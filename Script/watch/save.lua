-- [ts]: save.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local Content = ____Dora.Content -- 8
local ____run = require("Script.watch.run") -- 9
local isMuseumPhase = ____run.isMuseumPhase -- 9
____exports.SAVE_VERSION = 1 -- 11
____exports.SAVE_DIR = "watch-save" -- 12
____exports.SAVE_FILE = "watch-save/archive.txt" -- 13
local BACKUP_FILE = "watch-save/archive.corrupt.txt" -- 14
local currentFile = ____exports.SAVE_FILE -- 32
--- 引擎的 `exist/load/copy/remove` 只认绝对路径；相对写入会落到 writablePath 但读不回来。
local function absPath(path) -- 35
	if #path > 0 and string.sub(path, 1, 1) == "/" then -- 35
		return path -- 37
	end -- 37
	return (Content.writablePath .. "/") .. path -- 39
end -- 35
--- 测试用：切到隔离档案文件；传空则回正式档案。
function ____exports.setSaveFile(path) -- 43
	currentFile = path == "" and ____exports.SAVE_FILE or path -- 44
end -- 43
function ____exports.getSaveFile() -- 47
	return currentFile -- 48
end -- 47
function ____exports.emptySave() -- 51
	return { -- 52
		childCleared = false, -- 53
		soldierCleared = false, -- 54
		artifactOwned = false, -- 55
		museumPhase = "locked", -- 56
		museumSeen = false -- 57
	} -- 57
end -- 51
local function lineValue(text, key) -- 61
	local lines = __TS__StringSplit(text, "\n") -- 62
	local prefix = key .. "=" -- 63
	local i = 0 -- 64
	do -- 64
		i = 0 -- 65
		while i < #lines do -- 65
			local line = lines[i + 1] -- 66
			if #line >= #prefix and __TS__StringSubstring(line, 0, #prefix) == prefix then -- 66
				return __TS__StringSubstring(line, #prefix) -- 68
			end -- 68
			i = i + 1 -- 65
		end -- 65
	end -- 65
	return nil -- 71
end -- 61
local function boolOf(text, key, fallback) -- 74
	local value = lineValue(text, key) -- 75
	if value == nil then -- 75
		return fallback -- 77
	end -- 77
	if value == "true" then -- 77
		return true -- 80
	end -- 80
	if value == "false" then -- 80
		return false -- 83
	end -- 83
	return fallback -- 85
end -- 74
--- 只接受十进制整数；任何多余字符都按缺省处理。
local function intOf(text, fallback) -- 89
	if #text == 0 then -- 89
		return fallback -- 91
	end -- 91
	local i = 0 -- 93
	local sign = 1 -- 94
	if string.sub(text, 1, 1) == "-" then -- 94
		sign = -1 -- 96
		i = 1 -- 97
	end -- 97
	local n = 0 -- 99
	local digits = 0 -- 100
	do -- 100
		while i < #text do -- 100
			local c = __TS__StringCharCodeAt(text, i) -- 102
			if c < 48 or c > 57 then -- 102
				return fallback -- 104
			end -- 104
			n = n * 10 + (c - 48) -- 106
			digits = digits + 1 -- 107
			i = i + 1 -- 101
		end -- 101
	end -- 101
	if digits == 0 then -- 101
		return fallback -- 110
	end -- 110
	return sign * n -- 112
end -- 89
local function phaseOf(text, key, fallback) -- 115
	local value = lineValue(text, key) -- 116
	if value == nil or not isMuseumPhase(value) then -- 116
		return fallback -- 118
	end -- 118
	return value -- 120
end -- 115
local function numberOf(text, key, fallback) -- 123
	local value = lineValue(text, key) -- 124
	return value == nil and fallback or intOf(value, fallback) -- 125
end -- 123
local function formatSave(state) -- 128
	return table.concat( -- 129
		{ -- 129
			"version=" .. tostring(____exports.SAVE_VERSION), -- 130
			"childCleared=" .. (state.childCleared and "true" or "false"), -- 131
			"soldierCleared=" .. (state.soldierCleared and "true" or "false"), -- 132
			"artifactOwned=" .. (state.artifactOwned and "true" or "false"), -- 133
			"museumPhase=" .. state.museumPhase, -- 134
			"museumSeen=" .. (state.museumSeen and "true" or "false"), -- 135
			"" -- 136
		}, -- 136
		"\n" -- 137
	) -- 137
end -- 128
local function backupCorrupt() -- 140
	local src = absPath(currentFile) -- 141
	if Content:exist(src) then -- 141
		Content:copy( -- 143
			src, -- 143
			absPath(BACKUP_FILE) -- 143
		) -- 143
	end -- 143
end -- 140
--- 读取档案。
-- 缺失 → 空档案（missing）；损坏/版本不支持 → 备份原文件后回空档案并报告（corrupt/unsupported）。
-- 已支持的旧版本按字段缺省补齐，不丢已有通关。
function ____exports.loadSave() -- 152
	local file = absPath(currentFile) -- 153
	if not Content:exist(file) then -- 153
		return { -- 155
			state = ____exports.emptySave(), -- 155
			status = "missing", -- 155
			detail = "无档案，按新档起局" -- 155
		} -- 155
	end -- 155
	local text = Content:load(file) -- 157
	if text == nil or text == "" then -- 157
		backupCorrupt() -- 159
		return { -- 160
			state = ____exports.emptySave(), -- 160
			status = "corrupt", -- 160
			detail = "档案为空，已备份为 " .. BACKUP_FILE -- 160
		} -- 160
	end -- 160
	local version = numberOf(text, "version", -1) -- 162
	if version < 0 then -- 162
		backupCorrupt() -- 164
		return { -- 165
			state = ____exports.emptySave(), -- 165
			status = "corrupt", -- 165
			detail = "档案无版本行，已备份为 " .. BACKUP_FILE -- 165
		} -- 165
	end -- 165
	if version > ____exports.SAVE_VERSION then -- 165
		backupCorrupt() -- 168
		return { -- 169
			state = ____exports.emptySave(), -- 170
			status = "unsupported", -- 171
			detail = (((("档案版本 " .. tostring(version)) .. " 高于 ") .. tostring(____exports.SAVE_VERSION)) .. "，原文件保留，已备份为 ") .. BACKUP_FILE -- 172
		} -- 172
	end -- 172
	local state = { -- 175
		childCleared = boolOf(text, "childCleared", false), -- 176
		soldierCleared = boolOf(text, "soldierCleared", false), -- 177
		artifactOwned = boolOf(text, "artifactOwned", false), -- 178
		museumPhase = phaseOf(text, "museumPhase", "locked"), -- 179
		museumSeen = boolOf(text, "museumSeen", false) -- 180
	} -- 180
	return { -- 182
		state = state, -- 182
		status = "ok", -- 182
		detail = "版本 " .. tostring(version) -- 182
	} -- 182
end -- 152
--- 目标文件的目录部分；没有目录就写根。
local function dirOf(path) -- 186
	local i = #path - 1 -- 187
	do -- 187
		while i >= 0 do -- 187
			if __TS__StringCharAt(path, i) == "/" then -- 187
				return __TS__StringSubstring(path, 0, i) -- 190
			end -- 190
			i = i - 1 -- 188
		end -- 188
	end -- 188
	return "" -- 193
end -- 186
--- 写入档案：先写临时文件，成功后再替换；失败保留旧文件。
function ____exports.saveSave(state) -- 197
	local target = absPath(currentFile) -- 198
	local dir = dirOf(target) -- 199
	if dir ~= "" and not Content:isdir(dir) then -- 199
		Content:mkdir(dir) -- 201
	end -- 201
	local tmp = target .. ".tmp" -- 203
	local text = formatSave(state) -- 204
	Content:save(tmp, text) -- 205
	if not Content:exist(tmp) then -- 205
		return false -- 207
	end -- 207
	if Content:exist(target) then -- 207
		Content:remove(target) -- 210
	end -- 210
	return Content:copy(tmp, target) and Content:remove(tmp) -- 212
end -- 197
--- 档案内容签名：用于「正式通关是否变化」的幂等判断。
function ____exports.saveSignature(state) -- 216
	return table.concat({ -- 217
		state.childCleared and "1" or "0", -- 218
		state.soldierCleared and "1" or "0", -- 219
		state.artifactOwned and "1" or "0", -- 220
		state.museumPhase, -- 221
		state.museumSeen and "1" or "0" -- 222
	}, "|") -- 222
end -- 216
return ____exports -- 216