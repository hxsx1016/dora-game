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
import { Play, PROLOGUE_CABINET_X, PROLOGUE_HIDE_TICKS, PROLOGUE_SHADOW_TICKS } from "Script/watch/play";
import { AudioDirector } from "Script/watch/fe/audio";
import { DualRouteContract, DualRouteSnapshot } from "Script/watch/fe/contract";
import { CUFF_PALETTE } from "Script/watch/fe/cutscenes/cuff_shots";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import { ComicKeyframe, drawComicSequence } from "Script/watch/fe/renderer/slideshow";
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
    p02ShadowDuration: PROLOGUE_SHADOW_TICKS / 60,
    p02EscapeDuration: 7.5,
    p02HiddenFadeOut: 0.28,
    p02HiddenLinger: PROLOGUE_HIDE_TICKS / 60,
    p04FlashDuration: 1.0,
    heartbeatMinHz: 1.15,
    heartbeatMaxHz: 2.75,
};

/**
 * P01 父亲叫醒小满硬核明代木刻暗黑漫画逐帧拍表（总长 4.00s，与 D30/D31 及 bed_creak 1.78s 精确咬合）：
 * 黑场透光 → 掀帐见火 → 父亲粗手压褥撑床沿 → 坐起望见火光门缝无缝衔接 P02。
 */
const P01_WAKE_COMIC_SEQ: readonly ComicKeyframe[] = [
    {
        slot: "comic_p01_01_curtain_dark",
        start: 0.00,
        end: 0.92,
        zoomFrom: 1.00,
        zoomTo: 1.014,
        transition: "cut",
    },
    {
        slot: "comic_p01_02_curtain_glow",
        start: 0.92,
        end: 1.78,
        zoomFrom: 1.005,
        zoomTo: 1.018,
        transition: "cut",
    },
    {
        slot: "comic_p01_03_hand_bedrail",
        start: 1.78,
        end: 2.90,
        zoomFrom: 1.012,
        zoomTo: 1.024,
        transition: "cut",
        shakeAmp: 3.2,
        shakeFreq: 52,
    },
    {
        slot: "comic_p01_04_look_door",
        start: 2.90,
        end: 4.00,
        zoomFrom: 1.008,
        zoomTo: 1.02,
        transition: "cut",
    },
];

/**
 * P02 硬核明代木刻暗黑漫画逐帧拍表（总长 4.50s，等步幅跨度 + 零重影硬切 + 1.55s 单帧冲击 + 3.88s 撞槛定格）：
 * 全部时间点与 stepP02Shadow 音效触发毫秒级咬合。
 */
const P02_SHADOW_COMIC_SEQ: readonly ComicKeyframe[] = [
    {
        slot: "comic_p02_01_shadows",
        start: 0.00,
        end: 0.85,
        zoomFrom: 1.00,
        zoomTo: 1.012,
        transition: "cut",
    },
    {
        slot: "comic_p02_02a_door_intrude",
        start: 0.85,
        end: 1.55,
        zoomFrom: 1.01,
        zoomTo: 1.022,
        transition: "cut",
    },
    {
        slot: "comic_p02_03_impact_cut",
        start: 1.55,
        end: 1.74,
        zoomFrom: 1.035,
        zoomTo: 1.035,
        transition: "cut",
        impactFlash: true,
        impactDur: 0.19,
        shakeAmp: 11,
        shakeFreq: 72,
    },
    {
        slot: "comic_p02_04_shadows_fall",
        start: 1.74,
        end: 2.70,
        zoomFrom: 1.015,
        zoomTo: 1.00,
        transition: "cut",
        shakeAmp: 3.5,
        shakeFreq: 48,
    },
    {
        slot: "comic_p02_05_bowl_roll1",
        start: 2.70,
        end: 3.32,
        zoomFrom: 1.00,
        zoomTo: 1.014,
        transition: "slash_cut",
        transitionDur: 0.10,
    },
    {
        slot: "comic_p02_06_bowl_roll2",
        start: 3.32,
        end: 3.88,
        zoomFrom: 1.008,
        zoomTo: 1.02,
        transition: "cut",
        shakeAmp: 2.5,
    },
    {
        slot: "comic_p02_07_bowl_smash",
        start: 3.88,
        end: 4.50,
        zoomFrom: 1.028,
        zoomTo: 1.00,
        transition: "cut",
        impactFlash: true,
        impactDur: 0.18,
        shakeAmp: 9.5,
        shakeFreq: 66,
    },
];

/** P02 入柜收声三阶合缝拍表（总长 1.80s：贼足掠过 → 门缝半合 → 合缝一线冷月死寂） */
const P02_HIDDEN_COMIC_SEQ: readonly ComicKeyframe[] = [
    {
        slot: "comic_p02_08a_cabinet_slit",
        start: 0.00,
        end: 0.65,
        zoomFrom: 1.00,
        zoomTo: 1.008,
        transition: "cut",
    },
    {
        slot: "comic_p02_08m_cabinet_narrowing",
        start: 0.65,
        end: 1.12,
        zoomFrom: 1.00,
        zoomTo: 1.005,
        transition: "cut",
    },
    {
        slot: "comic_p02_08b_cabinet_shut",
        start: 1.12,
        end: 1.80,
        zoomFrom: 1.00,
        zoomTo: 1.00,
        transition: "cut",
    },
];

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

        if (this.stageElapsed >= 0.10) {
            ctx.audio.playOnce(
                this.cueKey("p02_door_commotion"),
                "ambience",
                PROLOGUE_AUDIO.doorCommotion,
                0.62,
                "prologue:p02_commotion",
                tick,
            );
        }
        if (this.stageElapsed >= 1.55) {
            ctx.audio.playOnce(
                this.cueKey("p02_shadow_strike"),
                "sfx",
                PROLOGUE_AUDIO.shadowStrike,
                0.88,
                "prologue:p02_shadow_cut",
                tick,
            );
        }
        if (this.stageElapsed >= 2.78) {
            ctx.audio.playOnce(
                this.cueKey("p02_bowl_roll"),
                "sfx",
                PROLOGUE_AUDIO.bowlRoll,
                0.78,
                "prologue:p02_bowl_roll",
                tick,
            );
        }
        if (this.stageElapsed >= 3.88) {
            ctx.audio.playOnce(
                this.cueKey("p02_bowl_hit"),
                "sfx",
                PROLOGUE_AUDIO.bowlHit,
                0.92,
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
        worldArt: FePluginContext["worldArt"],
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
        this.drawP04WorldAction(fgDraw, fgGlow, worldArt, ctx);
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
            this.drawP02ShadowAndBowl(uiDraw, uiInkDraw, uiArt, uiGlow, ctx);
            return true;
        }
        if (this.stage === "p02_escape") {
            this.drawP02EscapeVignette(uiDraw, uiInkDraw, uiGlow, ctx);
            // P02 限时逃柜期间压隐战斗 HUD 与底部教学长条，保持纯屏边红晕 + 心跳的窒息紧张感
            return true;
        }
        if (this.stage === "p02_hidden") {
            this.drawP02HiddenCabinet(uiDraw, uiInkDraw, uiArt, uiGlow, ctx);
            return true;
        }
        return false;
    }

    // ==================== P01：父亲叫醒小满（4 秒） ====================

    private drawP01Wake(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: FePluginContext["uiArt"],
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): void {
        const w = ctx.uiW;
        const h = ctx.uiH;
        const t = this.stageElapsed;

        // 全屏深墨底，彻底隔绝底层场景
        uiDraw.drawRect(Rect(0, 0, w, h), Color(6, 7, 11, 255));

        // 睁眼开合节奏（黑场先闻唤声 → 眼睑缓慢张开 → 末段轻收衔接 P02）
        const wakeOpen = smoothstep(0.28, 1.45, t);
        const blinkDip = t >= 0.96 && t <= 1.28 ? Math.sin(((t - 0.96) / 0.32) * Math.PI) * 0.22 : 0;
        const eyeOpen = clamp01(wakeOpen - blinkDip);
        const fadeOut = 1 - smoothstep(3.76, 4.0, t);
        const barH = Math.round(h * 0.068);

        if (eyeOpen > 0.01) {
            drawComicSequence(
                uiDraw,
                uiInkDraw,
                uiArt,
                P01_WAKE_COMIC_SEQ,
                t,
                w,
                h,
                {
                    letterboxH: barH,
                    opacity: clamp01(smoothstep(0.18, 0.58, t)) * fadeOut,
                    layer: 2,
                    instancePrefix: "p01_comic",
                    accentBorder: true,
                },
            );
        }

        // 上下眼睑柔边开合遮幅（保留第一人称睁眼核心体感）
        const lidH = h * 0.52 * (1 - eyeOpen);
        if (lidH > 1) {
            ctx.uiMask.drawRect(Rect(0, h - lidH, w, lidH), Color(5, 6, 9, 255));
            ctx.uiMask.drawRect(Rect(0, 0, w, lidH), Color(5, 6, 9, 255));
            const feather = Math.min(46, h * 0.08);
            fillVGradRect(ctx.uiMask, 0, h - lidH - feather, w, feather, Color(5, 6, 9, 0), Color(5, 6, 9, 235));
            fillVGradRect(ctx.uiMask, 0, lidH, w, feather, Color(5, 6, 9, 235), Color(5, 6, 9, 0));
        }

        // 排演态黑场父亲唤「小满。」极简素幕字幕（正式模式交由 NarrativeRenderer.drawCutsceneDialogue 呈现 D30/D31）
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

    // ==================== P02 前段：门槛墙影截断与滚碗撞槛（硬核木刻漫画逐帧演出，4.5 秒） ====================

    private drawP02ShadowAndBowl(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: FePluginContext["uiArt"],
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): void {
        const w = ctx.uiW;
        const h = ctx.uiH;
        const t = this.stageElapsed;
        const barH = Math.round(h * 0.068);
        drawComicSequence(
            uiDraw,
            uiInkDraw,
            uiArt,
            P02_SHADOW_COMIC_SEQ,
            t,
            w,
            h,
            {
                letterboxH: barH,
                opacity: 1,
                layer: 2,
                instancePrefix: "fe03_p02_shadow",
                accentBorder: true,
            },
        );
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
            if (!ctx.uiArt.tryPlaceRun("child", "p02_escape_child", childX, groundY, 46, 74, this.stageElapsed * 1.8, {
                facing: 1,
                layer: 3,
            })) {
                uiDraw.drawRect(Rect(childX - 12, groundY, 24, 54), Color(168, 72, 54, 235));
            }
        }
    }

    // ==================== P02 入柜收声：三阶漫画门缝合拢 + 红晕收尽 ====================

    private drawP02HiddenCabinet(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: FePluginContext["uiArt"],
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): void {
        const w = ctx.uiW;
        const h = ctx.uiH;
        const t = this.stageElapsed;

        drawComicSequence(
            uiDraw,
            uiInkDraw,
            uiArt,
            P02_HIDDEN_COMIC_SEQ,
            t,
            w,
            h,
            {
                letterboxH: Math.round(h * 0.055),
                opacity: 1,
                layer: 3,
                instancePrefix: "fe03_p02_hidden",
                accentBorder: false,
            },
        );

        // 入柜前 0.28s 红晕迅速收尽；0.28s 后 vignetteAlpha === 0 不再绘制任何红晕
        if (this.vignetteAlpha > 0.005) {
            const a = Math.round(140 * this.vignetteAlpha);
            const edge = w * 0.08;
            fillHGradRect(uiInkDraw, 0, 0, edge, h, Color(124, 38, 42, a), Color(124, 38, 42, 0));
            fillHGradRect(uiInkDraw, w - edge, 0, edge, h, Color(124, 38, 42, 0), Color(124, 38, 42, a));
        }
    }

    // ==================== P04：井庭墙根枪火挡光 + 磨亮窗板下沿与石槽磨痕 ====================

    private drawP04WorldAction(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: FePluginContext["worldArt"],
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

        // 2. 小满沿脚边看见的「磨亮的布行窗板下沿」与「青石槽磨痕」（手绘 p04_window_board，光灭后仍可辨认）
        if (hintAlpha > 0.02) {
            const baseWx = this.p04AnchorWorldX > 0 ? this.p04AnchorWorldX : zhou.x;
            const hintBaseX = cam.sx(baseWx + 74);
            const groundY = cam.sy(0, 0);
            const boardW = cam.len(62);
            const sheenBoost = flash * 0.55;
            const aNorm = clamp01(hintAlpha + sheenBoost);

            const placedBoard = worldArt.tryPlacePath(
                "assets/art/cutscene_well_museum.clip|p04_window_board",
                "p04_polished_window_board",
                hintBaseX + boardW * 0.5,
                groundY - 2,
                boardW * 1.15,
                cam.len(68),
                {
                    anchorX: 0.5,
                    anchorY: 0,
                    color: Color(
                        Math.round(188 + 64 * flash),
                        Math.round(184 + 54 * flash),
                        Math.round(176 + 34 * flash),
                        255,
                    ),
                    opacity: 0.88 * aNorm,
                    smooth: true,
                    layer: 4200,
                },
            );
            if (!placedBoard) {
                const boardY = groundY + cam.len(34);
                fgDraw.drawRect(
                    Rect(hintBaseX, boardY, boardW, cam.len(12)),
                    Color(54, 42, 32, Math.round(165 * aNorm)),
                    1.0,
                    Color(126, 102, 76, Math.round(150 * aNorm)),
                );
            }
            // 沿磨亮窗板下沿的克制微反光（预告后续线索，无箭标无文字）
            fillRadialGlow(
                fgGlow,
                hintBaseX + boardW * 0.52,
                groundY + cam.len(8),
                boardW * 0.55,
                cam.len(12),
                Color(232, 214, 178, Math.round((46 + 84 * flash) * aNorm)),
                Color(214, 186, 142, 0),
                12,
            );
        }
    }
}
