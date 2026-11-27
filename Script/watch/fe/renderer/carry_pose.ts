/**
 * 《向西守望》Wave 1 · FE-02：兄妹牵手 / 蹲背攀爬 / 背负移动转身 / 换弹探手 / 工台放下叠层渲染插件。
 *
 * 设计红线与零冲突约束：
 * - 独立实现 FeRenderPlugin，零改动 actors.ts / frontend.ts / play.ts；
 * - 仅在序章像素风（view.visualMode === "pixel"）下工作，严格复用周戍单碰撞体位置，不引入额外碰撞；
 * - 背负/攀爬/工台放下态通过 AssetSlotHost 同 instanceKey:path 覆写将原生 actor_child 凌空步态隐去，
 *   消除 B1 后端 carryOn=true 时 p.partner.vx>8 导致的半空跑步穿帮与排演态重影；
 * - 世界空间动画全部吃 ctx.worldDt（暂停自动归零冻结），换弹探手吃 ctx.uiDt（暂停同冻、慢时灵动）。
 */

import { Color, DrawNode, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { DualRouteSnapshot } from "Script/watch/fe/contract";
import { depthOrder } from "Script/watch/fe/occlusion";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import { PALETTE, fillRadialGlow, toColor } from "Script/watch/fe/theme";

export type CarryPoseMode = "none" | "handInHand" | "mounting" | "carrying" | "atBench";

export interface CarryPoseDebugState {
    mode: CarryPoseMode;
    smoothedFacing: number;
    mountT: number;
    benchDropT: number;
    reachT: number;
    childAnchorX: number;
    childAnchorY: number;
    handoverActive: boolean;
}

/** 原生 actors.ts 在护送/背负模式下可能激活的 actor_child / actor_soldier 精灵帧（原地压隐防重影） */
const CHILD_SPRITE_PATHS: readonly string[] = [
    "assets/art/sprites.clip|child_idle",
    "assets/art/sprites.clip|child_run",
    "assets/art/sprites.clip|child_step",
    "assets/art/sprites.clip|child_crouch",
    "assets/art/sprites.clip|child_crouch_step",
    "assets/art/sprites.clip|child_fear",
    "assets/art/sprites.clip|child_peek",
    "assets/art/sprites.clip|child_offer",
    "assets/art/sprites.clip|child_knock",
];

const SOLDIER_SPRITE_PATHS: readonly string[] = [
    "assets/art/sprites.clip|soldier_idle",
    "assets/art/sprites.clip|soldier_run",
    "assets/art/sprites.clip|soldier_step",
    "assets/art/sprites.clip|soldier_cover",
    "assets/art/sprites.clip|soldier_hold",
    "assets/art/sprites.clip|soldier_offer",
];

function clamp01(v: number): number {
    return Math.max(0, Math.min(1, v));
}

function smoothStep(t: number): number {
    const k = clamp01(t);
    return k * k * (3 - 2 * k);
}

function suppressOriginalChild(worldArt: AssetSlotHost): void {
    let i = 0;
    for (i = 0; i < CHILD_SPRITE_PATHS.length; i++) {
        worldArt.tryPlacePath(
            CHILD_SPRITE_PATHS[i],
            "actor_child",
            -9999,
            -9999,
            1,
            1,
            { anchorY: 0, preserveAspect: true, opacity: 0, layer: -99 },
        );
    }
}

function suppressOriginalSoldier(worldArt: AssetSlotHost): void {
    let i = 0;
    for (i = 0; i < SOLDIER_SPRITE_PATHS.length; i++) {
        worldArt.tryPlacePath(
            SOLDIER_SPRITE_PATHS[i],
            "actor_soldier",
            -9999,
            -9999,
            1,
            1,
            { anchorY: 0, preserveAspect: true, opacity: 0, layer: -99 },
        );
    }
}

export class CarryPosePlugin implements FeRenderPlugin {
    readonly id = "fe-02-carry-pose";

    private animTime = 0;
    private smoothedFacing = 1;
    private mountT = 0;
    private benchDropT = 0;
    private reachT = 0;
    private mode: CarryPoseMode = "none";
    private childAnchorX = 0;
    private childAnchorY = 0;
    private handoverActive = false;
    private carryAudioRoomSession = -1;

    getPoseState(): CarryPoseDebugState {
        return {
            mode: this.mode,
            smoothedFacing: this.smoothedFacing,
            mountT: this.mountT,
            benchDropT: this.benchDropT,
            reachT: this.reachT,
            childAnchorX: this.childAnchorX,
            childAnchorY: this.childAnchorY,
            handoverActive: this.handoverActive,
        };
    }

    onBindPlay(p: Play, view: DualRouteSnapshot): void {
        this.animTime = 0;
        this.smoothedFacing = p.player.facing >= 0 ? 1 : -1;
        this.mountT = view.backCarry.active && !view.backCarry.mounting ? 1 : 0;
        this.benchDropT = view.backCarry.atBench ? 1 : 0;
        this.reachT = 0;
        this.mode = this.resolveMode(view);
        this.childAnchorX = p.player.x;
        this.childAnchorY = p.player.y;
        this.handoverActive = false;
        this.carryAudioRoomSession = -1;
    }

    private resolveMode(view: DualRouteSnapshot): CarryPoseMode {
        const bc = view.backCarry;
        if (bc.atBench || view.craftBench.active) {
            return "atBench";
        }
        if (bc.mounting) {
            return "mounting";
        }
        if (bc.active) {
            return "carrying";
        }
        if (bc.handInHand) {
            return "handInHand";
        }
        return "none";
    }

    update(ctx: FePluginContext): void {
        const view = ctx.view;
        const p = ctx.p;
        this.mode = this.resolveMode(view);
        this.handoverActive = view.craftBench.justCraftedTimer > 0;

        if (view.visualMode !== "pixel" || p.childMode || !p.player.alive) {
            return;
        }
        if (ctx.paused) {
            return;
        }

        const wdt = Math.max(0, ctx.worldDt);
        const udt = Math.max(0, ctx.uiDt);

        if (wdt > 0) {
            this.animTime += wdt;

            // 平滑转身：小满沿周戍肩背弧线平滑换到另一侧，绝不瞬移闪跳
            const targetF = p.player.facing >= 0 ? 1 : -1;
            const turnK = Math.min(1, wdt * 15);
            this.smoothedFacing += (targetF - this.smoothedFacing) * turnK;
            if (Math.abs(targetF - this.smoothedFacing) < 0.005) {
                this.smoothedFacing = targetF;
            }

            // 高石阶蹲背攀爬进度（约 0.45s 上背，离开背负时平滑回落）
            if (this.mode === "mounting") {
                this.mountT = clamp01(this.mountT + wdt / 0.45);
            } else if (this.mode === "carrying") {
                this.mountT = clamp01(this.mountT + wdt / 0.22);
            } else if (this.mode === "handInHand" || this.mode === "none") {
                this.mountT = clamp01(this.mountT - wdt / 0.28);
            }

            // 第三段工台放下与离开重新背起过渡（约 0.30s）
            const dropTarget = this.mode === "atBench" ? 1 : 0;
            this.benchDropT += (dropTarget - this.benchDropT) * Math.min(1, wdt * 11);
            if (Math.abs(dropTarget - this.benchDropT) < 0.005) {
                this.benchDropT = dropTarget;
            }
        }

        // 换弹探手吃全速 uiDt（暂停为 0 自动冻结），慢时期间仍能利落探出触盘与收回
        if (udt > 0) {
            const reachTarget = view.reloadSession.active ? 1 : 0;
            const speed = view.reloadSession.active
                ? (view.reloadSession.firstTime ? 4.4 : 9.2)
                : 5.5;
            this.reachT += (reachTarget - this.reachT) * Math.min(1, udt * speed);
            if (Math.abs(reachTarget - this.reachT) < 0.005) {
                this.reachT = reachTarget;
            }
        }

        // 若处于排演态切入背负且本帧后端未发 carryStart 事件，则按房间会话去重补播上背布料声
        if ((this.mode === "mounting" || this.mode === "carrying")
            && this.carryAudioRoomSession !== ctx.events.roomSessionId) {
            let hasBackendEvent = false;
            let i = 0;
            for (i = 0; i < ctx.events.rawEvents.length; i++) {
                if ((ctx.events.rawEvents[i].name as string) === "carryStart") {
                    hasBackendEvent = true;
                    break;
                }
            }
            this.carryAudioRoomSession = ctx.events.roomSessionId;
            if (!hasBackendEvent) {
                ctx.audio.playOnce(
                    "fe02:carry_start:r" + ctx.events.roomSessionId,
                    "sfx",
                    "assets/audio/combat/carry_start.wav",
                    0.82,
                    "combat:carry_start",
                    p.ticks,
                );
            }
        }
    }

    drawActorsOverlay(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        const view = ctx.view;
        const p = ctx.p;
        if (view.visualMode !== "pixel" || p.childMode || !p.player.alive) {
            return;
        }
        if (this.mode === "none" && this.mountT <= 0.01 && this.benchDropT <= 0.01) {
            return;
        }

        if (this.mode === "handInHand") {
            this.drawHandInHand(fgDraw, fgGlow, worldArt, ctx);
            return;
        }

        // 背负、蹲背攀爬或工台放下：压隐原生 actor_child，彻底杜绝半空蹬腿或双小满重影
        suppressOriginalChild(worldArt);

        if (this.mode === "atBench" || this.benchDropT > 0.5) {
            this.drawAtBench(fgDraw, fgGlow, worldArt, ctx);
            return;
        }

        this.drawCarriedOrMounting(fgDraw, fgGlow, worldArt, ctx);
    }

    /** 姿态 1：风台重逢后牵手过平路（兄妹各自步幅 + 青布补线袖口交握） */
    private drawHandInHand(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        const p = ctx.p;
        const cam = ctx.cam;
        const soldier = p.player;
        const partner = p.partner;
        const depthEnabled = p.room.depth !== undefined;
        const f = soldier.facing >= 0 ? 1 : -1;
        const speed = Math.max(Math.abs(soldier.vx), Math.abs(soldier.depthSpeed));

        // 校验同伴是否已在牵手距离内；排演态下若同伴仍停在远处则压隐并就近绘制同行小满
        const nearPartner = partner.alive && Math.abs(partner.x - soldier.x) <= 56 && Math.abs(partner.y - soldier.y) <= 24;
        let childWX = partner.x;
        let childWY = partner.y;
        let childDepth = partner.depth;

        if (!nearPartner) {
            suppressOriginalChild(worldArt);
            // 小满牵手步幅比周戍轻快（两套步频呼应分镜 G06「只听两种步幅」）
            const lag = speed > 8 ? Math.sin(this.animTime * 13.5) * 2.4 : 0;
            childWX = soldier.x - f * 26 + lag;
            childWY = soldier.y;
            childDepth = soldier.depth;

            const childStep = Math.floor(this.animTime * 13);
            const slot = speed > 8 ? "child_run" : "child_idle";
            const scx = cam.sx(childWX);
            const scy = cam.sy(childWY, childDepth);
            const cW = cam.len(22);
            const cH = cam.len(64);
            worldArt.tryPlace(slot, "carry_child_walk", scx, scy, cW, cH, {
                facing: f,
                frame: speed > 8 ? childStep : 0,
                layer: depthEnabled ? depthOrder(childDepth, 4) : 4,
            });
            fgDraw.drawEllipse(Vec2(scx, scy + 1), cW * 0.46, 3.2, Color(10, 10, 12, 130));
        }

        this.childAnchorX = childWX;
        this.childAnchorY = childWY;

        // 驻足牵手时换用像素牵手伸臂精灵 fe_soldier_hand_hold，行走时以柔和暖微光连结两人像素身影（告别线条手臂）
        if (speed <= 8 && soldier.rollT <= 0) {
            suppressOriginalSoldier(worldArt);
            worldArt.tryPlace(
                "fe_soldier_hand_hold",
                "carry_soldier_hold",
                cam.sx(soldier.x),
                cam.sy(soldier.y, soldier.depth),
                cam.len(36),
                cam.len(soldier.h),
                {
                    facing: f,
                    layer: depthEnabled ? depthOrder(soldier.depth, 4) : 4,
                },
            );
        }
        const sHandX = cam.sx(soldier.x - f * 8);
        const sHandY = cam.sy(soldier.y + soldier.h * 0.46, soldier.depth);
        const cHandX = cam.sx(childWX + f * 7);
        const cHandY = cam.sy(childWY + 36, childDepth);
        const claspX = (sHandX + cHandX) * 0.5;
        const claspY = (sHandY + cHandY) * 0.5;
        fillRadialGlow(fgGlow, claspX, claspY, cam.len(10), cam.len(8), toColor(PALETTE.amberCore, 76), Color(244, 234, 214, 0), 10);
    }

    /** 姿态 2 & 3：高石阶蹲背攀爬（mounting）与常规背负战斗移动（carrying），全像素一体精灵零矢量手臂 */
    private drawCarriedOrMounting(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        const p = ctx.p;
        const cam = ctx.cam;
        const soldier = p.player;
        const depthEnabled = p.room.depth !== undefined;
        const sf = this.smoothedFacing;
        const faceSign = sf >= 0 ? 1 : -1;
        const speed = Math.max(Math.abs(soldier.vx), Math.abs(soldier.depthSpeed));

        // 蹲背攀爬插值：0 -> 1 从周戍身后地面沿肩背弧线攀上背负锚点
        const kMount = this.mode === "mounting" ? smoothStep(this.mountT) : 1;
        const crouchDip = this.mode === "mounting"
            ? Math.sin(kMount * Math.PI) * 14
            : ((soldier.covered || p.coverHug) ? 10 : (soldier.rollT > 0 ? 18 : 0));

        const walking = speed > 8 && soldier.onGround;
        const bob = walking
            ? Math.abs(Math.sin(this.animTime * 10.5)) * 2.0
            : Math.sin(this.animTime * 2.5) * 0.8;

        // 背负世界坐标：严格对齐后端 carryPose() 的 (x - facing * 12, y + 26)
        const targetBackX = soldier.x - sf * 13;
        const targetBackY = soldier.y + 30 - crouchDip + bob;
        const startGroundX = soldier.x - sf * 24;
        const startGroundY = soldier.y;
        const arcLift = this.mode === "mounting" ? Math.sin(kMount * Math.PI) * 8 : 0;

        const childWX = startGroundX + (targetBackX - startGroundX) * kMount;
        const childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift;
        this.childAnchorX = childWX;
        this.childAnchorY = childWY;

        const scx = cam.sx(soldier.x);
        const scy = cam.sy(soldier.y, soldier.depth);
        const baseLayer = depthEnabled ? depthOrder(soldier.depth, 4) : 4;

        // 蹲背攀爬前段：周戍单膝跪迎像素精灵 + 小满俯身攀上
        if (this.mode === "mounting" && kMount < 0.72) {
            suppressOriginalSoldier(worldArt);
            fgDraw.drawEllipse(Vec2(scx - sf * cam.len(4), scy + 1), cam.len(22), 4.0, Color(10, 10, 12, 118));
            worldArt.tryPlace("fe_soldier_kneel_mount", "carry_soldier_kneel", scx, scy, cam.len(42), cam.len(soldier.h * 0.90), {
                facing: faceSign,
                layer: baseLayer,
            });
            const cx = cam.sx(childWX);
            const cy = cam.sy(childWY, soldier.depth);
            worldArt.tryPlace(kMount < 0.45 ? "child_crouch" : "child_peek", "carry_child", cx, cy, cam.len(22), cam.len(42 + (1 - kMount) * 18), {
                facing: faceSign,
                layer: baseLayer + 1,
            });
            return;
        }

        // 背负稳态（待机 / 步履 / 换弹探手）：使用专属合体像素精灵，周戍翻滚时退回原生翻滚精灵+背上小满
        if (soldier.rollT <= 0) {
            const carrySlot = this.reachT > 0.08
                ? "fe_carry_reload"
                : (walking ? "fe_carry_walk" : "fe_carry_idle");
            const frame = carrySlot === "fe_carry_walk" ? Math.floor(this.animTime * 10) : 0;
            const carryH = cam.len(soldier.h * (crouchDip > 4 ? 0.88 : 1.04));
            if (worldArt.tryPlace(carrySlot, "carry_pair_sprite", scx, scy, cam.len(48), carryH, {
                facing: faceSign,
                frame,
                layer: baseLayer,
            })) {
                suppressOriginalSoldier(worldArt);
                if (this.reachT > 0.12) {
                    const reachFrac = smoothStep(this.reachT);
                    const handGlowX = cam.sx(soldier.x + sf * (14 + reachFrac * 10));
                    const handGlowY = cam.sy(soldier.y + soldier.h * 0.72 - crouchDip, soldier.depth);
                    fillRadialGlow(fgGlow, handGlowX, handGlowY, cam.len(9 * reachFrac), cam.len(9 * reachFrac), toColor(PALETTE.amberCore, 72 * reachFrac), Color(244, 234, 214, 0), 10);
                }
                return;
            }
        }

        // 翻滚兜底：保留原生周戍翻滚精灵，仅在身后低层贴合小满像素精灵（零矢量棍臂）
        const cx = cam.sx(childWX);
        const cy = cam.sy(childWY, soldier.depth);
        worldArt.tryPlace("child_peek", "carry_child", cx, cy, cam.len(22), cam.len(40), {
            facing: faceSign,
            layer: depthEnabled ? depthOrder(soldier.depth, 3) : 3,
        });
    }

    /** 姿态 4：第三段安全工台放下小满（并协同表现首次试握像素鸟铳递器） */
    private drawAtBench(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void {
        const p = ctx.p;
        const cam = ctx.cam;
        const soldier = p.player;
        const depthEnabled = p.room.depth !== undefined;
        const f = soldier.facing >= 0 ? 1 : -1;
        const dropK = smoothStep(this.benchDropT);

        // 从背上落到周戍惯用手一侧的木案旁
        const startX = soldier.x - f * 12;
        const startY = soldier.y + 26;
        const standX = soldier.x + f * 30;
        const standY = soldier.y;
        const childWX = startX + (standX - startX) * dropK;
        const childWY = startY + (standY - startY) * dropK;
        this.childAnchorX = childWX;
        this.childAnchorY = childWY;

        const cx = cam.sx(childWX);
        const cy = cam.sy(childWY, soldier.depth);
        const cW = cam.len(22);
        const cH = cam.len(64);

        const handing = ctx.view.craftBench.justCraftedTimer > 0;
        const slot = handing ? "child_offer" : "child_idle";
        worldArt.tryPlace(slot, "carry_child_bench", cx, cy, cW, cH, {
            facing: -f,
            layer: depthEnabled ? depthOrder(soldier.depth, 5) : 5,
        });
        fgDraw.drawEllipse(Vec2(cx, cam.sy(soldier.y, soldier.depth) + 1), cW * 0.48 * dropK, 3.2, Color(10, 10, 12, 130));

        // 首次制成/递交期间在两人手间展示专属像素鸟铳精灵（告别两段木棍画枪）
        if (handing) {
            const prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer);
            const midX = cam.sx(soldier.x + f * (22 - prog * 10));
            const midY = cam.sy(soldier.y + 44 + Math.sin(prog * Math.PI) * 5, soldier.depth);
            const isEcho = ctx.view.craftBench.equippedWeapon.indexOf("echo") >= 0;
            worldArt.tryPlace(isEcho ? "fe_weapon_echo_gun" : "fe_weapon_lantern_gun", "carry_bench_gun", midX, midY, cam.len(34), cam.len(16), {
                facing: f,
                layer: depthEnabled ? depthOrder(soldier.depth, 6) : 6,
            });
            fillRadialGlow(fgGlow, midX, midY, cam.len(15), cam.len(11), toColor(PALETTE.amberCore, 72), Color(244, 234, 214, 0), 10);
        }
    }
}

export function createCarryPosePlugin(): CarryPosePlugin {
    return new CarryPosePlugin();
}
