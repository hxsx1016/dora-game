/**
 * 《向西守望》高帧角色动作状态机与次级物理韵律控制器（Animation State Machine & Juice Polish）：
 *
 * 设计目标：
 * - 严格消费世界时钟 worldDt（暂停自动归零冻结，换弹慢时自动 0.25× 慢放），后端碰撞零侵入；
 * - 为每个角色维护独立状态计时（确保单次动作如开火、受击、跳跃、倒地从第 0 帧完整播放），
 *   并在进入待机瞬间重置 idleTime = 0，保证首帧精准锚定静态回归键名；
 * - 引入动画十二原则克制次级修饰：转向弹性微压、起跳拉伸、落地缓冲压缩、开火后坐回正、受击闪白；
 * - 按真实模拟步相触发脚步着地/急停/起跳/落地事件，供 VfxSystem 同步生成贴地像素尘烟与雨溅。
 */

import { Actor, Enemy, Play } from "Script/watch/play";

export type FootstepKind = "step" | "land" | "brake" | "jump";

export interface FootstepCue {
    x: number;
    y: number;
    depth: number;
    facing: number;
    kind: FootstepKind;
    strength: number;
}

export interface JuiceTransform {
    offsetX: number;
    offsetY: number;
    scaleXMul: number;
    scaleYMul: number;
    angleOffset: number;
    hitFlash: number;
}

export const IDENTITY_JUICE: JuiceTransform = {
    offsetX: 0,
    offsetY: 0,
    scaleXMul: 1,
    scaleYMul: 1,
    angleOffset: 0,
    hitFlash: 0,
};

const TURN_DURATION = 0.085;
const JUMP_DURATION = 0.12;
const LAND_DURATION = 0.14;
const RECOIL_DURATION = 0.17;
const HIT_DURATION = 0.24;

function clamp01(v: number): number {
    return v <= 0 ? 0 : (v >= 1 ? 1 : v);
}

export class ActorMotionState {
    facing = 1;
    turnTimer = 0;
    wasOnGround = true;
    prevVy = 0;
    jumpTimer = 0;
    landTimer = 0;
    landStrength = 1;
    recoilTimer = 0;
    recoilDir = 1;
    hitTimer = 0;
    hitDir = 1;

    idleTime = 0;
    coverTime = 0;
    stateKey = "";
    stateTime = 0;

    lastStrideHalf = -1;
    wasMoving = false;
    crouchCycle = 0;
    pushCycle = 0;
    prevX = 0;
    prevDepth = 0;

    reset(a: Actor): void {
        this.facing = a.facing >= 0 ? 1 : -1;
        this.turnTimer = 0;
        this.wasOnGround = a.onGround;
        this.prevVy = a.vy;
        this.jumpTimer = 0;
        this.landTimer = 0;
        this.landStrength = 1;
        this.recoilTimer = 0;
        this.recoilDir = this.facing;
        this.hitTimer = 0;
        this.hitDir = this.facing;
        this.idleTime = 0;
        this.coverTime = 0;
        this.stateKey = "";
        this.stateTime = 0;
        this.lastStrideHalf = -1;
        this.wasMoving = false;
        this.crouchCycle = 0;
        this.pushCycle = 0;
        this.prevX = a.x;
        this.prevDepth = a.depth;
    }

    triggerRecoil(dir: number): void {
        this.recoilTimer = RECOIL_DURATION;
        this.recoilDir = dir >= 0 ? 1 : -1;
    }

    triggerHit(dir: number): void {
        this.hitTimer = HIT_DURATION;
        this.hitDir = dir >= 0 ? 1 : -1;
    }

    update(
        dt: number,
        a: Actor,
        strideCycle: number,
        strideSpeed: number,
        strideEffort: number,
        isCovering: boolean,
        outCues: FootstepCue[],
    ): void {
        if (dt <= 0) {
            return;
        }
        const f = a.facing >= 0 ? 1 : -1;
        if (f !== this.facing) {
            this.facing = f;
            this.turnTimer = TURN_DURATION;
        }

        const dx = a.x - this.prevX;
        const dd = a.depth - this.prevDepth;
        const stepDist = Math.sqrt(dx * dx + dd * dd);
        this.prevX = a.x;
        this.prevDepth = a.depth;

        if (a.crouch && a.onGround && stepDist > 0.05) {
            this.crouchCycle = (this.crouchCycle + stepDist / Math.max(24, a.h * 1.15)) % 1;
        }
        if (a.onGround && stepDist > 0.05) {
            this.pushCycle = (this.pushCycle + stepDist / Math.max(30, a.h * 0.92)) % 1;
        }

        // 起跳 / 落地边缘检测
        if (this.wasOnGround && !a.onGround) {
            if (a.vy > 30) {
                this.jumpTimer = JUMP_DURATION;
                outCues.push({
                    x: a.x,
                    y: a.y,
                    depth: a.depth,
                    facing: f,
                    kind: "jump",
                    strength: 0.9,
                });
            }
        } else if (!this.wasOnGround && a.onGround) {
            this.landTimer = LAND_DURATION;
            this.landStrength = clamp01(Math.abs(this.prevVy) / 360);
            if (this.landStrength < 0.35) {
                this.landStrength = 0.35;
            }
            outCues.push({
                x: a.x,
                y: a.y,
                depth: a.depth,
                facing: f,
                kind: "land",
                strength: this.landStrength,
            });
        }
        this.wasOnGround = a.onGround;
        this.prevVy = a.vy;

        // 跑步着地相位与急停刹尘检测
        const movingFast = a.alive && a.onGround && !a.crouch && !a.covered && a.rollT <= 0 && strideSpeed > 18;
        if (movingFast && strideEffort > 0.35) {
            const half = strideCycle < 0.5 ? 0 : 1;
            if (this.lastStrideHalf !== -1 && half !== this.lastStrideHalf) {
                outCues.push({
                    x: a.x - f * a.w * 0.18,
                    y: a.y,
                    depth: a.depth,
                    facing: f,
                    kind: "step",
                    strength: clamp01(strideSpeed / 240),
                });
            }
            this.lastStrideHalf = half;
        } else {
            if (this.wasMoving && a.onGround && a.rollT <= 0 && strideSpeed <= 12) {
                outCues.push({
                    x: a.x + f * a.w * 0.22,
                    y: a.y,
                    depth: a.depth,
                    facing: f,
                    kind: "brake",
                    strength: 0.85,
                });
            }
            this.lastStrideHalf = -1;
        }
        this.wasMoving = movingFast && strideEffort > 0.5;

        // 待机与掩体独立累计（一旦运动/离地/翻滚则清零，确保回到待机首帧稳落索引 0）
        if (a.alive && a.onGround && !a.crouch && !isCovering && a.rollT <= 0 && strideSpeed <= 8 && strideEffort <= 0.001) {
            this.idleTime += dt;
        } else {
            this.idleTime = 0;
        }

        if (isCovering && a.alive) {
            this.coverTime += dt;
        } else {
            this.coverTime = 0;
        }

        if (this.turnTimer > 0) {
            this.turnTimer = Math.max(0, this.turnTimer - dt);
        }
        if (this.jumpTimer > 0) {
            this.jumpTimer = Math.max(0, this.jumpTimer - dt);
        }
        if (this.landTimer > 0) {
            this.landTimer = Math.max(0, this.landTimer - dt);
        }
        if (this.recoilTimer > 0) {
            this.recoilTimer = Math.max(0, this.recoilTimer - dt);
        }
        if (this.hitTimer > 0) {
            this.hitTimer = Math.max(0, this.hitTimer - dt);
        }
    }

    /** 进入/维持某个离散状态时刷新该状态的局部播放时间 */
    trackState(key: string, dt: number): number {
        if (this.stateKey !== key) {
            this.stateKey = key;
            this.stateTime = 0;
        } else {
            this.stateTime += dt;
        }
        return this.stateTime;
    }

    /** 采样当前帧的次级物理形变（缩放/位移/微倾/受击闪白） */
    sampleJuice(ppu: number): JuiceTransform {
        let offsetX = 0;
        let offsetY = 0;
        let scaleXMul = 1;
        let scaleYMul = 1;
        let angleOffset = 0;
        let hitFlash = 0;

        if (this.turnTimer > 0) {
            const k = this.turnTimer / TURN_DURATION;
            const s = Math.sin(k * Math.PI * 0.5);
            scaleXMul *= 1 - 0.20 * s;
            scaleYMul *= 1 + 0.04 * s;
        }
        if (this.jumpTimer > 0) {
            const k = this.jumpTimer / JUMP_DURATION;
            const s = Math.sin(k * Math.PI);
            scaleXMul *= 1 - 0.08 * s;
            scaleYMul *= 1 + 0.09 * s;
        }
        if (this.landTimer > 0) {
            const k = this.landTimer / LAND_DURATION;
            const s = Math.sin(k * Math.PI);
            const str = this.landStrength;
            scaleXMul *= 1 + 0.12 * s * str;
            scaleYMul *= 1 - 0.11 * s * str;
        }
        if (this.recoilTimer > 0) {
            const k = this.recoilTimer / RECOIL_DURATION;
            const punch = k * k;
            offsetX -= this.recoilDir * 4.2 * punch * ppu;
            angleOffset -= this.recoilDir * 3.2 * punch;
            scaleXMul *= 1 - 0.04 * punch;
            scaleYMul *= 1 + 0.03 * punch;
        }
        if (this.hitTimer > 0) {
            const k = this.hitTimer / HIT_DURATION;
            hitFlash = k > 0.55 ? 1 : k / 0.55;
            offsetX -= this.hitDir * 3.6 * k * ppu;
            angleOffset -= this.hitDir * 6.5 * Math.sin(k * Math.PI);
        }
        return { offsetX, offsetY, scaleXMul, scaleYMul, angleOffset, hitFlash };
    }
}

export class EnemyAnimState {
    prevX = 0;
    prevDepth = 0;
    speed = 0;
    walkCycle = 0;
    alive = true;
    deathTime = 0;
    warnTime = 0;
    wasWarn = false;
    swingTime = 0;
    wasSwing = false;
    hitTime = 0;
    hitFlash = 0;
    idlePhase = 0;

    constructor(e: Enemy, index: number) {
        this.prevX = e.x;
        this.prevDepth = e.depth ?? 0;
        this.alive = e.alive;
        this.idlePhase = (index * 1.37) % 6.283;
    }

    update(dt: number, e: Enemy): void {
        if (dt <= 0) {
            return;
        }
        const depth = e.depth ?? 0;
        const dx = e.x - this.prevX;
        const dd = depth - this.prevDepth;
        const dist = Math.sqrt(dx * dx + dd * dd);
        this.speed = dist / Math.max(0.001, dt);
        this.prevX = e.x;
        this.prevDepth = depth;

        if (e.alive && this.speed > 6) {
            this.walkCycle = (this.walkCycle + dist / Math.max(34, e.h * 1.1)) % 1;
        }

        if (!e.alive) {
            if (this.alive) {
                this.alive = false;
                this.deathTime = 0;
                this.hitFlash = 1;
            } else {
                this.deathTime += dt;
            }
        } else {
            this.alive = true;
            this.deathTime = 0;
        }

        if (e.warnT > 0) {
            if (!this.wasWarn) {
                this.warnTime = 0;
                this.wasWarn = true;
            } else {
                this.warnTime += dt;
            }
        } else {
            this.wasWarn = false;
            this.warnTime = 0;
        }

        const swinging = (e.swingT ?? 0) > 0;
        if (swinging) {
            if (!this.wasSwing) {
                this.swingTime = 0;
                this.wasSwing = true;
            } else {
                this.swingTime += dt;
            }
        } else {
            this.wasSwing = false;
            this.swingTime = 0;
        }

        if (e.hitT > 0) {
            this.hitTime += dt;
            this.hitFlash = Math.min(1, e.hitT * 2.5);
        } else {
            this.hitTime = 0;
            this.hitFlash = Math.max(0, this.hitFlash - dt * 5.0);
        }
    }
}

export class ActorAnimController {
    readonly player = new ActorMotionState();
    readonly partner = new ActorMotionState();
    enemies: EnemyAnimState[] = [];
    footstepCues: FootstepCue[] = [];
    scavCycle = 0;
    prevScavX = 0;
    dogCycle = 0;
    prevDogX = 0;

    reset(p: Play): void {
        this.player.reset(p.player);
        this.partner.reset(p.partner);
        this.enemies = [];
        for (let i = 0; i < p.enemies.length; i++) {
            this.enemies.push(new EnemyAnimState(p.enemies[i], i));
        }
        this.footstepCues = [];
        this.scavCycle = 0;
        this.prevScavX = p.scavX;
        this.dogCycle = 0;
        this.prevDogX = p.dogX;
    }

    drainFootsteps(): FootstepCue[] {
        const out = this.footstepCues;
        this.footstepCues = [];
        return out;
    }

    updateEnemiesAndNpcs(dt: number, p: Play): void {
        if (dt <= 0) {
            return;
        }
        if (this.enemies.length !== p.enemies.length) {
            this.enemies = [];
            for (let i = 0; i < p.enemies.length; i++) {
                this.enemies.push(new EnemyAnimState(p.enemies[i], i));
            }
        }
        for (let i = 0; i < p.enemies.length; i++) {
            this.enemies[i].update(dt, p.enemies[i]);
        }

        // 村口拾荒者步态相位
        const scavDist = Math.abs(p.scavX - this.prevScavX);
        this.prevScavX = p.scavX;
        if (scavDist > 0.05) {
            const stride = p.scavState === "chase" ? 56 : 44;
            this.scavCycle = (this.scavCycle + scavDist / stride) % 1;
        }

        // 森林猎犬四足奔袭相位
        const dogDist = Math.abs(p.dogX - this.prevDogX);
        this.prevDogX = p.dogX;
        if (dogDist > 0.05) {
            const stride = p.dogState === "chase" ? 48 : 34;
            this.dogCycle = (this.dogCycle + dogDist / stride) % 1;
        }
    }
}
