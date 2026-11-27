/**
 * 《向西守望》统一输入状态容器（零外设轮询实现，完全委托至当前活跃端 TargetInputDriver）。
 *
 * - Windows 端仅加载 KbmPoller（零触控节点、零手柄 FFI）；
 * - Android 手机端仅加载 TouchRouter + TouchControls（零键鼠、零手柄）；
 * - Android 掌机端仅加载 TouchRouter + 横屏 TouchControls + GamepadRouter（零键鼠、零竖屏）；
 * - Web 端加载全量三模驱动。
 */

import { Node } from "Dora";
import {
    ControlSettings,
    GamepadLayout,
    InputMode,
    InputModePref,
    loadControlSettings,
    nextPrefInList,
    saveControlSettings,
} from "Script/watch/controls_config";
import { getActiveTarget } from "Script/watch/target";
import {
    StageViewport,
    TargetAttachHooks,
    TargetFrameSync,
    TargetInputDriver,
    TargetRuntime,
} from "Script/watch/target_types";

/** 一个键的三种状态。pressed / released 只在发生的那一帧为真。 */
export interface KeyState {
    held: boolean;
    pressed: boolean;
    released: boolean;
}

function emptyKey(): KeyState {
    return { held: false, pressed: false, released: false };
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

export class Input {
    moveX = 0;
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

    pickRoom = 0;

    /** 主舞台局部指针坐标（左下原点、y 向上） */
    mx = 0;
    my = 0;
    inside = true;
    mdx = 0;
    mdy = 0;

    /** 规范化渲染帧 UI 指针（不被模拟步 endStep 清空） */
    uiX = 0;
    uiY = 0;
    uiDx = 0;
    uiDy = 0;
    uiInside = false;
    uiHeld = false;
    uiPressed = false;
    uiReleased = false;
    uiRightPressed = false;

    readonly settings: ControlSettings = loadControlSettings();
    readonly target: TargetRuntime;
    private readonly driver: TargetInputDriver;

    inputMode: InputMode;
    gamepadLayout: GamepadLayout = "xbox";
    userInteracted = false;

    frameInteractPressed = false;
    private suppressPickRoomOnce = false;

    artifactTogglePressed = false;
    bottleCanceled = false;
    touchZoneTap = "";
    muteTogglePressed = false;
    fullscreenTogglePressed = false;
    splashSkipPressed = false;

    navUp = false;
    navDown = false;
    navLeft = false;
    navRight = false;
    navConfirm = false;
    navBack = false;
    navPrevTab = false;
    navNextTab = false;

    /** 3×3 换弹盘方向步进与确认/重画信号（键鼠与手柄统一汇入） */
    reloadDirCol = 0;
    reloadDirRow = 0;
    reloadStepEdge = false;
    reloadAutoStep = false;
    reloadConfirm = false;
    reloadReset = false;

    /** 工台确认/收起信号（键鼠 Return/Space/E/BackSpace 与手柄统一汇入） */
    craftConfirm = false;
    craftCancel = false;

    /** 局内三选一本领卡切选信号 */
    talentDelta = 0;
    talentConfirm = false;

    /** Back 长按重试进度（0..1） */
    retryHoldProgress = 0;

    private stageVp: StageViewport;
    private lastPick = 0;

    constructor() {
        this.target = getActiveTarget();
        if (this.settings.modePref !== "auto" && this.target.supportedModes.indexOf(this.settings.modePref) < 0) {
            this.settings.modePref = "auto";
        }
        this.driver = this.target.createDriver(this.settings);
        this.stageVp = this.target.computeStageViewport(1280, 720);
        this.gamepadLayout = this.settings.gamepadLayout;
        this.inputMode = this.driver.defaultMode;
        if (this.settings.modePref !== "auto") {
            this.inputMode = this.settings.modePref;
        }
    }

    attach(parent: Node.Type, hooks: TargetAttachHooks): void {
        this.driver.attach(parent, hooks);
    }

    syncFrame(ctx: TargetFrameSync): void {
        this.driver.syncFrame(ctx);
    }

    renderOverlay(): void {
        this.driver.renderOverlay();
    }

    getTouchRouter(): unknown {
        return this.driver.getTouchRouter !== undefined ? this.driver.getTouchRouter() : undefined;
    }

    getGamepadRouter(): unknown {
        return this.driver.getGamepadRouter !== undefined ? this.driver.getGamepadRouter() : undefined;
    }

    getTouchControls(): unknown {
        return this.driver.getTouchControls !== undefined ? this.driver.getTouchControls() : undefined;
    }

    injectTouch(phase: "began" | "moved" | "ended", id: number, x: number, y: number, fromMouse?: boolean): void {
        if (this.driver.injectTouch !== undefined) {
            this.driver.injectTouch(phase, id, x, y, fromMouse);
        }
    }

    setGamepadSim(state?: unknown): void {
        if (this.driver.setGamepadSim !== undefined) {
            this.driver.setGamepadSim(state);
        }
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

    setInputMode(mode: InputMode): void {
        if (this.target.supportedModes.indexOf(mode) < 0) {
            return;
        }
        if (this.inputMode === mode) return;
        this.inputMode = mode;
        if (this.driver.onInputModeChanged !== undefined) {
            this.driver.onInputModeChanged(mode);
        }
    }

    setModePref(pref: InputModePref): void {
        if (this.target.modePrefOrder.indexOf(pref) < 0) {
            return;
        }
        this.settings.modePref = pref;
        if (pref !== "auto") {
            this.setInputMode(pref);
        }
        saveControlSettings(this.settings);
    }

    cycleModePref(delta: number = 1): InputModePref {
        const order = this.target.modePrefOrder;
        if (order.length <= 1) {
            return order[0] ?? this.inputMode;
        }
        const next = nextPrefInList(this.settings.modePref, order, delta);
        this.setModePref(next);
        return next;
    }

    shouldShowTouchControls(): boolean {
        return this.driver.shouldShowTouchControls(this, this.stageVp);
    }

    markKeyboardActivity(): void {
        if (!this.target.supportsKbm) {
            return;
        }
        this.userInteracted = true;
        if (this.settings.modePref === "auto") {
            this.setInputMode("kbm");
        }
    }

    vibrate(seconds: number): void {
        this.driver.vibrate(seconds);
    }

    clearTransient(keepTouchToggles: boolean = false): void {
        this.driver.clearTransient(keepTouchToggles);
    }

    update(): void {
        this.driver.pollInto(this);
    }

    /** 供各端驱动写入核心玩法按键的电平与边沿态。 */
    applyKeyHeld(
        jump: boolean,
        crouch: boolean,
        cover: boolean,
        interact: boolean,
        aim: boolean,
        fire: boolean,
        flare: boolean,
        pause: boolean,
        retry: boolean,
        toggleView: boolean,
        tab: boolean,
    ): void {
        this.jump = edge(this.jump, jump);
        this.crouch = edge(this.crouch, crouch);
        this.cover = edge(this.cover, cover);
        this.interact = edge(this.interact, interact);
        this.aim = edge(this.aim, aim);
        this.fire = edge(this.fire, fire);
        this.flare = edge(this.flare, flare);
        this.pause = edge(this.pause, pause);
        this.retry = edge(this.retry, retry);
        this.toggleView = edge(this.toggleView, toggleView);
        this.tab = edge(this.tab, tab);
    }

    /** 每帧驱动采样前清零单帧瞬时边沿信号。 */
    resetFrameSignals(): void {
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

        this.craftConfirm = false;
        this.craftCancel = false;

        this.talentDelta = 0;
        this.talentConfirm = false;
        this.retryHoldProgress = 0;
    }

    applyPickRoom(pick: number): void {
        if (this.suppressPickRoomOnce) {
            this.suppressPickRoomOnce = false;
            this.pickRoom = 0;
        } else if (pick !== 0 && pick !== this.lastPick) {
            this.pickRoom = pick;
        }
        this.lastPick = pick;
    }

    consumePickRoom(): void {
        this.pickRoom = 0;
        this.suppressPickRoomOnce = true;
    }

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
