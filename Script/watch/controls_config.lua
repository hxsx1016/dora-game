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
____exports.TOUCH_OPACITY_STEPS = TOUCH_OPACITY_STEPS -- 24
____exports.TOUCH_SCALE_STEPS = TOUCH_SCALE_STEPS -- 25
____exports.VOLUME_STEPS = VOLUME_STEPS -- 26
____exports.MODE_PREF_ORDER = {"auto", "kbm", "touch", "gamepad"} -- 29
local DEFAULT_CONTROLS_FILE = "watch-save/controls.txt" -- 31
local LEGACY_TOUCH_FILE = "watch-save/touch.txt" -- 32
local LEGACY_GAMEPAD_FILE = "watch-save/gamepad.txt" -- 33
local customControlsFile = "" -- 35
function ____exports.setControlSettingsFile(path) -- 37
	customControlsFile = path -- 38
end -- 37
function ____exports.getControlSettingsFile() -- 41
	return customControlsFile ~= "" and customControlsFile or DEFAULT_CONTROLS_FILE -- 42
end -- 41
local function isAbsolutePath(p) -- 45
	if #p == 0 then -- 46
		return false -- 46
	end -- 46
	if string.sub(p, 1, 1) == "/" or string.sub(p, 1, 1) == "\\" then -- 47
		return true -- 47
	end -- 47
	return #p >= 2 and string.sub(p, 2, 2) == ":" -- 48
end -- 45
local function resolvePath(rel) -- 51
	if isAbsolutePath(rel) then -- 52
		return rel -- 53
	end -- 53
	local base = Content.writablePath -- 55
	local sep = (string.find(base, "\\", nil, true) or 0) - 1 >= 0 and (string.find(base, "/", nil, true) or 0) - 1 < 0 and "\\" or "/" -- 56
	local normRel = sep == "\\" and table.concat( -- 57
		__TS__StringSplit(rel, "/"), -- 57
		"\\" -- 57
	) or rel -- 57
	local trimmed = (__TS__StringEndsWith(base, "/") or __TS__StringEndsWith(base, "\\")) and string.sub(base, 1, -2) or base -- 58
	return (trimmed .. sep) .. normRel -- 59
end -- 51
local function parentDirOf(p) -- 62
	local i = #p - 1 -- 63
	do -- 63
		while i >= 0 do -- 64
			local ch = __TS__StringCharAt(p, i) -- 65
			if ch == "/" or ch == "\\" then -- 66
				return __TS__StringSlice(p, 0, i) -- 67
			end -- 67
			i = i - 1 -- 64
		end -- 64
	end -- 64
	return "" -- 70
end -- 62
function ____exports.defaultControlSettings() -- 73
	return { -- 74
		modePref = "auto", -- 75
		aimAssist = true, -- 76
		crouchToggle = false, -- 77
		gamepadLayout = "xbox", -- 78
		deadzoneLeft = 0.22, -- 79
		deadzoneRight = 0.18, -- 80
		touchOpacity = 0.78, -- 81
		touchScale = 1, -- 82
		haptics = true, -- 83
		masterVol = 1, -- 84
		bgmVol = 0.8, -- 85
		sfxVol = 0.9, -- 86
		voiceVol = 1 -- 87
	} -- 87
end -- 73
local function applyKvLines(raw, out) -- 91
	local lines = __TS__StringSplit(raw, "\n") -- 92
	local i = 0 -- 93
	do -- 93
		i = 0 -- 94
		while i < #lines do -- 94
			do -- 94
				local line = __TS__StringTrim(lines[i + 1]) -- 95
				local eq = (string.find(line, "=", nil, true) or 0) - 1 -- 96
				if eq <= 0 then -- 97
					goto __continue16 -- 97
				end -- 97
				local k = __TS__StringSlice(line, 0, eq) -- 98
				local v = __TS__StringSlice(line, eq + 1) -- 99
				if k == "modePref" then -- 100
					if v == "auto" or v == "kbm" or v == "touch" or v == "gamepad" then -- 101
						out.modePref = v -- 102
					end -- 102
				elseif k == "aimAssist" then -- 104
					out.aimAssist = v == "1" or v == "true" -- 105
				elseif k == "crouchToggle" then -- 106
					out.crouchToggle = v == "1" or v == "true" -- 107
				elseif k == "gamepadLayout" or k == "layout" then -- 108
					out.gamepadLayout = v == "nintendo" and "nintendo" or "xbox" -- 109
				elseif k == "deadzoneLeft" then -- 110
					local n = __TS__Number(v) -- 111
					if n >= 0.08 and n <= 0.45 then -- 112
						out.deadzoneLeft = n -- 112
					end -- 112
				elseif k == "deadzoneRight" then -- 113
					local n = __TS__Number(v) -- 114
					if n >= 0.08 and n <= 0.45 then -- 115
						out.deadzoneRight = n -- 115
					end -- 115
				elseif k == "touchOpacity" or k == "opacity" then -- 116
					local n = __TS__Number(v) -- 117
					if n >= 0.3 and n <= 1 then -- 118
						out.touchOpacity = n -- 118
					end -- 118
				elseif k == "touchScale" or k == "scale" then -- 119
					local n = __TS__Number(v) -- 120
					if n >= 0.75 and n <= 1.35 then -- 121
						out.touchScale = n -- 121
					end -- 121
				elseif k == "haptics" then -- 122
					out.haptics = v == "1" or v == "true" -- 123
				elseif k == "masterVol" then -- 124
					local n = __TS__Number(v) -- 125
					if n >= 0 and n <= 1 then -- 126
						out.masterVol = n -- 126
					end -- 126
				elseif k == "bgmVol" then -- 127
					local n = __TS__Number(v) -- 128
					if n >= 0 and n <= 1 then -- 129
						out.bgmVol = n -- 129
					end -- 129
				elseif k == "sfxVol" then -- 130
					local n = __TS__Number(v) -- 131
					if n >= 0 and n <= 1 then -- 132
						out.sfxVol = n -- 132
					end -- 132
				elseif k == "voiceVol" then -- 133
					local n = __TS__Number(v) -- 134
					if n >= 0 and n <= 1 then -- 135
						out.voiceVol = n -- 135
					end -- 135
				end -- 135
			end -- 135
			::__continue16:: -- 135
			i = i + 1 -- 94
		end -- 94
	end -- 94
end -- 91
function ____exports.loadControlSettings() -- 140
	local out = ____exports.defaultControlSettings() -- 141
	do -- 141
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 141
			local mainPath = resolvePath(____exports.getControlSettingsFile()) -- 143
			if Content:exist(mainPath) then -- 144
				local raw = Content:load(mainPath) -- 145
				if raw ~= nil and raw ~= "" then -- 146
					applyKvLines(raw, out) -- 147
				end -- 147
				return true, out -- 149
			end -- 149
			if customControlsFile == "" then -- 151
				local legacyTouch = resolvePath(LEGACY_TOUCH_FILE) -- 152
				if Content:exist(legacyTouch) then -- 153
					local raw = Content:load(legacyTouch) -- 154
					if raw ~= nil and raw ~= "" then -- 155
						applyKvLines(raw, out) -- 156
					end -- 156
				end -- 156
				local legacyGamepad = resolvePath(LEGACY_GAMEPAD_FILE) -- 159
				if Content:exist(legacyGamepad) then -- 160
					local raw = Content:load(legacyGamepad) -- 161
					if raw ~= nil and raw ~= "" then -- 162
						applyKvLines(raw, out) -- 163
					end -- 163
				end -- 163
			end -- 163
		end) -- 163
		if ____try and ____hasReturned then -- 163
			return ____returnValue -- 142
		end -- 142
	end -- 142
	return out -- 170
end -- 140
function ____exports.saveControlSettings(s) -- 173
	do -- 173
		pcall(function() -- 173
			local target = resolvePath(____exports.getControlSettingsFile()) -- 175
			local dir = parentDirOf(target) -- 176
			if dir ~= "" and not Content:exist(dir) then -- 177
				Content:mkdir(dir) -- 178
			end -- 178
			local text = ((((((((((((((((((((((((((((((((((((("modePref=" .. s.modePref) .. "\n") .. "aimAssist=") .. (s.aimAssist and "1" or "0")) .. "\n") .. "crouchToggle=") .. (s.crouchToggle and "1" or "0")) .. "\n") .. "gamepadLayout=") .. s.gamepadLayout) .. "\n") .. "deadzoneLeft=") .. __TS__NumberToFixed(s.deadzoneLeft, 2)) .. "\n") .. "deadzoneRight=") .. __TS__NumberToFixed(s.deadzoneRight, 2)) .. "\n") .. "touchOpacity=") .. __TS__NumberToFixed(s.touchOpacity, 2)) .. "\n") .. "touchScale=") .. __TS__NumberToFixed(s.touchScale, 2)) .. "\n") .. "haptics=") .. (s.haptics and "1" or "0")) .. "\n") .. "masterVol=") .. __TS__NumberToFixed(s.masterVol, 2)) .. "\n") .. "bgmVol=") .. __TS__NumberToFixed(s.bgmVol, 2)) .. "\n") .. "sfxVol=") .. __TS__NumberToFixed(s.sfxVol, 2)) .. "\n") .. "voiceVol=") .. __TS__NumberToFixed(s.voiceVol, 2)) .. "\n" -- 180
			Content:save(target, text) -- 194
		end) -- 194
	end -- 194
end -- 173
function ____exports.nextPrefInList(cur, list, delta) -- 200
	if delta == nil then -- 200
		delta = 1 -- 200
	end -- 200
	if #list == 0 then -- 201
		return "auto" -- 201
	end -- 201
	local idx = __TS__ArrayIndexOf(list, cur) -- 202
	local base = idx >= 0 and idx or 0 -- 203
	local len = #list -- 204
	return list[(base + delta + len) % len + 1] -- 205
end -- 200
function ____exports.nextModePref(cur, delta) -- 208
	if delta == nil then -- 208
		delta = 1 -- 208
	end -- 208
	return ____exports.nextPrefInList(cur, ____exports.MODE_PREF_ORDER, delta) -- 209
end -- 208
function ____exports.nextStepValue(cur, steps, delta) -- 212
	if delta == nil then -- 212
		delta = 1 -- 212
	end -- 212
	local bestIdx = 0 -- 213
	local bestDist = 999 -- 214
	local i = 0 -- 215
	do -- 215
		i = 0 -- 216
		while i < #steps do -- 216
			local d = math.abs(steps[i + 1] - cur) -- 217
			if d < bestDist then -- 218
				bestDist = d -- 219
				bestIdx = i -- 220
			end -- 220
			i = i + 1 -- 216
		end -- 216
	end -- 216
	local len = #steps -- 223
	return steps[(bestIdx + delta + len) % len + 1] -- 224
end -- 212
function ____exports.modePrefLabelOf(pref) -- 227
	if pref == "kbm" then -- 228
		return "键鼠" -- 228
	end -- 228
	if pref == "touch" then -- 229
		return "触屏" -- 229
	end -- 229
	if pref == "gamepad" then -- 230
		return "手柄" -- 230
	end -- 230
	return "自动" -- 231
end -- 227
function ____exports.inputModeLabelOf(mode) -- 234
	if mode == "touch" then -- 235
		return "触屏" -- 235
	end -- 235
	if mode == "gamepad" then -- 236
		return "手柄" -- 236
	end -- 236
	return "键鼠" -- 237
end -- 234
function ____exports.layoutLabelOf(layout) -- 240
	return layout == "nintendo" and "日系 B确认" or "标准 A确认" -- 241
end -- 240
function ____exports.opacityLabelOf(opacity) -- 244
	if opacity <= 0.62 then -- 245
		return "轻" -- 245
	end -- 245
	if opacity >= 0.88 then -- 246
		return "浓" -- 246
	end -- 246
	return "中" -- 247
end -- 244
function ____exports.scaleLabelOf(scale) -- 250
	if scale <= 0.93 then -- 251
		return "小" -- 251
	end -- 251
	if scale >= 1.07 then -- 252
		return "大" -- 252
	end -- 252
	return "中" -- 253
end -- 250
function ____exports.volumeLabelOf(vol) -- 256
	local pct = math.floor(math.max( -- 257
		0, -- 257
		math.min(1, vol) -- 257
	) * 100 + 0.5) -- 257
	return pct <= 0 and "静音" or tostring(pct) .. "%" -- 258
end -- 256
function ____exports.applyVolumeSetting(rowId, delta, s) -- 261
	if rowId == "masterVol" then -- 266
		s.masterVol = ____exports.nextStepValue(s.masterVol, VOLUME_STEPS, delta) -- 267
		____exports.saveControlSettings(s) -- 268
		return true -- 269
	end -- 269
	if rowId == "bgmVol" then -- 271
		s.bgmVol = ____exports.nextStepValue(s.bgmVol, VOLUME_STEPS, delta) -- 272
		____exports.saveControlSettings(s) -- 273
		return true -- 274
	end -- 274
	if rowId == "sfxVol" then -- 276
		s.sfxVol = ____exports.nextStepValue(s.sfxVol, VOLUME_STEPS, delta) -- 277
		____exports.saveControlSettings(s) -- 278
		return true -- 279
	end -- 279
	if rowId == "voiceVol" then -- 281
		s.voiceVol = ____exports.nextStepValue(s.voiceVol, VOLUME_STEPS, delta) -- 282
		____exports.saveControlSettings(s) -- 283
		return true -- 284
	end -- 284
	return false -- 286
end -- 261
function ____exports.volumeSettingText(rowId, s) -- 289
	if rowId == "masterVol" then -- 290
		return ____exports.volumeLabelOf(s.masterVol) -- 290
	end -- 290
	if rowId == "bgmVol" then -- 291
		return ____exports.volumeLabelOf(s.bgmVol) -- 291
	end -- 291
	if rowId == "sfxVol" then -- 292
		return ____exports.volumeLabelOf(s.sfxVol) -- 292
	end -- 292
	if rowId == "voiceVol" then -- 293
		return ____exports.volumeLabelOf(s.voiceVol) -- 293
	end -- 293
	return "" -- 294
end -- 289
return ____exports -- 289
