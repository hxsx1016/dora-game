-- [ts]: well_museum.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 29
local Color = ____Dora.Color -- 29
local Rect = ____Dora.Rect -- 29
local Vec2 = ____Dora.Vec2 -- 29
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 38
local CUFF_PALETTE = ____cuff_shots.CUFF_PALETTE -- 39
local drawPatchedCuff = ____cuff_shots.drawPatchedCuff -- 40
local ____theme = require("Script.watch.fe.theme") -- 43
local PALETTE = ____theme.PALETTE -- 44
local drawHairline = ____theme.drawHairline -- 45
local drawSilkVeil = ____theme.drawSilkVeil -- 46
local fillGradQuad = ____theme.fillGradQuad -- 47
local fillHGradRect = ____theme.fillHGradRect -- 48
local fillRadialGlow = ____theme.fillRadialGlow -- 49
local fillVGradRect = ____theme.fillVGradRect -- 50
local toColor = ____theme.toColor -- 52
____exports.WELL_WORLD_X = 34 -- 55
____exports.WELL_INTERACT_REACH = 46 -- 56
____exports.MATCH_CUT_ANCHOR_NX = 0.5 -- 57
____exports.MATCH_CUT_ANCHOR_NY = 0.54 -- 58
____exports.MUSEUM_HALL_WIDTH = 1360 -- 59
____exports.MUSEUM_ENTRY_X = 180 -- 60
____exports.MUSEUM_CASE_X = 600 -- 61
____exports.MUSEUM_LAMP_X = 1140 -- 62
____exports.MUSEUM_WALK_SPEED = 156 -- 63
____exports.MUSEUM_LINE_DAWN = "「小满，外头天亮了。」" -- 64
____exports.MUSEUM_HALL_TITLE = "现代 · 宁村海防抗战纪念展厅" -- 65
____exports.MUSEUM_HALL_SUBTITLE = "山河安然，守望未绝" -- 66
____exports.MUSEUM_TIMINGS = { -- 68
	wellReflectDuration = 3.2, -- 69
	wellPickupAt = 1.1, -- 70
	wellMatchCutStart = 1.9, -- 71
	hallIntroFadeIn = 0.55, -- 72
	hallIntroHold = 3.4, -- 73
	hallIntroFadeOut = 0.85, -- 74
	childEchoDelay = 0.52, -- 75
	lampTurnDuration = 3.8, -- 76
	lampReflectStart = 0.65, -- 77
	lampLineAt = 1.45, -- 78
	lampKnock1At = 3.15, -- 79
	returnCabinetDuration = 2.6, -- 80
	returnKnock2At = 0.42, -- 81
	returnFadeOutAt = 2.2 -- 82
} -- 82
local MUSEUM_AUDIO_ROOT = "assets/audio/museum/" -- 85
____exports.MUSEUM_AUDIO = { -- 86
	wellDripLoop = MUSEUM_AUDIO_ROOT .. "well_drip_loop.wav", -- 87
	artifactPickup = MUSEUM_AUDIO_ROOT .. "artifact_pickup.wav", -- 88
	matchCutTransition = MUSEUM_AUDIO_ROOT .. "match_cut_transition.wav", -- 89
	hallAmbienceLoop = MUSEUM_AUDIO_ROOT .. "hall_ambience_loop.wav", -- 90
	hallFootstep = MUSEUM_AUDIO_ROOT .. "hall_footstep.wav", -- 91
	weaponHolster = MUSEUM_AUDIO_ROOT .. "weapon_holster.wav", -- 92
	childStepsEcho = MUSEUM_AUDIO_ROOT .. "child_steps_echo.wav", -- 93
	lampTurn = MUSEUM_AUDIO_ROOT .. "lamp_turn.wav", -- 94
	knockHallFirst = MUSEUM_AUDIO_ROOT .. "knock_hall_first.wav", -- 95
	knockCabinetSecond = MUSEUM_AUDIO_ROOT .. "knock_cabinet_second.wav", -- 96
	lineDawn = MUSEUM_AUDIO_ROOT .. "line_dawn.wav" -- 97
} -- 97
local LOOP_WELL_DRIP = "fe06_well_drip" -- 100
local LOOP_HALL_AMBIENCE = "fe06_hall_ambience" -- 101
local function clamp(v, lo, hi) -- 157
	return math.max( -- 158
		lo, -- 158
		math.min(hi, v) -- 158
	) -- 158
end -- 157
local function clamp01(v) -- 161
	return clamp(v, 0, 1) -- 162
end -- 161
local function smoothstep(edge0, edge1, x) -- 165
	if edge1 <= edge0 then -- 165
		return x >= edge1 and 1 or 0 -- 167
	end -- 167
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 169
	return t * t * (3 - 2 * t) -- 170
end -- 165
local function drawEllipseRing(draw, cx, cy, rx, ry, fillCol, borderWidth, borderCol, segments) -- 173
	if segments == nil then -- 173
		segments = 28 -- 182
	end -- 182
	if rx <= 0.5 or ry <= 0.5 then -- 182
		return -- 185
	end -- 185
	local pts = {} -- 187
	local step = math.pi * 2 / segments -- 188
	local i = 0 -- 189
	do -- 189
		i = 0 -- 190
		while i < segments do -- 190
			local a = i * step -- 191
			pts[#pts + 1] = Vec2( -- 192
				cx + math.cos(a) * rx, -- 192
				cy + math.sin(a) * ry -- 192
			) -- 192
			i = i + 1 -- 190
		end -- 190
	end -- 190
	draw:drawPolygon(pts, fillCol, borderWidth, borderCol) -- 194
end -- 173
local function drawCircleRing(draw, cx, cy, r, fillCol, borderWidth, borderCol, segments) -- 197
	if segments == nil then -- 197
		segments = 28 -- 205
	end -- 205
	drawEllipseRing( -- 207
		draw, -- 207
		cx, -- 207
		cy, -- 207
		r, -- 207
		r, -- 207
		fillCol, -- 207
		borderWidth, -- 207
		borderCol, -- 207
		segments -- 207
	) -- 207
end -- 197
local function asRecord(v) -- 210
	if v ~= nil and type(v) == "table" then -- 210
		return v -- 212
	end -- 212
	return nil -- 214
end -- 210
local function readNum(rec, key) -- 217
	if rec == nil then -- 217
		return nil -- 219
	end -- 219
	local val = rec[key] -- 221
	return type(val) == "number" and val or nil -- 222
end -- 217
local function readBool(rec, key) -- 225
	if rec == nil then -- 225
		return nil -- 227
	end -- 227
	local val = rec[key] -- 229
	local ____temp_0 -- 230
	if type(val) == "boolean" then -- 230
		____temp_0 = val -- 230
	else -- 230
		____temp_0 = nil -- 230
	end -- 230
	return ____temp_0 -- 230
end -- 225
local function resolveRuntimeContract(injected) -- 233
	if injected ~= nil then -- 233
		return injected -- 235
	end -- 235
	local g = _G -- 237
	local ____temp_1 -- 238
	if g.package ~= nil then -- 238
		____temp_1 = g.package.loaded -- 238
	else -- 238
		____temp_1 = nil -- 238
	end -- 238
	local loaded = ____temp_1 -- 238
	if loaded == nil then -- 238
		return nil -- 240
	end -- 240
	local rawFe = loaded["watch.fe"] -- 242
	if rawFe ~= nil and type(rawFe) == "table" then -- 242
		local c = rawFe.contract -- 244
		if c ~= nil and type(c) == "table" then -- 244
			return c -- 246
		end -- 246
	end -- 246
	return nil -- 249
end -- 233
local function isPrologueIntroBlocking() -- 252
	local g = _G -- 253
	local ____temp_2 -- 254
	if g.package ~= nil then -- 254
		____temp_2 = g.package.loaded -- 254
	else -- 254
		____temp_2 = nil -- 254
	end -- 254
	local loaded = ____temp_2 -- 254
	if loaded == nil then -- 254
		return false -- 256
	end -- 256
	local rawFe = loaded["watch.fe"] -- 258
	if rawFe == nil or type(rawFe) ~= "table" then -- 258
		return false -- 260
	end -- 260
	local prologue = rawFe.prologue -- 262
	if prologue == nil or type(prologue) ~= "table" then -- 262
		return false -- 264
	end -- 264
	local fn = prologue.getSnapshot -- 266
	if type(fn) ~= "function" then -- 266
		return false -- 268
	end -- 268
	local snap = asRecord(fn(prologue)) -- 270
	if readBool(snap, "blocksPlayerControl") == true then -- 270
		return true -- 272
	end -- 272
	local stage = snap ~= nil and type(snap.stage) == "string" and snap.stage or "idle" -- 275
	return stage == "p02_escape" or stage == "p02_hidden" -- 276
end -- 252
local function isActiveMuseumPhase(phase) -- 279
	return phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" -- 280
end -- 279
____exports.WellMuseumPlugin = __TS__Class() -- 286
local WellMuseumPlugin = ____exports.WellMuseumPlugin -- 286
WellMuseumPlugin.name = "WellMuseumPlugin" -- 286
function WellMuseumPlugin.prototype.____constructor(self, contract) -- 349
	self.id = "fe-06-well-museum" -- 287
	self.animTime = 0 -- 290
	self.prevPhase = "locked" -- 291
	self.roomSessionId = 0 -- 292
	self.gateOpen = false -- 295
	self.gateBlockedReason = "locked" -- 296
	self.wellWorldX = ____exports.WELL_WORLD_X -- 297
	self.nearWell = false -- 298
	self.revisitCalmTimer = 0 -- 299
	self.revisitCalmCount = 0 -- 300
	self.reflectElapsed = 0 -- 303
	self.wellAnchorX = 640 -- 304
	self.wellAnchorY = 388.8 -- 305
	self.glassAnchorX = 640 -- 306
	self.glassAnchorY = 388.8 -- 307
	self.enterHallSubmitted = false -- 308
	self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 311
	self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 312
	self.hallFacing = 1 -- 313
	self.hallWalkAnim = 0 -- 314
	self.hallMoving = false -- 315
	self.hallFootstepTimer = 0 -- 316
	self.hallIntroElapsed = 0 -- 317
	self.holstered = false -- 318
	self.childEchoCountdown = -1 -- 319
	self.childEchoPlayed = false -- 320
	self.childEchoVisualT = 0 -- 321
	self.nearLamp = false -- 322
	self.lampElapsed = 0 -- 324
	self.lineDawnShown = false -- 325
	self.knock1Played = false -- 326
	self.knock1VisualT = 0 -- 327
	self.beginReturnSubmitted = false -- 328
	self.returnElapsed = 0 -- 331
	self.knock2Played = false -- 332
	self.knock2VisualT = 0 -- 333
	self.returnCompleteSubmitted = false -- 334
	self.artifactGrantCount = 0 -- 337
	self.resumeRestoreCount = 0 -- 339
	self.lastResumePhase = "locked" -- 340
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 341
	self.lastVisualMode = "pixel" -- 342
	self.lastPaused = false -- 343
	self.wellDripPlaying = false -- 344
	self.hallAmbiencePlaying = false -- 345
	self.liveReflectDoneInMuseumRoom = false -- 346
	self.injectedContract = contract -- 350
end -- 349
function WellMuseumPlugin.prototype.syncRuntimeHook(self) -- 353
	local g = _G -- 354
	local ____temp_3 -- 355
	if g.package ~= nil then -- 355
		____temp_3 = g.package.loaded -- 355
	else -- 355
		____temp_3 = nil -- 355
	end -- 355
	local loaded = ____temp_3 -- 355
	if loaded == nil then -- 355
		return -- 357
	end -- 357
	local rawFe = loaded["watch.fe"] -- 359
	if rawFe ~= nil and type(rawFe) == "table" then -- 359
		local watchFe = rawFe -- 361
		if watchFe.wellMuseum ~= self then -- 361
			watchFe.wellMuseum = self -- 363
		end -- 363
	end -- 363
end -- 353
function WellMuseumPlugin.prototype.queueSimulatedInput(self, sim) -- 369
	self.simInput = {moveX = sim.moveX, interact = sim.interact} -- 370
end -- 369
function WellMuseumPlugin.prototype.exportResumeState(self) -- 377
	return { -- 378
		phase = self.prevPhase, -- 379
		hallWalkX = self.hallWalkX, -- 380
		hallCamX = self.hallCamX, -- 381
		hallFacing = self.hallFacing, -- 382
		holstered = self.holstered, -- 383
		childEchoPlayed = self.childEchoPlayed, -- 384
		reflectElapsed = self.reflectElapsed, -- 385
		lampElapsed = self.lampElapsed, -- 386
		returnElapsed = self.returnElapsed, -- 387
		artifactGrantCount = self.artifactGrantCount -- 388
	} -- 388
end -- 377
function WellMuseumPlugin.prototype.restoreResumeState(self, snap) -- 393
	if snap.phase ~= nil then -- 393
		self.prevPhase = snap.phase -- 395
		self.lastResumePhase = snap.phase -- 396
	end -- 396
	if snap.hallWalkX ~= nil then -- 396
		self.hallWalkX = clamp(snap.hallWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 399
		self.lastResumeWalkX = self.hallWalkX -- 400
	end -- 400
	if snap.hallCamX ~= nil then -- 400
		self.hallCamX = snap.hallCamX -- 403
	else -- 403
		self.hallCamX = self.hallWalkX -- 405
	end -- 405
	if snap.hallFacing ~= nil then -- 405
		self.hallFacing = snap.hallFacing >= 0 and 1 or -1 -- 408
	end -- 408
	if snap.holstered ~= nil then -- 408
		self.holstered = snap.holstered -- 411
	end -- 411
	if snap.childEchoPlayed ~= nil then -- 411
		self.childEchoPlayed = snap.childEchoPlayed -- 414
	end -- 414
	if snap.reflectElapsed ~= nil then -- 414
		self.reflectElapsed = math.max(0, snap.reflectElapsed) -- 417
	end -- 417
	if snap.lampElapsed ~= nil then -- 417
		self.lampElapsed = math.max(0, snap.lampElapsed) -- 420
	end -- 420
	if snap.returnElapsed ~= nil then -- 420
		self.returnElapsed = math.max(0, snap.returnElapsed) -- 423
	end -- 423
	if snap.artifactGrantCount ~= nil then -- 423
		self.artifactGrantCount = math.max(0, snap.artifactGrantCount) -- 426
	end -- 426
	self.savedResume = self:exportResumeState() -- 428
	self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 429
end -- 393
function WellMuseumPlugin.prototype.resetSessionCounters(self) -- 433
	self.artifactGrantCount = 0 -- 434
	self.revisitCalmCount = 0 -- 435
	self.revisitCalmTimer = 0 -- 436
	self.savedResume = nil -- 437
	self.resumeRestoreCount = 0 -- 438
	self.lastResumePhase = "locked" -- 439
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 440
end -- 433
function WellMuseumPlugin.prototype.setHallWalkPosition(self, x, holstered) -- 444
	self.hallWalkX = clamp(x, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 445
	self.hallCamX = self.hallWalkX -- 446
	if holstered ~= nil then -- 446
		self.holstered = holstered -- 448
	elseif self.hallWalkX >= ____exports.MUSEUM_CASE_X - 85 then -- 448
		self.holstered = true -- 450
	end -- 450
	self.savedResume = self:exportResumeState() -- 452
end -- 444
function WellMuseumPlugin.prototype.seekStageTime(self, stage, seconds) -- 456
	local s = math.max(0, seconds) -- 457
	if stage == "well_reflect" then -- 457
		self.reflectElapsed = math.min(____exports.MUSEUM_TIMINGS.wellReflectDuration, s) -- 459
	elseif stage == "lamp_turn" then -- 459
		self.lampElapsed = math.min(____exports.MUSEUM_TIMINGS.lampTurnDuration, s) -- 461
		self.lineDawnShown = self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt -- 462
	elseif stage == "return_cabinet" then -- 462
		self.returnElapsed = math.min(____exports.MUSEUM_TIMINGS.returnCabinetDuration, s) -- 464
	end -- 464
end -- 456
function WellMuseumPlugin.prototype.getDebugState(self) -- 468
	local reflectProg = clamp01(self.reflectElapsed / ____exports.MUSEUM_TIMINGS.wellReflectDuration) -- 469
	local matchStart = ____exports.MUSEUM_TIMINGS.wellMatchCutStart -- 470
	local matchSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.wellReflectDuration - matchStart) -- 471
	local matchProg = self.reflectElapsed <= matchStart and 0 or clamp01((self.reflectElapsed - matchStart) / matchSpan) -- 472
	local lampTurnProg = clamp01(self.lampElapsed / 1.15) -- 475
	local cuffStart = ____exports.MUSEUM_TIMINGS.returnKnock2At -- 476
	local cuffSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.returnFadeOutAt - cuffStart) -- 477
	local cuffProg = self.returnElapsed <= cuffStart and 0 or clamp01((self.returnElapsed - cuffStart) / cuffSpan) -- 478
	local dx = self.glassAnchorX - self.wellAnchorX -- 481
	local dy = self.glassAnchorY - self.wellAnchorY -- 482
	return { -- 483
		gateOpen = self.gateOpen, -- 484
		gateBlockedReason = self.gateBlockedReason, -- 485
		wellWorldX = self.wellWorldX, -- 486
		nearWell = self.nearWell, -- 487
		museumPhase = self.prevPhase, -- 488
		visualMode = self.lastVisualMode, -- 489
		reflectElapsed = self.reflectElapsed, -- 490
		reflectProgress = reflectProg, -- 491
		matchCutProgress = matchProg, -- 492
		wellAnchorX = self.wellAnchorX, -- 493
		wellAnchorY = self.wellAnchorY, -- 494
		glassAnchorX = self.glassAnchorX, -- 495
		glassAnchorY = self.glassAnchorY, -- 496
		matchCutAnchorDeltaPx = math.sqrt(dx * dx + dy * dy), -- 497
		hallWalkX = self.hallWalkX, -- 498
		hallCamX = self.hallCamX, -- 499
		holstered = self.holstered, -- 500
		childEchoPlayed = self.childEchoPlayed, -- 501
		nearLamp = self.nearLamp, -- 502
		lampElapsed = self.lampElapsed, -- 503
		lampTurnProgress = lampTurnProg, -- 504
		lineDawnShown = self.lineDawnShown, -- 505
		knock1Played = self.knock1Played, -- 506
		knock2Played = self.knock2Played, -- 507
		returnElapsed = self.returnElapsed, -- 508
		cuffReusedFromSharedPalette = true, -- 509
		cuffProgress = cuffProg, -- 510
		artifactGrantCount = self.artifactGrantCount, -- 511
		revisitCalmCount = self.revisitCalmCount, -- 512
		resumeRestoreCount = self.resumeRestoreCount, -- 513
		lastResumePhase = self.lastResumePhase, -- 514
		lastResumeWalkX = self.lastResumeWalkX, -- 515
		pausedFrozen = self.lastPaused -- 516
	} -- 516
end -- 468
function WellMuseumPlugin.prototype.onBindPlay(self, p, view) -- 520
	self:syncRuntimeHook() -- 521
	self.animTime = 0 -- 522
	self.revisitCalmTimer = 0 -- 523
	self.childEchoVisualT = 0 -- 524
	self.knock1VisualT = 0 -- 525
	self.knock2VisualT = 0 -- 526
	self.wellDripPlaying = false -- 527
	self.hallAmbiencePlaying = false -- 528
	self.enterHallSubmitted = false -- 529
	self.beginReturnSubmitted = false -- 530
	self.returnCompleteSubmitted = false -- 531
	self.liveReflectDoneInMuseumRoom = false -- 532
	self.simInput = nil -- 533
	local phase = view.archive.museumPhase -- 535
	self.prevPhase = phase -- 536
	self.lastVisualMode = view.visualMode -- 537
	local pRec = asRecord(p) -- 540
	local backendWellX = readNum(pRec, "wellX") -- 541
	self.wellWorldX = backendWellX ~= nil and p.ox + backendWellX or p.ox + ____exports.WELL_WORLD_X -- 542
	self.hallMoving = false -- 543
	if view.archive.childCleared and view.archive.soldierCleared and view.archive.artifactOwned then -- 543
		if self.artifactGrantCount < 1 then -- 543
			self.artifactGrantCount = 1 -- 548
		end -- 548
	elseif not view.archive.artifactOwned then -- 548
		self.artifactGrantCount = 0 -- 551
	end -- 551
	if isActiveMuseumPhase(phase) then -- 551
		local runRec = asRecord(p.run) -- 556
		local ____asRecord_5 = asRecord -- 557
		local ____temp_4 -- 557
		if pRec ~= nil then -- 557
			____temp_4 = pRec.archive -- 557
		else -- 557
			____temp_4 = nil -- 557
		end -- 557
		local ____asRecord_5_result_8 = ____asRecord_5(____temp_4) -- 557
		if ____asRecord_5_result_8 == nil then -- 557
			local ____asRecord_7 = asRecord -- 558
			local ____temp_6 -- 558
			if runRec ~= nil then -- 558
				____temp_6 = runRec.archive -- 558
			else -- 558
				____temp_6 = nil -- 558
			end -- 558
			____asRecord_5_result_8 = ____asRecord_7(____temp_6) -- 557
		end -- 557
		local archRec = ____asRecord_5_result_8 -- 557
		local backendWalkX = readNum(archRec, "museumWalkX") or readNum(pRec, "museumWalkX") -- 559
		local ____readBool_result_9 = readBool(archRec, "museumHolstered") -- 560
		if ____readBool_result_9 == nil then -- 560
			____readBool_result_9 = readBool(pRec, "museumHolstered") -- 560
		end -- 560
		local backendHolstered = ____readBool_result_9 -- 560
		local ____readBool_result_10 = readBool(archRec, "museumChildEchoPlayed") -- 561
		if ____readBool_result_10 == nil then -- 561
			____readBool_result_10 = readBool(pRec, "museumChildEchoPlayed") -- 561
		end -- 561
		local backendChildEcho = ____readBool_result_10 -- 561
		if self.savedResume ~= nil and self.savedResume.phase == phase then -- 561
			self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.savedResume.hallWalkX -- 564
			self.hallCamX = self.hallWalkX -- 565
			self.hallFacing = self.savedResume.hallFacing -- 566
			local ____backendHolstered_11 = backendHolstered -- 567
			if ____backendHolstered_11 == nil then -- 567
				____backendHolstered_11 = self.savedResume.holstered -- 567
			end -- 567
			self.holstered = ____backendHolstered_11 -- 567
			local ____backendChildEcho_12 = backendChildEcho -- 568
			if ____backendChildEcho_12 == nil then -- 568
				____backendChildEcho_12 = self.savedResume.childEchoPlayed -- 568
			end -- 568
			self.childEchoPlayed = ____backendChildEcho_12 -- 568
			self.reflectElapsed = self.savedResume.reflectElapsed -- 569
			self.lampElapsed = self.savedResume.lampElapsed -- 570
			self.returnElapsed = self.savedResume.returnElapsed -- 571
		else -- 571
			self:resetPhaseTimersForEntry(phase, backendWalkX, backendHolstered, backendChildEcho) -- 573
		end -- 573
		self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 575
		self.lastResumePhase = phase -- 576
		self.lastResumeWalkX = self.hallWalkX -- 577
	else -- 577
		self.reflectElapsed = 0 -- 580
		self.lampElapsed = 0 -- 581
		self.returnElapsed = 0 -- 582
		self.hallIntroElapsed = 0 -- 583
		self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 584
		self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 585
		self.hallFacing = 1 -- 586
		self.holstered = false -- 587
		self.childEchoCountdown = -1 -- 588
		self.childEchoPlayed = false -- 589
		self.lineDawnShown = false -- 590
		self.knock1Played = false -- 591
		self.knock2Played = false -- 592
		if phase == "locked" or phase == "well_open" then -- 592
			self.savedResume = nil -- 594
		end -- 594
	end -- 594
end -- 520
function WellMuseumPlugin.prototype.resetPhaseTimersForEntry(self, phase, backendWalkX, backendHolstered, backendChildEcho) -- 599
	if phase == "well_reflect" then -- 599
		self.reflectElapsed = 0 -- 606
		self.enterHallSubmitted = false -- 607
		return -- 608
	end -- 608
	if phase == "hall_walk" then -- 608
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or ____exports.MUSEUM_ENTRY_X -- 611
		self.hallCamX = self.hallWalkX -- 612
		self.hallFacing = 1 -- 613
		self.hallIntroElapsed = backendWalkX ~= nil and backendWalkX > 260 and 5 or 0 -- 614
		local ____backendHolstered_13 = backendHolstered -- 615
		if ____backendHolstered_13 == nil then -- 615
			____backendHolstered_13 = self.hallWalkX >= ____exports.MUSEUM_CASE_X - 85 -- 615
		end -- 615
		self.holstered = ____backendHolstered_13 -- 615
		local ____backendChildEcho_14 = backendChildEcho -- 616
		if ____backendChildEcho_14 == nil then -- 616
			____backendChildEcho_14 = self.hallWalkX >= ____exports.MUSEUM_CASE_X + 120 -- 616
		end -- 616
		self.childEchoPlayed = ____backendChildEcho_14 -- 616
		self.childEchoCountdown = -1 -- 617
		return -- 618
	end -- 618
	if phase == "lamp_turn" then -- 618
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or ____exports.MUSEUM_LAMP_X - 36 -- 621
		self.hallCamX = self.hallWalkX -- 622
		self.hallFacing = 1 -- 623
		self.holstered = true -- 624
		self.childEchoPlayed = true -- 625
		self.lampElapsed = 0 -- 626
		self.lineDawnShown = false -- 627
		self.knock1Played = false -- 628
		self.beginReturnSubmitted = false -- 629
		return -- 630
	end -- 630
	if phase == "return_cabinet" then -- 630
		self.returnElapsed = 0 -- 633
		self.knock2Played = false -- 634
		self.returnCompleteSubmitted = false -- 635
	end -- 635
end -- 599
function WellMuseumPlugin.prototype.evaluateGate(self, p, view) -- 639
	if p.run.trial ~= nil then -- 639
		return {open = false, reason = "trial_mode"} -- 641
	end -- 641
	if p.room.key ~= "prologue" then -- 641
		return {open = false, reason = "not_prologue"} -- 644
	end -- 644
	if p.phase ~= "prologue-wait" and p.phase ~= "prologue-well" then -- 644
		return {open = false, reason = "after_cabinet_window"} -- 647
	end -- 647
	if isPrologueIntroBlocking() then -- 647
		return {open = false, reason = "prologue_intro_active"} -- 650
	end -- 650
	if not view.archive.childCleared or not view.archive.soldierCleared then -- 650
		return {open = false, reason = "requires_both_clear"} -- 654
	end -- 654
	if view.archive.museumPhase == "locked" then -- 654
		return {open = false, reason = "phase_locked"} -- 657
	end -- 657
	return {open = true, reason = "ok"} -- 659
end -- 639
function WellMuseumPlugin.prototype.submitMuseumIntent(self, p, target) -- 662
	local contract = resolveRuntimeContract(self.injectedContract) -- 663
	if contract == nil then -- 663
		return false -- 665
	end -- 665
	local intent = {kind = "museumInteract", target = target} -- 667
	return contract:submitIntent(p, intent) -- 668
end -- 662
function WellMuseumPlugin.prototype.syncLoops(self, ctx, wantWellDrip, dripVolume, wantHallAmbience) -- 671
	if wantWellDrip then -- 671
		ctx.audio:playLoop( -- 673
			LOOP_WELL_DRIP, -- 673
			"water", -- 673
			____exports.MUSEUM_AUDIO.wellDripLoop, -- 673
			dripVolume, -- 673
			ctx.p.ticks -- 673
		) -- 673
		self.wellDripPlaying = true -- 674
	elseif self.wellDripPlaying then -- 674
		ctx.audio:stopLoop(LOOP_WELL_DRIP) -- 676
		self.wellDripPlaying = false -- 677
	end -- 677
	if wantHallAmbience then -- 677
		ctx.audio:playLoop( -- 681
			LOOP_HALL_AMBIENCE, -- 681
			"ambience", -- 681
			____exports.MUSEUM_AUDIO.hallAmbienceLoop, -- 681
			0.34, -- 681
			ctx.p.ticks -- 681
		) -- 681
		self.hallAmbiencePlaying = true -- 682
	elseif self.hallAmbiencePlaying then -- 682
		ctx.audio:stopLoop(LOOP_HALL_AMBIENCE) -- 684
		self.hallAmbiencePlaying = false -- 685
	end -- 685
end -- 671
function WellMuseumPlugin.prototype.update(self, ctx) -- 689
	self:syncRuntimeHook() -- 690
	local p = ctx.p -- 691
	local view = ctx.view -- 692
	local phase = view.archive.museumPhase -- 693
	self.roomSessionId = ctx.events.roomSessionId -- 694
	self.lastVisualMode = view.visualMode -- 695
	self.lastPaused = ctx.paused -- 696
	self.wellAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 699
	self.wellAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 700
	self.glassAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 701
	self.glassAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 702
	local sim = self.simInput -- 705
	self.simInput = nil -- 706
	local interactPressed = ctx.input.interact.pressed or sim ~= nil and sim.interact == true -- 707
	local moveX = sim ~= nil and sim.moveX ~= nil and sim.moveX or ctx.input.moveX -- 708
	if phase ~= self.prevPhase then -- 708
		local wasActive = isActiveMuseumPhase(self.prevPhase) -- 712
		self.prevPhase = phase -- 713
		if isActiveMuseumPhase(phase) then -- 713
			if phase == "well_reflect" then -- 713
				self:resetPhaseTimersForEntry("well_reflect") -- 716
				if view.archive.artifactOwned and self.artifactGrantCount < 1 then -- 716
					self.artifactGrantCount = 1 -- 718
				end -- 718
			elseif phase == "hall_walk" and not wasActive then -- 718
				self:resetPhaseTimersForEntry("hall_walk") -- 721
			elseif phase == "hall_walk" and wasActive then -- 721
				self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 723
				self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 724
				self.hallFacing = 1 -- 725
				self.hallIntroElapsed = 0 -- 726
				self.holstered = false -- 727
				self.childEchoPlayed = false -- 728
				self.childEchoCountdown = -1 -- 729
			elseif phase == "lamp_turn" then -- 729
				self:resetPhaseTimersForEntry("lamp_turn", self.hallWalkX, true, self.childEchoPlayed) -- 731
			elseif phase == "return_cabinet" then -- 731
				self:resetPhaseTimersForEntry("return_cabinet") -- 733
			end -- 733
		elseif phase == "done" then -- 733
			self.savedResume = nil -- 736
		end -- 736
	end -- 736
	local gate = self:evaluateGate(p, view) -- 740
	self.gateOpen = gate.open -- 741
	self.gateBlockedReason = gate.reason -- 742
	self.nearWell = gate.open and math.abs(p.player.x - self.wellWorldX) <= ____exports.WELL_INTERACT_REACH -- 743
	if ctx.paused then -- 743
		return -- 747
	end -- 747
	local wdt = math.max(0, ctx.worldDt) -- 750
	local udt = math.max(0, ctx.uiDt) -- 751
	self.animTime = self.animTime + wdt -- 752
	if self.revisitCalmTimer > 0 then -- 752
		self.revisitCalmTimer = math.max(0, self.revisitCalmTimer - wdt) -- 755
	end -- 755
	if self.childEchoVisualT > 0 then -- 755
		self.childEchoVisualT = math.max(0, self.childEchoVisualT - udt) -- 758
	end -- 758
	if self.knock1VisualT > 0 then -- 758
		self.knock1VisualT = math.max(0, self.knock1VisualT - wdt) -- 761
	end -- 761
	if self.knock2VisualT > 0 then -- 761
		self.knock2VisualT = math.max(0, self.knock2VisualT - wdt) -- 764
	end -- 764
	if view.visualMode ~= "museum" then -- 764
		local wantDrip = gate.open and phase == "well_open" and not view.archive.museumSeen -- 769
		local dist = math.abs(p.player.x - self.wellWorldX) -- 770
		local dripVol = clamp(0.46 - dist * 0.0014, 0.08, 0.46) -- 771
		self:syncLoops(ctx, wantDrip, dripVol, false) -- 772
		if gate.open and self.nearWell and interactPressed then -- 772
			local alreadyAwarded = view.archive.museumSeen or phase == "done" or view.archive.artifactOwned and self.artifactGrantCount >= 1 -- 775
			if phase == "well_open" and not alreadyAwarded then -- 775
				self:submitMuseumIntent(p, "well_pickup") -- 779
			else -- 779
				self.revisitCalmTimer = 1.4 -- 782
				self.revisitCalmCount = self.revisitCalmCount + 1 -- 783
			end -- 783
		end -- 783
		return -- 786
	end -- 786
	local effectivePhase = p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 790
	if effectivePhase == "well_reflect" then -- 790
		local dripVol = clamp( -- 795
			0.44 * (1 - smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, self.reflectElapsed)), -- 795
			0, -- 795
			0.44 -- 795
		) -- 795
		self:syncLoops(ctx, dripVol > 0.03, dripVol, false) -- 796
		if wdt > 0 then -- 796
			self.reflectElapsed = self.reflectElapsed + wdt -- 799
		end -- 799
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 799
			if self.artifactGrantCount < 1 then -- 799
				self.artifactGrantCount = 1 -- 803
			end -- 803
			ctx.audio:playOnce( -- 805
				"fe06:e01:pickup:" .. tostring(self.roomSessionId), -- 806
				"sfx", -- 807
				____exports.MUSEUM_AUDIO.artifactPickup, -- 808
				0.86, -- 809
				"museum:e01:artifact_pickup", -- 810
				p.ticks -- 811
			) -- 811
		end -- 811
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellMatchCutStart then -- 811
			ctx.audio:playOnce( -- 815
				"fe06:e01:matchcut:" .. tostring(self.roomSessionId), -- 816
				"ambience", -- 817
				____exports.MUSEUM_AUDIO.matchCutTransition, -- 818
				0.78, -- 819
				"museum:e01:match_cut", -- 820
				p.ticks -- 821
			) -- 821
		end -- 821
		self.savedResume = self:exportResumeState() -- 824
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellReflectDuration and not self.enterHallSubmitted then -- 824
			self.enterHallSubmitted = true -- 826
			if p.room.key == "museum" then -- 826
				self.liveReflectDoneInMuseumRoom = true -- 828
			end -- 828
			self:submitMuseumIntent(p, "enter_hall") -- 830
			local contract = resolveRuntimeContract(self.injectedContract) -- 831
			if contract ~= nil and contract:isRehearsal() then -- 831
				contract:enterMockMuseum("hall_walk") -- 833
			end -- 833
		end -- 833
		return -- 836
	end -- 836
	if effectivePhase == "hall_walk" then -- 836
		self:syncLoops(ctx, false, 0, true) -- 841
		self.hallIntroElapsed = self.hallIntroElapsed + udt -- 842
		local pRec = asRecord(p) -- 846
		local backendWalkX = readNum(pRec, "museumWalkX") or (p.room.key == "museum" and p.player.x - p.ox or nil) -- 847
		self.hallMoving = false -- 849
		if backendWalkX ~= nil then -- 849
			local targetX = clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 851
			local delta = targetX - self.hallWalkX -- 852
			if math.abs(delta) > 0.25 then -- 852
				self.hallFacing = delta >= 0 and 1 or -1 -- 854
				self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 855
				self.hallMoving = true -- 856
			end -- 856
			self.hallWalkX = targetX -- 858
		elseif udt > 0 and math.abs(moveX) > 0.05 then -- 858
			self.hallFacing = moveX > 0 and 1 or -1 -- 860
			self.hallWalkX = clamp(self.hallWalkX + moveX * ____exports.MUSEUM_WALK_SPEED * udt, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 861
			self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 862
			self.hallMoving = true -- 863
			self.hallFootstepTimer = self.hallFootstepTimer + udt -- 864
			if self.hallFootstepTimer >= 0.46 then -- 864
				self.hallFootstepTimer = 0 -- 866
				ctx.audio:playOnce( -- 867
					(("fe06:e02:step:" .. tostring(self.roomSessionId)) .. ":") .. tostring(math.floor(self.hallWalkAnim * 2)), -- 868
					"sfx", -- 869
					____exports.MUSEUM_AUDIO.hallFootstep, -- 870
					0.46, -- 871
					"museum:e02:footstep", -- 872
					p.ticks -- 873
				) -- 873
			end -- 873
		else -- 873
			self.hallFootstepTimer = math.min(self.hallFootstepTimer, 0.22) -- 877
		end -- 877
		local camFollow = math.min(1, udt * 5.2) -- 881
		self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * camFollow -- 882
		if not self.holstered and self.hallWalkX >= ____exports.MUSEUM_CASE_X - 85 then -- 882
			self.holstered = true -- 886
			ctx.audio:playOnce( -- 887
				"fe06:e02:holster:" .. tostring(self.roomSessionId), -- 888
				"sfx", -- 889
				____exports.MUSEUM_AUDIO.weaponHolster, -- 890
				0.76, -- 891
				"museum:e02:weapon_holster", -- 892
				p.ticks -- 893
			) -- 893
			if not self.childEchoPlayed then -- 893
				self.childEchoCountdown = ____exports.MUSEUM_TIMINGS.childEchoDelay -- 896
			end -- 896
		end -- 896
		if self.childEchoCountdown >= 0 and not self.childEchoPlayed then -- 896
			self.childEchoCountdown = self.childEchoCountdown - udt -- 901
			if self.childEchoCountdown <= 0 then -- 901
				self.childEchoCountdown = -1 -- 903
				self.childEchoPlayed = true -- 904
				self.childEchoVisualT = 2.1 -- 905
				ctx.audio:playOnce( -- 906
					"fe06:e02:child_echo:" .. tostring(self.roomSessionId), -- 907
					"sfx", -- 908
					____exports.MUSEUM_AUDIO.childStepsEcho, -- 909
					0.72, -- 910
					"museum:e02:child_steps_echo", -- 911
					p.ticks -- 912
				) -- 912
			end -- 912
		end -- 912
		self.nearLamp = math.abs(self.hallWalkX - ____exports.MUSEUM_LAMP_X) <= 72 -- 917
		self.savedResume = self:exportResumeState() -- 918
		if self.nearLamp and interactPressed then -- 918
			self:submitMuseumIntent(p, "lamp_turn") -- 921
		end -- 921
		return -- 923
	end -- 923
	if effectivePhase == "lamp_turn" then -- 923
		self:syncLoops(ctx, false, 0, true) -- 928
		if wdt > 0 then -- 928
			self.lampElapsed = self.lampElapsed + wdt -- 930
		end -- 930
		if p.room.key == "museum" then -- 930
			local targetX = clamp(p.player.x - p.ox, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 934
			local delta = targetX - self.hallWalkX -- 935
			self.hallMoving = math.abs(delta) > 0.25 -- 936
			if self.hallMoving then -- 936
				self.hallFacing = delta >= 0 and 1 or -1 -- 938
				self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 939
			end -- 939
			self.hallWalkX = targetX -- 941
			self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * math.min(1, udt * 5.2) -- 942
		end -- 942
		ctx.audio:playOnce( -- 944
			"fe06:e02:lamp_turn:" .. tostring(self.roomSessionId), -- 945
			"sfx", -- 946
			____exports.MUSEUM_AUDIO.lampTurn, -- 947
			0.82, -- 948
			"museum:e02:lamp_turn", -- 949
			p.ticks -- 950
		) -- 950
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 950
			self.lineDawnShown = true -- 953
			ctx.audio:playOnce( -- 954
				"fe06:e02:line_dawn:" .. tostring(self.roomSessionId), -- 955
				"voice", -- 956
				____exports.MUSEUM_AUDIO.lineDawn, -- 957
				0.92, -- 958
				"museum:e02:line_dawn", -- 959
				p.ticks -- 960
			) -- 960
		end -- 960
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampKnock1At and not self.knock1Played then -- 960
			self.knock1Played = true -- 964
			self.knock1VisualT = 0.85 -- 965
			ctx.audio:playOnce( -- 966
				"fe06:e02:knock1:" .. tostring(self.roomSessionId), -- 967
				"sfx", -- 968
				____exports.MUSEUM_AUDIO.knockHallFirst, -- 969
				0.88, -- 970
				"museum:knock:1", -- 971
				p.ticks -- 972
			) -- 972
		end -- 972
		self.savedResume = self:exportResumeState() -- 975
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampTurnDuration and not self.beginReturnSubmitted then -- 975
			self.beginReturnSubmitted = true -- 978
			self:submitMuseumIntent(p, "begin_return_cabinet") -- 979
			local contract = resolveRuntimeContract(self.injectedContract) -- 980
			if contract ~= nil and contract:isRehearsal() then -- 980
				contract:enterMockMuseum("return_cabinet") -- 982
			end -- 982
		end -- 982
		return -- 985
	end -- 985
	if phase == "return_cabinet" then -- 985
		self:syncLoops(ctx, false, 0, false) -- 990
		if wdt > 0 then -- 990
			self.returnElapsed = self.returnElapsed + wdt -- 992
		end -- 992
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnKnock2At and not self.knock2Played then -- 992
			self.knock2Played = true -- 995
			self.knock2VisualT = 0.9 -- 996
			ctx.audio:playOnce( -- 997
				"fe06:e02:knock2:" .. tostring(self.roomSessionId), -- 998
				"sfx", -- 999
				____exports.MUSEUM_AUDIO.knockCabinetSecond, -- 1000
				0.92, -- 1001
				"museum:knock:2", -- 1002
				p.ticks -- 1003
			) -- 1003
		end -- 1003
		self.savedResume = self:exportResumeState() -- 1006
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnCabinetDuration and not self.returnCompleteSubmitted then -- 1006
			self.returnCompleteSubmitted = true -- 1009
			self:submitMuseumIntent(p, "return_cabinet") -- 1010
		end -- 1010
	end -- 1010
end -- 689
function WellMuseumPlugin.prototype.drawBackdrop(self, bgDraw, _bgGlow, _backdropArt, ctx) -- 1015
	if ctx.view.visualMode ~= "museum" then -- 1015
		return false -- 1022
	end -- 1022
	bgDraw:drawRect( -- 1025
		Rect(0, 0, ctx.w, ctx.h), -- 1025
		Color(11, 13, 18, 255) -- 1025
	) -- 1025
	return true -- 1026
end -- 1015
function WellMuseumPlugin.prototype.drawWorld(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1029
	return ctx.view.visualMode == "museum" -- 1035
end -- 1029
function WellMuseumPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1038
	return ctx.view.visualMode == "museum" -- 1044
end -- 1038
function WellMuseumPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 1050
	if not self.gateOpen or ctx.view.visualMode == "museum" then -- 1050
		return -- 1057
	end -- 1057
	local cam = ctx.cam -- 1059
	local wellCx = cam:sx(self.wellWorldX) -- 1060
	local groundY = cam:sy(0, 0) -- 1061
	local phase = ctx.view.archive.museumPhase -- 1062
	local activeLure = phase == "well_open" and not ctx.view.archive.museumSeen -- 1063
	local archW = cam:len(68) -- 1066
	local archH = cam:len(96) -- 1067
	local archX = wellCx - archW * 0.54 -- 1068
	fillVGradRect( -- 1069
		fgDraw, -- 1070
		archX, -- 1071
		groundY, -- 1072
		archW, -- 1073
		archH, -- 1074
		Color(12, 16, 22, 232), -- 1075
		Color(18, 24, 34, 212) -- 1076
	) -- 1076
	fgDraw:drawRect( -- 1079
		Rect(archX - 4, groundY, 6, archH), -- 1079
		Color(48, 54, 62, 240) -- 1079
	) -- 1079
	fgDraw:drawRect( -- 1080
		Rect(archX + archW - 2, groundY, 6, archH), -- 1080
		Color(48, 54, 62, 240) -- 1080
	) -- 1080
	fgDraw:drawRect( -- 1081
		Rect(archX - 6, groundY + archH - 8, archW + 12, 10), -- 1081
		Color(62, 68, 76, 245) -- 1081
	) -- 1081
	local rimW = cam:len(38) -- 1084
	local rimH = cam:len(22) -- 1085
	local rimX = wellCx - rimW * 0.5 -- 1086
	fgDraw:drawRect( -- 1087
		Rect(rimX, groundY, rimW, rimH), -- 1088
		Color(46, 52, 60, 250), -- 1089
		1.2, -- 1090
		Color(102, 110, 120, 215) -- 1091
	) -- 1091
	fgDraw:drawEllipse( -- 1094
		Vec2(wellCx, groundY + rimH), -- 1094
		rimW * 0.52, -- 1094
		cam:len(5.5), -- 1094
		Color(74, 82, 92, 250) -- 1094
	) -- 1094
	fgDraw:drawEllipse( -- 1095
		Vec2(wellCx, groundY + rimH), -- 1095
		rimW * 0.38, -- 1095
		cam:len(3.8), -- 1095
		Color(8, 12, 18, 255) -- 1095
	) -- 1095
	local dripCycle = self.animTime * 0.58 % 1 -- 1098
	local rippleR = cam:len(3 + dripCycle * 11) -- 1099
	local rippleAlpha = math.floor((1 - dripCycle) * (activeLure and 155 or 42) + 0.5) -- 1100
	if activeLure then -- 1100
		local shimmer = 0.65 + 0.35 * math.sin(self.animTime * 2.9) -- 1102
		fgDraw:drawCircle( -- 1104
			Vec2(wellCx, groundY + rimH), -- 1104
			cam:len(2.8), -- 1104
			Color( -- 1104
				236, -- 1104
				244, -- 1104
				252, -- 1104
				math.floor(215 * shimmer + 0.5) -- 1104
			) -- 1104
		) -- 1104
		drawEllipseRing( -- 1105
			fgDraw, -- 1105
			wellCx, -- 1105
			groundY + rimH, -- 1105
			rippleR, -- 1105
			rippleR * 0.36, -- 1105
			Color(0, 0, 0, 0), -- 1105
			1.1, -- 1105
			Color(210, 226, 242, rippleAlpha), -- 1105
			24 -- 1105
		) -- 1105
		fillRadialGlow( -- 1106
			fgGlow, -- 1107
			wellCx, -- 1108
			groundY + rimH + cam:len(8), -- 1109
			cam:len(30), -- 1110
			cam:len(38), -- 1111
			Color( -- 1112
				206, -- 1112
				224, -- 1112
				244, -- 1112
				math.floor(52 * shimmer + 0.5) -- 1112
			), -- 1112
			Color(148, 178, 212, 0), -- 1113
			16 -- 1114
		) -- 1114
		if dripCycle < 0.24 then -- 1114
			local dropK = dripCycle / 0.24 -- 1118
			local dropY = groundY + archH * 0.72 - dropK * (archH * 0.72 - rimH) -- 1119
			fgDraw:drawSegment( -- 1120
				Vec2(wellCx, dropY), -- 1121
				Vec2( -- 1122
					wellCx, -- 1122
					dropY + cam:len(4.5) -- 1122
				), -- 1122
				1.4, -- 1123
				Color(214, 228, 244, 185) -- 1124
			) -- 1124
		end -- 1124
	elseif self.revisitCalmTimer > 0 then -- 1124
		local calmK = 1 - clamp01(self.revisitCalmTimer / 1.4) -- 1129
		local calmR = cam:len(3 + calmK * 10) -- 1130
		drawEllipseRing( -- 1131
			fgDraw, -- 1132
			wellCx, -- 1133
			groundY + rimH, -- 1134
			calmR, -- 1135
			calmR * 0.35, -- 1136
			Color(0, 0, 0, 0), -- 1137
			1, -- 1138
			Color( -- 1139
				148, -- 1139
				160, -- 1139
				172, -- 1139
				math.floor((1 - calmK) * 120 + 0.5) -- 1139
			), -- 1139
			24 -- 1140
		) -- 1140
	end -- 1140
end -- 1050
function WellMuseumPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1150
	local view = ctx.view -- 1157
	local phase = view.archive.museumPhase -- 1158
	if view.visualMode ~= "museum" then -- 1158
		if self.gateOpen and self.nearWell and view.assistHintsEnabled and phase == "well_open" and not view.archive.museumSeen then -- 1158
			local sx = ctx.cam:sx(self.wellWorldX) / ctx.uiScale -- 1163
			local sy = (ctx.cam:sy(0, 0) + ctx.cam:len(54)) / ctx.uiScale -- 1164
			drawSilkVeil( -- 1165
				uiDraw, -- 1165
				uiArt, -- 1165
				"fe06_well_hint_veil", -- 1165
				sx, -- 1165
				sy, -- 1165
				132, -- 1165
				26, -- 1165
				PALETTE.panelBg, -- 1165
				0.82, -- 1165
				1 -- 1165
			) -- 1165
			ctx.texts:put( -- 1166
				"xs", -- 1167
				"[E] 俯身看井", -- 1168
				sx, -- 1169
				sy, -- 1170
				toColor(PALETTE.textBright), -- 1171
				0.5, -- 1172
				0.5, -- 1173
				"Center", -- 1174
				0.6, -- 1175
				0.92 -- 1176
			) -- 1176
		end -- 1176
		return false -- 1179
	end -- 1179
	local w = ctx.uiW -- 1182
	local h = ctx.uiH -- 1183
	local effectivePhase = ctx.p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 1185
	if effectivePhase == "well_reflect" then -- 1185
		self:renderE01WellReflectMatchCut( -- 1190
			uiDraw, -- 1190
			uiInkDraw, -- 1190
			uiArt, -- 1190
			uiGlow, -- 1190
			ctx, -- 1190
			w, -- 1190
			h -- 1190
		) -- 1190
		return true -- 1191
	end -- 1191
	if effectivePhase == "hall_walk" then -- 1191
		self:renderE02MuseumHall( -- 1194
			uiDraw, -- 1194
			uiInkDraw, -- 1194
			uiArt, -- 1194
			uiGlow, -- 1194
			ctx, -- 1194
			w, -- 1194
			h, -- 1194
			0, -- 1194
			false -- 1194
		) -- 1194
		return true -- 1195
	end -- 1195
	if effectivePhase == "lamp_turn" then -- 1195
		local turnProg = smoothstep(0, 1.15, self.lampElapsed) -- 1198
		self:renderE02MuseumHall( -- 1199
			uiDraw, -- 1199
			uiInkDraw, -- 1199
			uiArt, -- 1199
			uiGlow, -- 1199
			ctx, -- 1199
			w, -- 1199
			h, -- 1199
			turnProg, -- 1199
			true -- 1199
		) -- 1199
		return true -- 1200
	end -- 1200
	if effectivePhase == "return_cabinet" then -- 1200
		self:renderE02ReturnCabinet( -- 1203
			uiDraw, -- 1203
			uiInkDraw, -- 1203
			uiArt, -- 1203
			uiGlow, -- 1203
			ctx, -- 1203
			w, -- 1203
			h -- 1203
		) -- 1203
		return true -- 1204
	end -- 1204
	return false -- 1206
end -- 1150
function WellMuseumPlugin.prototype.renderE01WellReflectMatchCut(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1212
	local t = self.reflectElapsed -- 1221
	local ax = self.wellAnchorX -- 1222
	local ay = self.wellAnchorY -- 1223
	local matchK = smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, t) -- 1224
	local wellAlpha = 1 - matchK -- 1225
	fillVGradRect( -- 1228
		uiDraw, -- 1229
		0, -- 1230
		0, -- 1231
		w, -- 1232
		h, -- 1233
		Color( -- 1234
			math.floor(8 + 14 * matchK + 0.5), -- 1235
			math.floor(10 + 16 * matchK + 0.5), -- 1236
			math.floor(15 + 20 * matchK + 0.5), -- 1237
			255 -- 1238
		), -- 1238
		Color( -- 1240
			math.floor(14 + 22 * matchK + 0.5), -- 1241
			math.floor(18 + 26 * matchK + 0.5), -- 1242
			math.floor(26 + 30 * matchK + 0.5), -- 1243
			255 -- 1244
		) -- 1244
	) -- 1244
	if wellAlpha > 0.01 then -- 1244
		local wellR = math.min(w, h) * (0.31 + matchK * 0.24) -- 1250
		uiDraw:drawCircle( -- 1252
			Vec2(ax, ay), -- 1252
			wellR + 36, -- 1252
			Color( -- 1252
				30, -- 1252
				35, -- 1252
				42, -- 1252
				math.floor(240 * wellAlpha + 0.5) -- 1252
			) -- 1252
		) -- 1252
		uiDraw:drawCircle( -- 1253
			Vec2(ax, ay), -- 1253
			wellR + 14, -- 1253
			Color( -- 1253
				20, -- 1253
				24, -- 1253
				30, -- 1253
				math.floor(250 * wellAlpha + 0.5) -- 1253
			) -- 1253
		) -- 1253
		uiDraw:drawCircle( -- 1255
			Vec2(ax, ay), -- 1255
			wellR, -- 1255
			Color( -- 1255
				7, -- 1255
				11, -- 1255
				17, -- 1255
				math.floor(255 * wellAlpha + 0.5) -- 1255
			) -- 1255
		) -- 1255
		local ri = 0 -- 1258
		do -- 1258
			ri = 0 -- 1259
			while ri < 3 do -- 1259
				local cyc = (t * 0.42 + ri * 0.33) % 1 -- 1260
				local r = 20 + cyc * (wellR * 0.85) -- 1261
				local ra = math.floor((1 - cyc) * 90 * wellAlpha + 0.5) -- 1262
				drawCircleRing( -- 1263
					uiInkDraw, -- 1263
					ax, -- 1263
					ay, -- 1263
					r, -- 1263
					Color(0, 0, 0, 0), -- 1263
					1.1, -- 1263
					Color(176, 198, 222, ra), -- 1263
					32 -- 1263
				) -- 1263
				ri = ri + 1 -- 1259
			end -- 1259
		end -- 1259
		local compassSlide = smoothstep(0.15, 0.95, t) -- 1267
		local compX = ax + (1 - compassSlide) * 140 -- 1268
		local compY = ay - (1 - compassSlide) * 90 -- 1269
		local compR = 62 -- 1270
		drawCircleRing( -- 1272
			uiInkDraw, -- 1273
			compX, -- 1274
			compY, -- 1275
			compR + 8, -- 1276
			Color( -- 1277
				98, -- 1277
				78, -- 1277
				48, -- 1277
				math.floor(218 * wellAlpha + 0.5) -- 1277
			), -- 1277
			2, -- 1278
			Color( -- 1279
				186, -- 1279
				154, -- 1279
				102, -- 1279
				math.floor(235 * wellAlpha + 0.5) -- 1279
			), -- 1279
			32 -- 1280
		) -- 1280
		drawCircleRing( -- 1283
			uiInkDraw, -- 1284
			compX, -- 1285
			compY, -- 1286
			compR, -- 1287
			Color( -- 1288
				16, -- 1288
				24, -- 1288
				36, -- 1288
				math.floor(145 * wellAlpha + 0.5) -- 1288
			), -- 1288
			1.2, -- 1289
			Color( -- 1290
				218, -- 1290
				226, -- 1290
				236, -- 1290
				math.floor(180 * wellAlpha + 0.5) -- 1290
			), -- 1290
			32 -- 1291
		) -- 1291
		uiInkDraw:drawSegment( -- 1294
			Vec2(compX, compY + compR - 6), -- 1294
			Vec2(compX, compY + compR - 18), -- 1294
			1.6, -- 1294
			Color( -- 1294
				224, -- 1294
				206, -- 1294
				168, -- 1294
				math.floor(190 * wellAlpha + 0.5) -- 1294
			) -- 1294
		) -- 1294
		uiInkDraw:drawSegment( -- 1295
			Vec2(compX, compY - compR + 6), -- 1295
			Vec2(compX, compY - compR + 18), -- 1295
			1.4, -- 1295
			Color( -- 1295
				168, -- 1295
				174, -- 1295
				182, -- 1295
				math.floor(165 * wellAlpha + 0.5) -- 1295
			) -- 1295
		) -- 1295
		uiInkDraw:drawSegment( -- 1296
			Vec2(compX - compR + 6, compY), -- 1296
			Vec2(compX - compR + 18, compY), -- 1296
			1.4, -- 1296
			Color( -- 1296
				168, -- 1296
				174, -- 1296
				182, -- 1296
				math.floor(165 * wellAlpha + 0.5) -- 1296
			) -- 1296
		) -- 1296
		uiInkDraw:drawSegment( -- 1297
			Vec2(compX + compR - 6, compY), -- 1297
			Vec2(compX + compR - 18, compY), -- 1297
			1.4, -- 1297
			Color( -- 1297
				168, -- 1297
				174, -- 1297
				182, -- 1297
				math.floor(165 * wellAlpha + 0.5) -- 1297
			) -- 1297
		) -- 1297
		local needleAng = -0.35 + math.sin(t * 2.2) * 0.08 * (1 - matchK) -- 1299
		local nx = math.cos(needleAng) * 34 -- 1300
		local ny = math.sin(needleAng) * 34 -- 1301
		uiInkDraw:drawSegment( -- 1302
			Vec2(compX, compY), -- 1302
			Vec2(compX + nx, compY + ny), -- 1302
			2.2, -- 1302
			Color( -- 1302
				208, -- 1302
				92, -- 1302
				82, -- 1302
				math.floor(215 * wellAlpha + 0.5) -- 1302
			) -- 1302
		) -- 1302
		uiInkDraw:drawSegment( -- 1303
			Vec2(compX, compY), -- 1303
			Vec2(compX - nx * 0.85, compY - ny * 0.85), -- 1303
			1.8, -- 1303
			Color( -- 1303
				214, -- 1303
				222, -- 1303
				232, -- 1303
				math.floor(185 * wellAlpha + 0.5) -- 1303
			) -- 1303
		) -- 1303
		if t >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 1303
			local pickK = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellMatchCutStart, t) -- 1307
			local liftY = ay + pickK * 14 -- 1308
			drawCircleRing( -- 1309
				uiInkDraw, -- 1310
				ax, -- 1311
				liftY, -- 1312
				24 + pickK * 12, -- 1313
				Color(0, 0, 0, 0), -- 1314
				1.6, -- 1315
				Color( -- 1316
					226, -- 1316
					204, -- 1316
					152, -- 1316
					math.floor(215 * (1 - matchK * 0.65) + 0.5) -- 1316
				), -- 1316
				28 -- 1317
			) -- 1317
			local capA = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellPickupAt + 0.35, t) * (1 - matchK) -- 1320
			if capA > 0.03 then -- 1320
				drawSilkVeil( -- 1322
					uiDraw, -- 1322
					uiArt, -- 1322
					"fe06_pickup_veil", -- 1322
					w * 0.5, -- 1322
					96, -- 1322
					300, -- 1322
					34, -- 1322
					PALETTE.inkVoid, -- 1322
					0.78 * capA, -- 1322
					1 -- 1322
				) -- 1322
				ctx.texts:put( -- 1323
					"sm", -- 1324
					"拾起「时间穿梭器」", -- 1325
					w * 0.5, -- 1326
					96, -- 1327
					toColor(PALETTE.amberCore), -- 1328
					0.5, -- 1329
					0.5, -- 1330
					"Center", -- 1331
					1.4, -- 1332
					capA -- 1333
				) -- 1333
			end -- 1333
		end -- 1333
	end -- 1333
	if matchK > 0.01 then -- 1333
		local caseW = 300 -- 1341
		local caseH = 276 -- 1342
		local caseX = self.glassAnchorX - caseW * 0.5 -- 1343
		local caseY = self.glassAnchorY - caseH * 0.54 -- 1344
		uiDraw:drawRect( -- 1346
			Rect(caseX - 80, caseY - 110, caseW + 160, caseH + 220), -- 1346
			Color( -- 1346
				24, -- 1346
				29, -- 1346
				36, -- 1346
				math.floor(190 * matchK + 0.5) -- 1346
			) -- 1346
		) -- 1346
		uiDraw:drawRect( -- 1347
			Rect(caseX, caseY, caseW, caseH), -- 1348
			Color( -- 1349
				18, -- 1349
				23, -- 1349
				30, -- 1349
				math.floor(220 * matchK + 0.5) -- 1349
			), -- 1349
			1.6, -- 1350
			Color( -- 1351
				164, -- 1351
				178, -- 1351
				194, -- 1351
				math.floor(185 * matchK + 0.5) -- 1351
			) -- 1351
		) -- 1351
		fillGradQuad( -- 1354
			uiInkDraw, -- 1355
			self.glassAnchorX - 42, -- 1356
			caseY + caseH - 6, -- 1356
			Color( -- 1356
				224, -- 1356
				236, -- 1356
				248, -- 1356
				math.floor(44 * matchK + 0.5) -- 1356
			), -- 1356
			self.glassAnchorX + 24, -- 1357
			caseY + caseH - 6, -- 1357
			Color( -- 1357
				238, -- 1357
				246, -- 1357
				255, -- 1357
				math.floor(78 * matchK + 0.5) -- 1357
			), -- 1357
			self.glassAnchorX - 18, -- 1358
			caseY + 6, -- 1358
			Color( -- 1358
				224, -- 1358
				236, -- 1358
				248, -- 1358
				math.floor(24 * matchK + 0.5) -- 1358
			), -- 1358
			self.glassAnchorX - 82, -- 1359
			caseY + 6, -- 1359
			Color(224, 236, 248, 0) -- 1359
		) -- 1359
		uiArt:tryPlace( -- 1362
			"prop_compass", -- 1362
			"fe06_match_compass", -- 1362
			self.glassAnchorX, -- 1362
			caseY + 72, -- 1362
			46, -- 1362
			46, -- 1362
			{opacity = matchK * 0.85, layer = 3} -- 1362
		) -- 1362
	end -- 1362
	local flashPeak = math.sin(matchK * math.pi) -- 1369
	local coreR = 8 + flashPeak * 18 -- 1370
	uiInkDraw:drawCircle( -- 1371
		Vec2(ax, ay), -- 1371
		coreR * 0.55, -- 1371
		Color(248, 252, 255, 248) -- 1371
	) -- 1371
	fillRadialGlow( -- 1372
		uiGlow, -- 1373
		ax, -- 1374
		ay, -- 1375
		52 + flashPeak * 145, -- 1376
		46 + flashPeak * 115, -- 1377
		Color( -- 1378
			238, -- 1378
			246, -- 1378
			255, -- 1378
			math.floor(145 + flashPeak * 95 + 0.5) -- 1378
		), -- 1378
		Color(174, 204, 238, 0), -- 1379
		20 -- 1380
	) -- 1380
	if flashPeak > 0.05 then -- 1380
		local rayW = 70 + flashPeak * 260 -- 1384
		fillHGradRect( -- 1385
			uiGlow, -- 1385
			ax - rayW, -- 1385
			ay - 2, -- 1385
			rayW, -- 1385
			4, -- 1385
			Color(224, 238, 252, 0), -- 1385
			Color( -- 1385
				242, -- 1385
				248, -- 1385
				255, -- 1385
				math.floor(160 * flashPeak + 0.5) -- 1385
			) -- 1385
		) -- 1385
		fillHGradRect( -- 1386
			uiGlow, -- 1386
			ax, -- 1386
			ay - 2, -- 1386
			rayW, -- 1386
			4, -- 1386
			Color( -- 1386
				242, -- 1386
				248, -- 1386
				255, -- 1386
				math.floor(160 * flashPeak + 0.5) -- 1386
			), -- 1386
			Color(224, 238, 252, 0) -- 1386
		) -- 1386
	end -- 1386
	self:drawLetterbox( -- 1389
		uiInkDraw, -- 1389
		w, -- 1389
		h, -- 1389
		42, -- 1389
		0.92 -- 1389
	) -- 1389
end -- 1212
function WellMuseumPlugin.prototype.renderE02MuseumHall(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, lampTurnProg, inLampTurn) -- 1395
	local floorY = 148 -- 1406
	local wallTopY = h - 86 -- 1407
	local halfW = w * 0.5 -- 1408
	local camMin = math.min(____exports.MUSEUM_HALL_WIDTH * 0.5, halfW - 40) -- 1409
	local camMax = math.max(____exports.MUSEUM_HALL_WIDTH * 0.5, ____exports.MUSEUM_HALL_WIDTH - halfW + 40) -- 1410
	local camX = clamp(self.hallCamX, camMin, camMax) -- 1411
	local function toScreenX(hx) -- 1412
		return halfW + (hx - camX) -- 1412
	end -- 1412
	fillVGradRect( -- 1415
		uiDraw, -- 1415
		0, -- 1415
		floorY, -- 1415
		w, -- 1415
		h - floorY, -- 1415
		Color(26, 31, 38, 255), -- 1415
		Color(16, 20, 26, 255) -- 1415
	) -- 1415
	uiDraw:drawRect( -- 1417
		Rect(0, wallTopY, w, h - wallTopY), -- 1417
		Color(11, 14, 19, 255) -- 1417
	) -- 1417
	local px = 0 -- 1419
	do -- 1419
		px = 40 -- 1420
		while px <= ____exports.MUSEUM_HALL_WIDTH do -- 1420
			local sx = toScreenX(px) -- 1421
			if sx >= -20 and sx <= w + 20 then -- 1421
				uiDraw:drawSegment( -- 1423
					Vec2(sx, floorY), -- 1423
					Vec2(sx, wallTopY), -- 1423
					1, -- 1423
					Color(38, 45, 54, 130) -- 1423
				) -- 1423
			end -- 1423
			px = px + 140 -- 1420
		end -- 1420
	end -- 1420
	fillVGradRect( -- 1427
		uiDraw, -- 1427
		0, -- 1427
		0, -- 1427
		w, -- 1427
		floorY, -- 1427
		Color(14, 17, 22, 255), -- 1427
		Color(32, 37, 45, 255) -- 1427
	) -- 1427
	uiDraw:drawSegment( -- 1428
		Vec2(0, floorY), -- 1428
		Vec2(w, floorY), -- 1428
		2, -- 1428
		Color(76, 86, 98, 220) -- 1428
	) -- 1428
	uiDraw:drawRect( -- 1429
		Rect(0, floorY, w, 12), -- 1429
		Color(20, 24, 31, 240) -- 1429
	) -- 1429
	local plaqueX = toScreenX(180) -- 1432
	if plaqueX > -240 and plaqueX < w + 240 then -- 1432
		local pw = 290 -- 1434
		local ph = 132 -- 1435
		local py = floorY + 135 -- 1436
		uiDraw:drawRect( -- 1437
			Rect(plaqueX - pw * 0.5, py, pw, ph), -- 1438
			Color(18, 22, 28, 238), -- 1439
			1.2, -- 1440
			Color(118, 128, 140, 170) -- 1441
		) -- 1441
		fillRadialGlow( -- 1443
			uiGlow, -- 1443
			plaqueX, -- 1443
			wallTopY - 8, -- 1443
			150, -- 1443
			120, -- 1443
			Color(224, 232, 240, 42), -- 1443
			Color(180, 196, 214, 0), -- 1443
			14 -- 1443
		) -- 1443
		ctx.texts:put( -- 1444
			"sm", -- 1445
			"海防抗战纪念展厅", -- 1446
			plaqueX, -- 1447
			py + 82, -- 1448
			toColor(PALETTE.textBright), -- 1449
			0.5, -- 1450
			0.5, -- 1451
			"Center", -- 1452
			2, -- 1453
			0.88 -- 1454
		) -- 1454
		ctx.texts:put( -- 1456
			"xs", -- 1457
			"温州宁村 · 守望史迹陈列", -- 1458
			plaqueX, -- 1459
			py + 46, -- 1460
			toColor(PALETTE.textDim), -- 1461
			0.5, -- 1462
			0.5, -- 1463
			"Center", -- 1464
			1, -- 1465
			0.78 -- 1466
		) -- 1466
	end -- 1466
	local caseSx = toScreenX(____exports.MUSEUM_CASE_X) -- 1471
	if caseSx > -260 and caseSx < w + 260 then -- 1471
		local boardOffsets = {-210, 210} -- 1474
		local bi = 0 -- 1475
		do -- 1475
			bi = 0 -- 1476
			while bi < #boardOffsets do -- 1476
				local bx = caseSx + boardOffsets[bi + 1] -- 1477
				uiDraw:drawRect( -- 1478
					Rect(bx - 56, floorY + 112, 112, 154), -- 1478
					Color(20, 24, 30, 235), -- 1478
					1, -- 1478
					Color(88, 98, 110, 155) -- 1478
				) -- 1478
				uiDraw:drawRect( -- 1479
					Rect(bx - 42, floorY + 168, 84, 78), -- 1479
					Color(34, 40, 48, 220) -- 1479
				) -- 1479
				uiDraw:drawSegment( -- 1480
					Vec2(bx - 36, floorY + 146), -- 1480
					Vec2(bx + 36, floorY + 146), -- 1480
					1.6, -- 1480
					Color(138, 146, 156, 140) -- 1480
				) -- 1480
				uiDraw:drawSegment( -- 1481
					Vec2(bx - 28, floorY + 132), -- 1481
					Vec2(bx + 24, floorY + 132), -- 1481
					1.2, -- 1481
					Color(108, 116, 126, 115) -- 1481
				) -- 1481
				bi = bi + 1 -- 1476
			end -- 1476
		end -- 1476
		local pedW = 148 -- 1485
		local pedH = 88 -- 1486
		local glassH = 148 -- 1487
		uiDraw:drawRect( -- 1489
			Rect(caseSx - pedW * 0.5, floorY, pedW, pedH), -- 1490
			Color(22, 26, 33, 252), -- 1491
			1.2, -- 1492
			Color(96, 106, 118, 185) -- 1493
		) -- 1493
		uiDraw:drawRect( -- 1496
			Rect(caseSx - pedW * 0.46, floorY + pedH, pedW * 0.92, glassH), -- 1497
			Color(16, 22, 30, 165), -- 1498
			1.4, -- 1499
			Color(180, 196, 214, 195) -- 1500
		) -- 1500
		uiArt:tryPlace( -- 1503
			"prop_compass", -- 1503
			"fe06_hall_compass", -- 1503
			caseSx, -- 1503
			floorY + pedH + 34, -- 1503
			34, -- 1503
			34, -- 1503
			{opacity = 0.94, layer = 3} -- 1503
		) -- 1503
		uiDraw:drawRect( -- 1507
			Rect(caseSx - 30, floorY + pedH + 6, 60, 12), -- 1507
			Color(214, 212, 204, 190) -- 1507
		) -- 1507
		fillGradQuad( -- 1509
			uiInkDraw, -- 1510
			caseSx - 28, -- 1511
			floorY + pedH + glassH - 4, -- 1511
			Color(230, 240, 252, 42), -- 1511
			caseSx + 12, -- 1512
			floorY + pedH + glassH - 4, -- 1512
			Color(242, 248, 255, 72), -- 1512
			caseSx - 12, -- 1513
			floorY + pedH + 4, -- 1513
			Color(230, 240, 252, 18), -- 1513
			caseSx - 48, -- 1514
			floorY + pedH + 4, -- 1514
			Color(230, 240, 252, 0) -- 1514
		) -- 1514
		fillRadialGlow( -- 1516
			uiGlow, -- 1516
			caseSx, -- 1516
			floorY + pedH + glassH - 12, -- 1516
			86, -- 1516
			128, -- 1516
			Color(224, 236, 250, 56), -- 1516
			Color(168, 192, 220, 0), -- 1516
			16 -- 1516
		) -- 1516
		fillVGradRect( -- 1518
			uiDraw, -- 1518
			caseSx - pedW * 0.45, -- 1518
			floorY - 36, -- 1518
			pedW * 0.9, -- 1518
			36, -- 1518
			Color(168, 186, 206, 0), -- 1518
			Color(168, 186, 206, 28) -- 1518
		) -- 1518
	end -- 1518
	local lampSx = toScreenX(____exports.MUSEUM_LAMP_X) -- 1522
	local winSx = toScreenX(____exports.MUSEUM_LAMP_X + 108) -- 1523
	local reflectK = inLampTurn and smoothstep(____exports.MUSEUM_TIMINGS.lampReflectStart, 2.35, self.lampElapsed) or 0 -- 1524
	if winSx > -260 and winSx < w + 260 then -- 1524
		local winW = 196 -- 1529
		local winH = 292 -- 1530
		local winX = winSx - winW * 0.5 -- 1531
		local winY = floorY + 46 -- 1532
		fillVGradRect( -- 1534
			uiDraw, -- 1535
			winX, -- 1536
			winY, -- 1537
			winW, -- 1538
			winH, -- 1539
			Color( -- 1540
				math.floor(54 + 46 * reflectK + 0.5), -- 1541
				math.floor(68 + 42 * reflectK + 0.5), -- 1542
				math.floor(92 + 24 * reflectK + 0.5), -- 1543
				255 -- 1544
			), -- 1544
			Color( -- 1546
				math.floor(30 + 28 * reflectK + 0.5), -- 1547
				math.floor(44 + 34 * reflectK + 0.5), -- 1548
				math.floor(70 + 30 * reflectK + 0.5), -- 1549
				255 -- 1550
			) -- 1550
		) -- 1550
		if reflectK > 0.02 then -- 1550
			uiArt:tryPlace( -- 1556
				"bgFar_prologue", -- 1556
				"fe06_window_courtyard", -- 1556
				winSx, -- 1556
				winY + 26, -- 1556
				winW - 8, -- 1556
				winH - 52, -- 1556
				{ -- 1556
					opacity = reflectK * 0.48, -- 1557
					color = Color(238, 218, 186, 255), -- 1558
					layer = 1 -- 1559
				} -- 1559
			) -- 1559
			local cy = winY + 34 -- 1562
			local silA = math.floor(188 * reflectK + 0.5) -- 1563
			uiInkDraw:drawRect( -- 1564
				Rect(winX + 12, cy, 42, 118), -- 1564
				Color(24, 28, 36, silA) -- 1564
			) -- 1564
			uiInkDraw:drawRect( -- 1565
				Rect(winX + winW - 56, cy, 44, 134), -- 1565
				Color(24, 28, 36, silA) -- 1565
			) -- 1565
			uiInkDraw:drawRect( -- 1567
				Rect(winSx - 24, cy + 4, 48, 28), -- 1567
				Color( -- 1567
					46, -- 1567
					44, -- 1567
					42, -- 1567
					math.floor(215 * reflectK + 0.5) -- 1567
				), -- 1567
				1, -- 1567
				Color( -- 1567
					214, -- 1567
					186, -- 1567
					138, -- 1567
					math.floor(170 * reflectK + 0.5) -- 1567
				) -- 1567
			) -- 1567
			uiInkDraw:drawEllipse( -- 1568
				Vec2(winSx, cy + 32), -- 1568
				26, -- 1568
				7, -- 1568
				Color( -- 1568
					218, -- 1568
					194, -- 1568
					148, -- 1568
					math.floor(175 * reflectK + 0.5) -- 1568
				) -- 1568
			) -- 1568
			fillRadialGlow( -- 1570
				uiGlow, -- 1570
				winSx, -- 1570
				winY + winH * 0.48, -- 1570
				116, -- 1570
				128, -- 1570
				Color( -- 1570
					246, -- 1570
					218, -- 1570
					168, -- 1570
					math.floor(92 * reflectK + 0.5) -- 1570
				), -- 1570
				Color(214, 174, 112, 0), -- 1570
				18 -- 1570
			) -- 1570
		end -- 1570
		uiInkDraw:drawRect( -- 1574
			Rect(winX, winY, winW, winH), -- 1574
			Color(0, 0, 0, 0), -- 1574
			3, -- 1574
			Color(68, 76, 88, 245) -- 1574
		) -- 1574
		uiInkDraw:drawSegment( -- 1575
			Vec2(winSx, winY), -- 1575
			Vec2(winSx, winY + winH), -- 1575
			2, -- 1575
			Color(68, 76, 88, 235) -- 1575
		) -- 1575
		uiInkDraw:drawSegment( -- 1576
			Vec2(winX, winY + winH * 0.56), -- 1576
			Vec2(winX + winW, winY + winH * 0.56), -- 1576
			2, -- 1576
			Color(68, 76, 88, 235) -- 1576
		) -- 1576
		local standW = 34 -- 1579
		local standH = 74 -- 1580
		uiDraw:drawRect( -- 1581
			Rect(lampSx - standW * 0.5, floorY, standW, standH), -- 1581
			Color(34, 39, 48, 250), -- 1581
			1.1, -- 1581
			Color(108, 118, 130, 190) -- 1581
		) -- 1581
		local pivotY = floorY + standH + 40 -- 1583
		uiInkDraw:drawSegment( -- 1584
			Vec2(lampSx, floorY + standH), -- 1584
			Vec2(lampSx, pivotY), -- 1584
			3.2, -- 1584
			Color(136, 144, 154, 240) -- 1584
		) -- 1584
		uiInkDraw:drawCircle( -- 1585
			Vec2(lampSx, pivotY), -- 1585
			5.5, -- 1585
			Color(196, 178, 142, 245) -- 1585
		) -- 1585
		local aimDir = -0.65 + lampTurnProg * 1.48 -- 1587
		local headX = lampSx + math.sin(aimDir) * 20 -- 1588
		local headY = pivotY + math.cos(aimDir) * 14 -- 1589
		uiInkDraw:drawSegment( -- 1590
			Vec2(lampSx, pivotY), -- 1590
			Vec2(headX, headY), -- 1590
			6.2, -- 1590
			Color(188, 166, 126, 245) -- 1590
		) -- 1590
		uiInkDraw:drawCircle( -- 1591
			Vec2(headX, headY), -- 1591
			5.2, -- 1591
			Color(248, 234, 198, 248) -- 1591
		) -- 1591
		local beamLen = 132 + lampTurnProg * 76 -- 1594
		local bxEnd = headX + math.sin(aimDir) * beamLen -- 1595
		local byEnd = headY + math.cos(aimDir) * 28 -- 1596
		local perpX = -math.cos(aimDir) * 18 -- 1597
		local perpY = math.sin(aimDir) * 34 -- 1598
		fillGradQuad( -- 1599
			uiGlow, -- 1600
			headX, -- 1601
			headY - 4, -- 1601
			Color( -- 1601
				246, -- 1601
				224, -- 1601
				178, -- 1601
				math.floor(68 + 44 * lampTurnProg + 0.5) -- 1601
			), -- 1601
			headX, -- 1602
			headY + 4, -- 1602
			Color( -- 1602
				246, -- 1602
				224, -- 1602
				178, -- 1602
				math.floor(68 + 44 * lampTurnProg + 0.5) -- 1602
			), -- 1602
			bxEnd + perpX, -- 1603
			byEnd + perpY + 34, -- 1603
			Color(238, 206, 148, 0), -- 1603
			bxEnd - perpX, -- 1604
			byEnd - perpY - 22, -- 1604
			Color(238, 206, 148, 0) -- 1604
		) -- 1604
		fillRadialGlow( -- 1606
			uiGlow, -- 1606
			headX, -- 1606
			headY, -- 1606
			34, -- 1606
			34, -- 1606
			Color(246, 228, 186, 78), -- 1606
			Color(224, 194, 140, 0), -- 1606
			14 -- 1606
		) -- 1606
	end -- 1606
	local playerSx = toScreenX(self.hallWalkX) -- 1610
	local moving = not inLampTurn and (self.hallMoving or math.abs(ctx.input.moveX) > 0.05) -- 1611
	local slot = moving and "soldier_run" or "soldier_idle" -- 1612
	local frame = moving and math.floor(self.hallWalkAnim) or 0 -- 1613
	local charH = 114 -- 1614
	local charW = 54 -- 1615
	uiDraw:drawEllipse( -- 1617
		Vec2(playerSx, floorY + 2), -- 1617
		26, -- 1617
		5.5, -- 1617
		Color(6, 8, 12, 178) -- 1617
	) -- 1617
	uiDraw:drawEllipse( -- 1618
		Vec2(playerSx, floorY - 12), -- 1618
		18, -- 1618
		4, -- 1618
		Color(16, 20, 28, 62) -- 1618
	) -- 1618
	if not uiArt:tryPlace( -- 1618
		slot, -- 1619
		"fe06_museum_zhoushu", -- 1619
		playerSx, -- 1619
		floorY + 2, -- 1619
		charW, -- 1619
		charH, -- 1619
		{facing = self.hallFacing, frame = frame, layer = 3} -- 1619
	) then -- 1619
		uiDraw:drawRect( -- 1625
			Rect(playerSx - 14, floorY + 2, 28, charH * 0.84), -- 1625
			toColor(CUFF_PALETTE.indigoBase) -- 1625
		) -- 1625
		uiDraw:drawCircle( -- 1626
			Vec2(playerSx, floorY + charH * 0.92), -- 1626
			12, -- 1626
			Color(66, 73, 76, 255) -- 1626
		) -- 1626
	end -- 1626
	if self.holstered and not inLampTurn and math.abs(self.hallWalkX - ____exports.MUSEUM_CASE_X) <= 130 then -- 1626
		local subA = clamp01(1 - math.abs(self.hallWalkX - ____exports.MUSEUM_CASE_X) / 145) * 0.86 -- 1631
		ctx.texts:put( -- 1632
			"xs", -- 1633
			"已收起随身器物", -- 1634
			caseSx, -- 1635
			floorY + 286, -- 1636
			toColor(PALETTE.textMid), -- 1637
			0.5, -- 1638
			0.5, -- 1639
			"Center", -- 1640
			0.9, -- 1641
			subA -- 1642
		) -- 1642
	end -- 1642
	if self.childEchoVisualT > 0 then -- 1642
		local echoK = 1 - clamp01(self.childEchoVisualT / 2.1) -- 1648
		local ex = math.min( -- 1649
			w - 110, -- 1649
			toScreenX(____exports.MUSEUM_CASE_X + 310) -- 1649
		) -- 1649
		local ey = floorY + 32 -- 1650
		local ea = math.floor(math.sin(echoK * math.pi) * 165 + 0.5) -- 1651
		drawCircleRing( -- 1652
			uiInkDraw, -- 1652
			ex, -- 1652
			ey, -- 1652
			14 + echoK * 46, -- 1652
			Color(0, 0, 0, 0), -- 1652
			1.1, -- 1652
			Color(224, 214, 194, ea), -- 1652
			28 -- 1652
		) -- 1652
		drawCircleRing( -- 1653
			uiInkDraw, -- 1653
			ex, -- 1653
			ey, -- 1653
			8 + echoK * 28, -- 1653
			Color(0, 0, 0, 0), -- 1653
			0.9, -- 1653
			Color( -- 1653
				224, -- 1653
				214, -- 1653
				194, -- 1653
				math.floor(ea * 0.7 + 0.5) -- 1653
			), -- 1653
			24 -- 1653
		) -- 1653
		ctx.texts:put( -- 1654
			"xs", -- 1655
			"（远方传来轻快的孩童脚步声）", -- 1656
			w * 0.5, -- 1657
			84, -- 1658
			toColor(PALETTE.textMid), -- 1659
			0.5, -- 1660
			0.5, -- 1661
			"Center", -- 1662
			1, -- 1663
			math.sin(echoK * math.pi) * 0.85 -- 1664
		) -- 1664
	end -- 1664
	if not inLampTurn then -- 1664
		local fadeIn = smoothstep(0, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn, self.hallIntroElapsed) -- 1670
		local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold + ____exports.MUSEUM_TIMINGS.hallIntroFadeOut, self.hallIntroElapsed) -- 1671
		local introA = fadeIn * fadeOut -- 1676
		if introA > 0.02 then -- 1676
			drawSilkVeil( -- 1678
				uiDraw, -- 1678
				uiArt, -- 1678
				"fe06_hall_intro_veil", -- 1678
				w * 0.5, -- 1678
				h - 104, -- 1678
				480, -- 1678
				74, -- 1678
				PALETTE.inkVoid, -- 1678
				0.78 * introA, -- 1678
				1 -- 1678
			) -- 1678
			drawHairline( -- 1679
				uiInkDraw, -- 1679
				uiArt, -- 1679
				"fe06_hall_intro_line", -- 1679
				w * 0.5, -- 1679
				h - 106, -- 1679
				260, -- 1679
				PALETTE.silkLine, -- 1679
				0.45 * introA, -- 1679
				false, -- 1679
				4 -- 1679
			) -- 1679
			ctx.texts:put( -- 1680
				"md", -- 1680
				____exports.MUSEUM_HALL_TITLE, -- 1680
				w * 0.5, -- 1680
				h - 88, -- 1680
				toColor(PALETTE.textBright), -- 1680
				0.5, -- 1680
				0.5, -- 1680
				"Center", -- 1680
				1.8, -- 1680
				introA -- 1680
			) -- 1680
			ctx.texts:put( -- 1681
				"xs", -- 1681
				____exports.MUSEUM_HALL_SUBTITLE, -- 1681
				w * 0.5, -- 1681
				h - 122, -- 1681
				toColor(PALETTE.amberCore), -- 1681
				0.5, -- 1681
				0.5, -- 1681
				"Center", -- 1681
				1.2, -- 1681
				introA * 0.88 -- 1681
			) -- 1681
		end -- 1681
		if self.nearLamp and ctx.view.assistHintsEnabled then -- 1681
			drawSilkVeil( -- 1686
				uiDraw, -- 1686
				uiArt, -- 1686
				"fe06_lamp_hint_veil", -- 1686
				lampSx, -- 1686
				floorY + 158, -- 1686
				146, -- 1686
				28, -- 1686
				PALETTE.panelBg, -- 1686
				0.84, -- 1686
				1 -- 1686
			) -- 1686
			ctx.texts:put( -- 1687
				"xs", -- 1687
				"[E] 转动西窗灯", -- 1687
				lampSx, -- 1687
				floorY + 158, -- 1687
				toColor(PALETTE.textBright), -- 1687
				0.5, -- 1687
				0.5, -- 1687
				"Center", -- 1687
				0.6, -- 1687
				0.94 -- 1687
			) -- 1687
		end -- 1687
	end -- 1687
	if inLampTurn and self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1687
		local lineA = smoothstep(____exports.MUSEUM_TIMINGS.lampLineAt, ____exports.MUSEUM_TIMINGS.lampLineAt + 0.45, self.lampElapsed) * (1 - smoothstep(____exports.MUSEUM_TIMINGS.lampTurnDuration - 0.35, ____exports.MUSEUM_TIMINGS.lampTurnDuration, self.lampElapsed)) -- 1693
		if lineA > 0.02 then -- 1693
			drawSilkVeil( -- 1696
				uiDraw, -- 1696
				uiArt, -- 1696
				"fe06_dawn_line_veil", -- 1696
				w * 0.5, -- 1696
				86, -- 1696
				440, -- 1696
				50, -- 1696
				PALETTE.inkVoid, -- 1696
				0.84 * lineA, -- 1696
				1 -- 1696
			) -- 1696
			ctx.texts:put( -- 1697
				"md", -- 1698
				____exports.MUSEUM_LINE_DAWN, -- 1698
				w * 0.5, -- 1700
				86, -- 1701
				toColor(PALETTE.amberCore), -- 1702
				0.5, -- 1703
				0.5, -- 1704
				"Center", -- 1705
				1.6, -- 1706
				lineA -- 1707
			) -- 1707
		end -- 1707
	end -- 1707
	if self.knock1VisualT > 0 then -- 1707
		local k1 = 1 - clamp01(self.knock1VisualT / 0.85) -- 1713
		local k1A = math.floor((1 - k1) * 205 + 0.5) -- 1714
		drawCircleRing( -- 1715
			uiInkDraw, -- 1715
			winSx, -- 1715
			floorY + 148, -- 1715
			12 + k1 * 64, -- 1715
			Color(0, 0, 0, 0), -- 1715
			1.6, -- 1715
			Color(242, 232, 206, k1A), -- 1715
			28 -- 1715
		) -- 1715
		drawCircleRing( -- 1716
			uiInkDraw, -- 1716
			winSx, -- 1716
			floorY + 148, -- 1716
			6 + k1 * 34, -- 1716
			Color(0, 0, 0, 0), -- 1716
			1.1, -- 1716
			Color( -- 1716
				242, -- 1716
				232, -- 1716
				206, -- 1716
				math.floor(k1A * 0.72 + 0.5) -- 1716
			), -- 1716
			24 -- 1716
		) -- 1716
	end -- 1716
	self:drawLetterbox( -- 1719
		uiInkDraw, -- 1719
		w, -- 1719
		h, -- 1719
		38, -- 1719
		0.9 -- 1719
	) -- 1719
end -- 1395
function WellMuseumPlugin.prototype.renderE02ReturnCabinet(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1725
	local t = self.returnElapsed -- 1734
	local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.returnFadeOutAt, ____exports.MUSEUM_TIMINGS.returnCabinetDuration, t) -- 1735
	uiDraw:drawRect( -- 1738
		Rect(0, 0, w, h), -- 1738
		Color( -- 1738
			7, -- 1738
			9, -- 1738
			13, -- 1738
			math.floor(252 * fadeOut + 0.5) -- 1738
		) -- 1738
	) -- 1738
	if t < ____exports.MUSEUM_TIMINGS.returnKnock2At then -- 1738
		self:drawLetterbox( -- 1741
			uiInkDraw, -- 1741
			w, -- 1741
			h, -- 1741
			42, -- 1741
			0.95 * fadeOut -- 1741
		) -- 1741
		return -- 1742
	end -- 1742
	local revealK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.34, t) * fadeOut -- 1746
	local boxW = math.min(w - 140, 820) -- 1747
	local boxH = math.min(h - 190, 390) -- 1748
	local bx = (w - boxW) * 0.5 -- 1749
	local by = (h - boxH) * 0.5 + 10 -- 1750
	fillVGradRect( -- 1753
		uiDraw, -- 1754
		bx, -- 1755
		by, -- 1756
		boxW, -- 1757
		boxH, -- 1758
		Color( -- 1759
			13, -- 1759
			12, -- 1759
			16, -- 1759
			math.floor(248 * revealK + 0.5) -- 1759
		), -- 1759
		Color( -- 1760
			24, -- 1760
			24, -- 1760
			30, -- 1760
			math.floor(248 * revealK + 0.5) -- 1760
		) -- 1760
	) -- 1760
	local cabEdgeX = bx + boxW * 0.58 -- 1763
	uiDraw:drawRect( -- 1764
		Rect(cabEdgeX, by, boxW - (cabEdgeX - bx), boxH), -- 1764
		Color( -- 1764
			42, -- 1764
			31, -- 1764
			24, -- 1764
			math.floor(246 * revealK + 0.5) -- 1764
		) -- 1764
	) -- 1764
	uiDraw:drawSegment( -- 1765
		Vec2(cabEdgeX, by), -- 1765
		Vec2(cabEdgeX, by + boxH), -- 1765
		2.4, -- 1765
		Color( -- 1765
			116, -- 1765
			92, -- 1765
			68, -- 1765
			math.floor(220 * revealK + 0.5) -- 1765
		) -- 1765
	) -- 1765
	local gi = 0 -- 1767
	do -- 1767
		gi = 0 -- 1768
		while gi < 5 do -- 1768
			local gx = cabEdgeX + 26 + gi * 44 -- 1769
			if gx < bx + boxW - 10 then -- 1769
				uiDraw:drawSegment( -- 1771
					Vec2(gx, by + 12), -- 1771
					Vec2(gx, by + boxH - 12), -- 1771
					1, -- 1771
					Color( -- 1771
						28, -- 1771
						20, -- 1771
						15, -- 1771
						math.floor(140 * revealK + 0.5) -- 1771
					) -- 1771
				) -- 1771
			end -- 1771
			gi = gi + 1 -- 1768
		end -- 1768
	end -- 1768
	fillHGradRect( -- 1775
		uiGlow, -- 1776
		cabEdgeX - 58, -- 1777
		by + 24, -- 1778
		58, -- 1779
		boxH - 48, -- 1780
		Color(168, 188, 210, 0), -- 1781
		Color( -- 1782
			186, -- 1782
			206, -- 1782
			226, -- 1782
			math.floor(42 * revealK + 0.5) -- 1782
		) -- 1782
	) -- 1782
	if self.knock2VisualT > 0 then -- 1782
		local k2 = 1 - clamp01(self.knock2VisualT / 0.9) -- 1787
		local k2A = math.floor((1 - k2) * 215 * fadeOut + 0.5) -- 1788
		drawCircleRing( -- 1789
			uiInkDraw, -- 1789
			cabEdgeX + 8, -- 1789
			by + boxH * 0.5, -- 1789
			10 + k2 * 56, -- 1789
			Color(0, 0, 0, 0), -- 1789
			1.6, -- 1789
			Color(232, 220, 196, k2A), -- 1789
			28 -- 1789
		) -- 1789
	end -- 1789
	local extendK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.08, ____exports.MUSEUM_TIMINGS.returnKnock2At + 1.05, t) -- 1793
	local wristX = bx + 115 + extendK * (cabEdgeX - bx - 168) -- 1794
	local wristY = by + boxH * 0.5 -- 1795
	drawPatchedCuff(uiInkDraw, uiGlow, { -- 1796
		wristX = wristX, -- 1797
		wristY = wristY, -- 1798
		angleRad = -0.04 * (1 - extendK), -- 1799
		scale = 1.02, -- 1800
		pose = "reach", -- 1801
		opacity = revealK, -- 1802
		stitchHighlight = 0.48 + 0.22 * extendK, -- 1803
		cuffPullBack = 0.06, -- 1804
		warmth = 0.16 -- 1805
	}) -- 1805
	uiInkDraw:drawRect( -- 1809
		Rect(bx, by, boxW, boxH), -- 1809
		Color(0, 0, 0, 0), -- 1809
		1.2, -- 1809
		toColor( -- 1809
			PALETTE.silkDim, -- 1809
			math.floor(160 * revealK + 0.5) -- 1809
		) -- 1809
	) -- 1809
	local tipA = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.45, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.95, t) * fadeOut -- 1810
	if tipA > 0.03 then -- 1810
		drawSilkVeil( -- 1812
			uiDraw, -- 1812
			uiArt, -- 1812
			"fe06_return_veil", -- 1812
			w * 0.5, -- 1812
			by - 30, -- 1812
			320, -- 1812
			32, -- 1812
			PALETTE.inkVoid, -- 1812
			0.72 * tipA, -- 1812
			1 -- 1812
		) -- 1812
		ctx.texts:put( -- 1813
			"xs", -- 1814
			"两声轻敲落回柜板 · 寻回小满", -- 1815
			w * 0.5, -- 1816
			by - 30, -- 1817
			toColor(PALETTE.textMid), -- 1818
			0.5, -- 1819
			0.5, -- 1820
			"Center", -- 1821
			1.2, -- 1822
			tipA * 0.9 -- 1823
		) -- 1823
	end -- 1823
	self:drawLetterbox( -- 1827
		uiInkDraw, -- 1827
		w, -- 1827
		h, -- 1827
		42, -- 1827
		0.95 * fadeOut -- 1827
	) -- 1827
end -- 1725
function WellMuseumPlugin.prototype.drawLetterbox(self, draw, w, h, barH, opacity) -- 1830
	local a = math.floor(244 * clamp01(opacity) + 0.5) -- 1831
	if a <= 2 then -- 1831
		return -- 1833
	end -- 1833
	draw:drawRect( -- 1835
		Rect(0, 0, w, barH), -- 1835
		Color(6, 8, 12, a) -- 1835
	) -- 1835
	draw:drawRect( -- 1836
		Rect(0, h - barH, w, barH), -- 1836
		Color(6, 8, 12, a) -- 1836
	) -- 1836
end -- 1830
function ____exports.createWellMuseumPlugin(contract) -- 1840
	return __TS__New(____exports.WellMuseumPlugin, contract) -- 1841
end -- 1840
return ____exports -- 1840