-- [ts]: occlusion.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____depth = require("Script.watch.depth") -- 1
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 1
local overlapsDepth = ____depth.overlapsDepth -- 1
--- 同一个贴图容器内，脚下越靠近屏幕，下层编号越大。
function ____exports.depthOrder(depth, tie) -- 15
	return 4096 - math.floor(depth * 16 + 0.5) + tie -- 16
end -- 15
local function hides(actor, prop) -- 19
	local behind = actor.depth > prop.depth.min + 0.5 -- 20
	local passingThrough = prop.passThrough and overlapsDepth(actor.depth, prop.depth, ACTOR_DEPTH_HALF) -- 21
	if not actor.alive or not behind and not passingThrough or actor.x + actor.w * 0.5 <= prop.x0 or actor.x - actor.w * 0.5 >= prop.x1 then -- 21
		return false -- 24
	end -- 24
	if actor.y >= prop.y1 and overlapsDepth(actor.depth, prop.depth, ACTOR_DEPTH_HALF) then -- 24
		return false -- 27
	end -- 27
	local foot = actor.y + actor.depth -- 29
	local height = actor.rollT > 0 and actor.h * 0.6 or actor.h -- 30
	return foot < prop.y1 + prop.depth.max and foot + height > prop.y0 + prop.depth.min -- 31
end -- 19
____exports.DepthOcclusion = __TS__Class() -- 34
local DepthOcclusion = ____exports.DepthOcclusion -- 34
DepthOcclusion.name = "DepthOcclusion" -- 34
function DepthOcclusion.prototype.____constructor(self) -- 34
	self.opacity = {} -- 35
end -- 34
function DepthOcclusion.prototype.reset(self) -- 37
	self.opacity = {} -- 38
end -- 37
function DepthOcclusion.prototype.update(self, key, prop, p, dt) -- 41
	local current = self.opacity[key] or 1 -- 42
	local obscured = hides(p.player, prop) or hides(p.partner, prop) -- 43
	local next = obscured and math.max(0.24, current - dt * 7) or math.min(1, current + dt * 4) -- 44
	self.opacity[key] = next -- 46
	return next -- 47
end -- 41
return ____exports -- 41