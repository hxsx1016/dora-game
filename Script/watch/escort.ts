/**
 * 护送：小满的跟随目标、恐惧格与安抚进度。
 *
 * 状态机 follow → seekCover → sheltered → follow；三格恐惧转 frozen，
 * 周戍走近点 E 进 calming，第 12 / 36 / 60 拍各有一个动作时点，之后回 follow。
 * 位移仍由 Play 的 slideX / fallY 统一处理，本模块只出「往哪走、什么姿态、哪一步敲」。
 *
 * 有效危险的去重在 applyDanger 里：同一个 dangerId 只结算一次，重复派发不会叠加。
 */

import { Input } from "Script/watch/input";

export type EscortState = "follow" | "seekCover" | "sheltered" | "frozen" | "calming";

/** 恐惧满格。 */
export const FEAR_MAX = 3;
/** 安抚总拍数：第 12 拍第一声、第 36 拍第二声、第 60 拍恢复移动。 */
export const CALM_TICKS = 60;
/** 周戍离她多近才能开始安抚。 */
export const CALM_REACH = 64;
/** 躲进掩体后停留的拍数。 */
const COVER_TICKS = 90;
/** 跟随时落在周戍身后多少单位。 */
const FOLLOW_GAP = 30;
/** 到这个距离内就不再挪脚，避免左右抖。 */
const STOP_GAP = 6;

export class Escort {
    state: EscortState = "follow";
    fear = 0;
    /** 安抚已过的拍数。 */
    calmTick = 0;
    /** 第一声、第二声是否已经响过。 */
    knock1 = false;
    knock2 = false;
    /** 当前要走的脚底 x。 */
    targetX = 0;
    /** 给 HUD 的一句话。 */
    note = "";

    private coverTick = 0;
    private dangerIds: number[] = [];
    private safeX: number;
    private followGap: number;

    constructor(safeX: number, followGap: number = FOLLOW_GAP) {
        this.safeX = safeX;
        this.followGap = followGap;
        this.targetX = safeX;
    }

    /** 已经停步（站住、不再跟随）。 */
    get stopped(): boolean {
        return this.state === "frozen" || this.state === "calming";
    }

    /** 要低姿：冻结、安抚、躲藏都蹲下。 */
    get crouchPose(): boolean {
        return this.state === "frozen" || this.state === "calming" || this.state === "sheltered";
    }

    /** 这个 dangerId 是否已经结算过。 */
    hasDanger(id: number): boolean {
        let i = 0;
        for (i = 0; i < this.dangerIds.length; i++) {
            if (this.dangerIds[i] === id) {
                return true;
            }
        }
        return false;
    }

    /**
     * 读到一次危险。exposed 为假（被柜台挡住、站得远、周戍挡在中间）时不结算。
     * 同一个 id 第二次派发只返回当前恐惧，不再加格。
     */
    applyDanger(id: number, exposed: boolean, childX: number): number {
        if (!exposed) {
            return this.fear;
        }
        if (this.hasDanger(id)) {
            return this.fear;
        }
        this.dangerIds.push(id);
        if (this.fear < FEAR_MAX) {
            this.fear += 1;
        }
        if (this.fear >= FEAR_MAX) {
            // 三格：停在当前脚下，清空移动目标。
            this.state = "frozen";
            this.targetX = childX;
            this.note = "三格 · 蹲下捂耳";
        } else {
            this.state = "seekCover";
            this.targetX = this.safeX;
            this.note = "跑向安全锚";
        }
        return this.fear;
    }

    /**
     * 每步推进安抚与躲藏，并重算跟随目标。
     * @returns 本步是否吃掉了 E（Play 据此不再触发敲木板 / 车把）。
     */
    update(input: Input, playerX: number, playerFacing: number, childX: number, distance: number): boolean {
        if (this.state === "frozen") {
            if (input.interact.pressed && distance <= CALM_REACH) {
                this.state = "calming";
                this.calmTick = 0;
                this.knock1 = false;
                this.knock2 = false;
                this.note = "周戍蹲下，抬起手";
                return true;
            }
            return false;
        }

        if (this.state === "calming") {
            this.calmTick += 1;
            if (this.calmTick === 12) {
                this.knock1 = true;
                this.note = "第一声";
            }
            if (this.calmTick === 36) {
                this.knock2 = true;
                this.fear = 1;
                this.note = "第二声 · 我听见了";
            }
            if (this.calmTick >= CALM_TICKS) {
                this.state = "follow";
                this.note = "小满站起来，重新跟上";
            }
            return false;
        }

        if (this.state === "sheltered") {
            this.coverTick -= 1;
            if (this.coverTick <= 0) {
                this.state = "follow";
                this.note = "危险过去，继续跟随";
            }
            return false;
        }

        if (this.state === "seekCover") {
            this.targetX = this.safeX;
            if (Math.abs(this.safeX - childX) < STOP_GAP) {
                this.state = "sheltered";
                this.coverTick = COVER_TICKS;
                this.note = "缩在柜台后，捂住耳朵";
            }
            return false;
        }

        this.targetX = playerX - playerFacing * this.followGap;
        return false;
    }

    /** 想要的移动方向：-1 / 0 / 1。停步状态一律 0。 */
    moveDir(childX: number): number {
        if (this.stopped) {
            return 0;
        }
        const dx = this.targetX - childX;
        if (dx > STOP_GAP) {
            return 1;
        }
        if (dx < -STOP_GAP) {
            return -1;
        }
        return 0;
    }
}

/** 从房间标记里找第一个安全锚（kind 1）的 x；没有就返回 -1。 */
export function safeAnchorX(marks: { x: number; kind: number }[]): number {
    let i = 0;
    for (i = 0; i < marks.length; i++) {
        if (marks[i].kind === 1) {
            return marks[i].x;
        }
    }
    return -1;
}
