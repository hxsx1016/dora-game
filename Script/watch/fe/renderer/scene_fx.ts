/**
 * 《向西守望》黑暗像素风四层活态场景动效引擎（SceneFxSystem · Dead Cells 风格参考）：
 *
 * 架构解耦原则：
 * - 完全独立于静态底图文件（bgFar_*.png），通过标准分层 DrawNode / AssetSlotHost 叠加，
 *   可与任意黑暗像素风底图无缝融合、零文件冲突；
 * - 统一风场（WindField）协同驱动全场景：天穹行云、谷底流雾、挂灯摆动、火盆烈焰、
 *   战旗飘动、草丛风波与角色拨草、三层景深雨丝与落地水花溅射、战火余烬与密林萤尘；
 * - 严格消费世界时钟 worldDt（暂停瞬间绝对冻结，换弹慢时同步放慢）；
 * - 零每帧内存分配：全部粒子/水花/拨草叶片采用固定容量对象池复用。
 */

import { Color, DrawNode, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { LANE_DEPTH, LANE_ROAD } from "Script/watch/depth";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { depthOrder } from "Script/watch/fe/occlusion";
import { isEscortWorldRoom } from "Script/watch/fe/scenes/escort_world";
import { PALETTE, RGBA, fillGradQuad, fillRadialGlow, themeOf, toColor } from "Script/watch/fe/theme";

export type WeatherKind = "embers" | "rain" | "forest" | "sanctuary" | "siege";

interface DepthParticle {
    fx: number;      // 0..1 归一化视口 X
    fy: number;      // 0..1 归一化视口 Y
    layer: number;   // 0=远, 1=中, 2=近
    speedMul: number;
    size: number;
    phase: number;
    drift: number;
    bright: boolean;
}

interface RainSplash {
    wx: number;
    wy: number;
    depth: number;
    age: number;
    maxAge: number;
    scale: number;
}

interface FoliageLeaf {
    wx: number;
    wy: number;
    depth: number;
    vx: number;
    vy: number;
    age: number;
    maxAge: number;
    spin: number;
    frame: number;
}

interface BrazierEmber {
    wx: number;
    wy: number;
    depth: number;
    vx: number;
    vy: number;
    age: number;
    maxAge: number;
    size: number;
}

interface LightShaftSpec {
    x0: number;
    topW: number;
    botShift: number;
    botW: number;
    color: RGBA;
    alpha: number;
}

interface WorldAnchor {
    offsetX: number;
    y: number;
    depth: number;
    kind: "brazier" | "banner" | "lantern";
    facing?: number;
}

const PARTICLE_COUNT = 92;
const MAX_SPLASHES = 24;
const MAX_LEAVES = 32;
const MAX_BRAZIER_EMBERS = 36;

const SFX_FLAME_CLIPS = [
    "assets/art/vfx_ming_fx.clip|flame_0",
    "assets/art/vfx_ming_fx.clip|flame_1",
    "assets/art/vfx_ming_fx.clip|flame_2",
    "assets/art/vfx_ming_fx.clip|flame_3",
];
const SFX_FLAG_CLIPS = [
    "assets/art/vfx_ming_fx.clip|flag_red_0",
    "assets/art/vfx_ming_fx.clip|flag_red_1",
    "assets/art/vfx_ming_fx.clip|flag_red_2",
    "assets/art/vfx_ming_fx.clip|flag_red_3",
];
const SFX_LANTERN_FLAME_CLIPS = [
    "assets/art/vfx_ming_fx.clip|lantern_flame_0",
    "assets/art/vfx_ming_fx.clip|lantern_flame_1",
];
const SFX_LEAF_CLIPS = [
    "assets/art/vfx_ming_fx.clip|leaf_0",
    "assets/art/vfx_ming_fx.clip|leaf_1",
];
const SFX_RAIN_SPLASH_CLIPS = [
    "assets/art/vfx_ming_fx.clip|rain_splash_0",
    "assets/art/vfx_ming_fx.clip|rain_splash_1",
];

function clamp01(v: number): number {
    return v <= 0 ? 0 : (v >= 1 ? 1 : v);
}

function hash01(seed: number): number {
    const x = Math.sin(seed * 127.1 + 311.7) * 43758.5453;
    return x - Math.floor(x);
}

function weatherOfRoom(roomKey: string): WeatherKind {
    if (roomKey === "gate") {
        return "siege";
    }
    if (roomKey === "outside" || roomKey === "village" || roomKey === "escort4") {
        return "rain";
    }
    if (roomKey === "forest" || roomKey === "escort3") {
        return "forest";
    }
    if (roomKey === "tower" || roomKey === "museum" || roomKey === "escort5") {
        return "sanctuary";
    }
    return "embers";
}

function roomWindScale(roomKey: string): number {
    if (roomKey === "prologue" || roomKey === "escort2" || roomKey === "c2-granary" || roomKey === "museum") {
        return 0.25;
    }
    if (roomKey === "tower" || roomKey === "escort3") {
        return 0.45;
    }
    if (roomKey === "gate" || roomKey === "outside" || roomKey === "escort4") {
        return 1.25;
    }
    return 0.85;
}

function isOutdoorRoom(roomKey: string): boolean {
    return roomKey !== "prologue"
        && roomKey !== "c2-granary"
        && roomKey !== "escort2"
        && roomKey !== "museum";
}

function hasWarHorizon(roomKey: string): boolean {
    return roomKey === "prologue"
        || roomKey === "street"
        || roomKey === "s1-crossroad"
        || roomKey === "s2-drygoods"
        || roomKey === "s3-archway"
        || roomKey === "checkpoint"
        || roomKey === "c1-yard"
        || roomKey === "gate"
        || roomKey === "gatepath"
        || roomKey === "escort1";
}

function lightShaftsForRoom(roomKey: string): LightShaftSpec[] {
    if (roomKey === "prologue") {
        return [
            { x0: 190, topW: 54, botShift: -82, botW: 118, color: PALETTE.jadeMist, alpha: 0.14 },
            { x0: 540, topW: 40, botShift: -68, botW: 96, color: PALETTE.jadeMist, alpha: 0.11 },
        ];
    }
    if (roomKey === "s2-drygoods" || roomKey === "s1-crossroad" || roomKey === "street") {
        return [
            { x0: 260, topW: 48, botShift: -75, botW: 112, color: PALETTE.jadeMist, alpha: 0.10 },
            { x0: 760, topW: 56, botShift: -84, botW: 128, color: PALETTE.jadeMist, alpha: 0.10 },
        ];
    }
    if (roomKey === "c2-granary") {
        return [
            { x0: 280, topW: 46, botShift: -72, botW: 108, color: PALETTE.jadeMist, alpha: 0.16 },
            { x0: 660, topW: 52, botShift: -80, botW: 120, color: PALETTE.jadeMist, alpha: 0.15 },
            { x0: 1040, topW: 42, botShift: -68, botW: 98, color: PALETTE.jadeMist, alpha: 0.13 },
        ];
    }
    if (roomKey === "gate") {
        return [
            { x0: 910, topW: 72, botShift: -64, botW: 146, color: PALETTE.jadeMist, alpha: 0.16 },
        ];
    }
    if (roomKey === "forest" || roomKey === "escort3") {
        return [
            { x0: 340, topW: 44, botShift: -86, botW: 112, color: PALETTE.emerald, alpha: 0.10 },
            { x0: 880, topW: 52, botShift: -92, botW: 126, color: PALETTE.emerald, alpha: 0.11 },
            { x0: 1320, topW: 48, botShift: -76, botW: 118, color: PALETTE.amber, alpha: 0.09 },
        ];
    }
    if (roomKey === "tower" || roomKey === "escort5") {
        return [
            { x0: 445, topW: 58, botShift: -56, botW: 132, color: PALETTE.amber, alpha: 0.14 },
        ];
    }
    if (roomKey === "museum") {
        return [
            { x0: 240, topW: 68, botShift: 92, botW: 150, color: PALETTE.amberCore, alpha: 0.15 },
            { x0: 640, topW: 72, botShift: 96, botW: 158, color: PALETTE.amberCore, alpha: 0.13 },
        ];
    }
    return [];
}

function roomAnchors(roomKey: string): WorldAnchor[] {
    const roadBack = LANE_ROAD.max;
    const escortBack = LANE_DEPTH.upper + 14;
    if (roomKey === "street" || roomKey === "s1-crossroad" || roomKey === "s2-drygoods") {
        return [
            { offsetX: 168, y: 0, depth: roadBack, kind: "brazier" },
            { offsetX: 465, y: 92, depth: roadBack, kind: "banner", facing: 1 },
            { offsetX: 790, y: 0, depth: roadBack, kind: "brazier" },
            { offsetX: 1030, y: 90, depth: roadBack, kind: "banner", facing: 1 },
        ];
    }
    if (roomKey === "s3-archway" || roomKey === "checkpoint" || roomKey === "c1-yard") {
        return [
            { offsetX: 210, y: 0, depth: roadBack, kind: "brazier" },
            { offsetX: 540, y: 94, depth: roadBack, kind: "banner", facing: 1 },
            { offsetX: 880, y: 0, depth: roadBack, kind: "brazier" },
        ];
    }
    if (roomKey === "gate") {
        return [
            { offsetX: 170, y: 0, depth: roadBack, kind: "brazier" },
            { offsetX: 468, y: 0, depth: roadBack, kind: "brazier" },
            { offsetX: 785, y: 0, depth: roadBack, kind: "brazier" },
            { offsetX: 340, y: 76, depth: roadBack, kind: "banner", facing: 1 },
            { offsetX: 715, y: 80, depth: roadBack, kind: "banner", facing: 1 },
        ];
    }
    if (roomKey === "gatepath") {
        // gatepath 已升级 2.5D 窄巷（depth -28..28），锚定至后缘并错开 escort_world 路碑（108 / 520）
        return [
            { offsetX: 164, y: 62, depth: 28, kind: "banner", facing: 1 },
            { offsetX: 576, y: 56, depth: 28, kind: "banner", facing: 1 },
        ];
    }
    if (roomKey === "escort1") {
        // 火盆与 escort_world 后缘深度完全对齐（46），统一用 dp_brazier + 4 帧像素火焰渲染，消除双份火盆
        return [
            { offsetX: 285, y: 0, depth: escortBack, kind: "brazier" },
            { offsetX: 860, y: 0, depth: escortBack, kind: "brazier" },
            { offsetX: 615, y: 74, depth: escortBack, kind: "banner", facing: 1 },
        ];
    }
    if (roomKey === "escort5") {
        // 错开 escort_world 路碑（x=215）并贴齐后缘
        return [
            { offsetX: 268, y: 68, depth: escortBack, kind: "banner", facing: 1 },
            { offsetX: 920, y: 0, depth: escortBack, kind: "brazier" },
        ];
    }
    return [];
}

export class SceneFxSystem {
    private particles: DepthParticle[] = [];
    private splashes: RainSplash[] = [];
    private leaves: FoliageLeaf[] = [];
    private brazierEmbers: BrazierEmber[] = [];

    private time = 0;
    private splashCooldown = 0;
    private emberCooldown = 0;
    private farFlash = 0;
    private farFlashCooldown = 4.2;
    private prevPlayerInGrass = false;
    private prevPlayerX = 0;
    private lastRoomKey = "";
    private rng = 20261127;

    constructor() {
        this.initParticles();
    }

    private rand(): number {
        this.rng = (this.rng * 1664525 + 1013904223) % 4294967296;
        return this.rng / 4294967296;
    }

    private initParticles(): void {
        this.particles = [];
        for (let i = 0; i < PARTICLE_COUNT; i++) {
            const layer = i < 30 ? 0 : (i < 66 ? 1 : 2);
            this.particles.push({
                fx: this.rand(),
                fy: this.rand(),
                layer,
                speedMul: (layer === 0 ? 0.52 : (layer === 1 ? 0.96 : 1.48)) * (0.8 + this.rand() * 0.45),
                size: layer === 0 ? (1.0 + this.rand() * 0.8) : (layer === 1 ? (1.5 + this.rand() * 1.1) : (2.1 + this.rand() * 1.5)),
                phase: this.rand() * Math.PI * 2,
                drift: (this.rand() - 0.5) * 0.08,
                bright: this.rand() > 0.42,
            });
        }
    }

    reset(roomKey: string = ""): void {
        this.splashes = [];
        this.leaves = [];
        this.brazierEmbers = [];
        this.splashCooldown = 0;
        this.emberCooldown = 0;
        this.farFlash = 0;
        this.farFlashCooldown = 3.2 + this.rand() * 4.5;
        this.prevPlayerInGrass = false;
        this.lastRoomKey = roomKey;
    }

    /** 全局统一风场强度（约 0.25..1.85，包含阵风脉冲） */
    windAt(time: number, roomKey: string): number {
        const base = roomWindScale(roomKey);
        const swell = 0.65 + 0.35 * Math.sin(time * 0.47);
        const gustRaw = Math.sin(time * 1.19 + 0.8) * Math.sin(time * 0.31);
        const gust = gustRaw > 0 ? gustRaw * gustRaw * 0.95 : 0;
        return base * (swell + gust);
    }

    /** 主更新（严格消费 worldDt，暂停归零冻结） */
    update(dt: number, p: Play, cam: CameraDirector): void {
        if (this.lastRoomKey !== p.room.key) {
            this.reset(p.room.key);
            this.prevPlayerX = p.player.x;
        }
        if (dt <= 0) {
            return;
        }

        this.time += dt;
        const key = p.room.key;
        const weather = weatherOfRoom(key);
        const wind = this.windAt(this.time, key);

        // 1. 远方战火偶发远闪（仅城内/城门战区，极克制不刺眼）
        if (this.farFlash > 0) {
            this.farFlash = Math.max(0, this.farFlash - dt * 3.8);
        }
        if (key === "gate" || key === "street" || key === "s1-crossroad" || key === "escort1") {
            this.farFlashCooldown -= dt;
            if (this.farFlashCooldown <= 0) {
                this.farFlash = key === "gate" ? 0.65 : 0.35;
                this.farFlashCooldown = (key === "gate" ? 2.6 : 5.5) + this.rand() * 5.2;
            }
        }

        // 2. 三层景深天气/氛围粒子推进
        const siegeBoost = (key === "gate" && p.phase === "gate-hold")
            ? (1 + 0.7 * clamp01(p.gateTick / 2700))
            : 1;
        for (let i = 0; i < this.particles.length; i++) {
            const pt = this.particles[i];
            pt.phase += dt * (1.7 + pt.layer * 0.45);
            if (weather === "rain") {
                pt.fx -= dt * (0.13 + wind * 0.16) * pt.speedMul;
                pt.fy -= dt * (0.72 + pt.layer * 0.22) * pt.speedMul;
            } else if (weather === "siege" || weather === "embers") {
                const vx = (-0.055 - wind * 0.085) * siegeBoost + Math.sin(pt.phase * 1.3) * 0.028;
                const vy = (0.045 + (pt.bright ? 0.065 : -0.022)) * siegeBoost;
                pt.fx += (vx + pt.drift * 0.4) * dt * pt.speedMul;
                pt.fy += vy * dt * pt.speedMul;
            } else if (weather === "forest") {
                pt.fx += (-0.018 * wind + Math.sin(pt.phase) * 0.022) * dt * pt.speedMul;
                pt.fy += (pt.bright ? Math.cos(pt.phase * 0.8) * 0.024 : -0.042) * dt * pt.speedMul;
            } else {
                // sanctuary：北塔暖尘与破晓微浮尘
                pt.fx += Math.sin(pt.phase * 0.7) * 0.012 * dt * pt.speedMul;
                pt.fy += (0.016 + Math.cos(pt.phase * 0.5) * 0.008) * dt * pt.speedMul;
            }
            if (pt.fx < -0.04) { pt.fx += 1.08; }
            if (pt.fx > 1.04) { pt.fx -= 1.08; }
            if (pt.fy < -0.04) { pt.fy += 1.08; }
            if (pt.fy > 1.04) { pt.fy -= 1.08; }
        }

        // 3. 雨天地面/台面水花溅射池
        if (weather === "rain") {
            this.splashCooldown -= dt;
            const halfSpan = (cam.viewW * 0.55) / Math.max(0.4, cam.ppu);
            if (this.splashCooldown <= 0 && this.splashes.length < MAX_SPLASHES) {
                const wx = cam.x + (this.rand() - 0.5) * 2 * halfSpan;
                let wy = 0;
                for (let f = 0; f < p.room.floors.length; f++) {
                    const fl = p.room.floors[f];
                    if (wx >= fl.x0 && wx <= fl.x1 && fl.y > wy && this.rand() > 0.45) {
                        wy = fl.y;
                    }
                }
                const depthRange = p.room.depth;
                const depth = depthRange !== undefined
                    ? depthRange.min + this.rand() * (depthRange.max - depthRange.min)
                    : 0;
                this.splashes.push({
                    wx,
                    wy,
                    depth,
                    age: 0,
                    maxAge: 0.22 + this.rand() * 0.12,
                    scale: 0.75 + this.rand() * 0.5,
                });
                this.splashCooldown = 0.032 + this.rand() * 0.038;
            }
        }
        let w = 0;
        for (let i = 0; i < this.splashes.length; i++) {
            const sp = this.splashes[i];
            sp.age += dt;
            if (sp.age < sp.maxAge) {
                this.splashes[w] = sp;
                w += 1;
            }
        }
        this.splashes.length = w;

        // 4. 草丛拨动与惊起碎叶检测（森林/城外/山道）
        let inGrass = false;
        for (let i = 0; i < p.room.solids.length; i++) {
            const s = p.room.solids[i];
            if (s.passable === true && p.player.x >= s.x - 8 && p.player.x <= s.x + s.w + 8 && p.player.y <= s.y + s.h + 6) {
                inGrass = true;
                break;
            }
        }
        const playerMove = Math.abs(p.player.x - this.prevPlayerX);
        this.prevPlayerX = p.player.x;
        if (inGrass && (!this.prevPlayerInGrass || (playerMove > 2.2 && this.rand() < dt * 7.5))) {
            this.spawnGrassLeaves(p.player.x, p.player.y + 8, p.player.depth, p.player.facing, this.prevPlayerInGrass ? 2 : 5);
        }
        this.prevPlayerInGrass = inGrass;

        // 森林/山路周期飘落松叶
        if ((key === "forest" || key === "escort3" || key === "escort4" || key === "escort5") && this.leaves.length < MAX_LEAVES && this.rand() < dt * (1.8 + wind)) {
            const halfSpan = (cam.viewW * 0.55) / Math.max(0.4, cam.ppu);
            this.leaves.push({
                wx: cam.x + (this.rand() - 0.35) * 2 * halfSpan,
                wy: 170 + this.rand() * 65,
                depth: 0,
                vx: -18 - wind * 24 - this.rand() * 14,
                vy: -20 - this.rand() * 18,
                age: 0,
                maxAge: 2.8 + this.rand() * 1.8,
                spin: this.rand() * Math.PI * 2,
                frame: Math.floor(this.rand() * 4),
            });
        }

        w = 0;
        for (let i = 0; i < this.leaves.length; i++) {
            const lf = this.leaves[i];
            lf.age += dt;
            if (lf.age < lf.maxAge && lf.wy >= -4) {
                lf.spin += dt * 4.2;
                lf.wx += (lf.vx + Math.sin(lf.spin) * 16) * dt;
                lf.wy += (lf.vy + Math.cos(lf.spin * 0.8) * 6) * dt;
                this.leaves[w] = lf;
                w += 1;
            }
        }
        this.leaves.length = w;

        // 5. 火盆升腾火星粒子
        const anchors = roomAnchors(key);
        this.emberCooldown -= dt;
        if (this.emberCooldown <= 0 && anchors.length > 0 && this.brazierEmbers.length < MAX_BRAZIER_EMBERS) {
            for (let i = 0; i < anchors.length; i++) {
                const an = anchors[i];
                if (an.kind !== "brazier") {
                    continue;
                }
                const wx = p.ox + an.offsetX;
                if (Math.abs(wx - cam.x) > 520) {
                    continue;
                }
                this.brazierEmbers.push({
                    wx: wx + (this.rand() - 0.5) * 12,
                    wy: an.y + 24,
                    depth: an.depth,
                    vx: -wind * 18 + (this.rand() - 0.5) * 18,
                    vy: 28 + this.rand() * 34,
                    age: 0,
                    maxAge: 0.9 + this.rand() * 0.9,
                    size: 1.4 + this.rand() * 1.4,
                });
            }
            this.emberCooldown = 0.14;
        }
        w = 0;
        for (let i = 0; i < this.brazierEmbers.length; i++) {
            const em = this.brazierEmbers[i];
            em.age += dt;
            if (em.age < em.maxAge) {
                em.wx += (em.vx + Math.sin(this.time * 5 + i) * 12) * dt;
                em.wy += em.vy * dt;
                this.brazierEmbers[w] = em;
                w += 1;
            }
        }
        this.brazierEmbers.length = w;
    }

    private spawnGrassLeaves(wx: number, wy: number, depth: number, facing: number, count: number): void {
        for (let i = 0; i < count && this.leaves.length < MAX_LEAVES; i++) {
            this.leaves.push({
                wx: wx + (this.rand() - 0.5) * 18,
                wy: wy + this.rand() * 10,
                depth,
                vx: -facing * (16 + this.rand() * 28) + (this.rand() - 0.5) * 26,
                vy: 36 + this.rand() * 38,
                age: 0,
                maxAge: 0.65 + this.rand() * 0.45,
                spin: this.rand() * Math.PI * 2,
                frame: Math.floor(this.rand() * 4),
            });
        }
    }

    /** L0：叠在任意静态/暗黑像素底图之上的大气与天穹动效（行云、霜月晕、战火地平光、流雾、丁达尔光束） */
    drawBackdropFx(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        backdropArt: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
    ): void {
        const key = p.room.key;
        const w = cam.viewW;
        const h = cam.viewH;
        const t = this.time;
        const wind = this.windAt(t, key);
        const theme = themeOf(key);

        // 1. 室外霜月呼吸晕与流动水墨夜云（不遮盖底图建筑，仅在天际上 35% 轻拂）
        if (isOutdoorRoom(key) && theme.showMoon) {
            const mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015;
            const my = h * theme.moonYFrac;
            const pulse = 0.88 + 0.12 * Math.sin(t * 1.15);
            fillRadialGlow(bgGlow, mx, my, h * 0.24 * pulse, h * 0.20 * pulse,
                Color(138, 174, 206, Math.round(28 * pulse)), Color(18, 28, 46, 0), 18);

            // 双层慢移云絮
            const cloudA = ((t * (7 + wind * 5) + cam.x * 0.05) % (w + 520)) - 260;
            const cloudB = ((t * (12 + wind * 8) + cam.x * 0.09 + w * 0.48) % (w + 520)) - 260;
            backdropArt.tryPlace("ink_mist_curve", "sfx_cloud_a", w - cloudA, h * 0.82, 540, 84, {
                color: Color(76, 98, 128, 255), opacity: 0.14, layer: 6,
            });
            backdropArt.tryPlace("ink_mist_curve", "sfx_cloud_b", w - cloudB, h * 0.72, 460, 72, {
                color: Color(58, 76, 104, 255), opacity: 0.11, layer: 6, facing: -1,
            });
        }

        // 2. 失守城池方向远火映红 & 偶尔远炮闪光（gatepath/escort1 已有 escort_world 基底红辉，仅补远炮闪光避免叠加过曝）
        const backRoadY = cam.sy(0, p.room.depth !== undefined ? p.room.depth.max : 0);
        if (hasWarHorizon(key)) {
            if (key !== "gatepath" && key !== "escort1") {
                const firePulse = 0.78 + 0.22 * Math.sin(t * 2.6 + Math.sin(t * 1.1));
                const glowA = key === "gate" ? 48 : 30;
                fillRadialGlow(bgGlow, w * 0.16, h * 0.28, w * 0.38, h * 0.34,
                    Color(186, 62, 34, Math.round(glowA * firePulse)), Color(160, 44, 24, 0), 16);
            }
            if (this.farFlash > 0.02) {
                const fa = Math.round(36 * this.farFlash);
                fillRadialGlow(bgGlow, w * 0.24, h * 0.46, w * 0.48, h * 0.42,
                    Color(242, 168, 114, fa), Color(186, 72, 44, 0), 16);
            }
        }

        // 3. 贴地双层流动夜雾 / 山岚（锚定 2.5D 路面后缘 backRoadY；护送线已由 escort_world 绘制专属海雾，避免四层叠雾发灰）
        if (!isEscortWorldRoom(key)) {
            const mistSpeed = 10 + wind * 12;
            const m1 = ((t * mistSpeed + cam.x * 0.14) % (w + 640)) - 320;
            const m2 = ((t * mistSpeed * 0.65 + cam.x * 0.08 + w * 0.52) % (w + 640)) - 320;
            const mistTint = key === "gate" ? Color(94, 52, 54, 255)
                : (key === "forest" ? Color(68, 108, 102, 255)
                    : (key === "tower" ? Color(148, 126, 98, 255) : Color(66, 86, 112, 255)));
            const mistOp = key === "forest" || key === "outside" || key === "village" ? 0.20 : 0.14;
            backdropArt.tryPlace("ink_mist_curve", "sfx_ground_mist_1", w - m1, backRoadY + h * 0.06, 660, 124, {
                color: mistTint, opacity: mistOp, layer: 7,
            });
            backdropArt.tryPlace("ink_mist_curve", "sfx_ground_mist_2", w - m2, backRoadY + h * 0.12, 580, 108, {
                color: mistTint, opacity: mistOp * 0.80, layer: 7, facing: -1,
            });
        }

        // 4. 丁达尔体积光束 + 光柱内漂浮像素尘埃（底端锁定 backRoadY 贴合暗黑底图石基）
        const shafts = lightShaftsForRoom(key);
        for (let i = 0; i < shafts.length; i++) {
            const sh = shafts[i];
            const topX = cam.sx(p.ox + sh.x0);
            const botX = topX + cam.len(sh.botShift);
            if (topX + cam.len(sh.topW + sh.botW) < -80 || botX - cam.len(sh.botW) > w + 80) {
                continue;
            }
            const pulse = 0.84 + 0.16 * Math.sin(t * 0.95 + i * 1.7);
            const tw = cam.len(sh.topW) * 0.5;
            const bw = cam.len(sh.botW) * 0.5;
            const yTop = h + 16;
            const yMid = h * 0.54;
            const yBot = backRoadY - 4;
            const midX = (topX + botX) * 0.5;
            const mw = (tw + bw) * 0.5;
            const col = sh.color;
            const aMid = Math.round(255 * sh.alpha * pulse);
            const aTop = Math.round(aMid * 0.45);
            fillGradQuad(
                bgGlow,
                topX - tw, yTop, Color(col.r, col.g, col.b, aTop),
                topX + tw, yTop, Color(col.r, col.g, col.b, aTop),
                midX + mw, yMid, Color(col.r, col.g, col.b, aMid),
                midX - mw, yMid, Color(col.r, col.g, col.b, aMid),
            );
            fillGradQuad(
                bgGlow,
                midX - mw, yMid, Color(col.r, col.g, col.b, aMid),
                midX + mw, yMid, Color(col.r, col.g, col.b, aMid),
                botX + bw, yBot, Color(col.r, col.g, col.b, 0),
                botX - bw, yBot, Color(col.r, col.g, col.b, 0),
            );

            // 光束内部慢旋尘粒（6 颗）
            for (let d = 0; d < 6; d++) {
                const u = (t * 0.08 + d * 0.167 + i * 0.23) % 1;
                const px = topX + (botX - topX) * u + Math.sin(t * 1.2 + d * 2.1) * (tw + (bw - tw) * u) * 0.55;
                const py = yTop + (yBot - yTop) * u;
                const fade = Math.sin(u * Math.PI);
                bgGlow.drawDot(Vec2(px, py), 1.4 + (d % 2) * 0.7, Color(col.r, col.g, col.b, Math.round(135 * fade * pulse)));
            }
        }
    }

    /** L1：世界空间活态环境物件（摇曳挂灯活焰、铁火盆烈焰与升腾火星、飘舞残旗、风动草丛与拨草叶片、水花溅射） */
    drawWorldFx(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
    ): void {
        const key = p.room.key;
        const t = this.time;
        const wind = this.windAt(t, key);
        const w = cam.viewW;
        const depthEnabled = p.room.depth !== undefined;

        // 1. 房间专属世界锚点：暗黑像素铁火盆 + 4 帧烈焰 + 暖光倒影、风吹暗红残旗（全部按 2.5D depthOrder 严格深度排序）
        const anchors = roomAnchors(key);
        const flameFrame = Math.floor(t * 11) % 4;
        const flagFrame = Math.floor(t * (5.5 + wind * 3.5)) % 4;

        for (let i = 0; i < anchors.length; i++) {
            const an = anchors[i];
            const wx = p.ox + an.offsetX;
            const sx = cam.sx(wx);
            if (sx < -120 || sx > w + 120) {
                continue;
            }
            const depth = depthEnabled ? an.depth : 0;
            const dScale = cam.depthScale(depth, depthEnabled);
            const sy = cam.sy(an.y, depth);

            if (an.kind === "brazier") {
                const pulse = 0.84 + 0.16 * Math.sin(t * 8.4 + i * 2.1);
                const potLayer = depthEnabled ? depthOrder(depth, -1) : 2;
                const potW = cam.len(26) * dScale;
                const potH = cam.len(30) * dScale;
                const fSize = cam.len(24) * dScale;

                // 统一使用暗黑像素铁火盆精灵 dp_brazier + worldArt 接触影（彻底清除多边形梯形灰模）
                worldArt.tryPlace("dp_shadow_contact", "sfx_brazier_sh_" + i, sx, sy + 1, potW, cam.len(7) * dScale, {
                    layer: potLayer - 1, opacity: 0.76,
                });
                if (!worldArt.tryPlace("dp_brazier", "sfx_brazier_pot_" + i, sx, sy, potW, potH, {
                    layer: potLayer,
                })) {
                    fgDraw.drawPolygon([
                        Vec2(sx - cam.len(11) * dScale, sy + cam.len(13) * dScale),
                        Vec2(sx + cam.len(11) * dScale, sy + cam.len(13) * dScale),
                        Vec2(sx + cam.len(7) * dScale, sy + cam.len(4) * dScale),
                        Vec2(sx - cam.len(7) * dScale, sy + cam.len(4) * dScale),
                    ], Color(26, 22, 24, 245), 1.0, Color(84, 58, 46, 175));
                }

                // 4 帧手绘像素火焰（紧贴盆口位于 potLayer + 1，绝不被盆体或远墙遮盖）
                if (!worldArt.tryPlacePath(
                    SFX_FLAME_CLIPS[(flameFrame + i) % 4],
                    "sfx_brazier_flame_" + i,
                    sx,
                    sy + cam.len(16) * dScale,
                    fSize,
                    fSize * 1.15,
                    { anchorX: 0.5, anchorY: 0, preserveAspect: true, layer: potLayer + 1 },
                )) {
                    fgGlow.drawEllipse(Vec2(sx, sy + cam.len(22) * dScale), cam.len(6) * dScale, cam.len(10 * pulse) * dScale, Color(246, 132, 46, 195));
                }

                // Dead Cells 式高对比暖光池 + 地面湿石暖色反光
                fillRadialGlow(fgGlow, sx, sy + cam.len(24) * dScale, cam.len(64 * pulse), cam.len(48 * pulse),
                    Color(238, 126, 48, Math.round(70 * pulse)), Color(210, 76, 26, 0), 16);
                fillRadialGlow(fgGlow, sx, sy + cam.len(2), cam.len(44 * pulse), cam.len(11 * pulse),
                    Color(246, 152, 72, Math.round(44 * pulse)), Color(220, 96, 36, 0), 14);
            } else if (an.kind === "banner") {
                // 4 帧风吹破损明代战旗（含铁矛枪尖与立杆，深度排序与后墙对齐）
                const poleBot = cam.sy(0, depth);
                const poleTop = sy + cam.len(16) * dScale;
                const bannerLayer = depthEnabled ? depthOrder(depth, 0) : 2;
                worldArt.tryPlace("dp_shadow_contact", "sfx_banner_sh_" + i, sx, poleBot + 1, cam.len(14) * dScale, cam.len(5) * dScale, {
                    layer: bannerLayer - 1, opacity: 0.68,
                });
                fgDraw.drawSegment(Vec2(sx, poleBot), Vec2(sx, poleTop), Math.max(1.5, cam.len(2.0) * dScale), Color(48, 38, 32, 230));
                fgDraw.drawPolygon([
                    Vec2(sx - cam.len(1.8) * dScale, poleTop),
                    Vec2(sx + cam.len(1.8) * dScale, poleTop),
                    Vec2(sx, poleTop + cam.len(6) * dScale),
                ], Color(136, 146, 158, 225));
                worldArt.tryPlacePath(
                    SFX_FLAG_CLIPS[(flagFrame + i) % 4],
                    "sfx_banner_" + i,
                    sx + cam.len(0.8) * dScale,
                    sy + cam.len(9) * dScale,
                    cam.len(34) * dScale,
                    cam.len(22) * dScale,
                    {
                        anchorX: 0.08,
                        anchorY: 0.5,
                        preserveAspect: true,
                        facing: an.facing ?? 1,
                        angle: Math.sin(t * 2.8 + i) * wind * 2.8,
                        opacity: 0.90,
                        layer: bannerLayer,
                    },
                );
            }
        }

        // 2. 路灯/挂灯（marks kind=6）增强摇曳烛火与地面暖色光池
        const lanternFrame = Math.floor(t * 7.5) % 2;
        const markLayer = depthEnabled ? depthOrder(0, 6) : 6;
        for (let i = 0; i < p.room.marks.length; i++) {
            const m = p.room.marks[i];
            if (m.kind !== 6) {
                continue;
            }
            const mx = cam.sx(m.x + 13);
            if (mx < -80 || mx > w + 80) {
                continue;
            }
            const my = cam.sy(m.y + 40);
            const swayX = Math.sin(t * 2.3 + m.x * 0.02) * wind * cam.len(2.4);
            const flicker = 0.86 + 0.14 * Math.sin(t * 9.2 + i * 3.1);
            worldArt.tryPlacePath(
                SFX_LANTERN_FLAME_CLIPS[lanternFrame],
                "sfx_mark_flame_" + i,
                mx + swayX,
                my,
                cam.len(16),
                cam.len(18),
                { anchorX: 0.5, anchorY: 0.5, preserveAspect: true, opacity: 0.88 * flicker, layer: markLayer },
            );
            // 路灯下青石地面的湿润暖光倒影
            const gy = cam.sy(m.y);
            fillRadialGlow(fgGlow, mx + swayX * 0.4, gy + cam.len(2), cam.len(38 * flicker), cam.len(10 * flicker),
                Color(246, 186, 104, Math.round(42 * flicker)), Color(224, 152, 74, 0), 14);
        }

        // 3. 火盆升腾火星
        for (let i = 0; i < this.brazierEmbers.length; i++) {
            const em = this.brazierEmbers[i];
            const k = 1 - em.age / em.maxAge;
            const ex = cam.sx(em.wx);
            const ey = cam.sy(em.wy, depthEnabled ? em.depth : 0);
            fgGlow.drawDot(Vec2(ex, ey), em.size * k, Color(255, 168, 76, Math.round(230 * k)));
            fgGlow.drawDot(Vec2(ex, ey), em.size * 2.4 * k, Color(228, 92, 36, Math.round(72 * k)));
        }

        // 4. 潜行草丛前景活态风波草叶（叠在静态 grass 贴图前侧，随风波动并在角色经过时向两侧弯折）
        for (let i = 0; i < p.room.solids.length; i++) {
            const s = p.room.solids[i];
            if (s.passable !== true) {
                continue;
            }
            const x0 = cam.sx(s.x);
            const x1 = cam.sx(s.x + s.w);
            if (x1 < -30 || x0 > w + 30) {
                continue;
            }
            const y0 = cam.sy(s.y);
            const sw = x1 - x0;
            const sh = cam.len(s.h);
            const blades = Math.max(7, Math.min(20, Math.floor(s.w / 9)));
            for (let b = 0; b < blades; b++) {
                const u = (b + 0.5) / blades;
                const bwx = s.x + s.w * u;
                const bx = x0 + sw * u;
                const dxPlayer = bwx - p.player.x;
                const near = Math.abs(dxPlayer) < 26 && p.player.y < s.y + s.h + 10;
                const partPush = near ? (dxPlayer >= 0 ? 1 : -1) * (1 - Math.abs(dxPlayer) / 26) * cam.len(10) : 0;
                const wave = Math.sin(t * (2.6 + wind) + bwx * 0.08) * cam.len(3.4 * wind) + partPush;
                const bh = sh * (0.95 + 0.45 * hash01(b * 13.7 + s.x));
                const col = (b % 2 === 0) ? Color(28, 66, 56, 175) : Color(46, 94, 78, 165);
                fgDraw.drawSegment(Vec2(bx, y0), Vec2(bx + wave, y0 + bh), Math.max(1.2, cam.len(1.6)), col);
            }
        }

        // 5. 飘落松叶与拨草飞叶
        for (let i = 0; i < this.leaves.length; i++) {
            const lf = this.leaves[i];
            const k = 1 - lf.age / lf.maxAge;
            const lx = cam.sx(lf.wx);
            const ly = cam.sy(lf.wy, depthEnabled ? lf.depth : 0);
            const sz = cam.len(9) * cam.depthScale(lf.depth, depthEnabled);
            const leafLayer = depthEnabled ? depthOrder(lf.depth, 5) : 7;
            if (!worldArt.tryPlacePath(
                SFX_LEAF_CLIPS[lf.frame % 2],
                "sfx_leaf_" + i,
                lx,
                ly,
                sz,
                sz,
                { anchorX: 0.5, anchorY: 0.5, angle: lf.spin * 45, opacity: Math.min(1, k * 1.8) * 0.85, layer: leafLayer },
            )) {
                fgDraw.drawEllipse(Vec2(lx, ly), 2.8, 1.3, Color(76, 118, 92, Math.round(185 * k)));
            }
        }

        // 6. 地面雨滴水花溅射（像素水花，按 2.5D 纵深排序）
        for (let i = 0; i < this.splashes.length; i++) {
            const sp = this.splashes[i];
            const prog = clamp01(sp.age / sp.maxAge);
            const sx = cam.sx(sp.wx);
            if (sx < -20 || sx > w + 20) {
                continue;
            }
            const sy = cam.sy(sp.wy + 1, depthEnabled ? sp.depth : 0);
            const sz = cam.len(10 * sp.scale) * cam.depthScale(sp.depth, depthEnabled);
            const frame = Math.min(1, Math.floor(prog * 2));
            const splashLayer = depthEnabled ? depthOrder(sp.depth, 1) : 7;
            if (!worldArt.tryPlacePath(
                SFX_RAIN_SPLASH_CLIPS[frame],
                "sfx_rain_splash_" + i,
                sx,
                sy,
                sz,
                sz * 0.65,
                { anchorX: 0.5, anchorY: 0, preserveAspect: true, opacity: (1 - prog) * 0.62, layer: splashLayer },
            )) {
                const r = cam.len(3 + prog * 5) * sp.scale;
                fgGlow.drawEllipse(Vec2(sx, sy), r, r * 0.28, Color(168, 196, 218, Math.round(110 * (1 - prog))));
            }
        }
    }

    /** L3：三层景深视差天气与近景大气粒子（替代单调平面小点） */
    drawForegroundWeather(
        fgGlow: DrawNode.Type,
        p: Play,
        cam: CameraDirector,
        w: number,
        h: number,
    ): void {
        const key = p.room.key;
        const weather = weatherOfRoom(key);
        const wind = this.windAt(this.time, key);
        const camParallaxBase = cam.x * 0.00045;

        for (let i = 0; i < this.particles.length; i++) {
            const pt = this.particles[i];
            const parallax = pt.layer === 0 ? 0.35 : (pt.layer === 1 ? 0.85 : 1.55);
            let nx = (pt.fx - camParallaxBase * parallax) % 1;
            if (nx < 0) {
                nx += 1;
            }
            const x = nx * w;
            const y = pt.fy * h;
            const tw = 0.55 + 0.45 * Math.sin(pt.phase);
            const layerAlpha = pt.layer === 0 ? 0.45 : (pt.layer === 1 ? 0.78 : 1.0);

            if (weather === "rain") {
                const len = (11 + pt.layer * 8) * pt.speedMul * 0.75;
                const tilt = (3.5 + wind * 5.2) * (0.7 + pt.layer * 0.25);
                const alpha = Math.round((46 + pt.layer * 24) * tw * layerAlpha);
                fgGlow.drawSegment(
                    Vec2(x, y),
                    Vec2(x + tilt, y + len),
                    pt.layer === 2 ? 1.15 : 0.8,
                    Color(168, 194, 216, alpha),
                );
            } else if (weather === "siege" || weather === "embers") {
                if (pt.bright) {
                    const col = weather === "siege" ? Color(255, 134, 62, Math.round(168 * tw * layerAlpha))
                        : Color(242, 160, 82, Math.round(132 * tw * layerAlpha));
                    const tailX = x + (2.5 + wind * 4.2) * (0.5 + pt.layer * 0.30);
                    const tailY = y - 2.8 * (0.6 + pt.layer * 0.25);
                    fgGlow.drawSegment(Vec2(tailX, tailY), Vec2(x, y), pt.size * 0.38, col);
                    fgGlow.drawDot(Vec2(x, y), pt.size * 0.54, Color(255, 214, 138, Math.round(145 * tw * layerAlpha)));
                } else {
                    // 漂浮暗灰烬絮
                    fgGlow.drawDot(Vec2(x, y), pt.size * 0.68, Color(142, 148, 162, Math.round(52 * tw * layerAlpha)));
                }
            } else if (weather === "forest") {
                if (pt.bright && pt.layer >= 1) {
                    // 密林冷翠/微金萤火
                    const col = (i % 3 === 0) ? PALETTE.amberCore : PALETTE.emerald;
                    const r = pt.size * (0.85 + 0.35 * tw);
                    fgGlow.drawDot(Vec2(x, y), r, toColor(col, 155 * tw * layerAlpha));
                    fgGlow.drawDot(Vec2(x, y), r * 2.8, toColor(col, 32 * tw * layerAlpha));
                } else {
                    fgGlow.drawDot(Vec2(x, y), pt.size * 0.72, Color(128, 164, 152, Math.round(62 * tw * layerAlpha)));
                }
            } else {
                // sanctuary：北塔暖尘与破晓微曦金粒
                const col = pt.bright ? PALETTE.amberCore : PALETTE.amber;
                fgGlow.drawDot(Vec2(x, y), pt.size * 0.85, toColor(col, 128 * tw * layerAlpha));
                if (pt.layer === 2 && pt.bright) {
                    fgGlow.drawDot(Vec2(x, y), pt.size * 2.4, toColor(PALETTE.amber, 26 * tw));
                }
            }
        }
    }

    /** 标题界面专属活态化动效（精准锚定 title.png 的霜月、北塔门灯、山谷夜雾与板车红布） */
    drawTitleAtmosphere(
        bgGlow: DrawNode.Type,
        fgGlow: DrawNode.Type,
        backdropArt: AssetSlotHost,
        worldArt: AssetSlotHost,
        w: number,
        h: number,
        time: number,
    ): void {
        // 统一计算与 MenuRenderer 相同的 16:9 铺满矩形
        const artW = Math.max(w, h * 16 / 9);
        const artH = artW * 9 / 16;
        const ox = (w - artW) * 0.5;
        const oy = (h - artH) * 0.5;
        const wind = this.windAt(time, "outside");

        // 1. 霜月柔和呼吸冷晕（title.png 右上月亮锚点 0.833, 0.915）
        const moonX = ox + artW * 0.833;
        const moonY = oy + artH * 0.915;
        const moonPulse = 0.88 + 0.12 * Math.sin(time * 0.9);
        fillRadialGlow(bgGlow, moonX, moonY, artH * 0.22 * moonPulse, artH * 0.22 * moonPulse,
            Color(176, 206, 232, Math.round(42 * moonPulse)), Color(24, 38, 60, 0), 20);

        // 2. 夜空缓行轻云与山谷深处流动夜雾
        const cloudX = ((time * 9) % (w + 540)) - 270;
        backdropArt.tryPlace("ink_mist_curve", "title_cloud_a", w - cloudX, oy + artH * 0.84, 540, 82, {
            color: Color(86, 108, 138, 255), opacity: 0.16, layer: 4,
        });
        const mist1 = ((time * 13) % (w + 680)) - 340;
        const mist2 = ((time * 8 + w * 0.45) % (w + 680)) - 340;
        backdropArt.tryPlace("ink_mist_curve", "title_valley_mist_1", w - mist1, oy + artH * 0.42, 680, 136, {
            color: Color(74, 96, 126, 255), opacity: 0.22, layer: 4,
        });
        backdropArt.tryPlace("ink_mist_curve", "title_valley_mist_2", w - mist2, oy + artH * 0.52, 600, 116, {
            color: Color(62, 82, 110, 255), opacity: 0.16, layer: 4, facing: -1,
        });

        // 3. 北塔门洞与西窗一点不灭暖灯（锚点 0.902, 0.684 与 0.893, 0.778）
        const doorX = ox + artW * 0.902;
        const doorY = oy + artH * 0.684;
        const lampPulse = 0.84 + 0.16 * Math.sin(time * 2.7 + Math.sin(time * 1.1));
        fillRadialGlow(bgGlow, doorX, doorY, artH * 0.14 * lampPulse, artH * 0.13 * lampPulse,
            Color(255, 202, 114, Math.round(108 * lampPulse)), Color(236, 152, 62, 0), 18);
        fillRadialGlow(bgGlow, doorX, doorY, artH * 0.045 * lampPulse, artH * 0.045 * lampPulse,
            Color(255, 240, 192, Math.round(168 * lampPulse)), Color(255, 196, 102, 0), 12);

        const winX = ox + artW * 0.893;
        const winY = oy + artH * 0.778;
        fillRadialGlow(bgGlow, winX, winY, artH * 0.045 * lampPulse, artH * 0.045 * lampPulse,
            Color(255, 212, 128, Math.round(92 * lampPulse)), Color(238, 168, 72, 0), 12);

        // 4. 标题界面微浮灰烬与月光尘埃（42 粒轻盈掠过，左暗区不抢文字可读性；保留 title.png 原生板车红布不重影）
        for (let i = 0; i < 42; i++) {
            const speed = 0.014 + (i % 5) * 0.005;
            const px = (1 - ((hash01(i * 17.3) + time * speed * (0.7 + wind * 0.5)) % 1)) * w;
            const py = ((hash01(i * 31.1) + time * (0.012 + (i % 3) * 0.006)) % 1) * h;
            const tw = 0.45 + 0.55 * Math.sin(time * 2.1 + i * 1.4);
            const isWarm = i % 3 === 0 && px > w * 0.45;
            const col = isWarm ? PALETTE.amberCore : PALETTE.jadeMist;
            const r = 1.0 + (i % 3) * 0.55;
            fgGlow.drawDot(Vec2(px, py), r, toColor(col, (isWarm ? 132 : 76) * tw));
        }
    }
}
