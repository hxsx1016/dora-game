/**
 * 《向西守望》平台能力、安全区与多比例视口抽象层（Axis 1 · 纯平台层，零输入键位逻辑）。
 *
 * 职责：
 * 1. 识别运行平台与载体（Windows/macOS/Linux 桌面原生、Web、Android 独立 APK / Dora Go、iOS），
 *    导出统一的 PlatformCaps 能力矩阵（全屏、退出、系统返回键、触觉震动、Web 音频解锁、发行模式）；
 * 2. 统一换算 App.safeArea（刘海/圆角/手势条），消灭各分支重复的 safeArea 逻辑；
 * 3. 统一计算多比例舞台视口：
 *    - 横屏（16:9 / 超宽屏 / KTR 3:2 / 4:3）：主舞台铺满全屏，safeUi 自动按 uiScale 内缩；
 *    - 竖屏（fullH > fullW * 1.05，含手机竖屏 Web 与允许旋转的 Android 独立 APK）：
 *      上半屏 16:9 完整无裁切舞台 + 下半屏宋明水墨掌机触控台，提供 viewToStage 零误差坐标变换。
 */

import { App, PlatformType, Rect, View } from "Dora";

export type PlatformKind = "windows" | "macos" | "linux" | "android" | "ios" | "web" | "unknown";
export type DefaultInputMode = "kbm" | "touch" | "gamepad";

export interface SafeInsets {
    left: number;
    right: number;
    top: number;
    bottom: number;
}

export const ZERO_SAFE_INSETS: SafeInsets = { left: 0, right: 0, top: 0, bottom: 0 };

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
    /** 换算至主舞台内 UI 逻辑空间的安全区内缩（竖屏上下已由 topBarH/deckH 缓冲，避免双重缩进） */
    safeUi: SafeInsets;
}

export interface ReleaseConfig {
    isRelease?: boolean;
    version?: string;
    portableSave?: boolean;
    platform?: string;
}

export interface PlatformCaps {
    kind: PlatformKind;
    isDesktop: boolean;
    isMobile: boolean;
    isWeb: boolean;
    /** 是否为独立打包发行的 Android APK（由 tools/android-boot.lua 注入 platform="Android"） */
    isStandaloneAndroidApk: boolean;
    /** 是否支持窗口/全屏切换（桌面原生 + Web 支持，移动原生隐藏） */
    canToggleFullscreen: boolean;
    /** 是否在标题/暂停菜单显示并允许「退出游戏」（桌面原生 + Android 独立 APK；Web 与 Dora Go 源码模式隐藏） */
    canQuit: boolean;
    /** 是否具有 Android 系统返回键 */
    hasBackButton: boolean;
    /** 当前环境是否具备触觉微震动能力 */
    supportsHaptics: boolean;
    /** 是否需要浏览器首手势解锁 AudioContext */
    needsAudioUnlock: boolean;
    /** 是否处于发行模式（屏蔽调试跳关与灰盒热键） */
    isRelease: boolean;
    /** 平台首次启动时的默认活跃输入模式（后续可在所有平台随时切换为任意模式） */
    defaultInputMode: DefaultInputMode;
}

export function getPlatformKind(): PlatformKind {
    const plat = App.platform;
    if (plat === PlatformType.Windows) return "windows";
    if (plat === PlatformType.macOS) return "macos";
    if (plat === PlatformType.Linux) return "linux";
    if (plat === PlatformType.Android) return "android";
    if (plat === PlatformType.iOS) return "ios";
    if (plat === PlatformType.Web) return "web";
    return "unknown";
}

export function isWebPlatform(): boolean {
    return App.platform === PlatformType.Web;
}

export function isMobilePlatform(): boolean {
    const plat = App.platform;
    return plat === PlatformType.Android || plat === PlatformType.iOS;
}

export function isDesktopNative(): boolean {
    const plat = App.platform;
    return plat === PlatformType.Windows || plat === PlatformType.macOS || plat === PlatformType.Linux;
}

export function getReleaseConfig(): ReleaseConfig | undefined {
    const reg = (globalThis as unknown as { package?: { loaded?: Record<string, unknown> } }).package?.loaded;
    const cfg = reg !== undefined ? reg["watch.release"] : undefined;
    if (cfg !== undefined && typeof cfg === "object") {
        return cfg as ReleaseConfig;
    }
    return undefined;
}

export function isStandaloneAndroidApk(): boolean {
    const cfg = getReleaseConfig();
    return App.platform === PlatformType.Android && cfg !== undefined && cfg.platform === "Android";
}

/** Web 与桌面原生支持全屏切换；移动原生端始终全屏，隐藏此项。 */
export function canToggleFullscreen(): boolean {
    return isDesktopNative() || isWebPlatform();
}

/**
 * 退出游戏能力判定：
 * - 桌面原生与独立发行 Android APK 支持并显示「退出游戏」；
 * - Web 浏览器与 Android Dora Go 源码模式隐藏该项并禁止调用 App.shutdown()，避免停死宿主。
 */
export function canQuitApp(): boolean {
    return isDesktopNative() || isStandaloneAndroidApk();
}

/**
 * 发行模式判定：
 * - 显式注入 watch.release.isRelease 时以其为准；
 * - Web 平台默认启用发行保护（屏蔽 G / Tab / 1-8 调试跳房），除非显式注入 isRelease: false。
 */
export function isReleaseMode(): boolean {
    const cfg = getReleaseConfig();
    if (cfg !== undefined && cfg.isRelease !== undefined) {
        return cfg.isRelease === true;
    }
    return isWebPlatform();
}

export function getPlatformCaps(): PlatformCaps {
    const kind = getPlatformKind();
    const isDesktop = isDesktopNative();
    const isMobile = isMobilePlatform();
    const isWeb = isWebPlatform();
    const standaloneApk = isStandaloneAndroidApk();
    return {
        kind,
        isDesktop,
        isMobile,
        isWeb,
        isStandaloneAndroidApk: standaloneApk,
        canToggleFullscreen: isDesktop || isWeb,
        canQuit: isDesktop || standaloneApk,
        hasBackButton: kind === "android",
        supportsHaptics: isMobile && typeof App.vibrate === "function",
        needsAudioUnlock: isWeb,
        isRelease: isReleaseMode(),
        defaultInputMode: isMobile ? "touch" : "kbm",
    };
}

/** 触发短促触觉反馈（仅移动设备支持且用户开启震动时生效）。 */
export function triggerHaptics(seconds: number, enabled: boolean): void {
    if (!enabled || !isMobilePlatform()) {
        return;
    }
    if (typeof App.vibrate === "function") {
        try {
            App.vibrate(seconds);
        } catch {
            // 忽略不支持震动的模拟器或设备
        }
    }
}

/** 判断舞台是否接近 KTR1/KTR2 等紧凑非 16:9 掌机屏（3:2 或 4:3） */
export function isCompactAspect(stageW: number, stageH: number): boolean {
    if (stageW <= 0 || stageH <= 0) return false;
    return (stageW / stageH) < 1.62;
}

/** 读取安全区内缩（容错无 safeArea 的旧引擎/测试环境，换算为 View 逻辑像素）。 */
export function readSafeInsets(fullW: number, fullH: number): SafeInsets {
    if (fullW <= 0 || fullH <= 0) {
        return { left: 0, right: 0, top: 0, bottom: 0 };
    }
    const appObj = App as unknown as { safeArea?: Rect.Type; visualSize?: { width: number; height: number } };
    const safe = appObj.safeArea;
    const vis = appObj.visualSize;
    if (safe === undefined || vis === undefined || vis.width <= 0 || vis.height <= 0) {
        return { left: 0, right: 0, top: 0, bottom: 0 };
    }
    if (safe.width <= 0 || safe.height <= 0) {
        return { left: 0, right: 0, top: 0, bottom: 0 };
    }
    const sx = fullW / vis.width;
    const sy = fullH / vis.height;
    const left = Math.max(0, Math.min(fullW * 0.12, safe.x * sx));
    const right = Math.max(0, Math.min(fullW * 0.12, (vis.width - (safe.x + safe.width)) * sx));
    const bottom = Math.max(0, Math.min(fullH * 0.12, safe.y * sy));
    const top = Math.max(0, Math.min(fullH * 0.12, (vis.height - (safe.y + safe.height)) * sy));
    return {
        left: Math.round(left),
        right: Math.round(right),
        top: Math.round(top),
        bottom: Math.round(bottom),
    };
}

/** 将 App.safeArea 换算为给定 UI 缩放下的逻辑像素内缩量（供全屏或独立面板使用）。 */
export function computeSafeInsets(viewW: number, viewH: number, uiScale: number): SafeInsets {
    const safeScale = Math.max(0.25, uiScale);
    const px = readSafeInsets(viewW, viewH);
    return {
        left: Math.min(140, px.left / safeScale),
        right: Math.min(140, px.right / safeScale),
        top: Math.min(90, px.top / safeScale),
        bottom: Math.min(90, px.bottom / safeScale),
    };
}

/**
 * 根据当前 View 尺寸计算主舞台与竖屏掌机区几何：
 * - 横屏（fullH <= fullW * 1.05）：舞台铺满全屏（0, 0, fullW, fullH）；
 * - 竖屏（fullH > fullW * 1.05）：上方完整 16:9 游戏画面，下方留作水墨掌机式虚拟操控台。
 */
export function computeStageViewport(fullW: number, fullH: number): StageViewport {
    const w = Math.max(320, fullW > 0 ? fullW : View.size.width);
    const h = Math.max(180, fullH > 0 ? fullH : View.size.height);
    const safe = readSafeInsets(w, h);
    const isPortrait = h > w * 1.05;

    if (!isPortrait) {
        const uiScale = Math.max(0.25, Math.min(w / 1280, h / 720));
        const safeUi: SafeInsets = {
            left: Math.min(140, safe.left / uiScale),
            right: Math.min(140, safe.right / uiScale),
            top: Math.min(90, safe.top / uiScale),
            bottom: Math.min(90, safe.bottom / uiScale),
        };
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
            safe,
            safeUi,
        };
    }

    const topBarH = Math.max(safe.top + 38, Math.min(68, Math.round(h * 0.055)));
    const minDeckH = Math.max(168, Math.round(h * 0.34));
    const maxStageH = Math.max(160, h - topBarH - minDeckH);
    const ideal16x9H = Math.round(w * 9 / 16);
    const stageH = Math.min(ideal16x9H, maxStageH);
    const stageW = stageH < ideal16x9H ? Math.min(w, Math.round(stageH * 16 / 9)) : w;
    const stageX = Math.round((w - stageW) * 0.5);
    const stageY = Math.max(minDeckH, h - topBarH - stageH);
    const uiScale = Math.max(0.25, Math.min(stageW / 1280, stageH / 720));
    const rightMargin = w - (stageX + stageW);
    const safeUi: SafeInsets = {
        left: Math.min(140, Math.max(0, safe.left - stageX) / uiScale),
        right: Math.min(140, Math.max(0, safe.right - rightMargin) / uiScale),
        top: 0,
        bottom: 0,
    };

    return {
        fullW: w,
        fullH: h,
        stageX,
        stageY,
        stageW,
        stageH,
        deckH: stageY,
        topBarH,
        isPortrait: true,
        uiScale,
        uiW: stageW / uiScale,
        uiH: stageH / uiScale,
        safe,
        safeUi,
    };
}

/** 将全屏 View 坐标（左下原点）换算为主舞台局部坐标。 */
export function viewToStage(
    viewX: number,
    viewY: number,
    vp: StageViewport,
): { x: number; y: number; inside: boolean } {
    const x = viewX - vp.stageX;
    const y = viewY - vp.stageY;
    return {
        x,
        y,
        inside: x >= 0 && x <= vp.stageW && y >= 0 && y <= vp.stageH,
    };
}
