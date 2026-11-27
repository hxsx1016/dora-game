-- [ts]: run.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local ____exports = {} -- 1
____exports.MUSEUM_PHASES = { -- 40
	"locked", -- 40
	"well_open", -- 40
	"well_reflect", -- 40
	"hall_walk", -- 40
	"lamp_turn", -- 40
	"return_cabinet", -- 40
	"done" -- 40
} -- 40
function ____exports.isMuseumPhase(value) -- 42
	local i = 0 -- 43
	do -- 43
		i = 0 -- 44
		while i < #____exports.MUSEUM_PHASES do -- 44
			if ____exports.MUSEUM_PHASES[i + 1] == value then -- 45
				return true -- 46
			end -- 46
			i = i + 1 -- 44
		end -- 44
	end -- 44
	return false -- 49
end -- 42
function ____exports.createArchive() -- 61
	return { -- 62
		childCleared = false, -- 62
		soldierCleared = false, -- 62
		artifactOwned = false, -- 62
		museumPhase = "locked", -- 62
		museumSeen = false -- 62
	} -- 62
end -- 61
____exports.ALL_TALENTS = { -- 161
	"vitality", -- 162
	"guard", -- 163
	"stride", -- 164
	"focus", -- 165
	"push_force", -- 166
	"echo_wide", -- 167
	"lantern_pierce", -- 168
	"salvage" -- 169
} -- 169
____exports.TALENT_CATALOG = { -- 172
	vitality = { -- 173
		id = "vitality", -- 174
		title = "厚甲", -- 175
		branch = "body", -- 176
		branchZh = "护身", -- 177
		shortDesc = "体力上限+1并回复1点", -- 178
		detailDesc = "稳守肩背，体力上限增一并即刻回气", -- 179
		glyphEffect = "normal" -- 180
	}, -- 180
	guard = { -- 182
		id = "guard", -- 183
		title = "护身", -- 184
		branch = "body", -- 185
		branchZh = "护身", -- 186
		shortDesc = "受击保护+15拍，翻滚全向避近战", -- 187
		detailDesc = "延长受击硬直保护，翻滚可避背身盾击与破障", -- 188
		glyphEffect = "normal" -- 189
	}, -- 189
	stride = { -- 191
		id = "stride", -- 192
		title = "疾步", -- 193
		branch = "body", -- 194
		branchZh = "护身", -- 195
		shortDesc = "背负步速+10%，翻滚更疾", -- 196
		detailDesc = "背负穿巷步幅更稳，翻滚突围拉远身距", -- 197
		synergyWeapon = "echo_gun", -- 198
		synergyLabel = "与回声铳相合", -- 199
		glyphEffect = "normal" -- 200
	}, -- 200
	focus = { -- 202
		id = "focus", -- 203
		title = "凝神", -- 204
		branch = "wheel", -- 205
		branchZh = "枪机", -- 206
		shortDesc = "慢时换弹线盘+1秒", -- 207
		detailDesc = "慢时连线作答延宽60拍，从容绘出铃纹与灯纹", -- 208
		synergyWeapon = "guide_lantern_gun", -- 209
		synergyLabel = "与引路灯铳相合", -- 210
		glyphEffect = "light" -- 211
	}, -- 211
	push_force = { -- 213
		id = "push_force", -- 214
		title = "劲推", -- 215
		branch = "wheel", -- 216
		branchZh = "枪机", -- 217
		shortDesc = "推退破盾加伤并震退敌兵", -- 218
		detailDesc = "推退连线可重挫盾面并大幅震退，压缓周边举铳", -- 219
		glyphEffect = "knockback" -- 220
	}, -- 220
	echo_wide = { -- 222
		id = "echo_wide", -- 223
		title = "广音", -- 224
		branch = "wheel", -- 225
		branchZh = "枪机", -- 226
		shortDesc = "回声多惊一人并延缓开火", -- 227
		detailDesc = "铃纹连线额外惊动一处敌兵，显著推迟敌群开火", -- 228
		synergyWeapon = "echo_gun", -- 229
		synergyLabel = "与回声铳共鸣", -- 230
		glyphEffect = "echo" -- 231
	}, -- 231
	lantern_pierce = { -- 233
		id = "lantern_pierce", -- 234
		title = "明灯", -- 235
		branch = "craft", -- 236
		branchZh = "工巧", -- 237
		shortDesc = "灯纹必起光晕，镇敌范围加大", -- 238
		detailDesc = "灯纹命中即起余明光晕，镇住旁侧敌兵并扩宽照域", -- 239
		synergyWeapon = "guide_lantern_gun", -- 240
		synergyLabel = "与引路灯铳共鸣", -- 241
		glyphEffect = "light" -- 242
	}, -- 242
	salvage = { -- 244
		id = "salvage", -- 245
		title = "拾料", -- 246
		branch = "craft", -- 247
		branchZh = "工巧", -- 248
		shortDesc = "即得筹料+1，架盾与立楔加厚", -- 249
		detailDesc = "拾得木纹或铃纹筹一枚，架起残盾与临时木楔多承一击", -- 250
		glyphEffect = "knockback" -- 251
	} -- 251
} -- 251
____exports.talentNames = { -- 255
	vitality = "厚甲·体力+1", -- 256
	guard = "护身·硬直+15拍", -- 257
	stride = "疾步·背负提速", -- 258
	focus = "凝神·线盘+1秒", -- 259
	push_force = "劲推·破盾震退", -- 260
	echo_wide = "广音·回声多惊", -- 261
	lantern_pierce = "明灯·余明镇敌", -- 262
	salvage = "拾料·得筹加盾" -- 263
} -- 263
function ____exports.isTalent(value) -- 266
	local i = 0 -- 267
	do -- 267
		i = 0 -- 268
		while i < #____exports.ALL_TALENTS do -- 268
			if ____exports.ALL_TALENTS[i + 1] == value then -- 269
				return true -- 270
			end -- 270
			i = i + 1 -- 268
		end -- 268
	end -- 268
	return false -- 273
end -- 266
--- 向后兼容旧档中 4 项旧本领名：reload -> focus，craft -> salvage。
function ____exports.normalizeLegacyTalent(raw) -- 277
	if ____exports.isTalent(raw) then -- 278
		return raw -- 279
	end -- 279
	if raw == "reload" then -- 281
		return "focus" -- 282
	end -- 282
	if raw == "craft" then -- 284
		return "salvage" -- 285
	end -- 285
	return nil -- 287
end -- 277
function ____exports.createEmptyTalentRanks() -- 290
	return { -- 291
		vitality = 0, -- 292
		guard = 0, -- 293
		stride = 0, -- 294
		focus = 0, -- 295
		push_force = 0, -- 296
		echo_wide = 0, -- 297
		lantern_pierce = 0, -- 298
		salvage = 0 -- 299
	} -- 299
end -- 290
--- 按基础种子与轮回次序确定性派生新一轮种子（第 1 轮直用基础种子，死亡重开逐轮演变）。
function ____exports.deriveAttemptSeed(baseSeed, attempt) -- 304
	if attempt == nil then -- 304
		attempt = 1 -- 304
	end -- 304
	local s = 1 + math.floor(math.abs(baseSeed)) % 2147483646 -- 305
	local k = 1 -- 306
	do -- 306
		k = 1 -- 307
		while k < attempt do -- 307
			s = (s * 48271 + k * 7919) % 2147483647 -- 308
			if s <= 0 then -- 309
				s = 1 -- 310
			end -- 310
			k = k + 1 -- 307
		end -- 307
	end -- 307
	return s -- 313
end -- 304
--- 按种子、轮次与房间键确定性选取遭遇变体（0..variantCount-1）。
function ____exports.pickEscortVariant(seed, attempt, roomKey, variantCount) -- 317
	if variantCount == nil then -- 317
		variantCount = 3 -- 317
	end -- 317
	if variantCount <= 1 then -- 318
		return 0 -- 319
	end -- 319
	local h = ____exports.deriveAttemptSeed(seed, attempt) -- 321
	local i = 0 -- 322
	do -- 322
		i = 0 -- 323
		while i < #roomKey do -- 323
			h = (h * 33 + __TS__StringCharCodeAt(roomKey, i)) % 2147483647 -- 324
			i = i + 1 -- 323
		end -- 323
	end -- 323
	h = h * 48271 % 2147483647 -- 326
	return math.abs(h) % variantCount -- 327
end -- 317
function ____exports.createStoryTalents(seed, attempt) -- 343
	if seed == nil then -- 343
		seed = 20261124 -- 343
	end -- 343
	if attempt == nil then -- 343
		attempt = 1 -- 343
	end -- 343
	local safeAttempt = math.max( -- 344
		1, -- 344
		math.floor(attempt) -- 344
	) -- 344
	return { -- 345
		randomState = ____exports.deriveAttemptSeed(seed, safeAttempt), -- 346
		attempt = safeAttempt, -- 347
		ranks = ____exports.createEmptyTalentRanks(), -- 348
		offers = {}, -- 349
		room = "", -- 350
		variant = 0, -- 351
		deferred = false -- 352
	} -- 352
end -- 343
function ____exports.createStory(hp, maxHp, seed) -- 356
	if hp == nil then -- 356
		hp = 3 -- 356
	end -- 356
	if maxHp == nil then -- 356
		maxHp = 3 -- 356
	end -- 356
	if seed == nil then -- 356
		seed = 20261124 -- 356
	end -- 356
	return { -- 357
		route = "", -- 358
		hp = hp, -- 359
		maxHp = maxHp, -- 360
		hpAtGate = -1, -- 361
		maxHpAtGate = -1, -- 362
		settled = false, -- 363
		phase = "", -- 364
		countTick = 0, -- 365
		phaseTick = 0, -- 366
		handTicks = 0, -- 367
		handDone = false, -- 368
		lineSaid = false, -- 369
		tied = false, -- 370
		carry = false, -- 371
		museumReturn = false, -- 372
		escortDone = false, -- 373
		craftedWeapon = "", -- 374
		equippedWeapon = "", -- 375
		ending = "", -- 376
		cp = nil, -- 377
		segments = {}, -- 378
		talents = ____exports.createStoryTalents(seed, 1) -- 379
	} -- 379
end -- 356
function ____exports.draftTalentOffers(target, room, equippedWeapon) -- 383
	if equippedWeapon == nil then -- 386
		equippedWeapon = "standard_gun" -- 386
	end -- 386
	if target.room == room and not target.deferred then -- 388
		return -- 389
	end -- 389
	target.room = room -- 391
	target.deferred = false -- 392
	local pool = __TS__ArraySlice(____exports.ALL_TALENTS) -- 393
	target.offers = {} -- 394
	while #target.offers < 3 and #pool > 0 do -- 395
		local totalW = 0 -- 396
		local weights = {} -- 397
		local i = 0 -- 398
		do -- 398
			i = 0 -- 399
			while i < #pool do -- 399
				local t = pool[i + 1] -- 400
				local w = 10 -- 401
				if (equippedWeapon == "guide_lantern_gun" or equippedWeapon == "time_shuttler") and (t == "lantern_pierce" or t == "focus") then -- 402
					w = w + 10 -- 404
				elseif equippedWeapon == "echo_gun" and (t == "echo_wide" or t == "stride") then -- 405
					w = w + 10 -- 406
				end -- 406
				if (room == "escort1" or room == "escort2") and t == "salvage" then -- 408
					w = w + 4 -- 409
				end -- 409
				if (target.ranks[t] or 0) >= 2 then -- 411
					w = math.max(3, w - 4) -- 412
				end -- 412
				weights[#weights + 1] = w -- 414
				totalW = totalW + w -- 415
				i = i + 1 -- 399
			end -- 399
		end -- 399
		target.randomState = target.randomState * 48271 % 2147483647 -- 417
		local pick = target.randomState / 2147483647 * totalW -- 418
		local chosen = 0 -- 419
		do -- 419
			i = 0 -- 420
			while i < #weights do -- 420
				pick = pick - weights[i + 1] -- 421
				if pick <= 0 then -- 422
					chosen = i -- 423
					break -- 424
				end -- 424
				i = i + 1 -- 420
			end -- 420
		end -- 420
		local ____target_offers_0 = target.offers -- 427
		____target_offers_0[#____target_offers_0 + 1] = __TS__ArraySplice(pool, chosen, 1)[1] -- 427
	end -- 427
end -- 383
--- 开一局。`archive` 传入跨局档案（标题开局与片尾再玩都指向同一份），
-- 不传则新建一份（试炼、章节直达、调试与测试默认各局独立）。
function ____exports.createRun(seed, source, archive) -- 471
	if seed == nil then -- 471
		seed = 20261124 -- 471
	end -- 471
	if source == nil then -- 471
		source = "debug" -- 471
	end -- 471
	if archive == nil then -- 472
		archive = ____exports.createArchive() -- 472
	end -- 472
	return { -- 473
		source = source, -- 474
		seed = seed, -- 475
		ticks = 0, -- 476
		roomTicks = {}, -- 477
		roomEnterTick = 0, -- 478
		route = "", -- 479
		inventory = { -- 480
			shield = 0, -- 480
			wedge = 0, -- 480
			ammo = 0, -- 480
			pass = 0, -- 480
			quickbelt = 0, -- 480
			scrap = 0, -- 480
			wood = 0, -- 480
			bell = 0 -- 480
		}, -- 480
		props = {}, -- 481
		taken = {}, -- 482
		joined = false, -- 483
		c1Latch = false, -- 484
		c2Latch = false, -- 485
		checkpoint = 0, -- 486
		finished = false, -- 487
		story = ____exports.createStory(3, 3, seed), -- 488
		archive = archive, -- 489
		log = {} -- 490
	} -- 490
end -- 471
--- 60 拍 = 1 秒；给 HUD 与交付记录用。
function ____exports.seconds(ticks) -- 495
	return math.floor(ticks / 60 * 10 + 0.5) / 10 -- 496
end -- 495
function ____exports.mmss(ticks) -- 499
	local total = math.floor(ticks / 60) -- 500
	local m = math.floor(total / 60) -- 501
	local s = total % 60 -- 502
	return ((((m < 10 and "0" or "") .. tostring(m)) .. ":") .. (s < 10 and "0" or "")) .. tostring(s) -- 503
end -- 499
return ____exports -- 499
