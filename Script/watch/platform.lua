-- [ts]: platform.ts
local ____exports = {} -- 1
local ____target = require("Script.watch.target") -- 5
local getActiveTarget = ____target.getActiveTarget -- 5
local ____target_types = require("Script.watch.target_types") -- 6
local ZERO_SAFE_INSETS = ____target_types.ZERO_SAFE_INSETS -- 14
local getReleaseConfig = ____target_types.getReleaseConfig -- 15
____exports.ZERO_SAFE_INSETS = ZERO_SAFE_INSETS -- 26
____exports.getReleaseConfig = getReleaseConfig -- 27
function ____exports.getTargetProfileId() -- 30
	return getActiveTarget().id -- 31
end -- 30
function ____exports.getPlatformCaps() -- 34
	return getActiveTarget():getPlatformCaps() -- 35
end -- 34
function ____exports.getPlatformKind() -- 38
	return getActiveTarget():getPlatformCaps().kind -- 39
end -- 38
function ____exports.isWebPlatform() -- 42
	return getActiveTarget():getPlatformCaps().isWeb -- 43
end -- 42
function ____exports.isMobilePlatform() -- 46
	return getActiveTarget():getPlatformCaps().isMobile -- 47
end -- 46
function ____exports.isDesktopNative() -- 50
	return getActiveTarget():getPlatformCaps().isDesktop -- 51
end -- 50
function ____exports.isStandaloneAndroidApk() -- 54
	return getActiveTarget():getPlatformCaps().isStandaloneAndroidApk -- 55
end -- 54
function ____exports.canToggleFullscreen() -- 58
	return getActiveTarget():canToggleFullscreen() -- 59
end -- 58
function ____exports.canQuitApp() -- 62
	return getActiveTarget():canQuitApp() -- 63
end -- 62
function ____exports.isReleaseMode() -- 66
	return getActiveTarget():isReleaseMode() -- 67
end -- 66
function ____exports.triggerHaptics(seconds, enabled) -- 70
	getActiveTarget():triggerHaptics(seconds, enabled) -- 71
end -- 70
function ____exports.isCompactAspect(stageW, stageH) -- 74
	if stageW <= 0 or stageH <= 0 then -- 75
		return false -- 75
	end -- 75
	return stageW / stageH < 1.62 -- 76
end -- 74
function ____exports.computeStageViewport(fullW, fullH) -- 79
	return getActiveTarget():computeStageViewport(fullW, fullH) -- 80
end -- 79
function ____exports.viewToStage(viewX, viewY, vp) -- 83
	local x = viewX - vp.stageX -- 88
	local y = viewY - vp.stageY -- 89
	return {x = x, y = y, inside = x >= 0 and x <= vp.stageW and y >= 0 and y <= vp.stageH} -- 90
end -- 83
return ____exports -- 83
