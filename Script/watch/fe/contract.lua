-- [ts]: contract.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local cloneRecordNum -- 353
local ____play = require("Script.watch.play") -- 20
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 20
local gateCountAtTick = ____play.gateCountAtTick -- 20
function cloneRecordNum(src) -- 353
	local out = {} -- 354
	for k in pairs(src) do -- 355
		out[k] = src[k] -- 356
	end -- 356
	return out -- 358
end -- 358
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
	return BASE_INVULN_HIT_TICKS + 12 * (ranks.guard or 0) -- 226
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
		ranks = {vitality = 0, reload = 0, guard = 0, craft = 0}, -- 272
		totalRanks = 0, -- 273
		hp = 3, -- 274
		maxHp = 3, -- 275
		reloadTicksNow = 54, -- 276
		invulnTicksNow = BASE_INVULN_HIT_TICKS, -- 277
		craftTicksNow = BASE_CRAFT_TICKS, -- 278
		activeReloadTicks = 0, -- 279
		activeInvulnTicks = 0, -- 280
		activeCraftTicks = 0, -- 281
		equippedWeapon = "standard_gun", -- 282
		supplies = {}, -- 283
		stages = {}, -- 284
		talentLabelHints = {} -- 285
	} -- 285
end -- 263
local function cloneRoguelike(src) -- 289
	local stages = {} -- 290
	local i = 0 -- 291
	do -- 291
		i = 0 -- 292
		while i < #src.stages do -- 292
			local s = src.stages[i + 1] -- 293
			stages[#stages + 1] = { -- 294
				key = s.key, -- 295
				label = s.label, -- 296
				isBench = s.isBench, -- 297
				isFinal = s.isFinal, -- 298
				cleared = s.cleared, -- 299
				current = s.current -- 300
			} -- 300
			i = i + 1 -- 292
		end -- 292
	end -- 292
	local hints = {} -- 303
	for k in pairs(src.talentLabelHints) do -- 304
		hints[k] = src.talentLabelHints[k] -- 305
	end -- 305
	return { -- 307
		active = src.active, -- 308
		showRouteTrack = src.showRouteTrack, -- 309
		seed = src.seed, -- 310
		ticks = src.ticks, -- 311
		routeTag = src.routeTag, -- 312
		roomKey = src.roomKey, -- 313
		offers = __TS__ArraySlice(src.offers), -- 314
		ranks = cloneRecordNum(src.ranks), -- 315
		totalRanks = src.totalRanks, -- 316
		hp = src.hp, -- 317
		maxHp = src.maxHp, -- 318
		reloadTicksNow = src.reloadTicksNow, -- 319
		invulnTicksNow = src.invulnTicksNow, -- 320
		craftTicksNow = src.craftTicksNow, -- 321
		activeReloadTicks = src.activeReloadTicks, -- 322
		activeInvulnTicks = src.activeInvulnTicks, -- 323
		activeCraftTicks = src.activeCraftTicks, -- 324
		equippedWeapon = src.equippedWeapon, -- 325
		supplies = cloneRecordNum(src.supplies), -- 326
		stages = stages, -- 327
		talentLabelHints = hints -- 328
	} -- 328
end -- 289
local function defaultRecipes() -- 332
	return {{ -- 333
		id = "guide_lantern_gun", -- 335
		name = "引路灯铳", -- 336
		desc = "以两枚木纹筹改制，增强灯纹照亮范围与余明", -- 337
		enhancedEffect = "light", -- 338
		cost = {wood_tally = 2}, -- 339
		crafted = false -- 340
	}, { -- 342
		id = "echo_gun", -- 343
		name = "回声铳", -- 344
		desc = "以一枚木纹筹与一枚铃纹筹改制，增强铃纹回声诱导", -- 345
		enhancedEffect = "echo", -- 346
		cost = {wood_tally = 1, bell_tally = 1}, -- 347
		crafted = false -- 348
	}} -- 348
end -- 332
local function cloneRecipes(list) -- 361
	local out = {} -- 362
	local i = 0 -- 363
	do -- 363
		i = 0 -- 364
		while i < #list do -- 364
			local r = list[i + 1] -- 365
			out[#out + 1] = { -- 366
				id = r.id, -- 367
				name = r.name, -- 368
				desc = r.desc, -- 369
				enhancedEffect = r.enhancedEffect, -- 370
				cost = cloneRecordNum(r.cost), -- 371
				crafted = r.crafted -- 372
			} -- 372
			i = i + 1 -- 364
		end -- 364
	end -- 364
	return out -- 375
end -- 361
local function createEmptyGateReunion() -- 378
	return { -- 379
		active = false, -- 380
		knockHeard = false, -- 381
		holdProgress = 0, -- 382
		holding = false, -- 383
		completed = false, -- 384
		releasedAbortCount = 0 -- 385
	} -- 385
end -- 378
local function createEmptyBackCarry() -- 389
	return {active = false, handInHand = false, mounting = false, atBench = false} -- 390
end -- 389
local function createEmptyReloadSession() -- 398
	return { -- 399
		active = false, -- 400
		firstTime = true, -- 401
		elapsed = 0, -- 402
		duration = DEFAULT_RELOAD_DURATION, -- 403
		path = {}, -- 404
		previewEffect = "normal", -- 405
		nextEffect = "normal", -- 406
		invalidFlash = 0 -- 407
	} -- 407
end -- 398
local function createEmptyCraftBench() -- 411
	return { -- 412
		active = false, -- 413
		firstCraftDone = false, -- 414
		justCraftedTimer = 0, -- 415
		inventory = {}, -- 416
		recipes = defaultRecipes(), -- 417
		equippedWeapon = "standard_gun" -- 418
	} -- 418
end -- 411
local function createEmptyArchive() -- 422
	return { -- 423
		childCleared = false, -- 424
		soldierCleared = false, -- 425
		artifactOwned = false, -- 426
		museumPhase = "locked", -- 427
		museumSeen = false -- 428
	} -- 428
end -- 422
local function createInitialRehearsalState(tag) -- 432
	local bench = createEmptyCraftBench() -- 433
	bench.inventory = {wood_tally = 2, bell_tally = 1} -- 434
	return { -- 435
		tag = tag, -- 436
		storyRoute = "undecided", -- 437
		countTickOverride = nil, -- 438
		countDurationOverride = nil, -- 439
		timeScaleOverride = nil, -- 440
		gateReunion = createEmptyGateReunion(), -- 441
		gateHoldArmed = true, -- 442
		gatePrevInteractHeld = false, -- 443
		backCarry = createEmptyBackCarry(), -- 444
		reloadSession = createEmptyReloadSession(), -- 445
		craftBench = bench, -- 446
		archive = createEmptyArchive(), -- 447
		roguelike = createEmptyRoguelike(), -- 448
		handledCraftRequestIds = {} -- 449
	} -- 449
end -- 432
local function asRecord(value) -- 453
	if value ~= nil and type(value) == "table" then -- 454
		return value -- 455
	end -- 455
	return nil -- 457
end -- 453
local function readNum(rec, key) -- 460
	if rec == nil then -- 461
		return nil -- 462
	end -- 462
	local v = rec[key] -- 464
	return type(v) == "number" and v or nil -- 465
end -- 460
local function readBool(rec, key) -- 468
	if rec == nil then -- 469
		return nil -- 470
	end -- 470
	local v = rec[key] -- 472
	local ____temp_0 -- 473
	if type(v) == "boolean" then -- 473
		____temp_0 = v -- 473
	else -- 473
		____temp_0 = nil -- 473
	end -- 473
	return ____temp_0 -- 473
end -- 468
local function readStr(rec, key) -- 476
	if rec == nil then -- 477
		return nil -- 478
	end -- 478
	local v = rec[key] -- 480
	return type(v) == "string" and v or nil -- 481
end -- 476
local function readNumArray(rec, key) -- 484
	if rec == nil then -- 485
		return nil -- 486
	end -- 486
	local v = rec[key] -- 488
	if not __TS__ArrayIsArray(v) then -- 489
		return nil -- 490
	end -- 490
	local out = {} -- 492
	local i = 0 -- 493
	do -- 493
		i = 0 -- 494
		while i < #v do -- 494
			if type(v[i + 1]) == "number" then -- 495
				out[#out + 1] = v[i + 1] -- 496
			end -- 496
			i = i + 1 -- 494
		end -- 494
	end -- 494
	return out -- 499
end -- 484
local function readNumMap(rec, key) -- 502
	if rec == nil then -- 503
		return nil -- 504
	end -- 504
	local obj = asRecord(rec[key]) -- 506
	if obj == nil then -- 507
		return nil -- 508
	end -- 508
	local out = {} -- 510
	for k in pairs(obj) do -- 511
		local val = obj[k] -- 512
		if type(val) == "number" then -- 513
			out[k] = val -- 514
		end -- 514
	end -- 514
	return out -- 517
end -- 502
local function parseStoryRoute(v) -- 520
	if v == "child" or v == "soldier" then -- 521
		return v -- 522
	end -- 522
	return "undecided" -- 524
end -- 520
local function parseReloadEffect(v) -- 527
	if v == "push" or v == "knockback" then -- 528
		return "knockback" -- 529
	end -- 529
	if v == "echo" or v == "light" then -- 531
		return v -- 532
	end -- 532
	return "normal" -- 534
end -- 527
local function parseMuseumPhase(v) -- 537
	if v == "well_open" or v == "well_reflect" or v == "hall_walk" or v == "lamp_turn" or v == "return_cabinet" or v == "done" then -- 539
		return v -- 546
	end -- 546
	return "locked" -- 548
end -- 537
--- 根据 3×3 路径点集合推导效果（对齐后端 reload.ts 布局）：
-- - 0 = 左下起点，8 = 右上枪机复位终点；
-- - 4 = 中心铃纹（echo，优先），2 = 右下灯纹（light），其余有效路径 = 推退（knockback）。
local function deriveReloadEffectFromPath(path) -- 556
	if #path < 2 then -- 557
		return "normal" -- 558
	end -- 558
	local hasBell = false -- 560
	local hasLamp = false -- 561
	local i = 0 -- 562
	do -- 562
		i = 0 -- 563
		while i < #path do -- 563
			if path[i + 1] == 4 then -- 564
				hasBell = true -- 565
			elseif path[i + 1] == 2 then -- 566
				hasLamp = true -- 567
			end -- 567
			i = i + 1 -- 563
		end -- 563
	end -- 563
	if hasBell then -- 570
		return "echo" -- 571
	end -- 571
	if hasLamp then -- 573
		return "light" -- 574
	end -- 574
	return "knockback" -- 576
end -- 556
local function deriveVisualMode(roomKey, phase, storyRoute, museumPhase, countProgress, reunionCompleted) -- 579
	if roomKey == "museum" or museumPhase == "well_reflect" or museumPhase == "hall_walk" or museumPhase == "lamp_turn" or museumPhase == "return_cabinet" then -- 588
		return "museum" -- 594
	end -- 594
	if roomKey == "gate" then -- 596
		if phase == "gate-hand" then -- 597
			return "pixel" -- 598
		end -- 598
		if phase == "gate-wait" then -- 600
			return reunionCompleted and "pixel" or "lowpoly" -- 601
		end -- 601
		if phase == "gate-count" then -- 603
			if storyRoute == "soldier" and reunionCompleted then -- 604
				return "pixel" -- 605
			end -- 605
			if countProgress <= 0 then -- 607
				return "pixel" -- 608
			end -- 608
			if countProgress >= 1 then -- 610
				return "lowpoly" -- 611
			end -- 611
			return "transition" -- 613
		end -- 613
		if phase == "gate-walk" then -- 615
			return storyRoute == "soldier" and "pixel" or (storyRoute == "child" and "lowpoly" or "pixel") -- 616
		end -- 616
		return "pixel" -- 618
	end -- 618
	if roomKey == "gatepath" or roomKey == "escort1" or roomKey == "escort2" or roomKey == "escort3" or roomKey == "escort4" or roomKey == "escort5" then -- 620
		return "pixel" -- 622
	end -- 622
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" then -- 624
		if storyRoute == "child" then -- 625
			return "lowpoly" -- 626
		end -- 626
		return "pixel" -- 628
	end -- 628
	return "pixel" -- 630
end -- 579
____exports.DualRouteContract = __TS__Class() -- 633
local DualRouteContract = ____exports.DualRouteContract -- 633
DualRouteContract.name = "DualRouteContract" -- 633
function DualRouteContract.prototype.____constructor(self) -- 633
	self.source = "live" -- 634
	self.assistHintsEnabled = false -- 637
	self.livePendingCraftRequests = {} -- 639
	self.liveReleasedAbortCount = 0 -- 641
	self.liveReloadInvalidFlash = 0 -- 642
	self.liveFocusTimeScale = 1 -- 643
	self.liveArchiveCache = createEmptyArchive() -- 644
	self.intentLog = {} -- 645
end -- 633
function DualRouteContract.prototype.getDataSource(self) -- 649
	return self.source -- 650
end -- 649
function DualRouteContract.prototype.isRehearsal(self) -- 654
	return self.source == "rehearsal" and self.rehearsal ~= nil -- 655
end -- 654
function DualRouteContract.prototype.enterRehearsal(self, tag) -- 659
	if tag == nil then -- 659
		tag = "rehearsal" -- 659
	end -- 659
	self.source = "rehearsal" -- 660
	if self.rehearsal == nil then -- 661
		self.rehearsal = createInitialRehearsalState(tag) -- 662
	else -- 662
		self.rehearsal.tag = tag -- 664
	end -- 664
end -- 659
function DualRouteContract.prototype.exitRehearsal(self) -- 669
	self.source = "live" -- 670
	self.rehearsal = nil -- 671
	self.liveFocusTimeScale = 1 -- 672
end -- 669
function DualRouteContract.prototype.setFocusTimeScale(self, scale) -- 676
	self.liveFocusTimeScale = math.max( -- 677
		0.2, -- 677
		math.min(1, scale) -- 677
	) -- 677
end -- 676
function DualRouteContract.prototype.getFocusTimeScale(self) -- 680
	return self.liveFocusTimeScale -- 681
end -- 680
function DualRouteContract.prototype.ensureRehearsal(self, tag) -- 684
	if tag == nil then -- 684
		tag = "mock" -- 684
	end -- 684
	if self.source ~= "rehearsal" or self.rehearsal == nil then -- 685
		self:enterRehearsal(tag) -- 686
	end -- 686
	return self.rehearsal -- 688
end -- 684
function DualRouteContract.prototype.isAssistHintsEnabled(self) -- 691
	return self.assistHintsEnabled -- 692
end -- 691
function DualRouteContract.prototype.setAssistHintsEnabled(self, enabled) -- 695
	self.assistHintsEnabled = enabled -- 696
end -- 695
function DualRouteContract.prototype.toggleAssistHints(self) -- 699
	self.assistHintsEnabled = not self.assistHintsEnabled -- 700
	return self.assistHintsEnabled -- 701
end -- 699
function DualRouteContract.prototype.getLastSnapshot(self) -- 704
	return self.lastSnapshot -- 705
end -- 704
function DualRouteContract.prototype.peekSnapshot(self, p) -- 709
	local neutralInput = {interact = {held = false, pressed = false, released = false}} -- 710
	return self:sample(p, 0, neutralInput) -- 713
end -- 709
function DualRouteContract.prototype.getIntentLog(self) -- 716
	return self.intentLog -- 717
end -- 716
function DualRouteContract.prototype.clearIntentLog(self) -- 720
	self.intentLog = {} -- 721
end -- 720
function DualRouteContract.prototype.resetForRoom(self, p) -- 731
	self.livePendingCraftRequests = {} -- 732
	self.liveReleasedAbortCount = 0 -- 733
	self.liveReloadInvalidFlash = 0 -- 734
	self.liveFocusTimeScale = 1 -- 735
	self.liveArchiveCache = self:readLiveArchive(p) -- 736
	if self.rehearsal ~= nil then -- 737
		self.rehearsal.gateReunion = createEmptyGateReunion() -- 738
		self.rehearsal.gateHoldArmed = true -- 739
		self.rehearsal.gatePrevInteractHeld = false -- 740
		self.rehearsal.reloadSession = createEmptyReloadSession() -- 741
		self.rehearsal.craftBench.active = false -- 742
		self.rehearsal.craftBench.justCraftedTimer = 0 -- 743
		self.rehearsal.handledCraftRequestIds = {} -- 744
		self.rehearsal.timeScaleOverride = nil -- 745
	end -- 745
end -- 731
function DualRouteContract.prototype.sample(self, p, rawDt, input, events) -- 755
	local dt = p.paused and 0 or math.max(0, rawDt) -- 756
	local snap = self.source == "rehearsal" and self.rehearsal ~= nil and self:sampleRehearsal(p, dt, input, self.rehearsal) or self:sampleLive(p, dt, events) -- 757
	self.lastSnapshot = snap -- 760
	return snap -- 761
end -- 755
function DualRouteContract.prototype.submitIntent(self, p, intent) -- 769
	local accepted = false -- 770
	if self.source == "rehearsal" and self.rehearsal ~= nil then -- 771
		accepted = self:applyRehearsalIntent(self.rehearsal, intent) -- 772
	else -- 772
		accepted = self:forwardLiveIntent(p, intent) -- 774
	end -- 774
	local ____self_intentLog_1 = self.intentLog -- 776
	____self_intentLog_1[#____self_intentLog_1 + 1] = {tick = p.ticks, source = self.source, intent = intent, accepted = accepted} -- 776
	if #self.intentLog > MAX_INTENT_LOG then -- 782
		table.remove(self.intentLog, 1) -- 783
	end -- 783
	return accepted -- 785
end -- 769
function DualRouteContract.prototype.setMockRoute(self, route) -- 790
	local st = self:ensureRehearsal("mock") -- 791
	st.storyRoute = route -- 792
end -- 790
function DualRouteContract.prototype.setMockCountTick(self, tick, duration) -- 795
	local st = self:ensureRehearsal("mock") -- 796
	st.countTickOverride = tick -- 797
	if duration ~= nil and duration > 0 then -- 798
		st.countDurationOverride = duration -- 799
	end -- 799
end -- 795
function DualRouteContract.prototype.setMockTimeScale(self, scale) -- 803
	local st = self:ensureRehearsal("mock") -- 804
	st.timeScaleOverride = scale -- 805
end -- 803
function DualRouteContract.prototype.setMockGateReunion(self, patch) -- 808
	local st = self:ensureRehearsal("mock") -- 809
	if patch.active ~= nil then -- 810
		st.gateReunion.active = patch.active -- 810
	end -- 810
	if patch.knockHeard ~= nil then -- 811
		st.gateReunion.knockHeard = patch.knockHeard -- 811
	end -- 811
	if patch.holdProgress ~= nil then -- 812
		st.gateReunion.holdProgress = math.max( -- 812
			0, -- 812
			math.min(1, patch.holdProgress) -- 812
		) -- 812
	end -- 812
	if patch.holding ~= nil then -- 813
		st.gateReunion.holding = patch.holding -- 813
	end -- 813
	if patch.completed ~= nil then -- 814
		st.gateReunion.completed = patch.completed -- 814
	end -- 814
	if patch.releasedAbortCount ~= nil then -- 815
		st.gateReunion.releasedAbortCount = patch.releasedAbortCount -- 815
	end -- 815
end -- 808
function DualRouteContract.prototype.setMockBackCarry(self, patch) -- 818
	local st = self:ensureRehearsal("mock") -- 819
	if patch.active ~= nil then -- 820
		st.backCarry.active = patch.active -- 820
	end -- 820
	if patch.handInHand ~= nil then -- 821
		st.backCarry.handInHand = patch.handInHand -- 821
	end -- 821
	if patch.mounting ~= nil then -- 822
		st.backCarry.mounting = patch.mounting -- 822
	end -- 822
	if patch.atBench ~= nil then -- 823
		st.backCarry.atBench = patch.atBench -- 823
	end -- 823
end -- 818
function DualRouteContract.prototype.triggerMockReload(self, active, options) -- 826
	local st = self:ensureRehearsal("mock") -- 830
	st.reloadSession.active = active -- 831
	if active then -- 832
		st.reloadSession.elapsed = 0 -- 833
		st.reloadSession.duration = options and options.duration or DEFAULT_RELOAD_DURATION -- 834
		st.reloadSession.path = {} -- 835
		st.reloadSession.previewEffect = "normal" -- 836
		st.reloadSession.invalidFlash = 0 -- 837
		if (options and options.firstTime) ~= nil then -- 838
			st.reloadSession.firstTime = options.firstTime -- 839
		end -- 839
		st.timeScaleOverride = options and options.slowTimeScale or DEFAULT_SLOW_TIME_SCALE -- 841
	else -- 841
		st.reloadSession.elapsed = 0 -- 843
		st.reloadSession.path = {} -- 844
		st.timeScaleOverride = nil -- 845
	end -- 845
end -- 826
function DualRouteContract.prototype.triggerMockBench(self, active, options) -- 849
	local st = self:ensureRehearsal("mock") -- 853
	st.craftBench.active = active -- 854
	st.backCarry.atBench = active -- 855
	if (options and options.inventory) ~= nil then -- 856
		st.craftBench.inventory = cloneRecordNum(options.inventory) -- 857
	end -- 857
	if (options and options.equippedWeapon) ~= nil then -- 859
		st.craftBench.equippedWeapon = options.equippedWeapon -- 860
	end -- 860
end -- 849
function DualRouteContract.prototype.setMockArchive(self, childCleared, soldierCleared, artifactOwned) -- 864
	local st = self:ensureRehearsal("mock") -- 865
	st.archive.childCleared = childCleared -- 866
	st.archive.soldierCleared = soldierCleared -- 867
	if artifactOwned ~= nil then -- 868
		st.archive.artifactOwned = artifactOwned -- 869
	end -- 869
	if childCleared and soldierCleared and st.archive.museumPhase == "locked" then -- 871
		st.archive.museumPhase = "well_open" -- 872
	elseif (not childCleared or not soldierCleared) and st.archive.museumPhase == "well_open" then -- 873
		st.archive.museumPhase = "locked" -- 874
	end -- 874
end -- 864
function DualRouteContract.prototype.enterMockMuseum(self, phase) -- 878
	local st = self:ensureRehearsal("mock") -- 879
	st.archive.museumPhase = phase -- 880
	if phase == "done" then -- 881
		st.archive.museumSeen = true -- 882
	end -- 882
	if phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" or phase == "done" then -- 885
		st.archive.artifactOwned = true -- 891
	end -- 891
end -- 878
function DualRouteContract.prototype.setMockRoguelike(self, patch) -- 895
	local st = self:ensureRehearsal("mock") -- 896
	local rg = st.roguelike -- 897
	local ____patch_active_12 = patch.active -- 898
	if ____patch_active_12 == nil then -- 898
		____patch_active_12 = true -- 898
	end -- 898
	rg.active = ____patch_active_12 -- 898
	if patch.showRouteTrack ~= nil then -- 899
		rg.showRouteTrack = patch.showRouteTrack -- 899
	end -- 899
	if patch.seed ~= nil then -- 900
		rg.seed = patch.seed -- 900
	end -- 900
	if patch.ticks ~= nil then -- 901
		rg.ticks = patch.ticks -- 901
	end -- 901
	if patch.routeTag ~= nil then -- 902
		rg.routeTag = patch.routeTag -- 902
	end -- 902
	if patch.roomKey ~= nil then -- 903
		rg.roomKey = patch.roomKey -- 903
	end -- 903
	if patch.clearOffers == true then -- 904
		rg.offers = {} -- 905
	elseif patch.offers ~= nil then -- 906
		rg.offers = __TS__ArraySlice(patch.offers) -- 907
	end -- 907
	if patch.ranks ~= nil then -- 909
		rg.ranks = cloneRecordNum(patch.ranks) -- 910
	end -- 910
	if patch.supplies ~= nil then -- 912
		rg.supplies = cloneRecordNum(patch.supplies) -- 913
	end -- 913
	if patch.hp ~= nil then -- 915
		rg.hp = patch.hp -- 915
	end -- 915
	if patch.maxHp ~= nil then -- 916
		rg.maxHp = patch.maxHp -- 916
	end -- 916
	if patch.equippedWeapon ~= nil then -- 917
		rg.equippedWeapon = patch.equippedWeapon -- 917
	end -- 917
	if patch.activeReloadTicks ~= nil then -- 918
		rg.activeReloadTicks = patch.activeReloadTicks -- 918
	end -- 918
	if patch.activeInvulnTicks ~= nil then -- 919
		rg.activeInvulnTicks = patch.activeInvulnTicks -- 919
	end -- 919
	if patch.activeCraftTicks ~= nil then -- 920
		rg.activeCraftTicks = patch.activeCraftTicks -- 920
	end -- 920
	if patch.stages ~= nil then -- 921
		rg.stages = __TS__ArrayMap( -- 922
			patch.stages, -- 922
			function(____, s) return __TS__ObjectAssign({}, s) end -- 922
		) -- 922
	elseif #rg.stages == 0 then -- 923
		rg.stages = buildStageNodes(ESCORT_STAGE_SPECS, rg.roomKey ~= "" and rg.roomKey or "escort1") -- 924
	end -- 924
	if patch.talentLabelHints ~= nil then -- 926
		rg.talentLabelHints = {} -- 927
		for k in pairs(patch.talentLabelHints) do -- 928
			rg.talentLabelHints[k] = patch.talentLabelHints[k] -- 929
		end -- 929
	end -- 929
	local sum = 0 -- 932
	for k in pairs(rg.ranks) do -- 933
		sum = sum + (rg.ranks[k] or 0) -- 934
	end -- 934
	rg.totalRanks = patch.totalRanks or sum -- 936
	rg.reloadTicksNow = patch.reloadTicksNow or computeDerivedReloadTicks(rg.ranks, rg.supplies) -- 937
	rg.invulnTicksNow = patch.invulnTicksNow or computeDerivedInvulnTicks(rg.ranks) -- 938
	rg.craftTicksNow = patch.craftTicksNow or computeDerivedCraftTicks(rg.ranks) -- 939
end -- 895
function DualRouteContract.prototype.sampleLive(self, p, dt, events) -- 944
	local pRec = asRecord(p) -- 945
	local runRec = asRecord(p.run) -- 946
	local ____asRecord_14 = asRecord -- 947
	local ____temp_13 -- 947
	if runRec ~= nil then -- 947
		____temp_13 = runRec.story -- 947
	else -- 947
		____temp_13 = nil -- 947
	end -- 947
	local storyRec = ____asRecord_14(____temp_13) -- 947
	if dt > 0 and self.liveReloadInvalidFlash > 0 then -- 949
		self.liveReloadInvalidFlash = math.max(0, self.liveReloadInvalidFlash - dt) -- 950
	end -- 950
	if events ~= nil and #events.rawEvents > 0 then -- 952
		local ei = 0 -- 953
		do -- 953
			ei = 0 -- 954
			while ei < #events.rawEvents do -- 954
				local ename = events.rawEvents[ei + 1].name -- 955
				if ename == "handRelease" then -- 956
					self.liveReleasedAbortCount = self.liveReleasedAbortCount + 1 -- 957
				elseif ename == "reloadInvalid" then -- 958
					self.liveReloadInvalidFlash = 0.35 -- 959
				end -- 959
				ei = ei + 1 -- 954
			end -- 954
		end -- 954
	end -- 954
	local ____temp_17 -- 965
	if pRec ~= nil and type(pRec.storyRoute) == "string" and pRec.storyRoute ~= "" then -- 965
		____temp_17 = pRec.storyRoute -- 966
	else -- 966
		local ____temp_16 -- 967
		if storyRec ~= nil and type(storyRec.route) == "string" and storyRec.route ~= "" then -- 967
			____temp_16 = storyRec.route -- 968
		else -- 968
			local ____temp_15 -- 969
			if runRec ~= nil then -- 969
				____temp_15 = runRec.storyRoute -- 969
			else -- 969
				____temp_15 = nil -- 969
			end -- 969
			____temp_16 = ____temp_15 -- 969
		end -- 969
		____temp_17 = ____temp_16 -- 967
	end -- 967
	local rawRoute = ____temp_17 -- 965
	local storyRoute = parseStoryRoute(rawRoute) -- 970
	local countElapsedTicks = readNum(pRec, "countElapsedTicks") or p.countTick -- 973
	local countDurationTicks = math.max( -- 974
		1, -- 974
		readNum(pRec, "countDurationTicks") or GATE_COUNT_END -- 974
	) -- 974
	local countNumber = gateCountAtTick(countElapsedTicks) -- 975
	local countProgress = math.max( -- 976
		0, -- 976
		math.min(1, countElapsedTicks / countDurationTicks) -- 976
	) -- 976
	local ____asRecord_19 = asRecord -- 979
	local ____temp_18 -- 979
	if pRec ~= nil then -- 979
		____temp_18 = pRec.gateReunion -- 979
	else -- 979
		____temp_18 = nil -- 979
	end -- 979
	local grRec = ____asRecord_19(____temp_18) -- 979
	local flatHold = readNum(pRec, "gateHoldProgress") -- 980
	local inGateWaitOrHand = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand") -- 981
	local handTicks = readNum(pRec, "handTicks") or 0 -- 982
	local handNeedTicks = math.max( -- 983
		1, -- 983
		readNum(pRec, "handNeedTicks") or 36 -- 983
	) -- 983
	local handTied = p.room.key == "gate" and p.phase == "gate-hand" -- 984
	local derivedHoldProg = handTied and 1 or (inGateWaitOrHand and math.max( -- 985
		0, -- 985
		math.min(1, handTicks / handNeedTicks) -- 985
	) or 0) -- 985
	local ____readBool_result_20 = readBool(grRec, "active") -- 987
	if ____readBool_result_20 == nil then -- 987
		____readBool_result_20 = inGateWaitOrHand -- 987
	end -- 987
	local ____readBool_result_21 = readBool(grRec, "knockHeard") -- 988
	if ____readBool_result_21 == nil then -- 988
		____readBool_result_21 = inGateWaitOrHand and p.knocks >= 1 -- 988
	end -- 988
	local ____math_max_result_24 = math.max( -- 989
		0, -- 989
		math.min( -- 989
			1, -- 989
			readNum(grRec, "holdProgress") or flatHold or derivedHoldProg -- 989
		) -- 989
	) -- 989
	local ____readBool_result_22 = readBool(grRec, "holding") -- 990
	if ____readBool_result_22 == nil then -- 990
		____readBool_result_22 = inGateWaitOrHand and not handTied and handTicks > 0 -- 990
	end -- 990
	local ____readBool_result_23 = readBool(grRec, "completed") -- 991
	if ____readBool_result_23 == nil then -- 991
		____readBool_result_23 = handTied -- 991
	end -- 991
	local gateReunion = { -- 986
		active = ____readBool_result_20, -- 987
		knockHeard = ____readBool_result_21, -- 988
		holdProgress = ____math_max_result_24, -- 989
		holding = ____readBool_result_22, -- 990
		completed = ____readBool_result_23, -- 991
		releasedAbortCount = readNum(grRec, "releasedAbortCount") or self.liveReleasedAbortCount -- 992
	} -- 992
	local ____asRecord_26 = asRecord -- 996
	local ____temp_25 -- 996
	if pRec ~= nil then -- 996
		____temp_25 = pRec.backCarry -- 996
	else -- 996
		____temp_25 = nil -- 996
	end -- 996
	local bcRec = ____asRecord_26(____temp_25) -- 996
	local ____asRecord_28 = asRecord -- 997
	local ____temp_27 -- 997
	if pRec ~= nil then -- 997
		____temp_27 = pRec.craftBench -- 997
	else -- 997
		____temp_27 = nil -- 997
	end -- 997
	local cbRecEarly = ____asRecord_28(____temp_27) -- 997
	local ____readBool_result_29 = readBool(cbRecEarly, "active") -- 998
	if ____readBool_result_29 == nil then -- 998
		____readBool_result_29 = false -- 998
	end -- 998
	local benchActiveLive = ____readBool_result_29 -- 998
	local ____readBool_result_30 = readBool(pRec, "carryOn") -- 999
	if ____readBool_result_30 == nil then -- 999
		____readBool_result_30 = readBool(storyRec, "carry") -- 999
	end -- 999
	local ____readBool_result_30_31 = ____readBool_result_30 -- 999
	if ____readBool_result_30_31 == nil then -- 999
		____readBool_result_30_31 = false -- 999
	end -- 999
	local carryOn = ____readBool_result_30_31 -- 999
	local handInHandLive = handTied or p.room.key == "gatepath" and not carryOn -- 1000
	local ____readBool_result_32 = readBool(bcRec, "active") -- 1002
	if ____readBool_result_32 == nil then -- 1002
		____readBool_result_32 = carryOn -- 1002
	end -- 1002
	local ____readBool_result_33 = readBool(bcRec, "handInHand") -- 1003
	if ____readBool_result_33 == nil then -- 1003
		____readBool_result_33 = handInHandLive -- 1003
	end -- 1003
	local ____readBool_result_34 = readBool(bcRec, "mounting") -- 1004
	if ____readBool_result_34 == nil then -- 1004
		____readBool_result_34 = p.room.key == "gatepath" and carryOn -- 1004
	end -- 1004
	local ____readBool_result_35 = readBool(bcRec, "atBench") -- 1005
	if ____readBool_result_35 == nil then -- 1005
		____readBool_result_35 = benchActiveLive -- 1005
	end -- 1005
	local backCarry = {active = ____readBool_result_32, handInHand = ____readBool_result_33, mounting = ____readBool_result_34, atBench = ____readBool_result_35} -- 1001
	local ____asRecord_37 = asRecord -- 1009
	local ____temp_36 -- 1009
	if pRec ~= nil then -- 1009
		____temp_36 = pRec.reloadSession -- 1009
	else -- 1009
		____temp_36 = nil -- 1009
	end -- 1009
	local rsRec = ____asRecord_37(____temp_36) -- 1009
	local ____readBool_result_38 = readBool(pRec, "reloadOpen") -- 1010
	if ____readBool_result_38 == nil then -- 1010
		____readBool_result_38 = false -- 1010
	end -- 1010
	local reloadOpenLive = ____readBool_result_38 -- 1010
	local ____readBool_result_39 = readBool(rsRec, "active") -- 1011
	if ____readBool_result_39 == nil then -- 1011
		____readBool_result_39 = reloadOpenLive -- 1011
	end -- 1011
	local reloadActive = ____readBool_result_39 -- 1011
	local reloadAnswerTicks = readNum(pRec, "reloadAnswerTicks") or 0 -- 1012
	local reloadTryCount = readNum(pRec, "reloadTryCount") or 0 -- 1013
	local livePath = readNumArray(rsRec, "path") or readNumArray(pRec, "reloadPath") or ({}) -- 1014
	local ____temp_42 -- 1015
	if rsRec ~= nil and rsRec.nextEffect ~= nil then -- 1015
		____temp_42 = rsRec.nextEffect -- 1016
	else -- 1016
		local ____temp_41 -- 1017
		if pRec ~= nil and pRec.reloadPendingEffect ~= nil then -- 1017
			____temp_41 = pRec.reloadPendingEffect -- 1018
		else -- 1018
			local ____temp_40 -- 1019
			if pRec ~= nil then -- 1019
				____temp_40 = pRec.nextEffect -- 1019
			else -- 1019
				____temp_40 = nil -- 1019
			end -- 1019
			____temp_41 = ____temp_40 -- 1019
		end -- 1019
		____temp_42 = ____temp_41 -- 1017
	end -- 1017
	local liveNextRaw = ____temp_42 -- 1015
	local livePreview = rsRec ~= nil and rsRec.previewEffect ~= nil and parseReloadEffect(rsRec.previewEffect) or (reloadActive and deriveReloadEffectFromPath(livePath) or "normal") -- 1020
	local ____readBool_result_43 = readBool(rsRec, "firstTime") -- 1026
	if ____readBool_result_43 == nil then -- 1026
		____readBool_result_43 = reloadTryCount <= 1 -- 1026
	end -- 1026
	local reloadSession = { -- 1024
		active = reloadActive, -- 1025
		firstTime = ____readBool_result_43, -- 1026
		elapsed = readNum(rsRec, "elapsed") or reloadAnswerTicks / 60, -- 1027
		duration = math.max( -- 1028
			0.01, -- 1028
			readNum(rsRec, "duration") or DEFAULT_RELOAD_DURATION -- 1028
		), -- 1028
		path = livePath, -- 1029
		previewEffect = livePreview, -- 1030
		nextEffect = parseReloadEffect(liveNextRaw), -- 1031
		invalidFlash = readNum(rsRec, "invalidFlash") or self.liveReloadInvalidFlash -- 1032
	} -- 1032
	local rawScale = readNum(pRec, "timeScale") or readNum(runRec, "timeScale") -- 1035
	local baseScale = rawScale ~= nil and rawScale >= 0 and rawScale or (reloadActive and DEFAULT_SLOW_TIME_SCALE or 1) -- 1036
	local timeScale = math.min(baseScale, self.liveFocusTimeScale) -- 1039
	local ____asRecord_45 = asRecord -- 1042
	local ____temp_44 -- 1042
	if pRec ~= nil then -- 1042
		____temp_44 = pRec.craftBench -- 1042
	else -- 1042
		____temp_44 = nil -- 1042
	end -- 1042
	local cbRec = ____asRecord_45(____temp_44) -- 1042
	local craftBench = self:readLiveCraftBench(cbRec, pRec, runRec) -- 1043
	local archive = self:readLiveArchive(p) -- 1046
	self.liveArchiveCache = archive -- 1047
	local roguelike = self:readLiveRoguelike(p, pRec, runRec, storyRec) -- 1050
	local visualMode = deriveVisualMode( -- 1052
		p.room.key, -- 1053
		p.phase, -- 1054
		storyRoute, -- 1055
		"locked", -- 1056
		countProgress, -- 1057
		gateReunion.completed -- 1058
	) -- 1058
	return { -- 1061
		storyRoute = storyRoute, -- 1062
		countElapsedTicks = countElapsedTicks, -- 1063
		countDurationTicks = countDurationTicks, -- 1064
		countNumber = countNumber, -- 1065
		countProgress = countProgress, -- 1066
		gateReunion = gateReunion, -- 1067
		backCarry = backCarry, -- 1068
		timeScale = timeScale, -- 1069
		reloadSession = reloadSession, -- 1070
		craftBench = craftBench, -- 1071
		archive = archive, -- 1072
		roguelike = roguelike, -- 1073
		assistHintsEnabled = self.assistHintsEnabled, -- 1074
		visualMode = visualMode, -- 1075
		dataSource = "live", -- 1076
		isRehearsal = false, -- 1077
		rehearsalTag = "" -- 1078
	} -- 1078
end -- 944
function DualRouteContract.prototype.readLiveRoguelike(self, p, pRec, runRec, storyRec) -- 1082
	local roomKey = p.room.key -- 1088
	local isEscort = (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 -- 1089
	local ____opt_46 = p.room.campaign -- 1090
	local campChapter = ____opt_46 and ____opt_46.chapter -- 1090
	local isCampaignRun = p.isCampaign and (campChapter == "S" or campChapter == "C") -- 1091
	local rawOffers = p:getStoryTalentOffers() -- 1093
	local offers = {} -- 1094
	local i = 0 -- 1095
	do -- 1095
		i = 0 -- 1096
		while i < #rawOffers do -- 1096
			offers[#offers + 1] = rawOffers[i + 1] -- 1097
			i = i + 1 -- 1096
		end -- 1096
	end -- 1096
	if #offers == 0 and p.run.trial ~= nil and #p.run.trial.offers > 0 then -- 1099
		do -- 1099
			i = 0 -- 1100
			while i < #p.run.trial.offers do -- 1100
				offers[#offers + 1] = p.run.trial.offers[i + 1] -- 1101
				i = i + 1 -- 1100
			end -- 1100
		end -- 1100
	end -- 1100
	local ranks = {vitality = 0, reload = 0, guard = 0, craft = 0} -- 1105
	local storyRanks = p:getStoryTalentRanks() -- 1106
	local ____asRecord_52 = asRecord -- 1107
	local ____asRecord_51 = asRecord -- 1107
	local ____temp_50 -- 1107
	if storyRec ~= nil then -- 1107
		____temp_50 = storyRec.talents -- 1107
	else -- 1107
		____temp_50 = nil -- 1107
	end -- 1107
	local ____opt_48 = ____asRecord_51(____temp_50) -- 1107
	local fallbackStoryRanks = ____asRecord_52(____opt_48 and ____opt_48.ranks) -- 1107
	local srcRanks = storyRanks ~= nil and storyRanks or (p.run.trial ~= nil and p.run.trial.ranks or fallbackStoryRanks) -- 1108
	local totalRanks = 0 -- 1113
	if srcRanks ~= nil then -- 1114
		for k in pairs(srcRanks) do -- 1115
			local v = srcRanks[k] -- 1116
			if type(v) == "number" and v > 0 then -- 1117
				ranks[k] = v -- 1118
				totalRanks = totalRanks + v -- 1119
			end -- 1119
		end -- 1119
	end -- 1119
	local inv = p.run.inventory -- 1124
	local supplies = { -- 1125
		wood = inv.wood or 0, -- 1126
		bell = inv.bell or 0, -- 1127
		shield = inv.shield or 0, -- 1128
		wedge = inv.wedge or 0, -- 1129
		ammo = inv.ammo or 0, -- 1130
		scrap = inv.scrap or 0, -- 1131
		pass = inv.pass or 0, -- 1132
		quickbelt = inv.quickbelt or 0 -- 1133
	} -- 1133
	local ____asRecord_54 = asRecord -- 1136
	local ____temp_53 -- 1136
	if storyRec ~= nil then -- 1136
		____temp_53 = storyRec.segments -- 1136
	else -- 1136
		____temp_53 = nil -- 1136
	end -- 1136
	local clearedSegs = ____asRecord_54(____temp_53) -- 1136
	local stages = {} -- 1137
	local showRouteTrack = false -- 1138
	if isEscort then -- 1139
		stages = buildStageNodes(ESCORT_STAGE_SPECS, roomKey, clearedSegs) -- 1140
		showRouteTrack = true -- 1141
	elseif isCampaignRun then -- 1142
		stages = buildStageNodes(CAMPAIGN_STAGE_SPECS, roomKey) -- 1143
		showRouteTrack = true -- 1144
	end -- 1144
	local explicitActive = readBool(pRec, "roguelikeActive") == true or readBool(runRec, "roguelikeActive") == true -- 1147
	local active = explicitActive or isEscort or isCampaignRun or #offers > 0 or totalRanks > 0 -- 1149
	local talentLabelHints = {} -- 1151
	local ____asRecord_56 = asRecord -- 1152
	local ____temp_55 -- 1152
	if pRec ~= nil then -- 1152
		____temp_55 = pRec.talentMeta -- 1152
	else -- 1152
		____temp_55 = nil -- 1152
	end -- 1152
	local ____asRecord_56_result_59 = ____asRecord_56(____temp_55) -- 1152
	if ____asRecord_56_result_59 == nil then -- 1152
		local ____asRecord_58 = asRecord -- 1153
		local ____temp_57 -- 1153
		if runRec ~= nil then -- 1153
			____temp_57 = runRec.talentMeta -- 1153
		else -- 1153
			____temp_57 = nil -- 1153
		end -- 1153
		____asRecord_56_result_59 = ____asRecord_58(____temp_57) -- 1152
	end -- 1152
	local rawMeta = ____asRecord_56_result_59 -- 1152
	if rawMeta ~= nil then -- 1154
		for k in pairs(rawMeta) do -- 1155
			local v = rawMeta[k] -- 1156
			if type(v) == "string" then -- 1157
				talentLabelHints[k] = v -- 1158
			else -- 1158
				local obj = asRecord(v) -- 1160
				local n = readStr(obj, "name") -- 1161
				local d = readStr(obj, "desc") -- 1162
				if n ~= nil then -- 1163
					talentLabelHints[k] = d ~= nil and d ~= "" and (n .. "·") .. d or n -- 1164
				end -- 1164
			end -- 1164
		end -- 1164
	end -- 1164
	local reloadTicksNow = computeDerivedReloadTicks(ranks, supplies) -- 1170
	local invulnTicksNow = computeDerivedInvulnTicks(ranks) -- 1171
	local craftTicksNow = computeDerivedCraftTicks(ranks) -- 1172
	return { -- 1174
		active = active, -- 1175
		showRouteTrack = showRouteTrack, -- 1176
		seed = p.run.seed, -- 1177
		ticks = p.run.ticks, -- 1178
		routeTag = p.run.route, -- 1179
		roomKey = roomKey, -- 1180
		offers = offers, -- 1181
		ranks = ranks, -- 1182
		totalRanks = totalRanks, -- 1183
		hp = p.hp, -- 1184
		maxHp = p.maxHp, -- 1185
		reloadTicksNow = reloadTicksNow, -- 1186
		invulnTicksNow = invulnTicksNow, -- 1187
		craftTicksNow = craftTicksNow, -- 1188
		activeReloadTicks = readNum(pRec, "reloadT") or 0, -- 1189
		activeInvulnTicks = readNum(pRec, "invulnT") or 0, -- 1190
		activeCraftTicks = readNum(pRec, "craftT") or 0, -- 1191
		equippedWeapon = p.equippedWeapon ~= "" and p.equippedWeapon or "standard_gun", -- 1192
		supplies = supplies, -- 1193
		stages = stages, -- 1194
		talentLabelHints = talentLabelHints -- 1195
	} -- 1195
end -- 1082
function DualRouteContract.prototype.readLiveCraftBench(self, cbRec, pRec, runRec) -- 1199
	local recipes = defaultRecipes() -- 1204
	if cbRec ~= nil and __TS__ArrayIsArray(cbRec.recipes) then -- 1205
		local rawList = cbRec.recipes -- 1206
		local parsed = {} -- 1207
		local i = 0 -- 1208
		do -- 1208
			i = 0 -- 1209
			while i < #rawList do -- 1209
				do -- 1209
					local item = asRecord(rawList[i + 1]) -- 1210
					if item == nil then -- 1211
						goto __continue185 -- 1212
					end -- 1212
					local id = readStr(item, "id") -- 1214
					local name = readStr(item, "name") -- 1215
					if id == nil or name == nil then -- 1216
						goto __continue185 -- 1217
					end -- 1217
					local ____id_61 = id -- 1220
					local ____name_62 = name -- 1221
					local ____temp_63 = readStr(item, "desc") or "" -- 1222
					local ____parseReloadEffect_result_64 = parseReloadEffect(item.enhancedEffect) -- 1223
					local ____temp_65 = readNumMap(item, "cost") or ({}) -- 1224
					local ____readBool_result_60 = readBool(item, "crafted") -- 1225
					if ____readBool_result_60 == nil then -- 1225
						____readBool_result_60 = false -- 1225
					end -- 1225
					parsed[#parsed + 1] = { -- 1219
						id = ____id_61, -- 1220
						name = ____name_62, -- 1221
						desc = ____temp_63, -- 1222
						enhancedEffect = ____parseReloadEffect_result_64, -- 1223
						cost = ____temp_65, -- 1224
						crafted = ____readBool_result_60 -- 1225
					} -- 1225
				end -- 1225
				::__continue185:: -- 1225
				i = i + 1 -- 1209
			end -- 1209
		end -- 1209
		if #parsed > 0 then -- 1228
			local ____readBool_result_66 = readBool(cbRec, "active") -- 1230
			if ____readBool_result_66 == nil then -- 1230
				____readBool_result_66 = false -- 1230
			end -- 1230
			local ____readBool_result_67 = readBool(cbRec, "firstCraftDone") -- 1231
			if ____readBool_result_67 == nil then -- 1231
				____readBool_result_67 = false -- 1231
			end -- 1231
			return { -- 1229
				active = ____readBool_result_66, -- 1230
				firstCraftDone = ____readBool_result_67, -- 1231
				justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 1232
				inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or ({}), -- 1233
				recipes = parsed, -- 1234
				equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 1235
			} -- 1235
		end -- 1235
	end -- 1235
	local ____readBool_result_68 = readBool(cbRec, "active") -- 1240
	if ____readBool_result_68 == nil then -- 1240
		____readBool_result_68 = false -- 1240
	end -- 1240
	local ____readBool_result_69 = readBool(cbRec, "firstCraftDone") -- 1241
	if ____readBool_result_69 == nil then -- 1241
		____readBool_result_69 = false -- 1241
	end -- 1241
	return { -- 1239
		active = ____readBool_result_68, -- 1240
		firstCraftDone = ____readBool_result_69, -- 1241
		justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 1242
		inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or readNumMap(runRec, "craftInventory") or ({}), -- 1243
		recipes = recipes, -- 1244
		equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 1245
	} -- 1245
end -- 1199
function DualRouteContract.prototype.readLiveArchive(self, p) -- 1249
	local pRec = asRecord(p) -- 1250
	local runRec = asRecord(p.run) -- 1251
	local ____asRecord_71 = asRecord -- 1252
	local ____temp_70 -- 1252
	if pRec ~= nil then -- 1252
		____temp_70 = pRec.archive -- 1252
	else -- 1252
		____temp_70 = nil -- 1252
	end -- 1252
	local ____asRecord_71_result_74 = ____asRecord_71(____temp_70) -- 1252
	if ____asRecord_71_result_74 == nil then -- 1252
		local ____asRecord_73 = asRecord -- 1253
		local ____temp_72 -- 1253
		if runRec ~= nil then -- 1253
			____temp_72 = runRec.archive -- 1253
		else -- 1253
			____temp_72 = nil -- 1253
		end -- 1253
		____asRecord_71_result_74 = ____asRecord_73(____temp_72) -- 1252
	end -- 1252
	local archRec = ____asRecord_71_result_74 -- 1252
	local ____readBool_result_75 = readBool(archRec, "childCleared") -- 1255
	if ____readBool_result_75 == nil then -- 1255
		____readBool_result_75 = readBool(pRec, "childCleared") -- 1255
	end -- 1255
	local ____readBool_result_75_76 = ____readBool_result_75 -- 1255
	if ____readBool_result_75_76 == nil then -- 1255
		____readBool_result_75_76 = false -- 1255
	end -- 1255
	local childCleared = ____readBool_result_75_76 -- 1255
	local ____readBool_result_77 = readBool(archRec, "soldierCleared") -- 1256
	if ____readBool_result_77 == nil then -- 1256
		____readBool_result_77 = readBool(pRec, "soldierCleared") -- 1256
	end -- 1256
	local ____readBool_result_77_78 = ____readBool_result_77 -- 1256
	if ____readBool_result_77_78 == nil then -- 1256
		____readBool_result_77_78 = false -- 1256
	end -- 1256
	local soldierCleared = ____readBool_result_77_78 -- 1256
	local ____readBool_result_79 = readBool(archRec, "artifactOwned") -- 1257
	if ____readBool_result_79 == nil then -- 1257
		____readBool_result_79 = readBool(pRec, "artifactOwned") -- 1257
	end -- 1257
	local ____readBool_result_79_80 = ____readBool_result_79 -- 1257
	if ____readBool_result_79_80 == nil then -- 1257
		____readBool_result_79_80 = false -- 1257
	end -- 1257
	local artifactOwned = ____readBool_result_79_80 -- 1257
	local ____temp_82 -- 1258
	if archRec ~= nil and archRec.museumPhase ~= nil then -- 1258
		____temp_82 = archRec.museumPhase -- 1259
	else -- 1259
		local ____temp_81 -- 1260
		if pRec ~= nil then -- 1260
			____temp_81 = pRec.museumPhase -- 1260
		else -- 1260
			____temp_81 = nil -- 1260
		end -- 1260
		____temp_82 = ____temp_81 -- 1260
	end -- 1260
	local rawPhase = ____temp_82 -- 1258
	local museumPhase = parseMuseumPhase(rawPhase) -- 1261
	local ____readBool_result_83 = readBool(archRec, "museumSeen") -- 1262
	if ____readBool_result_83 == nil then -- 1262
		____readBool_result_83 = readBool(pRec, "museumSeen") -- 1262
	end -- 1262
	local ____readBool_result_83_84 = ____readBool_result_83 -- 1262
	if ____readBool_result_83_84 == nil then -- 1262
		____readBool_result_83_84 = false -- 1262
	end -- 1262
	local museumSeen = ____readBool_result_83_84 -- 1262
	local livePhase = p.phase -- 1271
	if p.room.key == "museum" then -- 1272
		if livePhase == "museum-cabinet" then -- 1273
			museumPhase = museumPhase == "well_reflect" and "well_reflect" or "hall_walk" -- 1274
		elseif livePhase == "museum-hall" or livePhase == "museum-lamp" then -- 1275
			museumPhase = "hall_walk" -- 1276
		elseif livePhase == "museum-return" then -- 1277
			museumPhase = "lamp_turn" -- 1278
		elseif livePhase == "museum-knock" or livePhase == "museum-done" then -- 1279
			museumPhase = "return_cabinet" -- 1280
		end -- 1280
	elseif p.room.key == "prologue" and museumPhase == "locked" and childCleared and soldierCleared and not museumSeen then -- 1282
		local backendWellOpen = readBool(pRec, "wellOpen") == true -- 1283
		local hasBackendWell = readNum(pRec, "wellX") ~= nil -- 1284
		if backendWellOpen or livePhase == "prologue-well" or artifactOwned and hasBackendWell then -- 1285
			museumPhase = "well_open" -- 1286
		end -- 1286
	end -- 1286
	return { -- 1290
		childCleared = childCleared, -- 1291
		soldierCleared = soldierCleared, -- 1292
		artifactOwned = artifactOwned, -- 1293
		museumPhase = museumPhase, -- 1294
		museumSeen = museumSeen -- 1295
	} -- 1295
end -- 1249
function DualRouteContract.prototype.forwardLiveIntent(self, p, intent) -- 1299
	if intent.kind == "craftSubmit" then -- 1300
		if self.livePendingCraftRequests[intent.requestId] == true then -- 1301
			return false -- 1302
		end -- 1302
		self.livePendingCraftRequests[intent.requestId] = true -- 1304
	end -- 1304
	local pRec = asRecord(p) -- 1306
	if pRec == nil then -- 1307
		return false -- 1308
	end -- 1308
	local handler = pRec.submitFeIntent -- 1310
	if type(handler) == "function" then -- 1311
		local fn = handler -- 1312
		local result = fn(p, intent) -- 1313
		if result ~= false then -- 1314
			return true -- 1315
		end -- 1315
		if intent.kind == "museumInteract" and intent.target == "well_pickup" then -- 1318
			local wellRes = fn(p, {kind = "wellPick"}) -- 1319
			return wellRes ~= false -- 1320
		end -- 1320
		return false -- 1322
	end -- 1322
	if intent.kind == "chooseTalent" then -- 1324
		local choose = pRec.chooseTalent -- 1325
		if type(choose) == "function" then -- 1326
			return choose(p, intent.slot) == true -- 1327
		end -- 1327
	end -- 1327
	local tapNode = pRec.reloadTapNode -- 1331
	if type(tapNode) == "function" then -- 1332
		local fn = tapNode -- 1333
		if intent.kind == "reloadTapNode" then -- 1334
			fn(p, intent.node) -- 1335
			return true -- 1336
		end -- 1336
		if intent.kind == "reloadPathCommit" and #intent.path > 0 then -- 1338
			local i = 0 -- 1339
			do -- 1339
				i = 0 -- 1340
				while i < #intent.path do -- 1340
					do -- 1340
						if i == 0 and intent.path[i + 1] == 0 then -- 1341
							goto __continue210 -- 1342
						end -- 1342
						fn(p, intent.path[i + 1]) -- 1344
					end -- 1344
					::__continue210:: -- 1344
					i = i + 1 -- 1340
				end -- 1340
			end -- 1340
			return true -- 1346
		end -- 1346
	end -- 1346
	return false -- 1349
end -- 1299
function DualRouteContract.prototype.sampleRehearsal(self, p, dt, input, st) -- 1354
	local countElapsedTicks = st.countTickOverride ~= nil and st.countTickOverride or p.countTick -- 1355
	local countDurationTicks = math.max(1, st.countDurationOverride or GATE_COUNT_END) -- 1356
	local countNumber = gateCountAtTick(countElapsedTicks) -- 1357
	local countProgress = math.max( -- 1358
		0, -- 1358
		math.min(1, countElapsedTicks / countDurationTicks) -- 1358
	) -- 1358
	if p.room.key == "gate" and p.phase == "gate-count" and st.storyRoute == "soldier" then -- 1361
		if countElapsedTicks < countDurationTicks then -- 1362
			st.gateReunion.active = false -- 1363
			st.gateReunion.knockHeard = false -- 1364
			st.gateReunion.holding = false -- 1365
			st.gateReunion.holdProgress = 0 -- 1366
			st.gateHoldArmed = not input.interact.held -- 1367
			st.gatePrevInteractHeld = input.interact.held -- 1368
		elseif not st.gateReunion.completed then -- 1369
			st.gateReunion.active = true -- 1370
			st.gateReunion.knockHeard = true -- 1371
			if not st.gateHoldArmed and not input.interact.held then -- 1372
				st.gateHoldArmed = true -- 1373
			end -- 1373
			if dt > 0 then -- 1375
				if st.gateHoldArmed and input.interact.held then -- 1376
					st.gateReunion.holding = true -- 1377
					st.gateReunion.holdProgress = math.min(1, st.gateReunion.holdProgress + dt / GATE_REUNION_HOLD_SECONDS) -- 1378
					if st.gateReunion.holdProgress >= 1 then -- 1382
						st.gateReunion.holdProgress = 1 -- 1383
						st.gateReunion.holding = false -- 1384
						st.gateReunion.completed = true -- 1385
						st.backCarry.handInHand = true -- 1386
					end -- 1386
				else -- 1386
					if st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1389
						local ____st_gateReunion_85, ____releasedAbortCount_86 = st.gateReunion, "releasedAbortCount" -- 1390
						____st_gateReunion_85[____releasedAbortCount_86] = ____st_gateReunion_85[____releasedAbortCount_86] + 1 -- 1390
					end -- 1390
					st.gateReunion.holding = false -- 1392
					st.gateReunion.holdProgress = 0 -- 1393
				end -- 1393
			end -- 1393
			st.gatePrevInteractHeld = input.interact.held -- 1396
		end -- 1396
	end -- 1396
	if st.reloadSession.active and dt > 0 then -- 1401
		local ____st_reloadSession_87, ____elapsed_88 = st.reloadSession, "elapsed" -- 1402
		____st_reloadSession_87[____elapsed_88] = ____st_reloadSession_87[____elapsed_88] + dt -- 1402
		if st.reloadSession.invalidFlash > 0 then -- 1403
			st.reloadSession.invalidFlash = math.max(0, st.reloadSession.invalidFlash - dt) -- 1404
		end -- 1404
		if st.reloadSession.elapsed >= st.reloadSession.duration then -- 1406
			st.reloadSession.active = false -- 1407
			st.reloadSession.elapsed = 0 -- 1408
			st.reloadSession.path = {} -- 1409
			st.reloadSession.previewEffect = "normal" -- 1410
			st.reloadSession.nextEffect = "normal" -- 1411
			st.reloadSession.firstTime = false -- 1412
			st.timeScaleOverride = nil -- 1413
		end -- 1413
	end -- 1413
	if st.craftBench.justCraftedTimer > 0 and dt > 0 then -- 1418
		st.craftBench.justCraftedTimer = math.max(0, st.craftBench.justCraftedTimer - dt) -- 1419
	end -- 1419
	local baseScale = st.timeScaleOverride ~= nil and math.max(0, st.timeScaleOverride) or (st.reloadSession.active and DEFAULT_SLOW_TIME_SCALE or 1) -- 1422
	local timeScale = st.timeScaleOverride ~= nil and baseScale or math.min(baseScale, self.liveFocusTimeScale) -- 1425
	local visualMode = deriveVisualMode( -- 1429
		p.room.key, -- 1430
		p.phase, -- 1431
		st.storyRoute, -- 1432
		st.archive.museumPhase, -- 1433
		countProgress, -- 1434
		st.gateReunion.completed -- 1435
	) -- 1435
	return { -- 1438
		storyRoute = st.storyRoute, -- 1439
		countElapsedTicks = countElapsedTicks, -- 1440
		countDurationTicks = countDurationTicks, -- 1441
		countNumber = countNumber, -- 1442
		countProgress = countProgress, -- 1443
		gateReunion = { -- 1444
			active = st.gateReunion.active, -- 1445
			knockHeard = st.gateReunion.knockHeard, -- 1446
			holdProgress = st.gateReunion.holdProgress, -- 1447
			holding = st.gateReunion.holding, -- 1448
			completed = st.gateReunion.completed, -- 1449
			releasedAbortCount = st.gateReunion.releasedAbortCount -- 1450
		}, -- 1450
		backCarry = {active = st.backCarry.active, handInHand = st.backCarry.handInHand, mounting = st.backCarry.mounting, atBench = st.backCarry.atBench}, -- 1452
		timeScale = timeScale, -- 1458
		reloadSession = { -- 1459
			active = st.reloadSession.active, -- 1460
			firstTime = st.reloadSession.firstTime, -- 1461
			elapsed = st.reloadSession.elapsed, -- 1462
			duration = st.reloadSession.duration, -- 1463
			path = __TS__ArraySlice(st.reloadSession.path), -- 1464
			previewEffect = st.reloadSession.previewEffect, -- 1465
			nextEffect = st.reloadSession.nextEffect, -- 1466
			invalidFlash = st.reloadSession.invalidFlash -- 1467
		}, -- 1467
		craftBench = { -- 1469
			active = st.craftBench.active, -- 1470
			firstCraftDone = st.craftBench.firstCraftDone, -- 1471
			justCraftedTimer = st.craftBench.justCraftedTimer, -- 1472
			inventory = cloneRecordNum(st.craftBench.inventory), -- 1473
			recipes = cloneRecipes(st.craftBench.recipes), -- 1474
			equippedWeapon = st.craftBench.equippedWeapon -- 1475
		}, -- 1475
		archive = { -- 1477
			childCleared = st.archive.childCleared, -- 1478
			soldierCleared = st.archive.soldierCleared, -- 1479
			artifactOwned = st.archive.artifactOwned, -- 1480
			museumPhase = st.archive.museumPhase, -- 1481
			museumSeen = st.archive.museumSeen -- 1482
		}, -- 1482
		roguelike = cloneRoguelike(st.roguelike), -- 1484
		assistHintsEnabled = self.assistHintsEnabled, -- 1485
		visualMode = visualMode, -- 1486
		dataSource = "rehearsal", -- 1487
		isRehearsal = true, -- 1488
		rehearsalTag = st.tag -- 1489
	} -- 1489
end -- 1354
function DualRouteContract.prototype.applyRehearsalIntent(self, st, intent) -- 1493
	if intent.kind == "gateReunionHold" then -- 1494
		if not st.gateReunion.active or st.gateReunion.completed then -- 1495
			return false -- 1496
		end -- 1496
		if not intent.holding and st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1498
			local ____st_gateReunion_89, ____releasedAbortCount_90 = st.gateReunion, "releasedAbortCount" -- 1499
			____st_gateReunion_89[____releasedAbortCount_90] = ____st_gateReunion_89[____releasedAbortCount_90] + 1 -- 1499
			st.gateReunion.holdProgress = 0 -- 1500
		end -- 1500
		st.gateReunion.holding = intent.holding -- 1502
		return true -- 1503
	end -- 1503
	if intent.kind == "reloadOpen" then -- 1505
		self:triggerMockReload(true) -- 1506
		return true -- 1507
	end -- 1507
	if intent.kind == "reloadTapNode" then -- 1509
		if not st.reloadSession.active then -- 1510
			return false -- 1511
		end -- 1511
		if #st.reloadSession.path == 0 then -- 1513
			local ____st_reloadSession_path_91 = st.reloadSession.path -- 1514
			____st_reloadSession_path_91[#____st_reloadSession_path_91 + 1] = 0 -- 1514
		end -- 1514
		if __TS__ArrayIndexOf(st.reloadSession.path, intent.node) >= 0 then -- 1516
			st.reloadSession.invalidFlash = 0.35 -- 1517
			st.reloadSession.path = {0} -- 1518
			st.reloadSession.previewEffect = "normal" -- 1519
			return false -- 1520
		end -- 1520
		local ____st_reloadSession_path_92 = st.reloadSession.path -- 1522
		____st_reloadSession_path_92[#____st_reloadSession_path_92 + 1] = intent.node -- 1522
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(st.reloadSession.path) -- 1523
		if intent.node == 8 then -- 1524
			st.reloadSession.nextEffect = st.reloadSession.previewEffect -- 1525
			st.reloadSession.active = false -- 1526
			st.reloadSession.elapsed = 0 -- 1527
			st.reloadSession.path = {} -- 1528
			st.reloadSession.firstTime = false -- 1529
			st.timeScaleOverride = nil -- 1530
		end -- 1530
		return true -- 1532
	end -- 1532
	if intent.kind == "reloadPathPreview" then -- 1534
		if not st.reloadSession.active then -- 1535
			return false -- 1536
		end -- 1536
		st.reloadSession.path = __TS__ArraySlice(intent.path) -- 1538
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(intent.path) -- 1539
		return true -- 1540
	end -- 1540
	if intent.kind == "reloadPathCommit" then -- 1542
		if not st.reloadSession.active then -- 1543
			return false -- 1544
		end -- 1544
		if #intent.path < 2 then -- 1546
			st.reloadSession.invalidFlash = 0.35 -- 1547
			st.reloadSession.path = {} -- 1548
			st.reloadSession.previewEffect = "normal" -- 1549
			return false -- 1550
		end -- 1550
		local effect = deriveReloadEffectFromPath(intent.path) -- 1552
		st.reloadSession.nextEffect = effect -- 1553
		st.reloadSession.previewEffect = effect -- 1554
		st.reloadSession.path = {} -- 1555
		st.reloadSession.active = false -- 1556
		st.reloadSession.elapsed = 0 -- 1557
		st.reloadSession.firstTime = false -- 1558
		st.timeScaleOverride = nil -- 1559
		return true -- 1560
	end -- 1560
	if intent.kind == "reloadCancel" then -- 1562
		st.reloadSession.active = false -- 1563
		st.reloadSession.elapsed = 0 -- 1564
		st.reloadSession.path = {} -- 1565
		st.reloadSession.previewEffect = "normal" -- 1566
		st.timeScaleOverride = nil -- 1567
		return true -- 1568
	end -- 1568
	if intent.kind == "craftSubmit" then -- 1570
		if not st.craftBench.active or st.handledCraftRequestIds[intent.requestId] == true then -- 1571
			return false -- 1572
		end -- 1572
		local target -- 1574
		local i = 0 -- 1575
		do -- 1575
			i = 0 -- 1576
			while i < #st.craftBench.recipes do -- 1576
				if st.craftBench.recipes[i + 1].id == intent.recipeId then -- 1577
					target = st.craftBench.recipes[i + 1] -- 1578
					break -- 1579
				end -- 1579
				i = i + 1 -- 1576
			end -- 1576
		end -- 1576
		if target == nil or target.crafted then -- 1582
			return false -- 1583
		end -- 1583
		for mat in pairs(target.cost) do -- 1585
			if (st.craftBench.inventory[mat] or 0) < target.cost[mat] then -- 1586
				return false -- 1587
			end -- 1587
		end -- 1587
		for mat in pairs(target.cost) do -- 1590
			st.craftBench.inventory[mat] = (st.craftBench.inventory[mat] or 0) - target.cost[mat] -- 1591
		end -- 1591
		st.handledCraftRequestIds[intent.requestId] = true -- 1593
		target.crafted = true -- 1594
		st.craftBench.equippedWeapon = target.id -- 1595
		st.craftBench.justCraftedTimer = st.craftBench.firstCraftDone and 0.45 or 1 -- 1596
		st.craftBench.firstCraftDone = true -- 1597
		return true -- 1598
	end -- 1598
	if intent.kind == "craftEquip" then -- 1600
		st.craftBench.equippedWeapon = intent.weaponId -- 1601
		return true -- 1602
	end -- 1602
	if intent.kind == "craftClose" then -- 1604
		st.craftBench.active = false -- 1605
		st.backCarry.atBench = false -- 1606
		return true -- 1607
	end -- 1607
	if intent.kind == "museumInteract" then -- 1609
		if intent.target == "well_pickup" and st.archive.museumPhase == "well_open" then -- 1610
			st.archive.artifactOwned = true -- 1611
			st.archive.museumPhase = "well_reflect" -- 1612
			return true -- 1613
		end -- 1613
		if intent.target == "enter_hall" and st.archive.museumPhase == "well_reflect" then -- 1615
			st.archive.museumPhase = "hall_walk" -- 1616
			return true -- 1617
		end -- 1617
		if intent.target == "lamp_turn" and st.archive.museumPhase == "hall_walk" then -- 1619
			st.archive.museumPhase = "lamp_turn" -- 1620
			return true -- 1621
		end -- 1621
		if intent.target == "begin_return_cabinet" and st.archive.museumPhase == "lamp_turn" then -- 1623
			st.archive.museumPhase = "return_cabinet" -- 1624
			return true -- 1625
		end -- 1625
		if intent.target == "return_cabinet" then -- 1627
			st.archive.museumPhase = "done" -- 1628
			st.archive.museumSeen = true -- 1629
			return true -- 1630
		end -- 1630
		return false -- 1632
	end -- 1632
	if intent.kind == "chooseTalent" then -- 1634
		local rg = st.roguelike -- 1635
		local id = rg.offers[intent.slot + 1] -- 1636
		if id == nil then -- 1637
			return false -- 1638
		end -- 1638
		rg.ranks[id] = (rg.ranks[id] or 0) + 1 -- 1640
		rg.totalRanks = rg.totalRanks + 1 -- 1641
		if id == "vitality" then -- 1642
			rg.maxHp = rg.maxHp + 1 -- 1643
			rg.hp = rg.hp + 1 -- 1644
		end -- 1644
		rg.offers = {} -- 1646
		rg.reloadTicksNow = computeDerivedReloadTicks(rg.ranks, rg.supplies) -- 1647
		rg.invulnTicksNow = computeDerivedInvulnTicks(rg.ranks) -- 1648
		rg.craftTicksNow = computeDerivedCraftTicks(rg.ranks) -- 1649
		return true -- 1650
	end -- 1650
	return false -- 1652
end -- 1493
return ____exports -- 1493
