/**
 * 《向西守望》共同序章 P01 / P02 / P04 演出插件（Wave 1 · feature/fe-03-prologue-ming-art）。
 *
 * 职责边界（对齐 wave1-01-03.md、游戏分镜稿与动画插入规划）：
 * - P01（约 4 秒）：黑场先闻父亲唤「小满」→ 第一人称睁眼床帐透光 → 父亲撑床沿的手陷进褥子
 *   → 顺视线见门缝 → 机位在孩子眼高落稳即交还移动；
 * - P02（约 2 秒接可玩）：门槛内墙上两道人影被一道长影截断 → 瓷碗滚到脚旁撞上门槛
 *   → 切回小满侧视开启限时逃柜（仅屏边叠红晕 + 心跳随剩余时间加快，零按键提示/倒计时面板）
 *   → 入柜收尽红晕、留半拍柜外渐远脚步；重试直接从门口可玩姿态起且零红晕/心跳残留；
 * - P04（约 1 秒叠加动作）：双人经井庭/街口墙根时，枪火将两人影子照上砖墙 → 周戍侧肩挡光
 *   → 小满沿脚边看见磨亮的布行窗板下沿与石槽磨痕，光灭后板边与磨痕仍可辨认（绝不锁移动与镜头）。
 *
 * 协作隔离：
 * - P03（柜边相认补线袖口）与 P05（城门拉袖送别）归 fe-01，本模块在 P02 入柜静默与 P04 墙根与其自然衔接；
 * - 零侵入后端文件，不改 frontend.ts；支持正式模式读后端快照/自然触发与显式排演模式双轨运行；
 * - 全部文字使用 xs/sm/md 正文桶（lxgw-neo-zhisong.ttf），避免龙藏体缺字。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { Play, PROLOGUE_CABINET_X } from "Script/watch/play";
import { AudioDirector } from "Script/watch/fe/audio";
import { DualRouteContract, DualRouteSnapshot } from "Script/watch/fe/contract";
import { CUFF_PALETTE } from "Script/watch/fe/cutscenes/cuff_shots";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import {
    PALETTE,
    RGBA,
    drawSilkVeil,
    fillGradQuad,
    fillHGradRect,
    fillRadialGlow,
    fillVGradRect,
    rgba,
    toColor,
} from "Script/watch/fe/theme";

export type PrologueStage =
    | "idle"
    | "p01_wake"
    | "p02_shadow"
    | "p02_escape"
    | "p02_hidden"
    | "p04_flash";

export type PrologueRehearsalMode =
    | "p01"
    | "p02"
    | "p02_escape"
    | "p04"
    | "sequence";

/** 与 fe-01（P03/P05/G05）同源的明代青布补线袖口配色口径（直接取自 cuff_shots.CUFF_PALETTE，确保四镜视觉严格一致） */
export const CUFF_SHARED_SPEC = {
    indigoCloth: CUFF_PALETTE.indigoBase,
    indigoTrim: CUFF_PALETTE.hemEdge,
    mendStitch: CUFF_PALETTE.stitchThread,
    armWrapCloth: CUFF_PALETTE.armWrapLinen,
    stitchCount: 6,
};

export const PROLOGUE_TIMINGS = {
    p01Duration: 4.0,
    p02ShadowDuration: 2.0,
    p02EscapeDuration: 7.5,
    p02HiddenFadeOut: 0.28,
    p02HiddenLinger: 0.85,
    p04FlashDuration: 1.0,
    heartbeatMinHz: 1.15,
    heartbeatMaxHz: 2.75,
};

const PROLOGUE_AUDIO = {
    fatherWake: "assets/audio/prologue/father_wake.wav",
    nightFire: "assets/audio/prologue/night_distant_fire.wav",
    bedCreak: "assets/audio/prologue/bed_creak.wav",
    doorCommotion: "assets/audio/prologue/door_commotion.wav",
    shadowStrike: "assets/audio/prologue/shadow_strike.wav",
    bowlRoll: "assets/audio/prologue/bowl_roll.wav",
    bowlHit: "assets/audio/prologue/bowl_hit.wav",
    heartbeat: "assets/audio/prologue/heartbeat.wav",
    cabinetShut: "assets/audio/prologue/cabinet_shut.wav",
    footstepsFade: "assets/audio/prologue/footsteps_fade.wav",
    distantGunflash: "assets/audio/prologue/distant_gunflash.wav",
};

export interface PrologueIntroSnapshot {
    stage: PrologueStage;
    active: boolean;
    isRehearsal: boolean;
    stageElapsed: number;
    stageDuration: number;
    escapeRemaining: number;
    escapeDuration: number;
    /** 逃柜排演进度 0=门口可玩起点，1=厨柜入口 */
    escapePlayerX: number;
    vignetteAlpha: number;
    heartbeatHz: number;
    heartbeatBeatCount: number;
    heartbeatPulse: number;
    escapeRetryCount: number;
    p04Active: boolean;
    p04Elapsed: number;
    p04FlashIntensity: number;
    p04PostHintAlpha: number;
    p04TriggeredOnce: boolean;
    blocksPlayerControl: boolean;
    roomSessionId: number;
}

function clamp01(v: number): number {
    return Math.max(0, Math.min(1, v));
}

function smoothstep(edge0: number, edge1: number, x: number): number {
    if (edge1 <= edge0) {
        return x >= edge1 ? 1 : 0;
    }
    const t = clamp01((x - edge0) / (edge1 - edge0));
    return t * t * (3 - 2 * t);
}

function asRecord(value: unknown): Record<string, unknown> | undefined {
    if (value !== undefined && typeof value === "object") {
        return value as Record<string, unknown>;
    }
    return undefined;
}

function readNum(rec: Record<string, unknown> | undefined, key: string): number | undefined {
    if (rec === undefined) {
        return undefined;
    }
    const v = rec[key];
    return typeof v === "number" ? v : undefined;
}

export class PrologueIntroPlugin implements FeRenderPlugin {
    readonly id = "fe03-prologue-intro";

    private stage: PrologueStage = "idle";
    private rehearsalActive = false;
    private rehearsalSequence = false;
    private stageElapsed = 0;
    private stageDuration = 0;

    // P02 限时逃柜状态（重试/切房严格清零）
    private escapeDuration = PROLOGUE_TIMINGS.p02EscapeDuration;
    private escapeRemaining = 0;
    private escapePlayerX = 0;
    private vignetteAlpha = 0;
    private hiddenStartVignette = 0;
    private heartbeatHz = 0;
    private heartbeatPhase = 0;
    private heartbeatBeatCount = 0;
    private heartbeatPulse = 0;
    private escapeRetryCount = 0;
    private attemptSeq = 0;

    // P04 墙根枪火挡光与磨痕留影（绝不锁移动与镜头）
    private p04Active = false;
    private p04Elapsed = 0;
    private p04FlashIntensity = 0;
    private p04PostHintAlpha = 0;
    private p04TriggeredOnce = false;
    private p04AnchorWorldX = 0;
    private p04AnchorWorldY = 0;

    private roomSessionId = 0;
    private fireLoopActive = false;
    private lastRoomKey = "";
    private lastAudio: AudioDirector | undefined;
    private boundContract: DualRouteContract | undefined;
    private enteredContractRehearsal = false;

    onBindPlay(p: Play, _view: DualRouteSnapshot): void {
        this.roomSessionId += 1;
        this.lastRoomKey = p.room.key;
        this.clearTransientState(true);
        this.syncRuntimeHook();
    }

    /** 清空全部瞬时演出、红晕与心跳状态（切房、重试或退出排演时调用） */
    private clearTransientState(clearRehearsal: boolean): void {
        if (this.fireLoopActive && this.lastAudio !== undefined) {
            this.lastAudio.stopLoop("fe03_night_fire", 0);
        }
        if (clearRehearsal) {
            this.rehearsalActive = false;
            this.rehearsalSequence = false;
            if (this.enteredContractRehearsal && this.boundContract !== undefined) {
                this.boundContract.exitRehearsal();
            }
            this.enteredContractRehearsal = false;
        }
        this.stage = "idle";
        this.stageElapsed = 0;
        this.stageDuration = 0;
        this.escapeRemaining = 0;
        this.escapePlayerX = 0;
        this.vignetteAlpha = 0;
        this.hiddenStartVignette = 0;
        this.heartbeatHz = 0;
        this.heartbeatPhase = 0;
        this.heartbeatBeatCount = 0;
        this.heartbeatPulse = 0;
        this.escapeRetryCount = 0;
        this.p04Active = false;
        this.p04Elapsed = 0;
        this.p04FlashIntensity = 0;
        this.p04PostHintAlpha = 0;
        this.p04TriggeredOnce = false;
        this.fireLoopActive = false;
        this.attemptSeq += 1;
    }

    /** 惰性挂接至 package.loaded["watch.fe"].prologue，供验证脚本与排演调用（零改 app.ts/frontend.ts） */
    private syncRuntimeHook(): void {
        const g = globalThis as unknown as { package?: { loaded?: Record<string, unknown> } };
        const loaded = g.package !== undefined ? g.package.loaded : undefined;
        if (loaded === undefined) {
            return;
        }
        const rawFe = loaded["watch.fe"];
        if (rawFe !== undefined && typeof rawFe === "object") {
            const watchFe = rawFe as Record<string, unknown>;
            if (watchFe["prologue"] !== this) {
                watchFe["prologue"] = this;
            }
            if (this.boundContract === undefined && watchFe["contract"] !== undefined && typeof watchFe["contract"] === "object") {
                this.boundContract = watchFe["contract"] as DualRouteContract;
            }
        }
    }

    /** 显式启动序章排演（独立内存态，自动打排演标注，不污染正式流程与档案） */
    startRehearsal(mode: PrologueRehearsalMode, escapeDuration?: number, contract?: DualRouteContract): void {
        this.clearTransientState(false);
        this.rehearsalActive = true;
        this.rehearsalSequence = mode === "sequence";
        if (contract !== undefined) {
            this.boundContract = contract;
        } else {
            this.syncRuntimeHook();
        }
        if (this.boundContract !== undefined && !this.boundContract.isRehearsal()) {
            this.boundContract.enterRehearsal("fe03-prologue");
            this.enteredContractRehearsal = true;
        }
        this.escapeDuration = (escapeDuration !== undefined && escapeDuration > 0.5)
            ? escapeDuration
            : PROLOGUE_TIMINGS.p02EscapeDuration;

        if (mode === "p01" || mode === "sequence") {
            this.enterStage("p01_wake", PROLOGUE_TIMINGS.p01Duration);
        } else if (mode === "p02") {
            this.enterStage("p02_shadow", PROLOGUE_TIMINGS.p02ShadowDuration);
        } else if (mode === "p02_escape") {
            this.enterEscapeFromDoorway(false);
        } else if (mode === "p04") {
            this.triggerP04(0, 0);
        }
    }

    /** 退出排演并彻底清理红晕、心跳与临时态 */
    stopRehearsal(): void {
        this.clearTransientState(true);
    }

    /** 排演精确跳转/定格至指定秒数（便于关键帧截取与灰度复核） */
    seekRehearsal(stage: PrologueStage, seconds: number): void {
        const t = Math.max(0, seconds);
        this.rehearsalActive = true;
        this.rehearsalSequence = false;
        if (stage === "p01_wake") {
            this.enterStage("p01_wake", PROLOGUE_TIMINGS.p01Duration);
            this.stageElapsed = Math.min(PROLOGUE_TIMINGS.p01Duration, t);
            return;
        }
        if (stage === "p02_shadow") {
            this.enterStage("p02_shadow", PROLOGUE_TIMINGS.p02ShadowDuration);
            this.stageElapsed = Math.min(PROLOGUE_TIMINGS.p02ShadowDuration, t);
            return;
        }
        if (stage === "p02_escape") {
            this.enterEscapeFromDoorway(false);
            const clamped = Math.min(this.escapeDuration, t);
            this.stageElapsed = clamped;
            this.escapeRemaining = Math.max(0, this.escapeDuration - clamped);
            const u = clamp01(1 - this.escapeRemaining / Math.max(0.01, this.escapeDuration));
            this.heartbeatHz = PROLOGUE_TIMINGS.heartbeatMinHz
                + u * (PROLOGUE_TIMINGS.heartbeatMaxHz - PROLOGUE_TIMINGS.heartbeatMinHz);
            this.vignetteAlpha = clamp01(0.14 + u * 0.56);
            return;
        }
        if (stage === "p02_hidden") {
            this.enterHiddenCabinet();
            this.stageElapsed = Math.min(PROLOGUE_TIMINGS.p02HiddenLinger, t);
            const fadeK = clamp01(1 - this.stageElapsed / PROLOGUE_TIMINGS.p02HiddenFadeOut);
            this.vignetteAlpha = this.stageElapsed >= PROLOGUE_TIMINGS.p02HiddenFadeOut
                ? 0
                : this.hiddenStartVignette * fadeK;
            return;
        }
        if (stage === "p04_flash") {
            this.stage = "idle";
            this.triggerP04(220, 0);
            this.p04Elapsed = Math.min(PROLOGUE_TIMINGS.p04FlashDuration, t);
            this.recomputeP04Weights();
            return;
        }
        this.clearTransientState(false);
    }

    /** 触发小满钻入厨柜：红晕立即开始收净、心跳停搏、留半拍柜外远去脚步 */
    triggerCabinetEnter(): void {
        if (this.stage === "p02_escape" || this.stage === "p02_shadow") {
            this.enterHiddenCabinet();
        }
    }

    /** 逃柜失败或按 R 重试：直接从门口可玩姿态起步，彻底清除红晕与心跳残留 */
    retryEscape(): void {
        this.enterEscapeFromDoorway(true);
    }

    /** 获取当前只读状态快照，供自动化脚本与审计核对 */
    getSnapshot(): PrologueIntroSnapshot {
        const blocks = this.stage === "p01_wake" || this.stage === "p02_shadow";
        return {
            stage: this.stage,
            active: this.stage !== "idle" || this.p04Active || this.p04PostHintAlpha > 0.01,
            isRehearsal: this.rehearsalActive,
            stageElapsed: this.stageElapsed,
            stageDuration: this.stageDuration,
            escapeRemaining: this.escapeRemaining,
            escapeDuration: this.escapeDuration,
            escapePlayerX: this.escapePlayerX,
            vignetteAlpha: this.vignetteAlpha,
            heartbeatHz: this.heartbeatHz,
            heartbeatBeatCount: this.heartbeatBeatCount,
            heartbeatPulse: this.heartbeatPulse,
            escapeRetryCount: this.escapeRetryCount,
            p04Active: this.p04Active,
            p04Elapsed: this.p04Elapsed,
            p04FlashIntensity: this.p04FlashIntensity,
            p04PostHintAlpha: this.p04PostHintAlpha,
            p04TriggeredOnce: this.p04TriggeredOnce,
            blocksPlayerControl: blocks,
            roomSessionId: this.roomSessionId,
        };
    }

    private enterStage(next: PrologueStage, duration: number): void {
        this.stage = next;
        this.stageElapsed = 0;
        this.stageDuration = duration;
        if (next !== "p02_escape" && next !== "p02_hidden") {
            this.vignetteAlpha = 0;
            this.heartbeatHz = 0;
            this.heartbeatPulse = 0;
            this.heartbeatPhase = 0;
        }
    }

    private enterEscapeFromDoorway(isRetry: boolean): void {
        this.attemptSeq += 1;
        this.stage = "p02_escape";
        this.stageElapsed = 0;
        this.stageDuration = this.escapeDuration;
        this.escapeRemaining = this.escapeDuration;
        this.escapePlayerX = 0;
        // 重试首帧零红晕、零心跳残留，从门口可玩姿态干净起步
        this.vignetteAlpha = 0;
        this.hiddenStartVignette = 0;
        this.heartbeatHz = 0;
        this.heartbeatPhase = 0;
        this.heartbeatBeatCount = 0;
        this.heartbeatPulse = 0;
        if (isRetry) {
            this.escapeRetryCount += 1;
        }
    }

    private enterHiddenCabinet(): void {
        this.hiddenStartVignette = this.vignetteAlpha > 0.01 ? this.vignetteAlpha : 0.35;
        this.stage = "p02_hidden";
        this.stageElapsed = 0;
        this.stageDuration = PROLOGUE_TIMINGS.p02HiddenLinger;
        this.escapeRemaining = 0;
        this.escapePlayerX = 1;
        this.heartbeatHz = 0;
        this.heartbeatPulse = 0;
        this.heartbeatPhase = 0;
    }

    private triggerP04(anchorX: number, anchorY: number): void {
        this.p04Active = true;
        this.p04Elapsed = 0;
        this.p04TriggeredOnce = true;
        this.p04AnchorWorldX = anchorX;
        this.p04AnchorWorldY = anchorY;
        this.recomputeP04Weights();
    }

    private recomputeP04Weights(): void {
        const t = this.p04Elapsed;
        if (t < 0.08) {
            this.p04FlashIntensity = clamp01(t / 0.08);
        } else if (t < 0.55) {
            const k = (t - 0.08) / 0.47;
            const flicker = 0.86 + 0.14 * Math.sin(t * 46);
            this.p04FlashIntensity = clamp01((1 - k * k) * flicker);
        } else {
            this.p04FlashIntensity = 0;
        }
        if (t >= 0.18) {
            const reveal = smoothstep(0.18, 0.42, t);
            const settle = t > 0.55 ? (0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t))) : 0.85;
            this.p04PostHintAlpha = Math.max(this.p04PostHintAlpha, reveal * settle);
            if (t > 0.55) {
                this.p04PostHintAlpha = 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t));
            }
        }
    }

    private cueKey(name: string): string {
        return "fe03:r" + this.roomSessionId + ":a" + this.attemptSeq + ":" + name;
    }

    update(ctx: FePluginContext): void {
        this.lastAudio = ctx.audio;
        this.syncRuntimeHook();
        const p = ctx.p;

        if (this.lastRoomKey !== "" && this.lastRoomKey !== p.room.key) {
            this.onBindPlay(p, ctx.view);
        }

        // 暂停态严格冻结所有演出进度、红晕与心跳节拍
        if (ctx.paused || ctx.worldDt <= 0) {
            return;
        }

        const dt = ctx.worldDt;

        // 1. 正式模式下监听未来后端序章相位与一次性事件（零侵入现有 prologue-wait 流程）
        if (!this.rehearsalActive) {
            this.syncLiveBackendTriggers(ctx);
        }

        // 2. 推进 P01 / P02 主序列状态机
        if (this.stage === "p01_wake") {
            this.stepP01(ctx, dt);
        } else if (this.stage === "p02_shadow") {
            this.stepP02Shadow(ctx, dt);
        } else if (this.stage === "p02_escape") {
            this.stepP02Escape(ctx, dt);
        } else if (this.stage === "p02_hidden") {
            this.stepP02Hidden(ctx, dt);
        }

        // 3. 推进 P04 非阻塞墙根枪火挡光（与玩家移动完全并行）
        if (this.p04Active) {
            this.stepP04(ctx, dt);
        }
    }

    private syncLiveBackendTriggers(ctx: FePluginContext): void {
        const p = ctx.p;
        const pRec = asRecord(p);

        // 监听未来后端可能新增的序章前期相位（当前后端未实现时绝不误触）
        if (p.room.key === "prologue") {
            const phase = p.phase as string;
            if (phase === "prologue-wake" && this.stage !== "p01_wake") {
                this.enterStage("p01_wake", PROLOGUE_TIMINGS.p01Duration);
            } else if (phase === "prologue-shadow" && this.stage !== "p02_shadow") {
                this.enterStage("p02_shadow", PROLOGUE_TIMINGS.p02ShadowDuration);
            } else if (phase === "prologue-escape" && this.stage !== "p02_escape") {
                const dur = readNum(pRec, "escapeDuration") ?? PROLOGUE_TIMINGS.p02EscapeDuration;
                this.escapeDuration = Math.max(0.5, dur);
                this.enterEscapeFromDoorway(false);
            } else if (phase === "prologue-hide" && this.stage !== "p02_hidden") {
                this.enterHiddenCabinet();
            } else if (
                (phase === "prologue-wait" || phase === "prologue-give" || phase === "prologue-follow")
                && (this.stage === "p01_wake"
                    || this.stage === "p02_shadow"
                    || this.stage === "p02_escape"
                    || this.stage === "p02_hidden")
            ) {
                this.stage = "idle";
                this.vignetteAlpha = 0;
                this.heartbeatHz = 0;
                this.heartbeatPulse = 0;
            }
        }

        // 监听未来后端一次性事件（若有）
        let i = 0;
        for (i = 0; i < ctx.events.rawEvents.length; i++) {
            const ev = ctx.events.rawEvents[i];
            const ename = ev.name as string;
            if (ename === "prologueBeat" && ev.data["beat"] === "escapeRetry" && this.stage === "p02_escape") {
                this.retryEscape();
            } else if (ename === "p04WallFlash" || ename === "wallPeekFlash") {
                if (!this.p04TriggeredOnce && p.run.story.segments["p04_wall_flash"] !== true) {
                    p.run.story.segments["p04_wall_flash"] = true;
                    this.triggerP04(p.player.x, p.player.y);
                }
            }
        }

        // 正式局内自然触发 P04：双人同行经兵房巷出口/十字街起始墙根段（跨房持久去重，避免序章与 S1 重复播放两次）
        if (!this.p04TriggeredOnce && p.run.story.segments["p04_wall_flash"] !== true && !p.childMode && p.player.alive && p.partner.alive) {
            const inPrologueCourtyard = p.room.key === "prologue"
                && p.phase === "prologue-follow"
                && p.player.x >= p.ox + 470 && p.player.x <= p.ox + 635;
            const inStreetWallRoot = p.room.key === "street"
                && p.player.x >= p.ox + 115 && p.player.x <= p.ox + 265
                && this.hasAliveEnemy(p);
            const inS1WellRoot = p.room.key === "s1-crossroad"
                && p.player.x >= p.ox + 185 && p.player.x <= p.ox + 320;
            if (inPrologueCourtyard || inStreetWallRoot || inS1WellRoot) {
                p.run.story.segments["p04_wall_flash"] = true;
                this.triggerP04(p.player.x, p.player.y);
            }
        }
    }

    private hasAliveEnemy(p: Play): boolean {
        let i = 0;
        for (i = 0; i < p.enemies.length; i++) {
            if (p.enemies[i].alive) {
                return true;
            }
        }
        return false;
    }

    private stepP01(ctx: FePluginContext, dt: number): void {
        this.stageElapsed += dt;
        const tick = ctx.p.ticks;

        if (!this.fireLoopActive) {
            this.fireLoopActive = true;
            ctx.audio.playLoop("fe03_night_fire", "ambience", PROLOGUE_AUDIO.nightFire, 0.34, tick);
        }
        if (this.stageElapsed >= 0.12) {
            ctx.audio.playOnce(
                this.cueKey("p01_father_call"),
                "voice",
                PROLOGUE_AUDIO.fatherWake,
                0.92,
                "prologue:p01_call",
                tick,
            );
        }
        if (this.stageElapsed >= 1.90) {
            ctx.audio.playOnce(
                this.cueKey("p01_bed_press"),
                "sfx",
                PROLOGUE_AUDIO.bedCreak,
                0.68,
                "prologue:p01_bed_press",
                tick,
            );
        }

        if (this.stageElapsed >= PROLOGUE_TIMINGS.p01Duration) {
            if (this.rehearsalSequence) {
                this.enterStage("p02_shadow", PROLOGUE_TIMINGS.p02ShadowDuration);
            } else if (this.rehearsalActive) {
                this.stageElapsed = PROLOGUE_TIMINGS.p01Duration;
                this.stage = "idle";
            } else {
                // 正式模式严格服从后端 prologue-wake → prologue-shadow 切换，防 worldDt 提前 1 帧切 idle 导致黑闪重播
                this.stageElapsed = PROLOGUE_TIMINGS.p01Duration;
            }
        }
    }

    private stepP02Shadow(ctx: FePluginContext, dt: number): void {
        this.stageElapsed += dt;
        const tick = ctx.p.ticks;

        if (this.stageElapsed >= 0.08) {
            ctx.audio.playOnce(
                this.cueKey("p02_door_commotion"),
                "ambience",
                PROLOGUE_AUDIO.doorCommotion,
                0.62,
                "prologue:p02_commotion",
                tick,
            );
        }
        if (this.stageElapsed >= 0.65) {
            ctx.audio.playOnce(
                this.cueKey("p02_shadow_strike"),
                "sfx",
                PROLOGUE_AUDIO.shadowStrike,
                0.85,
                "prologue:p02_shadow_cut",
                tick,
            );
        }
        if (this.stageElapsed >= 1.02) {
            ctx.audio.playOnce(
                this.cueKey("p02_bowl_roll"),
                "sfx",
                PROLOGUE_AUDIO.bowlRoll,
                0.76,
                "prologue:p02_bowl_roll",
                tick,
            );
        }
        if (this.stageElapsed >= 1.85) {
            ctx.audio.playOnce(
                this.cueKey("p02_bowl_hit"),
                "sfx",
                PROLOGUE_AUDIO.bowlHit,
                0.90,
                "prologue:p02_bowl_hit",
                tick,
            );
        }

        if (this.stageElapsed >= PROLOGUE_TIMINGS.p02ShadowDuration) {
            if (this.rehearsalActive) {
                // 排演态碗停、镜头归位与限时逃柜起表同拍对齐
                this.enterEscapeFromDoorway(false);
            } else {
                // 正式态在末帧定格等待后端切入 prologue-escape，防双时钟抖动
                this.stageElapsed = PROLOGUE_TIMINGS.p02ShadowDuration;
            }
        }
    }

    private stepP02Escape(ctx: FePluginContext, dt: number): void {
        this.stageElapsed += dt;

        // 若正式后端下发剩余时间快照则以之为准，否则在排演/预览态由本地世界时钟推进
        const pRec = asRecord(ctx.p);
        const liveRemain = readNum(pRec, "escapeRemaining");
        if (!this.rehearsalActive && liveRemain !== undefined) {
            this.escapeRemaining = Math.max(0, liveRemain);
        } else {
            this.escapeRemaining = Math.max(0, this.escapeRemaining - dt);
        }

        // 排演态支持真实键鼠操作：移动奔向厨柜、贴近或按 E 入柜
        if (this.rehearsalActive) {
            if (ctx.input.moveX !== 0) {
                this.escapePlayerX = clamp01(this.escapePlayerX + ctx.input.moveX * dt * 0.34);
            }
            if ((this.escapePlayerX >= 0.85 && ctx.input.interact.pressed) || this.escapePlayerX >= 0.98) {
                this.enterHiddenCabinet();
                return;
            }
        }

        // 超时自动重试：排演态本地重置；正式态由后端 prologueBeat(escapeRetry) 同步触发重置，防双重置抖动
        if (this.escapeRemaining <= 0 && (this.rehearsalActive || liveRemain === undefined)) {
            this.retryEscape();
            return;
        }

        const urgency = clamp01(1 - this.escapeRemaining / Math.max(0.01, this.escapeDuration));
        this.heartbeatHz = PROLOGUE_TIMINGS.heartbeatMinHz
            + urgency * (PROLOGUE_TIMINGS.heartbeatMaxHz - PROLOGUE_TIMINGS.heartbeatMinHz);

        const prevCycle = Math.floor(this.heartbeatPhase);
        this.heartbeatPhase += dt * this.heartbeatHz;
        const currCycle = Math.floor(this.heartbeatPhase);
        if (currCycle > prevCycle) {
            this.heartbeatBeatCount += 1;
            this.heartbeatPulse = 1.0;
            ctx.audio.playOnce(
                this.cueKey("p02_hb_" + this.heartbeatBeatCount),
                "sfx",
                PROLOGUE_AUDIO.heartbeat,
                0.44 + 0.48 * urgency,
                "prologue:p02_heartbeat:" + this.heartbeatBeatCount,
                ctx.p.ticks,
            );
        } else {
            // 双搏微峰（lub-dub）
            const frac = this.heartbeatPhase - currCycle;
            if (frac >= 0.20 && frac <= 0.28) {
                this.heartbeatPulse = Math.max(this.heartbeatPulse, 0.56);
            }
            this.heartbeatPulse = Math.max(0, this.heartbeatPulse - dt * 3.8);
        }

        // 跑动期仅在屏边叠加克制暗胭脂红晕，不遮挡中央视线
        this.vignetteAlpha = clamp01(0.14 + urgency * 0.54 + this.heartbeatPulse * 0.16);
    }

    private stepP02Hidden(ctx: FePluginContext, dt: number): void {
        this.stageElapsed += dt;
        const tick = ctx.p.ticks;

        ctx.audio.playOnce(
            this.cueKey("p02_cabinet_shut"),
            "sfx",
            PROLOGUE_AUDIO.cabinetShut,
            0.78,
            "prologue:p02_cabinet_shut",
            tick,
        );

        // 入柜即在 0.28s 内彻底收尽红晕、停搏心跳
        if (this.stageElapsed >= PROLOGUE_TIMINGS.p02HiddenFadeOut) {
            this.vignetteAlpha = 0;
        } else {
            this.vignetteAlpha = this.hiddenStartVignette
                * (1 - this.stageElapsed / PROLOGUE_TIMINGS.p02HiddenFadeOut);
        }
        this.heartbeatHz = 0;
        this.heartbeatPulse = 0;

        // 留半拍柜外渐远脚步声
        if (this.stageElapsed >= 0.30) {
            ctx.audio.playOnce(
                this.cueKey("p02_footsteps_fade"),
                "sfx",
                PROLOGUE_AUDIO.footstepsFade,
                0.65,
                "prologue:p02_footsteps_fade",
                tick,
            );
        }

        if (this.stageElapsed >= PROLOGUE_TIMINGS.p02HiddenLinger) {
            this.stageElapsed = PROLOGUE_TIMINGS.p02HiddenLinger;
            this.vignetteAlpha = 0;
        }
    }

    private stepP04(ctx: FePluginContext, dt: number): void {
        if (this.p04Elapsed === 0) {
            ctx.audio.playOnce(
                this.cueKey("p04_gunflash"),
                "sfx",
                PROLOGUE_AUDIO.distantGunflash,
                0.78,
                "prologue:p04_gunflash",
                ctx.p.ticks,
            );
        }
        this.p04Elapsed += dt;
        this.recomputeP04Weights();
        if (this.p04Elapsed >= PROLOGUE_TIMINGS.p04FlashDuration) {
            this.p04Elapsed = PROLOGUE_TIMINGS.p04FlashDuration;
            this.p04FlashIntensity = 0;
            this.p04Active = false;
            // 光灭后保留磨亮窗板下沿与石槽磨痕的可读微反光（不锁走动与镜头）
            this.p04PostHintAlpha = 0.42;
        }
    }

    /** 世界层叠绘：P02 逃柜目标厨柜环境缝光引导 + P04 枪火双人墙影与磨痕（绝不阻断走动与镜头） */
    drawActorsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        _worldArt: FePluginContext["worldArt"],
        ctx: FePluginContext,
    ): void {
        if (this.stage === "p02_escape" && !this.rehearsalActive && ctx.p.room.key === "prologue") {
            const cam = ctx.cam;
            const cabX = cam.sx(ctx.p.ox + PROLOGUE_CABINET_X + 18);
            const cabY = cam.sy(0, 0);
            const pulse = 0.65 + 0.35 * Math.sin(this.stageElapsed * 6.5);
            const sway = Math.sin(this.stageElapsed * 9.0) * cam.len(2.5);
            // 纯环境倒柜门缝暖光呼吸，无按键/箭头污染，确保低引导下也能一眼辨认藏身目标
            fillRadialGlow(
                fgGlow,
                cabX + sway,
                cabY + cam.len(34),
                cam.len(38),
                cam.len(46),
                Color(232, 178, 104, Math.round(68 * pulse)),
                Color(186, 118, 56, 0),
                14,
            );
            fgDraw.drawSegment(
                Vec2(cabX + sway, cabY + cam.len(4)),
                Vec2(cabX + sway, cabY + cam.len(54)),
                2.0,
                Color(238, 198, 134, Math.round(165 * pulse)),
            );
        }
        if (!this.p04Active && this.p04PostHintAlpha <= 0.01) {
            return;
        }
        this.drawP04WorldAction(fgDraw, fgGlow, ctx);
    }

    /** 过场与屏幕覆盖层：P01 睁眼、P02 墙影滚碗 / 逃柜红晕 / 入柜收声 */
    drawCutsceneOverlay(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: FePluginContext["uiArt"],
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        if (this.stage === "p01_wake") {
            this.drawP01Wake(uiDraw, uiInkDraw, uiArt, uiGlow, ctx);
            return true;
        }
        if (this.stage === "p02_shadow") {
            this.drawP02ShadowAndBowl(uiDraw, uiInkDraw, uiGlow, ctx);
            return true;
        }
        if (this.stage === "p02_escape") {
            this.drawP02EscapeVignette(uiDraw, uiInkDraw, uiGlow, ctx);
            // P02 限时逃柜期间压隐战斗 HUD 与底部教学长条，保持纯屏边红晕 + 心跳的窒息紧张感
            return true;
        }
        if (this.stage === "p02_hidden") {
            this.drawP02HiddenCabinet(uiDraw, uiInkDraw, uiGlow, ctx);
            return true;
        }
        return false;
    }

    // ==================== P01：父亲叫醒小满（4 秒） ====================

    private drawP01Wake(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: FePluginContext["uiArt"],
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): void {
        const w = ctx.uiW;
        const h = ctx.uiH;
        const t = this.stageElapsed;

        // 全屏深墨底，彻底隔绝底层场景
        uiDraw.drawRect(Rect(0, 0, w, h), Color(6, 7, 11, 255));

        // 阶段比例
        const wakeOpen = smoothstep(0.75, 2.10, t);
        const blinkDip = t >= 1.25 && t <= 1.62 ? Math.sin(((t - 1.25) / 0.37) * Math.PI) * 0.24 : 0;
        const eyeOpen = clamp01(wakeOpen - blinkDip);
        const sitPan = smoothstep(2.65, 3.85, t);
        const handPress = smoothstep(1.75, 2.35, t) * (1 - smoothstep(3.15, 3.85, t) * 0.65);
        const fadeOut = 1 - smoothstep(3.72, 4.0, t);

        if (eyeOpen > 0.01) {
            const panX = -sitPan * w * 0.16;
            const sitLiftY = sitPan * h * 0.06;
            const fireFlicker = 0.84 + 0.16 * Math.sin(t * 9.5) * Math.cos(t * 5.2);

            // 1. 粗麻床帐背景（暖橙火光透帐 + 右侧冷月青影）
            fillVGradRect(
                uiDraw,
                0,
                0,
                w,
                h,
                Color(16, 14, 18, Math.round(255 * eyeOpen * fadeOut)),
                Color(34, 24, 24, Math.round(255 * eyeOpen * fadeOut)),
            );
            // 透过粗麻床帐的火光暖晕
            fillRadialGlow(
                uiGlow,
                w * 0.34 + panX * 0.4,
                h * 0.62 - sitLiftY,
                w * 0.42,
                h * 0.36,
                Color(186, 108, 56, Math.round(68 * fireFlicker * eyeOpen * fadeOut)),
                Color(120, 52, 28, 0),
                18,
            );
            // 麻布垂褶竖纹（极克制像素质感条带）
            let fold = 0;
            for (fold = 0; fold < 11; fold++) {
                const fx = w * (0.04 + fold * 0.095) + panX * 0.55 + Math.sin(t * 1.4 + fold) * 4;
                const fw = 22 + (fold % 3) * 10;
                const col = (fold & 1) === 0
                    ? Color(52, 42, 36, Math.round(64 * eyeOpen * fadeOut))
                    : Color(24, 20, 22, Math.round(78 * eyeOpen * fadeOut));
                fillHGradRect(uiDraw, fx, h * 0.24, fw, h * 0.72, Color(col.r, col.g, col.b, 0), col);
            }

            // 2. 右侧门缝（顺父亲转头方向渐渐入画，冷月与火光并透）
            const doorVis = smoothstep(2.25, 3.20, t);
            if (doorVis > 0.01) {
                const doorX = w * 0.84 + panX * 0.95;
                const crackW = 14 + sitPan * 18;
                const doorBot = h * 0.14 - sitLiftY * 0.4;
                const doorH = h * 0.72;
                // 门框暗木两侧
                uiDraw.drawRect(Rect(doorX - 46, doorBot, 46, doorH), Color(14, 12, 14, Math.round(235 * doorVis * fadeOut)));
                uiDraw.drawRect(Rect(doorX + crackW, doorBot, 54, doorH), Color(14, 12, 14, Math.round(235 * doorVis * fadeOut)));
                // 门缝冷月 + 远火斜光
                fillVGradRect(
                    uiDraw,
                    doorX,
                    doorBot,
                    crackW,
                    doorH,
                    Color(142, 168, 186, Math.round(170 * doorVis * fadeOut)),
                    Color(214, 168, 118, Math.round(195 * doorVis * fireFlicker * fadeOut)),
                );
                fillGradQuad(
                    uiGlow,
                    doorX, doorBot, Color(164, 188, 204, Math.round(64 * doorVis * fadeOut)),
                    doorX + crackW, doorBot, Color(214, 164, 108, Math.round(54 * doorVis * fadeOut)),
                    doorX - 135, doorBot - 40, Color(120, 148, 170, 0),
                    doorX - 190, doorBot + doorH * 0.48, Color(180, 130, 82, 0),
                );
            }

            // 3. 床沿、粗布褥子与父亲撑住床沿陷进褥子的手
            const bedTopY = h * 0.27 - sitLiftY;
            const dipX = w * 0.52 + panX * 0.7;
            const pressDepth = 22 * handPress;
            // 褥面轮廓（受掌压向内下陷）
            uiDraw.drawPolygon([
                Vec2(0, 0),
                Vec2(w, 0),
                Vec2(w, bedTopY + 10),
                Vec2(dipX + 110, bedTopY + 6),
                Vec2(dipX + 38, bedTopY - pressDepth * 0.85),
                Vec2(dipX - 34, bedTopY - pressDepth),
                Vec2(dipX - 108, bedTopY + 5),
                Vec2(0, bedTopY + 12),
            ], Color(30, 27, 32, Math.round(248 * eyeOpen * fadeOut)));

            // 褥面压痕高光与褶皱线
            uiInkDraw.drawSegment(
                Vec2(dipX - 96, bedTopY + 4),
                Vec2(dipX - 30, bedTopY - pressDepth + 2),
                1.6,
                Color(124, 114, 102, Math.round(145 * eyeOpen * fadeOut)),
            );
            uiInkDraw.drawSegment(
                Vec2(dipX - 30, bedTopY - pressDepth + 2),
                Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2),
                1.4,
                Color(92, 82, 74, Math.round(165 * eyeOpen * fadeOut)),
            );
            uiInkDraw.drawSegment(
                Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2),
                Vec2(dipX + 106, bedTopY + 5),
                1.5,
                Color(138, 122, 106, Math.round(140 * eyeOpen * fadeOut)),
            );

            // 父亲宽厚手掌撑住床沿（暗粗布袖口 + 指背火光微边）
            if (handPress > 0.02) {
                const hx = dipX;
                const hy = bedTopY - pressDepth + 14;
                const ha = Math.round(245 * handPress * fadeOut);
                // 粗布前臂与袖口
                uiDraw.drawPolygon([
                    Vec2(hx - 62, hy + 135),
                    Vec2(hx - 14, hy + 142),
                    Vec2(hx + 8, hy + 28),
                    Vec2(hx - 36, hy + 24),
                ], Color(42, 46, 54, ha));
                // 手背与撑褥五指轮廓
                uiDraw.drawPolygon([
                    Vec2(hx - 38, hy + 26),
                    Vec2(hx + 16, hy + 28),
                    Vec2(hx + 34, hy + 2),
                    Vec2(hx + 22, hy - 14),
                    Vec2(hx - 26, hy - 12),
                    Vec2(hx - 42, hy + 4),
                ], Color(148, 112, 86, ha));
                // 指节分缝与指背暖光缘
                let f = 0;
                for (f = 0; f < 3; f++) {
                    const fx = hx - 16 + f * 15;
                    uiInkDraw.drawSegment(Vec2(fx, hy + 10), Vec2(fx + 2, hy - 11), 1.4, Color(68, 46, 36, ha));
                }
                uiInkDraw.drawSegment(
                    Vec2(hx - 34, hy + 22),
                    Vec2(hx + 24, hy + 12),
                    1.8,
                    Color(214, 168, 126, Math.round(175 * handPress * fireFlicker * fadeOut)),
                );
            }
        }

        // 4. 上下眼睑柔边开合遮幅（第一人称睁眼核心体感）
        const lidH = h * 0.52 * (1 - eyeOpen);
        if (lidH > 1) {
            uiDraw.drawRect(Rect(0, h - lidH, w, lidH), Color(5, 6, 9, 255));
            uiDraw.drawRect(Rect(0, 0, w, lidH), Color(5, 6, 9, 255));
            const feather = Math.min(46, h * 0.08);
            fillVGradRect(uiDraw, 0, h - lidH - feather, w, feather, Color(5, 6, 9, 0), Color(5, 6, 9, 235));
            fillVGradRect(uiDraw, 0, lidH, w, feather, Color(5, 6, 9, 235), Color(5, 6, 9, 0));
        }

        // 5. 排演态黑场父亲唤「小满。」极简素幕字幕（正式模式交由 NarrativeRenderer.drawCutsceneDialogue 呈现 D30/D31）
        if (this.rehearsalActive) {
            const callAlpha = smoothstep(0.10, 0.32, t) * (1 - smoothstep(1.05, 1.55, t));
            if (callAlpha > 0.02) {
                drawSilkVeil(uiDraw, uiArt, "p01_call_veil", w * 0.5, h * 0.14, 240, 44, PALETTE.inkWash, 0.72 * callAlpha, 0);
                ctx.texts.put(
                    "sm",
                    "「小满。」",
                    w * 0.5,
                    h * 0.14,
                    toColor(PALETTE.textBright),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    2.0,
                    callAlpha,
                    0.08,
                );
            }
        }
    }

    // ==================== P02 前段：门槛墙影与瓷碗滚停（2 秒） ====================

    private drawP02ShadowAndBowl(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): void {
        const w = ctx.uiW;
        const h = ctx.uiH;
        const t = this.stageElapsed;
        const fireFlicker = 0.85 + 0.15 * Math.sin(t * 14.0);

        // 1. 门槛内青砖土墙与地面
        const floorY = h * 0.25;
        fillVGradRect(uiDraw, 0, floorY, w, h - floorY, Color(38, 30, 28, 255), Color(20, 18, 24, 255));
        fillVGradRect(uiDraw, 0, 0, w, floorY, Color(12, 12, 16, 255), Color(28, 24, 24, 255));

        // 砖墙纹理横缝
        let row = 1;
        for (row = 1; row <= 6; row++) {
            const ry = floorY + (h - floorY) * (row / 7);
            uiInkDraw.drawSegment(Vec2(0, ry), Vec2(w, ry), 0.9, Color(18, 16, 20, 110));
        }

        // 左侧门框外透入的颤动火光
        fillRadialGlow(
            uiGlow,
            w * 0.12,
            floorY + h * 0.28,
            w * 0.52,
            h * 0.44,
            Color(198, 116, 56, Math.round(78 * fireFlicker)),
            Color(120, 50, 24, 0),
            18,
        );

        // 2. 墙上两道父母人影（0.0–0.68s 完整，0.68s 起被一道拉长袭城者长影斜切截断）
        const cutProg = smoothstep(0.62, 1.05, t);
        const tremble = Math.sin(t * 18) * 3;
        const p1X = w * 0.42 + tremble;
        const p2X = w * 0.56 - tremble * 0.6;
        const parentDrop = cutProg * 36;
        // 左侧较高人影（父亲）
        uiDraw.drawPolygon([
            Vec2(p1X - 42, floorY),
            Vec2(p1X + 34, floorY),
            Vec2(p1X + 26 + cutProg * 26, floorY + 218 - parentDrop),
            Vec2(p1X - 28 + cutProg * 14, floorY + 226 - parentDrop),
        ], Color(10, 9, 13, 215));
        uiDraw.drawCircle(Vec2(p1X + cutProg * 20, floorY + 248 - parentDrop), 24, Color(10, 9, 13, 215));
        // 右侧稍矮人影（母亲）
        uiDraw.drawPolygon([
            Vec2(p2X - 36, floorY),
            Vec2(p2X + 32, floorY),
            Vec2(p2X + 20 + cutProg * 32, floorY + 186 - parentDrop * 0.8),
            Vec2(p2X - 24 + cutProg * 18, floorY + 194 - parentDrop * 0.8),
        ], Color(11, 10, 14, 205));
        uiDraw.drawCircle(Vec2(p2X - 2 + cutProg * 26, floorY + 214 - parentDrop * 0.8), 21, Color(11, 10, 14, 205));

        // 突入截断两道人影的袭城者长影（长杆火器/刀影斜切整墙）
        if (cutProg > 0.01) {
            const sx = w * (0.02 + cutProg * 0.46);
            uiDraw.drawPolygon([
                Vec2(0, floorY),
                Vec2(sx + 58, floorY),
                Vec2(sx + 135, h),
                Vec2(0, h),
            ], Color(6, 6, 10, Math.round(238 * cutProg)));
            // 斜切长杆兵器剪影
            uiDraw.drawPolygon([
                Vec2(sx + 20, floorY + 160),
                Vec2(sx + 275 * cutProg, floorY + 260),
                Vec2(sx + 268 * cutProg, floorY + 276),
                Vec2(sx + 14, floorY + 178),
            ], Color(5, 5, 8, Math.round(235 * cutProg)));
        }

        // 3. 木门槛（地面实木横坎）
        const threshX = w * 0.66;
        uiDraw.drawRect(Rect(threshX, floorY - 22, 26, 30), Color(54, 38, 28, 255), 1.2, Color(112, 86, 62, 210));
        uiInkDraw.drawSegment(Vec2(threshX, floorY + 8), Vec2(threshX + 26, floorY + 8), 1.6, Color(156, 128, 96, 200));

        // 4. 粗瓷碗从门后滚入并撞上门槛停在小满脚旁（1.00–1.85s 滚跳，1.85s 稳停）
        const rollK = smoothstep(0.98, 1.85, t);
        if (t >= 0.96) {
            const startX = w * 0.14;
            const stopX = threshX - 18;
            const bx = startX + (stopX - startX) * rollK;
            const bounce = rollK < 1 ? Math.abs(Math.sin(rollK * Math.PI * 3.5)) * (1 - rollK) * 18 : 0;
            const by = floorY + 8 + bounce;
            const tilt = rollK * Math.PI * 3.2;
            const br = 16;

            // 瓷碗地面投影
            uiDraw.drawEllipse(Vec2(bx, floorY + 2), 18, 4.5, Color(6, 6, 10, 175));
            // 粗灰青瓷碗轮廓
            uiDraw.drawCircle(Vec2(bx, by), br, Color(168, 164, 152, 245));
            uiDraw.drawEllipse(
                Vec2(bx + Math.cos(tilt) * 4, by + Math.sin(tilt) * 4),
                br * 0.72,
                br * 0.36,
                Color(64, 60, 56, 235),
            );
            // 碗沿磕出的一道冷白微光与撞坎微震尘粒
            uiInkDraw.drawArc(Vec2(bx, by), br - 1, 20, 155, 1.5, Color(224, 222, 214, 215));
            if (t >= 1.84) {
                const impact = 1 - smoothstep(1.84, 2.0, t);
                if (impact > 0.02) {
                    uiInkDraw.drawSegment(
                        Vec2(threshX - 2, floorY + 8),
                        Vec2(threshX - 14 - (1 - impact) * 12, floorY + 18 + (1 - impact) * 8),
                        1.4,
                        Color(220, 210, 194, Math.round(210 * impact)),
                    );
                }
            }
        }

        // 5. 右缘微微晃动的厨柜木门边角（纯环境构图引导，无文字提示）
        const wobble = Math.sin(t * 11) * 5;
        uiDraw.drawRect(Rect(w - 72 + wobble * 0.3, floorY, 64, 142), Color(42, 30, 24, 250), 1.1, Color(94, 72, 54, 180));
        uiInkDraw.drawSegment(Vec2(w - 70 + wobble, floorY + 6), Vec2(w - 70 + wobble, floorY + 136), 2.0, Color(146, 118, 88, 185));

        // 上下克制电影黑边
        uiDraw.drawRect(Rect(0, h - 46, w, 46), Color(6, 8, 12, 244));
        uiDraw.drawRect(Rect(0, 0, w, 46), Color(6, 8, 12, 244));
    }

    // ==================== P02 可玩逃柜态：仅屏边红晕 + 心跳搏动 ====================

    private drawP02EscapeVignette(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): void {
        const w = ctx.uiW;
        const h = ctx.uiH;
        const a = clamp01(this.vignetteAlpha);

        if (a > 0.005) {
            const edgeX = w * (0.09 + 0.06 * a);
            const edgeY = h * (0.11 + 0.07 * a);
            const peakA = Math.round(168 * a);
            const deep = PALETTE.crimsonDeep;
            const rouge = PALETTE.rouge;
            const cEdge = Color(deep.r, deep.g, deep.b, peakA);
            const cZero = Color(deep.r, deep.g, deep.b, 0);

            fillHGradRect(uiDraw, 0, 0, edgeX, h, cEdge, cZero);
            fillHGradRect(uiDraw, w - edgeX, 0, edgeX, h, cZero, cEdge);
            fillVGradRect(uiDraw, 0, 0, w, edgeY, cEdge, cZero);
            fillVGradRect(uiDraw, 0, h - edgeY, w, edgeY, cZero, cEdge);

            // 心跳瞬间的极微弱胭脂暗脉，绝不遮挡画面中央
            if (this.heartbeatPulse > 0.02) {
                const pa = Math.round(62 * this.heartbeatPulse * a);
                const cPulse = Color(rouge.r, rouge.g, rouge.b, pa);
                const cPulseZero = Color(rouge.r, rouge.g, rouge.b, 0);
                fillHGradRect(uiGlow, 0, 0, edgeX * 0.72, h, cPulse, cPulseZero);
                fillHGradRect(uiGlow, w - edgeX * 0.72, 0, edgeX * 0.72, h, cPulseZero, cPulse);
            }
        }

        // 排演态绘制极简侧视逃柜空间示意（门框 → 奔跑小满轮廓 → 晃动厨柜门），正式态留给底层实景
        if (this.rehearsalActive) {
            const groundY = h * 0.24;
            const doorX = w * 0.14;
            const cabX = w * 0.80;
            const childX = doorX + (cabX - doorX) * this.escapePlayerX;
            const wobble = Math.sin(this.stageElapsed * 9.5) * 4;

            // 门口侧框与滚停的瓷碗
            uiInkDraw.drawRect(Rect(doorX - 18, groundY, 16, 130), Color(48, 36, 28, 220));
            uiDraw.drawCircle(Vec2(doorX + 18, groundY + 8), 8, Color(168, 164, 152, 220));
            // 晃动的木厨柜与缝隙
            uiDraw.drawRect(Rect(cabX, groundY, 74, 108), Color(42, 31, 24, 240), 1.2, Color(118, 92, 68, 195));
            uiInkDraw.drawSegment(Vec2(cabX + 8 + wobble * 0.5, groundY + 6), Vec2(cabX + 8 + wobble * 0.5, groundY + 100), 2.2, Color(176, 144, 106, 210));
            // 小满奔跑剪影（复用小满像素帧，缺失则绘轮廓）
            if (!ctx.uiArt.tryPlace("child_run", "p02_escape_child", childX, groundY, 46, 74, {
                facing: 1,
                frame: Math.floor(this.stageElapsed * 10),
                layer: 3,
            })) {
                uiDraw.drawRect(Rect(childX - 12, groundY, 24, 54), Color(168, 72, 54, 235));
            }
        }
    }

    // ==================== P02 入柜收声：红晕收尽 + 半拍渐远脚步 ====================

    private drawP02HiddenCabinet(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): void {
        const w = ctx.uiW;
        const h = ctx.uiH;
        const t = this.stageElapsed;
        const closeK = smoothstep(0.0, 0.26, t);

        // 厨柜内暗木门缝视角（两侧木板合拢，中央留一线冷月柜缝）
        const slitW = w * (0.28 - 0.21 * closeK);
        const leftW = (w - slitW) * 0.5;
        uiDraw.drawRect(Rect(0, 0, leftW, h), Color(7, 7, 10, 248));
        uiDraw.drawRect(Rect(w - leftW, 0, leftW, h), Color(7, 7, 10, 248));
        uiInkDraw.drawSegment(Vec2(leftW, 0), Vec2(leftW, h), 1.4, Color(66, 52, 40, 175));
        uiInkDraw.drawSegment(Vec2(w - leftW, 0), Vec2(w - leftW, h), 1.4, Color(66, 52, 40, 175));

        // 柜缝外一缕冷灰暗影（模拟脚步远去后归于寂静）
        const footFade = 1 - smoothstep(0.30, 0.80, t);
        if (footFade > 0.02) {
            const shadowX = w * 0.5 + (1 - footFade) * 38;
            fillRadialGlow(
                uiGlow,
                shadowX,
                h * 0.42,
                32,
                90,
                Color(148, 168, 184, Math.round(32 * footFade)),
                Color(90, 110, 130, 0),
                12,
            );
        }

        // 入柜前 0.28s 红晕迅速收尽；0.28s 后 vignetteAlpha === 0 不再绘制任何红晕
        if (this.vignetteAlpha > 0.005) {
            const a = Math.round(140 * this.vignetteAlpha);
            const edge = w * 0.08;
            fillHGradRect(uiDraw, 0, 0, edge, h, Color(124, 38, 42, a), Color(124, 38, 42, 0));
            fillHGradRect(uiDraw, w - edge, 0, edge, h, Color(124, 38, 42, 0), Color(124, 38, 42, a));
        }
    }

    // ==================== P04：井庭墙根枪火挡光 + 磨亮窗板下沿与石槽磨痕 ====================

    private drawP04WorldAction(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): void {
        const p = ctx.p;
        const cam = ctx.cam;
        const flash = this.p04FlashIntensity;
        const hintAlpha = this.p04PostHintAlpha;

        const zhou = p.childMode ? p.partner : p.player;
        const xiao = p.childMode ? p.player : p.partner;
        const zX = cam.sx(zhou.x);
        const zY = cam.sy(zhou.y, zhou.depth);
        const zH = cam.len(zhou.h);
        const xX = cam.sx(xiao.x);
        const xY = cam.sy(xiao.y, xiao.depth);
        const xH = cam.len(xiao.h);

        // 1. 远街鸟铳枪火将两人影子斜照上砖墙 + 周戍侧肩挡光
        if (flash > 0.01) {
            // 远街右侧方向斜射而来的克制明代枪火闪光
            fillGradQuad(
                fgGlow,
                cam.viewW, cam.groundScreenY + cam.len(18), Color(238, 178, 108, Math.round(96 * flash)),
                cam.viewW, cam.groundScreenY + cam.len(195), Color(224, 148, 82, Math.round(72 * flash)),
                zX - cam.len(140), cam.groundScreenY + cam.len(140), Color(200, 120, 62, 0),
                zX - cam.len(140), cam.groundScreenY, Color(200, 120, 62, 0),
            );

            // 砖墙上的双人拉长剪影（向枪火反方向斜投）
            const wallBaseY = cam.groundScreenY + cam.len(14);
            const shAlpha = Math.round(148 * flash);
            const shCol = Color(8, 10, 14, shAlpha);
            // 周戍砖墙长影
            fgDraw.drawPolygon([
                Vec2(zX - cam.len(14), wallBaseY),
                Vec2(zX + cam.len(6), wallBaseY),
                Vec2(zX - cam.len(38), wallBaseY + zH * 1.18),
                Vec2(zX - cam.len(64), wallBaseY + zH * 1.12),
            ], shCol);
            // 小满砖墙长影（紧靠周戍身侧微缩）
            fgDraw.drawPolygon([
                Vec2(xX - cam.len(10), wallBaseY),
                Vec2(xX + cam.len(6), wallBaseY),
                Vec2(xX - cam.len(26), wallBaseY + xH * 1.12),
                Vec2(xX - cam.len(44), wallBaseY + xH * 1.06),
            ], shCol);

            // 周戍侧肩抬臂挡光动作（采用与 fe-01 同源的青布补线袖口配色）
            const shieldK = smoothstep(0.10, 0.24, this.p04Elapsed) * (1 - smoothstep(0.50, 0.78, this.p04Elapsed));
            if (shieldK > 0.02) {
                const armX = zX + cam.len(10);
                const armY = zY + zH * 0.66;
                const cuffW = cam.len(13);
                const cuffH = cam.len(7);
                const sa = Math.round(235 * shieldK);
                fgDraw.drawPolygon([
                    Vec2(zX + cam.len(2), armY - cuffH * 0.4),
                    Vec2(armX + cuffW, armY + cuffH * 0.9),
                    Vec2(armX + cuffW * 0.72, armY + cuffH * 1.75),
                    Vec2(zX - cam.len(2), armY + cuffH * 0.5),
                ], toColor(CUFF_SHARED_SPEC.indigoCloth, sa));
                // 袖口浅麻补线微光（提示周戍同一件旧号衣）
                fgDraw.drawSegment(
                    Vec2(armX + cuffW * 0.45, armY + cuffH * 0.75),
                    Vec2(armX + cuffW * 0.82, armY + cuffH * 1.25),
                    1.3,
                    toColor(CUFF_SHARED_SPEC.mendStitch, Math.round(210 * shieldK)),
                );
                // 挡在周戍与小满之间的暗护影带
                fillGradQuad(
                    fgDraw,
                    zX + cam.len(4), zY + zH * 0.85, Color(10, 12, 18, Math.round(92 * shieldK)),
                    zX + cam.len(4), zY, Color(10, 12, 18, Math.round(62 * shieldK)),
                    xX - cam.len(18), xY, Color(10, 12, 18, 0),
                    xX - cam.len(18), xY + xH, Color(10, 12, 18, 0),
                );
            }
        }

        // 2. 小满沿脚边看见的「磨亮的布行窗板下沿」与「青石槽磨痕」（光灭后仍可辨认）
        if (hintAlpha > 0.02) {
            const baseWx = this.p04AnchorWorldX > 0 ? this.p04AnchorWorldX : zhou.x;
            const hintBaseX = cam.sx(baseWx + 74);
            const groundY = cam.sy(0, 0);
            const boardY = groundY + cam.len(34);
            const boardW = cam.len(62);
            const sheenBoost = flash * 0.55;
            const aNorm = clamp01(hintAlpha + sheenBoost);

            // 布行窗板木体轮廓 + 被反复摸亮的浅木下沿
            fgDraw.drawRect(
                Rect(hintBaseX, boardY, boardW, cam.len(12)),
                Color(54, 42, 32, Math.round(165 * aNorm)),
                1.0,
                Color(126, 102, 76, Math.round(150 * aNorm)),
            );
            fgDraw.drawSegment(
                Vec2(hintBaseX + 2, boardY + 1),
                Vec2(hintBaseX + boardW - 2, boardY + 1),
                2.0,
                Color(214, 198, 168, Math.round(215 * aNorm)),
            );

            // 地面青石轨槽与磨亮槽沿（预告后续布行窗板与粮棚石槽线索，无箭标无文字）
            const grooveX0 = hintBaseX - cam.len(18);
            const grooveX1 = hintBaseX + boardW + cam.len(26);
            fgDraw.drawRect(
                Rect(grooveX0, groundY + 1, grooveX1 - grooveX0, cam.len(4)),
                Color(22, 26, 32, Math.round(170 * aNorm)),
            );
            fgDraw.drawSegment(
                Vec2(grooveX0 + 4, groundY + cam.len(5)),
                Vec2(grooveX1 - 4, groundY + cam.len(5)),
                1.6,
                Color(196, 204, 210, Math.round(195 * aNorm)),
            );
        }
    }
}
