-- [ts]: depth.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes -- 1
local ____exports = {} -- 1
--- 角色脚下在前后方向占据的半宽。
____exports.ACTOR_DEPTH_HALF = 7 -- 4
____exports.INTERACT_DEPTH_REACH = 18 -- 5
--- 2.5D 地面纵深投影到屏幕 Y 轴的透视压扁系数（避免 1:1 映射把路面画成竖墙、把矮柜顶盖拉高 56 单位）。
____exports.DEPTH_Y_SCALE = 0.42 -- 7
local LANE_SPACING = 32 -- 8
local LANE_MARGIN = 12 -- 9
____exports.LANE_DEPTH = {upper = LANE_SPACING, middle = 0, lower = -LANE_SPACING} -- 13
____exports.LANE_ROAD = {min = ____exports.LANE_DEPTH.lower - LANE_MARGIN, max = ____exports.LANE_DEPTH.upper + LANE_MARGIN} -- 14
--- 相邻档位合成一块占地。分开的档位各生成一块，给中间留下通道。
function ____exports.laneFootprints(lanes) -- 17
	local footprints = {} -- 18
	local ordered = {"lower", "middle", "upper"} -- 19
	local run -- 20
	for ____, lane in ipairs(ordered) do -- 21
		do -- 21
			if not __TS__ArrayIncludes(lanes, lane) then -- 21
				run = nil -- 23
				goto __continue3 -- 24
			end -- 24
			local center = ____exports.LANE_DEPTH[lane] -- 26
			if run == nil then -- 26
				run = {min = center - LANE_MARGIN, max = center + LANE_MARGIN} -- 28
				footprints[#footprints + 1] = run -- 29
			else -- 29
				run.max = center + LANE_MARGIN -- 31
			end -- 31
		end -- 31
		::__continue3:: -- 31
	end -- 31
	return footprints -- 34
end -- 17
function ____exports.overlapsDepth(depth, range, half) -- 37
	return range == nil or depth + half > range.min and depth - half < range.max -- 38
end -- 37
function ____exports.inReachDepth(depth, target) -- 41
	if target == nil then -- 41
		target = 0 -- 41
	end -- 41
	return math.abs(depth - target) <= ____exports.INTERACT_DEPTH_REACH -- 42
end -- 41
return ____exports -- 41