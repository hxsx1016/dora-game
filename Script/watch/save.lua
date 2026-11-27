-- [ts]: save.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local copyForWrite, absPath, lineValue, intOf, formatSave, parseSave, normalize, sameContent, usableBackup, dirOf, ops, fault, currentFile, protectedPath -- 1
local ____Dora = require("Dora") -- 11
local Content = ____Dora.Content -- 11
local ____run = require("Script.watch.run") -- 12
local isMuseumPhase = ____run.isMuseumPhase -- 12
function copyForWrite(from, to) -- 78
	if fault == "replace" then -- 78
		return false -- 80
	end -- 80
	return ops:copy(from, to) -- 82
end -- 82
function absPath(path) -- 92
	if #path > 0 and string.sub(path, 1, 1) == "/" then -- 92
		return path -- 94
	end -- 94
	return (Content.writablePath .. "/") .. path -- 96
end -- 96
function ____exports.emptySave() -- 144
	return { -- 145
		childCleared = false, -- 146
		soldierCleared = false, -- 147
		artifactOwned = false, -- 148
		museumPhase = "locked", -- 149
		museumSeen = false -- 150
	} -- 150
end -- 144
function lineValue(text, key) -- 154
	local lines = __TS__StringSplit(text, "\n") -- 155
	local prefix = key .. "=" -- 156
	local i = 0 -- 157
	do -- 157
		i = 0 -- 158
		while i < #lines do -- 158
			local line = lines[i + 1] -- 159
			if #line >= #prefix and __TS__StringSubstring(line, 0, #prefix) == prefix then -- 159
				return __TS__StringSubstring(line, #prefix) -- 161
			end -- 161
			i = i + 1 -- 158
		end -- 158
	end -- 158
	return nil -- 164
end -- 164
function intOf(text, fallback) -- 167
	if #text == 0 then -- 167
		return fallback -- 169
	end -- 169
	local i = 0 -- 171
	local sign = 1 -- 172
	if string.sub(text, 1, 1) == "-" then -- 172
		sign = -1 -- 174
		i = 1 -- 175
	end -- 175
	local n = 0 -- 177
	local digits = 0 -- 178
	do -- 178
		while i < #text do -- 178
			local c = __TS__StringCharCodeAt(text, i) -- 180
			if c < 48 or c > 57 then -- 180
				return fallback -- 182
			end -- 182
			n = n * 10 + (c - 48) -- 184
			digits = digits + 1 -- 185
			i = i + 1 -- 179
		end -- 179
	end -- 179
	if digits == 0 then -- 179
		return fallback -- 188
	end -- 188
	return sign * n -- 190
end -- 190
function formatSave(state) -- 193
	return table.concat( -- 194
		{ -- 194
			"version=" .. tostring(____exports.SAVE_VERSION), -- 195
			"childCleared=" .. (state.childCleared and "true" or "false"), -- 196
			"soldierCleared=" .. (state.soldierCleared and "true" or "false"), -- 197
			"artifactOwned=" .. (state.artifactOwned and "true" or "false"), -- 198
			"museumPhase=" .. state.museumPhase, -- 199
			"museumSeen=" .. (state.museumSeen and "true" or "false"), -- 200
			"" -- 201
		}, -- 201
		"\n" -- 202
	) -- 202
end -- 202
function parseSave(text) -- 216
	local bad = { -- 217
		ok = false, -- 217
		status = "corrupt", -- 217
		reason = "", -- 217
		state = ____exports.emptySave() -- 217
	} -- 217
	if #text == 0 then -- 217
		bad.reason = "档案为空" -- 219
		return bad -- 220
	end -- 220
	local versionText = lineValue(text, "version") -- 222
	if versionText == nil then -- 222
		bad.reason = "缺少 version 行" -- 224
		return bad -- 225
	end -- 225
	local version = intOf(versionText, -1) -- 227
	if version < 0 then -- 227
		bad.reason = "version 不是十进制整数" -- 229
		return bad -- 230
	end -- 230
	if version > ____exports.SAVE_VERSION then -- 230
		return { -- 233
			ok = false, -- 233
			status = "unsupported", -- 233
			reason = (("版本 " .. tostring(version)) .. " 高于 ") .. tostring(____exports.SAVE_VERSION), -- 233
			state = ____exports.emptySave() -- 233
		} -- 233
	end -- 233
	if version ~= ____exports.SAVE_VERSION then -- 233
		bad.reason = "不支持的旧版本 " .. tostring(version) -- 236
		return bad -- 237
	end -- 237
	local boolKeys = {"childCleared", "soldierCleared", "artifactOwned", "museumSeen"} -- 239
	local bools = {} -- 240
	local i = 0 -- 241
	do -- 241
		i = 0 -- 242
		while i < #boolKeys do -- 242
			local value = lineValue(text, boolKeys[i + 1]) -- 243
			if value == nil then -- 243
				bad.reason = "缺少字段 " .. boolKeys[i + 1] -- 245
				return bad -- 246
			end -- 246
			if value ~= "true" and value ~= "false" then -- 246
				bad.reason = ("字段 " .. boolKeys[i + 1]) .. " 不是布尔值" -- 249
				return bad -- 250
			end -- 250
			bools[#bools + 1] = value == "true" -- 252
			i = i + 1 -- 242
		end -- 242
	end -- 242
	local phase = lineValue(text, "museumPhase") -- 254
	if phase == nil then -- 254
		bad.reason = "缺少字段 museumPhase" -- 256
		return bad -- 257
	end -- 257
	if not isMuseumPhase(phase) then -- 257
		bad.reason = "museumPhase 不在枚举内" -- 260
		return bad -- 261
	end -- 261
	return { -- 263
		ok = true, -- 264
		status = "ok", -- 265
		reason = "版本 " .. tostring(version), -- 266
		state = { -- 267
			childCleared = bools[1], -- 268
			soldierCleared = bools[2], -- 269
			artifactOwned = bools[3], -- 270
			museumPhase = phase, -- 271
			museumSeen = bools[4] -- 272
		} -- 272
	} -- 272
end -- 272
function normalize(text) -- 277
	return table.concat( -- 278
		__TS__StringSplit( -- 278
			table.concat( -- 278
				__TS__StringSplit(text, "\r\n"), -- 278
				"\n" -- 278
			), -- 278
			"\r" -- 278
		), -- 278
		"\n" -- 278
	) -- 278
end -- 278
function sameContent(a, b) -- 282
	local textA = ops:load(a) -- 283
	local textB = ops:load(b) -- 284
	if textA == nil or textB == nil then -- 284
		return false -- 286
	end -- 286
	return normalize(textA) == normalize(textB) -- 288
end -- 288
function usableBackup(path) -- 339
	if not ops:exist(path) then -- 339
		return false -- 341
	end -- 341
	local text = ops:load(path) -- 343
	return text ~= nil and parseSave(text).ok -- 344
end -- 344
function dirOf(path) -- 449
	local i = #path - 1 -- 450
	do -- 450
		while i >= 0 do -- 450
			if __TS__StringCharAt(path, i) == "/" then -- 450
				return __TS__StringSubstring(path, 0, i) -- 453
			end -- 453
			i = i - 1 -- 451
		end -- 451
	end -- 451
	return "" -- 456
end -- 456
--- 写入档案：写 `.tmp` → 校验 → 备份旧档到 `.prev`（校验成功才继续）→ 覆盖目标 → 回读校验。
-- 失败语义：
--   - 备份失败：不覆盖目标，清掉本次 `.tmp`（旧档完好），返回 false；
--   - 覆盖失败：尝试从 `.prev` 回滚；`.tmp` 保留为最新候选，返回 false；
--   - 校验失败：用 `.prev` 回滚；回滚失败则保留 `.tmp`，返回 false。
-- 未知版本原件（按路径保护）拒绝写入。
function ____exports.saveSave(state) -- 467
	local target = absPath(currentFile) -- 468
	if protectedPath == target then -- 468
		return false -- 470
	end -- 470
	local dir = dirOf(target) -- 472
	if dir ~= "" and not ops:isdir(dir) then -- 472
		ops:mkdir(dir) -- 474
	end -- 474
	local tmp = target .. ".tmp" -- 476
	local prev = target .. ".prev" -- 477
	local text = formatSave(state) -- 478
	if fault == "write" then -- 478
		return false -- 481
	end -- 481
	if not ops:save(tmp, text) then -- 481
		ops:remove(tmp) -- 484
		return false -- 485
	end -- 485
	local written = ops:load(tmp) -- 487
	if written == nil or normalize(written) ~= normalize(text) then -- 487
		ops:remove(tmp) -- 489
		return false -- 490
	end -- 490
	local existed = ops:exist(target) -- 493
	local backedUp = false -- 494
	if existed then -- 494
		backedUp = ops:copy(target, prev) -- 496
		if not backedUp or not usableBackup(prev) then -- 496
			ops:remove(tmp) -- 499
			return false -- 500
		end -- 500
	end -- 500
	if not copyForWrite(tmp, target) then -- 500
		if existed and backedUp and not sameContent(target, prev) then -- 500
			ops:copy(prev, target) -- 506
		end -- 506
		return false -- 509
	end -- 509
	local check = ops:load(target) -- 512
	if fault == "verify" or check == nil or normalize(check) ~= normalize(text) then -- 512
		if existed and backedUp and ops:copy(prev, target) and usableBackup(target) then -- 512
			ops:remove(tmp) -- 515
			return false -- 516
		end -- 516
		return false -- 519
	end -- 519
	ops:remove(tmp) -- 522
	return true -- 523
end -- 467
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
function ____exports.setSaveFile(path) -- 100
	currentFile = path == "" and ____exports.SAVE_FILE or path -- 101
end -- 100
--- 登记一份待落盘档案（同拍切房、写失败都由调用方重新登记）。
function ____exports.markProfilePending(state) -- 105
	pending = {state = state, file = currentFile} -- 106
end -- 105
function ____exports.profilePending() -- 109
	return pending ~= nil -- 110
end -- 109
--- 待落盘档案是否属于当前档案路径（切档后不应写错目标）。
function ____exports.pendingMatchesCurrent() -- 114
	return pending ~= nil and pending.file == currentFile -- 115
end -- 114
--- 把登记的档案落盘；成功才清登记，失败保留等下一帧重试。
-- 登记属于别的档案路径时不写、返回 false（调用方应显式丢弃或先切回）。
function ____exports.flushProfile() -- 122
	if pending == nil then -- 122
		return true -- 124
	end -- 124
	if pending.file ~= currentFile then -- 124
		return false -- 127
	end -- 127
	if not ____exports.saveSave(pending.state) then -- 127
		return false -- 130
	end -- 130
	pending = nil -- 132
	return true -- 133
end -- 122
function ____exports.clearProfilePending() -- 136
	pending = nil -- 137
end -- 136
function ____exports.getSaveFile() -- 140
	return currentFile -- 141
end -- 140
--- 按当前档案路径派生备份名：archive.txt.corrupt / .corrupt.2 …；找不到空位就返回空串（拒绝覆盖）。
local function backupPathFor(target, suffix) -- 292
	local candidate = target .. suffix -- 293
	if not ops:exist(candidate) then -- 293
		return candidate -- 295
	end -- 295
	local n = 2 -- 297
	while n <= 9999 do -- 297
		candidate = ((target .. suffix) .. ".") .. tostring(n) -- 299
		if not ops:exist(candidate) then -- 299
			return candidate -- 301
		end -- 301
		n = n + 1 -- 303
	end -- 303
	return "" -- 305
end -- 292
--- 把当前档案复制到派生的损坏/未知版本备份，返回备份路径（无原件/复制失败/内容不符则空串）。
-- 备份保留的是原件字节，可能是损坏档，所以不能用 `parseSave` 校验，只校验「复制成功且内容一致」。
local function backupCorrupt(target, suffix) -- 312
	if not ops:exist(target) then -- 312
		return "" -- 314
	end -- 314
	local backup = backupPathFor(target, suffix) -- 316
	if backup == "" then -- 316
		return "" -- 318
	end -- 318
	if not ops:copy(target, backup) then -- 318
		return "" -- 321
	end -- 321
	if not sameContent(target, backup) then -- 321
		return "" -- 324
	end -- 324
	return backup -- 326
end -- 312
--- 读文本；读不到按空串处理（解析会判 corrupt）。
local function loadText(path) -- 330
	local text = ops:load(path) -- 331
	if text == nil then -- 331
		return "" -- 333
	end -- 333
	return text -- 335
end -- 330
--- 用候选件恢复目标；成功（复制成功且回读解析一致）才清候选，失败保留候选并返回 false。
local function restoreFrom(candidate, target, keepCandidate) -- 348
	if not usableBackup(candidate) then -- 348
		return false -- 350
	end -- 350
	if not ops:copy(candidate, target) then -- 350
		return false -- 353
	end -- 353
	local again = parseSave(loadText(target)) -- 355
	if not again.ok then -- 355
		return false -- 357
	end -- 357
	if not keepCandidate then -- 357
		ops:remove(candidate) -- 360
	end -- 360
	return true -- 362
end -- 348
--- 读取档案。
-- 自愈顺序：
--   目标缺失 → 完整 `.tmp` → 完整 `.prev`；
--   目标损坏 → 完整 `.tmp`（最新候选）→ 完整 `.prev`。
-- 损坏/未知版本先派生备份；未知版本原件置保护位（按路径），普通写档拒绝覆盖。
function ____exports.loadSave() -- 372
	local target = absPath(currentFile) -- 373
	local tmp = target .. ".tmp" -- 374
	local prev = target .. ".prev" -- 375
	local recovered = false -- 376
	local recoveryDetail = "" -- 377
	if not ops:exist(target) then -- 377
		if restoreFrom(tmp, target, false) then -- 377
			recovered = true -- 381
			recoveryDetail = "目标缺失，已用完整 .tmp 恢复" -- 382
		elseif restoreFrom(prev, target, true) then -- 382
			recovered = true -- 384
			recoveryDetail = "目标缺失，已用完整 .prev 恢复" -- 385
		end -- 385
	end -- 385
	if not ops:exist(target) then -- 385
		return { -- 390
			state = ____exports.emptySave(), -- 391
			status = "missing", -- 391
			detail = "无档案，按新档起局" .. (recovered and ("（" .. recoveryDetail) .. "）" or ""), -- 392
			recovered = recovered, -- 393
			backup = "", -- 393
			action = "none" -- 393
		} -- 393
	end -- 393
	local text = ops:load(target) -- 397
	local parsed = parseSave(text == nil and "" or text) -- 398
	if parsed.ok then -- 398
		if ops:exist(tmp) and sameContent(tmp, target) then -- 398
			ops:remove(tmp) -- 402
		end -- 402
		return { -- 404
			state = parsed.state, -- 405
			status = "ok", -- 405
			detail = parsed.reason .. (recovered and ("（" .. recoveryDetail) .. "）" or ""), -- 406
			recovered = recovered, -- 407
			backup = "", -- 407
			action = "keep" -- 407
		} -- 407
	end -- 407
	if parsed.status == "corrupt" then -- 407
		local broken = backupCorrupt(target, ".corrupt") -- 412
		if restoreFrom(tmp, target, false) then -- 412
			return { -- 414
				state = parseSave(loadText(target)).state, -- 415
				status = "ok", -- 416
				detail = (("原档损坏（" .. parsed.reason) .. "），已用完整 .tmp 恢复，损坏件备份为 ") .. broken, -- 417
				recovered = true, -- 418
				backup = broken, -- 418
				action = "keep" -- 418
			} -- 418
		end -- 418
		if restoreFrom(prev, target, true) then -- 418
			return { -- 422
				state = parseSave(loadText(target)).state, -- 423
				status = "ok", -- 424
				detail = (("原档损坏（" .. parsed.reason) .. "），已用 .prev 恢复，损坏件备份为 ") .. broken, -- 425
				recovered = true, -- 426
				backup = broken, -- 426
				action = "keep" -- 426
			} -- 426
		end -- 426
		return { -- 430
			state = ____exports.emptySave(), -- 431
			status = "corrupt", -- 431
			detail = (("档案损坏（" .. parsed.reason) .. "），原件保留") .. (broken ~= "" and "，损坏件备份为 " .. broken or "，备份失败（原件未动）"), -- 432
			recovered = false, -- 434
			backup = broken, -- 434
			action = "reset" -- 434
		} -- 434
	end -- 434
	local backup = backupCorrupt(target, ".unsupported") -- 438
	protectedPath = target -- 439
	return { -- 440
		state = ____exports.emptySave(), -- 441
		status = "unsupported", -- 441
		detail = (("档案版本不支持（" .. parsed.reason) .. "），原件保留") .. (backup ~= "" and "：" .. backup or "，备份失败（原件未动）"), -- 442
		recovered = recovered, -- 444
		backup = backup, -- 444
		action = "reset" -- 444
	} -- 444
end -- 372
--- 恢复策略（给前端「档案损坏/版本不支持」页用）：把原件隔离到派生备份后删除。
-- 只有备份复制成功、内容与原件一致、且备份本身可解析时才删除目标。
function ____exports.resetSave() -- 530
	local target = absPath(currentFile) -- 531
	if not ops:exist(target) then -- 531
		return false -- 533
	end -- 533
	local backup = backupCorrupt(target, ".reset") -- 535
	if backup == "" then -- 535
		return false -- 537
	end -- 537
	if not sameContent(target, backup) then -- 537
		return false -- 541
	end -- 541
	if not ops:remove(target) then -- 541
		return false -- 544
	end -- 544
	if protectedPath == target then -- 544
		protectedPath = "" -- 547
	end -- 547
	return true -- 549
end -- 530
--- 档案内容签名：用于「正式通关是否变化」的幂等判断。
function ____exports.saveSignature(state) -- 553
	return table.concat({ -- 554
		state.childCleared and "1" or "0", -- 555
		state.soldierCleared and "1" or "0", -- 556
		state.artifactOwned and "1" or "0", -- 557
		state.museumPhase, -- 558
		state.museumSeen and "1" or "0" -- 559
	}, "|") -- 559
end -- 553
____exports.SESSION_VERSION = 1 -- 567
____exports.SESSION_FILE = "watch-save/session.txt" -- 568
local currentSessionFile = ____exports.SESSION_FILE -- 626
function ____exports.setSessionFile(path) -- 628
	currentSessionFile = path == "" and ____exports.SESSION_FILE or path -- 629
end -- 628
function ____exports.getSessionFile() -- 632
	return currentSessionFile -- 633
end -- 632
local function parseBoolField(raw, fallback) -- 636
	if raw == nil then -- 636
		return fallback -- 638
	end -- 638
	if raw == "true" or raw == "1" then -- 638
		return true -- 641
	end -- 641
	if raw == "false" or raw == "0" then -- 641
		return false -- 644
	end -- 644
	return nil -- 646
end -- 636
local function parseListField(raw) -- 649
	if raw == nil or raw == "" then -- 649
		return {} -- 651
	end -- 651
	local parts = __TS__StringSplit(raw, ",") -- 653
	local out = {} -- 654
	local i = 0 -- 655
	do -- 655
		i = 0 -- 656
		while i < #parts do -- 656
			local item = __TS__StringTrim(parts[i + 1]) -- 657
			if item ~= "" then -- 657
				out[#out + 1] = item -- 659
			end -- 659
			i = i + 1 -- 656
		end -- 656
	end -- 656
	return out -- 662
end -- 649
local function formatSession(s) -- 665
	return table.concat( -- 666
		{ -- 666
			"version=" .. tostring(____exports.SESSION_VERSION), -- 667
			"roomKey=" .. s.roomKey, -- 668
			"checkpoint=" .. tostring(math.floor(s.checkpoint + 0.5)), -- 669
			"seed=" .. tostring(math.floor(s.seed + 0.5)), -- 670
			"route=" .. s.route, -- 671
			"hp=" .. tostring(math.floor(s.hp + 0.5)), -- 672
			"maxHp=" .. tostring(math.floor(s.maxHp + 0.5)), -- 673
			"hpAtGate=" .. tostring(math.floor(s.hpAtGate + 0.5)), -- 674
			"maxHpAtGate=" .. tostring(math.floor(s.maxHpAtGate + 0.5)), -- 675
			"settled=" .. (s.settled and "true" or "false"), -- 676
			"phase=" .. s.phase, -- 677
			"countTick=" .. tostring(math.floor(s.countTick + 0.5)), -- 678
			"phaseTick=" .. tostring(math.floor(s.phaseTick + 0.5)), -- 679
			"handTicks=" .. tostring(math.floor(s.handTicks + 0.5)), -- 680
			"handDone=" .. (s.handDone and "true" or "false"), -- 681
			"lineSaid=" .. (s.lineSaid and "true" or "false"), -- 682
			"tied=" .. (s.tied and "true" or "false"), -- 683
			"carry=" .. (s.carry and "true" or "false"), -- 684
			"escortDone=" .. (s.escortDone and "true" or "false"), -- 685
			"craftedWeapon=" .. s.craftedWeapon, -- 686
			"equippedWeapon=" .. s.equippedWeapon, -- 687
			"wood=" .. tostring(math.floor(s.wood + 0.5)), -- 688
			"bell=" .. tostring(math.floor(s.bell + 0.5)), -- 689
			"scrap=" .. tostring(math.floor(s.scrap + 0.5)), -- 690
			"wedge=" .. tostring(math.floor(s.wedge + 0.5)), -- 691
			"ammo=" .. tostring(math.floor(s.ammo + 0.5)), -- 692
			"shield=" .. tostring(math.floor(s.shield + 0.5)), -- 693
			"pass=" .. tostring(math.floor(s.pass + 0.5)), -- 694
			"quickbelt=" .. tostring(math.floor(s.quickbelt + 0.5)), -- 695
			"taken=" .. table.concat(s.taken, ","), -- 696
			"segments=" .. table.concat(s.segments, ","), -- 697
			"cartAxle=" .. tostring(math.floor(s.cartAxle + 0.5)), -- 698
			"cartDocked=" .. (s.cartDocked and "true" or "false"), -- 699
			"campaignRoute=" .. (s.campaignRoute or ""), -- 700
			"joined=" .. (s.joined == true and "true" or "false"), -- 701
			"c1Latch=" .. (s.c1Latch == true and "true" or "false"), -- 702
			"c2Latch=" .. (s.c2Latch == true and "true" or "false"), -- 703
			"talentSeed=" .. tostring(math.floor((s.talentSeed or 0) + 0.5)), -- 704
			"talentRoom=" .. (s.talentRoom or ""), -- 705
			"talentOffers=" .. (s.talentOffers == nil and "" or table.concat(s.talentOffers, ",")), -- 706
			"talentVitality=" .. tostring(math.floor((s.talentVitality or 0) + 0.5)), -- 707
			"talentReload=" .. tostring(math.floor((s.talentReload or 0) + 0.5)), -- 708
			"talentGuard=" .. tostring(math.floor((s.talentGuard or 0) + 0.5)), -- 709
			"talentCraft=" .. tostring(math.floor((s.talentCraft or 0) + 0.5)), -- 710
			"" -- 711
		}, -- 711
		"\n" -- 712
	) -- 712
end -- 665
local function parseSession(text) -- 715
	if #text == 0 then -- 715
		return {ok = false, status = "corrupt", reason = "局中存档为空"} -- 717
	end -- 717
	local verRaw = lineValue(text, "version") -- 719
	if verRaw == nil then -- 719
		return {ok = false, status = "corrupt", reason = "缺少 version 行"} -- 721
	end -- 721
	local ver = intOf(verRaw, -1) -- 723
	if ver < 0 then -- 723
		return {ok = false, status = "corrupt", reason = "version 非法"} -- 725
	end -- 725
	if ver > ____exports.SESSION_VERSION then -- 725
		return { -- 728
			ok = false, -- 728
			status = "unsupported", -- 728
			reason = (("局中存档版本 " .. tostring(ver)) .. " 高于当前 ") .. tostring(____exports.SESSION_VERSION) -- 728
		} -- 728
	end -- 728
	local roomKey = lineValue(text, "roomKey") -- 730
	if roomKey == nil or roomKey == "" then -- 730
		return {ok = false, status = "corrupt", reason = "缺少 roomKey"} -- 732
	end -- 732
	local routeRaw = lineValue(text, "route") or "" -- 734
	if routeRaw ~= "" and routeRaw ~= "child" and routeRaw ~= "soldier" then -- 734
		return {ok = false, status = "corrupt", reason = "route 取值非法"} -- 736
	end -- 736
	local settled = parseBoolField( -- 738
		lineValue(text, "settled"), -- 738
		false -- 738
	) -- 738
	local handDone = parseBoolField( -- 739
		lineValue(text, "handDone"), -- 739
		false -- 739
	) -- 739
	local lineSaid = parseBoolField( -- 740
		lineValue(text, "lineSaid"), -- 740
		false -- 740
	) -- 740
	local tied = parseBoolField( -- 741
		lineValue(text, "tied"), -- 741
		false -- 741
	) -- 741
	local carry = parseBoolField( -- 742
		lineValue(text, "carry"), -- 742
		false -- 742
	) -- 742
	local escortDone = parseBoolField( -- 743
		lineValue(text, "escortDone"), -- 743
		false -- 743
	) -- 743
	local cartDocked = parseBoolField( -- 744
		lineValue(text, "cartDocked"), -- 744
		false -- 744
	) -- 744
	local joined = parseBoolField( -- 745
		lineValue(text, "joined"), -- 745
		false -- 745
	) -- 745
	local c1Latch = parseBoolField( -- 746
		lineValue(text, "c1Latch"), -- 746
		false -- 746
	) -- 746
	local c2Latch = parseBoolField( -- 747
		lineValue(text, "c2Latch"), -- 747
		false -- 747
	) -- 747
	if settled == nil or handDone == nil or lineSaid == nil or tied == nil or carry == nil or escortDone == nil or cartDocked == nil or joined == nil or c1Latch == nil or c2Latch == nil then -- 747
		return {ok = false, status = "corrupt", reason = "布尔字段非法"} -- 751
	end -- 751
	local campRouteRaw = lineValue(text, "campaignRoute") or "" -- 753
	if campRouteRaw ~= "" and campRouteRaw ~= "outer" and campRouteRaw ~= "drygoods" then -- 753
		return {ok = false, status = "corrupt", reason = "campaignRoute 取值非法"} -- 755
	end -- 755
	local hp = intOf( -- 757
		lineValue(text, "hp") or "3", -- 757
		-1 -- 757
	) -- 757
	local maxHp = intOf( -- 758
		lineValue(text, "maxHp") or "3", -- 758
		-1 -- 758
	) -- 758
	if hp < 0 or maxHp <= 0 then -- 758
		return {ok = false, status = "corrupt", reason = "血量字段非法"} -- 760
	end -- 760
	return { -- 762
		ok = true, -- 763
		status = "ok", -- 764
		reason = "ok", -- 765
		state = { -- 766
			roomKey = roomKey, -- 767
			checkpoint = intOf( -- 768
				lineValue(text, "checkpoint") or "0", -- 768
				0 -- 768
			), -- 768
			seed = intOf( -- 769
				lineValue(text, "seed") or "20261124", -- 769
				20261124 -- 769
			), -- 769
			route = routeRaw, -- 770
			hp = hp, -- 771
			maxHp = maxHp, -- 772
			hpAtGate = intOf( -- 773
				lineValue(text, "hpAtGate") or "-1", -- 773
				-1 -- 773
			), -- 773
			maxHpAtGate = intOf( -- 774
				lineValue(text, "maxHpAtGate") or "-1", -- 774
				-1 -- 774
			), -- 774
			settled = settled, -- 775
			phase = lineValue(text, "phase") or "", -- 776
			countTick = math.max( -- 777
				0, -- 777
				intOf( -- 777
					lineValue(text, "countTick") or "0", -- 777
					0 -- 777
				) -- 777
			), -- 777
			phaseTick = math.max( -- 778
				0, -- 778
				intOf( -- 778
					lineValue(text, "phaseTick") or "0", -- 778
					0 -- 778
				) -- 778
			), -- 778
			handTicks = math.max( -- 779
				0, -- 779
				intOf( -- 779
					lineValue(text, "handTicks") or "0", -- 779
					0 -- 779
				) -- 779
			), -- 779
			handDone = handDone, -- 780
			lineSaid = lineSaid, -- 781
			tied = tied, -- 782
			carry = carry, -- 783
			escortDone = escortDone, -- 784
			craftedWeapon = lineValue(text, "craftedWeapon") or "", -- 785
			equippedWeapon = lineValue(text, "equippedWeapon") or "", -- 786
			wood = math.max( -- 787
				0, -- 787
				intOf( -- 787
					lineValue(text, "wood") or "0", -- 787
					0 -- 787
				) -- 787
			), -- 787
			bell = math.max( -- 788
				0, -- 788
				intOf( -- 788
					lineValue(text, "bell") or "0", -- 788
					0 -- 788
				) -- 788
			), -- 788
			scrap = math.max( -- 789
				0, -- 789
				intOf( -- 789
					lineValue(text, "scrap") or "0", -- 789
					0 -- 789
				) -- 789
			), -- 789
			wedge = math.max( -- 790
				0, -- 790
				intOf( -- 790
					lineValue(text, "wedge") or "0", -- 790
					0 -- 790
				) -- 790
			), -- 790
			ammo = math.max( -- 791
				0, -- 791
				intOf( -- 791
					lineValue(text, "ammo") or "0", -- 791
					0 -- 791
				) -- 791
			), -- 791
			shield = math.max( -- 792
				0, -- 792
				intOf( -- 792
					lineValue(text, "shield") or "0", -- 792
					0 -- 792
				) -- 792
			), -- 792
			pass = math.max( -- 793
				0, -- 793
				intOf( -- 793
					lineValue(text, "pass") or "0", -- 793
					0 -- 793
				) -- 793
			), -- 793
			quickbelt = math.max( -- 794
				0, -- 794
				intOf( -- 794
					lineValue(text, "quickbelt") or "0", -- 794
					0 -- 794
				) -- 794
			), -- 794
			taken = parseListField(lineValue(text, "taken")), -- 795
			segments = parseListField(lineValue(text, "segments")), -- 796
			cartAxle = intOf( -- 797
				lineValue(text, "cartAxle") or "0", -- 797
				0 -- 797
			), -- 797
			cartDocked = cartDocked, -- 798
			campaignRoute = campRouteRaw, -- 799
			joined = joined, -- 800
			c1Latch = c1Latch, -- 801
			c2Latch = c2Latch, -- 802
			talentSeed = math.max( -- 803
				0, -- 803
				intOf( -- 803
					lineValue(text, "talentSeed") or "0", -- 803
					0 -- 803
				) -- 803
			), -- 803
			talentRoom = lineValue(text, "talentRoom") or "", -- 804
			talentOffers = parseListField(lineValue(text, "talentOffers")), -- 805
			talentVitality = math.max( -- 806
				0, -- 806
				intOf( -- 806
					lineValue(text, "talentVitality") or "0", -- 806
					0 -- 806
				) -- 806
			), -- 806
			talentReload = math.max( -- 807
				0, -- 807
				intOf( -- 807
					lineValue(text, "talentReload") or "0", -- 807
					0 -- 807
				) -- 807
			), -- 807
			talentGuard = math.max( -- 808
				0, -- 808
				intOf( -- 808
					lineValue(text, "talentGuard") or "0", -- 808
					0 -- 808
				) -- 808
			), -- 808
			talentCraft = math.max( -- 809
				0, -- 809
				intOf( -- 809
					lineValue(text, "talentCraft") or "0", -- 809
					0 -- 809
				) -- 809
			) -- 809
		} -- 809
	} -- 809
end -- 715
local function usableSessionBackup(path) -- 814
	if not ops:exist(path) then -- 814
		return false -- 816
	end -- 816
	return parseSession(loadText(path)).ok -- 818
end -- 814
local function restoreSessionFrom(candidate, target, keepCandidate) -- 821
	if not usableSessionBackup(candidate) then -- 821
		return false -- 823
	end -- 823
	if not ops:copy(candidate, target) then -- 823
		return false -- 826
	end -- 826
	if not sameContent(candidate, target) then -- 826
		return false -- 829
	end -- 829
	if not keepCandidate then -- 829
		ops:remove(candidate) -- 832
	end -- 832
	return true -- 834
end -- 821
function ____exports.hasSessionSave() -- 837
	local target = absPath(currentSessionFile) -- 838
	if usableSessionBackup(target) then -- 838
		return true -- 840
	end -- 840
	return usableSessionBackup(target .. ".tmp") or usableSessionBackup(target .. ".prev") -- 842
end -- 837
function ____exports.loadSession() -- 845
	local target = absPath(currentSessionFile) -- 846
	local tmp = target .. ".tmp" -- 847
	local prev = target .. ".prev" -- 848
	if not ops:exist(target) then -- 848
		if restoreSessionFrom(tmp, target, false) then -- 848
			local p = parseSession(loadText(target)) -- 851
			return { -- 852
				state = p.state, -- 852
				status = "ok", -- 852
				detail = "由 .tmp 恢复局中存档", -- 852
				recovered = true, -- 852
				backup = "" -- 852
			} -- 852
		end -- 852
		if restoreSessionFrom(prev, target, true) then -- 852
			local p = parseSession(loadText(target)) -- 855
			return { -- 856
				state = p.state, -- 856
				status = "ok", -- 856
				detail = "由 .prev 恢复局中存档", -- 856
				recovered = true, -- 856
				backup = "" -- 856
			} -- 856
		end -- 856
		return { -- 858
			state = nil, -- 858
			status = "missing", -- 858
			detail = "无局中存档", -- 858
			recovered = false, -- 858
			backup = "" -- 858
		} -- 858
	end -- 858
	local parsed = parseSession(loadText(target)) -- 860
	if parsed.ok and parsed.state ~= nil then -- 860
		if ops:exist(tmp) then -- 860
			ops:remove(tmp) -- 863
		end -- 863
		return { -- 865
			state = parsed.state, -- 865
			status = "ok", -- 865
			detail = "局中存档读取成功", -- 865
			recovered = false, -- 865
			backup = "" -- 865
		} -- 865
	end -- 865
	if parsed.status == "corrupt" then -- 865
		local broken = backupCorrupt(target, ".corrupt") -- 868
		if restoreSessionFrom(tmp, target, false) then -- 868
			local p = parseSession(loadText(target)) -- 870
			return { -- 871
				state = p.state, -- 871
				status = "ok", -- 871
				detail = "原局中存档损坏，已用 .tmp 恢复", -- 871
				recovered = true, -- 871
				backup = broken -- 871
			} -- 871
		end -- 871
		if restoreSessionFrom(prev, target, true) then -- 871
			local p = parseSession(loadText(target)) -- 874
			return { -- 875
				state = p.state, -- 875
				status = "ok", -- 875
				detail = "原局中存档损坏，已用 .prev 恢复", -- 875
				recovered = true, -- 875
				backup = broken -- 875
			} -- 875
		end -- 875
		return { -- 877
			state = nil, -- 877
			status = "corrupt", -- 877
			detail = parsed.reason, -- 877
			recovered = false, -- 877
			backup = broken -- 877
		} -- 877
	end -- 877
	local backup = backupCorrupt(target, ".unsupported") -- 879
	return { -- 880
		state = nil, -- 880
		status = "unsupported", -- 880
		detail = parsed.reason, -- 880
		recovered = false, -- 880
		backup = backup -- 880
	} -- 880
end -- 845
function ____exports.saveSession(state) -- 883
	local target = absPath(currentSessionFile) -- 884
	local dir = dirOf(target) -- 885
	if dir ~= "" and not ops:isdir(dir) then -- 885
		ops:mkdir(dir) -- 887
	end -- 887
	local tmp = target .. ".tmp" -- 889
	local prev = target .. ".prev" -- 890
	local text = formatSession(state) -- 891
	if not ops:save(tmp, text) then -- 891
		ops:remove(tmp) -- 893
		return false -- 894
	end -- 894
	local written = ops:load(tmp) -- 896
	if written == nil or normalize(written) ~= normalize(text) then -- 896
		ops:remove(tmp) -- 898
		return false -- 899
	end -- 899
	local existed = ops:exist(target) -- 901
	local backedUp = false -- 902
	if existed then -- 902
		backedUp = ops:copy(target, prev) -- 904
		if not backedUp or not usableSessionBackup(prev) then -- 904
			ops:remove(tmp) -- 906
			return false -- 907
		end -- 907
	end -- 907
	if not ops:copy(tmp, target) then -- 907
		if existed and backedUp and not sameContent(target, prev) then -- 907
			ops:copy(prev, target) -- 912
		end -- 912
		return false -- 914
	end -- 914
	local check = ops:load(target) -- 916
	if check == nil or normalize(check) ~= normalize(text) then -- 916
		if existed and backedUp and ops:copy(prev, target) and usableSessionBackup(target) then -- 916
			ops:remove(tmp) -- 919
		end -- 919
		return false -- 921
	end -- 921
	ops:remove(tmp) -- 923
	return true -- 924
end -- 883
function ____exports.clearSession() -- 927
	local target = absPath(currentSessionFile) -- 928
	local tmp = target .. ".tmp" -- 929
	local prev = target .. ".prev" -- 930
	local ok = true -- 931
	if ops:exist(target) then -- 931
		ok = ops:remove(target) and ok -- 933
	end -- 933
	if ops:exist(tmp) then -- 933
		ops:remove(tmp) -- 936
	end -- 936
	if ops:exist(prev) then -- 936
		ops:remove(prev) -- 939
	end -- 939
	return ok -- 941
end -- 927
return ____exports -- 927