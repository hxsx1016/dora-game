-- [ts]: save.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local isPortableSaveLayout, copyForWrite, effectiveSaveFile, usePortableBackupsForProfile, absPath, baseNameOf, ensureDir, prevPathFor, lineValue, intOf, formatSave, parseSave, normalize, sameContent, backupPathFor, backupCorrupt, usableBackup, dirOf, ops, fault, customSaveFile, protectedPath -- 1
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
function copyForWrite(from, to) -- 88
	if fault == "replace" then -- 88
		return false -- 90
	end -- 90
	return ops:copy(from, to) -- 92
end -- 92
function effectiveSaveFile() -- 101
	if customSaveFile ~= "" then -- 101
		return customSaveFile -- 103
	end -- 103
	return isPortableSaveLayout() and ____exports.PORTABLE_PROFILE_FILE or ____exports.SAVE_FILE -- 105
end -- 105
function usePortableBackupsForProfile() -- 108
	return customSaveFile == "" and isPortableSaveLayout() -- 109
end -- 109
function absPath(path) -- 113
	if #path > 0 and (string.sub(path, 1, 1) == "/" or string.sub(path, 1, 1) == "\\") then -- 113
		return path -- 115
	end -- 115
	if #path >= 2 and string.sub(path, 2, 2) == ":" then -- 115
		return path -- 118
	end -- 118
	local base = Content.writablePath -- 120
	local sep = (string.find(base, "\\", nil, true) or 0) - 1 >= 0 and (string.find(base, "/", nil, true) or 0) - 1 < 0 and "\\" or "/" -- 121
	local norm = sep == "\\" and table.concat( -- 122
		__TS__StringSplit(path, "/"), -- 122
		"\\" -- 122
	) or path -- 122
	local trimmed = (__TS__StringEndsWith(base, "/") or __TS__StringEndsWith(base, "\\")) and string.sub(base, 1, -2) or base -- 123
	return (trimmed .. sep) .. norm -- 124
end -- 124
function baseNameOf(path) -- 127
	local i = #path - 1 -- 128
	do -- 128
		while i >= 0 do -- 128
			local ch = __TS__StringCharAt(path, i) -- 130
			if ch == "/" or ch == "\\" then -- 130
				return __TS__StringSubstring(path, i + 1) -- 132
			end -- 132
			i = i - 1 -- 129
		end -- 129
	end -- 129
	return path -- 135
end -- 135
function ensureDir(dir) -- 138
	if dir ~= "" and not ops:isdir(dir) then -- 138
		ops:mkdir(dir) -- 140
	end -- 140
end -- 140
function prevPathFor(target, useBackupsDir) -- 144
	if useBackupsDir then -- 144
		return absPath(("backups/" .. baseNameOf(target)) .. ".prev") -- 146
	end -- 146
	return target .. ".prev" -- 148
end -- 148
function ____exports.emptySave() -- 200
	return { -- 201
		childCleared = false, -- 202
		soldierCleared = false, -- 203
		artifactOwned = false, -- 204
		museumPhase = "locked", -- 205
		museumSeen = false -- 206
	} -- 206
end -- 200
function lineValue(text, key) -- 210
	local lines = __TS__StringSplit(text, "\n") -- 211
	local prefix = key .. "=" -- 212
	local i = 0 -- 213
	do -- 213
		i = 0 -- 214
		while i < #lines do -- 214
			local line = lines[i + 1] -- 215
			if #line >= #prefix and __TS__StringSubstring(line, 0, #prefix) == prefix then -- 215
				return __TS__StringSubstring(line, #prefix) -- 217
			end -- 217
			i = i + 1 -- 214
		end -- 214
	end -- 214
	return nil -- 220
end -- 220
function intOf(text, fallback) -- 223
	if #text == 0 then -- 223
		return fallback -- 225
	end -- 225
	local i = 0 -- 227
	local sign = 1 -- 228
	if string.sub(text, 1, 1) == "-" then -- 228
		sign = -1 -- 230
		i = 1 -- 231
	end -- 231
	local n = 0 -- 233
	local digits = 0 -- 234
	do -- 234
		while i < #text do -- 234
			local c = __TS__StringCharCodeAt(text, i) -- 236
			if c < 48 or c > 57 then -- 236
				return fallback -- 238
			end -- 238
			n = n * 10 + (c - 48) -- 240
			digits = digits + 1 -- 241
			i = i + 1 -- 235
		end -- 235
	end -- 235
	if digits == 0 then -- 235
		return fallback -- 244
	end -- 244
	return sign * n -- 246
end -- 246
function formatSave(state) -- 249
	return table.concat( -- 250
		{ -- 250
			"version=" .. tostring(____exports.SAVE_VERSION), -- 251
			"childCleared=" .. (state.childCleared and "true" or "false"), -- 252
			"soldierCleared=" .. (state.soldierCleared and "true" or "false"), -- 253
			"artifactOwned=" .. (state.artifactOwned and "true" or "false"), -- 254
			"museumPhase=" .. state.museumPhase, -- 255
			"museumSeen=" .. (state.museumSeen and "true" or "false"), -- 256
			"" -- 257
		}, -- 257
		"\n" -- 258
	) -- 258
end -- 258
function parseSave(text) -- 272
	local bad = { -- 273
		ok = false, -- 273
		status = "corrupt", -- 273
		reason = "", -- 273
		state = ____exports.emptySave() -- 273
	} -- 273
	if #text == 0 then -- 273
		bad.reason = "档案为空" -- 275
		return bad -- 276
	end -- 276
	local versionText = lineValue(text, "version") -- 278
	if versionText == nil then -- 278
		bad.reason = "缺少 version 行" -- 280
		return bad -- 281
	end -- 281
	local version = intOf(versionText, -1) -- 283
	if version < 0 then -- 283
		bad.reason = "version 不是十进制整数" -- 285
		return bad -- 286
	end -- 286
	if version > ____exports.SAVE_VERSION then -- 286
		return { -- 289
			ok = false, -- 289
			status = "unsupported", -- 289
			reason = (("版本 " .. tostring(version)) .. " 高于 ") .. tostring(____exports.SAVE_VERSION), -- 289
			state = ____exports.emptySave() -- 289
		} -- 289
	end -- 289
	if version ~= ____exports.SAVE_VERSION then -- 289
		bad.reason = "不支持的旧版本 " .. tostring(version) -- 292
		return bad -- 293
	end -- 293
	local boolKeys = {"childCleared", "soldierCleared", "artifactOwned", "museumSeen"} -- 295
	local bools = {} -- 296
	local i = 0 -- 297
	do -- 297
		i = 0 -- 298
		while i < #boolKeys do -- 298
			local value = lineValue(text, boolKeys[i + 1]) -- 299
			if value == nil then -- 299
				bad.reason = "缺少字段 " .. boolKeys[i + 1] -- 301
				return bad -- 302
			end -- 302
			if value ~= "true" and value ~= "false" then -- 302
				bad.reason = ("字段 " .. boolKeys[i + 1]) .. " 不是布尔值" -- 305
				return bad -- 306
			end -- 306
			bools[#bools + 1] = value == "true" -- 308
			i = i + 1 -- 298
		end -- 298
	end -- 298
	local phase = lineValue(text, "museumPhase") -- 310
	if phase == nil then -- 310
		bad.reason = "缺少字段 museumPhase" -- 312
		return bad -- 313
	end -- 313
	if not isMuseumPhase(phase) then -- 313
		bad.reason = "museumPhase 不在枚举内" -- 316
		return bad -- 317
	end -- 317
	return { -- 319
		ok = true, -- 320
		status = "ok", -- 321
		reason = "版本 " .. tostring(version), -- 322
		state = { -- 323
			childCleared = bools[1], -- 324
			soldierCleared = bools[2], -- 325
			artifactOwned = bools[3], -- 326
			museumPhase = phase, -- 327
			museumSeen = bools[4] -- 328
		} -- 328
	} -- 328
end -- 328
function normalize(text) -- 333
	return table.concat( -- 334
		__TS__StringSplit( -- 334
			table.concat( -- 334
				__TS__StringSplit(text, "\r\n"), -- 334
				"\n" -- 334
			), -- 334
			"\r" -- 334
		), -- 334
		"\n" -- 334
	) -- 334
end -- 334
function sameContent(a, b) -- 338
	local textA = ops:load(a) -- 339
	local textB = ops:load(b) -- 340
	if textA == nil or textB == nil then -- 340
		return false -- 342
	end -- 342
	return normalize(textA) == normalize(textB) -- 344
end -- 344
function backupPathFor(target, suffix, useBackupsDir) -- 348
	if useBackupsDir == nil then -- 348
		useBackupsDir = false -- 348
	end -- 348
	local prefix = useBackupsDir and absPath("backups/" .. baseNameOf(target)) or target -- 349
	local candidate = prefix .. suffix -- 350
	if not ops:exist(candidate) then -- 350
		return candidate -- 352
	end -- 352
	local n = 2 -- 354
	while n <= 9999 do -- 354
		candidate = ((prefix .. suffix) .. ".") .. tostring(n) -- 356
		if not ops:exist(candidate) then -- 356
			return candidate -- 358
		end -- 358
		n = n + 1 -- 360
	end -- 360
	return "" -- 362
end -- 362
function backupCorrupt(target, suffix, useBackupsDir) -- 369
	if useBackupsDir == nil then -- 369
		useBackupsDir = false -- 369
	end -- 369
	if not ops:exist(target) then -- 369
		return "" -- 371
	end -- 371
	local backup = backupPathFor(target, suffix, useBackupsDir) -- 373
	if backup == "" then -- 373
		return "" -- 375
	end -- 375
	ensureDir(dirOf(backup)) -- 377
	if not ops:copy(target, backup) then -- 377
		return "" -- 379
	end -- 379
	if not sameContent(target, backup) then -- 379
		return "" -- 382
	end -- 382
	return backup -- 384
end -- 384
function usableBackup(path) -- 397
	if not ops:exist(path) then -- 397
		return false -- 399
	end -- 399
	local text = ops:load(path) -- 401
	return text ~= nil and parseSave(text).ok -- 402
end -- 402
function dirOf(path) -- 508
	local i = #path - 1 -- 509
	do -- 509
		while i >= 0 do -- 509
			local ch = __TS__StringCharAt(path, i) -- 511
			if ch == "/" or ch == "\\" then -- 511
				return __TS__StringSubstring(path, 0, i) -- 513
			end -- 513
			i = i - 1 -- 510
		end -- 510
	end -- 510
	return "" -- 516
end -- 516
--- 写入档案：写 `.tmp` → 校验 → 备份旧档到 `.prev`（校验成功才继续）→ 覆盖目标 → 回读校验。
-- 失败语义：
--   - 备份失败：不覆盖目标，清掉本次 `.tmp`（旧档完好），返回 false；
--   - 覆盖失败：尝试从 `.prev` 回滚；`.tmp` 保留为最新候选，返回 false；
--   - 校验失败：用 `.prev` 回滚；回滚失败则保留 `.tmp`，返回 false。
-- 未知版本原件（按路径保护）拒绝写入。
function ____exports.saveSave(state) -- 527
	local target = absPath(effectiveSaveFile()) -- 528
	if protectedPath == target then -- 528
		return false -- 530
	end -- 530
	local useBackups = usePortableBackupsForProfile() -- 532
	ensureDir(dirOf(target)) -- 533
	local tmp = target .. ".tmp" -- 534
	local prev = prevPathFor(target, useBackups) -- 535
	local text = formatSave(state) -- 536
	if fault == "write" then -- 536
		return false -- 539
	end -- 539
	if not ops:save(tmp, text) then -- 539
		ops:remove(tmp) -- 542
		return false -- 543
	end -- 543
	local written = ops:load(tmp) -- 545
	if written == nil or normalize(written) ~= normalize(text) then -- 545
		ops:remove(tmp) -- 547
		return false -- 548
	end -- 548
	local existed = ops:exist(target) -- 551
	local backedUp = false -- 552
	if existed then -- 552
		if usableBackup(target) then -- 552
			ensureDir(dirOf(prev)) -- 555
			backedUp = ops:copy(target, prev) -- 556
			if not backedUp or not usableBackup(prev) then -- 556
				ops:remove(tmp) -- 559
				return false -- 560
			end -- 560
		else -- 560
			backupCorrupt(target, ".corrupt", useBackups) -- 564
		end -- 564
	end -- 564
	if not copyForWrite(tmp, target) then -- 564
		if existed and backedUp and not sameContent(target, prev) then -- 564
			ops:copy(prev, target) -- 570
		end -- 570
		return false -- 573
	end -- 573
	local check = ops:load(target) -- 576
	if fault == "verify" or check == nil or normalize(check) ~= normalize(text) then -- 576
		if existed and backedUp and ops:copy(prev, target) and usableBackup(target) then -- 576
			ops:remove(tmp) -- 579
			return false -- 580
		end -- 580
		return false -- 583
	end -- 583
	ops:remove(tmp) -- 586
	return true -- 587
end -- 527
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
customSaveFile = "" -- 95
--- 跨 Play 实例的待落盘档案：携带目标路径，切换档案后不会写错档。
local pending = nil -- 97
protectedPath = "" -- 99
--- 测试用：切到隔离档案文件；传空则回正式档案。不清保护位（保护位按路径绑定）。
function ____exports.setSaveFile(path) -- 152
	customSaveFile = path -- 153
end -- 152
--- 登记一份待落盘档案（同拍切房、写失败都由调用方重新登记）。
function ____exports.markProfilePending(state) -- 157
	pending = { -- 158
		state = state, -- 158
		file = effectiveSaveFile() -- 158
	} -- 158
end -- 157
function ____exports.profilePending() -- 161
	return pending ~= nil -- 162
end -- 161
--- 待落盘档案是否属于当前档案路径（切档后不应写错目标）。
function ____exports.pendingMatchesCurrent() -- 166
	return pending ~= nil and pending.file == effectiveSaveFile() -- 167
end -- 166
--- 把登记的档案落盘；成功才清登记，失败保留等下一帧重试。
-- 登记属于别的档案路径时不写、返回 false（调用方应显式丢弃或先切回）。
function ____exports.flushProfile() -- 174
	if pending == nil then -- 174
		return true -- 176
	end -- 176
	if pending.file ~= effectiveSaveFile() then -- 176
		return false -- 179
	end -- 179
	if not ____exports.saveSave(pending.state) then -- 179
		return false -- 182
	end -- 182
	pending = nil -- 184
	return true -- 185
end -- 174
function ____exports.clearProfilePending() -- 188
	pending = nil -- 189
end -- 188
function ____exports.getSaveFile() -- 192
	return effectiveSaveFile() -- 193
end -- 192
function ____exports.savePath() -- 196
	return absPath(effectiveSaveFile()) -- 197
end -- 196
--- 读文本；读不到按空串处理（解析会判 corrupt）。
local function loadText(path) -- 388
	local text = ops:load(path) -- 389
	if text == nil then -- 389
		return "" -- 391
	end -- 391
	return text -- 393
end -- 388
--- 用候选件恢复目标；成功（复制成功且回读解析一致）才清候选，失败保留候选并返回 false。
local function restoreFrom(candidate, target, keepCandidate) -- 406
	if not usableBackup(candidate) then -- 406
		return false -- 408
	end -- 408
	if not ops:copy(candidate, target) then -- 408
		return false -- 411
	end -- 411
	local again = parseSave(loadText(target)) -- 413
	if not again.ok then -- 413
		return false -- 415
	end -- 415
	if not keepCandidate then -- 415
		ops:remove(candidate) -- 418
	end -- 418
	return true -- 420
end -- 406
--- 读取档案。
-- 自愈顺序：
--   目标缺失 → 完整 `.tmp` → 完整 `.prev`；
--   目标损坏 → 完整 `.tmp`（最新候选）→ 完整 `.prev`。
-- 损坏/未知版本先派生备份；未知版本原件置保护位（按路径），普通写档拒绝覆盖。
function ____exports.loadSave() -- 430
	local target = absPath(effectiveSaveFile()) -- 431
	local useBackups = usePortableBackupsForProfile() -- 432
	local tmp = target .. ".tmp" -- 433
	local prev = prevPathFor(target, useBackups) -- 434
	local recovered = false -- 435
	local recoveryDetail = "" -- 436
	if not ops:exist(target) then -- 436
		if restoreFrom(tmp, target, false) then -- 436
			recovered = true -- 440
			recoveryDetail = "目标缺失，已用完整 .tmp 恢复" -- 441
		elseif restoreFrom(prev, target, true) then -- 441
			recovered = true -- 443
			recoveryDetail = "目标缺失，已用完整 .prev 恢复" -- 444
		end -- 444
	end -- 444
	if not ops:exist(target) then -- 444
		return { -- 449
			state = ____exports.emptySave(), -- 450
			status = "missing", -- 450
			detail = "无档案，按新档起局" .. (recovered and ("（" .. recoveryDetail) .. "）" or ""), -- 451
			recovered = recovered, -- 452
			backup = "", -- 452
			action = "none" -- 452
		} -- 452
	end -- 452
	local text = ops:load(target) -- 456
	local parsed = parseSave(text == nil and "" or text) -- 457
	if parsed.ok then -- 457
		if ops:exist(tmp) and sameContent(tmp, target) then -- 457
			ops:remove(tmp) -- 461
		end -- 461
		return { -- 463
			state = parsed.state, -- 464
			status = "ok", -- 464
			detail = parsed.reason .. (recovered and ("（" .. recoveryDetail) .. "）" or ""), -- 465
			recovered = recovered, -- 466
			backup = "", -- 466
			action = "keep" -- 466
		} -- 466
	end -- 466
	if parsed.status == "corrupt" then -- 466
		local broken = backupCorrupt(target, ".corrupt", useBackups) -- 471
		if restoreFrom(tmp, target, false) then -- 471
			return { -- 473
				state = parseSave(loadText(target)).state, -- 474
				status = "ok", -- 475
				detail = (("原档损坏（" .. parsed.reason) .. "），已用完整 .tmp 恢复，损坏件备份为 ") .. broken, -- 476
				recovered = true, -- 477
				backup = broken, -- 477
				action = "keep" -- 477
			} -- 477
		end -- 477
		if restoreFrom(prev, target, true) then -- 477
			return { -- 481
				state = parseSave(loadText(target)).state, -- 482
				status = "ok", -- 483
				detail = (("原档损坏（" .. parsed.reason) .. "），已用 .prev 恢复，损坏件备份为 ") .. broken, -- 484
				recovered = true, -- 485
				backup = broken, -- 485
				action = "keep" -- 485
			} -- 485
		end -- 485
		return { -- 489
			state = ____exports.emptySave(), -- 490
			status = "corrupt", -- 490
			detail = (("档案损坏（" .. parsed.reason) .. "），原件保留") .. (broken ~= "" and "，损坏件备份为 " .. broken or "，备份失败（原件未动）"), -- 491
			recovered = false, -- 493
			backup = broken, -- 493
			action = "reset" -- 493
		} -- 493
	end -- 493
	local backup = backupCorrupt(target, ".unsupported", useBackups) -- 497
	protectedPath = target -- 498
	return { -- 499
		state = ____exports.emptySave(), -- 500
		status = "unsupported", -- 500
		detail = (("档案版本不支持（" .. parsed.reason) .. "），原件保留") .. (backup ~= "" and "：" .. backup or "，备份失败（原件未动）"), -- 501
		recovered = recovered, -- 503
		backup = backup, -- 503
		action = "reset" -- 503
	} -- 503
end -- 430
--- 恢复策略（给前端「档案损坏/版本不支持」页用）：把原件隔离到派生备份后删除。
-- 只有备份复制成功、内容与原件一致、且备份本身可解析时才删除目标。
function ____exports.resetSave() -- 594
	local target = absPath(effectiveSaveFile()) -- 595
	if not ops:exist(target) then -- 595
		return false -- 597
	end -- 597
	local backup = backupCorrupt( -- 599
		target, -- 599
		".reset", -- 599
		usePortableBackupsForProfile() -- 599
	) -- 599
	if backup == "" then -- 599
		return false -- 601
	end -- 601
	if not sameContent(target, backup) then -- 601
		return false -- 605
	end -- 605
	if not ops:remove(target) then -- 605
		return false -- 608
	end -- 608
	if protectedPath == target then -- 608
		protectedPath = "" -- 611
	end -- 611
	return true -- 613
end -- 594
--- 档案内容签名：用于「正式通关是否变化」的幂等判断。
function ____exports.saveSignature(state) -- 617
	return table.concat({ -- 618
		state.childCleared and "1" or "0", -- 619
		state.soldierCleared and "1" or "0", -- 620
		state.artifactOwned and "1" or "0", -- 621
		state.museumPhase, -- 622
		state.museumSeen and "1" or "0" -- 623
	}, "|") -- 623
end -- 617
____exports.SESSION_VERSION = 1 -- 631
____exports.SESSION_FILE = "watch-save/session.txt" -- 632
local customSessionFile = "" -- 719
local function effectiveSessionFile() -- 721
	if customSessionFile ~= "" then -- 721
		return customSessionFile -- 723
	end -- 723
	return isPortableSaveLayout() and ____exports.PORTABLE_AUTOSAVE_FILE or ____exports.SESSION_FILE -- 725
end -- 721
local function usePortableBackupsForSession() -- 728
	return customSessionFile == "" and isPortableSaveLayout() -- 729
end -- 728
function ____exports.getSlotFile(slot) -- 732
	if slot == "auto" then -- 732
		return effectiveSessionFile() -- 734
	end -- 734
	if customSessionFile ~= "" then -- 734
		return (customSessionFile .. ".slot") .. tostring(slot) -- 737
	end -- 737
	return isPortableSaveLayout() and ("slots/slot_" .. tostring(slot)) .. ".sav" or ("watch-save/slots/slot_" .. tostring(slot)) .. ".sav" -- 739
end -- 732
function ____exports.setSessionFile(path) -- 744
	customSessionFile = path -- 745
end -- 744
function ____exports.getSessionFile() -- 748
	return effectiveSessionFile() -- 749
end -- 748
function ____exports.nowUnixSeconds() -- 752
	local g = _G -- 753
	local ____temp_0 -- 754
	if g.os ~= nil then -- 754
		____temp_0 = g.os.time -- 754
	else -- 754
		____temp_0 = nil -- 754
	end -- 754
	local timeFn = ____temp_0 -- 754
	if type(timeFn) == "function" then -- 754
		local t = timeFn() -- 756
		if type(t) == "number" and t > 0 then -- 756
			return math.floor(t) -- 758
		end -- 758
	end -- 758
	return 0 -- 761
end -- 752
function ____exports.formatSavedAt(ts) -- 764
	if ts <= 0 then -- 764
		return "" -- 766
	end -- 766
	local g = _G -- 768
	local ____temp_1 -- 769
	if g.os ~= nil then -- 769
		____temp_1 = g.os.date -- 769
	else -- 769
		____temp_1 = nil -- 769
	end -- 769
	local dateFn = ____temp_1 -- 769
	if type(dateFn) == "function" then -- 769
		local s = dateFn("%Y-%m-%d %H:%M", ts) -- 771
		if type(s) == "string" then -- 771
			return s -- 773
		end -- 773
	end -- 773
	return "" -- 776
end -- 764
function ____exports.formatPlayDuration(sec) -- 779
	local total = math.max( -- 780
		0, -- 780
		math.floor(sec) -- 780
	) -- 780
	if total <= 0 then -- 780
		return "" -- 782
	end -- 782
	local h = math.floor(total / 3600) -- 784
	local m = math.floor(total % 3600 / 60) -- 785
	local s = total % 60 -- 786
	local mm = m < 10 and "0" .. tostring(m) or "" .. tostring(m) -- 787
	local ss = s < 10 and "0" .. tostring(s) or "" .. tostring(s) -- 788
	if h > 0 then -- 788
		return (((tostring(h) .. ":") .. mm) .. ":") .. ss -- 790
	end -- 790
	return (mm .. ":") .. ss -- 792
end -- 779
local function parseBoolField(raw, fallback) -- 795
	if raw == nil then -- 795
		return fallback -- 797
	end -- 797
	if raw == "true" or raw == "1" then -- 797
		return true -- 800
	end -- 800
	if raw == "false" or raw == "0" then -- 800
		return false -- 803
	end -- 803
	return nil -- 805
end -- 795
local function parseListField(raw) -- 808
	if raw == nil or raw == "" then -- 808
		return {} -- 810
	end -- 810
	local parts = __TS__StringSplit(raw, ",") -- 812
	local out = {} -- 813
	local i = 0 -- 814
	do -- 814
		i = 0 -- 815
		while i < #parts do -- 815
			local item = __TS__StringTrim(parts[i + 1]) -- 816
			if item ~= "" then -- 816
				out[#out + 1] = item -- 818
			end -- 818
			i = i + 1 -- 815
		end -- 815
	end -- 815
	return out -- 821
end -- 808
function ____exports.formatSession(s) -- 824
	return table.concat( -- 825
		{ -- 825
			"version=" .. tostring(____exports.SESSION_VERSION), -- 826
			"roomKey=" .. s.roomKey, -- 827
			"checkpoint=" .. tostring(math.floor(s.checkpoint + 0.5)), -- 828
			"seed=" .. tostring(math.floor(s.seed + 0.5)), -- 829
			"route=" .. s.route, -- 830
			"hp=" .. tostring(math.floor(s.hp + 0.5)), -- 831
			"maxHp=" .. tostring(math.floor(s.maxHp + 0.5)), -- 832
			"hpAtGate=" .. tostring(math.floor(s.hpAtGate + 0.5)), -- 833
			"maxHpAtGate=" .. tostring(math.floor(s.maxHpAtGate + 0.5)), -- 834
			"settled=" .. (s.settled and "true" or "false"), -- 835
			"phase=" .. s.phase, -- 836
			"countTick=" .. tostring(math.floor(s.countTick + 0.5)), -- 837
			"phaseTick=" .. tostring(math.floor(s.phaseTick + 0.5)), -- 838
			"handTicks=" .. tostring(math.floor(s.handTicks + 0.5)), -- 839
			"handDone=" .. (s.handDone and "true" or "false"), -- 840
			"lineSaid=" .. (s.lineSaid and "true" or "false"), -- 841
			"tied=" .. (s.tied and "true" or "false"), -- 842
			"carry=" .. (s.carry and "true" or "false"), -- 843
			"escortDone=" .. (s.escortDone and "true" or "false"), -- 844
			"craftedWeapon=" .. s.craftedWeapon, -- 845
			"equippedWeapon=" .. s.equippedWeapon, -- 846
			"wood=" .. tostring(math.floor(s.wood + 0.5)), -- 847
			"bell=" .. tostring(math.floor(s.bell + 0.5)), -- 848
			"scrap=" .. tostring(math.floor(s.scrap + 0.5)), -- 849
			"wedge=" .. tostring(math.floor(s.wedge + 0.5)), -- 850
			"ammo=" .. tostring(math.floor(s.ammo + 0.5)), -- 851
			"shield=" .. tostring(math.floor(s.shield + 0.5)), -- 852
			"pass=" .. tostring(math.floor(s.pass + 0.5)), -- 853
			"quickbelt=" .. tostring(math.floor(s.quickbelt + 0.5)), -- 854
			"taken=" .. table.concat(s.taken, ","), -- 855
			"segments=" .. table.concat(s.segments, ","), -- 856
			"cartAxle=" .. tostring(math.floor(s.cartAxle + 0.5)), -- 857
			"cartDocked=" .. (s.cartDocked and "true" or "false"), -- 858
			"campaignRoute=" .. (s.campaignRoute or ""), -- 859
			"joined=" .. (s.joined == true and "true" or "false"), -- 860
			"c1Latch=" .. (s.c1Latch == true and "true" or "false"), -- 861
			"c2Latch=" .. (s.c2Latch == true and "true" or "false"), -- 862
			"talentSeed=" .. tostring(math.floor((s.talentSeed or 0) + 0.5)), -- 863
			"talentRoom=" .. (s.talentRoom or ""), -- 864
			"talentOffers=" .. (s.talentOffers == nil and "" or table.concat(s.talentOffers, ",")), -- 865
			"talentRanks=" .. (s.talentRanks == nil and "" or table.concat(s.talentRanks, ",")), -- 866
			"escortAttempt=" .. tostring(math.floor((s.escortAttempt or 1) + 0.5)), -- 867
			"escortVariant=" .. tostring(math.floor((s.escortVariant or 0) + 0.5)), -- 868
			"talentDeferred=" .. (s.talentDeferred == true and "true" or "false"), -- 869
			"talentVitality=" .. tostring(math.floor((s.talentVitality or 0) + 0.5)), -- 870
			"talentReload=" .. tostring(math.floor((s.talentReload or 0) + 0.5)), -- 871
			"talentGuard=" .. tostring(math.floor((s.talentGuard or 0) + 0.5)), -- 872
			"talentCraft=" .. tostring(math.floor((s.talentCraft or 0) + 0.5)), -- 873
			"props=" .. (s.props == nil and "" or table.concat(s.props, ",")), -- 874
			"playerX=" .. tostring(s.playerX == nil and -1 or math.floor(s.playerX + 0.5)), -- 875
			"playerY=" .. tostring(s.playerY == nil and 0 or math.floor(s.playerY + 0.5)), -- 876
			"playerDepth=" .. tostring(s.playerDepth == nil and 0 or math.floor(s.playerDepth + 0.5)), -- 877
			"gateTick=" .. tostring(math.floor((s.gateTick or 0) + 0.5)), -- 878
			"hasBottle=" .. (s.hasBottle == true and "true" or "false"), -- 879
			"villagePassed=" .. (s.villagePassed == true and "true" or "false"), -- 880
			"savedAt=" .. tostring(math.floor((s.savedAt ~= nil and s.savedAt > 0 and s.savedAt or ____exports.nowUnixSeconds()) + 0.5)), -- 881
			"playSeconds=" .. tostring(math.max( -- 882
				0, -- 882
				math.floor((s.playSeconds or 0) + 0.5) -- 882
			)), -- 882
			"" -- 883
		}, -- 883
		"\n" -- 884
	) -- 884
end -- 824
function ____exports.parseSession(text) -- 887
	if #text == 0 then -- 887
		return {ok = false, status = "corrupt", reason = "局中存档为空"} -- 889
	end -- 889
	local verRaw = lineValue(text, "version") -- 891
	if verRaw == nil then -- 891
		return {ok = false, status = "corrupt", reason = "缺少 version 行"} -- 893
	end -- 893
	local ver = intOf(verRaw, -1) -- 895
	if ver < 0 then -- 895
		return {ok = false, status = "corrupt", reason = "version 非法"} -- 897
	end -- 897
	if ver > ____exports.SESSION_VERSION then -- 897
		return { -- 900
			ok = false, -- 900
			status = "unsupported", -- 900
			reason = (("局中存档版本 " .. tostring(ver)) .. " 高于当前 ") .. tostring(____exports.SESSION_VERSION) -- 900
		} -- 900
	end -- 900
	local roomKey = lineValue(text, "roomKey") -- 902
	if roomKey == nil or roomKey == "" then -- 902
		return {ok = false, status = "corrupt", reason = "缺少 roomKey"} -- 904
	end -- 904
	local routeRaw = lineValue(text, "route") or "" -- 906
	if routeRaw ~= "" and routeRaw ~= "child" and routeRaw ~= "soldier" then -- 906
		return {ok = false, status = "corrupt", reason = "route 取值非法"} -- 908
	end -- 908
	local settled = parseBoolField( -- 910
		lineValue(text, "settled"), -- 910
		false -- 910
	) -- 910
	local handDone = parseBoolField( -- 911
		lineValue(text, "handDone"), -- 911
		false -- 911
	) -- 911
	local lineSaid = parseBoolField( -- 912
		lineValue(text, "lineSaid"), -- 912
		false -- 912
	) -- 912
	local tied = parseBoolField( -- 913
		lineValue(text, "tied"), -- 913
		false -- 913
	) -- 913
	local carry = parseBoolField( -- 914
		lineValue(text, "carry"), -- 914
		false -- 914
	) -- 914
	local escortDone = parseBoolField( -- 915
		lineValue(text, "escortDone"), -- 915
		false -- 915
	) -- 915
	local cartDocked = parseBoolField( -- 916
		lineValue(text, "cartDocked"), -- 916
		false -- 916
	) -- 916
	local joined = parseBoolField( -- 917
		lineValue(text, "joined"), -- 917
		false -- 917
	) -- 917
	local c1Latch = parseBoolField( -- 918
		lineValue(text, "c1Latch"), -- 918
		false -- 918
	) -- 918
	local c2Latch = parseBoolField( -- 919
		lineValue(text, "c2Latch"), -- 919
		false -- 919
	) -- 919
	if settled == nil or handDone == nil or lineSaid == nil or tied == nil or carry == nil or escortDone == nil or cartDocked == nil or joined == nil or c1Latch == nil or c2Latch == nil then -- 919
		return {ok = false, status = "corrupt", reason = "布尔字段非法"} -- 923
	end -- 923
	local campRouteRaw = lineValue(text, "campaignRoute") or "" -- 925
	if campRouteRaw ~= "" and campRouteRaw ~= "outer" and campRouteRaw ~= "drygoods" then -- 925
		return {ok = false, status = "corrupt", reason = "campaignRoute 取值非法"} -- 927
	end -- 927
	local hp = intOf( -- 929
		lineValue(text, "hp") or "3", -- 929
		-1 -- 929
	) -- 929
	local maxHp = intOf( -- 930
		lineValue(text, "maxHp") or "3", -- 930
		-1 -- 930
	) -- 930
	if hp < 0 or maxHp <= 0 then -- 930
		return {ok = false, status = "corrupt", reason = "血量字段非法"} -- 932
	end -- 932
	return { -- 934
		ok = true, -- 935
		status = "ok", -- 936
		reason = "ok", -- 937
		state = { -- 938
			roomKey = roomKey, -- 939
			checkpoint = intOf( -- 940
				lineValue(text, "checkpoint") or "0", -- 940
				0 -- 940
			), -- 940
			seed = intOf( -- 941
				lineValue(text, "seed") or "20261124", -- 941
				20261124 -- 941
			), -- 941
			route = routeRaw, -- 942
			hp = hp, -- 943
			maxHp = maxHp, -- 944
			hpAtGate = intOf( -- 945
				lineValue(text, "hpAtGate") or "-1", -- 945
				-1 -- 945
			), -- 945
			maxHpAtGate = intOf( -- 946
				lineValue(text, "maxHpAtGate") or "-1", -- 946
				-1 -- 946
			), -- 946
			settled = settled, -- 947
			phase = lineValue(text, "phase") or "", -- 948
			countTick = math.max( -- 949
				0, -- 949
				intOf( -- 949
					lineValue(text, "countTick") or "0", -- 949
					0 -- 949
				) -- 949
			), -- 949
			phaseTick = math.max( -- 950
				0, -- 950
				intOf( -- 950
					lineValue(text, "phaseTick") or "0", -- 950
					0 -- 950
				) -- 950
			), -- 950
			handTicks = math.max( -- 951
				0, -- 951
				intOf( -- 951
					lineValue(text, "handTicks") or "0", -- 951
					0 -- 951
				) -- 951
			), -- 951
			handDone = handDone, -- 952
			lineSaid = lineSaid, -- 953
			tied = tied, -- 954
			carry = carry, -- 955
			escortDone = escortDone, -- 956
			craftedWeapon = lineValue(text, "craftedWeapon") or "", -- 957
			equippedWeapon = lineValue(text, "equippedWeapon") or "", -- 958
			wood = math.max( -- 959
				0, -- 959
				intOf( -- 959
					lineValue(text, "wood") or "0", -- 959
					0 -- 959
				) -- 959
			), -- 959
			bell = math.max( -- 960
				0, -- 960
				intOf( -- 960
					lineValue(text, "bell") or "0", -- 960
					0 -- 960
				) -- 960
			), -- 960
			scrap = math.max( -- 961
				0, -- 961
				intOf( -- 961
					lineValue(text, "scrap") or "0", -- 961
					0 -- 961
				) -- 961
			), -- 961
			wedge = math.max( -- 962
				0, -- 962
				intOf( -- 962
					lineValue(text, "wedge") or "0", -- 962
					0 -- 962
				) -- 962
			), -- 962
			ammo = math.max( -- 963
				0, -- 963
				intOf( -- 963
					lineValue(text, "ammo") or "0", -- 963
					0 -- 963
				) -- 963
			), -- 963
			shield = math.max( -- 964
				0, -- 964
				intOf( -- 964
					lineValue(text, "shield") or "0", -- 964
					0 -- 964
				) -- 964
			), -- 964
			pass = math.max( -- 965
				0, -- 965
				intOf( -- 965
					lineValue(text, "pass") or "0", -- 965
					0 -- 965
				) -- 965
			), -- 965
			quickbelt = math.max( -- 966
				0, -- 966
				intOf( -- 966
					lineValue(text, "quickbelt") or "0", -- 966
					0 -- 966
				) -- 966
			), -- 966
			taken = parseListField(lineValue(text, "taken")), -- 967
			segments = parseListField(lineValue(text, "segments")), -- 968
			cartAxle = intOf( -- 969
				lineValue(text, "cartAxle") or "0", -- 969
				0 -- 969
			), -- 969
			cartDocked = cartDocked, -- 970
			campaignRoute = campRouteRaw, -- 971
			joined = joined, -- 972
			c1Latch = c1Latch, -- 973
			c2Latch = c2Latch, -- 974
			talentSeed = math.max( -- 975
				0, -- 975
				intOf( -- 975
					lineValue(text, "talentSeed") or "0", -- 975
					0 -- 975
				) -- 975
			), -- 975
			talentRoom = lineValue(text, "talentRoom") or "", -- 976
			talentOffers = parseListField(lineValue(text, "talentOffers")), -- 977
			talentRanks = parseListField(lineValue(text, "talentRanks")), -- 978
			escortAttempt = math.max( -- 979
				1, -- 979
				intOf( -- 979
					lineValue(text, "escortAttempt") or "1", -- 979
					1 -- 979
				) -- 979
			), -- 979
			escortVariant = math.max( -- 980
				0, -- 980
				intOf( -- 980
					lineValue(text, "escortVariant") or "0", -- 980
					0 -- 980
				) -- 980
			), -- 980
			talentDeferred = parseBoolField( -- 981
				lineValue(text, "talentDeferred"), -- 981
				false -- 981
			) == true, -- 981
			talentVitality = math.max( -- 982
				0, -- 982
				intOf( -- 982
					lineValue(text, "talentVitality") or "0", -- 982
					0 -- 982
				) -- 982
			), -- 982
			talentReload = math.max( -- 983
				0, -- 983
				intOf( -- 983
					lineValue(text, "talentReload") or "0", -- 983
					0 -- 983
				) -- 983
			), -- 983
			talentGuard = math.max( -- 984
				0, -- 984
				intOf( -- 984
					lineValue(text, "talentGuard") or "0", -- 984
					0 -- 984
				) -- 984
			), -- 984
			talentCraft = math.max( -- 985
				0, -- 985
				intOf( -- 985
					lineValue(text, "talentCraft") or "0", -- 985
					0 -- 985
				) -- 985
			), -- 985
			props = parseListField(lineValue(text, "props")), -- 986
			playerX = intOf( -- 987
				lineValue(text, "playerX") or "-1", -- 987
				-1 -- 987
			), -- 987
			playerY = intOf( -- 988
				lineValue(text, "playerY") or "0", -- 988
				0 -- 988
			), -- 988
			playerDepth = intOf( -- 989
				lineValue(text, "playerDepth") or "0", -- 989
				0 -- 989
			), -- 989
			gateTick = math.max( -- 990
				0, -- 990
				intOf( -- 990
					lineValue(text, "gateTick") or "0", -- 990
					0 -- 990
				) -- 990
			), -- 990
			hasBottle = parseBoolField( -- 991
				lineValue(text, "hasBottle"), -- 991
				false -- 991
			) == true, -- 991
			villagePassed = parseBoolField( -- 992
				lineValue(text, "villagePassed"), -- 992
				false -- 992
			) == true, -- 992
			savedAt = math.max( -- 993
				0, -- 993
				intOf( -- 993
					lineValue(text, "savedAt") or "0", -- 993
					0 -- 993
				) -- 993
			), -- 993
			playSeconds = math.max( -- 994
				0, -- 994
				intOf( -- 994
					lineValue(text, "playSeconds") or "0", -- 994
					0 -- 994
				) -- 994
			) -- 994
		} -- 994
	} -- 994
end -- 887
local function usableSessionBackup(path) -- 999
	if not ops:exist(path) then -- 999
		return false -- 1001
	end -- 1001
	return ____exports.parseSession(loadText(path)).ok -- 1003
end -- 999
local function restoreSessionFrom(candidate, target, keepCandidate) -- 1006
	if not usableSessionBackup(candidate) then -- 1006
		return false -- 1008
	end -- 1008
	ensureDir(dirOf(target)) -- 1010
	if not ops:copy(candidate, target) then -- 1010
		return false -- 1012
	end -- 1012
	if not sameContent(candidate, target) then -- 1012
		return false -- 1015
	end -- 1015
	if not keepCandidate then -- 1015
		ops:remove(candidate) -- 1018
	end -- 1018
	return true -- 1020
end -- 1006
local function hasSessionAtPath(relFile, useBackups) -- 1023
	local target = absPath(relFile) -- 1024
	if usableSessionBackup(target) then -- 1024
		return true -- 1026
	end -- 1026
	return usableSessionBackup(target .. ".tmp") or usableSessionBackup(prevPathFor(target, useBackups)) -- 1028
end -- 1023
local function loadSessionAtPath(relFile, useBackups) -- 1031
	local target = absPath(relFile) -- 1032
	local tmp = target .. ".tmp" -- 1033
	local prev = prevPathFor(target, useBackups) -- 1034
	if not ops:exist(target) then -- 1034
		if restoreSessionFrom(tmp, target, false) then -- 1034
			local p = ____exports.parseSession(loadText(target)) -- 1037
			return { -- 1038
				state = p.state, -- 1038
				status = "ok", -- 1038
				detail = "由 .tmp 恢复局中存档", -- 1038
				recovered = true, -- 1038
				backup = "" -- 1038
			} -- 1038
		end -- 1038
		if restoreSessionFrom(prev, target, true) then -- 1038
			local p = ____exports.parseSession(loadText(target)) -- 1041
			return { -- 1042
				state = p.state, -- 1042
				status = "ok", -- 1042
				detail = "由 .prev 恢复局中存档", -- 1042
				recovered = true, -- 1042
				backup = "" -- 1042
			} -- 1042
		end -- 1042
		return { -- 1044
			state = nil, -- 1044
			status = "missing", -- 1044
			detail = "无局中存档", -- 1044
			recovered = false, -- 1044
			backup = "" -- 1044
		} -- 1044
	end -- 1044
	local parsed = ____exports.parseSession(loadText(target)) -- 1046
	if parsed.ok and parsed.state ~= nil then -- 1046
		if ops:exist(tmp) and sameContent(tmp, target) then -- 1046
			ops:remove(tmp) -- 1049
		end -- 1049
		return { -- 1051
			state = parsed.state, -- 1051
			status = "ok", -- 1051
			detail = "局中存档读取成功", -- 1051
			recovered = false, -- 1051
			backup = "" -- 1051
		} -- 1051
	end -- 1051
	if parsed.status == "corrupt" then -- 1051
		local broken = backupCorrupt(target, ".corrupt", useBackups) -- 1054
		if restoreSessionFrom(tmp, target, false) then -- 1054
			local p = ____exports.parseSession(loadText(target)) -- 1056
			return { -- 1057
				state = p.state, -- 1057
				status = "ok", -- 1057
				detail = "原局中存档损坏，已用 .tmp 恢复", -- 1057
				recovered = true, -- 1057
				backup = broken -- 1057
			} -- 1057
		end -- 1057
		if restoreSessionFrom(prev, target, true) then -- 1057
			local p = ____exports.parseSession(loadText(target)) -- 1060
			return { -- 1061
				state = p.state, -- 1061
				status = "ok", -- 1061
				detail = "原局中存档损坏，已用 .prev 恢复", -- 1061
				recovered = true, -- 1061
				backup = broken -- 1061
			} -- 1061
		end -- 1061
		return { -- 1063
			state = nil, -- 1063
			status = "corrupt", -- 1063
			detail = parsed.reason, -- 1063
			recovered = false, -- 1063
			backup = broken -- 1063
		} -- 1063
	end -- 1063
	local backup = backupCorrupt(target, ".unsupported", useBackups) -- 1065
	return { -- 1066
		state = nil, -- 1066
		status = "unsupported", -- 1066
		detail = parsed.reason, -- 1066
		recovered = false, -- 1066
		backup = backup -- 1066
	} -- 1066
end -- 1031
local function saveSessionAtPath(relFile, state, useBackups) -- 1069
	local target = absPath(relFile) -- 1070
	ensureDir(dirOf(target)) -- 1071
	local tmp = target .. ".tmp" -- 1072
	local prev = prevPathFor(target, useBackups) -- 1073
	local text = ____exports.formatSession(state) -- 1074
	if not ops:save(tmp, text) then -- 1074
		ops:remove(tmp) -- 1076
		return false -- 1077
	end -- 1077
	local written = ops:load(tmp) -- 1079
	if written == nil or normalize(written) ~= normalize(text) then -- 1079
		ops:remove(tmp) -- 1081
		return false -- 1082
	end -- 1082
	local existed = ops:exist(target) -- 1084
	local backedUp = false -- 1085
	if existed then -- 1085
		if usableSessionBackup(target) then -- 1085
			ensureDir(dirOf(prev)) -- 1088
			backedUp = ops:copy(target, prev) -- 1089
			if not backedUp or not usableSessionBackup(prev) then -- 1089
				ops:remove(tmp) -- 1091
				return false -- 1092
			end -- 1092
		else -- 1092
			backupCorrupt(target, ".corrupt", useBackups) -- 1095
		end -- 1095
	end -- 1095
	if not ops:copy(tmp, target) then -- 1095
		if existed and backedUp and not sameContent(target, prev) then -- 1095
			ops:copy(prev, target) -- 1100
		end -- 1100
		return false -- 1102
	end -- 1102
	local check = ops:load(target) -- 1104
	if check == nil or normalize(check) ~= normalize(text) then -- 1104
		if existed and backedUp and ops:copy(prev, target) and usableSessionBackup(target) then -- 1104
			ops:remove(tmp) -- 1107
		end -- 1107
		return false -- 1109
	end -- 1109
	ops:remove(tmp) -- 1111
	return true -- 1112
end -- 1069
local function clearSessionAtPath(relFile, useBackups) -- 1115
	local target = absPath(relFile) -- 1116
	local tmp = target .. ".tmp" -- 1117
	local prev = prevPathFor(target, useBackups) -- 1118
	local ok = true -- 1119
	if ops:exist(target) then -- 1119
		ok = ops:remove(target) and ok -- 1121
	end -- 1121
	if ops:exist(tmp) then -- 1121
		ops:remove(tmp) -- 1124
	end -- 1124
	if ops:exist(prev) then -- 1124
		ops:remove(prev) -- 1127
	end -- 1127
	return ok -- 1129
end -- 1115
local function peekSlotSummary(slot) -- 1132
	local rel = ____exports.getSlotFile(slot) -- 1133
	local useBackups = usePortableBackupsForSession() -- 1134
	local target = absPath(rel) -- 1135
	local tmp = target .. ".tmp" -- 1136
	local prev = prevPathFor(target, useBackups) -- 1137
	local empty = { -- 1138
		id = slot, -- 1139
		exists = false, -- 1140
		status = "missing", -- 1141
		roomKey = "", -- 1142
		route = "", -- 1143
		hp = 0, -- 1144
		maxHp = 0, -- 1145
		savedAt = 0, -- 1146
		playSeconds = 0, -- 1147
		recovered = false -- 1148
	} -- 1148
	local candidates = {{path = target, rec = false}, {path = tmp, rec = true}, {path = prev, rec = true}} -- 1150
	local primaryStatus = "missing" -- 1155
	local i = 0 -- 1156
	do -- 1156
		i = 0 -- 1157
		while i < #candidates do -- 1157
			do -- 1157
				local c = candidates[i + 1] -- 1158
				if not ops:exist(c.path) then -- 1158
					goto __continue192 -- 1160
				end -- 1160
				local parsed = ____exports.parseSession(loadText(c.path)) -- 1162
				if parsed.ok and parsed.state ~= nil then -- 1162
					return { -- 1164
						id = slot, -- 1165
						exists = true, -- 1166
						status = "ok", -- 1167
						roomKey = parsed.state.roomKey, -- 1168
						route = parsed.state.route, -- 1169
						hp = parsed.state.hp, -- 1170
						maxHp = parsed.state.maxHp, -- 1171
						savedAt = parsed.state.savedAt or 0, -- 1172
						playSeconds = parsed.state.playSeconds or 0, -- 1173
						recovered = c.rec -- 1174
					} -- 1174
				end -- 1174
				if i == 0 then -- 1174
					primaryStatus = parsed.status -- 1178
				end -- 1178
			end -- 1178
			::__continue192:: -- 1178
			i = i + 1 -- 1157
		end -- 1157
	end -- 1157
	if primaryStatus ~= "missing" then -- 1157
		empty.status = primaryStatus -- 1182
	end -- 1182
	return empty -- 1184
end -- 1132
function ____exports.hasSlotSave(slot) -- 1187
	return hasSessionAtPath( -- 1188
		____exports.getSlotFile(slot), -- 1188
		usePortableBackupsForSession() -- 1188
	) -- 1188
end -- 1187
function ____exports.loadSlot(slot) -- 1191
	return loadSessionAtPath( -- 1192
		____exports.getSlotFile(slot), -- 1192
		usePortableBackupsForSession() -- 1192
	) -- 1192
end -- 1191
function ____exports.saveSlot(slot, state) -- 1195
	return saveSessionAtPath( -- 1196
		____exports.getSlotFile(slot), -- 1196
		state, -- 1196
		usePortableBackupsForSession() -- 1196
	) -- 1196
end -- 1195
function ____exports.deleteSlot(slot) -- 1199
	return clearSessionAtPath( -- 1200
		____exports.getSlotFile(slot), -- 1200
		usePortableBackupsForSession() -- 1200
	) -- 1200
end -- 1199
function ____exports.listSaveSlots() -- 1203
	return { -- 1204
		peekSlotSummary("auto"), -- 1205
		peekSlotSummary(1), -- 1206
		peekSlotSummary(2), -- 1207
		peekSlotSummary(3) -- 1208
	} -- 1208
end -- 1203
function ____exports.hasAnySaveSlot() -- 1212
	return ____exports.hasSlotSave("auto") or ____exports.hasSlotSave(1) or ____exports.hasSlotSave(2) or ____exports.hasSlotSave(3) -- 1213
end -- 1212
function ____exports.hasSessionSave() -- 1216
	return ____exports.hasSlotSave("auto") -- 1217
end -- 1216
function ____exports.loadSession() -- 1220
	return ____exports.loadSlot("auto") -- 1221
end -- 1220
function ____exports.saveSession(state) -- 1224
	return ____exports.saveSlot("auto", state) -- 1225
end -- 1224
function ____exports.clearSession() -- 1228
	return ____exports.deleteSlot("auto") -- 1229
end -- 1228
return ____exports -- 1228