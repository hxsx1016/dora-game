/**
 * 《向西守望》中国水墨菜单体系（参考《饿殍：明末千里行》美学）：
 * - 标题页：古典竖排书法主标题「向西守望」+ 朱砂腰圆引首章 + 左侧墨烟留白 + 飞白墨刷选框；
 * - 选章页：上卷孤城护童 / 下卷独赴北塔，八房间缩略水墨画笺 + 汉字大写章印（壹~捌）；
 * - 操作说明：双页宣纸卷谱 + 古铜细框键印；
 * - 局内暂停：竖长卷轴墨笺（木轴铜箍 + 四角雕花）。
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
    drawBrushDivider,
    drawInkKeycap,
    drawInkPanel,
    drawInkWashStrip,
    drawOvalSeal,
    drawScrollFrame,
    drawSealStamp,
    fillHGradRect,
    fillRadialGlow,
    fillVGradRect,
    themeOf,
    toColor,
} from "Script/watch/fe/theme";

export type ScreenKind = "title" | "chapters" | "controls" | "play";

export interface MenuAction {
    type: "none" | "start" | "jump" | "resume" | "retry" | "toTitle" | "openChapters" | "openControls" | "backTitle" | "backPause";
    roomIndex?: number;
}

const TITLE_ITEMS = [
    { id: "start", zh: "开始游戏", seal: "启" },
    { id: "chapters", zh: "选择章节", seal: "卷" },
    { id: "controls", zh: "操作说明", seal: "诀" },
];

const PAUSE_ITEMS = [
    { id: "resume", zh: "继续游戏", seal: "续" },
    { id: "retry", zh: "重试检查点", seal: "重" },
    { id: "chapters", zh: "选择章节", seal: "卷" },
    { id: "title", zh: "返回标题", seal: "归" },
];

const VERTICAL_TITLE = ["向", "西", "守", "望"];

export class MenuRenderer {
    selected = 0;
    chapterSelected = 0;
    pauseSelected = 0;
    private prevUp = false;
    private prevDown = false;
    private prevLeft = false;
    private prevRight = false;
    private prevEnter = false;
    private chaptersFromPause = false;
    private pointerActive = false;
    private queuedUp = false;
    private queuedDown = false;
    private queuedLeft = false;
    private queuedRight = false;
    private queuedConfirm = false;
    private queuedBack = false;
    private time = 0;

    openChapters(roomIndex?: number): void {
        this.chaptersFromPause = roomIndex !== undefined;
        this.chapterSelected = roomIndex ?? 0;
        this.resetInput();
    }

    openPause(): void {
        this.pauseSelected = 0;
        this.resetInput();
    }

    /** 页面切换时锁住仍按下的键，避免确认键穿透到下一页。 */
    resetInput(): void {
        this.prevUp = Keyboard.isKeyPressed(KeyName.Up) || Keyboard.isKeyPressed(KeyName.W);
        this.prevDown = Keyboard.isKeyPressed(KeyName.Down) || Keyboard.isKeyPressed(KeyName.S);
        this.prevLeft = Keyboard.isKeyPressed(KeyName.Left) || Keyboard.isKeyPressed(KeyName.A);
        this.prevRight = Keyboard.isKeyPressed(KeyName.Right) || Keyboard.isKeyPressed(KeyName.D);
        this.prevEnter = Keyboard.isKeyPressed(KeyName.Return) || Keyboard.isKeyPressed(KeyName.Space);
        this.queuedUp = this.queuedDown = this.queuedLeft = this.queuedRight = false;
        this.queuedConfirm = this.queuedBack = false;
    }

    /** 由 app.ts 的 onKeyDown 事件锁存短按键，避免低帧率下短按被轮询漏掉 */
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
        return input.inside && input.fire.pressed;
    }

    /** 标题/章节/操作说明的交互更新与渲染 */
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
        this.pointerActive = input.inside && (clicked ||
            (Math.abs(input.mdx) + Math.abs(input.mdy) >= uiScale &&
                !mk.up && !mk.down && !mk.left && !mk.right && !mk.confirm));

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

        // 左侧柔和横向墨烟渐隐，完整让出右侧明月、松林、红布板车与北塔暖灯
        fillHGradRect(uiDraw, 0, 0, w * 0.24, h, Color(10, 11, 16, 198), Color(10, 11, 16, 138));
        fillHGradRect(uiDraw, w * 0.24, 0, w * 0.28, h, Color(10, 11, 16, 138), Color(10, 11, 16, 0));
        fillVGradRect(uiDraw, 0, 0, w, 86, Color(8, 9, 13, 155), Color(8, 9, 13, 0));

        // 古典竖排书法主标题「向西守望」
        const titleX = 152;
        const topY = h - 108;
        const charStep = 64;

        // 标题背后的淡墨晕染与细枯笔竖线
        uiArt.tryPlace("ink_splatter", "title_mist", titleX + 8, topY - 96, 220, 260, {
            color: toColor(PALETTE.inkVoid), opacity: 0.42, layer: -1,
        });
        uiArt.tryPlace("ink_vbrush", "title_vrule_l", titleX - 48, topY - 102, 16, 264, {
            color: toColor(PALETTE.bronzeDim), opacity: 0.56, layer: 1,
        });
        uiArt.tryPlace("ink_vbrush", "title_vrule_r", titleX + 76, topY - 118, 12, 228, {
            color: toColor(PALETTE.bronzeLine), opacity: 0.36, layer: 1,
        });

        let c = 0;
        for (c = 0; c < VERTICAL_TITLE.length; c++) {
            const cy = topY - c * charStep;
            texts.put(
                "title",
                VERTICAL_TITLE[c],
                titleX,
                cy,
                toColor(PALETTE.textBright),
                0.5,
                0.5,
                TextAlign.Center,
                0,
                0.98,
                0.15,
                Color(8, 9, 13, 235),
            );
        }

        // 朱砂腰圆引首章「守望」落于主标题右下侧
        drawOvalSeal(
            uiInkDraw,
            uiArt,
            texts,
            "title_seal",
            titleX + 46,
            topY - 3 * charStep + 10,
            32,
            58,
            "守",
            "望",
            PALETTE.sealRed,
            PALETTE.sealText,
            0.96,
            4,
        );

        // 题跋副句（置于竖标题右侧，疏朗克制，不压迫右侧人物与北塔）
        const epigraphX = titleX + 100;
        texts.put("sm", "城破那天，他留下断后。", epigraphX, topY - 82, toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.0, 0.92);
        texts.put("sm", "她独自走向北塔。", epigraphX, topY - 114, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 1.0, 0.90);
        drawBrushDivider(uiInkDraw, uiArt, "title_epigraph_div", epigraphX + 94, topY - 140, 196, 12, PALETTE.bronzeDim, 0.62, 2);
        texts.put("xs", "双线叙事 · 护送与潜行", epigraphX, topY - 162, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.4, 0.85);

        // 极简水墨菜单列（无科幻黑盒，选中时飞白墨刷铺展 + 朱砂小印落款）
        const menuX = 114;
        const btnW = 304;
        const btnH = 48;
        const gap = 14;
        const startY = 266;
        let hitIdx = -1;

        let i = 0;
        for (i = 0; i < TITLE_ITEMS.length; i++) {
            const by = startY - i * (btnH + gap);
            const hover = pointer.x >= menuX - 10 && pointer.x <= menuX + btnW && pointer.y >= by && pointer.y <= by + btnH;
            if (hover && this.pointerActive) {
                this.selected = i;
                hitIdx = i;
            }
            const active = this.selected === i;
            const cy = by + btnH * 0.5;
            const shiftX = active ? 8 : 0;

            if (active) {
                const breathe = 0.86 + 0.14 * Math.sin(this.time * 2.6);
                // 底层深墨飞白横刷 + 内层暗朱砂微晕
                drawInkWashStrip(uiDraw, uiArt, "title_btn_ink_" + i, menuX + btnW * 0.5 + 4, cy, btnW + 34, btnH + 10, PALETTE.inkWash, 0.84, false, 0);
                drawInkWashStrip(uiDraw, uiArt, "title_btn_red_" + i, menuX + btnW * 0.44 + 4, cy, btnW * 0.84, btnH - 2, PALETTE.cinnabarDeep, 0.46 * breathe, false, 1);
                drawBrushDivider(uiInkDraw, uiArt, "title_btn_line_" + i, menuX + btnW * 0.46, by + 3, btnW * 0.78, 10, PALETTE.bronzeLine, 0.55, 2);
                // 左侧朱砂方印
                drawSealStamp(uiInkDraw, uiArt, texts, "title_btn_seal_" + i, menuX + 18, cy, 26, TITLE_ITEMS[i].seal, PALETTE.sealRed, PALETTE.sealText, 0.96, true, 4);
                fillRadialGlow(uiGlow, menuX + 18, cy, 34, 20, toColor(PALETTE.cinnabar, 36 * breathe), Color(168, 46, 40, 0), 12);
            } else {
                // 未选中：极淡墨点，轻盈透气
                uiArt.tryPlace("ink_dot", "title_btn_dot_" + i, menuX + 18, cy, 9, 9, {
                    color: toColor(PALETTE.bronzeDim), opacity: 0.58, layer: 2,
                });
            }

            texts.put(
                "md",
                TITLE_ITEMS[i].zh,
                menuX + 42 + shiftX,
                cy,
                toColor(active ? PALETTE.amberCore : PALETTE.textMid),
                0,
                0.5,
                TextAlign.Left,
                active ? 3.2 : 2.0,
                active ? 1.0 : 0.88,
            );
        }

        texts.put("xs", "↑ ↓ 择项   ·   Enter 或点击启程", menuX + 8, 46, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 0.8, 0.85);

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
            return { type: this.chaptersFromPause ? "backPause" : "backTitle" };
        }
        if (mk.left) {
            this.chapterSelected = (this.chapterSelected + ROOMS.length - 1) % ROOMS.length;
        } else if (mk.right) {
            this.chapterSelected = (this.chapterSelected + 1) % ROOMS.length;
        } else if (mk.up) {
            this.chapterSelected = (this.chapterSelected + ROOMS.length - 4) % ROOMS.length;
        } else if (mk.down) {
            this.chapterSelected = (this.chapterSelected + 4) % ROOMS.length;
        }

        // 宣纸暗墨全屏轻罩
        uiDraw.drawRect(Rect(0, 0, w, h), Color(11, 12, 17, 178));

        const leftX = 96;
        // 顶部卷首题字 + 朱砂印
        drawSealStamp(uiInkDraw, uiArt, texts, "chap_head_seal", leftX + 18, h - 86, 34, "卷", PALETTE.sealRed, PALETTE.sealText, 0.96, true, 4);
        texts.put("banner", "选择章节", leftX + 48, h - 86, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 4.0, 1);
        texts.put("xs", "双线八幕 · 行纪直达", leftX + 236, h - 90, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.2, 0.88);
        drawBrushDivider(uiInkDraw, uiArt, "chap_head_div", w * 0.5, h - 118, w - leftX * 2, 14, PALETTE.bronzeDim, 0.72, 2);

        const cols = 4;
        const gapX = 22;
        const cardW = Math.min(262, (w - leftX * 2 - (cols - 1) * gapX) / cols);
        const cardH = 140;
        const rowY0 = h * 0.52;
        const rowY1 = h * 0.21;
        let hitIdx = -1;

        // 上下两卷标目（全中文古风，无英文终端符号）
        drawSealStamp(uiInkDraw, uiArt, texts, "vol1_seal", leftX + 12, rowY0 + cardH + 22, 22, "上", PALETTE.cyanDim, PALETTE.moonPale, 0.92, true, 4);
        texts.put("sm", "上卷 · 孤城护童（周戍）", leftX + 30, rowY0 + cardH + 22, toColor(PALETTE.cyanCore), 0, 0.5, TextAlign.Left, 1.2, 0.95);

        drawSealStamp(uiInkDraw, uiArt, texts, "vol2_seal", leftX + 12, rowY1 + cardH + 22, 22, "下", PALETTE.amberDim, PALETTE.amberCore, 0.92, true, 4);
        texts.put("sm", "下卷 · 独赴北塔（小满）", leftX + 30, rowY1 + cardH + 22, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 1.2, 0.95);

        let i = 0;
        for (i = 0; i < ROOMS.length; i++) {
            const col = i % cols;
            const row = Math.floor(i / cols);
            const cx = leftX + col * (cardW + gapX);
            const cy = row === 0 ? rowY0 : rowY1;
            const theme = themeOf(ROOMS[i].key);
            const hover = pointer.x >= cx && pointer.x <= cx + cardW && pointer.y >= cy && pointer.y <= cy + cardH;
            if (hover && this.pointerActive) {
                this.chapterSelected = i;
                hitIdx = i;
            }
            const active = this.chapterSelected === i;

            // 1. 墨云底板
            drawInkPanel(uiDraw, uiArt, "chap_panel_" + i, cx, cy, cardW, cardH, active ? PALETTE.inkWarm : PALETTE.inkWash, active ? 0.94 : 0.82, active, -2);
            // 2. 房间像素场景低明度缩略预览（《饿殍》行纪画笺感）
            const bgSlot = ("bgFar_" + ROOMS[i].key) as AssetSlotKey;
            uiArt.tryPlace(bgSlot, "chap_thumb_" + i, cx + cardW * 0.5, cy + 6, cardW - 12, cardH - 12, {
                opacity: active ? 0.44 : 0.24, layer: -1,
            });
            // 3. 底部渐变墨幕确保文字清晰可读
            fillVGradRect(
                uiInkDraw,
                cx + 4,
                cy + 4,
                cardW - 8,
                cardH * 0.72,
                Color(12, 13, 18, active ? 215 : 200),
                Color(12, 13, 18, 25),
            );
            // 4. 双线典籍边框（选中时四角点亮铜雕花）
            const frameCol = active ? (ROOMS[i].key === "gate" ? PALETTE.sealRedBright : PALETTE.amber) : PALETTE.bronzeDim;
            drawScrollFrame(uiInkDraw, uiArt, "chap_frame_" + i, cx, cy, cardW, cardH, frameCol, active ? 1.0 : 0.65, active, false, 18, 2);

            if (active) {
                fillRadialGlow(uiGlow, cx + cardW - 26, cy + cardH - 26, 36, 36, toColor(PALETTE.cinnabar, 36), Color(186, 66, 54, 0), 12);
            }

            // 5. 右上角汉字大写章印（壹~捌）
            drawSealStamp(
                uiInkDraw,
                uiArt,
                texts,
                "chap_num_" + i,
                cx + cardW - 26,
                cy + cardH - 26,
                30,
                theme.numeralZh,
                active ? PALETTE.sealRed : PALETTE.bronzeDim,
                active ? PALETTE.sealText : PALETTE.textMid,
                active ? 0.98 : 0.85,
                active,
                4,
            );

            // 6. 章目文案
            texts.put("xs", theme.actCode + " · " + theme.lineTag, cx + 16, cy + 54, toColor(active ? PALETTE.amberCore : theme.accent), 0, 0.5, TextAlign.Left, 0.8, 0.94);
            texts.put("md", theme.titleZh, cx + 16, cy + 26, toColor(active ? PALETTE.textBright : PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.6, 1);
        }

        // 返回按钮
        const backX = leftX;
        const backY = 44;
        const backHover = pointer.x >= backX && pointer.x <= backX + 188 && pointer.y >= backY && pointer.y <= backY + 38;
        drawInkWashStrip(uiDraw, uiArt, "chap_back_bg", backX + 90, backY + 19, 200, 38, backHover ? PALETTE.cinnabarDeep : PALETTE.inkWash, backHover ? 0.78 : 0.64, false, 0);
        drawInkKeycap(uiInkDraw, texts, backX + 6, backY + 7, 46, 24, "ESC", backHover ? PALETTE.sealRedBright : PALETTE.bronzeLine, 0.95, backHover);
        texts.put("sm", this.chaptersFromPause ? "返回暂停" : "返回标题", backX + 62, backY + 19, toColor(backHover ? PALETTE.amberCore : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.2, 1);

        if (clicked && backHover) {
            return { type: this.chaptersFromPause ? "backPause" : "backTitle" };
        }
        if (mk.confirm || (clicked && hitIdx >= 0)) {
            return { type: "jump", roomIndex: this.chapterSelected };
        }
        return { type: "none" };
    }

    private drawControls(
        mk: { confirm: boolean; back: boolean },
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
        if (input.pause.pressed || mk.back || mk.confirm) {
            return { type: "backTitle" };
        }
        uiDraw.drawRect(Rect(0, 0, w, h), Color(11, 12, 17, 182));

        const leftX = 96;
        drawSealStamp(uiInkDraw, uiArt, texts, "ctrl_head_seal", leftX + 18, h - 86, 34, "诀", PALETTE.sealRed, PALETTE.sealText, 0.96, true, 4);
        texts.put("banner", "操作说明", leftX + 48, h - 86, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 4.0, 1);
        texts.put("xs", "键鼠执器要诀", leftX + 236, h - 90, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.2, 0.88);
        drawBrushDivider(uiInkDraw, uiArt, "ctrl_head_div", w * 0.5, h - 118, w - leftX * 2, 14, PALETTE.bronzeDim, 0.72, 2);

        const colGap = 34;
        const colW = (w - leftX * 2 - colGap) * 0.5;
        const panelY = h * 0.18;
        const panelH = h * 0.58;

        // 左卷：周戍（军人线）
        drawInkPanel(uiDraw, uiArt, "ctrl_left_bg", leftX, panelY, colW, panelH, PALETTE.inkWash, 0.92, true, -1);
        drawScrollFrame(uiInkDraw, uiArt, "ctrl_left_frame", leftX, panelY, colW, panelH, PALETTE.cyan, 0.88, true, true, 20, 2);
        drawSealStamp(uiInkDraw, uiArt, texts, "ctrl_left_seal", leftX + 38, panelY + panelH - 36, 28, "戍", PALETTE.cyanDim, PALETTE.moonPale, 0.96, true, 4);
        texts.put("md", "周戍 · 护送与交锋", leftX + 62, panelY + panelH - 36, toColor(PALETTE.cyanCore), 0, 0.5, TextAlign.Left, 1.2, 1);
        drawBrushDivider(uiInkDraw, uiArt, "ctrl_left_div", leftX + colW * 0.5, panelY + panelH - 60, colW - 44, 10, PALETTE.cyanDim, 0.65, 2);

        const sRows: [string, string][] = [
            ["A / D", "左右移动"],
            ["鼠标 + 左键", "瞄准 / 发射火铳"],
            ["SHIFT 按住", "贴靠柜台 / 街垒挡枪"],
            ["SPACE", "平地翻滚 / 贴矮台翻越"],
            ["E", "递物 / 敲两下安抚 / 按住+D 推车"],
            ["ESC / R", "暂歇 / 从检查点重试"],
        ];
        let i = 0;
        for (i = 0; i < sRows.length; i++) {
            const ry = panelY + panelH - 96 - i * 48;
            drawInkKeycap(uiInkDraw, texts, leftX + 26, ry - 13, 124, 26, sRows[i][0], PALETTE.cyan, 0.95, false);
            texts.put("sm", sRows[i][1], leftX + 166, ry, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.4, 0.95);
        }

        // 右卷：小满（孩子线）
        const rightX = leftX + colW + colGap;
        drawInkPanel(uiDraw, uiArt, "ctrl_right_bg", rightX, panelY, colW, panelH, PALETTE.inkWash, 0.92, true, -1);
        drawScrollFrame(uiInkDraw, uiArt, "ctrl_right_frame", rightX, panelY, colW, panelH, PALETTE.amber, 0.88, true, true, 20, 2);
        drawSealStamp(uiInkDraw, uiArt, texts, "ctrl_right_seal", rightX + 38, panelY + panelH - 36, 28, "满", PALETTE.amberDim, PALETTE.amberCore, 0.96, true, 4);
        texts.put("md", "小满 · 潜行与寻路", rightX + 62, panelY + panelH - 36, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 1.2, 1);
        drawBrushDivider(uiInkDraw, uiArt, "ctrl_right_div", rightX + colW * 0.5, panelY + panelH - 60, colW - 44, 10, PALETTE.amberDim, 0.65, 2);

        const cRows: [string, string][] = [
            ["A / D", "潜行行走"],
            ["SHIFT 按住", "轻步慢走（压低脚步声）"],
            ["S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"],
            ["SPACE", "跳跃攀上石阶与矮台"],
            ["E", "拾瓶 / 敲塔门 / 按住+D 拉板车"],
            ["F 按住→松手", "预览落点，投瓶引开拾荒者"],
        ];
        for (i = 0; i < cRows.length; i++) {
            const ry = panelY + panelH - 96 - i * 48;
            drawInkKeycap(uiInkDraw, texts, rightX + 26, ry - 13, 128, 26, cRows[i][0], PALETTE.amber, 0.95, false);
            texts.put("sm", cRows[i][1], rightX + 170, ry, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.4, 0.95);
        }

        // 返回按钮
        const backX = leftX;
        const backY = 44;
        const backHover = pointer.x >= backX && pointer.x <= backX + 224 && pointer.y >= backY && pointer.y <= backY + 38;
        drawInkWashStrip(uiDraw, uiArt, "ctrl_back_bg", backX + 108, backY + 19, 232, 38, backHover ? PALETTE.cinnabarDeep : PALETTE.inkWash, backHover ? 0.78 : 0.64, false, 0);
        drawInkKeycap(uiInkDraw, texts, backX + 6, backY + 7, 88, 24, "ESC / ENTER", backHover ? PALETTE.sealRedBright : PALETTE.bronzeLine, 0.95, backHover);
        texts.put("sm", "返回标题", backX + 104, backY + 19, toColor(backHover ? PALETTE.amberCore : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.2, 1);

        if (clicked && backHover) {
            return { type: "backTitle" };
        }
        return { type: "none" };
    }

    /** 局内暂停卷轴覆层 */
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
        this.pointerActive = input.inside && (clicked ||
            (Math.abs(input.mdx) + Math.abs(input.mdy) >= uiScale &&
                !mk.up && !mk.down && !mk.confirm));
        if (mk.back || input.pause.pressed) {
            return { type: "resume" };
        }

        if (mk.up) {
            this.pauseSelected = (this.pauseSelected + PAUSE_ITEMS.length - 1) % PAUSE_ITEMS.length;
        } else if (mk.down) {
            this.pauseSelected = (this.pauseSelected + 1) % PAUSE_ITEMS.length;
        }

        // 沉静淡墨压暗背景
        uiDraw.drawRect(Rect(0, 0, w, h), Color(9, 10, 14, 178));

        const boxW = 376;
        const boxH = 368;
        const bx = (w - boxW) * 0.5;
        const by = (h - boxH) * 0.5;

        // 竖长卷轴墨笺（木轴铜箍 + 四角铜雕花 + 宣纸细纹）
        drawInkPanel(uiDraw, uiArt, "pause_scroll_bg", bx, by, boxW, boxH, PALETTE.inkWash, 0.94, true, -1);
        drawScrollFrame(uiInkDraw, uiArt, "pause_scroll_frame", bx, by, boxW, boxH, PALETTE.bronzeLine, 0.94, true, true, 22, 2);

        // 顶部书法题字「暂歇」+ 朱砂小印
        texts.put("banner", "暂歇", w * 0.5 - 16, by + boxH - 52, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 8.0, 1);
        drawSealStamp(uiInkDraw, uiArt, texts, "pause_head_seal", w * 0.5 + 52, by + boxH - 52, 26, "停", PALETTE.sealRed, PALETTE.sealText, 0.95, true, 4);
        drawBrushDivider(uiInkDraw, uiArt, "pause_head_div", w * 0.5, by + boxH - 86, boxW - 64, 12, PALETTE.bronzeDim, 0.7, 2);

        let hitIdx = -1;
        let i = 0;
        for (i = 0; i < PAUSE_ITEMS.length; i++) {
            const iy = by + boxH - 146 - i * 56;
            const ix = bx + 36;
            const iw = boxW - 72;
            const ih = 44;
            const hover = pointer.x >= ix && pointer.x <= ix + iw && pointer.y >= iy && pointer.y <= iy + ih;
            if (hover && this.pointerActive) {
                this.pauseSelected = i;
                hitIdx = i;
            }
            const active = this.pauseSelected === i;
            const cy = iy + ih * 0.5;

            if (active) {
                const breathe = 0.86 + 0.14 * Math.sin(this.time * 2.8);
                drawInkWashStrip(uiDraw, uiArt, "pause_item_red_" + i, ix + iw * 0.5, cy, iw + 16, ih + 4, PALETTE.cinnabarDeep, 0.56 * breathe, true, 0);
                drawBrushDivider(uiInkDraw, uiArt, "pause_item_line_" + i, ix + iw * 0.5, iy + 2, iw - 12, 8, PALETTE.bronzeLine, 0.52, 2);
                drawSealStamp(uiInkDraw, uiArt, texts, "pause_item_seal_" + i, ix + 24, cy, 24, PAUSE_ITEMS[i].seal, PALETTE.sealRed, PALETTE.sealText, 0.96, true, 4);
                fillRadialGlow(uiGlow, ix + 24, cy, 28, 18, toColor(PALETTE.cinnabar, 32 * breathe), Color(168, 46, 40, 0), 10);
            } else {
                uiArt.tryPlace("ink_dot", "pause_item_dot_" + i, ix + 24, cy, 8, 8, {
                    color: toColor(PALETTE.bronzeDim), opacity: 0.55, layer: 2,
                });
            }

            texts.put(
                "md",
                PAUSE_ITEMS[i].zh,
                ix + (active ? 54 : 46),
                cy,
                toColor(active ? PALETTE.amberCore : PALETTE.textMid),
                0,
                0.5,
                TextAlign.Left,
                active ? 2.4 : 1.4,
                active ? 1.0 : 0.88,
            );
        }

        texts.put("xs", "ESC 继续   ·   Enter 或点击确认", w * 0.5, by + 24, toColor(PALETTE.textDim), 0.5, 0.5, TextAlign.Center, 0.6, 0.85);

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
