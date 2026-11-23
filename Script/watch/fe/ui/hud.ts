/**
 * 《向西守望》极简中国水墨 HUD + 世界空间古纸墨签提示 + 枯笔准星。
 *
 * 设计准则：
 * - 去硬壳斜切，用柔和飞白墨刷与方正篆印托起关键信息，画面大面积留白给月下山城；
 * - 静音与灰度可读：实心墨格 vs 空心框体、空心墨环 vs 朱砂墨点，不依赖单一色相；
 * - 军人线：「戍」印 + 三枚玉简墨格体力条（带淡朱滞后褪墨）+ 掩体印签 + 小满三墨点惊惧；
 * - 孩子线：「满」印 + 轻盈潜行姿态短签，无血条杂讯；
 * - 右上角采用无盒轻题款（章印 + 章名 + Esc 暂歇）。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { FEAR_MAX } from "Script/watch/escort";
import { WorldPrompt, deriveWorldPrompts } from "Script/watch/fe/adapter";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { VfxSystem } from "Script/watch/fe/renderer/vfx";
import { TextPool } from "Script/watch/fe/ui/textpool";
import {
    PALETTE,
    drawBrushDivider,
    drawInkKeycap,
    drawInkWashStrip,
    drawSealStamp,
    fillRadialGlow,
    themeOf,
    toColor,
    visualTextWidth,
} from "Script/watch/fe/theme";

export class HudRenderer {
    /** 掉血滞后淡朱条数值 */
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
    ): void {
        const w = cam.viewW / uiScale;
        const h = cam.viewH / uiScale;

        // 电影遮幅全开（关门数数、尾声）时自动渐隐 HUD
        const hudAlpha = Math.max(0, 1 - letterboxFrac * 1.15);

        if (hudAlpha > 0.05) {
            // 1. 左上角：主角状态墨笺
            if (p.childMode) {
                this.drawChildStatus(uiDraw, uiInkDraw, uiArt, texts, p, h, hudAlpha);
            } else {
                this.drawSoldierStatus(uiDraw, uiInkDraw, uiArt, texts, p, h, hudAlpha);
            }

            // 2. 右上角：无盒水墨章节题款
            this.drawChapterBadge(uiDraw, uiInkDraw, uiArt, texts, p, w, h, hudAlpha);

            // 3. 顶部中央：情境进度墨带（城门守点 / 检查站与城外双目标）
            this.drawContextualObjective(uiDraw, uiInkDraw, uiArt, texts, p, w, h, hudAlpha);

            // 4. 世界空间悬浮纸签交互提示
            const prompts = deriveWorldPrompts(p);
            this.drawWorldPrompts(uiDraw, uiInkDraw, uiArt, texts, prompts, cam, hudAlpha, uiScale);

            // 5. 掩体挡枪浮字
            if (vfx.deflectFlash > 0.25) {
                const dx = cam.sx(vfx.deflectX) / uiScale;
                const dy = cam.sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 16;
                texts.put(
                    "sm",
                    "掩体挡下",
                    dx,
                    dy,
                    toColor(PALETTE.xuanPaper),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    1.6,
                    vfx.deflectFlash,
                );
            }
        }

        // 6. 枯笔准星（过场全开时不遮挡画面）
        if (!p.paused && letterboxFrac < 0.5) {
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
    ): void {
        const bx = 28;
        const by = h - 76;
        const lowHp = p.hp <= 1;

        // 柔和非对称墨晕底（无硬边框盒子）
        drawInkWashStrip(uiDraw, uiArt, "hud_soldier_bg", bx + 158, by + 26, 336, 58, PALETTE.inkWash, 0.78 * alpha, false, -1);

        // 左侧方印「戍」（危血转朱砂）
        drawSealStamp(
            uiInkDraw,
            uiArt,
            texts,
            "hud_soldier_seal",
            bx + 22,
            by + 27,
            30,
            "戍",
            lowHp ? PALETTE.sealRed : PALETTE.cyanDim,
            lowHp ? PALETTE.sealText : PALETTE.moonPale,
            alpha,
            true,
            4,
        );

        texts.put("xs", "周戍 · 体力", bx + 46, by + 39, toColor(PALETTE.xuanWarm), 0, 0.5, TextAlign.Left, 1.0, alpha);

        // 三枚手绘墨格体力条（空心框 + 淡朱滞后条 + 霜月/朱砂实心墨条）
        const segCount = Math.max(1, p.maxHp);
        const barX = bx + 46;
        const barY = by + 16;
        const segW = 54;
        const segH = 11;
        const gap = 8;

        let i = 0;
        for (i = 0; i < segCount; i++) {
            const sx = barX + i * (segW + gap);
            const scx = sx + segW * 0.5;
            // 空心框体（灰度下依然明确分辨空/满）
            if (!uiArt.tryPlace("ink_hp_slot", "hp_slot_" + i, scx, barY, segW + 4, segH + 6, {
                color: toColor(PALETTE.bronzeDim), opacity: 0.85 * alpha, layer: 1,
            })) {
                uiInkDraw.drawRect(Rect(sx, barY - segH * 0.5, segW, segH), Color(16, 17, 22, Math.round(180 * alpha)), 1.0, toColor(PALETTE.bronzeDim, 180 * alpha));
            }
            // 受击滞后淡朱条
            if (this.ghostHp > i && this.ghostHp > p.hp) {
                const frac = Math.min(1, this.ghostHp - i);
                uiInkDraw.drawRect(Rect(sx + 1, barY - segH * 0.42, (segW - 2) * frac, segH * 0.84), toColor(PALETTE.crimsonCore, 165 * alpha));
            }
            // 当前实心体力格
            if (p.hp > i) {
                const pulse = lowHp ? (0.72 + 0.28 * Math.sin(this.time * 7.5)) : 1;
                const fillCol = lowHp ? PALETTE.sealRedBright : PALETTE.cyanCore;
                if (!uiArt.tryPlace("ink_hp_bar", "hp_fill_" + i, scx, barY, segW + 2, segH + 4, {
                    color: toColor(fillCol), opacity: 0.94 * alpha * pulse, layer: 2,
                })) {
                    uiInkDraw.drawRect(Rect(sx + 1, barY - segH * 0.42, segW - 2, segH * 0.84), toColor(fillCol, 235 * alpha * pulse));
                }
            }
        }

        // 掩体印签（紧接体力条右侧）
        const covX = barX + segCount * (segW + gap) + 6;
        if (p.coverHug) {
            uiInkDraw.drawRect(Rect(covX, barY - 9, 56, 18), toColor(PALETTE.cyanDim, 215 * alpha), 1.0, toColor(PALETTE.cyanCore, 180 * alpha));
            texts.put("xs", "掩体中", covX + 28, barY, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 0.4, alpha, 0);
        } else if (p.coverNear) {
            uiInkDraw.drawRect(Rect(covX, barY - 9, 56, 18), Color(22, 19, 17, Math.round(195 * alpha)), 1.0, toColor(PALETTE.amber, 210 * alpha));
            texts.put("xs", "可贴靠", covX + 28, barY, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 0.4, alpha);
        }

        // 护送态：小满惊惧三墨点子栏（仅序章/街道/检查站显示）
        if (p.room.key === "prologue" || p.room.key === "street" || p.room.key === "checkpoint") {
            const subY = by - 28;
            const frozen = p.escort.state === "frozen";
            const calming = p.escort.state === "calming";

            drawInkWashStrip(
                uiDraw,
                uiArt,
                "hud_fear_bg",
                bx + 132,
                subY + 8,
                258,
                32,
                frozen ? PALETTE.inkWarm : PALETTE.inkWash,
                0.72 * alpha,
                false,
                -1,
            );
            texts.put("xs", "小满 · 惊惧", bx + 16, subY + 8, toColor(frozen ? PALETTE.crimsonCore : PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.8, alpha);

            let k = 0;
            for (k = 0; k < FEAR_MAX; k++) {
                const dx = bx + 114 + k * 21;
                const dy = subY + 8;
                const lit = k < p.escort.fear;
                const dc = frozen ? PALETTE.sealRedBright : PALETTE.amber;
                // 空心枯笔墨环作为槽底
                if (!uiArt.tryPlace("ink_ring", "fear_ring_" + k, dx, dy, 16, 16, {
                    color: toColor(lit ? dc : PALETTE.bronzeDim), opacity: (lit ? 0.92 : 0.65) * alpha, layer: 2,
                })) {
                    uiInkDraw.drawRing(Vec2(dx, dy), 5.5, 6.8, Color(0, 0, 0, 0), 1.1, toColor(dc, 180 * alpha));
                }
                // 满格墨滴点染
                if (lit) {
                    if (!uiArt.tryPlace("ink_dot", "fear_dot_" + k, dx, dy, 10, 10, {
                        color: toColor(dc), opacity: 0.96 * alpha, layer: 3,
                    })) {
                        uiInkDraw.drawDot(Vec2(dx, dy), 4.2, toColor(dc, 235 * alpha));
                    }
                }
            }

            if (frozen) {
                const pulse = 0.65 + 0.35 * Math.sin(this.time * 7.5);
                drawInkKeycap(uiInkDraw, texts, bx + 172, subY - 3, 22, 22, "E", PALETTE.sealRedBright, alpha * pulse, true);
                texts.put("xs", "轻敲安抚", bx + 199, subY + 8, toColor(PALETTE.crimsonCore), 0, 0.5, TextAlign.Left, 0.5, alpha * pulse);
            } else if (calming) {
                texts.put("xs", "轻敲安抚中", bx + 174, subY + 8, toColor(PALETTE.emerald), 0, 0.5, TextAlign.Left, 0.5, alpha);
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
    ): void {
        const bx = 28;
        const by = h - 72;
        const alert = p.scavChase || p.dogState === "chase" || p.dogState === "ear" || p.scavSee > 0;
        const sealCol = alert ? PALETTE.sealRed : (p.player.crouch ? PALETTE.emeraldDim : PALETTE.amberDim);
        const sealChar = alert ? "危" : "满";

        drawInkWashStrip(uiDraw, uiArt, "hud_child_bg", bx + 148, by + 24, 308, 52, alert ? PALETTE.inkWarm : PALETTE.inkWash, 0.76 * alpha, false, -1);
        drawSealStamp(uiInkDraw, uiArt, texts, "hud_child_seal", bx + 22, by + 24, 30, sealChar, sealCol, PALETTE.sealText, alpha, true, 4);

        texts.put("xs", "小满 · 潜行", bx + 46, by + 35, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 1.0, alpha);

        let posture = "轻步前行 · 保持隐蔽";
        let col = PALETTE.textMid;
        if (alert) {
            posture = p.scavChase || p.dogState === "chase" ? "已被发现 · 速寻隐蔽" : "引起警觉 · 停步蹲伏";
            col = PALETTE.crimsonCore;
        } else if (p.player.crouch) {
            posture = "低姿伏行 · 匿迹于影";
            col = PALETTE.emerald;
        } else if (p.hasBottle) {
            posture = "手持玻璃瓶 · 按住 [F] 瞄投";
            col = PALETTE.amberCore;
        }
        texts.put("xs", posture, bx + 46, by + 13, toColor(col), 0, 0.5, TextAlign.Left, 0.4, alpha);
    }

    private drawChapterBadge(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
        alpha: number,
    ): void {
        const theme = themeOf(p.room.key);
        const rx = w - 30;
        const cy = h - 46;

        // 极轻右上角淡墨烟，无硬框盒体，让夜空呼吸
        drawInkWashStrip(uiDraw, uiArt, "hud_chap_bg", rx - 94, cy, 246, 48, PALETTE.inkWash, 0.58 * alpha, true, -1);
        drawSealStamp(
            uiInkDraw,
            uiArt,
            texts,
            "hud_chap_seal",
            rx - 14,
            cy + 2,
            26,
            theme.numeralZh,
            p.room.key === "gate" ? PALETTE.sealRed : PALETTE.bronzeDim,
            PALETTE.sealText,
            0.9 * alpha,
            true,
            4,
        );
        texts.put("xs", theme.titleZh, rx - 34, cy + 9, toColor(PALETTE.textBright), 1, 0.5, TextAlign.Right, 0.8, alpha);
        texts.put("xs", "Esc 暂歇", rx - 34, cy - 11, toColor(PALETTE.textDim), 1, 0.5, TextAlign.Right, 0.6, 0.86 * alpha);
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
    ): void {
        // 1. 城门 45 秒死守：水墨朱砂进度带（去英文 GATE HOLD）
        if (p.room.key === "gate" && p.room.story !== undefined && p.room.story.gate !== undefined) {
            const g = p.room.story.gate;
            if (p.phase === "gate-hold" || p.phase === "gate-idle") {
                const bw = 420;
                const cx = w * 0.5;
                const by = h - 66;
                const ratio = Math.max(0, Math.min(1, p.gateTick / Math.max(1, g.holdTicks)));
                const secLeft = Math.max(0, (g.holdTicks - p.gateTick) / 60);
                const secStr = secLeft.toFixed(1);

                drawInkWashStrip(uiDraw, uiArt, "hud_gate_bg", cx, by + 18, bw + 60, 50, PALETTE.inkWash, 0.84 * alpha, true, -1);
                drawBrushDivider(uiInkDraw, uiArt, "hud_gate_top", cx, by + 39, bw - 30, 8, PALETTE.crimsonDeep, 0.58 * alpha, 2);

                const label = p.phase === "gate-idle"
                    ? (p.gateNeedConfirm ? "绞盘待命 · 按 [E] 重新守门" : "待小满就位 · 绞盘启")
                    : ("城门死守 · 余 " + secStr + " 秒");
                texts.put("xs", label, cx, by + 27, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.4, alpha);

                // 朱砂墨痕进度槽
                const pbx = cx - (bw - 72) * 0.5;
                const pbw = bw - 72;
                const pby = by + 9;
                uiInkDraw.drawRect(Rect(pbx, pby - 2.5, pbw, 5), Color(28, 22, 24, Math.round(210 * alpha)), 0.7, toColor(PALETTE.bronzeDim, 130 * alpha));
                if (ratio > 0.002) {
                    uiInkDraw.drawRect(Rect(pbx, pby - 2.5, pbw * ratio, 5), toColor(PALETTE.sealRedBright, 235 * alpha));
                    uiInkDraw.drawRect(Rect(pbx, pby + 0.5, pbw * ratio, 1.5), toColor(PALETTE.crimsonCore, 160 * alpha));
                }
                // 4 波敌兵节点圆钉（0 / 9 / 15 / 25 秒）
                const waves = [0, 540 / 2700, 900 / 2700, 1500 / 2700];
                let k = 0;
                for (k = 0; k < waves.length; k++) {
                    const wx = pbx + pbw * waves[k];
                    const passed = p.gateSpawned > k;
                    uiArt.tryPlace(passed ? "ink_dot" : "ink_ring", "gate_wave_" + k, wx, pby, passed ? 9 : 11, passed ? 9 : 11, {
                        color: toColor(passed ? PALETTE.amberCore : PALETTE.sealRedBright), opacity: 0.92 * alpha, layer: 3,
                    });
                }
            }
            return;
        }

        // 2. 检查站 / 城外：精简双节点墨签
        if (p.room.key === "checkpoint" || p.room.key === "outside") {
            const cx = w * 0.5;
            const by = h - 46;
            const step1 = p.cartDocked;
            const step2 = p.room.key === "checkpoint" ? p.gateOpen : p.checkpoint >= 380;
            const t1 = p.room.key === "checkpoint" ? "红布板车入窝" : "上层拉车让拱";
            const t2 = p.room.key === "checkpoint" ? "双人汇合出口" : "蹲伏穿拱赴塔";

            drawInkWashStrip(uiDraw, uiArt, "hud_obj_bg", cx, by, 356, 36, PALETTE.inkWash, 0.70 * alpha, true, -1);

            const x1 = cx - 134;
            uiArt.tryPlace(step1 ? "ink_dot" : "ink_ring", "obj_m1", x1, by, 12, 12, {
                color: toColor(step1 ? PALETTE.emerald : PALETTE.amber), opacity: 0.92 * alpha, layer: 3,
            });
            texts.put("xs", t1, x1 + 13, by, toColor(step1 ? PALETTE.emerald : PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.6, alpha);

            const x2 = cx + 18;
            uiArt.tryPlace(step2 ? "ink_dot" : "ink_ring", "obj_m2", x2, by, 12, 12, {
                color: toColor(step2 ? PALETTE.emerald : PALETTE.bronzeDim), opacity: 0.92 * alpha, layer: 3,
            });
            texts.put("xs", t2, x2 + 13, by, toColor(step2 ? PALETTE.emerald : PALETTE.textDim), 0, 0.5, TextAlign.Left, 0.6, alpha);
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
        const bob = Math.sin(this.time * 3.8) * 3.0;
        let i = 0;
        for (i = 0; i < prompts.length; i++) {
            const pr = prompts[i];
            const sx = Math.max(115, Math.min(cam.viewW / uiScale - 115, cam.sx(pr.x) / uiScale));
            const sy = Math.max(96, Math.min(cam.viewH / uiScale - 110, cam.sy(pr.y) / uiScale + bob));
            const accent = pr.urgent ? PALETTE.sealRedBright : PALETTE.amber;

            // 细垂墨丝与落点微墨点
            uiInkDraw.drawSegment(Vec2(sx, sy - 15), Vec2(sx, sy - 29), 1.0, toColor(accent, 160 * alpha));
            uiInkDraw.drawDot(Vec2(sx, sy - 29), 2.2, toColor(accent, 210 * alpha));

            // 古铜方印键帽 + 轻墨托底短签
            const keyW = Math.max(24, visualTextWidth(pr.keyTag, 14) + 14);
            const labelW = visualTextWidth(pr.label, 15);
            const pillW = keyW + labelW + 26;
            const px = sx - pillW * 0.5;
            const py = sy - 13;

            drawInkWashStrip(uiDraw, uiArt, "wp_bg_" + i, sx, py + 13, pillW + 24, 34, PALETTE.inkWash, 0.86 * alpha, true, 0);
            uiInkDraw.drawSegment(Vec2(px + 2, py + 26), Vec2(px + pillW - 2, py + 26), 0.8, toColor(accent, 115 * alpha));
            uiInkDraw.drawSegment(Vec2(px + 2, py), Vec2(px + pillW - 2, py), 0.8, toColor(accent, 115 * alpha));
            drawInkKeycap(uiInkDraw, texts, px + 3, py + 2, keyW, 22, pr.keyTag, accent, alpha, pr.urgent);
            texts.put("xs", pr.label, px + keyW + 12, py + 13, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.5, alpha);
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
            // 孩子线：非投瓶时极轻暖点；持瓶瞄准时展开枯笔古铜环
            const aiming = p.room.key === "village" && p.hasBottle;
            const col = aiming ? PALETTE.amber : PALETTE.bronzeDim;
            uiInkDraw.drawDot(Vec2(mx, my), aiming ? 2.2 : 1.8, toColor(col, aiming ? 225 : 135));
            if (aiming) {
                const sz = p.aimHold > 0 ? 34 : 26;
                if (!uiArt.tryPlace("ink_ring", "reticle_child", mx, my, sz, sz, {
                    color: toColor(PALETTE.amberCore), opacity: 0.86, angle: this.time * 28, layer: 5,
                })) {
                    uiInkDraw.drawRing(Vec2(mx, my), sz * 0.44, sz * 0.5, Color(0, 0, 0, 0), 1.2, toColor(PALETTE.amber, 200));
                }
            }
            return;
        }

        // 军人线：克制枯笔十字准星（悬停活敌收拢朱砂墨环，去科技蓝光）
        const wAim = cam.screenToWorld(p.aimX, p.aimY);
        let onEnemy = false;
        let i = 0;
        for (i = 0; i < p.enemies.length; i++) {
            const e = p.enemies[i];
            if (e.alive && Math.abs(wAim.x - e.x) <= e.w * 0.85 && wAim.y >= e.y - 6 && wAim.y <= e.y + e.h + 6) {
                onEnemy = true;
            }
        }

        const col = onEnemy ? PALETTE.sealRedBright : PALETTE.xuanPaper;
        const gap = (onEnemy ? 5.5 : 7) + vfx.crosshairKick * 0.75;
        const arm = onEnemy ? 8.5 : 9.5;

        // 细暗墨衬底防亮背景丢失 + 素宣/朱砂十字细臂
        const bg = Color(12, 13, 18, 170);
        uiInkDraw.drawSegment(Vec2(mx - gap - arm, my), Vec2(mx - gap, my), 2.4, bg);
        uiInkDraw.drawSegment(Vec2(mx + gap, my), Vec2(mx + gap + arm, my), 2.4, bg);
        uiInkDraw.drawSegment(Vec2(mx, my - gap - arm), Vec2(mx, my - gap), 2.4, bg);
        uiInkDraw.drawSegment(Vec2(mx, my + gap), Vec2(mx, my + gap + arm), 2.4, bg);

        uiInkDraw.drawSegment(Vec2(mx - gap - arm, my), Vec2(mx - gap, my), 1.3, toColor(col, 235));
        uiInkDraw.drawSegment(Vec2(mx + gap, my), Vec2(mx + gap + arm, my), 1.3, toColor(col, 235));
        uiInkDraw.drawSegment(Vec2(mx, my - gap - arm), Vec2(mx, my - gap), 1.3, toColor(col, 235));
        uiInkDraw.drawSegment(Vec2(mx, my + gap), Vec2(mx, my + gap + arm), 1.3, toColor(col, 235));
        uiInkDraw.drawDot(Vec2(mx, my), 2.0, toColor(onEnemy ? PALETTE.crimsonCore : PALETTE.xuanPaper, 245));

        if (onEnemy) {
            const sz = 32 + Math.sin(this.time * 12) * 2.0;
            uiArt.tryPlace("ink_ring", "reticle_lock", mx, my, sz, sz, {
                color: toColor(PALETTE.sealRedBright), opacity: 0.90, angle: this.time * 42, layer: 5,
            });
            fillRadialGlow(uiGlow, mx, my, 18, 18, toColor(PALETTE.cinnabar, 36), Color(168, 46, 40, 0), 10);
        }
    }
}
