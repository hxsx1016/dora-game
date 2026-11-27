/**
 * 《向西守望》宋明清雅水墨视觉体系（V2 · 参考《饿殍：明末千里行》风流婉转之美）：
 * - 去土黄、去粗滚轴、去满屏硬章；
 * - 色板收束为「鸦青烟纱、霜月素白、淡玉青灰、一缕微杏、孤点胭脂朱砂」；
 * - 原语全面轻盈化：烟黛渐变幕、水袖飞白游丝、婉转烟岚曲线、海棠菱花微结、纤细云肩折角、文人孤印。
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

/** 宋明清雅色板（彻底剔除浊土黄，保持鸦青冷月与清丽胭脂的高级克制对比） */
export const PALETTE = {
    // 鸦青与松墨烟纱
    voidDark: rgba(11, 13, 19, 255),
    panelBg: rgba(16, 19, 27, 218),
    panelBgDeep: rgba(12, 14, 21, 236),
    steelDark: rgba(26, 30, 39, 255),
    steelMid: rgba(44, 50, 62, 255),
    steelLight: rgba(102, 112, 124, 255),
    rimSilver: rgba(176, 184, 192, 255),

    // 周戍：冷月玉青 / 霜月素白
    cyanCore: rgba(235, 238, 236, 255),
    cyan: rgba(154, 178, 188, 255),
    cyanDim: rgba(94, 112, 124, 255),
    cyanGlow: rgba(154, 178, 188, 64),

    // 小满 / 指南针 / 北塔残灯：极克制的微杏淡金（不发土黄）
    amberCore: rgba(244, 234, 214, 255),
    amber: rgba(214, 186, 146, 255),
    amberDim: rgba(132, 118, 102, 255),
    amberGlow: rgba(214, 186, 146, 60),

    // 孤朱 / 胭脂 / 危急：清丽暗胭脂朱砂
    crimsonCore: rgba(246, 208, 200, 255),
    crimson: rgba(188, 68, 64, 255),
    crimsonDeep: rgba(124, 38, 42, 255),
    crimsonGlow: rgba(188, 68, 64, 62),

    // 林间隐蔽 / 安抚：淡松烟青玉
    emerald: rgba(152, 178, 152, 255),
    emeraldDim: rgba(92, 118, 102, 255),

    // 素月文字层级（保证 15px 新致宋纤细横画在暗底上清透可读）
    textBright: rgba(244, 242, 236, 255),
    textMid: rgba(208, 210, 212, 255),
    textDim: rgba(164, 170, 178, 255),

    // V2 宋明清雅专用 Token
    inkVoid: rgba(10, 12, 18, 255),
    inkWash: rgba(14, 17, 25, 255),
    inkMist: rgba(28, 34, 46, 255),
    inkWarm: rgba(34, 22, 27, 255),
    silkLine: rgba(196, 202, 208, 255),
    silkDim: rgba(118, 126, 138, 255),
    jadeMist: rgba(164, 184, 190, 255),
    rouge: rgba(182, 58, 56, 255),
    rougeSoft: rgba(148, 46, 48, 255),
    xuanWarm: rgba(232, 226, 214, 255),
    xuanInk: rgba(32, 30, 32, 255),
    xuanInkSub: rgba(92, 86, 82, 255),
    xuanPaper: rgba(232, 227, 216, 255),
    sealRed: rgba(168, 46, 44, 255),
    sealRedBright: rgba(198, 64, 60, 255),
    sealText: rgba(248, 244, 236, 255),
    cinnabar: rgba(182, 58, 56, 255),
    cinnabarDeep: rgba(116, 36, 40, 255),
    bronzeLine: rgba(178, 184, 192, 255),
    bronzeDim: rgba(114, 122, 134, 255),
    moonPale: rgba(232, 236, 234, 255),

    // 道具
    cartWood: rgba(104, 73, 55, 255),
    cartMetal: rgba(125, 110, 97, 255),
    clothRed: rgba(168, 52, 48, 255),
    clothRedHighlight: rgba(210, 90, 78, 255),
};

export type AmbientKind = "ash" | "drizzle" | "spores" | "motes";

export interface RoomTheme {
    key: string;
    backdropKey?: string;
    numeralZh: string;
    actCode: string;
    titleZh: string;
    shortNameZh: string;
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
        shortNameZh: "倒柜后",
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
        groundRim: rgba(154, 178, 188, 195),
        accent: PALETTE.cyan,
        beamColor: rgba(140, 168, 184, 34),
        ambient: "ash",
        showSearchlights: false,
        showTowerBeacon: false,
        showMoon: true,
        moonXFrac: 0.78,
        moonYFrac: 0.78,
        defaultZoom: 1.12,
        introWhisper: "城破前夜，月光斜漏旧仓。她在倒塌的柜子后面。",
    },
    street: {
        key: "street",
        numeralZh: "贰",
        actCode: "第贰章",
        titleZh: "街道 · 封锁线",
        shortNameZh: "封锁线",
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
        groundRim: rgba(154, 178, 188, 190),
        accent: PALETTE.cyan,
        beamColor: rgba(148, 170, 184, 34),
        ambient: "ash",
        showSearchlights: false,
        showTowerBeacon: false,
        showMoon: true,
        moonXFrac: 0.82,
        moonYFrac: 0.80,
        defaultZoom: 1.0,
        introWhisper: "夜雾漫过长街，带她穿过火线，莫让枪声压住她的步子。",
    },
    checkpoint: {
        key: "checkpoint",
        numeralZh: "叁",
        actCode: "第叁章",
        titleZh: "检查站 · 装卸台",
        shortNameZh: "装卸台",
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
        groundRim: rgba(154, 178, 188, 200),
        accent: PALETTE.cyan,
        beamColor: rgba(140, 172, 188, 36),
        ambient: "ash",
        showSearchlights: false,
        showTowerBeacon: false,
        showMoon: true,
        moonXFrac: 0.74,
        moonYFrac: 0.82,
        defaultZoom: 1.0,
        introWhisper: "红布在夜风里轻晃，把板车推进装卸窝，城门才会放行。",
    },
    gate: {
        key: "gate",
        numeralZh: "肆",
        actCode: "第肆章",
        titleZh: "城门 · 四十五秒",
        shortNameZh: "四十五秒",
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
        groundRim: rgba(188, 68, 64, 195),
        accent: PALETTE.rouge,
        beamColor: rgba(196, 76, 62, 38),
        ambient: "ash",
        showSearchlights: false,
        showTowerBeacon: false,
        showMoon: true,
        moonXFrac: 0.22,
        moonYFrac: 0.80,
        defaultZoom: 0.92,
        introWhisper: "把她送到门洞，自己留下来，守住绞盘最后的四十五秒。",
    },
    outside: {
        key: "outside",
        numeralZh: "伍",
        actCode: "第伍章",
        titleZh: "城墙外 · 拱与红布",
        shortNameZh: "拱与红布",
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
        groundRim: rgba(184, 176, 162, 185),
        accent: PALETTE.amber,
        beamColor: rgba(176, 166, 146, 28),
        ambient: "drizzle",
        showSearchlights: false,
        showTowerBeacon: true,
        showMoon: true,
        moonXFrac: 0.68,
        moonYFrac: 0.82,
        defaultZoom: 0.96,
        introWhisper: "数到二十，门后再无应声。拉开车辙，伏身穿过石拱。",
    },
    village: {
        key: "village",
        numeralZh: "陆",
        actCode: "第陆章",
        titleZh: "废弃村庄 · 砖地一响",
        shortNameZh: "砖地一响",
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
        groundRim: rgba(202, 184, 152, 185),
        accent: PALETTE.amber,
        beamColor: rgba(212, 174, 118, 24),
        ambient: "drizzle",
        showSearchlights: false,
        showTowerBeacon: true,
        showMoon: true,
        moonXFrac: 0.78,
        moonYFrac: 0.82,
        defaultZoom: 1.0,
        introWhisper: "残垣旧院里有拾荒者游荡。掷瓶引响，趁隙潜过案底。",
    },
    forest: {
        key: "forest",
        numeralZh: "柒",
        actCode: "第柒章",
        titleZh: "北塔森林 · 听风辨步",
        shortNameZh: "听风辨步",
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
        groundRim: rgba(152, 178, 152, 190),
        accent: PALETTE.emerald,
        beamColor: rgba(148, 178, 146, 24),
        ambient: "spores",
        showSearchlights: false,
        showTowerBeacon: true,
        showMoon: true,
        moonXFrac: 0.72,
        moonYFrac: 0.84,
        defaultZoom: 1.0,
        introWhisper: "松涛起落，猎犬先人闻步。屏息伏于草影，向北塔行去。",
    },
    tower: {
        key: "tower",
        numeralZh: "捌",
        actCode: "终章",
        titleZh: "北塔 · 最后一行",
        shortNameZh: "最后一行",
        titleEn: "归途尾声",
        lineTag: "尾声",
        volumeTagZh: "终章 · 北塔守望",
        skyTop: rgba(10, 13, 21, 255),
        skyMid: rgba(20, 28, 44, 255),
        skyHorizon: rgba(48, 52, 66, 255),
        farBuilding: rgba(16, 21, 32, 255),
        midBuilding: rgba(24, 30, 44, 255),
        fogBottom: rgba(214, 186, 146, 44),
        groundTop: rgba(60, 60, 66, 255),
        groundBody: rgba(19, 21, 28, 255),
        groundRim: rgba(232, 214, 182, 210),
        accent: PALETTE.amber,
        beamColor: rgba(236, 198, 132, 40),
        ambient: "motes",
        showSearchlights: false,
        showTowerBeacon: true,
        showMoon: true,
        moonXFrac: 0.24,
        moonYFrac: 0.80,
        defaultZoom: 1.12,
        introWhisper: "孤灯犹明。走到北塔门前，照他教过的节奏，轻敲两下。",
    },
};

const ROOM_VARIANTS: Record<string, [string, string, string, string, string, string]> = {
    "s1-crossroad": ["street", "街道 · 十字街", "十字街", "井背可退，转角火器压近。从街口选外街或布行继续北上。", "贰", "第贰章"],
    "s2-drygoods": ["street", "街道 · 布行", "布行", "外街短跨或入布行放窗板，两路穿过敌阵同通牌楼。", "贰", "第贰章"],
    "s3-archway": ["street", "街道 · 牌楼后巷", "牌楼后巷", "登装卸坡探清火线，或沿墙脚绕行，候检门前再汇合。", "贰", "第贰章"],
    "c1-yard": ["checkpoint", "检查站 · 候检院", "候检院", "队栏与查验台层层挡路，转到门背抬起横锁方能带她过院。", "叁", "第叁章"],
    "c2-granary": ["checkpoint", "检查站 · 军粮棚", "军粮棚", "先落木帘或架残盾，将红布车推入轮窝并抬起连杆锁。", "叁", "第叁章"],
    gatepath: ["outside", "城外 · 兄妹同行", "兄妹同行", "城门未隔断二人。牵起她的手，沿平路往高石阶走去。", "伍", "第伍章"],
    escort1: ["outside", "城外巷路 · 第一段护送", "护送巷路", "背起受伤的小满穿过巷口火线，借慢时换弹突出重围。", "伍", "第伍章"],
    escort2: ["checkpoint", "粮棚 · 第二段取材", "粮棚取材", "高低两路暗藏木纹筹与铃纹筹，沿途收齐好在工台改制。", "陆", "第陆章"],
    escort3: ["forest", "山腰工台 · 第三段改制", "山腰工台", "暂放小满，择引路灯铳或回声铳改制试射，再背起前行。", "陆", "第陆章"],
    escort4: ["forest", "山道 · 第四段脱身", "山道脱身", "窄道追兵紧逼，在慢时连线与伏身翻滚间夺出一条生路。", "柒", "第柒章"],
    escort5: ["tower", "塔前山道 · 第五段", "塔前山道", "北塔孤灯已在前方。带着改制火铳护她走完最后一段山路。", "柒", "第柒章"],
    museum: ["prologue", "博物馆 · 西厅", "西厅", "玻璃柜静立晨光之中，那枚青布针套仍在等待回响。", "番", "番外"],
};

for (const key in ROOM_VARIANTS) {
    const [backdropKey, titleZh, shortNameZh, introWhisper, numZh, actZh] = ROOM_VARIANTS[key];
    const base = ROOM_THEMES[backdropKey];
    const soldierPath = key === "gatepath" || key.startsWith("escort");
    ROOM_THEMES[key] = {
        ...base, key, backdropKey, titleZh, shortNameZh, introWhisper,
        numeralZh: numZh ?? (soldierPath ? ROOM_THEMES.outside.numeralZh : base.numeralZh),
        actCode: actZh ?? (soldierPath ? ROOM_THEMES.outside.actCode : base.actCode),
        lineTag: soldierPath ? "周戍" : base.lineTag,
        volumeTagZh: soldierPath ? "周戍线 · 护送" : base.volumeTagZh,
    };
}

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

/** 顶点渐变四边形 */
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

/** 径向柔和光晕 */
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
 * 烟黛渐变轻幕（《饿殍》柔边字幕幕 / 顶部轻带，四周自然消融无硬框）
 */
export function drawSilkVeil(
    fallbackDraw: DrawNode.Type,
    art: AssetSlotHost,
    id: string,
    cx: number, cy: number, w: number, h: number,
    tint: RGBA, opacity: number = 0.84,
    layer: number = -1,
): void {
    if (w <= 2 || h <= 2 || opacity <= 0.01) {
        return;
    }
    if (art.tryPlace("ink_veil_strip", id, cx, cy, w, h, { color: toColor(tint, 255), opacity, layer })) {
        return;
    }
    const x = cx - w * 0.5;
    const y = cy - h * 0.5;
    const fadeW = w * 0.22;
    const midCol = toColor(tint, Math.round(225 * opacity));
    const zeroCol = Color(tint.r, tint.g, tint.b, 0);
    fillHGradRect(fallbackDraw, x, y, fadeW, h, zeroCol, midCol);
    fallbackDraw.drawRect(Rect(x + fadeW, y, Math.max(0, w - fadeW * 2), h), midCol);
    fillHGradRect(fallbackDraw, x + w - fadeW, y, fadeW, h, midCol, zeroCol);
}

/**
 * 水袖游丝飞白飘带（用于菜单选中态轻拂高光，柔美弧线非粗重墨块）
 */
export function drawSilkRibbon(
    fallbackDraw: DrawNode.Type,
    art: AssetSlotHost,
    id: string,
    cx: number, cy: number, w: number, h: number,
    tint: RGBA, opacity: number = 0.65,
    layer: number = 0,
): void {
    if (w <= 2 || h <= 2 || opacity <= 0.01) {
        return;
    }
    if (art.tryPlace("ink_ribbon_sweep", id, cx, cy, w, h, { color: toColor(tint, 255), opacity, layer })) {
        return;
    }
    const x = cx - w * 0.5;
    const y = cy - h * 0.5;
    fillHGradRect(fallbackDraw, x, y, w * 0.65, h, toColor(tint, Math.round(160 * opacity)), Color(tint.r, tint.g, tint.b, 0));
}

/**
 * 婉转烟岚流云曲线（赋予标题、驿道长卷、章名以轻盈流动感）
 */
export function drawMistCurve(
    art: AssetSlotHost,
    id: string,
    cx: number, cy: number, w: number, h: number,
    tint: RGBA, opacity: number = 0.36,
    layer: number = -1,
    facing: number = 1,
): void {
    if (w <= 4 || h <= 4 || opacity <= 0.01) {
        return;
    }
    art.tryPlace("ink_mist_curve", id, cx, cy, w, h, { color: toColor(tint, 255), opacity, layer, facing });
}

/**
 * 霜月游丝细线（可选在中点缀一枚极精巧的宋明海棠菱花微结）
 */
export function drawHairline(
    overlayDraw: DrawNode.Type,
    art: AssetSlotHost,
    id: string,
    cx: number, cy: number, w: number,
    col: RGBA, alpha: number = 0.72,
    withKnot: boolean = false,
    layer: number = 2,
): void {
    if (w <= 4 || alpha <= 0.01) {
        return;
    }
    if (!art.tryPlace("ink_hairline", id, cx, cy, w, 10, { color: toColor(col, 255), opacity: alpha, layer })) {
        const half = w * 0.5;
        fillHGradRect(overlayDraw, cx - half, cy - 0.5, half, 1.0, Color(col.r, col.g, col.b, 0), toColor(col, 190 * alpha));
        fillHGradRect(overlayDraw, cx, cy - 0.5, half, 1.0, toColor(col, 190 * alpha), Color(col.r, col.g, col.b, 0));
    }
    if (withKnot) {
        art.tryPlace("ink_knot_ornament", id + "_knot", cx, cy, 88, 24, { color: toColor(col, 255), opacity: Math.min(1, alpha * 1.15), layer: layer + 1 });
    }
}

/**
 * 宋明纤细海棠折角（取代笨重双线铁框与像素铜角，带留白呼吸感）
 */
export function drawFiligreeCorners(
    overlayDraw: DrawNode.Type,
    art: AssetSlotHost,
    id: string,
    x: number, y: number, w: number, h: number,
    col: RGBA, alpha: number = 0.78,
    cornerSize: number = 34,
    withHairBorder: boolean = true,
    layer: number = 2,
): void {
    if (alpha <= 0.01) {
        return;
    }
    if (withHairBorder) {
        overlayDraw.drawRect(Rect(x, y, w, h), Color(0, 0, 0, 0), 0.75, toColor(col, 78 * alpha));
    }
    const half = cornerSize * 0.5;
    const c = toColor(col, 255);
    const op = alpha;
    art.tryPlace("ink_corner_fine", id + "_tl", x + half - 2, y + h - half + 2, cornerSize, cornerSize, { color: c, opacity: op, layer });
    art.tryPlace("ink_corner_fine", id + "_tr", x + w - half + 2, y + h - half + 2, cornerSize, cornerSize, { facing: -1, color: c, opacity: op, layer });
    art.tryPlace("ink_corner_fine", id + "_bl", x + half - 2, y + half - 2, cornerSize, cornerSize, { flipY: true, color: c, opacity: op, layer });
    art.tryPlace("ink_corner_fine", id + "_br", x + w - half + 2, y + half - 2, cornerSize, cornerSize, { facing: -1, flipY: true, color: c, opacity: op, layer });
}

/**
 * 文人孤印（全屏仅用于主标题落款与北塔登记簿落款，清瘦精致不泛滥）
 */
export function drawLoneSeal(
    overlayDraw: DrawNode.Type,
    art: AssetSlotHost,
    texts: TextPool,
    id: string,
    cx: number, cy: number, w: number, h: number,
    topChar: string, botChar: string,
    stampCol: RGBA, textCol: RGBA,
    alpha: number = 0.94,
    layer: number = 4,
): void {
    if (alpha <= 0.01) {
        return;
    }
    if (!art.tryPlace("ink_seal_slender", id, cx, cy, w, h, { color: toColor(stampCol, 255), opacity: alpha, layer })) {
        overlayDraw.drawRect(Rect(cx - w * 0.42, cy - h * 0.44, w * 0.84, h * 0.88), toColor(stampCol, 225 * alpha));
    }
    texts.put("seal", topChar, cx, cy + h * 0.17, toColor(textCol), 0.5, 0.5, TextAlign.Center, 0, alpha, 0);
    texts.put("seal", botChar, cx, cy - h * 0.18, toColor(textCol), 0.5, 0.5, TextAlign.Center, 0, alpha, 0);
}

/** 纤巧菱花花蕊点（替换笨重圆点与方印焦点） */
export function drawBlossomDot(
    overlayDraw: DrawNode.Type,
    art: AssetSlotHost,
    id: string,
    cx: number, cy: number, size: number,
    col: RGBA, alpha: number = 0.92,
    layer: number = 4,
): void {
    if (alpha <= 0.01) {
        return;
    }
    if (!art.tryPlace("ink_blossom_dot", id, cx, cy, size, size, { color: toColor(col, 255), opacity: alpha, layer })) {
        drawDiamond(overlayDraw, cx, cy, size * 0.35, size * 0.35, toColor(col, 230 * alpha));
    }
}

/** 清雅霜银发丝微框键位（去土黄、去厚底） */
export function drawSilkKeycap(
    overlayDraw: DrawNode.Type,
    texts: TextPool,
    x: number, y: number, w: number, h: number,
    keyText: string,
    accent: RGBA,
    alpha: number = 1,
    urgent: boolean = false,
): void {
    const bg = urgent ? toColor(PALETTE.rougeSoft, 200 * alpha) : Color(14, 17, 25, Math.round(186 * alpha));
    const bd = toColor(urgent ? PALETTE.crimsonCore : accent, (urgent ? 225 : 165) * alpha);
    overlayDraw.drawRect(Rect(x, y, w, h), bg, 0.85, bd);
    const tc = urgent ? toColor(PALETTE.sealText) : toColor(PALETTE.textBright);
    texts.put("xs", keyText, x + w * 0.5, y + h * 0.5, tc, 0.5, 0.5, TextAlign.Center, 0.5, alpha, urgent ? 0 : 0.08);
}

/** 以下四项仅为 stage/props/actors 既有调用保留兼容，新 UI 一律使用上述清雅水墨原语 */
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
