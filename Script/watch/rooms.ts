/**
 * D1 灰盒坐标：世界单位，与《守望-逐日开发与代码实现逻辑》第五、六节逐字对齐。
 *
 * 1 世界单位 ≈ 1.84 cm（小满 64 = 1.18 m，周戍 88 = 1.62 m）。
 * 车轴就是车身中心，车身半宽 24，所以停车后左沿 = 432 − 24 = 408，
 * 与小满右沿 402 之间留 6 单位净空——这条在城外剖面上要看得见。
 */

export interface FloorSpec {
    y: number;
    x0: number;
    x1: number;
}

export interface SolidSpec {
    x: number;
    w: number;
    h: number;
    y: number;
    label: string;
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
    floors: [{ y: 0, x0: -640, x1: 1000 }],
    solids: [
        // 候检区队栏：28 高，周戍空格翻过去，小满跟随会自己跳。缺口留在 330–390（世界）。
        { x: -430, w: 180, h: 28, y: 0, label: "队栏 -430–-250 · 高 28" },
        // 高 44：两人跳得上去（小满 51、周戍 58），也能在柜台后蹲下躲子弹。
        { x: 240, w: 100, h: 44, y: 0, label: "柜台 240–340 · 高 44" },
        { x: 950, w: 50, h: 150, y: 0, label: "城门内侧" },
    ],
    zones: [{ x0: 380, x1: 560, y: 0, h: 120, tint: 1, label: "危险段 380–560" }],
    arch: { x0: 0, x1: 0, y: 0, h: 0, label: "" },
    stairs: [],
    cart: {
        startX: 640,
        endX: 768,
        baseY: 0,
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

export const ROOMS: RoomSpec[] = [CHECKPOINT_ROOM, OUTSIDE_ROOM, VILLAGE_ROOM];

/**
 * 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
 * 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
 */
export function withOrigin(room: RoomSpec): RoomSpec {
    const ox = room.originX;
    if (ox === 0) {
        return room;
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
        floors: room.floors.map((f) => ({ y: f.y, x0: shift(f.x0), x1: shift(f.x1) })),
        solids: room.solids.map((s) => ({ x: shift(s.x), w: s.w, h: s.h, y: s.y, label: s.label })),
        zones: room.zones.map((z) => ({ x0: shift(z.x0), x1: shift(z.x1), y: z.y, h: z.h, tint: z.tint, label: z.label })),
        arch: { x0: shift(room.arch.x0), x1: shift(room.arch.x1), y: room.arch.y, h: room.arch.h, label: room.arch.label },
        stairs: room.stairs.map((s) => ({ x0: shift(s.x0), x1: shift(s.x1), y0: s.y0, y1: s.y1, steps: s.steps, label: s.label })),
        cart: {
            startX: shift(room.cart.startX),
            endX: shift(room.cart.endX),
            baseY: room.cart.baseY,
            bodyW: room.cart.bodyW,
            bodyH: room.cart.bodyH,
            wheelR: room.cart.wheelR,
            handleOffset: room.cart.handleOffset,
            clothSide: room.cart.clothSide,
        },
        spawns: room.spawns.map((s) => ({ x: shift(s.x), y: s.y, h: s.h, label: s.label })),
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
    };
}