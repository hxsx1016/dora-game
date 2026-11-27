/**
 * 《向西守望》多端目标契约（极薄纯类型 + 常量，零平台/外设驱动实现）。
 *
 * 四端目标：
 * - windows  ：Windows 桌面，仅键鼠（KBM）；
 * - android  ：安卓手机/平板，仅触屏（Touch，含横竖屏自适应）；
 * - handheld ：安卓掌机（KT-R1/R2 等），仅触屏 + 手柄（Touch + Gamepad，锁定横屏）；
 * - web      ：Web 浏览器（全包含：键鼠 + 触屏 + 手柄 + 横竖屏）。
 */

import { Node, Rect } from "Dora";
import type { Play } from "Script/watch/play";
import type { RunState } from "Script/watch/run";
import type { CameraDirector } from "Script/watch/fe/camera";
import type { ScreenKind } from "Script/watch/fe/ui/menus";
import type { Input } from "Script/watch/input";

export type TargetProfileId = "windows" | "android" | "handheld" | "web";
export type PlatformKind = "windows" | "macos" | "linux" | "android" | "ios" | "web" | "unknown";
export type InputMode = "kbm" | "touch" | "gamepad";
export type InputModePref = "auto" | "kbm" | "touch" | "gamepad";
export type DefaultInputMode = InputMode;
export type GamepadLayout = "xbox" | "nintendo";

export interface SafeInsets {
    left: number;
    right: number;
    top: number;
    bottom: number;
}

export const ZERO_SAFE_INSETS: SafeInsets = { left: 0, right: 0, top: 0, bottom: 0 };

export const TOUCH_OPACITY_STEPS = [0.52, 0.78, 0.96];
export const TOUCH_SCALE_STEPS = [0.88, 1.0, 1.14];
export const VOLUME_STEPS = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];

export interface StageViewport {
    /** 完整逻辑视口宽高（对应 View.size） */
    fullW: number;
    fullH: number;
    /** 游戏主舞台在 fullW×fullH 内的左下角原点与宽高 */
    stageX: number;
    stageY: number;
    stageW: number;
    stageH: number;
    /** 竖屏掌机模式下方触控台高度（横屏为 0） */
    deckH: number;
    /** 竖屏掌机模式顶部状态条高度（横屏为 0） */
    topBarH: number;
    /** 是否处于竖屏掌机布局 */
    isPortrait: boolean;
    /** 舞台内 UI 缩放系数（基准 1280×720） */
    uiScale: number;
    /** 舞台内 UI 逻辑宽/高 */
    uiW: number;
    uiH: number;
    /** 换算至完整 View 逻辑像素的四边安全区内缩 */
    safe: SafeInsets;
    /** 换算至主舞台内 UI 逻辑空间的安全区内缩 */
    safeUi: SafeInsets;
}

export interface ReleaseConfig {
    isRelease?: boolean;
    version?: string;
    portableSave?: boolean;
    platform?: string;
    target?: TargetProfileId;
}

export interface PlatformCaps {
    kind: PlatformKind;
    target: TargetProfileId;
    isDesktop: boolean;
    isMobile: boolean;
    isWeb: boolean;
    isStandaloneAndroidApk: boolean;
    canToggleFullscreen: boolean;
    canQuit: boolean;
    hasBackButton: boolean;
    supportsHaptics: boolean;
    needsAudioUnlock: boolean;
    isRelease: boolean;
    defaultInputMode: InputMode;
}

export interface ControlSettings {
    modePref: InputModePref;
    aimAssist: boolean;
    crouchToggle: boolean;
    gamepadLayout: GamepadLayout;
    deadzoneLeft: number;
    deadzoneRight: number;
    touchOpacity: number;
    touchScale: number;
    haptics: boolean;
    masterVol: number;
    bgmVol: number;
    sfxVol: number;
    voiceVol: number;
}

export type KeyActionId =
    | "interact"
    | "jump"
    | "crouch"
    | "cover"
    | "fire"
    | "aim"
    | "pause"
    | "retry"
    | "confirm"
    | "back"
    | "artifact";

export interface ControlsGuidePage {
    subtitle: string;
    soldierRows: [string, string][];
    childRows: [string, string][];
}

export interface ControlsGuideTab {
    mode: InputMode;
    label: string;
}

export interface SettingsRowDef {
    id: string;
    title: string;
}

export interface InteractActionMeta {
    label: string;
    subLabel?: string;
    urgent: boolean;
    progress: number;
    available: boolean;
}

/** app.ts 传给当前端输入驱动的挂载回调，仅含键鼠的端才注册 onKeyDown。 */
export interface TargetAttachHooks {
    onFirstUserGesture: () => void;
    onToggleFullscreen: () => void;
    onKeyDownEvent: (key: string) => void;
}

/** 每帧由 app.ts 喂给当前端输入驱动的统一运行态上下文。 */
export interface TargetFrameSync {
    viewport: StageViewport;
    mode: number;
    screen: ScreenKind;
    play: Play | undefined;
    run: RunState | undefined;
    cam: CameraDirector | undefined;
    input: Input;
    assistHintsEnabled: boolean;
    isMuted: boolean;
    isFullscreen: boolean;
    storyTalentBoxes: Rect.Type[];
    dt: number;
}

export interface TargetInputDriver {
    readonly defaultMode: InputMode;
    attach(parent: Node.Type, hooks: TargetAttachHooks): void;
    syncFrame(ctx: TargetFrameSync): void;
    pollInto(input: Input): void;
    renderOverlay(): void;
    clearTransient(keepTouchToggles: boolean): void;
    vibrate(seconds: number): void;
    shouldShowTouchControls(input: Input, vp: StageViewport): boolean;
    onInputModeChanged?(mode: InputMode): void;
    getTouchRouter?(): unknown;
    getGamepadRouter?(): unknown;
    getTouchControls?(): unknown;
    injectTouch?(phase: "began" | "moved" | "ended", id: number, x: number, y: number, fromMouse?: boolean): void;
    setGamepadSim?(state?: unknown): void;
}

export interface TargetRuntime {
    readonly id: TargetProfileId;
    readonly supportsKbm: boolean;
    readonly supportsTouch: boolean;
    readonly supportsGamepad: boolean;
    readonly supportsPortrait: boolean;
    readonly defaultInputMode: InputMode;
    readonly supportedModes: InputMode[];
    readonly modePrefOrder: InputModePref[];
    readonly controlsGuideTabs: ControlsGuideTab[];

    // 平台与视口
    getPlatformCaps(): PlatformCaps;
    canToggleFullscreen(): boolean;
    canQuitApp(): boolean;
    isReleaseMode(): boolean;
    computeStageViewport(fullW: number, fullH: number): StageViewport;
    triggerHaptics(seconds: number, enabled: boolean): void;

    // 提示文案与操作指南（各端只保留自身支持模式的文案）
    keyTagFor(action: KeyActionId, mode: InputMode, layout: GamepadLayout): string;
    adaptWorldKeyTag(rawKeyTag: string, mode: InputMode, layout: GamepadLayout): string;
    adaptHintSentence(text: string, mode: InputMode, layout: GamepadLayout): string;
    controlsGuideRows(tab: InputMode): ControlsGuidePage;
    splashSkipHint(mode: InputMode, layout: GamepadLayout): string;
    titleFooterHint(mode: InputMode, layout: GamepadLayout): string;
    chapterFooterHint(mode: InputMode, confirmTag: string): string;
    pauseFooterHint(mode: InputMode, layout: GamepadLayout): string;
    settingsFooterHint(mode: InputMode, layout: GamepadLayout): string;
    controlsFooterRightHint(mode: InputMode): string;
    epilogueFooterHint(mode: InputMode, layout: GamepadLayout): string;
    trialSubHint(mode: InputMode, ended: boolean, seed: number): string;

    // 设置项定义与值渲染（各端只暴露本端真实有效的设置项）
    settingsRows(): SettingsRowDef[];
    settingsPauseLabel(settings: ControlSettings): string;
    settingsHeaderTitle(): string;
    settingsHeaderSummary(activeMode: InputMode): string;
    settingsValueText(rowId: string, settings: ControlSettings, activeMode: InputMode): string;
    applySettingsDelta(
        rowId: string,
        delta: number,
        settings: ControlSettings,
        input: Input,
    ): "none" | "audio" | "back" | "control";

    // 创建该端专属输入驱动
    createDriver(settings: ControlSettings): TargetInputDriver;
}

export function getReleaseConfig(): ReleaseConfig | undefined {
    const reg = (globalThis as unknown as { package?: { loaded?: Record<string, unknown> } }).package?.loaded;
    const cfg = reg !== undefined ? reg["watch.release"] : undefined;
    if (cfg !== undefined && typeof cfg === "object") {
        return cfg as ReleaseConfig;
    }
    return undefined;
}
