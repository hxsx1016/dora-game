/**
 * 《向西守望》平台能力与视口门面（委托至当前活跃 TargetRuntime，零跨端冗余代码）。
 */

import { getActiveTarget } from "Script/watch/target";
import {
    DefaultInputMode,
    PlatformCaps,
    PlatformKind,
    ReleaseConfig,
    SafeInsets,
    StageViewport,
    TargetProfileId,
    ZERO_SAFE_INSETS,
    getReleaseConfig,
} from "Script/watch/target_types";

export {
    DefaultInputMode,
    PlatformCaps,
    PlatformKind,
    ReleaseConfig,
    SafeInsets,
    StageViewport,
    TargetProfileId,
    ZERO_SAFE_INSETS,
    getReleaseConfig,
};

export function getTargetProfileId(): TargetProfileId {
    return getActiveTarget().id;
}

export function getPlatformCaps(): PlatformCaps {
    return getActiveTarget().getPlatformCaps();
}

export function getPlatformKind(): PlatformKind {
    return getActiveTarget().getPlatformCaps().kind;
}

export function isWebPlatform(): boolean {
    return getActiveTarget().getPlatformCaps().isWeb;
}

export function isMobilePlatform(): boolean {
    return getActiveTarget().getPlatformCaps().isMobile;
}

export function isDesktopNative(): boolean {
    return getActiveTarget().getPlatformCaps().isDesktop;
}

export function isStandaloneAndroidApk(): boolean {
    return getActiveTarget().getPlatformCaps().isStandaloneAndroidApk;
}

export function canToggleFullscreen(): boolean {
    return getActiveTarget().canToggleFullscreen();
}

export function canQuitApp(): boolean {
    return getActiveTarget().canQuitApp();
}

export function isReleaseMode(): boolean {
    return getActiveTarget().isReleaseMode();
}

export function triggerHaptics(seconds: number, enabled: boolean): void {
    getActiveTarget().triggerHaptics(seconds, enabled);
}

export function isCompactAspect(stageW: number, stageH: number): boolean {
    if (stageW <= 0 || stageH <= 0) return false;
    return (stageW / stageH) < 1.62;
}

export function computeStageViewport(fullW: number, fullH: number): StageViewport {
    return getActiveTarget().computeStageViewport(fullW, fullH);
}

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
