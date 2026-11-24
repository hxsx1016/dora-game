import { Color } from "Dora";
import { ACTOR_DEPTH_HALF, overlapsDepth } from "Script/watch/depth";
import { Actor, Play } from "Script/watch/play";
import { DepthRange } from "Script/watch/rooms";

export const OCCLUDED_OPACITY = 0.44;
const WHITE = Color(255, 255, 255, 255);

export function occlusionTint(opacity: number, color: Color.Type = WHITE): Color.Type {
    const shade = 1 - 0.32 * (1 - opacity) / (1 - OCCLUDED_OPACITY);
    return Color(color.r * shade, color.g * shade, color.b * shade, color.a);
}

interface Occluder {
    x0: number;
    x1: number;
    y0: number;
    y1: number;
    depth: DepthRange;
    passThrough?: boolean;
}

/** 同一个贴图容器内，脚下越靠近屏幕，下层编号越大。 */
export function depthOrder(depth: number, tie: number): number {
    return 4096 - Math.round(depth * 16) + tie;
}

function hides(actor: Actor, prop: Occluder): boolean {
    const behind = actor.depth > prop.depth.min + 0.5;
    const passingThrough = prop.passThrough && overlapsDepth(actor.depth, prop.depth, ACTOR_DEPTH_HALF);
    if (!actor.alive || (!behind && !passingThrough) ||
        actor.x + actor.w * 0.5 <= prop.x0 || actor.x - actor.w * 0.5 >= prop.x1) {
        return false;
    }
    if (actor.y >= prop.y1 && overlapsDepth(actor.depth, prop.depth, ACTOR_DEPTH_HALF)) {
        return false;
    }
    const foot = actor.y + actor.depth;
    const height = actor.rollT > 0 ? actor.h * 0.6 : actor.h;
    return foot < prop.y1 + prop.depth.max && foot + height > prop.y0 + prop.depth.min;
}

export class DepthOcclusion {
    private opacity: Record<string, number> = {};

    reset(): void {
        this.opacity = {};
    }

    update(key: string, prop: Occluder, p: Play, dt: number): number {
        const current = this.opacity[key] ?? 1;
        const obscured = hides(p.player, prop) || hides(p.partner, prop);
        const next = obscured ? Math.max(OCCLUDED_OPACITY, current - dt * 5)
            : Math.min(1, current + dt * 4);
        this.opacity[key] = next;
        return next;
    }
}
