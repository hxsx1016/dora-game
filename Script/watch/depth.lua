-- [ts]: depth.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes -- 1
local ____exports = {} -- 1
--- 角色脚下在前后方向占据的半宽。
____exports.ACTOR_DEPTH_HALF = 7 -- 4
local INTERACT_DEPTH_REACH = 18 -- 5
local LANE_SPACING = 32 -- 6
local LANE_MARGIN = 12 -- 7
____exports.LANE_DEPTH = {upper = LANE_SPACING, middle = 0, lower = -LANE_SPACING} -- 11
____exports.LANE_ROAD = {min = ____exports.LANE_DEPTH.lower - LANE_MARGIN, max = ____exports.LANE_DEPTH.upper + LANE_MARGIN} -- 12
--- 相邻档位合成一块占地。分开的档位各生成一块，给中间留下通道。
function ____exports.laneFootprints(lanes) -- 15
	local footprints = {} -- 16
	local ordered = {"lower", "middle", "upper"} -- 17
	local run -- 18
	for ____, lane in ipairs(ordered) do -- 19
		do -- 19
			if not __TS__ArrayIncludes(lanes, lane) then -- 19
				run = nil -- 21
				goto __continue3 -- 22
			end -- 22
			local center = ____exports.LANE_DEPTH[lane] -- 24
			if run == nil then -- 24
				run = {min = center - LANE_MARGIN, max = center + LANE_MARGIN} -- 26
				footprints[#footprints + 1] = run -- 27
			else -- 27
				run.max = center + LANE_MARGIN -- 29
			end -- 29
		end -- 29
		::__continue3:: -- 29
	end -- 29
	return footprints -- 32
end -- 15
function ____exports.overlapsDepth(depth, range, half) -- 35
	return range == nil or depth + half > range.min and depth - half < range.max -- 36
end -- 35
function ____exports.inReachDepth(depth, target) -- 39
	if target == nil then -- 39
		target = 0 -- 39
	end -- 39
	return math.abs(depth - target) <= INTERACT_DEPTH_REACH -- 40
end -- 39
return ____exports -- 39