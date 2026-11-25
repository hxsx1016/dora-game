/**
 * 后端契约适配器：只读消费 Script/watch/play.ts 的 Play 实例，
 * 提取每帧快照、边沿触发事件（供 VFX/震屏/顿帧/旁白响应）以及场景内嵌按键提示。
 *
 * 后端零耦合：所有判断都基于 Play 已公开的状态字段。
 */

import { Play, PlayEvent, Trace } from "Script/watch/play";
import { CALM_REACH } from "Script/watch/escort";
import { inReachDepth } from "Script/watch/depth";

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
    bottleLandY: number;
    cartJustDocked: boolean;
    checkpointJustHit: boolean;
    caughtTriggered: boolean;
    phaseChanged: boolean;
    roomChanged: boolean;
    gateWaveSpawned: boolean;
    /** 本帧由唯一 drainEvents() 入口按 seq 升序取出的原始模拟事件（0 步帧与暂停帧为空） */
    rawEvents: PlayEvent[];
    /** 单调递增的已消费事件序号（供音频与插件防重播核对） */
    eventSeq: number;
    /** 单调递增的房间/实例会话号（切房与重试 reset 时自增），避免不同实例 seq 碰撞 */
    roomSessionId: number;
    /** 当前检查点代号（供音频与插件校验读档/重试恢复态） */
    checkpoint: number;
    /** 已消费事件摘要（seq@tick:name） */
    eventSummary: string[];
}

export function createEmptyFrameEvents(
    roomSessionId: number,
    eventSeq: number,
    checkpoint: number,
): FrameEvents {
    return {
        shotFired: false,
        shotHit: false,
        shotTrace: undefined,
        enemyKilledX: -9999,
        enemyKilledY: 0,
        playerHit: false,
        coverDeflect: false,
        rollStarted: false,
        knockPulse: false,
        knockX: 0,
        knockY: 0,
        bottleLanded: false,
        bottleLandX: -1,
        bottleLandY: 0,
        cartJustDocked: false,
        checkpointJustHit: false,
        caughtTriggered: false,
        phaseChanged: false,
        roomChanged: false,
        gateWaveSpawned: false,
        rawEvents: [],
        eventSeq,
        roomSessionId,
        checkpoint,
        eventSummary: [],
    };
}

export interface WorldPrompt {
    x: number;
    /** 已含纵深的投影高度。 */
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
    private roomSessionId = 0;
    private eventSeq = 0;

    getRoomSessionId(): number {
        return this.roomSessionId;
    }

    getEventSeq(): number {
        return this.eventSeq;
    }

    emptyFrame(p?: Play): FrameEvents {
        return createEmptyFrameEvents(
            this.roomSessionId,
            this.eventSeq,
            p !== undefined ? p.checkpoint : -1,
        );
    }

    reset(p?: Play): void {
        this.roomSessionId += 1;
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

        const rawEvents = p.drainEvents();
        // 按 seq 升序稳定排列，确保单帧补跑多步跨过多次事件时音频与插件严格按发生顺序逐条消费。
        if (rawEvents.length > 1) {
            rawEvents.sort((a, b) => (a.seq !== b.seq ? a.seq - b.seq : a.tick - b.tick));
        }
        const eventSummary: string[] = [];
        const shotFired = p.trace !== undefined && p.trace !== this.prevTrace;
        const shotHit = shotFired && p.trace !== undefined && p.trace.hit;
        let enemyKilledX = -9999;
        let enemyKilledY = 0;
        let i = 0;
        for (i = 0; i < p.enemies.length; i++) {
            const wasAlive = i < this.prevAliveMask.length ? this.prevAliveMask[i] : true;
            if (wasAlive && !p.enemies[i].alive) {
                enemyKilledX = p.enemies[i].x;
                enemyKilledY = p.enemies[i].y + (p.enemies[i].depth ?? 0) + p.enemies[i].h * 0.55;
            }
        }

        let playerHit = p.hp < this.prevHp || (this.prevPhase === "gate-hold" && p.phase === "gate-idle" && p.gateNeedConfirm);
        let coverDeflect = p.coveredFlash > this.prevCoveredFlash + 0.05;
        const rollStarted = p.player.rollT > 0 && this.prevRollT <= 0;

        // 敲击只消费模拟队列，避免重试、换房或补跑多步时重复/漏播。
        let knockPulse = false;
        let knockX = p.player.x;
        let knockY = p.player.y + p.player.depth + p.player.h * 0.5;

        let bottleLanded = p.bottleLandT > this.prevBottleLandT + 0.1 && p.bottleLandX >= 0;
        let bottleLandX = p.bottleLandX;
        let bottleLandY = p.bottleLandY;
        let cartJustDocked = p.cartDocked && !this.prevCartDocked;
        const checkpointJustHit = p.checkpoint >= 0 && p.checkpoint !== this.prevCheckpoint;
        const caughtTriggered = p.caughtT > 0 && this.prevCaughtT <= 0;
        const phaseChanged = this.prevPhase !== "" && this.prevPhase !== p.phase;
        const gateWaveSpawned = p.gateSpawned > this.prevGateSpawned;
        let migratedRoomChange = false;
        for (const event of rawEvents) {
            this.eventSeq += 1;
            eventSummary.push(event.seq + "@" + event.tick + ":" + event.name);
            if (event.name === "knock") {
                knockPulse = true;
                const x = event.data.x;
                knockX = typeof x === "number" ? x : p.player.x;
                knockY = p.escort.state === "calming"
                    ? p.partner.y + p.partner.depth + 28 : p.player.y + p.player.depth + p.player.h * 0.55;
            } else if (event.name === "actorHit" || event.name === "gateFailed") {
                playerHit = true;
            } else if (event.name === "coverBlocked") {
                coverDeflect = true;
            } else if (event.name === "bottleLanded") {
                bottleLanded = true;
                if (typeof event.data.x === "number") {
                    bottleLandX = event.data.x;
                }
                if (typeof event.data.y === "number") {
                    bottleLandY = event.data.y;
                }
            } else if (event.name === "cartDocked") {
                cartJustDocked = true;
            } else if (event.name === "roomChange") {
                migratedRoomChange = true;
            }
        }

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
            bottleLandX,
            bottleLandY,
            cartJustDocked,
            checkpointJustHit,
            caughtTriggered,
            phaseChanged,
            roomChanged: roomChanged || migratedRoomChange,
            gateWaveSpawned,
            rawEvents,
            eventSeq: this.eventSeq,
            roomSessionId: this.roomSessionId,
            checkpoint: p.checkpoint,
            eventSummary,
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
        if (Math.abs(player.x - p.partner.x) <= reach && inReachDepth(player.depth, p.partner.depth)) {
            return { x: p.partner.x, y: p.partner.y + p.partner.depth + p.partner.h + 22, keyTag: "E", label: "递出指南针", urgent: false };
        }
        return undefined;
    }

    if (!p.childMode && p.escort.state === "frozen") {
        if (Math.abs(player.x - p.partner.x) <= CALM_REACH && inReachDepth(player.depth, p.partner.depth)) {
            return { x: p.partner.x, y: p.partner.y + p.partner.depth + p.partner.h + 22, keyTag: "E", label: "安抚小满", urgent: true };
        }
        return undefined;
    }

    const gate = room.story?.gate;
    if (gate !== undefined) {
        if (p.phase === "gate-idle" && p.gateNeedConfirm &&
            Math.abs(player.x - gate.winchX) <= 24 && player.y < 20 && inReachDepth(player.depth) &&
            p.partner.alive && Math.abs(p.partner.x - gate.waitX) <= 60) {
            return { x: gate.winchX, y: 84, keyTag: "E", label: "重新守门", urgent: true };
        }
        if (p.phase === "gate-send" && Math.abs(player.x - gate.doorX) <= 60 && inReachDepth(player.depth)) {
            return { x: gate.doorX, y: 98, keyTag: "E", label: "送小满出城", urgent: true };
        }
    }

    const cart = room.cart;
    if ((room.key === "checkpoint" || room.key === "outside") && !p.cartDocked && cart.bodyW > 0) {
        const handleX = p.cartAxle + cart.handleOffset;
        if (p.gripping || p.cartHandleInReach()) {
            return {
                x: handleX,
                y: cart.baseY + (cart.depth ?? 0) + cart.wheelR + cart.bodyH + 46,
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

    if (room.key !== "prologue" && !p.childMode && p.coverNear && !p.coverHug && !p.gripping &&
        p.escort.state !== "calming" && (gate === undefined || p.phase === "gate-hold")) {
        return {
            x: player.x, y: player.y + player.depth + player.h + 25,
            keyTag: "按住 Shift", label: "贴靠掩体", urgent: gate !== undefined,
        };
    }
    return undefined;
}
