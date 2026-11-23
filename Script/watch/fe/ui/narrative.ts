/** 故事过场和一条当前目标。房间名交给 HUD。 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { TextPool } from "Script/watch/fe/ui/textpool";
import { PALETTE, themeOf, toColor, visualTextWidth } from "Script/watch/fe/theme";

export class NarrativeRenderer {
    letterbox = 0;
    wipeT = 0;
    private roomKey = "";

    onEnterRoom(roomKey: string): void {
        this.roomKey = roomKey;
        this.letterbox = 0;
        this.wipeT = 1;
    }

    update(dt: number, p: Play): void {
        if (this.roomKey !== p.room.key) {
            this.onEnterRoom(p.room.key);
        }
        const cinema = p.phase === "prologue-give" || p.phase === "gate-count" ||
            (p.room.key === "tower" && p.phase !== "tower-wait");
        this.letterbox += ((cinema ? 1 : 0) - this.letterbox) * Math.min(1, dt * 4.5);
        this.wipeT = Math.max(0, this.wipeT - dt * 3.5);
    }

    draw(draw: DrawNode.Type, art: AssetSlotHost, texts: TextPool, p: Play, w: number, h: number): void {
        const barH = Math.round(64 * this.letterbox);
        if (barH > 0) {
            draw.drawRect(Rect(0, h - barH, w, barH), Color(8, 8, 13, 245));
            draw.drawRect(Rect(0, 0, w, barH), Color(8, 8, 13, 245));
        }
        if (this.wipeT > 0) {
            draw.drawRect(Rect(0, 0, w, h), Color(8, 8, 13, Math.round(200 * this.wipeT)));
        }

        if (p.phase === "gate-count") {
            this.drawGateWait(draw, texts, p, w, h);
        } else if (p.phase === "tower-end" || (p.phase === "tower-given" && p.phaseTick >= 120)) {
            this.drawRegistry(draw, art, texts, p.phase === "tower-end", w, h);
        } else {
            const line = this.goalText(p);
            if (line !== "") {
                this.drawSubtitle(draw, texts, line, w);
            }
        }
    }

    private drawSubtitle(draw: DrawNode.Type, texts: TextPool, text: string, w: number): void {
        const width = Math.min(w - 44, visualTextWidth(text, 17) + 44);
        draw.drawRect(Rect((w - width) / 2, 22, width, 40), toColor(PALETTE.panelBgDeep, 235));
        texts.put("sm", text, w * 0.5, 42, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center);
    }

    private goalText(p: Play): string {
        if (p.caughtT > 0) {
            return "被发现了，正在返回检查点。";
        }
        const room = p.room.key;
        if (room === "prologue") {
            if (p.phase === "prologue-wait") {
                return "用 A / D 向右走近小满，把指南针交给她。";
            }
            if (p.phase === "prologue-give") {
                return "周戍把纸条塞进针套，递到她手里。";
            }
            return "带小满向右走出大门。";
        }

        if (room === "street" || room === "checkpoint") {
            if (p.escort.state === "frozen") {
                return "小满受惊停下了。走近她，按 E 安抚。";
            }
            if (p.escort.state === "calming") {
                return "咚、咚。小满慢慢抬起了头。";
            }
            if (p.enemies.some(enemy => enemy.alive)) {
                return "鼠标瞄准，左键开枪。靠近矮柜时按空格翻越。";
            }
            if (room === "street") {
                return "带小满向右，前往检查站。";
            }
            return p.cartDocked ? "和小满一起走到右侧出口。" : "把红布板车推到右边的车窝。";
        }

        if (room === "gate") {
            if (p.phase === "gate-hold") {
                if (p.coverHug) {
                    return "已贴靠掩体。用鼠标瞄准，左键开枪。";
                }
                return p.enemies.some(enemy => enemy.alive && enemy.warnT > 0)
                    ? "敌兵举枪了。靠近街垒，按住 Shift 挡枪。"
                    : "靠近街垒，按住 Shift 贴掩体，守住城门。";
            }
            if (p.phase === "gate-idle") {
                return p.gateNeedConfirm ? "回到绞盘，按 E 重新守门。" : "走到左侧绞盘，等小满到门边。";
            }
            return p.phase === "gate-send" ? "走到右边城门，把小满送出城。" : "用 D 沿小路向右走。";
        }

        if (room === "outside") {
            if (!p.cartDocked) {
                return "把上层的红布板车向右拉开。";
            }
            return p.checkpoint < p.room.arch.x1
                ? "沿左侧石阶下去，按住 Ctrl 穿过低拱。"
                : "沿墙根小路向右走。";
        }

        if (room === "village") {
            if (p.scavChase) {
                return "拾荒者追来了。按住 Ctrl 钻到桌下。";
            }
            if (p.passed) {
                return "继续向右，进入森林。";
            }
            if (p.hasBottle) {
                return "按住 F 瞄准砖地，松开投瓶。";
            }
            if (p.bottleFly !== undefined) {
                return "等瓶子落地，把拾荒者引开。";
            }
            if (p.scavState === "turn" || p.scavState === "walk" || p.scavState === "stall") {
                return "趁拾荒者走开，按住 Ctrl 钻过桌下。";
            }
            return "到瓶架旁，按 E 拾起瓶子。";
        }

        if (room === "forest") {
            if (p.dogState === "chase") {
                return "猎犬追来了。蹲进草丛躲开它。";
            }
            return p.dogState === "ear" ? "猎犬听到了。按住 Ctrl 蹲下。" : "按住 Shift 慢走，绕开猎犬。";
        }

        if (room === "tower") {
            if (p.phase === "tower-wait") {
                return "走到北塔门前，按 E 敲门。";
            }
            if (p.phase === "tower-knock") {
                return "咚、咚。她敲响了北塔的门。";
            }
            return p.phaseTick < 60 ? "门开了，灯光落在小满身上。" : "她把指南针和纸条交给守卫。";
        }

        return themeOf(room).introWhisper;
    }

    private drawGateWait(draw: DrawNode.Type, texts: TextPool, p: Play, w: number, h: number): void {
        const count = Math.min(100, Math.floor(p.countTick * 100 / 1440));
        draw.drawRect(Rect(0, 0, w, h), Color(8, 8, 13, 137));
        texts.put("xl", "" + count, w * 0.5, h * 0.57,
            toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center);
        const hint = count < 100 ? "小满在城外等着。" :
            (p.countPrevMove > 0 ? "先松开方向键，再按 D 向前走。" : "按 D 继续向前走。");
        texts.put("md", hint, w * 0.5, h * 0.46, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center);
    }

    private drawRegistry(
        draw: DrawNode.Type, art: AssetSlotHost, texts: TextPool, ending: boolean, w: number, h: number,
    ): void {
        draw.drawRect(Rect(0, 0, w, h), Color(8, 8, 13, 145));
        const box = Rect((w - 472) / 2, (h - 244) / 2, 472, 244);
        draw.drawRect(box, toColor(PALETTE.panelBgDeep, 250), 1, toColor(PALETTE.steelLight));
        art.tryPlace("ui_paper", "registry_paper", box.centerX, box.centerY, box.width - 14, box.height - 14,
            { opacity: 0.14 });

        texts.put("lg", "北塔登记簿", box.x + 26, box.top - 38, toColor(PALETTE.textBright));
        texts.put("md", "小满　已入塔", box.x + 26, box.top - 86, toColor(PALETTE.textBright));
        texts.put("sm", "她带来了指南针和纸条。", box.x + 26, box.top - 120, toColor(PALETTE.textMid));
        texts.put("sm", "护送者", box.x + 26, box.y + 82, toColor(PALETTE.textMid));
        draw.drawSegment(Vec2(box.x + 101, box.y + 80), Vec2(box.right - 26, box.y + 80),
            1, toColor(PALETTE.amberDim));
        if (ending) {
            texts.put("sm", "E 再玩一次　　Esc 暂停菜单", box.x + 26, box.y + 35, toColor(PALETTE.textBright));
        }
    }
}
