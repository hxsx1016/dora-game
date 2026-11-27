/**
 * 《向西守望》统一三模输入总线（Axis 2 · 键鼠 kbm / 触屏 touch / 手柄 gamepad）。
 *
 * 深度解耦架构：
 * - 不直接依赖平台判断封杀某种输入：任何平台均可选择「自动切换」或手动指定 键鼠 / 触屏 / 手柄；
 * - 通过 TouchRouter.isSuppressingSyntheticMouse() 动态隔离 SDL 单指合成假鼠标，
 *   既杜绝安卓触屏左手摇杆误射，又让安卓平板/掌机外接实体键鼠零阻碍工作；
 * - 统一坐标变换：鼠标、触屏、手柄输出的 mx/my 与 uiX/uiY 均为**主舞台局部坐标**（左下原点），
 *   彻底屏蔽竖屏掌机模式舞台偏移，让 Play / Menu / ReloadWheel / CraftBench 零感知；
 * - 严格保留与固定步长的接缝（D3）：gameplay KeyState 边沿锁存至第一个可用模拟步，
 *   渲染帧 UI 通道（uiX..uiRightPressed、nav*、reload*、talent*）存活于整个渲染帧。
 */

import { App, Keyboard, KeyName, Mouse, View } from "Dora";
import {
    ControlSettings,
    GamepadLayout,
    InputMode,
    InputModePref,
    loadControlSettings,
    nextModePref,
    saveControlSettings,
} from "Script/watch/controls_config";
import { GamepadRouter, GamepadSnapshot } from "Script/watch/gamepad";
import {
    StageViewport,
    computeStageViewport,
    getPlatformCaps,
} from "Script/watch/platform";
import { TouchRouter, TouchSnapshot } from "Script/watch/touch";

/** 一个键的三种状态。pressed / released 只在发生的那一帧为真。 */
export interface KeyState {
    held: boolean;
    pressed: boolean;
    released: boolean;
}

function emptyKey(): KeyState {
    return { held: false, pressed: false, released: false };
}

export class Input {
    /** 水平输入：-1..1。键鼠、触屏摇杆、手柄左摇杆/十字键统一汇入。 */
    moveX = 0;
    /** 屏幕上下输入：-1..1。周戍纵深走位与序章逃柜共用。 */
    moveY = 0;

    jump: KeyState = emptyKey();
    crouch: KeyState = emptyKey();
    cover: KeyState = emptyKey();
    interact: KeyState = emptyKey();
    aim: KeyState = emptyKey();
    fire: KeyState = emptyKey();
    flare: KeyState = emptyKey();
    pause: KeyState = emptyKey();
    retry: KeyState = emptyKey();
    toggleView: KeyState = emptyKey();
    tab: KeyState = emptyKey();

    /** 1 / 2 / 3 直接选房或选本领；0 表示本帧没选。 */
    pickRoom = 0;

    /** 指针在主舞台内的局部坐标（左下原点、y 向上），与 DrawNode 绘制坐标一致。 */
    mx = 0;
    my = 0;
    /** 指针是否在主舞台可视区域内。 */
    inside = true;

    /** 上一帧的指针位置变化量。 */
    mdx = 0;
    mdy = 0;

    /**
     * 规范化渲染帧 UI 指针（主舞台局部坐标，菜单 / 换弹盘 / 工台 / 本领卡统一消费）：
     * - 边沿 uiPressed / uiReleased / uiRightPressed 存活于整个渲染帧，不会被模拟步 endStep() 清掉。
     */
    uiX = 0;
    uiY = 0;
    uiDx = 0;
    uiDy = 0;
    uiInside = false;
    uiHeld = false;
    uiPressed = false;
    uiReleased = false;
    uiRightPressed = false;

    /** 共享操控配置（全平台统一落盘至 watch-save/controls.txt） */
    readonly settings: ControlSettings = loadControlSettings();

    /** 当前实际活跃输入模式（kbm / touch / gamepad） */
    inputMode: InputMode = getPlatformCaps().defaultInputMode;

    /** 手柄确认键位布局镜像（始终与 settings.gamepadLayout 同步） */
    gamepadLayout: GamepadLayout = "xbox";

    /** 本会话是否收到过任意真实玩家输入（供 Web 音频首手势解锁） */
    userInteracted = false;

    /** 渲染帧内是否按下过交互键（不被模拟步 endStep 清空，供插件 renderPlay 读取） */
    frameInteractPressed = false;
    /** 渲染帧内是否由按键选天赋消费了 1-3，防非发行态穿透跳房 */
    private suppressPickRoomOnce = false;

    /** 单帧快捷边沿（供 app.ts 消费，不侵入 Play.update） */
    artifactTogglePressed = false;
    bottleCanceled = false;
    touchZoneTap = "";
    muteTogglePressed = false;
    fullscreenTogglePressed = false;
    splashSkipPressed = false;

    /** 渲染帧菜单导航边沿（手柄连发 + 竖屏掌机导航键汇入） */
    navUp = false;
    navDown = false;
    navLeft = false;
    navRight = false;
    navConfirm = false;
    navBack = false;
    navPrevTab = false;
    navNextTab = false;

    /** 3×3 换弹盘手柄 8 向步进信号 */
    reloadDirCol = 0;
    reloadDirRow = 0;
    reloadStepEdge = false;
    reloadAutoStep = false;
    reloadConfirm = false;
    reloadReset = false;

    /** 局内三选一本领卡手柄切选信号 */
    talentDelta = 0;
    talentConfirm = false;

    /** Back 长按重试进度（0..1） */
    retryHoldProgress = 0;

    private touchRouter: TouchRouter | undefined;
    private gamepadRouter: GamepadRouter | undefined;
    private stageVp: StageViewport = computeStageViewport(1280, 720);

    private lastPick = 0;
    private rawMouseX = -1;
    private rawMouseY = -1;
    private rawMouseInited = false;
    private prevMouseLeft = false;
    private prevMouseRight = false;

    constructor() {
        this.gamepadLayout = this.settings.gamepadLayout;
        if (this.settings.modePref !== "auto") {
            this.inputMode = this.settings.modePref;
        }
    }

    bindTouch(router: TouchRouter): void {
        this.touchRouter = router;
        router.settings = this.settings;
    }

    bindGamepad(router: GamepadRouter): void {
        this.gamepadRouter = router;
        router.settings = this.settings;
        this.gamepadLayout = this.settings.gamepadLayout;
    }

    getTouch(): TouchRouter | undefined {
        return this.touchRouter;
    }

    getGamepad(): GamepadRouter | undefined {
        return this.gamepadRouter;
    }

    setStageViewport(vp: StageViewport): void {
        this.stageVp = vp;
    }

    getStageViewport(): StageViewport {
        return this.stageVp;
    }

    isTouchMode(): boolean {
        return this.inputMode === "touch";
    }

    isGamepadMode(): boolean {
        return this.inputMode === "gamepad";
    }

    isKbmMode(): boolean {
        return this.inputMode === "kbm";
    }

    /** 供自动化测试或外部手动切当前活跃模式（若偏好为锁定模式，一并保持一致语义）。 */
    setInputMode(mode: InputMode): void {
        if (this.inputMode === mode) return;
        this.inputMode = mode;
        if (mode !== "touch") {
            this.touchRouter?.releaseAll(false);
        }
    }

    /** 玩家在「操控设置」中修改模式偏好（auto / kbm / touch / gamepad）并落盘。 */
    setModePref(pref: InputModePref): void {
        this.settings.modePref = pref;
        if (pref !== "auto") {
            this.setInputMode(pref);
        }
        saveControlSettings(this.settings);
    }

    cycleModePref(delta: number = 1): InputModePref {
        const next = nextModePref(this.settings.modePref, delta);
        this.setModePref(next);
        return next;
    }

    /**
     * 当前是否应显示虚拟触控层：
     * - 竖屏模式始终展示下半屏宋明水墨掌机台；
     * - 横屏模式：手动选「触屏」常显；手动选「键鼠/手柄」隐藏；「自动」则随 activeMode === "touch" 自动显隐。
     */
    shouldShowTouchControls(): boolean {
        if (this.stageVp.isPortrait) {
            return true;
        }
        if (this.settings.modePref === "touch") {
            return true;
        }
        if (this.settings.modePref === "kbm" || this.settings.modePref === "gamepad") {
            return false;
        }
        return this.inputMode === "touch";
    }

    /** 通知本帧收到了键盘按下事件（用于首手势解锁与自动切回 kbm）。 */
    markKeyboardActivity(): void {
        this.userInteracted = true;
        if (this.settings.modePref === "auto") {
            this.setInputMode("kbm");
        }
    }

    /** 切后台/暂停/切场景时统一释放触控与手柄瞬时态。 */
    clearTransient(keepTouchToggles: boolean = false): void {
        this.touchRouter?.releaseAll(keepTouchToggles);
        this.gamepadRouter?.clearTransient();
    }

    update(): void {
        this.gamepadLayout = this.settings.gamepadLayout;
        const touch = this.touchRouter !== undefined ? this.touchRouter.consumeSnapshot() : undefined;
        const gp = this.gamepadRouter !== undefined ? this.gamepadRouter.consumeSnapshot() : undefined;

        // 1. 采样原始物理鼠标（换算为全屏 View 坐标与主舞台局部坐标）
        const vs = App.visualSize;
        const vw = View.size.width > 0 ? View.size.width : this.stageVp.fullW;
        const vh = View.size.height > 0 ? View.size.height : this.stageVp.fullH;
        const sw = vs.width > 0 ? vs.width : 1;
        const sh = vs.height > 0 ? vs.height : 1;
        const p = Mouse.position;
        const fullX = p.x * vw / sw;
        const fullY = vh - (p.y * vh / sh);

        const mouseLeft = Mouse.leftButtonPressed;
        const mouseRight = Mouse.rightButtonPressed;
        const mouseMoved = this.rawMouseInited
            && (Math.abs(fullX - this.rawMouseX) + Math.abs(fullY - this.rawMouseY) >= 2.5);
        const mouseLeftPressed = mouseLeft && !this.prevMouseLeft;
        const mouseLeftReleased = !mouseLeft && this.prevMouseLeft;
        const mouseRightPressed = mouseRight && !this.prevMouseRight;
        const mouseClicked = mouseLeftPressed || mouseRightPressed;

        this.rawMouseX = fullX;
        this.rawMouseY = fullY;
        this.rawMouseInited = true;
        this.prevMouseLeft = mouseLeft;
        this.prevMouseRight = mouseRight;

        const stX = this.stageVp.stageW > 0 ? this.stageVp.stageX : 0;
        const stY = this.stageVp.stageH > 0 ? this.stageVp.stageY : 0;
        const stW = this.stageVp.stageW > 0 ? this.stageVp.stageW : vw;
        const stH = this.stageVp.stageH > 0 ? this.stageVp.stageH : vh;
        const mouseStageX = fullX - stX;
        const mouseStageY = fullY - stY;
        const mouseInsideStage = mouseStageX >= 0 && mouseStageX <= stW && mouseStageY >= 0 && mouseStageY <= stH;

        const suppressMouse = touch !== undefined && (touch.suppressSyntheticMouse || touch.mouseConsumedByOverlay);
        const realMouseActive = !suppressMouse && (mouseMoved || (mouseClicked && mouseInsideStage));

        // 2. 轮询物理键盘
        const left = Keyboard.isKeyPressed(KeyName.A) || Keyboard.isKeyPressed(KeyName.Left);
        const right = Keyboard.isKeyPressed(KeyName.D) || Keyboard.isKeyPressed(KeyName.Right);
        const up = Keyboard.isKeyPressed(KeyName.W) || Keyboard.isKeyPressed(KeyName.Up);
        const down = Keyboard.isKeyPressed(KeyName.S) || Keyboard.isKeyPressed(KeyName.Down);
        const kbJump = Keyboard.isKeyPressed(KeyName.Space);
        const kbCrouch = Keyboard.isKeyPressed(KeyName.LCtrl) || Keyboard.isKeyPressed(KeyName.RCtrl);
        const kbCover = Keyboard.isKeyPressed(KeyName.LShift) || Keyboard.isKeyPressed(KeyName.RShift);
        const kbInteract = Keyboard.isKeyPressed(KeyName.E);
        const kbAim = Keyboard.isKeyPressed(KeyName.F);
        const kbFlare = Keyboard.isKeyPressed(KeyName.Q);
        const kbPause = Keyboard.isKeyPressed(KeyName.Escape);
        const kbRetry = Keyboard.isKeyPressed(KeyName.R);
        const kbToggle = Keyboard.isKeyPressed(KeyName.G);
        const kbTab = Keyboard.isKeyPressed(KeyName.Tab);
        const n1 = Keyboard.isKeyPressed(KeyName.Num1);
        const n2 = Keyboard.isKeyPressed(KeyName.Num2);
        const n3 = Keyboard.isKeyPressed(KeyName.Num3);

        const anyKb = left || right || up || down || kbJump || kbCrouch || kbCover
            || kbInteract || kbAim || kbFlare || kbPause || kbRetry || kbToggle || kbTab
            || n1 || n2 || n3 || Keyboard.isKeyPressed(KeyName.Return);

        // 3. 三模仲裁（支持全平台自动热切换，或遵循用户手动锁定偏好）
        const hadGp = gp !== undefined && gp.hadGamepadInput;
        const hadTouchAny = touch !== undefined && touch.hadRealTouch;
        if (anyKb || realMouseActive || hadGp || hadTouchAny) {
            this.userInteracted = true;
        }

        if (this.settings.modePref !== "auto") {
            this.setInputMode(this.settings.modePref);
        } else {
            if (hadGp) {
                this.setInputMode("gamepad");
            } else if (touch !== undefined && touch.hadGameplayTouch) {
                this.setInputMode("touch");
            } else if (anyKb || realMouseActive) {
                this.setInputMode("kbm");
            } else if (touch !== undefined && touch.hadUiTouch && this.inputMode === "kbm") {
                this.setInputMode("touch");
            }
        }

        // 4. 合并三模移动与玩法动作状态
        const kbMoveX = (right ? 1 : 0) - (left ? 1 : 0);
        const kbMoveY = (down ? 1 : 0) - (up ? 1 : 0);
        const gpMoveX = gp !== undefined ? gp.moveX : 0;
        const gpMoveY = gp !== undefined ? gp.moveY : 0;
        const tMoveX = touch !== undefined ? touch.moveX : 0;
        const tMoveY = touch !== undefined ? touch.moveY : 0;
        this.moveX = kbMoveX !== 0 ? kbMoveX : (gpMoveX !== 0 ? gpMoveX : tMoveX);
        this.moveY = kbMoveY !== 0 ? kbMoveY : (gpMoveY !== 0 ? gpMoveY : tMoveY);

        const allowMouseFire = !suppressMouse && this.inputMode === "kbm" && mouseInsideStage;
        const rawFireHeld = (allowMouseFire && mouseLeft)
            || (gp !== undefined && gp.fireHeld)
            || (touch !== undefined && touch.fireHeld);

        this.jump = edge(this.jump, kbJump || (gp !== undefined && gp.jumpHeld) || (touch !== undefined && touch.jumpHeld));
        this.crouch = edge(this.crouch, kbCrouch || (gp !== undefined && gp.crouchHeld) || (touch !== undefined && touch.crouchHeld));
        this.cover = edge(this.cover, kbCover || (gp !== undefined && gp.coverHeld) || (touch !== undefined && touch.coverHeld));
        this.interact = edge(this.interact, kbInteract || (gp !== undefined && gp.interactHeld) || (touch !== undefined && touch.interactHeld));
        this.aim = edge(this.aim, kbAim || (gp !== undefined && gp.aimHeld) || (touch !== undefined && touch.aimHeld));
        this.fire = edge(this.fire, rawFireHeld);
        this.flare = edge(this.flare, kbFlare || (gp !== undefined && gp.flareHeld));
        this.pause = edge(this.pause, kbPause);
        this.retry = edge(this.retry, kbRetry);
        this.toggleView = edge(this.toggleView, kbToggle);
        this.tab = edge(this.tab, kbTab);

        // 5. 合并单帧边沿与渲染帧模态信号
        this.artifactTogglePressed = false;
        this.bottleCanceled = false;
        this.touchZoneTap = "";
        this.muteTogglePressed = false;
        this.fullscreenTogglePressed = false;
        this.splashSkipPressed = false;

        this.navUp = false;
        this.navDown = false;
        this.navLeft = false;
        this.navRight = false;
        this.navConfirm = false;
        this.navBack = false;
        this.navPrevTab = false;
        this.navNextTab = false;

        this.reloadDirCol = 0;
        this.reloadDirRow = 0;
        this.reloadStepEdge = false;
        this.reloadAutoStep = false;
        this.reloadConfirm = false;
        this.reloadReset = false;

        this.talentDelta = 0;
        this.talentConfirm = false;
        this.retryHoldProgress = 0;

        if (gp !== undefined) {
            if (gp.jumpPressed) this.jump.pressed = true;
            if (gp.crouchPressed) this.crouch.pressed = true;
            if (gp.interactPressed) this.interact.pressed = true;
            if (gp.aimPressed) this.aim.pressed = true;
            if (gp.firePressed) this.fire.pressed = true;
            if (gp.flarePressed) this.flare.pressed = true;
            if (gp.pausePressed) this.pause.pressed = true;
            if (gp.retryPressed) this.retry.pressed = true;
            if (gp.artifactPressed) this.artifactTogglePressed = true;
            if (gp.anyButtonPressed) this.splashSkipPressed = true;
            if (gp.bottleCanceled) {
                this.bottleCanceled = true;
                this.aim.held = false;
                this.aim.pressed = false;
                this.aim.released = false;
            }
            this.navUp = gp.navUp;
            this.navDown = gp.navDown;
            this.navLeft = gp.navLeft;
            this.navRight = gp.navRight;
            this.navConfirm = gp.navConfirm;
            this.navBack = gp.navBack;
            this.navPrevTab = gp.navPrevTab;
            this.navNextTab = gp.navNextTab;
            this.reloadDirCol = gp.reloadDirCol;
            this.reloadDirRow = gp.reloadDirRow;
            this.reloadStepEdge = gp.reloadStepEdge;
            this.reloadAutoStep = gp.reloadAutoStep;
            this.reloadConfirm = gp.reloadConfirm;
            this.reloadReset = gp.reloadReset;
            this.talentDelta = gp.talentDelta;
            this.talentConfirm = gp.talentConfirm;
            this.retryHoldProgress = gp.retryHoldProgress;
        }

        if (touch !== undefined) {
            if (touch.jumpPressed) this.jump.pressed = true;
            if (touch.interactPressed) this.interact.pressed = true;
            if (touch.firePressed) this.fire.pressed = true;
            if (touch.pausePressed) this.pause.pressed = true;
            if (touch.retryPressed) this.retry.pressed = true;
            if (touch.artifactPressed) this.artifactTogglePressed = true;
            if (touch.mutePressed) this.muteTogglePressed = true;
            if (touch.fullscreenPressed) this.fullscreenTogglePressed = true;
            if (touch.anyTapBegan) this.splashSkipPressed = true;
            if (touch.zoneTap !== "") this.touchZoneTap = touch.zoneTap;
            if (touch.navUp) this.navUp = true;
            if (touch.navDown) this.navDown = true;
            if (touch.navLeft) this.navLeft = true;
            if (touch.navRight) this.navRight = true;
            if (touch.navConfirm) this.navConfirm = true;
            if (touch.navBack) this.navBack = true;
            if (touch.bottleCanceled) {
                this.bottleCanceled = true;
                this.aim.held = false;
                this.aim.pressed = false;
                this.aim.released = false;
            }
        }

        const pick = n1 ? 1 : (n2 ? 2 : (n3 ? 3 : 0));
        if (this.suppressPickRoomOnce) {
            this.suppressPickRoomOnce = false;
            this.pickRoom = 0;
        } else if (pick !== 0 && pick !== this.lastPick) {
            this.pickRoom = pick;
        }
        this.lastPick = pick;
        this.frameInteractPressed = this.interact.pressed;

        // 6. 合并主舞台准星（mx/my）与渲染帧 UI 指针（uiX..uiRightPressed）
        const touchUiActive = touch !== undefined
            && (touch.uiHeld || touch.uiPressed || touch.uiReleased || touch.uiInside);

        if (touchUiActive && touch !== undefined) {
            this.uiX = touch.uiX;
            this.uiY = touch.uiY;
            this.uiDx = touch.uiDx;
            this.uiDy = touch.uiDy;
            this.uiInside = touch.uiInside;
            this.uiHeld = touch.uiHeld;
            this.uiPressed = touch.uiPressed;
            this.uiReleased = touch.uiReleased;
            this.uiRightPressed = false;
            if (touch.uiHeld || touch.uiPressed) {
                this.mdx = touch.uiDx;
                this.mdy = touch.uiDy;
                this.mx = touch.uiX;
                this.my = touch.uiY;
                this.inside = true;
            } else if (touch.hasAim) {
                this.mdx = touch.aimX - this.mx;
                this.mdy = touch.aimY - this.my;
                this.mx = touch.aimX;
                this.my = touch.aimY;
                this.inside = true;
            } else {
                this.mdx = 0;
                this.mdy = 0;
                this.inside = touch.uiInside;
            }
            return;
        }

        if (this.inputMode === "gamepad") {
            if (gp !== undefined && gp.hasAim) {
                this.mdx = gp.aimX - this.mx;
                this.mdy = gp.aimY - this.my;
                this.mx = gp.aimX;
                this.my = gp.aimY;
                this.inside = true;
            } else {
                this.mdx = 0;
                this.mdy = 0;
                this.inside = false;
            }
            // 手柄态静默鼠标悬停防抢焦；但在桌面锁定手柄模式下若真实点击菜单/UI仍保留 uiPressed，绝不锁死桌面点选
            if (!suppressMouse && mouseInsideStage && (mouseLeft || mouseLeftPressed || mouseLeftReleased)) {
                this.uiDx = mouseStageX - this.uiX;
                this.uiDy = mouseStageY - this.uiY;
                this.uiX = mouseStageX;
                this.uiY = mouseStageY;
                this.uiInside = true;
                this.uiHeld = mouseLeft;
                this.uiPressed = mouseLeftPressed;
                this.uiReleased = mouseLeftReleased;
                this.uiRightPressed = mouseRightPressed;
            } else {
                this.uiX = this.mx;
                this.uiY = this.my;
                this.uiDx = 0;
                this.uiDy = 0;
                this.uiInside = false;
                this.uiHeld = false;
                this.uiPressed = false;
                this.uiReleased = false;
                this.uiRightPressed = false;
            }
            return;
        }

        if (this.inputMode === "touch") {
            if (touch !== undefined && touch.hasAim) {
                this.mdx = touch.aimX - this.mx;
                this.mdy = touch.aimY - this.my;
                this.mx = touch.aimX;
                this.my = touch.aimY;
                this.inside = true;
            } else {
                this.mdx = 0;
                this.mdy = 0;
                this.inside = false;
            }
            // 手动锁定触屏模式时（例如桌面/Web 预览），若无真实手指且鼠标点击了舞台菜单/换弹盘，仍允许单指点选避免锁死
            if (!suppressMouse && mouseInsideStage && (mouseLeft || mouseLeftPressed || mouseLeftReleased)) {
                this.uiDx = mouseStageX - this.uiX;
                this.uiDy = mouseStageY - this.uiY;
                this.uiX = mouseStageX;
                this.uiY = mouseStageY;
                this.uiInside = true;
                this.uiHeld = mouseLeft;
                this.uiPressed = mouseLeftPressed;
                this.uiReleased = mouseLeftReleased;
                this.uiRightPressed = mouseRightPressed;
            } else {
                this.uiDx = 0;
                this.uiDy = 0;
                this.uiInside = false;
                this.uiHeld = false;
                this.uiPressed = false;
                this.uiReleased = false;
                this.uiRightPressed = false;
            }
            return;
        }

        // kbm 键鼠模式（主舞台局部坐标，100% 兼容原生键鼠行为）
        this.mdx = mouseStageX - this.mx;
        this.mdy = mouseStageY - this.my;
        this.mx = mouseStageX;
        this.my = mouseStageY;
        this.inside = mouseInsideStage;

        const effLeft = !suppressMouse && mouseLeft && mouseInsideStage;
        const effLeftPressed = !suppressMouse && mouseLeftPressed && mouseInsideStage;
        const effLeftReleased = !suppressMouse && mouseLeftReleased;
        const effRightPressed = !suppressMouse && mouseRightPressed && mouseInsideStage;
        this.uiX = mouseStageX;
        this.uiY = mouseStageY;
        this.uiDx = this.mdx;
        this.uiDy = this.mdy;
        this.uiInside = mouseInsideStage;
        this.uiHeld = effLeft;
        this.uiPressed = effLeftPressed;
        this.uiReleased = effLeftReleased;
        this.uiRightPressed = effRightPressed;
    }

    /** 标记本帧 1/2/3 已被天赋选择消费，阻止穿透触发调试跳房 */
    consumePickRoom(): void {
        this.pickRoom = 0;
        this.suppressPickRoomOnce = true;
    }

    /** 虚拟按钮请求选卡（1/2/3） */
    requestPickRoom(slot: number): void {
        if (slot >= 1 && slot <= 3) {
            this.pickRoom = slot;
        }
    }

    beginStep(first: boolean): void {
        if (!first) {
            this.clearEdges();
        }
    }

    endStep(): void {
        this.clearEdges();
    }

    consumeEdges(): void {
        this.clearEdges();
    }

    private clearEdges(): void {
        this.jump.pressed = false;
        this.jump.released = false;
        this.crouch.pressed = false;
        this.crouch.released = false;
        this.cover.pressed = false;
        this.cover.released = false;
        this.interact.pressed = false;
        this.interact.released = false;
        this.aim.pressed = false;
        this.aim.released = false;
        this.fire.pressed = false;
        this.fire.released = false;
        this.flare.pressed = false;
        this.flare.released = false;
        this.pause.pressed = false;
        this.pause.released = false;
        this.retry.pressed = false;
        this.retry.released = false;
        this.toggleView.pressed = false;
        this.toggleView.released = false;
        this.tab.pressed = false;
        this.tab.released = false;
    }
}

function edge(state: KeyState, held: boolean): KeyState {
    const was = state.held;
    state.held = held;
    if (held && !was) {
        state.pressed = true;
    }
    if (!held && was) {
        state.released = true;
    }
    return state;
}
