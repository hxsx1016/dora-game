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
import {
    GATE_NIGHTMARE_LIGHT,
    LP_BUCKET,
    LowpolyProjection,
    LowpolyScene,
    MING_MATERIALS,
    clamp01,
    projectWorld3D,
    smoothstep,
    vec3,
} from "Script/watch/fe/renderer/lowpoly";
import {
    PALETTE,
    drawHairline,
    drawMistCurve,
    drawSilkVeil,
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
    private g04LineAge = -1;
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
        this.g04LineAge = -1;
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
            if (this.g04LineAge >= 0 && this.g04LineAge < 20) {
                this.g04LineAge += ctx.worldDt;
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

        // 双对齐点锚定：gate-count / gate-wait 严格锁死小满脚底与门槛；gate-walk 与切回像素完成后交还跟随镜头
        const lockCamera = (p.phase === "gate-count" || p.phase === "gate-wait") && this.reunionPixelReturn < 0.98;
        if (lockCamera) {
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
                this.g04LineAge = 0.5;
            }
        } else if (jumped) {
            this.pendingBreath19 = false;
            this.lastTriggeredCount = countNum;
            this.activeCountZh = COUNT_ZH[countNum] ?? "";
            this.countCueAge = 0.35;
            this.lastGestureStage = stage;
            if (tick < view.countDurationTicks) {
                this.g04LineTriggered = false;
                this.g04LineAge = -1;
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

        // G04 女主线数满二十后的留白台词与风/水/呼吸循环
        const isChildWait = p.phase === "gate-count"
            && tick >= view.countDurationTicks
            && view.storyRoute !== "soldier";
        if (isChildWait && !this.g04LineTriggered && !ctx.paused) {
            this.g04LineTriggered = true;
            this.g04LineAge = 0;
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

        // 1. 远景冷夜天穹（从城门余烬暗红缓慢退为宁村所海防寒夜青灰）
        const skyTop = lerpRGBA(rgba(14, 10, 14, 255), rgba(8, 13, 22, 255), m);
        const skyMid = lerpRGBA(rgba(28, 17, 22, 255), rgba(16, 25, 38, 255), m);
        const skyHor = lerpRGBA(rgba(54, 28, 30, 255), rgba(30, 44, 62, 255), m);
        const splitY = h * 0.48;
        fillVGradRect(bgDraw, 0, splitY, w, h - splitY, toColor(skyMid), toColor(skyTop));
        fillVGradRect(bgDraw, 0, 0, w, splitY, toColor(skyHor), toColor(skyMid));

        // 2. 0s 时与原有像素城门 bgFar_gate 100% 衔接，随 morph 拉大平滑淡出（男主线回切像素风时自然复现）
        const pixelBgAlpha = 1 - smoothstep(0.08, 0.72, m);
        if (pixelBgAlpha > 0.01) {
            const span = Math.max(1, ctx.p.room.maxX - ctx.p.room.minX);
            const progress = (cam.x - ctx.p.room.minX) / span - 0.5;
            const artW = Math.max(w, h * 16 / 9) + w * 0.12;
            const artH = artW * 9 / 16;
            backdropArt.tryPlace("bgFar_gate", "gate_pixel_bg", w * (0.5 - progress * 0.09), (h - artH) * 0.5, artW, artH, {
                opacity: pixelBgAlpha,
                layer: 0,
            });
        }

        // 3. 低模远景：海滨山脊 + 分层海雾 + 宁村所远城墙垛口 + 远方北塔孤灯（18s 时远墙与山体在雾中清晰分离）
        const farReveal = smoothstep(0.22, 0.85, m);
        if (farReveal > 0.01) {
            const scene = new LowpolyScene(cam, this.activeProjection, GATE_NIGHTMARE_LIGHT);
            const xMin = this.lockThresholdX - 320;
            const xMax = this.lockThresholdX + 680;

            // 远方山体（z = 520，18s 以后与远墙拉开清晰层次）
            const hillSep = smoothstep(0.45, 0.88, m);
            scene.addDistantRidge(
                [
                    { x: xMin, y: 112 },
                    { x: this.lockThresholdX - 60, y: 176 },
                    { x: this.lockThresholdX + 120, y: 146 },
                    { x: this.lockThresholdX + 280, y: 204 },
                    { x: this.lockThresholdX + 460, y: 164 },
                    { x: xMax, y: 132 },
                ],
                -40,
                520,
                MING_MATERIALS.distantHill,
                { bucket: LP_BUCKET.BACKDROP, opacity: farReveal * (0.55 + 0.45 * hillSep) },
            );

            // 远山与远墙之间的深海雾帘（z = 360，显式把山体与远墙在雾中切开）
            scene.addFogBand(xMin, xMax, -30, 190, 360, rgba(38, 54, 74, 255), 0.72 * hillSep, 0.06 * hillSep, {
                bucket: LP_BUCKET.BACKDROP,
            });

            // 宁村所外城远墙与垛口（z = 225，无杂乱描边，纯雾中明代城垣低模剪影）
            const wallMat = MING_MATERIALS.distantWall;
            scene.addBox({
                x0: this.lockThresholdX + 40,
                x1: xMax,
                y0: -48,
                y1: 96,
                z0: 215,
                z1: 260,
                material: wallMat,
                bucket: LP_BUCKET.BACKDROP,
                opacity: farReveal,
                highlightTopEdge: true,
                edgeWidth: 0,
            });
            // 明代城墙女墙垛口
            let merlonX = this.lockThresholdX + 64;
            let mi = 0;
            for (mi = 0; mi < 10; mi++) {
                scene.addBox({
                    x0: merlonX,
                    x1: merlonX + 28,
                    y0: 96,
                    y1: 112,
                    z0: 215,
                    z1: 242,
                    material: wallMat,
                    bucket: LP_BUCKET.BACKDROP,
                    opacity: farReveal,
                    sortBias: 0.05,
                    edgeWidth: 0,
                });
                merlonX += 56;
            }

            // 远墙前的护城河低雾带（z = 148）
            scene.addFogBand(xMin, xMax, -44, 108, 148, rgba(32, 46, 66, 255), 0.64 * farReveal, 0.04, {
                bucket: LP_BUCKET.BACKDROP,
            });

            // 远方北塔一豆极克制的暖灯（方向引导，居中偏右与水墨数字清晰错开，不做夸张光柱）
            const beaconP = projectWorld3D(this.lockThresholdX + 210, 146, 490, cam, this.activeProjection);
            const pulse = 0.82 + 0.18 * Math.sin(this.animTime * 2.1);
            fillRadialGlow(
                bgGlow,
                beaconP.x,
                beaconP.y,
                34 * farReveal * pulse,
                34 * farReveal * pulse,
                Color(246, 212, 148, Math.round(92 * farReveal * pulse)),
                Color(232, 180, 96, 0),
                16,
            );
            bgGlow.drawDot(Vec2(beaconP.x, beaconP.y), 2.6 * farReveal, Color(255, 244, 212, Math.round(235 * farReveal)));

            // 护城河水面冷月细波（z = 120）
            const moatY = -36;
            const waterA = 0.42 * farReveal;
            let ri = 0;
            for (ri = 0; ri < 6; ri++) {
                const rx = this.lockThresholdX + 110 + ri * 68 + Math.sin(this.animTime * 1.1 + ri * 1.7) * 8;
                const pL = projectWorld3D(rx - 18, moatY - (ri % 2) * 6, 128 + ri * 12, cam, this.activeProjection);
                const pR = projectWorld3D(rx + 18, moatY - (ri % 2) * 6, 128 + ri * 12, cam, this.activeProjection);
                bgGlow.drawSegment(Vec2(pL.x, pL.y), Vec2(pR.x, pR.y), 1.1, Color(168, 198, 224, Math.round(90 * waterA)));
            }

            scene.flush(bgDraw, bgGlow);
        }

        // 冷月微晕（居高开阔夜空，左避门楣、右避水墨报数字，不裁切不拥挤）
        const mx = w * 0.66;
        const my = h * 0.82;
        const mr = Math.max(15, h * 0.032);
        fillRadialGlow(bgGlow, mx, my, mr * 4.8, mr * 4.8, Color(164, 202, 232, Math.round(18 + 20 * m)), Color(24, 42, 68, 0), 18);
        bgDraw.drawCircle(Vec2(mx, my), mr, Color(218, 232, 246, Math.round(115 + 85 * m)));

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

        // 1. 城门关闭进程（与 stage.ts 对齐：0..360 拍闸门合拢，360 拍后完全落稳）
        const closeFrac = p.phase === "gate-count"
            ? (0.44 + 0.56 * clamp01(ctx.view.countElapsedTicks / 360))
            : 1.0;

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
                    edgeWidth: 0.9,
                });
            }
        }

        // 3. 外城门砖石城墙与立体门框（0s 时与像素 bgFar_gate 无缝衔接，随 morph 0.02..0.22 显露厚实低模墙体；
        //    6s / morph = 0.25 时门框内壁侧面完全成形并承接第一道侧光！）
        const wallReveal = smoothstep(0.02, 0.22, m);
        const frameLightStrength = smoothstep(0.10, 0.34, m) * (1 - 0.35 * smoothstep(0.85, 1.0, m));
        if (wallReveal > 0.01) {
            scene.addBox({
                x0: doorLeft - 140,
                x1: thX - 18,
                y0: -60,
                y1: 230,
                z0: -12,
                z1: 88,
                material: MING_MATERIALS.mingBrick,
                bucket: LP_BUCKET.MIDGROUND,
                opacity: wallReveal,
                highlightTopEdge: true,
                edgeWidth: 0.75,
            });
            // 门框立体内壁（x = thX-18..thX，z = -6..+72；随 morph 展开露出厚实石框侧面）
            scene.addBox({
                x0: thX - 18,
                x1: thX,
                y0: 0,
                y1: 162,
                z0: -6,
                z1: 72,
                material: MING_MATERIALS.mingStoneStep,
                bucket: LP_BUCKET.MIDGROUND,
                opacity: wallReveal,
                sortBias: 0.08,
                highlightTopEdge: true,
                edgeWidth: 0.9,
            });
            // 门楣厚石过梁（克制外挑宽度，保留右侧开阔寒夜海空）
            scene.addBox({
                x0: doorLeft - 40,
                x1: thX + 76,
                y0: 160,
                y1: 214,
                z0: -14,
                z1: 82,
                material: MING_MATERIALS.mingBrickDark,
                bucket: LP_BUCKET.MIDGROUND,
                opacity: wallReveal,
                sortBias: 0.12,
                highlightTopEdge: true,
                edgeWidth: 0.8,
            });
        }

        // 6 秒第一道擦过门框侧面的冷月侧光与光柱
        if (frameLightStrength > 0.02) {
            scene.addLightShaft(
                thX + 16, thX + 34, 160,
                thX - 4, thX + 24, 0,
                16,
                rgba(220, 234, 248, 255),
                0.24 * frameLightStrength,
                0.04 * frameLightStrength,
            );
            // 门框内壁亮棱线（在静音与灰度下也能一眼读出立体门框第一道侧面）
            const pBotNear = scene.project(thX, 0, -6);
            const pBotFar = scene.project(thX, 0, 72);
            const pTopFar = scene.project(thX, 160, 72);
            const pTopNear = scene.project(thX, 160, -6);
            const glowA = Math.round(140 * frameLightStrength);
            fgGlow.drawVertices([
                [Vec2(pBotNear.x, pBotNear.y), Color(224, 236, 248, glowA)],
                [Vec2(pBotFar.x, pBotFar.y), Color(168, 196, 224, Math.round(glowA * 0.25))],
                [Vec2(pTopFar.x, pTopFar.y), Color(168, 196, 224, Math.round(glowA * 0.25))],
                [Vec2(pBotNear.x, pBotNear.y), Color(224, 236, 248, glowA)],
                [Vec2(pTopFar.x, pTopFar.y), Color(168, 196, 224, Math.round(glowA * 0.25))],
                [Vec2(pTopNear.x, pTopNear.y), Color(224, 236, 248, glowA)],
            ]);
        }

        // 厚重明代木铁城门板（在门洞左侧闭合，含横向暗铁门箍提升质感；男主线 G05 回切像素风时淡出敞开门廊）
        const doorAlpha = 1 - this.reunionPixelReturn;
        const doorBotY = 160 * (1 - closeFrac);
        if (160 - doorBotY > 2 && doorAlpha > 0.02) {
            scene.addBox({
                x0: thX - 122,
                x1: thX - 2,
                y0: doorBotY,
                y1: 160,
                z0: 4,
                z1: 22,
                material: MING_MATERIALS.mingTimberDark,
                bucket: LP_BUCKET.MIDGROUND,
                opacity: doorAlpha,
                sortBias: 0.04,
                edgeWidth: 0.9,
            });
            // 明代重门铁箍横梁
            const bandYs = [doorBotY + 12, doorBotY + 42, doorBotY + 72];
            let bi = 0;
            for (bi = 0; bi < bandYs.length; bi++) {
                const byBand = bandYs[bi];
                if (byBand + 6 < 158) {
                    scene.addBox({
                        x0: thX - 120,
                        x1: thX - 4,
                        y0: byBand,
                        y1: byBand + 6,
                        z0: 2,
                        z1: 10,
                        material: MING_MATERIALS.mingIron,
                        bucket: LP_BUCKET.MIDGROUND,
                        opacity: doorAlpha,
                        sortBias: 0.06,
                        edgeWidth: 0.5,
                    });
                }
            }
            // 门底缝透出的城内微弱暖光（0..6s 渐灭，象征门内光声断绝）
            if (closeFrac < 0.98) {
                const gapAlpha = (1 - closeFrac) * 0.65 * doorAlpha;
                scene.addLightShaft(
                    thX - 96, thX - 2, Math.max(4, doorBotY),
                    thX - 86, thX + 26, 0,
                    2,
                    rgba(232, 188, 128, 255),
                    gapAlpha * 0.42,
                    gapAlpha * 0.14,
                );
            }
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
        if (plankReveal > 0.01) {
            const overhangZ0 = -10 - 48 * plankReveal;
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
            // 远处系在左端的旧红布（随风摆动，不翻面）
            const clothBaseX = thX + 244;
            const clothTopY = 34;
            const windFreq = 2.8 + m * 1.4;
            const wave1 = Math.sin(this.animTime * windFreq) * (4 + 6 * m);
            const wave2 = Math.cos(this.animTime * windFreq * 0.85) * (3 + 4 * m);
            scene.addTri3D(
                vec3(clothBaseX, clothTopY, -12),
                vec3(clothBaseX + 7, clothTopY - 2, -12),
                vec3(clothBaseX - 8 + wave1, clothTopY - 24 + wave2 * 0.3, -15),
                MING_MATERIALS.mingRedCloth,
                { bucket: LP_BUCKET.PROP, opacity: plankReveal, sortBias: 0.35, edgeWidth: 0.9 },
            );
            scene.addTri3D(
                vec3(clothBaseX + 7, clothTopY - 2, -12),
                vec3(clothBaseX - 8 + wave1, clothTopY - 24 + wave2 * 0.3, -15),
                vec3(clothBaseX + 2 + wave2, clothTopY - 20, -13),
                MING_MATERIALS.mingRedCloth,
                { bucket: LP_BUCKET.PROP, opacity: plankReveal * 0.9, sortBias: 0.36 },
            );
        }

        // 7. 角色脚底接触影（严格贴合 wz = 0，24s 时清晰落在立体风台上）
        scene.addContactShadow(p.player.x, p.player.y, 16, 12, 0.62 + 0.28 * m, {
            bucket: LP_BUCKET.PROP,
            sortBias: 0.45,
        });

        // 8. 刷出全部 3D 低模几何
        scene.flush(fgDraw, fgGlow);

        // 9. 关门后用实心明代城墙与重门精灵遮蔽留在门内的 p.partner（周戍在 swapToChild 后仍 alive 站在门内 x<=860），
        //    男主线 G05 重逢切回像素风时淡出该遮挡，自然露出周戍身影；门槛位于 874，绝不越过门外小满 x=890！
        const hidePartnerInside = this.reunionPixelReturn < 0.85 && closeFrac > 0.60;
        if (hidePartnerInside) {
            const wallRightX = cam.sx(thX - 1);
            const wallLeftX = cam.sx(doorLeft - 140);
            const wallW = Math.max(2, wallRightX - wallLeftX);
            const wallTopY = cam.sy(164, p.player.depth);
            const wallBotY = cam.sy(0, p.player.depth);
            const wallH = Math.max(2, wallTopY - wallBotY);
            const wallOp = clamp01((closeFrac - 0.60) / 0.28) * (1 - this.reunionPixelReturn);
            worldArt.tryPlace(
                "wall",
                "gate_closed_wall_mask",
                (wallLeftX + wallRightX) * 0.5,
                wallBotY,
                wallW,
                wallH,
                {
                    layer: 4102,
                    color: Color(52, 56, 66, 255),
                    opacity: wallOp,
                },
            );
            const doorPanelL = cam.sx(thX - 112);
            const doorPanelR = cam.sx(thX - 1);
            worldArt.tryPlace(
                "prop_tower_door",
                "gate_closed_door_leaf",
                (doorPanelL + doorPanelR) * 0.5,
                wallBotY,
                Math.max(2, doorPanelR - doorPanelL),
                wallH,
                {
                    layer: 4103,
                    color: Color(86, 74, 62, 255),
                    opacity: wallOp,
                },
            );
        }

        // 10. 《小小梦魇》式前景压边木梁（位于角色前方 worldArt 高 layer，绝不遮挡小满与门槛对齐点）
        const fgBeamAlpha = smoothstep(0.42, 0.95, m) * (1 - this.reunionPixelReturn);
        if (fgBeamAlpha > 0.02) {
            scene.placeForegroundOccluder(
                worldArt,
                "cover_wood",
                "gate_fg_beam_right",
                thX + 266,
                thX + 356,
                -42,
                22,
                -68,
                { color: Color(14, 17, 24, 255), opacity: 0.92 * fgBeamAlpha, layer: 5200 },
            );
        }

        return true;
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
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        _worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        if (!this.active) {
            return;
        }
        const p = ctx.p;
        const view = ctx.view;
        const cam = ctx.cam;
        const tick = view.countElapsedTicks;
        const cx = cam.sx(p.player.x);
        const by = cam.sy(p.player.y, p.player.depth);
        const H = cam.len(p.player.h);

        // 1. G03（18..19 拍，1080..1439 拍）：小满贴耳靠向门板 + 寒夜呼气白雾
        if (p.phase === "gate-count" && tick >= 1080 && tick < view.countDurationTicks) {
            const leanK = smoothstep(1080, 1130, tick);
            const doorSx = cam.sx(this.lockThresholdX);
            const headY = by + H * 0.80;
            // 贴耳听声的微弱门内声静波（极克制的霜白弧线，提示她在侧耳倾听）
            const earPulse = 0.55 + 0.45 * Math.sin(this.animTime * 2.2);
            fgGlow.drawArc(
                Vec2(doorSx + 4, headY),
                12 + (1 - earPulse) * 8,
                -38,
                38,
                1.1,
                Color(214, 224, 236, Math.round(78 * leanK * earPulse)),
            );
            // 19 声呼吸停顿（1260..1439 拍）：一缕冷夜哈气白雾随呼吸轻散
            if (tick >= 1260) {
                const breathCycle = (this.animTime * 0.7) % 1;
                const bAlpha = Math.sin(breathCycle * Math.PI) * 0.48;
                const bx = cx - 10 - breathCycle * 18;
                const bY = headY - 4 + breathCycle * 6;
                fillRadialGlow(
                    fgGlow,
                    bx,
                    bY,
                    12 + breathCycle * 10,
                    7 + breathCycle * 6,
                    Color(220, 232, 244, Math.round(110 * bAlpha)),
                    Color(180, 204, 228, 0),
                    12,
                );
            }
        }

        // 2. G04（女主线数满二十后静候迈步）：收回攥袖手抚平腕上针套的微暖余光（纯环境线索，零浮签）
        const isChildIdle = p.phase === "gate-count"
            && tick >= view.countDurationTicks
            && view.storyRoute !== "soldier";
        if (isChildIdle) {
            const pouchX = cx + cam.len(6);
            const pouchY = by + H * 0.48;
            const pulse = 0.72 + 0.28 * Math.sin(this.animTime * 2.4);
            fillRadialGlow(
                fgGlow,
                pouchX,
                pouchY,
                18 * pulse,
                18 * pulse,
                Color(236, 198, 128, Math.round(64 * pulse)),
                Color(220, 168, 86, 0),
                12,
            );
            fgGlow.drawDot(Vec2(pouchX, pouchY), 2.1, toColor(PALETTE.amberCore, Math.round(190 * pulse)));
        }

        // 3. G05（男主线听见两下轻叩）：侧墙敲击声波涟漪 + 小满抬手待握微光
        const isSoldierWait = view.storyRoute === "soldier"
            && !view.gateReunion.completed
            && (p.phase === "gate-wait" || (p.phase === "gate-count" && view.gateReunion.active));
        if (isSoldierWait) {
            const wallSx = cam.sx(this.lockThresholdX + 2);
            const knockY = by + H * 0.56;
            const ringCycle = (this.animTime * 0.85) % 1;
            const r1 = 8 + ringCycle * 34;
            const a1 = (1 - ringCycle) * 0.72;
            fgGlow.drawRing(Vec2(wallSx, knockY), Math.max(1, r1 - 1.5), r1, Color(0, 0, 0, 0), 1.3, toColor(PALETTE.amber, 210 * a1));
            // 微微抬起的手势轮廓微芒
            const handX = cx - cam.len(10);
            const handY = by + H * 0.62 + Math.sin(this.animTime * 2.6) * 2;
            fgDraw.drawSegment(Vec2(cx - cam.len(3), by + H * 0.56), Vec2(handX, handY), 2.4, Color(230, 206, 182, 220));
            fgGlow.drawDot(Vec2(handX, handY), 2.4, toColor(PALETTE.amberCore, 165));
        }
    }

    drawCutsceneOverlay(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        if (!this.active) {
            return false;
        }
        const p = ctx.p;
        const view = ctx.view;
        const w = ctx.uiW;
        const h = ctx.uiH;

        // gate-walk 期间交还正常画面（不加遮幅）
        if (p.phase === "gate-walk") {
            return false;
        }

        // 1. 克制细电影遮幅（上下 52px，不压黑中央舞台，保障 0/6/12/18/24s 五帧清晰对比）
        const barH = Math.round(52 * (1 - this.reunionPixelReturn * 0.35));
        uiDraw.drawRect(Rect(0, h - barH, w, barH), Color(8, 10, 16, 236));
        uiDraw.drawRect(Rect(0, 0, w, barH), Color(8, 10, 16, 236));
        uiInkDraw.drawSegment(Vec2(0, h - barH), Vec2(w, h - barH), 0.7, toColor(PALETTE.silkDim, 68));
        uiInkDraw.drawSegment(Vec2(0, barH), Vec2(w, barH), 0.7, toColor(PALETTE.silkDim, 68));

        // 2. 数到二十期间（0..1439 拍）：左上/右上留白区极轻水墨数声浮现（绝不挡住中央小满、门槛与木板）
        const inCounting = p.phase === "gate-count" && view.countElapsedTicks < view.countDurationTicks;
        if (inCounting && this.activeCountZh !== "") {
            const isBreathNum = view.countNumber === 19;
            const fadeIn = smoothstep(0, 0.16, this.countCueAge);
            const holdOut = 1 - smoothstep(isBreathNum ? 2.1 : 1.15, isBreathNum ? 2.85 : 1.65, this.countCueAge);
            const numAlpha = clamp01(fadeIn * Math.max(0.28, holdOut)) * (isBreathNum ? 0.68 : 0.90);

            const nx = w * 0.84;
            const ny = h * 0.74;
            drawMistCurve(uiArt, "gate_whisper_mist", nx, ny, 190, 44, PALETTE.jadeMist, 0.18 * numAlpha, 0);
            ctx.texts.put(
                "banner",
                this.activeCountZh,
                nx,
                ny + 6,
                toColor(PALETTE.textBright),
                0.5,
                0.5,
                TextAlign.Center,
                4,
                numAlpha,
                0.10,
            );
            // 底部轻量听觉字幕（18 贴耳、19 放轻留呼吸）
            const whisperText = view.countNumber === 18
                ? "「十八……」"
                : (view.countNumber === 19 ? "「……十九……」" : ("「" + this.activeCountZh + "……」"));
            drawSilkVeil(uiDraw, uiArt, "gate_count_sub_veil", w * 0.5, 26, 320, 36, PALETTE.inkWash, 0.72 * numAlpha, -1);
            ctx.texts.put("sm", whisperText, w * 0.5, 26, toColor(PALETTE.textMid), 0.5, 0.5, TextAlign.Center, 1.4, numAlpha, 0.08);
            return true;
        }

        // 3. G04 女主线数满二十：单次轻台词「……二十了。我往北去了。」（不弹按键提示；仅在开启按键辅助时极淡提示）
        const isChildDone = p.phase === "gate-count"
            && view.countElapsedTicks >= view.countDurationTicks
            && view.storyRoute !== "soldier";
        if (isChildDone) {
            const lineAlpha = this.g04LineAge >= 0
                ? smoothstep(0, 0.25, this.g04LineAge) * (1 - smoothstep(3.8, 5.2, this.g04LineAge))
                : 0.9;
            if (lineAlpha > 0.02) {
                drawSilkVeil(uiDraw, uiArt, "gate_g04_veil", w * 0.5, 26, 460, 38, PALETTE.inkWash, 0.78 * lineAlpha, -1);
                drawHairline(uiInkDraw, uiArt, "gate_g04_line", w * 0.5, 44, 300, PALETTE.silkDim, 0.45 * lineAlpha, true, 2);
                ctx.texts.put(
                    "sm",
                    "「……二十了。我往北去了。」",
                    w * 0.5,
                    26,
                    toColor(PALETTE.textBright),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    1.2,
                    lineAlpha,
                    0.08,
                );
            }
            if (view.assistHintsEnabled) {
                ctx.texts.put(
                    "xs",
                    "松开后重新按方向键迈步",
                    w * 0.5,
                    h - 26,
                    toColor(PALETTE.textDim),
                    0.5,
                    0.5,
                    TextAlign.Center,
                    1.2,
                    0.78,
                    0.08,
                );
            }
            return true;
        }

        // G05 阶段交由 cuff_shots.ts 渲染袖口特写与「我们走吧。」台词，本插件仅保留上方黑边
        return true;
    }
}

export function createGateTransitionPlugin(): GateTransitionPlugin {
    return new GateTransitionPlugin();
}
