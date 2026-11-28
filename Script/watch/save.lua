-- [ts]: save.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local isPortableSaveLayout, effectiveSaveFile, usePortableBackupsForProfile, absPath, baseNameOf, ensureDir, prevPathFor, readFields, intOf, formatSave, parseSave, normalize, sameContent, matchesText, backupPathFor, backupCorrupt, copyVerified, dirOf, writeSaveFile, ops, fault, customSaveFile -- 1
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
function backupPathFor(target, suffix, useBackupsDir) -- 339
	if useBackupsDir == nil then -- 339
		useBackupsDir = false -- 339
	end -- 339
	local prefix = useBackupsDir and absPath("backups/" .. baseNameOf(target)) or target -- 340
	local candidate = prefix .. suffix -- 341
	if not ops:exist(candidate) then -- 341
		return candidate -- 343
	end -- 343
	local n = 2 -- 345
	while n <= 9999 do -- 345
		candidate = ((prefix .. suffix) .. ".") .. tostring(n) -- 347
		if not ops:exist(candidate) then -- 347
			return candidate -- 349
		end -- 349
		n = n + 1 -- 351
	end -- 351
	return "" -- 353
end -- 353
function backupCorrupt(target, suffix, useBackupsDir) -- 360
	if useBackupsDir == nil then -- 360
		useBackupsDir = false -- 360
	end -- 360
	if not ops:exist(target) then -- 360
		return "" -- 362
	end -- 362
	local backup = backupPathFor(target, suffix, useBackupsDir) -- 364
	if backup == "" then -- 364
		return "" -- 366
	end -- 366
	ensureDir(dirOf(backup)) -- 368
	return copyVerified(target, backup) and backup or "" -- 369
end -- 369
function copyVerified(from, to) -- 384
	return ops:copy(from, to) and sameContent(from, to) -- 385
end -- 385
function dirOf(path) -- 480
	local i = #path - 1 -- 481
	do -- 481
		while i >= 0 do -- 481
			local ch = __TS__StringCharAt(path, i) -- 483
			if ch == "/" or ch == "\\" then -- 483
				return __TS__StringSubstring(path, 0, i) -- 485
			end -- 485
			i = i - 1 -- 482
		end -- 482
	end -- 482
	return "" -- 488
end -- 488
--- 写入档案：写 `.tmp` → 校验 → 备份旧档到 `.prev`（校验成功才继续）→ 覆盖目标 → 回读校验。
-- 失败语义：
--   - 备份失败：不覆盖目标，清掉本次 `.tmp`（旧档完好），返回 false；
--   - 覆盖失败：尝试从 `.prev` 回滚；`.tmp` 保留为最新候选，返回 false；
--   - 校验失败：用 `.prev` 回滚；回滚失败则保留 `.tmp`，返回 false。
-- 未知版本原件（按路径保护）拒绝写入。
function ____exports.saveSave(state) -- 499
	return writeSaveFile( -- 500
		____exports.savePath(), -- 500
		formatSave(state), -- 500
		usePortableBackupsForProfile(), -- 500
		parseSave, -- 500
		fault -- 500
	) -- 500
end -- 499
function writeSaveFile(target, text, useBackups, parse, failure) -- 503
	if failure == nil then -- 503
		failure = "" -- 503
	end -- 503
	if failure == "write" then -- 503
		return false -- 504
	end -- 504
	ensureDir(dirOf(target)) -- 505
	local tmp = target .. ".tmp" -- 506
	local prev = prevPathFor(target, useBackups) -- 507
	local status = "missing" -- 508
	if ops:exist(target) then -- 508
		local original = ops:load(target) -- 510
		if original == nil then -- 510
			return false -- 511
		end -- 511
		status = parse(original).status -- 512
		if status == "unsupported" then -- 512
			return false -- 513
		end -- 513
		if status == "corrupt" and backupCorrupt(target, ".corrupt", useBackups) == "" then -- 513
			return false -- 514
		end -- 514
	end -- 514
	if status ~= "ok" and ops:exist(tmp) then -- 514
		local candidate = ops:load(tmp) -- 519
		if candidate == nil then -- 519
			return false -- 520
		end -- 520
		local candidateStatus = parse(candidate).status -- 521
		if candidateStatus == "unsupported" then -- 521
			return false -- 522
		end -- 522
		if candidateStatus == "ok" then -- 522
			if not copyVerified(tmp, target) then -- 522
				return false -- 524
			end -- 524
			status = "ok" -- 525
		end -- 525
	end -- 525
	if not ops:save(tmp, text) or not matchesText(tmp, text) then -- 525
		ops:remove(tmp) -- 529
		return false -- 530
	end -- 530
	if status == "ok" then -- 530
		ensureDir(dirOf(prev)) -- 533
		if not copyVerified(target, prev) then -- 533
			ops:remove(tmp) -- 535
			return false -- 536
		end -- 536
	end -- 536
	if failure == "replace" or not ops:copy(tmp, target) then -- 536
		if status == "ok" and not sameContent(target, prev) then -- 536
			copyVerified(prev, target) -- 540
		end -- 540
		return false -- 541
	end -- 541
	if failure == "verify" or not matchesText(target, text) then -- 541
		if status == "ok" and copyVerified(prev, target) then -- 541
			ops:remove(tmp) -- 544
		end -- 544
		return false -- 545
	end -- 545
	ops:remove(tmp) -- 547
	return true -- 548
end -- 548
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
local function loadText(path) -- 373
	local text = ops:load(path) -- 374
	if text == nil then -- 374
		return "" -- 376
	end -- 376
	return text -- 378
end -- 373
local function restoreFrom(candidate, target, keepCandidate, parse) -- 388
	if not ops:exist(candidate) or parse(loadText(candidate)).status ~= "ok" then -- 388
		return false -- 389
	end -- 389
	ensureDir(dirOf(target)) -- 390
	if not copyVerified(candidate, target) then -- 390
		return false -- 391
	end -- 391
	if not keepCandidate then -- 391
		ops:remove(candidate) -- 392
	end -- 392
	return true -- 393
end -- 388
--- 读取档案。
-- 自愈顺序：
--   目标缺失 → 完整 `.tmp` → 完整 `.prev`；
--   目标损坏 → 完整 `.tmp`（最新候选）→ 完整 `.prev`。
-- 损坏/未知版本先派生备份；普通写档按原件版本判断能否覆盖。
function ____exports.loadSave() -- 403
	local target = absPath(effectiveSaveFile()) -- 404
	local useBackups = usePortableBackupsForProfile() -- 405
	local tmp = target .. ".tmp" -- 406
	local prev = prevPathFor(target, useBackups) -- 407
	local recovered = false -- 408
	local recoveryDetail = "" -- 409
	if not ops:exist(target) then -- 409
		if restoreFrom(tmp, target, false, parseSave) then -- 409
			recovered = true -- 413
			recoveryDetail = "目标缺失，已用完整 .tmp 恢复" -- 414
		elseif restoreFrom(prev, target, true, parseSave) then -- 414
			recovered = true -- 416
			recoveryDetail = "目标缺失，已用完整 .prev 恢复" -- 417
		end -- 417
	end -- 417
	if not ops:exist(target) then -- 417
		return { -- 422
			state = ____exports.emptySave(), -- 423
			status = "missing", -- 423
			detail = "无档案，按新档起局" .. (recovered and ("（" .. recoveryDetail) .. "）" or ""), -- 424
			recovered = recovered, -- 425
			backup = "", -- 425
			action = "none" -- 425
		} -- 425
	end -- 425
	local text = ops:load(target) -- 429
	local parsed = parseSave(text == nil and "" or text) -- 430
	if parsed.ok then -- 430
		if ops:exist(tmp) and sameContent(tmp, target) then -- 430
			ops:remove(tmp) -- 434
		end -- 434
		return { -- 436
			state = parsed.state, -- 437
			status = "ok", -- 437
			detail = parsed.reason .. (recovered and ("（" .. recoveryDetail) .. "）" or ""), -- 438
			recovered = recovered, -- 439
			backup = "", -- 439
			action = "keep" -- 439
		} -- 439
	end -- 439
	if parsed.status == "corrupt" then -- 439
		local broken = backupCorrupt(target, ".corrupt", useBackups) -- 444
		if broken ~= "" and restoreFrom(tmp, target, false, parseSave) then -- 444
			return { -- 446
				state = parseSave(loadText(target)).state, -- 447
				status = "ok", -- 448
				detail = (("原档损坏（" .. parsed.reason) .. "），已用完整 .tmp 恢复，损坏件备份为 ") .. broken, -- 449
				recovered = true, -- 450
				backup = broken, -- 450
				action = "keep" -- 450
			} -- 450
		end -- 450
		if broken ~= "" and restoreFrom(prev, target, true, parseSave) then -- 450
			return { -- 454
				state = parseSave(loadText(target)).state, -- 455
				status = "ok", -- 456
				detail = (("原档损坏（" .. parsed.reason) .. "），已用 .prev 恢复，损坏件备份为 ") .. broken, -- 457
				recovered = true, -- 458
				backup = broken, -- 458
				action = "keep" -- 458
			} -- 458
		end -- 458
		return { -- 462
			state = ____exports.emptySave(), -- 463
			status = "corrupt", -- 463
			detail = (("档案损坏（" .. parsed.reason) .. "），原件保留") .. (broken ~= "" and "，损坏件备份为 " .. broken or "，备份失败（原件未动）"), -- 464
			recovered = false, -- 466
			backup = broken, -- 466
			action = "reset" -- 466
		} -- 466
	end -- 466
	local backup = backupCorrupt(target, ".unsupported", useBackups) -- 470
	return { -- 471
		state = ____exports.emptySave(), -- 472
		status = "unsupported", -- 472
		detail = (("档案版本不支持（" .. parsed.reason) .. "），原件保留") .. (backup ~= "" and "：" .. backup or "，备份失败（原件未动）"), -- 473
		recovered = recovered, -- 475
		backup = backup, -- 475
		action = "reset" -- 475
	} -- 475
end -- 403
--- 先清理可复活进度的候选件，失败时保留当前主文件供重试。
local function removeSaveFiles(target, useBackups) -- 552
	for ____, path in ipairs({ -- 553
		prevPathFor(target, useBackups), -- 553
		target .. ".tmp", -- 553
		target -- 553
	}) do -- 553
		if ops:exist(path) and not ops:remove(path) then -- 553
			return false -- 554
		end -- 554
	end -- 554
	return true -- 556
end -- 552
--- 恢复策略（给前端「档案损坏/版本不支持」页用）：把原件隔离到派生备份后删除。
-- 只有备份复制成功、内容与原件一致，才删除目标和可恢复候选。
function ____exports.resetSave() -- 563
	local target = absPath(effectiveSaveFile()) -- 564
	if not ops:exist(target) then -- 564
		return false -- 566
	end -- 566
	local backup = backupCorrupt( -- 568
		target, -- 568
		".reset", -- 568
		usePortableBackupsForProfile() -- 568
	) -- 568
	if backup == "" then -- 568
		return false -- 570
	end -- 570
	if not removeSaveFiles( -- 570
		target, -- 572
		usePortableBackupsForProfile() -- 572
	) then -- 572
		return false -- 572
	end -- 572
	if ____exports.pendingMatchesCurrent() then -- 572
		____exports.clearProfilePending() -- 573
	end -- 573
	return true -- 574
end -- 563
--- 档案内容签名：用于「正式通关是否变化」的幂等判断。
function ____exports.saveSignature(state) -- 578
	return table.concat({ -- 579
		state.childCleared and "1" or "0", -- 580
		state.soldierCleared and "1" or "0", -- 581
		state.artifactOwned and "1" or "0", -- 582
		state.museumPhase, -- 583
		state.museumSeen and "1" or "0" -- 584
	}, "|") -- 584
end -- 578
____exports.SESSION_VERSION = 1 -- 592
____exports.SESSION_FILE = "watch-save/session.txt" -- 593
local customSessionFile = "" -- 680
local function effectiveSessionFile() -- 682
	if customSessionFile ~= "" then -- 682
		return customSessionFile -- 684
	end -- 684
	return isPortableSaveLayout() and ____exports.PORTABLE_AUTOSAVE_FILE or ____exports.SESSION_FILE -- 686
end -- 682
local function usePortableBackupsForSession() -- 689
	return customSessionFile == "" and isPortableSaveLayout() -- 690
end -- 689
function ____exports.getSlotFile(slot) -- 693
	if slot == "auto" then -- 693
		return effectiveSessionFile() -- 695
	end -- 695
	if customSessionFile ~= "" then -- 695
		return (customSessionFile .. ".slot") .. tostring(slot) -- 698
	end -- 698
	return isPortableSaveLayout() and ("slots/slot_" .. tostring(slot)) .. ".sav" or ("watch-save/slots/slot_" .. tostring(slot)) .. ".sav" -- 700
end -- 693
function ____exports.setSessionFile(path) -- 705
	customSessionFile = path -- 706
end -- 705
function ____exports.getSessionFile() -- 709
	return effectiveSessionFile() -- 710
end -- 709
function ____exports.nowUnixSeconds() -- 713
	local g = _G -- 714
	local ____temp_0 -- 715
	if g.os ~= nil then -- 715
		____temp_0 = g.os.time -- 715
	else -- 715
		____temp_0 = nil -- 715
	end -- 715
	local timeFn = ____temp_0 -- 715
	if type(timeFn) == "function" then -- 715
		local t = timeFn() -- 717
		if type(t) == "number" and t > 0 then -- 717
			return math.floor(t) -- 719
		end -- 719
	end -- 719
	return 0 -- 722
end -- 713
function ____exports.formatSavedAt(ts) -- 725
	if ts <= 0 then -- 725
		return "" -- 727
	end -- 727
	local g = _G -- 729
	local ____temp_1 -- 730
	if g.os ~= nil then -- 730
		____temp_1 = g.os.date -- 730
	else -- 730
		____temp_1 = nil -- 730
	end -- 730
	local dateFn = ____temp_1 -- 730
	if type(dateFn) == "function" then -- 730
		local s = dateFn("%Y-%m-%d %H:%M", ts) -- 732
		if type(s) == "string" then -- 732
			return s -- 734
		end -- 734
	end -- 734
	return "" -- 737
end -- 725
function ____exports.formatPlayDuration(sec) -- 740
	local total = math.max( -- 741
		0, -- 741
		math.floor(sec) -- 741
	) -- 741
	if total <= 0 then -- 741
		return "" -- 743
	end -- 743
	local h = math.floor(total / 3600) -- 745
	local m = math.floor(total % 3600 / 60) -- 746
	local s = total % 60 -- 747
	local mm = m < 10 and "0" .. tostring(m) or "" .. tostring(m) -- 748
	local ss = s < 10 and "0" .. tostring(s) or "" .. tostring(s) -- 749
	if h > 0 then -- 749
		return (((tostring(h) .. ":") .. mm) .. ":") .. ss -- 751
	end -- 751
	return (mm .. ":") .. ss -- 753
end -- 740
local function parseBoolField(raw, fallback) -- 756
	if raw == nil then -- 756
		return fallback -- 758
	end -- 758
	if raw == "true" or raw == "1" then -- 758
		return true -- 761
	end -- 761
	if raw == "false" or raw == "0" then -- 761
		return false -- 764
	end -- 764
	return nil -- 766
end -- 756
local function parseListField(raw) -- 769
	if raw == nil or raw == "" then -- 769
		return {} -- 771
	end -- 771
	local parts = __TS__StringSplit(raw, ",") -- 773
	local out = {} -- 774
	local i = 0 -- 775
	do -- 775
		i = 0 -- 776
		while i < #parts do -- 776
			local item = __TS__StringTrim(parts[i + 1]) -- 777
			if item ~= "" then -- 777
				out[#out + 1] = item -- 779
			end -- 779
			i = i + 1 -- 776
		end -- 776
	end -- 776
	return out -- 782
end -- 769
function ____exports.formatSession(s) -- 785
	return table.concat( -- 786
		{ -- 786
			"version=" .. tostring(____exports.SESSION_VERSION), -- 787
			"roomKey=" .. s.roomKey, -- 788
			"checkpoint=" .. tostring(math.floor(s.checkpoint + 0.5)), -- 789
			"seed=" .. tostring(math.floor(s.seed + 0.5)), -- 790
			"route=" .. s.route, -- 791
			"hp=" .. tostring(math.floor(s.hp + 0.5)), -- 792
			"maxHp=" .. tostring(math.floor(s.maxHp + 0.5)), -- 793
			"hpAtGate=" .. tostring(math.floor(s.hpAtGate + 0.5)), -- 794
			"maxHpAtGate=" .. tostring(math.floor(s.maxHpAtGate + 0.5)), -- 795
			"settled=" .. (s.settled and "true" or "false"), -- 796
			"phase=" .. s.phase, -- 797
			"countTick=" .. tostring(math.floor(s.countTick + 0.5)), -- 798
			"phaseTick=" .. tostring(math.floor(s.phaseTick + 0.5)), -- 799
			"handTicks=" .. tostring(math.floor(s.handTicks + 0.5)), -- 800
			"handDone=" .. (s.handDone and "true" or "false"), -- 801
			"lineSaid=" .. (s.lineSaid and "true" or "false"), -- 802
			"tied=" .. (s.tied and "true" or "false"), -- 803
			"carry=" .. (s.carry and "true" or "false"), -- 804
			"escortDone=" .. (s.escortDone and "true" or "false"), -- 805
			"craftedWeapon=" .. s.craftedWeapon, -- 806
			"equippedWeapon=" .. s.equippedWeapon, -- 807
			"wood=" .. tostring(math.floor(s.wood + 0.5)), -- 808
			"bell=" .. tostring(math.floor(s.bell + 0.5)), -- 809
			"scrap=" .. tostring(math.floor(s.scrap + 0.5)), -- 810
			"wedge=" .. tostring(math.floor(s.wedge + 0.5)), -- 811
			"ammo=" .. tostring(math.floor(s.ammo + 0.5)), -- 812
			"shield=" .. tostring(math.floor(s.shield + 0.5)), -- 813
			"pass=" .. tostring(math.floor(s.pass + 0.5)), -- 814
			"quickbelt=" .. tostring(math.floor(s.quickbelt + 0.5)), -- 815
			"taken=" .. table.concat(s.taken, ","), -- 816
			"segments=" .. table.concat(s.segments, ","), -- 817
			"cartAxle=" .. tostring(math.floor(s.cartAxle + 0.5)), -- 818
			"cartDocked=" .. (s.cartDocked and "true" or "false"), -- 819
			"campaignRoute=" .. (s.campaignRoute or ""), -- 820
			"joined=" .. (s.joined == true and "true" or "false"), -- 821
			"c1Latch=" .. (s.c1Latch == true and "true" or "false"), -- 822
			"c2Latch=" .. (s.c2Latch == true and "true" or "false"), -- 823
			"talentSeed=" .. tostring(math.floor((s.talentSeed or 0) + 0.5)), -- 824
			"talentRoom=" .. (s.talentRoom or ""), -- 825
			"talentOffers=" .. (s.talentOffers == nil and "" or table.concat(s.talentOffers, ",")), -- 826
			"talentRanks=" .. (s.talentRanks == nil and "" or table.concat(s.talentRanks, ",")), -- 827
			"escortAttempt=" .. tostring(math.floor((s.escortAttempt or 1) + 0.5)), -- 828
			"escortVariant=" .. tostring(math.floor((s.escortVariant or 0) + 0.5)), -- 829
			"talentDeferred=" .. (s.talentDeferred == true and "true" or "false"), -- 830
			"talentVitality=" .. tostring(math.floor((s.talentVitality or 0) + 0.5)), -- 831
			"talentReload=" .. tostring(math.floor((s.talentReload or 0) + 0.5)), -- 832
			"talentGuard=" .. tostring(math.floor((s.talentGuard or 0) + 0.5)), -- 833
			"talentCraft=" .. tostring(math.floor((s.talentCraft or 0) + 0.5)), -- 834
			"props=" .. (s.props == nil and "" or table.concat(s.props, ",")), -- 835
			"playerX=" .. tostring(s.playerX == nil and -1 or math.floor(s.playerX + 0.5)), -- 836
			"playerY=" .. tostring(s.playerY == nil and 0 or math.floor(s.playerY + 0.5)), -- 837
			"playerDepth=" .. tostring(s.playerDepth == nil and 0 or math.floor(s.playerDepth + 0.5)), -- 838
			"gateTick=" .. tostring(math.floor((s.gateTick or 0) + 0.5)), -- 839
			"hasBottle=" .. (s.hasBottle == true and "true" or "false"), -- 840
			"villagePassed=" .. (s.villagePassed == true and "true" or "false"), -- 841
			"savedAt=" .. tostring(math.floor((s.savedAt ~= nil and s.savedAt > 0 and s.savedAt or ____exports.nowUnixSeconds()) + 0.5)), -- 842
			"playSeconds=" .. tostring(math.max( -- 843
				0, -- 843
				math.floor((s.playSeconds or 0) + 0.5) -- 843
			)), -- 843
			"" -- 844
		}, -- 844
		"\n" -- 845
	) -- 845
end -- 785
function ____exports.parseSession(text) -- 848
	if #text == 0 then -- 848
		return {ok = false, status = "corrupt", reason = "局中存档为空"} -- 850
	end -- 850
	local fields = readFields(text) -- 852
	local verRaw = fields.version -- 853
	if verRaw == nil then -- 853
		return {ok = false, status = "corrupt", reason = "缺少 version 行"} -- 855
	end -- 855
	local ver = intOf(verRaw, -1) -- 857
	if ver < 0 then -- 857
		return {ok = false, status = "corrupt", reason = "version 非法"} -- 859
	end -- 859
	if ver > ____exports.SESSION_VERSION then -- 859
		return { -- 862
			ok = false, -- 862
			status = "unsupported", -- 862
			reason = (("局中存档版本 " .. tostring(ver)) .. " 高于当前 ") .. tostring(____exports.SESSION_VERSION) -- 862
		} -- 862
	end -- 862
	local roomKey = fields.roomKey -- 864
	if roomKey == nil or roomKey == "" then -- 864
		return {ok = false, status = "corrupt", reason = "缺少 roomKey"} -- 866
	end -- 866
	local routeRaw = fields.route or "" -- 868
	if routeRaw ~= "" and routeRaw ~= "child" and routeRaw ~= "soldier" then -- 868
		return {ok = false, status = "corrupt", reason = "route 取值非法"} -- 870
	end -- 870
	local settled = parseBoolField(fields.settled, false) -- 872
	local handDone = parseBoolField(fields.handDone, false) -- 873
	local lineSaid = parseBoolField(fields.lineSaid, false) -- 874
	local tied = parseBoolField(fields.tied, false) -- 875
	local carry = parseBoolField(fields.carry, false) -- 876
	local escortDone = parseBoolField(fields.escortDone, false) -- 877
	local cartDocked = parseBoolField(fields.cartDocked, false) -- 878
	local joined = parseBoolField(fields.joined, false) -- 879
	local c1Latch = parseBoolField(fields.c1Latch, false) -- 880
	local c2Latch = parseBoolField(fields.c2Latch, false) -- 881
	if settled == nil or handDone == nil or lineSaid == nil or tied == nil or carry == nil or escortDone == nil or cartDocked == nil or joined == nil or c1Latch == nil or c2Latch == nil then -- 881
		return {ok = false, status = "corrupt", reason = "布尔字段非法"} -- 885
	end -- 885
	local campRouteRaw = fields.campaignRoute or "" -- 887
	if campRouteRaw ~= "" and campRouteRaw ~= "outer" and campRouteRaw ~= "drygoods" then -- 887
		return {ok = false, status = "corrupt", reason = "campaignRoute 取值非法"} -- 889
	end -- 889
	local hp = intOf(fields.hp or "3", -1) -- 891
	local maxHp = intOf(fields.maxHp or "3", -1) -- 892
	if hp < 0 or maxHp <= 0 then -- 892
		return {ok = false, status = "corrupt", reason = "血量字段非法"} -- 894
	end -- 894
	return { -- 896
		ok = true, -- 897
		status = "ok", -- 898
		reason = "ok", -- 899
		state = { -- 900
			roomKey = roomKey, -- 901
			checkpoint = intOf(fields.checkpoint or "0", 0), -- 902
			seed = intOf(fields.seed or "20261124", 20261124), -- 903
			route = routeRaw, -- 904
			hp = hp, -- 905
			maxHp = maxHp, -- 906
			hpAtGate = intOf(fields.hpAtGate or "-1", -1), -- 907
			maxHpAtGate = intOf(fields.maxHpAtGate or "-1", -1), -- 908
			settled = settled, -- 909
			phase = fields.phase or "", -- 910
			countTick = math.max( -- 911
				0, -- 911
				intOf(fields.countTick or "0", 0) -- 911
			), -- 911
			phaseTick = math.max( -- 912
				0, -- 912
				intOf(fields.phaseTick or "0", 0) -- 912
			), -- 912
			handTicks = math.max( -- 913
				0, -- 913
				intOf(fields.handTicks or "0", 0) -- 913
			), -- 913
			handDone = handDone, -- 914
			lineSaid = lineSaid, -- 915
			tied = tied, -- 916
			carry = carry, -- 917
			escortDone = escortDone, -- 918
			craftedWeapon = fields.craftedWeapon or "", -- 919
			equippedWeapon = fields.equippedWeapon or "", -- 920
			wood = math.max( -- 921
				0, -- 921
				intOf(fields.wood or "0", 0) -- 921
			), -- 921
			bell = math.max( -- 922
				0, -- 922
				intOf(fields.bell or "0", 0) -- 922
			), -- 922
			scrap = math.max( -- 923
				0, -- 923
				intOf(fields.scrap or "0", 0) -- 923
			), -- 923
			wedge = math.max( -- 924
				0, -- 924
				intOf(fields.wedge or "0", 0) -- 924
			), -- 924
			ammo = math.max( -- 925
				0, -- 925
				intOf(fields.ammo or "0", 0) -- 925
			), -- 925
			shield = math.max( -- 926
				0, -- 926
				intOf(fields.shield or "0", 0) -- 926
			), -- 926
			pass = math.max( -- 927
				0, -- 927
				intOf(fields.pass or "0", 0) -- 927
			), -- 927
			quickbelt = math.max( -- 928
				0, -- 928
				intOf(fields.quickbelt or "0", 0) -- 928
			), -- 928
			taken = parseListField(fields.taken), -- 929
			segments = parseListField(fields.segments), -- 930
			cartAxle = intOf(fields.cartAxle or "0", 0), -- 931
			cartDocked = cartDocked, -- 932
			campaignRoute = campRouteRaw, -- 933
			joined = joined, -- 934
			c1Latch = c1Latch, -- 935
			c2Latch = c2Latch, -- 936
			talentSeed = math.max( -- 937
				0, -- 937
				intOf(fields.talentSeed or "0", 0) -- 937
			), -- 937
			talentRoom = fields.talentRoom or "", -- 938
			talentOffers = parseListField(fields.talentOffers), -- 939
			talentRanks = parseListField(fields.talentRanks), -- 940
			escortAttempt = math.max( -- 941
				1, -- 941
				intOf(fields.escortAttempt or "1", 1) -- 941
			), -- 941
			escortVariant = math.max( -- 942
				0, -- 942
				intOf(fields.escortVariant or "0", 0) -- 942
			), -- 942
			talentDeferred = parseBoolField(fields.talentDeferred, false) == true, -- 943
			talentVitality = math.max( -- 944
				0, -- 944
				intOf(fields.talentVitality or "0", 0) -- 944
			), -- 944
			talentReload = math.max( -- 945
				0, -- 945
				intOf(fields.talentReload or "0", 0) -- 945
			), -- 945
			talentGuard = math.max( -- 946
				0, -- 946
				intOf(fields.talentGuard or "0", 0) -- 946
			), -- 946
			talentCraft = math.max( -- 947
				0, -- 947
				intOf(fields.talentCraft or "0", 0) -- 947
			), -- 947
			props = parseListField(fields.props), -- 948
			playerX = intOf(fields.playerX or "-1", -1), -- 949
			playerY = intOf(fields.playerY or "0", 0), -- 950
			playerDepth = intOf(fields.playerDepth or "0", 0), -- 951
			gateTick = math.max( -- 952
				0, -- 952
				intOf(fields.gateTick or "0", 0) -- 952
			), -- 952
			hasBottle = parseBoolField(fields.hasBottle, false) == true, -- 953
			villagePassed = parseBoolField(fields.villagePassed, false) == true, -- 954
			savedAt = math.max( -- 955
				0, -- 955
				intOf(fields.savedAt or "0", 0) -- 955
			), -- 955
			playSeconds = math.max( -- 956
				0, -- 956
				intOf(fields.playSeconds or "0", 0) -- 956
			) -- 956
		} -- 956
	} -- 956
end -- 848
local function loadSessionAtPath(relFile, useBackups) -- 961
	local target = absPath(relFile) -- 962
	local tmp = target .. ".tmp" -- 963
	local prev = prevPathFor(target, useBackups) -- 964
	if not ops:exist(target) then -- 964
		if restoreFrom(tmp, target, false, ____exports.parseSession) then -- 964
			local p = ____exports.parseSession(loadText(target)) -- 967
			return { -- 968
				state = p.state, -- 968
				status = "ok", -- 968
				detail = "由 .tmp 恢复局中存档", -- 968
				recovered = true, -- 968
				backup = "" -- 968
			} -- 968
		end -- 968
		if restoreFrom(prev, target, true, ____exports.parseSession) then -- 968
			local p = ____exports.parseSession(loadText(target)) -- 971
			return { -- 972
				state = p.state, -- 972
				status = "ok", -- 972
				detail = "由 .prev 恢复局中存档", -- 972
				recovered = true, -- 972
				backup = "" -- 972
			} -- 972
		end -- 972
		return { -- 974
			state = nil, -- 974
			status = "missing", -- 974
			detail = "无局中存档", -- 974
			recovered = false, -- 974
			backup = "" -- 974
		} -- 974
	end -- 974
	local parsed = ____exports.parseSession(loadText(target)) -- 976
	if parsed.ok and parsed.state ~= nil then -- 976
		if ops:exist(tmp) and sameContent(tmp, target) then -- 976
			ops:remove(tmp) -- 979
		end -- 979
		return { -- 981
			state = parsed.state, -- 981
			status = "ok", -- 981
			detail = "局中存档读取成功", -- 981
			recovered = false, -- 981
			backup = "" -- 981
		} -- 981
	end -- 981
	if parsed.status == "corrupt" then -- 981
		local broken = backupCorrupt(target, ".corrupt", useBackups) -- 984
		if broken ~= "" and restoreFrom(tmp, target, false, ____exports.parseSession) then -- 984
			local p = ____exports.parseSession(loadText(target)) -- 986
			return { -- 987
				state = p.state, -- 987
				status = "ok", -- 987
				detail = "原局中存档损坏，已用 .tmp 恢复", -- 987
				recovered = true, -- 987
				backup = broken -- 987
			} -- 987
		end -- 987
		if broken ~= "" and restoreFrom(prev, target, true, ____exports.parseSession) then -- 987
			local p = ____exports.parseSession(loadText(target)) -- 990
			return { -- 991
				state = p.state, -- 991
				status = "ok", -- 991
				detail = "原局中存档损坏，已用 .prev 恢复", -- 991
				recovered = true, -- 991
				backup = broken -- 991
			} -- 991
		end -- 991
		return { -- 993
			state = nil, -- 993
			status = "corrupt", -- 993
			detail = parsed.reason, -- 993
			recovered = false, -- 993
			backup = broken -- 993
		} -- 993
	end -- 993
	local backup = backupCorrupt(target, ".unsupported", useBackups) -- 995
	return { -- 996
		state = nil, -- 996
		status = "unsupported", -- 996
		detail = parsed.reason, -- 996
		recovered = false, -- 996
		backup = backup -- 996
	} -- 996
end -- 961
local function peekSlotSummary(slot) -- 999
	local rel = ____exports.getSlotFile(slot) -- 1000
	local useBackups = usePortableBackupsForSession() -- 1001
	local target = absPath(rel) -- 1002
	local tmp = target .. ".tmp" -- 1003
	local prev = prevPathFor(target, useBackups) -- 1004
	local empty = { -- 1005
		id = slot, -- 1006
		exists = false, -- 1007
		status = "missing", -- 1008
		roomKey = "", -- 1009
		route = "", -- 1010
		hp = 0, -- 1011
		maxHp = 0, -- 1012
		savedAt = 0, -- 1013
		playSeconds = 0, -- 1014
		recovered = false -- 1015
	} -- 1015
	local candidates = {{path = target, rec = false}, {path = tmp, rec = true}, {path = prev, rec = true}} -- 1017
	local primaryStatus = "missing" -- 1022
	local i = 0 -- 1023
	do -- 1023
		i = 0 -- 1024
		while i < #candidates do -- 1024
			do -- 1024
				local c = candidates[i + 1] -- 1025
				if not ops:exist(c.path) then -- 1025
					goto __continue172 -- 1027
				end -- 1027
				local parsed = ____exports.parseSession(loadText(c.path)) -- 1029
				if parsed.ok and parsed.state ~= nil then -- 1029
					return { -- 1031
						id = slot, -- 1032
						exists = true, -- 1033
						status = "ok", -- 1034
						roomKey = parsed.state.roomKey, -- 1035
						route = parsed.state.route, -- 1036
						hp = parsed.state.hp, -- 1037
						maxHp = parsed.state.maxHp, -- 1038
						savedAt = parsed.state.savedAt or 0, -- 1039
						playSeconds = parsed.state.playSeconds or 0, -- 1040
						recovered = c.rec -- 1041
					} -- 1041
				end -- 1041
				if i == 0 then -- 1041
					primaryStatus = parsed.status -- 1045
					if primaryStatus == "unsupported" then -- 1045
						break -- 1046
					end -- 1046
				end -- 1046
			end -- 1046
			::__continue172:: -- 1046
			i = i + 1 -- 1024
		end -- 1024
	end -- 1024
	if primaryStatus ~= "missing" then -- 1024
		empty.status = primaryStatus -- 1050
	end -- 1050
	return empty -- 1052
end -- 999
function ____exports.hasSlotSave(slot) -- 1055
	return peekSlotSummary(slot).exists -- 1056
end -- 1055
function ____exports.loadSlot(slot) -- 1059
	return loadSessionAtPath( -- 1060
		____exports.getSlotFile(slot), -- 1060
		usePortableBackupsForSession() -- 1060
	) -- 1060
end -- 1059
function ____exports.saveSlot(slot, state) -- 1063
	return writeSaveFile( -- 1064
		absPath(____exports.getSlotFile(slot)), -- 1064
		____exports.formatSession(state), -- 1064
		usePortableBackupsForSession(), -- 1064
		____exports.parseSession -- 1064
	) -- 1064
end -- 1063
function ____exports.deleteSlot(slot) -- 1067
	return removeSaveFiles( -- 1068
		absPath(____exports.getSlotFile(slot)), -- 1068
		usePortableBackupsForSession() -- 1068
	) -- 1068
end -- 1067
function ____exports.listSaveSlots() -- 1071
	return { -- 1072
		peekSlotSummary("auto"), -- 1073
		peekSlotSummary(1), -- 1074
		peekSlotSummary(2), -- 1075
		peekSlotSummary(3) -- 1076
	} -- 1076
end -- 1071
function ____exports.hasAnySaveSlot() -- 1080
	return ____exports.hasSlotSave("auto") or ____exports.hasSlotSave(1) or ____exports.hasSlotSave(2) or ____exports.hasSlotSave(3) -- 1081
end -- 1080
function ____exports.hasSessionSave() -- 1084
	return ____exports.hasSlotSave("auto") -- 1085
end -- 1084
function ____exports.loadSession() -- 1088
	return ____exports.loadSlot("auto") -- 1089
end -- 1088
function ____exports.saveSession(state) -- 1092
	return ____exports.saveSlot("auto", state) -- 1093
end -- 1092
function ____exports.clearSession() -- 1096
	return ____exports.deleteSlot("auto") -- 1097
end -- 1096
return ____exports -- 1096