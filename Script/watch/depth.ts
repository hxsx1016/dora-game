import type { DepthRange } from "Script/watch/rooms";

/** 角色脚下在前后方向占据的半宽。 */
export const ACTOR_DEPTH_HALF = 7;
const INTERACT_DEPTH_REACH = 18;
const LANE_SPACING = 32;
const LANE_MARGIN = 12;

/** 关卡摆放用的占地区段。 */
export type DepthLane = "upper" | "middle" | "lower";
export const LANE_DEPTH: Record<DepthLane, number> = { upper: LANE_SPACING, middle: 0, lower: -LANE_SPACING };
export const LANE_ROAD: DepthRange = { min: LANE_DEPTH.lower - LANE_MARGIN, max: LANE_DEPTH.upper + LANE_MARGIN };

/** 相邻档位合成一块占地。分开的档位各生成一块，给中间留下通道。 */
export function laneFootprints(lanes: readonly DepthLane[]): DepthRange[] {
    const footprints: DepthRange[] = [];
    const ordered: DepthLane[] = ["lower", "middle", "upper"];
    let run: DepthRange | undefined;
    for (const lane of ordered) {
        if (!lanes.includes(lane)) {
            run = undefined;
            continue;
        }
        const center = LANE_DEPTH[lane];
        if (run === undefined) {
            run = { min: center - LANE_MARGIN, max: center + LANE_MARGIN };
            footprints.push(run);
        } else {
            run.max = center + LANE_MARGIN;
        }
    }
    return footprints;
}

export function overlapsDepth(depth: number, range: DepthRange | undefined, half: number): boolean {
    return range === undefined || (depth + half > range.min && depth - half < range.max);
}

export function inReachDepth(depth: number, target: number = 0): boolean {
    return Math.abs(depth - target) <= INTERACT_DEPTH_REACH;
}
