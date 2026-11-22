/**
 * D2 试玩层：把 D1 的灰盒数值变成能走、能跳、能蹲、能打的一段。
 *
 * 世界坐标：单位同 rooms.ts，y 向上，地面 y=0，角色位置是「脚底中心」。
 * 绘制坐标：Dora DrawNode 局部坐标，左下原点、y 向上；Rect(x, y, w, h) 以 (x, y)
 * 为左下角向右上扩展。相机把世界线性映射到这块画布上，zoom 固定。
 *
 * 每帧顺序按程序实现稿：输入 → 位移与碰撞 → 机关/命中/交互事件 → 提交快照 → 表现。
 * 本层只管前四步，表现由 draw() 一次画出。
 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { CartSpec, RoomSpec, ScavSpec, SolidSpec, CHECKPOINT_ROOM, OUTSIDE_ROOM } from "Script/watch/rooms";
import { Input } from "Script/watch/input";
import { STEP } from "Script/watch/clock";
import { CALM_REACH, Escort, FEAR_MAX, safeAnchorX } from "Script/watch/escort";

/** 60 拍 = 1 秒；固定步长见 clock.ts。 */
export { STEP };
const GRAVITY = 1000;

/** 小满：高 64、蹲 36、走 160、慢走 80、跳初速 320（顶点 51）。 */
const CHILD_W = 28;
const CHILD_H = 64;
const CHILD_CROUCH_H = 36;
const CHILD_SPEED = 160;
const CHILD_SLOW = 80;
const CHILD_JUMP = 320;

/** 周戍：高 88、速度 264、翻滚 0.35 秒约 97 单位。 */
const SOLDIER_W = 30;
const SOLDIER_H = 88;
const SOLDIER_SPEED = 264;
const ROLL_TIME = 0.35;
const ROLL_SPEED = 280;
/** 翻上矮台：贴着一人高的柜台/台阶时，空格改跳，不再翻滚。 */
const SOLDIER_JUMP = 340;
const LEDGE_RISE = 60;

/** 世界层画布：320×180 逻辑像素，1 美术像素 = 2 世界单位。 */
export const LOGIC_W = 320;
export const LOGIC_H = 180;
export const UNITS_PER_PX = 2;
/** 主地面（世界 y=0）落在画布从底往上 22% 处，上方留给天光与远景。 */
const GROUND_PX = 40;
const CAM_FOLLOW = 9;
const CAM_LOOK_UP = 46;

/** 拉车速度：规划初值 64 单位/秒。 */
const CART_SPEED = 64;
/** 握把触发半径。 */
const CART_REACH = 70;
/** 车身半宽与下缘净高（城外下层阻挡）。 */
const CART_HALF = 24;
const CART_CLEAR = 44;

const INK = Color(232, 232, 228, 255);
const INK_DIM = Color(150, 152, 150, 255);
const BG_VOID = Color(8, 9, 10, 255);
const BG_FAR = Color(24, 26, 28, 255);
const BG_MID = Color(31, 34, 37, 255);
const GROUND = Color(112, 114, 112, 255);
const FLOOR_DECK = Color(66, 70, 72, 255);
const SOLID_FILL = Color(84, 86, 84, 255);
const SOLID_EDGE = Color(126, 130, 126, 255);
const CART_FILL = Color(122, 78, 56, 255);
const CLOTH = Color(178, 52, 46, 255);
const DANGER = Color(150, 54, 48, 46);
const DANGER_LINE = Color(178, 78, 64, 200);
const HOLE_FILL = Color(10, 11, 12, 255);
const SOLDIER_BODY = Color(96, 148, 196, 255);
const SOLDIER_HEAD = Color(206, 214, 220, 255);
const CHILD_BODY = Color(214, 168, 96, 255);
const CHILD_HEAD = Color(232, 214, 186, 255);
const ENEMY_BODY = Color(176, 92, 84, 255);
const ENEMY_DEAD = Color(86, 74, 74, 255);
const CHECK = Color(96, 186, 122, 255);
const STAND = Color(226, 186, 84, 255);
const AIM = Color(236, 236, 232, 230);
const AIM_HIT = Color(236, 96, 84, 255);
/** 村口：软土、砖地、通行线、瓶与拾荒者。 */
const SOFT = Color(96, 78, 58, 70);
const SOFT_LINE = Color(140, 112, 80, 190);
const BRICK = Color(126, 118, 110, 70);
const BRICK_LINE = Color(160, 152, 142, 200);
const PASS = Color(96, 186, 122, 40);
const PASS_LINE = Color(96, 186, 122, 200);
const BOTTLE = Color(120, 186, 160, 255);
const SCAV_BODY = Color(128, 118, 96, 255);
const SCAV_HEAD = Color(196, 182, 158, 255);

/** 轴对齐盒（世界单位）。 */
interface Box {
    x0: number;
    x1: number;
    y0: number;
    y1: number;
    /** 单向平台：只做落脚面，水平不挡人，从下方也不撞头。 */
    passable?: boolean;
}

interface Actor {
    x: number;
    y: number;
    vx: number;
    vy: number;
    w: number;
    h: number;
    onGround: boolean;
    facing: number;
    crouch: boolean;
    rollT: number;
    covered: boolean;
    alive: boolean;
}

interface Enemy {
    x: number;
    y: number;
    w: number;
    h: number;
    alive: boolean;
    hitT: number;
}

interface Camera {
    x: number;
    y: number;
}

/** 当前窗口下的像素视口：整数倍放大 + 居中（黑边留在两侧）。 */
export interface Viewport {
    zoom: number;
    ox: number;
    oy: number;
}

/** 取能容纳 320×180 画布的最大整数倍，并把画布居中。 */
export function computeViewport(w: number, h: number): Viewport {
    let zoom = Math.floor(Math.min(w / LOGIC_W, h / LOGIC_H));
    if (zoom < 1) {
        zoom = 1;
    }
    return {
        zoom: zoom,
        ox: Math.floor((w - LOGIC_W * zoom) / 2),
        oy: Math.floor((h - LOGIC_H * zoom) / 2),
    };
}

/** 一次命中判定的结果，供表现层画弹道与反馈。 */
interface Trace {
    x0: number;
    y0: number;
    x1: number;
    y1: number;
    hit: boolean;
}

export class Play {
    room: RoomSpec;
    player: Actor;
    partner: Actor;
    cam: Camera;
    enemies: Enemy[] = [];
    boxes: Box[] = [];
    floors: Box[] = [];
    /** 已提交的检查点世界 x；-1 表示还没提交。 */
    checkpoint = -1;
    /** 帧内反馈，给 HUD 用。 */
    flash = "";
    flashT = 0;
    /** 最近一次弹道，画 0.12 秒。 */
    trace: Trace | undefined;
    traceT = 0;
    /** 城外拉车焦点是否亮起。 */
    focusCart = false;
    /** E 按下的次数与最近一次的时间，用来做「敲两下」。 */
    knocks = 0;
    knockT = 0;
    /** 护送状态、恐惧格与安抚进度。 */
    escort: Escort;
    /** 车轴当前世界 x：检查站 640→768，城外 304→432。 */
    cartAxle = 0;
    /** 车已推进到底（车轮落窝）。 */
    cartDocked = false;
    /** 周戍是否正握着车把。 */
    gripping = false;
    /** 双人出口是否同时满足「车到位 + 两人都进区」。 */
    gateOpen = false;
    /** 本步 E 是否已经给安抚用掉，避免同一步又敲木板。 */
    calmConsumed = false;
    /** 危险事件的递增 id，同一 id 只结算一次。 */
    nextDangerId = 1;
    /** 要切到哪个房间；app 读走后置空。 */
    wantRoom = "";
    /** 切场要带过去的车位。 */
    carryCartAxle = -1;
    carryCartDocked = false;
    /** 提交检查点时的车位，供复演记录。 */
    checkpointCartAxle = -1;

    // —— 村口 ——
    /** 手上是否有瓶。 */
    hasBottle = false;
    /** 投出的瓶子（飞行中）。 */
    bottleFly: { x: number; y: number; vx: number; vy: number } | undefined;
    /** 最近一次落点与余音计时。 */
    bottleLandX = -1;
    bottleLandT = 0;
    /** 按住 F 的蓄力时长（D3 只用来画准星，不影响手感）。 */
    aimHold = 0;
    /** 拾荒者位置与状态机。 */
    scavX = 0;
    scavDir = 1;
    scavState: "patrol" | "turn" | "walk" | "stall" | "back" = "patrol";
    scavT = 0;
    scavTargetX = 0;
    /** 是否已过第一院通行线。 */
    passed = false;
    paused = false;
    /** 累计模拟步，用来做与帧率无关的计时。 */
    ticks = 0;
    /** 当前窗口的像素视口，绘制前算一次。 */
    view: Viewport = { zoom: 1, ox: 0, oy: 0 };
    /** 准星在画布上的位置（局部、左下原点），由 app 每帧写入。 */
    aimX = 0;
    aimY = 0;
    /** 最近一次绘制的画布尺寸，供屏幕↔世界换算。 */
    viewW = 0;
    viewH = 0;

    constructor(room: RoomSpec, resume?: { checkpoint: number }) {
        this.room = room;
        this.cam = { x: (room.minX + room.maxX) / 2, y: room.height / 2 };
        this.buildWorld();
        this.player = makeActor(room, room.key === "checkpoint" ? 1 : 0);
        this.partner = makeActor(room, room.key === "checkpoint" ? 0 : -1);
        this.cam.x = this.player.x;
        this.cam.y = this.player.y + CAM_LOOK_UP;
        this.cartAxle = room.cart.startX;
        this.escort = new Escort(safeAnchorX(room.marks));
        this.scavX = room.scavenger !== undefined ? room.scavenger.x0 : 0;
        this.buildEnemies();
        // 重试/复演：洞后检查点已提交则车已在 432 落窝，小满回到洞后。
        if (resume !== undefined && resume.checkpoint > 0) {
            this.checkpoint = resume.checkpoint;
            if (room.key === "outside" && resume.checkpoint >= 380) {
                this.cartAxle = room.cart.endX;
                this.cartDocked = true;
                // 恢复到下层洞后安全点：脚踩地面 y=0、站 380（还没到 388 的切线）。
                // 车轴同步到 432，松键空转也不会自己进村，得自己走过 388。
                this.player.x = 380;
                this.player.y = 0;
                this.player.vy = 0;
                this.player.onGround = true;
                this.cam.x = this.player.x;
                this.cam.y = this.player.y + CAM_LOOK_UP;
            }
        }
    }

    /** 把房间数据转成碰撞盒；stairs 按级拆成可站立的台阶。 */
    private buildWorld(): void {
        const room = this.room;
        this.boxes = [];
        this.floors = [];
        let i = 0;
        for (i = 0; i < room.floors.length; i++) {
            const f = room.floors[i];
            this.floors.push({ x0: f.x0, x1: f.x1, y0: f.y, y1: f.y });
        }
        for (i = 0; i < room.solids.length; i++) {
            const s: SolidSpec = room.solids[i];
            this.boxes.push({ x0: s.x, x1: s.x + s.w, y0: s.y, y1: s.y + s.h });
        }
        for (i = 0; i < room.stairs.length; i++) {
            const st = room.stairs[i];
            const n = st.steps + 1;
            const stepW = (st.x1 - st.x0) / n;
            let k = 0;
            for (k = 0; k < n; k++) {
                const y = st.y0 + (st.y1 - st.y0) * k / (n - 1);
                const x0 = st.x0 + stepW * k;
                // 台阶做成单向平台：从台面下来能踩，从地面走过不会被挡住，也不会从下方撞头。
                this.boxes.push({ x0: x0, x1: x0 + stepW, y0: -8, y1: y, passable: true });
            }
        }
    }

    private buildEnemies(): void {
        this.enemies = [];
        if (this.room.key !== "checkpoint") {
            return;
        }
        this.enemies.push({ x: 430, y: 0, w: 26, h: 84, alive: true, hitT: 0 });
        this.enemies.push({ x: 505, y: 0, w: 26, h: 84, alive: true, hitT: 0 });
    }

    /** 推进一帧。input 已在本帧刷新过。 */
    update(dt: number, input: Input): void {
        if (input.pause.pressed) {
            this.paused = !this.paused;
        }
        if (this.flashT > 0) {
            this.flashT -= dt;
            if (this.flashT <= 0) {
                this.flash = "";
            }
        }
        if (this.traceT > 0) {
            this.traceT -= dt;
            if (this.traceT <= 0) {
                this.trace = undefined;
            }
        }
        if (this.paused) {
            this.updateCamera(dt);
            return;
        }

        this.ticks += 1;
        const p = this.player;
        this.stepPlayer(p, dt, input);
        this.stepEscort(dt, input);
        this.stepEnemies(dt);
        this.stepVillage(dt, input);
        this.stepInteract(dt, input);
        this.updateGate();
        this.updateCamera(dt);
    }

    /** 面前是否有一人高的台面：是则空格改成翻上去，平地仍是翻滚。 */
    private nearLowLedge(a: Actor): boolean {
        const reach = 26;
        const x0 = a.facing > 0 ? a.x + a.w / 2 : a.x - a.w / 2 - reach;
        const x1 = x0 + reach;
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.x1 <= x0 || b.x0 >= x1) {
                continue;
            }
            const rise = b.y1 - a.y;
            if (rise > 0 && rise <= LEDGE_RISE) {
                return true;
            }
        }
        return false;
    }

    private stepPlayer(a: Actor, dt: number, input: Input): void {
        if (!a.alive) {
            return;
        }
        const isChild = this.room.key !== "checkpoint";
        // 安抚的 60 拍里周戍蹲着不动，交火与移动都停。
        if (!isChild && this.escort.state === "calming") {
            a.crouch = false;
            a.h = SOLDIER_H;
            a.vx = 0;
            this.fallY(a, dt);
            return;
        }
        a.crouch = isChild && input.crouch.held && a.onGround;
        a.h = a.crouch ? CHILD_CROUCH_H : (isChild ? CHILD_H : SOLDIER_H);
        a.covered = !isChild && input.cover.held;

        // 翻滚：周戍按下空格，0.35 秒内按固定速度冲出去，期间不能改向
        if (a.rollT > 0) {
            a.rollT -= dt;
            a.vx = a.facing * ROLL_SPEED;
            this.slideX(a, a.vx * dt);
            this.fallY(a, dt);
            if (a.rollT <= 0) {
                this.flashSet("翻滚结束", 0.5);
            }
            return;
        }

        if (!isChild && input.jump.pressed && a.onGround) {
            if (input.moveX !== 0) {
                a.facing = input.moveX > 0 ? 1 : -1;
            }
            // 贴着一人高的柜台/台阶时改成跳上去；平地上仍是翻滚。
            if (this.nearLowLedge(a)) {
                a.vy = SOLDIER_JUMP;
                a.onGround = false;
                this.flashSet("翻上去", 0.3);
                return;
            }
            a.rollT = ROLL_TIME;
            this.flashSet("翻滚", 0.3);
            return;
        }

        let speed = isChild ? CHILD_SPEED : SOLDIER_SPEED;
        if (isChild) {
            if (input.cover.held) {
                speed = CHILD_SLOW;
            }
            if (a.crouch) {
                speed = CHILD_SLOW;
            }
        } else if (a.covered) {
            speed = SOLDIER_SPEED * 0.45;
        }

        // 握车把时人由车带着走，自己按方向键不再叠加位移。
        const dir = this.gripping ? 0 : input.moveX;
        if (dir !== 0) {
            a.facing = dir > 0 ? 1 : -1;
        }
        a.vx = dir * speed;

        // 小满跳跃：地面 + 未蹲
        if (isChild && input.jump.pressed && a.onGround && !a.crouch) {
            a.vy = CHILD_JUMP;
            a.onGround = false;
            this.flashSet("跳", 0.25);
        }

        this.slideX(a, a.vx * dt);
        this.fallY(a, dt);

        // 点射：周戍按住左键，朝准星打一条线
        if (!isChild && input.fire.pressed) {
            this.shoot(a);
        }
    }

    /** 未操控的一方：站在出生点，跟着镜头外不动。D3 再接跟随与护送。 */
    private stepPartner(p: Actor, dt: number): void {
        const a = this.partner;
        if (!a.alive) {
            return;
        }
        a.crouch = false;
        a.h = a.w === CHILD_W ? CHILD_H : SOLDIER_H;
        a.vx = 0;
        this.fallY(a, dt);
    }

    /**
     * 小满的跟随与护送：目标点由 Escort 出，位移走统一的 slideX / fallY。
     * 检查站之外的房间没有护送数据，保持原地落体。
     */
    private stepEscort(dt: number, input: Input): void {
        const a = this.partner;
        if (!a.alive) {
            return;
        }
        if (this.room.key !== "checkpoint") {
            a.vx = 0;
            this.fallY(a, dt);
            return;
        }
        const p = this.player;
        const dist = Math.abs(p.x - a.x);
        this.calmConsumed = this.escort.update(input, p.x, p.facing, a.x, dist);
        a.crouch = this.escort.crouchPose;
        a.h = a.crouch ? CHILD_CROUCH_H : CHILD_H;
        const dir = this.escort.moveDir(a.x);
        a.vx = dir * CHILD_SPEED;
        if (dir !== 0) {
            a.facing = dir;
            const before = a.x;
            this.slideX(a, dir * CHILD_SPEED * dt);
            // 跟随时撞到矮台（柜台、台阶）：自己跳上去，不卡在台前。
            if (a.onGround && Math.abs(a.x - before) < 0.4) {
                a.vy = CHILD_JUMP;
                a.onGround = false;
            }
        }
        this.fallY(a, dt);
    }

    /** 出口：车落窝、两人都进 [792,928] 才开。 */    private updateGate(): void {
        if (this.room.key !== "checkpoint") {
            this.gateOpen = false;
            return;
        }
        const inZone = (x: number): boolean => x >= 792 && x <= 928;
        this.gateOpen = this.cartDocked && inZone(this.player.x) && inZone(this.partner.x);
    }

    private stepEnemies(dt: number): void {
        let i = 0;
        for (i = 0; i < this.enemies.length; i++) {
            const e = this.enemies[i];
            if (e.hitT > 0) {
                e.hitT -= dt;
            }
        }
    }

    private stepInteract(dt: number, input: Input): void {
        const p = this.player;
        const calmUsed = this.calmConsumed;
        this.calmConsumed = false;
        this.focusCart = false;
        if (this.room.key === "outside") {
            const c = this.room.cart;
            const dx = p.x - (this.cartAxle + c.handleOffset);
            const dy = p.y - c.baseY;
            this.focusCart = dx * dx + dy * dy < CART_REACH * CART_REACH;
        }
        this.stepCart(dt, input);

        // E 先给安抚；同一只 E 不再触发敲木板。
        if (calmUsed) {
            this.flashSet("安抚 · 敲两下", 0.8);
        } else if (input.interact.pressed && !this.gripping && this.room.key !== "village") {
            if (this.knockT > 0) {
                this.knocks += 1;
            } else {
                this.knocks = 1;
            }
            this.knockT = 1.2;
            if (this.knocks >= 2) {
                this.flashSet("敲两下", 0.8);
                this.knocks = 0;
            } else {
                this.flashSet("敲一下", 0.5);
            }
        } else if (this.knockT > 0) {
            this.knockT -= dt;
            if (this.knockT <= 0) {
                this.knocks = 0;
            }
        }

        // 本地检查点：小满或周戍踩到 kind 0 的标记就提交
        let i = 0;
        for (i = 0; i < this.room.marks.length; i++) {
            const m = this.room.marks[i];
            if (m.kind !== 0) {
                continue;
            }
            const subjects: Actor[] = [this.partner, this.player];
            let k = 0;
            for (k = 0; k < subjects.length; k++) {
                const s = subjects[k];
                if (!s.alive) {
                    continue;
                }
                const dx = s.x - m.x;
                const dy = s.y - m.y;
                if (dx * dx + dy * dy < 26 * 26 && this.checkpoint !== m.x) {
                    this.checkpoint = m.x;
                    this.checkpointCartAxle = this.cartAxle;
                    if (this.cartDocked) {
                        this.flashSet("检查点 · 车已落窝", 1.0);
                    } else {
                        this.flashSet("检查点 · 车还没到位", 1.0);
                    }
                }
            }
        }

        this.checkCarryGate();
    }

    /** 村口：拾瓶、蓄力、投掷、拾荒者与通行线。 */
    private stepVillage(dt: number, input: Input): void {
        if (this.room.key !== "village") {
            return;
        }
        const p = this.player;
        const bottle = this.room.bottle;
        const scav = this.room.scavenger;

        // 点 E 拾瓶
        if (!this.hasBottle && bottle !== undefined) {
            const dx = p.x - bottle.x;
            const dy = p.y + p.h * 0.5 - bottle.y;
            if (dx * dx + dy * dy < 56 * 56 && input.interact.pressed) {
                this.hasBottle = true;
                this.flashSet("拾起瓶子", 0.8);
            }
        }

        // 按住 F 瞄，松手才投
        if (this.hasBottle) {
            if (input.aim.held) {
                this.aimHold += dt;
                if (this.aimHold > 1.2) {
                    this.aimHold = 1.2;
                }
            } else if (input.aim.released) {
                const aim = screenToWorld(this.aimX, this.aimY, this.cam, this.view);
                this.throwBottle(aim.x, aim.y);
                this.aimHold = 0;
            }
        } else {
            this.aimHold = 0;
        }

        // 瓶子飞行，触地才发声
        const fly = this.bottleFly;
        if (fly !== undefined) {
            fly.vy -= GRAVITY * dt;
            fly.x += fly.vx * dt;
            fly.y += fly.vy * dt;
            const g = this.groundAt(fly.x, fly.y + 4, 3);
            if (fly.y <= g) {
                this.bottleFly = undefined;
                this.bottleLandX = fly.x;
                this.bottleLandT = 0.9;
                this.hearBottle(fly.x);
            }
        }
        if (this.bottleLandT > 0) {
            this.bottleLandT -= dt;
        }

        if (scav !== undefined) {
            this.stepScav(dt, scav);
        }

        const line = this.room.passLine;
        if (line !== undefined && !this.passed && p.x >= line) {
            this.passed = true;
            this.flashSet("过了第一院 · 通行线 440", 1.4);
        }
    }

    /** 固定飞行时间反解初速，落点跟着准星走。 */
    private throwBottle(tx: number, ty: number): void {
        const p = this.player;
        const x0 = p.x + p.facing * 10;
        const y0 = p.y + p.h * 0.7;
        const T = 0.62;
        const vx = (tx - x0) / T;
        const vy = (ty - y0 + 0.5 * GRAVITY * T * T) / T;
        this.bottleFly = { x: x0, y: y0, vx: vx, vy: vy };
        this.hasBottle = false;
        this.flashSet("投出", 0.4);
    }

    /** 落地才结算听觉：射程内才转头。 */
    private hearBottle(x: number): void {
        const s = this.room.scavenger;
        if (s === undefined) {
            return;
        }
        if (Math.abs(x - this.scavX) > s.range) {
            this.flashSet("落地 · 他没听见", 0.6);
            return;
        }
        this.scavState = "turn";
        this.scavT = s.hearTicks;
        this.scavTargetX = x;
        this.flashSet("砖地一响 · 他转头", 0.9);
    }

    /** 拾荒者：巡逻 → 转头 18 拍 → 赶到落点 → 停 120 拍 → 走回巡逻段。 */
    private stepScav(dt: number, s: ScavSpec): void {
        if (this.scavState === "turn") {
            this.scavT -= 1;
            if (this.scavT <= 0) {
                this.scavState = "walk";
            }
            return;
        }
        if (this.scavState === "walk") {
            const d = this.scavTargetX - this.scavX;
            if (Math.abs(d) < 4) {
                this.scavState = "stall";
                this.scavT = s.stallTicks;
                return;
            }
            this.scavX += (d > 0 ? 1 : -1) * s.approachSpeed * dt;
            return;
        }
        if (this.scavState === "stall") {
            this.scavT -= 1;
            if (this.scavT <= 0) {
                this.scavState = "back";
            }
            return;
        }
        if (this.scavState === "back") {
            const home = Math.max(s.x0, Math.min(s.x1, this.scavX));
            if (Math.abs(home - this.scavX) < 2) {
                this.scavState = "patrol";
                return;
            }
            this.scavX += (home > this.scavX ? 1 : -1) * s.approachSpeed * dt;
            return;
        }
        this.scavX += this.scavDir * s.patrolSpeed * dt;
        if (this.scavX >= s.x1) {
            this.scavX = s.x1;
            this.scavDir = -1;
        } else if (this.scavX <= s.x0) {
            this.scavX = s.x0;
            this.scavDir = 1;
        }
    }

    /**
     * 车把：E 抓住，A/D 推拉，松手立即停；到端位写 dock。
     * 人跟着车把一起走，走不动就脱手。
     */
    private stepCart(dt: number, input: Input): void {
        const p = this.player;
        const c = this.room.cart;
        const handleX = this.cartAxle + c.handleOffset;

        if (this.gripping) {
            if (!input.interact.held) {
                this.gripping = false;
                this.flashSet("松开车把", 0.4);
                return;
            }
        } else {
            if (!input.interact.pressed) {
                return;
            }
            if (Math.abs(p.x - handleX) > CART_REACH || Math.abs(p.y - c.baseY) > 40) {
                return;
            }
            this.gripping = true;
            this.flashSet("握住车把", 0.4);
            return;
        }

        if (this.cartDocked) {
            return;
        }
        const dir = input.moveX;
        if (dir === 0) {
            return;
        }
        const lo = Math.min(c.startX, c.endX);
        const hi = Math.max(c.startX, c.endX);
        let next = this.cartAxle + dir * CART_SPEED * dt;
        if (next < lo) {
            next = lo;
        }
        if (next > hi) {
            next = hi;
        }
        const delta = next - this.cartAxle;
        if (delta === 0) {
            return;
        }
        this.cartAxle = next;
        p.x += delta;
        p.facing = dir > 0 ? 1 : -1;
        this.slideX(p, 0);
        if (Math.abs(p.x - (this.cartAxle + c.handleOffset)) > CART_REACH) {
            this.gripping = false;
            this.flashSet("跟不上了，脱手", 0.6);
            return;
        }
        if (Math.abs(this.cartAxle - c.endX) < 0.01) {
            this.cartDocked = true;
            this.gripping = false;
            this.flashSet("车轮落窝", 1.2);
        } else if (Math.abs(this.cartAxle - c.startX) < 0.01) {
            this.flashSet("车轮回到起点", 0.5);
        }
    }

    /**
     * 切场条件：检查站要车落窝且两人都在出口区；城外要洞后检查点已提交并再往右跨到 388。
     * D3 用明确的开发切场点，D4 再接墙根小路与地图加宽。
     */
    private checkCarryGate(): void {
        if (this.room.key === "checkpoint") {
            if (this.gateOpen && this.player.x >= 900) {
                this.carryCartAxle = this.cartAxle;
                this.carryCartDocked = this.cartDocked;
                this.wantRoom = "outside";
                this.flashSet("过城门 · 城外", 1.2);
            }
            return;
        }
        if (this.room.key === "outside") {
            // 周戍 88 高过不了 44 的拱，切场由被护送的小满触发。
            if (this.checkpoint >= 380 && this.player.x >= 388) {
                this.carryCartAxle = this.cartAxle;
                this.carryCartDocked = this.cartDocked;
                this.wantRoom = "village";
                this.flashSet("洞后 · 墙根小路", 1.2);
            }
        }
    }

    /** 点射：从枪口到准星拉一条线，命中最近的敌人；被实体挡住则打空。 */
    private shoot(a: Actor): void {
        const ox = a.x + a.facing * 8;
        const oy = a.y + a.h * 0.72;
        // 准星在世界里的位置由 app 传进来，这里直接用相机反算
        const aim = screenToWorld(this.aimX, this.aimY, this.cam, this.view);
        let dx = aim.x - ox;
        let dy = aim.y - oy;
        const len = Math.sqrt(dx * dx + dy * dy);
        if (len < 0.001) {
            dx = a.facing;
            dy = 0;
        } else {
            dx = dx / len;
            dy = dy / len;
        }
        if (dx !== 0) {
            a.facing = dx > 0 ? 1 : -1;
        }

        const hitEnemy = this.raycast(ox, oy, dx, dy, true);
        const hitWall = this.raycast(ox, oy, dx, dy, false);
        const tEnemy = hitEnemy.t;
        const tWall = hitWall.t;
        const hit = tEnemy >= 0 && (tWall < 0 || tEnemy <= tWall);
        const t = hit ? tEnemy : (tWall >= 0 ? tWall : 700);

        this.trace = { x0: ox, y0: oy, x1: ox + dx * t, y1: oy + dy * t, hit: hit };
        this.traceT = 0.12;
        this.applyFireDanger(ox);
        if (hit) {
            const i = hitEnemy.index;
            const e = this.enemies[i];
            e.alive = false;
            e.hitT = 0.4;
            this.flashSet("命中", 0.6);
        } else {
            this.flashSet("打空", 0.35);
        }
    }

    /** 把一次开火派发成危险事件；是否真的吓到她由 childExposed 判。 */
    private applyFireDanger(shotX: number): void {
        if (this.room.key !== "checkpoint" || !this.partner.alive) {
            return;
        }
        let dangerX = shotX;
        let best = -1;
        let bestD = 1e9;
        let i = 0;
        for (i = 0; i < this.enemies.length; i++) {
            const e = this.enemies[i];
            if (!e.alive) {
                continue;
            }
            const d = Math.abs(e.x - this.partner.x);
            if (d < bestD) {
                bestD = d;
                best = i;
            }
        }
        if (best >= 0) {
            dangerX = this.enemies[best].x;
        }
        const exposed = this.childExposed(dangerX);
        const before = this.escort.fear;
        const after = this.escort.applyDanger(this.nextDangerId, exposed, this.partner.x);
        this.nextDangerId += 1;
        if (after > before) {
            this.flashSet(`小满受惊 ${after}/${FEAR_MAX}`, 1.0);
        } else if (!exposed) {
            this.flashSet("枪声没够到她", 0.5);
        }
    }

    /** 有效危险：柜台后不算、危险段外不算、周戍挡在中间不算。 */
    private childExposed(dangerX: number): boolean {
        const c = this.partner;
        if (!c.alive) {
            return false;
        }
        if (c.x > 240 && c.x < 340) {
            return false;
        }
        if (c.x < 380 || c.x > 560) {
            return false;
        }
        const toDanger = dangerX - c.x;
        const toPlayer = this.player.x - c.x;
        if (toDanger * toPlayer > 0 && Math.abs(toPlayer) < Math.abs(toDanger)) {
            return false;
        }
        return true;
    }

    /** 射线求交：enemies=true 打敌人，false 打实体与地面。返回命中距离与敌人下标。 */
    private raycast(ox: number, oy: number, dx: number, dy: number, enemies: boolean): { t: number; index: number } {
        let best = -1;
        let bestI = -1;
        let i = 0;
        if (enemies) {
            for (i = 0; i < this.enemies.length; i++) {
                const e = this.enemies[i];
                if (!e.alive) {
                    continue;
                }
                const t = hitBox(ox, oy, dx, dy, e.x - e.w / 2, e.x + e.w / 2, e.y, e.y + e.h);
                if (t >= 0 && (best < 0 || t < best)) {
                    best = t;
                    bestI = i;
                }
            }
            return { t: best, index: bestI };
        }
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            const t = hitBox(ox, oy, dx, dy, b.x0, b.x1, b.y0, b.y1);
            if (t >= 0 && (best < 0 || t < best)) {
                best = t;
            }
        }
        // 地面 y=0 也是一条挡线
        if (dy < 0) {
            const t = (0 - oy) / dy;
            if (t >= 0 && (best < 0 || t < best)) {
                best = t;
            }
        }
        return { t: best, index: -1 };
    }

    /** 水平位移 + 实体/拱洞阻挡。 */
    private slideX(a: Actor, dx: number): void {
        let nx = a.x + dx;
        const half = a.w / 2;
        const room = this.room;
        nx = Math.max(room.minX + half, Math.min(room.maxX - half, nx));
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.passable === true) {
                continue;
            }
            if (a.y + a.h <= b.y0 + 0.001 || a.y >= b.y1 - 0.001) {
                continue;
            }
            if (nx + half > b.x0 && nx - half < b.x1) {
                if (a.x <= b.x0) {
                    nx = b.x0 - half;
                } else if (a.x >= b.x1) {
                    nx = b.x1 + half;
                } else {
                    nx = a.x;
                }
            }
        }
        // 城外：车身下缘在下层形成随车移动的阻挡（离地 0..44），车拉走才让开洞口。
        if (this.room.key === "outside" && a.y < CART_CLEAR - 0.001) {
            const bx0 = this.cartAxle - CART_HALF;
            const bx1 = this.cartAxle + CART_HALF;
            if (nx + half > bx0 && nx - half < bx1) {
                if (a.x <= bx0) {
                    nx = bx0 - half;
                } else if (a.x >= bx1) {
                    nx = bx1 + half;
                } else {
                    nx = a.x;
                }
            }
        }
        // 拱洞（低洞）：身高超出净空就进不去。
        // 已经在洞里的人（例如蹲着进来后站起来）允许朝任一侧走出去，
        // 否则会被永久卡在洞内。
        // 只有脚底低于拱顶时才会被拱口挡；站在上层台面（y=96）时拱洞在脚下，不该拦人。
        const arch = room.arch;
        if (arch.h > 0 && a.y < arch.y + arch.h - 0.001 && a.y + a.h > arch.y + arch.h + 0.001) {
            const insideNow = a.x > arch.x0 && a.x < arch.x1;
            if (!insideNow && nx + half > arch.x0 && nx - half < arch.x1) {
                if (a.x <= arch.x0) {
                    nx = arch.x0 - half;
                } else if (a.x >= arch.x1) {
                    nx = arch.x1 + half;
                }
            }
        }
        a.x = nx;
    }

    /** 垂直位移：重力、落地、撞头。 */
    private fallY(a: Actor, dt: number): void {
        a.vy -= GRAVITY * dt;
        if (a.vy < -900) {
            a.vy = -900;
        }
        let ny = a.y + a.vy * dt;
        const half = a.w / 2;
        if (a.vy <= 0) {
            const ground = this.groundAt(a.x, a.y + 0.5, half);
            if (ny <= ground) {
                ny = ground;
                a.vy = 0;
                a.onGround = true;
            } else {
                a.onGround = false;
            }
        } else {
            a.onGround = false;
            let i = 0;
            for (i = 0; i < this.boxes.length; i++) {
                const b = this.boxes[i];
                if (b.passable === true) {
                    continue;
                }
                if (a.x + half <= b.x0 || a.x - half >= b.x1) {
                    continue;
                }
                if (b.y0 >= a.y + a.h - 0.5 && ny + a.h > b.y0) {
                    ny = b.y0 - a.h;
                    a.vy = 0;
                }
            }
        }
        a.y = ny;
    }

    /** 当前 x 处、不高于 ceiling 的最高落脚面。 */
    private groundAt(x: number, ceiling: number, half: number): number {
        let g = -9999;
        let i = 0;
        for (i = 0; i < this.floors.length; i++) {
            const f = this.floors[i];
            if (x + half > f.x0 && x - half < f.x1 && f.y1 <= ceiling && f.y1 > g) {
                g = f.y1;
            }
        }
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (x + half > b.x0 && x - half < b.x1 && b.y1 <= ceiling && b.y1 > g) {
                g = b.y1;
            }
        }
        return g;
    }

    private updateCamera(dt: number): void {
        const p = this.player;
        const tx = p.x + p.facing * 30;
        const ty = p.y + CAM_LOOK_UP;
        const k = Math.min(1, CAM_FOLLOW * dt);
        this.cam.x = this.cam.x + (tx - this.cam.x) * k;
        this.cam.y = this.cam.y + (ty - this.cam.y) * k;
    }

    /** 相机按画布尺寸钳制，保证看不到房间外。由绘制前调用。 */
    clampCamera(w: number, h: number): void {
        const room = this.room;
        const halfW = (LOGIC_W * UNITS_PER_PX) / 2;
        const spanX = room.maxX - room.minX;
        if (spanX <= halfW * 2) {
            this.cam.x = (room.minX + room.maxX) / 2;
        } else {
            this.cam.x = Math.max(room.minX + halfW, Math.min(room.maxX - halfW, this.cam.x));
        }
        // 竖向：主地面固定在画布下部，房间更高时不再额外抬高相机。
        const camY = (LOGIC_H / 2 - GROUND_PX) * UNITS_PER_PX;
        const spanY = room.height;
        const halfH = (LOGIC_H * UNITS_PER_PX) / 2;
        if (spanY <= halfH * 2) {
            this.cam.y = camY;
        } else {
            this.cam.y = Math.max(camY, Math.min(camY + (spanY - halfH * 2), this.cam.y));
        }
    }

    private flashSet(text: string, t: number): void {
        this.flash = text;
        this.flashT = t;
    }

    /** 一行状态文字。 */
    statusText(): string {
        const p = this.player;
        const parts: string[] = [];
        if (this.room.key === "village") {
            parts.push("小满 x=" + Math.round(p.x) + " y=" + Math.round(p.y));
            parts.push(p.crouch ? "蹲" : "站");
            if (this.hasBottle) {
                parts.push("有瓶");
            } else if (this.bottleFly !== undefined) {
                parts.push("瓶在飞");
            } else {
                parts.push("空手");
            }
            parts.push("拾荒者 " + this.scavLabel() + " @" + Math.round(this.scavX));
            if (this.passed) {
                parts.push("已过通行线");
            }
            if (this.paused) {
                parts.push("已暂停");
            }
            return parts.join(" · ");
        }

        const isChild = this.room.key !== "checkpoint";
        const who = isChild ? "小满" : "周戍";
        parts.push(who + " x=" + Math.round(p.x) + " y=" + Math.round(p.y));
        if (isChild) {
            parts.push(p.crouch ? "蹲" : "站");
            parts.push("高 " + Math.round(p.h));
            parts.push("车轴 " + Math.round(this.cartAxle));
        } else {
            parts.push(p.covered ? "贴掩体" : "无掩体");
            if (p.rollT > 0) {
                parts.push("翻滚中");
            }
            let alive = 0;
            let i = 0;
            for (i = 0; i < this.enemies.length; i++) {
                if (this.enemies[i].alive) {
                    alive += 1;
                }
            }
            parts.push("敌 " + alive + "/" + this.enemies.length);
            parts.push("车轴 " + Math.round(this.cartAxle));
            parts.push(this.gateOpen ? "出口开" : "出口关");
            parts.push("恐惧 " + this.escort.fear + "/" + FEAR_MAX);
        }
        if (this.checkpoint >= 0) {
            parts.push("检查点 " + Math.round(this.checkpoint));
        }
        if (this.paused) {
            parts.push("已暂停");
        }
        return parts.join(" · ");
    }

    /** 拾荒者状态的中文短标签。 */
    scavLabel(): string {
        if (this.scavState === "turn") {
            return "转头";
        }
        if (this.scavState === "walk") {
            return "赶来";
        }
        if (this.scavState === "stall") {
            return "停住";
        }
        if (this.scavState === "back") {
            return "回位";
        }
        return "巡逻";
    }

    /** 一行提示文字。 */
    hintText(): string {
        if (this.paused) {
            return "Esc 继续 · R 重置";
        }
        if (this.flash !== "") {
            return this.flash;
        }
        if (this.room.key === "village") {
            if (this.bottleFly !== undefined) {
                return "等瓶子落地 · 触地才发声";
            }
            if (this.hasBottle) {
                return "按住 F 瞄，松手投 · 往右投到砖地 608，他才会走开";
            }
            if (this.passed) {
                return "已过第一院 · R 重置可再来一遍";
            }
            return "走到瓶架旁点 E 拾瓶 · Ctrl 蹲下钻过桌下 44";
        }
        if (this.room.key === "outside") {
            if (this.focusCart) {
                return "按住 E 抓住车把 · A / D 推拉 · 松手就停";
            }
            return "A / D 走 · Ctrl 蹲 · 空格跳 · 车要拉到 432 才让开拱洞";
        }
        if (this.escort.state === "frozen") {
            if (Math.abs(this.player.x - this.partner.x) <= CALM_REACH) {
                return "点 E 蹲下安抚 · 第 12 / 36 拍各敲一次，60 拍后她起身";
            }
            return "小满吓住了 · 走过去，靠近再点 E";
        }
        if (this.escort.state === "calming") {
            return "安抚中 " + this.escort.calmTick + " / 60 拍 · 别动";
        }
        return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下 · 两人到出口才开门";
    }

    // ---------- 绘制 ----------

    draw(draw: DrawNode.Type, w: number, h: number): void {
        this.viewW = w;
        this.viewH = h;
        this.view = computeViewport(w, h);
        this.clampCamera(w, h);
        draw.clear();
        // 画布外的黑边与画布底
        draw.drawRect(Rect(0, 0, w, h), BG_VOID);
        const box = this.canvasRect(w, h);
        draw.drawRect(box, BG_FAR);
        draw.drawRect(Rect(box.x, box.y + box.height * 0.38, box.width, box.height * 0.62), BG_MID);

        this.drawFloors(draw, w, h);
        this.drawSolids(draw, w, h);
        this.drawZones(draw, w, h);
        this.drawArch(draw, w, h);
        this.drawCart(draw, w, h);
        this.drawActors(draw, w, h);
        this.drawTrace(draw, w, h);
        this.drawAim(draw, w, h);
    }

    /** 画布矩形（窗口坐标，左下原点）。 */
    canvasRect(w: number, h: number): Rect.Type {
        const v = this.view;
        return Rect(v.ox, v.oy, LOGIC_W * v.zoom, LOGIC_H * v.zoom);
    }

    /** 逻辑像素长度 → 屏幕像素。用于线宽、圆点等。 */
    px(n: number): number {
        return n * this.view.zoom;
    }

    /** 世界 x → 窗口 x。量化到逻辑像素格，保证边缘锐利。 */
    sx(wx: number, w: number): number {
        const v = this.view;
        const lx = Math.round((wx - this.cam.x) / UNITS_PER_PX + LOGIC_W / 2);
        return v.ox + lx * v.zoom;
    }

    /** 世界 y → 窗口 y。 */
    sy(wy: number, h: number): number {
        const v = this.view;
        const ly = Math.round((wy - this.cam.y) / UNITS_PER_PX + LOGIC_H / 2);
        return v.oy + ly * v.zoom;
    }

    drawBox(draw: DrawNode.Type, w: number, h: number, x0: number, x1: number, y0: number, y1: number, color: Color.Type): void {
        const px0 = this.sx(x0, w);
        const px1 = this.sx(x1, w);
        const py0 = this.sy(y0, h);
        const py1 = this.sy(y1, h);
        if (px1 <= px0 || py1 <= py0) {
            return;
        }
        draw.drawRect(Rect(px0, py0, px1 - px0, py1 - py0), color);
    }

    private drawFloors(draw: DrawNode.Type, w: number, h: number): void {
        let i = 0;
        for (i = 0; i < this.room.floors.length; i++) {
            const f = this.room.floors[i];
            const y = this.sy(f.y, h);
            const x0 = this.sx(f.x0, w);
            const x1 = this.sx(f.x1, w);
            const deck = this.px(5);
            draw.drawRect(Rect(x0, y - deck, x1 - x0, deck), FLOOR_DECK);
            draw.drawSegment(Vec2(x0, y), Vec2(x1, y), this.px(1), GROUND);
        }
    }

    private drawSolids(draw: DrawNode.Type, w: number, h: number): void {
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.y0 < -4 && b.y1 <= 96) {
                // 台阶体：只需顶面线
                draw.drawSegment(Vec2(this.sx(b.x0, w), this.sy(b.y1, h)), Vec2(this.sx(b.x1, w), this.sy(b.y1, h)), this.px(1), GROUND);
                continue;
            }
            this.drawBox(draw, w, h, b.x0, b.x1, b.y0, b.y1, SOLID_FILL);
            draw.drawSegment(Vec2(this.sx(b.x0, w), this.sy(b.y1, h)), Vec2(this.sx(b.x1, w), this.sy(b.y1, h)), this.px(1), SOLID_EDGE);
        }
    }

    private drawZones(draw: DrawNode.Type, w: number, h: number): void {
        let i = 0;
        for (i = 0; i < this.room.zones.length; i++) {
            const z = this.room.zones[i];
            let fill = DANGER;
            let line = DANGER_LINE;
            if (z.tint === 2) {
                fill = SOFT;
                line = SOFT_LINE;
            } else if (z.tint === 3) {
                fill = BRICK;
                line = BRICK_LINE;
            } else if (z.tint === 4) {
                fill = PASS;
                line = PASS_LINE;
            }
            this.drawBox(draw, w, h, z.x0, z.x1, z.y, z.y + z.h, fill);
            draw.drawSegment(Vec2(this.sx(z.x0, w), this.sy(z.y, h)), Vec2(this.sx(z.x0, w), this.sy(z.y + z.h, h)), this.px(1), line);
            draw.drawSegment(Vec2(this.sx(z.x1, w), this.sy(z.y, h)), Vec2(this.sx(z.x1, w), this.sy(z.y + z.h, h)), this.px(1), line);
        }
    }

    private drawArch(draw: DrawNode.Type, w: number, h: number): void {
        const a = this.room.arch;
        if (a.h <= 0) {
            return;
        }
        this.drawBox(draw, w, h, a.x0, a.x1, a.y, a.y + a.h, HOLE_FILL);
        draw.drawSegment(Vec2(this.sx(a.x0, w), this.sy(a.y + a.h, h)), Vec2(this.sx(a.x1, w), this.sy(a.y + a.h, h)), this.px(1), SOLID_EDGE);
        draw.drawSegment(Vec2(this.sx(a.x0, w), this.sy(a.y, h)), Vec2(this.sx(a.x0, w), this.sy(a.y + a.h, h)), this.px(1), SOLID_EDGE);
        draw.drawSegment(Vec2(this.sx(a.x1, w), this.sy(a.y, h)), Vec2(this.sx(a.x1, w), this.sy(a.y + a.h, h)), this.px(1), SOLID_EDGE);
    }

    private drawCart(draw: DrawNode.Type, w: number, h: number): void {
        const c: CartSpec = this.room.cart;
        if (c.bodyW <= 0) {
            return;
        }
        drawCartShape(draw, this, w, h, c, this.cartAxle);
        draw.drawRect(Rect(this.sx(this.cartAxle + c.handleOffset, w) - this.px(1), this.sy(c.baseY + 40, h), this.px(2), this.px(40)), STAND);
    }

    private drawActors(draw: DrawNode.Type, w: number, h: number): void {
        const p = this.player;
        const isChild = this.room.key !== "checkpoint";
        drawFigure(draw, this, w, h, p, isChild ? CHILD_BODY : SOLDIER_BODY, isChild ? CHILD_HEAD : SOLDIER_HEAD);
        const q = this.partner;
        if (q.alive) {
            const childPartner = q.w === CHILD_W;
            drawFigure(draw, this, w, h, q, childPartner ? CHILD_BODY : SOLDIER_BODY, childPartner ? CHILD_HEAD : SOLDIER_HEAD);
        }
        let i = 0;
        for (i = 0; i < this.enemies.length; i++) {
            const e = this.enemies[i];
            const col = e.alive ? ENEMY_BODY : ENEMY_DEAD;
            this.drawBox(draw, w, h, e.x - e.w / 2, e.x + e.w / 2, e.y, e.y + e.h, col);
        }
        // 检查点标记
        let k = 0;
        for (k = 0; k < this.room.marks.length; k++) {
            const m = this.room.marks[k];
            if (m.kind !== 0) {
                continue;
            }
            const on = this.checkpoint === m.x;
            const x = this.sx(m.x, w);
            const y = this.sy(m.y, h);
            draw.drawSegment(Vec2(x, y), Vec2(x, y + this.px(35)), this.px(1), on ? CHECK : INK_DIM);
            draw.drawDot(Vec2(x, y + this.px(35)), this.px(2), on ? CHECK : INK_DIM);
        }

        // 安全锚、通行线、砖地落点：细竖线
        let j = 0;
        for (j = 0; j < this.room.marks.length; j++) {
            const m = this.room.marks[j];
            if (m.kind !== 1 && m.kind !== 4 && m.kind !== 5) {
                continue;
            }
            if (m.kind === 1 && this.room.key !== "checkpoint") {
                continue;
            }
            let col = STAND;
            if (m.kind === 4) {
                col = PASS_LINE;
            } else if (m.kind === 5) {
                col = BRICK_LINE;
            }
            const mx = this.sx(m.x, w);
            const my = this.sy(m.y, h);
            draw.drawSegment(Vec2(mx, my), Vec2(mx, my + this.px(24)), this.px(1), col);
        }
        if (this.room.key === "village") {
            this.drawVillage(draw, w, h);
        }
    }

    /** 村口道具：瓶架、桌子、拾荒者、手上的瓶、飞行与落地余音。 */
    private drawVillage(draw: DrawNode.Type, w: number, h: number): void {
        const bottle = this.room.bottle;
        if (bottle !== undefined) {
            this.drawBox(draw, w, h, bottle.x - 14, bottle.x + 14, 0, 64, SOLID_FILL);
            if (!this.hasBottle && this.bottleFly === undefined && this.bottleLandT <= 0) {
                this.drawBottle(draw, w, h, bottle.x, 64);
            }
        }
        // 桌面：304..416，桌下净高 44；桌腿只做视觉，碰撞交给 arch。
        this.drawBox(draw, w, h, 300, 420, 44, 50, FLOOR_DECK);
        this.drawBox(draw, w, h, 300, 306, 0, 44, FLOOR_DECK);
        this.drawBox(draw, w, h, 414, 420, 0, 44, FLOOR_DECK);

        const s = this.room.scavenger;
        if (s !== undefined) {
            const sx0 = this.scavX;
            this.drawBox(draw, w, h, sx0 - 12, sx0 + 12, 0, s.h - 14, SCAV_BODY);
            this.drawBox(draw, w, h, sx0 - 7, sx0 + 7, s.h - 14, s.h, SCAV_HEAD);
            if (this.scavState === "turn") {
                const fx = sx0 + (this.scavDir > 0 ? 12 : -12);
                draw.drawSegment(Vec2(this.sx(sx0, w), this.sy(s.h - 6, h)), Vec2(this.sx(fx, w), this.sy(s.h - 6, h)), this.px(1), INK);
            }
        }

        if (this.hasBottle) {
            const p = this.player;
            this.drawBottle(draw, w, h, p.x + p.facing * 10, p.y + p.h * 0.62);
        }
        if (this.bottleFly !== undefined) {
            this.drawBottle(draw, w, h, this.bottleFly.x, this.bottleFly.y);
        }
        if (this.bottleLandT > 0 && this.bottleLandX >= 0) {
            const r = (1 - this.bottleLandT / 0.9) * 28;
            draw.drawCircle(Vec2(this.sx(this.bottleLandX, w), this.sy(0, h)), this.px(r / UNITS_PER_PX), BRICK_LINE);
        }
    }

    private drawBottle(draw: DrawNode.Type, w: number, h: number, x: number, y: number): void {
        this.drawBox(draw, w, h, x - 3, x + 3, y - 10, y, BOTTLE);
    }

    private drawTrace(draw: DrawNode.Type, w: number, h: number): void {
        const t = this.trace;
        if (t === undefined || this.traceT <= 0) {
            return;
        }
        draw.drawSegment(
            Vec2(this.sx(t.x0, w), this.sy(t.y0, h)),
            Vec2(this.sx(t.x1, w), this.sy(t.y1, h)),
            this.px(1), t.hit ? AIM_HIT : INK_DIM);
    }

    private drawAim(draw: DrawNode.Type, w: number, h: number): void {
        // 准星按逻辑像素画：中心留 1 像素缺口，四臂各 3 像素，外圈 1 像素。
        const v = this.view;
        const gx = v.ox + Math.round((this.aimX - v.ox) / v.zoom) * v.zoom;
        const gy = v.oy + Math.round((this.aimY - v.oy) / v.zoom) * v.zoom;
        const dot = this.px(1);
        const arm = this.px(3);
        const gap = this.px(1);
        draw.drawSegment(Vec2(gx - arm - gap, gy), Vec2(gx - gap, gy), dot / 2, AIM);
        draw.drawSegment(Vec2(gx + gap, gy), Vec2(gx + arm + gap, gy), dot / 2, AIM);
        draw.drawSegment(Vec2(gx, gy - arm - gap), Vec2(gx, gy - gap), dot / 2, AIM);
        draw.drawSegment(Vec2(gx, gy + gap), Vec2(gx, gy + arm + gap), dot / 2, AIM);

        // 村口：手上有瓶时画出落点弧线
        if (this.room.key === "village" && this.hasBottle) {
            const p = this.player;
            const aim = screenToWorld(this.aimX, this.aimY, this.cam, this.view);
            const x0 = p.x + p.facing * 10;
            const y0 = p.y + p.h * 0.7;
            const T = 0.62;
            const vx = (aim.x - x0) / T;
            const vy = (aim.y - y0 + 0.5 * GRAVITY * T * T) / T;
            let pxr = x0;
            let pyr = y0;
            let t = 1;
            for (t = 1; t <= 12; t++) {
                const tt = (t / 12) * T;
                const nx = x0 + vx * tt;
                const ny = y0 + vy * tt - 0.5 * GRAVITY * tt * tt;
                draw.drawSegment(Vec2(this.sx(pxr, w), this.sy(pyr, h)), Vec2(this.sx(nx, w), this.sy(ny, h)), this.px(1) / 2, BOTTLE);
                pxr = nx;
                pyr = ny;
            }
        }
    }
}

function makeActor(room: RoomSpec, index: number): Actor {
    const sp = room.spawns;
    if (index < 0 || index >= sp.length) {
        return { x: 0, y: 0, vx: 0, vy: 0, w: CHILD_W, h: CHILD_H, onGround: true, facing: 1, crouch: false, rollT: 0, covered: false, alive: false };
    }
    const s = sp[index];
    const child = s.h <= CHILD_H;
    return {
        x: s.x, y: s.y, vx: 0, vy: 0,
        w: child ? CHILD_W : SOLDIER_W,
        h: child ? CHILD_H : SOLDIER_H,
        onGround: true, facing: 1, crouch: false, rollT: 0, covered: false, alive: true,
    };
}

function drawFigure(draw: DrawNode.Type, play: Play, w: number, h: number, a: Actor, body: Color.Type, head: Color.Type): void {
    if (!a.alive) {
        return;
    }
    const x0 = a.x - a.w / 2;
    const x1 = a.x + a.w / 2;
    const y0 = a.y;
    const y1 = a.y + a.h;
    play.drawBox(draw, w, h, x0, x1, y0, y1 - a.h * 0.26, body);
    play.drawBox(draw, w, h, x0 + 2, x1 - 2, y1 - a.h * 0.26, y1, head);
    // 眼睛：1 逻辑像素的亮点，朝向前方
    const eyeX = a.facing > 0 ? a.x + a.w * 0.16 : a.x - a.w * 0.28;
    play.drawBox(draw, w, h, eyeX, eyeX + 4, y1 - a.h * 0.14, y1 - a.h * 0.08, INK);
}

/** 窗口坐标（局部、左下原点）→ 世界。用实际画面原点、显示倍数与相机反算。 */
export function screenToWorld(sx: number, sy: number, cam: Camera, view: Viewport): { x: number; y: number } {
    return {
        x: cam.x + ((sx - view.ox) / view.zoom - LOGIC_W / 2) * UNITS_PER_PX,
        y: cam.y + ((sy - view.oy) / view.zoom - LOGIC_H / 2) * UNITS_PER_PX,
    };
}

/** 射线与轴对齐盒求交，返回命中距离；不相交返回 -1。 */
function hitBox(ox: number, oy: number, dx: number, dy: number, x0: number, x1: number, y0: number, y1: number): number {
    let tmin = 0;
    let tmax = 99999;
    if (dx === 0) {
        if (ox < x0 || ox > x1) {
            return -1;
        }
    } else {
        const t1 = (x0 - ox) / dx;
        const t2 = (x1 - ox) / dx;
        const lo = t1 < t2 ? t1 : t2;
        const hi = t1 < t2 ? t2 : t1;
        if (lo > tmin) {
            tmin = lo;
        }
        if (hi < tmax) {
            tmax = hi;
        }
    }
    if (dy === 0) {
        if (oy < y0 || oy > y1) {
            return -1;
        }
    } else {
        const t1 = (y0 - oy) / dy;
        const t2 = (y1 - oy) / dy;
        const lo = t1 < t2 ? t1 : t2;
        const hi = t1 < t2 ? t2 : t1;
        if (lo > tmin) {
            tmin = lo;
        }
        if (hi < tmax) {
            tmax = hi;
        }
    }
    return tmax >= tmin ? tmin : -1;
}

function drawCartShape(draw: DrawNode.Type, play: Play, w: number, h: number, c: CartSpec, axleX: number): void {
    const half = c.bodyW / 2;
    const x0 = axleX - half;
    const x1 = axleX + half;
    play.drawBox(draw, w, h, x0, x1, c.baseY + c.wheelR, c.baseY + c.wheelR + c.bodyH, CART_FILL);
    draw.drawCircle(Vec2(play.sx(x0 + c.bodyW * 0.28, w), play.sy(c.baseY + c.wheelR, h)), play.px(c.wheelR / UNITS_PER_PX), Color(52, 50, 48, 255));
    draw.drawCircle(Vec2(play.sx(x1 - c.bodyW * 0.28, w), play.sy(c.baseY + c.wheelR, h)), play.px(c.wheelR / UNITS_PER_PX), Color(52, 50, 48, 255));
    const cx = c.clothSide < 0 ? x0 : x1;
    play.drawBox(draw, w, h, cx - 10, cx + 10, c.baseY + c.wheelR + c.bodyH, c.baseY + c.wheelR + c.bodyH + 18, CLOTH);
}
