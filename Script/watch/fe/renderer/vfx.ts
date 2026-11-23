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
import { CameraDirector } from "Script/watch/fe/camera";
import {
    AmbientKind,
    PALETTE,
    RGBA,
    drawDiamond,
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
            this.spawnBurst(ev.enemyKilledX, ev.enemyKilledY, 18, PALETTE.crimson, 210);
            this.spawnBurst(ev.enemyKilledX, ev.enemyKilledY, 8, PALETTE.cyanCore, 150);
            this.rings.push({ x: ev.enemyKilledX, y: ev.enemyKilledY, maxR: 46, life: 0.34, maxLife: 0.34, color: PALETTE.crimson });
        }

        if (ev.coverDeflect) {
            this.deflectFlash = 1.0;
            this.deflectX = p.player.x + p.player.facing * 20;
            this.deflectY = p.player.y + p.player.h * 0.58;
            this.spawnBurst(this.deflectX, this.deflectY, 14, PALETTE.cyan, 180);
            this.rings.push({ x: this.deflectX, y: this.deflectY, maxR: 42, life: 0.32, maxLife: 0.32, color: PALETTE.cyan });
            cam.addShake(4.2);
        }

        if (ev.playerHit) {
            this.hitVignette = 1.0;
            this.spawnBurst(p.player.x, p.player.y + p.player.h * 0.55, 16, PALETTE.crimson, 220);
            cam.addShake(11);
            this.visualHitstop = 0.06;
        }

        if (ev.rollStarted) {
            this.spawnBurst(p.player.x, p.player.y + 4, 8, PALETTE.cyan, 95);
        }

        if (ev.knockPulse) {
            this.rings.push({ x: ev.knockX, y: ev.knockY, maxR: 54, life: 0.55, maxLife: 0.55, color: PALETTE.amber });
            this.rings.push({ x: ev.knockX, y: ev.knockY, maxR: 34, life: 0.38, maxLife: 0.38, color: PALETTE.cyanCore });
        }

        if (ev.bottleLanded) {
            const isBrick = p.room.brickX !== undefined && Math.abs(ev.bottleLandX - p.room.brickX) <= 36;
            const ringCol = isBrick ? PALETTE.amber : PALETTE.emerald;
            this.rings.push({ x: ev.bottleLandX, y: 4, maxR: isBrick ? 96 : 38, life: 0.85, maxLife: 0.85, color: ringCol });
            this.rings.push({ x: ev.bottleLandX, y: 4, maxR: isBrick ? 62 : 22, life: 0.52, maxLife: 0.52, color: PALETTE.cyanCore });
            this.spawnBurst(ev.bottleLandX, 6, 12, PALETTE.emerald, 140);
            cam.addShake(isBrick ? 3.5 : 1.5);
        }

        if (ev.cartJustDocked) {
            const cx = p.cartAxle;
            const cy = p.room.cart.baseY + 8;
            this.rings.push({ x: cx, y: cy, maxR: 60, life: 0.55, maxLife: 0.55, color: PALETTE.emerald });
            this.spawnBurst(cx, cy, 14, PALETTE.amber, 130);
            cam.addShake(5.0);
        }

        if (ev.caughtTriggered) {
            this.hitVignette = 0.9;
            cam.addShake(9.0);
        }
    }

    private spawnShot(t: Trace): void {
        this.tracers.push({
            x0: t.x0, y0: t.y0, x1: t.x1, y1: t.y1,
            hit: t.hit, life: 0.18, maxLife: 0.18,
        });
        // 枪口火花 + 落点火花
        this.spawnBurst(t.x0, t.y0, 5, PALETTE.cyanCore, 120);
        this.spawnBurst(t.x1, t.y1, t.hit ? 10 : 6, t.hit ? PALETTE.crimson : PALETTE.cyan, 145);
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

    /** 绘制世界空间特效（弹道、火花、格挡光幕、声波环） */
    drawWorldVfx(fgGlow: DrawNode.Type, cam: CameraDirector): void {
        // 1. 斩切式霓虹曳光弹道
        let i = 0;
        for (i = 0; i < this.tracers.length; i++) {
            const tr = this.tracers[i];
            const k = tr.life / tr.maxLife;
            const x0 = cam.sx(tr.x0);
            const y0 = cam.sy(tr.y0);
            const x1 = cam.sx(tr.x1);
            const y1 = cam.sy(tr.y1);
            const outerCol = tr.hit ? PALETTE.crimson : PALETTE.cyan;

            // 宽光晕 + 锐利白芯
            fgGlow.drawSegment(Vec2(x0, y0), Vec2(x1, y1), 5.5 * k, toColor(outerCol, 130 * k));
            fgGlow.drawSegment(Vec2(x0, y0), Vec2(x1, y1), 1.8 * k, toColor(PALETTE.cyanCore, 255 * k));

            // 枪口十字焰
            if (k > 0.55) {
                const mk = (k - 0.55) / 0.45;
                fillRadialGlow(fgGlow, x0, y0, 26 * mk, 26 * mk, toColor(PALETTE.cyanCore, 180 * mk), Color(72, 224, 255, 0), 12);
                fgGlow.drawSegment(Vec2(x0 - 16 * mk, y0), Vec2(x0 + 16 * mk, y0), 1.6, toColor(PALETTE.cyanCore, 220 * mk));
                fgGlow.drawSegment(Vec2(x0, y0 - 14 * mk), Vec2(x0, y0 + 14 * mk), 1.6, toColor(PALETTE.cyanCore, 220 * mk));
            }
            // 命中斜切星芒（ICEY 标志打击感）
            if (tr.hit) {
                const s = 26 * (1.2 - k * 0.5);
                fgGlow.drawSegment(Vec2(x1 - s, y1 - s * 0.65), Vec2(x1 + s, y1 + s * 0.65), 2.4 * k, toColor(PALETTE.crimsonCore, 240 * k));
                fgGlow.drawSegment(Vec2(x1 - s * 0.55, y1 + s * 0.7), Vec2(x1 + s * 0.55, y1 - s * 0.7), 1.8 * k, toColor(PALETTE.crimson, 210 * k));
            }
        }

        // 2. 掩体格挡全息盾爆闪
        if (this.deflectFlash > 0) {
            const k = this.deflectFlash;
            const dx = cam.sx(this.deflectX);
            const dy = cam.sy(this.deflectY);
            const r = 18 + (1 - k) * 32;
            drawDiamond(fgGlow, dx, dy, r * 0.65, r * 1.15, toColor(PALETTE.cyan, 65 * k), 2.2, toColor(PALETTE.cyanCore, 235 * k));
            fillRadialGlow(fgGlow, dx, dy, r * 1.6, r * 1.6, toColor(PALETTE.cyan, 120 * k), Color(72, 224, 255, 0), 14);
        }

        // 3. 同心扩散声波环
        for (i = 0; i < this.rings.length; i++) {
            const rg = this.rings[i];
            const prog = 1 - rg.life / rg.maxLife;
            const r = Math.max(4, cam.len(rg.maxR) * prog);
            const alpha = (1 - prog) * 215;
            const rx = cam.sx(rg.x);
            const ry = cam.sy(rg.y);
            fgGlow.drawRing(Vec2(rx, ry), Math.max(1, r - 2.2), r, Color(0, 0, 0, 0), 1.5, toColor(rg.color, alpha));
        }

        // 4. 高速火花与碎片
        for (i = 0; i < this.sparks.length; i++) {
            const sp = this.sparks[i];
            const k = sp.life / sp.maxLife;
            const sx = cam.sx(sp.x);
            const sy = cam.sy(sp.y);
            const tx = sx - sp.vx * 0.022 * cam.ppu;
            const ty = sy - sp.vy * 0.022 * cam.ppu;
            fgGlow.drawSegment(Vec2(tx, ty), Vec2(sx, sy), sp.size * k, toColor(sp.color, 235 * k));
        }
    }

    /** 绘制屏幕空间氛围粒子 + 受击红边脉冲 */
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
                fgGlow.drawSegment(Vec2(x, y), Vec2(x + 4, y + 18), 0.9, Color(156, 206, 240, Math.round(52 * tw)));
            } else if (kind === "ash") {
                const c = roomKey === "gate" ? PALETTE.crimson : PALETTE.amber;
                fgGlow.drawDot(Vec2(x, y), m.size * 0.85, toColor(c, 92 * tw));
            } else if (kind === "spores") {
                fgGlow.drawDot(Vec2(x, y), m.size, toColor(PALETTE.emerald, 108 * tw));
            } else {
                fgGlow.drawDot(Vec2(x, y), m.size * 1.05, toColor(PALETTE.amberCore, 118 * tw));
            }
        }

        // 受击全屏绯红脉冲边框
        if (this.hitVignette > 0.01) {
            const a = Math.round(135 * this.hitVignette);
            const edge = 68;
            fillHGradRect(fgGlow, 0, 0, edge, h, Color(255, 32, 68, a), Color(255, 32, 68, 0));
            fillHGradRect(fgGlow, w - edge, 0, edge, h, Color(255, 32, 68, 0), Color(255, 32, 68, a));
            fillVGradRect(fgGlow, 0, 0, w, edge * 0.8, Color(255, 32, 68, a), Color(255, 32, 68, 0));
            fillVGradRect(fgGlow, 0, h - edge * 0.8, w, edge * 0.8, Color(255, 32, 68, 0), Color(255, 32, 68, a));
        }
    }
}
