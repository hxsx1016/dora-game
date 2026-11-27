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
local function resolvePath(rel) -- 55
	return (Content.writablePath .. "/") .. rel -- 56
end -- 55
function ____exports.defaultControlSettings() -- 59
	return { -- 60
		modePref = "auto", -- 61
		aimAssist = true, -- 62
		crouchToggle = false, -- 63
		gamepadLayout = "xbox", -- 64
		deadzoneLeft = 0.22, -- 65
		deadzoneRight = 0.18, -- 66
		touchOpacity = 0.78, -- 67
		touchScale = 1, -- 68
		haptics = true -- 69
	} -- 69
end -- 59
local function applyKvLines(raw, out) -- 73
	local lines = __TS__StringSplit(raw, "\n") -- 74
	local i = 0 -- 75
	do -- 75
		i = 0 -- 76
		while i < #lines do -- 76
			do -- 76
				local line = __TS__StringTrim(lines[i + 1]) -- 77
				local eq = (string.find(line, "=", nil, true) or 0) - 1 -- 78
				if eq <= 0 then -- 78
					goto __continue8 -- 79
				end -- 79
				local k = __TS__StringSlice(line, 0, eq) -- 80
				local v = __TS__StringSlice(line, eq + 1) -- 81
				if k == "modePref" then -- 81
					if v == "auto" or v == "kbm" or v == "touch" or v == "gamepad" then -- 81
						out.modePref = v -- 84
					end -- 84
				elseif k == "aimAssist" then -- 84
					out.aimAssist = v == "1" or v == "true" -- 87
				elseif k == "crouchToggle" then -- 87
					out.crouchToggle = v == "1" or v == "true" -- 89
				elseif k == "gamepadLayout" or k == "layout" then -- 89
					out.gamepadLayout = v == "nintendo" and "nintendo" or "xbox" -- 91
				elseif k == "deadzoneLeft" then -- 91
					local n = __TS__Number(v) -- 93
					if n >= 0.08 and n <= 0.45 then -- 93
						out.deadzoneLeft = n -- 94
					end -- 94
				elseif k == "deadzoneRight" then -- 94
					local n = __TS__Number(v) -- 96
					if n >= 0.08 and n <= 0.45 then -- 96
						out.deadzoneRight = n -- 97
					end -- 97
				elseif k == "touchOpacity" or k == "opacity" then -- 97
					local n = __TS__Number(v) -- 99
					if n >= 0.3 and n <= 1 then -- 99
						out.touchOpacity = n -- 100
					end -- 100
				elseif k == "touchScale" or k == "scale" then -- 100
					local n = __TS__Number(v) -- 102
					if n >= 0.75 and n <= 1.35 then -- 102
						out.touchScale = n -- 103
					end -- 103
				elseif k == "haptics" then -- 103
					out.haptics = v == "1" or v == "true" -- 105
				end -- 105
			end -- 105
			::__continue8:: -- 105
			i = i + 1 -- 76
		end -- 76
	end -- 76
end -- 73
function ____exports.loadControlSettings() -- 110
	local out = ____exports.defaultControlSettings() -- 111
	do -- 111
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 111
			local mainPath = resolvePath(____exports.getControlSettingsFile()) -- 113
			if Content:exist(mainPath) then -- 113
				local raw = Content:load(mainPath) -- 115
				if raw ~= nil and raw ~= "" then -- 115
					applyKvLines(raw, out) -- 117
				end -- 117
				return true, out -- 119
			end -- 119
			if customControlsFile == "" then -- 119
				local legacyTouch = resolvePath(LEGACY_TOUCH_FILE) -- 123
				if Content:exist(legacyTouch) then -- 123
					local raw = Content:load(legacyTouch) -- 125
					if raw ~= nil and raw ~= "" then -- 125
						applyKvLines(raw, out) -- 127
					end -- 127
				end -- 127
				local legacyGamepad = resolvePath(LEGACY_GAMEPAD_FILE) -- 130
				if Content:exist(legacyGamepad) then -- 130
					local raw = Content:load(legacyGamepad) -- 132
					if raw ~= nil and raw ~= "" then -- 132
						applyKvLines(raw, out) -- 134
					end -- 134
				end -- 134
			end -- 134
		end) -- 134
		if ____try and ____hasReturned then -- 134
			return ____returnValue -- 112
		end -- 112
	end -- 112
	return out -- 141
end -- 110
function ____exports.saveControlSettings(s) -- 144
	do -- 144
		pcall(function() -- 144
			local dir = Content.writablePath .. "/watch-save" -- 146
			if not Content:exist(dir) then -- 146
				Content:mkdir(dir) -- 148
			end -- 148
			local text = ((((((((((((((((((((((((("modePref=" .. s.modePref) .. "\n") .. "aimAssist=") .. (s.aimAssist and "1" or "0")) .. "\n") .. "crouchToggle=") .. (s.crouchToggle and "1" or "0")) .. "\n") .. "gamepadLayout=") .. s.gamepadLayout) .. "\n") .. "deadzoneLeft=") .. __TS__NumberToFixed(s.deadzoneLeft, 2)) .. "\n") .. "deadzoneRight=") .. __TS__NumberToFixed(s.deadzoneRight, 2)) .. "\n") .. "touchOpacity=") .. __TS__NumberToFixed(s.touchOpacity, 2)) .. "\n") .. "touchScale=") .. __TS__NumberToFixed(s.touchScale, 2)) .. "\n") .. "haptics=") .. (s.haptics and "1" or "0")) .. "\n" -- 150
			Content:save( -- 160
				resolvePath(____exports.getControlSettingsFile()), -- 160
				text -- 160
			) -- 160
		end) -- 160
	end -- 160
end -- 144
function ____exports.nextModePref(cur, delta) -- 166
	if delta == nil then -- 166
		delta = 1 -- 166
	end -- 166
	local idx = __TS__ArrayIndexOf(____exports.MODE_PREF_ORDER, cur) -- 167
	local base = idx >= 0 and idx or 0 -- 168
	local len = #____exports.MODE_PREF_ORDER -- 169
	return ____exports.MODE_PREF_ORDER[(base + delta + len) % len + 1] -- 170
end -- 166
function ____exports.nextStepValue(cur, steps, delta) -- 173
	if delta == nil then -- 173
		delta = 1 -- 173
	end -- 173
	local bestIdx = 0 -- 174
	local bestDist = 999 -- 175
	local i = 0 -- 176
	do -- 176
		i = 0 -- 177
		while i < #steps do -- 177
			local d = math.abs(steps[i + 1] - cur) -- 178
			if d < bestDist then -- 178
				bestDist = d -- 180
				bestIdx = i -- 181
			end -- 181
			i = i + 1 -- 177
		end -- 177
	end -- 177
	local len = #steps -- 184
	return steps[(bestIdx + delta + len) % len + 1] -- 185
end -- 173
function ____exports.modePrefLabelOf(pref) -- 188
	if pref == "kbm" then -- 188
		return "键鼠" -- 189
	end -- 189
	if pref == "touch" then -- 189
		return "触屏" -- 190
	end -- 190
	if pref == "gamepad" then -- 190
		return "手柄" -- 191
	end -- 191
	return "自动" -- 192
end -- 188
function ____exports.inputModeLabelOf(mode) -- 195
	if mode == "touch" then -- 195
		return "触屏" -- 196
	end -- 196
	if mode == "gamepad" then -- 196
		return "手柄" -- 197
	end -- 197
	return "键鼠" -- 198
end -- 195
function ____exports.layoutLabelOf(layout) -- 201
	return layout == "nintendo" and "日系 B确认" or "标准 A确认" -- 202
end -- 201
function ____exports.opacityLabelOf(opacity) -- 205
	if opacity <= 0.62 then -- 205
		return "轻" -- 206
	end -- 206
	if opacity >= 0.88 then -- 206
		return "浓" -- 207
	end -- 207
	return "中" -- 208
end -- 205
function ____exports.scaleLabelOf(scale) -- 211
	if scale <= 0.93 then -- 211
		return "小" -- 212
	end -- 212
	if scale >= 1.07 then -- 212
		return "大" -- 213
	end -- 213
	return "中" -- 214
end -- 211
return ____exports -- 211