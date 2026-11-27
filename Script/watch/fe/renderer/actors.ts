/** 角色像素帧随玩法姿态切换，脚底与当前相机共用世界坐标。 */

import { Color, DrawNode, Vec2 } from "Dora";
import { Actor, Enemy, Play, Trace } from "Script/watch/play";
import { FEAR_MAX } from "Script/watch/escort";
import { STEP } from "Script/watch/clock";
import { ACTOR_DEPTH_HALF, overlapsDepth } from "Script/watch/depth";
import { depthOrder } from "Script/watch/fe/occlusion";
import { CameraDirector } from "Script/watch/fe/camera";
import { AssetSlotHost, AssetSlotKey } from "Script/watch/fe/assets";
import { PALETTE, drawDiamond, fillRadialGlow, toColor } from "Script/watch/fe/theme";

interface SlideDust {
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
}

function strideAt(actor: Actor): Stride {
    return { actor, x: actor.x, depth: actor.depth, speed: 0, cycle: 0 };
}

function advanceStride(stride: Stride, steps: number, dt: number): void {
    const a = stride.actor;
    if (steps > 0) {
        const dx = a.x - stride.x;
        const depth = a.depth - stride.depth;
        const speed = Math.sqrt(dx * dx + depth * depth) / (steps * STEP);
        stride.speed = speed <= 380 ? speed : 0;
        stride.x = a.x;
        stride.depth = a.depth;
    }
    if (a.onGround && !a.crouch && !a.covered && a.rollT <= 0 && stride.speed > 8) {
        const strideLength = a.h * (a.w <= 28 ? 1.40 : 1.32);
        stride.cycle = (stride.cycle + stride.speed * dt / strideLength) % 1;
    }
}

const DUST_LIFE = 0.23;

export class ActorsRenderer {
    private slideDust: SlideDust[] = [];
    private dustCooldown = 0;
    private slideDuration = 0;
    private strideTick = 0;
    private playerStride: Stride | undefined;
    private partnerStride: Stride | undefined;
    private animTime = 0;
    private previousHp = 3;
    private previousAxle = 0;
    private cartMoving = false;
    private previousBottle = false;
    private previousTrace: Trace | undefined;
    private hitUntil = -1;
    private throwUntil = -1;
    private shotUntil = -1;

    reset(p: Play): void {
        this.slideDust = [];
        this.dustCooldown = 0;
        this.slideDuration = 0;
        this.strideTick = p.ticks;
        this.playerStride = strideAt(p.player);
        this.partnerStride = strideAt(p.partner);
        this.animTime = 0;
        this.previousHp = p.hp;
        this.previousAxle = p.cartAxle;
        this.cartMoving = false;
        this.previousBottle = p.hasBottle;
        this.previousTrace = p.trace;
        this.hitUntil = -1;
        this.throwUntil = -1;
        this.shotUntil = -1;
    }

    /** 按已经走过的距离更新步态，镜头和重新渲染均不改变跑步节奏。 */
    update(dt: number, p: Play): void {
        this.animTime += dt;
        if (p.hp < this.previousHp || p.gateNeedConfirm) {
            this.hitUntil = p.ticks + 14;
        }
        if (this.previousBottle && !p.hasBottle && p.bottleFly !== undefined) {
            this.throwUntil = p.ticks + 12;
        }
        if (p.trace !== undefined && p.trace !== this.previousTrace) {
            this.shotUntil = p.ticks + 7;
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
        this.updateSlideDust(dt, p, this.playerStride.speed);
    }

    private slidePhase(a: Actor): number {
        return this.slideDuration > 0 ? 1 - a.rollT / this.slideDuration : 0;
    }

    private updateSlideDust(dt: number, p: Play, speed: number): void {
        const a = p.player;
        if (!p.childMode && a.rollT > 0) {
            this.slideDuration = Math.max(this.slideDuration, a.rollT);
            const progress = this.slidePhase(a);
            this.dustCooldown -= dt;
            if (a.onGround && speed > 8 && progress >= 0.16 && progress < 0.77 && this.dustCooldown <= 0) {
                this.slideDust.push({
                    x: a.x + a.facing * a.h * 0.34,
                    y: a.y + a.depth,
                    facing: a.facing,
                    life: DUST_LIFE,
                });
                this.dustCooldown = 0.038;
            }
        } else {
            this.slideDuration = 0;
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
        suppressPartner: boolean = false,
    ): void {
        this.drawSlideDust(fgGlow, cam);

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
        if (p.partner.alive && !suppressPartner) {
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
                this.drawZhouShu(fgDraw, fgGlow, assets, p.player, p, cam, true);
            }
        }
    }

    private drawSlideDust(draw: DrawNode.Type, cam: CameraDirector): void {
        for (const dust of this.slideDust) {
            const alpha = dust.life / DUST_LIFE;
            const spread = 1 - alpha;
            const x = cam.sx(dust.x - dust.facing * spread * 17);
            const y = cam.sy(dust.y + 1.5 + spread * 2);
            draw.drawEllipse(Vec2(x, y), cam.len(5 + spread * 7), cam.len(1.5 + spread * 2),
                Color(166, 147, 124, 170 * alpha));
            draw.drawDot(Vec2(x - dust.facing * cam.len(3), y + cam.len(4)),
                cam.len(1.1), Color(195, 174, 148, 135 * alpha));
        }
    }

    /** 周戍。动作贴图以脚底对齐，缺失时绘制守军轮廓。 */
    private drawZhouShu(
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
        const shadowY = depthEnabled && !a.onGround ? cam.sy(0, a.depth) : by;
        const H = cam.len(a.h);
        const W = cam.len(a.w);
        const f = a.facing;
        const speed = Math.max(Math.abs(a.vx), Math.abs(a.depthSpeed));

        let slot: AssetSlotKey = "soldier_idle";
        let height = H;
        let frame = 0;
        let facing = f;
        const step = Math.floor(this.animTime * 10);
        const gait = isControlled ? this.playerStride : this.partnerStride;
        if (isControlled && p.ticks < this.hitUntil) {
            slot = "soldier_hit";
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
            frame = this.cartMoving ? step : 0;
            facing = p.room.cart.handleOffset < 0 ? 1 : -1;
            height *= 0.91;
        } else if (isControlled && p.escort.state === "calming") {
            slot = "soldier_knock";
            const calm = p.escort.calmTick;
            frame = (calm >= 12 && calm < 18) || (calm >= 36 && calm < 42) ? 1 : 0;
            height *= 0.76;
        } else if (p.phase === "gate-send" && p.room.story?.gate !== undefined &&
            Math.abs(a.x - p.room.story.gate.doorX) <= 60 && speed <= 8) {
            slot = "soldier_hold";
            height *= 1.11;
        } else if (isControlled && p.ticks < this.shotUntil) {
            const running = speed > 8;
            slot = running ? "soldier_fire_move" : "soldier_fire";
            frame = running ? step : 0;
            facing = p.trace !== undefined && p.trace.x1 < p.trace.x0 ? -1 : 1;
        } else if (a.covered || (isControlled && p.coverHug)) {
            slot = "soldier_cover";
            height *= 0.77;
        } else if ((gait?.speed ?? 0) > 8) {
            slot = "soldier_run";
            frame = step;
        }
        const pose = {
            facing, frame, layer: depthEnabled ? depthOrder(a.depth, 4) : 4,
        };
        const running = slot === "soldier_run" && a.onGround && gait !== undefined
            && assets.tryPlaceRun("soldier", "actor_soldier", cx, by, W, height, gait.cycle, pose);
        if (running || assets.tryPlace(slot, "actor_soldier", cx, by, W, height, pose)) {
            fgDraw.drawEllipse(Vec2(cx, shadowY + 1), W * 0.54, 4, Color(12, 11, 13, 145));
            return;
        }

        // 脚底接地阴影
        fgDraw.drawEllipse(Vec2(cx, shadowY + 1), H * 0.24, 4.5, Color(3, 5, 10, 175));

        const walking = speed > 10 && a.onGround;
        const stride = walking ? Math.sin(this.animTime * 12.5) : 0;
        const bob = walking ? Math.abs(Math.cos(this.animTime * 12.5)) * 3.5 : Math.sin(this.animTime * 2.6) * 1.4;
        const calming = !p.childMode && p.escort.state === "calming";
        const rolling = a.rollT > 0;
        const crouching = a.covered || calming || rolling;

        // 艾希风凌厉修长动漫比例：7 头身（headR ≈ H * 0.088，肩宽 ≈ H * 0.22，收腰 V 廓形）
        const bodyH = rolling ? H * 0.62 : (crouching ? H * 0.82 : H);
        const lean = rolling ? f * H * 0.14 : (p.gripping ? f * H * 0.10 : (walking ? f * 6 : f * 2));
        const sw = H * 0.115; // 半肩宽

        // 1. 双节 Articulated 腿部（大腿 + 小腿 + 战靴）
        const hipY = by + bodyH * 0.44 + bob * 0.4;
        const kneeY = by + bodyH * 0.23;
        const stepX = stride * H * 0.15;
        const legDark = Color(14, 21, 34, 255);
        const legFront = Color(26, 38, 58, 255);
        // 后腿
        const bkX = cx - f * 4 - stepX * 0.5;
        const bfX = cx - f * 8 - stepX;
        fgDraw.drawSegment(Vec2(cx - f * 3, hipY), Vec2(bkX, kneeY), H * 0.044, legDark);
        fgDraw.drawSegment(Vec2(bkX, kneeY), Vec2(bfX, by + 3), H * 0.038, legDark);
        // 前腿
        const fkX = cx + f * 6 + stepX * 0.55;
        const ffX = cx + f * 7 + stepX;
        fgDraw.drawSegment(Vec2(cx + f * 3, hipY), Vec2(fkX, kneeY), H * 0.048, legFront);
        fgDraw.drawSegment(Vec2(fkX, kneeY), Vec2(ffX, by + 3), H * 0.042, legFront);
        // 裹腿与布靴。
        fgDraw.drawSegment(Vec2(ffX - f * 2, by + 3), Vec2(ffX + f * 9, by + 3), 3.4, Color(42, 60, 86, 255));

        // 2. 飘动的袄摆。
        const shY = by + bodyH * 0.80 + bob;
        const coatDrag = -f * (walking ? 24 : (rolling ? 34 : 14)) + Math.sin(this.animTime * 4.4) * 4;
        fgDraw.drawPolygon([
            Vec2(cx - f * sw * 0.75 + lean * 0.5, shY - 6),
            Vec2(cx + f * sw * 0.35 + lean * 0.5, hipY + 4),
            Vec2(cx - f * sw * 0.25 + coatDrag * 0.45, by + bodyH * 0.16),
            Vec2(cx - f * sw * 1.15 + coatDrag, by + bodyH * 0.22),
        ], Color(16, 26, 42, 248), 1.2, Color(64, 118, 164, 195));

        // 3. 青布短袄、斜襟和护肩。
        fgDraw.drawPolygon([
            Vec2(cx - sw * 0.62 + lean * 0.45, hipY),
            Vec2(cx + sw * 0.62 + lean * 0.45, hipY),
            Vec2(cx + sw * 1.05 + lean, shY),
            Vec2(cx - sw * 0.98 + lean, shY),
        ], Color(24, 38, 60, 255), 1.3, toColor(PALETTE.rimSilver, 190));
        // 斜襟。
        fgDraw.drawSegment(
            Vec2(cx - sw * 0.7 + lean, shY - 2),
            Vec2(cx + sw * 0.5 + lean * 0.5, hipY + 6),
            2.4,
            Color(173, 155, 125, 225),
        );
        fgDraw.drawPolygon([
            Vec2(cx - sw * 1.18 + lean, shY - 6),
            Vec2(cx + sw * 1.12 + lean, shY - 3),
            Vec2(cx + sw * 0.90 + lean, shY + 5),
            Vec2(cx - sw * 0.95 + lean, shY + 4),
        ], Color(99, 105, 103, 248));

        // 4. 铁盔与盔顶红缨。
        const headR = H * 0.088;
        const headX = cx + lean + f * 3;
        const headY = shY + headR * 1.35;
        fgDraw.drawCircle(Vec2(headX, headY - headR * 0.12), headR * 0.86, Color(181, 139, 106, 255));
        fgDraw.drawEllipse(Vec2(headX, headY + headR * 0.5), headR * 1.12, headR * 0.72, Color(66, 73, 76, 255));
        fgDraw.drawSegment(Vec2(headX - headR, headY + 1), Vec2(headX + headR, headY + 1),
            1.6, Color(97, 103, 101, 255));
        fgDraw.drawSegment(Vec2(headX, headY + headR), Vec2(headX - f * headR * 0.38, headY + headR * 1.48),
            1.6, Color(177, 78, 51, 255));

        // 5. 木托铁管火铳。
        if (isControlled && !calming && !rolling && !p.gripping) {
            const gunPivotX = cx + lean + f * sw * 0.35;
            const gunPivotY = shY - bodyH * 0.10;
            let aimDx = f;
            let aimDy = 0;
            if (p.aimX > 0 || p.aimY > 0) {
                aimDx = p.aimX - gunPivotX;
                aimDy = p.aimY - gunPivotY;
                const dLen = Math.sqrt(aimDx * aimDx + aimDy * aimDy);
                if (dLen > 4) {
                    aimDx /= dLen;
                    aimDy /= dLen;
                }
            }
            const barrelLen = H * 0.34;
            const tipX = gunPivotX + aimDx * barrelLen;
            const tipY = gunPivotY + aimDy * barrelLen;
            const stockX = gunPivotX - aimDx * (H * 0.08);
            const stockY = gunPivotY - aimDy * (H * 0.08);
            // 手臂
            fgDraw.drawSegment(Vec2(cx + lean, shY - 5), Vec2(gunPivotX + aimDx * 14, gunPivotY + aimDy * 14 - 4), 3.6, Color(26, 40, 62, 255));
            fgDraw.drawSegment(Vec2(stockX, stockY), Vec2(gunPivotX + aimDx * barrelLen * 0.62, gunPivotY + aimDy * barrelLen * 0.62), 3.8, Color(105, 71, 50, 255));
            fgDraw.drawSegment(Vec2(gunPivotX, gunPivotY), Vec2(tipX, tipY), 1.8, Color(145, 140, 128, 245));
        } else if (calming) {
            fgDraw.drawSegment(Vec2(cx + lean, shY - 6), Vec2(cx + f * sw * 2.1, shY - 14), 3.0, Color(196, 222, 240, 235));
            fgGlow.drawDot(Vec2(cx + f * sw * 2.15, shY - 14), 3.6, toColor(PALETTE.amber, 225));
        }

    }

    /** 小满（孩子线主角 / 护送同伴）：优雅尖兜帽琥珀斗篷 + 飘带围巾 + 微光指南针 */
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
        const shadowY = depthEnabled && !a.onGround ? cam.sy(0, a.depth) : by;
        const H = cam.len(a.h);
        const W = cam.len(a.w);
        const f = a.facing;
        const speed = Math.max(Math.abs(a.vx), Math.abs(a.depthSpeed));
        const gait = isControlled ? this.playerStride : this.partnerStride;

        const afraid = !isControlled && p.escort.fear > 0;
        let slot: AssetSlotKey = "child_idle";
        let height = H;
        let frame = 0;
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
        } else if (isControlled && p.hasBottle && p.aimHold > 0) {
            slot = "child_aim";
        } else if (isControlled && p.gripping) {
            slot = "child_pull";
            frame = this.cartMoving ? step : 0;
        } else if (afraid && p.escort.state === "frozen") {
            slot = "child_fear";
            height *= 0.74;
        } else if (!isControlled && nearCover &&
            (p.room.key === "street" || p.room.key === "checkpoint") && speed < 8) {
            slot = "child_peek";
            height *= 0.83;
        } else if (a.crouch) {
            slot = "child_crouch";
            frame = speed > 8 ? step : 0;
        } else if ((gait?.speed ?? 0) > 8) {
            slot = "child_run";
            frame = step;
        }
        const facing = slot === "child_pull" ? (p.room.cart.handleOffset < 0 ? 1 : -1) : f;
        const pose = {
            facing, frame, layer: depthEnabled ? depthOrder(a.depth, 5) : 5,
        };
        const running = slot === "child_run" && a.onGround && gait !== undefined
            && assets.tryPlaceRun("child", "actor_child", cx, by, W, height, gait.cycle, pose);
        if (running || assets.tryPlace(slot, "actor_child", cx, by, W, height, pose)) {
            fgDraw.drawEllipse(Vec2(cx, shadowY + 1), W * 0.48, 3, Color(12, 11, 13, 125));
            if (afraid) {
                this.drawFear(fgGlow, p, cx, by + height + 14);
            }
            return;
        }

        const jitter = (!isControlled && p.escort.state === "frozen") ? Math.sin(this.animTime * 42) * 2.2 : 0;
        const x = cx + jitter;

        const fullRef = a.crouch ? H * 1.35 : H;
        const cw = fullRef * 0.16;

        // 接地阴影
        fgDraw.drawEllipse(Vec2(x, shadowY + 1), cw * 1.15, 3.6, Color(4, 6, 10, 155));

        const walking = speed > 6 && a.onGround;
        const stride = walking ? Math.sin(this.animTime * 11) : 0;
        const bob = walking ? Math.abs(Math.cos(this.animTime * 11)) * 2.8 : Math.sin(this.animTime * 2.8) * 1.1;

        // 1. 腿部
        const hipY = by + H * 0.30;
        const legSwing = stride * cw * 0.85;
        fgDraw.drawSegment(Vec2(x - 2, hipY), Vec2(x - legSwing, by + 2), Math.max(2.6, cw * 0.22), Color(34, 30, 38, 255));
        fgDraw.drawSegment(Vec2(x + 2, hipY), Vec2(x + legSwing, by + 2), Math.max(2.8, cw * 0.24), Color(52, 46, 56, 255));

        // 2. 层次感暖琥珀斗篷（外层亮面 + 内褶阴影 + 底边米白花边）
        const cloakTopY = by + H * (a.crouch ? 0.68 : 0.74) + bob;
        const cloakBotY = by + H * 0.20;
        const cloakDrag = -f * (walking ? 14 : 6) + Math.sin(this.animTime * 3.8) * 2.8;
        fgDraw.drawPolygon([
            Vec2(x - cw * 1.05 + cloakDrag * 0.45, cloakBotY),
            Vec2(x + cw * 0.92, cloakBotY),
            Vec2(x + cw * 0.62, cloakTopY),
            Vec2(x - cw * 0.68, cloakTopY),
        ], Color(214, 166, 94, 255), 1.3, Color(252, 232, 192, 225));
        fgDraw.drawPolygon([
            Vec2(x - cw * 0.92 + cloakDrag * 0.38, cloakBotY + 2),
            Vec2(x - f * cw * 0.12, cloakBotY + 2),
            Vec2(x - f * cw * 0.18, cloakTopY - 3),
            Vec2(x - cw * 0.60, cloakTopY - 2),
        ], Color(148, 108, 56, 215));
        fgDraw.drawSegment(Vec2(x - cw * 0.98 + cloakDrag * 0.42, cloakBotY + 3), Vec2(x + cw * 0.88, cloakBotY + 3), 1.8, toColor(PALETTE.amberCore, 200));

        // 3. 双节飘动围巾丝带
        const scarfY = cloakTopY - 2;
        const smidX = x - f * cw * 0.95 + cloakDrag * 0.55;
        const smidY = scarfY - 6 + Math.sin(this.animTime * 4.5) * 2.5;
        const sendX = x - f * cw * 1.65 + cloakDrag;
        const sendY = scarfY - 12 + Math.cos(this.animTime * 4.8) * 3.5;
        fgDraw.drawQuadraticBezier(Vec2(x - f * cw * 0.3, scarfY), Vec2(smidX, smidY), Vec2(sendX, sendY), 2.8, toColor(PALETTE.amberCore, 235));

        // 4. 柔和儿童比例头部 + 尖角兜帽轮廓
        const headR = fullRef * (a.crouch ? 0.118 : 0.126);
        const headX = x + f * (a.crouch ? 5 : 2);
        const headY = Math.min(by + H - headR - 1, cloakTopY + headR * 0.92);
        fgDraw.drawCircle(Vec2(headX, headY), headR, Color(240, 222, 198, 255));
        // 尖角暖褐兜帽包裹头后侧，既可爱又极契合废土旅人剪影
        fgDraw.drawPolygon([
            Vec2(headX - f * headR * 1.28, headY - headR * 0.72),
            Vec2(headX - f * headR * 1.48, headY + headR * 0.35),
            Vec2(headX - f * headR * 0.25, headY + headR * 1.15),
            Vec2(headX + f * headR * 0.68, headY + headR * 0.82),
            Vec2(headX - f * headR * 0.18, headY + headR * 0.15),
            Vec2(headX - f * headR * 0.35, headY - headR * 0.78),
        ], Color(156, 114, 62, 248), 1.1, Color(244, 214, 162, 200));
        // 明眸光点
        fgGlow.drawDot(Vec2(headX + f * headR * 0.45, headY + 1), 2.2, toColor(PALETTE.amberCore));

        // 5. 指南针微光
        const hasCompass = isControlled || p.room.key !== "prologue" || p.phase !== "prologue-wait";
        if (hasCompass) {
            const compX = x + f * cw * 0.65;
            const compY = by + H * 0.48;
            const glowPulse = 0.78 + 0.22 * Math.sin(this.animTime * 3.2);
            fgGlow.drawDot(Vec2(compX, compY), 2.6, toColor(PALETTE.amberCore, 250));
            fillRadialGlow(fgGlow, compX, compY, 26 * glowPulse, 26 * glowPulse, Color(248, 206, 120, 78 * glowPulse), Color(248, 180, 72, 0), 14);
        }

        if (afraid) {
            this.drawFear(fgGlow, p, x, by + H + 16);
        }

        // 7. 孩子线潜行脚步微环
        if (isControlled && walking && !a.crouch && speed > 100) {
            const r = 10 + (this.animTime * 32) % 24;
            fgGlow.drawRing(Vec2(x, by + 3), r, r + 1.5, Color(0, 0, 0, 0), 1.1, toColor(PALETTE.amber, 95 * (1 - r / 36)));
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
        const by = cam.sy(e.y, depth);
        const H = cam.len(e.h);
        const W = cam.len(e.w);
        const f = p.player.x >= e.x ? 1 : -1;

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
            facing: f, opacity: e.alive ? 1 : 0.78, layer: p.room.depth === undefined ? 3 : depthOrder(depth, 3),
        })) {
            if (e.alive && e.warnT > 0) {
                this.drawEnemyWarning(fgGlow, e, p, cam, f);
            }
            return;
        }

        if (!e.alive) {
            const flash = e.hitT > 0 ? Math.min(1, e.hitT / 0.4) : 0;
            fgDraw.drawPolygon([
                Vec2(cx - H * 0.30, by),
                Vec2(cx + H * 0.28, by),
                Vec2(cx + H * 0.20, by + H * 0.14),
                Vec2(cx - H * 0.24, by + H * 0.11),
            ], flash > 0.2 ? Color(220, 120, 130, 220) : Color(28, 22, 34, 215));
            if (flash > 0) {
                fillRadialGlow(fgGlow, cx, by + 12, 34 * flash, 18 * flash, toColor(PALETTE.crimson, 180 * flash), Color(255, 48, 82, 0), 12);
            }
            return;
        }

        const sw = H * 0.112;
        fgDraw.drawEllipse(Vec2(cx, by + 1), sw * 1.9, 4, Color(4, 6, 10, 165));

        // 布衣与蓑笠。
        const hipY = by + H * 0.44;
        const kneeY = by + H * 0.23;
        const shY = by + H * 0.79;
        fgDraw.drawSegment(Vec2(cx - 5, hipY), Vec2(cx - 7, kneeY), H * 0.044, Color(20, 16, 26, 255));
        fgDraw.drawSegment(Vec2(cx - 7, kneeY), Vec2(cx - 8, by + 2), H * 0.038, Color(20, 16, 26, 255));
        fgDraw.drawSegment(Vec2(cx + 5, hipY), Vec2(cx + 7, kneeY), H * 0.046, Color(28, 22, 36, 255));
        fgDraw.drawSegment(Vec2(cx + 7, kneeY), Vec2(cx + 8, by + 2), H * 0.040, Color(28, 22, 36, 255));

        fgDraw.drawPolygon([
            Vec2(cx - sw * 0.68, hipY),
            Vec2(cx + sw * 0.68, hipY),
            Vec2(cx + sw * 1.12, shY),
            Vec2(cx - sw * 1.12, shY),
        ], Color(111, 68, 55, 255), 1.3, Color(143, 101, 66, 220));
        fgDraw.drawPolygon([
            Vec2(cx - sw * 1.26, shY - 6),
            Vec2(cx + sw * 1.26, shY - 6),
            Vec2(cx + sw * 0.96, shY + 5),
            Vec2(cx - sw * 0.96, shY + 5),
        ], Color(98, 82, 62, 255));

        const headR = H * 0.086;
        const headY = shY + headR * 1.32;
        fgDraw.drawCircle(Vec2(cx, headY), headR * 0.82, Color(187, 142, 103, 255));
        fgDraw.drawPolygon([
            Vec2(cx - headR * 1.65, headY + headR * 0.22),
            Vec2(cx + headR * 1.65, headY + headR * 0.22),
            Vec2(cx - f * headR * 0.18, headY + headR * 1.22),
        ], Color(136, 105, 65, 255), 1.1, Color(177, 145, 91, 220));

        const gunX = cx + f * H * 0.34;
        const gunY = by + H * 0.69;
        fgDraw.drawSegment(Vec2(cx - f * 6, gunY - 2), Vec2(gunX, gunY), 2.8, Color(118, 87, 61, 255));
        if (e.warnT > 0) {
            this.drawEnemyWarning(fgGlow, e, p, cam, f);
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

        let frame = 0;
        if (p.scavState === "turn") {
            frame = 2;
        } else if (p.scavState === "chase") {
            frame = Math.floor(this.animTime * 12) % 2 === 0 ? 3 : 1;
        } else if (p.scavState === "patrol" || p.scavState === "walk" || p.scavState === "back") {
            frame = Math.floor(this.animTime * 8) % 2;
        }
        if (assets.tryPlace("scavenger", "actor_scav", cx, by, W, H, { facing: f, frame, layer: 3 })) {
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

        let frame = 0;
        if (p.dogState === "ear") {
            frame = 1;
        } else if (p.dogState === "sniff") {
            frame = 3;
        } else if (p.dogState === "patrol" || p.dogState === "chase" || p.dogState === "back") {
            frame = Math.floor(this.animTime * (p.dogState === "chase" ? 14 : 8)) % 2 === 0 ? 0 : 2;
        }
        if (assets.tryPlace("dog", "actor_dog", cx, by, W, H, { facing: f, frame, layer: 3 })) {
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
