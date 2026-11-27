import { Camera3D, Color, Color3, Director, DirectionalLight3D, DrawNode, Model3D, Node, Node3D, Rect, Size, Sprite, Surface3D, Vec2, Vec3, View } from "Dora";
import { GRAVITY, Play } from "Script/watch/play";
import { DEPTH_Y_SCALE } from "Script/watch/depth";
import { StageViewport } from "Script/watch/platform";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector, WorldProjection } from "Script/watch/fe/camera";
import { ActorsRenderer } from "Script/watch/fe/renderer/actors";

const ROOM_MODELS: Record<string, string> = {
    outside: "assets/xiaoman3d/outside.glb",
    village: "assets/xiaoman3d/village.glb",
    forest: "assets/xiaoman3d/forest.glb",
    tower: "assets/xiaoman3d/tower.glb",
};

/** GLB coordinates stay Y-up. Collision and interaction authority stays in rooms.ts/Play. */
export class Xiaoman3DScene implements WorldProjection {
    private root = Node3D();
    private camera = Camera3D("xiaoman-follow");
    private model: Model3D.Type | undefined;
    private room = "";
    private active = false;
    private surfaces: Record<string, Surface3D.Type> = {};
    private shadows: Record<string, Surface3D.Type> = {};
    private assets: AssetSlotHost;
    private localCam = new CameraDirector();
    private scratch = DrawNode();
    private glow = DrawNode();
    private effects: Surface3D.Type;
    private p: Play | undefined;
    private depths: Record<string, number> = {};
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
        const sun = DirectionalLight3D();
        sun.color = Color3(229, 233, 242);
        sun.intensity = 2.2;
        sun.angles = Vec3(-48, -25, 0);
        this.root.addChild(sun);
        const fill = DirectionalLight3D();
        fill.color = Color3(210, 216, 226);
        fill.intensity = 0.8;
        fill.angles = Vec3(35, 150, 0);
        this.root.addChild(fill);
        const content = Node();
        content.addChild(this.glow);
        const effects = Surface3D(content, Size(20, 5), Size(2000, 500));
        if (effects === undefined) error("Surface3D effects creation failed");
        effects.scaleX = -1;
        this.effects = effects;
        this.root.addChild(effects);
        this.assets = new AssetSlotHost(Node(), 0, (sprite, key, instance, x, y) => this.placeSprite(sprite, key, instance, x, y));
        // Draw existing animation selection in game units, then move each sprite into shared depth.
        this.localCam.x = 0;
        this.localCam.y = 82;
        this.localCam.viewW = 0;
        this.localCam.ppu = 1;
        this.localCam.groundScreenY = 0;
        host.onCleanup(() => {
            this.hide();
            this.root.removeFromParent();
        });
    }

    supports(p: Play, visualMode: string): boolean {
        return visualMode === "lowpoly" && ROOM_MODELS[p.room.key] !== undefined;
    }

    hide(): void {
        this.root.visible = false;
        if (this.active) {
            Director.removeCamera(this.camera);
            this.active = false;
        }
    }

    render(p: Play, cam: CameraDirector, actors: ActorsRenderer, dt: number, w: number, h: number, vp: StageViewport): void {
        this.p = p;
        this.time += dt;
        if (this.room !== p.room.key) {
            if (this.model !== undefined) this.root.removeChild(this.model);
            this.model = Model3D(ROOM_MODELS[p.room.key]);
            this.root.addChild(this.model);
            this.room = p.room.key;
        }
        // Rooms can be embedded in a continuous run at p.ox.
        // 特效画布以房间中点为中心，世界坐标绘制的两端都落在纹理内。
        const centerX = (p.room.minX + p.room.maxX) / 2;
        this.glow.x = -centerX;
        this.effects.position = Vec3(centerX / 100, 0, 0.015);
        if (this.model !== undefined) this.model.position = Vec3(p.ox / 100, 0, 0);
        if (!this.active) {
            Director.pushCamera(this.camera);
            this.active = true;
        }
        this.root.visible = true;
        this.updateCamera(cam, w, h, vp);
        cam.projection = this;
        this.depths = { actor_child: p.player.depth, actor_scav: 0, actor_dog: 0 };
        this.assets.beginFrame();
        this.scratch.clear();
        this.glow.clear();
        for (const key in this.shadows) this.shadows[key].visible = false;
        const a = p.player;
        if (a.alive) {
            const ground = actors.supportGroundY(p, a);
            this.placeShadow("child", a.x, ground, a.depth, a.w * 0.48, 7,
                Math.max(0.2, 1 - (a.y - ground) / 180));
        }
        if (p.room.scavenger !== undefined) {
            this.placeShadow("scavenger", p.scavX, p.room.scavenger.y, 0, 15, 8);
        }
        if (p.room.key === "forest") this.placeShadow("dog", p.dogX, 0, 0, 19, 7);
        actors.drawAll(this.scratch, this.glow, this.assets, p, this.localCam);
        this.drawProps(p);
        this.assets.endFrame();
    }

    private placeSprite(sprite: Sprite.Type, key: string, instance: string, x: number, y: number): void {
        let surface = this.surfaces[key];
        if (surface === undefined) {
            const content = Node();
            const created = Surface3D(content, Size(4, 4), Size(400, 400));
            if (created === undefined) error("Surface3D creation failed for " + key);
            surface = created;
            // Surface content faces -Z. Mirror its local X for the +Z following camera.
            surface.scaleX = -1;
            sprite.removeFromParent(false);
            content.addChild(sprite);
            this.root.addChild(surface);
            this.surfaces[key] = surface;
        }
        const depth = this.depths[instance] ?? 0;
        surface.position = Vec3(x / 100, (y - depth * DEPTH_Y_SCALE) / 100, -depth / 100);
        sprite.position = Vec2(0, 0);
    }

    private placeShadow(key: string, x: number, y: number, depth: number, rx: number, rz: number, opacity: number = 1): void {
        let surface = this.shadows[key];
        if (surface === undefined) {
            const content = DrawNode();
            content.drawCircle(Vec2(0, 0), 50, Color(16, 17, 20, 100));
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
        surface.position = Vec3(x / 100, (y + 0.6) / 100, -depth / 100);
    }

    private drawProps(p: Play): void {
        const c = p.room.cart;
        if (c.bodyW > 0) {
            const d = c.depth ?? 0;
            this.depths.cart = d;
            this.depths.cart_cloth = d - 1;
            this.assets.tryPlace("prop_cart", "cart", p.cartAxle, c.baseY + d * DEPTH_Y_SCALE,
                c.bodyW * 1.38, (c.wheelR * 2 + c.bodyH) * 0.94);
            this.assets.tryPlace("fe_red_cloth", "cart_cloth", p.cartAxle - c.bodyW / 2 + 2,
                c.baseY + c.wheelR + c.bodyH - 2 + (d - 1) * DEPTH_Y_SCALE, 24, 24,
                { frame: Math.floor(this.time * 6) % 3 });
        }
        for (const box of p.boxes) {
            if (box.id === "outside_red_cart" && !box.broken) {
                this.assets.tryPlace("prop_cart", "red_cart", (box.x0 + box.x1) / 2, box.y0, box.x1 - box.x0, box.y1 - box.y0);
                this.assets.tryPlace("fe_red_cloth", "red_cart_cloth", box.x0 + 4, box.y1 - 3, 22, 22,
                    { frame: Math.floor(this.time * 6) % 3 });
            }
        }
        if (p.room.key === "village") {
            if (!p.hasBottle && p.bottleFly === undefined && p.bottleLandT <= 0 && p.room.bottle !== undefined) {
                this.assets.tryPlace("prop_bottle", "bottle_shelf", p.room.bottle.x, p.room.bottle.y, 14, 14);
            }
            if (p.hasBottle && p.aimHold <= 0) {
                const a = p.player;
                this.depths.bottle_held = a.depth - 1;
                this.assets.tryPlace("prop_bottle", "bottle_held", a.x + a.facing * 10,
                    a.y + a.h * 0.52 + (a.depth - 1) * DEPTH_Y_SCALE, 14, 14);
            }
            if (p.bottleFly !== undefined) {
                this.assets.tryPlace("prop_bottle", "bottle_air", p.bottleFly.x, p.bottleFly.y, 14, 14,
                    { angle: this.time * 360 });
            }
        }
        if (p.hasBottle && p.aimHold > 0 && p.bottleAimX >= 0) {
            const endX = p.bottleAimX;
            const endY = p.bottleAimY;
            const x0 = p.player.x + (endX >= p.player.x ? 10 : -10);
            const y0 = p.player.y + p.player.h * 0.7;
            const duration = 0.62;
            const vx = (endX - x0) / duration;
            const vy = (endY - y0 + 0.5 * GRAVITY * duration * duration) / duration;
            for (let i = 1; i <= 18; i++) {
                const t = i / 18 * duration;
                this.glow.drawDot(Vec2(x0 + vx * t, y0 + vy * t - 0.5 * GRAVITY * t * t), 1.2,
                    Color(229, 206, 148, 210));
            }
            this.glow.drawEllipse(Vec2(endX, endY + 1), 8, 2, Color(229, 206, 148, 170));
        }
        const latch = p.cartLatchBounds();
        if (latch !== undefined) {
            const iron = Color(122, 103, 78, 255);
            const top = latch.y + latch.height;
            const post = Math.min(3, latch.width);
            this.glow.drawRect(Rect(latch.x, top - 5, latch.width, 5), iron);
            this.glow.drawRect(Rect(latch.x, latch.y, post, latch.height), iron);
            this.glow.drawRect(Rect(latch.x + latch.width - post, latch.y, post, latch.height), iron);
            this.glow.drawRect(Rect(latch.x, top - 2, latch.width, 2), Color(194, 171, 132, 255));
        }
        // 森林旧渠与溪湾：水面微光、水中灯影（贴水面、随呼吸轻摆）。
        if (p.room.key === "forest") {
            const lampX = p.ox + 1224;
            const sway = Math.sin(this.time * 1.7) * 3;
            this.glow.drawRect(Rect(p.ox + 700, -3, 90, 3), Color(94, 116, 120, 120));
            this.glow.drawRect(Rect(p.ox + 1150, -3, 110, 3), Color(98, 124, 126, 132));
            this.glow.drawEllipse(Vec2(lampX + sway, 1), 26, 3, Color(229, 206, 148, 118));
            this.glow.drawEllipse(Vec2(lampX + sway * 0.6, 1), 12, 2, Color(246, 232, 186, 172));
            this.depths.water_lamp = 40;
            this.assets.tryPlace("prop_lantern", "water_lamp", lampX, 34 + 40 * DEPTH_Y_SCALE, 16, 26);
        }
        if (p.room.key === "tower") {
            if (!p.towerDoorOpen) {
                this.assets.tryPlace("prop_tower_door", "tower_door", p.ox + 450, 0, 40, 110);
            } else {
                this.depths.tower_guard = 38;
                const writing = p.deskHold >= 24 || p.towerHanded;
                this.assets.tryPlacePath(writing ? "assets/art/actors_extra.clip|tower_guard_write"
                    : "assets/art/actors_extra.clip|tower_guard_lantern", "tower_guard",
                    p.ox + 626, 38 * DEPTH_Y_SCALE, 54, 82,
                    { anchorX: 0.44, anchorY: 0, preserveAspect: true, facing: -1 });
                this.depths.desk_lamp = 22;
                this.assets.tryPlace("prop_lantern", "desk_lamp", p.ox + 639, 35 + 22 * DEPTH_Y_SCALE, 18, 30);
            }
        }
    }

    private updateCamera(cam: CameraDirector, w: number, h: number, vp: StageViewport): void {
        this.fullW = View.size.width;
        this.fullH = View.size.height;
        this.stageX = vp.stageX;
        this.stageY = vp.stageY;
        this.focal = this.fullH / (2 * Math.tan(View.fieldOfView * Math.PI / 360));
        const distance = 4.25 / cam.zoom * this.fullH / h;
        const rise = distance * 0.19;
        const length = Math.sqrt(distance * distance + rise * rise);
        this.pitchSin = rise / length;
        this.pitchCos = distance / length;
        const offsetX = (vp.stageX + w / 2 - this.fullW / 2) * length / this.focal;
        const offsetY = (vp.stageY + h / 2 - this.fullH / 2) * length / this.focal;
        const tx = cam.x / 100 - offsetX;
        const ty = 0.85 + (cam.y - 82) * 0.0045 - offsetY * this.pitchCos;
        const tz = offsetY * this.pitchSin;
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

    screenToWorld(x: number, y: number): { x: number; y: number } {
        const u = (x + this.stageX - this.fullW / 2) / this.focal;
        const v = (y + this.stageY - this.fullH / 2) / this.focal;
        const rayY = v * this.pitchCos - this.pitchSin;
        const rayZ = -v * this.pitchSin - this.pitchCos;
        // Bottle trajectories live on the player's gameplay plane.
        const z = -(this.p?.player.depth ?? 0) / 100;
        const t = (z - this.cameraZ) / rayZ;
        return { x: (this.cameraX + u * t) * 100, y: (this.cameraY + rayY * t) * 100 };
    }
}
