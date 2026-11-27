/**
 * 《向西守望》宋明清雅极简 HUD（V3 · 三模统一解耦版）：
 * - 统一消费 InputMode / GamepadLayout / SafeInsets，零平台硬编码；
 * - 键鼠 / 手柄 / 触屏三套世界标牌、本领卡提示、暂歇提示与准星反馈全由 control_prompts.ts 驱动；
 * - 支持手柄本领卡高亮焦点、长按 BACK 重试进度条、触屏放大本领卡与触屏非投瓶态自动隐藏小满圆点。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { talentNames } from "Script/watch/run";
import { DEPTH_Y_SCALE } from "Script/watch/depth";
import { FEAR_MAX } from "Script/watch/escort";
import { GamepadLayout, InputMode } from "Script/watch/controls_config";
import { SafeInsets, ZERO_SAFE_INSETS } from "Script/watch/platform";
import { getActiveTarget } from "Script/watch/target";
import { WorldPrompt, deriveWorldPrompt } from "Script/watch/fe/adapter";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { VfxSystem } from "Script/watch/fe/renderer/vfx";
import { TextPool } from "Script/watch/fe/ui/textpool";
import {
    PALETTE,
    drawBlossomDot,
    drawHairline,
    drawSilkKeycap,
    drawSilkVeil,
    fillRadialGlow,
    themeOf,
    toColor,
    visualTextWidth,
} from "Script/watch/fe/theme";

export class HudRenderer {
    /** 掉血滞后淡胭脂余痕 */
    private ghostHp = 3;
    private time = 0;
    /** 手柄模式下男主线三选一本领卡当前高亮索引 */
    talentSelected = 0;
    /** 已挂载 RoguelikeUiPlugin 时自动礼让旧版顶部扁矩形与文本行，防止双层叠绘 */
    roguelikeUiHandled = false;
    /** 指向 RoguelikeUiPlugin 的选筹热区单一真源（保持 hud.talentCardRects 100% 兼容） */
    talentRectProvider?: (w: number, h: number, count: number, touchMode: boolean, safeTop: number) => Rect.Type[];

    reset(p?: Play): void {
        this.ghostHp = p !== undefined ? p.hp : 3;
        this.talentSelected = 0;
    }

    update(dt: number, p: Play): void {
        this.time += dt;
        if (this.ghostHp > p.hp) {
            this.ghostHp = Math.max(p.hp, this.ghostHp - dt * 1.45);
        } else {
            this.ghostHp = p.hp;
        }
    }

    draw(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        p: Play,
        cam: CameraDirector,
        vfx: VfxSystem,
        letterboxFrac: number,
        uiScale: number,
        assistHintsEnabled: boolean = false,
        suppressReticle: boolean = false,
        inputMode: InputMode = "kbm",
        gamepadLayout: GamepadLayout = "xbox",
        safe: SafeInsets = ZERO_SAFE_INSETS,
        retryHoldProgress: number = 0,
        touchOverlayVisible: boolean = false,
    ): void {
        const w = cam.viewW / uiScale;
        const h = cam.viewH / uiScale;
        const hudAlpha = Math.max(0, 1 - letterboxFrac * 1.15);

        if (hudAlpha > 0.05) {
            if (p.childMode) {
                this.drawChildStatus(uiDraw, uiInkDraw, uiArt, texts, p, h, hudAlpha, assistHintsEnabled, inputMode, gamepadLayout, safe);
            } else {
                this.drawSoldierStatus(uiDraw, uiInkDraw, uiArt, texts, p, h, hudAlpha, assistHintsEnabled, inputMode, gamepadLayout, safe);
            }

            this.drawChapterBadge(uiDraw, uiArt, texts, p, w, h, hudAlpha, inputMode, safe, touchOverlayVisible);
            this.drawContextualObjective(uiDraw, uiInkDraw, uiArt, texts, p, w, h, hudAlpha, assistHintsEnabled, inputMode, gamepadLayout, safe);

            if (assistHintsEnabled) {
                const prompt = deriveWorldPrompt(p);
                if (prompt !== undefined) {
                    const adapted: WorldPrompt = {
                        x: prompt.x,
                        y: prompt.y,
                        keyTag: getActiveTarget().adaptWorldKeyTag(prompt.keyTag, inputMode, gamepadLayout),
                        label: prompt.label,
                        urgent: prompt.urgent,
                        progress: prompt.progress,
                    };
                    this.drawWorldPrompts(uiDraw, uiInkDraw, uiArt, texts, [adapted], cam, hudAlpha, uiScale, safe);
                }
            }

            if (vfx.deflectFlash > 0.25) {
                const dx = cam.sx(vfx.deflectX) / uiScale;
                const dy = cam.sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16;
                texts.put("sm", "掩体挡下", dx, dy, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 2.0, vfx.deflectFlash, 0.10);
            }
        }

        // 手柄长按 BACK 重试检查点进度条（避让 Dora Go Back+Start 组合键）
        if (retryHoldProgress > 0.02) {
            const cx = w * 0.5;
            const cy = h - 32 - safe.top;
            const bw = 220;
            drawSilkVeil(uiDraw, uiArt, "hud_retry_hold_veil", cx, cy, bw + 60, 34, PALETTE.inkWarm, 0.84, 2);
            texts.put("xs", "长按 BACK 重试检查点", cx, cy + 7, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.0, 0.96, 0.08);
            const x0 = cx - bw * 0.44;
            const x1 = cx + bw * 0.44;
            uiInkDraw.drawSegment(Vec2(x0, cy - 8), Vec2(x1, cy - 8), 1.4, toColor(PALETTE.silkDim, 120));
            uiInkDraw.drawSegment(Vec2(x0, cy - 8), Vec2(x0 + (x1 - x0) * Math.min(1, retryHoldProgress), cy - 8), 2.8, toColor(PALETTE.rouge, 235));
        }

        if (!suppressReticle) {
            this.drawReticleOverlay(uiInkDraw, uiArt, uiGlow, p, cam, vfx, letterboxFrac, uiScale, inputMode === "touch");
        }
    }

    /** 计算男主线护送段三选一本领卡的 UI 坐标矩形（渲染与点击命中共用单一真源）。 */
    talentCardRects(w: number, h: number, count: number, touchMode: boolean = false, safeTop: number = 0): Rect.Type[] {
        if (this.talentRectProvider !== undefined) {
            return this.talentRectProvider(w, h, count, touchMode, safeTop);
        }
        const out: Rect.Type[] = [];
        if (count <= 0) {
            return out;
        }
        const cardW = touchMode ? 212 : 204;
        const cardH = touchMode ? 50 : 38;
        const gap = 14;
        const totalW = count * cardW + (count - 1) * gap;
        const startX = (w - totalW) * 0.5;
        const y = h - (touchMode ? 132 : 120) - safeTop;
        let i = 0;
        for (i = 0; i < count; i++) {
            out.push(Rect(startX + i * (cardW + gap), y, cardW, cardH));
        }
        return out;
    }

    /** 独立绘制战斗/投瓶准星（供 frontend.ts 在全速 UI 插件判定后决定是否绘制，实现同帧零闪烁隐藏） */
    drawReticleOverlay(
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        vfx: VfxSystem,
        letterboxFrac: number,
        uiScale: number,
        touchMode: boolean = false,
    ): void {
        if (!p.paused && letterboxFrac < 0.5 && !p.gripping &&
            p.escort.state !== "calming" && !p.gateNeedConfirm && p.phase !== "prologue-give") {
            this.drawReticle(uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale, touchMode);
        }
    }

    private drawSoldierStatus(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        texts: TextPool,
        p: Play,
        h: number,
        alpha: number,
        assistHintsEnabled: boolean,
        inputMode: InputMode,
        gamepadLayout: GamepadLayout,
        safe: SafeInsets,
    ): void {
        const bx = 28 + safe.left;
        const by = h - 72 - safe.top;
        const lowHp = p.hp <= 1;

        const segCount = Math.max(1, p.maxHp);
        const segW = segCount >= 5 ? 42 : 54;
        const segH = 9;
        const gap = segCount >= 5 ? 6 : 8;
        const veilW = Math.max(340, 124 + segCount * (segW + gap));
        drawSilkVeil(uiDraw, uiArt, "hud_soldier_veil", bx + veilW * 0.44, by + 24, veilW, 56, PALETTE.inkWash, 0.62 * alpha, -1);
        texts.put("md", "戍", bx + 16, by + 25, toColor(lowHp ? PALETTE.rouge : PALETTE.cyanCore), 0.5, 0.5, TextAlign.Center, 0, alpha, 0.10);
        uiInkDraw.drawSegment(Vec2(bx + 32, by + 9), Vec2(bx + 32, by + 40), 0.8, toColor(PALETTE.silkDim, 130 * alpha));
        texts.put("xs", "周戍 · 体力", bx + 44, by + 36, toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.4, alpha, 0.08);

        const barX = bx + 44;
        const barY = by + 16;

        let i = 0;
        for (i = 0; i < segCount; i++) {
            const sx = barX + i * (segW + gap);
            const scx = sx + segW * 0.5;
            if (!uiArt.tryPlace("ink_bamboo_slot", "hp_slot_" + i, scx, barY, segW, segH, {
                color: toColor(PALETTE.silkDim), opacity: 0.72 * alpha, layer: 1,
            })) {
                uiInkDraw.drawRect(Rect(sx, barY - 3, segW, 6), Color(0, 0, 0, 0), 0.8, toColor(PALETTE.silkDim, 145 * alpha));
            }
            if (this.ghostHp > i && this.ghostHp > p.hp) {
                const frac = Math.min(1, this.ghostHp - i);
                uiInkDraw.drawRect(Rect(sx + 3, barY - 2, (segW - 6) * frac, 4), toColor(PALETTE.crimsonCore, 150 * alpha));
            }
            if (p.hp > i) {
                const pulse = lowHp ? (0.72 + 0.28 * Math.sin(this.time * 7.0)) : 1;
                const fillCol = lowHp ? PALETTE.rouge : PALETTE.moonPale;
                if (!uiArt.tryPlace("ink_bamboo_slip", "hp_fill_" + i, scx, barY, segW, segH, {
                    color: toColor(fillCol), opacity: 0.94 * alpha * pulse, layer: 2,
                })) {
                    uiInkDraw.drawRect(Rect(sx + 2, barY - 2.5, segW - 4, 5), toColor(fillCol, 230 * alpha * pulse));
                }
            }
        }

        const covX = barX + segCount * (segW + gap) + 6;
        let hasAliveEnemy = false;
        for (i = 0; i < p.enemies.length; i++) {
            if (p.enemies[i].alive) {
                hasAliveEnemy = true;
                break;
            }
        }
        if (p.coverHug) {
            if (hasAliveEnemy && !p.coverBlocking) {
                uiInkDraw.drawRect(Rect(covX, barY - 9, 72, 18), toColor(PALETTE.inkWarm, 185 * alpha), 0.8, toColor(PALETTE.amber, 200 * alpha));
                texts.put("xs", "背向掩体", covX + 36, barY, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 0.6, alpha, 0);
            } else {
                uiInkDraw.drawRect(Rect(covX, barY - 9, 54, 18), toColor(PALETTE.cyanDim, 165 * alpha), 0.8, toColor(PALETTE.cyanCore, 180 * alpha));
                texts.put("xs", "掩体中", covX + 27, barY, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 0.6, alpha, 0);
            }
        } else if (assistHintsEnabled && p.coverNear) {
            uiInkDraw.drawRect(Rect(covX, barY - 9, 54, 18), Color(14, 17, 25, Math.round(150 * alpha)), 0.8, toColor(PALETTE.silkLine, 165 * alpha));
            texts.put("xs", "可贴靠", covX + 27, barY, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 0.6, alpha, 0.08);
        }

        const showCampaignFear = p.isCampaign && (p.room.campaign?.chapter === "S" || p.room.campaign?.chapter === "C")
            && (p.escort.fear > 0 || p.escort.state === "frozen" || p.escort.state === "calming");
        if (p.room.key === "prologue" || p.room.key === "street" || p.room.key === "checkpoint" || showCampaignFear) {
            const subY = by - 24;
            const frozen = p.escort.state === "frozen";
            const calming = p.escort.state === "calming";

            drawSilkVeil(uiDraw, uiArt, "hud_fear_veil", bx + 126, subY + 6, 260, 30, frozen ? PALETTE.inkWarm : PALETTE.inkWash, 0.64 * alpha, -1);
            texts.put("xs", "小满 · 惊惧", bx + 14, subY + 6, toColor(frozen ? PALETTE.crimsonCore : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.0, alpha, 0.08);

            let k = 0;
            for (k = 0; k < FEAR_MAX; k++) {
                const dx = bx + 114 + k * 20;
                const dy = subY + 6;
                const lit = k < p.escort.fear;
                const dc = frozen ? PALETTE.rouge : PALETTE.amber;
                uiArt.tryPlace("ink_enso_fine", "fear_ring_" + k, dx, dy, 14, 14, {
                    color: toColor(lit ? dc : PALETTE.silkLine), opacity: (lit ? 0.92 : 0.64) * alpha, layer: 2,
                });
                if (lit) {
                    drawBlossomDot(uiInkDraw, uiArt, "fear_dot_" + k, dx, dy, 10, dc, 0.96 * alpha, 3);
                }
            }

            if (frozen) {
                const pulse = 0.65 + 0.35 * Math.sin(this.time * 7.0);
                if (assistHintsEnabled) {
                    const calmKey = getActiveTarget().adaptWorldKeyTag("E", inputMode, gamepadLayout);
                    const keyW = Math.max(22, visualTextWidth(calmKey, 15) + 10);
                    drawSilkKeycap(uiInkDraw, texts, bx + 170, subY - 5, keyW, 22, calmKey, PALETTE.rouge, alpha * pulse, true);
                    texts.put("xs", "轻敲安抚", bx + 176 + keyW, subY + 6, toColor(PALETTE.crimsonCore), 0, 0.5, TextAlign.Left, 0.8, alpha * pulse, 0.08);
                } else {
                    texts.put("xs", "受惊停步", bx + 172, subY + 6, toColor(PALETTE.crimsonCore), 0, 0.5, TextAlign.Left, 0.8, alpha * pulse, 0.08);
                }
            } else if (calming) {
                texts.put("xs", "轻敲安抚中", bx + 172, subY + 6, toColor(PALETTE.emerald), 0, 0.5, TextAlign.Left, 0.8, alpha, 0.08);
            }
        }

        if (!this.roguelikeUiHandled) {
            const ranks = p.getStoryTalentRanks();
            if (ranks !== undefined) {
                const parts: string[] = [];
                if (ranks.vitality > 0) parts.push("厚甲" + ranks.vitality);
                if (ranks.focus > 0) parts.push("凝神" + ranks.focus);
                if (ranks.guard > 0) parts.push("护身" + ranks.guard);
                if (ranks.salvage > 0) parts.push("拾料" + ranks.salvage);
                if (parts.length > 0) {
                    const subY = by - 22;
                    const txt = "本领 · " + parts.join(" · ");
                    drawSilkVeil(uiDraw, uiArt, "hud_talent_ranks_veil", bx + 126, subY + 6, 260, 26, PALETTE.inkWash, 0.56 * alpha, -1);
                    texts.put("xs", txt, bx + 14, subY + 6, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 0.8, alpha, 0.08);
                }
            } else if (p.isCampaign && p.room.campaign !== undefined && (p.room.campaign.chapter === "S" || p.room.campaign.chapter === "C")) {
                const inv = p.run.inventory;
                const items: string[] = [];
                if (inv.shield > 0) items.push("残盾" + inv.shield);
                if (inv.wedge > 0) items.push("木楔" + inv.wedge);
                if (inv.ammo > 0) items.push("弹包" + inv.ammo);
                if (inv.scrap > 0) items.push("木料" + inv.scrap);
                const companionText = p.run.joined ? "小满同行" : "小满等待";
                const summary = items.length > 0 ? (companionText + " · " + items.join(" ")) : companionText;
                const subY = by - 22;
                drawSilkVeil(uiDraw, uiArt, "hud_camp_veil", bx + 126, subY + 6, 260, 26, PALETTE.inkWash, 0.54 * alpha, -1);
                texts.put("xs", summary, bx + 14, subY + 6, toColor(p.run.joined ? PALETTE.cyanCore : PALETTE.amberCore), 0, 0.5, TextAlign.Left, 0.8, alpha, 0.08);
            }
        }
    }

    private drawChildStatus(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        texts: TextPool,
        p: Play,
        h: number,
        alpha: number,
        assistHintsEnabled: boolean,
        inputMode: InputMode,
        gamepadLayout: GamepadLayout,
        safe: SafeInsets,
    ): void {
        const bx = 28 + safe.left;
        const by = h - 68 - safe.top;
        const alert = p.scavChase || p.dogState === "chase" || p.dogState === "ear" || p.scavSee > 0;
        const leadCol = alert ? PALETTE.rouge : (p.player.crouch ? PALETTE.emerald : PALETTE.amberCore);

        drawSilkVeil(uiDraw, uiArt, "hud_child_veil", bx + 144, by + 22, 316, 48, alert ? PALETTE.inkWarm : PALETTE.inkWash, 0.58 * alpha, -1);
        texts.put("md", alert ? "危" : "满", bx + 16, by + 22, toColor(leadCol), 0.5, 0.5, TextAlign.Center, 0, alpha, 0.10);
        uiInkDraw.drawSegment(Vec2(bx + 32, by + 7), Vec2(bx + 32, by + 37), 0.8, toColor(PALETTE.silkDim, 130 * alpha));
        texts.put("xs", "小满 · 潜行", bx + 44, by + 33, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 1.4, alpha, 0.08);

        let posture = assistHintsEnabled ? "轻步前行 · 保持隐蔽" : "轻步前行";
        let col = PALETTE.textMid;
        if (alert) {
            posture = p.scavChase || p.dogState === "chase"
                ? (assistHintsEnabled ? "已被发现 · 速寻隐蔽" : "已被发现")
                : (assistHintsEnabled ? "引起警觉 · 停步蹲伏" : "引起警觉");
            col = PALETTE.crimsonCore;
        } else if (p.player.crouch) {
            posture = assistHintsEnabled ? "低姿伏行 · 匿迹于影" : "低姿伏行";
            col = PALETTE.emerald;
        } else if (p.hasBottle) {
            posture = assistHintsEnabled
                ? getActiveTarget().adaptHintSentence("手持陶瓶 · 按住 [F] 瞄投", inputMode, gamepadLayout)
                : "手持陶瓶";
            col = PALETTE.amberCore;
        }
        texts.put("xs", posture, bx + 44, by + 12, toColor(col), 0, 0.5, TextAlign.Left, 0.6, alpha, 0.08);
    }

    private drawChapterBadge(
        uiDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
        alpha: number,
        inputMode: InputMode,
        safe: SafeInsets,
        touchOverlayVisible: boolean,
    ): void {
        const theme = themeOf(p.room.key);
        const rx = w - 32 - safe.right - (touchOverlayVisible ? 208 : 0);
        const cy = h - 44 - safe.top;
        const pauseTip = inputMode === "gamepad" ? "START 暂歇" : "Esc 暂歇";

        drawSilkVeil(uiDraw, uiArt, "hud_chap_veil", rx - 82, cy, 240, 44, PALETTE.inkWash, 0.44 * alpha, -1);
        texts.put("xs", theme.numeralZh + " · " + theme.titleZh, rx, touchOverlayVisible ? cy : cy + 9, toColor(PALETTE.textBright), 1, 0.5, TextAlign.Right, 1.2, alpha, 0.08);
        if (!touchOverlayVisible) {
            texts.put("xs", pauseTip, rx, cy - 11, toColor(PALETTE.textDim), 1, 0.5, TextAlign.Right, 1.0, 0.78 * alpha, 0.08);
        }
    }

    private drawContextualObjective(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
        alpha: number,
        assistHintsEnabled: boolean,
        inputMode: InputMode,
        gamepadLayout: GamepadLayout,
        safe: SafeInsets,
    ): void {
        const touchMode = inputMode === "touch";
        const talentOffers = p.getStoryTalentOffers();
        if (!this.roguelikeUiHandled && talentOffers.length > 0 && !p.craftBench.active && !p.reloadOpen) {
            const boxes = this.talentCardRects(w, h, talentOffers.length, touchMode, safe.top);
            const cx = w * 0.5;
            const titleY = h - 54 - safe.top;
            const talentHint = inputMode === "gamepad"
                ? "护送本领三选一 · LB/RB 择项 · L3 确认或点选"
                : (touchMode
                    ? "护送本领三选一 · 轻触卡面习得"
                    : "护送本领三选一 · 按 1 / 2 / 3 或点击习得");
            drawSilkVeil(uiDraw, uiArt, "hud_talent_head_veil", cx, titleY, 410, 26, PALETTE.inkWash, 0.72 * alpha, -1);
            drawHairline(uiInkDraw, uiArt, "hud_talent_head_line", cx, titleY + 13, 330, PALETTE.amber, 0.52 * alpha, true, 2);
            texts.put("xs", talentHint, cx, titleY, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.2, alpha, 0.08);

            let ti = 0;
            for (ti = 0; ti < talentOffers.length; ti++) {
                const box = boxes[ti];
                const bx = box.x;
                const by = box.y;
                const bh = box.height;
                const cy = by + bh * 0.5;
                const gpFocus = inputMode === "gamepad" && ti === this.talentSelected;
                const borderCol = gpFocus ? PALETTE.rouge : PALETTE.amber;
                uiDraw.drawRect(
                    box,
                    toColor(gpFocus ? PALETTE.inkWarm : PALETTE.panelBgDeep, Math.round((gpFocus ? 235 : 215) * alpha)),
                    gpFocus ? 1.5 : 0.9,
                    toColor(borderCol, Math.round((gpFocus ? 235 : 185) * alpha)),
                );
                if (inputMode === "kbm") {
                    drawSilkKeycap(uiInkDraw, texts, bx + 8, cy - 11, 22, 22, "" + (ti + 1), borderCol, alpha, true);
                    texts.put("xs", talentNames[talentOffers[ti]], bx + 38, cy, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.6, alpha, 0.08);
                } else {
                    drawBlossomDot(uiInkDraw, uiArt, "hud_talent_dot_" + ti, bx + 18, cy, gpFocus ? 12 : 8, borderCol, alpha, 4);
                    texts.put("xs", talentNames[talentOffers[ti]], bx + 34, cy, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.6, alpha, 0.08);
                }
            }
        }

        // 工台与 3×3 慢时换弹界面已分别由 CraftBenchPlugin / ReloadWheelPlugin 全速层接管，
        // 此处不再叠绘旧版灰盒工台与顶部换弹条，避免新旧双层 UI 互相遮挡与错位键位提示。

        if (p.room.key === "gate" && p.room.story !== undefined && p.room.story.gate !== undefined) {
            const g = p.room.story.gate;
            if (p.phase === "gate-wait" || p.phase === "gate-hand") {
                const bw = 400;
                const cx = w * 0.5;
                const by = h - 64 - safe.top;
                const tied = p.phase === "gate-hand";
                const ratio = tied ? 1 : Math.max(0, Math.min(1, p.handTicks / Math.max(1, p.handNeedTicks)));
                const holdInteractKey = getActiveTarget().adaptWorldKeyTag("按住 E", inputMode, gamepadLayout);
                const reholdInteractKey = getActiveTarget().adaptWorldKeyTag("松开再按住 E", inputMode, gamepadLayout);
                const label = tied ? "我们走吧。"
                    : (p.handTicks > 0 ? "牵起小满 · " + p.handTicks + " / " + p.handNeedTicks
                        : (p.handArmed ? (holdInteractKey + " · 把手伸给她") : (reholdInteractKey + " · 把手伸给她")));

                drawSilkVeil(uiDraw, uiArt, "hud_hand_veil", cx, by + 18, bw + 90, 48, PALETTE.inkWash, 0.76 * alpha, -1);
                drawHairline(uiInkDraw, uiArt, "hud_hand_top", cx, by + 39, bw - 20, PALETTE.amber, 0.55 * alpha, false, 2);
                texts.put("xs", label, cx, by + 26, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.8, alpha, 0.08);

                const pbw = bw - 80;
                const pbx = cx - pbw * 0.5;
                const pby = by + 9;
                uiInkDraw.drawSegment(Vec2(pbx, pby), Vec2(pbx + pbw, pby), 1.4, toColor(PALETTE.silkDim, 115 * alpha));
                if (ratio > 0.002) {
                    uiInkDraw.drawSegment(Vec2(pbx, pby), Vec2(pbx + pbw * ratio, pby), 2.8, toColor(PALETTE.amber, 230 * alpha));
                    uiInkDraw.drawSegment(Vec2(pbx, pby), Vec2(pbx + pbw * ratio, pby), 1.0, toColor(PALETTE.amberCore, 165 * alpha));
                }
                uiArt.tryPlace("ink_enso_fine", "hand_knock_1", pbx + pbw * 0.62, pby, 11, 11, {
                    color: toColor(PALETTE.amber), opacity: (p.knocks >= 1 ? 0.9 : 0.45) * alpha, layer: 3,
                });
                uiArt.tryPlace("ink_enso_fine", "hand_knock_2", pbx + pbw * 0.72, pby, 11, 11, {
                    color: toColor(PALETTE.amber), opacity: (p.knocks >= 2 ? 0.9 : 0.45) * alpha, layer: 3,
                });
            }
            if (p.phase === "gate-hold" || p.phase === "gate-idle") {
                const bw = 400;
                const cx = w * 0.5;
                const by = h - 64 - safe.top;
                const ratio = Math.max(0, Math.min(1, p.gateTick / Math.max(1, g.holdTicks)));
                const secLeft = Math.max(0, (g.holdTicks - p.gateTick) / 60);
                const secStr = secLeft.toFixed(1);

                drawSilkVeil(uiDraw, uiArt, "hud_gate_veil", cx, by + 18, bw + 90, 48, PALETTE.inkWash, 0.76 * alpha, -1);
                drawHairline(uiInkDraw, uiArt, "hud_gate_top", cx, by + 39, bw - 20, PALETTE.rougeSoft, 0.55 * alpha, false, 2);

                const idleNeedConfirmLabel = assistHintsEnabled
                    ? getActiveTarget().adaptHintSentence("绞盘待命 · 按 [E] 重新守门", inputMode, gamepadLayout)
                    : "绞盘待命";
                const label = p.phase === "gate-idle"
                    ? (p.gateNeedConfirm ? idleNeedConfirmLabel : "待小满就位 · 绞盘启")
                    : ("城门死守 · 余 " + secStr + " 秒");
                texts.put("xs", label, cx, by + 26, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.8, alpha, 0.08);

                const pbw = bw - 80;
                const pbx = cx - pbw * 0.5;
                const pby = by + 9;
                uiInkDraw.drawSegment(Vec2(pbx, pby), Vec2(pbx + pbw, pby), 1.4, toColor(PALETTE.silkDim, 115 * alpha));
                if (ratio > 0.002) {
                    uiInkDraw.drawSegment(Vec2(pbx, pby), Vec2(pbx + pbw * ratio, pby), 2.8, toColor(PALETTE.rouge, 230 * alpha));
                    uiInkDraw.drawSegment(Vec2(pbx, pby), Vec2(pbx + pbw * ratio, pby), 1.0, toColor(PALETTE.crimsonCore, 165 * alpha));
                }
                const waves = [0, 540 / 2700, 900 / 2700, 1500 / 2700];
                let k = 0;
                for (k = 0; k < waves.length; k++) {
                    const wx = pbx + pbw * waves[k];
                    const passed = p.gateSpawned > k;
                    if (passed) {
                        drawBlossomDot(uiInkDraw, uiArt, "gate_wave_" + k, wx, pby, 10, PALETTE.moonPale, 0.92 * alpha, 3);
                    } else {
                        uiArt.tryPlace("ink_enso_fine", "gate_wave_" + k, wx, pby, 11, 11, {
                            color: toColor(PALETTE.rouge), opacity: 0.84 * alpha, layer: 3,
                        });
                    }
                }
            }
            return;
        }

        if (!assistHintsEnabled) {
            return;
        }
        if (p.room.key === "checkpoint" || p.room.key === "outside") {
            const cx = w * 0.5;
            const by = h - 44 - safe.top;
            const step1 = p.cartDocked;
            const step2 = p.room.key === "checkpoint" ? p.gateOpen : p.checkpoint >= p.room.arch.x1;
            const t1 = p.room.key === "checkpoint" ? "红布板车入窝" : "上层拉车让拱";
            const t2 = p.room.key === "checkpoint" ? "双人汇合出口" : "蹲伏穿拱赴塔";

            drawSilkVeil(uiDraw, uiArt, "hud_obj_veil", cx, by, 380, 34, PALETTE.inkWash, 0.58 * alpha, -1);

            const x1 = cx - 134;
            if (step1) {
                drawBlossomDot(uiInkDraw, uiArt, "obj_m1", x1, by, 11, PALETTE.emerald, 0.94 * alpha, 3);
            } else {
                uiArt.tryPlace("ink_enso_fine", "obj_m1", x1, by, 11, 11, { color: toColor(PALETTE.silkLine), opacity: 0.72 * alpha, layer: 3 });
            }
            texts.put("xs", t1, x1 + 13, by, toColor(step1 ? PALETTE.emerald : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.0, alpha, 0.08);

            const x2 = cx + 18;
            if (step2) {
                drawBlossomDot(uiInkDraw, uiArt, "obj_m2", x2, by, 11, PALETTE.emerald, 0.94 * alpha, 3);
            } else {
                uiArt.tryPlace("ink_enso_fine", "obj_m2", x2, by, 11, 11, { color: toColor(PALETTE.silkDim), opacity: 0.62 * alpha, layer: 3 });
            }
            texts.put("xs", t2, x2 + 13, by, toColor(step2 ? PALETTE.emerald : PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.0, alpha, 0.08);
        }
    }

    private drawWorldPrompts(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        texts: TextPool,
        prompts: WorldPrompt[],
        cam: CameraDirector,
        alpha: number,
        uiScale: number,
        safe: SafeInsets,
    ): void {
        const bob = Math.sin(this.time * 3.4) * 2.8;
        const viewW = cam.viewW / uiScale;
        const viewH = cam.viewH / uiScale;
        let i = 0;
        for (i = 0; i < prompts.length; i++) {
            const pr = prompts[i];
            const keyW = Math.max(24, visualTextWidth(pr.keyTag, 15) + 16);
            const labelW = visualTextWidth(pr.label, 15);
            const pillW = keyW + labelW + 24;
            const padX = Math.max(115, pillW * 0.5 + 24);
            const point = cam.worldToScreen(pr.x, pr.y);
            const sx = Math.max(padX + safe.left, Math.min(viewW - padX - safe.right, point.x / uiScale));
            const sy = Math.max(96 + safe.bottom, Math.min(viewH - 110 - safe.top, point.y / uiScale + bob));
            const accent = pr.urgent ? PALETTE.rouge : PALETTE.silkLine;

            uiInkDraw.drawSegment(Vec2(sx, sy - 14), Vec2(sx, sy - 27), 0.8, toColor(accent, 135 * alpha));
            drawBlossomDot(uiInkDraw, uiArt, "wp_anchor_" + i, sx, sy - 28, 7, accent, 0.85 * alpha, 3);

            const px = sx - pillW * 0.5;
            const py = sy - 12;

            drawSilkVeil(uiDraw, uiArt, "wp_bg_" + i, sx, py + 12, pillW + 40, 32, PALETTE.inkWash, 0.78 * alpha, 0);
            drawHairline(uiInkDraw, uiArt, "wp_line_" + i, sx, py + 24, pillW + 4, accent, 0.45 * alpha, false, 2);
            drawSilkKeycap(uiInkDraw, texts, px + 2, py + 2, keyW, 20, pr.keyTag, accent, alpha, pr.urgent);
            texts.put("xs", pr.label, px + keyW + 12, py + 12, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.8, alpha, 0.08);
        }
    }

    private drawReticle(
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        vfx: VfxSystem,
        uiScale: number,
        touchMode: boolean,
    ): void {
        const mx = p.aimX / uiScale;
        const my = p.aimY / uiScale;
        if (mx <= 0 && my <= 0) {
            return;
        }

        if (p.childMode) {
            const aiming = p.room.key === "village" && p.hasBottle;
            if (touchMode && (!aiming || p.aimHold <= 0)) {
                return;
            }
            const col = aiming ? PALETTE.amberCore : PALETTE.silkDim;
            uiInkDraw.drawDot(Vec2(mx, my), aiming ? 2.0 : 1.6, toColor(col, aiming ? 215 : 120));
            if (aiming) {
                const sz = p.aimHold > 0 ? 32 : 24;
                uiArt.tryPlace("ink_enso_fine", "reticle_child", mx, my, sz, sz, {
                    color: toColor(PALETTE.amberCore), opacity: 0.82, angle: this.time * 24, layer: 5,
                });
            }
            return;
        }

        const wAim = cam.screenToWorld(p.aimX, p.aimY);
        let onEnemy = false;
        let i = 0;
        for (i = 0; i < p.enemies.length; i++) {
            const e = p.enemies[i];
            const ey = e.y + (e.depth ?? 0) * DEPTH_Y_SCALE;
            if (e.alive && Math.abs(wAim.x - e.x) <= e.w * 0.85 && wAim.y >= ey - 6 && wAim.y <= ey + e.h + 6) {
                onEnemy = true;
            }
        }

        const col = onEnemy ? PALETTE.rouge : PALETTE.textBright;
        const gap = (onEnemy ? 5.5 : 7) + vfx.crosshairKick * 0.72;
        const arm = onEnemy ? 8.5 : 9.5;
        const bg = Color(10, 12, 18, 160);

        uiInkDraw.drawSegment(Vec2(mx - gap - arm, my), Vec2(mx - gap, my), 2.1, bg);
        uiInkDraw.drawSegment(Vec2(mx + gap, my), Vec2(mx + gap + arm, my), 2.1, bg);
        uiInkDraw.drawSegment(Vec2(mx, my - gap - arm), Vec2(mx, my - gap), 2.1, bg);
        uiInkDraw.drawSegment(Vec2(mx, my + gap), Vec2(mx, my + gap + arm), 2.1, bg);

        uiInkDraw.drawSegment(Vec2(mx - gap - arm, my), Vec2(mx - gap, my), 1.1, toColor(col, 230));
        uiInkDraw.drawSegment(Vec2(mx + gap, my), Vec2(mx + gap + arm, my), 1.1, toColor(col, 230));
        uiInkDraw.drawSegment(Vec2(mx, my - gap - arm), Vec2(mx, my - gap), 1.1, toColor(col, 230));
        uiInkDraw.drawSegment(Vec2(mx, my + gap), Vec2(mx, my + gap + arm), 1.1, toColor(col, 230));
        uiInkDraw.drawDot(Vec2(mx, my), 1.8, toColor(onEnemy ? PALETTE.crimsonCore : PALETTE.textBright, 240));

        if (onEnemy) {
            const sz = 30 + Math.sin(this.time * 11) * 1.8;
            uiArt.tryPlace("ink_enso_fine", "reticle_lock", mx, my, sz, sz, {
                color: toColor(PALETTE.rouge), opacity: 0.88, angle: this.time * 38, layer: 5,
            });
            fillRadialGlow(uiGlow, mx, my, 16, 16, toColor(PALETTE.rouge, 30), Color(182, 58, 56, 0), 10);
        }
    }
}
