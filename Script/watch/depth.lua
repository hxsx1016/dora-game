-- [ts]: depth.ts
local ____exports = {} -- 1
--- 角色脚下在前后方向占据的半宽。
____exports.ACTOR_DEPTH_HALF = 7 -- 4
local INTERACT_DEPTH_REACH = 18 -- 5
function ____exports.overlapsDepth(depth, range, half) -- 7
	return range == nil or depth + half > range.min and depth - half < range.max -- 8
end -- 7
function ____exports.inReachDepth(depth, target) -- 11
	if target == nil then -- 11
		target = 0 -- 11
	end -- 11
	return math.abs(depth - target) <= INTERACT_DEPTH_REACH -- 12
end -- 11
return ____exports -- 11