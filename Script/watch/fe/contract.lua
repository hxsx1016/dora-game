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
	if roomKey == "gatepath" or roomKey == "escort1" or roomKey == "escort2" or roomKey == "escort3" or roomKey == "escort4" or roomKey == "escort5" then -- 447
		return "pixel" -- 451
	end -- 451
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" then -- 451
		if storyRoute == "child" then -- 451
			return "lowpoly" -- 455
		end -- 455
		return "pixel" -- 457
	end -- 457
	return "pixel" -- 459
end -- 409
____exports.DualRouteContract = __TS__Class() -- 462
local DualRouteContract = ____exports.DualRouteContract -- 462
DualRouteContract.name = "DualRouteContract" -- 462
function DualRouteContract.prototype.____constructor(self) -- 462
	self.source = "live" -- 463
	self.assistHintsEnabled = false -- 466
	self.livePendingCraftRequests = {} -- 468
	self.liveReleasedAbortCount = 0 -- 470
	self.liveReloadInvalidFlash = 0 -- 471
	self.liveArchiveCache = createEmptyArchive() -- 472
	self.intentLog = {} -- 473
end -- 462
function DualRouteContract.prototype.getDataSource(self) -- 477
	return self.source -- 478
end -- 477
function DualRouteContract.prototype.isRehearsal(self) -- 482
	return self.source == "rehearsal" and self.rehearsal ~= nil -- 483
end -- 482
function DualRouteContract.prototype.enterRehearsal(self, tag) -- 487
	if tag == nil then -- 487
		tag = "rehearsal" -- 487
	end -- 487
	self.source = "rehearsal" -- 488
	if self.rehearsal == nil then -- 488
		self.rehearsal = createInitialRehearsalState(tag) -- 490
	else -- 490
		self.rehearsal.tag = tag -- 492
	end -- 492
end -- 487
function DualRouteContract.prototype.exitRehearsal(self) -- 497
	self.source = "live" -- 498
	self.rehearsal = nil -- 499
end -- 497
function DualRouteContract.prototype.ensureRehearsal(self, tag) -- 502
	if tag == nil then -- 502
		tag = "mock" -- 502
	end -- 502
	if self.source ~= "rehearsal" or self.rehearsal == nil then -- 502
		self:enterRehearsal(tag) -- 504
	end -- 504
	return self.rehearsal -- 506
end -- 502
function DualRouteContract.prototype.isAssistHintsEnabled(self) -- 509
	return self.assistHintsEnabled -- 510
end -- 509
function DualRouteContract.prototype.setAssistHintsEnabled(self, enabled) -- 513
	self.assistHintsEnabled = enabled -- 514
end -- 513
function DualRouteContract.prototype.toggleAssistHints(self) -- 517
	self.assistHintsEnabled = not self.assistHintsEnabled -- 518
	return self.assistHintsEnabled -- 519
end -- 517
function DualRouteContract.prototype.getLastSnapshot(self) -- 522
	return self.lastSnapshot -- 523
end -- 522
function DualRouteContract.prototype.peekSnapshot(self, p) -- 527
	local neutralInput = {interact = {held = false, pressed = false, released = false}} -- 528
	return self:sample(p, 0, neutralInput) -- 531
end -- 527
function DualRouteContract.prototype.getIntentLog(self) -- 534
	return self.intentLog -- 535
end -- 534
function DualRouteContract.prototype.clearIntentLog(self) -- 538
	self.intentLog = {} -- 539
end -- 538
function DualRouteContract.prototype.resetForRoom(self, p) -- 549
	self.livePendingCraftRequests = {} -- 550
	self.liveReleasedAbortCount = 0 -- 551
	self.liveReloadInvalidFlash = 0 -- 552
	self.liveArchiveCache = self:readLiveArchive(p) -- 553
	if self.rehearsal ~= nil then -- 553
		self.rehearsal.gateReunion = createEmptyGateReunion() -- 555
		self.rehearsal.gateHoldArmed = true -- 556
		self.rehearsal.gatePrevInteractHeld = false -- 557
		self.rehearsal.reloadSession = createEmptyReloadSession() -- 558
		self.rehearsal.craftBench.active = false -- 559
		self.rehearsal.craftBench.justCraftedTimer = 0 -- 560
		self.rehearsal.handledCraftRequestIds = {} -- 561
		self.rehearsal.timeScaleOverride = nil -- 562
	end -- 562
end -- 549
function DualRouteContract.prototype.sample(self, p, rawDt, input, events) -- 572
	local dt = p.paused and 0 or math.max(0, rawDt) -- 573
	local snap = self.source == "rehearsal" and self.rehearsal ~= nil and self:sampleRehearsal(p, dt, input, self.rehearsal) or self:sampleLive(p, dt, events) -- 574
	self.lastSnapshot = snap -- 577
	return snap -- 578
end -- 572
function DualRouteContract.prototype.submitIntent(self, p, intent) -- 586
	local accepted = false -- 587
	if self.source == "rehearsal" and self.rehearsal ~= nil then -- 587
		accepted = self:applyRehearsalIntent(self.rehearsal, intent) -- 589
	else -- 589
		accepted = self:forwardLiveIntent(p, intent) -- 591
	end -- 591
	local ____self_intentLog_1 = self.intentLog -- 591
	____self_intentLog_1[#____self_intentLog_1 + 1] = {tick = p.ticks, source = self.source, intent = intent, accepted = accepted} -- 593
	if #self.intentLog > MAX_INTENT_LOG then -- 593
		table.remove(self.intentLog, 1) -- 600
	end -- 600
	return accepted -- 602
end -- 586
function DualRouteContract.prototype.setMockRoute(self, route) -- 607
	local st = self:ensureRehearsal("mock") -- 608
	st.storyRoute = route -- 609
end -- 607
function DualRouteContract.prototype.setMockCountTick(self, tick, duration) -- 612
	local st = self:ensureRehearsal("mock") -- 613
	st.countTickOverride = tick -- 614
	if duration ~= nil and duration > 0 then -- 614
		st.countDurationOverride = duration -- 616
	end -- 616
end -- 612
function DualRouteContract.prototype.setMockTimeScale(self, scale) -- 620
	local st = self:ensureRehearsal("mock") -- 621
	st.timeScaleOverride = scale -- 622
end -- 620
function DualRouteContract.prototype.setMockGateReunion(self, patch) -- 625
	local st = self:ensureRehearsal("mock") -- 626
	if patch.active ~= nil then -- 626
		st.gateReunion.active = patch.active -- 627
	end -- 627
	if patch.knockHeard ~= nil then -- 627
		st.gateReunion.knockHeard = patch.knockHeard -- 628
	end -- 628
	if patch.holdProgress ~= nil then -- 628
		st.gateReunion.holdProgress = math.max( -- 629
			0, -- 629
			math.min(1, patch.holdProgress) -- 629
		) -- 629
	end -- 629
	if patch.holding ~= nil then -- 629
		st.gateReunion.holding = patch.holding -- 630
	end -- 630
	if patch.completed ~= nil then -- 630
		st.gateReunion.completed = patch.completed -- 631
	end -- 631
	if patch.releasedAbortCount ~= nil then -- 631
		st.gateReunion.releasedAbortCount = patch.releasedAbortCount -- 632
	end -- 632
end -- 625
function DualRouteContract.prototype.setMockBackCarry(self, patch) -- 635
	local st = self:ensureRehearsal("mock") -- 636
	if patch.active ~= nil then -- 636
		st.backCarry.active = patch.active -- 637
	end -- 637
	if patch.handInHand ~= nil then -- 637
		st.backCarry.handInHand = patch.handInHand -- 638
	end -- 638
	if patch.mounting ~= nil then -- 638
		st.backCarry.mounting = patch.mounting -- 639
	end -- 639
	if patch.atBench ~= nil then -- 639
		st.backCarry.atBench = patch.atBench -- 640
	end -- 640
end -- 635
function DualRouteContract.prototype.triggerMockReload(self, active, options) -- 643
	local st = self:ensureRehearsal("mock") -- 647
	st.reloadSession.active = active -- 648
	if active then -- 648
		st.reloadSession.elapsed = 0 -- 650
		st.reloadSession.duration = options and options.duration or DEFAULT_RELOAD_DURATION -- 651
		st.reloadSession.path = {} -- 652
		st.reloadSession.previewEffect = "normal" -- 653
		st.reloadSession.invalidFlash = 0 -- 654
		if (options and options.firstTime) ~= nil then -- 654
			st.reloadSession.firstTime = options.firstTime -- 656
		end -- 656
		st.timeScaleOverride = options and options.slowTimeScale or DEFAULT_SLOW_TIME_SCALE -- 658
	else -- 658
		st.reloadSession.elapsed = 0 -- 660
		st.reloadSession.path = {} -- 661
		st.timeScaleOverride = nil -- 662
	end -- 662
end -- 643
function DualRouteContract.prototype.triggerMockBench(self, active, options) -- 666
	local st = self:ensureRehearsal("mock") -- 670
	st.craftBench.active = active -- 671
	st.backCarry.atBench = active -- 672
	if (options and options.inventory) ~= nil then -- 672
		st.craftBench.inventory = cloneRecordNum(options.inventory) -- 674
	end -- 674
	if (options and options.equippedWeapon) ~= nil then -- 674
		st.craftBench.equippedWeapon = options.equippedWeapon -- 677
	end -- 677
end -- 666
function DualRouteContract.prototype.setMockArchive(self, childCleared, soldierCleared, artifactOwned) -- 681
	local st = self:ensureRehearsal("mock") -- 682
	st.archive.childCleared = childCleared -- 683
	st.archive.soldierCleared = soldierCleared -- 684
	if artifactOwned ~= nil then -- 684
		st.archive.artifactOwned = artifactOwned -- 686
	end -- 686
	if childCleared and soldierCleared and st.archive.museumPhase == "locked" then -- 686
		st.archive.museumPhase = "well_open" -- 689
	elseif (not childCleared or not soldierCleared) and st.archive.museumPhase == "well_open" then -- 689
		st.archive.museumPhase = "locked" -- 691
	end -- 691
end -- 681
function DualRouteContract.prototype.enterMockMuseum(self, phase) -- 695
	local st = self:ensureRehearsal("mock") -- 696
	st.archive.museumPhase = phase -- 697
	if phase == "done" then -- 697
		st.archive.museumSeen = true -- 699
	end -- 699
	if phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" or phase == "done" then -- 699
		st.archive.artifactOwned = true -- 708
	end -- 708
end -- 695
function DualRouteContract.prototype.sampleLive(self, p, dt, events) -- 714
	local pRec = asRecord(p) -- 715
	local runRec = asRecord(p.run) -- 716
	local ____asRecord_13 = asRecord -- 717
	local ____temp_12 -- 717
	if runRec ~= nil then -- 717
		____temp_12 = runRec.story -- 717
	else -- 717
		____temp_12 = nil -- 717
	end -- 717
	local storyRec = ____asRecord_13(____temp_12) -- 717
	if dt > 0 and self.liveReloadInvalidFlash > 0 then -- 717
		self.liveReloadInvalidFlash = math.max(0, self.liveReloadInvalidFlash - dt) -- 720
	end -- 720
	if events ~= nil and #events.rawEvents > 0 then -- 720
		local ei = 0 -- 723
		do -- 723
			ei = 0 -- 724
			while ei < #events.rawEvents do -- 724
				local ename = events.rawEvents[ei + 1].name -- 725
				if ename == "handRelease" then -- 725
					self.liveReleasedAbortCount = self.liveReleasedAbortCount + 1 -- 727
				elseif ename == "reloadInvalid" then -- 727
					self.liveReloadInvalidFlash = 0.35 -- 729
				end -- 729
				ei = ei + 1 -- 724
			end -- 724
		end -- 724
	end -- 724
	local ____temp_16 -- 735
	if pRec ~= nil and type(pRec.storyRoute) == "string" and pRec.storyRoute ~= "" then -- 735
		____temp_16 = pRec.storyRoute -- 736
	else -- 736
		local ____temp_15 -- 737
		if storyRec ~= nil and type(storyRec.route) == "string" and storyRec.route ~= "" then -- 737
			____temp_15 = storyRec.route -- 738
		else -- 738
			local ____temp_14 -- 739
			if runRec ~= nil then -- 739
				____temp_14 = runRec.storyRoute -- 739
			else -- 739
				____temp_14 = nil -- 739
			end -- 739
			____temp_15 = ____temp_14 -- 739
		end -- 739
		____temp_16 = ____temp_15 -- 737
	end -- 737
	local rawRoute = ____temp_16 -- 735
	local storyRoute = parseStoryRoute(rawRoute) -- 740
	local countElapsedTicks = readNum(pRec, "countElapsedTicks") or p.countTick -- 743
	local countDurationTicks = math.max( -- 744
		1, -- 744
		readNum(pRec, "countDurationTicks") or GATE_COUNT_END -- 744
	) -- 744
	local countNumber = gateCountAtTick(countElapsedTicks) -- 745
	local countProgress = math.max( -- 746
		0, -- 746
		math.min(1, countElapsedTicks / countDurationTicks) -- 746
	) -- 746
	local ____asRecord_18 = asRecord -- 749
	local ____temp_17 -- 749
	if pRec ~= nil then -- 749
		____temp_17 = pRec.gateReunion -- 749
	else -- 749
		____temp_17 = nil -- 749
	end -- 749
	local grRec = ____asRecord_18(____temp_17) -- 749
	local flatHold = readNum(pRec, "gateHoldProgress") -- 750
	local inGateWaitOrHand = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand") -- 751
	local handTicks = readNum(pRec, "handTicks") or 0 -- 752
	local handNeedTicks = math.max( -- 753
		1, -- 753
		readNum(pRec, "handNeedTicks") or 36 -- 753
	) -- 753
	local handTied = p.room.key == "gate" and p.phase == "gate-hand" -- 754
	local derivedHoldProg = handTied and 1 or (inGateWaitOrHand and math.max( -- 755
		0, -- 755
		math.min(1, handTicks / handNeedTicks) -- 755
	) or 0) -- 755
	local ____readBool_result_19 = readBool(grRec, "active") -- 757
	if ____readBool_result_19 == nil then -- 757
		____readBool_result_19 = inGateWaitOrHand -- 757
	end -- 757
	local ____readBool_result_20 = readBool(grRec, "knockHeard") -- 758
	if ____readBool_result_20 == nil then -- 758
		____readBool_result_20 = inGateWaitOrHand and p.knocks >= 1 -- 758
	end -- 758
	local ____math_max_result_23 = math.max( -- 759
		0, -- 759
		math.min( -- 759
			1, -- 759
			readNum(grRec, "holdProgress") or flatHold or derivedHoldProg -- 759
		) -- 759
	) -- 759
	local ____readBool_result_21 = readBool(grRec, "holding") -- 760
	if ____readBool_result_21 == nil then -- 760
		____readBool_result_21 = inGateWaitOrHand and not handTied and handTicks > 0 -- 760
	end -- 760
	local ____readBool_result_22 = readBool(grRec, "completed") -- 761
	if ____readBool_result_22 == nil then -- 761
		____readBool_result_22 = handTied -- 761
	end -- 761
	local gateReunion = { -- 756
		active = ____readBool_result_19, -- 757
		knockHeard = ____readBool_result_20, -- 758
		holdProgress = ____math_max_result_23, -- 759
		holding = ____readBool_result_21, -- 760
		completed = ____readBool_result_22, -- 761
		releasedAbortCount = readNum(grRec, "releasedAbortCount") or self.liveReleasedAbortCount -- 762
	} -- 762
	local ____asRecord_25 = asRecord -- 766
	local ____temp_24 -- 766
	if pRec ~= nil then -- 766
		____temp_24 = pRec.backCarry -- 766
	else -- 766
		____temp_24 = nil -- 766
	end -- 766
	local bcRec = ____asRecord_25(____temp_24) -- 766
	local ____asRecord_27 = asRecord -- 767
	local ____temp_26 -- 767
	if pRec ~= nil then -- 767
		____temp_26 = pRec.craftBench -- 767
	else -- 767
		____temp_26 = nil -- 767
	end -- 767
	local cbRecEarly = ____asRecord_27(____temp_26) -- 767
	local ____readBool_result_28 = readBool(cbRecEarly, "active") -- 768
	if ____readBool_result_28 == nil then -- 768
		____readBool_result_28 = false -- 768
	end -- 768
	local benchActiveLive = ____readBool_result_28 -- 768
	local ____readBool_result_29 = readBool(pRec, "carryOn") -- 769
	if ____readBool_result_29 == nil then -- 769
		____readBool_result_29 = readBool(storyRec, "carry") -- 769
	end -- 769
	local ____readBool_result_29_30 = ____readBool_result_29 -- 769
	if ____readBool_result_29_30 == nil then -- 769
		____readBool_result_29_30 = false -- 769
	end -- 769
	local carryOn = ____readBool_result_29_30 -- 769
	local handInHandLive = handTied or p.room.key == "gatepath" and not carryOn -- 770
	local ____readBool_result_31 = readBool(bcRec, "active") -- 772
	if ____readBool_result_31 == nil then -- 772
		____readBool_result_31 = carryOn -- 772
	end -- 772
	local ____readBool_result_32 = readBool(bcRec, "handInHand") -- 773
	if ____readBool_result_32 == nil then -- 773
		____readBool_result_32 = handInHandLive -- 773
	end -- 773
	local ____readBool_result_33 = readBool(bcRec, "mounting") -- 774
	if ____readBool_result_33 == nil then -- 774
		____readBool_result_33 = p.room.key == "gatepath" and carryOn -- 774
	end -- 774
	local ____readBool_result_34 = readBool(bcRec, "atBench") -- 775
	if ____readBool_result_34 == nil then -- 775
		____readBool_result_34 = benchActiveLive -- 775
	end -- 775
	local backCarry = {active = ____readBool_result_31, handInHand = ____readBool_result_32, mounting = ____readBool_result_33, atBench = ____readBool_result_34} -- 771
	local ____asRecord_36 = asRecord -- 779
	local ____temp_35 -- 779
	if pRec ~= nil then -- 779
		____temp_35 = pRec.reloadSession -- 779
	else -- 779
		____temp_35 = nil -- 779
	end -- 779
	local rsRec = ____asRecord_36(____temp_35) -- 779
	local ____readBool_result_37 = readBool(pRec, "reloadOpen") -- 780
	if ____readBool_result_37 == nil then -- 780
		____readBool_result_37 = false -- 780
	end -- 780
	local reloadOpenLive = ____readBool_result_37 -- 780
	local ____readBool_result_38 = readBool(rsRec, "active") -- 781
	if ____readBool_result_38 == nil then -- 781
		____readBool_result_38 = reloadOpenLive -- 781
	end -- 781
	local reloadActive = ____readBool_result_38 -- 781
	local reloadAnswerTicks = readNum(pRec, "reloadAnswerTicks") or 0 -- 782
	local reloadTryCount = readNum(pRec, "reloadTryCount") or 0 -- 783
	local livePath = readNumArray(rsRec, "path") or readNumArray(pRec, "reloadPath") or ({}) -- 784
	local ____temp_41 -- 785
	if rsRec ~= nil and rsRec.nextEffect ~= nil then -- 785
		____temp_41 = rsRec.nextEffect -- 786
	else -- 786
		local ____temp_40 -- 787
		if pRec ~= nil and pRec.reloadPendingEffect ~= nil then -- 787
			____temp_40 = pRec.reloadPendingEffect -- 788
		else -- 788
			local ____temp_39 -- 789
			if pRec ~= nil then -- 789
				____temp_39 = pRec.nextEffect -- 789
			else -- 789
				____temp_39 = nil -- 789
			end -- 789
			____temp_40 = ____temp_39 -- 789
		end -- 789
		____temp_41 = ____temp_40 -- 787
	end -- 787
	local liveNextRaw = ____temp_41 -- 785
	local livePreview = rsRec ~= nil and rsRec.previewEffect ~= nil and parseReloadEffect(rsRec.previewEffect) or (reloadActive and deriveReloadEffectFromPath(livePath) or "normal") -- 790
	local ____readBool_result_42 = readBool(rsRec, "firstTime") -- 796
	if ____readBool_result_42 == nil then -- 796
		____readBool_result_42 = reloadTryCount <= 1 -- 796
	end -- 796
	local reloadSession = { -- 794
		active = reloadActive, -- 795
		firstTime = ____readBool_result_42, -- 796
		elapsed = readNum(rsRec, "elapsed") or reloadAnswerTicks / 60, -- 797
		duration = math.max( -- 798
			0.01, -- 798
			readNum(rsRec, "duration") or DEFAULT_RELOAD_DURATION -- 798
		), -- 798
		path = livePath, -- 799
		previewEffect = livePreview, -- 800
		nextEffect = parseReloadEffect(liveNextRaw), -- 801
		invalidFlash = readNum(rsRec, "invalidFlash") or self.liveReloadInvalidFlash -- 802
	} -- 802
	local rawScale = readNum(pRec, "timeScale") or readNum(runRec, "timeScale") -- 805
	local timeScale = rawScale ~= nil and rawScale >= 0 and rawScale or (reloadActive and DEFAULT_SLOW_TIME_SCALE or 1) -- 806
	local ____asRecord_44 = asRecord -- 811
	local ____temp_43 -- 811
	if pRec ~= nil then -- 811
		____temp_43 = pRec.craftBench -- 811
	else -- 811
		____temp_43 = nil -- 811
	end -- 811
	local cbRec = ____asRecord_44(____temp_43) -- 811
	local craftBench = self:readLiveCraftBench(cbRec, pRec, runRec) -- 812
	local archive = self:readLiveArchive(p) -- 815
	self.liveArchiveCache = archive -- 816
	local visualMode = deriveVisualMode( -- 818
		p.room.key, -- 819
		p.phase, -- 820
		storyRoute, -- 821
		archive.museumPhase, -- 822
		countProgress, -- 823
		gateReunion.completed -- 824
	) -- 824
	return { -- 827
		storyRoute = storyRoute, -- 828
		countElapsedTicks = countElapsedTicks, -- 829
		countDurationTicks = countDurationTicks, -- 830
		countNumber = countNumber, -- 831
		countProgress = countProgress, -- 832
		gateReunion = gateReunion, -- 833
		backCarry = backCarry, -- 834
		timeScale = timeScale, -- 835
		reloadSession = reloadSession, -- 836
		craftBench = craftBench, -- 837
		archive = archive, -- 838
		assistHintsEnabled = self.assistHintsEnabled, -- 839
		visualMode = visualMode, -- 840
		dataSource = "live", -- 841
		isRehearsal = false, -- 842
		rehearsalTag = "" -- 843
	} -- 843
end -- 714
function DualRouteContract.prototype.readLiveCraftBench(self, cbRec, pRec, runRec) -- 847
	local recipes = defaultRecipes() -- 852
	if cbRec ~= nil and __TS__ArrayIsArray(cbRec.recipes) then -- 852
		local rawList = cbRec.recipes -- 854
		local parsed = {} -- 855
		local i = 0 -- 856
		do -- 856
			i = 0 -- 857
			while i < #rawList do -- 857
				do -- 857
					local item = asRecord(rawList[i + 1]) -- 858
					if item == nil then -- 858
						goto __continue126 -- 860
					end -- 860
					local id = readStr(item, "id") -- 862
					local name = readStr(item, "name") -- 863
					if id == nil or name == nil then -- 863
						goto __continue126 -- 865
					end -- 865
					local ____id_46 = id -- 868
					local ____name_47 = name -- 869
					local ____temp_48 = readStr(item, "desc") or "" -- 870
					local ____parseReloadEffect_result_49 = parseReloadEffect(item.enhancedEffect) -- 871
					local ____temp_50 = readNumMap(item, "cost") or ({}) -- 872
					local ____readBool_result_45 = readBool(item, "crafted") -- 873
					if ____readBool_result_45 == nil then -- 873
						____readBool_result_45 = false -- 873
					end -- 873
					parsed[#parsed + 1] = { -- 867
						id = ____id_46, -- 868
						name = ____name_47, -- 869
						desc = ____temp_48, -- 870
						enhancedEffect = ____parseReloadEffect_result_49, -- 871
						cost = ____temp_50, -- 872
						crafted = ____readBool_result_45 -- 873
					} -- 873
				end -- 873
				::__continue126:: -- 873
				i = i + 1 -- 857
			end -- 857
		end -- 857
		if #parsed > 0 then -- 857
			local ____readBool_result_51 = readBool(cbRec, "active") -- 878
			if ____readBool_result_51 == nil then -- 878
				____readBool_result_51 = false -- 878
			end -- 878
			local ____readBool_result_52 = readBool(cbRec, "firstCraftDone") -- 879
			if ____readBool_result_52 == nil then -- 879
				____readBool_result_52 = false -- 879
			end -- 879
			return { -- 877
				active = ____readBool_result_51, -- 878
				firstCraftDone = ____readBool_result_52, -- 879
				justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 880
				inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or ({}), -- 881
				recipes = parsed, -- 882
				equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 883
			} -- 883
		end -- 883
	end -- 883
	local ____readBool_result_53 = readBool(cbRec, "active") -- 888
	if ____readBool_result_53 == nil then -- 888
		____readBool_result_53 = false -- 888
	end -- 888
	local ____readBool_result_54 = readBool(cbRec, "firstCraftDone") -- 889
	if ____readBool_result_54 == nil then -- 889
		____readBool_result_54 = false -- 889
	end -- 889
	return { -- 887
		active = ____readBool_result_53, -- 888
		firstCraftDone = ____readBool_result_54, -- 889
		justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 890
		inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or readNumMap(runRec, "craftInventory") or ({}), -- 891
		recipes = recipes, -- 892
		equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 893
	} -- 893
end -- 847
function DualRouteContract.prototype.readLiveArchive(self, p) -- 897
	local pRec = asRecord(p) -- 898
	local runRec = asRecord(p.run) -- 899
	local ____asRecord_56 = asRecord -- 900
	local ____temp_55 -- 900
	if pRec ~= nil then -- 900
		____temp_55 = pRec.archive -- 900
	else -- 900
		____temp_55 = nil -- 900
	end -- 900
	local ____asRecord_56_result_59 = ____asRecord_56(____temp_55) -- 900
	if ____asRecord_56_result_59 == nil then -- 900
		local ____asRecord_58 = asRecord -- 901
		local ____temp_57 -- 901
		if runRec ~= nil then -- 901
			____temp_57 = runRec.archive -- 901
		else -- 901
			____temp_57 = nil -- 901
		end -- 901
		____asRecord_56_result_59 = ____asRecord_58(____temp_57) -- 900
	end -- 900
	local archRec = ____asRecord_56_result_59 -- 900
	local ____readBool_result_60 = readBool(archRec, "childCleared") -- 903
	if ____readBool_result_60 == nil then -- 903
		____readBool_result_60 = readBool(pRec, "childCleared") -- 903
	end -- 903
	local ____readBool_result_60_61 = ____readBool_result_60 -- 903
	if ____readBool_result_60_61 == nil then -- 903
		____readBool_result_60_61 = false -- 903
	end -- 903
	local childCleared = ____readBool_result_60_61 -- 903
	local ____readBool_result_62 = readBool(archRec, "soldierCleared") -- 904
	if ____readBool_result_62 == nil then -- 904
		____readBool_result_62 = readBool(pRec, "soldierCleared") -- 904
	end -- 904
	local ____readBool_result_62_63 = ____readBool_result_62 -- 904
	if ____readBool_result_62_63 == nil then -- 904
		____readBool_result_62_63 = false -- 904
	end -- 904
	local soldierCleared = ____readBool_result_62_63 -- 904
	local ____readBool_result_64 = readBool(archRec, "artifactOwned") -- 905
	if ____readBool_result_64 == nil then -- 905
		____readBool_result_64 = readBool(pRec, "artifactOwned") -- 905
	end -- 905
	local ____readBool_result_64_65 = ____readBool_result_64 -- 905
	if ____readBool_result_64_65 == nil then -- 905
		____readBool_result_64_65 = false -- 905
	end -- 905
	local artifactOwned = ____readBool_result_64_65 -- 905
	local ____temp_67 -- 906
	if archRec ~= nil and archRec.museumPhase ~= nil then -- 906
		____temp_67 = archRec.museumPhase -- 907
	else -- 907
		local ____temp_66 -- 908
		if pRec ~= nil then -- 908
			____temp_66 = pRec.museumPhase -- 908
		else -- 908
			____temp_66 = nil -- 908
		end -- 908
		____temp_67 = ____temp_66 -- 908
	end -- 908
	local rawPhase = ____temp_67 -- 906
	local museumPhase = parseMuseumPhase(rawPhase) -- 909
	local ____readBool_result_68 = readBool(archRec, "museumSeen") -- 910
	if ____readBool_result_68 == nil then -- 910
		____readBool_result_68 = readBool(pRec, "museumSeen") -- 910
	end -- 910
	local ____readBool_result_68_69 = ____readBool_result_68 -- 910
	if ____readBool_result_68_69 == nil then -- 910
		____readBool_result_68_69 = false -- 910
	end -- 910
	local museumSeen = ____readBool_result_68_69 -- 910
	return { -- 912
		childCleared = childCleared, -- 913
		soldierCleared = soldierCleared, -- 914
		artifactOwned = artifactOwned, -- 915
		museumPhase = museumPhase, -- 916
		museumSeen = museumSeen -- 917
	} -- 917
end -- 897
function DualRouteContract.prototype.forwardLiveIntent(self, p, intent) -- 921
	if intent.kind == "craftSubmit" then -- 921
		if self.livePendingCraftRequests[intent.requestId] == true then -- 921
			return false -- 924
		end -- 924
		self.livePendingCraftRequests[intent.requestId] = true -- 926
	end -- 926
	local pRec = asRecord(p) -- 928
	if pRec == nil then -- 928
		return false -- 930
	end -- 930
	local handler = pRec.submitFeIntent -- 932
	if type(handler) == "function" then -- 932
		local result = handler(p, intent) -- 934
		return result ~= false -- 935
	end -- 935
	local tapNode = pRec.reloadTapNode -- 938
	if type(tapNode) == "function" then -- 938
		local fn = tapNode -- 940
		if intent.kind == "reloadTapNode" then -- 940
			fn(p, intent.node) -- 942
			return true -- 943
		end -- 943
		if intent.kind == "reloadPathCommit" and #intent.path > 0 then -- 943
			local i = 0 -- 946
			do -- 946
				i = 0 -- 947
				while i < #intent.path do -- 947
					do -- 947
						if i == 0 and intent.path[i + 1] == 0 then -- 947
							goto __continue140 -- 949
						end -- 949
						fn(p, intent.path[i + 1]) -- 951
					end -- 951
					::__continue140:: -- 951
					i = i + 1 -- 947
				end -- 947
			end -- 947
			return true -- 953
		end -- 953
	end -- 953
	return false -- 956
end -- 921
function DualRouteContract.prototype.sampleRehearsal(self, p, dt, input, st) -- 961
	local countElapsedTicks = st.countTickOverride ~= nil and st.countTickOverride or p.countTick -- 962
	local countDurationTicks = math.max(1, st.countDurationOverride or GATE_COUNT_END) -- 963
	local countNumber = gateCountAtTick(countElapsedTicks) -- 964
	local countProgress = math.max( -- 965
		0, -- 965
		math.min(1, countElapsedTicks / countDurationTicks) -- 965
	) -- 965
	if p.room.key == "gate" and p.phase == "gate-count" and st.storyRoute == "soldier" then -- 965
		if countElapsedTicks < countDurationTicks then -- 965
			st.gateReunion.active = false -- 970
			st.gateReunion.knockHeard = false -- 971
			st.gateReunion.holding = false -- 972
			st.gateReunion.holdProgress = 0 -- 973
			st.gateHoldArmed = not input.interact.held -- 974
			st.gatePrevInteractHeld = input.interact.held -- 975
		elseif not st.gateReunion.completed then -- 975
			st.gateReunion.active = true -- 977
			st.gateReunion.knockHeard = true -- 978
			if not st.gateHoldArmed and not input.interact.held then -- 978
				st.gateHoldArmed = true -- 980
			end -- 980
			if dt > 0 then -- 980
				if st.gateHoldArmed and input.interact.held then -- 980
					st.gateReunion.holding = true -- 984
					st.gateReunion.holdProgress = math.min(1, st.gateReunion.holdProgress + dt / GATE_REUNION_HOLD_SECONDS) -- 985
					if st.gateReunion.holdProgress >= 1 then -- 985
						st.gateReunion.holdProgress = 1 -- 990
						st.gateReunion.holding = false -- 991
						st.gateReunion.completed = true -- 992
						st.backCarry.handInHand = true -- 993
					end -- 993
				else -- 993
					if st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 993
						local ____st_gateReunion_70, ____releasedAbortCount_71 = st.gateReunion, "releasedAbortCount" -- 993
						____st_gateReunion_70[____releasedAbortCount_71] = ____st_gateReunion_70[____releasedAbortCount_71] + 1 -- 997
					end -- 997
					st.gateReunion.holding = false -- 999
					st.gateReunion.holdProgress = 0 -- 1000
				end -- 1000
			end -- 1000
			st.gatePrevInteractHeld = input.interact.held -- 1003
		end -- 1003
	end -- 1003
	if st.reloadSession.active and dt > 0 then -- 1003
		local ____st_reloadSession_72, ____elapsed_73 = st.reloadSession, "elapsed" -- 1003
		____st_reloadSession_72[____elapsed_73] = ____st_reloadSession_72[____elapsed_73] + dt -- 1009
		if st.reloadSession.invalidFlash > 0 then -- 1009
			st.reloadSession.invalidFlash = math.max(0, st.reloadSession.invalidFlash - dt) -- 1011
		end -- 1011
		if st.reloadSession.elapsed >= st.reloadSession.duration then -- 1011
			st.reloadSession.active = false -- 1014
			st.reloadSession.elapsed = 0 -- 1015
			st.reloadSession.path = {} -- 1016
			st.reloadSession.previewEffect = "normal" -- 1017
			st.reloadSession.nextEffect = "normal" -- 1018
			st.reloadSession.firstTime = false -- 1019
			st.timeScaleOverride = nil -- 1020
		end -- 1020
	end -- 1020
	if st.craftBench.justCraftedTimer > 0 and dt > 0 then -- 1020
		st.craftBench.justCraftedTimer = math.max(0, st.craftBench.justCraftedTimer - dt) -- 1026
	end -- 1026
	local timeScale = st.timeScaleOverride ~= nil and math.max(0, st.timeScaleOverride) or (st.reloadSession.active and DEFAULT_SLOW_TIME_SCALE or 1) -- 1029
	local visualMode = deriveVisualMode( -- 1033
		p.room.key, -- 1034
		p.phase, -- 1035
		st.storyRoute, -- 1036
		st.archive.museumPhase, -- 1037
		countProgress, -- 1038
		st.gateReunion.completed -- 1039
	) -- 1039
	return { -- 1042
		storyRoute = st.storyRoute, -- 1043
		countElapsedTicks = countElapsedTicks, -- 1044
		countDurationTicks = countDurationTicks, -- 1045
		countNumber = countNumber, -- 1046
		countProgress = countProgress, -- 1047
		gateReunion = { -- 1048
			active = st.gateReunion.active, -- 1049
			knockHeard = st.gateReunion.knockHeard, -- 1050
			holdProgress = st.gateReunion.holdProgress, -- 1051
			holding = st.gateReunion.holding, -- 1052
			completed = st.gateReunion.completed, -- 1053
			releasedAbortCount = st.gateReunion.releasedAbortCount -- 1054
		}, -- 1054
		backCarry = {active = st.backCarry.active, handInHand = st.backCarry.handInHand, mounting = st.backCarry.mounting, atBench = st.backCarry.atBench}, -- 1056
		timeScale = timeScale, -- 1062
		reloadSession = { -- 1063
			active = st.reloadSession.active, -- 1064
			firstTime = st.reloadSession.firstTime, -- 1065
			elapsed = st.reloadSession.elapsed, -- 1066
			duration = st.reloadSession.duration, -- 1067
			path = __TS__ArraySlice(st.reloadSession.path), -- 1068
			previewEffect = st.reloadSession.previewEffect, -- 1069
			nextEffect = st.reloadSession.nextEffect, -- 1070
			invalidFlash = st.reloadSession.invalidFlash -- 1071
		}, -- 1071
		craftBench = { -- 1073
			active = st.craftBench.active, -- 1074
			firstCraftDone = st.craftBench.firstCraftDone, -- 1075
			justCraftedTimer = st.craftBench.justCraftedTimer, -- 1076
			inventory = cloneRecordNum(st.craftBench.inventory), -- 1077
			recipes = cloneRecipes(st.craftBench.recipes), -- 1078
			equippedWeapon = st.craftBench.equippedWeapon -- 1079
		}, -- 1079
		archive = { -- 1081
			childCleared = st.archive.childCleared, -- 1082
			soldierCleared = st.archive.soldierCleared, -- 1083
			artifactOwned = st.archive.artifactOwned, -- 1084
			museumPhase = st.archive.museumPhase, -- 1085
			museumSeen = st.archive.museumSeen -- 1086
		}, -- 1086
		assistHintsEnabled = self.assistHintsEnabled, -- 1088
		visualMode = visualMode, -- 1089
		dataSource = "rehearsal", -- 1090
		isRehearsal = true, -- 1091
		rehearsalTag = st.tag -- 1092
	} -- 1092
end -- 961
function DualRouteContract.prototype.applyRehearsalIntent(self, st, intent) -- 1096
	if intent.kind == "gateReunionHold" then -- 1096
		if not st.gateReunion.active or st.gateReunion.completed then -- 1096
			return false -- 1099
		end -- 1099
		if not intent.holding and st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1099
			local ____st_gateReunion_74, ____releasedAbortCount_75 = st.gateReunion, "releasedAbortCount" -- 1099
			____st_gateReunion_74[____releasedAbortCount_75] = ____st_gateReunion_74[____releasedAbortCount_75] + 1 -- 1102
			st.gateReunion.holdProgress = 0 -- 1103
		end -- 1103
		st.gateReunion.holding = intent.holding -- 1105
		return true -- 1106
	end -- 1106
	if intent.kind == "reloadOpen" then -- 1106
		self:triggerMockReload(true) -- 1109
		return true -- 1110
	end -- 1110
	if intent.kind == "reloadTapNode" then -- 1110
		if not st.reloadSession.active then -- 1110
			return false -- 1114
		end -- 1114
		if #st.reloadSession.path == 0 then -- 1114
			local ____st_reloadSession_path_76 = st.reloadSession.path -- 1114
			____st_reloadSession_path_76[#____st_reloadSession_path_76 + 1] = 0 -- 1117
		end -- 1117
		if __TS__ArrayIndexOf(st.reloadSession.path, intent.node) >= 0 then -- 1117
			st.reloadSession.invalidFlash = 0.35 -- 1120
			st.reloadSession.path = {0} -- 1121
			st.reloadSession.previewEffect = "normal" -- 1122
			return false -- 1123
		end -- 1123
		local ____st_reloadSession_path_77 = st.reloadSession.path -- 1123
		____st_reloadSession_path_77[#____st_reloadSession_path_77 + 1] = intent.node -- 1125
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(st.reloadSession.path) -- 1126
		if intent.node == 8 then -- 1126
			st.reloadSession.nextEffect = st.reloadSession.previewEffect -- 1128
			st.reloadSession.active = false -- 1129
			st.reloadSession.elapsed = 0 -- 1130
			st.reloadSession.path = {} -- 1131
			st.reloadSession.firstTime = false -- 1132
			st.timeScaleOverride = nil -- 1133
		end -- 1133
		return true -- 1135
	end -- 1135
	if intent.kind == "reloadPathPreview" then -- 1135
		if not st.reloadSession.active then -- 1135
			return false -- 1139
		end -- 1139
		st.reloadSession.path = __TS__ArraySlice(intent.path) -- 1141
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(intent.path) -- 1142
		return true -- 1143
	end -- 1143
	if intent.kind == "reloadPathCommit" then -- 1143
		if not st.reloadSession.active then -- 1143
			return false -- 1147
		end -- 1147
		if #intent.path < 2 then -- 1147
			st.reloadSession.invalidFlash = 0.35 -- 1150
			st.reloadSession.path = {} -- 1151
			st.reloadSession.previewEffect = "normal" -- 1152
			return false -- 1153
		end -- 1153
		local effect = deriveReloadEffectFromPath(intent.path) -- 1155
		st.reloadSession.nextEffect = effect -- 1156
		st.reloadSession.previewEffect = effect -- 1157
		st.reloadSession.path = {} -- 1158
		st.reloadSession.active = false -- 1159
		st.reloadSession.elapsed = 0 -- 1160
		st.reloadSession.firstTime = false -- 1161
		st.timeScaleOverride = nil -- 1162
		return true -- 1163
	end -- 1163
	if intent.kind == "reloadCancel" then -- 1163
		st.reloadSession.active = false -- 1166
		st.reloadSession.elapsed = 0 -- 1167
		st.reloadSession.path = {} -- 1168
		st.reloadSession.previewEffect = "normal" -- 1169
		st.timeScaleOverride = nil -- 1170
		return true -- 1171
	end -- 1171
	if intent.kind == "craftSubmit" then -- 1171
		if not st.craftBench.active or st.handledCraftRequestIds[intent.requestId] == true then -- 1171
			return false -- 1175
		end -- 1175
		local target -- 1177
		local i = 0 -- 1178
		do -- 1178
			i = 0 -- 1179
			while i < #st.craftBench.recipes do -- 1179
				if st.craftBench.recipes[i + 1].id == intent.recipeId then -- 1179
					target = st.craftBench.recipes[i + 1] -- 1181
					break -- 1182
				end -- 1182
				i = i + 1 -- 1179
			end -- 1179
		end -- 1179
		if target == nil or target.crafted then -- 1179
			return false -- 1186
		end -- 1186
		for mat in pairs(target.cost) do -- 1188
			if (st.craftBench.inventory[mat] or 0) < target.cost[mat] then -- 1188
				return false -- 1190
			end -- 1190
		end -- 1190
		for mat in pairs(target.cost) do -- 1193
			st.craftBench.inventory[mat] = (st.craftBench.inventory[mat] or 0) - target.cost[mat] -- 1194
		end -- 1194
		st.handledCraftRequestIds[intent.requestId] = true -- 1196
		target.crafted = true -- 1197
		st.craftBench.equippedWeapon = target.id -- 1198
		st.craftBench.justCraftedTimer = st.craftBench.firstCraftDone and 0.45 or 1 -- 1199
		st.craftBench.firstCraftDone = true -- 1200
		return true -- 1201
	end -- 1201
	if intent.kind == "craftEquip" then -- 1201
		st.craftBench.equippedWeapon = intent.weaponId -- 1204
		return true -- 1205
	end -- 1205
	if intent.kind == "craftClose" then -- 1205
		st.craftBench.active = false -- 1208
		st.backCarry.atBench = false -- 1209
		return true -- 1210
	end -- 1210
	if intent.kind == "museumInteract" then -- 1210
		if intent.target == "well_pickup" and st.archive.museumPhase == "well_open" then -- 1210
			st.archive.artifactOwned = true -- 1214
			st.archive.museumPhase = "well_reflect" -- 1215
			return true -- 1216
		end -- 1216
		if intent.target == "lamp_turn" and st.archive.museumPhase == "hall_walk" then -- 1216
			st.archive.museumPhase = "lamp_turn" -- 1219
			return true -- 1220
		end -- 1220
		if intent.target == "return_cabinet" then -- 1220
			st.archive.museumPhase = "done" -- 1223
			st.archive.museumSeen = true -- 1224
			return true -- 1225
		end -- 1225
		return false -- 1227
	end -- 1227
	return false -- 1229
end -- 1096
return ____exports -- 1096