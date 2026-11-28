/**
 * 《向西守望》纯键鼠输入驱动内核（仅 Windows 与 Web 目标引入）。
 *
 * 职责：
 * - 单点轮询物理 Mouse 与 Keyboard（彻底消灭 menus.ts / reload_wheel.ts / craft_bench.ts / roguelike_ui.ts 的重复键鼠轮询）；
 * - 挂载非吞噬全屏事件捕获节点（onTapBegan / onTapEnded / onMouseWheel），彻底根治笔记本触控板轻点与同帧快速单击丢帧问题；
 * - Windows 端自动执行 IME 防护（attachIME → detachIME 触发 SDL_StopTextInput），防止按 Shift 激活中文输入法；
 * - 监听窗口失焦（WindowFocusLost）清零鼠标粘连态，并支持菜单方向键长按连发（Key Repeat）。
 *
 * 注意：Android 手机与 Android 掌机发行包不引入、不打包本模块。
 */

import { App, Keyboard, KeyName, Mouse, Node, Size, Touch, Vec2, View } from "Dora";
import { StageViewport, TargetAttachHooks } from "Script/watch/target_types";

export interface KbmPollerOptions {
    /**
     * Windows 原生版 Dora 默认 Touch::_source = FromTouch（左键合成无 fromMouse 的 Touch 事件），
     * 设为 true 后对所有非触控平台的 TapBegan/TapEnded 均做左键边沿锁存；
     * Web 端同时存在真实触屏，设为 false 仅锁存 touch.fromMouse === true 的真实鼠标点击。
     */
    latchTouchEvents?: boolean;
    /** 是否在 Windows 桌面端自动关闭窗口 IME 上下文（防 Shift 切中文输入法）。 */
    disableIme?: boolean;
}

export interface KbmSample {
    mouseStageX: number;
    mouseStageY: number;
    mouseInsideStage: boolean;
    mouseLeft: boolean;
    mouseLeftPressed: boolean;
    mouseLeftReleased: boolean;
    mouseRight: boolean;
    mouseRightPressed: boolean;
    mouseMoved: boolean;
    mouseClicked: boolean;
    mouseWheelY: number;

    moveX: number;
    moveY: number;
    jump: boolean;
    crouch: boolean;
    crouchPressed: boolean;
    cover: boolean;
    interact: boolean;
    aim: boolean;
    flare: boolean;
    pause: boolean;
    pausePressed: boolean;
    retry: boolean;
    retryTapPressed: boolean;
    toggleView: boolean;
    tab: boolean;
    pick: number;
    anyKb: boolean;
    ledgerTogglePressed: boolean;

    // 菜单 / 换弹盘 / 工台单帧边沿（全端 UI 统一消费，不再各自调 Keyboard）
    navUp: boolean;
    navDown: boolean;
    navLeft: boolean;
    navRight: boolean;
    navConfirm: boolean;
    navBack: boolean;
    uiConfirmWithE: boolean;
    uiBackSpace: boolean;
}

const NAV_REPEAT_DELAY = 0.36;
const NAV_REPEAT_INTERVAL = 0.095;

export class KbmPoller {
    private rawMouseX = -1;
    private rawMouseY = -1;
    private rawMouseInited = false;
    private prevMouseLeft = false;
    private prevMouseRight = false;

    // 鼠标事件锁存（防止同帧按下并抬起导致 Mouse.leftButtonPressed 轮询漏击）
    private latchTouchEvents = true;
    private disableIme = false;
    private pendingLeftPressed = false;
    private pendingLeftHeld = false;
    private pendingLeftReleased = false;
    private deferredLeftRelease = false;
    private pendingRightPressed = false;
    private pendingRightHeld = false;
    private hasPendingClickPos = false;
    private pendingClickX = 0;
    private pendingClickY = 0;
    private pendingWheelY = 0;

    // Alt+Tab 切窗失焦后 Dora 不会清空 UITouchHandler::_leftButtonPressed，失焦重置时屏蔽陈旧按下态
    private ignoreStuckLeft = false;
    private ignoreStuckRight = false;

    // 键盘瞬时边沿锁存（防同帧短按丢失）
    private pendingLedgerToggle = false;
    private pendingPausePressed = false;
    private pendingBackSpacePressed = false;
    private pendingRetryTap = false;

    private prevUp = false;
    private prevDown = false;
    private prevLeft = false;
    private prevRight = false;
    private prevConfirm = false;
    private prevConfirmWithE = false;
    private prevBackSpace = false;
    private prevCrouch = false;
    private prevPause = false;
    private prevRetry = false;
    private prevLedgerV = false;

    private holdUpT = 0;
    private holdDownT = 0;
    private holdLeftT = 0;
    private holdRightT = 0;

    private imeNode: Node.Type | undefined;
    private imeSuppressedOnce = false;

    suppressIme(): void {
        if (!this.disableIme || this.imeNode === undefined) {
            return;
        }
        try {
            // Dora 的 Keyboard::detachIME 只有在 _imeHandler 非空时才派发 SDL_StopTextInput()；
            // 连续执行 attachIME() → detachIME() 可稳定触发 WIN_StopTextInput() 剥离 Windows TSF/HIMC。
            this.imeNode.attachIME();
            this.imeNode.detachIME();
            this.imeSuppressedOnce = true;
        } catch {
            // 无头或精简测试环境可能未挂载完整窗口 IME，静默忽略
        }
    }

    clearTransient(): void {
        this.pendingLeftPressed = false;
        this.pendingLeftHeld = false;
        this.pendingLeftReleased = false;
        this.deferredLeftRelease = false;
        this.pendingRightPressed = false;
        this.pendingRightHeld = false;
        this.hasPendingClickPos = false;
        this.pendingWheelY = 0;
        this.pendingLedgerToggle = false;
        this.pendingPausePressed = false;
        this.pendingBackSpacePressed = false;
        this.pendingRetryTap = false;
        this.holdUpT = 0;
        this.holdDownT = 0;
        this.holdLeftT = 0;
        this.holdRightT = 0;
        this.prevMouseLeft = false;
        this.prevMouseRight = false;
        try {
            if (Mouse.leftButtonPressed) {
                this.ignoreStuckLeft = true;
            }
            if (Mouse.rightButtonPressed) {
                this.ignoreStuckRight = true;
            }
        } catch {
            // ignore
        }
    }

    attach(parent: Node.Type, hooks: TargetAttachHooks, options?: KbmPollerOptions): void {
        this.latchTouchEvents = options?.latchTouchEvents !== false;
        this.disableIme = options?.disableIme === true;

        parent.onKeyDown((key: KeyName) => {
            if (hooks.onFirstUserGesture !== undefined) {
                hooks.onFirstUserGesture();
            }
            if (this.disableIme && !this.imeSuppressedOnce) {
                this.suppressIme();
            }
            if (key === KeyName.F11
                || (key === KeyName.Return
                    && (Keyboard.isKeyPressed(KeyName.LAlt) || Keyboard.isKeyPressed(KeyName.RAlt)))) {
                if (hooks.onToggleFullscreen !== undefined) {
                    hooks.onToggleFullscreen();
                }
                return;
            }
            if (key === KeyName.V) {
                this.pendingLedgerToggle = true;
            } else if (key === KeyName.Escape) {
                this.pendingPausePressed = true;
            } else if (key === KeyName.BackSpace) {
                this.pendingBackSpacePressed = true;
            } else if (key === KeyName.R) {
                this.pendingRetryTap = true;
            }
            if (hooks.onKeyDownEvent !== undefined) {
                hooks.onKeyDownEvent(key as unknown as string);
            }
        });

        // 全屏非吞噬节点：显式设置大尺寸以同时命中 Dora NodeTouchHandler::down/up 与 ::wheel（零尺寸节点收不到 MouseWheel）
        const pointerNode = Node();
        pointerNode.size = Size(16384, 16384);
        pointerNode.anchor = Vec2(0.5, 0.5);
        pointerNode.position = Vec2(0, 0);
        pointerNode.order = 120;
        pointerNode.swallowTouches = false;
        pointerNode.swallowMouseWheel = false;
        pointerNode.touchEnabled = true;
        pointerNode.onTapBegan((touch: Touch.Type) => {
            const isMouse = touch.fromMouse === true;
            if (!isMouse && !this.latchTouchEvents) {
                return;
            }
            if (hooks.onFirstUserGesture !== undefined) {
                hooks.onFirstUserGesture();
            }
            if (this.disableIme && !this.imeSuppressedOnce) {
                this.suppressIme();
            }
            const vl = touch.viewLocation;
            if (isMouse && touch.mouseButton === 2) {
                this.pendingRightPressed = true;
                this.pendingRightHeld = true;
                this.ignoreStuckRight = false;
                this.pendingClickX = vl.x;
                this.pendingClickY = vl.y;
                this.hasPendingClickPos = true;
            } else if (!isMouse || touch.mouseButton === 1) {
                this.pendingLeftPressed = true;
                this.pendingLeftHeld = true;
                this.ignoreStuckLeft = false;
                this.pendingClickX = vl.x;
                this.pendingClickY = vl.y;
                this.hasPendingClickPos = true;
            }
        });
        pointerNode.onTapEnded((touch: Touch.Type) => {
            const isMouse = touch.fromMouse === true;
            if (!isMouse && !this.latchTouchEvents) {
                return;
            }
            if (isMouse && touch.mouseButton === 2) {
                this.pendingRightHeld = false;
            } else if (!isMouse || touch.mouseButton === 1) {
                this.pendingLeftHeld = false;
                this.pendingLeftReleased = true;
            }
        });
        pointerNode.onMouseWheel((delta: Vec2.Type) => {
            this.pendingWheelY += delta.y;
        });
        pointerNode.gslot("AppEvent", (eventType: string) => {
            if (eventType === "WindowFocusLost") {
                this.clearTransient();
                return;
            }
            if (this.disableIme && (eventType === "WindowFocusGained" || eventType === "WindowShown")) {
                this.suppressIme();
            }
        });
        pointerNode.addTo(parent);

        if (this.disableIme) {
            const imeGuard = Node();
            imeGuard.visible = false;
            imeGuard.addTo(parent);
            this.imeNode = imeGuard;
            // 启动窗口完成聚焦后的第 3 与第 15 帧各压制一次 IME，然后自动卸载定时器零开销
            let bootFrames = 0;
            imeGuard.schedule(() => {
                bootFrames += 1;
                if (bootFrames === 3 || bootFrames === 15) {
                    this.suppressIme();
                }
                return bootFrames >= 15;
            });
        }
    }

    private stepRepeat(held: boolean, prevHeld: boolean, holdT: number, dt: number): [boolean, number] {
        if (!held) {
            return [false, 0];
        }
        if (!prevHeld) {
            return [true, 0];
        }
        const nextT = holdT + dt;
        if (nextT >= NAV_REPEAT_DELAY) {
            return [true, NAV_REPEAT_DELAY - NAV_REPEAT_INTERVAL];
        }
        return [false, nextT];
    }

    sample(vp: StageViewport, dt: number = 1 / 60): KbmSample {
        const safeDt = Math.min(0.05, Math.max(0.001, dt));

        // 1. 原始物理鼠标 → 全屏 View 坐标 → 主舞台局部坐标
        const vs = App.visualSize;
        const vw = View.size.width > 0 ? View.size.width : vp.fullW;
        const vh = View.size.height > 0 ? View.size.height : vp.fullH;
        const sw = vs.width > 0 ? vs.width : 1;
        const sh = vs.height > 0 ? vs.height : 1;
        const p = Mouse.position;
        let fullX = p.x * vw / sw;
        let fullY = vh - (p.y * vh / sh);
        if (this.hasPendingClickPos) {
            fullX = this.pendingClickX;
            fullY = this.pendingClickY;
            this.hasPendingClickPos = false;
        }

        const rawLeft = Mouse.leftButtonPressed;
        if (this.ignoreStuckLeft && !rawLeft) {
            this.ignoreStuckLeft = false;
        }
        const polledLeft = this.ignoreStuckLeft ? false : rawLeft;

        const rawRight = Mouse.rightButtonPressed;
        if (this.ignoreStuckRight && !rawRight) {
            this.ignoreStuckRight = false;
        }
        const polledRight = this.ignoreStuckRight ? false : rawRight;

        let mouseLeft: boolean;
        let mouseLeftPressed: boolean;
        let mouseLeftReleased: boolean;
        if (this.pendingLeftPressed) {
            mouseLeftPressed = true;
            mouseLeft = true;
            mouseLeftReleased = false;
            if (this.pendingLeftReleased && !polledLeft && !this.pendingLeftHeld) {
                // 同帧按下并抬起：本帧稳定给出 pressed/held=true，下一帧补发 released=true
                this.deferredLeftRelease = true;
            }
            this.pendingLeftPressed = false;
            this.pendingLeftReleased = false;
        } else if (this.deferredLeftRelease) {
            this.deferredLeftRelease = false;
            mouseLeft = polledLeft || this.pendingLeftHeld;
            mouseLeftPressed = false;
            mouseLeftReleased = !mouseLeft;
        } else {
            mouseLeft = polledLeft || this.pendingLeftHeld;
            mouseLeftPressed = mouseLeft && !this.prevMouseLeft;
            mouseLeftReleased = (!mouseLeft && this.prevMouseLeft) || this.pendingLeftReleased;
            this.pendingLeftReleased = false;
        }

        let mouseRight: boolean;
        let mouseRightPressed: boolean;
        if (this.pendingRightPressed) {
            mouseRightPressed = true;
            mouseRight = true;
            this.pendingRightPressed = false;
        } else {
            mouseRight = polledRight || this.pendingRightHeld;
            mouseRightPressed = mouseRight && !this.prevMouseRight;
        }

        const mouseMoved = this.rawMouseInited
            && (Math.abs(fullX - this.rawMouseX) + Math.abs(fullY - this.rawMouseY) >= 2.0);
        const mouseClicked = mouseLeftPressed || mouseRightPressed;
        const mouseWheelY = this.pendingWheelY;
        this.pendingWheelY = 0;

        this.rawMouseX = fullX;
        this.rawMouseY = fullY;
        this.rawMouseInited = true;
        this.prevMouseLeft = mouseLeft;
        this.prevMouseRight = mouseRight;

        const stX = vp.stageW > 0 ? vp.stageX : 0;
        const stY = vp.stageH > 0 ? vp.stageY : 0;
        const stW = vp.stageW > 0 ? vp.stageW : vw;
        const stH = vp.stageH > 0 ? vp.stageH : vh;
        const mouseStageX = fullX - stX;
        const mouseStageY = fullY - stY;
        const mouseInsideStage = mouseStageX >= 0 && mouseStageX <= stW && mouseStageY >= 0 && mouseStageY <= stH;

        // 2. 单点轮询物理键盘
        const left = Keyboard.isKeyPressed(KeyName.A) || Keyboard.isKeyPressed(KeyName.Left);
        const right = Keyboard.isKeyPressed(KeyName.D) || Keyboard.isKeyPressed(KeyName.Right);
        const up = Keyboard.isKeyPressed(KeyName.W) || Keyboard.isKeyPressed(KeyName.Up);
        const down = Keyboard.isKeyPressed(KeyName.S) || Keyboard.isKeyPressed(KeyName.Down);
        const jump = Keyboard.isKeyPressed(KeyName.Space);
        const crouch = Keyboard.isKeyPressed(KeyName.LCtrl) || Keyboard.isKeyPressed(KeyName.RCtrl) || Keyboard.isKeyPressed(KeyName.C);
        const cover = Keyboard.isKeyPressed(KeyName.LShift) || Keyboard.isKeyPressed(KeyName.RShift);
        const interact = Keyboard.isKeyPressed(KeyName.E);
        const aim = Keyboard.isKeyPressed(KeyName.F);
        const flare = Keyboard.isKeyPressed(KeyName.Q);
        const pause = Keyboard.isKeyPressed(KeyName.Escape);
        const retry = Keyboard.isKeyPressed(KeyName.R);
        const toggleView = Keyboard.isKeyPressed(KeyName.G);
        const tab = Keyboard.isKeyPressed(KeyName.Tab);
        const ledgerV = Keyboard.isKeyPressed(KeyName.V);
        const ret = Keyboard.isKeyPressed(KeyName.Return);
        const bs = Keyboard.isKeyPressed(KeyName.BackSpace);
        const n1 = Keyboard.isKeyPressed(KeyName.Num1);
        const n2 = Keyboard.isKeyPressed(KeyName.Num2);
        const n3 = Keyboard.isKeyPressed(KeyName.Num3);

        const confirm = ret || jump;
        const confirmWithE = confirm || interact;

        const [navUp, nextUpT] = this.stepRepeat(up, this.prevUp, this.holdUpT, safeDt);
        const [navDown, nextDownT] = this.stepRepeat(down, this.prevDown, this.holdDownT, safeDt);
        const [navLeft, nextLeftT] = this.stepRepeat(left, this.prevLeft, this.holdLeftT, safeDt);
        const [navRight, nextRightT] = this.stepRepeat(right, this.prevRight, this.holdRightT, safeDt);
        this.holdUpT = nextUpT;
        this.holdDownT = nextDownT;
        this.holdLeftT = nextLeftT;
        this.holdRightT = nextRightT;

        const navConfirm = confirm && !this.prevConfirm;
        const uiConfirmWithE = confirmWithE && !this.prevConfirmWithE;
        const uiBackSpace = (bs && !this.prevBackSpace) || this.pendingBackSpacePressed;
        const crouchPressed = crouch && !this.prevCrouch;
        const pausePressed = (pause && !this.prevPause) || this.pendingPausePressed;
        const retryTapPressed = (retry && !this.prevRetry) || this.pendingRetryTap;
        const ledgerTogglePressed = (ledgerV && !this.prevLedgerV) || this.pendingLedgerToggle;

        this.pendingBackSpacePressed = false;
        this.pendingPausePressed = false;
        this.pendingRetryTap = false;
        this.pendingLedgerToggle = false;

        this.prevUp = up;
        this.prevDown = down;
        this.prevLeft = left;
        this.prevRight = right;
        this.prevConfirm = confirm;
        this.prevConfirmWithE = confirmWithE;
        this.prevBackSpace = bs;
        this.prevCrouch = crouch;
        this.prevPause = pause;
        this.prevRetry = retry;
        this.prevLedgerV = ledgerV;

        const anyKb = left || right || up || down || jump || crouch || cover
            || interact || aim || flare || pause || retry || toggleView || tab
            || ledgerV || n1 || n2 || n3 || ret || bs;

        return {
            mouseStageX,
            mouseStageY,
            mouseInsideStage,
            mouseLeft,
            mouseLeftPressed,
            mouseLeftReleased,
            mouseRight,
            mouseRightPressed,
            mouseMoved,
            mouseClicked,
            mouseWheelY,
            moveX: (right ? 1 : 0) - (left ? 1 : 0),
            moveY: (down ? 1 : 0) - (up ? 1 : 0),
            jump,
            crouch,
            crouchPressed,
            cover,
            interact,
            aim,
            flare,
            pause,
            pausePressed,
            retry,
            retryTapPressed,
            toggleView,
            tab,
            pick: n1 ? 1 : (n2 ? 2 : (n3 ? 3 : 0)),
            anyKb,
            ledgerTogglePressed,
            navUp,
            navDown,
            navLeft,
            navRight,
            navConfirm,
            navBack: false,
            uiConfirmWithE,
            uiBackSpace,
        };
    }
}
