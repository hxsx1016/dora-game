/** 标题、选章、操作说明与暂停菜单。键盘和鼠标共用可见按钮范围。 */

import { Color, DrawNode, Keyboard, KeyName, Rect, TextAlign, Vec2 } from "Dora";
import { ROOMS } from "Script/watch/rooms";
import { Input } from "Script/watch/input";
import { TextPool } from "Script/watch/fe/ui/textpool";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { StageRenderer } from "Script/watch/fe/renderer/stage";
import { PALETTE, toColor } from "Script/watch/fe/theme";

export type ScreenKind = "title" | "chapters" | "controls" | "play";

export interface MenuAction {
    type: "none" | "start" | "jump" | "resume" | "retry" | "toTitle" | "openChapters" | "openControls" | "backTitle" | "backPause";
    roomIndex?: number;
}

interface Button {
    label: string;
    action: MenuAction;
}

const TITLE_ITEMS: Button[] = [
    { label: "开始游戏", action: { type: "start" } },
    { label: "选择章节", action: { type: "openChapters" } },
    { label: "操作说明", action: { type: "openControls" } },
];

const PAUSE_ITEMS: Button[] = [
    { label: "继续游戏", action: { type: "resume" } },
    { label: "重试检查点", action: { type: "retry" } },
    { label: "选择章节", action: { type: "openChapters" } },
    { label: "返回标题", action: { type: "toTitle" } },
];

const CHAPTER_TITLES: Record<string, string> = {
    prologue: "序章",
    street: "街道",
    checkpoint: "检查站",
    gate: "城门",
    outside: "城墙外",
    village: "废弃村庄",
    forest: "北塔森林",
    tower: "北塔",
};

const SOLDIER_CONTROLS: [string, string][] = [
    ["鼠标 / 左键", "瞄准 / 开枪"],
    ["按住 Shift", "贴住掩体挡枪"],
    ["空格", "翻滚 / 靠近矮柜时翻越"],
    ["按住 E + D", "握住车把，推车向前"],
];

const CHILD_CONTROLS: [string, string][] = [
    ["空格", "跳跃"],
    ["按住 Shift", "轻步慢走"],
    ["按住 S 或 Ctrl", "蹲下"],
    ["F", "按住瞄准，松开投瓶"],
    ["按住 E + D", "握住车把，拉车向前"],
];

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

function hitIndex(boxes: Rect.Type[], pointer: Vec2.Type): number {
    return boxes.findIndex(box => box.containsPoint(pointer));
}

function verticalBoxes(x: number, firstY: number, width: number, count: number): Rect.Type[] {
    const boxes: Rect.Type[] = [];
    for (let i = 0; i < count; i++) {
        boxes.push(Rect(x, firstY - i * 58, width, 48));
    }
    return boxes;
}

function drawButton(draw: DrawNode.Type, texts: TextPool, box: Rect.Type, label: string, active: boolean): void {
    const border = active ? PALETTE.amber : PALETTE.steelLight;
    draw.drawRect(box, toColor(active ? PALETTE.steelMid : PALETTE.panelBgDeep, 245),
        active ? 2 : 1, toColor(border, active ? 255 : 170));
    texts.put("md", label, box.x + 19, box.centerY, toColor(PALETTE.textBright));
}

export class MenuRenderer {
    selected = 0;
    chapterSelected = 0;
    pauseSelected = 0;
    private chaptersFromPause = false;
    private previousKeys: Partial<MenuKeys> = {};
    private queuedKeys: Partial<MenuKeys> = {};
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

    /** 页面切换后，把仍按住的键视为旧输入。 */
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
            click: input.inside && input.fire.pressed,
            pointerMoved: input.inside && Math.abs(input.mdx) + Math.abs(input.mdy) >= scale,
        };
        this.previousKeys = held;
        this.queuedKeys = {};
        this.queuedBack = false;
        return frame;
    }

    private verticalSelection(selected: number, boxes: Rect.Type[], frame: MenuFrame): number {
        const hit = hitIndex(boxes, frame.pointer);
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

    private drawActions(
        draw: DrawNode.Type, texts: TextPool, items: Button[], boxes: Rect.Type[], selected: number,
        frame: MenuFrame,
    ): MenuAction {
        for (let i = 0; i < items.length; i++) {
            drawButton(draw, texts, boxes[i], items[i].label, i === selected);
        }
        const hit = frame.click ? hitIndex(boxes, frame.pointer) : -1;
        return hit >= 0 ? items[hit].action : (frame.keys.confirm ? items[selected].action : { type: "none" });
    }

    updateAndDrawScreen(
        dt: number, screen: ScreenKind, input: Input, stage: StageRenderer,
        bgDraw: DrawNode.Type, bgGlow: DrawNode.Type, backdropArt: AssetSlotHost,
        uiDraw: DrawNode.Type, texts: TextPool, w: number, h: number, uiScale: number,
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
        const title = screen === "title";
        uiDraw.drawRect(Rect(0, 0, w, h), Color(15, 14, 20, title ? 32 : 158));
        const left = Math.min(110, w * 0.085);

        if (title) {
            const heading = h * 0.74;
            texts.put("xl", "向西守望", left, heading, toColor(PALETTE.textBright));
            texts.put("sm", "城破后，护送小满出城。", left, heading - 56, toColor(PALETTE.textMid));
            const boxes = verticalBoxes(left, h * 0.43, 300, TITLE_ITEMS.length);
            this.selected = this.verticalSelection(this.selected, boxes, frame);
            texts.put("sm", "↑ ↓ 选择　Enter 确认", left, boxes[2].y - 34, toColor(PALETTE.textMid));
            return this.drawActions(uiDraw, texts, TITLE_ITEMS, boxes, this.selected, frame);
        }
        if (screen === "chapters") {
            return this.drawChapters(frame, uiDraw, texts, left, w, h);
        }
        return this.drawControls(frame, uiDraw, texts, left, w, h);
    }

    private drawChapters(
        frame: MenuFrame, draw: DrawNode.Type, texts: TextPool, left: number, w: number, h: number,
    ): MenuAction {
        const back: MenuAction = { type: this.chaptersFromPause ? "backPause" : "backTitle" };
        if (frame.back) {
            return back;
        }
        const cols = 4;
        const width = Math.min(248, (w - left * 2 - 3 * 16) / cols);
        const boxes = ROOMS.map((_, i) => {
            const y = i < cols ? h * 0.53 : h * 0.30;
            return Rect(left + (i % cols) * (width + 16), y, width, 58);
        });
        const hit = hitIndex(boxes, frame.pointer);
        const keys = frame.keys;
        if (frame.click && hit >= 0) {
            this.chapterSelected = hit;
        } else if (keys.left || keys.right || keys.up || keys.down) {
            const step = keys.left ? -1 : keys.right ? 1 : cols;
            this.chapterSelected = (this.chapterSelected + step + ROOMS.length) % ROOMS.length;
        } else if (frame.pointerMoved && hit >= 0 && !keys.confirm) {
            this.chapterSelected = hit;
        }

        texts.put("lg", "选择章节", left, h - 100, toColor(PALETTE.textBright));
        texts.put("sm", "周戍 · 护送", left, boxes[0].top + 27, toColor(PALETTE.textMid));
        texts.put("sm", "小满 · 潜行", left, boxes[cols].top + 27, toColor(PALETTE.textMid));
        for (let i = 0; i < ROOMS.length; i++) {
            drawButton(draw, texts, boxes[i], CHAPTER_TITLES[ROOMS[i].key] ?? ROOMS[i].name, i === this.chapterSelected);
        }
        const backBox = Rect(left, 48, 188, 44);
        const hoveringBack = backBox.containsPoint(frame.pointer);
        drawButton(draw, texts, backBox, this.chaptersFromPause ? "返回暂停菜单" : "返回标题", hoveringBack);
        texts.put("sm", "方向键选择　Enter 进入　Esc 返回", backBox.right + 24, backBox.centerY,
            toColor(PALETTE.textMid));
        if (frame.click && hoveringBack) {
            return back;
        }
        return keys.confirm || (frame.click && hit >= 0)
            ? { type: "jump", roomIndex: this.chapterSelected }
            : { type: "none" };
    }

    private drawControls(
        frame: MenuFrame, draw: DrawNode.Type, texts: TextPool, left: number, w: number, h: number,
    ): MenuAction {
        const backBox = Rect(left, 48, 188, 44);
        const hoveringBack = backBox.containsPoint(frame.pointer);
        if (frame.back || frame.keys.confirm || (frame.click && hoveringBack)) {
            return { type: "backTitle" };
        }

        texts.put("lg", "操作说明", left, h - 92, toColor(PALETTE.textBright));
        texts.put("md", "A / D 或 ← / → 移动　　E 互动　　Esc 暂停　　R 重试检查点", left, h - 150,
            toColor(PALETTE.textBright));

        const width = Math.min(550, (w - left * 2 - 24) / 2);
        const panelY = h * 0.23;
        const height = h * 0.45;
        this.drawControlGroup(draw, texts, Rect(left, panelY, width, height), "周戍", SOLDIER_CONTROLS);
        this.drawControlGroup(draw, texts, Rect(left + width + 24, panelY, width, height), "小满", CHILD_CONTROLS);

        drawButton(draw, texts, backBox, "返回标题", hoveringBack);
        texts.put("sm", "Esc 返回", backBox.right + 24, backBox.centerY, toColor(PALETTE.textMid));
        return { type: "none" };
    }

    private drawControlGroup(
        draw: DrawNode.Type, texts: TextPool, box: Rect.Type, heading: string, rows: [string, string][],
    ): void {
        draw.drawRect(box, toColor(PALETTE.panelBgDeep), 1, toColor(PALETTE.steelLight));
        texts.put("md", heading, box.x + 22, box.top - 30, toColor(PALETTE.amberCore));
        for (let i = 0; i < rows.length; i++) {
            const y = box.top - 82 - i * 42;
            texts.put("sm", rows[i][0], box.x + 22, y, toColor(PALETTE.textMid));
            texts.put("sm", rows[i][1], box.x + 166, y, toColor(PALETTE.textBright));
        }
    }

    updateAndDrawPause(
        input: Input, draw: DrawNode.Type, texts: TextPool, w: number, h: number, uiScale: number,
    ): MenuAction {
        const frame = this.readFrame(input, uiScale);
        if (frame.back) {
            return { type: "resume" };
        }

        draw.drawRect(Rect(0, 0, w, h), Color(10, 10, 16, 176));
        const box = Rect((w - 404) * 0.5, (h - 378) * 0.5, 404, 378);
        draw.drawRect(box, toColor(PALETTE.panelBgDeep, 251), 1, toColor(PALETTE.steelLight));
        texts.put("lg", "游戏暂停", box.x + 25, box.top - 45, toColor(PALETTE.textBright));
        const boxes = verticalBoxes(box.x + 25, box.top - 122, box.width - 50, PAUSE_ITEMS.length);
        this.pauseSelected = this.verticalSelection(this.pauseSelected, boxes, frame);
        texts.put("sm", "Esc 继续游戏", box.x + 25, box.y + 34, toColor(PALETTE.textMid));
        return this.drawActions(draw, texts, PAUSE_ITEMS, boxes, this.pauseSelected, frame);
    }
}
