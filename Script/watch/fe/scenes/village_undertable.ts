/**
 * 《向西守望》Wave 2 fe-04 空村桌下专章（分镜 F01 下半 · 重点验收样段）。
 *
 * 严格对表《第二波施工书》fe-04、《游戏分镜稿》F01、《动画插入与演出规划》与《明朝全局美术设定》：
 * 1. 《小小梦魇》桌下压迫构图：
 *    - 厚重木桌沿与桌围压在画面上部（wz < 0 前景层），前景一条粗大木桌腿遮住半边院门；
 *    - 右上方院门冷月斜光擦过铁盆沿与硬砖拼缝，不加任务箭头、浮签或光柱；
 *    - 通过桌下低机位 anchorLock 让桌下（304..416）、暗渠入口（440）、拾荒者鞋底（464..512）、
 *      铁盆（548）与硬砖（608）同屏可读，同时保持 wz = 0 与 Play.worldMapper 0.00 px 误差。
 * 2. 暗处与灰度可读硬标准：
 *    - 阴影里一眼看清拾荒者整双鞋底朝向（前尖后跟 + 步幅 + 侧光鞋缘）、暗渠入口（凹陷石栅 + 翻板亮边）、
 *      硬砖拼缝亮边（608）、铁盆弧形金属高光沿（548）与软土暗哑散点足印（272）。
 * 3. 双材质落点差异化视听反馈（完全跟随后端 bottleLanded 与 scavState/scavTargetX，不限制玩家钻出时机）：
 *    - 砸硬砖：干脆单响 + 碎陶砖灰 + 拾荒者鞋尖先微顿约 0.14s 再转向调查方向；
 *    - 砸铁盆：盆沿先高频阻尼颤动 + 金属余响扩散波纹 + 拾荒者鞋底随余响平滑转向；
 *    - 砸软土：低沉浮尘，无扩散亮环。
 */

import { Color, DrawNode, Vec2 } from "Dora";
import { Play, PlayEvent } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { FePluginContext } from "Script/watch/fe/plugins";
import {
    LowpolyProjection,
    clamp01,
    projectWorld3D,
    smoothstep,
} from "Script/watch/fe/renderer/lowpoly";
import { drawChildColdMoonGrade } from "Script/watch/fe/renderer/slideshow";
import {
    RGBA,
    fillRadialGlow,
    fillVGradRect,
    rgba,
    toColor,
} from "Script/watch/fe/theme";

const GRAVITY = 1000;
const BOTTLE_FLY_T = 0.62;
const CHILD_AUDIO_ROOT = "assets/audio/child/";

/** 空村铁盆世界坐标（位于拾荒者巡逻右侧、与硬砖 brickX=608 ± 34 清晰分离、完全在听觉半径 480 内） */
export const VILLAGE_BASIN_OFFSET_X = 548;
export const VILLAGE_BASIN_HIT_RADIUS = 24;
export const VILLAGE_SURFACE_HIT_RADIUS = 34;

export type VillageSurfaceKind = "brick" | "iron" | "soft";

interface ShardParticle {
    x: number;
    y: number;
    vx: number;
    vy: number;
    size: number;
    life: number;
    maxLife: number;
    kind: VillageSurfaceKind;
}

interface EchoRing {
    x: number;
    y: number;
    age: number;
    duration: number;
    maxRadius: number;
    kind: VillageSurfaceKind;
}

export interface VillageUndertableDebugState {
    active: boolean;
    basinWorldX: number;
    brickWorldX: number;
    softWorldX: number;
    culvertWorldX: number;
    lastSurface: VillageSurfaceKind | "";
    brickHits: number;
    ironHits: number;
    softHits: number;
    basinShakeTimer: number;
    basinShakeAngle: number;
    shoeToePauseTimer: number;
    shoeFacing: number;
    scavTargetX: number;
    underTableFocus: number;
    lastLandX: number;
}

function drawEllipseRing(
    draw: DrawNode.Type,
    cx: number,
    cy: number,
    rx: number,
    ry: number,
    lineW: number,
    col: Color.Type,
    segs: number = 22,
): void {
    const pts: Vec2.Type[] = [];
    let i = 0;
    for (i = 0; i < segs; i++) {
        const a = (i / segs) * Math.PI * 2;
        pts.push(Vec2(cx + Math.cos(a) * rx, cy + Math.sin(a) * ry));
    }
    draw.drawPolygon(pts, Color(0, 0, 0, 0), lineW, col);
}

export class VillageUndertableScene {
    private animTime = 0;
    private active = false;
    private underTableFocus = 0;
    private lastSurface: VillageSurfaceKind | "" = "";
    private lastLandX = -1;
    private brickHits = 0;
    private ironHits = 0;
    private softHits = 0;

    // 铁盆受击阻尼颤动状态
    private basinShakeTimer = 0;
    private basinShakeMax = 1.15;
    private basinShakeAngle = 0;

    // 拾荒者鞋底反应：砸硬砖时鞋尖先微顿约 0.14s，砸铁盆时随金属余振平滑转向
    private shoeToePauseTimer = 0;
    private shoeTurnBlend = 1;
    private shoeFacing = -1;
    private prevScavState = "patrol";
    private prevScavX = 0;
    private scavStridePhase = 0;

    private shards: ShardParticle[] = [];
    private rings: EchoRing[] = [];
    private rng = 7321;

    private proj: LowpolyProjection = {
        morph: 1,
        focal: 390,
        vpFracX: 0.54,
        vpFracY: 0.44,
        vpOffsetX: 0,
        vpOffsetY: 0,
        baseDepth: 0,
    };

    reset(): void {
        this.animTime = 0;
        this.active = false;
        this.underTableFocus = 0;
        this.lastSurface = "";
        this.lastLandX = -1;
        this.brickHits = 0;
        this.ironHits = 0;
        this.softHits = 0;
        this.basinShakeTimer = 0;
        this.basinShakeAngle = 0;
        this.shoeToePauseTimer = 0;
        this.shoeTurnBlend = 1;
        this.shoeFacing = -1;
        this.prevScavState = "patrol";
        this.prevScavX = 0;
        this.scavStridePhase = 0;
        this.shards = [];
        this.rings = [];
    }

    private rand(): number {
        this.rng = (this.rng * 1664525 + 1013904223) % 4294967296;
        return this.rng / 4294967296;
    }

    getProjection(): LowpolyProjection {
        return this.proj;
    }

    getBasinWorldX(p: Play): number {
        return p.ox + VILLAGE_BASIN_OFFSET_X;
    }

    getBrickWorldX(p: Play): number {
        return p.room.brickX ?? (p.ox + 608);
    }

    getSoftWorldX(p: Play): number {
        return p.room.softX ?? (p.ox + 272);
    }

    getCulvertWorldX(p: Play): number {
        // 对齐 VILLAGE_ROOM 后端暗渠口（560..640，中心 600；passLine=440 为院门通行线而非暗渠）
        return p.ox + 600;
    }

    /** 判定落点材质：优先消费后端 e.data.surface，缺失时按真实世界坐标 x 分类 */
    classifyLandingSurface(p: Play, x: number, explicitSurface?: string): VillageSurfaceKind {
        if (explicitSurface === "iron" || explicitSurface === "basin") {
            return "iron";
        }
        if (explicitSurface === "soft" || explicitSurface === "dirt") {
            return "soft";
        }
        if (explicitSurface === "brick") {
            return "brick";
        }
        const basinX = this.getBasinWorldX(p);
        if (Math.abs(x - basinX) <= VILLAGE_BASIN_HIT_RADIUS) {
            return "iron";
        }
        const softX = this.getSoftWorldX(p);
        if (Math.abs(x - softX) <= VILLAGE_SURFACE_HIT_RADIUS) {
            return "soft";
        }
        return "brick";
    }

    getDebugState(p?: Play): VillageUndertableDebugState {
        return {
            active: this.active,
            basinWorldX: p !== undefined ? this.getBasinWorldX(p) : VILLAGE_BASIN_OFFSET_X,
            brickWorldX: p !== undefined ? this.getBrickWorldX(p) : 608,
            softWorldX: p !== undefined ? this.getSoftWorldX(p) : 272,
            culvertWorldX: p !== undefined ? this.getCulvertWorldX(p) : 440,
            lastSurface: this.lastSurface,
            brickHits: this.brickHits,
            ironHits: this.ironHits,
            softHits: this.softHits,
            basinShakeTimer: this.basinShakeTimer,
            basinShakeAngle: this.basinShakeAngle,
            shoeToePauseTimer: this.shoeToePauseTimer,
            shoeFacing: this.shoeFacing,
            scavTargetX: p !== undefined ? p.scavTargetX : 0,
            underTableFocus: this.underTableFocus,
            lastLandX: this.lastLandX,
        };
    }

    update(ctx: FePluginContext): void {
        const p = ctx.p;
        this.active = true;

        // 桌下关注度（小满靠近、蹲伏或位于桌下 240..436 区间时自然压低视角突出桌沿压迫感）
        const arch = p.room.arch;
        const nearTable = p.player.x >= arch.x0 - 80 && p.player.x <= arch.x1 + 30;
        const targetFocus = (p.player.crouch || nearTable) ? 1.0 : 0.72;
        if (!ctx.paused && ctx.worldDt > 0) {
            const dt = ctx.worldDt;
            this.animTime += dt;
            this.underTableFocus += (targetFocus - this.underTableFocus) * Math.min(1, dt * 4.5);

            // 推进铁盆阻尼震动
            if (this.basinShakeTimer > 0) {
                this.basinShakeTimer = Math.max(0, this.basinShakeTimer - dt);
                const elapsed = this.basinShakeMax - this.basinShakeTimer;
                this.basinShakeAngle = Math.sin(elapsed * 38.0) * Math.exp(-elapsed * 3.1) * 0.24;
            } else {
                this.basinShakeAngle = 0;
            }

            // 推进拾荒者鞋尖微顿与步态相位
            if (this.shoeToePauseTimer > 0) {
                this.shoeToePauseTimer = Math.max(0, this.shoeToePauseTimer - dt);
            }
            const scavDx = p.scavX - this.prevScavX;
            if (Math.abs(scavDx) > 0.02) {
                this.scavStridePhase += Math.abs(scavDx) * 0.16;
            } else if (p.scavState === "patrol" || p.scavState === "walk" || p.scavState === "back" || p.scavState === "chase") {
                this.scavStridePhase += dt * (p.scavState === "chase" ? 11.5 : 6.2);
            }
            this.prevScavX = p.scavX;

            // 计算鞋底真实朝向：严格跟随后端 scavState 与 scavTargetX，仅在砖响初段保留 0.14s 鞋尖停顿
            const desiredFacing = this.computeDesiredShoeFacing(p);
            if (this.shoeToePauseTimer <= 0) {
                this.shoeFacing = desiredFacing;
                this.shoeTurnBlend = Math.min(1, this.shoeTurnBlend + dt * 6.0);
            }

            // 消费本帧全部 bottleLanded 事件（按 seq 顺序，绝不遗漏单帧多步）
            let i = 0;
            for (i = 0; i < ctx.events.rawEvents.length; i++) {
                const ev = ctx.events.rawEvents[i];
                if (ev.name === "bottleLanded") {
                    this.onBottleLanded(ctx, ev);
                }
            }

            // 兜底：若拾荒者刚刚由非 turn 态进入 turn 态（例如直接测试回放），按最近落点补对齐反应
            if (p.scavState === "turn" && this.prevScavState !== "turn") {
                if (this.lastSurface === "brick" && this.shoeToePauseTimer <= 0) {
                    this.shoeToePauseTimer = 0.14;
                }
            }
            this.prevScavState = p.scavState;

            // 更新碎屑粒子
            let w = 0;
            for (i = 0; i < this.shards.length; i++) {
                const sp = this.shards[i];
                sp.life -= dt;
                if (sp.life > 0) {
                    sp.vy -= (sp.kind === "soft" ? 180 : 420) * dt;
                    sp.x += sp.vx * dt;
                    sp.y += sp.vy * dt;
                    if (sp.y < 0) {
                        sp.y = 0;
                        sp.vy = -sp.vy * 0.28;
                        sp.vx *= 0.62;
                    }
                    this.shards[w] = sp;
                    w += 1;
                }
            }
            this.shards.length = w;

            // 更新声波扩散环
            w = 0;
            for (i = 0; i < this.rings.length; i++) {
                const rg = this.rings[i];
                rg.age += dt;
                if (rg.age < rg.duration) {
                    this.rings[w] = rg;
                    w += 1;
                }
            }
            this.rings.length = w;

            // 空村寂夜底噪循环
            ctx.audio.playLoop("fe04_village_night", "ambience", CHILD_AUDIO_ROOT + "village_night_loop.wav", 0.24, p.ticks);
        } else if (this.underTableFocus === 0) {
            this.underTableFocus = targetFocus;
        }

        // 桌下低机位锚定（与 screenToWorld 严格互逆，同时保持人物与木桌自然体量比例）
        const focusAnchorX = Math.max(p.ox + 305, Math.min(p.ox + 455, p.ox + 355 + (p.player.x - (p.ox + 320)) * 0.28));
        const zoom = 1.04 + (1 - this.underTableFocus) * 0.04;
        ctx.cam.setAnchorLock({
            footWorldX: focusAnchorX,
            footWorldY: 0,
            footDepth: 0,
            thresholdWorldX: p.ox + 440,
            screenFootFracX: 0.50,
            screenFootFracY: 0.235,
            zoomOverride: zoom,
        });

        this.proj = {
            morph: 1,
            focal: 390,
            vpFracX: 0.54,
            vpFracY: 0.43 - this.underTableFocus * 0.03,
            vpOffsetX: Math.sin(this.animTime * 0.65) * 1.4,
            vpOffsetY: Math.cos(this.animTime * 0.85) * 1.0,
            baseDepth: 0,
        };
    }

    private computeDesiredShoeFacing(p: Play): number {
        if (p.scavState === "chase") {
            return p.player.x >= p.scavX ? 1 : -1;
        }
        if (p.scavState === "turn" || p.scavState === "walk" || p.scavState === "stall") {
            if (Math.abs(p.scavTargetX - p.scavX) > 2) {
                return p.scavTargetX >= p.scavX ? 1 : -1;
            }
        }
        if (p.scavState === "back" && p.room.scavenger !== undefined) {
            const home = Math.max(p.room.scavenger.x0, Math.min(p.room.scavenger.x1, p.scavX));
            if (Math.abs(home - p.scavX) > 2) {
                return home > p.scavX ? 1 : -1;
            }
        }
        return p.scavDir >= 0 ? 1 : -1;
    }

    private onBottleLanded(ctx: FePluginContext, ev: PlayEvent): void {
        const p = ctx.p;
        const x = typeof ev.data.x === "number" ? ev.data.x : p.bottleLandX;
        const y = typeof ev.data.y === "number" ? ev.data.y : Math.max(0, p.bottleLandY);
        const explicitSurface = typeof ev.data.surface === "string" ? ev.data.surface : undefined;
        const surface = this.classifyLandingSurface(p, x, explicitSurface);

        this.lastSurface = surface;
        this.lastLandX = x;

        if (surface === "iron") {
            this.ironHits += 1;
            this.basinShakeTimer = this.basinShakeMax;
            this.shoeToePauseTimer = 0;
            this.shoeTurnBlend = 0.25;
            const bx = this.getBasinWorldX(p);
            // 铁盆三圈缓散金属余振波纹
            this.rings.push({ x: bx, y: 12, age: 0, duration: 1.05, maxRadius: 84, kind: "iron" });
            this.rings.push({ x: bx, y: 12, age: -0.14, duration: 1.20, maxRadius: 112, kind: "iron" });
            this.rings.push({ x: bx, y: 12, age: -0.28, duration: 1.32, maxRadius: 136, kind: "iron" });
            this.spawnShards(bx, 12, "iron", 7);

            // 叠加铁盆第二声金属余振（与 audio.ts 主撞击音 bottle_iron.wav 形成双响层次）
            const key = "fe04:village:iron_ring:" + ctx.events.roomSessionId + ":" + ev.tick + ":" + ev.seq;
            ctx.audio.playOnce(
                key,
                "sfx",
                CHILD_AUDIO_ROOT + "bottle_iron_ring.wav",
                0.82,
                "fe04:bottle:iron_ring",
                ev.tick,
                ev.seq,
            );
        } else if (surface === "brick") {
            this.brickHits += 1;
            // 砸硬砖：拾荒者鞋尖先微顿约 0.14s，再果断转向调查方向
            this.shoeToePauseTimer = 0.14;
            this.rings.push({ x, y: Math.max(2, y), age: 0, duration: 0.44, maxRadius: 58, kind: "brick" });
            this.spawnShards(x, Math.max(2, y), "brick", 9);
        } else {
            this.softHits += 1;
            this.rings.push({ x, y: Math.max(2, y), age: 0, duration: 0.36, maxRadius: 24, kind: "soft" });
            this.spawnShards(x, Math.max(2, y), "soft", 6);
            // M2 起 audio.ts 已按落点坐标原生分轨播放 bottle_soft.wav（cueId="bottle:soft"），
            // 此处仅在无 audio.ts 分轨（如排演直接注入且未经过 ingestEvents）时兜底，避免重复播两声软土音
            const audioKey = "r" + ctx.events.roomSessionId + ":cp" + ctx.events.checkpoint + ":t" + ev.tick + ":s" + ev.seq + ":bottleLanded";
            if (!ctx.audio.hasPlayed(audioKey)) {
                const key = "fe04:village:soft_thud:" + ctx.events.roomSessionId + ":" + ev.tick + ":" + ev.seq;
                ctx.audio.playOnce(
                    key,
                    "sfx",
                    CHILD_AUDIO_ROOT + "bottle_soft.wav",
                    0.76,
                    "fe04:bottle:soft_thud",
                    ev.tick,
                    ev.seq,
                );
            }
        }
    }

    private spawnShards(x: number, y: number, kind: VillageSurfaceKind, count: number): void {
        let i = 0;
        for (i = 0; i < count; i++) {
            const ang = (0.18 + this.rand() * 0.64) * Math.PI;
            const spd = (kind === "soft" ? 28 : 65) + this.rand() * (kind === "soft" ? 36 : 95);
            this.shards.push({
                x: x + (this.rand() - 0.5) * 10,
                y: y + 2,
                vx: Math.cos(ang) * spd * (this.rand() > 0.5 ? 1 : -1),
                vy: Math.sin(ang) * spd,
                size: kind === "soft" ? (2.2 + this.rand() * 2.4) : (1.8 + this.rand() * 2.2),
                life: (kind === "soft" ? 0.34 : 0.48) + this.rand() * 0.22,
                maxLife: 0.65,
                kind,
            });
        }
    }

    /** 供自动化与排演主动模拟某处落点效果（不修改 Play 内部） */
    triggerRehearsalImpact(ctx: FePluginContext, surface: VillageSurfaceKind): void {
        const p = ctx.p;
        const x = surface === "iron"
            ? this.getBasinWorldX(p)
            : (surface === "soft" ? this.getSoftWorldX(p) : this.getBrickWorldX(p));
        this.onBottleLanded(ctx, {
            seq: 9000 + this.brickHits + this.ironHits + this.softHits,
            tick: p.ticks,
            name: "bottleLanded",
            data: { x, y: 0, surface, heard: true },
        });
    }

    drawBackdrop(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        backdropArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const w = cam.viewW;
        const h = cam.viewH;
        const ox = p.ox;

        // 1. 深夜冷村像素远景（统一冷月调色，零低模几何方块）
        fillVGradRect(bgDraw, 0, 0, w, h, Color(20, 26, 38, 255), Color(7, 9, 15, 255));
        const span = Math.max(1, p.room.maxX - p.room.minX);
        const progress = (cam.x - p.room.minX) / span - 0.5;
        const artW = Math.max(w, (h * 16) / 9) * 1.24;
        const artH = (artW * 9) / 16;
        const artY = Math.min(0, Math.max(h - artH, cam.groundScreenY - artH * 0.24));
        backdropArt.tryPlace("bgFar_village", "fe04_bg_village", w * (0.5 - progress * 0.08), artY, artW, artH, {
            color: Color(148, 168, 200, 255),
            layer: 0,
        });
        fillVGradRect(bgGlow, 0, cam.groundScreenY - 2, w, h * 0.16, Color(24, 34, 52, 24), Color(12, 18, 28, 0));

        // 远景北塔极淡一豆灯火（指明去向但不抢夺桌下焦点）
        const towerPt = projectWorld3D(ox + 668, 152, 410, cam, this.proj);
        fillRadialGlow(bgGlow, towerPt.x, towerPt.y, 20, 20, Color(238, 198, 132, 54), Color(238, 198, 132, 0), 12);
        bgGlow.drawDot(Vec2(towerPt.x, towerPt.y), 2.0, Color(252, 232, 186, 185));

        return true;
    }

    drawWorld(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const ox = p.ox;
        const groundY = cam.sy(0);
        const deckH = cam.len(26);

        // 1. 地面基底（门内暗木夯土 vs 门外冷月青石院坪）
        const xMin = cam.sx(ox - 40);
        const xSplit = cam.sx(ox + 436);
        const xMax = cam.sx(ox + 760);
        if (groundY - deckH > 0) {
            fillVGradRect(fgDraw, xMin, 0, xMax - xMin, groundY - deckH + 1, Color(8, 10, 16, 255), Color(18, 22, 32, 255));
        }
        const tileSpan = Math.max(24, cam.len(74));
        let j = 0;
        for (j = 0; xMin + j * tileSpan < xSplit; j++) {
            const tx = xMin + j * tileSpan;
            const tw = Math.min(tileSpan, xSplit - tx);
            worldArt.tryPlace("fe_beam_wood", "fe04_vil_fl_in_" + j, tx + tw * 0.5, groundY - deckH, tw + 0.5, deckH, {
                color: Color(98, 86, 78, 255),
                layer: 1,
            });
        }
        for (j = 0; xSplit + j * tileSpan < xMax; j++) {
            const tx = xSplit + j * tileSpan;
            const tw = Math.min(tileSpan, xMax - tx);
            worldArt.tryPlace("fe_road_stone", "fe04_vil_fl_out_" + j, tx + tw * 0.5, groundY - deckH, tw + 0.5, deckH, {
                color: Color(162, 180, 206, 255),
                layer: 1,
            });
        }
        fgDraw.drawSegment(Vec2(xMin, groundY), Vec2(xMax, groundY), 1.1, Color(138, 158, 184, 115));

        // 2. 院门立柱与横梁（克制暗木色融入村舍院景）
        worldArt.tryPlace("fe_pillar_wood", "fe04_vil_door_l", cam.sx(ox + 422), groundY, cam.len(12), cam.len(126), {
            color: Color(116, 108, 104, 255),
            opacity: 0.78,
            layer: 2,
        });
        worldArt.tryPlace("fe_pillar_wood", "fe04_vil_door_r", cam.sx(ox + 458), groundY, cam.len(12), cam.len(126), {
            color: Color(128, 122, 120, 255),
            opacity: 0.78,
            layer: 2,
        });
        worldArt.tryPlace("fe_beam_wood", "fe04_vil_door_top", cam.sx(ox + 440), cam.sy(120), cam.len(56), cam.len(14), {
            color: Color(120, 112, 108, 255),
            opacity: 0.78,
            layer: 2,
        });

        // 3. 镂空木瓶架（x=96..128, h=52）与院墙（x=672..720, h=96）
        worldArt.tryPlace("fe_bottle_rack", "fe04_vil_rack", cam.sx(ox + 112), groundY, cam.len(38), cam.len(54), {
            color: Color(186, 194, 208, 255),
            layer: 3,
        });
        const wallX0 = cam.sx(ox + 672);
        const wallX1 = cam.sx(ox + 720);
        const wallW = wallX1 - wallX0;
        const wallH = cam.len(96);
        worldArt.tryPlace("wall", "fe04_vil_wall_lo", (wallX0 + wallX1) * 0.5, groundY, wallW, wallH * 0.52, {
            color: Color(156, 174, 198, 255),
            layer: 2,
        });
        worldArt.tryPlace("wall", "fe04_vil_wall_hi", (wallX0 + wallX1) * 0.5, groundY + wallH * 0.50, wallW, wallH * 0.52, {
            color: Color(164, 182, 206, 255),
            facing: -1,
            layer: 2,
        });
        worldArt.tryPlace("eaves", "fe04_vil_wall_eave", (wallX0 + wallX1) * 0.5, groundY + wallH - cam.len(2), wallW + cam.len(16), cam.len(18), {
            color: Color(158, 174, 198, 255),
            layer: 3,
        });

        // 4. 明式木桌后景主体（压暗作为桌下景深后层，前桌腿与前景桌沿在 drawForegroundOverlay 呈现）
        const arch = p.room.arch;
        worldArt.tryPlace("prop_table", "fe04_vil_table_back", cam.sx((arch.x0 + arch.x1) * 0.5), groundY, cam.len(arch.x1 - arch.x0 + 18), cam.len(arch.h + 12), {
            color: Color(108, 94, 84, 255),
            opacity: 0.92,
            layer: 2,
        });

        // 5. 暗渠入口、软土、硬砖与敲打铁盆（像素专属道具精灵）
        const culvertX = this.getCulvertWorldX(p);
        const softX = this.getSoftWorldX(p);
        const brickX = this.getBrickWorldX(p);
        const basinX = this.getBasinWorldX(p);

        worldArt.tryPlace("fe_culvert_grate", "fe04_vil_culvert", cam.sx(culvertX), groundY - cam.len(2), cam.len(42), cam.len(34), {
            color: Color(188, 204, 224, 255),
            layer: 3,
        });
        worldArt.tryPlace("fe_ground_soft", "fe04_vil_soft", cam.sx(softX), groundY - cam.len(4), cam.len(54), cam.len(16), {
            color: Color(154, 146, 138, 255),
            layer: 2,
        });
        worldArt.tryPlace("fe_ground_brick", "fe04_vil_brick", cam.sx(brickX), groundY - cam.len(4), cam.len(56), cam.len(16), {
            color: Color(216, 226, 240, 255),
            layer: 2,
        });

        const shaking = this.basinShakeTimer > 0;
        const shakeAngDeg = shaking ? (this.basinShakeAngle * 22) : 0;
        const shiftX = shaking ? Math.sin(this.basinShakeAngle * 2.2) * cam.len(2.4) : 0;
        worldArt.tryPlace(shaking ? "fe_basin_tilt" : "fe_basin_flat", "fe04_vil_basin", cam.sx(basinX) + shiftX, groundY, cam.len(38), cam.len(22), {
            angle: shakeAngDeg,
            color: Color(204, 218, 236, 255),
            layer: 4,
        });

        // 6. 院门月光漫射擦亮铁盆与硬砖
        fillRadialGlow(fgGlow, cam.sx(ox + 566), cam.sy(48), cam.len(128), cam.len(96), Color(188, 210, 232, 34), Color(150, 178, 208, 0), 16);

        // 7. 2D 角色脚底接触影
        fgDraw.drawEllipse(Vec2(cam.sx(p.player.x), cam.sy(p.player.y) + 1), cam.len(14), 3.4, Color(8, 10, 16, 155));
        if (p.room.scavenger !== undefined) {
            fgDraw.drawEllipse(Vec2(cam.sx(p.scavX), cam.sy(p.room.scavenger.y) + 1), cam.len(18), 4.0, Color(8, 10, 16, 165));
        }

        // 8. 强化地表灰度微细节、暗渠水光、铁盆高光闪与双材质扩散声波环
        this.drawSurfaceReadabilityDetails(fgDraw, fgGlow, p, cam, softX, culvertX, basinX, brickX);

        return true;
    }

    private drawSurfaceReadabilityDetails(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        _softX: number,
        culvertX: number,
        basinX: number,
        brickX: number,
    ): void {
        const y0 = cam.sy(0);

        // 1. 暗渠入口冷月水光微动
        const cL = cam.sx(culvertX - 11);
        const cR = cam.sx(culvertX + 11);
        const rippleShift = Math.sin(this.animTime * 2.3) * 3;
        fgGlow.drawSegment(Vec2(cL + 3 + rippleShift, y0 + 2), Vec2(cR - 4 + rippleShift, y0 + 2), 1.1, Color(164, 192, 214, 105));

        // 2. 铁盆受击颤动侧光高光闪（保留受击反馈可读性）
        const shakeBoost = this.basinShakeTimer > 0 ? clamp01(this.basinShakeTimer / this.basinShakeMax) : 0;
        const bx = cam.sx(basinX);
        const by = cam.sy(14);
        fillRadialGlow(
            fgGlow,
            bx,
            by,
            cam.len(22 + shakeBoost * 18),
            cam.len(10 + shakeBoost * 8),
            Color(216, 226, 236, Math.round(44 + 98 * shakeBoost)),
            Color(186, 202, 220, 0),
            14,
        );

        // 3. 硬砖顶沿月光反光细线
        fgDraw.drawSegment(Vec2(cam.sx(brickX - 24), cam.sy(3.2)), Vec2(cam.sx(brickX + 24), cam.sy(3.2)), 1.4, Color(224, 230, 238, 185));

        // 4. 瓶子落地后的碎屑与双材质扩散声波环
        let i = 0;
        for (i = 0; i < this.rings.length; i++) {
            const rg = this.rings[i];
            if (rg.age < 0) {
                continue;
            }
            const t = clamp01(rg.age / rg.duration);
            const r = Math.max(4, cam.len(rg.maxRadius) * (0.14 + 0.86 * t));
            const alpha = (1 - t) * (rg.kind === "iron" ? 0.88 : (rg.kind === "brick" ? 0.82 : 0.40));
            const rx = cam.sx(rg.x);
            const ry = cam.sy(rg.y);
            const ringCol = rg.kind === "iron"
                ? Color(220, 234, 246, Math.round(235 * alpha))
                : (rg.kind === "brick"
                    ? Color(236, 216, 178, Math.round(225 * alpha))
                    : Color(148, 134, 114, Math.round(165 * alpha)));
            drawEllipseRing(fgGlow, rx, ry, r, r * 0.34, rg.kind === "iron" ? 1.8 : 1.4, ringCol, 22);
            if (rg.kind === "iron") {
                drawEllipseRing(fgDraw, rx, ry, r * 0.96, r * 0.32, 1.1, Color(214, 224, 236, Math.round(150 * alpha)), 22);
            }
        }
        for (i = 0; i < this.shards.length; i++) {
            const sp = this.shards[i];
            const a = clamp01(sp.life / sp.maxLife);
            const col = sp.kind === "soft"
                ? Color(138, 120, 98, Math.round(170 * a))
                : (sp.kind === "iron"
                    ? Color(224, 232, 242, Math.round(225 * a))
                    : Color(216, 198, 174, Math.round(220 * a)));
            fgDraw.drawDot(Vec2(cam.sx(sp.x), cam.sy(sp.y)), sp.size, col);
        }

        if (p.bottleLandT > 0 && p.bottleLandX >= 0 && this.rings.length === 0) {
            const rx = cam.sx(p.bottleLandX);
            const ry = cam.sy(Math.max(1, p.bottleLandY));
            fgDraw.drawDot(Vec2(rx, ry), 2.5, Color(216, 206, 186, 150));
        }
    }

    /** 接管空村道具层：瓶架上陶瓶、手持/飞行陶瓶与无赛博污染的精准抛物线预览 */
    drawPropsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;

        // 1. 瓶架上未拾取陶瓶（稳稳立在 h=52 瓶架顶板上）
        const bottle = p.room.bottle;
        if (bottle !== undefined && !p.hasBottle && p.bottleFly === undefined && p.bottleLandT <= 0) {
            this.drawCeramicBottle(fgDraw, fgGlow, worldArt, "fe04_bottle_shelf", cam.sx(bottle.x), cam.sy(56), cam.ppu, 0, true);
        }

        // 2. 手上持瓶与飞行中陶瓶（瞄准时 child_aim 精灵手里已有瓶子，不重复叠画第二只）
        if (p.hasBottle && p.aimHold <= 0) {
            const pl = p.player;
            this.drawCeramicBottle(
                fgDraw,
                fgGlow,
                worldArt,
                "fe04_bottle_held",
                cam.sx(pl.x + pl.facing * 10),
                cam.sy(pl.y + pl.h * 0.52),
                cam.ppu,
                pl.facing * 0.22,
                false,
            );
        }
        if (p.bottleFly !== undefined) {
            this.drawCeramicBottle(
                fgDraw,
                fgGlow,
                worldArt,
                "fe04_bottle_air",
                cam.sx(p.bottleFly.x),
                cam.sy(p.bottleFly.y),
                cam.ppu,
                this.animTime * 13.5,
                false,
            );
        }

        // 3. 持瓶抛物线预览（严格对齐后端 bottleAimX/Y 与 T=0.62，区分硬砖 / 铁盆 / 软土落点）
        if (p.hasBottle && p.aimHold > 0) {
            const pl = p.player;
            let endX = p.bottleAimX;
            let endY = p.bottleAimY;
            if (endX < 0) {
                const wAim = cam.screenToWorld(p.aimX, p.aimY);
                endX = wAim.x;
                endY = 0;
            }
            const dir = endX >= pl.x ? 1 : -1;
            const x0 = pl.x + dir * 10;
            const y0 = pl.y + pl.h * 0.7;
            const vx = (endX - x0) / BOTTLE_FLY_T;
            const vy = (endY - y0 + 0.5 * GRAVITY * BOTTLE_FLY_T * BOTTLE_FLY_T) / BOTTLE_FLY_T;

            const previewSurface = this.classifyLandingSurface(p, endX);
            const arcRgb: RGBA = previewSurface === "iron"
                ? rgba(214, 228, 242, 255)
                : (previewSurface === "brick"
                    ? rgba(232, 206, 152, 255)
                    : rgba(154, 142, 126, 255));

            const steps = 18;
            let k = 1;
            for (k = 1; k <= steps; k++) {
                const tt = (k / steps) * BOTTLE_FLY_T;
                const wx = x0 + vx * tt;
                const wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt;
                const alpha = 195 * (0.40 + 0.60 * (k / steps));
                fgDraw.drawDot(Vec2(cam.sx(wx), cam.sy(wy)), 2.5, toColor(arcRgb, alpha));
                fgGlow.drawDot(Vec2(cam.sx(wx), cam.sy(wy)), 3.2, toColor(arcRgb, alpha * 0.55));
            }

            const lx = cam.sx(endX);
            const ly = cam.sy(endY + 2);
            const pulse = 0.88 + 0.12 * Math.sin(this.animTime * 5.2);
            drawEllipseRing(fgDraw, lx, ly, 11 * pulse, 4.2 * pulse, 1.6, toColor(arcRgb, 235), 20);
            if (previewSurface === "iron") {
                drawEllipseRing(fgGlow, lx, ly, 24 * pulse, 9.2 * pulse, 1.3, toColor(arcRgb, 195), 22);
            } else if (previewSurface === "brick") {
                drawEllipseRing(fgGlow, lx, ly, 18 * pulse, 7.0 * pulse, 1.2, toColor(arcRgb, 165), 20);
            }
        }

        return true;
    }

    private drawCeramicBottle(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        id: string,
        cx: number,
        cy: number,
        ppu: number,
        tilt: number,
        shelfGlint: boolean,
    ): void {
        const size = Math.max(10, ppu * 10.5);
        if (!worldArt.tryPlace("prop_bottle", id, cx, cy, size, size, {
            angle: (tilt * 180) / Math.PI,
            layer: 8,
        })) {
            fgDraw.drawCircle(Vec2(cx, cy), size * 0.36, Color(172, 138, 102, 245));
        }
        if (shelfGlint) {
            const p = 0.72 + 0.28 * Math.sin(this.animTime * 3.0);
            fillRadialGlow(fgGlow, cx, cy + 2, 14 * p, 14 * p, Color(224, 214, 190, Math.round(62 * p)), Color(224, 214, 190, 0), 12);
        }
    }

    /** 在角色之上强化拾荒者整双鞋底可读性（暗处与灰度下一目了然朝向与步态） */
    drawActorsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        const p = ctx.p;
        const cam = ctx.cam;
        if (p.room.scavenger !== undefined) {
            this.drawScavengerShoeOverlay(fgDraw, fgGlow, p, cam);
        }

        // 暂停态下 uiDraw 不运行，使用像素前景桌沿/桌腿贴合兜底
        if (ctx.paused) {
            const arch = p.room.arch;
            const tableTopY = cam.sy(arch.h + 10);
            const tableX = cam.sx((arch.x0 + arch.x1) * 0.5);
            const tableW = cam.len(arch.x1 - arch.x0 + 24);
            worldArt.tryPlace("fe_fg_table_top", "fe04_pause_table_top", tableX, tableTopY, tableW, cam.len(16), {
                opacity: 0.96,
                layer: 5300,
            });
            worldArt.tryPlace("fe_fg_table_leg", "fe04_pause_table_leg", cam.sx(arch.x1 - 2), cam.sy(arch.h), cam.len(12), cam.len(arch.h), {
                opacity: 0.96,
                layer: 5310,
            });
        }
    }

    private drawScavengerShoeOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
    ): void {
        const cx = cam.sx(p.scavX);
        const by = cam.sy(p.room.scavenger !== undefined ? p.room.scavenger.y : 0);
        const f = this.shoeFacing >= 0 ? 1 : -1;
        const pausedToe = this.shoeToePauseTimer > 0;

        // 柔和地面冷月擦亮底带，自然托出像素拾荒者双足朝向，不叠贴多边形草鞋补丁
        fillRadialGlow(fgGlow, cx + f * cam.len(5), by + 2, cam.len(34), cam.len(9), Color(196, 208, 224, 56), Color(156, 172, 190, 0), 14);
        fgDraw.drawEllipse(Vec2(cx + f * cam.len(3), by + 1), cam.len(18), cam.len(3.2), Color(118, 130, 144, 62));

        // 砸硬砖鞋尖微顿时的瞬间警觉微光
        if (pausedToe) {
            fgGlow.drawDot(Vec2(cx + f * cam.len(9), by + 2), 3.4, Color(236, 218, 178, 175));
        }
    }

    /**
     * 像素前景木桌遮挡层（桌沿 + 左右前桌腿 + 桌上冷碗 + 蹲伏顶部木梁压迫暗影 + 冷月电影调色）：
     * 固定返回 false，绝不压隐 HUD、字幕或投瓶准星。
     */
    drawForegroundOverlay(
        uiDraw: DrawNode.Type,
        _uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const inv = 1 / Math.max(0.25, ctx.uiScale);
        const arch = p.room.arch;

        const tableCx = cam.sx((arch.x0 + arch.x1) * 0.5) * inv;
        const tableW = cam.len(arch.x1 - arch.x0 + 26) * inv;
        const tableTopUiY = cam.sy(arch.h + 10) * inv;
        const tableBotUiY = cam.sy(arch.h) * inv;
        const legH = Math.max(12, tableBotUiY - cam.sy(0) * inv);
        const legW = Math.max(8, cam.len(11) * inv);

        // 1. 像素前景左右桌腿与厚重明式桌沿（anchorY = 1.0，顶部对齐）
        uiArt.tryPlace("fe_fg_table_leg", "fe04_fg_leg_l", cam.sx(arch.x0 + 2) * inv, tableBotUiY, legW, legH, {
            opacity: 0.96,
            layer: 2,
        });
        uiArt.tryPlace("fe_fg_table_leg", "fe04_fg_leg_r", cam.sx(arch.x1 - 2) * inv, tableBotUiY, legW, legH, {
            opacity: 0.96,
            layer: 2,
        });
        uiArt.tryPlace("fe_fg_table_top", "fe04_fg_top", tableCx, tableTopUiY, tableW, Math.max(10, cam.len(14) * inv), {
            opacity: 0.98,
            layer: 3,
        });

        // 2. 蹲伏在桌下时顶部克制木梁剪影压顶（1.35x 视差），强化桌下屏息感
        if (p.player.crouch && p.player.x >= arch.x0 - 16 && p.player.x <= arch.x1 + 16) {
            const beamOffset = (cam.x - p.ox - 360) * 0.35 * inv;
            uiArt.tryPlace("fe_fg_table_top", "fe04_fg_crouch_beam", ctx.uiW * 0.5 - beamOffset * 0.25, ctx.uiH + 4, ctx.uiW * 1.12, ctx.uiH * 0.11, {
                color: Color(24, 22, 26, 255),
                opacity: 0.72,
                layer: 4,
            });
        }

        // 3. 冷月像素电影调色暗角
        drawChildColdMoonGrade(uiDraw, uiGlow, ctx.uiW, ctx.uiH, 0.84, 0);

        return false;
    }
}
