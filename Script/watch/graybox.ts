/**
 * 灰盒绘制：只画形状，不画文字。文字由 app.ts 的标签池按 LabelSpec 摆放。
 *
 * 坐标：世界单位（米）→ 屏幕像素，px = padX + (x - minX) * scale，py = groundPx + y * scale。
 * PX 是「屏幕像素常数的倍率」：Dora 在 Retina 上按物理像素渲染（2560×1440），
 * 导出 PNG 会被缩到 1280×720，所以线宽、字号、间距一律 ×PX，保证导出图仍然可读。
 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { RoomSpec } from "Script/watch/rooms";

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
const BG_NEAR = Color(40, 43, 46, 255);
const GROUND = Color(96, 98, 96, 255);
const SOLID_FILL = Color(84, 86, 84, 255);
const CART_FILL = Color(122, 78, 56, 255);
const CLOTH = Color(178, 52, 46, 255);
const HOLE_FILL = Color(12, 13, 14, 255);
const DANGER = Color(150, 54, 48, 70);
const DANGER_LINE = Color(178, 78, 64, 220);
const PLATFORM = Color(112, 116, 108, 80);
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
    return v.groundPx - 30 * PX - i * 24 * PX;
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

/** 画背景、地面、台面、实体、门洞、板车、低洞、车辙、标记点。 */
export function renderWorld(draw: DrawNode.Type, room: RoomSpec, v: Viewbox, w: number, h: number): void {
    const ground = pxY(v, 0);
    const top = pxY(v, room.height);

    // 三层景深
    draw.drawRect(Rect(0, 0, w, h), BG_FAR);
    draw.drawRect(Rect(0, ground, w, top - ground), BG_MID);
    draw.drawRect(Rect(0, ground, w, (top - ground) * 0.34), BG_NEAR);

    // 地面
    draw.drawSegment(Vec2(v.padX - 24 * PX, ground), Vec2(w - v.padX + 24 * PX, ground), 3 * PX, GROUND);

    // 台面（装卸台、北路口）
    for (let i = 0; i < room.zones.length; i++) {
        const z = room.zones[i];
        if (z.tint === 2) {
            draw.drawRect(rectOf(v, room, z.x0, z.x1, 0, 0.16), PLATFORM);
        }
    }

    // 危险区
    for (let i = 0; i < room.zones.length; i++) {
        const z = room.zones[i];
        if (z.tint === 1) {
            draw.drawRect(rectOf(v, room, z.x0, z.x1, 0, z.h), DANGER);
            draw.drawSegment(
                Vec2(pxX(v, z.x0, room), pxY(v, z.h)),
                Vec2(pxX(v, z.x1, room), pxY(v, z.h)),
                1 * PX,
                DANGER_LINE,
            );
        }
    }

    // 实体
    for (let i = 0; i < room.solids.length; i++) {
        const s = room.solids[i];
        draw.drawRect(rectOf(v, room, s.x, s.x + s.w, 0, s.h), SOLID_FILL);
        draw.drawRect(rectOf(v, room, s.x, s.x + s.w, 0, s.h), Color(0, 0, 0, 0), 1.5 * PX, INK_DIM);
    }

    // 门洞：门框 + 落下的大门
    for (let i = 0; i < room.gates.length; i++) {
        const g = room.gates[i];
        const x0 = g.x - g.w / 2;
        const x1 = g.x + g.w / 2;
        draw.drawRect(rectOf(v, room, x0, x1, 0, g.h), Color(18, 19, 20, 255));
        draw.drawRect(rectOf(v, room, x0, x1, 0, g.h), Color(0, 0, 0, 0), 2 * PX, INK);
        draw.drawSegment(Vec2(pxX(v, x0, room), pxY(v, g.h)), Vec2(pxX(v, x1, room), pxY(v, g.h)), 2.5 * PX, INK);
        // 落下的门扇
        draw.drawRect(rectOf(v, room, x0 + 0.12, x1 - 0.12, 0, g.h - 0.12), Color(70, 72, 74, 210));
        draw.drawSegment(
            Vec2(pxX(v, x0 + 0.12, room), pxY(v, 0)),
            Vec2(pxX(v, x0 + 0.12, room), pxY(v, g.h - 0.12)),
            1 * PX,
            INK_DIM,
        );
        draw.drawSegment(
            Vec2(pxX(v, x1 - 0.12, room), pxY(v, 0)),
            Vec2(pxX(v, x1 - 0.12, room), pxY(v, g.h - 0.12)),
            1 * PX,
            INK_DIM,
        );
    }

    // 低洞：半个矮拱
    if (room.hole.w > 0) {
        const hl = room.hole;
        draw.drawRect(rectOf(v, room, hl.x, hl.x + hl.w, 0, hl.h), HOLE_FILL);
        draw.drawRect(rectOf(v, room, hl.x, hl.x + hl.w, 0, hl.h), Color(0, 0, 0, 0), 2 * PX, INK);
        draw.drawArc(
            Vec2(pxX(v, hl.x + hl.w / 2, room), pxY(v, hl.h * 0.62)),
            (hl.w / 2) * v.scale,
            0,
            180,
            2 * PX,
            INK,
        );
    }

    // 车辙：板车两端之间两条平行线
    const cart = room.cart;
    const lo = Math.min(cart.startX, cart.endX);
    const hi = Math.max(cart.startX, cart.endX);
    if (hi - lo > 0.05) {
        draw.drawSegment(Vec2(pxX(v, lo, room), pxY(v, 0.04)), Vec2(pxX(v, hi, room), pxY(v, 0.04)), 1 * PX, INK_DIM);
        draw.drawSegment(Vec2(pxX(v, lo, room), pxY(v, 0.12)), Vec2(pxX(v, hi, room), pxY(v, 0.12)), 1 * PX, INK_DIM);
        draw.drawSegment(Vec2(pxX(v, lo, room), pxY(v, 0.02)), Vec2(pxX(v, lo, room), pxY(v, 0.14)), 1 * PX, INK_DIM);
        draw.drawSegment(Vec2(pxX(v, hi, room), pxY(v, 0.02)), Vec2(pxX(v, hi, room), pxY(v, 0.14)), 1 * PX, INK_DIM);
    }

    // 板车：起点虚影 + 终点实车
    drawCart(draw, room, v, cart.startX, true);
    drawCart(draw, room, v, cart.endX, false);

    // 停车窝（车轮落窝）
    if (Math.abs(cart.startX - cart.endX) > 0.05) {
        const wx = pxX(v, cart.endX, room);
        draw.drawSegment(Vec2(wx - 0.34 * v.scale, pxY(v, -0.02)), Vec2(wx + 0.34 * v.scale, pxY(v, -0.02)), 2 * PX, INK);
        draw.drawSegment(Vec2(wx - 0.26 * v.scale, pxY(v, -0.1)), Vec2(wx - 0.26 * v.scale, pxY(v, 0.02)), 1 * PX, INK);
        draw.drawSegment(Vec2(wx + 0.26 * v.scale, pxY(v, -0.1)), Vec2(wx + 0.26 * v.scale, pxY(v, 0.02)), 1 * PX, INK);
    }

    // 标记点：检查点 / 站位 / 出口 / 地标
    for (let i = 0; i < room.marks.length; i++) {
        const m = room.marks[i];
        const mx = pxX(v, m.x, room);
        const my = pxY(v, 1.9);
        const c = m.kind === 0 ? CHECK : m.kind === 1 ? STAND : m.kind === 2 ? EXIT : LAND;
        draw.drawSegment(Vec2(mx, pxY(v, 0.05)), Vec2(mx, my - 12 * PX), 1 * PX, c);
        draw.drawDot(Vec2(mx, my), 4.5 * PX, c);
        draw.drawRing(Vec2(mx, my), 8 * PX, 10 * PX, Color(0, 0, 0, 0), 1 * PX, c);
    }

    // 出生点：两个身高剪影
    for (let i = 0; i < room.spawns.length; i++) {
        const s = room.spawns[i];
        const bodyH = i === 0 ? 1.18 : 1.8;
        drawFigure(draw, v, room, s.x, bodyH, i === 0 ? Color(198, 176, 132, 200) : Color(168, 180, 198, 200));
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

function drawCart(draw: DrawNode.Type, room: RoomSpec, v: Viewbox, cx: number, ghost: boolean): void {
    const c = room.cart;
    const x0 = cx - c.bodyW / 2;
    const x1 = cx + c.bodyW / 2;
    const fill = ghost ? Color(90, 62, 48, 90) : CART_FILL;
    const edge = ghost ? Color(150, 110, 96, 150) : Color(196, 152, 124, 255);

    // 车板
    draw.drawRect(rectOf(v, room, x0, x1, c.wheelR * 0.6, c.bodyH), fill);
    draw.drawRect(rectOf(v, room, x0, x1, c.wheelR * 0.6, c.bodyH), Color(0, 0, 0, 0), 1.5 * PX, edge);

    // 车轮
    draw.drawCircle(Vec2(pxX(v, x1 - 0.32, room), pxY(v, c.wheelR)), c.wheelR * v.scale, fill);
    draw.drawRing(
        Vec2(pxX(v, x1 - 0.32, room), pxY(v, c.wheelR)),
        c.wheelR * v.scale * 0.55,
        c.wheelR * v.scale + 1 * PX,
        Color(0, 0, 0, 0),
        1.5 * PX,
        edge,
    );
    draw.drawDot(Vec2(pxX(v, x1 - 0.32, room), pxY(v, c.wheelR)), 2.5 * PX, edge);

    // 车把（左端）：两根斜杆
    draw.drawSegment(Vec2(pxX(v, x0, room), pxY(v, c.bodyH)), Vec2(pxX(v, x0 - 0.42, room), pxY(v, c.handleH)), 2 * PX, edge);
    draw.drawSegment(
        Vec2(pxX(v, x0, room), pxY(v, c.bodyH - 0.14)),
        Vec2(pxX(v, x0 - 0.42, room), pxY(v, c.handleH - 0.14)),
        2 * PX,
        edge,
    );

    // 红布：绑在车把上，向右上方垂下
    draw.drawPolygon([
        Vec2(pxX(v, x0 - 0.42, room), pxY(v, c.handleH)),
        Vec2(pxX(v, x0 - 0.08, room), pxY(v, c.handleH - 0.06)),
        Vec2(pxX(v, x0 - 0.04, room), pxY(v, c.handleH - 0.44)),
        Vec2(pxX(v, x0 - 0.46, room), pxY(v, c.handleH - 0.36)),
    ], ghost ? Color(120, 46, 42, 120) : CLOTH);
}

function drawFigure(draw: DrawNode.Type, v: Viewbox, room: RoomSpec, x: number, bodyH: number, color: Color.Type): void {
    const headR = bodyH * 0.075;
    const cx = pxX(v, x, room);
    const foot = pxY(v, 0.06);
    const shoulder = pxY(v, bodyH * 0.86);
    const headC = pxY(v, bodyH - headR);
    // 躯干
    draw.drawRect(Rect(cx - 0.13 * v.scale, pxY(v, bodyH * 0.42), 0.26 * v.scale, (bodyH * 0.44) * v.scale), color);
    // 腿
    draw.drawSegment(Vec2(cx - 0.07 * v.scale, pxY(v, bodyH * 0.42)), Vec2(cx - 0.09 * v.scale, foot), 2 * PX, color);
    draw.drawSegment(Vec2(cx + 0.07 * v.scale, pxY(v, bodyH * 0.42)), Vec2(cx + 0.09 * v.scale, foot), 2 * PX, color);
    // 手臂
    draw.drawSegment(Vec2(cx - 0.13 * v.scale, shoulder), Vec2(cx - 0.24 * v.scale, pxY(v, bodyH * 0.5)), 2 * PX, color);
    draw.drawSegment(Vec2(cx + 0.13 * v.scale, shoulder), Vec2(cx + 0.24 * v.scale, pxY(v, bodyH * 0.5)), 2 * PX, color);
    // 头
    draw.drawCircle(Vec2(cx, headC), headR * v.scale, color);
}

/** 收集当前房间的文字标签（屏幕坐标，root 左下原点）。 */
export function collectLabels(room: RoomSpec, v: Viewbox, w: number): LabelSpec[] {
    const out: LabelSpec[] = [];

    for (let i = 0; i < room.spawns.length; i++) {
        const s = room.spawns[i];
        out.push({ x: pxX(v, s.x, room), y: pxY(v, 1.94), text: s.label, ax: 0.5, ay: 0, color: INK, size: 12 * PX });
    }
    for (let i = 0; i < room.solids.length; i++) {
        const s = room.solids[i];
        out.push({
            x: pxX(v, s.x + s.w / 2, room),
            y: pxY(v, s.h) + 6 * PX,
            text: s.label,
            ax: 0.5,
            ay: 0,
            color: INK,
            size: 12 * PX,
        });
    }
    for (let i = 0; i < room.gates.length; i++) {
        const g = room.gates[i];
        out.push({ x: pxX(v, g.x, room), y: pxY(v, g.h) + 8 * PX, text: g.label, ax: 0.5, ay: 0, color: INK, size: 12 * PX });
    }
    for (let i = 0; i < room.zones.length; i++) {
        const z = room.zones[i];
        if (z.label.length === 0) {
            continue;
        }
        if (z.tint === 1) {
            out.push({
                x: pxX(v, (z.x0 + z.x1) / 2, room),
                y: pxY(v, z.h) + 6 * PX,
                text: z.label,
                ax: 0.5,
                ay: 0,
                color: DANGER_LINE,
                size: 12 * PX,
            });
        } else {
            out.push({
                x: pxX(v, z.x1, room),
                y: pxY(v, 0.16) + 4 * PX,
                text: z.label,
                ax: 1,
                ay: 0,
                color: INK_DIM,
                size: 11 * PX,
            });
        }
    }
    if (room.hole.w > 0) {
        out.push({
            x: pxX(v, room.hole.x + room.hole.w / 2, room),
            y: pxY(v, room.hole.h) + 8 * PX,
            text: room.hole.label,
            ax: 0.5,
            ay: 0,
            color: INK,
            size: 12 * PX,
        });
    }
    for (let i = 0; i < room.marks.length; i++) {
        const m = room.marks[i];
        const c = m.kind === 0 ? CHECK : m.kind === 1 ? STAND : m.kind === 2 ? EXIT : LAND;
        out.push({ x: pxX(v, m.x, room), y: pxY(v, 1.9) + 10 * PX, text: m.label, ax: 0.5, ay: 0, color: c, size: 11 * PX });
    }
    for (let i = 0; i < room.dims.length; i++) {
        const d = room.dims[i];
        const mid = (pxX(v, d.x0, room) + pxX(v, d.x1, room)) / 2;
        out.push({ x: mid, y: dimPxY(v, i) - 3 * PX, text: d.text, ax: 0.5, ay: 0, color: DIM_LINE, size: 11 * PX });
    }
    // 板车起终点
    out.push({
        x: pxX(v, room.cart.startX, room),
        y: pxY(v, room.cart.bodyH) + 46 * PX,
        text: "车 · 起点",
        ax: 0.5,
        ay: 0,
        color: INK_DIM,
        size: 11 * PX,
    });
    out.push({
        x: pxX(v, room.cart.endX, room),
        y: pxY(v, room.cart.bodyH) + 8 * PX,
        text: "车 · 停靠位",
        ax: 0.5,
        ay: 0,
        color: INK_DIM,
        size: 11 * PX,
    });

    return out;
}

/** 1 米比例尺：画在灰盒顶部上方，用于直接读灰盒里的高度。 */
export function drawScaleRuler(draw: DrawNode.Type, x: number, yBase: number, unitPx: number): void {
    const yTop = yBase + unitPx;
    draw.drawSegment(Vec2(x, yBase), Vec2(x, yTop), 1.5 * PX, INK_DIM);
    draw.drawSegment(Vec2(x - 8 * PX, yBase), Vec2(x + 8 * PX, yBase), 1.5 * PX, INK_DIM);
    draw.drawSegment(Vec2(x - 8 * PX, yTop), Vec2(x + 8 * PX, yTop), 1.5 * PX, INK_DIM);
    draw.drawSegment(Vec2(x - 5 * PX, yBase + unitPx / 2), Vec2(x + 5 * PX, yBase + unitPx / 2), 1 * PX, INK_DIM);
}
