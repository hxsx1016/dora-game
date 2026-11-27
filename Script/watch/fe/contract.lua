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
	}, { -- 173
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
	if value ~= nil and type(value) == "table" then -- 284
		return value -- 285
	end -- 285
	return nil -- 287
end -- 283
local function readNum(rec, key) -- 290
	if rec == nil then -- 291
		return nil -- 292
	end -- 292
	local v = rec[key] -- 294
	return type(v) == "number" and v or nil -- 295
end -- 290
local function readBool(rec, key) -- 298
	if rec == nil then -- 299
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
	if rec == nil then -- 307
		return nil -- 308
	end -- 308
	local v = rec[key] -- 310
	return type(v) == "string" and v or nil -- 311
end -- 306
local function readNumArray(rec, key) -- 314
	if rec == nil then -- 315
		return nil -- 316
	end -- 316
	local v = rec[key] -- 318
	if not __TS__ArrayIsArray(v) then -- 319
		return nil -- 320
	end -- 320
	local out = {} -- 322
	local i = 0 -- 323
	do -- 323
		i = 0 -- 324
		while i < #v do -- 324
			if type(v[i + 1]) == "number" then -- 325
				out[#out + 1] = v[i + 1] -- 326
			end -- 326
			i = i + 1 -- 324
		end -- 324
	end -- 324
	return out -- 329
end -- 314
local function readNumMap(rec, key) -- 332
	if rec == nil then -- 333
		return nil -- 334
	end -- 334
	local obj = asRecord(rec[key]) -- 336
	if obj == nil then -- 337
		return nil -- 338
	end -- 338
	local out = {} -- 340
	for k in pairs(obj) do -- 341
		local val = obj[k] -- 342
		if type(val) == "number" then -- 343
			out[k] = val -- 344
		end -- 344
	end -- 344
	return out -- 347
end -- 332
local function parseStoryRoute(v) -- 350
	if v == "child" or v == "soldier" then -- 351
		return v -- 352
	end -- 352
	return "undecided" -- 354
end -- 350
local function parseReloadEffect(v) -- 357
	if v == "push" or v == "knockback" then -- 358
		return "knockback" -- 359
	end -- 359
	if v == "echo" or v == "light" then -- 361
		return v -- 362
	end -- 362
	return "normal" -- 364
end -- 357
local function parseMuseumPhase(v) -- 367
	if v == "well_open" or v == "well_reflect" or v == "hall_walk" or v == "lamp_turn" or v == "return_cabinet" or v == "done" then -- 369
		return v -- 376
	end -- 376
	return "locked" -- 378
end -- 367
--- 根据 3×3 路径点集合推导效果（对齐后端 reload.ts 布局）：
-- - 0 = 左下起点，8 = 右上枪机复位终点；
-- - 4 = 中心铃纹（echo，优先），2 = 右下灯纹（light），其余有效路径 = 推退（knockback）。
local function deriveReloadEffectFromPath(path) -- 386
	if #path < 2 then -- 387
		return "normal" -- 388
	end -- 388
	local hasBell = false -- 390
	local hasLamp = false -- 391
	local i = 0 -- 392
	do -- 392
		i = 0 -- 393
		while i < #path do -- 393
			if path[i + 1] == 4 then -- 394
				hasBell = true -- 395
			elseif path[i + 1] == 2 then -- 396
				hasLamp = true -- 397
			end -- 397
			i = i + 1 -- 393
		end -- 393
	end -- 393
	if hasBell then -- 400
		return "echo" -- 401
	end -- 401
	if hasLamp then -- 403
		return "light" -- 404
	end -- 404
	return "knockback" -- 406
end -- 386
local function deriveVisualMode(roomKey, phase, storyRoute, museumPhase, countProgress, reunionCompleted) -- 409
	if roomKey == "museum" or museumPhase == "well_reflect" or museumPhase == "hall_walk" or museumPhase == "lamp_turn" or museumPhase == "return_cabinet" then -- 418
		return "museum" -- 424
	end -- 424
	if roomKey == "gate" then -- 426
		if phase == "gate-hand" then -- 427
			return "pixel" -- 428
		end -- 428
		if phase == "gate-wait" then -- 430
			return reunionCompleted and "pixel" or "lowpoly" -- 431
		end -- 431
		if phase == "gate-count" then -- 433
			if storyRoute == "soldier" and reunionCompleted then -- 434
				return "pixel" -- 435
			end -- 435
			if countProgress <= 0 then -- 437
				return "pixel" -- 438
			end -- 438
			if countProgress >= 1 then -- 440
				return "lowpoly" -- 441
			end -- 441
			return "transition" -- 443
		end -- 443
		if phase == "gate-walk" then -- 445
			return storyRoute == "soldier" and "pixel" or (storyRoute == "child" and "lowpoly" or "pixel") -- 446
		end -- 446
		return "pixel" -- 448
	end -- 448
	if roomKey == "gatepath" or roomKey == "escort1" or roomKey == "escort2" or roomKey == "escort3" or roomKey == "escort4" or roomKey == "escort5" then -- 450
		return "pixel" -- 452
	end -- 452
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" then -- 454
		if storyRoute == "child" then -- 455
			return "lowpoly" -- 456
		end -- 456
		return "pixel" -- 458
	end -- 458
	return "pixel" -- 460
end -- 409
____exports.DualRouteContract = __TS__Class() -- 463
local DualRouteContract = ____exports.DualRouteContract -- 463
DualRouteContract.name = "DualRouteContract" -- 463
function DualRouteContract.prototype.____constructor(self) -- 463
	self.source = "live" -- 464
	self.assistHintsEnabled = false -- 467
	self.livePendingCraftRequests = {} -- 469
	self.liveReleasedAbortCount = 0 -- 471
	self.liveReloadInvalidFlash = 0 -- 472
	self.liveArchiveCache = createEmptyArchive() -- 473
	self.intentLog = {} -- 474
end -- 463
function DualRouteContract.prototype.getDataSource(self) -- 478
	return self.source -- 479
end -- 478
function DualRouteContract.prototype.isRehearsal(self) -- 483
	return self.source == "rehearsal" and self.rehearsal ~= nil -- 484
end -- 483
function DualRouteContract.prototype.enterRehearsal(self, tag) -- 488
	if tag == nil then -- 488
		tag = "rehearsal" -- 488
	end -- 488
	self.source = "rehearsal" -- 489
	if self.rehearsal == nil then -- 490
		self.rehearsal = createInitialRehearsalState(tag) -- 491
	else -- 491
		self.rehearsal.tag = tag -- 493
	end -- 493
end -- 488
function DualRouteContract.prototype.exitRehearsal(self) -- 498
	self.source = "live" -- 499
	self.rehearsal = nil -- 500
end -- 498
function DualRouteContract.prototype.ensureRehearsal(self, tag) -- 503
	if tag == nil then -- 503
		tag = "mock" -- 503
	end -- 503
	if self.source ~= "rehearsal" or self.rehearsal == nil then -- 504
		self:enterRehearsal(tag) -- 505
	end -- 505
	return self.rehearsal -- 507
end -- 503
function DualRouteContract.prototype.isAssistHintsEnabled(self) -- 510
	return self.assistHintsEnabled -- 511
end -- 510
function DualRouteContract.prototype.setAssistHintsEnabled(self, enabled) -- 514
	self.assistHintsEnabled = enabled -- 515
end -- 514
function DualRouteContract.prototype.toggleAssistHints(self) -- 518
	self.assistHintsEnabled = not self.assistHintsEnabled -- 519
	return self.assistHintsEnabled -- 520
end -- 518
function DualRouteContract.prototype.getLastSnapshot(self) -- 523
	return self.lastSnapshot -- 524
end -- 523
function DualRouteContract.prototype.peekSnapshot(self, p) -- 528
	local neutralInput = {interact = {held = false, pressed = false, released = false}} -- 529
	return self:sample(p, 0, neutralInput) -- 532
end -- 528
function DualRouteContract.prototype.getIntentLog(self) -- 535
	return self.intentLog -- 536
end -- 535
function DualRouteContract.prototype.clearIntentLog(self) -- 539
	self.intentLog = {} -- 540
end -- 539
function DualRouteContract.prototype.resetForRoom(self, p) -- 550
	self.livePendingCraftRequests = {} -- 551
	self.liveReleasedAbortCount = 0 -- 552
	self.liveReloadInvalidFlash = 0 -- 553
	self.liveArchiveCache = self:readLiveArchive(p) -- 554
	if self.rehearsal ~= nil then -- 555
		self.rehearsal.gateReunion = createEmptyGateReunion() -- 556
		self.rehearsal.gateHoldArmed = true -- 557
		self.rehearsal.gatePrevInteractHeld = false -- 558
		self.rehearsal.reloadSession = createEmptyReloadSession() -- 559
		self.rehearsal.craftBench.active = false -- 560
		self.rehearsal.craftBench.justCraftedTimer = 0 -- 561
		self.rehearsal.handledCraftRequestIds = {} -- 562
		self.rehearsal.timeScaleOverride = nil -- 563
	end -- 563
end -- 550
function DualRouteContract.prototype.sample(self, p, rawDt, input, events) -- 573
	local dt = p.paused and 0 or math.max(0, rawDt) -- 574
	local snap = self.source == "rehearsal" and self.rehearsal ~= nil and self:sampleRehearsal(p, dt, input, self.rehearsal) or self:sampleLive(p, dt, events) -- 575
	self.lastSnapshot = snap -- 578
	return snap -- 579
end -- 573
function DualRouteContract.prototype.submitIntent(self, p, intent) -- 587
	local accepted = false -- 588
	if self.source == "rehearsal" and self.rehearsal ~= nil then -- 589
		accepted = self:applyRehearsalIntent(self.rehearsal, intent) -- 590
	else -- 590
		accepted = self:forwardLiveIntent(p, intent) -- 592
	end -- 592
	local ____self_intentLog_1 = self.intentLog -- 594
	____self_intentLog_1[#____self_intentLog_1 + 1] = {tick = p.ticks, source = self.source, intent = intent, accepted = accepted} -- 594
	if #self.intentLog > MAX_INTENT_LOG then -- 600
		table.remove(self.intentLog, 1) -- 601
	end -- 601
	return accepted -- 603
end -- 587
function DualRouteContract.prototype.setMockRoute(self, route) -- 608
	local st = self:ensureRehearsal("mock") -- 609
	st.storyRoute = route -- 610
end -- 608
function DualRouteContract.prototype.setMockCountTick(self, tick, duration) -- 613
	local st = self:ensureRehearsal("mock") -- 614
	st.countTickOverride = tick -- 615
	if duration ~= nil and duration > 0 then -- 616
		st.countDurationOverride = duration -- 617
	end -- 617
end -- 613
function DualRouteContract.prototype.setMockTimeScale(self, scale) -- 621
	local st = self:ensureRehearsal("mock") -- 622
	st.timeScaleOverride = scale -- 623
end -- 621
function DualRouteContract.prototype.setMockGateReunion(self, patch) -- 626
	local st = self:ensureRehearsal("mock") -- 627
	if patch.active ~= nil then -- 628
		st.gateReunion.active = patch.active -- 628
	end -- 628
	if patch.knockHeard ~= nil then -- 629
		st.gateReunion.knockHeard = patch.knockHeard -- 629
	end -- 629
	if patch.holdProgress ~= nil then -- 630
		st.gateReunion.holdProgress = math.max( -- 630
			0, -- 630
			math.min(1, patch.holdProgress) -- 630
		) -- 630
	end -- 630
	if patch.holding ~= nil then -- 631
		st.gateReunion.holding = patch.holding -- 631
	end -- 631
	if patch.completed ~= nil then -- 632
		st.gateReunion.completed = patch.completed -- 632
	end -- 632
	if patch.releasedAbortCount ~= nil then -- 633
		st.gateReunion.releasedAbortCount = patch.releasedAbortCount -- 633
	end -- 633
end -- 626
function DualRouteContract.prototype.setMockBackCarry(self, patch) -- 636
	local st = self:ensureRehearsal("mock") -- 637
	if patch.active ~= nil then -- 638
		st.backCarry.active = patch.active -- 638
	end -- 638
	if patch.handInHand ~= nil then -- 639
		st.backCarry.handInHand = patch.handInHand -- 639
	end -- 639
	if patch.mounting ~= nil then -- 640
		st.backCarry.mounting = patch.mounting -- 640
	end -- 640
	if patch.atBench ~= nil then -- 641
		st.backCarry.atBench = patch.atBench -- 641
	end -- 641
end -- 636
function DualRouteContract.prototype.triggerMockReload(self, active, options) -- 644
	local st = self:ensureRehearsal("mock") -- 648
	st.reloadSession.active = active -- 649
	if active then -- 650
		st.reloadSession.elapsed = 0 -- 651
		st.reloadSession.duration = options and options.duration or DEFAULT_RELOAD_DURATION -- 652
		st.reloadSession.path = {} -- 653
		st.reloadSession.previewEffect = "normal" -- 654
		st.reloadSession.invalidFlash = 0 -- 655
		if (options and options.firstTime) ~= nil then -- 656
			st.reloadSession.firstTime = options.firstTime -- 657
		end -- 657
		st.timeScaleOverride = options and options.slowTimeScale or DEFAULT_SLOW_TIME_SCALE -- 659
	else -- 659
		st.reloadSession.elapsed = 0 -- 661
		st.reloadSession.path = {} -- 662
		st.timeScaleOverride = nil -- 663
	end -- 663
end -- 644
function DualRouteContract.prototype.triggerMockBench(self, active, options) -- 667
	local st = self:ensureRehearsal("mock") -- 671
	st.craftBench.active = active -- 672
	st.backCarry.atBench = active -- 673
	if (options and options.inventory) ~= nil then -- 674
		st.craftBench.inventory = cloneRecordNum(options.inventory) -- 675
	end -- 675
	if (options and options.equippedWeapon) ~= nil then -- 677
		st.craftBench.equippedWeapon = options.equippedWeapon -- 678
	end -- 678
end -- 667
function DualRouteContract.prototype.setMockArchive(self, childCleared, soldierCleared, artifactOwned) -- 682
	local st = self:ensureRehearsal("mock") -- 683
	st.archive.childCleared = childCleared -- 684
	st.archive.soldierCleared = soldierCleared -- 685
	if artifactOwned ~= nil then -- 686
		st.archive.artifactOwned = artifactOwned -- 687
	end -- 687
	if childCleared and soldierCleared and st.archive.museumPhase == "locked" then -- 689
		st.archive.museumPhase = "well_open" -- 690
	elseif (not childCleared or not soldierCleared) and st.archive.museumPhase == "well_open" then -- 691
		st.archive.museumPhase = "locked" -- 692
	end -- 692
end -- 682
function DualRouteContract.prototype.enterMockMuseum(self, phase) -- 696
	local st = self:ensureRehearsal("mock") -- 697
	st.archive.museumPhase = phase -- 698
	if phase == "done" then -- 699
		st.archive.museumSeen = true -- 700
	end -- 700
	if phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" or phase == "done" then -- 703
		st.archive.artifactOwned = true -- 709
	end -- 709
end -- 696
function DualRouteContract.prototype.sampleLive(self, p, dt, events) -- 715
	local pRec = asRecord(p) -- 716
	local runRec = asRecord(p.run) -- 717
	local ____asRecord_13 = asRecord -- 718
	local ____temp_12 -- 718
	if runRec ~= nil then -- 718
		____temp_12 = runRec.story -- 718
	else -- 718
		____temp_12 = nil -- 718
	end -- 718
	local storyRec = ____asRecord_13(____temp_12) -- 718
	if dt > 0 and self.liveReloadInvalidFlash > 0 then -- 720
		self.liveReloadInvalidFlash = math.max(0, self.liveReloadInvalidFlash - dt) -- 721
	end -- 721
	if events ~= nil and #events.rawEvents > 0 then -- 723
		local ei = 0 -- 724
		do -- 724
			ei = 0 -- 725
			while ei < #events.rawEvents do -- 725
				local ename = events.rawEvents[ei + 1].name -- 726
				if ename == "handRelease" then -- 727
					self.liveReleasedAbortCount = self.liveReleasedAbortCount + 1 -- 728
				elseif ename == "reloadInvalid" then -- 729
					self.liveReloadInvalidFlash = 0.35 -- 730
				end -- 730
				ei = ei + 1 -- 725
			end -- 725
		end -- 725
	end -- 725
	local ____temp_16 -- 736
	if pRec ~= nil and type(pRec.storyRoute) == "string" and pRec.storyRoute ~= "" then -- 736
		____temp_16 = pRec.storyRoute -- 737
	else -- 737
		local ____temp_15 -- 738
		if storyRec ~= nil and type(storyRec.route) == "string" and storyRec.route ~= "" then -- 738
			____temp_15 = storyRec.route -- 739
		else -- 739
			local ____temp_14 -- 740
			if runRec ~= nil then -- 740
				____temp_14 = runRec.storyRoute -- 740
			else -- 740
				____temp_14 = nil -- 740
			end -- 740
			____temp_15 = ____temp_14 -- 740
		end -- 740
		____temp_16 = ____temp_15 -- 738
	end -- 738
	local rawRoute = ____temp_16 -- 736
	local storyRoute = parseStoryRoute(rawRoute) -- 741
	local countElapsedTicks = readNum(pRec, "countElapsedTicks") or p.countTick -- 744
	local countDurationTicks = math.max( -- 745
		1, -- 745
		readNum(pRec, "countDurationTicks") or GATE_COUNT_END -- 745
	) -- 745
	local countNumber = gateCountAtTick(countElapsedTicks) -- 746
	local countProgress = math.max( -- 747
		0, -- 747
		math.min(1, countElapsedTicks / countDurationTicks) -- 747
	) -- 747
	local ____asRecord_18 = asRecord -- 750
	local ____temp_17 -- 750
	if pRec ~= nil then -- 750
		____temp_17 = pRec.gateReunion -- 750
	else -- 750
		____temp_17 = nil -- 750
	end -- 750
	local grRec = ____asRecord_18(____temp_17) -- 750
	local flatHold = readNum(pRec, "gateHoldProgress") -- 751
	local inGateWaitOrHand = p.room.key == "gate" and (p.phase == "gate-wait" or p.phase == "gate-hand") -- 752
	local handTicks = readNum(pRec, "handTicks") or 0 -- 753
	local handNeedTicks = math.max( -- 754
		1, -- 754
		readNum(pRec, "handNeedTicks") or 36 -- 754
	) -- 754
	local handTied = p.room.key == "gate" and p.phase == "gate-hand" -- 755
	local derivedHoldProg = handTied and 1 or (inGateWaitOrHand and math.max( -- 756
		0, -- 756
		math.min(1, handTicks / handNeedTicks) -- 756
	) or 0) -- 756
	local ____readBool_result_19 = readBool(grRec, "active") -- 758
	if ____readBool_result_19 == nil then -- 758
		____readBool_result_19 = inGateWaitOrHand -- 758
	end -- 758
	local ____readBool_result_20 = readBool(grRec, "knockHeard") -- 759
	if ____readBool_result_20 == nil then -- 759
		____readBool_result_20 = inGateWaitOrHand and p.knocks >= 1 -- 759
	end -- 759
	local ____math_max_result_23 = math.max( -- 760
		0, -- 760
		math.min( -- 760
			1, -- 760
			readNum(grRec, "holdProgress") or flatHold or derivedHoldProg -- 760
		) -- 760
	) -- 760
	local ____readBool_result_21 = readBool(grRec, "holding") -- 761
	if ____readBool_result_21 == nil then -- 761
		____readBool_result_21 = inGateWaitOrHand and not handTied and handTicks > 0 -- 761
	end -- 761
	local ____readBool_result_22 = readBool(grRec, "completed") -- 762
	if ____readBool_result_22 == nil then -- 762
		____readBool_result_22 = handTied -- 762
	end -- 762
	local gateReunion = { -- 757
		active = ____readBool_result_19, -- 758
		knockHeard = ____readBool_result_20, -- 759
		holdProgress = ____math_max_result_23, -- 760
		holding = ____readBool_result_21, -- 761
		completed = ____readBool_result_22, -- 762
		releasedAbortCount = readNum(grRec, "releasedAbortCount") or self.liveReleasedAbortCount -- 763
	} -- 763
	local ____asRecord_25 = asRecord -- 767
	local ____temp_24 -- 767
	if pRec ~= nil then -- 767
		____temp_24 = pRec.backCarry -- 767
	else -- 767
		____temp_24 = nil -- 767
	end -- 767
	local bcRec = ____asRecord_25(____temp_24) -- 767
	local ____asRecord_27 = asRecord -- 768
	local ____temp_26 -- 768
	if pRec ~= nil then -- 768
		____temp_26 = pRec.craftBench -- 768
	else -- 768
		____temp_26 = nil -- 768
	end -- 768
	local cbRecEarly = ____asRecord_27(____temp_26) -- 768
	local ____readBool_result_28 = readBool(cbRecEarly, "active") -- 769
	if ____readBool_result_28 == nil then -- 769
		____readBool_result_28 = false -- 769
	end -- 769
	local benchActiveLive = ____readBool_result_28 -- 769
	local ____readBool_result_29 = readBool(pRec, "carryOn") -- 770
	if ____readBool_result_29 == nil then -- 770
		____readBool_result_29 = readBool(storyRec, "carry") -- 770
	end -- 770
	local ____readBool_result_29_30 = ____readBool_result_29 -- 770
	if ____readBool_result_29_30 == nil then -- 770
		____readBool_result_29_30 = false -- 770
	end -- 770
	local carryOn = ____readBool_result_29_30 -- 770
	local handInHandLive = handTied or p.room.key == "gatepath" and not carryOn -- 771
	local ____readBool_result_31 = readBool(bcRec, "active") -- 773
	if ____readBool_result_31 == nil then -- 773
		____readBool_result_31 = carryOn -- 773
	end -- 773
	local ____readBool_result_32 = readBool(bcRec, "handInHand") -- 774
	if ____readBool_result_32 == nil then -- 774
		____readBool_result_32 = handInHandLive -- 774
	end -- 774
	local ____readBool_result_33 = readBool(bcRec, "mounting") -- 775
	if ____readBool_result_33 == nil then -- 775
		____readBool_result_33 = p.room.key == "gatepath" and carryOn -- 775
	end -- 775
	local ____readBool_result_34 = readBool(bcRec, "atBench") -- 776
	if ____readBool_result_34 == nil then -- 776
		____readBool_result_34 = benchActiveLive -- 776
	end -- 776
	local backCarry = {active = ____readBool_result_31, handInHand = ____readBool_result_32, mounting = ____readBool_result_33, atBench = ____readBool_result_34} -- 772
	local ____asRecord_36 = asRecord -- 780
	local ____temp_35 -- 780
	if pRec ~= nil then -- 780
		____temp_35 = pRec.reloadSession -- 780
	else -- 780
		____temp_35 = nil -- 780
	end -- 780
	local rsRec = ____asRecord_36(____temp_35) -- 780
	local ____readBool_result_37 = readBool(pRec, "reloadOpen") -- 781
	if ____readBool_result_37 == nil then -- 781
		____readBool_result_37 = false -- 781
	end -- 781
	local reloadOpenLive = ____readBool_result_37 -- 781
	local ____readBool_result_38 = readBool(rsRec, "active") -- 782
	if ____readBool_result_38 == nil then -- 782
		____readBool_result_38 = reloadOpenLive -- 782
	end -- 782
	local reloadActive = ____readBool_result_38 -- 782
	local reloadAnswerTicks = readNum(pRec, "reloadAnswerTicks") or 0 -- 783
	local reloadTryCount = readNum(pRec, "reloadTryCount") or 0 -- 784
	local livePath = readNumArray(rsRec, "path") or readNumArray(pRec, "reloadPath") or ({}) -- 785
	local ____temp_41 -- 786
	if rsRec ~= nil and rsRec.nextEffect ~= nil then -- 786
		____temp_41 = rsRec.nextEffect -- 787
	else -- 787
		local ____temp_40 -- 788
		if pRec ~= nil and pRec.reloadPendingEffect ~= nil then -- 788
			____temp_40 = pRec.reloadPendingEffect -- 789
		else -- 789
			local ____temp_39 -- 790
			if pRec ~= nil then -- 790
				____temp_39 = pRec.nextEffect -- 790
			else -- 790
				____temp_39 = nil -- 790
			end -- 790
			____temp_40 = ____temp_39 -- 790
		end -- 790
		____temp_41 = ____temp_40 -- 788
	end -- 788
	local liveNextRaw = ____temp_41 -- 786
	local livePreview = rsRec ~= nil and rsRec.previewEffect ~= nil and parseReloadEffect(rsRec.previewEffect) or (reloadActive and deriveReloadEffectFromPath(livePath) or "normal") -- 791
	local ____temp_42 -- 795
	if pRec ~= nil then -- 795
		____temp_42 = pRec.reloadNeedTicks -- 795
	else -- 795
		____temp_42 = nil -- 795
	end -- 795
	local needTicksFn = ____temp_42 -- 795
	local liveReloadDuration = type(needTicksFn) == "function" and math.max( -- 796
		0.5, -- 797
		needTicksFn(p) / 60 -- 797
	) or DEFAULT_RELOAD_DURATION -- 798
	local ____readBool_result_43 = readBool(rsRec, "firstTime") -- 801
	if ____readBool_result_43 == nil then -- 801
		____readBool_result_43 = reloadTryCount <= 1 -- 801
	end -- 801
	local reloadSession = { -- 799
		active = reloadActive, -- 800
		firstTime = ____readBool_result_43, -- 801
		elapsed = readNum(rsRec, "elapsed") or reloadAnswerTicks / 60, -- 802
		duration = math.max( -- 803
			0.01, -- 803
			readNum(rsRec, "duration") or liveReloadDuration -- 803
		), -- 803
		path = livePath, -- 804
		previewEffect = livePreview, -- 805
		nextEffect = parseReloadEffect(liveNextRaw), -- 806
		invalidFlash = readNum(rsRec, "invalidFlash") or self.liveReloadInvalidFlash -- 807
	} -- 807
	local rawScale = readNum(pRec, "timeScale") or readNum(runRec, "timeScale") -- 810
	local timeScale = rawScale ~= nil and rawScale >= 0 and rawScale or (reloadActive and DEFAULT_SLOW_TIME_SCALE or 1) -- 811
	local ____asRecord_45 = asRecord -- 816
	local ____temp_44 -- 816
	if pRec ~= nil then -- 816
		____temp_44 = pRec.craftBench -- 816
	else -- 816
		____temp_44 = nil -- 816
	end -- 816
	local cbRec = ____asRecord_45(____temp_44) -- 816
	local craftBench = self:readLiveCraftBench(cbRec, pRec, runRec) -- 817
	local archive = self:readLiveArchive(p) -- 820
	self.liveArchiveCache = archive -- 821
	local visualMode = deriveVisualMode( -- 823
		p.room.key, -- 824
		p.phase, -- 825
		storyRoute, -- 826
		"locked", -- 827
		countProgress, -- 828
		gateReunion.completed -- 829
	) -- 829
	return { -- 832
		storyRoute = storyRoute, -- 833
		countElapsedTicks = countElapsedTicks, -- 834
		countDurationTicks = countDurationTicks, -- 835
		countNumber = countNumber, -- 836
		countProgress = countProgress, -- 837
		gateReunion = gateReunion, -- 838
		backCarry = backCarry, -- 839
		timeScale = timeScale, -- 840
		reloadSession = reloadSession, -- 841
		craftBench = craftBench, -- 842
		archive = archive, -- 843
		assistHintsEnabled = self.assistHintsEnabled, -- 844
		visualMode = visualMode, -- 845
		dataSource = "live", -- 846
		isRehearsal = false, -- 847
		rehearsalTag = "" -- 848
	} -- 848
end -- 715
function DualRouteContract.prototype.readLiveCraftBench(self, cbRec, pRec, runRec) -- 852
	local recipes = defaultRecipes() -- 857
	if cbRec ~= nil and __TS__ArrayIsArray(cbRec.recipes) then -- 858
		local rawList = cbRec.recipes -- 859
		local parsed = {} -- 860
		local i = 0 -- 861
		do -- 861
			i = 0 -- 862
			while i < #rawList do -- 862
				do -- 862
					local item = asRecord(rawList[i + 1]) -- 863
					if item == nil then -- 864
						goto __continue126 -- 865
					end -- 865
					local id = readStr(item, "id") -- 867
					local name = readStr(item, "name") -- 868
					if id == nil or name == nil then -- 869
						goto __continue126 -- 870
					end -- 870
					local ____id_47 = id -- 873
					local ____name_48 = name -- 874
					local ____temp_49 = readStr(item, "desc") or "" -- 875
					local ____parseReloadEffect_result_50 = parseReloadEffect(item.enhancedEffect) -- 876
					local ____temp_51 = readNumMap(item, "cost") or ({}) -- 877
					local ____readBool_result_46 = readBool(item, "crafted") -- 878
					if ____readBool_result_46 == nil then -- 878
						____readBool_result_46 = false -- 878
					end -- 878
					parsed[#parsed + 1] = { -- 872
						id = ____id_47, -- 873
						name = ____name_48, -- 874
						desc = ____temp_49, -- 875
						enhancedEffect = ____parseReloadEffect_result_50, -- 876
						cost = ____temp_51, -- 877
						crafted = ____readBool_result_46 -- 878
					} -- 878
				end -- 878
				::__continue126:: -- 878
				i = i + 1 -- 862
			end -- 862
		end -- 862
		if #parsed > 0 then -- 881
			local ____readBool_result_52 = readBool(cbRec, "active") -- 883
			if ____readBool_result_52 == nil then -- 883
				____readBool_result_52 = false -- 883
			end -- 883
			local ____readBool_result_53 = readBool(cbRec, "firstCraftDone") -- 884
			if ____readBool_result_53 == nil then -- 884
				____readBool_result_53 = false -- 884
			end -- 884
			return { -- 882
				active = ____readBool_result_52, -- 883
				firstCraftDone = ____readBool_result_53, -- 884
				justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 885
				inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or ({}), -- 886
				recipes = parsed, -- 887
				equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 888
			} -- 888
		end -- 888
	end -- 888
	local ____readBool_result_54 = readBool(cbRec, "active") -- 893
	if ____readBool_result_54 == nil then -- 893
		____readBool_result_54 = false -- 893
	end -- 893
	local ____readBool_result_55 = readBool(cbRec, "firstCraftDone") -- 894
	if ____readBool_result_55 == nil then -- 894
		____readBool_result_55 = false -- 894
	end -- 894
	return { -- 892
		active = ____readBool_result_54, -- 893
		firstCraftDone = ____readBool_result_55, -- 894
		justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 895
		inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or readNumMap(runRec, "craftInventory") or ({}), -- 896
		recipes = recipes, -- 897
		equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 898
	} -- 898
end -- 852
function DualRouteContract.prototype.readLiveArchive(self, p) -- 902
	local pRec = asRecord(p) -- 903
	local runRec = asRecord(p.run) -- 904
	local ____asRecord_57 = asRecord -- 905
	local ____temp_56 -- 905
	if pRec ~= nil then -- 905
		____temp_56 = pRec.archive -- 905
	else -- 905
		____temp_56 = nil -- 905
	end -- 905
	local ____asRecord_57_result_60 = ____asRecord_57(____temp_56) -- 905
	if ____asRecord_57_result_60 == nil then -- 905
		local ____asRecord_59 = asRecord -- 906
		local ____temp_58 -- 906
		if runRec ~= nil then -- 906
			____temp_58 = runRec.archive -- 906
		else -- 906
			____temp_58 = nil -- 906
		end -- 906
		____asRecord_57_result_60 = ____asRecord_59(____temp_58) -- 905
	end -- 905
	local archRec = ____asRecord_57_result_60 -- 905
	local ____readBool_result_61 = readBool(archRec, "childCleared") -- 908
	if ____readBool_result_61 == nil then -- 908
		____readBool_result_61 = readBool(pRec, "childCleared") -- 908
	end -- 908
	local ____readBool_result_61_62 = ____readBool_result_61 -- 908
	if ____readBool_result_61_62 == nil then -- 908
		____readBool_result_61_62 = false -- 908
	end -- 908
	local childCleared = ____readBool_result_61_62 -- 908
	local ____readBool_result_63 = readBool(archRec, "soldierCleared") -- 909
	if ____readBool_result_63 == nil then -- 909
		____readBool_result_63 = readBool(pRec, "soldierCleared") -- 909
	end -- 909
	local ____readBool_result_63_64 = ____readBool_result_63 -- 909
	if ____readBool_result_63_64 == nil then -- 909
		____readBool_result_63_64 = false -- 909
	end -- 909
	local soldierCleared = ____readBool_result_63_64 -- 909
	local ____readBool_result_65 = readBool(archRec, "artifactOwned") -- 910
	if ____readBool_result_65 == nil then -- 910
		____readBool_result_65 = readBool(pRec, "artifactOwned") -- 910
	end -- 910
	local ____readBool_result_65_66 = ____readBool_result_65 -- 910
	if ____readBool_result_65_66 == nil then -- 910
		____readBool_result_65_66 = false -- 910
	end -- 910
	local artifactOwned = ____readBool_result_65_66 -- 910
	local ____temp_68 -- 911
	if archRec ~= nil and archRec.museumPhase ~= nil then -- 911
		____temp_68 = archRec.museumPhase -- 912
	else -- 912
		local ____temp_67 -- 913
		if pRec ~= nil then -- 913
			____temp_67 = pRec.museumPhase -- 913
		else -- 913
			____temp_67 = nil -- 913
		end -- 913
		____temp_68 = ____temp_67 -- 913
	end -- 913
	local rawPhase = ____temp_68 -- 911
	local museumPhase = parseMuseumPhase(rawPhase) -- 914
	local ____readBool_result_69 = readBool(archRec, "museumSeen") -- 915
	if ____readBool_result_69 == nil then -- 915
		____readBool_result_69 = readBool(pRec, "museumSeen") -- 915
	end -- 915
	local ____readBool_result_69_70 = ____readBool_result_69 -- 915
	if ____readBool_result_69_70 == nil then -- 915
		____readBool_result_69_70 = false -- 915
	end -- 915
	local museumSeen = ____readBool_result_69_70 -- 915
	local livePhase = p.phase -- 924
	if p.room.key == "museum" then -- 925
		if livePhase == "museum-cabinet" then -- 926
			museumPhase = museumPhase == "well_reflect" and "well_reflect" or "hall_walk" -- 927
		elseif livePhase == "museum-hall" or livePhase == "museum-lamp" then -- 928
			museumPhase = "hall_walk" -- 929
		elseif livePhase == "museum-return" then -- 930
			museumPhase = "lamp_turn" -- 931
		elseif livePhase == "museum-knock" or livePhase == "museum-done" then -- 932
			museumPhase = "return_cabinet" -- 933
		end -- 933
	elseif p.room.key == "prologue" and museumPhase == "locked" and childCleared and soldierCleared and not museumSeen then -- 935
		local backendWellOpen = readBool(pRec, "wellOpen") == true -- 936
		local hasBackendWell = readNum(pRec, "wellX") ~= nil -- 937
		if backendWellOpen or livePhase == "prologue-well" or artifactOwned and hasBackendWell then -- 938
			museumPhase = "well_open" -- 939
		end -- 939
	end -- 939
	return { -- 943
		childCleared = childCleared, -- 944
		soldierCleared = soldierCleared, -- 945
		artifactOwned = artifactOwned, -- 946
		museumPhase = museumPhase, -- 947
		museumSeen = museumSeen -- 948
	} -- 948
end -- 902
function DualRouteContract.prototype.forwardLiveIntent(self, p, intent) -- 952
	if intent.kind == "craftSubmit" then -- 953
		if self.livePendingCraftRequests[intent.requestId] == true then -- 954
			return false -- 955
		end -- 955
		self.livePendingCraftRequests[intent.requestId] = true -- 957
	end -- 957
	local pRec = asRecord(p) -- 959
	if pRec == nil then -- 960
		return false -- 961
	end -- 961
	local handler = pRec.submitFeIntent -- 963
	if type(handler) == "function" then -- 964
		local fn = handler -- 965
		local result = fn(p, intent) -- 966
		if result ~= false then -- 967
			return true -- 968
		end -- 968
		if intent.kind == "museumInteract" and intent.target == "well_pickup" then -- 971
			local wellRes = fn(p, {kind = "wellPick"}) -- 972
			return wellRes ~= false -- 973
		end -- 973
		return false -- 975
	end -- 975
	local tapNode = pRec.reloadTapNode -- 978
	if type(tapNode) == "function" then -- 979
		local fn = tapNode -- 980
		if intent.kind == "reloadTapNode" then -- 981
			fn(p, intent.node) -- 982
			return true -- 983
		end -- 983
		if intent.kind == "reloadPathCommit" and #intent.path > 0 then -- 985
			local i = 0 -- 986
			do -- 986
				i = 0 -- 987
				while i < #intent.path do -- 987
					do -- 987
						if i == 0 and intent.path[i + 1] == 0 then -- 988
							goto __continue149 -- 989
						end -- 989
						fn(p, intent.path[i + 1]) -- 991
					end -- 991
					::__continue149:: -- 991
					i = i + 1 -- 987
				end -- 987
			end -- 987
			return true -- 993
		end -- 993
	end -- 993
	return false -- 996
end -- 952
function DualRouteContract.prototype.sampleRehearsal(self, p, dt, input, st) -- 1001
	local countElapsedTicks = st.countTickOverride ~= nil and st.countTickOverride or p.countTick -- 1002
	local countDurationTicks = math.max(1, st.countDurationOverride or GATE_COUNT_END) -- 1003
	local countNumber = gateCountAtTick(countElapsedTicks) -- 1004
	local countProgress = math.max( -- 1005
		0, -- 1005
		math.min(1, countElapsedTicks / countDurationTicks) -- 1005
	) -- 1005
	if p.room.key == "gate" and p.phase == "gate-count" and st.storyRoute == "soldier" then -- 1008
		if countElapsedTicks < countDurationTicks then -- 1009
			st.gateReunion.active = false -- 1010
			st.gateReunion.knockHeard = false -- 1011
			st.gateReunion.holding = false -- 1012
			st.gateReunion.holdProgress = 0 -- 1013
			st.gateHoldArmed = not input.interact.held -- 1014
			st.gatePrevInteractHeld = input.interact.held -- 1015
		elseif not st.gateReunion.completed then -- 1016
			st.gateReunion.active = true -- 1017
			st.gateReunion.knockHeard = true -- 1018
			if not st.gateHoldArmed and not input.interact.held then -- 1019
				st.gateHoldArmed = true -- 1020
			end -- 1020
			if dt > 0 then -- 1022
				if st.gateHoldArmed and input.interact.held then -- 1023
					st.gateReunion.holding = true -- 1024
					st.gateReunion.holdProgress = math.min(1, st.gateReunion.holdProgress + dt / GATE_REUNION_HOLD_SECONDS) -- 1025
					if st.gateReunion.holdProgress >= 1 then -- 1029
						st.gateReunion.holdProgress = 1 -- 1030
						st.gateReunion.holding = false -- 1031
						st.gateReunion.completed = true -- 1032
						st.backCarry.handInHand = true -- 1033
					end -- 1033
				else -- 1033
					if st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1036
						local ____st_gateReunion_71, ____releasedAbortCount_72 = st.gateReunion, "releasedAbortCount" -- 1037
						____st_gateReunion_71[____releasedAbortCount_72] = ____st_gateReunion_71[____releasedAbortCount_72] + 1 -- 1037
					end -- 1037
					st.gateReunion.holding = false -- 1039
					st.gateReunion.holdProgress = 0 -- 1040
				end -- 1040
			end -- 1040
			st.gatePrevInteractHeld = input.interact.held -- 1043
		end -- 1043
	end -- 1043
	if st.reloadSession.active and dt > 0 then -- 1048
		local ____st_reloadSession_73, ____elapsed_74 = st.reloadSession, "elapsed" -- 1049
		____st_reloadSession_73[____elapsed_74] = ____st_reloadSession_73[____elapsed_74] + dt -- 1049
		if st.reloadSession.invalidFlash > 0 then -- 1050
			st.reloadSession.invalidFlash = math.max(0, st.reloadSession.invalidFlash - dt) -- 1051
		end -- 1051
		if st.reloadSession.elapsed >= st.reloadSession.duration then -- 1053
			st.reloadSession.active = false -- 1054
			st.reloadSession.elapsed = 0 -- 1055
			st.reloadSession.path = {} -- 1056
			st.reloadSession.previewEffect = "normal" -- 1057
			st.reloadSession.nextEffect = "normal" -- 1058
			st.reloadSession.firstTime = false -- 1059
			st.timeScaleOverride = nil -- 1060
		end -- 1060
	end -- 1060
	if st.craftBench.justCraftedTimer > 0 and dt > 0 then -- 1065
		st.craftBench.justCraftedTimer = math.max(0, st.craftBench.justCraftedTimer - dt) -- 1066
	end -- 1066
	local timeScale = st.timeScaleOverride ~= nil and math.max(0, st.timeScaleOverride) or (st.reloadSession.active and DEFAULT_SLOW_TIME_SCALE or 1) -- 1069
	local visualMode = deriveVisualMode( -- 1073
		p.room.key, -- 1074
		p.phase, -- 1075
		st.storyRoute, -- 1076
		st.archive.museumPhase, -- 1077
		countProgress, -- 1078
		st.gateReunion.completed -- 1079
	) -- 1079
	return { -- 1082
		storyRoute = st.storyRoute, -- 1083
		countElapsedTicks = countElapsedTicks, -- 1084
		countDurationTicks = countDurationTicks, -- 1085
		countNumber = countNumber, -- 1086
		countProgress = countProgress, -- 1087
		gateReunion = { -- 1088
			active = st.gateReunion.active, -- 1089
			knockHeard = st.gateReunion.knockHeard, -- 1090
			holdProgress = st.gateReunion.holdProgress, -- 1091
			holding = st.gateReunion.holding, -- 1092
			completed = st.gateReunion.completed, -- 1093
			releasedAbortCount = st.gateReunion.releasedAbortCount -- 1094
		}, -- 1094
		backCarry = {active = st.backCarry.active, handInHand = st.backCarry.handInHand, mounting = st.backCarry.mounting, atBench = st.backCarry.atBench}, -- 1096
		timeScale = timeScale, -- 1102
		reloadSession = { -- 1103
			active = st.reloadSession.active, -- 1104
			firstTime = st.reloadSession.firstTime, -- 1105
			elapsed = st.reloadSession.elapsed, -- 1106
			duration = st.reloadSession.duration, -- 1107
			path = __TS__ArraySlice(st.reloadSession.path), -- 1108
			previewEffect = st.reloadSession.previewEffect, -- 1109
			nextEffect = st.reloadSession.nextEffect, -- 1110
			invalidFlash = st.reloadSession.invalidFlash -- 1111
		}, -- 1111
		craftBench = { -- 1113
			active = st.craftBench.active, -- 1114
			firstCraftDone = st.craftBench.firstCraftDone, -- 1115
			justCraftedTimer = st.craftBench.justCraftedTimer, -- 1116
			inventory = cloneRecordNum(st.craftBench.inventory), -- 1117
			recipes = cloneRecipes(st.craftBench.recipes), -- 1118
			equippedWeapon = st.craftBench.equippedWeapon -- 1119
		}, -- 1119
		archive = { -- 1121
			childCleared = st.archive.childCleared, -- 1122
			soldierCleared = st.archive.soldierCleared, -- 1123
			artifactOwned = st.archive.artifactOwned, -- 1124
			museumPhase = st.archive.museumPhase, -- 1125
			museumSeen = st.archive.museumSeen -- 1126
		}, -- 1126
		assistHintsEnabled = self.assistHintsEnabled, -- 1128
		visualMode = visualMode, -- 1129
		dataSource = "rehearsal", -- 1130
		isRehearsal = true, -- 1131
		rehearsalTag = st.tag -- 1132
	} -- 1132
end -- 1001
function DualRouteContract.prototype.applyRehearsalIntent(self, st, intent) -- 1136
	if intent.kind == "gateReunionHold" then -- 1137
		if not st.gateReunion.active or st.gateReunion.completed then -- 1138
			return false -- 1139
		end -- 1139
		if not intent.holding and st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1141
			local ____st_gateReunion_75, ____releasedAbortCount_76 = st.gateReunion, "releasedAbortCount" -- 1142
			____st_gateReunion_75[____releasedAbortCount_76] = ____st_gateReunion_75[____releasedAbortCount_76] + 1 -- 1142
			st.gateReunion.holdProgress = 0 -- 1143
		end -- 1143
		st.gateReunion.holding = intent.holding -- 1145
		return true -- 1146
	end -- 1146
	if intent.kind == "reloadOpen" then -- 1148
		self:triggerMockReload(true) -- 1149
		return true -- 1150
	end -- 1150
	if intent.kind == "reloadTapNode" then -- 1152
		if not st.reloadSession.active then -- 1153
			return false -- 1154
		end -- 1154
		if #st.reloadSession.path == 0 then -- 1156
			local ____st_reloadSession_path_77 = st.reloadSession.path -- 1157
			____st_reloadSession_path_77[#____st_reloadSession_path_77 + 1] = 0 -- 1157
		end -- 1157
		if __TS__ArrayIndexOf(st.reloadSession.path, intent.node) >= 0 then -- 1159
			st.reloadSession.invalidFlash = 0.35 -- 1160
			st.reloadSession.path = {0} -- 1161
			st.reloadSession.previewEffect = "normal" -- 1162
			return false -- 1163
		end -- 1163
		local ____st_reloadSession_path_78 = st.reloadSession.path -- 1165
		____st_reloadSession_path_78[#____st_reloadSession_path_78 + 1] = intent.node -- 1165
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(st.reloadSession.path) -- 1166
		if intent.node == 8 then -- 1167
			st.reloadSession.nextEffect = st.reloadSession.previewEffect -- 1168
			st.reloadSession.active = false -- 1169
			st.reloadSession.elapsed = 0 -- 1170
			st.reloadSession.path = {} -- 1171
			st.reloadSession.firstTime = false -- 1172
			st.timeScaleOverride = nil -- 1173
		end -- 1173
		return true -- 1175
	end -- 1175
	if intent.kind == "reloadPathPreview" then -- 1177
		if not st.reloadSession.active then -- 1178
			return false -- 1179
		end -- 1179
		st.reloadSession.path = __TS__ArraySlice(intent.path) -- 1181
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(intent.path) -- 1182
		return true -- 1183
	end -- 1183
	if intent.kind == "reloadPathCommit" then -- 1185
		if not st.reloadSession.active then -- 1186
			return false -- 1187
		end -- 1187
		if #intent.path < 2 then -- 1189
			st.reloadSession.invalidFlash = 0.35 -- 1190
			st.reloadSession.path = {} -- 1191
			st.reloadSession.previewEffect = "normal" -- 1192
			return false -- 1193
		end -- 1193
		local effect = deriveReloadEffectFromPath(intent.path) -- 1195
		st.reloadSession.nextEffect = effect -- 1196
		st.reloadSession.previewEffect = effect -- 1197
		st.reloadSession.path = {} -- 1198
		st.reloadSession.active = false -- 1199
		st.reloadSession.elapsed = 0 -- 1200
		st.reloadSession.firstTime = false -- 1201
		st.timeScaleOverride = nil -- 1202
		return true -- 1203
	end -- 1203
	if intent.kind == "reloadCancel" then -- 1205
		st.reloadSession.active = false -- 1206
		st.reloadSession.elapsed = 0 -- 1207
		st.reloadSession.path = {} -- 1208
		st.reloadSession.previewEffect = "normal" -- 1209
		st.timeScaleOverride = nil -- 1210
		return true -- 1211
	end -- 1211
	if intent.kind == "craftSubmit" then -- 1213
		if not st.craftBench.active or st.handledCraftRequestIds[intent.requestId] == true then -- 1214
			return false -- 1215
		end -- 1215
		local target -- 1217
		local i = 0 -- 1218
		do -- 1218
			i = 0 -- 1219
			while i < #st.craftBench.recipes do -- 1219
				if st.craftBench.recipes[i + 1].id == intent.recipeId then -- 1220
					target = st.craftBench.recipes[i + 1] -- 1221
					break -- 1222
				end -- 1222
				i = i + 1 -- 1219
			end -- 1219
		end -- 1219
		if target == nil or target.crafted then -- 1225
			return false -- 1226
		end -- 1226
		for mat in pairs(target.cost) do -- 1228
			if (st.craftBench.inventory[mat] or 0) < target.cost[mat] then -- 1229
				return false -- 1230
			end -- 1230
		end -- 1230
		for mat in pairs(target.cost) do -- 1233
			st.craftBench.inventory[mat] = (st.craftBench.inventory[mat] or 0) - target.cost[mat] -- 1234
		end -- 1234
		st.handledCraftRequestIds[intent.requestId] = true -- 1236
		target.crafted = true -- 1237
		st.craftBench.equippedWeapon = target.id -- 1238
		st.craftBench.justCraftedTimer = st.craftBench.firstCraftDone and 0.45 or 1 -- 1239
		st.craftBench.firstCraftDone = true -- 1240
		return true -- 1241
	end -- 1241
	if intent.kind == "craftEquip" then -- 1243
		st.craftBench.equippedWeapon = intent.weaponId -- 1244
		return true -- 1245
	end -- 1245
	if intent.kind == "craftClose" then -- 1247
		st.craftBench.active = false -- 1248
		st.backCarry.atBench = false -- 1249
		return true -- 1250
	end -- 1250
	if intent.kind == "museumInteract" then -- 1252
		if intent.target == "well_pickup" and st.archive.museumPhase == "well_open" then -- 1253
			st.archive.artifactOwned = true -- 1254
			st.archive.museumPhase = "well_reflect" -- 1255
			return true -- 1256
		end -- 1256
		if intent.target == "enter_hall" and st.archive.museumPhase == "well_reflect" then -- 1258
			st.archive.museumPhase = "hall_walk" -- 1259
			return true -- 1260
		end -- 1260
		if intent.target == "lamp_turn" and st.archive.museumPhase == "hall_walk" then -- 1262
			st.archive.museumPhase = "lamp_turn" -- 1263
			return true -- 1264
		end -- 1264
		if intent.target == "begin_return_cabinet" and st.archive.museumPhase == "lamp_turn" then -- 1266
			st.archive.museumPhase = "return_cabinet" -- 1267
			return true -- 1268
		end -- 1268
		if intent.target == "return_cabinet" then -- 1270
			st.archive.museumPhase = "done" -- 1271
			st.archive.museumSeen = true -- 1272
			return true -- 1273
		end -- 1273
		return false -- 1275
	end -- 1275
	return false -- 1277
end -- 1136
return ____exports -- 1136
