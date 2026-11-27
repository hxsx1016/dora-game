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
local ____Dora = require("Dora") -- 10
local Content = ____Dora.Content -- 10
____exports.MODE_PREF_ORDER = {"auto", "kbm", "touch", "gamepad"} -- 45
____exports.TOUCH_OPACITY_STEPS = {0.52, 0.78, 0.96} -- 46
____exports.TOUCH_SCALE_STEPS = {0.88, 1, 1.14} -- 47
____exports.VOLUME_STEPS = { -- 48
	0, -- 48
	0.1, -- 48
	0.2, -- 48
	0.3, -- 48
	0.4, -- 48
	0.5, -- 48
	0.6, -- 48
	0.7, -- 48
	0.8, -- 48
	0.9, -- 48
	1 -- 48
} -- 48
local DEFAULT_CONTROLS_FILE = "watch-save/controls.txt" -- 50
local LEGACY_TOUCH_FILE = "watch-save/touch.txt" -- 51
local LEGACY_GAMEPAD_FILE = "watch-save/gamepad.txt" -- 52
local customControlsFile = "" -- 54
function ____exports.setControlSettingsFile(path) -- 56
	customControlsFile = path -- 57
end -- 56
function ____exports.getControlSettingsFile() -- 60
	return customControlsFile ~= "" and customControlsFile or DEFAULT_CONTROLS_FILE -- 61
end -- 60
local function isAbsolutePath(p) -- 64
	if #p == 0 then -- 64
		return false -- 65
	end -- 65
	if string.sub(p, 1, 1) == "/" or string.sub(p, 1, 1) == "\\" then -- 65
		return true -- 66
	end -- 66
	return #p >= 2 and string.sub(p, 2, 2) == ":" -- 67
end -- 64
local function resolvePath(rel) -- 70
	if isAbsolutePath(rel) then -- 70
		return rel -- 72
	end -- 72
	local base = Content.writablePath -- 74
	local sep = (string.find(base, "\\", nil, true) or 0) - 1 >= 0 and (string.find(base, "/", nil, true) or 0) - 1 < 0 and "\\" or "/" -- 75
	local normRel = sep == "\\" and table.concat( -- 76
		__TS__StringSplit(rel, "/"), -- 76
		"\\" -- 76
	) or rel -- 76
	local trimmed = (__TS__StringEndsWith(base, "/") or __TS__StringEndsWith(base, "\\")) and string.sub(base, 1, -2) or base -- 77
	return (trimmed .. sep) .. normRel -- 78
end -- 70
local function parentDirOf(p) -- 81
	local i = #p - 1 -- 82
	do -- 82
		while i >= 0 do -- 82
			local ch = __TS__StringCharAt(p, i) -- 84
			if ch == "/" or ch == "\\" then -- 84
				return __TS__StringSlice(p, 0, i) -- 86
			end -- 86
			i = i - 1 -- 83
		end -- 83
	end -- 83
	return "" -- 89
end -- 81
function ____exports.defaultControlSettings() -- 92
	return { -- 93
		modePref = "auto", -- 94
		aimAssist = true, -- 95
		crouchToggle = false, -- 96
		gamepadLayout = "xbox", -- 97
		deadzoneLeft = 0.22, -- 98
		deadzoneRight = 0.18, -- 99
		touchOpacity = 0.78, -- 100
		touchScale = 1, -- 101
		haptics = true, -- 102
		masterVol = 1, -- 103
		bgmVol = 0.8, -- 104
		sfxVol = 0.9, -- 105
		voiceVol = 1 -- 106
	} -- 106
end -- 92
local function applyKvLines(raw, out) -- 110
	local lines = __TS__StringSplit(raw, "\n") -- 111
	local i = 0 -- 112
	do -- 112
		i = 0 -- 113
		while i < #lines do -- 113
			do -- 113
				local line = __TS__StringTrim(lines[i + 1]) -- 114
				local eq = (string.find(line, "=", nil, true) or 0) - 1 -- 115
				if eq <= 0 then -- 115
					goto __continue16 -- 116
				end -- 116
				local k = __TS__StringSlice(line, 0, eq) -- 117
				local v = __TS__StringSlice(line, eq + 1) -- 118
				if k == "modePref" then -- 118
					if v == "auto" or v == "kbm" or v == "touch" or v == "gamepad" then -- 118
						out.modePref = v -- 121
					end -- 121
				elseif k == "aimAssist" then -- 121
					out.aimAssist = v == "1" or v == "true" -- 124
				elseif k == "crouchToggle" then -- 124
					out.crouchToggle = v == "1" or v == "true" -- 126
				elseif k == "gamepadLayout" or k == "layout" then -- 126
					out.gamepadLayout = v == "nintendo" and "nintendo" or "xbox" -- 128
				elseif k == "deadzoneLeft" then -- 128
					local n = __TS__Number(v) -- 130
					if n >= 0.08 and n <= 0.45 then -- 130
						out.deadzoneLeft = n -- 131
					end -- 131
				elseif k == "deadzoneRight" then -- 131
					local n = __TS__Number(v) -- 133
					if n >= 0.08 and n <= 0.45 then -- 133
						out.deadzoneRight = n -- 134
					end -- 134
				elseif k == "touchOpacity" or k == "opacity" then -- 134
					local n = __TS__Number(v) -- 136
					if n >= 0.3 and n <= 1 then -- 136
						out.touchOpacity = n -- 137
					end -- 137
				elseif k == "touchScale" or k == "scale" then -- 137
					local n = __TS__Number(v) -- 139
					if n >= 0.75 and n <= 1.35 then -- 139
						out.touchScale = n -- 140
					end -- 140
				elseif k == "haptics" then -- 140
					out.haptics = v == "1" or v == "true" -- 142
				elseif k == "masterVol" then -- 142
					local n = __TS__Number(v) -- 144
					if n >= 0 and n <= 1 then -- 144
						out.masterVol = n -- 145
					end -- 145
				elseif k == "bgmVol" then -- 145
					local n = __TS__Number(v) -- 147
					if n >= 0 and n <= 1 then -- 147
						out.bgmVol = n -- 148
					end -- 148
				elseif k == "sfxVol" then -- 148
					local n = __TS__Number(v) -- 150
					if n >= 0 and n <= 1 then -- 150
						out.sfxVol = n -- 151
					end -- 151
				elseif k == "voiceVol" then -- 151
					local n = __TS__Number(v) -- 153
					if n >= 0 and n <= 1 then -- 153
						out.voiceVol = n -- 154
					end -- 154
				end -- 154
			end -- 154
			::__continue16:: -- 154
			i = i + 1 -- 113
		end -- 113
	end -- 113
end -- 110
function ____exports.loadControlSettings() -- 159
	local out = ____exports.defaultControlSettings() -- 160
	do -- 160
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 160
			local mainPath = resolvePath(____exports.getControlSettingsFile()) -- 162
			if Content:exist(mainPath) then -- 162
				local raw = Content:load(mainPath) -- 164
				if raw ~= nil and raw ~= "" then -- 164
					applyKvLines(raw, out) -- 166
				end -- 166
				return true, out -- 168
			end -- 168
			if customControlsFile == "" then -- 168
				local legacyTouch = resolvePath(LEGACY_TOUCH_FILE) -- 172
				if Content:exist(legacyTouch) then -- 172
					local raw = Content:load(legacyTouch) -- 174
					if raw ~= nil and raw ~= "" then -- 174
						applyKvLines(raw, out) -- 176
					end -- 176
				end -- 176
				local legacyGamepad = resolvePath(LEGACY_GAMEPAD_FILE) -- 179
				if Content:exist(legacyGamepad) then -- 179
					local raw = Content:load(legacyGamepad) -- 181
					if raw ~= nil and raw ~= "" then -- 181
						applyKvLines(raw, out) -- 183
					end -- 183
				end -- 183
			end -- 183
		end) -- 183
		if ____try and ____hasReturned then -- 183
			return ____returnValue -- 161
		end -- 161
	end -- 161
	return out -- 190
end -- 159
function ____exports.saveControlSettings(s) -- 193
	do -- 193
		pcall(function() -- 193
			local target = resolvePath(____exports.getControlSettingsFile()) -- 195
			local dir = parentDirOf(target) -- 196
			if dir ~= "" and not Content:exist(dir) then -- 196
				Content:mkdir(dir) -- 198
			end -- 198
			local text = ((((((((((((((((((((((((((((((((((((("modePref=" .. s.modePref) .. "\n") .. "aimAssist=") .. (s.aimAssist and "1" or "0")) .. "\n") .. "crouchToggle=") .. (s.crouchToggle and "1" or "0")) .. "\n") .. "gamepadLayout=") .. s.gamepadLayout) .. "\n") .. "deadzoneLeft=") .. __TS__NumberToFixed(s.deadzoneLeft, 2)) .. "\n") .. "deadzoneRight=") .. __TS__NumberToFixed(s.deadzoneRight, 2)) .. "\n") .. "touchOpacity=") .. __TS__NumberToFixed(s.touchOpacity, 2)) .. "\n") .. "touchScale=") .. __TS__NumberToFixed(s.touchScale, 2)) .. "\n") .. "haptics=") .. (s.haptics and "1" or "0")) .. "\n") .. "masterVol=") .. __TS__NumberToFixed(s.masterVol, 2)) .. "\n") .. "bgmVol=") .. __TS__NumberToFixed(s.bgmVol, 2)) .. "\n") .. "sfxVol=") .. __TS__NumberToFixed(s.sfxVol, 2)) .. "\n") .. "voiceVol=") .. __TS__NumberToFixed(s.voiceVol, 2)) .. "\n" -- 200
			Content:save(target, text) -- 214
		end) -- 214
	end -- 214
end -- 193
function ____exports.nextModePref(cur, delta) -- 220
	if delta == nil then -- 220
		delta = 1 -- 220
	end -- 220
	local idx = __TS__ArrayIndexOf(____exports.MODE_PREF_ORDER, cur) -- 221
	local base = idx >= 0 and idx or 0 -- 222
	local len = #____exports.MODE_PREF_ORDER -- 223
	return ____exports.MODE_PREF_ORDER[(base + delta + len) % len + 1] -- 224
end -- 220
function ____exports.nextStepValue(cur, steps, delta) -- 227
	if delta == nil then -- 227
		delta = 1 -- 227
	end -- 227
	local bestIdx = 0 -- 228
	local bestDist = 999 -- 229
	local i = 0 -- 230
	do -- 230
		i = 0 -- 231
		while i < #steps do -- 231
			local d = math.abs(steps[i + 1] - cur) -- 232
			if d < bestDist then -- 232
				bestDist = d -- 234
				bestIdx = i -- 235
			end -- 235
			i = i + 1 -- 231
		end -- 231
	end -- 231
	local len = #steps -- 238
	return steps[(bestIdx + delta + len) % len + 1] -- 239
end -- 227
function ____exports.modePrefLabelOf(pref) -- 242
	if pref == "kbm" then -- 242
		return "键鼠" -- 243
	end -- 243
	if pref == "touch" then -- 243
		return "触屏" -- 244
	end -- 244
	if pref == "gamepad" then -- 244
		return "手柄" -- 245
	end -- 245
	return "自动" -- 246
end -- 242
function ____exports.inputModeLabelOf(mode) -- 249
	if mode == "touch" then -- 249
		return "触屏" -- 250
	end -- 250
	if mode == "gamepad" then -- 250
		return "手柄" -- 251
	end -- 251
	return "键鼠" -- 252
end -- 249
function ____exports.layoutLabelOf(layout) -- 255
	return layout == "nintendo" and "日系 B确认" or "标准 A确认" -- 256
end -- 255
function ____exports.opacityLabelOf(opacity) -- 259
	if opacity <= 0.62 then -- 259
		return "轻" -- 260
	end -- 260
	if opacity >= 0.88 then -- 260
		return "浓" -- 261
	end -- 261
	return "中" -- 262
end -- 259
function ____exports.scaleLabelOf(scale) -- 265
	if scale <= 0.93 then -- 265
		return "小" -- 266
	end -- 266
	if scale >= 1.07 then -- 266
		return "大" -- 267
	end -- 267
	return "中" -- 268
end -- 265
function ____exports.volumeLabelOf(vol) -- 271
	local pct = math.floor(math.max( -- 272
		0, -- 272
		math.min(1, vol) -- 272
	) * 100 + 0.5) -- 272
	return pct <= 0 and "静音" or tostring(pct) .. "%" -- 273
end -- 271
return ____exports -- 271