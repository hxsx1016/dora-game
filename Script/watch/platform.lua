-- [ts]: platform.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 14
local App = ____Dora.App -- 14
local View = ____Dora.View -- 14
____exports.ZERO_SAFE_INSETS = {left = 0, right = 0, top = 0, bottom = 0} -- 26
function ____exports.getPlatformKind() -- 84
	local plat = App.platform -- 85
	if plat == "Windows" then -- 85
		return "windows" -- 86
	end -- 86
	if plat == "macOS" then -- 86
		return "macos" -- 87
	end -- 87
	if plat == "Linux" then -- 87
		return "linux" -- 88
	end -- 88
	if plat == "Android" then -- 88
		return "android" -- 89
	end -- 89
	if plat == "iOS" then -- 89
		return "ios" -- 90
	end -- 90
	if plat == "Web" then -- 90
		return "web" -- 91
	end -- 91
	return "unknown" -- 92
end -- 84
function ____exports.isWebPlatform() -- 95
	return App.platform == "Web" -- 96
end -- 95
function ____exports.isMobilePlatform() -- 99
	local plat = App.platform -- 100
	return plat == "Android" or plat == "iOS" -- 101
end -- 99
function ____exports.isDesktopNative() -- 104
	local plat = App.platform -- 105
	return plat == "Windows" or plat == "macOS" or plat == "Linux" -- 106
end -- 104
function ____exports.getReleaseConfig() -- 109
	local ____opt_0 = _G.package -- 109
	local reg = ____opt_0 and ____opt_0.loaded -- 110
	local ____temp_2 -- 111
	if reg ~= nil then -- 111
		____temp_2 = reg["watch.release"] -- 111
	else -- 111
		____temp_2 = nil -- 111
	end -- 111
	local cfg = ____temp_2 -- 111
	if cfg ~= nil and type(cfg) == "table" then -- 111
		return cfg -- 113
	end -- 113
	return nil -- 115
end -- 109
function ____exports.isStandaloneAndroidApk() -- 118
	local cfg = ____exports.getReleaseConfig() -- 119
	return App.platform == "Android" and cfg ~= nil and cfg.platform == "Android" -- 120
end -- 118
--- Web 与桌面原生支持全屏切换；移动原生端始终全屏，隐藏此项。
function ____exports.canToggleFullscreen() -- 124
	return ____exports.isDesktopNative() or ____exports.isWebPlatform() -- 125
end -- 124
--- 退出游戏能力判定：
-- - 桌面原生与独立发行 Android APK 支持并显示「退出游戏」；
-- - Web 浏览器与 Android Dora Go 源码模式隐藏该项并禁止调用 App.shutdown()，避免停死宿主。
function ____exports.canQuitApp() -- 133
	return ____exports.isDesktopNative() or ____exports.isStandaloneAndroidApk() -- 134
end -- 133
--- 发行模式判定：
-- - 显式注入 watch.release.isRelease 时以其为准；
-- - Web 平台默认启用发行保护（屏蔽 G / Tab / 1-8 调试跳房），除非显式注入 isRelease: false。
function ____exports.isReleaseMode() -- 142
	local cfg = ____exports.getReleaseConfig() -- 143
	if cfg ~= nil and cfg.isRelease ~= nil then -- 143
		return cfg.isRelease == true -- 145
	end -- 145
	return ____exports.isWebPlatform() -- 147
end -- 142
function ____exports.getPlatformCaps() -- 150
	local kind = ____exports.getPlatformKind() -- 151
	local isDesktop = ____exports.isDesktopNative() -- 152
	local isMobile = ____exports.isMobilePlatform() -- 153
	local isWeb = ____exports.isWebPlatform() -- 154
	local standaloneApk = ____exports.isStandaloneAndroidApk() -- 155
	return { -- 156
		kind = kind, -- 157
		isDesktop = isDesktop, -- 158
		isMobile = isMobile, -- 159
		isWeb = isWeb, -- 160
		isStandaloneAndroidApk = standaloneApk, -- 161
		canToggleFullscreen = isDesktop or isWeb, -- 162
		canQuit = isDesktop or standaloneApk, -- 163
		hasBackButton = kind == "android", -- 164
		supportsHaptics = isMobile and type(App.vibrate) == "function", -- 165
		needsAudioUnlock = isWeb, -- 166
		isRelease = ____exports.isReleaseMode(), -- 167
		defaultInputMode = isMobile and "touch" or "kbm" -- 168
	} -- 168
end -- 150
--- 触发短促触觉反馈（仅移动设备支持且用户开启震动时生效）。
function ____exports.triggerHaptics(seconds, enabled) -- 173
	if not enabled or not ____exports.isMobilePlatform() then -- 173
		return -- 175
	end -- 175
	if type(App.vibrate) == "function" then -- 175
		do -- 175
			pcall(function() -- 175
				App:vibrate(seconds) -- 179
			end) -- 179
		end -- 179
	end -- 179
end -- 173
--- 判断舞台是否接近 KTR1/KTR2 等紧凑非 16:9 掌机屏（3:2 或 4:3）
function ____exports.isCompactAspect(stageW, stageH) -- 187
	if stageW <= 0 or stageH <= 0 then -- 187
		return false -- 188
	end -- 188
	return stageW / stageH < 1.62 -- 189
end -- 187
--- 读取安全区内缩（容错无 safeArea 的旧引擎/测试环境，换算为 View 逻辑像素）。
function ____exports.readSafeInsets(fullW, fullH) -- 193
	if fullW <= 0 or fullH <= 0 then -- 193
		return {left = 0, right = 0, top = 0, bottom = 0} -- 195
	end -- 195
	local appObj = App -- 197
	local safe = appObj.safeArea -- 198
	local vis = appObj.visualSize -- 199
	if safe == nil or vis == nil or vis.width <= 0 or vis.height <= 0 then -- 199
		return {left = 0, right = 0, top = 0, bottom = 0} -- 201
	end -- 201
	if safe.width <= 0 or safe.height <= 0 then -- 201
		return {left = 0, right = 0, top = 0, bottom = 0} -- 204
	end -- 204
	local sx = fullW / vis.width -- 206
	local sy = fullH / vis.height -- 207
	local left = math.max( -- 208
		0, -- 208
		math.min(fullW * 0.12, safe.x * sx) -- 208
	) -- 208
	local right = math.max( -- 209
		0, -- 209
		math.min(fullW * 0.12, (vis.width - (safe.x + safe.width)) * sx) -- 209
	) -- 209
	local bottom = math.max( -- 210
		0, -- 210
		math.min(fullH * 0.12, safe.y * sy) -- 210
	) -- 210
	local top = math.max( -- 211
		0, -- 211
		math.min(fullH * 0.12, (vis.height - (safe.y + safe.height)) * sy) -- 211
	) -- 211
	return { -- 212
		left = math.floor(left + 0.5), -- 213
		right = math.floor(right + 0.5), -- 214
		top = math.floor(top + 0.5), -- 215
		bottom = math.floor(bottom + 0.5) -- 216
	} -- 216
end -- 193
--- 将 App.safeArea 换算为给定 UI 缩放下的逻辑像素内缩量（供全屏或独立面板使用）。
function ____exports.computeSafeInsets(viewW, viewH, uiScale) -- 221
	local safeScale = math.max(0.25, uiScale) -- 222
	local px = ____exports.readSafeInsets(viewW, viewH) -- 223
	return { -- 224
		left = math.min(140, px.left / safeScale), -- 225
		right = math.min(140, px.right / safeScale), -- 226
		top = math.min(90, px.top / safeScale), -- 227
		bottom = math.min(90, px.bottom / safeScale) -- 228
	} -- 228
end -- 221
--- 根据当前 View 尺寸计算主舞台与竖屏掌机区几何：
-- - 横屏（fullH <= fullW * 1.05）：舞台铺满全屏（0, 0, fullW, fullH）；
-- - 竖屏（fullH > fullW * 1.05）：上方完整 16:9 游戏画面，下方留作水墨掌机式虚拟操控台。
function ____exports.computeStageViewport(fullW, fullH) -- 237
	local w = math.max(320, fullW > 0 and fullW or View.size.width) -- 238
	local h = math.max(180, fullH > 0 and fullH or View.size.height) -- 239
	local safe = ____exports.readSafeInsets(w, h) -- 240
	local isPortrait = h > w * 1.05 -- 241
	if not isPortrait then -- 241
		local uiScale = math.max( -- 244
			0.25, -- 244
			math.min(w / 1280, h / 720) -- 244
		) -- 244
		local safeUi = { -- 245
			left = math.min(140, safe.left / uiScale), -- 246
			right = math.min(140, safe.right / uiScale), -- 247
			top = math.min(90, safe.top / uiScale), -- 248
			bottom = math.min(90, safe.bottom / uiScale) -- 249
		} -- 249
		return { -- 251
			fullW = w, -- 252
			fullH = h, -- 253
			stageX = 0, -- 254
			stageY = 0, -- 255
			stageW = w, -- 256
			stageH = h, -- 257
			deckH = 0, -- 258
			topBarH = 0, -- 259
			isPortrait = false, -- 260
			uiScale = uiScale, -- 261
			uiW = w / uiScale, -- 262
			uiH = h / uiScale, -- 263
			safe = safe, -- 264
			safeUi = safeUi -- 265
		} -- 265
	end -- 265
	local topBarH = math.max( -- 269
		safe.top + 38, -- 269
		math.min( -- 269
			68, -- 269
			math.floor(h * 0.055 + 0.5) -- 269
		) -- 269
	) -- 269
	local minDeckH = math.max( -- 270
		168, -- 270
		math.floor(h * 0.34 + 0.5) -- 270
	) -- 270
	local maxStageH = math.max(160, h - topBarH - minDeckH) -- 271
	local ideal16x9H = math.floor(w * 9 / 16 + 0.5) -- 272
	local stageH = math.min(ideal16x9H, maxStageH) -- 273
	local stageW = stageH < ideal16x9H and math.min( -- 274
		w, -- 274
		math.floor(stageH * 16 / 9 + 0.5) -- 274
	) or w -- 274
	local stageX = math.floor((w - stageW) * 0.5 + 0.5) -- 275
	local stageY = math.max(minDeckH, h - topBarH - stageH) -- 276
	local uiScale = math.max( -- 277
		0.25, -- 277
		math.min(stageW / 1280, stageH / 720) -- 277
	) -- 277
	local rightMargin = w - (stageX + stageW) -- 278
	local safeUi = { -- 279
		left = math.min( -- 280
			140, -- 280
			math.max(0, safe.left - stageX) / uiScale -- 280
		), -- 280
		right = math.min( -- 281
			140, -- 281
			math.max(0, safe.right - rightMargin) / uiScale -- 281
		), -- 281
		top = 0, -- 282
		bottom = 0 -- 283
	} -- 283
	return { -- 286
		fullW = w, -- 287
		fullH = h, -- 288
		stageX = stageX, -- 289
		stageY = stageY, -- 290
		stageW = stageW, -- 291
		stageH = stageH, -- 292
		deckH = stageY, -- 293
		topBarH = topBarH, -- 294
		isPortrait = true, -- 295
		uiScale = uiScale, -- 296
		uiW = stageW / uiScale, -- 297
		uiH = stageH / uiScale, -- 298
		safe = safe, -- 299
		safeUi = safeUi -- 300
	} -- 300
end -- 237
--- 将全屏 View 坐标（左下原点）换算为主舞台局部坐标。
function ____exports.viewToStage(viewX, viewY, vp) -- 305
	local x = viewX - vp.stageX -- 310
	local y = viewY - vp.stageY -- 311
	return {x = x, y = y, inside = x >= 0 and x <= vp.stageW and y >= 0 and y <= vp.stageH} -- 312
end -- 305
return ____exports -- 305