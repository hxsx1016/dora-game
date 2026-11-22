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

export interface RoomSpec {
    key: string;
    name: string;
    caption: string;
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
}

/** 检查站：周戍把车从 640 推到 768 落入 dock，再和小满一起走到出口。 */
export const CHECKPOINT_ROOM: RoomSpec = {
    key: "checkpoint",
    name: "检查站 · 地面 y=0",
    caption: "周戍左柄按住 E + D 推车 128 单位入窝；双人到齐且车在 dock 才开绞盘",
    minX: 0,
    maxX: 1000,
    height: 210,
    floors: [{ y: 0, x0: 0, x1: 1000 }],
    solids: [
        { x: 240, w: 100, h: 60, y: 0, label: "柜台 240–340 · 高 60" },
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
        { x: 32, y: 0, h: 64, label: "小满 32" },
        { x: 80, y: 0, h: 88, label: "周戍 80" },
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
    name: "城外 · 上层 y=96 / 下层 y=0",
    caption: "从右柄按住 E+D 朝空窝拉 128 单位，轮子落窝后沿台面回左端跳下，蹲过 44 高的拱",
    minX: 0,
    maxX: 600,
    height: 230,
    floors: [
        { y: 0, x0: 0, x1: 600 },
        { y: 96, x0: 128, x1: 512 },
    ],
    solids: [
        { x: 512, w: 88, h: 96, y: 0, label: "台面右端实墙" },
        { x: 0, w: 40, h: 96, y: 0, label: "街口" },
    ],
    zones: [],
    arch: { x0: 280, x1: 360, y: 0, h: 44, label: "拱 280–360 · 净高 44" },
    stairs: [{ x0: 40, x1: 128, y0: 0, y1: 96, steps: 2, label: "石阶 0 / 48 / 96" }],
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
    ],
    dims: [
        { x0: 304, x1: 432, text: "拉车 128 · 右柄 E+D" },
        { x0: 128, x1: 512, text: "台面 384" },
        { x0: 280, x1: 360, text: "拱 80" },
    ],
};

export const ROOMS: RoomSpec[] = [CHECKPOINT_ROOM, OUTSIDE_ROOM];
