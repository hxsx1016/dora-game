/**
 * 灰盒绘制：只画形状，不画文字。文字由 app.ts 的标签池按 LabelSpec 摆放。
 *
 * 坐标：世界单位（与逐日文档一致）→ 屏幕像素，
 * px = padX + (x - minX) * scale，py = groundPx + y * scale。
 * PX 是「屏幕像素常数的倍率」：Dora 在 Retina 上按物理像素渲染（2560×1440），
 * 导出 PNG 会被缩到 1280×720，所以线宽、字号、间距一律 ×PX，保证导出图仍然可读。
 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { RoomSpec, StairSpec } from "Script/watch/rooms";

export interface Viewbox {
    scale: number;
    padX: number;
    groundPx: number;
}

/** 文字锚点：ax/ay 直接是 Node.anchor，0=左/底，0.5=中，1=右/顶。 */
export interface LabelSpec {
    x: number;
    y: number;
    text: string;
    ax: number;
    ay: number;
    color: Color.Type;
    size: number;
}

const PX = 2;

const PAD_X = 72 * PX;
const PAD_TOP = 104 * PX;
const PAD_BOTTOM = 108 * PX;

const INK = Color(232, 232, 228, 255);
const INK_DIM = Color(150, 152, 150, 255);
const BG_FAR = Color(24, 26, 28, 255);
const BG_MID = Color(31, 34, 37, 255);
const BG_NEAR = Color(38, 41, 44, 255);
const GROUND = Color(112, 114, 112, 255);
const FLOOR_DECK = Color(66, 70, 72, 255);
const SOLID_FILL = Color(84, 86, 84, 255);
const CART_FILL = Color(122, 78, 56, 255);
const CLOTH = Color(178, 52, 46, 255);
const HOLE_FILL = Color(10, 11, 12, 255);
const DANGER = Color(150, 54, 48, 70);
const DANGER_LINE = Color(178, 78, 64, 220);
const DIM_LINE = Color(126, 132, 140, 255);
const CHECK = Color(96, 186, 122, 255);
const STAND = Color(226, 186, 84, 255);
const EXIT = Color(96, 166, 226, 255);
const LAND = Color(206, 196, 122, 255);

export function computeView(room: RoomSpec, w: number, h: number): Viewbox {
    const usableW = Math.max(240 * PX, w - PAD_X * 2);
    const drawH = Math.max(160 * PX, h - PAD_TOP - PAD_BOTTOM);
    const spanX = Math.max(1, room.maxX - room.minX);
    const scale = Math.min(usableW / spanX, drawH / room.height);
    // 灰盒在上下信息带之间垂直居中，尺寸线落在地面以下
    const groundPx = PAD_BOTTOM + (drawH - room.height * scale) / 2;
    return { scale, padX: PAD_X, groundPx };
}

/** 尺寸线在地面下的像素位置：i=0 最靠地面。 */
function dimPxY(v: Viewbox, i: number): number {
    return v.groundPx - 30 * PX - i * 22 * PX;
}

export function pxX(v: Viewbox, m: number, room: RoomSpec): number {
    return v.padX + (m - room.minX) * v.scale;
}

export function pxY(v: Viewbox, m: number): number {
    return v.groundPx + m * v.scale;
}

function rectOf(v: Viewbox, room: RoomSpec, x0: number, x1: number, y0: number, y1: number): Rect.Type {
    return Rect(pxX(v, x0, room), pxY(v, y0), (x1 - x0) * v.scale, (y1 - y0) * v.scale);
}

/** 画背景、地面、台面、实体、拱、台阶、板车、标记点。 */
export function renderWorld(draw: DrawNode.Type, room: RoomSpec, v: Viewbox, w: number, h: number): void {
    const ground = pxY(v, 0);
    const top = pxY(v, room.height);

    // 三层景深
    draw.drawRect(Rect(0, 0, w, h), BG_FAR);
    draw.drawRect(Rect(0, ground, w, top - ground), BG_MID);

    // 每层地面
    for (let i = 0; i < room.floors.length; i++) {
        const f = room.floors[i];
        const y = pxY(v, f.y);
        const x0 = pxX(v, f.x0, room);
        const x1 = pxX(v, f.x1, room);
        draw.drawRect(Rect(x0, y, x1 - x0, top - y), BG_NEAR);
        draw.drawSegment(Vec2(x0, y), Vec2(x1, y), 3 * PX, GROUND);
        // 台面下方阴影，表示这层是悬空平台
        if (f.y > 0) {
            draw.drawRect(Rect(x0, y - 10 * PX, x1 - x0, 10 * PX), FLOOR_DECK);
        }
    }

    // 危险区
    for (let i = 0; i < room.zones.length; i++) {
        const z = room.zones[i];
        if (z.tint !== 1) {
            continue;
        }
        draw.drawRect(rectOf(v, room, z.x0, z.x1, z.y, z.y + z.h), DANGER);
        draw.drawSegment(
            Vec2(pxX(v, z.x0, room), pxY(v, z.y + z.h)),
            Vec2(pxX(v, z.x1, room), pxY(v, z.y + z.h)),
            1 * PX,
            DANGER_LINE,
        );
    }

    // 实体
    for (let i = 0; i < room.solids.length; i++) {
        const s = room.solids[i];
        draw.drawRect(rectOf(v, room, s.x, s.x + s.w, s.y, s.y + s.h), SOLID_FILL);
        draw.drawRect(rectOf(v, room, s.x, s.x + s.w, s.y, s.y + s.h), Color(0, 0, 0, 0), 1.5 * PX, INK_DIM);
    }

    // 拱：半个矮拱，下面是黑洞
    if (room.arch.x1 > room.arch.x0) {
        const a = room.arch;
        draw.drawRect(rectOf(v, room, a.x0, a.x1, a.y, a.y + a.h), HOLE_FILL);
        draw.drawSegment(Vec2(pxX(v, a.x0, room), pxY(v, a.y)), Vec2(pxX(v, a.x0, room), pxY(v, a.y + a.h)), 2 * PX, INK);
        draw.drawSegment(Vec2(pxX(v, a.x1, room), pxY(v, a.y)), Vec2(pxX(v, a.x1, room), pxY(v, a.y + a.h)), 2 * PX, INK);
        draw.drawArc(
            Vec2(pxX(v, (a.x0 + a.x1) / 2, room), pxY(v, a.y + a.h * 0.55)),
            ((a.x1 - a.x0) / 2) * v.scale,
            0,
            180,
            2 * PX,
            INK,
        );
    }

    // 台阶
    for (let i = 0; i < room.stairs.length; i++) {
        drawStairs(draw, room, v, room.stairs[i]);
    }

    // 车辙：两端之间的两条平行线，画在车所在的那层
    const cart = room.cart;
    const lo = Math.min(cart.startX, cart.endX);
    const hi = Math.max(cart.startX, cart.endX);
    if (hi - lo > 4) {
        const yBase = cart.baseY;
        draw.drawSegment(Vec2(pxX(v, lo, room), pxY(v, yBase + 3)), Vec2(pxX(v, hi, room), pxY(v, yBase + 3)), 1 * PX, INK_DIM);
        draw.drawSegment(Vec2(pxX(v, lo, room), pxY(v, yBase + 9)), Vec2(pxX(v, hi, room), pxY(v, yBase + 9)), 1 * PX, INK_DIM);
        draw.drawSegment(Vec2(pxX(v, lo, room), pxY(v, yBase + 1)), Vec2(pxX(v, lo, room), pxY(v, yBase + 11)), 1 * PX, INK_DIM);
        draw.drawSegment(Vec2(pxX(v, hi, room), pxY(v, yBase + 1)), Vec2(pxX(v, hi, room), pxY(v, yBase + 11)), 1 * PX, INK_DIM);
    }

    // 板车：起点虚影 + 终点实车
    drawCart(draw, room, v, cart.startX, true);
    drawCart(draw, room, v, cart.endX, false);

    // 停车窝
    if (Math.abs(cart.startX - cart.endX) > 4) {
        const wx = pxX(v, cart.endX, room);
        const wy = pxY(v, cart.baseY);
        draw.drawSegment(Vec2(wx - 0.9 * cart.wheelR * v.scale, wy), Vec2(wx + 0.9 * cart.wheelR * v.scale, wy), 2 * PX, INK);
        draw.drawSegment(Vec2(wx - 0.7 * cart.wheelR * v.scale, wy - 6 * PX), Vec2(wx - 0.7 * cart.wheelR * v.scale, wy + 3 * PX), 1 * PX, INK);
        draw.drawSegment(Vec2(wx + 0.7 * cart.wheelR * v.scale, wy - 6 * PX), Vec2(wx + 0.7 * cart.wheelR * v.scale, wy + 3 * PX), 1 * PX, INK);
    }

    // 标记点：竖引线 + 圆点
    for (let i = 0; i < room.marks.length; i++) {
        const m = room.marks[i];
        const mx = pxX(v, m.x, room);
        const my = pxY(v, m.y);
        const c = markColor(m.kind);
        draw.drawSegment(Vec2(mx, my), Vec2(mx, pxY(v, room.height - 26)), 1 * PX, c);
        draw.drawDot(Vec2(mx, my), 4.5 * PX, c);
        draw.drawRing(Vec2(mx, my), 8 * PX, 10 * PX, Color(0, 0, 0, 0), 1 * PX, c);
        draw.drawDot(Vec2(mx, pxY(v, room.height - 26)), 4 * PX, c);
    }

    // 出生点剪影
    for (let i = 0; i < room.spawns.length; i++) {
        const s = room.spawns[i];
        drawFigure(draw, v, room, s.x, s.y, s.h, i === 0 ? Color(198, 176, 132, 210) : Color(168, 180, 198, 210));
    }

    // 尺寸线
    for (let i = 0; i < room.dims.length; i++) {
        const d = room.dims[i];
        const y = dimPxY(v, i);
        const xa = pxX(v, Math.min(d.x0, d.x1), room);
        const xb = pxX(v, Math.max(d.x0, d.x1), room);
        draw.drawSegment(Vec2(xa, y), Vec2(xb, y), 1 * PX, DIM_LINE);
        draw.drawSegment(Vec2(xa, y - 6 * PX), Vec2(xa, y + 6 * PX), 1 * PX, DIM_LINE);
        draw.drawSegment(Vec2(xb, y - 6 * PX), Vec2(xb, y + 6 * PX), 1 * PX, DIM_LINE);
    }
}

function markColor(kind: number): Color.Type {
    if (kind === 0) {
        return CHECK;
    }
    if (kind === 1) {
        return STAND;
    }
    if (kind === 2) {
        return EXIT;
    }
    return LAND;
}

function drawStairs(draw: DrawNode.Type, room: RoomSpec, v: Viewbox, s: StairSpec): void {
    // 从 (x1, y1) 走到 (x0, y0)，steps 级
    let prevX = pxX(v, s.x1, room);
    let prevY = pxY(v, s.y1);
    for (let i = 1; i <= s.steps; i++) {
        const t = i / s.steps;
        const nx = pxX(v, s.x1 - (s.x1 - s.x0) * t, room);
        const ny = pxY(v, s.y1 - (s.y1 - s.y0) * t);
        draw.drawSegment(Vec2(prevX, prevY), Vec2(nx, prevY), 2 * PX, INK);
        draw.drawSegment(Vec2(nx, prevY), Vec2(nx, ny), 2 * PX, INK);
        prevX = nx;
        prevY = ny;
    }
}

function drawCart(draw: DrawNode.Type, room: RoomSpec, v: Viewbox, cx: number, ghost: boolean): void {
    const c = room.cart;
    const half = c.bodyW / 2;
    const y0 = c.baseY;
    const yBody = y0 + c.wheelR * 1.2;
    const yTop = yBody + c.bodyH;
    const fill = ghost ? Color(90, 62, 48, 90) : CART_FILL;
    const edge = ghost ? Color(150, 110, 96, 150) : Color(196, 152, 124, 255);

    // 车身（车轴 ± half）
    draw.drawRect(rectOf(v, room, cx - half, cx + half, yBody, yTop), fill);
    draw.drawRect(rectOf(v, room, cx - half, cx + half, yBody, yTop), Color(0, 0, 0, 0), 1.5 * PX, edge);

    // 车轮（车轴处）
    draw.drawCircle(Vec2(pxX(v, cx, room), pxY(v, y0 + c.wheelR)), c.wheelR * v.scale, fill);
    draw.drawRing(
        Vec2(pxX(v, cx, room), pxY(v, y0 + c.wheelR)),
        c.wheelR * v.scale * 0.5,
        c.wheelR * v.scale + 1 * PX,
        Color(0, 0, 0, 0),
        1.5 * PX,
        edge,
    );
    draw.drawDot(Vec2(pxX(v, cx, room), pxY(v, y0 + c.wheelR)), 2.5 * PX, edge);

    // 外侧手柄
    const hx = cx + c.handleOffset;
    draw.drawSegment(Vec2(pxX(v, hx, room), pxY(v, y0)), Vec2(pxX(v, hx, room), pxY(v, yTop + c.bodyH * 0.5)), 2 * PX, edge);
    draw.drawDot(Vec2(pxX(v, hx, room), pxY(v, yTop + c.bodyH * 0.5)), 3 * PX, edge);

    // 红布：系在 clothSide 那一端，垂下来
    const clothX = cx + half * c.clothSide;
    draw.drawPolygon([
        Vec2(pxX(v, clothX, room), pxY(v, yTop)),
        Vec2(pxX(v, clothX - 10 * c.clothSide, room), pxY(v, yTop - 3)),
        Vec2(pxX(v, clothX - 14 * c.clothSide, room), pxY(v, yTop - 34)),
        Vec2(pxX(v, clothX + 2 * c.clothSide, room), pxY(v, yTop - 30)),
    ], ghost ? Color(120, 46, 42, 120) : CLOTH);
}

function drawFigure(draw: DrawNode.Type, v: Viewbox, room: RoomSpec, x: number, y: number, bodyH: number, color: Color.Type): void {
    const headR = bodyH * 0.075;
    const cx = pxX(v, x, room);
    const foot = pxY(v, y + 2);
    const shoulder = pxY(v, y + bodyH * 0.86);
    const headC = pxY(v, y + bodyH - headR);
    draw.drawRect(Rect(cx - 0.11 * bodyH * v.scale, pxY(v, y + bodyH * 0.42), 0.22 * bodyH * v.scale, bodyH * 0.44 * v.scale), color);
    draw.drawSegment(Vec2(cx - 0.06 * bodyH * v.scale, pxY(v, y + bodyH * 0.42)), Vec2(cx - 0.08 * bodyH * v.scale, foot), 2 * PX, color);
    draw.drawSegment(Vec2(cx + 0.06 * bodyH * v.scale, pxY(v, y + bodyH * 0.42)), Vec2(cx + 0.08 * bodyH * v.scale, foot), 2 * PX, color);
    draw.drawSegment(Vec2(cx - 0.11 * bodyH * v.scale, shoulder), Vec2(cx - 0.2 * bodyH * v.scale, pxY(v, y + bodyH * 0.5)), 2 * PX, color);
    draw.drawSegment(Vec2(cx + 0.11 * bodyH * v.scale, shoulder), Vec2(cx + 0.2 * bodyH * v.scale, pxY(v, y + bodyH * 0.5)), 2 * PX, color);
    draw.drawCircle(Vec2(cx, headC), headR * v.scale, color);
}

/** 收集当前房间的文字标签（屏幕坐标，root 左下原点）。 */
export function collectLabels(room: RoomSpec, v: Viewbox, w: number): LabelSpec[] {
    const out: LabelSpec[] = [];

    // 出生点：名字放在头顶
    for (let i = 0; i < room.spawns.length; i++) {
        const s = room.spawns[i];
        out.push({
            x: pxX(v, s.x, room),
            y: pxY(v, s.y + s.h) + (8 + i * 26) * PX,
            text: s.label,
            ax: 0.5,
            ay: 0,
            color: INK,
            size: 12 * PX,
        });
    }
    // 实体：名字放在顶上
    for (let i = 0; i < room.solids.length; i++) {
        const s = room.solids[i];
        out.push({
            x: pxX(v, s.x + s.w / 2, room),
            y: pxY(v, s.y + s.h) + 8 * PX,
            text: s.label,
            ax: 0.5,
            ay: 0,
            color: INK,
            size: 12 * PX,
        });
    }
    // 危险段
    for (let i = 0; i < room.zones.length; i++) {
        const z = room.zones[i];
        if (z.label.length === 0) {
            continue;
        }
        out.push({
            x: pxX(v, (z.x0 + z.x1) / 2, room),
            y: pxY(v, z.y + z.h) + 8 * PX,
            text: z.label,
            ax: 0.5,
            ay: 0,
            color: DANGER_LINE,
            size: 12 * PX,
        });
    }
    // 拱
    if (room.arch.x1 > room.arch.x0) {
        out.push({
            x: pxX(v, (room.arch.x0 + room.arch.x1) / 2, room),
            y: pxY(v, room.arch.y + room.arch.h) + 10 * PX,
            text: room.arch.label,
            ax: 0.5,
            ay: 0,
            color: INK,
            size: 12 * PX,
        });
    }
    // 台阶
    for (let i = 0; i < room.stairs.length; i++) {
        const s = room.stairs[i];
        out.push({
            x: pxX(v, (s.x0 + s.x1) / 2, room),
            y: pxY(v, s.y1) + 8 * PX,
            text: s.label,
            ax: 0.5,
            ay: 0,
            color: INK_DIM,
            size: 11 * PX,
        });
    }
    // 标记点：名字挂在顶部引线端头
    for (let i = 0; i < room.marks.length; i++) {
        const m = room.marks[i];
        out.push({
            x: pxX(v, m.x, room),
            y: pxY(v, room.height - 26) + 6 * PX,
            text: m.label,
            ax: 0.5,
            ay: 0,
            color: markColor(m.kind),
            size: 11 * PX,
        });
    }
    // 尺寸
    for (let i = 0; i < room.dims.length; i++) {
        const d = room.dims[i];
        const mid = (pxX(v, d.x0, room) + pxX(v, d.x1, room)) / 2;
        out.push({ x: mid, y: dimPxY(v, i) - 3 * PX, text: d.text, ax: 0.5, ay: 0, color: DIM_LINE, size: 11 * PX });
    }
    // 板车起终点
    out.push({
        x: pxX(v, room.cart.startX, room),
        y: pxY(v, room.cart.baseY + room.cart.wheelR * 1.2 + room.cart.bodyH) + 8 * PX,
        text: "车 · 起点",
        ax: 0.5,
        ay: 0,
        color: INK_DIM,
        size: 11 * PX,
    });
    out.push({
        x: pxX(v, room.cart.endX, room),
        y: pxY(v, room.cart.baseY + room.cart.wheelR * 1.2 + room.cart.bodyH) + 34 * PX,
        text: "车 · 停靠位",
        ax: 0.5,
        ay: 0,
        color: INK_DIM,
        size: 11 * PX,
    });

    return out;
}

/** 1 米比例尺：画在灰盒顶部上方。世界单位 1 米 ≈ 54.3 单位，这里按 64 单位画一段，标注约 1.18 m。 */
export function drawScaleRuler(draw: DrawNode.Type, x: number, yBase: number, unitPx: number): void {
    const yTop = yBase + unitPx;
    draw.drawSegment(Vec2(x, yBase), Vec2(x, yTop), 1.5 * PX, INK_DIM);
    draw.drawSegment(Vec2(x - 8 * PX, yBase), Vec2(x + 8 * PX, yBase), 1.5 * PX, INK_DIM);
    draw.drawSegment(Vec2(x - 8 * PX, yTop), Vec2(x + 8 * PX, yTop), 1.5 * PX, INK_DIM);
    draw.drawSegment(Vec2(x - 5 * PX, yBase + unitPx / 2), Vec2(x + 5 * PX, yBase + unitPx / 2), 1 * PX, INK_DIM);
}
