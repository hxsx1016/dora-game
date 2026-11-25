/**
 * 玩家档案的本地持久化。
 *
 * 档案只记跨局结果（两种通关、神器、博物馆进度），与 RunState 的局内状态分开。
 * 替换策略：先写 `.tmp` → 备份旧档到 `.prev` → 覆盖目标 → 回读校验；任一步失败都从
 * `.prev` 回滚，绝不先删唯一有效旧档。启动时优先用完整 `.tmp` 或 `.prev` 自愈。
 * 自动测试用 `setSaveFile` 指向隔离文件，损坏备份也按该路径派生，绝不碰玩家档案。
 */
import { Content } from "Dora";
import { MuseumPhase, isMuseumPhase } from "Script/watch/run";

export const SAVE_VERSION = 1;
export const SAVE_DIR = "watch-save";
export const SAVE_FILE = "watch-save/archive.txt";

export interface SaveState {
    childCleared: boolean;
    soldierCleared: boolean;
    artifactOwned: boolean;
    museumPhase: MuseumPhase;
    museumSeen: boolean;
}

export type LoadStatus = "ok" | "missing" | "corrupt" | "unsupported";
/** 恢复建议：keep=按档案继续；reset=旧档已隔离、可开新档；none=无档可管。 */
export type RecoveryAction = "keep" | "reset" | "none";

export interface LoadResult {
    state: SaveState;
    status: LoadStatus;
    detail: string;
    /** 本次读取是否动过磁盘（自愈/备份/隔离）。 */
    recovered: boolean;
    /** 损坏/未知版本原件的备份路径；没有则为空串。 */
    backup: string;
    action: RecoveryAction;
}

/** 故障注入：只给隔离测试用，正式入口永远是空串。 */
export type SaveFault = "" | "write" | "verify" | "replace";
let fault: SaveFault = "";

export function setSaveFault(value: SaveFault): void {
    fault = value;
}

let currentFile = SAVE_FILE;
/** 跨 Play 实例的待落盘档案：归 app 同寿命的模块所有，切房换实例不会丢。 */
let pendingState: SaveState | undefined = undefined;
/** 读到未知版本原件后置位：普通写档一律拒绝，避免悄悄覆盖。 */
let protectedFile = false;

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
    protectedFile = false;
}

/** 登记一份待落盘档案（同拍切房、写失败都由调用方重新登记）。 */
export function markProfilePending(state: SaveState): void {
    pendingState = state;
}

export function profilePending(): boolean {
    return pendingState !== undefined;
}

/** 把登记的档案落盘；成功才清登记，失败保留等下一帧重试。 */
export function flushProfile(): boolean {
    if (pendingState === undefined) {
        return true;
    }
    if (!saveSave(pendingState)) {
        return false;
    }
    pendingState = undefined;
    return true;
}

export function clearProfilePending(): void {
    pendingState = undefined;
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

interface Parsed {
    ok: boolean;
    status: LoadStatus;
    reason: string;
    state: SaveState;
}

/**
 * 严格解析：版本行必须存在；高于 SAVE_VERSION → unsupported；
 * 同版本六个字段缺一或取值非法 → corrupt（旧版本没有可选字段，缺省才补）。
 */
function parseSave(text: string): Parsed {
    const bad: Parsed = { ok: false, status: "corrupt", reason: "", state: emptySave() };
    if (text.length === 0) {
        bad.reason = "档案为空";
        return bad;
    }
    const versionText = lineValue(text, "version");
    if (versionText === undefined) {
        bad.reason = "缺少 version 行";
        return bad;
    }
    const version = intOf(versionText, -1);
    if (version < 0) {
        bad.reason = "version 不是十进制整数";
        return bad;
    }
    if (version > SAVE_VERSION) {
        return { ok: false, status: "unsupported", reason: "版本 " + version + " 高于 " + SAVE_VERSION, state: emptySave() };
    }
    if (version !== SAVE_VERSION) {
        bad.reason = "不支持的旧版本 " + version;
        return bad;
    }
    const boolKeys = ["childCleared", "soldierCleared", "artifactOwned", "museumSeen"];
    const bools: boolean[] = [];
    let i = 0;
    for (i = 0; i < boolKeys.length; i++) {
        const value = lineValue(text, boolKeys[i]);
        if (value === undefined) {
            bad.reason = "缺少字段 " + boolKeys[i];
            return bad;
        }
        if (value !== "true" && value !== "false") {
            bad.reason = "字段 " + boolKeys[i] + " 不是布尔值";
            return bad;
        }
        bools.push(value === "true");
    }
    const phase = lineValue(text, "museumPhase");
    if (phase === undefined) {
        bad.reason = "缺少字段 museumPhase";
        return bad;
    }
    if (!isMuseumPhase(phase)) {
        bad.reason = "museumPhase 不在枚举内";
        return bad;
    }
    return {
        ok: true,
        status: "ok",
        reason: "版本 " + version,
        state: {
            childCleared: bools[0],
            soldierCleared: bools[1],
            artifactOwned: bools[2],
            museumPhase: phase,
            museumSeen: bools[3],
        },
    };
}

function normalize(text: string): string {
    return text.split("\r\n").join("\n").split("\r").join("\n");
}

/** 按当前档案路径派生备份名：archive.txt.corrupt / .corrupt.2 …，不覆盖已有原件。 */
function backupPathFor(target: string, suffix: string): string {
    let candidate = target + suffix;
    let n = 2;
    while (Content.exist(candidate)) {
        candidate = target + suffix + "." + n;
        n += 1;
        if (n > 99) {
            break;
        }
    }
    return candidate;
}

/** 把当前档案复制到派生的损坏/未知版本备份，返回备份路径（无原件则空串）。 */
function backupCorrupt(target: string, suffix: string): string {
    if (!Content.exist(target)) {
        return "";
    }
    const backup = backupPathFor(target, suffix);
    Content.copy(target, backup);
    return backup;
}

/** 备份是否有效（能解析出完整档案）。 */
function usableBackup(path: string): boolean {
    if (!Content.exist(path)) {
        return false;
    }
    const text = Content.load(path);
    return text !== undefined && parseSave(text).ok;
}

/**
 * 读取档案。
 * 自愈顺序：目标缺失但 `.tmp` 完整 → 用 `.tmp`；目标损坏但 `.prev` 完整 → 用 `.prev`。
 * 损坏/未知版本先派生备份，再回空档案；未知版本原件置保护位，普通写档拒绝覆盖。
 */
export function loadSave(): LoadResult {
    const target = absPath(currentFile);
    const tmp = target + ".tmp";
    const prev = target + ".prev";
    let recovered = false;

    if (!Content.exist(target) && Content.exist(tmp)) {
        if (usableBackup(tmp)) {
            Content.copy(tmp, target);
            Content.remove(tmp);
            recovered = true;
        }
    }

    if (!Content.exist(target)) {
        return {
            state: emptySave(), status: "missing", detail: "无档案，按新档起局",
            recovered, backup: "", action: "none",
        };
    }

    const text = Content.load(target);
    const parsed = parseSave(text === undefined ? "" : text);
    if (parsed.ok) {
        if (Content.exist(tmp)) {
            Content.remove(tmp);
        }
        return {
            state: parsed.state, status: "ok", detail: parsed.reason,
            recovered, backup: "", action: "keep",
        };
    }

    if (parsed.status === "corrupt" && usableBackup(prev)) {
        const broken = backupCorrupt(target, ".corrupt");
        Content.copy(prev, target);
        const again = parseSave(Content.load(target) === undefined ? "" : Content.load(target));
        if (again.ok) {
            return {
                state: again.state, status: "ok",
                detail: "原档损坏（" + parsed.reason + "），已从 .prev 恢复，损坏件备份为 " + broken,
                recovered: true, backup: broken, action: "keep",
            };
        }
    }

    const backup = backupCorrupt(target, parsed.status === "unsupported" ? ".unsupported" : ".corrupt");
    if (parsed.status === "unsupported") {
        protectedFile = true;
    }
    return {
        state: emptySave(),
        status: parsed.status,
        detail: (parsed.status === "unsupported"
            ? "档案版本不支持（" + parsed.reason + "），原件保留"
            : "档案损坏（" + parsed.reason + "），原件已备份")
            + (backup !== "" ? "：" + backup : ""),
        recovered, backup,
        action: "reset",
    };
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

/**
 * 写入档案：写 `.tmp` → 校验 → 备份旧档到 `.prev` → 覆盖目标 → 回读校验。
 * 任一步失败：目标保持旧内容（覆盖失败）或从 `.prev` 回滚；临时文件清理。
 * 未知版本原件处于保护位时拒绝写入，返回 false。
 */
export function saveSave(state: SaveState): boolean {
    if (protectedFile) {
        return false;
    }
    const target = absPath(currentFile);
    const dir = dirOf(target);
    if (dir !== "" && !Content.isdir(dir)) {
        Content.mkdir(dir);
    }
    const tmp = target + ".tmp";
    const prev = target + ".prev";
    const text = formatSave(state);

    if (fault === "write") {
        return false;
    }
    Content.save(tmp, text);
    const written = Content.load(tmp);
    if (written === undefined || normalize(written) !== normalize(text)) {
        Content.remove(tmp);
        return false;
    }

    const existed = Content.exist(target);
    if (existed) {
        Content.copy(target, prev);
    }
    if (fault === "replace") {
        Content.remove(tmp);
        return false;
    }

    const copied = Content.copy(tmp, target);
    if (!copied) {
        if (existed && usableBackup(prev)) {
            Content.copy(prev, target);
        }
        Content.remove(tmp);
        return false;
    }

    const check = Content.load(target);
    if (fault === "verify" || check === undefined || normalize(check) !== normalize(text)) {
        if (existed && usableBackup(prev)) {
            Content.copy(prev, target);
        } else {
            Content.remove(target);
        }
        Content.remove(tmp);
        return false;
    }

    Content.remove(tmp);
    return true;
}

/**
 * 恢复策略（给前端「档案损坏/版本不支持」页用）：把原件隔离到派生备份后删除，
 * 让下一次保存能建新档。仅当读取结果 `action === "reset"` 时需要调用。
 */
export function resetSave(): boolean {
    const target = absPath(currentFile);
    const backup = backupCorrupt(target, ".reset");
    protectedFile = false;
    if (Content.exist(target)) {
        Content.remove(target);
    }
    return backup !== "";
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
