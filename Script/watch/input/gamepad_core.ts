/**
 * 《向西守望》纯手柄输入驱动内核（仅安卓掌机与 Web 目标引入）。
 *
 * 注意：Windows 与 Android 手机/平板发行包不引入、不打包本模块。
 */

import { AxisName, ButtonName, Controller, Node, Size, Vec2 } from "Dora";
import { AimTargetCandidate, snapConeAim } from "Script/watch/input/aim_assist";
import {
    ControlSettings,
    GamepadLayout,
    defaultControlSettings,
    saveControlSettings,
} from "Script/watch/controls_config";

export interface GamepadFrameContext {
    stageW: number;
    stageH: number;
    uiScale: number;
    modal: boolean;
    gameplayActive: boolean;
    reloadActive: boolean;
    craftActive: boolean;
    talentOfferCount: number;
    childMode: boolean;
    allowDepth: boolean;
    canShoot: boolean;
    canBottleAim: boolean;
    playerRolling: boolean;
    inLowArch: boolean;
    inTowerEnd: boolean;
    playerFacing: number;
    playerScreenX: number;
    playerScreenY: number;
    enemyTargets: AimTargetCandidate[];
}

export interface GamepadRawState {
    a?: boolean;
    b?: boolean;
    x?: boolean;
    y?: boolean;
    up?: boolean;
    down?: boolean;
    left?: boolean;
    right?: boolean;
    lb?: boolean;
    rb?: boolean;
    ls?: boolean;
    rs?: boolean;
    back?: boolean;
    start?: boolean;
    leftX?: number;
    leftY?: number;
    rightX?: number;
    rightY?: number;
    lt?: number;
    rt?: number;
}

export interface GamepadSnapshot {
    hadGamepadInput: boolean;
    anyButtonPressed: boolean;
    moveX: number;
    moveY: number;
    jumpHeld: boolean;
    jumpPressed: boolean;
    crouchHeld: boolean;
    crouchPressed: boolean;
    coverHeld: boolean;
    interactHeld: boolean;
    interactPressed: boolean;
    aimHeld: boolean;
    aimPressed: boolean;
    bottleCanceled: boolean;
    fireHeld: boolean;
    firePressed: boolean;
    flareHeld: boolean;
    flarePressed: boolean;
    pausePressed: boolean;
    retryPressed: boolean;
    retryHoldProgress: number;
    artifactPressed: boolean;
    hasAim: boolean;
    aimX: number;
    aimY: number;
    navUp: boolean;
    navDown: boolean;
    navLeft: boolean;
    navRight: boolean;
    navConfirm: boolean;
    navBack: boolean;
    navPrevTab: boolean;
    navNextTab: boolean;
    reloadDirCol: number;
    reloadDirRow: number;
    reloadStepEdge: boolean;
    reloadAutoStep: boolean;
    reloadConfirm: boolean;
    reloadReset: boolean;
    talentDelta: number;
    talentConfirm: boolean;
}

const MAX_CONTROLLER_SLOTS = 4;
const STICK_MENU_DEADZONE = 0.55;
const MENU_REPEAT_INITIAL = 0.38;
const MENU_REPEAT_INTERVAL = 0.13;
const TRIGGER_PRESS_THRESHOLD = 0.35;
const TRIGGER_RELEASE_THRESHOLD = 0.20;
const RETRY_HOLD_SEC = 0.55;
const BOTTLE_AIM_SPEED_UI = 460;

interface NormalizedRaw {
    a: boolean;
    b: boolean;
    x: boolean;
    y: boolean;
    up: boolean;
    down: boolean;
    left: boolean;
    right: boolean;
    lb: boolean;
    rb: boolean;
    ls: boolean;
    rs: boolean;
    back: boolean;
    start: boolean;
    leftX: number;
    leftY: number;
    rightX: number;
    rightY: number;
    lt: number;
    rt: number;
}

function emptyRaw(): NormalizedRaw {
    return {
        a: false, b: false, x: false, y: false,
        up: false, down: false, left: false, right: false,
        lb: false, rb: false, ls: false, rs: false,
        back: false, start: false,
        leftX: 0, leftY: 0, rightX: 0, rightY: 0,
        lt: 0, rt: 0,
    };
}

function clamp(v: number, lo: number, hi: number): number {
    return v < lo ? lo : (v > hi ? hi : v);
}

function hypot(dx: number, dy: number): number {
    return Math.sqrt(dx * dx + dy * dy);
}

function safeButtonPressed(id: number, btn: ButtonName): boolean {
    if (typeof Controller === "undefined") return false;
    return Controller.isButtonPressed(id, btn);
}

function safeButtonDown(id: number, btn: ButtonName): boolean {
    if (typeof Controller === "undefined") return false;
    return Controller.isButtonDown(id, btn);
}

function safeAxis(id: number, axis: AxisName): number {
    if (typeof Controller === "undefined") return 0;
    const v = Controller.getAxis(id, axis);
    return typeof v === "number" ? v : 0;
}

export class GamepadRouter {
    settings: ControlSettings;
    activeControllerId = 0;

    private listenerNode: Node.Type | undefined;
    private simState: GamepadRawState | undefined;
    private latchedButtons: Record<string, boolean> = {};

    private ctx: GamepadFrameContext = {
        stageW: 1280,
        stageH: 720,
        uiScale: 1,
        modal: true,
        gameplayActive: false,
        reloadActive: false,
        craftActive: false,
        talentOfferCount: 0,
        childMode: false,
        allowDepth: false,
        canShoot: false,
        canBottleAim: false,
        playerRolling: false,
        inLowArch: false,
        inTowerEnd: false,
        playerFacing: 1,
        playerScreenX: 640,
        playerScreenY: 240,
        enemyTargets: [],
    };

    private prevA = false;
    private prevB = false;
    private prevX = false;
    private prevY = false;
    private prevUp = false;
    private prevDown = false;
    private prevLeft = false;
    private prevRight = false;
    private prevLb = false;
    private prevRb = false;
    private prevLs = false;
    private prevRs = false;
    private prevBack = false;
    private prevStart = false;
    private ltPressed = false;
    private rtPressed = false;
    private prevRtPressed = false;

    private chordLocked = false;
    private backHoldSec = 0;
    private backRetryFired = false;

    private crouchToggled = false;
    private bottleCancelLock = false;

    private repeatDirX = 0;
    private repeatDirY = 0;
    private repeatTimer = 0;

    private reloadStickCol = 0;
    private reloadStickRow = 0;
    private reloadStickTimer = 0;
    private reloadStickArmed = false;

    private aimAngle = 0;
    private aimLastFacing = 1;
    private aimX = 640;
    private aimY = 260;
    private bottleOffsetX = 160;
    private bottleOffsetY = 0;
    private wasBottleAiming = false;

    private lastDt = 1 / 60;

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
        n.order = 115;
        n.controllerEnabled = true;
        n.touchEnabled = false;

        n.onButtonDown((controllerId: number, buttonName: ButtonName) => {
            this.activeControllerId = controllerId;
            this.latchedButtons[buttonName] = true;
        });

        n.onAxis((controllerId: number, _axisName: AxisName, value: number) => {
            if (Math.abs(value) > 0.35) {
                this.activeControllerId = controllerId;
            }
        });

        n.addTo(parent);
        this.listenerNode = n;
    }

    setSimulatedState(state?: GamepadRawState): void {
        this.simState = state;
    }

    toggleLayout(): GamepadLayout {
        this.settings.gamepadLayout = this.settings.gamepadLayout === "xbox" ? "nintendo" : "xbox";
        saveControlSettings(this.settings);
        return this.settings.gamepadLayout;
    }

    toggleAimAssist(): boolean {
        this.settings.aimAssist = !this.settings.aimAssist;
        saveControlSettings(this.settings);
        return this.settings.aimAssist;
    }

    toggleCrouchMode(): boolean {
        this.settings.crouchToggle = !this.settings.crouchToggle;
        if (!this.settings.crouchToggle) {
            this.crouchToggled = false;
        }
        saveControlSettings(this.settings);
        return this.settings.crouchToggle;
    }

    setFrameContext(next: GamepadFrameContext, dt: number): void {
        this.lastDt = Math.min(0.05, Math.max(0.001, dt));
        const wasChild = this.ctx.childMode;
        const wasReload = this.ctx.reloadActive;
        this.ctx = next;
        if (wasChild !== next.childMode || next.modal) {
            this.crouchToggled = false;
        }
        if (next.reloadActive && !wasReload) {
            this.reloadStickCol = 0;
            this.reloadStickRow = 0;
            this.reloadStickTimer = 0;
            this.reloadStickArmed = false;
        }
        if (!next.canBottleAim) {
            this.wasBottleAiming = false;
            this.bottleCancelLock = false;
        }
    }

    clearTransient(): void {
        this.latchedButtons = {};
        this.backHoldSec = 0;
        this.backRetryFired = false;
        this.chordLocked = false;
        this.crouchToggled = false;
        this.bottleCancelLock = false;
        this.wasBottleAiming = false;
        this.repeatDirX = 0;
        this.repeatDirY = 0;
        this.repeatTimer = 0;
    }

    private sampleRaw(): NormalizedRaw {
        if (this.simState !== undefined) {
            const s = this.simState;
            return {
                a: s.a === true,
                b: s.b === true,
                x: s.x === true,
                y: s.y === true,
                up: s.up === true,
                down: s.down === true,
                left: s.left === true,
                right: s.right === true,
                lb: s.lb === true,
                rb: s.rb === true,
                ls: s.ls === true,
                rs: s.rs === true,
                back: s.back === true,
                start: s.start === true,
                leftX: s.leftX ?? 0,
                leftY: s.leftY ?? 0,
                rightX: s.rightX ?? 0,
                rightY: s.rightY ?? 0,
                lt: s.lt ?? 0,
                rt: s.rt ?? 0,
            };
        }

        const out = emptyRaw();
        if (typeof Controller === "undefined") {
            return out;
        }

        let cid = 0;
        for (cid = 0; cid < MAX_CONTROLLER_SLOTS; cid++) {
            const a = safeButtonPressed(cid, ButtonName.A) || safeButtonDown(cid, ButtonName.A);
            const b = safeButtonPressed(cid, ButtonName.B) || safeButtonDown(cid, ButtonName.B);
            const x = safeButtonPressed(cid, ButtonName.X) || safeButtonDown(cid, ButtonName.X);
            const y = safeButtonPressed(cid, ButtonName.Y) || safeButtonDown(cid, ButtonName.Y);
            const up = safeButtonPressed(cid, ButtonName.Up) || safeButtonDown(cid, ButtonName.Up);
            const down = safeButtonPressed(cid, ButtonName.Down) || safeButtonDown(cid, ButtonName.Down);
            const left = safeButtonPressed(cid, ButtonName.Left) || safeButtonDown(cid, ButtonName.Left);
            const right = safeButtonPressed(cid, ButtonName.Right) || safeButtonDown(cid, ButtonName.Right);
            const lb = safeButtonPressed(cid, ButtonName.LeftShoulder) || safeButtonDown(cid, ButtonName.LeftShoulder);
            const rb = safeButtonPressed(cid, ButtonName.RightShoulder) || safeButtonDown(cid, ButtonName.RightShoulder);
            const ls = safeButtonPressed(cid, ButtonName.LeftStick) || safeButtonDown(cid, ButtonName.LeftStick);
            const rs = safeButtonPressed(cid, ButtonName.RightStick) || safeButtonDown(cid, ButtonName.RightStick);
            const back = safeButtonPressed(cid, ButtonName.Back) || safeButtonDown(cid, ButtonName.Back);
            const start = safeButtonPressed(cid, ButtonName.Start) || safeButtonDown(cid, ButtonName.Start);

            const lx = safeAxis(cid, AxisName.LeftX);
            const ly = safeAxis(cid, AxisName.LeftY);
            const rx = safeAxis(cid, AxisName.RightX);
            const ry = safeAxis(cid, AxisName.RightY);
            const lt = Math.max(0, safeAxis(cid, AxisName.LeftTrigger));
            const rt = Math.max(0, safeAxis(cid, AxisName.RightTrigger));

            const anyBtn = a || b || x || y || up || down || left || right || lb || rb || ls || rs || back || start;
            const anyAxis = Math.abs(lx) > 0.25 || Math.abs(ly) > 0.25 || Math.abs(rx) > 0.25 || Math.abs(ry) > 0.25 || lt > 0.25 || rt > 0.25;
            if (anyBtn || anyAxis) {
                this.activeControllerId = cid;
            }
            if (a) out.a = true;
            if (b) out.b = true;
            if (x) out.x = true;
            if (y) out.y = true;
            if (up) out.up = true;
            if (down) out.down = true;
            if (left) out.left = true;
            if (right) out.right = true;
            if (lb) out.lb = true;
            if (rb) out.rb = true;
            if (ls) out.ls = true;
            if (rs) out.rs = true;
            if (back) out.back = true;
            if (start) out.start = true;

            if (Math.abs(lx) > Math.abs(out.leftX)) out.leftX = lx;
            if (Math.abs(ly) > Math.abs(out.leftY)) out.leftY = ly;
            if (Math.abs(rx) > Math.abs(out.rightX)) out.rightX = rx;
            if (Math.abs(ry) > Math.abs(out.rightY)) out.rightY = ry;
            if (lt > out.lt) out.lt = lt;
            if (rt > out.rt) out.rt = rt;
        }

        if (this.latchedButtons[ButtonName.A]) out.a = true;
        if (this.latchedButtons[ButtonName.B]) out.b = true;
        if (this.latchedButtons[ButtonName.X]) out.x = true;
        if (this.latchedButtons[ButtonName.Y]) out.y = true;
        if (this.latchedButtons[ButtonName.Up]) out.up = true;
        if (this.latchedButtons[ButtonName.Down]) out.down = true;
        if (this.latchedButtons[ButtonName.Left]) out.left = true;
        if (this.latchedButtons[ButtonName.Right]) out.right = true;
        if (this.latchedButtons[ButtonName.LeftShoulder]) out.lb = true;
        if (this.latchedButtons[ButtonName.RightShoulder]) out.rb = true;
        if (this.latchedButtons[ButtonName.LeftStick]) out.ls = true;
        if (this.latchedButtons[ButtonName.RightStick]) out.rs = true;
        if (this.latchedButtons[ButtonName.Back]) out.back = true;
        if (this.latchedButtons[ButtonName.Start]) out.start = true;
        this.latchedButtons = {};

        return out;
    }

    consumeSnapshot(): GamepadSnapshot {
        const dt = this.lastDt;
        const raw = this.sampleRaw();

        const ltNow = this.ltPressed ? raw.lt > TRIGGER_RELEASE_THRESHOLD : raw.lt > TRIGGER_PRESS_THRESHOLD;
        const rtNow = this.rtPressed ? raw.rt > TRIGGER_RELEASE_THRESHOLD : raw.rt > TRIGGER_PRESS_THRESHOLD;
        this.ltPressed = ltNow;
        this.rtPressed = rtNow;

        const aPressed = raw.a && !this.prevA;
        const bPressed = raw.b && !this.prevB;
        const xPressed = raw.x && !this.prevX;
        const yPressed = raw.y && !this.prevY;
        const upPressed = raw.up && !this.prevUp;
        const downPressed = raw.down && !this.prevDown;
        const leftPressed = raw.left && !this.prevLeft;
        const rightPressed = raw.right && !this.prevRight;
        const lbPressed = raw.lb && !this.prevLb;
        const rbPressed = raw.rb && !this.prevRb;
        const lsPressed = raw.ls && !this.prevLs;
        const rsPressed = raw.rs && !this.prevRs;
        const startPressed = raw.start && !this.prevStart;
        const rtEdge = rtNow && !this.prevRtPressed;

        const dzL = this.settings.deadzoneLeft;
        const dzR = this.settings.deadzoneRight;
        const lMag = hypot(raw.leftX, raw.leftY);
        const rMag = hypot(raw.rightX, raw.rightY);
        const hadGamepadInput = raw.a || raw.b || raw.x || raw.y
            || raw.up || raw.down || raw.left || raw.right
            || raw.lb || raw.rb || raw.ls || raw.rs
            || raw.back || raw.start
            || ltNow || rtNow || lMag > dzL || rMag > dzR;
        const anyButtonPressed = aPressed || bPressed || xPressed || yPressed || startPressed || lbPressed || rbPressed;

        // 1. 避让 Dora Go 移动端客户端「Back + Start」退出组合键
        let pausePressed = false;
        let retryPressed = false;
        if (raw.back && raw.start) {
            this.chordLocked = true;
            this.backHoldSec = 0;
            this.backRetryFired = false;
        } else if (this.chordLocked) {
            if (!raw.back && !raw.start) {
                this.chordLocked = false;
            }
            this.backHoldSec = 0;
            this.backRetryFired = false;
        } else {
            if (startPressed && !raw.back) {
                pausePressed = true;
            }
            if (raw.back && !raw.start && this.ctx.gameplayActive && !this.ctx.modal && !this.ctx.inTowerEnd) {
                this.backHoldSec += dt;
                if (this.backHoldSec >= RETRY_HOLD_SEC && !this.backRetryFired) {
                    retryPressed = true;
                    this.backRetryFired = true;
                }
            } else {
                this.backHoldSec = 0;
                this.backRetryFired = false;
            }
        }
        const retryHoldProgress = raw.back && !this.chordLocked && !raw.start && this.ctx.gameplayActive && !this.ctx.modal
            ? clamp(this.backHoldSec / RETRY_HOLD_SEC, 0, 1)
            : 0;

        // 2. 左摇杆 + 十字键移动
        const dpadX = (raw.right ? 1 : 0) - (raw.left ? 1 : 0);
        const dpadY = (raw.down ? 1 : 0) - (raw.up ? 1 : 0);
        let stickMoveX = 0;
        let stickMoveY = 0;
        let stickSlowWalk = false;
        if (lMag > dzL) {
            const normMag = clamp((lMag - dzL) / Math.max(0.05, 1 - dzL), 0, 1);
            const nx = raw.leftX / lMag;
            const ny = raw.leftY / lMag;
            if (this.ctx.allowDepth) {
                const maxAxis = Math.max(Math.abs(nx), Math.abs(ny), 0.001);
                stickMoveX = clamp((nx / maxAxis) * normMag, -1, 1);
                stickMoveY = clamp((ny / maxAxis) * normMag, -1, 1);
            } else {
                if (Math.abs(raw.leftX) > dzL * 0.85) {
                    stickMoveX = raw.leftX > 0 ? 1 : -1;
                    if (lMag < 0.56) {
                        stickSlowWalk = true;
                    }
                }
                if (raw.leftY > 0.65 && Math.abs(raw.leftY) > Math.abs(raw.leftX) * 1.15) {
                    stickMoveY = 1;
                } else if (raw.leftY < -0.65 && Math.abs(raw.leftY) > Math.abs(raw.leftX) * 1.15) {
                    stickMoveY = -1;
                }
            }
        }
        const bottleSteerLocksMove = this.ctx.gameplayActive && this.ctx.childMode && this.ctx.canBottleAim
            && (rtNow || raw.x) && !this.bottleCancelLock && rMag <= dzR;
        const moveX = bottleSteerLocksMove ? 0 : (dpadX !== 0 ? dpadX : stickMoveX);
        const moveY = bottleSteerLocksMove ? 0 : (dpadY !== 0 ? dpadY : stickMoveY);

        // 3. 模态导航（左摇杆连发器）
        const sMenuX = Math.abs(raw.leftX) >= STICK_MENU_DEADZONE ? (raw.leftX > 0 ? 1 : -1) : 0;
        const sMenuY = Math.abs(raw.leftY) >= STICK_MENU_DEADZONE ? (raw.leftY > 0 ? 1 : -1) : 0;
        let stickNavX = 0;
        let stickNavY = 0;
        if (sMenuX === 0 && sMenuY === 0) {
            this.repeatDirX = 0;
            this.repeatDirY = 0;
            this.repeatTimer = 0;
        } else if (sMenuX !== this.repeatDirX || sMenuY !== this.repeatDirY) {
            this.repeatDirX = sMenuX;
            this.repeatDirY = sMenuY;
            this.repeatTimer = MENU_REPEAT_INITIAL;
            stickNavX = sMenuX;
            stickNavY = sMenuY;
        } else {
            this.repeatTimer -= dt;
            if (this.repeatTimer <= 0) {
                this.repeatTimer = MENU_REPEAT_INTERVAL;
                stickNavX = sMenuX;
                stickNavY = sMenuY;
            }
        }

        const navUp = upPressed || stickNavY < 0;
        const navDown = downPressed || stickNavY > 0;
        const navLeft = leftPressed || stickNavX < 0;
        const navRight = rightPressed || stickNavX > 0;
        const navConfirm = this.settings.gamepadLayout === "nintendo" ? bPressed : aPressed;
        const navBack = this.settings.gamepadLayout === "nintendo" ? aPressed : bPressed;
        const navPrevTab = lbPressed;
        const navNextTab = rbPressed;

        // 4. 3×3 换弹盘 8 向操作
        let reloadDirCol = 0;
        let reloadDirRow = 0;
        let reloadStepEdge = false;
        let reloadAutoStep = false;
        if (this.ctx.reloadActive) {
            const dpCol = (rightPressed ? 1 : 0) - (leftPressed ? 1 : 0);
            const dpRow = (upPressed ? 1 : 0) - (downPressed ? 1 : 0);
            if (dpCol !== 0 || dpRow !== 0) {
                reloadDirCol = dpCol;
                reloadDirRow = dpRow;
                reloadStepEdge = true;
            } else {
                const rMagL = hypot(raw.leftX, raw.leftY);
                if (rMagL >= 0.45) {
                    const ux = raw.leftX / rMagL;
                    const uy = -raw.leftY / rMagL;
                    const qCol = ux > 0.38 ? 1 : (ux < -0.38 ? -1 : 0);
                    const qRow = uy > 0.38 ? 1 : (uy < -0.38 ? -1 : 0);
                    if (qCol !== this.reloadStickCol || qRow !== this.reloadStickRow) {
                        this.reloadStickCol = qCol;
                        this.reloadStickRow = qRow;
                        this.reloadStickTimer = 0.24;
                        this.reloadStickArmed = true;
                        reloadDirCol = qCol;
                        reloadDirRow = qRow;
                        reloadStepEdge = true;
                        reloadAutoStep = true;
                    } else if (this.reloadStickArmed) {
                        this.reloadStickTimer -= dt;
                        if (this.reloadStickTimer <= 0) {
                            this.reloadStickTimer = 0.16;
                            reloadDirCol = qCol;
                            reloadDirRow = qRow;
                            reloadStepEdge = true;
                            reloadAutoStep = true;
                        }
                    }
                } else {
                    this.reloadStickCol = 0;
                    this.reloadStickRow = 0;
                    this.reloadStickTimer = 0;
                    this.reloadStickArmed = false;
                }
            }
        }
        const gpReloadConfirmBtn = this.settings.gamepadLayout === "nintendo" ? bPressed : aPressed;
        const gpReloadResetBtn = this.settings.gamepadLayout === "nintendo" ? aPressed : bPressed;
        const reloadConfirm = this.ctx.reloadActive && (gpReloadConfirmBtn || yPressed || rtEdge);
        const reloadReset = this.ctx.reloadActive && (gpReloadResetBtn || xPressed);

        // 5. 局内三选一本领卡切选
        let talentDelta = 0;
        let talentConfirm = false;
        if (this.ctx.talentOfferCount > 0 && !this.ctx.modal && !this.ctx.reloadActive && !this.ctx.craftActive) {
            if (lbPressed) talentDelta -= 1;
            if (rbPressed) talentDelta += 1;
            if (lsPressed || rsPressed || (raw.lb && rbPressed) || (raw.rb && lbPressed)) {
                talentConfirm = true;
            }
        }

        // 6. 局内核心动作映射
        const gpActive = this.ctx.gameplayActive && !this.ctx.modal && !this.ctx.reloadActive && !this.ctx.craftActive;
        let jumpHeld = false;
        let jumpPressed = false;
        let crouchHeld = false;
        let crouchPressed = false;
        let coverHeld = false;
        let interactHeld = false;
        let interactPressed = false;
        let aimHeld = false;
        let aimPressed = false;
        let bottleCanceled = false;
        let fireHeld = false;
        let firePressed = false;
        let flareHeld = false;
        let flarePressed = false;
        let artifactPressed = false;

        if (gpActive) {
            jumpHeld = raw.a;
            jumpPressed = aPressed;

            if (this.settings.crouchToggle && this.ctx.childMode) {
                if (bPressed && !this.wasBottleAiming) {
                    this.crouchToggled = !this.crouchToggled;
                    crouchPressed = true;
                }
                crouchHeld = this.crouchToggled;
            } else {
                crouchHeld = raw.b && !this.wasBottleAiming;
                crouchPressed = bPressed && !this.wasBottleAiming;
            }

            coverHeld = ltNow || raw.lb || (this.ctx.childMode && stickSlowWalk);
            interactHeld = raw.y || raw.rb;
            interactPressed = yPressed || rbPressed;

            if (this.ctx.childMode) {
                const rawBottleBtn = rtNow || raw.x;
                if (this.ctx.canBottleAim) {
                    if (this.bottleCancelLock) {
                        if (!rawBottleBtn) {
                            this.bottleCancelLock = false;
                        }
                        aimHeld = false;
                    } else if (rawBottleBtn && bPressed && this.wasBottleAiming) {
                        bottleCanceled = true;
                        this.bottleCancelLock = true;
                        this.wasBottleAiming = false;
                        aimHeld = false;
                    } else {
                        aimHeld = rawBottleBtn;
                        aimPressed = (rtEdge || xPressed) && !this.wasBottleAiming;
                        this.wasBottleAiming = rawBottleBtn;
                    }
                } else {
                    this.wasBottleAiming = false;
                    this.bottleCancelLock = false;
                }
            } else {
                fireHeld = rtNow || raw.x;
                firePressed = rtEdge || xPressed;
                if (lsPressed && this.ctx.talentOfferCount === 0) {
                    artifactPressed = true;
                }
            }
        }

        // 7. 虚拟准星计算
        let hasAim = false;
        const scale = Math.max(0.25, this.ctx.uiScale);
        if (gpActive && !this.ctx.childMode && this.ctx.canShoot) {
            if (this.ctx.playerFacing !== this.aimLastFacing && rMag <= dzR) {
                this.aimAngle = this.ctx.playerFacing >= 0 ? 0 : Math.PI;
                this.aimLastFacing = this.ctx.playerFacing;
            }
            if (rMag > dzR) {
                this.aimAngle = Math.atan2(-raw.rightY, raw.rightX);
                this.aimLastFacing = raw.rightX >= 0 ? 1 : -1;
            }
            const pt = snapConeAim(
                this.ctx.playerScreenX,
                this.ctx.playerScreenY,
                Math.cos(this.aimAngle),
                Math.sin(this.aimAngle),
                215 * scale,
                this.ctx.stageW,
                this.ctx.stageH,
                this.ctx.enemyTargets,
                this.settings.aimAssist,
            );
            this.aimX = pt.x;
            this.aimY = pt.y;
            hasAim = true;
        } else if (gpActive && this.ctx.childMode && this.ctx.canBottleAim) {
            if (aimPressed) {
                this.bottleOffsetX = this.ctx.playerFacing * 155 * scale;
                this.bottleOffsetY = 0;
            }
            if (aimHeld) {
                const steerX = rMag > dzR ? raw.rightX : (lMag > dzL ? raw.leftX : 0);
                const steerY = rMag > dzR ? -raw.rightY : (lMag > dzL ? -raw.leftY : 0);
                this.bottleOffsetX = clamp(
                    this.bottleOffsetX + steerX * BOTTLE_AIM_SPEED_UI * scale * dt,
                    -this.ctx.stageW * 0.48,
                    this.ctx.stageW * 0.48,
                );
                this.bottleOffsetY = clamp(
                    this.bottleOffsetY + steerY * BOTTLE_AIM_SPEED_UI * 0.7 * scale * dt,
                    -this.ctx.stageH * 0.35,
                    this.ctx.stageH * 0.45,
                );
                this.aimX = clamp(this.ctx.playerScreenX + this.bottleOffsetX, 16, Math.max(32, this.ctx.stageW - 16));
                this.aimY = clamp(this.ctx.playerScreenY + this.bottleOffsetY, 16, Math.max(32, this.ctx.stageH - 16));
                hasAim = true;
            }
        }

        this.prevA = raw.a;
        this.prevB = raw.b;
        this.prevX = raw.x;
        this.prevY = raw.y;
        this.prevUp = raw.up;
        this.prevDown = raw.down;
        this.prevLeft = raw.left;
        this.prevRight = raw.right;
        this.prevLb = raw.lb;
        this.prevRb = raw.rb;
        this.prevLs = raw.ls;
        this.prevRs = raw.rs;
        this.prevBack = raw.back;
        this.prevStart = raw.start;
        this.prevRtPressed = rtNow;

        return {
            hadGamepadInput,
            anyButtonPressed,
            moveX,
            moveY,
            jumpHeld,
            jumpPressed,
            crouchHeld,
            crouchPressed,
            coverHeld,
            interactHeld,
            interactPressed,
            aimHeld,
            aimPressed,
            bottleCanceled,
            fireHeld,
            firePressed,
            flareHeld,
            flarePressed,
            pausePressed,
            retryPressed,
            retryHoldProgress,
            artifactPressed,
            hasAim,
            aimX: this.aimX,
            aimY: this.aimY,
            navUp,
            navDown,
            navLeft,
            navRight,
            navConfirm,
            navBack,
            navPrevTab,
            navNextTab,
            reloadDirCol,
            reloadDirRow,
            reloadStepEdge,
            reloadAutoStep,
            reloadConfirm,
            reloadReset,
            talentDelta,
            talentConfirm,
        };
    }
}
