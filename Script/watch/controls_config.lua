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
____exports.MODE_PREF_ORDER = {"auto", "kbm", "touch", "gamepad"} -- 37
____exports.TOUCH_OPACITY_STEPS = {0.52, 0.78, 0.96} -- 38
____exports.TOUCH_SCALE_STEPS = {0.88, 1, 1.14} -- 39
local DEFAULT_CONTROLS_FILE = "watch-save/controls.txt" -- 41
local LEGACY_TOUCH_FILE = "watch-save/touch.txt" -- 42
local LEGACY_GAMEPAD_FILE = "watch-save/gamepad.txt" -- 43
local customControlsFile = "" -- 45
function ____exports.setControlSettingsFile(path) -- 47
	customControlsFile = path -- 48
end -- 47
function ____exports.getControlSettingsFile() -- 51
	return customControlsFile ~= "" and customControlsFile or DEFAULT_CONTROLS_FILE -- 52
end -- 51
local function isAbsolutePath(p) -- 55
	if #p == 0 then -- 56
		return false -- 56
	end -- 56
	if string.sub(p, 1, 1) == "/" or string.sub(p, 1, 1) == "\\" then -- 57
		return true -- 57
	end -- 57
	return #p >= 2 and string.sub(p, 2, 2) == ":" -- 58
end -- 55
local function resolvePath(rel) -- 61
	if isAbsolutePath(rel) then -- 62
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
		while i >= 0 do -- 74
			local ch = __TS__StringCharAt(p, i) -- 75
			if ch == "/" or ch == "\\" then -- 76
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
		haptics = true -- 93
	} -- 93
end -- 83
local function applyKvLines(raw, out) -- 97
	local lines = __TS__StringSplit(raw, "\n") -- 98
	local i = 0 -- 99
	do -- 99
		i = 0 -- 100
		while i < #lines do -- 100
			do -- 100
				local line = __TS__StringTrim(lines[i + 1]) -- 101
				local eq = (string.find(line, "=", nil, true) or 0) - 1 -- 102
				if eq <= 0 then -- 103
					goto __continue16 -- 103
				end -- 103
				local k = __TS__StringSlice(line, 0, eq) -- 104
				local v = __TS__StringSlice(line, eq + 1) -- 105
				if k == "modePref" then -- 106
					if v == "auto" or v == "kbm" or v == "touch" or v == "gamepad" then -- 107
						out.modePref = v -- 108
					end -- 108
				elseif k == "aimAssist" then -- 110
					out.aimAssist = v == "1" or v == "true" -- 111
				elseif k == "crouchToggle" then -- 112
					out.crouchToggle = v == "1" or v == "true" -- 113
				elseif k == "gamepadLayout" or k == "layout" then -- 114
					out.gamepadLayout = v == "nintendo" and "nintendo" or "xbox" -- 115
				elseif k == "deadzoneLeft" then -- 116
					local n = __TS__Number(v) -- 117
					if n >= 0.08 and n <= 0.45 then -- 118
						out.deadzoneLeft = n -- 118
					end -- 118
				elseif k == "deadzoneRight" then -- 119
					local n = __TS__Number(v) -- 120
					if n >= 0.08 and n <= 0.45 then -- 121
						out.deadzoneRight = n -- 121
					end -- 121
				elseif k == "touchOpacity" or k == "opacity" then -- 122
					local n = __TS__Number(v) -- 123
					if n >= 0.3 and n <= 1 then -- 124
						out.touchOpacity = n -- 124
					end -- 124
				elseif k == "touchScale" or k == "scale" then -- 125
					local n = __TS__Number(v) -- 126
					if n >= 0.75 and n <= 1.35 then -- 127
						out.touchScale = n -- 127
					end -- 127
				elseif k == "haptics" then -- 128
					out.haptics = v == "1" or v == "true" -- 129
				end -- 129
			end -- 129
			::__continue16:: -- 129
			i = i + 1 -- 100
		end -- 100
	end -- 100
end -- 97
function ____exports.loadControlSettings() -- 134
	local out = ____exports.defaultControlSettings() -- 135
	do -- 135
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 135
			local mainPath = resolvePath(____exports.getControlSettingsFile()) -- 137
			if Content:exist(mainPath) then -- 138
				local raw = Content:load(mainPath) -- 139
				if raw ~= nil and raw ~= "" then -- 140
					applyKvLines(raw, out) -- 141
				end -- 141
				return true, out -- 143
			end -- 143
			if customControlsFile == "" then -- 146
				local legacyTouch = resolvePath(LEGACY_TOUCH_FILE) -- 147
				if Content:exist(legacyTouch) then -- 148
					local raw = Content:load(legacyTouch) -- 149
					if raw ~= nil and raw ~= "" then -- 150
						applyKvLines(raw, out) -- 151
					end -- 151
				end -- 151
				local legacyGamepad = resolvePath(LEGACY_GAMEPAD_FILE) -- 154
				if Content:exist(legacyGamepad) then -- 155
					local raw = Content:load(legacyGamepad) -- 156
					if raw ~= nil and raw ~= "" then -- 157
						applyKvLines(raw, out) -- 158
					end -- 158
				end -- 158
			end -- 158
		end) -- 158
		if ____try and ____hasReturned then -- 158
			return ____returnValue -- 136
		end -- 136
	end -- 136
	return out -- 165
end -- 134
function ____exports.saveControlSettings(s) -- 168
	do -- 168
		pcall(function() -- 168
			local target = resolvePath(____exports.getControlSettingsFile()) -- 170
			local dir = parentDirOf(target) -- 171
			if dir ~= "" and not Content:exist(dir) then -- 172
				Content:mkdir(dir) -- 173
			end -- 173
			local text = ((((((((((((((((((((((((("modePref=" .. s.modePref) .. "\n") .. "aimAssist=") .. (s.aimAssist and "1" or "0")) .. "\n") .. "crouchToggle=") .. (s.crouchToggle and "1" or "0")) .. "\n") .. "gamepadLayout=") .. s.gamepadLayout) .. "\n") .. "deadzoneLeft=") .. __TS__NumberToFixed(s.deadzoneLeft, 2)) .. "\n") .. "deadzoneRight=") .. __TS__NumberToFixed(s.deadzoneRight, 2)) .. "\n") .. "touchOpacity=") .. __TS__NumberToFixed(s.touchOpacity, 2)) .. "\n") .. "touchScale=") .. __TS__NumberToFixed(s.touchScale, 2)) .. "\n") .. "haptics=") .. (s.haptics and "1" or "0")) .. "\n" -- 175
			Content:save(target, text) -- 185
		end) -- 185
	end -- 185
end -- 168
function ____exports.nextModePref(cur, delta) -- 191
	if delta == nil then -- 191
		delta = 1 -- 191
	end -- 191
	local idx = __TS__ArrayIndexOf(____exports.MODE_PREF_ORDER, cur) -- 192
	local base = idx >= 0 and idx or 0 -- 193
	local len = #____exports.MODE_PREF_ORDER -- 194
	return ____exports.MODE_PREF_ORDER[(base + delta + len) % len + 1] -- 195
end -- 191
function ____exports.nextStepValue(cur, steps, delta) -- 198
	if delta == nil then -- 198
		delta = 1 -- 198
	end -- 198
	local bestIdx = 0 -- 199
	local bestDist = 999 -- 200
	local i = 0 -- 201
	do -- 201
		i = 0 -- 202
		while i < #steps do -- 202
			local d = math.abs(steps[i + 1] - cur) -- 203
			if d < bestDist then -- 204
				bestDist = d -- 205
				bestIdx = i -- 206
			end -- 206
			i = i + 1 -- 202
		end -- 202
	end -- 202
	local len = #steps -- 209
	return steps[(bestIdx + delta + len) % len + 1] -- 210
end -- 198
function ____exports.modePrefLabelOf(pref) -- 213
	if pref == "kbm" then -- 214
		return "键鼠" -- 214
	end -- 214
	if pref == "touch" then -- 215
		return "触屏" -- 215
	end -- 215
	if pref == "gamepad" then -- 216
		return "手柄" -- 216
	end -- 216
	return "自动" -- 217
end -- 213
function ____exports.inputModeLabelOf(mode) -- 220
	if mode == "touch" then -- 221
		return "触屏" -- 221
	end -- 221
	if mode == "gamepad" then -- 222
		return "手柄" -- 222
	end -- 222
	return "键鼠" -- 223
end -- 220
function ____exports.layoutLabelOf(layout) -- 226
	return layout == "nintendo" and "日系 B确认" or "标准 A确认" -- 227
end -- 226
function ____exports.opacityLabelOf(opacity) -- 230
	if opacity <= 0.62 then -- 231
		return "轻" -- 231
	end -- 231
	if opacity >= 0.88 then -- 232
		return "浓" -- 232
	end -- 232
	return "中" -- 233
end -- 230
function ____exports.scaleLabelOf(scale) -- 236
	if scale <= 0.93 then -- 237
		return "小" -- 237
	end -- 237
	if scale >= 1.07 then -- 238
		return "大" -- 238
	end -- 238
	return "中" -- 239
end -- 236
return ____exports -- 236
