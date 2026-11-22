-- [ts]: levels.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
--- 地图字符是否合法。
local function isTileChar(ch) -- 32
	return ch == "#" or ch == "." or ch == "S" or ch == "E" or ch == "a" or ch == "A" or ch == "b" or ch == "B" -- 33
end -- 32
--- 按 \n 切行，兼容 \r\n；不保留首尾空行。
local function splitRows(input) -- 38
	local rows = {} -- 39
	local cur = "" -- 40
	do -- 40
		local i = 0 -- 41
		while i < #input do -- 41
			local ch = __TS__StringSlice(input, i, i + 1) -- 42
			if ch == "\n" then -- 42
				rows[#rows + 1] = cur -- 44
				cur = "" -- 45
			elseif ch == "\r" then -- 45
			else -- 45
				cur = cur .. ch -- 49
			end -- 49
			i = i + 1 -- 41
		end -- 41
	end -- 41
	rows[#rows + 1] = cur -- 52
	local out = {} -- 54
	do -- 54
		local i = 0 -- 55
		while i < #rows do -- 55
			do -- 55
				local row = rows[i + 1] -- 56
				if #row == 0 then -- 56
					goto __continue10 -- 58
				end -- 58
				out[#out + 1] = row -- 60
			end -- 60
			::__continue10:: -- 60
			i = i + 1 -- 55
		end -- 55
	end -- 55
	return out -- 62
end -- 38
--- 解析并校验一张地图。任何一条不满足都抛错，错误信息带关卡 id 与原因。
function ____exports.parseLevel(id, input) -- 68
	if #input == 0 then -- 68
		error( -- 70
			__TS__New(Error, ("level " .. id) .. ": map is empty"), -- 70
			0 -- 70
		) -- 70
	end -- 70
	local rows = splitRows(input) -- 73
	if #rows == 0 then -- 73
		error( -- 75
			__TS__New(Error, ("level " .. id) .. ": map is empty"), -- 75
			0 -- 75
		) -- 75
	end -- 75
	local width = #rows[1] -- 78
	do -- 78
		local y = 0 -- 79
		while y < #rows do -- 79
			if #rows[y + 1] ~= width then -- 79
				error( -- 81
					__TS__New( -- 81
						Error, -- 81
						(((((("level " .. id) .. ": row ") .. tostring(y)) .. " width ") .. tostring(#rows[y + 1])) .. " != ") .. tostring(width) -- 81
					), -- 81
					0 -- 81
				) -- 81
			end -- 81
			y = y + 1 -- 79
		end -- 79
	end -- 79
	local starts = {} -- 85
	local exits = {} -- 86
	local plates = {} -- 87
	local gates = {} -- 88
	do -- 88
		local y = 0 -- 90
		while y < #rows do -- 90
			local row = rows[y + 1] -- 91
			do -- 91
				local x = 0 -- 92
				while x < width do -- 92
					local ch = __TS__StringSlice(row, x, x + 1) -- 93
					if isTileChar(ch) == false then -- 93
						error( -- 95
							__TS__New( -- 95
								Error, -- 95
								((((((("level " .. id) .. ": bad char '") .. ch) .. "' at (") .. tostring(x)) .. ",") .. tostring(y)) .. ")" -- 95
							), -- 95
							0 -- 95
						) -- 95
					end -- 95
					if ch == "S" then -- 95
						starts[#starts + 1] = {x = x, y = y} -- 98
					elseif ch == "E" then -- 98
						exits[#exits + 1] = {x = x, y = y} -- 100
					elseif ch == "a" or ch == "b" then -- 100
						local group = ch == "a" and "A" or "B" -- 102
						if plates[group] ~= nil then -- 102
							error( -- 104
								__TS__New( -- 104
									Error, -- 104
									((((((("level " .. id) .. ": duplicate plate ") .. ch) .. " at (") .. tostring(x)) .. ",") .. tostring(y)) .. ")" -- 104
								), -- 104
								0 -- 104
							) -- 104
						end -- 104
						plates[group] = {x = x, y = y} -- 106
					elseif ch == "A" or ch == "B" then -- 106
						local group = ch -- 108
						if gates[group] ~= nil then -- 108
							error( -- 110
								__TS__New( -- 110
									Error, -- 110
									((((((("level " .. id) .. ": duplicate gate ") .. ch) .. " at (") .. tostring(x)) .. ",") .. tostring(y)) .. ")" -- 110
								), -- 110
								0 -- 110
							) -- 110
						end -- 110
						gates[group] = {x = x, y = y} -- 112
					end -- 112
					x = x + 1 -- 92
				end -- 92
			end -- 92
			y = y + 1 -- 90
		end -- 90
	end -- 90
	if #starts ~= 1 then -- 90
		error( -- 118
			__TS__New( -- 118
				Error, -- 118
				(("level " .. id) .. ": expect exactly 1 start S, got ") .. tostring(#starts) -- 118
			), -- 118
			0 -- 118
		) -- 118
	end -- 118
	if #exits ~= 1 then -- 118
		error( -- 121
			__TS__New( -- 121
				Error, -- 121
				(("level " .. id) .. ": expect exactly 1 exit E, got ") .. tostring(#exits) -- 121
			), -- 121
			0 -- 121
		) -- 121
	end -- 121
	do -- 121
		local i = 0 -- 124
		while i < 2 do -- 124
			local group = i == 0 and "A" or "B" -- 125
			local plate = group == "A" and "a" or "b" -- 126
			if plates[group] == nil ~= (gates[group] == nil) then -- 126
				error( -- 128
					__TS__New(Error, (((("level " .. id) .. ": plate ") .. plate) .. " must pair with gate ") .. group), -- 128
					0 -- 128
				) -- 128
			end -- 128
			i = i + 1 -- 124
		end -- 124
	end -- 124
	return { -- 132
		id = id, -- 133
		width = width, -- 134
		height = #rows, -- 135
		rows = rows, -- 136
		start = starts[1], -- 137
		exit = exits[1], -- 138
		gates = gates, -- 139
		plates = plates -- 140
	} -- 140
end -- 68
--- 一行的可读摘要，D1 用来确认「读到了什么」。
function ____exports.describeLevel(level) -- 145
	return ((((((((((((((((((((((((level.id .. " size=") .. tostring(level.width)) .. "x") .. tostring(level.height)) .. " S=(") .. tostring(level.start.x)) .. ",") .. tostring(level.start.y)) .. ")") .. " E=(") .. tostring(level.exit.x)) .. ",") .. tostring(level.exit.y)) .. ")") .. " A=(") .. tostring(level.gates.A.x)) .. ",") .. tostring(level.gates.A.y)) .. ")") .. " a=(") .. tostring(level.plates.A.x)) .. ",") .. tostring(level.plates.A.y)) .. ")") .. (level.gates.B == nil and " B=- b=-" or ((((((((" B=(" .. tostring(level.gates.B.x)) .. ",") .. tostring(level.gates.B.y)) .. ")") .. " b=(") .. tostring(level.plates.B.x)) .. ",") .. tostring(level.plates.B.y)) .. ")") -- 146
end -- 145
--- 关卡源文本。第一关 6x1，第二关 7x1；第三关（三行）留到后面再加。
local LEVEL_INPUTS = {level1 = "aS.AE", level2 = "baS.ABE"} -- 160
--- 按 id 读取关卡；非法地图会抛错，调用方决定怎么处理。
function ____exports.loadLevel(id) -- 166
	local input = LEVEL_INPUTS[id] -- 167
	if input == nil then -- 167
		error( -- 169
			__TS__New(Error, ("level " .. id) .. ": unknown level id"), -- 169
			0 -- 169
		) -- 169
	end -- 169
	return ____exports.parseLevel(id, input) -- 171
end -- 166
--- 当前可玩的关卡顺序。
____exports.LEVEL_IDS = {"level1", "level2"} -- 175
return ____exports -- 175