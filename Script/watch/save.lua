-- [ts]: save.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local isPortableSaveLayout, effectiveSaveFile, usePortableBackupsForProfile, absPath, baseNameOf, ensureDir, prevPathFor, readFields, intOf, formatSave, parseSave, normalize, sameContent, matchesText, backupPathFor, backupCorrupt, copyVerified, preserveUnrecognizedFile, dirOf, writeSaveFile, ops, fault, customSaveFile -- 1
local ____Dora = require("Dora") -- 11
local Content = ____Dora.Content -- 11
local ____run = require("Script.watch.run") -- 12
local isMuseumPhase = ____run.isMuseumPhase -- 12
local ____target_types = require("Script.watch.target_types") -- 13
local getReleaseConfig = ____target_types.getReleaseConfig -- 13
function isPortableSaveLayout() -- 23
	local cfg = getReleaseConfig() -- 24
	return cfg ~= nil and cfg.saveLayout == "portable" -- 25
end -- 25
function effectiveSaveFile() -- 91
	if customSaveFile ~= "" then -- 91
		return customSaveFile -- 93
	end -- 93
	return isPortableSaveLayout() and ____exports.PORTABLE_PROFILE_FILE or ____exports.SAVE_FILE -- 95
end -- 95
function usePortableBackupsForProfile() -- 98
	return customSaveFile == "" and isPortableSaveLayout() -- 99
end -- 99
function absPath(path) -- 103
	if #path > 0 and (string.sub(path, 1, 1) == "/" or string.sub(path, 1, 1) == "\\") then -- 103
		return path -- 105
	end -- 105
	if #path >= 2 and string.sub(path, 2, 2) == ":" then -- 105
		return path -- 108
	end -- 108
	local base = Content.writablePath -- 110
	local sep = (string.find(base, "\\", nil, true) or 0) - 1 >= 0 and (string.find(base, "/", nil, true) or 0) - 1 < 0 and "\\" or "/" -- 111
	local norm = sep == "\\" and table.concat( -- 112
		__TS__StringSplit(path, "/"), -- 112
		"\\" -- 112
	) or path -- 112
	local trimmed = (__TS__StringEndsWith(base, "/") or __TS__StringEndsWith(base, "\\")) and string.sub(base, 1, -2) or base -- 113
	return (trimmed .. sep) .. norm -- 114
end -- 114
function baseNameOf(path) -- 117
	local i = #path - 1 -- 118
	do -- 118
		while i >= 0 do -- 118
			local ch = __TS__StringCharAt(path, i) -- 120
			if ch == "/" or ch == "\\" then -- 120
				return __TS__StringSubstring(path, i + 1) -- 122
			end -- 122
			i = i - 1 -- 119
		end -- 119
	end -- 119
	return path -- 125
end -- 125
function ensureDir(dir) -- 128
	if dir ~= "" and not ops:isdir(dir) then -- 128
		ops:mkdir(dir) -- 130
	end -- 130
end -- 130
function prevPathFor(target, useBackupsDir) -- 134
	if useBackupsDir then -- 134
		return absPath(("backups/" .. baseNameOf(target)) .. ".prev") -- 136
	end -- 136
	return target .. ".prev" -- 138
end -- 138
function ____exports.savePath() -- 186
	return absPath(effectiveSaveFile()) -- 187
end -- 186
function ____exports.emptySave() -- 190
	return { -- 191
		childCleared = false, -- 192
		soldierCleared = false, -- 193
		artifactOwned = false, -- 194
		museumPhase = "locked", -- 195
		museumSeen = false -- 196
	} -- 196
end -- 190
function readFields(text) -- 201
	local fields = {} -- 202
	for ____, line in ipairs(__TS__StringSplit( -- 203
		normalize(text), -- 203
		"\n" -- 203
	)) do -- 203
		do -- 203
			local separator = (string.find(line, "=", nil, true) or 0) - 1 -- 204
			if separator <= 0 then -- 204
				goto __continue39 -- 205
			end -- 205
			local key = __TS__StringSubstring(line, 0, separator) -- 206
			if fields[key] == nil then -- 206
				fields[key] = __TS__StringSubstring(line, separator + 1) -- 207
			end -- 207
		end -- 207
		::__continue39:: -- 207
	end -- 207
	return fields -- 209
end -- 209
function intOf(text, fallback) -- 212
	if #text == 0 then -- 212
		return fallback -- 214
	end -- 214
	local i = 0 -- 216
	local sign = 1 -- 217
	if string.sub(text, 1, 1) == "-" then -- 217
		sign = -1 -- 219
		i = 1 -- 220
	end -- 220
	local n = 0 -- 222
	local digits = 0 -- 223
	do -- 223
		while i < #text do -- 223
			local c = __TS__StringCharCodeAt(text, i) -- 225
			if c < 48 or c > 57 then -- 225
				return fallback -- 227
			end -- 227
			n = n * 10 + (c - 48) -- 229
			digits = digits + 1 -- 230
			i = i + 1 -- 224
		end -- 224
	end -- 224
	if digits == 0 then -- 224
		return fallback -- 233
	end -- 233
	return sign * n -- 235
end -- 235
function formatSave(state) -- 238
	return table.concat( -- 239
		{ -- 239
			"version=" .. tostring(____exports.SAVE_VERSION), -- 240
			"childCleared=" .. (state.childCleared and "true" or "false"), -- 241
			"soldierCleared=" .. (state.soldierCleared and "true" or "false"), -- 242
			"artifactOwned=" .. (state.artifactOwned and "true" or "false"), -- 243
			"museumPhase=" .. state.museumPhase, -- 244
			"museumSeen=" .. (state.museumSeen and "true" or "false"), -- 245
			"" -- 246
		}, -- 246
		"\n" -- 247
	) -- 247
end -- 247
function parseSave(text) -- 261
	local bad = { -- 262
		ok = false, -- 262
		status = "corrupt", -- 262
		reason = "", -- 262
		state = ____exports.emptySave() -- 262
	} -- 262
	if #text == 0 then -- 262
		bad.reason = "档案为空" -- 264
		return bad -- 265
	end -- 265
	local fields = readFields(text) -- 267
	local versionText = fields.version -- 268
	if versionText == nil then -- 268
		bad.reason = "缺少 version 行" -- 270
		return bad -- 271
	end -- 271
	local version = intOf(versionText, -1) -- 273
	if version < 0 then -- 273
		bad.reason = "version 不是十进制整数" -- 275
		return bad -- 276
	end -- 276
	if version > ____exports.SAVE_VERSION then -- 276
		return { -- 279
			ok = false, -- 279
			status = "unsupported", -- 279
			reason = (("版本 " .. tostring(version)) .. " 高于 ") .. tostring(____exports.SAVE_VERSION), -- 279
			state = ____exports.emptySave() -- 279
		} -- 279
	end -- 279
	if version ~= ____exports.SAVE_VERSION then -- 279
		bad.reason = "不支持的旧版本 " .. tostring(version) -- 282
		return bad -- 283
	end -- 283
	local boolKeys = {"childCleared", "soldierCleared", "artifactOwned", "museumSeen"} -- 285
	local bools = {} -- 286
	local i = 0 -- 287
	do -- 287
		i = 0 -- 288
		while i < #boolKeys do -- 288
			local value = fields[boolKeys[i + 1]] -- 289
			if value == nil then -- 289
				bad.reason = "缺少字段 " .. boolKeys[i + 1] -- 291
				return bad -- 292
			end -- 292
			if value ~= "true" and value ~= "false" then -- 292
				bad.reason = ("字段 " .. boolKeys[i + 1]) .. " 不是布尔值" -- 295
				return bad -- 296
			end -- 296
			bools[#bools + 1] = value == "true" -- 298
			i = i + 1 -- 288
		end -- 288
	end -- 288
	local phase = fields.museumPhase -- 300
	if phase == nil then -- 300
		bad.reason = "缺少字段 museumPhase" -- 302
		return bad -- 303
	end -- 303
	if not isMuseumPhase(phase) then -- 303
		bad.reason = "museumPhase 不在枚举内" -- 306
		return bad -- 307
	end -- 307
	return { -- 309
		ok = true, -- 310
		status = "ok", -- 311
		reason = "版本 " .. tostring(version), -- 312
		state = { -- 313
			childCleared = bools[1], -- 314
			soldierCleared = bools[2], -- 315
			artifactOwned = bools[3], -- 316
			museumPhase = phase, -- 317
			museumSeen = bools[4] -- 318
		} -- 318
	} -- 318
end -- 318
function normalize(text) -- 323
	return table.concat( -- 324
		__TS__StringSplit( -- 324
			table.concat( -- 324
				__TS__StringSplit(text, "\r\n"), -- 324
				"\n" -- 324
			), -- 324
			"\r" -- 324
		), -- 324
		"\n" -- 324
	) -- 324
end -- 324
function sameContent(a, b) -- 328
	local text = ops:load(a) -- 329
	return text ~= nil and matchesText(b, text) -- 330
end -- 330
function matchesText(path, expected) -- 333
	local actual = ops:load(path) -- 334
	return actual ~= nil and normalize(actual) == normalize(expected) -- 335
end -- 335
function backupPathFor(target, suffix, useBackupsDir, reuseVerified) -- 339
	local prefix = useBackupsDir and absPath("backups/" .. baseNameOf(target)) or target -- 340
	do -- 340
		local n = 1 -- 341
		while n <= 9999 do -- 341
			local candidate = (prefix .. suffix) .. (n == 1 and "" or "." .. tostring(n)) -- 342
			if not ops:exist(candidate) or reuseVerified and sameContent(target, candidate) then -- 342
				return candidate -- 343
			end -- 343
			n = n + 1 -- 341
		end -- 341
	end -- 341
	return "" -- 345
end -- 345
function backupCorrupt(target, suffix, useBackupsDir, reuseVerified) -- 352
	if useBackupsDir == nil then -- 352
		useBackupsDir = false -- 352
	end -- 352
	if reuseVerified == nil then -- 352
		reuseVerified = false -- 352
	end -- 352
	if not ops:exist(target) then -- 352
		return "" -- 354
	end -- 354
	local backup = backupPathFor(target, suffix, useBackupsDir, reuseVerified) -- 356
	if backup == "" then -- 356
		return "" -- 358
	end -- 358
	if reuseVerified and ops:exist(backup) then -- 358
		return sameContent(target, backup) and backup or "" -- 360
	end -- 360
	ensureDir(dirOf(backup)) -- 361
	return copyVerified(target, backup) and backup or "" -- 362
end -- 362
function copyVerified(from, to) -- 377
	return ops:copy(from, to) and sameContent(from, to) -- 378
end -- 378
function preserveUnrecognizedFile(path, parse, useBackups) -- 382
	if not ops:exist(path) then -- 382
		return true -- 383
	end -- 383
	local text = ops:load(path) -- 384
	if text == nil then -- 384
		return false -- 385
	end -- 385
	local status = parse(text).status -- 386
	if status == "ok" then -- 386
		return true -- 387
	end -- 387
	local suffix = status == "unsupported" and ".unsupported" or ".corrupt" -- 388
	return backupCorrupt(path, suffix, useBackups, true) ~= "" -- 389
end -- 389
function dirOf(path) -- 484
	local i = #path - 1 -- 485
	do -- 485
		while i >= 0 do -- 485
			local ch = __TS__StringCharAt(path, i) -- 487
			if ch == "/" or ch == "\\" then -- 487
				return __TS__StringSubstring(path, 0, i) -- 489
			end -- 489
			i = i - 1 -- 486
		end -- 486
	end -- 486
	return "" -- 492
end -- 492
--- 写入档案：写 `.tmp` → 校验 → 备份旧档到 `.prev`（校验成功才继续）→ 覆盖目标 → 回读校验。
-- 失败语义：
--   - 备份失败：不覆盖目标，清掉本次 `.tmp`（旧档完好），返回 false；
--   - 覆盖失败：尝试从 `.prev` 回滚；`.tmp` 保留为最新候选，返回 false；
--   - 校验失败：用 `.prev` 回滚；回滚失败则保留 `.tmp`，返回 false。
-- 未知版本原件（按路径保护）拒绝写入。
function ____exports.saveSave(state) -- 503
	return writeSaveFile( -- 504
		____exports.savePath(), -- 504
		formatSave(state), -- 504
		usePortableBackupsForProfile(), -- 504
		parseSave, -- 504
		fault -- 504
	) -- 504
end -- 503
function writeSaveFile(target, text, useBackups, parse, failure) -- 507
	if failure == nil then -- 507
		failure = "" -- 507
	end -- 507
	if failure == "write" then -- 507
		return false -- 508
	end -- 508
	ensureDir(dirOf(target)) -- 509
	local tmp = target .. ".tmp" -- 510
	local prev = prevPathFor(target, useBackups) -- 511
	local status = "missing" -- 512
	if ops:exist(target) then -- 512
		local original = ops:load(target) -- 514
		if original == nil then -- 514
			return false -- 515
		end -- 515
		status = parse(original).status -- 516
		if status == "unsupported" then -- 516
			return false -- 517
		end -- 517
		if status == "corrupt" and backupCorrupt(target, ".corrupt", useBackups) == "" then -- 517
			return false -- 518
		end -- 518
	end -- 518
	if status ~= "ok" and ops:exist(tmp) then -- 518
		local candidate = ops:load(tmp) -- 523
		if candidate == nil then -- 523
			return false -- 524
		end -- 524
		local candidateStatus = parse(candidate).status -- 525
		if candidateStatus == "unsupported" then -- 525
			return false -- 526
		end -- 526
		if candidateStatus == "ok" then -- 526
			if not copyVerified(tmp, target) then -- 526
				return false -- 528
			end -- 528
			status = "ok" -- 529
		end -- 529
	end -- 529
	if not preserveUnrecognizedFile(tmp, parse, useBackups) or status == "ok" and not preserveUnrecognizedFile(prev, parse, useBackups) then -- 529
		return false -- 534
	end -- 534
	if not ops:save(tmp, text) or not matchesText(tmp, text) then -- 534
		ops:remove(tmp) -- 536
		return false -- 537
	end -- 537
	if status == "ok" then -- 537
		ensureDir(dirOf(prev)) -- 540
		if not copyVerified(target, prev) then -- 540
			ops:remove(tmp) -- 542
			return false -- 543
		end -- 543
	end -- 543
	if failure == "replace" or not ops:copy(tmp, target) then -- 543
		if status == "ok" and not sameContent(target, prev) then -- 543
			copyVerified(prev, target) -- 547
		end -- 547
		return false -- 548
	end -- 548
	if failure == "verify" or not matchesText(target, text) then -- 548
		if status == "ok" and copyVerified(prev, target) then -- 548
			ops:remove(tmp) -- 551
		end -- 551
		return false -- 552
	end -- 552
	ops:remove(tmp) -- 554
	return true -- 555
end -- 555
____exports.SAVE_VERSION = 1 -- 15
____exports.SAVE_DIR = "watch-save" -- 16
____exports.SAVE_FILE = "watch-save/archive.txt" -- 17
____exports.PORTABLE_PROFILE_FILE = "profile.sav" -- 18
____exports.PORTABLE_AUTOSAVE_FILE = "autosave.sav" -- 19
____exports.SAVE_SLOT_COUNT = 3 -- 20
local contentOps = { -- 62
	exist = function(____, path) return Content:exist(path) end, -- 63
	load = function(____, path) return Content:load(path) end, -- 64
	save = function(____, path, text) return Content:save(path, text) end, -- 65
	copy = function(____, from, to) return Content:copy(from, to) end, -- 66
	remove = function(____, path) return Content:remove(path) end, -- 67
	isdir = function(____, path) return Content:isdir(path) end, -- 68
	mkdir = function(____, path) return Content:mkdir(path) end -- 69
} -- 69
ops = contentOps -- 72
--- 测试注入文件操作层；传 undefined 恢复引擎默认。正式入口不调用。
function ____exports.setFileOpsForTest(next) -- 75
	ops = next == nil and contentOps or next -- 76
end -- 75
fault = "" -- 81
function ____exports.setSaveFault(value) -- 83
	fault = value -- 84
end -- 83
customSaveFile = "" -- 87
--- 跨 Play 实例的待落盘档案：携带目标路径，切换档案后不会写错档。
local pending = nil -- 89
--- 测试用：切到隔离档案文件；传空则回正式档案。写入时始终检查目标的实际版本。
function ____exports.setSaveFile(path) -- 142
	customSaveFile = path -- 143
end -- 142
--- 登记一份待落盘档案（同拍切房、写失败都由调用方重新登记）。
function ____exports.markProfilePending(state) -- 147
	pending = { -- 148
		state = state, -- 148
		file = effectiveSaveFile() -- 148
	} -- 148
end -- 147
function ____exports.profilePending() -- 151
	return pending ~= nil -- 152
end -- 151
--- 待落盘档案是否属于当前档案路径（切档后不应写错目标）。
function ____exports.pendingMatchesCurrent() -- 156
	return pending ~= nil and pending.file == effectiveSaveFile() -- 157
end -- 156
--- 把登记的档案落盘；成功才清登记，失败保留等下一帧重试。
-- 登记属于别的档案路径时不写、返回 false（调用方应显式丢弃或先切回）。
function ____exports.flushProfile() -- 164
	if pending == nil then -- 164
		return true -- 166
	end -- 166
	if pending.file ~= effectiveSaveFile() then -- 166
		return false -- 169
	end -- 169
	if not ____exports.saveSave(pending.state) then -- 169
		return false -- 172
	end -- 172
	pending = nil -- 174
	return true -- 175
end -- 164
function ____exports.clearProfilePending() -- 178
	pending = nil -- 179
end -- 178
function ____exports.getSaveFile() -- 182
	return effectiveSaveFile() -- 183
end -- 182
--- 读文本；读不到按空串处理（解析会判 corrupt）。
local function loadText(path) -- 366
	local text = ops:load(path) -- 367
	if text == nil then -- 367
		return "" -- 369
	end -- 369
	return text -- 371
end -- 366
local function restoreFrom(candidate, target, keepCandidate, parse) -- 392
	if not ops:exist(candidate) or parse(loadText(candidate)).status ~= "ok" then -- 392
		return false -- 393
	end -- 393
	ensureDir(dirOf(target)) -- 394
	if not copyVerified(candidate, target) then -- 394
		return false -- 395
	end -- 395
	if not keepCandidate then -- 395
		ops:remove(candidate) -- 396
	end -- 396
	return true -- 397
end -- 392
--- 读取档案。
-- 自愈顺序：
--   目标缺失 → 完整 `.tmp` → 完整 `.prev`；
--   目标损坏 → 完整 `.tmp`（最新候选）→ 完整 `.prev`。
-- 损坏/未知版本先派生备份；普通写档按原件版本判断能否覆盖。
function ____exports.loadSave() -- 407
	local target = absPath(effectiveSaveFile()) -- 408
	local useBackups = usePortableBackupsForProfile() -- 409
	local tmp = target .. ".tmp" -- 410
	local prev = prevPathFor(target, useBackups) -- 411
	local recovered = false -- 412
	local recoveryDetail = "" -- 413
	if not ops:exist(target) then -- 413
		if restoreFrom(tmp, target, false, parseSave) then -- 413
			recovered = true -- 417
			recoveryDetail = "目标缺失，已用完整 .tmp 恢复" -- 418
		elseif restoreFrom(prev, target, true, parseSave) then -- 418
			recovered = true -- 420
			recoveryDetail = "目标缺失，已用完整 .prev 恢复" -- 421
		end -- 421
	end -- 421
	if not ops:exist(target) then -- 421
		return { -- 426
			state = ____exports.emptySave(), -- 427
			status = "missing", -- 427
			detail = "无档案，按新档起局" .. (recovered and ("（" .. recoveryDetail) .. "）" or ""), -- 428
			recovered = recovered, -- 429
			backup = "", -- 429
			action = "none" -- 429
		} -- 429
	end -- 429
	local text = ops:load(target) -- 433
	local parsed = parseSave(text == nil and "" or text) -- 434
	if parsed.ok then -- 434
		if ops:exist(tmp) and sameContent(tmp, target) then -- 434
			ops:remove(tmp) -- 438
		end -- 438
		return { -- 440
			state = parsed.state, -- 441
			status = "ok", -- 441
			detail = parsed.reason .. (recovered and ("（" .. recoveryDetail) .. "）" or ""), -- 442
			recovered = recovered, -- 443
			backup = "", -- 443
			action = "keep" -- 443
		} -- 443
	end -- 443
	if parsed.status == "corrupt" then -- 443
		local broken = backupCorrupt(target, ".corrupt", useBackups) -- 448
		if broken ~= "" and restoreFrom(tmp, target, false, parseSave) then -- 448
			return { -- 450
				state = parseSave(loadText(target)).state, -- 451
				status = "ok", -- 452
				detail = (("原档损坏（" .. parsed.reason) .. "），已用完整 .tmp 恢复，损坏件备份为 ") .. broken, -- 453
				recovered = true, -- 454
				backup = broken, -- 454
				action = "keep" -- 454
			} -- 454
		end -- 454
		if broken ~= "" and restoreFrom(prev, target, true, parseSave) then -- 454
			return { -- 458
				state = parseSave(loadText(target)).state, -- 459
				status = "ok", -- 460
				detail = (("原档损坏（" .. parsed.reason) .. "），已用 .prev 恢复，损坏件备份为 ") .. broken, -- 461
				recovered = true, -- 462
				backup = broken, -- 462
				action = "keep" -- 462
			} -- 462
		end -- 462
		return { -- 466
			state = ____exports.emptySave(), -- 467
			status = "corrupt", -- 467
			detail = (("档案损坏（" .. parsed.reason) .. "），原件保留") .. (broken ~= "" and "，损坏件备份为 " .. broken or "，备份失败（原件未动）"), -- 468
			recovered = false, -- 470
			backup = broken, -- 470
			action = "reset" -- 470
		} -- 470
	end -- 470
	local backup = backupCorrupt(target, ".unsupported", useBackups) -- 474
	return { -- 475
		state = ____exports.emptySave(), -- 476
		status = "unsupported", -- 476
		detail = (("档案版本不支持（" .. parsed.reason) .. "），原件保留") .. (backup ~= "" and "：" .. backup or "，备份失败（原件未动）"), -- 477
		recovered = recovered, -- 479
		backup = backup, -- 479
		action = "reset" -- 479
	} -- 479
end -- 407
--- 先清理可复活进度的候选件，失败时保留当前主文件供重试。
local function removeSaveFiles(target, useBackups) -- 559
	for ____, path in ipairs({ -- 560
		prevPathFor(target, useBackups), -- 560
		target .. ".tmp", -- 560
		target -- 560
	}) do -- 560
		if ops:exist(path) and not ops:remove(path) then -- 560
			return false -- 561
		end -- 561
	end -- 561
	return true -- 563
end -- 559
--- 恢复策略（给前端「档案损坏/版本不支持」页用）：把原件隔离到派生备份后删除。
-- 只有备份复制成功、内容与原件一致，才删除目标和可恢复候选。
function ____exports.resetSave() -- 570
	local target = absPath(effectiveSaveFile()) -- 571
	if not ops:exist(target) then -- 571
		return false -- 573
	end -- 573
	local backup = backupCorrupt( -- 575
		target, -- 575
		".reset", -- 575
		usePortableBackupsForProfile() -- 575
	) -- 575
	if backup == "" then -- 575
		return false -- 577
	end -- 577
	if not removeSaveFiles( -- 577
		target, -- 579
		usePortableBackupsForProfile() -- 579
	) then -- 579
		return false -- 579
	end -- 579
	if ____exports.pendingMatchesCurrent() then -- 579
		____exports.clearProfilePending() -- 580
	end -- 580
	return true -- 581
end -- 570
--- 档案内容签名：用于「正式通关是否变化」的幂等判断。
function ____exports.saveSignature(state) -- 585
	return table.concat({ -- 586
		state.childCleared and "1" or "0", -- 587
		state.soldierCleared and "1" or "0", -- 588
		state.artifactOwned and "1" or "0", -- 589
		state.museumPhase, -- 590
		state.museumSeen and "1" or "0" -- 591
	}, "|") -- 591
end -- 585
____exports.SESSION_VERSION = 1 -- 599
____exports.SESSION_FILE = "watch-save/session.txt" -- 600
local customSessionFile = "" -- 687
local function effectiveSessionFile() -- 689
	if customSessionFile ~= "" then -- 689
		return customSessionFile -- 691
	end -- 691
	return isPortableSaveLayout() and ____exports.PORTABLE_AUTOSAVE_FILE or ____exports.SESSION_FILE -- 693
end -- 689
local function usePortableBackupsForSession() -- 696
	return customSessionFile == "" and isPortableSaveLayout() -- 697
end -- 696
function ____exports.getSlotFile(slot) -- 700
	if slot == "auto" then -- 700
		return effectiveSessionFile() -- 702
	end -- 702
	if customSessionFile ~= "" then -- 702
		return (customSessionFile .. ".slot") .. tostring(slot) -- 705
	end -- 705
	return isPortableSaveLayout() and ("slots/slot_" .. tostring(slot)) .. ".sav" or ("watch-save/slots/slot_" .. tostring(slot)) .. ".sav" -- 707
end -- 700
function ____exports.setSessionFile(path) -- 712
	customSessionFile = path -- 713
end -- 712
function ____exports.getSessionFile() -- 716
	return effectiveSessionFile() -- 717
end -- 716
function ____exports.nowUnixSeconds() -- 720
	local g = _G -- 721
	local ____temp_0 -- 722
	if g.os ~= nil then -- 722
		____temp_0 = g.os.time -- 722
	else -- 722
		____temp_0 = nil -- 722
	end -- 722
	local timeFn = ____temp_0 -- 722
	if type(timeFn) == "function" then -- 722
		local t = timeFn() -- 724
		if type(t) == "number" and t > 0 then -- 724
			return math.floor(t) -- 726
		end -- 726
	end -- 726
	return 0 -- 729
end -- 720
function ____exports.formatSavedAt(ts) -- 732
	if ts <= 0 then -- 732
		return "" -- 734
	end -- 734
	local g = _G -- 736
	local ____temp_1 -- 737
	if g.os ~= nil then -- 737
		____temp_1 = g.os.date -- 737
	else -- 737
		____temp_1 = nil -- 737
	end -- 737
	local dateFn = ____temp_1 -- 737
	if type(dateFn) == "function" then -- 737
		local s = dateFn("%Y-%m-%d %H:%M", ts) -- 739
		if type(s) == "string" then -- 739
			return s -- 741
		end -- 741
	end -- 741
	return "" -- 744
end -- 732
function ____exports.formatPlayDuration(sec) -- 747
	local total = math.max( -- 748
		0, -- 748
		math.floor(sec) -- 748
	) -- 748
	if total <= 0 then -- 748
		return "" -- 750
	end -- 750
	local h = math.floor(total / 3600) -- 752
	local m = math.floor(total % 3600 / 60) -- 753
	local s = total % 60 -- 754
	local mm = m < 10 and "0" .. tostring(m) or "" .. tostring(m) -- 755
	local ss = s < 10 and "0" .. tostring(s) or "" .. tostring(s) -- 756
	if h > 0 then -- 756
		return (((tostring(h) .. ":") .. mm) .. ":") .. ss -- 758
	end -- 758
	return (mm .. ":") .. ss -- 760
end -- 747
local function parseBoolField(raw, fallback) -- 763
	if raw == nil then -- 763
		return fallback -- 765
	end -- 765
	if raw == "true" or raw == "1" then -- 765
		return true -- 768
	end -- 768
	if raw == "false" or raw == "0" then -- 768
		return false -- 771
	end -- 771
	return nil -- 773
end -- 763
local function parseListField(raw) -- 776
	if raw == nil or raw == "" then -- 776
		return {} -- 778
	end -- 778
	local parts = __TS__StringSplit(raw, ",") -- 780
	local out = {} -- 781
	local i = 0 -- 782
	do -- 782
		i = 0 -- 783
		while i < #parts do -- 783
			local item = __TS__StringTrim(parts[i + 1]) -- 784
			if item ~= "" then -- 784
				out[#out + 1] = item -- 786
			end -- 786
			i = i + 1 -- 783
		end -- 783
	end -- 783
	return out -- 789
end -- 776
function ____exports.formatSession(s) -- 792
	return table.concat( -- 793
		{ -- 793
			"version=" .. tostring(____exports.SESSION_VERSION), -- 794
			"roomKey=" .. s.roomKey, -- 795
			"checkpoint=" .. tostring(math.floor(s.checkpoint + 0.5)), -- 796
			"seed=" .. tostring(math.floor(s.seed + 0.5)), -- 797
			"route=" .. s.route, -- 798
			"hp=" .. tostring(math.floor(s.hp + 0.5)), -- 799
			"maxHp=" .. tostring(math.floor(s.maxHp + 0.5)), -- 800
			"hpAtGate=" .. tostring(math.floor(s.hpAtGate + 0.5)), -- 801
			"maxHpAtGate=" .. tostring(math.floor(s.maxHpAtGate + 0.5)), -- 802
			"settled=" .. (s.settled and "true" or "false"), -- 803
			"phase=" .. s.phase, -- 804
			"countTick=" .. tostring(math.floor(s.countTick + 0.5)), -- 805
			"phaseTick=" .. tostring(math.floor(s.phaseTick + 0.5)), -- 806
			"handTicks=" .. tostring(math.floor(s.handTicks + 0.5)), -- 807
			"handDone=" .. (s.handDone and "true" or "false"), -- 808
			"lineSaid=" .. (s.lineSaid and "true" or "false"), -- 809
			"tied=" .. (s.tied and "true" or "false"), -- 810
			"carry=" .. (s.carry and "true" or "false"), -- 811
			"escortDone=" .. (s.escortDone and "true" or "false"), -- 812
			"craftedWeapon=" .. s.craftedWeapon, -- 813
			"equippedWeapon=" .. s.equippedWeapon, -- 814
			"wood=" .. tostring(math.floor(s.wood + 0.5)), -- 815
			"bell=" .. tostring(math.floor(s.bell + 0.5)), -- 816
			"scrap=" .. tostring(math.floor(s.scrap + 0.5)), -- 817
			"wedge=" .. tostring(math.floor(s.wedge + 0.5)), -- 818
			"ammo=" .. tostring(math.floor(s.ammo + 0.5)), -- 819
			"shield=" .. tostring(math.floor(s.shield + 0.5)), -- 820
			"pass=" .. tostring(math.floor(s.pass + 0.5)), -- 821
			"quickbelt=" .. tostring(math.floor(s.quickbelt + 0.5)), -- 822
			"taken=" .. table.concat(s.taken, ","), -- 823
			"segments=" .. table.concat(s.segments, ","), -- 824
			"cartAxle=" .. tostring(math.floor(s.cartAxle + 0.5)), -- 825
			"cartDocked=" .. (s.cartDocked and "true" or "false"), -- 826
			"campaignRoute=" .. (s.campaignRoute or ""), -- 827
			"joined=" .. (s.joined == true and "true" or "false"), -- 828
			"c1Latch=" .. (s.c1Latch == true and "true" or "false"), -- 829
			"c2Latch=" .. (s.c2Latch == true and "true" or "false"), -- 830
			"talentSeed=" .. tostring(math.floor((s.talentSeed or 0) + 0.5)), -- 831
			"talentRoom=" .. (s.talentRoom or ""), -- 832
			"talentOffers=" .. (s.talentOffers == nil and "" or table.concat(s.talentOffers, ",")), -- 833
			"talentRanks=" .. (s.talentRanks == nil and "" or table.concat(s.talentRanks, ",")), -- 834
			"escortAttempt=" .. tostring(math.floor((s.escortAttempt or 1) + 0.5)), -- 835
			"escortVariant=" .. tostring(math.floor((s.escortVariant or 0) + 0.5)), -- 836
			"talentDeferred=" .. (s.talentDeferred == true and "true" or "false"), -- 837
			"talentVitality=" .. tostring(math.floor((s.talentVitality or 0) + 0.5)), -- 838
			"talentReload=" .. tostring(math.floor((s.talentReload or 0) + 0.5)), -- 839
			"talentGuard=" .. tostring(math.floor((s.talentGuard or 0) + 0.5)), -- 840
			"talentCraft=" .. tostring(math.floor((s.talentCraft or 0) + 0.5)), -- 841
			"props=" .. (s.props == nil and "" or table.concat(s.props, ",")), -- 842
			"playerX=" .. tostring(s.playerX == nil and -1 or math.floor(s.playerX + 0.5)), -- 843
			"playerY=" .. tostring(s.playerY == nil and 0 or math.floor(s.playerY + 0.5)), -- 844
			"playerDepth=" .. tostring(s.playerDepth == nil and 0 or math.floor(s.playerDepth + 0.5)), -- 845
			"gateTick=" .. tostring(math.floor((s.gateTick or 0) + 0.5)), -- 846
			"hasBottle=" .. (s.hasBottle == true and "true" or "false"), -- 847
			"villagePassed=" .. (s.villagePassed == true and "true" or "false"), -- 848
			"savedAt=" .. tostring(math.floor((s.savedAt ~= nil and s.savedAt > 0 and s.savedAt or ____exports.nowUnixSeconds()) + 0.5)), -- 849
			"playSeconds=" .. tostring(math.max( -- 850
				0, -- 850
				math.floor((s.playSeconds or 0) + 0.5) -- 850
			)), -- 850
			"" -- 851
		}, -- 851
		"\n" -- 852
	) -- 852
end -- 792
function ____exports.parseSession(text) -- 855
	if #text == 0 then -- 855
		return {ok = false, status = "corrupt", reason = "局中存档为空"} -- 857
	end -- 857
	local fields = readFields(text) -- 859
	local verRaw = fields.version -- 860
	if verRaw == nil then -- 860
		return {ok = false, status = "corrupt", reason = "缺少 version 行"} -- 862
	end -- 862
	local ver = intOf(verRaw, -1) -- 864
	if ver < 0 then -- 864
		return {ok = false, status = "corrupt", reason = "version 非法"} -- 866
	end -- 866
	if ver > ____exports.SESSION_VERSION then -- 866
		return { -- 869
			ok = false, -- 869
			status = "unsupported", -- 869
			reason = (("局中存档版本 " .. tostring(ver)) .. " 高于当前 ") .. tostring(____exports.SESSION_VERSION) -- 869
		} -- 869
	end -- 869
	local roomKey = fields.roomKey -- 871
	if roomKey == nil or roomKey == "" then -- 871
		return {ok = false, status = "corrupt", reason = "缺少 roomKey"} -- 873
	end -- 873
	local routeRaw = fields.route or "" -- 875
	if routeRaw ~= "" and routeRaw ~= "child" and routeRaw ~= "soldier" then -- 875
		return {ok = false, status = "corrupt", reason = "route 取值非法"} -- 877
	end -- 877
	local settled = parseBoolField(fields.settled, false) -- 879
	local handDone = parseBoolField(fields.handDone, false) -- 880
	local lineSaid = parseBoolField(fields.lineSaid, false) -- 881
	local tied = parseBoolField(fields.tied, false) -- 882
	local carry = parseBoolField(fields.carry, false) -- 883
	local escortDone = parseBoolField(fields.escortDone, false) -- 884
	local cartDocked = parseBoolField(fields.cartDocked, false) -- 885
	local joined = parseBoolField(fields.joined, false) -- 886
	local c1Latch = parseBoolField(fields.c1Latch, false) -- 887
	local c2Latch = parseBoolField(fields.c2Latch, false) -- 888
	if settled == nil or handDone == nil or lineSaid == nil or tied == nil or carry == nil or escortDone == nil or cartDocked == nil or joined == nil or c1Latch == nil or c2Latch == nil then -- 888
		return {ok = false, status = "corrupt", reason = "布尔字段非法"} -- 892
	end -- 892
	local campRouteRaw = fields.campaignRoute or "" -- 894
	if campRouteRaw ~= "" and campRouteRaw ~= "outer" and campRouteRaw ~= "drygoods" then -- 894
		return {ok = false, status = "corrupt", reason = "campaignRoute 取值非法"} -- 896
	end -- 896
	local hp = intOf(fields.hp or "3", -1) -- 898
	local maxHp = intOf(fields.maxHp or "3", -1) -- 899
	if hp < 0 or maxHp <= 0 then -- 899
		return {ok = false, status = "corrupt", reason = "血量字段非法"} -- 901
	end -- 901
	return { -- 903
		ok = true, -- 904
		status = "ok", -- 905
		reason = "ok", -- 906
		state = { -- 907
			roomKey = roomKey, -- 908
			checkpoint = intOf(fields.checkpoint or "0", 0), -- 909
			seed = intOf(fields.seed or "20261124", 20261124), -- 910
			route = routeRaw, -- 911
			hp = hp, -- 912
			maxHp = maxHp, -- 913
			hpAtGate = intOf(fields.hpAtGate or "-1", -1), -- 914
			maxHpAtGate = intOf(fields.maxHpAtGate or "-1", -1), -- 915
			settled = settled, -- 916
			phase = fields.phase or "", -- 917
			countTick = math.max( -- 918
				0, -- 918
				intOf(fields.countTick or "0", 0) -- 918
			), -- 918
			phaseTick = math.max( -- 919
				0, -- 919
				intOf(fields.phaseTick or "0", 0) -- 919
			), -- 919
			handTicks = math.max( -- 920
				0, -- 920
				intOf(fields.handTicks or "0", 0) -- 920
			), -- 920
			handDone = handDone, -- 921
			lineSaid = lineSaid, -- 922
			tied = tied, -- 923
			carry = carry, -- 924
			escortDone = escortDone, -- 925
			craftedWeapon = fields.craftedWeapon or "", -- 926
			equippedWeapon = fields.equippedWeapon or "", -- 927
			wood = math.max( -- 928
				0, -- 928
				intOf(fields.wood or "0", 0) -- 928
			), -- 928
			bell = math.max( -- 929
				0, -- 929
				intOf(fields.bell or "0", 0) -- 929
			), -- 929
			scrap = math.max( -- 930
				0, -- 930
				intOf(fields.scrap or "0", 0) -- 930
			), -- 930
			wedge = math.max( -- 931
				0, -- 931
				intOf(fields.wedge or "0", 0) -- 931
			), -- 931
			ammo = math.max( -- 932
				0, -- 932
				intOf(fields.ammo or "0", 0) -- 932
			), -- 932
			shield = math.max( -- 933
				0, -- 933
				intOf(fields.shield or "0", 0) -- 933
			), -- 933
			pass = math.max( -- 934
				0, -- 934
				intOf(fields.pass or "0", 0) -- 934
			), -- 934
			quickbelt = math.max( -- 935
				0, -- 935
				intOf(fields.quickbelt or "0", 0) -- 935
			), -- 935
			taken = parseListField(fields.taken), -- 936
			segments = parseListField(fields.segments), -- 937
			cartAxle = intOf(fields.cartAxle or "0", 0), -- 938
			cartDocked = cartDocked, -- 939
			campaignRoute = campRouteRaw, -- 940
			joined = joined, -- 941
			c1Latch = c1Latch, -- 942
			c2Latch = c2Latch, -- 943
			talentSeed = math.max( -- 944
				0, -- 944
				intOf(fields.talentSeed or "0", 0) -- 944
			), -- 944
			talentRoom = fields.talentRoom or "", -- 945
			talentOffers = parseListField(fields.talentOffers), -- 946
			talentRanks = parseListField(fields.talentRanks), -- 947
			escortAttempt = math.max( -- 948
				1, -- 948
				intOf(fields.escortAttempt or "1", 1) -- 948
			), -- 948
			escortVariant = math.max( -- 949
				0, -- 949
				intOf(fields.escortVariant or "0", 0) -- 949
			), -- 949
			talentDeferred = parseBoolField(fields.talentDeferred, false) == true, -- 950
			talentVitality = math.max( -- 951
				0, -- 951
				intOf(fields.talentVitality or "0", 0) -- 951
			), -- 951
			talentReload = math.max( -- 952
				0, -- 952
				intOf(fields.talentReload or "0", 0) -- 952
			), -- 952
			talentGuard = math.max( -- 953
				0, -- 953
				intOf(fields.talentGuard or "0", 0) -- 953
			), -- 953
			talentCraft = math.max( -- 954
				0, -- 954
				intOf(fields.talentCraft or "0", 0) -- 954
			), -- 954
			props = parseListField(fields.props), -- 955
			playerX = intOf(fields.playerX or "-1", -1), -- 956
			playerY = intOf(fields.playerY or "0", 0), -- 957
			playerDepth = intOf(fields.playerDepth or "0", 0), -- 958
			gateTick = math.max( -- 959
				0, -- 959
				intOf(fields.gateTick or "0", 0) -- 959
			), -- 959
			hasBottle = parseBoolField(fields.hasBottle, false) == true, -- 960
			villagePassed = parseBoolField(fields.villagePassed, false) == true, -- 961
			savedAt = math.max( -- 962
				0, -- 962
				intOf(fields.savedAt or "0", 0) -- 962
			), -- 962
			playSeconds = math.max( -- 963
				0, -- 963
				intOf(fields.playSeconds or "0", 0) -- 963
			) -- 963
		} -- 963
	} -- 963
end -- 855
local function loadSessionAtPath(relFile, useBackups) -- 968
	local target = absPath(relFile) -- 969
	local tmp = target .. ".tmp" -- 970
	local prev = prevPathFor(target, useBackups) -- 971
	if not ops:exist(target) then -- 971
		if restoreFrom(tmp, target, false, ____exports.parseSession) then -- 971
			local p = ____exports.parseSession(loadText(target)) -- 974
			return { -- 975
				state = p.state, -- 975
				status = "ok", -- 975
				detail = "由 .tmp 恢复局中存档", -- 975
				recovered = true, -- 975
				backup = "" -- 975
			} -- 975
		end -- 975
		if restoreFrom(prev, target, true, ____exports.parseSession) then -- 975
			local p = ____exports.parseSession(loadText(target)) -- 978
			return { -- 979
				state = p.state, -- 979
				status = "ok", -- 979
				detail = "由 .prev 恢复局中存档", -- 979
				recovered = true, -- 979
				backup = "" -- 979
			} -- 979
		end -- 979
		return { -- 981
			state = nil, -- 981
			status = "missing", -- 981
			detail = "无局中存档", -- 981
			recovered = false, -- 981
			backup = "" -- 981
		} -- 981
	end -- 981
	local parsed = ____exports.parseSession(loadText(target)) -- 983
	if parsed.ok and parsed.state ~= nil then -- 983
		if ops:exist(tmp) and sameContent(tmp, target) then -- 983
			ops:remove(tmp) -- 986
		end -- 986
		return { -- 988
			state = parsed.state, -- 988
			status = "ok", -- 988
			detail = "局中存档读取成功", -- 988
			recovered = false, -- 988
			backup = "" -- 988
		} -- 988
	end -- 988
	if parsed.status == "corrupt" then -- 988
		local broken = backupCorrupt(target, ".corrupt", useBackups) -- 991
		if broken ~= "" and restoreFrom(tmp, target, false, ____exports.parseSession) then -- 991
			local p = ____exports.parseSession(loadText(target)) -- 993
			return { -- 994
				state = p.state, -- 994
				status = "ok", -- 994
				detail = "原局中存档损坏，已用 .tmp 恢复", -- 994
				recovered = true, -- 994
				backup = broken -- 994
			} -- 994
		end -- 994
		if broken ~= "" and restoreFrom(prev, target, true, ____exports.parseSession) then -- 994
			local p = ____exports.parseSession(loadText(target)) -- 997
			return { -- 998
				state = p.state, -- 998
				status = "ok", -- 998
				detail = "原局中存档损坏，已用 .prev 恢复", -- 998
				recovered = true, -- 998
				backup = broken -- 998
			} -- 998
		end -- 998
		return { -- 1000
			state = nil, -- 1000
			status = "corrupt", -- 1000
			detail = parsed.reason, -- 1000
			recovered = false, -- 1000
			backup = broken -- 1000
		} -- 1000
	end -- 1000
	local backup = backupCorrupt(target, ".unsupported", useBackups) -- 1002
	return { -- 1003
		state = nil, -- 1003
		status = "unsupported", -- 1003
		detail = parsed.reason, -- 1003
		recovered = false, -- 1003
		backup = backup -- 1003
	} -- 1003
end -- 968
local function peekSlotSummary(slot) -- 1006
	local rel = ____exports.getSlotFile(slot) -- 1007
	local useBackups = usePortableBackupsForSession() -- 1008
	local target = absPath(rel) -- 1009
	local tmp = target .. ".tmp" -- 1010
	local prev = prevPathFor(target, useBackups) -- 1011
	local empty = { -- 1012
		id = slot, -- 1013
		exists = false, -- 1014
		status = "missing", -- 1015
		roomKey = "", -- 1016
		route = "", -- 1017
		hp = 0, -- 1018
		maxHp = 0, -- 1019
		savedAt = 0, -- 1020
		playSeconds = 0, -- 1021
		recovered = false -- 1022
	} -- 1022
	local candidates = {{path = target, rec = false}, {path = tmp, rec = true}, {path = prev, rec = true}} -- 1024
	local primaryStatus = "missing" -- 1029
	local i = 0 -- 1030
	do -- 1030
		i = 0 -- 1031
		while i < #candidates do -- 1031
			do -- 1031
				local c = candidates[i + 1] -- 1032
				if not ops:exist(c.path) then -- 1032
					goto __continue178 -- 1034
				end -- 1034
				local parsed = ____exports.parseSession(loadText(c.path)) -- 1036
				if parsed.ok and parsed.state ~= nil then -- 1036
					return { -- 1038
						id = slot, -- 1039
						exists = true, -- 1040
						status = "ok", -- 1041
						roomKey = parsed.state.roomKey, -- 1042
						route = parsed.state.route, -- 1043
						hp = parsed.state.hp, -- 1044
						maxHp = parsed.state.maxHp, -- 1045
						savedAt = parsed.state.savedAt or 0, -- 1046
						playSeconds = parsed.state.playSeconds or 0, -- 1047
						recovered = c.rec -- 1048
					} -- 1048
				end -- 1048
				if i == 0 then -- 1048
					primaryStatus = parsed.status -- 1052
					if primaryStatus == "unsupported" then -- 1052
						break -- 1053
					end -- 1053
				end -- 1053
			end -- 1053
			::__continue178:: -- 1053
			i = i + 1 -- 1031
		end -- 1031
	end -- 1031
	if primaryStatus ~= "missing" then -- 1031
		empty.status = primaryStatus -- 1057
	end -- 1057
	return empty -- 1059
end -- 1006
function ____exports.hasSlotSave(slot) -- 1062
	return peekSlotSummary(slot).exists -- 1063
end -- 1062
function ____exports.loadSlot(slot) -- 1066
	return loadSessionAtPath( -- 1067
		____exports.getSlotFile(slot), -- 1067
		usePortableBackupsForSession() -- 1067
	) -- 1067
end -- 1066
function ____exports.saveSlot(slot, state) -- 1070
	return writeSaveFile( -- 1071
		absPath(____exports.getSlotFile(slot)), -- 1071
		____exports.formatSession(state), -- 1071
		usePortableBackupsForSession(), -- 1071
		____exports.parseSession -- 1071
	) -- 1071
end -- 1070
function ____exports.deleteSlot(slot) -- 1074
	return removeSaveFiles( -- 1075
		absPath(____exports.getSlotFile(slot)), -- 1075
		usePortableBackupsForSession() -- 1075
	) -- 1075
end -- 1074
function ____exports.listSaveSlots() -- 1078
	return { -- 1079
		peekSlotSummary("auto"), -- 1080
		peekSlotSummary(1), -- 1081
		peekSlotSummary(2), -- 1082
		peekSlotSummary(3) -- 1083
	} -- 1083
end -- 1078
function ____exports.hasAnySaveSlot() -- 1087
	return ____exports.hasSlotSave("auto") or ____exports.hasSlotSave(1) or ____exports.hasSlotSave(2) or ____exports.hasSlotSave(3) -- 1088
end -- 1087
function ____exports.hasSessionSave() -- 1091
	return ____exports.hasSlotSave("auto") -- 1092
end -- 1091
function ____exports.loadSession() -- 1095
	return ____exports.loadSlot("auto") -- 1096
end -- 1095
function ____exports.saveSession(state) -- 1099
	return ____exports.saveSlot("auto", state) -- 1100
end -- 1099
function ____exports.clearSession() -- 1103
	local target = absPath(____exports.getSlotFile("auto")) -- 1105
	local useBackups = usePortableBackupsForSession() -- 1106
	local files = {} -- 1107
	local needsBackup = false -- 1108
	for ____, path in ipairs({ -- 1109
		target, -- 1109
		target .. ".tmp", -- 1109
		prevPathFor(target, useBackups) -- 1109
	}) do -- 1109
		do -- 1109
			if not ops:exist(path) then -- 1109
				goto __continue194 -- 1110
			end -- 1110
			local text = ops:load(path) -- 1111
			if text == nil then -- 1111
				return false -- 1112
			end -- 1112
			local status = ____exports.parseSession(text).status -- 1113
			files[#files + 1] = {path = path, status = status} -- 1114
			if status ~= "ok" then -- 1114
				needsBackup = true -- 1115
			end -- 1115
		end -- 1115
		::__continue194:: -- 1115
	end -- 1115
	if needsBackup then -- 1115
		for ____, file in ipairs(files) do -- 1119
			local suffix = file.status == "ok" and ".reset" or "." .. file.status -- 1120
			if backupCorrupt(file.path, suffix, useBackups, true) == "" then -- 1120
				return false -- 1121
			end -- 1121
		end -- 1121
	end -- 1121
	return removeSaveFiles(target, useBackups) -- 1124
end -- 1103
return ____exports -- 1103