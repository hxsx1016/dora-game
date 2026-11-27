-- [ts]: save.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local copyForWrite, absPath, lineValue, intOf, formatSave, parseSave, normalize, sameContent, backupPathFor, backupCorrupt, usableBackup, dirOf, ops, fault, currentFile, protectedPath -- 78
local ____Dora = require("Dora") -- 11
local Content = ____Dora.Content -- 11
local ____run = require("Script.watch.run") -- 12
local isMuseumPhase = ____run.isMuseumPhase -- 12
function copyForWrite(from, to) -- 78
	if fault == "replace" then -- 79
		return false -- 80
	end -- 80
	return ops:copy(from, to) -- 82
end -- 82
function absPath(path) -- 92
	if #path > 0 and (string.sub(path, 1, 1) == "/" or string.sub(path, 1, 1) == "\\") then -- 93
		return path -- 94
	end -- 94
	if #path >= 2 and string.sub(path, 2, 2) == ":" then -- 96
		return path -- 97
	end -- 97
	local base = Content.writablePath -- 99
	local sep = (string.find(base, "\\", nil, true) or 0) - 1 >= 0 and (string.find(base, "/", nil, true) or 0) - 1 < 0 and "\\" or "/" -- 100
	local norm = sep == "\\" and table.concat( -- 101
		__TS__StringSplit(path, "/"), -- 101
		"\\" -- 101
	) or path -- 101
	local trimmed = (__TS__StringEndsWith(base, "/") or __TS__StringEndsWith(base, "\\")) and string.sub(base, 1, -2) or base -- 102
	return (trimmed .. sep) .. norm -- 103
end -- 103
function ____exports.emptySave() -- 155
	return { -- 156
		childCleared = false, -- 157
		soldierCleared = false, -- 158
		artifactOwned = false, -- 159
		museumPhase = "locked", -- 160
		museumSeen = false -- 161
	} -- 161
end -- 155
function lineValue(text, key) -- 165
	local lines = __TS__StringSplit(text, "\n") -- 166
	local prefix = key .. "=" -- 167
	local i = 0 -- 168
	do -- 168
		i = 0 -- 169
		while i < #lines do -- 169
			local line = lines[i + 1] -- 170
			if #line >= #prefix and __TS__StringSubstring(line, 0, #prefix) == prefix then -- 171
				return __TS__StringSubstring(line, #prefix) -- 172
			end -- 172
			i = i + 1 -- 169
		end -- 169
	end -- 169
	return nil -- 175
end -- 175
function intOf(text, fallback) -- 178
	if #text == 0 then -- 179
		return fallback -- 180
	end -- 180
	local i = 0 -- 182
	local sign = 1 -- 183
	if string.sub(text, 1, 1) == "-" then -- 184
		sign = -1 -- 185
		i = 1 -- 186
	end -- 186
	local n = 0 -- 188
	local digits = 0 -- 189
	do -- 189
		while i < #text do -- 190
			local c = __TS__StringCharCodeAt(text, i) -- 191
			if c < 48 or c > 57 then -- 192
				return fallback -- 193
			end -- 193
			n = n * 10 + (c - 48) -- 195
			digits = digits + 1 -- 196
			i = i + 1 -- 190
		end -- 190
	end -- 190
	if digits == 0 then -- 198
		return fallback -- 199
	end -- 199
	return sign * n -- 201
end -- 201
function formatSave(state) -- 204
	return table.concat( -- 205
		{ -- 205
			"version=" .. tostring(____exports.SAVE_VERSION), -- 206
			"childCleared=" .. (state.childCleared and "true" or "false"), -- 207
			"soldierCleared=" .. (state.soldierCleared and "true" or "false"), -- 208
			"artifactOwned=" .. (state.artifactOwned and "true" or "false"), -- 209
			"museumPhase=" .. state.museumPhase, -- 210
			"museumSeen=" .. (state.museumSeen and "true" or "false"), -- 211
			"" -- 212
		}, -- 212
		"\n" -- 213
	) -- 213
end -- 213
function parseSave(text) -- 227
	local bad = { -- 228
		ok = false, -- 228
		status = "corrupt", -- 228
		reason = "", -- 228
		state = ____exports.emptySave() -- 228
	} -- 228
	if #text == 0 then -- 229
		bad.reason = "档案为空" -- 230
		return bad -- 231
	end -- 231
	local versionText = lineValue(text, "version") -- 233
	if versionText == nil then -- 234
		bad.reason = "缺少 version 行" -- 235
		return bad -- 236
	end -- 236
	local version = intOf(versionText, -1) -- 238
	if version < 0 then -- 239
		bad.reason = "version 不是十进制整数" -- 240
		return bad -- 241
	end -- 241
	if version > ____exports.SAVE_VERSION then -- 243
		return { -- 244
			ok = false, -- 244
			status = "unsupported", -- 244
			reason = (("版本 " .. tostring(version)) .. " 高于 ") .. tostring(____exports.SAVE_VERSION), -- 244
			state = ____exports.emptySave() -- 244
		} -- 244
	end -- 244
	if version ~= ____exports.SAVE_VERSION then -- 246
		bad.reason = "不支持的旧版本 " .. tostring(version) -- 247
		return bad -- 248
	end -- 248
	local boolKeys = {"childCleared", "soldierCleared", "artifactOwned", "museumSeen"} -- 250
	local bools = {} -- 251
	local i = 0 -- 252
	do -- 252
		i = 0 -- 253
		while i < #boolKeys do -- 253
			local value = lineValue(text, boolKeys[i + 1]) -- 254
			if value == nil then -- 255
				bad.reason = "缺少字段 " .. boolKeys[i + 1] -- 256
				return bad -- 257
			end -- 257
			if value ~= "true" and value ~= "false" then -- 259
				bad.reason = ("字段 " .. boolKeys[i + 1]) .. " 不是布尔值" -- 260
				return bad -- 261
			end -- 261
			bools[#bools + 1] = value == "true" -- 263
			i = i + 1 -- 253
		end -- 253
	end -- 253
	local phase = lineValue(text, "museumPhase") -- 265
	if phase == nil then -- 266
		bad.reason = "缺少字段 museumPhase" -- 267
		return bad -- 268
	end -- 268
	if not isMuseumPhase(phase) then -- 270
		bad.reason = "museumPhase 不在枚举内" -- 271
		return bad -- 272
	end -- 272
	return { -- 274
		ok = true, -- 275
		status = "ok", -- 276
		reason = "版本 " .. tostring(version), -- 277
		state = { -- 278
			childCleared = bools[1], -- 279
			soldierCleared = bools[2], -- 280
			artifactOwned = bools[3], -- 281
			museumPhase = phase, -- 282
			museumSeen = bools[4] -- 283
		} -- 283
	} -- 283
end -- 283
function normalize(text) -- 288
	return table.concat( -- 289
		__TS__StringSplit( -- 289
			table.concat( -- 289
				__TS__StringSplit(text, "\r\n"), -- 289
				"\n" -- 289
			), -- 289
			"\r" -- 289
		), -- 289
		"\n" -- 289
	) -- 289
end -- 289
function sameContent(a, b) -- 293
	local textA = ops:load(a) -- 294
	local textB = ops:load(b) -- 295
	if textA == nil or textB == nil then -- 296
		return false -- 297
	end -- 297
	return normalize(textA) == normalize(textB) -- 299
end -- 299
function backupPathFor(target, suffix) -- 303
	local candidate = target .. suffix -- 304
	if not ops:exist(candidate) then -- 305
		return candidate -- 306
	end -- 306
	local n = 2 -- 308
	while n <= 9999 do -- 309
		candidate = ((target .. suffix) .. ".") .. tostring(n) -- 310
		if not ops:exist(candidate) then -- 311
			return candidate -- 312
		end -- 312
		n = n + 1 -- 314
	end -- 314
	return "" -- 316
end -- 316
function backupCorrupt(target, suffix) -- 323
	if not ops:exist(target) then -- 324
		return "" -- 325
	end -- 325
	local backup = backupPathFor(target, suffix) -- 327
	if backup == "" then -- 328
		return "" -- 329
	end -- 329
	if not ops:copy(target, backup) then -- 331
		return "" -- 332
	end -- 332
	if not sameContent(target, backup) then -- 334
		return "" -- 335
	end -- 335
	return backup -- 337
end -- 337
function usableBackup(path) -- 350
	if not ops:exist(path) then -- 351
		return false -- 352
	end -- 352
	local text = ops:load(path) -- 354
	return text ~= nil and parseSave(text).ok -- 355
end -- 355
function dirOf(path) -- 460
	local i = #path - 1 -- 461
	do -- 461
		while i >= 0 do -- 462
			local ch = __TS__StringCharAt(path, i) -- 463
			if ch == "/" or ch == "\\" then -- 464
				return __TS__StringSubstring(path, 0, i) -- 465
			end -- 465
			i = i - 1 -- 462
		end -- 462
	end -- 462
	return "" -- 468
end -- 468
--- 写入档案：写 `.tmp` → 校验 → 备份旧档到 `.prev`（校验成功才继续）→ 覆盖目标 → 回读校验。
-- 失败语义：
--   - 备份失败：不覆盖目标，清掉本次 `.tmp`（旧档完好），返回 false；
--   - 覆盖失败：尝试从 `.prev` 回滚；`.tmp` 保留为最新候选，返回 false；
--   - 校验失败：用 `.prev` 回滚；回滚失败则保留 `.tmp`，返回 false。
-- 未知版本原件（按路径保护）拒绝写入。
function ____exports.saveSave(state) -- 479
	local target = absPath(currentFile) -- 480
	if protectedPath == target then -- 481
		return false -- 482
	end -- 482
	local dir = dirOf(target) -- 484
	if dir ~= "" and not ops:isdir(dir) then -- 485
		ops:mkdir(dir) -- 486
	end -- 486
	local tmp = target .. ".tmp" -- 488
	local prev = target .. ".prev" -- 489
	local text = formatSave(state) -- 490
	if fault == "write" then -- 492
		return false -- 493
	end -- 493
	if not ops:save(tmp, text) then -- 495
		ops:remove(tmp) -- 496
		return false -- 497
	end -- 497
	local written = ops:load(tmp) -- 499
	if written == nil or normalize(written) ~= normalize(text) then -- 500
		ops:remove(tmp) -- 501
		return false -- 502
	end -- 502
	local existed = ops:exist(target) -- 505
	local backedUp = false -- 506
	if existed then -- 507
		if usableBackup(target) then -- 508
			backedUp = ops:copy(target, prev) -- 509
			if not backedUp or not usableBackup(prev) then -- 510
				ops:remove(tmp) -- 512
				return false -- 513
			end -- 513
		else -- 513
			backupCorrupt(target, ".corrupt") -- 517
		end -- 517
	end -- 517
	if not copyForWrite(tmp, target) then -- 521
		if existed and backedUp and not sameContent(target, prev) then -- 522
			ops:copy(prev, target) -- 523
		end -- 523
		return false -- 526
	end -- 526
	local check = ops:load(target) -- 529
	if fault == "verify" or check == nil or normalize(check) ~= normalize(text) then -- 530
		if existed and backedUp and ops:copy(prev, target) and usableBackup(target) then -- 531
			ops:remove(tmp) -- 532
			return false -- 533
		end -- 533
		return false -- 536
	end -- 536
	ops:remove(tmp) -- 539
	return true -- 540
end -- 479
____exports.SAVE_VERSION = 1 -- 14
____exports.SAVE_DIR = "watch-save" -- 15
____exports.SAVE_FILE = "watch-save/archive.txt" -- 16
local contentOps = { -- 52
	exist = function(____, path) return Content:exist(path) end, -- 53
	load = function(____, path) return Content:load(path) end, -- 54
	save = function(____, path, text) return Content:save(path, text) end, -- 55
	copy = function(____, from, to) return Content:copy(from, to) end, -- 56
	remove = function(____, path) return Content:remove(path) end, -- 57
	isdir = function(____, path) return Content:isdir(path) end, -- 58
	mkdir = function(____, path) return Content:mkdir(path) end -- 59
} -- 59
ops = contentOps -- 62
--- 测试注入文件操作层；传 undefined 恢复引擎默认。正式入口不调用。
function ____exports.setFileOpsForTest(next) -- 65
	ops = next == nil and contentOps or next -- 66
end -- 65
fault = "" -- 71
function ____exports.setSaveFault(value) -- 73
	fault = value -- 74
end -- 73
currentFile = ____exports.SAVE_FILE -- 85
--- 跨 Play 实例的待落盘档案：携带目标路径，切换档案后不会写错档。
local pending = nil -- 87
protectedPath = "" -- 89
--- 测试用：切到隔离档案文件；传空则回正式档案。不清保护位（保护位按路径绑定）。
function ____exports.setSaveFile(path) -- 107
	currentFile = path == "" and ____exports.SAVE_FILE or path -- 108
end -- 107
--- 登记一份待落盘档案（同拍切房、写失败都由调用方重新登记）。
function ____exports.markProfilePending(state) -- 112
	pending = {state = state, file = currentFile} -- 113
end -- 112
function ____exports.profilePending() -- 116
	return pending ~= nil -- 117
end -- 116
--- 待落盘档案是否属于当前档案路径（切档后不应写错目标）。
function ____exports.pendingMatchesCurrent() -- 121
	return pending ~= nil and pending.file == currentFile -- 122
end -- 121
--- 把登记的档案落盘；成功才清登记，失败保留等下一帧重试。
-- 登记属于别的档案路径时不写、返回 false（调用方应显式丢弃或先切回）。
function ____exports.flushProfile() -- 129
	if pending == nil then -- 130
		return true -- 131
	end -- 131
	if pending.file ~= currentFile then -- 133
		return false -- 134
	end -- 134
	if not ____exports.saveSave(pending.state) then -- 136
		return false -- 137
	end -- 137
	pending = nil -- 139
	return true -- 140
end -- 129
function ____exports.clearProfilePending() -- 143
	pending = nil -- 144
end -- 143
function ____exports.getSaveFile() -- 147
	return currentFile -- 148
end -- 147
function ____exports.savePath() -- 151
	return absPath(currentFile) -- 152
end -- 151
--- 读文本；读不到按空串处理（解析会判 corrupt）。
local function loadText(path) -- 341
	local text = ops:load(path) -- 342
	if text == nil then -- 343
		return "" -- 344
	end -- 344
	return text -- 346
end -- 341
--- 用候选件恢复目标；成功（复制成功且回读解析一致）才清候选，失败保留候选并返回 false。
local function restoreFrom(candidate, target, keepCandidate) -- 359
	if not usableBackup(candidate) then -- 360
		return false -- 361
	end -- 361
	if not ops:copy(candidate, target) then -- 363
		return false -- 364
	end -- 364
	local again = parseSave(loadText(target)) -- 366
	if not again.ok then -- 367
		return false -- 368
	end -- 368
	if not keepCandidate then -- 370
		ops:remove(candidate) -- 371
	end -- 371
	return true -- 373
end -- 359
--- 读取档案。
-- 自愈顺序：
--   目标缺失 → 完整 `.tmp` → 完整 `.prev`；
--   目标损坏 → 完整 `.tmp`（最新候选）→ 完整 `.prev`。
-- 损坏/未知版本先派生备份；未知版本原件置保护位（按路径），普通写档拒绝覆盖。
function ____exports.loadSave() -- 383
	local target = absPath(currentFile) -- 384
	local tmp = target .. ".tmp" -- 385
	local prev = target .. ".prev" -- 386
	local recovered = false -- 387
	local recoveryDetail = "" -- 388
	if not ops:exist(target) then -- 390
		if restoreFrom(tmp, target, false) then -- 391
			recovered = true -- 392
			recoveryDetail = "目标缺失，已用完整 .tmp 恢复" -- 393
		elseif restoreFrom(prev, target, true) then -- 394
			recovered = true -- 395
			recoveryDetail = "目标缺失，已用完整 .prev 恢复" -- 396
		end -- 396
	end -- 396
	if not ops:exist(target) then -- 400
		return { -- 401
			state = ____exports.emptySave(), -- 402
			status = "missing", -- 402
			detail = "无档案，按新档起局" .. (recovered and ("（" .. recoveryDetail) .. "）" or ""), -- 403
			recovered = recovered, -- 404
			backup = "", -- 404
			action = "none" -- 404
		} -- 404
	end -- 404
	local text = ops:load(target) -- 408
	local parsed = parseSave(text == nil and "" or text) -- 409
	if parsed.ok then -- 410
		if ops:exist(tmp) and sameContent(tmp, target) then -- 412
			ops:remove(tmp) -- 413
		end -- 413
		return { -- 415
			state = parsed.state, -- 416
			status = "ok", -- 416
			detail = parsed.reason .. (recovered and ("（" .. recoveryDetail) .. "）" or ""), -- 417
			recovered = recovered, -- 418
			backup = "", -- 418
			action = "keep" -- 418
		} -- 418
	end -- 418
	if parsed.status == "corrupt" then -- 422
		local broken = backupCorrupt(target, ".corrupt") -- 423
		if restoreFrom(tmp, target, false) then -- 424
			return { -- 425
				state = parseSave(loadText(target)).state, -- 426
				status = "ok", -- 427
				detail = (("原档损坏（" .. parsed.reason) .. "），已用完整 .tmp 恢复，损坏件备份为 ") .. broken, -- 428
				recovered = true, -- 429
				backup = broken, -- 429
				action = "keep" -- 429
			} -- 429
		end -- 429
		if restoreFrom(prev, target, true) then -- 432
			return { -- 433
				state = parseSave(loadText(target)).state, -- 434
				status = "ok", -- 435
				detail = (("原档损坏（" .. parsed.reason) .. "），已用 .prev 恢复，损坏件备份为 ") .. broken, -- 436
				recovered = true, -- 437
				backup = broken, -- 437
				action = "keep" -- 437
			} -- 437
		end -- 437
		return { -- 441
			state = ____exports.emptySave(), -- 442
			status = "corrupt", -- 442
			detail = (("档案损坏（" .. parsed.reason) .. "），原件保留") .. (broken ~= "" and "，损坏件备份为 " .. broken or "，备份失败（原件未动）"), -- 443
			recovered = false, -- 445
			backup = broken, -- 445
			action = "reset" -- 445
		} -- 445
	end -- 445
	local backup = backupCorrupt(target, ".unsupported") -- 449
	protectedPath = target -- 450
	return { -- 451
		state = ____exports.emptySave(), -- 452
		status = "unsupported", -- 452
		detail = (("档案版本不支持（" .. parsed.reason) .. "），原件保留") .. (backup ~= "" and "：" .. backup or "，备份失败（原件未动）"), -- 453
		recovered = recovered, -- 455
		backup = backup, -- 455
		action = "reset" -- 455
	} -- 455
end -- 383
--- 恢复策略（给前端「档案损坏/版本不支持」页用）：把原件隔离到派生备份后删除。
-- 只有备份复制成功、内容与原件一致、且备份本身可解析时才删除目标。
function ____exports.resetSave() -- 547
	local target = absPath(currentFile) -- 548
	if not ops:exist(target) then -- 549
		return false -- 550
	end -- 550
	local backup = backupCorrupt(target, ".reset") -- 552
	if backup == "" then -- 553
		return false -- 554
	end -- 554
	if not sameContent(target, backup) then -- 557
		return false -- 558
	end -- 558
	if not ops:remove(target) then -- 560
		return false -- 561
	end -- 561
	if protectedPath == target then -- 563
		protectedPath = "" -- 564
	end -- 564
	return true -- 566
end -- 547
--- 档案内容签名：用于「正式通关是否变化」的幂等判断。
function ____exports.saveSignature(state) -- 570
	return table.concat({ -- 571
		state.childCleared and "1" or "0", -- 572
		state.soldierCleared and "1" or "0", -- 573
		state.artifactOwned and "1" or "0", -- 574
		state.museumPhase, -- 575
		state.museumSeen and "1" or "0" -- 576
	}, "|") -- 577
end -- 570
____exports.SESSION_VERSION = 1 -- 584
____exports.SESSION_FILE = "watch-save/session.txt" -- 585
local currentSessionFile = ____exports.SESSION_FILE -- 656
function ____exports.setSessionFile(path) -- 658
	currentSessionFile = path == "" and ____exports.SESSION_FILE or path -- 659
end -- 658
function ____exports.getSessionFile() -- 662
	return currentSessionFile -- 663
end -- 662
local function parseBoolField(raw, fallback) -- 666
	if raw == nil then -- 667
		return fallback -- 668
	end -- 668
	if raw == "true" or raw == "1" then -- 670
		return true -- 671
	end -- 671
	if raw == "false" or raw == "0" then -- 673
		return false -- 674
	end -- 674
	return nil -- 676
end -- 666
local function parseListField(raw) -- 679
	if raw == nil or raw == "" then -- 680
		return {} -- 681
	end -- 681
	local parts = __TS__StringSplit(raw, ",") -- 683
	local out = {} -- 684
	local i = 0 -- 685
	do -- 685
		i = 0 -- 686
		while i < #parts do -- 686
			local item = __TS__StringTrim(parts[i + 1]) -- 687
			if item ~= "" then -- 688
				out[#out + 1] = item -- 689
			end -- 689
			i = i + 1 -- 686
		end -- 686
	end -- 686
	return out -- 692
end -- 679
function ____exports.formatSession(s) -- 695
	return table.concat( -- 696
		{ -- 696
			"version=" .. tostring(____exports.SESSION_VERSION), -- 697
			"roomKey=" .. s.roomKey, -- 698
			"checkpoint=" .. tostring(math.floor(s.checkpoint + 0.5)), -- 699
			"seed=" .. tostring(math.floor(s.seed + 0.5)), -- 700
			"route=" .. s.route, -- 701
			"hp=" .. tostring(math.floor(s.hp + 0.5)), -- 702
			"maxHp=" .. tostring(math.floor(s.maxHp + 0.5)), -- 703
			"hpAtGate=" .. tostring(math.floor(s.hpAtGate + 0.5)), -- 704
			"maxHpAtGate=" .. tostring(math.floor(s.maxHpAtGate + 0.5)), -- 705
			"settled=" .. (s.settled and "true" or "false"), -- 706
			"phase=" .. s.phase, -- 707
			"countTick=" .. tostring(math.floor(s.countTick + 0.5)), -- 708
			"phaseTick=" .. tostring(math.floor(s.phaseTick + 0.5)), -- 709
			"handTicks=" .. tostring(math.floor(s.handTicks + 0.5)), -- 710
			"handDone=" .. (s.handDone and "true" or "false"), -- 711
			"lineSaid=" .. (s.lineSaid and "true" or "false"), -- 712
			"tied=" .. (s.tied and "true" or "false"), -- 713
			"carry=" .. (s.carry and "true" or "false"), -- 714
			"escortDone=" .. (s.escortDone and "true" or "false"), -- 715
			"craftedWeapon=" .. s.craftedWeapon, -- 716
			"equippedWeapon=" .. s.equippedWeapon, -- 717
			"wood=" .. tostring(math.floor(s.wood + 0.5)), -- 718
			"bell=" .. tostring(math.floor(s.bell + 0.5)), -- 719
			"scrap=" .. tostring(math.floor(s.scrap + 0.5)), -- 720
			"wedge=" .. tostring(math.floor(s.wedge + 0.5)), -- 721
			"ammo=" .. tostring(math.floor(s.ammo + 0.5)), -- 722
			"shield=" .. tostring(math.floor(s.shield + 0.5)), -- 723
			"pass=" .. tostring(math.floor(s.pass + 0.5)), -- 724
			"quickbelt=" .. tostring(math.floor(s.quickbelt + 0.5)), -- 725
			"taken=" .. table.concat(s.taken, ","), -- 726
			"segments=" .. table.concat(s.segments, ","), -- 727
			"cartAxle=" .. tostring(math.floor(s.cartAxle + 0.5)), -- 728
			"cartDocked=" .. (s.cartDocked and "true" or "false"), -- 729
			"campaignRoute=" .. (s.campaignRoute or ""), -- 730
			"joined=" .. (s.joined == true and "true" or "false"), -- 731
			"c1Latch=" .. (s.c1Latch == true and "true" or "false"), -- 732
			"c2Latch=" .. (s.c2Latch == true and "true" or "false"), -- 733
			"talentSeed=" .. tostring(math.floor((s.talentSeed or 0) + 0.5)), -- 734
			"talentRoom=" .. (s.talentRoom or ""), -- 735
			"talentOffers=" .. (s.talentOffers == nil and "" or table.concat(s.talentOffers, ",")), -- 736
			"talentRanks=" .. (s.talentRanks == nil and "" or table.concat(s.talentRanks, ",")), -- 737
			"escortAttempt=" .. tostring(math.floor((s.escortAttempt or 1) + 0.5)), -- 738
			"escortVariant=" .. tostring(math.floor((s.escortVariant or 0) + 0.5)), -- 739
			"talentDeferred=" .. (s.talentDeferred == true and "true" or "false"), -- 740
			"talentVitality=" .. tostring(math.floor((s.talentVitality or 0) + 0.5)), -- 741
			"talentReload=" .. tostring(math.floor((s.talentReload or 0) + 0.5)), -- 742
			"talentGuard=" .. tostring(math.floor((s.talentGuard or 0) + 0.5)), -- 743
			"talentCraft=" .. tostring(math.floor((s.talentCraft or 0) + 0.5)), -- 744
			"props=" .. (s.props == nil and "" or table.concat(s.props, ",")), -- 745
			"playerX=" .. tostring(s.playerX == nil and -1 or math.floor(s.playerX + 0.5)), -- 746
			"playerY=" .. tostring(s.playerY == nil and 0 or math.floor(s.playerY + 0.5)), -- 747
			"playerDepth=" .. tostring(s.playerDepth == nil and 0 or math.floor(s.playerDepth + 0.5)), -- 748
			"gateTick=" .. tostring(math.floor((s.gateTick or 0) + 0.5)), -- 749
			"hasBottle=" .. (s.hasBottle == true and "true" or "false"), -- 750
			"villagePassed=" .. (s.villagePassed == true and "true" or "false"), -- 751
			"" -- 752
		}, -- 752
		"\n" -- 753
	) -- 753
end -- 695
function ____exports.parseSession(text) -- 756
	if #text == 0 then -- 757
		return {ok = false, status = "corrupt", reason = "局中存档为空"} -- 758
	end -- 758
	local verRaw = lineValue(text, "version") -- 760
	if verRaw == nil then -- 761
		return {ok = false, status = "corrupt", reason = "缺少 version 行"} -- 762
	end -- 762
	local ver = intOf(verRaw, -1) -- 764
	if ver < 0 then -- 765
		return {ok = false, status = "corrupt", reason = "version 非法"} -- 766
	end -- 766
	if ver > ____exports.SESSION_VERSION then -- 768
		return { -- 769
			ok = false, -- 769
			status = "unsupported", -- 769
			reason = (("局中存档版本 " .. tostring(ver)) .. " 高于当前 ") .. tostring(____exports.SESSION_VERSION) -- 769
		} -- 769
	end -- 769
	local roomKey = lineValue(text, "roomKey") -- 771
	if roomKey == nil or roomKey == "" then -- 772
		return {ok = false, status = "corrupt", reason = "缺少 roomKey"} -- 773
	end -- 773
	local routeRaw = lineValue(text, "route") or "" -- 775
	if routeRaw ~= "" and routeRaw ~= "child" and routeRaw ~= "soldier" then -- 776
		return {ok = false, status = "corrupt", reason = "route 取值非法"} -- 777
	end -- 777
	local settled = parseBoolField( -- 779
		lineValue(text, "settled"), -- 779
		false -- 779
	) -- 779
	local handDone = parseBoolField( -- 780
		lineValue(text, "handDone"), -- 780
		false -- 780
	) -- 780
	local lineSaid = parseBoolField( -- 781
		lineValue(text, "lineSaid"), -- 781
		false -- 781
	) -- 781
	local tied = parseBoolField( -- 782
		lineValue(text, "tied"), -- 782
		false -- 782
	) -- 782
	local carry = parseBoolField( -- 783
		lineValue(text, "carry"), -- 783
		false -- 783
	) -- 783
	local escortDone = parseBoolField( -- 784
		lineValue(text, "escortDone"), -- 784
		false -- 784
	) -- 784
	local cartDocked = parseBoolField( -- 785
		lineValue(text, "cartDocked"), -- 785
		false -- 785
	) -- 785
	local joined = parseBoolField( -- 786
		lineValue(text, "joined"), -- 786
		false -- 786
	) -- 786
	local c1Latch = parseBoolField( -- 787
		lineValue(text, "c1Latch"), -- 787
		false -- 787
	) -- 787
	local c2Latch = parseBoolField( -- 788
		lineValue(text, "c2Latch"), -- 788
		false -- 788
	) -- 788
	if settled == nil or handDone == nil or lineSaid == nil or tied == nil or carry == nil or escortDone == nil or cartDocked == nil or joined == nil or c1Latch == nil or c2Latch == nil then -- 789
		return {ok = false, status = "corrupt", reason = "布尔字段非法"} -- 792
	end -- 792
	local campRouteRaw = lineValue(text, "campaignRoute") or "" -- 794
	if campRouteRaw ~= "" and campRouteRaw ~= "outer" and campRouteRaw ~= "drygoods" then -- 795
		return {ok = false, status = "corrupt", reason = "campaignRoute 取值非法"} -- 796
	end -- 796
	local hp = intOf( -- 798
		lineValue(text, "hp") or "3", -- 798
		-1 -- 798
	) -- 798
	local maxHp = intOf( -- 799
		lineValue(text, "maxHp") or "3", -- 799
		-1 -- 799
	) -- 799
	if hp < 0 or maxHp <= 0 then -- 800
		return {ok = false, status = "corrupt", reason = "血量字段非法"} -- 801
	end -- 801
	return { -- 803
		ok = true, -- 804
		status = "ok", -- 805
		reason = "ok", -- 806
		state = { -- 807
			roomKey = roomKey, -- 808
			checkpoint = intOf( -- 809
				lineValue(text, "checkpoint") or "0", -- 809
				0 -- 809
			), -- 809
			seed = intOf( -- 810
				lineValue(text, "seed") or "20261124", -- 810
				20261124 -- 810
			), -- 810
			route = routeRaw, -- 811
			hp = hp, -- 812
			maxHp = maxHp, -- 813
			hpAtGate = intOf( -- 814
				lineValue(text, "hpAtGate") or "-1", -- 814
				-1 -- 814
			), -- 814
			maxHpAtGate = intOf( -- 815
				lineValue(text, "maxHpAtGate") or "-1", -- 815
				-1 -- 815
			), -- 815
			settled = settled, -- 816
			phase = lineValue(text, "phase") or "", -- 817
			countTick = math.max( -- 818
				0, -- 818
				intOf( -- 818
					lineValue(text, "countTick") or "0", -- 818
					0 -- 818
				) -- 818
			), -- 818
			phaseTick = math.max( -- 819
				0, -- 819
				intOf( -- 819
					lineValue(text, "phaseTick") or "0", -- 819
					0 -- 819
				) -- 819
			), -- 819
			handTicks = math.max( -- 820
				0, -- 820
				intOf( -- 820
					lineValue(text, "handTicks") or "0", -- 820
					0 -- 820
				) -- 820
			), -- 820
			handDone = handDone, -- 821
			lineSaid = lineSaid, -- 822
			tied = tied, -- 823
			carry = carry, -- 824
			escortDone = escortDone, -- 825
			craftedWeapon = lineValue(text, "craftedWeapon") or "", -- 826
			equippedWeapon = lineValue(text, "equippedWeapon") or "", -- 827
			wood = math.max( -- 828
				0, -- 828
				intOf( -- 828
					lineValue(text, "wood") or "0", -- 828
					0 -- 828
				) -- 828
			), -- 828
			bell = math.max( -- 829
				0, -- 829
				intOf( -- 829
					lineValue(text, "bell") or "0", -- 829
					0 -- 829
				) -- 829
			), -- 829
			scrap = math.max( -- 830
				0, -- 830
				intOf( -- 830
					lineValue(text, "scrap") or "0", -- 830
					0 -- 830
				) -- 830
			), -- 830
			wedge = math.max( -- 831
				0, -- 831
				intOf( -- 831
					lineValue(text, "wedge") or "0", -- 831
					0 -- 831
				) -- 831
			), -- 831
			ammo = math.max( -- 832
				0, -- 832
				intOf( -- 832
					lineValue(text, "ammo") or "0", -- 832
					0 -- 832
				) -- 832
			), -- 832
			shield = math.max( -- 833
				0, -- 833
				intOf( -- 833
					lineValue(text, "shield") or "0", -- 833
					0 -- 833
				) -- 833
			), -- 833
			pass = math.max( -- 834
				0, -- 834
				intOf( -- 834
					lineValue(text, "pass") or "0", -- 834
					0 -- 834
				) -- 834
			), -- 834
			quickbelt = math.max( -- 835
				0, -- 835
				intOf( -- 835
					lineValue(text, "quickbelt") or "0", -- 835
					0 -- 835
				) -- 835
			), -- 835
			taken = parseListField(lineValue(text, "taken")), -- 836
			segments = parseListField(lineValue(text, "segments")), -- 837
			cartAxle = intOf( -- 838
				lineValue(text, "cartAxle") or "0", -- 838
				0 -- 838
			), -- 838
			cartDocked = cartDocked, -- 839
			campaignRoute = campRouteRaw, -- 840
			joined = joined, -- 841
			c1Latch = c1Latch, -- 842
			c2Latch = c2Latch, -- 843
			talentSeed = math.max( -- 844
				0, -- 844
				intOf( -- 844
					lineValue(text, "talentSeed") or "0", -- 844
					0 -- 844
				) -- 844
			), -- 844
			talentRoom = lineValue(text, "talentRoom") or "", -- 845
			talentOffers = parseListField(lineValue(text, "talentOffers")), -- 846
			talentRanks = parseListField(lineValue(text, "talentRanks")), -- 847
			escortAttempt = math.max( -- 848
				1, -- 848
				intOf( -- 848
					lineValue(text, "escortAttempt") or "1", -- 848
					1 -- 848
				) -- 848
			), -- 848
			escortVariant = math.max( -- 849
				0, -- 849
				intOf( -- 849
					lineValue(text, "escortVariant") or "0", -- 849
					0 -- 849
				) -- 849
			), -- 849
			talentDeferred = parseBoolField( -- 850
				lineValue(text, "talentDeferred"), -- 850
				false -- 850
			) == true, -- 850
			talentVitality = math.max( -- 851
				0, -- 851
				intOf( -- 851
					lineValue(text, "talentVitality") or "0", -- 851
					0 -- 851
				) -- 851
			), -- 851
			talentReload = math.max( -- 852
				0, -- 852
				intOf( -- 852
					lineValue(text, "talentReload") or "0", -- 852
					0 -- 852
				) -- 852
			), -- 852
			talentGuard = math.max( -- 853
				0, -- 853
				intOf( -- 853
					lineValue(text, "talentGuard") or "0", -- 853
					0 -- 853
				) -- 853
			), -- 853
			talentCraft = math.max( -- 854
				0, -- 854
				intOf( -- 854
					lineValue(text, "talentCraft") or "0", -- 854
					0 -- 854
				) -- 854
			), -- 854
			props = parseListField(lineValue(text, "props")), -- 855
			playerX = intOf( -- 856
				lineValue(text, "playerX") or "-1", -- 856
				-1 -- 856
			), -- 856
			playerY = intOf( -- 857
				lineValue(text, "playerY") or "0", -- 857
				0 -- 857
			), -- 857
			playerDepth = intOf( -- 858
				lineValue(text, "playerDepth") or "0", -- 858
				0 -- 858
			), -- 858
			gateTick = math.max( -- 859
				0, -- 859
				intOf( -- 859
					lineValue(text, "gateTick") or "0", -- 859
					0 -- 859
				) -- 859
			), -- 859
			hasBottle = parseBoolField( -- 860
				lineValue(text, "hasBottle"), -- 860
				false -- 860
			) == true, -- 860
			villagePassed = parseBoolField( -- 861
				lineValue(text, "villagePassed"), -- 861
				false -- 861
			) == true -- 861
		} -- 861
	} -- 861
end -- 756
local function usableSessionBackup(path) -- 866
	if not ops:exist(path) then -- 867
		return false -- 868
	end -- 868
	return ____exports.parseSession(loadText(path)).ok -- 870
end -- 866
local function restoreSessionFrom(candidate, target, keepCandidate) -- 873
	if not usableSessionBackup(candidate) then -- 874
		return false -- 875
	end -- 875
	if not ops:copy(candidate, target) then -- 877
		return false -- 878
	end -- 878
	if not sameContent(candidate, target) then -- 880
		return false -- 881
	end -- 881
	if not keepCandidate then -- 883
		ops:remove(candidate) -- 884
	end -- 884
	return true -- 886
end -- 873
function ____exports.hasSessionSave() -- 889
	local target = absPath(currentSessionFile) -- 890
	if usableSessionBackup(target) then -- 891
		return true -- 892
	end -- 892
	return usableSessionBackup(target .. ".tmp") or usableSessionBackup(target .. ".prev") -- 894
end -- 889
function ____exports.loadSession() -- 897
	local target = absPath(currentSessionFile) -- 898
	local tmp = target .. ".tmp" -- 899
	local prev = target .. ".prev" -- 900
	if not ops:exist(target) then -- 901
		if restoreSessionFrom(tmp, target, false) then -- 902
			local p = ____exports.parseSession(loadText(target)) -- 903
			return { -- 904
				state = p.state, -- 904
				status = "ok", -- 904
				detail = "由 .tmp 恢复局中存档", -- 904
				recovered = true, -- 904
				backup = "" -- 904
			} -- 904
		end -- 904
		if restoreSessionFrom(prev, target, true) then -- 906
			local p = ____exports.parseSession(loadText(target)) -- 907
			return { -- 908
				state = p.state, -- 908
				status = "ok", -- 908
				detail = "由 .prev 恢复局中存档", -- 908
				recovered = true, -- 908
				backup = "" -- 908
			} -- 908
		end -- 908
		return { -- 910
			state = nil, -- 910
			status = "missing", -- 910
			detail = "无局中存档", -- 910
			recovered = false, -- 910
			backup = "" -- 910
		} -- 910
	end -- 910
	local parsed = ____exports.parseSession(loadText(target)) -- 912
	if parsed.ok and parsed.state ~= nil then -- 913
		if ops:exist(tmp) and sameContent(tmp, target) then -- 914
			ops:remove(tmp) -- 915
		end -- 915
		return { -- 917
			state = parsed.state, -- 917
			status = "ok", -- 917
			detail = "局中存档读取成功", -- 917
			recovered = false, -- 917
			backup = "" -- 917
		} -- 917
	end -- 917
	if parsed.status == "corrupt" then -- 919
		local broken = backupCorrupt(target, ".corrupt") -- 920
		if restoreSessionFrom(tmp, target, false) then -- 921
			local p = ____exports.parseSession(loadText(target)) -- 922
			return { -- 923
				state = p.state, -- 923
				status = "ok", -- 923
				detail = "原局中存档损坏，已用 .tmp 恢复", -- 923
				recovered = true, -- 923
				backup = broken -- 923
			} -- 923
		end -- 923
		if restoreSessionFrom(prev, target, true) then -- 925
			local p = ____exports.parseSession(loadText(target)) -- 926
			return { -- 927
				state = p.state, -- 927
				status = "ok", -- 927
				detail = "原局中存档损坏，已用 .prev 恢复", -- 927
				recovered = true, -- 927
				backup = broken -- 927
			} -- 927
		end -- 927
		return { -- 929
			state = nil, -- 929
			status = "corrupt", -- 929
			detail = parsed.reason, -- 929
			recovered = false, -- 929
			backup = broken -- 929
		} -- 929
	end -- 929
	local backup = backupCorrupt(target, ".unsupported") -- 931
	return { -- 932
		state = nil, -- 932
		status = "unsupported", -- 932
		detail = parsed.reason, -- 932
		recovered = false, -- 932
		backup = backup -- 932
	} -- 932
end -- 897
function ____exports.saveSession(state) -- 935
	local target = absPath(currentSessionFile) -- 936
	local dir = dirOf(target) -- 937
	if dir ~= "" and not ops:isdir(dir) then -- 938
		ops:mkdir(dir) -- 939
	end -- 939
	local tmp = target .. ".tmp" -- 941
	local prev = target .. ".prev" -- 942
	local text = ____exports.formatSession(state) -- 943
	if not ops:save(tmp, text) then -- 944
		ops:remove(tmp) -- 945
		return false -- 946
	end -- 946
	local written = ops:load(tmp) -- 948
	if written == nil or normalize(written) ~= normalize(text) then -- 949
		ops:remove(tmp) -- 950
		return false -- 951
	end -- 951
	local existed = ops:exist(target) -- 953
	local backedUp = false -- 954
	if existed then -- 955
		if usableSessionBackup(target) then -- 956
			backedUp = ops:copy(target, prev) -- 957
			if not backedUp or not usableSessionBackup(prev) then -- 958
				ops:remove(tmp) -- 959
				return false -- 960
			end -- 960
		else -- 960
			backupCorrupt(target, ".corrupt") -- 963
		end -- 963
	end -- 963
	if not ops:copy(tmp, target) then -- 966
		if existed and backedUp and not sameContent(target, prev) then -- 967
			ops:copy(prev, target) -- 968
		end -- 968
		return false -- 970
	end -- 970
	local check = ops:load(target) -- 972
	if check == nil or normalize(check) ~= normalize(text) then -- 973
		if existed and backedUp and ops:copy(prev, target) and usableSessionBackup(target) then -- 974
			ops:remove(tmp) -- 975
		end -- 975
		return false -- 977
	end -- 977
	ops:remove(tmp) -- 979
	return true -- 980
end -- 935
function ____exports.clearSession() -- 983
	local target = absPath(currentSessionFile) -- 984
	local tmp = target .. ".tmp" -- 985
	local prev = target .. ".prev" -- 986
	local ok = true -- 987
	if ops:exist(target) then -- 988
		ok = ops:remove(target) and ok -- 989
	end -- 989
	if ops:exist(tmp) then -- 991
		ops:remove(tmp) -- 992
	end -- 992
	if ops:exist(prev) then -- 994
		ops:remove(prev) -- 995
	end -- 995
	return ok -- 997
end -- 983
return ____exports -- 983
