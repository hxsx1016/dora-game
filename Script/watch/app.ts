/**
 * 《守望》D1 · 灰盒查看器装配。
 *
 * 只做三件事：建绘制层与标签池、按窗口尺寸排版、用 1/2/Tab 切两张灰盒。
 * 游戏逻辑留到 D2 的 Script/watch/ 正式模块里，这里只负责“摆放能被看见、能被量”。
 */

import { Color, DrawNode, KeyName, Label, Node, Rect, Size, Vec2, View } from "Dora";
import { LabelSpec, collectLabels, computeView, drawScaleRuler, renderWorld } from "Script/watch/graybox";
import { CART_NOTE, HINTS, RULER_TEXT, STAND_NOTE, SWITCH_HINT, TITLE } from "Script/watch/keys";
import { ROOMS } from "Script/watch/rooms";
import { Input } from "Script/watch/input";
import { Play, STEP } from "Script/watch/play";

declare function print(...args: string[]): void;

const FONT = "sarasa-mono-sc-regular";

/**
 * 排版自检开关：打开后每次切房间把可见标签的包围盒打到引擎日志，
 * 输出形如 AUDIT|小结|标签=25|越界=0|重叠=0|屏幕=2560x1440。
 * D1 验收时开过一轮（检查站 25 个标签 / 城墙外 20 个标签，均无越界无重叠），平时关掉。
 */
const LAYOUT_AUDIT = false;

const C_TEXT = Color(236, 236, 232, 255);
const C_DIM = Color(150, 154, 152, 255);
const C_ACCENT = Color(226, 186, 84, 255);
const C_BG = Color(17, 18, 19, 255);

const POOL_BODY = 30;
const POOL_SMALL = 44;
const TOP_H = 208;
const BOTTOM_H = 216;

let root: Node.Type | undefined;
let draw: DrawNode.Type | undefined;
let titleLabel: Label.Type | undefined;
let roomLabel: Label.Type | undefined;
let captionLabel: Label.Type | undefined;
let hintLabel: Label.Type | undefined;
let switchLabel: Label.Type | undefined;
let rulerLabel: Label.Type | undefined;
let standLabel: Label.Type | undefined;
let cartLabel: Label.Type | undefined;

const poolBody: Label.Type[] = [];
const poolSmall: Label.Type[] = [];

let current = 0;
let viewW = 0;
let viewH = 0;
let dirty = true;
/** 0 = 灰盒查看，1 = 试玩。D2 的入口在这里分叉，G 键来回切。 */
let mode = 0;
let input: Input | undefined;
let play: Play | undefined;

function makeLabel(text: string, size: number, color: Color.Type): Label.Type | undefined {
    if (root === undefined) {
        return undefined;
    }
    const lb = Label(FONT, size);
    if (lb === undefined) {
        return undefined;
    }
    lb.text = text;
    lb.color = color;
    lb.addTo(root);
    lb.visible = true;
    return lb;
}

function place(lb: Label.Type | undefined, x: number, y: number, ax: number, ay: number): void {
    if (lb === undefined) {
        return;
    }
    lb.position = Vec2(x, y);
    lb.anchor = Vec2(ax, ay);
    lb.visible = true;
}

export function start(parent: Node.Type): void {
    root = parent;
    draw = DrawNode();
    draw.addTo(parent);

    titleLabel = makeLabel(TITLE, 40, C_TEXT);
    roomLabel = makeLabel("", 26, C_ACCENT);
    captionLabel = makeLabel("", 22, C_DIM);
    switchLabel = makeLabel(SWITCH_HINT, 22, C_DIM);
    hintLabel = makeLabel("", 22, C_TEXT);
    rulerLabel = makeLabel(RULER_TEXT, 22, C_DIM);
    standLabel = makeLabel(STAND_NOTE, 24, C_DIM);
    cartLabel = makeLabel(CART_NOTE, 24, C_ACCENT);

    for (let i = 0; i < POOL_BODY; i++) {
        const lb = makeLabel("", 24, C_TEXT);
        if (lb !== undefined) {
            poolBody.push(lb);
        }
    }
    for (let i = 0; i < POOL_SMALL; i++) {
        const lb = makeLabel("", 22, C_DIM);
        if (lb !== undefined) {
            poolSmall.push(lb);
        }
    }

    input = new Input();

    // 开发钩子：F1 进试玩、F2 回灰盒、1/2 换房间。走事件而不是轮询，
    // 这样 Lua 侧可以 emit("KeyDown","F1") 直接切模式与房间做验收，不必碰物理键盘。
    // 物理按 1/2 时轮询也会命中，两路结果一致，不会打架。
    parent.onKeyDown((key: KeyName) => {
        if (key === KeyName.F1) {
            mode = 1;
            play = undefined;
            ensurePlay();
        } else if (key === KeyName.F2) {
            mode = 0;
            dirty = true;
        } else if (key === KeyName.Num1) {
            current = 0;
            play = undefined;
            dirty = true;
            if (mode === 1) {
                ensurePlay();
            }
        } else if (key === KeyName.Num2) {
            current = 1;
            play = undefined;
            dirty = true;
            if (mode === 1) {
                ensurePlay();
            }
        }
    });

    viewW = View.size.width;
    viewH = View.size.height;
    applySize();

    parent.schedule(() => {
        tick();
        return false;
    });
}

function applySize(): void {
    if (root === undefined) {
        return;
    }
    root.size = Size(viewW, viewH);
    root.position = Vec2(-viewW / 2, -viewH / 2);
}

function tick(): void {
    const w = View.size.width;
    const h = View.size.height;
    if (w !== viewW || h !== viewH) {
        viewW = w;
        viewH = h;
        applySize();
        dirty = true;
    }
    if (input === undefined) {
        return;
    }
    input.update();
    if (input.toggleView.pressed) {
        mode = mode === 0 ? 1 : 0;
        dirty = true;
        if (mode === 1) {
            ensurePlay();
        }
    }
    if (input.pickRoom !== 0) {
        current = input.pickRoom - 1;
        dirty = true;
        play = undefined;
        if (mode === 1) {
            ensurePlay();
        }
    } else if (input.tab.pressed) {
        current = (current + 1) % ROOMS.length;
        dirty = true;
        play = undefined;
        if (mode === 1) {
            ensurePlay();
        }
    }
    if (mode === 1) {
        tickPlay();
        return;
    }
    if (dirty) {
        redraw();
        dirty = false;
    }
}

/** 试玩模式下按当前房间建运行时；切房间时重建。 */
function ensurePlay(): void {
    play = new Play(ROOMS[current]);
}

/** 试玩每帧：输入 → 位移与碰撞 → 事件 → 绘制。 */
function tickPlay(): void {
    if (play === undefined || draw === undefined || input === undefined) {
        return;
    }
    const p = play;
    if (input.retry.pressed) {
        play = new Play(ROOMS[current]);
        return;
    }
    p.aimX = input.mx;
    p.aimY = input.my;
    p.update(STEP, input);
    p.draw(draw, viewW, viewH);
    playHud(p);
}

/** 试玩模式的 HUD 用灰盒那套标签，不加新节点。 */
function playHud(p: Play): void {
    const room = ROOMS[current];
    if (titleLabel !== undefined) {
        titleLabel.text = "守望 · D2 试玩";
    }
    if (roomLabel !== undefined) {
        roomLabel.text = room.name;
    }
    if (captionLabel !== undefined) {
        captionLabel.text = p.statusText();
        captionLabel.color = C_TEXT;
    }
    if (hintLabel !== undefined) {
        hintLabel.text = p.hintText();
    }
    if (switchLabel !== undefined) {
        switchLabel.text = "G 回灰盒 · 1 检查站 · 2 城外 · R 重置";
    }
    if (rulerLabel !== undefined) {
        rulerLabel.text = "";
    }
    if (standLabel !== undefined) {
        standLabel.text = "";
    }
    if (cartLabel !== undefined) {
        cartLabel.text = "";
    }
    let i = 0;
    for (i = 0; i < poolBody.length; i++) {
        poolBody[i].visible = false;
    }
    for (i = 0; i < poolSmall.length; i++) {
        poolSmall[i].visible = false;
    }
    place(titleLabel, 48, viewH - 40, 0, 1);
    place(roomLabel, 48, viewH - 96, 0, 1);
    place(captionLabel, 48, viewH - 140, 0, 1);
    place(switchLabel, 48, 40, 0, 0);
    place(hintLabel, 48, 84, 0, 0);
}

function redraw(): void {
    if (draw === undefined) {
        return;
    }
    const w = viewW;
    const h = viewH;
    const room = ROOMS[current];

    draw.clear();

    // 顶部与底部信息带
    draw.drawRect(Rect(0, h - TOP_H, w, TOP_H), C_BG);
    draw.drawRect(Rect(0, 0, w, BOTTOM_H), C_BG);
    draw.drawSegment(Vec2(0, h - TOP_H), Vec2(w, h - TOP_H), 1, Color(52, 54, 54, 255));
    draw.drawSegment(Vec2(0, BOTTOM_H), Vec2(w, BOTTOM_H), 1, Color(52, 54, 54, 255));

    const v = computeView(room, w, h);
    renderWorld(draw, room, v, w, h);

    const roomTop = v.groundPx + room.height * v.scale;
    drawScaleRuler(draw, w - 192, roomTop + 36, v.scale);

    place(titleLabel, 48, h - 40, 0, 1);
    place(roomLabel, 48, h - 96, 0, 1);
    place(captionLabel, 48, h - 140, 0, 1);

    place(switchLabel, 48, 40, 0, 0);
    place(hintLabel, 48, 84, 0, 0);
    place(rulerLabel, w - 216, roomTop + 36 + v.scale * 0.5 - 14, 1, 0);
    place(standLabel, 48, roomTop + 40, 0, 0);
    place(cartLabel, 48, roomTop + 92, 0, 0);

    if (roomLabel !== undefined) {
        roomLabel.text = room.name;
    }
    if (captionLabel !== undefined) {
        captionLabel.text = room.caption;
    }
    if (hintLabel !== undefined) {
        const lines = HINTS[current];
        let merged = lines[0];
        for (let i = 1; i < lines.length; i++) {
            merged = merged + "    " + lines[i];
        }
        hintLabel.text = merged;
    }

    // 标签池：按字号分到 12 号与 11 号两组
    const specs = collectLabels(room, v, w);
    const body: LabelSpec[] = [];
    const small: LabelSpec[] = [];
    for (let i = 0; i < specs.length; i++) {
        const s = specs[i];
        if (s.size >= 24) {
            body.push(s);
        } else {
            small.push(s);
        }
    }
    applyPool(body, poolBody);
    applyPool(small, poolSmall);

    if (LAYOUT_AUDIT) {
        auditLayout(w, h);
    }
}

function applyPool(specs: LabelSpec[], pool: Label.Type[]): void {
    for (let i = 0; i < pool.length; i++) {
        const lb = pool[i];
        if (i < specs.length) {
            const s = specs[i];
            lb.text = s.text;
            lb.position = Vec2(s.x, s.y);
            lb.anchor = Vec2(s.ax, s.ay);
            lb.color = s.color;
            lb.visible = true;
        } else {
            lb.visible = false;
        }
    }
}

/** 打印所有可见标签的屏幕包围盒，并统计越界与重叠。 */
function auditLayout(w: number, h: number): void {
    const all: Label.Type[] = [];
    collectOne(all, titleLabel);
    collectOne(all, roomLabel);
    collectOne(all, captionLabel);
    collectOne(all, switchLabel);
    collectOne(all, hintLabel);
    collectOne(all, rulerLabel);
    collectOne(all, standLabel);
    collectOne(all, cartLabel);
    for (let i = 0; i < poolBody.length; i++) {
        collectOne(all, poolBody[i]);
    }
    for (let i = 0; i < poolSmall.length; i++) {
        collectOne(all, poolSmall[i]);
    }

    const lefts: number[] = [];
    const rights: number[] = [];
    const bottoms: number[] = [];
    const tops: number[] = [];
    let outOfScreen = 0;
    for (let i = 0; i < all.length; i++) {
        const lb = all[i];
        const bw = lb.width;
        const bh = lb.height;
        const l = lb.x - bw * lb.anchor.x;
        const r = l + bw;
        const b = lb.y - bh * lb.anchor.y;
        const t = b + bh;
        lefts.push(l);
        rights.push(r);
        bottoms.push(b);
        tops.push(t);
        if (l < 0 || r > w || b < 0 || t > h) {
            outOfScreen++;
            print("AUDIT|越界|" + lb.text + "|" + l + "," + r + "," + b + "," + t);
        }
    }

    let overlaps = 0;
    for (let i = 0; i < all.length; i++) {
        for (let j = i + 1; j < all.length; j++) {
            const ox = Math.min(rights[i], rights[j]) - Math.max(lefts[i], lefts[j]);
            const oy = Math.min(tops[i], tops[j]) - Math.max(bottoms[i], bottoms[j]);
            if (ox > 4 && oy > 4) {
                overlaps++;
                print("AUDIT|重叠|" + all[i].text + " <> " + all[j].text + "|" + ox + "x" + oy);
            }
        }
    }
    print("AUDIT|小结|标签=" + all.length + "|越界=" + outOfScreen + "|重叠=" + overlaps + "|屏幕=" + w + "x" + h);
}

function collectOne(out: Label.Type[], lb: Label.Type | undefined): void {
    if (lb !== undefined && lb.visible) {
        out.push(lb);
    }
}
