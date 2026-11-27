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
import { DualRouteSnapshot } from "Script/watch/fe/contract";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import {
    LowpolyProjection,
    clamp01,
    projectWorld3D,
    smoothstep,
} from "Script/watch/fe/renderer/lowpoly";
import {
    drawChildColdMoonGrade,
    drawPixelSlidePlate,
    drawSlideFrameChrome,
} from "Script/watch/fe/renderer/slideshow";
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
            return this.drawOutsideBackdrop(bgDraw, bgGlow, backdropArt, ctx);
        }
        if (key === "tower") {
            return this.drawTowerBackdrop(bgDraw, bgGlow, backdropArt, ctx);
        }
        return false;
    }

    private drawOutsideBackdrop(
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

        // 冷月海风底天（作为像素远景图的兜底）
        fillVGradRect(bgDraw, 0, 0, w, h, Color(24, 34, 52, 255), Color(8, 13, 22, 255));

        const span = Math.max(1, p.room.maxX - p.room.minX);
        const progress = (cam.x - p.room.minX) / span - 0.5;
        const artW = Math.max(w, (h * 16) / 9) * 1.24;
        const artH = (artW * 9) / 16;
        const artY = Math.min(0, Math.max(h - artH, cam.groundScreenY - artH * 0.24));
        backdropArt.tryPlace("bgFar_outside", "fe04_bg_outside", w * (0.5 - progress * 0.08), artY, artW, artH, {
            color: Color(172, 194, 224, 255),
            layer: 0,
        });

        // 远景冷月微晕与远山北塔一豆暖灯（引导尽头 x ≈ 1120，无任务光柱）
        const y = cam.groundScreenY;
        fillVGradRect(bgGlow, 0, y - 2, w, h * 0.16, Color(34, 48, 70, 26), Color(16, 26, 42, 0));

        const beaconP = projectWorld3D(ox + 1140, 154, 410, cam, this.outsideProj);
        const pulse = 0.84 + 0.16 * Math.sin(this.animTime * 2.2);
        fillRadialGlow(bgGlow, beaconP.x, beaconP.y, 30 * pulse, 30 * pulse, Color(246, 208, 138, Math.round(84 * pulse)), Color(232, 176, 86, 0), 14);
        bgGlow.drawDot(Vec2(beaconP.x, beaconP.y), 2.3, Color(255, 244, 212, 230));

        return true;
    }

    private drawTowerBackdrop(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        backdropArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const cam = ctx.cam;
        const p = ctx.p;
        const w = cam.viewW;
        const h = cam.viewH;

        fillVGradRect(bgDraw, 0, 0, w, h, Color(34, 42, 58, 255), Color(12, 18, 30, 255));
        const span = Math.max(1, p.room.maxX - p.room.minX);
        const progress = (cam.x - p.room.minX) / span - 0.5;
        const artW = Math.max(w, (h * 16) / 9) * 1.24;
        const artH = (artW * 9) / 16;
        const artY = Math.min(0, Math.max(h - artH, cam.groundScreenY - artH * 0.24));
        backdropArt.tryPlace("bgFar_tower", "fe04_bg_tower", w * (0.5 - progress * 0.08), artY, artW, artH, {
            color: Color(184, 198, 222, 255),
            layer: 0,
        });
        fillVGradRect(bgGlow, 0, cam.groundScreenY - 2, w, h * 0.14, Color(44, 50, 66, 20), Color(20, 26, 38, 0));

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
            return this.drawOutsideWorld(fgDraw, fgGlow, worldArt, ctx);
        }
        if (key === "tower") {
            return this.drawTowerWorld(fgDraw, fgGlow, worldArt, ctx);
        }
        return false;
    }

    private drawOutsideWorld(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const ox = p.ox;
        const coldStone = Color(168, 186, 210, 255);
        const coldWall = Color(156, 174, 198, 255);

        // 1. 地面与上层栈台（全部使用像素石砖地坪，彻底移除伪3D色块盒子）
        let fi = 0;
        for (fi = 0; fi < p.room.floors.length; fi++) {
            const fl = p.room.floors[fi];
            const left = cam.sx(fl.x0);
            const right = cam.sx(fl.x1);
            const top = cam.sy(fl.y);
            const isMain = fl.y <= 0.1;
            const deckH = cam.len(isMain ? 26 : 14);
            const bot = top - deckH;
            if (isMain && bot > 0) {
                fillVGradRect(fgDraw, left, 0, right - left, bot + 1, Color(10, 14, 22, 255), Color(24, 32, 46, 255));
            }
            const step = Math.max(24, cam.len(76));
            const start = Math.max(0, Math.floor(-left / step));
            let j = start;
            for (j = start; left + j * step < Math.min(right, cam.viewW + 40); j++) {
                const tx = left + j * step;
                const tw = Math.min(step, right - tx);
                if (tw <= 2) {
                    continue;
                }
                worldArt.tryPlace(isMain ? "fe_road_stone" : "slab", "fe04_out_fl_" + fi + "_" + j, tx + tw * 0.5, bot, tw + 0.5, deckH, {
                    color: coldStone,
                    layer: 1,
                });
            }
            fgDraw.drawSegment(Vec2(left, top), Vec2(right, top), 1.1, Color(142, 166, 192, 125));
        }

        // 2. 下层水门暗廊背景墙与低拱石洞（严格无垂布遮挡净空）
        const a = p.room.arch;
        if (a.h > 0 && a.x1 > a.x0) {
            const ax0 = cam.sx(a.x0);
            const ax1 = cam.sx(a.x1);
            const ay0 = cam.sy(a.y);
            const ay1 = cam.sy(a.y + a.h);
            const aw = ax1 - ax0;
            const ah = ay1 - ay0;
            fgDraw.drawRect(Rect(ax0, ay0, aw, ah + cam.len(10)), Color(10, 14, 22, 232));
            worldArt.tryPlace("fe_outside_arch", "fe04_out_arch", (ax0 + ax1) * 0.5, ay0, aw + cam.len(26), ah + cam.len(24), {
                color: coldStone,
                layer: 2,
            });
            // 板车未入窝前，车底木栓探入拱口，直观呈现「拉车开拱」因果
            if (!p.cartDocked) {
                const bx0 = Math.max(a.x0 + 4, p.cartAxle - 18);
                const bx1 = Math.min(a.x1 - 4, p.cartAxle + 18);
                if (bx1 > bx0 + 4) {
                    const sbx0 = cam.sx(bx0);
                    const sbx1 = cam.sx(bx1);
                    const deckY = cam.sy(p.room.cart.baseY);
                    worldArt.tryPlace("fe_pillar_wood", "fe04_arch_bolt", (sbx0 + sbx1) * 0.5, ay0 + 2, sbx1 - sbx0, ah - 2, {
                        color: Color(172, 182, 198, 255),
                        layer: 3,
                    });
                    fgDraw.drawSegment(Vec2((sbx0 + sbx1) * 0.5, ay1), Vec2((sbx0 + sbx1) * 0.5, deckY), Math.max(2, cam.len(2.4)), Color(96, 108, 124, 225));
                }
            }
        }

        // 3. 石阶（像素砖石平铺）
        let si = 0;
        for (si = 0; si < p.room.stairs.length; si++) {
            const st = p.room.stairs[si];
            const n = Math.max(1, st.steps + 1);
            const stepW = (st.x1 - st.x0) / n;
            const flatTop = Math.abs(st.y1 - st.y0) < 0.01;
            const baseWY = flatTop ? 0 : Math.max(0, st.y0);
            let k = 0;
            for (k = 0; k < n; k++) {
                const wy = n <= 1 ? st.y1 : (st.y0 + ((st.y1 - st.y0) * k) / (n - 1));
                const x0 = cam.sx(st.x0 + stepW * k);
                const x1 = cam.sx(st.x0 + stepW * (k + 1));
                if (x1 < -20 || x0 > cam.viewW + 20) {
                    continue;
                }
                const y0 = cam.sy(baseWY);
                const y1 = cam.sy(wy);
                if (y1 > y0 + 2) {
                    worldArt.tryPlace("wall", "fe04_st_" + si + "_" + k, (x0 + x1) * 0.5, y0, x1 - x0 + 0.5, y1 - y0, {
                        color: coldWall,
                        opacity: 0.90,
                        layer: 1,
                    });
                    worldArt.tryPlace("slab", "fe04_st_top_" + si + "_" + k, (x0 + x1) * 0.5, y1 - cam.len(4), x1 - x0 + 0.5, cam.len(4.5), {
                        color: coldStone,
                        layer: 2,
                    });
                }
            }
        }

        // 4. 城墙与石墩实体（像素砖墙等比平铺，跳过红布车）
        for (si = 0; si < p.room.solids.length; si++) {
            const s = p.room.solids[si];
            if (s.decorative === true || s.id === "outside_red_cart") {
                continue;
            }
            const x0 = cam.sx(s.x);
            const x1 = cam.sx(s.x + s.w);
            const y0 = cam.sy(s.y);
            const y1 = cam.sy(s.y + s.h);
            const sw = x1 - x0;
            const sh = y1 - y0;
            if (sw <= 1 || sh <= 1 || x1 < -20 || x0 > cam.viewW + 20) {
                continue;
            }
            if (s.y > 10) {
                const gy = cam.sy(0);
                const pierW = cam.len(18);
                worldArt.tryPlace("wall", "fe04_pier_l_" + si, x0 + pierW * 0.5, gy, pierW, y0 - gy, { color: Color(122, 138, 162, 255), layer: 1 });
                worldArt.tryPlace("wall", "fe04_pier_r_" + si, x1 - pierW * 0.5, gy, pierW, y0 - gy, { color: Color(122, 138, 162, 255), layer: 1 });
            }
            const cols = Math.max(1, Math.min(8, Math.round(s.w / 58)));
            const rows = Math.max(1, Math.min(8, Math.round(s.h / 38)));
            const tw = sw / cols;
            const th = sh / rows;
            let r = 0;
            let col = 0;
            for (r = 0; r < rows; r++) {
                for (col = 0; col < cols; col++) {
                    worldArt.tryPlace("wall", "fe04_wall_" + si + "_" + r + "_" + col, x0 + (col + 0.5) * tw, y0 + r * th, tw + 0.5, th + 0.5, {
                        color: coldWall,
                        facing: (r + col) % 2 === 0 ? 1 : -1,
                        layer: 2,
                    });
                }
            }
        }

        // 5. 挡住石阶口的补丁红布独轮车（像素车体 + 左端动画红布）
        const redBox = p.boxes.find((b) => b.id === "outside_red_cart");
        if (redBox !== undefined && redBox.broken !== true && redBox.hidden !== true) {
            const rx0 = cam.sx(redBox.x0);
            const rx1 = cam.sx(redBox.x1);
            const ry0 = cam.sy(redBox.y0);
            const ry1 = cam.sy(redBox.y1);
            const rw = rx1 - rx0;
            const rh = ry1 - ry0;
            worldArt.tryPlace("prop_cart", "fe04_out_red_box", (rx0 + rx1) * 0.5, ry0, rw * 1.15, rh * 1.05, {
                color: Color(192, 206, 224, 255),
                layer: 3,
            });
            const clothFrame = Math.floor(this.animTime * 4.2) % 3;
            worldArt.tryPlace("fe_red_cloth", "fe04_out_red_box_cloth", rx0 + cam.len(6), ry1 - cam.len(4), cam.len(20), cam.len(20), {
                frame: clothFrame,
                layer: 4,
            });
        }

        // 6. 上层栈台木轮车辙与停靠铁窝（c.endX）
        const c = p.room.cart;
        if (c.bodyW > 0) {
            const deckY = cam.sy(c.baseY);
            fgDraw.drawSegment(Vec2(cam.sx(ox + 258), deckY + 1), Vec2(cam.sx(ox + 474), deckY + 1), 1.4, Color(62, 74, 92, 165));
            const dockX = cam.sx(c.endX);
            worldArt.tryPlace("slab", "fe04_cart_dock", dockX, deckY - cam.len(4), cam.len(34), cam.len(6), {
                color: Color(86, 98, 118, 255),
                layer: 2,
            });
        }

        // 7. 墙根尽头远望北塔微暖侧光与小满脚底接触影
        const endGlowX = cam.sx(ox + 1120);
        const endGlowY = cam.sy(76);
        fillRadialGlow(fgGlow, endGlowX, endGlowY, cam.len(96), cam.len(118), Color(234, 198, 138, 34), Color(234, 198, 138, 0), 14);
        fgDraw.drawEllipse(Vec2(cam.sx(p.player.x), cam.sy(p.player.y) + 1), cam.len(14), 3.4, Color(8, 12, 18, 150));

        return true;
    }

    private drawTowerWorld(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const ox = p.ox;
        const opened = p.towerDoorOpen
            || p.phase === "tower-enter"
            || p.phase === "tower-desk"
            || p.phase === "tower-given"
            || p.phase === "tower-end";
        const towerTint = Color(172, 188, 210, 255);
        const groundY = cam.sy(0);

        // 1. 山顶青石走面与门廊石阶
        const gLeft = cam.sx(ox - 40);
        const gRight = cam.sx(ox + 760);
        const deckH = cam.len(26);
        if (groundY - deckH > 0) {
            fillVGradRect(fgDraw, gLeft, 0, gRight - gLeft, groundY - deckH + 1, Color(10, 14, 22, 255), Color(24, 30, 42, 255));
        }
        const step = Math.max(24, cam.len(76));
        let j = 0;
        for (j = 0; gLeft + j * step < gRight; j++) {
            const tx = gLeft + j * step;
            const tw = Math.min(step, gRight - tx);
            worldArt.tryPlace("fe_road_stone", "fe04_tw_floor_" + j, tx + tw * 0.5, groundY - deckH, tw + 0.5, deckH, {
                color: towerTint,
                layer: 1,
            });
        }
        worldArt.tryPlace("slab", "fe04_tw_sill", cam.sx(ox + 445), groundY - cam.len(3), cam.len(94), cam.len(6), {
            color: Color(196, 206, 220, 255),
            layer: 2,
        });

        // 2. 塔身左右厚重青砖墙（像素砖墙等比平铺）
        const tileWallBlock = (prefix: string, wx0: number, wx1: number, wy0: number, wy1: number): void => {
            const x0 = cam.sx(wx0);
            const x1 = cam.sx(wx1);
            const y0 = cam.sy(wy0);
            const y1 = cam.sy(wy1);
            const cols = Math.max(1, Math.round((wx1 - wx0) / 56));
            const rows = Math.max(1, Math.round((wy1 - wy0) / 38));
            const tw = (x1 - x0) / cols;
            const th = (y1 - y0) / rows;
            let r = 0;
            let c = 0;
            for (r = 0; r < rows; r++) {
                for (c = 0; c < cols; c++) {
                    worldArt.tryPlace("wall", prefix + "_" + r + "_" + c, x0 + (c + 0.5) * tw, y0 + r * th, tw + 0.5, th + 0.5, {
                        color: towerTint,
                        facing: (r + c) % 2 === 0 ? 1 : -1,
                        layer: 1,
                    });
                }
            }
        };
        tileWallBlock("fe04_tw_wl", ox + 180, ox + 400, 0, 215);
        tileWallBlock("fe04_tw_wr", ox + 490, ox + 720, 0, 215);
        // 门楣砖石
        tileWallBlock("fe04_tw_lintel", ox + 398, ox + 492, 110, 152);

        // 3. 厚木门扇 vs 开门后实景值夜室（像素室内画面，彻底告别纯色方块人/方块桌）
        const doorCx = cam.sx(ox + 445);
        const doorW = cam.len(90);
        const doorH = cam.len(110);
        const pulse = 0.88 + 0.12 * Math.sin(this.animTime * 2.8);
        if (!opened) {
            worldArt.tryPlace("prop_tower_door", "fe04_tw_door", doorCx, groundY, doorW, doorH, {
                color: Color(204, 212, 224, 255),
                layer: 2,
            });
        } else {
            fillVGradRect(fgGlow, doorCx - doorW * 0.46, groundY, doorW * 0.92, doorH, Color(246, 204, 132, Math.round(92 * pulse)), Color(255, 226, 166, 155));
            const roomX0 = cam.sx(ox + 492);
            const roomX1 = cam.sx(ox + 724);
            worldArt.tryPlace("slide_tower_interior_live", "fe04_tw_room_live", (roomX0 + roomX1) * 0.5, groundY, roomX1 - roomX0, cam.len(172), {
                layer: 2,
            });
        }

        // 4. 门廊悬灯与西窗暖灯（呼应「朝西那盏灯，能留着吗」）
        const lampX = doorCx;
        const lampY = cam.sy(102);
        worldArt.tryPlace("prop_lantern", "fe04_tw_lamp", lampX, lampY, cam.len(16), cam.len(22), { layer: 3 });
        fillRadialGlow(
            fgGlow,
            lampX,
            lampY,
            cam.len(opened ? 68 : 38) * pulse,
            cam.len(opened ? 68 : 38) * pulse,
            Color(248, 214, 146, Math.round((opened ? 132 : 78) * pulse)),
            Color(232, 174, 82, 0),
            16,
        );

        const winX = cam.sx(ox + 296);
        const winY = cam.sy(138);
        fgDraw.drawRect(Rect(winX - cam.len(10), winY - cam.len(18), cam.len(20), cam.len(36)), Color(242, 198, 126, 235), 1.4, Color(68, 52, 38, 235));
        fgDraw.drawSegment(Vec2(winX, winY - cam.len(18)), Vec2(winX, winY + cam.len(18)), 1.3, Color(68, 52, 38, 225));
        fgDraw.drawSegment(Vec2(winX - cam.len(10), winY), Vec2(winX + cam.len(10), winY), 1.3, Color(68, 52, 38, 225));
        fillRadialGlow(fgGlow, winX, winY, cam.len(40), cam.len(44), Color(246, 206, 132, Math.round(78 * pulse)), Color(232, 174, 82, 0), 14);

        // 5. 小满脚底接触影
        fgDraw.drawEllipse(Vec2(cam.sx(p.player.x), cam.sy(p.player.y) + 1), cam.len(14), 3.4, Color(8, 12, 18, 145));

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
            return this.drawOutsideCartLowpoly(fgDraw, fgGlow, worldArt, ctx);
        }
        if (key === "tower") {
            const p = ctx.p;
            const opened = p.towerDoorOpen || p.phase === "tower-enter" || p.phase === "tower-desk";
            if (opened) {
                const cam = ctx.cam;
                const deskCx = cam.sx(p.ox + 605);
                const groundY = cam.sy(0);
                const deskW = cam.len(88);
                const deskH = cam.len(38);
                const deskTop = groundY + deskH;
                const pulse = 0.88 + 0.12 * Math.sin(this.animTime * 2.8);
                fillRadialGlow(fgGlow, deskCx, deskTop + cam.len(28), cam.len(124), cam.len(90),
                    Color(255, 198, 114, Math.round(74 * pulse)), Color(255, 168, 72, 0), 16);
                // 像素守卒提灯与实木值夜桌
                worldArt.tryPlace("fe_tower_guard_lantern", "fe04_tw_guard", deskCx + cam.len(32), groundY, cam.len(54), cam.len(82), {
                    layer: 4,
                });
                worldArt.tryPlace("fe_workbench", "fe04_tw_desk", deskCx, groundY, deskW, deskH, {
                    color: Color(238, 218, 196, 255),
                    layer: 5,
                });
                worldArt.tryPlace("fe_tower_lantern_detail", "fe04_tw_desk_lamp", deskCx + cam.len(30), deskTop - cam.len(2), cam.len(18), cam.len(24), {
                    layer: 6,
                });
                if (p.deskHold >= 12 || p.towerHanded) {
                    worldArt.tryPlace("fe_tower_pouch_note", "fe04_tw_handover", deskCx - cam.len(14), deskTop + cam.len(6), cam.len(30), cam.len(18), {
                        layer: 6,
                    });
                }
            }
            return true;
        }
        return false;
    }

    /** 城外像素红布检修车（右柄抓握、左端旧红布绝不随小满转向翻面、木轮真实滚动、零黄球/全息标） */
    private drawOutsideCartLowpoly(
        fgDraw: DrawNode.Type,
        _fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const p = ctx.p;
        const cam = ctx.cam;
        const c = p.room.cart;
        if (c.bodyW <= 0) {
            return true;
        }
        const halfW = c.bodyW * 0.5;
        const axleX = p.cartAxle;
        const baseY = cam.sy(c.baseY);
        const bodyTopY = cam.sy(c.baseY + c.wheelR + c.bodyH);
        const cx = cam.sx(axleX);
        const artW = cam.len(c.bodyW * 1.38);
        const artH = cam.len((c.wheelR * 2 + c.bodyH) * 0.94);

        fgDraw.drawEllipse(Vec2(cx, baseY + 1), cam.len(c.bodyW * 0.62), 4.0, Color(6, 10, 16, 155));
        worldArt.tryPlace("prop_cart", "fe04_outside_cart", cx, baseY, artW, artH, {
            color: Color(196, 210, 228, 255),
            layer: 5,
        });

        // 车身左端固定旧红布与补丁（恒锚定在 axleX - halfW，绝不随小满转向翻面！）
        const clothX = axleX - halfW;
        const clothFrame = Math.floor(this.animTime * (this.cartWheelVol > 0.05 ? 6.5 : 3.8)) % 3;
        worldArt.tryPlace("fe_red_cloth", "fe04_outside_cart_cloth", cam.sx(clothX + 2), bodyTopY - cam.len(2), cam.len(24), cam.len(24), {
            frame: clothFrame,
            layer: 6,
        });

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
     * 前景遮挡、冷月电影调色与城外 0.5 秒缝布回忆：
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
            drawChildColdMoonGrade(uiDraw, uiGlow, ctx.uiW, ctx.uiH, 0.72, 0);
            this.drawOutsideSewingMemoryOverlay(uiDraw, uiInkDraw, uiArt, uiGlow, ctx);
            return false;
        }
        if (key === "tower") {
            drawChildColdMoonGrade(uiDraw, uiGlow, ctx.uiW, ctx.uiH, 0.44, 0.45);
        }
        return false;
    }

    /**
     * 城外栈台首次握车柄回忆（约 0.54s，不锁移动、保留小满手部位置作为视觉锚心）：
     * 叠出像素绘卷特写（暖灯下家人双指替她缝红布补丁拉紧最后一针），再平滑落回车柄。
     */
    private drawOutsideSewingMemoryOverlay(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): void {
        if (this.memoryTimer < 0 || this.memoryTimer >= SEWING_MEMORY_DURATION) {
            return;
        }
        const prog = clamp01(this.memoryTimer / SEWING_MEMORY_DURATION);
        // 0..0.20 迅速浮现，0.20..0.72 稳拉最后一针，0.72..1.0 柔淡落回车柄
        const alpha = smoothstep(0, 0.20, prog) * (1 - smoothstep(0.72, 1.0, prog));
        if (alpha <= 0.01) {
            return;
        }
        const inv = 1 / Math.max(0.25, ctx.uiScale);
        const handPt = projectWorld3D(this.memoryAnchorWorldX, this.memoryAnchorWorldY, 0, ctx.cam, this.outsideProj);
        const cardW = 264;
        const cardH = 148;
        const cx = Math.max(cardW * 0.5 + 24, Math.min(ctx.uiW - cardW * 0.5 - 24, handPt.x * inv - 16));
        const cy = Math.max(cardH * 0.5 + 32, Math.min(ctx.uiH - cardH * 0.5 - 32, handPt.y * inv + 102));
        const rect = { x: Math.round(cx - cardW * 0.5), y: Math.round(cy - cardH * 0.5), w: cardW, h: cardH };

        fillRadialGlow(uiGlow, cx, cy, cardW * 0.82, cardH * 0.92, Color(238, 190, 122, Math.round(88 * alpha)), Color(218, 162, 92, 0), 20);
        const zoom = 1.0 + prog * 0.036;
        drawPixelSlidePlate(uiDraw, uiInkDraw, uiArt, "slide_f01_sewing", "fe04_sewing_mem", rect, alpha * 0.96, 3, 0, 0, zoom);
        drawSlideFrameChrome(uiDraw, uiInkDraw, uiArt, rect, ctx.uiW, ctx.uiH, {
            frameOpacity: 0.78,
            letterboxH: 0,
            opacity: alpha,
            layer: 3,
            instancePrefix: "fe04_sew",
        });
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
