/**
 * 后端契约适配器：只读消费 Script/watch/play.ts 的 Play 实例，
 * 提取每帧快照、边沿触发事件（供 VFX/震屏/顿帧/旁白响应）以及场景内嵌按键提示。
 *
 * 后端零耦合：所有判断都基于 Play 已公开的状态字段。
 */

import { Play, PlayEvent, Trace } from "Script/watch/play";
import { CALM_REACH } from "Script/watch/escort";
import { DEPTH_Y_SCALE, inReachDepth, overlapsDepth } from "Script/watch/depth";

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

    /** 守点末拍已锁存结局路线；storyRoute 为 "child" / "soldier"。 */
    storyRouteLocked: boolean;
    storyRoute: string;
    /** 风台待机（两侧都安全），可长按牵手。 */
    gateRested: boolean;
    /** 牵手完成的那一拍。 */
    handJustTied: boolean;
    /** 牵手中途松手（进度清零）。 */
    handReleased: boolean;
    /** 一次性台词「我们走吧。」。 */
    storyLine: boolean;
    storyLineText: string;
    /** 走出出口的那一拍：child=迈步出城，soldier=牵手转同行段。 */
    storyExit: boolean;
    storyExitRoute: string;
    /** 高石阶背起小满，同行段转首场护送。 */
    carryStarted: boolean;
    /** 慢时换弹：盘开盘 / 结算 / 超时 / 无效重画 / 效果已打出去。 */
    reloadOpened: boolean;
    reloadSolved: boolean;
    reloadEffect: string;
    reloadApplied: boolean;
    reloadAppliedEffect: string;
    reloadTimeout: boolean;
    reloadInvalid: boolean;
    /** 护送段过关：段名与下一房 key（escort2–escort5）。 */
    segmentDone: boolean;
    segmentKey: string;
    segmentNext: string;
    /** 第三段工台：开面板 / 做成 / 装备 / 关闭 / 拒绝。 */
    benchOpened: boolean;
    benchCrafted: boolean;
    benchCraftedWeapon: string;
    benchEquipped: boolean;
    benchClosed: boolean;
    benchRejected: boolean;
    benchRejectReason: string;
    /** 北塔落幕：结局标识 reunion / lamp。 */
    endingReached: boolean;
    ending: string;
    /** 是否正式通关（标题开局 + 合法路线 + 玩法进度）；章节预览为 false。 */
    endingOfficial: boolean;
    /** 登记簿两行：第一行小满，第二行团圆线周戍、单人线空串。 */
    endingLines: string[];
    /** 博物馆：一步推进（cabinet/hall/lamp/knock）与整段完成。 */
    museumStep: boolean;
    museumStepName: string;
    museumDone: boolean;
    /** 后端发射的叙事节拍（red_cart / red_cart_memory / footstep_near / ditch / path_burrow / path_ditch / water_lantern / tower_door 等） */
    storyBeats: { beat: string; x: number; room: string; item: string }[];
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
        storyRouteLocked: false,
        storyRoute: "",
        gateRested: false,
        handJustTied: false,
        handReleased: false,
        storyLine: false,
        storyLineText: "",
        storyExit: false,
        storyExitRoute: "",
        carryStarted: false,
        reloadOpened: false,
        reloadSolved: false,
        reloadEffect: "",
        reloadApplied: false,
        reloadAppliedEffect: "",
        reloadTimeout: false,
        reloadInvalid: false,
        segmentDone: false,
        segmentKey: "",
        segmentNext: "",
        benchOpened: false,
        benchCrafted: false,
        benchCraftedWeapon: "",
        benchEquipped: false,
        benchClosed: false,
        benchRejected: false,
        benchRejectReason: "",
        endingReached: false,
        ending: "",
        endingOfficial: false,
        endingLines: [],
        museumStep: false,
        museumStepName: "",
        museumDone: false,
        storyBeats: [],
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
    /** 长按类提示的进度 0–1；没有进度的提示不填。 */
    progress?: number;
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
                enemyKilledY = p.enemies[i].y + (p.enemies[i].depth ?? 0) * DEPTH_Y_SCALE + p.enemies[i].h * 0.55;
            }
        }

        let playerHit = p.hp < this.prevHp || (this.prevPhase === "gate-hold" && p.phase === "gate-idle" && p.gateNeedConfirm);
        let coverDeflect = p.coveredFlash > this.prevCoveredFlash + 0.05;
        const rollStarted = p.player.rollT > 0 && this.prevRollT <= 0;

        // 敲击只消费模拟队列，避免重试、换房或补跑多步时重复/漏播。
        let knockPulse = false;
        let knockX = p.player.x;
        let knockY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.5;

        let bottleLanded = p.bottleLandT > this.prevBottleLandT + 0.1 && p.bottleLandX >= 0;
        let bottleLandX = p.bottleLandX;
        let bottleLandY = p.bottleLandY;
        let cartJustDocked = p.cartDocked && !this.prevCartDocked;
        const checkpointJustHit = p.checkpoint >= 0 && p.checkpoint !== this.prevCheckpoint;
        const caughtTriggered = p.caughtT > 0 && this.prevCaughtT <= 0;
        const phaseChanged = this.prevPhase !== "" && this.prevPhase !== p.phase;
        const gateWaveSpawned = p.gateSpawned > this.prevGateSpawned;
        let migratedRoomChange = false;

        let storyRouteLocked = false;
        let gateRested = false;
        let handJustTied = false;
        let handReleased = false;
        let storyLine = false;
        let storyLineText = "";
        let storyExit = false;
        let storyExitRoute = "";
        let carryStarted = false;
        let reloadOpened = false;
        let reloadSolved = false;
        let reloadEffect = "";
        let reloadApplied = false;
        let reloadAppliedEffect = "";
        let reloadTimeout = false;
        let reloadInvalid = false;
        let segmentDone = false;
        let segmentKey = "";
        let segmentNext = "";
        let benchOpened = false;
        let benchCrafted = false;
        let benchCraftedWeapon = "";
        let benchEquipped = false;
        let benchClosed = false;
        let benchRejected = false;
        let benchRejectReason = "";
        let endingReached = false;
        let museumStep = false;
        let museumStepName = "";
        let museumDone = false;
        let ending = "";
        let endingOfficial = false;
        let endingLines: string[] = [];
        const storyBeats: { beat: string; x: number; room: string; item: string }[] = [];
        for (const event of rawEvents) {
            this.eventSeq += 1;
            eventSummary.push(event.seq + "@" + event.tick + ":" + event.name);

            if (event.name === "knock") {
                knockPulse = true;
                const x = event.data.x;
                knockX = typeof x === "number" ? x : p.player.x;
                knockY = p.escort.state === "calming"
                    ? p.partner.y + p.partner.depth * DEPTH_Y_SCALE + 28
                    : p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.55;
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
            } else if (event.name === "storyRouteLocked") {
                storyRouteLocked = true;
            } else if (event.name === "gateCountDone" && p.storyRoute === "soldier") {
                gateRested = true;
            } else if (event.name === "handHeld") {
                handJustTied = true;
            } else if (event.name === "handRelease") {
                handReleased = true;
            } else if (event.name === "storyLine") {
                storyLine = true;
                storyLineText = typeof event.data.text === "string" ? event.data.text : "";
            } else if (event.name === "storyExit") {
                storyExit = true;
                storyExitRoute = typeof event.data.route === "string" ? event.data.route : "";
            } else if (event.name === "carryStart") {
                carryStarted = true;
            } else if (event.name === "reloadOpen") {
                reloadOpened = true;
            } else if (event.name === "reloadSolved") {
                reloadSolved = true;
                reloadEffect = typeof event.data.effect === "string" ? event.data.effect : "";
            } else if (event.name === "reloadApplied") {
                reloadApplied = true;
                reloadAppliedEffect = typeof event.data.effect === "string" ? event.data.effect : "";
            } else if (event.name === "reloadTimeout") {
                reloadTimeout = true;
            } else if (event.name === "reloadInvalid") {
                reloadInvalid = true;
            } else if (event.name === "segmentDone") {
                segmentDone = true;
                segmentKey = typeof event.data.room === "string" ? event.data.room : "";
                segmentNext = typeof event.data.next === "string" ? event.data.next : "";
            } else if (event.name === "benchOpen") {
                benchOpened = true;
            } else if (event.name === "benchCraft") {
                benchCrafted = true;
                benchCraftedWeapon = typeof event.data.weapon === "string" ? event.data.weapon : "";
            } else if (event.name === "benchEquip") {
                benchEquipped = true;
            } else if (event.name === "benchClose") {
                benchClosed = true;
            } else if (event.name === "benchRejected") {
                benchRejected = true;
                benchRejectReason = typeof event.data.reason === "string" ? event.data.reason : "";
            } else if (event.name === "museumStep") {
                museumStep = true;
                museumStepName = typeof event.data.step === "string" ? event.data.step : "";
            } else if (event.name === "museumDone") {
                museumDone = true;
            } else if (event.name === "storyBeat") {
                storyBeats.push({
                    beat: typeof event.data.beat === "string" ? event.data.beat : "",
                    x: typeof event.data.x === "number" ? event.data.x : p.player.x,
                    room: typeof event.data.room === "string" ? event.data.room : p.room.key,
                    item: typeof event.data.item === "string" ? event.data.item : "",
                });
            } else if (event.name === "endingReached") {
                endingReached = true;
                ending = typeof event.data.ending === "string" ? event.data.ending : "";
                endingOfficial = event.data.official === true;
                endingLines = Array.isArray(event.data.lines)
                    ? (event.data.lines as unknown[]).map((v) => (typeof v === "string" ? v : ""))
                    : [];
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

            storyRouteLocked,
            storyRoute: p.storyRoute,
            gateRested,
            handJustTied,
            handReleased,
            storyLine,
            storyLineText,
            storyExit,
            storyExitRoute,
            carryStarted,
            reloadOpened,
            reloadSolved,
            reloadEffect,
            reloadApplied,
            reloadAppliedEffect,
            reloadTimeout,
            reloadInvalid,
            segmentDone,
            segmentKey,
            segmentNext,
            benchOpened,
            benchCrafted,
            benchCraftedWeapon,
            benchEquipped,
            benchClosed,
            benchRejected,
            benchRejectReason,
            endingReached,
            ending,
            endingOfficial,
            endingLines,
            museumStep,
            museumStepName,
            museumDone,
            storyBeats,

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
            return { x: p.partner.x, y: p.partner.y + p.partner.depth * DEPTH_Y_SCALE + p.partner.h + 22, keyTag: "E", label: "递出指南针", urgent: false };
        }
        return undefined;
    }

    if (!p.childMode && p.escort.state === "frozen") {
        if (Math.abs(player.x - p.partner.x) <= CALM_REACH && inReachDepth(player.depth, p.partner.depth)) {
            return { x: p.partner.x, y: p.partner.y + p.partner.depth * DEPTH_Y_SCALE + p.partner.h + 22, keyTag: "E", label: "安抚小满", urgent: true };
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
        if (p.phase === "gate-wait") {
            // 风台待机：提示长按，进度随有效拍推进；松手即清零，可重试。
            const ratio = Math.max(0, Math.min(1, p.handTicks / p.handNeedTicks));
            return {
                x: gate.doorX + 30, y: 96,
                keyTag: p.handArmed ? "按住 E" : "松开再按住 E",
                label: p.handTicks > 0 ? "牵起小满" : "把手伸给她",
                urgent: p.handArmed, progress: ratio,
            };
        }
        if (p.phase === "gate-hand") {
            return { x: gate.doorX + 30, y: 96, keyTag: "E", label: "我们走吧。", urgent: false };
        }
        if (p.phase === "gate-walk") {
            return { x: player.x, y: player.y + player.h + 22, keyTag: "→", label: "走向城外", urgent: false };
        }
    }

    // 慢时换弹：盘开着时只提示连线；已画好的枪机在下一枪前提示左键发射。
    if (p.reloadOpen) {
        const ratio = Math.max(0, Math.min(1, p.reloadAnswerTicks / 240));
        return {
            x: player.x, y: player.y + player.depth * DEPTH_Y_SCALE + player.h + 34,
            keyTag: "连线", label: "画到枪机复位", urgent: p.reloadAnswerTicks > 168, progress: ratio,
        };
    }
    if (p.reloadPendingEffect !== "") {
        return {
            x: player.x, y: player.y + player.depth * DEPTH_Y_SCALE + player.h + 34,
            keyTag: "左键", label: "枪机已上势 · 打下一枪", urgent: false,
        };
    }
    if (room.key === "gatepath" && !p.carryOn) {
        return { x: player.x, y: player.y + player.h + 24, keyTag: "→", label: "走到高石阶", urgent: false };
    }
    if (room.key === "escort3" && !p.craftBench.active) {
        const bench = 560;
        if (Math.abs(player.x - bench) <= p.benchReach + 40 && player.y < 12) {
            return { x: bench, y: 92, keyTag: "E", label: "在工台制作", urgent: false };
        }
    }
    if ((room.key === "escort2" || room.key === "escort3" || room.key === "escort4" || room.key === "escort5") && p.carryOn) {
        return { x: player.x, y: player.y + player.h + 24, keyTag: "→", label: "带她走到出口", urgent: false };
    }

    const cart = room.cart;
    if ((room.key === "checkpoint" || room.key === "outside" || room.key === "c2-granary") && !p.cartDocked && cart.bodyW > 0) {
        const handleX = p.cartAxle + cart.handleOffset;
        if (p.gripping || p.cartHandleInReach()) {
            return {
                x: handleX,
                y: cart.baseY + (cart.depth ?? 0) * DEPTH_Y_SCALE + cart.wheelR + cart.bodyH + 46,
                keyTag: room.key === "c2-granary" ? "E 握柄 + D" : "按住 E + D",
                label: room.key === "outside" ? "向前拉车" : "向前推车",
                urgent: false,
            };
        }
    }

    if (p.isCampaign) {
        let bi = 0;
        for (bi = 0; bi < p.boxes.length; bi++) {
            const b = p.boxes[bi];
            if (b.broken === true || b.hidden === true || b.interact === undefined) {
                continue;
            }
            const cx = (b.x0 + b.x1) * 0.5;
            const reach = b.interact.reach ?? 46;
            if (Math.abs(player.x - cx) <= reach + 16 && overlapsDepth(player.depth, b.depth, 16)) {
                const kind = b.interact.kind;
                const label = kind === "open_board" ? "放下窗板"
                    : (kind === "lower_curtain" ? "放下木帘" : "抬起门锁");
                return { x: cx, y: b.y1 + 24, keyTag: "E", label, urgent: true };
            }
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

    const museum = room.story?.museum;
    if (room.key === "museum" && museum !== undefined) {
        if (p.phase === "museum-cabinet") {
            return { x: museum.cabinetX, y: 64 + 44, keyTag: "E", label: "玻璃柜前 · 收枪入袖", urgent: true };
        }
        if (p.phase === "museum-hall") {
            return { x: museum.hallX, y: 120, keyTag: "走到", label: "西厅那头 · 孩子的脚步", urgent: false };
        }
        if (p.phase === "museum-lamp") {
            return { x: museum.lampX, y: 120, keyTag: "E", label: "末厅 · 把灯转向西窗", urgent: true };
        }
        if (p.phase === "museum-return") {
            return { x: museum.cabinetX, y: 64 + 44, keyTag: "E", label: "回柜边 · 轻敲两下", urgent: true };
        }
        if (p.phase === "museum-done") {
            return { x: museum.cabinetX, y: 64 + 44, keyTag: "E", label: "回柜边 · 灯还亮着", urgent: false };
        }
        return undefined;
    }

    const tower = room.story?.tower;
    if (p.phase === "tower-wait" && tower !== undefined && Math.abs(player.x - tower.doorX) <= 50) {
        return { x: tower.doorX, y: 96, keyTag: "E", label: "敲两下 · 守卒应门", urgent: false };
    }
    if (p.phase === "tower-enter") {
        return { x: 605, y: 64, keyTag: "→", label: "跨过门槛 · 走到值夜桌前", urgent: false };
    }
    if (p.phase === "tower-desk") {
        return {
            x: 605, y: 64, keyTag: "按住 E", label: "交出针套、指南针和纸条",
            progress: p.deskHold / 36, urgent: true,
        };
    }
    if (p.phase === "tower-given") {
        return { x: 605, y: 64, keyTag: "", label: "看登记簿 · 西窗的灯", urgent: false };
    }

    if (room.key !== "prologue" && !p.childMode && p.coverNear && !p.coverHug && !p.gripping &&
        p.escort.state !== "calming" && (gate === undefined || p.phase === "gate-hold")) {
        return {
            x: player.x, y: player.y + player.depth * DEPTH_Y_SCALE + player.h + 25,
            keyTag: "按住 Shift", label: "贴靠掩体", urgent: gate !== undefined,
        };
    }
    return undefined;
}
