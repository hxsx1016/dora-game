/**
 * 艾希（ICEY）参考视觉体系：色板、8 房间氛围配置、渐变与斜切几何原语。
 *
 * 设计基调：
 * - 深冷钢蓝/黑岩废墟底色（高纵深低明度）
 * - 高对比霓虹功能色切割：冷冰青（周戍/战术/护盾）、暖琥珀（小满/指南针/塔灯）、
 *   霓虹绯红（敌意/激光预警/红布图腾）
 * - 所有发光与大气效果均通过 DrawNode.drawVertices 顶点渐变与 Additive 混合实现，
 *   零外部贴图即可在 Dora SSR 原生与 WebGL 端渲染出锐利通透的光影层次。
 */

import { Color, DrawNode, Vec2 } from "Dora";

export interface RGBA {
    r: number;
    g: number;
    b: number;
    a: number;
}

export function rgba(r: number, g: number, b: number, a: number = 255): RGBA {
    return { r, g, b, a };
}

export function toColor(c: RGBA, alphaOverride?: number): Color.Type {
    const a = alphaOverride !== undefined ? Math.max(0, Math.min(255, Math.round(alphaOverride))) : c.a;
    return Color(c.r, c.g, c.b, a);
}

export function lerpRGBA(a: RGBA, b: RGBA, t: number): RGBA {
    const k = Math.max(0, Math.min(1, t));
    return {
        r: Math.round(a.r + (b.r - a.r) * k),
        g: Math.round(a.g + (b.g - a.g) * k),
        b: Math.round(a.b + (b.b - a.b) * k),
        a: Math.round(a.a + (b.a - a.a) * k),
    };
}

/** 通用 ICEY 功能色 Token */
export const PALETTE = {
    voidDark: rgba(5, 8, 14, 255),
    panelBg: rgba(9, 14, 24, 218),
    panelBgDeep: rgba(6, 10, 18, 238),
    steelDark: rgba(20, 28, 42, 255),
    steelMid: rgba(34, 46, 66, 255),
    steelLight: rgba(68, 86, 114, 255),
    rimSilver: rgba(148, 178, 210, 255),

    // 周戍 / 战术 / ICEY 标志冰青
    cyanCore: rgba(215, 250, 255, 255),
    cyan: rgba(72, 224, 255, 255),
    cyanDim: rgba(32, 128, 168, 255),
    cyanGlow: rgba(56, 210, 255, 110),

    // 小满 / 指南针 / 塔灯暖琥珀
    amberCore: rgba(255, 242, 212, 255),
    amber: rgba(242, 188, 96, 255),
    amberDim: rgba(154, 112, 54, 255),
    amberGlow: rgba(246, 196, 108, 100),

    // 敌意 / 预警 / 红布绯红
    crimsonCore: rgba(255, 206, 214, 255),
    crimson: rgba(255, 48, 82, 255),
    crimsonDeep: rgba(176, 28, 48, 255),
    crimsonGlow: rgba(255, 42, 78, 110),

    // 安全 / 同步完成 / 玻璃瓶翡翠青
    emerald: rgba(84, 232, 168, 255),
    emeraldDim: rgba(38, 118, 88, 255),

    // 文字
    textBright: rgba(238, 244, 252, 255),
    textMid: rgba(164, 182, 206, 255),
    textDim: rgba(102, 120, 146, 255),

    // 道具
    cartWood: rgba(82, 54, 44, 255),
    cartMetal: rgba(114, 126, 142, 255),
    clothRed: rgba(216, 40, 56, 255),
    clothRedHighlight: rgba(252, 92, 104, 255),
};

export type AmbientKind = "ash" | "drizzle" | "spores" | "motes";

export interface RoomTheme {
    key: string;
    actCode: string;
    titleZh: string;
    titleEn: string;
    lineTag: string;
    skyTop: RGBA;
    skyMid: RGBA;
    skyHorizon: RGBA;
    farBuilding: RGBA;
    midBuilding: RGBA;
    fogBottom: RGBA;
    groundTop: RGBA;
    groundBody: RGBA;
    groundRim: RGBA;
    accent: RGBA;
    beamColor: RGBA;
    ambient: AmbientKind;
    showSearchlights: boolean;
    showTowerBeacon: boolean;
    showMoon: boolean;
    moonXFrac: number;
    moonYFrac: number;
    defaultZoom: number;
    introWhisper: string;
}

export const ROOM_THEMES: Record<string, RoomTheme> = {
    prologue: {
        key: "prologue",
        actCode: "ACT 01",
        titleZh: "序章 · 倒柜后",
        titleEn: "PROLOGUE // BROKEN WARD",
        lineTag: "SOLDIER LINE",
        skyTop: rgba(5, 8, 16, 255),
        skyMid: rgba(11, 20, 36, 255),
        skyHorizon: rgba(22, 38, 62, 255),
        farBuilding: rgba(11, 18, 30, 255),
        midBuilding: rgba(17, 26, 42, 255),
        fogBottom: rgba(34, 68, 102, 72),
        groundTop: rgba(42, 54, 72, 255),
        groundBody: rgba(15, 21, 32, 255),
        groundRim: rgba(96, 198, 236, 220),
        accent: PALETTE.cyan,
        beamColor: rgba(88, 206, 255, 42),
        ambient: "ash",
        showSearchlights: true,
        showTowerBeacon: false,
        showMoon: true,
        moonXFrac: 0.78,
        moonYFrac: 0.78,
        defaultZoom: 1.12,
        introWhisper: "城破前夜。她在倒塌的柜子后面。",
    },
    street: {
        key: "street",
        actCode: "ACT 02",
        titleZh: "街道 · 封锁线",
        titleEn: "SECTOR 02 // BURNING AVENUE",
        lineTag: "SOLDIER LINE",
        skyTop: rgba(7, 9, 18, 255),
        skyMid: rgba(16, 22, 38, 255),
        skyHorizon: rgba(36, 34, 54, 255),
        farBuilding: rgba(13, 18, 30, 255),
        midBuilding: rgba(21, 27, 42, 255),
        fogBottom: rgba(68, 56, 84, 74),
        groundTop: rgba(46, 54, 68, 255),
        groundBody: rgba(16, 20, 30, 255),
        groundRim: rgba(102, 194, 232, 215),
        accent: PALETTE.cyan,
        beamColor: rgba(108, 196, 255, 44),
        ambient: "ash",
        showSearchlights: true,
        showTowerBeacon: false,
        showMoon: true,
        moonXFrac: 0.82,
        moonYFrac: 0.80,
        defaultZoom: 1.0,
        introWhisper: "带她穿过街心。别让火力压住她的步子。",
    },
    checkpoint: {
        key: "checkpoint",
        actCode: "ACT 03",
        titleZh: "检查站 · 装卸台",
        titleEn: "SECTOR 03 // CHECKPOINT DOCK",
        lineTag: "SOLDIER LINE",
        skyTop: rgba(6, 10, 19, 255),
        skyMid: rgba(13, 23, 40, 255),
        skyHorizon: rgba(26, 44, 68, 255),
        farBuilding: rgba(12, 20, 34, 255),
        midBuilding: rgba(19, 30, 48, 255),
        fogBottom: rgba(40, 86, 122, 68),
        groundTop: rgba(44, 58, 76, 255),
        groundBody: rgba(14, 20, 31, 255),
        groundRim: rgba(86, 218, 252, 230),
        accent: PALETTE.cyan,
        beamColor: rgba(74, 214, 255, 46),
        ambient: "ash",
        showSearchlights: true,
        showTowerBeacon: false,
        showMoon: true,
        moonXFrac: 0.74,
        moonYFrac: 0.82,
        defaultZoom: 1.0,
        introWhisper: "把那辆系着红布的板车推进装卸窝，城门才会放行。",
    },
    gate: {
        key: "gate",
        actCode: "ACT 04",
        titleZh: "城门 · 四十五秒",
        titleEn: "SECTOR 04 // LAST STAND GATE",
        lineTag: "SOLDIER LINE",
        skyTop: rgba(11, 7, 14, 255),
        skyMid: rgba(26, 15, 26, 255),
        skyHorizon: rgba(58, 24, 34, 255),
        farBuilding: rgba(18, 13, 22, 255),
        midBuilding: rgba(28, 20, 32, 255),
        fogBottom: rgba(128, 36, 48, 68),
        groundTop: rgba(54, 48, 58, 255),
        groundBody: rgba(18, 15, 24, 255),
        groundRim: rgba(255, 86, 108, 210),
        accent: PALETTE.crimson,
        beamColor: rgba(255, 72, 96, 46),
        ambient: "ash",
        showSearchlights: true,
        showTowerBeacon: false,
        showMoon: true,
        moonXFrac: 0.22,
        moonYFrac: 0.80,
        defaultZoom: 0.92,
        introWhisper: "把她送到门洞，守住绞盘四十五秒。",
    },
    outside: {
        key: "outside",
        actCode: "ACT 05",
        titleZh: "城墙外 · 拱与红布",
        titleEn: "OUTSKIRTS 05 // WALL & ARCHWAY",
        lineTag: "CHILD LINE",
        skyTop: rgba(5, 9, 18, 255),
        skyMid: rgba(11, 20, 38, 255),
        skyHorizon: rgba(24, 40, 66, 255),
        farBuilding: rgba(10, 17, 30, 255),
        midBuilding: rgba(16, 26, 44, 255),
        fogBottom: rgba(44, 68, 106, 68),
        groundTop: rgba(46, 56, 72, 255),
        groundBody: rgba(14, 19, 30, 255),
        groundRim: rgba(154, 196, 232, 200),
        accent: PALETTE.amber,
        beamColor: rgba(142, 194, 255, 32),
        ambient: "drizzle",
        showSearchlights: false,
        showTowerBeacon: true,
        showMoon: true,
        moonXFrac: 0.68,
        moonYFrac: 0.82,
        defaultZoom: 0.96,
        introWhisper: "门后再没有人应声。把板车拉进空窝，蹲着穿过低拱。",
    },
    village: {
        key: "village",
        actCode: "ACT 06",
        titleZh: "废弃村庄 · 砖地一响",
        titleEn: "OUTSKIRTS 06 // RUINED COURTYARD",
        lineTag: "CHILD LINE",
        skyTop: rgba(7, 10, 17, 255),
        skyMid: rgba(15, 22, 34, 255),
        skyHorizon: rgba(34, 42, 56, 255),
        farBuilding: rgba(13, 18, 28, 255),
        midBuilding: rgba(22, 28, 40, 255),
        fogBottom: rgba(76, 74, 68, 60),
        groundTop: rgba(54, 56, 62, 255),
        groundBody: rgba(17, 20, 26, 255),
        groundRim: rgba(214, 186, 134, 195),
        accent: PALETTE.amber,
        beamColor: rgba(232, 192, 128, 26),
        ambient: "drizzle",
        showSearchlights: false,
        showTowerBeacon: true,
        showMoon: true,
        moonXFrac: 0.78,
        moonYFrac: 0.82,
        defaultZoom: 1.0,
        introWhisper: "别被拾荒者看见。拾起瓶子扔向砖地，趁他转身钻过桌底。",
    },
    forest: {
        key: "forest",
        actCode: "ACT 07",
        titleZh: "北塔森林 · 听风辨步",
        titleEn: "OUTSKIRTS 07 // NORTHWOOD",
        lineTag: "CHILD LINE",
        skyTop: rgba(4, 10, 14, 255),
        skyMid: rgba(9, 24, 30, 255),
        skyHorizon: rgba(20, 48, 54, 255),
        farBuilding: rgba(8, 20, 24, 255),
        midBuilding: rgba(13, 32, 36, 255),
        fogBottom: rgba(42, 112, 118, 68),
        groundTop: rgba(32, 58, 56, 255),
        groundBody: rgba(11, 22, 24, 255),
        groundRim: rgba(112, 214, 186, 205),
        accent: PALETTE.emerald,
        beamColor: rgba(108, 232, 198, 28),
        ambient: "spores",
        showSearchlights: false,
        showTowerBeacon: true,
        showMoon: true,
        moonXFrac: 0.72,
        moonYFrac: 0.84,
        defaultZoom: 1.0,
        introWhisper: "猎犬比人先听见脚步。伏在草影里，向北塔灯火走去。",
    },
    tower: {
        key: "tower",
        actCode: "ACT 08",
        titleZh: "北塔 · 最后一行",
        titleEn: "EPILOGUE // THE NORTH TOWER",
        lineTag: "EPILOGUE",
        skyTop: rgba(6, 10, 20, 255),
        skyMid: rgba(16, 26, 46, 255),
        skyHorizon: rgba(46, 54, 72, 255),
        farBuilding: rgba(13, 20, 34, 255),
        midBuilding: rgba(20, 30, 48, 255),
        fogBottom: rgba(232, 184, 110, 56),
        groundTop: rgba(62, 64, 72, 255),
        groundBody: rgba(18, 22, 30, 255),
        groundRim: rgba(246, 206, 134, 230),
        accent: PALETTE.amber,
        beamColor: rgba(255, 216, 146, 46),
        ambient: "motes",
        showSearchlights: false,
        showTowerBeacon: true,
        showMoon: true,
        moonXFrac: 0.24,
        moonYFrac: 0.80,
        defaultZoom: 1.12,
        introWhisper: "灯亮着。走到门前，像他教你的那样，敲两下。",
    },
};

export function themeOf(key: string): RoomTheme {
    const t = ROOM_THEMES[key];
    return t !== undefined ? t : ROOM_THEMES["prologue"];
}

/** 顶点渐变四边形（按顺时针/逆时针拆成两个三角形） */
export function fillGradQuad(
    draw: DrawNode.Type,
    x0: number, y0: number, c00: Color.Type,
    x1: number, y1: number, c10: Color.Type,
    x2: number, y2: number, c11: Color.Type,
    x3: number, y3: number, c01: Color.Type,
): void {
    const p0 = Vec2(x0, y0);
    const p1 = Vec2(x1, y1);
    const p2 = Vec2(x2, y2);
    const p3 = Vec2(x3, y3);
    draw.drawVertices([
        [p0, c00], [p1, c10], [p2, c11],
        [p0, c00], [p2, c11], [p3, c01],
    ]);
}

/** 竖直方向线性渐变矩形 */
export function fillVGradRect(
    draw: DrawNode.Type,
    x: number, y: number, w: number, h: number,
    bottomCol: Color.Type, topCol: Color.Type,
): void {
    fillGradQuad(
        draw,
        x, y, bottomCol,
        x + w, y, bottomCol,
        x + w, y + h, topCol,
        x, y + h, topCol,
    );
}

/** 水平方向线性渐变矩形 */
export function fillHGradRect(
    draw: DrawNode.Type,
    x: number, y: number, w: number, h: number,
    leftCol: Color.Type, rightCol: Color.Type,
): void {
    fillGradQuad(
        draw,
        x, y, leftCol,
        x + w, y, rightCol,
        x + w, y + h, rightCol,
        x, y + h, leftCol,
    );
}

/** 径向柔和光晕（扇形顶点渐变，配合 Additive DrawNode 效果极佳） */
export function fillRadialGlow(
    draw: DrawNode.Type,
    cx: number, cy: number, rx: number, ry: number,
    innerCol: Color.Type, outerCol: Color.Type,
    segments: number = 18,
): void {
    if (rx <= 0.5 || ry <= 0.5) {
        return;
    }
    const center = Vec2(cx, cy);
    const verts: [Vec2.Type, Color.Type][] = [];
    const step = (Math.PI * 2) / segments;
    let i = 0;
    for (i = 0; i < segments; i++) {
        const a0 = i * step;
        const a1 = (i + 1) * step;
        verts.push([center, innerCol]);
        verts.push([Vec2(cx + Math.cos(a0) * rx, cy + Math.sin(a0) * ry), outerCol]);
        verts.push([Vec2(cx + Math.cos(a1) * rx, cy + Math.sin(a1) * ry), outerCol]);
    }
    draw.drawVertices(verts);
}

/** 艾希风格斜切平行四边形填充 */
export function fillSkewRect(
    draw: DrawNode.Type,
    x: number, y: number, w: number, h: number, skew: number,
    fill: Color.Type, borderW: number = 0, borderCol?: Color.Type,
): void {
    if (w <= 0 || h <= 0) {
        return;
    }
    const pts = [
        Vec2(x, y),
        Vec2(x + w, y),
        Vec2(x + w + skew, y + h),
        Vec2(x + skew, y + h),
    ];
    if (borderW > 0 && borderCol !== undefined) {
        draw.drawPolygon(pts, fill, borderW, borderCol);
    } else {
        draw.drawPolygon(pts, fill);
    }
}

/** 艾希风格倒角切边矩形（左上、右下 45° 切角） */
export function fillChamferBox(
    draw: DrawNode.Type,
    x: number, y: number, w: number, h: number, cut: number,
    fill: Color.Type, borderW: number = 0, borderCol?: Color.Type,
): void {
    const c = Math.min(cut, w * 0.3, h * 0.3);
    const pts = [
        Vec2(x, y),
        Vec2(x + w - c, y),
        Vec2(x + w, y + c),
        Vec2(x + w, y + h),
        Vec2(x + c, y + h),
        Vec2(x, y + h - c),
    ];
    if (borderW > 0 && borderCol !== undefined) {
        draw.drawPolygon(pts, fill, borderW, borderCol);
    } else {
        draw.drawPolygon(pts, fill);
    }
}

/** 菱形标（用于锁定点、节点、恐惧晶格、按键标） */
export function drawDiamond(
    draw: DrawNode.Type,
    cx: number, cy: number, rx: number, ry: number,
    fill: Color.Type, borderW: number = 0, borderCol?: Color.Type,
): void {
    const pts = [
        Vec2(cx, cy + ry),
        Vec2(cx + rx, cy),
        Vec2(cx, cy - ry),
        Vec2(cx - rx, cy),
    ];
    if (borderW > 0 && borderCol !== undefined) {
        draw.drawPolygon(pts, fill, borderW, borderCol);
    } else {
        draw.drawPolygon(pts, fill);
    }
}

/**
 * 估算 UTF-8 中英文混排字符串的视觉像素宽度（Lua 的 string.length 返回字节数，1 个汉字占 3 字节）。
 */
export function visualTextWidth(text: string, fontSize: number): number {
    let units = 0;
    let i = 0;
    for (i = 0; i < text.length; i++) {
        const b = text.charCodeAt(i);
        if (b < 128) {
            units += 0.56;
        } else if (b >= 192) {
            units += 1.02;
        }
    }
    return units * fontSize;
}

/** 工业警示斜纹条（用于掩体、城门、装卸台） */
export function drawHazardStripes(
    draw: DrawNode.Type,
    x: number, y: number, w: number, h: number,
    pitch: number, col: Color.Type,
): void {
    const sw = pitch * 0.45;
    let cur = x - h;
    while (cur < x + w) {
        const x0 = Math.max(x, cur);
        const x1 = Math.min(x + w, cur + sw);
        const tx0 = Math.max(x, cur + h);
        const tx1 = Math.min(x + w, cur + h + sw);
        if (x1 > x0 && tx1 > tx0) {
            draw.drawPolygon([
                Vec2(x0, y),
                Vec2(x1, y),
                Vec2(tx1, y + h),
                Vec2(tx0, y + h),
            ], col);
        }
        cur += pitch;
    }
}
