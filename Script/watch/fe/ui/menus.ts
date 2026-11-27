/**
 * 《向西守望》宋明清雅水墨菜单体系（全平台 × 三模统一解耦版）：
 * - 开机序幕（splash）：4.65s 局外人团队标 → 向西守望主标 → 柔化进入标题页，0.25s 后键鼠/手柄/触屏/返回键任意跳过；
 * - 标题页：竖版品牌主标（缺图自动回退龙藏体 + 朱砂孤印）+ 右下角团队微光角标 + 按平台能力过滤「退出游戏」；
 * - 选章页：千里驿道长卷，支持安全区内缩、3:2/4:3 纵向舒展与触屏两段防误触确认；
 * - 执器要诀：键鼠 / 手柄 / 触屏三页统一说明（左右 / LB / RB / 点击自由切换）；
 * - 局内暂停：桌面严格保持原 0..7 索引零回归（4=fullscreen，7=quit），末尾追加「操控设置」原地二级页，
 *   让所有平台都能随时选择操作模式（自动/键鼠/触屏/手柄）及共享磁吸、手柄布局与触控参数。
 */

import { App, Color, DrawNode, Keyboard, KeyName, Rect, TextAlign, Vec2 } from "Dora";
import { ROOMS } from "Script/watch/rooms";
import { Input } from "Script/watch/input";
import {
    GamepadLayout,
    InputMode,
    TOUCH_OPACITY_STEPS,
    TOUCH_SCALE_STEPS,
    inputModeLabelOf,
    layoutLabelOf,
    modePrefLabelOf,
    nextStepValue,
    opacityLabelOf,
    saveControlSettings,
    scaleLabelOf,
} from "Script/watch/controls_config";
import {
    SafeInsets,
    ZERO_SAFE_INSETS,
    canQuitApp,
    canToggleFullscreen,
    getPlatformCaps,
} from "Script/watch/platform";
import { controlsGuideRows, keyTagFor } from "Script/watch/fe/ui/control_prompts";
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

export type ScreenKind = "splash" | "title" | "chapters" | "controls" | "play";

export interface MenuAction {
    type:
        | "none"
        | "splashDone"
        | "continue"
        | "start"
        | "trial"
        | "jump"
        | "resume"
        | "retry"
        | "toTitle"
        | "openChapters"
        | "openControls"
        | "backTitle"
        | "backPause"
        | "toggleFullscreen"
        | "quit";
    roomIndex?: number;
}

const TITLE_ITEMS = [
    { id: "start", zh: "开始游戏" },
    { id: "chapters", zh: "选择章节" },
    { id: "controls", zh: "操作说明" },
    { id: "trial", zh: "护送试炼 · 肉鸽" },
    { id: "quit", zh: "退出游戏" },
];

// 博物馆由双通关后的井口进入，章节菜单保留公开关卡原有的房间索引。
const CHAPTERS = ROOMS.map((room, roomIndex) => ({ room, roomIndex }))
    .filter(chapter => chapter.room.key !== "museum");

// 桌面端严格保持 0..7 既有顺序（4 = fullscreen，7 = quit），第 8 项追加「操控设置」二级页。
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
];

const SETTINGS_ROWS = [
    { id: "modePref", title: "操作模式" },
    { id: "aimAssist", title: "瞄准磁吸" },
    { id: "gpLayout", title: "手柄确认键" },
    { id: "crouchMode", title: "手柄蹲伏方式" },
    { id: "touchOpacity", title: "触控按键透度" },
    { id: "touchScale", title: "触控按键大小" },
    { id: "haptics", title: "触觉震动反馈" },
    { id: "back", title: "返回暂歇菜单" },
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
    settingsSelected = 0;
    /** 存在有效局中存档时，标题页首项显示「继续游戏」，无存档时保持原 5 项索引不变。 */
    hasSession = false;
    /** 操作说明页当前分页（自动随最近输入模式同步，支持左右 / LB / RB / 点击切换） */
    controlsTab: InputMode = "kbm";

    private chaptersFromPause = false;
    private pauseShowControls = false;
    private pauseShowSettings = false;
    private controlsTabManual = false;
    private previousKeys: Partial<MenuKeys> = {};
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

    openPauseSettings(): void {
        this.pauseShowControls = false;
        this.pauseShowSettings = true;
        this.settingsSelected = 0;
        this.resetInput();
    }

    openChapters(roomIndex?: number): void {
        this.chaptersFromPause = roomIndex !== undefined;
        this.chapterSelected = Math.max(0, CHAPTERS.findIndex(chapter => chapter.roomIndex === roomIndex));
        this.pauseShowControls = false;
        this.pauseShowSettings = false;
        this.resetInput();
    }

    openPause(): void {
        this.pauseSelected = 0;
        this.pauseShowControls = false;
        this.pauseShowSettings = false;
        this.resetInput();
    }

    /** 外部注入返回边沿（供 Android 系统返回键 BackButton 调用）。 */
    triggerBack(): void {
        this.queuedBack = true;
    }

    /** 页面切换后，把仍按住的键视为旧输入，避免切页串键。 */
    resetInput(): void {
        this.previousKeys = pressedKeys();
        this.queuedKeys = {};
        this.queuedBack = false;
        this.queuedSkip = false;
        this.controlsTabManual = false;
    }

    /** 锁存两个渲染帧之间的短按。方向键轮询也保留同一份按下边沿。 */
    onKeyEvent(key: KeyName): void {
        this.queuedSkip = true;
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

    private readFrame(input: Input, scale: number, safe: SafeInsets): MenuFrame {
        const held = pressedKeys();
        const prev = this.previousKeys;
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
                up: queued.up === true || (held.up && !prev.up) || input.navUp,
                down: queued.down === true || (held.down && !prev.down) || input.navDown,
                left: queued.left === true || (held.left && !prev.left) || input.navLeft,
                right: queued.right === true || (held.right && !prev.right) || input.navRight,
                confirm: queued.confirm === true || (held.confirm && !prev.confirm) || input.navConfirm,
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
        this.previousKeys = held;
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
            const skipText = frame.mode === "touch"
                ? "轻触跳过"
                : (frame.mode === "gamepad"
                    ? (keyTagFor("confirm", "gamepad", frame.layout) + " / START  跳过")
                    : "ESC / SPACE  SKIP");
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
        const menuX = 112 + frame.safe.left * 0.6;
        const btnW = 280;
        const btnH = frame.mode === "touch" ? 44 : 40;
        const gap = this.hasSession ? 6 : 8;
        const startY = (this.hasSession ? 298 : 268) + extraH * 0.35;
        const boxes: Rect.Type[] = [];
        let i = 0;
        for (i = 0; i < items.length; i++) {
            boxes.push(Rect(menuX - 10, startY - i * (btnH + gap), btnW + 10, btnH));
        }
        this.selected = this.verticalSelection(this.selected, boxes, frame);

        for (i = 0; i < items.length; i++) {
            const by = boxes[i].y;
            const active = this.selected === i;
            const cy = by + btnH * 0.5;
            const shiftX = active ? 10 : 0;

            if (active) {
                const breathe = 0.84 + 0.16 * Math.sin(this.time * 2.2);
                drawSilkRibbon(uiDraw, uiArt, "title_rib_red_" + i, menuX + 124, cy, 290, btnH, PALETTE.rougeSoft, 0.52 * breathe, 0);
                drawHairline(uiInkDraw, uiArt, "title_rib_line_" + i, menuX + 114, by + 4, 230, PALETTE.silkLine, 0.42 * breathe, false, 2);
                drawBlossomDot(uiInkDraw, uiArt, "title_dot_" + i, menuX + 14, cy, 16, PALETTE.rouge, 0.96, 4);
                fillRadialGlow(uiGlow, menuX + 14, cy, 22, 16, toColor(PALETTE.rouge, 28 * breathe), Color(182, 58, 56, 0), 10);
            } else {
                drawBlossomDot(uiInkDraw, uiArt, "title_dot_" + i, menuX + 14, cy, 8, PALETTE.silkDim, 0.40, 3);
            }

            texts.put(
                "md",
                items[i].zh,
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

        const titleHint = frame.mode === "gamepad"
            ? ("左摇杆 / 十字键择项   ·   " + keyTagFor("confirm", "gamepad", frame.layout) + " 或点选启程")
            : (frame.mode === "touch"
                ? (getPlatformCaps().hasBackButton && canQuitApp()
                    ? "轻触择项启程   ·   双击返回键退出"
                    : "轻触择项启程   ·   支持键鼠与手柄")
                : "上下择项   ·   回车或点选启程");
        texts.put("xs", titleHint, menuX + 12, 42 + frame.safe.bottom * 0.45, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.4, 0.88, 0.08);

        // 右下角克制团队落款（局外人 T2 微光角标）
        const badgeRight = w - frame.safe.right * 0.5;
        const badgeY = 42 + frame.safe.bottom * 0.4;
        fillHGradRect(uiDraw, badgeRight - 270, 0, 270 + frame.safe.right * 0.5, 86, Color(8, 10, 16, 0), Color(8, 10, 16, 204));
        uiArt.tryPlace("brand_team_badge", "title_team_badge", badgeRight - 118, badgeY, 168, 54, {
            opacity: 0.95, layer: 3,
        });

        const hit = frame.click ? hitIndex(boxes, frame.pointer, frame.inside) : -1;
        if (hit >= 0 || frame.keys.confirm) {
            const idx = hit >= 0 ? hit : this.selected;
            const id = items[idx].id;
            if (id === "continue") return { type: "continue" };
            if (id === "trial") return { type: "trial" };
            if (id === "start") return { type: "start" };
            if (id === "chapters") return { type: "openChapters" };
            if (id === "quit") return { type: "quit" };
            return { type: "openControls" };
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
            return back;
        }

        const extraH = Math.max(0, h - 720);
        const marginX = Math.max(96, 56 + Math.max(frame.safe.left, frame.safe.right));
        const splitTrack = CHAPTERS.length > 8;
        const perRow = splitTrack ? Math.ceil(CHAPTERS.length / 2) : CHAPTERS.length;
        const trackY = (splitTrack ? 195 : 148) + extraH * 0.25;
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

        uiDraw.drawRect(Rect(0, 0, w, h), Color(10, 12, 19, 198));

        const topHeadY = h - 66 - frame.safe.top * 0.35;
        texts.put("banner", "选择章节", marginX, topHeadY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 4.5, 0.96, 0.10);
        drawHairline(uiInkDraw, uiArt, "chap_top_line", w * 0.5, topHeadY - 34, w - marginX * 2, PALETTE.silkDim, 0.60, true, 2);

        const activeRoom = CHAPTERS[this.chapterSelected].room;
        const theme = themeOf(activeRoom.key);
        const winX = marginX;
        const winY = 266 + extraH * 0.44;
        const winW = Math.min(548, Math.max(420, w * 0.43));
        const winH = 300;
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

        texts.put("xs", theme.actCode + "  ·  " + theme.lineTag, winX + 20, winY + 22, toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.8, 0.90, 0.08);

        const infoX = winX + winW + 46;
        const infoCenterY = winY + winH * 0.5;
        drawMistCurve(uiArt, "chap_info_mist", infoX + 210, infoCenterY + 36, 420, 88, theme.accent, 0.22, -1);

        const volCol = theme.lineTag === "周戍" ? PALETTE.cyan : PALETTE.amber;
        texts.put("xs", theme.volumeTagZh, infoX, winY + winH - 44, toColor(volCol), 0, 0.5, TextAlign.Left, 2.8, 0.92, 0.08);

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
        texts.put("sm", theme.introWhisper, infoX, titleY - 72, toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.8, 0.94, 0.08);

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
        const chapConfirmTag = frame.mode === "gamepad"
            ? keyTagFor("confirm", "gamepad", frame.layout)
            : (frame.mode === "touch" ? "点选" : "Enter");
        texts.put("xs", chapConfirmTag, goX + 156, goY + 21, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.0, 0.82, 0.08);

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
            const nodeCol = active ? PALETTE.rouge : (rt.lineTag === "周戍" ? PALETTE.cyan : PALETTE.amber);

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

        const backX = marginX;
        const backY = 40 + frame.safe.bottom * 0.45;
        const backBox = Rect(backX - 6, backY - 6, 210, 46);
        const backHover = frame.inside && backBox.containsPoint(frame.pointer);
        const chapBackTag = frame.mode === "gamepad"
            ? keyTagFor("back", "gamepad", frame.layout)
            : (frame.mode === "touch" ? "返回" : "ESC");
        const chapFooter = frame.mode === "gamepad"
            ? ("摇杆/十字键选择   ·   " + chapConfirmTag + " 或点选进入")
            : (frame.mode === "touch"
                ? "轻触驿站预览   ·   再点或轻触入此卷章"
                : "方向键选择   ·   回车或点击进入");
        drawSilkKeycap(uiInkDraw, texts, backX, backY + 5, 48, 24, chapBackTag, backHover ? PALETTE.rouge : PALETTE.silkDim, 0.92, backHover);
        texts.put("sm", this.chaptersFromPause ? "返回暂停" : "返回标题", backX + 60, backY + 17, toColor(backHover ? PALETTE.textBright : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.8, 0.90, 0.08);
        texts.put("xs", chapFooter, w - marginX, backY + 17, toColor(PALETTE.textDim), 1, 0.5, TextAlign.Right, 1.2, 0.75, 0.08);

        if (frame.click && backHover) {
            return back;
        }
        // 触屏无悬停：首次轻触未选驿站仅预览，再次点击同一驿站或点击画窗/入此卷章进关
        const stationConfirmed = frame.mode === "touch"
            ? (hitStation >= 0 && hitStation === prevSelected)
            : (hitStation >= 0);
        if (keys.confirm || (frame.click && (stationConfirmed || winHover || goHover))) {
            return { type: "jump", roomIndex: CHAPTERS[this.chapterSelected].roomIndex };
        }
        return { type: "none" };
    }

    /** 操作说明 V3：「极简通透双栏素笺」× 键鼠 / 手柄 / 触屏三页统一切换 */
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
        if (!this.controlsTabManual) {
            this.controlsTab = frame.mode;
        }
        const tabOrder: InputMode[] = ["kbm", "gamepad", "touch"];
        const tabLabels = ["键鼠", "手柄", "触屏"];
        const marginX = Math.max(96, 56 + Math.max(frame.safe.left, frame.safe.right));
        const tabW = 92;
        const tabH = 28;
        const tabGap = 10;
        const tabStartX = w - marginX - (tabW * 3 + tabGap * 2);
        const tabY = h - 82 - frame.safe.top * 0.35;
        const tabBoxes: Rect.Type[] = [
            Rect(tabStartX, tabY, tabW, tabH),
            Rect(tabStartX + tabW + tabGap, tabY, tabW, tabH),
            Rect(tabStartX + (tabW + tabGap) * 2, tabY, tabW, tabH),
        ];

        const hitTab = hitIndex(tabBoxes, frame.pointer, frame.inside);
        if (frame.click && hitTab >= 0) {
            this.controlsTab = tabOrder[hitTab];
            this.controlsTabManual = true;
        } else if (frame.keys.left || frame.prevTab) {
            const cur = tabOrder.indexOf(this.controlsTab);
            this.controlsTab = tabOrder[(cur + tabOrder.length - 1) % tabOrder.length];
            this.controlsTabManual = true;
        } else if (frame.keys.right || frame.nextTab) {
            const cur = tabOrder.indexOf(this.controlsTab);
            this.controlsTab = tabOrder[(cur + 1) % tabOrder.length];
            this.controlsTabManual = true;
        }

        const backX = marginX;
        const backY = 40 + frame.safe.bottom * 0.45;
        const backBox = Rect(backX - 6, backY - 6, 250, 46);
        const backHover = frame.inside && backBox.containsPoint(frame.pointer);
        if (frame.back || (frame.keys.confirm && !(frame.click && hitTab >= 0)) || (frame.click && backHover)) {
            return { type: "backTitle" };
        }
        uiDraw.drawRect(Rect(0, 0, w, h), Color(10, 12, 19, 204));

        const guide = controlsGuideRows(this.controlsTab);
        const topHeadY = h - 66 - frame.safe.top * 0.35;
        texts.put("banner", "执器要诀", marginX, topHeadY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 4.5, 0.96, 0.10);
        texts.put("xs", guide.subtitle, marginX + 196, topHeadY - 4, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.8, 0.85, 0.08);
        drawHairline(uiInkDraw, uiArt, "ctrl_top_line", w * 0.5, topHeadY - 34, w - marginX * 2, PALETTE.silkDim, 0.60, true, 2);

        let ti = 0;
        for (ti = 0; ti < tabBoxes.length; ti++) {
            const tb = tabBoxes[ti];
            const activeTab = this.controlsTab === tabOrder[ti];
            const hoverTab = hitTab === ti;
            uiInkDraw.drawRect(
                tb,
                activeTab ? toColor(PALETTE.rougeSoft, 150) : Color(14, 17, 25, hoverTab ? 185 : 130),
                0.9,
                toColor(activeTab ? PALETTE.rouge : (hoverTab ? PALETTE.textBright : PALETTE.silkDim), activeTab ? 225 : 155),
            );
            texts.put(
                "xs",
                tabLabels[ti],
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
        for (i = 0; i < guide.soldierRows.length; i++) {
            const ry = headY - 66 - i * rowStep;
            drawSilkKeycap(uiInkDraw, texts, leftColX + 2, ry - 13, 136, 26, guide.soldierRows[i][0], PALETTE.cyan, 0.92, false);
            texts.put("sm", guide.soldierRows[i][1], leftColX + 152, ry, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.8, 0.92, 0.08);
        }

        const rightColX = midX + 44;
        drawBlossomDot(uiInkDraw, uiArt, "ctrl_r_dot", rightColX + 8, headY, 12, PALETTE.amber, 0.88, 3);
        texts.put("md", "小满 · 潜行与寻路", rightColX + 26, headY, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 2.4, 0.98, 0.08);
        drawHairline(uiInkDraw, uiArt, "ctrl_r_line", rightColX + colW * 0.5, headY - 24, colW, PALETTE.amberDim, 0.58, false, 2);

        for (i = 0; i < guide.childRows.length; i++) {
            const ry = headY - 66 - i * rowStep;
            drawSilkKeycap(uiInkDraw, texts, rightColX + 2, ry - 13, 136, 26, guide.childRows[i][0], PALETTE.amber, 0.92, false);
            texts.put("sm", guide.childRows[i][1], rightColX + 152, ry, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 0.8, 0.92, 0.08);
        }

        const ctrlBackKey = frame.mode === "gamepad"
            ? (keyTagFor("back", "gamepad", frame.layout) + " / " + keyTagFor("confirm", "gamepad", frame.layout))
            : (frame.mode === "touch" ? "返回" : "ESC / ENTER");
        const ctrlRightHint = frame.mode === "gamepad"
            ? "LB / RB 或左右切换键位图"
            : (frame.mode === "touch"
                ? "轻触右上页签切图 · 暂歇菜单可调操控设置"
                : (canToggleFullscreen() ? "←/→ 切页   ·   F11 / Alt+Enter 全屏" : "←/→ 切页   ·   暂歇菜单可调操控设置"));
        const keyW = frame.mode === "touch" ? 76 : 110;
        drawSilkKeycap(uiInkDraw, texts, backX, backY + 5, keyW, 24, ctrlBackKey, backHover ? PALETTE.rouge : PALETTE.silkDim, 0.92, backHover);
        texts.put("sm", backLabel, backX + keyW + 12, backY + 17, toColor(backHover ? PALETTE.textBright : PALETTE.textMid), 0, 0.5, TextAlign.Left, 1.8, 0.92, 0.08);
        texts.put("xs", ctrlRightHint, w - marginX, backY + 17, toColor(PALETTE.textDim), 1, 0.5, TextAlign.Right, 1.2, 0.78, 0.08);

        return { type: "none" };
    }

    /** 暂停内原地「操控设置」二级页：所有平台统一选择操作模式（自动/键鼠/触屏/手柄）与触控/手柄参数。 */
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
            return true;
        }

        const caps = getPlatformCaps();
        const s = input.settings;

        uiDraw.drawRect(Rect(0, 0, w, h), Color(10, 12, 19, 206));

        const marginX = Math.max(96, 56 + Math.max(frame.safe.left, frame.safe.right));
        const topHeadY = h - 66 - frame.safe.top * 0.35;
        texts.put("banner", "操控设置", marginX, topHeadY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 4.5, 0.96, 0.10);
        const curSummary = "当前模式：" + inputModeLabelOf(input.inputMode) + " · 全平台支持键鼠 / 触屏 / 手柄";
        texts.put("xs", curSummary, marginX + 196, topHeadY - 4, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 1.4, 0.88, 0.08);
        drawHairline(uiInkDraw, uiArt, "set_top_line", w * 0.5, topHeadY - 34, w - marginX * 2, PALETTE.silkDim, 0.60, true, 2);

        const panelW = Math.min(760, w - marginX * 2);
        const panelX = (w - panelW) * 0.5;
        const rowH = 44;
        const rowStep = 50;
        const firstY = topHeadY - 104;

        const boxes: Rect.Type[] = [];
        let i = 0;
        for (i = 0; i < SETTINGS_ROWS.length; i++) {
            boxes.push(Rect(panelX, firstY - i * rowStep, panelW, rowH));
        }
        this.settingsSelected = this.verticalSelection(this.settingsSelected, boxes, frame);

        const applyDelta = (rowId: string, delta: number): boolean => {
            if (rowId === "back") {
                return true;
            }
            if (rowId === "modePref") {
                input.cycleModePref(delta);
            } else if (rowId === "aimAssist") {
                s.aimAssist = !s.aimAssist;
                saveControlSettings(s);
            } else if (rowId === "gpLayout") {
                s.gamepadLayout = s.gamepadLayout === "xbox" ? "nintendo" : "xbox";
                input.gamepadLayout = s.gamepadLayout;
                saveControlSettings(s);
            } else if (rowId === "crouchMode") {
                s.crouchToggle = !s.crouchToggle;
                saveControlSettings(s);
            } else if (rowId === "touchOpacity") {
                s.touchOpacity = nextStepValue(s.touchOpacity, TOUCH_OPACITY_STEPS, delta);
                saveControlSettings(s);
            } else if (rowId === "touchScale") {
                s.touchScale = nextStepValue(s.touchScale, TOUCH_SCALE_STEPS, delta);
                saveControlSettings(s);
            } else if (rowId === "haptics") {
                s.haptics = !s.haptics;
                saveControlSettings(s);
                if (s.haptics) {
                    input.getTouch()?.vibrate(0.018);
                }
            }
            return false;
        };

        const valueTextOf = (rowId: string): string => {
            if (rowId === "modePref") {
                return s.modePref === "auto"
                    ? ("自动切换（" + inputModeLabelOf(input.inputMode) + "）")
                    : ("锁定 · " + modePrefLabelOf(s.modePref));
            }
            if (rowId === "aimAssist") return s.aimAssist ? "开（触屏与手柄共用）" : "关";
            if (rowId === "gpLayout") return layoutLabelOf(s.gamepadLayout);
            if (rowId === "crouchMode") return s.crouchToggle ? "点按切换" : "持续按住";
            if (rowId === "touchOpacity") return opacityLabelOf(s.touchOpacity);
            if (rowId === "touchScale") return scaleLabelOf(s.touchScale);
            if (rowId === "haptics") return caps.supportsHaptics ? (s.haptics ? "开" : "关") : (s.haptics ? "开（仅移动端生效）" : "关");
            return "";
        };

        for (i = 0; i < SETTINGS_ROWS.length; i++) {
            const row = SETTINGS_ROWS[i];
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

            const val = valueTextOf(row.id);
            if (val !== "") {
                const valCol = active ? PALETTE.amberCore : PALETTE.cyanCore;
                const decorated = active ? ("‹  " + val + "  ›") : val;
                texts.put("sm", decorated, panelX + panelW - 24, cy, toColor(valCol), 1, 0.5, TextAlign.Right, 1.0, active ? 1.0 : 0.86, 0.08);
            }
        }

        const backY = 40 + frame.safe.bottom * 0.45;
        const hint = frame.mode === "gamepad"
            ? ("左右或 " + keyTagFor("confirm", "gamepad", frame.layout) + " 切换   ·   " + keyTagFor("back", "gamepad", frame.layout) + " 返回暂停")
            : (frame.mode === "touch"
                ? "轻触任意条目切换   ·   设置自动保存"
                : "←/→ 或回车/点击切换   ·   Esc 返回暂停");
        texts.put("xs", hint, w * 0.5, backY + 14, toColor(PALETTE.textDim), 0.5, 0.5, TextAlign.Center, 1.2, 0.84, 0.08);

        const hit = frame.click ? hitIndex(boxes, frame.pointer, frame.inside) : -1;
        if (hit >= 0) {
            this.settingsSelected = hit;
            if (applyDelta(SETTINGS_ROWS[hit].id, 1)) {
                return true;
            }
            this.resetInput();
            return false;
        }
        if (frame.keys.left || frame.prevTab) {
            const id = SETTINGS_ROWS[this.settingsSelected].id;
            if (id !== "back") {
                applyDelta(id, -1);
                this.resetInput();
            }
            return false;
        }
        if (frame.keys.right || frame.nextTab || frame.keys.confirm) {
            const id = SETTINGS_ROWS[this.settingsSelected].id;
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

        if (frame.back) {
            this.pauseShowControls = false;
            this.pauseShowSettings = false;
            return { type: "resume" };
        }

        const allowFs = canToggleFullscreen();
        const allowQuit = canQuitApp();
        const pauseItems = PAUSE_ITEMS.filter(item =>
            (item.id !== "fullscreen" || allowFs) && (item.id !== "quit" || allowQuit),
        );
        if (this.pauseSelected >= pauseItems.length) {
            this.pauseSelected = 0;
        }

        uiDraw.drawRect(Rect(0, 0, w, h), Color(8, 10, 16, 102));
        fillHGradRect(uiDraw, 0, 0, w * 0.27 + frame.safe.left, h, Color(9, 11, 18, 232), Color(10, 13, 21, 198));
        fillHGradRect(uiDraw, w * 0.27 + frame.safe.left, 0, w * 0.21, h, Color(10, 13, 21, 198), Color(10, 13, 21, 0));

        const menuX = 110 + frame.safe.left * 0.6;
        const compact = pauseItems.length > 8;
        const headY = (compact ? h - 122 : h - 146) - frame.safe.top * 0.35;
        uiArt.tryPlace("ink_vstream", "pause_vstream", menuX - 32, h * 0.5, 34, h * 0.78, {
            color: toColor(PALETTE.silkDim), opacity: 0.48, layer: 1,
        });
        drawMistCurve(uiArt, "pause_mist", menuX + 118, headY - 8, 290, 72, PALETTE.jadeMist, 0.20, -1);

        texts.put("banner", "暂歇", menuX + 16, headY, toColor(PALETTE.textBright), 0, 0.5, TextAlign.Left, 10.0, 0.98, 0.10);
        texts.put("xs", "月夜暂驻 · 卷页留痕", menuX + 18, headY - 36, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 2.0, 0.80, 0.08);
        drawHairline(uiInkDraw, uiArt, "pause_div", menuX + 124, headY - 60, 240, PALETTE.silkDim, 0.58, true, 2);

        const rowStep = compact ? 42 : 46;
        const rowH = compact ? 36 : 38;
        const firstY = compact ? (headY - 112) : (headY - 120);
        const boxes: Rect.Type[] = [];
        let i = 0;
        for (i = 0; i < pauseItems.length; i++) {
            boxes.push(Rect(menuX - 10, firstY - i * rowStep, 286, rowH));
        }
        this.pauseSelected = this.verticalSelection(this.pauseSelected, boxes, frame);

        for (i = 0; i < pauseItems.length; i++) {
            const iy = boxes[i].y;
            const active = this.pauseSelected === i;
            const cy = iy + rowH * 0.5;
            const shiftX = active ? 10 : 0;
            const item = pauseItems[i];
            let label = item.zh;
            if (item.id === "assist") {
                label = assistHintsEnabled ? "按键辅助：开" : "按键辅助：关";
            } else if (item.id === "fullscreen") {
                label = App.fullScreen ? "显示：全屏" : "显示：窗口";
            } else if (item.id === "settings") {
                label = "操控设置 · " + modePrefLabelOf(input.settings.modePref);
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

        const pauseFooter = frame.mode === "gamepad"
            ? (keyTagFor("back", "gamepad", frame.layout) + " / START 续行   ·   " + keyTagFor("confirm", "gamepad", frame.layout) + " 确认")
            : (frame.mode === "touch"
                ? "轻触确认   ·   点「继续游戏」续行"
                : "Esc 续行   ·   Enter 或点击确认");
        texts.put("xs", pauseFooter, menuX + 12, 38 + frame.safe.bottom * 0.4, toColor(PALETTE.textDim), 0, 0.5, TextAlign.Left, 1.2, 0.86, 0.08);

        const hit = frame.click ? hitIndex(boxes, frame.pointer, frame.inside) : -1;
        if (hit >= 0 || frame.keys.confirm) {
            const idx = hit >= 0 ? hit : this.pauseSelected;
            const id = pauseItems[idx].id;
            if (id === "controls") {
                this.pauseShowControls = true;
                this.resetInput();
                return { type: "none" };
            }
            if (id === "settings") {
                this.openPauseSettings();
                return { type: "none" };
            }
            if (id === "assist") {
                if (onToggleAssist !== undefined) {
                    onToggleAssist();
                }
                this.resetInput();
                return { type: "none" };
            }
            if (id === "fullscreen") {
                this.resetInput();
                return { type: "toggleFullscreen" };
            }
            this.pauseShowControls = false;
            this.pauseShowSettings = false;
            if (id === "resume") return { type: "resume" };
            if (id === "retry") return { type: "retry" };
            if (id === "chapters") return { type: "openChapters" };
            if (id === "quit") return { type: "quit" };
            return { type: "toTitle" };
        }
        return { type: "none" };
    }
}
