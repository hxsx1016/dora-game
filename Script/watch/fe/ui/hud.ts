/**
 * 艾希（ICEY）极简科幻斜切 HUD + 世界空间内嵌按键提示 + 响应型战术准星。
 *
 * 设计准则：
 * - 零调试坐标杂讯，画面 90%+ 留白给电影级舞台；
 * - 军人线：冷冰青斜切 3 格装甲血条（带白条滞后缓降）+ 掩体锁止指示 + 小满 3 晶格恐惧波形；
 * - 孩子线：暖琥珀潜行标识，无血条、无准星杂乱，强化脆弱潜行张力；
 * - 顶部中央进度条按需展开（城门 45 秒守点 4 波次进度 / 检查站与城外双锁目标）；
 * - 世界空间在可交互物正上方弹出斜切菱形按键标（[E] / [SHIFT] / [F] / [CTRL]）。
 */

import { Color, DrawNode, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { FEAR_MAX } from "Script/watch/escort";
import { WorldPrompt, deriveWorldPrompts } from "Script/watch/fe/adapter";
import { CameraDirector } from "Script/watch/fe/camera";
import { VfxSystem } from "Script/watch/fe/renderer/vfx";
import { TextPool } from "Script/watch/fe/ui/textpool";
import {
    PALETTE,
    drawDiamond,
    fillRadialGlow,
    fillSkewRect,
    themeOf,
    toColor,
    visualTextWidth,
} from "Script/watch/fe/theme";

export class HudRenderer {
    /** 掉血滞后白条数值 */
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

        // 电影遮幅全开（如关门数数、尾声）时自动渐隐 HUD，让画面彻底聚焦演出
        const hudAlpha = Math.max(0, 1 - letterboxFrac * 1.15);

        if (hudAlpha > 0.05) {
            // 1. 左上角：主角状态模块
            if (p.childMode) {
                this.drawChildStatus(uiDraw, uiGlow, texts, p, h, hudAlpha);
            } else {
                this.drawSoldierStatus(uiDraw, uiGlow, texts, p, h, hudAlpha);
            }

            // 2. 右上角：当前章节编号与系统入口
            this.drawChapterBadge(uiDraw, uiGlow, texts, p, w, h, hudAlpha);

            // 3. 顶部中央：情境同步条（城门 45 秒守点 / 检查站双锁 / 城外双锁）
            this.drawContextualObjective(uiDraw, uiGlow, texts, p, w, h, hudAlpha);

            // 4. 世界空间悬浮按键提示
            const prompts = deriveWorldPrompts(p);
            this.drawWorldPrompts(uiDraw, uiGlow, texts, prompts, cam, hudAlpha, uiScale);

            // 5. 掩体精准挡枪 DEFLECT 浮标
            if (vfx.deflectFlash > 0.25) {
                const dx = cam.sx(vfx.deflectX) / uiScale;
                const dy = cam.sy(vfx.deflectY) / uiScale + 34 + (1 - vfx.deflectFlash) * 18;
                texts.put(
                    "sm",
                    "掩体挡下",
                    dx,
                    dy,
                    toColor(PALETTE.cyanCore),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    1.2,
                    vfx.deflectFlash,
                );
            }
        }

        // 6. 艾希战术准星（暂停或纯过场时不遮挡菜单）
        if (!p.paused && letterboxFrac < 0.5) {
            this.drawReticle(uiDraw, uiGlow, p, cam, vfx, uiScale);
        }
    }

    private drawSoldierStatus(
        uiDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        p: Play,
        h: number,
        alpha: number,
    ): void {
        const bx = 34;
        const by = h - 78;
        const panelW = 286;
        const panelH = 50;

        // 斜切深色战术底板 + 左侧冰青能量竖边
        fillSkewRect(uiDraw, bx, by, panelW, panelH, 14, toColor(PALETTE.panelBg, 210 * alpha), 1.1, toColor(PALETTE.cyanDim, 165 * alpha));
        fillSkewRect(uiGlow, bx - 4, by, 5, panelH, 14, toColor(PALETTE.cyan, 235 * alpha));

        texts.put("xs", "周戍 · 体力", bx + 18, by + panelH - 12, toColor(PALETTE.cyanCore), 0, 0.5, TextAlign.Left, 1.0, alpha);

        // 3 格斜切装甲血条（带掉血白条缓降）
        const segCount = Math.max(1, p.maxHp);
        const barX = bx + 16;
        const barY = by + 11;
        const barW = 192;
        const barH = 12;
        const gap = 6;
        const segW = (barW - gap * (segCount - 1)) / segCount;

        let i = 0;
        for (i = 0; i < segCount; i++) {
            const sx = barX + i * (segW + gap);
            // 槽底
            fillSkewRect(uiDraw, sx, barY, segW, barH, 6, Color(16, 26, 40, Math.round(220 * alpha)), 1, toColor(PALETTE.steelLight, 140 * alpha));
            // 滞后白条
            if (this.ghostHp > i) {
                const gw = segW * Math.min(1, this.ghostHp - i);
                fillSkewRect(uiDraw, sx, barY, gw, barH, 6, Color(235, 244, 255, Math.round(180 * alpha)));
            }
            // 当前血量条
            if (p.hp > i) {
                const hpCol = p.hp === 1 ? PALETTE.crimson : PALETTE.cyan;
                fillSkewRect(uiDraw, sx, barY, segW, barH, 6, toColor(hpCol, 240 * alpha));
                fillSkewRect(uiGlow, sx, barY + barH - 3, segW, 3, 2, toColor(PALETTE.cyanCore, 150 * alpha));
            }
        }

        // 掩体状态微标
        const covX = barX + barW + 16;
        if (p.coverHug) {
            fillSkewRect(uiGlow, covX, barY - 2, 58, 16, 6, toColor(PALETTE.cyan, 195 * alpha));
            texts.put("xs", "掩体中", covX + 31, barY + 6, Color(6, 12, 20, 255), 0.5, 0.5, TextAlign.Center, 0, alpha);
        } else if (p.coverNear) {
            fillSkewRect(uiDraw, covX, barY - 2, 58, 16, 6, Color(42, 34, 18, Math.round(200 * alpha)), 1.1, toColor(PALETTE.amber, 215 * alpha));
            texts.put("xs", "可贴靠", covX + 31, barY + 6, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 0, alpha);
        }

        // 护送态：小满情绪/恐惧波形子面板（仅序章/街道/检查站显示）
        if (p.room.key === "prologue" || p.room.key === "street" || p.room.key === "checkpoint") {
            const subY = by - 36;
            const frozen = p.escort.state === "frozen";
            const calming = p.escort.state === "calming";
            const borderCol = frozen ? PALETTE.crimson : PALETTE.amberDim;
            fillSkewRect(uiDraw, bx + 6, subY, 212, 28, 9, toColor(PALETTE.panelBg, 195 * alpha), 1.0, toColor(borderCol, 180 * alpha));
            fillSkewRect(uiGlow, bx + 3, subY, 3, 28, 9, toColor(frozen ? PALETTE.crimson : PALETTE.amber, 220 * alpha));
            texts.put("xs", "小满 · 恐惧", bx + 18, subY + 14, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 0.5, alpha);

            let k = 0;
            for (k = 0; k < FEAR_MAX; k++) {
                const dx = bx + 116 + k * 20;
                const dy = subY + 14;
                const lit = k < p.escort.fear;
                const dc = frozen ? PALETTE.crimson : PALETTE.amber;
                drawDiamond(
                    lit ? uiGlow : uiDraw,
                    dx,
                    dy,
                    6.5,
                    7.5,
                    lit ? toColor(dc, 235 * alpha) : Color(24, 34, 48, Math.round(180 * alpha)),
                    1.1,
                    toColor(dc, (lit ? 255 : 120) * alpha),
                );
            }
            if (frozen) {
                const pulse = 0.65 + 0.35 * Math.sin(this.time * 9);
                texts.put("xs", "[E]安抚", bx + 172, subY + 14, toColor(PALETTE.crimsonCore), 0, 0.5, TextAlign.Left, 0, alpha * pulse);
            } else if (calming) {
                texts.put("xs", "安抚中", bx + 172, subY + 14, toColor(PALETTE.cyanCore), 0, 0.5, TextAlign.Left, 0, alpha);
            }
        }
    }

    private drawChildStatus(
        uiDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        p: Play,
        h: number,
        alpha: number,
    ): void {
        const bx = 34;
        const by = h - 72;
        const alert = p.scavChase || p.dogState === "chase" || p.dogState === "ear" || p.scavSee > 0;
        const accent = alert ? PALETTE.crimson : (p.player.crouch ? PALETTE.emerald : PALETTE.amber);

        fillSkewRect(uiDraw, bx, by, 246, 44, 12, toColor(PALETTE.panelBg, 205 * alpha), 1.1, toColor(accent, 175 * alpha));
        fillSkewRect(uiGlow, bx - 4, by, 5, 44, 12, toColor(accent, 235 * alpha));

        texts.put("xs", "小满 · 潜行", bx + 18, by + 31, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 1.0, alpha);

        let posture = "轻步前行 · 保持隐蔽";
        if (alert) {
            posture = p.scavChase || p.dogState === "chase" ? "已被发现 · 速隐蔽！" : "引起警觉 · 停步蹲伏";
        } else if (p.player.crouch) {
            posture = "低姿潜行 · 隐蔽中";
        } else if (p.hasBottle) {
            posture = "手持玻璃瓶 · 按住 [F] 瞄投";
        }
        texts.put("xs", posture, bx + 18, by + 12, toColor(alert ? PALETTE.crimsonCore : PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.3, alpha);
    }

    private drawChapterBadge(
        uiDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
        alpha: number,
    ): void {
        const theme = themeOf(p.room.key);
        const bw = 248;
        const bh = 44;
        const bx = w - bw - 34;
        const by = h - 72;

        fillSkewRect(uiDraw, bx, by, bw, bh, -12, toColor(PALETTE.panelBg, 195 * alpha), 1.0, toColor(PALETTE.steelLight, 140 * alpha));
        fillSkewRect(uiGlow, bx + bw - 2, by, 4, bh, -12, toColor(theme.accent, 220 * alpha));

        texts.put("xs", theme.titleZh, bx + bw - 18, by + 30, toColor(PALETTE.textBright), 1, 0.5, TextAlign.Right, 0.6, alpha);
        texts.put("xs", "[Esc] 暂停", bx + bw - 18, by + 12, toColor(PALETTE.textDim), 1, 0.5, TextAlign.Right, 0.4, alpha);
    }

    private drawContextualObjective(
        uiDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
        alpha: number,
    ): void {
        // 1. 城门 45 秒守点：艾希风 Boss/守点顶栏同步条
        if (p.room.key === "gate" && p.room.story !== undefined && p.room.story.gate !== undefined) {
            const g = p.room.story.gate;
            if (p.phase === "gate-hold" || p.phase === "gate-idle") {
                const bw = 420;
                const bx = (w - bw) * 0.5;
                const by = h - 66;
                const ratio = Math.max(0, Math.min(1, p.gateTick / Math.max(1, g.holdTicks)));
                const secLeft = Math.max(0, (g.holdTicks - p.gateTick) / 60);
                const secStr = secLeft.toFixed(1) + "s";

                fillSkewRect(uiDraw, bx, by, bw, 36, 10, toColor(PALETTE.panelBgDeep, 220 * alpha), 1.1, toColor(PALETTE.crimson, 185 * alpha));
                const label = p.phase === "gate-idle"
                    ? (p.gateNeedConfirm ? "绞盘待命 · 按 [E] 重新守点" : "等待两人就位 · 绞盘启动")
                    : ("城门守点  //  GATE HOLD    " + secStr);
                texts.put("xs", label, w * 0.5, by + 26, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.0, alpha);

                // 进度槽
                const pbx = bx + 20;
                const pbw = bw - 40;
                const pby = by + 7;
                fillSkewRect(uiDraw, pbx, pby, pbw, 7, 4, Color(24, 18, 28, Math.round(220 * alpha)));
                if (ratio > 0.002) {
                    fillSkewRect(uiGlow, pbx, pby, pbw * ratio, 7, 4, toColor(PALETTE.crimson, 235 * alpha));
                    fillSkewRect(uiGlow, pbx, pby + 4, pbw * ratio, 3, 2, toColor(PALETTE.crimsonCore, 160 * alpha));
                }
                // 4 波敌兵节点菱标（0 / 9 / 15 / 25 秒）
                const waves = [0, 540 / 2700, 900 / 2700, 1500 / 2700];
                let k = 0;
                for (k = 0; k < waves.length; k++) {
                    const wx = pbx + pbw * waves[k];
                    const passed = p.gateSpawned > k;
                    drawDiamond(uiGlow, wx, pby + 3.5, 4, 5, toColor(passed ? PALETTE.cyanCore : PALETTE.crimson, 230 * alpha));
                }
            }
            return;
        }

        // 2. 检查站 / 城外：精简双节点任务态
        if (p.room.key === "checkpoint" || p.room.key === "outside") {
            const bw = 320;
            const bx = (w - bw) * 0.5;
            const by = h - 56;
            const step1 = p.cartDocked;
            const step2 = p.room.key === "checkpoint" ? p.gateOpen : p.checkpoint >= 380;
            const t1 = p.room.key === "checkpoint" ? "红布板车入窝" : "上层拉车让拱";
            const t2 = p.room.key === "checkpoint" ? "双人汇合出口" : "蹲伏穿拱赴塔";

            fillSkewRect(uiDraw, bx, by, bw, 28, 8, toColor(PALETTE.panelBg, 185 * alpha), 1.0, toColor(PALETTE.steelLight, 130 * alpha));
            drawDiamond(uiGlow, bx + 24, by + 14, 5, 5, toColor(step1 ? PALETTE.emerald : PALETTE.amber, 230 * alpha));
            texts.put("xs", t1, bx + 36, by + 14, toColor(step1 ? PALETTE.emerald : PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.4, alpha);

            drawDiamond(uiGlow, bx + 178, by + 14, 5, 5, toColor(step2 ? PALETTE.emerald : PALETTE.textDim, 230 * alpha));
            texts.put("xs", t2, bx + 190, by + 14, toColor(step2 ? PALETTE.emerald : PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.4, alpha);
        }
    }

    private drawWorldPrompts(
        uiDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        prompts: WorldPrompt[],
        cam: CameraDirector,
        alpha: number,
        uiScale: number,
    ): void {
        const bob = Math.sin(this.time * 4.5) * 3.5;
        let i = 0;
        for (i = 0; i < prompts.length; i++) {
            const pr = prompts[i];
            const sx = Math.max(110, Math.min(cam.viewW / uiScale - 110, cam.sx(pr.x) / uiScale));
            const sy = Math.max(96, Math.min(cam.viewH / uiScale - 110, cam.sy(pr.y) / uiScale + bob));
            const col = pr.urgent ? PALETTE.cyan : PALETTE.amber;

            // 细长引导线连向目标
            uiGlow.drawSegment(Vec2(sx, sy - 16), Vec2(sx, sy - 30), 1.2, toColor(col, 165 * alpha));
            uiGlow.drawDot(Vec2(sx, sy - 30), 2.5, toColor(col, 220 * alpha));

            // 艾希风菱形/斜切键帽 + 精确按视觉字宽贴合的文案胶囊
            const keyW = Math.max(26, visualTextWidth(pr.keyTag, 14) + 16);
            const labelW = visualTextWidth(pr.label, 14);
            const pillW = keyW + labelW + 26;
            const px = sx - pillW * 0.5;
            const py = sy - 14;

            fillSkewRect(uiDraw, px, py, pillW, 26, 7, toColor(PALETTE.panelBgDeep, 228 * alpha), 1.1, toColor(col, 215 * alpha));
            fillSkewRect(uiGlow, px + 2, py + 2, keyW, 22, 6, toColor(col, 232 * alpha));
            texts.put("xs", pr.keyTag, px + 2 + keyW * 0.5 + 3, py + 13, Color(6, 11, 18, 255), 0.5, 0.5, TextAlign.Center, 0.4, alpha);
            texts.put("xs", pr.label, px + keyW + 14, py + 13, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.4, alpha);
        }
    }

    private drawReticle(
        uiDraw: DrawNode.Type,
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
            // 孩子线：非投瓶时极简微光点；持瓶瞄准时展开柔和测距环
            const aiming = p.room.key === "village" && p.hasBottle;
            const r = aiming ? (p.aimHold > 0 ? 15 : 11) : 4;
            const col = aiming ? PALETTE.emerald : PALETTE.amber;
            uiGlow.drawDot(Vec2(mx, my), 2.2, toColor(col, 220));
            if (aiming) {
                uiGlow.drawRing(Vec2(mx, my), r - 1.5, r, Color(0, 0, 0, 0), 1.4, toColor(col, 210));
            }
            return;
        }

        // 军人线：艾希风响应型战术十字准星（悬停活敌变绯红锁标 + 开枪后坐力外扩）
        const wAim = cam.screenToWorld(p.aimX, p.aimY);
        let onEnemy = false;
        let i = 0;
        for (i = 0; i < p.enemies.length; i++) {
            const e = p.enemies[i];
            if (e.alive && Math.abs(wAim.x - e.x) <= e.w * 0.85 && wAim.y >= e.y - 6 && wAim.y <= e.y + e.h + 6) {
                onEnemy = true;
            }
        }

        const col = onEnemy ? PALETTE.crimson : PALETTE.cyan;
        const gap = 7 + vfx.crosshairKick;
        const arm = 10;
        const rot = onEnemy ? this.time * 2.5 : 0;

        // 四向锐利刻度臂
        uiGlow.drawSegment(Vec2(mx - gap - arm, my), Vec2(mx - gap, my), 1.6, toColor(col, 240));
        uiGlow.drawSegment(Vec2(mx + gap, my), Vec2(mx + gap + arm, my), 1.6, toColor(col, 240));
        uiGlow.drawSegment(Vec2(mx, my - gap - arm), Vec2(mx, my - gap), 1.6, toColor(col, 240));
        uiGlow.drawSegment(Vec2(mx, my + gap), Vec2(mx, my + gap + arm), 1.6, toColor(col, 240));
        uiGlow.drawDot(Vec2(mx, my), 2.2, toColor(onEnemy ? PALETTE.crimsonCore : PALETTE.cyanCore, 255));

        // 锁定活敌时外圈旋转菱形光框
        if (onEnemy) {
            const dr = 17 + Math.sin(this.time * 16) * 1.5;
            drawDiamond(uiGlow, mx, my, dr, dr, Color(255, 48, 82, 24), 1.5, toColor(PALETTE.crimson, 230));
            fillRadialGlow(uiGlow, mx, my, 24, 24, toColor(PALETTE.crimson, 75), Color(255, 48, 82, 0), 12);
        } else {
            const cr = gap + 4;
            uiDraw.drawArc(Vec2(mx, my), cr, 25 + rot * 20, 65 + rot * 20, 1.1, toColor(PALETTE.cyanDim, 180));
            uiDraw.drawArc(Vec2(mx, my), cr, 205 + rot * 20, 245 + rot * 20, 1.1, toColor(PALETTE.cyanDim, 180));
        }
    }
}
