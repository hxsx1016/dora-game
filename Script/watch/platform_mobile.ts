/**
 * 《向西守望》移动端 / 掌机 / Web 共享安全区、竖屏掌机视口与震动工具。
 *
 * 注意：Windows 发行包不引入、不打包本模块。
 */

import { App, PlatformType, Rect, View } from "Dora";
import { SafeInsets, StageViewport } from "Script/watch/target_types";

/** 判断舞台是否接近 KTR1/KTR2 等紧凑非 16:9 掌机屏（3:2 或 4:3）。 */
export function isCompactAspect(stageW: number, stageH: number): boolean {
    if (stageW <= 0 || stageH <= 0) return false;
    return (stageW / stageH) < 1.62;
}

/** 触发短促触觉微震动反馈（仅移动设备支持且用户开启震动时生效）。 */
export function triggerMobileHaptics(seconds: number, enabled: boolean): void {
    if (!enabled) {
        return;
    }
    const plat = App.platform;
    if (plat !== PlatformType.Android && plat !== PlatformType.iOS) {
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

/** 仅横屏安全区视口计算（用于安卓掌机等锁定横屏设备，零竖屏分支）。 */
export function computeLandscapeSafeViewport(fullW: number, fullH: number): StageViewport {
    const w = Math.max(320, fullW > 0 ? fullW : View.size.width);
    const h = Math.max(180, fullH > 0 ? fullH : View.size.height);
    const safe = readSafeInsets(w, h);
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

/** 支持横竖屏自适应的视口计算（用于安卓手机/平板与 Web）。 */
export function computeAdaptiveViewport(fullW: number, fullH: number): StageViewport {
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
