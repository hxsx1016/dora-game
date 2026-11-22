/**
 * 输入层：每帧轮询键盘与鼠标，给出「按住 / 刚按下 / 刚抬起」三种状态。
 *
 * 用轮询而不是 onKeyDown 回调：窗口失焦后用户在外松键，回调收不到抬起事件，
 * 按下态就会卡住；轮询读的是物理键当前状态，切回来自动归零。
 *
 * 与固定步长的接缝（D3）：一帧可能跑 0 到 5 个模拟步，物理键却只在帧首采样一次。
 * 因此按下／松开不是「当帧有效」，而是**锁存到第一个可用模拟步**：
 *   update()  → 采样，把新边沿累积进 pressed / released（不清旧的）
 *   beginStep(i === 0) → 第一步保留累积边沿，后续步清掉
 *   endStep() → 这一步读完，边沿作废
 * 这样 1/30 秒回调跑两步时，按一次 E 只让 Play 读到一次 pressed；
 * 如果本帧凑不满一步（120 Hz 显示器），边沿留到下一次真正推进的模拟步。
 *
 * 鼠标坐标：Mouse.position 是窗口逻辑坐标（左上原点、y 向下），
 * 本层换算成与绘制同一套的局部坐标（左下原点、y 向上）。
 */

import { App, Keyboard, KeyName, Mouse, View } from "Dora";

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
    /** 水平输入：-1 左、0 无、1 右。A/D 与方向键都算。 */
    moveX = 0;
    /** 垂直输入：-1 上、0 无、1 下。只为菜单与爬梯预留。 */
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

    /** 1 / 2 直接选房间；0 表示本帧没选。 */
    pickRoom = 0;

    /** 鼠标局部坐标（左下原点、y 向上），与 DrawNode 绘制坐标一致。 */
    mx = 0;
    my = 0;
    /** 鼠标是否在可视区域内。 */
    inside = true;

    /** 上一帧的鼠标位置，用来算移动量。 */
    mdx = 0;
    mdy = 0;

    private lastPick = 0;

    update(): void {
        this.readKeys();
        this.readMouse();
    }

    /**
     * 进入一个模拟步。first=true 保留本帧（以及之前未消费）的按下／松开边沿；
     * 其余步把它们清掉——同一次按键只属于第一个可用模拟步。
     */
    beginStep(first: boolean): void {
        if (!first) {
            this.clearEdges();
        }
    }

    /** 这一步执行完：边沿已被读取，清掉，下一步不会再看见。 */
    endStep(): void {
        this.clearEdges();
    }

    /** 丢弃所有待消费边沿（重试、切房间后调用）。持续态 held 不受影响。 */
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

    private readKeys(): void {
        const left = Keyboard.isKeyPressed(KeyName.A) || Keyboard.isKeyPressed(KeyName.Left);
        const right = Keyboard.isKeyPressed(KeyName.D) || Keyboard.isKeyPressed(KeyName.Right);
        const up = Keyboard.isKeyPressed(KeyName.W) || Keyboard.isKeyPressed(KeyName.Up);
        const down = Keyboard.isKeyPressed(KeyName.S) || Keyboard.isKeyPressed(KeyName.Down);
        this.moveX = (right ? 1 : 0) - (left ? 1 : 0);
        this.moveY = (down ? 1 : 0) - (up ? 1 : 0);

        this.jump = edge(this.jump, Keyboard.isKeyPressed(KeyName.Space));
        this.crouch = edge(this.crouch,
            Keyboard.isKeyPressed(KeyName.S) || Keyboard.isKeyPressed(KeyName.Down)
            || Keyboard.isKeyPressed(KeyName.LCtrl) || Keyboard.isKeyPressed(KeyName.RCtrl));
        this.cover = edge(this.cover,
            Keyboard.isKeyPressed(KeyName.LShift) || Keyboard.isKeyPressed(KeyName.RShift));
        this.interact = edge(this.interact, Keyboard.isKeyPressed(KeyName.E));
        this.aim = edge(this.aim, Keyboard.isKeyPressed(KeyName.F));
        this.fire = edge(this.fire, Mouse.leftButtonPressed);
        this.flare = edge(this.flare, Keyboard.isKeyPressed(KeyName.Q));
        this.pause = edge(this.pause, Keyboard.isKeyPressed(KeyName.Escape));
        this.retry = edge(this.retry, Keyboard.isKeyPressed(KeyName.R));
        this.toggleView = edge(this.toggleView, Keyboard.isKeyPressed(KeyName.G));
        this.tab = edge(this.tab, Keyboard.isKeyPressed(KeyName.Tab));

        const n1 = Keyboard.isKeyPressed(KeyName.Num1);
        const n2 = Keyboard.isKeyPressed(KeyName.Num2);
        const n3 = Keyboard.isKeyPressed(KeyName.Num3);
        const pick = n1 ? 1 : (n2 ? 2 : (n3 ? 3 : 0));
        // 锁存而不是当帧直出：本帧可能一步都不跑，选房要留到被读走为止。
        if (pick !== 0 && pick !== this.lastPick) {
            this.pickRoom = pick;
        }
        this.lastPick = pick;
    }

    private readMouse(): void {
        const vs = App.visualSize;
        const vw = View.size.width;
        const vh = View.size.height;
        const sw = vs.width > 0 ? vs.width : 1;
        const sh = vs.height > 0 ? vs.height : 1;
        const p = Mouse.position;
        // 窗口坐标 → 视图坐标（左上原点、y 向下）
        const x = p.x * vw / sw;
        const y = p.y * vh / sh;
        // 翻成左下原点、y 向上
        const nx = x;
        const ny = vh - y;
        this.mdx = nx - this.mx;
        this.mdy = ny - this.my;
        this.mx = nx;
        this.my = ny;
        this.inside = x >= 0 && x <= vw && y >= 0 && y <= vh;
    }
}

/** 把「当前按住」折算成带边沿的键状态。按下／松开只置位，不自动清零。 */
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
