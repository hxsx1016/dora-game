/**
 * 《向西守望》活跃端目标解析器（开发期动态按需加载单端；发行打包期由打包脚本替换为静态单端绑定）。
 *
 * 约定：
 * - 发行包（Windows / Android 手机 / Android 掌机 / Web）在打包阶段会把本文件的 Lua 产物
 *   替换为仅 require 单一目标的静态绑定，并物理剔除其余目标与无关外设驱动模块；
 * - 开发期 / 源码包默认按运行平台映射：Web → web（全包含），Android/iOS → android（纯触屏），
 *   桌面 → windows（纯键鼠）；测试或引导脚本可通过 package.loaded["watch.target"] 指定任意端。
 */

import { App, PlatformType } from "Dora";
import { TargetProfileId, TargetRuntime, getReleaseConfig } from "Script/watch/target_types";

function isValidTargetId(v: unknown): v is TargetProfileId {
    return v === "windows" || v === "android" || v === "handheld" || v === "web";
}

export function resolveTargetId(): TargetProfileId {
    const reg = (globalThis as unknown as { package?: { loaded?: Record<string, unknown> } }).package?.loaded;
    if (reg !== undefined) {
        const forced = reg["watch.target"];
        if (isValidTargetId(forced)) {
            return forced;
        }
    }
    const cfg = getReleaseConfig();
    if (cfg !== undefined && isValidTargetId(cfg.target)) {
        return cfg.target;
    }
    const plat = App.platform;
    if (plat === PlatformType.Web) return "web";
    if (plat === PlatformType.Android || plat === PlatformType.iOS) return "android";
    return "windows";
}

let cachedId: TargetProfileId | undefined;
let cachedTarget: TargetRuntime | undefined;

export function resetActiveTarget(): void {
    cachedId = undefined;
    cachedTarget = undefined;
}

export function getActiveTarget(): TargetRuntime {
    const id = resolveTargetId();
    if (cachedTarget !== undefined && cachedId === id) {
        return cachedTarget;
    }
    const luaRequire = (globalThis as unknown as { require: (this: void, name: string) => unknown }).require;
    const modName = "Script.watch.targets." + id + ".index";
    const mod = luaRequire(modName) as { TARGET: TargetRuntime };
    cachedId = id;
    cachedTarget = mod.TARGET;
    return cachedTarget;
}
