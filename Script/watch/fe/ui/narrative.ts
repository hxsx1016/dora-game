/**
 * 《向西守望》宋明清雅水墨叙事与高光演出层（V2 · 《饿殍》风流婉转之美）：
 * - 底部柔边烟黛字幕幕 + 上沿霜月游丝与海棠菱花微结（霞鹜新致宋清雅排印，零红方印干扰）；
 * - 切场烟岚流云章名横幅（龙藏体瘦逸行书 + 菱花点隔开）；
 * - 演出 1：城门「数到二十」—— 龙藏体中文大写数字（壹、贰……拾玖、贰拾）渗墨浮现；
 * - 演出 2：北塔尾声「登记簿末页」—— 640×440 高清宋明冷素宣纸页 + 明版朱丝栏 + 新致宋焦墨字 + 文人孤印「守望」。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { GATE_COUNT_END, gateCountAtTick, Play } from "Script/watch/play";
import { GamepadLayout, InputMode } from "Script/watch/controls_config";
import { SafeInsets, ZERO_SAFE_INSETS } from "Script/watch/platform";
import {
    MUTE_SFX_CAPTIONS,
    NEEDLE_NOTE_LINES,
    ScriptDialogueLine,
    dialogueById,
} from "Script/watch/dialogues";
import { FrameEvents } from "Script/watch/fe/adapter";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { getActiveTarget } from "Script/watch/target";
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

    /** 非阻塞剧情对白队列（驱动 D01–D65 + G06 + 可选发现，绝不锁控） */
    private activeLine: ScriptDialogueLine | undefined;
    private activeLineT = 0;
    private queuedLines: ScriptDialogueLine[] = [];
    private triggeredBeats: Record<string, boolean> = {};
    private lastS2BoardOpen = false;
    private lastC1LatchRaised = false;
    private lastCartDocked = false;
    private lastEscortCalming = false;
    private lastFlashSeen = "";
    /** 静音游玩方向性声效字幕（如 [两下轻敲] [砖地脆响]） */
    private muteCaption = "";
    private muteCaptionT = 0;

    onEnterRoom(roomKey: string): void {
        this.lastRoomKey = roomKey;
        this.bannerT = this.bannerMax;
        this.wipeT = 1.0;
        this.activeLine = undefined;
        this.activeLineT = 0;
        this.queuedLines = [];
        this.triggeredBeats = {};
        this.lastS2BoardOpen = false;
        this.lastC1LatchRaised = false;
        this.lastCartDocked = false;
        this.lastEscortCalming = false;
        this.lastFlashSeen = "";
        this.muteCaption = "";
        this.muteCaptionT = 0;
    }

    /** 供外部或自动化验证查询当前正在呈现的剧情对白与静音声效字幕 */
    getActiveDialogue(): { id: string; who: string; text: string; muteCaption: string } {
        return {
            id: this.activeLine !== undefined ? this.activeLine.id : "",
            who: this.activeLine !== undefined ? this.activeLine.who : "",
            text: this.activeLine !== undefined ? this.activeLine.text : "",
            muteCaption: this.muteCaptionT > 0 ? this.muteCaption : "",
        };
    }

    private triggerOnce(beatKey: string, lineIds: string[], replaceCurrent: boolean = false): void {
        if (this.triggeredBeats[beatKey]) {
            return;
        }
        this.triggeredBeats[beatKey] = true;
        if (replaceCurrent) {
            this.activeLine = undefined;
            this.activeLineT = 0;
            this.queuedLines = [];
        }
        let i = 0;
        for (i = 0; i < lineIds.length; i++) {
            const d = dialogueById(lineIds[i]);
            if (d !== undefined) {
                if (this.activeLine === undefined) {
                    this.activeLine = d;
                    this.activeLineT = d.duration;
                } else {
                    this.queuedLines.push(d);
                }
            }
        }
    }

    private showMuteCaption(key: string, duration: number = 1.9): void {
        const txt = MUTE_SFX_CAPTIONS[key];
        if (txt !== undefined && txt !== "") {
            this.muteCaption = txt;
            this.muteCaptionT = duration;
        }
    }

    private stepScriptedBeats(p: Play, events?: FrameEvents, interactPressed: boolean = false): void {
        const key = p.room.key;
        const ox = p.ox;
        const px = p.player.x;

        // 1. 静音方向性声效字幕（基于真实物理/事件反馈，绝不伪造）
        if (events !== undefined) {
            if (events.knockPulse) {
                this.showMuteCaption("knockTwo", 1.8);
            }
            if (events.cartJustDocked) {
                this.showMuteCaption("cartDock", 2.0);
            }
            if (events.bottleLanded) {
                const isBasin = p.flash.indexOf("铁盆") >= 0;
                this.showMuteCaption(isBasin ? "basinRing" : "brickClink", 2.0);
            }
            let ei = 0;
            for (ei = 0; ei < events.rawEvents.length; ei++) {
                const ev = events.rawEvents[ei];
                if (ev.name === "storyBeat" && ev.data["beat"] === "tower_door") {
                    this.showMuteCaption("knockReply", 2.0);
                }
            }
        }
        if (p.flash !== "" && p.flash !== this.lastFlashSeen) {
            this.lastFlashSeen = p.flash;
            if (p.flash.indexOf("枯枝") >= 0) {
                this.showMuteCaption("twigSnap", 1.8);
            } else if (p.flash.indexOf("铁盆") >= 0) {
                this.showMuteCaption("basinRing", 1.8);
            } else if (p.flash.indexOf("砖") >= 0 && key === "village") {
                this.showMuteCaption("brickClink", 1.8);
            }
        }

        // 2. 两下轻敲安抚（S1–C2 与旧 checkpoint 通用）
        const calmingNow = p.escort.state === "calming";
        if (calmingNow && !this.lastEscortCalming) {
            this.showMuteCaption("knockTwo", 2.0);
            this.triggeredBeats["calming_d04"] = false;
            this.triggerOnce("calming_d04", ["D04"], true);
        }
        this.lastEscortCalming = calmingNow;

        // 3. 逐场非阻塞剧情对白（D01–D65 + G06 + 3 处可选发现）
        if (key === "prologue") {
            if (p.phase === "prologue-wake") {
                if (p.introTick < 120) {
                    this.triggerOnce("p0_wake_mom", ["D30"], true);
                } else {
                    this.triggerOnce("p0_wake_dad", ["D31"], true);
                }
            } else if (p.phase === "prologue-shadow") {
                if (p.introTick < 105) {
                    this.triggerOnce("p0_shadow_call", ["D32"], true);
                } else {
                    this.triggerOnce("p0_shadow_raider", ["D33"], true);
                }
            } else if (p.phase === "prologue-escape") {
                this.triggerOnce("p0_shadow_raider", ["D33"]);
                this.triggerOnce("p0_escape_cry", ["D34"]);
            } else if (p.phase === "prologue-hide") {
                // 入柜后收声留给柜外渐远脚步
                if (this.activeLine !== undefined) {
                    this.activeLine = undefined;
                    this.activeLineT = 0;
                    this.queuedLines = [];
                }
            } else if (p.phase === "prologue-wait") {
                this.triggerOnce("p1_call", ["D35", "D36"], true);
            } else if (p.phase === "prologue-give") {
                // P03 占满 3 秒（180 拍），先在特写内播完 D01，切回跟随段再自然续播 D02/D03/D37/D38
                this.triggerOnce("p2_give", ["D01", "D02", "D03", "D37", "D38"], true);
            } else if (p.phase === "prologue-follow") {
                if (px >= ox + 420) {
                    this.triggerOnce("p3_well", ["D21", "D22", "D39"]);
                } else if (px >= ox + 300) {
                    this.triggerOnce("p2_wall", ["D57", "D58"]);
                }
                // 可选发现 01：巷壁纸风车（递物后折返巷口左侧按 E，零阻塞）
                if (interactPressed && px <= ox + 175 && Math.abs(p.player.y) < 20) {
                    this.triggerOnce("opt_pinwheel", ["OPT_PINWHEEL"], true);
                }
            }
            return;
        }

        if (key === "s1-crossroad") {
            if (px < ox + 260) {
                this.triggerOnce("s1_standoff", ["D23", "D24"]);
            } else if (px >= ox + 380 && this.activeLine !== undefined && this.activeLine.id === "D23") {
                // 玩家先一步迈入街口即自然略去未说完的对峙喊话，但不误删战后的 D40/D41
                this.activeLine = undefined;
                this.activeLineT = 0;
                this.queuedLines = [];
            }
            if (px >= ox + 920) {
                this.triggerOnce("s1_after_fight", ["D40", "D41"]);
            }
            return;
        }

        if (key === "s2-drygoods") {
            let boardOpen = false;
            let bi = 0;
            for (bi = 0; bi < p.boxes.length; bi++) {
                if (p.boxes[bi].id === "s2_board_cover" && !p.boxes[bi].hidden) {
                    boardOpen = true;
                    break;
                }
            }
            if (!boardOpen && px >= ox + 290 && px <= ox + 520) {
                this.triggerOnce("s2_hint_board", ["D05"]);
            }
            if (boardOpen && !this.lastS2BoardOpen) {
                this.showMuteCaption("boardDrop", 2.0);
                this.triggerOnce("s2_board_drop", ["D42"], true);
            }
            // 可选发现 02：布行影戏盘（窗板落下后在柜角附近按 E，零阻塞）
            if (boardOpen && interactPressed && px >= ox + 470 && px <= ox + 640 && Math.abs(p.player.y) < 20) {
                this.triggerOnce("opt_shadowdisc", ["OPT_SHADOWDISC"], true);
            }
            this.lastS2BoardOpen = boardOpen;
            return;
        }

        if (key === "s3-archway") {
            if (px >= ox + 660 && p.partner.alive && Math.abs(p.partner.x - px) <= 150) {
                this.triggerOnce("s3_rejoin", ["D06"]);
            }
            return;
        }

        if (key === "c1-yard") {
            if (px >= ox + 220 && px <= ox + 640) {
                this.triggerOnce("c1_enter", ["C1A", "C1B"]);
            }
            const latchRaised = p.run.c1Latch === true;
            if (latchRaised && !this.lastC1LatchRaised) {
                this.showMuteCaption("latchOpen", 2.0);
                this.triggerOnce("c1_latch", ["C1C"], true);
            }
            this.lastC1LatchRaised = latchRaised;
            return;
        }

        if (key === "c2-granary") {
            if (!p.cartDocked && px >= ox + 260) {
                this.triggerOnce("c2_groove", ["D07", "D43"]);
            }
            if (p.cartDocked && !this.lastCartDocked) {
                this.showMuteCaption("latchOpen", 2.0);
                this.triggerOnce("c2_docked", ["D08"], true);
            }
            this.lastCartDocked = p.cartDocked;
            return;
        }

        if (key === "gate") {
            if (p.phase === "gate-idle") {
                this.triggerOnce("g1_winch", ["D09", "D44", "D45", "D59", "D60"]);
            } else if (p.phase === "gate-hold") {
                // 高压守点战不插必读对白，清掉战前闲聊
                if (this.activeLine !== undefined) {
                    this.activeLine = undefined;
                    this.activeLineT = 0;
                    this.queuedLines = [];
                }
            } else if (p.phase === "gate-send") {
                this.triggerOnce("g3_farewell", ["D10", "D25", "D26", "D61", "D62", "D46", "D47", "D12"], true);
            } else if (p.phase === "gate-farewell" || p.phase === "gate-count") {
                // P05 嘱咐与 G01 数到二十由对应演出插件独占字幕，避免双字幕叠加
                if (this.activeLine !== undefined) {
                    this.activeLine = undefined;
                    this.activeLineT = 0;
                    this.queuedLines = [];
                }
            } else if (p.phase === "gate-wait") {
                this.triggerOnce("g4_reunion_call", ["D48", "D49", "D50"], true);
            } else if (p.phase === "gate-hand") {
                if (this.activeLine !== undefined) {
                    this.activeLine = undefined;
                    this.activeLineT = 0;
                    this.queuedLines = [];
                }
            }
            return;
        }

        if (key === "gatepath") {
            this.triggerOnce("g06_north", ["G06A", "G06B", "D51", "D52"]);
            return;
        }

        // 男主线五段护送（escort1..5）：非阻塞背上耳语与工台歇息，终结长达五关的叙事静默
        if (key === "escort1") {
            if (px >= ox + 170 && px <= ox + 460) {
                this.triggerOnce("e1_start", ["E1A", "E1B"]);
            }
            return;
        }

        if (key === "escort2") {
            if (px >= ox + 220 && px <= ox + 520) {
                this.triggerOnce("e2_granary", ["E2A", "E2B"]);
            }
            return;
        }

        if (key === "escort3") {
            if (px >= ox + 440 && px <= ox + 710) {
                this.triggerOnce("e3_bench_rest", ["E3A", "E3B"]);
            }
            if (events !== undefined && events.benchCrafted) {
                this.triggerOnce("e3_bench_crafted", ["E3C"], true);
            }
            return;
        }

        if (key === "escort4") {
            if (px >= ox + 190 && px <= ox + 460) {
                this.triggerOnce("e4_cliff", ["E4A", "E4B"]);
            }
            return;
        }

        if (key === "escort5") {
            if (px >= ox + 180 && px <= ox + 420) {
                this.triggerOnce("e5_dawn", ["E5A", "E5B"]);
            }
            return;
        }

        if (key === "outside") {
            // O3 盐埂风中核对指南针 + 可选发现 03（盐棚檐角贝壳风铃 x=840..940）
            if (px >= ox + 760 && px <= ox + 1020) {
                this.triggerOnce("o3_salt_wind", ["O3_WIND"]);
            }
            if (interactPressed && px >= ox + 830 && px <= ox + 950 && Math.abs(p.player.y) < 20) {
                this.triggerOnce("opt_shell", ["OPT_SHELL"], true);
            }
            return;
        }

        if (key === "village") {
            // V3 排水暗渠石栅安全凹位（ox+550..690）：拾荒者隔栅喝问 D27，按 E 可选回应 D28–D29
            if (p.passed && px >= ox + 550 && px <= ox + 690) {
                this.triggerOnce("v3_grate_ask", ["D27"]);
                if (interactPressed && this.triggeredBeats["v3_grate_ask"]) {
                    this.triggerOnce("v3_grate_reply", ["D28", "D29"], true);
                }
            }
            return;
        }

        if (key === "forest") {
            // F4 溪湾水中见灯（绑定后端 water_lantern 节拍或进入溪湾 x>=1180）+ 可选发现 05（树根洞口拨叶）
            const waterBeat = events !== undefined && events.storyBeats.some((b) => b.beat === "water_lantern");
            if (waterBeat || px >= ox + 1190) {
                this.triggerOnce("f4_creek_lamp", ["F4_CREEK"]);
            }
            if (interactPressed && px >= ox + 300 && px <= ox + 400 && p.player.crouch) {
                this.triggerOnce("opt_hollow", ["OPT_HOLLOW"], true);
            }
            return;
        }

        if (key === "tower") {
            // 可选发现 06：门廊扶正风灯（叩门前于门廊外侧按 E，不抢占 doorX=445±50 叩门热区）
            if (p.phase === "tower-wait" && interactPressed && px >= ox + 300 && px <= ox + 385) {
                this.triggerOnce("opt_lantern", ["OPT_LANTERN"], true);
            } else if (p.phase === "tower-enter") {
                // 推门过渡结束后跨入值夜室，先接门廊应门问话 D14–D15，不提前问姓名
                this.triggerOnce("t2_knock", ["D14", "D15"], true);
            } else if (p.phase === "tower-desk") {
                if (p.storyRoute === "soldier") {
                    this.triggerOnce("t3_soldier_talk", ["D53", "D54", "D16", "D17", "D63", "D64"]);
                } else {
                    this.triggerOnce("t3_child_talk", ["D16", "D17", "D63", "D64", "D18", "D19"]);
                }
            } else if (p.phase === "tower-end" && p.storyRoute === "soldier" && p.phaseTick >= 200) {
                // 等 M03 前段 6.85s 叙事收净后再接团圆尾声对白 D55–D56–D65，零叠字
                this.triggerOnce("t3_reunion_end", ["D55", "D56", "D65"], true);
            }
        }
    }

    update(dt: number, p: Play, events?: FrameEvents, interactPressed: boolean = false): void {
        this.time += dt;
        if (this.lastRoomKey !== p.room.key) {
            this.onEnterRoom(p.room.key);
        }
        if (this.muteCaptionT > 0) {
            this.muteCaptionT = Math.max(0, this.muteCaptionT - dt);
        }
        if (this.activeLine !== undefined) {
            this.activeLineT -= dt;
            if (this.activeLineT <= 0) {
                const next = this.queuedLines.shift();
                this.activeLine = next;
                this.activeLineT = next !== undefined ? next.duration : 0;
            }
        }
        this.stepScriptedBeats(p, events, interactPressed);

        const wantCinema =
            (p.room.key === "prologue" && p.phase === "prologue-give")
            || (p.room.key === "gate" && (p.phase === "gate-farewell" || p.phase === "gate-count" || p.phase === "gate-wait" || p.phase === "gate-hand"))
            || p.reloadOpen
            || ((p.room.key === "tower" || p.room.key === "museum") && p.phase !== "tower-wait");
        const target = wantCinema ? 1 : 0;
        this.letterbox += (target - this.letterbox) * Math.min(1, dt * 4.5);

        // 北塔一旦叩门入场，立刻清掉入房章名横幅，防止 door_open 交回控制权后误重现「终章 · 北塔守望」
        if (p.room.key === "tower" && p.phase !== "tower-wait") {
            this.bannerT = 0;
        }
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
        assistHintsEnabled: boolean = true,
        inputMode: InputMode = "kbm",
        gamepadLayout: GamepadLayout = "xbox",
        safe: SafeInsets = ZERO_SAFE_INSETS,
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
            this.drawTowerRegistryCard(uiDraw, uiInkDraw, uiGlow, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout);
        }

        // 4. 底部《饿殍》风烟黛渐变旁白长幕 + 上沿霜月海棠结
        if (!p.paused && !showRegistry) {
            this.drawSubtitleStrip(uiDraw, uiInkDraw, art, texts, p, w, h, assistHintsEnabled, inputMode, gamepadLayout, safe);
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

    /**
     * 过场插件接管画面（cutsceneHandled === true）时的专用剧本对白与静音声效字幕通道：
     * - 只在当前过场阶段未由插件独占底部字幕时透出 activeLine（P01/P02/P03/G05/M03 尾声），
     * - 绝不叠加常规战斗 HUD、章名横幅或按键教学，确保 Wave 2 对白（D01–D65）与过场视觉零互吞、零叠字。
     */
    drawCutsceneDialogue(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        art: AssetSlotHost,
        texts: TextPool,
        p: Play,
        w: number,
        h: number,
        safe: SafeInsets = ZERO_SAFE_INSETS,
    ): void {
        if (p.paused) {
            return;
        }
        const key = p.room.key;
        const allowDialogue =
            (key === "prologue"
                && (p.phase === "prologue-wake"
                    || p.phase === "prologue-shadow"
                    || p.phase === "prologue-escape"
                    || p.phase === "prologue-give"))
            || (key === "gate" && p.phase === "gate-wait")
            || (key === "tower" && p.phase === "tower-end" && p.storyRoute === "soldier" && p.phaseTick >= 200);

        const cx = w * 0.5;
        const cy = (key === "gate" && p.phase === "gate-wait" ? 68 : 42) + safe.bottom * 0.5;

        if (this.muteCaptionT > 0 && this.muteCaption !== "") {
            const capAlpha = Math.min(1, this.muteCaptionT * 2.5);
            const capY = cy + 44;
            drawSilkVeil(uiDraw, art, "cut_mute_veil", cx, capY, 172, 26, PALETTE.inkWarm, 0.76 * capAlpha, 0);
            texts.put("xs", this.muteCaption, cx, capY, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.4, 0.94 * capAlpha, 0.08);
        }

        if (!allowDialogue || this.activeLine === undefined) {
            return;
        }
        const spoken = this.activeLine.who !== ""
            ? (this.activeLine.who + "：「" + this.activeLine.text + "」")
            : this.activeLine.text;
        const cue = this.activeLine.who === "周戍" ? "兄"
            : (this.activeLine.who === "小满" ? "妹" : "");
        const urgent = this.activeLine.urgent === true;
        const hasCue = cue !== "";
        const textW = visualTextWidth(spoken, 18);
        const contentW = textW + (hasCue ? 48 : 0);
        const stripW = Math.min(w - 72 - safe.left - safe.right, Math.max(500, contentW + 180));
        const stripH = 50;

        drawSilkVeil(uiDraw, art, "cut_sub_veil", cx, cy, stripW, stripH, urgent ? PALETTE.inkWarm : PALETTE.inkWash, 0.86, 2);
        drawHairline(uiInkDraw, art, "cut_sub_top", cx, cy + 21, stripW * 0.72, urgent ? PALETTE.rouge : PALETTE.silkDim, urgent ? 0.72 : 0.52, true, 3);
        if (hasCue) {
            const startX = cx - contentW * 0.5;
            const cueCol = urgent ? PALETTE.rouge : (p.childMode ? PALETTE.amber : PALETTE.cyan);
            drawBlossomDot(uiInkDraw, art, "cut_cue_dot", startX + 6, cy - 1, 10, cueCol, 0.94, 4);
            texts.put("xs", cue, startX + 24, cy - 1, toColor(urgent ? PALETTE.crimsonCore : cueCol), 0.5, 0.5, TextAlign.Center, 0, 0.96, 0.08);
            uiInkDraw.drawSegment(Vec2(startX + 38, cy - 8), Vec2(startX + 38, cy + 6), 0.75, toColor(PALETTE.silkDim, 115));
            texts.put("sm", spoken, startX + 48, cy - 1, toColor(urgent ? PALETTE.crimsonCore : PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.9, 0.98, 0.08);
        } else {
            texts.put("sm", spoken, cx, cy - 1, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 1.0, 0.98, 0.08);
        }
    }

    private isKeyHintSegment(seg: string): boolean {
        return seg.indexOf("按 E") >= 0
            || seg.indexOf("点 E") >= 0
            || seg.indexOf("按住 E") >= 0
            || seg.indexOf("按 F") >= 0
            || seg.indexOf("按住 F") >= 0
            || seg.indexOf("按 Shift") >= 0
            || seg.indexOf("按 Ctrl") >= 0
            || seg.indexOf("A/D") >= 0
            || seg.indexOf("限时") >= 0
            || seg.indexOf("E 再玩") >= 0
            || seg.indexOf("E 拉开") >= 0
            || seg.indexOf("E 敲") >= 0
            || seg.indexOf("E 递") >= 0
            || seg.indexOf("E 送") >= 0
            || seg.indexOf("E 交") >= 0
            || seg.indexOf("E 拿") >= 0
            || seg.indexOf("E 开") >= 0
            || seg.indexOf("E 选") >= 0
            || seg.indexOf("按 1") >= 0;
    }

    /** 拆分复合 flashSet 中的「纯叙事状态句」与「按键/倒计时教学段」，低引导下只去按键段不连坐叙事句 */
    private stripKeyHintClause(fl: string): string {
        if (!this.isKeyHintSegment(fl)) {
            return fl;
        }
        const parts = fl.split(" · ");
        if (parts.length <= 1) {
            return "";
        }
        const kept: string[] = [];
        let i = 0;
        for (i = 0; i < parts.length; i++) {
            const seg = parts[i].trim();
            if (seg !== "" && !this.isKeyHintSegment(seg)) {
                kept.push(seg);
            }
        }
        return kept.join(" · ");
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
        inputMode: InputMode,
        gamepadLayout: GamepadLayout,
        safe: SafeInsets,
    ): void {
        const cx = w * 0.5;
        const touchLift = inputMode === "touch" && this.letterbox <= 0.4 ? 22 : 0;
        const cy = (this.letterbox > 0.4 ? 36 : 42) + touchLift + safe.bottom * 0.5;

        // 静音方向性声效微标（位于底幕正上方，不阻塞操作）
        if (this.muteCaptionT > 0 && this.muteCaption !== "") {
            const capAlpha = Math.min(1, this.muteCaptionT * 2.5);
            const capY = cy + 44;
            drawSilkVeil(uiDraw, art, "mute_sfx_veil", cx, capY, 172, 26, PALETTE.inkWarm, 0.76 * capAlpha, 0);
            texts.put("xs", this.muteCaption, cx, capY, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.4, 0.94 * capAlpha, 0.08);
        }

        const rawLine = this.composeNarrativeLine(p, assistHintsEnabled);
        if (rawLine.text === "") {
            return;
        }
        const line = {
            cue: rawLine.cue,
            text: assistHintsEnabled ? getActiveTarget().adaptHintSentence(rawLine.text, inputMode, gamepadLayout) : rawLine.text,
            urgent: rawLine.urgent,
        };
        const hasCue = line.cue !== "";
        const textW = visualTextWidth(line.text, 18);
        const contentW = textW + (hasCue ? 48 : 0);
        const stripW = Math.min(w - 72 - safe.left - safe.right, Math.max(540, contentW + 210));
        const stripH = 54;

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
            // 默认低引导：优先呈现非阻塞剧情对白（D01–D65 + G06），绝不泄露按键教学
            if (this.activeLine !== undefined) {
                const spoken = this.activeLine.who !== ""
                    ? (this.activeLine.who + "：「" + this.activeLine.text + "」")
                    : this.activeLine.text;
                const cue = this.activeLine.who === "周戍" ? "兄"
                    : (this.activeLine.who === "小满" ? "妹" : "");
                return { cue, text: spoken, urgent: this.activeLine.urgent === true };
            }
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
            if (p.flash !== "" && p.flashT > 0 && p.flash !== "翻滚结束") {
                // 严格低引导红线：仅剔除显式按键与倒计时子句，保留复合闪字中的纯叙事状态（如「周戍蹲到柜边」「守满了」「两下轻叩」）
                const cleanFlash = this.stripKeyHintClause(p.flash);
                if (cleanFlash !== "") {
                    const isDanger = cleanFlash.indexOf("中弹") >= 0 || cleanFlash.indexOf("被抓") >= 0 || cleanFlash.indexOf("击倒") >= 0 || cleanFlash.indexOf("看见") >= 0 || cleanFlash.indexOf("追") >= 0;
                    let text = cleanFlash;
                    let cue = isDanger ? "危" : (p.childMode ? "潜" : "战");
                    if (key === "tower" || key === "prologue") {
                        cue = "";
                    }
                    if (text === "命中") {
                        text = "倭寇击倒";
                    } else if (text === "打空") {
                        text = "铅丸偏离或被掩体阻挡";
                    } else if (text === "翻滚") {
                        text = "伏身滑铲";
                    }
                    return { cue, text, urgent: isDanger };
                }
            }
            if (p.childMode && key === "outside" && p.checkpoint < p.room.arch.x1) {
                const text = !p.cartDocked ? "红布车右边伸着车柄，前面是个空车窝。"
                    : (p.player.y > p.room.arch.y + 1 ? "车轮落进窝里，左边的石阶通向拱下。"
                        : "拱下的铁栓收起来了，伏低身子就能过去。");
                return { cue: "", text, urgent: false };
            }
            if (p.childMode && key === "tower") {
                if (p.phase === "tower-wait") return { cue: "", text: "木门里透出灯光。她还记得那两声叩门。", urgent: false };
                if (p.phase === "tower-enter") return { cue: "", text: "守卒让开门槛，值夜桌上摊着登记簿。", urgent: false };
                if (p.phase === "tower-desk") return { cue: "", text: "守卒伸过手来，等她放下针套、指南针和纸条。", urgent: false };
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

        if (this.activeLine !== undefined) {
            const spoken = this.activeLine.who !== ""
                ? (this.activeLine.who + "：「" + this.activeLine.text + "」")
                : this.activeLine.text;
            const cue = this.activeLine.who === "周戍" ? "兄"
                : (this.activeLine.who === "小满" ? "妹" : "");
            return { cue, text: spoken, urgent: this.activeLine.urgent === true };
        }

        if (p.flash !== "" && p.flashT > 0 && p.flash !== "翻滚结束") {
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
                text = "伏身滑铲";
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
                if (p.gripping || p.cartHandleInReach()) {
                    return { cue: "", text: "按住 [E]+[D]，把红布车拉进右侧车窝", urgent: false };
                }
                const text = p.player.y < p.room.cart.baseY - 25
                    ? "沿左侧石阶上台，去找红布车右柄"
                    : (p.player.x > p.cartAxle + p.room.cart.handleOffset ? "向左走回红布车右柄" : "向右走到红布车的右柄");
                return { cue: "", text, urgent: false };
            }
            if (p.checkpoint < p.room.arch.x1) {
                const text = p.player.y > p.room.arch.y + 1
                    ? "车轮落窝了。往左返回石阶，下到地面"
                    : "在石阶底按住 [CTRL]，蹲着向右穿过矮拱";
                return { cue: "潜", text, urgent: false };
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
                return { cue: "", text: "走到木门前，按 [E] 叩门", urgent: false };
            }
            if (p.phase === "tower-knock") {
                return { cue: "", text: "咚、咚。她照着他教过的节奏，敲响了北塔的门。", urgent: false };
            }
            if (p.phase === "tower-enter") {
                return { cue: "", text: "门开了。向右跨过门槛，走到值夜桌前", urgent: false };
            }
            if (p.phase === "tower-desk") {
                return { cue: "", text: "走到值夜桌前，按住 [E] 交出针套、指南针和纸条", urgent: false };
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
        inputMode: InputMode,
        gamepadLayout: GamepadLayout,
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
        const reunion = (p.endingLines.length >= 2 && p.endingLines[1] !== "") || p.storyRoute === "soldier";
        const row1Y = headY - 56;
        texts.put("sm", "肆拾壹   小满 · 持黄铜指南针与纸条 · 已入塔", inX + 20, row1Y, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 0.8, 0.94, 0);
        texts.put(
            "xs",
            reunion ? "附注：兄妹并肩抵塔；怀铜针、手书一纸。" : ("附注：" + NEEDLE_NOTE_LINES[0] + " —— " + NEEDLE_NOTE_LINES[1]),
            inX + 20,
            row1Y - 28,
            toColor(PALETTE.xuanInkSub),
            0,
            0.5,
            TextAlign.Left,
            0.6,
            0.88,
            0,
        );
        uiInkDraw.drawSegment(Vec2(inX + 16, row1Y - 48), Vec2(inX + inW - 16, row1Y - 48), 0.65, redSilkFaint);

        // 肆拾贰：团圆线写满周戍，单人线留白待归（不盖完成章）
        const blankY = row1Y - 80;
        const pulse = 0.66 + 0.34 * Math.sin(this.time * 2.2);
        if (reunion) {
            texts.put("sm", "肆拾贰   周戍 · 兄妹同行 · 已入塔", inX + 20, blankY, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 0.8, 0.94, 0);
            texts.put("xs", "附注：门内断后脱身，同抵北塔值夜室。", inX + 20, blankY - 26, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.6, 0.86, 0);
        } else {
            texts.put("sm", "肆拾贰", inX + 20, blankY, toColor(PALETTE.rouge), 0, 0.5, TextAlign.Left, 1.0, 0.92, 0);
            uiInkDraw.drawSegment(Vec2(inX + 94, blankY - 7), Vec2(inX + inW - 116, blankY - 7), 0.95, toColor(PALETTE.xuanInkSub, 155 * pulse));
            texts.put("xs", "（空行留待）", inX + inW - 104, blankY, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 1.0, 0.82 * pulse, 0);
        }

        // 尾声落款：龙藏体「向西守望」+ 唯一文人孤印「守望」
        if (p.phase === "tower-end") {
            const signY = inY + 46;
            texts.put("banner", "向西守望", midX - 18, signY, toColor(PALETTE.xuanInk), 0.5, 0.5, TextAlign.Center, 6.5, 0.92, 0);
            drawLoneSeal(uiInkDraw, art, texts, "reg_lone_seal", midX + 86, signY, 22, 42, "守", "望", PALETTE.sealRed, PALETTE.sealText, 0.92, 4);

            drawSilkVeil(uiDraw, art, "reg_hint_veil", midX, cy - 28, 390, 32, PALETTE.inkWash, 0.72, 0);
            const rawEndHint = assistHintsEnabled
                ? (inputMode === "kbm" ? "按 E / 左键继续     ·     Esc 暂歇" : "按 E 再次启程     ·     Esc 暂歇")
                : "Esc 暂歇";
            const endHint = getActiveTarget().adaptHintSentence(rawEndHint, inputMode, gamepadLayout);
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
        if (theme.backdropKey !== undefined) {
            texts.put("lg", theme.titleZh, cx, cy + 14, toColor(PALETTE.textBright),
                0.5, 0.5, TextAlign.Center, 1.0, alpha, 0.10);
        } else if (idx > 0) {
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
