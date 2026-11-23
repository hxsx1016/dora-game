/**
 * 《向西守望》宋明清雅水墨菜单体系（V2 · 《饿殍》风流婉转美学）：
 * - 标题页：龙藏体瘦逸竖排主标题「向西守望」+ 唯一文人孤印「守望」+ 右起错落古画竖排题诗 + 无盒新致宋菜单与水袖飞白；
 * - 选章页：「千里驿道长卷」+ 单幅月窗大图画笺（柔和烟边、诗意引语、8 驿站游丝时间轴）；
 * - 操作说明：极简通透「双栏素笺」（去滚轴去方盒，一缕竖烟丝与海棠结轻分周戍/小满）；
 * - 局内暂停：左侧通天垂落「烟黛纱幔」（去土黄居中卷轴盒，保留右侧月夜实景）。
 *
 * 完整保留键鼠双通道操作（W/S/↑/↓/A/D、Enter/Space、Esc 与鼠标悬停/点击）。
 */

import { Color, DrawNode, Keyboard, KeyName, Rect, TextAlign, Vec2 } from "Dora";
import { ROOMS } from "Script/watch/rooms";
import { Input } from "Script/watch/input";
import { TextPool } from "Script/watch/fe/ui/textpool";
import { AssetSlotHost, AssetSlotKey } from "Script/watch/fe/assets";
import { StageRenderer } from "Script/watch/fe/renderer/stage";
import {
    PALETTE,
    drawBlossomDot,
    drawFiligreeCorners,
    drawHairline,
    drawLoneSeal,
    drawMistCurve,
    drawSilkKeycap,
    drawSilkRibbon,
    drawSilkVeil,
    fillHGradRect,
    fillRadialGlow,
    fillVGradRect,
    themeOf,
    toColor,
    visualTextWidth,
} from "Script/watch/fe/theme";

export type ScreenKind = "title" | "chapters" | "controls" | "play";

export interface MenuAction {
    type: "none" | "start" | "jump" | "resume" | "retry" | "toTitle" | "openChapters" | "openControls" | "backTitle";
    roomIndex?: number;
}

const TITLE_ITEMS = [
    { id: "start", zh: "开始游戏" },
    { id: "chapters", zh: "选择章节" },
    { id: "controls", zh: "操作说明" },
];

const PAUSE_ITEMS = [
    { id: "resume", zh: "继续游戏" },
    { id: "retry", zh: "重试检查点" },
    { id: "chapters", zh: "选择章节" },
    { id: "title", zh: "返回标题" },
];

const VERTICAL_TITLE = ["向", "西", "守", "望"];
// 古画题跋：右列先读、左列错落低两格，去现代标点改用呼吸留空
const EPIGRAPH_RIGHT = ["城", "破", "那", "天", "", "他", "留", "下", "断", "后"];
const EPIGRAPH_LEFT = ["她", "独", "自", "走", "向", "北", "塔"];

export class MenuRenderer {
    selected = 0;
    chapterSelected = 0;
    pauseSelected = 0;
    private prevUp = false;
    private prevDown = false;
    private prevLeft = false;
    private prevRight = false;
    private prevEnter = false;
    private prevClick = false;
    private queuedUp = false;
    private queuedDown = false;
    private queuedLeft = false;
    private queuedRight = false;
    private queuedConfirm = false;
    private queuedBack = false;
    private time = 0;

    onKeyEvent(key: KeyName): void {
        if (key === KeyName.Up || key === KeyName.W) {
            this.queuedUp = true;
        } else if (key === KeyName.Down || key === KeyName.S) {
            this.queuedDown = true;
        } else if (key === KeyName.Left || key === KeyName.A) {
            this.queuedLeft = true;
        } else if (key === KeyName.Right || key === KeyName.D) {
            this.queuedRight = true;
        } else if (key === KeyName.Return || key === KeyName.Space) {
            this.queuedConfirm = true;
        } else if (key === KeyName.Escape) {
            this.queuedBack = true;
        }
    }

    private readMenuKeys(): { up: boolean; down: boolean; left: boolean; right: boolean; confirm: boolean; back: boolean } {
        const u = Keyboard.isKeyPressed(KeyName.Up) || Keyboard.isKeyPressed(KeyName.W);
        const d = Keyboard.isKeyPressed(KeyName.Down) || Keyboard.isKeyPressed(KeyName.S);
        const l = Keyboard.isKeyPressed(KeyName.Left) || Keyboard.isKeyPressed(KeyName.A);
        const r = Keyboard.isKeyPressed(KeyName.Right) || Keyboard.isKeyPressed(KeyName.D);
        const e = Keyboard.isKeyPressed(KeyName.Return) || Keyboard.isKeyPressed(KeyName.Space);
        const res = {
            up: (u && !this.prevUp) || this.queuedUp,
            down: (d && !this.prevDown) || this.queuedDown,
            left: (l && !this.prevLeft) || this.queuedLeft,
            right: (r && !this.prevRight) || this.queuedRight,
            confirm: (e && !this.prevEnter) || this.queuedConfirm,
            back: this.queuedBack,
        };
        this.prevUp = u;
        this.prevDown = d;
        this.prevLeft = l;
        this.prevRight = r;
        this.prevEnter = e;
        this.queuedUp = false;
        this.queuedDown = false;
        this.queuedLeft = false;
        this.queuedRight = false;
        this.queuedConfirm = false;
        this.queuedBack = false;
        return res;
    }

    private clickEdge(input: Input): boolean {
        const held = input.fire.held;
        const fired = held && !this.prevClick;
        this.prevClick = held;
        return fired;
    }

    updateAndDrawScreen(
        dt: number,
        screen: ScreenKind,
        input: Input,
        stage: StageRenderer,
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        backdropArt: AssetSlotHost,
        uiArt: AssetSlotHost,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
        uiScale: number,
    ): MenuAction {
        this.time += dt;
        const artW = Math.max(w, h * 16 / 9);
        const artH = artW * 9 / 16;
        if (!backdropArt.tryPlace("title_backdrop", "menu_landscape", w * 0.5, (h - artH) * 0.5, artW, artH)) {
            stage.drawMenuBackdrop(bgDraw, bgGlow, w, h, this.time);
        }

        const pointer = Vec2(input.mx / uiScale, input.my / uiScale);
        w /= uiScale;
        h /= uiScale;

        const mk = this.readMenuKeys();
        const clicked = this.clickEdge(input);

        if (screen === "title") {
            return this.drawTitle(mk, clicked, pointer, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h);
        }
        if (screen === "chapters") {
            return this.drawChapters(mk, clicked, input, pointer, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h);
        }
        return this.drawControls(mk, clicked, input, pointer, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h);
    }

    private drawTitle(
        mk: { up: boolean; down: boolean; confirm: boolean },
        clicked: boolean,
        pointer: Vec2.Type,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
    ): MenuAction {
        if (mk.up) {
            this.selected = (this.selected + TITLE_ITEMS.length - 1) % TITLE_ITEMS.length;
        } else if (mk.down) {
            this.selected = (this.selected + 1) % TITLE_ITEMS.length;
        }

        // 左侧轻透鸦青烟纱，右侧完整让出冷月、松影、红布板车与北塔暖灯
        fillHGradRect(uiDraw, 0, 0, w * 0.22, h, Color(9, 11, 18, 192), Color(9, 11, 18, 116));
        fillHGradRect(uiDraw, w * 0.22, 0, w * 0.28, h, Color(9, 11, 18, 116), Color(9, 11, 18, 0));
        fillVGradRect(uiDraw, 0, 0, w, 78, Color(8, 10, 16, 138), Color(8, 10, 16, 0));

        // 标题后一缕婉转淡烟流云 + 左侧纤细竖烟丝
        const titleX = 148;
        const topY = h - 104;
        const charStep = 66;
        const sway = Math.sin(this.time * 0.7) * 5;
        drawMistCurve(uiArt, "title_mist_wisp", titleX + 86 + sway, topY - 122, 340, 82, PALETTE.jadeMist, 0.20, -1);
        uiArt.tryPlace("ink_petal_mist", "title_petals", titleX + 12, topY - 102, 230, 210, {
            color: toColor(PALETTE.inkMist), opacity: 0.40, layer: -1,
        });
        uiArt.tryPlace("ink_vstream", "title_vstream", titleX - 48, topY - 100, 34, 290, {
            color: toColor(PALETTE.silkDim), opacity: 0.48, layer: 1,
        });

        // 龙藏体瘦逸竖排主标题「向西守望」
        let c = 0;
        for (c = 0; c < VERTICAL_TITLE.length; c++) {
            texts.put(
                "title",
                VERTICAL_TITLE[c],
                titleX,
                topY - c * charStep,
                toColor(PALETTE.textBright),
                0.5,
                0.5,
                TextAlign.Center,
                0,
                0.98,
                0.10,
                Color(8, 10, 16, 210),
            );
        }

        // 全屏唯一一枚文人朱砂孤印「守望」
        drawLoneSeal(
            uiInkDraw,
            uiArt,
            texts,
            "title_lone_seal",
            titleX + 46,
            topY - 3 * charStep + 8,
            26,
            52,
            "守",
            "望",
            PALETTE.sealRed,
            PALETTE.sealText,
            0.94,
            4,
        );

        // 古画错落竖排题跋（传统右起先读，疏朗留白，不压右侧人物与北塔）
        const colRightX = titleX + 132;
        const colLeftX = titleX + 102;
        const poemStep = 22;
        let p = 0;
        for (p = 0; p < EPIGRAPH_RIGHT.length; p++) {
            const ch = EPIGRAPH_RIGHT[p];
            if (ch !== "") {
                texts.put("xs", ch, colRightX, topY - 22 - p * poemStep, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 0, 0.86, 0.08);
            }
        }
        for (p = 0; p < EPIGRAPH_LEFT.length; p++) {
            texts.put("xs", EPIGRAPH_LEFT[p], colLeftX, topY - 68 - p * poemStep, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 0, 0.90, 0.08);
        }

        // 无盒清雅宋体菜单（水袖游丝飞白 + 菱花微星，彻底去红方印与厚墨块）
        const menuX = 112;
        const btnW = 280;
        const btnH = 44;
        const gap = 12;
        const startY = 252;
        let hitIdx = -1;

        let i = 0;
        for (i = 0; i < TITLE_ITEMS.length; i++) {
            const by = startY - i * (btnH + gap);
            const hover = pointer.x >= menuX - 10 && pointer.x <= menuX + btnW && pointer.y >= by && pointer.y <= by + btnH;
            if (hover) {
                this.selected = i;
                hitIdx = i;
            }
            const active = this.selected === i;
            const cy = by + btnH * 0.5;
            const shiftX = active ? 10 : 0;

            if (active) {
                const breathe = 0.84 + 0.16 * Math.sin(this.time * 2.2);
                // 柔和胭脂水袖飞白飘带 + 下沿霜月游丝
                drawSilkRibbon(uiDraw, uiArt, "title_rib_red_" + i, menuX + 124, cy, 290, 40, PALETTE.rougeSoft, 0.52 * breathe, 0);
                drawHairline(uiInkDraw, uiArt, "title_rib_line_" + i, menuX + 114, by + 4, 230, PALETTE.silkLine, 0.42 * breathe, false, 2);
                drawBlossomDot(uiInkDraw, uiArt, "title_dot_" + i, menuX + 14, cy, 16, PALETTE.rouge, 0.96, 4);
                fillRadialGlow(uiGlow, menuX + 14, cy, 22, 16, toColor(PALETTE.rouge, 28 * breathe), Color(182, 58, 56, 0), 10);
            } else {
                drawBlossomDot(uiInkDraw, uiArt, "title_dot_" + i, menuX + 14, cy, 8, PALETTE.silkDim, 0.40, 3);
            }

            texts.put(
                "md",
                TITLE_ITEMS[i].zh,
                menuX + 34 + shiftX,
                cy,
                toColor(active ? PALETTE.textBright : PALETTE.textMid),
                0,
                0.5,
                TextAlign.Left,
                active ? 4.4 : 2.8,
                active ? 1.0 : 0.88,
                0.10,
            );
        }

        texts.put("xs", "上下择项   ·   回车或点选启程", menuX + 12, 42, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.4, 0.88, 0.08);

        if (mk.confirm || (clicked && hitIdx >= 0)) {
            const id = TITLE_ITEMS[this.selected].id;
            if (id === "start") {
                return { type: "start" };
            }
            if (id === "chapters") {
                return { type: "openChapters" };
            }
            return { type: "openControls" };
        }
        return { type: "none" };
    }

    /**
     * 选章页 V2：「千里驿道长卷 + 单幅月窗大图画笺」
     * 彻底摒弃八个土黄方盒子，改为上方诗意月窗大图预览 + 下方连绵游丝驿道时间轴。
     */
    private drawChapters(
        mk: { up: boolean; down: boolean; left: boolean; right: boolean; confirm: boolean; back: boolean },
        clicked: boolean,
        input: Input,
        pointer: Vec2.Type,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
    ): MenuAction {
        if (input.pause.pressed || mk.back) {
            return { type: "backTitle" };
        }
        if (mk.left) {
            this.chapterSelected = (this.chapterSelected + ROOMS.length - 1) % ROOMS.length;
        } else if (mk.right) {
            this.chapterSelected = (this.chapterSelected + 1) % ROOMS.length;
        } else if (mk.up || mk.down) {
            this.chapterSelected = (this.chapterSelected + 4) % ROOMS.length;
        }

        // 清冷鸦青全屏轻幕
        uiDraw.drawRect(Rect(0, 0, w, h), Color(10, 12, 19, 198));

        const marginX = 96;
        // 顶部清雅眉题（无红方块，一缕霜月游丝配海棠结）
        texts.put("banner", "千里行纪", marginX, h - 66, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 4.5, 0.96, 0.10);
        texts.put("xs", "双线八驿 · 择章重历", marginX + 196, h - 70, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 2.0, 0.85, 0.08);
        drawHairline(uiInkDraw, uiArt, "chap_top_line", w * 0.5, h - 100, w - marginX * 2, PALETTE.silkDim, 0.60, true, 2);

        // -------- 1. 上方主视区：单幅月窗画笺 + 右侧诗意章目 --------
        const activeRoom = ROOMS[this.chapterSelected];
        const theme = themeOf(activeRoom.key);
        const winX = marginX;
        const winY = 266;
        const winW = 548;
        const winH = 300;
        const winHover = pointer.x >= winX && pointer.x <= winX + winW && pointer.y >= winY && pointer.y <= winY + winH;

        // 柔和墨云底 + 房间画卷实景
        uiArt.tryPlace("ink_frame_mask", "chap_win_shadow", winX + winW * 0.5, winY + winH * 0.5, winW + 40, winH + 34, {
            color: toColor(PALETTE.inkVoid), opacity: 0.88, layer: -2,
        });
        const bgSlot = ("bgFar_" + activeRoom.key) as AssetSlotKey;
        uiArt.tryPlace(bgSlot, "chap_win_art", winX + winW * 0.5, winY + 4, winW - 8, winH - 8, {
            opacity: 0.92, layer: -1,
        });
        // 四周极柔烟边羽化，让像素画卷自然融进夜色（告别生硬裁切盒）
        fillVGradRect(uiInkDraw, winX, winY, winW, 56, Color(10, 12, 19, 200), Color(10, 12, 19, 0));
        fillVGradRect(uiInkDraw, winX, winY + winH - 36, winW, 36, Color(10, 12, 19, 0), Color(10, 12, 19, 130));
        fillHGradRect(uiInkDraw, winX, winY, 34, winH, Color(10, 12, 19, 135), Color(10, 12, 19, 0));
        fillHGradRect(uiInkDraw, winX + winW - 34, winY, 34, winH, Color(10, 12, 19, 0), Color(10, 12, 19, 135));
        // 纤细宋明海棠云肩折角
        drawFiligreeCorners(uiInkDraw, uiArt, "chap_win_frame", winX, winY, winW, winH, winHover ? PALETTE.textBright : PALETTE.silkLine, winHover ? 0.92 : 0.72, 34, true, 3);

        // 画窗左下角静谧章序小注
        texts.put("xs", theme.actCode + "  ·  " + theme.lineTag, winX + 20, winY + 22, toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.8, 0.90, 0.08);

        // 右侧诗意赏析与启程入口
        const infoX = winX + winW + 46;
        const infoCenterY = winY + winH * 0.5;
        drawMistCurve(uiArt, "chap_info_mist", infoX + 210, infoCenterY + 36, 420, 88, theme.accent, 0.22, -1);

        // 卷次眉注
        const volCol = this.chapterSelected < 4 ? PALETTE.cyan : PALETTE.amber;
        texts.put("xs", theme.volumeTagZh, infoX, winY + winH - 44, toColor(volCol), 0, 0.5, TextAlign.Left, 2.8, 0.92, 0.08);

        // 龙藏体大章名（中点以精致菱花点衔接，避开行书缺间隔号）
        const sep = " · ";
        const sIdx = theme.titleZh.indexOf(sep);
        const titleY = winY + winH - 98;
        if (sIdx > 0) {
            const leftPart = theme.titleZh.slice(0, sIdx);
            const rightPart = theme.titleZh.slice(sIdx + sep.length);
            const lw = visualTextWidth(leftPart, 40);
            texts.put("banner", leftPart, infoX, titleY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 2.0, 1, 0.10);
            drawBlossomDot(uiInkDraw, uiArt, "chap_title_dot", infoX + lw + 16, titleY - 2, 11, activeRoom.key === "gate" ? PALETTE.rouge : PALETTE.silkLine, 0.90, 4);
            texts.put("banner", rightPart, infoX + lw + 32, titleY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 2.0, 1, 0.10);
        } else {
            texts.put("banner", theme.titleZh, infoX, titleY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 2.4, 1, 0.10);
        }

        drawHairline(uiInkDraw, uiArt, "chap_info_line", infoX + 185, titleY - 36, 370, PALETTE.silkDim, 0.58, false, 2);

        // 章节诗意引语
        texts.put("sm", theme.introWhisper, infoX, titleY - 72, toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.8, 0.94, 0.08);

        // 启程按钮（纤细水袖飘带 + 菱花微星）
        const goX = infoX;
        const goY = winY + 26;
        const goW = 220;
        const goH = 42;
        const goHover = pointer.x >= goX && pointer.x <= goX + goW && pointer.y >= goY && pointer.y <= goY + goH;
        const breathe = 0.84 + 0.16 * Math.sin(this.time * 2.4);
        drawSilkRibbon(uiDraw, uiArt, "chap_go_rib", goX + 106, goY + 21, 250, 40, goHover ? PALETTE.rouge : PALETTE.rougeSoft, (goHover ? 0.68 : 0.46) * breathe, 0);
        drawHairline(uiInkDraw, uiArt, "chap_go_line", goX + 94, goY + 3, 196, PALETTE.silkLine, goHover ? 0.68 : 0.40, false, 2);
        drawBlossomDot(uiInkDraw, uiArt, "chap_go_dot", goX + 14, goY + 21, 14, PALETTE.rouge, 0.96, 4);
        texts.put("md", "入此卷章", goX + 34, goY + 21, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 3.8, 1, 0.10);
        texts.put("xs", "Enter", goX + 156, goY + 21, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.0, 0.82, 0.08);

        // -------- 2. 下方「千里驿道」八驿游丝长卷轴 --------
        const trackY = 148;
        const trackX0 = marginX + 34;
        const trackX1 = w - marginX - 34;
        const stepX = (trackX1 - trackX0) / (ROOMS.length - 1);

        // 蜿蜒流云墨丝贯通八驿 + 柔边烟纱托底，确保八驿题名与右下石阶背景清晰分离
        drawSilkVeil(uiDraw, uiArt, "chap_track_veil", w * 0.5, trackY + 6, w - marginX * 1.1, 126, PALETTE.inkWash, 0.72, -2);
        drawMistCurve(uiArt, "chap_track_mist", w * 0.5, trackY, trackX1 - trackX0 + 160, 74, PALETTE.inkMist, 0.62, -1);
        uiInkDraw.drawSegment(Vec2(trackX0, trackY), Vec2(trackX1, trackY), 0.9, toColor(PALETTE.silkDim, 145));

        // 上下卷分界微刻（第 4 驿与第 5 驿之间）
        const midDivX = trackX0 + stepX * 3.5;
        uiInkDraw.drawSegment(Vec2(midDivX, trackY - 12), Vec2(midDivX, trackY + 12), 0.8, toColor(PALETTE.silkDim, 120));
        texts.put("xs", "上卷 · 孤城护童", trackX0 + stepX * 1.5, trackY + 52, toColor(PALETTE.cyan), 0.5, 0.5, TextAlign.Center, 2.2, 0.88, 0.08);
        texts.put("xs", "下卷 · 独赴北塔", trackX0 + stepX * 5.5, trackY + 52, toColor(PALETTE.amber), 0.5, 0.5, TextAlign.Center, 2.2, 0.88, 0.08);

        let hitStation = -1;
        let i = 0;
        for (i = 0; i < ROOMS.length; i++) {
            const sx = trackX0 + i * stepX;
            const rt = themeOf(ROOMS[i].key);
            const hover = Math.abs(pointer.x - sx) <= stepX * 0.45 && Math.abs(pointer.y - trackY) <= 46;
            if (hover) {
                this.chapterSelected = i;
                hitStation = i;
            }
            const active = this.chapterSelected === i;
            const nodeCol = active ? PALETTE.rouge : (i < 4 ? PALETTE.cyan : PALETTE.amber);

            if (active) {
                fillRadialGlow(uiGlow, sx, trackY, 26, 26, toColor(PALETTE.rouge, 36 * breathe), Color(182, 58, 56, 0), 12);
                uiArt.tryPlace("ink_enso_fine", "chap_st_ring_" + i, sx, trackY, 32, 32, {
                    color: toColor(PALETTE.silkLine), opacity: 0.78, angle: this.time * 18, layer: 3,
                });
                drawBlossomDot(uiInkDraw, uiArt, "chap_st_dot_" + i, sx, trackY, 17, PALETTE.rouge, 0.98, 4);
            } else {
                uiArt.tryPlace("ink_enso_fine", "chap_st_ring_" + i, sx, trackY, 16, 16, {
                    color: toColor(nodeCol), opacity: 0.62, layer: 3,
                });
                drawBlossomDot(uiInkDraw, uiArt, "chap_st_dot_" + i, sx, trackY, 7, PALETTE.silkLine, 0.72, 4);
            }

            texts.put("xs", rt.numeralZh, sx, trackY + 25, toColor(active ? PALETTE.crimsonCore : PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 0, active ? 1 : 0.88, 0.08);
            texts.put("xs", rt.shortNameZh, sx, trackY - 26, toColor(active ? PALETTE.textBright : PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 1.0, active ? 1 : 0.84, 0.08);
        }

        // 左下返回按钮
        const backX = marginX;
        const backY = 40;
        const backHover = pointer.x >= backX && pointer.x <= backX + 168 && pointer.y >= backY && pointer.y <= backY + 34;
        drawSilkKeycap(uiInkDraw, texts, backX, backY + 5, 44, 24, "ESC", backHover ? PALETTE.rouge : PALETTE.silkDim, 0.92, backHover);
        texts.put("sm", "返回标题", backX + 56, backY + 17, toColor(backHover ? PALETTE.textBright : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.8, 0.90, 0.08);
        texts.put("xs", "← / → 沿驿道阅览   ·   Enter 或点选入章", w - marginX, backY + 17, toColor(PALETTE.textDim), 1, 0.5, TextAlign.Right, 1.2, 0.75, 0.08);

        if (clicked && backHover) {
            return { type: "backTitle" };
        }
        if (mk.confirm || (clicked && (hitStation >= 0 || winHover || goHover))) {
            return { type: "jump", roomIndex: this.chapterSelected };
        }
        return { type: "none" };
    }

    /**
     * 操作说明 V2：「极简通透双栏素笺」（去拟物木滚轴与厚黑盒，一缕竖烟丝轻分周戍与小满）
     */
    private drawControls(
        mk: { confirm: boolean; back: boolean },
        clicked: boolean,
        input: Input,
        pointer: Vec2.Type,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        _uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
    ): MenuAction {
        if (input.pause.pressed || mk.back || mk.confirm) {
            return { type: "backTitle" };
        }
        uiDraw.drawRect(Rect(0, 0, w, h), Color(10, 12, 19, 204));

        const marginX = 96;
        texts.put("banner", "执器要诀", marginX, h - 66, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 4.5, 0.96, 0.10);
        texts.put("xs", "键鼠操作说明", marginX + 196, h - 70, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 2.0, 0.85, 0.08);
        drawHairline(uiInkDraw, uiArt, "ctrl_top_line", w * 0.5, h - 100, w - marginX * 2, PALETTE.silkDim, 0.60, true, 2);

        // 开放式清雅画框（仅四角纤细海棠折角，无封闭粗框、无木滚轴）
        const areaY = 114;
        const areaH = h - 244;
        drawFiligreeCorners(uiInkDraw, uiArt, "ctrl_outer", marginX, areaY, w - marginX * 2, areaH, PALETTE.silkDim, 0.52, 34, false, 2);

        // 中央一缕纤细竖烟丝 + 菱花微星优雅分栏
        const midX = w * 0.5;
        uiArt.tryPlace("ink_vstream", "ctrl_mid_stream", midX, areaY + areaH * 0.5, 32, areaH - 18, {
            color: toColor(PALETTE.silkDim), opacity: 0.52, layer: 1,
        });
        drawBlossomDot(uiInkDraw, uiArt, "ctrl_mid_dot", midX, areaY + areaH * 0.5, 11, PALETTE.silkLine, 0.62, 3);

        // 左栏：周戍
        const leftColX = marginX + 34;
        const colW = midX - leftColX - 42;
        const headY = areaY + areaH - 34;
        drawBlossomDot(uiInkDraw, uiArt, "ctrl_l_dot", leftColX + 8, headY, 12, PALETTE.cyan, 0.88, 3);
        texts.put("md", "周戍 · 护送与交锋", leftColX + 26, headY, toColor(PALETTE.cyanCore), 0, 0.5, TextAlign.Left, 2.4, 0.98, 0.08);
        drawHairline(uiInkDraw, uiArt, "ctrl_l_line", leftColX + colW * 0.5, headY - 24, colW, PALETTE.cyanDim, 0.58, false, 2);

        const sRows: [string, string][] = [
            ["A / D", "左右移动"],
            ["鼠标 + 左键", "瞄准与点射"],
            ["SHIFT 按住", "贴靠柜台 / 街垒挡枪"],
            ["SPACE", "平地翻滚 / 贴矮台翻越"],
            ["E", "递物 / 敲两下安抚 / 按住+D 推车"],
            ["ESC / R", "暂歇 / 从检查点重试"],
        ];
        let i = 0;
        for (i = 0; i < sRows.length; i++) {
            const ry = headY - 66 - i * 52;
            drawSilkKeycap(uiInkDraw, texts, leftColX + 2, ry - 13, 122, 26, sRows[i][0], PALETTE.cyan, 0.92, false);
            texts.put("sm", sRows[i][1], leftColX + 144, ry, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.8, 0.92, 0.08);
        }

        // 右栏：小满
        const rightColX = midX + 44;
        drawBlossomDot(uiInkDraw, uiArt, "ctrl_r_dot", rightColX + 8, headY, 12, PALETTE.amber, 0.88, 3);
        texts.put("md", "小满 · 潜行与寻路", rightColX + 26, headY, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 2.4, 0.98, 0.08);
        drawHairline(uiInkDraw, uiArt, "ctrl_r_line", rightColX + colW * 0.5, headY - 24, colW, PALETTE.amberDim, 0.58, false, 2);

        const cRows: [string, string][] = [
            ["A / D", "潜行行走"],
            ["SHIFT 按住", "轻步慢走（压低脚步声）"],
            ["S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"],
            ["SPACE", "跳跃攀上石阶与矮台"],
            ["E", "拾瓶 / 敲塔门 / 按住+D 拉板车"],
            ["F 按住→松手", "预览落点，投瓶引开拾荒者"],
        ];
        for (i = 0; i < cRows.length; i++) {
            const ry = headY - 66 - i * 52;
            drawSilkKeycap(uiInkDraw, texts, rightColX + 2, ry - 13, 126, 26, cRows[i][0], PALETTE.amber, 0.92, false);
            texts.put("sm", cRows[i][1], rightColX + 148, ry, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.8, 0.92, 0.08);
        }

        // 左下返回按钮
        const backX = marginX;
        const backY = 40;
        const backHover = pointer.x >= backX && pointer.x <= backX + 230 && pointer.y >= backY && pointer.y <= backY + 34;
        drawSilkKeycap(uiInkDraw, texts, backX, backY + 5, 110, 24, "ESC / ENTER", backHover ? PALETTE.rouge : PALETTE.silkDim, 0.92, backHover);
        texts.put("sm", "返回标题", backX + 122, backY + 17, toColor(backHover ? PALETTE.textBright : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.8, 0.92, 0.08);

        if (clicked && backHover) {
            return { type: "backTitle" };
        }
        return { type: "none" };
    }

    /**
     * 局内暂停 V2：「左侧通天烟黛垂纱」（彻底告别屏幕正中土黄卷轴盒！）
     */
    updateAndDrawPause(
        dt: number,
        input: Input,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
        uiScale: number,
    ): MenuAction {
        this.time += dt;
        const pointer = Vec2(input.mx / uiScale, input.my / uiScale);
        const mk = this.readMenuKeys();
        const clicked = this.clickEdge(input);

        if (mk.up) {
            this.pauseSelected = (this.pauseSelected + PAUSE_ITEMS.length - 1) % PAUSE_ITEMS.length;
        } else if (mk.down) {
            this.pauseSelected = (this.pauseSelected + 1) % PAUSE_ITEMS.length;
        }

        // 右侧轻压暗留出月夜定格，左侧垂落通天烟黛半透明纱幔
        uiDraw.drawRect(Rect(0, 0, w, h), Color(8, 10, 16, 102));
        fillHGradRect(uiDraw, 0, 0, w * 0.27, h, Color(9, 11, 18, 232), Color(10, 13, 21, 198));
        fillHGradRect(uiDraw, w * 0.27, 0, w * 0.21, h, Color(10, 13, 21, 198), Color(10, 13, 21, 0));

        // 纱幔内一缕通高细烟丝 + 淡墨云纹
        const menuX = 110;
        uiArt.tryPlace("ink_vstream", "pause_vstream", menuX - 32, h * 0.5, 34, h * 0.78, {
            color: toColor(PALETTE.silkDim), opacity: 0.48, layer: 1,
        });
        drawMistCurve(uiArt, "pause_mist", menuX + 118, h - 154, 290, 72, PALETTE.jadeMist, 0.20, -1);

        // 龙藏体清雅「暂歇」+ 霜月游丝海棠结
        texts.put("banner", "暂歇", menuX + 16, h - 146, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 10.0, 0.98, 0.10);
        texts.put("xs", "月夜暂驻 · 卷页留痕", menuX + 18, h - 184, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 2.0, 0.80, 0.08);
        drawHairline(uiInkDraw, uiArt, "pause_div", menuX + 124, h - 210, 240, PALETTE.silkDim, 0.58, true, 2);

        let hitIdx = -1;
        let i = 0;
        for (i = 0; i < PAUSE_ITEMS.length; i++) {
            const iy = h - 284 - i * 60;
            const iw = 260;
            const ih = 44;
            const hover = pointer.x >= menuX - 10 && pointer.x <= menuX + iw && pointer.y >= iy && pointer.y <= iy + ih;
            if (hover) {
                this.pauseSelected = i;
                hitIdx = i;
            }
            const active = this.pauseSelected === i;
            const cy = iy + ih * 0.5;
            const shiftX = active ? 10 : 0;

            if (active) {
                const breathe = 0.84 + 0.16 * Math.sin(this.time * 2.4);
                drawSilkRibbon(uiDraw, uiArt, "pause_rib_" + i, menuX + 116, cy, 276, 40, PALETTE.rougeSoft, 0.54 * breathe, 0);
                drawHairline(uiInkDraw, uiArt, "pause_line_" + i, menuX + 106, iy + 4, 210, PALETTE.silkLine, 0.42 * breathe, false, 2);
                drawBlossomDot(uiInkDraw, uiArt, "pause_dot_" + i, menuX + 12, cy, 15, PALETTE.rouge, 0.96, 4);
                fillRadialGlow(uiGlow, menuX + 12, cy, 22, 16, toColor(PALETTE.rouge, 26 * breathe), Color(182, 58, 56, 0), 10);
            } else {
                drawBlossomDot(uiInkDraw, uiArt, "pause_dot_" + i, menuX + 12, cy, 8, PALETTE.silkDim, 0.40, 3);
            }

            texts.put(
                "md",
                PAUSE_ITEMS[i].zh,
                menuX + 32 + shiftX,
                cy,
                toColor(active ? PALETTE.textBright : PALETTE.textMid),
                0,
                0.5,
                TextAlign.Left,
                active ? 3.8 : 2.4,
                active ? 1.0 : 0.88,
                0.10,
            );
        }

        texts.put("xs", "Esc 续行   ·   Enter 或点击确认", menuX + 12, 56, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.2, 0.86, 0.08);

        if (mk.confirm || (clicked && hitIdx >= 0)) {
            const id = PAUSE_ITEMS[this.pauseSelected].id;
            if (id === "resume") {
                return { type: "resume" };
            }
            if (id === "retry") {
                return { type: "retry" };
            }
            if (id === "chapters") {
                return { type: "openChapters" };
            }
            return { type: "toTitle" };
        }
        return { type: "none" };
    }
}
