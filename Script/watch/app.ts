/**
 * 《守望》入口装配器：
 * - 正常启动进入 WatchFrontend 的标题页与八个房间；
 * - 保留 G / F2 切回 D1 灰盒调试视图（graybox.ts），保留 1..8 / Tab / F1 开发快跳与
 *   package.loaded["watch.play" | "watch.input" | "watch.room" | "watch.fe"] 运行态验收钩子。
 */

import { App, Color, DrawNode, Keyboard, KeyName, Label, Node, Rect, Size, Vec2, View } from "Dora";
import { LabelSpec, collectLabels, computeView, drawScaleRuler, renderWorld } from "Script/watch/graybox";
import { CART_NOTE, HINTS, RULER_TEXT, STAND_NOTE, SWITCH_HINT, TITLE } from "Script/watch/keys";
import { CAMPAIGN_ROOMS, ROOMS } from "Script/watch/rooms";
import { Input } from "Script/watch/input";
import { DEPTH_Y_SCALE } from "Script/watch/depth";
import { Play } from "Script/watch/play";
import { STEP, StepClock } from "Script/watch/clock";
import { collectPlayAimTargets, collectTrialAimTargets } from "Script/watch/aim_assist";
import { InputMode, InputModePref } from "Script/watch/controls_config";
import { GamepadFrameContext, GamepadRawState, GamepadRouter } from "Script/watch/gamepad";
import {
    StageViewport,
    canQuitApp,
    canToggleFullscreen,
    computeStageViewport,
    getReleaseConfig,
    isReleaseMode,
} from "Script/watch/platform";
import { TouchRouter } from "Script/watch/touch";
import { WatchFrontend } from "Script/watch/fe/frontend";
import { createRun, createStoryTalents, createTrial, mmss, RunSource, RunState, Talent, talentNames } from "Script/watch/run";
import { emptySave, loadSave, saveSave, SaveState, setSaveFile, getSaveFile,
    markProfilePending, flushProfile as flushSaveProfile, clearProfilePending, profilePending,
    SessionSave, loadSession, saveSession, clearSession, hasSessionSave, setSessionFile, getSessionFile } from "Script/watch/save";
import { ScreenKind } from "Script/watch/fe/ui/menus";
import { TouchControls } from "Script/watch/fe/ui/touch_controls";
import { isCutsceneBlockingPlay } from "Script/watch/fe/ui/control_prompts";

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
let touchRouter: TouchRouter | undefined;
let gamepadRouter: GamepadRouter | undefined;
let touchControls: TouchControls | undefined;
let play: Play | undefined;
let fe: WatchFrontend | undefined;
const clock = new StepClock();
let stageVp: StageViewport = computeStageViewport(1280, 720);
let testViewportOverride: { w: number; h: number } | undefined;
let audioUnlocked = false;
let appClock = 0;
let lastBackPressClock = -10;
let trialTalentSelected = 0;

function isReleaseBuild(): boolean {
    return isReleaseMode();
}

function onFirstUserGesture(): void {
    if (audioUnlocked || fe === undefined) {
        return;
    }
    audioUnlocked = true;
    fe.audio.unlockAndResyncAfterGesture();
}

function toggleFullscreen(): boolean {
    if (!canToggleFullscreen()) {
        return false;
    }
    try {
        const next = !App.fullScreen;
        App.fullScreen = next;
        return next;
    } catch {
        return false;
    }
}

function quitGame(): void {
    flushProfile();
    saveCurrentSession();
    input?.clearTransient(false);
    if (fe !== undefined) {
        fe.audio.stopRoomTransient();
    }
    if (!canQuitApp()) {
        // Web / Dora Go 源码模式不允许停死宿主进程：安全回退到标题页
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
    App.shutdown();
}

function handleBackButton(): void {
    if (mode === 0) {
        setMode(1);
        return;
    }
    if (mode === 2 && play !== undefined) {
        const trial = run?.trial;
        if (trial !== undefined && (trial.lost || run?.finished === true)) {
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
        play.paused = !play.paused;
        clock.reset();
        input?.clearTransient(true);
        return;
    }
    if (fe === undefined) {
        return;
    }
    if (fe.screen === "splash") {
        fe.menus.resetSplash();
        fe.screen = "title";
        fe.menus.resetInput();
        return;
    }
    if (fe.screen === "chapters" || fe.screen === "controls") {
        fe.menus.triggerBack();
        return;
    }
    if (fe.screen === "title") {
        if (!canQuitApp()) {
            fe.showToast("按系统返回主界面或切换应用离开", 1.8);
            return;
        }
        if (appClock - lastBackPressClock <= 2.0) {
            quitGame();
        } else {
            lastBackPressClock = appClock;
            fe.showToast("再按一次返回退出游戏", 2.0);
        }
        return;
    }
    if (fe.screen === "play" && play !== undefined) {
        if (play.paused) {
            fe.menus.triggerBack();
            return;
        }
        if (play.craftBench.active) {
            play.closeCraftBench();
            return;
        }
        play.paused = true;
        play.aimHold = 0;
        play.bottleAimX = -1;
        saveCurrentSession();
        fe.menus.openPause();
        input?.clearTransient(true);
    }
}

function canSaveSession(): boolean {
    if (mode !== 1 || play === undefined || storyRun === undefined) {
        return false;
    }
    if (storyRun.source !== "official" || play.run.finished) {
        return false;
    }
    if (play.room.key === "museum" || (play.room.key === "tower" && play.phase === "tower-end")) {
        return false;
    }
    return true;
}

function refreshTitleSessionFlag(): void {
    if (fe !== undefined) {
        fe.menus.hasSession = hasSessionSave();
    }
}

function saveCurrentSession(): boolean {
    if (!canSaveSession() || play === undefined) {
        return false;
    }
    play.sessionDirty = false;
    const ok = saveSession(play.exportSession());
    refreshTitleSessionFlag();
    return ok;
}

function continueOfficialStory(): Play | undefined {
    const res = loadSession();
    if (res.status !== "ok" || res.state === undefined) {
        refreshTitleSessionFlag();
        return undefined;
    }
    const s: SessionSave = res.state;
    const idx = roomIndexByKey(s.roomKey);
    if (ROOMS[idx].key !== s.roomKey) {
        return undefined;
    }
    storyRun = createRun(s.seed, "official", profile);
    storyRun.checkpoint = s.checkpoint;
    storyRun.story.route = s.route;
    storyRun.story.hp = s.hp;
    storyRun.story.maxHp = s.maxHp;
    storyRun.story.hpAtGate = s.hpAtGate;
    storyRun.story.maxHpAtGate = s.maxHpAtGate;
    storyRun.story.settled = s.settled;
    storyRun.story.phase = s.phase;
    storyRun.story.countTick = s.countTick;
    storyRun.story.phaseTick = s.phaseTick;
    storyRun.story.handTicks = s.handTicks;
    storyRun.story.handDone = s.handDone;
    storyRun.story.lineSaid = s.lineSaid;
    storyRun.story.tied = s.tied;
    storyRun.story.carry = s.carry;
    storyRun.story.escortDone = s.escortDone;
    storyRun.story.craftedWeapon = s.craftedWeapon;
    storyRun.story.equippedWeapon = s.equippedWeapon;
    storyRun.inventory.wood = s.wood;
    storyRun.inventory.bell = s.bell;
    storyRun.inventory.scrap = s.scrap;
    storyRun.inventory.wedge = s.wedge;
    storyRun.inventory.ammo = s.ammo;
    storyRun.inventory.shield = s.shield;
    storyRun.inventory.pass = s.pass;
    storyRun.inventory.quickbelt = s.quickbelt;
    let k = 0;
    for (k = 0; k < s.taken.length; k++) {
        storyRun.taken[s.taken[k]] = true;
    }
    for (k = 0; k < s.segments.length; k++) {
        storyRun.story.segments[s.segments[k]] = true;
    }
    if (s.campaignRoute !== undefined) {
        storyRun.route = s.campaignRoute;
    }
    if (s.joined !== undefined) {
        storyRun.joined = s.joined;
    }
    if (s.c1Latch !== undefined) {
        storyRun.c1Latch = s.c1Latch;
    }
    if (s.c2Latch !== undefined) {
        storyRun.c2Latch = s.c2Latch;
    }
    if (s.props !== undefined) {
        for (k = 0; k < s.props.length; k++) {
            const parts = s.props[k].split(":");
            const pid = parts[0];
            if (pid !== undefined && pid !== "") {
                storyRun.props[pid] = {
                    broken: parts[1] === undefined ? true : parts[1] === "1",
                    hp: parts[2] === undefined ? 0 : (tonumber(parts[2]) ?? 0),
                    wedge: parts[3] === "1",
                    revealed: parts[4] === "1" ? true : undefined,
                };
            }
        }
    }
    const stTalents = createStoryTalents(s.seed);
    if (s.talentSeed !== undefined && s.talentSeed > 0) {
        stTalents.randomState = s.talentSeed;
    }
    stTalents.room = s.talentRoom ?? "";
    stTalents.ranks.vitality = s.talentVitality ?? 0;
    stTalents.ranks.reload = s.talentReload ?? 0;
    stTalents.ranks.guard = s.talentGuard ?? 0;
    stTalents.ranks.craft = s.talentCraft ?? 0;
    if (s.talentOffers !== undefined) {
        for (k = 0; k < s.talentOffers.length; k++) {
            const t = s.talentOffers[k];
            if (t === "vitality" || t === "reload" || t === "guard" || t === "craft") {
                stTalents.offers.push(t as Talent);
            }
        }
    }
    storyRun.story.talents = stTalents;
    current = idx;
    setMode(1);
    if (fe !== undefined) {
        fe.screen = "play";
    }
    play = undefined;
    ensurePlay(s.checkpoint > 0 ? { checkpoint: s.checkpoint } : undefined);
    const cur = play as Play | undefined;
    if (cur !== undefined) {
        if (s.cartAxle > 0 && cur.room.cart.bodyW > 0) {
            cur.cartAxle = s.cartAxle;
            cur.cartDocked = s.cartDocked;
        }
        if (s.playerX !== undefined && s.playerX >= 0) {
            cur.player.x = Math.max(cur.room.minX + 16, Math.min(cur.room.maxX - 16, s.playerX));
            cur.player.y = Math.max(0, s.playerY ?? 0);
            if (cur.room.depth !== undefined && s.playerDepth !== undefined) {
                cur.player.depth = Math.max(cur.room.depth.min, Math.min(cur.room.depth.max, s.playerDepth));
            }
        }
        if (cur.room.key === "gate" && s.gateTick !== undefined && s.gateTick > 0) {
            cur.gateTick = s.gateTick;
        }
        if (cur.room.key === "village") {
            if (s.hasBottle === true) cur.hasBottle = true;
            if (s.villagePassed === true) cur.passed = true;
        }
    }
    return play;
}

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
    if (startScreen === "splash") {
        fe.menus.resetSplash();
    }
    refreshTitleSessionFlag();
    grayboxLayer.visible = mode === 0;
    fe.setVisible(mode === 1);
    if (campaignLayer !== undefined) {
        campaignLayer.visible = mode === 2;
    }

    input = new Input();
    touchRouter = new TouchRouter(input.settings);
    touchRouter.attach(parent);
    input.bindTouch(touchRouter);

    gamepadRouter = new GamepadRouter(input.settings);
    gamepadRouter.attach(parent);
    input.bindGamepad(gamepadRouter);

    touchControls = new TouchControls(parent);

    // 系统返回键、窗口关闭、切后台与焦点切换生命周期统一治理
    parent.gslot("AppEvent", (eventType: string) => {
        if (eventType === "BackButton") {
            handleBackButton();
            return;
        }
        if (eventType === "Quit" || eventType === "Shutdown") {
            flushProfile();
            saveCurrentSession();
            input?.clearTransient(false);
            return;
        }
        if (eventType === "WillEnterBackground" || eventType === "DidEnterBackground" || eventType === "WindowFocusLost") {
            flushProfile();
            saveCurrentSession();
            input?.clearTransient(true);
            if (mode === 1 && fe !== undefined && fe.screen === "play" && play !== undefined && !play.paused) {
                play.paused = true;
                play.aimHold = 0;
                play.bottleAimX = -1;
                fe.menus.openPause();
            } else if (mode === 2 && play !== undefined && !play.paused) {
                play.paused = true;
            }
            if (fe !== undefined) {
                fe.audio.setPaused(true);
            }
            return;
        }
        if (eventType === "DidEnterForeground" || eventType === "WindowFocusGained") {
            if (fe !== undefined) {
                const paused = play !== undefined && play.paused
                    && ((mode === 1 && fe.screen === "play") || mode === 2);
                fe.audio.setPaused(paused);
            }
        }
    });

    // 开发与验收快捷键 + 瞬时按键边沿锁存（防止低帧率下短按 E / Space / Esc / 菜单方向键被轮询漏掉）
    parent.onKeyDown((key: KeyName) => {
        onFirstUserGesture();
        input?.markKeyboardActivity();
        if (key === KeyName.F11
            || (key === KeyName.Return && (Keyboard.isKeyPressed(KeyName.LAlt) || Keyboard.isKeyPressed(KeyName.RAlt)))) {
            toggleFullscreen();
            return;
        }
        if (mode === 1 && fe !== undefined && fe.screen === "play" && play !== undefined && !play.paused && key === KeyName.T) {
            play.toggleArtifactWeapon();
            return;
        }
        if (mode === 1 && fe !== undefined && fe.screen === "play" && play !== undefined && !play.paused
            && !play.craftBench.active && !play.reloadOpen && play.getStoryTalentOffers().length > 0) {
            if (key === KeyName.Num1) {
                play.chooseTalent(0);
                input?.consumePickRoom();
                return;
            }
            if (key === KeyName.Num2) {
                play.chooseTalent(1);
                input?.consumePickRoom();
                return;
            }
            if (key === KeyName.Num3) {
                play.chooseTalent(2);
                input?.consumePickRoom();
                return;
            }
        }
        const inPausedPlay = mode === 1 && fe !== undefined && fe.screen === "play" && play !== undefined && play.paused;
        if (fe !== undefined && mode === 1 && (fe.screen !== "play" || inPausedPlay)) {
            fe.menus.onKeyEvent(key);
        }
        if (input !== undefined && ((mode === 1 && fe !== undefined && fe.screen === "play" && !inPausedPlay) || mode === 2)) {
            if (key === KeyName.E) {
                input.interact.pressed = true;
            } else if (key === KeyName.Space) {
                input.jump.pressed = true;
            } else if (key === KeyName.Escape) {
                input.pause.pressed = true;
            } else if (key === KeyName.R && (play === undefined || (!play.craftBench.active && !play.reloadOpen))) {
                input.retry.pressed = true;
            }
        }
        if (mode === 2 && run?.trial !== undefined) return;
        if (isReleaseBuild()) return;
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

    // 验收钩子：保留 watch.input / watch.play / watch.room / watch.fe，并补充三模与多比例视口控制面
    const reg = (globalThis as unknown as { package: { loaded: Record<string, unknown> } }).package.loaded;
    reg["watch.input"] = input;
    reg["watch.touch"] = touchRouter;
    reg["watch.gamepad"] = gamepadRouter;
    reg["watch.fe"] = {
        setScreen: (sc: ScreenKind) => {
            if (fe === undefined) {
                return;
            }
            setMode(1);
            fe.screen = sc;
            if (sc === "splash") {
                fe.menus.resetSplash();
            } else if (sc === "chapters") {
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
            setSessionFile(name === "" ? "" : name + ".session");
            clearProfilePending();
            const loaded = loadSave();
            profile = loaded.state;
            profileStatus = loaded.status;
            profileDetail = loaded.detail;
            refreshTitleSessionFlag();
        },
        useTestSession: (name: string) => {
            setSessionFile(name);
            refreshTitleSessionFlag();
        },
        getSessionFile,
        hasSessionSave,
        saveSessionNow: () => saveCurrentSession(),
        clearSessionNow: () => {
            const ok = clearSession();
            refreshTitleSessionFlag();
            return ok;
        },
        continueStory: () => continueOfficialStory(),
        saveNow: () => saveSave(profile),
        getSaveFile,
        isRelease: () => isReleaseBuild(),
        getReleaseVersion: () => getReleaseConfig()?.version ?? "dev",
        toggleFullscreen: () => toggleFullscreen(),
        quitGame: () => quitGame(),
        startTrial: () => startTrial(),
        handleBackButton: () => handleBackButton(),
        getViewport: () => stageVp,
        getTouchController: () => touchControls,
        getTouchRouter: () => touchRouter,
        getGamepad: () => gamepadRouter,
        setGamepadSim: (state?: GamepadRawState) => {
            gamepadRouter?.setSimulatedState(state);
        },
        injectTouch: (phase: "began" | "moved" | "ended", id: number, x: number, y: number, fromMouse?: boolean) => {
            touchRouter?.injectTouch(phase, id, x, y, fromMouse);
        },
        getInputMode: () => input?.inputMode ?? "kbm",
        setInputMode: (m: InputMode) => {
            input?.setInputMode(m);
        },
        setModePref: (pref: InputModePref) => {
            input?.setModePref(pref);
        },
        applyViewportForTest: (w?: number, h?: number) => {
            if (w !== undefined && h !== undefined && w > 0 && h > 0) {
                testViewportOverride = { w, h };
                viewW = w;
                viewH = h;
            } else {
                testViewportOverride = undefined;
                viewW = View.size.width;
                viewH = View.size.height;
            }
            applySize();
            dirty = true;
            return stageVp;
        },
        getToast: () => fe?.getToastText() ?? "",
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
    // 标题「新的旅程」进序章视为正式开新局；章节直达始终起干净独立预览局，不泄漏或污染正式局状态。
    if (fresh || source === "chapter" || storyRun === undefined) {
        storyRun = createRun(20261124, source, profile);
    } else {
        storyRun.source = source;
    }
    ensurePlay();
    // 标题「开始游戏」是正式新局：首帧从 P01「叫醒」起播，章节直达/快跳不播。
    const firstPlay = play as Play | undefined;
    if (fresh && source === "official" && firstPlay !== undefined && ROOMS[current].key === "prologue") {
        firstPlay.phase = "prologue-wake";
    }
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
    flushProfile();
    if (storyRun !== undefined) {
        storyRun.source = source;
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
    stageVp = computeStageViewport(viewW, viewH);
    if (input !== undefined) {
        input.setStageViewport(stageVp);
    }
    if (fe !== undefined) {
        fe.setStagePlacement(stageVp);
    }
    if (campaignLayer !== undefined) {
        campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY);
    }
    if (grayboxLayer !== undefined) {
        grayboxLayer.position = Vec2(0, 0);
    }
}

function syncFrameAdapters(frameDt: number): void {
    if (input === undefined) {
        return;
    }
    const p = play;
    const isPlayMode = mode === 1 && fe !== undefined && fe.screen === "play" && p !== undefined;
    const isTrialMode = mode === 2 && p !== undefined;
    const gameplayActive = isPlayMode || isTrialMode;

    const storyTalentBoxes = isPlayMode && fe !== undefined && p !== undefined
        && !p.paused && !p.craftBench.active && !p.reloadOpen
        ? fe.getStoryTalentBoxes(p, stageVp.stageW, stageVp.stageH, input.isTouchMode())
        : [];

    if (touchControls !== undefined && touchRouter !== undefined) {
        let isFs = false;
        if (canToggleFullscreen()) {
            try {
                isFs = App.fullScreen;
            } catch {
                isFs = false;
            }
        }
        touchControls.syncContext({
            viewport: stageVp,
            mode,
            screen: fe !== undefined ? fe.screen : "title",
            play: p,
            run,
            cam: fe !== undefined ? fe.cam : undefined,
            input,
            router: touchRouter,
            assistHintsEnabled: fe !== undefined ? fe.contract.isAssistHintsEnabled() : false,
            isMuted: fe !== undefined ? fe.audio.isAllMuted() : false,
            isFullscreen: isFs,
            storyTalentBoxes,
            dt: frameDt,
        });
    }

    if (gamepadRouter !== undefined) {
        const trial = run?.trial;
        const trialEnded = isTrialMode && trial !== undefined && (trial.lost || run?.finished === true);
        const trialHasOffers = isTrialMode && trial !== undefined && trial.offers.length > 0 && p !== undefined && !p.paused && !trialEnded;
        const modal = !gameplayActive
            || (isPlayMode && p !== undefined && (p.paused || p.reloadOpen || p.craftBench.active))
            || (isTrialMode && p !== undefined && (p.paused || trialEnded));
        const reloadActive = isPlayMode && p !== undefined && !p.paused && p.reloadOpen;
        const craftActive = isPlayMode && p !== undefined && !p.paused && p.craftBench.active;
        const talentOfferCount = isPlayMode && p !== undefined && !p.paused && !p.craftBench.active && !p.reloadOpen
            ? p.getStoryTalentOffers().length
            : (trialHasOffers && trial !== undefined ? trial.offers.length : 0);
        const cutsceneBlocking = isPlayMode && p !== undefined ? isCutsceneBlockingPlay(p) : false;
        const allowDepth = p !== undefined && p.room.depth !== undefined
            && (!p.childMode || p.phase === "prologue-escape");
        const peacefulRoom = p !== undefined && (p.room.key === "museum" || p.room.key === "tower");
        const canShoot = gameplayActive && p !== undefined && !p.childMode && !peacefulRoom && !p.gripping
            && !modal && !cutsceneBlocking && !trialHasOffers && p.escort.state !== "calming";
        const canBottleAim = isPlayMode && p !== undefined && p.childMode && p.room.key === "village"
            && p.hasBottle && !p.passed && !modal && !cutsceneBlocking;
        const inLowArch = p !== undefined && p.room.arch.h > 0
            && p.player.x >= p.room.arch.x0 - 10 && p.player.x <= p.room.arch.x1 + 10
            && p.player.y <= p.room.arch.y + p.room.arch.h;
        const inTowerEnd = isPlayMode && p !== undefined && p.room.key === "tower" && p.phase === "tower-end";

        let playerScreenX = stageVp.stageW * 0.5;
        let playerScreenY = stageVp.stageH * 0.38;
        if (p !== undefined) {
            if (isPlayMode && fe !== undefined) {
                playerScreenX = fe.cam.sx(p.player.x + p.player.facing * 8);
                playerScreenY = fe.cam.sy(p.player.y + p.player.h * 0.72, p.player.depth);
            } else {
                // 护送试炼（mode === 2）按 Play.view 精确投影主角屏幕位置，保证手柄方向锥磁吸准心不偏心
                const vz = p.view.zoom > 0 ? p.view.zoom : 1;
                playerScreenX = stageVp.stageW * 0.5 + (p.player.x + p.player.facing * 8 - p.cam.x) * vz;
                playerScreenY = stageVp.stageH * 0.5 + (p.player.y + p.player.h * 0.72 + p.player.depth * DEPTH_Y_SCALE - p.cam.y) * vz;
            }
        }

        const enemyTargets = canShoot && p !== undefined
            ? (isPlayMode && fe !== undefined
                ? collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH)
                : collectTrialAimTargets(p, stageVp.stageW, stageVp.stageH))
            : [];

        const gpCtx: GamepadFrameContext = {
            stageW: stageVp.stageW,
            stageH: stageVp.stageH,
            uiScale: stageVp.uiScale,
            modal,
            gameplayActive,
            reloadActive,
            craftActive,
            talentOfferCount,
            childMode: p !== undefined && p.childMode,
            allowDepth,
            canShoot,
            canBottleAim,
            playerRolling: p !== undefined && p.player.rollT > 0,
            inLowArch,
            inTowerEnd,
            playerFacing: p !== undefined ? p.player.facing : 1,
            playerScreenX,
            playerScreenY,
            enemyTargets,
        };
        gamepadRouter.setFrameContext(gpCtx, frameDt);
    }
}

function renderTouchOverlay(): void {
    if (touchControls !== undefined && touchRouter !== undefined) {
        touchControls.render(touchRouter);
    }
}

function tick(frameDt: number): void {
    appClock += Math.min(0.05, Math.max(0, frameDt));
    const w = testViewportOverride !== undefined ? testViewportOverride.w : View.size.width;
    const h = testViewportOverride !== undefined ? testViewportOverride.h : View.size.height;
    if (w !== viewW || h !== viewH) {
        viewW = w;
        viewH = h;
        applySize();
        dirty = true;
    }
    if (input === undefined) {
        return;
    }
    syncFrameAdapters(frameDt);
    input.update();

    if (input.userInteracted) {
        onFirstUserGesture();
    }
    if (input.muteTogglePressed && fe !== undefined) {
        input.muteTogglePressed = false;
        fe.audio.toggleAllMuted();
    }
    if (input.fullscreenTogglePressed) {
        input.fullscreenTogglePressed = false;
        toggleFullscreen();
    }
    if (input.artifactTogglePressed && mode === 1 && fe !== undefined && fe.screen === "play" && play !== undefined && !play.paused) {
        input.artifactTogglePressed = false;
        play.toggleArtifactWeapon();
    }
    if (input.bottleCanceled && play !== undefined) {
        input.bottleCanceled = false;
        play.aimHold = 0;
        play.bottleAimX = -1;
    }

    if (mode === 2 && run?.trial !== undefined) {
        tickCampaign(frameDt);
        renderTouchOverlay();
        return;
    }

    if (mode === 1 && fe !== undefined && fe.screen === "play" && play !== undefined && !play.paused
        && !play.craftBench.active && play.getStoryTalentOffers().length > 0
        && input.pickRoom >= 1 && input.pickRoom <= 3) {
        play.chooseTalent(input.pickRoom - 1);
        input.pickRoom = 0;
    }

    if (isReleaseBuild()) {
        input.toggleView.pressed = false;
        input.pickRoom = 0;
        input.tab.pressed = false;
    } else {
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
    }

    if (mode === 2) {
        tickCampaign(frameDt);
    } else if (mode === 1) {
        tickFrontend(frameDt);
    } else if (dirty) {
        redrawGraybox();
        dirty = false;
    }
    renderTouchOverlay();
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
        fe.bindPlay(play, stageVp.stageW, stageVp.stageH);
    }
}

function startTrial(): void {
    current = 0;
    trialTalentSelected = 0;
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

    const zoneTap = input.touchZoneTap;
    input.touchZoneTap = "";

    const trial = run?.trial;
    if (trial !== undefined) {
        const ended = trial.lost || run?.finished === true;
        const pick = input.pickRoom;
        input.pickRoom = 0;

        if (zoneTap === "trial:resume" && p.paused && !ended) {
            p.paused = false;
            clock.reset();
            input.consumeEdges();
            drawCampaign(p);
            return;
        }
        if (zoneTap === "trial:retry") {
            input.consumeEdges();
            startTrial();
            return;
        }
        if (zoneTap === "trial:title") {
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

        if ((ended && (input.pause.pressed || input.navBack)) || (p.paused && input.interact.pressed)) {
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
            const restart = input.retry.pressed || (ended && input.navConfirm);
            input.consumeEdges();
            if (restart) startTrial();
            else drawCampaign(p);
            return;
        }
        input.retry.pressed = false;
        if (trial.offers.length > 0 && !p.paused && !input.pause.pressed) {
            if (trialTalentSelected >= trial.offers.length) {
                trialTalentSelected = 0;
            }
            if (zoneTap.indexOf("talent:") === 0) {
                const idx = parseInt(zoneTap.slice(7), 10);
                if (idx >= 0 && idx < trial.offers.length) {
                    p.chooseTalent(idx);
                }
            } else if (pick > 0) {
                p.chooseTalent(pick - 1);
            } else {
                const delta = input.talentDelta
                    + ((input.navRight || input.navNextTab) ? 1 : 0)
                    - ((input.navLeft || input.navPrevTab) ? 1 : 0);
                if (delta !== 0) {
                    trialTalentSelected = (trialTalentSelected + delta + trial.offers.length) % trial.offers.length;
                }
                if (input.talentConfirm || input.navConfirm) {
                    p.chooseTalent(trialTalentSelected);
                }
            }
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
    if (input.pause.pressed || (p.paused && input.navBack)) {
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
    const w = stageVp.stageW;
    const h = stageVp.stageH;
    const safeL = stageVp.safeUi.left * stageVp.uiScale;
    const safeT = stageVp.safeUi.top * stageVp.uiScale;
    p.draw(campaignDraw, w, h);
    const room = CAMPAIGN_ROOMS[current];
    const c = room.campaign;
    const r = run;
    let line = room.name;
    if (c !== undefined) {
        line = line + "  " + c.chapter + c.act + " · 目标 " + goalLabel(c.goal)
            + " · 本段 " + mmss(r === undefined ? 0 : (r.roomTicks[room.key] ?? 0)) + " / 预算 " + mmss(c.budget * 60);
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
        campaignHud.position = Vec2(24 + safeL, h - 14 - safeT);
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
            const gpMode = input !== undefined && input.isGamepadMode();
            const touchMode = input !== undefined && input.isTouchMode();
            if (trial.lost || r.finished) {
                sub = "种子 " + r.seed + (gpMode ? " · A 再开一局 · START 返回标题" : (touchMode ? " · 点下方按钮再开或返回标题" : " · R 再开一局 · Esc 返回标题"));
            } else if (p.paused) {
                sub = "种子 " + r.seed + (gpMode ? " · START 继续 · 长按BACK 重开 · Y 返回标题" : (touchMode ? " · 点下方按钮继续/重开/返回标题" : " · Esc 继续 · R 重新开局 · E 返回标题"));
            } else if (trial.offers.length > 0) {
                sub = trial.offers.map((talent, index) => {
                    const mark = gpMode && index === trialTalentSelected ? "▶ " : "";
                    return mark + (index + 1) + " " + talentNames[talent];
                }).join("　");
            } else {
                sub = "厚甲" + trial.ranks.vitality + " 熟铳" + trial.ranks.reload + " 护身" + trial.ranks.guard + " 巧手" + trial.ranks.craft + " · " + (p.flash !== "" ? p.flash : (r.joined ? "小满跟随" : "小满等待"));
            }
        }
        campaignSub.text = sub;
        campaignSub.position = Vec2(24 + safeL, h - 44 - safeT);
        campaignSub.visible = true;
    }
}

function tickFrontend(frameDt: number): void {
    if (fe === undefined || input === undefined) {
        return;
    }

    // 1. 序幕 / 标题 / 章节直达 / 操作图鉴
    if (fe.screen !== "play") {
        const act = fe.renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH);
        input.consumeEdges();
        if (act.type === "splashDone") {
            fe.menus.resetInput();
            fe.screen = "title";
        } else if (act.type === "trial") {
            startTrial();
        } else if (act.type === "continue") {
            if (continueOfficialStory() === undefined) {
                enterPlayRoom(officialStartIndex(), "official", true);
            }
        } else if (act.type === "start") {
            // 馆内中途退出过：从档案里的同一步续读；否则照常从序章起并清除旧局中档。
            clearSession();
            refreshTitleSessionFlag();
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
        } else if (act.type === "quit") {
            quitGame();
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

    p.aimX = input.mx;
    p.aimY = input.my;

    const zoneTap = input.touchZoneTap;
    input.touchZoneTap = "";

    const offers = p.getStoryTalentOffers();
    if (!p.paused && !p.craftBench.active && !p.reloadOpen && offers.length > 0) {
        if (fe.hud.talentSelected >= offers.length) {
            fe.hud.talentSelected = 0;
        }
        if (zoneTap.indexOf("talent:") === 0) {
            const idx = parseInt(zoneTap.slice(7), 10);
            if (idx >= 0 && idx < offers.length && p.chooseTalent(idx)) {
                input.fire.pressed = false;
            }
        } else {
            if (input.talentDelta !== 0) {
                fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + offers.length) % offers.length;
                input.talentDelta = 0;
            }
            if (input.talentConfirm) {
                p.chooseTalent(fe.hud.talentSelected);
                input.talentConfirm = false;
                input.fire.pressed = false;
            } else if ((input.uiPressed || (input.inputMode !== "gamepad" && input.fire.pressed))
                && fe.tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH)) {
                input.fire.pressed = false;
            }
        }
    }

    // 北塔尾声支持手柄确认键 / 触屏确认钮重新启程（与键盘 E 共享 8 秒防误跳闸门）
    if (!p.paused && p.room.key === "tower" && p.phase === "tower-end" && input.navConfirm) {
        input.interact.pressed = true;
    }

    if (!p.paused && p.craftBench.active && input.pause.pressed) {
        p.closeCraftBench();
        input.consumeEdges();
        return;
    }
    if (!p.paused && input.pause.pressed) {
        p.paused = true;
        p.aimHold = 0;
        p.bottleAimX = -1;
        saveCurrentSession();
        fe.menus.openPause();
        input.clearTransient(true);
        input.consumeEdges();
    }

    if (p.paused) {
        // 菜单独占这一帧的输入。恢复时从下一帧开始推进游戏。
        clock.reset();
        const pauseAct = fe.renderPlay(frameDt, p, input, stageVp.stageW, stageVp.stageH);
        input.consumeEdges();
        if (pauseAct.type === "resume") {
            p.paused = false;
        } else if (pauseAct.type === "retry") {
            ensurePlay({ checkpoint: p.checkpoint });
        } else if (pauseAct.type === "openChapters") {
            fe.audio.stopRoomTransient();
            fe.audio.setPaused(false);
            fe.menus.openChapters(current);
            fe.screen = "chapters";
        } else if (pauseAct.type === "toggleFullscreen") {
            toggleFullscreen();
        } else if (pauseAct.type === "quit") {
            quitGame();
        } else if (pauseAct.type === "toTitle") {
            saveCurrentSession();
            refreshTitleSessionFlag();
            fe.menus.resetInput();
            fe.screen = "title";
        }
        return;
    }

    const inTowerEnding = p.room.key === "tower" && p.phase !== "tower-wait";
    const inPrologueIntro = p.room.key === "prologue"
        && (p.phase === "prologue-wake" || p.phase === "prologue-shadow" || p.phase === "prologue-escape" || p.phase === "prologue-hide");
    if (input.retry.pressed && !inTowerEnding && !inPrologueIntro && !p.craftBench.active && !p.reloadOpen) {
        input.consumeEdges();
        // 重试保留检查点，并重新绑定前端相机与运行态验收钩子。
        ensurePlay({ checkpoint: p.checkpoint });
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
            // 片尾回序章：重开一份正式局内状态（路线/材料/拾取/检查点清零），档案仍是同一份。
            if (p.restartStory) {
                if (storyRun !== undefined && storyRun.source === "official") {
                    clearSession();
                    refreshTitleSessionFlag();
                }
                const nextSource: RunSource = (storyRun !== undefined && storyRun.source === "debug") ? "debug" : "official";
                storyRun = createRun(20261124, nextSource, profile);
            }
            current = idx;
            ensurePlay();
            const fresh = play;
            if (fresh !== undefined) {
                if (p.restartStory && ROOMS[current].key === "prologue" && storyRun?.source === "official") {
                    fresh.phase = "prologue-wake";
                }
                fresh.adoptEvents(leaving);
            }
            if (!p.restartStory) {
                saveCurrentSession();
            }
            clock.reset();
            dirty = true;
        }
        return;
    }

    // 档案变化（正式通关、井口取器）在下一个渲染帧落盘；写失败保留旧文件，下次再试。
    flushProfile();
    if (p.run.finished && p.run.source === "official" && hasSessionSave()) {
        clearSession();
        refreshTitleSessionFlag();
    } else if (p.sessionDirty) {
        saveCurrentSession();
    }
    fe.renderPlay(frameDt, p, input, stageVp.stageW, stageVp.stageH);
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
