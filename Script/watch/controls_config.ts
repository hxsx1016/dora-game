/**
 * 《向西守望》统一配置持久化（watch-save/controls.txt）。
 *
 * 保持与旧版 controls.txt / touch.txt / gamepad.txt 的完全兼容，
 * 各端只向玩家展示与修改本端支持的设置项，落盘时保留全部字段防跨端覆盖丢失。
 */

import { Content } from "Dora";
import {
    ControlSettings,
    GamepadLayout,
    InputMode,
    InputModePref,
    TOUCH_OPACITY_STEPS,
    TOUCH_SCALE_STEPS,
    VOLUME_STEPS,
} from "Script/watch/target_types";

export {
    ControlSettings,
    GamepadLayout,
    InputMode,
    InputModePref,
    TOUCH_OPACITY_STEPS,
    TOUCH_SCALE_STEPS,
    VOLUME_STEPS,
};

export const MODE_PREF_ORDER: InputModePref[] = ["auto", "kbm", "touch", "gamepad"];

const DEFAULT_CONTROLS_FILE = "watch-save/controls.txt";
const LEGACY_TOUCH_FILE = "watch-save/touch.txt";
const LEGACY_GAMEPAD_FILE = "watch-save/gamepad.txt";

let customControlsFile = "";

export function setControlSettingsFile(path: string): void {
    customControlsFile = path;
}

export function getControlSettingsFile(): string {
    return customControlsFile !== "" ? customControlsFile : DEFAULT_CONTROLS_FILE;
}

function isAbsolutePath(p: string): boolean {
    if (p.length === 0) return false;
    if (p.charAt(0) === "/" || p.charAt(0) === "\\") return true;
    return p.length >= 2 && p.charAt(1) === ":";
}

function resolvePath(rel: string): string {
    if (isAbsolutePath(rel)) {
        return rel;
    }
    const base = Content.writablePath;
    const sep = base.indexOf("\\") >= 0 && base.indexOf("/") < 0 ? "\\" : "/";
    const normRel = sep === "\\" ? rel.split("/").join("\\") : rel;
    const trimmed = (base.endsWith("/") || base.endsWith("\\")) ? base.slice(0, -1) : base;
    return trimmed + sep + normRel;
}

function parentDirOf(p: string): string {
    let i = p.length - 1;
    for (; i >= 0; i--) {
        const ch = p.charAt(i);
        if (ch === "/" || ch === "\\") {
            return p.slice(0, i);
        }
    }
    return "";
}

export function defaultControlSettings(): ControlSettings {
    return {
        modePref: "auto",
        aimAssist: true,
        crouchToggle: false,
        gamepadLayout: "xbox",
        deadzoneLeft: 0.22,
        deadzoneRight: 0.18,
        touchOpacity: 0.78,
        touchScale: 1.0,
        haptics: true,
        masterVol: 1.0,
        bgmVol: 0.8,
        sfxVol: 0.9,
        voiceVol: 1.0,
    };
}

function applyKvLines(raw: string, out: ControlSettings): void {
    const lines = raw.split("\n");
    let i = 0;
    for (i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        const eq = line.indexOf("=");
        if (eq <= 0) continue;
        const k = line.slice(0, eq);
        const v = line.slice(eq + 1);
        if (k === "modePref") {
            if (v === "auto" || v === "kbm" || v === "touch" || v === "gamepad") {
                out.modePref = v;
            }
        } else if (k === "aimAssist") {
            out.aimAssist = v === "1" || v === "true";
        } else if (k === "crouchToggle") {
            out.crouchToggle = v === "1" || v === "true";
        } else if (k === "gamepadLayout" || k === "layout") {
            out.gamepadLayout = v === "nintendo" ? "nintendo" : "xbox";
        } else if (k === "deadzoneLeft") {
            const n = Number(v);
            if (n >= 0.08 && n <= 0.45) out.deadzoneLeft = n;
        } else if (k === "deadzoneRight") {
            const n = Number(v);
            if (n >= 0.08 && n <= 0.45) out.deadzoneRight = n;
        } else if (k === "touchOpacity" || k === "opacity") {
            const n = Number(v);
            if (n >= 0.3 && n <= 1.0) out.touchOpacity = n;
        } else if (k === "touchScale" || k === "scale") {
            const n = Number(v);
            if (n >= 0.75 && n <= 1.35) out.touchScale = n;
        } else if (k === "haptics") {
            out.haptics = v === "1" || v === "true";
        } else if (k === "masterVol") {
            const n = Number(v);
            if (n >= 0 && n <= 1) out.masterVol = n;
        } else if (k === "bgmVol") {
            const n = Number(v);
            if (n >= 0 && n <= 1) out.bgmVol = n;
        } else if (k === "sfxVol") {
            const n = Number(v);
            if (n >= 0 && n <= 1) out.sfxVol = n;
        } else if (k === "voiceVol") {
            const n = Number(v);
            if (n >= 0 && n <= 1) out.voiceVol = n;
        }
    }
}

export function loadControlSettings(): ControlSettings {
    const out = defaultControlSettings();
    try {
        const mainPath = resolvePath(getControlSettingsFile());
        if (Content.exist(mainPath)) {
            const raw = Content.load(mainPath);
            if (raw !== undefined && raw !== "") {
                applyKvLines(raw, out);
            }
            return out;
        }
        if (customControlsFile === "") {
            const legacyTouch = resolvePath(LEGACY_TOUCH_FILE);
            if (Content.exist(legacyTouch)) {
                const raw = Content.load(legacyTouch);
                if (raw !== undefined && raw !== "") {
                    applyKvLines(raw, out);
                }
            }
            const legacyGamepad = resolvePath(LEGACY_GAMEPAD_FILE);
            if (Content.exist(legacyGamepad)) {
                const raw = Content.load(legacyGamepad);
                if (raw !== undefined && raw !== "") {
                    applyKvLines(raw, out);
                }
            }
        }
    } catch {
        // 读取配置失败时回退默认值
    }
    return out;
}

export function saveControlSettings(s: ControlSettings): void {
    try {
        const target = resolvePath(getControlSettingsFile());
        const dir = parentDirOf(target);
        if (dir !== "" && !Content.exist(dir)) {
            Content.mkdir(dir);
        }
        const text =
            "modePref=" + s.modePref + "\n"
            + "aimAssist=" + (s.aimAssist ? "1" : "0") + "\n"
            + "crouchToggle=" + (s.crouchToggle ? "1" : "0") + "\n"
            + "gamepadLayout=" + s.gamepadLayout + "\n"
            + "deadzoneLeft=" + s.deadzoneLeft.toFixed(2) + "\n"
            + "deadzoneRight=" + s.deadzoneRight.toFixed(2) + "\n"
            + "touchOpacity=" + s.touchOpacity.toFixed(2) + "\n"
            + "touchScale=" + s.touchScale.toFixed(2) + "\n"
            + "haptics=" + (s.haptics ? "1" : "0") + "\n"
            + "masterVol=" + s.masterVol.toFixed(2) + "\n"
            + "bgmVol=" + s.bgmVol.toFixed(2) + "\n"
            + "sfxVol=" + s.sfxVol.toFixed(2) + "\n"
            + "voiceVol=" + s.voiceVol.toFixed(2) + "\n";
        Content.save(target, text);
    } catch {
        // 只读环境下静默忽略落盘失败
    }
}

export function nextPrefInList(cur: InputModePref, list: InputModePref[], delta: number = 1): InputModePref {
    if (list.length === 0) return "auto";
    const idx = list.indexOf(cur);
    const base = idx >= 0 ? idx : 0;
    const len = list.length;
    return list[(base + delta + len) % len];
}

export function nextModePref(cur: InputModePref, delta: number = 1): InputModePref {
    return nextPrefInList(cur, MODE_PREF_ORDER, delta);
}

export function nextStepValue(cur: number, steps: number[], delta: number = 1): number {
    let bestIdx = 0;
    let bestDist = 999;
    let i = 0;
    for (i = 0; i < steps.length; i++) {
        const d = Math.abs(steps[i] - cur);
        if (d < bestDist) {
            bestDist = d;
            bestIdx = i;
        }
    }
    const len = steps.length;
    return steps[(bestIdx + delta + len) % len];
}

export function modePrefLabelOf(pref: InputModePref): string {
    if (pref === "kbm") return "键鼠";
    if (pref === "touch") return "触屏";
    if (pref === "gamepad") return "手柄";
    return "自动";
}

export function inputModeLabelOf(mode: InputMode): string {
    if (mode === "touch") return "触屏";
    if (mode === "gamepad") return "手柄";
    return "键鼠";
}

export function layoutLabelOf(layout: GamepadLayout): string {
    return layout === "nintendo" ? "日系 B确认" : "标准 A确认";
}

export function opacityLabelOf(opacity: number): string {
    if (opacity <= 0.62) return "轻";
    if (opacity >= 0.88) return "浓";
    return "中";
}

export function scaleLabelOf(scale: number): string {
    if (scale <= 0.93) return "小";
    if (scale >= 1.07) return "大";
    return "中";
}

export function volumeLabelOf(vol: number): string {
    const pct = Math.round(Math.max(0, Math.min(1, vol)) * 100);
    return pct <= 0 ? "静音" : (pct + "%");
}

export function applyVolumeSetting(
    rowId: string,
    delta: number,
    s: ControlSettings,
): boolean {
    if (rowId === "masterVol") {
        s.masterVol = nextStepValue(s.masterVol, VOLUME_STEPS, delta);
        saveControlSettings(s);
        return true;
    }
    if (rowId === "bgmVol") {
        s.bgmVol = nextStepValue(s.bgmVol, VOLUME_STEPS, delta);
        saveControlSettings(s);
        return true;
    }
    if (rowId === "sfxVol") {
        s.sfxVol = nextStepValue(s.sfxVol, VOLUME_STEPS, delta);
        saveControlSettings(s);
        return true;
    }
    if (rowId === "voiceVol") {
        s.voiceVol = nextStepValue(s.voiceVol, VOLUME_STEPS, delta);
        saveControlSettings(s);
        return true;
    }
    return false;
}

export function volumeSettingText(rowId: string, s: ControlSettings): string {
    if (rowId === "masterVol") return volumeLabelOf(s.masterVol);
    if (rowId === "bgmVol") return volumeLabelOf(s.bgmVol);
    if (rowId === "sfxVol") return volumeLabelOf(s.sfxVol);
    if (rowId === "voiceVol") return volumeLabelOf(s.voiceVol);
    return "";
}
