/**
 * 《向西守望》宋明清雅水墨菜单体系（V2 视觉 × 改进键鼠输入状态机）：
 * - 标题页：龙藏体瘦逸竖排主标题「向西守望」+ 唯一文人孤印「守望」+ 右起错落古画竖排题诗 + 无盒新致宋菜单与水袖飞白；
 * - 选章页：关卡预览与可分行的驿站时间轴，支持从暂停往返保留进度；
 * - 操作说明：极简通透「双栏素笺」（去滚轴去方盒，一缕竖烟丝与海棠结轻分周戍/小满）；
 * - 局内暂停：左侧通天垂落「烟黛纱幔」（保留右侧月夜实景，支持 Esc 续行与切页不串键）。
 *
 * 键鼠输入逻辑承接 watch-controls：切页重置旧按键边沿、鼠标未移动时不抢占键盘高亮、仅窗口内按下触发点击。
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
    type: "none" | "start" | "trial" | "jump" | "resume" | "retry" | "toTitle" | "openChapters" | "openControls" | "backTitle" | "backPause";
    roomIndex?: number;
}

const TITLE_ITEMS = [
    { id: "start", zh: "开始游戏" },
    { id: "chapters", zh: "选择章节" },
    { id: "controls", zh: "操作说明" },
    { id: "trial", zh: "护送试炼 · 肉鸽" },
];

// 博物馆由双通关后的井口进入，章节菜单保留公开关卡原有的房间索引。
const CHAPTERS = ROOMS.map((room, roomIndex) => ({ room, roomIndex }))
    .filter(chapter => chapter.room.key !== "museum");

const PAUSE_ITEMS = [
    { id: "resume", zh: "继续游戏" },
    { id: "retry", zh: "重试检查点" },
    { id: "controls", zh: "操作说明" },
    { id: "assist", zh: "按键辅助：关" },
    { id: "chapters", zh: "选择章节" },
    { id: "title", zh: "返回标题" },
];

const VERTICAL_TITLE = ["向", "西", "守", "望"];
// 古画题跋：右列先读、左列错落低两格，去现代标点改用呼吸留空
const EPIGRAPH_RIGHT = ["城", "破", "那", "天", "", "他", "留", "下", "断", "后"];
const EPIGRAPH_LEFT = ["她", "独", "自", "走", "向", "北", "塔"];

interface MenuKeys {
    up: boolean;
    down: boolean;
    left: boolean;
    right: boolean;
    confirm: boolean;
}

interface MenuFrame {
    keys: MenuKeys;
    back: boolean;
    pointer: Vec2.Type;
    inside: boolean;
    click: boolean;
    pointerMoved: boolean;
}

function pressedKeys(): MenuKeys {
    return {
        up: Keyboard.isKeyPressed(KeyName.Up) || Keyboard.isKeyPressed(KeyName.W),
        down: Keyboard.isKeyPressed(KeyName.Down) || Keyboard.isKeyPressed(KeyName.S),
        left: Keyboard.isKeyPressed(KeyName.Left) || Keyboard.isKeyPressed(KeyName.A),
        right: Keyboard.isKeyPressed(KeyName.Right) || Keyboard.isKeyPressed(KeyName.D),
        confirm: Keyboard.isKeyPressed(KeyName.Return) || Keyboard.isKeyPressed(KeyName.Space),
    };
}

function hitIndex(boxes: Rect.Type[], pointer: Vec2.Type, inside: boolean): number {
    if (!inside) {
        return -1;
    }
    return boxes.findIndex(box => box.containsPoint(pointer));
}

export class MenuRenderer {
    selected = 0;
    chapterSelected = 0;
    pauseSelected = 0;
    private chaptersFromPause = false;
    /** 暂停态原地展开双栏素笺操作说明（零侵入 app.ts） */
    private pauseShowControls = false;
    private previousKeys: Partial<MenuKeys> = {};
    private queuedKeys: Partial<MenuKeys> = {};
    private queuedBack = false;
    private time = 0;

    isShowingPauseControls(): boolean {
        return this.pauseShowControls;
    }

    openChapters(roomIndex?: number): void {
        this.chaptersFromPause = roomIndex !== undefined;
        this.chapterSelected = Math.max(0, CHAPTERS.findIndex(chapter => chapter.roomIndex === roomIndex));
        this.pauseShowControls = false;
        this.resetInput();
    }

    openPause(): void {
        this.pauseSelected = 0;
        this.pauseShowControls = false;
        this.resetInput();
    }

    /** 页面切换后，把仍按住的键视为旧输入，避免切页串键。 */
    resetInput(): void {
        this.previousKeys = pressedKeys();
        this.queuedKeys = {};
        this.queuedBack = false;
    }

    /** 锁存两个渲染帧之间的短按。方向键轮询也保留同一份按下边沿。 */
    onKeyEvent(key: KeyName): void {
        if (key === KeyName.Up || key === KeyName.W) {
            this.queuedKeys.up = true;
        } else if (key === KeyName.Down || key === KeyName.S) {
            this.queuedKeys.down = true;
        } else if (key === KeyName.Left || key === KeyName.A) {
            this.queuedKeys.left = true;
        } else if (key === KeyName.Right || key === KeyName.D) {
            this.queuedKeys.right = true;
        } else if (key === KeyName.Return || key === KeyName.Space) {
            this.queuedKeys.confirm = true;
        } else if (key === KeyName.Escape) {
            this.queuedBack = true;
        }
    }

    private readFrame(input: Input, scale: number): MenuFrame {
        const held = pressedKeys();
        const prev = this.previousKeys;
        const queued = this.queuedKeys;
        const frame: MenuFrame = {
            keys: {
                up: queued.up === true || (held.up && !prev.up),
                down: queued.down === true || (held.down && !prev.down),
                left: queued.left === true || (held.left && !prev.left),
                right: queued.right === true || (held.right && !prev.right),
                confirm: queued.confirm === true || (held.confirm && !prev.confirm),
            },
            back: this.queuedBack || input.pause.pressed,
            pointer: Vec2(input.mx / scale, input.my / scale),
            inside: input.inside,
            click: input.inside && input.fire.pressed,
            pointerMoved: input.inside && Math.abs(input.mdx) + Math.abs(input.mdy) >= scale,
        };
        this.previousKeys = held;
        this.queuedKeys = {};
        this.queuedBack = false;
        return frame;
    }

    private verticalSelection(selected: number, boxes: Rect.Type[], frame: MenuFrame): number {
        const hit = hitIndex(boxes, frame.pointer, frame.inside);
        if (frame.click && hit >= 0) {
            return hit;
        }
        if (frame.keys.up) {
            return (selected + boxes.length - 1) % boxes.length;
        }
        if (frame.keys.down) {
            return (selected + 1) % boxes.length;
        }
        return frame.pointerMoved && hit >= 0 && !frame.keys.confirm ? hit : selected;
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

        const frame = this.readFrame(input, uiScale);
        w /= uiScale;
        h /= uiScale;

        if (screen === "title") {
            return this.drawTitle(frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h);
        }
        if (screen === "chapters") {
            return this.drawChapters(frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h);
        }
        return this.drawControls(frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h);
    }

    private drawTitle(
        frame: MenuFrame,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
    ): MenuAction {
        // 左侧轻透鸦青烟纱，右侧完整让出冷月、松影、红布板车、明代人物与北塔暖灯
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

        // 无盒清雅宋体菜单（水袖游丝飞白 + 菱花微星，键盘与鼠标移动仲裁防抢焦）
        const menuX = 112;
        const btnW = 280;
        const btnH = 44;
        const gap = 12;
        const startY = 252;
        const boxes: Rect.Type[] = [];
        let i = 0;
        for (i = 0; i < TITLE_ITEMS.length; i++) {
            boxes.push(Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH));
        }
        this.selected = this.verticalSelection(this.selected, boxes, frame);

        for (i = 0; i < TITLE_ITEMS.length; i++) {
            const by = boxes[i].y;
            const active = this.selected === i;
            const cy = by + btnH * 0.5;
            const shiftX = active ? 10 : 0;

            if (active) {
                const breathe = 0.84 + 0.16 * Math.sin(this.time * 2.2);
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

        const hit = frame.click ? hitIndex(boxes, frame.pointer, frame.inside) : -1;
        if (hit >= 0 || frame.keys.confirm) {
            const idx = hit >= 0 ? hit : this.selected;
            const id = TITLE_ITEMS[idx].id;
            if (id === "trial") return { type: "trial" };
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
     * 保留水墨长卷布局，接入 watch-controls 方向键/鼠标防抢焦与从暂停往返逻辑。
     */
    private drawChapters(
        frame: MenuFrame,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
    ): MenuAction {
        const back: MenuAction = { type: this.chaptersFromPause ? "backPause" : "backTitle" };
        if (frame.back) {
            return back;
        }

        const marginX = 96;
        const splitTrack = CHAPTERS.length > 8;
        const perRow = splitTrack ? Math.ceil(CHAPTERS.length / 2) : CHAPTERS.length;
        const trackY = splitTrack ? 195 : 148;
        const rowGap = 84;
        const trackX0 = marginX + 34;
        const trackX1 = w - marginX - 34;
        const stepX = (trackX1 - trackX0) / Math.max(1, perRow - 1);

        const stationBoxes: Rect.Type[] = [];
        let s = 0;
        for (s = 0; s < CHAPTERS.length; s++) {
            const sx = trackX0 + (s % perRow) * stepX;
            const sy = trackY - Math.floor(s / perRow) * rowGap;
            stationBoxes.push(Rect(sx - stepX * 0.45, sy - 37, stepX * 0.9, 74));
        }

        const hitStation = hitIndex(stationBoxes, frame.pointer, frame.inside);
        const keys = frame.keys;
        if (frame.click && hitStation >= 0) {
            this.chapterSelected = hitStation;
        } else if (keys.left || keys.right || (!splitTrack && (keys.up || keys.down))) {
            const step = keys.left ? -1 : keys.right ? 1 : 4;
            this.chapterSelected = (this.chapterSelected + step + CHAPTERS.length) % CHAPTERS.length;
        } else if (keys.down && this.chapterSelected < perRow) {
            this.chapterSelected = Math.min(CHAPTERS.length - 1, this.chapterSelected + perRow);
        } else if (keys.up && this.chapterSelected >= perRow) {
            this.chapterSelected -= perRow;
        } else if (frame.pointerMoved && hitStation >= 0 && !keys.confirm) {
            this.chapterSelected = hitStation;
        }

        // 清冷鸦青全屏轻幕
        uiDraw.drawRect(Rect(0, 0, w, h), Color(10, 12, 19, 198));

        // 顶部清雅眉题（无红方块，一缕霜月游丝配海棠结）
        texts.put("banner", "选择章节", marginX, h - 66, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 4.5, 0.96, 0.10);
        drawHairline(uiInkDraw, uiArt, "chap_top_line", w * 0.5, h - 100, w - marginX * 2, PALETTE.silkDim, 0.60, true, 2);

        // -------- 1. 上方主视区：单幅月窗画笺 + 右侧诗意章目 --------
        const activeRoom = CHAPTERS[this.chapterSelected].room;
        const theme = themeOf(activeRoom.key);
        const winX = marginX;
        const winY = 266;
        const winW = 548;
        const winH = 300;
        const winBox = Rect(winX, winY, winW, winH);
        const winHover = frame.inside && winBox.containsPoint(frame.pointer);

        // 柔和墨云底 + 房间画卷实景
        uiArt.tryPlace("ink_frame_mask", "chap_win_shadow", winX + winW * 0.5, winY + winH * 0.5, winW + 40, winH + 34, {
            color: toColor(PALETTE.inkVoid), opacity: 0.88, layer: -2,
        });
        const bgSlot = ("bgFar_" + (theme.backdropKey ?? activeRoom.key)) as AssetSlotKey;
        uiArt.tryPlace(bgSlot, "chap_win_art", winX + winW * 0.5, winY + 4, winW - 8, winH - 8, {
            opacity: 0.92, layer: -1,
        });
        // 四周极柔烟边羽化，让像素画卷自然融进夜色
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

        // 新增关卡名有龙藏体未收录的字，使用覆盖完整的正文宋体。
        const sep = " · ";
        const sIdx = theme.titleZh.indexOf(sep);
        const titleY = winY + winH - 98;
        if (theme.backdropKey !== undefined) {
            texts.put("lg", theme.titleZh, infoX, titleY, toColor(PALETTE.textBright));
        } else if (sIdx > 0) {
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
        const goBox = Rect(goX, goY, goW, goH);
        const goHover = frame.inside && goBox.containsPoint(frame.pointer);
        const breathe = 0.84 + 0.16 * Math.sin(this.time * 2.4);
        drawSilkRibbon(uiDraw, uiArt, "chap_go_rib", goX + 106, goY + 21, 250, 40, goHover ? PALETTE.rouge : PALETTE.rougeSoft, (goHover ? 0.68 : 0.46) * breathe, 0);
        drawHairline(uiInkDraw, uiArt, "chap_go_line", goX + 94, goY + 3, 196, PALETTE.silkLine, goHover ? 0.68 : 0.40, false, 2);
        drawBlossomDot(uiInkDraw, uiArt, "chap_go_dot", goX + 14, goY + 21, 14, PALETTE.rouge, 0.96, 4);
        texts.put("md", "入此卷章", goX + 34, goY + 21, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 3.8, 1, 0.10);
        texts.put("xs", "Enter", goX + 156, goY + 21, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.0, 0.82, 0.08);

        // -------- 2. 下方章节时间轴 --------
        drawSilkVeil(uiDraw, uiArt, "chap_track_veil", w * 0.5, trackY + 6, w - marginX * 1.1, 126, PALETTE.inkWash, 0.72, -2);
        drawMistCurve(uiArt, "chap_track_mist", w * 0.5, trackY, trackX1 - trackX0 + 160, 74, PALETTE.inkMist, 0.62, -1);
        uiInkDraw.drawSegment(Vec2(trackX0, trackY), Vec2(trackX1, trackY), 0.9, toColor(PALETTE.silkDim, 145));

        if (splitTrack) {
            const lastX = trackX0 + (CHAPTERS.length - perRow - 1) * stepX;
            uiInkDraw.drawSegment(Vec2(trackX0, trackY - rowGap), Vec2(lastX, trackY - rowGap), 0.9, toColor(PALETTE.silkDim, 145));
        } else {
            const midDivX = trackX0 + stepX * 3.5;
            uiInkDraw.drawSegment(Vec2(midDivX, trackY - 12), Vec2(midDivX, trackY + 12), 0.8, toColor(PALETTE.silkDim, 120));
            texts.put("xs", "上卷 · 孤城护童", trackX0 + stepX * 1.5, trackY + 52, toColor(PALETTE.cyan), 0.5, 0.5, TextAlign.Center, 2.2, 0.88, 0.08);
            texts.put("xs", "下卷 · 独赴北塔", trackX0 + stepX * 5.5, trackY + 52, toColor(PALETTE.amber), 0.5, 0.5, TextAlign.Center, 2.2, 0.88, 0.08);
        }

        let i = 0;
        for (i = 0; i < CHAPTERS.length; i++) {
            const box = stationBoxes[i];
            const sx = box.x + box.width * 0.5;
            const sy = box.y + box.height * 0.5;
            const rt = themeOf(CHAPTERS[i].room.key);
            const active = this.chapterSelected === i;
            const nodeCol = active ? PALETTE.rouge : (i < 4 ? PALETTE.cyan : PALETTE.amber);

            if (active) {
                fillRadialGlow(uiGlow, sx, sy, 26, 26, toColor(PALETTE.rouge, 36 * breathe), Color(182, 58, 56, 0), 12);
                uiArt.tryPlace("ink_enso_fine", "chap_st_ring_" + i, sx, sy, 32, 32, {
                    color: toColor(PALETTE.silkLine), opacity: 0.78, angle: this.time * 18, layer: 3,
                });
                drawBlossomDot(uiInkDraw, uiArt, "chap_st_dot_" + i, sx, sy, 17, PALETTE.rouge, 0.98, 4);
            } else {
                uiArt.tryPlace("ink_enso_fine", "chap_st_ring_" + i, sx, sy, 16, 16, {
                    color: toColor(nodeCol), opacity: 0.62, layer: 3,
                });
                drawBlossomDot(uiInkDraw, uiArt, "chap_st_dot_" + i, sx, sy, 7, PALETTE.silkLine, 0.72, 4);
            }

            if (!splitTrack) {
                texts.put("xs", rt.numeralZh, sx, sy + 25, toColor(active ? PALETTE.crimsonCore : PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 0, active ? 1 : 0.88, 0.08);
            }
            texts.put("xs", rt.shortNameZh, sx, sy - 26, toColor(active ? PALETTE.textBright : PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 1.0, active ? 1 : 0.84, 0.08);
        }

        // 左下返回按钮（由暂停进入时返回暂停，不丢失场景进度）
        const backX = marginX;
        const backY = 40;
        const backBox = Rect(backX, backY, 190, 34);
        const backHover = frame.inside && backBox.containsPoint(frame.pointer);
        drawSilkKeycap(uiInkDraw, texts, backX, backY + 5, 44, 24, "ESC", backHover ? PALETTE.rouge : PALETTE.silkDim, 0.92, backHover);
        texts.put("sm", this.chaptersFromPause ? "返回暂停" : "返回标题", backX + 56, backY + 17, toColor(backHover ? PALETTE.textBright : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.8, 0.90, 0.08);
        texts.put("xs", "方向键选择   ·   回车或点击进入", w - marginX, backY + 17, toColor(PALETTE.textDim), 1, 0.5, TextAlign.Right, 1.2, 0.75, 0.08);

        if (frame.click && backHover) {
            return back;
        }
        if (keys.confirm || (frame.click && (hitStation >= 0 || winHover || goHover))) {
            return { type: "jump", roomIndex: CHAPTERS[this.chapterSelected].roomIndex };
        }
        return { type: "none" };
    }

    /**
     * 操作说明 V2：「极简通透双栏素笺」（去拟物木滚轴与厚黑盒，一缕竖烟丝轻分周戍与小满）
     */
    private drawControls(
        frame: MenuFrame,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        _uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
        backLabel: string = "返回标题",
    ): MenuAction {
        const marginX = 96;
        const backX = marginX;
        const backY = 40;
        const backBox = Rect(backX, backY, 230, 34);
        const backHover = frame.inside && backBox.containsPoint(frame.pointer);
        if (frame.back || frame.keys.confirm || (frame.click && backHover)) {
            return { type: "backTitle" };
        }
        uiDraw.drawRect(Rect(0, 0, w, h), Color(10, 12, 19, 204));

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
            ["WASD / 方向键", "左右、前后自由移动"],
            ["鼠标 + 左键", "瞄准与发射火铳"],
            ["按住 SHIFT", "贴靠柜台 / 街垒挡下铅丸"],
            ["SPACE", "平地滑铲 / 靠近矮柜翻越"],
            ["E", "递物 / 轻敲安抚 / 按住+D 推车"],
            ["ESC / R", "暂歇菜单 / 重试检查点"],
        ];
        let i = 0;
        for (i = 0; i < sRows.length; i++) {
            const ry = headY - 66 - i * 52;
            drawSilkKeycap(uiInkDraw, texts, leftColX + 2, ry - 13, 132, 26, sRows[i][0], PALETTE.cyan, 0.92, false);
            texts.put("sm", sRows[i][1], leftColX + 150, ry, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.8, 0.92, 0.08);
        }

        // 右栏：小满
        const rightColX = midX + 44;
        drawBlossomDot(uiInkDraw, uiArt, "ctrl_r_dot", rightColX + 8, headY, 12, PALETTE.amber, 0.88, 3);
        texts.put("md", "小满 · 潜行与寻路", rightColX + 26, headY, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 2.4, 0.98, 0.08);
        drawHairline(uiInkDraw, uiArt, "ctrl_r_line", rightColX + colW * 0.5, headY - 24, colW, PALETTE.amberDim, 0.58, false, 2);

        const cRows: [string, string][] = [
            ["A / D · ← / →", "左右潜行"],
            ["按住 SHIFT", "轻步慢走（压低脚步声）"],
            ["按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"],
            ["SPACE", "跳跃攀上石阶与矮台"],
            ["E", "拾瓶 / 敲塔门 / 按住+D 拉车"],
            ["F 按住→松开", "瞄准砖地，投瓶引开拾荒者"],
        ];
        for (i = 0; i < cRows.length; i++) {
            const ry = headY - 66 - i * 52;
            drawSilkKeycap(uiInkDraw, texts, rightColX + 2, ry - 13, 132, 26, cRows[i][0], PALETTE.amber, 0.92, false);
            texts.put("sm", cRows[i][1], rightColX + 150, ry, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.8, 0.92, 0.08);
        }

        // 左下返回按钮
        drawSilkKeycap(uiInkDraw, texts, backX, backY + 5, 110, 24, "ESC / ENTER", backHover ? PALETTE.rouge : PALETTE.silkDim, 0.92, backHover);
        texts.put("sm", backLabel, backX + 122, backY + 17, toColor(backHover ? PALETTE.textBright : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.8, 0.92, 0.08);

        return { type: "none" };
    }

    /**
     * 局内暂停 V2：「左侧通天烟黛垂纱」（保留右侧月夜实景 + watch-controls 独占帧输入）
     * 支持原地切换「操作说明」双栏素笺与「按键辅助：关/开」，零侵入 app.ts。
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
        assistHintsEnabled: boolean = false,
        onToggleAssist?: () => void,
    ): MenuAction {
        this.time += dt;
        const frame = this.readFrame(input, uiScale);

        // 原地渲染双栏素笺操作说明：按 Esc / 确认 / 点击返回按钮仅切回暂停菜单列表，绝不串键。
        if (this.pauseShowControls) {
            const ctrlAct = this.drawControls(frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, "返回暂停");
            if (ctrlAct.type === "backTitle") {
                this.pauseShowControls = false;
                this.resetInput();
            }
            return { type: "none" };
        }

        if (frame.back) {
            this.pauseShowControls = false;
            return { type: "resume" };
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

        const boxes: Rect.Type[] = [];
        let i = 0;
        for (i = 0; i < PAUSE_ITEMS.length; i++) {
            boxes.push(Rect(menuX - 10, h - 270 - i * 52, 270, 42));
        }
        this.pauseSelected = this.verticalSelection(this.pauseSelected, boxes, frame);

        for (i = 0; i < PAUSE_ITEMS.length; i++) {
            const iy = boxes[i].y;
            const active = this.pauseSelected === i;
            const cy = iy + 21;
            const shiftX = active ? 10 : 0;
            const item = PAUSE_ITEMS[i];
            const label = item.id === "assist"
                ? (assistHintsEnabled ? "按键辅助：开" : "按键辅助：关")
                : item.zh;

            if (active) {
                const breathe = 0.84 + 0.16 * Math.sin(this.time * 2.4);
                drawSilkRibbon(uiDraw, uiArt, "pause_rib_" + i, menuX + 116, cy, 276, 38, PALETTE.rougeSoft, 0.54 * breathe, 0);
                drawHairline(uiInkDraw, uiArt, "pause_line_" + i, menuX + 106, iy + 3, 210, PALETTE.silkLine, 0.42 * breathe, false, 2);
                drawBlossomDot(uiInkDraw, uiArt, "pause_dot_" + i, menuX + 12, cy, 15, PALETTE.rouge, 0.96, 4);
                fillRadialGlow(uiGlow, menuX + 12, cy, 22, 16, toColor(PALETTE.rouge, 26 * breathe), Color(182, 58, 56, 0), 10);
            } else {
                drawBlossomDot(uiInkDraw, uiArt, "pause_dot_" + i, menuX + 12, cy, 8, PALETTE.silkDim, 0.40, 3);
            }

            texts.put(
                "md",
                label,
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

        const hit = frame.click ? hitIndex(boxes, frame.pointer, frame.inside) : -1;
        if (hit >= 0 || frame.keys.confirm) {
            const idx = hit >= 0 ? hit : this.pauseSelected;
            const id = PAUSE_ITEMS[idx].id;
            if (id === "controls") {
                this.pauseShowControls = true;
                this.resetInput();
                return { type: "none" };
            }
            if (id === "assist") {
                if (onToggleAssist !== undefined) {
                    onToggleAssist();
                }
                this.resetInput();
                return { type: "none" };
            }
            this.pauseShowControls = false;
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
