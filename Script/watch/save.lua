-- [ts]: save.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local ____exports = {} -- 1
local absPath, lineValue, intOf, formatSave, parseSave, normalize, usableBackup, dirOf, fault, currentFile, protectedFile -- 1
local ____Dora = require("Dora") -- 9
local Content = ____Dora.Content -- 9
local ____run = require("Script.watch.run") -- 10
local isMuseumPhase = ____run.isMuseumPhase -- 10
function absPath(path) -- 54
	if #path > 0 and string.sub(path, 1, 1) == "/" then -- 54
		return path -- 56
	end -- 56
	return (Content.writablePath .. "/") .. path -- 58
end -- 58
function ____exports.emptySave() -- 96
	return { -- 97
		childCleared = false, -- 98
		soldierCleared = false, -- 99
		artifactOwned = false, -- 100
		museumPhase = "locked", -- 101
		museumSeen = false -- 102
	} -- 102
end -- 96
function lineValue(text, key) -- 106
	local lines = __TS__StringSplit(text, "\n") -- 107
	local prefix = key .. "=" -- 108
	local i = 0 -- 109
	do -- 109
		i = 0 -- 110
		while i < #lines do -- 110
			local line = lines[i + 1] -- 111
			if #line >= #prefix and __TS__StringSubstring(line, 0, #prefix) == prefix then -- 111
				return __TS__StringSubstring(line, #prefix) -- 113
			end -- 113
			i = i + 1 -- 110
		end -- 110
	end -- 110
	return nil -- 116
end -- 116
function intOf(text, fallback) -- 119
	if #text == 0 then -- 119
		return fallback -- 121
	end -- 121
	local i = 0 -- 123
	local sign = 1 -- 124
	if string.sub(text, 1, 1) == "-" then -- 124
		sign = -1 -- 126
		i = 1 -- 127
	end -- 127
	local n = 0 -- 129
	local digits = 0 -- 130
	do -- 130
		while i < #text do -- 130
			local c = __TS__StringCharCodeAt(text, i) -- 132
			if c < 48 or c > 57 then -- 132
				return fallback -- 134
			end -- 134
			n = n * 10 + (c - 48) -- 136
			digits = digits + 1 -- 137
			i = i + 1 -- 131
		end -- 131
	end -- 131
	if digits == 0 then -- 131
		return fallback -- 140
	end -- 140
	return sign * n -- 142
end -- 142
function formatSave(state) -- 145
	return table.concat( -- 146
		{ -- 146
			"version=" .. tostring(____exports.SAVE_VERSION), -- 147
			"childCleared=" .. (state.childCleared and "true" or "false"), -- 148
			"soldierCleared=" .. (state.soldierCleared and "true" or "false"), -- 149
			"artifactOwned=" .. (state.artifactOwned and "true" or "false"), -- 150
			"museumPhase=" .. state.museumPhase, -- 151
			"museumSeen=" .. (state.museumSeen and "true" or "false"), -- 152
			"" -- 153
		}, -- 153
		"\n" -- 154
	) -- 154
end -- 154
function parseSave(text) -- 168
	local bad = { -- 169
		ok = false, -- 169
		status = "corrupt", -- 169
		reason = "", -- 169
		state = ____exports.emptySave() -- 169
	} -- 169
	if #text == 0 then -- 169
		bad.reason = "档案为空" -- 171
		return bad -- 172
	end -- 172
	local versionText = lineValue(text, "version") -- 174
	if versionText == nil then -- 174
		bad.reason = "缺少 version 行" -- 176
		return bad -- 177
	end -- 177
	local version = intOf(versionText, -1) -- 179
	if version < 0 then -- 179
		bad.reason = "version 不是十进制整数" -- 181
		return bad -- 182
	end -- 182
	if version > ____exports.SAVE_VERSION then -- 182
		return { -- 185
			ok = false, -- 185
			status = "unsupported", -- 185
			reason = (("版本 " .. tostring(version)) .. " 高于 ") .. tostring(____exports.SAVE_VERSION), -- 185
			state = ____exports.emptySave() -- 185
		} -- 185
	end -- 185
	if version ~= ____exports.SAVE_VERSION then -- 185
		bad.reason = "不支持的旧版本 " .. tostring(version) -- 188
		return bad -- 189
	end -- 189
	local boolKeys = {"childCleared", "soldierCleared", "artifactOwned", "museumSeen"} -- 191
	local bools = {} -- 192
	local i = 0 -- 193
	do -- 193
		i = 0 -- 194
		while i < #boolKeys do -- 194
			local value = lineValue(text, boolKeys[i + 1]) -- 195
			if value == nil then -- 195
				bad.reason = "缺少字段 " .. boolKeys[i + 1] -- 197
				return bad -- 198
			end -- 198
			if value ~= "true" and value ~= "false" then -- 198
				bad.reason = ("字段 " .. boolKeys[i + 1]) .. " 不是布尔值" -- 201
				return bad -- 202
			end -- 202
			bools[#bools + 1] = value == "true" -- 204
			i = i + 1 -- 194
		end -- 194
	end -- 194
	local phase = lineValue(text, "museumPhase") -- 206
	if phase == nil then -- 206
		bad.reason = "缺少字段 museumPhase" -- 208
		return bad -- 209
	end -- 209
	if not isMuseumPhase(phase) then -- 209
		bad.reason = "museumPhase 不在枚举内" -- 212
		return bad -- 213
	end -- 213
	return { -- 215
		ok = true, -- 216
		status = "ok", -- 217
		reason = "版本 " .. tostring(version), -- 218
		state = { -- 219
			childCleared = bools[1], -- 220
			soldierCleared = bools[2], -- 221
			artifactOwned = bools[3], -- 222
			museumPhase = phase, -- 223
			museumSeen = bools[4] -- 224
		} -- 224
	} -- 224
end -- 224
function normalize(text) -- 229
	return table.concat( -- 230
		__TS__StringSplit( -- 230
			table.concat( -- 230
				__TS__StringSplit(text, "\r\n"), -- 230
				"\n" -- 230
			), -- 230
			"\r" -- 230
		), -- 230
		"\n" -- 230
	) -- 230
end -- 230
function usableBackup(path) -- 258
	if not Content:exist(path) then -- 258
		return false -- 260
	end -- 260
	local text = Content:load(path) -- 262
	return text ~= nil and parseSave(text).ok -- 263
end -- 263
function dirOf(path) -- 334
	local i = #path - 1 -- 335
	do -- 335
		while i >= 0 do -- 335
			if __TS__StringCharAt(path, i) == "/" then -- 335
				return __TS__StringSubstring(path, 0, i) -- 338
			end -- 338
			i = i - 1 -- 336
		end -- 336
	end -- 336
	return "" -- 341
end -- 341
--- 写入档案：写 `.tmp` → 校验 → 备份旧档到 `.prev` → 覆盖目标 → 回读校验。
-- 任一步失败：目标保持旧内容（覆盖失败）或从 `.prev` 回滚；临时文件清理。
-- 未知版本原件处于保护位时拒绝写入，返回 false。
function ____exports.saveSave(state) -- 349
	if protectedFile then -- 349
		return false -- 351
	end -- 351
	local target = absPath(currentFile) -- 353
	local dir = dirOf(target) -- 354
	if dir ~= "" and not Content:isdir(dir) then -- 354
		Content:mkdir(dir) -- 356
	end -- 356
	local tmp = target .. ".tmp" -- 358
	local prev = target .. ".prev" -- 359
	local text = formatSave(state) -- 360
	if fault == "write" then -- 360
		return false -- 363
	end -- 363
	Content:save(tmp, text) -- 365
	local written = Content:load(tmp) -- 366
	if written == nil or normalize(written) ~= normalize(text) then -- 366
		Content:remove(tmp) -- 368
		return false -- 369
	end -- 369
	local existed = Content:exist(target) -- 372
	if existed then -- 372
		Content:copy(target, prev) -- 374
	end -- 374
	if fault == "replace" then -- 374
		Content:remove(tmp) -- 377
		return false -- 378
	end -- 378
	local copied = Content:copy(tmp, target) -- 381
	if not copied then -- 381
		if existed and usableBackup(prev) then -- 381
			Content:copy(prev, target) -- 384
		end -- 384
		Content:remove(tmp) -- 386
		return false -- 387
	end -- 387
	local check = Content:load(target) -- 390
	if fault == "verify" or check == nil or normalize(check) ~= normalize(text) then -- 390
		if existed and usableBackup(prev) then -- 390
			Content:copy(prev, target) -- 393
		else -- 393
			Content:remove(target) -- 395
		end -- 395
		Content:remove(tmp) -- 397
		return false -- 398
	end -- 398
	Content:remove(tmp) -- 401
	return true -- 402
end -- 349
____exports.SAVE_VERSION = 1 -- 12
____exports.SAVE_DIR = "watch-save" -- 13
____exports.SAVE_FILE = "watch-save/archive.txt" -- 14
fault = "" -- 41
function ____exports.setSaveFault(value) -- 43
	fault = value -- 44
end -- 43
currentFile = ____exports.SAVE_FILE -- 47
--- 跨 Play 实例的待落盘档案：归 app 同寿命的模块所有，切房换实例不会丢。
local pendingState = nil -- 49
protectedFile = false -- 51
--- 测试用：切到隔离档案文件；传空则回正式档案。
function ____exports.setSaveFile(path) -- 62
	currentFile = path == "" and ____exports.SAVE_FILE or path -- 63
	protectedFile = false -- 64
end -- 62
--- 登记一份待落盘档案（同拍切房、写失败都由调用方重新登记）。
function ____exports.markProfilePending(state) -- 68
	pendingState = state -- 69
end -- 68
function ____exports.profilePending() -- 72
	return pendingState ~= nil -- 73
end -- 72
--- 把登记的档案落盘；成功才清登记，失败保留等下一帧重试。
function ____exports.flushProfile() -- 77
	if pendingState == nil then -- 77
		return true -- 79
	end -- 79
	if not ____exports.saveSave(pendingState) then -- 79
		return false -- 82
	end -- 82
	pendingState = nil -- 84
	return true -- 85
end -- 77
function ____exports.clearProfilePending() -- 88
	pendingState = nil -- 89
end -- 88
function ____exports.getSaveFile() -- 92
	return currentFile -- 93
end -- 92
--- 按当前档案路径派生备份名：archive.txt.corrupt / .corrupt.2 …，不覆盖已有原件。
local function backupPathFor(target, suffix) -- 234
	local candidate = target .. suffix -- 235
	local n = 2 -- 236
	while Content:exist(candidate) do -- 236
		candidate = ((target .. suffix) .. ".") .. tostring(n) -- 238
		n = n + 1 -- 239
		if n > 99 then -- 239
			break -- 241
		end -- 241
	end -- 241
	return candidate -- 244
end -- 234
--- 把当前档案复制到派生的损坏/未知版本备份，返回备份路径（无原件则空串）。
local function backupCorrupt(target, suffix) -- 248
	if not Content:exist(target) then -- 248
		return "" -- 250
	end -- 250
	local backup = backupPathFor(target, suffix) -- 252
	Content:copy(target, backup) -- 253
	return backup -- 254
end -- 248
--- 读取档案。
-- 自愈顺序：目标缺失但 `.tmp` 完整 → 用 `.tmp`；目标损坏但 `.prev` 完整 → 用 `.prev`。
-- 损坏/未知版本先派生备份，再回空档案；未知版本原件置保护位，普通写档拒绝覆盖。
function ____exports.loadSave() -- 271
	local target = absPath(currentFile) -- 272
	local tmp = target .. ".tmp" -- 273
	local prev = target .. ".prev" -- 274
	local recovered = false -- 275
	if not Content:exist(target) and Content:exist(tmp) then -- 275
		if usableBackup(tmp) then -- 275
			Content:copy(tmp, target) -- 279
			Content:remove(tmp) -- 280
			recovered = true -- 281
		end -- 281
	end -- 281
	if not Content:exist(target) then -- 281
		return { -- 286
			state = ____exports.emptySave(), -- 287
			status = "missing", -- 287
			detail = "无档案，按新档起局", -- 287
			recovered = recovered, -- 288
			backup = "", -- 288
			action = "none" -- 288
		} -- 288
	end -- 288
	local text = Content:load(target) -- 292
	local parsed = parseSave(text == nil and "" or text) -- 293
	if parsed.ok then -- 293
		if Content:exist(tmp) then -- 293
			Content:remove(tmp) -- 296
		end -- 296
		return { -- 298
			state = parsed.state, -- 299
			status = "ok", -- 299
			detail = parsed.reason, -- 299
			recovered = recovered, -- 300
			backup = "", -- 300
			action = "keep" -- 300
		} -- 300
	end -- 300
	if parsed.status == "corrupt" and usableBackup(prev) then -- 300
		local broken = backupCorrupt(target, ".corrupt") -- 305
		Content:copy(prev, target) -- 306
		local again = parseSave(Content:load(target) == nil and "" or Content:load(target)) -- 307
		if again.ok then -- 307
			return { -- 309
				state = again.state, -- 310
				status = "ok", -- 310
				detail = (("原档损坏（" .. parsed.reason) .. "），已从 .prev 恢复，损坏件备份为 ") .. broken, -- 311
				recovered = true, -- 312
				backup = broken, -- 312
				action = "keep" -- 312
			} -- 312
		end -- 312
	end -- 312
	local backup = backupCorrupt(target, parsed.status == "unsupported" and ".unsupported" or ".corrupt") -- 317
	if parsed.status == "unsupported" then -- 317
		protectedFile = true -- 319
	end -- 319
	return { -- 321
		state = ____exports.emptySave(), -- 322
		status = parsed.status, -- 323
		detail = (parsed.status == "unsupported" and ("档案版本不支持（" .. parsed.reason) .. "），原件保留" or ("档案损坏（" .. parsed.reason) .. "），原件已备份") .. (backup ~= "" and "：" .. backup or ""), -- 324
		recovered = recovered, -- 328
		backup = backup, -- 328
		action = "reset" -- 329
	} -- 329
end -- 271
--- 恢复策略（给前端「档案损坏/版本不支持」页用）：把原件隔离到派生备份后删除，
-- 让下一次保存能建新档。仅当读取结果 `action === "reset"` 时需要调用。
function ____exports.resetSave() -- 409
	local target = absPath(currentFile) -- 410
	local backup = backupCorrupt(target, ".reset") -- 411
	protectedFile = false -- 412
	if Content:exist(target) then -- 412
		Content:remove(target) -- 414
	end -- 414
	return backup ~= "" -- 416
end -- 409
--- 档案内容签名：用于「正式通关是否变化」的幂等判断。
function ____exports.saveSignature(state) -- 420
	return table.concat({ -- 421
		state.childCleared and "1" or "0", -- 422
		state.soldierCleared and "1" or "0", -- 423
		state.artifactOwned and "1" or "0", -- 424
		state.museumPhase, -- 425
		state.museumSeen and "1" or "0" -- 426
	}, "|") -- 426
end -- 420
return ____exports -- 420