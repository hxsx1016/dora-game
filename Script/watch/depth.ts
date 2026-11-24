import { DepthRange } from "Script/watch/rooms";

/** 角色脚下在前后方向占据的半宽。 */
export const ACTOR_DEPTH_HALF = 7;
const INTERACT_DEPTH_REACH = 18;

export function overlapsDepth(depth: number, range: DepthRange | undefined, half: number): boolean {
    return range === undefined || (depth + half > range.min && depth - half < range.max);
}

export function inReachDepth(depth: number, target: number = 0): boolean {
    return Math.abs(depth - target) <= INTERACT_DEPTH_REACH;
}
