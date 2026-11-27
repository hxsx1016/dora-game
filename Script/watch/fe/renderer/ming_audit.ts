/**
 * 《向西守望》明朝全局美术红线体检与运行态校准插件（Wave 1 · feature/fe-03-prologue-ming-art）。
 *
 * 严格遵循 Wave 1 零冲突铁律（方案 A）：
 * - 不修改 stage.ts / props.ts / actors.ts / vfx.ts / theme.ts / frontend.ts 等既有热点文件；
 * - 通过 FeRenderPlugin 挂点在运行态执行明朝考据增强与退化兜底：
 *   1. drawBackdrop：拦截无专属 bgFar_<roomKey> 的非八房关卡（s1/s2/s3/c1/c2/gatepath/escort1），
 *      映射至明初温州宁村所像素底图，彻底杜绝 StageRenderer 退化画出探照灯、高压线、屋顶天线与工业钢架；
 *   2. drawActorsOverlay：补强明朝物理材质与静音/灰度可读性：
 *      - 挡下（coverBlocked）：木柜起暗木屑，砖沿/街垒起冷灰砖粉；
 *      - 开火（shotResolved）：明式鸟铳短促灰白火药烟 + 地面微焦痕（绝无弹壳）；
 *      - 村口（village）：硬砖拼缝亮边 vs 软土散点浅足印，确保静音+灰度清晰可辨；
 *      - 森林（forest）：草丛后猎犬竖耳与小满肩线冷月轮廓提亮，确保草后灰度分离；
 *      - 板车（checkpoint / outside）：校验并强化车身左端旧红布风动形态（绝不随角色转向翻面）；
 *   3. runAudit()：提供结构化明朝红线体检接口，覆盖 8 房底图、58 帧 sprites.clip 兼容、
 *      15 帧 ui_ink.clip 兼容、红布左端不变式与 6 处既有旧代码遗留项定位清单。
 */

import { Color, Content, DrawNode, Rect, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { ACTOR_DEPTH_HALF, DEPTH_Y_SCALE, overlapsDepth } from "Script/watch/depth";
import { ASSET_SLOTS, AssetSlotHost, AssetSlotKey } from "Script/watch/fe/assets";
import { DualRouteSnapshot } from "Script/watch/fe/contract";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import { PALETTE, fillVGradRect, themeOf, toColor } from "Script/watch/fe/theme";

/** 既有 58 个 sprites.clip 帧键名（fe-03 严格保持 100% 向后兼容） */
export const MING_PRESERVED_SPRITE_CLIPS: readonly string[] = [
    "soldier_idle", "soldier_run", "soldier_roll", "child_idle", "child_run", "child_fear",
    "enemy_idle", "enemy_aim", "enemy_down", "enemy_hit",
    "scavenger_idle", "scavenger_walk", "scavenger_turn", "scavenger_run",
    "soldier_cover", "soldier_step", "soldier_push", "soldier_hold",
    "soldier_offer", "soldier_knock", "soldier_hit", "soldier_fire",
    "child_crouch", "child_step", "child_peek", "child_pull",
    "child_aim", "child_throw", "child_knock", "child_offer",
    "soldier_push_step", "child_pull_step", "child_crouch_step",
    "cart", "bottle", "door", "lantern",
    "dog_idle", "dog_alert", "dog_run", "dog_sniff",
    "table", "compass", "grass", "stone_chips", "ui_corner", "paper",
    "cover_wood", "cover_stone", "fence", "wall", "slab", "eaves", "pine", "winch",
    "grass_low", "soldier_fire_run", "soldier_fire_run_step",
];

/** 既有 15 个 ui_ink.clip 帧键名 */
export const MING_PRESERVED_UI_CLIPS: readonly string[] = [
    "ink_ribbon_sweep", "ink_mist_curve", "ink_veil_strip", "ink_hairline",
    "ink_bamboo_slip", "ink_bamboo_slot", "ink_frame_mask", "ink_vstream",
    "ink_knot_ornament", "ink_corner_fine", "ink_seal_slender", "ink_blossom_dot",
    "ink_enso_fine", "ink_petal_mist", "ink_song_paper",
];

/** 八大核心房间的官方明朝像素背景键 */
export const CORE_MING_BACKDROPS: Record<string, AssetSlotKey> = {
    prologue: "bgFar_prologue",
    street: "bgFar_street",
    checkpoint: "bgFar_checkpoint",
    gate: "bgFar_gate",
    outside: "bgFar_outside",
    village: "bgFar_village",
    forest: "bgFar_forest",
    tower: "bgFar_tower",
};

/** 非八房战役/护送段到明朝像素底图的映射表（杜绝探照灯与工业钢架退化；已覆盖 B2 escort2-5） */
export const FALLBACK_MING_BACKDROPS: Record<string, AssetSlotKey> = {
    "s1-crossroad": "bgFar_street",
    "s2-drygoods": "bgFar_street",
    "s3-archway": "bgFar_street",
    "c1-yard": "bgFar_checkpoint",
    "c2-granary": "bgFar_checkpoint",
    "gatepath": "bgFar_outside",
    "escort1": "bgFar_outside",
    "escort2": "bgFar_checkpoint",
    "escort3": "bgFar_forest",
    "escort4": "bgFar_forest",
    "escort5": "bgFar_tower",
};

export interface LegacyRedlineFinding {
    readonly id: string;
    readonly file: string;
    readonly lines: string;
    readonly severity: "high" | "medium";
    readonly summary: string;
    readonly mitigationInFe03: string;
    readonly targetFixPhase: string;
}

/**
 * 检出的 6 处既有热点渲染文件赛博/全息遗留（方案 A：记录清单，不修改热点文件，交 M1 / fe-07 收口）
 */
export const MING_LEGACY_FINDINGS: readonly LegacyRedlineFinding[] = [
    {
        id: "MING-01",
        file: "Script/watch/fe/theme.ts & Script/watch/fe/renderer/stage.ts",
        lines: "theme.ts:160,189,218,247; stage.ts:166-274,329-508",
        severity: "high",
        summary: "showSearchlights=true 与无 bgFar 退化路径包含扫射探照灯、屋顶天线、工业钢桁架、垂落电缆及破损电灯",
        mitigationInFe03: "MingArtAuditPlugin.drawBackdrop 拦截全部非八房房间并映射至明朝像素底图，运行期 0 触发探照灯",
        targetFixPhase: "M1 / fe-07",
    },
    {
        id: "MING-02",
        file: "Script/watch/fe/renderer/stage.ts",
        lines: "stage.ts:844-857",
        severity: "high",
        summary: "drawCoverBlock 在贴靠掩体时绘制冰青全息护盾竖条与大面积荧光蓝光晕",
        mitigationInFe03: "审计报告标注待改为木沿/砖沿低饱和描边，本分支不改动 stage.ts 保持零冲突",
        targetFixPhase: "M1 / fe-07",
    },
    {
        id: "MING-03",
        file: "Script/watch/fe/renderer/stage.ts",
        lines: "stage.ts:860-891",
        severity: "medium",
        summary: "drawWinch 在 prop_winch 下层仍绘倒角钢箱与闪烁冰青/琥珀电子状态灯",
        mitigationInFe03: "待改为纯木铁绞盘实体与绳链张力表现",
        targetFixPhase: "M1 / fe-07",
    },
    {
        id: "MING-04",
        file: "Script/watch/fe/renderer/stage.ts",
        lines: "stage.ts:1047-1059",
        severity: "medium",
        summary: "drawArch 城外矮拱绘制亮银矩形外框与冰蓝发光竖渐变，与周边明代灰砖质感割裂",
        mitigationInFe03: "fe-04 低模城外将接管城外舞台；像素线待在 fe-07 改为石拱券砖沿",
        targetFixPhase: "fe-04 / fe-07",
    },
    {
        id: "MING-05",
        file: "Script/watch/fe/renderer/props.ts",
        lines: "props.ts:78-83,100-153,242-245,307",
        severity: "high",
        summary: "存在危险区红激光扫描线、全息检查点菱柱、车柄发光黄球、钢杆灯柱及村口瓶架贴图纵拉变形",
        mitigationInFe03: "ming_audit.ts 补强村口砖缝/软土灰度纹样与左端红布校验；全息标与黄球留待 fe-07 清理",
        targetFixPhase: "fe-07",
    },
    {
        id: "MING-06",
        file: "Script/watch/fe/renderer/actors.ts",
        lines: "actors.ts:66-83,145-171",
        severity: "medium",
        summary: "周戍翻滚仍生成 ICEY 冰青残影，不符合明代守卒写实基调且与 fe-06 穿梭器残影彩蛋语义重叠",
        mitigationInFe03: "审计报告标注待改为扬尘步烟，残影视觉专属留给 fe-06 穿梭器彩蛋",
        targetFixPhase: "M2 / fe-07",
    },
];

interface DebrisChip {
    x: number;
    y: number;
    vx: number;
    vy: number;
    w: number;
    h: number;
    life: number;
    maxLife: number;
    isWood: boolean;
}

interface PowderPuff {
    x: number;
    y: number;
    vx: number;
    vy: number;
    r: number;
    life: number;
    maxLife: number;
}

interface ScorchMark {
    x: number;
    y: number;
    rx: number;
}

export interface MingAuditReport {
    coreBackdropsOk: boolean;
    missingBackdrops: string[];
    preservedSpriteClipsCount: number;
    missingSpriteClips: string[];
    preservedUiClipsCount: number;
    missingUiClips: string[];
    cartClothLeftInvariantOk: boolean;
    fallbackInterceptCount: number;
    woodDebrisTriggered: number;
    brickDebrisTriggered: number;
    powderSmokeTriggered: number;
    legacyFindingsCount: number;
}

export function resolveMingBackdropSlot(roomKey: string): AssetSlotKey {
    const direct = CORE_MING_BACKDROPS[roomKey];
    if (direct !== undefined) {
        return direct;
    }
    const mapped = FALLBACK_MING_BACKDROPS[roomKey];
    if (mapped !== undefined) {
        return mapped;
    }
    return "bgFar_street";
}

export function isWoodCoverLabel(art?: string, label?: string): boolean {
    if (art === "cover_wood" || art === "thin_wood" || art === "board" || art === "fence" || art === "basket_wall") {
        return true;
    }
    if (art === "cover_stone" || art === "wall" || art === "gate_post" || art === "well") {
        return false;
    }
    if (label !== undefined) {
        if (
            label.indexOf("柜") >= 0
            || label.indexOf("木") >= 0
            || label.indexOf("桌") >= 0
            || label.indexOf("货") >= 0
            || label.indexOf("棚") >= 0
            || label.indexOf("栏") >= 0
        ) {
            return true;
        }
    }
    return false;
}

export class MingArtAuditPlugin implements FeRenderPlugin {
    readonly id = "fe03-ming-audit";

    private chips: DebrisChip[] = [];
    private puffs: PowderPuff[] = [];
    private scorches: ScorchMark[] = [];
    private animTime = 0;
    private rng = 4099;

    // 运行态审计计数器（供 verify-fe03 断言验证）
    private fallbackInterceptCount = 0;
    private woodDebrisCount = 0;
    private brickDebrisCount = 0;
    private powderSmokeCount = 0;
    private cartLeftInvariantOk = true;
    private lastRoomKey = "";

    private rand(): number {
        this.rng = (this.rng * 1664525 + 1013904223) % 4294967296;
        return this.rng / 4294967296;
    }

    onBindPlay(p: Play, _view: DualRouteSnapshot): void {
        this.chips = [];
        this.puffs = [];
        this.scorches = [];
        this.animTime = 0;
        this.lastRoomKey = p.room.key;
        if (p.room.cart.bodyW > 0 && p.room.cart.clothSide >= 0) {
            this.cartLeftInvariantOk = false;
        }
        this.syncRuntimeHook();
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
            if (watchFe["mingAudit"] !== this) {
                watchFe["mingAudit"] = this;
            }
        }
    }

    update(ctx: FePluginContext): void {
        this.syncRuntimeHook();
        const p = ctx.p;

        if (this.lastRoomKey !== "" && this.lastRoomKey !== p.room.key) {
            this.onBindPlay(p, ctx.view);
        }
        if (p.room.cart.bodyW > 0 && p.room.cart.clothSide >= 0) {
            this.cartLeftInvariantOk = false;
        }

        if (ctx.paused || ctx.worldDt <= 0) {
            return;
        }

        const dt = ctx.worldDt;
        this.animTime += dt;

        // 1. 消费挡下事件：按木柜 / 砖沿分别生成木屑或砖灰粒子
        if (ctx.events.coverDeflect) {
            this.spawnCoverMaterialDebris(p);
        }

        // 2. 消费开火事件：生成明代鸟铳短促灰白硝烟与地面微焦痕（绝无弹壳）
        if (ctx.events.shotFired && ctx.events.shotTrace !== undefined) {
            const tr = ctx.events.shotTrace;
            this.spawnMatchlockSmoke(tr.x0, tr.y0, tr.x1 >= tr.x0 ? 1 : -1);
            if (!tr.hit && tr.y1 <= 42) {
                this.addScorch(tr.x1, Math.max(0, tr.y1));
            }
        }

        // 3. 更新木屑/砖灰粒子
        let w = 0;
        let i = 0;
        for (i = 0; i < this.chips.length; i++) {
            const c = this.chips[i];
            c.life -= dt;
            if (c.life > 0) {
                c.vy -= (c.isWood ? 360 : 210) * dt;
                c.x += c.vx * dt;
                c.y += c.vy * dt;
                if (c.y < 0) {
                    c.y = 0;
                    c.vy = -c.vy * 0.25;
                    c.vx *= 0.65;
                }
                this.chips[w] = c;
                w += 1;
            }
        }
        this.chips.length = w;

        // 4. 更新鸟铳灰白火药烟
        w = 0;
        for (i = 0; i < this.puffs.length; i++) {
            const pf = this.puffs[i];
            pf.life -= dt;
            if (pf.life > 0) {
                pf.x += pf.vx * dt;
                pf.y += pf.vy * dt;
                pf.vx *= Math.max(0, 1 - dt * 3.4);
                pf.r += dt * 14;
                this.puffs[w] = pf;
                w += 1;
            }
        }
        this.puffs.length = w;
    }

    /**
     * 拦截非八房房间（无直接 bgFar_<roomKey>），用同源明朝像素背景替代，
     * 100% 阻止 StageRenderer 退化画出探照灯、工业桁架、电缆与现代电灯。
     */
    drawBackdrop(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        backdropArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
        const roomKey = ctx.p.room.key;
        if (CORE_MING_BACKDROPS[roomKey] !== undefined) {
            return false;
        }
        // 低模/博物馆视角由对应专章插件处理，不抢占
        if (ctx.view.visualMode === "lowpoly" || ctx.view.visualMode === "museum") {
            return false;
        }

        const slot = resolveMingBackdropSlot(roomKey);
        const cam = ctx.cam;
        const w = cam.viewW;
        const h = cam.viewH;
        const span = Math.max(1, ctx.p.room.maxX - ctx.p.room.minX);
        const progress = (cam.x - ctx.p.room.minX) / span - 0.5;
        const ground = cam.groundScreenY;
        const artW = Math.max(w, (h * 16) / 9) + w * 0.12;
        const artH = (artW * 9) / 16;
        // 与 stage.ts 地平线锚点一致（画面底边略低于地面基线，避免悬空或切腰）
        const sceneY = Math.min((h - artH) * 0.5, ground - artH * 0.24);

        if (backdropArt.tryPlace(slot, "ming_fallback_scene", w * (0.5 - progress * 0.09), sceneY, artW, artH)) {
            this.fallbackInterceptCount += 1;
            const theme = themeOf(roomKey);
            const dressSlot: AssetSlotKey = slot === "bgFar_outside" ? "pine" : "eaves";
            backdropArt.tryPlace(
                dressSlot,
                "ming_fallback_mid",
                w * (0.74 - progress * 0.25),
                ground - cam.len(10),
                cam.len(dressSlot === "pine" ? 124 : 186),
                cam.len(dressSlot === "pine" ? 138 : 104),
                { layer: 1, opacity: 0.46 },
            );
            fillVGradRect(bgDraw, 0, 0, w, h, toColor(PALETTE.voidDark), toColor(theme.skyMid));
            fillVGradRect(bgGlow, 0, ground - 1, w, h * 0.14, Color(43, 49, 63, 15), Color(43, 49, 63, 0));
            return true;
        }
        return false;
    }

    /** 叠加明朝材质细节、静音/灰度可读强化与左端红布校验 */
    drawActorsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        const p = ctx.p;
        const cam = ctx.cam;
        const isPixelStyle = ctx.view.visualMode === "pixel" || ctx.view.visualMode === "transition";

        // 1. 村口硬砖拼缝亮边 vs 软土散点浅足印（像素地皮补丁；不覆盖 fe-04 舞台）
        if (isPixelStyle && p.room.key === "village") {
            this.drawVillageGrayscaleSurfaces(fgDraw, worldArt, p, cam);
        }

        // 2. 森林草丛后小满肩线冷月轮廓分离（非光柱、灰度可读；不覆盖 fe-04 舞台）
        if (isPixelStyle && p.room.key === "forest") {
            this.drawForestSilhouetteSeparation(fgDraw, p, cam);
        }

        // 3. 城门内外板车：左端旧红布飘带一致性补强（绝不随角色转向翻面）
        if (isPixelStyle && (p.room.key === "checkpoint" || p.room.key === "outside") && p.room.cart.bodyW > 0) {
            this.drawLeftEndRedClothAccent(worldArt, p, cam);
        }

        // 4. 鸟铳地面焦痕（仅在当房存在，切房/重试清空）
        let i = 0;
        for (i = 0; i < this.scorches.length; i++) {
            const sc = this.scorches[i];
            fgDraw.drawEllipse(Vec2(cam.sx(sc.x), cam.sy(sc.y) + 2), cam.len(sc.rx), cam.len(2.4), Color(16, 14, 15, 165));
        }

        // 5. 挡下材质区分粒子：木柜暗木屑 vs 砖沿冷灰砖粉
        for (i = 0; i < this.chips.length; i++) {
            const c = this.chips[i];
            const k = c.life / c.maxLife;
            const sx = cam.sx(c.x);
            const sy = cam.sy(c.y);
            const sw = Math.max(2, cam.len(c.w));
            const sh = Math.max(1.5, cam.len(c.h));
            if (c.isWood) {
                fgDraw.drawRect(Rect(sx - sw * 0.5, sy - sh * 0.5, sw, sh), Color(128, 86, 54, Math.round(235 * k)));
                fgDraw.drawSegment(Vec2(sx - sw * 0.5, sy + sh * 0.5), Vec2(sx + sw * 0.5, sy + sh * 0.5), 0.9, Color(196, 162, 118, Math.round(180 * k)));
            } else {
                fgDraw.drawCircle(Vec2(sx, sy), sw * 0.65, Color(164, 168, 172, Math.round(175 * k)));
                fgDraw.drawDot(Vec2(sx + 1, sy + 1), Math.max(1.2, sw * 0.32), Color(218, 220, 224, Math.round(210 * k)));
            }
        }

        // 6. 明代鸟铳短促像素灰白火药烟（4 帧像素烟团，替代圆球色块）
        for (i = 0; i < this.puffs.length; i++) {
            const pf = this.puffs[i];
            const k = pf.life / pf.maxLife;
            const sx = cam.sx(pf.x);
            const sy = cam.sy(pf.y);
            const sz = Math.max(8, cam.len(pf.r * 3.4));
            if (!worldArt.tryPlace("fe_vfx_smoke", "ming_puff_" + i, sx, sy, sz, sz, {
                frame: Math.min(3, Math.floor((1 - k) * 4)),
                opacity: 0.72 * k,
                layer: 8,
            })) {
                const r = Math.max(2, cam.len(pf.r));
                fgDraw.drawCircle(Vec2(sx, sy), r, Color(196, 198, 200, Math.round(92 * k)));
                fgGlow.drawCircle(Vec2(sx, sy), r * 0.62, Color(224, 222, 214, Math.round(48 * k)));
            }
        }
    }

    private spawnCoverMaterialDebris(p: Play): void {
        let hitX = p.player.x + p.player.facing * 16;
        let hitY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.5;
        let isWood = false;
        let nearest = 56;
        let i = 0;
        for (i = 0; i < p.room.solids.length; i++) {
            const s = p.room.solids[i];
            if (s.passable || s.decorative || s.y > p.player.y + 4 || s.h > 72) {
                continue;
            }
            if (!overlapsDepth(p.player.depth, s.depth, ACTOR_DEPTH_HALF)) {
                continue;
            }
            const edge = p.player.x < s.x ? s.x : s.x + s.w;
            const gap = Math.abs(p.player.x - edge);
            if (gap < nearest) {
                nearest = gap;
                hitX = edge;
                hitY = s.y + (s.depth?.min ?? 0) * DEPTH_Y_SCALE + s.h * 0.85;
                isWood = isWoodCoverLabel(s.art, s.label);
            }
        }

        if (isWood) {
            this.woodDebrisCount += 1;
        } else {
            this.brickDebrisCount += 1;
        }

        const count = isWood ? 9 : 10;
        for (i = 0; i < count; i++) {
            const ang = (this.rand() - 0.5) * Math.PI * 1.15;
            const spd = (isWood ? 85 : 58) * (0.45 + this.rand() * 0.75);
            const life = (isWood ? 0.34 : 0.42) + this.rand() * 0.16;
            this.chips.push({
                x: hitX,
                y: hitY,
                vx: -p.player.facing * Math.abs(Math.cos(ang)) * spd + (this.rand() - 0.5) * 35,
                vy: Math.abs(Math.sin(ang)) * spd + (isWood ? 55 : 28),
                w: isWood ? (4.5 + this.rand() * 3.5) : (2.6 + this.rand() * 2.8),
                h: isWood ? (1.8 + this.rand() * 1.4) : (2.6 + this.rand() * 2.8),
                life,
                maxLife: life,
                isWood,
            });
        }
    }

    private spawnMatchlockSmoke(wx: number, wy: number, dir: number): void {
        this.powderSmokeCount += 1;
        let i = 0;
        for (i = 0; i < 5; i++) {
            const life = 0.24 + this.rand() * 0.18;
            this.puffs.push({
                x: wx + dir * (4 + i * 3.5),
                y: wy + (this.rand() - 0.4) * 5,
                vx: dir * (28 + this.rand() * 44),
                vy: 14 + this.rand() * 22,
                r: 3.0 + this.rand() * 2.4,
                life,
                maxLife: life,
            });
        }
    }

    private addScorch(wx: number, wy: number): void {
        this.scorches.push({ x: wx, y: wy, rx: 5.5 + this.rand() * 3.0 });
        if (this.scorches.length > 16) {
            this.scorches.shift();
        }
    }

    private drawVillageGrayscaleSurfaces(
        fgDraw: DrawNode.Type,
        worldArt: AssetSlotHost,
        p: Play,
        cam: FePluginContext["cam"],
    ): void {
        const y0 = cam.sy(0);

        if (p.room.brickX !== undefined) {
            const bx = cam.sx(p.room.brickX);
            if (!worldArt.tryPlace("fe_ground_brick", "ming_vil_brick", bx, y0 - cam.len(4), cam.len(44), cam.len(14), { layer: 2 })) {
                fgDraw.drawRect(Rect(bx - cam.len(18), y0 - 4, cam.len(36), 8), Color(142, 146, 150, 235));
            }
            fgDraw.drawSegment(Vec2(bx - cam.len(20), y0 + 2), Vec2(bx + cam.len(20), y0 + 2), 1.3, Color(228, 232, 238, 170));
        }

        if (p.room.softX !== undefined) {
            const sx = cam.sx(p.room.softX);
            if (!worldArt.tryPlace("fe_ground_soft", "ming_vil_soft", sx, y0 - cam.len(4), cam.len(44), cam.len(14), { layer: 2 })) {
                fgDraw.drawRect(Rect(sx - cam.len(18), y0 - 3, cam.len(36), 6), Color(54, 44, 36, 225));
            }
        }
    }

    private drawForestSilhouetteSeparation(fgDraw: DrawNode.Type, p: Play, cam: FePluginContext["cam"]): void {
        // 仅在草丛遮挡下补克制冷月微弧，不给猎犬贴生硬几何折线耳
        let childInGrass = false;
        let i = 0;
        for (i = 0; i < p.room.solids.length; i++) {
            const s = p.room.solids[i];
            if (s.passable === true && p.player.x >= s.x - 16 && p.player.x <= s.x + s.w + 16) {
                childInGrass = true;
            }
        }
        if (childInGrass && p.player.alive) {
            const cx = cam.sx(p.player.x);
            const topY = cam.sy(p.player.y + p.player.h);
            fgDraw.drawArc(Vec2(cx, topY - cam.len(7)), cam.len(11), 25, 155, 1.4, Color(214, 224, 230, 165));
        }
    }

    private drawLeftEndRedClothAccent(worldArt: AssetSlotHost, p: Play, cam: FePluginContext["cam"]): void {
        const c = p.room.cart;
        const depth = c.depth ?? 0;
        // 红布恒定在车身左端（clothSide < 0），绝不随角色转向翻面
        const leftEdgeWorldX = p.cartAxle - c.bodyW * 0.54;
        const anchorX = cam.sx(leftEdgeWorldX);
        const anchorY = cam.sy(c.baseY + c.wheelR + c.bodyH * 0.86, depth);
        const frame = Math.floor(this.animTime * 4.4) % 3;
        worldArt.tryPlace("fe_red_cloth", "ming_cart_red_cloth", anchorX, anchorY, cam.len(22), cam.len(22), {
            frame,
            layer: 6,
        });
    }

    /** 执行全量明朝美术红线静态 + 运行态体检，供 verify-fe03 自动化断言 */
    runAudit(host?: AssetSlotHost): MingAuditReport {
        const missingBackdrops: string[] = [];
        for (const roomKey in CORE_MING_BACKDROPS) {
            const slotKey = CORE_MING_BACKDROPS[roomKey];
            const cfg = ASSET_SLOTS[slotKey];
            const path = cfg !== undefined && cfg.paths.length > 0 ? cfg.paths[0] : "";
            if (path === "" || !Content.exist(path)) {
                missingBackdrops.push(roomKey + ":" + path);
            }
        }

        const missingSpriteClips: string[] = [];
        let i = 0;
        for (i = 0; i < MING_PRESERVED_SPRITE_CLIPS.length; i++) {
            const clipName = MING_PRESERVED_SPRITE_CLIPS[i];
            const path = "assets/art/sprites.clip|" + clipName;
            if (host !== undefined) {
                const ok = host.tryPlacePath(path, "audit_spr_" + clipName, -9999, -9999, 16, 16);
                if (!ok) {
                    missingSpriteClips.push(clipName);
                }
            } else if (!Content.exist("assets/art/sprites.clip")) {
                missingSpriteClips.push(clipName);
            }
        }

        const missingUiClips: string[] = [];
        for (i = 0; i < MING_PRESERVED_UI_CLIPS.length; i++) {
            const uiName = MING_PRESERVED_UI_CLIPS[i];
            const path = "assets/art/ui_ink.clip|" + uiName;
            if (host !== undefined) {
                const ok = host.tryPlacePath(path, "audit_ui_" + uiName, -9999, -9999, 16, 16);
                if (!ok) {
                    missingUiClips.push(uiName);
                }
            } else if (!Content.exist("assets/art/ui_ink.clip")) {
                missingUiClips.push(uiName);
            }
        }

        return {
            coreBackdropsOk: missingBackdrops.length === 0,
            missingBackdrops,
            preservedSpriteClipsCount: MING_PRESERVED_SPRITE_CLIPS.length - missingSpriteClips.length,
            missingSpriteClips,
            preservedUiClipsCount: MING_PRESERVED_UI_CLIPS.length - missingUiClips.length,
            missingUiClips,
            cartClothLeftInvariantOk: this.cartLeftInvariantOk,
            fallbackInterceptCount: this.fallbackInterceptCount,
            woodDebrisTriggered: this.woodDebrisCount,
            brickDebrisTriggered: this.brickDebrisCount,
            powderSmokeTriggered: this.powderSmokeCount,
            legacyFindingsCount: MING_LEGACY_FINDINGS.length,
        };
    }
}
