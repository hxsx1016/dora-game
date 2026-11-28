/**
 * 《向西守望》Windows 桌面目标（纯键鼠 KBM-only）。
 *
 * 严格裁剪：
 * - 零触屏路由、零虚拟触控层（省去 178 个 SDF Label + 4 DrawNode）、零手柄 136 次/帧 FFI 轮询、零磁吸敌兵投影；
 * - 零竖屏掌机台代码、零触屏/手柄提示文案；
 * - 桌面专属体验：IME 自动屏蔽防 Shift 弹输入法、点击事件锁存防漏击、R 长按防误触重开、蹲伏切换模式可选。
 */

import { App, Node, PlatformType, View } from "Dora";
import { KbmPoller } from "Script/watch/input/kbm_core";
import { applyVolumeSetting, saveControlSettings, volumeSettingText } from "Script/watch/controls_config";
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

const RETRY_HOLD_DEADZONE = 0.08;
const RETRY_HOLD_DURATION = 0.65;

const WINDOWS_SETTINGS_ROWS: SettingsRowDef[] = [
    { id: "masterVol", title: "主音量" },
    { id: "bgmVol", title: "音乐音量" },
    { id: "sfxVol", title: "音效与环境" },
    { id: "voiceVol", title: "人声音量" },
    { id: "fullscreen", title: "显示模式" },
    { id: "assistHints", title: "按键辅助" },
    { id: "crouchToggle", title: "蹲伏方式" },
    { id: "back", title: "返回" },
];

const WINDOWS_GUIDE: ControlsGuidePage = {
    subtitle: "键鼠操作说明 · Windows 桌面",
    soldierRows: [
        ["WASD / 方向键", "左右、前后纵深自由移动"],
        ["鼠标 + 左键 / Q·右键", "瞄准发射火铳 · Q/右键开换弹盘"],
        ["按住 SHIFT / SPACE", "贴靠掩体挡弹 · 平地翻滚或翻越"],
        ["E / 1·2·3 / 点提示", "交互推车工台 · 数字键或点击选本领"],
        ["拖线 / 方向+回车", "慢时 3×3 换弹盘 · 右键/退格重画"],
        ["ESC / 长按R / V / T", "暂歇 · 重试检查点 · 札记 · 切神器"],
    ],
    childRows: [
        ["WASD / 方向键", "前后左右纵深潜行"],
        ["按住 SHIFT", "轻步慢走（压低脚步声）"],
        ["C / CTRL", "蹲伏隐蔽 · 穿低拱与桌底（可改切换）"],
        ["SPACE", "跳跃攀上石阶与矮台"],
        ["E / 点世界提示", "拾瓶 / 敲塔门 / 按住+D 拉车"],
        ["F / 左键 按住→松开", "瞄准砖地/铁盆投瓶 · 右键取消"],
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
    if (action === "crouch") return "C / CTRL";
    if (action === "cover") return "SHIFT";
    if (action === "fire") return "左键";
    if (action === "aim") return "F / 左键";
    if (action === "pause") return "ESC";
    if (action === "retry") return "长按 R";
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
    private settings: ControlSettings;
    private crouchLatched = false;
    private retryHoldSec = 0;
    private retryFired = false;

    constructor(settings: ControlSettings) {
        this.settings = settings;
    }

    attach(parent: Node.Type, hooks: TargetAttachHooks): void {
        this.kbm.attach(parent, hooks, {
            latchTouchEvents: true,
            disableIme: true,
        });
    }

    syncFrame(_ctx: TargetFrameSync): void {
        // Windows 纯键鼠无需每帧同步触控热区、手柄上下文或敌兵磁吸投影
    }

    renderOverlay(): void {
        // Windows 无虚拟触控覆盖层
    }

    clearTransient(keepTouchToggles: boolean): void {
        this.kbm.clearTransient();
        this.retryHoldSec = 0;
        this.retryFired = false;
        if (!keepTouchToggles) {
            this.crouchLatched = false;
        }
    }

    vibrate(_seconds: number): void {
        // 桌面端无触觉震动
    }

    shouldShowTouchControls(_input: Input, _vp: StageViewport): boolean {
        return false;
    }

    pollInto(input: Input, dt: number = 1 / 60): void {
        const safeDt = Math.min(0.05, Math.max(0.001, dt));
        input.inputMode = "kbm";
        const s = this.kbm.sample(input.getStageViewport(), safeDt);

        if (s.anyKb || s.mouseMoved || (s.mouseClicked && s.mouseInsideStage)) {
            input.userInteracted = true;
        }

        // 可选切换蹲伏模式：开启后点按 C / Ctrl 切换蹲伏，跳跃自动起身
        let crouchHeld = s.crouch;
        if (this.settings.crouchToggle) {
            if (s.crouchPressed) {
                this.crouchLatched = !this.crouchLatched;
            }
            if (s.jump) {
                this.crouchLatched = false;
            }
            crouchHeld = this.crouchLatched;
        } else {
            this.crouchLatched = false;
        }

        // 防误触：R 键改为长按 0.65s 触发重试检查点/重开护送，单按误碰不再炸档
        let retryTriggered = false;
        if (s.retry) {
            this.retryHoldSec += safeDt;
            if (this.retryHoldSec >= RETRY_HOLD_DURATION && !this.retryFired) {
                this.retryFired = true;
                retryTriggered = true;
            }
        } else {
            this.retryHoldSec = 0;
            this.retryFired = false;
        }

        input.moveX = s.moveX;
        input.moveY = s.moveY;
        input.applyKeyHeld(
            s.jump,
            crouchHeld,
            s.cover,
            s.interact,
            s.aim,
            s.mouseInsideStage && s.mouseLeft,
            s.flare,
            s.pause,
            false,
            s.toggleView,
            s.tab,
        );
        if (s.pausePressed) {
            input.pause.pressed = true;
        }
        if (retryTriggered) {
            input.retry.pressed = true;
        }

        input.resetFrameSignals();
        input.retryTapPressed = s.retryTapPressed;
        input.retryHoldProgress = (!this.retryFired && this.retryHoldSec > RETRY_HOLD_DEADZONE)
            ? Math.min(1, (this.retryHoldSec - RETRY_HOLD_DEADZONE) / (RETRY_HOLD_DURATION - RETRY_HOLD_DEADZONE))
            : 0;
        input.ledgerTogglePressed = s.ledgerTogglePressed;
        input.uiWheelY = s.mouseWheelY;

        if ((input.aim.held || input.fire.held) && s.mouseRightPressed) {
            input.bottleCanceled = true;
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
        if (rawKeyTag === "按住 F") return "按住 F / 左键";
        if (rawKeyTag === "松开 F") return "松开 F / 左键";
        if (rawKeyTag === "按住 Ctrl") return "C / CTRL";
        return rawKeyTag;
    },

    adaptHintSentence(text: string, _mode: InputMode, _layout: GamepadLayout): string {
        return text;
    },

    controlsGuideRows(_tab: InputMode): ControlsGuidePage {
        return WINDOWS_GUIDE;
    },

    splashSkipHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "点击 / ESC / SPACE  跳过";
    },

    titleFooterHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "上下/滚轮择项   ·   回车或左键启程";
    },

    chapterFooterHint(_mode: InputMode, _confirmTag: string): string {
        return "方向键/滚轮选择   ·   回车或左键进入   ·   Esc/右键返回";
    },

    pauseFooterHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "Esc 续行   ·   滚轮/上下择项   ·   Enter 或左键确认";
    },

    settingsFooterHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "←/→ · 滚轮 · 点击 ‹/› 调节   ·   Esc / 右键返回   ·   自动保存";
    },

    controlsFooterRightHint(_mode: InputMode): string {
        return "F11 / Alt+Enter 全屏 · 鼠标右键返回 · 标题与暂歇菜单可调游戏设置";
    },

    epilogueFooterHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "↑/↓ 或滚轮选择   ·   Enter / 左键确认   ·   Esc / 右键返回标题";
    },

    settingsRows(): SettingsRowDef[] {
        return WINDOWS_SETTINGS_ROWS;
    },

    settingsPauseLabel(_settings: ControlSettings): string {
        return "游戏设置";
    },

    settingsHeaderTitle(): string {
        return "游戏设置";
    },

    settingsHeaderSummary(_activeMode: InputMode): string {
        return "键鼠模式 · 音量、显示、按键辅助与蹲伏方式自动保存";
    },

    settingsValueText(rowId: string, settings: ControlSettings, _activeMode: InputMode): string {
        if (rowId === "fullscreen") {
            return App.fullScreen ? "全屏" : "窗口";
        }
        if (rowId === "assistHints") {
            return settings.assistHints ? "开" : "关";
        }
        if (rowId === "crouchToggle") {
            return settings.crouchToggle ? "点按切换" : "按住蹲伏";
        }
        return volumeSettingText(rowId, settings);
    },

    applySettingsDelta(
        rowId: string,
        delta: number,
        settings: ControlSettings,
        _input: Input,
    ): "none" | "audio" | "back" | "control" | "display" | "assist" {
        if (rowId === "back") return "back";
        if (rowId === "fullscreen") return "display";
        if (rowId === "assistHints") {
            settings.assistHints = !settings.assistHints;
            saveControlSettings(settings);
            return "assist";
        }
        if (rowId === "crouchToggle") {
            settings.crouchToggle = !settings.crouchToggle;
            saveControlSettings(settings);
            return "control";
        }
        const step = delta >= 2 ? 1 : (delta <= -2 ? -1 : delta);
        const wrap = Math.abs(delta) >= 2;
        if (applyVolumeSetting(rowId, step, settings, wrap)) return "audio";
        return "none";
    },

    createDriver(settings: ControlSettings): TargetInputDriver {
        return new WindowsInputDriver(settings);
    },
};
