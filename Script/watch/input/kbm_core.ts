/**
 * 《向西守望》纯键鼠输入驱动内核（仅 Windows 与 Web 目标引入）。
 *
 * 职责：
 * - 单点轮询物理 Mouse 与 Keyboard（彻底消灭 menus.ts / reload_wheel.ts / craft_bench.ts 的重复键鼠轮询）；
 * - 统一产生主舞台坐标下的指针（mx/my/uiX..uiRightPressed）、玩法按键边沿、菜单导航边沿与换弹盘/工台按键边沿；
 * - 挂载 onKeyDown 瞬时边沿锁存（F11 / Alt+Enter 全屏、T 神器、1-3 天赋、E/Space/Esc/R 短按防丢帧）。
 *
 * 注意：Android 手机与 Android 掌机发行包不引入、不打包本模块。
 */

import { App, Keyboard, KeyName, Mouse, Node, View } from "Dora";
import { StageViewport, TargetAttachHooks } from "Script/watch/target_types";

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

    moveX: number;
    moveY: number;
    jump: boolean;
    crouch: boolean;
    cover: boolean;
    interact: boolean;
    aim: boolean;
    flare: boolean;
    pause: boolean;
    retry: boolean;
    toggleView: boolean;
    tab: boolean;
    pick: number;
    anyKb: boolean;

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

export class KbmPoller {
    private rawMouseX = -1;
    private rawMouseY = -1;
    private rawMouseInited = false;
    private prevMouseLeft = false;
    private prevMouseRight = false;

    private prevUp = false;
    private prevDown = false;
    private prevLeft = false;
    private prevRight = false;
    private prevConfirm = false;
    private prevConfirmWithE = false;
    private prevBackSpace = false;

    attach(parent: Node.Type, hooks: TargetAttachHooks): void {
        parent.onKeyDown((key: KeyName) => {
            hooks.onFirstUserGesture();
            if (key === KeyName.F11
                || (key === KeyName.Return
                    && (Keyboard.isKeyPressed(KeyName.LAlt) || Keyboard.isKeyPressed(KeyName.RAlt)))) {
                hooks.onToggleFullscreen();
                return;
            }
            hooks.onKeyDownEvent(key as unknown as string);
        });
    }

    sample(vp: StageViewport): KbmSample {
        // 1. 原始物理鼠标 → 全屏 View 坐标 → 主舞台局部坐标
        const vs = App.visualSize;
        const vw = View.size.width > 0 ? View.size.width : vp.fullW;
        const vh = View.size.height > 0 ? View.size.height : vp.fullH;
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
        const crouch = Keyboard.isKeyPressed(KeyName.LCtrl) || Keyboard.isKeyPressed(KeyName.RCtrl);
        const cover = Keyboard.isKeyPressed(KeyName.LShift) || Keyboard.isKeyPressed(KeyName.RShift);
        const interact = Keyboard.isKeyPressed(KeyName.E);
        const aim = Keyboard.isKeyPressed(KeyName.F);
        const flare = Keyboard.isKeyPressed(KeyName.Q);
        const pause = Keyboard.isKeyPressed(KeyName.Escape);
        const retry = Keyboard.isKeyPressed(KeyName.R);
        const toggleView = Keyboard.isKeyPressed(KeyName.G);
        const tab = Keyboard.isKeyPressed(KeyName.Tab);
        const ret = Keyboard.isKeyPressed(KeyName.Return);
        const bs = Keyboard.isKeyPressed(KeyName.BackSpace);
        const n1 = Keyboard.isKeyPressed(KeyName.Num1);
        const n2 = Keyboard.isKeyPressed(KeyName.Num2);
        const n3 = Keyboard.isKeyPressed(KeyName.Num3);

        const confirm = ret || jump;
        const confirmWithE = confirm || interact;

        const navUp = up && !this.prevUp;
        const navDown = down && !this.prevDown;
        const navLeft = left && !this.prevLeft;
        const navRight = right && !this.prevRight;
        const navConfirm = confirm && !this.prevConfirm;
        const uiConfirmWithE = confirmWithE && !this.prevConfirmWithE;
        const uiBackSpace = bs && !this.prevBackSpace;

        this.prevUp = up;
        this.prevDown = down;
        this.prevLeft = left;
        this.prevRight = right;
        this.prevConfirm = confirm;
        this.prevConfirmWithE = confirmWithE;
        this.prevBackSpace = bs;

        const anyKb = left || right || up || down || jump || crouch || cover
            || interact || aim || flare || pause || retry || toggleView || tab
            || n1 || n2 || n3 || ret || bs;

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
            moveX: (right ? 1 : 0) - (left ? 1 : 0),
            moveY: (down ? 1 : 0) - (up ? 1 : 0),
            jump,
            crouch,
            cover,
            interact,
            aim,
            flare,
            pause,
            retry,
            toggleView,
            tab,
            pick: n1 ? 1 : (n2 ? 2 : (n3 ? 3 : 0)),
            anyKb,
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
