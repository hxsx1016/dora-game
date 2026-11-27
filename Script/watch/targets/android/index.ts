/**
 * 《向西守望》Android 手机/平板目标（纯触屏 Touch-only）。
 *
 * 严格裁剪：
 * - 零键盘/鼠标轮询、零 onKeyDown、零手柄 136 次/帧 FFI 轮询、零 gamecontrollerdb.txt；
 * - 保留横屏浮钮 + 竖屏 16:9 上舞台/下半宋明水墨掌机台（fullUser）与安全区避让；
 * - TouchControls 使用轻量化 36-Label TextPool（较旧版 178 个削减 80%）；
 * - 设置页仅暴露触控 + 音量项；执器要诀仅显示触屏单页。
 */

import { App, Node } from "Dora";
import { TouchRouter } from "Script/watch/input/touch_core";
import { TouchControls } from "Script/watch/input/touch_hud_landscape";
import { PORTRAIT_TOUCH_DELEGATE } from "Script/watch/input/touch_hud_portrait";
import { computeAdaptiveViewport, triggerMobileHaptics } from "Script/watch/platform_mobile";
import {
    TOUCH_OPACITY_STEPS,
    TOUCH_SCALE_STEPS,
    applyVolumeSetting,
    nextStepValue,
    opacityLabelOf,
    saveControlSettings,
    scaleLabelOf,
    volumeSettingText,
} from "Script/watch/controls_config";
import type { Input } from "Script/watch/input";
import {
    ControlSettings,
    ControlsGuidePage,
    GamepadLayout,
    InputMode,
    KeyActionId,
    PlatformCaps,
    SettingsRowDef,
    StageViewport,
    TargetAttachHooks,
    TargetFrameSync,
    TargetInputDriver,
    TargetRuntime,
    getReleaseConfig,
} from "Script/watch/target_types";

const ANDROID_SETTINGS_ROWS: SettingsRowDef[] = [
    { id: "aimAssist", title: "瞄准磁吸" },
    { id: "touchOpacity", title: "触控按键透度" },
    { id: "touchScale", title: "触控按键大小" },
    { id: "haptics", title: "触觉震动反馈" },
    { id: "masterVol", title: "主音量" },
    { id: "bgmVol", title: "音乐音量" },
    { id: "sfxVol", title: "音效与环境" },
    { id: "voiceVol", title: "人声音量" },
    { id: "back", title: "返回暂歇菜单" },
];

const ANDROID_GUIDE: ControlsGuidePage = {
    subtitle: "触屏操作说明 · 横屏全屏 / 竖屏掌机台",
    soldierRows: [
        ["左水墨摇杆", "全向走位与里外道切线"],
        ["点屏 / 开火钮", "直点射击或拖住开火钮 360° 精瞄"],
        ["掩体开关", "轻点贴靠掩体，再点或翻滚离掩"],
        ["翻滚 / 翻越", "平地翻滚，贴近矮柜自动翻越"],
        ["交互 / 推车", "点推车自动锁握柄，长按牵手交物"],
        ["换弹九宫格", "单指一笔滑连至右上，点重画清空"],
    ],
    childRows: [
        ["摇杆内圈 / 轻步", "轻推内圈或点轻步压低脚步声"],
        ["蹲伏开关", "点按蹲下钻桌穿拱，点跳顺滑起身"],
        ["跳跃钮", "攀上石阶、红布车与矮台"],
        ["投瓶拖瞄", "按住投瓶拖向砖地，拖回取消圈放弃"],
        ["交互 / 拉车", "拾瓶、敲塔门、点拉车锁定握柄"],
        ["右上暂歇 / 竖屏", "顶栏随时暂歇，竖屏自动展掌机台"],
    ],
};

function isStandaloneApk(): boolean {
    const cfg = getReleaseConfig();
    return cfg !== undefined && cfg.platform === "Android";
}

function keyTagTouch(action: KeyActionId): string {
    if (action === "interact") return "点按";
    if (action === "jump") return "跳/滚";
    if (action === "crouch") return "蹲伏";
    if (action === "cover") return "掩体";
    if (action === "fire") return "开火";
    if (action === "aim") return "拖投瓶";
    if (action === "pause") return "暂歇";
    if (action === "retry") return "重试";
    if (action === "confirm") return "点选";
    if (action === "back") return "返回";
    return "穿梭";
}

function adaptWorldKeyTagTouch(rawKeyTag: string): string {
    if (rawKeyTag === "E") return "轻触";
    if (rawKeyTag === "按住 E") return "长按交互";
    if (rawKeyTag === "松开再按住 E") return "松开再长按";
    if (rawKeyTag === "按住 E + D" || rawKeyTag === "E 握柄 + D") return "点推车+摇杆";
    if (rawKeyTag === "F" || rawKeyTag === "左键") return "开火";
    if (rawKeyTag === "按住 F") return "拖投瓶";
    if (rawKeyTag === "松开 F") return "松手投";
    if (rawKeyTag === "按住 Ctrl") return "点蹲伏";
    if (rawKeyTag === "按住 Shift") return "点掩体";
    if (rawKeyTag === "连线") return "一笔划连";
    return rawKeyTag;
}

function adaptHintSentenceTouch(text: string): string {
    if (text === "") return text;
    return text
        .split("按住 [E]+[D]").join("点按推/拉车并推摇杆")
        .split("[E]+[D]").join("推/拉车并推摇杆")
        .split("速按 [CTRL]").join("点按「蹲伏」")
        .split("按住 [CTRL]").join("点按「蹲伏」")
        .split("按 [CTRL]").join("点按「蹲伏」")
        .split("[CTRL]").join("「蹲伏」")
        .split("按住 [SHIFT]").join("点按「轻步/掩体」")
        .split("[SHIFT]").join("「轻步/掩体」")
        .split("按住 [F]").join("按住「投瓶」拖拽")
        .split("[F]").join("「投瓶」")
        .split("按住 E").join("长按「交互」")
        .split("按 [E]").join("点按「交互」")
        .split("[E]").join("「交互」")
        .split("方向键").join("左下摇杆")
        .split("按 [ESC]").join("轻触右上「暂歇」")
        .split("[ESC]").join("右上「暂歇」")
        .split("按 [SPACE]").join("点按「翻滚/跳跃」")
        .split("[SPACE]").join("「翻滚/跳跃」")
        .split("按 [R]").join("在暂歇菜单重试")
        .split("[A/D]").join("左下摇杆")
        .split("[W/S]").join("摇杆上下")
        .split("[W]").join("摇杆向上")
        .split("[S]").join("摇杆向下")
        .split("鼠标瞄准，左键发射火铳").join("点屏或拖「开火」发射火铳")
        .split("左键先手击倒").join("点屏或「开火」先手击倒")
        .split("左键发射火铳").join("点屏或「开火」发射火铳")
        .split("左键发铳").join("点屏或「开火」发铳")
        .split("左键").join("点屏或「开火」")
        .split("鼠标").join("触屏")
        .split("按 E 再次启程").join("轻触屏幕再次启程")
        .split("Esc 暂歇").join("轻触右上暂歇");
}

class AndroidTouchDriver implements TargetInputDriver {
    readonly defaultMode: InputMode = "touch";
    private router: TouchRouter;
    private controls: TouchControls | undefined;

    constructor(settings: ControlSettings) {
        this.router = new TouchRouter(settings, {
            enableMouseCompat: false,
            enablePortrait: true,
        });
    }

    attach(parent: Node.Type, _hooks: TargetAttachHooks): void {
        this.router.attach(parent);
        if (this.controls === undefined) {
            this.controls = new TouchControls(parent, PORTRAIT_TOUCH_DELEGATE);
        }
    }

    syncFrame(ctx: TargetFrameSync): void {
        if (this.controls === undefined) return;
        this.controls.syncContext({
            viewport: ctx.viewport,
            mode: ctx.mode,
            screen: ctx.screen,
            play: ctx.play,
            run: ctx.run,
            cam: ctx.cam,
            router: this.router,
            overlayActive: true,
            allowAutoGameplayTouch: true,
            allowMouseOnOverlay: false,
            showWebTopPills: false,
            canToggleFullscreen: false,
            assistHintsEnabled: ctx.assistHintsEnabled,
            isMuted: ctx.isMuted,
            isFullscreen: false,
            storyTalentBoxes: ctx.storyTalentBoxes,
            dt: ctx.dt,
        });
    }

    renderOverlay(): void {
        this.controls?.render(this.router);
    }

    clearTransient(keepTouchToggles: boolean): void {
        this.router.releaseAll(keepTouchToggles);
    }

    vibrate(seconds: number): void {
        this.router.vibrate(seconds);
    }

    shouldShowTouchControls(_input: Input, _vp: StageViewport): boolean {
        return true;
    }

    getTouchRouter(): TouchRouter {
        return this.router;
    }

    getTouchControls(): TouchControls | undefined {
        return this.controls;
    }

    injectTouch(phase: "began" | "moved" | "ended", id: number, x: number, y: number, fromMouse?: boolean): void {
        this.router.injectTouch(phase, id, x, y, fromMouse === true);
    }

    pollInto(input: Input): void {
        input.inputMode = "touch";
        const touch = this.router.consumeSnapshot();
        if (touch.hadRealTouch) {
            input.userInteracted = true;
        }

        input.moveX = touch.moveX;
        input.moveY = touch.moveY;
        input.applyKeyHeld(
            touch.jumpHeld,
            touch.crouchHeld,
            touch.coverHeld,
            touch.interactHeld,
            touch.aimHeld,
            touch.fireHeld,
            false,
            false,
            false,
            false,
            false,
        );

        input.resetFrameSignals();
        if (touch.jumpPressed) input.jump.pressed = true;
        if (touch.interactPressed) input.interact.pressed = true;
        if (touch.firePressed) input.fire.pressed = true;
        if (touch.pausePressed) input.pause.pressed = true;
        if (touch.retryPressed) input.retry.pressed = true;
        if (touch.artifactPressed) input.artifactTogglePressed = true;
        if (touch.mutePressed) input.muteTogglePressed = true;
        if (touch.anyTapBegan) input.splashSkipPressed = true;
        if (touch.zoneTap !== "") input.touchZoneTap = touch.zoneTap;
        input.navUp = touch.navUp;
        input.navDown = touch.navDown;
        input.navLeft = touch.navLeft;
        input.navRight = touch.navRight;
        input.navConfirm = touch.navConfirm;
        input.navBack = touch.navBack;
        input.craftConfirm = touch.navConfirm;
        input.craftCancel = touch.navBack;
        if (touch.bottleCanceled) {
            input.bottleCanceled = true;
            input.aim.held = false;
            input.aim.pressed = false;
            input.aim.released = false;
        }

        input.frameInteractPressed = input.interact.pressed;

        if (touch.uiHeld || touch.uiPressed || touch.uiReleased || touch.uiInside) {
            input.uiX = touch.uiX;
            input.uiY = touch.uiY;
            input.uiDx = touch.uiDx;
            input.uiDy = touch.uiDy;
            input.uiInside = touch.uiInside;
            input.uiHeld = touch.uiHeld;
            input.uiPressed = touch.uiPressed;
            input.uiReleased = touch.uiReleased;
            input.uiRightPressed = false;
            if (touch.uiHeld || touch.uiPressed) {
                input.mdx = touch.uiDx;
                input.mdy = touch.uiDy;
                input.mx = touch.uiX;
                input.my = touch.uiY;
                input.inside = true;
            } else if (touch.hasAim) {
                input.mdx = touch.aimX - input.mx;
                input.mdy = touch.aimY - input.my;
                input.mx = touch.aimX;
                input.my = touch.aimY;
                input.inside = true;
            } else {
                input.mdx = 0;
                input.mdy = 0;
                input.inside = touch.uiInside;
            }
            return;
        }

        if (touch.hasAim) {
            input.mdx = touch.aimX - input.mx;
            input.mdy = touch.aimY - input.my;
            input.mx = touch.aimX;
            input.my = touch.aimY;
            input.inside = true;
        } else {
            input.mdx = 0;
            input.mdy = 0;
            input.inside = false;
        }
        input.uiDx = 0;
        input.uiDy = 0;
        input.uiInside = false;
        input.uiHeld = false;
        input.uiPressed = false;
        input.uiReleased = false;
        input.uiRightPressed = false;
    }
}

export const TARGET: TargetRuntime = {
    id: "android",
    supportsKbm: false,
    supportsTouch: true,
    supportsGamepad: false,
    supportsPortrait: true,
    defaultInputMode: "touch",
    supportedModes: ["touch"],
    modePrefOrder: ["touch"],
    controlsGuideTabs: [{ mode: "touch", label: "触屏" }],

    getPlatformCaps(): PlatformCaps {
        const standaloneApk = isStandaloneApk();
        const cfg = getReleaseConfig();
        return {
            kind: "android",
            target: "android",
            isDesktop: false,
            isMobile: true,
            isWeb: false,
            isStandaloneAndroidApk: standaloneApk,
            canToggleFullscreen: false,
            canQuit: standaloneApk,
            hasBackButton: true,
            supportsHaptics: typeof App.vibrate === "function",
            needsAudioUnlock: false,
            isRelease: cfg !== undefined && cfg.isRelease === true,
            defaultInputMode: "touch",
        };
    },

    canToggleFullscreen(): boolean {
        return false;
    },

    canQuitApp(): boolean {
        return isStandaloneApk();
    },

    isReleaseMode(): boolean {
        const cfg = getReleaseConfig();
        return cfg !== undefined && cfg.isRelease === true;
    },

    computeStageViewport(fullW: number, fullH: number): StageViewport {
        return computeAdaptiveViewport(fullW, fullH);
    },

    triggerHaptics(seconds: number, enabled: boolean): void {
        triggerMobileHaptics(seconds, enabled);
    },

    keyTagFor(action: KeyActionId, _mode: InputMode, _layout: GamepadLayout): string {
        return keyTagTouch(action);
    },

    adaptWorldKeyTag(rawKeyTag: string, _mode: InputMode, _layout: GamepadLayout): string {
        return adaptWorldKeyTagTouch(rawKeyTag);
    },

    adaptHintSentence(text: string, _mode: InputMode, _layout: GamepadLayout): string {
        return adaptHintSentenceTouch(text);
    },

    controlsGuideRows(_tab: InputMode): ControlsGuidePage {
        return ANDROID_GUIDE;
    },

    splashSkipHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "轻触跳过";
    },

    titleFooterHint(_mode: InputMode, _layout: GamepadLayout): string {
        return isStandaloneApk()
            ? "轻触择项启程   ·   双击返回键退出"
            : "轻触择项启程";
    },

    chapterFooterHint(_mode: InputMode, _confirmTag: string): string {
        return "轻触驿站预览   ·   再点或轻触入此卷章";
    },

    pauseFooterHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "轻触确认   ·   点「继续游戏」续行";
    },

    settingsFooterHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "轻触任意条目切换   ·   设置自动保存";
    },

    controlsFooterRightHint(_mode: InputMode): string {
        return "暂歇菜单可调触控与声音";
    },

    epilogueFooterHint(_mode: InputMode, _layout: GamepadLayout): string {
        return "轻触任一入口继续";
    },

    trialSubHint(_mode: InputMode, ended: boolean, seed: number): string {
        return "种子 " + seed + (ended ? " · 点下方按钮再开或返回标题" : " · 点下方按钮继续/重开/返回标题");
    },

    settingsRows(): SettingsRowDef[] {
        return ANDROID_SETTINGS_ROWS;
    },

    settingsPauseLabel(_settings: ControlSettings): string {
        return "触控与声音";
    },

    settingsHeaderTitle(): string {
        return "触控与声音";
    },

    settingsHeaderSummary(_activeMode: InputMode): string {
        return "当前模式：触屏 · 操控与四通道音量实时生效";
    },

    settingsValueText(rowId: string, settings: ControlSettings, _activeMode: InputMode): string {
        if (rowId === "aimAssist") return settings.aimAssist ? "开" : "关";
        if (rowId === "touchOpacity") return opacityLabelOf(settings.touchOpacity);
        if (rowId === "touchScale") return scaleLabelOf(settings.touchScale);
        if (rowId === "haptics") return settings.haptics ? "开" : "关";
        return volumeSettingText(rowId, settings);
    },

    applySettingsDelta(rowId: string, delta: number, settings: ControlSettings, input: Input): "none" | "audio" | "back" | "control" {
        if (rowId === "back") return "back";
        if (rowId === "aimAssist") {
            settings.aimAssist = !settings.aimAssist;
            saveControlSettings(settings);
            return "control";
        }
        if (rowId === "touchOpacity") {
            settings.touchOpacity = nextStepValue(settings.touchOpacity, TOUCH_OPACITY_STEPS, delta);
            saveControlSettings(settings);
            return "control";
        }
        if (rowId === "touchScale") {
            settings.touchScale = nextStepValue(settings.touchScale, TOUCH_SCALE_STEPS, delta);
            saveControlSettings(settings);
            return "control";
        }
        if (rowId === "haptics") {
            settings.haptics = !settings.haptics;
            saveControlSettings(settings);
            if (settings.haptics) {
                input.vibrate(0.018);
            }
            return "control";
        }
        if (applyVolumeSetting(rowId, delta, settings)) return "audio";
        return "none";
    },

    createDriver(settings: ControlSettings): TargetInputDriver {
        return new AndroidTouchDriver(settings);
    },
};
