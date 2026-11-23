/**
 * 回合规则：初态、回声位置、门开启判定、单命令推进。
 *
 * 参考《代码实现逻辑.md》第 1 节；把 `level.spawn` 换成 D1 的 `level.start`，
 * 其余规则逐条对齐。坐标与 levels.ts 一致：左上 (0,0)，x 右，y 下。
 *
 * 约定：
 * - REC：本体在地图上走，格子按落点记进 path；不显示回声、不判门。
 * - PLAY：每拍本体与回声同时移动；本体跨入 A/B 门时，用「候选回声格 + 本体旧格」判通行。
 * - 拒绝时返回原状态对象（引用不变），调用方据此区分「局面没变」与「新局面」。
 */
import { Level, Position } from "Script/game/levels";

export type Phase = "REC" | "PLAY" | "WON";
export type Direction = "L" | "R" | "U" | "D" | "W";
export type Command = Direction | "Confirm" | "Retry" | "Rerecord";
export type Outcome = "ok" | "empty" | "outside" | "wall" | "closed_A" | "closed_B"
    | "confirmed" | "auto_confirmed" | "retried" | "rerecorded" | "won" | "inactive";

export interface State {
    phase: Phase;
    body: Position;
    path: Position[];
    ticks: number;
}

export interface Result {
    state: State;
    outcome: Outcome;
}

/** 每拍最多录六步。 */
export const MAX_STEPS = 6;

const OFFSETS: { [key: string]: Position } = {
    L: { x: -1, y: 0 },
    R: { x: 1, y: 0 },
    U: { x: 0, y: -1 },
    D: { x: 0, y: 1 },
    W: { x: 0, y: 0 },
};

/** 地图查询：越界返回 "outside"。 */
export function tileAt(level: Level, pos: Position): string {
    if (pos.x < 0 || pos.x >= level.width || pos.y < 0 || pos.y >= level.height) {
        return "outside";
    }
    return level.rows[pos.y].slice(pos.x, pos.x + 1);
}

/** 新一局录制态。 */
export function start(level: Level): State {
    return { phase: "REC", body: level.start, path: [], ticks: 0 };
}

/** 从已确认路径进入合作态。path 原样共享，不复制。 */
export function playback(level: Level, path: Position[]): State {
    return { phase: "PLAY", body: level.start, path: path, ticks: 0 };
}

/**
 * 第 ticks 拍回声所在格。
 * REC 无回声；0 拍站在起点；其余取 path[min(ticks, len) - 1]（超出后停在末项）。
 */
export function echoAt(level: Level, state: State, ticks: number): Position | undefined {
    if (state.phase === "REC") {
        return undefined;
    }
    if (ticks === 0) {
        return level.start;
    }
    const index = Math.min(ticks, state.path.length) - 1;
    if (index < 0) {
        return level.start;
    }
    return state.path[index];
}

/** 本体或回声是否踩在 group 对应的踏板上。 */
export function pressed(level: Level, group: string, body: Position, echo: Position | undefined): boolean {
    const plate = group === "A" ? "a" : "b";
    if (tileAt(level, body) === plate) {
        return true;
    }
    if (echo !== undefined && tileAt(level, echo) === plate) {
        return true;
    }
    return false;
}

/** 当前画面应显示为开启的门组字符串（"A" / "B" / "AB" / ""）。 */
export function shownGroups(level: Level, state: State): string {
    if (state.phase === "REC") {
        return "";
    }
    const echo = echoAt(level, state, state.ticks);
    const a = pressed(level, "A", state.body, echo) ? "A" : "";
    const b = pressed(level, "B", state.body, echo) ? "B" : "";
    return a + b;
}

/** 一个命令推进一拍。任何被拒绝的命令都返回同一个 before 对象。 */
export function advance(level: Level, before: State, command: Command): Result {
    if (before.phase === "WON") {
        return { state: before, outcome: "inactive" };
    }
    if (command === "Rerecord") {
        return { state: start(level), outcome: "rerecorded" };
    }
    if (command === "Retry") {
        if (before.phase !== "PLAY") {
            return { state: before, outcome: "inactive" };
        }
        return { state: playback(level, before.path), outcome: "retried" };
    }
    if (command === "Confirm") {
        if (before.phase !== "REC") {
            return { state: before, outcome: "inactive" };
        }
        if (before.path.length === 0) {
            return { state: before, outcome: "empty" };
        }
        return { state: playback(level, before.path), outcome: "confirmed" };
    }

    const offset = OFFSETS[command];
    const nextBody: Position = { x: before.body.x + offset.x, y: before.body.y + offset.y };
    const tile = tileAt(level, nextBody);
    if (tile === "outside" || tile === "#") {
        return { state: before, outcome: tile === "#" ? "wall" : "outside" };
    }

    const nextTicks = before.ticks + 1;
    const nextEcho = echoAt(level, before, nextTicks);
    if (command !== "W" && (tile === "A" || tile === "B")) {
        // 录制态不判门；合作态用「候选回声格 + 本体旧格」判本拍能否通过。
        if (before.phase === "REC" || pressed(level, tile, before.body, nextEcho) === false) {
            return { state: before, outcome: tile === "A" ? "closed_A" : "closed_B" };
        }
    }

    if (before.phase === "REC") {
        const path = before.path.slice();
        path.push(nextBody);
        if (path.length >= MAX_STEPS) {
            return { state: playback(level, path), outcome: "auto_confirmed" };
        }
        return { state: { phase: "REC", body: nextBody, path: path, ticks: 0 }, outcome: "ok" };
    }

    const reachedExit = tile === "E";
    const state: State = {
        phase: reachedExit ? "WON" : "PLAY",
        body: nextBody,
        path: before.path,
        ticks: nextTicks,
    };
    return { state: state, outcome: reachedExit ? "won" : "ok" };
}

/** 玩家与回声当前所在格（REC 时回声为 undefined）。 */
export function bodies(level: Level, state: State): { body: Position; echo: Position | undefined } {
    return { body: state.body, echo: echoAt(level, state, state.ticks) };
}
