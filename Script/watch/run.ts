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
}

export interface PropState {
    broken: boolean;
    hp: number;
    wedge: boolean;
    /** 机关已打开（窗板放下 / 木帘落下），初始隐藏的实体现在在场。 */
    revealed?: boolean;
}

export type RouteTag = "outer" | "drygoods" | "";

export interface RunState {
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
    latchOpen: boolean;
    /** 已提交的检查点序号。 */
    checkpoint: number;
    /** 本轮是否已经完成 C2 灰盒。 */
    finished: boolean;
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
        inventory: { shield: 0, wedge: 0, ammo: 0, pass: 0, quickbelt: 0 },
        props: {},
        taken: {},
        joined: false,
        latchOpen: false,
        checkpoint: 0,
        finished: false,
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
