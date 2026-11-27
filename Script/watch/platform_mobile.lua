-- [ts]: platform_mobile.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 7
local App = ____Dora.App -- 7
local View = ____Dora.View -- 7
--- 判断舞台是否接近 KTR1/KTR2 等紧凑非 16:9 掌机屏（3:2 或 4:3）。
function ____exports.isCompactAspect(stageW, stageH) -- 11
	if stageW <= 0 or stageH <= 0 then -- 12
		return false -- 12
	end -- 12
	return stageW / stageH < 1.62 -- 13
end -- 11
--- 触发短促触觉微震动反馈（仅移动设备支持且用户开启震动时生效）。
function ____exports.triggerMobileHaptics(seconds, enabled) -- 17
	if not enabled then -- 18
		return -- 19
	end -- 19
	local plat = App.platform -- 21
	if plat ~= "Android" and plat ~= "iOS" then -- 22
		return -- 23
	end -- 23
	if type(App.vibrate) == "function" then -- 25
		do -- 25
			pcall(function() -- 25
				App:vibrate(seconds) -- 27
			end) -- 27
		end -- 27
	end -- 27
end -- 17
--- 读取安全区内缩（容错无 safeArea 的旧引擎/测试环境，换算为 View 逻辑像素）。
function ____exports.readSafeInsets(fullW, fullH) -- 35
	if fullW <= 0 or fullH <= 0 then -- 36
		return {left = 0, right = 0, top = 0, bottom = 0} -- 37
	end -- 37
	local appObj = App -- 39
	local safe = appObj.safeArea -- 40
	local vis = appObj.visualSize -- 41
	if safe == nil or vis == nil or vis.width <= 0 or vis.height <= 0 then -- 42
		return {left = 0, right = 0, top = 0, bottom = 0} -- 43
	end -- 43
	if safe.width <= 0 or safe.height <= 0 then -- 45
		return {left = 0, right = 0, top = 0, bottom = 0} -- 46
	end -- 46
	local sx = fullW / vis.width -- 48
	local sy = fullH / vis.height -- 49
	local left = math.max( -- 50
		0, -- 50
		math.min(fullW * 0.12, safe.x * sx) -- 50
	) -- 50
	local right = math.max( -- 51
		0, -- 51
		math.min(fullW * 0.12, (vis.width - (safe.x + safe.width)) * sx) -- 51
	) -- 51
	local bottom = math.max( -- 52
		0, -- 52
		math.min(fullH * 0.12, safe.y * sy) -- 52
	) -- 52
	local top = math.max( -- 53
		0, -- 53
		math.min(fullH * 0.12, (vis.height - (safe.y + safe.height)) * sy) -- 53
	) -- 53
	return { -- 54
		left = math.floor(left + 0.5), -- 55
		right = math.floor(right + 0.5), -- 56
		top = math.floor(top + 0.5), -- 57
		bottom = math.floor(bottom + 0.5) -- 58
	} -- 58
end -- 35
--- 仅横屏安全区视口计算（用于安卓掌机等锁定横屏设备，零竖屏分支）。
function ____exports.computeLandscapeSafeViewport(fullW, fullH) -- 63
	local w = math.max(320, fullW > 0 and fullW or View.size.width) -- 64
	local h = math.max(180, fullH > 0 and fullH or View.size.height) -- 65
	local safe = ____exports.readSafeInsets(w, h) -- 66
	local uiScale = math.max( -- 67
		0.25, -- 67
		math.min(w / 1280, h / 720) -- 67
	) -- 67
	local safeUi = { -- 68
		left = math.min(140, safe.left / uiScale), -- 69
		right = math.min(140, safe.right / uiScale), -- 70
		top = math.min(90, safe.top / uiScale), -- 71
		bottom = math.min(90, safe.bottom / uiScale) -- 72
	} -- 72
	return { -- 74
		fullW = w, -- 75
		fullH = h, -- 76
		stageX = 0, -- 77
		stageY = 0, -- 78
		stageW = w, -- 79
		stageH = h, -- 80
		deckH = 0, -- 81
		topBarH = 0, -- 82
		isPortrait = false, -- 83
		uiScale = uiScale, -- 84
		uiW = w / uiScale, -- 85
		uiH = h / uiScale, -- 86
		safe = safe, -- 87
		safeUi = safeUi -- 88
	} -- 88
end -- 63
--- 支持横竖屏自适应的视口计算（用于安卓手机/平板与 Web）。
function ____exports.computeAdaptiveViewport(fullW, fullH) -- 93
	local w = math.max(320, fullW > 0 and fullW or View.size.width) -- 94
	local h = math.max(180, fullH > 0 and fullH or View.size.height) -- 95
	local safe = ____exports.readSafeInsets(w, h) -- 96
	local isPortrait = h > w * 1.05 -- 97
	if not isPortrait then -- 99
		local uiScale = math.max( -- 100
			0.25, -- 100
			math.min(w / 1280, h / 720) -- 100
		) -- 100
		local safeUi = { -- 101
			left = math.min(140, safe.left / uiScale), -- 102
			right = math.min(140, safe.right / uiScale), -- 103
			top = math.min(90, safe.top / uiScale), -- 104
			bottom = math.min(90, safe.bottom / uiScale) -- 105
		} -- 105
		return { -- 107
			fullW = w, -- 108
			fullH = h, -- 109
			stageX = 0, -- 110
			stageY = 0, -- 111
			stageW = w, -- 112
			stageH = h, -- 113
			deckH = 0, -- 114
			topBarH = 0, -- 115
			isPortrait = false, -- 116
			uiScale = uiScale, -- 117
			uiW = w / uiScale, -- 118
			uiH = h / uiScale, -- 119
			safe = safe, -- 120
			safeUi = safeUi -- 121
		} -- 121
	end -- 121
	local topBarH = math.max( -- 125
		safe.top + 38, -- 125
		math.min( -- 125
			68, -- 125
			math.floor(h * 0.055 + 0.5) -- 125
		) -- 125
	) -- 125
	local minDeckH = math.max( -- 126
		168, -- 126
		math.floor(h * 0.34 + 0.5) -- 126
	) -- 126
	local maxStageH = math.max(160, h - topBarH - minDeckH) -- 127
	local ideal16x9H = math.floor(w * 9 / 16 + 0.5) -- 128
	local stageH = math.min(ideal16x9H, maxStageH) -- 129
	local stageW = stageH < ideal16x9H and math.min( -- 130
		w, -- 130
		math.floor(stageH * 16 / 9 + 0.5) -- 130
	) or w -- 130
	local stageX = math.floor((w - stageW) * 0.5 + 0.5) -- 131
	local stageY = math.max(minDeckH, h - topBarH - stageH) -- 132
	local uiScale = math.max( -- 133
		0.25, -- 133
		math.min(stageW / 1280, stageH / 720) -- 133
	) -- 133
	local rightMargin = w - (stageX + stageW) -- 134
	local safeUi = { -- 135
		left = math.min( -- 136
			140, -- 136
			math.max(0, safe.left - stageX) / uiScale -- 136
		), -- 136
		right = math.min( -- 137
			140, -- 137
			math.max(0, safe.right - rightMargin) / uiScale -- 137
		), -- 137
		top = 0, -- 138
		bottom = 0 -- 139
	} -- 139
	return { -- 142
		fullW = w, -- 143
		fullH = h, -- 144
		stageX = stageX, -- 145
		stageY = stageY, -- 146
		stageW = stageW, -- 147
		stageH = stageH, -- 148
		deckH = stageY, -- 149
		topBarH = topBarH, -- 150
		isPortrait = true, -- 151
		uiScale = uiScale, -- 152
		uiW = stageW / uiScale, -- 153
		uiH = stageH / uiScale, -- 154
		safe = safe, -- 155
		safeUi = safeUi -- 156
	} -- 156
end -- 93
--- 将全屏 View 坐标（左下原点）换算为主舞台局部坐标。
function ____exports.viewToStage(viewX, viewY, vp) -- 161
	local x = viewX - vp.stageX -- 166
	local y = viewY - vp.stageY -- 167
	return {x = x, y = y, inside = x >= 0 and x <= vp.stageW and y >= 0 and y <= vp.stageH} -- 168
end -- 161
return ____exports -- 161
