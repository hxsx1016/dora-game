/**
 * 《向西守望》前端双线契约适配层（Phase 0 · feature/fe-00-foundation）。
 *
 * 设计红线（对齐 tqym 提交 64fc06f）：
 * 1. 正式模式（"live"）与排演模式（"rehearsal"）严格隔离：
 *    - 正式入口只读取当前后端 Play / RunState 真实快照字段；字段缺失时严格按降级口径返回，
 *      严禁静默 fallback 到 Mock，严禁按切房后的即时 HP 或房内岔路 run.route 推导 storyRoute。
 *    - 排演模式必须显式进入（enterRehearsal 或调用排演钩子），状态完全存在于独立内存中，
 *      退出排演（exitRehearsal）即彻底清空并恢复正式数据源；录屏/界面通过 isRehearsal 标注。
 * 2. 操作意图归属：
 *    - 暂停菜单与「按键辅助」开关归前端本地管理；
 *    - 换弹、风台牵手重逢、工台制作、博物馆访馆统一经由 submitIntent() 提交结构化操作意图：
 *      正式模式下透传给后端消费并等待回执，排演模式下由本地排演状态机闭环消费。
 * 3. 下游零改动承诺：
 *    - 待后端 8 类字段正式上线时，仅需将本文件内 readLive* 适配函数对齐真实字段名即可，
 *      Wave 1 / Wave 2 下游所有渲染模块复用同一 DualRouteSnapshot 视图，无需修改。
 *    - 正式联调时另需核对输入路由、模拟时钟（世界 60 拍 = 作答 240 拍）与后端持久化存档。
 */

import { GATE_COUNT_END, gateCountAtTick, Play } from "Script/watch/play";
import { Input } from "Script/watch/input";
import { FrameEvents } from "Script/watch/fe/adapter";

export type StoryRoute = "undecided" | "child" | "soldier";
export type VisualStyleMode = "pixel" | "transition" | "lowpoly" | "museum";
export type ReloadEffectKind = "normal" | "knockback" | "echo" | "light";
export type MuseumPhase =
    | "locked"
    | "well_open"
    | "well_reflect"
    | "hall_walk"
    | "lamp_turn"
    | "return_cabinet"
    | "done";
export type ContractDataSource = "live" | "rehearsal";

export interface CraftRecipeView {
    id: string;
    name: string;
    desc: string;
    enhancedEffect: ReloadEffectKind;
    cost: Record<string, number>;
    crafted: boolean;
}

export interface GateReunionSnapshot {
    active: boolean;
    knockHeard: boolean;
    holdProgress: number;
    holding: boolean;
    completed: boolean;
    releasedAbortCount: number;
}

export interface BackCarrySnapshot {
    active: boolean;
    handInHand: boolean;
    mounting: boolean;
    atBench: boolean;
}

export interface ReloadSessionSnapshot {
    active: boolean;
    firstTime: boolean;
    elapsed: number;
    duration: number;
    path: number[];
    previewEffect: ReloadEffectKind;
    nextEffect: ReloadEffectKind;
    invalidFlash: number;
}

export interface CraftBenchSnapshot {
    active: boolean;
    firstCraftDone: boolean;
    justCraftedTimer: number;
    inventory: Record<string, number>;
    recipes: CraftRecipeView[];
    equippedWeapon: string;
}

export interface ArchiveSnapshot {
    childCleared: boolean;
    soldierCleared: boolean;
    artifactOwned: boolean;
    museumPhase: MuseumPhase;
    museumSeen: boolean;
}

export interface RoguelikeStageNode {
    key: string;
    label: string;
    isBench: boolean;
    isFinal: boolean;
    cleared: boolean;
    current: boolean;
}

export interface RoguelikeSnapshot {
    active: boolean;
    showRouteTrack: boolean;
    seed: number;
    ticks: number;
    routeTag: string;
    roomKey: string;
    offers: string[];
    ranks: Record<string, number>;
    totalRanks: number;
    hp: number;
    maxHp: number;
    reloadTicksNow: number;
    invulnTicksNow: number;
    craftTicksNow: number;
    activeReloadTicks: number;
    activeInvulnTicks: number;
    activeCraftTicks: number;
    equippedWeapon: string;
    supplies: Record<string, number>;
    stages: RoguelikeStageNode[];
    talentLabelHints: Record<string, string>;
}

export interface DualRouteSnapshot {
    /** 1. 城门 80% 血量锁存结果；正式模式缺字段固定返回 undecided */
    storyRoute: StoryRoute;
    /** 2. 风台数到二十拍数与归一化进度 */
    countElapsedTicks: number;
    countDurationTicks: number;
    countNumber: number;
    countProgress: number;
    /** 3. 男主线风台 0.6s 长按牵手重逢状态 */
    gateReunion: GateReunionSnapshot;
    /** 4. 牵手 / 蹲背 / 背负 / 工台放下状态 */
    backCarry: BackCarrySnapshot;
    /** 5. 世界慢时倍率（常规 1，换弹/选筹慢时约 0.25） */
    timeScale: number;
    /** 6. 3×3 慢时连线换弹会话 */
    reloadSession: ReloadSessionSnapshot;
    /** 7. 第三段安全武器工台视图 */
    craftBench: CraftBenchSnapshot;
    /** 8. 双通关档案与水井/现代展厅状态 */
    archive: ArchiveSnapshot;
    /** 9. 肉鸽构筑、筹签、随身战备与北行里程快照 */
    roguelike: RoguelikeSnapshot;
    /** 默认关闭的低引导「按键辅助」开关（由暂停菜单切换） */
    assistHintsEnabled: boolean;
    /** 统一推导的当前画面风格模式 */
    visualMode: VisualStyleMode;
    /** 当前数据源模式（严格区分正式玩法与排演样片） */
    dataSource: ContractDataSource;
    /** 是否处于显式排演态（用于界面/录屏标注） */
    isRehearsal: boolean;
    /** 排演标签（空串表示正式模式） */
    rehearsalTag: string;
}

/** 前端提交给玩法层的结构化操作意图（M0 输入归属对齐） */
export type FrontendIntent =
    | { kind: "gateReunionHold"; holding: boolean }
    | { kind: "reloadOpen" }
    | { kind: "reloadTapNode"; node: number }
    | { kind: "reloadPathPreview"; path: number[] }
    | { kind: "reloadPathCommit"; path: number[] }
    | { kind: "reloadCancel" }
    | { kind: "craftSubmit"; requestId: string; recipeId: string }
    | { kind: "craftEquip"; weaponId: string }
    | { kind: "craftClose" }
    | { kind: "museumInteract"; target: string }
    | { kind: "chooseTalent"; slot: number };

export interface IntentLogEntry {
    tick: number;
    source: ContractDataSource;
    intent: FrontendIntent;
    accepted: boolean;
}

interface RehearsalState {
    tag: string;
    storyRoute: StoryRoute;
    countTickOverride: number | undefined;
    countDurationOverride: number | undefined;
    timeScaleOverride: number | undefined;
    gateReunion: GateReunionSnapshot;
    gateHoldArmed: boolean;
    gatePrevInteractHeld: boolean;
    backCarry: BackCarrySnapshot;
    reloadSession: ReloadSessionSnapshot;
    craftBench: CraftBenchSnapshot;
    archive: ArchiveSnapshot;
    roguelike: RoguelikeSnapshot;
    handledCraftRequestIds: Record<string, boolean>;
}

const GATE_REUNION_HOLD_SECONDS = 0.6;
const DEFAULT_RELOAD_DURATION = 4.0;
const DEFAULT_SLOW_TIME_SCALE = 0.25;
const MAX_INTENT_LOG = 64;
const BASE_CRAFT_TICKS = 45;
const BASE_INVULN_HIT_TICKS = 42;

const ESCORT_STAGE_SPECS: readonly { key: string; label: string; isBench: boolean; isFinal: boolean }[] = [
    { key: "escort1", label: "巷路", isBench: false, isFinal: false },
    { key: "escort2", label: "粮棚", isBench: false, isFinal: false },
    { key: "escort3", label: "工台", isBench: true, isFinal: false },
    { key: "escort4", label: "山道", isBench: false, isFinal: false },
    { key: "escort5", label: "塔前", isBench: false, isFinal: true },
];

const CAMPAIGN_STAGE_SPECS: readonly { key: string; label: string; isBench: boolean; isFinal: boolean }[] = [
    { key: "s1-crossroad", label: "十字街", isBench: false, isFinal: false },
    { key: "s2-drygoods", label: "布行", isBench: false, isFinal: false },
    { key: "s3-archway", label: "牌楼", isBench: false, isFinal: false },
    { key: "c1-yard", label: "候检院", isBench: false, isFinal: false },
    { key: "c2-granary", label: "军粮棚", isBench: false, isFinal: true },
];

function computeDerivedReloadTicks(ranks: Record<string, number>, supplies: Record<string, number>): number {
    const base = (supplies["quickbelt"] ?? 0) > 0 ? 36 : 54;
    const rel = ranks["reload"] ?? 0;
    const crf = ranks["craft"] ?? 0;
    return Math.max(6, base - 6 * rel - 3 * crf);
}

function computeDerivedInvulnTicks(ranks: Record<string, number>): number {
    return BASE_INVULN_HIT_TICKS + 12 * (ranks["guard"] ?? 0);
}

function computeDerivedCraftTicks(ranks: Record<string, number>): number {
    return Math.max(6, BASE_CRAFT_TICKS - 6 * (ranks["craft"] ?? 0));
}

function buildStageNodes(
    specs: readonly { key: string; label: string; isBench: boolean; isFinal: boolean }[],
    currentRoomKey: string,
    clearedMap?: Record<string, boolean>,
): RoguelikeStageNode[] {
    let curIdx = -1;
    let i = 0;
    for (i = 0; i < specs.length; i++) {
        if (specs[i].key === currentRoomKey) {
            curIdx = i;
            break;
        }
    }
    const out: RoguelikeStageNode[] = [];
    for (i = 0; i < specs.length; i++) {
        const sp = specs[i];
        const byMap = clearedMap !== undefined && clearedMap[sp.key] === true;
        const cleared = byMap || (curIdx >= 0 && i < curIdx);
        out.push({
            key: sp.key,
            label: sp.label,
            isBench: sp.isBench,
            isFinal: sp.isFinal,
            cleared,
            current: sp.key === currentRoomKey,
        });
    }
    return out;
}

function createEmptyRoguelike(): RoguelikeSnapshot {
    return {
        active: false,
        showRouteTrack: false,
        seed: 0,
        ticks: 0,
        routeTag: "",
        roomKey: "",
        offers: [],
        ranks: { vitality: 0, reload: 0, guard: 0, craft: 0 },
        totalRanks: 0,
        hp: 3,
        maxHp: 3,
        reloadTicksNow: 54,
        invulnTicksNow: BASE_INVULN_HIT_TICKS,
        craftTicksNow: BASE_CRAFT_TICKS,
        activeReloadTicks: 0,
        activeInvulnTicks: 0,
        activeCraftTicks: 0,
        equippedWeapon: "standard_gun",
        supplies: {},
        stages: [],
        talentLabelHints: {},
    };
}

function cloneRoguelike(src: RoguelikeSnapshot): RoguelikeSnapshot {
    const stages: RoguelikeStageNode[] = [];
    let i = 0;
    for (i = 0; i < src.stages.length; i++) {
        const s = src.stages[i];
        stages.push({
            key: s.key,
            label: s.label,
            isBench: s.isBench,
            isFinal: s.isFinal,
            cleared: s.cleared,
            current: s.current,
        });
    }
    const hints: Record<string, string> = {};
    for (const k in src.talentLabelHints) {
        hints[k] = src.talentLabelHints[k];
    }
    return {
        active: src.active,
        showRouteTrack: src.showRouteTrack,
        seed: src.seed,
        ticks: src.ticks,
        routeTag: src.routeTag,
        roomKey: src.roomKey,
        offers: src.offers.slice(),
        ranks: cloneRecordNum(src.ranks),
        totalRanks: src.totalRanks,
        hp: src.hp,
        maxHp: src.maxHp,
        reloadTicksNow: src.reloadTicksNow,
        invulnTicksNow: src.invulnTicksNow,
        craftTicksNow: src.craftTicksNow,
        activeReloadTicks: src.activeReloadTicks,
        activeInvulnTicks: src.activeInvulnTicks,
        activeCraftTicks: src.activeCraftTicks,
        equippedWeapon: src.equippedWeapon,
        supplies: cloneRecordNum(src.supplies),
        stages,
        talentLabelHints: hints,
    };
}

function defaultRecipes(): CraftRecipeView[] {
    return [
        {
            id: "guide_lantern_gun",
            name: "引路灯铳",
            desc: "以两枚木纹筹改制，增强灯纹照亮范围与余明",
            enhancedEffect: "light",
            cost: { wood_tally: 2 },
            crafted: false,
        },
        {
            id: "echo_gun",
            name: "回声铳",
            desc: "以一枚木纹筹与一枚铃纹筹改制，增强铃纹回声诱导",
            enhancedEffect: "echo",
            cost: { wood_tally: 1, bell_tally: 1 },
            crafted: false,
        },
    ];
}

function cloneRecordNum(src: Record<string, number>): Record<string, number> {
    const out: Record<string, number> = {};
    for (const k in src) {
        out[k] = src[k];
    }
    return out;
}

function cloneRecipes(list: CraftRecipeView[]): CraftRecipeView[] {
    const out: CraftRecipeView[] = [];
    let i = 0;
    for (i = 0; i < list.length; i++) {
        const r = list[i];
        out.push({
            id: r.id,
            name: r.name,
            desc: r.desc,
            enhancedEffect: r.enhancedEffect,
            cost: cloneRecordNum(r.cost),
            crafted: r.crafted,
        });
    }
    return out;
}

function createEmptyGateReunion(): GateReunionSnapshot {
    return {
        active: false,
        knockHeard: false,
        holdProgress: 0,
        holding: false,
        completed: false,
        releasedAbortCount: 0,
    };
}

function createEmptyBackCarry(): BackCarrySnapshot {
    return {
        active: false,
        handInHand: false,
        mounting: false,
        atBench: false,
    };
}

function createEmptyReloadSession(): ReloadSessionSnapshot {
    return {
        active: false,
        firstTime: true,
        elapsed: 0,
        duration: DEFAULT_RELOAD_DURATION,
        path: [],
        previewEffect: "normal",
        nextEffect: "normal",
        invalidFlash: 0,
    };
}

function createEmptyCraftBench(): CraftBenchSnapshot {
    return {
        active: false,
        firstCraftDone: false,
        justCraftedTimer: 0,
        inventory: {},
        recipes: defaultRecipes(),
        equippedWeapon: "standard_gun",
    };
}

function createEmptyArchive(): ArchiveSnapshot {
    return {
        childCleared: false,
        soldierCleared: false,
        artifactOwned: false,
        museumPhase: "locked",
        museumSeen: false,
    };
}

function createInitialRehearsalState(tag: string): RehearsalState {
    const bench = createEmptyCraftBench();
    bench.inventory = { wood_tally: 2, bell_tally: 1 };
    return {
        tag,
        storyRoute: "undecided",
        countTickOverride: undefined,
        countDurationOverride: undefined,
        timeScaleOverride: undefined,
        gateReunion: createEmptyGateReunion(),
        gateHoldArmed: true,
        gatePrevInteractHeld: false,
        backCarry: createEmptyBackCarry(),
        reloadSession: createEmptyReloadSession(),
        craftBench: bench,
        archive: createEmptyArchive(),
        roguelike: createEmptyRoguelike(),
        handledCraftRequestIds: {},
    };
}

function asRecord(value: unknown): Record<string, unknown> | undefined {
    if (value !== undefined && typeof value === "object") {
        return value as Record<string, unknown>;
    }
    return undefined;
}

function readNum(rec: Record<string, unknown> | undefined, key: string): number | undefined {
    if (rec === undefined) {
        return undefined;
    }
    const v = rec[key];
    return typeof v === "number" ? v : undefined;
}

function readBool(rec: Record<string, unknown> | undefined, key: string): boolean | undefined {
    if (rec === undefined) {
        return undefined;
    }
    const v = rec[key];
    return typeof v === "boolean" ? v : undefined;
}

function readStr(rec: Record<string, unknown> | undefined, key: string): string | undefined {
    if (rec === undefined) {
        return undefined;
    }
    const v = rec[key];
    return typeof v === "string" ? v : undefined;
}

function readNumArray(rec: Record<string, unknown> | undefined, key: string): number[] | undefined {
    if (rec === undefined) {
        return undefined;
    }
    const v = rec[key];
    if (!Array.isArray(v)) {
        return undefined;
    }
    const out: number[] = [];
    let i = 0;
    for (i = 0; i < v.length; i++) {
        if (typeof v[i] === "number") {
            out.push(v[i] as number);
        }
    }
    return out;
}

function readNumMap(rec: Record<string, unknown> | undefined, key: string): Record<string, number> | undefined {
    if (rec === undefined) {
        return undefined;
    }
    const obj = asRecord(rec[key]);
    if (obj === undefined) {
        return undefined;
    }
    const out: Record<string, number> = {};
    for (const k in obj) {
        const val = obj[k];
        if (typeof val === "number") {
            out[k] = val;
        }
    }
    return out;
}

function parseStoryRoute(v: unknown): StoryRoute {
    if (v === "child" || v === "soldier") {
        return v;
    }
    return "undecided";
}

function parseReloadEffect(v: unknown): ReloadEffectKind {
    if (v === "push" || v === "knockback") {
        return "knockback";
    }
    if (v === "echo" || v === "light") {
        return v;
    }
    return "normal";
}

function parseMuseumPhase(v: unknown): MuseumPhase {
    if (
        v === "well_open" ||
        v === "well_reflect" ||
        v === "hall_walk" ||
        v === "lamp_turn" ||
        v === "return_cabinet" ||
        v === "done"
    ) {
        return v;
    }
    return "locked";
}

/**
 * 根据 3×3 路径点集合推导效果（对齐后端 reload.ts 布局）：
 * - 0 = 左下起点，8 = 右上枪机复位终点；
 * - 4 = 中心铃纹（echo，优先），2 = 右下灯纹（light），其余有效路径 = 推退（knockback）。
 */
function deriveReloadEffectFromPath(path: number[]): ReloadEffectKind {
    if (path.length < 2) {
        return "normal";
    }
    let hasBell = false;
    let hasLamp = false;
    let i = 0;
    for (i = 0; i < path.length; i++) {
        if (path[i] === 4) {
            hasBell = true;
        } else if (path[i] === 2) {
            hasLamp = true;
        }
    }
    if (hasBell) {
        return "echo";
    }
    if (hasLamp) {
        return "light";
    }
    return "knockback";
}

function deriveVisualMode(
    roomKey: string,
    phase: string,
    storyRoute: StoryRoute,
    museumPhase: MuseumPhase,
    countProgress: number,
    reunionCompleted: boolean,
): VisualStyleMode {
    if (
        roomKey === "museum" ||
        museumPhase === "well_reflect" ||
        museumPhase === "hall_walk" ||
        museumPhase === "lamp_turn" ||
        museumPhase === "return_cabinet"
    ) {
        return "museum";
    }
    if (roomKey === "gate") {
        if (phase === "gate-hand") {
            return "pixel";
        }
        if (phase === "gate-wait") {
            return reunionCompleted ? "pixel" : "lowpoly";
        }
        if (phase === "gate-count") {
            if (storyRoute === "soldier" && reunionCompleted) {
                return "pixel";
            }
            if (countProgress <= 0) {
                return "pixel";
            }
            if (countProgress >= 1) {
                return "lowpoly";
            }
            return "transition";
        }
        if (phase === "gate-walk") {
            return storyRoute === "soldier" ? "pixel" : (storyRoute === "child" ? "lowpoly" : "pixel");
        }
        return "pixel";
    }
    if (roomKey === "gatepath" || roomKey === "escort1" || roomKey === "escort2" || roomKey === "escort3"
        || roomKey === "escort4" || roomKey === "escort5") {
        return "pixel";
    }
    if (roomKey === "outside" || roomKey === "village" || roomKey === "forest" || roomKey === "tower") {
        if (storyRoute === "child") {
            return "lowpoly";
        }
        return "pixel";
    }
    return "pixel";
}

export class DualRouteContract {
    private source: ContractDataSource = "live";
    private rehearsal: RehearsalState | undefined;
    /** 用户主动设置的「按键辅助」开关，默认关闭；切房、重试、退出排演均保持用户设置 */
    private assistHintsEnabled = false;
    /** 正式模式工台制作请求幂等防重表（切房/重试清空） */
    private livePendingCraftRequests: Record<string, boolean> = {};
    /** 正式模式瞬时交互计数（从后端一次性事件累计，切房/重试清零） */
    private liveReleasedAbortCount = 0;
    private liveReloadInvalidFlash = 0;
    private liveFocusTimeScale = 1;
    private liveArchiveCache: ArchiveSnapshot = createEmptyArchive();
    private intentLog: IntentLogEntry[] = [];
    private lastSnapshot: DualRouteSnapshot | undefined;

    constructor(private readonly canPickTalent?: (p: Play) => boolean) {}

    /** 获取当前数据源模式 */
    getDataSource(): ContractDataSource {
        return this.source;
    }

    /** 是否处于显式排演模式 */
    isRehearsal(): boolean {
        return this.source === "rehearsal" && this.rehearsal !== undefined;
    }

    /** 显式进入排演模式（独立内存状态，绝不污染正式玩法与档案） */
    enterRehearsal(tag: string = "rehearsal"): void {
        this.source = "rehearsal";
        if (this.rehearsal === undefined) {
            this.rehearsal = createInitialRehearsalState(tag);
        } else {
            this.rehearsal.tag = tag;
        }
    }

    /** 退出排演模式：立即清空独立排演内存，恢复正式数据源 */
    exitRehearsal(): void {
        this.source = "live";
        this.rehearsal = undefined;
        this.liveFocusTimeScale = 1;
    }

    /** 设置前端聚焦轻慢时倍率（如三筹木牍展卷或行军札记翻阅时的 0.25x 表现层缓流，绝不阻塞 Play.update 模拟步） */
    setFocusTimeScale(scale: number): void {
        this.liveFocusTimeScale = Math.max(0.2, Math.min(1, scale));
    }

    getFocusTimeScale(): number {
        return this.liveFocusTimeScale;
    }

    private ensureRehearsal(tag: string = "mock"): RehearsalState {
        if (this.source !== "rehearsal" || this.rehearsal === undefined) {
            this.enterRehearsal(tag);
        }
        return this.rehearsal as RehearsalState;
    }

    isAssistHintsEnabled(): boolean {
        return this.assistHintsEnabled;
    }

    setAssistHintsEnabled(enabled: boolean): void {
        this.assistHintsEnabled = enabled;
    }

    toggleAssistHints(): boolean {
        this.assistHintsEnabled = !this.assistHintsEnabled;
        return this.assistHintsEnabled;
    }

    getLastSnapshot(): DualRouteSnapshot | undefined {
        return this.lastSnapshot;
    }

    /** 仅采样静态视图快照（不推进计时与交互边沿），供 bindPlay 通知插件初始化使用 */
    peekSnapshot(p: Play): DualRouteSnapshot {
        const neutralInput = {
            interact: { held: false, pressed: false, released: false },
        } as unknown as Input;
        return this.sample(p, 0, neutralInput);
    }

    getIntentLog(): readonly IntentLogEntry[] {
        return this.intentLog;
    }

    clearIntentLog(): void {
        this.intentLog = [];
    }

    /**
     * 切房或重试时重置瞬时态：
     * - 清空房间级瞬时态（gateReunion、reloadSession、justCraftedTimer、请求幂等锁）；
     * - 正式模式从后端快照重读双结局与神器档案；
     * - 排演模式在该次排演内跨房保留内存档案（退出排演即清）；
     * - assistHintsEnabled 始终保留用户设置。
     */
    resetForRoom(p: Play): void {
        this.livePendingCraftRequests = {};
        this.liveReleasedAbortCount = 0;
        this.liveReloadInvalidFlash = 0;
        this.liveFocusTimeScale = 1;
        this.liveArchiveCache = this.readLiveArchive(p);
        if (this.rehearsal !== undefined) {
            this.rehearsal.gateReunion = createEmptyGateReunion();
            this.rehearsal.gateHoldArmed = true;
            this.rehearsal.gatePrevInteractHeld = false;
            this.rehearsal.reloadSession = createEmptyReloadSession();
            this.rehearsal.craftBench.active = false;
            this.rehearsal.craftBench.justCraftedTimer = 0;
            this.rehearsal.handledCraftRequestIds = {};
            this.rehearsal.timeScaleOverride = undefined;
        }
    }

    /**
     * 每帧采样只读契约视图：
     * - 正式模式仅消费当前 Play / RunState 快照，缺字段按安全口径降级；
     * - 排演模式仅消费独立内存状态，并打 isRehearsal = true 标记；
     * - 暂停时 rawDt 应传 0（或由 p.paused 保护），冻结所有排演计时。
     */
    sample(p: Play, rawDt: number, input: Input, events?: FrameEvents): DualRouteSnapshot {
        const dt = p.paused ? 0 : Math.max(0, rawDt);
        const snap = this.source === "rehearsal" && this.rehearsal !== undefined
            ? this.sampleRehearsal(p, dt, input, this.rehearsal)
            : this.sampleLive(p, dt, events);
        this.lastSnapshot = snap;
        return snap;
    }

    /**
     * 提交前端操作意图（换弹 / 风台长按重逢 / 工台制作 / 博物馆交互）。
     * - 正式模式：仅转发给后端 Play（若已暴露 submitFeIntent），绝不私自篡改 Play 内部状态；
     * - 排演模式：由独立排演内存状态机闭环消费。
     */
    submitIntent(p: Play, intent: FrontendIntent): boolean {
        const allowed = intent.kind !== "chooseTalent" || this.canPickTalent === undefined || this.canPickTalent(p);
        const accepted = allowed && (this.source === "rehearsal" && this.rehearsal !== undefined
            ? this.applyRehearsalIntent(this.rehearsal, intent)
            : this.forwardLiveIntent(p, intent));
        this.intentLog.push({
            tick: p.ticks,
            source: this.source,
            intent,
            accepted,
        });
        if (this.intentLog.length > MAX_INTENT_LOG) {
            this.intentLog.shift();
        }
        return accepted;
    }

    // ==================== 排演与自动化控制钩子 ====================

    setMockRoute(route: StoryRoute): void {
        const st = this.ensureRehearsal("mock");
        st.storyRoute = route;
    }

    setMockCountTick(tick: number | undefined, duration?: number): void {
        const st = this.ensureRehearsal("mock");
        st.countTickOverride = tick;
        if (duration !== undefined && duration > 0) {
            st.countDurationOverride = duration;
        }
    }

    setMockTimeScale(scale: number | undefined): void {
        const st = this.ensureRehearsal("mock");
        st.timeScaleOverride = scale;
    }

    setMockGateReunion(patch: Partial<GateReunionSnapshot>): void {
        const st = this.ensureRehearsal("mock");
        if (patch.active !== undefined) { st.gateReunion.active = patch.active; }
        if (patch.knockHeard !== undefined) { st.gateReunion.knockHeard = patch.knockHeard; }
        if (patch.holdProgress !== undefined) { st.gateReunion.holdProgress = Math.max(0, Math.min(1, patch.holdProgress)); }
        if (patch.holding !== undefined) { st.gateReunion.holding = patch.holding; }
        if (patch.completed !== undefined) { st.gateReunion.completed = patch.completed; }
        if (patch.releasedAbortCount !== undefined) { st.gateReunion.releasedAbortCount = patch.releasedAbortCount; }
    }

    setMockBackCarry(patch: Partial<BackCarrySnapshot>): void {
        const st = this.ensureRehearsal("mock");
        if (patch.active !== undefined) { st.backCarry.active = patch.active; }
        if (patch.handInHand !== undefined) { st.backCarry.handInHand = patch.handInHand; }
        if (patch.mounting !== undefined) { st.backCarry.mounting = patch.mounting; }
        if (patch.atBench !== undefined) { st.backCarry.atBench = patch.atBench; }
    }

    triggerMockReload(
        active: boolean,
        options?: { firstTime?: boolean; duration?: number; slowTimeScale?: number },
    ): void {
        const st = this.ensureRehearsal("mock");
        st.reloadSession.active = active;
        if (active) {
            st.reloadSession.elapsed = 0;
            st.reloadSession.duration = options?.duration ?? DEFAULT_RELOAD_DURATION;
            st.reloadSession.path = [];
            st.reloadSession.previewEffect = "normal";
            st.reloadSession.invalidFlash = 0;
            if (options?.firstTime !== undefined) {
                st.reloadSession.firstTime = options.firstTime;
            }
            st.timeScaleOverride = options?.slowTimeScale ?? DEFAULT_SLOW_TIME_SCALE;
        } else {
            st.reloadSession.elapsed = 0;
            st.reloadSession.path = [];
            st.timeScaleOverride = undefined;
        }
    }

    triggerMockBench(
        active: boolean,
        options?: { inventory?: Record<string, number>; equippedWeapon?: string },
    ): void {
        const st = this.ensureRehearsal("mock");
        st.craftBench.active = active;
        st.backCarry.atBench = active;
        if (options?.inventory !== undefined) {
            st.craftBench.inventory = cloneRecordNum(options.inventory);
        }
        if (options?.equippedWeapon !== undefined) {
            st.craftBench.equippedWeapon = options.equippedWeapon;
        }
    }

    setMockArchive(childCleared: boolean, soldierCleared: boolean, artifactOwned?: boolean): void {
        const st = this.ensureRehearsal("mock");
        st.archive.childCleared = childCleared;
        st.archive.soldierCleared = soldierCleared;
        if (artifactOwned !== undefined) {
            st.archive.artifactOwned = artifactOwned;
        }
        if (childCleared && soldierCleared && st.archive.museumPhase === "locked") {
            st.archive.museumPhase = "well_open";
        } else if ((!childCleared || !soldierCleared) && st.archive.museumPhase === "well_open") {
            st.archive.museumPhase = "locked";
        }
    }

    enterMockMuseum(phase: MuseumPhase): void {
        const st = this.ensureRehearsal("mock");
        st.archive.museumPhase = phase;
        if (phase === "done") {
            st.archive.museumSeen = true;
        }
        if (
            phase === "well_reflect" ||
            phase === "hall_walk" ||
            phase === "lamp_turn" ||
            phase === "return_cabinet" ||
            phase === "done"
        ) {
            st.archive.artifactOwned = true;
        }
    }

    setMockRoguelike(patch: Partial<RoguelikeSnapshot> & { clearOffers?: boolean }): void {
        const st = this.ensureRehearsal("mock");
        const rg = st.roguelike;
        rg.active = patch.active ?? true;
        if (patch.showRouteTrack !== undefined) { rg.showRouteTrack = patch.showRouteTrack; }
        if (patch.seed !== undefined) { rg.seed = patch.seed; }
        if (patch.ticks !== undefined) { rg.ticks = patch.ticks; }
        if (patch.routeTag !== undefined) { rg.routeTag = patch.routeTag; }
        if (patch.roomKey !== undefined) { rg.roomKey = patch.roomKey; }
        if (patch.clearOffers === true) {
            rg.offers = [];
        } else if (patch.offers !== undefined) {
            rg.offers = patch.offers.slice();
        }
        if (patch.ranks !== undefined) {
            rg.ranks = cloneRecordNum(patch.ranks);
        }
        if (patch.supplies !== undefined) {
            rg.supplies = cloneRecordNum(patch.supplies);
        }
        if (patch.hp !== undefined) { rg.hp = patch.hp; }
        if (patch.maxHp !== undefined) { rg.maxHp = patch.maxHp; }
        if (patch.equippedWeapon !== undefined) { rg.equippedWeapon = patch.equippedWeapon; }
        if (patch.activeReloadTicks !== undefined) { rg.activeReloadTicks = patch.activeReloadTicks; }
        if (patch.activeInvulnTicks !== undefined) { rg.activeInvulnTicks = patch.activeInvulnTicks; }
        if (patch.activeCraftTicks !== undefined) { rg.activeCraftTicks = patch.activeCraftTicks; }
        if (patch.stages !== undefined) {
            rg.stages = patch.stages.map(s => ({ ...s }));
        } else if (rg.stages.length === 0) {
            rg.stages = buildStageNodes(ESCORT_STAGE_SPECS, rg.roomKey !== "" ? rg.roomKey : "escort1");
        }
        if (patch.talentLabelHints !== undefined) {
            rg.talentLabelHints = {};
            for (const k in patch.talentLabelHints) {
                rg.talentLabelHints[k] = patch.talentLabelHints[k];
            }
        }
        let sum = 0;
        for (const k in rg.ranks) {
            sum += rg.ranks[k] ?? 0;
        }
        rg.totalRanks = patch.totalRanks ?? sum;
        rg.reloadTicksNow = patch.reloadTicksNow ?? computeDerivedReloadTicks(rg.ranks, rg.supplies);
        rg.invulnTicksNow = patch.invulnTicksNow ?? computeDerivedInvulnTicks(rg.ranks);
        rg.craftTicksNow = patch.craftTicksNow ?? computeDerivedCraftTicks(rg.ranks);
    }

    // ==================== 正式模式读取适配（后端字段上线后仅改此处） ====================

    private sampleLive(p: Play, dt: number, events?: FrameEvents): DualRouteSnapshot {
        const pRec = asRecord(p);
        const runRec = asRecord(p.run);
        const storyRec = asRecord(runRec !== undefined ? runRec["story"] : undefined);

        if (dt > 0 && this.liveReloadInvalidFlash > 0) {
            this.liveReloadInvalidFlash = Math.max(0, this.liveReloadInvalidFlash - dt);
        }
        if (events !== undefined && events.rawEvents.length > 0) {
            let ei = 0;
            for (ei = 0; ei < events.rawEvents.length; ei++) {
                const ename = events.rawEvents[ei].name as string;
                if (ename === "handRelease") {
                    this.liveReleasedAbortCount += 1;
                } else if (ename === "reloadInvalid") {
                    this.liveReloadInvalidFlash = 0.35;
                }
            }
        }

        // 1. 路线锁存：仅读取后端锁存字段（兼容 p.storyRoute 与 p.run.story.route）；严禁读即时 HP 或 run.route
        const rawRoute = pRec !== undefined && typeof pRec["storyRoute"] === "string" && pRec["storyRoute"] !== ""
            ? pRec["storyRoute"]
            : (storyRec !== undefined && typeof storyRec["route"] === "string" && storyRec["route"] !== ""
                ? storyRec["route"]
                : (runRec !== undefined ? runRec["storyRoute"] : undefined));
        const storyRoute = parseStoryRoute(rawRoute);

        // 2. 风台数到二十：兼容 countElapsedTicks 与既有 countTick
        const countElapsedTicks = readNum(pRec, "countElapsedTicks") ?? p.countTick;
        const countDurationTicks = Math.max(1, readNum(pRec, "countDurationTicks") ?? GATE_COUNT_END);
        const countNumber = gateCountAtTick(countElapsedTicks);
        const countProgress = Math.max(0, Math.min(1, countElapsedTicks / countDurationTicks));

        // 3. 风台长按牵手重逢（兼容嵌套 gateReunion 与 A单后端 gate-wait/gate-hand + handTicks/handNeedTicks）
        const grRec = asRecord(pRec !== undefined ? pRec["gateReunion"] : undefined);
        const flatHold = readNum(pRec, "gateHoldProgress");
        const inGateWaitOrHand = p.room.key === "gate" && (p.phase === "gate-wait" || p.phase === "gate-hand");
        const handTicks = readNum(pRec, "handTicks") ?? 0;
        const handNeedTicks = Math.max(1, readNum(pRec, "handNeedTicks") ?? 36);
        const handTied = p.room.key === "gate" && p.phase === "gate-hand";
        const derivedHoldProg = handTied ? 1 : (inGateWaitOrHand ? Math.max(0, Math.min(1, handTicks / handNeedTicks)) : 0);
        const gateReunion: GateReunionSnapshot = {
            active: readBool(grRec, "active") ?? inGateWaitOrHand,
            knockHeard: readBool(grRec, "knockHeard") ?? (inGateWaitOrHand && p.knocks >= 1),
            holdProgress: Math.max(0, Math.min(1, readNum(grRec, "holdProgress") ?? flatHold ?? derivedHoldProg)),
            holding: readBool(grRec, "holding") ?? (inGateWaitOrHand && !handTied && handTicks > 0),
            completed: readBool(grRec, "completed") ?? handTied,
            releasedAbortCount: readNum(grRec, "releasedAbortCount") ?? this.liveReleasedAbortCount,
        };

        // 4. 牵手与背负姿态（兼容嵌套 backCarry、B1 carryOn 与 B2 第三段工台放下态 craftBench.active）
        const bcRec = asRecord(pRec !== undefined ? pRec["backCarry"] : undefined);
        const cbRecEarly = asRecord(pRec !== undefined ? pRec["craftBench"] : undefined);
        const benchActiveLive = readBool(cbRecEarly, "active") ?? false;
        const carryOn = readBool(pRec, "carryOn") ?? readBool(storyRec, "carry") ?? false;
        const handInHandLive = handTied || (p.room.key === "gatepath" && !carryOn);
        const backCarry: BackCarrySnapshot = {
            active: readBool(bcRec, "active") ?? carryOn,
            handInHand: readBool(bcRec, "handInHand") ?? handInHandLive,
            mounting: readBool(bcRec, "mounting") ?? (p.room.key === "gatepath" && carryOn),
            atBench: readBool(bcRec, "atBench") ?? benchActiveLive,
        };

        // 5 & 6. 世界慢时与 3×3 换弹会话（兼容嵌套 reloadSession 与 B1后端 reloadOpen/reloadAnswerTicks/reloadPath/reloadPendingEffect）
        const rsRec = asRecord(pRec !== undefined ? pRec["reloadSession"] : undefined);
        const reloadOpenLive = readBool(pRec, "reloadOpen") ?? false;
        const reloadActive = readBool(rsRec, "active") ?? reloadOpenLive;
        const reloadAnswerTicks = readNum(pRec, "reloadAnswerTicks") ?? 0;
        const reloadTryCount = readNum(pRec, "reloadTryCount") ?? 0;
        const livePath = readNumArray(rsRec, "path") ?? readNumArray(pRec, "reloadPath") ?? [];
        const liveNextRaw = rsRec !== undefined && rsRec["nextEffect"] !== undefined
            ? rsRec["nextEffect"]
            : (pRec !== undefined && pRec["reloadPendingEffect"] !== undefined
                ? pRec["reloadPendingEffect"]
                : (pRec !== undefined ? pRec["nextEffect"] : undefined));
        const livePreview = rsRec !== undefined && rsRec["previewEffect"] !== undefined
            ? parseReloadEffect(rsRec["previewEffect"])
            : (reloadActive ? deriveReloadEffectFromPath(livePath) : "normal");

        const needTicksFn = pRec !== undefined ? pRec["reloadNeedTicks"] : undefined;
        const liveReloadDuration = typeof needTicksFn === "function"
            ? Math.max(0.5, (needTicksFn as (self: Play) => number)(p) / 60)
            : DEFAULT_RELOAD_DURATION;
        const reloadSession: ReloadSessionSnapshot = {
            active: reloadActive,
            firstTime: readBool(rsRec, "firstTime") ?? (reloadTryCount <= 1),
            elapsed: readNum(rsRec, "elapsed") ?? (reloadAnswerTicks / 60),
            duration: Math.max(0.01, readNum(rsRec, "duration") ?? liveReloadDuration),
            path: livePath,
            previewEffect: livePreview,
            nextEffect: parseReloadEffect(liveNextRaw),
            invalidFlash: readNum(rsRec, "invalidFlash") ?? this.liveReloadInvalidFlash,
        };

        const rawScale = readNum(pRec, "timeScale") ?? readNum(runRec, "timeScale");
        const baseScale = rawScale !== undefined && rawScale >= 0
            ? rawScale
            : (reloadActive ? DEFAULT_SLOW_TIME_SCALE : 1);
        const timeScale = Math.min(baseScale, this.liveFocusTimeScale);

        // 7. 第三段安全工台
        const cbRec = asRecord(pRec !== undefined ? pRec["craftBench"] : undefined);
        const craftBench = this.readLiveCraftBench(cbRec, pRec, runRec);

        // 8. 双通关档案与水井/博物馆
        const archive = this.readLiveArchive(p);
        this.liveArchiveCache = archive;

        // 9. 肉鸽成长、筹签、随身战备与北行里程快照（防御性多源读取，向前兼容后端扩展）
        const roguelike = this.readLiveRoguelike(p, pRec, runRec, storyRec);

        const visualMode = deriveVisualMode(
            p.room.key,
            p.phase,
            storyRoute,
            "locked", // 正式展厅由当前房间决定，档案里的续读点不改变章节预览。
            countProgress,
            gateReunion.completed,
        );

        return {
            storyRoute,
            countElapsedTicks,
            countDurationTicks,
            countNumber,
            countProgress,
            gateReunion,
            backCarry,
            timeScale,
            reloadSession,
            craftBench,
            archive,
            roguelike,
            assistHintsEnabled: this.assistHintsEnabled,
            visualMode,
            dataSource: "live",
            isRehearsal: false,
            rehearsalTag: "",
        };
    }

    private readLiveRoguelike(
        p: Play,
        pRec: Record<string, unknown> | undefined,
        runRec: Record<string, unknown> | undefined,
        storyRec: Record<string, unknown> | undefined,
    ): RoguelikeSnapshot {
        const roomKey = p.room.key;
        const isEscort = roomKey.indexOf("escort") === 0;
        const campChapter = p.room.campaign?.chapter;
        const isCampaignRun = p.isCampaign && (campChapter === "S" || campChapter === "C");

        const rawOffers = p.getStoryTalentOffers();
        const offers: string[] = [];
        let i = 0;
        for (i = 0; i < rawOffers.length; i++) {
            offers.push(rawOffers[i]);
        }
        if (offers.length === 0 && p.run.trial !== undefined && p.run.trial.offers.length > 0) {
            for (i = 0; i < p.run.trial.offers.length; i++) {
                offers.push(p.run.trial.offers[i]);
            }
        }

        const ranks: Record<string, number> = { vitality: 0, reload: 0, guard: 0, craft: 0 };
        const storyRanks = p.getStoryTalentRanks();
        const fallbackStoryRanks = asRecord(asRecord(storyRec !== undefined ? storyRec["talents"] : undefined)?.["ranks"]);
        const srcRanks: Record<string, unknown> | undefined = storyRanks !== undefined
            ? (storyRanks as unknown as Record<string, unknown>)
            : (p.run.trial !== undefined
                ? (p.run.trial.ranks as unknown as Record<string, unknown>)
                : fallbackStoryRanks);
        let totalRanks = 0;
        if (srcRanks !== undefined) {
            for (const k in srcRanks) {
                const v = srcRanks[k];
                if (typeof v === "number" && v > 0) {
                    ranks[k] = v;
                    totalRanks += v;
                }
            }
        }

        const inv = p.run.inventory;
        const supplies: Record<string, number> = {
            wood: inv.wood ?? 0,
            bell: inv.bell ?? 0,
            shield: inv.shield ?? 0,
            wedge: inv.wedge ?? 0,
            ammo: inv.ammo ?? 0,
            scrap: inv.scrap ?? 0,
            pass: inv.pass ?? 0,
            quickbelt: inv.quickbelt ?? 0,
        };

        const clearedSegs = asRecord(storyRec !== undefined ? storyRec["segments"] : undefined) as Record<string, boolean> | undefined;
        let stages: RoguelikeStageNode[] = [];
        let showRouteTrack = false;
        if (isEscort) {
            stages = buildStageNodes(ESCORT_STAGE_SPECS, roomKey, clearedSegs);
            showRouteTrack = true;
        } else if (isCampaignRun) {
            stages = buildStageNodes(CAMPAIGN_STAGE_SPECS, roomKey);
            showRouteTrack = true;
        }

        const explicitActive = readBool(pRec, "roguelikeActive") === true
            || readBool(runRec, "roguelikeActive") === true;
        const active = explicitActive || isEscort || isCampaignRun || offers.length > 0 || totalRanks > 0;

        const talentLabelHints: Record<string, string> = {};
        const rawMeta = asRecord(pRec !== undefined ? pRec["talentMeta"] : undefined)
            ?? asRecord(runRec !== undefined ? runRec["talentMeta"] : undefined);
        if (rawMeta !== undefined) {
            for (const k in rawMeta) {
                const v = rawMeta[k];
                if (typeof v === "string") {
                    talentLabelHints[k] = v;
                } else {
                    const obj = asRecord(v);
                    const n = readStr(obj, "name");
                    const d = readStr(obj, "desc");
                    if (n !== undefined) {
                        talentLabelHints[k] = d !== undefined && d !== "" ? (n + "·" + d) : n;
                    }
                }
            }
        }

        const reloadTicksNow = computeDerivedReloadTicks(ranks, supplies);
        const invulnTicksNow = computeDerivedInvulnTicks(ranks);
        const craftTicksNow = computeDerivedCraftTicks(ranks);

        return {
            active,
            showRouteTrack,
            seed: p.run.seed,
            ticks: p.run.ticks,
            routeTag: p.run.route,
            roomKey,
            offers,
            ranks,
            totalRanks,
            hp: p.hp,
            maxHp: p.maxHp,
            reloadTicksNow,
            invulnTicksNow,
            craftTicksNow,
            activeReloadTicks: readNum(pRec, "reloadT") ?? 0,
            activeInvulnTicks: readNum(pRec, "invulnT") ?? 0,
            activeCraftTicks: readNum(pRec, "craftT") ?? 0,
            equippedWeapon: p.equippedWeapon !== "" ? p.equippedWeapon : "standard_gun",
            supplies,
            stages,
            talentLabelHints,
        };
    }

    private readLiveCraftBench(
        cbRec: Record<string, unknown> | undefined,
        pRec: Record<string, unknown> | undefined,
        runRec: Record<string, unknown> | undefined,
    ): CraftBenchSnapshot {
        const recipes = defaultRecipes();
        if (cbRec !== undefined && Array.isArray(cbRec["recipes"])) {
            const rawList = cbRec["recipes"] as unknown[];
            const parsed: CraftRecipeView[] = [];
            let i = 0;
            for (i = 0; i < rawList.length; i++) {
                const item = asRecord(rawList[i]);
                if (item === undefined) {
                    continue;
                }
                const id = readStr(item, "id");
                const name = readStr(item, "name");
                if (id === undefined || name === undefined) {
                    continue;
                }
                parsed.push({
                    id,
                    name,
                    desc: readStr(item, "desc") ?? "",
                    enhancedEffect: parseReloadEffect(item["enhancedEffect"]),
                    cost: readNumMap(item, "cost") ?? {},
                    crafted: readBool(item, "crafted") ?? false,
                });
            }
            if (parsed.length > 0) {
                return {
                    active: readBool(cbRec, "active") ?? false,
                    firstCraftDone: readBool(cbRec, "firstCraftDone") ?? false,
                    justCraftedTimer: readNum(cbRec, "justCraftedTimer") ?? 0,
                    inventory: readNumMap(cbRec, "inventory") ?? readNumMap(pRec, "inventory") ?? {},
                    recipes: parsed,
                    equippedWeapon: readStr(cbRec, "equippedWeapon") ?? readStr(pRec, "equippedWeapon") ?? "standard_gun",
                };
            }
        }
        return {
            active: readBool(cbRec, "active") ?? false,
            firstCraftDone: readBool(cbRec, "firstCraftDone") ?? false,
            justCraftedTimer: readNum(cbRec, "justCraftedTimer") ?? 0,
            inventory: readNumMap(cbRec, "inventory") ?? readNumMap(pRec, "inventory") ?? readNumMap(runRec, "craftInventory") ?? {},
            recipes,
            equippedWeapon: readStr(cbRec, "equippedWeapon") ?? readStr(pRec, "equippedWeapon") ?? "standard_gun",
        };
    }

    private readLiveArchive(p: Play): ArchiveSnapshot {
        const pRec = asRecord(p);
        const runRec = asRecord(p.run);
        const archRec = asRecord(pRec !== undefined ? pRec["archive"] : undefined)
            ?? asRecord(runRec !== undefined ? runRec["archive"] : undefined);

        const childCleared = readBool(archRec, "childCleared") ?? readBool(pRec, "childCleared") ?? false;
        const soldierCleared = readBool(archRec, "soldierCleared") ?? readBool(pRec, "soldierCleared") ?? false;
        const artifactOwned = readBool(archRec, "artifactOwned") ?? readBool(pRec, "artifactOwned") ?? false;
        const rawPhase = archRec !== undefined && archRec["museumPhase"] !== undefined
            ? archRec["museumPhase"]
            : (pRec !== undefined ? pRec["museumPhase"] : undefined);
        let museumPhase = parseMuseumPhase(rawPhase);
        const museumSeen = readBool(archRec, "museumSeen") ?? readBool(pRec, "museumSeen") ?? false;

        // 兼容后端 C 单（story-c-archive）：
        // 1. 序章双通关后后端通过 p.wellOpen=true / phase="prologue-well" 开放井口，此时 archive.museumPhase 仍为 "locked"；
        // 2. 进入独立 MUSEUM_ROOM（room.key === "museum"）后由后端 phase 驱动四步返场：
        //    - museum-cabinet（首次进馆保留 well_reflect 匹配剪辑，之后进 hall_walk）
        //    - museum-hall / museum-lamp（自由步行走过玻璃柜与末厅）
        //    - museum-return（已转西窗灯，步行回柜边）
        //    - museum-knock / museum-done（两声轻敲 + 补线袖口回柜）
        const livePhase = p.phase as string;
        if (p.room.key === "museum") {
            if (livePhase === "museum-cabinet") {
                museumPhase = museumPhase === "well_reflect" ? "well_reflect" : "hall_walk";
            } else if (livePhase === "museum-hall" || livePhase === "museum-lamp") {
                museumPhase = "hall_walk";
            } else if (livePhase === "museum-return") {
                museumPhase = "lamp_turn";
            } else if (livePhase === "museum-knock" || livePhase === "museum-done") {
                museumPhase = "return_cabinet";
            }
        } else if (p.room.key === "prologue" && museumPhase === "locked" && childCleared && soldierCleared && !museumSeen) {
            const backendWellOpen = readBool(pRec, "wellOpen") === true;
            const hasBackendWell = readNum(pRec, "wellX") !== undefined;
            if (backendWellOpen || livePhase === "prologue-well" || (artifactOwned && hasBackendWell)) {
                museumPhase = "well_open";
            }
        }

        return {
            childCleared,
            soldierCleared,
            artifactOwned,
            museumPhase,
            museumSeen,
        };
    }

    private forwardLiveIntent(p: Play, intent: FrontendIntent): boolean {
        if (intent.kind === "craftSubmit") {
            if (this.livePendingCraftRequests[intent.requestId] === true) {
                return false;
            }
            this.livePendingCraftRequests[intent.requestId] = true;
        }
        const pRec = asRecord(p);
        if (pRec === undefined) {
            return false;
        }
        const handler = pRec["submitFeIntent"];
        if (typeof handler === "function") {
            const fn = handler as (self: Play, req: Record<string, unknown>) => unknown;
            const result = fn(p, intent as unknown as Record<string, unknown>);
            if (result !== false) {
                return true;
            }
            // 兼容后端 C 单（story-c-archive）submitFeIntent({ kind: "wellPick" })
            if (intent.kind === "museumInteract" && intent.target === "well_pickup") {
                const wellRes = fn(p, { kind: "wellPick" });
                return wellRes !== false;
            }
            return false;
        }
        if (intent.kind === "chooseTalent") {
            const choose = pRec["chooseTalent"];
            if (typeof choose === "function") {
                return (choose as (self: Play, slot: number) => boolean)(p, intent.slot) === true;
            }
        }
        // 兼容 B1 后端已落地的 reloadTapNode(node) 入口
        const tapNode = pRec["reloadTapNode"];
        if (typeof tapNode === "function") {
            const fn = tapNode as (self: Play, node: number) => void;
            if (intent.kind === "reloadTapNode") {
                fn(p, intent.node);
                return true;
            }
            if (intent.kind === "reloadPathCommit" && intent.path.length > 0) {
                let i = 0;
                for (i = 0; i < intent.path.length; i++) {
                    if (i === 0 && intent.path[i] === 0) {
                        continue;
                    }
                    fn(p, intent.path[i]);
                }
                return true;
            }
        }
        return false;
    }

    // ==================== 排演模式独立内存状态机 ====================

    private sampleRehearsal(p: Play, dt: number, input: Input, st: RehearsalState): DualRouteSnapshot {
        const countElapsedTicks = st.countTickOverride !== undefined ? st.countTickOverride : p.countTick;
        const countDurationTicks = Math.max(1, st.countDurationOverride ?? GATE_COUNT_END);
        const countNumber = gateCountAtTick(countElapsedTicks);
        const countProgress = Math.max(0, Math.min(1, countElapsedTicks / countDurationTicks));

        // 排演风台长按重逢推进（遵循 1439 预按须松开再按、0.6s 满时锁一次、中途松手归零重试）
        if (p.room.key === "gate" && p.phase === "gate-count" && st.storyRoute === "soldier") {
            if (countElapsedTicks < countDurationTicks) {
                st.gateReunion.active = false;
                st.gateReunion.knockHeard = false;
                st.gateReunion.holding = false;
                st.gateReunion.holdProgress = 0;
                st.gateHoldArmed = !input.interact.held;
                st.gatePrevInteractHeld = input.interact.held;
            } else if (!st.gateReunion.completed) {
                st.gateReunion.active = true;
                st.gateReunion.knockHeard = true;
                if (!st.gateHoldArmed && !input.interact.held) {
                    st.gateHoldArmed = true;
                }
                if (dt > 0) {
                    if (st.gateHoldArmed && input.interact.held) {
                        st.gateReunion.holding = true;
                        st.gateReunion.holdProgress = Math.min(
                            1,
                            st.gateReunion.holdProgress + dt / GATE_REUNION_HOLD_SECONDS,
                        );
                        if (st.gateReunion.holdProgress >= 1) {
                            st.gateReunion.holdProgress = 1;
                            st.gateReunion.holding = false;
                            st.gateReunion.completed = true;
                            st.backCarry.handInHand = true;
                        }
                    } else {
                        if (st.gateReunion.holding && st.gateReunion.holdProgress > 0 && st.gateReunion.holdProgress < 1) {
                            st.gateReunion.releasedAbortCount += 1;
                        }
                        st.gateReunion.holding = false;
                        st.gateReunion.holdProgress = 0;
                    }
                }
                st.gatePrevInteractHeld = input.interact.held;
            }
        }

        // 排演换弹全速倒计时推进（暂停时 dt === 0 自动冻结）
        if (st.reloadSession.active && dt > 0) {
            st.reloadSession.elapsed += dt;
            if (st.reloadSession.invalidFlash > 0) {
                st.reloadSession.invalidFlash = Math.max(0, st.reloadSession.invalidFlash - dt);
            }
            if (st.reloadSession.elapsed >= st.reloadSession.duration) {
                st.reloadSession.active = false;
                st.reloadSession.elapsed = 0;
                st.reloadSession.path = [];
                st.reloadSession.previewEffect = "normal";
                st.reloadSession.nextEffect = "normal";
                st.reloadSession.firstTime = false;
                st.timeScaleOverride = undefined;
            }
        }

        // 排演工台首次试握计时衰减
        if (st.craftBench.justCraftedTimer > 0 && dt > 0) {
            st.craftBench.justCraftedTimer = Math.max(0, st.craftBench.justCraftedTimer - dt);
        }

        const baseScale = st.timeScaleOverride !== undefined
            ? Math.max(0, st.timeScaleOverride)
            : (st.reloadSession.active ? DEFAULT_SLOW_TIME_SCALE : 1);
        const timeScale = st.timeScaleOverride !== undefined
            ? baseScale
            : Math.min(baseScale, this.liveFocusTimeScale);

        const visualMode = deriveVisualMode(
            p.room.key,
            p.phase,
            st.storyRoute,
            st.archive.museumPhase,
            countProgress,
            st.gateReunion.completed,
        );

        return {
            storyRoute: st.storyRoute,
            countElapsedTicks,
            countDurationTicks,
            countNumber,
            countProgress,
            gateReunion: {
                active: st.gateReunion.active,
                knockHeard: st.gateReunion.knockHeard,
                holdProgress: st.gateReunion.holdProgress,
                holding: st.gateReunion.holding,
                completed: st.gateReunion.completed,
                releasedAbortCount: st.gateReunion.releasedAbortCount,
            },
            backCarry: {
                active: st.backCarry.active,
                handInHand: st.backCarry.handInHand,
                mounting: st.backCarry.mounting,
                atBench: st.backCarry.atBench,
            },
            timeScale,
            reloadSession: {
                active: st.reloadSession.active,
                firstTime: st.reloadSession.firstTime,
                elapsed: st.reloadSession.elapsed,
                duration: st.reloadSession.duration,
                path: st.reloadSession.path.slice(),
                previewEffect: st.reloadSession.previewEffect,
                nextEffect: st.reloadSession.nextEffect,
                invalidFlash: st.reloadSession.invalidFlash,
            },
            craftBench: {
                active: st.craftBench.active,
                firstCraftDone: st.craftBench.firstCraftDone,
                justCraftedTimer: st.craftBench.justCraftedTimer,
                inventory: cloneRecordNum(st.craftBench.inventory),
                recipes: cloneRecipes(st.craftBench.recipes),
                equippedWeapon: st.craftBench.equippedWeapon,
            },
            archive: {
                childCleared: st.archive.childCleared,
                soldierCleared: st.archive.soldierCleared,
                artifactOwned: st.archive.artifactOwned,
                museumPhase: st.archive.museumPhase,
                museumSeen: st.archive.museumSeen,
            },
            roguelike: cloneRoguelike(st.roguelike),
            assistHintsEnabled: this.assistHintsEnabled,
            visualMode,
            dataSource: "rehearsal",
            isRehearsal: true,
            rehearsalTag: st.tag,
        };
    }

    private applyRehearsalIntent(st: RehearsalState, intent: FrontendIntent): boolean {
        if (intent.kind === "gateReunionHold") {
            if (!st.gateReunion.active || st.gateReunion.completed) {
                return false;
            }
            if (!intent.holding && st.gateReunion.holding && st.gateReunion.holdProgress > 0 && st.gateReunion.holdProgress < 1) {
                st.gateReunion.releasedAbortCount += 1;
                st.gateReunion.holdProgress = 0;
            }
            st.gateReunion.holding = intent.holding;
            return true;
        }
        if (intent.kind === "reloadOpen") {
            this.triggerMockReload(true);
            return true;
        }
        if (intent.kind === "reloadTapNode") {
            if (!st.reloadSession.active) {
                return false;
            }
            if (st.reloadSession.path.length === 0) {
                st.reloadSession.path.push(0);
            }
            if (st.reloadSession.path.indexOf(intent.node) >= 0) {
                st.reloadSession.invalidFlash = 0.35;
                st.reloadSession.path = [0];
                st.reloadSession.previewEffect = "normal";
                return false;
            }
            st.reloadSession.path.push(intent.node);
            st.reloadSession.previewEffect = deriveReloadEffectFromPath(st.reloadSession.path);
            if (intent.node === 8) {
                st.reloadSession.nextEffect = st.reloadSession.previewEffect;
                st.reloadSession.active = false;
                st.reloadSession.elapsed = 0;
                st.reloadSession.path = [];
                st.reloadSession.firstTime = false;
                st.timeScaleOverride = undefined;
            }
            return true;
        }
        if (intent.kind === "reloadPathPreview") {
            if (!st.reloadSession.active) {
                return false;
            }
            st.reloadSession.path = intent.path.slice();
            st.reloadSession.previewEffect = deriveReloadEffectFromPath(intent.path);
            return true;
        }
        if (intent.kind === "reloadPathCommit") {
            if (!st.reloadSession.active) {
                return false;
            }
            if (intent.path.length < 2) {
                st.reloadSession.invalidFlash = 0.35;
                st.reloadSession.path = [];
                st.reloadSession.previewEffect = "normal";
                return false;
            }
            const effect = deriveReloadEffectFromPath(intent.path);
            st.reloadSession.nextEffect = effect;
            st.reloadSession.previewEffect = effect;
            st.reloadSession.path = [];
            st.reloadSession.active = false;
            st.reloadSession.elapsed = 0;
            st.reloadSession.firstTime = false;
            st.timeScaleOverride = undefined;
            return true;
        }
        if (intent.kind === "reloadCancel") {
            st.reloadSession.active = false;
            st.reloadSession.elapsed = 0;
            st.reloadSession.path = [];
            st.reloadSession.previewEffect = "normal";
            st.timeScaleOverride = undefined;
            return true;
        }
        if (intent.kind === "craftSubmit") {
            if (!st.craftBench.active || st.handledCraftRequestIds[intent.requestId] === true) {
                return false;
            }
            let target: CraftRecipeView | undefined;
            let i = 0;
            for (i = 0; i < st.craftBench.recipes.length; i++) {
                if (st.craftBench.recipes[i].id === intent.recipeId) {
                    target = st.craftBench.recipes[i];
                    break;
                }
            }
            if (target === undefined || target.crafted) {
                return false;
            }
            for (const mat in target.cost) {
                if ((st.craftBench.inventory[mat] ?? 0) < target.cost[mat]) {
                    return false;
                }
            }
            for (const mat in target.cost) {
                st.craftBench.inventory[mat] = (st.craftBench.inventory[mat] ?? 0) - target.cost[mat];
            }
            st.handledCraftRequestIds[intent.requestId] = true;
            target.crafted = true;
            st.craftBench.equippedWeapon = target.id;
            st.craftBench.justCraftedTimer = st.craftBench.firstCraftDone ? 0.45 : 1.0;
            st.craftBench.firstCraftDone = true;
            return true;
        }
        if (intent.kind === "craftEquip") {
            st.craftBench.equippedWeapon = intent.weaponId;
            return true;
        }
        if (intent.kind === "craftClose") {
            st.craftBench.active = false;
            st.backCarry.atBench = false;
            return true;
        }
        if (intent.kind === "museumInteract") {
            if (intent.target === "well_pickup" && st.archive.museumPhase === "well_open") {
                st.archive.artifactOwned = true;
                st.archive.museumPhase = "well_reflect";
                return true;
            }
            if (intent.target === "enter_hall" && st.archive.museumPhase === "well_reflect") {
                st.archive.museumPhase = "hall_walk";
                return true;
            }
            if (intent.target === "lamp_turn" && st.archive.museumPhase === "hall_walk") {
                st.archive.museumPhase = "lamp_turn";
                return true;
            }
            if (intent.target === "begin_return_cabinet" && st.archive.museumPhase === "lamp_turn") {
                st.archive.museumPhase = "return_cabinet";
                return true;
            }
            if (intent.target === "return_cabinet") {
                st.archive.museumPhase = "done";
                st.archive.museumSeen = true;
                return true;
            }
            return false;
        }
        if (intent.kind === "chooseTalent") {
            const rg = st.roguelike;
            const id = rg.offers[intent.slot];
            if (id === undefined) {
                return false;
            }
            rg.ranks[id] = (rg.ranks[id] ?? 0) + 1;
            rg.totalRanks += 1;
            if (id === "vitality") {
                rg.maxHp += 1;
                rg.hp += 1;
            }
            rg.offers = [];
            rg.reloadTicksNow = computeDerivedReloadTicks(rg.ranks, rg.supplies);
            rg.invulnTicksNow = computeDerivedInvulnTicks(rg.ranks);
            rg.craftTicksNow = computeDerivedCraftTicks(rg.ranks);
            return true;
        }
        return false;
    }
}
