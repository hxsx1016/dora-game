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
import { CUFF_PALETTE } from "Script/watch/fe/cutscenes/cuff_shots";
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

/** 原生 actors.ts 在护送/背负模式下可能激活的 actor_child 精灵帧（同 instanceKey 原地压隐防重影） */
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

/** 原生 actors.ts 在合体牵手/背负模式下可能激活的 actor_soldier 精灵帧（使用 actors_extra.clip 合体帧时原地压隐防重影） */
const SOLDIER_SPRITE_PATHS: readonly string[] = [
    "assets/art/sprites.clip|soldier_idle",
    "assets/art/sprites.clip|soldier_run",
    "assets/art/sprites.clip|soldier_step",
    "assets/art/sprites.clip|soldier_cover",
    "assets/art/sprites.clip|soldier_fire",
    "assets/art/sprites.clip|soldier_fire_run",
    "assets/art/sprites.clip|soldier_fire_run_step",
    "assets/art/sprites.clip|soldier_hit",
    "assets/art/sprites.clip|soldier_knock",
    "assets/art/sprites.clip|soldier_hold",
    "assets/art/sprites.clip|soldier_offer",
];

/** 同一道青布补线袖口（同源 cuff_shots.CUFF_PALETTE）与明初小满红褐短袄色板 */
const CUFF_CLOTH = toColor(CUFF_PALETTE.indigoBase);
const CUFF_MEND = toColor(CUFF_PALETTE.stitchThread);
const CHILD_SLEEVE = Color(164, 78, 54, 255);
const CHILD_SKIN = Color(236, 210, 182, 255);
const CHILD_VEST = Color(146, 68, 48, 255);
const NEEDLE_CORD = Color(198, 166, 114, 240);

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
    private shotUntil = -1;
    private shotFacing = 1;

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
        this.shotFacing = this.smoothedFacing;
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
            this.shotUntil = p.ticks + 10;
            if (ctx.events.shotTrace !== undefined) {
                this.shotFacing = ctx.events.shotTrace.x1 < ctx.events.shotTrace.x0 ? -1 : 1;
            } else {
                this.shotFacing = p.player.facing >= 0 ? 1 : -1;
            }
        }

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

    /** 姿态 1：风台重逢后牵手过平路（Phase 3 接入 duo_hand_walk 兄妹牵手合体像素精灵，保留脚底对齐与微步起伏） */
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

        // 校验同伴是否已在牵手距离内；更新小满锚点供外部测试读取
        const nearPartner = partner.alive && Math.abs(partner.x - soldier.x) <= 56 && Math.abs(partner.y - soldier.y) <= 24;
        const lag = speed > 8 ? Math.sin(this.animTime * 13.5) * 2.0 : 0;
        const childWX = nearPartner ? partner.x : soldier.x + f * 30 + lag;
        const childWY = nearPartner ? partner.y : soldier.y;
        const childDepth = nearPartner ? partner.depth : soldier.depth;
        this.childAnchorX = childWX;
        this.childAnchorY = childWY;

        // 地面站立/步行牵手时使用整体手绘合体精灵 duo_hand_walk（周戍左、小满右牵手前行），彻底告别拆散棍条手臂
        if (soldier.rollT <= 0 && !p.gripping) {
            const sx = cam.sx(soldier.x);
            const sy = cam.sy(soldier.y, soldier.depth);
            const bob = speed > 8 ? Math.abs(Math.sin(this.animTime * 10.5)) * cam.len(2.2) : Math.sin(this.animTime * 2.2) * cam.len(0.6);
            const duoH = cam.len(soldier.h * 1.03);
            if (worldArt.tryPlacePath("assets/art/actors_extra.clip|duo_hand_walk", "carry_duo_hand", sx, sy + bob, duoH, duoH, {
                anchorX: 0.28,
                anchorY: 0,
                preserveAspect: true,
                facing: f,
                layer: depthEnabled ? depthOrder(soldier.depth, 4) : 4,
            })) {
                suppressOriginalChild(worldArt);
                suppressOriginalSoldier(worldArt);
                fgDraw.drawEllipse(Vec2(sx + f * cam.len(24), sy + 1), cam.len(12), 3.0, Color(10, 10, 12, 125));
                return;
            }
        }

        if (!nearPartner) {
            suppressOriginalChild(worldArt);
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

        const sHandX = cam.sx(soldier.x - f * 8);
        const sHandY = cam.sy(soldier.y + soldier.h * 0.46, soldier.depth);
        const cHandX = cam.sx(childWX + f * 7);
        const cHandY = cam.sy(childWY + 36, childDepth);
        const swayY = speed > 8 ? Math.sin(this.animTime * 10.5) * cam.len(2.4) : Math.sin(this.animTime * 2.2) * cam.len(0.8);
        const claspX = (sHandX + cHandX) * 0.5;
        const claspY = (sHandY + cHandY) * 0.5 + swayY;

        fgDraw.drawSegment(Vec2(sHandX, sHandY + cam.len(5)), Vec2(claspX, claspY), Math.max(2.6, cam.len(3.0)), CUFF_CLOTH);
        const mendX = sHandX + (claspX - sHandX) * 0.72;
        const mendY = (sHandY + cam.len(5)) + (claspY - (sHandY + cam.len(5))) * 0.72;
        fgDraw.drawSegment(Vec2(mendX - f * 2, mendY - 1.5), Vec2(mendX + f * 2, mendY + 1.5), 1.3, CUFF_MEND);
        fgDraw.drawSegment(Vec2(cHandX, cHandY), Vec2(claspX, claspY), Math.max(2.0, cam.len(2.2)), CHILD_SLEEVE);
        fgDraw.drawDot(Vec2(claspX - f * 2.5, claspY + 1), Math.max(1.8, cam.len(1.4)), NEEDLE_CORD);
        fgDraw.drawCircle(Vec2(claspX, claspY), Math.max(2.8, cam.len(2.4)), CHILD_SKIN);
        fgGlow.drawDot(Vec2(claspX, claspY), Math.max(2.2, cam.len(1.8)), toColor(PALETTE.amberCore, 155));
    }

    /** 姿态 2 & 3：高石阶蹲背攀爬（mounting）与常规背负战斗移动（carrying） */
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

        // 行走与待机微幅呼吸起伏（贴合周戍重心，不飘浮）
        const walking = speed > 8 && soldier.onGround;
        const bob = walking
            ? Math.abs(Math.sin(this.animTime * 10.5)) * 2.3
            : Math.sin(this.animTime * 2.5) * 0.9;

        // 背负世界坐标：严格对齐后端 carryPose() 的 (x - facing * 12, y + 26) 并微抬肩头可读性
        const targetBackX = soldier.x - sf * 13;
        const targetBackY = soldier.y + 30 - crouchDip + bob;

        // 攀爬起手点在周戍身后脚边
        const startGroundX = soldier.x - sf * 24;
        const startGroundY = soldier.y;
        const arcLift = this.mode === "mounting" ? Math.sin(kMount * Math.PI) * 8 : 0;

        const childWX = startGroundX + (targetBackX - startGroundX) * kMount;
        const childWY = startGroundY + (targetBackY - startGroundY) * kMount + arcLift;
        this.childAnchorX = childWX;
        this.childAnchorY = childWY;

        const cx = cam.sx(childWX);
        const cy = cam.sy(childWY, soldier.depth);
        const childW = cam.len(22);
        const childH = cam.len(42 + (1 - kMount) * 18);

        // Phase 3 背负态整体手绘像素精灵（duo_carry_idle / duo_carry_run / duo_carry_fire），取代错位贴图 + 棍状手臂
        if (kMount >= 0.72 && soldier.rollT <= 0 && !p.gripping) {
            const firing = p.ticks < this.shotUntil;
            const duoClip = firing ? "duo_carry_fire" : (walking ? "duo_carry_run" : "duo_carry_idle");
            const duoAnchorX = firing ? 0.36 : 0.54;
            const duoFacing = firing ? this.shotFacing : faceSign;
            const duoLayer = depthEnabled ? depthOrder(soldier.depth, 4) : 4;
            const crouchScale = (soldier.covered || p.coverHug) ? 0.86 : 1.05;
            const duoH = cam.len(soldier.h * crouchScale);
            const sx = cam.sx(soldier.x);
            const sy = cam.sy(soldier.y, soldier.depth) + cam.len(bob * 0.7);
            if (worldArt.tryPlacePath("assets/art/actors_extra.clip|" + duoClip, "carry_duo_sprite", sx, sy, duoH, duoH, {
                anchorX: duoAnchorX,
                anchorY: 0,
                preserveAspect: true,
                facing: duoFacing,
                layer: duoLayer,
            })) {
                suppressOriginalSoldier(worldArt);
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
                return;
            }
        }

        // 蹲背瞬间为周戍脚侧补一层接地微影与护膝动作感
        if (this.mode === "mounting" && kMount < 0.72) {
            const scx = cam.sx(soldier.x);
            const scy = cam.sy(soldier.y, soldier.depth);
            fgDraw.drawEllipse(Vec2(scx - sf * cam.len(6), scy + 1), cam.len(22), 4.2, Color(10, 10, 12, 110));
        }

        // 背上小满精灵：放在周戍后一微层（layer 3 vs soldier 4），避免压住周戍面庞与鸟铳
        const backSlot = kMount < 0.45 ? "child_crouch" : "child_peek";
        const tilt = -sf * (walking ? 5.5 : 2.2);
        const childLayer = depthEnabled ? depthOrder(soldier.depth, 3) : 3;
        const placed = worldArt.tryPlace(backSlot, "carry_child", cx, cy, childW, childH, {
            facing: faceSign,
            angle: tilt,
            layer: childLayer,
        });

        // 贴图缺失时的像素风剪影回退
        if (!placed) {
            fgDraw.drawPolygon([
                Vec2(cx - childW * 0.4, cy + childH * 0.1),
                Vec2(cx + childW * 0.4, cy + childH * 0.1),
                Vec2(cx + childW * 0.3, cy + childH * 0.72),
                Vec2(cx - childW * 0.35, cy + childH * 0.72),
            ], CHILD_VEST, 1, toColor(PALETTE.amberCore, 165));
            fgDraw.drawCircle(Vec2(cx + sf * childW * 0.12, cy + childH * 0.84), childW * 0.32, CHILD_SKIN);
        }

        // 前景叠层：周戍托背护臂袖口（补线） + 小满环抱周戍双肩的手臂与腕上针套
        const shoulderX = cam.sx(soldier.x + sf * 3);
        const shoulderY = cam.sy(soldier.y + soldier.h * 0.72 - crouchDip + bob * 0.7, soldier.depth);
        const childShoulderX = cam.sx(childWX + sf * 5);
        const childShoulderY = cam.sy(childWY + 26, soldier.depth);

        // 1. 周戍反手托稳腿弯的旧布袖口（位于腿部下方）
        const hipSupportX = cam.sx(soldier.x - sf * 10);
        const hipSupportY = cam.sy(soldier.y + 30 - crouchDip + bob * 0.6, soldier.depth);
        fgDraw.drawSegment(
            Vec2(cam.sx(soldier.x - sf * 2), cam.sy(soldier.y + 42 - crouchDip, soldier.depth)),
            Vec2(hipSupportX, hipSupportY),
            Math.max(2.4, cam.len(2.8)),
            CUFF_CLOTH,
        );
        fgDraw.drawSegment(
            Vec2(hipSupportX - sf * 2, hipSupportY + 1),
            Vec2(hipSupportX + sf * 3, hipSupportY + 1),
            1.2,
            CUFF_MEND,
        );

        // 2. 小满搭在哥哥肩前的环抱臂（换弹时自然从肩后轻抬探向侧前方线盘）
        if (this.reachT > 0.05 && kMount > 0.7) {
            const reachFrac = smoothStep(this.reachT);
            const elbowX = shoulderX + sf * cam.len(4 + reachFrac * 5);
            const elbowY = shoulderY + cam.len(1 + reachFrac * 3);
            const handEndX = elbowX + sf * cam.len(5 + reachFrac * 11);
            const handEndY = elbowY + cam.len(2 + reachFrac * 5);
            fgDraw.drawSegment(Vec2(childShoulderX, childShoulderY), Vec2(elbowX, elbowY), Math.max(2.0, cam.len(2.1)), CHILD_SLEEVE);
            fgDraw.drawSegment(Vec2(elbowX, elbowY), Vec2(handEndX - sf * cam.len(3), handEndY - cam.len(1)), Math.max(1.7, cam.len(1.8)), CHILD_SLEEVE);
            // 腕上针套暗绳与纤细小手
            fgDraw.drawDot(Vec2(handEndX - sf * cam.len(3.2), handEndY - cam.len(0.8)), Math.max(1.5, cam.len(1.2)), NEEDLE_CORD);
            fgDraw.drawCircle(Vec2(handEndX, handEndY), Math.max(2.1, cam.len(1.8)), CHILD_SKIN);
            fgDraw.drawSegment(Vec2(handEndX, handEndY), Vec2(handEndX + sf * cam.len(3.5), handEndY + cam.len(1.2)), Math.max(1.1, cam.len(1.0)), CHILD_SKIN);
            fillRadialGlow(
                fgGlow,
                handEndX + sf * cam.len(3),
                handEndY + cam.len(1),
                cam.len(7 * reachFrac),
                cam.len(7 * reachFrac),
                toColor(PALETTE.amberCore, 72 * reachFrac),
                Color(244, 234, 214, 0),
                10,
            );
        } else if (kMount > 0.35) {
            const armAlpha = clamp01((kMount - 0.35) / 0.65);
            const gripX = shoulderX + sf * cam.len(4);
            const gripY = shoulderY - cam.len(2);
            fgDraw.drawSegment(
                Vec2(childShoulderX, childShoulderY),
                Vec2(gripX, gripY),
                Math.max(1.8, cam.len(2.0)),
                Color(164, 78, 54, Math.round(255 * armAlpha)),
            );
            fgDraw.drawDot(Vec2(gripX - sf * 2, gripY), Math.max(1.5, cam.len(1.2)), Color(198, 166, 114, Math.round(235 * armAlpha)));
            fgDraw.drawCircle(Vec2(gripX, gripY), Math.max(2.0, cam.len(1.7)), Color(236, 210, 182, Math.round(255 * armAlpha)));
        }
    }

    /** 姿态 4：第三段安全工台放下小满（并协同表现首次试握递器） */
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
        // 小满面向哥哥排布材料或递交成品
        worldArt.tryPlace(slot, "carry_child_bench", cx, cy, cW, cH, {
            facing: -f,
            layer: depthEnabled ? depthOrder(soldier.depth, 5) : 5,
        });
        fgDraw.drawEllipse(Vec2(cx, cam.sy(soldier.y, soldier.depth) + 1), cW * 0.48 * dropK, 3.2, Color(10, 10, 12, 130));

        // 首次制成/递交期间在两人手间绘手绘明式改制鸟铳（引路灯铳 / 回声铳，淘汰 2 条线段棍枪）
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
            fillRadialGlow(fgGlow, midX, midY, cam.len(14), cam.len(10), toColor(PALETTE.amberCore, 72), Color(244, 234, 214, 0), 10);
        }
    }
}

export function createCarryPosePlugin(): CarryPosePlugin {
    return new CarryPosePlugin();
}
