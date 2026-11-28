/**
 * 《向西守望》宋明清雅水墨菜单体系（全平台 × 三模统一解耦版）：
 * - 开机序幕（splash）：4.65s 局外人团队标 → 向西守望主标 → 柔化进入标题页，0.25s 后键鼠/手柄/触屏/返回键任意跳过；
 * - 标题页：竖版品牌主标（缺图自动回退龙藏体 + 朱砂孤印）+ 右下角团队微光角标 + 按平台能力过滤「退出游戏」；
 * - 选章页：千里驿道长卷，支持安全区内缩、3:2/4:3 纵向舒展与触屏两段防误触确认；
 * - 执器要诀：键鼠 / 手柄 / 触屏三页统一说明（左右 / LB / RB / 点击自由切换）；
 * - 局内暂停：桌面严格保持原 0..7 索引零回归（4=fullscreen，7=quit），末尾追加「操控设置」原地二级页，
 *   让所有平台都能随时选择操作模式（自动/键鼠/触屏/手柄）及共享磁吸、手柄布局与触控参数。
 */

import { App, Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { ROOMS } from "Script/watch/rooms";
import { Input } from "Script/watch/input";
import { GamepadLayout, InputMode } from "Script/watch/controls_config";
import {
    SaveSlotId,
    SaveSlotSummary,
    formatPlayDuration,
    formatSavedAt,
    listSaveSlots,
} from "Script/watch/save";
import {
    SafeInsets,
    ZERO_SAFE_INSETS,
    canQuitApp,
    canToggleFullscreen,
} from "Script/watch/platform";
import { getActiveTarget } from "Script/watch/target";
import { HISTORY_CARDS } from "Script/watch/dialogues";
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

export type ScreenKind = "splash" | "title" | "chapters" | "controls" | "saves" | "settings" | "epilogue" | "history" | "play";

export type UiSoundKind = "hover" | "confirm" | "back" | "start" | "pauseOpen" | "pauseClose" | "toggle";

export interface MenuAction {
    type:
        | "none"
        | "splashDone"
        | "continue"
        | "start"
        | "replayStory"
        | "jump"
        | "resume"
        | "retry"
        | "toTitle"
        | "openChapters"
        | "openControls"
        | "openSaves"
        | "openSettings"
        | "loadSlot"
        | "saveSlot"
        | "deleteSlot"
        | "openHistory"
        | "backTitle"
        | "backEpilogue"
        | "backPause"
        | "toggleFullscreen"
        | "quit";
    roomIndex?: number;
    route?: "child" | "soldier";
    slot?: SaveSlotId;
}

const TITLE_ITEMS = [
    { id: "start", zh: "开始游戏" },
    { id: "chapters", zh: "选择章节" },
    { id: "controls", zh: "操作说明" },
    { id: "saves", zh: "读取存档" },
    { id: "settings", zh: "游戏设置" },
    { id: "quit", zh: "退出游戏" },
];

interface ChapterEntry {
    room: (typeof ROOMS)[number];
    roomIndex: number;
    route?: "child" | "soldier";
    titleOverride?: string;
    shortNameOverride?: string;
    lineTagOverride?: string;
    whisperOverride?: string;
}

// 博物馆由双通关后的井口进入；旧版灰盒 street/checkpoint 仅保留给 debug 回归，不暴露在正式选章里。
// 北塔按双结局拆分为小满留灯（低模）与周戍团圆（像素），保证选章直达也能完整呈现对应视觉与演出。
const CHAPTERS: ChapterEntry[] = (() => {
    const out: ChapterEntry[] = [];
    let i = 0;
    for (i = 0; i < ROOMS.length; i++) {
        const room = ROOMS[i];
        if (room.key === "museum" || room.key === "street" || room.key === "checkpoint") {
            continue;
        }
        if (room.key === "tower") {
            out.push({
                room,
                roomIndex: i,
                route: "child",
                titleOverride: "终章 · 北塔留灯",
                shortNameOverride: "北塔·留灯",
                lineTagOverride: "小满",
                whisperOverride: "孤身叩响北塔门，西窗留一盏向西的灯。",
            });
            out.push({
                room,
                roomIndex: i,
                route: "soldier",
                titleOverride: "终章 · 北塔团圆",
                shortNameOverride: "北塔·团圆",
                lineTagOverride: "周戍",
                whisperOverride: "兄妹并肩跨过塔门，两行姓名同落登记簿。",
            });
            continue;
        }
        out.push({ room, roomIndex: i });
    }
    return out;
})();

// 桌面端严格保持 0..9 既有顺序（4 = fullscreen，7 = quit，8 = settings，9 = ledger），末项追加「存取档案」。
const PAUSE_ITEMS = [
    { id: "resume", zh: "继续游戏" },
    { id: "retry", zh: "重试检查点" },
    { id: "controls", zh: "操作说明" },
    { id: "assist", zh: "按键辅助：关" },
    { id: "fullscreen", zh: "显示：窗口" },
    { id: "chapters", zh: "选择章节" },
    { id: "title", zh: "返回标题" },
    { id: "quit", zh: "退出游戏" },
    { id: "settings", zh: "操控设置" },
    { id: "ledger", zh: "行军札记" },
    { id: "saves", zh: "存取档案" },
];

const VERTICAL_TITLE = ["向", "西", "守", "望"];
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
    prevTab: boolean;
    nextTab: boolean;
    skipInput: boolean;
    pointer: Vec2.Type;
    inside: boolean;
    click: boolean;
    pointerMoved: boolean;
    mode: InputMode;
    layout: GamepadLayout;
    safe: SafeInsets;
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
    settingsSelected = 0;
    saveSelected = 0;
    saveActionSelected = 0;
    epilogueSelected = 0;
    epilogueEnding: "lamp" | "reunion" = "lamp";
    epilogueBothCleared = false;
    historyCardIndex = 0;
    private historyFromEpilogue = false;
    /** 存在有效局中存档时，标题页首项显示「继续游戏」，无存档时保持原索引。 */
    hasSession = false;
    /** 局中存档所在章节短名（显示于「继续游戏」右侧，便于分辨续读落点） */
    sessionLabel = "";
    /** 存档管理页当前缓存的四槽位摘要（自动档 + 档位 1..3） */
    saveSlots: SaveSlotSummary[] = [];

    setSessionRoomKey(roomKey: string): void {
        this.sessionLabel = roomKey !== "" ? themeOf(roomKey).shortNameZh : "";
    }
    /** 操作说明页当前分页（自动随最近输入模式同步，支持左右 / LB / RB / 点击切换） */
    controlsTab: InputMode = "kbm";
    /** 可选水墨 UI 交互音效回调（由 WatchFrontend 挂载，测试直调零耦合） */
    onUiSound?: (kind: UiSoundKind) => void;
    /** 音量设置项实时变化回调 */
    onAudioSettingsChanged?: (input: Input) => void;
    /** 按键辅助设置项实时变化回调 */
    onAssistSettingsChanged?: (input: Input) => void;
    /** 显示模式全屏切换回调（由 app.ts 挂载以同步持久化配置） */
    onToggleFullscreen?: () => void;

    private emitSound(kind: UiSoundKind): void {
        if (this.onUiSound !== undefined) {
            this.onUiSound(kind);
        }
    }

    private chaptersFromPause = false;
    private pauseShowControls = false;
    private pauseShowSettings = false;
    private pauseShowSaves = false;
    private titleConfirmNewGame = false;
    private titleConfirmSel = 1;
    private saveConfirmKind: "" | "overwrite" | "delete" = "";
    private saveConfirmSlot: SaveSlotId = 1;
    private saveConfirmSel = 1;
    private controlsTabManual = false;
    private queuedKeys: Partial<MenuKeys> = {};
    private queuedBack = false;
    private queuedSkip = false;
    private splashTime = 0;
    private time = 0;

    resetSplash(): void {
        this.splashTime = 0;
        this.queuedSkip = false;
        this.resetInput();
    }

    isShowingPauseControls(): boolean {
        return this.pauseShowControls;
    }

    isShowingPauseSettings(): boolean {
        return this.pauseShowSettings;
    }

    isShowingPauseSaves(): boolean {
        return this.pauseShowSaves;
    }

    isShowingTitleConfirm(): boolean {
        return this.titleConfirmNewGame;
    }

    refreshSaveSlots(): void {
        this.saveSlots = listSaveSlots();
    }

    openSaves(fromPause: boolean = false): void {
        this.refreshSaveSlots();
        this.saveSelected = fromPause ? 1 : 0;
        this.saveActionSelected = 0;
        this.saveConfirmKind = "";
        this.saveConfirmSel = 1;
        this.pauseShowControls = false;
        this.pauseShowSettings = false;
        this.pauseShowSaves = fromPause;
        this.resetInput();
    }

    openSettings(): void {
        this.settingsSelected = 0;
        this.titleConfirmNewGame = false;
        this.resetInput();
    }

    openPauseSettings(): void {
        this.pauseShowControls = false;
        this.pauseShowSaves = false;
        this.pauseShowSettings = true;
        this.settingsSelected = 0;
        this.resetInput();
    }

    openChapters(roomIndex?: number): void {
        this.chaptersFromPause = roomIndex !== undefined;
        this.chapterSelected = Math.max(0, CHAPTERS.findIndex(chapter => chapter.roomIndex === roomIndex));
        this.pauseShowControls = false;
        this.pauseShowSettings = false;
        this.pauseShowSaves = false;
        this.titleConfirmNewGame = false;
        this.resetInput();
    }

    openPause(): void {
        this.pauseSelected = 0;
        this.pauseShowControls = false;
        this.pauseShowSettings = false;
        this.pauseShowSaves = false;
        this.saveConfirmKind = "";
        this.resetInput();
    }

    openEpilogue(ending: "lamp" | "reunion" = "lamp", bothCleared: boolean = false): void {
        this.epilogueEnding = ending;
        this.epilogueBothCleared = bothCleared;
        this.epilogueSelected = 0;
        this.resetInput();
    }

    openHistory(fromEpilogue: boolean = true): void {
        this.historyFromEpilogue = fromEpilogue;
        this.historyCardIndex = 0;
        this.resetInput();
    }

    /** 外部注入返回边沿（供 Android 系统返回键 BackButton 调用）。 */
    triggerBack(): void {
        this.queuedBack = true;
    }

    /** 页面切换后清空待消费边沿，避免切页串键。 */
    resetInput(): void {
        this.queuedKeys = {};
        this.queuedBack = false;
        this.queuedSkip = false;
        this.controlsTabManual = false;
    }

    /** 锁存两个渲染帧之间的键盘短按（仅在含键鼠端或自动化测试中调用）。 */
    onKeyEvent(key: string): void {
        this.queuedSkip = true;
        if (key === "Up" || key === "W") {
            this.queuedKeys.up = true;
        } else if (key === "Down" || key === "S") {
            this.queuedKeys.down = true;
        } else if (key === "Left" || key === "A") {
            this.queuedKeys.left = true;
        } else if (key === "Right" || key === "D") {
            this.queuedKeys.right = true;
        } else if (key === "Return" || key === "Space") {
            this.queuedKeys.confirm = true;
        } else if (key === "Escape") {
            this.queuedBack = true;
        }
    }

    private readFrame(input: Input, scale: number, safe: SafeInsets): MenuFrame {
        const queued = this.queuedKeys;

        // 优先使用规范化渲染帧 UI 指针；保留直接写 input.mx/fire.pressed 的验收脚本兼容
        const useUiPtr = input.uiInside || input.uiPressed;
        const rawX = useUiPtr ? input.uiX : input.mx;
        const rawY = useUiPtr ? input.uiY : input.my;
        const rawDx = useUiPtr ? input.uiDx : input.mdx;
        const rawDy = useUiPtr ? input.uiDy : input.mdy;
        const inside = useUiPtr ? input.uiInside : input.inside;
        const click = useUiPtr ? (input.uiInside && input.uiPressed) : (input.inside && input.fire.pressed);
        const touchMode = input.isTouchMode();

        const frame: MenuFrame = {
            keys: {
                up: queued.up === true || input.navUp,
                down: queued.down === true || input.navDown,
                left: queued.left === true || input.navLeft,
                right: queued.right === true || input.navRight,
                confirm: queued.confirm === true || input.navConfirm,
            },
            back: this.queuedBack || input.pause.pressed || input.navBack,
            prevTab: input.navPrevTab,
            nextTab: input.navNextTab,
            skipInput: this.queuedSkip || input.splashSkipPressed,
            pointer: Vec2(rawX / scale, rawY / scale),
            inside,
            click,
            pointerMoved: !touchMode && inside && Math.abs(rawDx) + Math.abs(rawDy) >= scale,
            mode: input.inputMode,
            layout: input.gamepadLayout,
            safe,
        };
        this.queuedKeys = {};
        this.queuedBack = false;
        this.queuedSkip = false;
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
        safeUi: SafeInsets = ZERO_SAFE_INSETS,
    ): MenuAction {
        this.time += dt;
        const splashDissolving = screen === "splash" && this.splashTime >= 4.15;
        if (screen !== "splash" || splashDissolving) {
            const artW = Math.max(w, h * 16 / 9);
            const artH = artW * 9 / 16;
            if (!backdropArt.tryPlace("title_backdrop", "menu_landscape", w * 0.5, (h - artH) * 0.5, artW, artH)) {
                stage.drawMenuBackdrop(bgDraw, bgGlow, w, h, this.time);
            }
        }

        const frame = this.readFrame(input, uiScale, safeUi);
        w /= uiScale;
        h /= uiScale;

        if (screen === "splash") {
            return this.drawSplash(dt, frame, uiDraw, uiArt, texts, w, h);
        }
        if (screen === "title") {
            return this.drawTitle(frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h);
        }
        if (screen === "chapters") {
            return this.drawChapters(frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h);
        }
        if (screen === "saves") {
            return this.drawSavesPanel(frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, false, false);
        }
        if (screen === "settings") {
            if (this.drawPauseSettings(frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h)) {
                return { type: "backTitle" };
            }
            return { type: "none" };
        }
        if (screen === "epilogue") {
            return this.drawEpilogue(frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h);
        }
        if (screen === "history") {
            return this.drawHistory(frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h);
        }
        return this.drawControls(frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h);
    }

    /**
     * 开机品牌序幕（4.65s，支持 0.25s 后键鼠、手柄、触屏或返回键任意跳过）：
     * - 0.00–2.20s：团队「局外人」Logo（T2 六边暖灯）+ Powered by Dora SSR
     * - 2.20–4.20s：游戏主标《向西守望》（G2 水墨题签）
     * - 4.20–4.65s：鸦青轻幕柔化淡出，无缝衔接标题页
     */
    private drawSplash(
        dt: number,
        frame: MenuFrame,
        uiDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        texts: TextPool,
        w: number,
        h: number,
    ): MenuAction {
        const safeDt = Math.min(0.1, Math.max(0, dt));
        this.splashTime += safeDt;
        const t = this.splashTime;

        const wantSkip = t >= 0.25 && (frame.skipInput || frame.click || frame.keys.confirm || frame.back);
        if (wantSkip || t >= 4.65) {
            this.splashTime = 0;
            return { type: "splashDone" };
        }

        const fadeOutCurtain = t >= 4.20 ? Math.max(0, 1 - (t - 4.20) / 0.45) : 1;
        const bgR = t < 2.20 ? 13 : 11;
        const bgG = t < 2.20 ? 16 : 13;
        const bgB = t < 2.20 ? 24 : 19;
        uiDraw.drawRect(Rect(0, 0, w, h), Color(bgR, bgG, bgB, Math.round(255 * fadeOutCurtain)));

        const smoothEnvelope = (localT: number, fadeIn: number, holdEnd: number, endT: number): number => {
            if (localT <= 0 || localT >= endT) return 0;
            if (localT < fadeIn) {
                const u = localT / fadeIn;
                return u * u * (3 - 2 * u);
            }
            if (localT <= holdEnd) return 1;
            const u = (localT - holdEnd) / Math.max(0.01, endT - holdEnd);
            return 1 - u * u * (3 - 2 * u);
        };

        if (t < 2.20) {
            const alpha = smoothEnvelope(t, 0.42, 1.72, 2.20);
            const scaleBreath = 0.985 + 0.03 * (t / 2.20);
            const logoH = Math.min(384, h * 0.54) * scaleBreath;
            if (!uiArt.tryPlace("brand_team_logo", "splash_team_logo", w * 0.5, h * 0.54, logoH * 2, logoH, { opacity: alpha, layer: 2 })) {
                texts.put("banner", "OUTSIDER", w * 0.5, h * 0.52, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 6.0, alpha, 0);
            }
            texts.put("xs", "Powered by Dora SSR", w * 0.5, 58 + frame.safe.bottom * 0.4, toColor(PALETTE.textDim), 0.5, 0.5, TextAlign.Center, 1.8, alpha * 0.62, 0);
        } else if (t < 4.25) {
            const localT = t - 2.20;
            const alpha = smoothEnvelope(localT, 0.45, 1.60, 2.05);
            const sway = Math.sin(localT * 1.1) * 8;
            drawMistCurve(uiArt, "splash_game_mist", w * 0.5 + sway, h * 0.46, 560, 110, PALETTE.jadeMist, 0.16 * alpha, 1);
            const scaleBreath = 0.985 + 0.028 * (localT / 2.05);
            const logoH = Math.min(310, h * 0.44) * scaleBreath;
            if (!uiArt.tryPlace("brand_game_logo_h", "splash_game_logo", w * 0.5, h * 0.52, logoH * 2.4, logoH, { opacity: alpha, layer: 2 })) {
                texts.put("title", "向西守望", w * 0.5, h * 0.52, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 8.0, alpha, 0);
            }
        }

        if (t >= 0.35 && t < 4.15) {
            const hintA = Math.min(1, (t - 0.35) / 0.35) * 0.52;
            const skipText = getActiveTarget().splashSkipHint(frame.mode, frame.layout);
            texts.put("xs", skipText, w - 48 - frame.safe.right * 0.6, 36 + frame.safe.bottom * 0.4, toColor(PALETTE.textDim), 1, 0.5, TextAlign.Right, 1.4, hintA, 0);
        }

        return { type: "none" };
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
        fillHGradRect(uiDraw, 0, 0, w * 0.22 + frame.safe.left * 0.5, h, Color(9, 11, 18, 192), Color(9, 11, 18, 116));
        fillHGradRect(uiDraw, w * 0.22 + frame.safe.left * 0.5, 0, w * 0.28, h, Color(9, 11, 18, 116), Color(9, 11, 18, 0));
        fillVGradRect(uiDraw, 0, 0, w, 78, Color(8, 10, 16, 138), Color(8, 10, 16, 0));

        const extraH = Math.max(0, h - 720);
        const titleX = 148 + frame.safe.left * 0.6;
        const topY = h - 104 - frame.safe.top * 0.4;
        const charStep = 66;
        const sway = Math.sin(this.time * 0.7) * 5;
        drawMistCurve(uiArt, "title_mist_wisp", titleX + 86 + sway, topY - 122, 340, 82, PALETTE.jadeMist, 0.20, -1);
        uiArt.tryPlace("ink_petal_mist", "title_petals", titleX + 12, topY - 102, 230, 210, {
            color: toColor(PALETTE.inkMist), opacity: 0.40, layer: -1,
        });

        // 主标题区：优先使用定稿竖版水墨题签主标，缺失时回退至龙藏体逐字竖排 + 朱砂孤印
        const placedBrandTitle = uiArt.tryPlace("brand_game_logo_v", "title_brand_v", titleX + 22, topY - 106, 240, 304, {
            opacity: 0.98, layer: 3,
        });
        if (!placedBrandTitle) {
            uiArt.tryPlace("ink_vstream", "title_vstream", titleX - 48, topY - 100, 34, 290, {
                color: toColor(PALETTE.silkDim), opacity: 0.48, layer: 1,
            });
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
        }

        // 古画错落竖排题跋
        const colRightX = placedBrandTitle ? titleX + 190 : titleX + 132;
        const colLeftX = placedBrandTitle ? titleX + 160 : titleX + 102;
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

        // 按平台能力决定是否显示「退出游戏」（桌面原生与独立 Android APK 显示，Web / Dora Go 隐藏）
        const baseItems = canQuitApp()
            ? TITLE_ITEMS
            : TITLE_ITEMS.filter(it => it.id !== "quit");
        const items = this.hasSession
            ? [{ id: "continue", zh: "继续游戏" }, ...baseItems]
            : baseItems;
        if (this.selected >= items.length) {
            this.selected = 0;
        }
        const denseTitle = items.length >= 6;
        const veryDenseTitle = items.length >= 7;
        const menuX = 112 + frame.safe.left * 0.6;
        const btnW = 280;
        const btnH = veryDenseTitle ? 34 : (denseTitle ? 36 : (frame.mode === "touch" ? 44 : 40));
        const gap = veryDenseTitle ? 5 : (denseTitle ? 5 : 8);
        const startY = (veryDenseTitle ? 306 : (denseTitle ? 274 : 268)) + extraH * 0.35;
        const boxes: Rect.Type[] = [];
        let i = 0;
        for (i = 0; i < items.length; i++) {
            boxes.push(Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH));
        }

        if (!this.titleConfirmNewGame) {
            const prevTitleSel = this.selected;
            this.selected = this.verticalSelection(this.selected, boxes, frame);
            if (this.selected !== prevTitleSel) {
                this.emitSound("hover");
            }
        }

        for (i = 0; i < items.length; i++) {
            const by = boxes[i].y;
            const active = !this.titleConfirmNewGame && this.selected === i;
            const cy = by + btnH * 0.5;
            const shiftX = active ? 10 : 0;

            if (active) {
                const breathe = 0.84 + 0.16 * Math.sin(this.time * 2.2);
                drawSilkRibbon(uiDraw, uiArt, "title_rib_red_" + i, menuX + 124, cy, 290, btnH, PALETTE.rougeSoft, 0.52 * breathe, 0);
                drawHairline(uiInkDraw, uiArt, "title_rib_line_" + i, menuX + 114, by + 4, 230, PALETTE.silkLine, 0.42 * breathe, false, 2);
                drawBlossomDot(uiInkDraw, uiArt, "title_dot_" + i, menuX + 14, cy, 15, PALETTE.rouge, 0.96, 4);
                fillRadialGlow(uiGlow, menuX + 14, cy, 22, 16, toColor(PALETTE.rouge, 28 * breathe), Color(182, 58, 56, 0), 10);
            } else {
                drawBlossomDot(uiInkDraw, uiArt, "title_dot_" + i, menuX + 14, cy, 8, PALETTE.silkDim, 0.40, 3);
            }

            texts.put(
                veryDenseTitle ? "sm" : "md",
                items[i].zh,
                menuX + 34 + shiftX,
                cy,
                toColor(active ? PALETTE.textBright : PALETTE.textMid),
                0,
                0.5,
                TextAlign.Left,
                active ? 4.0 : 2.6,
                active ? 1.0 : 0.88,
                0.10,
            );
            if (items[i].id === "continue" && this.sessionLabel !== "") {
                texts.put(
                    "xs",
                    "· " + this.sessionLabel,
                    menuX + 168 + shiftX,
                    cy,
                    toColor(active ? PALETTE.amberCore : PALETTE.textDim),
                    0,
                    0.5,
                    TextAlign.Left,
                    1.2,
                    active ? 0.92 : 0.72,
                    0.08,
                );
            }
        }

        const titleHint = getActiveTarget().titleFooterHint(frame.mode, frame.layout);
        texts.put("xs", titleHint, menuX + 12, 34 + frame.safe.bottom * 0.45, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.4, 0.88, 0.08);

        // 右下角克制团队落款（局外人 T2 微光角标）
        const badgeRight = w - frame.safe.right * 0.5;
        const badgeY = 42 + frame.safe.bottom * 0.4;
        fillHGradRect(uiDraw, badgeRight - 270, 0, 270 + frame.safe.right * 0.5, 86, Color(8, 10, 16, 0), Color(8, 10, 16, 204));
        uiArt.tryPlace("brand_team_badge", "title_team_badge", badgeRight - 118, badgeY, 168, 54, {
            opacity: 0.95, layer: 3,
        });

        if (this.titleConfirmNewGame) {
            const dlgRes = this.drawConfirmDialog(
                frame,
                uiDraw,
                uiInkDraw,
                uiArt,
                texts,
                w,
                h,
                "开启新旅程",
                "当前已有自动存档，开始新游戏将覆盖自动存档（手动槽位保留）。",
                "确认开始",
                "取消返回",
                this.titleConfirmSel,
                (sel: number) => {
                    this.titleConfirmSel = sel;
                },
            );
            if (dlgRes === "confirm") {
                this.titleConfirmNewGame = false;
                this.emitSound("start");
                this.resetInput();
                return { type: "start" };
            }
            if (dlgRes === "cancel") {
                this.titleConfirmNewGame = false;
                this.emitSound("back");
                this.resetInput();
            }
            return { type: "none" };
        }

        const hit = frame.click ? hitIndex(boxes, frame.pointer, frame.inside) : -1;
        if (hit >= 0 || frame.keys.confirm) {
            const idx = hit >= 0 ? hit : this.selected;
            const id = items[idx].id;
            if (id === "continue") { this.emitSound("start"); return { type: "continue" }; }
            if (id === "start") {
                if (this.hasSession) {
                    this.titleConfirmNewGame = true;
                    this.titleConfirmSel = 1;
                    this.emitSound("confirm");
                    this.resetInput();
                    return { type: "none" };
                }
                this.emitSound("start");
                return { type: "start" };
            }
            if (id === "chapters") { this.emitSound("confirm"); return { type: "openChapters" }; }
            if (id === "saves") {
                this.openSaves(false);
                this.emitSound("confirm");
                return { type: "openSaves" };
            }
            if (id === "settings") {
                this.openSettings();
                this.emitSound("confirm");
                return { type: "openSettings" };
            }
            if (id === "quit") { this.emitSound("back"); return { type: "quit" }; }
            this.emitSound("confirm");
            return { type: "openControls" };
        }
        return { type: "none" };
    }

    /** 居中水墨二次确认弹窗（用于覆盖自动存档 / 覆盖槽位 / 删除槽位，默认选中「取消」防误删）。 */
    private drawConfirmDialog(
        frame: MenuFrame,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        texts: TextPool,
        w: number,
        h: number,
        heading: string,
        message: string,
        confirmLabel: string,
        cancelLabel: string,
        selected: number,
        setSelected: (next: number) => void,
    ): "none" | "confirm" | "cancel" {
        if (frame.back) {
            return "cancel";
        }
        const dlgW = Math.min(540, w - 120);
        const dlgH = 224;
        const dlgX = (w - dlgW) * 0.5;
        const dlgY = (h - dlgH) * 0.5;
        const btnW = 166;
        const btnH = 40;
        const btnGap = 28;
        const btnY = dlgY + 28;
        const btn0X = w * 0.5 - btnW - btnGap * 0.5;
        const btn1X = w * 0.5 + btnGap * 0.5;
        const boxes = [Rect(btn0X, btnY, btnW, btnH), Rect(btn1X, btnY, btnW, btnH)];

        const hit = hitIndex(boxes, frame.pointer, frame.inside);
        let cur = selected;
        if (frame.click && hit >= 0) {
            cur = hit;
        } else if (frame.keys.left || frame.keys.up) {
            cur = 0;
        } else if (frame.keys.right || frame.keys.down) {
            cur = 1;
        } else if (frame.pointerMoved && hit >= 0 && !frame.keys.confirm) {
            cur = hit;
        }
        if (cur !== selected) {
            setSelected(cur);
            this.emitSound("hover");
        }

        uiDraw.drawRect(Rect(0, 0, w, h), Color(6, 8, 14, 186));
        uiDraw.drawRect(Rect(dlgX, dlgY, dlgW, dlgH), Color(14, 17, 26, 244));
        drawFiligreeCorners(uiInkDraw, uiArt, "confirm_dlg_frame", dlgX, dlgY, dlgW, dlgH, PALETTE.silkLine, 0.85, 28, true, 5);
        texts.put("lg", heading, w * 0.5, dlgY + dlgH - 44, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 3.0, 0.98, 0.10);
        drawHairline(uiInkDraw, uiArt, "confirm_dlg_div", w * 0.5, dlgY + dlgH - 72, dlgW - 84, PALETTE.silkDim, 0.56, true, 4);
        texts.put("sm", message, w * 0.5, dlgY + dlgH - 110, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 0.8, 0.94, 0.08);

        const labels = [confirmLabel, cancelLabel];
        let bi = 0;
        for (bi = 0; bi < 2; bi++) {
            const bx = boxes[bi];
            const isSel = cur === bi;
            const fillCol = isSel
                ? (bi === 0 ? toColor(PALETTE.rougeSoft, 185) : Color(32, 40, 56, 215))
                : Color(18, 22, 32, 165);
            const borderCol = isSel
                ? (bi === 0 ? PALETTE.rouge : PALETTE.amberCore)
                : PALETTE.silkDim;
            uiInkDraw.drawRect(bx, fillCol, 1.1, toColor(borderCol, isSel ? 235 : 145));
            texts.put(
                "sm",
                labels[bi],
                bx.x + bx.width * 0.5,
                bx.y + bx.height * 0.5,
                toColor(isSel ? PALETTE.textBright : PALETTE.textMid),
                0.5,
                0.5,
                TextAlign.Center,
                2.0,
                isSel ? 1.0 : 0.84,
                0.08,
            );
        }

        if ((frame.click && hit >= 0) || frame.keys.confirm) {
            return cur === 0 ? "confirm" : "cancel";
        }
        return "none";
    }

    /** 多槽位存档管理页（自动存档 + 档案一/二/三；支持标题页读删与暂停页存取删及覆盖/删除确认）。 */
    private drawSavesPanel(
        frame: MenuFrame,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
        fromPause: boolean,
        canSave: boolean,
    ): MenuAction {
        const backAction: MenuAction = { type: fromPause ? "backPause" : "backTitle" };
        if (this.saveSlots.length === 0) {
            this.refreshSaveSlots();
        }
        const slots = this.saveSlots;
        if (this.saveSelected >= slots.length) {
            this.saveSelected = 0;
        }

        if (this.saveConfirmKind === "" && frame.back) {
            this.emitSound("back");
            return backAction;
        }

        uiDraw.drawRect(Rect(0, 0, w, h), Color(10, 12, 19, 208));

        const marginX = Math.max(96, 56 + Math.max(frame.safe.left, frame.safe.right));
        const topHeadY = h - 58 - frame.safe.top * 0.35;
        texts.put("lg", fromPause ? "存取档案" : "读取存档", marginX, topHeadY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 4.0, 0.98, 0.10);
        const subDesc = fromPause
            ? (canSave ? "自动存档随进度更新 · 可存入或读取三处手动槽位" : "当前段落仅可读取或清理已有存档")
            : "便携目录 saves/ · 支持自动存档与三处独立槽位";
        texts.put("xs", subDesc, marginX + 168, topHeadY - 2, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 1.2, 0.86, 0.08);
        drawHairline(uiInkDraw, uiArt, "saves_top_line", w * 0.5, topHeadY - 30, w - marginX * 2, PALETTE.silkDim, 0.60, true, 2);

        const panelW = Math.min(880, w - marginX * 2);
        const panelX = (w - panelW) * 0.5;
        const cardH = 92;
        const cardGap = 16;
        const firstTop = topHeadY - 58;
        const cardBoxes: Rect.Type[] = [];
        let i = 0;
        for (i = 0; i < slots.length; i++) {
            const cyBottom = firstTop - (i + 1) * cardH - i * cardGap;
            cardBoxes.push(Rect(panelX, cyBottom, panelW, cardH));
        }

        const actionsForSlot = (slot: SaveSlotSummary): { id: "save" | "load" | "delete"; zh: string }[] => {
            const acts: { id: "save" | "load" | "delete"; zh: string }[] = [];
            if (fromPause && canSave && slot.id !== "auto") {
                acts.push({ id: "save", zh: slot.exists ? "覆盖保存" : "存入此档" });
            }
            if (slot.exists) {
                acts.push({ id: "load", zh: "读取" });
                acts.push({ id: "delete", zh: "删除" });
            }
            return acts;
        };

        if (this.saveConfirmKind === "") {
            const prevSel = this.saveSelected;
            this.saveSelected = this.verticalSelection(this.saveSelected, cardBoxes, frame);
            if (this.saveSelected !== prevSel) {
                this.saveActionSelected = 0;
                this.emitSound("hover");
            }
        }

        const slotTitleOf = (id: SaveSlotId): string => {
            if (id === "auto") return "自动存档";
            if (id === 1) return "档案一";
            if (id === 2) return "档案二";
            return "档案三";
        };

        let activeActionBoxes: Rect.Type[] = [];
        let activeActions: { id: "save" | "load" | "delete"; zh: string }[] = [];

        for (i = 0; i < slots.length; i++) {
            const slot = slots[i];
            const box = cardBoxes[i];
            const active = this.saveSelected === i && this.saveConfirmKind === "";
            const acts = actionsForSlot(slot);
            if (this.saveSelected === i) {
                activeActions = acts;
                if (this.saveActionSelected >= acts.length) {
                    this.saveActionSelected = 0;
                }
            }

            const cardBg = active ? Color(22, 26, 38, 224) : Color(13, 16, 24, 182);
            const cardBorder = active ? PALETTE.rouge : PALETTE.silkDim;
            uiInkDraw.drawRect(box, cardBg, active ? 1.3 : 0.8, toColor(cardBorder, active ? 225 : 120));
            if (active) {
                const breathe = 0.84 + 0.16 * Math.sin(this.time * 2.2);
                drawSilkRibbon(uiDraw, uiArt, "save_rib_" + i, panelX + panelW * 0.5, box.y + box.height * 0.5, panelW + 10, box.height - 6, PALETTE.rougeSoft, 0.24 * breathe, 0);
                drawBlossomDot(uiInkDraw, uiArt, "save_dot_" + i, box.x + 22, box.y + box.height - 28, 13, PALETTE.rouge, 0.96, 4);
                fillRadialGlow(uiGlow, box.x + 22, box.y + box.height - 28, 18, 14, toColor(PALETTE.rouge, 24 * breathe), Color(182, 58, 56, 0), 10);
            } else {
                drawBlossomDot(uiInkDraw, uiArt, "save_dot_" + i, box.x + 22, box.y + box.height - 28, 7, PALETTE.silkDim, 0.48, 3);
            }

            const titleX = box.x + 44;
            const titleY = box.y + box.height - 28;
            texts.put("md", slotTitleOf(slot.id), titleX, titleY, toColor(active ? PALETTE.textBright : PALETTE.textMid), 0, 0.5, TextAlign.Left, 2.2, active ? 1.0 : 0.88, 0.08);

            if (slot.exists) {
                const rt = themeOf(slot.roomKey);
                const routeZh = slot.route === "soldier" ? "周戍线" : (slot.route === "child" ? "小满线" : "序章");
                const chapTag = rt.shortNameZh + " · " + routeZh;
                texts.put("sm", chapTag, titleX + 118, titleY, toColor(slot.route === "soldier" ? PALETTE.cyanCore : PALETTE.amberCore), 0, 0.5, TextAlign.Left, 1.4, 0.94, 0.08);

                const parts: string[] = [];
                parts.push("血量 " + slot.hp + "/" + slot.maxHp);
                const dur = formatPlayDuration(slot.playSeconds);
                if (dur !== "") {
                    parts.push("时长 " + dur);
                }
                const savedStr = formatSavedAt(slot.savedAt);
                if (savedStr !== "") {
                    parts.push("保存于 " + savedStr);
                }
                if (slot.recovered) {
                    parts.push("备份恢复");
                }
                texts.put("xs", parts.join("   ·   "), titleX, box.y + 26, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 0.8, 0.88, 0.08);
            } else if (slot.status === "corrupt" || slot.status === "unsupported") {
                texts.put("sm", slot.status === "corrupt" ? "存档已损坏" : "版本不兼容", titleX + 118, titleY, toColor(PALETTE.rouge), 0, 0.5, TextAlign.Left, 1.4, 0.94, 0.08);
                texts.put("xs", "原件已隔离于 backups 目录，可覆盖保存或忽略", titleX, box.y + 26, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 0.8, 0.82, 0.08);
            } else {
                texts.put("sm", "空档", titleX + 118, titleY, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.4, 0.72, 0.08);
                const emptyTip = slot.id === "auto"
                    ? "推进剧情、切房或暂停时自动记录"
                    : (fromPause && canSave ? "按回车或点击右侧「存入此档」保存当前进度" : "游玩中可在暂歇菜单手动保存");
                texts.put("xs", emptyTip, titleX, box.y + 26, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 0.8, 0.70, 0.08);
            }

            // 右侧操作按钮组
            const btnW = 88;
            const btnH = 30;
            const btnGap = 8;
            const totalActW = acts.length > 0 ? (acts.length * btnW + (acts.length - 1) * btnGap) : 0;
            const actStartX = box.x + box.width - 18 - totalActW;
            const actY = box.y + (box.height - btnH) * 0.5;
            const rowBtnBoxes: Rect.Type[] = [];
            let ai = 0;
            for (ai = 0; ai < acts.length; ai++) {
                const bx = Rect(actStartX + ai * (btnW + btnGap), actY, btnW, btnH);
                rowBtnBoxes.push(bx);
                const btnFocused = active && this.saveActionSelected === ai;
                const btnHover = this.saveConfirmKind === "" && frame.inside && bx.containsPoint(frame.pointer);
                const highlight = btnFocused || btnHover;
                const isDel = acts[ai].id === "delete";
                const bg = highlight
                    ? (isDel ? Color(118, 36, 36, 210) : toColor(PALETTE.rougeSoft, 195))
                    : Color(18, 22, 32, 168);
                const bd = highlight
                    ? (isDel ? PALETTE.rouge : PALETTE.amberCore)
                    : PALETTE.silkDim;
                uiInkDraw.drawRect(bx, bg, 1.0, toColor(bd, highlight ? 235 : 135));
                texts.put(
                    "xs",
                    acts[ai].zh,
                    bx.x + bx.width * 0.5,
                    bx.y + bx.height * 0.5,
                    toColor(highlight ? PALETTE.textBright : PALETTE.textMid),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    0.8,
                    highlight ? 1.0 : 0.86,
                    0.08,
                );
            }
            if (this.saveSelected === i) {
                activeActionBoxes = rowBtnBoxes;
            }
        }

        const backX = marginX;
        const backY = 38 + frame.safe.bottom * 0.45;
        const backBox = Rect(backX - 6, backY - 6, 210, 44);
        const backHover = this.saveConfirmKind === "" && frame.inside && backBox.containsPoint(frame.pointer);
        drawSilkKeycap(uiInkDraw, texts, backX, backY + 4, 52, 24, "ESC", backHover ? PALETTE.rouge : PALETTE.silkDim, 0.92, backHover);
        texts.put("sm", fromPause ? "返回暂停" : "返回标题", backX + 64, backY + 16, toColor(backHover ? PALETTE.textBright : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.8, 0.90, 0.08);
        texts.put("xs", "上下选槽位   ·   左右选动作   ·   回车或点击确认", w - marginX, backY + 16, toColor(PALETTE.textDim), 1, 0.5, TextAlign.Right, 1.2, 0.78, 0.08);

        if (this.saveConfirmKind !== "") {
            const isDel = this.saveConfirmKind === "delete";
            const dlgRes = this.drawConfirmDialog(
                frame,
                uiDraw,
                uiInkDraw,
                uiArt,
                texts,
                w,
                h,
                isDel ? "删除存档" : "覆盖存档",
                isDel
                    ? ("确定删除「" + slotTitleOf(this.saveConfirmSlot) + "」？删除后无法恢复。")
                    : ("确定覆盖「" + slotTitleOf(this.saveConfirmSlot) + "」？原存档进度将被替换。"),
                isDel ? "确认删除" : "确认覆盖",
                "取消",
                this.saveConfirmSel,
                (sel: number) => {
                    this.saveConfirmSel = sel;
                },
            );
            if (dlgRes === "confirm") {
                const kind = this.saveConfirmKind;
                const slotId = this.saveConfirmSlot;
                this.saveConfirmKind = "";
                this.resetInput();
                this.emitSound(kind === "delete" ? "back" : "confirm");
                return { type: kind === "delete" ? "deleteSlot" : "saveSlot", slot: slotId };
            }
            if (dlgRes === "cancel") {
                this.saveConfirmKind = "";
                this.emitSound("back");
                this.resetInput();
            }
            return { type: "none" };
        }

        if (frame.click && backHover) {
            this.emitSound("back");
            return backAction;
        }

        if (activeActions.length > 0) {
            const hitAct = hitIndex(activeActionBoxes, frame.pointer, frame.inside);
            if (frame.pointerMoved && hitAct >= 0 && !frame.keys.confirm && hitAct !== this.saveActionSelected) {
                this.saveActionSelected = hitAct;
                this.emitSound("hover");
            }
            if (frame.keys.left) {
                this.saveActionSelected = (this.saveActionSelected + activeActions.length - 1) % activeActions.length;
                this.emitSound("hover");
            } else if (frame.keys.right) {
                this.saveActionSelected = (this.saveActionSelected + 1) % activeActions.length;
                this.emitSound("hover");
            }

            let triggerIdx = -1;
            if (frame.click && hitAct >= 0) {
                this.saveActionSelected = hitAct;
                triggerIdx = hitAct;
            } else if (frame.keys.confirm) {
                triggerIdx = this.saveActionSelected;
            }

            if (triggerIdx >= 0 && triggerIdx < activeActions.length) {
                const chosen = activeActions[triggerIdx];
                const slot = slots[this.saveSelected];
                if (chosen.id === "load") {
                    this.emitSound("start");
                    this.resetInput();
                    return { type: "loadSlot", slot: slot.id };
                }
                if (chosen.id === "save") {
                    if (slot.exists) {
                        this.saveConfirmKind = "overwrite";
                        this.saveConfirmSlot = slot.id;
                        this.saveConfirmSel = 1;
                        this.emitSound("confirm");
                        this.resetInput();
                        return { type: "none" };
                    }
                    this.emitSound("confirm");
                    this.resetInput();
                    return { type: "saveSlot", slot: slot.id };
                }
                if (chosen.id === "delete") {
                    this.saveConfirmKind = "delete";
                    this.saveConfirmSlot = slot.id;
                    this.saveConfirmSel = 1;
                    this.emitSound("confirm");
                    this.resetInput();
                    return { type: "none" };
                }
            }
        }

        return { type: "none" };
    }

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
            this.emitSound("back");
            return back;
        }

        const extraH = Math.max(0, h - 720);
        const marginX = Math.max(96, 56 + Math.max(frame.safe.left, frame.safe.right));
        const splitTrack = CHAPTERS.length > 8;
        const perRow = splitTrack ? Math.ceil(CHAPTERS.length / 2) : CHAPTERS.length;
        const trackY = (splitTrack ? 210 : 148) + extraH * 0.25;
        const rowGap = 68;
        const trackX0 = marginX + 34;
        const trackX1 = w - marginX - 34;
        const stepX = (trackX1 - trackX0) / Math.max(1, perRow - 1);

        const stationBoxes: Rect.Type[] = [];
        let s = 0;
        for (s = 0; s < CHAPTERS.length; s++) {
            const sx = trackX0 + (s % perRow) * stepX;
            const sy = trackY - Math.floor(s / perRow) * rowGap;
            stationBoxes.push(Rect(sx - stepX * 0.45, sy - 29, stepX * 0.9, 58));
        }

        const prevSelected = this.chapterSelected;
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
        if (this.chapterSelected !== prevSelected) {
            this.emitSound("hover");
        }

        uiDraw.drawRect(Rect(0, 0, w, h), Color(10, 12, 19, 198));

        const topHeadY = h - 66 - frame.safe.top * 0.35;
        texts.put("banner", "选择章节", marginX, topHeadY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 4.5, 0.96, 0.10);
        drawHairline(uiInkDraw, uiArt, "chap_top_line", w * 0.5, topHeadY - 34, w - marginX * 2, PALETTE.silkDim, 0.60, true, 2);

        const activeEntry = CHAPTERS[this.chapterSelected];
        const activeRoom = activeEntry.room;
        const theme = themeOf(activeRoom.key);
        const activeTitleZh = activeEntry.titleOverride ?? theme.titleZh;
        const activeLineTag = activeEntry.lineTagOverride ?? theme.lineTag;
        const activeWhisper = activeEntry.whisperOverride ?? theme.introWhisper;
        const winX = marginX;
        const winY = 266 + extraH * 0.44;
        const winW = Math.min(520, Math.max(360, (w - marginX * 2) * 0.46));
        const winH = 296;
        const winBox = Rect(winX, winY, winW, winH);
        const winHover = frame.inside && winBox.containsPoint(frame.pointer);

        uiArt.tryPlace("ink_frame_mask", "chap_win_shadow", winX + winW * 0.5, winY + winH * 0.5, winW + 40, winH + 34, {
            color: toColor(PALETTE.inkVoid), opacity: 0.88, layer: -2,
        });
        const bgSlot = ("bgFar_" + (theme.backdropKey ?? activeRoom.key)) as AssetSlotKey;
        uiArt.tryPlace(bgSlot, "chap_win_art", winX + winW * 0.5, winY + 4, winW - 8, winH - 8, {
            opacity: 0.92, layer: -1,
        });
        fillVGradRect(uiInkDraw, winX, winY, winW, 56, Color(10, 12, 19, 200), Color(10, 12, 19, 0));
        fillVGradRect(uiInkDraw, winX, winY + winH - 36, winW, 36, Color(10, 12, 19, 0), Color(10, 12, 19, 130));
        fillHGradRect(uiInkDraw, winX, winY, 34, winH, Color(10, 12, 19, 135), Color(10, 12, 19, 0));
        fillHGradRect(uiInkDraw, winX + winW - 34, winY, 34, winH, Color(10, 12, 19, 0), Color(10, 12, 19, 135));
        drawFiligreeCorners(uiInkDraw, uiArt, "chap_win_frame", winX, winY, winW, winH, winHover ? PALETTE.textBright : PALETTE.silkLine, winHover ? 0.92 : 0.72, 34, true, 3);

        texts.put("xs", theme.actCode + "  ·  " + activeLineTag, winX + 20, winY + 22, toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.8, 0.90, 0.08);

        const infoX = winX + winW + 40;
        const infoW = Math.max(240, w - marginX - infoX);
        const infoCenterY = winY + winH * 0.5;
        drawMistCurve(uiArt, "chap_info_mist", infoX + infoW * 0.5, infoCenterY + 36, Math.min(420, infoW + 24), 88, theme.accent, 0.22, -1);

        const volCol = activeLineTag === "周戍" ? PALETTE.cyan : PALETTE.amber;
        texts.put("xs", theme.volumeTagZh, infoX, winY + winH - 44, toColor(volCol), 0, 0.5, TextAlign.Left, 2.8, 0.92, 0.08);

        const sep = " · ";
        const sIdx = activeTitleZh.indexOf(sep);
        const titleY = winY + winH - 98;
        if (theme.backdropKey !== undefined) {
            texts.put("lg", activeTitleZh, infoX, titleY, toColor(PALETTE.textBright));
        } else if (sIdx > 0) {
            const leftPart = activeTitleZh.slice(0, sIdx);
            const rightPart = activeTitleZh.slice(sIdx + sep.length);
            const lw = visualTextWidth(leftPart, 40);
            texts.put("banner", leftPart, infoX, titleY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 2.0, 1, 0.10);
            drawBlossomDot(uiInkDraw, uiArt, "chap_title_dot", infoX + lw + 16, titleY - 2, 11, activeRoom.key === "gate" ? PALETTE.rouge : PALETTE.silkLine, 0.90, 4);
            texts.put("banner", rightPart, infoX + lw + 32, titleY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 2.0, 1, 0.10);
        } else {
            texts.put("banner", activeTitleZh, infoX, titleY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 2.4, 1, 0.10);
        }

        drawHairline(uiInkDraw, uiArt, "chap_info_line", infoX + Math.min(185, infoW * 0.5), titleY - 36, Math.min(370, infoW), PALETTE.silkDim, 0.58, false, 2);
        texts.put("sm", activeWhisper, infoX, titleY - 72, toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.8, 0.94, 0.08);

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
        const chapConfirmTag = getActiveTarget().keyTagFor("confirm", frame.mode, frame.layout);
        texts.put("xs", chapConfirmTag, goX + 156, goY + 21, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.0, 0.82, 0.08);

        const veilCenterY = splitTrack ? (trackY - rowGap * 0.5) : (trackY + 6);
        const veilH = splitTrack ? 156 : 126;
        drawSilkVeil(uiDraw, uiArt, "chap_track_veil", w * 0.5, veilCenterY, w - marginX * 1.1, veilH, PALETTE.inkWash, 0.72, -2);
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
            const entry = CHAPTERS[i];
            const rt = themeOf(entry.room.key);
            const entryLineTag = entry.lineTagOverride ?? rt.lineTag;
            const entryShortName = entry.shortNameOverride ?? rt.shortNameZh;
            const active = this.chapterSelected === i;
            const nodeCol = active ? PALETTE.rouge : (entryLineTag === "周戍" ? PALETTE.cyan : PALETTE.amber);

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
            texts.put("xs", entryShortName, sx, sy - 26, toColor(active ? PALETTE.textBright : PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 1.0, active ? 1 : 0.84, 0.08);
        }

        const backX = marginX;
        const backY = 40 + frame.safe.bottom * 0.45;
        const backBox = Rect(backX - 6, backY - 6, 210, 46);
        const backHover = frame.inside && backBox.containsPoint(frame.pointer);
        const chapBackTag = getActiveTarget().keyTagFor("back", frame.mode, frame.layout);
        const chapFooter = getActiveTarget().chapterFooterHint(frame.mode, chapConfirmTag);
        drawSilkKeycap(uiInkDraw, texts, backX, backY + 5, 48, 24, chapBackTag, backHover ? PALETTE.rouge : PALETTE.silkDim, 0.92, backHover);
        texts.put("sm", this.chaptersFromPause ? "返回暂停" : "返回标题", backX + 60, backY + 17, toColor(backHover ? PALETTE.textBright : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.8, 0.90, 0.08);
        texts.put("xs", chapFooter, w - marginX, backY + 17, toColor(PALETTE.textDim), 1, 0.5, TextAlign.Right, 1.2, 0.75, 0.08);

        if (frame.click && backHover) {
            this.emitSound("back");
            return back;
        }
        // 触屏无悬停：首次轻触未选驿站仅预览，再次点击同一驿站或点击画窗/入此卷章进关
        const stationConfirmed = frame.mode === "touch"
            ? (hitStation >= 0 && hitStation === prevSelected)
            : (hitStation >= 0);
        if (keys.confirm || (frame.click && (stationConfirmed || winHover || goHover))) {
            this.emitSound("start");
            return {
                type: "jump",
                roomIndex: CHAPTERS[this.chapterSelected].roomIndex,
                route: CHAPTERS[this.chapterSelected].route,
            };
        }
        return { type: "none" };
    }

    /** 操作说明 V3：「极简通透双栏素笺」× 按当前端裁剪页签（单端单页无页签，双/三端可切换） */
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
        const target = getActiveTarget();
        const tabs = target.controlsGuideTabs;
        const hasMultipleTabs = tabs.length > 1;
        if (!this.controlsTabManual || tabs.findIndex(t => t.mode === this.controlsTab) < 0) {
            this.controlsTab = tabs.findIndex(t => t.mode === frame.mode) >= 0 ? frame.mode : tabs[0].mode;
        }
        const marginX = Math.max(96, 56 + Math.max(frame.safe.left, frame.safe.right));
        const tabW = 92;
        const tabH = 28;
        const tabGap = 10;
        const tabBoxes: Rect.Type[] = [];
        let hitTab = -1;
        if (hasMultipleTabs) {
            const tabStartX = w - marginX - (tabW * tabs.length + tabGap * (tabs.length - 1));
            const tabY = h - 82 - frame.safe.top * 0.35;
            let k = 0;
            for (k = 0; k < tabs.length; k++) {
                tabBoxes.push(Rect(tabStartX + (tabW + tabGap) * k, tabY, tabW, tabH));
            }
            hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside);
            if (frame.click && hitTab >= 0) {
                if (this.controlsTab !== tabs[hitTab].mode) {
                    this.emitSound("toggle");
                }
                this.controlsTab = tabs[hitTab].mode;
                this.controlsTabManual = true;
            } else if (frame.keys.left || frame.prevTab) {
                const cur = tabs.findIndex(t => t.mode === this.controlsTab);
                this.controlsTab = tabs[((cur >= 0 ? cur : 0) + tabs.length - 1) % tabs.length].mode;
                this.controlsTabManual = true;
                this.emitSound("toggle");
            } else if (frame.keys.right || frame.nextTab) {
                const cur = tabs.findIndex(t => t.mode === this.controlsTab);
                this.controlsTab = tabs[((cur >= 0 ? cur : 0) + 1) % tabs.length].mode;
                this.controlsTabManual = true;
                this.emitSound("toggle");
            }
        }

        const backX = marginX;
        const backY = 40 + frame.safe.bottom * 0.45;
        const backBox = Rect(backX - 6, backY - 6, 250, 46);
        const backHover = frame.inside && backBox.containsPoint(frame.pointer);
        if (frame.back || (frame.keys.confirm && !(frame.click && hitTab >= 0)) || (frame.click && backHover)) {
            this.emitSound("back");
            return { type: "backTitle" };
        }
        uiDraw.drawRect(Rect(0, 0, w, h), Color(10, 12, 19, 204));

        const guide = target.controlsGuideRows(this.controlsTab);
        const topHeadY = h - 66 - frame.safe.top * 0.35;
        texts.put("banner", "执器要诀", marginX, topHeadY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 4.5, 0.96, 0.10);
        texts.put("xs", guide.subtitle, marginX + 196, topHeadY - 4, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.8, 0.85, 0.08);
        drawHairline(uiInkDraw, uiArt, "ctrl_top_line", w * 0.5, topHeadY - 34, w - marginX * 2, PALETTE.silkDim, 0.60, true, 2);

        if (hasMultipleTabs) {
            let ti = 0;
            for (ti = 0; ti < tabBoxes.length; ti++) {
                const tb = tabBoxes[ti];
                const activeTab = this.controlsTab === tabs[ti].mode;
                const hoverTab = hitTab === ti;
                uiInkDraw.drawRect(
                    tb,
                    activeTab ? toColor(PALETTE.rougeSoft, 150) : Color(14, 17, 25, hoverTab ? 185 : 130),
                    0.9,
                    toColor(activeTab ? PALETTE.rouge : (hoverTab ? PALETTE.textBright : PALETTE.silkDim), activeTab ? 225 : 155),
                );
                texts.put(
                    "xs",
                    tabs[ti].label,
                    tb.x + tb.width * 0.5,
                    tb.y + tb.height * 0.5,
                    toColor(activeTab ? PALETTE.textBright : PALETTE.textMid),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    0.8,
                    activeTab ? 0.98 : 0.82,
                    0.08,
                );
            }
        }

        const extraH = Math.max(0, h - 720);
        const areaY = 114 + frame.safe.bottom * 0.4;
        const areaH = h - 244 - frame.safe.top * 0.35 - frame.safe.bottom * 0.4;
        drawFiligreeCorners(uiInkDraw, uiArt, "ctrl_outer", marginX, areaY, w - marginX * 2, areaH, PALETTE.silkDim, 0.52, 34, false, 2);

        const midX = w * 0.5;
        uiArt.tryPlace("ink_vstream", "ctrl_mid_stream", midX, areaY + areaH * 0.5, 32, areaH - 18, {
            color: toColor(PALETTE.silkDim), opacity: 0.52, layer: 1,
        });
        drawBlossomDot(uiInkDraw, uiArt, "ctrl_mid_dot", midX, areaY + areaH * 0.5, 11, PALETTE.silkLine, 0.62, 3);

        const leftColX = marginX + 34;
        const colW = midX - leftColX - 42;
        const headY = areaY + areaH - 34;
        const rowStep = 52 + extraH * 0.08;

        drawBlossomDot(uiInkDraw, uiArt, "ctrl_l_dot", leftColX + 8, headY, 12, PALETTE.cyan, 0.88, 3);
        texts.put("md", "周戍 · 护送与交锋", leftColX + 26, headY, toColor(PALETTE.cyanCore), 0, 0.5, TextAlign.Left, 2.4, 0.98, 0.08);
        drawHairline(uiInkDraw, uiArt, "ctrl_l_line", leftColX + colW * 0.5, headY - 24, colW, PALETTE.cyanDim, 0.58, false, 2);

        let i = 0;
        const keycapW = 160;
        for (i = 0; i < guide.soldierRows.length; i++) {
            const ry = headY - 66 - i * rowStep;
            drawSilkKeycap(uiInkDraw, texts, leftColX + 2, ry - 13, keycapW, 26, guide.soldierRows[i][0], PALETTE.cyan, 0.92, false);
            texts.put("sm", guide.soldierRows[i][1], leftColX + keycapW + 16, ry, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.8, 0.92, 0.08);
        }

        const rightColX = midX + 44;
        drawBlossomDot(uiInkDraw, uiArt, "ctrl_r_dot", rightColX + 8, headY, 12, PALETTE.amber, 0.88, 3);
        texts.put("md", "小满 · 潜行与寻路", rightColX + 26, headY, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 2.4, 0.98, 0.08);
        drawHairline(uiInkDraw, uiArt, "ctrl_r_line", rightColX + colW * 0.5, headY - 24, colW, PALETTE.amberDim, 0.58, false, 2);

        for (i = 0; i < guide.childRows.length; i++) {
            const ry = headY - 66 - i * rowStep;
            drawSilkKeycap(uiInkDraw, texts, rightColX + 2, ry - 13, keycapW, 26, guide.childRows[i][0], PALETTE.amber, 0.92, false);
            texts.put("sm", guide.childRows[i][1], rightColX + keycapW + 16, ry, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.8, 0.92, 0.08);
        }

        const ctrlBackKey = frame.mode === "gamepad"
            ? (target.keyTagFor("back", "gamepad", frame.layout) + " / " + target.keyTagFor("confirm", "gamepad", frame.layout))
            : (frame.mode === "touch" ? "返回" : "ESC / ENTER");
        const ctrlRightHint = target.controlsFooterRightHint(frame.mode);
        const keyW = frame.mode === "touch" ? 76 : 110;
        drawSilkKeycap(uiInkDraw, texts, backX, backY + 5, keyW, 24, ctrlBackKey, backHover ? PALETTE.rouge : PALETTE.silkDim, 0.92, backHover);
        texts.put("sm", backLabel, backX + keyW + 12, backY + 17, toColor(backHover ? PALETTE.textBright : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.8, 0.92, 0.08);
        texts.put("xs", ctrlRightHint, w - marginX, backY + 17, toColor(PALETTE.textDim), 1, 0.5, TextAlign.Right, 1.2, 0.78, 0.08);

        return { type: "none" };
    }

    /** 暂停内原地设置二级页：按当前端仅展示本端有效设置项（Windows 仅音量，Android 触控+音量，掌机/Web 含模式与手柄）。 */
    private drawPauseSettings(
        frame: MenuFrame,
        input: Input,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
    ): boolean {
        if (frame.back) {
            this.emitSound("back");
            return true;
        }

        const target = getActiveTarget();
        const rows = target.settingsRows();
        const s = input.settings;
        if (this.settingsSelected >= rows.length) {
            this.settingsSelected = 0;
        }

        uiDraw.drawRect(Rect(0, 0, w, h), Color(10, 12, 19, 206));

        const marginX = Math.max(96, 56 + Math.max(frame.safe.left, frame.safe.right));
        const topHeadY = h - 56 - frame.safe.top * 0.35;
        texts.put("banner", target.settingsHeaderTitle(), marginX, topHeadY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 4.0, 0.96, 0.10);
        const curSummary = target.settingsHeaderSummary(input.inputMode);
        texts.put("xs", curSummary, marginX + 224, topHeadY - 4, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 1.4, 0.88, 0.08);
        drawHairline(uiInkDraw, uiArt, "set_top_line", w * 0.5, topHeadY - 30, w - marginX * 2, PALETTE.silkDim, 0.60, true, 2);

        const panelW = Math.min(760, w - marginX * 2);
        const panelX = (w - panelW) * 0.5;
        const rowH = 34;
        const rowStep = rows.length <= 6 ? 48 : 39;
        const firstY = topHeadY - 76;

        const boxes: Rect.Type[] = [];
        let i = 0;
        for (i = 0; i < rows.length; i++) {
            boxes.push(Rect(panelX, firstY - i * rowStep, panelW, rowH));
        }
        const prevSetSel = this.settingsSelected;
        this.settingsSelected = this.verticalSelection(this.settingsSelected, boxes, frame);
        if (this.settingsSelected !== prevSetSel) {
            this.emitSound("hover");
        }

        const applyDelta = (rowId: string, delta: number): boolean => {
            const res = target.applySettingsDelta(rowId, delta, s, input);
            if (res === "back") {
                this.emitSound("back");
                return true;
            }
            if (res === "audio" && this.onAudioSettingsChanged !== undefined) {
                this.onAudioSettingsChanged(input);
            }
            if (res === "assist" && this.onAssistSettingsChanged !== undefined) {
                this.onAssistSettingsChanged(input);
            }
            if (res === "display") {
                if (this.onToggleFullscreen !== undefined) {
                    this.onToggleFullscreen();
                } else if (canToggleFullscreen()) {
                    try {
                        App.fullScreen = !App.fullScreen;
                    } catch {
                        // ignore
                    }
                }
            }
            if (res !== "none") {
                this.emitSound("toggle");
            }
            return false;
        };

        for (i = 0; i < rows.length; i++) {
            const row = rows[i];
            const box = boxes[i];
            const cy = box.y + box.height * 0.5;
            const active = this.settingsSelected === i;

            if (active) {
                const breathe = 0.84 + 0.16 * Math.sin(this.time * 2.4);
                drawSilkRibbon(uiDraw, uiArt, "set_rib_" + i, panelX + panelW * 0.5, cy, panelW + 24, rowH, PALETTE.rougeSoft, 0.48 * breathe, 0);
                drawHairline(uiInkDraw, uiArt, "set_line_" + i, panelX + panelW * 0.5, box.y + 3, panelW - 24, PALETTE.silkLine, 0.42 * breathe, false, 2);
                drawBlossomDot(uiInkDraw, uiArt, "set_dot_" + i, panelX + 18, cy, 14, PALETTE.rouge, 0.96, 4);
                fillRadialGlow(uiGlow, panelX + 18, cy, 20, 14, toColor(PALETTE.rouge, 24 * breathe), Color(182, 58, 56, 0), 10);
            } else {
                drawBlossomDot(uiInkDraw, uiArt, "set_dot_" + i, panelX + 18, cy, 7, PALETTE.silkDim, 0.42, 3);
            }

            texts.put(
                "sm",
                row.title,
                panelX + 42,
                cy,
                toColor(active ? PALETTE.textBright : PALETTE.textMid),
                0,
                0.5,
                TextAlign.Left,
                active ? 2.4 : 1.6,
                active ? 1.0 : 0.88,
                0.08,
            );

            const val = target.settingsValueText(row.id, s, input.inputMode);
            if (val !== "") {
                const valCol = active ? PALETTE.amberCore : PALETTE.cyanCore;
                const decorated = active ? ("‹  " + val + "  ›") : val;
                texts.put("sm", decorated, panelX + panelW - 24, cy, toColor(valCol), 1, 0.5, TextAlign.Right, 1.0, active ? 1.0 : 0.86, 0.08);
            }
        }

        const backY = 40 + frame.safe.bottom * 0.45;
        const hint = target.settingsFooterHint(frame.mode, frame.layout);
        texts.put("xs", hint, w * 0.5, backY + 14, toColor(PALETTE.textDim), 0.5, 0.5, TextAlign.Center, 1.2, 0.84, 0.08);

        const hit = frame.click ? hitIndex(boxes, frame.pointer, frame.inside) : -1;
        if (hit >= 0) {
            this.settingsSelected = hit;
            if (applyDelta(rows[hit].id, 1)) {
                return true;
            }
            this.resetInput();
            return false;
        }
        if (frame.keys.left || frame.prevTab) {
            const id = rows[this.settingsSelected].id;
            if (id !== "back") {
                applyDelta(id, -1);
                this.resetInput();
            }
            return false;
        }
        if (frame.keys.right || frame.nextTab || frame.keys.confirm) {
            const id = rows[this.settingsSelected].id;
            if (applyDelta(id, 1)) {
                return true;
            }
            this.resetInput();
            return false;
        }
        return false;
    }

    /**
     * 局内暂停 V3：「左侧通天烟黛垂纱」
     * - 桌面端保留原 0..7 索引（4=fullscreen，7=quit）并在第 8 项追加「操控设置」；
     * - Web / 移动平台按 PlatformCaps 自动过滤不适用项，支持原地切「操作说明」与「操控设置」。
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
        safeUi: SafeInsets = ZERO_SAFE_INSETS,
        isMaleRoguelike: boolean = false,
        showLedgerEntry: boolean = false,
        onOpenLedger?: () => void,
        canSaveSlots: boolean = false,
    ): MenuAction {
        this.time += dt;
        const frame = this.readFrame(input, uiScale, safeUi);

        if (this.pauseShowControls) {
            const ctrlAct = this.drawControls(frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, "返回暂停");
            if (ctrlAct.type === "backTitle") {
                this.pauseShowControls = false;
                this.resetInput();
            }
            return { type: "none" };
        }

        if (this.pauseShowSettings) {
            if (this.drawPauseSettings(frame, input, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h)) {
                this.pauseShowSettings = false;
                this.resetInput();
            }
            return { type: "none" };
        }

        if (this.pauseShowSaves) {
            const saveAct = this.drawSavesPanel(frame, uiDraw, uiInkDraw, uiArt, uiGlow, texts, w, h, true, canSaveSlots);
            if (saveAct.type === "backPause") {
                this.pauseShowSaves = false;
                this.resetInput();
                return { type: "none" };
            }
            if (saveAct.type === "loadSlot") {
                this.pauseShowSaves = false;
                return saveAct;
            }
            return saveAct;
        }

        if (frame.back) {
            this.pauseShowControls = false;
            this.pauseShowSettings = false;
            this.pauseShowSaves = false;
            this.emitSound("pauseClose");
            return { type: "resume" };
        }

        const allowFs = canToggleFullscreen();
        const allowQuit = canQuitApp();
        const pauseItems = PAUSE_ITEMS.filter(item =>
            (item.id !== "fullscreen" || allowFs)
            && (item.id !== "quit" || allowQuit)
            && (item.id !== "ledger" || showLedgerEntry),
        );
        if (this.pauseSelected >= pauseItems.length) {
            this.pauseSelected = 0;
        }

        uiDraw.drawRect(Rect(0, 0, w, h), Color(8, 10, 16, 102));
        fillHGradRect(uiDraw, 0, 0, w * 0.27 + frame.safe.left, h, Color(9, 11, 18, 232), Color(10, 13, 21, 198));
        fillHGradRect(uiDraw, w * 0.27 + frame.safe.left, 0, w * 0.21, h, Color(10, 13, 21, 198), Color(10, 13, 21, 0));

        const menuX = 110 + frame.safe.left * 0.6;
        const veryCompact = pauseItems.length >= 10;
        const compact = pauseItems.length > 8;
        const headY = (veryCompact ? h - 92 : (compact ? h - 114 : h - 146)) - frame.safe.top * 0.35;
        uiArt.tryPlace("ink_vstream", "pause_vstream", menuX - 32, h * 0.5, 34, h * 0.78, {
            color: toColor(PALETTE.silkDim), opacity: 0.48, layer: 1,
        });
        drawMistCurve(uiArt, "pause_mist", menuX + 118, headY - 8, 290, 72, PALETTE.jadeMist, 0.20, -1);

        texts.put("banner", "暂歇", menuX + 16, headY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 10.0, 0.98, 0.10);
        texts.put("xs", "月夜暂驻 · 卷页留痕", menuX + 18, headY - 36, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 2.0, 0.80, 0.08);
        drawHairline(uiInkDraw, uiArt, "pause_div", menuX + 124, headY - 56, 240, PALETTE.silkDim, 0.58, true, 2);

        const rowStep = veryCompact ? 37 : (compact ? 42 : 46);
        const rowH = veryCompact ? 32 : (compact ? 36 : 38);
        const firstY = veryCompact ? (headY - 88) : (compact ? (headY - 106) : (headY - 120));
        const boxes: Rect.Type[] = [];
        let i = 0;
        for (i = 0; i < pauseItems.length; i++) {
            boxes.push(Rect(menuX - 10, firstY - i * rowStep, 286, rowH));
        }
        const prevPauseSel = this.pauseSelected;
        this.pauseSelected = this.verticalSelection(this.pauseSelected, boxes, frame);
        if (this.pauseSelected !== prevPauseSel) {
            this.emitSound("hover");
        }

        for (i = 0; i < pauseItems.length; i++) {
            const iy = boxes[i].y;
            const active = this.pauseSelected === i;
            const cy = iy + rowH * 0.5;
            const shiftX = active ? 10 : 0;
            const item = pauseItems[i];
            let label = item.zh;
            if (item.id === "retry" && isMaleRoguelike) {
                label = "重开本轮护送";
            } else if (item.id === "assist") {
                label = assistHintsEnabled ? "按键辅助：开" : "按键辅助：关";
            } else if (item.id === "fullscreen") {
                label = App.fullScreen ? "显示：全屏" : "显示：窗口";
            } else if (item.id === "settings") {
                label = getActiveTarget().settingsPauseLabel(input.settings);
            }

            if (active) {
                const breathe = 0.84 + 0.16 * Math.sin(this.time * 2.4);
                drawSilkRibbon(uiDraw, uiArt, "pause_rib_" + i, menuX + 116, cy, 282, rowH, PALETTE.rougeSoft, 0.54 * breathe, 0);
                drawHairline(uiInkDraw, uiArt, "pause_line_" + i, menuX + 106, iy + 3, 210, PALETTE.silkLine, 0.42 * breathe, false, 2);
                drawBlossomDot(uiInkDraw, uiArt, "pause_dot_" + i, menuX + 12, cy, 15, PALETTE.rouge, 0.96, 4);
                fillRadialGlow(uiGlow, menuX + 12, cy, 22, 16, toColor(PALETTE.rouge, 26 * breathe), Color(182, 58, 56, 0), 10);
            } else {
                drawBlossomDot(uiInkDraw, uiArt, "pause_dot_" + i, menuX + 12, cy, 8, PALETTE.silkDim, 0.40, 3);
            }

            texts.put(
                compact ? "sm" : "md",
                label,
                menuX + 32 + shiftX,
                cy,
                toColor(active ? PALETTE.textBright : PALETTE.textMid),
                0,
                0.5,
                TextAlign.Left,
                active ? 3.4 : 2.2,
                active ? 1.0 : 0.88,
                0.10,
            );
        }

        const pauseFooter = getActiveTarget().pauseFooterHint(frame.mode, frame.layout);
        texts.put("xs", pauseFooter, menuX + 12, 38 + frame.safe.bottom * 0.4, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.2, 0.86, 0.08);

        const hit = frame.click ? hitIndex(boxes, frame.pointer, frame.inside) : -1;
        if (hit >= 0 || frame.keys.confirm) {
            const idx = hit >= 0 ? hit : this.pauseSelected;
            const id = pauseItems[idx].id;
            if (id === "controls") {
                this.pauseShowControls = true;
                this.emitSound("confirm");
                this.resetInput();
                return { type: "none" };
            }
            if (id === "settings") {
                this.openPauseSettings();
                this.emitSound("confirm");
                return { type: "none" };
            }
            if (id === "saves") {
                this.openSaves(true);
                this.emitSound("confirm");
                return { type: "none" };
            }
            if (id === "ledger") {
                if (onOpenLedger !== undefined) {
                    onOpenLedger();
                }
                this.pauseShowControls = false;
                this.pauseShowSettings = false;
                this.emitSound("confirm");
                return { type: "resume" };
            }
            if (id === "assist") {
                if (onToggleAssist !== undefined) {
                    onToggleAssist();
                }
                this.emitSound("toggle");
                this.resetInput();
                return { type: "none" };
            }
            if (id === "fullscreen") {
                this.emitSound("toggle");
                this.resetInput();
                return { type: "toggleFullscreen" };
            }
            this.pauseShowControls = false;
            this.pauseShowSettings = false;
            if (id === "resume") { this.emitSound("pauseClose"); return { type: "resume" }; }
            if (id === "retry") { this.emitSound("confirm"); return { type: "retry" }; }
            if (id === "chapters") { this.emitSound("confirm"); return { type: "openChapters" }; }
            if (id === "quit") { this.emitSound("back"); return { type: "quit" }; }
            this.emitSound("back");
            return { type: "toTitle" };
        }
        return { type: "none" };
    }

    /**
     * 片尾落款页（《向西守望》正篇收束）：
     * 严格按剧本「片尾操作与落款」提供「返回标题」「再走一遍」「了解历史」三项入口。
     */
    private drawEpilogue(
        frame: MenuFrame,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
    ): MenuAction {
        if (frame.back) {
            return { type: "backTitle" };
        }

        // 深宵鸦青水墨幕 + 居中微光烟岚
        uiDraw.drawRect(Rect(0, 0, w, h), Color(7, 9, 15, 214));
        const cx = w * 0.5;
        const reunion = this.epilogueEnding === "reunion";
        const accentCol = reunion ? PALETTE.amber : PALETTE.cyan;
        drawMistCurve(uiArt, "ep_mist", cx, h * 0.62, 620, 120, accentCol, 0.20, 0);
        fillRadialGlow(uiGlow, cx, h * 0.68, 220, 140, toColor(accentCol, 28), Color(10, 14, 22, 0), 18);

        // 水墨片名《向西守望》与孤印「守望」
        const titleY = h * 0.72;
        texts.put("title", "向西守望", cx - 18, titleY, toColor(PALETTE.textBright), 0.5, 0.5, TextAlign.Center, 12.0, 0.98, 0.12);
        drawLoneSeal(uiInkDraw, uiArt, texts, "ep_seal", cx + 148, titleY - 2, 24, 46, "守", "望", PALETTE.sealRed, PALETTE.sealText, 0.94, 4);
        drawHairline(uiInkDraw, uiArt, "ep_div", cx, titleY - 46, 360, PALETTE.silkDim, 0.62, true, 2);

        const endingTitle = reunion ? "终章 · 兄妹团圆" : "终章 · 西窗留灯";
        const verse = reunion
            ? "簿页两行落墨，西窗灯火犹明。山海未静，此行终归同路。"
            : "西窗长灯未熄，簿页末行仍空——留给城门那头仍可能走来的人。";
        texts.put("md", endingTitle, cx, titleY - 76, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 3.2, 0.96, 0.08);
        texts.put("sm", verse, cx, titleY - 114, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 1.0, 0.92, 0.08);

        if (this.epilogueBothCleared) {
            drawSilkVeil(uiDraw, uiArt, "ep_well_veil", cx, titleY - 152, 560, 30, PALETTE.inkWarm, 0.68, 0);
            texts.put("xs", "双结局已通 · 回到序章寻柜之前，后院深井似有冷白微光", cx, titleY - 152, toColor(PALETTE.cyanCore), 0.5, 0.5, TextAlign.Center, 1.0, 0.90, 0.08);
        }

        const items = [
            { id: "history", zh: "了解历史 · 片尾史话" },
            { id: "replay", zh: "再走一遍" },
            { id: "title", zh: "返回标题" },
        ];
        const btnW = 286;
        const btnH = 44;
        const gap = 14;
        const baseY = Math.max(150, h * 0.34);
        const boxes: Rect.Type[] = [];
        let i = 0;
        for (i = 0; i < items.length; i++) {
            boxes.push(Rect(cx - btnW * 0.5, baseY - i * (btnH + gap), btnW, btnH));
        }
        this.epilogueSelected = this.verticalSelection(this.epilogueSelected, boxes, frame);

        for (i = 0; i < items.length; i++) {
            const box = boxes[i];
            const active = this.epilogueSelected === i;
            const cy = box.y + box.height * 0.5;
            if (active) {
                const breathe = 0.86 + 0.14 * Math.sin(this.time * 2.4);
                drawSilkRibbon(uiDraw, uiArt, "ep_rib_" + i, cx, cy, btnW + 24, btnH, PALETTE.rougeSoft, 0.62 * breathe, 0);
                drawHairline(uiInkDraw, uiArt, "ep_line_" + i, cx, box.y + 3, btnW - 44, PALETTE.silkLine, 0.48 * breathe, false, 2);
                drawBlossomDot(uiInkDraw, uiArt, "ep_dot_" + i, box.x + 22, cy, 13, PALETTE.rouge, 0.96, 4);
            } else {
                drawSilkVeil(uiDraw, uiArt, "ep_idle_" + i, cx, cy, btnW, btnH - 2, PALETTE.inkWash, 0.58, 0);
                drawBlossomDot(uiInkDraw, uiArt, "ep_dot_" + i, box.x + 22, cy, 8, PALETTE.silkDim, 0.42, 3);
            }
            texts.put(
                "sm",
                items[i].zh,
                cx + 6,
                cy,
                toColor(active ? PALETTE.textBright : PALETTE.textMid),
                0.5,
                0.5,
                TextAlign.Center,
                active ? 2.6 : 1.6,
                active ? 1.0 : 0.88,
                0.08,
            );
        }

        const footer = getActiveTarget().epilogueFooterHint(frame.mode, frame.layout);
        texts.put("xs", footer, cx, 38 + frame.safe.bottom * 0.4, toColor(PALETTE.textDim), 0.5, 0.5, TextAlign.Center, 1.2, 0.84, 0.08);

        const hit = frame.click ? hitIndex(boxes, frame.pointer, frame.inside) : -1;
        if (hit >= 0 || frame.keys.confirm) {
            const idx = hit >= 0 ? hit : this.epilogueSelected;
            const id = items[idx].id;
            if (id === "history") return { type: "openHistory" };
            if (id === "replay") return { type: "replayStory" };
            return { type: "backTitle" };
        }
        return { type: "none" };
    }

    /**
     * 片尾史话（三张可选史话卡片：海隅筑城 / 井边烟火 / 长灯不绝）：
     * 采用冷素宣纸书页与明版朱丝栏排印，支持左右翻页、手柄 LB/RB 与触屏直点。
     */
    private drawHistory(
        frame: MenuFrame,
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        texts: TextPool,
        w: number,
        h: number,
    ): MenuAction {
        if (frame.back) {
            return { type: this.historyFromEpilogue ? "backEpilogue" : "backTitle" };
        }

        const total = HISTORY_CARDS.length;
        if (frame.keys.left || frame.prevTab) {
            this.historyCardIndex = (this.historyCardIndex + total - 1) % total;
        } else if (frame.keys.right || frame.nextTab) {
            this.historyCardIndex = (this.historyCardIndex + 1) % total;
        }
        const card = HISTORY_CARDS[this.historyCardIndex];

        uiDraw.drawRect(Rect(0, 0, w, h), Color(7, 9, 15, 206));
        const cx = w * 0.5;
        const pageW = Math.min(w - 110 - frame.safe.left - frame.safe.right, 860);
        const pageH = Math.min(h - 140 - frame.safe.top - frame.safe.bottom, 500);
        const px = cx - pageW * 0.5;
        const py = (h - pageH) * 0.5 + 14;
        const midY = py + pageH * 0.5;

        uiArt.tryPlace("ink_frame_mask", "hist_shadow", cx, midY - 6, pageW + 52, pageH + 46, {
            color: toColor(PALETTE.voidDark), opacity: 0.84, layer: -1,
        });
        if (!uiArt.tryPlace("ink_song_paper", "hist_paper", cx, midY, pageW, pageH, { opacity: 0.98, layer: 1 })) {
            uiDraw.drawRect(Rect(px, py, pageW, pageH), toColor(PALETTE.xuanPaper, 248), 1.0, toColor(PALETTE.silkDim, 180));
        }
        fillRadialGlow(uiGlow, cx, midY + 40, 260, 140, Color(236, 224, 202, 16), Color(236, 224, 202, 0), 14);

        // 明版朱丝栏
        const inX = px + 42;
        const inY = py + 32;
        const inW = pageW - 84;
        const inH = pageH - 64;
        const redSilk = toColor(PALETTE.rouge, 118);
        const redSilkFaint = toColor(PALETTE.rouge, 58);
        uiInkDraw.drawRect(Rect(inX, inY, inW, inH), Color(0, 0, 0, 0), 0.95, redSilk);
        uiInkDraw.drawRect(Rect(inX + 4, inY + 4, inW - 8, inH - 8), Color(0, 0, 0, 0), 0.55, redSilkFaint);

        // 天头：片尾史话 + 页码
        const headY = inY + inH - 30;
        texts.put("md", "片尾史话  ·  " + card.indexZh + " · " + card.title, inX + 20, headY, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 2.0, 0.96, 0);
        texts.put("xs", (this.historyCardIndex + 1) + " / " + total, inX + inW - 20, headY, toColor(PALETTE.rouge), 1, 0.5, TextAlign.Right, 1.8, 0.88, 0);
        uiInkDraw.drawSegment(Vec2(inX + 14, headY - 22), Vec2(inX + inW - 14, headY - 22), 0.85, redSilk);

        // 副题
        texts.put("xs", card.subtitle, inX + 20, headY - 42, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 1.4, 0.86, 0);

        // 正文按 UTF-8 字符边界与视觉宽度自动折行（TSTL Lua 字节索引安全，绝不截断多字节汉字）
        const wrapZh = (src: string, maxUnits: number): string[] => {
            const out: string[] = [];
            let buf = "";
            let units = 0;
            let ci = 0;
            while (ci < src.length) {
                const b = src.charCodeAt(ci);
                const step = b < 128 ? 1 : (b < 224 ? 2 : (b < 240 ? 3 : 4));
                const ch = src.slice(ci, ci + step);
                const u = b < 128 ? 0.56 : 1.02;
                if (units + u > maxUnits && buf !== "") {
                    out.push(buf);
                    buf = ch;
                    units = u;
                } else {
                    buf += ch;
                    units += u;
                }
                ci += step;
            }
            if (buf !== "") {
                out.push(buf);
            }
            return out;
        };

        const charsPerLine = Math.max(24, Math.floor((inW - 44) / 20));
        let cursorY = headY - 76;
        let pi = 0;
        for (pi = 0; pi < card.paragraphs.length; pi++) {
            const lines = wrapZh("　　" + card.paragraphs[pi], charsPerLine);
            let li = 0;
            for (li = 0; li < lines.length; li++) {
                texts.put("sm", lines[li], inX + 22, cursorY, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 0.6, 0.94, 0);
                cursorY -= 30;
            }
            cursorY -= 12;
        }

        // 页底小注
        const footY = inY + 26;
        uiInkDraw.drawSegment(Vec2(inX + 14, footY + 20), Vec2(inX + inW - 14, footY + 20), 0.6, redSilkFaint);
        texts.put("xs", card.footnote, inX + 20, footY, toColor(PALETTE.xuanInkSub), 0, 0.5, TextAlign.Left, 0.4, 0.84, 0);

        // 底部导航按钮：上一页 / 卡片标签 / 下一页 / 返回
        const navY = Math.max(30, py - 48);
        const prevBox = Rect(cx - 290, navY, 132, 34);
        const nextBox = Rect(cx + 158, navY, 132, 34);
        const backBox = Rect(cx - 88, navY, 176, 34);

        const drawNavBtn = (box: Rect.Type, tag: string, label: string): boolean => {
            const hover = frame.inside && box.containsPoint(frame.pointer);
            drawSilkVeil(uiDraw, uiArt, "hist_btn_" + tag, box.x + box.width * 0.5, box.y + box.height * 0.5, box.width, box.height, hover ? PALETTE.rougeSoft : PALETTE.inkWash, hover ? 0.86 : 0.72, 2);
            texts.put("xs", label, box.x + box.width * 0.5, box.y + box.height * 0.5, toColor(hover ? PALETTE.textBright : PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 1.4, 0.94, 0.08);
            return hover && frame.click;
        };

        if (drawNavBtn(prevBox, "prev", "上一篇")) {
            this.historyCardIndex = (this.historyCardIndex + total - 1) % total;
        }
        if (drawNavBtn(nextBox, "next", "下一篇")) {
            this.historyCardIndex = (this.historyCardIndex + 1) % total;
        }
        if (drawNavBtn(backBox, "back", this.historyFromEpilogue ? "返回尾声" : "返回标题")) {
            return { type: this.historyFromEpilogue ? "backEpilogue" : "backTitle" };
        }

        if (frame.keys.confirm) {
            if (this.historyCardIndex + 1 < total) {
                this.historyCardIndex += 1;
            } else {
                return { type: this.historyFromEpilogue ? "backEpilogue" : "backTitle" };
            }
        }
        return { type: "none" };
    }
}
