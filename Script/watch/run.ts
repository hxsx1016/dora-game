/**
 * 跨房运行态：一局从 S1 到 C2 只保留一份。
 *
 * 只放必须跨房存活的东西：种子、有效玩法拍、路线、背包、机关与破坏状态、
 * 已拾取物、同伴是否已汇合、检查点。房间几何与敌兵属于房间数据，不进这里。
 */

/** 背包：1 个战具格 + 2 个消耗品格。 */
export interface Inventory {
    /** 战具格：残盾，架设后挡一发。 */
    shield: number;
    /** 消耗：木楔，给完好薄木挡多一次承击。 */
    wedge: number;
    /** 消耗：备用弹包，立即完成当前装填。 */
    ammo: number;
    /** 消耗：护送号牌，示意小满等候 / 跟上。 */
    pass: number;
    /** 消耗：快装带，永久缩短装填。 */
    quickbelt: number;
    /** 材料：废木料，制木楔的原料。不占消耗品格。 */
    scrap: number;
    /** 材料：木纹筹，工台改制引路灯铳（2）或回声铳（1）。不占格。 */
    wood: number;
    /** 材料：铃纹筹，工台改制回声铳（1）。不占格。 */
    bell: number;
}

export interface PropState {
    broken: boolean;
    hp: number;
    wedge: boolean;
    /** 机关已打开（窗板放下 / 木帘落下），初始隐藏的实体现在在场。 */
    revealed?: boolean;
}

export type RouteTag = "outer" | "drygoods" | "";

/** 双通关档案：C 单接收的结局结果；跨局持久化由 C 单落盘。 */
export type MuseumPhase = "locked" | "well_open" | "well_reflect" | "hall_walk" | "lamp_turn" | "return_cabinet" | "done";
export const MUSEUM_PHASES: readonly MuseumPhase[] = ["locked", "well_open", "well_reflect", "hall_walk", "lamp_turn", "return_cabinet", "done"];

export function isMuseumPhase(value: string): value is MuseumPhase {
    let i = 0;
    for (i = 0; i < MUSEUM_PHASES.length; i++) {
        if (MUSEUM_PHASES[i] === value) {
            return true;
        }
    }
    return false;
}

export interface ArchiveState {
    childCleared: boolean;
    soldierCleared: boolean;
    artifactOwned: boolean;
    /** 0=未进馆；1..7=馆内步骤；8=已离馆。 */
    museumPhase: MuseumPhase;
    museumSeen: boolean;
}

export function createArchive(): ArchiveState {
    return { childCleared: false, soldierCleared: false, artifactOwned: false, museumPhase: "locked", museumSeen: false };
}

/**
 * 正式剧情的结局路线：与房内岔路 RouteTag 分开。
 * child = 小满带伤送别后自己数完出城；soldier = 守住 80% 血量门槛后长按牵手。
 * 空串表示还没过门锁线。
 */
export type StoryRoute = "child" | "soldier" | "";

/** 检查点快照：库存、装备、已改制与背负，制前 / 制后各记一份。 */
export interface CheckpointSnap {
    id: number;
    wood: number;
    bell: number;
    scrap: number;
    wedge: number;
    ammo: number;
    shield: number;
    pass: number;
    quickbelt: number;
    crafted: string;
    equipped: string;
    carry: boolean;
}

/**
 * 正式剧情跨房状态：周戍血量与上限、过门锁存、风台演出快照。
 *
 * 只放必须在房间之间活下来的东西；房间几何与敌兵仍属房间数据。
 * 演出快照（phase/countTick/phaseTick/handTicks）只在同名房间重试或续读时启用，
 * 切到别的房间一律从新房间的默认阶段开始。
 */
export interface StoryState {
    route: StoryRoute;
    /** 周戍当前血量，跨房继承；新房不得满血重算。 */
    hp: number;
    /** 周戍血量上限，扩容后按比例判定门槛。 */
    maxHp: number;
    /** 殿后最后一拍伤害结算后的锁存血量；-1 表示还没锁线。 */
    hpAtGate: number;
    /** 锁存时点的上限；上限为正时 100*hpAtGate >= 80*maxHpAtGate 走 soldier。 */
    maxHpAtGate: number;
    /** 已锁线（小满已安全过门）。锁线后重试/切房都不重算。 */
    settled: boolean;
    /** 风台演出快照：所在阶段与计数拍。 */
    phase: string;
    countTick: number;
    phaseTick: number;
    handTicks: number;
    /** 牵手已完成，台词只一次。 */
    handDone: boolean;
    lineSaid: boolean;
    /** 牵手演出已完成后的同行段标记。 */
    tied: boolean;
    /** 男主线：小满已背在背上；背负只有一套移动与受击碰撞。 */
    carry: boolean;
    /** 第一段护送房已走到安全出口。 */
    escortDone: boolean;
    /** 从博物馆回柜边的一次性标记：跨房传递后由序章消费。 */
    museumReturn: boolean;
    /** 已在第三段工台做出的武器 id；空串表示还没做。 */
    craftedWeapon: string;
    /** 当前装备的武器 id（支持标准铳、工台改制武器及双通关时间穿梭器）。 */
    equippedWeapon: string;
    /** 结局：reunion=北塔团圆；lamp=小满留灯；空串表示还没落幕。 */
    ending: string;
    /** 最近一次检查点快照；切房/重试时随 run 一起带走。 */
    cp?: CheckpointSnap;
    /** 已走出的段出口：每段只结算一次，重试/回访不重复记。 */
    segments: Record<string, boolean>;
}

export function createStory(hp: number = 3, maxHp: number = 3): StoryState {
    return {
        route: "",
        hp: hp,
        maxHp: maxHp,
        hpAtGate: -1,
        maxHpAtGate: -1,
        settled: false,
        phase: "",
        countTick: 0,
        phaseTick: 0,
        handTicks: 0,
        handDone: false,
        lineSaid: false,
        tied: false,
        carry: false,
        museumReturn: false,
        escortDone: false,
        craftedWeapon: "",
        equippedWeapon: "",
        ending: "",
        cp: undefined,
        segments: {},
    };
}

export type Talent = "vitality" | "reload" | "guard" | "craft";
export const talentNames: Record<Talent, string> = {
    vitality: "厚甲·体力+1", reload: "熟铳·装填减6拍", guard: "护身·受击保护加12拍", craft: "巧手·制楔减6拍",
};

export interface Trial {
    randomState: number;
    hp: number;
    lost: boolean;
    ranks: Record<Talent, number>;
    offers: Talent[];
    room: string;
}

export function createTrial(seed: number): RunState {
    const run = createRun(seed, "trial");
    run.trial = { randomState: 1 + Math.floor(Math.abs(seed)) % 2147483646, hp: 3, lost: false,
        ranks: { vitality: 0, reload: 0, guard: 0, craft: 0 }, offers: [], room: "" };
    return run;
}

export function draftRoom(trial: Trial, room: string): void {
    if (trial.room === room) return;
    trial.room = room;
    const pool: Talent[] = ["vitality", "reload", "guard", "craft"];
    trial.offers = [];
    while (trial.offers.length < 3) {
        trial.randomState = (trial.randomState * 48271) % 2147483647;
        const index = Math.floor(trial.randomState / 2147483647 * pool.length);
        trial.offers.push(pool.splice(index, 1)[0]);
    }
}

/** 本局从哪来：official=标题「新的旅程」，chapter=章节直达，debug=数字快跳/验收夹具，trial=标题试炼。 */
export type RunSource = "official" | "chapter" | "debug" | "trial";

export interface RunState {
    trial?: Trial;
    /** 开局来源：只有 official 的结局写通关档案。 */
    source: RunSource;
    seed: number;
    /** 有效玩法拍：只在本房处于可控玩法时累加，暂停与切换不累加。 */
    ticks: number;
    /** 各段有效拍，用于章末逐段对预算。 */
    roomTicks: Record<string, number>;
    /** 进入当前段的累计拍，用于算本段用时。 */
    roomEnterTick: number;
    route: RouteTag;
    inventory: Inventory;
    /** 按场景件 id 存：碎了、还剩几次、是否加固。 */
    props: Record<string, PropState>;
    /** 已拾取的掉落 id，避免切房回来重复出现。 */
    taken: Record<string, boolean>;
    /** 小满是否已经汇合（放板 / 抬闩 / 推车后）。 */
    joined: boolean;
    /** 侧门闩 / 棚尾连杆是否已抬。 */
    c1Latch: boolean;
    c2Latch: boolean;
    /** 已提交的检查点序号。 */
    checkpoint: number;
    /** 本轮是否已经完成 C2 灰盒。 */
    finished: boolean;
    /** 正式剧情的跨房状态（血量、过门锁线、风台演出快照）。 */
    story: StoryState;
    /** 双通关档案：B2 结局写入，C 单读取后落盘。 */
    archive: ArchiveState;
    /** 试玩记录：每次进房、达成目标、拾取都留一行。 */
    log: string[];
}

/**
 * 开一局。`archive` 传入跨局档案（标题开局与片尾再玩都指向同一份），
 * 不传则新建一份（试炼、章节直达、调试与测试默认各局独立）。
 */
export function createRun(seed: number = 20261124, source: RunSource = "debug",
                          archive: ArchiveState = createArchive()): RunState {
    return {
        source: source,
        seed: seed,
        ticks: 0,
        roomTicks: {},
        roomEnterTick: 0,
        route: "",
        inventory: { shield: 0, wedge: 0, ammo: 0, pass: 0, quickbelt: 0, scrap: 0, wood: 0, bell: 0 },
        props: {},
        taken: {},
        joined: false,
        c1Latch: false,
        c2Latch: false,
        checkpoint: 0,
        finished: false,
        story: createStory(),
        archive: archive,
        log: [],
    };
}

/** 60 拍 = 1 秒；给 HUD 与交付记录用。 */
export function seconds(ticks: number): number {
    return Math.round(ticks / 60 * 10) / 10;
}

export function mmss(ticks: number): string {
    const total = Math.floor(ticks / 60);
    const m = Math.floor(total / 60);
    const s = total % 60;
    return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
}
