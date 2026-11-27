/**
 * 《向西守望》肉鸽前端视觉词典与明初器物工笔纹样库（《行军筹签记》）。
 *
 * 设计红线：
 * 1. 明初卫所写实美学：以宋明清雅色板（theme.ts PALETTE）+ 纯 DrawNode 工笔线绘呈现，
 *    零西式奇幻卡牌、零仙侠发光阵、零现代弹药箱；
 * 2. 静音与灰度可读：四大本领与八类随身战备均具备完全互异的几何轮廓；
 * 3. 表驱动向前兼容：通过 registerTalentVisual() 可随时注册新本领，未登记 ID 自动回退至
 *    通用明代军筹模板，绝不崩溃；
 * 4. 严格匹配后端真实数值公式（Script/watch/play.ts）：
 *    - vitality：maxHp + 1，hp + 1
 *    - reload：装填拍 = max(6, (quickbelt>0 ? 36 : 54) - 6*reload - 3*craft)
 *    - guard：受击保护 = 42 + 12*guard
 *    - craft：制楔 = max(6, 45 - 6*craft)（且顺带减装填 3 拍）
 * 5. 字库 0 缺字：全部正文字符经 lxgw-neo-zhisong.ttf 核对。
 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { talentNames } from "Script/watch/run";
import { ReloadEffectKind, RoguelikeSnapshot } from "Script/watch/fe/contract";
import { drawReloadPatternGlyph } from "Script/watch/fe/ui/reload_wheel";
import {
    PALETTE,
    RGBA,
    drawDiamond,
    fillRadialGlow,
    toColor,
} from "Script/watch/fe/theme";

export type TalentAbsorbTarget = "hp" | "gun" | "shoulder" | "satchel" | "crest";

export interface TalentVisualMeta {
    id: string;
    title: string;
    category: string;
    accent: RGBA;
    accentCore: RGBA;
    whisper: string;
    absorbTarget: TalentAbsorbTarget;
    shortEffect: (snap: RoguelikeSnapshot, curRank: number) => string;
    subEffect: (snap: RoguelikeSnapshot, curRank: number) => string;
    ledgerLine: (snap: RoguelikeSnapshot, rank: number) => string;
}

export interface WeaponDisplayMeta {
    id: string;
    name: string;
    shortName: string;
    effect: ReloadEffectKind;
    accent: RGBA;
    desc: string;
}

export interface PickupDisplayMeta {
    kind: string;
    name: string;
    shortName: string;
    accent: RGBA;
    accentCore: RGBA;
    category: "material" | "gear";
}

export interface MarchTitleMeta {
    title: string;
    sealTop: string;
    sealBot: string;
    subtitle: string;
    accent: RGBA;
}

const RANK_NUMERALS = ["零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "拾"];

/** 将本领阶位转为传统中文大写（全覆盖正文字库，无缺失罗马数字）。 */
export function rankChinese(rank: number): string {
    const r = Math.max(0, Math.floor(rank));
    if (r < RANK_NUMERALS.length) {
        return RANK_NUMERALS[r];
    }
    return "" + r;
}

const TALENT_REGISTRY: Record<string, TalentVisualMeta> = {};

/** 注册或扩展自定义本领视觉定义（表驱动，方便后续并行扩展新本领）。 */
export function registerTalentVisual(meta: TalentVisualMeta): void {
    TALENT_REGISTRY[meta.id] = meta;
}

registerTalentVisual({
    id: "vitality",
    title: "厚甲",
    category: "固守",
    accent: PALETTE.cyan,
    accentCore: PALETTE.moonPale,
    whisper: "「再重些，背上的人便稳些。」",
    absorbTarget: "hp",
    shortEffect: (snap) => "体力上限 " + snap.maxHp + " → " + (snap.maxHp + 1),
    subEffect: () => "并即刻回气 +1",
    ledgerLine: (snap, rank) => "体力上限 +" + rank + "（现 " + snap.hp + "/" + snap.maxHp + "）",
});

registerTalentVisual({
    id: "reload",
    title: "熟铳",
    category: "火器",
    accent: PALETTE.amber,
    accentCore: PALETTE.amberCore,
    whisper: "「火绳趁手，莫叫她久等。」",
    absorbTarget: "gun",
    shortEffect: (snap) => {
        const next = Math.max(6, snap.reloadTicksNow - 6);
        return "装填 " + snap.reloadTicksNow + " → " + next + " 拍";
    },
    subEffect: () => "更快复位鸟铳 (-6 拍)",
    ledgerLine: (snap, rank) => "装填耗时 " + snap.reloadTicksNow + " 拍（减 " + (rank * 6) + " 拍）",
});

registerTalentVisual({
    id: "guard",
    title: "护身",
    category: "身法",
    accent: PALETTE.emerald,
    accentCore: PALETTE.moonPale,
    whisper: "「挨了这一记，步子不能乱。」",
    absorbTarget: "shoulder",
    shortEffect: (snap) => "护身 " + snap.invulnTicksNow + " → " + (snap.invulnTicksNow + 12) + " 拍",
    subEffect: () => "受击多得喘息窗 (+12 拍)",
    ledgerLine: (snap, rank) => "受击保护 " + snap.invulnTicksNow + " 拍（加 " + (rank * 12) + " 拍）",
});

registerTalentVisual({
    id: "craft",
    title: "巧手",
    category: "机巧",
    accent: PALETTE.amber,
    accentCore: PALETTE.amberCore,
    whisper: "「爹教的楔法，倒派上用场。」",
    absorbTarget: "satchel",
    shortEffect: (snap) => {
        const next = Math.max(6, snap.craftTicksNow - 6);
        return "制楔 " + snap.craftTicksNow + " → " + next + " 拍";
    },
    subEffect: () => "顺手减装填 3 拍",
    ledgerLine: (snap, rank) => "制楔 " + snap.craftTicksNow + " 拍 · 装填另减 " + (rank * 3) + " 拍",
});

/** 解析任意本领 ID 的视觉元数据；未知未来 ID 自动回退至明代军筹通用模板。 */
export function resolveTalentVisual(id: string, snap?: RoguelikeSnapshot): TalentVisualMeta {
    const reg = TALENT_REGISTRY[id];
    if (reg !== undefined) {
        return reg;
    }
    const hint = (snap !== undefined ? snap.talentLabelHints[id] : undefined)
        ?? (talentNames as Record<string, string | undefined>)[id]
        ?? id;
    const dotIdx = hint.indexOf("·");
    const parsedTitle = dotIdx > 0 ? hint.slice(0, dotIdx) : hint;
    const parsedDesc = dotIdx > 0 ? hint.slice(dotIdx + 1) : "行军备策 · 增益一阶";
    return {
        id,
        title: parsedTitle !== "" ? parsedTitle : "军筹",
        category: "军筹",
        accent: PALETTE.jadeMist,
        accentCore: PALETTE.textBright,
        whisper: "「夜路漫漫，多备一筹总安心。」",
        absorbTarget: "crest",
        shortEffect: () => parsedDesc,
        subEffect: (_s, curRank) => "现 " + rankChinese(curRank) + " → " + rankChinese(curRank + 1) + " 阶",
        ledgerLine: (_s, rank) => parsedDesc + "（" + rankChinese(rank) + " 阶）",
    };
}

const WEAPON_META: Record<string, WeaponDisplayMeta> = {
    standard_gun: {
        id: "standard_gun",
        name: "标准鸟铳",
        shortName: "鸟铳",
        effect: "normal",
        accent: PALETTE.silkLine,
        desc: "九宫连线蓄推退、铃纹、灯纹",
    },
    guide_lantern_gun: {
        id: "guide_lantern_gun",
        name: "引路灯铳",
        shortName: "灯铳",
        effect: "light",
        accent: PALETTE.amberCore,
        desc: "强化灯纹破夜光晕镇敌",
    },
    echo_gun: {
        id: "echo_gun",
        name: "回声铜铃铳",
        shortName: "回声铳",
        effect: "echo",
        accent: PALETTE.cyanCore,
        desc: "强化铃纹双响回声诱敌",
    },
    time_shuttler: {
        id: "time_shuttler",
        name: "时间穿梭器",
        shortName: "穿梭器",
        effect: "knockback",
        accent: PALETTE.amberCore,
        desc: "双线归档旧物，冷白残影",
    },
};

export function weaponMetaOf(weaponId: string): WeaponDisplayMeta {
    return WEAPON_META[weaponId] ?? WEAPON_META["standard_gun"];
}

export const PICKUP_ORDER: readonly string[] = [
    "wood",
    "bell",
    "shield",
    "wedge",
    "ammo",
    "scrap",
    "pass",
    "quickbelt",
];

const PICKUP_META: Record<string, PickupDisplayMeta> = {
    wood: { kind: "wood", name: "木纹筹", shortName: "木筹", accent: PALETTE.amber, accentCore: PALETTE.amberCore, category: "material" },
    bell: { kind: "bell", name: "铃纹筹", shortName: "铃筹", accent: PALETTE.amberCore, accentCore: PALETTE.amberCore, category: "material" },
    shield: { kind: "shield", name: "残盾", shortName: "残盾", accent: PALETTE.cyan, accentCore: PALETTE.cyanCore, category: "gear" },
    wedge: { kind: "wedge", name: "木楔", shortName: "木楔", accent: PALETTE.emerald, accentCore: PALETTE.moonPale, category: "gear" },
    ammo: { kind: "ammo", name: "备用弹包", shortName: "弹包", accent: PALETTE.rouge, accentCore: PALETTE.crimsonCore, category: "gear" },
    scrap: { kind: "scrap", name: "废木料", shortName: "木料", accent: PALETTE.amberDim, accentCore: PALETTE.amber, category: "material" },
    pass: { kind: "pass", name: "护送号牌", shortName: "号牌", accent: PALETTE.jadeMist, accentCore: PALETTE.textBright, category: "gear" },
    quickbelt: { kind: "quickbelt", name: "快装带", shortName: "装带", accent: PALETTE.amber, accentCore: PALETTE.amberCore, category: "gear" },
};

export function pickupMetaOf(kind: string): PickupDisplayMeta {
    return PICKUP_META[kind] ?? {
        kind,
        name: kind,
        shortName: kind,
        accent: PALETTE.silkLine,
        accentCore: PALETTE.textBright,
        category: "gear",
    };
}

/** 按当前已习本领、所持火铳与战备派生纯前端「行军雅号」（零后端侵入）。 */
export function deriveMarchTitle(snap: RoguelikeSnapshot): MarchTitleMeta {
    const vit = snap.ranks["vitality"] ?? 0;
    const rel = snap.ranks["reload"] ?? 0;
    const grd = snap.ranks["guard"] ?? 0;
    const crf = snap.ranks["craft"] ?? 0;
    const total = snap.totalRanks;
    const weapon = snap.equippedWeapon;
    const wedge = snap.supplies["wedge"] ?? 0;

    if (total <= 0) {
        return { title: "初启北行", sealTop: "守", sealBot: "望", subtitle: "行囊初整，孤灯在前", accent: PALETTE.silkLine };
    }
    if (rel >= 2 && weapon === "guide_lantern_gun") {
        return { title: "明火疾铳", sealTop: "明", sealBot: "火", subtitle: "灯影破夜，火绳如电", accent: PALETTE.amberCore };
    }
    if (rel >= 2 && weapon === "echo_gun") {
        return { title: "惊铃连响", sealTop: "惊", sealBot: "铃", subtitle: "铜铃惑敌，连发不断", accent: PALETTE.cyanCore };
    }
    if (vit + grd >= 3 && vit >= 1 && grd >= 1) {
        return { title: "铁壁断后", sealTop: "铁", sealBot: "壁", subtitle: "重甲护身，步履不乱", accent: PALETTE.cyan };
    }
    if (crf >= 2 || (crf >= 1 && wedge >= 1)) {
        return { title: "巧楔筑垒", sealTop: "巧", sealBot: "楔", subtitle: "削木固掩，以巧破险", accent: PALETTE.emerald };
    }
    if (rel >= 2) {
        return { title: "疾火连铳", sealTop: "疾", sealBot: "铳", subtitle: "熟手快装，火线不绝", accent: PALETTE.amber };
    }
    if (vit >= 2) {
        return { title: "重甲负行", sealTop: "重", sealBot: "甲", subtitle: "铁衣加身，稳背同行", accent: PALETTE.cyan };
    }
    if (grd >= 2) {
        return { title: "稳步护势", sealTop: "护", sealBot: "身", subtitle: "身法从容，危中留隙", accent: PALETTE.emerald };
    }
    return { title: "孤城守望", sealTop: "守", sealBot: "望", subtitle: "诸筹兼备，护她北归", accent: PALETTE.rouge };
}

/** 内部工具：用短折线绘制清秀明式弧线（兼容所有缩放与灰度）。 */
export function drawBrushArc(
    draw: DrawNode.Type,
    cx: number,
    cy: number,
    rx: number,
    ry: number,
    startRad: number,
    endRad: number,
    thickness: number,
    color: Color.Type,
    segments: number = 14,
): void {
    const n = Math.max(4, segments);
    let prevX = cx + Math.cos(startRad) * rx;
    let prevY = cy + Math.sin(startRad) * ry;
    let i = 1;
    for (i = 1; i <= n; i++) {
        const a = startRad + ((endRad - startRad) * i) / n;
        const nx = cx + Math.cos(a) * rx;
        const ny = cy + Math.sin(a) * ry;
        draw.drawSegment(Vec2(prevX, prevY), Vec2(nx, ny), thickness, color);
        prevX = nx;
        prevY = ny;
    }
}

/**
 * 绘制明初器物工笔本领纹样（纯 DrawNode 矢量，静音与灰度下轮廓 100% 互异）：
 * - vitality：明式叠鳞札甲 + 居中圆形护心镜
 * - reload：明式鸟铳龙头火绳弯钩 + 药池微星
 * - guard：明式云肩披膊 + 双向卸力偏锋弧
 * - craft：削木短刀 + 梯形木楔契口
 * - fallback：明代卫所竖式军筹木简
 */
export function drawTalentGlyph(
    draw: DrawNode.Type,
    cx: number,
    cy: number,
    radius: number,
    talentId: string,
    col: RGBA,
    alpha: number = 1,
    coreCol?: RGBA,
): void {
    const r = Math.max(5, radius);
    const lw = Math.max(1.0, r * 0.085);
    const stroke = toColor(col, 240 * alpha);
    const core = toColor(coreCol ?? PALETTE.textBright, 245 * alpha);
    const faint = toColor(col, 125 * alpha);
    const fill = toColor(col, 38 * alpha);

    if (talentId === "vitality") {
        // 三层明式叠鳞札甲外廓（上宽下收盾形胸甲）
        draw.drawPolygon([
            Vec2(cx - r * 0.72, cy + r * 0.66),
            Vec2(cx - r * 0.28, cy + r * 0.82),
            Vec2(cx + r * 0.28, cy + r * 0.82),
            Vec2(cx + r * 0.72, cy + r * 0.66),
            Vec2(cx + r * 0.64, cy - r * 0.26),
            Vec2(cx, cy - r * 0.84),
            Vec2(cx - r * 0.64, cy - r * 0.26),
        ], fill, lw * 1.1, stroke);
        // 札甲横向叠鳞纹（上下两道甲片折线）
        draw.drawSegment(Vec2(cx - r * 0.62, cy + r * 0.22), Vec2(cx + r * 0.62, cy + r * 0.22), lw * 0.8, faint);
        draw.drawSegment(Vec2(cx - r * 0.56, cy - r * 0.24), Vec2(cx + r * 0.56, cy - r * 0.24), lw * 0.8, faint);
        // 甲片竖向编缀丝
        draw.drawSegment(Vec2(cx - r * 0.30, cy - r * 0.52), Vec2(cx - r * 0.34, cy + r * 0.68), lw * 0.7, faint);
        draw.drawSegment(Vec2(cx + r * 0.30, cy - r * 0.52), Vec2(cx + r * 0.34, cy + r * 0.68), lw * 0.7, faint);
        // 居中圆形护心铜镜
        draw.drawCircle(Vec2(cx, cy + r * 0.04), r * 0.32, toColor(PALETTE.panelBgDeep, 210 * alpha));
        draw.drawRing(Vec2(cx, cy + r * 0.04), r * 0.26, r * 0.34, Color(0, 0, 0, 0), lw, core);
        draw.drawDot(Vec2(cx, cy + r * 0.04), Math.max(1.4, r * 0.11), core);
        return;
    }

    if (talentId === "reload") {
        // 明式鸟铳铳身斜杆 + 护木
        draw.drawSegment(Vec2(cx - r * 0.82, cy - r * 0.54), Vec2(cx + r * 0.82, cy + r * 0.34), lw * 1.45, stroke);
        draw.drawSegment(Vec2(cx - r * 0.76, cy - r * 0.68), Vec2(cx + r * 0.22, cy - r * 0.14), lw * 1.0, faint);
        // 龙头 S 形火绳弯钩（明代火绳铳最独特特征）
        draw.drawSegment(Vec2(cx - r * 0.16, cy - r * 0.20), Vec2(cx - r * 0.26, cy + r * 0.32), lw * 1.15, core);
        draw.drawSegment(Vec2(cx - r * 0.26, cy + r * 0.32), Vec2(cx + r * 0.16, cy + r * 0.56), lw * 1.15, core);
        draw.drawSegment(Vec2(cx + r * 0.16, cy + r * 0.56), Vec2(cx + r * 0.38, cy + r * 0.36), lw * 1.05, core);
        // 药池与四向火绳火星
        const sx = cx + r * 0.44;
        const sy = cy + r * 0.34;
        drawDiamond(draw, sx, sy, r * 0.17, r * 0.17, core);
        draw.drawSegment(Vec2(sx - r * 0.28, sy), Vec2(sx + r * 0.28, sy), lw * 0.75, core);
        draw.drawSegment(Vec2(sx, sy - r * 0.28), Vec2(sx, sy + r * 0.28), lw * 0.75, core);
        // 铳托尾端微弯
        draw.drawSegment(Vec2(cx - r * 0.82, cy - r * 0.54), Vec2(cx - r * 0.90, cy - r * 0.76), lw * 1.2, stroke);
        return;
    }

    if (talentId === "guard") {
        // 云肩披膊双层弧形护肩
        drawBrushArc(draw, cx, cy - r * 0.10, r * 0.78, r * 0.62, Math.PI * 0.12, Math.PI * 0.88, lw * 1.35, stroke, 12);
        drawBrushArc(draw, cx, cy - r * 0.26, r * 0.58, r * 0.44, Math.PI * 0.16, Math.PI * 0.84, lw * 0.95, faint, 10);
        // 双向卸力偏锋弧（左右双翼水墨回旋）
        drawBrushArc(draw, cx - r * 0.22, cy - r * 0.04, r * 0.62, r * 0.62, Math.PI * 0.72, Math.PI * 1.32, lw * 1.1, core, 10);
        drawBrushArc(draw, cx + r * 0.22, cy - r * 0.04, r * 0.62, r * 0.62, -Math.PI * 0.32, Math.PI * 0.28, lw * 1.1, core, 10);
        // 中心稳步菱印 + 垂坠护腰短线
        drawDiamond(draw, cx, cy - r * 0.02, r * 0.22, r * 0.28, fill, lw, core);
        draw.drawSegment(Vec2(cx, cy - r * 0.36), Vec2(cx, cy - r * 0.76), lw * 0.95, faint);
        draw.drawDot(Vec2(cx, cy - r * 0.02), Math.max(1.3, r * 0.09), core);
        return;
    }

    if (talentId === "craft") {
        // 梯形竹木楔（左侧立面 + 契口刻线）
        draw.drawPolygon([
            Vec2(cx - r * 0.68, cy - r * 0.56),
            Vec2(cx + r * 0.36, cy - r * 0.56),
            Vec2(cx + r * 0.14, cy + r * 0.32),
            Vec2(cx - r * 0.44, cy + r * 0.32),
        ], fill, lw * 1.1, stroke);
        // 楔身斜切面纹理
        draw.drawSegment(Vec2(cx - r * 0.34, cy - r * 0.54), Vec2(cx - r * 0.14, cy + r * 0.30), lw * 0.8, faint);
        draw.drawSegment(Vec2(cx - r * 0.52, cy - r * 0.14), Vec2(cx + r * 0.24, cy - r * 0.14), lw * 0.75, faint);
        // 斜交叉削木短刀（右上到左下，锐利刀锋）
        draw.drawPolygon([
            Vec2(cx - r * 0.42, cy + r * 0.14),
            Vec2(cx + r * 0.44, cy + r * 0.76),
            Vec2(cx + r * 0.62, cy + r * 0.58),
            Vec2(cx - r * 0.18, cy - r * 0.06),
        ], toColor(coreCol ?? PALETTE.amberCore, 52 * alpha), lw * 1.05, core);
        // 缠布短刀柄
        draw.drawSegment(Vec2(cx + r * 0.48, cy + r * 0.64), Vec2(cx + r * 0.80, cy + r * 0.84), lw * 1.65, stroke);
        // 飞起的两片细木屑
        draw.drawSegment(Vec2(cx - r * 0.66, cy + r * 0.52), Vec2(cx - r * 0.48, cy + r * 0.64), lw * 0.85, core);
        draw.drawSegment(Vec2(cx - r * 0.76, cy + r * 0.26), Vec2(cx - r * 0.60, cy + r * 0.34), lw * 0.75, faint);
        return;
    }

    // 通用明代军筹木简模板（兼容未来任意新增天赋 ID）
    draw.drawPolygon([
        Vec2(cx - r * 0.34, cy + r * 0.76),
        Vec2(cx + r * 0.34, cy + r * 0.76),
        Vec2(cx + r * 0.34, cy - r * 0.46),
        Vec2(cx, cy - r * 0.84),
        Vec2(cx - r * 0.34, cy - r * 0.46),
    ], fill, lw * 1.1, stroke);
    draw.drawCircle(Vec2(cx, cy + r * 0.50), r * 0.11, toColor(PALETTE.panelBgDeep, 220 * alpha));
    draw.drawRing(Vec2(cx, cy + r * 0.50), r * 0.08, r * 0.14, Color(0, 0, 0, 0), lw * 0.8, core);
    draw.drawSegment(Vec2(cx - r * 0.22, cy + r * 0.14), Vec2(cx + r * 0.22, cy + r * 0.14), lw * 0.9, core);
    draw.drawSegment(Vec2(cx - r * 0.22, cy - r * 0.12), Vec2(cx + r * 0.22, cy - r * 0.12), lw * 0.9, faint);
    draw.drawSegment(Vec2(cx - r * 0.16, cy - r * 0.36), Vec2(cx + r * 0.16, cy - r * 0.36), lw * 0.8, faint);
}

/**
 * 绘制明初器物级战备/掉落物纹样（HUD 行囊条与 2.5D 世界掉落物 100% 同源）：
 * 8 类物资轮廓完全互异，取代原 props.ts 的「万物皆指南针」。
 */
export function drawPickupGlyph(
    draw: DrawNode.Type,
    cx: number,
    cy: number,
    radius: number,
    kind: string,
    alpha: number = 1,
    overrideCol?: RGBA,
): void {
    const meta = pickupMetaOf(kind);
    const col = overrideCol ?? meta.accent;
    const core = overrideCol ?? meta.accentCore;
    const r = Math.max(4.5, radius);
    const lw = Math.max(0.95, r * 0.12);
    const stroke = toColor(col, 240 * alpha);
    const hi = toColor(core, 248 * alpha);
    const fill = toColor(col, 68 * alpha);
    const darkFill = Color(20, 18, 22, Math.round(185 * alpha));

    if (kind === "wood") {
        // 木纹筹：竖式刻痕竹木筹简 + 穿绳孔
        draw.drawPolygon([
            Vec2(cx - r * 0.36, cy + r * 0.82),
            Vec2(cx + r * 0.36, cy + r * 0.82),
            Vec2(cx + r * 0.36, cy - r * 0.64),
            Vec2(cx, cy - r * 0.90),
            Vec2(cx - r * 0.36, cy - r * 0.64),
        ], fill, lw * 1.1, hi);
        draw.drawDot(Vec2(cx, cy + r * 0.54), Math.max(1.2, r * 0.12), darkFill);
        draw.drawSegment(Vec2(cx - r * 0.22, cy + r * 0.16), Vec2(cx + r * 0.22, cy + r * 0.16), lw * 0.9, hi);
        draw.drawSegment(Vec2(cx - r * 0.22, cy - r * 0.14), Vec2(cx + r * 0.22, cy - r * 0.14), lw * 0.9, stroke);
        draw.drawSegment(Vec2(cx - r * 0.14, cy - r * 0.42), Vec2(cx + r * 0.14, cy - r * 0.42), lw * 0.8, stroke);
        return;
    }

    if (kind === "bell") {
        // 铃纹筹：与 3×3 换弹盘 100% 同源的古铜小铃轮廓
        drawReloadPatternGlyph(draw, cx, cy, r * 1.05, "echo", core, alpha);
        return;
    }

    if (kind === "shield") {
        // 残盾：明式包铁边矩形木盾 + 护心铁脐 + 战损微裂
        draw.drawPolygon([
            Vec2(cx - r * 0.64, cy + r * 0.72),
            Vec2(cx + r * 0.64, cy + r * 0.72),
            Vec2(cx + r * 0.58, cy - r * 0.36),
            Vec2(cx, cy - r * 0.82),
            Vec2(cx - r * 0.58, cy - r * 0.36),
        ], fill, lw * 1.15, hi);
        draw.drawCircle(Vec2(cx, cy + r * 0.08), r * 0.20, hi);
        draw.drawSegment(Vec2(cx - r * 0.54, cy + r * 0.44), Vec2(cx - r * 0.20, cy + r * 0.22), lw * 0.8, darkFill);
        return;
    }

    if (kind === "wedge") {
        // 木楔：双斜角梯形加固木楔
        draw.drawPolygon([
            Vec2(cx - r * 0.78, cy - r * 0.46),
            Vec2(cx + r * 0.78, cy - r * 0.46),
            Vec2(cx + r * 0.44, cy + r * 0.52),
            Vec2(cx - r * 0.24, cy + r * 0.52),
        ], fill, lw * 1.15, hi);
        draw.drawSegment(Vec2(cx - r * 0.24, cy + r * 0.52), Vec2(cx - r * 0.12, cy - r * 0.46), lw * 0.9, hi);
        draw.drawSegment(Vec2(cx + r * 0.16, cy + r * 0.10), Vec2(cx + r * 0.46, cy + r * 0.10), lw * 0.75, stroke);
        return;
    }

    if (kind === "ammo") {
        // 备用弹包：束口粗布火药铅丸囊 + 束绳
        draw.drawPolygon([
            Vec2(cx - r * 0.28, cy + r * 0.42),
            Vec2(cx + r * 0.28, cy + r * 0.42),
            Vec2(cx + r * 0.66, cy - r * 0.24),
            Vec2(cx + r * 0.44, cy - r * 0.76),
            Vec2(cx - r * 0.44, cy - r * 0.76),
            Vec2(cx - r * 0.66, cy - r * 0.24),
        ], fill, lw * 1.1, hi);
        // 束口布褶与绳结
        draw.drawSegment(Vec2(cx - r * 0.38, cy + r * 0.40), Vec2(cx + r * 0.38, cy + r * 0.40), lw * 1.25, hi);
        draw.drawSegment(Vec2(cx - r * 0.22, cy + r * 0.42), Vec2(cx - r * 0.36, cy + r * 0.78), lw, stroke);
        draw.drawSegment(Vec2(cx + r * 0.22, cy + r * 0.42), Vec2(cx + r * 0.36, cy + r * 0.78), lw, stroke);
        draw.drawDot(Vec2(cx, cy - r * 0.22), Math.max(1.4, r * 0.18), hi);
        return;
    }

    if (kind === "scrap") {
        // 废木料：交叉粗木板条
        draw.drawSegment(Vec2(cx - r * 0.74, cy - r * 0.48), Vec2(cx + r * 0.74, cy + r * 0.48), lw * 2.1, stroke);
        draw.drawSegment(Vec2(cx - r * 0.74, cy - r * 0.48), Vec2(cx + r * 0.74, cy + r * 0.48), lw * 0.9, hi);
        draw.drawSegment(Vec2(cx - r * 0.64, cy + r * 0.52), Vec2(cx + r * 0.64, cy - r * 0.52), lw * 2.0, stroke);
        draw.drawSegment(Vec2(cx - r * 0.64, cy + r * 0.52), Vec2(cx + r * 0.64, cy - r * 0.52), lw * 0.85, hi);
        return;
    }

    if (kind === "pass") {
        // 护送号牌：明代卫所弧顶木腰牌 + 底端流苏
        draw.drawPolygon([
            Vec2(cx - r * 0.46, cy + r * 0.42),
            Vec2(cx, cy + r * 0.82),
            Vec2(cx + r * 0.46, cy + r * 0.42),
            Vec2(cx + r * 0.46, cy - r * 0.46),
            Vec2(cx - r * 0.46, cy - r * 0.46),
        ], fill, lw * 1.1, hi);
        draw.drawSegment(Vec2(cx, cy - r * 0.46), Vec2(cx, cy - r * 0.88), lw, hi);
        draw.drawSegment(Vec2(cx - r * 0.16, cy - r * 0.66), Vec2(cx - r * 0.22, cy - r * 0.88), lw * 0.75, stroke);
        draw.drawSegment(Vec2(cx + r * 0.16, cy - r * 0.66), Vec2(cx + r * 0.22, cy - r * 0.88), lw * 0.75, stroke);
        drawDiamond(draw, cx, cy + r * 0.04, r * 0.16, r * 0.22, hi);
        return;
    }

    if (kind === "quickbelt") {
        // 快装带：斜挂皮绳 + 三枚竹制药筒
        draw.drawSegment(Vec2(cx - r * 0.78, cy - r * 0.66), Vec2(cx + r * 0.78, cy + r * 0.66), lw * 1.5, stroke);
        let k = -1;
        for (k = -1; k <= 1; k++) {
            const tx = cx + k * r * 0.36;
            const ty = cy + k * r * 0.30;
            draw.drawRect(Rect(tx - r * 0.14, ty - r * 0.24, r * 0.28, r * 0.48), fill, lw * 0.9, hi);
        }
        return;
    }

    drawDiamond(draw, cx, cy, r * 0.56, r * 0.56, fill, lw, hi);
}

/**
 * 在 2.5D 世界舞台上绘制具有接触影、轻浮呼吸与明初轮廓的地面掉落物（供 props.ts 调用）。
 */
export function drawWorldPickupVisual(
    fgDraw: DrawNode.Type,
    fgGlow: DrawNode.Type,
    cx: number,
    groundY: number,
    scalePx: number,
    kind: string,
    time: number,
    seedPhase: number,
): void {
    const meta = pickupMetaOf(kind);
    const bob = Math.sin(time * 2.8 + seedPhase) * 2.1;
    const iconY = groundY + scalePx * 0.88 + bob;
    const r = Math.max(6.5, scalePx * 0.62);

    // 地面柔和接触影（贴地，随浮起略缩）
    const shScale = 1 - bob * 0.025;
    fgDraw.drawEllipse(Vec2(cx, groundY + 1.5), r * 0.95 * shScale, Math.max(2.2, r * 0.30 * shScale), Color(6, 8, 12, 155));

    // 克制暖暗微光圈（工台核心筹材 wood/bell 稍亮，一眼可辨）
    const isBenchMat = kind === "wood" || kind === "bell";
    const glowA = isBenchMat ? (36 + Math.sin(time * 3.6 + seedPhase) * 10) : 22;
    fillRadialGlow(
        fgGlow,
        cx,
        iconY,
        r * (isBenchMat ? 2.1 : 1.65),
        r * (isBenchMat ? 2.1 : 1.65),
        toColor(meta.accentCore, glowA),
        Color(meta.accent.r, meta.accent.g, meta.accent.b, 0),
        12,
    );

    // 深墨衬底圆环，确保在浅石地与暗巷地都具备极佳对比度与灰度可读性
    fgDraw.drawCircle(Vec2(cx, iconY), r * 1.06, Color(10, 12, 18, 150));
    fgDraw.drawRing(Vec2(cx, iconY), r * 1.02, r * 1.14, Color(0, 0, 0, 0), 0.9, toColor(meta.accent, isBenchMat ? 175 : 120));

    drawPickupGlyph(fgDraw, cx, iconY, r * 0.84, kind, 0.98);
}
