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
import { MuseumPhase, RouteTag, StoryRoute, isMuseumPhase } from "Script/watch/run";
import { getReleaseConfig } from "Script/watch/target_types";

export const SAVE_VERSION = 1;
export const SAVE_DIR = "watch-save";
export const SAVE_FILE = "watch-save/archive.txt";
export const PORTABLE_PROFILE_FILE = "profile.sav";
export const PORTABLE_AUTOSAVE_FILE = "autosave.sav";
export const SAVE_SLOT_COUNT = 3;
export type SaveSlotId = "auto" | 1 | 2 | 3;

function isPortableSaveLayout(): boolean {
    const cfg = getReleaseConfig();
    return cfg !== undefined && cfg.saveLayout === "portable";
}

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

let customSaveFile = "";
/** 跨 Play 实例的待落盘档案：携带目标路径，切换档案后不会写错档。 */
let pending: { state: SaveState; file: string } | undefined = undefined;

function effectiveSaveFile(): string {
    if (customSaveFile !== "") {
        return customSaveFile;
    }
    return isPortableSaveLayout() ? PORTABLE_PROFILE_FILE : SAVE_FILE;
}

function usePortableBackupsForProfile(): boolean {
    return customSaveFile === "" && isPortableSaveLayout();
}

/** 引擎的 `exist/load/copy/remove` 只认绝对路径；兼容 Unix `/` 与 Windows 盘符 `C:\...`。 */
function absPath(path: string): string {
    if (path.length > 0 && (path.charAt(0) === "/" || path.charAt(0) === "\\")) {
        return path;
    }
    if (path.length >= 2 && path.charAt(1) === ":") {
        return path;
    }
    const base = Content.writablePath;
    const sep = base.indexOf("\\") >= 0 && base.indexOf("/") < 0 ? "\\" : "/";
    const norm = sep === "\\" ? path.split("/").join("\\") : path;
    const trimmed = (base.endsWith("/") || base.endsWith("\\")) ? base.slice(0, -1) : base;
    return trimmed + sep + norm;
}

function baseNameOf(path: string): string {
    let i = path.length - 1;
    for (; i >= 0; i--) {
        const ch = path.charAt(i);
        if (ch === "/" || ch === "\\") {
            return path.substring(i + 1);
        }
    }
    return path;
}

function ensureDir(dir: string): void {
    if (dir !== "" && !ops.isdir(dir)) {
        ops.mkdir(dir);
    }
}

function prevPathFor(target: string, useBackupsDir: boolean): string {
    if (useBackupsDir) {
        return absPath("backups/" + baseNameOf(target) + ".prev");
    }
    return target + ".prev";
}

/** 测试用：切到隔离档案文件；传空则回正式档案。写入时始终检查目标的实际版本。 */
export function setSaveFile(path: string): void {
    customSaveFile = path;
}

/** 登记一份待落盘档案（同拍切房、写失败都由调用方重新登记）。 */
export function markProfilePending(state: SaveState): void {
    pending = { state: state, file: effectiveSaveFile() };
}

export function profilePending(): boolean {
    return pending !== undefined;
}

/** 待落盘档案是否属于当前档案路径（切档后不应写错目标）。 */
export function pendingMatchesCurrent(): boolean {
    return pending !== undefined && pending.file === effectiveSaveFile();
}

/**
 * 把登记的档案落盘；成功才清登记，失败保留等下一帧重试。
 * 登记属于别的档案路径时不写、返回 false（调用方应显式丢弃或先切回）。
 */
export function flushProfile(): boolean {
    if (pending === undefined) {
        return true;
    }
    if (pending.file !== effectiveSaveFile()) {
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
    return effectiveSaveFile();
}

export function savePath(): string {
    return absPath(effectiveSaveFile());
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

/** 一次解析整份键值档，兼容 Windows 换行，重复键沿用首项。 */
function readFields(text: string): Record<string, string | undefined> {
    const fields: Record<string, string | undefined> = {};
    for (const line of normalize(text).split("\n")) {
        const separator = line.indexOf("=");
        if (separator <= 0) continue;
        const key = line.substring(0, separator);
        if (fields[key] === undefined) fields[key] = line.substring(separator + 1);
    }
    return fields;
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
    const fields = readFields(text);
    const versionText = fields.version;
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
        const value = fields[boolKeys[i]];
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
    const phase = fields.museumPhase;
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
    const text = ops.load(a);
    return text !== undefined && matchesText(b, text);
}

function matchesText(path: string, expected: string): boolean {
    const actual = ops.load(path);
    return actual !== undefined && normalize(actual) === normalize(expected);
}

/** 按当前档案路径派生备份名：便携模式收入 saves/backups/，常规/测试模式按原路径派生；找不到空位返回空串（拒绝覆盖）。 */
function backupPathFor(target: string, suffix: string, useBackupsDir: boolean = false): string {
    const prefix = useBackupsDir ? absPath("backups/" + baseNameOf(target)) : target;
    let candidate = prefix + suffix;
    if (!ops.exist(candidate)) {
        return candidate;
    }
    let n = 2;
    while (n <= 9999) {
        candidate = prefix + suffix + "." + n;
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
function backupCorrupt(target: string, suffix: string, useBackupsDir: boolean = false): string {
    if (!ops.exist(target)) {
        return "";
    }
    const backup = backupPathFor(target, suffix, useBackupsDir);
    if (backup === "") {
        return "";
    }
    ensureDir(dirOf(backup));
    return copyVerified(target, backup) ? backup : "";
}

/** 读文本；读不到按空串处理（解析会判 corrupt）。 */
function loadText(path: string): string {
    const text = ops.load(path);
    if (text === undefined) {
        return "";
    }
    return text;
}

type SaveParser = (text: string) => { status: LoadStatus };

/** 复制成功并回读一致后，才允许删除候选件或覆盖唯一的有效档。 */
function copyVerified(from: string, to: string): boolean {
    return ops.copy(from, to) && sameContent(from, to);
}

function restoreFrom(candidate: string, target: string, keepCandidate: boolean, parse: SaveParser): boolean {
    if (!ops.exist(candidate) || parse(loadText(candidate)).status !== "ok") return false;
    ensureDir(dirOf(target));
    if (!copyVerified(candidate, target)) return false;
    if (!keepCandidate) ops.remove(candidate);
    return true;
}

/**
 * 读取档案。
 * 自愈顺序：
 *   目标缺失 → 完整 `.tmp` → 完整 `.prev`；
 *   目标损坏 → 完整 `.tmp`（最新候选）→ 完整 `.prev`。
 * 损坏/未知版本先派生备份；普通写档按原件版本判断能否覆盖。
 */
export function loadSave(): LoadResult {
    const target = absPath(effectiveSaveFile());
    const useBackups = usePortableBackupsForProfile();
    const tmp = target + ".tmp";
    const prev = prevPathFor(target, useBackups);
    let recovered = false;
    let recoveryDetail = "";

    if (!ops.exist(target)) {
        if (restoreFrom(tmp, target, false, parseSave)) {
            recovered = true;
            recoveryDetail = "目标缺失，已用完整 .tmp 恢复";
        } else if (restoreFrom(prev, target, true, parseSave)) {
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
        const broken = backupCorrupt(target, ".corrupt", useBackups);
        if (broken !== "" && restoreFrom(tmp, target, false, parseSave)) {
            return {
                state: parseSave(loadText(target)).state,
                status: "ok",
                detail: "原档损坏（" + parsed.reason + "），已用完整 .tmp 恢复，损坏件备份为 " + broken,
                recovered: true, backup: broken, action: "keep",
            };
        }
        if (broken !== "" && restoreFrom(prev, target, true, parseSave)) {
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

    const backup = backupCorrupt(target, ".unsupported", useBackups);
    return {
        state: emptySave(), status: "unsupported",
        detail: "档案版本不支持（" + parsed.reason + "），原件保留"
            + (backup !== "" ? "：" + backup : "，备份失败（原件未动）"),
        recovered, backup, action: "reset",
    };
}

/** 目标文件的目录部分；兼容 `/` 与 `\`，没有目录就写根。 */
function dirOf(path: string): string {
    let i = path.length - 1;
    for (; i >= 0; i--) {
        const ch = path.charAt(i);
        if (ch === "/" || ch === "\\") {
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
    return writeSaveFile(savePath(), formatSave(state), usePortableBackupsForProfile(), parseSave, fault);
}

function writeSaveFile(target: string, text: string, useBackups: boolean, parse: SaveParser, failure: SaveFault = ""): boolean {
    if (failure === "write") return false;
    ensureDir(dirOf(target));
    const tmp = target + ".tmp";
    const prev = prevPathFor(target, useBackups);
    let status: LoadStatus = "missing";
    if (ops.exist(target)) {
        const original = ops.load(target);
        if (original === undefined) return false;
        status = parse(original).status;
        if (status === "unsupported") return false;
        if (status === "corrupt" && backupCorrupt(target, ".corrupt", useBackups) === "") return false;
    }

    // 首次写入也可能发生在上次中断之后。先保住唯一的有效临时件，再复用它的路径。
    if (status !== "ok" && ops.exist(tmp)) {
        const candidate = ops.load(tmp);
        if (candidate === undefined) return false;
        const candidateStatus = parse(candidate).status;
        if (candidateStatus === "unsupported") return false;
        if (candidateStatus === "ok") {
            if (!copyVerified(tmp, target)) return false;
            status = "ok";
        }
    }
    if (!ops.save(tmp, text) || !matchesText(tmp, text)) {
        ops.remove(tmp);
        return false;
    }
    if (status === "ok") {
        ensureDir(dirOf(prev));
        if (!copyVerified(target, prev)) {
            ops.remove(tmp);
            return false;
        }
    }
    if (failure === "replace" || !ops.copy(tmp, target)) {
        if (status === "ok" && !sameContent(target, prev)) copyVerified(prev, target);
        return false;
    }
    if (failure === "verify" || !matchesText(target, text)) {
        if (status === "ok" && copyVerified(prev, target)) ops.remove(tmp);
        return false;
    }
    ops.remove(tmp);
    return true;
}

/** 先清理可复活进度的候选件，失败时保留当前主文件供重试。 */
function removeSaveFiles(target: string, useBackups: boolean): boolean {
    for (const path of [prevPathFor(target, useBackups), target + ".tmp", target]) {
        if (ops.exist(path) && !ops.remove(path)) return false;
    }
    return true;
}

/**
 * 恢复策略（给前端「档案损坏/版本不支持」页用）：把原件隔离到派生备份后删除。
 * 只有备份复制成功、内容与原件一致，才删除目标和可恢复候选。
 */
export function resetSave(): boolean {
    const target = absPath(effectiveSaveFile());
    if (!ops.exist(target)) {
        return false;
    }
    const backup = backupCorrupt(target, ".reset", usePortableBackupsForProfile());
    if (backup === "") {
        return false;
    }
    if (!removeSaveFiles(target, usePortableBackupsForProfile())) return false;
    if (pendingMatchesCurrent()) clearProfilePending();
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

// ==================== 局中存档（Session Checkpoint Save） ====================
// 独立于跨局双通关档案 watch-save/archive.txt，避免影响既有关闭/损坏隔离测试。
// 仅正式剧情（source === "official"）写盘，复用 .tmp -> .prev -> 回读校验的原子落盘协议。

export const SESSION_VERSION = 1;
export const SESSION_FILE = "watch-save/session.txt";

export interface SessionSave {
    roomKey: string;
    checkpoint: number;
    seed: number;
    route: StoryRoute;
    hp: number;
    maxHp: number;
    hpAtGate: number;
    maxHpAtGate: number;
    settled: boolean;
    phase: string;
    countTick: number;
    phaseTick: number;
    handTicks: number;
    handDone: boolean;
    lineSaid: boolean;
    tied: boolean;
    carry: boolean;
    escortDone: boolean;
    craftedWeapon: string;
    equippedWeapon: string;
    wood: number;
    bell: number;
    scrap: number;
    wedge: number;
    ammo: number;
    shield: number;
    pass: number;
    quickbelt: number;
    taken: string[];
    segments: string[];
    cartAxle: number;
    cartDocked: boolean;
    /** S1..C2 正式接入后的岔路与机关进度（向后兼容旧版 session.txt）。 */
    campaignRoute?: RouteTag;
    joined?: boolean;
    c1Latch?: boolean;
    c2Latch?: boolean;
    /** 男主线 escort1..5 肉鸽三选一天赋状态（向后兼容旧版 session.txt）。 */
    talentSeed?: number;
    talentRoom?: string;
    talentOffers?: string[];
    /** 新版 8 项本领等级序列化列表（如 vitality:1,focus:2）；旧档四字段仍自动兼容。 */
    talentRanks?: string[];
    escortAttempt?: number;
    escortVariant?: number;
    talentDeferred?: boolean;
    talentVitality?: number;
    talentReload?: number;
    talentGuard?: number;
    talentCraft?: number;
    /** 房内机关/破损道具、精确角色位置与城门/空村状态（向后兼容旧版 session.txt）。 */
    props?: string[];
    playerX?: number;
    playerY?: number;
    playerDepth?: number;
    gateTick?: number;
    hasBottle?: boolean;
    villagePassed?: boolean;
    /** 局中存档元数据：Unix 秒时间戳与累计游玩时长（秒），向后兼容旧档。 */
    savedAt?: number;
    playSeconds?: number;
}

export interface SessionLoadResult {
    state: SessionSave | undefined;
    status: LoadStatus;
    detail: string;
    recovered: boolean;
    backup: string;
}

export interface SaveSlotSummary {
    id: SaveSlotId;
    exists: boolean;
    status: LoadStatus;
    roomKey: string;
    route: StoryRoute;
    hp: number;
    maxHp: number;
    savedAt: number;
    playSeconds: number;
    recovered: boolean;
}

let customSessionFile = "";

function effectiveSessionFile(): string {
    if (customSessionFile !== "") {
        return customSessionFile;
    }
    return isPortableSaveLayout() ? PORTABLE_AUTOSAVE_FILE : SESSION_FILE;
}

function usePortableBackupsForSession(): boolean {
    return customSessionFile === "" && isPortableSaveLayout();
}

export function getSlotFile(slot: SaveSlotId): string {
    if (slot === "auto") {
        return effectiveSessionFile();
    }
    if (customSessionFile !== "") {
        return customSessionFile + ".slot" + slot;
    }
    return isPortableSaveLayout()
        ? ("slots/slot_" + slot + ".sav")
        : ("watch-save/slots/slot_" + slot + ".sav");
}

export function setSessionFile(path: string): void {
    customSessionFile = path;
}

export function getSessionFile(): string {
    return effectiveSessionFile();
}

export function nowUnixSeconds(): number {
    const g = globalThis as unknown as { os?: { time?: (this: void) => number } };
    const timeFn = g.os !== undefined ? g.os.time : undefined;
    if (typeof timeFn === "function") {
        const t = timeFn();
        if (typeof t === "number" && t > 0) {
            return Math.floor(t);
        }
    }
    return 0;
}

export function formatSavedAt(ts: number): string {
    if (ts <= 0) {
        return "";
    }
    const g = globalThis as unknown as { os?: { date?: (this: void, fmt: string, t: number) => string } };
    const dateFn = g.os !== undefined ? g.os.date : undefined;
    if (typeof dateFn === "function") {
        const s = dateFn("%Y-%m-%d %H:%M", ts);
        if (typeof s === "string") {
            return s;
        }
    }
    return "";
}

export function formatPlayDuration(sec: number): string {
    const total = Math.max(0, Math.floor(sec));
    if (total <= 0) {
        return "";
    }
    const h = Math.floor(total / 3600);
    const m = Math.floor((total % 3600) / 60);
    const s = total % 60;
    const mm = m < 10 ? "0" + m : "" + m;
    const ss = s < 10 ? "0" + s : "" + s;
    if (h > 0) {
        return h + ":" + mm + ":" + ss;
    }
    return mm + ":" + ss;
}

function parseBoolField(raw: string | undefined, fallback: boolean): boolean | undefined {
    if (raw === undefined) {
        return fallback;
    }
    if (raw === "true" || raw === "1") {
        return true;
    }
    if (raw === "false" || raw === "0") {
        return false;
    }
    return undefined;
}

function parseListField(raw: string | undefined): string[] {
    if (raw === undefined || raw === "") {
        return [];
    }
    const parts = raw.split(",");
    const out: string[] = [];
    let i = 0;
    for (i = 0; i < parts.length; i++) {
        const item = parts[i].trim();
        if (item !== "") {
            out.push(item);
        }
    }
    return out;
}

export function formatSession(s: SessionSave): string {
    return [
        "version=" + SESSION_VERSION,
        "roomKey=" + s.roomKey,
        "checkpoint=" + Math.round(s.checkpoint),
        "seed=" + Math.round(s.seed),
        "route=" + s.route,
        "hp=" + Math.round(s.hp),
        "maxHp=" + Math.round(s.maxHp),
        "hpAtGate=" + Math.round(s.hpAtGate),
        "maxHpAtGate=" + Math.round(s.maxHpAtGate),
        "settled=" + (s.settled ? "true" : "false"),
        "phase=" + s.phase,
        "countTick=" + Math.round(s.countTick),
        "phaseTick=" + Math.round(s.phaseTick),
        "handTicks=" + Math.round(s.handTicks),
        "handDone=" + (s.handDone ? "true" : "false"),
        "lineSaid=" + (s.lineSaid ? "true" : "false"),
        "tied=" + (s.tied ? "true" : "false"),
        "carry=" + (s.carry ? "true" : "false"),
        "escortDone=" + (s.escortDone ? "true" : "false"),
        "craftedWeapon=" + s.craftedWeapon,
        "equippedWeapon=" + s.equippedWeapon,
        "wood=" + Math.round(s.wood),
        "bell=" + Math.round(s.bell),
        "scrap=" + Math.round(s.scrap),
        "wedge=" + Math.round(s.wedge),
        "ammo=" + Math.round(s.ammo),
        "shield=" + Math.round(s.shield),
        "pass=" + Math.round(s.pass),
        "quickbelt=" + Math.round(s.quickbelt),
        "taken=" + s.taken.join(","),
        "segments=" + s.segments.join(","),
        "cartAxle=" + Math.round(s.cartAxle),
        "cartDocked=" + (s.cartDocked ? "true" : "false"),
        "campaignRoute=" + (s.campaignRoute ?? ""),
        "joined=" + (s.joined === true ? "true" : "false"),
        "c1Latch=" + (s.c1Latch === true ? "true" : "false"),
        "c2Latch=" + (s.c2Latch === true ? "true" : "false"),
        "talentSeed=" + Math.round(s.talentSeed ?? 0),
        "talentRoom=" + (s.talentRoom ?? ""),
        "talentOffers=" + (s.talentOffers === undefined ? "" : s.talentOffers.join(",")),
        "talentRanks=" + (s.talentRanks === undefined ? "" : s.talentRanks.join(",")),
        "escortAttempt=" + Math.round(s.escortAttempt ?? 1),
        "escortVariant=" + Math.round(s.escortVariant ?? 0),
        "talentDeferred=" + (s.talentDeferred === true ? "true" : "false"),
        "talentVitality=" + Math.round(s.talentVitality ?? 0),
        "talentReload=" + Math.round(s.talentReload ?? 0),
        "talentGuard=" + Math.round(s.talentGuard ?? 0),
        "talentCraft=" + Math.round(s.talentCraft ?? 0),
        "props=" + (s.props === undefined ? "" : s.props.join(",")),
        "playerX=" + (s.playerX === undefined ? -1 : Math.round(s.playerX)),
        "playerY=" + (s.playerY === undefined ? 0 : Math.round(s.playerY)),
        "playerDepth=" + (s.playerDepth === undefined ? 0 : Math.round(s.playerDepth)),
        "gateTick=" + Math.round(s.gateTick ?? 0),
        "hasBottle=" + (s.hasBottle === true ? "true" : "false"),
        "villagePassed=" + (s.villagePassed === true ? "true" : "false"),
        "savedAt=" + Math.round(s.savedAt !== undefined && s.savedAt > 0 ? s.savedAt : nowUnixSeconds()),
        "playSeconds=" + Math.max(0, Math.round(s.playSeconds ?? 0)),
        "",
    ].join("\n");
}

export function parseSession(text: string): { ok: boolean; status: LoadStatus; reason: string; state?: SessionSave } {
    if (text.length === 0) {
        return { ok: false, status: "corrupt", reason: "局中存档为空" };
    }
    const fields = readFields(text);
    const verRaw = fields.version;
    if (verRaw === undefined) {
        return { ok: false, status: "corrupt", reason: "缺少 version 行" };
    }
    const ver = intOf(verRaw, -1);
    if (ver < 0) {
        return { ok: false, status: "corrupt", reason: "version 非法" };
    }
    if (ver > SESSION_VERSION) {
        return { ok: false, status: "unsupported", reason: "局中存档版本 " + ver + " 高于当前 " + SESSION_VERSION };
    }
    const roomKey = fields.roomKey;
    if (roomKey === undefined || roomKey === "") {
        return { ok: false, status: "corrupt", reason: "缺少 roomKey" };
    }
    const routeRaw = fields.route ?? "";
    if (routeRaw !== "" && routeRaw !== "child" && routeRaw !== "soldier") {
        return { ok: false, status: "corrupt", reason: "route 取值非法" };
    }
    const settled = parseBoolField(fields.settled, false);
    const handDone = parseBoolField(fields.handDone, false);
    const lineSaid = parseBoolField(fields.lineSaid, false);
    const tied = parseBoolField(fields.tied, false);
    const carry = parseBoolField(fields.carry, false);
    const escortDone = parseBoolField(fields.escortDone, false);
    const cartDocked = parseBoolField(fields.cartDocked, false);
    const joined = parseBoolField(fields.joined, false);
    const c1Latch = parseBoolField(fields.c1Latch, false);
    const c2Latch = parseBoolField(fields.c2Latch, false);
    if (settled === undefined || handDone === undefined || lineSaid === undefined
        || tied === undefined || carry === undefined || escortDone === undefined || cartDocked === undefined
        || joined === undefined || c1Latch === undefined || c2Latch === undefined) {
        return { ok: false, status: "corrupt", reason: "布尔字段非法" };
    }
    const campRouteRaw = fields.campaignRoute ?? "";
    if (campRouteRaw !== "" && campRouteRaw !== "outer" && campRouteRaw !== "drygoods") {
        return { ok: false, status: "corrupt", reason: "campaignRoute 取值非法" };
    }
    const hp = intOf(fields.hp ?? "3", -1);
    const maxHp = intOf(fields.maxHp ?? "3", -1);
    if (hp < 0 || maxHp <= 0) {
        return { ok: false, status: "corrupt", reason: "血量字段非法" };
    }
    return {
        ok: true,
        status: "ok",
        reason: "ok",
        state: {
            roomKey,
            checkpoint: intOf(fields.checkpoint ?? "0", 0),
            seed: intOf(fields.seed ?? "20261124", 20261124),
            route: routeRaw as StoryRoute,
            hp,
            maxHp,
            hpAtGate: intOf(fields.hpAtGate ?? "-1", -1),
            maxHpAtGate: intOf(fields.maxHpAtGate ?? "-1", -1),
            settled,
            phase: fields.phase ?? "",
            countTick: Math.max(0, intOf(fields.countTick ?? "0", 0)),
            phaseTick: Math.max(0, intOf(fields.phaseTick ?? "0", 0)),
            handTicks: Math.max(0, intOf(fields.handTicks ?? "0", 0)),
            handDone,
            lineSaid,
            tied,
            carry,
            escortDone,
            craftedWeapon: fields.craftedWeapon ?? "",
            equippedWeapon: fields.equippedWeapon ?? "",
            wood: Math.max(0, intOf(fields.wood ?? "0", 0)),
            bell: Math.max(0, intOf(fields.bell ?? "0", 0)),
            scrap: Math.max(0, intOf(fields.scrap ?? "0", 0)),
            wedge: Math.max(0, intOf(fields.wedge ?? "0", 0)),
            ammo: Math.max(0, intOf(fields.ammo ?? "0", 0)),
            shield: Math.max(0, intOf(fields.shield ?? "0", 0)),
            pass: Math.max(0, intOf(fields.pass ?? "0", 0)),
            quickbelt: Math.max(0, intOf(fields.quickbelt ?? "0", 0)),
            taken: parseListField(fields.taken),
            segments: parseListField(fields.segments),
            cartAxle: intOf(fields.cartAxle ?? "0", 0),
            cartDocked,
            campaignRoute: campRouteRaw as RouteTag,
            joined,
            c1Latch,
            c2Latch,
            talentSeed: Math.max(0, intOf(fields.talentSeed ?? "0", 0)),
            talentRoom: fields.talentRoom ?? "",
            talentOffers: parseListField(fields.talentOffers),
            talentRanks: parseListField(fields.talentRanks),
            escortAttempt: Math.max(1, intOf(fields.escortAttempt ?? "1", 1)),
            escortVariant: Math.max(0, intOf(fields.escortVariant ?? "0", 0)),
            talentDeferred: parseBoolField(fields.talentDeferred, false) === true,
            talentVitality: Math.max(0, intOf(fields.talentVitality ?? "0", 0)),
            talentReload: Math.max(0, intOf(fields.talentReload ?? "0", 0)),
            talentGuard: Math.max(0, intOf(fields.talentGuard ?? "0", 0)),
            talentCraft: Math.max(0, intOf(fields.talentCraft ?? "0", 0)),
            props: parseListField(fields.props),
            playerX: intOf(fields.playerX ?? "-1", -1),
            playerY: intOf(fields.playerY ?? "0", 0),
            playerDepth: intOf(fields.playerDepth ?? "0", 0),
            gateTick: Math.max(0, intOf(fields.gateTick ?? "0", 0)),
            hasBottle: parseBoolField(fields.hasBottle, false) === true,
            villagePassed: parseBoolField(fields.villagePassed, false) === true,
            savedAt: Math.max(0, intOf(fields.savedAt ?? "0", 0)),
            playSeconds: Math.max(0, intOf(fields.playSeconds ?? "0", 0)),
        },
    };
}

function loadSessionAtPath(relFile: string, useBackups: boolean): SessionLoadResult {
    const target = absPath(relFile);
    const tmp = target + ".tmp";
    const prev = prevPathFor(target, useBackups);
    if (!ops.exist(target)) {
        if (restoreFrom(tmp, target, false, parseSession)) {
            const p = parseSession(loadText(target));
            return { state: p.state, status: "ok", detail: "由 .tmp 恢复局中存档", recovered: true, backup: "" };
        }
        if (restoreFrom(prev, target, true, parseSession)) {
            const p = parseSession(loadText(target));
            return { state: p.state, status: "ok", detail: "由 .prev 恢复局中存档", recovered: true, backup: "" };
        }
        return { state: undefined, status: "missing", detail: "无局中存档", recovered: false, backup: "" };
    }
    const parsed = parseSession(loadText(target));
    if (parsed.ok && parsed.state !== undefined) {
        if (ops.exist(tmp) && sameContent(tmp, target)) {
            ops.remove(tmp);
        }
        return { state: parsed.state, status: "ok", detail: "局中存档读取成功", recovered: false, backup: "" };
    }
    if (parsed.status === "corrupt") {
        const broken = backupCorrupt(target, ".corrupt", useBackups);
        if (broken !== "" && restoreFrom(tmp, target, false, parseSession)) {
            const p = parseSession(loadText(target));
            return { state: p.state, status: "ok", detail: "原局中存档损坏，已用 .tmp 恢复", recovered: true, backup: broken };
        }
        if (broken !== "" && restoreFrom(prev, target, true, parseSession)) {
            const p = parseSession(loadText(target));
            return { state: p.state, status: "ok", detail: "原局中存档损坏，已用 .prev 恢复", recovered: true, backup: broken };
        }
        return { state: undefined, status: "corrupt", detail: parsed.reason, recovered: false, backup: broken };
    }
    const backup = backupCorrupt(target, ".unsupported", useBackups);
    return { state: undefined, status: "unsupported", detail: parsed.reason, recovered: false, backup };
}

function peekSlotSummary(slot: SaveSlotId): SaveSlotSummary {
    const rel = getSlotFile(slot);
    const useBackups = usePortableBackupsForSession();
    const target = absPath(rel);
    const tmp = target + ".tmp";
    const prev = prevPathFor(target, useBackups);
    const empty: SaveSlotSummary = {
        id: slot,
        exists: false,
        status: "missing",
        roomKey: "",
        route: "",
        hp: 0,
        maxHp: 0,
        savedAt: 0,
        playSeconds: 0,
        recovered: false,
    };
    const candidates: { path: string; rec: boolean }[] = [
        { path: target, rec: false },
        { path: tmp, rec: true },
        { path: prev, rec: true },
    ];
    let primaryStatus: LoadStatus = "missing";
    let i = 0;
    for (i = 0; i < candidates.length; i++) {
        const c = candidates[i];
        if (!ops.exist(c.path)) {
            continue;
        }
        const parsed = parseSession(loadText(c.path));
        if (parsed.ok && parsed.state !== undefined) {
            return {
                id: slot,
                exists: true,
                status: "ok",
                roomKey: parsed.state.roomKey,
                route: parsed.state.route,
                hp: parsed.state.hp,
                maxHp: parsed.state.maxHp,
                savedAt: parsed.state.savedAt ?? 0,
                playSeconds: parsed.state.playSeconds ?? 0,
                recovered: c.rec,
            };
        }
        if (i === 0) {
            primaryStatus = parsed.status;
            if (primaryStatus === "unsupported") break;
        }
    }
    if (primaryStatus !== "missing") {
        empty.status = primaryStatus;
    }
    return empty;
}

export function hasSlotSave(slot: SaveSlotId): boolean {
    return peekSlotSummary(slot).exists;
}

export function loadSlot(slot: SaveSlotId): SessionLoadResult {
    return loadSessionAtPath(getSlotFile(slot), usePortableBackupsForSession());
}

export function saveSlot(slot: SaveSlotId, state: SessionSave): boolean {
    return writeSaveFile(absPath(getSlotFile(slot)), formatSession(state), usePortableBackupsForSession(), parseSession);
}

export function deleteSlot(slot: SaveSlotId): boolean {
    return removeSaveFiles(absPath(getSlotFile(slot)), usePortableBackupsForSession());
}

export function listSaveSlots(): SaveSlotSummary[] {
    return [
        peekSlotSummary("auto"),
        peekSlotSummary(1),
        peekSlotSummary(2),
        peekSlotSummary(3),
    ];
}

export function hasAnySaveSlot(): boolean {
    return hasSlotSave("auto") || hasSlotSave(1) || hasSlotSave(2) || hasSlotSave(3);
}

export function hasSessionSave(): boolean {
    return hasSlotSave("auto");
}

export function loadSession(): SessionLoadResult {
    return loadSlot("auto");
}

export function saveSession(state: SessionSave): boolean {
    return saveSlot("auto", state);
}

export function clearSession(): boolean {
    return deleteSlot("auto");
}
