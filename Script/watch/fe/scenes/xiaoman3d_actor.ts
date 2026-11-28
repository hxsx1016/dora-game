/**
 * 《向西守望》小满 3D 纯体素角色控制器（xiaoman3d_actor.ts）。
 *
 * 职责：
 * - 加载纯正交像素风体素 3D 角色 assets/xiaoman3d/xiaoman.glb（13 骨骼节点 + 13 套动画 + 六面立体着色）；
 * - 根据 3D 四向纵深速度 (vx, -depthSpeed) 及剧情交互上下文（拉车/瞄准/投瓶/叩门/交物）平滑转向，
 *   自然呈现正/背/左/右四面与斜向视角；
 * - 管理 13 套内嵌动画状态机、暂停同步与右手持瓶挂点 hand_R_socket；
 * - 为亮色角色挂载紧凑暖调近身补光，确保小满在暗黑写实场景与桌底/拱洞深影中始终明快清晰。
 */

import { Color3, Model3D, Node3D, PointLight3D, Vec3 } from "Dora";
import { Play } from "Script/watch/play";

const XIAOMAN_MODEL_PATH = "assets/xiaoman3d/xiaoman.glb";
const BOTTLE_MODEL_PATH = "assets/xiaoman3d/bottle.glb";
const TWIG_OFFSETS: readonly number[] = [235, 455, 865, 1115];

/** 朝向符号（glTF +Z 正面，绕 +Y 逆时针旋转 +90° 朝 +X 右侧）。 */
const YAW_SIGN = 1;

export interface Xiaoman3DActorDebug {
    loaded: boolean;
    visible: boolean;
    yawDeg: number;
    targetYawDeg: number;
    animName: string;
    animCount: number;
    hasHandSocket: boolean;
    bottleInHand: boolean;
    worldX: number;
    worldY: number;
    worldZ: number;
}

function mountModel(parent: Node3D.Type, path: string): Model3D.Type {
    const m = Model3D(path);
    if (m.parent !== undefined) {
        m.removeFromParent(false);
    }
    parent.addChild(m);
    return m;
}

function wrapAngleDeg(deg: number): number {
    let a = deg % 360;
    if (a > 180) {
        a -= 360;
    } else if (a < -180) {
        a += 360;
    }
    return a;
}

function shortestDeltaDeg(fromDeg: number, toDeg: number): number {
    return wrapAngleDeg(toDeg - fromDeg);
}

export class Xiaoman3DActor {
    private pivot = Node3D();
    private model: Model3D.Type | undefined;
    private heldBottle: Model3D.Type | undefined;
    private personalLight = PointLight3D();
    private hasSocket = false;

    private yawDeg = 58;
    private targetYawDeg = 58;
    private currentAnim = "";
    private animLoop = true;
    private lastRoomKey = "";

    private throwTimer = 0;
    private listenTimer = 0;
    private prevBottleFly = false;
    private prevDogState = "";
    private prevCartAxle = 0;
    private lastTwigIdx = -1;

    constructor(root: Node3D.Type) {
        root.addChild(this.pivot);
        this.pivot.visible = false;

        // 紧凑暖调近身补光：只提亮小满自身与脚边极近区域，不破坏暗黑写实大场景压迫感
        this.personalLight.color = Color3(255, 232, 196);
        this.personalLight.intensity = 0.92;
        this.personalLight.range = 1.25;
        this.personalLight.position = Vec3(0, 0.42, 0.36);
        this.pivot.addChild(this.personalLight);
    }

    private ensureLoaded(): void {
        if (this.model !== undefined) {
            return;
        }
        const m = mountModel(this.pivot, XIAOMAN_MODEL_PATH);
        this.model = m;
        this.hasSocket = m.hasNode("hand_R_socket");

        if (this.hasSocket) {
            const bottle = Model3D(BOTTLE_MODEL_PATH);
            if (bottle.parent !== undefined) {
                bottle.removeFromParent(false);
            }
            bottle.position = Vec3(0.0, -0.02, 0.025);
            bottle.scale = Vec3(0.92, 0.92, 0.92);
            bottle.visible = false;
            m.attachToNode("hand_R_socket", bottle);
            this.heldBottle = bottle;
        }
        this.playAnim("idle", true, 1.0);
    }

    hide(): void {
        this.pivot.visible = false;
        if (this.model !== undefined && !this.model.paused) {
            this.model.pause();
        }
    }

    update(p: Play, dt: number): void {
        this.ensureLoaded();
        const a = p.player;
        if (!a.alive) {
            this.pivot.visible = false;
            return;
        }
        this.pivot.visible = true;

        // 切房重置朝向与一次性动作计时
        if (this.lastRoomKey !== p.room.key) {
            this.lastRoomKey = p.room.key;
            this.throwTimer = 0;
            this.listenTimer = 0;
            this.prevBottleFly = p.bottleFly !== undefined;
            this.prevDogState = p.dogState;
            this.prevCartAxle = p.cartAxle;
            this.lastTwigIdx = -1;
            // 默认 3/4 朝右偏镜头视角，入场即见正侧脸、红袄与斜挎包
            this.yawDeg = a.facing >= 0 ? 58 : -58;
            this.targetYawDeg = this.yawDeg;
        }

        const paused = p.paused || dt <= 0;
        const safeDt = paused ? 0 : Math.min(0.05, dt);

        if (this.model !== undefined) {
            if (paused) {
                if (!this.model.paused) {
                    this.model.pause();
                }
            } else if (this.model.paused) {
                this.model.resume();
            }
        }

        // 触发投瓶与林中侧耳听声状态
        const flying = p.bottleFly !== undefined;
        if (flying && !this.prevBottleFly) {
            this.throwTimer = 0.44;
        }
        this.prevBottleFly = flying;

        if (!paused) {
            if (this.throwTimer > 0) {
                this.throwTimer = Math.max(0, this.throwTimer - safeDt);
            }
            if (this.listenTimer > 0) {
                this.listenTimer = Math.max(0, this.listenTimer - safeDt);
            }
        }

        const horizSpeed = Math.sqrt(a.vx * a.vx + a.depthSpeed * a.depthSpeed);
        if (p.room.key === "forest") {
            if (p.dogState === "ear" && this.prevDogState !== "ear") {
                this.listenTimer = 0.72;
            }
            let curTwig = -1;
            if (!a.crouch && a.y <= 8 && horizSpeed > 12) {
                let i = 0;
                for (i = 0; i < TWIG_OFFSETS.length; i++) {
                    if (Math.abs(a.x - (p.ox + TWIG_OFFSETS[i])) <= 18) {
                        curTwig = i;
                        break;
                    }
                }
            }
            if (curTwig >= 0 && curTwig !== this.lastTwigIdx) {
                this.listenTimer = 0.65;
            }
            this.lastTwigIdx = curTwig;
        }
        this.prevDogState = p.dogState;

        // 1. 计算目标 3D 朝向（支持前后左右四向及 360° 任意斜向）
        this.targetYawDeg = this.computeTargetYaw(p, horizSpeed);
        if (!paused) {
            const diff = shortestDeltaDeg(this.yawDeg, this.targetYawDeg);
            const turnRate = Math.min(1, safeDt * 13.5);
            this.yawDeg = wrapAngleDeg(this.yawDeg + diff * turnRate);
        }

        // 2. 更新世界位置与朝向（1 glTF unit = 100 game units, gltf_z = -depth/100）
        this.pivot.position = Vec3(a.x / 100, a.y / 100, -a.depth / 100);
        if (this.model !== undefined) {
            this.model.angles = Vec3(0, this.yawDeg * YAW_SIGN, 0);
        }

        // 3. 桌底/暗拱内略微增强小满近身补光，保持暗处亮色主角高可读性
        const inShadowCover = a.crouch
            || (p.room.key === "village" && a.x >= p.ox + 290 && a.x <= p.ox + 430)
            || (p.room.key === "outside" && a.y < 60 && a.x >= p.ox + 250 && a.x <= p.ox + 400);
        this.personalLight.intensity = inShadowCover ? 1.18 : 0.90;
        this.personalLight.position = Vec3(0, a.crouch ? 0.28 : 0.42, 0.34);

        // 4. 更新右手持瓶挂点可见性
        if (this.heldBottle !== undefined) {
            this.heldBottle.visible = p.room.key === "village" && p.hasBottle && !flying;
        }

        // 5. 驱动 13 套体素骨骼动画
        const cartDelta = Math.abs(p.cartAxle - this.prevCartAxle);
        if (!paused) {
            this.prevCartAxle = p.cartAxle;
        }
        this.selectAnimation(p, horizSpeed, cartDelta);
    }

    private computeTargetYaw(p: Play, horizSpeed: number): number {
        const a = p.player;
        // 剧情与特殊交互朝向优先
        if (p.room.key === "tower") {
            if (p.phase === "tower-knock" || p.phase === "tower-open") {
                return 162; // 3/4 背面朝北塔木门抬手叩门
            }
            if (p.deskHold > 0 || p.phase === "tower-given") {
                return 118; // 面向值夜桌与守卫递出针套和纸条
            }
        }
        if (p.gripping) {
            const axleX = p.cartAxle;
            return axleX <= a.x ? -76 : 76; // 面向车身略偏镜头，双手握车柄清晰可读
        }
        if (p.hasBottle && p.aimHold > 0 && p.bottleAimX >= 0) {
            const dx = p.bottleAimX - a.x;
            const dz = a.depth; // 目标位于 z=0，小满位于 z=-depth -> targetZ - curZ = +depth
            return wrapAngleDeg(Math.atan2(dx, dz) * (180 / Math.PI));
        }
        if (this.throwTimer > 0 && p.bottleFly !== undefined) {
            const dx = p.bottleFly.vx;
            return dx >= 0 ? 82 : -82;
        }

        // 自由移动：严格依据 (vx, -depthSpeed) 3D 方向转向
        // D (+X) -> +90°, A (-X) -> -90°, S (+Z 朝镜头正面) -> 0°, W (-Z 背对镜头背面) -> 180°
        if (horizSpeed > 2.5) {
            const velX = a.vx;
            const velZ = -a.depthSpeed;
            return wrapAngleDeg(Math.atan2(velX, velZ) * (180 / Math.PI));
        }

        return this.targetYawDeg;
    }

    private selectAnimation(p: Play, horizSpeed: number, cartDelta: number): void {
        const a = p.player;
        let next = "idle";
        let loop = true;
        let speed = 1.0;

        if (p.room.key === "tower" && p.phase === "tower-knock") {
            next = "knock";
            loop = true;
            speed = 1.05;
        } else if (p.room.key === "tower" && (p.deskHold > 0 || p.phase === "tower-given")) {
            next = "offer";
            loop = true;
            speed = 0.95;
        } else if (this.throwTimer > 0) {
            next = "throw";
            loop = false;
            speed = 1.15;
        } else if (p.hasBottle && p.aimHold > 0) {
            next = "aim";
            loop = true;
            speed = 1.0;
        } else if (p.gripping) {
            next = cartDelta > 0.05 ? "pull_walk" : "pull_idle";
            loop = true;
            speed = cartDelta > 0.05 ? 1.05 : 0.9;
        } else if (!a.onGround) {
            next = "jump";
            loop = true;
            speed = 1.0;
        } else if (a.crouch) {
            next = horizSpeed > 8 ? "crouch_walk" : "crouch_idle";
            loop = true;
            speed = horizSpeed > 8 ? Math.max(0.75, Math.min(1.25, horizSpeed / 78)) : 1.0;
        } else if (this.listenTimer > 0 && horizSpeed <= 8) {
            next = "listen";
            loop = true;
            speed = 1.0;
        } else if (horizSpeed > 135) {
            next = "run";
            loop = true;
            speed = Math.max(0.95, Math.min(1.30, horizSpeed / 160));
        } else if (horizSpeed > 8) {
            next = "walk";
            loop = true;
            speed = Math.max(0.72, Math.min(1.18, horizSpeed / 112));
        } else {
            next = "idle";
            loop = true;
            speed = 1.0;
        }

        this.playAnim(next, loop, speed);
    }

    private playAnim(name: string, loop: boolean, speed: number): void {
        const m = this.model;
        if (m === undefined) {
            return;
        }
        m.speed = speed;
        if (this.currentAnim !== name || this.animLoop !== loop) {
            this.currentAnim = name;
            this.animLoop = loop;
            m.play(name, loop);
        }
    }

    getDebugState(p?: Play): Xiaoman3DActorDebug {
        const pos = this.pivot.position;
        return {
            loaded: this.model !== undefined,
            visible: this.pivot.visible,
            yawDeg: this.yawDeg,
            targetYawDeg: this.targetYawDeg,
            animName: this.currentAnim,
            animCount: this.model !== undefined ? this.model.animationCount : 0,
            hasHandSocket: this.hasSocket,
            bottleInHand: this.heldBottle !== undefined && this.heldBottle.visible,
            worldX: p !== undefined ? p.player.x : pos.x * 100,
            worldY: p !== undefined ? p.player.y : pos.y * 100,
            worldZ: p !== undefined ? -p.player.depth : pos.z * 100,
        };
    }
}
