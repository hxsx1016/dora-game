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

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { Play, PlayEvent } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { FePluginContext } from "Script/watch/fe/plugins";
import {
    DIORAMA_TEX_CLIP,
    LP_BUCKET,
    LowpolyMaterial,
    LowpolyProjection,
    LowpolyScene,
    MING_MATERIALS,
    VILLAGE_UNDERTABLE_LIGHT,
    clamp01,
    projectWorld3D,
    smoothstep,
    vec3,
} from "Script/watch/fe/renderer/lowpoly";
import {
    PALETTE,
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

const MAT_CLAY_STOVE: LowpolyMaterial = {
    base: rgba(74, 68, 62, 255),
    edge: rgba(128, 120, 110, 110),
    minShade: 0.26,
    rimBoost: 0.16,
    bottomAo: 0.34,
    texture: DIORAMA_TEX_CLIP + "ming_plaster",
    textureTint: rgba(168, 160, 148, 255),
    subdivX: 2,
    subdivY: 2,
};

const MAT_SOFT_EARTH: LowpolyMaterial = {
    base: rgba(66, 54, 43, 255),
    edge: rgba(96, 80, 64, 85),
    minShade: 0.32,
    rimBoost: 0.08,
    bottomAo: 0.24,
    texture: DIORAMA_TEX_CLIP + "ming_plaster",
    textureTint: rgba(132, 112, 92, 255),
    subdivX: 2,
    subdivY: 2,
};

const MAT_HARD_BRICK: LowpolyMaterial = {
    base: rgba(126, 132, 142, 255),
    edge: rgba(220, 226, 234, 165),
    minShade: 0.36,
    rimBoost: 0.30,
    bottomAo: 0.22,
    texture: DIORAMA_TEX_CLIP + "ming_brick",
    textureTint: rgba(228, 234, 242, 255),
    subdivX: 2,
    subdivY: 2,
};

const MAT_IRON_BASIN: LowpolyMaterial = {
    base: rgba(58, 66, 78, 255),
    edge: rgba(214, 224, 238, 185),
    minShade: 0.28,
    rimBoost: 0.38,
    bottomAo: 0.26,
    texture: DIORAMA_TEX_CLIP + "ming_iron",
    textureTint: rgba(188, 198, 212, 255),
    subdivX: 2,
    subdivY: 2,
};

const MAT_TABLE_WOOD: LowpolyMaterial = {
    base: rgba(78, 56, 40, 255),
    edge: rgba(142, 110, 82, 120),
    minShade: 0.24,
    rimBoost: 0.18,
    bottomAo: 0.38,
    texture: DIORAMA_TEX_CLIP + "ming_timber",
    textureTint: rgba(164, 140, 120, 255),
    subdivX: 3,
    subdivY: 2,
};

const MAT_CULVERT_STONE: LowpolyMaterial = {
    base: rgba(76, 84, 96, 255),
    edge: rgba(178, 194, 210, 155),
    minShade: 0.30,
    rimBoost: 0.28,
    bottomAo: 0.30,
    texture: DIORAMA_TEX_CLIP + "ming_stone",
    textureTint: rgba(188, 198, 212, 255),
    subdivX: 2,
    subdivY: 2,
};

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

function drawUiQuad(
    uiDraw: DrawNode.Type,
    p0: { x: number; y: number },
    p1: { x: number; y: number },
    p2: { x: number; y: number },
    p3: { x: number; y: number },
    cBot: Color.Type,
    cTop: Color.Type,
    invScale: number,
    edgeCol?: Color.Type,
    edgeW: number = 0,
): void {
    const v0 = Vec2(p0.x * invScale, p0.y * invScale);
    const v1 = Vec2(p1.x * invScale, p1.y * invScale);
    const v2 = Vec2(p2.x * invScale, p2.y * invScale);
    const v3 = Vec2(p3.x * invScale, p3.y * invScale);
    uiDraw.drawVertices([
        [v0, cBot],
        [v1, cBot],
        [v2, cTop],
    ]);
    uiDraw.drawVertices([
        [v0, cBot],
        [v2, cTop],
        [v3, cTop],
    ]);
    if (edgeCol !== undefined && edgeW > 0) {
        const half = edgeW * 0.5;
        uiDraw.drawSegment(v0, v1, half, edgeCol);
        uiDraw.drawSegment(v1, v2, half, edgeCol);
        uiDraw.drawSegment(v2, v3, half, edgeCol);
        uiDraw.drawSegment(v3, v0, half, edgeCol);
    }
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
        _backdropArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const w = cam.viewW;
        const h = cam.viewH;

        // 1. 深夜冷村天穹（压低亮度，把高反差留给桌下侧光、鞋底与两种落点）
        const splitY = h * 0.50;
        fillVGradRect(bgDraw, 0, splitY, w, h - splitY, Color(14, 18, 26, 255), Color(7, 9, 15, 255));
        fillVGradRect(bgDraw, 0, 0, w, splitY, Color(24, 28, 38, 255), Color(14, 18, 26, 255));

        const scene = new LowpolyScene(cam, this.proj, VILLAGE_UNDERTABLE_LIGHT);
        const ox = p.ox;

        // 2. 远景村落青瓦屋脊与远山雾幕
        scene.addDistantRidge(
            [
                { x: ox - 140, y: 120 },
                { x: ox + 120, y: 162 },
                { x: ox + 360, y: 138 },
                { x: ox + 590, y: 176 },
                { x: ox + 860, y: 132 },
            ],
            -20,
            420,
            MING_MATERIALS.distantHill,
            { bucket: LP_BUCKET.BACKDROP },
        );

        // 远景民居残垣飞檐与远山北塔实景立牌（替换纯三角几何屋顶）
        scene.addCutout3D(
            "assets/art/diorama_cutouts.clip|ming_eave_ruin",
            ox + 575,
            18,
            218,
            238,
            156,
            {
                bucket: LP_BUCKET.BACKDROP,
                anchorX: 0.5,
                anchorY: 0,
                color: rgba(112, 126, 144, 255),
                opacity: 0.90,
                sortBias: 0.04,
            },
        );
        scene.addCutout3D(
            "assets/art/diorama_cutouts.clip|north_tower_distant",
            ox + 668,
            46,
            405,
            108,
            138,
            {
                bucket: LP_BUCKET.BACKDROP,
                anchorX: 0.5,
                anchorY: 0,
                color: rgba(132, 146, 168, 255),
                opacity: 0.88,
                sortBias: 0.06,
            },
        );

        // 远景冷灶室内后壁（左半室，x = 0..438，z = 110..150，构成门内与院外强明暗分界）
        scene.addBox({
            x0: ox - 60,
            x1: ox + 436,
            y0: 0,
            y1: 196,
            z0: 112,
            z1: 152,
            material: MING_MATERIALS.mingBrickDark,
            bucket: LP_BUCKET.BACKDROP,
            edgeWidth: 0.6,
        });

        // 门内土灶与烟道（低模明代村舍灶台剪影，无现代杂物）
        scene.addBox({
            x0: ox + 150,
            x1: ox + 258,
            y0: 0,
            y1: 42,
            z0: 76,
            z1: 112,
            material: MAT_CLAY_STOVE,
            bucket: LP_BUCKET.MIDGROUND,
            highlightTopEdge: true,
        });
        scene.addBox({
            x0: ox + 178,
            x1: ox + 228,
            y0: 42,
            y1: 156,
            z0: 94,
            z1: 114,
            material: MAT_CLAY_STOVE,
            bucket: LP_BUCKET.MIDGROUND,
            edgeWidth: 0.5,
        });

        // 院内远景石井栏（V2 晒谷院叙事细部，z = 128..166）
        scene.addBox({
            x0: ox + 486,
            x1: ox + 536,
            y0: 0,
            y1: 34,
            z0: 126,
            z1: 162,
            material: MING_MATERIALS.mingStoneStep,
            bucket: LP_BUCKET.MIDGROUND,
            highlightTopEdge: true,
        });

        // 院落夜雾与远方北塔一豆极微暖灯（指明去向但不抢夺桌下焦点）
        scene.addFogBand(ox - 120, ox + 840, -10, 140, 260, rgba(24, 30, 42, 255), 0.62, 0.05, {
            bucket: LP_BUCKET.BACKDROP,
        });

        scene.flush(bgDraw, bgGlow, ctx.dioramaBg);

        // 右上冷月微光（侧光光源方向依据）
        const mx = w * 0.80;
        const my = h * 0.84;
        fillRadialGlow(bgGlow, mx, my, 96, 96, Color(188, 206, 224, 24), Color(24, 32, 46, 0), 16);
        bgDraw.drawCircle(Vec2(mx, my), 14, Color(214, 224, 236, 130));

        // 远景北塔极淡一豆灯火
        const towerPt = projectWorld3D(ox + 668, 152, 410, cam, this.proj);
        fillRadialGlow(bgGlow, towerPt.x, towerPt.y, 20, 20, Color(238, 198, 132, 54), Color(238, 198, 132, 0), 12);
        bgGlow.drawDot(Vec2(towerPt.x, towerPt.y), 2.0, Color(252, 232, 186, 185));

        return true;
    }

    drawWorld(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        _worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const ox = p.ox;
        const scene = new LowpolyScene(cam, this.proj, VILLAGE_UNDERTABLE_LIGHT);

        // 1. 地面基底（门内冷灶夯土 vs 门外露天青石院坪）
        scene.addBox({
            x0: ox - 40,
            x1: ox + 436,
            y0: -52,
            y1: 0,
            z0: -32,
            z1: 112,
            material: MING_MATERIALS.mingTimberDark,
            bucket: LP_BUCKET.MIDGROUND,
            highlightTopEdge: true,
            edgeWidth: 0.7,
        });
        scene.addBox({
            x0: ox + 436,
            x1: ox + 760,
            y0: -52,
            y1: 0,
            z0: -32,
            z1: 126,
            material: MING_MATERIALS.mingBrickDark,
            bucket: LP_BUCKET.MIDGROUND,
            highlightTopEdge: true,
            edgeWidth: 0.8,
        });

        // 2. 院门门框（位于 x = 428..452 附近，把灶屋暗影与月光院坪劈出强烈明暗交界）
        scene.addBeveledFrame(ox + 416, ox + 462, 0, 128, 16, 22, 16, 112, MING_MATERIALS.mingTimberDark, {
            bucket: LP_BUCKET.MIDGROUND,
            innerRimLight: rgba(206, 214, 222, 255),
            innerRimStrength: 0.42,
        });

        // 3. 瓶架（rooms.ts solid: x=96..128, h=52，镂空木架结构）与院墙（x=672..720, h=96）
        scene.addBox({
            x0: ox + 96,
            x1: ox + 101,
            y0: 0,
            y1: 52,
            z0: -6,
            z1: 24,
            material: MAT_TABLE_WOOD,
            bucket: LP_BUCKET.WALK_DECK,
            edgeWidth: 0.8,
        });
        scene.addBox({
            x0: ox + 123,
            x1: ox + 128,
            y0: 0,
            y1: 52,
            z0: -6,
            z1: 24,
            material: MAT_TABLE_WOOD,
            bucket: LP_BUCKET.WALK_DECK,
            edgeWidth: 0.8,
        });
        scene.addBox({
            x0: ox + 95,
            x1: ox + 129,
            y0: 24,
            y1: 28,
            z0: -8,
            z1: 26,
            material: MING_MATERIALS.mingTimber,
            bucket: LP_BUCKET.WALK_DECK,
            sortBias: 0.05,
        });
        scene.addBox({
            x0: ox + 94,
            x1: ox + 130,
            y0: 48,
            y1: 52,
            z0: -8,
            z1: 26,
            material: MING_MATERIALS.mingTimber,
            bucket: LP_BUCKET.WALK_DECK,
            highlightTopEdge: true,
            sortBias: 0.06,
        });
        // 院墙（x = 672..720, h = 96）+ 青瓦墙帽
        scene.addBox({
            x0: ox + 672,
            x1: ox + 720,
            y0: 0,
            y1: 96,
            z0: -14,
            z1: 96,
            material: MING_MATERIALS.mingBrick,
            bucket: LP_BUCKET.MIDGROUND,
            highlightTopEdge: true,
            edgeWidth: 0.9,
        });
        scene.addBox({
            x0: ox + 666,
            x1: ox + 726,
            y0: 96,
            y1: 106,
            z0: -18,
            z1: 100,
            material: MING_MATERIALS.mingTile,
            bucket: LP_BUCKET.MIDGROUND,
            sortBias: 0.08,
        });

        // 4. 唯一明式木桌后半部（严格贴合 arch = 304..416, y = 0..44；后桌腿与后档横枨在 z > 0，
        //    前半部桌面、前桌腿与粗瓷碗在 drawForegroundOverlay 中绘制，杜绝双桌叠加）
        const arch = p.room.arch;
        // 左后桌腿与右后桌腿
        scene.addBox({
            x0: arch.x0 - 1,
            x1: arch.x0 + 7,
            y0: 0,
            y1: arch.h,
            z0: 12,
            z1: 22,
            material: MAT_TABLE_WOOD,
            bucket: LP_BUCKET.MIDGROUND,
            edgeWidth: 0.8,
        });
        scene.addBox({
            x0: arch.x1 - 7,
            x1: arch.x1 + 1,
            y0: 0,
            y1: arch.h,
            z0: 12,
            z1: 22,
            material: MAT_TABLE_WOOD,
            bucket: LP_BUCKET.MIDGROUND,
            edgeWidth: 0.8,
        });
        // 后侧横枨（贴桌底 y = 39..44，强化真实木桌结构）
        scene.addBox({
            x0: arch.x0 + 7,
            x1: arch.x1 - 7,
            y0: arch.h - 5,
            y1: arch.h,
            z0: 14,
            z1: 20,
            material: MAT_TABLE_WOOD,
            bucket: LP_BUCKET.MIDGROUND,
            edgeWidth: 0.6,
        });
        // 桌面后半部（y = 44..52，与前景桌沿无缝拼接为同一张木桌）
        scene.addBox({
            x0: arch.x0 - 8,
            x1: arch.x1 + 8,
            y0: arch.h,
            y1: arch.h + 8,
            z0: 4,
            z1: 28,
            material: MAT_TABLE_WOOD,
            bucket: LP_BUCKET.WALK_DECK,
            highlightTopEdge: true,
            edgeWidth: 0.8,
        });

        // 5. 暗渠入口（位于 passLine = 440，阴影里凭冷月石沿与深暗格栅清晰可读）
        const culvertX = this.getCulvertWorldX(p);
        this.buildCulvertEntrance(scene, culvertX);

        // 6. 三类地表落点（灰度下形态+明暗截然分明）：
        //    6a. 软土（softX = 272，暗哑散点与浅足印）
        const softX = this.getSoftWorldX(p);
        this.buildSoftDirtPatch(scene, softX);

        //    6b. 硬砖落点（brickX = 608，拼缝深暗 + 迎光亮边）
        const brickX = this.getBrickWorldX(p);
        this.buildHardBrickPatch(scene, brickX);

        //    6c. 铁盆落点（basinX = 548，低模多面体敲打铁盆 + 受击高频颤动 + 侧光亮沿）
        const basinX = this.getBasinWorldX(p);
        this.buildIronBasin(scene, basinX);

        // 7. 院门斜射月光体积光束（自屏幕顶部无缝倾泻，恰好擦过铁盆沿、拾荒者鞋底与硬砖拼缝）
        scene.addLightShaft(
            ox + 570, ox + 710, 290,
            ox + 446, ox + 642, 0,
            24,
            rgba(218, 226, 218, 255),
            0.13,
            0.04,
        );

        // 8. 2D 角色脚底接触影（小满与拾荒者，严格贴合 wz = 0）
        scene.addContactShadow(p.player.x, p.player.y, 14, 10, 0.80, { bucket: LP_BUCKET.PROP, sortBias: 0.4 });
        if (p.room.scavenger !== undefined) {
            scene.addContactShadow(p.scavX, p.room.scavenger.y, 19, 13, 0.84, { bucket: LP_BUCKET.PROP, sortBias: 0.42 });
        }

        scene.flush(fgDraw, fgGlow, ctx.dioramaWorld);

        // 9. 强化地表灰度纹理细节（砖缝高亮线、软土散点足印、暗渠水光、铁盆受击光闪）
        this.drawSurfaceReadabilityDetails(fgDraw, fgGlow, p, cam, softX, culvertX, basinX, brickX);

        return true;
    }

    private buildCulvertEntrance(scene: LowpolyScene, cx: number): void {
        // 凹陷暗渠石框底台（不挡地面碰撞但清晰标明下穿口）
        scene.addBox({
            x0: cx - 18,
            x1: cx + 18,
            y0: -12,
            y1: 2,
            z0: -6,
            z1: 42,
            material: MAT_CULVERT_STONE,
            bucket: LP_BUCKET.WALK_DECK,
            highlightTopEdge: true,
            edgeWidth: 0.8,
        });
        // 手绘石拱暗渠栅栏入口（diorama_cutouts.clip|culvert_arch）
        scene.addCutout3D(
            "assets/art/diorama_cutouts.clip|culvert_arch",
            cx,
            0,
            20,
            46,
            33,
            {
                bucket: LP_BUCKET.MIDGROUND,
                anchorX: 0.5,
                anchorY: 0,
                color: rgba(182, 198, 214, 255),
                opacity: 0.98,
                sortBias: 0.32,
            },
        );
    }

    private buildSoftDirtPatch(scene: LowpolyScene, softX: number): void {
        scene.addBox({
            x0: softX - 24,
            x1: softX + 24,
            y0: -4,
            y1: 1.5,
            z0: -16,
            z1: 28,
            material: MAT_SOFT_EARTH,
            bucket: LP_BUCKET.WALK_DECK,
            sortBias: 0.15,
            edgeWidth: 0.4,
        });
    }

    private buildHardBrickPatch(scene: LowpolyScene, brickX: number): void {
        // 3×2 错缝露天青砖块（清晰拼缝与迎光亮边，灰度下极具识别度）
        let col = 0;
        for (col = 0; col < 3; col++) {
            const bx0 = brickX - 24 + col * 16;
            const bx1 = bx0 + 14.5;
            scene.addBox({
                x0: bx0,
                x1: bx1,
                y0: -4,
                y1: 3.2,
                z0: -14,
                z1: 6,
                material: MAT_HARD_BRICK,
                bucket: LP_BUCKET.WALK_DECK,
                sortBias: 0.20 + col * 0.01,
                highlightTopEdge: true,
                edgeWidth: 1.0,
            });
            scene.addBox({
                x0: bx0 + 4,
                x1: bx1 + 4,
                y0: -4,
                y1: 2.8,
                z0: 8,
                z1: 26,
                material: MAT_HARD_BRICK,
                bucket: LP_BUCKET.WALK_DECK,
                sortBias: 0.18 + col * 0.01,
                highlightTopEdge: true,
                edgeWidth: 0.9,
            });
        }
    }

    private buildIronBasin(scene: LowpolyScene, basinX: number): void {
        // 垫底青石砖
        scene.addBox({
            x0: basinX - 14,
            x1: basinX + 14,
            y0: -2,
            y1: 3,
            z0: -10,
            z1: 14,
            material: MING_MATERIALS.mingBrickDark,
            bucket: LP_BUCKET.PROP,
            sortBias: 0.02,
        });
        // 手绘厚壁旧铁盆立牌（受击时随 basinShakeAngle 产生阻尼倾角微摆）
        const tilt = this.basinShakeAngle;
        const shiftX = Math.sin(tilt * 1.4) * 2.5;
        const bx = basinX + shiftX;
        scene.addCutout3D(
            "assets/art/diorama_cutouts.clip|iron_basin",
            bx,
            2,
            -8,
            38,
            17.5,
            {
                bucket: LP_BUCKET.PROP,
                anchorX: 0.5,
                anchorY: 0,
                angle: -(tilt * 180) / Math.PI,
                color: rgba(214, 224, 236, 255),
                opacity: 0.99,
                sortBias: 0.28,
            },
        );
    }

    private drawSurfaceReadabilityDetails(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        softX: number,
        culvertX: number,
        basinX: number,
        brickX: number,
    ): void {
        const y0 = cam.sy(0);

        // 1. 软土散点土粒与浅足印（低反差暗哑，绝不发光）
        const sx0 = cam.sx(softX - 20);
        const sx1 = cam.sx(softX + 20);
        let d = 0;
        for (d = 0; d < 9; d++) {
            const dx = sx0 + ((sx1 - sx0) * (d + 0.5)) / 9;
            const dy = y0 - 2.5 + ((d % 3) - 1) * 1.8;
            fgDraw.drawDot(Vec2(dx, dy), 1.3, Color(116, 98, 78, 175));
        }
        fgDraw.drawEllipse(Vec2(cam.sx(softX - 7), y0 - 1.5), cam.len(4.2), 1.6, Color(38, 30, 24, 185));
        fgDraw.drawEllipse(Vec2(cam.sx(softX + 8), y0 - 2.0), cam.len(4.2), 1.6, Color(38, 30, 24, 185));

        // 2. 暗渠入口水光微沿（冷灰银，非荧光）
        const cL = cam.sx(culvertX - 11);
        const cR = cam.sx(culvertX + 11);
        const cTop = cam.sy(25);
        fgDraw.drawSegment(Vec2(cL, cTop), Vec2(cR, cTop), 1.6, Color(196, 210, 224, 210));
        const rippleShift = Math.sin(this.animTime * 2.3) * 3;
        fgGlow.drawSegment(Vec2(cL + 3 + rippleShift, y0 + 2), Vec2(cR - 4 + rippleShift, y0 + 2), 1.1, Color(164, 192, 214, 105));

        // 3. 铁盆盆沿侧光高光弧（受击时随颤动闪亮，灰度清晰）
        const bPtL = projectWorld3D(basinX - 16, 14.5 + Math.sin(this.basinShakeAngle) * 14, -12, cam, this.proj);
        const bPtR = projectWorld3D(basinX + 16, 14.5 - Math.sin(this.basinShakeAngle) * 14, -12, cam, this.proj);
        const shakeBoost = this.basinShakeTimer > 0 ? clamp01(this.basinShakeTimer / this.basinShakeMax) : 0;
        const rimAlpha = Math.round(205 + 48 * shakeBoost);
        fgDraw.drawSegment(Vec2(bPtL.x, bPtL.y), Vec2(bPtR.x, bPtR.y), 2.1 + shakeBoost * 1.1, Color(230, 236, 242, rimAlpha));
        fillRadialGlow(
            fgGlow,
            (bPtL.x + bPtR.x) * 0.5,
            (bPtL.y + bPtR.y) * 0.5,
            cam.len(22 + shakeBoost * 18),
            cam.len(10 + shakeBoost * 8),
            Color(216, 226, 236, Math.round(48 + 95 * shakeBoost)),
            Color(186, 202, 220, 0),
            14,
        );

        // 4. 硬砖拼缝亮边（三条明晰亮棱 + 暗缝，与铁盆圆沿截然区分）
        const brL = cam.sx(brickX - 24);
        const brR = cam.sx(brickX + 24);
        const brTop = cam.sy(3.2);
        fgDraw.drawSegment(Vec2(brL, brTop), Vec2(brR, brTop), 1.8, Color(224, 228, 234, 225));
        let k = 1;
        for (k = 1; k <= 2; k++) {
            const seamX = brL + ((brR - brL) * k) / 3;
            fgDraw.drawSegment(Vec2(seamX, y0 - 3), Vec2(seamX, brTop + 1), 1.5, Color(20, 24, 32, 240));
            fgDraw.drawSegment(Vec2(seamX + 1.8, y0 - 2), Vec2(seamX + 1.8, brTop), 0.9, Color(214, 218, 224, 175));
        }

        // 5. 瓶子落地后的碎屑与双材质扩散声波环
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

        // 防止未使用的 p 参数告警
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
            this.drawScavengerShoeOverlay(fgDraw, fgGlow, worldArt, p, cam);
        }

        // 暂停态下 uiDraw 不运行，使用 worldArt 贴合同一木桌真实尺度兜底，绝不弹出巨型黑块
        if (ctx.paused) {
            const arch = p.room.arch;
            const pTopBL = projectWorld3D(arch.x0 - 8, arch.h, -15, cam, this.proj);
            const pTopTR = projectWorld3D(arch.x1 + 8, arch.h + 8, -15, cam, this.proj);
            worldArt.tryPlace(
                "cover_wood",
                "fe04_pause_table_top",
                (pTopBL.x + pTopTR.x) * 0.5,
                pTopBL.y,
                Math.max(20, Math.abs(pTopTR.x - pTopBL.x)),
                Math.max(8, Math.abs(pTopTR.y - pTopBL.y)),
                { color: Color(46, 35, 27, 255), opacity: 0.96, layer: 5300 },
            );
            const legBL = projectWorld3D(arch.x1 - 6, 0, -15, cam, this.proj);
            const legTR = projectWorld3D(arch.x1 + 1, arch.h, -15, cam, this.proj);
            worldArt.tryPlace(
                "cover_wood",
                "fe04_pause_table_leg",
                (legBL.x + legTR.x) * 0.5,
                legBL.y,
                Math.max(6, Math.abs(legTR.x - legBL.x)),
                Math.max(16, Math.abs(legTR.y - legBL.y)),
                { color: Color(34, 25, 19, 255), opacity: 0.96, layer: 5310 },
            );
        }
    }

    private drawScavengerShoeOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
    ): void {
        const cx = cam.sx(p.scavX);
        const by = cam.sy(p.room.scavenger !== undefined ? p.room.scavenger.y : 0);
        const f = this.shoeFacing >= 0 ? 1 : -1;
        const moving = p.scavState === "patrol" || p.scavState === "walk" || p.scavState === "back" || p.scavState === "chase";
        const pausedToe = this.shoeToePauseTimer > 0;

        // 1. 地面月光擦亮底带（柔和把阴影里的草鞋脚步从深色地面托出，确保灰度高对比）
        fillRadialGlow(fgGlow, cx + f * cam.len(4), by + 2, cam.len(34), cam.len(9), Color(196, 208, 220, 52), Color(156, 172, 190, 0), 14);
        fgDraw.drawEllipse(Vec2(cx + f * cam.len(2), by + 1), cam.len(19), cam.len(3.4), Color(74, 82, 92, 68));

        // 2. 手绘拾荒者绑腿草鞋脚步立牌（diorama_cutouts.clip|scav_legs_a / scav_legs_b，与像素步态同步）
        const stepB = moving && Math.sin(this.scavStridePhase) < 0;
        const framePath = stepB
            ? "assets/art/diorama_cutouts.clip|scav_legs_b"
            : "assets/art/diorama_cutouts.clip|scav_legs_a";
        const bobY = moving ? Math.abs(Math.sin(this.scavStridePhase)) * cam.len(1.8) : 0;
        const tiltDeg = moving ? Math.sin(this.scavStridePhase) * 3.5 * f : 0;
        const legsH = cam.len(23);
        const legsW = legsH * (394 / 342);
        worldArt.tryPlacePath(framePath, "fe04_scav_painted_legs", cx, by - 1 + bobY, legsW, legsH, {
            anchorX: 0.5,
            anchorY: 0,
            facing: f,
            angle: tiltDeg,
            color: Color(204, 212, 224, 255),
            opacity: 0.94,
            smooth: true,
            layer: 4650,
        });
        if (pausedToe) {
            fgGlow.drawDot(Vec2(cx + f * cam.len(10), by + 2), 3.4, Color(236, 218, 178, 165));
        }
    }

    /**
     * 在 uiDraw / uiArt 前景层（严格位于 2D 角色精灵 worldArt 之前、HUD 文本之后）绘制与 drawWorld
     * 严格 1:1 对齐的唯一明式木桌前景部分（手绘 table_apron_frame + hemp_tablecloth + 粗瓷冷碗）：
     * - 保持桌高 44、宽 128 与人物尺度严密契合，桌下 44 单位净空完全通透；
     * - 小满从前后桌腿之间、桌面之下穿行时呈现自然真实的前后遮挡层次；
     * - 固定返回 false，绝不压隐 HUD、字幕或投瓶准星。
     */
    drawForegroundOverlay(
        uiDraw: DrawNode.Type,
        _uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        _uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const inv = 1 / Math.max(0.25, ctx.uiScale);
        const arch = p.room.arch;

        const xLeft = arch.x0 - 8;
        const xRight = arch.x1 + 8;
        const tableBotY = arch.h;
        const tableTopY = arch.h + 8;
        const zFront = -15;
        const zMid = 4;

        // 1. 桌面顶面透视（保留 3D 顶面衔接与后半桌一致）
        const fTopL = projectWorld3D(xLeft, tableTopY, zFront, cam, this.proj);
        const fTopR = projectWorld3D(xRight, tableTopY, zFront, cam, this.proj);
        const topBackL = projectWorld3D(xLeft, tableTopY, zMid, cam, this.proj);
        const topBackR = projectWorld3D(xRight, tableTopY, zMid, cam, this.proj);
        drawUiQuad(uiDraw, fTopL, fTopR, topBackR, topBackL, Color(46, 35, 26, 240), Color(28, 21, 16, 232), inv, Color(118, 98, 78, 115), 0.7);

        // 2. 手绘明式厚木桌前框（透明桌下净空，严密对齐 y = 0..tableTopY、xLeft..xRight）
        const pBL = projectWorld3D(xLeft, 0, zFront, cam, this.proj);
        const pBR = projectWorld3D(xRight, 0, zFront, cam, this.proj);
        const tblW = Math.max(24, (pBR.x - pBL.x) * inv);
        const tblH = Math.max(18, (fTopL.y - pBL.y) * inv);
        const tblCx = (pBL.x + pBR.x) * 0.5 * inv;
        const tblBot = pBL.y * inv;
        const placedTable = uiArt.tryPlacePath(
            "assets/art/diorama_cutouts.clip|table_apron_frame",
            "fe04_village_fg_table_frame",
            tblCx,
            tblBot,
            tblW * 1.03,
            tblH * 1.04,
            {
                anchorX: 0.5,
                anchorY: 0,
                color: Color(172, 158, 146, 255),
                opacity: 0.98,
                smooth: true,
                layer: 1,
            },
        );
        if (!placedTable) {
            const bNearL = projectWorld3D(xLeft, tableBotY, zFront, cam, this.proj);
            const bNearR = projectWorld3D(xRight, tableBotY, zFront, cam, this.proj);
            drawUiQuad(uiDraw, bNearL, bNearR, fTopR, fTopL, Color(38, 28, 21, 252), Color(56, 42, 32, 254), inv);
        }

        // 3. 左桌角垂落手绘粗麻桌布角（克制尺寸落在左角外沿，绝不遮挡桌下小满）
        uiArt.tryPlacePath(
            "assets/art/diorama_cutouts.clip|hemp_tablecloth",
            "fe04_village_fg_tablecloth",
            pBL.x * inv + tblW * 0.08,
            fTopL.y * inv + 2,
            tblW * 0.24,
            tblH * 0.42,
            {
                anchorX: 0.5,
                anchorY: 1,
                color: Color(136, 132, 126, 255),
                opacity: 0.90,
                smooth: true,
                layer: 2,
            },
        );

        // 4. 桌上真实比例手绘粗瓷冷碗（14×7 世界单位 ≈ 28cm×14cm，绝非巨碗）
        const bowlPt = projectWorld3D(arch.x0 + 31, tableTopY, -5, cam, this.proj);
        const bowlW = cam.len(17) * inv;
        const bowlH = bowlW * (248 / 326);
        uiArt.tryPlacePath(
            "assets/art/cutscene_story_parts.clip|porridge_bowl",
            "fe04_village_table_bowl",
            bowlPt.x * inv,
            bowlPt.y * inv - 2,
            bowlW,
            bowlH,
            {
                anchorX: 0.5,
                anchorY: 0,
                color: Color(152, 158, 166, 255),
                opacity: 0.94,
                smooth: true,
                layer: 2,
            },
        );

        // 5. 蹲伏在桌下（304..416）时顶部极克制木梁压顶暗边，强化《小小梦魇》桌下压迫层次（绝不遮挡鞋底与投瓶）
        if (p.player.crouch && p.player.x >= arch.x0 - 16 && p.player.x <= arch.x1 + 16) {
            const topBandH = ctx.uiH * 0.14;
            fillVGradRect(
                uiDraw,
                0,
                ctx.uiH - topBandH,
                ctx.uiW,
                topBandH,
                Color(12, 10, 9, 0),
                Color(12, 10, 9, 138),
            );
        }

        // 绝不压隐常规 HUD 与准星
        return false;
    }
}
