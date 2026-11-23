/**
 * 《向西守望》中国水墨叙事与高光演出层（参考《饿殍：明末千里行》美学）：
 * - 底部两端渐隐墨韵旁白带（全中文语境，去英文终端前缀，危急/动作配单字小印）；
 * - 切场书法章名横幅（汉字大写章印 壹~捌 + 毛笔大字 + 枯笔墨线）与浓墨缓合转场；
 * - 演出 1：城门「数到一百」—— 中文大写数字（零、壹……玖拾玖、壹佰）渗墨浮现；
 * - 演出 2：北塔尾声「登记簿末页」—— 完整泛黄旧宣纸本体 + 焦墨手书条目 + 朱砂红线与官印。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { TextPool } from "Script/watch/fe/ui/textpool";
import {
    PALETTE,
    drawBrushDivider,
    drawInkWashStrip,
    drawOvalSeal,
    drawSealStamp,
    fillRadialGlow,
    themeOf,
    toChineseUpper,
    toColor,
    visualTextWidth,
} from "Script/watch/fe/theme";

export class NarrativeRenderer {
    /** 当前电影遮幅展开比例（0..1） */
    letterbox = 0;
    /** 区域切场标题卡剩余显示时间（秒） */
    bannerT = 0;
    private bannerMax = 2.8;
    /** 墨幕切场转场进度（1 → 0） */
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
            this.wipeT = Math.max(0, this.wipeT - dt * 2.4);
        }
    }

    draw(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        art: AssetSlotHost,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
    ): void {
        // 1. 电影遮幅（沉墨纯黑 + 极微暗古铜发丝线）
        if (this.letterbox > 0.01) {
            const barH = Math.round(72 * this.letterbox);
            uiDraw.drawRect(Rect(0, h - barH, w, barH), Color(8, 9, 13, 244));
            uiDraw.drawRect(Rect(0, 0, w, barH), Color(8, 9, 13, 244));
            uiInkDraw.drawSegment(Vec2(0, h - barH), Vec2(w, h - barH), 0.9, toColor(PALETTE.bronzeDim, 90 * this.letterbox));
            uiInkDraw.drawSegment(Vec2(0, barH), Vec2(w, barH), 0.9, toColor(PALETTE.bronzeDim, 90 * this.letterbox));
        }

        // 2. 城门「数到一百」水墨暗角与中文大写计数演出
        if (p.room.key === "gate" && p.phase === "gate-count") {
            this.drawGateCountOverlay(uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h);
        }

        // 3. 北塔尾声「登记簿末页」旧宣纸账簿定格卡片
        const showRegistry = p.room.key === "tower" && (p.phase === "tower-end" || (p.phase === "tower-given" && p.phaseTick >= 120));
        if (showRegistry) {
            this.drawTowerRegistryCard(uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h);
        }

        // 4. 底部两端渐隐墨韵旁白字幕带（尾声摊开登记簿时隐藏底部条，避免重复）
        if (!p.paused && !showRegistry) {
            this.drawSubtitleStrip(uiDraw, uiInkDraw, art, texts, p, w, h);
        }

        // 5. 切场书法区域标题卡（入场前 2.8 秒居中上方缓现淡散）
        if (this.bannerT > 0 && !p.paused) {
            this.drawAreaBanner(uiDraw, uiInkDraw, art, texts, p.room.key, w, h);
        }

        // 6. 房间切换浓墨舒卷转场（去掉电子青光剑斩）
        if (this.wipeT > 0.01) {
            const k = Math.min(1, this.wipeT * 1.18);
            const a = Math.round(255 * k * k);
            uiDraw.drawRect(Rect(0, 0, w, h), Color(9, 10, 14, a));
            art.tryPlace("ink_splatter", "wipe_mist", w * 0.5, h * 0.5, w * 0.72, h * 0.72, {
                color: toColor(PALETTE.inkMist), opacity: 0.22 * this.wipeT, layer: 5,
            });
        }
    }

    private drawSubtitleStrip(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        art: AssetSlotHost,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
    ): void {
        const line = this.composeNarrativeLine(p);
        if (line.text === "") {
            return;
        }
        const hasSeal = line.seal !== "";
        const textW = visualTextWidth(line.text, 18);
        const contentW = textW + (hasSeal ? 42 : 0);
        const stripW = Math.min(w - 84, Math.max(480, contentW + 148));
        const stripH = 48;
        const cx = w * 0.5;
        const cy = this.letterbox > 0.4 ? 36 : 42;

        // 两端飞白渐隐墨韵长带
        drawInkWashStrip(
            uiDraw,
            art,
            "sub_ink_strip",
            cx,
            cy,
            stripW,
            stripH,
            line.urgent ? PALETTE.inkWarm : PALETTE.inkWash,
            0.88,
            true,
            -1,
        );
        // 上下极细枯笔古铜/暗朱发丝线
        const railCol = line.urgent ? PALETTE.sealRedBright : PALETTE.bronzeDim;
        drawBrushDivider(uiInkDraw, art, "sub_rail_top", cx, cy + 20, stripW * 0.74, 8, railCol, 0.52, 2);
        drawBrushDivider(uiInkDraw, art, "sub_rail_bot", cx, cy - 20, stripW * 0.74, 8, railCol, 0.52, 2);

        if (hasSeal) {
            const startX = cx - contentW * 0.5;
            const sealCol = line.urgent ? PALETTE.sealRed : (p.childMode ? PALETTE.amberDim : PALETTE.cyanDim);
            drawSealStamp(
                uiInkDraw,
                art,
                texts,
                "sub_seal",
                startX + 13,
                cy,
                25,
                line.seal,
                sealCol,
                PALETTE.sealText,
                0.96,
                line.urgent,
                4,
            );
            texts.put("sm", line.text, startX + 36, cy, toColor(line.urgent ? PALETTE.crimsonCore : PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.6, 0.98);
        } else {
            texts.put("sm", line.text, cx, cy, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 0.8, 0.98);
        }
    }

    /** 将后端状态译作克制的古风旁白与动作短句（零英文终端符号） */
    private composeNarrativeLine(p: Play): { seal: string; text: string; urgent: boolean } {
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
                return { seal: "警", text: "敌兵举枪瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent: true };
            }
            if (p.coverHug) {
                return { seal: "掩", text: "已贴靠掩体。左键点射压制来敌，守满四十五秒", urgent: false };
            }
            return { seal: "守", text: "前出至街垒左侧贴掩体，左键点射守住城门", urgent: false };
        }

        if (key === "gate" && p.phase === "gate-count") {
            if (p.countTick >= 1440) {
                return {
                    seal: "",
                    text: p.countPrevMove > 0 ? "先松开方向键，再按下 [D] —— 由她迈出第一步" : "数到一百了，没有人来。按下 [D]，继续向北走",
                    urgent: false,
                };
            }
            return { seal: "", text: "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent: false };
        }

        if (p.flash !== "" && p.flashT > 0) {
            const isDanger = p.flash.indexOf("中弹") >= 0 || p.flash.indexOf("被抓") >= 0 || p.flash.indexOf("击倒") >= 0 || p.flash.indexOf("看见") >= 0 || p.flash.indexOf("追") >= 0;
            let text = p.flash;
            let seal = isDanger ? "危" : (p.childMode ? "潜" : "战");
            if (key === "tower" || key === "prologue") {
                seal = "";
            }
            if (text === "命中") {
                text = "目标击倒 —— 继续推进并留意掩体";
            } else if (text === "打空") {
                text = "弹道偏离或被掩体阻挡";
            } else if (text === "翻滚") {
                text = "伏身翻滚回避";
            }
            return { seal, text, urgent: isDanger };
        }

        if (key === "prologue") {
            if (p.phase === "prologue-wait") {
                return { seal: "", text: "倒塌的柜台后面藏着一个孩子。走近她，按 [E] 递出指南针与纸条", urgent: false };
            }
            if (p.phase === "prologue-give") {
                return { seal: "", text: "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent: false };
            }
            return { seal: "", text: "她攥紧针套跟了上来。一起向右走出大门，进入街道", urgent: false };
        }

        if (key === "street") {
            let alive = 0;
            let i = 0;
            for (i = 0; i < p.enemies.length; i++) {
                if (p.enemies[i].alive) { alive += 1; }
            }
            if (alive > 0) {
                return { seal: "战", text: "前方街心有倭寇封锁。鼠标瞄准，左键发射火铳，空格贴矮台可翻越", urgent: false };
            }
            return { seal: "", text: "街心安静了。带她继续向右，前往城邦检查站", urgent: false };
        }

        if (key === "checkpoint") {
            if (p.escort.state === "frozen") {
                return { seal: "危", text: "枪声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent: true };
            }
            if (p.escort.state === "calming") {
                return { seal: "", text: "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent: false };
            }
            if (!p.cartDocked) {
                return { seal: "机", text: "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent: false };
            }
            return { seal: "归", text: "车轮落窝了。与小满一同站进右侧双人出口，推开城门", urgent: false };
        }

        if (key === "gate") {
            if (p.phase === "gate-idle") {
                return {
                    seal: p.gateNeedConfirm ? "警" : "",
                    text: p.gateNeedConfirm ? "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" : "小满正走向门洞等待点。贴近左侧绞盘就位，守住最后四十五秒",
                    urgent: p.gateNeedConfirm,
                };
            }
            if (p.phase === "gate-send") {
                return { seal: "", text: "四十五秒守满了。走到右侧门洞边，按 [E] 把她送出城去", urgent: false };
            }
            return { seal: "", text: "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent: false };
        }

        if (key === "outside") {
            if (!p.cartDocked) {
                return { seal: "", text: "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent: false };
            }
            if (p.checkpoint < 380) {
                return { seal: "潜", text: "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent: false };
            }
            return { seal: "", text: "穿过矮拱，沿墙根小路向北塔灯火前行", urgent: false };
        }

        if (key === "village") {
            if (p.scavChase) {
                return { seal: "危", text: "拾荒者追上来了！迅速蹲伏或钻进桌底甩开视线", urgent: true };
            }
            if (p.hasBottle) {
                return { seal: "诱", text: "按住 [F] 瞄准右侧砖地，松手投瓶 —— 趁他转身走开，按 [CTRL] 钻过桌下", urgent: false };
            }
            if (p.passed) {
                return { seal: "", text: "越过了第一院。继续向右，走进通往北塔的森林", urgent: false };
            }
            if (p.bottleFly !== undefined) {
                return { seal: "诱", text: "等瓶子落地，把拾荒者引开。", urgent: false };
            }
            if (p.scavState === "turn" || p.scavState === "walk" || p.scavState === "stall") {
                return { seal: "潜", text: "趁拾荒者走开，按住 [CTRL] 钻过桌下。", urgent: false };
            }
            return { seal: "", text: "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent: false };
        }

        if (key === "forest") {
            if (p.dogState === "chase" || p.dogState === "ear") {
                return { seal: "警", text: "猎犬竖起了耳朵 —— 立刻蹲下或伏在草影里别出声！", urgent: true };
            }
            return { seal: "", text: "林间有猎犬巡逻。按住 [SHIFT] 慢走或 [CTRL] 伏低，穿过林缘抵达北塔", urgent: false };
        }

        if (key === "tower") {
            if (p.phase === "tower-wait") {
                return { seal: "", text: "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent: false };
            }
            if (p.phase === "tower-knock") {
                return { seal: "", text: "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent: false };
            }
            if (p.phase === "tower-given") {
                return { seal: "", text: "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent: false };
            }
            return { seal: "", text: "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent: false };
        }

        return { seal: "", text: theme.introWhisper, urgent: false };
    }

    private drawGateCountOverlay(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        art: AssetSlotHost,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
    ): void {
        const frac = Math.min(1, p.countTick / 1440);
        const countNum = Math.min(100, Math.floor(frac * 100));
        // 渐进墨幕暗角
        uiDraw.drawRect(Rect(0, 0, w, h), Color(7, 8, 12, Math.round(74 + frac * 114)));

        const cy = h * 0.56;
        art.tryPlace("ink_splatter", "gate_count_mist", w * 0.5, cy, 260, 220, {
            color: toColor(PALETTE.inkMist), opacity: 0.34 + frac * 0.22, layer: 0,
        });

        // 中文大写计数（零、壹、贰……玖拾玖、壹佰）
        const numZh = toChineseUpper(countNum);
        texts.put("title", numZh, w * 0.5, cy + 4, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 10, 0.38 + frac * 0.60);
        drawBrushDivider(uiInkDraw, art, "gate_count_div", w * 0.5, cy - 34, 240, 10, PALETTE.bronzeDim, 0.65, 2);
        texts.put("sm", "城外静候 · 默数至百", w * 0.5, cy - 54, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 3.0, 0.80);

        if (p.countTick >= 1440) {
            const pulse = 0.72 + 0.28 * Math.sin(this.time * 3.8);
            const py = cy - 108;
            fillRadialGlow(uiGlow, w * 0.5, py, 130, 24, toColor(PALETTE.amber, 42 * pulse), Color(212, 164, 102, 0), 14);
            drawInkWashStrip(uiDraw, uiArtSafe(art), "gate_go_strip", w * 0.5, py, 300, 42, PALETTE.inkWarm, 0.86, true, 1);
            drawBrushDivider(uiInkDraw, art, "gate_go_top", w * 0.5, py + 17, 220, 8, PALETTE.amber, 0.65 * pulse, 2);
            drawBrushDivider(uiInkDraw, art, "gate_go_bot", w * 0.5, py - 17, 220, 8, PALETTE.amber, 0.65 * pulse, 2);
            const prompt = p.countPrevMove > 0 ? "先松开方向键，再按 [D]" : "按 [D] · 独自向北";
            texts.put("sm", prompt, w * 0.5, py, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.6, 1);
        }
    }

    /**
     * 北塔尾声「登记簿末页」：以真实折痕旧宣纸（ui_paper）为账簿本体，
     * 上书焦墨字迹、朱砂格线与落款官印，还原《饿殍》式古旧行记质感。
     */
    private drawTowerRegistryCard(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        art: AssetSlotHost,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
    ): void {
        const cardW = 548;
        const cardH = 356;
        const cx = (w - cardW) * 0.5;
        const cy = (h - cardH) * 0.5 + 10;
        const midX = w * 0.5;
        const midY = cy + cardH * 0.5;

        // 沉墨暗幕 + 宣纸底柔影
        uiDraw.drawRect(Rect(0, 0, w, h), Color(7, 8, 12, 168));
        art.tryPlace("ink_wash_panel", "reg_shadow", midX, midY - 6, cardW + 52, cardH + 46, {
            color: toColor(PALETTE.voidDark), opacity: 0.85, layer: -1,
        });

        // 铺开完整泛黄折痕古宣纸（缺失时回退陈纸色矩形）
        if (!art.tryPlace("ui_paper", "registry_paper_full", midX, midY, cardW, cardH, { opacity: 0.96, layer: 1 })) {
            uiDraw.drawRect(Rect(cx, cy, cardW, cardH), toColor(PALETTE.xuanPaper, 245), 1.6, toColor(PALETTE.bronzeDim, 210));
        }
        // 微弱宣纸暖灯晕（契合北塔门口提灯）
        fillRadialGlow(uiGlow, midX, midY + 40, 260, 140, Color(235, 196, 130, 18), Color(235, 196, 130, 0), 16);

        // 账册内朱砂细线框（避开旧纸左上/右下卷角暗影，模仿明清红格账簿）
        const padX = 60;
        const padY = 44;
        const inX = cx + padX;
        const inY = cy + padY;
        const inW = cardW - padX * 2;
        const inH = cardH - padY * 2;
        const redLine = toColor(PALETTE.sealRed, 145);
        const redLineFaint = toColor(PALETTE.sealRed, 82);

        uiInkDraw.drawRect(Rect(inX, inY, inW, inH), Color(0, 0, 0, 0), 1.25, redLine);
        uiInkDraw.drawRect(Rect(inX + 4, inY + 4, inW - 8, inH - 8), Color(0, 0, 0, 0), 0.7, redLineFaint);

        // 账册天头：北塔入塔登记簿 · 末页 + 朱砂官印
        const headY = inY + inH - 26;
        texts.put("md", "北塔入塔登记簿 · 末页", inX + 18, headY, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 1.6, 0.96, 0);
        drawSealStamp(uiInkDraw, art, texts, "reg_top_seal", inX + inW - 28, headY, 28, "塔", PALETTE.sealRed, PALETTE.sealText, 0.90, true, 4);
        uiInkDraw.drawSegment(Vec2(inX + 12, headY - 22), Vec2(inX + inW - 12, headY - 22), 1.1, redLine);

        // 肆拾壹：小满入塔记录（纸上焦墨字，彻底透明描边）
        const row1Y = headY - 52;
        texts.put("sm", "肆拾壹  小满 · 持黄铜指南针与纸条 · 已入塔", inX + 18, row1Y, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 0.5, 0.96, 0);
        texts.put("xs", "附注：护送者留守南城门，托她独自走完余路。", inX + 18, row1Y - 27, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.4, 0.92, 0);
        uiInkDraw.drawSegment(Vec2(inX + 14, row1Y - 46), Vec2(inX + inW - 14, row1Y - 46), 0.85, redLineFaint);

        // 肆拾贰：标志性空行（留给周戍 / 下一位守望者）
        const blankY = row1Y - 74;
        const pulse = 0.66 + 0.34 * Math.sin(this.time * 2.4);
        texts.put("sm", "肆拾贰", inX + 18, blankY, toColor(PALETTE.sealRed), 0, 0.5, TextAlign.Left, 0.6, 0.94, 0);
        uiInkDraw.drawSegment(Vec2(inX + 88, blankY - 7), Vec2(inX + inW - 108, blankY - 7), 1.15, toColor(PALETTE.xuanInkSub, 175 * pulse));
        texts.put("xs", "（空行留待）", inX + inW - 98, blankY, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.6, 0.86 * pulse, 0);

        // 尾声落款：向西守望 + 朱砂小印
        if (p.phase === "tower-end") {
            const signY = inY + 38;
            texts.put("banner", "向西守望", midX - 18, signY, toColor(PALETTE.xuanInk), 0.5, 0.5, TextAlign.Center, 6.0, 0.94, 0);
            drawOvalSeal(uiInkDraw, art, texts, "reg_end_seal", midX + 86, signY, 24, 42, "守", "望", PALETTE.sealRed, PALETTE.sealText, 0.92, 4);

            // 纸页外下方安静的操作指引
            drawInkWashStrip(uiDraw, art, "reg_hint_bg", midX, cy - 28, 340, 34, PALETTE.inkWash, 0.78, true, 0);
            texts.put("xs", "[E] 再次启程     ·     [ESC] 暂歇", midX, cy - 28, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.2, 0.95);
        }
    }

    private drawAreaBanner(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        art: AssetSlotHost,
        texts: TextPool,
        roomKey: string,
        w: number,
        h: number,
    ): void {
        const theme = themeOf(roomKey);
        const t = this.bannerT / this.bannerMax;
        // 快入缓停如烟淡散
        let alpha = 1;
        if (t > 0.82) {
            alpha = (1 - t) / 0.18;
        } else if (t < 0.28) {
            alpha = t / 0.28;
        }
        const cx = w * 0.5;
        const cy = h * 0.77;
        const spread = Math.min(1, alpha * 1.15);

        // 水墨飞白横幅底 + 枯笔墨线
        drawInkWashStrip(uiDraw, art, "banner_ink", cx, cy + 4, 460 * spread + 60, 74, PALETTE.inkWash, 0.78 * alpha, true, -1);
        drawBrushDivider(uiInkDraw, art, "banner_line", cx, cy - 18, 340 * spread, 12, theme.accent, 0.78 * alpha, 2);

        // 拆分「主地名 · 副题」，中间以一枚手绘朱砂/古铜墨点衔接（避免毛笔字体缺间隔号）
        const sep = " · ";
        const idx = theme.titleZh.indexOf(sep);
        const sealCol = roomKey === "gate" ? PALETTE.sealRed : PALETTE.cinnabarDeep;
        if (idx > 0) {
            const leftPart = theme.titleZh.slice(0, idx);
            const rightPart = theme.titleZh.slice(idx + sep.length);
            const lw = visualTextWidth(leftPart, 38);
            const rw = visualTextWidth(rightPart, 38);
            const dotGap = 24;
            const totalW = lw + rw + dotGap;
            const leftEdge = cx + 16 - totalW * 0.5;
            const dotX = leftEdge + lw + dotGap * 0.5;

            drawSealStamp(uiInkDraw, art, texts, "banner_seal", leftEdge - 24, cy + 14, 32, theme.numeralZh, sealCol, PALETTE.sealText, alpha, true, 4);
            texts.put("banner", leftPart, leftEdge, cy + 14, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 2.0, alpha);
            art.tryPlace("ink_dot", "banner_mid_dot", dotX, cy + 12, 9, 9, {
                color: toColor(roomKey === "gate" ? PALETTE.sealRedBright : PALETTE.amber), opacity: 0.92 * alpha, layer: 4,
            });
            texts.put("banner", rightPart, dotX + dotGap * 0.5, cy + 14, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 2.0, alpha);
        } else {
            const titleW = visualTextWidth(theme.titleZh, 38);
            drawSealStamp(uiInkDraw, art, texts, "banner_seal", cx - titleW * 0.5 - 24, cy + 14, 32, theme.numeralZh, sealCol, PALETTE.sealText, alpha, true, 4);
            texts.put("banner", theme.titleZh, cx + 10, cy + 14, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 3.0, alpha);
        }
        texts.put("xs", theme.volumeTagZh, cx, cy - 34, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 2.2, 0.86 * alpha);
    }
}

function uiArtSafe(art: AssetSlotHost): AssetSlotHost {
    return art;
}
