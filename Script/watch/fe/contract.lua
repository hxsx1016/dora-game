-- [ts]: contract.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local cloneRecordNum -- 1
local ____play = require("Script.watch.play") -- 20
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 20
local gateCountAtTick = ____play.gateCountAtTick -- 20
function cloneRecordNum(src) -- 351
	local out = {} -- 352
	for k in pairs(src) do -- 353
		out[k] = src[k] -- 354
	end -- 354
	return out -- 356
end -- 356
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
	return base -- 220
end -- 218
local function computeDerivedInvulnTicks(ranks) -- 223
	return BASE_INVULN_HIT_TICKS + 15 * (ranks.guard or 0) -- 224
end -- 223
local function computeDerivedCraftTicks(ranks) -- 227
	return math.max(6, BASE_CRAFT_TICKS - 6 * (ranks.salvage or 0)) -- 228
end -- 227
local function buildStageNodes(specs, currentRoomKey, clearedMap) -- 231
	local curIdx = -1 -- 236
	local i = 0 -- 237
	do -- 237
		i = 0 -- 238
		while i < #specs do -- 238
			if specs[i + 1].key == currentRoomKey then -- 238
				curIdx = i -- 240
				break -- 241
			end -- 241
			i = i + 1 -- 238
		end -- 238
	end -- 238
	local out = {} -- 244
	do -- 244
		i = 0 -- 245
		while i < #specs do -- 245
			local sp = specs[i + 1] -- 246
			local byMap = clearedMap ~= nil and clearedMap[sp.key] == true -- 247
			local cleared = byMap or curIdx >= 0 and i < curIdx -- 248
			out[#out + 1] = { -- 249
				key = sp.key, -- 250
				label = sp.label, -- 251
				isBench = sp.isBench, -- 252
				isFinal = sp.isFinal, -- 253
				cleared = cleared, -- 254
				current = sp.key == currentRoomKey -- 255
			} -- 255
			i = i + 1 -- 245
		end -- 245
	end -- 245
	return out -- 258
end -- 231
local function createEmptyRoguelike() -- 261
	return { -- 262
		active = false, -- 263
		showRouteTrack = false, -- 264
		seed = 0, -- 265
		ticks = 0, -- 266
		routeTag = "", -- 267
		roomKey = "", -- 268
		offers = {}, -- 269
		ranks = {vitality = 0, reload = 0, guard = 0, craft = 0}, -- 270
		totalRanks = 0, -- 271
		hp = 3, -- 272
		maxHp = 3, -- 273
		reloadTicksNow = 54, -- 274
		invulnTicksNow = BASE_INVULN_HIT_TICKS, -- 275
		craftTicksNow = BASE_CRAFT_TICKS, -- 276
		activeReloadTicks = 0, -- 277
		activeInvulnTicks = 0, -- 278
		activeCraftTicks = 0, -- 279
		equippedWeapon = "standard_gun", -- 280
		supplies = {}, -- 281
		stages = {}, -- 282
		talentLabelHints = {} -- 283
	} -- 283
end -- 261
local function cloneRoguelike(src) -- 287
	local stages = {} -- 288
	local i = 0 -- 289
	do -- 289
		i = 0 -- 290
		while i < #src.stages do -- 290
			local s = src.stages[i + 1] -- 291
			stages[#stages + 1] = { -- 292
				key = s.key, -- 293
				label = s.label, -- 294
				isBench = s.isBench, -- 295
				isFinal = s.isFinal, -- 296
				cleared = s.cleared, -- 297
				current = s.current -- 298
			} -- 298
			i = i + 1 -- 290
		end -- 290
	end -- 290
	local hints = {} -- 301
	for k in pairs(src.talentLabelHints) do -- 302
		hints[k] = src.talentLabelHints[k] -- 303
	end -- 303
	return { -- 305
		active = src.active, -- 306
		showRouteTrack = src.showRouteTrack, -- 307
		seed = src.seed, -- 308
		ticks = src.ticks, -- 309
		routeTag = src.routeTag, -- 310
		roomKey = src.roomKey, -- 311
		offers = __TS__ArraySlice(src.offers), -- 312
		ranks = cloneRecordNum(src.ranks), -- 313
		totalRanks = src.totalRanks, -- 314
		hp = src.hp, -- 315
		maxHp = src.maxHp, -- 316
		reloadTicksNow = src.reloadTicksNow, -- 317
		invulnTicksNow = src.invulnTicksNow, -- 318
		craftTicksNow = src.craftTicksNow, -- 319
		activeReloadTicks = src.activeReloadTicks, -- 320
		activeInvulnTicks = src.activeInvulnTicks, -- 321
		activeCraftTicks = src.activeCraftTicks, -- 322
		equippedWeapon = src.equippedWeapon, -- 323
		supplies = cloneRecordNum(src.supplies), -- 324
		stages = stages, -- 325
		talentLabelHints = hints -- 326
	} -- 326
end -- 287
local function defaultRecipes() -- 330
	return {{ -- 331
		id = "guide_lantern_gun", -- 333
		name = "引路灯铳", -- 334
		desc = "以两枚木纹筹改制，增强灯纹照亮范围与余明", -- 335
		enhancedEffect = "light", -- 336
		cost = {wood_tally = 2}, -- 337
		crafted = false -- 338
	}, { -- 338
		id = "echo_gun", -- 341
		name = "回声铳", -- 342
		desc = "以一枚木纹筹与一枚铃纹筹改制，增强铃纹回声诱导", -- 343
		enhancedEffect = "echo", -- 344
		cost = {wood_tally = 1, bell_tally = 1}, -- 345
		crafted = false -- 346
	}} -- 346
end -- 330
local function cloneRecipes(list) -- 359
	local out = {} -- 360
	local i = 0 -- 361
	do -- 361
		i = 0 -- 362
		while i < #list do -- 362
			local r = list[i + 1] -- 363
			out[#out + 1] = { -- 364
				id = r.id, -- 365
				name = r.name, -- 366
				desc = r.desc, -- 367
				enhancedEffect = r.enhancedEffect, -- 368
				cost = cloneRecordNum(r.cost), -- 369
				crafted = r.crafted -- 370
			} -- 370
			i = i + 1 -- 362
		end -- 362
	end -- 362
	return out -- 373
end -- 359
local function createEmptyGateReunion() -- 376
	return { -- 377
		active = false, -- 378
		knockHeard = false, -- 379
		holdProgress = 0, -- 380
		holding = false, -- 381
		completed = false, -- 382
		releasedAbortCount = 0 -- 383
	} -- 383
end -- 376
local function createEmptyBackCarry() -- 387
	return {active = false, handInHand = false, mounting = false, atBench = false} -- 388
end -- 387
local function createEmptyReloadSession() -- 396
	return { -- 397
		active = false, -- 398
		firstTime = true, -- 399
		elapsed = 0, -- 400
		duration = DEFAULT_RELOAD_DURATION, -- 401
		path = {}, -- 402
		previewEffect = "normal", -- 403
		nextEffect = "normal", -- 404
		invalidFlash = 0 -- 405
	} -- 405
end -- 396
local function createEmptyCraftBench() -- 409
	return { -- 410
		active = false, -- 411
		firstCraftDone = false, -- 412
		justCraftedTimer = 0, -- 413
		inventory = {}, -- 414
		recipes = defaultRecipes(), -- 415
		equippedWeapon = "standard_gun" -- 416
	} -- 416
end -- 409
local function createEmptyArchive() -- 420
	return { -- 421
		childCleared = false, -- 422
		soldierCleared = false, -- 423
		artifactOwned = false, -- 424
		museumPhase = "locked", -- 425
		museumSeen = false -- 426
	} -- 426
end -- 420
local function createInitialRehearsalState(tag) -- 430
	local bench = createEmptyCraftBench() -- 431
	bench.inventory = {wood_tally = 2, bell_tally = 1} -- 432
	return { -- 433
		tag = tag, -- 434
		storyRoute = "undecided", -- 435
		countTickOverride = nil, -- 436
		countDurationOverride = nil, -- 437
		timeScaleOverride = nil, -- 438
		gateReunion = createEmptyGateReunion(), -- 439
		gateHoldArmed = true, -- 440
		gatePrevInteractHeld = false, -- 441
		backCarry = createEmptyBackCarry(), -- 442
		reloadSession = createEmptyReloadSession(), -- 443
		craftBench = bench, -- 444
		archive = createEmptyArchive(), -- 445
		roguelike = createEmptyRoguelike(), -- 446
		handledCraftRequestIds = {} -- 447
	} -- 447
end -- 430
local function asRecord(value) -- 451
	if value ~= nil and type(value) == "table" then -- 451
		return value -- 453
	end -- 453
	return nil -- 455
end -- 451
local function readNum(rec, key) -- 458
	if rec == nil then -- 458
		return nil -- 460
	end -- 460
	local v = rec[key] -- 462
	return type(v) == "number" and v or nil -- 463
end -- 458
local function readBool(rec, key) -- 466
	if rec == nil then -- 466
		return nil -- 468
	end -- 468
	local v = rec[key] -- 470
	local ____temp_0 -- 471
	if type(v) == "boolean" then -- 471
		____temp_0 = v -- 471
	else -- 471
		____temp_0 = nil -- 471
	end -- 471
	return ____temp_0 -- 471
end -- 466
local function readStr(rec, key) -- 474
	if rec == nil then -- 474
		return nil -- 476
	end -- 476
	local v = rec[key] -- 478
	return type(v) == "string" and v or nil -- 479
end -- 474
local function readNumArray(rec, key) -- 482
	if rec == nil then -- 482
		return nil -- 484
	end -- 484
	local v = rec[key] -- 486
	if not __TS__ArrayIsArray(v) then -- 486
		return nil -- 488
	end -- 488
	local out = {} -- 490
	local i = 0 -- 491
	do -- 491
		i = 0 -- 492
		while i < #v do -- 492
			if type(v[i + 1]) == "number" then -- 492
				out[#out + 1] = v[i + 1] -- 494
			end -- 494
			i = i + 1 -- 492
		end -- 492
	end -- 492
	return out -- 497
end -- 482
local function readNumMap(rec, key) -- 500
	if rec == nil then -- 500
		return nil -- 502
	end -- 502
	local obj = asRecord(rec[key]) -- 504
	if obj == nil then -- 504
		return nil -- 506
	end -- 506
	local out = {} -- 508
	for k in pairs(obj) do -- 509
		local val = obj[k] -- 510
		if type(val) == "number" then -- 510
			out[k] = val -- 512
		end -- 512
	end -- 512
	return out -- 515
end -- 500
local function parseStoryRoute(v) -- 518
	if v == "child" or v == "soldier" then -- 518
		return v -- 520
	end -- 520
	return "undecided" -- 522
end -- 518
local function parseReloadEffect(v) -- 525
	if v == "push" or v == "knockback" then -- 525
		return "knockback" -- 527
	end -- 527
	if v == "echo" or v == "light" then -- 527
		return v -- 530
	end -- 530
	return "normal" -- 532
end -- 525
local function parseMuseumPhase(v) -- 535
	if v == "well_open" or v == "well_reflect" or v == "hall_walk" or v == "lamp_turn" or v == "return_cabinet" or v == "done" then -- 535
		return v -- 544
	end -- 544
	return "locked" -- 546
end -- 535
--- 根据 3×3 路径点集合推导效果（对齐后端 reload.ts 布局）：
-- - 0 = 左下起点，8 = 右上枪机复位终点；
-- - 4 = 中心铃纹（echo，优先），2 = 右下灯纹（light），其余有效路径 = 推退（knockback）。
local function deriveReloadEffectFromPath(path) -- 554
	if #path < 2 then -- 554
		return "normal" -- 556
	end -- 556
	local hasBell = false -- 558
	local hasLamp = false -- 559
	local i = 0 -- 560
	do -- 560
		i = 0 -- 561
		while i < #path do -- 561
			if path[i + 1] == 4 then -- 561
				hasBell = true -- 563
			elseif path[i + 1] == 2 then -- 563
				hasLamp = true -- 565
			end -- 565
			i = i + 1 -- 561
		end -- 561
	end -- 561
	if hasBell then -- 561
		return "echo" -- 569
	end -- 569
	if hasLamp then -- 569
		return "light" -- 572
	end -- 572
	return "knockback" -- 574
end -- 554
local function deriveVisualMode(roomKey, phase, storyRoute, museumPhase, countProgress, reunionCompleted) -- 577
	if roomKey == "museum" or museumPhase == "well_reflect" or museumPhase == "hall_walk" or museumPhase == "lamp_turn" or museumPhase == "return_cabinet" then -- 577
		return "museum" -- 592
	end -- 592
	if roomKey == "gate" then -- 592
		if phase == "gate-hand" then -- 592
			return "pixel" -- 596
		end -- 596
		if phase == "gate-wait" then -- 596
			return reunionCompleted and "pixel" or "lowpoly" -- 599
		end -- 599
		if phase == "gate-count" then -- 599
			if storyRoute == "soldier" and reunionCompleted then -- 599
				return "pixel" -- 603
			end -- 603
			if countProgress <= 0 then -- 603
				return "pixel" -- 606
			end -- 606
			if countProgress >= 1 then -- 606
				return "lowpoly" -- 609
			end -- 609
			return "transition" -- 611
		end -- 611
		if phase == "gate-walk" then -- 611
			return storyRoute == "soldier" and "pixel" or (storyRoute == "child" and "lowpoly" or "pixel") -- 614
		end -- 614
		return "pixel" -- 616
	end -- 616
	if roomKey == "gatepath" or roomKey == "escort1" or roomKey == "escort2" or roomKey == "escort3" or roomKey == "escort4" or roomKey == "escort5" then -- 616
		return "pixel" -- 620
	end -- 620
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" then -- 620
		if storyRoute == "child" then -- 620
			return "lowpoly" -- 624
		end -- 624
		return "pixel" -- 626
	end -- 626
	return "pixel" -- 628
end -- 577
____exports.DualRouteContract = __TS__Class() -- 631
local DualRouteContract = ____exports.DualRouteContract -- 631
DualRouteContract.name = "DualRouteContract" -- 631
function DualRouteContract.prototype.____constructor(self, canPickTalent) -- 646
	self.canPickTalent = canPickTalent -- 646
	self.source = "live" -- 632
	self.assistHintsEnabled = false -- 635
	self.livePendingCraftRequests = {} -- 637
	self.liveReleasedAbortCount = 0 -- 639
	self.liveReloadInvalidFlash = 0 -- 640
	self.liveFocusTimeScale = 1 -- 641
	self.liveArchiveCache = createEmptyArchive() -- 642
	self.intentLog = {} -- 643
end -- 646
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
	if self.rehearsal == nil then -- 660
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
	if self.source ~= "rehearsal" or self.rehearsal == nil then -- 684
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
	if self.rehearsal ~= nil then -- 736
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
	local allowed = intent.kind ~= "chooseTalent" or self.canPickTalent == nil or self.canPickTalent(p) -- 770
	local ____allowed_2 = allowed -- 771
	if ____allowed_2 then -- 771
		local ____temp_1 -- 771
		if self.source == "rehearsal" and self.rehearsal ~= nil then -- 771
			____temp_1 = self:applyRehearsalIntent(self.rehearsal, intent) -- 772
		else -- 772
			____temp_1 = self:forwardLiveIntent(p, intent) -- 773
		end -- 773
		____allowed_2 = ____temp_1 -- 771
	end -- 771
	local accepted = ____allowed_2 -- 771
	local ____self_intentLog_3 = self.intentLog -- 771
	____self_intentLog_3[#____self_intentLog_3 + 1] = {tick = p.ticks, source = self.source, intent = intent, accepted = accepted} -- 774
	if #self.intentLog > MAX_INTENT_LOG then -- 774
		table.remove(self.intentLog, 1) -- 781
	end -- 781
	return accepted -- 783
end -- 769
function DualRouteContract.prototype.setMockRoute(self, route) -- 788
	local st = self:ensureRehearsal("mock") -- 789
	st.storyRoute = route -- 790
end -- 788
function DualRouteContract.prototype.setMockCountTick(self, tick, duration) -- 793
	local st = self:ensureRehearsal("mock") -- 794
	st.countTickOverride = tick -- 795
	if duration ~= nil and duration > 0 then -- 795
		st.countDurationOverride = duration -- 797
	end -- 797
end -- 793
function DualRouteContract.prototype.setMockTimeScale(self, scale) -- 801
	local st = self:ensureRehearsal("mock") -- 802
	st.timeScaleOverride = scale -- 803
end -- 801
function DualRouteContract.prototype.setMockGateReunion(self, patch) -- 806
	local st = self:ensureRehearsal("mock") -- 807
	if patch.active ~= nil then -- 807
		st.gateReunion.active = patch.active -- 808
	end -- 808
	if patch.knockHeard ~= nil then -- 808
		st.gateReunion.knockHeard = patch.knockHeard -- 809
	end -- 809
	if patch.holdProgress ~= nil then -- 809
		st.gateReunion.holdProgress = math.max( -- 810
			0, -- 810
			math.min(1, patch.holdProgress) -- 810
		) -- 810
	end -- 810
	if patch.holding ~= nil then -- 810
		st.gateReunion.holding = patch.holding -- 811
	end -- 811
	if patch.completed ~= nil then -- 811
		st.gateReunion.completed = patch.completed -- 812
	end -- 812
	if patch.releasedAbortCount ~= nil then -- 812
		st.gateReunion.releasedAbortCount = patch.releasedAbortCount -- 813
	end -- 813
end -- 806
function DualRouteContract.prototype.setMockBackCarry(self, patch) -- 816
	local st = self:ensureRehearsal("mock") -- 817
	if patch.active ~= nil then -- 817
		st.backCarry.active = patch.active -- 818
	end -- 818
	if patch.handInHand ~= nil then -- 818
		st.backCarry.handInHand = patch.handInHand -- 819
	end -- 819
	if patch.mounting ~= nil then -- 819
		st.backCarry.mounting = patch.mounting -- 820
	end -- 820
	if patch.atBench ~= nil then -- 820
		st.backCarry.atBench = patch.atBench -- 821
	end -- 821
end -- 816
function DualRouteContract.prototype.triggerMockReload(self, active, options) -- 824
	local st = self:ensureRehearsal("mock") -- 828
	st.reloadSession.active = active -- 829
	if active then -- 829
		st.reloadSession.elapsed = 0 -- 831
		st.reloadSession.duration = options and options.duration or DEFAULT_RELOAD_DURATION -- 832
		st.reloadSession.path = {} -- 833
		st.reloadSession.previewEffect = "normal" -- 834
		st.reloadSession.invalidFlash = 0 -- 835
		if (options and options.firstTime) ~= nil then -- 835
			st.reloadSession.firstTime = options.firstTime -- 837
		end -- 837
		st.timeScaleOverride = options and options.slowTimeScale or DEFAULT_SLOW_TIME_SCALE -- 839
	else -- 839
		st.reloadSession.elapsed = 0 -- 841
		st.reloadSession.path = {} -- 842
		st.timeScaleOverride = nil -- 843
	end -- 843
end -- 824
function DualRouteContract.prototype.triggerMockBench(self, active, options) -- 847
	local st = self:ensureRehearsal("mock") -- 851
	st.craftBench.active = active -- 852
	st.backCarry.atBench = active -- 853
	if (options and options.inventory) ~= nil then -- 853
		st.craftBench.inventory = cloneRecordNum(options.inventory) -- 855
	end -- 855
	if (options and options.equippedWeapon) ~= nil then -- 855
		st.craftBench.equippedWeapon = options.equippedWeapon -- 858
	end -- 858
end -- 847
function DualRouteContract.prototype.setMockArchive(self, childCleared, soldierCleared, artifactOwned) -- 862
	local st = self:ensureRehearsal("mock") -- 863
	st.archive.childCleared = childCleared -- 864
	st.archive.soldierCleared = soldierCleared -- 865
	if artifactOwned ~= nil then -- 865
		st.archive.artifactOwned = artifactOwned -- 867
	end -- 867
	if childCleared and soldierCleared and st.archive.museumPhase == "locked" then -- 867
		st.archive.museumPhase = "well_open" -- 870
	elseif (not childCleared or not soldierCleared) and st.archive.museumPhase == "well_open" then -- 870
		st.archive.museumPhase = "locked" -- 872
	end -- 872
end -- 862
function DualRouteContract.prototype.enterMockMuseum(self, phase) -- 876
	local st = self:ensureRehearsal("mock") -- 877
	st.archive.museumPhase = phase -- 878
	if phase == "done" then -- 878
		st.archive.museumSeen = true -- 880
	end -- 880
	if phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" or phase == "done" then -- 880
		st.archive.artifactOwned = true -- 889
	end -- 889
end -- 876
function DualRouteContract.prototype.setMockRoguelike(self, patch) -- 893
	local st = self:ensureRehearsal("mock") -- 894
	local rg = st.roguelike -- 895
	local ____patch_active_14 = patch.active -- 896
	if ____patch_active_14 == nil then -- 896
		____patch_active_14 = true -- 896
	end -- 896
	rg.active = ____patch_active_14 -- 896
	if patch.showRouteTrack ~= nil then -- 896
		rg.showRouteTrack = patch.showRouteTrack -- 897
	end -- 897
	if patch.seed ~= nil then -- 897
		rg.seed = patch.seed -- 898
	end -- 898
	if patch.ticks ~= nil then -- 898
		rg.ticks = patch.ticks -- 899
	end -- 899
	if patch.routeTag ~= nil then -- 899
		rg.routeTag = patch.routeTag -- 900
	end -- 900
	if patch.roomKey ~= nil then -- 900
		rg.roomKey = patch.roomKey -- 901
	end -- 901
	if patch.clearOffers == true then -- 901
		rg.offers = {} -- 903
	elseif patch.offers ~= nil then -- 903
		rg.offers = __TS__ArraySlice(patch.offers) -- 905
	end -- 905
	if patch.ranks ~= nil then -- 905
		rg.ranks = cloneRecordNum(patch.ranks) -- 908
	end -- 908
	if patch.supplies ~= nil then -- 908
		rg.supplies = cloneRecordNum(patch.supplies) -- 911
	end -- 911
	if patch.hp ~= nil then -- 911
		rg.hp = patch.hp -- 913
	end -- 913
	if patch.maxHp ~= nil then -- 913
		rg.maxHp = patch.maxHp -- 914
	end -- 914
	if patch.equippedWeapon ~= nil then -- 914
		rg.equippedWeapon = patch.equippedWeapon -- 915
	end -- 915
	if patch.activeReloadTicks ~= nil then -- 915
		rg.activeReloadTicks = patch.activeReloadTicks -- 916
	end -- 916
	if patch.activeInvulnTicks ~= nil then -- 916
		rg.activeInvulnTicks = patch.activeInvulnTicks -- 917
	end -- 917
	if patch.activeCraftTicks ~= nil then -- 917
		rg.activeCraftTicks = patch.activeCraftTicks -- 918
	end -- 918
	if patch.stages ~= nil then -- 918
		rg.stages = __TS__ArrayMap( -- 920
			patch.stages, -- 920
			function(____, s) return __TS__ObjectAssign({}, s) end -- 920
		) -- 920
	elseif #rg.stages == 0 then -- 920
		rg.stages = buildStageNodes(ESCORT_STAGE_SPECS, rg.roomKey ~= "" and rg.roomKey or "escort1") -- 922
	end -- 922
	if patch.talentLabelHints ~= nil then -- 922
		rg.talentLabelHints = {} -- 925
		for k in pairs(patch.talentLabelHints) do -- 926
			rg.talentLabelHints[k] = patch.talentLabelHints[k] -- 927
		end -- 927
	end -- 927
	local sum = 0 -- 930
	for k in pairs(rg.ranks) do -- 931
		sum = sum + (rg.ranks[k] or 0) -- 932
	end -- 932
	rg.totalRanks = patch.totalRanks or sum -- 934
	rg.reloadTicksNow = patch.reloadTicksNow or computeDerivedReloadTicks(rg.ranks, rg.supplies) -- 935
	rg.invulnTicksNow = patch.invulnTicksNow or computeDerivedInvulnTicks(rg.ranks) -- 936
	rg.craftTicksNow = patch.craftTicksNow or computeDerivedCraftTicks(rg.ranks) -- 937
end -- 893
function DualRouteContract.prototype.sampleLive(self, p, dt, events) -- 942
	local pRec = asRecord(p) -- 943
	local runRec = asRecord(p.run) -- 944
	local ____asRecord_16 = asRecord -- 945
	local ____temp_15 -- 945
	if runRec ~= nil then -- 945
		____temp_15 = runRec.story -- 945
	else -- 945
		____temp_15 = nil -- 945
	end -- 945
	local storyRec = ____asRecord_16(____temp_15) -- 945
	if dt > 0 and self.liveReloadInvalidFlash > 0 then -- 945
		self.liveReloadInvalidFlash = math.max(0, self.liveReloadInvalidFlash - dt) -- 948
	end -- 948
	if events ~= nil and #events.rawEvents > 0 then -- 948
		local ei = 0 -- 951
		do -- 951
			ei = 0 -- 952
			while ei < #events.rawEvents do -- 952
				local ename = events.rawEvents[ei + 1].name -- 953
				if ename == "handRelease" then -- 953
					self.liveReleasedAbortCount = self.liveReleasedAbortCount + 1 -- 955
				elseif ename == "reloadInvalid" then -- 955
					self.liveReloadInvalidFlash = 0.35 -- 957
				end -- 957
				ei = ei + 1 -- 952
			end -- 952
		end -- 952
	end -- 952
	local ____temp_19 -- 963
	if pRec ~= nil and type(pRec.storyRoute) == "string" and pRec.storyRoute ~= "" then -- 963
		____temp_19 = pRec.storyRoute -- 964
	else -- 964
		local ____temp_18 -- 965
		if storyRec ~= nil and type(storyRec.route) == "string" and storyRec.route ~= "" then -- 965
			____temp_18 = storyRec.route -- 966
		else -- 966
			local ____temp_17 -- 967
			if runRec ~= nil then -- 967
				____temp_17 = runRec.storyRoute -- 967
			else -- 967
				____temp_17 = nil -- 967
			end -- 967
			____temp_18 = ____temp_17 -- 967
		end -- 967
		____temp_19 = ____temp_18 -- 965
	end -- 965
	local rawRoute = ____temp_19 -- 963
	local storyRoute = parseStoryRoute(rawRoute) -- 968
	local countElapsedTicks = readNum(pRec, "countElapsedTicks") or p.countTick -- 971
	local countDurationTicks = math.max( -- 972
		1, -- 972
		readNum(pRec, "countDurationTicks") or GATE_COUNT_END -- 972
	) -- 972
	local countNumber = gateCountAtTick(countElapsedTicks) -- 973
	local countProgress = math.max( -- 974
		0, -- 974
		math.min(1, countElapsedTicks / countDurationTicks) -- 974
	) -- 974
	local ____asRecord_21 = asRecord -- 977
	local ____temp_20 -- 977
	if pRec ~= nil then -- 977
		____temp_20 = pRec.gateReunion -- 977
	else -- 977
		____temp_20 = nil -- 977
	end -- 977
	local grRec = ____asRecord_21(____temp_20) -- 977
	local flatHold = readNum(pRec, "gateHoldProgress") -- 978
	local inGateWaitOrHand = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand") -- 979
	local handTicks = readNum(pRec, "handTicks") or 0 -- 980
	local handNeedTicks = math.max( -- 981
		1, -- 981
		readNum(pRec, "handNeedTicks") or 36 -- 981
	) -- 981
	local handTied = p.room.key == "gate" and p.phase == "gate-hand" -- 982
	local derivedHoldProg = handTied and 1 or (inGateWaitOrHand and math.max( -- 983
		0, -- 983
		math.min(1, handTicks / handNeedTicks) -- 983
	) or 0) -- 983
	local ____readBool_result_22 = readBool(grRec, "active") -- 985
	if ____readBool_result_22 == nil then -- 985
		____readBool_result_22 = inGateWaitOrHand -- 985
	end -- 985
	local ____readBool_result_23 = readBool(grRec, "knockHeard") -- 986
	if ____readBool_result_23 == nil then -- 986
		____readBool_result_23 = inGateWaitOrHand and p.knocks >= 1 -- 986
	end -- 986
	local ____math_max_result_26 = math.max( -- 987
		0, -- 987
		math.min( -- 987
			1, -- 987
			readNum(grRec, "holdProgress") or flatHold or derivedHoldProg -- 987
		) -- 987
	) -- 987
	local ____readBool_result_24 = readBool(grRec, "holding") -- 988
	if ____readBool_result_24 == nil then -- 988
		____readBool_result_24 = inGateWaitOrHand and not handTied and handTicks > 0 -- 988
	end -- 988
	local ____readBool_result_25 = readBool(grRec, "completed") -- 989
	if ____readBool_result_25 == nil then -- 989
		____readBool_result_25 = handTied -- 989
	end -- 989
	local gateReunion = { -- 984
		active = ____readBool_result_22, -- 985
		knockHeard = ____readBool_result_23, -- 986
		holdProgress = ____math_max_result_26, -- 987
		holding = ____readBool_result_24, -- 988
		completed = ____readBool_result_25, -- 989
		releasedAbortCount = readNum(grRec, "releasedAbortCount") or self.liveReleasedAbortCount -- 990
	} -- 990
	local ____asRecord_28 = asRecord -- 994
	local ____temp_27 -- 994
	if pRec ~= nil then -- 994
		____temp_27 = pRec.backCarry -- 994
	else -- 994
		____temp_27 = nil -- 994
	end -- 994
	local bcRec = ____asRecord_28(____temp_27) -- 994
	local ____asRecord_30 = asRecord -- 995
	local ____temp_29 -- 995
	if pRec ~= nil then -- 995
		____temp_29 = pRec.craftBench -- 995
	else -- 995
		____temp_29 = nil -- 995
	end -- 995
	local cbRecEarly = ____asRecord_30(____temp_29) -- 995
	local ____readBool_result_31 = readBool(cbRecEarly, "active") -- 996
	if ____readBool_result_31 == nil then -- 996
		____readBool_result_31 = false -- 996
	end -- 996
	local benchActiveLive = ____readBool_result_31 -- 996
	local ____readBool_result_32 = readBool(pRec, "carryOn") -- 997
	if ____readBool_result_32 == nil then -- 997
		____readBool_result_32 = readBool(storyRec, "carry") -- 997
	end -- 997
	local ____readBool_result_32_33 = ____readBool_result_32 -- 997
	if ____readBool_result_32_33 == nil then -- 997
		____readBool_result_32_33 = false -- 997
	end -- 997
	local carryOn = ____readBool_result_32_33 -- 997
	local handInHandLive = handTied or p.room.key == "gatepath" and not carryOn -- 998
	local ____readBool_result_34 = readBool(bcRec, "active") -- 1000
	if ____readBool_result_34 == nil then -- 1000
		____readBool_result_34 = carryOn -- 1000
	end -- 1000
	local ____readBool_result_35 = readBool(bcRec, "handInHand") -- 1001
	if ____readBool_result_35 == nil then -- 1001
		____readBool_result_35 = handInHandLive -- 1001
	end -- 1001
	local ____readBool_result_36 = readBool(bcRec, "mounting") -- 1002
	if ____readBool_result_36 == nil then -- 1002
		____readBool_result_36 = p.room.key == "gatepath" and carryOn -- 1002
	end -- 1002
	local ____readBool_result_37 = readBool(bcRec, "atBench") -- 1003
	if ____readBool_result_37 == nil then -- 1003
		____readBool_result_37 = benchActiveLive -- 1003
	end -- 1003
	local backCarry = {active = ____readBool_result_34, handInHand = ____readBool_result_35, mounting = ____readBool_result_36, atBench = ____readBool_result_37} -- 999
	local ____asRecord_39 = asRecord -- 1007
	local ____temp_38 -- 1007
	if pRec ~= nil then -- 1007
		____temp_38 = pRec.reloadSession -- 1007
	else -- 1007
		____temp_38 = nil -- 1007
	end -- 1007
	local rsRec = ____asRecord_39(____temp_38) -- 1007
	local ____readBool_result_40 = readBool(pRec, "reloadOpen") -- 1008
	if ____readBool_result_40 == nil then -- 1008
		____readBool_result_40 = false -- 1008
	end -- 1008
	local reloadOpenLive = ____readBool_result_40 -- 1008
	local ____readBool_result_41 = readBool(rsRec, "active") -- 1009
	if ____readBool_result_41 == nil then -- 1009
		____readBool_result_41 = reloadOpenLive -- 1009
	end -- 1009
	local reloadActive = ____readBool_result_41 -- 1009
	local reloadAnswerTicks = readNum(pRec, "reloadAnswerTicks") or 0 -- 1010
	local reloadTryCount = readNum(pRec, "reloadTryCount") or 0 -- 1011
	local livePath = readNumArray(rsRec, "path") or readNumArray(pRec, "reloadPath") or ({}) -- 1012
	local ____temp_44 -- 1013
	if rsRec ~= nil and rsRec.nextEffect ~= nil then -- 1013
		____temp_44 = rsRec.nextEffect -- 1014
	else -- 1014
		local ____temp_43 -- 1015
		if pRec ~= nil and pRec.reloadPendingEffect ~= nil then -- 1015
			____temp_43 = pRec.reloadPendingEffect -- 1016
		else -- 1016
			local ____temp_42 -- 1017
			if pRec ~= nil then -- 1017
				____temp_42 = pRec.nextEffect -- 1017
			else -- 1017
				____temp_42 = nil -- 1017
			end -- 1017
			____temp_43 = ____temp_42 -- 1017
		end -- 1017
		____temp_44 = ____temp_43 -- 1015
	end -- 1015
	local liveNextRaw = ____temp_44 -- 1013
	local livePreview = rsRec ~= nil and rsRec.previewEffect ~= nil and parseReloadEffect(rsRec.previewEffect) or (reloadActive and deriveReloadEffectFromPath(livePath) or "normal") -- 1018
	local ____temp_45 -- 1022
	if pRec ~= nil then -- 1022
		____temp_45 = pRec.reloadNeedTicks -- 1022
	else -- 1022
		____temp_45 = nil -- 1022
	end -- 1022
	local needTicksFn = ____temp_45 -- 1022
	local liveReloadDuration = type(needTicksFn) == "function" and math.max( -- 1023
		0.5, -- 1024
		needTicksFn(p) / 60 -- 1024
	) or DEFAULT_RELOAD_DURATION -- 1024
	local ____readBool_result_46 = readBool(rsRec, "firstTime") -- 1028
	if ____readBool_result_46 == nil then -- 1028
		____readBool_result_46 = reloadTryCount <= 1 -- 1028
	end -- 1028
	local reloadSession = { -- 1026
		active = reloadActive, -- 1027
		firstTime = ____readBool_result_46, -- 1028
		elapsed = readNum(rsRec, "elapsed") or reloadAnswerTicks / 60, -- 1029
		duration = math.max( -- 1030
			0.01, -- 1030
			readNum(rsRec, "duration") or liveReloadDuration -- 1030
		), -- 1030
		path = livePath, -- 1031
		previewEffect = livePreview, -- 1032
		nextEffect = parseReloadEffect(liveNextRaw), -- 1033
		invalidFlash = readNum(rsRec, "invalidFlash") or self.liveReloadInvalidFlash -- 1034
	} -- 1034
	local rawScale = readNum(pRec, "timeScale") or readNum(runRec, "timeScale") -- 1037
	local baseScale = rawScale ~= nil and rawScale >= 0 and rawScale or (reloadActive and DEFAULT_SLOW_TIME_SCALE or 1) -- 1038
	local timeScale = math.min(baseScale, self.liveFocusTimeScale) -- 1041
	local ____asRecord_48 = asRecord -- 1044
	local ____temp_47 -- 1044
	if pRec ~= nil then -- 1044
		____temp_47 = pRec.craftBench -- 1044
	else -- 1044
		____temp_47 = nil -- 1044
	end -- 1044
	local cbRec = ____asRecord_48(____temp_47) -- 1044
	local craftBench = self:readLiveCraftBench(cbRec, pRec, runRec) -- 1045
	local archive = self:readLiveArchive(p) -- 1048
	self.liveArchiveCache = archive -- 1049
	local roguelike = self:readLiveRoguelike(p, pRec, runRec, storyRec) -- 1052
	local visualMode = deriveVisualMode( -- 1054
		p.room.key, -- 1055
		p.phase, -- 1056
		storyRoute, -- 1057
		"locked", -- 1058
		countProgress, -- 1059
		gateReunion.completed -- 1060
	) -- 1060
	return { -- 1063
		storyRoute = storyRoute, -- 1064
		countElapsedTicks = countElapsedTicks, -- 1065
		countDurationTicks = countDurationTicks, -- 1066
		countNumber = countNumber, -- 1067
		countProgress = countProgress, -- 1068
		gateReunion = gateReunion, -- 1069
		backCarry = backCarry, -- 1070
		timeScale = timeScale, -- 1071
		reloadSession = reloadSession, -- 1072
		craftBench = craftBench, -- 1073
		archive = archive, -- 1074
		roguelike = roguelike, -- 1075
		assistHintsEnabled = self.assistHintsEnabled, -- 1076
		visualMode = visualMode, -- 1077
		dataSource = "live", -- 1078
		isRehearsal = false, -- 1079
		rehearsalTag = "" -- 1080
	} -- 1080
end -- 942
function DualRouteContract.prototype.readLiveRoguelike(self, p, pRec, runRec, storyRec) -- 1084
	local roomKey = p.room.key -- 1090
	local isEscort = (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 -- 1091
	local ____opt_49 = p.room.campaign -- 1091
	local campChapter = ____opt_49 and ____opt_49.chapter -- 1092
	local isCampaignRun = p.isCampaign and (campChapter == "S" or campChapter == "C") -- 1093
	local rawOffers = p:getStoryTalentOffers() -- 1095
	local offers = {} -- 1096
	local i = 0 -- 1097
	do -- 1097
		i = 0 -- 1098
		while i < #rawOffers do -- 1098
			offers[#offers + 1] = rawOffers[i + 1] -- 1099
			i = i + 1 -- 1098
		end -- 1098
	end -- 1098
	local ranks = {} -- 1101
	local srcRanks = p:getStoryTalentRanks() -- 1102
	local totalRanks = 0 -- 1103
	if srcRanks ~= nil then -- 1103
		for k in pairs(srcRanks) do -- 1105
			local v = srcRanks[k] -- 1106
			if type(v) == "number" and v > 0 then -- 1106
				ranks[k] = v -- 1108
				totalRanks = totalRanks + v -- 1109
			end -- 1109
		end -- 1109
	end -- 1109
	local inv = p.run.inventory -- 1114
	local supplies = { -- 1115
		wood = inv.wood or 0, -- 1116
		bell = inv.bell or 0, -- 1117
		shield = inv.shield or 0, -- 1118
		wedge = inv.wedge or 0, -- 1119
		ammo = inv.ammo or 0, -- 1120
		scrap = inv.scrap or 0, -- 1121
		pass = inv.pass or 0, -- 1122
		quickbelt = inv.quickbelt or 0 -- 1123
	} -- 1123
	local ____asRecord_52 = asRecord -- 1126
	local ____temp_51 -- 1126
	if storyRec ~= nil then -- 1126
		____temp_51 = storyRec.segments -- 1126
	else -- 1126
		____temp_51 = nil -- 1126
	end -- 1126
	local clearedSegs = ____asRecord_52(____temp_51) -- 1126
	local stages = {} -- 1127
	local showRouteTrack = false -- 1128
	if isEscort then -- 1128
		stages = buildStageNodes(ESCORT_STAGE_SPECS, roomKey, clearedSegs) -- 1130
		showRouteTrack = true -- 1131
	elseif isCampaignRun then -- 1131
		stages = buildStageNodes(CAMPAIGN_STAGE_SPECS, roomKey) -- 1133
		showRouteTrack = true -- 1134
	end -- 1134
	local explicitActive = readBool(pRec, "roguelikeActive") == true or readBool(runRec, "roguelikeActive") == true -- 1137
	local active = explicitActive or isEscort or isCampaignRun or #offers > 0 or totalRanks > 0 -- 1139
	local talentLabelHints = {} -- 1141
	local ____asRecord_54 = asRecord -- 1142
	local ____temp_53 -- 1142
	if pRec ~= nil then -- 1142
		____temp_53 = pRec.talentMeta -- 1142
	else -- 1142
		____temp_53 = nil -- 1142
	end -- 1142
	local ____asRecord_54_result_57 = ____asRecord_54(____temp_53) -- 1142
	if ____asRecord_54_result_57 == nil then -- 1142
		local ____asRecord_56 = asRecord -- 1143
		local ____temp_55 -- 1143
		if runRec ~= nil then -- 1143
			____temp_55 = runRec.talentMeta -- 1143
		else -- 1143
			____temp_55 = nil -- 1143
		end -- 1143
		____asRecord_54_result_57 = ____asRecord_56(____temp_55) -- 1142
	end -- 1142
	local rawMeta = ____asRecord_54_result_57 -- 1142
	if rawMeta ~= nil then -- 1142
		for k in pairs(rawMeta) do -- 1145
			local v = rawMeta[k] -- 1146
			if type(v) == "string" then -- 1146
				talentLabelHints[k] = v -- 1148
			else -- 1148
				local obj = asRecord(v) -- 1150
				local n = readStr(obj, "name") -- 1151
				local d = readStr(obj, "desc") -- 1152
				if n ~= nil then -- 1152
					talentLabelHints[k] = d ~= nil and d ~= "" and (n .. "·") .. d or n -- 1154
				end -- 1154
			end -- 1154
		end -- 1154
	end -- 1154
	local reloadTicksNow = computeDerivedReloadTicks(ranks, supplies) -- 1160
	local invulnTicksNow = computeDerivedInvulnTicks(ranks) -- 1161
	local craftTicksNow = computeDerivedCraftTicks(ranks) -- 1162
	return { -- 1164
		active = active, -- 1165
		showRouteTrack = showRouteTrack, -- 1166
		seed = p.run.seed, -- 1167
		ticks = p.run.ticks, -- 1168
		routeTag = p.run.route, -- 1169
		roomKey = roomKey, -- 1170
		offers = offers, -- 1171
		ranks = ranks, -- 1172
		totalRanks = totalRanks, -- 1173
		hp = p.hp, -- 1174
		maxHp = p.maxHp, -- 1175
		reloadTicksNow = reloadTicksNow, -- 1176
		invulnTicksNow = invulnTicksNow, -- 1177
		craftTicksNow = craftTicksNow, -- 1178
		activeReloadTicks = readNum(pRec, "reloadT") or 0, -- 1179
		activeInvulnTicks = readNum(pRec, "invulnT") or 0, -- 1180
		activeCraftTicks = readNum(pRec, "craftT") or 0, -- 1181
		equippedWeapon = p.equippedWeapon ~= "" and p.equippedWeapon or "standard_gun", -- 1182
		supplies = supplies, -- 1183
		stages = stages, -- 1184
		talentLabelHints = talentLabelHints -- 1185
	} -- 1185
end -- 1084
function DualRouteContract.prototype.readLiveCraftBench(self, cbRec, pRec, runRec) -- 1189
	local recipes = defaultRecipes() -- 1194
	if cbRec ~= nil and __TS__ArrayIsArray(cbRec.recipes) then -- 1194
		local rawList = cbRec.recipes -- 1196
		local parsed = {} -- 1197
		local i = 0 -- 1198
		do -- 1198
			i = 0 -- 1199
			while i < #rawList do -- 1199
				do -- 1199
					local item = asRecord(rawList[i + 1]) -- 1200
					if item == nil then -- 1200
						goto __continue180 -- 1202
					end -- 1202
					local id = readStr(item, "id") -- 1204
					local name = readStr(item, "name") -- 1205
					if id == nil or name == nil then -- 1205
						goto __continue180 -- 1207
					end -- 1207
					local ____id_59 = id -- 1210
					local ____name_60 = name -- 1211
					local ____temp_61 = readStr(item, "desc") or "" -- 1212
					local ____parseReloadEffect_result_62 = parseReloadEffect(item.enhancedEffect) -- 1213
					local ____temp_63 = readNumMap(item, "cost") or ({}) -- 1214
					local ____readBool_result_58 = readBool(item, "crafted") -- 1215
					if ____readBool_result_58 == nil then -- 1215
						____readBool_result_58 = false -- 1215
					end -- 1215
					parsed[#parsed + 1] = { -- 1209
						id = ____id_59, -- 1210
						name = ____name_60, -- 1211
						desc = ____temp_61, -- 1212
						enhancedEffect = ____parseReloadEffect_result_62, -- 1213
						cost = ____temp_63, -- 1214
						crafted = ____readBool_result_58 -- 1215
					} -- 1215
				end -- 1215
				::__continue180:: -- 1215
				i = i + 1 -- 1199
			end -- 1199
		end -- 1199
		if #parsed > 0 then -- 1199
			local ____readBool_result_64 = readBool(cbRec, "active") -- 1220
			if ____readBool_result_64 == nil then -- 1220
				____readBool_result_64 = false -- 1220
			end -- 1220
			local ____readBool_result_65 = readBool(cbRec, "firstCraftDone") -- 1221
			if ____readBool_result_65 == nil then -- 1221
				____readBool_result_65 = false -- 1221
			end -- 1221
			return { -- 1219
				active = ____readBool_result_64, -- 1220
				firstCraftDone = ____readBool_result_65, -- 1221
				justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 1222
				inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or ({}), -- 1223
				recipes = parsed, -- 1224
				equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 1225
			} -- 1225
		end -- 1225
	end -- 1225
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
		inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or readNumMap(runRec, "craftInventory") or ({}), -- 1233
		recipes = recipes, -- 1234
		equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 1235
	} -- 1235
end -- 1189
function DualRouteContract.prototype.readLiveArchive(self, p) -- 1239
	local pRec = asRecord(p) -- 1240
	local runRec = asRecord(p.run) -- 1241
	local ____asRecord_69 = asRecord -- 1242
	local ____temp_68 -- 1242
	if pRec ~= nil then -- 1242
		____temp_68 = pRec.archive -- 1242
	else -- 1242
		____temp_68 = nil -- 1242
	end -- 1242
	local ____asRecord_69_result_72 = ____asRecord_69(____temp_68) -- 1242
	if ____asRecord_69_result_72 == nil then -- 1242
		local ____asRecord_71 = asRecord -- 1243
		local ____temp_70 -- 1243
		if runRec ~= nil then -- 1243
			____temp_70 = runRec.archive -- 1243
		else -- 1243
			____temp_70 = nil -- 1243
		end -- 1243
		____asRecord_69_result_72 = ____asRecord_71(____temp_70) -- 1242
	end -- 1242
	local archRec = ____asRecord_69_result_72 -- 1242
	local ____readBool_result_73 = readBool(archRec, "childCleared") -- 1245
	if ____readBool_result_73 == nil then -- 1245
		____readBool_result_73 = readBool(pRec, "childCleared") -- 1245
	end -- 1245
	local ____readBool_result_73_74 = ____readBool_result_73 -- 1245
	if ____readBool_result_73_74 == nil then -- 1245
		____readBool_result_73_74 = false -- 1245
	end -- 1245
	local childCleared = ____readBool_result_73_74 -- 1245
	local ____readBool_result_75 = readBool(archRec, "soldierCleared") -- 1246
	if ____readBool_result_75 == nil then -- 1246
		____readBool_result_75 = readBool(pRec, "soldierCleared") -- 1246
	end -- 1246
	local ____readBool_result_75_76 = ____readBool_result_75 -- 1246
	if ____readBool_result_75_76 == nil then -- 1246
		____readBool_result_75_76 = false -- 1246
	end -- 1246
	local soldierCleared = ____readBool_result_75_76 -- 1246
	local ____readBool_result_77 = readBool(archRec, "artifactOwned") -- 1247
	if ____readBool_result_77 == nil then -- 1247
		____readBool_result_77 = readBool(pRec, "artifactOwned") -- 1247
	end -- 1247
	local ____readBool_result_77_78 = ____readBool_result_77 -- 1247
	if ____readBool_result_77_78 == nil then -- 1247
		____readBool_result_77_78 = false -- 1247
	end -- 1247
	local artifactOwned = ____readBool_result_77_78 -- 1247
	local ____temp_80 -- 1248
	if archRec ~= nil and archRec.museumPhase ~= nil then -- 1248
		____temp_80 = archRec.museumPhase -- 1249
	else -- 1249
		local ____temp_79 -- 1250
		if pRec ~= nil then -- 1250
			____temp_79 = pRec.museumPhase -- 1250
		else -- 1250
			____temp_79 = nil -- 1250
		end -- 1250
		____temp_80 = ____temp_79 -- 1250
	end -- 1250
	local rawPhase = ____temp_80 -- 1248
	local museumPhase = parseMuseumPhase(rawPhase) -- 1251
	local ____readBool_result_81 = readBool(archRec, "museumSeen") -- 1252
	if ____readBool_result_81 == nil then -- 1252
		____readBool_result_81 = readBool(pRec, "museumSeen") -- 1252
	end -- 1252
	local ____readBool_result_81_82 = ____readBool_result_81 -- 1252
	if ____readBool_result_81_82 == nil then -- 1252
		____readBool_result_81_82 = false -- 1252
	end -- 1252
	local museumSeen = ____readBool_result_81_82 -- 1252
	local livePhase = p.phase -- 1261
	if p.room.key == "museum" then -- 1261
		if livePhase == "museum-cabinet" then -- 1261
			museumPhase = museumPhase == "well_reflect" and "well_reflect" or "hall_walk" -- 1264
		elseif livePhase == "museum-hall" or livePhase == "museum-lamp" then -- 1264
			museumPhase = "hall_walk" -- 1266
		elseif livePhase == "museum-return" then -- 1266
			museumPhase = "lamp_turn" -- 1268
		elseif livePhase == "museum-knock" or livePhase == "museum-done" then -- 1268
			museumPhase = "return_cabinet" -- 1270
		end -- 1270
	elseif p.room.key == "prologue" and museumPhase == "locked" and childCleared and soldierCleared and not museumSeen then -- 1270
		local backendWellOpen = readBool(pRec, "wellOpen") == true -- 1273
		local hasBackendWell = readNum(pRec, "wellX") ~= nil -- 1274
		if backendWellOpen or livePhase == "prologue-well" or artifactOwned and hasBackendWell then -- 1274
			museumPhase = "well_open" -- 1276
		end -- 1276
	end -- 1276
	return { -- 1280
		childCleared = childCleared, -- 1281
		soldierCleared = soldierCleared, -- 1282
		artifactOwned = artifactOwned, -- 1283
		museumPhase = museumPhase, -- 1284
		museumSeen = museumSeen -- 1285
	} -- 1285
end -- 1239
function DualRouteContract.prototype.forwardLiveIntent(self, p, intent) -- 1289
	if intent.kind == "craftSubmit" then -- 1289
		if self.livePendingCraftRequests[intent.requestId] == true then -- 1289
			return false -- 1292
		end -- 1292
		self.livePendingCraftRequests[intent.requestId] = true -- 1294
	end -- 1294
	local pRec = asRecord(p) -- 1296
	if pRec == nil then -- 1296
		return false -- 1298
	end -- 1298
	local handler = pRec.submitFeIntent -- 1300
	if type(handler) == "function" then -- 1300
		local fn = handler -- 1302
		local result = fn(p, intent) -- 1303
		if result ~= false then -- 1303
			return true -- 1305
		end -- 1305
		if intent.kind == "museumInteract" and intent.target == "well_pickup" then -- 1305
			local wellRes = fn(p, {kind = "wellPick"}) -- 1309
			return wellRes ~= false -- 1310
		end -- 1310
		return false -- 1312
	end -- 1312
	if intent.kind == "chooseTalent" then -- 1312
		local choose = pRec.chooseTalent -- 1315
		if type(choose) == "function" then -- 1315
			return choose(p, intent.slot) == true -- 1317
		end -- 1317
	end -- 1317
	local tapNode = pRec.reloadTapNode -- 1321
	if type(tapNode) == "function" then -- 1321
		local fn = tapNode -- 1323
		if intent.kind == "reloadTapNode" then -- 1323
			fn(p, intent.node) -- 1325
			return true -- 1326
		end -- 1326
		if intent.kind == "reloadPathCommit" and #intent.path > 0 then -- 1326
			local i = 0 -- 1329
			do -- 1329
				i = 0 -- 1330
				while i < #intent.path do -- 1330
					do -- 1330
						if i == 0 and intent.path[i + 1] == 0 then -- 1330
							goto __continue205 -- 1332
						end -- 1332
						fn(p, intent.path[i + 1]) -- 1334
					end -- 1334
					::__continue205:: -- 1334
					i = i + 1 -- 1330
				end -- 1330
			end -- 1330
			return true -- 1336
		end -- 1336
	end -- 1336
	return false -- 1339
end -- 1289
function DualRouteContract.prototype.sampleRehearsal(self, p, dt, input, st) -- 1344
	local countElapsedTicks = st.countTickOverride ~= nil and st.countTickOverride or p.countTick -- 1345
	local countDurationTicks = math.max(1, st.countDurationOverride or GATE_COUNT_END) -- 1346
	local countNumber = gateCountAtTick(countElapsedTicks) -- 1347
	local countProgress = math.max( -- 1348
		0, -- 1348
		math.min(1, countElapsedTicks / countDurationTicks) -- 1348
	) -- 1348
	if p.room.key == "gate" and p.phase == "gate-count" and st.storyRoute == "soldier" then -- 1348
		if countElapsedTicks < countDurationTicks then -- 1348
			st.gateReunion.active = false -- 1353
			st.gateReunion.knockHeard = false -- 1354
			st.gateReunion.holding = false -- 1355
			st.gateReunion.holdProgress = 0 -- 1356
			st.gateHoldArmed = not input.interact.held -- 1357
			st.gatePrevInteractHeld = input.interact.held -- 1358
		elseif not st.gateReunion.completed then -- 1358
			st.gateReunion.active = true -- 1360
			st.gateReunion.knockHeard = true -- 1361
			if not st.gateHoldArmed and not input.interact.held then -- 1361
				st.gateHoldArmed = true -- 1363
			end -- 1363
			if dt > 0 then -- 1363
				if st.gateHoldArmed and input.interact.held then -- 1363
					st.gateReunion.holding = true -- 1367
					st.gateReunion.holdProgress = math.min(1, st.gateReunion.holdProgress + dt / GATE_REUNION_HOLD_SECONDS) -- 1368
					if st.gateReunion.holdProgress >= 1 then -- 1368
						st.gateReunion.holdProgress = 1 -- 1373
						st.gateReunion.holding = false -- 1374
						st.gateReunion.completed = true -- 1375
						st.backCarry.handInHand = true -- 1376
					end -- 1376
				else -- 1376
					if st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1376
						local ____st_gateReunion_83, ____releasedAbortCount_84 = st.gateReunion, "releasedAbortCount" -- 1376
						____st_gateReunion_83[____releasedAbortCount_84] = ____st_gateReunion_83[____releasedAbortCount_84] + 1 -- 1380
					end -- 1380
					st.gateReunion.holding = false -- 1382
					st.gateReunion.holdProgress = 0 -- 1383
				end -- 1383
			end -- 1383
			st.gatePrevInteractHeld = input.interact.held -- 1386
		end -- 1386
	end -- 1386
	if st.reloadSession.active and dt > 0 then -- 1386
		local ____st_reloadSession_85, ____elapsed_86 = st.reloadSession, "elapsed" -- 1386
		____st_reloadSession_85[____elapsed_86] = ____st_reloadSession_85[____elapsed_86] + dt -- 1392
		if st.reloadSession.invalidFlash > 0 then -- 1392
			st.reloadSession.invalidFlash = math.max(0, st.reloadSession.invalidFlash - dt) -- 1394
		end -- 1394
		if st.reloadSession.elapsed >= st.reloadSession.duration then -- 1394
			st.reloadSession.active = false -- 1397
			st.reloadSession.elapsed = 0 -- 1398
			st.reloadSession.path = {} -- 1399
			st.reloadSession.previewEffect = "normal" -- 1400
			st.reloadSession.nextEffect = "normal" -- 1401
			st.reloadSession.firstTime = false -- 1402
			st.timeScaleOverride = nil -- 1403
		end -- 1403
	end -- 1403
	if st.craftBench.justCraftedTimer > 0 and dt > 0 then -- 1403
		st.craftBench.justCraftedTimer = math.max(0, st.craftBench.justCraftedTimer - dt) -- 1409
	end -- 1409
	local baseScale = st.timeScaleOverride ~= nil and math.max(0, st.timeScaleOverride) or (st.reloadSession.active and DEFAULT_SLOW_TIME_SCALE or 1) -- 1412
	local timeScale = st.timeScaleOverride ~= nil and baseScale or math.min(baseScale, self.liveFocusTimeScale) -- 1415
	local visualMode = deriveVisualMode( -- 1419
		p.room.key, -- 1420
		p.phase, -- 1421
		st.storyRoute, -- 1422
		st.archive.museumPhase, -- 1423
		countProgress, -- 1424
		st.gateReunion.completed -- 1425
	) -- 1425
	return { -- 1428
		storyRoute = st.storyRoute, -- 1429
		countElapsedTicks = countElapsedTicks, -- 1430
		countDurationTicks = countDurationTicks, -- 1431
		countNumber = countNumber, -- 1432
		countProgress = countProgress, -- 1433
		gateReunion = { -- 1434
			active = st.gateReunion.active, -- 1435
			knockHeard = st.gateReunion.knockHeard, -- 1436
			holdProgress = st.gateReunion.holdProgress, -- 1437
			holding = st.gateReunion.holding, -- 1438
			completed = st.gateReunion.completed, -- 1439
			releasedAbortCount = st.gateReunion.releasedAbortCount -- 1440
		}, -- 1440
		backCarry = {active = st.backCarry.active, handInHand = st.backCarry.handInHand, mounting = st.backCarry.mounting, atBench = st.backCarry.atBench}, -- 1442
		timeScale = timeScale, -- 1448
		reloadSession = { -- 1449
			active = st.reloadSession.active, -- 1450
			firstTime = st.reloadSession.firstTime, -- 1451
			elapsed = st.reloadSession.elapsed, -- 1452
			duration = st.reloadSession.duration, -- 1453
			path = __TS__ArraySlice(st.reloadSession.path), -- 1454
			previewEffect = st.reloadSession.previewEffect, -- 1455
			nextEffect = st.reloadSession.nextEffect, -- 1456
			invalidFlash = st.reloadSession.invalidFlash -- 1457
		}, -- 1457
		craftBench = { -- 1459
			active = st.craftBench.active, -- 1460
			firstCraftDone = st.craftBench.firstCraftDone, -- 1461
			justCraftedTimer = st.craftBench.justCraftedTimer, -- 1462
			inventory = cloneRecordNum(st.craftBench.inventory), -- 1463
			recipes = cloneRecipes(st.craftBench.recipes), -- 1464
			equippedWeapon = st.craftBench.equippedWeapon -- 1465
		}, -- 1465
		archive = { -- 1467
			childCleared = st.archive.childCleared, -- 1468
			soldierCleared = st.archive.soldierCleared, -- 1469
			artifactOwned = st.archive.artifactOwned, -- 1470
			museumPhase = st.archive.museumPhase, -- 1471
			museumSeen = st.archive.museumSeen -- 1472
		}, -- 1472
		roguelike = cloneRoguelike(st.roguelike), -- 1474
		assistHintsEnabled = self.assistHintsEnabled, -- 1475
		visualMode = visualMode, -- 1476
		dataSource = "rehearsal", -- 1477
		isRehearsal = true, -- 1478
		rehearsalTag = st.tag -- 1479
	} -- 1479
end -- 1344
function DualRouteContract.prototype.applyRehearsalIntent(self, st, intent) -- 1483
	if intent.kind == "gateReunionHold" then -- 1483
		if not st.gateReunion.active or st.gateReunion.completed then -- 1483
			return false -- 1486
		end -- 1486
		if not intent.holding and st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1486
			local ____st_gateReunion_87, ____releasedAbortCount_88 = st.gateReunion, "releasedAbortCount" -- 1486
			____st_gateReunion_87[____releasedAbortCount_88] = ____st_gateReunion_87[____releasedAbortCount_88] + 1 -- 1489
			st.gateReunion.holdProgress = 0 -- 1490
		end -- 1490
		st.gateReunion.holding = intent.holding -- 1492
		return true -- 1493
	end -- 1493
	if intent.kind == "reloadOpen" then -- 1493
		self:triggerMockReload(true) -- 1496
		return true -- 1497
	end -- 1497
	if intent.kind == "reloadTapNode" then -- 1497
		if not st.reloadSession.active then -- 1497
			return false -- 1501
		end -- 1501
		if #st.reloadSession.path == 0 then -- 1501
			local ____st_reloadSession_path_89 = st.reloadSession.path -- 1501
			____st_reloadSession_path_89[#____st_reloadSession_path_89 + 1] = 0 -- 1504
		end -- 1504
		if __TS__ArrayIndexOf(st.reloadSession.path, intent.node) >= 0 then -- 1504
			st.reloadSession.invalidFlash = 0.35 -- 1507
			st.reloadSession.path = {0} -- 1508
			st.reloadSession.previewEffect = "normal" -- 1509
			return false -- 1510
		end -- 1510
		local ____st_reloadSession_path_90 = st.reloadSession.path -- 1510
		____st_reloadSession_path_90[#____st_reloadSession_path_90 + 1] = intent.node -- 1512
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(st.reloadSession.path) -- 1513
		if intent.node == 8 then -- 1513
			st.reloadSession.nextEffect = st.reloadSession.previewEffect -- 1515
			st.reloadSession.active = false -- 1516
			st.reloadSession.elapsed = 0 -- 1517
			st.reloadSession.path = {} -- 1518
			st.reloadSession.firstTime = false -- 1519
			st.timeScaleOverride = nil -- 1520
		end -- 1520
		return true -- 1522
	end -- 1522
	if intent.kind == "reloadPathPreview" then -- 1522
		if not st.reloadSession.active then -- 1522
			return false -- 1526
		end -- 1526
		st.reloadSession.path = __TS__ArraySlice(intent.path) -- 1528
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(intent.path) -- 1529
		return true -- 1530
	end -- 1530
	if intent.kind == "reloadPathCommit" then -- 1530
		if not st.reloadSession.active then -- 1530
			return false -- 1534
		end -- 1534
		if #intent.path < 2 then -- 1534
			st.reloadSession.invalidFlash = 0.35 -- 1537
			st.reloadSession.path = {} -- 1538
			st.reloadSession.previewEffect = "normal" -- 1539
			return false -- 1540
		end -- 1540
		local effect = deriveReloadEffectFromPath(intent.path) -- 1542
		st.reloadSession.nextEffect = effect -- 1543
		st.reloadSession.previewEffect = effect -- 1544
		st.reloadSession.path = {} -- 1545
		st.reloadSession.active = false -- 1546
		st.reloadSession.elapsed = 0 -- 1547
		st.reloadSession.firstTime = false -- 1548
		st.timeScaleOverride = nil -- 1549
		return true -- 1550
	end -- 1550
	if intent.kind == "reloadCancel" then -- 1550
		st.reloadSession.active = false -- 1553
		st.reloadSession.elapsed = 0 -- 1554
		st.reloadSession.path = {} -- 1555
		st.reloadSession.previewEffect = "normal" -- 1556
		st.timeScaleOverride = nil -- 1557
		return true -- 1558
	end -- 1558
	if intent.kind == "craftSubmit" then -- 1558
		if not st.craftBench.active or st.handledCraftRequestIds[intent.requestId] == true then -- 1558
			return false -- 1562
		end -- 1562
		local target -- 1564
		local i = 0 -- 1565
		do -- 1565
			i = 0 -- 1566
			while i < #st.craftBench.recipes do -- 1566
				if st.craftBench.recipes[i + 1].id == intent.recipeId then -- 1566
					target = st.craftBench.recipes[i + 1] -- 1568
					break -- 1569
				end -- 1569
				i = i + 1 -- 1566
			end -- 1566
		end -- 1566
		if target == nil or target.crafted then -- 1566
			return false -- 1573
		end -- 1573
		for mat in pairs(target.cost) do -- 1575
			if (st.craftBench.inventory[mat] or 0) < target.cost[mat] then -- 1575
				return false -- 1577
			end -- 1577
		end -- 1577
		for mat in pairs(target.cost) do -- 1580
			st.craftBench.inventory[mat] = (st.craftBench.inventory[mat] or 0) - target.cost[mat] -- 1581
		end -- 1581
		st.handledCraftRequestIds[intent.requestId] = true -- 1583
		target.crafted = true -- 1584
		st.craftBench.equippedWeapon = target.id -- 1585
		st.craftBench.justCraftedTimer = st.craftBench.firstCraftDone and 0.45 or 1 -- 1586
		st.craftBench.firstCraftDone = true -- 1587
		return true -- 1588
	end -- 1588
	if intent.kind == "craftEquip" then -- 1588
		st.craftBench.equippedWeapon = intent.weaponId -- 1591
		return true -- 1592
	end -- 1592
	if intent.kind == "craftClose" then -- 1592
		st.craftBench.active = false -- 1595
		st.backCarry.atBench = false -- 1596
		return true -- 1597
	end -- 1597
	if intent.kind == "museumInteract" then -- 1597
		if intent.target == "well_pickup" and st.archive.museumPhase == "well_open" then -- 1597
			st.archive.artifactOwned = true -- 1601
			st.archive.museumPhase = "well_reflect" -- 1602
			return true -- 1603
		end -- 1603
		if intent.target == "enter_hall" and st.archive.museumPhase == "well_reflect" then -- 1603
			st.archive.museumPhase = "hall_walk" -- 1606
			return true -- 1607
		end -- 1607
		if intent.target == "lamp_turn" and st.archive.museumPhase == "hall_walk" then -- 1607
			st.archive.museumPhase = "lamp_turn" -- 1610
			return true -- 1611
		end -- 1611
		if intent.target == "begin_return_cabinet" and st.archive.museumPhase == "lamp_turn" then -- 1611
			st.archive.museumPhase = "return_cabinet" -- 1614
			return true -- 1615
		end -- 1615
		if intent.target == "return_cabinet" then -- 1615
			st.archive.museumPhase = "done" -- 1618
			st.archive.museumSeen = true -- 1619
			return true -- 1620
		end -- 1620
		return false -- 1622
	end -- 1622
	if intent.kind == "chooseTalent" then -- 1622
		local rg = st.roguelike -- 1625
		local id = rg.offers[intent.slot + 1] -- 1626
		if id == nil then -- 1626
			return false -- 1628
		end -- 1628
		rg.ranks[id] = (rg.ranks[id] or 0) + 1 -- 1630
		rg.totalRanks = rg.totalRanks + 1 -- 1631
		if id == "vitality" then -- 1631
			rg.maxHp = rg.maxHp + 1 -- 1633
			rg.hp = rg.hp + 1 -- 1634
		end -- 1634
		rg.offers = {} -- 1636
		rg.reloadTicksNow = computeDerivedReloadTicks(rg.ranks, rg.supplies) -- 1637
		rg.invulnTicksNow = computeDerivedInvulnTicks(rg.ranks) -- 1638
		rg.craftTicksNow = computeDerivedCraftTicks(rg.ranks) -- 1639
		return true -- 1640
	end -- 1640
	return false -- 1642
end -- 1483
return ____exports -- 1483