/**
 * 《向西守望》Wave 1 · FE-02：兄妹牵手 / 蹲背攀爬 / 背负移动转身 / 换弹探手 / 工台放下叠层渲染插件。
 *
 * 设计红线与零冲突约束：
 * - 仅在序章像素风（view.visualMode === "pixel"）下工作，严格复用周戍单碰撞体位置，不引入额外碰撞；
 * - 姿态报告本帧成功放置的角色，由基础渲染补画其余角色；
 * - 世界空间动画全部吃 ctx.worldDt（暂停自动归零冻结），换弹探手吃 ctx.uiDt（暂停同冻、慢时灵动）。
 */

import { Color, DrawNode, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { DualRouteSnapshot } from "Script/watch/fe/contract";
import { depthOrder } from "Script/watch/fe/occlusion";
import { FePluginContext, FeRenderPlugin, PartyPose } from "Script/watch/fe/plugins";
import { PALETTE, fillRadialGlow, toColor } from "Script/watch/fe/theme";

export type CarryPoseMode = "none" | "handInHand" | "mounting" | "carrying" | "atBench";

const DUO_HAND_CLIPS = [
    "assets/art/actors_duo_anim.clip|duo_hand_walk_0",
    "assets/art/actors_duo_anim.clip|duo_hand_walk_1",
    "assets/art/actors_duo_anim.clip|duo_hand_walk_2",
    "assets/art/actors_duo_anim.clip|duo_hand_walk_3",
];
const DUO_MOUNT_CLIPS = [
    "assets/art/actors_duo_anim.clip|duo_mount_0",
    "assets/art/actors_duo_anim.clip|duo_mount_1",
    "assets/art/actors_duo_anim.clip|duo_mount_2",
    "assets/art/actors_duo_anim.clip|duo_mount_3",
];
const DUO_CARRY_RUN_CLIPS = [
    "assets/art/actors_duo_anim.clip|duo_carry_run_0",
    "assets/art/actors_duo_anim.clip|duo_carry_run_1",
    "assets/art/actors_duo_anim.clip|duo_carry_run_2",
    "assets/art/actors_duo_anim.clip|duo_carry_run_3",
    "assets/art/actors_duo_anim.clip|duo_carry_run_4",
    "assets/art/actors_duo_anim.clip|duo_carry_run_5",
    "assets/art/actors_duo_anim.clip|duo_carry_run_6",
    "assets/art/actors_duo_anim.clip|duo_carry_run_7",
];
const DUO_CARRY_IDLE_CLIPS = [
    "assets/art/actors_duo_anim.clip|duo_carry_idle_0",
    "assets/art/actors_duo_anim.clip|duo_carry_idle_1",
    "assets/art/actors_duo_anim.clip|duo_carry_idle_2",
    "assets/art/actors_duo_anim.clip|duo_carry_idle_3",
];
const DUO_CARRY_FIRE_CLIPS = [
    "assets/art/actors_duo_anim.clip|duo_carry_fire_0",
    "assets/art/actors_duo_anim.clip|duo_carry_fire_1",
    "assets/art/actors_duo_anim.clip|duo_carry_fire_2",
    "assets/art/actors_duo_anim.clip|duo_carry_fire_3",
];

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

function clamp01(v: number): number {
    return Math.max(0, Math.min(1, v));
}

function smoothStep(t: number): number {
    const k = clamp01(t);
    return k * k * (3 - 2 * k);
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

    private shotUntil = -1;
    private shotStartTick = 0;
    private shotFacing = 1;
    private carryStride = 0;
    private prevSoldierX = 0;
    private prevSoldierDepth = 0;

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
        this.shotUntil = -1;
        this.shotStartTick = 0;
        this.shotFacing = this.smoothedFacing;
        this.carryStride = 0;
        this.prevSoldierX = p.player.x;
        this.prevSoldierDepth = p.player.depth;
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

        if (ctx.events.shotFired) {
            this.shotStartTick = p.ticks;
            this.shotUntil = p.ticks + 18;
            if (ctx.events.shotTrace !== undefined) {
                this.shotFacing = ctx.events.shotTrace.x1 < ctx.events.shotTrace.x0 ? -1 : 1;
            } else {
                this.shotFacing = p.player.facing >= 0 ? 1 : -1;
            }
        }

        if (wdt > 0) {
            this.animTime += wdt;
            const dx = p.player.x - this.prevSoldierX;
            const dd = p.player.depth - this.prevSoldierDepth;
            const stepDist = Math.sqrt(dx * dx + dd * dd);
            this.prevSoldierX = p.player.x;
            this.prevSoldierDepth = p.player.depth;
            if (stepDist > 0.05 && stepDist < 80) {
                this.carryStride = (this.carryStride + stepDist / Math.max(40, p.player.h * 1.28)) % 1;
            }

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

    drawPartyPose(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): PartyPose | undefined {
        const view = ctx.view;
        const p = ctx.p;
        if (view.visualMode !== "pixel" || p.childMode || !p.player.alive) {
            return;
        }
        if (this.mode === "none" && this.mountT <= 0.01 && this.benchDropT <= 0.01) {
            return;
        }

        if (this.mode === "handInHand") {
            return this.drawHandInHand(fgDraw, fgGlow, worldArt, ctx);
        }

        if (this.mode === "atBench" || this.benchDropT > 0.5) {
            return { player: false, partner: this.drawAtBench(fgDraw, fgGlow, worldArt, ctx) };
        }

        return this.drawCarriedOrMounting(fgGlow, worldArt, ctx);
    }

    /** 姿态 1：风台重逢后牵手过平路（兄妹各自步幅 + 青布补线袖口交握） */
    private drawHandInHand(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): PartyPose {
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

        // 地面站立/步行牵手：使用全新高精明代像素 4 帧牵手同行序列 duo_hand_walk_0..3（周戍稳步 + 小满轻快小步）
        if (soldier.rollT <= 0 && !p.gripping) {
            const dScale = cam.depthScale(soldier.depth, depthEnabled);
            const dShade = cam.depthShade(soldier.depth, depthEnabled);
            const tone = Math.round(255 * Math.min(1, dShade + 0.06));
            const duoTint = depthEnabled && soldier.depth > 6 ? Color(tone, tone, Math.min(255, tone + 8), 255) : undefined;
            const sx = cam.sx(soldier.x);
            const sy = cam.sy(soldier.y, soldier.depth);
            const duoH = cam.len(soldier.h * 1.03) * dScale;
            const duoLayer = depthEnabled ? depthOrder(soldier.depth, 4) : 4;
            const walking = speed > 8 && soldier.onGround;
            const handFrame = walking ? (Math.floor(this.carryStride * 8) % 4) : 0;
            const breathSquash = walking ? 1 : (1 + Math.sin(this.animTime * 2.4) * 0.012);
            if (worldArt.tryPlacePath(DUO_HAND_CLIPS[handFrame], "carry_duo_hand", sx, sy, duoH, duoH, {
                anchorX: 0.5,
                anchorY: 0,
                preserveAspect: true,
                facing: f,
                scaleYMul: breathSquash,
                color: duoTint,
                layer: duoLayer,
            })) {
                // 周戍脚底接触影已由 ActorsRenderer.drawZhouShu 写入 worldArt(layer-1)，此处补小满侧伴随接触影
                worldArt.tryPlace("dp_shadow_contact", "carry_duo_hand_sh", sx + f * cam.len(26) * dScale, sy + 1, cam.len(28) * dScale, cam.len(8.5) * dScale, {
                    layer: duoLayer - 1, opacity: 0.78,
                });
                this.childAnchorX = childWX;
                this.childAnchorY = childWY;
                return { player: true, partner: true };
            }
        }

        let partnerPlaced = false;
        if (!nearPartner) {
            // 小满牵手步幅比周戍轻快（两套步频呼应分镜 G06「只听两种步幅」）
            const lag = speed > 8 ? Math.sin(this.animTime * 13.5) * 2.4 : 0;
            childWX = soldier.x - f * 26 + lag;
            childWY = soldier.y;
            childDepth = soldier.depth;

            const dScale = cam.depthScale(childDepth, depthEnabled);
            const scx = cam.sx(childWX);
            const scy = cam.sy(childWY, childDepth);
            const cW = cam.len(22) * dScale;
            const cH = cam.len(64) * dScale;
            const cLayer = depthEnabled ? depthOrder(childDepth, 4) : 4;
            const pose = { facing: f, layer: cLayer };
            partnerPlaced = (speed > 8 && worldArt.tryPlaceRun("child", "carry_child_walk", scx, scy, cW, cH, this.animTime * 1.8, pose))
                || worldArt.tryPlace("child_idle", "carry_child_walk", scx, scy, cW, cH, pose);
            worldArt.tryPlace("dp_shadow_contact", "carry_child_walk_sh", scx, scy + 1, cW * 1.4, cam.len(8) * dScale, {
                layer: cLayer - 1, opacity: 0.80,
            });
        }

        this.childAnchorX = childWX;
        this.childAnchorY = childWY;

        // 驻足牵手时换用像素牵手伸臂精灵 fe_soldier_hand_hold，行走时以柔和暖微光连结两人像素身影（告别线条手臂）
        let playerPlaced = false;
        if (speed <= 8 && soldier.rollT <= 0) {
            playerPlaced = worldArt.tryPlace(
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
        return { player: playerPlaced, partner: partnerPlaced };
    }

    /** 姿态 2 & 3：高石阶蹲背攀爬（mounting）与常规背负战斗移动（carrying），全像素一体精灵零矢量手臂 */
    private drawCarriedOrMounting(
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): PartyPose {
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
        const dScale = cam.depthScale(soldier.depth, depthEnabled);
        const dShade = cam.depthShade(soldier.depth, depthEnabled);
        const tone = Math.round(255 * Math.min(1, dShade + 0.06));
        const duoTint = depthEnabled && soldier.depth > 6 ? Color(tone, tone, Math.min(255, tone + 8), 255) : undefined;

        // 蹲背攀爬连贯 4 帧高精像素动画（单膝下蹲 → 蹬背攀肩 → 撑膝起立 → 托稳站定）
        if (this.mode === "mounting" && kMount < 0.96) {
            const mountFrame = kMount < 0.28 ? 0 : (kMount < 0.56 ? 1 : (kMount < 0.80 ? 2 : 3));
            const mountH = cam.len(soldier.h * 1.06) * dScale;
            if (worldArt.tryPlacePath(DUO_MOUNT_CLIPS[mountFrame], "carry_duo_mount", scx, scy, mountH, mountH, {
                anchorX: 0.5,
                anchorY: 0,
                preserveAspect: true,
                facing: faceSign,
                color: duoTint,
                layer: baseLayer,
            })) {
                return { player: true, partner: true };
            }
            const playerPlaced = worldArt.tryPlace("fe_soldier_kneel_mount", "carry_soldier_kneel", scx, scy, cam.len(42) * dScale, cam.len(soldier.h * 0.90) * dScale, {
                facing: faceSign,
                color: duoTint,
                layer: baseLayer,
            });
            const cx = cam.sx(childWX);
            const cy = cam.sy(childWY, soldier.depth);
            const partnerPlaced = worldArt.tryPlace(kMount < 0.45 ? "child_crouch" : "child_peek", "carry_child", cx, cy, cam.len(22) * dScale, cam.len(42 + (1 - kMount) * 18) * dScale, {
                facing: faceSign,
                color: duoTint,
                layer: baseLayer + 1,
            });
            return { player: playerPlaced, partner: partnerPlaced };
        }

        // 高精明代像素合体背负全帧动画（8 帧真实背负奔跑 / 4 帧背负呼吸待机 / 4 帧背负开火小满护耳后坐）
        if (kMount >= 0.72 && soldier.rollT <= 0 && !p.gripping) {
            const firing = p.ticks < this.shotUntil;
            let duoPath = DUO_CARRY_IDLE_CLIPS[0];
            let duoFacing = faceSign;
            let recoilOffsetX = 0;
            let turnScaleX = 1 - Math.abs(Math.abs(sf) - 1) * 0.24;
            if (firing) {
                const elapsed = Math.max(0, p.ticks - this.shotStartTick);
                const fIdx = elapsed < 2 ? 0 : (elapsed < 5 ? 1 : (elapsed < 12 ? 2 : 3));
                duoPath = DUO_CARRY_FIRE_CLIPS[fIdx];
                duoFacing = this.shotFacing;
                if (fIdx === 2) {
                    recoilOffsetX = -duoFacing * cam.len(3.2) * dScale;
                }
            } else if (walking) {
                const runIdx = Math.floor(this.carryStride * 8) % 8;
                duoPath = DUO_CARRY_RUN_CLIPS[runIdx];
            } else {
                const ping = [0, 1, 2, 3, 2, 1];
                const idleIdx = ping[Math.floor(this.animTime * 5.2) % ping.length];
                duoPath = DUO_CARRY_IDLE_CLIPS[idleIdx];
            }
            const duoLayer = depthEnabled ? depthOrder(soldier.depth, 4) : 4;
            const crouchScale = (soldier.covered || p.coverHug) ? 0.88 : 1.06;
            const duoH = cam.len(soldier.h * crouchScale) * dScale;
            const sx = cam.sx(soldier.x) + recoilOffsetX;
            const sy = cam.sy(soldier.y, soldier.depth);
            if (worldArt.tryPlacePath(duoPath, "carry_duo_sprite", sx, sy, duoH, duoH, {
                anchorX: 0.5,
                anchorY: 0,
                preserveAspect: true,
                facing: duoFacing,
                scaleXMul: Math.max(0.76, turnScaleX),
                color: duoTint,
                layer: duoLayer,
            })) {
                // 换弹慢时期间肩侧保留一缕极克制微杏提灯微光，提示小满正搭手协助换弹
                if (this.reachT > 0.05) {
                    const reachFrac = smoothStep(this.reachT);
                    const gx = sx + sf * cam.len(14 + reachFrac * 8);
                    const gy = sy + duoH * 0.72;
                    fillRadialGlow(
                        fgGlow,
                        gx,
                        gy,
                        cam.len(10 * reachFrac),
                        cam.len(10 * reachFrac),
                        toColor(PALETTE.amberCore, 82 * reachFrac),
                        Color(244, 234, 214, 0),
                        10,
                    );
                }
                return { player: true, partner: true };
            }
        }

        // 翻滚或合体帧缺失：保留原生周戍动作，仅在身后低层贴合小满像素精灵（零矢量棍臂）
        const cx = cam.sx(childWX);
        const cy = cam.sy(childWY, soldier.depth);
        const partnerPlaced = worldArt.tryPlace("child_peek", "carry_child", cx, cy, cam.len(22), cam.len(40), {
            facing: faceSign,
            layer: depthEnabled ? depthOrder(soldier.depth, 3) : 3,
        });
        return { player: false, partner: partnerPlaced };
    }

    /** 姿态 4：第三段安全工台放下小满（并协同表现首次试握像素鸟铳递器） */
    private drawAtBench(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean {
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

        const dScale = cam.depthScale(soldier.depth, depthEnabled);
        const dShade = cam.depthShade(soldier.depth, depthEnabled);
        const tone = Math.round(255 * Math.min(1, dShade + 0.06));
        const depthTint = depthEnabled && soldier.depth > 6 ? Color(tone, tone, Math.min(255, tone + 6), 255) : undefined;
        const cx = cam.sx(childWX);
        const cy = cam.sy(childWY, soldier.depth);
        const cW = cam.len(22) * dScale;
        const cH = cam.len(64) * dScale;

        const handing = ctx.view.craftBench.justCraftedTimer > 0;
        const slot = handing ? "child_offer" : "child_idle";
        const benchLayer = depthEnabled ? depthOrder(soldier.depth, 5) : 5;
        const partnerPlaced = worldArt.tryPlace(slot, "carry_child_bench", cx, cy, cW, cH, {
            facing: -f,
            color: depthTint,
            layer: benchLayer,
        });
        worldArt.tryPlace("dp_shadow_contact", "carry_child_bench_sh", cx, cam.sy(soldier.y, soldier.depth) + 1, cW * 1.45 * Math.max(0.3, dropK), cam.len(8) * dScale, {
            layer: benchLayer - 1, opacity: 0.80,
        });

        // 首次制成/递交期间在两人手间展示专属像素鸟铳精灵（告别两段木棍画枪）
        if (handing) {
            const prog = clamp01(1 - ctx.view.craftBench.justCraftedTimer);
            const midX = cam.sx(soldier.x + f * (22 - prog * 10));
            const midY = cam.sy(soldier.y + 44 + Math.sin(prog * Math.PI) * 5, soldier.depth);
            const gunClip = ctx.view.craftBench.equippedWeapon === "echo_gun" ? "craft_echo_gun" : "craft_lantern_gun";
            const gunW = cam.len(38);
            const gunH = cam.len(14);
            if (!worldArt.tryPlacePath("assets/art/vfx_craft_art.clip|" + gunClip, "carry_bench_gun", midX, midY, gunW, gunH, {
                anchorX: 0.5,
                anchorY: 0.5,
                preserveAspect: true,
                facing: f,
                smooth: true,
                layer: depthEnabled ? depthOrder(soldier.depth, 6) : 6,
            })) {
                const gunLen = cam.len(22);
                fgDraw.drawSegment(Vec2(midX - f * gunLen * 0.4, midY - 2), Vec2(midX + f * gunLen * 0.25, midY + 1), 3.2, Color(108, 74, 52, 255));
                fgDraw.drawSegment(Vec2(midX + f * gunLen * 0.1, midY + 1), Vec2(midX + f * gunLen * 0.65, midY + 3), 1.8, Color(148, 144, 134, 245));
            }
            fillRadialGlow(fgGlow, midX, midY, cam.len(15), cam.len(11), toColor(PALETTE.amberCore, 72), Color(244, 234, 214, 0), 10);
        }
        return partnerPlaced;
    }
}

export function createCarryPosePlugin(): CarryPosePlugin {
    return new CarryPosePlugin();
}
