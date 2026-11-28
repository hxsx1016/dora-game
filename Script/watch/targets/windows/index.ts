/**
 * 《向西守望》Windows 桌面目标（纯键鼠 KBM-only）。
 *
 * 严格裁剪：
 * - 零触屏路由、零虚拟触控层（省去 178 个 SDF Label + 4 DrawNode）、零手柄 136 次/帧 FFI 轮询、零磁吸敌兵投影；
 * - 零竖屏掌机台代码、零触屏/手柄提示文案；
 * - 设置页仅暴露四通道音量；执器要诀仅显示键鼠单页。
 */

import { App, Node, PlatformType, View } from "Dora";
import { KbmPoller } from "Script/watch/input/kbm_core";
import { applyVolumeSetting, volumeSettingText } from "Script/watch/controls_config";
import type { Input } from "Script/watch/input";
import {
    ControlSettings,
    ControlsGuidePage,
    GamepadLayout,
    InputMode,
    KeyActionId,
    PlatformCaps,
    PlatformKind,
    SettingsRowDef,
    StageViewport,
    TargetAttachHooks,
    TargetFrameSync,
    TargetInputDriver,
    TargetRuntime,
    ZERO_SAFE_INSETS,
    getReleaseConfig,
} from "Script/watch/target_types";

const WINDOWS_SETTINGS_ROWS: SettingsRowDef[] = [
    { id: "masterVol", title: "主音量" },
    { id: "bgmVol", title: "音乐音量" },
    { id: "sfxVol", title: "音效与环境" },
    { id: "voiceVol", title: "人声音量" },
    { id: "back", title: "返回暂歇菜单" },
];

const WINDOWS_GUIDE: ControlsGuidePage = {
    subtitle: "键鼠操作说明 · Windows 桌面",
    soldierRows: [
        ["WASD / 方向键", "左右、前后纵深自由移动"],
        ["鼠标 + 左键 / Q", "瞄准发射火铳 · Q 随时开换弹盘"],
        ["按住 SHIFT / SPACE", "贴靠掩体挡弹 · 平地翻滚或翻越"],
        ["E / 1·2·3", "交互推车工台 · 数字键选护送本领"],
        ["拖线 / 方向+回车", "慢时 3×3 换弹盘 · 右键/退格重画"],
        ["ESC / R / T", "暂歇菜单 / 重试检查点 / 切神器"],
    ],
    childRows: [
        ["WASD / 方向键", "前后左右纵深潜行"],
        ["按住 SHIFT", "轻步慢走（压低脚步声）"],
        ["按住 C / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"],
        ["SPACE", "跳跃攀上石阶与矮台"],
        ["E", "拾瓶 / 敲塔门 / 按住+D 拉车"],
        ["F 按住→松开", "瞄准砖地/铁盆投瓶 · 右键取消"],
    ],
};

function desktopKind(): PlatformKind {
    const plat = App.platform;
    if (plat === PlatformType.macOS) return "macos";
    if (plat === PlatformType.Linux) return "linux";
    return "windows";
}

function keyTagKbm(action: KeyActionId): string {
    if (action === "interact") return "E";
    if (action === "jump") return "SPACE";
    if (action === "crouch") return "CTRL";
    if (action === "cover") return "SHIFT";
    if (action === "fire") return "左键";
    if (action === "aim") return "F";
    if (action === "pause") return "ESC";
    if (action === "retry") return "R";
    if (action === "confirm") return "ENTER";
    if (action === "back") return "ESC";
    return "T";
}

function computeWindowsViewport(fullW: number, fullH: number): StageViewport {
    const w = Math.max(320, fullW > 0 ? fullW : View.size.width);
    const h = Math.max(180, fullH > 0 ? fullH : View.size.height);
    const uiScale = Math.max(0.25, Math.min(w / 1280, h / 720));
    return {
        fullW: w,
        fullH: h,
        stageX: 0,
        stageY: 0,
        stageW: w,
        stageH: h,
        deckH: 0,
        topBarH: 0,
        isPortrait: false,
        uiScale,
        uiW: w / uiScale,
        uiH: h / uiScale,
        safe: ZERO_SAFE_INSETS,
        safeUi: ZERO_SAFE_INSETS,
    };
}

class WindowsInputDriver implements TargetInputDriver {
    readonly defaultMode: InputMode = "kbm";
    private kbm = new KbmPoller();

    attach(parent: Node.Type, hooks: TargetAttachHooks): void {
        this.kbm.attach(parent, hooks);
    }

    syncFrame(_ctx: TargetFrameSync): void {
        // Windows 纯键鼠无需每帧同步触控热区、手柄上下文或敌兵磁吸投影
    }

    renderOverlay(): void {
        // Windows 无虚拟触控覆盖层
    }

    clearTransient(_keepTouchToggles: boolean): void {
        // 纯键鼠无瞬时虚拟摇杆/手柄态
    }

    vibrate(_seconds: number): void {
        // 桌面端无触觉震动
    }

    shouldShowTouchControls(_input: Input, _vp: StageViewport): boolean {
        return false;
    }

    pollInto(input: Input): void {
        input.inputMode = "kbm";
        const s = this.kbm.sample(input.getStageViewport());

        if (s.anyKb || s.mouseMoved || (s.mouseClicked && s.mouseInsideStage)) {
            input.userInteracted = true;
        }

        input.moveX = s.moveX;
        input.moveY = s.moveY;
        input.applyKeyHeld(
            s.jump,
            s.crouch,
            s.cover,
            s.interact,
            s.aim,
            s.mouseInsideStage && s.mouseLeft,
            s.flare,
            s.pause,
            s.retry,
            s.toggleView,
            s.tab,
        );

        input.resetFrameSignals();
        if (input.aim.held && s.mouseRightPressed) {
            input.bottleCanceled = true;
            input.aim.held = false;
            input.aim.pressed = false;
            input.aim.released = false;
        }

        input.navUp = s.navUp;
        input.navDown = s.navDown;
        input.navLeft = s.navLeft;
        input.navRight = s.navRight;
        input.navConfirm = s.navConfirm;
        input.navBack = false;
        input.craftConfirm = s.uiConfirmWithE;
        input.craftCancel = s.uiBackSpace;

        const rCol = (s.navRight ? 1 : 0) - (s.navLeft ? 1 : 0);
        const rRow = (s.navUp ? 1 : 0) - (s.navDown ? 1 : 0);
        if (rCol !== 0 || rRow !== 0) {
            input.reloadDirCol = rCol;
            input.reloadDirRow = rRow;
            input.reloadStepEdge = true;
            input.reloadAutoStep = false;
        }
        input.reloadConfirm = s.uiConfirmWithE;
        input.reloadReset = s.uiBackSpace;

        input.applyPickRoom(s.pick);
        input.frameInteractPressed = input.interact.pressed;

        input.mdx = s.mouseStageX - input.mx;
        input.mdy = s.mouseStageY - input.my;
        input.mx = s.mouseStageX;
        input.my = s.mouseStageY;
        input.inside = s.mouseInsideStage;

        input.uiX = s.mouseStageX;
        input.uiY = s.mouseStageY;
        input.uiDx = input.mdx;
        input.uiDy = input.mdy;
        input.uiInside = s.mouseInsideStage;
        input.uiHeld = s.mouseLeft && s.mouseInsideStage;
        input.uiPressed = s.mouseLeftPressed && s.mouseInsideStage;
        input.uiReleased = s.mouseLeftReleased;
        input.uiRightPressed = s.mouseRightPressed && s.mouseInsideStage;
    }
}

export const TARGET: TargetRuntime = {
    id: "windows",
    supportsKbm: true,
    supportsTouch: false,
    supportsGamepad: false,
    supportsPortrait: false,
    defaultInputMode: "kbm",
    supportedModes: ["kbm"],
    modePrefOrder: ["kbm"],
    controlsGuideTabs: [{ mode: "kbm", label: "键鼠" }],

    getPlatformCaps(): PlatformCaps {
        const cfg = getReleaseConfig();
        return {
            kind: desktopKind(),
            target: "windows",
            isDesktop: true,
            isMobile: false,
            isWeb: false,
            isStandaloneAndroidApk: false,
            canToggleFullscreen: true,
            canQuit: true,
            hasBackButton: false,
            supportsHaptics: false,
            needsAudioUnlock: false,
            isRelease: cfg !== undefined && cfg.isRelease === true,
            defaultInputMode: "kbm",
        };
    },

    canToggleFullscreen(): boolean {
        return true;
    },

    canQuitApp(): boolean {
        return true;
    },

    isReleaseMode(): boolean {
        const cfg = getReleaseConfig();
        return cfg !== undefined && cfg.isRelease === true;
    },

    computeStageViewport(fullW: number, fullH: number): StageViewport {
        return computeWindowsViewport(fullW, fullH);
    },

    triggerHaptics(_seconds: number, _enabled: boolean): void {
        // 桌面端无震动
    },

    keyTagFor(action: KeyActionId, _mode: InputMode, _layout: GamepadLayout): string {
        return keyTagKbm(action);
    },

    adaptWorldKeyTag(rawKeyTag: string, _mode: InputMode, _layout: GamepadLayout): string {
        return rawKeyTag;
    },

    adaptHintSentence(text: string, _mode: InputMode, _layout: GamepadLayout): string {
        return text;
    },

    controlsGuideRows(_tab: InputMode): ControlsGuidePage {
        return WINDOWS_GUIDE;
    },

    splashSkipHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "ESC / SPACE  SKIP";
    },

    titleFooterHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "上下择项   ·   回车或点选启程";
    },

    chapterFooterHint(_mode: InputMode, _confirmTag: string): string {
        return "方向键选择   ·   回车或点击进入";
    },

    pauseFooterHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "Esc 续行   ·   Enter 或点击确认";
    },

    settingsFooterHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "←/→ 或回车/点击切换   ·   Esc 返回暂停";
    },

    controlsFooterRightHint(_mode: InputMode): string {
        return "F11 / Alt+Enter 全屏   ·   暂歇菜单可调声音设置";
    },

    epilogueFooterHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "↑/↓ 选择   ·   Enter / 点击确认   ·   Esc 返回标题";
    },

    settingsRows(): SettingsRowDef[] {
        return WINDOWS_SETTINGS_ROWS;
    },

    settingsPauseLabel(_settings: ControlSettings): string {
        return "声音设置";
    },

    settingsHeaderTitle(): string {
        return "声音设置";
    },

    settingsHeaderSummary(_activeMode: InputMode): string {
        return "当前模式：键鼠 · 四通道音量实时生效";
    },

    settingsValueText(rowId: string, settings: ControlSettings, _activeMode: InputMode): string {
        return volumeSettingText(rowId, settings);
    },

    applySettingsDelta(rowId: string, delta: number, settings: ControlSettings, _input: Input): "none" | "audio" | "back" | "control" {
        if (rowId === "back") return "back";
        if (applyVolumeSetting(rowId, delta, settings)) return "audio";
        return "none";
    },

    createDriver(_settings: ControlSettings): TargetInputDriver {
        return new WindowsInputDriver();
    },
};
