/** 角色像素帧随玩法姿态切换，脚底与当前相机共用世界坐标。 */

import { Color, DrawNode, Rect, Vec2 } from "Dora";
import { Actor, Enemy, Play, Trace } from "Script/watch/play";
import { FEAR_MAX } from "Script/watch/escort";
import { ACTOR_DEPTH_HALF, DEPTH_Y_SCALE, overlapsDepth } from "Script/watch/depth";
import { depthOrder } from "Script/watch/fe/occlusion";
import { CameraDirector } from "Script/watch/fe/camera";
import { AssetSlotHost, AssetSlotKey } from "Script/watch/fe/assets";
import { PALETTE, drawDiamond, fillRadialGlow, toColor } from "Script/watch/fe/theme";

interface Afterimage {
    x: number;
    y: number;
    depth: number;
    h: number;
    facing: number;
    life: number;
    maxLife: number;
    isRoll: boolean;
}

export class ActorsRenderer {
    private ghosts: Afterimage[] = [];
    private ghostCooldown = 0;
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
        this.ghosts = [];
        this.ghostCooldown = 0;
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

    /** 推进残影与步态时间 */
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
        // 周戍翻滚期间高频采样贴地扬尘步烟
        if (!p.childMode && p.player.rollT > 0) {
            this.ghostCooldown -= dt;
            if (this.ghostCooldown <= 0) {
                this.ghosts.push({
                    x: p.player.x,
                    y: p.player.y,
                    depth: p.player.depth,
                    h: p.player.h,
                    facing: p.player.facing,
                    life: 0.28,
                    maxLife: 0.28,
                    isRoll: true,
                });
                this.ghostCooldown = 0.036;
            }
        } else {
            this.ghostCooldown = 0;
        }

        // 更新并回收过期残影
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
    }

    drawAll(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        assets: AssetSlotHost,
        p: Play,
        cam: CameraDirector,
        suppressPartner: boolean = false,
    ): void {
        // 1. 翻滚冰青残影（最底层）
        this.drawAfterimages(fgGlow, cam);

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

    /** M2（MING-06 清理）：周戍翻滚改为明代写实扬尘步烟，将人物残影视觉专属留给 fe-06 时间穿梭器彩蛋 */
    private drawAfterimages(fgGlow: DrawNode.Type, cam: CameraDirector): void {
        let i = 0;
        for (i = 0; i < this.ghosts.length; i++) {
            const g = this.ghosts[i];
            const k = Math.max(0, Math.min(1, g.life / g.maxLife));
            const spread = 1 - k;
            const cx = cam.sx(g.x);
            const by = cam.sy(g.y, g.depth);
            const f = g.facing;
            const rBase = cam.len(6 + spread * 9);
            // 贴地翻滚扬起的暖灰尘烟（非冰青科幻残影）
            fgGlow.drawCircle(
                Vec2(cx - f * cam.len(6 + spread * 10), by + cam.len(4 + spread * 5)),
                rBase,
                Color(156, 144, 124, Math.round(78 * k)),
            );
            fgGlow.drawCircle(
                Vec2(cx - f * cam.len(14 + spread * 14), by + cam.len(8 + spread * 8)),
                rBase * 0.72,
                Color(186, 174, 152, Math.round(54 * k)),
            );
        }
    }

    /** 计算角色脚下最近的支撑面高度，滞空阴影落在脚下平台而非穿底掉回 y=0。 */
    private supportGroundY(p: Play, a: Actor): number {
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
        const shadowY = !a.onGround ? cam.sy(this.supportGroundY(p, a), a.depth) : by;
        const H = cam.len(a.h);
        const W = cam.len(a.w);
        const f = a.facing;
        const speed = Math.max(Math.abs(a.vx), Math.abs(a.depthSpeed));

        let slot: AssetSlotKey = "soldier_idle";
        let height = H;
        let frame = 0;
        let facing = f;
        const step = Math.floor(this.animTime * 10);
        if (isControlled && p.ticks < this.hitUntil) {
            slot = "soldier_hit";
        } else if (a.rollT > 0) {
            slot = "soldier_roll";
            height *= 0.59;
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
        } else if (speed > 8) {
            slot = "soldier_run";
            frame = step;
        }
        if (assets.tryPlace(slot, "actor_soldier", cx, by, W, height, {
            facing, frame, layer: depthEnabled ? depthOrder(a.depth, 4) : 4,
        })) {
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

        // 极简明代守卒无贴图安全兜底（仅在 sprites.clip 不可用时触发，肃清旧 ICEY 霓虹兜底）
        const bodyH = rolling ? H * 0.62 : (crouching ? H * 0.82 : H);
        const lean = rolling ? f * H * 0.14 : (p.gripping ? f * H * 0.10 : (walking ? f * 6 : f * 2));
        const sw = H * 0.115;

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
        const shadowY = !a.onGround ? cam.sy(this.supportGroundY(p, a), a.depth) : by;
        const H = cam.len(a.h);
        const W = cam.len(a.w);
        const f = a.facing;
        const speed = Math.max(Math.abs(a.vx), Math.abs(a.depthSpeed));

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
        } else if (speed > 8) {
            slot = "child_run";
            frame = step;
        }
        const facing = slot === "child_pull" ? (p.room.cart.handleOffset < 0 ? 1 : -1) : f;
        if (assets.tryPlace(slot, "actor_child", cx, by, W, height, {
            facing, frame, layer: depthEnabled ? depthOrder(a.depth, 5) : 5,
        })) {
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

        // 4. 明代女童头部与双丫髻剪影兜底（无发光眼点）
        const headR = fullRef * (a.crouch ? 0.118 : 0.126);
        const headX = x + f * (a.crouch ? 5 : 2);
        const headY = Math.min(by + H - headR - 1, cloakTopY + headR * 0.92);
        fgDraw.drawCircle(Vec2(headX, headY), headR, Color(232, 212, 188, 255));
        fgDraw.drawCircle(Vec2(headX - f * headR * 0.45, headY + headR * 0.72), headR * 0.42, Color(36, 30, 32, 250));
        fgDraw.drawCircle(Vec2(headX + f * headR * 0.15, headY + headR * 0.82), headR * 0.36, Color(36, 30, 32, 250));

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

        // 试射靶（escort3 工台靶位由 EscortWorldRenderer 精绘带声波环青铜鸣锣+草靶；其余关卡用 props_ming.clip|target_dummy）
        if (e.kind === "target") {
            if (p.room.key === "escort3") {
                return;
            }
            const targetLayer = p.room.depth === undefined ? 3 : depthOrder(depth, 3);
            fgDraw.drawEllipse(Vec2(cx, by + 1), W * 0.56, 3.6, Color(12, 11, 13, 140));
            const angle = !e.alive ? f * 62 : (e.hitT > 0 ? f * 18 : 0);
            const tint = (e.hitT > 0 || !e.alive) ? Color(238, 196, 174, 255) : Color(255, 255, 255, 255);
            if (assets.tryPlacePath("assets/art/props_ming.clip|target_dummy", "actor_target_" + index, cx, by, H * 0.82, H * 0.96, {
                anchorX: 0.5,
                anchorY: 0,
                preserveAspect: true,
                angle,
                color: tint,
                opacity: e.alive ? 1 : 0.76,
                layer: targetLayer,
            })) {
                return;
            }
            const lean = !e.alive ? f * cam.len(16) : (e.hitT > 0 ? f * cam.len(8) : 0);
            const postTopY = by + H * (e.alive ? 0.78 : 0.42);
            fgDraw.drawSegment(Vec2(cx - cam.len(9), by), Vec2(cx + lean * 0.4, postTopY), Math.max(2, cam.len(3.2)), Color(92, 64, 42, 255));
            fgDraw.drawSegment(Vec2(cx + cam.len(9), by), Vec2(cx + lean * 0.4, postTopY), Math.max(2, cam.len(3.2)), Color(76, 52, 34, 255));
            const discX = cx + lean;
            const discY = by + H * (e.alive ? 0.56 : 0.30);
            const discR = Math.max(7, cam.len(13));
            const hitTint = e.hitT > 0 || !e.alive;
            fgDraw.drawCircle(Vec2(discX, discY), discR, hitTint ? Color(214, 152, 116, 245) : Color(196, 174, 134, 250));
            fgDraw.drawRing(Vec2(discX, discY), discR * 0.62, discR * 0.76, Color(0, 0, 0, 0), 1.4, Color(62, 46, 34, 230));
            fgDraw.drawCircle(Vec2(discX, discY), discR * 0.30, toColor(PALETTE.rouge, hitTint ? 255 : 220));
            return;
        }

        const enemyLayer = p.room.depth === undefined ? 3 : depthOrder(depth, 3);
        // Phase 3 三类精英倭寇专属像素精灵（盾手 / 破障斧手 / 朱缨头领），彻底替换几何方块盾与多边形斧粘贴
        if (e.alive && e.hitT <= 0) {
            let extraClip = "";
            let extraAnchorX = 0.5;
            let extraHeight = H * 0.96;
            let extraTint = Color(255, 255, 255, 255);
            if (e.kind === "shield" && (e.shieldHp ?? 0) > 0) {
                extraClip = e.warnT > 0 ? "enemy_shield_aim" : "enemy_shield_idle";
                extraAnchorX = e.warnT > 0 ? 0.45 : 0.50;
                extraHeight = H * 0.94;
                if ((e.shieldHp ?? 2) <= 1) {
                    extraTint = Color(234, 198, 178, 255);
                }
            } else if (e.kind === "breaker") {
                const swing = (e.swingT ?? 0) > 0 || e.warnT > 0;
                extraClip = swing ? "enemy_breaker_aim" : "enemy_breaker_idle";
                extraAnchorX = swing ? 0.52 : 0.38;
                extraHeight = H * (swing ? 0.98 : 0.94);
            } else if (e.kind === "leader") {
                extraClip = e.warnT > 0 ? "enemy_leader_aim" : "enemy_leader_idle";
                extraAnchorX = e.warnT > 0 ? 0.38 : 0.44;
                extraHeight = H * 1.00;
            }
            if (extraClip !== "" && assets.tryPlacePath(
                "assets/art/actors_extra.clip|" + extraClip,
                "actor_enemy_" + index,
                cx,
                by,
                W * 1.8,
                extraHeight,
                {
                    anchorX: extraAnchorX,
                    anchorY: 0,
                    preserveAspect: true,
                    facing: f,
                    color: extraTint,
                    layer: enemyLayer,
                },
            )) {
                fgDraw.drawEllipse(Vec2(cx, by + 1), W * 0.58, 3.8, Color(12, 11, 13, 145));
                if (e.kind === "breaker" && (e.swingT ?? 0) > 0) {
                    fgGlow.drawArc(Vec2(cx + f * cam.len(10), by + H * 0.56), cam.len(18), f > 0 ? -40 : 140, f > 0 ? 50 : 230, 1.8, toColor(PALETTE.rouge, 195));
                }
                if (e.warnT > 0) {
                    this.drawEnemyWarning(fgGlow, e, p, cam, f);
                }
                return;
            }
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
                this.drawEnemyArchetypeGear(fgDraw, fgGlow, e, cx, by, H, f, cam);
                if (e.warnT > 0) {
                    this.drawEnemyWarning(fgGlow, e, p, cam, f);
                }
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
        this.drawEnemyArchetypeGear(fgDraw, fgGlow, e, cx, by, H, f, cam);
        if (e.warnT > 0) {
            this.drawEnemyWarning(fgGlow, e, p, cam, f);
        }
    }

    /** 区分盾手 / 破障手 / 带队者的明初冷兵器轮廓（灰度与实战均一眼可辨） */
    private drawEnemyArchetypeGear(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        e: Enemy,
        cx: number,
        by: number,
        H: number,
        f: number,
        cam: CameraDirector,
    ): void {
        if (e.kind === "shield" && (e.shieldHp ?? 0) > 0) {
            const shX = cx + f * cam.len(13);
            const shW = Math.max(5, cam.len(8));
            const shH = H * 0.72;
            const cracked = (e.shieldHp ?? 2) <= 1;
            fgDraw.drawRect(
                Rect(shX - shW * 0.5, by + H * 0.08, shW, shH),
                cracked ? Color(122, 82, 52, 245) : Color(96, 66, 42, 250),
                1.3,
                Color(168, 174, 180, 230),
            );
            fgDraw.drawCircle(Vec2(shX, by + H * 0.44), Math.max(2.2, cam.len(3.5)), Color(142, 148, 154, 240));
            if (cracked) {
                fgDraw.drawSegment(Vec2(shX - shW * 0.4, by + H * 0.28), Vec2(shX + shW * 0.4, by + H * 0.58), 1.4, Color(24, 18, 16, 235));
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
        const W = cam.len(42);
        const H = cam.len(34);

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
