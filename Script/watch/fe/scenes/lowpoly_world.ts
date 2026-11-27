/**
 * 《向西守望》Wave 2 fe-04 小满单人线《小小梦魇》风低模四房主场景插件（feature/fe-04-child-lowpoly）。
 *
 * 严格对表《第二波施工书》fe-04、《游戏分镜稿》F01–F02、《动画插入与演出规划》与《明朝全局美术设定》：
 * 1. 统一视觉激活门控：
 *    - 仅当 view.visualMode === "lowpoly" 且 room.key ∈ {"outside", "village", "forest", "tower"} 时接管非角色渲染；
 *    - 绝不干扰像素风主线/男主线（storyRoute === "soldier" 或 "undecided"），确保既有回归 100% 零回归；
 *    - 所有建筑、巨型日常物、木桌、铁盆、石阶、拱洞、枝叶均经 lowpoly.ts 程序化低模渲染，
 *      小满、拾荒者、林犬保持 2D 精灵 + wz = 0 脚底接触影，零任务箭头/浮签/光柱。
 * 2. 四房分工：
 *    - `outside`（F01 上半）：复用并扩展 buildOutsideJettyLowpoly，低拱无垂布遮净空、磨旧石阶与车辙、
 *      红布检修车左端固定红布不变式（绝不随转向翻面）、首次握车柄约 0.52 秒家人缝布回忆（不打断拉车输入）；
 *    - `village`（F01 下半）：委托 village_undertable.ts（桌下压迫机位、鞋底/暗渠/砖面/铁盆暗处可读与双反馈）；
 *    - `forest`（F02）：委托 forest_creek.ts（枯枝听声、草后犬耳/小满肩线、双路自然区分、溪湾碎灯倒影与拨枝见真灯）；
 *    - `tower`（F03 壳体）：同源低模砖石望塔与西窗暖灯，drawCutsceneOverlay 返回 false 礼让 fe-05 tower_endings.ts。
 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { DualRouteSnapshot } from "Script/watch/fe/contract";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import {
    LP_BUCKET,
    LowpolyProjection,
    LowpolyScene,
    MING_MATERIALS,
    OUTSIDE_JETTY_LIGHT,
    TOWER_WEST_LAMP_LIGHT,
    buildOutsideJettyLowpoly,
    clamp01,
    projectWorld3D,
    smoothstep,
    vec3,
} from "Script/watch/fe/renderer/lowpoly";
import {
    VillageSurfaceKind,
    VillageUndertableDebugState,
    VillageUndertableScene,
} from "Script/watch/fe/scenes/village_undertable";
import {
    ForestCreekDebugState,
    ForestCreekScene,
} from "Script/watch/fe/scenes/forest_creek";
import {
    fillRadialGlow,
    fillVGradRect,
    rgba,
    toColor,
} from "Script/watch/fe/theme";

const CHILD_AUDIO_ROOT = "assets/audio/child/";
/** 首次握车柄家人缝布回忆总时长（秒）：约半秒叠画再落回车柄，拉车输入全程不断档 */
const SEWING_MEMORY_DURATION = 0.54;

export interface OutsideLowpolyDebugState {
    active: boolean;
    cartClothLeftInvariantOk: boolean;
    cartClothWorldX: number;
    cartAxleWorldX: number;
    memoryTriggeredCount: number;
    memoryActive: boolean;
    memoryProgress: number;
    cartWheelVol: number;
}

export interface LowpolyWorldDebugState {
    active: boolean;
    roomKey: string;
    outside: OutsideLowpolyDebugState;
    village: VillageUndertableDebugState;
    forest: ForestCreekDebugState;
}

export class LowpolyWorldPlugin implements FeRenderPlugin {
    readonly id = "fe-04-child-lowpoly";

    readonly village = new VillageUndertableScene();
    readonly forest = new ForestCreekScene();

    private active = false;
    private wasActive = false;
    private activeRoomKey = "";
    private animTime = 0;

    // outside 城外栈台状态
    private prevGripping = false;
    private prevCartAxle = 0;
    private cartWheelVol = 0;
    private cartClothLeftInvariantOk = true;
    private lastCartClothX = 0;
    private lastCartAxle = 0;
    private memoryPlayed = false;
    private memoryTriggeredCount = 0;
    private memoryTimer = -1;
    private memoryAnchorWorldX = 344;
    private memoryAnchorWorldY = 122;

    private outsideProj: LowpolyProjection = {
        morph: 1,
        focal: 410,
        vpFracX: 0.54,
        vpFracY: 0.52,
        vpOffsetX: 0,
        vpOffsetY: 0,
        baseDepth: 0,
    };

    private towerProj: LowpolyProjection = {
        morph: 1,
        focal: 415,
        vpFracX: 0.52,
        vpFracY: 0.50,
        vpOffsetX: 0,
        vpOffsetY: 0,
        baseDepth: 0,
    };

    onBindPlay(p: Play, _view: DualRouteSnapshot): void {
        this.resetRoomState(p);
        this.syncRuntimeHook();
    }

    private resetRoomState(p?: Play): void {
        this.active = false;
        this.wasActive = false;
        this.activeRoomKey = p !== undefined ? p.room.key : "";
        this.animTime = 0;
        this.prevGripping = false;
        this.prevCartAxle = p !== undefined ? p.cartAxle : 0;
        this.cartWheelVol = 0;
        this.cartClothLeftInvariantOk = true;
        this.lastCartAxle = this.prevCartAxle;
        this.lastCartClothX = p !== undefined && p.room.cart.bodyW > 0 ? (p.cartAxle - p.room.cart.bodyW * 0.5) : 0;
        this.memoryPlayed = false;
        this.memoryTriggeredCount = 0;
        this.memoryTimer = -1;
        this.village.reset();
        this.forest.reset();
    }

    private syncRuntimeHook(): void {
        const g = globalThis as unknown as { package?: { loaded?: Record<string, unknown> } };
        const loaded = g.package !== undefined ? g.package.loaded : undefined;
        if (loaded === undefined) {
            return;
        }
        const rawFe = loaded["watch.fe"];
        if (rawFe !== undefined && typeof rawFe === "object") {
            const watchFe = rawFe as Record<string, unknown>;
            if (watchFe["lowpolyWorld"] !== this) {
                watchFe["lowpolyWorld"] = this;
            }
        }
    }

    private isLowpolyChildRoom(roomKey: string): boolean {
        return roomKey === "outside" || roomKey === "village" || roomKey === "forest" || roomKey === "tower";
    }

    private shouldActivate(ctx: FePluginContext): boolean {
        return ctx.view.visualMode === "lowpoly" && this.isLowpolyChildRoom(ctx.p.room.key);
    }

    getActiveProjection(roomKey?: string): LowpolyProjection {
        const key = roomKey ?? this.activeRoomKey;
        if (key === "village") {
            return this.village.getProjection();
        }
        if (key === "forest") {
            return this.forest.getProjection();
        }
        if (key === "tower") {
            return this.towerProj;
        }
        return this.outsideProj;
    }

    getDebugState(p?: Play): LowpolyWorldDebugState {
        const memActive = this.memoryTimer >= 0 && this.memoryTimer < SEWING_MEMORY_DURATION;
        return {
            active: this.active,
            roomKey: this.activeRoomKey,
            outside: {
                active: this.active && this.activeRoomKey === "outside",
                cartClothLeftInvariantOk: this.cartClothLeftInvariantOk,
                cartClothWorldX: this.lastCartClothX,
                cartAxleWorldX: this.lastCartAxle,
                memoryTriggeredCount: this.memoryTriggeredCount,
                memoryActive: memActive,
                memoryProgress: memActive ? clamp01(this.memoryTimer / SEWING_MEMORY_DURATION) : (this.memoryPlayed ? 1 : 0),
                cartWheelVol: this.cartWheelVol,
            },
            village: this.village.getDebugState(p),
            forest: this.forest.getDebugState(p),
        };
    }

    /** 排演/截帧辅助：触发城外栈台 0.5 秒缝布回忆（可定格至指定进度 0..1） */
    rehearseOutsideSewingMemory(progress?: number): void {
        this.memoryPlayed = true;
        this.memoryTriggeredCount += 1;
        this.memoryTimer = progress !== undefined ? clamp01(progress) * SEWING_MEMORY_DURATION : 0;
    }

    /** 排演/截帧辅助：触发空村硬砖/铁盆/软土落点反馈 */
    rehearseVillageImpact(ctx: FePluginContext, surface: VillageSurfaceKind): void {
        this.village.triggerRehearsalImpact(ctx, surface);
    }

    private stopAllAudioLoops(ctx: FePluginContext): void {
        ctx.audio.stopLoop("fe04_outside_wind", 0.2);
        ctx.audio.stopLoop("fe04_cart_wheel", 0.15);
        ctx.audio.stopLoop("fe04_village_night", 0.2);
        ctx.audio.stopLoop("fe04_forest_wind", 0.2);
        ctx.audio.stopLoop("fe04_creek_water", 0.2);
    }

    update(ctx: FePluginContext): void {
        this.syncRuntimeHook();
        const want = this.shouldActivate(ctx);
        if (!want) {
            if (this.wasActive) {
                ctx.cam.setAnchorLock(undefined);
                this.stopAllAudioLoops(ctx);
                this.wasActive = false;
            }
            this.active = false;
            return;
        }

        const p = ctx.p;
        if (this.activeRoomKey !== "" && this.activeRoomKey !== p.room.key) {
            ctx.cam.setAnchorLock(undefined);
            this.stopAllAudioLoops(ctx);
            this.resetRoomState(p);
        }

        this.active = true;
        this.wasActive = true;
        this.activeRoomKey = p.room.key;

        if (!ctx.paused && ctx.worldDt > 0) {
            this.animTime += ctx.worldDt;
        }

        if (p.room.key === "outside") {
            this.updateOutside(ctx);
        } else if (p.room.key === "village") {
            this.village.update(ctx);
        } else if (p.room.key === "forest") {
            this.forest.update(ctx);
        } else if (p.room.key === "tower") {
            ctx.cam.setAnchorLock(undefined);
            this.towerProj = {
                morph: 1,
                focal: 415,
                vpFracX: 0.52,
                vpFracY: 0.50,
                vpOffsetX: Math.sin(this.animTime * 0.45) * 1.2,
                vpOffsetY: Math.cos(this.animTime * 0.60) * 0.8,
                baseDepth: 0,
            };
        }
    }

    private updateOutside(ctx: FePluginContext): void {
        const p = ctx.p;
        ctx.cam.setAnchorLock(undefined);

        const c = p.room.cart;
        if (c.bodyW > 0) {
            // 强制红布固定在车身左端（绝不随小满转向翻面）
            this.lastCartAxle = p.cartAxle;
            this.lastCartClothX = p.cartAxle - c.bodyW * 0.5;
            if (this.lastCartClothX >= this.lastCartAxle || c.clothSide >= 0) {
                this.cartClothLeftInvariantOk = false;
            }
            this.memoryAnchorWorldX = p.cartAxle + c.handleOffset;
            this.memoryAnchorWorldY = c.baseY + c.wheelR + c.bodyH * 0.72;
        }

        if (!ctx.paused && ctx.worldDt > 0) {
            const dt = ctx.worldDt;

            // 首次握住红布检修车右柄，或拉开挡道红布车触发 redCartMemoryT → 触发约 0.54s 家人缝布回忆，不中断输入
            const redCartMemTrigger = p.redCartMemoryT > 0 && !this.memoryPlayed;
            if (((p.gripping && !this.prevGripping) || redCartMemTrigger) && !this.memoryPlayed) {
                this.memoryPlayed = true;
                this.memoryTriggeredCount += 1;
                this.memoryTimer = 0;
                if (redCartMemTrigger) {
                    this.memoryAnchorWorldX = p.player.x;
                    this.memoryAnchorWorldY = p.player.y + 36;
                }
                ctx.audio.playOnce(
                    "fe04:outside:sewing:" + ctx.events.roomSessionId,
                    "ambience",
                    CHILD_AUDIO_ROOT + "sewing_memory.wav",
                    0.68,
                    "fe04:outside:sewing_memory",
                    p.ticks,
                );
            }
            this.prevGripping = p.gripping;

            if (this.memoryTimer >= 0 && this.memoryTimer < SEWING_MEMORY_DURATION) {
                this.memoryTimer = Math.min(SEWING_MEMORY_DURATION, this.memoryTimer + dt);
            }

            // 木轮声按板车实际移动速度调制
            const cartSpeed = Math.abs(p.cartAxle - this.prevCartAxle) / Math.max(0.001, dt);
            this.prevCartAxle = p.cartAxle;
            const targetWheelVol = cartSpeed > 4 ? Math.min(0.54, 0.22 + (cartSpeed / 64) * 0.32) : 0;
            this.cartWheelVol += (targetWheelVol - this.cartWheelVol) * Math.min(1, dt * 10);

            ctx.audio.playLoop("fe04_outside_wind", "wind", CHILD_AUDIO_ROOT + "wind_outside_loop.wav", 0.36, p.ticks);
            if (this.cartWheelVol > 0.03) {
                ctx.audio.playLoop("fe04_cart_wheel", "ambience", CHILD_AUDIO_ROOT + "cart_wheel_loop.wav", this.cartWheelVol, p.ticks);
            } else {
                ctx.audio.stopLoop("fe04_cart_wheel", 0.12);
            }
        }

        this.outsideProj = {
            morph: 1,
            focal: 410,
            vpFracX: 0.54,
            vpFracY: 0.52,
            vpOffsetX: Math.sin(this.animTime * 0.52) * 1.5,
            vpOffsetY: Math.cos(this.animTime * 0.68) * 1.0,
            baseDepth: 0,
        };
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
        const key = ctx.p.room.key;
        if (key === "village") {
            return this.village.drawBackdrop(bgDraw, bgGlow, backdropArt, ctx);
        }
        if (key === "forest") {
            return this.forest.drawBackdrop(bgDraw, bgGlow, backdropArt, ctx);
        }
        if (key === "outside") {
            return this.drawOutsideBackdrop(bgDraw, bgGlow, ctx);
        }
        if (key === "tower") {
            return this.drawTowerBackdrop(bgDraw, bgGlow, ctx);
        }
        return false;
    }

    private drawOutsideBackdrop(bgDraw: DrawNode.Type, bgGlow: DrawNode.Type, ctx: FePluginContext): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const w = cam.viewW;
        const h = cam.viewH;
        const ox = p.ox;

        // 宁村所外城冷夜海风天穹
        const splitY = h * 0.48;
        fillVGradRect(bgDraw, 0, splitY, w, h - splitY, Color(16, 25, 38, 255), Color(8, 13, 22, 255));
        fillVGradRect(bgDraw, 0, 0, w, splitY, Color(30, 44, 62, 255), Color(16, 25, 38, 255));

        const scene = new LowpolyScene(cam, this.outsideProj, OUTSIDE_JETTY_LIGHT);
        // 远景外城砖墙垛口与护城河海雾
        scene.addBox({
            x0: ox - 160,
            x1: ox + 1360,
            y0: -48,
            y1: 112,
            z0: 230,
            z1: 274,
            material: MING_MATERIALS.distantWall,
            bucket: LP_BUCKET.BACKDROP,
            edgeWidth: 0,
        });
        let mx = ox - 80;
        let mi = 0;
        for (mi = 0; mi < 18; mi++) {
            scene.addBox({
                x0: mx,
                x1: mx + 32,
                y0: 112,
                y1: 128,
                z0: 230,
                z1: 256,
                material: MING_MATERIALS.distantWall,
                bucket: LP_BUCKET.BACKDROP,
                sortBias: 0.04,
                edgeWidth: 0,
            });
            mx += 78;
        }
        // 远景城垣残檐与远山北塔实景手绘立牌（与远方一豆暖灯呼应去向）
        scene.addCutout3D("assets/art/diorama_cutouts.clip|ming_eave_ruin", ox + 280, 96, 224, 152, 100, {
            bucket: LP_BUCKET.BACKDROP,
            anchorX: 0.5,
            anchorY: 0,
            color: rgba(114, 134, 156, 255),
            opacity: 0.84,
            sortBias: 0.05,
        });
        scene.addCutout3D("assets/art/diorama_cutouts.clip|ming_eave_ruin", ox + 810, 96, 226, 148, 98, {
            bucket: LP_BUCKET.BACKDROP,
            facing: -1,
            anchorX: 0.5,
            anchorY: 0,
            color: rgba(108, 128, 152, 255),
            opacity: 0.80,
            sortBias: 0.05,
        });
        scene.addCutout3D("assets/art/diorama_cutouts.clip|north_tower_distant", ox + 1140, 48, 405, 118, 150, {
            bucket: LP_BUCKET.BACKDROP,
            anchorX: 0.5,
            anchorY: 0,
            color: rgba(136, 156, 178, 255),
            opacity: 0.90,
            sortBias: 0.08,
        });
        scene.addFogBand(ox - 180, ox + 1420, -34, 152, 180, rgba(28, 42, 60, 255), 0.58, 0.06, {
            bucket: LP_BUCKET.BACKDROP,
        });
        scene.flush(bgDraw, bgGlow, ctx.dioramaBg);

        // 冷月与远山北塔一豆暖灯（引导尽头 x ≈ 1120，无任务光柱）
        const moonX = w * 0.76;
        const moonY = h * 0.83;
        fillRadialGlow(bgGlow, moonX, moonY, 82, 82, Color(172, 206, 232, 28), Color(24, 42, 68, 0), 16);
        bgDraw.drawCircle(Vec2(moonX, moonY), 14, Color(218, 232, 246, 165));

        const beaconP = projectWorld3D(ox + 1140, 154, 410, cam, this.outsideProj);
        const pulse = 0.84 + 0.16 * Math.sin(this.animTime * 2.2);
        fillRadialGlow(bgGlow, beaconP.x, beaconP.y, 32 * pulse, 32 * pulse, Color(246, 208, 138, Math.round(92 * pulse)), Color(232, 176, 86, 0), 14);
        bgGlow.drawDot(Vec2(beaconP.x, beaconP.y), 2.5, Color(255, 244, 212, 235));

        return true;
    }

    private drawTowerBackdrop(bgDraw: DrawNode.Type, bgGlow: DrawNode.Type, ctx: FePluginContext): boolean {
        const cam = ctx.cam;
        const p = ctx.p;
        const ox = p.ox;
        const w = cam.viewW;
        const h = cam.viewH;

        // 拂晓前微暖山风天际
        const splitY = h * 0.46;
        fillVGradRect(bgDraw, 0, splitY, w, h - splitY, Color(24, 34, 52, 255), Color(12, 18, 30, 255));
        fillVGradRect(bgDraw, 0, 0, w, splitY, Color(46, 54, 70, 255), Color(24, 34, 52, 255));

        const scene = new LowpolyScene(cam, this.towerProj, TOWER_WEST_LAMP_LIGHT);
        scene.addDistantRidge(
            [
                { x: ox - 180, y: 118 },
                { x: ox + 90, y: 172 },
                { x: ox + 360, y: 146 },
                { x: ox + 640, y: 184 },
                { x: ox + 920, y: 132 },
            ],
            -40,
            420,
            MING_MATERIALS.distantHill,
            { bucket: LP_BUCKET.BACKDROP },
        );
        scene.addFogBand(ox - 160, ox + 900, -24, 150, 260, rgba(36, 42, 58, 255), 0.56, 0.06, {
            bucket: LP_BUCKET.BACKDROP,
        });
        scene.flush(bgDraw, bgGlow, ctx.dioramaBg);

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
        const key = ctx.p.room.key;
        if (key === "village") {
            return this.village.drawWorld(fgDraw, fgGlow, worldArt, ctx);
        }
        if (key === "forest") {
            return this.forest.drawWorld(fgDraw, fgGlow, worldArt, ctx);
        }
        if (key === "outside") {
            return this.drawOutsideWorld(fgDraw, fgGlow, ctx);
        }
        if (key === "tower") {
            return this.drawTowerWorld(fgDraw, fgGlow, ctx);
        }
        return false;
    }

    private drawOutsideWorld(fgDraw: DrawNode.Type, fgGlow: DrawNode.Type, ctx: FePluginContext): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const ox = p.ox;
        const scene = new LowpolyScene(cam, this.outsideProj, OUTSIDE_JETTY_LIGHT);

        // 1. 复用 fe-01 核心低模栈台构建器（floors / stairs / solids / 无垂布低拱 / 左端红布投影 / 脚底接触影）
        buildOutsideJettyLowpoly(scene, p.room, p.player.x, p.player.y, p.cartAxle, this.animTime);

        // 1b. 挡住石阶口的补丁红布独轮车（实时跟随后端 outside_red_cart 坐标，避免画成灰砖墙与高墩）
        const redBox = p.boxes.find((b) => b.id === "outside_red_cart");
        if (redBox !== undefined && redBox.broken !== true && redBox.hidden !== true) {
            scene.addBox({
                x0: redBox.x0 + 2,
                x1: redBox.x1 - 2,
                y0: redBox.y0 + 10,
                y1: redBox.y1,
                z0: -10,
                z1: 12,
                material: MING_MATERIALS.mingTimber,
                bucket: LP_BUCKET.PROP,
                highlightTopEdge: true,
                edgeWidth: 0.9,
            });
            // 车沿系着的旧补丁红布（Grid 织纹波浪飘动）
            scene.addWavingQuad3D(
                vec3(redBox.x0 - 4, redBox.y0 + 10, -12),
                vec3(redBox.x0 + 14, redBox.y0 + 12, -11),
                vec3(redBox.x0 + 18, redBox.y1, -10),
                vec3(redBox.x0 + 4, redBox.y1, -11),
                MING_MATERIALS.mingRedCloth,
                { ampX: 4.5, ampY: 1.8, phase: this.animTime * 2.9, freqU: 1.8, freqV: 2.4, pin: "top" },
                { bucket: LP_BUCKET.PROP, sortBias: 0.26, subdivX: 3, subdivY: 3 },
            );
        }

        // 2. 增补城外细部：上层木轮车辙与空窝物理凹槽（x = 432）、下层廊顶铁格栅条影与盐碱高水线
        const c = p.room.cart;
        if (c.bodyW > 0) {
            // 物理轮窝凹槽（无发光箭头/全息柱，纯木槽与暗铁限位块）
            scene.addBox({
                x0: c.endX - 18,
                x1: c.endX + 18,
                y0: c.baseY - 4,
                y1: c.baseY + 2,
                z0: -12,
                z1: 14,
                material: MING_MATERIALS.mingIron,
                bucket: LP_BUCKET.WALK_DECK,
                sortBias: 0.35,
                highlightTopEdge: true,
            });
            // 上层栈台双道木轮车辙槽
            scene.addBox({
                x0: ox + 258,
                x1: ox + 474,
                y0: c.baseY - 1.5,
                y1: c.baseY + 0.4,
                z0: -11,
                z1: -7,
                material: MING_MATERIALS.mingTimberDark,
                bucket: LP_BUCKET.WALK_DECK,
                sortBias: 0.30,
                edgeWidth: 0,
            });
            scene.addBox({
                x0: ox + 258,
                x1: ox + 474,
                y0: c.baseY - 1.5,
                y1: c.baseY + 0.4,
                z0: 7,
                z1: 11,
                material: MING_MATERIALS.mingTimberDark,
                bucket: LP_BUCKET.WALK_DECK,
                sortBias: 0.30,
                edgeWidth: 0,
            });
        }

        // 2b. 板车未入窝前，车底连杆挡木垂直探入下层拱口，直观呈现「拉车开拱」的物理阻挡因果；
        //     车轮一旦落窝（cartDocked），挡木收回，拱口与底层完全畅通。
        if (!p.cartDocked && p.room.arch.h > 0) {
            const bx0 = Math.max(p.room.arch.x0 + 4, p.cartAxle - 18);
            const bx1 = Math.min(p.room.arch.x1 - 4, p.cartAxle + 18);
            if (bx1 > bx0 + 4) {
                scene.addBox({
                    x0: bx0,
                    x1: bx1,
                    y0: 2,
                    y1: p.room.arch.h,
                    z0: -6,
                    z1: 8,
                    material: MING_MATERIALS.mingTimberDark,
                    bucket: LP_BUCKET.PROP,
                    highlightTopEdge: true,
                    edgeWidth: 0.9,
                });
                // 连至上层板车底梁的铁链/拉杆
                scene.addBox({
                    x0: (bx0 + bx1) * 0.5 - 3,
                    x1: (bx0 + bx1) * 0.5 + 3,
                    y0: p.room.arch.h,
                    y1: p.room.cart.baseY,
                    z0: -3,
                    z1: 5,
                    material: MING_MATERIALS.mingIron,
                    bucket: LP_BUCKET.PROP,
                    edgeWidth: 0.6,
                });
            }
        }

        // 3. 下层水门检修廊背景墙与盐碱高水线（位于 z = 44..72，不侵占拱洞净空）
        scene.addBox({
            x0: ox + 128,
            x1: ox + 598,
            y0: 0,
            y1: 92,
            z0: 44,
            z1: 72,
            material: MING_MATERIALS.mingBrickDark,
            bucket: LP_BUCKET.MIDGROUND,
            sortBias: -0.20,
            edgeWidth: 0.5,
        });
        // 旧年高水线浅灰盐碱带
        scene.addQuad3D(
            vec3(ox + 132, 26, 43),
            vec3(ox + 592, 26, 43),
            vec3(ox + 592, 31, 43),
            vec3(ox + 132, 31, 43),
            { base: rgba(138, 148, 158, 92) },
            { bucket: LP_BUCKET.MIDGROUND, unlit: true, sortBias: -0.10 },
        );

        // 4. 墙根尽头远望北塔侧光束（x ≈ 1080..1180）
        scene.addLightShaft(
            ox + 1110, ox + 1180, 170,
            ox + 1040, ox + 1140, 0,
            34,
            rgba(234, 198, 138, 255),
            0.14,
            0.03,
        );

        scene.flush(fgDraw, fgGlow, ctx.dioramaWorld);

        // 下层水门廊道头顶格栅条影（细微环境层次）
        let gi = 0;
        for (gi = 0; gi < 6; gi++) {
            const gx = ox + 165 + gi * 56;
            const p0 = projectWorld3D(gx, 0.5, -14, cam, this.outsideProj);
            const p1 = projectWorld3D(gx + 10, 0.5, 22, cam, this.outsideProj);
            fgDraw.drawSegment(Vec2(p0.x, p0.y), Vec2(p1.x, p1.y), 3.0, Color(8, 12, 18, 76));
        }

        return true;
    }

    private drawTowerWorld(fgDraw: DrawNode.Type, fgGlow: DrawNode.Type, ctx: FePluginContext): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const ox = p.ox;
        const opened = p.towerDoorOpen
            || p.phase === "tower-enter"
            || p.phase === "tower-desk"
            || p.phase === "tower-given"
            || p.phase === "tower-end";
        const scene = new LowpolyScene(cam, this.towerProj, TOWER_WEST_LAMP_LIGHT);

        // 1. 山顶青石走面与塔基石阶
        scene.addBox({
            x0: ox - 40,
            x1: ox + 760,
            y0: -52,
            y1: 0,
            z0: -26,
            z1: 96,
            material: MING_MATERIALS.mingBrickDark,
            bucket: LP_BUCKET.WALK_DECK,
            highlightTopEdge: true,
        });
        // 门廊青石门槛（doorX = 445）
        scene.addBox({
            x0: ox + 398,
            x1: ox + 492,
            y0: -4,
            y1: 2.5,
            z0: -16,
            z1: 26,
            material: MING_MATERIALS.mingStoneStep,
            bucket: LP_BUCKET.WALK_DECK,
            sortBias: 0.15,
            highlightTopEdge: true,
        });

        // 2. 塔身左右厚重砖石墙体（拉齐至 z0 = -8 与步行面和石门框严密贴合，消除视觉退后导致的空气墙感）
        scene.addBox({
            x0: ox + 180,
            x1: ox + 400,
            y0: 0,
            y1: 215,
            z0: -8,
            z1: 96,
            material: MING_MATERIALS.mingBrick,
            bucket: LP_BUCKET.MIDGROUND,
            highlightTopEdge: true,
        });
        scene.addBox({
            x0: ox + 490,
            x1: ox + 720,
            y0: 0,
            y1: 215,
            z0: -8,
            z1: 96,
            material: MING_MATERIALS.mingBrick,
            bucket: LP_BUCKET.MIDGROUND,
            highlightTopEdge: true,
        });

        // 3. 门廊石拱门楣（400..490, y = 110..144）
        scene.addBeveledFrame(ox + 400, ox + 490, 0, 110, 14, 34, -8, 68, MING_MATERIALS.mingStoneStep, {
            bucket: LP_BUCKET.MIDGROUND,
            innerRimLight: rgba(244, 206, 140, 255),
            innerRimStrength: opened ? 0.78 : 0.32,
        });

        // 3b. 北塔重檐飞角剪影
        scene.addCutout3D("assets/art/diorama_cutouts.clip|ming_eave_ruin", ox + 445, 206, 18, 240, 142, {
            bucket: LP_BUCKET.MIDGROUND,
            anchorX: 0.5,
            anchorY: 0,
            color: rgba(154, 168, 184, 255),
            opacity: 0.92,
            sortBias: 0.08,
        });

        // 4. 厚木门扇（未开门时使用手绘明代铁铺首厚木塔门立牌，开门后敞露温暖值夜室灯火）
        if (!opened) {
            scene.addCutout3D("assets/art/cutscene_story_parts.clip|tower_porch_door", ox + 445, 2, 14, 84, 108, {
                bucket: LP_BUCKET.MIDGROUND,
                anchorX: 0.5,
                anchorY: 0,
                color: rgba(186, 182, 176, 255),
                opacity: 0.98,
                sortBias: 0.14,
            });
        } else {
            scene.addQuad3D(
                vec3(ox + 404, 2, 24),
                vec3(ox + 486, 2, 24),
                vec3(ox + 486, 109, 24),
                vec3(ox + 404, 109, 24),
                { base: rgba(112, 78, 42, 255) },
                { bucket: LP_BUCKET.MIDGROUND, unlit: true, sortBias: 0.08 },
            );
        }

        // 5. 西窗狭长暖窗（贴合拉齐后的左塔壁前立面 z = -9，呼应“朝西那盏灯，能留着吗”）
        scene.addQuad3D(
            vec3(ox + 286, 118, -9),
            vec3(ox + 306, 118, -9),
            vec3(ox + 306, 158, -9),
            vec3(ox + 286, 158, -9),
            { base: rgba(244, 204, 134, 255) },
            { bucket: LP_BUCKET.PROP, unlit: true, edgeColor: rgba(82, 68, 52, 255), edgeWidth: 1.4 },
        );

        // 6. 门内暖光溢出与提灯光晕
        const pulse = 0.88 + 0.12 * Math.sin(this.animTime * 2.8);
        scene.addLightShaft(
            ox + 412, ox + 478, 106,
            ox + 382, ox + 506, 0,
            6,
            rgba(246, 208, 138, 255),
            (opened ? 0.34 : 0.08) * pulse,
            (opened ? 0.16 : 0.04) * pulse,
        );

        // 7. 小满脚底接触影
        scene.addContactShadow(p.player.x, p.player.y, 15, 11, 0.78, { bucket: LP_BUCKET.PROP, sortBias: 0.45 });

        scene.flush(fgDraw, fgGlow, ctx.dioramaWorld);

        // 门廊悬灯暖点与西窗微晕
        const lampP = projectWorld3D(ox + 445, 102, 2, cam, this.towerProj);
        fillRadialGlow(
            fgGlow,
            lampP.x,
            lampP.y,
            cam.len(opened ? 64 : 34) * pulse,
            cam.len(opened ? 64 : 34) * pulse,
            Color(248, 214, 146, Math.round((opened ? 132 : 76) * pulse)),
            Color(232, 174, 82, 0),
            16,
        );
        fgDraw.drawCircle(Vec2(lampP.x, lampP.y), 4.2, Color(255, 240, 202, 245));

        const winP = projectWorld3D(ox + 296, 138, -9, cam, this.towerProj);
        fillRadialGlow(fgGlow, winP.x, winP.y, cam.len(38), cam.len(42), Color(246, 206, 132, Math.round(78 * pulse)), Color(232, 174, 82, 0), 14);
        // 西窗明代木窗格（十字棂条；塔身已由真实青砖 Grid 纹理承载）
        const wBL = projectWorld3D(ox + 286, 118, -9, cam, this.towerProj);
        const wTR = projectWorld3D(ox + 306, 158, -9, cam, this.towerProj);
        const wMidX = (wBL.x + wTR.x) * 0.5;
        const wMidY = (wBL.y + wTR.y) * 0.5;
        fgDraw.drawSegment(Vec2(wMidX, wBL.y), Vec2(wMidX, wTR.y), 1.4, Color(68, 52, 38, 225));
        fgDraw.drawSegment(Vec2(wBL.x, wMidY), Vec2(wTR.x, wMidY), 1.4, Color(68, 52, 38, 225));

        return true;
    }

    drawPropsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        if (!this.active) {
            return false;
        }
        const key = ctx.p.room.key;
        if (key === "village") {
            return this.village.drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx);
        }
        if (key === "forest") {
            return this.forest.drawPropsOverlay(fgDraw, fgGlow, worldArt, ctx);
        }
        if (key === "outside") {
            return this.drawOutsideCartLowpoly(fgDraw, fgGlow, ctx);
        }
        if (key === "tower") {
            const p = ctx.p;
            const opened = p.towerDoorOpen || p.phase === "tower-enter" || p.phase === "tower-desk";
            if (opened) {
                const cam = ctx.cam;
                const deskCx = cam.sx(p.ox + 605);
                const groundY = cam.sy(0);
                const deskW = cam.len(84);
                const deskH = cam.len(34);
                const deskTop = groundY + deskH;
                const pulse = 0.88 + 0.12 * Math.sin(this.animTime * 2.8);
                fillRadialGlow(fgGlow, deskCx, deskTop + cam.len(28), cam.len(120), cam.len(88),
                    Color(255, 198, 114, Math.round(74 * pulse)), Color(255, 168, 72, 0), 16);
                // 值夜室守卒手绘精灵（提灯值夜 / 伏案记簿）与旧木值夜桌
                const guardX = deskCx + cam.len(26);
                const writing = p.deskHold >= 24 || p.towerHanded;
                const guardClip = writing
                    ? "assets/art/actors_extra.clip|tower_guard_write"
                    : "assets/art/actors_extra.clip|tower_guard_lantern";
                if (!worldArt.tryPlacePath(guardClip, "fe04_tower_guard_npc", guardX, groundY, cam.len(54), cam.len(82), {
                    anchorX: 0.44,
                    anchorY: 0,
                    preserveAspect: true,
                    facing: -1,
                    opacity: 0.96,
                    layer: 3600,
                })) {
                    fgDraw.drawRect(Rect(guardX - cam.len(11), groundY, cam.len(22), cam.len(68)), Color(28, 34, 44, 240));
                }
                worldArt.tryPlace("prop_table", "fe04_tower_desk_prop", deskCx, groundY, deskW * 1.06, deskH * 1.04, {
                    color: Color(206, 180, 150, 255),
                    opacity: 0.98,
                    layer: 3650,
                });
                if (writing) {
                    worldArt.tryPlace("prop_lantern", "fe04_tower_desk_lamp", deskCx + cam.len(34), deskTop + cam.len(10), cam.len(14), cam.len(20), {
                        opacity: 0.96,
                        layer: 3700,
                    });
                    fillRadialGlow(fgGlow, deskCx + cam.len(34), deskTop + cam.len(12), cam.len(24), cam.len(22), Color(255, 214, 134, Math.round(84 * pulse)), Color(255, 180, 86, 0), 12);
                } else {
                    fillRadialGlow(fgGlow, deskCx + cam.len(3), deskTop + cam.len(18), cam.len(28), cam.len(26), Color(255, 214, 134, Math.round(74 * pulse)), Color(255, 180, 86, 0), 12);
                }
                fgDraw.drawRect(Rect(deskCx + cam.len(2), deskTop + cam.len(1), cam.len(22), cam.len(4)), Color(230, 220, 196, 235));
                if (p.deskHold >= 12 || p.towerHanded) {
                    worldArt.tryPlacePath("assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", "fe04_tower_desk_pouch", deskCx - cam.len(18), deskTop + cam.len(8), cam.len(18), cam.len(18), {
                        anchorX: 0.5,
                        anchorY: 0.5,
                        opacity: 0.95,
                        smooth: true,
                        layer: 3710,
                    });
                }
                if (p.deskHold >= 24 || p.towerHanded) {
                    fgDraw.drawRect(Rect(deskCx - cam.len(4), deskTop + cam.len(1), cam.len(10), cam.len(3)), Color(236, 228, 206, 240));
                }
            }
            return true;
        }
        return false;
    }

    /** 城外低模红布检修车（右柄抓握、左端旧红布绝不随小满转向翻面、木轮真实滚动、零黄球/全息标） */
    private drawOutsideCartLowpoly(fgDraw: DrawNode.Type, fgGlow: DrawNode.Type, ctx: FePluginContext): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const c = p.room.cart;
        if (c.bodyW <= 0) {
            return true;
        }
        const scene = new LowpolyScene(cam, this.outsideProj, OUTSIDE_JETTY_LIGHT);
        const halfW = c.bodyW * 0.5;
        const axleX = p.cartAxle;
        const axleY = c.baseY + c.wheelR;
        const bodyBot = axleY + 2;
        const bodyTop = bodyBot + c.bodyH;

        // 1. 立体木车厢本体（z = -12..14）
        scene.addBox({
            x0: axleX - halfW,
            x1: axleX + halfW,
            y0: bodyBot,
            y1: bodyTop,
            z0: -12,
            z1: 14,
            material: MING_MATERIALS.mingTimber,
            bucket: LP_BUCKET.PROP,
            highlightTopEdge: true,
            edgeWidth: 1.0,
        });
        // 车厢暗铁包角横箍
        scene.addBox({
            x0: axleX - halfW - 1,
            x1: axleX + halfW + 1,
            y0: bodyBot + 4,
            y1: bodyBot + 8,
            z0: -13,
            z1: 15,
            material: MING_MATERIALS.mingIron,
            bucket: LP_BUCKET.PROP,
            sortBias: 0.08,
        });
        // 右侧双木拉柄（小满抓右柄 handleOffset = +40，自然木色无发光黄球）
        const handleX = axleX + c.handleOffset;
        scene.addBox({
            x0: axleX + halfW - 2,
            x1: handleX,
            y0: bodyTop - 6,
            y1: bodyTop - 1,
            z0: -10,
            z1: -4,
            material: MING_MATERIALS.mingTimber,
            bucket: LP_BUCKET.PROP,
            sortBias: 0.12,
            highlightTopEdge: true,
        });
        scene.addBox({
            x0: handleX - 3,
            x1: handleX + 3,
            y0: bodyTop - 8,
            y1: bodyTop + 2,
            z0: -11,
            z1: 9,
            material: MING_MATERIALS.mingTimber,
            bucket: LP_BUCKET.PROP,
            sortBias: 0.14,
            highlightTopEdge: true,
        });

        // 2. 车身左端固定旧红布与补丁（恒锚定在 axleX - halfW，Grid 粗麻织纹随风自然垂扬，绝不随小满转向翻面！）
        const clothX = axleX - halfW;
        const clothTop = bodyTop + 1;
        scene.addWavingQuad3D(
            vec3(clothX - 15, clothTop - 23, -14),
            vec3(clothX + 2, clothTop - 21, -12),
            vec3(clothX + 11, clothTop, -11),
            vec3(clothX - 2, clothTop + 1, -12),
            MING_MATERIALS.mingRedCloth,
            { ampX: 6.2, ampY: 2.4, phase: this.animTime * 3.1, freqU: 1.7, freqV: 2.6, pin: "top" },
            { bucket: LP_BUCKET.PROP, sortBias: 0.28, subdivX: 3, subdivY: 4 },
        );

        scene.flush(fgDraw, fgGlow, ctx.dioramaWorld);

        // 3. 旋转木辐条双轮（贴合 wz = 0，随 cartAxle 真实转动）
        const wheelXs = [axleX - halfW * 0.56, axleX + halfW * 0.56];
        const wheelR = cam.len(c.wheelR);
        const rollAngle = -axleX / Math.max(1, c.wheelR);
        let wi = 0;
        for (wi = 0; wi < wheelXs.length; wi++) {
            const wp = projectWorld3D(wheelXs[wi], axleY, -10, cam, this.outsideProj);
            fgDraw.drawCircle(Vec2(wp.x, wp.y), wheelR, Color(52, 40, 32, 255));
            fgDraw.drawRing(Vec2(wp.x, wp.y), Math.max(1, wheelR - 2.6), wheelR, Color(0, 0, 0, 0), 1.4, Color(148, 126, 102, 220));
            let sp = 0;
            for (sp = 0; sp < 4; sp++) {
                const a = rollAngle + (sp * Math.PI) / 4;
                const dx = Math.cos(a) * (wheelR - 2);
                const dy = Math.sin(a) * (wheelR - 2);
                fgDraw.drawSegment(Vec2(wp.x - dx, wp.y - dy), Vec2(wp.x + dx, wp.y + dy), 1.0, Color(118, 92, 70, 210));
            }
            fgDraw.drawDot(Vec2(wp.x, wp.y), 2.4, Color(172, 160, 144, 230));
        }

        // 左端旧红布上的浅麻补丁细针脚（与回忆里缝的补丁前后呼应）
        const patchP = projectWorld3D(clothX + 1, clothTop - 7, -13, cam, this.outsideProj);
        fgDraw.drawSegment(Vec2(patchP.x - 3, patchP.y), Vec2(patchP.x + 3, patchP.y - 2), 1.0, Color(224, 212, 188, 215));
        fgDraw.drawSegment(Vec2(patchP.x - 2, patchP.y - 4), Vec2(patchP.x + 2, patchP.y - 5), 0.9, Color(224, 212, 188, 195));

        return true;
    }

    drawActorsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        if (!this.active) {
            return;
        }
        const key = ctx.p.room.key;
        if (key === "village") {
            this.village.drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx);
        } else if (key === "forest") {
            this.forest.drawActorsOverlay(fgDraw, fgGlow, worldArt, ctx);
        }
    }

    /**
     * 前景遮挡与城外 0.5 秒缝布回忆：
     * 始终返回 false（绝不压隐 HUD、字幕、准星或 fe-05 北塔登记簿演出）。
     */
    drawCutsceneOverlay(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        if (!this.active) {
            return false;
        }
        const key = ctx.p.room.key;
        if (key === "village") {
            return this.village.drawForegroundOverlay(uiDraw, uiInkDraw, uiArt, uiGlow, ctx);
        }
        if (key === "forest") {
            return this.forest.drawForegroundOverlay(uiDraw, uiInkDraw, uiArt, uiGlow, ctx);
        }
        if (key === "outside") {
            this.drawOutsideSewingMemoryOverlay(uiDraw, uiInkDraw, uiArt, uiGlow, ctx);
            return false;
        }
        return false;
    }

    /**
     * 城外栈台首次握车柄回忆（约 0.54s，不锁移动、保留小满手部位置作为视觉锚心）：
     * 以柔和暖雾羽化浮现手绘 f01_mother_stitch（暖灯下母亲缝红布补丁拉紧最后一针），彻底去除旧几何红方块与黑椭圆框。
     */
    private drawOutsideSewingMemoryOverlay(
        uiDraw: DrawNode.Type,
        _uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): void {
        if (this.memoryTimer < 0 || this.memoryTimer >= SEWING_MEMORY_DURATION) {
            return;
        }
        const prog = clamp01(this.memoryTimer / SEWING_MEMORY_DURATION);
        const alpha = smoothstep(0, 0.20, prog) * (1 - smoothstep(0.72, 1.0, prog));
        if (alpha <= 0.01) {
            return;
        }
        const inv = 1 / Math.max(0.25, ctx.uiScale);
        const handPt = projectWorld3D(this.memoryAnchorWorldX, this.memoryAnchorWorldY, 0, ctx.cam, this.outsideProj);
        const cx = Math.max(190, Math.min(ctx.uiW - 190, handPt.x * inv - 20));
        const cy = Math.max(170, Math.min(ctx.uiH - 150, handPt.y * inv + 104));
        const pullT = smoothstep(0.14, 0.82, prog);
        const zoom = 0.94 + pullT * 0.09;

        // 柔和暖灯回忆云晕（无生硬蛋形/矩形边框，自然浮于冷月夜空之上）
        fillRadialGlow(uiGlow, cx, cy, 215 * zoom, 152 * zoom, Color(238, 186, 114, Math.round(88 * alpha)), Color(214, 152, 82, 0), 22);
        uiArt.tryPlace("ink_petal_mist", "fe04_f01_memory_mist", cx, cy, 380 * zoom, 260 * zoom, {
            color: Color(36, 24, 18, 255),
            opacity: 0.72 * alpha,
            layer: 3,
        });
        if (!uiArt.tryPlacePath(
            "assets/art/cutscene_story_parts.clip|f01_mother_stitch",
            "fe04_f01_mother_stitch",
            cx + pullT * 6,
            cy + pullT * 4,
            296 * zoom,
            218 * zoom,
            {
                anchorX: 0.5,
                anchorY: 0.5,
                color: Color(246, 224, 196, 255),
                opacity: 0.96 * alpha,
                smooth: true,
                layer: 4,
            },
        )) {
            uiDraw.drawEllipse(Vec2(cx, cy), 116, 70, Color(32, 22, 16, Math.round(196 * alpha)));
        }
    }
}

export function createLowpolyWorldPlugin(): LowpolyWorldPlugin {
    return new LowpolyWorldPlugin();
}

/** 零冲突注册辅助：供 M2 合流接线与 verify-fe04.lua 独立测试调用（避免循环 require） */
export function registerFe04Plugins(fe: { registerPlugin: (plugin: FeRenderPlugin) => void }): {
    lowpolyWorld: LowpolyWorldPlugin;
} {
    const lowpolyWorld = new LowpolyWorldPlugin();
    fe.registerPlugin(lowpolyWorld);
    return { lowpolyWorld };
}
