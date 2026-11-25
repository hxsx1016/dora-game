/**
 * 玩家档案的本地持久化。
 *
 * 档案只记跨局结果（两种通关、神器、博物馆进度），与 RunState 的局内状态分开。
 * 替换策略：先写 `.tmp` → 校验 → 备份旧档到 `.prev`（**校验备份成功才继续**） →
 * 覆盖目标 → 回读校验；任一步失败都保留旧档与有效候选件，绝不先删唯一有效旧档。
 * 启动自愈顺序：目标缺失 → 完整 `.tmp` → 完整 `.prev`；目标损坏 → 完整 `.tmp`/`.prev`。
 * 所有破坏性动作（覆盖、删除、隔离）之前都先验证备份/恢复结果与内容。
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
    /** 本次读取是否**成功**用候选件恢复过目标（失败不置 true）。 */
    recovered: boolean;
    /** 损坏/未知版本原件的备份路径；没有则为空串。 */
    backup: string;
    action: RecoveryAction;
}

/** 文件操作层：默认直接走引擎 `Content`；测试可注入返回 false 的 copy/save，覆盖真实失败分支。 */
export interface FileOps {
    exist(path: string): boolean;
    load(path: string): string | undefined;
    save(path: string, text: string): boolean;
    copy(from: string, to: string): boolean;
    remove(path: string): boolean;
    isdir(path: string): boolean;
    mkdir(path: string): boolean;
}

const contentOps: FileOps = {
    exist: (path: string): boolean => Content.exist(path),
    load: (path: string): string | undefined => Content.load(path),
    save: (path: string, text: string): boolean => Content.save(path, text),
    copy: (from: string, to: string): boolean => Content.copy(from, to),
    remove: (path: string): boolean => Content.remove(path),
    isdir: (path: string): boolean => Content.isdir(path),
    mkdir: (path: string): boolean => Content.mkdir(path),
};

let ops: FileOps = contentOps;

/** 测试注入文件操作层；传 undefined 恢复引擎默认。正式入口不调用。 */
export function setFileOpsForTest(next: FileOps | undefined): void {
    ops = next === undefined ? contentOps : next;
}

/** 故障注入：只给隔离测试用，正式入口永远是空串。 */
export type SaveFault = "" | "write" | "verify" | "replace";
let fault: SaveFault = "";

export function setSaveFault(value: SaveFault): void {
    fault = value;
}

/** `replace` 故障走真实的「copy 返回 false」分支，而不是提前跳过。 */
function copyForWrite(from: string, to: string): boolean {
    if (fault === "replace") {
        return false;
    }
    return ops.copy(from, to);
}

let currentFile = SAVE_FILE;
/** 跨 Play 实例的待落盘档案：携带目标路径，切换档案后不会写错档。 */
let pending: { state: SaveState; file: string } | undefined = undefined;
/** 读到未知版本原件后置位：该路径的普通写档一律拒绝，切走再切回仍受保护。 */
let protectedPath = "";

/** 引擎的 `exist/load/copy/remove` 只认绝对路径；相对写入会落到 writablePath 但读不回来。 */
function absPath(path: string): string {
    if (path.length > 0 && path.charAt(0) === "/") {
        return path;
    }
    return Content.writablePath + "/" + path;
}

/** 测试用：切到隔离档案文件；传空则回正式档案。不清保护位（保护位按路径绑定）。 */
export function setSaveFile(path: string): void {
    currentFile = path === "" ? SAVE_FILE : path;
}

/** 登记一份待落盘档案（同拍切房、写失败都由调用方重新登记）。 */
export function markProfilePending(state: SaveState): void {
    pending = { state: state, file: currentFile };
}

export function profilePending(): boolean {
    return pending !== undefined;
}

/** 待落盘档案是否属于当前档案路径（切档后不应写错目标）。 */
export function pendingMatchesCurrent(): boolean {
    return pending !== undefined && pending.file === currentFile;
}

/**
 * 把登记的档案落盘；成功才清登记，失败保留等下一帧重试。
 * 登记属于别的档案路径时不写、返回 false（调用方应显式丢弃或先切回）。
 */
export function flushProfile(): boolean {
    if (pending === undefined) {
        return true;
    }
    if (pending.file !== currentFile) {
        return false;
    }
    if (!saveSave(pending.state)) {
        return false;
    }
    pending = undefined;
    return true;
}

export function clearProfilePending(): void {
    pending = undefined;
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

/** 两个文件内容是否一致（读不到就是不一致）。 */
function sameContent(a: string, b: string): boolean {
    const textA = ops.load(a);
    const textB = ops.load(b);
    if (textA === undefined || textB === undefined) {
        return false;
    }
    return normalize(textA) === normalize(textB);
}

/** 按当前档案路径派生备份名：archive.txt.corrupt / .corrupt.2 …；找不到空位就返回空串（拒绝覆盖）。 */
function backupPathFor(target: string, suffix: string): string {
    let candidate = target + suffix;
    if (!ops.exist(candidate)) {
        return candidate;
    }
    let n = 2;
    while (n <= 9999) {
        candidate = target + suffix + "." + n;
        if (!ops.exist(candidate)) {
            return candidate;
        }
        n += 1;
    }
    return "";
}

/**
 * 把当前档案复制到派生的损坏/未知版本备份，返回备份路径（无原件/复制失败/内容不符则空串）。
 * 备份保留的是原件字节，可能是损坏档，所以不能用 `parseSave` 校验，只校验「复制成功且内容一致」。
 */
function backupCorrupt(target: string, suffix: string): string {
    if (!ops.exist(target)) {
        return "";
    }
    const backup = backupPathFor(target, suffix);
    if (backup === "") {
        return "";
    }
    if (!ops.copy(target, backup)) {
        return "";
    }
    if (!sameContent(target, backup)) {
        return "";
    }
    return backup;
}

/** 读文本；读不到按空串处理（解析会判 corrupt）。 */
function loadText(path: string): string {
    const text = ops.load(path);
    if (text === undefined) {
        return "";
    }
    return text;
}

/** 备份是否有效（能解析出完整档案）。 */
function usableBackup(path: string): boolean {
    if (!ops.exist(path)) {
        return false;
    }
    const text = ops.load(path);
    return text !== undefined && parseSave(text).ok;
}

/** 用候选件恢复目标；成功（复制成功且回读解析一致）才清候选，失败保留候选并返回 false。 */
function restoreFrom(candidate: string, target: string, keepCandidate: boolean): boolean {
    if (!usableBackup(candidate)) {
        return false;
    }
    if (!ops.copy(candidate, target)) {
        return false;
    }
    const again = parseSave(loadText(target));
    if (!again.ok) {
        return false;
    }
    if (!keepCandidate) {
        ops.remove(candidate);
    }
    return true;
}

/**
 * 读取档案。
 * 自愈顺序：
 *   目标缺失 → 完整 `.tmp` → 完整 `.prev`；
 *   目标损坏 → 完整 `.tmp`（最新候选）→ 完整 `.prev`。
 * 损坏/未知版本先派生备份；未知版本原件置保护位（按路径），普通写档拒绝覆盖。
 */
export function loadSave(): LoadResult {
    const target = absPath(currentFile);
    const tmp = target + ".tmp";
    const prev = target + ".prev";
    let recovered = false;
    let recoveryDetail = "";

    if (!ops.exist(target)) {
        if (restoreFrom(tmp, target, false)) {
            recovered = true;
            recoveryDetail = "目标缺失，已用完整 .tmp 恢复";
        } else if (restoreFrom(prev, target, true)) {
            recovered = true;
            recoveryDetail = "目标缺失，已用完整 .prev 恢复";
        }
    }

    if (!ops.exist(target)) {
        return {
            state: emptySave(), status: "missing",
            detail: "无档案，按新档起局" + (recovered ? "（" + recoveryDetail + "）" : ""),
            recovered, backup: "", action: "none",
        };
    }

    const text = ops.load(target);
    const parsed = parseSave(text === undefined ? "" : text);
    if (parsed.ok) {
        // 目标已完整：只在 `.tmp` 与目标内容一致时才清掉，避免丢弃内容不同的候选。
        if (ops.exist(tmp) && sameContent(tmp, target)) {
            ops.remove(tmp);
        }
        return {
            state: parsed.state, status: "ok",
            detail: parsed.reason + (recovered ? "（" + recoveryDetail + "）" : ""),
            recovered, backup: "", action: "keep",
        };
    }

    if (parsed.status === "corrupt") {
        const broken = backupCorrupt(target, ".corrupt");
        if (restoreFrom(tmp, target, false)) {
            return {
                state: parseSave(loadText(target)).state,
                status: "ok",
                detail: "原档损坏（" + parsed.reason + "），已用完整 .tmp 恢复，损坏件备份为 " + broken,
                recovered: true, backup: broken, action: "keep",
            };
        }
        if (restoreFrom(prev, target, true)) {
            return {
                state: parseSave(loadText(target)).state,
                status: "ok",
                detail: "原档损坏（" + parsed.reason + "），已用 .prev 恢复，损坏件备份为 " + broken,
                recovered: true, backup: broken, action: "keep",
            };
        }
        // 后备候选无效/复制失败：不动它们，如实返回损坏，不谎报 recovered。
        return {
            state: emptySave(), status: "corrupt",
            detail: "档案损坏（" + parsed.reason + "），原件保留"
                + (broken !== "" ? "，损坏件备份为 " + broken : "，备份失败（原件未动）"),
            recovered: false, backup: broken, action: "reset",
        };
    }

    const backup = backupCorrupt(target, ".unsupported");
    protectedPath = target;
    return {
        state: emptySave(), status: "unsupported",
        detail: "档案版本不支持（" + parsed.reason + "），原件保留"
            + (backup !== "" ? "：" + backup : "，备份失败（原件未动）"),
        recovered, backup, action: "reset",
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
 * 写入档案：写 `.tmp` → 校验 → 备份旧档到 `.prev`（校验成功才继续）→ 覆盖目标 → 回读校验。
 * 失败语义：
 *   - 备份失败：不覆盖目标，清掉本次 `.tmp`（旧档完好），返回 false；
 *   - 覆盖失败：尝试从 `.prev` 回滚；`.tmp` 保留为最新候选，返回 false；
 *   - 校验失败：用 `.prev` 回滚；回滚失败则保留 `.tmp`，返回 false。
 * 未知版本原件（按路径保护）拒绝写入。
 */
export function saveSave(state: SaveState): boolean {
    const target = absPath(currentFile);
    if (protectedPath === target) {
        return false;
    }
    const dir = dirOf(target);
    if (dir !== "" && !ops.isdir(dir)) {
        ops.mkdir(dir);
    }
    const tmp = target + ".tmp";
    const prev = target + ".prev";
    const text = formatSave(state);

    if (fault === "write") {
        return false;
    }
    if (!ops.save(tmp, text)) {
        ops.remove(tmp);
        return false;
    }
    const written = ops.load(tmp);
    if (written === undefined || normalize(written) !== normalize(text)) {
        ops.remove(tmp);
        return false;
    }

    const existed = ops.exist(target);
    let backedUp = false;
    if (existed) {
        backedUp = ops.copy(target, prev);
        if (!backedUp || !usableBackup(prev)) {
            // 备份不可用：绝不覆盖唯一有效旧档。
            ops.remove(tmp);
            return false;
        }
    }

    if (!copyForWrite(tmp, target)) {
        if (existed && backedUp && !sameContent(target, prev)) {
            ops.copy(prev, target);
        }
        // `.tmp` 保留：它是本次唯一完整候选。
        return false;
    }

    const check = ops.load(target);
    if (fault === "verify" || check === undefined || normalize(check) !== normalize(text)) {
        if (existed && backedUp && ops.copy(prev, target) && usableBackup(target)) {
            ops.remove(tmp);
            return false;
        }
        // 回滚失败：保留 `.tmp` 候选与当前目标，不删任何可能有效的东西。
        return false;
    }

    ops.remove(tmp);
    return true;
}

/**
 * 恢复策略（给前端「档案损坏/版本不支持」页用）：把原件隔离到派生备份后删除。
 * 只有备份复制成功、内容与原件一致、且备份本身可解析时才删除目标。
 */
export function resetSave(): boolean {
    const target = absPath(currentFile);
    if (!ops.exist(target)) {
        return false;
    }
    const backup = backupCorrupt(target, ".reset");
    if (backup === "") {
        return false;
    }
    // 原件本身可能不可解析（损坏/未知版本），这里只要求「复制成功且内容一致」。
    if (!sameContent(target, backup)) {
        return false;
    }
    if (!ops.remove(target)) {
        return false;
    }
    if (protectedPath === target) {
        protectedPath = "";
    }
    return true;
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
