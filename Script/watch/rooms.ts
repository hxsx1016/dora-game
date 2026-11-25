/**
 * D1 灰盒坐标：世界单位，与《守望-逐日开发与代码实现逻辑》第五、六节逐字对齐。
 *
 * 1 世界单位 ≈ 1.84 cm（小满 64 = 1.18 m，周戍 88 = 1.62 m）。
 * 车轴就是车身中心，车身半宽 24，所以停车后左沿 = 432 − 24 = 408，
 * 与小满右沿 402 之间留 6 单位净空——这条在城外剖面上要看得见。
 */
import { DepthLane, LANE_DEPTH, LANE_ROAD, laneFootprints } from "Script/watch/depth";

export interface FloorSpec {
    y: number;
    x0: number;
    x1: number;
}

/** 地面前后坐标，min 靠玩家、max 靠远景。y 始终表示离地高度。 */
export interface DepthRange {
    min: number;
    max: number;
}

/** 新版关卡的可破坏与可交互件种类。 */
export type PropKind =
    | "thin_wood" | "basket_wall" | "curtain" | "window_board" | "latch" | "grain_sack" | "well";

export interface BreakSpec {
    kind: PropKind;
    /** 未加固时承受的命中次数；归零后碎裂，碰撞与遮挡同拍撤下。 */
    hp: number;
    /** 木楔加固后多承受的次数，每件只能加固一次。 */
    wedgeHp?: number;
    /** 能不能钉木楔加固。缺省可以；写成 false 表示这件东西钉不上。 */
    wedgeable?: boolean;
}

export interface InteractSpec {
    /** open_board 放窗板、lower_curtain 放木帘、raise_latch 抬门闩。 */
    kind: "open_board" | "lower_curtain" | "raise_latch";
    /** 交互半径，默认 40。 */
    reach?: number;
}

export interface PickupSpec {
    id: string;
    kind: "shield" | "wedge" | "ammo" | "pass" | "quickbelt" | "scrap";
    x: number;
    y: number;
    depth?: number;
    label: string;
}

/** 小满在本房的等待与汇合点；缺省时一直跟随。 */
export interface CompanionSpec {
    waitX?: number;
    waitDepth?: number;
    joinX?: number;
    /** 完成这个机关后她才离开等待点。 */
    followAfter?: "open_board" | "lower_curtain" | "raise_latch";
}

export interface CampaignSpec {
    chapter: "S" | "C" | "G" | "O" | "V" | "F" | "T";
    act: number;
    /** 设计预算秒数，只用于 HUD 对照，不强制等待。 */
    budget: number;
    /** 本段结束条件。 */
    goal: "reach_exit" | "dock_cart" | "raise_latch";
    next?: string;
    exitX: number;
    /** 检查点序号；进入本段时提交。 */
    checkpoint?: number;
}

export interface SolidSpec {
    x: number;
    w: number;
    h: number;
    y: number;
    label: string;
    /** 编辑关卡时优先用档位。非相邻档位会分成独立的实体。 */
    lanes?: readonly DepthLane[];
    /** 自定义占地或由档位算出的实体范围。缺省时横跨整条道路。 */
    depth?: DepthRange;
    /** 布料、小植被一类软布景，只参与绘制和遮挡。 */
    decorative?: boolean;
    /** 破坏与机关状态靠 id 跨房保留。 */
    id?: string;
    breakable?: BreakSpec;
    interact?: InteractSpec;
    art?: "cover_wood" | "cover_stone" | "fence" | "wall" | "gate_post"
        | "thin_wood" | "basket_wall" | "curtain" | "board" | "latch" | "grain_sack" | "well";
    /** 低矮植被等：只挡撞头不做水平阻挡，蹲行与走过都能穿过。 */
    passable?: boolean;
    /** 布帘、窗纸一类：挡视线与子弹，但不挡人、车和碎屑。 */
    soft?: boolean;
    /** 机关未打开前不参与碰撞与绘制（卷起的帘、背后的窗板）。 */
    hidden?: boolean;
}

export interface ZoneSpec {
    x0: number;
    x1: number;
    y: number;
    h: number;
    tint: number;
    label: string;
}

export interface ArchSpec {
    x0: number;
    x1: number;
    y: number;
    h: number;
    label: string;
}

export interface StairSpec {
    x0: number;
    x1: number;
    y0: number;
    y1: number;
    steps: number;
    label: string;
}

export interface CartSpec {
    /** 车轴起点（世界 x）。 */
    startX: number;
    /** 车轴终点。 */
    endX: number;
    /** 车所在的地面高度。 */
    baseY: number;
    /** 车辙所在的地面纵深，默认为道路中间。 */
    depth?: number;
    /** 车身宽（车轴到沿 = bodyW / 2）。 */
    bodyW: number;
    bodyH: number;
    wheelR: number;
    /** 外侧手柄相对车轴的偏移，负=左、正=右。 */
    handleOffset: number;
    /** 红布系在哪一侧，负=左、正=右。 */
    clothSide: number;
}

export interface SpawnSpec {
    x: number;
    y: number;
    h: number;
    label: string;
    depth?: number;
    /** 新版关卡：火器手 / 持盾手 / 破障手 / 侧线带队者。 */
    kind?: "gunner" | "shield" | "breaker" | "leader";
    /** 盾的耐久；盾完整倒地才掉残盾。 */
    shieldHp?: number;
    /** 击倒时掉什么；缺省按 kind 推断。 */
    drop?: "shield" | "wedge" | "ammo" | "pass" | "quickbelt" | "none";
}

export interface MarkSpec {
    x: number;
    y: number;
    kind: number;
    label: string;
}

export interface DimSpec {
    x0: number;
    x1: number;
    text: string;
}

/** 拾荒者：巡逻段、听觉、赶来与停留。 */
export interface ScavSpec {
    x0: number;
    x1: number;
    y: number;
    h: number;
    patrolSpeed: number;
    approachSpeed: number;
    /** 听见声音后原地转头多少拍。 */
    hearTicks: number;
    /** 到落点后停多少拍。 */
    stallTicks: number;
    /** 听觉半径。 */
    range: number;
}

/** 城门守点：绞盘、门洞等待点、门边送别位与离场线。 */
export interface GateSpec {
    winchX: number;
    waitX: number;
    doorX: number;
    exitX: number;
    /** 45 秒 = 2700 拍，只累计可操作的模拟步。 */
    holdTicks: number;
}

/** 剧本段数据：与房间尺寸无关，只放这一段需要的锚点。 */
export interface StorySpec {
    /** 序章：小满藏在柜后的位置与可以递交的距离。 */
    prologue?: { giveReach: number };
    /** 城门。 */
    gate?: GateSpec;
    /** 森林里的狗：巡逻段、速度与听觉半径。 */
    dog?: { x0: number; x1: number; speed: number; range: number };
    /** 塔门：门前交互点与敲两下用的拍数。 */
    tower?: { doorX: number; knockTicks: number };
}

export interface RoomSpec {
    key: string;
    name: string;
    caption: string;
    /**
     * 段在世界地图里的起点。`rooms.ts` 里所有 x 都写段内坐标，
     * `withOrigin()` 在生成房间时统一加上它，段内锚点保持不变。
     * 例：检查站候检区宽 640，originX=640，原灰盒装卸台 768 就是世界 1408。
     */
    originX: number;
    minX: number;
    maxX: number;
    height: number;
    depth?: DepthRange;
    floors: FloorSpec[];
    solids: SolidSpec[];
    zones: ZoneSpec[];
    arch: ArchSpec;
    stairs: StairSpec[];
    cart: CartSpec;
    spawns: SpawnSpec[];
    marks: MarkSpec[];
    dims: DimSpec[];
    /** 村口：拾荒者。 */
    scavenger?: ScavSpec;
    /** 村口：瓶架上的瓶子位置。 */
    bottle?: { x: number; y: number };
    /** 村口：砖地落点。 */
    brickX?: number;
    /** 村口：软土落点。 */
    softX?: number;
    /** 村口：第一院通行线。 */
    passLine?: number;
    /** 新版关卡：本段目标、出口与预算。 */
    campaign?: CampaignSpec;
    /** 新版关卡：本段地面上的掉落物。 */
    pickups?: PickupSpec[];
    /** 新版关卡：小满的等待点与汇合点。 */
    companion?: CompanionSpec;
    /** 剧本段数据；没有这一项的房间就是纯路段。 */
    story?: StorySpec;
}

/** 检查站：周戍把车从 640 推到 768 落入 dock，再和小满一起走到出口。 */
export const CHECKPOINT_ROOM: RoomSpec = {
    key: "checkpoint",
    name: "检查站 · 候检区 640 + 原段 1000",
    caption: "先翻过队栏进候检区，再带小满走到柜台与安全点；末段按住 E + D 推车 128 单位入窝",
    // 段内坐标仍是 D1 验收过的 0–1000；整段在世界地图上右移 640，前面接 640 宽的候检区。
    originX: 640,
    minX: -640,
    maxX: 1000,
    height: 210,
    depth: LANE_ROAD,
    floors: [{ y: 0, x0: -640, x1: 1000 }],
    solids: [
        // 候检区队栏：28 高，周戍空格翻过去，小满跟随会自己跳。缺口留在 330–390（世界）。
        { x: -430, w: 180, h: 28, y: 0, label: "队栏 -430–-250 · 高 28", lanes: ["lower", "middle"] },
        // 高 44：两人跳得上去（小满 51、周戍 58），也能在柜台后蹲下躲子弹。
        { x: 240, w: 100, h: 44, y: 0, label: "柜台 240–340 · 高 44", lanes: ["lower", "middle"] },
        { x: 890, w: 36, h: 122, y: 0, label: "检查站出口门柱", lanes: ["lower", "upper"], art: "gate_post" },
    ],
    zones: [{ x0: 380, x1: 560, y: 0, h: 120, tint: 1, label: "危险段 380–560" }],
    arch: { x0: 0, x1: 0, y: 0, h: 0, label: "" },
    stairs: [],
    cart: {
        startX: 640,
        endX: 768,
        baseY: 0,
        depth: LANE_DEPTH.middle,
        bodyW: 48,
        bodyH: 26,
        wheelR: 12,
        handleOffset: -40,
        clothSide: -1,
    },
    spawns: [
        { x: -600, y: 0, h: 64, label: "小满 -600（世界 40）" },
        { x: -560, y: 0, h: 88, label: "周戍 -560（世界 80）" },
    ],
    marks: [
        { x: 264, y: 0, kind: 1, label: "安全锚 264" },
        { x: 768, y: 0, kind: 1, label: "dock 768" },
        { x: 860, y: 0, kind: 2, label: "双人出口 792–928" },
    ],
    dims: [
        { x0: 240, x1: 340, text: "柜台 100" },
        { x0: 640, x1: 768, text: "推车 128 · 左柄 E+D" },
        { x0: 792, x1: 928, text: "出口 136" },
    ],
};

/** 城外：同一剖面里同时看上层手柄与下层拱口，这是 D1 要交的那张图。 */
export const OUTSIDE_ROOM: RoomSpec = {
    key: "outside",
    name: "城外 · 台面 y=96 / 墙根 1240",
    caption: "从右柄按住 E+D 朝空窝拉 128 单位，轮子落窝后沿台面回左端跳下，蹲过 44 高的拱；洞后墙根小路走到底可看见塔灯",
    // 装卸台与拱都在原位，洞后 600–1240 是 D4 新接的墙根小路。
    originX: 0,
    minX: 0,
    maxX: 1240,
    height: 230,
    floors: [
        { y: 0, x0: 0, x1: 1240 },
        { y: 96, x0: 128, x1: 512 },
        { y: 64, x0: 820, x1: 940 },
    ],
    solids: [
        // 城墙基座：只占 96 以上，挡住台面上的玩家；下层 0–96 是通的，墙根小路就从下面穿过去。
        { x: 512, w: 88, h: 134, y: 96, label: "台面右端城墙 · 下层可通" },
        { x: 0, w: 40, h: 96, y: 0, label: "街口" },
        { x: 1200, w: 40, h: 140, y: 0, label: "墙根尽头" },
    ],
    zones: [],
    arch: { x0: 280, x1: 360, y: 0, h: 44, label: "拱 280–360 · 净高 44" },
    stairs: [
        { x0: 40, x1: 128, y0: 0, y1: 96, steps: 2, label: "石阶 0 / 48 / 96" },
        { x0: 700, x1: 820, y0: 0, y1: 64, steps: 3, label: "墙根石阶 0 / 16 / 32 / 48 / 64" },
    ],
    cart: {
        startX: 304,
        endX: 432,
        baseY: 96,
        bodyW: 48,
        bodyH: 26,
        wheelR: 12,
        handleOffset: 40,
        clothSide: -1,
    },
    spawns: [{ x: 160, y: 96, h: 64, label: "小满 160" }],
    marks: [
        { x: 432, y: 96, kind: 1, label: "空窝 432" },
        { x: 380, y: 0, kind: 0, label: "洞后检查点 380" },
        { x: 520, y: 96, kind: 3, label: "石阶光 · 回首红布" },
        { x: 820, y: 64, kind: 3, label: "墙根石阶顶 820" },
        { x: 1120, y: 64, kind: 6, label: "塔灯 1120" },
    ],
    dims: [
        { x0: 304, x1: 432, text: "拉车 128 · 右柄 E+D" },
        { x0: 128, x1: 512, text: "台面 384" },
        { x0: 280, x1: 360, text: "拱 80" },
        { x0: 600, x1: 1240, text: "墙根 640" },
    ],
};

/**
 * 村口：瓶架 112、观察位 160、桌下 304–416（净高 44）、第一院通行线 440、
 * 软土 272（D5 完整）、砖地 608、拾荒者巡逻 464–512。
 * 小满脚底中心 290 起必须蹲，超过 430 才站起；160→440 约 2.63 秒。
 */
export const VILLAGE_ROOM: RoomSpec = {
    key: "village",
    originX: 0,
    name: "村口 · 架、桌、砖地",
    caption: "点 E 拾瓶，按住 F 瞄，松手投；砖地一响，拾荒者转身，趁他走开钻过桌下",
    minX: 0,
    maxX: 720,
    height: 200,
    floors: [{ y: 0, x0: 0, x1: 720 }],
    solids: [
        { x: 96, w: 32, h: 64, y: 0, label: "瓶架" },
        // 桌腿只是视觉（drawVillage 补画），碰撞交给 arch：站 64 进不去、蹲 36 能过。
        { x: 672, w: 48, h: 96, y: 0, label: "院墙" },
    ],
    zones: [
        { x0: 256, x1: 288, y: 0, h: 6, tint: 2, label: "软土 272" },
        { x0: 440, x1: 448, y: 0, h: 120, tint: 4, label: "通行线 440" },
        { x0: 592, x1: 624, y: 0, h: 6, tint: 3, label: "砖地 608" },
    ],
    arch: { x0: 304, x1: 416, y: 0, h: 44, label: "桌下 304–416 · 净高 44" },
    stairs: [],
    cart: { startX: 0, endX: 0, baseY: 0, bodyW: 0, bodyH: 0, wheelR: 0, handleOffset: 0, clothSide: 1 },
    spawns: [{ x: 160, y: 0, h: 64, label: "小满 160" }],
    marks: [
        { x: 608, y: 0, kind: 5, label: "砖地落点 608" },
        { x: 440, y: 0, kind: 4, label: "通行线 440" },
    ],
    dims: [
        { x0: 96, x1: 128, text: "瓶架" },
        { x0: 304, x1: 416, text: "桌下 112" },
        { x0: 464, x1: 512, text: "巡逻 48" },
    ],
    scavenger: {
        x0: 464,
        x1: 512,
        y: 0,
        h: 56,
        patrolSpeed: 40,
        approachSpeed: 64,
        hearTicks: 18,
        stallTicks: 120,
        range: 480,
    },
    bottle: { x: 112, y: 48 },
    brickX: 608,
    softX: 272,
    passLine: 440,
};

/** 剧本锚点跟着 originX 一起搬，判定仍读世界坐标。 */
function shiftStory(story: StorySpec | undefined, ox: number): StorySpec | undefined {
    if (story === undefined) {
        return undefined;
    }
    if (ox === 0) {
        return story;
    }
    const out: StorySpec = {};
    if (story.prologue !== undefined) {
        out.prologue = { giveReach: story.prologue.giveReach };
    }
    if (story.gate !== undefined) {
        out.gate = {
            winchX: story.gate.winchX + ox,
            waitX: story.gate.waitX + ox,
            doorX: story.gate.doorX + ox,
            exitX: story.gate.exitX + ox,
            holdTicks: story.gate.holdTicks,
        };
    }
    if (story.dog !== undefined) {
        out.dog = { x0: story.dog.x0 + ox, x1: story.dog.x1 + ox, speed: story.dog.speed, range: story.dog.range };
    }
    if (story.tower !== undefined) {
        out.tower = { doorX: story.tower.doorX + ox, knockTicks: story.tower.knockTicks };
    }
    return out;
}

/**
 * 序章：周戍在废墟里找到藏在倒柜后的小满，走近点 E 递出指南针（纸条夹在针套里）。
 * 递完她开始跟随，两人一起走进街道。
 */
export const PROLOGUE_ROOM: RoomSpec = {
    key: "prologue",
    originX: 0,
    name: "序章 · 倒柜后",
    caption: "周戍持针套，小满藏在倒柜后；走近点 E 递过去，纸条塞进针套，她开始跟随",
    minX: 0,
    maxX: 720,
    height: 200,
    depth: LANE_ROAD,
    floors: [{ y: 0, x0: 0, x1: 720 }],
    solids: [
        { x: 152, w: 98, h: 32, y: 0, label: "倒柜 152–250 · 高 32", lanes: ["lower", "middle"] },
        { x: 648, w: 30, h: 118, y: 0, label: "出口门柱", lanes: ["lower", "upper"], art: "gate_post" },
        { x: 110, w: 38, h: 84, y: 0, label: "石柱", lanes: ["lower", "middle"], art: "wall" },
    ],
    zones: [],
    arch: { x0: 0, x1: 0, y: 0, h: 0, label: "" },
    stairs: [],
    cart: { startX: 0, endX: 0, baseY: 0, bodyW: 0, bodyH: 0, wheelR: 0, handleOffset: 0, clothSide: 1 },
    spawns: [
        { x: 80, y: 0, h: 88, label: "周戍 80" },
        { x: 300, y: 0, h: 64, label: "小满 300 · 柜子后面" },
    ],
    marks: [
        { x: 300, y: 0, kind: 1, label: "柜后 300" },
        { x: 660, y: 0, kind: 0, label: "门口中路 660" },
    ],
    dims: [
        { x0: 152, x1: 250, text: "倒柜 98" },
        { x0: 648, x1: 678, text: "门柱 30" },
    ],
    story: { prologue: { giveReach: 46 } },
};

/**
 * 街道：两人已经同行，第一次交火在街心柜台后，打完把柜台敲两下算解除。
 * 一路走到检查站入口，提交进度后进入检查站。
 */
export const STREET_ROOM: RoomSpec = {
    key: "street",
    originX: 0,
    name: "街道 · 柜台与交火",
    caption: "小满跟着走；街心柜台后有两名敌兵，点鼠标射击，清掉后一起走到检查站入口",
    minX: 0,
    maxX: 1000,
    height: 210,
    depth: LANE_ROAD,
    floors: [{ y: 0, x0: 0, x1: 1000 }],
    solids: [
        { x: 300, w: 100, h: 44, y: 0, label: "街心柜台 300–400 · 高 44", lanes: ["lower", "middle"] },
        { x: 620, w: 60, h: 36, y: 0, label: "街边矮墙 620", lanes: ["upper"] },
        { x: 892, w: 40, h: 120, y: 0, label: "检查站门柱", lanes: ["lower", "upper"], art: "gate_post" },
    ],
    zones: [],
    arch: { x0: 0, x1: 0, y: 0, h: 0, label: "" },
    stairs: [],
    cart: { startX: 0, endX: 0, baseY: 0, bodyW: 0, bodyH: 0, wheelR: 0, handleOffset: 0, clothSide: 1 },
    spawns: [
        { x: 100, y: 0, h: 88, label: "周戍 100" },
        { x: 60, y: 0, h: 64, label: "小满 60" },
    ],
    marks: [
        { x: 900, y: 0, kind: 0, label: "检查站入口 900" },
        { x: 520, y: 0, kind: 3, label: "街心 520" },
    ],
    dims: [
        { x0: 300, x1: 400, text: "柜台 100" },
        { x0: 900, x1: 1000, text: "入口 100" },
    ],
};

/**
 * 城门：周戍把小满送到门洞等待点，自己回到绞盘；两人就位后开始 45 秒守点。
 * 守满后玩家走到门边按 E 送别，接着是数到一百与交权。
 */
export const GATE_ROOM: RoomSpec = {
    key: "gate",
    originX: 0,
    name: "城门 · 45 秒守点",
    caption: "小满到门洞 960、周戍贴住绞盘 118，两人就位开始 45 秒；守满走到门边按 E 送她",
    minX: 0,
    maxX: 1200,
    height: 240,
    depth: LANE_ROAD,
    floors: [{ y: 0, x0: 0, x1: 1200 }],
    solids: [
        { x: 40, w: 60, h: 60, y: 0, label: "绞盘 40–100 · 高 60" },
        { x: 520, w: 80, h: 44, y: 0, label: "街垒 520 · 高 44", lanes: ["middle", "upper"] },
        { x: 970, w: 34, h: 100, y: 0, label: "城门门柱", lanes: ["lower", "upper"], art: "gate_post" },
        { x: 1040, w: 160, h: 180, y: 0, label: "门洞右墙 1040" },
        { x: 840, w: 200, h: 56, y: 160, label: "门楣 840–1040" },
    ],
    zones: [
        { x0: 860, x1: 1000, y: 0, h: 8, tint: 4, label: "门洞 860–1000" },
    ],
    arch: { x0: 0, x1: 0, y: 0, h: 0, label: "" },
    stairs: [],
    cart: { startX: 0, endX: 0, baseY: 0, bodyW: 0, bodyH: 0, wheelR: 0, handleOffset: 0, clothSide: 1 },
    spawns: [
        { x: 130, y: 0, h: 88, label: "周戍 130" },
        { x: 150, y: 0, h: 64, label: "小满 150" },
    ],
    marks: [
        { x: 118, y: 0, kind: 1, label: "绞盘站位 118" },
        { x: 960, y: 0, kind: 1, label: "门洞等待点 960" },
        { x: 860, y: 0, kind: 0, label: "门边 860" },
        { x: 1020, y: 0, kind: 0, label: "出门 1020" },
    ],
    dims: [
        { x0: 40, x1: 100, text: "绞盘 60" },
        { x0: 840, x1: 1040, text: "门洞 200" },
    ],
    // winchX 是「站的位置」不是绞盘中心：绞盘实体 40–100，周戍半宽 15，站 118 正好贴住右侧。
    story: { gate: { winchX: 118, waitX: 960, doorX: 860, exitX: 1020, holdTicks: 2700 } },
};

/**
 * 北塔森林：小满独自走。草后可以等，狗听见脚步会转耳朵、赶来、停一会儿再回线。
 * 最后一段从林缘自己选时机走到灯下门廊。
 */
export const FOREST_ROOM: RoomSpec = {
    key: "forest",
    originX: 0,
    name: "北塔森林 · 草与狗",
    caption: "狗对动静比人快：草后等、Shift 慢走、蹲着过；林缘 1450 走到灯下门廊",
    minX: 0,
    maxX: 1600,
    height: 200,
    floors: [{ y: 0, x0: 0, x1: 1600 }],
    solids: [
        { x: 300, w: 80, h: 24, y: 0, label: "草丛 300–380 · 高 24", passable: true },
        { x: 700, w: 90, h: 24, y: 0, label: "草丛 700–790 · 高 24", passable: true },
        { x: 1150, w: 90, h: 24, y: 0, label: "草丛 1150–1240 · 高 24", passable: true },
        { x: 1560, w: 40, h: 160, y: 0, label: "林缘 1560" },
    ],
    zones: [
        { x0: 1400, x1: 1470, y: 0, h: 6, tint: 4, label: "林边 1400–1470" },
    ],
    arch: { x0: 0, x1: 0, y: 0, h: 0, label: "" },
    stairs: [
        { x0: 520, x1: 640, y0: 0, y1: 22, steps: 1, label: "矮台 520–640 · 高 22" },
        { x0: 980, x1: 1100, y0: 0, y1: 22, steps: 1, label: "矮台 980–1100 · 高 22" },
    ],
    cart: { startX: 0, endX: 0, baseY: 0, bodyW: 0, bodyH: 0, wheelR: 0, handleOffset: 0, clothSide: 1 },
    spawns: [{ x: 120, y: 0, h: 64, label: "小满 120" }],
    marks: [
        { x: 1450, y: 0, kind: 0, label: "林边安全点 1450" },
        { x: 620, y: 0, kind: 3, label: "矮台 620" },
    ],
    dims: [
        { x0: 700, x1: 790, text: "草 90" },
        { x0: 1400, x1: 1470, text: "林边 70" },
    ],
    story: { dog: { x0: 620, x1: 780, speed: 56, range: 300 } },
};

/**
 * 塔门与尾声：小满走到门前，按一次 E 敲两下；守卫开门接过针套和纸条，
 * 在登记簿里给下一个人留出一行空白。片尾可以再玩。
 */
export const TOWER_ROOM: RoomSpec = {
    key: "tower",
    originX: 0,
    name: "北塔塔门 · 尾声",
    caption: "走到门前点一次 E 敲两下；递出针套和纸条，看登记簿空行，片尾可再玩",
    minX: 0,
    maxX: 720,
    height: 220,
    floors: [{ y: 0, x0: 0, x1: 720 }],
    solids: [
        { x: 180, w: 220, h: 200, y: 0, label: "塔身 180–400" },
        { x: 490, w: 230, h: 200, y: 0, label: "塔身 490–720" },
        { x: 400, w: 90, h: 30, y: 110, label: "门楣 400–490" },
    ],
    zones: [
        { x0: 400, x1: 490, y: 0, h: 8, tint: 4, label: "门廊 400–490" },
    ],
    arch: { x0: 0, x1: 0, y: 0, h: 0, label: "" },
    stairs: [],
    cart: { startX: 0, endX: 0, baseY: 0, bodyW: 0, bodyH: 0, wheelR: 0, handleOffset: 0, clothSide: 1 },
    spawns: [{ x: 418, y: 0, h: 64, label: "小满 418 · 门廊里" }],
    marks: [
        { x: 445, y: 0, kind: 1, label: "门前 445" },
    ],
    dims: [
        { x0: 400, x1: 490, text: "门 90" },
    ],
    story: { tower: { doorX: 445, knockTicks: 36 } },
};

const NO_CART: CartSpec = {
    startX: 0, endX: 0, baseY: 0, bodyW: 0, bodyH: 0, wheelR: 0, handleOffset: 0, clothSide: -1,
};

/**
 * S1 十字街：同一个街口先教单方向火器，再让破障手从街角压近。
 * 外檐线与布行线都从这里的出口分叉；井背是退回点，窗台是可选的翻窗捷径。
 */
export const S1_CROSSROAD: RoomSpec = {
    key: "s1-crossroad",
    name: "S1 · 十字街",
    caption: "井背 → 摊后窄道 → 观察转角 → 街角压近者。薄木挡与窗台分别通向 S2 的两条线。",
    originX: 0,
    minX: 0,
    maxX: 1600,
    height: 220,
    depth: LANE_ROAD,
    floors: [{ y: 0, x0: 0, x1: 1600 }],
    solids: [
        { x: 180, w: 88, h: 56, y: 0, label: "井背 180–268 · 高 56", lanes: ["lower"], art: "cover_stone", id: "s1_well" },
        { x: 360, w: 160, h: 44, y: 0, label: "摊后柜台 360–520 · 高 44", lanes: ["lower", "middle"], art: "cover_wood" },
        { x: 620, w: 44, h: 24, y: 0, label: "观察转角石基 620–664 · 高 24", lanes: ["lower"] },
        { x: 1130, w: 20, h: 120, y: 0, label: "窗柱左", lanes: ["lower"], art: "wall" },
        { x: 1150, w: 80, h: 44, y: 0, label: "窗台 1150–1230 · 高 44", lanes: ["lower"] },
        { x: 1230, w: 20, h: 120, y: 0, label: "窗柱右", lanes: ["lower"], art: "wall" },
        { x: 1460, w: 40, h: 140, y: 0, label: "街尾门柱", lanes: ["lower", "upper"], art: "gate_post" },
    ],
    zones: [{ x0: 700, x1: 960, y: 0, h: 150, tint: 1, label: "街角交火 700–960" }],
    arch: { x0: 0, x1: 0, y: 0, h: 0, label: "" },
    stairs: [{ x0: 900, x1: 1040, y0: 0, y1: 40, steps: 4, label: "石基斜走 900–1040 · 高 40" }],
    cart: NO_CART,
    spawns: [
        { x: 760, y: 0, h: 84, depth: 32, label: "单方向火器手 760", kind: "gunner", drop: "ammo" },
        { x: 880, y: 0, h: 84, label: "街角压近者 880", kind: "breaker", drop: "wedge" },
    ],
    marks: [
        { x: 220, y: 0, kind: 1, label: "井背安全点 220" },
        { x: 640, y: 0, kind: 0, label: "观察转角 640" },
        { x: 1190, y: 0, kind: 0, label: "窗台捷径 1190" },
        { x: 1500, y: 0, kind: 0, label: "出口 1500" },
    ],
    dims: [
        { x0: 180, x1: 268, text: "井 88" },
        { x0: 360, x1: 520, text: "柜台 160" },
        { x0: 900, x1: 1040, text: "石基 140" },
    ],
    companion: { waitX: 220, waitDepth: -32, joinX: 900 },
    campaign: { chapter: "S", act: 1, budget: 210, goal: "reach_exit", next: "s2-drygoods", exitX: 1500, checkpoint: 1 },
};

/**
 * S2 布行与外檐：近檐柱下短跨、可碎摊挡与转角装卸面是一条线；
 * 从染布架侧面进布行、绕柜到窗板背后放板、后仓折回是另一条线。两条线同通牌楼。
 */
export const S2_DRYGOODS: RoomSpec = {
    key: "s2-drygoods",
    name: "S2 · 布行与外檐",
    caption: "近檐：檐柱短跨、薄木摊挡、装卸面。远帘：染布架入内、绕柜、放窗板、后仓折回。两路同通牌楼。",
    originX: 1600,
    minX: 0,
    maxX: 1800,
    height: 230,
    depth: LANE_ROAD,
    floors: [{ y: 0, x0: 0, x1: 1800 }],
    pickups: [
        { id: "s2_scrap_1", kind: "scrap", x: 520, y: 0, depth: 0, label: "废木料 · 薄木摊挡脚下" },
        { id: "s2_scrap_2", kind: "scrap", x: 760, y: 0, depth: 0, label: "废木料 · 装卸面旁" },
    ],
    solids: [
        { x: 100, w: 24, h: 130, y: 0, label: "檐柱 100", lanes: ["middle"], art: "cover_wood" },
        { x: 240, w: 24, h: 130, y: 0, label: "檐柱 240", lanes: ["middle"], art: "cover_wood" },
        {
            x: 460, w: 100, h: 48, y: 0, label: "薄木摊挡 460–560 · 高 48", lanes: ["middle", "upper"],
            art: "thin_wood", id: "s2_wood", breakable: { kind: "thin_wood", hp: 2, wedgeHp: 1 },
        },
        { x: 620, w: 40, h: 130, y: 0, label: "永久石柱 620–660", lanes: ["upper"], art: "cover_stone" },
        { x: 700, w: 120, h: 32, y: 0, label: "转角装卸面 700–820 · 高 32", lanes: ["middle"] },
        { x: 340, w: 120, h: 44, y: 0, label: "布行柜台 340–460 · 高 44", lanes: ["upper"], art: "cover_wood" },
        {
            x: 600, w: 80, h: 72, y: 0, label: "窗板背后 600–680", lanes: ["upper"],
            art: "board", id: "s2_board", interact: { kind: "open_board", reach: 46 },
        },
        {
            x: 600, w: 80, h: 40, y: 0, label: "放下的窗板 600–680", lanes: ["lower"],
            art: "board", id: "s2_board_cover", soft: true,
        },
        { x: 1560, w: 30, h: 150, y: 0, label: "牌楼左柱", lanes: ["lower", "upper"], art: "gate_post" },
        { x: 1700, w: 30, h: 150, y: 0, label: "牌楼右柱", lanes: ["lower", "upper"], art: "gate_post" },
    ],
    zones: [{ x0: 640, x1: 1300, y: 0, h: 150, tint: 1, label: "转角装卸面交火 700–1200" }],
    arch: { x0: 0, x1: 0, y: 0, h: 0, label: "" },
    stairs: [],
    cart: NO_CART,
    spawns: [
        { x: 940, y: 0, h: 84, depth: 0, label: "持盾手 940", kind: "shield", shieldHp: 2, drop: "shield" },
        { x: 1060, y: 0, h: 84, depth: 32, label: "远侧火器手 1060", kind: "gunner", drop: "ammo" },
        { x: 1140, y: 0, h: 84, depth: 0, label: "破障手 1140", kind: "breaker", drop: "wedge" },
    ],
    marks: [
        { x: 640, y: 0, kind: 1, label: "窗板后等待位 640" },
        { x: 900, y: 0, kind: 0, label: "后仓汇合口 900" },
        { x: 1740, y: 0, kind: 0, label: "牌楼出口 1740" },
    ],
    dims: [
        { x0: 100, x1: 124, text: "檐柱 24" },
        { x0: 460, x1: 560, text: "摊挡 100" },
        { x0: 700, x1: 820, text: "装卸面 120" },
    ],
    companion: { waitX: 640, waitDepth: 32, joinX: 900, followAfter: "open_board" },
    campaign: { chapter: "S", act: 2, budget: 390, goal: "reach_exit", next: "s3-archway", exitX: 1740, checkpoint: 2 },
};

/**
 * S3 牌楼后巷：外檐线从低处进、布行线从高处进，两条入口在墙脚汇合。
 * 装卸坡可先上去看同一堆粮袋的敌位，再退半层接小满；也可以沿墙脚直接绕。
 */
export const S3_ARCHWAY: RoomSpec = {
    key: "s3-archway",
    name: "S3 · 牌楼后巷",
    caption: "两高度入口看同一粮袋。登装卸坡看敌位再退半层接人，或沿墙脚绕走；候检门前两人停。",
    originX: 3400,
    minX: 0,
    maxX: 1400,
    height: 230,
    depth: LANE_ROAD,
    floors: [{ y: 0, x0: 0, x1: 1400 }],
    solids: [
        { x: 0, w: 180, h: 32, y: 0, label: "高处进口台 0–180 · 高 32", lanes: ["upper"] },
        { x: 380, w: 140, h: 64, y: 0, label: "装卸高台 380–520 · 高 64", lanes: ["upper"] },
        { x: 560, w: 160, h: 48, y: 0, label: "粮袋堆 560–720 · 高 48", lanes: ["lower", "middle"] },
        { x: 1260, w: 30, h: 140, y: 0, label: "候检门左柱", lanes: ["lower", "upper"], art: "gate_post" },
        { x: 1330, w: 30, h: 140, y: 0, label: "候检门右柱", lanes: ["lower", "upper"], art: "gate_post" },
    ],
    zones: [{ x0: 780, x1: 1060, y: 0, h: 150, tint: 1, label: "后巷交火 780–1060" }],
    arch: { x0: 0, x1: 0, y: 0, h: 0, label: "" },
    stairs: [
        { x0: 140, x1: 200, y0: 0, y1: 32, steps: 3, label: "进口台阶" },
        { x0: 260, x1: 380, y0: 0, y1: 64, steps: 4, label: "装卸坡 260–380 · 高 64" },
    ],
    cart: NO_CART,
    spawns: [
        { x: 860, y: 0, h: 84, depth: 32, label: "高处火器手 860", kind: "gunner", drop: "ammo" },
        { x: 980, y: 0, h: 84, depth: 0, label: "墙脚火器手 980", kind: "gunner", drop: "ammo" },
    ],
    marks: [
        { x: 440, y: 0, kind: 0, label: "装卸坡观察位 440" },
        { x: 620, y: 0, kind: 1, label: "粮袋后安全点 620" },
        { x: 1300, y: 0, kind: 0, label: "候检门前 1300" },
    ],
    dims: [{ x0: 260, x1: 380, text: "装卸坡 120" }, { x0: 560, x1: 720, text: "粮袋 160" }],
    companion: { waitX: 620, waitDepth: 0, joinX: 1240 },
    campaign: { chapter: "S", act: 3, budget: 180, goal: "reach_exit", next: "c1-yard", exitX: 1320, checkpoint: 3 },
};

/**
 * C1 候检院：侧门横闩在门背，粮棚可见但被队栏、查验台与棚柱交错挡住。
 * 绕缺口进栏，截断压近者或穿查验台后到棚口；正面看门，转到背面才抬得动闩。
 */
export const C1_YARD: RoomSpec = {
    key: "c1-yard",
    name: "C1 · 候检院",
    caption: "队栏与查验台把粮棚切成几段。绕缺口进栏，压近者会截断通路；侧门横闩要转到门背才抬得动。",
    originX: 4800,
    minX: 0,
    maxX: 1900,
    height: 240,
    depth: LANE_ROAD,
    floors: [{ y: 0, x0: 0, x1: 1900 }],
    solids: [
        { x: 280, w: 340, h: 28, y: 0, label: "候检队栏 280–620 · 高 28", lanes: ["lower", "middle"], art: "fence" },
        { x: 820, w: 180, h: 44, y: 0, label: "查验台 820–1000 · 高 44", lanes: ["lower", "middle"] },
        { x: 1100, w: 40, h: 150, y: 0, label: "棚柱 1100–1140", lanes: ["lower", "middle"], art: "cover_wood" },
        { x: 1240, w: 40, h: 150, y: 0, label: "棚柱 1240–1280", lanes: ["lower", "middle"], art: "cover_wood" },
        { x: 1600, w: 160, h: 48, y: 0, label: "粮棚袋堆 1600–1760 · 高 48", lanes: ["lower", "middle"] },
        { x: 1780, w: 50, h: 150, y: 0, label: "侧门 1780–1830", lanes: ["lower", "middle"], art: "wall", id: "c1_door" },
        {
            x: 1810, w: 30, h: 24, y: 40, label: "侧门横闩（门背）", lanes: ["upper"],
            art: "latch", id: "c1_latch", interact: { kind: "raise_latch", reach: 52 },
        },
    ],
    zones: [{ x0: 760, x1: 1080, y: 0, h: 150, tint: 1, label: "查验台截断 820–1000" }],
    arch: { x0: 0, x1: 0, y: 0, h: 0, label: "" },
    stairs: [],
    cart: NO_CART,
    spawns: [
        { x: 900, y: 0, h: 84, depth: 0, label: "截断压近者 900", kind: "breaker", drop: "wedge" },
        { x: 1200, y: 0, h: 84, depth: 32, label: "棚柱后火器手 1200", kind: "gunner", drop: "ammo" },
    ],
    marks: [
        { x: 1000, y: 0, kind: 1, label: "查验台后等待位 1000" },
        { x: 1700, y: 0, kind: 0, label: "侧门正面 1700" },
        { x: 1860, y: 0, kind: 0, label: "门背出口 1860" },
    ],
    dims: [{ x0: 820, x1: 1000, text: "查验台 180" }, { x0: 1780, x1: 1830, text: "侧门 50" }],
    companion: { waitX: 1000, waitDepth: 0, joinX: 1700, followAfter: "raise_latch" },
    campaign: { chapter: "C", act: 1, budget: 270, goal: "raise_latch", next: "c2-granary", exitX: 1860, checkpoint: 4 },
};

/**
 * C2 军粮棚：粮袋安全区居中，远柱木帘与近侧车轨分列。
 * 有残盾可以在暴露轨段架起来挡一发；空手路线先绕上远柱放帘，再回来握车柄。
 */
export const C2_GRANARY: RoomSpec = {
    key: "c2-granary",
    name: "C2 · 军粮棚",
    caption: "空筐围挡、暴露轨段与远柱木帘。先绕上远柱放帘，或架残盾，再握车柄把车推入轮窝并抬连杆闩。",
    originX: 6700,
    minX: 0,
    maxX: 1800,
    height: 240,
    depth: LANE_ROAD,
    floors: [{ y: 0, x0: 0, x1: 1800 }],
    solids: [
        {
            x: 900, w: 120, h: 44, y: 0, label: "空筐围挡 900–1020 · 高 44", lanes: ["lower", "middle"],
            art: "basket_wall", id: "c2_basket", breakable: { kind: "basket_wall", hp: 2, wedgeable: false },
        },
        { x: 600, w: 300, h: 48, y: 0, label: "粮袋安全区 600–900 · 高 48", lanes: ["lower", "middle"] },
        { x: 980, w: 40, h: 24, y: 0, label: "棚口下轨台 980–1020 · 高 24", lanes: ["lower", "middle"] },
        {
            x: 1200, w: 40, h: 150, y: 0, label: "远柱 1200–1240 · 高 150", lanes: ["upper"],
            art: "cover_wood", id: "c2_post", interact: { kind: "lower_curtain", reach: 46 },
        },
        {
            x: 1240, w: 120, h: 120, y: 24, label: "木帘落点 1240–1360", lanes: ["lower", "middle"],
            art: "curtain", soft: true, id: "c2_curtain", hidden: true,
        },
        {
            x: 1560, w: 30, h: 24, y: 40, label: "连杆抬闩 1560–1590", lanes: ["middle"],
            art: "latch", id: "c2_latch", interact: { kind: "raise_latch", reach: 50 },
        },
        { x: 1720, w: 30, h: 150, y: 0, label: "棚尾门柱", lanes: ["lower", "upper"], art: "gate_post" },
    ],
    zones: [{ x0: 1000, x1: 1200, y: 0, h: 150, tint: 1, label: "暴露轨段 1000–1200" }],
    arch: { x0: 0, x1: 0, y: 0, h: 0, label: "" },
    stairs: [],
    cart: {
        startX: 1150, endX: 1500, baseY: 0, depth: 0, bodyW: 48, bodyH: 26, wheelR: 12, handleOffset: -50, clothSide: -1,
    },
    spawns: [
        { x: 1580, y: 0, h: 84, depth: 0, label: "棚尾火器手 1580", kind: "gunner", drop: "ammo" },
        { x: 1340, y: 0, h: 84, depth: 32, label: "远侧持盾手 1340", kind: "shield", shieldHp: 2, drop: "shield" },
    ],
    marks: [
        { x: 760, y: 0, kind: 1, label: "袋堆后等待位 760" },
        { x: 1100, y: 0, kind: 0, label: "车柄 1100" },
        { x: 1500, y: 0, kind: 0, label: "轮窝 1500" },
        { x: 1700, y: 0, kind: 0, label: "棚尾出口 1700" },
    ],
    dims: [{ x0: 1150, x1: 1500, text: "推车 350" }, { x0: 1240, x1: 1360, text: "木帘 120" }],
    companion: { waitX: 760, waitDepth: 0, joinX: 1700 },
    campaign: { chapter: "C", act: 2, budget: 360, goal: "dock_cart", exitX: 1700, checkpoint: 5 },
};

export const CAMPAIGN_ROOMS: RoomSpec[] = [
    S1_CROSSROAD,
    S2_DRYGOODS,
    S3_ARCHWAY,
    C1_YARD,
    C2_GRANARY,
];

export const ROOMS: RoomSpec[] = [
    PROLOGUE_ROOM,
    STREET_ROOM,
    CHECKPOINT_ROOM,
    GATE_ROOM,
    OUTSIDE_ROOM,
    VILLAGE_ROOM,
    FOREST_ROOM,
    TOWER_ROOM,
];

function placeSolids(room: RoomSpec): SolidSpec[] {
    const blocks: SolidSpec[] = [];
    for (const solid of room.solids) {
        const x = solid.x + room.originX;
        if (room.depth !== undefined && solid.lanes !== undefined) {
            for (const depth of laneFootprints(solid.lanes)) {
                blocks.push({ ...solid, x, depth, lanes: undefined });
            }
        } else {
            blocks.push({ ...solid, x });
        }
    }
    return blocks;
}

/**
 * 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
 * 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
 */
export function withOrigin(room: RoomSpec): RoomSpec {
    const ox = room.originX;
    if (ox === 0) {
        return room.depth === undefined ? room : { ...room, solids: placeSolids(room) };
    }
    const shift = (x: number): number => x + ox;
    return {
        key: room.key,
        name: room.name,
        caption: room.caption,
        originX: 0,
        minX: shift(room.minX),
        maxX: shift(room.maxX),
        height: room.height,
        depth: room.depth,
        floors: room.floors.map((f) => ({ y: f.y, x0: shift(f.x0), x1: shift(f.x1) })),
        solids: placeSolids(room),
        zones: room.zones.map((z) => ({ x0: shift(z.x0), x1: shift(z.x1), y: z.y, h: z.h, tint: z.tint, label: z.label })),
        arch: { x0: shift(room.arch.x0), x1: shift(room.arch.x1), y: room.arch.y, h: room.arch.h, label: room.arch.label },
        stairs: room.stairs.map((s) => ({ x0: shift(s.x0), x1: shift(s.x1), y0: s.y0, y1: s.y1, steps: s.steps, label: s.label })),
        cart: {
            ...room.cart,
            startX: shift(room.cart.startX),
            endX: shift(room.cart.endX),
        },
        spawns: room.spawns.map((s) => ({ ...s, x: shift(s.x) })),
        marks: room.marks.map((m) => ({ x: shift(m.x), y: m.y, kind: m.kind, label: m.label })),
        dims: room.dims.map((d) => ({ x0: shift(d.x0), x1: shift(d.x1), text: d.text })),
        scavenger: room.scavenger === undefined ? undefined : {
            x0: shift(room.scavenger.x0), x1: shift(room.scavenger.x1), y: room.scavenger.y, h: room.scavenger.h,
            patrolSpeed: room.scavenger.patrolSpeed, approachSpeed: room.scavenger.approachSpeed,
            hearTicks: room.scavenger.hearTicks, stallTicks: room.scavenger.stallTicks, range: room.scavenger.range,
        },
        bottle: room.bottle === undefined ? undefined : { x: shift(room.bottle.x), y: room.bottle.y },
        brickX: room.brickX === undefined ? undefined : shift(room.brickX),
        softX: room.softX === undefined ? undefined : shift(room.softX),
        passLine: room.passLine === undefined ? undefined : shift(room.passLine),
        campaign: room.campaign === undefined ? undefined : { ...room.campaign, exitX: shift(room.campaign.exitX) },
        pickups: room.pickups === undefined ? undefined : room.pickups.map((p) => ({ ...p, x: shift(p.x) })),
        companion: room.companion,
        story: shiftStory(room.story, ox),
    };
}
