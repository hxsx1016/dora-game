/**
 * 后端契约适配器：只读消费 Script/watch/play.ts 的 Play 实例，
 * 提取每帧快照、边沿触发事件（供 VFX/震屏/顿帧/旁白响应）以及场景内嵌按键提示。
 *
 * 后端零耦合：所有判断都基于 Play 已公开的状态字段。
 */

import { CART_REACH, Play, Trace } from "Script/watch/play";
import { CALM_REACH } from "Script/watch/escort";

export interface FrameEvents {
    shotFired: boolean;
    shotHit: boolean;
    shotTrace: Trace | undefined;
    enemyKilledX: number;
    enemyKilledY: number;
    playerHit: boolean;
    coverDeflect: boolean;
    rollStarted: boolean;
    knockPulse: boolean;
    knockX: number;
    knockY: number;
    bottleLanded: boolean;
    bottleLandX: number;
    cartJustDocked: boolean;
    checkpointJustHit: boolean;
    caughtTriggered: boolean;
    phaseChanged: boolean;
    roomChanged: boolean;
    gateWaveSpawned: boolean;
}

export interface WorldPrompt {
    x: number;
    y: number;
    keyTag: string;
    label: string;
    urgent: boolean;
}

export class PlayAdapter {
    private prevRoomKey = "";
    private prevPhase = "";
    private prevHp = 3;
    private prevTrace: Trace | undefined;
    private prevCoveredFlash = 0;
    private prevRollT = 0;
    private prevCalmTick = 0;
    private prevKnocks = 0;
    private prevBottleLandT = 0;
    private prevCartDocked = false;
    private prevCheckpoint = -1;
    private prevCaughtT = 0;
    private prevGateSpawned = 0;
    private prevAliveMask: boolean[] = [];

    reset(p?: Play): void {
        this.prevRoomKey = p !== undefined ? p.room.key : "";
        this.prevPhase = p !== undefined ? p.phase : "";
        this.prevHp = p !== undefined ? p.hp : 3;
        this.prevTrace = undefined;
        this.prevCoveredFlash = 0;
        this.prevRollT = 0;
        this.prevCalmTick = 0;
        this.prevKnocks = 0;
        this.prevBottleLandT = 0;
        this.prevCartDocked = p !== undefined ? p.cartDocked : false;
        this.prevCheckpoint = p !== undefined ? p.checkpoint : -1;
        this.prevCaughtT = 0;
        this.prevGateSpawned = p !== undefined ? p.gateSpawned : 0;
        this.prevAliveMask = [];
        if (p !== undefined) {
            let i = 0;
            for (i = 0; i < p.enemies.length; i++) {
                this.prevAliveMask.push(p.enemies[i].alive);
            }
        }
    }

    /** 对比当前帧与上一帧，产出供表现层消费的边沿事件。 */
    sample(p: Play): FrameEvents {
        const roomChanged = this.prevRoomKey !== "" && this.prevRoomKey !== p.room.key;
        if (roomChanged) {
            this.reset(p);
        }

        const shotFired = p.trace !== undefined && p.trace !== this.prevTrace;
        const shotHit = shotFired && p.trace !== undefined && p.trace.hit;
        let enemyKilledX = -9999;
        let enemyKilledY = 0;
        let i = 0;
        for (i = 0; i < p.enemies.length; i++) {
            const wasAlive = i < this.prevAliveMask.length ? this.prevAliveMask[i] : true;
            if (wasAlive && !p.enemies[i].alive) {
                enemyKilledX = p.enemies[i].x;
                enemyKilledY = p.enemies[i].y + p.enemies[i].h * 0.55;
            }
        }

        const playerHit = p.hp < this.prevHp || (this.prevPhase === "gate-hold" && p.phase === "gate-idle" && p.gateNeedConfirm);
        const coverDeflect = p.coveredFlash > this.prevCoveredFlash + 0.05;
        const rollStarted = p.player.rollT > 0 && this.prevRollT <= 0;

        // 敲两下脉冲：安抚第 12/36 拍、塔门敲门、或手动敲击
        let knockPulse = false;
        let knockX = p.player.x;
        let knockY = p.player.y + p.player.h * 0.5;
        if (p.escort.state === "calming") {
            if ((this.prevCalmTick < 12 && p.escort.calmTick >= 12) || (this.prevCalmTick < 36 && p.escort.calmTick >= 36)) {
                knockPulse = true;
                knockX = (p.player.x + p.partner.x) * 0.5;
                knockY = p.partner.y + 28;
            }
        }
        if (p.knocks !== this.prevKnocks && p.knocks > 0) {
            knockPulse = true;
            knockX = p.player.x + p.player.facing * 12;
            knockY = p.player.y + p.player.h * 0.55;
        }

        const bottleLanded = p.bottleLandT > this.prevBottleLandT + 0.1 && p.bottleLandX >= 0;
        const cartJustDocked = p.cartDocked && !this.prevCartDocked;
        const checkpointJustHit = p.checkpoint >= 0 && p.checkpoint !== this.prevCheckpoint;
        const caughtTriggered = p.caughtT > 0 && this.prevCaughtT <= 0;
        const phaseChanged = this.prevPhase !== "" && this.prevPhase !== p.phase;
        const gateWaveSpawned = p.gateSpawned > this.prevGateSpawned;

        // 写回历史
        this.prevRoomKey = p.room.key;
        this.prevPhase = p.phase;
        this.prevHp = p.hp;
        this.prevTrace = p.trace;
        this.prevCoveredFlash = p.coveredFlash;
        this.prevRollT = p.player.rollT;
        this.prevCalmTick = p.escort.calmTick;
        this.prevKnocks = p.knocks;
        this.prevBottleLandT = p.bottleLandT;
        this.prevCartDocked = p.cartDocked;
        this.prevCheckpoint = p.checkpoint;
        this.prevCaughtT = p.caughtT;
        this.prevGateSpawned = p.gateSpawned;
        this.prevAliveMask = [];
        for (i = 0; i < p.enemies.length; i++) {
            this.prevAliveMask.push(p.enemies[i].alive);
        }

        return {
            shotFired,
            shotHit,
            shotTrace: shotFired ? p.trace : undefined,
            enemyKilledX,
            enemyKilledY,
            playerHit,
            coverDeflect,
            rollStarted,
            knockPulse,
            knockX,
            knockY,
            bottleLanded,
            bottleLandX: p.bottleLandX,
            cartJustDocked,
            checkpointJustHit,
            caughtTriggered,
            phaseChanged,
            roomChanged,
            gateWaveSpawned,
        };
    }
}

/** 每次只展示最相关的就近操作。走到可触发的位置才显示按键。 */
export function deriveWorldPrompt(p: Play): WorldPrompt | undefined {
    const room = p.room;
    const player = p.player;
    if (p.paused || !player.alive) {
        return undefined;
    }

    if (room.key === "prologue" && p.phase === "prologue-wait") {
        const reach = room.story?.prologue?.giveReach ?? 46;
        if (Math.abs(player.x - p.partner.x) <= reach) {
            return { x: p.partner.x, y: p.partner.y + p.partner.h + 22, keyTag: "E", label: "递出指南针", urgent: false };
        }
        return undefined;
    }

    if (!p.childMode && p.escort.state === "frozen") {
        if (Math.abs(player.x - p.partner.x) <= CALM_REACH) {
            return { x: p.partner.x, y: p.partner.y + p.partner.h + 22, keyTag: "E", label: "安抚小满", urgent: true };
        }
        return undefined;
    }

    const gate = room.story?.gate;
    if (gate !== undefined) {
        if (p.phase === "gate-idle" && p.gateNeedConfirm &&
            Math.abs(player.x - gate.winchX) <= 24 && player.y < 20 &&
            p.partner.alive && Math.abs(p.partner.x - gate.waitX) <= 60) {
            return { x: gate.winchX, y: 84, keyTag: "E", label: "重新守门", urgent: true };
        }
        if (p.phase === "gate-send" && Math.abs(player.x - gate.doorX) <= 60) {
            return { x: gate.doorX, y: 98, keyTag: "E", label: "送小满出城", urgent: true };
        }
    }

    const cart = room.cart;
    if ((room.key === "checkpoint" || room.key === "outside") && !p.cartDocked && cart.bodyW > 0) {
        const handleX = p.cartAxle + cart.handleOffset;
        if (p.gripping || (Math.abs(player.x - handleX) <= CART_REACH && Math.abs(player.y - cart.baseY) <= 40)) {
            return {
                x: handleX,
                y: cart.baseY + cart.wheelR + cart.bodyH + 46,
                keyTag: "按住 E + D",
                label: room.key === "checkpoint" ? "向前推车" : "向前拉车",
                urgent: false,
            };
        }
    }

    if (room.key === "village" && p.scavChase) {
        return player.crouch ? undefined : {
            x: player.x, y: player.y + player.h + 22, keyTag: "按住 Ctrl", label: "蹲下躲避", urgent: true,
        };
    }

    if (room.key === "village" && !p.passed) {
        const bottle = room.bottle;
        if (p.hasBottle) {
            return {
                x: player.x, y: player.y + player.h + 26,
                keyTag: p.aimHold >= 0.12 ? "松开 F" : "按住 F",
                label: p.aimHold >= 0.12 ? "投瓶" : "瞄准砖地", urgent: false,
            };
        }
        if (p.bottleFly === undefined && bottle !== undefined) {
            const dx = player.x - bottle.x;
            const dy = player.y + player.h * 0.5 - bottle.y;
            if (dx * dx + dy * dy < 56 * 56) {
                return { x: bottle.x, y: bottle.y + 36, keyTag: "E", label: "拾起瓶子", urgent: false };
            }
        }
    }

    const arch = room.arch;
    if ((room.key === "village" || (room.key === "outside" && p.cartDocked)) &&
        arch.h > 0 && !player.crouch && player.y <= arch.y + 28 &&
        player.x >= arch.x0 - 56 && player.x < arch.x1) {
        return {
            x: (arch.x0 + arch.x1) * 0.5, y: arch.y + arch.h + 44,
            keyTag: "按住 Ctrl", label: room.key === "outside" ? "蹲着穿过拱洞" : "蹲着钻过桌下", urgent: false,
        };
    }

    const tower = room.story?.tower;
    if (p.phase === "tower-wait" && tower !== undefined && Math.abs(player.x - tower.doorX) <= 50) {
        return { x: tower.doorX, y: 96, keyTag: "E", label: "敲门", urgent: false };
    }

    if (!p.childMode && p.coverNear && !p.coverHug && !p.gripping &&
        p.escort.state !== "calming" && (gate === undefined || p.phase === "gate-hold")) {
        return {
            x: player.x, y: player.y + player.h + 25,
            keyTag: "按住 Shift", label: "贴靠掩体", urgent: gate !== undefined,
        };
    }
    return undefined;
}
