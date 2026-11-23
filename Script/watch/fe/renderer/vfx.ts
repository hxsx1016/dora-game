/**
 * 艾希（ICEY）风格特效与粒子池：
 * - 斩切式霓虹曳光弹道、枪口十字焰、命中碎屑与受击闪白
 * - 掩体格挡（类「一闪」）冰青菱形护盾爆闪
 * - 双环声波扩散（安抚敲两下、塔门敲两下、投瓶落砖地）
 * - 各房间专属环境粒子（火星灰烬 / 细雨 / 森林孢子 / 北塔暖光浮尘）
 * - 纯表现层微顿帧（Hitstop）与全屏受击红边脉冲（不阻塞后端 60Hz 时钟）
 */

import { Color, DrawNode, Vec2 } from "Dora";
import { Play, Trace } from "Script/watch/play";
import { FrameEvents } from "Script/watch/fe/adapter";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
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

interface AmbientMote {
    fx: number; // 0..1 屏幕归一化位置
    fy: number;
    vx: number;
    vy: number;
    size: number;
    phase: number;
}

const AMBIENT_COUNT = 34;

export class VfxSystem {
    private sparks: Spark[] = [];
    private rings: SonicRing[] = [];
    private tracers: SlashTracer[] = [];
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
        this.hitVignette = 0;
        this.deflectFlash = 0;
        this.visualHitstop = 0;
        this.crosshairKick = 0;
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
            this.deflectY = p.player.y + p.player.h * 0.48;
            let nearest = 48;
            for (const solid of p.room.solids) {
                const edge = p.player.x < solid.x ? solid.x : solid.x + solid.w;
                const gap = Math.abs(p.player.x - edge);
                if (!solid.passable && solid.y <= p.player.y + 2 && solid.h <= 64 && gap < nearest) {
                    nearest = gap;
                    this.deflectX = edge;
                    this.deflectY = solid.y + solid.h * 0.86;
                }
            }
            this.spawnBurst(this.deflectX, this.deflectY, 8, PALETTE.amberDim, 115);
            cam.addShake(2.6);
        }

        if (ev.playerHit) {
            this.hitVignette = 1.0;
            this.spawnBurst(p.player.x, p.player.y + p.player.h * 0.55, 14, PALETTE.sealRedBright, 185);
            cam.addShake(10);
            this.visualHitstop = 0.055;
        }

        if (ev.rollStarted) {
            this.spawnBurst(p.player.x, p.player.y + 4, 7, PALETTE.textDim, 82);
        }

        if (ev.knockPulse) {
            this.rings.push({ x: ev.knockX, y: ev.knockY, maxR: 52, life: 0.55, maxLife: 0.55, color: PALETTE.amber });
            this.rings.push({ x: ev.knockX, y: ev.knockY, maxR: 32, life: 0.38, maxLife: 0.38, color: PALETTE.xuanWarm });
        }

        if (ev.bottleLanded) {
            const isBrick = p.room.brickX !== undefined && Math.abs(ev.bottleLandX - p.room.brickX) <= 36;
            const ringCol = isBrick ? PALETTE.amber : PALETTE.emerald;
            this.rings.push({ x: ev.bottleLandX, y: 4, maxR: isBrick ? 96 : 38, life: 0.85, maxLife: 0.85, color: ringCol });
            this.rings.push({ x: ev.bottleLandX, y: 4, maxR: isBrick ? 62 : 22, life: 0.52, maxLife: 0.52, color: PALETTE.xuanWarm });
            this.spawnBurst(ev.bottleLandX, 6, 10, PALETTE.amberDim, 120);
            cam.addShake(isBrick ? 3.5 : 1.5);
        }

        if (ev.cartJustDocked) {
            const cx = p.cartAxle;
            const cy = p.room.cart.baseY + 8;
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

    /** 绘制世界空间特效（冷月火药弹道、暗朱墨烟溅星、枯笔声波环） */
    drawWorldVfx(fgGlow: DrawNode.Type, assets: AssetSlotHost, cam: CameraDirector): void {
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

            // 枪口火药暖焰（去冰青激光十字）
            if (k > 0.55) {
                const mk = (k - 0.55) / 0.45;
                fillRadialGlow(fgGlow, x0, y0, 18 * mk, 14 * mk, toColor(PALETTE.amberCore, 138 * mk), Color(186, 126, 62, 0), 12);
                fgGlow.drawSegment(Vec2(x0 - 10 * mk, y0), Vec2(x0 + 10 * mk, y0), 1.2, toColor(PALETTE.amberCore, 165 * mk));
                fgGlow.drawSegment(Vec2(x0, y0 - 7 * mk), Vec2(x0, y0 + 7 * mk), 1.0, toColor(PALETTE.amber, 145 * mk));
            }
            // 命中暗朱溅墨微闪
            if (tr.hit) {
                const s = 18 * (1.15 - k * 0.45);
                fgGlow.drawSegment(Vec2(x1 - s, y1 - s * 0.55), Vec2(x1 + s, y1 + s * 0.55), 1.7 * k, toColor(PALETTE.sealRedBright, 155 * k));
                assets.tryPlace("ink_splatter", "hit_ink_" + i, x1, y1, s * 2.0, s * 2.0, {
                    color: toColor(PALETTE.sealRed), opacity: 0.52 * k, layer: 7,
                });
            }
        }

        if (this.deflectFlash > 0) {
            const k = this.deflectFlash;
            const dy = cam.sy(this.deflectY + (1 - k) * 11);
            const height = cam.len(18 + (1 - k) * 12);
            assets.tryPlace("stone_chips", "blocked", cam.sx(this.deflectX), dy, height, height, {
                opacity: k, layer: 8,
            });
        }

        // 3. 枯笔墨韵扩散声波环
        for (i = 0; i < this.rings.length; i++) {
            const rg = this.rings[i];
            const prog = 1 - rg.life / rg.maxLife;
            const r = Math.max(4, cam.len(rg.maxR) * prog);
            const alpha = (1 - prog) * 0.82;
            const rx = cam.sx(rg.x);
            const ry = cam.sy(rg.y);
            if (!assets.tryPlace("ink_ring", "vfx_ring_" + i, rx, ry, r * 2.35, r * 2.35, {
                color: toColor(rg.color), opacity: alpha, angle: prog * 24, layer: 7,
            })) {
                fgGlow.drawRing(Vec2(rx, ry), Math.max(1, r - 2.0), r, Color(0, 0, 0, 0), 1.3, toColor(rg.color, alpha * 235));
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

    /** 绘制屏幕空间氛围粒子 + 暗朱受击墨边脉冲 */
    drawScreenVfx(fgGlow: DrawNode.Type, w: number, h: number, roomKey: string): void {
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
