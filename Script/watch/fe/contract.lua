-- [ts]: contract.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____play = require("Script.watch.play") -- 20
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 20
local gateCountAtTick = ____play.gateCountAtTick -- 20
local GATE_REUNION_HOLD_SECONDS = 0.6 -- 158
local DEFAULT_RELOAD_DURATION = 4 -- 159
local DEFAULT_SLOW_TIME_SCALE = 0.25 -- 160
local MAX_INTENT_LOG = 64 -- 161
local function defaultRecipes() -- 163
	return {{ -- 164
		id = "guide_lantern_gun", -- 166
		name = "引路灯铳", -- 167
		desc = "以两枚木纹筹改制，增强灯纹照亮范围与余明", -- 168
		enhancedEffect = "light", -- 169
		cost = {wood_tally = 2}, -- 170
		crafted = false -- 171
	}, { -- 171
		id = "echo_gun", -- 174
		name = "回声铳", -- 175
		desc = "以一枚木纹筹与一枚铃纹筹改制，增强铃纹回声诱导", -- 176
		enhancedEffect = "echo", -- 177
		cost = {wood_tally = 1, bell_tally = 1}, -- 178
		crafted = false -- 179
	}} -- 179
end -- 163
local function cloneRecordNum(src) -- 184
	local out = {} -- 185
	for k in pairs(src) do -- 186
		out[k] = src[k] -- 187
	end -- 187
	return out -- 189
end -- 184
local function cloneRecipes(list) -- 192
	local out = {} -- 193
	local i = 0 -- 194
	do -- 194
		i = 0 -- 195
		while i < #list do -- 195
			local r = list[i + 1] -- 196
			out[#out + 1] = { -- 197
				id = r.id, -- 198
				name = r.name, -- 199
				desc = r.desc, -- 200
				enhancedEffect = r.enhancedEffect, -- 201
				cost = cloneRecordNum(r.cost), -- 202
				crafted = r.crafted -- 203
			} -- 203
			i = i + 1 -- 195
		end -- 195
	end -- 195
	return out -- 206
end -- 192
local function createEmptyGateReunion() -- 209
	return { -- 210
		active = false, -- 211
		knockHeard = false, -- 212
		holdProgress = 0, -- 213
		holding = false, -- 214
		completed = false, -- 215
		releasedAbortCount = 0 -- 216
	} -- 216
end -- 209
local function createEmptyBackCarry() -- 220
	return {active = false, handInHand = false, mounting = false, atBench = false} -- 221
end -- 220
local function createEmptyReloadSession() -- 229
	return { -- 230
		active = false, -- 231
		firstTime = true, -- 232
		elapsed = 0, -- 233
		duration = DEFAULT_RELOAD_DURATION, -- 234
		path = {}, -- 235
		previewEffect = "normal", -- 236
		nextEffect = "normal", -- 237
		invalidFlash = 0 -- 238
	} -- 238
end -- 229
local function createEmptyCraftBench() -- 242
	return { -- 243
		active = false, -- 244
		firstCraftDone = false, -- 245
		justCraftedTimer = 0, -- 246
		inventory = {}, -- 247
		recipes = defaultRecipes(), -- 248
		equippedWeapon = "standard_gun" -- 249
	} -- 249
end -- 242
local function createEmptyArchive() -- 253
	return { -- 254
		childCleared = false, -- 255
		soldierCleared = false, -- 256
		artifactOwned = false, -- 257
		museumPhase = "locked", -- 258
		museumSeen = false -- 259
	} -- 259
end -- 253
local function createInitialRehearsalState(tag) -- 263
	local bench = createEmptyCraftBench() -- 264
	bench.inventory = {wood_tally = 2, bell_tally = 1} -- 265
	return { -- 266
		tag = tag, -- 267
		storyRoute = "undecided", -- 268
		countTickOverride = nil, -- 269
		countDurationOverride = nil, -- 270
		timeScaleOverride = nil, -- 271
		gateReunion = createEmptyGateReunion(), -- 272
		gateHoldArmed = true, -- 273
		gatePrevInteractHeld = false, -- 274
		backCarry = createEmptyBackCarry(), -- 275
		reloadSession = createEmptyReloadSession(), -- 276
		craftBench = bench, -- 277
		archive = createEmptyArchive(), -- 278
		handledCraftRequestIds = {} -- 279
	} -- 279
end -- 263
local function asRecord(value) -- 283
	if value ~= nil and type(value) == "table" then -- 283
		return value -- 285
	end -- 285
	return nil -- 287
end -- 283
local function readNum(rec, key) -- 290
	if rec == nil then -- 290
		return nil -- 292
	end -- 292
	local v = rec[key] -- 294
	return type(v) == "number" and v or nil -- 295
end -- 290
local function readBool(rec, key) -- 298
	if rec == nil then -- 298
		return nil -- 300
	end -- 300
	local v = rec[key] -- 302
	local ____temp_0 -- 303
	if type(v) == "boolean" then -- 303
		____temp_0 = v -- 303
	else -- 303
		____temp_0 = nil -- 303
	end -- 303
	return ____temp_0 -- 303
end -- 298
local function readStr(rec, key) -- 306
	if rec == nil then -- 306
		return nil -- 308
	end -- 308
	local v = rec[key] -- 310
	return type(v) == "string" and v or nil -- 311
end -- 306
local function readNumArray(rec, key) -- 314
	if rec == nil then -- 314
		return nil -- 316
	end -- 316
	local v = rec[key] -- 318
	if not __TS__ArrayIsArray(v) then -- 318
		return nil -- 320
	end -- 320
	local out = {} -- 322
	local i = 0 -- 323
	do -- 323
		i = 0 -- 324
		while i < #v do -- 324
			if type(v[i + 1]) == "number" then -- 324
				out[#out + 1] = v[i + 1] -- 326
			end -- 326
			i = i + 1 -- 324
		end -- 324
	end -- 324
	return out -- 329
end -- 314
local function readNumMap(rec, key) -- 332
	if rec == nil then -- 332
		return nil -- 334
	end -- 334
	local obj = asRecord(rec[key]) -- 336
	if obj == nil then -- 336
		return nil -- 338
	end -- 338
	local out = {} -- 340
	for k in pairs(obj) do -- 341
		local val = obj[k] -- 342
		if type(val) == "number" then -- 342
			out[k] = val -- 344
		end -- 344
	end -- 344
	return out -- 347
end -- 332
local function parseStoryRoute(v) -- 350
	if v == "child" or v == "soldier" then -- 350
		return v -- 352
	end -- 352
	return "undecided" -- 354
end -- 350
local function parseReloadEffect(v) -- 357
	if v == "push" or v == "knockback" then -- 357
		return "knockback" -- 359
	end -- 359
	if v == "echo" or v == "light" then -- 359
		return v -- 362
	end -- 362
	return "normal" -- 364
end -- 357
local function parseMuseumPhase(v) -- 367
	if v == "well_open" or v == "well_reflect" or v == "hall_walk" or v == "lamp_turn" or v == "return_cabinet" or v == "done" then -- 367
		return v -- 376
	end -- 376
	return "locked" -- 378
end -- 367
--- 根据 3×3 路径点集合推导效果（对齐后端 reload.ts 布局）：
-- - 0 = 左下起点，8 = 右上枪机复位终点；
-- - 4 = 中心铃纹（echo，优先），2 = 右下灯纹（light），其余有效路径 = 推退（knockback）。
local function deriveReloadEffectFromPath(path) -- 386
	if #path < 2 then -- 386
		return "normal" -- 388
	end -- 388
	local hasBell = false -- 390
	local hasLamp = false -- 391
	local i = 0 -- 392
	do -- 392
		i = 0 -- 393
		while i < #path do -- 393
			if path[i + 1] == 4 then -- 393
				hasBell = true -- 395
			elseif path[i + 1] == 2 then -- 395
				hasLamp = true -- 397
			end -- 397
			i = i + 1 -- 393
		end -- 393
	end -- 393
	if hasBell then -- 393
		return "echo" -- 401
	end -- 401
	if hasLamp then -- 401
		return "light" -- 404
	end -- 404
	return "knockback" -- 406
end -- 386
local function deriveVisualMode(roomKey, phase, storyRoute, museumPhase, countProgress, reunionCompleted) -- 409
	if museumPhase == "well_reflect" or museumPhase == "hall_walk" or museumPhase == "lamp_turn" or museumPhase == "return_cabinet" then -- 409
		return "museum" -- 423
	end -- 423
	if roomKey == "gate" then -- 423
		if phase == "gate-hand" then -- 423
			return "pixel" -- 427
		end -- 427
		if phase == "gate-wait" then -- 427
			return reunionCompleted and "pixel" or "lowpoly" -- 430
		end -- 430
		if phase == "gate-count" then -- 430
			if storyRoute == "soldier" and reunionCompleted then -- 430
				return "pixel" -- 434
			end -- 434
			if countProgress <= 0 then -- 434
				return "pixel" -- 437
			end -- 437
			if countProgress >= 1 then -- 437
				return "lowpoly" -- 440
			end -- 440
			return "transition" -- 442
		end -- 442
		if phase == "gate-walk" then -- 442
			return storyRoute == "soldier" and "pixel" or (storyRoute == "child" and "lowpoly" or "pixel") -- 445
		end -- 445
		return "pixel" -- 447
	end -- 447
	if roomKey == "gatepath" or roomKey == "escort1" then -- 447
		return "pixel" -- 450
	end -- 450
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" then -- 450
		if storyRoute == "child" then -- 450
			return "lowpoly" -- 454
		end -- 454
		return "pixel" -- 456
	end -- 456
	return "pixel" -- 458
end -- 409
____exports.DualRouteContract = __TS__Class() -- 461
local DualRouteContract = ____exports.DualRouteContract -- 461
DualRouteContract.name = "DualRouteContract" -- 461
function DualRouteContract.prototype.____constructor(self) -- 461
	self.source = "live" -- 462
	self.assistHintsEnabled = false -- 465
	self.livePendingCraftRequests = {} -- 467
	self.liveReleasedAbortCount = 0 -- 469
	self.liveReloadInvalidFlash = 0 -- 470
	self.liveArchiveCache = createEmptyArchive() -- 471
	self.intentLog = {} -- 472
end -- 461
function DualRouteContract.prototype.getDataSource(self) -- 476
	return self.source -- 477
end -- 476
function DualRouteContract.prototype.isRehearsal(self) -- 481
	return self.source == "rehearsal" and self.rehearsal ~= nil -- 482
end -- 481
function DualRouteContract.prototype.enterRehearsal(self, tag) -- 486
	if tag == nil then -- 486
		tag = "rehearsal" -- 486
	end -- 486
	self.source = "rehearsal" -- 487
	if self.rehearsal == nil then -- 487
		self.rehearsal = createInitialRehearsalState(tag) -- 489
	else -- 489
		self.rehearsal.tag = tag -- 491
	end -- 491
end -- 486
function DualRouteContract.prototype.exitRehearsal(self) -- 496
	self.source = "live" -- 497
	self.rehearsal = nil -- 498
end -- 496
function DualRouteContract.prototype.ensureRehearsal(self, tag) -- 501
	if tag == nil then -- 501
		tag = "mock" -- 501
	end -- 501
	if self.source ~= "rehearsal" or self.rehearsal == nil then -- 501
		self:enterRehearsal(tag) -- 503
	end -- 503
	return self.rehearsal -- 505
end -- 501
function DualRouteContract.prototype.isAssistHintsEnabled(self) -- 508
	return self.assistHintsEnabled -- 509
end -- 508
function DualRouteContract.prototype.setAssistHintsEnabled(self, enabled) -- 512
	self.assistHintsEnabled = enabled -- 513
end -- 512
function DualRouteContract.prototype.toggleAssistHints(self) -- 516
	self.assistHintsEnabled = not self.assistHintsEnabled -- 517
	return self.assistHintsEnabled -- 518
end -- 516
function DualRouteContract.prototype.getLastSnapshot(self) -- 521
	return self.lastSnapshot -- 522
end -- 521
function DualRouteContract.prototype.peekSnapshot(self, p) -- 526
	local neutralInput = {interact = {held = false, pressed = false, released = false}} -- 527
	return self:sample(p, 0, neutralInput) -- 530
end -- 526
function DualRouteContract.prototype.getIntentLog(self) -- 533
	return self.intentLog -- 534
end -- 533
function DualRouteContract.prototype.clearIntentLog(self) -- 537
	self.intentLog = {} -- 538
end -- 537
function DualRouteContract.prototype.resetForRoom(self, p) -- 548
	self.livePendingCraftRequests = {} -- 549
	self.liveReleasedAbortCount = 0 -- 550
	self.liveReloadInvalidFlash = 0 -- 551
	self.liveArchiveCache = self:readLiveArchive(p) -- 552
	if self.rehearsal ~= nil then -- 552
		self.rehearsal.gateReunion = createEmptyGateReunion() -- 554
		self.rehearsal.gateHoldArmed = true -- 555
		self.rehearsal.gatePrevInteractHeld = false -- 556
		self.rehearsal.reloadSession = createEmptyReloadSession() -- 557
		self.rehearsal.craftBench.active = false -- 558
		self.rehearsal.craftBench.justCraftedTimer = 0 -- 559
		self.rehearsal.handledCraftRequestIds = {} -- 560
		self.rehearsal.timeScaleOverride = nil -- 561
	end -- 561
end -- 548
function DualRouteContract.prototype.sample(self, p, rawDt, input, events) -- 571
	local dt = p.paused and 0 or math.max(0, rawDt) -- 572
	local snap = self.source == "rehearsal" and self.rehearsal ~= nil and self:sampleRehearsal(p, dt, input, self.rehearsal) or self:sampleLive(p, dt, events) -- 573
	self.lastSnapshot = snap -- 576
	return snap -- 577
end -- 571
function DualRouteContract.prototype.submitIntent(self, p, intent) -- 585
	local accepted = false -- 586
	if self.source == "rehearsal" and self.rehearsal ~= nil then -- 586
		accepted = self:applyRehearsalIntent(self.rehearsal, intent) -- 588
	else -- 588
		accepted = self:forwardLiveIntent(p, intent) -- 590
	end -- 590
	local ____self_intentLog_1 = self.intentLog -- 590
	____self_intentLog_1[#____self_intentLog_1 + 1] = {tick = p.ticks, source = self.source, intent = intent, accepted = accepted} -- 592
	if #self.intentLog > MAX_INTENT_LOG then -- 592
		table.remove(self.intentLog, 1) -- 599
	end -- 599
	return accepted -- 601
end -- 585
function DualRouteContract.prototype.setMockRoute(self, route) -- 606
	local st = self:ensureRehearsal("mock") -- 607
	st.storyRoute = route -- 608
end -- 606
function DualRouteContract.prototype.setMockCountTick(self, tick, duration) -- 611
	local st = self:ensureRehearsal("mock") -- 612
	st.countTickOverride = tick -- 613
	if duration ~= nil and duration > 0 then -- 613
		st.countDurationOverride = duration -- 615
	end -- 615
end -- 611
function DualRouteContract.prototype.setMockTimeScale(self, scale) -- 619
	local st = self:ensureRehearsal("mock") -- 620
	st.timeScaleOverride = scale -- 621
end -- 619
function DualRouteContract.prototype.setMockGateReunion(self, patch) -- 624
	local st = self:ensureRehearsal("mock") -- 625
	if patch.active ~= nil then -- 625
		st.gateReunion.active = patch.active -- 626
	end -- 626
	if patch.knockHeard ~= nil then -- 626
		st.gateReunion.knockHeard = patch.knockHeard -- 627
	end -- 627
	if patch.holdProgress ~= nil then -- 627
		st.gateReunion.holdProgress = math.max( -- 628
			0, -- 628
			math.min(1, patch.holdProgress) -- 628
		) -- 628
	end -- 628
	if patch.holding ~= nil then -- 628
		st.gateReunion.holding = patch.holding -- 629
	end -- 629
	if patch.completed ~= nil then -- 629
		st.gateReunion.completed = patch.completed -- 630
	end -- 630
	if patch.releasedAbortCount ~= nil then -- 630
		st.gateReunion.releasedAbortCount = patch.releasedAbortCount -- 631
	end -- 631
end -- 624
function DualRouteContract.prototype.setMockBackCarry(self, patch) -- 634
	local st = self:ensureRehearsal("mock") -- 635
	if patch.active ~= nil then -- 635
		st.backCarry.active = patch.active -- 636
	end -- 636
	if patch.handInHand ~= nil then -- 636
		st.backCarry.handInHand = patch.handInHand -- 637
	end -- 637
	if patch.mounting ~= nil then -- 637
		st.backCarry.mounting = patch.mounting -- 638
	end -- 638
	if patch.atBench ~= nil then -- 638
		st.backCarry.atBench = patch.atBench -- 639
	end -- 639
end -- 634
function DualRouteContract.prototype.triggerMockReload(self, active, options) -- 642
	local st = self:ensureRehearsal("mock") -- 646
	st.reloadSession.active = active -- 647
	if active then -- 647
		st.reloadSession.elapsed = 0 -- 649
		st.reloadSession.duration = options and options.duration or DEFAULT_RELOAD_DURATION -- 650
		st.reloadSession.path = {} -- 651
		st.reloadSession.previewEffect = "normal" -- 652
		st.reloadSession.invalidFlash = 0 -- 653
		if (options and options.firstTime) ~= nil then -- 653
			st.reloadSession.firstTime = options.firstTime -- 655
		end -- 655
		st.timeScaleOverride = options and options.slowTimeScale or DEFAULT_SLOW_TIME_SCALE -- 657
	else -- 657
		st.reloadSession.elapsed = 0 -- 659
		st.reloadSession.path = {} -- 660
		st.timeScaleOverride = nil -- 661
	end -- 661
end -- 642
function DualRouteContract.prototype.triggerMockBench(self, active, options) -- 665
	local st = self:ensureRehearsal("mock") -- 669
	st.craftBench.active = active -- 670
	st.backCarry.atBench = active -- 671
	if (options and options.inventory) ~= nil then -- 671
		st.craftBench.inventory = cloneRecordNum(options.inventory) -- 673
	end -- 673
	if (options and options.equippedWeapon) ~= nil then -- 673
		st.craftBench.equippedWeapon = options.equippedWeapon -- 676
	end -- 676
end -- 665
function DualRouteContract.prototype.setMockArchive(self, childCleared, soldierCleared, artifactOwned) -- 680
	local st = self:ensureRehearsal("mock") -- 681
	st.archive.childCleared = childCleared -- 682
	st.archive.soldierCleared = soldierCleared -- 683
	if artifactOwned ~= nil then -- 683
		st.archive.artifactOwned = artifactOwned -- 685
	end -- 685
	if childCleared and soldierCleared and st.archive.museumPhase == "locked" then -- 685
		st.archive.museumPhase = "well_open" -- 688
	elseif (not childCleared or not soldierCleared) and st.archive.museumPhase == "well_open" then -- 688
		st.archive.museumPhase = "locked" -- 690
	end -- 690
end -- 680
function DualRouteContract.prototype.enterMockMuseum(self, phase) -- 694
	local st = self:ensureRehearsal("mock") -- 695
	st.archive.museumPhase = phase -- 696
	if phase == "done" then -- 696
		st.archive.museumSeen = true -- 698
	end -- 698
	if phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" or phase == "done" then -- 698
		st.archive.artifactOwned = true -- 707
	end -- 707
end -- 694
function DualRouteContract.prototype.sampleLive(self, p, dt, events) -- 713
	local pRec = asRecord(p) -- 714
	local runRec = asRecord(p.run) -- 715
	local ____asRecord_13 = asRecord -- 716
	local ____temp_12 -- 716
	if runRec ~= nil then -- 716
		____temp_12 = runRec.story -- 716
	else -- 716
		____temp_12 = nil -- 716
	end -- 716
	local storyRec = ____asRecord_13(____temp_12) -- 716
	if dt > 0 and self.liveReloadInvalidFlash > 0 then -- 716
		self.liveReloadInvalidFlash = math.max(0, self.liveReloadInvalidFlash - dt) -- 719
	end -- 719
	if events ~= nil and #events.rawEvents > 0 then -- 719
		local ei = 0 -- 722
		do -- 722
			ei = 0 -- 723
			while ei < #events.rawEvents do -- 723
				local ename = events.rawEvents[ei + 1].name -- 724
				if ename == "handRelease" then -- 724
					self.liveReleasedAbortCount = self.liveReleasedAbortCount + 1 -- 726
				elseif ename == "reloadInvalid" then -- 726
					self.liveReloadInvalidFlash = 0.35 -- 728
				end -- 728
				ei = ei + 1 -- 723
			end -- 723
		end -- 723
	end -- 723
	local ____temp_16 -- 734
	if pRec ~= nil and type(pRec.storyRoute) == "string" and pRec.storyRoute ~= "" then -- 734
		____temp_16 = pRec.storyRoute -- 735
	else -- 735
		local ____temp_15 -- 736
		if storyRec ~= nil and type(storyRec.route) == "string" and storyRec.route ~= "" then -- 736
			____temp_15 = storyRec.route -- 737
		else -- 737
			local ____temp_14 -- 738
			if runRec ~= nil then -- 738
				____temp_14 = runRec.storyRoute -- 738
			else -- 738
				____temp_14 = nil -- 738
			end -- 738
			____temp_15 = ____temp_14 -- 738
		end -- 738
		____temp_16 = ____temp_15 -- 736
	end -- 736
	local rawRoute = ____temp_16 -- 734
	local storyRoute = parseStoryRoute(rawRoute) -- 739
	local countElapsedTicks = readNum(pRec, "countElapsedTicks") or p.countTick -- 742
	local countDurationTicks = math.max( -- 743
		1, -- 743
		readNum(pRec, "countDurationTicks") or GATE_COUNT_END -- 743
	) -- 743
	local countNumber = gateCountAtTick(countElapsedTicks) -- 744
	local countProgress = math.max( -- 745
		0, -- 745
		math.min(1, countElapsedTicks / countDurationTicks) -- 745
	) -- 745
	local ____asRecord_18 = asRecord -- 748
	local ____temp_17 -- 748
	if pRec ~= nil then -- 748
		____temp_17 = pRec.gateReunion -- 748
	else -- 748
		____temp_17 = nil -- 748
	end -- 748
	local grRec = ____asRecord_18(____temp_17) -- 748
	local flatHold = readNum(pRec, "gateHoldProgress") -- 749
	local inGateWaitOrHand = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand") -- 750
	local handTicks = readNum(pRec, "handTicks") or 0 -- 751
	local handNeedTicks = math.max( -- 752
		1, -- 752
		readNum(pRec, "handNeedTicks") or 36 -- 752
	) -- 752
	local handTied = p.room.key == "gate" and p.phase == "gate-hand" -- 753
	local derivedHoldProg = handTied and 1 or (inGateWaitOrHand and math.max( -- 754
		0, -- 754
		math.min(1, handTicks / handNeedTicks) -- 754
	) or 0) -- 754
	local ____readBool_result_19 = readBool(grRec, "active") -- 756
	if ____readBool_result_19 == nil then -- 756
		____readBool_result_19 = inGateWaitOrHand -- 756
	end -- 756
	local ____readBool_result_20 = readBool(grRec, "knockHeard") -- 757
	if ____readBool_result_20 == nil then -- 757
		____readBool_result_20 = inGateWaitOrHand and p.knocks >= 1 -- 757
	end -- 757
	local ____math_max_result_23 = math.max( -- 758
		0, -- 758
		math.min( -- 758
			1, -- 758
			readNum(grRec, "holdProgress") or flatHold or derivedHoldProg -- 758
		) -- 758
	) -- 758
	local ____readBool_result_21 = readBool(grRec, "holding") -- 759
	if ____readBool_result_21 == nil then -- 759
		____readBool_result_21 = inGateWaitOrHand and not handTied and handTicks > 0 -- 759
	end -- 759
	local ____readBool_result_22 = readBool(grRec, "completed") -- 760
	if ____readBool_result_22 == nil then -- 760
		____readBool_result_22 = handTied -- 760
	end -- 760
	local gateReunion = { -- 755
		active = ____readBool_result_19, -- 756
		knockHeard = ____readBool_result_20, -- 757
		holdProgress = ____math_max_result_23, -- 758
		holding = ____readBool_result_21, -- 759
		completed = ____readBool_result_22, -- 760
		releasedAbortCount = readNum(grRec, "releasedAbortCount") or self.liveReleasedAbortCount -- 761
	} -- 761
	local ____asRecord_25 = asRecord -- 765
	local ____temp_24 -- 765
	if pRec ~= nil then -- 765
		____temp_24 = pRec.backCarry -- 765
	else -- 765
		____temp_24 = nil -- 765
	end -- 765
	local bcRec = ____asRecord_25(____temp_24) -- 765
	local ____readBool_result_26 = readBool(pRec, "carryOn") -- 766
	if ____readBool_result_26 == nil then -- 766
		____readBool_result_26 = readBool(storyRec, "carry") -- 766
	end -- 766
	local ____readBool_result_26_27 = ____readBool_result_26 -- 766
	if ____readBool_result_26_27 == nil then -- 766
		____readBool_result_26_27 = false -- 766
	end -- 766
	local carryOn = ____readBool_result_26_27 -- 766
	local handInHandLive = handTied or p.room.key == "gatepath" and not carryOn -- 767
	local ____readBool_result_28 = readBool(bcRec, "active") -- 769
	if ____readBool_result_28 == nil then -- 769
		____readBool_result_28 = carryOn -- 769
	end -- 769
	local ____readBool_result_29 = readBool(bcRec, "handInHand") -- 770
	if ____readBool_result_29 == nil then -- 770
		____readBool_result_29 = handInHandLive -- 770
	end -- 770
	local ____readBool_result_30 = readBool(bcRec, "mounting") -- 771
	if ____readBool_result_30 == nil then -- 771
		____readBool_result_30 = p.room.key == "gatepath" and carryOn -- 771
	end -- 771
	local ____readBool_result_31 = readBool(bcRec, "atBench") -- 772
	if ____readBool_result_31 == nil then -- 772
		____readBool_result_31 = false -- 772
	end -- 772
	local backCarry = {active = ____readBool_result_28, handInHand = ____readBool_result_29, mounting = ____readBool_result_30, atBench = ____readBool_result_31} -- 768
	local ____asRecord_33 = asRecord -- 776
	local ____temp_32 -- 776
	if pRec ~= nil then -- 776
		____temp_32 = pRec.reloadSession -- 776
	else -- 776
		____temp_32 = nil -- 776
	end -- 776
	local rsRec = ____asRecord_33(____temp_32) -- 776
	local ____readBool_result_34 = readBool(pRec, "reloadOpen") -- 777
	if ____readBool_result_34 == nil then -- 777
		____readBool_result_34 = false -- 777
	end -- 777
	local reloadOpenLive = ____readBool_result_34 -- 777
	local ____readBool_result_35 = readBool(rsRec, "active") -- 778
	if ____readBool_result_35 == nil then -- 778
		____readBool_result_35 = reloadOpenLive -- 778
	end -- 778
	local reloadActive = ____readBool_result_35 -- 778
	local reloadAnswerTicks = readNum(pRec, "reloadAnswerTicks") or 0 -- 779
	local reloadTryCount = readNum(pRec, "reloadTryCount") or 0 -- 780
	local livePath = readNumArray(rsRec, "path") or readNumArray(pRec, "reloadPath") or ({}) -- 781
	local ____temp_38 -- 782
	if rsRec ~= nil and rsRec.nextEffect ~= nil then -- 782
		____temp_38 = rsRec.nextEffect -- 783
	else -- 783
		local ____temp_37 -- 784
		if pRec ~= nil and pRec.reloadPendingEffect ~= nil then -- 784
			____temp_37 = pRec.reloadPendingEffect -- 785
		else -- 785
			local ____temp_36 -- 786
			if pRec ~= nil then -- 786
				____temp_36 = pRec.nextEffect -- 786
			else -- 786
				____temp_36 = nil -- 786
			end -- 786
			____temp_37 = ____temp_36 -- 786
		end -- 786
		____temp_38 = ____temp_37 -- 784
	end -- 784
	local liveNextRaw = ____temp_38 -- 782
	local livePreview = rsRec ~= nil and rsRec.previewEffect ~= nil and parseReloadEffect(rsRec.previewEffect) or (reloadActive and deriveReloadEffectFromPath(livePath) or "normal") -- 787
	local ____readBool_result_39 = readBool(rsRec, "firstTime") -- 793
	if ____readBool_result_39 == nil then -- 793
		____readBool_result_39 = reloadTryCount <= 1 -- 793
	end -- 793
	local reloadSession = { -- 791
		active = reloadActive, -- 792
		firstTime = ____readBool_result_39, -- 793
		elapsed = readNum(rsRec, "elapsed") or reloadAnswerTicks / 60, -- 794
		duration = math.max( -- 795
			0.01, -- 795
			readNum(rsRec, "duration") or DEFAULT_RELOAD_DURATION -- 795
		), -- 795
		path = livePath, -- 796
		previewEffect = livePreview, -- 797
		nextEffect = parseReloadEffect(liveNextRaw), -- 798
		invalidFlash = readNum(rsRec, "invalidFlash") or self.liveReloadInvalidFlash -- 799
	} -- 799
	local rawScale = readNum(pRec, "timeScale") or readNum(runRec, "timeScale") -- 802
	local timeScale = rawScale ~= nil and rawScale >= 0 and rawScale or (reloadActive and DEFAULT_SLOW_TIME_SCALE or 1) -- 803
	local ____asRecord_41 = asRecord -- 808
	local ____temp_40 -- 808
	if pRec ~= nil then -- 808
		____temp_40 = pRec.craftBench -- 808
	else -- 808
		____temp_40 = nil -- 808
	end -- 808
	local cbRec = ____asRecord_41(____temp_40) -- 808
	local craftBench = self:readLiveCraftBench(cbRec, pRec, runRec) -- 809
	local archive = self:readLiveArchive(p) -- 812
	self.liveArchiveCache = archive -- 813
	local visualMode = deriveVisualMode( -- 815
		p.room.key, -- 816
		p.phase, -- 817
		storyRoute, -- 818
		archive.museumPhase, -- 819
		countProgress, -- 820
		gateReunion.completed -- 821
	) -- 821
	return { -- 824
		storyRoute = storyRoute, -- 825
		countElapsedTicks = countElapsedTicks, -- 826
		countDurationTicks = countDurationTicks, -- 827
		countNumber = countNumber, -- 828
		countProgress = countProgress, -- 829
		gateReunion = gateReunion, -- 830
		backCarry = backCarry, -- 831
		timeScale = timeScale, -- 832
		reloadSession = reloadSession, -- 833
		craftBench = craftBench, -- 834
		archive = archive, -- 835
		assistHintsEnabled = self.assistHintsEnabled, -- 836
		visualMode = visualMode, -- 837
		dataSource = "live", -- 838
		isRehearsal = false, -- 839
		rehearsalTag = "" -- 840
	} -- 840
end -- 713
function DualRouteContract.prototype.readLiveCraftBench(self, cbRec, pRec, runRec) -- 844
	local recipes = defaultRecipes() -- 849
	if cbRec ~= nil and __TS__ArrayIsArray(cbRec.recipes) then -- 849
		local rawList = cbRec.recipes -- 851
		local parsed = {} -- 852
		local i = 0 -- 853
		do -- 853
			i = 0 -- 854
			while i < #rawList do -- 854
				do -- 854
					local item = asRecord(rawList[i + 1]) -- 855
					if item == nil then -- 855
						goto __continue126 -- 857
					end -- 857
					local id = readStr(item, "id") -- 859
					local name = readStr(item, "name") -- 860
					if id == nil or name == nil then -- 860
						goto __continue126 -- 862
					end -- 862
					local ____id_43 = id -- 865
					local ____name_44 = name -- 866
					local ____temp_45 = readStr(item, "desc") or "" -- 867
					local ____parseReloadEffect_result_46 = parseReloadEffect(item.enhancedEffect) -- 868
					local ____temp_47 = readNumMap(item, "cost") or ({}) -- 869
					local ____readBool_result_42 = readBool(item, "crafted") -- 870
					if ____readBool_result_42 == nil then -- 870
						____readBool_result_42 = false -- 870
					end -- 870
					parsed[#parsed + 1] = { -- 864
						id = ____id_43, -- 865
						name = ____name_44, -- 866
						desc = ____temp_45, -- 867
						enhancedEffect = ____parseReloadEffect_result_46, -- 868
						cost = ____temp_47, -- 869
						crafted = ____readBool_result_42 -- 870
					} -- 870
				end -- 870
				::__continue126:: -- 870
				i = i + 1 -- 854
			end -- 854
		end -- 854
		if #parsed > 0 then -- 854
			local ____readBool_result_48 = readBool(cbRec, "active") -- 875
			if ____readBool_result_48 == nil then -- 875
				____readBool_result_48 = false -- 875
			end -- 875
			local ____readBool_result_49 = readBool(cbRec, "firstCraftDone") -- 876
			if ____readBool_result_49 == nil then -- 876
				____readBool_result_49 = false -- 876
			end -- 876
			return { -- 874
				active = ____readBool_result_48, -- 875
				firstCraftDone = ____readBool_result_49, -- 876
				justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 877
				inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or ({}), -- 878
				recipes = parsed, -- 879
				equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 880
			} -- 880
		end -- 880
	end -- 880
	local ____readBool_result_50 = readBool(cbRec, "active") -- 885
	if ____readBool_result_50 == nil then -- 885
		____readBool_result_50 = false -- 885
	end -- 885
	local ____readBool_result_51 = readBool(cbRec, "firstCraftDone") -- 886
	if ____readBool_result_51 == nil then -- 886
		____readBool_result_51 = false -- 886
	end -- 886
	return { -- 884
		active = ____readBool_result_50, -- 885
		firstCraftDone = ____readBool_result_51, -- 886
		justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 887
		inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or readNumMap(runRec, "craftInventory") or ({}), -- 888
		recipes = recipes, -- 889
		equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 890
	} -- 890
end -- 844
function DualRouteContract.prototype.readLiveArchive(self, p) -- 894
	local pRec = asRecord(p) -- 895
	local runRec = asRecord(p.run) -- 896
	local ____asRecord_53 = asRecord -- 897
	local ____temp_52 -- 897
	if pRec ~= nil then -- 897
		____temp_52 = pRec.archive -- 897
	else -- 897
		____temp_52 = nil -- 897
	end -- 897
	local ____asRecord_53_result_56 = ____asRecord_53(____temp_52) -- 897
	if ____asRecord_53_result_56 == nil then -- 897
		local ____asRecord_55 = asRecord -- 898
		local ____temp_54 -- 898
		if runRec ~= nil then -- 898
			____temp_54 = runRec.archive -- 898
		else -- 898
			____temp_54 = nil -- 898
		end -- 898
		____asRecord_53_result_56 = ____asRecord_55(____temp_54) -- 897
	end -- 897
	local archRec = ____asRecord_53_result_56 -- 897
	local ____readBool_result_57 = readBool(archRec, "childCleared") -- 900
	if ____readBool_result_57 == nil then -- 900
		____readBool_result_57 = readBool(pRec, "childCleared") -- 900
	end -- 900
	local ____readBool_result_57_58 = ____readBool_result_57 -- 900
	if ____readBool_result_57_58 == nil then -- 900
		____readBool_result_57_58 = false -- 900
	end -- 900
	local childCleared = ____readBool_result_57_58 -- 900
	local ____readBool_result_59 = readBool(archRec, "soldierCleared") -- 901
	if ____readBool_result_59 == nil then -- 901
		____readBool_result_59 = readBool(pRec, "soldierCleared") -- 901
	end -- 901
	local ____readBool_result_59_60 = ____readBool_result_59 -- 901
	if ____readBool_result_59_60 == nil then -- 901
		____readBool_result_59_60 = false -- 901
	end -- 901
	local soldierCleared = ____readBool_result_59_60 -- 901
	local ____readBool_result_61 = readBool(archRec, "artifactOwned") -- 902
	if ____readBool_result_61 == nil then -- 902
		____readBool_result_61 = readBool(pRec, "artifactOwned") -- 902
	end -- 902
	local ____readBool_result_61_62 = ____readBool_result_61 -- 902
	if ____readBool_result_61_62 == nil then -- 902
		____readBool_result_61_62 = false -- 902
	end -- 902
	local artifactOwned = ____readBool_result_61_62 -- 902
	local ____temp_64 -- 903
	if archRec ~= nil and archRec.museumPhase ~= nil then -- 903
		____temp_64 = archRec.museumPhase -- 904
	else -- 904
		local ____temp_63 -- 905
		if pRec ~= nil then -- 905
			____temp_63 = pRec.museumPhase -- 905
		else -- 905
			____temp_63 = nil -- 905
		end -- 905
		____temp_64 = ____temp_63 -- 905
	end -- 905
	local rawPhase = ____temp_64 -- 903
	local museumPhase = parseMuseumPhase(rawPhase) -- 906
	local ____readBool_result_65 = readBool(archRec, "museumSeen") -- 907
	if ____readBool_result_65 == nil then -- 907
		____readBool_result_65 = readBool(pRec, "museumSeen") -- 907
	end -- 907
	local ____readBool_result_65_66 = ____readBool_result_65 -- 907
	if ____readBool_result_65_66 == nil then -- 907
		____readBool_result_65_66 = false -- 907
	end -- 907
	local museumSeen = ____readBool_result_65_66 -- 907
	return { -- 909
		childCleared = childCleared, -- 910
		soldierCleared = soldierCleared, -- 911
		artifactOwned = artifactOwned, -- 912
		museumPhase = museumPhase, -- 913
		museumSeen = museumSeen -- 914
	} -- 914
end -- 894
function DualRouteContract.prototype.forwardLiveIntent(self, p, intent) -- 918
	if intent.kind == "craftSubmit" then -- 918
		if self.livePendingCraftRequests[intent.requestId] == true then -- 918
			return false -- 921
		end -- 921
		self.livePendingCraftRequests[intent.requestId] = true -- 923
	end -- 923
	local pRec = asRecord(p) -- 925
	if pRec == nil then -- 925
		return false -- 927
	end -- 927
	local handler = pRec.submitFeIntent -- 929
	if type(handler) == "function" then -- 929
		local result = handler(p, intent) -- 931
		return result ~= false -- 932
	end -- 932
	local tapNode = pRec.reloadTapNode -- 935
	if type(tapNode) == "function" then -- 935
		local fn = tapNode -- 937
		if intent.kind == "reloadTapNode" then -- 937
			fn(p, intent.node) -- 939
			return true -- 940
		end -- 940
		if intent.kind == "reloadPathCommit" and #intent.path > 0 then -- 940
			local i = 0 -- 943
			do -- 943
				i = 0 -- 944
				while i < #intent.path do -- 944
					do -- 944
						if i == 0 and intent.path[i + 1] == 0 then -- 944
							goto __continue140 -- 946
						end -- 946
						fn(p, intent.path[i + 1]) -- 948
					end -- 948
					::__continue140:: -- 948
					i = i + 1 -- 944
				end -- 944
			end -- 944
			return true -- 950
		end -- 950
	end -- 950
	return false -- 953
end -- 918
function DualRouteContract.prototype.sampleRehearsal(self, p, dt, input, st) -- 958
	local countElapsedTicks = st.countTickOverride ~= nil and st.countTickOverride or p.countTick -- 959
	local countDurationTicks = math.max(1, st.countDurationOverride or GATE_COUNT_END) -- 960
	local countNumber = gateCountAtTick(countElapsedTicks) -- 961
	local countProgress = math.max( -- 962
		0, -- 962
		math.min(1, countElapsedTicks / countDurationTicks) -- 962
	) -- 962
	if p.room.key == "gate" and p.phase == "gate-count" and st.storyRoute == "soldier" then -- 962
		if countElapsedTicks < countDurationTicks then -- 962
			st.gateReunion.active = false -- 967
			st.gateReunion.knockHeard = false -- 968
			st.gateReunion.holding = false -- 969
			st.gateReunion.holdProgress = 0 -- 970
			st.gateHoldArmed = not input.interact.held -- 971
			st.gatePrevInteractHeld = input.interact.held -- 972
		elseif not st.gateReunion.completed then -- 972
			st.gateReunion.active = true -- 974
			st.gateReunion.knockHeard = true -- 975
			if not st.gateHoldArmed and not input.interact.held then -- 975
				st.gateHoldArmed = true -- 977
			end -- 977
			if dt > 0 then -- 977
				if st.gateHoldArmed and input.interact.held then -- 977
					st.gateReunion.holding = true -- 981
					st.gateReunion.holdProgress = math.min(1, st.gateReunion.holdProgress + dt / GATE_REUNION_HOLD_SECONDS) -- 982
					if st.gateReunion.holdProgress >= 1 then -- 982
						st.gateReunion.holdProgress = 1 -- 987
						st.gateReunion.holding = false -- 988
						st.gateReunion.completed = true -- 989
						st.backCarry.handInHand = true -- 990
					end -- 990
				else -- 990
					if st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 990
						local ____st_gateReunion_67, ____releasedAbortCount_68 = st.gateReunion, "releasedAbortCount" -- 990
						____st_gateReunion_67[____releasedAbortCount_68] = ____st_gateReunion_67[____releasedAbortCount_68] + 1 -- 994
					end -- 994
					st.gateReunion.holding = false -- 996
					st.gateReunion.holdProgress = 0 -- 997
				end -- 997
			end -- 997
			st.gatePrevInteractHeld = input.interact.held -- 1000
		end -- 1000
	end -- 1000
	if st.reloadSession.active and dt > 0 then -- 1000
		local ____st_reloadSession_69, ____elapsed_70 = st.reloadSession, "elapsed" -- 1000
		____st_reloadSession_69[____elapsed_70] = ____st_reloadSession_69[____elapsed_70] + dt -- 1006
		if st.reloadSession.invalidFlash > 0 then -- 1006
			st.reloadSession.invalidFlash = math.max(0, st.reloadSession.invalidFlash - dt) -- 1008
		end -- 1008
		if st.reloadSession.elapsed >= st.reloadSession.duration then -- 1008
			st.reloadSession.active = false -- 1011
			st.reloadSession.elapsed = 0 -- 1012
			st.reloadSession.path = {} -- 1013
			st.reloadSession.previewEffect = "normal" -- 1014
			st.reloadSession.nextEffect = "normal" -- 1015
			st.reloadSession.firstTime = false -- 1016
			st.timeScaleOverride = nil -- 1017
		end -- 1017
	end -- 1017
	if st.craftBench.justCraftedTimer > 0 and dt > 0 then -- 1017
		st.craftBench.justCraftedTimer = math.max(0, st.craftBench.justCraftedTimer - dt) -- 1023
	end -- 1023
	local timeScale = st.timeScaleOverride ~= nil and math.max(0, st.timeScaleOverride) or (st.reloadSession.active and DEFAULT_SLOW_TIME_SCALE or 1) -- 1026
	local visualMode = deriveVisualMode( -- 1030
		p.room.key, -- 1031
		p.phase, -- 1032
		st.storyRoute, -- 1033
		st.archive.museumPhase, -- 1034
		countProgress, -- 1035
		st.gateReunion.completed -- 1036
	) -- 1036
	return { -- 1039
		storyRoute = st.storyRoute, -- 1040
		countElapsedTicks = countElapsedTicks, -- 1041
		countDurationTicks = countDurationTicks, -- 1042
		countNumber = countNumber, -- 1043
		countProgress = countProgress, -- 1044
		gateReunion = { -- 1045
			active = st.gateReunion.active, -- 1046
			knockHeard = st.gateReunion.knockHeard, -- 1047
			holdProgress = st.gateReunion.holdProgress, -- 1048
			holding = st.gateReunion.holding, -- 1049
			completed = st.gateReunion.completed, -- 1050
			releasedAbortCount = st.gateReunion.releasedAbortCount -- 1051
		}, -- 1051
		backCarry = {active = st.backCarry.active, handInHand = st.backCarry.handInHand, mounting = st.backCarry.mounting, atBench = st.backCarry.atBench}, -- 1053
		timeScale = timeScale, -- 1059
		reloadSession = { -- 1060
			active = st.reloadSession.active, -- 1061
			firstTime = st.reloadSession.firstTime, -- 1062
			elapsed = st.reloadSession.elapsed, -- 1063
			duration = st.reloadSession.duration, -- 1064
			path = __TS__ArraySlice(st.reloadSession.path), -- 1065
			previewEffect = st.reloadSession.previewEffect, -- 1066
			nextEffect = st.reloadSession.nextEffect, -- 1067
			invalidFlash = st.reloadSession.invalidFlash -- 1068
		}, -- 1068
		craftBench = { -- 1070
			active = st.craftBench.active, -- 1071
			firstCraftDone = st.craftBench.firstCraftDone, -- 1072
			justCraftedTimer = st.craftBench.justCraftedTimer, -- 1073
			inventory = cloneRecordNum(st.craftBench.inventory), -- 1074
			recipes = cloneRecipes(st.craftBench.recipes), -- 1075
			equippedWeapon = st.craftBench.equippedWeapon -- 1076
		}, -- 1076
		archive = { -- 1078
			childCleared = st.archive.childCleared, -- 1079
			soldierCleared = st.archive.soldierCleared, -- 1080
			artifactOwned = st.archive.artifactOwned, -- 1081
			museumPhase = st.archive.museumPhase, -- 1082
			museumSeen = st.archive.museumSeen -- 1083
		}, -- 1083
		assistHintsEnabled = self.assistHintsEnabled, -- 1085
		visualMode = visualMode, -- 1086
		dataSource = "rehearsal", -- 1087
		isRehearsal = true, -- 1088
		rehearsalTag = st.tag -- 1089
	} -- 1089
end -- 958
function DualRouteContract.prototype.applyRehearsalIntent(self, st, intent) -- 1093
	if intent.kind == "gateReunionHold" then -- 1093
		if not st.gateReunion.active or st.gateReunion.completed then -- 1093
			return false -- 1096
		end -- 1096
		if not intent.holding and st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1096
			local ____st_gateReunion_71, ____releasedAbortCount_72 = st.gateReunion, "releasedAbortCount" -- 1096
			____st_gateReunion_71[____releasedAbortCount_72] = ____st_gateReunion_71[____releasedAbortCount_72] + 1 -- 1099
			st.gateReunion.holdProgress = 0 -- 1100
		end -- 1100
		st.gateReunion.holding = intent.holding -- 1102
		return true -- 1103
	end -- 1103
	if intent.kind == "reloadOpen" then -- 1103
		self:triggerMockReload(true) -- 1106
		return true -- 1107
	end -- 1107
	if intent.kind == "reloadTapNode" then -- 1107
		if not st.reloadSession.active then -- 1107
			return false -- 1111
		end -- 1111
		if #st.reloadSession.path == 0 then -- 1111
			local ____st_reloadSession_path_73 = st.reloadSession.path -- 1111
			____st_reloadSession_path_73[#____st_reloadSession_path_73 + 1] = 0 -- 1114
		end -- 1114
		if __TS__ArrayIndexOf(st.reloadSession.path, intent.node) >= 0 then -- 1114
			st.reloadSession.invalidFlash = 0.35 -- 1117
			st.reloadSession.path = {0} -- 1118
			st.reloadSession.previewEffect = "normal" -- 1119
			return false -- 1120
		end -- 1120
		local ____st_reloadSession_path_74 = st.reloadSession.path -- 1120
		____st_reloadSession_path_74[#____st_reloadSession_path_74 + 1] = intent.node -- 1122
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(st.reloadSession.path) -- 1123
		if intent.node == 8 then -- 1123
			st.reloadSession.nextEffect = st.reloadSession.previewEffect -- 1125
			st.reloadSession.active = false -- 1126
			st.reloadSession.elapsed = 0 -- 1127
			st.reloadSession.path = {} -- 1128
			st.reloadSession.firstTime = false -- 1129
			st.timeScaleOverride = nil -- 1130
		end -- 1130
		return true -- 1132
	end -- 1132
	if intent.kind == "reloadPathPreview" then -- 1132
		if not st.reloadSession.active then -- 1132
			return false -- 1136
		end -- 1136
		st.reloadSession.path = __TS__ArraySlice(intent.path) -- 1138
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(intent.path) -- 1139
		return true -- 1140
	end -- 1140
	if intent.kind == "reloadPathCommit" then -- 1140
		if not st.reloadSession.active then -- 1140
			return false -- 1144
		end -- 1144
		if #intent.path < 2 then -- 1144
			st.reloadSession.invalidFlash = 0.35 -- 1147
			st.reloadSession.path = {} -- 1148
			st.reloadSession.previewEffect = "normal" -- 1149
			return false -- 1150
		end -- 1150
		local effect = deriveReloadEffectFromPath(intent.path) -- 1152
		st.reloadSession.nextEffect = effect -- 1153
		st.reloadSession.previewEffect = effect -- 1154
		st.reloadSession.path = {} -- 1155
		st.reloadSession.active = false -- 1156
		st.reloadSession.elapsed = 0 -- 1157
		st.reloadSession.firstTime = false -- 1158
		st.timeScaleOverride = nil -- 1159
		return true -- 1160
	end -- 1160
	if intent.kind == "reloadCancel" then -- 1160
		st.reloadSession.active = false -- 1163
		st.reloadSession.elapsed = 0 -- 1164
		st.reloadSession.path = {} -- 1165
		st.reloadSession.previewEffect = "normal" -- 1166
		st.timeScaleOverride = nil -- 1167
		return true -- 1168
	end -- 1168
	if intent.kind == "craftSubmit" then -- 1168
		if not st.craftBench.active or st.handledCraftRequestIds[intent.requestId] == true then -- 1168
			return false -- 1172
		end -- 1172
		local target -- 1174
		local i = 0 -- 1175
		do -- 1175
			i = 0 -- 1176
			while i < #st.craftBench.recipes do -- 1176
				if st.craftBench.recipes[i + 1].id == intent.recipeId then -- 1176
					target = st.craftBench.recipes[i + 1] -- 1178
					break -- 1179
				end -- 1179
				i = i + 1 -- 1176
			end -- 1176
		end -- 1176
		if target == nil or target.crafted then -- 1176
			return false -- 1183
		end -- 1183
		for mat in pairs(target.cost) do -- 1185
			if (st.craftBench.inventory[mat] or 0) < target.cost[mat] then -- 1185
				return false -- 1187
			end -- 1187
		end -- 1187
		for mat in pairs(target.cost) do -- 1190
			st.craftBench.inventory[mat] = (st.craftBench.inventory[mat] or 0) - target.cost[mat] -- 1191
		end -- 1191
		st.handledCraftRequestIds[intent.requestId] = true -- 1193
		target.crafted = true -- 1194
		st.craftBench.equippedWeapon = target.id -- 1195
		st.craftBench.justCraftedTimer = st.craftBench.firstCraftDone and 0.45 or 1 -- 1196
		st.craftBench.firstCraftDone = true -- 1197
		return true -- 1198
	end -- 1198
	if intent.kind == "craftEquip" then -- 1198
		st.craftBench.equippedWeapon = intent.weaponId -- 1201
		return true -- 1202
	end -- 1202
	if intent.kind == "craftClose" then -- 1202
		st.craftBench.active = false -- 1205
		st.backCarry.atBench = false -- 1206
		return true -- 1207
	end -- 1207
	if intent.kind == "museumInteract" then -- 1207
		if intent.target == "well_pickup" and st.archive.museumPhase == "well_open" then -- 1207
			st.archive.artifactOwned = true -- 1211
			st.archive.museumPhase = "well_reflect" -- 1212
			return true -- 1213
		end -- 1213
		if intent.target == "lamp_turn" and st.archive.museumPhase == "hall_walk" then -- 1213
			st.archive.museumPhase = "lamp_turn" -- 1216
			return true -- 1217
		end -- 1217
		if intent.target == "return_cabinet" then -- 1217
			st.archive.museumPhase = "done" -- 1220
			st.archive.museumSeen = true -- 1221
			return true -- 1222
		end -- 1222
		return false -- 1224
	end -- 1224
	return false -- 1226
end -- 1093
return ____exports -- 1093