-- [ts]: controls_config.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
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
local function resolvePath(rel) -- 64
	return (Content.writablePath .. "/") .. rel -- 65
end -- 64
function ____exports.defaultControlSettings() -- 68
	return { -- 69
		modePref = "auto", -- 70
		aimAssist = true, -- 71
		crouchToggle = false, -- 72
		gamepadLayout = "xbox", -- 73
		deadzoneLeft = 0.22, -- 74
		deadzoneRight = 0.18, -- 75
		touchOpacity = 0.78, -- 76
		touchScale = 1, -- 77
		haptics = true, -- 78
		masterVol = 1, -- 79
		bgmVol = 0.8, -- 80
		sfxVol = 0.9, -- 81
		voiceVol = 1 -- 82
	} -- 82
end -- 68
local function applyKvLines(raw, out) -- 86
	local lines = __TS__StringSplit(raw, "\n") -- 87
	local i = 0 -- 88
	do -- 88
		i = 0 -- 89
		while i < #lines do -- 89
			do -- 89
				local line = __TS__StringTrim(lines[i + 1]) -- 90
				local eq = (string.find(line, "=", nil, true) or 0) - 1 -- 91
				if eq <= 0 then -- 91
					goto __continue8 -- 92
				end -- 92
				local k = __TS__StringSlice(line, 0, eq) -- 93
				local v = __TS__StringSlice(line, eq + 1) -- 94
				if k == "modePref" then -- 94
					if v == "auto" or v == "kbm" or v == "touch" or v == "gamepad" then -- 94
						out.modePref = v -- 97
					end -- 97
				elseif k == "aimAssist" then -- 97
					out.aimAssist = v == "1" or v == "true" -- 100
				elseif k == "crouchToggle" then -- 100
					out.crouchToggle = v == "1" or v == "true" -- 102
				elseif k == "gamepadLayout" or k == "layout" then -- 102
					out.gamepadLayout = v == "nintendo" and "nintendo" or "xbox" -- 104
				elseif k == "deadzoneLeft" then -- 104
					local n = __TS__Number(v) -- 106
					if n >= 0.08 and n <= 0.45 then -- 106
						out.deadzoneLeft = n -- 107
					end -- 107
				elseif k == "deadzoneRight" then -- 107
					local n = __TS__Number(v) -- 109
					if n >= 0.08 and n <= 0.45 then -- 109
						out.deadzoneRight = n -- 110
					end -- 110
				elseif k == "touchOpacity" or k == "opacity" then -- 110
					local n = __TS__Number(v) -- 112
					if n >= 0.3 and n <= 1 then -- 112
						out.touchOpacity = n -- 113
					end -- 113
				elseif k == "touchScale" or k == "scale" then -- 113
					local n = __TS__Number(v) -- 115
					if n >= 0.75 and n <= 1.35 then -- 115
						out.touchScale = n -- 116
					end -- 116
				elseif k == "haptics" then -- 116
					out.haptics = v == "1" or v == "true" -- 118
				elseif k == "masterVol" then -- 118
					local n = __TS__Number(v) -- 120
					if n >= 0 and n <= 1 then -- 120
						out.masterVol = n -- 121
					end -- 121
				elseif k == "bgmVol" then -- 121
					local n = __TS__Number(v) -- 123
					if n >= 0 and n <= 1 then -- 123
						out.bgmVol = n -- 124
					end -- 124
				elseif k == "sfxVol" then -- 124
					local n = __TS__Number(v) -- 126
					if n >= 0 and n <= 1 then -- 126
						out.sfxVol = n -- 127
					end -- 127
				elseif k == "voiceVol" then -- 127
					local n = __TS__Number(v) -- 129
					if n >= 0 and n <= 1 then -- 129
						out.voiceVol = n -- 130
					end -- 130
				end -- 130
			end -- 130
			::__continue8:: -- 130
			i = i + 1 -- 89
		end -- 89
	end -- 89
end -- 86
function ____exports.loadControlSettings() -- 135
	local out = ____exports.defaultControlSettings() -- 136
	do -- 136
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 136
			local mainPath = resolvePath(____exports.getControlSettingsFile()) -- 138
			if Content:exist(mainPath) then -- 138
				local raw = Content:load(mainPath) -- 140
				if raw ~= nil and raw ~= "" then -- 140
					applyKvLines(raw, out) -- 142
				end -- 142
				return true, out -- 144
			end -- 144
			if customControlsFile == "" then -- 144
				local legacyTouch = resolvePath(LEGACY_TOUCH_FILE) -- 148
				if Content:exist(legacyTouch) then -- 148
					local raw = Content:load(legacyTouch) -- 150
					if raw ~= nil and raw ~= "" then -- 150
						applyKvLines(raw, out) -- 152
					end -- 152
				end -- 152
				local legacyGamepad = resolvePath(LEGACY_GAMEPAD_FILE) -- 155
				if Content:exist(legacyGamepad) then -- 155
					local raw = Content:load(legacyGamepad) -- 157
					if raw ~= nil and raw ~= "" then -- 157
						applyKvLines(raw, out) -- 159
					end -- 159
				end -- 159
			end -- 159
		end) -- 159
		if ____try and ____hasReturned then -- 159
			return ____returnValue -- 137
		end -- 137
	end -- 137
	return out -- 166
end -- 135
function ____exports.saveControlSettings(s) -- 169
	do -- 169
		pcall(function() -- 169
			local dir = Content.writablePath .. "/watch-save" -- 171
			if not Content:exist(dir) then -- 171
				Content:mkdir(dir) -- 173
			end -- 173
			local text = ((((((((((((((((((((((((((((((((((((("modePref=" .. s.modePref) .. "\n") .. "aimAssist=") .. (s.aimAssist and "1" or "0")) .. "\n") .. "crouchToggle=") .. (s.crouchToggle and "1" or "0")) .. "\n") .. "gamepadLayout=") .. s.gamepadLayout) .. "\n") .. "deadzoneLeft=") .. __TS__NumberToFixed(s.deadzoneLeft, 2)) .. "\n") .. "deadzoneRight=") .. __TS__NumberToFixed(s.deadzoneRight, 2)) .. "\n") .. "touchOpacity=") .. __TS__NumberToFixed(s.touchOpacity, 2)) .. "\n") .. "touchScale=") .. __TS__NumberToFixed(s.touchScale, 2)) .. "\n") .. "haptics=") .. (s.haptics and "1" or "0")) .. "\n") .. "masterVol=") .. __TS__NumberToFixed(s.masterVol, 2)) .. "\n") .. "bgmVol=") .. __TS__NumberToFixed(s.bgmVol, 2)) .. "\n") .. "sfxVol=") .. __TS__NumberToFixed(s.sfxVol, 2)) .. "\n") .. "voiceVol=") .. __TS__NumberToFixed(s.voiceVol, 2)) .. "\n" -- 175
			Content:save( -- 189
				resolvePath(____exports.getControlSettingsFile()), -- 189
				text -- 189
			) -- 189
		end) -- 189
	end -- 189
end -- 169
function ____exports.nextModePref(cur, delta) -- 195
	if delta == nil then -- 195
		delta = 1 -- 195
	end -- 195
	local idx = __TS__ArrayIndexOf(____exports.MODE_PREF_ORDER, cur) -- 196
	local base = idx >= 0 and idx or 0 -- 197
	local len = #____exports.MODE_PREF_ORDER -- 198
	return ____exports.MODE_PREF_ORDER[(base + delta + len) % len + 1] -- 199
end -- 195
function ____exports.nextStepValue(cur, steps, delta) -- 202
	if delta == nil then -- 202
		delta = 1 -- 202
	end -- 202
	local bestIdx = 0 -- 203
	local bestDist = 999 -- 204
	local i = 0 -- 205
	do -- 205
		i = 0 -- 206
		while i < #steps do -- 206
			local d = math.abs(steps[i + 1] - cur) -- 207
			if d < bestDist then -- 207
				bestDist = d -- 209
				bestIdx = i -- 210
			end -- 210
			i = i + 1 -- 206
		end -- 206
	end -- 206
	local len = #steps -- 213
	return steps[(bestIdx + delta + len) % len + 1] -- 214
end -- 202
function ____exports.modePrefLabelOf(pref) -- 217
	if pref == "kbm" then -- 217
		return "键鼠" -- 218
	end -- 218
	if pref == "touch" then -- 218
		return "触屏" -- 219
	end -- 219
	if pref == "gamepad" then -- 219
		return "手柄" -- 220
	end -- 220
	return "自动" -- 221
end -- 217
function ____exports.inputModeLabelOf(mode) -- 224
	if mode == "touch" then -- 224
		return "触屏" -- 225
	end -- 225
	if mode == "gamepad" then -- 225
		return "手柄" -- 226
	end -- 226
	return "键鼠" -- 227
end -- 224
function ____exports.layoutLabelOf(layout) -- 230
	return layout == "nintendo" and "日系 B确认" or "标准 A确认" -- 231
end -- 230
function ____exports.opacityLabelOf(opacity) -- 234
	if opacity <= 0.62 then -- 234
		return "轻" -- 235
	end -- 235
	if opacity >= 0.88 then -- 235
		return "浓" -- 236
	end -- 236
	return "中" -- 237
end -- 234
function ____exports.scaleLabelOf(scale) -- 240
	if scale <= 0.93 then -- 240
		return "小" -- 241
	end -- 241
	if scale >= 1.07 then -- 241
		return "大" -- 242
	end -- 242
	return "中" -- 243
end -- 240
function ____exports.volumeLabelOf(vol) -- 246
	local pct = math.floor(math.max( -- 247
		0, -- 247
		math.min(1, vol) -- 247
	) * 100 + 0.5) -- 247
	return pct <= 0 and "静音" or tostring(pct) .. "%" -- 248
end -- 246
return ____exports -- 246