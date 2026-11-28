/** 角色像素帧随玩法姿态切换，脚底与当前相机共用世界坐标。 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { Actor, Enemy, Play, Trace } from "Script/watch/play";
import { FEAR_MAX } from "Script/watch/escort";
import { STEP } from "Script/watch/clock";
import { ACTOR_DEPTH_HALF, overlapsDepth } from "Script/watch/depth";
import { depthOrder } from "Script/watch/fe/occlusion";
import { PartyPose } from "Script/watch/fe/plugins";
import { CameraDirector } from "Script/watch/fe/camera";
import { AssetSlotHost, AssetSlotKey } from "Script/watch/fe/assets";
import { ActorAnimController, FootstepCue } from "Script/watch/fe/renderer/anim_controller";
import { PALETTE, drawDiamond, fillRadialGlow, toColor } from "Script/watch/fe/theme";

interface SlideDust {
    depth: number;
    x: number;
    y: number;
    facing: number;
    life: number;
}

interface Stride {
    actor: Actor;
    x: number;
    depth: number;
    speed: number;
    cycle: number;
    sampledCycle: number;
    sinceSample: number;
    effort: number;
}

function strideAt(actor: Actor): Stride {
    return { actor, x: actor.x, depth: actor.depth, speed: 0, cycle: 0, sampledCycle: 0, sinceSample: 0, effort: 0 };
}

const RUN_START_T = 0.10;
const RUN_STOP_T = 0.13;

function advanceStride(stride: Stride, steps: number, dt: number): void {
    const a = stride.actor;
    let distance = 0;
    if (steps > 0) {
        const dx = a.x - stride.x;
        const depth = a.depth - stride.depth;
        distance = Math.sqrt(dx * dx + depth * depth);
        const speed = distance / (steps * STEP);
        stride.speed = speed <= 380 ? speed : 0;
        stride.x = a.x;
        stride.depth = a.depth;
        stride.sinceSample = 0;
    } else {
        stride.sinceSample = Math.min(STEP, stride.sinceSample + dt);
    }
    if (!a.alive || !a.onGround || a.crouch || a.covered || a.rollT > 0) {
        stride.effort = 0;
        return;
    }
    if (stride.speed > 8) {
        stride.effort = Math.min(1, stride.effort + dt / RUN_START_T);
        const strideLength = a.h * (a.w <= 28 ? 1.40 : 1.32);
        stride.sampledCycle = (stride.sampledCycle + distance / strideLength) % 1;
        // Only the displayed pose extrapolates between ticks. The next sample uses measured travel.
        stride.cycle = (stride.sampledCycle + stride.speed * stride.sinceSample / strideLength) % 1;
    } else {
        stride.effort = Math.max(0, stride.effort - dt / RUN_STOP_T);
    }
}

const DUST_LIFE = 0.23;

const ZS_IDLE_CLIPS = [
    "assets/art/actors_zhoushu_anim.clip|zs_idle_0",
    "assets/art/actors_zhoushu_anim.clip|zs_idle_1",
    "assets/art/actors_zhoushu_anim.clip|zs_idle_2",
    "assets/art/actors_zhoushu_anim.clip|zs_idle_3",
];
const ZS_JUMP_CLIPS = [
    "assets/art/actors_zhoushu_anim.clip|zs_jump_0",
    "assets/art/actors_zhoushu_anim.clip|zs_jump_1",
    "assets/art/actors_zhoushu_anim.clip|zs_jump_2",
    "assets/art/actors_zhoushu_anim.clip|zs_jump_3",
];
const ZS_FIRE_CLIPS = [
    "assets/art/actors_zhoushu_anim.clip|zs_fire_0",
    "assets/art/actors_zhoushu_anim.clip|zs_fire_1",
    "assets/art/actors_zhoushu_anim.clip|zs_fire_2",
    "assets/art/actors_zhoushu_anim.clip|zs_fire_3",
];
const ZS_COVER_CLIPS = [
    "assets/art/actors_zhoushu_anim.clip|zs_cover_0",
    "assets/art/actors_zhoushu_anim.clip|zs_cover_1",
];
const ZS_HIT_CLIPS = [
    "assets/art/actors_zhoushu_anim.clip|zs_hit_0",
    "assets/art/actors_zhoushu_anim.clip|zs_hit_1",
];
const ZS_PUSH_CLIPS = [
    "assets/art/actors_zhoushu_anim.clip|zs_push_0",
    "assets/art/actors_zhoushu_anim.clip|zs_push_1",
    "assets/art/actors_zhoushu_anim.clip|zs_push_2",
    "assets/art/actors_zhoushu_anim.clip|zs_push_3",
];

const XM_IDLE_CLIPS = [
    "assets/art/actors_xiaoman_anim.clip|xm_idle_0",
    "assets/art/actors_xiaoman_anim.clip|xm_idle_1",
    "assets/art/actors_xiaoman_anim.clip|xm_idle_2",
    "assets/art/actors_xiaoman_anim.clip|xm_idle_3",
];
const XM_JUMP_CLIPS = [
    "assets/art/actors_xiaoman_anim.clip|xm_jump_0",
    "assets/art/actors_xiaoman_anim.clip|xm_jump_1",
    "assets/art/actors_xiaoman_anim.clip|xm_jump_2",
    "assets/art/actors_xiaoman_anim.clip|xm_jump_3",
];
const XM_CRAWL_CLIPS = [
    "assets/art/actors_xiaoman_anim.clip|xm_crawl_0",
    "assets/art/actors_xiaoman_anim.clip|xm_crawl_1",
    "assets/art/actors_xiaoman_anim.clip|xm_crawl_2",
    "assets/art/actors_xiaoman_anim.clip|xm_crawl_3",
];
const XM_PULL_MID_CLIP = "assets/art/actors_xiaoman_anim.clip|xm_pull_mid";
const XM_THROW_REL_CLIP = "assets/art/actors_xiaoman_anim.clip|xm_throw_rel";
const XM_FEAR_B_CLIP = "assets/art/actors_xiaoman_anim.clip|xm_fear_b";
const XM_PEEK_B_CLIP = "assets/art/actors_xiaoman_anim.clip|xm_peek_b";

const EN_GUN_IDLE_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_idle_0";
const EN_GUN_WALK_CLIPS = [
    "assets/art/actors_enemies_anim.clip|en_gun_walk_0",
    "assets/art/actors_enemies_anim.clip|en_gun_walk_1",
];
const EN_GUN_AIM_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_aim";
const EN_GUN_FIRE_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_fire";
const EN_GUN_HIT_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_hit";
const EN_GUN_DOWN_CLIP = "assets/art/actors_enemies_anim.clip|en_gun_down";

const EN_SHD_IDLE_CLIP = "assets/art/actors_enemies_anim.clip|en_shd_idle";
const EN_SHD_WALK_CLIP = "assets/art/actors_enemies_anim.clip|en_shd_walk_0";
const EN_SHD_BASH_CLIP = "assets/art/actors_enemies_anim.clip|en_shd_bash";
const EN_SHD_HIT_CLIP = "assets/art/actors_enemies_anim.clip|en_shd_hit";

const EN_BRK_WALK_CLIP = "assets/art/actors_enemies_anim.clip|en_brk_walk";
const EN_BRK_WINDUP_CLIP = "assets/art/actors_enemies_anim.clip|en_brk_windup";
const EN_BRK_CLEAVE_CLIP = "assets/art/actors_enemies_anim.clip|en_brk_cleave";
const EN_BRK_HIT_CLIP = "assets/art/actors_enemies_anim.clip|en_brk_hit";

const EN_LDR_IDLE_CLIP = "assets/art/actors_enemies_anim.clip|en_ldr_idle";
const EN_LDR_WALK_CLIP = "assets/art/actors_enemies_anim.clip|en_ldr_walk";
const EN_LDR_AIM_CLIP = "assets/art/actors_enemies_anim.clip|en_ldr_aim";
const EN_LDR_HIT_CLIP = "assets/art/actors_enemies_anim.clip|en_ldr_hit";

const SCAV_WALK_CLIPS = [
    "assets/art/actors_enemies_anim.clip|scav_walk_0",
    "assets/art/actors_enemies_anim.clip|scav_walk_1",
];
const SCAV_TURN_CLIP = "assets/art/actors_enemies_anim.clip|scav_turn";
const SCAV_RUN_CLIP = "assets/art/actors_enemies_anim.clip|scav_run";

const DOG_WALK_CLIP = "assets/art/actors_enemies_anim.clip|dog_walk";
const DOG_ALERT_CLIP = "assets/art/actors_enemies_anim.clip|dog_alert";
const DOG_RUN_CLIPS = [
    "assets/art/actors_enemies_anim.clip|dog_run_0",
    "assets/art/actors_enemies_anim.clip|dog_run_1",
];

const SLIDE_DUST_CLIPS = [
    "assets/art/vfx_ming_fx.clip|dust_0",
    "assets/art/vfx_ming_fx.clip|dust_1",
];

const IDLE_PING_PONG = [-1, 0, 1, 2, 3, 2, 1, 0];

export class ActorsRenderer {
    private slideDust: SlideDust[] = [];
    private dustCooldown = 0;
    private slideDuration = 0;
    private slideRemainder = 0;
    private strideTick = 0;
    private playerStride: Stride | undefined;
    private partnerStride: Stride | undefined;
    private anim = new ActorAnimController();
    private animTime = 0;
    private previousHp = 3;
    private previousAxle = 0;
    private cartMoving = false;
    private previousBottle = false;
    private previousTrace: Trace | undefined;
    private hitStartTick = 0;
    private hitUntil = -1;
    private throwStartTick = 0;
    private throwUntil = -1;
    private shotStartTick = 0;
    private shotUntil = -1;

    drainFootsteps(): FootstepCue[] {
        return this.anim.drainFootsteps();
    }

    reset(p: Play): void {
        this.slideDust = [];
        this.dustCooldown = 0;
        this.slideDuration = 0;
        this.slideRemainder = 0;
        this.strideTick = p.ticks;
        this.playerStride = strideAt(p.player);
        this.partnerStride = strideAt(p.partner);
        this.anim.reset(p);
        this.animTime = 0;
        this.previousHp = p.hp;
        this.previousAxle = p.cartAxle;
        this.cartMoving = false;
        this.previousBottle = p.hasBottle;
        this.previousTrace = p.trace;
        this.hitStartTick = 0;
        this.hitUntil = -1;
        this.throwStartTick = 0;
        this.throwUntil = -1;
        this.shotStartTick = 0;
        this.shotUntil = -1;
    }

    /** 按已经走过的距离更新步态，镜头和重新渲染均不改变跑步节奏。 */
    update(dt: number, p: Play): void {
        this.animTime += dt;
        if (p.hp < this.previousHp || p.gateNeedConfirm) {
            this.hitStartTick = p.ticks;
            this.hitUntil = p.ticks + 16;
            this.anim.player.triggerHit(p.player.facing);
        }
        if (this.previousBottle && !p.hasBottle && p.bottleFly !== undefined) {
            this.throwStartTick = p.ticks;
            this.throwUntil = p.ticks + 16;
        }
        if (p.trace !== undefined && p.trace !== this.previousTrace) {
            this.shotStartTick = p.ticks;
            this.shotUntil = p.ticks + 16;
            const shotDir = p.trace.x1 < p.trace.x0 ? -1 : 1;
            this.anim.player.triggerRecoil(shotDir);
        }
        this.cartMoving = Math.abs(p.cartAxle - this.previousAxle) > 0.01;
        this.previousAxle = p.cartAxle;
        this.previousHp = p.hp;
        this.previousBottle = p.hasBottle;
        this.previousTrace = p.trace;
        if (this.playerStride?.actor !== p.player) {
            this.playerStride = strideAt(p.player);
        }
        if (this.partnerStride?.actor !== p.partner) {
            this.partnerStride = strideAt(p.partner);
        }
        const steps = Math.max(0, p.ticks - this.strideTick);
        advanceStride(this.playerStride, steps, dt);
        advanceStride(this.partnerStride, steps, dt);
        this.strideTick = p.ticks;
        this.updateSlide(dt, steps, p, this.playerStride.speed);

        this.anim.player.update(
            dt,
            p.player,
            this.playerStride.cycle,
            this.playerStride.speed,
            this.playerStride.effort,
            p.player.covered || p.coverHug,
            this.anim.footstepCues,
        );
        this.anim.partner.update(
            dt,
            p.partner,
            this.partnerStride.cycle,
            this.partnerStride.speed,
            this.partnerStride.effort,
            p.partner.covered,
            this.anim.footstepCues,
        );
        this.anim.updateEnemiesAndNpcs(dt, p);
    }

    private slidePhase(a: Actor): number {
        const remaining = Math.max(0, a.rollT - this.slideRemainder);
        return this.slideDuration > 0 ? 1 - remaining / this.slideDuration : 0;
    }

    private updateSlide(dt: number, steps: number, p: Play, speed: number): void {
        const a = p.player;
        if (!p.childMode && a.rollT > 0) {
            // Reuse the time left between two simulation ticks on faster displays.
            this.slideRemainder = this.slideDuration === 0
                ? 0 : Math.max(0, Math.min(STEP, this.slideRemainder + dt - steps * STEP));
            this.slideDuration = Math.max(this.slideDuration, a.rollT);
            const progress = this.slidePhase(a);
            this.dustCooldown -= dt;
            if (a.onGround && speed > 8 && progress >= 0.16 && progress < 0.77 && this.dustCooldown <= 0) {
                this.slideDust.push({
                    x: a.x + a.facing * a.h * 0.34,
                    y: a.y,
                    depth: a.depth,
                    facing: a.facing,
                    life: DUST_LIFE,
                });
                this.dustCooldown = 0.038;
            }
        } else {
            this.slideDuration = 0;
            this.slideRemainder = 0;
            this.dustCooldown = 0;
        }
        let write = 0;
        for (const dust of this.slideDust) {
            dust.life -= dt;
            if (dust.life > 0) {
                this.slideDust[write] = dust;
                write += 1;
            }
        }
        this.slideDust.length = write;
    }

    drawAll(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        pose?: PartyPose,
    ): void {
        this.drawSlideDust(fgGlow, assets, p, cam);

        // 倭寇举铳时显示收紧的预警虚线。
        let i = 0;
        for (i = 0; i < p.enemies.length; i++) {
            this.drawEnemy(fgDraw, fgGlow, assets, p.enemies[i], i, p, cam);
        }

        // 3. 村口拾荒者
        if (p.room.key === "village" && p.room.scavenger !== undefined) {
            this.drawScavenger(fgDraw, fgGlow, assets, p, cam);
        }

        // 4. 森林猎犬
        if (p.room.key === "forest" && p.room.story !== undefined && p.room.story.dog !== undefined) {
            this.drawDog(fgDraw, fgGlow, assets, p, cam);
        }

        // 5. 同伴（先画同伴，再画主角，确保主角层级最突出；背负插件接管时一并跳过原生精灵与脚底阴影）
        if (p.partner.alive && !pose?.partner) {
            const partnerIsChild = p.partner.w <= 28;
            if (partnerIsChild) {
                this.drawXiaoman(fgDraw, fgGlow, assets, p.partner, p, cam, false);
            } else {
                this.drawZhouShu(fgDraw, fgGlow, assets, p.partner, p, cam, false);
            }
        }

        // 6. 当前操控主角
        if (p.player.alive) {
            if (p.childMode) {
                this.drawXiaoman(fgDraw, fgGlow, assets, p.player, p, cam, true);
            } else {
                this.drawZhouShu(fgDraw, fgGlow, assets, p.player, p, cam, true, pose?.player);
            }
        }
    }

    private drawSlideDust(draw: DrawNode.Type, assets: AssetSlotHost, p: Play, cam: CameraDirector): void {
        const depthEnabled = p.room.depth !== undefined;
        for (let i = 0; i < this.slideDust.length; i++) {
            const dust = this.slideDust[i];
            const alpha = dust.life / DUST_LIFE;
            const spread = 1 - alpha;
            const dScale = cam.depthScale(dust.depth, depthEnabled);
            const x = cam.sx(dust.x - dust.facing * spread * 17);
            const y = cam.sy(dust.y + 1.5 + spread * 2, dust.depth);
            const dustSz = cam.len(14 + spread * 16) * dScale;
            const clip = SLIDE_DUST_CLIPS[spread < 0.45 ? 0 : 1];
            if (!assets.tryPlacePath(clip, "slide_dust_" + i, x, y, dustSz * 1.25, dustSz, {
                anchorX: 0.5,
                anchorY: 0,
                preserveAspect: true,
                facing: dust.facing,
                opacity: alpha * 0.85,
                layer: depthEnabled ? depthOrder(dust.depth, 5) : 6,
            })) {
                draw.drawEllipse(Vec2(x, y), cam.len(5 + spread * 7), cam.len(1.5 + spread * 2),
                    Color(166, 147, 124, 170 * alpha));
                draw.drawDot(Vec2(x - dust.facing * cam.len(3), y + cam.len(4)),
                    cam.len(1.1), Color(195, 174, 148, 135 * alpha));
            }
        }
    }

    /** 计算角色脚下最近的支撑面高度，滞空阴影落在脚下平台而非穿底掉回 y=0。 */
    supportGroundY(p: Play, a: Actor): number {
        const half = a.w * 0.5;
        let g = 0;
        let i = 0;
        for (i = 0; i < p.room.floors.length; i++) {
            const f = p.room.floors[i];
            if (a.x + half > f.x0 && a.x - half < f.x1 && f.y <= a.y + 0.5 && f.y > g) {
                g = f.y;
            }
        }
        for (i = 0; i < p.boxes.length; i++) {
            const b = p.boxes[i];
            if (b.broken === true || b.hidden === true || b.soft === true) {
                continue;
            }
            if (a.x + half > b.x0 && a.x - half < b.x1 && b.y1 <= a.y + 0.5 && b.y1 > g &&
                overlapsDepth(a.depth, b.depth, ACTOR_DEPTH_HALF)) {
                g = b.y1;
            }
        }
        return g;
    }

    /** 角色脚底接触影与滞空垂直投影锚点（直接放入 worldArt 以 layer-1 随深度排序，永不被地面吃掉）。 */
    private drawGroundedShadow(
        overlayDraw: DrawNode.Type,
        assets: AssetSlotHost,
        shadowKey: string,
        cx: number,
        by: number,
        shadowY: number,
        wPx: number,
        airHeightWorld: number,
        actorLayer: number,
        depthScale: number,
        isControlled: boolean,
    ): void {
        const airborne = airHeightWorld > 1.5;
        const heightShrink = airborne ? Math.max(0.54, 1 / (1 + airHeightWorld / 82)) : 1.0;
        const shW = Math.max(16, wPx * 1.48 * heightShrink);
        const shH = Math.max(6, wPx * 0.42 * heightShrink);
        assets.tryPlace(airborne ? "dp_shadow_air" : "dp_shadow_contact", shadowKey, cx, shadowY + 1, shW, shH, {
            layer: actorLayer - 1,
            opacity: airborne ? 0.88 : (isControlled ? 0.92 : 0.82),
        });
        if (airborne) {
            // 滞空时在落地影与脚底之间绘极克制冷月垂线标尺，彻底区分“跳高 wy”与“进深 depth”
            const tickTop = Math.min(by - 2, shadowY + Math.max(6, (by - shadowY) * 0.35));
            if (tickTop > shadowY + 3) {
                overlayDraw.drawSegment(Vec2(cx, shadowY + 2), Vec2(cx, tickTop), 1.1, Color(148, 178, 202, 118));
            }
        } else if (isControlled) {
            // 主角脚下极淡月光足印描边，暗黑像素场景中一眼锁定自身所处车道
            const rx = shW * 0.38;
            const ry = Math.max(2.2, shH * 0.32);
            const ring: Vec2.Type[] = [];
            for (let i = 0; i < 12; i++) {
                const ang = (i / 12) * Math.PI * 2;
                ring.push(Vec2(cx + Math.cos(ang) * rx, shadowY + 1 + Math.sin(ang) * ry));
            }
            overlayDraw.drawPolygon(ring, Color(0, 0, 0, 0), 0.9, Color(146, 178, 200, Math.round(74 * depthScale)));
        }
    }

    /** 周戍。动作贴图以脚底对齐（保持全部角色素材不变），按 2.5D 深度自适应近大远小与接地影。 */
    private drawZhouShu(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        a: Actor,
        p: Play,
        cam: CameraDirector,
        isControlled: boolean,
        bodyPlaced: boolean = false,
    ): void {
        const cx = cam.sx(a.x);
        const by = cam.sy(a.y, a.depth);
        const depthEnabled = p.room.depth !== undefined;
        const groundY = !a.onGround ? this.supportGroundY(p, a) : a.y;
        const shadowY = !a.onGround ? cam.sy(groundY, a.depth) : by;
        const airH = Math.max(0, a.y - groundY);
        const dScale = cam.depthScale(a.depth, depthEnabled);
        const H = cam.len(a.h) * dScale;
        const W = cam.len(a.w) * dScale;
        const f = a.facing;
        const speed = Math.max(Math.abs(a.vx), Math.abs(a.depthSpeed));
        const motion = isControlled ? this.anim.player : this.anim.partner;
        const juice = motion.sampleJuice(cam.ppu);
        const drawX = cx + juice.offsetX * dScale;
        const actorLayer = depthEnabled ? depthOrder(a.depth, 4) : 4;
        const dShade = cam.depthShade(a.depth, depthEnabled);
        const tone = Math.round(255 * Math.min(1, dShade + 0.06));
        const depthTint = depthEnabled && a.depth > 6 ? Color(tone, tone, Math.min(255, tone + 8), 255) : undefined;
        const hitTint = juice.hitFlash > 0.12
            ? Color(255, Math.round(230 - 38 * juice.hitFlash), Math.round(212 - 44 * juice.hitFlash), 255)
            : depthTint;

        this.drawGroundedShadow(fgDraw, assets, "shadow_soldier", cx, by, shadowY, W, airH, actorLayer, dScale, isControlled);
        if (bodyPlaced) {
            return;
        }

        let slot: AssetSlotKey = "soldier_idle";
        let animClip = "";
        let height = H;
        let frame = 0;
        let facing = f;
        let extraScaleY = 1;
        const step = Math.floor(this.animTime * 10);
        const gait = isControlled ? this.playerStride : this.partnerStride;

        if (isControlled && p.ticks < this.hitUntil) {
            slot = "soldier_hit";
            const elapsed = Math.max(0, p.ticks - this.hitStartTick);
            animClip = ZS_HIT_CLIPS[elapsed < 7 ? 0 : 1];
        } else if (a.rollT > 0) {
            slot = "soldier_slide";
            const progress = this.slidePhase(a);
            frame = progress < 0.16 ? 0 : (progress < 0.64 ? 1 : (progress < 0.82 ? 2 : 3));
        } else if (p.phase === "prologue-give") {
            slot = "soldier_offer";
            height *= 0.75;
            facing = p.partner.x >= a.x ? 1 : -1;
        } else if (isControlled && p.gripping) {
            slot = "soldier_push";
            facing = p.room.cart.handleOffset < 0 ? 1 : -1;
            const pushIdx = this.cartMoving ? (Math.floor(motion.pushCycle * 4) % 4) : 0;
            animClip = ZS_PUSH_CLIPS[pushIdx];
            frame = this.cartMoving ? step : 0;
            height *= 0.91;
        } else if (isControlled && p.escort.state === "calming") {
            slot = "soldier_knock";
            const calm = p.escort.calmTick;
            frame = (calm >= 12 && calm < 18) || (calm >= 36 && calm < 42) ? 1 : 0;
            height *= 0.76;
        } else if (p.phase === "gate-send" && p.room.story?.gate !== undefined &&
            Math.abs(a.x - p.room.story.gate.doorX) <= 60 && speed <= 8) {
            slot = "soldier_hold";
        } else if (isControlled && p.ticks < this.shotUntil) {
            const running = speed > 8;
            slot = running ? "soldier_fire_move" : "soldier_fire";
            frame = running ? step : 0;
            facing = p.trace !== undefined && p.trace.x1 < p.trace.x0 ? -1 : 1;
            if (!running) {
                const elapsed = Math.max(0, p.ticks - this.shotStartTick);
                const fIdx = elapsed < 2 ? 0 : (elapsed < 5 ? 1 : (elapsed < 11 ? 2 : 3));
                animClip = ZS_FIRE_CLIPS[fIdx];
            }
        } else if (a.covered || (isControlled && p.coverHug)) {
            slot = "soldier_cover";
            animClip = ZS_COVER_CLIPS[Math.floor(motion.coverTime * 2.2) % 2];
            extraScaleY = 1 + Math.sin(motion.coverTime * 3.1) * 0.012;
            height *= 0.77;
        } else if (!a.onGround) {
            const jIdx = a.vy > 110 ? 0 : (a.vy > -35 ? 1 : 2);
            animClip = ZS_JUMP_CLIPS[jIdx];
        } else if (motion.landTimer > 0.05 && (gait?.speed ?? 0) <= 8) {
            animClip = ZS_JUMP_CLIPS[3];
        } else if ((gait?.speed ?? 0) > 8) {
            slot = "soldier_run";
            frame = step;
        } else if (motion.idleTime >= 0.14 && (gait?.effort ?? 0) <= 0.001) {
            const beat = IDLE_PING_PONG[Math.floor((motion.idleTime - 0.14) * 3.4) % IDLE_PING_PONG.length];
            if (beat >= 0) {
                animClip = ZS_IDLE_CLIPS[beat];
            }
            extraScaleY = 1 + Math.sin(motion.idleTime * 2.4) * 0.008;
        }
        const pose = {
            facing,
            frame,
            layer: actorLayer,
            angle: juice.angleOffset,
            scaleXMul: juice.scaleXMul,
            scaleYMul: juice.scaleYMul * extraScaleY,
            color: hitTint,
        };
        const sliding = slot === "soldier_slide"
            && assets.tryPlaceSlide("actor_soldier", cx, by, W, height, this.slidePhase(a), { facing, layer: actorLayer, color: hitTint });
        const running = animClip === "" && (slot === "soldier_run" || slot === "soldier_idle") && a.onGround
            && gait !== undefined && gait.effort > 0
            && assets.tryPlaceRun("soldier", "actor_soldier", cx, by, W, height, gait.cycle, pose, gait.effort);
        const placedAnim = animClip !== "" && assets.tryPlacePath(animClip, "actor_soldier", drawX, by, H, H, {
            anchorX: 0.5,
            anchorY: 0,
            preserveAspect: true,
            facing,
            angle: juice.angleOffset,
            scaleXMul: juice.scaleXMul,
            scaleYMul: juice.scaleYMul * extraScaleY,
            color: hitTint,
            layer: actorLayer,
        });
        if (sliding || running || placedAnim || assets.tryPlace(slot, "actor_soldier", drawX, by, W, height, pose)) {
            if (juice.hitFlash > 0.35) {
                fillRadialGlow(fgGlow, drawX, by + H * 0.56, H * 0.38, H * 0.44,
                    Color(255, 224, 198, Math.round(74 * juice.hitFlash)), Color(214, 72, 56, 0), 12);
            }
            return;
        }
        // 极简缺图保底（正式资源全部存在，仅防极端缺失白屏）
        fgDraw.drawRect(Rect(cx - W * 0.4, by, W * 0.8, height), Color(32, 46, 66, 220));
    }

    /** 小满（孩子线主角 / 护送同伴；保持原角色精灵不变，按 2.5D 深度缩放与接地影锚定）。 */
    private drawXiaoman(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        a: Actor,
        p: Play,
        cam: CameraDirector,
        isControlled: boolean,
    ): void {
        const cx = cam.sx(a.x);
        const by = cam.sy(a.y, a.depth);
        const depthEnabled = p.room.depth !== undefined;
        const groundY = !a.onGround ? this.supportGroundY(p, a) : a.y;
        const shadowY = !a.onGround ? cam.sy(groundY, a.depth) : by;
        const airH = Math.max(0, a.y - groundY);
        const dScale = cam.depthScale(a.depth, depthEnabled);
        const H = cam.len(a.h) * dScale;
        const W = cam.len(a.w) * dScale;
        const f = a.facing;
        const speed = Math.max(Math.abs(a.vx), Math.abs(a.depthSpeed));
        const gait = isControlled ? this.playerStride : this.partnerStride;
        const motion = isControlled ? this.anim.player : this.anim.partner;
        const juice = motion.sampleJuice(cam.ppu);
        const actorLayer = depthEnabled ? depthOrder(a.depth, 5) : 5;

        const afraid = !isControlled && p.escort.fear > 0;
        let slot: AssetSlotKey = "child_idle";
        let animClip = "";
        let height = H;
        let frame = 0;
        let extraScaleY = 1;
        let shiverX = 0;
        const step = Math.floor(this.animTime * 10);
        const nearCover = p.room.solids.some(solid =>
            !solid.decorative && solid.h <= 64 && solid.y <= 2 &&
            overlapsDepth(a.depth, solid.depth, ACTOR_DEPTH_HALF) &&
            Math.min(Math.abs(a.x - solid.x), Math.abs(a.x - solid.x - solid.w)) <= 30,
        );
        if (p.phase === "tower-knock" && (p.phaseTick < 6 || (p.phaseTick >= 12 && p.phaseTick < 18))) {
            slot = "child_knock";
        } else if ((p.phase === "tower-given" && p.phaseTick >= 60 && p.phaseTick < 120) ||
            (p.phase === "prologue-give" && p.phaseTick >= 12 && p.phaseTick < 36)) {
            slot = "child_offer";
        } else if (isControlled && p.ticks < this.throwUntil) {
            slot = "child_throw";
            if (p.ticks - this.throwStartTick < 7) {
                animClip = XM_THROW_REL_CLIP;
            }
        } else if (isControlled && p.hasBottle && p.aimHold > 0) {
            slot = "child_aim";
        } else if (isControlled && p.gripping) {
            slot = "child_pull";
            if (this.cartMoving) {
                const pBeat = Math.floor(motion.pushCycle * 4) % 4;
                if (pBeat === 1 || pBeat === 3) {
                    animClip = XM_PULL_MID_CLIP;
                } else {
                    frame = pBeat === 2 ? 1 : 0;
                }
            }
        } else if (afraid && p.escort.state === "frozen") {
            slot = "child_fear";
            height *= 0.74;
            shiverX = Math.sin(this.animTime * 42) * 1.4;
            if (Math.floor(this.animTime * 7) % 2 === 1) {
                animClip = XM_FEAR_B_CLIP;
            }
        } else if (!isControlled && nearCover &&
            (p.room.key === "street" || p.room.key === "checkpoint") && speed < 8) {
            slot = "child_peek";
            height *= 0.83;
            if (Math.floor(this.animTime * 2.2) % 2 === 1) {
                animClip = XM_PEEK_B_CLIP;
            }
        } else if (a.crouch) {
            slot = "child_crouch";
            const crawlIdx = speed > 6 ? (Math.floor(motion.crouchCycle * 4) % 4) : 0;
            animClip = XM_CRAWL_CLIPS[crawlIdx];
            frame = speed > 8 ? step : 0;
        } else if (!a.onGround) {
            const jIdx = a.vy > 100 ? 0 : (a.vy > -30 ? 1 : 2);
            animClip = XM_JUMP_CLIPS[jIdx];
        } else if (motion.landTimer > 0.05 && (gait?.speed ?? 0) <= 8) {
            animClip = XM_JUMP_CLIPS[3];
        } else if ((gait?.speed ?? 0) > 8) {
            slot = "child_run";
            frame = step;
        } else if (motion.idleTime >= 0.14 && (gait?.effort ?? 0) <= 0.001) {
            const beat = IDLE_PING_PONG[Math.floor((motion.idleTime - 0.14) * 3.2) % IDLE_PING_PONG.length];
            if (beat >= 0) {
                animClip = XM_IDLE_CLIPS[beat];
            }
            extraScaleY = 1 + Math.sin(motion.idleTime * 2.8) * 0.01;
        }

        const facing = slot === "child_pull" ? (p.room.cart.handleOffset < 0 ? 1 : -1) : f;
        const drawX = cx + (juice.offsetX + shiverX) * dScale;
        const dShade = cam.depthShade(a.depth, depthEnabled);
        const tone = Math.round(255 * Math.min(1, dShade + 0.06));
        const depthTint = depthEnabled && a.depth > 6 ? Color(tone, tone, Math.min(255, tone + 6), 255) : undefined;
        const pose = {
            facing,
            frame,
            layer: actorLayer,
            angle: juice.angleOffset,
            scaleXMul: juice.scaleXMul,
            scaleYMul: juice.scaleYMul * extraScaleY,
            color: depthTint,
        };
        this.drawGroundedShadow(fgDraw, assets, "shadow_child", cx, by, shadowY, W, airH, actorLayer, dScale, isControlled);
        const running = animClip === "" && (slot === "child_run" || slot === "child_idle") && a.onGround
            && gait !== undefined && gait.effort > 0
            && assets.tryPlaceRun("child", "actor_child", cx, by, W, height, gait.cycle, pose, gait.effort);
        const placedAnim = animClip !== "" && assets.tryPlacePath(animClip, "actor_child", drawX, by, H, H, {
            anchorX: 0.5,
            anchorY: 0,
            preserveAspect: true,
            facing,
            angle: juice.angleOffset,
            scaleXMul: juice.scaleXMul,
            scaleYMul: juice.scaleYMul * extraScaleY,
            color: depthTint,
            layer: actorLayer,
        });
        if (running || placedAnim || assets.tryPlace(slot, "actor_child", drawX, by, W, height, pose)) {
            if (afraid) {
                this.drawFear(fgGlow, p, cx, by + H + 14);
            }
            return;
        }
        fgDraw.drawRect(Rect(cx - W * 0.4, by, W * 0.8, height), Color(168, 126, 72, 220));
        if (afraid) {
            this.drawFear(fgGlow, p, cx, by + H + 16);
        }
    }

    private drawFear(fgGlow: DrawNode.Type, p: Play, x: number, y: number): void {
        const tint = p.escort.state === "frozen" ? PALETTE.crimson : PALETTE.amber;
        for (let i = 0; i < FEAR_MAX; i++) {
            const lit = i < p.escort.fear;
            drawDiamond(fgGlow, x + (i - 1) * 13, y, 4, 5,
                toColor(lit ? tint : PALETTE.steelDark, 215), 1, toColor(tint, lit ? 235 : 100));
        }
    }

    private drawEnemyWarning(fgGlow: DrawNode.Type, e: Enemy, p: Play, cam: CameraDirector, f: number): void {
        const x = cam.sx(e.x + f * 20);
        const y = cam.sy(e.y + e.h * 0.69, e.depth ?? 0);
        const dx = cam.sx(p.player.x) - x;
        const dy = cam.sy(p.player.y + p.player.h * 0.56, p.player.depth) - y;
        const length = 0.4 + 0.6 * Math.min(1, e.warnT / 36);
        for (let i = 0; i < 8; i += 2) {
            const a = length * i / 8;
            const b = length * (i + 1) / 8;
            fgGlow.drawSegment(Vec2(x + dx * a, y + dy * a), Vec2(x + dx * b, y + dy * b),
                1.3, Color(220, 120, 88, 210));
        }
    }

    /** 倭寇动作和开火前的虚线提示。 */
    private drawEnemy(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        e: Enemy,
        index: number,
        p: Play,
        cam: CameraDirector,
    ): void {
        const cx = cam.sx(e.x);
        const depth = e.depth ?? 0;
        const depthEnabled = p.room.depth !== undefined;
        const dScale = cam.depthScale(depth, depthEnabled);
        const by = cam.sy(e.y, depth);
        const H = cam.len(e.h) * dScale;
        const W = cam.len(e.w) * dScale;
        const f = p.player.x >= e.x ? 1 : -1;

        // 试射靶（escort3 工台靶位）：采用 props_ming.clip|target_dummy 明代草束木靶精灵，零线段拼接
        if (e.kind === "target") {
            const targetLayer = depthEnabled ? depthOrder(depth, 3) : 3;
            this.drawGroundedShadow(fgDraw, assets, "shadow_target_" + index, cx, by, by, W * 1.1, 0, targetLayer, dScale, false);
            const angle = !e.alive ? f * 62 : (e.hitT > 0 ? f * 18 : 0);
            const tint = (e.hitT > 0 || !e.alive) ? Color(238, 196, 174, 255) : Color(255, 255, 255, 255);
            assets.tryPlacePath("assets/art/props_ming.clip|target_dummy", "actor_target_" + index, cx, by, H * 0.82, H * 0.96, {
                anchorX: 0.5,
                anchorY: 0,
                preserveAspect: true,
                angle,
                color: tint,
                opacity: e.alive ? 1 : 0.76,
                layer: targetLayer,
            });
            return;
        }

        const enemyLayer = depthEnabled ? depthOrder(depth, 3) : 3;
        if (e.alive) {
            this.drawGroundedShadow(fgDraw, assets, "shadow_enemy_" + index, cx, by, by, W * 1.05, 0, enemyLayer, dScale, false);
        } else {
            assets.tryPlace("dp_shadow_contact", "shadow_enemy_" + index, cx, by + 1, Math.max(18, W * 1.65), Math.max(6, W * 0.42), {
                layer: enemyLayer - 1,
                opacity: 0.56,
            });
        }
        const es = index < this.anim.enemies.length ? this.anim.enemies[index] : undefined;
        const moving = (es?.speed ?? 0) > 6;
        const walkStep = Math.floor((es?.walkCycle ?? 0) * 4) % 2;
        const hitFlash = es !== undefined ? es.hitFlash : 0;
        const dying = !e.alive && (es?.deathTime ?? 1) < 0.15;
        const breathY = (e.alive && !moving && e.hitT <= 0)
            ? (1 + Math.sin(this.animTime * 2.4 + (es?.idlePhase ?? index)) * 0.014)
            : 1;
        const knockX = (e.hitT > 0 || dying) ? -f * cam.len(3.5 * Math.max(0.3, hitFlash)) * dScale : 0;
        const hitAngle = (e.hitT > 0 || dying) ? -f * 5.5 : 0;
        const dShade = cam.depthShade(depth, depthEnabled);
        const shadeMul = depthEnabled && depth > 6 ? Math.min(1, dShade + 0.06) : 1;
        const baseTone = Math.round(255 * shadeMul);
        let enemyClip = "";
        let enemyTint = hitFlash > 0.12
            ? Color(255, Math.round(220 - 42 * hitFlash), Math.round(196 - 52 * hitFlash), 255)
            : Color(baseTone, baseTone, Math.min(255, baseTone + (depthEnabled && depth > 6 ? 8 : 0)), 255);
        let drawHeight = H * 1.01;
        let cleaving = false;

        if (e.kind === "shield" && ((e.shieldHp ?? 0) > 0 || !e.alive || e.hitT > 0)) {
            if (!e.alive) {
                enemyClip = dying ? EN_SHD_HIT_CLIP : EN_GUN_DOWN_CLIP;
            } else if (e.hitT > 0) {
                enemyClip = EN_SHD_HIT_CLIP;
            } else if (e.warnT > 0) {
                enemyClip = EN_SHD_BASH_CLIP;
            } else if (moving) {
                enemyClip = walkStep === 0 ? EN_SHD_WALK_CLIP : EN_SHD_IDLE_CLIP;
            } else {
                enemyClip = EN_SHD_IDLE_CLIP;
            }
            if (e.alive && (e.shieldHp ?? 2) <= 1 && hitFlash <= 0.12) {
                enemyTint = Color(Math.round(238 * shadeMul), Math.round(198 * shadeMul), Math.round(174 * shadeMul), 255);
            }
        } else if (e.kind === "breaker") {
            drawHeight = H * 1.03;
            if (!e.alive) {
                enemyClip = dying ? EN_BRK_HIT_CLIP : EN_GUN_DOWN_CLIP;
            } else if (e.hitT > 0) {
                enemyClip = EN_BRK_HIT_CLIP;
            } else if ((e.swingT ?? 0) > 0) {
                cleaving = (es?.swingTime ?? 0) >= 0.12;
                enemyClip = cleaving ? EN_BRK_CLEAVE_CLIP : EN_BRK_WINDUP_CLIP;
            } else if (e.warnT > 0) {
                enemyClip = EN_BRK_WINDUP_CLIP;
            } else {
                enemyClip = EN_BRK_WALK_CLIP;
            }
        } else if (e.kind === "leader") {
            drawHeight = H * 1.04;
            if (!e.alive) {
                enemyClip = dying ? EN_LDR_HIT_CLIP : EN_GUN_DOWN_CLIP;
            } else if (e.hitT > 0) {
                enemyClip = EN_LDR_HIT_CLIP;
            } else if (e.warnT > 0) {
                enemyClip = EN_LDR_AIM_CLIP;
            } else if (moving) {
                enemyClip = walkStep === 0 ? EN_LDR_WALK_CLIP : EN_LDR_IDLE_CLIP;
            } else {
                enemyClip = EN_LDR_IDLE_CLIP;
            }
        } else {
            // 普通倭寇火器手（8 帧高精像素全状态覆盖）
            if (!e.alive) {
                enemyClip = dying ? EN_GUN_HIT_CLIP : EN_GUN_DOWN_CLIP;
            } else if (e.hitT > 0) {
                enemyClip = EN_GUN_HIT_CLIP;
            } else if (e.warnT > 0) {
                enemyClip = e.warnT <= 6 ? EN_GUN_FIRE_CLIP : EN_GUN_AIM_CLIP;
            } else if (moving) {
                enemyClip = EN_GUN_WALK_CLIPS[walkStep];
            } else {
                enemyClip = EN_GUN_IDLE_CLIP;
            }
        }

        if (enemyClip !== "" && assets.tryPlacePath(
            enemyClip,
            "actor_enemy_" + index,
            cx + knockX,
            by,
            drawHeight,
            drawHeight,
            {
                anchorX: 0.5,
                anchorY: 0,
                preserveAspect: true,
                facing: f,
                angle: hitAngle,
                scaleYMul: breathY,
                color: enemyTint,
                opacity: e.alive ? 1 : 0.78,
                layer: enemyLayer,
            },
        )) {
            if (hitFlash > 0.35) {
                fillRadialGlow(fgGlow, cx + knockX, by + H * 0.54, H * 0.34, H * 0.38,
                    Color(255, 224, 186, Math.round(78 * hitFlash)), Color(214, 72, 52, 0), 12);
            }
            if (cleaving) {
                fgGlow.drawArc(Vec2(cx + f * cam.len(12), by + H * 0.56), cam.len(22), f > 0 ? -48 : 132, f > 0 ? 54 : 234, 2.4, toColor(PALETTE.sealRedBright, 215));
                fgGlow.drawArc(Vec2(cx + f * cam.len(12), by + H * 0.56), cam.len(18), f > 0 ? -40 : 140, f > 0 ? 48 : 228, 1.4, toColor(PALETTE.amberCore, 185));
            }
            if (e.alive && e.warnT > 0) {
                this.drawEnemyWarning(fgGlow, e, p, cam, f);
            }
            return;
        }

        let slot: AssetSlotKey = "enemy_idle";
        if (!e.alive) {
            slot = "enemy_down";
        } else if (e.hitT > 0) {
            slot = "enemy_hit";
        } else if (e.warnT > 0) {
            slot = "enemy_aim";
        }
        const height = e.alive ? H : H * 0.24;
        if (assets.tryPlace(slot, "actor_enemy_" + index, cx, by, W, height, {
            facing: f, opacity: e.alive ? 1 : 0.78, layer: enemyLayer,
        })) {
            if (e.alive) {
                this.drawEnemyArchetypeGear(fgDraw, fgGlow, assets, e, index, cx, by, H, f, cam, enemyLayer + 1);
                if (e.warnT > 0) {
                    this.drawEnemyWarning(fgGlow, e, p, cam, f);
                }
            }
            return;
        }
        if (e.alive) {
            fgDraw.drawRect(Rect(cx - W * 0.4, by, W * 0.8, height), Color(96, 56, 48, 220));
        }
    }

    /** 区分盾手 / 破障手 / 带队者的明初冷兵器轮廓（像素藤盾精灵，灰度与实战均一眼可辨） */
    private drawEnemyArchetypeGear(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        e: Enemy,
        index: number,
        cx: number,
        by: number,
        H: number,
        f: number,
        cam: CameraDirector,
        layer: number,
    ): void {
        if (e.kind === "shield" && (e.shieldHp ?? 0) > 0) {
            const shX = cx + f * cam.len(13);
            const cracked = (e.shieldHp ?? 2) <= 1;
            if (!assets.tryPlace("fe_gear_rattan_shield", "enemy_shield_" + index, shX, by + H * 0.44, cam.len(22), H * 0.64, {
                facing: f,
                color: cracked ? Color(224, 178, 146, 255) : Color(255, 255, 255, 255),
                layer,
            })) {
                const shW = Math.max(5, cam.len(8));
                fgDraw.drawRect(Rect(shX - shW * 0.5, by + H * 0.08, shW, H * 0.72), Color(96, 66, 42, 250), 1.3, Color(168, 174, 180, 230));
            }
            if (cracked) {
                fgDraw.drawSegment(Vec2(shX - cam.len(4), by + H * 0.30), Vec2(shX + cam.len(4), by + H * 0.56), 1.4, Color(24, 18, 16, 235));
            }
        } else if (e.kind === "breaker") {
            const swing = (e.swingT ?? 0) > 0;
            const handleX0 = cx - f * cam.len(4);
            const handleY0 = by + H * 0.44;
            const tipX = cx + f * cam.len(swing ? 26 : 19);
            const tipY = by + H * (swing ? 0.46 : 0.78);
            fgDraw.drawSegment(Vec2(handleX0, handleY0), Vec2(tipX, tipY), Math.max(2.2, cam.len(3.0)), Color(98, 66, 44, 255));
            fgDraw.drawPolygon([
                Vec2(tipX - f * cam.len(3), tipY - cam.len(4)),
                Vec2(tipX + f * cam.len(9), tipY - cam.len(1)),
                Vec2(tipX + f * cam.len(7), tipY + cam.len(9)),
                Vec2(tipX - f * cam.len(2), tipY + cam.len(6)),
            ], Color(148, 154, 162, 250), 1.0, Color(224, 228, 232, 220));
            if (swing) {
                fgGlow.drawArc(Vec2(cx + f * cam.len(10), by + H * 0.56), cam.len(18), f > 0 ? -40 : 140, f > 0 ? 50 : 230, 1.8, toColor(PALETTE.rouge, 195));
            }
        } else if (e.kind === "leader") {
            // 侧线带队者：笠顶朱缨与肩带辨识
            const topY = by + H * 1.02;
            fgDraw.drawSegment(Vec2(cx, topY), Vec2(cx - f * cam.len(10), topY + cam.len(9)), 2.2, toColor(PALETTE.rouge, 240));
            fgDraw.drawDot(Vec2(cx - f * cam.len(10), topY + cam.len(9)), 2.6, toColor(PALETTE.crimsonCore, 235));
        }
    }

    /** 村口拾荒者（动态视野锥 + 听觉转头 + 发现进度弧） */
    private drawScavenger(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
    ): void {
        const s = p.room.scavenger;
        if (s === undefined) {
            return;
        }
        const cx = cam.sx(p.scavX);
        const by = cam.sy(s.y);
        const H = cam.len(s.h);
        const W = cam.len(26);
        const f = p.scavState === "chase" ? (p.player.x >= p.scavX ? 1 : -1) : p.scavDir;

        // 视线预警锥（潜行可读性的核心视觉锚点）
        const alert = p.scavChase || p.scavSee > 0;
        const coneCol = alert ? PALETTE.crimson : PALETTE.amber;
        const eyeY = by + H * 0.80;
        const coneLen = cam.len(alert ? 155 : 115);
        fgGlow.drawVertices([
            [Vec2(cx + f * 6, eyeY), toColor(coneCol, alert ? 78 : 34)],
            [Vec2(cx + f * coneLen, by + H * 1.05), Color(coneCol.r, coneCol.g, coneCol.b, 0)],
            [Vec2(cx + f * coneLen, by + 4), Color(coneCol.r, coneCol.g, coneCol.b, 0)],
        ]);

        let scavClip = SCAV_WALK_CLIPS[0];
        let frame = 0;
        if (p.scavState === "turn") {
            scavClip = SCAV_TURN_CLIP;
            frame = 2;
        } else if (p.scavState === "chase") {
            const runBeat = Math.floor(this.anim.scavCycle * 4) % 2;
            scavClip = runBeat === 0 ? SCAV_RUN_CLIP : SCAV_WALK_CLIPS[1];
            frame = runBeat === 0 ? 3 : 1;
        } else if (p.scavState === "patrol" || p.scavState === "walk" || p.scavState === "back") {
            const walkBeat = Math.floor(this.anim.scavCycle * 4) % 2;
            scavClip = SCAV_WALK_CLIPS[walkBeat];
            frame = walkBeat;
        }
        const scavBreath = (p.scavState === "stall" || p.scavState === "turn")
            ? (1 + Math.sin(this.animTime * 2.5) * 0.012)
            : 1;
        this.drawGroundedShadow(fgDraw, assets, "shadow_scav", cx, by, by, W * 0.96, 0, 3, 1, false);
        if (assets.tryPlacePath(scavClip, "actor_scav", cx, by, H, H, {
            anchorX: 0.5,
            anchorY: 0,
            preserveAspect: true,
            facing: f,
            scaleYMul: scavBreath,
            layer: 3,
        }) || assets.tryPlace("scavenger", "actor_scav", cx, by, W, H, { facing: f, frame, layer: 3 })) {
            const indY = by + H + 16;
            if (p.scavChase) {
                drawDiamond(fgGlow, cx, indY, 8, 11, toColor(PALETTE.crimson, 240), 1.4, toColor(PALETTE.crimsonCore));
            } else if (p.scavSee > 0) {
                const frac = Math.min(1, p.scavSee / 24);
                fgGlow.drawArc(Vec2(cx, indY), 10, 90, 90 - 360 * frac, 2.2, toColor(PALETTE.crimson, 235));
                fgGlow.drawDot(Vec2(cx, indY), 2.8, toColor(PALETTE.amber));
            } else if (p.scavState === "turn") {
                drawDiamond(fgGlow, cx, indY, 5.5, 7.5, toColor(PALETTE.amber, 220));
            }
            return;
        }

        fgDraw.drawEllipse(Vec2(cx, by + 1), W * 0.62, 4, Color(4, 6, 10, 155));
        const walk = p.scavState === "patrol" || p.scavState === "walk" || p.scavState === "back" || p.scavState === "chase";
        const stride = walk ? Math.sin(this.animTime * (p.scavState === "chase" ? 13 : 7)) * W * 0.36 : 0;

        fgDraw.drawSegment(Vec2(cx - 4, by + H * 0.4), Vec2(cx - stride, by + 2), W * 0.16, Color(32, 30, 28, 255));
        fgDraw.drawSegment(Vec2(cx + 4, by + H * 0.4), Vec2(cx + stride, by + 2), W * 0.16, Color(44, 40, 36, 255));
        // 佝偻大衣剪影
        fgDraw.drawPolygon([
            Vec2(cx - W * 0.45, by + H * 0.25),
            Vec2(cx + W * 0.42, by + H * 0.25),
            Vec2(cx + f * W * 0.22 + W * 0.32, by + H * 0.78),
            Vec2(cx + f * W * 0.22 - W * 0.34, by + H * 0.74),
        ], Color(56, 52, 46, 255), 1.2, Color(128, 118, 100, 180));
        // 头与护目灯
        const headX = cx + f * 5;
        const headY = by + H * 0.88;
        fgDraw.drawCircle(Vec2(headX, headY), W * 0.30, Color(42, 38, 34, 255));
        fgGlow.drawDot(Vec2(headX + f * 6, headY), 3.0, toColor(coneCol, 245));

        // 头顶状态指示（转头 / 发现充能 / 追逐！）
        const indY = by + H + 18;
        if (p.scavChase) {
            drawDiamond(fgGlow, cx, indY, 9, 12, toColor(PALETTE.crimson, 240), 1.5, toColor(PALETTE.crimsonCore));
        } else if (p.scavSee > 0) {
            const frac = Math.min(1, p.scavSee / 24);
            fgGlow.drawArc(Vec2(cx, indY), 11, 90, 90 - 360 * frac, 2.4, toColor(PALETTE.crimson, 235));
            fgGlow.drawDot(Vec2(cx, indY), 3, toColor(PALETTE.amber));
        } else if (p.scavState === "turn" || p.scavState === "walk") {
            drawDiamond(fgGlow, cx, indY, 6, 8, toColor(PALETTE.amber, 220));
        }
    }

    /** 森林猎犬（四足奔袭剪影 + 转耳听觉声波） */
    private drawDog(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
    ): void {
        const cx = cam.sx(p.dogX);
        const by = cam.sy(0);
        const f = p.dogState === "chase" ? (p.player.x >= p.dogX ? 1 : -1) : p.dogDir;
        const W = cam.len(34);
        const H = cam.len(28);

        let dogClip = DOG_WALK_CLIP;
        let frame = 0;
        if (p.dogState === "ear") {
            dogClip = DOG_ALERT_CLIP;
            frame = 1;
        } else if (p.dogState === "sniff") {
            dogClip = DOG_WALK_CLIP;
            frame = 3;
        } else if (p.dogState === "chase") {
            const beat = Math.floor(this.anim.dogCycle * 4) % 2;
            dogClip = DOG_RUN_CLIPS[beat];
            frame = beat === 0 ? 0 : 2;
        } else if (p.dogState === "patrol" || p.dogState === "back") {
            const beat = Math.floor(this.anim.dogCycle * 4) % 2;
            dogClip = beat === 0 ? DOG_WALK_CLIP : DOG_RUN_CLIPS[1];
            frame = beat === 0 ? 0 : 2;
        }
        const dogH = H * 1.12;
        this.drawGroundedShadow(fgDraw, assets, "shadow_dog", cx, by, by, W * 0.92, 0, 3, 1, false);
        if (assets.tryPlacePath(dogClip, "actor_dog", cx, by, dogH, dogH, {
            anchorX: 0.5,
            anchorY: 0,
            preserveAspect: true,
            facing: f,
            layer: 3,
        }) || assets.tryPlace("dog", "actor_dog", cx, by, W, H, { facing: f, frame, layer: 3 })) {
            const alert = p.dogState === "ear" || p.dogState === "chase";
            if (alert) {
                const hx = cx + f * W * 0.34;
                const hy = by + H * 0.86;
                const r = 10 + (this.animTime * 40) % 22;
                fgGlow.drawArc(Vec2(hx, hy + 8), r, 35, 145, 1.6, toColor(PALETTE.crimson, 200 * (1 - r / 34)));
            }
            return;
        }

        fgDraw.drawEllipse(Vec2(cx, by + 1), W * 0.56, 3.5, Color(4, 8, 10, 155));
        const running = p.dogState === "patrol" || p.dogState === "chase" || p.dogState === "back";
        const gallop = running ? Math.sin(this.animTime * (p.dogState === "chase" ? 18 : 10)) * 9 : 0;

        // 四足
        fgDraw.drawSegment(Vec2(cx - f * W * 0.28, by + H * 0.48), Vec2(cx - f * W * 0.36 - gallop, by + 2), 2.8, Color(26, 30, 34, 255));
        fgDraw.drawSegment(Vec2(cx + f * W * 0.28, by + H * 0.48), Vec2(cx + f * W * 0.34 + gallop, by + 2), 2.8, Color(36, 40, 44, 255));
        // 凌厉猎犬躯干与尖耳头颅
        fgDraw.drawPolygon([
            Vec2(cx - W * 0.42, by + H * 0.36),
            Vec2(cx + W * 0.38, by + H * 0.42),
            Vec2(cx + W * 0.34, by + H * 0.78),
            Vec2(cx - W * 0.38, by + H * 0.72),
        ], Color(38, 42, 48, 255), 1.2, Color(102, 118, 126, 175));
        const hx = cx + f * W * 0.42;
        const hy = by + H * 0.84;
        fgDraw.drawPolygon([
            Vec2(hx - f * 8, hy - 6),
            Vec2(hx + f * 12, hy - 2),
            Vec2(hx + f * 4, hy + 8),
            Vec2(hx - f * 6, hy + 14), // 尖耳
        ], Color(44, 48, 54, 255));

        const alert = p.dogState === "ear" || p.dogState === "chase";
        const eyeCol = alert ? PALETTE.crimson : PALETTE.amber;
        fgGlow.drawDot(Vec2(hx + f * 4, hy + 2), 2.8, toColor(eyeCol, 250));
        fillRadialGlow(fgGlow, hx + f * 4, hy + 2, 16, 16, toColor(eyeCol, alert ? 135 : 70), Color(eyeCol.r, eyeCol.g, eyeCol.b, 0), 12);

        if (alert) {
            const r = 12 + (this.animTime * 42) % 24;
            fgGlow.drawArc(Vec2(hx, hy + 12), r, 35, 145, 1.8, toColor(PALETTE.crimson, 210 * (1 - r / 38)));
        }
    }
}
