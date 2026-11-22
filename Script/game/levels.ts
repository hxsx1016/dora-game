/**
 * 关卡地图：字符源 → Level 结构，附带严格校验。
 *
 * 字符表：
 *   #  墙        .  空地
 *   S  起点      E  出口
 *   a/b 踏板（按一下，同组门开一拍）
 *   A/B 门（a→A，b→B）
 *
 * 坐标约定：左上 (0,0)，x 向右，y 向下；rows[y].slice(x, x+1) 就是该格。
 */

export interface Position {
    x: number;
    y: number;
}

export interface Level {
    id: string;
    width: number;
    height: number;
    rows: string[];
    start: Position;
    exit: Position;
    /** 门组 → 门格坐标（A 组、B 组各一个）。 */
    gates: { [group: string]: Position };
    /** 踏板组 → 踏板格坐标。 */
    plates: { [group: string]: Position };
}

/** 地图字符是否合法。 */
function isTileChar(ch: string): boolean {
    return ch === "#" || ch === "." || ch === "S" || ch === "E"
        || ch === "a" || ch === "A" || ch === "b" || ch === "B";
}

/** 按 \n 切行，兼容 \r\n；不保留首尾空行。 */
function splitRows(input: string): string[] {
    const rows: string[] = [];
    let cur = "";
    for (let i = 0; i < input.length; i++) {
        const ch = input.slice(i, i + 1);
        if (ch === "\n") {
            rows.push(cur);
            cur = "";
        } else if (ch === "\r") {
            // CRLF 的 \r 丢掉
        } else {
            cur += ch;
        }
    }
    rows.push(cur);

    const out: string[] = [];
    for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        if (row.length === 0) {
            continue;
        }
        out.push(row);
    }
    return out;
}

/**
 * 解析并校验一张地图。任何一条不满足都抛错，错误信息带关卡 id 与原因。
 */
export function parseLevel(id: string, input: string): Level {
    if (input.length === 0) {
        throw new Error("level " + id + ": map is empty");
    }

    const rows = splitRows(input);
    if (rows.length === 0) {
        throw new Error("level " + id + ": map is empty");
    }

    const width = rows[0].length;
    for (let y = 0; y < rows.length; y++) {
        if (rows[y].length !== width) {
            throw new Error("level " + id + ": row " + y + " width " + rows[y].length + " != " + width);
        }
    }

    const starts: Position[] = [];
    const exits: Position[] = [];
    const plates: { [group: string]: Position } = {};
    const gates: { [group: string]: Position } = {};

    for (let y = 0; y < rows.length; y++) {
        const row = rows[y];
        for (let x = 0; x < width; x++) {
            const ch = row.slice(x, x + 1);
            if (isTileChar(ch) === false) {
                throw new Error("level " + id + ": bad char '" + ch + "' at (" + x + "," + y + ")");
            }
            if (ch === "S") {
                starts.push({ x: x, y: y });
            } else if (ch === "E") {
                exits.push({ x: x, y: y });
            } else if (ch === "a" || ch === "b") {
                const group = ch === "a" ? "A" : "B";
                if (plates[group] !== undefined) {
                    throw new Error("level " + id + ": duplicate plate " + ch + " at (" + x + "," + y + ")");
                }
                plates[group] = { x: x, y: y };
            } else if (ch === "A" || ch === "B") {
                const group = ch;
                if (gates[group] !== undefined) {
                    throw new Error("level " + id + ": duplicate gate " + ch + " at (" + x + "," + y + ")");
                }
                gates[group] = { x: x, y: y };
            }
        }
    }

    if (starts.length !== 1) {
        throw new Error("level " + id + ": expect exactly 1 start S, got " + starts.length);
    }
    if (exits.length !== 1) {
        throw new Error("level " + id + ": expect exactly 1 exit E, got " + exits.length);
    }
    // 单组可以缺席（第一关只有 A 组），但踏板与门必须成对出现。
    for (let i = 0; i < 2; i++) {
        const group = i === 0 ? "A" : "B";
        const plate = group === "A" ? "a" : "b";
        if ((plates[group] === undefined) !== (gates[group] === undefined)) {
            throw new Error("level " + id + ": plate " + plate + " must pair with gate " + group);
        }
    }

    return {
        id: id,
        width: width,
        height: rows.length,
        rows: rows,
        start: starts[0],
        exit: exits[0],
        gates: gates,
        plates: plates,
    };
}

/** 一行的可读摘要，D1 用来确认「读到了什么」。 */
export function describeLevel(level: Level): string {
    return level.id + " size=" + level.width + "x" + level.height
        + " S=(" + level.start.x + "," + level.start.y + ")"
        + " E=(" + level.exit.x + "," + level.exit.y + ")"
        + " A=(" + level.gates["A"].x + "," + level.gates["A"].y + ")"
        + " a=(" + level.plates["A"].x + "," + level.plates["A"].y + ")"
        + (level.gates["B"] === undefined
            ? " B=- b=-"
            : " B=(" + level.gates["B"].x + "," + level.gates["B"].y + ")"
                + " b=(" + level.plates["B"].x + "," + level.plates["B"].y + ")");
}

/**
 * 关卡源文本。第一关 6x1，第二关 7x1；第三关（三行）留到后面再加。
 */
const LEVEL_INPUTS: { [id: string]: string } = {
    "level1": "aS.AE",
    "level2": "baS.ABE",
};

/** 按 id 读取关卡；非法地图会抛错，调用方决定怎么处理。 */
export function loadLevel(id: string): Level {
    const input = LEVEL_INPUTS[id];
    if (input === undefined) {
        throw new Error("level " + id + ": unknown level id");
    }
    return parseLevel(id, input);
}

/** 当前可玩的关卡顺序。 */
export const LEVEL_IDS: string[] = ["level1", "level2"];
