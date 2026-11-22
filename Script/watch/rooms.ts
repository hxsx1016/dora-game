/**
 * 《守望》D1 · 两张灰盒的摆放定稿。
 *
 * 单位一律为米；地面 y = 0；x 轴向右。
 * 检查站与城墙外共用“车心距门中线 2.0m”这一定位量：
 * 检查站里门中线 29.5、车心 27.5；城外门中线 -0.4、车心 2.4（车身 1.6–3.2）。
 * 车把始终在车身左端，红布绑在车把上，所以城外从门里出来第一眼就落在红布上。
 */

export interface SpawnSpec {
    x: number;
    label: string;
}

export interface SolidSpec {
    x: number;
    w: number;
    h: number;
    label: string;
}

/** tint: 1 危险区 / 2 台面 / 3 洞体 */
export interface ZoneSpec {
    x0: number;
    x1: number;
    h: number;
    label: string;
    tint: number;
}

export interface CartSpec {
    startX: number;
    endX: number;
    bodyW: number;
    bodyH: number;
    wheelR: number;
    handleH: number;
}

export interface HoleSpec {
    x: number;
    w: number;
    h: number;
    label: string;
}

export interface GateSpec {
    x: number;
    w: number;
    h: number;
    label: string;
}

/** kind: 0 检查点 / 1 交接站位 / 2 出口 / 3 地标 */
export interface MarkSpec {
    x: number;
    label: string;
    kind: number;
}

export interface DimSpec {
    x0: number;
    x1: number;
    text: string;
}

export interface RoomSpec {
    id: string;
    name: string;
    caption: string;
    minX: number;
    maxX: number;
    height: number;
    spawns: SpawnSpec[];
    solids: SolidSpec[];
    zones: ZoneSpec[];
    cart: CartSpec;
    hole: HoleSpec;
    gates: GateSpec[];
    marks: MarkSpec[];
    dims: DimSpec[];
}

export const ROOM_CHECKPOINT: RoomSpec = {
    id: "checkpoint",
    name: "检查站 · 灰盒",
    caption: "点射 → 小满躲柜台 → 恐惧三格 → E 敲两下安抚 → 按住 E 推车到装卸台 → 门洞交接",
    minX: 0,
    maxX: 33,
    height: 6,
    spawns: [
        { x: 1.0, label: "小满出生" },
        { x: 2.6, label: "周戍出生" },
    ],
    solids: [
        { x: 8.0, w: 2.4, h: 1.0, label: "柜台 1.0m" },
        { x: 19.2, w: 1.2, h: 0.9, label: "矮墙 0.9m" },
        { x: 30.6, w: 1.4, h: 4.0, label: "城门墙" },
    ],
    zones: [
        { x0: 13.0, x1: 17.0, h: 3.0, label: "敌人触发区", tint: 1 },
        { x0: 26.4, x1: 29.4, h: 0.12, label: "装卸台", tint: 2 },
    ],
    cart: { startX: 23.0, endX: 27.5, bodyW: 1.6, bodyH: 0.55, wheelR: 0.25, handleH: 0.95 },
    hole: { x: 0, w: 0, h: 0, label: "" },
    gates: [{ x: 29.5, w: 2.2, h: 3.2, label: "城门洞 2.2m" }],
    marks: [
        { x: 21.0, label: "检查点", kind: 0 },
        { x: 29.0, label: "周戍侧", kind: 1 },
        { x: 30.8, label: "小满侧", kind: 1 },
        { x: 31.9, label: "双人出口", kind: 2 },
    ],
    dims: [
        { x0: 8.0, x1: 10.4, text: "柜台 2.4m / 高 1.0m" },
        { x0: 23.0, x1: 27.5, text: "推车 4.5m（按住 E + D）" },
        { x0: 27.5, x1: 29.5, text: "车心距门 2.0m" },
    ],
};

export const ROOM_OUTSIDE: RoomSpec = {
    id: "outside",
    name: "城墙外 · 灰盒",
    caption: "认出左端红布 → 按住 E 拉车 1.0m → 车轮落窝 → S/Ctrl 蹲下钻低洞 → 洞后检查点",
    minX: -2.2,
    maxX: 26,
    height: 6,
    spawns: [{ x: 1.4, label: "小满出生（刚接过控制权）" }],
    solids: [],
    zones: [
        { x0: -0.2, x1: 5.0, h: 0.12, label: "装卸台", tint: 2 },
        { x0: 8.0, x1: 12.0, h: 0.12, label: "北路口", tint: 2 },
    ],
    cart: { startX: 2.4, endX: 1.4, bodyW: 1.6, bodyH: 0.55, wheelR: 0.25, handleH: 0.95 },
    hole: { x: 2.8, w: 1.1, h: 0.78, label: "低洞 0.78m" },
    gates: [{ x: -0.4, w: 2.0, h: 3.2, label: "大门（已落下）" }],
    marks: [
        { x: 5.2, label: "洞后检查点", kind: 0 },
        { x: 11.0, label: "塔灯方向", kind: 3 },
    ],
    dims: [
        { x0: 1.6, x1: 3.2, text: "车体 1.6m（起点挡住半个洞）" },
        { x0: 1.4, x1: 2.4, text: "拉车 1.0m / 约 2.0s" },
        { x0: 2.8, x1: 3.9, text: "洞宽 1.1m / 高 0.78m" },
    ],
};

export const ROOMS: RoomSpec[] = [ROOM_CHECKPOINT, ROOM_OUTSIDE];
