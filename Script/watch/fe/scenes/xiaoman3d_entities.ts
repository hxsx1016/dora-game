/**
 * 《向西守望》小满 3D 暗黑写实世界实体、光照与四房实景道具管理器（xiaoman3d_entities.ts）。
 *
 * 职责：
 * - 管理四房差异化暗黑写实光照（带阴影投射冷月主光 + 冷灰天空补光 + 叙事暖灯/月光局部点光源）；
 * - 渲染午夜冷月天幕与远山北塔微灯（sky_backdrop.glb），彻底消除 3D 视口背景黑洞；
 * - 渲染全部暗黑写实 3D NPC（村口拾荒者、森林猎犬、北塔守卒）及其状态驱动动画；
 * - 渲染四房可交互 3D 实景道具与剧情反馈：
 *   * outside：唯一化红布检修车（消除双车重叠）、木轮转动、左端固定红布、低拱铁栓脱落、远方塔灯；
 *   * village：瓶架陶瓶/飞行自旋陶瓶、铁盆冷月高光沿与受击阻尼颤动、硬砖/铁盆/软土声波环与碎屑、拾荒者视线锥；
 *   * forest：三处高草冷月剪影丛、四处枯枝堆与踩断木屑、溪湾水灯与水面波纹倒影、随走上溪岸自动让开的前景松枝；
 *   * tower：铰链于门框左侧的 3D 厚木门（叩门微颤 + 开门向室内旋转 96°）、值夜室暖灯倾泻、守卒提灯/写录、桌面登记簿与针套指南针。
 */

import { Color, Color3, DirectionalLight3D, DrawNode, Model3D, Node3D, PointLight3D, Vec2, Vec3 } from "Dora";
import { Play } from "Script/watch/play";

const PATH_SKY      = "assets/xiaoman3d/sky_backdrop.glb";
const PATH_SCAV     = "assets/xiaoman3d/scavenger.glb";
const PATH_DOG      = "assets/xiaoman3d/dog.glb";
const PATH_GUARD    = "assets/xiaoman3d/guard.glb";
const PATH_CART     = "assets/xiaoman3d/cart.glb";
const PATH_BOTTLE   = "assets/xiaoman3d/bottle.glb";
const PATH_BASIN    = "assets/xiaoman3d/basin.glb";
const PATH_DOOR     = "assets/xiaoman3d/door.glb";
const PATH_LANTERN  = "assets/xiaoman3d/lantern.glb";
const PATH_LEDGER   = "assets/xiaoman3d/ledger.glb";
const PATH_POUCH    = "assets/xiaoman3d/pouch.glb";
const PATH_LATCH    = "assets/xiaoman3d/latch.glb";
const PATH_GRASS    = "assets/xiaoman3d/grass.glb";
const PATH_TWIG     = "assets/xiaoman3d/twig.glb";
const PATH_BOUGH    = "assets/xiaoman3d/bough.glb";

const TWIG_OFFSETS: readonly number[] = [235, 455, 865, 1115];
const GRASS_CENTERS: readonly number[] = [340, 745, 1195];

interface EchoRing3D {
    x: number;
    z: number;
    age: number;
    duration: number;
    maxRadius: number;
    kind: "brick" | "iron" | "soft";
}

interface Shard3D {
    x: number;
    y: number;
    vx: number;
    vy: number;
    life: number;
    maxLife: number;
    color: Color.Type;
}

export interface Xiaoman3DEntitiesDebug {
    room: string;
    doorOpenFrac: number;
    basinShakeTimer: number;
    creekReveal: number;
    scavAnim: string;
    dogAnim: string;
    guardAnim: string;
    cartAnim: string;
    activeRings: number;
}

function mountModel(parent: Node3D.Type, path: string): Model3D.Type {
    const m = Model3D(path);
    if (m.parent !== undefined) {
        m.removeFromParent(false);
    }
    parent.addChild(m);
    m.visible = false;
    return m;
}

function clamp01(v: number): number {
    if (v <= 0) return 0;
    if (v >= 1) return 1;
    return v;
}

function smoothstep(e0: number, e1: number, x: number): number {
    const t = clamp01((x - e0) / Math.max(0.0001, e1 - e0));
    return t * t * (3 - 2 * t);
}

function drawGroundRing(draw: DrawNode.Type, cx: number, cy: number, radius: number, col: Color.Type, segs: number = 28): void {
    const pts: Vec2.Type[] = [];
    let i = 0;
    for (i = 0; i < segs; i++) {
        const a = (i / segs) * Math.PI * 2;
        pts.push(Vec2(cx + Math.cos(a) * radius, cy + Math.sin(a) * radius));
    }
    draw.drawPolygon(pts, Color(0, 0, 0, 0), 1.4, col);
}

export class Xiaoman3DEntities {
    private container = Node3D();

    // 全局暗黑写实光照（2 方向光 + 2 房间叙事点光源，总灯光含主角近身光共 5 盏）
    private moonLight = DirectionalLight3D();
    private fillLight = DirectionalLight3D();
    private roomLightA = PointLight3D();
    private roomLightB = PointLight3D();

    // 共享午夜天幕
    private sky: Model3D.Type | undefined;

    // Outside 城外
    private cart: Model3D.Type | undefined;
    private latch: Model3D.Type | undefined;
    private outsideLantern: Model3D.Type | undefined;
    private cartAnim = "";
    private prevCartAxle = 0;

    // Village 村口
    private scav: Model3D.Type | undefined;
    private shelfBottle: Model3D.Type | undefined;
    private airBottle: Model3D.Type | undefined;
    private basin: Model3D.Type | undefined;
    private scavAnim = "";
    private scavYaw = -80;
    private prevScavX = 0;
    private basinShakeTimer = 0;
    private prevBottleLandT = 0;

    // Forest 密林与溪湾
    private dog: Model3D.Type | undefined;
    private dogAnim = "";
    private dogYaw = -84;
    private prevDogX = 0;
    private creekLantern: Model3D.Type | undefined;
    private grasses: Model3D.Type[] = [];
    private twigs: Model3D.Type[] = [];
    private boughL: Model3D.Type | undefined;
    private boughR: Model3D.Type | undefined;
    private creekReveal = 0;
    private lastSnappedTwig = -1;

    // Tower 北塔
    private door: Model3D.Type | undefined;
    private guard: Model3D.Type | undefined;
    private towerLantern: Model3D.Type | undefined;
    private ledger: Model3D.Type | undefined;
    private pouch: Model3D.Type | undefined;
    private guardAnim = "";
    private doorOpenFrac = 0;

    // 运行态粒子与波纹
    private lastRoom = "";
    private time = 0;
    private rings: EchoRing3D[] = [];
    private shards: Shard3D[] = [];
    private animatedModels: Model3D.Type[] = [];

    constructor(root: Node3D.Type) {
        root.addChild(this.container);

        // 冷月主方向光（开启实时阴影）
        this.moonLight.color = Color3(135, 168, 214);
        this.moonLight.intensity = 1.35;
        this.moonLight.angles = Vec3(-44, -28, 0);
        this.moonLight.castShadow = true;
        this.moonLight.shadowBias = 0.0018;
        this.moonLight.shadowNormalBias = 0.028;
        this.moonLight.shadowSoftness = 1.6;
        this.container.addChild(this.moonLight);

        // 暗蓝灰环境补光（防止纯黑死块，凸显暗黑写实砖石/木纹法线立体感）
        this.fillLight.color = Color3(62, 82, 112);
        this.fillLight.intensity = 0.42;
        this.fillLight.angles = Vec3(28, 146, 0);
        this.fillLight.castShadow = false;
        this.container.addChild(this.fillLight);

        // 房间局部叙事光源
        this.roomLightA.color = Color3(255, 198, 112);
        this.roomLightA.intensity = 0;
        this.roomLightA.range = 4.0;
        this.container.addChild(this.roomLightA);

        this.roomLightB.color = Color3(156, 186, 224);
        this.roomLightB.intensity = 0;
        this.roomLightB.range = 3.0;
        this.container.addChild(this.roomLightB);
    }

    private registerAnimated(m: Model3D.Type): Model3D.Type {
        this.animatedModels.push(m);
        return m;
    }

    private hideAllEntities(): void {
        if (this.cart !== undefined) this.cart.visible = false;
        if (this.latch !== undefined) this.latch.visible = false;
        if (this.outsideLantern !== undefined) this.outsideLantern.visible = false;

        if (this.scav !== undefined) this.scav.visible = false;
        if (this.shelfBottle !== undefined) this.shelfBottle.visible = false;
        if (this.airBottle !== undefined) this.airBottle.visible = false;
        if (this.basin !== undefined) this.basin.visible = false;

        if (this.dog !== undefined) this.dog.visible = false;
        if (this.creekLantern !== undefined) this.creekLantern.visible = false;
        let i = 0;
        for (i = 0; i < this.grasses.length; i++) this.grasses[i].visible = false;
        for (i = 0; i < this.twigs.length; i++) this.twigs[i].visible = false;
        if (this.boughL !== undefined) this.boughL.visible = false;
        if (this.boughR !== undefined) this.boughR.visible = false;

        if (this.door !== undefined) this.door.visible = false;
        if (this.guard !== undefined) this.guard.visible = false;
        if (this.towerLantern !== undefined) this.towerLantern.visible = false;
        if (this.ledger !== undefined) this.ledger.visible = false;
        if (this.pouch !== undefined) this.pouch.visible = false;
    }

    hide(): void {
        this.setPaused(true);
    }

    setPaused(paused: boolean): void {
        let i = 0;
        for (i = 0; i < this.animatedModels.length; i++) {
            const m = this.animatedModels[i];
            if (paused) {
                if (!m.paused) m.pause();
            } else if (m.paused) {
                m.resume();
            }
        }
    }

    update(p: Play, dt: number, camX: number, glow: DrawNode.Type, groundFx: DrawNode.Type): void {
        const paused = p.paused || dt <= 0;
        const safeDt = paused ? 0 : Math.min(0.05, dt);
        this.setPaused(paused);
        if (!paused) {
            this.time += safeDt;
        }

        if (this.lastRoom !== p.room.key) {
            this.lastRoom = p.room.key;
            this.hideAllEntities();
            this.rings = [];
            this.shards = [];
            this.basinShakeTimer = 0;
            this.prevBottleLandT = 0;
            this.prevCartAxle = p.cartAxle;
            this.prevScavX = p.scavX;
            this.prevDogX = p.dogX;
            this.doorOpenFrac = p.towerDoorOpen ? 1 : 0;
            this.creekReveal = 0;
            this.lastSnappedTwig = -1;
        }

        // 午夜冷月天幕（随镜头视差移动，放在所有房间背墙之后 z=-4.5）
        if (this.sky === undefined) {
            this.sky = mountModel(this.container, PATH_SKY);
        }
        this.sky.visible = true;
        this.sky.position = Vec3(camX / 100, -0.3, -4.5);
        this.sky.scale = Vec3(1.15, 1.0, 1.0);

        // 按房间更新光照、实体与视觉反馈
        if (p.room.key === "outside") {
            this.updateOutside(p, safeDt);
        } else if (p.room.key === "village") {
            this.updateVillage(p, safeDt, groundFx);
        } else if (p.room.key === "forest") {
            this.updateForest(p, safeDt, glow, groundFx);
        } else if (p.room.key === "tower") {
            this.updateTower(p, safeDt);
        }

        // 推进与绘制地面声波环（3D 贴地透视）和空中碎屑
        this.stepAndDrawFx(safeDt, glow, groundFx);
    }

    // ---------------------------------------------------------------- Outside 城外栈台与墙根小路

    private updateOutside(p: Play, dt: number): void {
        const ox = p.ox / 100;

        // 暗黑写实海风月夜布光
        this.moonLight.color = Color3(144, 178, 224);
        this.moonLight.intensity = 1.68;
        this.moonLight.angles = Vec3(-44, -26, 0);
        this.fillLight.color = Color3(68, 92, 126);
        this.fillLight.intensity = 0.54;

        // 远端北塔微灯点光源（1120 处）
        const pulse = 0.92 + Math.sin(this.time * 2.4) * 0.08;
        this.roomLightA.color = Color3(255, 196, 108);
        this.roomLightA.intensity = 2.6 * pulse;
        this.roomLightA.range = 5.2;
        this.roomLightA.position = Vec3(ox + 11.20, 1.55, -0.75);

        // 红布车附近冷月聚焦补光，凸显左端补丁红布与下方拱口
        this.roomLightB.color = Color3(166, 192, 224);
        this.roomLightB.intensity = 1.05;
        this.roomLightB.range = 3.2;
        this.roomLightB.position = Vec3(p.cartAxle / 100, 1.65, 0.85);

        // 1. 主红布检修车（左端红布永远朝 -X，木轮按移动真实转动）
        const c = p.room.cart;
        if (c.bodyW > 0) {
            if (this.cart === undefined) {
                this.cart = this.registerAnimated(mountModel(this.container, PATH_CART));
            }
            this.cart.visible = true;
            this.cart.position = Vec3(p.cartAxle / 100, c.baseY / 100, -(c.depth ?? 0) / 100);
            this.cart.angles = Vec3(0, 0, 0);

            const rolling = Math.abs(p.cartAxle - this.prevCartAxle) > 0.04;
            this.prevCartAxle = p.cartAxle;
            const nextAnim = rolling ? "roll" : "idle";
            if (this.cartAnim !== nextAnim) {
                this.cartAnim = nextAnim;
                this.cart.play(nextAnim, true);
            }
            this.cart.speed = rolling ? 1.15 : 0.75;
        }

        // 2. 拱下联动铁栓（拉车落窝后自然移开）
        const latchBounds = p.cartLatchBounds();
        if (latchBounds !== undefined) {
            if (this.latch === undefined) {
                this.latch = mountModel(this.container, PATH_LATCH);
            }
            this.latch.visible = true;
            this.latch.position = Vec3((latchBounds.x + latchBounds.width * 0.5) / 100, latchBounds.y / 100, -0.52);
            this.latch.scale = Vec3(Math.max(0.7, latchBounds.width / 48), 1.0, 1.0);
        } else if (this.latch !== undefined) {
            this.latch.visible = false;
        }

        // 3. 墙根尽头的远望塔灯
        if (this.outsideLantern === undefined) {
            this.outsideLantern = mountModel(this.container, PATH_LANTERN);
        }
        this.outsideLantern.visible = true;
        this.outsideLantern.position = Vec3(ox + 11.20, 1.48, -0.95);
        this.outsideLantern.angles = Vec3(0, 0, Math.sin(this.time * 1.9) * 3.5);
    }

    // ---------------------------------------------------------------- Village 空村桌下与拾荒者

    private updateVillage(p: Play, dt: number, groundFx: DrawNode.Type): void {
        const ox = p.ox / 100;

        // 幽暗压迫冷月布光
        this.moonLight.color = Color3(132, 166, 214);
        this.moonLight.intensity = 1.48;
        this.moonLight.angles = Vec3(-52, -32, 0);
        this.fillLight.color = Color3(62, 80, 110);
        this.fillLight.intensity = 0.50;

        // 院门斜射月光聚焦在铁盆(548)、硬砖(608)与拾荒者靴底，确保暗处可读
        this.roomLightA.color = Color3(162, 194, 232);
        this.roomLightA.intensity = 1.95;
        this.roomLightA.range = 4.0;
        this.roomLightA.position = Vec3(ox + 5.75, 1.38, 0.45);

        // 瓶架侧微弱暖灰提示光
        this.roomLightB.color = Color3(212, 178, 134);
        this.roomLightB.intensity = 1.05;
        this.roomLightB.range = 2.5;
        this.roomLightB.position = Vec3(ox + 1.12, 0.85, 0.36);

        // 1. 瓶架上的陶瓶
        if (this.shelfBottle === undefined) {
            this.shelfBottle = mountModel(this.container, PATH_BOTTLE);
        }
        const showShelfBottle = !p.hasBottle && p.bottleFly === undefined && p.bottleLandT <= 0 && p.room.bottle !== undefined;
        this.shelfBottle.visible = showShelfBottle;
        if (showShelfBottle && p.room.bottle !== undefined) {
            const bx = Math.min(p.room.bottle.x, p.ox + 108) / 100;
            this.shelfBottle.position = Vec3(bx, 0.46, 0.06);
        }

        // 2. 空中抛物线旋转陶瓶
        if (this.airBottle === undefined) {
            this.airBottle = mountModel(this.container, PATH_BOTTLE);
        }
        if (p.bottleFly !== undefined) {
            this.airBottle.visible = true;
            const prog = clamp01(p.bottleFly.t / 0.62);
            const z = (-p.player.depth / 100) * (1 - prog);
            this.airBottle.position = Vec3(p.bottleFly.x / 100, p.bottleFly.y / 100, z);
            this.airBottle.angles = Vec3(this.time * 240, 0, -this.time * 540);
        } else {
            this.airBottle.visible = false;
        }

        // 检测本帧瓶子刚刚落地，触发对应材质 3D 视效反馈（硬砖 / 铁盆 / 软土）
        if (p.bottleLandT > this.prevBottleLandT + 0.1 && p.bottleLandX >= 0) {
            const lx = p.bottleLandX;
            const isSoft = p.room.softX !== undefined && Math.abs(lx - p.room.softX) <= 34;
            const isIron = p.room.basinX !== undefined && Math.abs(lx - p.room.basinX) <= 24;
            const kind: "brick" | "iron" | "soft" = isSoft ? "soft" : (isIron ? "iron" : "brick");
            this.spawnBottleImpactFx(lx, p.bottleLandY, kind);
            if (kind === "iron") {
                this.basinShakeTimer = 1.15;
            }
        }
        this.prevBottleLandT = p.bottleLandT;

        // 3. 铁盆（548 处）与金属余振阻尼颤动
        if (this.basin === undefined) {
            this.basin = mountModel(this.container, PATH_BASIN);
        }
        const basinX = (p.room.basinX !== undefined ? p.room.basinX : p.ox + 548) / 100;
        this.basin.visible = true;
        this.basin.position = Vec3(basinX, 0.095, -0.18);
        if (this.basinShakeTimer > 0) {
            this.basinShakeTimer = Math.max(0, this.basinShakeTimer - dt);
            const amp = (this.basinShakeTimer / 1.15);
            const wobble = amp * amp;
            this.basin.angles = Vec3(
                Math.sin(this.time * 48) * 14 * wobble,
                Math.sin(this.time * 24) * 6 * wobble,
                Math.cos(this.time * 42) * 16 * wobble,
            );
        } else {
            this.basin.angles = Vec3(0, 0, 0);
        }

        // 4. 暗黑拾荒者 3D 角色与脚底/鞋尖转向
        if (p.room.scavenger !== undefined) {
            if (this.scav === undefined) {
                this.scav = this.registerAnimated(mountModel(this.container, PATH_SCAV));
            }
            this.scav.visible = true;
            this.scav.position = Vec3(p.scavX / 100, p.room.scavenger.y / 100, 0.02);

            const dx = p.scavX - this.prevScavX;
            this.prevScavX = p.scavX;

            let desiredDir = p.scavDir;
            if (p.scavState === "turn" || p.scavState === "walk") {
                desiredDir = p.scavTargetX >= p.scavX ? 1 : -1;
            } else if (p.scavState === "chase") {
                desiredDir = p.player.x >= p.scavX ? 1 : -1;
            } else if (Math.abs(dx) > 0.02) {
                desiredDir = dx > 0 ? 1 : -1;
            }
            const targetYaw = desiredDir >= 0 ? 80 : -80;
            this.scavYaw += (targetYaw - this.scavYaw) * Math.min(1, dt * 10);
            this.scav.angles = Vec3(0, this.scavYaw, 0);

            let nextAnim = "idle";
            if (p.scavState === "chase") {
                nextAnim = "chase";
            } else if (p.scavState === "turn") {
                nextAnim = "turn";
            } else if (p.scavState === "walk" || p.scavState === "back" || (p.scavState === "patrol" && Math.abs(dx) > 0.01)) {
                nextAnim = "walk";
            } else {
                nextAnim = "idle";
            }
            if (this.scavAnim !== nextAnim) {
                this.scavAnim = nextAnim;
                this.scav.play(nextAnim, true);
            }

            // 地面微弱警戒视线扇形（仅作氛围可读，无卡通箭头）
            const lookDir = this.scavYaw >= 0 ? 1 : -1;
            const alert = p.scavState === "chase" || p.scavState === "turn";
            const coneCol = alert ? Color(188, 72, 54, 48) : Color(128, 152, 184, 28);
            const edgeCol = alert ? Color(214, 96, 68, 86) : Color(156, 182, 212, 52);
            const sx = p.scavX;
            const coneLen = alert ? 115 : 88;
            groundFx.drawPolygon([
                Vec2(sx, 0),
                Vec2(sx + lookDir * coneLen, -34),
                Vec2(sx + lookDir * coneLen, 34),
            ], coneCol, 0.8, edgeCol);
        }

        // 暗渠入口 (560..640) 微弱冷月水雾边线提示（自然环境引导）
        if (p.passed) {
            const pulse = 0.65 + 0.35 * Math.sin(this.time * 2.2);
            groundFx.drawPolygon([
                Vec2(p.ox + 566, -34),
                Vec2(p.ox + 634, -34),
                Vec2(p.ox + 634, -18),
                Vec2(p.ox + 566, -18),
            ], Color(92, 134, 154, Math.round(42 * pulse)), 1.0, Color(164, 206, 224, Math.round(96 * pulse)));
        }
    }

    private spawnBottleImpactFx(x: number, y: number, kind: "brick" | "iron" | "soft"): void {
        if (kind === "iron") {
            this.rings.push({ x, z: 0, age: 0, duration: 1.05, maxRadius: 96, kind });
            this.rings.push({ x, z: 0, age: -0.22, duration: 1.15, maxRadius: 122, kind });
        } else if (kind === "brick") {
            this.rings.push({ x, z: 0, age: 0, duration: 0.62, maxRadius: 68, kind });
        } else {
            this.rings.push({ x, z: 0, age: 0, duration: 0.45, maxRadius: 26, kind });
        }

        const count = kind === "soft" ? 5 : 9;
        const col = kind === "iron"
            ? Color(224, 232, 244, 220)
            : (kind === "brick" ? Color(204, 154, 108, 220) : Color(118, 98, 76, 170));
        let i = 0;
        for (i = 0; i < count; i++) {
            const frac = (i / count) - 0.5;
            this.shards.push({
                x: x + frac * 10,
                y: y + 4,
                vx: frac * (kind === "soft" ? 45 : 135),
                vy: (kind === "soft" ? 48 : 115) + (i % 3) * 28,
                life: 0,
                maxLife: kind === "soft" ? 0.35 : 0.48,
                color: col,
            });
        }
    }

    // ---------------------------------------------------------------- Forest 北塔森林与溪湾

    private updateForest(p: Play, dt: number, glow: DrawNode.Type, groundFx: DrawNode.Type): void {
        const ox = p.ox / 100;

        // 寒夜松林雾月光
        this.moonLight.color = Color3(126, 168, 198);
        this.moonLight.intensity = 1.52;
        this.moonLight.angles = Vec3(-46, -24, 0);
        this.fillLight.color = Color3(56, 84, 98);
        this.fillLight.intensity = 0.52;

        // 溪湾水灯暖光（1224 处）
        const flick = 0.90 + Math.sin(this.time * 3.6) * 0.06 + Math.cos(this.time * 6.1) * 0.04;
        this.roomLightA.color = Color3(255, 198, 112);
        this.roomLightA.intensity = 2.9 * flick;
        this.roomLightA.range = 5.4;
        this.roomLightA.position = Vec3(ox + 12.24, 0.72, -0.62);

        // 森林中段冷月林隙光（照亮猎犬剪影与旧渠）
        this.roomLightB.color = Color3(144, 184, 214);
        this.roomLightB.intensity = 1.15;
        this.roomLightB.range = 4.6;
        this.roomLightB.position = Vec3(ox + 7.45, 1.85, 0.65);

        // 1. 3D 暗林猎犬（竖耳/追击/嗅探动画）
        if (this.dog === undefined) {
            this.dog = this.registerAnimated(mountModel(this.container, PATH_DOG));
        }
        this.dog.visible = true;
        this.dog.position = Vec3(p.dogX / 100, 0.0, -0.06);

        const ddx = p.dogX - this.prevDogX;
        this.prevDogX = p.dogX;
        let dogDir = this.dogYaw >= 0 ? 1 : -1;
        if (p.dogState === "chase" || p.dogState === "ear") {
            dogDir = p.player.x >= p.dogX ? 1 : -1;
        } else if (Math.abs(ddx) > 0.02) {
            dogDir = ddx > 0 ? 1 : -1;
        }
        const targetDogYaw = dogDir >= 0 ? 84 : -84;
        this.dogYaw += (targetDogYaw - this.dogYaw) * Math.min(1, dt * 12);
        this.dog.angles = Vec3(0, this.dogYaw, 0);

        let nextDogAnim = "walk";
        if (p.dogState === "ear") {
            nextDogAnim = "ear";
        } else if (p.dogState === "chase") {
            nextDogAnim = "chase";
        } else if (p.dogState === "sniff") {
            nextDogAnim = "sniff";
        } else if (Math.abs(ddx) > 0.01) {
            nextDogAnim = "walk";
        } else {
            nextDogAnim = "idle";
        }
        if (this.dogAnim !== nextDogAnim) {
            this.dogAnim = nextDogAnim;
            this.dog.play(nextDogAnim, true);
        }

        // 2. 三处高草丛（前后双层营造暗黑冷月草丛层次，与 rooms.ts 300-380 / 700-790 / 1150-1240 同源）
        if (this.grasses.length === 0) {
            let gIdx = 0;
            for (gIdx = 0; gIdx < GRASS_CENTERS.length * 2; gIdx++) {
                this.grasses.push(mountModel(this.container, PATH_GRASS));
            }
        }
        let gi = 0;
        for (gi = 0; gi < GRASS_CENTERS.length; gi++) {
            const gx = ox + GRASS_CENTERS[gi] / 100;
            const sway = Math.sin(this.time * 1.8 + gi * 1.4) * 2.5;
            const fgGrass = this.grasses[gi * 2];
            fgGrass.visible = true;
            fgGrass.position = Vec3(gx, 0.0, 0.36);
            fgGrass.angles = Vec3(0, 0, sway);
            fgGrass.scale = Vec3(1.12, 1.0, 1.0);

            const bgGrass = this.grasses[gi * 2 + 1];
            bgGrass.visible = true;
            bgGrass.position = Vec3(gx + 0.08, 0.0, -0.48);
            bgGrass.angles = Vec3(0, 180, -sway * 0.7);
            bgGrass.scale = Vec3(1.18, 1.15, 1.0);
        }

        // 3. 四处林径枯枝堆 + 踩断木屑反馈
        if (this.twigs.length === 0) {
            let ti = 0;
            for (ti = 0; ti < TWIG_OFFSETS.length; ti++) {
                this.twigs.push(mountModel(this.container, PATH_TWIG));
            }
        }
        let curTwig = -1;
        let ti = 0;
        for (ti = 0; ti < TWIG_OFFSETS.length; ti++) {
            const tx = p.ox + TWIG_OFFSETS[ti];
            const m = this.twigs[ti];
            m.visible = true;
            m.position = Vec3(tx / 100, 0.005, 0.06);
            m.angles = Vec3(0, ti * 35, 0);
            if (!p.player.crouch && p.player.y <= 8 && Math.abs(p.player.x - tx) <= 18
                && (Math.abs(p.player.vx) > 10 || Math.abs(p.player.depthSpeed) > 10)) {
                curTwig = ti;
            }
        }
        if (curTwig >= 0 && curTwig !== this.lastSnappedTwig) {
            const tx = p.ox + TWIG_OFFSETS[curTwig];
            let k = 0;
            for (k = 0; k < 6; k++) {
                const f = (k / 6) - 0.5;
                this.shards.push({
                    x: tx + f * 12,
                    y: 4,
                    vx: f * 92,
                    vy: 68 + (k % 3) * 24,
                    life: 0,
                    maxLife: 0.42,
                    color: Color(162, 134, 98, 220),
                });
            }
        }
        this.lastSnappedTwig = curTwig;

        // 4. 溪湾石墩暖灯 + 流动水面碎灯倒影（停步流动、暂停冻结）
        if (this.creekLantern === undefined) {
            this.creekLantern = mountModel(this.container, PATH_LANTERN);
        }
        this.creekLantern.visible = true;
        this.creekLantern.position = Vec3(ox + 12.24, 0.48, -0.74);
        this.creekLantern.angles = Vec3(0, 0, Math.sin(this.time * 1.6) * 2.8);

        const lampX = p.ox + 1224;
        let ri = 0;
        for (ri = 0; ri < 4; ri++) {
            const phase = this.time * 2.1 + ri * 1.3;
            const sx = Math.sin(phase) * (4 + ri * 2.5);
            const w = 22 - ri * 3.5;
            const a = Math.round(135 - ri * 26);
            groundFx.drawEllipse(Vec2(lampX + sx, -26 + ri * 14), w, 2.2, Color(246, 214, 146, a));
        }
        glow.drawEllipse(Vec2(lampX + Math.sin(this.time * 1.7) * 3, 2), 20, 2.6, Color(242, 214, 148, 128));

        // 5. 溪岸前景垂枝：随玩家走上溪岸 (1310 -> 1435) 自然向两侧让开，露出远方北塔灯火
        if (this.boughL === undefined) {
            this.boughL = mountModel(this.container, PATH_BOUGH);
            this.boughR = mountModel(this.container, PATH_BOUGH);
        }
        const targetReveal = smoothstep(p.ox + 1310, p.ox + 1435, p.player.x);
        this.creekReveal += (targetReveal - this.creekReveal) * Math.min(1, dt * 4.5 + (dt === 0 ? 0 : 0));
        const swayB = Math.sin(this.time * 1.4) * 2.2;
        this.boughL.visible = true;
        this.boughL.position = Vec3(ox + 13.15 - this.creekReveal * 1.15, 1.56 + this.creekReveal * 0.36, 1.15);
        this.boughL.angles = Vec3(0, 8, -8 + this.creekReveal * 16 + swayB);

        if (this.boughR !== undefined) {
            this.boughR.visible = true;
            this.boughR.position = Vec3(ox + 14.35 + this.creekReveal * 1.15, 1.48 + this.creekReveal * 0.40, 1.08);
            this.boughR.angles = Vec3(0, 172, 10 - this.creekReveal * 18 - swayB);
        }
    }

    // ---------------------------------------------------------------- Tower 北塔塔门与值夜室

    private updateTower(p: Play, dt: number): void {
        const ox = p.ox / 100;
        const doorX = (p.room.story?.tower?.doorX ?? p.ox + 445) / 100;

        // 塔外寒夜冷月 vs 室内值夜暖灯强烈冷暖对比
        this.moonLight.color = Color3(126, 158, 208);
        this.moonLight.intensity = 1.32;
        this.moonLight.angles = Vec3(-42, -34, 0);
        this.fillLight.color = Color3(62, 80, 108);
        this.fillLight.intensity = 0.48;

        const targetOpen = p.towerDoorOpen ? 1 : 0;
        this.doorOpenFrac += (targetOpen - this.doorOpenFrac) * Math.min(1, dt * 4.8);
        if (Math.abs(targetOpen - this.doorOpenFrac) < 0.005) {
            this.doorOpenFrac = targetOpen;
        }

        const lampPulse = 0.94 + Math.sin(this.time * 2.8) * 0.06;
        // 值夜室暖灯：开门时暖光大幅增强并漫出石门槛
        this.roomLightA.color = Color3(255, 196, 106);
        this.roomLightA.intensity = (1.55 + this.doorOpenFrac * 2.15) * lampPulse;
        this.roomLightA.range = 5.4;
        this.roomLightA.position = Vec3(ox + 6.26, 0.72, -0.05);

        // 门廊溢出的暖黄门缝光
        this.roomLightB.color = Color3(255, 204, 122);
        this.roomLightB.intensity = (1.35 + this.doorOpenFrac * 0.65) * lampPulse;
        this.roomLightB.range = 3.0;
        this.roomLightB.position = Vec3(doorX, 1.05, 0.55);

        // 门扇和门槛共用 X 位置，贴在剖视边前，避免被塔墙挡住。
        if (this.door === undefined) {
            this.door = mountModel(this.container, PATH_DOOR);
        }
        this.door.visible = true;
        this.door.position = Vec3(doorX - 0.10, 0.0, 0.12);
        this.door.scale = Vec3(0.90, 1.0, 1.0);
        const knockJitter = p.phase === "tower-knock" ? Math.sin(this.time * 36) * 2.2 : 0;
        this.door.angles = Vec3(0, -this.doorOpenFrac * 96 + knockJitter, 0);

        // 2. 值夜灯、登记簿、针套指南针、北塔守卒
        if (this.towerLantern === undefined) {
            this.towerLantern = mountModel(this.container, PATH_LANTERN);
        }
        this.towerLantern.visible = true;
        this.towerLantern.position = Vec3(ox + 6.38, 0.32, -0.18);

        if (this.ledger === undefined) {
            this.ledger = mountModel(this.container, PATH_LEDGER);
        }
        this.ledger.visible = true;
        this.ledger.position = Vec3(ox + 6.06, 0.32, -0.04);
        this.ledger.angles = Vec3(0, -10, 0);

        if (this.pouch === undefined) {
            this.pouch = mountModel(this.container, PATH_POUCH);
        }
        this.pouch.visible = p.deskHold >= 12 || p.towerHanded;
        this.pouch.position = Vec3(ox + 5.78, 0.32, 0.08);
        this.pouch.angles = Vec3(0, 14, 0);

        if (this.guard === undefined) {
            this.guard = this.registerAnimated(mountModel(this.container, PATH_GUARD));
        }
        this.guard.visible = this.doorOpenFrac > 0.08 || p.towerDoorOpen;
        this.guard.position = Vec3(ox + 6.50, 0.0, -0.16);
        this.guard.angles = Vec3(0, -72, 0);

        const writing = p.deskHold >= 24 || p.towerHanded;
        const nextGuardAnim = writing ? "write" : "lantern";
        if (this.guardAnim !== nextGuardAnim) {
            this.guardAnim = nextGuardAnim;
            this.guard.play(nextGuardAnim, true);
        }
    }

    // ---------------------------------------------------------------- 3D 地面波纹与碎屑更新绘制

    private stepAndDrawFx(dt: number, glow: DrawNode.Type, groundFx: DrawNode.Type): void {
        const aliveRings: EchoRing3D[] = [];
        let i = 0;
        for (i = 0; i < this.rings.length; i++) {
            const r = this.rings[i];
            r.age += dt;
            if (r.age < r.duration) {
                aliveRings.push(r);
                if (r.age >= 0) {
                    const prog = clamp01(r.age / r.duration);
                    const rad = 8 + prog * r.maxRadius;
                    const alpha = Math.round((1 - prog) * (r.kind === "iron" ? 210 : (r.kind === "brick" ? 170 : 95)));
                    const col = r.kind === "iron"
                        ? Color(216, 232, 248, alpha)
                        : (r.kind === "brick" ? Color(224, 198, 152, alpha) : Color(138, 122, 100, alpha));
                    drawGroundRing(groundFx, r.x, r.z, rad, col, 28);
                }
            }
        }
        this.rings = aliveRings;

        const aliveShards: Shard3D[] = [];
        for (i = 0; i < this.shards.length; i++) {
            const s = this.shards[i];
            s.life += dt;
            if (s.life < s.maxLife) {
                s.x += s.vx * dt;
                s.y = Math.max(0, s.y + s.vy * dt);
                s.vy -= 480 * dt;
                aliveShards.push(s);
                const sz = 2.2 * (1 - s.life / s.maxLife);
                glow.drawDot(Vec2(s.x, s.y), Math.max(0.8, sz), s.color);
            }
        }
        this.shards = aliveShards;
    }

    getDebugState(): Xiaoman3DEntitiesDebug {
        return {
            room: this.lastRoom,
            doorOpenFrac: this.doorOpenFrac,
            basinShakeTimer: this.basinShakeTimer,
            creekReveal: this.creekReveal,
            scavAnim: this.scavAnim,
            dogAnim: this.dogAnim,
            guardAnim: this.guardAnim,
            cartAnim: this.cartAnim,
            activeRings: this.rings.length,
        };
    }
}
