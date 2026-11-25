/**
 * 慢时连线换弹：3×3 线盘的数据与校验。
 *
 * 只放盘本身的规则，不碰 Play 的模拟：节点、邻接、路径合法性、路径能引出的效果。
 * 世界 1/4 速与 240 拍作答预算由 Play 管，这里保证预览与结算读同一张映射。
 */

/** 盘上节点能引出的三种枪机效果：推退 / 回声（引到声源）/ 照明（照亮遮蔽）。 */
export type ReloadEffect = "push" | "echo" | "light" | "";

export interface ReloadNode {
    id: number;
    /** 盘内格坐标，0..2。 */
    x: number;
    y: number;
    /** plain=普通点；bell=铃纹；lamp=灯纹。 */
    kind: "plain" | "bell" | "lamp";
}

/** 3×3 盘：左下为起点 0，右下为枪机复位点 8；中心 4 是铃纹，右上 2 是灯纹。 */
export const RELOAD_NODES: ReloadNode[] = [
    { id: 0, x: 0, y: 0, kind: "plain" },
    { id: 1, x: 1, y: 0, kind: "plain" },
    { id: 2, x: 2, y: 0, kind: "lamp" },
    { id: 3, x: 0, y: 1, kind: "plain" },
    { id: 4, x: 1, y: 1, kind: "bell" },
    { id: 5, x: 2, y: 1, kind: "plain" },
    { id: 6, x: 0, y: 2, kind: "plain" },
    { id: 7, x: 1, y: 2, kind: "plain" },
    { id: 8, x: 2, y: 2, kind: "plain" },
];

/** 玩家从这里落第一笔。 */
export const RELOAD_START = 0;
/** 枪机复位点：连到这里才算画完。 */
export const RELOAD_TARGET = 8;
/** 作答预算：240 个有效作答拍 = 60 个世界拍 = 4 秒。 */
export const RELOAD_ANSWER_TICKS = 240;
/** 盘开着时世界每 4 拍只推进 1 拍。 */
export const RELOAD_ANSWER_PER_WORLD = 4;

/** 只连相邻点（含斜角），不跳格。 */
export function reloadAdjacent(a: number, b: number): boolean {
    if (a === b) {
        return false;
    }
    const na = RELOAD_NODES[a];
    const nb = RELOAD_NODES[b];
    if (na === undefined || nb === undefined) {
        return false;
    }
    return Math.abs(na.x - nb.x) <= 1 && Math.abs(na.y - nb.y) <= 1;
}

/** 路径合法：从 0 起、每步相邻、不重复、末点是 8。 */
export function reloadPathValid(path: number[]): boolean {
    if (path.length < 2) {
        return false;
    }
    if (path[0] !== RELOAD_START) {
        return false;
    }
    if (path[path.length - 1] !== RELOAD_TARGET) {
        return false;
    }
    const seen: boolean[] = [];
    let i = 0;
    for (i = 0; i < path.length; i++) {
        const n = path[i];
        if (n < 0 || n >= RELOAD_NODES.length || seen[n] === true) {
            return false;
        }
        seen[n] = true;
        if (i > 0 && !reloadAdjacent(path[i - 1], n)) {
            return false;
        }
    }
    return true;
}

/** 路径经过铃纹就给回声，经过灯纹就给照明；都没有就是普通推退。 */
export function reloadEffectOf(path: number[]): ReloadEffect {
    if (!reloadPathValid(path)) {
        return "";
    }
    let bell = false;
    let lamp = false;
    let i = 0;
    for (i = 0; i < path.length; i++) {
        const node = RELOAD_NODES[path[i]];
        if (node === undefined) {
            continue;
        }
        if (node.kind === "bell") {
            bell = true;
        }
        if (node.kind === "lamp") {
            lamp = true;
        }
    }
    if (bell) {
        return "echo";
    }
    if (lamp) {
        return "light";
    }
    return "push";
}

/** 效果的短名，给 HUD 与一次性事件用。 */
export function reloadEffectName(e: ReloadEffect): string {
    if (e === "push") {
        return "推退";
    }
    if (e === "echo") {
        return "回声·引到声源";
    }
    if (e === "light") {
        return "照明·照亮遮蔽";
    }
    return "普通";
}
