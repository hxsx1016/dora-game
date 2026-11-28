-- [ts]: controls_config.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local Content = ____Dora.Content -- 8
local ____target_types = require("Script.watch.target_types") -- 9
local TOUCH_OPACITY_STEPS = ____target_types.TOUCH_OPACITY_STEPS -- 14
local TOUCH_SCALE_STEPS = ____target_types.TOUCH_SCALE_STEPS -- 15
local VOLUME_STEPS = ____target_types.VOLUME_STEPS -- 16
local getReleaseConfig = ____target_types.getReleaseConfig -- 17
____exports.TOUCH_OPACITY_STEPS = TOUCH_OPACITY_STEPS -- 25
____exports.TOUCH_SCALE_STEPS = TOUCH_SCALE_STEPS -- 26
____exports.VOLUME_STEPS = VOLUME_STEPS -- 27
____exports.MODE_PREF_ORDER = {"auto", "kbm", "touch", "gamepad"} -- 30
local DEFAULT_CONTROLS_FILE = "watch-save/controls.txt" -- 32
local PORTABLE_SETTINGS_FILE = "settings.ini" -- 33
local LEGACY_TOUCH_FILE = "watch-save/touch.txt" -- 34
local LEGACY_GAMEPAD_FILE = "watch-save/gamepad.txt" -- 35
local customControlsFile = "" -- 37
local function isPortableLayout() -- 39
	local cfg = getReleaseConfig() -- 40
	return cfg ~= nil and cfg.saveLayout == "portable" -- 41
end -- 39
function ____exports.setControlSettingsFile(path) -- 44
	customControlsFile = path -- 45
end -- 44
function ____exports.getControlSettingsFile() -- 48
	if customControlsFile ~= "" then -- 48
		return customControlsFile -- 50
	end -- 50
	return isPortableLayout() and PORTABLE_SETTINGS_FILE or DEFAULT_CONTROLS_FILE -- 52
end -- 48
local function isAbsolutePath(p) -- 55
	if #p == 0 then -- 55
		return false -- 56
	end -- 56
	if string.sub(p, 1, 1) == "/" or string.sub(p, 1, 1) == "\\" then -- 56
		return true -- 57
	end -- 57
	return #p >= 2 and string.sub(p, 2, 2) == ":" -- 58
end -- 55
local function resolvePath(rel) -- 61
	if isAbsolutePath(rel) then -- 61
		return rel -- 63
	end -- 63
	local base = Content.writablePath -- 65
	local sep = (string.find(base, "\\", nil, true) or 0) - 1 >= 0 and (string.find(base, "/", nil, true) or 0) - 1 < 0 and "\\" or "/" -- 66
	local normRel = sep == "\\" and table.concat( -- 67
		__TS__StringSplit(rel, "/"), -- 67
		"\\" -- 67
	) or rel -- 67
	local trimmed = (__TS__StringEndsWith(base, "/") or __TS__StringEndsWith(base, "\\")) and string.sub(base, 1, -2) or base -- 68
	return (trimmed .. sep) .. normRel -- 69
end -- 61
local function parentDirOf(p) -- 72
	local i = #p - 1 -- 73
	do -- 73
		while i >= 0 do -- 73
			local ch = __TS__StringCharAt(p, i) -- 75
			if ch == "/" or ch == "\\" then -- 75
				return __TS__StringSlice(p, 0, i) -- 77
			end -- 77
			i = i - 1 -- 74
		end -- 74
	end -- 74
	return "" -- 80
end -- 72
function ____exports.defaultControlSettings() -- 83
	return { -- 84
		modePref = "auto", -- 85
		aimAssist = true, -- 86
		crouchToggle = false, -- 87
		gamepadLayout = "xbox", -- 88
		deadzoneLeft = 0.22, -- 89
		deadzoneRight = 0.18, -- 90
		touchOpacity = 0.78, -- 91
		touchScale = 1, -- 92
		haptics = true, -- 93
		masterVol = 1, -- 94
		bgmVol = 0.8, -- 95
		sfxVol = 0.9, -- 96
		voiceVol = 1, -- 97
		fullscreen = false, -- 98
		winWidth = 0, -- 99
		winHeight = 0, -- 100
		muted = false, -- 101
		assistHints = false -- 102
	} -- 102
end -- 83
local function applyKvLines(raw, out) -- 106
	local lines = __TS__StringSplit(raw, "\n") -- 107
	local i = 0 -- 108
	do -- 108
		i = 0 -- 109
		while i < #lines do -- 109
			do -- 109
				local line = __TS__StringTrim(lines[i + 1]) -- 110
				if line == "" or string.sub(line, 1, 1) == "#" or string.sub(line, 1, 1) == ";" then -- 110
					goto __continue18 -- 111
				end -- 111
				local eq = (string.find(line, "=", nil, true) or 0) - 1 -- 112
				if eq <= 0 then -- 112
					goto __continue18 -- 113
				end -- 113
				local k = __TS__StringTrim(__TS__StringSlice(line, 0, eq)) -- 114
				local v = __TS__StringTrim(__TS__StringSlice(line, eq + 1)) -- 115
				if k == "modePref" then -- 115
					if v == "auto" or v == "kbm" or v == "touch" or v == "gamepad" then -- 115
						out.modePref = v -- 118
					end -- 118
				elseif k == "aimAssist" then -- 118
					out.aimAssist = v == "1" or v == "true" -- 121
				elseif k == "crouchToggle" then -- 121
					out.crouchToggle = v == "1" or v == "true" -- 123
				elseif k == "gamepadLayout" or k == "layout" then -- 123
					out.gamepadLayout = v == "nintendo" and "nintendo" or "xbox" -- 125
				elseif k == "deadzoneLeft" then -- 125
					local n = __TS__Number(v) -- 127
					if n >= 0.08 and n <= 0.45 then -- 127
						out.deadzoneLeft = n -- 128
					end -- 128
				elseif k == "deadzoneRight" then -- 128
					local n = __TS__Number(v) -- 130
					if n >= 0.08 and n <= 0.45 then -- 130
						out.deadzoneRight = n -- 131
					end -- 131
				elseif k == "touchOpacity" or k == "opacity" then -- 131
					local n = __TS__Number(v) -- 133
					if n >= 0.3 and n <= 1 then -- 133
						out.touchOpacity = n -- 134
					end -- 134
				elseif k == "touchScale" or k == "scale" then -- 134
					local n = __TS__Number(v) -- 136
					if n >= 0.75 and n <= 1.35 then -- 136
						out.touchScale = n -- 137
					end -- 137
				elseif k == "haptics" then -- 137
					out.haptics = v == "1" or v == "true" -- 139
				elseif k == "masterVol" then -- 139
					local n = __TS__Number(v) -- 141
					if n >= 0 and n <= 1 then -- 141
						out.masterVol = n -- 142
					end -- 142
				elseif k == "bgmVol" then -- 142
					local n = __TS__Number(v) -- 144
					if n >= 0 and n <= 1 then -- 144
						out.bgmVol = n -- 145
					end -- 145
				elseif k == "sfxVol" then -- 145
					local n = __TS__Number(v) -- 147
					if n >= 0 and n <= 1 then -- 147
						out.sfxVol = n -- 148
					end -- 148
				elseif k == "voiceVol" then -- 148
					local n = __TS__Number(v) -- 150
					if n >= 0 and n <= 1 then -- 150
						out.voiceVol = n -- 151
					end -- 151
				elseif k == "fullscreen" then -- 151
					out.fullscreen = v == "1" or v == "true" -- 153
				elseif k == "winWidth" then -- 153
					local n = math.floor(__TS__Number(v) + 0.5) -- 155
					if n >= 640 and n <= 7680 then -- 155
						out.winWidth = n -- 156
					end -- 156
				elseif k == "winHeight" then -- 156
					local n = math.floor(__TS__Number(v) + 0.5) -- 158
					if n >= 360 and n <= 4320 then -- 158
						out.winHeight = n -- 159
					end -- 159
				elseif k == "muted" then -- 159
					out.muted = v == "1" or v == "true" -- 161
				elseif k == "assistHints" then -- 161
					out.assistHints = v == "1" or v == "true" -- 163
				end -- 163
			end -- 163
			::__continue18:: -- 163
			i = i + 1 -- 109
		end -- 109
	end -- 109
end -- 106
function ____exports.loadControlSettings() -- 168
	local out = ____exports.defaultControlSettings() -- 169
	do -- 169
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 169
			local mainPath = resolvePath(____exports.getControlSettingsFile()) -- 171
			if Content:exist(mainPath) then -- 171
				local raw = Content:load(mainPath) -- 173
				if raw ~= nil and raw ~= "" then -- 173
					applyKvLines(raw, out) -- 175
				end -- 175
				return true, out -- 177
			end -- 177
			local tmpPath = mainPath .. ".tmp" -- 179
			if Content:exist(tmpPath) then -- 179
				local raw = Content:load(tmpPath) -- 181
				if raw ~= nil and raw ~= "" then -- 181
					applyKvLines(raw, out) -- 183
					return true, out -- 184
				end -- 184
			end -- 184
			if customControlsFile == "" then -- 184
				if isPortableLayout() then -- 184
					local legacyControls = resolvePath(DEFAULT_CONTROLS_FILE) -- 189
					if Content:exist(legacyControls) then -- 189
						local raw = Content:load(legacyControls) -- 191
						if raw ~= nil and raw ~= "" then -- 191
							applyKvLines(raw, out) -- 193
							return true, out -- 194
						end -- 194
					end -- 194
				end -- 194
				local legacyTouch = resolvePath(LEGACY_TOUCH_FILE) -- 198
				if Content:exist(legacyTouch) then -- 198
					local raw = Content:load(legacyTouch) -- 200
					if raw ~= nil and raw ~= "" then -- 200
						applyKvLines(raw, out) -- 202
					end -- 202
				end -- 202
				local legacyGamepad = resolvePath(LEGACY_GAMEPAD_FILE) -- 205
				if Content:exist(legacyGamepad) then -- 205
					local raw = Content:load(legacyGamepad) -- 207
					if raw ~= nil and raw ~= "" then -- 207
						applyKvLines(raw, out) -- 209
					end -- 209
				end -- 209
			end -- 209
		end) -- 209
		if ____try and ____hasReturned then -- 209
			return ____returnValue -- 170
		end -- 170
	end -- 170
	return out -- 216
end -- 168
function ____exports.saveControlSettings(s) -- 219
	do -- 219
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 219
			local target = resolvePath(____exports.getControlSettingsFile()) -- 221
			local dir = parentDirOf(target) -- 222
			if dir ~= "" and not Content:exist(dir) then -- 222
				Content:mkdir(dir) -- 224
			end -- 224
			local text = (((((((((((((((((((((((((((((((((((((((((((((((((((("modePref=" .. s.modePref) .. "\n") .. "aimAssist=") .. (s.aimAssist and "1" or "0")) .. "\n") .. "crouchToggle=") .. (s.crouchToggle and "1" or "0")) .. "\n") .. "gamepadLayout=") .. s.gamepadLayout) .. "\n") .. "deadzoneLeft=") .. __TS__NumberToFixed(s.deadzoneLeft, 2)) .. "\n") .. "deadzoneRight=") .. __TS__NumberToFixed(s.deadzoneRight, 2)) .. "\n") .. "touchOpacity=") .. __TS__NumberToFixed(s.touchOpacity, 2)) .. "\n") .. "touchScale=") .. __TS__NumberToFixed(s.touchScale, 2)) .. "\n") .. "haptics=") .. (s.haptics and "1" or "0")) .. "\n") .. "masterVol=") .. __TS__NumberToFixed(s.masterVol, 2)) .. "\n") .. "bgmVol=") .. __TS__NumberToFixed(s.bgmVol, 2)) .. "\n") .. "sfxVol=") .. __TS__NumberToFixed(s.sfxVol, 2)) .. "\n") .. "voiceVol=") .. __TS__NumberToFixed(s.voiceVol, 2)) .. "\n") .. "fullscreen=") .. (s.fullscreen and "1" or "0")) .. "\n") .. "winWidth=") .. tostring(math.floor(s.winWidth + 0.5))) .. "\n") .. "winHeight=") .. tostring(math.floor(s.winHeight + 0.5))) .. "\n") .. "muted=") .. (s.muted and "1" or "0")) .. "\n") .. "assistHints=") .. (s.assistHints and "1" or "0")) .. "\n" -- 226
			local tmp = target .. ".tmp" -- 245
			if Content:save(tmp, text) then -- 245
				local readBack = Content:load(tmp) -- 247
				if readBack ~= nil and table.concat( -- 247
					__TS__StringSplit(readBack, "\r\n"), -- 248
					"\n" -- 248
				) == text then -- 248
					if Content:copy(tmp, target) then -- 248
						Content:remove(tmp) -- 250
						return true -- 251
					end -- 251
				end -- 251
				Content:remove(tmp) -- 254
			end -- 254
			Content:save(target, text) -- 256
		end) -- 256
		if ____try and ____hasReturned then -- 256
			return ____returnValue -- 220
		end -- 220
	end -- 220
end -- 219
function ____exports.nextPrefInList(cur, list, delta) -- 262
	if delta == nil then -- 262
		delta = 1 -- 262
	end -- 262
	if #list == 0 then -- 262
		return "auto" -- 263
	end -- 263
	local idx = __TS__ArrayIndexOf(list, cur) -- 264
	local base = idx >= 0 and idx or 0 -- 265
	local len = #list -- 266
	return list[(base + delta + len) % len + 1] -- 267
end -- 262
function ____exports.nextModePref(cur, delta) -- 270
	if delta == nil then -- 270
		delta = 1 -- 270
	end -- 270
	return ____exports.nextPrefInList(cur, ____exports.MODE_PREF_ORDER, delta) -- 271
end -- 270
function ____exports.nextStepValue(cur, steps, delta) -- 274
	if delta == nil then -- 274
		delta = 1 -- 274
	end -- 274
	local bestIdx = 0 -- 275
	local bestDist = 999 -- 276
	local i = 0 -- 277
	do -- 277
		i = 0 -- 278
		while i < #steps do -- 278
			local d = math.abs(steps[i + 1] - cur) -- 279
			if d < bestDist then -- 279
				bestDist = d -- 281
				bestIdx = i -- 282
			end -- 282
			i = i + 1 -- 278
		end -- 278
	end -- 278
	local len = #steps -- 285
	return steps[(bestIdx + delta + len) % len + 1] -- 286
end -- 274
function ____exports.modePrefLabelOf(pref) -- 289
	if pref == "kbm" then -- 289
		return "键鼠" -- 290
	end -- 290
	if pref == "touch" then -- 290
		return "触屏" -- 291
	end -- 291
	if pref == "gamepad" then -- 291
		return "手柄" -- 292
	end -- 292
	return "自动" -- 293
end -- 289
function ____exports.inputModeLabelOf(mode) -- 296
	if mode == "touch" then -- 296
		return "触屏" -- 297
	end -- 297
	if mode == "gamepad" then -- 297
		return "手柄" -- 298
	end -- 298
	return "键鼠" -- 299
end -- 296
function ____exports.layoutLabelOf(layout) -- 302
	return layout == "nintendo" and "日系 B确认" or "标准 A确认" -- 303
end -- 302
function ____exports.opacityLabelOf(opacity) -- 306
	if opacity <= 0.62 then -- 306
		return "轻" -- 307
	end -- 307
	if opacity >= 0.88 then -- 307
		return "浓" -- 308
	end -- 308
	return "中" -- 309
end -- 306
function ____exports.scaleLabelOf(scale) -- 312
	if scale <= 0.93 then -- 312
		return "小" -- 313
	end -- 313
	if scale >= 1.07 then -- 313
		return "大" -- 314
	end -- 314
	return "中" -- 315
end -- 312
function ____exports.volumeLabelOf(vol) -- 318
	local pct = math.floor(math.max( -- 319
		0, -- 319
		math.min(1, vol) -- 319
	) * 100 + 0.5) -- 319
	return pct <= 0 and "静音" or tostring(pct) .. "%" -- 320
end -- 318
function ____exports.applyVolumeSetting(rowId, delta, s) -- 323
	if rowId == "masterVol" then -- 323
		s.masterVol = ____exports.nextStepValue(s.masterVol, VOLUME_STEPS, delta) -- 329
		____exports.saveControlSettings(s) -- 330
		return true -- 331
	end -- 331
	if rowId == "bgmVol" then -- 331
		s.bgmVol = ____exports.nextStepValue(s.bgmVol, VOLUME_STEPS, delta) -- 334
		____exports.saveControlSettings(s) -- 335
		return true -- 336
	end -- 336
	if rowId == "sfxVol" then -- 336
		s.sfxVol = ____exports.nextStepValue(s.sfxVol, VOLUME_STEPS, delta) -- 339
		____exports.saveControlSettings(s) -- 340
		return true -- 341
	end -- 341
	if rowId == "voiceVol" then -- 341
		s.voiceVol = ____exports.nextStepValue(s.voiceVol, VOLUME_STEPS, delta) -- 344
		____exports.saveControlSettings(s) -- 345
		return true -- 346
	end -- 346
	return false -- 348
end -- 323
function ____exports.volumeSettingText(rowId, s) -- 351
	if rowId == "masterVol" then -- 351
		return ____exports.volumeLabelOf(s.masterVol) -- 352
	end -- 352
	if rowId == "bgmVol" then -- 352
		return ____exports.volumeLabelOf(s.bgmVol) -- 353
	end -- 353
	if rowId == "sfxVol" then -- 353
		return ____exports.volumeLabelOf(s.sfxVol) -- 354
	end -- 354
	if rowId == "voiceVol" then -- 354
		return ____exports.volumeLabelOf(s.voiceVol) -- 355
	end -- 355
	return "" -- 356
end -- 351
return ____exports -- 351