/**
 * 《向西守望》共享瞄准目标采集与轻度敌兵磁吸辅助（仅安卓、掌机、Web 引入）。
 *
 * Windows 发行包不引入、不打包本模块。
 */

import { DEPTH_Y_SCALE } from "Script/watch/depth";
import { Play, worldToScreen } from "Script/watch/play";
import { CameraDirector } from "Script/watch/fe/camera";

export interface AimTargetCandidate {
    /** 主舞台局部坐标（左下原点，与 Input.mx / Input.my 一致） */
    sx: number;
    sy: number;
    /** 盾兵标记（有效持盾时瞄准点自动抬高至盾顶上方） */
    shield: boolean;
}

const DEFAULT_CONE_HALF_ANGLE_RAD = (26 * Math.PI) / 180;

function clamp(v: number, lo: number, hi: number): number {
    return v < lo ? lo : (v > hi ? hi : v);
}

function hypot(dx: number, dy: number): number {
    return Math.sqrt(dx * dx + dy * dy);
}

/** Use the sprite camera when supplied by the renderer, otherwise project through Play.draw's viewport. */
function projectAimPoint(p: Play, cam: CameraDirector | undefined, x: number, y: number, depth: number): { x: number; y: number } {
    if (cam !== undefined) return cam.worldToScreen(x, y, depth);
    return worldToScreen(x, y + depth * DEPTH_Y_SCALE, p.cam, p.view);
}

export function projectMuzzle(p: Play, cam: CameraDirector | undefined): { x: number; y: number } {
    const a = p.player;
    return projectAimPoint(p, cam, a.x + a.facing * 8, a.y + a.h * 0.72, a.depth);
}

export function collectAimTargets(
    p: Play,
    cam: CameraDirector | undefined,
    stageW: number,
    stageH: number,
): AimTargetCandidate[] {
    const out: AimTargetCandidate[] = [];
    let i = 0;
    for (i = 0; i < p.enemies.length; i++) {
        const e = p.enemies[i];
        if (!e.alive) continue;
        const isShield = e.kind === "shield" && (e.shieldHp ?? 0) > 0;
        const aimWorldY = e.y + e.h * (isShield ? 0.88 : 0.60);
        const pt = projectAimPoint(p, cam, e.x, aimWorldY, e.depth ?? 0);
        if (pt.x >= -64 && pt.x <= stageW + 64 && pt.y >= -48 && pt.y <= stageH + 48) {
            out.push({ sx: pt.x, sy: pt.y, shield: isShield });
        }
    }
    return out;
}

/** 屏幕点选轻度磁吸（用于触屏直点 / 拖滑点射）：仅在指定像素半径内吸附最近目标。 */
export function snapPointAim(
    stageX: number,
    stageY: number,
    targets: AimTargetCandidate[],
    maxSnapPx: number,
    enabled: boolean,
): { x: number; y: number } {
    if (!enabled || targets.length === 0 || maxSnapPx <= 0) {
        return { x: stageX, y: stageY };
    }
    let bestDist = maxSnapPx;
    let bestX = stageX;
    let bestY = stageY;
    let i = 0;
    for (i = 0; i < targets.length; i++) {
        const e = targets[i];
        const d = hypot(e.sx - stageX, e.sy - stageY);
        if (d < bestDist) {
            bestDist = d;
            bestX = e.sx;
            bestY = e.sy;
        }
    }
    return { x: bestX, y: bestY };
}

/** 方向锥轻度磁吸（用于手柄右摇杆 360° 瞄准与触屏开火摇杆精瞄）。 */
export function snapConeAim(
    originX: number,
    originY: number,
    dirX: number,
    dirY: number,
    reachPx: number,
    stageW: number,
    stageH: number,
    targets: AimTargetCandidate[],
    enabled: boolean,
    halfAngleRad: number = DEFAULT_CONE_HALF_ANGLE_RAD,
): { x: number; y: number } {
    const baseX = clamp(originX + dirX * reachPx, 12, Math.max(24, stageW - 12));
    const baseY = clamp(originY + dirY * reachPx, 12, Math.max(24, stageH - 12));

    if (!enabled || targets.length === 0) {
        return { x: baseX, y: baseY };
    }

    const wantAngle = Math.atan2(dirY, dirX);
    let bestScore = 1e9;
    let bestTarget: AimTargetCandidate | undefined;
    let i = 0;
    for (i = 0; i < targets.length; i++) {
        const e = targets[i];
        if (e.sx < -24 || e.sx > stageW + 24 || e.sy < -24 || e.sy > stageH + 24) {
            continue;
        }
        const dx = e.sx - originX;
        const dy = e.sy - originY;
        const dist = hypot(dx, dy);
        if (dist < 18) continue;
        let diff = Math.atan2(dy, dx) - wantAngle;
        while (diff > Math.PI) diff -= Math.PI * 2;
        while (diff < -Math.PI) diff += Math.PI * 2;
        const absDiff = Math.abs(diff);
        if (absDiff <= halfAngleRad) {
            const score = absDiff * 420 + dist * 0.25;
            if (score < bestScore) {
                bestScore = score;
                bestTarget = e;
            }
        }
    }

    if (bestTarget !== undefined) {
        return {
            x: clamp(bestTarget.sx, 12, Math.max(24, stageW - 12)),
            y: clamp(bestTarget.sy, 12, Math.max(24, stageH - 12)),
        };
    }
    return { x: baseX, y: baseY };
}

/** 触屏点按「开火」大钮时的智能锁敌目标（未开启磁吸或无可见敌人时沿朝向平射）。 */
export function pickSmartFireTarget(
    originX: number,
    originY: number,
    facing: number,
    stageW: number,
    stageH: number,
    uiScale: number,
    targets: AimTargetCandidate[],
    aimAssist: boolean,
    fallback?: { x: number; y: number },
): { x: number; y: number } {
    if (aimAssist && targets.length > 0) {
        let bestDist = 1e9;
        let bestX = originX + facing * 220;
        let bestY = originY;
        let i = 0;
        for (i = 0; i < targets.length; i++) {
            const e = targets[i];
            if (e.sx < -32 || e.sx > stageW + 32 || e.sy < -32 || e.sy > stageH + 32) {
                continue;
            }
            const d = hypot(e.sx - originX, e.sy - originY);
            if (d < bestDist) {
                bestDist = d;
                bestX = e.sx;
                bestY = e.sy;
            }
        }
        if (bestDist < 1e8) {
            return {
                x: clamp(bestX, 12, Math.max(24, stageW - 12)),
                y: clamp(bestY, 12, Math.max(24, stageH - 12)),
            };
        }
    }
    if (fallback !== undefined) {
        return fallback;
    }
    const dir = facing < 0 ? -1 : 1;
    const reach = 240 * Math.max(0.25, uiScale);
    return {
        x: clamp(originX + dir * reach, 16, Math.max(32, stageW - 16)),
        y: clamp(originY, 16, Math.max(32, stageH - 16)),
    };
}
