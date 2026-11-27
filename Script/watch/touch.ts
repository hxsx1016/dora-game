/**
 * 《向西守望》统一多指触控路由内核（全应用唯一全屏 Touch 仲裁节点）。
 *
 * 设计原则：
 * 1. 全应用仅此一处挂载 Size(0, 0) 全屏触控节点，消灭 android / web / handheld 三套触控监听打架；
 * 2. 按 touch.id 维护每根手指的独占归属（modal / stick / btn / zone / aim_canvas），多指并发零串触；
 * 3. 完整理解 StageViewport：
 *    - 按钮、摇杆、矩形热区在叠加层逻辑坐标（overlayScale）内命中；
 *    - 舞台内瞄准与模态 UI 指针通过 viewToStage() 输出主舞台局部坐标，横屏/竖屏掌机台零误差；
 * 4. 精准区分真实手指与 SDL 合成假鼠标（touch.fromMouse），既彻底杜绝安卓左手摇杆误射，
 *    又允许安卓/掌机外接物理键鼠无缝切换，且支持竖屏/常显触控下用鼠标点按虚拟按钮便于调试评审；
 * 5. 手柄模式下可保持战斗虚拟按键隐藏，同时继续承接菜单、3×3 换弹盘、工台与本领卡的混合触屏操作。
 */

import { Node, Rect, Size, Touch, Vec2 } from "Dora";
import {
    AimTargetCandidate,
    pickSmartFireTarget,
    snapConeAim,
    snapPointAim,
} from "Script/watch/aim_assist";
import {
    ControlSettings,
    TOUCH_OPACITY_STEPS,
    TOUCH_SCALE_STEPS,
    defaultControlSettings,
    nextStepValue,
    saveControlSettings,
} from "Script/watch/controls_config";
import {
    StageViewport,
    computeStageViewport,
    triggerHaptics,
    viewToStage,
} from "Script/watch/platform";

export type TouchButtonId =
    | "interact"
    | "jump"
    | "cover"
    | "crouch"
    | "fire"
    | "bottle"
    | "artifact"
    | "pause"
    | "retry"
    | "mute"
    | "fullscreen"
    | "nav_up"
    | "nav_down"
    | "nav_left"
    | "nav_right"
    | "nav_confirm"
    | "nav_back";

export type TouchAccent = "cyan" | "amber" | "rouge" | "emerald" | "silk";

export interface TouchButtonSpec {
    id: TouchButtonId;
    /** 叠加层逻辑空间中心坐标（view / overlayScale） */
    x: number;
    y: number;
    /** 圆形命中视觉半径（rect 未填时生效） */
    r: number;
    label: string;
    subLabel?: string;
    accent: TouchAccent;
    active: boolean;
    highlighted: boolean;
    progress: number;
    dimmed: boolean;
    shape?: "circle" | "pill";
    toggle?: boolean;
    /** 可选矩形命中区（用于顶栏胶囊钮或姿态切换胶囊） */
    rect?: Rect.Type;
}

export interface TouchRectZone {
    id: string;
    /** 叠加层逻辑空间矩形热区（view / overlayScale） */
    rect: Rect.Type;
}

export interface TouchFrameContext {
    viewport: StageViewport;
    /** 叠加层逻辑坐标缩放：横屏等于 viewport.uiScale，竖屏等于 1.0 */
    overlayScale: number;
    /** 虚拟触控界面当前是否显示并可交互（横屏触屏态或竖屏掌机态为 true） */
    overlayActive: boolean;
    /** 自动模式下是否允许空白画面首次触碰直接响应摇杆/开火并切入触屏模式 */
    allowAutoGameplayTouch: boolean;
    /** 是否允许鼠标事件点按虚拟按钮与竖屏下掌机摇杆（竖屏或手动锁定触屏模式时为 true） */
    allowMouseOnOverlay: boolean;
    /** 标题/选章/操作说明/暂停/换弹盘/工台/试炼弹窗等模态界面 */
    modal: boolean;
    /** 是否处于可操作局内态（mode === 1 正式或 mode === 2 护送试炼） */
    gameplayActive: boolean;
    /** 电影过场接管期间隐藏战斗按钮，仅保留顶栏暂歇与北塔尾声轻触 */
    cutsceneBlocking: boolean;
    childMode: boolean;
    /** 是否允许上下纵深移动（周戍全房 + 序章逃柜） */
    allowDepth: boolean;
    /** 是否允许右屏空白直点/摇杆开火 */
    canShoot: boolean;
    /** 是否处于空村持瓶可投状态 */
    canBottleAim: boolean;
    /** 靠近板车车把或正在握车把（未落窝） */
    cartNearby: boolean;
    /** 后端当前是否正处于 gripping 态 */
    cartGripping: boolean;
    /** C2 粮棚后端用点按 E 切换握柄；检查站/城外用持续按住 E */
    cartUsesToggle: boolean;
    /** 靠近掩体 */
    coverNear: boolean;
    /** 正在翻滚 */
    playerRolling: boolean;
    /** 处于低拱强制低姿区 */
    inLowArch: boolean;
    /** 北塔尾声可点按重开 */
    inTowerEnd: boolean;
    /** 主角朝向（1 右 / -1 左） */
    playerFacing: number;
    /** 主角枪口/身体在主舞台局部空间的锚点 */
    playerScreenX: number;
    playerScreenY: number;
    /** 当前房内可见活体敌兵列表（主舞台局部坐标） */
    enemyTargets: AimTargetCandidate[];
    /** 摇杆热区与基准几何（叠加层逻辑坐标） */
    stickZoneMaxX: number;
    stickZoneMaxY: number;
    stickDefaultX: number;
    stickDefaultY: number;
    stickMaxR: number;
    stickFixedOrigin: boolean;
    buttons: TouchButtonSpec[];
    rectZones: TouchRectZone[];
    bottleCancelCenter: { x: number; y: number; r: number };
}

export interface TouchStickVisual {
    active: boolean;
    originX: number;
    originY: number;
    knobX: number;
    knobY: number;
    radius: number;
    slowZone: boolean;
    allowDepth: boolean;
}

export interface TouchFireStickVisual {
    active: boolean;
    dragging: boolean;
    originX: number;
    originY: number;
    knobX: number;
    knobY: number;
    radius: number;
}

export interface TouchBottleDragVisual {
    active: boolean;
    cancelHover: boolean;
    cancelX: number;
    cancelY: number;
    cancelR: number;
    fingerOvX: number;
    fingerOvY: number;
}

export interface TouchSnapshot {
    /** 本帧是否收到真实手指（!fromMouse）触控事件 */
    hadRealTouch: boolean;
    /** 真实手指是否作用于局内虚拟操控/战场（用于自动模式切入 touch） */
    hadGameplayTouch: boolean;
    /** 真实手指是否作用于菜单/换弹盘/工台/本领卡等 UI */
    hadUiTouch: boolean;
    /** 本帧是否有任意真实手指按下（供 Splash 跳过与 Web 音频解锁） */
    anyTapBegan: boolean;
    /** 当前或近 250ms 内有真实手指活动：屏蔽 SDL 合成单指假鼠标 */
    suppressSyntheticMouse: boolean;
    /** 鼠标点击已被虚拟覆盖层消费，防止同时穿透触发舞台原生左键射击 */
    mouseConsumedByOverlay: boolean;
    moveX: number;
    moveY: number;
    jumpHeld: boolean;
    jumpPressed: boolean;
    crouchHeld: boolean;
    coverHeld: boolean;
    interactHeld: boolean;
    interactPressed: boolean;
    aimHeld: boolean;
    fireHeld: boolean;
    firePressed: boolean;
    pausePressed: boolean;
    retryPressed: boolean;
    artifactPressed: boolean;
    mutePressed: boolean;
    fullscreenPressed: boolean;
    bottleCanceled: boolean;
    navUp: boolean;
    navDown: boolean;
    navLeft: boolean;
    navRight: boolean;
    navConfirm: boolean;
    navBack: boolean;
    hasAim: boolean;
    /** 主舞台局部瞄准坐标（左下原点） */
    aimX: number;
    aimY: number;
    /** 模态 UI 单指指针（主舞台局部坐标，左下原点） */
    uiHeld: boolean;
    uiPressed: boolean;
    uiReleased: boolean;
    uiInside: boolean;
    uiX: number;
    uiY: number;
    uiDx: number;
    uiDy: number;
    zoneTap: string;
}

type FingerKind = "modal" | "stick" | "btn" | "zone" | "aim_canvas";

interface FingerState {
    id: number;
    fromMouse: boolean;
    kind: FingerKind;
    btnId?: TouchButtonId;
    zoneId?: string;
    startViewX: number;
    startViewY: number;
    curViewX: number;
    curViewY: number;
    startOvX: number;
    startOvY: number;
    curOvX: number;
    curOvY: number;
    movedDistOv: number;
    firedOnDrag?: boolean;
}

const STICK_DEAD_RATIO = 0.18;
const FIRE_STICK_DRAG_THRESHOLD_OV = 16;
const FIRE_STICK_MAX_R_OV = 54;
const BOTTLE_AIM_Y_OFFSET_UI = 52;
const SYNTHETIC_MOUSE_COOLDOWN_SEC = 0.25;

function clamp(v: number, lo: number, hi: number): number {
    return v < lo ? lo : (v > hi ? hi : v);
}

function hypot(dx: number, dy: number): number {
    return Math.sqrt(dx * dx + dy * dy);
}

function isInstantUiButton(id: TouchButtonId): boolean {
    return id === "pause"
        || id === "retry"
        || id === "mute"
        || id === "fullscreen"
        || id === "nav_up"
        || id === "nav_down"
        || id === "nav_left"
        || id === "nav_right"
        || id === "nav_confirm"
        || id === "nav_back";
}

export class TouchRouter {
    settings: ControlSettings;
    private listenerNode: Node.Type | undefined;
    private fingers: Record<number, FingerState> = {};

    private ctx: TouchFrameContext = {
        viewport: computeStageViewport(1280, 720),
        overlayScale: 1,
        overlayActive: false,
        allowAutoGameplayTouch: true,
        allowMouseOnOverlay: false,
        modal: true,
        gameplayActive: false,
        cutsceneBlocking: false,
        childMode: false,
        allowDepth: false,
        canShoot: false,
        canBottleAim: false,
        cartNearby: false,
        cartGripping: false,
        cartUsesToggle: false,
        coverNear: false,
        playerRolling: false,
        inLowArch: false,
        inTowerEnd: false,
        playerFacing: 1,
        playerScreenX: 640,
        playerScreenY: 240,
        enemyTargets: [],
        stickZoneMaxX: 560,
        stickZoneMaxY: 600,
        stickDefaultX: 148,
        stickDefaultY: 144,
        stickMaxR: 64,
        stickFixedOrigin: false,
        buttons: [],
        rectZones: [],
        bottleCancelCenter: { x: 1120, y: 120, r: 44 },
    };

    // 摇杆状态（叠加层逻辑坐标）
    private stickFingerId = -1;
    private stickOriginX = 148;
    private stickOriginY = 144;
    private stickKnobX = 148;
    private stickKnobY = 144;
    private stickMoveX = 0;
    private stickMoveY = 0;
    private stickSlow = false;

    // 触屏开关态与推车锁定态
    coverToggled = false;
    crouchToggled = false;
    slowToggled = false;
    cartGripLatched = false;
    private cartGripSeenActive = false;
    private coverNearSeen = false;

    // 按钮按住状态
    private interactFingerId = -1;
    private jumpFingerId = -1;
    private fireFingerId = -1;
    private fireStickDragging = false;
    private fireOriginX = 1110;
    private fireOriginY = 154;
    private fireKnobX = 1110;
    private fireKnobY = 154;
    private bottleFingerId = -1;
    private bottleOriginOvX = 0;
    private bottleOriginOvY = 0;
    private bottleCancelHover = false;
    private bottleFingerOvX = 0;
    private bottleFingerOvY = 0;
    private aimCanvasFingerId = -1;

    // 模态 UI 指针状态（主舞台局部坐标）
    private modalFingerId = -1;
    private uiX = 0;
    private uiY = 0;
    private uiPrevX = 0;
    private uiPrevY = 0;
    private uiHeld = false;
    private uiPressedQueue = false;
    private uiReleasedQueue = false;

    // 瞄准坐标（主舞台局部坐标）
    private hasAim = false;
    private aimX = 640;
    private aimY = 300;

    // 单帧边沿队列
    private qHadRealTouch = false;
    private qHadGameplayTouch = false;
    private qHadUiTouch = false;
    private qAnyTapBegan = false;
    private qMouseConsumed = false;
    private qJumpPressed = false;
    private qInteractPressed = false;
    private qFirePressed = false;
    private qPausePressed = false;
    private qRetryPressed = false;
    private qArtifactPressed = false;
    private qMutePressed = false;
    private qFullscreenPressed = false;
    private qBottleCanceled = false;
    private qNavUp = false;
    private qNavDown = false;
    private qNavLeft = false;
    private qNavRight = false;
    private qNavConfirm = false;
    private qNavBack = false;
    private qZoneTap = "";

    private clockSec = 10;
    private lastRealTouchClock = -10;

    constructor(sharedSettings?: ControlSettings) {
        this.settings = sharedSettings !== undefined ? sharedSettings : defaultControlSettings();
    }

    attach(parent: Node.Type): void {
        if (this.listenerNode !== undefined) {
            return;
        }
        const n = Node();
        n.size = Size(0, 0);
        n.position = Vec2(0, 0);
        n.order = 120;
        n.swallowTouches = false;
        n.touchEnabled = true;
        n.onTapBegan((touch: Touch.Type) => {
            const loc = touch.viewLocation;
            this.handleTouchBegan(touch.id, loc.x, loc.y, touch.fromMouse);
        });
        n.onTapMoved((touch: Touch.Type) => {
            const loc = touch.viewLocation;
            this.handleTouchMoved(touch.id, loc.x, loc.y, touch.fromMouse);
        });
        n.onTapEnded((touch: Touch.Type) => {
            const loc = touch.viewLocation;
            this.handleTouchEnded(touch.id, loc.x, loc.y, touch.fromMouse);
        });
        n.addTo(parent);
        this.listenerNode = n;
    }

    /** 供自动化测试与模拟调试直接注入触控事件（走与真机完全相同的状态机）。 */
    injectTouch(
        phase: "began" | "moved" | "ended",
        id: number,
        viewX: number,
        viewY: number,
        fromMouse: boolean = false,
    ): void {
        if (phase === "began") {
            this.handleTouchBegan(id, viewX, viewY, fromMouse);
        } else if (phase === "moved") {
            this.handleTouchMoved(id, viewX, viewY, fromMouse);
        } else {
            this.handleTouchEnded(id, viewX, viewY, fromMouse);
        }
    }

    cycleOpacity(): number {
        this.settings.touchOpacity = nextStepValue(this.settings.touchOpacity, TOUCH_OPACITY_STEPS, 1);
        saveControlSettings(this.settings);
        return this.settings.touchOpacity;
    }

    cycleScale(): number {
        this.settings.touchScale = nextStepValue(this.settings.touchScale, TOUCH_SCALE_STEPS, 1);
        saveControlSettings(this.settings);
        return this.settings.touchScale;
    }

    toggleAimAssist(): boolean {
        this.settings.aimAssist = !this.settings.aimAssist;
        saveControlSettings(this.settings);
        return this.settings.aimAssist;
    }

    toggleHaptics(): boolean {
        this.settings.haptics = !this.settings.haptics;
        saveControlSettings(this.settings);
        if (this.settings.haptics) {
            this.vibrate(0.018);
        }
        return this.settings.haptics;
    }

    vibrate(seconds: number): void {
        triggerHaptics(seconds, this.settings.haptics);
    }

    /** 是否存在正在按下或刚刚抬起的真实手指（用于动态屏蔽 SDL 合成鼠标，不误伤外接物理鼠标）。 */
    isSuppressingSyntheticMouse(): boolean {
        if (this.hasActiveRealFinger()) {
            return true;
        }
        return (this.clockSec - this.lastRealTouchClock) < SYNTHETIC_MOUSE_COOLDOWN_SEC;
    }

    private hasActiveRealFinger(): boolean {
        for (const k in this.fingers) {
            const f = this.fingers[k];
            if (f !== undefined && !f.fromMouse) {
                return true;
            }
        }
        return false;
    }

    private hasActiveMouseOverlayFinger(): boolean {
        for (const k in this.fingers) {
            const f = this.fingers[k];
            if (f !== undefined && f.fromMouse) {
                return true;
            }
        }
        return false;
    }

    setFrameContext(next: TouchFrameContext, dt: number): void {
        this.clockSec += Math.min(0.05, Math.max(0, dt));
        const wasModal = this.ctx.modal;
        const wasCutscene = this.ctx.cutsceneBlocking;
        this.ctx = next;

        if ((!wasModal && next.modal) || (!wasCutscene && next.cutsceneBlocking)) {
            this.releaseGameplayFingers();
        }

        if (next.playerRolling) {
            this.coverToggled = false;
        }
        if (this.coverToggled) {
            if (next.coverNear) {
                this.coverNearSeen = true;
            } else if (this.coverNearSeen) {
                this.coverToggled = false;
                this.coverNearSeen = false;
            }
        } else {
            this.coverNearSeen = false;
        }

        if (this.cartGripLatched) {
            if (next.cartGripping) {
                this.cartGripSeenActive = true;
            } else if (!next.cartNearby || this.cartGripSeenActive) {
                this.cartGripLatched = false;
                this.cartGripSeenActive = false;
            }
        } else {
            this.cartGripSeenActive = false;
        }

        if (!next.canBottleAim && this.bottleFingerId >= 0) {
            this.releaseFingerById(this.bottleFingerId);
        }

        if (next.childMode) {
            this.coverToggled = false;
        } else {
            this.crouchToggled = false;
            this.slowToggled = false;
        }
    }

    releaseAll(keepToggles: boolean = false): void {
        this.fingers = {};
        this.stickFingerId = -1;
        this.stickMoveX = 0;
        this.stickMoveY = 0;
        this.stickSlow = false;
        this.interactFingerId = -1;
        this.jumpFingerId = -1;
        this.fireFingerId = -1;
        this.fireStickDragging = false;
        this.bottleFingerId = -1;
        this.bottleCancelHover = false;
        this.aimCanvasFingerId = -1;
        this.modalFingerId = -1;
        this.uiHeld = false;
        this.uiPressedQueue = false;
        this.uiReleasedQueue = false;
        if (!keepToggles) {
            this.coverToggled = false;
            this.crouchToggled = false;
            this.slowToggled = false;
            this.cartGripLatched = false;
            this.cartGripSeenActive = false;
            this.coverNearSeen = false;
            this.hasAim = false;
        }
    }

    clearRoomStates(): void {
        this.releaseAll(false);
        this.qJumpPressed = false;
        this.qInteractPressed = false;
        this.qFirePressed = false;
        this.qPausePressed = false;
        this.qRetryPressed = false;
        this.qArtifactPressed = false;
        this.qMutePressed = false;
        this.qFullscreenPressed = false;
        this.qBottleCanceled = false;
        this.qNavUp = false;
        this.qNavDown = false;
        this.qNavLeft = false;
        this.qNavRight = false;
        this.qNavConfirm = false;
        this.qNavBack = false;
        this.qZoneTap = "";
    }

    private releaseGameplayFingers(): void {
        const ids: number[] = [];
        for (const k in this.fingers) {
            const f = this.fingers[k];
            if (f !== undefined && f.kind !== "modal") {
                ids.push(f.id);
            }
        }
        let i = 0;
        for (i = 0; i < ids.length; i++) {
            this.releaseFingerById(ids[i]);
        }
    }

    private releaseFingerById(id: number): void {
        const f = this.fingers[id];
        if (f === undefined) return;
        delete this.fingers[id];
        if (this.stickFingerId === id) {
            this.stickFingerId = -1;
            this.stickMoveX = 0;
            this.stickMoveY = 0;
            this.stickSlow = false;
        }
        if (this.interactFingerId === id) this.interactFingerId = -1;
        if (this.jumpFingerId === id) this.jumpFingerId = -1;
        if (this.fireFingerId === id) {
            this.fireFingerId = -1;
            this.fireStickDragging = false;
        }
        if (this.bottleFingerId === id) {
            this.bottleFingerId = -1;
            this.bottleCancelHover = false;
        }
        if (this.aimCanvasFingerId === id) this.aimCanvasFingerId = -1;
        if (this.modalFingerId === id) {
            this.modalFingerId = -1;
            this.uiHeld = false;
        }
    }

    getStickVisual(): TouchStickVisual {
        const r = this.ctx.stickMaxR;
        if (this.stickFingerId >= 0) {
            return {
                active: true,
                originX: this.stickOriginX,
                originY: this.stickOriginY,
                knobX: this.stickKnobX,
                knobY: this.stickKnobY,
                radius: r,
                slowZone: this.stickSlow,
                allowDepth: this.ctx.allowDepth,
            };
        }
        return {
            active: false,
            originX: this.ctx.stickDefaultX,
            originY: this.ctx.stickDefaultY,
            knobX: this.ctx.stickDefaultX,
            knobY: this.ctx.stickDefaultY,
            radius: r,
            slowZone: false,
            allowDepth: this.ctx.allowDepth,
        };
    }

    getFireStickVisual(): TouchFireStickVisual {
        return {
            active: this.fireFingerId >= 0,
            dragging: this.fireStickDragging,
            originX: this.fireOriginX,
            originY: this.fireOriginY,
            knobX: this.fireKnobX,
            knobY: this.fireKnobY,
            radius: FIRE_STICK_MAX_R_OV * this.settings.touchScale,
        };
    }

    getBottleDragVisual(): TouchBottleDragVisual {
        return {
            active: this.bottleFingerId >= 0,
            cancelHover: this.bottleCancelHover,
            cancelX: this.ctx.bottleCancelCenter.x,
            cancelY: this.ctx.bottleCancelCenter.y,
            cancelR: this.ctx.bottleCancelCenter.r,
            fingerOvX: this.bottleFingerOvX,
            fingerOvY: this.bottleFingerOvY,
        };
    }

    isButtonHeld(id: TouchButtonId): boolean {
        if (id === "interact") return this.interactFingerId >= 0 || this.cartGripLatched;
        if (id === "jump") return this.jumpFingerId >= 0;
        if (id === "fire") return this.fireFingerId >= 0;
        if (id === "bottle") return this.bottleFingerId >= 0;
        if (id === "cover") return this.ctx.childMode ? this.slowToggled : this.coverToggled;
        if (id === "crouch") return this.crouchToggled;
        return false;
    }

    consumeSnapshot(): TouchSnapshot {
        const uiDx = this.uiX - this.uiPrevX;
        const uiDy = this.uiY - this.uiPrevY;
        this.uiPrevX = this.uiX;
        this.uiPrevY = this.uiY;

        const cartHold = this.cartGripLatched && !this.ctx.cartUsesToggle;
        const suppressSyntheticMouse = this.isSuppressingSyntheticMouse();
        const mouseConsumed = this.qMouseConsumed || this.hasActiveMouseOverlayFinger();

        const snap: TouchSnapshot = {
            hadRealTouch: this.qHadRealTouch,
            hadGameplayTouch: this.qHadGameplayTouch,
            hadUiTouch: this.qHadUiTouch,
            anyTapBegan: this.qAnyTapBegan,
            suppressSyntheticMouse,
            mouseConsumedByOverlay: mouseConsumed,
            moveX: this.stickMoveX,
            moveY: this.stickMoveY,
            jumpHeld: this.jumpFingerId >= 0,
            jumpPressed: this.qJumpPressed,
            crouchHeld: this.crouchToggled,
            coverHeld: this.ctx.childMode ? (this.slowToggled || this.stickSlow) : this.coverToggled,
            interactHeld: this.interactFingerId >= 0 || cartHold,
            interactPressed: this.qInteractPressed,
            aimHeld: this.bottleFingerId >= 0,
            fireHeld: this.fireFingerId >= 0 || this.aimCanvasFingerId >= 0,
            firePressed: this.qFirePressed,
            pausePressed: this.qPausePressed,
            retryPressed: this.qRetryPressed,
            artifactPressed: this.qArtifactPressed,
            mutePressed: this.qMutePressed,
            fullscreenPressed: this.qFullscreenPressed,
            bottleCanceled: this.qBottleCanceled,
            navUp: this.qNavUp,
            navDown: this.qNavDown,
            navLeft: this.qNavLeft,
            navRight: this.qNavRight,
            navConfirm: this.qNavConfirm,
            navBack: this.qNavBack,
            hasAim: this.hasAim,
            aimX: this.aimX,
            aimY: this.aimY,
            uiHeld: this.uiHeld,
            uiPressed: this.uiPressedQueue,
            uiReleased: this.uiReleasedQueue,
            uiInside: this.uiHeld || this.uiPressedQueue || this.uiReleasedQueue,
            uiX: this.uiX,
            uiY: this.uiY,
            uiDx,
            uiDy,
            zoneTap: this.qZoneTap,
        };

        this.qHadRealTouch = false;
        this.qHadGameplayTouch = false;
        this.qHadUiTouch = false;
        this.qAnyTapBegan = false;
        this.qMouseConsumed = false;
        this.qJumpPressed = false;
        this.qInteractPressed = false;
        this.qFirePressed = false;
        this.qPausePressed = false;
        this.qRetryPressed = false;
        this.qArtifactPressed = false;
        this.qMutePressed = false;
        this.qFullscreenPressed = false;
        this.qBottleCanceled = false;
        this.qNavUp = false;
        this.qNavDown = false;
        this.qNavLeft = false;
        this.qNavRight = false;
        this.qNavConfirm = false;
        this.qNavBack = false;
        this.qZoneTap = "";
        this.uiPressedQueue = false;
        this.uiReleasedQueue = false;
        return snap;
    }

    private toOverlay(viewX: number, viewY: number): { x: number; y: number } {
        const sc = Math.max(0.25, this.ctx.overlayScale);
        return { x: viewX / sc, y: viewY / sc };
    }

    private hitTestRectZones(ovX: number, ovY: number): TouchRectZone | undefined {
        const pt = Vec2(ovX, ovY);
        let i = 0;
        for (i = 0; i < this.ctx.rectZones.length; i++) {
            const z = this.ctx.rectZones[i];
            if (z.rect.containsPoint(pt)) {
                return z;
            }
        }
        return undefined;
    }

    private hitTestButtons(ovX: number, ovY: number): TouchButtonSpec | undefined {
        const pt = Vec2(ovX, ovY);
        let best: TouchButtonSpec | undefined;
        let bestDist = 1e9;
        let i = 0;
        for (i = 0; i < this.ctx.buttons.length; i++) {
            const b = this.ctx.buttons[i];
            if (b.rect !== undefined) {
                if (b.rect.containsPoint(pt)) {
                    return b;
                }
                continue;
            }
            const hitR = b.r * 1.22;
            const d = hypot(ovX - b.x, ovY - b.y);
            if (d <= hitR && d < bestDist) {
                bestDist = d;
                best = b;
            }
        }
        return best;
    }

    private handleTouchBegan(id: number, viewX: number, viewY: number, fromMouse: boolean): void {
        const vp = this.ctx.viewport;
        const ov = this.toOverlay(viewX, viewY);

        // 1. 鼠标事件：仅在竖屏或手动触屏模式下允许点击虚拟覆盖层按钮与竖屏下掌机摇杆，舞台交由原生鼠标处理
        if (fromMouse) {
            if (!this.ctx.allowMouseOnOverlay || !this.ctx.overlayActive) {
                return;
            }
            const hitBtn = this.hitTestButtons(ov.x, ov.y);
            if (hitBtn !== undefined) {
                this.qMouseConsumed = true;
                this.fingers[id] = {
                    id,
                    fromMouse: true,
                    kind: "btn",
                    btnId: hitBtn.id,
                    startViewX: viewX,
                    startViewY: viewY,
                    curViewX: viewX,
                    curViewY: viewY,
                    startOvX: ov.x,
                    startOvY: ov.y,
                    curOvX: ov.x,
                    curOvY: ov.y,
                    movedDistOv: 0,
                };
                this.onButtonPressed(hitBtn, id, viewX, viewY, ov.x, ov.y, true);
                return;
            }
            if (vp.isPortrait && this.ctx.gameplayActive && !this.ctx.modal && !this.ctx.cutsceneBlocking
                && viewY < vp.deckH && ov.x <= this.ctx.stickZoneMaxX && this.stickFingerId < 0) {
                this.qMouseConsumed = true;
                this.startStick(id, viewX, viewY, ov.x, ov.y, true);
            }
            return;
        }

        // 2. 真实手指触控：记录保护窗屏蔽 SDL 假鼠标
        this.lastRealTouchClock = this.clockSec;
        this.qHadRealTouch = true;
        this.qAnyTapBegan = true;

        // 2a. 虚拟覆盖层已激活时，优先命中按钮（含顶栏快捷钮、竖屏菜单导航键与局内动作按钮）
        if (this.ctx.overlayActive) {
            const btn = this.hitTestButtons(ov.x, ov.y);
            if (btn !== undefined) {
                if (isInstantUiButton(btn.id)) {
                    this.qHadUiTouch = true;
                } else {
                    this.qHadGameplayTouch = true;
                }
                this.fingers[id] = {
                    id,
                    fromMouse: false,
                    kind: "btn",
                    btnId: btn.id,
                    startViewX: viewX,
                    startViewY: viewY,
                    curViewX: viewX,
                    curViewY: viewY,
                    startOvX: ov.x,
                    startOvY: ov.y,
                    curOvX: ov.x,
                    curOvY: ov.y,
                    movedDistOv: 0,
                };
                this.onButtonPressed(btn, id, viewX, viewY, ov.x, ov.y, false);
                return;
            }
        }

        const stage = viewToStage(viewX, viewY, vp);

        // 2b. 模态界面（标题 / 选章 / 说明 / 暂停 / 3×3 换弹盘 / 工台）：统一单指舞台 UI 指针
        if (this.ctx.modal || !this.ctx.gameplayActive) {
            this.qHadUiTouch = true;
            if (this.modalFingerId < 0 && (!vp.isPortrait || stage.inside)) {
                this.modalFingerId = id;
                this.uiX = stage.x;
                this.uiY = stage.y;
                this.uiPrevX = stage.x;
                this.uiPrevY = stage.y;
                this.uiHeld = true;
                this.uiPressedQueue = true;
                this.fingers[id] = {
                    id,
                    fromMouse: false,
                    kind: "modal",
                    startViewX: viewX,
                    startViewY: viewY,
                    curViewX: viewX,
                    curViewY: viewY,
                    startOvX: ov.x,
                    startOvY: ov.y,
                    curOvX: ov.x,
                    curOvY: ov.y,
                    movedDistOv: 0,
                };
            }
            return;
        }

        // 2c. 顶部与特殊矩形热区（本领卡 / 世界交互气泡 / 试炼弹窗钮；手柄混用触屏时同样直接可用）
        const zone = this.hitTestRectZones(ov.x, ov.y);
        if (zone !== undefined) {
            this.qHadUiTouch = true;
            this.fingers[id] = {
                id,
                fromMouse: false,
                kind: "zone",
                zoneId: zone.id,
                startViewX: viewX,
                startViewY: viewY,
                curViewX: viewX,
                curViewY: viewY,
                startOvX: ov.x,
                startOvY: ov.y,
                curOvX: ov.x,
                curOvY: ov.y,
                movedDistOv: 0,
            };
            if (zone.id === "pause") {
                this.qPausePressed = true;
                this.vibrate(0.015);
            } else if (zone.id === "retry") {
                this.qRetryPressed = true;
                this.vibrate(0.015);
            } else if (zone.id === "worldPrompt") {
                this.triggerInteractAction(id);
            } else {
                this.qZoneTap = zone.id;
                this.vibrate(0.015);
            }
            return;
        }

        // 2d. 过场阻塞期间：仅响应北塔尾声轻触再启程
        if (this.ctx.cutsceneBlocking) {
            this.qHadUiTouch = true;
            if (this.ctx.inTowerEnd) {
                this.qInteractPressed = true;
                this.vibrate(0.015);
            }
            return;
        }

        // 2e. 局内有效触屏（摇杆与直点射击）
        if (!this.ctx.overlayActive && !this.ctx.allowAutoGameplayTouch) {
            // 手动锁定键鼠/手柄模式时，不触发虚拟摇杆与触屏射击，仅保留上方模态/本领直点
            return;
        }
        this.qHadGameplayTouch = true;

        // 左手摇杆区（竖屏在下掌机左半区，横屏在左半屏动态浮现）
        const inStickZone = vp.isPortrait
            ? (viewY < vp.deckH && ov.x <= this.ctx.stickZoneMaxX)
            : (ov.x <= this.ctx.stickZoneMaxX && ov.y <= this.ctx.stickZoneMaxY);
        if (this.stickFingerId < 0 && inStickZone) {
            this.startStick(id, viewX, viewY, ov.x, ov.y, false);
            return;
        }

        // 右半/主舞台直接点射瞄准（周戍战斗态）
        const ovH = vp.fullH / Math.max(0.25, this.ctx.overlayScale);
        const allowStageShoot = stage.inside && (vp.isPortrait || ov.y <= ovH - 84);
        if (this.ctx.canShoot && this.aimCanvasFingerId < 0 && allowStageShoot) {
            this.aimCanvasFingerId = id;
            const assisted = snapPointAim(
                stage.x,
                stage.y,
                this.ctx.enemyTargets,
                44 * vp.uiScale,
                this.settings.aimAssist,
            );
            this.aimX = assisted.x;
            this.aimY = assisted.y;
            this.hasAim = true;
            this.qFirePressed = true;
            this.vibrate(0.016);
            this.fingers[id] = {
                id,
                fromMouse: false,
                kind: "aim_canvas",
                startViewX: viewX,
                startViewY: viewY,
                curViewX: viewX,
                curViewY: viewY,
                startOvX: ov.x,
                startOvY: ov.y,
                curOvX: ov.x,
                curOvY: ov.y,
                movedDistOv: 0,
            };
        }
    }

    private startStick(
        id: number,
        viewX: number,
        viewY: number,
        ovX: number,
        ovY: number,
        fromMouse: boolean,
    ): void {
        const vp = this.ctx.viewport;
        const r = this.ctx.stickMaxR;
        let ox = this.ctx.stickDefaultX;
        let oy = this.ctx.stickDefaultY;
        if (!this.ctx.stickFixedOrigin) {
            const safeL = vp.safe.left / Math.max(0.25, this.ctx.overlayScale);
            const safeB = vp.safe.bottom / Math.max(0.25, this.ctx.overlayScale);
            ox = clamp(ovX, safeL + r + 14, Math.max(safeL + r + 14, this.ctx.stickZoneMaxX - 18));
            oy = clamp(ovY, safeB + r + 14, Math.max(safeB + r + 14, this.ctx.stickZoneMaxY - r * 0.6));
        }
        this.stickFingerId = id;
        this.stickOriginX = ox;
        this.stickOriginY = oy;
        this.stickKnobX = ovX;
        this.stickKnobY = ovY;
        this.fingers[id] = {
            id,
            fromMouse,
            kind: "stick",
            startViewX: viewX,
            startViewY: viewY,
            curViewX: viewX,
            curViewY: viewY,
            startOvX: ovX,
            startOvY: ovY,
            curOvX: ovX,
            curOvY: ovY,
            movedDistOv: 0,
        };
        this.updateStickFromOverlay(ovX, ovY);
    }

    private triggerInteractAction(id: number): void {
        if (this.ctx.cartNearby) {
            if (this.cartGripLatched || this.ctx.cartGripping) {
                this.cartGripLatched = false;
                this.cartGripSeenActive = false;
                if (this.ctx.cartUsesToggle) {
                    this.qInteractPressed = true;
                }
            } else {
                this.cartGripLatched = true;
                this.cartGripSeenActive = false;
                this.qInteractPressed = true;
            }
            this.vibrate(0.018);
            return;
        }
        this.interactFingerId = id;
        this.qInteractPressed = true;
        this.vibrate(0.015);
    }

    private onButtonPressed(
        btn: TouchButtonSpec,
        id: number,
        _viewX: number,
        _viewY: number,
        ovX: number,
        ovY: number,
        fromMouse: boolean,
    ): void {
        const vp = this.ctx.viewport;
        if (btn.id === "interact") {
            this.triggerInteractAction(id);
        } else if (btn.id === "jump") {
            if (this.ctx.childMode && this.crouchToggled && !this.ctx.inLowArch) {
                this.crouchToggled = false;
            }
            this.jumpFingerId = id;
            this.qJumpPressed = true;
            if (!fromMouse) this.vibrate(0.014);
        } else if (btn.id === "cover") {
            if (this.ctx.childMode) {
                this.slowToggled = !this.slowToggled;
            } else {
                this.coverToggled = !this.coverToggled;
                this.coverNearSeen = this.ctx.coverNear;
            }
            if (!fromMouse) this.vibrate(0.012);
        } else if (btn.id === "crouch") {
            this.crouchToggled = !this.crouchToggled;
            if (!fromMouse) this.vibrate(0.012);
        } else if (btn.id === "artifact") {
            this.qArtifactPressed = true;
            if (!fromMouse) this.vibrate(0.02);
        } else if (btn.id === "pause") {
            this.qPausePressed = true;
            if (!fromMouse) this.vibrate(0.014);
        } else if (btn.id === "retry") {
            this.qRetryPressed = true;
            if (!fromMouse) this.vibrate(0.016);
        } else if (btn.id === "mute") {
            this.qMutePressed = true;
        } else if (btn.id === "fullscreen") {
            this.qFullscreenPressed = true;
        } else if (btn.id === "nav_up") {
            this.qNavUp = true;
        } else if (btn.id === "nav_down") {
            this.qNavDown = true;
        } else if (btn.id === "nav_left") {
            this.qNavLeft = true;
        } else if (btn.id === "nav_right") {
            this.qNavRight = true;
        } else if (btn.id === "nav_confirm") {
            this.qNavConfirm = true;
        } else if (btn.id === "nav_back") {
            this.qNavBack = true;
        } else if (btn.id === "fire") {
            this.fireFingerId = id;
            this.fireStickDragging = false;
            this.fireOriginX = btn.x;
            this.fireOriginY = btn.y;
            this.fireKnobX = btn.x;
            this.fireKnobY = btn.y;
            const smart = pickSmartFireTarget(
                this.ctx.playerScreenX,
                this.ctx.playerScreenY,
                this.stickMoveX < 0 ? -1 : (this.stickMoveX > 0 ? 1 : this.ctx.playerFacing),
                vp.stageW,
                vp.stageH,
                vp.uiScale,
                this.ctx.enemyTargets,
                this.settings.aimAssist,
                this.hasAim ? { x: this.aimX, y: this.aimY } : undefined,
            );
            this.aimX = smart.x;
            this.aimY = smart.y;
            this.hasAim = true;
            // 不在按下瞬间误射：统一在松手时发射一发（短按智能快射 / 拖动 ≥阈值 360° 精瞄松手发射）
            if (!fromMouse) this.vibrate(0.012);
        } else if (btn.id === "bottle") {
            this.bottleFingerId = id;
            this.bottleOriginOvX = btn.x;
            this.bottleOriginOvY = btn.y;
            this.bottleCancelHover = false;
            this.bottleFingerOvX = ovX;
            this.bottleFingerOvY = ovY;
            const dir = this.ctx.playerFacing < 0 ? -1 : 1;
            this.aimX = clamp(this.ctx.playerScreenX + dir * 180 * vp.uiScale, 24, Math.max(48, vp.stageW - 24));
            this.aimY = clamp(this.ctx.playerScreenY - 18 * vp.uiScale, 20, Math.max(40, vp.stageH - 48));
            this.hasAim = true;
            if (!fromMouse) this.vibrate(0.015);
        }
    }

    private updateStickFromOverlay(ovX: number, ovY: number): void {
        const maxR = Math.max(24, this.ctx.stickMaxR);
        const dead = maxR * STICK_DEAD_RATIO;
        const dx = ovX - this.stickOriginX;
        const dy = ovY - this.stickOriginY;
        const dist = hypot(dx, dy);
        if (dist <= 0.001) {
            this.stickKnobX = this.stickOriginX;
            this.stickKnobY = this.stickOriginY;
            this.stickMoveX = 0;
            this.stickMoveY = 0;
            this.stickSlow = false;
            return;
        }
        const clamped = Math.min(dist, maxR);
        this.stickKnobX = this.stickOriginX + (dx / dist) * clamped;
        this.stickKnobY = this.stickOriginY + (dy / dist) * clamped;

        if (dist < dead) {
            this.stickMoveX = 0;
            this.stickMoveY = 0;
            this.stickSlow = false;
            return;
        }
        const nx = (dx / dist) * (clamped / maxR);
        const ny = (dy / dist) * (clamped / maxR);

        this.stickMoveX = Math.abs(nx) >= 0.22 ? (nx > 0 ? 1 : -1) : 0;
        if (this.ctx.allowDepth) {
            // 叠加层 y 向上，而 Input.moveY 为 -1 上、+1 下
            this.stickMoveY = Math.abs(ny) >= 0.30 ? (ny > 0 ? -1 : 1) : 0;
        } else {
            this.stickMoveY = 0;
        }
        // 小满潜行房内圈轻推自动慢走（与手柄左摇杆内圈 < 56% 完全一致）
        this.stickSlow = this.ctx.childMode && this.stickMoveX !== 0 && clamped < maxR * 0.56;
    }

    private handleTouchMoved(id: number, viewX: number, viewY: number, fromMouse: boolean): void {
        const f = this.fingers[id];
        if (f === undefined) {
            return;
        }
        if (!fromMouse) {
            this.lastRealTouchClock = this.clockSec;
        } else {
            this.qMouseConsumed = true;
        }
        const vp = this.ctx.viewport;
        const ov = this.toOverlay(viewX, viewY);
        f.movedDistOv += hypot(ov.x - f.curOvX, ov.y - f.curOvY);
        f.curViewX = viewX;
        f.curViewY = viewY;
        f.curOvX = ov.x;
        f.curOvY = ov.y;

        if (f.kind === "modal" && this.modalFingerId === id) {
            const stage = viewToStage(viewX, viewY, vp);
            this.uiX = stage.x;
            this.uiY = stage.y;
            return;
        }

        if (f.kind === "stick" && this.stickFingerId === id) {
            this.updateStickFromOverlay(ov.x, ov.y);
            return;
        }

        if (f.kind === "aim_canvas" && this.aimCanvasFingerId === id) {
            const stage = viewToStage(viewX, viewY, vp);
            const assisted = snapPointAim(
                clamp(stage.x, 8, Math.max(16, vp.stageW - 8)),
                clamp(stage.y, 8, Math.max(16, vp.stageH - 8)),
                this.ctx.enemyTargets,
                34 * vp.uiScale,
                this.settings.aimAssist,
            );
            this.aimX = assisted.x;
            this.aimY = assisted.y;
            this.hasAim = true;
            return;
        }

        if (f.kind === "btn" && f.btnId === "fire" && this.fireFingerId === id) {
            const maxR = FIRE_STICK_MAX_R_OV * this.settings.touchScale;
            const dx = ov.x - this.fireOriginX;
            const dy = ov.y - this.fireOriginY;
            const dist = hypot(dx, dy);
            const clamped = Math.min(dist, maxR);
            this.fireKnobX = dist > 0.001 ? this.fireOriginX + (dx / dist) * clamped : this.fireOriginX;
            this.fireKnobY = dist > 0.001 ? this.fireOriginY + (dy / dist) * clamped : this.fireOriginY;
            if (dist >= FIRE_STICK_DRAG_THRESHOLD_OV * this.settings.touchScale) {
                this.fireStickDragging = true;
                f.firedOnDrag = true;
                const pt = snapConeAim(
                    this.ctx.playerScreenX,
                    this.ctx.playerScreenY,
                    dx / dist,
                    dy / dist,
                    260 * vp.uiScale,
                    vp.stageW,
                    vp.stageH,
                    this.ctx.enemyTargets,
                    this.settings.aimAssist,
                );
                this.aimX = pt.x;
                this.aimY = pt.y;
                this.hasAim = true;
            }
            return;
        }

        if (f.kind === "btn" && f.btnId === "bottle" && this.bottleFingerId === id) {
            this.bottleFingerOvX = ov.x;
            this.bottleFingerOvY = ov.y;
            const cancel = this.ctx.bottleCancelCenter;
            const dCancel = hypot(ov.x - cancel.x, ov.y - cancel.y);
            this.bottleCancelHover = dCancel <= cancel.r;
            if (!this.bottleCancelHover) {
                const stage = viewToStage(viewX, viewY, vp);
                if (vp.isPortrait && !stage.inside) {
                    // 竖屏下掌机区拖曳投瓶：按相对位移映射到上方 16:9 舞台
                    const dx = ov.x - this.bottleOriginOvX;
                    const dy = ov.y - this.bottleOriginOvY;
                    const dir = this.ctx.playerFacing < 0 ? -1 : 1;
                    const baseForward = dir * Math.min(180 * vp.uiScale, vp.stageW * 0.28);
                    this.aimX = clamp(this.ctx.playerScreenX + baseForward + dx * 2.2, 16, Math.max(32, vp.stageW - 16));
                    this.aimY = clamp(this.ctx.playerScreenY + dy * 1.4, 16, Math.max(32, vp.stageH - 16));
                } else {
                    // 横屏或手指滑入舞台：指尖略上移防遮挡落点
                    this.aimX = clamp(stage.x, 16, Math.max(32, vp.stageW - 16));
                    this.aimY = clamp(stage.y + BOTTLE_AIM_Y_OFFSET_UI * vp.uiScale, 16, Math.max(32, vp.stageH - 28));
                }
                this.hasAim = true;
            }
        }
    }

    private handleTouchEnded(id: number, viewX: number, viewY: number, fromMouse: boolean): void {
        const f = this.fingers[id];
        if (f === undefined) {
            return;
        }
        if (!fromMouse) {
            this.lastRealTouchClock = this.clockSec;
        } else {
            this.qMouseConsumed = true;
        }
        const vp = this.ctx.viewport;
        const ov = this.toOverlay(viewX, viewY);
        if (f.kind === "modal" && this.modalFingerId === id) {
            const stage = viewToStage(viewX, viewY, vp);
            this.uiX = stage.x;
            this.uiY = stage.y;
            this.uiHeld = false;
            this.uiReleasedQueue = true;
            this.modalFingerId = -1;
            delete this.fingers[id];
            return;
        }

        if (f.kind === "btn" && f.btnId === "fire" && this.fireFingerId === id) {
            if (this.ctx.canShoot) {
                this.qFirePressed = true;
                if (!fromMouse) this.vibrate(0.016);
            }
        } else if (f.kind === "btn" && f.btnId === "bottle" && this.bottleFingerId === id) {
            const cancel = this.ctx.bottleCancelCenter;
            const dCancel = hypot(ov.x - cancel.x, ov.y - cancel.y);
            if (dCancel <= cancel.r) {
                this.qBottleCanceled = true;
                if (!fromMouse) this.vibrate(0.012);
            }
        }

        this.releaseFingerById(id);
    }
}
