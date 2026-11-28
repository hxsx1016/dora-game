/**
 * 《向西守望》冷月火药与水墨韵律特效池：
 * - 冷月火药曳光弹道、枪口暖焰、命中暗朱星芒与碎屑
 * - 掩体格挡石屑飞溅
 * - 枯笔墨韵扩散声波环（安抚敲两下、塔门敲两下、投瓶落砖地）
 * - 各房间专属环境粒子（火星灰烬 / 细雨 / 森林微孢 / 北塔暖灯浮尘）
 * - 纯表现层微顿帧（Hitstop）与暗朱墨烟受击屏边脉冲（不阻塞后端 60Hz 时钟）
 */

import { Color, DrawNode, Vec2 } from "Dora";
import { Play, Trace } from "Script/watch/play";
import { ACTOR_DEPTH_HALF, DEPTH_Y_SCALE, overlapsDepth } from "Script/watch/depth";
import { FrameEvents } from "Script/watch/fe/adapter";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { depthOrder } from "Script/watch/fe/occlusion";
import { FootstepCue } from "Script/watch/fe/renderer/anim_controller";
import {
    AmbientKind,
    PALETTE,
    RGBA,
    fillHGradRect,
    fillRadialGlow,
    fillVGradRect,
    themeOf,
    toColor,
} from "Script/watch/fe/theme";

interface Spark {
    x: number;
    y: number;
    vx: number;
    vy: number;
    life: number;
    maxLife: number;
    size: number;
    color: RGBA;
}

interface SonicRing {
    x: number;
    y: number;
    maxR: number;
    life: number;
    maxLife: number;
    color: RGBA;
}

interface SlashTracer {
    x0: number;
    y0: number;
    x1: number;
    y1: number;
    hit: boolean;
    life: number;
    maxLife: number;
}

interface MuzzlePlume {
    x: number;
    y: number;
    dir: number;
    life: number;
    maxLife: number;
}

interface ImpactBurst {
    x: number;
    y: number;
    hit: boolean;
    life: number;
    maxLife: number;
}

interface StepDustPuff {
    x: number;
    y: number;
    depth: number;
    facing: number;
    life: number;
    maxLife: number;
    scale: number;
    wide: boolean;
}

interface AmbientMote {
    fx: number; // 0..1 屏幕归一化位置
    fy: number;
    vx: number;
    vy: number;
    size: number;
    phase: number;
}

const AMBIENT_COUNT = 34;

const MUZZLE_CLIPS = [
    "assets/art/vfx_ming_fx.clip|muzzle_0",
    "assets/art/vfx_ming_fx.clip|muzzle_1",
    "assets/art/vfx_ming_fx.clip|muzzle_2",
    "assets/art/vfx_ming_fx.clip|muzzle_3",
];
const SMOKE_CLIPS = [
    "assets/art/vfx_ming_fx.clip|smoke_0",
    "assets/art/vfx_ming_fx.clip|smoke_1",
    "assets/art/vfx_ming_fx.clip|smoke_2",
    "assets/art/vfx_ming_fx.clip|smoke_3",
];
const HIT_SPARK_CLIP = "assets/art/vfx_ming_fx.clip|hit_spark_0";
const DEBRIS_CLIP = "assets/art/vfx_ming_fx.clip|debris_0";
const STEP_DUST_CLIPS = [
    "assets/art/vfx_ming_fx.clip|dust_0",
    "assets/art/vfx_ming_fx.clip|dust_1",
];

export class VfxSystem {
    private sparks: Spark[] = [];
    private rings: SonicRing[] = [];
    private tracers: SlashTracer[] = [];
    private plumes: MuzzlePlume[] = [];
    private bursts: ImpactBurst[] = [];
    private stepDusts: StepDustPuff[] = [];
    private motes: AmbientMote[] = [];

    /** 视觉受击红边脉冲（0..1） */
    hitVignette = 0;
    /** 掩体格挡冰青闪光脉冲（0..1） */
    deflectFlash = 0;
    deflectX = 0;
    deflectY = 0;
    /** 纯表现层极短顿帧（秒），仅冻结特效衰减，不影响 Play.update */
    visualHitstop = 0;
    /** 准星后坐力扩散（像素） */
    crosshairKick = 0;
    private rngState = 1337;

    constructor() {
        this.initAmbient();
    }

    private rand(): number {
        this.rngState = (this.rngState * 1664525 + 1013904223) % 4294967296;
        return this.rngState / 4294967296;
    }

    private initAmbient(): void {
        this.motes = [];
        let i = 0;
        for (i = 0; i < AMBIENT_COUNT; i++) {
            this.motes.push({
                fx: this.rand(),
                fy: this.rand(),
                vx: (this.rand() - 0.5) * 0.04,
                vy: 0.02 + this.rand() * 0.05,
                size: 1.2 + this.rand() * 2.2,
                phase: this.rand() * Math.PI * 2,
            });
        }
    }

    reset(): void {
        this.sparks = [];
        this.rings = [];
        this.tracers = [];
        this.plumes = [];
        this.bursts = [];
        this.stepDusts = [];
        this.hitVignette = 0;
        this.deflectFlash = 0;
        this.visualHitstop = 0;
        this.crosshairKick = 0;
    }

    /** 接收角色脚步/急停/起跳/落地事件，生成贴地暗黑像素扬尘 */
    ingestFootsteps(cues: FootstepCue[]): void {
        for (let i = 0; i < cues.length; i++) {
            const c = cues[i];
            if (this.stepDusts.length >= 26) {
                this.stepDusts.shift();
            }
            const wide = c.kind === "land" || c.kind === "brake";
            const maxLife = c.kind === "land" ? 0.34 : (c.kind === "brake" ? 0.28 : 0.22);
            this.stepDusts.push({
                x: c.x,
                y: c.y,
                depth: c.depth,
                facing: c.facing,
                life: maxLife,
                maxLife,
                scale: (wide ? 1.15 : 0.78) * Math.max(0.6, c.strength),
                wide,
            });
            if (c.kind === "land") {
                this.stepDusts.push({
                    x: c.x + c.facing * 8,
                    y: c.y,
                    depth: c.depth,
                    facing: -c.facing,
                    life: maxLife * 0.9,
                    maxLife: maxLife * 0.9,
                    scale: 0.92 * Math.max(0.6, c.strength),
                    wide: true,
                });
            }
        }
    }

    /** 根据后端边沿事件生成对应 ICEY 打击与交互特效 */
    ingest(ev: FrameEvents, p: Play, cam: CameraDirector): void {
        if (ev.roomChanged) {
            this.reset();
        }

        if (ev.shotFired && ev.shotTrace !== undefined) {
            this.spawnShot(ev.shotTrace);
            this.crosshairKick = 12;
            cam.addShake(ev.shotHit ? 6.5 : 3.2);
            if (ev.shotHit) {
                this.visualHitstop = 0.045;
            }
        }

        if (ev.enemyKilledX > -5000) {
            this.spawnBurst(ev.enemyKilledX, ev.enemyKilledY, 14, PALETTE.sealRedBright, 175);
            this.spawnBurst(ev.enemyKilledX, ev.enemyKilledY, 7, PALETTE.amberDim, 130);
            this.rings.push({ x: ev.enemyKilledX, y: ev.enemyKilledY, maxR: 40, life: 0.34, maxLife: 0.34, color: PALETTE.sealRed });
        }

        if (ev.coverDeflect) {
            this.deflectFlash = 1.0;
            this.deflectX = p.player.x + p.player.facing * 16;
            this.deflectY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.48;
            let nearest = 48;
            for (const solid of p.room.solids) {
                const edge = p.player.x < solid.x ? solid.x : solid.x + solid.w;
                const gap = Math.abs(p.player.x - edge);
                if (!solid.passable && !solid.decorative && solid.y <= p.player.y + 2 && solid.h <= 64 &&
                    gap < nearest && overlapsDepth(p.player.depth, solid.depth, ACTOR_DEPTH_HALF)) {
                    nearest = gap;
                    this.deflectX = edge;
                    this.deflectY = solid.y + (solid.depth?.min ?? 0) * DEPTH_Y_SCALE + solid.h * 0.86;
                }
            }
            this.spawnBurst(this.deflectX, this.deflectY, 8, PALETTE.amberDim, 115);
            cam.addShake(2.6);
        }

        if (ev.playerHit) {
            this.hitVignette = 1.0;
            this.spawnBurst(p.player.x, p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.55, 14, PALETTE.sealRedBright, 185);
            cam.addShake(10);
            this.visualHitstop = 0.055;
        }

        if (ev.rollStarted) {
            this.spawnBurst(p.player.x, p.player.y + p.player.depth * DEPTH_Y_SCALE + 4, 7, PALETTE.textDim, 82);
        }

        if (ev.knockPulse) {
            this.rings.push({ x: ev.knockX, y: ev.knockY, maxR: 52, life: 0.55, maxLife: 0.55, color: PALETTE.amber });
            this.rings.push({ x: ev.knockX, y: ev.knockY, maxR: 32, life: 0.38, maxLife: 0.38, color: PALETTE.xuanWarm });
        }

        if (ev.bottleLanded) {
            const ly = ev.bottleLandY;
            const isBrick = p.room.brickX !== undefined && Math.abs(ev.bottleLandX - p.room.brickX) <= 36;
            const ringCol = isBrick ? PALETTE.amber : PALETTE.emerald;
            this.rings.push({ x: ev.bottleLandX, y: ly + 4, maxR: isBrick ? 96 : 38, life: 0.85, maxLife: 0.85, color: ringCol });
            this.rings.push({ x: ev.bottleLandX, y: ly + 4, maxR: isBrick ? 62 : 22, life: 0.52, maxLife: 0.52, color: PALETTE.xuanWarm });
            this.spawnBurst(ev.bottleLandX, ly + 6, 10, PALETTE.amberDim, 120);
            cam.addShake(isBrick ? 3.5 : 1.5);
        }

        if (ev.cartJustDocked) {
            const cx = p.cartAxle;
            const cy = p.room.cart.baseY + (p.room.cart.depth ?? 0) * DEPTH_Y_SCALE + 8;
            this.rings.push({ x: cx, y: cy, maxR: 58, life: 0.55, maxLife: 0.55, color: PALETTE.emerald });
            this.spawnBurst(cx, cy, 12, PALETTE.amber, 115);
            cam.addShake(4.8);
        }

        if (ev.caughtTriggered) {
            this.hitVignette = 0.9;
            cam.addShake(9.0);
        }
    }

    private spawnShot(t: Trace): void {
        this.tracers.push({
            x0: t.x0, y0: t.y0, x1: t.x1, y1: t.y1,
            hit: t.hit, life: 0.16, maxLife: 0.16,
        });
        this.plumes.push({
            x: t.x0, y: t.y0, dir: t.x1 >= t.x0 ? 1 : -1,
            life: 0.44, maxLife: 0.44,
        });
        this.bursts.push({
            x: t.x1, y: t.y1, hit: t.hit,
            life: 0.28, maxLife: 0.28,
        });
        // 枪口火药火星 + 落点碎屑/暗朱溅星
        this.spawnBurst(t.x0, t.y0, 5, PALETTE.amberCore, 105);
        this.spawnBurst(t.x1, t.y1, t.hit ? 9 : 6, t.hit ? PALETTE.sealRedBright : PALETTE.amberDim, 130);
    }

    private spawnBurst(wx: number, wy: number, count: number, color: RGBA, speed: number): void {
        let i = 0;
        for (i = 0; i < count; i++) {
            const a = this.rand() * Math.PI * 2;
            const s = speed * (0.35 + this.rand() * 0.85);
            const life = 0.22 + this.rand() * 0.26;
            this.sparks.push({
                x: wx, y: wy,
                vx: Math.cos(a) * s,
                vy: Math.sin(a) * s + 35,
                life, maxLife: life,
                size: 1.8 + this.rand() * 2.4,
                color,
            });
        }
    }

    update(dt: number, ambient: AmbientKind): void {
        if (this.visualHitstop > 0) {
            this.visualHitstop = Math.max(0, this.visualHitstop - dt);
            return;
        }
        this.hitVignette = Math.max(0, this.hitVignette - dt * 2.2);
        this.deflectFlash = Math.max(0, this.deflectFlash - dt * 3.2);
        this.crosshairKick = Math.max(0, this.crosshairKick - dt * 48);

        // 曳光弹道
        let w = 0;
        let i = 0;
        for (i = 0; i < this.tracers.length; i++) {
            const tr = this.tracers[i];
            tr.life -= dt;
            if (tr.life > 0) {
                this.tracers[w] = tr;
                w += 1;
            }
        }
        this.tracers.length = w;

        // 鸟铳黑火药硝烟团
        w = 0;
        for (i = 0; i < this.plumes.length; i++) {
            const pl = this.plumes[i];
            pl.life -= dt;
            if (pl.life > 0) {
                pl.x += pl.dir * 24 * dt * (pl.life / pl.maxLife);
                pl.y += 18 * dt;
                this.plumes[w] = pl;
                w += 1;
            }
        }
        this.plumes.length = w;

        // 弹着点碎屑爆裂
        w = 0;
        for (i = 0; i < this.bursts.length; i++) {
            const bu = this.bursts[i];
            bu.life -= dt;
            if (bu.life > 0) {
                this.bursts[w] = bu;
                w += 1;
            }
        }
        this.bursts.length = w;

        // 粒子
        w = 0;
        for (i = 0; i < this.sparks.length; i++) {
            const sp = this.sparks[i];
            sp.life -= dt;
            if (sp.life > 0) {
                sp.vy -= 420 * dt;
                sp.x += sp.vx * dt;
                sp.y += sp.vy * dt;
                if (sp.y < 0) {
                    sp.y = 0;
                    sp.vy = -sp.vy * 0.35;
                    sp.vx *= 0.7;
                }
                this.sparks[w] = sp;
                w += 1;
            }
        }
        this.sparks.length = w;

        // 声波环
        w = 0;
        for (i = 0; i < this.rings.length; i++) {
            const rg = this.rings[i];
            rg.life -= dt;
            if (rg.life > 0) {
                this.rings[w] = rg;
                w += 1;
            }
        }
        this.rings.length = w;

        // 脚步/落地/急停贴地扬尘
        w = 0;
        for (i = 0; i < this.stepDusts.length; i++) {
            const sd = this.stepDusts[i];
            sd.life -= dt;
            if (sd.life > 0) {
                this.stepDusts[w] = sd;
                w += 1;
            }
        }
        this.stepDusts.length = w;

        // 环境氛围粒子
        for (i = 0; i < this.motes.length; i++) {
            const m = this.motes[i];
            m.phase += dt * 2.0;
            if (ambient === "drizzle") {
                m.fx -= dt * 0.14;
                m.fy -= dt * 0.72;
            } else if (ambient === "ash") {
                m.fx += (m.vx - 0.035) * dt;
                m.fy += (m.vy * 0.55) * dt;
            } else if (ambient === "spores") {
                m.fx += Math.sin(m.phase) * 0.015 * dt;
                m.fy += Math.cos(m.phase * 0.7) * 0.018 * dt;
            } else {
                m.fx += Math.sin(m.phase * 0.6) * 0.01 * dt;
                m.fy += 0.018 * dt;
            }
            if (m.fx < 0) { m.fx += 1; }
            if (m.fx > 1) { m.fx -= 1; }
            if (m.fy < 0) { m.fy += 1; }
            if (m.fy > 1) { m.fy -= 1; }
        }
    }

    /** 绘制世界空间特效（冷月火药弹道、暗朱墨烟溅星、脚步扬尘、枯笔声波环） */
    drawWorldVfx(
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        cam: CameraDirector,
        depthEnabled: boolean = false,
    ): void {
        const muzzleLayer = depthEnabled ? 5100 : 9;
        const smokeLayer = depthEnabled ? 5090 : 8;
        const impactLayer = depthEnabled ? 5100 : 9;
        const deflectLayer = depthEnabled ? 5090 : 8;
        const ringLayer = depthEnabled ? 5085 : 7;

        // 1. 冷月火药曳光弹道（去赛博宽青光）
        let i = 0;
        for (i = 0; i < this.tracers.length; i++) {
            const tr = this.tracers[i];
            const k = tr.life / tr.maxLife;
            const x0 = cam.sx(tr.x0);
            const y0 = cam.sy(tr.y0);
            const x1 = cam.sx(tr.x1);
            const y1 = cam.sy(tr.y1);
            const outerCol = tr.hit ? PALETTE.sealRedBright : PALETTE.amber;

            // 克制火药余烟外晕 + 暖白弹芯
            fgGlow.drawSegment(Vec2(x0, y0), Vec2(x1, y1), 3.2 * k, toColor(outerCol, 88 * k));
            fgGlow.drawSegment(Vec2(x0, y0), Vec2(x1, y1), 1.3 * k, toColor(PALETTE.amberCore, 195 * k));

            // 枪口明式鸟铳 4 帧暗黑像素爆焰（沿弹道旋转，替代单帧旧图）
            if (k > 0.40) {
                const mk = (k - 0.40) / 0.60;
                const mIdx = Math.min(3, Math.floor((1 - mk) * 4));
                const shotAngle = -Math.atan2(y1 - y0, x1 - x0) * 180 / Math.PI;
                const blastH = Math.max(20, cam.len(26 * (0.82 + 0.34 * mk)));
                fillRadialGlow(fgGlow, x0, y0, 22 * mk, 18 * mk, toColor(PALETTE.amberCore, 136 * mk), Color(186, 126, 62, 0), 12);
                if (!assets.tryPlacePath(MUZZLE_CLIPS[mIdx], "vfx_muzzle_" + i, x0, y0, blastH * 1.6, blastH, {
                    anchorX: 0.14,
                    anchorY: 0.48,
                    preserveAspect: true,
                    angle: shotAngle,
                    opacity: Math.min(1, mk * 1.2),
                    layer: muzzleLayer,
                }) && !assets.tryPlacePath("assets/art/vfx_craft_art.clip|vfx_muzzle_blast", "vfx_muzzle_" + i, x0, y0, blastH * 1.7, blastH, {
                    anchorX: 0.14,
                    anchorY: 0.42,
                    preserveAspect: true,
                    angle: shotAngle,
                    opacity: Math.min(1, mk * 1.15),
                    smooth: true,
                    layer: muzzleLayer,
                })) {
                    fgGlow.drawSegment(Vec2(x0 - 10 * mk, y0), Vec2(x0 + 10 * mk, y0), 1.2, toColor(PALETTE.amberCore, 165 * mk));
                    fgGlow.drawSegment(Vec2(x0, y0 - 7 * mk), Vec2(x0, y0 + 7 * mk), 1.0, toColor(PALETTE.amber, 145 * mk));
                }
            }
            // 命中暗朱星芒与火药微闪
            if (tr.hit) {
                const s = 16 * (1.15 - k * 0.45);
                fillRadialGlow(fgGlow, x1, y1, s * 1.15, s * 0.9, toColor(PALETTE.sealRedBright, 130 * k), Color(168, 46, 44, 0), 12);
                fgGlow.drawSegment(Vec2(x1 - s, y1 - s * 0.55), Vec2(x1 + s, y1 + s * 0.55), 1.6 * k, toColor(PALETTE.crimsonCore, 185 * k));
                fgGlow.drawSegment(Vec2(x1 - s * 0.45, y1 + s * 0.7), Vec2(x1 + s * 0.45, y1 - s * 0.7), 1.2 * k, toColor(PALETTE.sealRedBright, 160 * k));
            }
        }

        // 1b. 黑火药 4 帧暗黑像素硝烟团（随枪口散逸抬升）
        for (i = 0; i < this.plumes.length; i++) {
            const pl = this.plumes[i];
            const k = pl.life / pl.maxLife;
            const grow = 1 - k;
            const sIdx = Math.min(3, Math.floor(grow * 4));
            const size = cam.len(18 + grow * 30);
            if (!assets.tryPlacePath(SMOKE_CLIPS[sIdx], "vfx_smoke_" + i, cam.sx(pl.x), cam.sy(pl.y), size, size, {
                anchorX: 0.5,
                anchorY: 0.5,
                preserveAspect: true,
                facing: pl.dir,
                opacity: k * 0.72,
                layer: smokeLayer,
            })) {
                assets.tryPlacePath("assets/art/vfx_craft_art.clip|vfx_smoke_plume", "vfx_smoke_" + i, cam.sx(pl.x), cam.sy(pl.y), size, size, {
                    anchorX: 0.5,
                    anchorY: 0.5,
                    preserveAspect: true,
                    facing: pl.dir,
                    opacity: k * 0.68,
                    smooth: true,
                    layer: smokeLayer,
                });
            }
        }

        // 1c. 弹着点暗黑像素星芒/碎屑爆裂
        for (i = 0; i < this.bursts.length; i++) {
            const bu = this.bursts[i];
            const k = bu.life / bu.maxLife;
            const size = cam.len(18 + (1 - k) * 22);
            const clip = bu.hit ? HIT_SPARK_CLIP : DEBRIS_CLIP;
            if (!assets.tryPlacePath(clip, "vfx_impact_" + i, cam.sx(bu.x), cam.sy(bu.y), size, size, {
                anchorX: 0.5,
                anchorY: 0.5,
                preserveAspect: true,
                opacity: k * 0.92,
                layer: impactLayer,
            })) {
                assets.tryPlacePath("assets/art/vfx_craft_art.clip|vfx_debris_burst", "vfx_impact_" + i, cam.sx(bu.x), cam.sy(bu.y), size, size, {
                    anchorX: 0.5,
                    anchorY: 0.5,
                    preserveAspect: true,
                    color: bu.hit ? Color(246, 174, 152, 255) : Color(235, 224, 206, 255),
                    opacity: k * 0.88,
                    smooth: true,
                    layer: impactLayer,
                });
            }
        }

        if (this.deflectFlash > 0) {
            const k = this.deflectFlash;
            const dy = cam.sy(this.deflectY + (1 - k) * 11);
            const height = cam.len(22 + (1 - k) * 18);
            if (!assets.tryPlacePath(DEBRIS_CLIP, "blocked", cam.sx(this.deflectX), dy, height, height, {
                anchorX: 0.5,
                anchorY: 0.5,
                preserveAspect: true,
                opacity: k * 0.94,
                layer: deflectLayer,
            })) {
                assets.tryPlace("stone_chips", "blocked", cam.sx(this.deflectX), dy, height, height, {
                    opacity: k, layer: deflectLayer,
                });
            }
        }

        // 2. 脚步着地 / 急停 / 起跳 / 落地暗黑像素扬尘
        for (i = 0; i < this.stepDusts.length; i++) {
            const sd = this.stepDusts[i];
            const k = sd.life / sd.maxLife;
            const prog = 1 - k;
            const dScale = cam.depthScale(sd.depth, depthEnabled);
            const sx = cam.sx(sd.x - sd.facing * prog * 9);
            const sy = cam.sy(sd.y + prog * 1.5, sd.depth);
            const size = cam.len((11 + prog * 14) * sd.scale) * dScale;
            const clip = STEP_DUST_CLIPS[sd.wide || prog > 0.45 ? 1 : 0];
            if (!assets.tryPlacePath(clip, "vfx_step_dust_" + i, sx, sy, size * 1.3, size, {
                anchorX: 0.5,
                anchorY: 0,
                preserveAspect: true,
                facing: sd.facing,
                opacity: k * 0.72,
                layer: depthEnabled ? depthOrder(sd.depth, 5) : 6,
            })) {
                fgGlow.drawEllipse(Vec2(sx, sy + 1), size * 0.42, size * 0.14, Color(166, 154, 138, Math.round(110 * k)));
            }
        }

        // 3. 纤细枯笔墨韵扩散声波环
        for (i = 0; i < this.rings.length; i++) {
            const rg = this.rings[i];
            const prog = 1 - rg.life / rg.maxLife;
            const r = Math.max(4, cam.len(rg.maxR) * prog);
            const alpha = (1 - prog) * 0.80;
            const rx = cam.sx(rg.x);
            const ry = cam.sy(rg.y);
            if (!assets.tryPlace("ink_enso_fine", "vfx_ring_" + i, rx, ry, r * 2.35, r * 2.35, {
                color: toColor(rg.color), opacity: alpha, angle: prog * 24, layer: ringLayer,
            })) {
                fgGlow.drawRing(Vec2(rx, ry), Math.max(1, r - 1.8), r, Color(0, 0, 0, 0), 1.2, toColor(rg.color, alpha * 230));
            }
        }

        // 4. 火药火星与灰烬碎片
        for (i = 0; i < this.sparks.length; i++) {
            const sp = this.sparks[i];
            const k = sp.life / sp.maxLife;
            const sx = cam.sx(sp.x);
            const sy = cam.sy(sp.y);
            const tx = sx - sp.vx * 0.020 * cam.ppu;
            const ty = sy - sp.vy * 0.020 * cam.ppu;
            fgGlow.drawSegment(Vec2(tx, ty), Vec2(sx, sy), sp.size * k * 0.9, toColor(sp.color, 210 * k));
        }
    }

    /** 绘制屏幕空间氛围粒子 + 暗朱受击墨边脉冲（像素模式由 SceneFxSystem 接管三层天气，此处仅保留受击红边） */
    drawScreenVfx(fgGlow: DrawNode.Type, w: number, h: number, roomKey: string, drawAmbient: boolean = true): void {
        if (drawAmbient) {
            const theme = themeOf(roomKey);
            const kind = theme.ambient;
            let i = 0;
            for (i = 0; i < this.motes.length; i++) {
                const m = this.motes[i];
                const x = m.fx * w;
                const y = m.fy * h;
                const tw = 0.55 + 0.45 * Math.sin(m.phase);
                if (kind === "drizzle") {
                    fgGlow.drawSegment(Vec2(x, y), Vec2(x + 4, y + 18), 0.85, Color(156, 174, 188, Math.round(44 * tw)));
                } else if (kind === "ash") {
                    const c = roomKey === "gate" ? PALETTE.sealRedBright : PALETTE.amberDim;
                    fgGlow.drawDot(Vec2(x, y), m.size * 0.82, toColor(c, 78 * tw));
                } else if (kind === "spores") {
                    fgGlow.drawDot(Vec2(x, y), m.size * 0.9, toColor(PALETTE.emerald, 82 * tw));
                } else {
                    fgGlow.drawDot(Vec2(x, y), m.size * 0.95, toColor(PALETTE.amberCore, 94 * tw));
                }
            }
        }

        // 受击暗朱墨烟屏边（去荧光红）
        if (this.hitVignette > 0.01) {
            const a = Math.round(120 * this.hitVignette);
            const edge = 72;
            fillHGradRect(fgGlow, 0, 0, edge, h, Color(148, 36, 32, a), Color(148, 36, 32, 0));
            fillHGradRect(fgGlow, w - edge, 0, edge, h, Color(148, 36, 32, 0), Color(148, 36, 32, a));
            fillVGradRect(fgGlow, 0, 0, w, edge * 0.8, Color(148, 36, 32, a), Color(148, 36, 32, 0));
            fillVGradRect(fgGlow, 0, h - edge * 0.8, w, edge * 0.8, Color(148, 36, 32, 0), Color(148, 36, 32, a));
        }
    }
}
