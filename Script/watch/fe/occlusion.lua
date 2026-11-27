-- [ts]: occlusion.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local ____depth = require("Script.watch.depth") -- 2
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 2
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 2
local overlapsDepth = ____depth.overlapsDepth -- 2
____exports.OCCLUDED_OPACITY = 0.44 -- 6
local WHITE = Color(255, 255, 255, 255) -- 7
function ____exports.occlusionTint(opacity, color) -- 9
	if color == nil then -- 9
		color = WHITE -- 9
	end -- 9
	local shade = 1 - 0.32 * (1 - opacity) / (1 - ____exports.OCCLUDED_OPACITY) -- 10
	return Color(color.r * shade, color.g * shade, color.b * shade, color.a) -- 11
end -- 9
--- 同一个贴图容器内，脚下越靠近屏幕，下层编号越大。
function ____exports.depthOrder(depth, tie) -- 24
	return 4096 - math.floor(depth * 16 + 0.5) + tie -- 25
end -- 24
local function hides(actor, prop) -- 28
	local behind = actor.depth > prop.depth.min + 0.5 -- 29
	local passingThrough = prop.passThrough and overlapsDepth(actor.depth, prop.depth, ACTOR_DEPTH_HALF) -- 30
	if not actor.alive or not behind and not passingThrough or actor.x + actor.w * 0.5 <= prop.x0 or actor.x - actor.w * 0.5 >= prop.x1 then -- 30
		return false -- 33
	end -- 33
	if actor.y >= prop.y1 and overlapsDepth(actor.depth, prop.depth, ACTOR_DEPTH_HALF) then -- 33
		return false -- 36
	end -- 36
	local foot = actor.y + actor.depth * DEPTH_Y_SCALE -- 38
	local height = actor.rollT > 0 and actor.h * 0.6 or actor.h -- 39
	return foot < prop.y1 + prop.depth.max * DEPTH_Y_SCALE and foot + height > prop.y0 + prop.depth.min * DEPTH_Y_SCALE -- 40
end -- 28
____exports.DepthOcclusion = __TS__Class() -- 43
local DepthOcclusion = ____exports.DepthOcclusion -- 43
DepthOcclusion.name = "DepthOcclusion" -- 43
function DepthOcclusion.prototype.____constructor(self) -- 43
	self.opacity = {} -- 44
end -- 43
function DepthOcclusion.prototype.reset(self) -- 46
	self.opacity = {} -- 47
end -- 46
function DepthOcclusion.prototype.update(self, key, prop, p, dt) -- 50
	local current = self.opacity[key] or 1 -- 51
	local obscured = hides(p.player, prop) or hides(p.partner, prop) -- 52
	local next = obscured and math.max(____exports.OCCLUDED_OPACITY, current - dt * 5) or math.min(1, current + dt * 4) -- 53
	self.opacity[key] = next -- 55
	return next -- 56
end -- 50
return ____exports -- 50