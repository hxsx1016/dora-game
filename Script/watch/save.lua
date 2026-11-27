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
function ____exports.emptySave() -- 151
	return { -- 152
		childCleared = false, -- 153
		soldierCleared = false, -- 154
		artifactOwned = false, -- 155
		museumPhase = "locked", -- 156
		museumSeen = false -- 157
	} -- 157
end -- 151
function lineValue(text, key) -- 161
	local lines = __TS__StringSplit(text, "\n") -- 162
	local prefix = key .. "=" -- 163
	local i = 0 -- 164
	do -- 164
		i = 0 -- 165
		while i < #lines do -- 165
			local line = lines[i + 1] -- 166
			if #line >= #prefix and __TS__StringSubstring(line, 0, #prefix) == prefix then -- 167
				return __TS__StringSubstring(line, #prefix) -- 168
			end -- 168
			i = i + 1 -- 165
		end -- 165
	end -- 165
	return nil -- 171
end -- 171
function intOf(text, fallback) -- 174
	if #text == 0 then -- 175
		return fallback -- 176
	end -- 176
	local i = 0 -- 178
	local sign = 1 -- 179
	if string.sub(text, 1, 1) == "-" then -- 180
		sign = -1 -- 181
		i = 1 -- 182
	end -- 182
	local n = 0 -- 184
	local digits = 0 -- 185
	do -- 185
		while i < #text do -- 186
			local c = __TS__StringCharCodeAt(text, i) -- 187
			if c < 48 or c > 57 then -- 188
				return fallback -- 189
			end -- 189
			n = n * 10 + (c - 48) -- 191
			digits = digits + 1 -- 192
			i = i + 1 -- 186
		end -- 186
	end -- 186
	if digits == 0 then -- 194
		return fallback -- 195
	end -- 195
	return sign * n -- 197
end -- 197
function formatSave(state) -- 200
	return table.concat( -- 201
		{ -- 201
			"version=" .. tostring(____exports.SAVE_VERSION), -- 202
			"childCleared=" .. (state.childCleared and "true" or "false"), -- 203
			"soldierCleared=" .. (state.soldierCleared and "true" or "false"), -- 204
			"artifactOwned=" .. (state.artifactOwned and "true" or "false"), -- 205
			"museumPhase=" .. state.museumPhase, -- 206
			"museumSeen=" .. (state.museumSeen and "true" or "false"), -- 207
			"" -- 208
		}, -- 208
		"\n" -- 209
	) -- 209
end -- 209
function parseSave(text) -- 223
	local bad = { -- 224
		ok = false, -- 224
		status = "corrupt", -- 224
		reason = "", -- 224
		state = ____exports.emptySave() -- 224
	} -- 224
	if #text == 0 then -- 225
		bad.reason = "档案为空" -- 226
		return bad -- 227
	end -- 227
	local versionText = lineValue(text, "version") -- 229
	if versionText == nil then -- 230
		bad.reason = "缺少 version 行" -- 231
		return bad -- 232
	end -- 232
	local version = intOf(versionText, -1) -- 234
	if version < 0 then -- 235
		bad.reason = "version 不是十进制整数" -- 236
		return bad -- 237
	end -- 237
	if version > ____exports.SAVE_VERSION then -- 239
		return { -- 240
			ok = false, -- 240
			status = "unsupported", -- 240
			reason = (("版本 " .. tostring(version)) .. " 高于 ") .. tostring(____exports.SAVE_VERSION), -- 240
			state = ____exports.emptySave() -- 240
		} -- 240
	end -- 240
	if version ~= ____exports.SAVE_VERSION then -- 242
		bad.reason = "不支持的旧版本 " .. tostring(version) -- 243
		return bad -- 244
	end -- 244
	local boolKeys = {"childCleared", "soldierCleared", "artifactOwned", "museumSeen"} -- 246
	local bools = {} -- 247
	local i = 0 -- 248
	do -- 248
		i = 0 -- 249
		while i < #boolKeys do -- 249
			local value = lineValue(text, boolKeys[i + 1]) -- 250
			if value == nil then -- 251
				bad.reason = "缺少字段 " .. boolKeys[i + 1] -- 252
				return bad -- 253
			end -- 253
			if value ~= "true" and value ~= "false" then -- 255
				bad.reason = ("字段 " .. boolKeys[i + 1]) .. " 不是布尔值" -- 256
				return bad -- 257
			end -- 257
			bools[#bools + 1] = value == "true" -- 259
			i = i + 1 -- 249
		end -- 249
	end -- 249
	local phase = lineValue(text, "museumPhase") -- 261
	if phase == nil then -- 262
		bad.reason = "缺少字段 museumPhase" -- 263
		return bad -- 264
	end -- 264
	if not isMuseumPhase(phase) then -- 266
		bad.reason = "museumPhase 不在枚举内" -- 267
		return bad -- 268
	end -- 268
	return { -- 270
		ok = true, -- 271
		status = "ok", -- 272
		reason = "版本 " .. tostring(version), -- 273
		state = { -- 274
			childCleared = bools[1], -- 275
			soldierCleared = bools[2], -- 276
			artifactOwned = bools[3], -- 277
			museumPhase = phase, -- 278
			museumSeen = bools[4] -- 279
		} -- 279
	} -- 279
end -- 279
function normalize(text) -- 284
	return table.concat( -- 285
		__TS__StringSplit( -- 285
			table.concat( -- 285
				__TS__StringSplit(text, "\r\n"), -- 285
				"\n" -- 285
			), -- 285
			"\r" -- 285
		), -- 285
		"\n" -- 285
	) -- 285
end -- 285
function sameContent(a, b) -- 289
	local textA = ops:load(a) -- 290
	local textB = ops:load(b) -- 291
	if textA == nil or textB == nil then -- 292
		return false -- 293
	end -- 293
	return normalize(textA) == normalize(textB) -- 295
end -- 295
function backupPathFor(target, suffix) -- 299
	local candidate = target .. suffix -- 300
	if not ops:exist(candidate) then -- 301
		return candidate -- 302
	end -- 302
	local n = 2 -- 304
	while n <= 9999 do -- 305
		candidate = ((target .. suffix) .. ".") .. tostring(n) -- 306
		if not ops:exist(candidate) then -- 307
			return candidate -- 308
		end -- 308
		n = n + 1 -- 310
	end -- 310
	return "" -- 312
end -- 312
function backupCorrupt(target, suffix) -- 319
	if not ops:exist(target) then -- 320
		return "" -- 321
	end -- 321
	local backup = backupPathFor(target, suffix) -- 323
	if backup == "" then -- 324
		return "" -- 325
	end -- 325
	if not ops:copy(target, backup) then -- 327
		return "" -- 328
	end -- 328
	if not sameContent(target, backup) then -- 330
		return "" -- 331
	end -- 331
	return backup -- 333
end -- 333
function usableBackup(path) -- 346
	if not ops:exist(path) then -- 347
		return false -- 348
	end -- 348
	local text = ops:load(path) -- 350
	return text ~= nil and parseSave(text).ok -- 351
end -- 351
function dirOf(path) -- 456
	local i = #path - 1 -- 457
	do -- 457
		while i >= 0 do -- 458
			local ch = __TS__StringCharAt(path, i) -- 459
			if ch == "/" or ch == "\\" then -- 460
				return __TS__StringSubstring(path, 0, i) -- 461
			end -- 461
			i = i - 1 -- 458
		end -- 458
	end -- 458
	return "" -- 464
end -- 464
--- 写入档案：写 `.tmp` → 校验 → 备份旧档到 `.prev`（校验成功才继续）→ 覆盖目标 → 回读校验。
-- 失败语义：
--   - 备份失败：不覆盖目标，清掉本次 `.tmp`（旧档完好），返回 false；
--   - 覆盖失败：尝试从 `.prev` 回滚；`.tmp` 保留为最新候选，返回 false；
--   - 校验失败：用 `.prev` 回滚；回滚失败则保留 `.tmp`，返回 false。
-- 未知版本原件（按路径保护）拒绝写入。
function ____exports.saveSave(state) -- 475
	local target = absPath(currentFile) -- 476
	if protectedPath == target then -- 477
		return false -- 478
	end -- 478
	local dir = dirOf(target) -- 480
	if dir ~= "" and not ops:isdir(dir) then -- 481
		ops:mkdir(dir) -- 482
	end -- 482
	local tmp = target .. ".tmp" -- 484
	local prev = target .. ".prev" -- 485
	local text = formatSave(state) -- 486
	if fault == "write" then -- 488
		return false -- 489
	end -- 489
	if not ops:save(tmp, text) then -- 491
		ops:remove(tmp) -- 492
		return false -- 493
	end -- 493
	local written = ops:load(tmp) -- 495
	if written == nil or normalize(written) ~= normalize(text) then -- 496
		ops:remove(tmp) -- 497
		return false -- 498
	end -- 498
	local existed = ops:exist(target) -- 501
	local backedUp = false -- 502
	if existed then -- 503
		if usableBackup(target) then -- 504
			backedUp = ops:copy(target, prev) -- 505
			if not backedUp or not usableBackup(prev) then -- 506
				ops:remove(tmp) -- 508
				return false -- 509
			end -- 509
		else -- 509
			backupCorrupt(target, ".corrupt") -- 513
		end -- 513
	end -- 513
	if not copyForWrite(tmp, target) then -- 517
		if existed and backedUp and not sameContent(target, prev) then -- 518
			ops:copy(prev, target) -- 519
		end -- 519
		return false -- 522
	end -- 522
	local check = ops:load(target) -- 525
	if fault == "verify" or check == nil or normalize(check) ~= normalize(text) then -- 526
		if existed and backedUp and ops:copy(prev, target) and usableBackup(target) then -- 527
			ops:remove(tmp) -- 528
			return false -- 529
		end -- 529
		return false -- 532
	end -- 532
	ops:remove(tmp) -- 535
	return true -- 536
end -- 475
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
--- 读文本；读不到按空串处理（解析会判 corrupt）。
local function loadText(path) -- 337
	local text = ops:load(path) -- 338
	if text == nil then -- 339
		return "" -- 340
	end -- 340
	return text -- 342
end -- 337
--- 用候选件恢复目标；成功（复制成功且回读解析一致）才清候选，失败保留候选并返回 false。
local function restoreFrom(candidate, target, keepCandidate) -- 355
	if not usableBackup(candidate) then -- 356
		return false -- 357
	end -- 357
	if not ops:copy(candidate, target) then -- 359
		return false -- 360
	end -- 360
	local again = parseSave(loadText(target)) -- 362
	if not again.ok then -- 363
		return false -- 364
	end -- 364
	if not keepCandidate then -- 366
		ops:remove(candidate) -- 367
	end -- 367
	return true -- 369
end -- 355
--- 读取档案。
-- 自愈顺序：
--   目标缺失 → 完整 `.tmp` → 完整 `.prev`；
--   目标损坏 → 完整 `.tmp`（最新候选）→ 完整 `.prev`。
-- 损坏/未知版本先派生备份；未知版本原件置保护位（按路径），普通写档拒绝覆盖。
function ____exports.loadSave() -- 379
	local target = absPath(currentFile) -- 380
	local tmp = target .. ".tmp" -- 381
	local prev = target .. ".prev" -- 382
	local recovered = false -- 383
	local recoveryDetail = "" -- 384
	if not ops:exist(target) then -- 386
		if restoreFrom(tmp, target, false) then -- 387
			recovered = true -- 388
			recoveryDetail = "目标缺失，已用完整 .tmp 恢复" -- 389
		elseif restoreFrom(prev, target, true) then -- 390
			recovered = true -- 391
			recoveryDetail = "目标缺失，已用完整 .prev 恢复" -- 392
		end -- 392
	end -- 392
	if not ops:exist(target) then -- 396
		return { -- 397
			state = ____exports.emptySave(), -- 398
			status = "missing", -- 398
			detail = "无档案，按新档起局" .. (recovered and ("（" .. recoveryDetail) .. "）" or ""), -- 399
			recovered = recovered, -- 400
			backup = "", -- 400
			action = "none" -- 400
		} -- 400
	end -- 400
	local text = ops:load(target) -- 404
	local parsed = parseSave(text == nil and "" or text) -- 405
	if parsed.ok then -- 406
		if ops:exist(tmp) and sameContent(tmp, target) then -- 408
			ops:remove(tmp) -- 409
		end -- 409
		return { -- 411
			state = parsed.state, -- 412
			status = "ok", -- 412
			detail = parsed.reason .. (recovered and ("（" .. recoveryDetail) .. "）" or ""), -- 413
			recovered = recovered, -- 414
			backup = "", -- 414
			action = "keep" -- 414
		} -- 414
	end -- 414
	if parsed.status == "corrupt" then -- 418
		local broken = backupCorrupt(target, ".corrupt") -- 419
		if restoreFrom(tmp, target, false) then -- 420
			return { -- 421
				state = parseSave(loadText(target)).state, -- 422
				status = "ok", -- 423
				detail = (("原档损坏（" .. parsed.reason) .. "），已用完整 .tmp 恢复，损坏件备份为 ") .. broken, -- 424
				recovered = true, -- 425
				backup = broken, -- 425
				action = "keep" -- 425
			} -- 425
		end -- 425
		if restoreFrom(prev, target, true) then -- 428
			return { -- 429
				state = parseSave(loadText(target)).state, -- 430
				status = "ok", -- 431
				detail = (("原档损坏（" .. parsed.reason) .. "），已用 .prev 恢复，损坏件备份为 ") .. broken, -- 432
				recovered = true, -- 433
				backup = broken, -- 433
				action = "keep" -- 433
			} -- 433
		end -- 433
		return { -- 437
			state = ____exports.emptySave(), -- 438
			status = "corrupt", -- 438
			detail = (("档案损坏（" .. parsed.reason) .. "），原件保留") .. (broken ~= "" and "，损坏件备份为 " .. broken or "，备份失败（原件未动）"), -- 439
			recovered = false, -- 441
			backup = broken, -- 441
			action = "reset" -- 441
		} -- 441
	end -- 441
	local backup = backupCorrupt(target, ".unsupported") -- 445
	protectedPath = target -- 446
	return { -- 447
		state = ____exports.emptySave(), -- 448
		status = "unsupported", -- 448
		detail = (("档案版本不支持（" .. parsed.reason) .. "），原件保留") .. (backup ~= "" and "：" .. backup or "，备份失败（原件未动）"), -- 449
		recovered = recovered, -- 451
		backup = backup, -- 451
		action = "reset" -- 451
	} -- 451
end -- 379
--- 恢复策略（给前端「档案损坏/版本不支持」页用）：把原件隔离到派生备份后删除。
-- 只有备份复制成功、内容与原件一致、且备份本身可解析时才删除目标。
function ____exports.resetSave() -- 543
	local target = absPath(currentFile) -- 544
	if not ops:exist(target) then -- 545
		return false -- 546
	end -- 546
	local backup = backupCorrupt(target, ".reset") -- 548
	if backup == "" then -- 549
		return false -- 550
	end -- 550
	if not sameContent(target, backup) then -- 553
		return false -- 554
	end -- 554
	if not ops:remove(target) then -- 556
		return false -- 557
	end -- 557
	if protectedPath == target then -- 559
		protectedPath = "" -- 560
	end -- 560
	return true -- 562
end -- 543
--- 档案内容签名：用于「正式通关是否变化」的幂等判断。
function ____exports.saveSignature(state) -- 566
	return table.concat({ -- 567
		state.childCleared and "1" or "0", -- 568
		state.soldierCleared and "1" or "0", -- 569
		state.artifactOwned and "1" or "0", -- 570
		state.museumPhase, -- 571
		state.museumSeen and "1" or "0" -- 572
	}, "|") -- 573
end -- 566
____exports.SESSION_VERSION = 1 -- 580
____exports.SESSION_FILE = "watch-save/session.txt" -- 581
local currentSessionFile = ____exports.SESSION_FILE -- 647
function ____exports.setSessionFile(path) -- 649
	currentSessionFile = path == "" and ____exports.SESSION_FILE or path -- 650
end -- 649
function ____exports.getSessionFile() -- 653
	return currentSessionFile -- 654
end -- 653
local function parseBoolField(raw, fallback) -- 657
	if raw == nil then -- 658
		return fallback -- 659
	end -- 659
	if raw == "true" or raw == "1" then -- 661
		return true -- 662
	end -- 662
	if raw == "false" or raw == "0" then -- 664
		return false -- 665
	end -- 665
	return nil -- 667
end -- 657
local function parseListField(raw) -- 670
	if raw == nil or raw == "" then -- 671
		return {} -- 672
	end -- 672
	local parts = __TS__StringSplit(raw, ",") -- 674
	local out = {} -- 675
	local i = 0 -- 676
	do -- 676
		i = 0 -- 677
		while i < #parts do -- 677
			local item = __TS__StringTrim(parts[i + 1]) -- 678
			if item ~= "" then -- 679
				out[#out + 1] = item -- 680
			end -- 680
			i = i + 1 -- 677
		end -- 677
	end -- 677
	return out -- 683
end -- 670
local function formatSession(s) -- 686
	return table.concat( -- 687
		{ -- 687
			"version=" .. tostring(____exports.SESSION_VERSION), -- 688
			"roomKey=" .. s.roomKey, -- 689
			"checkpoint=" .. tostring(math.floor(s.checkpoint + 0.5)), -- 690
			"seed=" .. tostring(math.floor(s.seed + 0.5)), -- 691
			"route=" .. s.route, -- 692
			"hp=" .. tostring(math.floor(s.hp + 0.5)), -- 693
			"maxHp=" .. tostring(math.floor(s.maxHp + 0.5)), -- 694
			"hpAtGate=" .. tostring(math.floor(s.hpAtGate + 0.5)), -- 695
			"maxHpAtGate=" .. tostring(math.floor(s.maxHpAtGate + 0.5)), -- 696
			"settled=" .. (s.settled and "true" or "false"), -- 697
			"phase=" .. s.phase, -- 698
			"countTick=" .. tostring(math.floor(s.countTick + 0.5)), -- 699
			"phaseTick=" .. tostring(math.floor(s.phaseTick + 0.5)), -- 700
			"handTicks=" .. tostring(math.floor(s.handTicks + 0.5)), -- 701
			"handDone=" .. (s.handDone and "true" or "false"), -- 702
			"lineSaid=" .. (s.lineSaid and "true" or "false"), -- 703
			"tied=" .. (s.tied and "true" or "false"), -- 704
			"carry=" .. (s.carry and "true" or "false"), -- 705
			"escortDone=" .. (s.escortDone and "true" or "false"), -- 706
			"craftedWeapon=" .. s.craftedWeapon, -- 707
			"equippedWeapon=" .. s.equippedWeapon, -- 708
			"wood=" .. tostring(math.floor(s.wood + 0.5)), -- 709
			"bell=" .. tostring(math.floor(s.bell + 0.5)), -- 710
			"scrap=" .. tostring(math.floor(s.scrap + 0.5)), -- 711
			"wedge=" .. tostring(math.floor(s.wedge + 0.5)), -- 712
			"ammo=" .. tostring(math.floor(s.ammo + 0.5)), -- 713
			"shield=" .. tostring(math.floor(s.shield + 0.5)), -- 714
			"pass=" .. tostring(math.floor(s.pass + 0.5)), -- 715
			"quickbelt=" .. tostring(math.floor(s.quickbelt + 0.5)), -- 716
			"taken=" .. table.concat(s.taken, ","), -- 717
			"segments=" .. table.concat(s.segments, ","), -- 718
			"cartAxle=" .. tostring(math.floor(s.cartAxle + 0.5)), -- 719
			"cartDocked=" .. (s.cartDocked and "true" or "false"), -- 720
			"campaignRoute=" .. (s.campaignRoute or ""), -- 721
			"joined=" .. (s.joined == true and "true" or "false"), -- 722
			"c1Latch=" .. (s.c1Latch == true and "true" or "false"), -- 723
			"c2Latch=" .. (s.c2Latch == true and "true" or "false"), -- 724
			"talentSeed=" .. tostring(math.floor((s.talentSeed or 0) + 0.5)), -- 725
			"talentRoom=" .. (s.talentRoom or ""), -- 726
			"talentOffers=" .. (s.talentOffers == nil and "" or table.concat(s.talentOffers, ",")), -- 727
			"talentVitality=" .. tostring(math.floor((s.talentVitality or 0) + 0.5)), -- 728
			"talentReload=" .. tostring(math.floor((s.talentReload or 0) + 0.5)), -- 729
			"talentGuard=" .. tostring(math.floor((s.talentGuard or 0) + 0.5)), -- 730
			"talentCraft=" .. tostring(math.floor((s.talentCraft or 0) + 0.5)), -- 731
			"props=" .. (s.props == nil and "" or table.concat(s.props, ",")), -- 732
			"playerX=" .. tostring(s.playerX == nil and -1 or math.floor(s.playerX + 0.5)), -- 733
			"playerY=" .. tostring(s.playerY == nil and 0 or math.floor(s.playerY + 0.5)), -- 734
			"playerDepth=" .. tostring(s.playerDepth == nil and 0 or math.floor(s.playerDepth + 0.5)), -- 735
			"gateTick=" .. tostring(math.floor((s.gateTick or 0) + 0.5)), -- 736
			"hasBottle=" .. (s.hasBottle == true and "true" or "false"), -- 737
			"villagePassed=" .. (s.villagePassed == true and "true" or "false"), -- 738
			"" -- 739
		}, -- 739
		"\n" -- 740
	) -- 740
end -- 686
local function parseSession(text) -- 743
	if #text == 0 then -- 744
		return {ok = false, status = "corrupt", reason = "局中存档为空"} -- 745
	end -- 745
	local verRaw = lineValue(text, "version") -- 747
	if verRaw == nil then -- 748
		return {ok = false, status = "corrupt", reason = "缺少 version 行"} -- 749
	end -- 749
	local ver = intOf(verRaw, -1) -- 751
	if ver < 0 then -- 752
		return {ok = false, status = "corrupt", reason = "version 非法"} -- 753
	end -- 753
	if ver > ____exports.SESSION_VERSION then -- 755
		return { -- 756
			ok = false, -- 756
			status = "unsupported", -- 756
			reason = (("局中存档版本 " .. tostring(ver)) .. " 高于当前 ") .. tostring(____exports.SESSION_VERSION) -- 756
		} -- 756
	end -- 756
	local roomKey = lineValue(text, "roomKey") -- 758
	if roomKey == nil or roomKey == "" then -- 759
		return {ok = false, status = "corrupt", reason = "缺少 roomKey"} -- 760
	end -- 760
	local routeRaw = lineValue(text, "route") or "" -- 762
	if routeRaw ~= "" and routeRaw ~= "child" and routeRaw ~= "soldier" then -- 763
		return {ok = false, status = "corrupt", reason = "route 取值非法"} -- 764
	end -- 764
	local settled = parseBoolField( -- 766
		lineValue(text, "settled"), -- 766
		false -- 766
	) -- 766
	local handDone = parseBoolField( -- 767
		lineValue(text, "handDone"), -- 767
		false -- 767
	) -- 767
	local lineSaid = parseBoolField( -- 768
		lineValue(text, "lineSaid"), -- 768
		false -- 768
	) -- 768
	local tied = parseBoolField( -- 769
		lineValue(text, "tied"), -- 769
		false -- 769
	) -- 769
	local carry = parseBoolField( -- 770
		lineValue(text, "carry"), -- 770
		false -- 770
	) -- 770
	local escortDone = parseBoolField( -- 771
		lineValue(text, "escortDone"), -- 771
		false -- 771
	) -- 771
	local cartDocked = parseBoolField( -- 772
		lineValue(text, "cartDocked"), -- 772
		false -- 772
	) -- 772
	local joined = parseBoolField( -- 773
		lineValue(text, "joined"), -- 773
		false -- 773
	) -- 773
	local c1Latch = parseBoolField( -- 774
		lineValue(text, "c1Latch"), -- 774
		false -- 774
	) -- 774
	local c2Latch = parseBoolField( -- 775
		lineValue(text, "c2Latch"), -- 775
		false -- 775
	) -- 775
	if settled == nil or handDone == nil or lineSaid == nil or tied == nil or carry == nil or escortDone == nil or cartDocked == nil or joined == nil or c1Latch == nil or c2Latch == nil then -- 776
		return {ok = false, status = "corrupt", reason = "布尔字段非法"} -- 779
	end -- 779
	local campRouteRaw = lineValue(text, "campaignRoute") or "" -- 781
	if campRouteRaw ~= "" and campRouteRaw ~= "outer" and campRouteRaw ~= "drygoods" then -- 782
		return {ok = false, status = "corrupt", reason = "campaignRoute 取值非法"} -- 783
	end -- 783
	local hp = intOf( -- 785
		lineValue(text, "hp") or "3", -- 785
		-1 -- 785
	) -- 785
	local maxHp = intOf( -- 786
		lineValue(text, "maxHp") or "3", -- 786
		-1 -- 786
	) -- 786
	if hp < 0 or maxHp <= 0 then -- 787
		return {ok = false, status = "corrupt", reason = "血量字段非法"} -- 788
	end -- 788
	return { -- 790
		ok = true, -- 791
		status = "ok", -- 792
		reason = "ok", -- 793
		state = { -- 794
			roomKey = roomKey, -- 795
			checkpoint = intOf( -- 796
				lineValue(text, "checkpoint") or "0", -- 796
				0 -- 796
			), -- 796
			seed = intOf( -- 797
				lineValue(text, "seed") or "20261124", -- 797
				20261124 -- 797
			), -- 797
			route = routeRaw, -- 798
			hp = hp, -- 799
			maxHp = maxHp, -- 800
			hpAtGate = intOf( -- 801
				lineValue(text, "hpAtGate") or "-1", -- 801
				-1 -- 801
			), -- 801
			maxHpAtGate = intOf( -- 802
				lineValue(text, "maxHpAtGate") or "-1", -- 802
				-1 -- 802
			), -- 802
			settled = settled, -- 803
			phase = lineValue(text, "phase") or "", -- 804
			countTick = math.max( -- 805
				0, -- 805
				intOf( -- 805
					lineValue(text, "countTick") or "0", -- 805
					0 -- 805
				) -- 805
			), -- 805
			phaseTick = math.max( -- 806
				0, -- 806
				intOf( -- 806
					lineValue(text, "phaseTick") or "0", -- 806
					0 -- 806
				) -- 806
			), -- 806
			handTicks = math.max( -- 807
				0, -- 807
				intOf( -- 807
					lineValue(text, "handTicks") or "0", -- 807
					0 -- 807
				) -- 807
			), -- 807
			handDone = handDone, -- 808
			lineSaid = lineSaid, -- 809
			tied = tied, -- 810
			carry = carry, -- 811
			escortDone = escortDone, -- 812
			craftedWeapon = lineValue(text, "craftedWeapon") or "", -- 813
			equippedWeapon = lineValue(text, "equippedWeapon") or "", -- 814
			wood = math.max( -- 815
				0, -- 815
				intOf( -- 815
					lineValue(text, "wood") or "0", -- 815
					0 -- 815
				) -- 815
			), -- 815
			bell = math.max( -- 816
				0, -- 816
				intOf( -- 816
					lineValue(text, "bell") or "0", -- 816
					0 -- 816
				) -- 816
			), -- 816
			scrap = math.max( -- 817
				0, -- 817
				intOf( -- 817
					lineValue(text, "scrap") or "0", -- 817
					0 -- 817
				) -- 817
			), -- 817
			wedge = math.max( -- 818
				0, -- 818
				intOf( -- 818
					lineValue(text, "wedge") or "0", -- 818
					0 -- 818
				) -- 818
			), -- 818
			ammo = math.max( -- 819
				0, -- 819
				intOf( -- 819
					lineValue(text, "ammo") or "0", -- 819
					0 -- 819
				) -- 819
			), -- 819
			shield = math.max( -- 820
				0, -- 820
				intOf( -- 820
					lineValue(text, "shield") or "0", -- 820
					0 -- 820
				) -- 820
			), -- 820
			pass = math.max( -- 821
				0, -- 821
				intOf( -- 821
					lineValue(text, "pass") or "0", -- 821
					0 -- 821
				) -- 821
			), -- 821
			quickbelt = math.max( -- 822
				0, -- 822
				intOf( -- 822
					lineValue(text, "quickbelt") or "0", -- 822
					0 -- 822
				) -- 822
			), -- 822
			taken = parseListField(lineValue(text, "taken")), -- 823
			segments = parseListField(lineValue(text, "segments")), -- 824
			cartAxle = intOf( -- 825
				lineValue(text, "cartAxle") or "0", -- 825
				0 -- 825
			), -- 825
			cartDocked = cartDocked, -- 826
			campaignRoute = campRouteRaw, -- 827
			joined = joined, -- 828
			c1Latch = c1Latch, -- 829
			c2Latch = c2Latch, -- 830
			talentSeed = math.max( -- 831
				0, -- 831
				intOf( -- 831
					lineValue(text, "talentSeed") or "0", -- 831
					0 -- 831
				) -- 831
			), -- 831
			talentRoom = lineValue(text, "talentRoom") or "", -- 832
			talentOffers = parseListField(lineValue(text, "talentOffers")), -- 833
			talentVitality = math.max( -- 834
				0, -- 834
				intOf( -- 834
					lineValue(text, "talentVitality") or "0", -- 834
					0 -- 834
				) -- 834
			), -- 834
			talentReload = math.max( -- 835
				0, -- 835
				intOf( -- 835
					lineValue(text, "talentReload") or "0", -- 835
					0 -- 835
				) -- 835
			), -- 835
			talentGuard = math.max( -- 836
				0, -- 836
				intOf( -- 836
					lineValue(text, "talentGuard") or "0", -- 836
					0 -- 836
				) -- 836
			), -- 836
			talentCraft = math.max( -- 837
				0, -- 837
				intOf( -- 837
					lineValue(text, "talentCraft") or "0", -- 837
					0 -- 837
				) -- 837
			), -- 837
			props = parseListField(lineValue(text, "props")), -- 838
			playerX = intOf( -- 839
				lineValue(text, "playerX") or "-1", -- 839
				-1 -- 839
			), -- 839
			playerY = intOf( -- 840
				lineValue(text, "playerY") or "0", -- 840
				0 -- 840
			), -- 840
			playerDepth = intOf( -- 841
				lineValue(text, "playerDepth") or "0", -- 841
				0 -- 841
			), -- 841
			gateTick = math.max( -- 842
				0, -- 842
				intOf( -- 842
					lineValue(text, "gateTick") or "0", -- 842
					0 -- 842
				) -- 842
			), -- 842
			hasBottle = parseBoolField( -- 843
				lineValue(text, "hasBottle"), -- 843
				false -- 843
			) == true, -- 843
			villagePassed = parseBoolField( -- 844
				lineValue(text, "villagePassed"), -- 844
				false -- 844
			) == true -- 844
		} -- 844
	} -- 844
end -- 743
local function usableSessionBackup(path) -- 849
	if not ops:exist(path) then -- 850
		return false -- 851
	end -- 851
	return parseSession(loadText(path)).ok -- 853
end -- 849
local function restoreSessionFrom(candidate, target, keepCandidate) -- 856
	if not usableSessionBackup(candidate) then -- 857
		return false -- 858
	end -- 858
	if not ops:copy(candidate, target) then -- 860
		return false -- 861
	end -- 861
	if not sameContent(candidate, target) then -- 863
		return false -- 864
	end -- 864
	if not keepCandidate then -- 866
		ops:remove(candidate) -- 867
	end -- 867
	return true -- 869
end -- 856
function ____exports.hasSessionSave() -- 872
	local target = absPath(currentSessionFile) -- 873
	if usableSessionBackup(target) then -- 874
		return true -- 875
	end -- 875
	return usableSessionBackup(target .. ".tmp") or usableSessionBackup(target .. ".prev") -- 877
end -- 872
function ____exports.loadSession() -- 880
	local target = absPath(currentSessionFile) -- 881
	local tmp = target .. ".tmp" -- 882
	local prev = target .. ".prev" -- 883
	if not ops:exist(target) then -- 884
		if restoreSessionFrom(tmp, target, false) then -- 885
			local p = parseSession(loadText(target)) -- 886
			return { -- 887
				state = p.state, -- 887
				status = "ok", -- 887
				detail = "由 .tmp 恢复局中存档", -- 887
				recovered = true, -- 887
				backup = "" -- 887
			} -- 887
		end -- 887
		if restoreSessionFrom(prev, target, true) then -- 889
			local p = parseSession(loadText(target)) -- 890
			return { -- 891
				state = p.state, -- 891
				status = "ok", -- 891
				detail = "由 .prev 恢复局中存档", -- 891
				recovered = true, -- 891
				backup = "" -- 891
			} -- 891
		end -- 891
		return { -- 893
			state = nil, -- 893
			status = "missing", -- 893
			detail = "无局中存档", -- 893
			recovered = false, -- 893
			backup = "" -- 893
		} -- 893
	end -- 893
	local parsed = parseSession(loadText(target)) -- 895
	if parsed.ok and parsed.state ~= nil then -- 896
		if ops:exist(tmp) and sameContent(tmp, target) then -- 897
			ops:remove(tmp) -- 898
		end -- 898
		return { -- 900
			state = parsed.state, -- 900
			status = "ok", -- 900
			detail = "局中存档读取成功", -- 900
			recovered = false, -- 900
			backup = "" -- 900
		} -- 900
	end -- 900
	if parsed.status == "corrupt" then -- 902
		local broken = backupCorrupt(target, ".corrupt") -- 903
		if restoreSessionFrom(tmp, target, false) then -- 904
			local p = parseSession(loadText(target)) -- 905
			return { -- 906
				state = p.state, -- 906
				status = "ok", -- 906
				detail = "原局中存档损坏，已用 .tmp 恢复", -- 906
				recovered = true, -- 906
				backup = broken -- 906
			} -- 906
		end -- 906
		if restoreSessionFrom(prev, target, true) then -- 908
			local p = parseSession(loadText(target)) -- 909
			return { -- 910
				state = p.state, -- 910
				status = "ok", -- 910
				detail = "原局中存档损坏，已用 .prev 恢复", -- 910
				recovered = true, -- 910
				backup = broken -- 910
			} -- 910
		end -- 910
		return { -- 912
			state = nil, -- 912
			status = "corrupt", -- 912
			detail = parsed.reason, -- 912
			recovered = false, -- 912
			backup = broken -- 912
		} -- 912
	end -- 912
	local backup = backupCorrupt(target, ".unsupported") -- 914
	return { -- 915
		state = nil, -- 915
		status = "unsupported", -- 915
		detail = parsed.reason, -- 915
		recovered = false, -- 915
		backup = backup -- 915
	} -- 915
end -- 880
function ____exports.saveSession(state) -- 918
	local target = absPath(currentSessionFile) -- 919
	local dir = dirOf(target) -- 920
	if dir ~= "" and not ops:isdir(dir) then -- 921
		ops:mkdir(dir) -- 922
	end -- 922
	local tmp = target .. ".tmp" -- 924
	local prev = target .. ".prev" -- 925
	local text = formatSession(state) -- 926
	if not ops:save(tmp, text) then -- 927
		ops:remove(tmp) -- 928
		return false -- 929
	end -- 929
	local written = ops:load(tmp) -- 931
	if written == nil or normalize(written) ~= normalize(text) then -- 932
		ops:remove(tmp) -- 933
		return false -- 934
	end -- 934
	local existed = ops:exist(target) -- 936
	local backedUp = false -- 937
	if existed then -- 938
		if usableSessionBackup(target) then -- 939
			backedUp = ops:copy(target, prev) -- 940
			if not backedUp or not usableSessionBackup(prev) then -- 941
				ops:remove(tmp) -- 942
				return false -- 943
			end -- 943
		else -- 943
			backupCorrupt(target, ".corrupt") -- 946
		end -- 946
	end -- 946
	if not ops:copy(tmp, target) then -- 949
		if existed and backedUp and not sameContent(target, prev) then -- 950
			ops:copy(prev, target) -- 951
		end -- 951
		return false -- 953
	end -- 953
	local check = ops:load(target) -- 955
	if check == nil or normalize(check) ~= normalize(text) then -- 956
		if existed and backedUp and ops:copy(prev, target) and usableSessionBackup(target) then -- 957
			ops:remove(tmp) -- 958
		end -- 958
		return false -- 960
	end -- 960
	ops:remove(tmp) -- 962
	return true -- 963
end -- 918
function ____exports.clearSession() -- 966
	local target = absPath(currentSessionFile) -- 967
	local tmp = target .. ".tmp" -- 968
	local prev = target .. ".prev" -- 969
	local ok = true -- 970
	if ops:exist(target) then -- 971
		ok = ops:remove(target) and ok -- 972
	end -- 972
	if ops:exist(tmp) then -- 974
		ops:remove(tmp) -- 975
	end -- 975
	if ops:exist(prev) then -- 977
		ops:remove(prev) -- 978
	end -- 978
	return ok -- 980
end -- 966
return ____exports -- 966
