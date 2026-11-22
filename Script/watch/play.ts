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
import { CartSpec, RoomSpec, SolidSpec, CHECKPOINT_ROOM, OUTSIDE_ROOM } from "Script/watch/rooms";
import { Input } from "Script/watch/input";

export const STEP = 1 / 60;
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

/** 相机：1 世界单位 = 4 屏幕像素；视点略高于脚底。 */
const CAM_ZOOM = 4;
const CAM_FOLLOW = 9;
const CAM_LOOK_UP = 46;

const INK = Color(232, 232, 228, 255);
const INK_DIM = Color(150, 152, 150, 255);
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

/** 轴对齐盒（世界单位）。 */
interface Box {
    x0: number;
    x1: number;
    y0: number;
    y1: number;
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
    /** 城外拉车焦点是否亮起（D2 只提示，D3 才真拉）。 */
    focusCart = false;
    /** E 按下的次数与最近一次的时间，用来做「敲两下」。 */
    knocks = 0;
    knockT = 0;
    paused = false;
    /** 累计模拟步，用来做与帧率无关的计时。 */
    ticks = 0;
    /** 准星在画布上的位置（局部、左下原点），由 app 每帧写入。 */
    aimX = 0;
    aimY = 0;
    /** 最近一次绘制的画布尺寸，供屏幕↔世界换算。 */
    viewW = 0;
    viewH = 0;

    constructor(room: RoomSpec) {
        this.room = room;
        this.cam = { x: (room.minX + room.maxX) / 2, y: room.height / 2 };
        this.buildWorld();
        this.player = makeActor(room, room.key === "checkpoint" ? 1 : 0);
        this.partner = makeActor(room, room.key === "checkpoint" ? 0 : -1);
        this.cam.x = this.player.x;
        this.cam.y = this.player.y + CAM_LOOK_UP;
        this.buildEnemies();
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
                this.boxes.push({ x0: x0, x1: x0 + stepW, y0: -8, y1: y });
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
        this.stepPartner(p, dt);
        this.stepEnemies(dt);
        this.stepInteract(input);
        this.updateCamera(dt);
    }

    private stepPlayer(a: Actor, dt: number, input: Input): void {
        if (!a.alive) {
            return;
        }
        const isChild = this.room.key !== "checkpoint";
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
            a.rollT = ROLL_TIME;
            if (input.moveX !== 0) {
                a.facing = input.moveX > 0 ? 1 : -1;
            }
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

        const dir = input.moveX;
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

    private stepEnemies(dt: number): void {
        let i = 0;
        for (i = 0; i < this.enemies.length; i++) {
            const e = this.enemies[i];
            if (e.hitT > 0) {
                e.hitT -= dt;
            }
        }
    }

    private stepInteract(input: Input): void {
        const p = this.player;
        this.focusCart = false;
        if (this.room.key === "outside") {
            const c = this.room.cart;
            const dx = p.x - (c.startX + c.handleOffset);
            const dy = p.y - c.baseY;
            if (dx * dx + dy * dy < 70 * 70) {
                this.focusCart = true;
            }
        }

        if (input.interact.pressed) {
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
            this.knockT -= STEP;
            if (this.knockT <= 0) {
                this.knocks = 0;
            }
        }

        // 本地检查点：踩到 kind 0 的标记就提交
        let i = 0;
        for (i = 0; i < this.room.marks.length; i++) {
            const m = this.room.marks[i];
            if (m.kind !== 0) {
                continue;
            }
            const dx = p.x - m.x;
            const dy = p.y - m.y;
            if (dx * dx + dy * dy < 26 * 26 && this.checkpoint !== m.x) {
                this.checkpoint = m.x;
                this.flashSet("检查点", 1.0);
            }
        }
    }

    /** 点射：从枪口到准星拉一条线，命中最近的敌人；被实体挡住则打空。 */
    private shoot(a: Actor): void {
        const ox = a.x + a.facing * 8;
        const oy = a.y + a.h * 0.72;
        // 准星在世界里的位置由 app 传进来，这里直接用相机反算
        const aim = screenToWorld(this.aimX, this.aimY, this.cam, this.viewW, this.viewH);
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
        // 拱洞（低洞）：身高超出净空就进不去。
        // 已经在洞里的人（例如蹲着进来后站起来）允许朝任一侧走出去，
        // 否则会被永久卡在洞内。
        const arch = room.arch;
        if (arch.h > 0 && a.y + a.h > arch.y + arch.h + 0.001) {
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
        const halfW = (w / 2) / CAM_ZOOM;
        const halfH = (h / 2) / CAM_ZOOM;
        const spanX = room.maxX - room.minX;
        if (spanX <= halfW * 2) {
            this.cam.x = (room.minX + room.maxX) / 2;
        } else {
            this.cam.x = Math.max(room.minX + halfW, Math.min(room.maxX - halfW, this.cam.x));
        }
        const spanY = room.height;
        if (spanY <= halfH * 2) {
            this.cam.y = spanY / 2;
        } else {
            this.cam.y = Math.max(halfH, Math.min(spanY - halfH, this.cam.y));
        }
    }

    private flashSet(text: string, t: number): void {
        this.flash = text;
        this.flashT = t;
    }

    /** 一行状态文字。 */
    statusText(): string {
        const p = this.player;
        const isChild = this.room.key !== "checkpoint";
        const who = isChild ? "小满" : "周戍";
        const cx = Math.round(p.x);
        const cy = Math.round(p.y);
        const parts: string[] = [];
        parts.push(who + " x=" + cx + " y=" + cy);
        if (isChild) {
            parts.push(p.crouch ? "蹲" : "站");
            parts.push("高 " + Math.round(p.h));
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
        }
        if (this.checkpoint >= 0) {
            parts.push("检查点 " + Math.round(this.checkpoint));
        }
        if (this.paused) {
            parts.push("已暂停");
        }
        return parts.join(" · ");
    }

    /** 一行提示文字。 */
    hintText(): string {
        if (this.paused) {
            return "Esc 继续 · R 重置";
        }
        if (this.flash !== "") {
            return this.flash;
        }
        const isChild = this.room.key !== "checkpoint";
        if (isChild) {
            if (this.focusCart) {
                return "按住 E + A/D 拉车（D3 接）";
            }
            return "A / D 走 · Shift 慢走 · 空格跳 · S 或 Ctrl 蹲下钻过拱洞";
        }
        return "A / D 移动 · 左键点射 · Shift 贴掩体 · 空格翻滚 · E 敲两下";
    }

    // ---------- 绘制 ----------

    draw(draw: DrawNode.Type, w: number, h: number): void {
        this.viewW = w;
        this.viewH = h;
        this.clampCamera(w, h);
        draw.clear();
        draw.drawRect(Rect(0, 0, w, h), BG_FAR);
        draw.drawRect(Rect(0, 0, w, h * 0.62), BG_MID);

        this.drawFloors(draw, w, h);
        this.drawSolids(draw, w, h);
        this.drawZones(draw, w, h);
        this.drawArch(draw, w, h);
        this.drawCart(draw, w, h);
        this.drawActors(draw, w, h);
        this.drawTrace(draw, w, h);
        this.drawAim(draw, w, h);
    }

    sx(wx: number, w: number): number {
        return (wx - this.cam.x) * CAM_ZOOM + w / 2;
    }

    sy(wy: number, h: number): number {
        return (wy - this.cam.y) * CAM_ZOOM + h / 2;
    }

    drawBox(draw: DrawNode.Type, w: number, h: number, x0: number, x1: number, y0: number, y1: number, color: Color.Type): void {
        const px = this.sx(x0, w);
        const py = this.sy(y0, h);
        draw.drawRect(Rect(px, py, (x1 - x0) * CAM_ZOOM, (y1 - y0) * CAM_ZOOM), color);
    }

    private drawFloors(draw: DrawNode.Type, w: number, h: number): void {
        let i = 0;
        for (i = 0; i < this.room.floors.length; i++) {
            const f = this.room.floors[i];
            const y = this.sy(f.y, h);
            const x0 = this.sx(f.x0, w);
            const x1 = this.sx(f.x1, w);
            draw.drawRect(Rect(x0, y - 10 * 2, x1 - x0, 10 * 2), FLOOR_DECK);
            draw.drawSegment(Vec2(x0, y), Vec2(x1, y), 3, GROUND);
        }
    }

    private drawSolids(draw: DrawNode.Type, w: number, h: number): void {
        let i = 0;
        for (i = 0; i < this.boxes.length; i++) {
            const b = this.boxes[i];
            if (b.y0 < -4 && b.y1 <= 96) {
                // 台阶体：只需顶面线
                draw.drawSegment(Vec2(this.sx(b.x0, w), this.sy(b.y1, h)), Vec2(this.sx(b.x1, w), this.sy(b.y1, h)), 3, GROUND);
                continue;
            }
            this.drawBox(draw, w, h, b.x0, b.x1, b.y0, b.y1, SOLID_FILL);
            draw.drawSegment(Vec2(this.sx(b.x0, w), this.sy(b.y1, h)), Vec2(this.sx(b.x1, w), this.sy(b.y1, h)), 2, SOLID_EDGE);
        }
    }

    private drawZones(draw: DrawNode.Type, w: number, h: number): void {
        let i = 0;
        for (i = 0; i < this.room.zones.length; i++) {
            const z = this.room.zones[i];
            this.drawBox(draw, w, h, z.x0, z.x1, z.y, z.y + z.h, DANGER);
            draw.drawSegment(Vec2(this.sx(z.x0, w), this.sy(z.y, h)), Vec2(this.sx(z.x0, w), this.sy(z.y + z.h, h)), 2, DANGER_LINE);
            draw.drawSegment(Vec2(this.sx(z.x1, w), this.sy(z.y, h)), Vec2(this.sx(z.x1, w), this.sy(z.y + z.h, h)), 2, DANGER_LINE);
        }
    }

    private drawArch(draw: DrawNode.Type, w: number, h: number): void {
        const a = this.room.arch;
        if (a.h <= 0) {
            return;
        }
        this.drawBox(draw, w, h, a.x0, a.x1, a.y, a.y + a.h, HOLE_FILL);
        draw.drawSegment(Vec2(this.sx(a.x0, w), this.sy(a.y + a.h, h)), Vec2(this.sx(a.x1, w), this.sy(a.y + a.h, h)), 3, SOLID_EDGE);
        draw.drawSegment(Vec2(this.sx(a.x0, w), this.sy(a.y, h)), Vec2(this.sx(a.x0, w), this.sy(a.y + a.h, h)), 2, SOLID_EDGE);
        draw.drawSegment(Vec2(this.sx(a.x1, w), this.sy(a.y, h)), Vec2(this.sx(a.x1, w), this.sy(a.y + a.h, h)), 2, SOLID_EDGE);
    }

    private drawCart(draw: DrawNode.Type, w: number, h: number): void {
        const c: CartSpec = this.room.cart;
        drawCartShape(draw, this, w, h, c, c.startX);
        draw.drawRect(Rect(this.sx(c.startX + c.handleOffset, w) - 3, this.sy(c.baseY + 40, h), 6, 80), STAND);
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
            draw.drawSegment(Vec2(x, y), Vec2(x, y + 70), 2, on ? CHECK : INK_DIM);
            draw.drawDot(Vec2(x, y + 70), 5, on ? CHECK : INK_DIM);
        }
    }

    private drawTrace(draw: DrawNode.Type, w: number, h: number): void {
        const t = this.trace;
        if (t === undefined || this.traceT <= 0) {
            return;
        }
        draw.drawSegment(
            Vec2(this.sx(t.x0, w), this.sy(t.y0, h)),
            Vec2(this.sx(t.x1, w), this.sy(t.y1, h)),
            2, t.hit ? AIM_HIT : INK_DIM);
    }

    private drawAim(draw: DrawNode.Type, w: number, h: number): void {
        const x = this.aimX;
        const y = this.aimY;
        draw.drawRing(Vec2(x, y), 7, 9, Color(0, 0, 0, 0), 1, AIM);
        draw.drawSegment(Vec2(x - 14, y), Vec2(x - 4, y), 1, AIM);
        draw.drawSegment(Vec2(x + 4, y), Vec2(x + 14, y), 1, AIM);
        draw.drawSegment(Vec2(x, y - 14), Vec2(x, y - 4), 1, AIM);
        draw.drawSegment(Vec2(x, y + 4), Vec2(x, y + 14), 1, AIM);
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
}

/** 屏幕（局部、左下原点）→ 世界。 */
export function screenToWorld(sx: number, sy: number, cam: Camera, w: number, h: number): { x: number; y: number } {
    return { x: (sx - w / 2) / CAM_ZOOM + cam.x, y: (sy - h / 2) / CAM_ZOOM + cam.y };
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
    draw.drawCircle(Vec2(play.sx(x0 + c.bodyW * 0.28, w), play.sy(c.baseY + c.wheelR, h)), c.wheelR * CAM_ZOOM, Color(52, 50, 48, 255));
    draw.drawCircle(Vec2(play.sx(x1 - c.bodyW * 0.28, w), play.sy(c.baseY + c.wheelR, h)), c.wheelR * CAM_ZOOM, Color(52, 50, 48, 255));
    const cx = c.clothSide < 0 ? x0 : x1;
    play.drawBox(draw, w, h, cx - 10, cx + 10, c.baseY + c.wheelR + c.bodyH, c.baseY + c.wheelR + c.bodyH + 18, CLOTH);
}
