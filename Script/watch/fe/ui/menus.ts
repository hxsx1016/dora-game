/**
 * 标题、选章、操作说明与暂停菜单。
 *
 * 支持键鼠双通道操作：
 * - W/S 或 ↑/↓ 移动选框，Enter / Space 确认，Esc 返回；
 * - 鼠标悬停即时切焦，左键点击即刻触发。
 */

import { Color, DrawNode, Keyboard, KeyName, Rect, TextAlign, Vec2 } from "Dora";
import { ROOMS } from "Script/watch/rooms";
import { Input } from "Script/watch/input";
import { TextPool } from "Script/watch/fe/ui/textpool";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { StageRenderer } from "Script/watch/fe/renderer/stage";
import {
    PALETTE,
    drawDiamond,
    fillChamferBox,
    fillRadialGlow,
    fillSkewRect,
    fillVGradRect,
    themeOf,
    toColor,
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
        const held = input.fire.held;
        const fired = held && !this.prevClick;
        this.prevClick = held;
        return fired;
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
        const titleScreen = screen === "title";
        uiDraw.drawRect(Rect(0, 0, w, h), Color(15, 14, 20, titleScreen ? 25 : 118));
        uiArt.tryPlace("ui_corner", "menu_corner", 88, titleScreen ? h * 0.72 + 58 : h - 145,
            42, 45, { opacity: 0.87 });

        const mk = this.readMenuKeys();
        const clicked = this.clickEdge(input);

        if (screen === "title") {
            return this.drawTitle(mk, clicked, pointer, uiDraw, uiGlow, texts, w, h);
        }
        if (screen === "chapters") {
            return this.drawChapters(mk, clicked, input, pointer, uiDraw, uiGlow, texts, w, h);
        }
        return this.drawControls(mk, clicked, input, pointer, uiDraw, uiGlow, texts, w, h);
    }

    private drawTitle(
        mk: { up: boolean; down: boolean; confirm: boolean },
        clicked: boolean,
        pointer: Vec2.Type,
        uiDraw: DrawNode.Type,
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

        const leftX = 106;
        const titleY = h * 0.72;

        texts.put("xl", "向西守望", leftX, titleY + 24, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 3.2, 1);
        uiDraw.drawSegment(Vec2(leftX, titleY - 16), Vec2(leftX + 310, titleY - 16), 1.3, toColor(PALETTE.amberDim, 210));
        texts.put("sm", "城破那天，他留下断后。她独自走向北塔。", leftX, titleY - 48,
            toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.4, 1);

        const btnW = 340;
        const btnH = 50;
        const gap = 16;
        const startY = h * 0.42;
        let hitIdx = -1;

        let i = 0;
        for (i = 0; i < TITLE_ITEMS.length; i++) {
            const bx = leftX;
            const by = startY - i * (btnH + gap);
            const hover = pointer.x >= bx && pointer.x <= bx + btnW + 16 && pointer.y >= by && pointer.y <= by + btnH;
            if (hover) {
                this.selected = i;
                hitIdx = i;
            }
            const active = this.selected === i;
            const shiftX = active ? 7 : 0;

            fillSkewRect(
                uiDraw,
                bx + shiftX,
                by,
                btnW,
                btnH,
                14,
                active ? Color(60, 45, 42, 240) : toColor(PALETTE.panelBg, 195),
                active ? 1.6 : 1.0,
                toColor(active ? PALETTE.cyan : PALETTE.steelLight, active ? 240 : 140),
            );
            if (active) {
                fillSkewRect(uiGlow, bx + shiftX - 4, by, 6, btnH, 14, toColor(PALETTE.cyanCore, 240));
                fillRadialGlow(uiGlow, bx + shiftX + 24, by + btnH * 0.5, 42, 22, toColor(PALETTE.cyan, 85), Color(193, 161, 114, 0), 12);
            }
            texts.put("md", (active ? "▸  " : "   ") + TITLE_ITEMS[i].zh, bx + shiftX + 22, by + btnH * 0.5,
                toColor(active ? PALETTE.amberCore : PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.8, 1);
        }

        texts.put("xs", "↑ / ↓ 选择   ·   Enter 或点击确认", leftX, 52,
            toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.3, 1);

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
        } else if (mk.up) {
            this.chapterSelected = (this.chapterSelected + ROOMS.length - 4) % ROOMS.length;
        } else if (mk.down) {
            this.chapterSelected = (this.chapterSelected + 4) % ROOMS.length;
        }

        const leftX = 106;
        texts.put("lg", "选择章节", leftX, h - 116, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 2.0, 1);
        uiGlow.drawSegment(Vec2(leftX, h - 142), Vec2(w - 86, h - 142), 1.4, toColor(PALETTE.cyanDim, 180));

        // 上行：军人线 01–04（冷冰青）；下行：孩子线 05–08（暖琥珀）
        const cols = 4;
        const cardW = Math.min(256, (w - leftX - 110 - (cols - 1) * 20) / cols);
        const cardH = 128;
        const gapX = 20;
        const rowY0 = h * 0.54;
        const rowY1 = h * 0.24;
        let hitIdx = -1;

        texts.put("xs", "PHASE I  //  军人线 · 护送周戍与小满出城", leftX, rowY0 + cardH + 20, toColor(PALETTE.cyan), 0, 0.5, TextAlign.Left, 1.0, 0.95);
        texts.put("xs", "PHASE II  //  孩子线 · 小满独自前往北塔", leftX, rowY1 + cardH + 20, toColor(PALETTE.amber), 0, 0.5, TextAlign.Left, 1.0, 0.95);

        let i = 0;
        for (i = 0; i < ROOMS.length; i++) {
            const col = i % cols;
            const row = Math.floor(i / cols);
            const cx = leftX + col * (cardW + gapX);
            const cy = row === 0 ? rowY0 : rowY1;
            const theme = themeOf(ROOMS[i].key);
            const hover = pointer.x >= cx && pointer.x <= cx + cardW && pointer.y >= cy && pointer.y <= cy + cardH;
            if (hover) {
                this.chapterSelected = i;
                hitIdx = i;
            }
            const active = this.chapterSelected === i;

            fillChamferBox(
                uiDraw,
                cx,
                cy,
                cardW,
                cardH,
                14,
                active ? Color(18, 36, 56, 232) : toColor(PALETTE.panelBg, 205),
                active ? 1.8 : 1.0,
                toColor(active ? theme.accent : PALETTE.steelLight, active ? 245 : 130),
            );
            fillVGradRect(uiGlow, cx, cy + cardH - 36, cardW, 36, Color(theme.accent.r, theme.accent.g, theme.accent.b, 0), toColor(theme.accent, active ? 68 : 26));
            texts.put("xs", theme.actCode + "  //  " + theme.lineTag, cx + 16, cy + cardH - 20, toColor(theme.accent), 0, 0.5, TextAlign.Left, 0.8, 1);
            texts.put("md", theme.titleZh, cx + 16, cy + cardH - 54, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.6, 1);
            if (active) {
                drawDiamond(uiGlow, cx + cardW - 22, cy + 24, 6, 6, toColor(theme.accent));
            }
        }

        // 返回按钮
        const backX = leftX;
        const backY = 48;
        const backHover = pointer.x >= backX && pointer.x <= backX + 160 && pointer.y >= backY && pointer.y <= backY + 34;
        fillSkewRect(uiDraw, backX, backY, 156, 34, 9, toColor(PALETTE.panelBg, 210), 1.2, toColor(backHover ? PALETTE.cyan : PALETTE.steelLight, 200));
        texts.put("xs", "← 返回标题 [ESC]", backX + 82, backY + 17, toColor(backHover ? PALETTE.cyanCore : PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 0.6, 1);

        if (clicked && backHover) {
            return { type: "backTitle" };
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
        uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
    ): MenuAction {
        if (input.pause.pressed || mk.back || mk.confirm) {
            return { type: "backTitle" };
        }
        const leftX = 106;
        texts.put("lg", "操作说明", leftX, h - 116, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 2.0, 1);
        uiGlow.drawSegment(Vec2(leftX, h - 142), Vec2(w - 86, h - 142), 1.4, toColor(PALETTE.cyanDim, 180));

        const colW = (w - leftX - 116) * 0.5;
        const panelY = h * 0.22;
        const panelH = h * 0.52;

        // 左列：军人线
        fillChamferBox(uiDraw, leftX, panelY, colW, panelH, 16, toColor(PALETTE.panelBgDeep, 225), 1.3, toColor(PALETTE.cyan, 185));
        texts.put("md", "周戍  //  军人线（枪战 · 掩体 · 护送）", leftX + 24, panelY + panelH - 32, toColor(PALETTE.cyanCore), 0, 0.5, TextAlign.Left, 0.6, 1);
        const sRows: [string, string][] = [
            ["A / D", "左右移动"],
            ["鼠标 + 左键", "瞄准与点射"],
            ["SHIFT（按住）", "贴靠柜台/街垒掩体挡枪"],
            ["SPACE", "平地高速翻滚 / 贴矮台翻越"],
            ["E", "递物 / 敲两下安抚 / 按住+D 推车"],
            ["ESC / R", "暂停 / 从检查点重试"],
        ];
        let i = 0;
        for (i = 0; i < sRows.length; i++) {
            const ry = panelY + panelH - 82 - i * 44;
            fillSkewRect(uiDraw, leftX + 24, ry - 12, 132, 24, 6, Color(18, 42, 62, 220), 1, toColor(PALETTE.cyanDim, 180));
            texts.put("xs", sRows[i][0], leftX + 92, ry, toColor(PALETTE.cyanCore), 0.5, 0.5, TextAlign.Center, 0.4, 1);
            texts.put("sm", sRows[i][1], leftX + 174, ry, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.3, 0.95);
        }

        // 右列：孩子线
        const rightX = leftX + colW + 28;
        fillChamferBox(uiDraw, rightX, panelY, colW, panelH, 16, toColor(PALETTE.panelBgDeep, 225), 1.3, toColor(PALETTE.amber, 185));
        texts.put("md", "小满  //  孩子线（潜行 · 平台 · 诱敌）", rightX + 24, panelY + panelH - 32, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 0.6, 1);
        const cRows: [string, string][] = [
            ["A / D", "潜行行走"],
            ["SHIFT（按住）", "轻步慢走（压低脚步声）"],
            ["S / CTRL（按住）", "蹲伏隐蔽 · 穿过 44 净高拱洞/桌下"],
            ["SPACE", "跳跃攀上石阶与矮台"],
            ["E", "拾瓶 / 敲塔门 / 按住+D 拉红布板车"],
            ["F（按住→松手）", "预览抛物线落点，投瓶引开拾荒者"],
        ];
        for (i = 0; i < cRows.length; i++) {
            const ry = panelY + panelH - 82 - i * 44;
            fillSkewRect(uiDraw, rightX + 24, ry - 12, 142, 24, 6, Color(52, 38, 18, 220), 1, toColor(PALETTE.amberDim, 190));
            texts.put("xs", cRows[i][0], rightX + 97, ry, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 0.4, 1);
            texts.put("sm", cRows[i][1], rightX + 182, ry, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.3, 0.95);
        }

        const backX = leftX;
        const backY = 48;
        const backHover = pointer.x >= backX && pointer.x <= backX + 190 && pointer.y >= backY && pointer.y <= backY + 34;
        fillSkewRect(uiDraw, backX, backY, 186, 34, 9, toColor(PALETTE.panelBg, 210), 1.2, toColor(backHover ? PALETTE.cyan : PALETTE.steelLight, 200));
        texts.put("xs", "← 返回标题 [ESC / ENTER]", backX + 96, backY + 17, toColor(backHover ? PALETTE.cyanCore : PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 0.5, 1);

        if (clicked && backHover) {
            return { type: "backTitle" };
        }
        return { type: "none" };
    }

    /** 局内暂停覆层 */
    updateAndDrawPause(
        dt: number,
        input: Input,
        uiDraw: DrawNode.Type,
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

        // 半透明压暗遮罩
        uiDraw.drawRect(Rect(0, 0, w, h), Color(4, 7, 13, 175));

        const boxW = 390;
        const boxH = 336;
        const bx = (w - boxW) * 0.5;
        const by = (h - boxH) * 0.5;

        fillChamferBox(uiDraw, bx, by, boxW, boxH, 18, toColor(PALETTE.panelBgDeep, 242), 1.5, toColor(PALETTE.cyan, 210));
        fillVGradRect(uiGlow, bx, by + boxH - 64, boxW, 64, Color(193, 161, 114, 0), Color(193, 161, 114, 36));
        texts.put("lg", "游戏暂停", bx + 28, by + boxH - 56, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 1.8, 1);

        let hitIdx = -1;
        let i = 0;
        for (i = 0; i < PAUSE_ITEMS.length; i++) {
            const iy = by + boxH - 122 - i * 54;
            const ix = bx + 28;
            const iw = boxW - 56;
            const ih = 42;
            const hover = pointer.x >= ix && pointer.x <= ix + iw && pointer.y >= iy && pointer.y <= iy + ih;
            if (hover) {
                this.pauseSelected = i;
                hitIdx = i;
            }
            const active = this.pauseSelected === i;
            fillSkewRect(
                uiDraw,
                ix,
                iy,
                iw,
                ih,
                10,
                active ? Color(59, 44, 41, 233) : Color(12, 18, 30, 200),
                active ? 1.5 : 1.0,
                toColor(active ? PALETTE.cyan : PALETTE.steelLight, active ? 240 : 130),
            );
            if (active) {
                fillSkewRect(uiGlow, ix - 3, iy, 5, ih, 10, toColor(PALETTE.cyanCore, 235));
            }
            texts.put("sm", (active ? "▸  " : "   ") + PAUSE_ITEMS[i].zh, ix + 18, iy + 21, toColor(active ? PALETTE.cyanCore : PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.8, 1);
        }

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
