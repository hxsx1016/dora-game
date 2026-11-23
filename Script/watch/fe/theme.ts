/**
 * 《向西守望》中国水墨视觉体系（参考《饿殍：明末千里行》苍凉克制的水墨美学）：
 * - 传统矿石与墨韵色板（玄墨、淡烟、素宣、陈纸、古铜、黛青、松烟、暗朱砂）
 * - 八房间氛围与汉字卷目配置（壹~捌、上卷孤城护童 / 下卷独赴北塔）
 * - 水墨飞白笔刷、宣纸卷轴框、朱砂篆印、枯笔分隔线原语（优先挂接 ui_ink.clip，缺图自动回退顶点渐变）
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { TextPool } from "Script/watch/fe/ui/textpool";

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

/** 中国水墨矿石色板（兼容原有 Token 命名，确保舞台/角色/道具无破坏接入） */
export const PALETTE = {
    // 玄墨与烟霭底色
    voidDark: rgba(13, 14, 19, 255),
    panelBg: rgba(19, 20, 26, 224),
    panelBgDeep: rgba(14, 15, 20, 240),
    steelDark: rgba(32, 30, 34, 255),
    steelMid: rgba(54, 49, 52, 255),
    steelLight: rgba(112, 97, 82, 255),
    rimSilver: rgba(154, 138, 118, 255),

    // 周戍：冷月黛青 / 霜月素白
    cyanCore: rgba(232, 230, 218, 255),
    cyan: rgba(146, 170, 178, 255),
    cyanDim: rgba(94, 110, 118, 255),
    cyanGlow: rgba(146, 170, 178, 72),

    // 小满 / 指南针 / 北塔残灯：古铜暖金
    amberCore: rgba(246, 228, 188, 255),
    amber: rgba(212, 164, 102, 255),
    amberDim: rgba(134, 100, 64, 255),
    amberGlow: rgba(212, 164, 102, 74),

    // 印鉴 / 战火 / 危急 / 红布：暗朱砂
    crimsonCore: rgba(245, 204, 182, 255),
    crimson: rgba(186, 66, 54, 255),
    crimsonDeep: rgba(124, 38, 34, 255),
    crimsonGlow: rgba(186, 66, 54, 72),

    // 林间隐蔽 / 落窝安抚：松烟青
    emerald: rgba(148, 172, 130, 255),
    emeraldDim: rgba(92, 118, 90, 255),

    // 宣纸与墨文字
    textBright: rgba(243, 233, 212, 255),
    textMid: rgba(202, 191, 172, 255),
    textDim: rgba(146, 139, 130, 255),

    // 水墨与宣纸专用色
    inkVoid: rgba(12, 13, 18, 255),
    inkWash: rgba(15, 16, 22, 255),
    inkMist: rgba(28, 30, 38, 255),
    inkWarm: rgba(42, 31, 28, 255),
    xuanWarm: rgba(226, 211, 182, 255),
    xuanInk: rgba(34, 26, 21, 255),
    xuanInkSub: rgba(88, 70, 54, 255),
    xuanPaper: rgba(226, 212, 184, 255),
    sealRed: rgba(168, 46, 40, 255),
    sealRedBright: rgba(202, 68, 56, 255),
    sealText: rgba(248, 239, 222, 255),
    cinnabar: rgba(182, 62, 52, 255),
    cinnabarDeep: rgba(122, 38, 34, 255),
    bronzeLine: rgba(168, 132, 84, 255),
    bronzeDim: rgba(118, 90, 58, 255),
    moonPale: rgba(228, 229, 218, 255),

    // 道具
    cartWood: rgba(104, 73, 55, 255),
    cartMetal: rgba(125, 110, 97, 255),
    clothRed: rgba(162, 56, 46, 255),
    clothRedHighlight: rgba(208, 96, 76, 255),
};

export type AmbientKind = "ash" | "drizzle" | "spores" | "motes";

export interface RoomTheme {
    key: string;
    numeralZh: string;
    actCode: string;
    titleZh: string;
    titleEn: string;
    lineTag: string;
    volumeTagZh: string;
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
        numeralZh: "壹",
        actCode: "第壹章",
        titleZh: "序章 · 倒柜后",
        titleEn: "孤城护童",
        lineTag: "周戍",
        volumeTagZh: "上卷 · 孤城护童",
        skyTop: rgba(9, 12, 20, 255),
        skyMid: rgba(16, 22, 34, 255),
        skyHorizon: rgba(28, 38, 54, 255),
        farBuilding: rgba(14, 18, 28, 255),
        midBuilding: rgba(22, 26, 38, 255),
        fogBottom: rgba(44, 58, 78, 62),
        groundTop: rgba(46, 52, 62, 255),
        groundBody: rgba(17, 20, 28, 255),
        groundRim: rgba(146, 170, 178, 195),
        accent: PALETTE.cyan,
        beamColor: rgba(140, 168, 184, 34),
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
        numeralZh: "贰",
        actCode: "第贰章",
        titleZh: "街道 · 封锁线",
        titleEn: "孤城护童",
        lineTag: "周戍",
        volumeTagZh: "上卷 · 孤城护童",
        skyTop: rgba(10, 12, 20, 255),
        skyMid: rgba(20, 24, 36, 255),
        skyHorizon: rgba(38, 36, 48, 255),
        farBuilding: rgba(16, 19, 28, 255),
        midBuilding: rgba(24, 27, 38, 255),
        fogBottom: rgba(66, 54, 68, 64),
        groundTop: rgba(48, 52, 60, 255),
        groundBody: rgba(18, 20, 28, 255),
        groundRim: rgba(146, 170, 178, 190),
        accent: PALETTE.cyan,
        beamColor: rgba(148, 170, 184, 34),
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
        numeralZh: "叁",
        actCode: "第叁章",
        titleZh: "检查站 · 装卸台",
        titleEn: "孤城护童",
        lineTag: "周戍",
        volumeTagZh: "上卷 · 孤城护童",
        skyTop: rgba(9, 12, 20, 255),
        skyMid: rgba(18, 25, 38, 255),
        skyHorizon: rgba(32, 44, 60, 255),
        farBuilding: rgba(15, 21, 32, 255),
        midBuilding: rgba(22, 30, 42, 255),
        fogBottom: rgba(48, 68, 86, 58),
        groundTop: rgba(46, 54, 64, 255),
        groundBody: rgba(16, 20, 28, 255),
        groundRim: rgba(146, 170, 178, 200),
        accent: PALETTE.cyan,
        beamColor: rgba(140, 172, 188, 36),
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
        numeralZh: "肆",
        actCode: "第肆章",
        titleZh: "城门 · 四十五秒",
        titleEn: "死守断后",
        lineTag: "周戍",
        volumeTagZh: "上卷 · 孤城护童",
        skyTop: rgba(14, 10, 14, 255),
        skyMid: rgba(28, 17, 22, 255),
        skyHorizon: rgba(56, 28, 30, 255),
        farBuilding: rgba(20, 15, 20, 255),
        midBuilding: rgba(30, 21, 26, 255),
        fogBottom: rgba(118, 42, 42, 62),
        groundTop: rgba(54, 48, 52, 255),
        groundBody: rgba(18, 16, 21, 255),
        groundRim: rgba(186, 66, 54, 195),
        accent: PALETTE.crimson,
        beamColor: rgba(196, 76, 62, 38),
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
        numeralZh: "伍",
        actCode: "第伍章",
        titleZh: "城墙外 · 拱与红布",
        titleEn: "独赴北塔",
        lineTag: "小满",
        volumeTagZh: "下卷 · 独赴北塔",
        skyTop: rgba(9, 12, 20, 255),
        skyMid: rgba(16, 24, 38, 255),
        skyHorizon: rgba(30, 42, 60, 255),
        farBuilding: rgba(14, 19, 30, 255),
        midBuilding: rgba(20, 28, 42, 255),
        fogBottom: rgba(48, 64, 88, 58),
        groundTop: rgba(48, 54, 64, 255),
        groundBody: rgba(16, 20, 28, 255),
        groundRim: rgba(168, 152, 126, 185),
        accent: PALETTE.amber,
        beamColor: rgba(176, 166, 146, 28),
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
        numeralZh: "陆",
        actCode: "第陆章",
        titleZh: "废弃村庄 · 砖地一响",
        titleEn: "独赴北塔",
        lineTag: "小满",
        volumeTagZh: "下卷 · 独赴北塔",
        skyTop: rgba(10, 12, 18, 255),
        skyMid: rgba(18, 23, 33, 255),
        skyHorizon: rgba(36, 40, 50, 255),
        farBuilding: rgba(15, 19, 26, 255),
        midBuilding: rgba(24, 28, 36, 255),
        fogBottom: rgba(74, 68, 60, 54),
        groundTop: rgba(54, 54, 58, 255),
        groundBody: rgba(18, 20, 25, 255),
        groundRim: rgba(206, 174, 122, 185),
        accent: PALETTE.amber,
        beamColor: rgba(212, 174, 118, 24),
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
        numeralZh: "柒",
        actCode: "第柒章",
        titleZh: "北塔森林 · 听风辨步",
        titleEn: "独赴北塔",
        lineTag: "小满",
        volumeTagZh: "下卷 · 独赴北塔",
        skyTop: rgba(8, 12, 16, 255),
        skyMid: rgba(14, 24, 28, 255),
        skyHorizon: rgba(26, 44, 46, 255),
        farBuilding: rgba(12, 20, 24, 255),
        midBuilding: rgba(18, 30, 32, 255),
        fogBottom: rgba(52, 86, 82, 56),
        groundTop: rgba(36, 52, 48, 255),
        groundBody: rgba(14, 22, 22, 255),
        groundRim: rgba(148, 172, 130, 190),
        accent: PALETTE.emerald,
        beamColor: rgba(148, 178, 146, 24),
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
        numeralZh: "捌",
        actCode: "终章",
        titleZh: "北塔 · 最后一行",
        titleEn: "归途尾声",
        lineTag: "尾声",
        volumeTagZh: "终章 · 北塔守望",
        skyTop: rgba(10, 13, 21, 255),
        skyMid: rgba(20, 28, 44, 255),
        skyHorizon: rgba(48, 52, 66, 255),
        farBuilding: rgba(16, 21, 32, 255),
        midBuilding: rgba(24, 30, 44, 255),
        fogBottom: rgba(212, 168, 104, 48),
        groundTop: rgba(60, 60, 66, 255),
        groundBody: rgba(19, 21, 28, 255),
        groundRim: rgba(232, 194, 128, 210),
        accent: PALETTE.amber,
        beamColor: rgba(236, 198, 132, 40),
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

const UPPER_DIGITS = ["零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖"];

/** 将 0..100 整数转为传统中文大写数字（零、壹..拾、拾壹..玖拾玖、壹佰） */
export function toChineseUpper(n: number): string {
    const v = Math.max(0, Math.min(100, Math.floor(n)));
    if (v === 100) {
        return "壹佰";
    }
    if (v < 10) {
        return UPPER_DIGITS[v];
    }
    const tens = Math.floor(v / 10);
    const ones = v % 10;
    const prefix = tens === 1 ? "拾" : UPPER_DIGITS[tens] + "拾";
    return ones === 0 ? prefix : prefix + UPPER_DIGITS[ones];
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

/** 径向柔和光晕（扇形顶点渐变） */
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

/**
 * 水墨飞白横刷长带（优先使用 ui_ink.clip 的毛笔笔触贴图，缺图自动回退两端渐隐墨晕）
 */
export function drawInkWashStrip(
    fallbackDraw: DrawNode.Type,
    art: AssetSlotHost,
    id: string,
    cx: number, cy: number, w: number, h: number,
    tint: RGBA, opacity: number = 0.88,
    symmetric: boolean = true,
    layer: number = 0,
): void {
    if (w <= 2 || h <= 2 || opacity <= 0.01) {
        return;
    }
    const slot = symmetric ? "ink_brush_sym" : "ink_brush_wide";
    if (art.tryPlace(slot, id, cx, cy, w, h, { color: toColor(tint, 255), opacity, layer })) {
        return;
    }
    // 程序化墨韵回退：中段实、左右柔化渐隐
    const x = cx - w * 0.5;
    const y = cy - h * 0.5;
    const fadeW = symmetric ? w * 0.18 : w * 0.34;
    const midCol = toColor(tint, Math.round(235 * opacity));
    const zeroCol = Color(tint.r, tint.g, tint.b, 0);
    if (symmetric) {
        fillHGradRect(fallbackDraw, x, y, fadeW, h, zeroCol, midCol);
        fallbackDraw.drawRect(Rect(x + fadeW, y, Math.max(0, w - fadeW * 2), h), midCol);
        fillHGradRect(fallbackDraw, x + w - fadeW, y, fadeW, h, midCol, zeroCol);
    } else {
        const leftFade = Math.min(20, w * 0.08);
        fillHGradRect(fallbackDraw, x, y, leftFade, h, zeroCol, midCol);
        fallbackDraw.drawRect(Rect(x + leftFade, y, Math.max(0, w - leftFade - fadeW), h), midCol);
        fillHGradRect(fallbackDraw, x + w - fadeW, y, fadeW, h, midCol, zeroCol);
    }
}

/**
 * 宣纸墨云面板（四周柔化渐隐的暗墨托底，可选叠加微弱宣纸纤维肌理）
 */
export function drawInkPanel(
    fallbackDraw: DrawNode.Type,
    art: AssetSlotHost,
    id: string,
    x: number, y: number, w: number, h: number,
    tint: RGBA, opacity: number = 0.90,
    withPaperGrain: boolean = false,
    layer: number = -1,
): void {
    const cx = x + w * 0.5;
    const cy = y + h * 0.5;
    if (!art.tryPlace("ink_wash_panel", id, cx, cy, w + 18, h + 16, { color: toColor(tint, 255), opacity, layer })) {
        fallbackDraw.drawRect(Rect(x, y, w, h), toColor(tint, Math.round(230 * opacity)));
    }
    if (withPaperGrain) {
        art.tryPlace("ink_paper_grain", id + "_grain", cx, cy, w - 6, h - 6, { opacity: 0.11 * opacity, layer: layer + 1 });
    }
}

/**
 * 典籍双线卷轴框（外古铜枯线 + 内缩极细线 + 四角镜像铜雕花 + 可选卷轴木杆）
 */
export function drawScrollFrame(
    overlayDraw: DrawNode.Type,
    art: AssetSlotHost,
    id: string,
    x: number, y: number, w: number, h: number,
    borderCol: RGBA, alpha: number = 1,
    showCorners: boolean = true,
    showRollers: boolean = false,
    cornerSize: number = 22,
    layer: number = 2,
): void {
    if (alpha <= 0.01) {
        return;
    }
    // 外古铜细框 + 内缩 4px 淡墨金线
    overlayDraw.drawRect(Rect(x, y, w, h), Color(0, 0, 0, 0), 1.15, toColor(borderCol, 175 * alpha));
    overlayDraw.drawRect(Rect(x + 4, y + 4, Math.max(0, w - 8), Math.max(0, h - 8)), Color(0, 0, 0, 0), 0.7, toColor(borderCol, 72 * alpha));

    if (showCorners) {
        const half = cornerSize * 0.5;
        const insetX = showRollers ? -6 : 2;
        const insetY = showRollers ? -8 : 2;
        const cCol = toColor(borderCol, 255);
        const op = (showRollers ? 0.72 : 0.85) * alpha;
        // ui_corner 原图开口朝右下方（左上角雕花）
        art.tryPlace("ui_corner_c", id + "_tl", x + half - insetX, y + h - half + insetY, cornerSize, cornerSize, { color: cCol, opacity: op, layer });
        art.tryPlace("ui_corner_c", id + "_tr", x + w - half + insetX, y + h - half + insetY, cornerSize, cornerSize, { facing: -1, color: cCol, opacity: op, layer });
        art.tryPlace("ui_corner_c", id + "_bl", x + half - insetX, y + half - insetY, cornerSize, cornerSize, { flipY: true, color: cCol, opacity: op, layer });
        art.tryPlace("ui_corner_c", id + "_br", x + w - half + insetX, y + half - insetY, cornerSize, cornerSize, { facing: -1, flipY: true, color: cCol, opacity: op, layer });
    }

    if (showRollers) {
        const rodW = w + 36;
        const rodH = 18;
        art.tryPlace("ink_scroll_bar", id + "_rod_top", x + w * 0.5, y + h + 2, rodW, rodH, { opacity: 0.94 * alpha, layer: layer + 1 });
        art.tryPlace("ink_scroll_bar", id + "_rod_bot", x + w * 0.5, y - 2, rodW, rodH, { opacity: 0.94 * alpha, layer: layer + 1 });
    }
}

/**
 * 枯笔一字墨线分隔符（中段实、两端尖细透明收锋）
 */
export function drawBrushDivider(
    overlayDraw: DrawNode.Type,
    art: AssetSlotHost,
    id: string,
    cx: number, cy: number, w: number, h: number,
    col: RGBA, alpha: number = 0.82,
    layer: number = 2,
): void {
    if (w <= 4 || alpha <= 0.01) {
        return;
    }
    if (art.tryPlace("ink_divider", id, cx, cy, w, h, { color: toColor(col, 255), opacity: alpha, layer })) {
        return;
    }
    const half = w * 0.5;
    fillHGradRect(overlayDraw, cx - half, cy - 0.7, half, 1.4, Color(col.r, col.g, col.b, 0), toColor(col, 200 * alpha));
    fillHGradRect(overlayDraw, cx, cy - 0.7, half, 1.4, toColor(col, 200 * alpha), Color(col.r, col.g, col.b, 0));
}

/**
 * 中国传统方形残边篆印（阳刻空心框 / 阴刻实底印泥 + 毛笔字）
 */
export function drawSealStamp(
    overlayDraw: DrawNode.Type,
    art: AssetSlotHost,
    texts: TextPool,
    id: string,
    cx: number, cy: number, size: number,
    text: string,
    stampCol: RGBA, textCol: RGBA,
    alpha: number = 1,
    solid: boolean = true,
    layer: number = 4,
): void {
    if (alpha <= 0.01) {
        return;
    }
    const slot = solid ? "ink_seal_solid" : "ink_seal_hollow";
    const placed = art.tryPlace(slot, id, cx, cy, size, size, { color: toColor(stampCol, 255), opacity: 0.94 * alpha, layer });
    if (!placed) {
        const half = size * 0.45;
        if (solid) {
            overlayDraw.drawRect(Rect(cx - half, cy - half, half * 2, half * 2), toColor(stampCol, 230 * alpha), 1.0, toColor(textCol, 85 * alpha));
        } else {
            overlayDraw.drawRect(Rect(cx - half, cy - half, half * 2, half * 2), Color(16, 17, 22, Math.round(165 * alpha)), 1.3, toColor(stampCol, 225 * alpha));
        }
    }
    if (text !== "") {
        const bucket = size >= 36 ? "sealLg" : "seal";
        // 实底印泥上的反白字去掉黑描边，避免字形浑浊
        const outW = solid ? 0 : 0.1;
        texts.put(bucket, text, cx, cy, toColor(textCol), 0.5, 0.5, TextAlign.Center, 0, alpha, outW);
    }
}

/**
 * 竖向腰圆引首章（常用于古典竖排主标题旁，如「守」「望」）
 */
export function drawOvalSeal(
    overlayDraw: DrawNode.Type,
    art: AssetSlotHost,
    texts: TextPool,
    id: string,
    cx: number, cy: number, w: number, h: number,
    topChar: string, botChar: string,
    stampCol: RGBA, textCol: RGBA,
    alpha: number = 1,
    layer: number = 4,
): void {
    if (alpha <= 0.01) {
        return;
    }
    const placed = art.tryPlace("ink_seal_oval", id, cx, cy, w, h, { color: toColor(stampCol, 255), opacity: 0.94 * alpha, layer });
    if (!placed) {
        overlayDraw.drawRect(Rect(cx - w * 0.44, cy - h * 0.44, w * 0.88, h * 0.88), toColor(stampCol, 225 * alpha));
    }
    texts.put("seal", topChar, cx, cy + h * 0.17, toColor(textCol), 0.5, 0.5, TextAlign.Center, 0, alpha, 0);
    texts.put("seal", botChar, cx, cy - h * 0.18, toColor(textCol), 0.5, 0.5, TextAlign.Center, 0, alpha, 0);
}

/**
 * 方正古铜细边键位印格（替换科幻斜切键帽）
 */
export function drawInkKeycap(
    overlayDraw: DrawNode.Type,
    texts: TextPool,
    x: number, y: number, w: number, h: number,
    keyText: string,
    accent: RGBA,
    alpha: number = 1,
    filled: boolean = false,
): void {
    const bg = filled ? toColor(accent, 220 * alpha) : Color(18, 17, 21, Math.round(218 * alpha));
    const bd = toColor(accent, (filled ? 245 : 195) * alpha);
    overlayDraw.drawRect(Rect(x, y, w, h), bg, 1.15, bd);
    // 四角微刻点，增强器物雕印感
    if (!filled) {
        overlayDraw.drawRect(Rect(x + 2.5, y + 2.5, Math.max(0, w - 5), Math.max(0, h - 5)), Color(0, 0, 0, 0), 0.6, toColor(accent, 75 * alpha));
    }
    const tc = filled ? toColor(PALETTE.sealText) : toColor(PALETTE.amberCore);
    texts.put("xs", keyText, x + w * 0.5, y + h * 0.5, tc, 0.5, 0.5, TextAlign.Center, 0.3, alpha, filled ? 0 : 0.1);
}

/** 以下四项仅为 stage/props/actors 既有调用保留兼容，新 UI 一律使用上述水墨原语 */
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
