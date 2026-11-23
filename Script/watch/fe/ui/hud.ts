/** 局内只显示人物状态、房间和当前可用动作。 */

import { DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { FEAR_MAX } from "Script/watch/escort";
import { deriveWorldPrompt, WorldPrompt } from "Script/watch/fe/adapter";
import { CameraDirector } from "Script/watch/fe/camera";
import { VfxSystem } from "Script/watch/fe/renderer/vfx";
import { TextPool } from "Script/watch/fe/ui/textpool";
import { PALETTE, RGBA, themeOf, toColor, visualTextWidth } from "Script/watch/fe/theme";

export class HudRenderer {
    draw(
        uiDraw: DrawNode.Type, uiGlow: DrawNode.Type, texts: TextPool,
        p: Play, cam: CameraDirector, vfx: VfxSystem, letterbox: number, uiScale: number,
    ): void {
        const w = cam.viewW / uiScale;
        const h = cam.viewH / uiScale;
        const opacity = Math.max(0, 1 - letterbox * 1.15);
        if (opacity > 0.05) {
            this.drawStatus(uiDraw, texts, p, w, h, opacity);

            const gate = p.room.story?.gate;
            if (gate !== undefined && p.phase === "gate-hold") {
                const left = Math.max(0, Math.ceil((gate.holdTicks - p.gateTick) / 60));
                const box = Rect(w * 0.5 - 101, h - 67, 202, 40);
                this.panel(uiDraw, box, opacity);
                texts.put("md", "守门 · 剩余 " + left + " 秒", box.centerX, box.centerY,
                    toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 0, opacity);
            }

            const prompt = deriveWorldPrompt(p);
            if (prompt !== undefined) {
                this.drawPrompt(uiDraw, texts, prompt, cam, w, h, uiScale, opacity);
            }
        }

        if (letterbox < 0.5 && !p.childMode && p.phase !== "prologue-give" &&
            p.escort.state !== "calming" && !p.gateNeedConfirm) {
            this.drawReticle(uiGlow, p, vfx, uiScale);
        }
    }

    private panel(draw: DrawNode.Type, box: Rect.Type, opacity: number): void {
        draw.drawRect(box, toColor(PALETTE.panelBgDeep, 232 * opacity),
            1, toColor(PALETTE.steelLight, 165 * opacity));
    }

    private drawStatus(
        draw: DrawNode.Type, texts: TextPool, p: Play, w: number, h: number, opacity: number,
    ): void {
        const left = 28;
        const top = h - 28;
        const showFear = !p.childMode && p.partner.alive &&
            (p.room.key === "street" || p.room.key === "checkpoint");
        const height = showFear ? 70 : 44;
        this.panel(draw, Rect(left, top - height, 238, height), opacity);

        if (p.childMode) {
            let status = p.player.crouch ? "蹲下" : "小心前进";
            if (p.dogState === "chase" || p.scavChase) {
                status = "被发现了";
            }
            texts.put("sm", "小满 · " + status, left + 14, top - 22, toColor(PALETTE.textBright),
                0, 0.5, TextAlign.Left, 0, opacity);
        } else if (p.room.key === "gate") {
            this.drawMeter(draw, texts, "周戍体力", p.hp, p.maxHp, left, top - 22,
                p.hp === 1 ? PALETTE.crimson : PALETTE.cyanCore, opacity);
        } else {
            texts.put("sm", "周戍 · 护送", left + 14, top - 22, toColor(PALETTE.textBright),
                0, 0.5, TextAlign.Left, 0, opacity);
            if (showFear) {
                this.drawMeter(draw, texts, "小满恐惧", p.escort.fear, FEAR_MAX, left, top - 48,
                    p.escort.state === "frozen" ? PALETTE.crimson : PALETTE.amber, opacity);
            }
        }

        const box = Rect(w - 268, h - 72, 240, 44);
        this.panel(draw, box, opacity);
        texts.put("sm", themeOf(p.room.key).titleZh, box.x + 12, box.centerY,
            toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0, opacity);
        texts.put("xs", "Esc 暂停", box.right - 11, box.centerY,
            toColor(PALETTE.textMid), 1, 0.5, TextAlign.Right, 0, opacity);
    }

    private drawMeter(
        draw: DrawNode.Type, texts: TextPool, label: string, filled: number, total: number,
        x: number, y: number, tint: RGBA, opacity: number,
    ): void {
        texts.put("sm", label, x + 14, y, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0, opacity);
        const cellW = Math.min(19, 86 / Math.max(1, total) - 5);
        for (let i = 0; i < total; i++) {
            const active = i < filled;
            draw.drawRect(Rect(x + 95 + i * (cellW + 5), y - 5, cellW, 10),
                toColor(active ? tint : PALETTE.voidDark, 220 * opacity),
                1, toColor(PALETTE.steelLight, 200 * opacity));
        }
        texts.put("sm", filled + "/" + total, x + 222, y, toColor(PALETTE.textBright),
            1, 0.5, TextAlign.Right, 0, opacity);
    }

    private drawPrompt(
        draw: DrawNode.Type, texts: TextPool, prompt: WorldPrompt, cam: CameraDirector,
        w: number, h: number, scale: number, opacity: number,
    ): void {
        const screenX = cam.sx(prompt.x) / scale;
        if (screenX < 4 || screenX > w - 4) {
            return;
        }
        const label = prompt.keyTag + "  " + prompt.label;
        const width = Math.min(w - 32, visualTextWidth(label, 17) + 30);
        const x = Math.min(w - width - 16, Math.max(16, screenX - width * 0.5));
        const y = Math.max(83, Math.min(h - 140, cam.sy(prompt.y) / scale));
        const rect = Rect(x, y, width, 32);
        this.panel(draw, rect, opacity);
        texts.put("sm", label, rect.centerX, rect.centerY,
            toColor(prompt.urgent ? PALETTE.amberCore : PALETTE.textBright),
            0.5, 0.5, TextAlign.Center, 0, opacity);
    }

    private drawReticle(
        draw: DrawNode.Type, p: Play, vfx: VfxSystem, scale: number,
    ): void {
        const x = p.aimX / scale;
        const y = p.aimY / scale;
        if (x <= 0 && y <= 0) {
            return;
        }

        const gap = 5 + vfx.crosshairKick * 0.45;
        const arm = 6;
        const color = toColor(PALETTE.cyanCore);
        draw.drawSegment(Vec2(x - gap - arm, y), Vec2(x - gap, y), 1.6, color);
        draw.drawSegment(Vec2(x + gap, y), Vec2(x + gap + arm, y), 1.6, color);
        draw.drawSegment(Vec2(x, y - gap - arm), Vec2(x, y - gap), 1.6, color);
        draw.drawSegment(Vec2(x, y + gap), Vec2(x, y + gap + arm), 1.6, color);
        draw.drawDot(Vec2(x, y), 1.8, color);
    }
}
