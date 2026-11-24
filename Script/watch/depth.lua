-- [ts]: depth.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes -- 1
local ____exports = {} -- 1
--- 角色脚下在前后方向占据的半宽。
____exports.ACTOR_DEPTH_HALF = 7 -- 4
local INTERACT_DEPTH_REACH = 18 -- 5
local LANE_SPACING = 32 -- 6
local LANE_MARGIN = 12 -- 7
____exports.LANE_DEPTH = {upper = LANE_SPACING, middle = 0, lower = -LANE_SPACING} -- 10
____exports.LANE_ROAD = {min = ____exports.LANE_DEPTH.lower - LANE_MARGIN, max = ____exports.LANE_DEPTH.upper + LANE_MARGIN} -- 11
function ____exports.nearestLane(depth) -- 13
	return math.max( -- 14
		____exports.LANE_DEPTH.lower, -- 14
		math.min( -- 14
			____exports.LANE_DEPTH.upper, -- 14
			math.floor(depth / LANE_SPACING + 0.5) * LANE_SPACING -- 14
		) -- 14
	) -- 14
end -- 13
function ____exports.adjacentLane(depth, direction) -- 17
	return ____exports.nearestLane(____exports.nearestLane(depth) + direction * LANE_SPACING) -- 18
end -- 17
--- 相邻档位合成一块占地。分开的档位各生成一块，给中间留下通道。
function ____exports.laneFootprints(lanes) -- 22
	local footprints = {} -- 23
	local ordered = {"lower", "middle", "upper"} -- 24
	local run -- 25
	for ____, lane in ipairs(ordered) do -- 26
		do -- 26
			if not __TS__ArrayIncludes(lanes, lane) then -- 26
				run = nil -- 28
				goto __continue5 -- 29
			end -- 29
			local center = ____exports.LANE_DEPTH[lane] -- 31
			if run == nil then -- 31
				run = {min = center - LANE_MARGIN, max = center + LANE_MARGIN} -- 33
				footprints[#footprints + 1] = run -- 34
			else -- 34
				run.max = center + LANE_MARGIN -- 36
			end -- 36
		end -- 36
		::__continue5:: -- 36
	end -- 36
	return footprints -- 39
end -- 22
function ____exports.overlapsDepth(depth, range, half, endDepth) -- 42
	if endDepth == nil then -- 42
		endDepth = depth -- 43
	end -- 43
	return range == nil or math.max(depth, endDepth) + half > range.min and math.min(depth, endDepth) - half < range.max -- 45
end -- 42
function ____exports.inReachDepth(depth, target) -- 49
	if target == nil then -- 49
		target = 0 -- 49
	end -- 49
	return math.abs(depth - target) <= INTERACT_DEPTH_REACH -- 50
end -- 49
return ____exports -- 49