/**
 * 《向西守望》纯玩法过场阻塞判定（全端共享极简工具，零输入模式文案）。
 */

import { GATE_COUNT_END, Play } from "Script/watch/play";

/** 判断当前房间阶段是否处于电影过场阻塞期（需隐藏战斗虚拟按钮或禁止射瞄）。 */
export function isCutsceneBlockingPlay(p: Play): boolean {
    const rk = p.room.key;
    const ph = p.phase;
    if (rk === "prologue"
        && (ph === "prologue-wake" || ph === "prologue-shadow" || ph === "prologue-hide"
            || ph === "prologue-give" || ph === "prologue-well")) {
        return true;
    }
    if (rk === "gate") {
        if (ph === "gate-farewell" || ph === "gate-hand") return true;
        if (ph === "gate-count" && p.countTick < GATE_COUNT_END) return true;
    }
    if (rk === "tower" && (ph === "tower-knock" || ph === "tower-given" || ph === "tower-end")) {
        return true;
    }
    if (rk === "museum" && ph === "museum-knock") {
        return true;
    }
    return false;
}
