-- [ts]: turn.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local ____exports = {} -- 1
--- 每拍最多录六步。
____exports.MAX_STEPS = 6 -- 33
local OFFSETS = { -- 35
	L = {x = -1, y = 0}, -- 36
	R = {x = 1, y = 0}, -- 37
	U = {x = 0, y = -1}, -- 38
	D = {x = 0, y = 1}, -- 39
	W = {x = 0, y = 0} -- 40
} -- 40
--- 地图查询：越界返回 "outside"。
function ____exports.tileAt(level, pos) -- 44
	if pos.x < 0 or pos.x >= level.width or pos.y < 0 or pos.y >= level.height then -- 44
		return "outside" -- 46
	end -- 46
	return __TS__StringSlice(level.rows[pos.y + 1], pos.x, pos.x + 1) -- 48
end -- 44
--- 新一局录制态。
function ____exports.start(level) -- 52
	return {phase = "REC", body = level.start, path = {}, ticks = 0} -- 53
end -- 52
--- 从已确认路径进入合作态。path 原样共享，不复制。
function ____exports.playback(level, path) -- 57
	return {phase = "PLAY", body = level.start, path = path, ticks = 0} -- 58
end -- 57
--- 第 ticks 拍回声所在格。
-- REC 无回声；0 拍站在起点；其余取 path[min(ticks, len) - 1]（超出后停在末项）。
function ____exports.echoAt(level, state, ticks) -- 65
	if state.phase == "REC" then -- 65
		return nil -- 67
	end -- 67
	if ticks == 0 then -- 67
		return level.start -- 70
	end -- 70
	local index = math.min(ticks, #state.path) - 1 -- 72
	if index < 0 then -- 72
		return level.start -- 74
	end -- 74
	return state.path[index + 1] -- 76
end -- 65
--- 本体或回声是否踩在 group 对应的踏板上。
function ____exports.pressed(level, group, body, echo) -- 80
	local plate = group == "A" and "a" or "b" -- 81
	if ____exports.tileAt(level, body) == plate then -- 81
		return true -- 83
	end -- 83
	if echo ~= nil and ____exports.tileAt(level, echo) == plate then -- 83
		return true -- 86
	end -- 86
	return false -- 88
end -- 80
--- 当前画面应显示为开启的门组字符串（"A" / "B" / "AB" / ""）。
function ____exports.shownGroups(level, state) -- 92
	if state.phase == "REC" then -- 92
		return "" -- 94
	end -- 94
	local echo = ____exports.echoAt(level, state, state.ticks) -- 96
	local a = ____exports.pressed(level, "A", state.body, echo) and "A" or "" -- 97
	local b = ____exports.pressed(level, "B", state.body, echo) and "B" or "" -- 98
	return a .. b -- 99
end -- 92
--- 一个命令推进一拍。任何被拒绝的命令都返回同一个 before 对象。
function ____exports.advance(level, before, command) -- 103
	if before.phase == "WON" then -- 103
		return {state = before, outcome = "inactive"} -- 105
	end -- 105
	if command == "Rerecord" then -- 105
		return { -- 108
			state = ____exports.start(level), -- 108
			outcome = "rerecorded" -- 108
		} -- 108
	end -- 108
	if command == "Retry" then -- 108
		if before.phase ~= "PLAY" then -- 108
			return {state = before, outcome = "inactive"} -- 112
		end -- 112
		return { -- 114
			state = ____exports.playback(level, before.path), -- 114
			outcome = "retried" -- 114
		} -- 114
	end -- 114
	if command == "Confirm" then -- 114
		if before.phase ~= "REC" then -- 114
			return {state = before, outcome = "inactive"} -- 118
		end -- 118
		if #before.path == 0 then -- 118
			return {state = before, outcome = "empty"} -- 121
		end -- 121
		return { -- 123
			state = ____exports.playback(level, before.path), -- 123
			outcome = "confirmed" -- 123
		} -- 123
	end -- 123
	local offset = OFFSETS[command] -- 126
	local nextBody = {x = before.body.x + offset.x, y = before.body.y + offset.y} -- 127
	local tile = ____exports.tileAt(level, nextBody) -- 128
	if tile == "outside" or tile == "#" then -- 128
		return {state = before, outcome = tile == "#" and "wall" or "outside"} -- 130
	end -- 130
	local nextTicks = before.ticks + 1 -- 133
	local nextEcho = ____exports.echoAt(level, before, nextTicks) -- 134
	if command ~= "W" and (tile == "A" or tile == "B") then -- 134
		if before.phase == "REC" or ____exports.pressed(level, tile, before.body, nextEcho) == false then -- 134
			return {state = before, outcome = tile == "A" and "closed_A" or "closed_B"} -- 138
		end -- 138
	end -- 138
	if before.phase == "REC" then -- 138
		local path = __TS__ArraySlice(before.path) -- 143
		path[#path + 1] = nextBody -- 144
		if #path >= ____exports.MAX_STEPS then -- 144
			return { -- 146
				state = ____exports.playback(level, path), -- 146
				outcome = "auto_confirmed" -- 146
			} -- 146
		end -- 146
		return {state = {phase = "REC", body = nextBody, path = path, ticks = 0}, outcome = "ok"} -- 148
	end -- 148
	local reachedExit = tile == "E" -- 151
	local state = {phase = reachedExit and "WON" or "PLAY", body = nextBody, path = before.path, ticks = nextTicks} -- 152
	return {state = state, outcome = reachedExit and "won" or "ok"} -- 158
end -- 103
--- 玩家与回声当前所在格（REC 时回声为 undefined）。
function ____exports.bodies(level, state) -- 162
	return { -- 163
		body = state.body, -- 163
		echo = ____exports.echoAt(level, state, state.ticks) -- 163
	} -- 163
end -- 162
return ____exports -- 162