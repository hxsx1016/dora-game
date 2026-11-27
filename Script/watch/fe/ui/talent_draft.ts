/**
 * 《向西守望》男主线肉鸽全速 UI 插件：
 * 1. 宋明折笺三选一轻暂停界面（escort1/2/4/5 入段展开，escort3 离工台后展开）：
 *    - 三张竖向烟黛宣纸折笺，各含独立几何纹样（静音/灰度可辨）、流派印记、本领名、当前重数、
 *      一句话战斗实效与改制武器共鸣标签；
 *    - 严格遵守低引导红线：默认以克制氛围短语呈现，开启「按键辅助」后才显示完整键位提示；
 *    - 键鼠（1/2/3 / 方向+回车 / 悬停点选）、手柄（左右/LB/RB + 确认/L3）、触屏（直点卡面）统一复用同一矩形真源。
 * 2. 男主线战斗倒地「折戟重整」轮回小结页：
 *    - 展示本轮抵达段落、轮次、执持武器与已习本领摘要；
 *    - 提供「重整再赴」（推进轮次派生新种子回第一段）与「返回标题」两项操作，附 0.4 秒防误触保护。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { ALL_TALENTS, TALENT_CATALOG, Talent, TalentMeta } from "Script/watch/run";
import { weaponNameOf } from "Script/watch/craft";
import { InputMode } from "Script/watch/controls_config";
import { getActiveTarget } from "Script/watch/target";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import { drawReloadPatternGlyph } from "Script/watch/fe/ui/reload_wheel";
import { drawTalentGlyph as drawCatalogTalentGlyph } from "Script/watch/fe/ui/talent_catalog";
import {
    PALETTE,
    RGBA,
    drawBlossomDot,
    drawDiamond,
    drawFiligreeCorners,
    drawHairline,
    drawSilkKeycap,
    drawSilkRibbon,
    drawSilkVeil,
    fillRadialGlow,
    themeOf,
    toColor,
} from "Script/watch/fe/theme";

/** 单一几何真源：计算三张居中宋明折笺本领卡的 UI 逻辑矩形（渲染、点击、触屏热区共用）。 */
export function computeTalentSlipRects(
    uiW: number,
    uiH: number,
    count: number,
    touchMode: boolean = false,
    safeTop: number = 0,
): Rect.Type[] {
    const out: Rect.Type[] = [];
    if (count <= 0) {
        return out;
    }
    const maxTotalW = Math.max(360, uiW - 96);
    const gap = touchMode ? 20 : 24;
    const baseW = touchMode ? 252 : 246;
    const cardW = Math.min(baseW, Math.floor((maxTotalW - gap * (count - 1)) / count));
    const cardH = Math.min(touchMode ? 270 : 262, Math.max(210, uiH - 220 - safeTop));
    const totalW = count * cardW + (count - 1) * gap;
    const startX = (uiW - totalW) * 0.5;
    const y = Math.max(82, (uiH - cardH) * 0.5 - 12 - safeTop * 0.25);
    let i = 0;
    for (i = 0; i < count; i++) {
        out.push(Rect(startX + i * (cardW + gap), y, cardW, cardH));
    }
    return out;
}

/** 单一几何真源：计算男主线「折戟重整」轮回小结页的两个按钮 UI 逻辑矩形。 */
export function computeEscortDeathButtons(
    uiW: number,
    uiH: number,
): { retry: Rect.Type; title: Rect.Type } {
    const cx = uiW * 0.5;
    const panelH = Math.min(390, Math.max(320, uiH - 170));
    const py = (uiH - panelH) * 0.5;
    const btnW = 216;
    const btnH = 44;
    const btnY = py + 34;
    const gap = 28;
    return {
        retry: Rect(cx - btnW - gap * 0.5, btnY, btnW, btnH),
        title: Rect(cx + gap * 0.5, btnY, btnW, btnH),
    };
}

function branchAccent(branch: TalentMeta["branch"]): RGBA {
    if (branch === "body") return PALETTE.cyan;
    if (branch === "wheel") return PALETTE.amber;
    return PALETTE.rouge;
}

function branchCore(branch: TalentMeta["branch"]): RGBA {
    if (branch === "body") return PALETTE.cyanCore;
    if (branch === "wheel") return PALETTE.amberCore;
    return PALETTE.crimsonCore;
}

/** 静音/灰度可辨的护身流派几何纹样（厚甲=八角盾印、护身=双环交错、疾步=破风双翼）。 */
function drawTalentGlyph(
    draw: DrawNode.Type,
    cx: number,
    cy: number,
    radius: number,
    meta: TalentMeta,
    col: RGBA,
    alpha: number,
): void {
    if (meta.branch !== "body") {
        drawReloadPatternGlyph(draw, cx, cy, radius, meta.glyphEffect, col, alpha);
        return;
    }
    const stroke = toColor(col, 235 * alpha);
    const faint = toColor(col, 130 * alpha);
    const r = Math.max(6, radius);
    if (meta.id === "vitality") {
        // 盾形纹样 + 中央菱芯
        draw.drawPolygon([
            Vec2(cx, cy + r * 0.78),
            Vec2(cx + r * 0.64, cy + r * 0.42),
            Vec2(cx + r * 0.52, cy - r * 0.28),
            Vec2(cx, cy - r * 0.78),
            Vec2(cx - r * 0.52, cy - r * 0.28),
            Vec2(cx - r * 0.64, cy + r * 0.42),
        ], Color(0, 0, 0, 0), 1.45, stroke);
        drawDiamond(draw, cx, cy, r * 0.26, r * 0.34, stroke);
        return;
    }
    if (meta.id === "guard") {
        // 双重回护圆环 + 四向小点
        draw.drawRing(Vec2(cx, cy), r * 0.66, r * 0.76, Color(0, 0, 0, 0), 1.25, stroke);
        draw.drawRing(Vec2(cx, cy), r * 0.34, r * 0.42, Color(0, 0, 0, 0), 1.0, faint);
        draw.drawDot(Vec2(cx, cy + r * 0.92), 1.8, stroke);
        draw.drawDot(Vec2(cx, cy - r * 0.92), 1.8, stroke);
        draw.drawDot(Vec2(cx - r * 0.92, cy), 1.8, stroke);
        draw.drawDot(Vec2(cx + r * 0.92, cy), 1.8, stroke);
        return;
    }
    // stride: 疾步双燕尾折线
    draw.drawSegment(Vec2(cx - r * 0.76, cy + r * 0.38), Vec2(cx + r * 0.16, cy + r * 0.38), 1.5, stroke);
    draw.drawSegment(Vec2(cx - r * 0.22, cy + r * 0.68), Vec2(cx + r * 0.24, cy + r * 0.38), 1.4, stroke);
    draw.drawSegment(Vec2(cx - r * 0.44, cy - r * 0.18), Vec2(cx + r * 0.74, cy - r * 0.18), 1.6, stroke);
    draw.drawSegment(Vec2(cx + r * 0.22, cy + r * 0.14), Vec2(cx + r * 0.76, cy - r * 0.18), 1.5, stroke);
    draw.drawSegment(Vec2(cx + r * 0.22, cy - r * 0.50), Vec2(cx + r * 0.76, cy - r * 0.18), 1.5, stroke);
    draw.drawSegment(Vec2(cx - r * 0.74, cy - r * 0.46), Vec2(cx - r * 0.14, cy - r * 0.46), 1.0, faint);
}

/** 按 UTF-8 字符边界折行（TSTL Lua 字节索引安全，绝不截断汉字）。 */
function wrapTextZh(src: string, maxUnits: number): string[] {
    const out: string[] = [];
    let buf = "";
    let units = 0;
    let ci = 0;
    while (ci < src.length) {
        const b = src.charCodeAt(ci);
        const step = b < 128 ? 1 : (b < 224 ? 2 : (b < 240 ? 3 : 4));
        const ch = src.slice(ci, ci + step);
        const u = b < 128 ? 0.56 : 1.02;
        if (units + u > maxUnits && buf !== "") {
            out.push(buf);
            buf = ch;
            units = u;
        } else {
            buf += ch;
            units += u;
        }
        ci += step;
    }
    if (buf !== "") {
        out.push(buf);
    }
    return out;
}

export class TalentDraftPlugin implements FeRenderPlugin {
    readonly id = "fe-07-talent-draft";

    selected = 0;
    deathSelected = 0;
    private animTime = 0;
    private openFade = 0;
    private deathFade = 0;

    onBindPlay(_p: Play): void {
        this.selected = 0;
        this.deathSelected = 0;
        this.openFade = 0;
        this.deathFade = 0;
    }

    update(ctx: FePluginContext): void {
        if (ctx.paused) {
            return;
        }
        const dt = Math.max(0, ctx.uiDt);
        this.animTime += dt;

        const p = ctx.p;
        const showDraft = p.getStoryTalentOffers().length > 0
            && !p.craftBench.active && !p.reloadOpen && !p.escortFailed;
        if (showDraft) {
            this.openFade = Math.min(1, this.openFade + dt * 5.2);
            const count = p.getStoryTalentOffers().length;
            if (this.selected >= count) {
                this.selected = 0;
            }
            // 鼠标悬停同步高亮（不抢手柄焦点）
            if (ctx.input.inputMode === "kbm" && ctx.input.inside) {
                const ptr = Vec2(ctx.input.mx / ctx.uiScale, ctx.input.my / ctx.uiScale);
                const safeTop = ctx.safeUi !== undefined ? ctx.safeUi.top : 0;
                const boxes = computeTalentSlipRects(ctx.uiW, ctx.uiH, count, false, safeTop);
                let i = 0;
                for (i = 0; i < boxes.length; i++) {
                    if (boxes[i].containsPoint(ptr)) {
                        this.selected = i;
                        break;
                    }
                }
            }
        } else {
            this.openFade = 0;
        }

        if (p.escortFailed) {
            this.deathFade = Math.min(1, this.deathFade + dt * 3.8);
            if (ctx.input.inputMode === "kbm" && ctx.input.inside) {
                const ptr = Vec2(ctx.input.mx / ctx.uiScale, ctx.input.my / ctx.uiScale);
                const btns = computeEscortDeathButtons(ctx.uiW, ctx.uiH);
                if (btns.retry.containsPoint(ptr)) {
                    this.deathSelected = 0;
                } else if (btns.title.containsPoint(ptr)) {
                    this.deathSelected = 1;
                }
            }
        } else {
            this.deathFade = 0;
        }
    }

    drawFullSpeedUi(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        if (p.paused) {
            return false;
        }
        if (p.escortFailed) {
            this.drawDeathSummary(uiDraw, uiInkDraw, uiArt, uiGlow, ctx);
            return true;
        }
        const offers = p.getStoryTalentOffers();
        if (p.talentModalActive && offers.length > 0 && !p.craftBench.active && !p.reloadOpen) {
            this.drawFoldedSlipDraft(uiDraw, uiInkDraw, uiArt, uiGlow, ctx, offers);
            return true;
        }
        return false;
    }

    private drawFoldedSlipDraft(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        offers: Talent[],
    ): void {
        const p = ctx.p;
        const w = ctx.uiW;
        const h = ctx.uiH;
        const alpha = Math.max(0.25, this.openFade);
        const touchMode = ctx.input.isTouchMode();
        const mode: InputMode = ctx.input.inputMode;
        const safeTop = ctx.safeUi !== undefined ? ctx.safeUi.top : 0;
        const safeBottom = ctx.safeUi !== undefined ? ctx.safeUi.bottom : 0;
        const boxes = computeTalentSlipRects(w, h, offers.length, touchMode, safeTop);
        const cx = w * 0.5;

        // 轻暂停半透鸦青墨幕（保留背负周戍与场景轮廓在幕后可辨）
        if (p.talentModalActive) {
            uiDraw.drawRect(Rect(0, 0, w, h), Color(8, 10, 16, Math.round(142 * alpha)));
        }

        const topBox = boxes[0];
        const headY = Math.min(h - 62 - safeTop, topBox.y + topBox.height + 56);
        const theme = themeOf(p.room.key);
        const attempt = p.getEscortAttempt();
        const headTitle = "护送本领 · 三择其一";
        const subLine = attempt > 1
            ? ("第" + attempt + "轮 · " + theme.shortNameZh + " · 择一护身之技")
            : (theme.shortNameZh + " · 择一护身之技");

        drawSilkVeil(uiDraw, uiArt, "td_head_veil", cx, headY - 4, 420, 56, PALETTE.inkWash, 0.80 * alpha, 0);
        drawHairline(uiInkDraw, uiArt, "td_head_line", cx, headY - 30, 320, PALETTE.amber, 0.56 * alpha, true, 2);
        ctx.texts.put("md", headTitle, cx, headY + 6, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 3.2, alpha, 0.10);
        ctx.texts.put("xs", subLine, cx, headY - 16, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.4, 0.90 * alpha, 0.08);

        const ranks = p.getStoryTalentRanks();
        const eq = p.equippedWeapon;
        const breathe = 0.86 + 0.14 * Math.sin(this.animTime * 2.8);

        let i = 0;
        for (i = 0; i < offers.length; i++) {
            const tid = offers[i];
            const meta = TALENT_CATALOG[tid];
            const box = boxes[i];
            const active = i === this.selected;
            const bx = box.x;
            const by = box.y + (active ? 6 : 0);
            const bw = box.width;
            const bh = box.height;
            const mcx = bx + bw * 0.5;
            const accent = branchAccent(meta.branch);
            const core = branchCore(meta.branch);
            const borderCol = active ? PALETTE.rouge : accent;
            const curRank = ranks !== undefined ? (ranks[tid] ?? 0) : 0;
            const hasSynergy = meta.synergyWeapon !== undefined
                && (eq === meta.synergyWeapon || (meta.synergyWeapon === "guide_lantern_gun" && eq === "time_shuttler"));

            // 卡底阴影 + 烟黛折笺底色
            uiArt.tryPlace("ink_frame_mask", "td_shadow_" + i, mcx, by + bh * 0.5 - 4, bw + 26, bh + 24, {
                color: toColor(PALETTE.inkVoid), opacity: (active ? 0.84 : 0.64) * alpha, layer: -1,
            });
            uiDraw.drawRect(
                Rect(bx, by, bw, bh),
                toColor(active ? PALETTE.inkWarm : PALETTE.panelBgDeep, Math.round((active ? 242 : 224) * alpha)),
                active ? 1.5 : 0.95,
                toColor(borderCol, Math.round((active ? 242 : 178) * alpha)),
            );
            // 内折线（仿明版书签内框）
            uiInkDraw.drawRect(
                Rect(bx + 6, by + 6, bw - 12, bh - 12),
                Color(0, 0, 0, 0),
                0.65,
                toColor(active ? PALETTE.silkLine : PALETTE.silkDim, Math.round((active ? 150 : 88) * alpha)),
            );
            drawFiligreeCorners(uiInkDraw, uiArt, "td_cor_" + i, bx, by, bw, bh, borderCol, (active ? 0.94 : 0.56) * alpha, 22, active, 3);
            if (active) {
                fillRadialGlow(uiGlow, mcx, by + bh - 62, 68, 52, toColor(accent, 34 * breathe * alpha), Color(0, 0, 0, 0), 12);
            }

            // 左上序号章 / 右上流派印记
            if (mode === "kbm") {
                drawSilkKeycap(uiInkDraw, ctx.texts, bx + 14, by + bh - 34, 24, 22, "" + (i + 1), borderCol, alpha, active);
            } else {
                drawBlossomDot(uiInkDraw, uiArt, "td_dot_" + i, bx + 24, by + bh - 23, active ? 13 : 9, borderCol, alpha, 4);
            }
            ctx.texts.put("xs", meta.branchZh, bx + bw - 16, by + bh - 23, toColor(core), 1, 0.5, TextAlign.Right, 1.4, 0.90 * alpha, 0.08);

            // 中上几何纹样徽记（静音/灰度可辨）
            const glyphY = by + bh - 68;
            uiArt.tryPlace("ink_enso_fine", "td_ring_" + i, mcx, glyphY, 56, 56, {
                color: toColor(active ? PALETTE.silkLine : accent), opacity: (active ? 0.78 : 0.45) * alpha, layer: 2,
            });
            drawCatalogTalentGlyph(uiInkDraw, mcx, glyphY, 18, tid, active ? PALETTE.textBright : core, alpha, accent);

            // 本领名称与重数
            const titleY = glyphY - 46;
            ctx.texts.put("md", meta.title, mcx, titleY, toColor(active ? PALETTE.textBright : PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 3.6, alpha, 0.10);
            const rankText = curRank > 0 ? ("已习 " + curRank + " 重 → " + (curRank + 1) + " 重") : "初习";
            ctx.texts.put("xs", rankText, mcx, titleY - 22, toColor(curRank > 0 ? PALETTE.amberCore : PALETTE.textDim), 0.5, 0.5, TextAlign.Center, 1.0, 0.90 * alpha, 0.08);
            drawHairline(uiInkDraw, uiArt, "td_div_" + i, mcx, titleY - 36, bw - 40, accent, 0.44 * alpha, false, 2);

            // 战斗实效说明（自动安全折行）
            const lines = wrapTextZh(meta.detailDesc, Math.max(10, Math.floor((bw - 34) / 16)));
            let li = 0;
            for (li = 0; li < Math.min(3, lines.length); li++) {
                ctx.texts.put(
                    "xs",
                    lines[li],
                    mcx,
                    titleY - 56 - li * 21,
                    toColor(active ? PALETTE.textBright : PALETTE.textMid),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    0.4,
                    0.94 * alpha,
                    0.06,
                );
            }

            // 武器共鸣底签（已持对应改制武器时高亮朱砂琥珀带）
            if (meta.synergyLabel !== undefined) {
                const synY = by + 24;
                if (hasSynergy) {
                    drawSilkRibbon(uiDraw, uiArt, "td_syn_" + i, mcx, synY, bw - 28, 24, PALETTE.rougeSoft, 0.62 * alpha, 0);
                }
                ctx.texts.put(
                    "xs",
                    hasSynergy ? ("· " + meta.synergyLabel + " ·") : meta.synergyLabel,
                    mcx,
                    synY,
                    toColor(hasSynergy ? PALETTE.amberCore : PALETTE.textDim),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    0.8,
                    (hasSynergy ? 0.98 : 0.72) * alpha,
                    0.06,
                );
            }
        }

        // 低引导原则：默认不显示大段键位说明；开启「按键辅助」或触屏时提供简短尾注
        if (ctx.view.assistHintsEnabled || touchMode) {
            const footY = Math.max(38 + safeBottom * 0.4, topBox.y - 34);
            const hint = mode === "gamepad"
                ? ("左摇杆 / LB·RB 择笺   ·   " + getActiveTarget().keyTagFor("confirm", "gamepad", ctx.input.gamepadLayout) + " 习得")
                : (touchMode
                    ? "轻触折笺习得此技"
                    : "按 1 / 2 / 3 · ←/→ 与回车或点击折笺习得");
            ctx.texts.put("xs", hint, cx, footY, toColor(PALETTE.textDim), 0.5, 0.5, TextAlign.Center, 1.2, 0.88 * alpha, 0.08);
        }
    }

    private drawDeathSummary(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): void {
        const p = ctx.p;
        const summary = p.escortSummary;
        const w = ctx.uiW;
        const h = ctx.uiH;
        const alpha = Math.max(0.2, this.deathFade);
        const cx = w * 0.5;
        const panelW = Math.min(620, w - 84);
        const panelH = Math.min(390, Math.max(320, h - 170));
        const px = cx - panelW * 0.5;
        const py = (h - panelH) * 0.5;
        const midY = py + panelH * 0.5;

        uiDraw.drawRect(Rect(0, 0, w, h), Color(7, 9, 14, Math.round(188 * alpha)));
        uiArt.tryPlace("ink_frame_mask", "ds_shadow", cx, midY - 6, panelW + 46, panelH + 40, {
            color: toColor(PALETTE.inkVoid), opacity: 0.88 * alpha, layer: -1,
        });
        uiDraw.drawRect(
            Rect(px, py, panelW, panelH),
            toColor(PALETTE.panelBgDeep, Math.round(244 * alpha)),
            1.2,
            toColor(PALETTE.rouge, Math.round(200 * alpha)),
        );
        uiInkDraw.drawRect(
            Rect(px + 8, py + 8, panelW - 16, panelH - 16),
            Color(0, 0, 0, 0),
            0.7,
            toColor(PALETTE.silkDim, Math.round(115 * alpha)),
        );
        drawFiligreeCorners(uiInkDraw, uiArt, "ds_cor", px, py, panelW, panelH, PALETTE.rouge, 0.88 * alpha, 28, true, 3);
        fillRadialGlow(uiGlow, cx, py + panelH - 68, 160, 74, toColor(PALETTE.rouge, 26 * alpha), Color(0, 0, 0, 0), 14);

        const headY = py + panelH - 52;
        ctx.texts.put("lg", "折返山道", cx, headY, toColor(PALETTE.crimsonCore), 0.5, 0.5, TextAlign.Center, 6.0, alpha, 0.10);
        ctx.texts.put("xs", "肩上的人还在，换一条路重头再护。", cx, headY - 34, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 1.4, 0.90 * alpha, 0.08);
        drawHairline(uiInkDraw, uiArt, "ds_div", cx, headY - 54, panelW - 96, PALETTE.silkDim, 0.56 * alpha, true, 2);

        const reachedKey = summary !== undefined ? summary.roomKey : p.room.key;
        const reachedTheme = themeOf(reachedKey);
        const attempt = summary !== undefined ? summary.attempt : p.getEscortAttempt();
        const weapon = weaponNameOf(summary !== undefined ? summary.equippedWeapon : p.equippedWeapon);

        const infoTop = headY - 82;
        ctx.texts.put(
            "sm",
            "第 " + attempt + " 轮护送   ·   止步于「" + reachedTheme.titleZh + "」",
            cx,
            infoTop,
            toColor(PALETTE.textBright),
            0.5,
            0.5,
            TextAlign.Center,
            1.2,
            0.96 * alpha,
            0.08,
        );
        ctx.texts.put(
            "xs",
            "执持火器：" + weapon + "   ·   重整后将以新路数自第一段再赴北塔",
            cx,
            infoTop - 30,
            toColor(PALETTE.amberCore),
            0.5,
            0.5,
            TextAlign.Center,
            1.0,
            0.90 * alpha,
            0.08,
        );

        const rankParts: string[] = [];
        if (summary !== undefined) {
            let ti = 0;
            for (ti = 0; ti < ALL_TALENTS.length; ti++) {
                const tid = ALL_TALENTS[ti];
                const rk = summary.ranks[tid] ?? 0;
                if (rk > 0) {
                    rankParts.push(TALENT_CATALOG[tid].title + "×" + rk);
                }
            }
        }
        const talentSummary = rankParts.length > 0 ? ("本轮已习本领：" + rankParts.join(" · ")) : "本轮尚未习得新本领";
        ctx.texts.put("xs", talentSummary, cx, infoTop - 60, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 0.8, 0.88 * alpha, 0.08);

        // 底部两枚操作按钮
        const btns = computeEscortDeathButtons(w, h);
        const ready = p.escortFailedTicks >= 24;
        const btnAlpha = ready ? alpha : alpha * 0.55;
        const breathe = 0.86 + 0.14 * Math.sin(this.animTime * 2.6);

        const drawBtn = (box: Rect.Type, idx: number, tag: string, label: string): void => {
            const active = this.deathSelected === idx;
            const bcx = box.x + box.width * 0.5;
            const bcy = box.y + box.height * 0.5;
            if (active) {
                drawSilkRibbon(uiDraw, uiArt, "ds_btn_rib_" + tag, bcx, bcy, box.width + 18, box.height, PALETTE.rougeSoft, 0.64 * breathe * btnAlpha, 0);
                drawHairline(uiInkDraw, uiArt, "ds_btn_line_" + tag, bcx, box.y + 3, box.width - 26, PALETTE.silkLine, 0.52 * btnAlpha, false, 2);
                drawBlossomDot(uiInkDraw, uiArt, "ds_btn_dot_" + tag, box.x + 18, bcy, 12, PALETTE.rouge, 0.96 * btnAlpha, 4);
            } else {
                drawSilkVeil(uiDraw, uiArt, "ds_btn_idle_" + tag, bcx, bcy, box.width, box.height - 2, PALETTE.inkWash, 0.68 * btnAlpha, 0);
                drawBlossomDot(uiInkDraw, uiArt, "ds_btn_dot_" + tag, box.x + 18, bcy, 7, PALETTE.silkDim, 0.48 * btnAlpha, 3);
            }
            ctx.texts.put(
                "sm",
                label,
                bcx + 6,
                bcy,
                toColor(active ? PALETTE.textBright : PALETTE.textMid),
                0.5,
                0.5,
                TextAlign.Center,
                active ? 2.4 : 1.4,
                btnAlpha,
                0.08,
            );
        };

        drawBtn(btns.retry, 0, "retry", "重整再赴");
        drawBtn(btns.title, 1, "title", "返回标题");
    }
}
