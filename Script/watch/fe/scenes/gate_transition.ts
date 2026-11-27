/**
 * 《向西守望》城门风台 24 秒转景与双出口舞台插件（Wave 1 · feature/fe-01-gate-cuff-lowpoly）。
 *
 * 严格对表《游戏分镜稿》G01–G05、《动画插入与演出规划》与《第一波施工书》fe-01：
 * 1. 双对齐点锁死：
 *    - 在 plugin.update() 中（先于 CameraDirector.update）调用 cam.setAnchorLock，
 *      固定小满脚底 (footWorldX, 0) 与城门门槛 (thresholdWorldX, 0) 的屏幕像素坐标，
 *      全程 0 / 6 / 12 / 18 / 24 秒（0 / 360 / 720 / 1080 / 1440 拍）零跳动。
 *    - G01 呼吸微动仅施加于低模灭点偏移，保证 wz = 0 对齐点 0.00 px 漂移。
 * 2. 24 秒（1440 拍 @ 60Hz）连续渐变：
 *    - 0–479 拍（0–8s，数 1–10 稍快）：0s 与平面像素城门无缝重合；6s（360 拍）光擦门框侧面显出第一道立体面；
 *    - 480–1079 拍（8–18s，数 11–17）：12s（720 拍）近处木板伸出挡住后排石阶一角；
 *    - 1080 拍（18s，数十八）：远墙与海滨山体在多层体积雾中分离，小满贴耳上门板；
 *    - 1260 拍（21s，数十九）：压低风噪、放轻十九、留呼吸停顿；
 *    - 1440 拍（24s，数二十）：低模风台投影完整，小满脚底接触影稳贴走面，人物始终二维。
 * 3. 单次触发与暂停冻结：
 *    - 声音（voice/wind/water/sfx 分轨）、轻量水墨数字与手势按 countNumber 变化各触发一次；
 *    - 暂停时冻结拍数、字幕、手势与音频位置，恢复续播不重播。
 * 4. 双出口：
 *    - G04（女主线 child / 未锁存默认）：门边空寂，抚平针套，远处红布轻动，默认零按键浮签，静待松键后新按方向迈步；
 *    - G05（男主线 soldier）：风台安静安全，两下轻叩后待长按牵手；牵手完成随抬镜平滑将 morph 1 → 0 切回序章像素风。
 */

import { Color, DrawNode, Rect, TextAlign, Vec2 } from "Dora";
import { GATE_COUNT_END, Play } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { DualRouteSnapshot } from "Script/watch/fe/contract";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import { adaptHintSentence } from "Script/watch/fe/ui/control_prompts";
import {
    GATE_NIGHTMARE_LIGHT,
    LP_BUCKET,
    LowpolyProjection,
    LowpolyScene,
    MING_MATERIALS,
    clamp01,
    smoothstep,
    vec3,
} from "Script/watch/fe/renderer/lowpoly";
import {
    PALETTE,
    fillRadialGlow,
    fillVGradRect,
    lerpRGBA,
    rgba,
    toColor,
} from "Script/watch/fe/theme";

const COUNT_ZH: string[] = [
    "", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十",
    "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
];

const GATE_AUDIO_ROOT = "assets/audio/gate/";
const GATE_ART = "assets/art/gate/";
const MOAT_MATTE = GATE_ART + "moat-night.png";
const MOAT_FLAT = GATE_ART + "moat-flat.png";
const GATE_FACADE = GATE_ART + "brick-gate.png";
const GATE_FLAT = GATE_ART + "brick-flat.png";
const STONE_APRON = GATE_ART + "stone-apron.png";
const BOARD_EDGE = GATE_ART + "board-edge.png";
const GATE_ANCHOR_FOOT_FRAC_X = 0.36;
const GATE_ANCHOR_FOOT_FRAC_Y = 0.27;
const GATE_ANCHOR_ZOOM = 1.15;
const GATE_FOCAL = 410;
const GATE_VP_FRAC_X = 0.56;
const GATE_VP_FRAC_Y = 0.54;

/** 与 cuff_shots.ts G05 抬镜回切像素风同步的时序常数（秒） */
export const G05_PIXEL_RETURN_START = 0.25;
export const G05_PIXEL_RETURN_END = 1.15;

export interface GateTransitionDebugState {
    active: boolean;
    morph: number;
    effectiveMorph: number;
    countTick: number;
    countNumber: number;
    lastTriggeredCount: number;
    earToDoor: boolean;
    breathPause: boolean;
    g04Idle: boolean;
    g05Waiting: boolean;
    reunionTimer: number;
    reunionPixelReturn: number;
    thresholdWorldX: number;
    footWorldX: number;
    rehearsalKnockStage: number;
    subtitleCountShown: number;
    gestureChangeCount: number;
}

function pad2(n: number): string {
    const v = Math.max(0, Math.floor(n));
    return v < 10 ? ("0" + v) : ("" + v);
}

function countVoicePath(n: number): string {
    return GATE_AUDIO_ROOT + "count_" + pad2(n) + ".wav";
}

function countVoiceVolume(n: number): number {
    if (n === 19) {
        return 0.68;
    }
    if (n === 18) {
        return 0.80;
    }
    if (n === 20) {
        return 0.96;
    }
    return 0.84;
}

export class GateTransitionPlugin implements FeRenderPlugin {
    readonly id = "fe-01-gate-transition";

    private animTime = 0;
    private active = false;
    private wasActive = false;
    private rawMorph = 0;
    private effectiveMorph = 0;
    private lastCountTick = -1;
    private lastTriggeredCount = 0;
    private countCueAge = 99;
    private pendingBreath19 = false;
    private activeCountZh = "";
    private g04LineTriggered = false;
    private reunionTimer = 0;
    private reunionPixelReturn = 0;
    private rehearsalKnockTimer = -1;
    private rehearsalKnockStage = 0;
    private lockFootX = 890;
    private lockThresholdX = 848;
    private subtitleCountShown = 0;
    private gestureChangeCount = 0;
    private lastGestureStage = 0;
    private activeProjection: LowpolyProjection = {
        morph: 0,
        focal: GATE_FOCAL,
        vpFracX: GATE_VP_FRAC_X,
        vpFracY: GATE_VP_FRAC_Y,
        vpOffsetX: 0,
        vpOffsetY: 0,
        baseDepth: 0,
    };

    onBindPlay(_p: Play, _view: DualRouteSnapshot): void {
        this.resetState();
    }

    private resetState(): void {
        this.animTime = 0;
        this.active = false;
        this.wasActive = false;
        this.rawMorph = 0;
        this.effectiveMorph = 0;
        this.lastCountTick = -1;
        this.lastTriggeredCount = 0;
        this.countCueAge = 99;
        this.pendingBreath19 = false;
        this.activeCountZh = "";
        this.g04LineTriggered = false;
        this.reunionTimer = 0;
        this.reunionPixelReturn = 0;
        this.rehearsalKnockTimer = -1;
        this.rehearsalKnockStage = 0;
        this.subtitleCountShown = 0;
        this.gestureChangeCount = 0;
        this.lastGestureStage = 0;
    }

    getProjection(): LowpolyProjection {
        return this.activeProjection;
    }

    getDebugState(): GateTransitionDebugState {
        const earToDoor = this.active && this.lastCountTick >= 1080 && this.lastCountTick < GATE_COUNT_END;
        const breathPause = this.active && this.lastCountTick >= 1260 && this.lastCountTick < GATE_COUNT_END;
        return {
            active: this.active,
            morph: this.rawMorph,
            effectiveMorph: this.effectiveMorph,
            countTick: Math.max(0, this.lastCountTick),
            countNumber: this.lastTriggeredCount,
            lastTriggeredCount: this.lastTriggeredCount,
            earToDoor,
            breathPause,
            g04Idle: this.g04LineTriggered,
            g05Waiting: this.rehearsalKnockStage > 0 && this.reunionTimer <= 0,
            reunionTimer: this.reunionTimer,
            reunionPixelReturn: this.reunionPixelReturn,
            thresholdWorldX: this.lockThresholdX,
            footWorldX: this.lockFootX,
            rehearsalKnockStage: this.rehearsalKnockStage,
            subtitleCountShown: this.subtitleCountShown,
            gestureChangeCount: this.gestureChangeCount,
        };
    }

    private shouldActivate(p: Play, view: DualRouteSnapshot): boolean {
        if (p.room.key !== "gate") {
            return false;
        }
        if (p.phase === "gate-count" || p.phase === "gate-wait" || p.phase === "gate-hand") {
            return true;
        }
        if (p.phase === "gate-walk" && view.storyRoute !== "soldier") {
            return true;
        }
        return false;
    }

    private gestureStageForTick(tick: number, view: DualRouteSnapshot): number {
        if (view.storyRoute === "soldier" && (view.gateReunion.completed || view.gateReunion.active)) {
            return 5;
        }
        if (tick >= view.countDurationTicks) {
            return 4;
        }
        if (tick >= 1260) {
            return 3;
        }
        if (tick >= 1080) {
            return 2;
        }
        if (tick >= 480) {
            return 1;
        }
        return 0;
    }

    update(ctx: FePluginContext): void {
        const p = ctx.p;
        const view = ctx.view;
        const want = this.shouldActivate(p, view);

        if (!want) {
            if (this.wasActive) {
                ctx.cam.setAnchorLock(undefined);
                ctx.audio.stopLoop("gate_wind", 0.25);
                ctx.audio.stopLoop("gate_water", 0.25);
                ctx.audio.stopLoop("gate_breath", 0.2);
                this.wasActive = false;
            }
            this.active = false;
            return;
        }

        this.active = true;
        const justEntered = !this.wasActive;
        this.wasActive = true;

        const g = p.room.story?.gate;
        const doorX = g !== undefined ? g.doorX : (p.ox + 860);
        // 门槛严格位于门内周戍 (doorX=860) 与门外小满 (doorX+30=890) 之间
        this.lockThresholdX = doorX + 14;
        this.lockFootX = p.player.x;

        if (!ctx.paused) {
            this.animTime += ctx.worldDt;
            if (this.countCueAge < 20) {
                this.countCueAge += ctx.worldDt;
            }
        }

        // 计算基础转景形变因子 morph ∈ [0, 1]
        if (p.phase === "gate-wait" || p.phase === "gate-hand" || p.phase === "gate-walk") {
            this.rawMorph = 1;
        } else {
            this.rawMorph = clamp01(view.countElapsedTicks / Math.max(1, view.countDurationTicks));
        }

        // 男主线牵手完成：随抬镜平滑从低模切回序章像素风（0.25s..1.15s）
        const reunionDone = p.phase === "gate-hand" || (view.storyRoute === "soldier" && view.gateReunion.completed);
        if (reunionDone) {
            if (!ctx.paused) {
                this.reunionTimer += ctx.worldDt;
            }
            this.reunionPixelReturn = smoothstep(G05_PIXEL_RETURN_START, G05_PIXEL_RETURN_END, this.reunionTimer);
            this.effectiveMorph = clamp01(1 - this.reunionPixelReturn);
        } else {
            this.reunionTimer = 0;
            this.reunionPixelReturn = 0;
            this.effectiveMorph = this.rawMorph;
        }

        // 数数与等待锁定双锚点，握稳后随抬镜移动，步行或切房时归还跟随镜头
        if (p.phase === "gate-count" || p.phase === "gate-wait" || p.phase === "gate-hand") {
            // 男主线抬镜阶段缓慢抬高脚底屏幕基线，形成顺手臂抬镜的观感；转景阶段保持 0.00 px 严格锁死
            const tiltLift = this.reunionPixelReturn * 0.055;
            ctx.cam.setAnchorLock({
                footWorldX: this.lockFootX,
                footWorldY: p.player.y,
                footDepth: p.player.depth,
                thresholdWorldX: this.lockThresholdX,
                screenFootFracX: GATE_ANCHOR_FOOT_FRAC_X,
                screenFootFracY: GATE_ANCHOR_FOOT_FRAC_Y - tiltLift,
                zoomOverride: GATE_ANCHOR_ZOOM + this.reunionPixelReturn * 0.07,
            });
        } else {
            ctx.cam.setAnchorLock(undefined);
        }

        // 构造当帧低模投影参数（G01 呼吸仅微移灭点，绝不触碰 wz = 0 双对齐点）
        const breathPhase = this.animTime * 1.35;
        const breatheAmp = this.effectiveMorph > 0.01 && p.phase === "gate-count" ? (1 - this.reunionPixelReturn) : 0;
        this.activeProjection = {
            morph: this.effectiveMorph,
            focal: GATE_FOCAL,
            vpFracX: GATE_VP_FRAC_X,
            vpFracY: GATE_VP_FRAC_Y,
            vpOffsetX: Math.sin(breathPhase * 0.7) * 3.5 * breatheAmp,
            vpOffsetY: Math.cos(breathPhase) * 2.5 * breatheAmp,
            baseDepth: p.player.depth,
        };

        // 探测是否发生排演跳拍 / 倒退（例如 setMockCountTick 直接定格截帧）
        const tick = view.countElapsedTicks;
        const countNum = Math.max(1, Math.min(20, view.countNumber));
        const jumped = this.lastCountTick >= 0 && (tick < this.lastCountTick || (tick - this.lastCountTick) > 36);
        const stage = this.gestureStageForTick(tick, view);

        if (justEntered && tick > 12) {
            // 读档或直接定格到中段拍：同步当前数与姿态，不补播先前数字
            this.lastTriggeredCount = countNum;
            this.activeCountZh = COUNT_ZH[countNum] ?? "";
            this.countCueAge = 0.6;
            this.lastGestureStage = stage;
            if (tick >= view.countDurationTicks && view.storyRoute !== "soldier") {
                this.g04LineTriggered = true;
            }
        } else if (jumped) {
            this.pendingBreath19 = false;
            this.lastTriggeredCount = countNum;
            this.activeCountZh = COUNT_ZH[countNum] ?? "";
            this.countCueAge = 0.35;
            this.lastGestureStage = stage;
            if (tick < view.countDurationTicks) {
                this.g04LineTriggered = false;
                this.rehearsalKnockTimer = -1;
                this.rehearsalKnockStage = 0;
            }
        } else if (!ctx.paused && (p.phase === "gate-count" || p.phase === "gate-wait")) {
            if (countNum > this.lastTriggeredCount) {
                this.lastTriggeredCount = countNum;
                this.activeCountZh = COUNT_ZH[countNum] ?? "";
                this.countCueAge = 0;
                this.pendingBreath19 = countNum === 19;
                this.subtitleCountShown += 1;
                const dedupeKey = "gate:count:" + ctx.events.roomSessionId + ":" + countNum;
                ctx.audio.playOnce(
                    dedupeKey,
                    "voice",
                    countVoicePath(countNum),
                    countVoiceVolume(countNum),
                    "gate:count:" + countNum,
                    tick,
                );
            }
            if (stage !== this.lastGestureStage) {
                this.lastGestureStage = stage;
                this.gestureChangeCount += 1;
            }
        }

        if (this.pendingBreath19 && this.countCueAge >= 0.78 && !ctx.paused && p.phase === "gate-count") {
            this.pendingBreath19 = false;
            ctx.audio.playOnce(
                "gate:breath19:" + ctx.events.roomSessionId,
                "voice",
                GATE_AUDIO_ROOT + "breath_soft.wav",
                0.48,
                "gate:breath_19",
                tick,
            );
        }

        // G04 女主线数满二十后的风、水和呼吸循环
        const isChildWait = p.phase === "gate-count"
            && tick >= view.countDurationTicks
            && view.storyRoute !== "soldier";
        if (isChildWait && !this.g04LineTriggered && !ctx.paused) {
            this.g04LineTriggered = true;
        }

        // G05 男主线排演态补发两下轻叩（正式模式由 audio.ingestEvents 消费后端 knock 事件，绝不重复）
        const isSoldierWait = view.storyRoute === "soldier"
            && (p.phase === "gate-wait" || (p.phase === "gate-count" && view.gateReunion.active && !view.gateReunion.completed));
        if (isSoldierWait && view.isRehearsal && !ctx.paused) {
            if (this.rehearsalKnockTimer < 0) {
                this.rehearsalKnockTimer = 0;
                this.rehearsalKnockStage = 1;
                ctx.audio.playOnce(
                    "gate:rehearsal:knock:1:" + ctx.events.roomSessionId,
                    "sfx",
                    GATE_AUDIO_ROOT + "knock_wall.wav",
                    0.88,
                    "knock:gate:1",
                    tick,
                );
            } else {
                this.rehearsalKnockTimer += ctx.worldDt;
                if (this.rehearsalKnockStage < 2 && this.rehearsalKnockTimer >= 12 / 60) {
                    this.rehearsalKnockStage = 2;
                    ctx.audio.playOnce(
                        "gate:rehearsal:knock:2:" + ctx.events.roomSessionId,
                        "sfx",
                        GATE_AUDIO_ROOT + "knock_wall.wav",
                        0.92,
                        "knock:gate:2",
                        tick,
                    );
                }
            }
        }

        // 最后三声和轻呼吸进入时让出声音空间，句间让风水自然回来。
        if (!ctx.paused) {
            const voiceDuck = p.phase === "gate-count" && countNum >= 18
                ? 0.32 + 0.68 * smoothstep(0.95, 1.55, this.countCueAge) : 1.0;
            const reunionCalm = reunionDone ? (1 - this.reunionPixelReturn * 0.55) : 1.0;
            const windVol = (0.18 + 0.46 * this.effectiveMorph) * voiceDuck * reunionCalm;
            const waterVol = (0.28 + 0.24 * this.effectiveMorph) * voiceDuck;
            ctx.audio.playLoop("gate_wind", "wind", GATE_AUDIO_ROOT + "wind_loop.wav", windVol, tick);
            ctx.audio.playLoop("gate_water", "water", GATE_AUDIO_ROOT + "water_moat_loop.wav", waterVol, tick);
            if (isChildWait) {
                ctx.audio.playLoop("gate_breath", "ambience", GATE_AUDIO_ROOT + "breath_soft.wav", 0.24, tick);
            } else {
                ctx.audio.stopLoop("gate_breath", 0.2);
            }
        }

        this.lastCountTick = tick;
    }

    drawBackdrop(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        backdropArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        if (!this.active) {
            return false;
        }
        const cam = ctx.cam;
        const w = cam.viewW;
        const h = cam.viewH;
        const m = this.effectiveMorph;

        const skyLow = lerpRGBA(rgba(30, 22, 29, 255), rgba(29, 43, 59, 255), m);
        fillVGradRect(bgDraw, 0, 0, w, h, toColor(skyLow), Color(12, 18, 31, 255));

        const width = Math.max(w, h * 16 / 9) * 1.11;
        const height = width * 9 / 16;
        const span = Math.max(1, ctx.p.room.maxX - ctx.p.room.minX);
        const progress = (cam.x - ctx.p.room.minX) / span - 0.5;
        const matteAlpha = smoothstep(0.14, 0.88, m);
        const drift = Math.sin(this.animTime * 0.34) * h * 0.003;
        const mattePlaced = matteAlpha > 0.01 && backdropArt.tryPlacePath(
            MOAT_MATTE, "gate_moat_matte",
            w * (0.5 - progress * 0.046 + (1 - m) * 0.013) + drift,
            h * 0.5, width, height, { opacity: matteAlpha, layer: 1, smooth: true },
        );
        if (!mattePlaced || matteAlpha < 0.999) {
            const flatX = w * (0.5 - progress * 0.046 + (1 - m) * 0.013);
            const outside = this.reunionPixelReturn <= 0.025;
            const flatPlaced = outside && backdropArt.tryPlacePath(
                MOAT_FLAT, "gate_moat_flat", flatX, h * 0.5, width, height, { layer: 0 },
            );
            if (!flatPlaced) {
                backdropArt.tryPlace(
                    "bgFar_gate", "gate_pixel_bg", flatX, (h - height) * 0.5, width, height, { layer: 0 },
                );
            }
        }

        // 月与水面由引擎实时绘制，远景明灯来自原画。
        const moonReveal = smoothstep(0.18, 0.58, m);
        if (moonReveal > 0.01) {
            const moonX = w * 0.745;
            const moonY = h * 0.827;
            const radius = h * 0.019;
            fillRadialGlow(
                bgGlow, moonX, moonY, radius * 5.2, radius * 4.4,
                Color(121, 164, 214, Math.round(50 * moonReveal)),
                Color(82, 123, 171, 0), 20,
            );
            fillRadialGlow(
                bgGlow, moonX, moonY, radius * 1.11, radius * 1.11,
                Color(232, 239, 243, Math.round(203 * moonReveal)),
                Color(194, 213, 232, 0), 24,
            );
            bgGlow.drawDot(Vec2(moonX, moonY), radius * 0.68, Color(187, 202, 218, Math.round(132 * moonReveal)));
        }

        const waterReveal = smoothstep(0.30, 0.86, m);
        for (let i = 0; i < 24; i++) {
            if (waterReveal <= 0.01) {
                break;
            }
            const depth = (i % 8) / 7;
            const flow = this.animTime * (0.62 + 0.32 * depth) + i * 1.91;
            const phase = Math.sin(flow);
            const rippleX = w * (0.43 + ((i * 7) % 29) / 52) + h * 0.016 * phase;
            const rippleY = h * (0.292 - depth * 0.216) + Math.cos(flow * 0.7) * h * 0.003;
            const radius = h * (0.015 + 0.028 * depth) * (0.83 + 0.17 * phase);
            const alpha = Math.round(waterReveal * (8 + 17 * (0.5 + 0.5 * phase)) * (1 - 0.52 * depth));
            bgGlow.drawSegment(
                Vec2(rippleX - radius, rippleY), Vec2(rippleX + radius, rippleY),
                h * (0.00042 + 0.00035 * depth), Color(143, 182, 222, alpha),
            );
        }
        return true;
    }

    drawWorld(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        if (!this.active) {
            return false;
        }
        const p = ctx.p;
        const cam = ctx.cam;
        const m = this.effectiveMorph;
        const thX = this.lockThresholdX; // 门槛 X (848)
        const doorLeft = thX - 108;

        const scene = new LowpolyScene(cam, this.activeProjection, GATE_NIGHTMARE_LIGHT);

        const doorOpen = 1 - smoothstep(0, 360, ctx.view.countElapsedTicks);
        const facadeOpacity = 1 - smoothstep(0.40, 0.92, this.reunionPixelReturn);

        // 2. 后排石阶（位于 z = +24..+102，通往城外下层护城河栈道；12s 时会被前景木板挡住一角！）
        const stepReveal = smoothstep(0.18, 0.58, m);
        if (stepReveal > 0.01) {
            const stairSpec = {
                x0: thX + 108,
                x1: thX + 292,
                y0: -56,
                y1: 2,
                steps: 5,
                label: "外壕石阶",
            };
            // 下行石阶：左高右低，逐级沉入护城河雾中
            let k = 0;
            const n = stairSpec.steps + 1;
            const stepW = (stairSpec.x1 - stairSpec.x0) / n;
            for (k = 0; k < n; k++) {
                const wy = stairSpec.y1 - (stairSpec.y1 - stairSpec.y0) * (k / Math.max(1, n - 1));
                const sx0 = stairSpec.x0 + k * stepW;
                const sx1 = sx0 + stepW + 1;
                scene.addBox({
                    x0: sx0,
                    x1: sx1,
                    y0: -78,
                    y1: wy,
                    z0: 26,
                    z1: 106,
                    material: MING_MATERIALS.mingStoneStep,
                    bucket: LP_BUCKET.MIDGROUND,
                    opacity: stepReveal,
                    sortBias: k * 0.02,
                    highlightTopEdge: true,
                    edgeWidth: 0.4,
                });
            }
        }

        // 立体门框从画面锚点向墙后展开，砖缝与侧光使用同一投影。
        const wallReveal = smoothstep(0.025, 0.28, m) * facadeOpacity;
        const frameLightStrength = smoothstep(0.065, 0.33, m) * (1 - 0.30 * smoothstep(0.53, 1, m));
        const jambX = thX - 5;
        const jambDepth = 66;
        const wallHeight = 256;
        if (wallReveal > 0.01) {
            scene.addBox({
                x0: doorLeft - 140, x1: jambX, y0: -8, y1: wallHeight,
                z0: 0, z1: jambDepth, material: MING_MATERIALS.mingBrickDark,
                bucket: LP_BUCKET.MIDGROUND, opacity: wallReveal,
            });

            for (let row = 0; row < 16; row++) {
                const y = row * 16;
                const courseOffset = row % 2 === 0 ? 0 : 11;
                for (let brick = 0; brick < 4; brick++) {
                    const z0 = Math.max(0, brick * 22 - courseOffset) + 0.45;
                    const z1 = Math.min(jambDepth, (brick + 1) * 22 - courseOffset) - 0.45;
                    if (z1 <= z0) {
                        continue;
                    }
                    const light = frameLightStrength * (1 - (z0 + z1) / (2 * jambDepth));
                    const shade = 36 + ((row * 5 + brick * 7) % 13) + 29 * light;
                    scene.addQuad3D(
                        vec3(jambX, y + 0.5, z1), vec3(jambX, y + 0.5, z0),
                        vec3(jambX, y + 15.1, z0), vec3(jambX, y + 15.1, z1),
                        { base: rgba(shade * 0.87, shade * 1.04, shade * 1.20, 255) },
                        { bucket: LP_BUCKET.MIDGROUND, opacity: wallReveal, unlit: true, bottomAo: 0.28, sortZOverride: jambDepth / 2, sortBias: 0.15 },
                    );
                }
            }
        }

        if (frameLightStrength > 0.02) {
            scene.addLightShaft(
                thX + 1, thX + 17, 184, thX - 8, thX + 23, 0, 12,
                rgba(162, 187, 218, 255), 0.095 * frameLightStrength, 0.016 * frameLightStrength,
            );
        }

        // 4. 门槛青石条（严格位于 wz = 0，x = thX-10..thX+12，与小满脚底构成双对齐基准）
        scene.addBox({
            x0: thX - 10,
            x1: thX + 12,
            y0: -12,
            y1: 2,
            z0: -14,
            z1: 28,
            material: MING_MATERIALS.mingStoneStep,
            bucket: LP_BUCKET.WALK_DECK,
            sortBias: 0.02,
            highlightTopEdge: true,
            edgeWidth: 1.1,
        });

        // 5. 风台主走面（wz = 0 严丝合缝，0s 时与原石板地面齐平，随 morph 展开厚重明代青石+木栈台）
        scene.addBox({
            x0: doorLeft - 140,
            x1: thX + 132,
            y0: -68,
            y1: 0,
            z0: -20,
            z1: 42,
            material: MING_MATERIALS.mingBrickDark,
            bucket: LP_BUCKET.WALK_DECK,
            sortBias: 0,
            highlightTopEdge: true,
            edgeWidth: 0.85,
        });

        // 6. 近处木栈台铺板（z = -56..-4，12s / morph = 0.50 起明显探向前景并挡住后排石阶一角！）
        const plankReveal = smoothstep(0.14, 0.52, m);
        const overhangZ0 = -10 - 48 * plankReveal;
        if (plankReveal > 0.01) {
            scene.addPlankDeck(
                thX + 58,
                thX + 340,
                0,
                overhangZ0,
                22,
                5,
                11,
                MING_MATERIALS.mingTimber,
                {
                    bucket: LP_BUCKET.WALK_DECK,
                    opacity: plankReveal,
                    sortBias: 0.25,
                    withPosts: true,
                    postBottomY: -78,
                },
            );
            this.drawDeckGrain(scene, thX + 58, thX + 340, overhangZ0, 22, plankReveal);
            // 栈台低矮石栏桩与远端系着旧红布的检修木桩/车柄剪影（G04 视觉牵引点）
            scene.addBox({
                x0: thX + 244,
                x1: thX + 260,
                y0: 0,
                y1: 38,
                z0: -12,
                z1: 6,
                material: MING_MATERIALS.mingTimberDark,
                bucket: LP_BUCKET.PROP,
                opacity: plankReveal,
                highlightTopEdge: true,
            });
            // 旧红布在木桩上的系点固定，越靠近破边越容易被风掀起。
            const clothX = thX + 245;
            const clothY = 34;
            const wave = this.animTime * 3.5;
            for (let fold = 0; fold < 5; fold++) {
                const a = fold / 5;
                const b = (fold + 1) / 5;
                const xA = clothX + a * (-13 + 12 * Math.sin(wave - a * 3.2));
                const xB = clothX + b * (-13 + 12 * Math.sin(wave - b * 3.2));
                const yA = clothY - a * 24;
                const yB = clothY - b * 24;
                const clothLight = 0.88 + 0.16 * Math.cos(wave - a * 3.2);
                scene.addQuad3D(
                    vec3(xA, yA, -13), vec3(xA + 8 - 3 * a, yA - a, -13),
                    vec3(xB + 8 - 3 * b, yB - 2 * b, -14), vec3(xB, yB, -14),
                    { base: rgba(133 * clothLight, 48 * clothLight, 46 * clothLight, 255) },
                    { bucket: LP_BUCKET.PROP, opacity: plankReveal, unlit: true, bottomAo: 0.10, sortBias: 0.35 },
                );
            }
        }

        // 7. 角色脚底接触影（严格贴合 wz = 0，24s 时清晰落在立体风台上）
        scene.addContactShadow(p.player.x, p.player.y, 16, 12, 0.62 + 0.28 * m, {
            bucket: LP_BUCKET.PROP,
            sortBias: 0.45,
        });

        // 8. 刷出全部 3D 低模几何
        scene.flush(fgDraw, fgGlow);

        // 门的正面钉在世界 z=0；不同清晰度的同一幅画共用边界。
        const wallLeft = cam.sx(doorLeft - 140);
        const wallRight = cam.sx(jambX);
        const wallY = cam.sy(0, p.player.depth);
        const wallW = wallRight - wallLeft;
        const wallH = cam.len(wallHeight);
        const wallX = (wallLeft + wallRight) * 0.5;
        const detail = smoothstep(0.09, 0.49, m);
        if (facadeOpacity > 0.01) {
            if (detail < 0.999 || facadeOpacity < 0.999) {
                const flatPlaced = worldArt.tryPlacePath(
                    GATE_FLAT, "gate_facade_flat", wallX, wallY, wallW, wallH,
                    { layer: 4101, opacity: facadeOpacity, anchorY: 0 },
                );
                if (!flatPlaced) {
                    worldArt.tryPlace("wall", "gate_closed_wall", wallX, wallY, wallW, wallH,
                        { layer: 4101, color: Color(52, 56, 66, 255), opacity: facadeOpacity });
                    worldArt.tryPlace("prop_tower_door", "gate_closed_door",
                        cam.sx(thX - 56), wallY, cam.len(111), cam.len(164),
                        { layer: 4102, opacity: facadeOpacity });
                }
            }
            if (detail > 0.01) {
                worldArt.tryPlacePath(
                    GATE_FACADE, "gate_facade_detail", wallX, wallY, wallW, wallH,
                    { layer: 4103, opacity: facadeOpacity * detail, anchorY: 0, smooth: true },
                );
            }
        }

        if (doorOpen > 0.02 && facadeOpacity > 0.01) {
            const seamX = wallLeft + wallW * 0.654;
            const alpha = doorOpen * facadeOpacity;
            fillRadialGlow(
                fgGlow, seamX, wallY + cam.len(2), cam.len(53), cam.len(7 + 9 * alpha),
                Color(161, 102, 51, Math.round(100 * alpha)), Color(107, 62, 28, 0), 18,
            );
            fgGlow.drawSegment(Vec2(seamX, wallY + cam.len(4)), Vec2(seamX, wallY + wallH * 0.64),
                cam.len(0.34 + 0.47 * alpha), Color(198, 145, 82, Math.round(62 * alpha)));
        }

        const apronFront = scene.project(thX + 132, 0, -20);
        const apronLeft = scene.project(doorLeft - 140, 0, -20);
        const apronBase = scene.project(doorLeft - 140, -68, -20);
        const plankLeft = scene.project(thX + 58, 0, overhangZ0);
        const apronRight = apronFront.x + (Math.min(apronFront.x, plankLeft.x + 2) - apronFront.x) * plankReveal;
        worldArt.tryPlacePath(
            STONE_APRON, "gate_stone_apron", (apronLeft.x + apronRight) * 0.5, apronBase.y,
            apronRight - apronLeft.x, apronLeft.y - apronBase.y,
            { layer: -2, anchorY: 0, opacity: 0.93, smooth: true },
        );

        if (plankReveal > 0.01) {
            const edgeRight = scene.project(thX + 340, 0, overhangZ0);
            const edgeBottom = scene.project(thX + 58, -11, overhangZ0);
            worldArt.tryPlacePath(
                BOARD_EDGE, "gate_deck_wet_edge", (plankLeft.x + edgeRight.x) * 0.5, edgeBottom.y + 1,
                edgeRight.x - plankLeft.x, Math.max(1, plankLeft.y - edgeBottom.y - 1),
                { layer: -1, anchorY: 0, opacity: plankReveal, smooth: true },
            );
        }

        return true;
    }

    private drawDeckGrain(
        scene: LowpolyScene, x0: number, x1: number, z0: number, z1: number, opacity: number,
    ): void {
        // 木纹和水光沿每一块栈板铺开，板缝留空，近板随投影压住远处石阶。
        const gap = Math.min(2.6, (z1 - z0) / 30);
        const boardDepth = (z1 - z0 - gap * 4) / 5;
        for (let board = 0; board < 5; board++) {
            const edge = z0 + (boardDepth + gap) * board;
            for (let streak = 0; streak < 13; streak++) {
                const seed = board * 17 + streak;
                const start = x0 + 4 + ((seed * 73) % 237);
                const end = Math.min(x1 - 2, start + 19 + (seed * 19) % 58);
                const z = edge + boardDepth * (0.13 + 0.135 * (streak % 6));
                const dark = streak % 3 === 0;
                const glint = Math.round(37 + 19 * Math.sin(this.animTime * 0.87 + seed * 0.4));
                const grain = dark ? rgba(20, 15, 17, 116) : rgba(135 + glint, 142 + glint, 151 + glint, glint);
                scene.addQuad3D(
                    vec3(start, 0.18, z), vec3(end, 0.18, z + 0.28),
                    vec3(end - 2, 0.18, z + 0.66), vec3(start + 3, 0.18, z + 0.73),
                    { base: grain },
                    { bucket: LP_BUCKET.WALK_DECK, opacity, unlit: true, sortZOverride: z0 - 0.8, sortBias: 0.4 },
                );
            }
        }
    }

    drawPropsOverlay(
        _fgDraw: DrawNode.Type,
        _fgGlow: DrawNode.Type,
        _worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        // 风台 24s 转景与重逢演出期间抑制常规区域发光带/菱形标记，保持纯净明代风台画面；迈步进 gate-walk 后恢复
        return this.active && ctx.p.phase !== "gate-walk";
    }

    drawActorsOverlay(
        _fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        _worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        if (!this.active) {
            return;
        }
        const { p, cam, view } = ctx;
        const tick = view.countElapsedTicks;

        // 第十九声之后只有一次呼气，雾从贴门的脸侧散开。
        const breathAge = this.countCueAge - 0.78;
        if (p.phase === "gate-count" && tick >= 1260 && tick < view.countDurationTicks
            && breathAge >= 0 && breathAge < 1.20) {
            const drift = breathAge / 1.20;
            const unit = cam.len(1);
            const x = cam.sx(p.player.x - 15) - unit * 7 * drift;
            const y = cam.sy(p.player.y, p.player.depth) + cam.len(p.player.h * 0.75 + 4 * drift);
            const alpha = smoothstep(0, 0.22, drift) * (1 - smoothstep(0.40, 1, drift));
            fillRadialGlow(
                fgGlow, x, y, unit * (2 + 6 * drift), unit * (1.0 + 2.5 * drift),
                Color(200, 222, 244, Math.round(71 * alpha)), Color(158, 184, 213, 0), 16,
            );
        }

        // 两声轻叩带出砖缝里几粒落尘，随后小满保持抬手的姿势等待。
        if (p.phase === "gate-wait") {
            const age = (p.phaseTick < 12 ? p.phaseTick : p.phaseTick - 12) / 60;
            const opacity = 1 - smoothstep(0.06, 0.42, age);
            if (opacity > 0.01) {
                const unit = cam.len(1);
                const x = cam.sx(this.lockThresholdX);
                const y = cam.sy(p.player.y, p.player.depth) + cam.len(p.player.h * 0.77);
                for (let i = 0; i < 7; i++) {
                    const px = x + unit * (i * 0.6 + (2 + i) * age);
                    const py = y - unit * (i * 1.4 + (2 + i) * 6 * age * age);
                    fgGlow.drawDot(Vec2(px, py), unit * (0.17 + (i % 3) * 0.10), Color(181, 202, 220, Math.round(opacity * (90 - i * 7))));
                }
            }
        }
    }

    drawCutsceneOverlay(
        uiDraw: DrawNode.Type,
        _uiInkDraw: DrawNode.Type,
        _uiArt: AssetSlotHost,
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        if (!this.active || ctx.p.phase === "gate-walk") {
            return false;
        }
        const { p, view } = ctx;
        const w = ctx.uiW;
        const h = ctx.uiH;
        const barH = Math.round(36 * (1 - this.reunionPixelReturn * 0.45));
        uiDraw.drawRect(Rect(0, h - barH, w, barH), Color(6, 9, 15, 255));
        uiDraw.drawRect(Rect(0, 0, w, barH), Color(6, 9, 15, 255));

        const isCounting = p.phase === "gate-count" && view.countElapsedTicks < view.countDurationTicks;
        const isTwenty = this.lastTriggeredCount === 20 &&
            this.countCueAge < 1.25 && (p.phase === "gate-count" || p.phase === "gate-wait");
        if ((isCounting || isTwenty) && this.activeCountZh !== "") {
            const relaxed = this.lastTriggeredCount === 19;
            const tail = relaxed ? 2.35 : 0.92;
            const opacity = smoothstep(0, 0.12, this.countCueAge) *
                (1 - smoothstep(tail, tail + 0.3, this.countCueAge));
            const text = isTwenty ? "二十。" : (relaxed ? "……十九……" : this.activeCountZh + "……");
            ctx.texts.put("sm", text, w * 0.5, barH * 0.51, toColor(PALETTE.textBright),
                0.5, 0.5, TextAlign.Center, 0, opacity, 0.04);
        }

        if (p.phase === "gate-count" && view.countElapsedTicks >= view.countDurationTicks
            && view.storyRoute !== "soldier" && view.assistHintsEnabled) {
            ctx.texts.put(
                "xs", adaptHintSentence("松开后重新按方向键迈步", ctx.input.inputMode, ctx.input.gamepadLayout),
                w * 0.5, h - barH * 0.5, toColor(PALETTE.textDim),
                0.5, 0.5, TextAlign.Center, 1.2, 0.78, 0.08,
            );
        }

        return true;
    }
}

export function createGateTransitionPlugin(): GateTransitionPlugin {
    return new GateTransitionPlugin();
}
