-- [ts]: target_types.ts
local ____exports = {} -- 1
____exports.ZERO_SAFE_INSETS = {left = 0, right = 0, top = 0, bottom = 0} -- 32
____exports.TOUCH_OPACITY_STEPS = {0.52, 0.78, 0.96} -- 34
____exports.TOUCH_SCALE_STEPS = {0.88, 1, 1.14} -- 35
____exports.VOLUME_STEPS = { -- 36
	0, -- 36
	0.1, -- 36
	0.2, -- 36
	0.3, -- 36
	0.4, -- 36
	0.5, -- 36
	0.6, -- 36
	0.7, -- 36
	0.8, -- 36
	0.9, -- 36
	1 -- 36
} -- 36
function ____exports.getReleaseConfig() -- 231
	local ____opt_0 = _G.package -- 232
	local reg = ____opt_0 and ____opt_0.loaded -- 232
	local ____temp_2 -- 233
	if reg ~= nil then -- 233
		____temp_2 = reg["watch.release"] -- 233
	else -- 233
		____temp_2 = nil -- 233
	end -- 233
	local cfg = ____temp_2 -- 233
	if cfg ~= nil and type(cfg) == "table" then -- 234
		return cfg -- 235
	end -- 235
	return nil -- 237
end -- 231
return ____exports -- 231
