/**
 * 《向西守望》宋明清雅水墨叙事与高光演出层（V2 · 《饿殍》风流婉转之美）：
 * - 底部柔边烟黛字幕幕 + 上沿霜月游丝与海棠菱花微结（霞鹜新致宋清雅排印，零红方印干扰）；
 * - 切场烟岚流云章名横幅（龙藏体瘦逸行书 + 菱花点隔开）；
 * - 演出 1：城门「数到二十」—— 龙藏体中文大写数字（壹、贰……拾玖、贰拾）渗墨浮现；
 * - 演出 2：北塔尾声「登记簿末页」—— 640×440 高清宋明冷素宣纸页 + 明版朱丝栏 + 新致宋焦墨字 + 文人孤印「守望」。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { GATE_COUNT_END, gateCountAtTick, Play } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { TextPool } from "Script/watch/fe/ui/textpool";
import {
    PALETTE,
    drawBlossomDot,
    drawHairline,
    drawLoneSeal,
    drawMistCurve,
    drawSilkRibbon,
    drawSilkVeil,
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
        assistHintsEnabled: boolean = false,
    ): void {
        // 1. 电影遮幅（极轻霜丝边）
        if (this.letterbox > 0.01) {
            const barH = Math.round(70 * this.letterbox);
            uiDraw.drawRect(Rect(0, h - barH, w, barH), Color(8, 10, 16, 242));
            uiDraw.drawRect(Rect(0, 0, w, barH), Color(8, 10, 16, 242));
            uiInkDraw.drawSegment(Vec2(0, h - barH), Vec2(w, h - barH), 0.7, toColor(PALETTE.silkDim, 70 * this.letterbox));
            uiInkDraw.drawSegment(Vec2(0, barH), Vec2(w, barH), 0.7, toColor(PALETTE.silkDim, 70 * this.letterbox));
        }

        // 2. 城门「数到二十」清雅水墨暗角与龙藏体中文大写计数
        if (p.room.key === "gate" && p.phase === "gate-count") {
            this.drawGateCountOverlay(uiDraw, uiInkDraw, art, texts, p, w, h);
        }

        // 3. 北塔尾声「登记簿末页」高清冷素宣纸页
        const showRegistry = p.room.key === "tower" && (p.phase === "tower-end" || (p.phase === "tower-given" && p.phaseTick >= 120));
        if (showRegistry) {
            this.drawTowerRegistryCard(uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled);
        }

        // 4. 底部《饿殍》风烟黛渐变旁白长幕 + 上沿霜月海棠结
        if (!p.paused && !showRegistry) {
            this.drawSubtitleStrip(uiDraw, uiInkDraw, art, texts, p, w, h, assistHintsEnabled);
        }

        // 5. 切场烟岚行书区域标题卡
        if (this.bannerT > 0 && !p.paused) {
            this.drawAreaBanner(uiDraw, uiInkDraw, art, texts, p.room.key, w, h);
        }

        // 6. 房间切换烟墨舒卷转场
        if (this.wipeT > 0.01) {
            const k = Math.min(1, this.wipeT * 1.15);
            const a = Math.round(255 * k * k);
            uiDraw.drawRect(Rect(0, 0, w, h), Color(9, 11, 17, a));
            art.tryPlace("ink_petal_mist", "wipe_mist", w * 0.5, h * 0.5, w * 0.65, h * 0.65, {
                color: toColor(PALETTE.inkMist), opacity: 0.20 * this.wipeT, layer: 5,
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
        assistHintsEnabled: boolean,
    ): void {
        const line = this.composeNarrativeLine(p, assistHintsEnabled);
        if (line.text === "") {
            return;
        }
        const hasCue = line.cue !== "";
        const textW = visualTextWidth(line.text, 18);
        const contentW = textW + (hasCue ? 48 : 0);
        const stripW = Math.min(w - 72, Math.max(540, contentW + 210));
        const stripH = 54;
        const cx = w * 0.5;
        const cy = this.letterbox > 0.4 ? 36 : 42;

        // 丝绒般柔边烟黛长幕
        drawSilkVeil(uiDraw, art, "sub_veil", cx, cy, stripW, stripH, line.urgent ? PALETTE.inkWarm : PALETTE.inkWash, 0.84, -1);
        // 上沿霜月游丝 + 中央宋明海棠菱花微结
        const railCol = line.urgent ? PALETTE.rouge : PALETTE.silkDim;
        drawHairline(uiInkDraw, art, "sub_top_line", cx, cy + 23, stripW * 0.72, railCol, line.urgent ? 0.72 : 0.52, true, 2);

        if (hasCue) {
            const startX = cx - contentW * 0.5;
            const cueCol = line.urgent ? PALETTE.rouge : (p.childMode ? PALETTE.amber : PALETTE.cyan);
            drawBlossomDot(uiInkDraw, art, "sub_cue_dot", startX + 6, cy - 1, 10, cueCol, 0.94, 4);
            texts.put("xs", line.cue, startX + 24, cy - 1, toColor(line.urgent ? PALETTE.crimsonCore : cueCol), 0.5, 0.5, TextAlign.Center, 0, 0.96, 0.08);
            uiInkDraw.drawSegment(Vec2(startX + 38, cy - 8), Vec2(startX + 38, cy + 6), 0.75, toColor(PALETTE.silkDim, 115));
            texts.put("sm", line.text, startX + 48, cy - 1, toColor(line.urgent ? PALETTE.crimsonCore : PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.9, 0.98, 0.08);
        } else {
            texts.put("sm", line.text, cx, cy - 1, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.0, 0.98, 0.08);
        }
    }

    /** 将后端状态译作清雅克制的古风旁白；默认低引导下屏蔽按键教学与催促文案，开「按键辅助」后恢复 */
    private composeNarrativeLine(p: Play, assistHintsEnabled: boolean): { cue: string; text: string; urgent: boolean } {
        const key = p.room.key;
        const theme = themeOf(key);

        if (key === "gate" && p.phase === "gate-count") {
            if (p.countTick >= GATE_COUNT_END) {
                return {
                    cue: "",
                    text: "……二十了。我往北去了。",
                    urgent: false,
                };
            }
            return { cue: "", text: "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent: false };
        }

        if (!assistHintsEnabled) {
            // 默认低引导：只保留纯剧情台词、状态事件与即时战斗结果反馈，彻底关闭 [W/S]/[SHIFT]/[E]/[CTRL]/[F] 操作引导
            if (key === "prologue" && p.phase === "prologue-give") {
                return { cue: "", text: "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent: false };
            }
            if (key === "checkpoint" && p.escort.state === "calming") {
                return { cue: "", text: "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent: false };
            }
            if (key === "tower") {
                if (p.phase === "tower-knock") {
                    return { cue: "", text: "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent: false };
                }
                if (p.phase === "tower-given") {
                    return { cue: "", text: "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent: false };
                }
            }
            if (p.flash !== "" && p.flashT > 0) {
                // 过滤后端 flash 里含显式按键指令的引导句（如「按 E」「按 F」「按 Shift」），仅留即时结果反馈
                const hasKeyHint = p.flash.indexOf("按 E") >= 0
                    || p.flash.indexOf("按 F") >= 0
                    || p.flash.indexOf("按 Shift") >= 0
                    || p.flash.indexOf("按 Ctrl") >= 0
                    || p.flash.indexOf("E 再玩") >= 0;
                if (!hasKeyHint) {
                    const isDanger = p.flash.indexOf("中弹") >= 0 || p.flash.indexOf("被抓") >= 0 || p.flash.indexOf("击倒") >= 0 || p.flash.indexOf("看见") >= 0 || p.flash.indexOf("追") >= 0;
                    let text = p.flash;
                    let cue = isDanger ? "危" : (p.childMode ? "潜" : "战");
                    if (key === "tower" || key === "prologue") {
                        cue = "";
                    }
                    if (text === "命中") {
                        text = "倭寇击倒";
                    } else if (text === "打空") {
                        text = "铅丸偏离或被掩体阻挡";
                    } else if (text === "翻滚") {
                        text = "伏身翻滚回避";
                    }
                    return { cue, text, urgent: isDanger };
                }
            }
            return { cue: "", text: "", urgent: false };
        }

        if (key === "gate" && p.phase === "gate-hold") {
            let threatened = false;
            let hasAliveEnemy = false;
            let i = 0;
            for (i = 0; i < p.enemies.length; i++) {
                if (p.enemies[i].alive) {
                    hasAliveEnemy = true;
                    if (p.enemies[i].warnT > 0) {
                        threatened = true;
                    }
                }
            }
            if (threatened) {
                return { cue: "警", text: "倭寇举铳瞄准 —— 贴住街垒按住 [SHIFT] 挡下，或左键先手击倒", urgent: true };
            }
            if (p.coverHug) {
                if (hasAliveEnemy && !p.coverBlocking) {
                    return { cue: "警", text: "此侧背向来敌，无法挡弹 —— 贴靠街垒左侧按住 [SHIFT]", urgent: true };
                }
                return { cue: "掩", text: "已贴靠掩体。左键发射火铳压制来敌，守满四十五秒", urgent: false };
            }
            return { cue: "守", text: "靠近街垒按住 [SHIFT] 贴掩体，左键发铳守住城门", urgent: false };
        }

        if (key === "gate" && p.phase === "gate-count") {
            if (p.countTick >= GATE_COUNT_END) {
                return {
                    cue: "",
                    text: "……二十了。我往北去了。",
                    urgent: false,
                };
            }
            return { cue: "", text: "铁门合拢了。她在门外安静地数着数，等里面的人出来……", urgent: false };
        }

        if (p.flash !== "" && p.flashT > 0) {
            const isDanger = p.flash.indexOf("中弹") >= 0 || p.flash.indexOf("被抓") >= 0 || p.flash.indexOf("击倒") >= 0 || p.flash.indexOf("看见") >= 0 || p.flash.indexOf("追") >= 0;
            let text = p.flash;
            let cue = isDanger ? "危" : (p.childMode ? "潜" : "战");
            if (key === "tower" || key === "prologue") {
                cue = "";
            }
            if (text === "命中") {
                text = "倭寇击倒 —— 继续推进并留意掩体";
            } else if (text === "打空") {
                text = "铅丸偏离或被掩体阻挡";
            } else if (text === "翻滚") {
                text = "伏身翻滚回避";
            }
            return { cue, text, urgent: isDanger };
        }

        if (key === "prologue") {
            if (p.phase === "prologue-wait") {
                return { cue: "", text: "按住 [W] 向里走，绕过石柱和倒柜，再用 [S] 靠近小满", urgent: false };
            }
            if (p.phase === "prologue-give") {
                return { cue: "", text: "他把纸条仔细塞进指南针皮套里，递到她手里。", urgent: false };
            }
            return { cue: "", text: "带小满往右，从两根门柱之间穿过", urgent: false };
        }

        if (key === "street") {
            let alive = 0;
            let i = 0;
            for (i = 0; i < p.enemies.length; i++) {
                if (p.enemies[i].alive) { alive += 1; }
            }
            if (alive > 0) {
                return { cue: "战", text: "前方有倭寇。鼠标瞄准，左键发射火铳，按 [W/S] 绕开柜台", urgent: false };
            }
            return { cue: "", text: "带小满穿过右侧门洞，进入检查站", urgent: false };
        }

        if (key === "checkpoint") {
            if (p.escort.state === "frozen") {
                return { cue: "危", text: "铳声吓住了小满，她蹲在原地不走了 —— 走近按 [E] 敲两下安抚她", urgent: true };
            }
            if (p.escort.state === "calming") {
                return { cue: "", text: "咚、咚。敲两下 —— 这是只属于两个人的暗号。", urgent: false };
            }
            if (!p.cartDocked) {
                return { cue: "机", text: "清障并护送小满穿过检查站，按住 [E]+[D] 把红布板车推入装卸窝", urgent: false };
            }
            return { cue: "归", text: "车轮落窝了。带小满从右侧门洞出去", urgent: false };
        }

        if (key === "gate") {
            if (p.phase === "gate-idle") {
                return {
                    cue: p.gateNeedConfirm ? "警" : "",
                    text: p.gateNeedConfirm ? "倒地后已退回绞盘。按 [E] 确认重新就位，再守四十五秒" : "小满正走向门洞等待点。走到左侧绞盘就位，守住最后四十五秒",
                    urgent: p.gateNeedConfirm,
                };
            }
            if (p.phase === "gate-send") {
                return { cue: "", text: "四十五秒守满了。走到右侧城门边，按 [E] 把小满送出城去", urgent: false };
            }
            return { cue: "", text: "她迈出了第一步。沿着门外小道向前，离开这座沦陷的城", urgent: false };
        }

        if (key === "outside") {
            if (!p.cartDocked) {
                return { cue: "", text: "上层装卸台停着那辆系着红布的板车。按住 [E]+[D] 拉入空窝，让开下层拱洞", urgent: false };
            }
            if (p.checkpoint < p.room.arch.x1) {
                return { cue: "潜", text: "沿左侧石阶下到地面，按住 [CTRL] 蹲伏穿过矮拱洞", urgent: false };
            }
            return { cue: "", text: "穿过矮拱，沿墙根小路向北塔灯火前行", urgent: false };
        }

        if (key === "village") {
            if (p.scavChase) {
                return { cue: "危", text: "拾荒者追上来了！按住 [CTRL] 钻进桌底甩开视线", urgent: true };
            }
            if (p.passed) {
                return { cue: "", text: "越过了第一院。继续向右，走进通往北塔的森林", urgent: false };
            }
            if (p.hasBottle) {
                return { cue: "诱", text: "按住 [F] 瞄准右侧砖地，松开投瓶 —— 引开拾荒者后按 [CTRL] 钻过桌下", urgent: false };
            }
            if (p.bottleFly !== undefined) {
                return { cue: "潜", text: "瓶子正落向砖地，屏息等拾荒者被声响引开", urgent: false };
            }
            if (p.scavState === "turn" || p.scavState === "walk" || p.scavState === "stall") {
                return { cue: "潜", text: "拾荒者循声走开了 —— 趁隙按住 [CTRL] 钻过桌下", urgent: false };
            }
            return { cue: "", text: "废村院里游荡着拾荒者。走到瓶架旁按 [E] 拾瓶，设法引开他", urgent: false };
        }

        if (key === "forest") {
            if (p.dogState === "chase") {
                return { cue: "危", text: "猎犬追上来了 —— 速按 [CTRL] 蹲进草丛匿迹！", urgent: true };
            }
            if (p.dogState === "ear") {
                return { cue: "警", text: "猎犬竖起了耳朵 —— 立刻按住 [CTRL] 蹲下别出声！", urgent: true };
            }
            return { cue: "", text: "林间有猎犬巡逻。按住 [SHIFT] 轻步慢走或 [CTRL] 伏低，绕开猎犬抵达北塔", urgent: false };
        }

        if (key === "tower") {
            if (p.phase === "tower-wait") {
                return { cue: "", text: "北塔的灯终于近在眼前。走到门廊前，按 [E] 敲两下", urgent: false };
            }
            if (p.phase === "tower-knock") {
                return { cue: "", text: "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent: false };
            }
            if (p.phase === "tower-given") {
                return { cue: "", text: "门开了。提灯的守卫接过指南针与纸条，翻开了登记簿最后一页。", urgent: false };
            }
            return { cue: "", text: "抵达北塔。按 [E] 重新开始一段新的守望，或按 [ESC] 打开菜单", urgent: false };
        }

        return { cue: "", text: theme.introWhisper, urgent: false };
    }

    private drawGateCountOverlay(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        art: AssetSlotHost,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
    ): void {
        const frac = Math.min(1, p.countTick / GATE_COUNT_END);
        const countNum = gateCountAtTick(p.countTick);
        uiDraw.drawRect(Rect(0, 0, w, h), Color(7, 9, 15, Math.round(78 + frac * 116)));

        const cy = h * 0.56;
        art.tryPlace("ink_petal_mist", "gate_count_mist", w * 0.5, cy, 290, 220, {
            color: toColor(PALETTE.inkMist), opacity: 0.34 + frac * 0.20, layer: 0,
        });
        drawMistCurve(art, "gate_count_wisp", w * 0.5, cy - 8, 420, 76, PALETTE.jadeMist, 0.22, 0);

        const numZh = toChineseUpper(countNum);
        texts.put("title", numZh, w * 0.5, cy + 8, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 12, 0.42 + frac * 0.56, 0.10);
        drawHairline(uiInkDraw, art, "gate_count_div", w * 0.5, cy - 34, 240, PALETTE.silkDim, 0.62, true, 2);
        texts.put("sm", "城外静候 · 默数至二十", w * 0.5, cy - 58, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 3.4, 0.84, 0.08);


    }

    /**
     * 北塔尾声「登记簿末页」V2：
     * 使用 640×440 高清冷素宣纸页（ink_song_paper，冷调素月灰白 + 对折书页柔影 + 远山淡墨暗纹）
     * 搭配极细明版朱丝栏、新致宋焦墨清字与一枚文人孤印「守望」，彻底告别发糊土黄羊皮纸。
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
        assistHintsEnabled: boolean,
    ): void {
        const cardW = 588;
        const cardH = 382;
        const cx = (w - cardW) * 0.5;
        const cy = (h - cardH) * 0.5 + 10;
        const midX = w * 0.5;
        const midY = cy + cardH * 0.5;

        // 鸦青静夜暗幕 + 宣纸底柔影
        uiDraw.drawRect(Rect(0, 0, w, h), Color(7, 9, 15, 174));
        art.tryPlace("ink_frame_mask", "reg_shadow", midX, midY - 6, cardW + 58, cardH + 50, {
            color: toColor(PALETTE.voidDark), opacity: 0.82, layer: -1,
        });

        // 640×440 高清冷素宣书页
        if (!art.tryPlace("ink_song_paper", "registry_song_paper", midX, midY, cardW, cardH, { opacity: 0.98, layer: 1 })) {
            uiDraw.drawRect(Rect(cx, cy, cardW, cardH), toColor(PALETTE.xuanPaper, 246), 1.0, toColor(PALETTE.silkDim, 180));
        }
        fillRadialGlow(uiGlow, midX, midY + 46, 240, 130, Color(235, 224, 202, 14), Color(235, 224, 202, 0), 14);

        // 明版朱丝栏（极细暗胭脂单线外框 + 舒朗横栏）
        const padX = 46;
        const padY = 36;
        const inX = cx + padX;
        const inY = cy + padY;
        const inW = cardW - padX * 2;
        const inH = cardH - padY * 2;
        const redSilk = toColor(PALETTE.rouge, 118);
        const redSilkFaint = toColor(PALETTE.rouge, 64);

        uiInkDraw.drawRect(Rect(inX, inY, inW, inH), Color(0, 0, 0, 0), 0.9, redSilk);
        uiInkDraw.drawRect(Rect(inX + 4, inY + 4, inW - 8, inH - 8), Color(0, 0, 0, 0), 0.55, redSilkFaint);

        // 天头：北塔入塔登记簿 · 末页
        const headY = inY + inH - 28;
        texts.put("md", "北塔入塔登记簿 · 末页", inX + 20, headY, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 2.4, 0.94, 0);
        texts.put("xs", "守望行记", inX + inW - 20, headY, toColor(PALETTE.xuanInkSub), 1, 0.5, TextAlign.Right, 2.0, 0.78, 0);
        uiInkDraw.drawSegment(Vec2(inX + 14, headY - 22), Vec2(inX + inW - 14, headY - 22), 0.85, redSilk);

        // 肆拾壹：小满入塔记录（新致宋焦墨字，零黑边）
        const row1Y = headY - 56;
        texts.put("sm", "肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", inX + 20, row1Y, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 0.8, 0.94, 0);
        texts.put("xs", "附注：护送者留守南城门，托她独自走完余路。", inX + 20, row1Y - 28, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.6, 0.88, 0);
        uiInkDraw.drawSegment(Vec2(inX + 16, row1Y - 48), Vec2(inX + inW - 16, row1Y - 48), 0.65, redSilkFaint);

        // 肆拾贰：标志性空行（留给周戍）
        const blankY = row1Y - 80;
        const pulse = 0.66 + 0.34 * Math.sin(this.time * 2.2);
        texts.put("sm", "肆拾贰", inX + 20, blankY, toColor(PALETTE.rouge), 0, 0.5, TextAlign.Left, 1.0, 0.92, 0);
        uiInkDraw.drawSegment(Vec2(inX + 94, blankY - 7), Vec2(inX + inW - 116, blankY - 7), 0.95, toColor(PALETTE.xuanInkSub, 155 * pulse));
        texts.put("xs", "（空行留待）", inX + inW - 104, blankY, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 1.0, 0.82 * pulse, 0);

        // 尾声落款：龙藏体「向西守望」+ 唯一文人孤印「守望」
        if (p.phase === "tower-end") {
            const signY = inY + 46;
            texts.put("banner", "向西守望", midX - 18, signY, toColor(PALETTE.xuanInk), 0.5, 0.5, TextAlign.Center, 6.5, 0.92, 0);
            drawLoneSeal(uiInkDraw, art, texts, "reg_lone_seal", midX + 86, signY, 22, 42, "守", "望", PALETTE.sealRed, PALETTE.sealText, 0.92, 4);

            drawSilkVeil(uiDraw, art, "reg_hint_veil", midX, cy - 28, 360, 32, PALETTE.inkWash, 0.72, 0);
            const endHint = assistHintsEnabled ? "按 E 再次启程     ·     Esc 暂歇" : "Esc 暂歇";
            texts.put("xs", endHint, midX, cy - 28, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 1.6, 0.92, 0.08);
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
        let alpha = 1;
        if (t > 0.82) {
            alpha = (1 - t) / 0.18;
        } else if (t < 0.28) {
            alpha = t / 0.28;
        }
        const cx = w * 0.5;
        const cy = h * 0.77;
        const spread = Math.min(1, alpha * 1.15);

        // 烟岚流云曲线 + 轻柔烟幕 + 霜月游丝
        drawSilkVeil(uiDraw, art, "banner_veil", cx, cy - 2, 480 * spread + 100, 92, PALETTE.inkWash, 0.76 * alpha, -1);
        drawMistCurve(art, "banner_mist", cx, cy + 4, 460 * spread, 72, theme.accent, 0.28 * alpha, 0);
        drawHairline(uiInkDraw, art, "banner_line", cx, cy - 16, 320 * spread, PALETTE.silkLine, 0.64 * alpha, false, 2);

        // 龙藏体瘦逸行书章名（中间点一枚精致菱花微星，无红方块印）
        const sep = " · ";
        const idx = theme.titleZh.indexOf(sep);
        const dotCol = roomKey === "gate" ? PALETTE.rouge : PALETTE.silkLine;
        if (idx > 0) {
            const leftPart = theme.titleZh.slice(0, idx);
            const rightPart = theme.titleZh.slice(idx + sep.length);
            const lw = visualTextWidth(leftPart, 42);
            const rw = visualTextWidth(rightPart, 42);
            const dotGap = 28;
            const totalW = lw + rw + dotGap;
            const leftEdge = cx - totalW * 0.5;
            const dotX = leftEdge + lw + dotGap * 0.5;

            texts.put("banner", leftPart, leftEdge, cy + 14, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 2.0, alpha, 0.10);
            drawBlossomDot(uiInkDraw, art, "banner_mid_dot", dotX, cy + 12, 11, dotCol, 0.92 * alpha, 4);
            texts.put("banner", rightPart, dotX + dotGap * 0.5, cy + 14, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 2.0, alpha, 0.10);
        } else {
            texts.put("banner", theme.titleZh, cx, cy + 14, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 3.0, alpha, 0.10);
        }
        texts.put("xs", theme.actCode + "  ·  " + theme.volumeTagZh, cx, cy - 34, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 2.2, 0.82 * alpha, 0.08);
    }
}
