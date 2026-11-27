-- [ts]: contract.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local cloneRecordNum -- 357
local ____play = require("Script.watch.play") -- 20
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 20
local gateCountAtTick = ____play.gateCountAtTick -- 20
function cloneRecordNum(src) -- 357
	local out = {} -- 358
	for k in pairs(src) do -- 359
		out[k] = src[k] -- 360
	end -- 360
	return out -- 362
end -- 362
local GATE_REUNION_HOLD_SECONDS = 0.6 -- 195
local DEFAULT_RELOAD_DURATION = 4 -- 196
local DEFAULT_SLOW_TIME_SCALE = 0.25 -- 197
local MAX_INTENT_LOG = 64 -- 198
local BASE_CRAFT_TICKS = 45 -- 199
local BASE_INVULN_HIT_TICKS = 42 -- 200
local ESCORT_STAGE_SPECS = { -- 202
	{key = "escort1", label = "巷路", isBench = false, isFinal = false}, -- 203
	{key = "escort2", label = "粮棚", isBench = false, isFinal = false}, -- 204
	{key = "escort3", label = "工台", isBench = true, isFinal = false}, -- 205
	{key = "escort4", label = "山道", isBench = false, isFinal = false}, -- 206
	{key = "escort5", label = "塔前", isBench = false, isFinal = true} -- 207
} -- 207
local CAMPAIGN_STAGE_SPECS = { -- 210
	{key = "s1-crossroad", label = "十字街", isBench = false, isFinal = false}, -- 211
	{key = "s2-drygoods", label = "布行", isBench = false, isFinal = false}, -- 212
	{key = "s3-archway", label = "牌楼", isBench = false, isFinal = false}, -- 213
	{key = "c1-yard", label = "候检院", isBench = false, isFinal = false}, -- 214
	{key = "c2-granary", label = "军粮棚", isBench = false, isFinal = true} -- 215
} -- 215
local function computeDerivedReloadTicks(ranks, supplies) -- 218
	local base = (supplies.quickbelt or 0) > 0 and 36 or 54 -- 219
	local rel = ranks.reload or 0 -- 220
	local crf = ranks.craft or 0 -- 221
	return math.max(6, base - 6 * rel - 3 * crf) -- 222
end -- 218
local function computeDerivedInvulnTicks(ranks) -- 225
	return BASE_INVULN_HIT_TICKS + 15 * (ranks.guard or 0) -- 226
end -- 225
local function computeDerivedCraftTicks(ranks) -- 229
	return math.max(6, BASE_CRAFT_TICKS - 6 * (ranks.craft or 0)) -- 230
end -- 229
local function buildStageNodes(specs, currentRoomKey, clearedMap) -- 233
	local curIdx = -1 -- 238
	local i = 0 -- 239
	do -- 239
		i = 0 -- 240
		while i < #specs do -- 240
			if specs[i + 1].key == currentRoomKey then -- 241
				curIdx = i -- 242
				break -- 243
			end -- 243
			i = i + 1 -- 240
		end -- 240
	end -- 240
	local out = {} -- 246
	do -- 246
		i = 0 -- 247
		while i < #specs do -- 247
			local sp = specs[i + 1] -- 248
			local byMap = clearedMap ~= nil and clearedMap[sp.key] == true -- 249
			local cleared = byMap or curIdx >= 0 and i < curIdx -- 250
			out[#out + 1] = { -- 251
				key = sp.key, -- 252
				label = sp.label, -- 253
				isBench = sp.isBench, -- 254
				isFinal = sp.isFinal, -- 255
				cleared = cleared, -- 256
				current = sp.key == currentRoomKey -- 257
			} -- 257
			i = i + 1 -- 247
		end -- 247
	end -- 247
	return out -- 260
end -- 233
local function createEmptyRoguelike() -- 263
	return { -- 264
		active = false, -- 265
		showRouteTrack = false, -- 266
		seed = 0, -- 267
		ticks = 0, -- 268
		routeTag = "", -- 269
		roomKey = "", -- 270
		offers = {}, -- 271
		ranks = { -- 272
			vitality = 0, -- 273
			guard = 0, -- 273
			stride = 0, -- 273
			focus = 0, -- 273
			push_force = 0, -- 274
			echo_wide = 0, -- 274
			lantern_pierce = 0, -- 274
			salvage = 0, -- 274
			reload = 0, -- 275
			craft = 0 -- 275
		}, -- 275
		totalRanks = 0, -- 277
		hp = 3, -- 278
		maxHp = 3, -- 279
		reloadTicksNow = 54, -- 280
		invulnTicksNow = BASE_INVULN_HIT_TICKS, -- 281
		craftTicksNow = BASE_CRAFT_TICKS, -- 282
		activeReloadTicks = 0, -- 283
		activeInvulnTicks = 0, -- 284
		activeCraftTicks = 0, -- 285
		equippedWeapon = "standard_gun", -- 286
		supplies = {}, -- 287
		stages = {}, -- 288
		talentLabelHints = {} -- 289
	} -- 289
end -- 263
local function cloneRoguelike(src) -- 293
	local stages = {} -- 294
	local i = 0 -- 295
	do -- 295
		i = 0 -- 296
		while i < #src.stages do -- 296
			local s = src.stages[i + 1] -- 297
			stages[#stages + 1] = { -- 298
				key = s.key, -- 299
				label = s.label, -- 300
				isBench = s.isBench, -- 301
				isFinal = s.isFinal, -- 302
				cleared = s.cleared, -- 303
				current = s.current -- 304
			} -- 304
			i = i + 1 -- 296
		end -- 296
	end -- 296
	local hints = {} -- 307
	for k in pairs(src.talentLabelHints) do -- 308
		hints[k] = src.talentLabelHints[k] -- 309
	end -- 309
	return { -- 311
		active = src.active, -- 312
		showRouteTrack = src.showRouteTrack, -- 313
		seed = src.seed, -- 314
		ticks = src.ticks, -- 315
		routeTag = src.routeTag, -- 316
		roomKey = src.roomKey, -- 317
		offers = __TS__ArraySlice(src.offers), -- 318
		ranks = cloneRecordNum(src.ranks), -- 319
		totalRanks = src.totalRanks, -- 320
		hp = src.hp, -- 321
		maxHp = src.maxHp, -- 322
		reloadTicksNow = src.reloadTicksNow, -- 323
		invulnTicksNow = src.invulnTicksNow, -- 324
		craftTicksNow = src.craftTicksNow, -- 325
		activeReloadTicks = src.activeReloadTicks, -- 326
		activeInvulnTicks = src.activeInvulnTicks, -- 327
		activeCraftTicks = src.activeCraftTicks, -- 328
		equippedWeapon = src.equippedWeapon, -- 329
		supplies = cloneRecordNum(src.supplies), -- 330
		stages = stages, -- 331
		talentLabelHints = hints -- 332
	} -- 332
end -- 293
local function defaultRecipes() -- 336
	return {{ -- 337
		id = "guide_lantern_gun", -- 339
		name = "引路灯铳", -- 340
		desc = "以两枚木纹筹改制，增强灯纹照亮范围与余明", -- 341
		enhancedEffect = "light", -- 342
		cost = {wood_tally = 2}, -- 343
		crafted = false -- 344
	}, { -- 346
		id = "echo_gun", -- 347
		name = "回声铳", -- 348
		desc = "以一枚木纹筹与一枚铃纹筹改制，增强铃纹回声诱导", -- 349
		enhancedEffect = "echo", -- 350
		cost = {wood_tally = 1, bell_tally = 1}, -- 351
		crafted = false -- 352
	}} -- 352
end -- 336
local function cloneRecipes(list) -- 365
	local out = {} -- 366
	local i = 0 -- 367
	do -- 367
		i = 0 -- 368
		while i < #list do -- 368
			local r = list[i + 1] -- 369
			out[#out + 1] = { -- 370
				id = r.id, -- 371
				name = r.name, -- 372
				desc = r.desc, -- 373
				enhancedEffect = r.enhancedEffect, -- 374
				cost = cloneRecordNum(r.cost), -- 375
				crafted = r.crafted -- 376
			} -- 376
			i = i + 1 -- 368
		end -- 368
	end -- 368
	return out -- 379
end -- 365
local function createEmptyGateReunion() -- 382
	return { -- 383
		active = false, -- 384
		knockHeard = false, -- 385
		holdProgress = 0, -- 386
		holding = false, -- 387
		completed = false, -- 388
		releasedAbortCount = 0 -- 389
	} -- 389
end -- 382
local function createEmptyBackCarry() -- 393
	return {active = false, handInHand = false, mounting = false, atBench = false} -- 394
end -- 393
local function createEmptyReloadSession() -- 402
	return { -- 403
		active = false, -- 404
		firstTime = true, -- 405
		elapsed = 0, -- 406
		duration = DEFAULT_RELOAD_DURATION, -- 407
		path = {}, -- 408
		previewEffect = "normal", -- 409
		nextEffect = "normal", -- 410
		invalidFlash = 0 -- 411
	} -- 411
end -- 402
local function createEmptyCraftBench() -- 415
	return { -- 416
		active = false, -- 417
		firstCraftDone = false, -- 418
		justCraftedTimer = 0, -- 419
		inventory = {}, -- 420
		recipes = defaultRecipes(), -- 421
		equippedWeapon = "standard_gun" -- 422
	} -- 422
end -- 415
local function createEmptyArchive() -- 426
	return { -- 427
		childCleared = false, -- 428
		soldierCleared = false, -- 429
		artifactOwned = false, -- 430
		museumPhase = "locked", -- 431
		museumSeen = false -- 432
	} -- 432
end -- 426
local function createInitialRehearsalState(tag) -- 436
	local bench = createEmptyCraftBench() -- 437
	bench.inventory = {wood_tally = 2, bell_tally = 1} -- 438
	return { -- 439
		tag = tag, -- 440
		storyRoute = "undecided", -- 441
		countTickOverride = nil, -- 442
		countDurationOverride = nil, -- 443
		timeScaleOverride = nil, -- 444
		gateReunion = createEmptyGateReunion(), -- 445
		gateHoldArmed = true, -- 446
		gatePrevInteractHeld = false, -- 447
		backCarry = createEmptyBackCarry(), -- 448
		reloadSession = createEmptyReloadSession(), -- 449
		craftBench = bench, -- 450
		archive = createEmptyArchive(), -- 451
		roguelike = createEmptyRoguelike(), -- 452
		handledCraftRequestIds = {} -- 453
	} -- 453
end -- 436
local function asRecord(value) -- 457
	if value ~= nil and type(value) == "table" then -- 458
		return value -- 459
	end -- 459
	return nil -- 461
end -- 457
local function readNum(rec, key) -- 464
	if rec == nil then -- 465
		return nil -- 466
	end -- 466
	local v = rec[key] -- 468
	return type(v) == "number" and v or nil -- 469
end -- 464
local function readBool(rec, key) -- 472
	if rec == nil then -- 473
		return nil -- 474
	end -- 474
	local v = rec[key] -- 476
	local ____temp_0 -- 477
	if type(v) == "boolean" then -- 477
		____temp_0 = v -- 477
	else -- 477
		____temp_0 = nil -- 477
	end -- 477
	return ____temp_0 -- 477
end -- 472
local function readStr(rec, key) -- 480
	if rec == nil then -- 481
		return nil -- 482
	end -- 482
	local v = rec[key] -- 484
	return type(v) == "string" and v or nil -- 485
end -- 480
local function readNumArray(rec, key) -- 488
	if rec == nil then -- 489
		return nil -- 490
	end -- 490
	local v = rec[key] -- 492
	if not __TS__ArrayIsArray(v) then -- 493
		return nil -- 494
	end -- 494
	local out = {} -- 496
	local i = 0 -- 497
	do -- 497
		i = 0 -- 498
		while i < #v do -- 498
			if type(v[i + 1]) == "number" then -- 499
				out[#out + 1] = v[i + 1] -- 500
			end -- 500
			i = i + 1 -- 498
		end -- 498
	end -- 498
	return out -- 503
end -- 488
local function readNumMap(rec, key) -- 506
	if rec == nil then -- 507
		return nil -- 508
	end -- 508
	local obj = asRecord(rec[key]) -- 510
	if obj == nil then -- 511
		return nil -- 512
	end -- 512
	local out = {} -- 514
	for k in pairs(obj) do -- 515
		local val = obj[k] -- 516
		if type(val) == "number" then -- 517
			out[k] = val -- 518
		end -- 518
	end -- 518
	return out -- 521
end -- 506
local function parseStoryRoute(v) -- 524
	if v == "child" or v == "soldier" then -- 525
		return v -- 526
	end -- 526
	return "undecided" -- 528
end -- 524
local function parseReloadEffect(v) -- 531
	if v == "push" or v == "knockback" then -- 532
		return "knockback" -- 533
	end -- 533
	if v == "echo" or v == "light" then -- 535
		return v -- 536
	end -- 536
	return "normal" -- 538
end -- 531
local function parseMuseumPhase(v) -- 541
	if v == "well_open" or v == "well_reflect" or v == "hall_walk" or v == "lamp_turn" or v == "return_cabinet" or v == "done" then -- 543
		return v -- 550
	end -- 550
	return "locked" -- 552
end -- 541
--- 根据 3×3 路径点集合推导效果（对齐后端 reload.ts 布局）：
-- - 0 = 左下起点，8 = 右上枪机复位终点；
-- - 4 = 中心铃纹（echo，优先），2 = 右下灯纹（light），其余有效路径 = 推退（knockback）。
local function deriveReloadEffectFromPath(path) -- 560
	if #path < 2 then -- 561
		return "normal" -- 562
	end -- 562
	local hasBell = false -- 564
	local hasLamp = false -- 565
	local i = 0 -- 566
	do -- 566
		i = 0 -- 567
		while i < #path do -- 567
			if path[i + 1] == 4 then -- 568
				hasBell = true -- 569
			elseif path[i + 1] == 2 then -- 570
				hasLamp = true -- 571
			end -- 571
			i = i + 1 -- 567
		end -- 567
	end -- 567
	if hasBell then -- 574
		return "echo" -- 575
	end -- 575
	if hasLamp then -- 577
		return "light" -- 578
	end -- 578
	return "knockback" -- 580
end -- 560
local function deriveVisualMode(roomKey, phase, storyRoute, museumPhase, countProgress, reunionCompleted) -- 583
	if roomKey == "museum" or museumPhase == "well_reflect" or museumPhase == "hall_walk" or museumPhase == "lamp_turn" or museumPhase == "return_cabinet" then -- 592
		return "museum" -- 598
	end -- 598
	if roomKey == "gate" then -- 600
		if phase == "gate-hand" then -- 601
			return "pixel" -- 602
		end -- 602
		if phase == "gate-wait" then -- 604
			return reunionCompleted and "pixel" or "lowpoly" -- 605
		end -- 605
		if phase == "gate-count" then -- 607
			if storyRoute == "soldier" and reunionCompleted then -- 608
				return "pixel" -- 609
			end -- 609
			if countProgress <= 0 then -- 611
				return "pixel" -- 612
			end -- 612
			if countProgress >= 1 then -- 614
				return "lowpoly" -- 615
			end -- 615
			return "transition" -- 617
		end -- 617
		if phase == "gate-walk" then -- 619
			return storyRoute == "soldier" and "pixel" or (storyRoute == "child" and "lowpoly" or "pixel") -- 620
		end -- 620
		return "pixel" -- 622
	end -- 622
	if roomKey == "gatepath" or roomKey == "escort1" or roomKey == "escort2" or roomKey == "escort3" or roomKey == "escort4" or roomKey == "escort5" then -- 624
		return "pixel" -- 626
	end -- 626
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" then -- 628
		if storyRoute == "child" then -- 629
			return "lowpoly" -- 630
		end -- 630
		return "pixel" -- 632
	end -- 632
	return "pixel" -- 634
end -- 583
____exports.DualRouteContract = __TS__Class() -- 637
local DualRouteContract = ____exports.DualRouteContract -- 637
DualRouteContract.name = "DualRouteContract" -- 637
function DualRouteContract.prototype.____constructor(self, canPickTalent) -- 652
	self.canPickTalent = canPickTalent -- 652
	self.source = "live" -- 638
	self.assistHintsEnabled = false -- 641
	self.livePendingCraftRequests = {} -- 643
	self.liveReleasedAbortCount = 0 -- 645
	self.liveReloadInvalidFlash = 0 -- 646
	self.liveFocusTimeScale = 1 -- 647
	self.liveArchiveCache = createEmptyArchive() -- 648
	self.intentLog = {} -- 649
end -- 652
function DualRouteContract.prototype.getDataSource(self) -- 655
	return self.source -- 656
end -- 655
function DualRouteContract.prototype.isRehearsal(self) -- 660
	return self.source == "rehearsal" and self.rehearsal ~= nil -- 661
end -- 660
function DualRouteContract.prototype.enterRehearsal(self, tag) -- 665
	if tag == nil then -- 665
		tag = "rehearsal" -- 665
	end -- 665
	self.source = "rehearsal" -- 666
	if self.rehearsal == nil then -- 667
		self.rehearsal = createInitialRehearsalState(tag) -- 668
	else -- 668
		self.rehearsal.tag = tag -- 670
	end -- 670
end -- 665
function DualRouteContract.prototype.exitRehearsal(self) -- 675
	self.source = "live" -- 676
	self.rehearsal = nil -- 677
	self.liveFocusTimeScale = 1 -- 678
end -- 675
function DualRouteContract.prototype.setFocusTimeScale(self, scale) -- 682
	self.liveFocusTimeScale = math.max( -- 683
		0.2, -- 683
		math.min(1, scale) -- 683
	) -- 683
end -- 682
function DualRouteContract.prototype.getFocusTimeScale(self) -- 686
	return self.liveFocusTimeScale -- 687
end -- 686
function DualRouteContract.prototype.ensureRehearsal(self, tag) -- 690
	if tag == nil then -- 690
		tag = "mock" -- 690
	end -- 690
	if self.source ~= "rehearsal" or self.rehearsal == nil then -- 691
		self:enterRehearsal(tag) -- 692
	end -- 692
	return self.rehearsal -- 694
end -- 690
function DualRouteContract.prototype.isAssistHintsEnabled(self) -- 697
	return self.assistHintsEnabled -- 698
end -- 697
function DualRouteContract.prototype.setAssistHintsEnabled(self, enabled) -- 701
	self.assistHintsEnabled = enabled -- 702
end -- 701
function DualRouteContract.prototype.toggleAssistHints(self) -- 705
	self.assistHintsEnabled = not self.assistHintsEnabled -- 706
	return self.assistHintsEnabled -- 707
end -- 705
function DualRouteContract.prototype.getLastSnapshot(self) -- 710
	return self.lastSnapshot -- 711
end -- 710
function DualRouteContract.prototype.peekSnapshot(self, p) -- 715
	local neutralInput = {interact = {held = false, pressed = false, released = false}} -- 716
	return self:sample(p, 0, neutralInput) -- 719
end -- 715
function DualRouteContract.prototype.getIntentLog(self) -- 722
	return self.intentLog -- 723
end -- 722
function DualRouteContract.prototype.clearIntentLog(self) -- 726
	self.intentLog = {} -- 727
end -- 726
function DualRouteContract.prototype.resetForRoom(self, p) -- 737
	self.livePendingCraftRequests = {} -- 738
	self.liveReleasedAbortCount = 0 -- 739
	self.liveReloadInvalidFlash = 0 -- 740
	self.liveFocusTimeScale = 1 -- 741
	self.liveArchiveCache = self:readLiveArchive(p) -- 742
	if self.rehearsal ~= nil then -- 743
		self.rehearsal.gateReunion = createEmptyGateReunion() -- 744
		self.rehearsal.gateHoldArmed = true -- 745
		self.rehearsal.gatePrevInteractHeld = false -- 746
		self.rehearsal.reloadSession = createEmptyReloadSession() -- 747
		self.rehearsal.craftBench.active = false -- 748
		self.rehearsal.craftBench.justCraftedTimer = 0 -- 749
		self.rehearsal.handledCraftRequestIds = {} -- 750
		self.rehearsal.timeScaleOverride = nil -- 751
	end -- 751
end -- 737
function DualRouteContract.prototype.sample(self, p, rawDt, input, events) -- 761
	local dt = p.paused and 0 or math.max(0, rawDt) -- 762
	local snap = self.source == "rehearsal" and self.rehearsal ~= nil and self:sampleRehearsal(p, dt, input, self.rehearsal) or self:sampleLive(p, dt, events) -- 763
	self.lastSnapshot = snap -- 766
	return snap -- 767
end -- 761
function DualRouteContract.prototype.submitIntent(self, p, intent) -- 775
	local allowed = intent.kind ~= "chooseTalent" or self.canPickTalent == nil or self.canPickTalent(p) -- 776
	local ____allowed_2 = allowed -- 777
	if ____allowed_2 then -- 777
		local ____temp_1 -- 777
		if self.source == "rehearsal" and self.rehearsal ~= nil then -- 777
			____temp_1 = self:applyRehearsalIntent(self.rehearsal, intent) -- 778
		else -- 778
			____temp_1 = self:forwardLiveIntent(p, intent) -- 779
		end -- 779
		____allowed_2 = ____temp_1 -- 777
	end -- 777
	local accepted = ____allowed_2 -- 777
	local ____self_intentLog_3 = self.intentLog -- 780
	____self_intentLog_3[#____self_intentLog_3 + 1] = {tick = p.ticks, source = self.source, intent = intent, accepted = accepted} -- 780
	if #self.intentLog > MAX_INTENT_LOG then -- 786
		table.remove(self.intentLog, 1) -- 787
	end -- 787
	return accepted -- 789
end -- 775
function DualRouteContract.prototype.setMockRoute(self, route) -- 794
	local st = self:ensureRehearsal("mock") -- 795
	st.storyRoute = route -- 796
end -- 794
function DualRouteContract.prototype.setMockCountTick(self, tick, duration) -- 799
	local st = self:ensureRehearsal("mock") -- 800
	st.countTickOverride = tick -- 801
	if duration ~= nil and duration > 0 then -- 802
		st.countDurationOverride = duration -- 803
	end -- 803
end -- 799
function DualRouteContract.prototype.setMockTimeScale(self, scale) -- 807
	local st = self:ensureRehearsal("mock") -- 808
	st.timeScaleOverride = scale -- 809
end -- 807
function DualRouteContract.prototype.setMockGateReunion(self, patch) -- 812
	local st = self:ensureRehearsal("mock") -- 813
	if patch.active ~= nil then -- 814
		st.gateReunion.active = patch.active -- 814
	end -- 814
	if patch.knockHeard ~= nil then -- 815
		st.gateReunion.knockHeard = patch.knockHeard -- 815
	end -- 815
	if patch.holdProgress ~= nil then -- 816
		st.gateReunion.holdProgress = math.max( -- 816
			0, -- 816
			math.min(1, patch.holdProgress) -- 816
		) -- 816
	end -- 816
	if patch.holding ~= nil then -- 817
		st.gateReunion.holding = patch.holding -- 817
	end -- 817
	if patch.completed ~= nil then -- 818
		st.gateReunion.completed = patch.completed -- 818
	end -- 818
	if patch.releasedAbortCount ~= nil then -- 819
		st.gateReunion.releasedAbortCount = patch.releasedAbortCount -- 819
	end -- 819
end -- 812
function DualRouteContract.prototype.setMockBackCarry(self, patch) -- 822
	local st = self:ensureRehearsal("mock") -- 823
	if patch.active ~= nil then -- 824
		st.backCarry.active = patch.active -- 824
	end -- 824
	if patch.handInHand ~= nil then -- 825
		st.backCarry.handInHand = patch.handInHand -- 825
	end -- 825
	if patch.mounting ~= nil then -- 826
		st.backCarry.mounting = patch.mounting -- 826
	end -- 826
	if patch.atBench ~= nil then -- 827
		st.backCarry.atBench = patch.atBench -- 827
	end -- 827
end -- 822
function DualRouteContract.prototype.triggerMockReload(self, active, options) -- 830
	local st = self:ensureRehearsal("mock") -- 834
	st.reloadSession.active = active -- 835
	if active then -- 836
		st.reloadSession.elapsed = 0 -- 837
		st.reloadSession.duration = options and options.duration or DEFAULT_RELOAD_DURATION -- 838
		st.reloadSession.path = {} -- 839
		st.reloadSession.previewEffect = "normal" -- 840
		st.reloadSession.invalidFlash = 0 -- 841
		if (options and options.firstTime) ~= nil then -- 842
			st.reloadSession.firstTime = options.firstTime -- 843
		end -- 843
		st.timeScaleOverride = options and options.slowTimeScale or DEFAULT_SLOW_TIME_SCALE -- 845
	else -- 845
		st.reloadSession.elapsed = 0 -- 847
		st.reloadSession.path = {} -- 848
		st.timeScaleOverride = nil -- 849
	end -- 849
end -- 830
function DualRouteContract.prototype.triggerMockBench(self, active, options) -- 853
	local st = self:ensureRehearsal("mock") -- 857
	st.craftBench.active = active -- 858
	st.backCarry.atBench = active -- 859
	if (options and options.inventory) ~= nil then -- 860
		st.craftBench.inventory = cloneRecordNum(options.inventory) -- 861
	end -- 861
	if (options and options.equippedWeapon) ~= nil then -- 863
		st.craftBench.equippedWeapon = options.equippedWeapon -- 864
	end -- 864
end -- 853
function DualRouteContract.prototype.setMockArchive(self, childCleared, soldierCleared, artifactOwned) -- 868
	local st = self:ensureRehearsal("mock") -- 869
	st.archive.childCleared = childCleared -- 870
	st.archive.soldierCleared = soldierCleared -- 871
	if artifactOwned ~= nil then -- 872
		st.archive.artifactOwned = artifactOwned -- 873
	end -- 873
	if childCleared and soldierCleared and st.archive.museumPhase == "locked" then -- 875
		st.archive.museumPhase = "well_open" -- 876
	elseif (not childCleared or not soldierCleared) and st.archive.museumPhase == "well_open" then -- 877
		st.archive.museumPhase = "locked" -- 878
	end -- 878
end -- 868
function DualRouteContract.prototype.enterMockMuseum(self, phase) -- 882
	local st = self:ensureRehearsal("mock") -- 883
	st.archive.museumPhase = phase -- 884
	if phase == "done" then -- 885
		st.archive.museumSeen = true -- 886
	end -- 886
	if phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" or phase == "done" then -- 889
		st.archive.artifactOwned = true -- 895
	end -- 895
end -- 882
function DualRouteContract.prototype.setMockRoguelike(self, patch) -- 899
	local st = self:ensureRehearsal("mock") -- 900
	local rg = st.roguelike -- 901
	local ____patch_active_14 = patch.active -- 902
	if ____patch_active_14 == nil then -- 902
		____patch_active_14 = true -- 902
	end -- 902
	rg.active = ____patch_active_14 -- 902
	if patch.showRouteTrack ~= nil then -- 903
		rg.showRouteTrack = patch.showRouteTrack -- 903
	end -- 903
	if patch.seed ~= nil then -- 904
		rg.seed = patch.seed -- 904
	end -- 904
	if patch.ticks ~= nil then -- 905
		rg.ticks = patch.ticks -- 905
	end -- 905
	if patch.routeTag ~= nil then -- 906
		rg.routeTag = patch.routeTag -- 906
	end -- 906
	if patch.roomKey ~= nil then -- 907
		rg.roomKey = patch.roomKey -- 907
	end -- 907
	if patch.clearOffers == true then -- 908
		rg.offers = {} -- 909
	elseif patch.offers ~= nil then -- 910
		rg.offers = __TS__ArraySlice(patch.offers) -- 911
	end -- 911
	if patch.ranks ~= nil then -- 913
		rg.ranks = cloneRecordNum(patch.ranks) -- 914
	end -- 914
	if patch.supplies ~= nil then -- 916
		rg.supplies = cloneRecordNum(patch.supplies) -- 917
	end -- 917
	if patch.hp ~= nil then -- 919
		rg.hp = patch.hp -- 919
	end -- 919
	if patch.maxHp ~= nil then -- 920
		rg.maxHp = patch.maxHp -- 920
	end -- 920
	if patch.equippedWeapon ~= nil then -- 921
		rg.equippedWeapon = patch.equippedWeapon -- 921
	end -- 921
	if patch.activeReloadTicks ~= nil then -- 922
		rg.activeReloadTicks = patch.activeReloadTicks -- 922
	end -- 922
	if patch.activeInvulnTicks ~= nil then -- 923
		rg.activeInvulnTicks = patch.activeInvulnTicks -- 923
	end -- 923
	if patch.activeCraftTicks ~= nil then -- 924
		rg.activeCraftTicks = patch.activeCraftTicks -- 924
	end -- 924
	if patch.stages ~= nil then -- 925
		rg.stages = __TS__ArrayMap( -- 926
			patch.stages, -- 926
			function(____, s) return __TS__ObjectAssign({}, s) end -- 926
		) -- 926
	elseif #rg.stages == 0 then -- 927
		rg.stages = buildStageNodes(ESCORT_STAGE_SPECS, rg.roomKey ~= "" and rg.roomKey or "escort1") -- 928
	end -- 928
	if patch.talentLabelHints ~= nil then -- 930
		rg.talentLabelHints = {} -- 931
		for k in pairs(patch.talentLabelHints) do -- 932
			rg.talentLabelHints[k] = patch.talentLabelHints[k] -- 933
		end -- 933
	end -- 933
	local sum = 0 -- 936
	for k in pairs(rg.ranks) do -- 937
		sum = sum + (rg.ranks[k] or 0) -- 938
	end -- 938
	rg.totalRanks = patch.totalRanks or sum -- 940
	rg.reloadTicksNow = patch.reloadTicksNow or computeDerivedReloadTicks(rg.ranks, rg.supplies) -- 941
	rg.invulnTicksNow = patch.invulnTicksNow or computeDerivedInvulnTicks(rg.ranks) -- 942
	rg.craftTicksNow = patch.craftTicksNow or computeDerivedCraftTicks(rg.ranks) -- 943
end -- 899
function DualRouteContract.prototype.sampleLive(self, p, dt, events) -- 948
	local pRec = asRecord(p) -- 949
	local runRec = asRecord(p.run) -- 950
	local ____asRecord_16 = asRecord -- 951
	local ____temp_15 -- 951
	if runRec ~= nil then -- 951
		____temp_15 = runRec.story -- 951
	else -- 951
		____temp_15 = nil -- 951
	end -- 951
	local storyRec = ____asRecord_16(____temp_15) -- 951
	if dt > 0 and self.liveReloadInvalidFlash > 0 then -- 953
		self.liveReloadInvalidFlash = math.max(0, self.liveReloadInvalidFlash - dt) -- 954
	end -- 954
	if events ~= nil and #events.rawEvents > 0 then -- 956
		local ei = 0 -- 957
		do -- 957
			ei = 0 -- 958
			while ei < #events.rawEvents do -- 958
				local ename = events.rawEvents[ei + 1].name -- 959
				if ename == "handRelease" then -- 960
					self.liveReleasedAbortCount = self.liveReleasedAbortCount + 1 -- 961
				elseif ename == "reloadInvalid" then -- 962
					self.liveReloadInvalidFlash = 0.35 -- 963
				end -- 963
				ei = ei + 1 -- 958
			end -- 958
		end -- 958
	end -- 958
	local ____temp_19 -- 969
	if pRec ~= nil and type(pRec.storyRoute) == "string" and pRec.storyRoute ~= "" then -- 969
		____temp_19 = pRec.storyRoute -- 970
	else -- 970
		local ____temp_18 -- 971
		if storyRec ~= nil and type(storyRec.route) == "string" and storyRec.route ~= "" then -- 971
			____temp_18 = storyRec.route -- 972
		else -- 972
			local ____temp_17 -- 973
			if runRec ~= nil then -- 973
				____temp_17 = runRec.storyRoute -- 973
			else -- 973
				____temp_17 = nil -- 973
			end -- 973
			____temp_18 = ____temp_17 -- 973
		end -- 973
		____temp_19 = ____temp_18 -- 971
	end -- 971
	local rawRoute = ____temp_19 -- 969
	local storyRoute = parseStoryRoute(rawRoute) -- 974
	local countElapsedTicks = readNum(pRec, "countElapsedTicks") or p.countTick -- 977
	local countDurationTicks = math.max( -- 978
		1, -- 978
		readNum(pRec, "countDurationTicks") or GATE_COUNT_END -- 978
	) -- 978
	local countNumber = gateCountAtTick(countElapsedTicks) -- 979
	local countProgress = math.max( -- 980
		0, -- 980
		math.min(1, countElapsedTicks / countDurationTicks) -- 980
	) -- 980
	local ____asRecord_21 = asRecord -- 983
	local ____temp_20 -- 983
	if pRec ~= nil then -- 983
		____temp_20 = pRec.gateReunion -- 983
	else -- 983
		____temp_20 = nil -- 983
	end -- 983
	local grRec = ____asRecord_21(____temp_20) -- 983
	local flatHold = readNum(pRec, "gateHoldProgress") -- 984
	local inGateWaitOrHand = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand") -- 985
	local handTicks = readNum(pRec, "handTicks") or 0 -- 986
	local handNeedTicks = math.max( -- 987
		1, -- 987
		readNum(pRec, "handNeedTicks") or 36 -- 987
	) -- 987
	local handTied = p.room.key == "gate" and p.phase == "gate-hand" -- 988
	local derivedHoldProg = handTied and 1 or (inGateWaitOrHand and math.max( -- 989
		0, -- 989
		math.min(1, handTicks / handNeedTicks) -- 989
	) or 0) -- 989
	local ____readBool_result_22 = readBool(grRec, "active") -- 991
	if ____readBool_result_22 == nil then -- 991
		____readBool_result_22 = inGateWaitOrHand -- 991
	end -- 991
	local ____readBool_result_23 = readBool(grRec, "knockHeard") -- 992
	if ____readBool_result_23 == nil then -- 992
		____readBool_result_23 = inGateWaitOrHand and p.knocks >= 1 -- 992
	end -- 992
	local ____math_max_result_26 = math.max( -- 993
		0, -- 993
		math.min( -- 993
			1, -- 993
			readNum(grRec, "holdProgress") or flatHold or derivedHoldProg -- 993
		) -- 993
	) -- 993
	local ____readBool_result_24 = readBool(grRec, "holding") -- 994
	if ____readBool_result_24 == nil then -- 994
		____readBool_result_24 = inGateWaitOrHand and not handTied and handTicks > 0 -- 994
	end -- 994
	local ____readBool_result_25 = readBool(grRec, "completed") -- 995
	if ____readBool_result_25 == nil then -- 995
		____readBool_result_25 = handTied -- 995
	end -- 995
	local gateReunion = { -- 990
		active = ____readBool_result_22, -- 991
		knockHeard = ____readBool_result_23, -- 992
		holdProgress = ____math_max_result_26, -- 993
		holding = ____readBool_result_24, -- 994
		completed = ____readBool_result_25, -- 995
		releasedAbortCount = readNum(grRec, "releasedAbortCount") or self.liveReleasedAbortCount -- 996
	} -- 996
	local ____asRecord_28 = asRecord -- 1000
	local ____temp_27 -- 1000
	if pRec ~= nil then -- 1000
		____temp_27 = pRec.backCarry -- 1000
	else -- 1000
		____temp_27 = nil -- 1000
	end -- 1000
	local bcRec = ____asRecord_28(____temp_27) -- 1000
	local ____asRecord_30 = asRecord -- 1001
	local ____temp_29 -- 1001
	if pRec ~= nil then -- 1001
		____temp_29 = pRec.craftBench -- 1001
	else -- 1001
		____temp_29 = nil -- 1001
	end -- 1001
	local cbRecEarly = ____asRecord_30(____temp_29) -- 1001
	local ____readBool_result_31 = readBool(cbRecEarly, "active") -- 1002
	if ____readBool_result_31 == nil then -- 1002
		____readBool_result_31 = false -- 1002
	end -- 1002
	local benchActiveLive = ____readBool_result_31 -- 1002
	local ____readBool_result_32 = readBool(pRec, "carryOn") -- 1003
	if ____readBool_result_32 == nil then -- 1003
		____readBool_result_32 = readBool(storyRec, "carry") -- 1003
	end -- 1003
	local ____readBool_result_32_33 = ____readBool_result_32 -- 1003
	if ____readBool_result_32_33 == nil then -- 1003
		____readBool_result_32_33 = false -- 1003
	end -- 1003
	local carryOn = ____readBool_result_32_33 -- 1003
	local handInHandLive = handTied or p.room.key == "gatepath" and not carryOn -- 1004
	local ____readBool_result_34 = readBool(bcRec, "active") -- 1006
	if ____readBool_result_34 == nil then -- 1006
		____readBool_result_34 = carryOn -- 1006
	end -- 1006
	local ____readBool_result_35 = readBool(bcRec, "handInHand") -- 1007
	if ____readBool_result_35 == nil then -- 1007
		____readBool_result_35 = handInHandLive -- 1007
	end -- 1007
	local ____readBool_result_36 = readBool(bcRec, "mounting") -- 1008
	if ____readBool_result_36 == nil then -- 1008
		____readBool_result_36 = p.room.key == "gatepath" and carryOn -- 1008
	end -- 1008
	local ____readBool_result_37 = readBool(bcRec, "atBench") -- 1009
	if ____readBool_result_37 == nil then -- 1009
		____readBool_result_37 = benchActiveLive -- 1009
	end -- 1009
	local backCarry = {active = ____readBool_result_34, handInHand = ____readBool_result_35, mounting = ____readBool_result_36, atBench = ____readBool_result_37} -- 1005
	local ____asRecord_39 = asRecord -- 1013
	local ____temp_38 -- 1013
	if pRec ~= nil then -- 1013
		____temp_38 = pRec.reloadSession -- 1013
	else -- 1013
		____temp_38 = nil -- 1013
	end -- 1013
	local rsRec = ____asRecord_39(____temp_38) -- 1013
	local ____readBool_result_40 = readBool(pRec, "reloadOpen") -- 1014
	if ____readBool_result_40 == nil then -- 1014
		____readBool_result_40 = false -- 1014
	end -- 1014
	local reloadOpenLive = ____readBool_result_40 -- 1014
	local ____readBool_result_41 = readBool(rsRec, "active") -- 1015
	if ____readBool_result_41 == nil then -- 1015
		____readBool_result_41 = reloadOpenLive -- 1015
	end -- 1015
	local reloadActive = ____readBool_result_41 -- 1015
	local reloadAnswerTicks = readNum(pRec, "reloadAnswerTicks") or 0 -- 1016
	local reloadTryCount = readNum(pRec, "reloadTryCount") or 0 -- 1017
	local livePath = readNumArray(rsRec, "path") or readNumArray(pRec, "reloadPath") or ({}) -- 1018
	local ____temp_44 -- 1019
	if rsRec ~= nil and rsRec.nextEffect ~= nil then -- 1019
		____temp_44 = rsRec.nextEffect -- 1020
	else -- 1020
		local ____temp_43 -- 1021
		if pRec ~= nil and pRec.reloadPendingEffect ~= nil then -- 1021
			____temp_43 = pRec.reloadPendingEffect -- 1022
		else -- 1022
			local ____temp_42 -- 1023
			if pRec ~= nil then -- 1023
				____temp_42 = pRec.nextEffect -- 1023
			else -- 1023
				____temp_42 = nil -- 1023
			end -- 1023
			____temp_43 = ____temp_42 -- 1023
		end -- 1023
		____temp_44 = ____temp_43 -- 1021
	end -- 1021
	local liveNextRaw = ____temp_44 -- 1019
	local livePreview = rsRec ~= nil and rsRec.previewEffect ~= nil and parseReloadEffect(rsRec.previewEffect) or (reloadActive and deriveReloadEffectFromPath(livePath) or "normal") -- 1024
	local ____temp_45 -- 1028
	if pRec ~= nil then -- 1028
		____temp_45 = pRec.reloadNeedTicks -- 1028
	else -- 1028
		____temp_45 = nil -- 1028
	end -- 1028
	local needTicksFn = ____temp_45 -- 1028
	local liveReloadDuration = type(needTicksFn) == "function" and math.max( -- 1029
		0.5, -- 1030
		needTicksFn(p) / 60 -- 1030
	) or DEFAULT_RELOAD_DURATION -- 1031
	local ____readBool_result_46 = readBool(rsRec, "firstTime") -- 1034
	if ____readBool_result_46 == nil then -- 1034
		____readBool_result_46 = reloadTryCount <= 1 -- 1034
	end -- 1034
	local reloadSession = { -- 1032
		active = reloadActive, -- 1033
		firstTime = ____readBool_result_46, -- 1034
		elapsed = readNum(rsRec, "elapsed") or reloadAnswerTicks / 60, -- 1035
		duration = math.max( -- 1036
			0.01, -- 1036
			readNum(rsRec, "duration") or liveReloadDuration -- 1036
		), -- 1036
		path = livePath, -- 1037
		previewEffect = livePreview, -- 1038
		nextEffect = parseReloadEffect(liveNextRaw), -- 1039
		invalidFlash = readNum(rsRec, "invalidFlash") or self.liveReloadInvalidFlash -- 1040
	} -- 1040
	local rawScale = readNum(pRec, "timeScale") or readNum(runRec, "timeScale") -- 1043
	local baseScale = rawScale ~= nil and rawScale >= 0 and rawScale or (reloadActive and DEFAULT_SLOW_TIME_SCALE or 1) -- 1044
	local timeScale = math.min(baseScale, self.liveFocusTimeScale) -- 1047
	local ____asRecord_48 = asRecord -- 1050
	local ____temp_47 -- 1050
	if pRec ~= nil then -- 1050
		____temp_47 = pRec.craftBench -- 1050
	else -- 1050
		____temp_47 = nil -- 1050
	end -- 1050
	local cbRec = ____asRecord_48(____temp_47) -- 1050
	local craftBench = self:readLiveCraftBench(cbRec, pRec, runRec) -- 1051
	local archive = self:readLiveArchive(p) -- 1054
	self.liveArchiveCache = archive -- 1055
	local roguelike = self:readLiveRoguelike(p, pRec, runRec, storyRec) -- 1058
	local visualMode = deriveVisualMode( -- 1060
		p.room.key, -- 1061
		p.phase, -- 1062
		storyRoute, -- 1063
		"locked", -- 1064
		countProgress, -- 1065
		gateReunion.completed -- 1066
	) -- 1066
	return { -- 1069
		storyRoute = storyRoute, -- 1070
		countElapsedTicks = countElapsedTicks, -- 1071
		countDurationTicks = countDurationTicks, -- 1072
		countNumber = countNumber, -- 1073
		countProgress = countProgress, -- 1074
		gateReunion = gateReunion, -- 1075
		backCarry = backCarry, -- 1076
		timeScale = timeScale, -- 1077
		reloadSession = reloadSession, -- 1078
		craftBench = craftBench, -- 1079
		archive = archive, -- 1080
		roguelike = roguelike, -- 1081
		assistHintsEnabled = self.assistHintsEnabled, -- 1082
		visualMode = visualMode, -- 1083
		dataSource = "live", -- 1084
		isRehearsal = false, -- 1085
		rehearsalTag = "" -- 1086
	} -- 1086
end -- 948
function DualRouteContract.prototype.readLiveRoguelike(self, p, pRec, runRec, storyRec) -- 1090
	local roomKey = p.room.key -- 1096
	local isEscort = (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 -- 1097
	local ____opt_49 = p.room.campaign -- 1098
	local campChapter = ____opt_49 and ____opt_49.chapter -- 1098
	local isCampaignRun = p.isCampaign and (campChapter == "S" or campChapter == "C") -- 1099
	local rawOffers = p:getStoryTalentOffers() -- 1101
	local offers = {} -- 1102
	local i = 0 -- 1103
	do -- 1103
		i = 0 -- 1104
		while i < #rawOffers do -- 1104
			offers[#offers + 1] = rawOffers[i + 1] -- 1105
			i = i + 1 -- 1104
		end -- 1104
	end -- 1104
	local ranks = { -- 1108
		vitality = 0, -- 1109
		guard = 0, -- 1109
		stride = 0, -- 1109
		focus = 0, -- 1109
		push_force = 0, -- 1110
		echo_wide = 0, -- 1110
		lantern_pierce = 0, -- 1110
		salvage = 0, -- 1110
		reload = 0, -- 1111
		craft = 0 -- 1111
	} -- 1111
	local storyRanks = p:getStoryTalentRanks() -- 1113
	local ____asRecord_55 = asRecord -- 1114
	local ____asRecord_54 = asRecord -- 1114
	local ____temp_53 -- 1114
	if storyRec ~= nil then -- 1114
		____temp_53 = storyRec.talents -- 1114
	else -- 1114
		____temp_53 = nil -- 1114
	end -- 1114
	local ____opt_51 = ____asRecord_54(____temp_53) -- 1114
	local fallbackStoryRanks = ____asRecord_55(____opt_51 and ____opt_51.ranks) -- 1114
	local srcRanks = storyRanks ~= nil and storyRanks or fallbackStoryRanks -- 1115
	local totalRanks = 0 -- 1118
	if srcRanks ~= nil then -- 1119
		for k in pairs(srcRanks) do -- 1120
			local v = srcRanks[k] -- 1121
			if type(v) == "number" and v > 0 then -- 1122
				ranks[k] = v -- 1123
				totalRanks = totalRanks + v -- 1124
			end -- 1124
		end -- 1124
	end -- 1124
	local inv = p.run.inventory -- 1129
	local supplies = { -- 1130
		wood = inv.wood or 0, -- 1131
		bell = inv.bell or 0, -- 1132
		shield = inv.shield or 0, -- 1133
		wedge = inv.wedge or 0, -- 1134
		ammo = inv.ammo or 0, -- 1135
		scrap = inv.scrap or 0, -- 1136
		pass = inv.pass or 0, -- 1137
		quickbelt = inv.quickbelt or 0 -- 1138
	} -- 1138
	local ____asRecord_57 = asRecord -- 1141
	local ____temp_56 -- 1141
	if storyRec ~= nil then -- 1141
		____temp_56 = storyRec.segments -- 1141
	else -- 1141
		____temp_56 = nil -- 1141
	end -- 1141
	local clearedSegs = ____asRecord_57(____temp_56) -- 1141
	local stages = {} -- 1142
	local showRouteTrack = false -- 1143
	if isEscort then -- 1144
		stages = buildStageNodes(ESCORT_STAGE_SPECS, roomKey, clearedSegs) -- 1145
		showRouteTrack = true -- 1146
	elseif isCampaignRun then -- 1147
		stages = buildStageNodes(CAMPAIGN_STAGE_SPECS, roomKey) -- 1148
		showRouteTrack = true -- 1149
	end -- 1149
	local explicitActive = readBool(pRec, "roguelikeActive") == true or readBool(runRec, "roguelikeActive") == true -- 1152
	local active = explicitActive or isEscort or isCampaignRun or #offers > 0 or totalRanks > 0 -- 1154
	local talentLabelHints = {} -- 1156
	local ____asRecord_59 = asRecord -- 1157
	local ____temp_58 -- 1157
	if pRec ~= nil then -- 1157
		____temp_58 = pRec.talentMeta -- 1157
	else -- 1157
		____temp_58 = nil -- 1157
	end -- 1157
	local ____asRecord_59_result_62 = ____asRecord_59(____temp_58) -- 1157
	if ____asRecord_59_result_62 == nil then -- 1157
		local ____asRecord_61 = asRecord -- 1158
		local ____temp_60 -- 1158
		if runRec ~= nil then -- 1158
			____temp_60 = runRec.talentMeta -- 1158
		else -- 1158
			____temp_60 = nil -- 1158
		end -- 1158
		____asRecord_59_result_62 = ____asRecord_61(____temp_60) -- 1157
	end -- 1157
	local rawMeta = ____asRecord_59_result_62 -- 1157
	if rawMeta ~= nil then -- 1159
		for k in pairs(rawMeta) do -- 1160
			local v = rawMeta[k] -- 1161
			if type(v) == "string" then -- 1162
				talentLabelHints[k] = v -- 1163
			else -- 1163
				local obj = asRecord(v) -- 1165
				local n = readStr(obj, "name") -- 1166
				local d = readStr(obj, "desc") -- 1167
				if n ~= nil then -- 1168
					talentLabelHints[k] = d ~= nil and d ~= "" and (n .. "·") .. d or n -- 1169
				end -- 1169
			end -- 1169
		end -- 1169
	end -- 1169
	local reloadTicksNow = computeDerivedReloadTicks(ranks, supplies) -- 1175
	local invulnTicksNow = computeDerivedInvulnTicks(ranks) -- 1176
	local craftTicksNow = computeDerivedCraftTicks(ranks) -- 1177
	return { -- 1179
		active = active, -- 1180
		showRouteTrack = showRouteTrack, -- 1181
		seed = p.run.seed, -- 1182
		ticks = p.run.ticks, -- 1183
		routeTag = p.run.route, -- 1184
		roomKey = roomKey, -- 1185
		offers = offers, -- 1186
		ranks = ranks, -- 1187
		totalRanks = totalRanks, -- 1188
		hp = p.hp, -- 1189
		maxHp = p.maxHp, -- 1190
		reloadTicksNow = reloadTicksNow, -- 1191
		invulnTicksNow = invulnTicksNow, -- 1192
		craftTicksNow = craftTicksNow, -- 1193
		activeReloadTicks = readNum(pRec, "reloadT") or 0, -- 1194
		activeInvulnTicks = readNum(pRec, "invulnT") or 0, -- 1195
		activeCraftTicks = readNum(pRec, "craftT") or 0, -- 1196
		equippedWeapon = p.equippedWeapon ~= "" and p.equippedWeapon or "standard_gun", -- 1197
		supplies = supplies, -- 1198
		stages = stages, -- 1199
		talentLabelHints = talentLabelHints -- 1200
	} -- 1200
end -- 1090
function DualRouteContract.prototype.readLiveCraftBench(self, cbRec, pRec, runRec) -- 1204
	local recipes = defaultRecipes() -- 1209
	if cbRec ~= nil and __TS__ArrayIsArray(cbRec.recipes) then -- 1210
		local rawList = cbRec.recipes -- 1211
		local parsed = {} -- 1212
		local i = 0 -- 1213
		do -- 1213
			i = 0 -- 1214
			while i < #rawList do -- 1214
				do -- 1214
					local item = asRecord(rawList[i + 1]) -- 1215
					if item == nil then -- 1216
						goto __continue180 -- 1217
					end -- 1217
					local id = readStr(item, "id") -- 1219
					local name = readStr(item, "name") -- 1220
					if id == nil or name == nil then -- 1221
						goto __continue180 -- 1222
					end -- 1222
					local ____id_64 = id -- 1225
					local ____name_65 = name -- 1226
					local ____temp_66 = readStr(item, "desc") or "" -- 1227
					local ____parseReloadEffect_result_67 = parseReloadEffect(item.enhancedEffect) -- 1228
					local ____temp_68 = readNumMap(item, "cost") or ({}) -- 1229
					local ____readBool_result_63 = readBool(item, "crafted") -- 1230
					if ____readBool_result_63 == nil then -- 1230
						____readBool_result_63 = false -- 1230
					end -- 1230
					parsed[#parsed + 1] = { -- 1224
						id = ____id_64, -- 1225
						name = ____name_65, -- 1226
						desc = ____temp_66, -- 1227
						enhancedEffect = ____parseReloadEffect_result_67, -- 1228
						cost = ____temp_68, -- 1229
						crafted = ____readBool_result_63 -- 1230
					} -- 1230
				end -- 1230
				::__continue180:: -- 1230
				i = i + 1 -- 1214
			end -- 1214
		end -- 1214
		if #parsed > 0 then -- 1233
			local ____readBool_result_69 = readBool(cbRec, "active") -- 1235
			if ____readBool_result_69 == nil then -- 1235
				____readBool_result_69 = false -- 1235
			end -- 1235
			local ____readBool_result_70 = readBool(cbRec, "firstCraftDone") -- 1236
			if ____readBool_result_70 == nil then -- 1236
				____readBool_result_70 = false -- 1236
			end -- 1236
			return { -- 1234
				active = ____readBool_result_69, -- 1235
				firstCraftDone = ____readBool_result_70, -- 1236
				justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 1237
				inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or ({}), -- 1238
				recipes = parsed, -- 1239
				equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 1240
			} -- 1240
		end -- 1240
	end -- 1240
	local ____readBool_result_71 = readBool(cbRec, "active") -- 1245
	if ____readBool_result_71 == nil then -- 1245
		____readBool_result_71 = false -- 1245
	end -- 1245
	local ____readBool_result_72 = readBool(cbRec, "firstCraftDone") -- 1246
	if ____readBool_result_72 == nil then -- 1246
		____readBool_result_72 = false -- 1246
	end -- 1246
	return { -- 1244
		active = ____readBool_result_71, -- 1245
		firstCraftDone = ____readBool_result_72, -- 1246
		justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 1247
		inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or readNumMap(runRec, "craftInventory") or ({}), -- 1248
		recipes = recipes, -- 1249
		equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 1250
	} -- 1250
end -- 1204
function DualRouteContract.prototype.readLiveArchive(self, p) -- 1254
	local pRec = asRecord(p) -- 1255
	local runRec = asRecord(p.run) -- 1256
	local ____asRecord_74 = asRecord -- 1257
	local ____temp_73 -- 1257
	if pRec ~= nil then -- 1257
		____temp_73 = pRec.archive -- 1257
	else -- 1257
		____temp_73 = nil -- 1257
	end -- 1257
	local ____asRecord_74_result_77 = ____asRecord_74(____temp_73) -- 1257
	if ____asRecord_74_result_77 == nil then -- 1257
		local ____asRecord_76 = asRecord -- 1258
		local ____temp_75 -- 1258
		if runRec ~= nil then -- 1258
			____temp_75 = runRec.archive -- 1258
		else -- 1258
			____temp_75 = nil -- 1258
		end -- 1258
		____asRecord_74_result_77 = ____asRecord_76(____temp_75) -- 1257
	end -- 1257
	local archRec = ____asRecord_74_result_77 -- 1257
	local ____readBool_result_78 = readBool(archRec, "childCleared") -- 1260
	if ____readBool_result_78 == nil then -- 1260
		____readBool_result_78 = readBool(pRec, "childCleared") -- 1260
	end -- 1260
	local ____readBool_result_78_79 = ____readBool_result_78 -- 1260
	if ____readBool_result_78_79 == nil then -- 1260
		____readBool_result_78_79 = false -- 1260
	end -- 1260
	local childCleared = ____readBool_result_78_79 -- 1260
	local ____readBool_result_80 = readBool(archRec, "soldierCleared") -- 1261
	if ____readBool_result_80 == nil then -- 1261
		____readBool_result_80 = readBool(pRec, "soldierCleared") -- 1261
	end -- 1261
	local ____readBool_result_80_81 = ____readBool_result_80 -- 1261
	if ____readBool_result_80_81 == nil then -- 1261
		____readBool_result_80_81 = false -- 1261
	end -- 1261
	local soldierCleared = ____readBool_result_80_81 -- 1261
	local ____readBool_result_82 = readBool(archRec, "artifactOwned") -- 1262
	if ____readBool_result_82 == nil then -- 1262
		____readBool_result_82 = readBool(pRec, "artifactOwned") -- 1262
	end -- 1262
	local ____readBool_result_82_83 = ____readBool_result_82 -- 1262
	if ____readBool_result_82_83 == nil then -- 1262
		____readBool_result_82_83 = false -- 1262
	end -- 1262
	local artifactOwned = ____readBool_result_82_83 -- 1262
	local ____temp_85 -- 1263
	if archRec ~= nil and archRec.museumPhase ~= nil then -- 1263
		____temp_85 = archRec.museumPhase -- 1264
	else -- 1264
		local ____temp_84 -- 1265
		if pRec ~= nil then -- 1265
			____temp_84 = pRec.museumPhase -- 1265
		else -- 1265
			____temp_84 = nil -- 1265
		end -- 1265
		____temp_85 = ____temp_84 -- 1265
	end -- 1265
	local rawPhase = ____temp_85 -- 1263
	local museumPhase = parseMuseumPhase(rawPhase) -- 1266
	local ____readBool_result_86 = readBool(archRec, "museumSeen") -- 1267
	if ____readBool_result_86 == nil then -- 1267
		____readBool_result_86 = readBool(pRec, "museumSeen") -- 1267
	end -- 1267
	local ____readBool_result_86_87 = ____readBool_result_86 -- 1267
	if ____readBool_result_86_87 == nil then -- 1267
		____readBool_result_86_87 = false -- 1267
	end -- 1267
	local museumSeen = ____readBool_result_86_87 -- 1267
	local livePhase = p.phase -- 1276
	if p.room.key == "museum" then -- 1277
		if livePhase == "museum-cabinet" then -- 1278
			museumPhase = museumPhase == "well_reflect" and "well_reflect" or "hall_walk" -- 1279
		elseif livePhase == "museum-hall" or livePhase == "museum-lamp" then -- 1280
			museumPhase = "hall_walk" -- 1281
		elseif livePhase == "museum-return" then -- 1282
			museumPhase = "lamp_turn" -- 1283
		elseif livePhase == "museum-knock" or livePhase == "museum-done" then -- 1284
			museumPhase = "return_cabinet" -- 1285
		end -- 1285
	elseif p.room.key == "prologue" and museumPhase == "locked" and childCleared and soldierCleared and not museumSeen then -- 1287
		local backendWellOpen = readBool(pRec, "wellOpen") == true -- 1288
		local hasBackendWell = readNum(pRec, "wellX") ~= nil -- 1289
		if backendWellOpen or livePhase == "prologue-well" or artifactOwned and hasBackendWell then -- 1290
			museumPhase = "well_open" -- 1291
		end -- 1291
	end -- 1291
	return { -- 1295
		childCleared = childCleared, -- 1296
		soldierCleared = soldierCleared, -- 1297
		artifactOwned = artifactOwned, -- 1298
		museumPhase = museumPhase, -- 1299
		museumSeen = museumSeen -- 1300
	} -- 1300
end -- 1254
function DualRouteContract.prototype.forwardLiveIntent(self, p, intent) -- 1304
	if intent.kind == "craftSubmit" then -- 1305
		if self.livePendingCraftRequests[intent.requestId] == true then -- 1306
			return false -- 1307
		end -- 1307
		self.livePendingCraftRequests[intent.requestId] = true -- 1309
	end -- 1309
	local pRec = asRecord(p) -- 1311
	if pRec == nil then -- 1312
		return false -- 1313
	end -- 1313
	local handler = pRec.submitFeIntent -- 1315
	if type(handler) == "function" then -- 1316
		local fn = handler -- 1317
		local result = fn(p, intent) -- 1318
		if result ~= false then -- 1319
			return true -- 1320
		end -- 1320
		if intent.kind == "museumInteract" and intent.target == "well_pickup" then -- 1323
			local wellRes = fn(p, {kind = "wellPick"}) -- 1324
			return wellRes ~= false -- 1325
		end -- 1325
		return false -- 1327
	end -- 1327
	if intent.kind == "chooseTalent" then -- 1329
		local choose = pRec.chooseTalent -- 1330
		if type(choose) == "function" then -- 1331
			return choose(p, intent.slot) == true -- 1332
		end -- 1332
	end -- 1332
	local tapNode = pRec.reloadTapNode -- 1336
	if type(tapNode) == "function" then -- 1337
		local fn = tapNode -- 1338
		if intent.kind == "reloadTapNode" then -- 1339
			fn(p, intent.node) -- 1340
			return true -- 1341
		end -- 1341
		if intent.kind == "reloadPathCommit" and #intent.path > 0 then -- 1343
			local i = 0 -- 1344
			do -- 1344
				i = 0 -- 1345
				while i < #intent.path do -- 1345
					do -- 1345
						if i == 0 and intent.path[i + 1] == 0 then -- 1346
							goto __continue205 -- 1347
						end -- 1347
						fn(p, intent.path[i + 1]) -- 1349
					end -- 1349
					::__continue205:: -- 1349
					i = i + 1 -- 1345
				end -- 1345
			end -- 1345
			return true -- 1351
		end -- 1351
	end -- 1351
	return false -- 1354
end -- 1304
function DualRouteContract.prototype.sampleRehearsal(self, p, dt, input, st) -- 1359
	local countElapsedTicks = st.countTickOverride ~= nil and st.countTickOverride or p.countTick -- 1360
	local countDurationTicks = math.max(1, st.countDurationOverride or GATE_COUNT_END) -- 1361
	local countNumber = gateCountAtTick(countElapsedTicks) -- 1362
	local countProgress = math.max( -- 1363
		0, -- 1363
		math.min(1, countElapsedTicks / countDurationTicks) -- 1363
	) -- 1363
	if p.room.key == "gate" and p.phase == "gate-count" and st.storyRoute == "soldier" then -- 1366
		if countElapsedTicks < countDurationTicks then -- 1367
			st.gateReunion.active = false -- 1368
			st.gateReunion.knockHeard = false -- 1369
			st.gateReunion.holding = false -- 1370
			st.gateReunion.holdProgress = 0 -- 1371
			st.gateHoldArmed = not input.interact.held -- 1372
			st.gatePrevInteractHeld = input.interact.held -- 1373
		elseif not st.gateReunion.completed then -- 1374
			st.gateReunion.active = true -- 1375
			st.gateReunion.knockHeard = true -- 1376
			if not st.gateHoldArmed and not input.interact.held then -- 1377
				st.gateHoldArmed = true -- 1378
			end -- 1378
			if dt > 0 then -- 1380
				if st.gateHoldArmed and input.interact.held then -- 1381
					st.gateReunion.holding = true -- 1382
					st.gateReunion.holdProgress = math.min(1, st.gateReunion.holdProgress + dt / GATE_REUNION_HOLD_SECONDS) -- 1383
					if st.gateReunion.holdProgress >= 1 then -- 1387
						st.gateReunion.holdProgress = 1 -- 1388
						st.gateReunion.holding = false -- 1389
						st.gateReunion.completed = true -- 1390
						st.backCarry.handInHand = true -- 1391
					end -- 1391
				else -- 1391
					if st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1394
						local ____st_gateReunion_88, ____releasedAbortCount_89 = st.gateReunion, "releasedAbortCount" -- 1395
						____st_gateReunion_88[____releasedAbortCount_89] = ____st_gateReunion_88[____releasedAbortCount_89] + 1 -- 1395
					end -- 1395
					st.gateReunion.holding = false -- 1397
					st.gateReunion.holdProgress = 0 -- 1398
				end -- 1398
			end -- 1398
			st.gatePrevInteractHeld = input.interact.held -- 1401
		end -- 1401
	end -- 1401
	if st.reloadSession.active and dt > 0 then -- 1406
		local ____st_reloadSession_90, ____elapsed_91 = st.reloadSession, "elapsed" -- 1407
		____st_reloadSession_90[____elapsed_91] = ____st_reloadSession_90[____elapsed_91] + dt -- 1407
		if st.reloadSession.invalidFlash > 0 then -- 1408
			st.reloadSession.invalidFlash = math.max(0, st.reloadSession.invalidFlash - dt) -- 1409
		end -- 1409
		if st.reloadSession.elapsed >= st.reloadSession.duration then -- 1411
			st.reloadSession.active = false -- 1412
			st.reloadSession.elapsed = 0 -- 1413
			st.reloadSession.path = {} -- 1414
			st.reloadSession.previewEffect = "normal" -- 1415
			st.reloadSession.nextEffect = "normal" -- 1416
			st.reloadSession.firstTime = false -- 1417
			st.timeScaleOverride = nil -- 1418
		end -- 1418
	end -- 1418
	if st.craftBench.justCraftedTimer > 0 and dt > 0 then -- 1423
		st.craftBench.justCraftedTimer = math.max(0, st.craftBench.justCraftedTimer - dt) -- 1424
	end -- 1424
	local baseScale = st.timeScaleOverride ~= nil and math.max(0, st.timeScaleOverride) or (st.reloadSession.active and DEFAULT_SLOW_TIME_SCALE or 1) -- 1427
	local timeScale = st.timeScaleOverride ~= nil and baseScale or math.min(baseScale, self.liveFocusTimeScale) -- 1430
	local visualMode = deriveVisualMode( -- 1434
		p.room.key, -- 1435
		p.phase, -- 1436
		st.storyRoute, -- 1437
		st.archive.museumPhase, -- 1438
		countProgress, -- 1439
		st.gateReunion.completed -- 1440
	) -- 1440
	return { -- 1443
		storyRoute = st.storyRoute, -- 1444
		countElapsedTicks = countElapsedTicks, -- 1445
		countDurationTicks = countDurationTicks, -- 1446
		countNumber = countNumber, -- 1447
		countProgress = countProgress, -- 1448
		gateReunion = { -- 1449
			active = st.gateReunion.active, -- 1450
			knockHeard = st.gateReunion.knockHeard, -- 1451
			holdProgress = st.gateReunion.holdProgress, -- 1452
			holding = st.gateReunion.holding, -- 1453
			completed = st.gateReunion.completed, -- 1454
			releasedAbortCount = st.gateReunion.releasedAbortCount -- 1455
		}, -- 1455
		backCarry = {active = st.backCarry.active, handInHand = st.backCarry.handInHand, mounting = st.backCarry.mounting, atBench = st.backCarry.atBench}, -- 1457
		timeScale = timeScale, -- 1463
		reloadSession = { -- 1464
			active = st.reloadSession.active, -- 1465
			firstTime = st.reloadSession.firstTime, -- 1466
			elapsed = st.reloadSession.elapsed, -- 1467
			duration = st.reloadSession.duration, -- 1468
			path = __TS__ArraySlice(st.reloadSession.path), -- 1469
			previewEffect = st.reloadSession.previewEffect, -- 1470
			nextEffect = st.reloadSession.nextEffect, -- 1471
			invalidFlash = st.reloadSession.invalidFlash -- 1472
		}, -- 1472
		craftBench = { -- 1474
			active = st.craftBench.active, -- 1475
			firstCraftDone = st.craftBench.firstCraftDone, -- 1476
			justCraftedTimer = st.craftBench.justCraftedTimer, -- 1477
			inventory = cloneRecordNum(st.craftBench.inventory), -- 1478
			recipes = cloneRecipes(st.craftBench.recipes), -- 1479
			equippedWeapon = st.craftBench.equippedWeapon -- 1480
		}, -- 1480
		archive = { -- 1482
			childCleared = st.archive.childCleared, -- 1483
			soldierCleared = st.archive.soldierCleared, -- 1484
			artifactOwned = st.archive.artifactOwned, -- 1485
			museumPhase = st.archive.museumPhase, -- 1486
			museumSeen = st.archive.museumSeen -- 1487
		}, -- 1487
		roguelike = cloneRoguelike(st.roguelike), -- 1489
		assistHintsEnabled = self.assistHintsEnabled, -- 1490
		visualMode = visualMode, -- 1491
		dataSource = "rehearsal", -- 1492
		isRehearsal = true, -- 1493
		rehearsalTag = st.tag -- 1494
	} -- 1494
end -- 1359
function DualRouteContract.prototype.applyRehearsalIntent(self, st, intent) -- 1498
	if intent.kind == "gateReunionHold" then -- 1499
		if not st.gateReunion.active or st.gateReunion.completed then -- 1500
			return false -- 1501
		end -- 1501
		if not intent.holding and st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1503
			local ____st_gateReunion_92, ____releasedAbortCount_93 = st.gateReunion, "releasedAbortCount" -- 1504
			____st_gateReunion_92[____releasedAbortCount_93] = ____st_gateReunion_92[____releasedAbortCount_93] + 1 -- 1504
			st.gateReunion.holdProgress = 0 -- 1505
		end -- 1505
		st.gateReunion.holding = intent.holding -- 1507
		return true -- 1508
	end -- 1508
	if intent.kind == "reloadOpen" then -- 1510
		self:triggerMockReload(true) -- 1511
		return true -- 1512
	end -- 1512
	if intent.kind == "reloadTapNode" then -- 1514
		if not st.reloadSession.active then -- 1515
			return false -- 1516
		end -- 1516
		if #st.reloadSession.path == 0 then -- 1518
			local ____st_reloadSession_path_94 = st.reloadSession.path -- 1519
			____st_reloadSession_path_94[#____st_reloadSession_path_94 + 1] = 0 -- 1519
		end -- 1519
		if __TS__ArrayIndexOf(st.reloadSession.path, intent.node) >= 0 then -- 1521
			st.reloadSession.invalidFlash = 0.35 -- 1522
			st.reloadSession.path = {0} -- 1523
			st.reloadSession.previewEffect = "normal" -- 1524
			return false -- 1525
		end -- 1525
		local ____st_reloadSession_path_95 = st.reloadSession.path -- 1527
		____st_reloadSession_path_95[#____st_reloadSession_path_95 + 1] = intent.node -- 1527
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(st.reloadSession.path) -- 1528
		if intent.node == 8 then -- 1529
			st.reloadSession.nextEffect = st.reloadSession.previewEffect -- 1530
			st.reloadSession.active = false -- 1531
			st.reloadSession.elapsed = 0 -- 1532
			st.reloadSession.path = {} -- 1533
			st.reloadSession.firstTime = false -- 1534
			st.timeScaleOverride = nil -- 1535
		end -- 1535
		return true -- 1537
	end -- 1537
	if intent.kind == "reloadPathPreview" then -- 1539
		if not st.reloadSession.active then -- 1540
			return false -- 1541
		end -- 1541
		st.reloadSession.path = __TS__ArraySlice(intent.path) -- 1543
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(intent.path) -- 1544
		return true -- 1545
	end -- 1545
	if intent.kind == "reloadPathCommit" then -- 1547
		if not st.reloadSession.active then -- 1548
			return false -- 1549
		end -- 1549
		if #intent.path < 2 then -- 1551
			st.reloadSession.invalidFlash = 0.35 -- 1552
			st.reloadSession.path = {} -- 1553
			st.reloadSession.previewEffect = "normal" -- 1554
			return false -- 1555
		end -- 1555
		local effect = deriveReloadEffectFromPath(intent.path) -- 1557
		st.reloadSession.nextEffect = effect -- 1558
		st.reloadSession.previewEffect = effect -- 1559
		st.reloadSession.path = {} -- 1560
		st.reloadSession.active = false -- 1561
		st.reloadSession.elapsed = 0 -- 1562
		st.reloadSession.firstTime = false -- 1563
		st.timeScaleOverride = nil -- 1564
		return true -- 1565
	end -- 1565
	if intent.kind == "reloadCancel" then -- 1567
		st.reloadSession.active = false -- 1568
		st.reloadSession.elapsed = 0 -- 1569
		st.reloadSession.path = {} -- 1570
		st.reloadSession.previewEffect = "normal" -- 1571
		st.timeScaleOverride = nil -- 1572
		return true -- 1573
	end -- 1573
	if intent.kind == "craftSubmit" then -- 1575
		if not st.craftBench.active or st.handledCraftRequestIds[intent.requestId] == true then -- 1576
			return false -- 1577
		end -- 1577
		local target -- 1579
		local i = 0 -- 1580
		do -- 1580
			i = 0 -- 1581
			while i < #st.craftBench.recipes do -- 1581
				if st.craftBench.recipes[i + 1].id == intent.recipeId then -- 1582
					target = st.craftBench.recipes[i + 1] -- 1583
					break -- 1584
				end -- 1584
				i = i + 1 -- 1581
			end -- 1581
		end -- 1581
		if target == nil or target.crafted then -- 1587
			return false -- 1588
		end -- 1588
		for mat in pairs(target.cost) do -- 1590
			if (st.craftBench.inventory[mat] or 0) < target.cost[mat] then -- 1591
				return false -- 1592
			end -- 1592
		end -- 1592
		for mat in pairs(target.cost) do -- 1595
			st.craftBench.inventory[mat] = (st.craftBench.inventory[mat] or 0) - target.cost[mat] -- 1596
		end -- 1596
		st.handledCraftRequestIds[intent.requestId] = true -- 1598
		target.crafted = true -- 1599
		st.craftBench.equippedWeapon = target.id -- 1600
		st.craftBench.justCraftedTimer = st.craftBench.firstCraftDone and 0.45 or 1 -- 1601
		st.craftBench.firstCraftDone = true -- 1602
		return true -- 1603
	end -- 1603
	if intent.kind == "craftEquip" then -- 1605
		st.craftBench.equippedWeapon = intent.weaponId -- 1606
		return true -- 1607
	end -- 1607
	if intent.kind == "craftClose" then -- 1609
		st.craftBench.active = false -- 1610
		st.backCarry.atBench = false -- 1611
		return true -- 1612
	end -- 1612
	if intent.kind == "museumInteract" then -- 1614
		if intent.target == "well_pickup" and st.archive.museumPhase == "well_open" then -- 1615
			st.archive.artifactOwned = true -- 1616
			st.archive.museumPhase = "well_reflect" -- 1617
			return true -- 1618
		end -- 1618
		if intent.target == "enter_hall" and st.archive.museumPhase == "well_reflect" then -- 1620
			st.archive.museumPhase = "hall_walk" -- 1621
			return true -- 1622
		end -- 1622
		if intent.target == "lamp_turn" and st.archive.museumPhase == "hall_walk" then -- 1624
			st.archive.museumPhase = "lamp_turn" -- 1625
			return true -- 1626
		end -- 1626
		if intent.target == "begin_return_cabinet" and st.archive.museumPhase == "lamp_turn" then -- 1628
			st.archive.museumPhase = "return_cabinet" -- 1629
			return true -- 1630
		end -- 1630
		if intent.target == "return_cabinet" then -- 1632
			st.archive.museumPhase = "done" -- 1633
			st.archive.museumSeen = true -- 1634
			return true -- 1635
		end -- 1635
		return false -- 1637
	end -- 1637
	if intent.kind == "chooseTalent" then -- 1639
		local rg = st.roguelike -- 1640
		local id = rg.offers[intent.slot + 1] -- 1641
		if id == nil then -- 1642
			return false -- 1643
		end -- 1643
		rg.ranks[id] = (rg.ranks[id] or 0) + 1 -- 1645
		rg.totalRanks = rg.totalRanks + 1 -- 1646
		if id == "vitality" then -- 1647
			rg.maxHp = rg.maxHp + 1 -- 1648
			rg.hp = rg.hp + 1 -- 1649
		end -- 1649
		rg.offers = {} -- 1651
		rg.reloadTicksNow = computeDerivedReloadTicks(rg.ranks, rg.supplies) -- 1652
		rg.invulnTicksNow = computeDerivedInvulnTicks(rg.ranks) -- 1653
		rg.craftTicksNow = computeDerivedCraftTicks(rg.ranks) -- 1654
		return true -- 1655
	end -- 1655
	return false -- 1657
end -- 1498
return ____exports -- 1498
