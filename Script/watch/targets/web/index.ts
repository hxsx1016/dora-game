/**
 * 《向西守望》Web 浏览器目标（全包含：键鼠 + 触屏 + 手柄 + 横竖屏自适应）。
 *
 * 完整保留三模热切、竖屏 16:9 宋明水墨掌机台、250ms SDL 合成假鼠标隔离与浏览器首手势音频解锁，
 * 同时享受轻量化 36-Label TouchControls、隐藏态零空转清屏与单次敌兵磁吸投影优化。
 */

import { App, Node } from "Dora";
import { AimTargetCandidate, collectAimTargets, projectMuzzle } from "Script/watch/input/aim_assist";
import { GamepadFrameContext, GamepadRawState, GamepadRouter } from "Script/watch/input/gamepad_core";
import { KbmPoller } from "Script/watch/input/kbm_core";
import { TouchRouter } from "Script/watch/input/touch_core";
import { TouchControls } from "Script/watch/input/touch_hud_landscape";
import { PORTRAIT_TOUCH_DELEGATE } from "Script/watch/input/touch_hud_portrait";
import { isCutsceneBlockingPlay } from "Script/watch/fe/ui/play_prompts";
import { computeAdaptiveViewport, triggerMobileHaptics } from "Script/watch/platform_mobile";
import {
    MODE_PREF_ORDER,
    TOUCH_OPACITY_STEPS,
    TOUCH_SCALE_STEPS,
    applyVolumeSetting,
    inputModeLabelOf,
    layoutLabelOf,
    modePrefLabelOf,
    nextStepValue,
    opacityLabelOf,
    saveControlSettings,
    scaleLabelOf,
    volumeSettingText,
} from "Script/watch/controls_config";
import type { Input } from "Script/watch/input";
import {
    ControlSettings,
    ControlsGuidePage,
    GamepadLayout,
    InputMode,
    KeyActionId,
    PlatformCaps,
    SettingsRowDef,
    StageViewport,
    TargetAttachHooks,
    TargetFrameSync,
    TargetInputDriver,
    TargetRuntime,
    getReleaseConfig,
} from "Script/watch/target_types";

const WEB_SETTINGS_ROWS: SettingsRowDef[] = [
    { id: "modePref", title: "操作模式" },
    { id: "aimAssist", title: "瞄准磁吸" },
    { id: "gpLayout", title: "手柄确认键" },
    { id: "crouchMode", title: "手柄蹲伏方式" },
    { id: "touchOpacity", title: "触控按键透度" },
    { id: "touchScale", title: "触控按键大小" },
    { id: "haptics", title: "触觉震动反馈" },
    { id: "masterVol", title: "主音量" },
    { id: "bgmVol", title: "音乐音量" },
    { id: "sfxVol", title: "音效与环境" },
    { id: "voiceVol", title: "人声音量" },
    { id: "back", title: "返回暂歇菜单" },
];

const GUIDE_KBM: ControlsGuidePage = {
    subtitle: "键鼠操作说明 · 全平台通用",
    soldierRows: [
        ["WASD / 方向键", "左右、前后纵深自由移动"],
        ["鼠标 + 左键 / Q", "瞄准发射火铳 · Q 随时开换弹盘"],
        ["按住 SHIFT / SPACE", "贴靠掩体挡弹 · 平地翻滚或翻越"],
        ["E / 1·2·3", "交互推车工台 · 数字键选护送本领"],
        ["拖线 / 方向+回车", "慢时 3×3 换弹盘 · 右键/退格重画"],
        ["ESC / R / T", "暂歇菜单 / 重试检查点 / 切神器"],
    ],
    childRows: [
        ["A / D · ← / →", "左右潜行"],
        ["按住 SHIFT", "轻步慢走（压低脚步声）"],
        ["按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"],
        ["SPACE", "跳跃攀上石阶与矮台"],
        ["E", "拾瓶 / 敲塔门 / 按住+D 拉车"],
        ["F 按住→松开", "瞄准砖地/铁盆投瓶 · 右键取消"],
    ],
};

const GUIDE_GAMEPAD: ControlsGuidePage = {
    subtitle: "手柄操作说明 · 全平台通用",
    soldierRows: [
        ["左摇杆 / 十字键", "左右、前后纵深移动"],
        ["右摇杆 + RT / X", "360° 瞄准与发射火铳（含轻磁吸）"],
        ["按住 LT / LB", "贴靠柜台 / 街垒挡下铅丸"],
        ["A 键", "平地翻滚 / 靠近矮柜翻越"],
        ["Y / RB 键", "递物 / 轻敲安抚 / 按住推车"],
        ["摇杆直推 / 触屏", "慢时连线换弹 · B 键清空重画"],
    ],
    childRows: [
        ["左摇杆轻推", "内圈轻步慢走（LT/LB 亦可）"],
        ["B 键", "蹲伏隐蔽 · 穿低拱与桌底"],
        ["A 键", "跳跃攀上石阶与矮台"],
        ["Y / RB 键", "拾瓶 / 敲塔门 / 握柄拉车"],
        ["RT/X 按住→松开", "右摇杆调落点投瓶 · B 取消"],
        ["START / BACK", "暂歇 / 长按重试 · L3 切神器"],
    ],
};

const GUIDE_TOUCH: ControlsGuidePage = {
    subtitle: "触屏操作说明 · 横屏全屏 / 竖屏掌机台",
    soldierRows: [
        ["左水墨摇杆", "全向走位与里外道切线"],
        ["点屏 / 开火钮", "直点射击或拖住开火钮 360° 精瞄"],
        ["掩体开关", "轻点贴靠掩体，再点或翻滚离掩"],
        ["翻滚 / 翻越", "平地翻滚，贴近矮柜自动翻越"],
        ["交互 / 推车", "点推车自动锁握柄，长按牵手交物"],
        ["换弹九宫格", "单指一笔滑连至右上，点重画清空"],
    ],
    childRows: [
        ["摇杆内圈 / 轻步", "轻推内圈或点轻步压低脚步声"],
        ["蹲伏开关", "点按蹲下钻桌穿拱，点跳顺滑起身"],
        ["跳跃钮", "攀上石阶、红布车与矮台"],
        ["投瓶拖瞄", "按住投瓶拖向砖地，拖回取消圈放弃"],
        ["交互 / 拉车", "拾瓶、敲塔门、点拉车锁定握柄"],
        ["右上暂歇 / 竖屏", "顶栏随时暂歇，竖屏自动展掌机台"],
    ],
};

function keyTagWeb(action: KeyActionId, mode: InputMode, layout: GamepadLayout): string {
    if (mode === "gamepad") {
        const confirmBtn = layout === "nintendo" ? "B" : "A";
        const backBtn = layout === "nintendo" ? "A" : "B";
        if (action === "interact") return "Y / RB";
        if (action === "jump") return "A";
        if (action === "crouch") return "B";
        if (action === "cover") return "LT / LB";
        if (action === "fire") return "RT / X";
        if (action === "aim") return "RT / X";
        if (action === "pause") return "START";
        if (action === "retry") return "长按 BACK";
        if (action === "confirm") return confirmBtn;
        if (action === "back") return backBtn;
        return "L3";
    }
    if (mode === "touch") {
        if (action === "interact") return "点按";
        if (action === "jump") return "跳/滚";
        if (action === "crouch") return "蹲伏";
        if (action === "cover") return "掩体";
        if (action === "fire") return "开火";
        if (action === "aim") return "拖投瓶";
        if (action === "pause") return "暂歇";
        if (action === "retry") return "重试";
        if (action === "confirm") return "点选";
        if (action === "back") return "返回";
        return "穿梭";
    }
    if (action === "interact") return "E";
    if (action === "jump") return "SPACE";
    if (action === "crouch") return "CTRL";
    if (action === "cover") return "SHIFT";
    if (action === "fire") return "左键";
    if (action === "aim") return "F";
    if (action === "pause") return "ESC";
    if (action === "retry") return "R";
    if (action === "confirm") return "ENTER";
    if (action === "back") return "ESC";
    return "T";
}

function adaptWorldKeyTagWeb(rawKeyTag: string, mode: InputMode): string {
    if (mode === "kbm") return rawKeyTag;
    if (mode === "gamepad") {
        if (rawKeyTag === "E") return "Y";
        if (rawKeyTag === "按住 E") return "按住 Y";
        if (rawKeyTag === "松开再按住 E") return "松开再按 Y";
        if (rawKeyTag === "按住 E + D") return "按住 Y + 右";
        if (rawKeyTag === "E 握柄 + D") return "Y 握柄 + 右";
        if (rawKeyTag === "F" || rawKeyTag === "左键") return "RT / X";
        if (rawKeyTag === "按住 F") return "按住 RT";
        if (rawKeyTag === "松开 F") return "松开 RT";
        if (rawKeyTag === "按住 Ctrl") return "按住 B";
        if (rawKeyTag === "按住 Shift") return "按住 LT";
        if (rawKeyTag === "连线") return "摇杆/触屏连线";
        if (rawKeyTag === "→") return "右推摇杆";
        return rawKeyTag;
    }
    if (rawKeyTag === "E") return "轻触";
    if (rawKeyTag === "按住 E") return "长按交互";
    if (rawKeyTag === "松开再按住 E") return "松开再长按";
    if (rawKeyTag === "按住 E + D" || rawKeyTag === "E 握柄 + D") return "点推车+摇杆";
    if (rawKeyTag === "F" || rawKeyTag === "左键") return "开火";
    if (rawKeyTag === "按住 F") return "拖投瓶";
    if (rawKeyTag === "松开 F") return "松手投";
    if (rawKeyTag === "按住 Ctrl") return "点蹲伏";
    if (rawKeyTag === "按住 Shift") return "点掩体";
    if (rawKeyTag === "连线") return "一笔划连";
    return rawKeyTag;
}

function adaptHintSentenceWeb(text: string, mode: InputMode, layout: GamepadLayout): string {
    if (mode === "kbm" || text === "") return text;
    if (mode === "gamepad") {
        const backBtn = layout === "nintendo" ? "A" : "B";
        return text
            .split("[SHIFT]").join("[LT/LB]")
            .split("[CTRL]").join("[B]")
            .split("[E]+[D]").join("[Y]+右推")
            .split("[E]").join("[Y]")
            .split("[F]").join("[RT/X]")
            .split("[SPACE]").join("[A]")
            .split("[W/S]").join("左摇杆上下")
            .split("[A/D]").join("左摇杆左右")
            .split("[W]").join("左摇杆向上")
            .split("[S]").join("左摇杆向下")
            .split("[ESC]").join("[START]")
            .split("[R]").join("长按 [BACK]")
            .split("鼠标瞄准，左键发射火铳").join("右摇杆瞄准，按 [RT/X] 发射火铳")
            .split("左键先手击倒").join("按 [RT/X] 先手击倒")
            .split("左键发射火铳").join("按 [RT/X] 发射火铳")
            .split("左键发铳").join("按 [RT/X] 发铳")
            .split("按 E 再次启程").join("按 Y 再次启程")
            .split("按住 E").join("按住 Y")
            .split("方向键").join("左摇杆")
            .split("Esc 暂歇").join("START 暂歇")
            .split("返回").join("按 " + backBtn + " 返回");
    }
    return text
        .split("按住 [E]+[D]").join("点按推/拉车并推摇杆")
        .split("[E]+[D]").join("推/拉车并推摇杆")
        .split("速按 [CTRL]").join("点按「蹲伏」")
        .split("按住 [CTRL]").join("点按「蹲伏」")
        .split("按 [CTRL]").join("点按「蹲伏」")
        .split("[CTRL]").join("「蹲伏」")
        .split("按住 [SHIFT]").join("点按「轻步/掩体」")
        .split("[SHIFT]").join("「轻步/掩体」")
        .split("按住 [F]").join("按住「投瓶」拖拽")
        .split("[F]").join("「投瓶」")
        .split("按住 E").join("长按「交互」")
        .split("按 [E]").join("点按「交互」")
        .split("[E]").join("「交互」")
        .split("方向键").join("左下摇杆")
        .split("按 [ESC]").join("轻触右上「暂歇」")
        .split("[ESC]").join("右上「暂歇」")
        .split("按 [SPACE]").join("点按「翻滚/跳跃」")
        .split("[SPACE]").join("「翻滚/跳跃」")
        .split("按 [R]").join("在暂歇菜单重试")
        .split("[A/D]").join("左下摇杆")
        .split("[W/S]").join("摇杆上下")
        .split("[W]").join("摇杆向上")
        .split("[S]").join("摇杆向下")
        .split("鼠标瞄准，左键发射火铳").join("点屏或拖「开火」发射火铳")
        .split("左键先手击倒").join("点屏或「开火」先手击倒")
        .split("左键发射火铳").join("点屏或「开火」发射火铳")
        .split("左键发铳").join("点屏或「开火」发铳")
        .split("左键").join("点屏或「开火」")
        .split("鼠标").join("触屏")
        .split("按 E 再次启程").join("轻触屏幕再次启程")
        .split("Esc 暂歇").join("轻触右上暂歇");
}

class WebInputDriver implements TargetInputDriver {
    readonly defaultMode: InputMode = "kbm";
    private kbm = new KbmPoller();
    private touchRouter: TouchRouter;
    private gamepadRouter: GamepadRouter;
    private touchControls: TouchControls | undefined;
    private settings: ControlSettings;

    constructor(settings: ControlSettings) {
        this.settings = settings;
        this.touchRouter = new TouchRouter(settings, {
            enableMouseCompat: true,
            enablePortrait: true,
        });
        this.gamepadRouter = new GamepadRouter(settings);
    }

    attach(parent: Node.Type, hooks: TargetAttachHooks): void {
        this.kbm.attach(parent, hooks);
        this.touchRouter.attach(parent);
        this.gamepadRouter.attach(parent);
        if (this.touchControls === undefined) {
            this.touchControls = new TouchControls(parent, PORTRAIT_TOUCH_DELEGATE);
        }
    }

    syncFrame(ctx: TargetFrameSync): void {
        const vp = ctx.viewport;
        const p = ctx.play;
        const isPlayMode = ctx.mode === 1 && ctx.screen === "play" && p !== undefined;
        const gameplayActive = isPlayMode;
        const talentModalOpen = isPlayMode && p !== undefined && !p.paused && !p.craftBench.active
            && !p.reloadOpen && !p.escortFailed && p.talentModalActive && p.getStoryTalentOffers().length > 0;
        const escortSummaryOpen = isPlayMode && p !== undefined && !p.paused && p.escortFailed;

        const modal = !gameplayActive
            || (isPlayMode && p !== undefined && (p.paused || p.reloadOpen || p.craftBench.active || talentModalOpen || escortSummaryOpen));
        const reloadActive = isPlayMode && p !== undefined && !p.paused && p.reloadOpen;
        const craftActive = isPlayMode && p !== undefined && !p.paused && p.craftBench.active;
        const talentOfferCount = isPlayMode && p !== undefined && !p.paused && !p.craftBench.active && !p.reloadOpen && !p.escortFailed
            ? (ctx.storyTalentBoxes.length > 0 ? ctx.storyTalentBoxes.length : p.getStoryTalentOffers().length)
            : 0;
        const cutsceneBlocking = isPlayMode && p !== undefined ? isCutsceneBlockingPlay(p) : false;
        const allowDepth = p !== undefined && p.room.depth !== undefined
            && (!p.childMode || p.phase === "prologue-escape");
        const peacefulRoom = p !== undefined && (p.room.key === "museum" || p.room.key === "tower");
        const canShoot = gameplayActive && p !== undefined && !p.childMode && !peacefulRoom && !p.gripping
            && !modal && !cutsceneBlocking && p.escort.state !== "calming";
        const canBottleAim = isPlayMode && p !== undefined && p.childMode && p.room.key === "village"
            && p.hasBottle && !p.passed && !modal && !cutsceneBlocking;
        const inLowArch = p !== undefined && p.room.arch.h > 0
            && p.player.x >= p.room.arch.x0 - 10 && p.player.x <= p.room.arch.x1 + 10
            && p.player.y <= p.room.arch.y + p.room.arch.h;
        const inTowerEnd = isPlayMode && p !== undefined && p.room.key === "tower" && p.phase === "tower-end";

        // 单帧仅采集一次敌兵磁吸目标，供触屏与手柄复用
        const enemyTargets: AimTargetCandidate[] = canShoot && this.settings.aimAssist && p !== undefined
            ? collectAimTargets(p, ctx.cam, vp.stageW, vp.stageH)
            : [];

        if (this.touchControls !== undefined) {
            const pref = this.settings.modePref;
            this.touchControls.syncContext({
                viewport: vp,
                mode: ctx.mode,
                screen: ctx.screen,
                play: p,
                run: ctx.run,
                cam: ctx.cam,
                router: this.touchRouter,
                overlayActive: this.shouldShowTouchControls(ctx.input, vp),
                allowAutoGameplayTouch: pref === "auto" || pref === "touch",
                allowMouseOnOverlay: vp.isPortrait || pref === "touch",
                showWebTopPills: true,
                canToggleFullscreen: true,
                assistHintsEnabled: ctx.assistHintsEnabled,
                isMuted: ctx.isMuted,
                isFullscreen: ctx.isFullscreen,
                storyTalentBoxes: ctx.storyTalentBoxes,
                escortDeathBoxes: ctx.escortDeathBoxes,
                ledgerButtonBox: ctx.ledgerButtonBox,
                enemyTargets,
                dt: ctx.dt,
            });
        }

        const muzzle = p !== undefined ? projectMuzzle(p, ctx.cam) : undefined;
        const playerScreenX = muzzle?.x ?? vp.stageW * 0.5;
        const playerScreenY = muzzle?.y ?? vp.stageH * 0.38;

        const gpCtx: GamepadFrameContext = {
            stageW: vp.stageW,
            stageH: vp.stageH,
            uiScale: vp.uiScale,
            modal,
            gameplayActive,
            reloadActive,
            craftActive,
            talentOfferCount,
            childMode: p !== undefined && p.childMode,
            allowDepth,
            canShoot,
            canBottleAim,
            playerRolling: p !== undefined && p.player.rollT > 0,
            inLowArch,
            inTowerEnd,
            playerFacing: p !== undefined ? p.player.facing : 1,
            playerScreenX,
            playerScreenY,
            enemyTargets,
        };
        this.gamepadRouter.setFrameContext(gpCtx, ctx.dt);
    }

    renderOverlay(): void {
        this.touchControls?.render(this.touchRouter);
    }

    clearTransient(keepTouchToggles: boolean): void {
        this.touchRouter.releaseAll(keepTouchToggles);
        this.gamepadRouter.clearTransient();
    }

    vibrate(seconds: number): void {
        this.touchRouter.vibrate(seconds);
    }

    onInputModeChanged(mode: InputMode): void {
        if (mode !== "touch") {
            this.touchRouter.releaseAll(false);
        }
    }

    shouldShowTouchControls(input: Input, vp: StageViewport): boolean {
        if (vp.isPortrait) return true;
        if (this.settings.modePref === "touch") return true;
        if (this.settings.modePref === "kbm" || this.settings.modePref === "gamepad") return false;
        return input.inputMode === "touch";
    }

    getTouchRouter(): TouchRouter {
        return this.touchRouter;
    }

    getGamepadRouter(): GamepadRouter {
        return this.gamepadRouter;
    }

    getTouchControls(): TouchControls | undefined {
        return this.touchControls;
    }

    injectTouch(phase: "began" | "moved" | "ended", id: number, x: number, y: number, fromMouse?: boolean): void {
        this.touchRouter.injectTouch(phase, id, x, y, fromMouse === true);
    }

    setGamepadSim(state?: unknown): void {
        this.gamepadRouter.setSimulatedState(state as GamepadRawState | undefined);
    }

    pollInto(input: Input): void {
        input.gamepadLayout = this.settings.gamepadLayout;
        const touch = this.touchRouter.consumeSnapshot();
        const gp = this.gamepadRouter.consumeSnapshot();
        const kbm = this.kbm.sample(input.getStageViewport());

        const suppressMouse = touch.suppressSyntheticMouse || touch.mouseConsumedByOverlay;
        const realMouseActive = !suppressMouse && (kbm.mouseMoved || (kbm.mouseClicked && kbm.mouseInsideStage));

        if (kbm.anyKb || realMouseActive || gp.hadGamepadInput || touch.hadRealTouch) {
            input.userInteracted = true;
        }

        if (this.settings.modePref !== "auto") {
            input.setInputMode(this.settings.modePref);
        } else if (gp.hadGamepadInput) {
            input.setInputMode("gamepad");
        } else if (touch.hadGameplayTouch) {
            input.setInputMode("touch");
        } else if (kbm.anyKb || realMouseActive) {
            input.setInputMode("kbm");
        } else if (touch.hadUiTouch && input.inputMode === "kbm") {
            input.setInputMode("touch");
        }

        input.moveX = kbm.moveX !== 0 ? kbm.moveX : (gp.moveX !== 0 ? gp.moveX : touch.moveX);
        input.moveY = kbm.moveY !== 0 ? kbm.moveY : (gp.moveY !== 0 ? gp.moveY : touch.moveY);

        const allowMouseFire = !suppressMouse && input.inputMode === "kbm" && kbm.mouseInsideStage;
        const rawFireHeld = (allowMouseFire && kbm.mouseLeft) || gp.fireHeld || touch.fireHeld;

        input.applyKeyHeld(
            kbm.jump || gp.jumpHeld || touch.jumpHeld,
            kbm.crouch || gp.crouchHeld || touch.crouchHeld,
            kbm.cover || gp.coverHeld || touch.coverHeld,
            kbm.interact || gp.interactHeld || touch.interactHeld,
            kbm.aim || gp.aimHeld || touch.aimHeld,
            rawFireHeld,
            kbm.flare || gp.flareHeld,
            kbm.pause,
            kbm.retry,
            kbm.toggleView,
            kbm.tab,
        );

        input.resetFrameSignals();

        // KBM 模态导航与换弹盘/工台按键边沿
        input.navUp = kbm.navUp;
        input.navDown = kbm.navDown;
        input.navLeft = kbm.navLeft;
        input.navRight = kbm.navRight;
        input.navConfirm = kbm.navConfirm;
        input.craftConfirm = kbm.uiConfirmWithE;
        input.craftCancel = kbm.uiBackSpace;
        const kCol = (kbm.navRight ? 1 : 0) - (kbm.navLeft ? 1 : 0);
        const kRow = (kbm.navUp ? 1 : 0) - (kbm.navDown ? 1 : 0);
        if (kCol !== 0 || kRow !== 0) {
            input.reloadDirCol = kCol;
            input.reloadDirRow = kRow;
            input.reloadStepEdge = true;
            input.reloadAutoStep = false;
        }
        input.reloadConfirm = kbm.uiConfirmWithE;
        input.reloadReset = kbm.uiBackSpace;

        if (gp.jumpPressed) input.jump.pressed = true;
        if (gp.crouchPressed) input.crouch.pressed = true;
        if (gp.interactPressed) input.interact.pressed = true;
        if (gp.aimPressed) input.aim.pressed = true;
        if (gp.firePressed) input.fire.pressed = true;
        if (gp.flarePressed) input.flare.pressed = true;
        if (gp.pausePressed) input.pause.pressed = true;
        if (gp.retryPressed) input.retry.pressed = true;
        if (gp.artifactPressed) input.artifactTogglePressed = true;
        if (gp.anyButtonPressed) input.splashSkipPressed = true;
        if (gp.bottleCanceled) {
            input.bottleCanceled = true;
            input.aim.held = false;
            input.aim.pressed = false;
            input.aim.released = false;
        }
        if (gp.navUp) input.navUp = true;
        if (gp.navDown) input.navDown = true;
        if (gp.navLeft) input.navLeft = true;
        if (gp.navRight) input.navRight = true;
        if (gp.navConfirm) {
            input.navConfirm = true;
            input.craftConfirm = true;
        }
        if (gp.navBack) {
            input.navBack = true;
            input.craftCancel = true;
        }
        input.navPrevTab = gp.navPrevTab;
        input.navNextTab = gp.navNextTab;
        if (gp.reloadStepEdge) {
            input.reloadDirCol = gp.reloadDirCol;
            input.reloadDirRow = gp.reloadDirRow;
            input.reloadStepEdge = true;
            input.reloadAutoStep = gp.reloadAutoStep;
        }
        if (gp.reloadConfirm) input.reloadConfirm = true;
        if (gp.reloadReset) input.reloadReset = true;
        input.talentDelta = gp.talentDelta;
        input.talentConfirm = gp.talentConfirm;
        input.retryHoldProgress = gp.retryHoldProgress;

        if (touch.jumpPressed) input.jump.pressed = true;
        if (touch.interactPressed) input.interact.pressed = true;
        if (touch.firePressed) input.fire.pressed = true;
        if (touch.pausePressed) input.pause.pressed = true;
        if (touch.retryPressed) input.retry.pressed = true;
        if (touch.artifactPressed) input.artifactTogglePressed = true;
        if (touch.mutePressed) input.muteTogglePressed = true;
        if (touch.fullscreenPressed) input.fullscreenTogglePressed = true;
        if (touch.anyTapBegan) input.splashSkipPressed = true;
        if (touch.zoneTap !== "") input.touchZoneTap = touch.zoneTap;
        if (touch.navUp) input.navUp = true;
        if (touch.navDown) input.navDown = true;
        if (touch.navLeft) input.navLeft = true;
        if (touch.navRight) input.navRight = true;
        if (touch.navConfirm) {
            input.navConfirm = true;
            input.craftConfirm = true;
        }
        if (touch.navBack) {
            input.navBack = true;
            input.craftCancel = true;
        }
        if (touch.bottleCanceled) {
            input.bottleCanceled = true;
            input.aim.held = false;
            input.aim.pressed = false;
            input.aim.released = false;
        }

        if (!suppressMouse && input.inputMode === "kbm" && input.aim.held && kbm.mouseRightPressed) {
            input.bottleCanceled = true;
            input.aim.held = false;
            input.aim.pressed = false;
            input.aim.released = false;
        }

        input.applyPickRoom(kbm.pick);
        input.frameInteractPressed = input.interact.pressed;

        if (touch.uiHeld || touch.uiPressed || touch.uiReleased || touch.uiInside) {
            input.uiX = touch.uiX;
            input.uiY = touch.uiY;
            input.uiDx = touch.uiDx;
            input.uiDy = touch.uiDy;
            input.uiInside = touch.uiInside;
            input.uiHeld = touch.uiHeld;
            input.uiPressed = touch.uiPressed;
            input.uiReleased = touch.uiReleased;
            input.uiRightPressed = false;
            if (touch.uiHeld || touch.uiPressed) {
                input.mdx = touch.uiDx;
                input.mdy = touch.uiDy;
                input.mx = touch.uiX;
                input.my = touch.uiY;
                input.inside = true;
            } else if (touch.hasAim) {
                input.mdx = touch.aimX - input.mx;
                input.mdy = touch.aimY - input.my;
                input.mx = touch.aimX;
                input.my = touch.aimY;
                input.inside = true;
            } else {
                input.mdx = 0;
                input.mdy = 0;
                input.inside = touch.uiInside;
            }
            return;
        }

        if (input.inputMode === "gamepad") {
            if (gp.hasAim) {
                input.mdx = gp.aimX - input.mx;
                input.mdy = gp.aimY - input.my;
                input.mx = gp.aimX;
                input.my = gp.aimY;
                input.inside = true;
            } else {
                input.mdx = 0;
                input.mdy = 0;
                input.inside = false;
            }
            if (!suppressMouse && kbm.mouseInsideStage && (kbm.mouseLeft || kbm.mouseLeftPressed || kbm.mouseLeftReleased)) {
                input.uiDx = kbm.mouseStageX - input.uiX;
                input.uiDy = kbm.mouseStageY - input.uiY;
                input.uiX = kbm.mouseStageX;
                input.uiY = kbm.mouseStageY;
                input.uiInside = true;
                input.uiHeld = kbm.mouseLeft;
                input.uiPressed = kbm.mouseLeftPressed;
                input.uiReleased = kbm.mouseLeftReleased;
                input.uiRightPressed = kbm.mouseRightPressed;
            } else {
                input.uiX = input.mx;
                input.uiY = input.my;
                input.uiDx = 0;
                input.uiDy = 0;
                input.uiInside = false;
                input.uiHeld = false;
                input.uiPressed = false;
                input.uiReleased = false;
                input.uiRightPressed = false;
            }
            return;
        }

        if (input.inputMode === "touch") {
            if (touch.hasAim) {
                input.mdx = touch.aimX - input.mx;
                input.mdy = touch.aimY - input.my;
                input.mx = touch.aimX;
                input.my = touch.aimY;
                input.inside = true;
            } else {
                input.mdx = 0;
                input.mdy = 0;
                input.inside = false;
            }
            if (!suppressMouse && kbm.mouseInsideStage && (kbm.mouseLeft || kbm.mouseLeftPressed || kbm.mouseLeftReleased)) {
                input.uiDx = kbm.mouseStageX - input.uiX;
                input.uiDy = kbm.mouseStageY - input.uiY;
                input.uiX = kbm.mouseStageX;
                input.uiY = kbm.mouseStageY;
                input.uiInside = true;
                input.uiHeld = kbm.mouseLeft;
                input.uiPressed = kbm.mouseLeftPressed;
                input.uiReleased = kbm.mouseLeftReleased;
                input.uiRightPressed = kbm.mouseRightPressed;
            } else {
                input.uiDx = 0;
                input.uiDy = 0;
                input.uiInside = false;
                input.uiHeld = false;
                input.uiPressed = false;
                input.uiReleased = false;
                input.uiRightPressed = false;
            }
            return;
        }

        input.mdx = kbm.mouseStageX - input.mx;
        input.mdy = kbm.mouseStageY - input.my;
        input.mx = kbm.mouseStageX;
        input.my = kbm.mouseStageY;
        input.inside = kbm.mouseInsideStage;

        input.uiX = kbm.mouseStageX;
        input.uiY = kbm.mouseStageY;
        input.uiDx = input.mdx;
        input.uiDy = input.mdy;
        input.uiInside = kbm.mouseInsideStage;
        input.uiHeld = !suppressMouse && kbm.mouseLeft && kbm.mouseInsideStage;
        input.uiPressed = !suppressMouse && kbm.mouseLeftPressed && kbm.mouseInsideStage;
        input.uiReleased = !suppressMouse && kbm.mouseLeftReleased;
        input.uiRightPressed = !suppressMouse && kbm.mouseRightPressed && kbm.mouseInsideStage;
    }
}

export const TARGET: TargetRuntime = {
    id: "web",
    supportsKbm: true,
    supportsTouch: true,
    supportsGamepad: true,
    supportsPortrait: true,
    defaultInputMode: "kbm",
    supportedModes: ["kbm", "touch", "gamepad"],
    modePrefOrder: MODE_PREF_ORDER,
    controlsGuideTabs: [
        { mode: "kbm", label: "键鼠" },
        { mode: "gamepad", label: "手柄" },
        { mode: "touch", label: "触屏" },
    ],

    getPlatformCaps(): PlatformCaps {
        const cfg = getReleaseConfig();
        return {
            kind: "web",
            target: "web",
            isDesktop: false,
            isMobile: false,
            isWeb: true,
            isStandaloneAndroidApk: false,
            canToggleFullscreen: true,
            canQuit: false,
            hasBackButton: false,
            supportsHaptics: false,
            needsAudioUnlock: true,
            isRelease: cfg !== undefined && cfg.isRelease !== undefined ? cfg.isRelease === true : true,
            defaultInputMode: "kbm",
        };
    },

    canToggleFullscreen(): boolean {
        return true;
    },

    canQuitApp(): boolean {
        return false;
    },

    isReleaseMode(): boolean {
        const cfg = getReleaseConfig();
        if (cfg !== undefined && cfg.isRelease !== undefined) {
            return cfg.isRelease === true;
        }
        return true;
    },

    computeStageViewport(fullW: number, fullH: number): StageViewport {
        return computeAdaptiveViewport(fullW, fullH);
    },

    triggerHaptics(seconds: number, enabled: boolean): void {
        triggerMobileHaptics(seconds, enabled);
    },

    keyTagFor(action: KeyActionId, mode: InputMode, layout: GamepadLayout): string {
        return keyTagWeb(action, mode, layout);
    },

    adaptWorldKeyTag(rawKeyTag: string, mode: InputMode, _layout: GamepadLayout): string {
        return adaptWorldKeyTagWeb(rawKeyTag, mode);
    },

    adaptHintSentence(text: string, mode: InputMode, layout: GamepadLayout): string {
        return adaptHintSentenceWeb(text, mode, layout);
    },

    controlsGuideRows(tab: InputMode): ControlsGuidePage {
        if (tab === "gamepad") return GUIDE_GAMEPAD;
        if (tab === "touch") return GUIDE_TOUCH;
        return GUIDE_KBM;
    },

    splashSkipHint(mode: InputMode, layout: GamepadLayout): string {
        if (mode === "touch") return "轻触跳过";
        if (mode === "gamepad") return keyTagWeb("confirm", "gamepad", layout) + " / START  跳过";
        return "ESC / SPACE  SKIP";
    },

    titleFooterHint(mode: InputMode, layout: GamepadLayout): string {
        if (mode === "gamepad") {
            return "左摇杆 / 十字键择项   ·   " + keyTagWeb("confirm", "gamepad", layout) + " 或点选启程";
        }
        if (mode === "touch") return "轻触择项启程   ·   支持键鼠与手柄";
        return "上下择项   ·   回车或点选启程";
    },

    chapterFooterHint(mode: InputMode, confirmTag: string): string {
        if (mode === "gamepad") return "摇杆/十字键选择   ·   " + confirmTag + " 或点选进入";
        if (mode === "touch") return "轻触驿站预览   ·   再点或轻触入此卷章";
        return "方向键选择   ·   回车或点击进入";
    },

    pauseFooterHint(mode: InputMode, layout: GamepadLayout): string {
        if (mode === "gamepad") {
            return keyTagWeb("back", "gamepad", layout) + " / START 续行   ·   " + keyTagWeb("confirm", "gamepad", layout) + " 确认";
        }
        if (mode === "touch") return "轻触确认   ·   点「继续游戏」续行";
        return "Esc 续行   ·   Enter 或点击确认";
    },

    settingsFooterHint(mode: InputMode, layout: GamepadLayout): string {
        if (mode === "gamepad") {
            return "左右或 " + keyTagWeb("confirm", "gamepad", layout) + " 切换   ·   " + keyTagWeb("back", "gamepad", layout) + " 返回暂停";
        }
        if (mode === "touch") return "轻触任意条目切换   ·   设置自动保存";
        return "←/→ 或回车/点击切换   ·   Esc 返回暂停";
    },

    controlsFooterRightHint(mode: InputMode): string {
        if (mode === "gamepad") return "LB / RB 或左右切换键位图";
        if (mode === "touch") return "轻触右上页签切图 · 暂歇菜单可调操控设置";
        return "←/→ 切页   ·   F11 / Alt+Enter 全屏";
    },

    epilogueFooterHint(mode: InputMode, layout: GamepadLayout): string {
        if (mode === "gamepad") {
            return keyTagWeb("confirm", "gamepad", layout) + " 确认   ·   " + keyTagWeb("back", "gamepad", layout) + " 返回标题";
        }
        if (mode === "touch") return "轻触任一入口继续";
        return "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题";
    },

    trialSubHint(mode: InputMode, ended: boolean, seed: number): string {
        if (mode === "gamepad") {
            return "种子 " + seed + (ended ? " · A 再开一局 · START 返回标题" : " · START 继续 · 长按BACK 重开 · Y 返回标题");
        }
        if (mode === "touch") {
            return "种子 " + seed + (ended ? " · 点下方按钮再开或返回标题" : " · 点下方按钮继续/重开/返回标题");
        }
        return "种子 " + seed + (ended ? " · R 再开一局 · Esc 返回标题" : " · Esc 继续 · R 重新开局 · E 返回标题");
    },

    settingsRows(): SettingsRowDef[] {
        return WEB_SETTINGS_ROWS;
    },

    settingsPauseLabel(settings: ControlSettings): string {
        return "操控设置 · " + modePrefLabelOf(settings.modePref);
    },

    settingsHeaderTitle(): string {
        return "操控与声音";
    },

    settingsHeaderSummary(activeMode: InputMode): string {
        return "当前模式：" + inputModeLabelOf(activeMode) + " · 操控与四通道音量实时生效";
    },

    settingsValueText(rowId: string, settings: ControlSettings, activeMode: InputMode): string {
        if (rowId === "modePref") {
            return settings.modePref === "auto"
                ? ("自动切换（" + inputModeLabelOf(activeMode) + "）")
                : ("锁定 · " + modePrefLabelOf(settings.modePref));
        }
        if (rowId === "aimAssist") return settings.aimAssist ? "开（触屏与手柄共用）" : "关";
        if (rowId === "gpLayout") return layoutLabelOf(settings.gamepadLayout);
        if (rowId === "crouchMode") return settings.crouchToggle ? "点按切换" : "持续按住";
        if (rowId === "touchOpacity") return opacityLabelOf(settings.touchOpacity);
        if (rowId === "touchScale") return scaleLabelOf(settings.touchScale);
        if (rowId === "haptics") return settings.haptics ? "开（仅移动端生效）" : "关";
        return volumeSettingText(rowId, settings);
    },

    applySettingsDelta(rowId: string, delta: number, settings: ControlSettings, input: Input): "none" | "audio" | "back" | "control" {
        if (rowId === "back") return "back";
        if (rowId === "modePref") {
            input.cycleModePref(delta);
            return "control";
        }
        if (rowId === "aimAssist") {
            settings.aimAssist = !settings.aimAssist;
            saveControlSettings(settings);
            return "control";
        }
        if (rowId === "gpLayout") {
            settings.gamepadLayout = settings.gamepadLayout === "xbox" ? "nintendo" : "xbox";
            input.gamepadLayout = settings.gamepadLayout;
            saveControlSettings(settings);
            return "control";
        }
        if (rowId === "crouchMode") {
            settings.crouchToggle = !settings.crouchToggle;
            saveControlSettings(settings);
            return "control";
        }
        if (rowId === "touchOpacity") {
            settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta);
            saveControlSettings(settings);
            return "control";
        }
        if (rowId === "touchScale") {
            settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta);
            saveControlSettings(settings);
            return "control";
        }
        if (rowId === "haptics") {
            settings.haptics = !settings.haptics;
            saveControlSettings(settings);
            return "control";
        }
        if (applyVolumeSetting(rowId, delta, settings)) return "audio";
        return "none";
    },

    createDriver(settings: ControlSettings): TargetInputDriver {
        return new WebInputDriver(settings);
    },
};
