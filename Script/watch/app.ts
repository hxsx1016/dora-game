/**
 * 《守望》入口装配器：
 * - 正常启动进入 WatchFrontend 的标题页与八个房间；
 * - 保留 G / F2 切回 D1 灰盒调试视图（graybox.ts），保留 1..8 / Tab / F1 开发快跳与
 *   package.loaded["watch.play" | "watch.input" | "watch.room" | "watch.fe"] 运行态验收钩子。
 */

import { App, Color, DrawNode, KeyName, Label, Node, Rect, Size, Vec2, View } from "Dora";
import { LabelSpec, collectLabels, computeView, drawScaleRuler, renderWorld } from "Script/watch/graybox";
import { CART_NOTE, HINTS, RULER_TEXT, STAND_NOTE, SWITCH_HINT, TITLE } from "Script/watch/keys";
import { CAMPAIGN_ROOMS, ROOMS } from "Script/watch/rooms";
import { Input } from "Script/watch/input";
import { Play } from "Script/watch/play";
import { STEP, StepClock } from "Script/watch/clock";
import { WatchFrontend } from "Script/watch/fe/frontend";
import { createRun, createTrial, mmss, RunSource, RunState, talentNames } from "Script/watch/run";
import { emptySave, loadSave, saveSave, SaveState, setSaveFile, getSaveFile,
    markProfilePending, flushProfile as flushSaveProfile, clearProfilePending, profilePending } from "Script/watch/save";
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
let campaignLayer: Node.Type | undefined;
let campaignDraw: DrawNode.Type | undefined;
let campaignHud: Label.Type | undefined;
let campaignSub: Label.Type | undefined;
let run: RunState | undefined;
/** 正式剧情的跨房状态；模式 1 整局一份，切房与 R 重试都复用它。 */
let storyRun: RunState | undefined;
/** 跨局档案：正式通关与神器只写在这里，与每局的 RunState 分开。 */
let profile: SaveState = emptySave();
let profileStatus = "missing";
let profileDetail = "";
let rulerLabel: Label.Type | undefined;
let standLabel: Label.Type | undefined;
let cartLabel: Label.Type | undefined;

const poolBody: Label.Type[] = [];
const poolSmall: Label.Type[] = [];

let current = 0;
let viewW = 0;
let viewH = 0;
let dirty = true;
/** 0 = 灰盒调试视图，1 = 游戏前端。 */
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

    // 新版关卡试玩层：直接画 Play，HUD 只有两行读数。
    campaignLayer = Node();
    campaignLayer.order = 3;
    campaignLayer.addTo(parent);
    campaignDraw = DrawNode();
    campaignDraw.addTo(campaignLayer);
    campaignHud = Label(FONT, 24);
    if (campaignHud !== undefined) {
        campaignHud.color = C_TEXT;
        campaignHud.anchor = Vec2(0, 1);
        campaignHud.addTo(campaignLayer);
        campaignHud.visible = true;
    }
    campaignSub = Label(FONT, 20);
    if (campaignSub !== undefined) {
        campaignSub.color = C_ACCENT;
        campaignSub.anchor = Vec2(0, 1);
        campaignSub.addTo(campaignLayer);
        campaignSub.visible = true;
    }
    campaignLayer.visible = mode === 2;

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

    // 挂载菜单与游戏前端。
    // 读档：缺文件按新档起局；损坏/版本不支持时保留原文件并报告，仍可继续玩。
    if (mode === 1) {
        const loaded = loadSave();
        profile = loaded.state;
        profileStatus = loaded.status;
        profileDetail = loaded.detail;
    }
    fe = new WatchFrontend(parent);
    fe.screen = startScreen;
    grayboxLayer.visible = mode === 0;
    fe.setVisible(mode === 1);
    if (campaignLayer !== undefined) {
        campaignLayer.visible = mode === 2;
    }

    input = new Input();

    // 开发与验收快捷键 + 瞬时按键边沿锁存（防止低帧率下短按 E / Space / Esc / 菜单方向键被轮询漏掉）
    parent.onKeyDown((key: KeyName) => {
        if (fe !== undefined && mode === 1 && (fe.screen !== "play" || (play !== undefined && play.paused))) {
            fe.menus.onKeyEvent(key);
        }
        if (input !== undefined && ((mode === 1 && fe !== undefined && fe.screen === "play") || mode === 2)) {
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
        if (mode === 2 && run?.trial !== undefined) return;
        if (key === KeyName.F1) {
            if (mode === 2) {
                current = 0;
                play = undefined;
                ensurePlay();
            } else {
                enterPlayRoom(current, storyRun === undefined ? "debug" : storyRun.source);
            }
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
            if (sc === "chapters") {
                fe.menus.openChapters();
            } else {
                fe.menus.resetInput();
            }
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
                enterPlayRoom(idx, "debug");
            }
        },
        getPlay: () => play,
        getFrontend: () => fe,
        // 验收钩子：按标题「新的旅程」的真实入口开一局（official 来源、全新 storyRun）。
        startStory: () => {
            enterPlayRoom(officialStartIndex(), "official", true);
            return play;
        },
        // 章节预览与菜单「章节」页的 jump 同一入口（chapter 来源，只演出不记档）。
        previewChapter: (idx: number) => {
            enterPlayRoom(idx, "chapter");
            return play;
        },
        getStoryRun: () => storyRun,
        getProfilePending: () => profilePending(),
        flushProfileNow: () => flushProfile(),
        // 档案验收：测试只切隔离文件，绝不覆盖正式 watch-save/archive.txt。
        getProfile: () => profile,
        getProfileStatus: () => profileStatus,
        getProfileDetail: () => profileDetail,
        useTestSave: (name: string) => {
            setSaveFile(name);
            clearProfilePending();
            const loaded = loadSave();
            profile = loaded.state;
            profileStatus = loaded.status;
            profileDetail = loaded.detail;
        },
        saveNow: () => saveSave(profile),
        getSaveFile,
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
    if (campaignLayer !== undefined) {
        campaignLayer.visible = mode === 2;
    }
    dirty = true;
    clock.reset();
}

/**
 * 把档案变化落盘：Play 上的 dirty 只当「本次变化」的信号，登记到 save 模块后立刻清；
 * 真正待写责任在 save 模块（与 app 同寿命），切房换 Play 实例不会丢。
 */
function flushProfile(): boolean {
    const cur = play;
    if (cur !== undefined && cur.archiveDirty) {
        cur.archiveDirty = false;
        markProfilePending(profile);
    }
    const ok = flushSaveProfile();
    if (!ok && cur !== undefined) {
        cur.archiveDirty = true;
    }
    return ok;
}

/** 正式开局的落点：馆内中途退出过就从同一步续读，否则照常从序章起。 */
function officialStartIndex(): number {
    const mp = profile.museumPhase;
    const inMuseum = mp === "well_reflect" || mp === "hall_walk" || mp === "lamp_turn" || mp === "return_cabinet";
    return inMuseum ? roomIndexByKey("museum") : 0;
}

function roomIndexByKey(key: string): number {
    let i = 0;
    for (i = 0; i < ROOMS.length; i++) {
        if (ROOMS[i].key === key) {
            return i;
        }
    }
    return 0;
}

function enterPlayRoom(idx: number, source: RunSource = "debug", fresh = false): void {
    current = idx;
    setMode(1);
    if (fe !== undefined) {
        fe.screen = "play";
    }
    play = undefined;
    // 标题「新的旅程」进序章视为正式开新局；章节直达与快跳只预览，不写通关档案。
    if (fresh || storyRun === undefined) {
        storyRun = createRun(20261124, source, profile);
    } else {
        storyRun.source = source;
    }
    ensurePlay();
    flushProfile();
}

function pickByIndex(idx: number, source: RunSource = "debug"): void {
    if (mode === 2) {
        if (idx < 0 || idx >= CAMPAIGN_ROOMS.length) {
            return;
        }
        current = idx;
        play = undefined;
        clock.reset();
        ensurePlay();
        return;
    }
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
    if (mode === 2 && run?.trial !== undefined) {
        tickCampaign(frameDt);
        return;
    }

    // G 键切换灰盒调试视图 / 高清前端
    if (input.toggleView.pressed) {
        input.toggleView.pressed = false;
        setMode(mode === 0 ? 1 : (mode === 1 ? 2 : 0));
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
        if (mode === 0 || (fe?.screen === "play" && !play?.paused)) {
            pickByIndex((current + 1) % ROOMS.length);
        }
    }

    if (mode === 2) {
        tickCampaign(frameDt);
        return;
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

/** 把当前 Play 实例挂到 package.loaded，供 Lua 回放/验收读真实运行态。 */
function registerPlay(): void {
    const reg = (globalThis as unknown as { package: { loaded: Record<string, unknown> } }).package.loaded;
    reg["watch.play"] = play;
    const rooms = mode === 2 ? CAMPAIGN_ROOMS : ROOMS;
    reg["watch.room"] = rooms[current].key;
}

/** 试玩模式下按当前房间建运行时；切房间时重建。 */
function ensurePlay(resume?: { checkpoint: number }): void {
    if (mode === 2) {
        if (run === undefined) {
            run = createRun();
        }
        play = new Play(CAMPAIGN_ROOMS[current], undefined, run);
    } else {
        // 正式剧情：整局只有一份跨房状态，血量、过门锁线与演出快照都在里面。
        // 重试与切房都重建 Play，但不再满血重算。
        if (storyRun === undefined) {
            storyRun = createRun(20261124, "debug", profile);
        }
        play = new Play(ROOMS[current], resume, storyRun);
    }
    registerPlay();
    clock.reset();
    if (fe !== undefined && mode === 1) {
        fe.bindPlay(play, viewW, viewH);
    }
}

function startTrial(): void {
    current = 0;
    run = createTrial(App.rand);
    setMode(2);
    ensurePlay();
}

function tickCampaign(frameDt: number): void {
    if (input === undefined) {
        return;
    }
    if (play === undefined) {
        ensurePlay();
    }
    if (play === undefined) {
        return;
    }
    const p = play;
    p.aimX = input.mx;
    p.aimY = input.my;

    const trial = run?.trial;
    if (trial !== undefined) {
        const ended = trial.lost || run?.finished === true;
        const pick = input.pickRoom;
        input.pickRoom = 0;
        if ((ended && input.pause.pressed) || (p.paused && input.interact.pressed)) {
            input.consumeEdges();
            current = 0;
            play = undefined;
            run = undefined;
            setMode(1);
            if (fe !== undefined) {
                fe.screen = "title";
                fe.menus.resetInput();
            }
            return;
        }
        if (ended || (p.paused && input.retry.pressed)) {
            const restart = input.retry.pressed;
            input.consumeEdges();
            if (restart) startTrial();
            else drawCampaign(p);
            return;
        }
        input.retry.pressed = false;
        if (trial.offers.length > 0 && !p.paused && !input.pause.pressed) {
            if (pick > 0) p.chooseTalent(pick - 1);
            input.consumeEdges();
            clock.reset();
            drawCampaign(p);
            return;
        }
    }

    if (input.retry.pressed) {
        input.retry.pressed = false;
        input.consumeEdges();
        // R 重开本段：保留已取物资与破坏，只把人送回起点。
        play = undefined;
        ensurePlay();
        return;
    }
    if (input.pause.pressed) {
        input.pause.pressed = false;
        p.paused = !p.paused;
        clock.reset();
        input.consumeEdges();
    }
    if (p.paused) {
        drawCampaign(p);
        return;
    }

    const steps = clock.advance(frameDt);
    let i = 0;
    for (i = 0; i < steps; i++) {
        input.beginStep(i === 0);
        p.update(STEP, input);
        input.endStep();
        if (p.wantRoom !== "" || trial?.lost || (trial !== undefined && run?.finished)) {
            break;
        }
    }

    if (p.wantRoom !== "") {
        const key = p.wantRoom;
        p.wantRoom = "";
        let idx = -1;
        let j = 0;
        for (j = 0; j < CAMPAIGN_ROOMS.length; j++) {
            if (CAMPAIGN_ROOMS[j].key === key) {
                idx = j;
            }
        }
        if (idx >= 0) {
            current = idx;
            play = undefined;
            ensurePlay();
        }
        return;
    }
    drawCampaign(p);
}

function goalLabel(goal: string): string {
    if (goal === "dock_cart") {
        return "推车入窝并抬闩";
    }
    if (goal === "raise_latch") {
        return "抬闩开侧门";
    }
    return "到段出口";
}

function drawCampaign(p: Play): void {
    if (campaignDraw === undefined) {
        return;
    }
    const w = viewW;
    const h = viewH;
    p.draw(campaignDraw, w, h);
    const room = CAMPAIGN_ROOMS[current];
    const c = room.campaign;
    const r = run;
    let line = room.name;
    if (c !== undefined) {
        line = line + "  " + c.chapter + c.act + " · 目标 " + goalLabel(c.goal)
            + " · 本段 " + mmss(r === undefined ? 0 : (r.roomTicks[room.key] ?? 0)) + " / 预算 " + mmss(c.budget);
    }
    if (p.paused) {
        line = line + "  · 已暂停 Esc 继续";
    }
    const trial = r?.trial;
    if (trial !== undefined && r !== undefined) {
        line = "护送试炼 · " + room.name + " · 体力 " + p.hp + "/" + p.maxHp + " · " + mmss(r.ticks);
        if (p.paused) line += " · 暂停";
        else if (trial.lost) line += " · 护送失败";
        else if (r.finished) line += " · 护送完成";
        else if (trial.offers.length > 0) line += " · 选择本段本领";
        else if (c !== undefined) line += " · " + goalLabel(c.goal);
    }
    if (campaignHud !== undefined) {
        campaignHud.text = line;
        campaignHud.position = Vec2(24, h - 14);
        campaignHud.visible = true;
    }
    if (campaignSub !== undefined) {
        let sub = "总 " + mmss(r === undefined ? 0 : r.ticks);
        if (r !== undefined) {
            const route = r.route === "drygoods" ? "布行" : (r.route === "outer" ? "外檐" : "未定");
            sub = sub + " · 路线 " + route
                + " · 盾" + r.inventory.shield + " 楔" + r.inventory.wedge + " 弹" + r.inventory.ammo
                + " 牌" + r.inventory.pass + " 带" + r.inventory.quickbelt
                + " · " + (r.joined ? "小满跟随" : "小满等待");
        }
        if (p.flash !== "") {
            sub = sub + " · " + p.flash;
        }
        if (trial !== undefined && r !== undefined) {
            if (trial.lost || r.finished) sub = "种子 " + r.seed + " · R 再开一局 · Esc 返回标题";
            else if (p.paused) sub = "种子 " + r.seed + " · Esc 继续 · R 重新开局 · E 返回标题";
            else if (trial.offers.length > 0) sub = trial.offers.map((talent, index) => (index + 1) + " " + talentNames[talent]).join("　");
            else sub = "厚甲" + trial.ranks.vitality + " 熟铳" + trial.ranks.reload + " 护身" + trial.ranks.guard + " 巧手" + trial.ranks.craft + " · " + (p.flash !== "" ? p.flash : (r.joined ? "小满跟随" : "小满等待"));
        }
        campaignSub.text = sub;
        campaignSub.position = Vec2(24, h - 44);
        campaignSub.visible = true;
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
        if (act.type === "trial") {
            startTrial();
        } else if (act.type === "start") {
            // 馆内中途退出过：从档案里的同一步续读；否则照常从序章起。
            enterPlayRoom(officialStartIndex(), "official", true);
        } else if (act.type === "jump" && act.roomIndex !== undefined) {
            enterPlayRoom(act.roomIndex, "chapter");
        } else if (act.type === "openChapters") {
            fe.menus.openChapters();
            fe.screen = "chapters";
        } else if (act.type === "openControls") {
            fe.menus.resetInput();
            fe.screen = "controls";
        } else if (act.type === "backTitle") {
            fe.menus.resetInput();
            fe.screen = "title";
        } else if (act.type === "backPause") {
            fe.menus.resetInput();
            fe.screen = "play";
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
        // 重试保留检查点，并重新绑定前端相机与运行态验收钩子。
        ensurePlay({ checkpoint: p.checkpoint });
        return;
    }

    p.aimX = input.mx;
    p.aimY = input.my;

    if (!p.paused && input.pause.pressed) {
        p.paused = true;
        p.aimHold = 0;
        p.bottleAimX = -1;
        fe.menus.openPause();
        input.consumeEdges();
    }

    if (p.paused) {
        // 菜单独占这一帧的输入。恢复时从下一帧开始推进游戏。
        clock.reset();
        const pauseAct = fe.renderPlay(frameDt, p, input, viewW, viewH);
        input.consumeEdges();
        if (pauseAct.type === "resume") {
            p.paused = false;
        } else if (pauseAct.type === "retry") {
            ensurePlay({ checkpoint: p.checkpoint });
        } else if (pauseAct.type === "openChapters") {
            fe.menus.openChapters(current);
            fe.screen = "chapters";
        } else if (pauseAct.type === "toTitle") {
            fe.menus.resetInput();
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
        if (p.wantRoom !== "") {
            break;
        }
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
            // 换实例前先取走旧队列，再接到新实例队首；前端下一帧仍能拿到切房这一条 roomChange。
            // adoptEvents 会丢掉旧房间的 knock，避免跨出口同拍按 E 时在新房重播旧房敲声。
            // 切房同拍：旧实例的档案变化先落盘；失败则留 profileDirty，由后续帧重试。
            flushProfile();
            const leaving = p.drainEvents();
            // 片尾回序章：重开一份局内状态（路线/材料/拾取/检查点清零），档案仍是同一份。
            if (p.restartStory) {
                storyRun = createRun(20261124, storyRun === undefined ? "official" : storyRun.source, profile);
            }
            current = idx;
            ensurePlay();
            const fresh = play;
            if (fresh !== undefined) {
                fresh.adoptEvents(leaving);
            }
            clock.reset();
            dirty = true;
        }
        return;
    }

    // 档案变化（正式通关、井口取器）在下一个渲染帧落盘；写失败保留旧文件，下次再试。
    flushProfile();
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
