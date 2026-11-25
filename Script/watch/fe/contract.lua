-- [ts]: contract.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local ____exports = {} -- 1
local ____play = require("Script.watch.play") -- 20
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 20
local gateCountAtTick = ____play.gateCountAtTick -- 20
local GATE_REUNION_HOLD_SECONDS = 0.6 -- 157
local DEFAULT_RELOAD_DURATION = 4 -- 158
local DEFAULT_SLOW_TIME_SCALE = 0.25 -- 159
local MAX_INTENT_LOG = 64 -- 160
local function defaultRecipes() -- 162
	return {{ -- 163
		id = "guide_lantern_gun", -- 165
		name = "引路灯铳", -- 166
		desc = "以两枚木纹筹改制，增强灯纹照亮范围与余明", -- 167
		enhancedEffect = "light", -- 168
		cost = {wood_tally = 2}, -- 169
		crafted = false -- 170
	}, { -- 170
		id = "echo_gun", -- 173
		name = "回声铳", -- 174
		desc = "以一枚木纹筹与一枚铃纹筹改制，增强铃纹回声诱导", -- 175
		enhancedEffect = "echo", -- 176
		cost = {wood_tally = 1, bell_tally = 1}, -- 177
		crafted = false -- 178
	}} -- 178
end -- 162
local function cloneRecordNum(src) -- 183
	local out = {} -- 184
	for k in pairs(src) do -- 185
		out[k] = src[k] -- 186
	end -- 186
	return out -- 188
end -- 183
local function cloneRecipes(list) -- 191
	local out = {} -- 192
	local i = 0 -- 193
	do -- 193
		i = 0 -- 194
		while i < #list do -- 194
			local r = list[i + 1] -- 195
			out[#out + 1] = { -- 196
				id = r.id, -- 197
				name = r.name, -- 198
				desc = r.desc, -- 199
				enhancedEffect = r.enhancedEffect, -- 200
				cost = cloneRecordNum(r.cost), -- 201
				crafted = r.crafted -- 202
			} -- 202
			i = i + 1 -- 194
		end -- 194
	end -- 194
	return out -- 205
end -- 191
local function createEmptyGateReunion() -- 208
	return { -- 209
		active = false, -- 210
		knockHeard = false, -- 211
		holdProgress = 0, -- 212
		holding = false, -- 213
		completed = false, -- 214
		releasedAbortCount = 0 -- 215
	} -- 215
end -- 208
local function createEmptyBackCarry() -- 219
	return {active = false, handInHand = false, mounting = false, atBench = false} -- 220
end -- 219
local function createEmptyReloadSession() -- 228
	return { -- 229
		active = false, -- 230
		firstTime = true, -- 231
		elapsed = 0, -- 232
		duration = DEFAULT_RELOAD_DURATION, -- 233
		path = {}, -- 234
		previewEffect = "normal", -- 235
		nextEffect = "normal", -- 236
		invalidFlash = 0 -- 237
	} -- 237
end -- 228
local function createEmptyCraftBench() -- 241
	return { -- 242
		active = false, -- 243
		firstCraftDone = false, -- 244
		justCraftedTimer = 0, -- 245
		inventory = {}, -- 246
		recipes = defaultRecipes(), -- 247
		equippedWeapon = "standard_gun" -- 248
	} -- 248
end -- 241
local function createEmptyArchive() -- 252
	return { -- 253
		childCleared = false, -- 254
		soldierCleared = false, -- 255
		artifactOwned = false, -- 256
		museumPhase = "locked", -- 257
		museumSeen = false -- 258
	} -- 258
end -- 252
local function createInitialRehearsalState(tag) -- 262
	local bench = createEmptyCraftBench() -- 263
	bench.inventory = {wood_tally = 2, bell_tally = 1} -- 264
	return { -- 265
		tag = tag, -- 266
		storyRoute = "undecided", -- 267
		countTickOverride = nil, -- 268
		countDurationOverride = nil, -- 269
		timeScaleOverride = nil, -- 270
		gateReunion = createEmptyGateReunion(), -- 271
		gateHoldArmed = true, -- 272
		gatePrevInteractHeld = false, -- 273
		backCarry = createEmptyBackCarry(), -- 274
		reloadSession = createEmptyReloadSession(), -- 275
		craftBench = bench, -- 276
		archive = createEmptyArchive(), -- 277
		handledCraftRequestIds = {} -- 278
	} -- 278
end -- 262
local function asRecord(value) -- 282
	if value ~= nil and type(value) == "table" then -- 282
		return value -- 284
	end -- 284
	return nil -- 286
end -- 282
local function readNum(rec, key) -- 289
	if rec == nil then -- 289
		return nil -- 291
	end -- 291
	local v = rec[key] -- 293
	return type(v) == "number" and v or nil -- 294
end -- 289
local function readBool(rec, key) -- 297
	if rec == nil then -- 297
		return nil -- 299
	end -- 299
	local v = rec[key] -- 301
	local ____temp_0 -- 302
	if type(v) == "boolean" then -- 302
		____temp_0 = v -- 302
	else -- 302
		____temp_0 = nil -- 302
	end -- 302
	return ____temp_0 -- 302
end -- 297
local function readStr(rec, key) -- 305
	if rec == nil then -- 305
		return nil -- 307
	end -- 307
	local v = rec[key] -- 309
	return type(v) == "string" and v or nil -- 310
end -- 305
local function readNumArray(rec, key) -- 313
	if rec == nil then -- 313
		return nil -- 315
	end -- 315
	local v = rec[key] -- 317
	if not __TS__ArrayIsArray(v) then -- 317
		return nil -- 319
	end -- 319
	local out = {} -- 321
	local i = 0 -- 322
	do -- 322
		i = 0 -- 323
		while i < #v do -- 323
			if type(v[i + 1]) == "number" then -- 323
				out[#out + 1] = v[i + 1] -- 325
			end -- 325
			i = i + 1 -- 323
		end -- 323
	end -- 323
	return out -- 328
end -- 313
local function readNumMap(rec, key) -- 331
	if rec == nil then -- 331
		return nil -- 333
	end -- 333
	local obj = asRecord(rec[key]) -- 335
	if obj == nil then -- 335
		return nil -- 337
	end -- 337
	local out = {} -- 339
	for k in pairs(obj) do -- 340
		local val = obj[k] -- 341
		if type(val) == "number" then -- 341
			out[k] = val -- 343
		end -- 343
	end -- 343
	return out -- 346
end -- 331
local function parseStoryRoute(v) -- 349
	if v == "child" or v == "soldier" then -- 349
		return v -- 351
	end -- 351
	return "undecided" -- 353
end -- 349
local function parseReloadEffect(v) -- 356
	if v == "knockback" or v == "echo" or v == "light" then -- 356
		return v -- 358
	end -- 358
	return "normal" -- 360
end -- 356
local function parseMuseumPhase(v) -- 363
	if v == "well_open" or v == "well_reflect" or v == "hall_walk" or v == "lamp_turn" or v == "return_cabinet" or v == "done" then -- 363
		return v -- 372
	end -- 372
	return "locked" -- 374
end -- 363
--- 根据 3×3 路径点集合推导效果（用于排演态预览与提交：4=铃纹，5=灯纹，其余有效连线=推退）
local function deriveRehearsalReloadEffect(path) -- 378
	if #path < 2 then -- 378
		return "normal" -- 380
	end -- 380
	local hasBell = false -- 382
	local hasLight = false -- 383
	local i = 0 -- 384
	do -- 384
		i = 0 -- 385
		while i < #path do -- 385
			if path[i + 1] == 4 then -- 385
				hasBell = true -- 387
			elseif path[i + 1] == 5 then -- 387
				hasLight = true -- 389
			end -- 389
			i = i + 1 -- 385
		end -- 385
	end -- 385
	if hasLight then -- 385
		return "light" -- 393
	end -- 393
	if hasBell then -- 393
		return "echo" -- 396
	end -- 396
	return "knockback" -- 398
end -- 378
local function deriveVisualMode(roomKey, phase, storyRoute, museumPhase, countProgress, reunionCompleted) -- 401
	if museumPhase == "well_reflect" or museumPhase == "hall_walk" or museumPhase == "lamp_turn" or museumPhase == "return_cabinet" then -- 401
		return "museum" -- 415
	end -- 415
	if roomKey == "gate" then -- 415
		if phase == "gate-count" then -- 415
			if storyRoute == "soldier" and reunionCompleted then -- 415
				return "pixel" -- 420
			end -- 420
			if countProgress <= 0 then -- 420
				return "pixel" -- 423
			end -- 423
			if countProgress >= 1 then -- 423
				return "lowpoly" -- 426
			end -- 426
			return "transition" -- 428
		end -- 428
		if phase == "gate-walk" then -- 428
			return storyRoute == "soldier" and "pixel" or (storyRoute == "child" and "lowpoly" or "pixel") -- 431
		end -- 431
		return "pixel" -- 433
	end -- 433
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" then -- 433
		if storyRoute == "child" then -- 433
			return "lowpoly" -- 437
		end -- 437
		return "pixel" -- 439
	end -- 439
	return "pixel" -- 441
end -- 401
____exports.DualRouteContract = __TS__Class() -- 444
local DualRouteContract = ____exports.DualRouteContract -- 444
DualRouteContract.name = "DualRouteContract" -- 444
function DualRouteContract.prototype.____constructor(self) -- 444
	self.source = "live" -- 445
	self.assistHintsEnabled = false -- 448
	self.livePendingCraftRequests = {} -- 450
	self.liveArchiveCache = createEmptyArchive() -- 451
	self.intentLog = {} -- 452
end -- 444
function DualRouteContract.prototype.getDataSource(self) -- 456
	return self.source -- 457
end -- 456
function DualRouteContract.prototype.isRehearsal(self) -- 461
	return self.source == "rehearsal" and self.rehearsal ~= nil -- 462
end -- 461
function DualRouteContract.prototype.enterRehearsal(self, tag) -- 466
	if tag == nil then -- 466
		tag = "rehearsal" -- 466
	end -- 466
	self.source = "rehearsal" -- 467
	if self.rehearsal == nil then -- 467
		self.rehearsal = createInitialRehearsalState(tag) -- 469
	else -- 469
		self.rehearsal.tag = tag -- 471
	end -- 471
end -- 466
function DualRouteContract.prototype.exitRehearsal(self) -- 476
	self.source = "live" -- 477
	self.rehearsal = nil -- 478
end -- 476
function DualRouteContract.prototype.ensureRehearsal(self, tag) -- 481
	if tag == nil then -- 481
		tag = "mock" -- 481
	end -- 481
	if self.source ~= "rehearsal" or self.rehearsal == nil then -- 481
		self:enterRehearsal(tag) -- 483
	end -- 483
	return self.rehearsal -- 485
end -- 481
function DualRouteContract.prototype.isAssistHintsEnabled(self) -- 488
	return self.assistHintsEnabled -- 489
end -- 488
function DualRouteContract.prototype.setAssistHintsEnabled(self, enabled) -- 492
	self.assistHintsEnabled = enabled -- 493
end -- 492
function DualRouteContract.prototype.toggleAssistHints(self) -- 496
	self.assistHintsEnabled = not self.assistHintsEnabled -- 497
	return self.assistHintsEnabled -- 498
end -- 496
function DualRouteContract.prototype.getLastSnapshot(self) -- 501
	return self.lastSnapshot -- 502
end -- 501
function DualRouteContract.prototype.peekSnapshot(self, p) -- 506
	local neutralInput = {interact = {held = false, pressed = false, released = false}} -- 507
	return self:sample(p, 0, neutralInput) -- 510
end -- 506
function DualRouteContract.prototype.getIntentLog(self) -- 513
	return self.intentLog -- 514
end -- 513
function DualRouteContract.prototype.clearIntentLog(self) -- 517
	self.intentLog = {} -- 518
end -- 517
function DualRouteContract.prototype.resetForRoom(self, p) -- 528
	self.livePendingCraftRequests = {} -- 529
	self.liveArchiveCache = self:readLiveArchive(p) -- 530
	if self.rehearsal ~= nil then -- 530
		self.rehearsal.gateReunion = createEmptyGateReunion() -- 532
		self.rehearsal.gateHoldArmed = true -- 533
		self.rehearsal.gatePrevInteractHeld = false -- 534
		self.rehearsal.reloadSession = createEmptyReloadSession() -- 535
		self.rehearsal.craftBench.active = false -- 536
		self.rehearsal.craftBench.justCraftedTimer = 0 -- 537
		self.rehearsal.handledCraftRequestIds = {} -- 538
		self.rehearsal.timeScaleOverride = nil -- 539
	end -- 539
end -- 528
function DualRouteContract.prototype.sample(self, p, rawDt, input, _events) -- 549
	local dt = p.paused and 0 or math.max(0, rawDt) -- 550
	local snap = self.source == "rehearsal" and self.rehearsal ~= nil and self:sampleRehearsal(p, dt, input, self.rehearsal) or self:sampleLive(p) -- 551
	self.lastSnapshot = snap -- 554
	return snap -- 555
end -- 549
function DualRouteContract.prototype.submitIntent(self, p, intent) -- 563
	local accepted = false -- 564
	if self.source == "rehearsal" and self.rehearsal ~= nil then -- 564
		accepted = self:applyRehearsalIntent(self.rehearsal, intent) -- 566
	else -- 566
		accepted = self:forwardLiveIntent(p, intent) -- 568
	end -- 568
	local ____self_intentLog_1 = self.intentLog -- 568
	____self_intentLog_1[#____self_intentLog_1 + 1] = {tick = p.ticks, source = self.source, intent = intent, accepted = accepted} -- 570
	if #self.intentLog > MAX_INTENT_LOG then -- 570
		table.remove(self.intentLog, 1) -- 577
	end -- 577
	return accepted -- 579
end -- 563
function DualRouteContract.prototype.setMockRoute(self, route) -- 584
	local st = self:ensureRehearsal("mock") -- 585
	st.storyRoute = route -- 586
end -- 584
function DualRouteContract.prototype.setMockCountTick(self, tick, duration) -- 589
	local st = self:ensureRehearsal("mock") -- 590
	st.countTickOverride = tick -- 591
	if duration ~= nil and duration > 0 then -- 591
		st.countDurationOverride = duration -- 593
	end -- 593
end -- 589
function DualRouteContract.prototype.setMockTimeScale(self, scale) -- 597
	local st = self:ensureRehearsal("mock") -- 598
	st.timeScaleOverride = scale -- 599
end -- 597
function DualRouteContract.prototype.setMockGateReunion(self, patch) -- 602
	local st = self:ensureRehearsal("mock") -- 603
	if patch.active ~= nil then -- 603
		st.gateReunion.active = patch.active -- 604
	end -- 604
	if patch.knockHeard ~= nil then -- 604
		st.gateReunion.knockHeard = patch.knockHeard -- 605
	end -- 605
	if patch.holdProgress ~= nil then -- 605
		st.gateReunion.holdProgress = math.max( -- 606
			0, -- 606
			math.min(1, patch.holdProgress) -- 606
		) -- 606
	end -- 606
	if patch.holding ~= nil then -- 606
		st.gateReunion.holding = patch.holding -- 607
	end -- 607
	if patch.completed ~= nil then -- 607
		st.gateReunion.completed = patch.completed -- 608
	end -- 608
	if patch.releasedAbortCount ~= nil then -- 608
		st.gateReunion.releasedAbortCount = patch.releasedAbortCount -- 609
	end -- 609
end -- 602
function DualRouteContract.prototype.setMockBackCarry(self, patch) -- 612
	local st = self:ensureRehearsal("mock") -- 613
	if patch.active ~= nil then -- 613
		st.backCarry.active = patch.active -- 614
	end -- 614
	if patch.handInHand ~= nil then -- 614
		st.backCarry.handInHand = patch.handInHand -- 615
	end -- 615
	if patch.mounting ~= nil then -- 615
		st.backCarry.mounting = patch.mounting -- 616
	end -- 616
	if patch.atBench ~= nil then -- 616
		st.backCarry.atBench = patch.atBench -- 617
	end -- 617
end -- 612
function DualRouteContract.prototype.triggerMockReload(self, active, options) -- 620
	local st = self:ensureRehearsal("mock") -- 624
	st.reloadSession.active = active -- 625
	if active then -- 625
		st.reloadSession.elapsed = 0 -- 627
		st.reloadSession.duration = options and options.duration or DEFAULT_RELOAD_DURATION -- 628
		st.reloadSession.path = {} -- 629
		st.reloadSession.previewEffect = "normal" -- 630
		st.reloadSession.invalidFlash = 0 -- 631
		if (options and options.firstTime) ~= nil then -- 631
			st.reloadSession.firstTime = options.firstTime -- 633
		end -- 633
		st.timeScaleOverride = options and options.slowTimeScale or DEFAULT_SLOW_TIME_SCALE -- 635
	else -- 635
		st.reloadSession.elapsed = 0 -- 637
		st.reloadSession.path = {} -- 638
		st.timeScaleOverride = nil -- 639
	end -- 639
end -- 620
function DualRouteContract.prototype.triggerMockBench(self, active, options) -- 643
	local st = self:ensureRehearsal("mock") -- 647
	st.craftBench.active = active -- 648
	st.backCarry.atBench = active -- 649
	if (options and options.inventory) ~= nil then -- 649
		st.craftBench.inventory = cloneRecordNum(options.inventory) -- 651
	end -- 651
	if (options and options.equippedWeapon) ~= nil then -- 651
		st.craftBench.equippedWeapon = options.equippedWeapon -- 654
	end -- 654
end -- 643
function DualRouteContract.prototype.setMockArchive(self, childCleared, soldierCleared, artifactOwned) -- 658
	local st = self:ensureRehearsal("mock") -- 659
	st.archive.childCleared = childCleared -- 660
	st.archive.soldierCleared = soldierCleared -- 661
	if artifactOwned ~= nil then -- 661
		st.archive.artifactOwned = artifactOwned -- 663
	end -- 663
	if childCleared and soldierCleared and st.archive.museumPhase == "locked" then -- 663
		st.archive.museumPhase = "well_open" -- 666
	elseif (not childCleared or not soldierCleared) and st.archive.museumPhase == "well_open" then -- 666
		st.archive.museumPhase = "locked" -- 668
	end -- 668
end -- 658
function DualRouteContract.prototype.enterMockMuseum(self, phase) -- 672
	local st = self:ensureRehearsal("mock") -- 673
	st.archive.museumPhase = phase -- 674
	if phase == "done" then -- 674
		st.archive.museumSeen = true -- 676
	end -- 676
	if phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" or phase == "done" then -- 676
		st.archive.artifactOwned = true -- 685
	end -- 685
end -- 672
function DualRouteContract.prototype.sampleLive(self, p) -- 691
	local pRec = asRecord(p) -- 692
	local runRec = asRecord(p.run) -- 693
	local ____temp_13 -- 696
	if pRec ~= nil and pRec.storyRoute ~= nil then -- 696
		____temp_13 = pRec.storyRoute -- 697
	else -- 697
		local ____temp_12 -- 698
		if runRec ~= nil then -- 698
			____temp_12 = runRec.storyRoute -- 698
		else -- 698
			____temp_12 = nil -- 698
		end -- 698
		____temp_13 = ____temp_12 -- 698
	end -- 698
	local rawRoute = ____temp_13 -- 696
	local storyRoute = parseStoryRoute(rawRoute) -- 699
	local countElapsedTicks = readNum(pRec, "countElapsedTicks") or p.countTick -- 702
	local countDurationTicks = math.max( -- 703
		1, -- 703
		readNum(pRec, "countDurationTicks") or GATE_COUNT_END -- 703
	) -- 703
	local countNumber = gateCountAtTick(countElapsedTicks) -- 704
	local countProgress = math.max( -- 705
		0, -- 705
		math.min(1, countElapsedTicks / countDurationTicks) -- 705
	) -- 705
	local ____asRecord_15 = asRecord -- 708
	local ____temp_14 -- 708
	if pRec ~= nil then -- 708
		____temp_14 = pRec.gateReunion -- 708
	else -- 708
		____temp_14 = nil -- 708
	end -- 708
	local grRec = ____asRecord_15(____temp_14) -- 708
	local flatHold = readNum(pRec, "gateHoldProgress") -- 709
	local ____readBool_result_16 = readBool(grRec, "active") -- 711
	if ____readBool_result_16 == nil then -- 711
		____readBool_result_16 = false -- 711
	end -- 711
	local ____readBool_result_17 = readBool(grRec, "knockHeard") -- 712
	if ____readBool_result_17 == nil then -- 712
		____readBool_result_17 = false -- 712
	end -- 712
	local ____math_max_result_20 = math.max( -- 713
		0, -- 713
		math.min( -- 713
			1, -- 713
			readNum(grRec, "holdProgress") or flatHold or 0 -- 713
		) -- 713
	) -- 713
	local ____readBool_result_18 = readBool(grRec, "holding") -- 714
	if ____readBool_result_18 == nil then -- 714
		____readBool_result_18 = false -- 714
	end -- 714
	local ____readBool_result_19 = readBool(grRec, "completed") -- 715
	if ____readBool_result_19 == nil then -- 715
		____readBool_result_19 = false -- 715
	end -- 715
	local gateReunion = { -- 710
		active = ____readBool_result_16, -- 711
		knockHeard = ____readBool_result_17, -- 712
		holdProgress = ____math_max_result_20, -- 713
		holding = ____readBool_result_18, -- 714
		completed = ____readBool_result_19, -- 715
		releasedAbortCount = readNum(grRec, "releasedAbortCount") or 0 -- 716
	} -- 716
	local ____asRecord_22 = asRecord -- 720
	local ____temp_21 -- 720
	if pRec ~= nil then -- 720
		____temp_21 = pRec.backCarry -- 720
	else -- 720
		____temp_21 = nil -- 720
	end -- 720
	local bcRec = ____asRecord_22(____temp_21) -- 720
	local ____readBool_result_23 = readBool(bcRec, "active") -- 722
	if ____readBool_result_23 == nil then -- 722
		____readBool_result_23 = false -- 722
	end -- 722
	local ____readBool_result_24 = readBool(bcRec, "handInHand") -- 723
	if ____readBool_result_24 == nil then -- 723
		____readBool_result_24 = false -- 723
	end -- 723
	local ____readBool_result_25 = readBool(bcRec, "mounting") -- 724
	if ____readBool_result_25 == nil then -- 724
		____readBool_result_25 = false -- 724
	end -- 724
	local ____readBool_result_26 = readBool(bcRec, "atBench") -- 725
	if ____readBool_result_26 == nil then -- 725
		____readBool_result_26 = false -- 725
	end -- 725
	local backCarry = {active = ____readBool_result_23, handInHand = ____readBool_result_24, mounting = ____readBool_result_25, atBench = ____readBool_result_26} -- 721
	local rawScale = readNum(pRec, "timeScale") or readNum(runRec, "timeScale") -- 729
	local timeScale = rawScale ~= nil and rawScale >= 0 and rawScale or 1 -- 730
	local ____asRecord_28 = asRecord -- 733
	local ____temp_27 -- 733
	if pRec ~= nil then -- 733
		____temp_27 = pRec.reloadSession -- 733
	else -- 733
		____temp_27 = nil -- 733
	end -- 733
	local rsRec = ____asRecord_28(____temp_27) -- 733
	local flatPath = readNumArray(pRec, "reloadPath") -- 734
	local ____readBool_result_29 = readBool(rsRec, "active") -- 736
	if ____readBool_result_29 == nil then -- 736
		____readBool_result_29 = false -- 736
	end -- 736
	local ____readBool_result_30 = readBool(rsRec, "firstTime") -- 737
	if ____readBool_result_30 == nil then -- 737
		____readBool_result_30 = true -- 737
	end -- 737
	local ____temp_36 = readNum(rsRec, "elapsed") or 0 -- 738
	local ____math_max_result_37 = math.max( -- 739
		0.01, -- 739
		readNum(rsRec, "duration") or DEFAULT_RELOAD_DURATION -- 739
	) -- 739
	local ____temp_38 = readNumArray(rsRec, "path") or flatPath or ({}) -- 740
	local ____parseReloadEffect_32 = parseReloadEffect -- 741
	local ____temp_31 -- 741
	if rsRec ~= nil then -- 741
		____temp_31 = rsRec.previewEffect -- 741
	else -- 741
		____temp_31 = nil -- 741
	end -- 741
	local ____parseReloadEffect_32_result_39 = ____parseReloadEffect_32(____temp_31) -- 741
	local ____parseReloadEffect_35 = parseReloadEffect -- 742
	local ____temp_34 -- 743
	if rsRec ~= nil and rsRec.nextEffect ~= nil then -- 743
		____temp_34 = rsRec.nextEffect -- 744
	else -- 744
		local ____temp_33 -- 745
		if pRec ~= nil then -- 745
			____temp_33 = pRec.nextEffect -- 745
		else -- 745
			____temp_33 = nil -- 745
		end -- 745
		____temp_34 = ____temp_33 -- 745
	end -- 745
	local reloadSession = { -- 735
		active = ____readBool_result_29, -- 736
		firstTime = ____readBool_result_30, -- 737
		elapsed = ____temp_36, -- 738
		duration = ____math_max_result_37, -- 739
		path = ____temp_38, -- 740
		previewEffect = ____parseReloadEffect_32_result_39, -- 741
		nextEffect = ____parseReloadEffect_35(____temp_34), -- 742
		invalidFlash = readNum(rsRec, "invalidFlash") or 0 -- 747
	} -- 747
	local ____asRecord_41 = asRecord -- 751
	local ____temp_40 -- 751
	if pRec ~= nil then -- 751
		____temp_40 = pRec.craftBench -- 751
	else -- 751
		____temp_40 = nil -- 751
	end -- 751
	local cbRec = ____asRecord_41(____temp_40) -- 751
	local craftBench = self:readLiveCraftBench(cbRec, pRec, runRec) -- 752
	local archive = self:readLiveArchive(p) -- 755
	self.liveArchiveCache = archive -- 756
	local visualMode = deriveVisualMode( -- 758
		p.room.key, -- 759
		p.phase, -- 760
		storyRoute, -- 761
		archive.museumPhase, -- 762
		countProgress, -- 763
		gateReunion.completed -- 764
	) -- 764
	return { -- 767
		storyRoute = storyRoute, -- 768
		countElapsedTicks = countElapsedTicks, -- 769
		countDurationTicks = countDurationTicks, -- 770
		countNumber = countNumber, -- 771
		countProgress = countProgress, -- 772
		gateReunion = gateReunion, -- 773
		backCarry = backCarry, -- 774
		timeScale = timeScale, -- 775
		reloadSession = reloadSession, -- 776
		craftBench = craftBench, -- 777
		archive = archive, -- 778
		assistHintsEnabled = self.assistHintsEnabled, -- 779
		visualMode = visualMode, -- 780
		dataSource = "live", -- 781
		isRehearsal = false, -- 782
		rehearsalTag = "" -- 783
	} -- 783
end -- 691
function DualRouteContract.prototype.readLiveCraftBench(self, cbRec, pRec, runRec) -- 787
	local recipes = defaultRecipes() -- 792
	if cbRec ~= nil and __TS__ArrayIsArray(cbRec.recipes) then -- 792
		local rawList = cbRec.recipes -- 794
		local parsed = {} -- 795
		local i = 0 -- 796
		do -- 796
			i = 0 -- 797
			while i < #rawList do -- 797
				do -- 797
					local item = asRecord(rawList[i + 1]) -- 798
					if item == nil then -- 798
						goto __continue116 -- 800
					end -- 800
					local id = readStr(item, "id") -- 802
					local name = readStr(item, "name") -- 803
					if id == nil or name == nil then -- 803
						goto __continue116 -- 805
					end -- 805
					local ____id_43 = id -- 808
					local ____name_44 = name -- 809
					local ____temp_45 = readStr(item, "desc") or "" -- 810
					local ____parseReloadEffect_result_46 = parseReloadEffect(item.enhancedEffect) -- 811
					local ____temp_47 = readNumMap(item, "cost") or ({}) -- 812
					local ____readBool_result_42 = readBool(item, "crafted") -- 813
					if ____readBool_result_42 == nil then -- 813
						____readBool_result_42 = false -- 813
					end -- 813
					parsed[#parsed + 1] = { -- 807
						id = ____id_43, -- 808
						name = ____name_44, -- 809
						desc = ____temp_45, -- 810
						enhancedEffect = ____parseReloadEffect_result_46, -- 811
						cost = ____temp_47, -- 812
						crafted = ____readBool_result_42 -- 813
					} -- 813
				end -- 813
				::__continue116:: -- 813
				i = i + 1 -- 797
			end -- 797
		end -- 797
		if #parsed > 0 then -- 797
			local ____readBool_result_48 = readBool(cbRec, "active") -- 818
			if ____readBool_result_48 == nil then -- 818
				____readBool_result_48 = false -- 818
			end -- 818
			local ____readBool_result_49 = readBool(cbRec, "firstCraftDone") -- 819
			if ____readBool_result_49 == nil then -- 819
				____readBool_result_49 = false -- 819
			end -- 819
			return { -- 817
				active = ____readBool_result_48, -- 818
				firstCraftDone = ____readBool_result_49, -- 819
				justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 820
				inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or ({}), -- 821
				recipes = parsed, -- 822
				equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 823
			} -- 823
		end -- 823
	end -- 823
	local ____readBool_result_50 = readBool(cbRec, "active") -- 828
	if ____readBool_result_50 == nil then -- 828
		____readBool_result_50 = false -- 828
	end -- 828
	local ____readBool_result_51 = readBool(cbRec, "firstCraftDone") -- 829
	if ____readBool_result_51 == nil then -- 829
		____readBool_result_51 = false -- 829
	end -- 829
	return { -- 827
		active = ____readBool_result_50, -- 828
		firstCraftDone = ____readBool_result_51, -- 829
		justCraftedTimer = readNum(cbRec, "justCraftedTimer") or 0, -- 830
		inventory = readNumMap(cbRec, "inventory") or readNumMap(pRec, "inventory") or readNumMap(runRec, "craftInventory") or ({}), -- 831
		recipes = recipes, -- 832
		equippedWeapon = readStr(cbRec, "equippedWeapon") or readStr(pRec, "equippedWeapon") or "standard_gun" -- 833
	} -- 833
end -- 787
function DualRouteContract.prototype.readLiveArchive(self, p) -- 837
	local pRec = asRecord(p) -- 838
	local runRec = asRecord(p.run) -- 839
	local ____asRecord_53 = asRecord -- 840
	local ____temp_52 -- 840
	if pRec ~= nil then -- 840
		____temp_52 = pRec.archive -- 840
	else -- 840
		____temp_52 = nil -- 840
	end -- 840
	local ____asRecord_53_result_56 = ____asRecord_53(____temp_52) -- 840
	if ____asRecord_53_result_56 == nil then -- 840
		local ____asRecord_55 = asRecord -- 841
		local ____temp_54 -- 841
		if runRec ~= nil then -- 841
			____temp_54 = runRec.archive -- 841
		else -- 841
			____temp_54 = nil -- 841
		end -- 841
		____asRecord_53_result_56 = ____asRecord_55(____temp_54) -- 840
	end -- 840
	local archRec = ____asRecord_53_result_56 -- 840
	local ____readBool_result_57 = readBool(archRec, "childCleared") -- 843
	if ____readBool_result_57 == nil then -- 843
		____readBool_result_57 = readBool(pRec, "childCleared") -- 843
	end -- 843
	local ____readBool_result_57_58 = ____readBool_result_57 -- 843
	if ____readBool_result_57_58 == nil then -- 843
		____readBool_result_57_58 = false -- 843
	end -- 843
	local childCleared = ____readBool_result_57_58 -- 843
	local ____readBool_result_59 = readBool(archRec, "soldierCleared") -- 844
	if ____readBool_result_59 == nil then -- 844
		____readBool_result_59 = readBool(pRec, "soldierCleared") -- 844
	end -- 844
	local ____readBool_result_59_60 = ____readBool_result_59 -- 844
	if ____readBool_result_59_60 == nil then -- 844
		____readBool_result_59_60 = false -- 844
	end -- 844
	local soldierCleared = ____readBool_result_59_60 -- 844
	local ____readBool_result_61 = readBool(archRec, "artifactOwned") -- 845
	if ____readBool_result_61 == nil then -- 845
		____readBool_result_61 = readBool(pRec, "artifactOwned") -- 845
	end -- 845
	local ____readBool_result_61_62 = ____readBool_result_61 -- 845
	if ____readBool_result_61_62 == nil then -- 845
		____readBool_result_61_62 = false -- 845
	end -- 845
	local artifactOwned = ____readBool_result_61_62 -- 845
	local ____temp_64 -- 846
	if archRec ~= nil and archRec.museumPhase ~= nil then -- 846
		____temp_64 = archRec.museumPhase -- 847
	else -- 847
		local ____temp_63 -- 848
		if pRec ~= nil then -- 848
			____temp_63 = pRec.museumPhase -- 848
		else -- 848
			____temp_63 = nil -- 848
		end -- 848
		____temp_64 = ____temp_63 -- 848
	end -- 848
	local rawPhase = ____temp_64 -- 846
	local museumPhase = parseMuseumPhase(rawPhase) -- 849
	local ____readBool_result_65 = readBool(archRec, "museumSeen") -- 850
	if ____readBool_result_65 == nil then -- 850
		____readBool_result_65 = readBool(pRec, "museumSeen") -- 850
	end -- 850
	local ____readBool_result_65_66 = ____readBool_result_65 -- 850
	if ____readBool_result_65_66 == nil then -- 850
		____readBool_result_65_66 = false -- 850
	end -- 850
	local museumSeen = ____readBool_result_65_66 -- 850
	return { -- 852
		childCleared = childCleared, -- 853
		soldierCleared = soldierCleared, -- 854
		artifactOwned = artifactOwned, -- 855
		museumPhase = museumPhase, -- 856
		museumSeen = museumSeen -- 857
	} -- 857
end -- 837
function DualRouteContract.prototype.forwardLiveIntent(self, p, intent) -- 861
	if intent.kind == "craftSubmit" then -- 861
		if self.livePendingCraftRequests[intent.requestId] == true then -- 861
			return false -- 864
		end -- 864
		self.livePendingCraftRequests[intent.requestId] = true -- 866
	end -- 866
	local pRec = asRecord(p) -- 868
	if pRec == nil then -- 868
		return false -- 870
	end -- 870
	local handler = pRec.submitFeIntent -- 872
	if type(handler) == "function" then -- 872
		local result = handler(p, intent) -- 874
		return result ~= false -- 875
	end -- 875
	return false -- 877
end -- 861
function DualRouteContract.prototype.sampleRehearsal(self, p, dt, input, st) -- 882
	local countElapsedTicks = st.countTickOverride ~= nil and st.countTickOverride or p.countTick -- 883
	local countDurationTicks = math.max(1, st.countDurationOverride or GATE_COUNT_END) -- 884
	local countNumber = gateCountAtTick(countElapsedTicks) -- 885
	local countProgress = math.max( -- 886
		0, -- 886
		math.min(1, countElapsedTicks / countDurationTicks) -- 886
	) -- 886
	if p.room.key == "gate" and p.phase == "gate-count" and st.storyRoute == "soldier" then -- 886
		if countElapsedTicks < countDurationTicks then -- 886
			st.gateReunion.active = false -- 891
			st.gateReunion.knockHeard = false -- 892
			st.gateReunion.holding = false -- 893
			st.gateReunion.holdProgress = 0 -- 894
			st.gateHoldArmed = not input.interact.held -- 895
			st.gatePrevInteractHeld = input.interact.held -- 896
		elseif not st.gateReunion.completed then -- 896
			st.gateReunion.active = true -- 898
			st.gateReunion.knockHeard = true -- 899
			if not st.gateHoldArmed and not input.interact.held then -- 899
				st.gateHoldArmed = true -- 901
			end -- 901
			if dt > 0 then -- 901
				if st.gateHoldArmed and input.interact.held then -- 901
					st.gateReunion.holding = true -- 905
					st.gateReunion.holdProgress = math.min(1, st.gateReunion.holdProgress + dt / GATE_REUNION_HOLD_SECONDS) -- 906
					if st.gateReunion.holdProgress >= 1 then -- 906
						st.gateReunion.holdProgress = 1 -- 911
						st.gateReunion.holding = false -- 912
						st.gateReunion.completed = true -- 913
						st.backCarry.handInHand = true -- 914
					end -- 914
				else -- 914
					if st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 914
						local ____st_gateReunion_67, ____releasedAbortCount_68 = st.gateReunion, "releasedAbortCount" -- 914
						____st_gateReunion_67[____releasedAbortCount_68] = ____st_gateReunion_67[____releasedAbortCount_68] + 1 -- 918
					end -- 918
					st.gateReunion.holding = false -- 920
					st.gateReunion.holdProgress = 0 -- 921
				end -- 921
			end -- 921
			st.gatePrevInteractHeld = input.interact.held -- 924
		end -- 924
	end -- 924
	if st.reloadSession.active and dt > 0 then -- 924
		local ____st_reloadSession_69, ____elapsed_70 = st.reloadSession, "elapsed" -- 924
		____st_reloadSession_69[____elapsed_70] = ____st_reloadSession_69[____elapsed_70] + dt -- 930
		if st.reloadSession.invalidFlash > 0 then -- 930
			st.reloadSession.invalidFlash = math.max(0, st.reloadSession.invalidFlash - dt) -- 932
		end -- 932
		if st.reloadSession.elapsed >= st.reloadSession.duration then -- 932
			st.reloadSession.active = false -- 935
			st.reloadSession.elapsed = 0 -- 936
			st.reloadSession.path = {} -- 937
			st.reloadSession.previewEffect = "normal" -- 938
			st.reloadSession.nextEffect = "normal" -- 939
			st.reloadSession.firstTime = false -- 940
			st.timeScaleOverride = nil -- 941
		end -- 941
	end -- 941
	if st.craftBench.justCraftedTimer > 0 and dt > 0 then -- 941
		st.craftBench.justCraftedTimer = math.max(0, st.craftBench.justCraftedTimer - dt) -- 947
	end -- 947
	local timeScale = st.timeScaleOverride ~= nil and math.max(0, st.timeScaleOverride) or (st.reloadSession.active and DEFAULT_SLOW_TIME_SCALE or 1) -- 950
	local visualMode = deriveVisualMode( -- 954
		p.room.key, -- 955
		p.phase, -- 956
		st.storyRoute, -- 957
		st.archive.museumPhase, -- 958
		countProgress, -- 959
		st.gateReunion.completed -- 960
	) -- 960
	return { -- 963
		storyRoute = st.storyRoute, -- 964
		countElapsedTicks = countElapsedTicks, -- 965
		countDurationTicks = countDurationTicks, -- 966
		countNumber = countNumber, -- 967
		countProgress = countProgress, -- 968
		gateReunion = { -- 969
			active = st.gateReunion.active, -- 970
			knockHeard = st.gateReunion.knockHeard, -- 971
			holdProgress = st.gateReunion.holdProgress, -- 972
			holding = st.gateReunion.holding, -- 973
			completed = st.gateReunion.completed, -- 974
			releasedAbortCount = st.gateReunion.releasedAbortCount -- 975
		}, -- 975
		backCarry = {active = st.backCarry.active, handInHand = st.backCarry.handInHand, mounting = st.backCarry.mounting, atBench = st.backCarry.atBench}, -- 977
		timeScale = timeScale, -- 983
		reloadSession = { -- 984
			active = st.reloadSession.active, -- 985
			firstTime = st.reloadSession.firstTime, -- 986
			elapsed = st.reloadSession.elapsed, -- 987
			duration = st.reloadSession.duration, -- 988
			path = __TS__ArraySlice(st.reloadSession.path), -- 989
			previewEffect = st.reloadSession.previewEffect, -- 990
			nextEffect = st.reloadSession.nextEffect, -- 991
			invalidFlash = st.reloadSession.invalidFlash -- 992
		}, -- 992
		craftBench = { -- 994
			active = st.craftBench.active, -- 995
			firstCraftDone = st.craftBench.firstCraftDone, -- 996
			justCraftedTimer = st.craftBench.justCraftedTimer, -- 997
			inventory = cloneRecordNum(st.craftBench.inventory), -- 998
			recipes = cloneRecipes(st.craftBench.recipes), -- 999
			equippedWeapon = st.craftBench.equippedWeapon -- 1000
		}, -- 1000
		archive = { -- 1002
			childCleared = st.archive.childCleared, -- 1003
			soldierCleared = st.archive.soldierCleared, -- 1004
			artifactOwned = st.archive.artifactOwned, -- 1005
			museumPhase = st.archive.museumPhase, -- 1006
			museumSeen = st.archive.museumSeen -- 1007
		}, -- 1007
		assistHintsEnabled = self.assistHintsEnabled, -- 1009
		visualMode = visualMode, -- 1010
		dataSource = "rehearsal", -- 1011
		isRehearsal = true, -- 1012
		rehearsalTag = st.tag -- 1013
	} -- 1013
end -- 882
function DualRouteContract.prototype.applyRehearsalIntent(self, st, intent) -- 1017
	if intent.kind == "gateReunionHold" then -- 1017
		if not st.gateReunion.active or st.gateReunion.completed then -- 1017
			return false -- 1020
		end -- 1020
		if not intent.holding and st.gateReunion.holding and st.gateReunion.holdProgress > 0 and st.gateReunion.holdProgress < 1 then -- 1020
			local ____st_gateReunion_71, ____releasedAbortCount_72 = st.gateReunion, "releasedAbortCount" -- 1020
			____st_gateReunion_71[____releasedAbortCount_72] = ____st_gateReunion_71[____releasedAbortCount_72] + 1 -- 1023
			st.gateReunion.holdProgress = 0 -- 1024
		end -- 1024
		st.gateReunion.holding = intent.holding -- 1026
		return true -- 1027
	end -- 1027
	if intent.kind == "reloadOpen" then -- 1027
		self:triggerMockReload(true) -- 1030
		return true -- 1031
	end -- 1031
	if intent.kind == "reloadPathPreview" then -- 1031
		if not st.reloadSession.active then -- 1031
			return false -- 1035
		end -- 1035
		st.reloadSession.path = __TS__ArraySlice(intent.path) -- 1037
		st.reloadSession.previewEffect = deriveRehearsalReloadEffect(intent.path) -- 1038
		return true -- 1039
	end -- 1039
	if intent.kind == "reloadPathCommit" then -- 1039
		if not st.reloadSession.active then -- 1039
			return false -- 1043
		end -- 1043
		if #intent.path < 2 then -- 1043
			st.reloadSession.invalidFlash = 0.35 -- 1046
			st.reloadSession.path = {} -- 1047
			st.reloadSession.previewEffect = "normal" -- 1048
			return false -- 1049
		end -- 1049
		local effect = deriveRehearsalReloadEffect(intent.path) -- 1051
		st.reloadSession.nextEffect = effect -- 1052
		st.reloadSession.previewEffect = effect -- 1053
		st.reloadSession.path = {} -- 1054
		st.reloadSession.active = false -- 1055
		st.reloadSession.elapsed = 0 -- 1056
		st.reloadSession.firstTime = false -- 1057
		st.timeScaleOverride = nil -- 1058
		return true -- 1059
	end -- 1059
	if intent.kind == "reloadCancel" then -- 1059
		st.reloadSession.active = false -- 1062
		st.reloadSession.elapsed = 0 -- 1063
		st.reloadSession.path = {} -- 1064
		st.reloadSession.previewEffect = "normal" -- 1065
		st.timeScaleOverride = nil -- 1066
		return true -- 1067
	end -- 1067
	if intent.kind == "craftSubmit" then -- 1067
		if not st.craftBench.active or st.handledCraftRequestIds[intent.requestId] == true then -- 1067
			return false -- 1071
		end -- 1071
		local target -- 1073
		local i = 0 -- 1074
		do -- 1074
			i = 0 -- 1075
			while i < #st.craftBench.recipes do -- 1075
				if st.craftBench.recipes[i + 1].id == intent.recipeId then -- 1075
					target = st.craftBench.recipes[i + 1] -- 1077
					break -- 1078
				end -- 1078
				i = i + 1 -- 1075
			end -- 1075
		end -- 1075
		if target == nil or target.crafted then -- 1075
			return false -- 1082
		end -- 1082
		for mat in pairs(target.cost) do -- 1084
			if (st.craftBench.inventory[mat] or 0) < target.cost[mat] then -- 1084
				return false -- 1086
			end -- 1086
		end -- 1086
		for mat in pairs(target.cost) do -- 1089
			st.craftBench.inventory[mat] = (st.craftBench.inventory[mat] or 0) - target.cost[mat] -- 1090
		end -- 1090
		st.handledCraftRequestIds[intent.requestId] = true -- 1092
		target.crafted = true -- 1093
		st.craftBench.equippedWeapon = target.id -- 1094
		st.craftBench.justCraftedTimer = st.craftBench.firstCraftDone and 0.45 or 1 -- 1095
		st.craftBench.firstCraftDone = true -- 1096
		return true -- 1097
	end -- 1097
	if intent.kind == "craftEquip" then -- 1097
		st.craftBench.equippedWeapon = intent.weaponId -- 1100
		return true -- 1101
	end -- 1101
	if intent.kind == "craftClose" then -- 1101
		st.craftBench.active = false -- 1104
		st.backCarry.atBench = false -- 1105
		return true -- 1106
	end -- 1106
	if intent.kind == "museumInteract" then -- 1106
		if intent.target == "well_pickup" and st.archive.museumPhase == "well_open" then -- 1106
			st.archive.artifactOwned = true -- 1110
			st.archive.museumPhase = "well_reflect" -- 1111
			return true -- 1112
		end -- 1112
		if intent.target == "lamp_turn" and st.archive.museumPhase == "hall_walk" then -- 1112
			st.archive.museumPhase = "lamp_turn" -- 1115
			return true -- 1116
		end -- 1116
		if intent.target == "return_cabinet" then -- 1116
			st.archive.museumPhase = "done" -- 1119
			st.archive.museumSeen = true -- 1120
			return true -- 1121
		end -- 1121
		return false -- 1123
	end -- 1123
	return false -- 1125
end -- 1017
return ____exports -- 1017