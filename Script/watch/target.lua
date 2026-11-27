-- [ts]: target.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 11
local App = ____Dora.App -- 11
local ____target_types = require("Script.watch.target_types") -- 12
local getReleaseConfig = ____target_types.getReleaseConfig -- 12
local function isValidTargetId(v) -- 14
	return v == "windows" or v == "android" or v == "handheld" or v == "web" -- 15
end -- 14
function ____exports.resolveTargetId() -- 18
	local ____opt_0 = _G.package -- 19
	local reg = ____opt_0 and ____opt_0.loaded -- 19
	if reg ~= nil then -- 20
		local forced = reg["watch.target"] -- 21
		if isValidTargetId(forced) then -- 22
			return forced -- 23
		end -- 23
	end -- 23
	local cfg = getReleaseConfig() -- 26
	if cfg ~= nil and isValidTargetId(cfg.target) then -- 27
		return cfg.target -- 28
	end -- 28
	local plat = App.platform -- 30
	if plat == "Web" then -- 31
		return "web" -- 31
	end -- 31
	if plat == "Android" or plat == "iOS" then -- 32
		return "android" -- 32
	end -- 32
	return "windows" -- 33
end -- 18
local cachedId -- 36
local cachedTarget -- 37
function ____exports.resetActiveTarget() -- 39
	cachedId = nil -- 40
	cachedTarget = nil -- 41
end -- 39
function ____exports.getActiveTarget() -- 44
	local id = ____exports.resolveTargetId() -- 45
	if cachedTarget ~= nil and cachedId == id then -- 46
		return cachedTarget -- 47
	end -- 47
	local luaRequire = _G.require -- 49
	local modName = ("Script.watch.targets." .. id) .. ".index" -- 50
	local mod = luaRequire(modName) -- 51
	cachedId = id -- 52
	cachedTarget = mod.TARGET -- 53
	return cachedTarget -- 54
end -- 44
return ____exports -- 44
