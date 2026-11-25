/**
 * 《向西守望》宋明清雅极简 HUD（V2 · 隐入画境、轻盈通透）：
 * - 取消所有方印与粗重灰块，以霜月细丝、竹叶玉簪体力痕、菱花惊惧点轻托信息；
 * - 静音与灰度可读：实心月白竹叶 vs 极细空心线、空心墨环 vs 绽放菱花点；
 * - 世界空间交互提示接入单点就近推导（deriveWorldPrompt），走到可触发处才浮现水墨纸签；
 * - 右上角仅留清瘦宋体章题与淡字「Esc 暂歇」，彻底释放冷月夜空。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { FEAR_MAX } from "Script/watch/escort";
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

    reset(p?: Play): void {
        this.ghostHp = p !== undefined ? p.hp : 3;
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
    ): void {
        const w = cam.viewW / uiScale;
        const h = cam.viewH / uiScale;

        const hudAlpha = Math.max(0, 1 - letterboxFrac * 1.15);

        if (hudAlpha > 0.05) {
            if (p.childMode) {
                this.drawChildStatus(uiDraw, uiInkDraw, uiArt, texts, p, h, hudAlpha, assistHintsEnabled);
            } else {
                this.drawSoldierStatus(uiDraw, uiInkDraw, uiArt, texts, p, h, hudAlpha, assistHintsEnabled);
            }

            this.drawChapterBadge(uiDraw, uiArt, texts, p, w, h, hudAlpha);
            this.drawContextualObjective(uiDraw, uiInkDraw, uiArt, texts, p, w, h, hudAlpha, assistHintsEnabled);

            if (assistHintsEnabled) {
                const prompt = deriveWorldPrompt(p);
                if (prompt !== undefined) {
                    this.drawWorldPrompts(uiDraw, uiInkDraw, uiArt, texts, [prompt], cam, hudAlpha, uiScale);
                }
            }

            if (vfx.deflectFlash > 0.25) {
                const dx = cam.sx(vfx.deflectX) / uiScale;
                const dy = cam.sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16;
                texts.put("sm", "掩体挡下", dx, dy, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 2.0, vfx.deflectFlash, 0.10);
            }
        }

        if (!suppressReticle) {
            this.drawReticleOverlay(uiInkDraw, uiArt, uiGlow, p, cam, vfx, letterboxFrac, uiScale);
        }
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
    ): void {
        if (!p.paused && letterboxFrac < 0.5 && !p.gripping &&
            p.escort.state !== "calming" && !p.gateNeedConfirm && p.phase !== "prologue-give") {
            this.drawReticle(uiInkDraw, uiArt, uiGlow, p, cam, vfx, uiScale);
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
    ): void {
        const bx = 28;
        const by = h - 72;
        const lowHp = p.hp <= 1;

        // 极轻鸦青烟雾托底（隐入夜空，无方块感）
        drawSilkVeil(uiDraw, uiArt, "hud_soldier_veil", bx + 150, by + 24, 340, 56, PALETTE.inkWash, 0.62 * alpha, -1);

        // 清瘦宋体「戍」+ 一根纤细竖玉丝（彻底告别红/灰大印块）
        texts.put("md", "戍", bx + 16, by + 25, toColor(lowHp ? PALETTE.rouge : PALETTE.cyanCore), 0.5, 0.5, TextAlign.Center, 0, alpha, 0.10);
        uiInkDraw.drawSegment(Vec2(bx + 32, by + 9), Vec2(bx + 32, by + 40), 0.8, toColor(PALETTE.silkDim, 130 * alpha));

        texts.put("xs", "周戍 · 体力", bx + 44, by + 36, toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.4, alpha, 0.08);

        // 三枚纤细玉簪/竹叶式体力细痕（实心月白 vs 极细空心线，危血转暗胭脂）
        const segCount = Math.max(1, p.maxHp);
        const barX = bx + 44;
        const barY = by + 16;
        const segW = 54;
        const segH = 9;
        const gap = 8;

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

        // 掩体极简微标（对齐 D7 掩体三态：有来敌且背向火力时提示「背向掩体」）
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
        } else if (p.coverNear) {
            uiInkDraw.drawRect(Rect(covX, barY - 9, 54, 18), Color(14, 17, 25, Math.round(150 * alpha)), 0.8, toColor(PALETTE.silkLine, 165 * alpha));
            texts.put("xs", "可贴靠", covX + 27, barY, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 0.6, alpha, 0.08);
        }

        // 护送态：小满惊惧三点菱花环（仅序章/街道/检查站）
        if (p.room.key === "prologue" || p.room.key === "street" || p.room.key === "checkpoint") {
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
                    drawSilkKeycap(uiInkDraw, texts, bx + 170, subY - 5, 22, 22, "E", PALETTE.rouge, alpha * pulse, true);
                    texts.put("xs", "轻敲安抚", bx + 198, subY + 6, toColor(PALETTE.crimsonCore), 0, 0.5, TextAlign.Left, 0.8, alpha * pulse, 0.08);
                } else {
                    texts.put("xs", "受惊停步", bx + 172, subY + 6, toColor(PALETTE.crimsonCore), 0, 0.5, TextAlign.Left, 0.8, alpha * pulse, 0.08);
                }
            } else if (calming) {
                texts.put("xs", "轻敲安抚中", bx + 172, subY + 6, toColor(PALETTE.emerald), 0, 0.5, TextAlign.Left, 0.8, alpha, 0.08);
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
    ): void {
        const bx = 28;
        const by = h - 68;
        const alert = p.scavChase || p.dogState === "chase" || p.dogState === "ear" || p.scavSee > 0;
        const leadCol = alert ? PALETTE.rouge : (p.player.crouch ? PALETTE.emerald : PALETTE.amberCore);

        drawSilkVeil(uiDraw, uiArt, "hud_child_veil", bx + 144, by + 22, 316, 48, alert ? PALETTE.inkWarm : PALETTE.inkWash, 0.58 * alpha, -1);
        texts.put("md", alert ? "危" : "满", bx + 16, by + 22, toColor(leadCol), 0.5, 0.5, TextAlign.Center, 0, alpha, 0.10);
        uiInkDraw.drawSegment(Vec2(bx + 32, by + 7), Vec2(bx + 32, by + 37), 0.8, toColor(PALETTE.silkDim, 130 * alpha));

        texts.put("xs", "小满 · 潜行", bx + 44, by + 33, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 1.4, alpha, 0.08);

        let posture = "轻步前行 · 保持隐蔽";
        let col = PALETTE.textMid;
        if (alert) {
            posture = p.scavChase || p.dogState === "chase" ? "已被发现 · 速寻隐蔽" : "引起警觉 · 停步蹲伏";
            col = PALETTE.crimsonCore;
        } else if (p.player.crouch) {
            posture = "低姿伏行 · 匿迹于影";
            col = PALETTE.emerald;
        } else if (p.hasBottle) {
            posture = assistHintsEnabled ? "手持陶瓶 · 按住 [F] 瞄投" : "手持陶瓶";
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
    ): void {
        const theme = themeOf(p.room.key);
        const rx = w - 32;
        const cy = h - 44;

        drawSilkVeil(uiDraw, uiArt, "hud_chap_veil", rx - 82, cy, 240, 44, PALETTE.inkWash, 0.44 * alpha, -1);
        texts.put("xs", theme.numeralZh + " · " + theme.titleZh, rx, cy + 9, toColor(PALETTE.textBright), 1, 0.5, TextAlign.Right, 1.2, alpha, 0.08);
        texts.put("xs", "Esc 暂歇", rx, cy - 11, toColor(PALETTE.textDim), 1, 0.5, TextAlign.Right, 1.0, 0.78 * alpha, 0.08);
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
    ): void {
        // 0. 慢时换弹：作答钟 4 秒、世界 1/4 速；3×3 盘已走过的点逐颗点亮。
        // 第三段工台：材料、两张配方与当前装备；面板期间世界冻结。
        if (p.craftBench.active) {
            const bw = 470;
            const cx = w * 0.5;
            const top = h * 0.32;
            drawSilkVeil(uiDraw, uiArt, "hud_bench_veil", cx, top + 118, bw + 64, 208, PALETTE.inkWash, 0.86 * alpha, -1);
            texts.put("xs", "工台 · 放她下来做一件", cx, top - 6, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.7, alpha, 0.08);
            const inv = p.craftBench.inventory;
            const wood = inv["wood"] ?? 0;
            const bell = inv["bell"] ?? 0;
            const scrap = inv["scrap"] ?? 0;
            texts.put("xs", "木纹筹 " + wood + " · 铃纹筹 " + bell + " · 碎片 " + scrap, cx, top + 24,
                toColor(PALETTE.silkDim), 0.5, 0.5, TextAlign.Center, 1.5, alpha, 0.08);
            const recipes = p.craftBench.recipes;
            for (let i = 0; i < recipes.length; i++) {
                const r = recipes[i];
                let costText = "";
                let afford = true;
                const costWood = r.cost["wood"] ?? 0;
                const costBell = r.cost["bell"] ?? 0;
                if (costWood > 0) {
                    costText = costText + (costText !== "" ? " + " : "") + "木 " + costWood;
                    if (wood < costWood) {
                        afford = false;
                    }
                }
                if (costBell > 0) {
                    costText = costText + (costText !== "" ? " + " : "") + "铃 " + costBell;
                    if (bell < costBell) {
                        afford = false;
                    }
                }
                const equipped = p.craftBench.equippedWeapon === r.id;
                const state = r.crafted ? "已做成" : (afford ? "可制作" : "缺料");
                const mark = equipped ? " ◈" : "";
                texts.put("xs", r.name + " · " + costText + " · " + state + mark, cx, top + 56 + i * 26,
                    toColor(equipped ? PALETTE.cyanCore : (r.crafted ? PALETTE.silkDim : PALETTE.textBright)),
                    0.5, 0.5, TextAlign.Center, 1.6, alpha, 0.08);
            }
            const firstMade = p.craftBench.firstCraftDone ? " · 首制完成" : "";
            texts.put("xs", "E 制作 · Q 装备 · Esc 离开" + firstMade, cx, top + 128,
                toColor(PALETTE.amber), 0.5, 0.5, TextAlign.Center, 1.5, alpha, 0.06);
        }

        if (p.reloadOpen) {
            const bw = 400;
            const cx = w * 0.5;
            const by = h - 64;
            const ratio = Math.max(0, Math.min(1, p.reloadAnswerTicks / 240));
            const effect = p.reloadPendingEffect;
            const label = effect !== ""
                ? "枪机复位 · " + (effect === "push" ? "推退" : (effect === "echo" ? "回声引声源" : "照明照遮蔽"))
                : "连线换弹 · " + Math.min(9, p.reloadPath.length) + " / 9";
            drawSilkVeil(uiDraw, uiArt, "hud_reload_veil", cx, by + 18, bw + 90, 48, PALETTE.inkWash, 0.76 * alpha, -1);
            drawHairline(uiInkDraw, uiArt, "hud_reload_top", cx, by + 39, bw - 20, PALETTE.cyan, 0.55 * alpha, false, 2);
            texts.put("xs", label, cx, by + 26, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.8, alpha, 0.08);

            // 9 颗节点：走过的路径点亮，终点 8 常亮为主。
            for (let n = 0; n < 9; n++) {
                const col = n % 3;
                const row = Math.floor(n / 3);
                const nx = cx + (col - 1) * 13;
                const ny = by + 50 + row * 12;
                const inPath = p.reloadPath.indexOf(n) >= 0;
                const isEnd = n === 8;
                uiArt.tryPlace("ink_enso_fine", "reload_node_" + n, nx, ny, isEnd ? 10 : 6, isEnd ? 10 : 6, {
                    color: toColor(isEnd ? PALETTE.cyanCore : (inPath ? PALETTE.amber : PALETTE.silkDim)),
                    opacity: (isEnd || inPath ? 0.92 : 0.4) * alpha, layer: 3,
                });
            }

            const pbw = bw - 80;
            const pbx = cx - pbw * 0.5;
            const pby = by + 9;
            uiInkDraw.drawSegment(Vec2(pbx, pby), Vec2(pbx + pbw, pby), 1.4, toColor(PALETTE.silkDim, 115 * alpha));
            if (ratio > 0.002) {
                uiInkDraw.drawSegment(Vec2(pbx, pby), Vec2(pbx + pbw * ratio, pby), 2.8, toColor(PALETTE.cyan, 220 * alpha));
                uiInkDraw.drawSegment(Vec2(pbx, pby), Vec2(pbx + pbw * ratio, pby), 1.0, toColor(PALETTE.cyanCore, 160 * alpha));
            }
        }

        // 1. 城门 45 秒死守：细丝胭脂进度带
        if (p.room.key === "gate" && p.room.story !== undefined && p.room.story.gate !== undefined) {
            const g = p.room.story.gate;
            if (p.phase === "gate-wait" || p.phase === "gate-hand") {
                // 风台待机：不再倒计时，只画长按牵手的有效拍进度；松手即回落。
                const bw = 400;
                const cx = w * 0.5;
                const by = h - 64;
                const tied = p.phase === "gate-hand";
                const ratio = tied ? 1 : Math.max(0, Math.min(1, p.handTicks / Math.max(1, p.handNeedTicks)));
                const label = tied ? "我们走吧。"
                    : (p.handTicks > 0 ? "牵起小满 · " + p.handTicks + " / " + p.handNeedTicks
                        : (p.handArmed ? "按住 E · 把手伸给她" : "松开 E 再按住 · 把手伸给她"));

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
                // 两下轻叩的落点：数完第 1 拍与第 12 拍各一颗。
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
                const by = h - 64;
                const ratio = Math.max(0, Math.min(1, p.gateTick / Math.max(1, g.holdTicks)));
                const secLeft = Math.max(0, (g.holdTicks - p.gateTick) / 60);
                const secStr = secLeft.toFixed(1);

                drawSilkVeil(uiDraw, uiArt, "hud_gate_veil", cx, by + 18, bw + 90, 48, PALETTE.inkWash, 0.76 * alpha, -1);
                drawHairline(uiInkDraw, uiArt, "hud_gate_top", cx, by + 39, bw - 20, PALETTE.rougeSoft, 0.55 * alpha, false, 2);

                const idleNeedConfirmLabel = assistHintsEnabled ? "绞盘待命 · 按 [E] 重新守门" : "绞盘待命";
                const label = p.phase === "gate-idle"
                    ? (p.gateNeedConfirm ? idleNeedConfirmLabel : "待小满就位 · 绞盘启")
                    : ("城门死守 · 余 " + secStr + " 秒");
                texts.put("xs", label, cx, by + 26, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.8, alpha, 0.08);

                // 3px 纤细胭脂进丝 + 四波菱花微珠
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

        // 2. 检查站 / 城外：文字目标清单默认关闭，仅在玩家开启「按键辅助」时显示
        if (!assistHintsEnabled) {
            return;
        }
        if (p.room.key === "checkpoint" || p.room.key === "outside") {
            const cx = w * 0.5;
            const by = h - 44;
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
            const sx = Math.max(padX, Math.min(viewW - padX, cam.sx(pr.x) / uiScale));
            const sy = Math.max(96, Math.min(viewH - 110, cam.sy(pr.y) / uiScale + bob));
            const accent = pr.urgent ? PALETTE.rouge : PALETTE.silkLine;

            // 细垂霜丝与微花点
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
    ): void {
        const mx = p.aimX / uiScale;
        const my = p.aimY / uiScale;
        if (mx <= 0 && my <= 0) {
            return;
        }

        if (p.childMode) {
            const aiming = p.room.key === "village" && p.hasBottle;
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
            if (e.alive && Math.abs(wAim.x - e.x) <= e.w * 0.85 && wAim.y >= e.y - 6 && wAim.y <= e.y + e.h + 6) {
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
