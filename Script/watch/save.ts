/**
 * 玩家档案的本地持久化。
 *
 * 档案只记跨局结果（两种通关、神器、博物馆进度），与 RunState 的局内状态分开。
 * 写入走引擎的 writablePath：先写 `.tmp`，成功后再替换目标文件，避免半份档案。
 * 自动测试用 `setSaveFile` 指向隔离文件，绝不碰正式 `watch-save/archive.txt`。
 */
import { Content } from "Dora";
import { MuseumPhase, isMuseumPhase } from "Script/watch/run";

export const SAVE_VERSION = 1;
export const SAVE_DIR = "watch-save";
export const SAVE_FILE = "watch-save/archive.txt";
const BACKUP_FILE = "watch-save/archive.corrupt.txt";

export interface SaveState {
    childCleared: boolean;
    soldierCleared: boolean;
    artifactOwned: boolean;
    museumPhase: MuseumPhase;
    museumSeen: boolean;
}

export type LoadStatus = "ok" | "missing" | "corrupt" | "unsupported";

export interface LoadResult {
    state: SaveState;
    status: LoadStatus;
    detail: string;
}

let currentFile = SAVE_FILE;

/** 引擎的 `exist/load/copy/remove` 只认绝对路径；相对写入会落到 writablePath 但读不回来。 */
function absPath(path: string): string {
    if (path.length > 0 && path.charAt(0) === "/") {
        return path;
    }
    return Content.writablePath + "/" + path;
}

/** 测试用：切到隔离档案文件；传空则回正式档案。 */
export function setSaveFile(path: string): void {
    currentFile = path === "" ? SAVE_FILE : path;
}

export function getSaveFile(): string {
    return currentFile;
}

export function emptySave(): SaveState {
    return {
        childCleared: false,
        soldierCleared: false,
        artifactOwned: false,
        museumPhase: "locked",
        museumSeen: false,
    };
}

function lineValue(text: string, key: string): string | undefined {
    const lines = text.split("\n");
    const prefix = key + "=";
    let i = 0;
    for (i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.length >= prefix.length && line.substring(0, prefix.length) === prefix) {
            return line.substring(prefix.length);
        }
    }
    return undefined;
}

function boolOf(text: string, key: string, fallback: boolean): boolean {
    const value = lineValue(text, key);
    if (value === undefined) {
        return fallback;
    }
    if (value === "true") {
        return true;
    }
    if (value === "false") {
        return false;
    }
    return fallback;
}

/** 只接受十进制整数；任何多余字符都按缺省处理。 */
function intOf(text: string, fallback: number): number {
    if (text.length === 0) {
        return fallback;
    }
    let i = 0;
    let sign = 1;
    if (text.charAt(0) === "-") {
        sign = -1;
        i = 1;
    }
    let n = 0;
    let digits = 0;
    for (; i < text.length; i++) {
        const c = text.charCodeAt(i);
        if (c < 48 || c > 57) {
            return fallback;
        }
        n = n * 10 + (c - 48);
        digits += 1;
    }
    if (digits === 0) {
        return fallback;
    }
    return sign * n;
}

function phaseOf(text: string, key: string, fallback: MuseumPhase): MuseumPhase {
    const value = lineValue(text, key);
    if (value === undefined || !isMuseumPhase(value)) {
        return fallback;
    }
    return value;
}

function numberOf(text: string, key: string, fallback: number): number {
    const value = lineValue(text, key);
    return value === undefined ? fallback : intOf(value, fallback);
}

function formatSave(state: SaveState): string {
    return [
        "version=" + SAVE_VERSION,
        "childCleared=" + (state.childCleared ? "true" : "false"),
        "soldierCleared=" + (state.soldierCleared ? "true" : "false"),
        "artifactOwned=" + (state.artifactOwned ? "true" : "false"),
        "museumPhase=" + state.museumPhase,
        "museumSeen=" + (state.museumSeen ? "true" : "false"),
        "",
    ].join("\n");
}

function backupCorrupt(): void {
    const src = absPath(currentFile);
    if (Content.exist(src)) {
        Content.copy(src, absPath(BACKUP_FILE));
    }
}

/**
 * 读取档案。
 * 缺失 → 空档案（missing）；损坏/版本不支持 → 备份原文件后回空档案并报告（corrupt/unsupported）。
 * 已支持的旧版本按字段缺省补齐，不丢已有通关。
 */
export function loadSave(): LoadResult {
    const file = absPath(currentFile);
    if (!Content.exist(file)) {
        return { state: emptySave(), status: "missing", detail: "无档案，按新档起局" };
    }
    const text = Content.load(file);
    if (text === undefined || text === "") {
        backupCorrupt();
        return { state: emptySave(), status: "corrupt", detail: "档案为空，已备份为 " + BACKUP_FILE };
    }
    const version = numberOf(text, "version", -1);
    if (version < 0) {
        backupCorrupt();
        return { state: emptySave(), status: "corrupt", detail: "档案无版本行，已备份为 " + BACKUP_FILE };
    }
    if (version > SAVE_VERSION) {
        backupCorrupt();
        return {
            state: emptySave(),
            status: "unsupported",
            detail: "档案版本 " + version + " 高于 " + SAVE_VERSION + "，原文件保留，已备份为 " + BACKUP_FILE,
        };
    }
    const state: SaveState = {
        childCleared: boolOf(text, "childCleared", false),
        soldierCleared: boolOf(text, "soldierCleared", false),
        artifactOwned: boolOf(text, "artifactOwned", false),
        museumPhase: phaseOf(text, "museumPhase", "locked"),
        museumSeen: boolOf(text, "museumSeen", false),
    };
    return { state, status: "ok", detail: "版本 " + version };
}

/** 目标文件的目录部分；没有目录就写根。 */
function dirOf(path: string): string {
    let i = path.length - 1;
    for (; i >= 0; i--) {
        if (path.charAt(i) === "/") {
            return path.substring(0, i);
        }
    }
    return "";
}

/** 写入档案：先写临时文件，成功后再替换；失败保留旧文件。 */
export function saveSave(state: SaveState): boolean {
    const target = absPath(currentFile);
    const dir = dirOf(target);
    if (dir !== "" && !Content.isdir(dir)) {
        Content.mkdir(dir);
    }
    const tmp = target + ".tmp";
    const text = formatSave(state);
    Content.save(tmp, text);
    if (!Content.exist(tmp)) {
        return false;
    }
    if (Content.exist(target)) {
        Content.remove(target);
    }
    return Content.copy(tmp, target) && Content.remove(tmp);
}

/** 档案内容签名：用于「正式通关是否变化」的幂等判断。 */
export function saveSignature(state: SaveState): string {
    return [
        state.childCleared ? "1" : "0",
        state.soldierCleared ? "1" : "0",
        state.artifactOwned ? "1" : "0",
        state.museumPhase,
        state.museumSeen ? "1" : "0",
    ].join("|");
}
