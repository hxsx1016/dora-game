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
	if roomKey == "museum" or museumPhase == "well_reflect" or museumPhase == "hall_walk" or museumPhase == "lamp_turn" or museumPhase == "return_cabinet" then -- 409
		return "museum" -- 424
	end -- 424
	if roomKey == "gate" then -- 424
		if phase == "gate-hand" then -- 424
			return "pixel" -- 428
		end -- 428
		if phase == "gate-wait" then -- 428
			return reunionCompleted and "pixel" or "lowpoly" -- 431
		end -- 431
		if phase == "gate-count" then -- 431
			if storyRoute == "soldier" and reunionCompleted then -- 431
				return "pixel" -- 435
			end -- 435
			if countProgress <= 0 then -- 435
				return "pixel" -- 438
			end -- 438
			if countProgress >= 1 then -- 438
				return "lowpoly" -- 441
			end -- 441
			return "transition" -- 443
		end -- 443
		if phase == "gate-walk" then -- 443
			return storyRoute == "soldier" and "pixel" or (storyRoute == "child" and "lowpoly" or "pixel") -- 446
		end -- 446
		return "pixel" -- 448
	end -- 448
	if roomKey == "gatepath" or roomKey == "escort1" or roomKey == "escort2" or roomKey == "escort3" or roomKey == "escort4" or roomKey == "escort5" then -- 448
		return "pixel" -- 452
	end -- 452
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" then -- 452
		if storyRoute == "child" then -- 452
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
	if self.rehearsal == nil then -- 489
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
	if self.source ~= "rehearsal" or self.rehearsal == nil then -- 503
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
	if self.rehearsal ~= nil then -- 554
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
	if self.source == "rehearsal" and self.rehearsal ~= nil then -- 588
		accepted = self:applyRehearsalIntent(self.rehearsal, intent) -- 590
	else -- 590
		accepted = self:forwardLiveIntent(p, intent) -- 592
	end -- 592
	local ____self_intentLog_1 = self.intentLog -- 592
	____self_intentLog_1[#____self_intentLog_1 + 1] = {tick = p.ticks, source = self.source, intent = intent, accepted = accepted} -- 594
	if #self.intentLog > MAX_INTENT_LOG then -- 594
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
	if duration ~= nil and duration > 0 then -- 615
		st.countDurationOverride = duration -- 617
	end -- 617
end -- 613
function DualRouteContract.prototype.setMockTimeScale(self, scale) -- 621
	local st = self:ensureRehearsal("mock") -- 622
	st.timeScaleOverride = scale -- 623
end -- 621
function DualRouteContract.prototype.setMockGateReunion(self, patch) -- 626
	local st = self:ensureRehearsal("mock") -- 627
	if patch.active ~= nil then -- 627
		st.gateReunion.active = patch.active -- 628
	end -- 628
	if patch.knockHeard ~= nil then -- 628
		st.gateReunion.knockHeard = patch.knockHeard -- 629
	end -- 629
	if patch.holdProgress ~= nil then -- 629
		st.gateReunion.holdProgress = math.max( -- 630
			0, -- 630
			math.min(1, patch.holdProgress) -- 630
		) -- 630
	end -- 630
	if patch.holding ~= nil then -- 630
		st.gateReunion.holding = patch.holding -- 631
	end -- 631
	if patch.completed ~= nil then -- 631
		st.gateReunion.completed = patch.completed -- 632
	end -- 632
	if patch.releasedAbortCount ~= nil then -- 632
		st.gateReunion.releasedAbortCount = patch.releasedAbortCount -- 633
	end -- 633
end -- 626
function DualRouteContract.prototype.setMockBackCarry(self, patch) -- 636
	local st = self:ensureRehearsal("mock") -- 637
	if patch.active ~= nil then -- 637
		st.backCarry.active = patch.active -- 638
	end -- 638
	if patch.handInHand ~= nil then -- 638
		st.backCarry.handInHand = patch.handInHand -- 639
	end -- 639
	if patch.mounting ~= nil then -- 639
		st.backCarry.mounting = patch.mounting -- 640
	end -- 640
	if patch.atBench ~= nil then -- 640
		st.backCarry.atBench = patch.atBench -- 641
	end -- 641
end -- 636
function DualRouteContract.prototype.triggerMockReload(self, active, options) -- 644
	local st = self:ensureRehearsal("mock") -- 648
	st.reloadSession.active = active -- 649
	if active then -- 649
		st.reloadSession.elapsed = 0 -- 651
		st.reloadSession.duration = options and options.duration or DEFAULT_RELOAD_DURATION -- 652
		st.reloadSession.path = {} -- 653
		st.reloadSession.previewEffect = "normal" -- 654
		st.reloadSession.invalidFlash = 0 -- 655
		if (options and options.firstTime) ~= nil then -- 655
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
	if (options and options.inventory) ~= nil then -- 673
		st.craftBench.inventory = cloneRecordNum(options.inventory) -- 675
	end -- 675
	if (options and options.equippedWeapon) ~= nil then -- 675
		st.craftBench.equippedWeapon = options.equippedWeapon -- 678
	end -- 678
end -- 667
function DualRouteContract.prototype.setMockArchive(self, childCleared, soldierCleared, artifactOwned) -- 682
	local st = self:ensureRehearsal("mock") -- 683
	st.archive.childCleared = childCleared -- 684
	st.archive.soldierCleared = soldierCleared -- 685
	if artifactOwned ~= nil then -- 685
		st.archive.artifactOwned = artifactOwned -- 687
	end -- 687
	if childCleared and soldierCleared and st.archive.museumPhase == "locked" then -- 687
		st.archive.museumPhase = "well_open" -- 690
	elseif (not childCleared or not soldierCleared) and st.archive.museumPhase == "well_open" then -- 690
		st.archive.museumPhase = "locked" -- 692
	end -- 692
end -- 682
function DualRouteContract.prototype.enterMockMuseum(self, phase) -- 696
	local st = self:ensureRehearsal("mock") -- 697
	st.archive.museumPhase = phase -- 698
	if phase == "done" then -- 698
		st.archive.museumSeen = true -- 700
	end -- 700
	if phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" or phase == "done" then -- 700
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
	if dt > 0 and self.liveReloadInvalidFlash > 0 then -- 718
		self.liveReloadInvalidFlash = math.max(0, self.liveReloadInvalidFlash - dt) -- 721
	end -- 721
	if events ~= nil and #events.rawEvents > 0 then -- 721
		local ei = 0 -- 724
		do -- 724
			ei = 0 -- 725
			while ei < #events.rawEvents do -- 725
				local ename = events.rawEvents[ei + 1].name -- 726
				if ename == "handRelease" then -- 726
					self.liveReleasedAbortCount = self.liveReleasedAbortCount + 1 -- 728
				elseif ename == "reloadInvalid" then -- 728
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
	local ____readBool_result_42 = readBool(rsRec, "firstTime") -- 797
	if ____readBool_result_42 == nil then -- 797
		____readBool_result_42 = reloadTryCount <= 1 -- 797
	end -- 797
	local reloadSession = { -- 795
		active = reloadActive, -- 796
		firstTime = ____readBool_result_42, -- 797
		elapsed = readNum(rsRec, "elapsed") or reloadAnswerTicks / 60, -- 798
		duration = math.max( -- 799
			0.01, -- 799
			readNum(rsRec, "duration") or DEFAULT_RELOAD_DURATION -- 799
		), -- 799
		path = livePath, -- 800
		previewEffect = livePreview, -- 801
		nextEffect = parseReloadEffect(liveNextRaw), -- 802
		invalidFlash = readNum(rsRec, "invalidFlash") or self.liveReloadInvalidFlash -- 803
	} -- 803
	local rawScale = readNum(pRec, "timeScale") or readNum(runRec, "timeScale") -- 806
	local timeScale = rawScale ~= nil and rawScale >= 0 and rawScale or (reloadActive and DEFAULT_SLOW_TIME_SCALE or 1) -- 807
	local ____asRecord_44 = asRecord -- 812
	local ____temp_43 -- 812
	if pRec ~= nil then -- 812
		____temp_43 = pRec.craftBench -- 812
	else -- 812
		____temp_43 = nil -- 812
	end -- 812
	local cbRec = ____asRecord_44(____temp_43) -- 812
	local craftBench = self:readLiveCraftBench(cbRec, pRec, runRec) -- 813
	local archive = self:readLiveArchive(p) -- 816
	self.liveArchiveCache = archive -- 817
	local visualMode = deriveVisualMode( -- 819
		p.room.key, -- 820
		p.phase, -- 821
		storyRoute, -- 822
		"locked", -- 823
		countProgress, -- 824
		gateReunion.completed -- 825
	) -- 825
	return { -- 828
		storyRoute = storyRoute, -- 829
		countElapsedTicks = countElapsedTicks, -- 830
		countDurationTicks = countDurationTicks, -- 831
		countNumber = countNumber, -- 832
		countProgress = countProgress, -- 833
		gateReunion = gateReunion, -- 834
		backCarry = backCarry, -- 835
		timeScale = timeScale, -- 836
		reloadSession = reloadSession, -- 837
		craftBench = craftBench, -- 838
		archive = archive, -- 839
		assistHintsEnabled = self.assistHintsEnabled, -- 840
		visualMode = visualMode, -- 841
		dataSource = "live", -- 842
		isRehearsal = false, -- 843
		rehearsalTag = "" -- 844
	} -- 844
end -- 715
function DualRouteContract.prototype.readLiveCraftBench(self, cbRec, pRec, runRec) -- 848
	local recipes = defaultRecipes() -- 853
	if cbRec ~= nil and __TS__ArrayIsArray(cbRec.recipes) then -- 853
		local rawList = cbRec.recipes -- 855
		local parsed = {} -- 856
		local i = 0 -- 857
		do -- 857
			i = 0 -- 858
			while i < #rawList do -- 858
				do -- 858
					local item = asRecord(rawList[i + 1]) -- 859
					if item == nil then -- 859
						goto __continue126 -- 861
					end -- 861
					local id = readStr(item, "id") -- 863
					local name = readStr(item, "name") -- 864
					if id == nil or name == nil then -- 864
						goto __continue126 -- 866
					end -- 866
					local ____id_46 = id -- 869
					local ____name_47 = name -- 870
					local ____temp_48 = readStr(item, "desc") or "" -- 871
					local ____parseReloadEffect_result_49 = parseReloadEffect(item.enhancedEffect) -- 872
					local ____temp_50 = readNumMap(item, "cost") or ({}) -- 873
					local ____readBool_result_45 = readBool(item, "crafted") -- 874
					if ____readBool_result_45 == nil then -- 874
						____readBool_result_45 = false -- 874
					end -- 874
					parsed[#parsed + 1] = { -- 868
						id = ____id_46, -- 869
						name = ____name_47, -- 870
						desc = ____temp_48, -- 871
						enhancedEffect = ____parseReloadEffect_result_49, -- 872
						cost = ____temp_50, -- 873
						crafted = ____readBool_result_45 -- 874
					} -- 874
				end -- 874
				::__continue126:: -- 874
				i = i + 1 -- 858
			end -- 858
		end -- 858
		if #parsed > 0 then -- 858
			local ____readBool_result_51 = readBool(cbRec, "active") -- 879
			if ____readBool_result_51 == nil then -- 879
				____readBool_result_51 = false -- 879
			end -- 879
			local ____readBool_result_52 = readBool(cbRec, "firstCraftDone") -- 880
			if ____readBool_result_52 == nil then -- 880
				____readBool_result_52 = false -- 880
			end -- 880
			return { -- 878
				active = ____readBool_result_51, -- 879
				firstCraftDone = ____readBool_result_52, -- 880
				justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 881
				inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or ({}), -- 882
				recipes = parsed, -- 883
				equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 884
			} -- 884
		end -- 884
	end -- 884
	local ____readBool_result_53 = readBool(cbRec, "active") -- 889
	if ____readBool_result_53 == nil then -- 889
		____readBool_result_53 = false -- 889
	end -- 889
	local ____readBool_result_54 = readBool(cbRec, "firstCraftDone") -- 890
	if ____readBool_result_54 == nil then -- 890
		____readBool_result_54 = false -- 890
	end -- 890
	return { -- 888
		active = ____readBool_result_53, -- 889
		firstCraftDone = ____readBool_result_54, -- 890
		justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 891
		inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or readNumMap(runRec, "craftInventory") or ({}), -- 892
		recipes = recipes, -- 893
		equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 894
	} -- 894
end -- 848
function DualRouteContract.prototype.readLiveArchive(self, p) -- 898
	local pRec = asRecord(p) -- 899
	local runRec = asRecord(p.run) -- 900
	local ____asRecord_56 = asRecord -- 901
	local ____temp_55 -- 901
	if pRec ~= nil then -- 901
		____temp_55 = pRec.archive -- 901
	else -- 901
		____temp_55 = nil -- 901
	end -- 901
	local ____asRecord_56_result_59 = ____asRecord_56(____temp_55) -- 901
	if ____asRecord_56_result_59 == nil then -- 901
		local ____asRecord_58 = asRecord -- 902
		local ____temp_57 -- 902
		if runRec ~= nil then -- 902
			____temp_57 = runRec.archive -- 902
		else -- 902
			____temp_57 = nil -- 902
		end -- 902
		____asRecord_56_result_59 = ____asRecord_58(____temp_57) -- 901
	end -- 901
	local archRec = ____asRecord_56_result_59 -- 901
	local ____readBool_result_60 = readBool(archRec, "childCleared") -- 904
	if ____readBool_result_60 == nil then -- 904
		____readBool_result_60 = readBool(pRec, "childCleared") -- 904
	end -- 904
	local ____readBool_result_60_61 = ____readBool_result_60 -- 904
	if ____readBool_result_60_61 == nil then -- 904
		____readBool_result_60_61 = false -- 904
	end -- 904
	local childCleared = ____readBool_result_60_61 -- 904
	local ____readBool_result_62 = readBool(archRec, "soldierCleared") -- 905
	if ____readBool_result_62 == nil then -- 905
		____readBool_result_62 = readBool(pRec, "soldierCleared") -- 905
	end -- 905
	local ____readBool_result_62_63 = ____readBool_result_62 -- 905
	if ____readBool_result_62_63 == nil then -- 905
		____readBool_result_62_63 = false -- 905
	end -- 905
	local soldierCleared = ____readBool_result_62_63 -- 905
	local ____readBool_result_64 = readBool(archRec, "artifactOwned") -- 906
	if ____readBool_result_64 == nil then -- 906
		____readBool_result_64 = readBool(pRec, "artifactOwned") -- 906
	end -- 906
	local ____readBool_result_64_65 = ____readBool_result_64 -- 906
	if ____readBool_result_64_65 == nil then -- 906
		____readBool_result_64_65 = false -- 906
	end -- 906
	local artifactOwned = ____readBool_result_64_65 -- 906
	local ____temp_67 -- 907
	if archRec ~= nil and archRec.museumPhase ~= nil then -- 907
		____temp_67 = archRec.museumPhase -- 908
	else -- 908
		local ____temp_66 -- 909
		if pRec ~= nil then -- 909
			____temp_66 = pRec.museumPhase -- 909
		else -- 909
			____temp_66 = nil -- 909
		end -- 909
		____temp_67 = ____temp_66 -- 909
	end -- 909
	local rawPhase = ____temp_67 -- 907
	local museumPhase = parseMuseumPhase(rawPhase) -- 910
	local ____readBool_result_68 = readBool(archRec, "museumSeen") -- 911
	if ____readBool_result_68 == nil then -- 911
		____readBool_result_68 = readBool(pRec, "museumSeen") -- 911
	end -- 911
	local ____readBool_result_68_69 = ____readBool_result_68 -- 911
	if ____readBool_result_68_69 == nil then -- 911
		____readBool_result_68_69 = false -- 911
	end -- 911
	local museumSeen = ____readBool_result_68_69 -- 911
	local livePhase = p.phase -- 920
	if p.room.key == "museum" then -- 920
		if livePhase == "museum-cabinet" then -- 920
			museumPhase = museumPhase == "well_reflect" and "well_reflect" or "hall_walk" -- 923
		elseif livePhase == "museum-hall" or livePhase == "museum-lamp" then -- 923
			museumPhase = "hall_walk" -- 925
		elseif livePhase == "museum-return" then -- 925
			museumPhase = "lamp_turn" -- 927
		elseif livePhase == "museum-knock" or livePhase == "museum-done" then -- 927
			museumPhase = "return_cabinet" -- 929
		end -- 929
	elseif p.room.key == "prologue" and museumPhase == "locked" and childCleared and soldierCleared and not museumSeen then -- 929
		local backendWellOpen = readBool(pRec, "wellOpen") == true -- 932
		local hasBackendWell = readNum(pRec, "wellX") ~= nil -- 933
		if backendWellOpen or livePhase == "prologue-well" or artifactOwned and hasBackendWell then -- 933
			museumPhase = "well_open" -- 935
		end -- 935
	end -- 935
	return { -- 939
		childCleared = childCleared, -- 940
		soldierCleared = soldierCleared, -- 941
		artifactOwned = artifactOwned, -- 942
		museumPhase = museumPhase, -- 943
		museumSeen = museumSeen -- 944
	} -- 944
end -- 898
function DualRouteContract.prototype.forwardLiveIntent(self, p, intent) -- 948
	if intent.kind == "craftSubmit" then -- 948
		if self.livePendingCraftRequests[intent.requestId] == true then -- 948
			return false -- 951
		end -- 951
		self.livePendingCraftRequests[intent.requestId] = true -- 953
	end -- 953
	local pRec = asRecord(p) -- 955
	if pRec == nil then -- 955
		return false -- 957
	end -- 957
	local handler = pRec.submitFeIntent -- 959
	if type(handler) == "function" then -- 959
		local fn = handler -- 961
		local result = fn(p, intent) -- 962
		if result ~= false then -- 962
			return true -- 964
		end -- 964
		if intent.kind == "museumInteract" and intent.target == "well_pickup" then -- 964
			local wellRes = fn(p, {kind = "wellPick"}) -- 968
			return wellRes ~= false -- 969
		end -- 969
		return false -- 971
	end -- 971
	local tapNode = pRec.reloadTapNode -- 974
	if type(tapNode) == "function" then -- 974
		local fn = tapNode -- 976
		if intent.kind == "reloadTapNode" then -- 976
			fn(p, intent.node) -- 978
			return true -- 979
		end -- 979
		if intent.kind == "reloadPathCommit" and #intent.path > 0 then -- 979
			local i = 0 -- 982
			do -- 982
				i = 0 -- 983
				while i < #intent.path do -- 983
					do -- 983
						if i == 0 and intent.path[i + 1] == 0 then -- 983
							goto __continue149 -- 985
						end -- 985
						fn(p, intent.path[i + 1]) -- 987
					end -- 987
					::__continue149:: -- 987
					i = i + 1 -- 983
				end -- 983
			end -- 983
			return true -- 989
		end -- 989
	end -- 989
	return false -- 992
end -- 948
function DualRouteContract.prototype.sampleRehearsal(self, p, dt, input, st) -- 997
	local countElapsedTicks = st.countTickOverride ~= nil and st.countTickOverride or p.countTick -- 998
	local countDurationTicks = math.max(1, st.countDurationOverride or GATE_COUNT_END) -- 999
	local countNumber = gateCountAtTick(countElapsedTicks) -- 1000
	local countProgress = math.max( -- 1001
		0, -- 1001
		math.min(1, countElapsedTicks / countDurationTicks) -- 1001
	) -- 1001
	if p.room.key == "gate" and p.phase == "gate-count" and st.storyRoute == "soldier" then -- 1001
		if countElapsedTicks < countDurationTicks then -- 1001
			st.gateReunion.active = false -- 1006
			st.gateReunion.knockHeard = false -- 1007
			st.gateReunion.holding = false -- 1008
			st.gateReunion.holdProgress = 0 -- 1009
			st.gateHoldArmed = not input.interact.held -- 1010
			st.gatePrevInteractHeld = input.interact.held -- 1011
		elseif not st.gateReunion.completed then -- 1011
			st.gateReunion.active = true -- 1013
			st.gateReunion.knockHeard = true -- 1014
			if not st.gateHoldArmed and not input.interact.held then -- 1014
				st.gateHoldArmed = true -- 1016
			end -- 1016
			if dt > 0 then -- 1016
				if st.gateHoldArmed and input.interact.held then -- 1016
					st.gateReunion.holding = true -- 1020
					st.gateReunion.holdProgress = math.min(1, st.gateReunion.holdProgress + dt / GATE_REUNION_HOLD_SECONDS) -- 1021
					if st.gateReunion.holdProgress >= 1 then -- 1021
						st.gateReunion.holdProgress = 1 -- 1026
						st.gateReunion.holding = false -- 1027
						st.gateReunion.completed = true -- 1028
						st.backCarry.handInHand = true -- 1029
					end -- 1029
				else -- 1029
					if st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1029
						local ____st_gateReunion_70, ____releasedAbortCount_71 = st.gateReunion, "releasedAbortCount" -- 1029
						____st_gateReunion_70[____releasedAbortCount_71] = ____st_gateReunion_70[____releasedAbortCount_71] + 1 -- 1033
					end -- 1033
					st.gateReunion.holding = false -- 1035
					st.gateReunion.holdProgress = 0 -- 1036
				end -- 1036
			end -- 1036
			st.gatePrevInteractHeld = input.interact.held -- 1039
		end -- 1039
	end -- 1039
	if st.reloadSession.active and dt > 0 then -- 1039
		local ____st_reloadSession_72, ____elapsed_73 = st.reloadSession, "elapsed" -- 1039
		____st_reloadSession_72[____elapsed_73] = ____st_reloadSession_72[____elapsed_73] + dt -- 1045
		if st.reloadSession.invalidFlash > 0 then -- 1045
			st.reloadSession.invalidFlash = math.max(0, st.reloadSession.invalidFlash - dt) -- 1047
		end -- 1047
		if st.reloadSession.elapsed >= st.reloadSession.duration then -- 1047
			st.reloadSession.active = false -- 1050
			st.reloadSession.elapsed = 0 -- 1051
			st.reloadSession.path = {} -- 1052
			st.reloadSession.previewEffect = "normal" -- 1053
			st.reloadSession.nextEffect = "normal" -- 1054
			st.reloadSession.firstTime = false -- 1055
			st.timeScaleOverride = nil -- 1056
		end -- 1056
	end -- 1056
	if st.craftBench.justCraftedTimer > 0 and dt > 0 then -- 1056
		st.craftBench.justCraftedTimer = math.max(0, st.craftBench.justCraftedTimer - dt) -- 1062
	end -- 1062
	local timeScale = st.timeScaleOverride ~= nil and math.max(0, st.timeScaleOverride) or (st.reloadSession.active and DEFAULT_SLOW_TIME_SCALE or 1) -- 1065
	local visualMode = deriveVisualMode( -- 1069
		p.room.key, -- 1070
		p.phase, -- 1071
		st.storyRoute, -- 1072
		st.archive.museumPhase, -- 1073
		countProgress, -- 1074
		st.gateReunion.completed -- 1075
	) -- 1075
	return { -- 1078
		storyRoute = st.storyRoute, -- 1079
		countElapsedTicks = countElapsedTicks, -- 1080
		countDurationTicks = countDurationTicks, -- 1081
		countNumber = countNumber, -- 1082
		countProgress = countProgress, -- 1083
		gateReunion = { -- 1084
			active = st.gateReunion.active, -- 1085
			knockHeard = st.gateReunion.knockHeard, -- 1086
			holdProgress = st.gateReunion.holdProgress, -- 1087
			holding = st.gateReunion.holding, -- 1088
			completed = st.gateReunion.completed, -- 1089
			releasedAbortCount = st.gateReunion.releasedAbortCount -- 1090
		}, -- 1090
		backCarry = {active = st.backCarry.active, handInHand = st.backCarry.handInHand, mounting = st.backCarry.mounting, atBench = st.backCarry.atBench}, -- 1092
		timeScale = timeScale, -- 1098
		reloadSession = { -- 1099
			active = st.reloadSession.active, -- 1100
			firstTime = st.reloadSession.firstTime, -- 1101
			elapsed = st.reloadSession.elapsed, -- 1102
			duration = st.reloadSession.duration, -- 1103
			path = __TS__ArraySlice(st.reloadSession.path), -- 1104
			previewEffect = st.reloadSession.previewEffect, -- 1105
			nextEffect = st.reloadSession.nextEffect, -- 1106
			invalidFlash = st.reloadSession.invalidFlash -- 1107
		}, -- 1107
		craftBench = { -- 1109
			active = st.craftBench.active, -- 1110
			firstCraftDone = st.craftBench.firstCraftDone, -- 1111
			justCraftedTimer = st.craftBench.justCraftedTimer, -- 1112
			inventory = cloneRecordNum(st.craftBench.inventory), -- 1113
			recipes = cloneRecipes(st.craftBench.recipes), -- 1114
			equippedWeapon = st.craftBench.equippedWeapon -- 1115
		}, -- 1115
		archive = { -- 1117
			childCleared = st.archive.childCleared, -- 1118
			soldierCleared = st.archive.soldierCleared, -- 1119
			artifactOwned = st.archive.artifactOwned, -- 1120
			museumPhase = st.archive.museumPhase, -- 1121
			museumSeen = st.archive.museumSeen -- 1122
		}, -- 1122
		assistHintsEnabled = self.assistHintsEnabled, -- 1124
		visualMode = visualMode, -- 1125
		dataSource = "rehearsal", -- 1126
		isRehearsal = true, -- 1127
		rehearsalTag = st.tag -- 1128
	} -- 1128
end -- 997
function DualRouteContract.prototype.applyRehearsalIntent(self, st, intent) -- 1132
	if intent.kind == "gateReunionHold" then -- 1132
		if not st.gateReunion.active or st.gateReunion.completed then -- 1132
			return false -- 1135
		end -- 1135
		if not intent.holding and st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1135
			local ____st_gateReunion_74, ____releasedAbortCount_75 = st.gateReunion, "releasedAbortCount" -- 1135
			____st_gateReunion_74[____releasedAbortCount_75] = ____st_gateReunion_74[____releasedAbortCount_75] + 1 -- 1138
			st.gateReunion.holdProgress = 0 -- 1139
		end -- 1139
		st.gateReunion.holding = intent.holding -- 1141
		return true -- 1142
	end -- 1142
	if intent.kind == "reloadOpen" then -- 1142
		self:triggerMockReload(true) -- 1145
		return true -- 1146
	end -- 1146
	if intent.kind == "reloadTapNode" then -- 1146
		if not st.reloadSession.active then -- 1146
			return false -- 1150
		end -- 1150
		if #st.reloadSession.path == 0 then -- 1150
			local ____st_reloadSession_path_76 = st.reloadSession.path -- 1150
			____st_reloadSession_path_76[#____st_reloadSession_path_76 + 1] = 0 -- 1153
		end -- 1153
		if __TS__ArrayIndexOf(st.reloadSession.path, intent.node) >= 0 then -- 1153
			st.reloadSession.invalidFlash = 0.35 -- 1156
			st.reloadSession.path = {0} -- 1157
			st.reloadSession.previewEffect = "normal" -- 1158
			return false -- 1159
		end -- 1159
		local ____st_reloadSession_path_77 = st.reloadSession.path -- 1159
		____st_reloadSession_path_77[#____st_reloadSession_path_77 + 1] = intent.node -- 1161
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(st.reloadSession.path) -- 1162
		if intent.node == 8 then -- 1162
			st.reloadSession.nextEffect = st.reloadSession.previewEffect -- 1164
			st.reloadSession.active = false -- 1165
			st.reloadSession.elapsed = 0 -- 1166
			st.reloadSession.path = {} -- 1167
			st.reloadSession.firstTime = false -- 1168
			st.timeScaleOverride = nil -- 1169
		end -- 1169
		return true -- 1171
	end -- 1171
	if intent.kind == "reloadPathPreview" then -- 1171
		if not st.reloadSession.active then -- 1171
			return false -- 1175
		end -- 1175
		st.reloadSession.path = __TS__ArraySlice(intent.path) -- 1177
		st.reloadSession.previewEffect = deriveReloadEffectFromPath(intent.path) -- 1178
		return true -- 1179
	end -- 1179
	if intent.kind == "reloadPathCommit" then -- 1179
		if not st.reloadSession.active then -- 1179
			return false -- 1183
		end -- 1183
		if #intent.path < 2 then -- 1183
			st.reloadSession.invalidFlash = 0.35 -- 1186
			st.reloadSession.path = {} -- 1187
			st.reloadSession.previewEffect = "normal" -- 1188
			return false -- 1189
		end -- 1189
		local effect = deriveReloadEffectFromPath(intent.path) -- 1191
		st.reloadSession.nextEffect = effect -- 1192
		st.reloadSession.previewEffect = effect -- 1193
		st.reloadSession.path = {} -- 1194
		st.reloadSession.active = false -- 1195
		st.reloadSession.elapsed = 0 -- 1196
		st.reloadSession.firstTime = false -- 1197
		st.timeScaleOverride = nil -- 1198
		return true -- 1199
	end -- 1199
	if intent.kind == "reloadCancel" then -- 1199
		st.reloadSession.active = false -- 1202
		st.reloadSession.elapsed = 0 -- 1203
		st.reloadSession.path = {} -- 1204
		st.reloadSession.previewEffect = "normal" -- 1205
		st.timeScaleOverride = nil -- 1206
		return true -- 1207
	end -- 1207
	if intent.kind == "craftSubmit" then -- 1207
		if not st.craftBench.active or st.handledCraftRequestIds[intent.requestId] == true then -- 1207
			return false -- 1211
		end -- 1211
		local target -- 1213
		local i = 0 -- 1214
		do -- 1214
			i = 0 -- 1215
			while i < #st.craftBench.recipes do -- 1215
				if st.craftBench.recipes[i + 1].id == intent.recipeId then -- 1215
					target = st.craftBench.recipes[i + 1] -- 1217
					break -- 1218
				end -- 1218
				i = i + 1 -- 1215
			end -- 1215
		end -- 1215
		if target == nil or target.crafted then -- 1215
			return false -- 1222
		end -- 1222
		for mat in pairs(target.cost) do -- 1224
			if (st.craftBench.inventory[mat] or 0) < target.cost[mat] then -- 1224
				return false -- 1226
			end -- 1226
		end -- 1226
		for mat in pairs(target.cost) do -- 1229
			st.craftBench.inventory[mat] = (st.craftBench.inventory[mat] or 0) - target.cost[mat] -- 1230
		end -- 1230
		st.handledCraftRequestIds[intent.requestId] = true -- 1232
		target.crafted = true -- 1233
		st.craftBench.equippedWeapon = target.id -- 1234
		st.craftBench.justCraftedTimer = st.craftBench.firstCraftDone and 0.45 or 1 -- 1235
		st.craftBench.firstCraftDone = true -- 1236
		return true -- 1237
	end -- 1237
	if intent.kind == "craftEquip" then -- 1237
		st.craftBench.equippedWeapon = intent.weaponId -- 1240
		return true -- 1241
	end -- 1241
	if intent.kind == "craftClose" then -- 1241
		st.craftBench.active = false -- 1244
		st.backCarry.atBench = false -- 1245
		return true -- 1246
	end -- 1246
	if intent.kind == "museumInteract" then -- 1246
		if intent.target == "well_pickup" and st.archive.museumPhase == "well_open" then -- 1246
			st.archive.artifactOwned = true -- 1250
			st.archive.museumPhase = "well_reflect" -- 1251
			return true -- 1252
		end -- 1252
		if intent.target == "enter_hall" and st.archive.museumPhase == "well_reflect" then -- 1252
			st.archive.museumPhase = "hall_walk" -- 1255
			return true -- 1256
		end -- 1256
		if intent.target == "lamp_turn" and st.archive.museumPhase == "hall_walk" then -- 1256
			st.archive.museumPhase = "lamp_turn" -- 1259
			return true -- 1260
		end -- 1260
		if intent.target == "begin_return_cabinet" and st.archive.museumPhase == "lamp_turn" then -- 1260
			st.archive.museumPhase = "return_cabinet" -- 1263
			return true -- 1264
		end -- 1264
		if intent.target == "return_cabinet" then -- 1264
			st.archive.museumPhase = "done" -- 1267
			st.archive.museumSeen = true -- 1268
			return true -- 1269
		end -- 1269
		return false -- 1271
	end -- 1271
	return false -- 1273
end -- 1132
return ____exports -- 1132