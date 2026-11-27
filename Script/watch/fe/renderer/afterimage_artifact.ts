/**
 * 《向西守望》Wave 2 · FE-06：「时间穿梭器」移动轨迹残影彩蛋插件。
 *
 * 设计约束（严格对表《wave2-04-06.md》《向西守望-双线后端开发规划》《明朝全局美术设定》）：
 * 1. 严格门控：
 *    - 仅当 `view.archive.artifactOwned === true` 且重玩男主线装备「时间穿梭器」时生效；
 *    - 处于女主线低模、博物馆展厅、未持有神器或装备其他武器时完全关闭并清空残影。
 * 2. 克制视觉，绝不干扰判定与视线：
 *    - 以冷白（霜月素白）外廓与微金（黄铜指南针余韵）细线短暂重现周戍上一段移动轨迹；
 *    - 峰值不透明度严格 <= 0.34，自动跳过距本体 < 12px 的近距重叠采样，不遮挡角色判定盒、掩体边缘与敌方举铳预警线；
 *    - 严禁仙侠光效、满屏拖尾或现代霓虹特效；翻滚期间自动柔化，避免与原生翻滚残影冲突。
 * 3. 双时钟与切房纪律：
 *    - 全程吃 `ctx.worldDt`：换弹慢时（0.25x）自动同步放慢，暂停（worldDt === 0）绝对冻结；
 *    - 切房/重试/卸下/失活立即清空环形采样缓冲，零残留污染。
 */

import { Color, DrawNode, Vec2 } from "Dora";
import { DEPTH_Y_SCALE } from "Script/watch/depth";
import { Play } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { DualRouteSnapshot } from "Script/watch/fe/contract";
import { depthOrder } from "Script/watch/fe/occlusion";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";

export const ARTIFACT_WEAPON_IDS: readonly string[] = [
    "time_shuttler",
    "time_shuttle",
    "shuttler",
    "time_artifact",
    "artifact",
    "时间穿梭器",
];

export function isArtifactWeaponId(weaponId: string): boolean {
    let i = 0;
    for (i = 0; i < ARTIFACT_WEAPON_IDS.length; i++) {
        if (ARTIFACT_WEAPON_IDS[i] === weaponId) {
            return true;
        }
    }
    return false;
}

interface TrajectoryGhost {
    x: number;
    y: number;
    depth: number;
    h: number;
    facing: number;
    crouched: boolean;
    rolling: boolean;
    carrying: boolean;
    life: number;
    maxLife: number;
}

export interface AfterimageArtifactDebugState {
    active: boolean;
    artifactOwned: boolean;
    equipped: boolean;
    equippedWeapon: string;
    ghostCount: number;
    maxGhosts: number;
    totalSpawned: number;
    maxRenderedAlpha: number;
    lastWorldDt: number;
    slowedByTimeScale: boolean;
}

const MAX_GHOSTS = 7;
const SAMPLE_INTERVAL_SEC = 0.056;
const MIN_STEP_DIST_PX = 18.0;
const MIN_DRAW_SEPARATION_PX = 16.0;
const GHOST_MAX_LIFE_SEC = 0.42;
const MAX_GHOST_ALPHA = 0.34;

function asRecord(v: unknown): Record<string, unknown> | undefined {
    if (v !== undefined && typeof v === "object") {
        return v as Record<string, unknown>;
    }
    return undefined;
}

function readBool(rec: Record<string, unknown> | undefined, key: string): boolean | undefined {
    if (rec === undefined) {
        return undefined;
    }
    const val = rec[key];
    return typeof val === "boolean" ? val : undefined;
}

function readStr(rec: Record<string, unknown> | undefined, key: string): string | undefined {
    if (rec === undefined) {
        return undefined;
    }
    const val = rec[key];
    return typeof val === "string" ? val : undefined;
}

function drawEllipseOutline(
    draw: DrawNode.Type,
    cx: number,
    cy: number,
    rx: number,
    ry: number,
    fillCol: Color.Type,
    borderWidth: number,
    borderCol: Color.Type,
    segments: number = 18,
): void {
    if (rx <= 0.4 || ry <= 0.4) {
        return;
    }
    const pts: Vec2.Type[] = [];
    const step = (Math.PI * 2) / segments;
    let i = 0;
    for (i = 0; i < segments; i++) {
        const a = i * step;
        pts.push(Vec2(cx + Math.cos(a) * rx, cy + Math.sin(a) * ry));
    }
    draw.drawPolygon(pts, fillCol, borderWidth, borderCol);
}

export class AfterimageArtifactPlugin implements FeRenderPlugin {
    readonly id = "fe-06-afterimage-artifact";

    private ghosts: TrajectoryGhost[] = [];
    private sampleTimer = 0;
    private hasLastSample = false;
    private lastSampleX = 0;
    private lastSampleY = 0;
    private lastSampleDepth = 0;

    private active = false;
    private lastOwned = false;
    private lastEquipped = false;
    private lastWeaponId = "";
    private totalSpawned = 0;
    private maxRenderedAlpha = 0;
    private lastWorldDt = 0;
    private slowedByTimeScale = false;
    private equippedOverride: boolean | undefined;

    private syncRuntimeHook(): void {
        const g = globalThis as unknown as { package?: { loaded?: Record<string, unknown> } };
        const loaded = g.package !== undefined ? g.package.loaded : undefined;
        if (loaded === undefined) {
            return;
        }
        const rawFe = loaded["watch.fe"];
        if (rawFe !== undefined && typeof rawFe === "object") {
            const watchFe = rawFe as Record<string, unknown>;
            if (watchFe["afterimageArtifact"] !== this) {
                watchFe["afterimageArtifact"] = this;
            }
        }
    }

    /** 供排演与自动化脚本显式切换装备覆写（传 undefined 恢复读取契约快照） */
    setEquippedOverride(equipped: boolean | undefined): void {
        this.equippedOverride = equipped;
    }

    getDebugState(): AfterimageArtifactDebugState {
        return {
            active: this.active,
            artifactOwned: this.lastOwned,
            equipped: this.lastEquipped,
            equippedWeapon: this.lastWeaponId,
            ghostCount: this.ghosts.length,
            maxGhosts: MAX_GHOSTS,
            totalSpawned: this.totalSpawned,
            maxRenderedAlpha: this.maxRenderedAlpha,
            lastWorldDt: this.lastWorldDt,
            slowedByTimeScale: this.slowedByTimeScale,
        };
    }

    onBindPlay(_p: Play, _view: DualRouteSnapshot): void {
        this.syncRuntimeHook();
        this.clearGhosts();
        this.active = false;
        this.totalSpawned = 0;
        this.maxRenderedAlpha = 0;
        this.lastWorldDt = 0;
        this.slowedByTimeScale = false;
    }

    private clearGhosts(): void {
        this.ghosts = [];
        this.sampleTimer = 0;
        this.hasLastSample = false;
    }

    private resolveEquipped(p: Play, view: DualRouteSnapshot): { equipped: boolean; weaponId: string } {
        const pRec = asRecord(p);
        const runRec = asRecord(p.run);
        const weaponId = view.craftBench.equippedWeapon !== ""
            ? view.craftBench.equippedWeapon
            : (readStr(pRec, "equippedWeapon") ?? readStr(runRec, "equippedWeapon") ?? "");

        if (this.equippedOverride !== undefined) {
            return { equipped: this.equippedOverride, weaponId };
        }
        if (readBool(pRec, "artifactEquipped") === true || readBool(runRec, "artifactEquipped") === true) {
            return { equipped: true, weaponId };
        }
        return { equipped: isArtifactWeaponId(weaponId), weaponId };
    }

    update(ctx: FePluginContext): void {
        this.syncRuntimeHook();
        const p = ctx.p;
        const view = ctx.view;

        const owned = view.archive.artifactOwned;
        const eq = this.resolveEquipped(p, view);
        this.lastOwned = owned;
        this.lastEquipped = eq.equipped;
        this.lastWeaponId = eq.weaponId;
        this.slowedByTimeScale = view.timeScale > 0 && view.timeScale < 0.99;

        const allowedMode = view.visualMode === "pixel"
            && !p.childMode
            && p.player.alive
            && view.storyRoute !== "child";

        this.active = owned && eq.equipped && allowedMode;

        if (!this.active) {
            if (this.ghosts.length > 0) {
                this.clearGhosts();
            }
            this.lastWorldDt = 0;
            this.maxRenderedAlpha = 0;
            return;
        }

        // 暂停态严格冻结所有残影寿命与采样
        if (ctx.paused || ctx.worldDt <= 0) {
            this.lastWorldDt = 0;
            return;
        }

        const dt = ctx.worldDt;
        this.lastWorldDt = dt;

        // 1. 衰减并回收既有残影
        let write = 0;
        let i = 0;
        for (i = 0; i < this.ghosts.length; i++) {
            const g = this.ghosts[i];
            g.life -= dt;
            if (g.life > 0) {
                this.ghosts[write] = g;
                write += 1;
            }
        }
        this.ghosts.length = write;

        // 2. 采样周戍真实移动轨迹（静止时不堆叠残影）
        const a = p.player;
        const speed = Math.sqrt(a.vx * a.vx + a.vy * a.vy + a.depthSpeed * a.depthSpeed);
        if (!this.hasLastSample) {
            this.lastSampleX = a.x;
            this.lastSampleY = a.y;
            this.lastSampleDepth = a.depth;
            this.hasLastSample = true;
            return;
        }

        this.sampleTimer += dt;
        const dx = a.x - this.lastSampleX;
        const dy = (a.y + a.depth * DEPTH_Y_SCALE) - (this.lastSampleY + this.lastSampleDepth * DEPTH_Y_SCALE);
        const dist = Math.sqrt(dx * dx + dy * dy);

        if ((dist >= MIN_STEP_DIST_PX && this.sampleTimer >= SAMPLE_INTERVAL_SEC * 0.65)
            || (speed > 28 && dist >= 4.5 && this.sampleTimer >= SAMPLE_INTERVAL_SEC)) {
            this.ghosts.push({
                x: this.lastSampleX,
                y: this.lastSampleY,
                depth: this.lastSampleDepth,
                h: a.h,
                facing: a.facing >= 0 ? 1 : -1,
                crouched: a.covered || a.crouch,
                rolling: a.rollT > 0,
                carrying: view.backCarry.active,
                life: GHOST_MAX_LIFE_SEC,
                maxLife: GHOST_MAX_LIFE_SEC,
            });
            if (this.ghosts.length > MAX_GHOSTS) {
                this.ghosts.shift();
            }
            this.totalSpawned += 1;
            ctx.audio.playFoley("afterimage:whoosh", "assets/audio/combat/afterimage_whoosh.wav", 0.34, ctx.audio.panForWorldX(a.x), 300);
            this.sampleTimer = 0;
            this.lastSampleX = a.x;
            this.lastSampleY = a.y;
            this.lastSampleDepth = a.depth;
        }
    }

    drawActorsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        if (!this.active || this.ghosts.length === 0) {
            this.maxRenderedAlpha = 0;
            return;
        }

        const p = ctx.p;
        const cam = ctx.cam;
        let peakAlpha = 0;
        let prevTrailX = 0;
        let prevTrailY = 0;
        let hasPrevTrail = false;

        let i = 0;
        for (i = 0; i < this.ghosts.length; i++) {
            const g = this.ghosts[i];
            const sepX = g.x - p.player.x;
            const sepY = (g.y + g.depth * DEPTH_Y_SCALE) - (p.player.y + p.player.depth * DEPTH_Y_SCALE);
            if (Math.sqrt(sepX * sepX + sepY * sepY) < MIN_DRAW_SEPARATION_PX) {
                continue;
            }

            const ratio = Math.max(0, Math.min(1, g.life / g.maxLife));
            const rollDamp = g.rolling ? 0.55 : 1.0;
            const normAlpha = Math.pow(ratio, 1.8) * MAX_GHOST_ALPHA * rollDamp;
            if (normAlpha <= 0.015) {
                continue;
            }
            if (normAlpha > peakAlpha) {
                peakAlpha = normAlpha;
            }

            const cx = cam.sx(g.x);
            const by = cam.sy(g.y, g.depth);
            const fullH = cam.len(g.h);
            const bodyH = g.rolling ? fullH * 0.62 : (g.crouched ? fullH * 0.80 : fullH);
            const halfW = fullH * 0.14;
            const f = g.facing;

            const goldAlpha = Math.round(normAlpha * 0.82 * 255);
            const paleGold = Color(218, 190, 128, goldAlpha);

            // 1. 像素级霜月冷白周戍残影（真实角色精灵剪影，严格 <= 0.34 透明，彻底替代矢量木偶）
            const ghostSlot = g.rolling
                ? "soldier_roll"
                : (g.crouched ? "soldier_cover" : (g.carrying ? "fe_carry_walk" : "soldier_run"));
            const ghostW = cam.len(g.carrying ? 36 : 28);
            const ghostLayer = p.room.depth !== undefined ? depthOrder(g.depth, 2) : 2;
            worldArt.tryPlace(ghostSlot, "fe06_ghost_" + i, cx, by, ghostW, bodyH, {
                facing: f,
                frame: i,
                color: Color(216, 228, 242, 255),
                opacity: normAlpha,
                layer: ghostLayer,
            });

            // 2. 脚底微弱时间刻度椭圆
            drawEllipseOutline(fgDraw, cx, by + 1, halfW * 1.05, 2.4, Color(0, 0, 0, 0), 0.9, paleGold, 16);

            // 3. 轻柔连接上一点轨迹的微金虚丝（仅在连续两点间，不跨屏拉长线）
            const midY = by + bodyH * 0.56;
            if (hasPrevTrail && Math.abs(cx - prevTrailX) < cam.len(72)) {
                fgGlow.drawSegment(
                    Vec2(prevTrailX, prevTrailY),
                    Vec2(cx, midY),
                    1.0,
                    Color(220, 198, 146, Math.round(goldAlpha * 0.55)),
                );
            }
            prevTrailX = cx;
            prevTrailY = midY;
            hasPrevTrail = true;
        }

        this.maxRenderedAlpha = peakAlpha;
    }
}

export function createAfterimageArtifactPlugin(): AfterimageArtifactPlugin {
    return new AfterimageArtifactPlugin();
}
