/**
 * 《守望》入口装配器：
 * - 正常启动进入艾希（ICEY）风格高清前端（WatchFrontend：终端标题页 → 8 章节全链试玩）；
 * - 保留 G / F2 切回 D1 灰盒调试视图（graybox.ts），保留 1..8 / Tab / F1 开发快跳与
 *   package.loaded["watch.play" | "watch.input" | "watch.room" | "watch.fe"] 运行态验收钩子。
 */

import { Color, DrawNode, KeyName, Label, Node, Rect, Size, Vec2, View } from "Dora";
import { LabelSpec, collectLabels, computeView, drawScaleRuler, renderWorld } from "Script/watch/graybox";
import { CART_NOTE, HINTS, RULER_TEXT, STAND_NOTE, SWITCH_HINT, TITLE } from "Script/watch/keys";
import { ROOMS } from "Script/watch/rooms";
import { Input } from "Script/watch/input";
import { Play } from "Script/watch/play";
import { STEP, StepClock } from "Script/watch/clock";
import { WatchFrontend } from "Script/watch/fe/frontend";
import { ScreenKind } from "Script/watch/fe/ui/menus";

declare function print(...args: string[]): void;

const FONT = "sarasa-mono-sc-regular";
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
let grayboxLayer: Node.Type | undefined;
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
/** 0 = D1 灰盒调试视图，1 = 正式艾希风高清前端 */
let mode = 1;
let input: Input | undefined;
let play: Play | undefined;
let fe: WatchFrontend | undefined;
const clock = new StepClock();

function makeGrayboxLabel(text: string, size: number, color: Color.Type): Label.Type | undefined {
    if (grayboxLayer === undefined) {
        return undefined;
    }
    const lb = Label(FONT, size);
    if (lb === undefined) {
        return undefined;
    }
    lb.text = text;
    lb.color = color;
    lb.addTo(grayboxLayer);
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

export function start(parent: Node.Type, initialMode: number = 1, startScreen: ScreenKind = "title"): void {
    root = parent;
    mode = initialMode;

    // 1. 保留 D1 灰盒调试层（G / F2 按需切入）
    grayboxLayer = Node();
    grayboxLayer.order = 2;
    grayboxLayer.addTo(parent);

    draw = DrawNode();
    draw.addTo(grayboxLayer);

    titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT);
    roomLabel = makeGrayboxLabel("", 26, C_ACCENT);
    captionLabel = makeGrayboxLabel("", 22, C_DIM);
    switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM);
    hintLabel = makeGrayboxLabel("", 22, C_TEXT);
    rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM);
    standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM);
    cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT);

    for (let i = 0; i < POOL_BODY; i++) {
        const lb = makeGrayboxLabel("", 24, C_TEXT);
        if (lb !== undefined) {
            poolBody.push(lb);
        }
    }
    for (let i = 0; i < POOL_SMALL; i++) {
        const lb = makeGrayboxLabel("", 22, C_DIM);
        if (lb !== undefined) {
            poolSmall.push(lb);
        }
    }

    // 2. 挂载艾希风格高清前端层
    fe = new WatchFrontend(parent);
    fe.screen = startScreen;
    grayboxLayer.visible = mode === 0;
    fe.setVisible(mode === 1);

    input = new Input();

    // 开发与验收快捷键 + 瞬时按键边沿锁存（防止低帧率下短按 E / Space / Esc / 菜单方向键被轮询漏掉）
    parent.onKeyDown((key: KeyName) => {
        if (fe !== undefined && mode === 1 && (fe.screen !== "play" || (play !== undefined && play.paused))) {
            fe.menus.onKeyEvent(key);
        }
        if (input !== undefined && mode === 1 && fe !== undefined && fe.screen === "play") {
            if (key === KeyName.E) {
                input.interact.pressed = true;
            } else if (key === KeyName.Space) {
                input.jump.pressed = true;
            } else if (key === KeyName.Escape) {
                input.pause.pressed = true;
            } else if (key === KeyName.R) {
                input.retry.pressed = true;
            }
        }
        if (key === KeyName.F1) {
            enterPlayRoom(current);
        } else if (key === KeyName.F2) {
            setMode(0);
        } else if (key === KeyName.Num1) {
            pickByIndex(0);
        } else if (key === KeyName.Num2) {
            pickByIndex(1);
        } else if (key === KeyName.Num3) {
            pickByIndex(2);
        } else if (key === KeyName.Num4) {
            pickByIndex(3);
        } else if (key === KeyName.Num5) {
            pickByIndex(4);
        } else if (key === KeyName.Num6) {
            pickByIndex(5);
        } else if (key === KeyName.Num7) {
            pickByIndex(6);
        } else if (key === KeyName.Num8) {
            pickByIndex(7);
        }
    });

    viewW = View.size.width;
    viewH = View.size.height;
    applySize();

    // 验收钩子：保留 watch.input / watch.play / watch.room，并补充 watch.fe 控制面
    const reg = (globalThis as unknown as { package: { loaded: Record<string, unknown> } }).package.loaded;
    reg["watch.input"] = input;
    reg["watch.fe"] = {
        setScreen: (sc: ScreenKind) => {
            if (fe === undefined) {
                return;
            }
            setMode(1);
            fe.screen = sc;
            if (sc === "play") {
                ensurePlay();
            }
        },
        jumpRoom: (keyOrIdx: string | number) => {
            let idx = -1;
            if (typeof keyOrIdx === "number") {
                idx = keyOrIdx;
            } else {
                let k = 0;
                for (k = 0; k < ROOMS.length; k++) {
                    if (ROOMS[k].key === keyOrIdx) {
                        idx = k;
                    }
                }
            }
            if (idx >= 0 && idx < ROOMS.length) {
                enterPlayRoom(idx);
            }
        },
        getPlay: () => play,
        getFrontend: () => fe,
    };

    if (mode === 1 && startScreen === "play") {
        ensurePlay();
    }

    parent.schedule((frameDt: number) => {
        tick(frameDt);
        return false;
    });
}

function setMode(nextMode: number): void {
    mode = nextMode;
    if (grayboxLayer !== undefined) {
        grayboxLayer.visible = mode === 0;
    }
    if (fe !== undefined) {
        fe.setVisible(mode === 1);
    }
    dirty = true;
    clock.reset();
}

function enterPlayRoom(idx: number): void {
    current = idx;
    setMode(1);
    if (fe !== undefined) {
        fe.screen = "play";
    }
    play = undefined;
    ensurePlay();
}

function pickByIndex(idx: number): void {
    if (idx < 0 || idx >= ROOMS.length) {
        return;
    }
    current = idx;
    dirty = true;
    play = undefined;
    clock.reset();
    if (mode === 1) {
        if (fe !== undefined) {
            fe.screen = "play";
        }
        ensurePlay();
    }
}

function applySize(): void {
    if (root === undefined) {
        return;
    }
    root.size = Size(viewW, viewH);
    root.position = Vec2(-viewW / 2, -viewH / 2);
}

function tick(frameDt: number): void {
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

    // G 键切换灰盒调试视图 / 高清前端
    if (input.toggleView.pressed) {
        input.toggleView.pressed = false;
        setMode(mode === 0 ? 1 : 0);
        if (mode === 1 && fe !== undefined && fe.screen === "play" && play === undefined) {
            ensurePlay();
        }
    }

    // 1/2/3 与 Tab 轮询快跳
    if (input.pickRoom !== 0) {
        const idx = input.pickRoom - 1;
        input.pickRoom = 0;
        pickByIndex(idx);
    } else if (input.tab.pressed) {
        input.tab.pressed = false;
        pickByIndex((current + 1) % ROOMS.length);
    }

    if (mode === 1) {
        tickFrontend(frameDt);
        return;
    }
    if (dirty) {
        redrawGraybox();
        dirty = false;
    }
}

function ensurePlay(resume?: { checkpoint: number }): void {
    play = new Play(ROOMS[current], resume);
    const reg = (globalThis as unknown as { package: { loaded: Record<string, unknown> } }).package.loaded;
    reg["watch.play"] = play;
    reg["watch.room"] = ROOMS[current].key;
    clock.reset();
    if (fe !== undefined) {
        fe.bindPlay(play, viewW, viewH);
    }
}

function tickFrontend(frameDt: number): void {
    if (fe === undefined || input === undefined) {
        return;
    }

    // 1. 标题 / 章节直达 / 操作图鉴
    if (fe.screen !== "play") {
        const act = fe.renderMenu(frameDt, input, viewW, viewH);
        input.consumeEdges();
        if (act.type === "start") {
            enterPlayRoom(0);
        } else if (act.type === "jump" && act.roomIndex !== undefined) {
            enterPlayRoom(act.roomIndex);
        } else if (act.type === "openChapters") {
            fe.screen = "chapters";
        } else if (act.type === "openControls") {
            fe.screen = "controls";
        } else if (act.type === "backTitle") {
            fe.screen = "title";
        }
        return;
    }

    // 2. 局内试玩
    if (play === undefined) {
        ensurePlay();
    }
    if (play === undefined) {
        return;
    }
    const p = play;

    if (input.retry.pressed) {
        input.consumeEdges();
        ensurePlay({ checkpoint: p.checkpoint });
        return;
    }

    p.aimX = input.mx;
    p.aimY = input.my;

    if (p.paused) {
        clock.reset();
        input.beginStep(true);
        p.update(STEP, input);
        input.endStep();
        const pauseAct = fe.renderPlay(frameDt, p, input, viewW, viewH);
        if (pauseAct.type === "resume") {
            p.paused = false;
        } else if (pauseAct.type === "retry") {
            ensurePlay({ checkpoint: p.checkpoint });
        } else if (pauseAct.type === "openChapters") {
            p.paused = false;
            fe.screen = "chapters";
        } else if (pauseAct.type === "toTitle") {
            p.paused = false;
            fe.screen = "title";
        }
        return;
    }

    const steps = clock.advance(frameDt);
    let i = 0;
    for (i = 0; i < steps; i++) {
        input.beginStep(i === 0);
        p.update(STEP, input);
        input.endStep();
    }

    // 切场由后端 wantRoom 触发，前端无缝接管
    if (p.wantRoom !== "") {
        const key = p.wantRoom;
        p.wantRoom = "";
        let idx = -1;
        let j = 0;
        for (j = 0; j < ROOMS.length; j++) {
            if (ROOMS[j].key === key) {
                idx = j;
            }
        }
        if (idx >= 0) {
            current = idx;
            ensurePlay();
            dirty = true;
        }
        return;
    }

    fe.renderPlay(frameDt, p, input, viewW, viewH);
}

/** D1 灰盒调试视图（按 G / F2 切入） */
function redrawGraybox(): void {
    if (draw === undefined) {
        return;
    }
    const w = viewW;
    const h = viewH;
    const room = ROOMS[current];

    draw.clear();
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
        const hintIdx = Math.min(current, HINTS.length - 1);
        const lines = HINTS[hintIdx];
        let merged = lines[0];
        for (let i = 1; i < lines.length; i++) {
            merged = merged + "    " + lines[i];
        }
        hintLabel.text = merged;
    }

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
        print("AUDIT|" + room.key + "|" + specs.length);
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
