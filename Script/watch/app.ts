import { App, Node, Size, Vec2, View } from "Dora";
import { getActiveTarget } from "Script/watch/target";
import { ROOMS } from "Script/watch/rooms";
import { Input } from "Script/watch/input";
import { Play } from "Script/watch/play";
import { STEP, StepClock } from "Script/watch/clock";
import { InputMode, InputModePref, saveControlSettings } from "Script/watch/controls_config";
import {
    StageViewport,
    canQuitApp,
    canToggleFullscreen,
    computeStageViewport,
    getReleaseConfig,
    isDesktopNative,
    isReleaseMode,
} from "Script/watch/platform";
import { WatchFrontend } from "Script/watch/fe/frontend";
import { createRun, createStoryTalents, normalizeLegacyTalent, RunSource, RunState, Talent } from "Script/watch/run";
import {
    emptySave, loadSave, saveSave, SaveState, setSaveFile, getSaveFile,
    markProfilePending, flushProfile as flushSaveProfile, clearProfilePending, profilePending,
    SessionSave, SaveSlotId, loadSession, saveSession, clearSession, hasSessionSave, setSessionFile, getSessionFile,
    listSaveSlots, loadSlot, saveSlot, deleteSlot, nowUnixSeconds,
} from "Script/watch/save";
import { ScreenKind } from "Script/watch/fe/ui/menus";

let root: Node.Type | undefined;
/** 正式剧情的跨房状态；模式 1 整局一份，切房与重试都复用它。 */
let storyRun: RunState | undefined;
/** 跨局档案：正式通关与神器只写在这里，与每局的 RunState 分开。 */
let profile: SaveState = emptySave();
let profileStatus = "missing";
let profileDetail = "";
let current = 0;
let viewW = 0;
let viewH = 0;
let input: Input | undefined;
let play: Play | undefined;
let fe: WatchFrontend | undefined;
const clock = new StepClock();
let stageVp: StageViewport = computeStageViewport(1280, 720);
let testViewportOverride: { w: number; h: number } | undefined;
let audioUnlocked = false;
let appClock = 0;
let lastBackPressClock = -10;
let runPlaySeconds = 0;
let autosaveTimer = 0;
let autosaveCooldown = 0;
let lastAutosaveSig = "";
let windowFocused = true;
let lastAppliedIdle: boolean | undefined;
let pendingWinSizeSaveTimer = -1;
let startupNoticeShown = false;
const WINDOW_CLOSE_FORCE_COUNT = 4;

function randomRunSeed(): number {
    return Math.max(1, Math.floor(Math.abs(App.rand)) % 2147483646);
}

function isReleaseBuild(): boolean {
    return isReleaseMode();
}

function syncPowerMode(): void {
    if (!isDesktopNative()) {
        return;
    }
    // 仅在窗口失焦/切后台时启用 idled 省电，避免片头/标题/暂歇菜单因 SDL_WaitEvent 冻结动效或切页后需晃鼠标才刷新。
    const wantIdle = !windowFocused;
    if (lastAppliedIdle === wantIdle) {
        return;
    }
    lastAppliedIdle = wantIdle;
    try {
        App.idled = wantIdle;
    } catch {
        // 忽略不支持 idled 的宿主环境
    }
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
        if (input !== undefined) {
            input.settings.fullscreen = next;
            saveControlSettings(input.settings);
        }
        return next;
    } catch {
        return false;
    }
}

function slotDisplayName(slot: SaveSlotId): string {
    if (slot === "auto") return "自动存档";
    if (slot === 1) return "档案一";
    if (slot === 2) return "档案二";
    return "档案三";
}

function quitGame(): void {
    flushProfile();
    saveCurrentSession();
    if (input !== undefined && isDesktopNative()) {
        try {
            input.settings.fullscreen = App.fullScreen;
            if (!App.fullScreen) {
                const ws = App.winSize;
                if (ws.width >= 640 && ws.height >= 360) {
                    input.settings.winWidth = Math.round(ws.width);
                    input.settings.winHeight = Math.round(ws.height);
                }
            }
            saveControlSettings(input.settings);
        } catch {
            // ignore
        }
    }
    input?.clearTransient(false);
    if (fe !== undefined) {
        fe.audio.stopRoomTransient();
    }
    if (!canQuitApp()) {
        // Web / Dora Go 源码模式不允许停死宿主进程：安全回退到标题页
        current = 0;
        play = undefined;
        clock.reset();
        if (fe !== undefined) {
            fe.audio.stopRoomTransient();
            fe.screen = "title";
            fe.menus.resetInput();
        }
        return;
    }
    App.shutdown();
}

function handleBackButton(): void {
    if (fe === undefined) {
        return;
    }
    if (fe.screen === "splash") {
        fe.menus.resetSplash();
        fe.screen = "title";
        fe.menus.resetInput();
        return;
    }
    if (fe.screen === "chapters" || fe.screen === "controls" || fe.screen === "saves" || fe.screen === "settings" || fe.screen === "epilogue" || fe.screen === "history") {
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
        if (play.escortFailed) {
            fe.audio.stopRoomTransient();
            fe.menus.resetInput();
            fe.screen = "title";
            input?.clearTransient(true);
            return;
        }
        if (fe.roguelikeUi.isLedgerOpen()) {
            fe.roguelikeUi.closeLedger();
            return;
        }
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

/**
 * Windows 窗口右上角「×」拦截状态机：
 * - 单次点击：局内自动存档并弹出 ESC 暂歇菜单；若已在暂歇/标题页则将光标聚焦至「退出游戏」；
 * - 2 秒内连续点击 4 次：立即安全落盘并强制退出（原生 C++ 渲染线程亦同步计数兜底，主循环卡死也可强退）。
 */
function handleWindowClose(nativeCount?: number): void {
    // 原生消息带有按实际时间计算的连击次数；失焦或低帧率时游戏时钟会减慢。
    const count = nativeCount !== undefined && nativeCount > 0 ? Math.floor(nativeCount) : 1;
    if (count >= WINDOW_CLOSE_FORCE_COUNT || fe === undefined) {
        quitGame();
        return;
    }

    const remain = Math.max(1, WINDOW_CLOSE_FORCE_COUNT - count);
    if (fe.screen === "splash") {
        fe.menus.resetSplash();
        fe.screen = "title";
        fe.menus.focusQuit("title");
        fe.showToast("已跳过片头 · 再连点关闭 " + remain + " 次可强制退出", 2.6);
        return;
    }
    if (fe.screen === "play" && play !== undefined) {
        if (fe.roguelikeUi.isLedgerOpen()) {
            fe.roguelikeUi.closeLedger();
        }
        if (!play.paused) {
            if (play.craftBench.active) {
                play.closeCraftBench();
            }
            play.paused = true;
            play.aimHold = 0;
            play.bottleAimX = -1;
            saveCurrentSession();
            fe.menus.openPause();
            fe.audio.playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08);
            input?.clearTransient(true);
            syncPowerMode();
            fe.showToast("已暂歇并自动存档 · 如需强制退出请连点关闭（还差 " + remain + " 次）", 3.0);
            return;
        }
        fe.menus.focusQuit("play");
        fe.audio.playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.50, 0.045);
        fe.showToast("点击「退出游戏」安全退出 · 连点关闭还差 " + remain + " 次强制退出", 2.6);
        return;
    }
    if (fe.screen === "title") {
        fe.menus.focusQuit("title");
        fe.audio.playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.50, 0.045);
        fe.showToast("点击「退出游戏」安全退出 · 连点关闭还差 " + remain + " 次强制退出", 2.6);
        return;
    }
    fe.screen = "title";
    fe.menus.focusQuit("title");
    fe.audio.playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05);
    fe.showToast("已返回标题 · 点击「退出游戏」或再连点关闭 " + remain + " 次强制退出", 2.6);
}

function canSaveSession(): boolean {
    if (play === undefined || storyRun === undefined) {
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
        const has = hasSessionSave();
        fe.menus.hasSession = has;
        if (has) {
            const loaded = loadSession();
            fe.menus.setSessionRoomKey(loaded.status === "ok" && loaded.state !== undefined ? loaded.state.roomKey : "");
        } else {
            fe.menus.setSessionRoomKey("");
        }
        fe.menus.refreshSaveSlots();
    }
}

/** 清档成功后才能创建新局，失败时把重试留给玩家。 */
function clearSessionForRestart(): boolean {
    if (!clearSession()) {
        fe?.showToast("清理自动存档失败，请检查目录写权限后重试", 3.0);
        return false;
    }
    refreshTitleSessionFlag();
    return true;
}

function exportSessionWithMeta(): SessionSave | undefined {
    if (play === undefined) {
        return undefined;
    }
    const snap = play.exportSession();
    snap.savedAt = nowUnixSeconds();
    snap.playSeconds = Math.max(0, Math.floor(runPlaySeconds));
    return snap;
}

function sessionMilestoneSignature(p: Play): string {
    const inv = p.run.inventory;
    let takenCount = 0;
    for (const k in p.run.taken) {
        if (p.run.taken[k] === true) takenCount++;
    }
    let segCount = 0;
    for (const k in p.run.story.segments) {
        if (p.run.story.segments[k] === true) segCount++;
    }
    return p.room.key
        + "|" + p.checkpoint
        + "|" + p.phase
        + "|" + p.run.story.hp
        + "|" + p.run.story.route
        + "|" + inv.wood + ":" + inv.bell + ":" + inv.scrap + ":" + inv.wedge + ":" + inv.ammo
        + "|" + takenCount + ":" + segCount
        + "|" + (p.cartDocked ? "1" : "0")
        + "|" + (p.hasBottle ? "1" : "0")
        + "|" + (p.passed ? "1" : "0")
        + "|" + p.equippedWeapon;
}

function saveCurrentSession(): boolean {
    if (!canSaveSession() || play === undefined) {
        return false;
    }
    const snap = exportSessionWithMeta();
    if (snap === undefined) {
        return false;
    }
    const ok = saveSession(snap);
    play.sessionDirty = !ok;
    if (ok) {
        autosaveTimer = 0;
        autosaveCooldown = 2.5;
        lastAutosaveSig = sessionMilestoneSignature(play);
    }
    refreshTitleSessionFlag();
    return ok;
}

function saveToManualSlot(slot: SaveSlotId): boolean {
    if (!canSaveSession() || play === undefined) {
        fe?.showToast("当前段落无法手动存档", 2.0);
        return false;
    }
    const snap = exportSessionWithMeta();
    if (snap === undefined) {
        return false;
    }
    const ok = saveSlot(slot, snap);
    refreshTitleSessionFlag();
    if (ok) {
        fe?.showToast("已保存至" + slotDisplayName(slot), 2.0);
    } else {
        fe?.showToast("保存失败，请检查目录写权限", 2.4);
    }
    return ok;
}

function deleteSaveSlotById(slot: SaveSlotId): boolean {
    const ok = deleteSlot(slot);
    refreshTitleSessionFlag();
    fe?.showToast(ok ? ("已删除" + slotDisplayName(slot)) : "删除存档失败", 2.0);
    return ok;
}

function continueOfficialStory(): Play | undefined {
    return loadOfficialSlot("auto");
}

function loadOfficialSlot(slot: SaveSlotId): Play | undefined {
    if (slot === "auto" && play?.escortFailed && play.run.source === "official" && play.sessionDirty) {
        // 落盘失败时仍可从内存进入已结算的新一轮，切房会再次尝试保存。
        play.confirmEscortRestart();
        applyRoomTransition(play);
        if (fe !== undefined) fe.screen = "play";
        return play;
    }
    const res = loadSlot(slot);
    if (res.status !== "ok" || res.state === undefined) {
        refreshTitleSessionFlag();
        return undefined;
    }
    const s: SessionSave = res.state;
    const idx = roomIndexByKey(s.roomKey);
    if (ROOMS[idx].key !== s.roomKey) {
        return undefined;
    }
    runPlaySeconds = Math.max(0, s.playSeconds ?? 0);
    autosaveTimer = 0;
    autosaveCooldown = 2.5;
    lastAutosaveSig = "";
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
            const parts: string[] = s.props[k].split(":");
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
    if (s.escortAttempt !== undefined && s.escortAttempt >= 1) {
        stTalents.attempt = s.escortAttempt;
    }
    if (s.escortVariant !== undefined && s.escortVariant >= 0) {
        stTalents.variant = s.escortVariant;
    }
    stTalents.deferred = s.talentDeferred === true;
    stTalents.room = s.talentRoom ?? "";
    if (s.talentRanks !== undefined && s.talentRanks.length > 0) {
        for (k = 0; k < s.talentRanks.length; k++) {
            const parts: string[] = s.talentRanks[k].split(":");
            const norm = parts[0] !== undefined ? normalizeLegacyTalent(parts[0]) : undefined;
            const rk = parts[1] !== undefined ? (tonumber(parts[1]) ?? 0) : 0;
            if (norm !== undefined && rk > 0) {
                stTalents.ranks[norm] = (stTalents.ranks[norm] ?? 0) + Math.floor(rk);
            }
        }
    } else {
        // 兼容旧版 4 本领字段迁移
        stTalents.ranks.vitality = s.talentVitality ?? 0;
        stTalents.ranks.focus = s.talentReload ?? 0;
        stTalents.ranks.guard = s.talentGuard ?? 0;
        stTalents.ranks.salvage = s.talentCraft ?? 0;
    }
    if (s.talentOffers !== undefined) {
        for (k = 0; k < s.talentOffers.length; k++) {
            const norm = normalizeLegacyTalent(s.talentOffers[k]);
            if (norm !== undefined) {
                stTalents.offers.push(norm);
            }
        }
    }
    storyRun.story.talents = stTalents;
    current = idx;
    clock.reset();
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
        // 序章 P01/P02 期间自动落盘时按设计重播 P01 叫醒，避免静默跳到 prologue-wait。
        if (cur.room.key === "prologue"
            && (s.phase === ""
                || s.phase === "prologue-wake"
                || s.phase === "prologue-shadow"
                || s.phase === "prologue-escape"
                || s.phase === "prologue-hide")) {
            cur.phase = "prologue-wake";
        }
        // 男主护送 1..5 续读兜底：非工台状态下保持背负，防止旧档 carry=false 导致 CarryPose 失活。
        if (cur.room.key.indexOf("escort") === 0 && s.route === "soldier" && !cur.craftBench.active && !cur.carryOn) {
            cur.carryOn = true;
            storyRun.story.carry = true;
        }
    }
    return play;
}

export function start(parent: Node.Type, _initialMode: number = 1, startScreen: ScreenKind = "title"): void {
    root = parent;

    // 挂载菜单与游戏前端。
    // 读档：缺文件按新档起局；损坏/版本不支持时保留原文件并报告，仍可继续玩。
    const loaded = loadSave();
    profile = loaded.state;
    profileStatus = loaded.status;
    profileDetail = loaded.detail;
    fe = new WatchFrontend(parent);
    fe.screen = startScreen;
    if (startScreen === "splash") {
        fe.menus.resetSplash();
    }
    refreshTitleSessionFlag();
    fe.setVisible(true);

    input = new Input();
    fe.audio.applyUserVolumes(input.settings);
    fe.contract.setAssistHintsEnabled(input.settings.assistHints);
    if (input.settings.muted) {
        fe.audio.setAllMuted(true);
    }
    fe.menus.onToggleFullscreen = () => {
        toggleFullscreen();
    };
    // 桌面原生端启动时恢复持久化的显示偏好（全屏或上次窗口大小）
    if (isDesktopNative() && canToggleFullscreen() && testViewportOverride === undefined) {
        try {
            if (input.settings.fullscreen) {
                if (!App.fullScreen) {
                    App.fullScreen = true;
                }
            } else if (input.settings.winWidth >= 640 && input.settings.winHeight >= 360) {
                const curSize = App.winSize;
                if (Math.abs(curSize.width - input.settings.winWidth) > 2
                    || Math.abs(curSize.height - input.settings.winHeight) > 2) {
                    App.winSize = Size(input.settings.winWidth, input.settings.winHeight);
                }
            }
        } catch {
            // 无头或不支持窗口尺寸修改的宿主静默跳过
        }
    }
    windowFocused = true;
    lastAppliedIdle = undefined;
    startupNoticeShown = false;
    syncPowerMode();
    input.attach(parent, {
        onFirstUserGesture: () => {
            onFirstUserGesture();
            input?.markKeyboardActivity();
        },
        onToggleFullscreen: () => {
            toggleFullscreen();
        },
        onKeyDownEvent: (key: string) => {
            if (fe?.screen === "play" && play !== undefined && !play.paused) {
                if (key === "1" || key === "2" || key === "3") {
                    input?.requestPickRoom(Number(key));
                    return;
                }
                if (key === "T" && !play.escortFailed && !play.talentModalActive && !fe.roguelikeUi.isLedgerOpen()) {
                    play.toggleArtifactWeapon();
                    return;
                }
            }
            const inPausedPlay = fe !== undefined && fe.screen === "play" && play !== undefined && play.paused;
            if (fe !== undefined && (fe.screen !== "play" || inPausedPlay)) {
                fe.menus.onKeyEvent(key);
            }
            if (input !== undefined && (fe !== undefined && fe.screen === "play" && !inPausedPlay)) {
                if (key === "E") {
                    input.interact.pressed = true;
                } else if (key === "Space") {
                    input.jump.pressed = true;
                } else if (key === "Escape") {
                    input.pause.pressed = true;
                }
            }
        },
    });

    // 窗口尺寸或全屏状态变化时同步持久化设置（尺寸拖拽防抖落盘）
    parent.gslot("AppChange", (settingName: string) => {
        if (input === undefined || !isDesktopNative()) {
            return;
        }
        if (settingName === "FullScreen") {
            try {
                input.settings.fullscreen = App.fullScreen;
                saveControlSettings(input.settings);
            } catch {
                // ignore
            }
        } else if (settingName === "Size") {
            pendingWinSizeSaveTimer = 0.45;
        }
    });

    // 系统返回键、窗口关闭、切后台与焦点切换生命周期统一治理
    parent.gslot("AppEvent", (eventType: string, payload?: unknown) => {
        if (eventType === "BackButton") {
            handleBackButton();
            return;
        }
        if (eventType === "WindowClose") {
            handleWindowClose(typeof payload === "number" ? payload : undefined);
            return;
        }
        if (eventType === "Quit" || eventType === "Shutdown") {
            flushProfile();
            saveCurrentSession();
            input?.clearTransient(false);
            return;
        }
        if (eventType === "WillEnterBackground" || eventType === "DidEnterBackground" || eventType === "WindowFocusLost") {
            windowFocused = false;
            flushProfile();
            saveCurrentSession();
            input?.clearTransient(true);
            if (fe !== undefined && fe.screen === "play" && play !== undefined && !play.paused && !play.escortFailed) {
                play.paused = true;
                play.aimHold = 0;
                play.bottleAimX = -1;
                fe.menus.openPause();
            }
            if (fe !== undefined) {
                fe.audio.setPaused(true);
            }
            syncPowerMode();
            return;
        }
        if (eventType === "DidEnterForeground" || eventType === "WindowFocusGained") {
            windowFocused = true;
            if (fe !== undefined) {
                const paused = play !== undefined && play.paused && fe.screen === "play";
                fe.audio.setPaused(paused);
            }
            syncPowerMode();
        }
    });

    viewW = View.size.width;
    viewH = View.size.height;
    applySize();

    // 验收钩子：保留 watch.input / watch.play / watch.room / watch.fe，并补充三模与多比例视口控制面
    const reg = (globalThis as unknown as { package: { loaded: Record<string, unknown> } }).package.loaded;
    reg["watch.input"] = input;
    reg["watch.touch"] = input.getTouchRouter();
    reg["watch.gamepad"] = input.getGamepadRouter();
    reg["watch.fe"] = {
        setScreen: (sc: ScreenKind) => {
            if (fe === undefined) {
                return;
            }
            clock.reset();
            fe.screen = sc;
            if (sc === "splash") {
                fe.menus.resetSplash();
            } else if (sc === "chapters") {
                fe.menus.openChapters();
            } else if (sc === "epilogue") {
                fe.menus.openEpilogue(
                    play !== undefined && play.storyRoute === "soldier" ? "reunion" : "lamp",
                    profile.childCleared && profile.soldierCleared,
                );
            } else if (sc === "history") {
                fe.menus.openHistory(false);
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
        // 验收钩子：按标题「新的旅程」的真实入口开一局（official 来源、全新 storyRun，可传固定 seed 便于回放复现）。
        startStory: (seed?: number) => {
            enterPlayRoom(officialStartIndex(), "official", true, seed);
            return play;
        },
        // 章节预览与菜单「章节」页的 jump 同一入口（chapter 来源，只演出不记档）。
        previewChapter: (idx: number, routeOrSeed?: "child" | "soldier" | number, seed?: number) => {
            enterPlayRoom(idx, "chapter", false, typeof routeOrSeed === "number" ? routeOrSeed : seed,
                typeof routeOrSeed === "string" ? routeOrSeed : undefined);
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
        listSaveSlots: () => listSaveSlots(),
        saveToSlot: (slot: SaveSlotId) => saveToManualSlot(slot),
        loadFromSlot: (slot: SaveSlotId) => loadOfficialSlot(slot),
        deleteSlot: (slot: SaveSlotId) => deleteSaveSlotById(slot),
        canSaveSession: () => canSaveSession(),
        saveNow: () => saveSave(profile),
        getSaveFile,
        isRelease: () => isReleaseBuild(),
        getReleaseVersion: () => getReleaseConfig()?.version ?? "dev",
        toggleFullscreen: () => toggleFullscreen(),
        quitGame: () => quitGame(),
        handleBackButton: () => handleBackButton(),
        getViewport: () => stageVp,
        getTargetId: () => getActiveTarget().id,
        getTouchController: () => input?.getTouchControls(),
        getTouchRouter: () => input?.getTouchRouter(),
        getGamepad: () => input?.getGamepadRouter(),
        setGamepadSim: (state?: unknown) => {
            input?.setGamepadSim(state);
        },
        injectTouch: (phase: "began" | "moved" | "ended", id: number, x: number, y: number, fromMouse?: boolean) => {
            input?.injectTouch(phase, id, x, y, fromMouse);
        },
        getInputMode: () => input?.inputMode ?? getActiveTarget().defaultInputMode,
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
            return stageVp;
        },
        getToast: () => fe?.getToastText() ?? "",
    };

    if (startScreen === "play") {
        ensurePlay();
    }

    parent.schedule((frameDt: number) => {
        tick(frameDt);
        return false;
    });
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

export function applyChapterPreviewRoute(targetRun: RunState, roomKey: string, routeOverride?: "child" | "soldier"): void {
    // 章节直达按对应路线预置独立预览上下文（绝不污染正式档或通关档案），
    // 防止 storyRoute 落回 undecided 导致小满四房低模、周戍护送背负、工台试握与北塔双结局失活。
    if (roomKey === "outside" || roomKey === "village" || roomKey === "forest"
        || (roomKey === "tower" && routeOverride !== "soldier")) {
        targetRun.story.route = "child";
        targetRun.story.settled = true;
        targetRun.story.countTick = 1440;
    } else if (roomKey === "gatepath" || roomKey.indexOf("escort") === 0
        || (roomKey === "tower" && routeOverride === "soldier")) {
        targetRun.story.route = "soldier";
        targetRun.story.settled = true;
        targetRun.joined = true;
        targetRun.story.handDone = true;
        targetRun.story.tied = true;
        targetRun.story.hpAtGate = targetRun.story.maxHpAtGate = 3;
        if (roomKey.indexOf("escort") === 0) {
            targetRun.story.carry = true;
        }
        if (roomKey === "escort4" || roomKey === "escort5") {
            targetRun.inventory.wood = 2;
            targetRun.inventory.bell = 1;
        }
        if (roomKey === "escort3") {
            targetRun.inventory.wood = Math.max(targetRun.inventory.wood, 2);
            targetRun.inventory.scrap = Math.max(targetRun.inventory.scrap, 2);
            targetRun.inventory.bell = Math.max(targetRun.inventory.bell, 1);
            targetRun.inventory.wedge = Math.max(targetRun.inventory.wedge, 1);
        }
    }
}

function enterPlayRoom(idx: number, source: RunSource = "debug", fresh = false, seedOverride?: number, chapterRoute?: "child" | "soldier"): void {
    current = idx;
    clock.reset();
    if (fe !== undefined) {
        fe.screen = "play";
    }
    play = undefined;
    // 标题「新的旅程」进序章视为正式开新局；章节直达始终起干净独立预览局，不泄漏或污染正式局状态。
    if (fresh || source === "chapter" || storyRun === undefined) {
        storyRun = createRun(seedOverride ?? (source === "debug" ? 20261124 : randomRunSeed()), source, profile);
        if (fresh || source === "official") {
            runPlaySeconds = 0;
            autosaveTimer = 0;
            lastAutosaveSig = "";
        }
        if (source === "chapter") {
            const targetKey = ROOMS[current] !== undefined ? ROOMS[current].key : "";
            applyChapterPreviewRoute(storyRun, targetKey, chapterRoute);
        }
    } else {
        storyRun.source = source;
    }
    ensurePlay();
    // 标题「开始游戏」与「选择章节 → 序章」均从 P01「叫醒」完整起播；debug 夹具保持 prologue-wait 兼容。
    const firstPlay = play as Play | undefined;
    if (firstPlay !== undefined && ROOMS[current].key === "prologue"
        && ((fresh && source === "official") || source === "chapter")) {
        firstPlay.phase = "prologue-wake";
    }
    flushProfile();
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
}

function syncFrameAdapters(frameDt: number): void {
    if (input === undefined) {
        return;
    }
    const target = input.target;
    if (!target.supportsTouch && !target.supportsGamepad) {
        return;
    }
    const p = play;
    const isPlayMode = fe !== undefined && fe.screen === "play" && p !== undefined;
    const storyTalentBoxes = target.supportsTouch && isPlayMode && fe !== undefined && p !== undefined
        && !p.paused && !p.craftBench.active && !p.reloadOpen
        ? fe.getStoryTalentBoxes(p, stageVp.stageW, stageVp.stageH, input.isTouchMode())
        : [];

    let isFs = false;
    if (target.canToggleFullscreen()) {
        try {
            isFs = App.fullScreen;
        } catch {
            isFs = false;
        }
    }
    input.syncFrame({
        viewport: stageVp,
        mode: 1,
        screen: fe !== undefined ? fe.screen : "title",
        play: p,
        run: storyRun,
        cam: isPlayMode ? fe?.cam : undefined,
        input,
        assistHintsEnabled: fe !== undefined ? fe.contract.isAssistHintsEnabled() : true,
        isMuted: fe !== undefined ? fe.audio.isAllMuted() : false,
        isFullscreen: isFs,
        storyTalentBoxes,
        escortDeathBoxes: p && fe ? fe.getEscortDeathBoxes(p, stageVp.stageW, stageVp.stageH) : undefined,
        ledgerBox: fe?.roguelikeUi.getLedgerButtonRect(),
        ledgerOpen: fe?.roguelikeUi.isLedgerOpen() ?? false,
        dt: frameDt,
    });
}

function renderTouchOverlay(): void {
    input?.renderOverlay();
}

function tick(frameDt: number): void {
    appClock += Math.min(0.05, Math.max(0, frameDt));
    const w = testViewportOverride !== undefined ? testViewportOverride.w : View.size.width;
    const h = testViewportOverride !== undefined ? testViewportOverride.h : View.size.height;
    if (w !== viewW || h !== viewH) {
        viewW = w;
        viewH = h;
        applySize();
    }
    if (input === undefined) {
        return;
    }
    syncFrameAdapters(frameDt);
    input.update(frameDt);

    if (input.userInteracted) {
        onFirstUserGesture();
    }
    if (pendingWinSizeSaveTimer > 0) {
        pendingWinSizeSaveTimer -= frameDt;
        if (pendingWinSizeSaveTimer <= 0 && isDesktopNative()) {
            try {
                if (!App.fullScreen) {
                    const ws = App.winSize;
                    if (ws.width >= 640 && ws.height >= 360) {
                        input.settings.winWidth = Math.round(ws.width);
                        input.settings.winHeight = Math.round(ws.height);
                        saveControlSettings(input.settings);
                    }
                }
            } catch {
                // ignore
            }
        }
    }
    if (input.muteTogglePressed && fe !== undefined) {
        input.muteTogglePressed = false;
        const muted = fe.audio.toggleAllMuted();
        input.settings.muted = muted;
        saveControlSettings(input.settings);
    }
    if (input.fullscreenTogglePressed) {
        input.fullscreenTogglePressed = false;
        toggleFullscreen();
    }
    syncPowerMode();
    if (!startupNoticeShown && fe !== undefined && fe.screen === "title") {
        startupNoticeShown = true;
        const rel = getReleaseConfig();
        if (rel !== undefined && rel.saveFallbackReason === "readonly") {
            fe.showToast("游戏目录不可写，存档已自动回退至用户目录", 4.5);
        } else if (rel !== undefined && rel.migratedFrom !== undefined && rel.migratedFrom !== "") {
            fe.showToast("已自动迁移旧存档至 saves 目录", 3.5);
        } else if (profileStatus === "corrupt" || profileStatus === "unsupported") {
            fe.showToast("主档案异常，原件已备份至 backups 目录", 4.5);
        }
    }
    if (input.artifactTogglePressed) {
        input.artifactTogglePressed = false;
        if (fe?.screen === "play" && play !== undefined && !play.paused && !play.escortFailed
            && !play.talentModalActive && !fe.roguelikeUi.isLedgerOpen()) {
            play.toggleArtifactWeapon();
        }
    }
    if (input.bottleCanceled && play !== undefined) {
        input.bottleCanceled = false;
        play.aimHold = 0;
        play.bottleAimX = -1;
    }

    if (fe !== undefined && fe.screen === "play" && play !== undefined && !play.paused
        && !play.craftBench.active && !play.reloadOpen && !play.escortFailed && play.getStoryTalentOffers().length > 0
        && input.pickRoom >= 1 && input.pickRoom <= 3) {
        if (fe.canPickStoryTalent(play)) {
            play.chooseTalent(input.pickRoom - 1);
        }
    }
    input.pickRoom = 0;
    tickFrontend(frameDt);
    renderTouchOverlay();
}

/** 把当前 Play 实例挂到 package.loaded，供 Lua 回放/验收读真实运行态。 */
function registerPlay(): void {
    const reg = (globalThis as unknown as { package: { loaded: Record<string, unknown> } }).package.loaded;
    reg["watch.play"] = play;
    reg["watch.room"] = ROOMS[current].key;
}

/** 试玩模式下按当前房间建运行时；切房间时重建。 */
function ensurePlay(resume?: { checkpoint: number }): void {
    // 正式剧情：整局只有一份跨房状态，血量、过门锁线与演出快照都在里面。
    // 重试与切房都重建 Play，但不再满血重算。
    if (storyRun === undefined) {
        storyRun = createRun(20261124, "debug", profile);
    }
    play = new Play(ROOMS[current], resume, storyRun);
    registerPlay();
    clock.reset();
    if (fe !== undefined) {
        fe.bindPlay(play, stageVp.stageW, stageVp.stageH);
    }
}

/** 处理后端 wantRoom 切房、男主线护送倒地/重开回第一段以及片尾重开。 */
function applyRoomTransition(p: Play): boolean {
    if (p.wantRoom === "") {
        return false;
    }
    const key = p.wantRoom;
    p.wantRoom = "";
    let idx = -1;
    let j = 0;
    for (j = 0; j < ROOMS.length; j++) {
        if (ROOMS[j].key === key) {
            idx = j;
        }
    }
    if (idx < 0) {
        return false;
    }
    // 换实例前先取走旧队列，再接到新实例队首；前端下一帧仍能拿到切房这一条 roomChange。
    // adoptEvents 会丢掉旧房间的 knock，避免跨出口同拍按 E 时在新房重播旧房敲声。
    // 切房同拍：旧实例的档案变化先落盘；失败则留 profileDirty，由后续帧重试。
    flushProfile();
    if (p.restartStory && storyRun?.source === "official" && !clearSessionForRestart()) {
        p.restartStory = false;
        if (fe !== undefined) {
            fe.menus.openEpilogue(p.storyRoute === "soldier" ? "reunion" : "lamp", profile.childCleared && profile.soldierCleared);
            fe.screen = "epilogue";
        }
        input?.clearTransient(true);
        return true;
    }
    const leaving = p.drainEvents();
    if (p.restartStory) {
        const nextSource = storyRun?.source ?? "debug";
        const nextSeed = nextSource === "official" ? randomRunSeed() : 20261124;
        storyRun = createRun(nextSeed, nextSource, profile);
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
    return true;
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
        } else if (act.type === "continue") {
            if (continueOfficialStory() === undefined) {
                fe.showToast("读取存档失败", 2.2);
            }
        } else if (act.type === "start" || act.type === "replayStory") {
            if (clearSessionForRestart()) enterPlayRoom(officialStartIndex(), "official", true);
        } else if (act.type === "jump" && act.roomIndex !== undefined) {
            enterPlayRoom(act.roomIndex, "chapter", false, undefined, act.route);
        } else if (act.type === "openChapters") {
            fe.menus.openChapters();
            fe.screen = "chapters";
        } else if (act.type === "openControls") {
            fe.menus.resetInput();
            fe.screen = "controls";
        } else if (act.type === "openSaves") {
            fe.menus.openSaves(false);
            fe.screen = "saves";
        } else if (act.type === "openSettings") {
            fe.menus.openSettings();
            fe.screen = "settings";
        } else if (act.type === "loadSlot" && act.slot !== undefined) {
            if (loadOfficialSlot(act.slot) !== undefined) {
                fe.showToast("已读取" + slotDisplayName(act.slot), 2.0);
            } else {
                fe.showToast("读取存档失败", 2.2);
            }
        } else if (act.type === "deleteSlot" && act.slot !== undefined) {
            deleteSaveSlotById(act.slot);
        } else if (act.type === "openHistory") {
            fe.menus.openHistory(true);
            fe.screen = "history";
        } else if (act.type === "backEpilogue") {
            fe.menus.resetInput();
            fe.screen = "epilogue";
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
    if (zoneTap !== "ledger:toggle") input.touchZoneTap = "";

    // 男主线肉鸽护送倒地：轮回小结页（折戟山道 → 重整再赴 / 返回标题）
    if (!p.paused && p.escortFailed) {
        let deathAction: "retry" | "title" | "" = "";
        if (zoneTap === "escort:retry" && p.escortFailedTicks >= 12) {
            deathAction = "retry";
        } else if (zoneTap === "escort:title") {
            deathAction = "title";
        } else {
            if (input.navLeft || input.navPrevTab) {
                fe.roguelikeUi.deathSelected = 0;
            } else if (input.navRight || input.navNextTab) {
                fe.roguelikeUi.deathSelected = 1;
            }
            if (input.pause.pressed || input.navBack) {
                deathAction = "title";
            } else if (p.escortFailedTicks >= 24 && (input.retry.pressed || input.retryTapPressed)) {
                deathAction = "retry";
            } else if (p.escortFailedTicks >= 24 && input.navConfirm) {
                deathAction = fe.roguelikeUi.deathSelected === 0 ? "retry" : "title";
            } else if (p.escortFailedTicks >= 12
                && (input.uiPressed || (input.inputMode !== "gamepad" && input.fire.pressed))) {
                deathAction = fe.tryPickEscortDeathAtPointer(p, input, stageVp.stageW, stageVp.stageH);
            }
        }
        if (deathAction === "retry") {
            input.consumeEdges();
            p.confirmEscortRestart();
            applyRoomTransition(p);
            return;
        }
        if (deathAction === "title") {
            input.consumeEdges();
            fe.audio.stopRoomTransient();
            fe.menus.resetInput();
            fe.screen = "title";
            input.clearTransient(true);
            return;
        }
        input.pause.pressed = false;
        input.retry.pressed = false;
        input.fire.pressed = false;
    }

    if (!p.paused && fe.roguelikeUi.isLedgerOpen()) {
        clock.reset();
        fe.renderPlay(frameDt, p, input, stageVp.stageW, stageVp.stageH);
        input.consumeEdges();
        return;
    }

    const offers = p.getStoryTalentOffers();
    if (fe.canPickStoryTalent(p) && offers.length > 0) {
        if (fe.hud.talentSelected >= offers.length) {
            fe.hud.talentSelected = 0;
        }
        if (zoneTap.indexOf("talent:") === 0) {
            const idx = parseInt(zoneTap.slice(7), 10);
            if (idx >= 0 && idx < offers.length && p.chooseTalent(idx)) {
                fe.hud.talentSelected = idx;
                input.fire.pressed = false;
            }
        } else {
            const navDelta = p.talentModalActive
                ? ((input.navRight || input.navNextTab ? 1 : 0) - (input.navLeft || input.navPrevTab ? 1 : 0))
                : 0;
            const totalDelta = navDelta !== 0 ? navDelta : input.talentDelta;
            if (totalDelta !== 0) {
                fe.hud.talentSelected = (fe.hud.talentSelected + totalDelta + offers.length) % offers.length;
                input.talentDelta = 0;
            }
            if (input.talentConfirm || (p.talentModalActive && input.navConfirm)) {
                p.chooseTalent(fe.hud.talentSelected);
                input.talentConfirm = false;
                input.fire.pressed = false;
            } else if ((input.uiPressed || (input.inputMode !== "gamepad" && input.fire.pressed))
                && fe.tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH)) {
                input.fire.pressed = false;
            }
        }
    }

    // 北塔尾声满 8 秒读完后，按确认键（E / 左键 / 手柄确认 / 触屏）收页进入片尾落款与史话入口
    if (!p.paused && p.room.key === "tower" && p.phase === "tower-end") {
        if (input.navConfirm) {
            input.interact.pressed = true;
        }
        const towerMouseContinue = input.inputMode !== "gamepad" && (input.uiPressed || input.fire.pressed);
        if (p.towerEndReady() && (input.interact.pressed || input.retry.pressed || input.retryTapPressed || towerMouseContinue)) {
            flushProfile();
            if (p.run.source === "official" && hasSessionSave()) {
                clearSession();
                refreshTitleSessionFlag();
            }
            fe.audio.stopRoomTransient();
            fe.menus.openEpilogue(
                p.storyRoute === "soldier" ? "reunion" : "lamp",
                profile.childCleared && profile.soldierCleared,
            );
            fe.screen = "epilogue";
            input.clearTransient(true);
            input.consumeEdges();
            return;
        }
    }

    if (!p.paused && p.craftBench.active && input.pause.pressed) {
        p.closeCraftBench();
        input.consumeEdges();
        return;
    }
    if (!p.paused && !p.escortFailed && fe.tryClickHudPause(p, input, stageVp.stageW, stageVp.stageH)) {
        input.pause.pressed = true;
        input.fire.pressed = false;
        input.fire.held = false;
        input.uiPressed = false;
    }
    if (!p.paused && !p.escortFailed && input.pause.pressed) {
        p.paused = true;
        p.aimHold = 0;
        p.bottleAimX = -1;
        saveCurrentSession();
        fe.menus.openPause();
        fe.audio.playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08);
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
            if (p.run.source === "official" && p.storyRoute === "soldier" && p.isEscortRoom()) {
                p.restartEscortRun();
                applyRoomTransition(p);
            } else {
                ensurePlay({ checkpoint: p.checkpoint });
            }
        } else if (pauseAct.type === "openChapters") {
            fe.audio.stopRoomTransient();
            fe.audio.setPaused(false);
            fe.menus.openChapters(current);
            fe.screen = "chapters";
        } else if (pauseAct.type === "toggleFullscreen") {
            toggleFullscreen();
        } else if (pauseAct.type === "saveSlot" && pauseAct.slot !== undefined) {
            saveToManualSlot(pauseAct.slot);
        } else if (pauseAct.type === "loadSlot" && pauseAct.slot !== undefined) {
            if (loadOfficialSlot(pauseAct.slot) !== undefined) {
                fe.showToast("已读取" + slotDisplayName(pauseAct.slot), 2.0);
            } else {
                fe.showToast("读取存档失败", 2.2);
            }
        } else if (pauseAct.type === "deleteSlot" && pauseAct.slot !== undefined) {
            deleteSaveSlotById(pauseAct.slot);
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
    if (input.retry.pressed && !inTowerEnding && !inPrologueIntro && !p.craftBench.active && !p.reloadOpen && !p.escortFailed && !p.talentModalActive) {
        input.consumeEdges();
        if (p.run.source === "official" && p.storyRoute === "soldier" && p.isEscortRoom()) {
            // 正式男主线肉鸽关闭单段 S/L：重开推进轮次派生新种子回第一段
            p.restartEscortRun();
            applyRoomTransition(p);
        } else {
            // 非肉鸽段落或调试/章节模式：重试保留检查点，并重新绑定前端相机与运行态验收钩子。
            ensurePlay({ checkpoint: p.checkpoint });
        }
        return;
    }

    const worldPromptClick = fe.tryClickWorldPrompt(p, input, stageVp.stageW, stageVp.stageH);
    if (worldPromptClick === "tap") {
        input.interact.pressed = true;
        input.interact.held = true;
        input.frameInteractPressed = true;
        input.fire.pressed = false;
        input.fire.held = false;
    } else if (worldPromptClick === "hold") {
        if (input.uiPressed || input.fire.pressed) {
            input.interact.pressed = true;
            input.frameInteractPressed = true;
        }
        input.interact.held = true;
        input.fire.pressed = false;
        input.fire.held = false;
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
    if (applyRoomTransition(p)) {
        return;
    }

    // 档案变化（正式通关、井口取器）在下一个渲染帧落盘；写失败保留旧文件，下次再试。
    flushProfile();
    if (p.run.source === "official" && !p.paused && !p.run.finished) {
        runPlaySeconds += Math.min(0.1, Math.max(0, frameDt));
        autosaveTimer += Math.min(0.1, Math.max(0, frameDt));
        if (autosaveCooldown > 0) {
            autosaveCooldown = Math.max(0, autosaveCooldown - frameDt);
        }
    }
    if (p.run.finished && p.run.source === "official" && hasSessionSave()) {
        clearSession();
        refreshTitleSessionFlag();
    } else if (p.sessionDirty) {
        saveCurrentSession();
    } else if (canSaveSession() && autosaveCooldown <= 0) {
        const sig = sessionMilestoneSignature(p);
        if (lastAutosaveSig === "") {
            lastAutosaveSig = sig;
        } else if (sig !== lastAutosaveSig || autosaveTimer >= 20.0) {
            saveCurrentSession();
        }
    }
    fe.renderPlay(frameDt, p, input, stageVp.stageW, stageVp.stageH);
}
