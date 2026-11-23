/**
 * 艾希（ICEY）式旁白/元叙事字幕带 + 电影遮幅 + 过场标题卡 + 两大核心演出层：
 * 1) 城门「数到一百」（gate-count）：24 秒暗角渐闭、节拍计数与松键后 [D] 交权亮起；
 * 2) 北塔尾声「登记簿最后一页空行」（tower-given / tower-end）：仪式感定格卡片与再玩入口。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { TextPool } from "Script/watch/fe/ui/textpool";
import {
    PALETTE,
    drawDiamond,
    fillChamferBox,
    fillRadialGlow,
    fillSkewRect,
    fillVGradRect,
    themeOf,
    toColor,
    visualTextWidth,
} from "Script/watch/fe/theme";

export class NarrativeRenderer {
    /** 当前电影遮幅展开比例（0..1） */
    letterbox = 0;
    /** 区域切场标题卡剩余显示时间（秒） */
    bannerT = 0;
    private bannerMax = 2.8;
    /** 斜切转场黑幕进度（1 → 0） */
    wipeT = 0;
    private lastRoomKey = "";
    private time = 0;

    onEnterRoom(roomKey: string): void {
        this.lastRoomKey = roomKey;
        this.bannerT = this.bannerMax;
        this.wipeT = 1.0;
    }

    update(dt: number, p: Play): void {
        this.time += dt;
        if (this.lastRoomKey !== p.room.key) {
            this.onEnterRoom(p.room.key);
        }
        const wantCinema =
            (p.room.key === "prologue" && p.phase === "prologue-give")
            || (p.room.key === "gate" && p.phase === "gate-count")
            || (p.room.key === "tower" && p.phase !== "tower-wait");
        const target = wantCinema ? 1 : 0;
        this.letterbox += (target - this.letterbox) * Math.min(1, dt * 4.5);

        if (this.bannerT > 0) {
            this.bannerT = Math.max(0, this.bannerT - dt);
        }
        if (this.wipeT > 0) {
            this.wipeT = Math.max(0, this.wipeT - dt * 2.8);
        }
    }

    draw(
        uiDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
    ): void {
        // 1. 电影遮幅（Letterbox）
        if (this.letterbox > 0.01) {
            const barH = Math.round(74 * this.letterbox);
            uiDraw.drawRect(Rect(0, h - barH, w, barH), Color(4, 6, 11, 245));
            uiDraw.drawRect(Rect(0, 0, w, barH), Color(4, 6, 11, 245));
            uiGlow.drawSegment(Vec2(0, h - barH), Vec2(w, h - barH), 1.1, toColor(PALETTE.cyanDim, 110 * this.letterbox));
            uiGlow.drawSegment(Vec2(0, barH), Vec2(w, barH), 1.1, toColor(PALETTE.cyanDim, 110 * this.letterbox));
        }

        // 2. 城门「数到一百」专属暗角与交权演出
        if (p.room.key === "gate" && p.phase === "gate-count") {
            this.drawGateCountOverlay(uiDraw, uiGlow, texts, p, w, h);
        }

        // 3. 北塔尾声「登记簿空行」专属仪式卡片
        if (p.room.key === "tower" && (p.phase === "tower-end" || (p.phase === "tower-given" && p.phaseTick >= 96))) {
            this.drawTowerRegistryCard(uiDraw, uiGlow, texts, p, w, h);
        }

        // 4. 底部艾希式旁白 / 系统指令字幕条（永远清晰、克制、不含坐标杂讯）
        if (!p.paused) {
            this.drawSubtitleStrip(uiDraw, uiGlow, texts, p, w, h);
        }

        // 5. 切场区域标题卡（入场前 2.8 秒居中上方缓出）
        if (this.bannerT > 0 && !p.paused) {
            this.drawAreaBanner(uiDraw, uiGlow, texts, p.room.key, w, h);
        }

        // 6. 房间切换斜切黑幕转场
        if (this.wipeT > 0.01) {
            const a = Math.round(255 * Math.min(1, this.wipeT * 1.15));
            uiDraw.drawRect(Rect(0, 0, w, h), Color(4, 6, 11, a));
            const slashX = w * (1 - this.wipeT);
            uiGlow.drawSegment(Vec2(slashX - 60, 0), Vec2(slashX + 60, h), 3, toColor(PALETTE.cyan, 190 * this.wipeT));
        }
    }

    private drawSubtitleStrip(
        uiDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
    ): void {
        const line = this.composeNarrativeLine(p);
        if (line.text === "") {
            return;
        }
        const textW = visualTextWidth(line.text, 17);
        const speakerW = visualTextWidth(line.speaker, 14);
        const stripW = Math.min(w - 100, Math.max(420, textW + speakerW + 96));
        const stripH = 42;
        const sx = (w - stripW) * 0.5;
        const sy = this.letterbox > 0.4 ? 16 : 22;
        const accent = line.urgent ? PALETTE.crimson : (p.childMode ? PALETTE.amber : PALETTE.cyan);

        fillSkewRect(uiDraw, sx, sy, stripW, stripH, 10, toColor(PALETTE.panelBgDeep, 218), 1.0, toColor(accent, 150));
        fillSkewRect(uiGlow, sx - 3, sy, 4, stripH, 10, toColor(accent, 235));
        texts.put("xs", line.speaker, sx + 18, sy + stripH * 0.5, toColor(accent), 0, 0.5, TextAlign.Left, 0.9, 0.94);
        uiDraw.drawSegment(Vec2(sx + speakerW + 30, sy + 10), Vec2(sx + speakerW + 30, sy + stripH - 10), 1, toColor(accent, 95));
        texts.put("sm", line.text, sx + speakerW + 46, sy + stripH * 0.5, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.4, 0.98);
    }

    /** 把后端状态与短反馈翻译成凝练的《守望》×《艾希》旁白/指令句 */
    private composeNarrativeLine(p: Play): { speaker: string; text: string; urgent: boolean } {
        const key = p.room.key;
        const theme = themeOf(key);

        if (key === "gate" && p.phase === "gate-hold") {
            let threatened = false;
            let i = 0;
            for (i = 0; i < p.enemies.length; i++) {
                if (p.enemies[i].alive && p.enemies[i].warnT > 0) {
                    threatened = true;
                }
            }
            if (threatened) {
                return { speaker: "WARN // 锁敌", text: "敌兵举枪瞄准 —— 贴住街垒按住 [SHIFT] 格挡，或左键先手击倒", urgent: true };
            }
            if (p.coverHug) {
                return { speaker: "SYS // 掩体", text: "已贴靠掩体。左键点射压制来敌，守满四十五秒", urgent: false };
            }
            return { speaker: "SYS // 守点", text: "前出至街垒左侧贴掩体，左键点射守住城门", urgent: false };
        }

        if (key === "gate" && p.phase === "gate-count") {
            if (p.countTick >= 1440) {
                return {
                    speaker: "WATCH // 交权",
                    text: p.countPrevMove > 0 ? "先松开方向键，再按下 [D] —— 由她迈出第一步" : "数到一百了，没有人来。按下 [D]，继续向北走",
                    urgent: false,
                };
            }
            return { speaker: "NARRATOR", text: "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent: false };
        }

        if (p.flash !== "" && p.flashT > 0) {
            const isDanger = p.flash.indexOf("中弹") >= 0 || p.flash.indexOf("被抓") >= 0 || p.flash.indexOf("击倒") >= 0 || p.flash.indexOf("看见") >= 0 || p.flash.indexOf("追") >= 0;
            let text = p.flash;
            let speaker = isDanger ? "ALERT" : (p.childMode ? "STEALTH" : "COMBAT");
            if (key === "tower" || key === "prologue") {
                speaker = "NARRATOR";
            }
            if (text === "命中") {
                text = "目标击倒 —— 继续推进并留意掩体";
            } else if (text === "打空") {
                text = "弹道偏离或被掩体阻挡";
            } else if (text === "翻滚") {
                text = "战术翻滚回避";
            }
            return { speaker, text, urgent: isDanger };
        }

        if (key === "prologue") {
            if (p.phase === "prologue-wait") {
                return { speaker: "NARRATOR", text: "倒塌的柜台后面藏着一个孩子。走近她，按 [E] 递出指南针与纸条", urgent: false };
            }
            if (p.phase === "prologue-give") {
                return { speaker: "NARRATOR", text: "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent: false };
            }
            return { speaker: "NARRATOR", text: "她攥紧针套跟了上来。一起向右走出大门，进入街道", urgent: false };
        }

        if (key === "street") {
            let alive = 0;
            let i = 0;
            for (i = 0; i < p.enemies.length; i++) {
                if (p.enemies[i].alive) { alive += 1; }
            }
            if (alive > 0) {
                return { speaker: "SYS // 交火", text: "前方街心有封锁敌兵。鼠标瞄准左键点射，空格贴矮台可翻越", urgent: false };
            }
            return { speaker: "NARRATOR", text: "街心安静了。带她继续向右，前往城邦检查站", urgent: false };
        }

        if (key === "checkpoint") {
            if (p.escort.state === "frozen") {
                return { speaker: "ALERT // 护送", text: "枪声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent: true };
            }
            if (p.escort.state === "calming") {
                return { speaker: "NARRATOR", text: "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent: false };
            }
            if (!p.cartDocked) {
                return { speaker: "SYS // 机关", text: "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent: false };
            }
            return { speaker: "SYS // 出口", text: "车轮落窝了。与小满一同站进右侧双人出口，推开城门", urgent: false };
        }

        if (key === "gate") {
            if (p.phase === "gate-idle") {
                return {
                    speaker: "NARRATOR",
                    text: p.gateNeedConfirm ? "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" : "小满正走向门洞等待点。贴近左侧绞盘就位，守住最后四十五秒",
                    urgent: p.gateNeedConfirm,
                };
            }
            if (p.phase === "gate-send") {
                return { speaker: "NARRATOR", text: "四十五秒守满了。走到右侧门洞边，按 [E] 把她送出城去", urgent: false };
            }
            return { speaker: "NARRATOR", text: "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent: false };
        }

        if (key === "outside") {
            if (!p.cartDocked) {
                return { speaker: "NARRATOR", text: "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent: false };
            }
            if (p.checkpoint < 380) {
                return { speaker: "SYS // 潜行", text: "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent: false };
            }
            return { speaker: "NARRATOR", text: "穿过矮拱，沿墙根小路向北塔灯火前行", urgent: false };
        }

        if (key === "village") {
            if (p.scavChase) {
                return { speaker: "ALERT // 暴露", text: "拾荒者追上来了！迅速蹲伏或钻进桌底甩开视线", urgent: true };
            }
            if (p.hasBottle) {
                return { speaker: "SYS // 诱敌", text: "按住 [F] 瞄准右侧砖地，松手投瓶 —— 趁他转身走开，按 [CTRL] 钻过桌下", urgent: false };
            }
            if (p.passed) {
                return { speaker: "NARRATOR", text: "越过了第一院。继续向右，走进通往北塔的森林", urgent: false };
            }
            return { speaker: "NARRATOR", text: "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent: false };
        }

        if (key === "forest") {
            if (p.dogState === "chase" || p.dogState === "ear") {
                return { speaker: "ALERT // 猎犬", text: "猎犬竖起了耳朵 —— 立刻蹲下或伏在草影里别出声！", urgent: true };
            }
            return { speaker: "NARRATOR", text: "林间有猎犬巡逻。按住 [SHIFT] 慢走或 [CTRL] 伏低，穿过林缘抵达北塔", urgent: false };
        }

        if (key === "tower") {
            if (p.phase === "tower-wait") {
                return { speaker: "NARRATOR", text: "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent: false };
            }
            if (p.phase === "tower-knock") {
                return { speaker: "NARRATOR", text: "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent: false };
            }
            if (p.phase === "tower-given") {
                return { speaker: "NARRATOR", text: "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent: false };
            }
            return { speaker: "EPILOGUE // 守望", text: "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent: false };
        }

        return { speaker: "NARRATOR", text: theme.introWhisper, urgent: false };
    }

    private drawGateCountOverlay(
        uiDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
    ): void {
        const frac = Math.min(1, p.countTick / 1440);
        const countNum = Math.min(100, Math.floor(frac * 100));
        // 渐进压暗四周
        uiDraw.drawRect(Rect(0, 0, w, h), Color(4, 6, 12, Math.round(70 + frac * 105)));

        const cy = h * 0.56;
        const numStr = countNum < 10 ? "00" + countNum : (countNum < 100 ? "0" + countNum : "100");
        texts.put("xl", numStr, w * 0.5, cy, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 8, 0.28 + frac * 0.65);
        texts.put("sm", "COUNTING OUTSIDE THE GATE  //  城外等待", w * 0.5, cy - 42, toColor(PALETTE.textDim), 0.5, 0.5, TextAlign.Center, 2.5, 0.72);

        if (p.countTick >= 1440) {
            const pulse = 0.65 + 0.35 * Math.sin(this.time * 4.5);
            fillRadialGlow(uiGlow, w * 0.5, cy - 88, 130, 26, toColor(PALETTE.amber, 75 * pulse), Color(242, 188, 96, 0), 16);
            fillSkewRect(uiDraw, w * 0.5 - 120, cy - 106, 240, 34, 9, toColor(PALETTE.panelBgDeep, 235), 1.4, toColor(PALETTE.amber, 230 * pulse));
            const prompt = p.countPrevMove > 0 ? "先松开方向键，再按 [D]" : "按 [D] · 迈出第一步";
            texts.put("sm", prompt, w * 0.5, cy - 89, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.0, 1);
        }
    }

    private drawTowerRegistryCard(
        uiDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
    ): void {
        const cardW = 480;
        const cardH = 264;
        const cx = (w - cardW) * 0.5;
        const cy = (h - cardH) * 0.5 + 14;

        uiDraw.drawRect(Rect(0, 0, w, h), Color(4, 6, 12, 145));
        fillChamferBox(uiDraw, cx, cy, cardW, cardH, 18, toColor(PALETTE.panelBgDeep, 242), 1.5, toColor(PALETTE.amber, 210));
        fillVGradRect(uiGlow, cx, cy + cardH - 52, cardW, 52, Color(242, 188, 96, 0), Color(242, 188, 96, 48));

        texts.put("xs", "NORTH TOWER ARCHIVE  //  北塔入塔登记簿 · 末页", cx + 26, cy + cardH - 22, toColor(PALETTE.amber), 0, 0.5, TextAlign.Left, 1.2, 1);
        uiDraw.drawSegment(Vec2(cx + 22, cy + cardH - 40), Vec2(cx + cardW - 22, cy + cardH - 40), 1.1, toColor(PALETTE.amberDim, 180));

        // 登记条目
        texts.put("sm", "#041   小满  ·  持黄铜指南针与纸条  ·  已入塔", cx + 28, cy + cardH - 72, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.4, 1);
        texts.put("xs", "附注：\"护送者留守南城门，托她独自走完余路。\"", cx + 28, cy + cardH - 102, toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.3, 0.92);

        // 标志性空行（留给下一个人 / 周戍）
        const blankY = cy + 102;
        const pulse = 0.72 + 0.28 * Math.sin(this.time * 2.6);
        uiDraw.drawSegment(Vec2(cx + 28, blankY - 12), Vec2(cx + cardW - 28, blankY - 12), 1.2, toColor(PALETTE.amber, 165 * pulse));
        texts.put("sm", "#042   ____________________________  （空行留待）", cx + 28, blankY + 4, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 0.5, 0.88 * pulse);

        if (p.phase === "tower-end") {
            texts.put("md", "月下山谷 · 守望", w * 0.5, cy + 52, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 3.0, 1);
            texts.put("xs", "[E] 再次启程     ·     [ESC] 系统菜单", w * 0.5, cy + 24, toColor(PALETTE.cyan), 0.5, 0.5, TextAlign.Center, 1.2, 0.95);
        }
    }

    private drawAreaBanner(
        uiDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        roomKey: string,
        w: number,
        h: number,
    ): void {
        const theme = themeOf(roomKey);
        const t = this.bannerT / this.bannerMax;
        // 快入缓停渐出
        let alpha = 1;
        if (t > 0.82) {
            alpha = (1 - t) / 0.18;
        } else if (t < 0.25) {
            alpha = t / 0.25;
        }
        const cy = h * 0.79;
        const lineW = 360 * Math.min(1, alpha * 1.2);
        uiGlow.drawSegment(Vec2(w * 0.5 - lineW * 0.5, cy - 2), Vec2(w * 0.5 + lineW * 0.5, cy - 2), 1.6, toColor(theme.accent, 210 * alpha));
        drawDiamond(uiGlow, w * 0.5, cy - 2, 5, 5, toColor(PALETTE.cyanCore, 230 * alpha));

        texts.put("lg", theme.actCode + "  ·  " + theme.titleZh, w * 0.5, cy + 26, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 2.2, alpha);
        texts.put("xs", theme.titleEn, w * 0.5, cy - 20, toColor(theme.accent), 0.5, 0.5, TextAlign.Center, 2.0, alpha * 0.9);
    }
}
