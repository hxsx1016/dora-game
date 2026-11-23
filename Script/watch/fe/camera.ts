/**
 * 动态镜头导演（CameraDirector）：
 * 负责高清 16:9 视口下的平滑前瞻、剧情/战斗动态缩放、射击/受击阻尼震屏，
 * 并提供与渲染完全互逆的 worldToScreen / screenToWorld 矩阵换算，
 * 保证注入 Play.worldMapper 后鼠标点射与投瓶落点 0 误差。
 */

import { Play } from "Script/watch/play";
import { themeOf } from "Script/watch/fe/theme";

/** 基础竖直世界视野高度（zoom=1 时屏幕纵向容纳约 304 世界单位，1280×720 下约 2.37 px/单位） */
const BASE_VIEW_UNITS_H = 304;
/** 地面基准线落在屏幕从底往上的比例（约 22.5%，留出大气天际与底部叙事字幕带） */
const GROUND_SCREEN_FRAC = 0.225;

export class CameraDirector {
    /** 当前镜头中心（世界单位） */
    x = 0;
    y = 85;
    /** 当前平滑缩放倍率 */
    zoom = 1.0;
    /** 震屏强度与相位 */
    shakeAmp = 0;
    shakeX = 0;
    shakeY = 0;
    private shakePhase = 0;

    /** 当前帧视口缓存（供 screenToWorld 精确反算） */
    viewW = 1280;
    viewH = 720;
    ppu = 2.37;
    groundScreenY = 162;

    /** 立即对齐到房间初始位置（切房或重置时调用） */
    snap(p: Play, w: number, h: number): void {
        const theme = themeOf(p.room.key);
        this.zoom = theme.defaultZoom;
        this.shakeAmp = 0;
        this.shakeX = 0;
        this.shakeY = 0;
        this.x = p.player.x + p.player.facing * 42;
        this.y = this.targetCamY(p);
        this.recomputeMetrics(p, w, h);
    }

    /** 施加阻尼震屏（单位：屏幕像素） */
    addShake(amount: number): void {
        if (amount > this.shakeAmp) {
            this.shakeAmp = Math.min(18, amount);
        } else {
            this.shakeAmp = Math.min(18, this.shakeAmp + amount * 0.45);
        }
    }

    /** 每帧推进镜头前瞻、缩放、震屏与边界钳制 */
    update(dt: number, p: Play, w: number, h: number): void {
        const theme = themeOf(p.room.key);
        let desiredZoom = theme.defaultZoom;

        // 剧情与互动动态推拉镜（艾希式演出镜头感）
        if (p.room.key === "prologue" && p.phase === "prologue-give") {
            desiredZoom = 1.24;
        } else if (!p.childMode && p.escort.state === "calming") {
            desiredZoom = 1.20;
        } else if (p.room.key === "gate") {
            if (p.phase === "gate-hold") {
                desiredZoom = 0.88;
            } else if (p.phase === "gate-count") {
                desiredZoom = 1.15;
            } else if (p.phase === "gate-send") {
                desiredZoom = 1.06;
            }
        } else if (p.room.key === "outside") {
            // 上层拉车或钻拱附近保持能同时看见上层板车与下层拱洞
            desiredZoom = p.player.x < 560 ? 0.94 : 1.02;
        } else if (p.room.key === "tower" && p.phase !== "tower-wait") {
            desiredZoom = 1.22;
        }

        const zk = Math.min(1, dt * 3.8);
        this.zoom += (desiredZoom - this.zoom) * zk;

        // 水平前瞻：朝向 + 轻微鼠标偏向（军人瞄准时视野微展）
        let lookAhead = p.player.facing * 48;
        if (!p.childMode && p.aimX > 0 && w > 0) {
            const normMouse = (p.aimX / w - 0.5) * 2;
            lookAhead += normMouse * 36;
        }
        if (p.room.key === "outside" && p.player.x < 520) {
            // 城外剖面重点居中，让上层板车与下层拱同时构图完整
            lookAhead = p.player.x < 280 ? 96 : 18;
        }
        if (p.room.key === "gate" && p.phase === "gate-hold") {
            lookAhead = 120;
        }
        if (p.room.key === "prologue" && p.phase === "prologue-give") {
            lookAhead = (p.partner.x - p.player.x) * 0.5;
        }

        const tx = p.player.x + lookAhead;
        const ty = this.targetCamY(p);
        const followK = Math.min(1, dt * 6.5);
        this.x += (tx - this.x) * followK;
        this.y += (ty - this.y) * Math.min(1, dt * 5.0);

        // 震屏衰减
        if (this.shakeAmp > 0.08) {
            this.shakePhase += dt * 68;
            this.shakeX = Math.sin(this.shakePhase * 1.3) * this.shakeAmp;
            this.shakeY = Math.cos(this.shakePhase * 1.7) * this.shakeAmp * 0.72;
            this.shakeAmp *= Math.max(0, 1 - dt * 11.5);
        } else {
            this.shakeAmp = 0;
            this.shakeX = 0;
            this.shakeY = 0;
        }

        this.recomputeMetrics(p, w, h);
    }

    private targetCamY(p: Play): number {
        if (p.room.key === "outside" && p.player.y >= 60) {
            return 102;
        }
        return 82 + Math.max(0, p.player.y - 36) * 0.35;
    }

    private recomputeMetrics(p: Play, w: number, h: number): void {
        this.viewW = Math.max(320, w);
        this.viewH = Math.max(180, h);
        this.ppu = (this.viewH / BASE_VIEW_UNITS_H) * this.zoom;
        this.groundScreenY = this.viewH * GROUND_SCREEN_FRAC;

        // 水平钳制在房间边界内，避免露出房间外黑洞
        const halfWorldW = (this.viewW * 0.5) / this.ppu;
        const spanX = p.room.maxX - p.room.minX;
        if (spanX <= halfWorldW * 2) {
            this.x = (p.room.minX + p.room.maxX) * 0.5;
        } else {
            const minCam = p.room.minX + halfWorldW;
            const maxCam = p.room.maxX - halfWorldW;
            if (this.x < minCam) {
                this.x = minCam;
            }
            if (this.x > maxCam) {
                this.x = maxCam;
            }
        }
    }

    /** 世界 X → 屏幕局部 X（左下原点） */
    sx(wx: number): number {
        return this.viewW * 0.5 + (wx - this.x) * this.ppu + this.shakeX;
    }

    /** 世界 Y → 屏幕局部 Y（左下原点；y=0 落在 groundScreenY） */
    sy(wy: number): number {
        const yOffset = (this.y - 82) * 0.45;
        return this.groundScreenY + (wy - yOffset) * this.ppu + this.shakeY;
    }

    /** 世界长度 → 屏幕像素长度 */
    len(worldLen: number): number {
        return worldLen * this.ppu;
    }

    /** 屏幕局部坐标 → 世界坐标（sx/sy 的精确反函数） */
    screenToWorld(screenX: number, screenY: number): { x: number; y: number } {
        const yOffset = (this.y - 82) * 0.45;
        return {
            x: this.x + (screenX - this.shakeX - this.viewW * 0.5) / this.ppu,
            y: yOffset + (screenY - this.shakeY - this.groundScreenY) / this.ppu,
        };
    }
}
