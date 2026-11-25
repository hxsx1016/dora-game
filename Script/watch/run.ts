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
}

export interface PropState {
    broken: boolean;
    hp: number;
    wedge: boolean;
    /** 机关已打开（窗板放下 / 木帘落下），初始隐藏的实体现在在场。 */
    revealed?: boolean;
}

export type RouteTag = "outer" | "drygoods" | "";

/**
 * 正式剧情的结局路线：与房内岔路 RouteTag 分开。
 * child = 小满带伤送别后自己数完出城；soldier = 守住 80% 血量门槛后长按牵手。
 * 空串表示还没过门锁线。
 */
export type StoryRoute = "child" | "soldier" | "";

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
    const run = createRun(seed);
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

export interface RunState {
    trial?: Trial;
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
    /** 试玩记录：每次进房、达成目标、拾取都留一行。 */
    log: string[];
}

export function createRun(seed: number = 20261124): RunState {
    return {
        seed: seed,
        ticks: 0,
        roomTicks: {},
        roomEnterTick: 0,
        route: "",
        inventory: { shield: 0, wedge: 0, ammo: 0, pass: 0, quickbelt: 0, scrap: 0 },
        props: {},
        taken: {},
        joined: false,
        c1Latch: false,
        c2Latch: false,
        checkpoint: 0,
        finished: false,
        story: createStory(),
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
