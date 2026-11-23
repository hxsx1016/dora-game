/**
 * 后端契约适配器：只读消费 Script/watch/play.ts 的 Play 实例，
 * 提取每帧快照、边沿触发事件（供 VFX/震屏/顿帧/旁白响应）以及场景内嵌按键提示。
 *
 * 后端零耦合：所有判断都基于 Play 已公开的状态字段。
 */

import { Play, Trace } from "Script/watch/play";
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

/** 推导当前场景内最应高亮的 1–2 个世界空间悬浮交互提示（艾希风场景内嵌指引） */
export function deriveWorldPrompts(p: Play): WorldPrompt[] {
    const out: WorldPrompt[] = [];
    const key = p.room.key;
    const pl = p.player;

    if (p.paused) {
        return out;
    }

    // 序章：递针套
    if (key === "prologue" && p.phase === "prologue-wait") {
        const d = Math.abs(pl.x - p.partner.x);
        out.push({
            x: p.partner.x,
            y: p.partner.y + p.partner.h + 18,
            keyTag: d <= 52 ? "E" : "→",
            label: d <= 52 ? "递出指南针" : "走近小满",
            urgent: d <= 52,
        });
        return out;
    }

    // 小满恐惧冻结：安抚提示最高优先
    if (!p.childMode && p.escort.state === "frozen") {
        const d = Math.abs(pl.x - p.partner.x);
        out.push({
            x: p.partner.x,
            y: p.partner.y + p.partner.h + 18,
            keyTag: d <= CALM_REACH ? "E" : "!",
            label: d <= CALM_REACH ? "敲两下安抚" : "小满受惊停步",
            urgent: true,
        });
    }

    // 掩体提示（城门待就位时不与绞盘提示重叠）
    if (!p.childMode && p.coverNear && !p.coverHug && !(key === "gate" && p.phase === "gate-idle")) {
        out.push({
            x: pl.x,
            y: pl.y + pl.h + 22,
            keyTag: "SHIFT",
            label: "贴靠掩体",
            urgent: key === "gate" && p.phase === "gate-hold",
        });
    }

    // 城门提示
    if (key === "gate" && p.room.story !== undefined && p.room.story.gate !== undefined) {
        const g = p.room.story.gate;
        if (p.phase === "gate-idle") {
            if (p.gateNeedConfirm) {
                out.push({ x: g.winchX, y: 84, keyTag: "E", label: "重新就位", urgent: true });
            } else {
                out.push({ x: g.winchX, y: 84, keyTag: "守", label: "贴近绞盘就位", urgent: false });
            }
        } else if (p.phase === "gate-send") {
            out.push({ x: g.doorX, y: 98, keyTag: "E", label: "送她出城", urgent: true });
        }
    }

    // 板车提示（检查站 & 城外）
    if ((key === "checkpoint" || key === "outside") && !p.cartDocked && p.room.cart.bodyW > 0) {
        const c = p.room.cart;
        const hx = p.cartAxle + c.handleOffset;
        const d = Math.abs(pl.x - hx);
        const dy = Math.abs(pl.y - c.baseY);
        if (d < 95 && dy < 48) {
            out.push({
                x: hx,
                y: c.baseY + c.wheelR + c.bodyH + 26,
                keyTag: p.gripping ? "D" : "E+D",
                label: key === "checkpoint" ? "推车入窝" : "拉车入窝",
                urgent: p.gripping,
            });
        }
    }

    // 城外低拱提示
    if (key === "outside" && p.cartDocked && pl.y < 30 && pl.x > 190 && pl.x < 320 && !pl.crouch) {
        out.push({
            x: 320,
            y: 54,
            keyTag: "CTRL",
            label: "蹲伏穿拱",
            urgent: false,
        });
    }

    // 村口拾瓶 / 投瓶 / 钻桌提示
    if (key === "village") {
        if (!p.hasBottle && p.bottleFly === undefined && p.room.bottle !== undefined) {
            const d = Math.abs(pl.x - p.room.bottle.x);
            if (d < 85) {
                out.push({
                    x: p.room.bottle.x,
                    y: 78,
                    keyTag: "E",
                    label: "拾取玻璃瓶",
                    urgent: true,
                });
            }
        } else if (p.hasBottle && p.aimHold <= 0) {
            out.push({
                x: pl.x,
                y: pl.y + pl.h + 22,
                keyTag: "F",
                label: "按住瞄准 · 松手投向砖地",
                urgent: false,
            });
        }
        if (pl.x > 250 && pl.x < 330 && !pl.crouch) {
            out.push({
                x: 360,
                y: 58,
                keyTag: "CTRL",
                label: "蹲伏钻桌",
                urgent: false,
            });
        }
    }

    // 塔门敲两下
    if (key === "tower" && p.phase === "tower-wait" && p.room.story !== undefined && p.room.story.tower !== undefined) {
        const dx = Math.abs(pl.x - p.room.story.tower.doorX);
        out.push({
            x: p.room.story.tower.doorX,
            y: 96,
            keyTag: "E",
            label: dx <= 50 ? "敲两下" : "走到塔门前",
            urgent: dx <= 50,
        });
    }

    return out;
}
