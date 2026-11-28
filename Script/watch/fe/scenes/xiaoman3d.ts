/**
 * 《向西守望》小满单人线真 3D 主场景控制器（xiaoman3d.ts）。
 *
 * 视觉对比与空间分工：
 * - 场景建筑（outside/village/forest/tower.glb）与 NPC/道具采用暗黑写实 PBR 材质 + 实时阴影冷月光 + 叙事暖灯；
 * - 主角小满采用亮色纯体素 3D 角色（xiaoman.glb，含 13 套骨骼动画），支持 W/A/S/D 四向纵深行走与正/背/左/右全角度展示；
 * - 保持与 rooms.ts / Play 碰撞判定与 worldToScreen / screenToWorld 严格互逆（0.00 px 投瓶与拾取误差）。
 */

import { Camera3D, Color, Director, DrawNode, Model3D, Node, Node3D, Size, Surface3D, Vec2, Vec3, View } from "Dora";
import { BOTTLE_FLY_TIME, BottlePoint, GRAVITY, Play } from "Script/watch/play";
import { StageViewport } from "Script/watch/platform";
import { CameraDirector, WorldProjection } from "Script/watch/fe/camera";
import { ActorsRenderer } from "Script/watch/fe/renderer/actors";
import { Xiaoman3DActor, Xiaoman3DActorDebug } from "Script/watch/fe/scenes/xiaoman3d_actor";
import { BASIN_DEPTH, BASIN_BASE_HEIGHT, Xiaoman3DEntities, Xiaoman3DEntitiesDebug } from "Script/watch/fe/scenes/xiaoman3d_entities";

const ROOM_MODELS: Record<string, string> = {
    outside: "assets/xiaoman3d/outside.glb",
    village: "assets/xiaoman3d/village.glb",
    forest: "assets/xiaoman3d/forest.glb",
    tower: "assets/xiaoman3d/tower.glb",
};

interface View3DLike {
    setEnvironmentMap?: (path: string) => boolean;
    setEnvironmentIntensity?: (diffuse: number, specular: number, exposure?: number) => void;
    shadowMapSize?: number;
    stats?: { drawCalls: number; triangles: number; models: number; visibleModels: number };
}

export interface Xiaoman3DDebugState {
    active: boolean;
    room: string;
    actor: Xiaoman3DActorDebug;
    entities: Xiaoman3DEntitiesDebug;
    cameraPos: { x: number; y: number; z: number };
    drawCalls: number;
    visibleModels: number;
}

function getView3D(): View3DLike {
    return Director.entry as unknown as View3DLike;
}

function rayInterval(origin: number, slope: number, low: number, high: number): { min: number; max: number } {
    if (Math.abs(slope) < 0.000001) {
        return { min: origin >= low && origin <= high ? -Infinity : Infinity, max: Infinity };
    }
    const first = (low - origin) / slope;
    const last = (high - origin) / slope;
    return { min: Math.min(first, last), max: Math.max(first, last) };
}

/** GLB coordinates stay Y-up. Collision and interaction authority stays in rooms.ts/Play. */
export class Xiaoman3DScene implements WorldProjection {
    private root = Node3D();
    private camera = Camera3D("xiaoman-follow");
    private model: Model3D.Type | undefined;
    private room = "";
    private active = false;
    private envConfigured = false;

    private actor: Xiaoman3DActor;
    private entities: Xiaoman3DEntities;

    private glow = DrawNode();
    private effects: Surface3D.Type;
    private groundFx = DrawNode();
    private groundSurface: Surface3D.Type;
    private shadows: Record<string, Surface3D.Type> = {};

    private p: Play | undefined;
    private focal = 1;
    private stageX = 0;
    private stageY = 0;
    private fullW = 1280;
    private fullH = 720;
    private pitchSin = 0;
    private pitchCos = 1;
    private cameraX = 0;
    private cameraY = 0;
    private cameraZ = 0;
    private time = 0;

    constructor(host: Node.Type) {
        Director.entry.addChild(this.root);
        this.root.visible = false;

        this.actor = new Xiaoman3DActor(this.root);
        this.entities = new Xiaoman3DEntities(this.root);

        // 垂直世界特效层（投瓶抛物线预览点、空中碎屑）
        const content = Node();
        content.addChild(this.glow);
        const effects = Surface3D(content, Size(20, 5), Size(2000, 500));
        if (effects === undefined) error("Surface3D effects creation failed");
        effects.scaleX = -1;
        this.effects = effects;
        this.root.addChild(effects);

        // 水平贴地特效层（声波扩散环、拾荒者视线扇形、溪湾碎灯波纹）
        const gContent = Node();
        gContent.addChild(this.groundFx);
        const gSurf = Surface3D(gContent, Size(20, 4), Size(2000, 400));
        if (gSurf === undefined) error("Surface3D groundFx creation failed");
        gSurf.angles = Vec3(90, 0, 0);
        gSurf.scaleX = -1;
        this.groundSurface = gSurf;
        this.root.addChild(gSurf);

        host.onCleanup(() => {
            this.hide();
            this.root.removeFromParent();
        });
    }

    supports(p: Play, visualMode: string): boolean {
        return visualMode === "lowpoly" && ROOM_MODELS[p.room.key] !== undefined;
    }

    private configureEnvironment(): void {
        if (this.envConfigured) {
            return;
        }
        const v3 = getView3D();
        if (v3.setEnvironmentMap !== undefined) {
            v3.setEnvironmentMap("");
        }
        if (v3.setEnvironmentIntensity !== undefined) {
            // 压低环境底光，让暗黑写实场景拥有深邃阴影与高反差冷暖光影，同时保留砖石木纹暗部层次
            v3.setEnvironmentIntensity(0.24, 0.18, 1.02);
        }
        v3.shadowMapSize = 1024;
        this.envConfigured = true;
    }

    private restoreEnvironment(): void {
        if (!this.envConfigured) {
            return;
        }
        const v3 = getView3D();
        if (v3.setEnvironmentIntensity !== undefined) {
            v3.setEnvironmentIntensity(1.0, 1.0, 1.0);
        }
        this.envConfigured = false;
    }

    hide(): void {
        if (this.p !== undefined) this.p.bottleMapper = undefined;
        this.root.visible = false;
        this.actor.hide();
        this.entities.hide();
        this.restoreEnvironment();
        if (this.active) {
            Director.removeCamera(this.camera);
            this.active = false;
        }
    }

    render(p: Play, cam: CameraDirector, actors: ActorsRenderer, dt: number, w: number, h: number, vp: StageViewport, overlay: DrawNode.Type): void {
        this.p = p;
        const safeDt = p.paused ? 0 : dt;
        this.time += safeDt;

        if (this.room !== p.room.key) {
            if (this.model !== undefined) {
                this.root.removeChild(this.model);
                this.model = undefined;
            }
            const loaded = Model3D(ROOM_MODELS[p.room.key]);
            if (loaded.parent !== undefined) {
                loaded.removeFromParent(false);
            }
            this.model = loaded;
            this.root.addChild(loaded);
            this.room = p.room.key;
        }

        // 特效画布以房间中点为中心，覆盖整个房间跨度
        const centerX = (p.room.minX + p.room.maxX) / 2;
        this.glow.x = -centerX;
        this.effects.position = Vec3(centerX / 100, 0, -p.player.depth / 100 + 0.02);
        this.groundFx.x = -centerX;
        this.groundFx.y = 0;
        this.groundSurface.position = Vec3(centerX / 100, 0.015, 0);

        if (this.model !== undefined) {
            this.model.position = Vec3(p.ox / 100, 0, 0);
        }

        this.configureEnvironment();
        if (!this.active) {
            Director.pushCamera(this.camera);
            this.active = true;
        }
        this.root.visible = true;

        this.updateCamera(p, cam, w, h, vp);
        cam.projection = this;
        if (p.room.key === "village") p.bottleMapper = this.villageBottlePoint;

        this.glow.clear();
        this.groundFx.clear();

        // 贴地接触影（配合主方向光实时阴影，让脚底落地感更稳）
        for (const key in this.shadows) {
            this.shadows[key].visible = false;
        }
        const a = p.player;
        if (a.alive) {
            const ground = actors.supportGroundY(p, a);
            this.placeShadow("child", a.x, ground, a.depth, a.w * 0.56, 10,
                Math.max(0.24, 0.92 - (a.y - ground) / 170));
        }
        if (p.room.scavenger !== undefined) {
            this.placeShadow("scavenger", p.scavX, p.room.scavenger.y, 0, 17, 10, 0.85);
        }
        if (p.room.key === "forest") {
            this.placeShadow("dog", p.dogX, 0, 6, 20, 9, 0.82);
        }

        // 更新 3D 体素主角小满 + 暗黑写实 3D NPC / 动态道具 / 光照
        this.actor.update(p, safeDt);
        this.entities.update(p, safeDt, cam.x, this.glow, this.groundFx, overlay, this);

        this.drawBottleAimPreview(p, overlay);
    }

    private drawBottleAimPreview(p: Play, overlay: DrawNode.Type): void {
        if (!p.hasBottle || p.aimHold <= 0 || p.bottleAimX < 0) {
            return;
        }
        const endX = p.bottleAimX;
        const endY = p.bottleAimY;
        const x0 = p.player.x + (endX >= p.player.x ? 10 : -10);
        const y0 = p.player.y + p.player.h * 0.7;
        const duration = BOTTLE_FLY_TIME;
        const vx = (endX - x0) / duration;
        const vy = (endY - y0 + 0.5 * GRAVITY * duration * duration) / duration;
        let i = 1;
        for (i = 1; i <= 18; i++) {
            const t = (i / 18) * duration;
            const depth = p.player.depth + (p.bottleAimDepth - p.player.depth) * (t / duration);
            const x = x0 + vx * t;
            const y = y0 + vy * t - 0.5 * GRAVITY * t * t;
            const pt = this.worldToScreen(x, y, depth);
            const edge = this.worldToScreen(x + 1.4, y, depth);
            overlay.drawDot(Vec2(pt.x, pt.y), edge.x - pt.x, Color(246, 220, 152, 224));
        }
        const end = this.worldToScreen(endX, endY, p.bottleAimDepth);
        const radius = this.worldToScreen(endX + 9, endY, p.bottleAimDepth).x - end.x;
        overlay.drawEllipse(Vec2(end.x, end.y), radius, radius * 0.27, Color(246, 220, 152, 190));
    }

    private placeShadow(key: string, x: number, y: number, depth: number, rx: number, rz: number, opacity: number = 1): void {
        let surface = this.shadows[key];
        if (surface === undefined) {
            const content = DrawNode();
            content.drawCircle(Vec2(0, 0), 50, Color(8, 10, 14, 138));
            const created = Surface3D(content, Size(1, 1), Size(100, 100));
            if (created === undefined) error("Surface3D shadow creation failed");
            surface = created;
            surface.angles = Vec3(90, 0, 0);
            this.root.addChild(surface);
            this.shadows[key] = surface;
        }
        surface.visible = true;
        surface.content.opacity = opacity;
        surface.scale = Vec3(rx / 50, rz / 50, 1);
        surface.position = Vec3(x / 100, (y + 0.7) / 100, -depth / 100);
    }

    private updateCamera(p: Play, cam: CameraDirector, w: number, h: number, vp: StageViewport): void {
        this.fullW = View.size.width;
        this.fullH = View.size.height;
        this.stageX = vp.stageX;
        this.stageY = vp.stageY;
        this.focal = this.fullH / (2 * Math.tan(View.fieldOfView * Math.PI / 360));

        // 略微按房间调整俯仰与视距：空村桌下压低机位增强压迫感，北塔居中对准门廊与值夜室避免左侧塔墙遮挡
        const baseDist = p.room.key === "village" ? 3.90 : (p.room.key === "tower" ? 4.10 : 4.25);
        const riseRatio = p.room.key === "village" ? 0.16 : 0.21;
        const baseTargetY = p.room.key === "village" ? 0.68 : 0.82;

        const distance = baseDist / cam.zoom * this.fullH / h;
        const rise = distance * riseRatio;
        const length = Math.sqrt(distance * distance + rise * rise);
        this.pitchSin = rise / length;
        this.pitchCos = distance / length;

        const offsetX = (vp.stageX + w / 2 - this.fullW / 2) * length / this.focal;
        const offsetY = (vp.stageY + h / 2 - this.fullH / 2) * length / this.focal;
        const towerDoor = p.room.story?.tower;
        let focusWorldX = cam.x / 100;
        if (towerDoor !== undefined) {
            const doorX = towerDoor.doorX;
            // 从门外构图逐步接到值夜桌。入场与开门时让小满和门扇同框。
            const across = Math.max(0, Math.min(1, (p.player.x - doorX) / 95));
            focusWorldX = (p.player.x + doorX) / 200 + 0.74 * across;
        }
        const tx = focusWorldX - offsetX;
        const ty = baseTargetY + (cam.y - 82) * 0.0045 - offsetY * this.pitchCos;
        // 镜头深度温和跟随小满前后纵深，凸显 3D 空间透视且不打乱互逆投影
        const tz = -p.player.depth * 0.0035 + offsetY * this.pitchSin;

        this.cameraX = tx;
        this.cameraY = ty + rise;
        this.cameraZ = tz + distance;
        this.camera.lookAt(Vec3(this.cameraX, this.cameraY, this.cameraZ), Vec3(tx, ty, tz));
    }

    worldToScreen(x: number, y: number, depth: number = 0): { x: number; y: number } {
        const dx = x / 100 - this.cameraX;
        const dy = y / 100 - this.cameraY;
        const dz = -depth / 100 - this.cameraZ;
        const forward = -dy * this.pitchSin - dz * this.pitchCos;
        return {
            x: this.fullW / 2 + dx * this.focal / forward - this.stageX,
            y: this.fullH / 2 + (dy * this.pitchCos - dz * this.pitchSin) * this.focal / forward - this.stageY,
        };
    }

    screenToWorld(x: number, y: number, depth: number = this.p?.player.depth ?? 0): { x: number; y: number } {
        const u = (x + this.stageX - this.fullW / 2) / this.focal;
        const v = (y + this.stageY - this.fullH / 2) / this.focal;
        const rayY = v * this.pitchCos - this.pitchSin;
        const rayZ = -v * this.pitchSin - this.pitchCos;
        const z = -depth / 100;
        const t = (z - this.cameraZ) / rayZ;
        return { x: (this.cameraX + u * t) * 100, y: (this.cameraY + rayY * t) * 100 };
    }

    // 同一屏幕射线与两个纵深平面的交点定义 x(depth)、y(depth)，沿光线取最近的村口表面。
    private villageBottlePoint = (sx: number, sy: number): BottlePoint => {
        const p = this.p!;
        const mid = this.screenToWorld(sx, sy, 0);
        const far = this.screenToWorld(sx, sy, 100);
        const dx = (far.x - mid.x) / 100;
        const dy = (far.y - mid.y) / 100;
        // anchors_village 的院土地面纵深 ±2 m；指向地平线上方时投向院落远沿。
        let depth = dy < -0.000001 ? Math.max(-200, Math.min(200, -mid.y / dy)) : 200;
        let height = 0;
        let hitBasin = false;
        const brickX = p.room.brickX;
        if (brickX !== undefined) {
            // 砖地实体从 brickX 到右墙，高 2，纵深 ±90；侧面和顶面均可瞄。
            const xs = rayInterval(mid.x, dx, brickX, p.room.maxX);
            const ys = rayInterval(mid.y, dy, 0, 2);
            const near = Math.max(-90, xs.min, ys.min);
            if (near <= Math.min(90, xs.max, ys.max, depth) + 0.000001) {
                depth = near;
                height = Math.max(0, Math.min(2, mid.y + dy * depth));
            }
        }
        const bx = p.room.basinX;
        if (bx !== undefined) {
            // 地图的圆形盆座接在活动盆身下。两段的高度与半径均以游戏单位计。
            const ox = mid.x - bx;
            const a = dx * dx + 1;
            const b = ox * dx - BASIN_DEPTH;
            const intersectBasin = (radius: number, bottom: number, top: number): void => {
                const disc = b * b - a * (ox * ox + BASIN_DEPTH * BASIN_DEPTH - radius * radius);
                if (disc < 0) return;
                const span = Math.sqrt(disc);
                const ys = rayInterval(mid.y, dy, bottom, top);
                const near = Math.max((-b - span) / a, ys.min);
                if (near <= Math.min((-b + span) / a, ys.max, depth) + 0.000001) {
                    depth = near;
                    height = Math.max(bottom, Math.min(top, mid.y + dy * depth));
                    hitBasin = true;
                }
            };
            intersectBasin(19, 0, 10);
            intersectBasin(16.8, BASIN_BASE_HEIGHT, BASIN_BASE_HEIGHT + 11.2);
        }
        return { x: mid.x + dx * depth, y: height, depth, hitBasin };
    };

    getDebugState(): Xiaoman3DDebugState {
        const v3 = getView3D();
        const stats = v3.stats;
        return {
            active: this.active,
            room: this.room,
            actor: this.actor.getDebugState(this.p),
            entities: this.entities.getDebugState(),
            cameraPos: { x: this.cameraX, y: this.cameraY, z: this.cameraZ },
            drawCalls: stats !== undefined ? stats.drawCalls : 0,
            visibleModels: stats !== undefined ? stats.visibleModels : 0,
        };
    }
}
