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
	return readBool(snap, "blocksPlayerControl") == true -- 271
end -- 252
local function isActiveMuseumPhase(phase) -- 274
	return phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" -- 275
end -- 274
____exports.WellMuseumPlugin = __TS__Class() -- 281
local WellMuseumPlugin = ____exports.WellMuseumPlugin -- 281
WellMuseumPlugin.name = "WellMuseumPlugin" -- 281
function WellMuseumPlugin.prototype.____constructor(self, contract) -- 342
	self.id = "fe-06-well-museum" -- 282
	self.animTime = 0 -- 285
	self.prevPhase = "locked" -- 286
	self.roomSessionId = 0 -- 287
	self.gateOpen = false -- 290
	self.gateBlockedReason = "locked" -- 291
	self.wellWorldX = ____exports.WELL_WORLD_X -- 292
	self.nearWell = false -- 293
	self.revisitCalmTimer = 0 -- 294
	self.revisitCalmCount = 0 -- 295
	self.reflectElapsed = 0 -- 298
	self.wellAnchorX = 640 -- 299
	self.wellAnchorY = 388.8 -- 300
	self.glassAnchorX = 640 -- 301
	self.glassAnchorY = 388.8 -- 302
	self.enterHallSubmitted = false -- 303
	self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 306
	self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 307
	self.hallFacing = 1 -- 308
	self.hallWalkAnim = 0 -- 309
	self.hallFootstepTimer = 0 -- 310
	self.hallIntroElapsed = 0 -- 311
	self.holstered = false -- 312
	self.childEchoCountdown = -1 -- 313
	self.childEchoPlayed = false -- 314
	self.childEchoVisualT = 0 -- 315
	self.nearLamp = false -- 316
	self.lampElapsed = 0 -- 318
	self.lineDawnShown = false -- 319
	self.knock1Played = false -- 320
	self.knock1VisualT = 0 -- 321
	self.beginReturnSubmitted = false -- 322
	self.returnElapsed = 0 -- 325
	self.knock2Played = false -- 326
	self.knock2VisualT = 0 -- 327
	self.returnCompleteSubmitted = false -- 328
	self.artifactGrantCount = 0 -- 331
	self.resumeRestoreCount = 0 -- 333
	self.lastResumePhase = "locked" -- 334
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 335
	self.lastVisualMode = "pixel" -- 336
	self.lastPaused = false -- 337
	self.wellDripPlaying = false -- 338
	self.hallAmbiencePlaying = false -- 339
	self.injectedContract = contract -- 343
end -- 342
function WellMuseumPlugin.prototype.syncRuntimeHook(self) -- 346
	local g = _G -- 347
	local ____temp_3 -- 348
	if g.package ~= nil then -- 348
		____temp_3 = g.package.loaded -- 348
	else -- 348
		____temp_3 = nil -- 348
	end -- 348
	local loaded = ____temp_3 -- 348
	if loaded == nil then -- 348
		return -- 350
	end -- 350
	local rawFe = loaded["watch.fe"] -- 352
	if rawFe ~= nil and type(rawFe) == "table" then -- 352
		local watchFe = rawFe -- 354
		if watchFe.wellMuseum ~= self then -- 354
			watchFe.wellMuseum = self -- 356
		end -- 356
	end -- 356
end -- 346
function WellMuseumPlugin.prototype.queueSimulatedInput(self, sim) -- 362
	self.simInput = {moveX = sim.moveX, interact = sim.interact} -- 363
end -- 362
function WellMuseumPlugin.prototype.exportResumeState(self) -- 370
	return { -- 371
		phase = self.prevPhase, -- 372
		hallWalkX = self.hallWalkX, -- 373
		hallCamX = self.hallCamX, -- 374
		hallFacing = self.hallFacing, -- 375
		holstered = self.holstered, -- 376
		childEchoPlayed = self.childEchoPlayed, -- 377
		reflectElapsed = self.reflectElapsed, -- 378
		lampElapsed = self.lampElapsed, -- 379
		returnElapsed = self.returnElapsed, -- 380
		artifactGrantCount = self.artifactGrantCount -- 381
	} -- 381
end -- 370
function WellMuseumPlugin.prototype.restoreResumeState(self, snap) -- 386
	if snap.phase ~= nil then -- 386
		self.prevPhase = snap.phase -- 388
		self.lastResumePhase = snap.phase -- 389
	end -- 389
	if snap.hallWalkX ~= nil then -- 389
		self.hallWalkX = clamp(snap.hallWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 392
		self.lastResumeWalkX = self.hallWalkX -- 393
	end -- 393
	if snap.hallCamX ~= nil then -- 393
		self.hallCamX = snap.hallCamX -- 396
	else -- 396
		self.hallCamX = self.hallWalkX -- 398
	end -- 398
	if snap.hallFacing ~= nil then -- 398
		self.hallFacing = snap.hallFacing >= 0 and 1 or -1 -- 401
	end -- 401
	if snap.holstered ~= nil then -- 401
		self.holstered = snap.holstered -- 404
	end -- 404
	if snap.childEchoPlayed ~= nil then -- 404
		self.childEchoPlayed = snap.childEchoPlayed -- 407
	end -- 407
	if snap.reflectElapsed ~= nil then -- 407
		self.reflectElapsed = math.max(0, snap.reflectElapsed) -- 410
	end -- 410
	if snap.lampElapsed ~= nil then -- 410
		self.lampElapsed = math.max(0, snap.lampElapsed) -- 413
	end -- 413
	if snap.returnElapsed ~= nil then -- 413
		self.returnElapsed = math.max(0, snap.returnElapsed) -- 416
	end -- 416
	if snap.artifactGrantCount ~= nil then -- 416
		self.artifactGrantCount = math.max(0, snap.artifactGrantCount) -- 419
	end -- 419
	self.savedResume = self:exportResumeState() -- 421
	self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 422
end -- 386
function WellMuseumPlugin.prototype.resetSessionCounters(self) -- 426
	self.artifactGrantCount = 0 -- 427
	self.revisitCalmCount = 0 -- 428
	self.revisitCalmTimer = 0 -- 429
	self.savedResume = nil -- 430
	self.resumeRestoreCount = 0 -- 431
	self.lastResumePhase = "locked" -- 432
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 433
end -- 426
function WellMuseumPlugin.prototype.setHallWalkPosition(self, x, holstered) -- 437
	self.hallWalkX = clamp(x, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 438
	self.hallCamX = self.hallWalkX -- 439
	if holstered ~= nil then -- 439
		self.holstered = holstered -- 441
	elseif self.hallWalkX >= ____exports.MUSEUM_CASE_X - 85 then -- 441
		self.holstered = true -- 443
	end -- 443
	self.savedResume = self:exportResumeState() -- 445
end -- 437
function WellMuseumPlugin.prototype.seekStageTime(self, stage, seconds) -- 449
	local s = math.max(0, seconds) -- 450
	if stage == "well_reflect" then -- 450
		self.reflectElapsed = math.min(____exports.MUSEUM_TIMINGS.wellReflectDuration, s) -- 452
	elseif stage == "lamp_turn" then -- 452
		self.lampElapsed = math.min(____exports.MUSEUM_TIMINGS.lampTurnDuration, s) -- 454
		self.lineDawnShown = self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt -- 455
	elseif stage == "return_cabinet" then -- 455
		self.returnElapsed = math.min(____exports.MUSEUM_TIMINGS.returnCabinetDuration, s) -- 457
	end -- 457
end -- 449
function WellMuseumPlugin.prototype.getDebugState(self) -- 461
	local reflectProg = clamp01(self.reflectElapsed / ____exports.MUSEUM_TIMINGS.wellReflectDuration) -- 462
	local matchStart = ____exports.MUSEUM_TIMINGS.wellMatchCutStart -- 463
	local matchSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.wellReflectDuration - matchStart) -- 464
	local matchProg = self.reflectElapsed <= matchStart and 0 or clamp01((self.reflectElapsed - matchStart) / matchSpan) -- 465
	local lampTurnProg = clamp01(self.lampElapsed / 1.15) -- 468
	local cuffStart = ____exports.MUSEUM_TIMINGS.returnKnock2At -- 469
	local cuffSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.returnFadeOutAt - cuffStart) -- 470
	local cuffProg = self.returnElapsed <= cuffStart and 0 or clamp01((self.returnElapsed - cuffStart) / cuffSpan) -- 471
	local dx = self.glassAnchorX - self.wellAnchorX -- 474
	local dy = self.glassAnchorY - self.wellAnchorY -- 475
	return { -- 476
		gateOpen = self.gateOpen, -- 477
		gateBlockedReason = self.gateBlockedReason, -- 478
		wellWorldX = self.wellWorldX, -- 479
		nearWell = self.nearWell, -- 480
		museumPhase = self.prevPhase, -- 481
		visualMode = self.lastVisualMode, -- 482
		reflectElapsed = self.reflectElapsed, -- 483
		reflectProgress = reflectProg, -- 484
		matchCutProgress = matchProg, -- 485
		wellAnchorX = self.wellAnchorX, -- 486
		wellAnchorY = self.wellAnchorY, -- 487
		glassAnchorX = self.glassAnchorX, -- 488
		glassAnchorY = self.glassAnchorY, -- 489
		matchCutAnchorDeltaPx = math.sqrt(dx * dx + dy * dy), -- 490
		hallWalkX = self.hallWalkX, -- 491
		hallCamX = self.hallCamX, -- 492
		holstered = self.holstered, -- 493
		childEchoPlayed = self.childEchoPlayed, -- 494
		nearLamp = self.nearLamp, -- 495
		lampElapsed = self.lampElapsed, -- 496
		lampTurnProgress = lampTurnProg, -- 497
		lineDawnShown = self.lineDawnShown, -- 498
		knock1Played = self.knock1Played, -- 499
		knock2Played = self.knock2Played, -- 500
		returnElapsed = self.returnElapsed, -- 501
		cuffReusedFromSharedPalette = true, -- 502
		cuffProgress = cuffProg, -- 503
		artifactGrantCount = self.artifactGrantCount, -- 504
		revisitCalmCount = self.revisitCalmCount, -- 505
		resumeRestoreCount = self.resumeRestoreCount, -- 506
		lastResumePhase = self.lastResumePhase, -- 507
		lastResumeWalkX = self.lastResumeWalkX, -- 508
		pausedFrozen = self.lastPaused -- 509
	} -- 509
end -- 461
function WellMuseumPlugin.prototype.onBindPlay(self, p, view) -- 513
	self:syncRuntimeHook() -- 514
	self.animTime = 0 -- 515
	self.revisitCalmTimer = 0 -- 516
	self.childEchoVisualT = 0 -- 517
	self.knock1VisualT = 0 -- 518
	self.knock2VisualT = 0 -- 519
	self.wellDripPlaying = false -- 520
	self.hallAmbiencePlaying = false -- 521
	self.enterHallSubmitted = false -- 522
	self.beginReturnSubmitted = false -- 523
	self.returnCompleteSubmitted = false -- 524
	self.simInput = nil -- 525
	local phase = view.archive.museumPhase -- 527
	self.prevPhase = phase -- 528
	self.lastVisualMode = view.visualMode -- 529
	local pRec = asRecord(p) -- 532
	local backendWellX = readNum(pRec, "wellX") -- 533
	self.wellWorldX = backendWellX ~= nil and backendWellX or p.ox + ____exports.WELL_WORLD_X -- 534
	if view.archive.childCleared and view.archive.soldierCleared and view.archive.artifactOwned then -- 534
		if self.artifactGrantCount < 1 then -- 534
			self.artifactGrantCount = 1 -- 539
		end -- 539
	elseif not view.archive.artifactOwned then -- 539
		self.artifactGrantCount = 0 -- 542
	end -- 542
	if isActiveMuseumPhase(phase) then -- 542
		local runRec = asRecord(p.run) -- 547
		local ____asRecord_5 = asRecord -- 548
		local ____temp_4 -- 548
		if pRec ~= nil then -- 548
			____temp_4 = pRec.archive -- 548
		else -- 548
			____temp_4 = nil -- 548
		end -- 548
		local ____asRecord_5_result_8 = ____asRecord_5(____temp_4) -- 548
		if ____asRecord_5_result_8 == nil then -- 548
			local ____asRecord_7 = asRecord -- 549
			local ____temp_6 -- 549
			if runRec ~= nil then -- 549
				____temp_6 = runRec.archive -- 549
			else -- 549
				____temp_6 = nil -- 549
			end -- 549
			____asRecord_5_result_8 = ____asRecord_7(____temp_6) -- 548
		end -- 548
		local archRec = ____asRecord_5_result_8 -- 548
		local backendWalkX = readNum(archRec, "museumWalkX") or readNum(pRec, "museumWalkX") -- 550
		local ____readBool_result_9 = readBool(archRec, "museumHolstered") -- 551
		if ____readBool_result_9 == nil then -- 551
			____readBool_result_9 = readBool(pRec, "museumHolstered") -- 551
		end -- 551
		local backendHolstered = ____readBool_result_9 -- 551
		local ____readBool_result_10 = readBool(archRec, "museumChildEchoPlayed") -- 552
		if ____readBool_result_10 == nil then -- 552
			____readBool_result_10 = readBool(pRec, "museumChildEchoPlayed") -- 552
		end -- 552
		local backendChildEcho = ____readBool_result_10 -- 552
		if self.savedResume ~= nil and self.savedResume.phase == phase then -- 552
			self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.savedResume.hallWalkX -- 555
			self.hallCamX = self.hallWalkX -- 556
			self.hallFacing = self.savedResume.hallFacing -- 557
			local ____backendHolstered_11 = backendHolstered -- 558
			if ____backendHolstered_11 == nil then -- 558
				____backendHolstered_11 = self.savedResume.holstered -- 558
			end -- 558
			self.holstered = ____backendHolstered_11 -- 558
			local ____backendChildEcho_12 = backendChildEcho -- 559
			if ____backendChildEcho_12 == nil then -- 559
				____backendChildEcho_12 = self.savedResume.childEchoPlayed -- 559
			end -- 559
			self.childEchoPlayed = ____backendChildEcho_12 -- 559
			self.reflectElapsed = self.savedResume.reflectElapsed -- 560
			self.lampElapsed = self.savedResume.lampElapsed -- 561
			self.returnElapsed = self.savedResume.returnElapsed -- 562
		else -- 562
			self:resetPhaseTimersForEntry(phase, backendWalkX, backendHolstered, backendChildEcho) -- 564
		end -- 564
		self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 566
		self.lastResumePhase = phase -- 567
		self.lastResumeWalkX = self.hallWalkX -- 568
	else -- 568
		self.reflectElapsed = 0 -- 571
		self.lampElapsed = 0 -- 572
		self.returnElapsed = 0 -- 573
		self.hallIntroElapsed = 0 -- 574
		self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 575
		self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 576
		self.hallFacing = 1 -- 577
		self.holstered = false -- 578
		self.childEchoCountdown = -1 -- 579
		self.childEchoPlayed = false -- 580
		self.lineDawnShown = false -- 581
		self.knock1Played = false -- 582
		self.knock2Played = false -- 583
		if phase == "locked" or phase == "well_open" then -- 583
			self.savedResume = nil -- 585
		end -- 585
	end -- 585
end -- 513
function WellMuseumPlugin.prototype.resetPhaseTimersForEntry(self, phase, backendWalkX, backendHolstered, backendChildEcho) -- 590
	if phase == "well_reflect" then -- 590
		self.reflectElapsed = 0 -- 597
		self.enterHallSubmitted = false -- 598
		return -- 599
	end -- 599
	if phase == "hall_walk" then -- 599
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or ____exports.MUSEUM_ENTRY_X -- 602
		self.hallCamX = self.hallWalkX -- 603
		self.hallFacing = 1 -- 604
		self.hallIntroElapsed = backendWalkX ~= nil and backendWalkX > 260 and 5 or 0 -- 605
		local ____backendHolstered_13 = backendHolstered -- 606
		if ____backendHolstered_13 == nil then -- 606
			____backendHolstered_13 = self.hallWalkX >= ____exports.MUSEUM_CASE_X - 85 -- 606
		end -- 606
		self.holstered = ____backendHolstered_13 -- 606
		local ____backendChildEcho_14 = backendChildEcho -- 607
		if ____backendChildEcho_14 == nil then -- 607
			____backendChildEcho_14 = self.hallWalkX >= ____exports.MUSEUM_CASE_X + 120 -- 607
		end -- 607
		self.childEchoPlayed = ____backendChildEcho_14 -- 607
		self.childEchoCountdown = -1 -- 608
		return -- 609
	end -- 609
	if phase == "lamp_turn" then -- 609
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or ____exports.MUSEUM_LAMP_X - 36 -- 612
		self.hallCamX = self.hallWalkX -- 613
		self.hallFacing = 1 -- 614
		self.holstered = true -- 615
		self.childEchoPlayed = true -- 616
		self.lampElapsed = 0 -- 617
		self.lineDawnShown = false -- 618
		self.knock1Played = false -- 619
		self.beginReturnSubmitted = false -- 620
		return -- 621
	end -- 621
	if phase == "return_cabinet" then -- 621
		self.returnElapsed = 0 -- 624
		self.knock2Played = false -- 625
		self.returnCompleteSubmitted = false -- 626
	end -- 626
end -- 590
function WellMuseumPlugin.prototype.evaluateGate(self, p, view) -- 630
	if p.run.trial ~= nil then -- 630
		return {open = false, reason = "trial_mode"} -- 632
	end -- 632
	if p.room.key ~= "prologue" then -- 632
		return {open = false, reason = "not_prologue"} -- 635
	end -- 635
	if p.phase ~= "prologue-wait" then -- 635
		return {open = false, reason = "after_cabinet_window"} -- 638
	end -- 638
	if isPrologueIntroBlocking() then -- 638
		return {open = false, reason = "prologue_intro_active"} -- 641
	end -- 641
	if not view.archive.childCleared or not view.archive.soldierCleared then -- 641
		return {open = false, reason = "requires_both_clear"} -- 645
	end -- 645
	if view.archive.museumPhase == "locked" then -- 645
		return {open = false, reason = "phase_locked"} -- 648
	end -- 648
	return {open = true, reason = "ok"} -- 650
end -- 630
function WellMuseumPlugin.prototype.submitMuseumIntent(self, p, target) -- 653
	local contract = resolveRuntimeContract(self.injectedContract) -- 654
	if contract == nil then -- 654
		return false -- 656
	end -- 656
	local intent = {kind = "museumInteract", target = target} -- 658
	return contract:submitIntent(p, intent) -- 659
end -- 653
function WellMuseumPlugin.prototype.syncLoops(self, ctx, wantWellDrip, dripVolume, wantHallAmbience) -- 662
	if wantWellDrip then -- 662
		ctx.audio:playLoop( -- 664
			LOOP_WELL_DRIP, -- 664
			"water", -- 664
			____exports.MUSEUM_AUDIO.wellDripLoop, -- 664
			dripVolume, -- 664
			ctx.p.ticks -- 664
		) -- 664
		self.wellDripPlaying = true -- 665
	elseif self.wellDripPlaying then -- 665
		ctx.audio:stopLoop(LOOP_WELL_DRIP) -- 667
		self.wellDripPlaying = false -- 668
	end -- 668
	if wantHallAmbience then -- 668
		ctx.audio:playLoop( -- 672
			LOOP_HALL_AMBIENCE, -- 672
			"ambience", -- 672
			____exports.MUSEUM_AUDIO.hallAmbienceLoop, -- 672
			0.34, -- 672
			ctx.p.ticks -- 672
		) -- 672
		self.hallAmbiencePlaying = true -- 673
	elseif self.hallAmbiencePlaying then -- 673
		ctx.audio:stopLoop(LOOP_HALL_AMBIENCE) -- 675
		self.hallAmbiencePlaying = false -- 676
	end -- 676
end -- 662
function WellMuseumPlugin.prototype.update(self, ctx) -- 680
	self:syncRuntimeHook() -- 681
	local p = ctx.p -- 682
	local view = ctx.view -- 683
	local phase = view.archive.museumPhase -- 684
	self.roomSessionId = ctx.events.roomSessionId -- 685
	self.lastVisualMode = view.visualMode -- 686
	self.lastPaused = ctx.paused -- 687
	self.wellAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 690
	self.wellAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 691
	self.glassAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 692
	self.glassAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 693
	local sim = self.simInput -- 696
	self.simInput = nil -- 697
	local interactPressed = ctx.input.interact.pressed or sim ~= nil and sim.interact == true -- 698
	local moveX = sim ~= nil and sim.moveX ~= nil and sim.moveX or ctx.input.moveX -- 699
	if phase ~= self.prevPhase then -- 699
		local wasActive = isActiveMuseumPhase(self.prevPhase) -- 703
		self.prevPhase = phase -- 704
		if isActiveMuseumPhase(phase) then -- 704
			if phase == "well_reflect" then -- 704
				self:resetPhaseTimersForEntry("well_reflect") -- 707
				if view.archive.artifactOwned and self.artifactGrantCount < 1 then -- 707
					self.artifactGrantCount = 1 -- 709
				end -- 709
			elseif phase == "hall_walk" and not wasActive then -- 709
				self:resetPhaseTimersForEntry("hall_walk") -- 712
			elseif phase == "hall_walk" and wasActive then -- 712
				self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 714
				self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 715
				self.hallFacing = 1 -- 716
				self.hallIntroElapsed = 0 -- 717
				self.holstered = false -- 718
				self.childEchoPlayed = false -- 719
				self.childEchoCountdown = -1 -- 720
			elseif phase == "lamp_turn" then -- 720
				self:resetPhaseTimersForEntry("lamp_turn", self.hallWalkX, true, self.childEchoPlayed) -- 722
			elseif phase == "return_cabinet" then -- 722
				self:resetPhaseTimersForEntry("return_cabinet") -- 724
			end -- 724
		elseif phase == "done" then -- 724
			self.savedResume = nil -- 727
		end -- 727
	end -- 727
	local gate = self:evaluateGate(p, view) -- 731
	self.gateOpen = gate.open -- 732
	self.gateBlockedReason = gate.reason -- 733
	self.nearWell = gate.open and math.abs(p.player.x - self.wellWorldX) <= ____exports.WELL_INTERACT_REACH -- 734
	if ctx.paused then -- 734
		return -- 738
	end -- 738
	local wdt = math.max(0, ctx.worldDt) -- 741
	local udt = math.max(0, ctx.uiDt) -- 742
	self.animTime = self.animTime + wdt -- 743
	if self.revisitCalmTimer > 0 then -- 743
		self.revisitCalmTimer = math.max(0, self.revisitCalmTimer - wdt) -- 746
	end -- 746
	if self.childEchoVisualT > 0 then -- 746
		self.childEchoVisualT = math.max(0, self.childEchoVisualT - udt) -- 749
	end -- 749
	if self.knock1VisualT > 0 then -- 749
		self.knock1VisualT = math.max(0, self.knock1VisualT - wdt) -- 752
	end -- 752
	if self.knock2VisualT > 0 then -- 752
		self.knock2VisualT = math.max(0, self.knock2VisualT - wdt) -- 755
	end -- 755
	if view.visualMode ~= "museum" then -- 755
		local wantDrip = gate.open and phase == "well_open" and not view.archive.museumSeen -- 760
		local dist = math.abs(p.player.x - self.wellWorldX) -- 761
		local dripVol = clamp(0.46 - dist * 0.0014, 0.08, 0.46) -- 762
		self:syncLoops(ctx, wantDrip, dripVol, false) -- 763
		if gate.open and self.nearWell and interactPressed then -- 763
			local alreadyAwarded = view.archive.museumSeen or phase == "done" or view.archive.artifactOwned and self.artifactGrantCount >= 1 -- 766
			if phase == "well_open" and not alreadyAwarded then -- 766
				self:submitMuseumIntent(p, "well_pickup") -- 770
			else -- 770
				self.revisitCalmTimer = 1.4 -- 773
				self.revisitCalmCount = self.revisitCalmCount + 1 -- 774
			end -- 774
		end -- 774
		return -- 777
	end -- 777
	if phase == "well_reflect" then -- 777
		local dripVol = clamp( -- 782
			0.44 * (1 - smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, self.reflectElapsed)), -- 782
			0, -- 782
			0.44 -- 782
		) -- 782
		self:syncLoops(ctx, dripVol > 0.03, dripVol, false) -- 783
		if wdt > 0 then -- 783
			self.reflectElapsed = self.reflectElapsed + wdt -- 786
		end -- 786
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 786
			if self.artifactGrantCount < 1 then -- 786
				self.artifactGrantCount = 1 -- 790
			end -- 790
			ctx.audio:playOnce( -- 792
				"fe06:e01:pickup:" .. tostring(self.roomSessionId), -- 793
				"sfx", -- 794
				____exports.MUSEUM_AUDIO.artifactPickup, -- 795
				0.86, -- 796
				"museum:e01:artifact_pickup", -- 797
				p.ticks -- 798
			) -- 798
		end -- 798
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellMatchCutStart then -- 798
			ctx.audio:playOnce( -- 802
				"fe06:e01:matchcut:" .. tostring(self.roomSessionId), -- 803
				"ambience", -- 804
				____exports.MUSEUM_AUDIO.matchCutTransition, -- 805
				0.78, -- 806
				"museum:e01:match_cut", -- 807
				p.ticks -- 808
			) -- 808
		end -- 808
		self.savedResume = self:exportResumeState() -- 811
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellReflectDuration and not self.enterHallSubmitted then -- 811
			self.enterHallSubmitted = true -- 813
			self:submitMuseumIntent(p, "enter_hall") -- 814
			local contract = resolveRuntimeContract(self.injectedContract) -- 815
			if contract ~= nil and contract:isRehearsal() then -- 815
				contract:enterMockMuseum("hall_walk") -- 817
			end -- 817
		end -- 817
		return -- 820
	end -- 820
	if phase == "hall_walk" then -- 820
		self:syncLoops(ctx, false, 0, true) -- 825
		self.hallIntroElapsed = self.hallIntroElapsed + udt -- 826
		local pRec = asRecord(p) -- 829
		local backendWalkX = readNum(pRec, "museumWalkX") -- 830
		if backendWalkX ~= nil then -- 830
			local delta = backendWalkX - self.hallWalkX -- 832
			if math.abs(delta) > 0.25 then -- 832
				self.hallFacing = delta >= 0 and 1 or -1 -- 834
				self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 835
			end -- 835
			self.hallWalkX = clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 837
		elseif udt > 0 and math.abs(moveX) > 0.05 then -- 837
			self.hallFacing = moveX > 0 and 1 or -1 -- 839
			self.hallWalkX = clamp(self.hallWalkX + moveX * ____exports.MUSEUM_WALK_SPEED * udt, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 840
			self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 841
			self.hallFootstepTimer = self.hallFootstepTimer + udt -- 842
			if self.hallFootstepTimer >= 0.46 then -- 842
				self.hallFootstepTimer = 0 -- 844
				ctx.audio:playOnce( -- 845
					(("fe06:e02:step:" .. tostring(self.roomSessionId)) .. ":") .. tostring(math.floor(self.hallWalkAnim * 2)), -- 846
					"sfx", -- 847
					____exports.MUSEUM_AUDIO.hallFootstep, -- 848
					0.46, -- 849
					"museum:e02:footstep", -- 850
					p.ticks -- 851
				) -- 851
			end -- 851
		else -- 851
			self.hallFootstepTimer = math.min(self.hallFootstepTimer, 0.22) -- 855
		end -- 855
		local camFollow = math.min(1, udt * 5.2) -- 859
		self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * camFollow -- 860
		if not self.holstered and self.hallWalkX >= ____exports.MUSEUM_CASE_X - 85 then -- 860
			self.holstered = true -- 864
			ctx.audio:playOnce( -- 865
				"fe06:e02:holster:" .. tostring(self.roomSessionId), -- 866
				"sfx", -- 867
				____exports.MUSEUM_AUDIO.weaponHolster, -- 868
				0.76, -- 869
				"museum:e02:weapon_holster", -- 870
				p.ticks -- 871
			) -- 871
			if not self.childEchoPlayed then -- 871
				self.childEchoCountdown = ____exports.MUSEUM_TIMINGS.childEchoDelay -- 874
			end -- 874
		end -- 874
		if self.childEchoCountdown >= 0 and not self.childEchoPlayed then -- 874
			self.childEchoCountdown = self.childEchoCountdown - udt -- 879
			if self.childEchoCountdown <= 0 then -- 879
				self.childEchoCountdown = -1 -- 881
				self.childEchoPlayed = true -- 882
				self.childEchoVisualT = 2.1 -- 883
				ctx.audio:playOnce( -- 884
					"fe06:e02:child_echo:" .. tostring(self.roomSessionId), -- 885
					"sfx", -- 886
					____exports.MUSEUM_AUDIO.childStepsEcho, -- 887
					0.72, -- 888
					"museum:e02:child_steps_echo", -- 889
					p.ticks -- 890
				) -- 890
			end -- 890
		end -- 890
		self.nearLamp = math.abs(self.hallWalkX - ____exports.MUSEUM_LAMP_X) <= 72 -- 895
		self.savedResume = self:exportResumeState() -- 896
		if self.nearLamp and interactPressed then -- 896
			self:submitMuseumIntent(p, "lamp_turn") -- 899
		end -- 899
		return -- 901
	end -- 901
	if phase == "lamp_turn" then -- 901
		self:syncLoops(ctx, false, 0, true) -- 906
		if wdt > 0 then -- 906
			self.lampElapsed = self.lampElapsed + wdt -- 908
		end -- 908
		ctx.audio:playOnce( -- 910
			"fe06:e02:lamp_turn:" .. tostring(self.roomSessionId), -- 911
			"sfx", -- 912
			____exports.MUSEUM_AUDIO.lampTurn, -- 913
			0.82, -- 914
			"museum:e02:lamp_turn", -- 915
			p.ticks -- 916
		) -- 916
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 916
			self.lineDawnShown = true -- 919
			ctx.audio:playOnce( -- 920
				"fe06:e02:line_dawn:" .. tostring(self.roomSessionId), -- 921
				"voice", -- 922
				____exports.MUSEUM_AUDIO.lineDawn, -- 923
				0.92, -- 924
				"museum:e02:line_dawn", -- 925
				p.ticks -- 926
			) -- 926
		end -- 926
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampKnock1At and not self.knock1Played then -- 926
			self.knock1Played = true -- 930
			self.knock1VisualT = 0.85 -- 931
			ctx.audio:playOnce( -- 932
				"fe06:e02:knock1:" .. tostring(self.roomSessionId), -- 933
				"sfx", -- 934
				____exports.MUSEUM_AUDIO.knockHallFirst, -- 935
				0.88, -- 936
				"museum:knock:1", -- 937
				p.ticks -- 938
			) -- 938
		end -- 938
		self.savedResume = self:exportResumeState() -- 941
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampTurnDuration and not self.beginReturnSubmitted then -- 941
			self.beginReturnSubmitted = true -- 944
			self:submitMuseumIntent(p, "begin_return_cabinet") -- 945
			local contract = resolveRuntimeContract(self.injectedContract) -- 946
			if contract ~= nil and contract:isRehearsal() then -- 946
				contract:enterMockMuseum("return_cabinet") -- 948
			end -- 948
		end -- 948
		return -- 951
	end -- 951
	if phase == "return_cabinet" then -- 951
		self:syncLoops(ctx, false, 0, false) -- 956
		if wdt > 0 then -- 956
			self.returnElapsed = self.returnElapsed + wdt -- 958
		end -- 958
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnKnock2At and not self.knock2Played then -- 958
			self.knock2Played = true -- 961
			self.knock2VisualT = 0.9 -- 962
			ctx.audio:playOnce( -- 963
				"fe06:e02:knock2:" .. tostring(self.roomSessionId), -- 964
				"sfx", -- 965
				____exports.MUSEUM_AUDIO.knockCabinetSecond, -- 966
				0.92, -- 967
				"museum:knock:2", -- 968
				p.ticks -- 969
			) -- 969
		end -- 969
		self.savedResume = self:exportResumeState() -- 972
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnCabinetDuration and not self.returnCompleteSubmitted then -- 972
			self.returnCompleteSubmitted = true -- 975
			self:submitMuseumIntent(p, "return_cabinet") -- 976
		end -- 976
	end -- 976
end -- 680
function WellMuseumPlugin.prototype.drawBackdrop(self, bgDraw, _bgGlow, _backdropArt, ctx) -- 981
	if ctx.view.visualMode ~= "museum" then -- 981
		return false -- 988
	end -- 988
	bgDraw:drawRect( -- 991
		Rect(0, 0, ctx.w, ctx.h), -- 991
		Color(11, 13, 18, 255) -- 991
	) -- 991
	return true -- 992
end -- 981
function WellMuseumPlugin.prototype.drawWorld(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 995
	return ctx.view.visualMode == "museum" -- 1001
end -- 995
function WellMuseumPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1004
	return ctx.view.visualMode == "museum" -- 1010
end -- 1004
function WellMuseumPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 1016
	if not self.gateOpen or ctx.view.visualMode == "museum" then -- 1016
		return -- 1023
	end -- 1023
	local cam = ctx.cam -- 1025
	local wellCx = cam:sx(self.wellWorldX) -- 1026
	local groundY = cam:sy(0, 0) -- 1027
	local phase = ctx.view.archive.museumPhase -- 1028
	local activeLure = phase == "well_open" and not ctx.view.archive.museumSeen -- 1029
	local archW = cam:len(68) -- 1032
	local archH = cam:len(96) -- 1033
	local archX = wellCx - archW * 0.54 -- 1034
	fillVGradRect( -- 1035
		fgDraw, -- 1036
		archX, -- 1037
		groundY, -- 1038
		archW, -- 1039
		archH, -- 1040
		Color(12, 16, 22, 232), -- 1041
		Color(18, 24, 34, 212) -- 1042
	) -- 1042
	fgDraw:drawRect( -- 1045
		Rect(archX - 4, groundY, 6, archH), -- 1045
		Color(48, 54, 62, 240) -- 1045
	) -- 1045
	fgDraw:drawRect( -- 1046
		Rect(archX + archW - 2, groundY, 6, archH), -- 1046
		Color(48, 54, 62, 240) -- 1046
	) -- 1046
	fgDraw:drawRect( -- 1047
		Rect(archX - 6, groundY + archH - 8, archW + 12, 10), -- 1047
		Color(62, 68, 76, 245) -- 1047
	) -- 1047
	local rimW = cam:len(38) -- 1050
	local rimH = cam:len(22) -- 1051
	local rimX = wellCx - rimW * 0.5 -- 1052
	fgDraw:drawRect( -- 1053
		Rect(rimX, groundY, rimW, rimH), -- 1054
		Color(46, 52, 60, 250), -- 1055
		1.2, -- 1056
		Color(102, 110, 120, 215) -- 1057
	) -- 1057
	fgDraw:drawEllipse( -- 1060
		Vec2(wellCx, groundY + rimH), -- 1060
		rimW * 0.52, -- 1060
		cam:len(5.5), -- 1060
		Color(74, 82, 92, 250) -- 1060
	) -- 1060
	fgDraw:drawEllipse( -- 1061
		Vec2(wellCx, groundY + rimH), -- 1061
		rimW * 0.38, -- 1061
		cam:len(3.8), -- 1061
		Color(8, 12, 18, 255) -- 1061
	) -- 1061
	local dripCycle = self.animTime * 0.58 % 1 -- 1064
	local rippleR = cam:len(3 + dripCycle * 11) -- 1065
	local rippleAlpha = math.floor((1 - dripCycle) * (activeLure and 155 or 42) + 0.5) -- 1066
	if activeLure then -- 1066
		local shimmer = 0.65 + 0.35 * math.sin(self.animTime * 2.9) -- 1068
		fgDraw:drawCircle( -- 1070
			Vec2(wellCx, groundY + rimH), -- 1070
			cam:len(2.8), -- 1070
			Color( -- 1070
				236, -- 1070
				244, -- 1070
				252, -- 1070
				math.floor(215 * shimmer + 0.5) -- 1070
			) -- 1070
		) -- 1070
		drawEllipseRing( -- 1071
			fgDraw, -- 1071
			wellCx, -- 1071
			groundY + rimH, -- 1071
			rippleR, -- 1071
			rippleR * 0.36, -- 1071
			Color(0, 0, 0, 0), -- 1071
			1.1, -- 1071
			Color(210, 226, 242, rippleAlpha), -- 1071
			24 -- 1071
		) -- 1071
		fillRadialGlow( -- 1072
			fgGlow, -- 1073
			wellCx, -- 1074
			groundY + rimH + cam:len(8), -- 1075
			cam:len(30), -- 1076
			cam:len(38), -- 1077
			Color( -- 1078
				206, -- 1078
				224, -- 1078
				244, -- 1078
				math.floor(52 * shimmer + 0.5) -- 1078
			), -- 1078
			Color(148, 178, 212, 0), -- 1079
			16 -- 1080
		) -- 1080
		if dripCycle < 0.24 then -- 1080
			local dropK = dripCycle / 0.24 -- 1084
			local dropY = groundY + archH * 0.72 - dropK * (archH * 0.72 - rimH) -- 1085
			fgDraw:drawSegment( -- 1086
				Vec2(wellCx, dropY), -- 1087
				Vec2( -- 1088
					wellCx, -- 1088
					dropY + cam:len(4.5) -- 1088
				), -- 1088
				1.4, -- 1089
				Color(214, 228, 244, 185) -- 1090
			) -- 1090
		end -- 1090
	elseif self.revisitCalmTimer > 0 then -- 1090
		local calmK = 1 - clamp01(self.revisitCalmTimer / 1.4) -- 1095
		local calmR = cam:len(3 + calmK * 10) -- 1096
		drawEllipseRing( -- 1097
			fgDraw, -- 1098
			wellCx, -- 1099
			groundY + rimH, -- 1100
			calmR, -- 1101
			calmR * 0.35, -- 1102
			Color(0, 0, 0, 0), -- 1103
			1, -- 1104
			Color( -- 1105
				148, -- 1105
				160, -- 1105
				172, -- 1105
				math.floor((1 - calmK) * 120 + 0.5) -- 1105
			), -- 1105
			24 -- 1106
		) -- 1106
	end -- 1106
end -- 1016
function WellMuseumPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1116
	local view = ctx.view -- 1123
	local phase = view.archive.museumPhase -- 1124
	if view.visualMode ~= "museum" then -- 1124
		if self.gateOpen and self.nearWell and view.assistHintsEnabled and phase == "well_open" and not view.archive.museumSeen then -- 1124
			local sx = ctx.cam:sx(self.wellWorldX) / ctx.uiScale -- 1129
			local sy = (ctx.cam:sy(0, 0) + ctx.cam:len(54)) / ctx.uiScale -- 1130
			drawSilkVeil( -- 1131
				uiDraw, -- 1131
				uiArt, -- 1131
				"fe06_well_hint_veil", -- 1131
				sx, -- 1131
				sy, -- 1131
				132, -- 1131
				26, -- 1131
				PALETTE.panelBg, -- 1131
				0.82, -- 1131
				1 -- 1131
			) -- 1131
			ctx.texts:put( -- 1132
				"xs", -- 1133
				"[E] 俯身看井", -- 1134
				sx, -- 1135
				sy, -- 1136
				toColor(PALETTE.textBright), -- 1137
				0.5, -- 1138
				0.5, -- 1139
				"Center", -- 1140
				0.6, -- 1141
				0.92 -- 1142
			) -- 1142
		end -- 1142
		return false -- 1145
	end -- 1145
	local w = ctx.uiW -- 1148
	local h = ctx.uiH -- 1149
	if phase == "well_reflect" then -- 1149
		self:renderE01WellReflectMatchCut( -- 1152
			uiDraw, -- 1152
			uiInkDraw, -- 1152
			uiArt, -- 1152
			uiGlow, -- 1152
			ctx, -- 1152
			w, -- 1152
			h -- 1152
		) -- 1152
		return true -- 1153
	end -- 1153
	if phase == "hall_walk" then -- 1153
		self:renderE02MuseumHall( -- 1156
			uiDraw, -- 1156
			uiInkDraw, -- 1156
			uiArt, -- 1156
			uiGlow, -- 1156
			ctx, -- 1156
			w, -- 1156
			h, -- 1156
			0, -- 1156
			false -- 1156
		) -- 1156
		return true -- 1157
	end -- 1157
	if phase == "lamp_turn" then -- 1157
		local turnProg = smoothstep(0, 1.15, self.lampElapsed) -- 1160
		self:renderE02MuseumHall( -- 1161
			uiDraw, -- 1161
			uiInkDraw, -- 1161
			uiArt, -- 1161
			uiGlow, -- 1161
			ctx, -- 1161
			w, -- 1161
			h, -- 1161
			turnProg, -- 1161
			true -- 1161
		) -- 1161
		return true -- 1162
	end -- 1162
	if phase == "return_cabinet" then -- 1162
		self:renderE02ReturnCabinet( -- 1165
			uiDraw, -- 1165
			uiInkDraw, -- 1165
			uiArt, -- 1165
			uiGlow, -- 1165
			ctx, -- 1165
			w, -- 1165
			h -- 1165
		) -- 1165
		return true -- 1166
	end -- 1166
	return false -- 1168
end -- 1116
function WellMuseumPlugin.prototype.renderE01WellReflectMatchCut(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1174
	local t = self.reflectElapsed -- 1183
	local ax = self.wellAnchorX -- 1184
	local ay = self.wellAnchorY -- 1185
	local matchK = smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, t) -- 1186
	local wellAlpha = 1 - matchK -- 1187
	fillVGradRect( -- 1190
		uiDraw, -- 1191
		0, -- 1192
		0, -- 1193
		w, -- 1194
		h, -- 1195
		Color( -- 1196
			math.floor(8 + 14 * matchK + 0.5), -- 1197
			math.floor(10 + 16 * matchK + 0.5), -- 1198
			math.floor(15 + 20 * matchK + 0.5), -- 1199
			255 -- 1200
		), -- 1200
		Color( -- 1202
			math.floor(14 + 22 * matchK + 0.5), -- 1203
			math.floor(18 + 26 * matchK + 0.5), -- 1204
			math.floor(26 + 30 * matchK + 0.5), -- 1205
			255 -- 1206
		) -- 1206
	) -- 1206
	if wellAlpha > 0.01 then -- 1206
		local wellR = math.min(w, h) * (0.31 + matchK * 0.24) -- 1212
		uiDraw:drawCircle( -- 1214
			Vec2(ax, ay), -- 1214
			wellR + 36, -- 1214
			Color( -- 1214
				30, -- 1214
				35, -- 1214
				42, -- 1214
				math.floor(240 * wellAlpha + 0.5) -- 1214
			) -- 1214
		) -- 1214
		uiDraw:drawCircle( -- 1215
			Vec2(ax, ay), -- 1215
			wellR + 14, -- 1215
			Color( -- 1215
				20, -- 1215
				24, -- 1215
				30, -- 1215
				math.floor(250 * wellAlpha + 0.5) -- 1215
			) -- 1215
		) -- 1215
		uiDraw:drawCircle( -- 1217
			Vec2(ax, ay), -- 1217
			wellR, -- 1217
			Color( -- 1217
				7, -- 1217
				11, -- 1217
				17, -- 1217
				math.floor(255 * wellAlpha + 0.5) -- 1217
			) -- 1217
		) -- 1217
		local ri = 0 -- 1220
		do -- 1220
			ri = 0 -- 1221
			while ri < 3 do -- 1221
				local cyc = (t * 0.42 + ri * 0.33) % 1 -- 1222
				local r = 20 + cyc * (wellR * 0.85) -- 1223
				local ra = math.floor((1 - cyc) * 90 * wellAlpha + 0.5) -- 1224
				drawCircleRing( -- 1225
					uiInkDraw, -- 1225
					ax, -- 1225
					ay, -- 1225
					r, -- 1225
					Color(0, 0, 0, 0), -- 1225
					1.1, -- 1225
					Color(176, 198, 222, ra), -- 1225
					32 -- 1225
				) -- 1225
				ri = ri + 1 -- 1221
			end -- 1221
		end -- 1221
		local compassSlide = smoothstep(0.15, 0.95, t) -- 1229
		local compX = ax + (1 - compassSlide) * 140 -- 1230
		local compY = ay - (1 - compassSlide) * 90 -- 1231
		local compR = 62 -- 1232
		drawCircleRing( -- 1234
			uiInkDraw, -- 1235
			compX, -- 1236
			compY, -- 1237
			compR + 8, -- 1238
			Color( -- 1239
				98, -- 1239
				78, -- 1239
				48, -- 1239
				math.floor(218 * wellAlpha + 0.5) -- 1239
			), -- 1239
			2, -- 1240
			Color( -- 1241
				186, -- 1241
				154, -- 1241
				102, -- 1241
				math.floor(235 * wellAlpha + 0.5) -- 1241
			), -- 1241
			32 -- 1242
		) -- 1242
		drawCircleRing( -- 1245
			uiInkDraw, -- 1246
			compX, -- 1247
			compY, -- 1248
			compR, -- 1249
			Color( -- 1250
				16, -- 1250
				24, -- 1250
				36, -- 1250
				math.floor(145 * wellAlpha + 0.5) -- 1250
			), -- 1250
			1.2, -- 1251
			Color( -- 1252
				218, -- 1252
				226, -- 1252
				236, -- 1252
				math.floor(180 * wellAlpha + 0.5) -- 1252
			), -- 1252
			32 -- 1253
		) -- 1253
		uiInkDraw:drawSegment( -- 1256
			Vec2(compX, compY + compR - 6), -- 1256
			Vec2(compX, compY + compR - 18), -- 1256
			1.6, -- 1256
			Color( -- 1256
				224, -- 1256
				206, -- 1256
				168, -- 1256
				math.floor(190 * wellAlpha + 0.5) -- 1256
			) -- 1256
		) -- 1256
		uiInkDraw:drawSegment( -- 1257
			Vec2(compX, compY - compR + 6), -- 1257
			Vec2(compX, compY - compR + 18), -- 1257
			1.4, -- 1257
			Color( -- 1257
				168, -- 1257
				174, -- 1257
				182, -- 1257
				math.floor(165 * wellAlpha + 0.5) -- 1257
			) -- 1257
		) -- 1257
		uiInkDraw:drawSegment( -- 1258
			Vec2(compX - compR + 6, compY), -- 1258
			Vec2(compX - compR + 18, compY), -- 1258
			1.4, -- 1258
			Color( -- 1258
				168, -- 1258
				174, -- 1258
				182, -- 1258
				math.floor(165 * wellAlpha + 0.5) -- 1258
			) -- 1258
		) -- 1258
		uiInkDraw:drawSegment( -- 1259
			Vec2(compX + compR - 6, compY), -- 1259
			Vec2(compX + compR - 18, compY), -- 1259
			1.4, -- 1259
			Color( -- 1259
				168, -- 1259
				174, -- 1259
				182, -- 1259
				math.floor(165 * wellAlpha + 0.5) -- 1259
			) -- 1259
		) -- 1259
		local needleAng = -0.35 + math.sin(t * 2.2) * 0.08 * (1 - matchK) -- 1261
		local nx = math.cos(needleAng) * 34 -- 1262
		local ny = math.sin(needleAng) * 34 -- 1263
		uiInkDraw:drawSegment( -- 1264
			Vec2(compX, compY), -- 1264
			Vec2(compX + nx, compY + ny), -- 1264
			2.2, -- 1264
			Color( -- 1264
				208, -- 1264
				92, -- 1264
				82, -- 1264
				math.floor(215 * wellAlpha + 0.5) -- 1264
			) -- 1264
		) -- 1264
		uiInkDraw:drawSegment( -- 1265
			Vec2(compX, compY), -- 1265
			Vec2(compX - nx * 0.85, compY - ny * 0.85), -- 1265
			1.8, -- 1265
			Color( -- 1265
				214, -- 1265
				222, -- 1265
				232, -- 1265
				math.floor(185 * wellAlpha + 0.5) -- 1265
			) -- 1265
		) -- 1265
		if t >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 1265
			local pickK = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellMatchCutStart, t) -- 1269
			local liftY = ay + pickK * 14 -- 1270
			drawCircleRing( -- 1271
				uiInkDraw, -- 1272
				ax, -- 1273
				liftY, -- 1274
				24 + pickK * 12, -- 1275
				Color(0, 0, 0, 0), -- 1276
				1.6, -- 1277
				Color( -- 1278
					226, -- 1278
					204, -- 1278
					152, -- 1278
					math.floor(215 * (1 - matchK * 0.65) + 0.5) -- 1278
				), -- 1278
				28 -- 1279
			) -- 1279
			local capA = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellPickupAt + 0.35, t) * (1 - matchK) -- 1282
			if capA > 0.03 then -- 1282
				drawSilkVeil( -- 1284
					uiDraw, -- 1284
					uiArt, -- 1284
					"fe06_pickup_veil", -- 1284
					w * 0.5, -- 1284
					96, -- 1284
					300, -- 1284
					34, -- 1284
					PALETTE.inkVoid, -- 1284
					0.78 * capA, -- 1284
					1 -- 1284
				) -- 1284
				ctx.texts:put( -- 1285
					"sm", -- 1286
					"拾起「时间穿梭器」", -- 1287
					w * 0.5, -- 1288
					96, -- 1289
					toColor(PALETTE.amberCore), -- 1290
					0.5, -- 1291
					0.5, -- 1292
					"Center", -- 1293
					1.4, -- 1294
					capA -- 1295
				) -- 1295
			end -- 1295
		end -- 1295
	end -- 1295
	if matchK > 0.01 then -- 1295
		local caseW = 300 -- 1303
		local caseH = 276 -- 1304
		local caseX = self.glassAnchorX - caseW * 0.5 -- 1305
		local caseY = self.glassAnchorY - caseH * 0.54 -- 1306
		uiDraw:drawRect( -- 1308
			Rect(caseX - 80, caseY - 110, caseW + 160, caseH + 220), -- 1308
			Color( -- 1308
				24, -- 1308
				29, -- 1308
				36, -- 1308
				math.floor(190 * matchK + 0.5) -- 1308
			) -- 1308
		) -- 1308
		uiDraw:drawRect( -- 1309
			Rect(caseX, caseY, caseW, caseH), -- 1310
			Color( -- 1311
				18, -- 1311
				23, -- 1311
				30, -- 1311
				math.floor(220 * matchK + 0.5) -- 1311
			), -- 1311
			1.6, -- 1312
			Color( -- 1313
				164, -- 1313
				178, -- 1313
				194, -- 1313
				math.floor(185 * matchK + 0.5) -- 1313
			) -- 1313
		) -- 1313
		fillGradQuad( -- 1316
			uiInkDraw, -- 1317
			self.glassAnchorX - 42, -- 1318
			caseY + caseH - 6, -- 1318
			Color( -- 1318
				224, -- 1318
				236, -- 1318
				248, -- 1318
				math.floor(44 * matchK + 0.5) -- 1318
			), -- 1318
			self.glassAnchorX + 24, -- 1319
			caseY + caseH - 6, -- 1319
			Color( -- 1319
				238, -- 1319
				246, -- 1319
				255, -- 1319
				math.floor(78 * matchK + 0.5) -- 1319
			), -- 1319
			self.glassAnchorX - 18, -- 1320
			caseY + 6, -- 1320
			Color( -- 1320
				224, -- 1320
				236, -- 1320
				248, -- 1320
				math.floor(24 * matchK + 0.5) -- 1320
			), -- 1320
			self.glassAnchorX - 82, -- 1321
			caseY + 6, -- 1321
			Color(224, 236, 248, 0) -- 1321
		) -- 1321
		uiArt:tryPlace( -- 1324
			"prop_compass", -- 1324
			"fe06_match_compass", -- 1324
			self.glassAnchorX, -- 1324
			caseY + 72, -- 1324
			46, -- 1324
			46, -- 1324
			{opacity = matchK * 0.85, layer = 3} -- 1324
		) -- 1324
	end -- 1324
	local flashPeak = math.sin(matchK * math.pi) -- 1331
	local coreR = 8 + flashPeak * 18 -- 1332
	uiInkDraw:drawCircle( -- 1333
		Vec2(ax, ay), -- 1333
		coreR * 0.55, -- 1333
		Color(248, 252, 255, 248) -- 1333
	) -- 1333
	fillRadialGlow( -- 1334
		uiGlow, -- 1335
		ax, -- 1336
		ay, -- 1337
		52 + flashPeak * 145, -- 1338
		46 + flashPeak * 115, -- 1339
		Color( -- 1340
			238, -- 1340
			246, -- 1340
			255, -- 1340
			math.floor(145 + flashPeak * 95 + 0.5) -- 1340
		), -- 1340
		Color(174, 204, 238, 0), -- 1341
		20 -- 1342
	) -- 1342
	if flashPeak > 0.05 then -- 1342
		local rayW = 70 + flashPeak * 260 -- 1346
		fillHGradRect( -- 1347
			uiGlow, -- 1347
			ax - rayW, -- 1347
			ay - 2, -- 1347
			rayW, -- 1347
			4, -- 1347
			Color(224, 238, 252, 0), -- 1347
			Color( -- 1347
				242, -- 1347
				248, -- 1347
				255, -- 1347
				math.floor(160 * flashPeak + 0.5) -- 1347
			) -- 1347
		) -- 1347
		fillHGradRect( -- 1348
			uiGlow, -- 1348
			ax, -- 1348
			ay - 2, -- 1348
			rayW, -- 1348
			4, -- 1348
			Color( -- 1348
				242, -- 1348
				248, -- 1348
				255, -- 1348
				math.floor(160 * flashPeak + 0.5) -- 1348
			), -- 1348
			Color(224, 238, 252, 0) -- 1348
		) -- 1348
	end -- 1348
	self:drawLetterbox( -- 1351
		uiInkDraw, -- 1351
		w, -- 1351
		h, -- 1351
		42, -- 1351
		0.92 -- 1351
	) -- 1351
end -- 1174
function WellMuseumPlugin.prototype.renderE02MuseumHall(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, lampTurnProg, inLampTurn) -- 1357
	local floorY = 148 -- 1368
	local wallTopY = h - 86 -- 1369
	local halfW = w * 0.5 -- 1370
	local camMin = math.min(____exports.MUSEUM_HALL_WIDTH * 0.5, halfW - 40) -- 1371
	local camMax = math.max(____exports.MUSEUM_HALL_WIDTH * 0.5, ____exports.MUSEUM_HALL_WIDTH - halfW + 40) -- 1372
	local camX = clamp(self.hallCamX, camMin, camMax) -- 1373
	local function toScreenX(hx) -- 1374
		return halfW + (hx - camX) -- 1374
	end -- 1374
	fillVGradRect( -- 1377
		uiDraw, -- 1377
		0, -- 1377
		floorY, -- 1377
		w, -- 1377
		h - floorY, -- 1377
		Color(26, 31, 38, 255), -- 1377
		Color(16, 20, 26, 255) -- 1377
	) -- 1377
	uiDraw:drawRect( -- 1379
		Rect(0, wallTopY, w, h - wallTopY), -- 1379
		Color(11, 14, 19, 255) -- 1379
	) -- 1379
	local px = 0 -- 1381
	do -- 1381
		px = 40 -- 1382
		while px <= ____exports.MUSEUM_HALL_WIDTH do -- 1382
			local sx = toScreenX(px) -- 1383
			if sx >= -20 and sx <= w + 20 then -- 1383
				uiDraw:drawSegment( -- 1385
					Vec2(sx, floorY), -- 1385
					Vec2(sx, wallTopY), -- 1385
					1, -- 1385
					Color(38, 45, 54, 130) -- 1385
				) -- 1385
			end -- 1385
			px = px + 140 -- 1382
		end -- 1382
	end -- 1382
	fillVGradRect( -- 1389
		uiDraw, -- 1389
		0, -- 1389
		0, -- 1389
		w, -- 1389
		floorY, -- 1389
		Color(14, 17, 22, 255), -- 1389
		Color(32, 37, 45, 255) -- 1389
	) -- 1389
	uiDraw:drawSegment( -- 1390
		Vec2(0, floorY), -- 1390
		Vec2(w, floorY), -- 1390
		2, -- 1390
		Color(76, 86, 98, 220) -- 1390
	) -- 1390
	uiDraw:drawRect( -- 1391
		Rect(0, floorY, w, 12), -- 1391
		Color(20, 24, 31, 240) -- 1391
	) -- 1391
	local plaqueX = toScreenX(180) -- 1394
	if plaqueX > -240 and plaqueX < w + 240 then -- 1394
		local pw = 290 -- 1396
		local ph = 132 -- 1397
		local py = floorY + 135 -- 1398
		uiDraw:drawRect( -- 1399
			Rect(plaqueX - pw * 0.5, py, pw, ph), -- 1400
			Color(18, 22, 28, 238), -- 1401
			1.2, -- 1402
			Color(118, 128, 140, 170) -- 1403
		) -- 1403
		fillRadialGlow( -- 1405
			uiGlow, -- 1405
			plaqueX, -- 1405
			wallTopY - 8, -- 1405
			150, -- 1405
			120, -- 1405
			Color(224, 232, 240, 42), -- 1405
			Color(180, 196, 214, 0), -- 1405
			14 -- 1405
		) -- 1405
		ctx.texts:put( -- 1406
			"sm", -- 1407
			"海防抗战纪念展厅", -- 1408
			plaqueX, -- 1409
			py + 82, -- 1410
			toColor(PALETTE.textBright), -- 1411
			0.5, -- 1412
			0.5, -- 1413
			"Center", -- 1414
			2, -- 1415
			0.88 -- 1416
		) -- 1416
		ctx.texts:put( -- 1418
			"xs", -- 1419
			"温州宁村 · 守望史迹陈列", -- 1420
			plaqueX, -- 1421
			py + 46, -- 1422
			toColor(PALETTE.textDim), -- 1423
			0.5, -- 1424
			0.5, -- 1425
			"Center", -- 1426
			1, -- 1427
			0.78 -- 1428
		) -- 1428
	end -- 1428
	local caseSx = toScreenX(____exports.MUSEUM_CASE_X) -- 1433
	if caseSx > -260 and caseSx < w + 260 then -- 1433
		local boardOffsets = {-210, 210} -- 1436
		local bi = 0 -- 1437
		do -- 1437
			bi = 0 -- 1438
			while bi < #boardOffsets do -- 1438
				local bx = caseSx + boardOffsets[bi + 1] -- 1439
				uiDraw:drawRect( -- 1440
					Rect(bx - 56, floorY + 112, 112, 154), -- 1440
					Color(20, 24, 30, 235), -- 1440
					1, -- 1440
					Color(88, 98, 110, 155) -- 1440
				) -- 1440
				uiDraw:drawRect( -- 1441
					Rect(bx - 42, floorY + 168, 84, 78), -- 1441
					Color(34, 40, 48, 220) -- 1441
				) -- 1441
				uiDraw:drawSegment( -- 1442
					Vec2(bx - 36, floorY + 146), -- 1442
					Vec2(bx + 36, floorY + 146), -- 1442
					1.6, -- 1442
					Color(138, 146, 156, 140) -- 1442
				) -- 1442
				uiDraw:drawSegment( -- 1443
					Vec2(bx - 28, floorY + 132), -- 1443
					Vec2(bx + 24, floorY + 132), -- 1443
					1.2, -- 1443
					Color(108, 116, 126, 115) -- 1443
				) -- 1443
				bi = bi + 1 -- 1438
			end -- 1438
		end -- 1438
		local pedW = 148 -- 1447
		local pedH = 88 -- 1448
		local glassH = 148 -- 1449
		uiDraw:drawRect( -- 1451
			Rect(caseSx - pedW * 0.5, floorY, pedW, pedH), -- 1452
			Color(22, 26, 33, 252), -- 1453
			1.2, -- 1454
			Color(96, 106, 118, 185) -- 1455
		) -- 1455
		uiDraw:drawRect( -- 1458
			Rect(caseSx - pedW * 0.46, floorY + pedH, pedW * 0.92, glassH), -- 1459
			Color(16, 22, 30, 165), -- 1460
			1.4, -- 1461
			Color(180, 196, 214, 195) -- 1462
		) -- 1462
		uiArt:tryPlace( -- 1465
			"prop_compass", -- 1465
			"fe06_hall_compass", -- 1465
			caseSx, -- 1465
			floorY + pedH + 34, -- 1465
			34, -- 1465
			34, -- 1465
			{opacity = 0.94, layer = 3} -- 1465
		) -- 1465
		uiDraw:drawRect( -- 1469
			Rect(caseSx - 30, floorY + pedH + 6, 60, 12), -- 1469
			Color(214, 212, 204, 190) -- 1469
		) -- 1469
		fillGradQuad( -- 1471
			uiInkDraw, -- 1472
			caseSx - 28, -- 1473
			floorY + pedH + glassH - 4, -- 1473
			Color(230, 240, 252, 42), -- 1473
			caseSx + 12, -- 1474
			floorY + pedH + glassH - 4, -- 1474
			Color(242, 248, 255, 72), -- 1474
			caseSx - 12, -- 1475
			floorY + pedH + 4, -- 1475
			Color(230, 240, 252, 18), -- 1475
			caseSx - 48, -- 1476
			floorY + pedH + 4, -- 1476
			Color(230, 240, 252, 0) -- 1476
		) -- 1476
		fillRadialGlow( -- 1478
			uiGlow, -- 1478
			caseSx, -- 1478
			floorY + pedH + glassH - 12, -- 1478
			86, -- 1478
			128, -- 1478
			Color(224, 236, 250, 56), -- 1478
			Color(168, 192, 220, 0), -- 1478
			16 -- 1478
		) -- 1478
		fillVGradRect( -- 1480
			uiDraw, -- 1480
			caseSx - pedW * 0.45, -- 1480
			floorY - 36, -- 1480
			pedW * 0.9, -- 1480
			36, -- 1480
			Color(168, 186, 206, 0), -- 1480
			Color(168, 186, 206, 28) -- 1480
		) -- 1480
	end -- 1480
	local lampSx = toScreenX(____exports.MUSEUM_LAMP_X) -- 1484
	local winSx = toScreenX(____exports.MUSEUM_LAMP_X + 108) -- 1485
	local reflectK = inLampTurn and smoothstep(____exports.MUSEUM_TIMINGS.lampReflectStart, 2.35, self.lampElapsed) or 0 -- 1486
	if winSx > -260 and winSx < w + 260 then -- 1486
		local winW = 196 -- 1491
		local winH = 292 -- 1492
		local winX = winSx - winW * 0.5 -- 1493
		local winY = floorY + 46 -- 1494
		fillVGradRect( -- 1496
			uiDraw, -- 1497
			winX, -- 1498
			winY, -- 1499
			winW, -- 1500
			winH, -- 1501
			Color( -- 1502
				math.floor(54 + 46 * reflectK + 0.5), -- 1503
				math.floor(68 + 42 * reflectK + 0.5), -- 1504
				math.floor(92 + 24 * reflectK + 0.5), -- 1505
				255 -- 1506
			), -- 1506
			Color( -- 1508
				math.floor(30 + 28 * reflectK + 0.5), -- 1509
				math.floor(44 + 34 * reflectK + 0.5), -- 1510
				math.floor(70 + 30 * reflectK + 0.5), -- 1511
				255 -- 1512
			) -- 1512
		) -- 1512
		if reflectK > 0.02 then -- 1512
			uiArt:tryPlace( -- 1518
				"bgFar_prologue", -- 1518
				"fe06_window_courtyard", -- 1518
				winSx, -- 1518
				winY + 26, -- 1518
				winW - 8, -- 1518
				winH - 52, -- 1518
				{ -- 1518
					opacity = reflectK * 0.48, -- 1519
					color = Color(238, 218, 186, 255), -- 1520
					layer = 1 -- 1521
				} -- 1521
			) -- 1521
			local cy = winY + 34 -- 1524
			local silA = math.floor(188 * reflectK + 0.5) -- 1525
			uiInkDraw:drawRect( -- 1526
				Rect(winX + 12, cy, 42, 118), -- 1526
				Color(24, 28, 36, silA) -- 1526
			) -- 1526
			uiInkDraw:drawRect( -- 1527
				Rect(winX + winW - 56, cy, 44, 134), -- 1527
				Color(24, 28, 36, silA) -- 1527
			) -- 1527
			uiInkDraw:drawRect( -- 1529
				Rect(winSx - 24, cy + 4, 48, 28), -- 1529
				Color( -- 1529
					46, -- 1529
					44, -- 1529
					42, -- 1529
					math.floor(215 * reflectK + 0.5) -- 1529
				), -- 1529
				1, -- 1529
				Color( -- 1529
					214, -- 1529
					186, -- 1529
					138, -- 1529
					math.floor(170 * reflectK + 0.5) -- 1529
				) -- 1529
			) -- 1529
			uiInkDraw:drawEllipse( -- 1530
				Vec2(winSx, cy + 32), -- 1530
				26, -- 1530
				7, -- 1530
				Color( -- 1530
					218, -- 1530
					194, -- 1530
					148, -- 1530
					math.floor(175 * reflectK + 0.5) -- 1530
				) -- 1530
			) -- 1530
			fillRadialGlow( -- 1532
				uiGlow, -- 1532
				winSx, -- 1532
				winY + winH * 0.48, -- 1532
				116, -- 1532
				128, -- 1532
				Color( -- 1532
					246, -- 1532
					218, -- 1532
					168, -- 1532
					math.floor(92 * reflectK + 0.5) -- 1532
				), -- 1532
				Color(214, 174, 112, 0), -- 1532
				18 -- 1532
			) -- 1532
		end -- 1532
		uiInkDraw:drawRect( -- 1536
			Rect(winX, winY, winW, winH), -- 1536
			Color(0, 0, 0, 0), -- 1536
			3, -- 1536
			Color(68, 76, 88, 245) -- 1536
		) -- 1536
		uiInkDraw:drawSegment( -- 1537
			Vec2(winSx, winY), -- 1537
			Vec2(winSx, winY + winH), -- 1537
			2, -- 1537
			Color(68, 76, 88, 235) -- 1537
		) -- 1537
		uiInkDraw:drawSegment( -- 1538
			Vec2(winX, winY + winH * 0.56), -- 1538
			Vec2(winX + winW, winY + winH * 0.56), -- 1538
			2, -- 1538
			Color(68, 76, 88, 235) -- 1538
		) -- 1538
		local standW = 34 -- 1541
		local standH = 74 -- 1542
		uiDraw:drawRect( -- 1543
			Rect(lampSx - standW * 0.5, floorY, standW, standH), -- 1543
			Color(34, 39, 48, 250), -- 1543
			1.1, -- 1543
			Color(108, 118, 130, 190) -- 1543
		) -- 1543
		local pivotY = floorY + standH + 40 -- 1545
		uiInkDraw:drawSegment( -- 1546
			Vec2(lampSx, floorY + standH), -- 1546
			Vec2(lampSx, pivotY), -- 1546
			3.2, -- 1546
			Color(136, 144, 154, 240) -- 1546
		) -- 1546
		uiInkDraw:drawCircle( -- 1547
			Vec2(lampSx, pivotY), -- 1547
			5.5, -- 1547
			Color(196, 178, 142, 245) -- 1547
		) -- 1547
		local aimDir = -0.65 + lampTurnProg * 1.48 -- 1549
		local headX = lampSx + math.sin(aimDir) * 20 -- 1550
		local headY = pivotY + math.cos(aimDir) * 14 -- 1551
		uiInkDraw:drawSegment( -- 1552
			Vec2(lampSx, pivotY), -- 1552
			Vec2(headX, headY), -- 1552
			6.2, -- 1552
			Color(188, 166, 126, 245) -- 1552
		) -- 1552
		uiInkDraw:drawCircle( -- 1553
			Vec2(headX, headY), -- 1553
			5.2, -- 1553
			Color(248, 234, 198, 248) -- 1553
		) -- 1553
		local beamLen = 132 + lampTurnProg * 76 -- 1556
		local bxEnd = headX + math.sin(aimDir) * beamLen -- 1557
		local byEnd = headY + math.cos(aimDir) * 28 -- 1558
		local perpX = -math.cos(aimDir) * 18 -- 1559
		local perpY = math.sin(aimDir) * 34 -- 1560
		fillGradQuad( -- 1561
			uiGlow, -- 1562
			headX, -- 1563
			headY - 4, -- 1563
			Color( -- 1563
				246, -- 1563
				224, -- 1563
				178, -- 1563
				math.floor(68 + 44 * lampTurnProg + 0.5) -- 1563
			), -- 1563
			headX, -- 1564
			headY + 4, -- 1564
			Color( -- 1564
				246, -- 1564
				224, -- 1564
				178, -- 1564
				math.floor(68 + 44 * lampTurnProg + 0.5) -- 1564
			), -- 1564
			bxEnd + perpX, -- 1565
			byEnd + perpY + 34, -- 1565
			Color(238, 206, 148, 0), -- 1565
			bxEnd - perpX, -- 1566
			byEnd - perpY - 22, -- 1566
			Color(238, 206, 148, 0) -- 1566
		) -- 1566
		fillRadialGlow( -- 1568
			uiGlow, -- 1568
			headX, -- 1568
			headY, -- 1568
			34, -- 1568
			34, -- 1568
			Color(246, 228, 186, 78), -- 1568
			Color(224, 194, 140, 0), -- 1568
			14 -- 1568
		) -- 1568
	end -- 1568
	local playerSx = toScreenX(self.hallWalkX) -- 1572
	local moving = not inLampTurn and math.abs(ctx.input.moveX) > 0.05 -- 1573
	local slot = moving and "soldier_run" or (self.holstered and "soldier_idle" or "soldier_idle") -- 1574
	local frame = moving and math.floor(self.hallWalkAnim) or 0 -- 1575
	local charH = 114 -- 1576
	local charW = 54 -- 1577
	uiDraw:drawEllipse( -- 1579
		Vec2(playerSx, floorY + 2), -- 1579
		26, -- 1579
		5.5, -- 1579
		Color(6, 8, 12, 178) -- 1579
	) -- 1579
	uiDraw:drawEllipse( -- 1580
		Vec2(playerSx, floorY - 12), -- 1580
		18, -- 1580
		4, -- 1580
		Color(16, 20, 28, 62) -- 1580
	) -- 1580
	if not uiArt:tryPlace( -- 1580
		slot, -- 1581
		"fe06_museum_zhoushu", -- 1581
		playerSx, -- 1581
		floorY + 2, -- 1581
		charW, -- 1581
		charH, -- 1581
		{facing = self.hallFacing, frame = frame, layer = 3} -- 1581
	) then -- 1581
		uiDraw:drawRect( -- 1587
			Rect(playerSx - 14, floorY + 2, 28, charH * 0.84), -- 1587
			toColor(CUFF_PALETTE.indigoBase) -- 1587
		) -- 1587
		uiDraw:drawCircle( -- 1588
			Vec2(playerSx, floorY + charH * 0.92), -- 1588
			12, -- 1588
			Color(66, 73, 76, 255) -- 1588
		) -- 1588
	end -- 1588
	if self.holstered and not inLampTurn and math.abs(self.hallWalkX - ____exports.MUSEUM_CASE_X) <= 130 then -- 1588
		local subA = clamp01(1 - math.abs(self.hallWalkX - ____exports.MUSEUM_CASE_X) / 145) * 0.86 -- 1593
		ctx.texts:put( -- 1594
			"xs", -- 1595
			"已收起随身器物", -- 1596
			caseSx, -- 1597
			floorY + 286, -- 1598
			toColor(PALETTE.textMid), -- 1599
			0.5, -- 1600
			0.5, -- 1601
			"Center", -- 1602
			0.9, -- 1603
			subA -- 1604
		) -- 1604
	end -- 1604
	if self.childEchoVisualT > 0 then -- 1604
		local echoK = 1 - clamp01(self.childEchoVisualT / 2.1) -- 1610
		local ex = math.min( -- 1611
			w - 110, -- 1611
			toScreenX(____exports.MUSEUM_CASE_X + 310) -- 1611
		) -- 1611
		local ey = floorY + 32 -- 1612
		local ea = math.floor(math.sin(echoK * math.pi) * 165 + 0.5) -- 1613
		drawCircleRing( -- 1614
			uiInkDraw, -- 1614
			ex, -- 1614
			ey, -- 1614
			14 + echoK * 46, -- 1614
			Color(0, 0, 0, 0), -- 1614
			1.1, -- 1614
			Color(224, 214, 194, ea), -- 1614
			28 -- 1614
		) -- 1614
		drawCircleRing( -- 1615
			uiInkDraw, -- 1615
			ex, -- 1615
			ey, -- 1615
			8 + echoK * 28, -- 1615
			Color(0, 0, 0, 0), -- 1615
			0.9, -- 1615
			Color( -- 1615
				224, -- 1615
				214, -- 1615
				194, -- 1615
				math.floor(ea * 0.7 + 0.5) -- 1615
			), -- 1615
			24 -- 1615
		) -- 1615
		ctx.texts:put( -- 1616
			"xs", -- 1617
			"（远方传来轻快的孩童脚步声）", -- 1618
			w * 0.5, -- 1619
			84, -- 1620
			toColor(PALETTE.textMid), -- 1621
			0.5, -- 1622
			0.5, -- 1623
			"Center", -- 1624
			1, -- 1625
			math.sin(echoK * math.pi) * 0.85 -- 1626
		) -- 1626
	end -- 1626
	if not inLampTurn then -- 1626
		local fadeIn = smoothstep(0, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn, self.hallIntroElapsed) -- 1632
		local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold + ____exports.MUSEUM_TIMINGS.hallIntroFadeOut, self.hallIntroElapsed) -- 1633
		local introA = fadeIn * fadeOut -- 1638
		if introA > 0.02 then -- 1638
			drawSilkVeil( -- 1640
				uiDraw, -- 1640
				uiArt, -- 1640
				"fe06_hall_intro_veil", -- 1640
				w * 0.5, -- 1640
				h - 104, -- 1640
				480, -- 1640
				74, -- 1640
				PALETTE.inkVoid, -- 1640
				0.78 * introA, -- 1640
				1 -- 1640
			) -- 1640
			drawHairline( -- 1641
				uiInkDraw, -- 1641
				uiArt, -- 1641
				"fe06_hall_intro_line", -- 1641
				w * 0.5, -- 1641
				h - 106, -- 1641
				260, -- 1641
				PALETTE.silkLine, -- 1641
				0.45 * introA, -- 1641
				false, -- 1641
				4 -- 1641
			) -- 1641
			ctx.texts:put( -- 1642
				"md", -- 1642
				____exports.MUSEUM_HALL_TITLE, -- 1642
				w * 0.5, -- 1642
				h - 88, -- 1642
				toColor(PALETTE.textBright), -- 1642
				0.5, -- 1642
				0.5, -- 1642
				"Center", -- 1642
				1.8, -- 1642
				introA -- 1642
			) -- 1642
			ctx.texts:put( -- 1643
				"xs", -- 1643
				____exports.MUSEUM_HALL_SUBTITLE, -- 1643
				w * 0.5, -- 1643
				h - 122, -- 1643
				toColor(PALETTE.amberCore), -- 1643
				0.5, -- 1643
				0.5, -- 1643
				"Center", -- 1643
				1.2, -- 1643
				introA * 0.88 -- 1643
			) -- 1643
		end -- 1643
		if self.nearLamp and ctx.view.assistHintsEnabled then -- 1643
			drawSilkVeil( -- 1648
				uiDraw, -- 1648
				uiArt, -- 1648
				"fe06_lamp_hint_veil", -- 1648
				lampSx, -- 1648
				floorY + 158, -- 1648
				146, -- 1648
				28, -- 1648
				PALETTE.panelBg, -- 1648
				0.84, -- 1648
				1 -- 1648
			) -- 1648
			ctx.texts:put( -- 1649
				"xs", -- 1649
				"[E] 转动西窗灯", -- 1649
				lampSx, -- 1649
				floorY + 158, -- 1649
				toColor(PALETTE.textBright), -- 1649
				0.5, -- 1649
				0.5, -- 1649
				"Center", -- 1649
				0.6, -- 1649
				0.94 -- 1649
			) -- 1649
		end -- 1649
	end -- 1649
	if inLampTurn and self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1649
		local lineA = smoothstep(____exports.MUSEUM_TIMINGS.lampLineAt, ____exports.MUSEUM_TIMINGS.lampLineAt + 0.45, self.lampElapsed) * (1 - smoothstep(____exports.MUSEUM_TIMINGS.lampTurnDuration - 0.35, ____exports.MUSEUM_TIMINGS.lampTurnDuration, self.lampElapsed)) -- 1655
		if lineA > 0.02 then -- 1655
			drawSilkVeil( -- 1658
				uiDraw, -- 1658
				uiArt, -- 1658
				"fe06_dawn_line_veil", -- 1658
				w * 0.5, -- 1658
				86, -- 1658
				440, -- 1658
				50, -- 1658
				PALETTE.inkVoid, -- 1658
				0.84 * lineA, -- 1658
				1 -- 1658
			) -- 1658
			ctx.texts:put( -- 1659
				"md", -- 1660
				____exports.MUSEUM_LINE_DAWN, -- 1660
				w * 0.5, -- 1662
				86, -- 1663
				toColor(PALETTE.amberCore), -- 1664
				0.5, -- 1665
				0.5, -- 1666
				"Center", -- 1667
				1.6, -- 1668
				lineA -- 1669
			) -- 1669
		end -- 1669
	end -- 1669
	if self.knock1VisualT > 0 then -- 1669
		local k1 = 1 - clamp01(self.knock1VisualT / 0.85) -- 1675
		local k1A = math.floor((1 - k1) * 205 + 0.5) -- 1676
		drawCircleRing( -- 1677
			uiInkDraw, -- 1677
			winSx, -- 1677
			floorY + 148, -- 1677
			12 + k1 * 64, -- 1677
			Color(0, 0, 0, 0), -- 1677
			1.6, -- 1677
			Color(242, 232, 206, k1A), -- 1677
			28 -- 1677
		) -- 1677
		drawCircleRing( -- 1678
			uiInkDraw, -- 1678
			winSx, -- 1678
			floorY + 148, -- 1678
			6 + k1 * 34, -- 1678
			Color(0, 0, 0, 0), -- 1678
			1.1, -- 1678
			Color( -- 1678
				242, -- 1678
				232, -- 1678
				206, -- 1678
				math.floor(k1A * 0.72 + 0.5) -- 1678
			), -- 1678
			24 -- 1678
		) -- 1678
	end -- 1678
	self:drawLetterbox( -- 1681
		uiInkDraw, -- 1681
		w, -- 1681
		h, -- 1681
		38, -- 1681
		0.9 -- 1681
	) -- 1681
end -- 1357
function WellMuseumPlugin.prototype.renderE02ReturnCabinet(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1687
	local t = self.returnElapsed -- 1696
	local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.returnFadeOutAt, ____exports.MUSEUM_TIMINGS.returnCabinetDuration, t) -- 1697
	uiDraw:drawRect( -- 1700
		Rect(0, 0, w, h), -- 1700
		Color( -- 1700
			7, -- 1700
			9, -- 1700
			13, -- 1700
			math.floor(252 * fadeOut + 0.5) -- 1700
		) -- 1700
	) -- 1700
	if t < ____exports.MUSEUM_TIMINGS.returnKnock2At then -- 1700
		self:drawLetterbox( -- 1703
			uiInkDraw, -- 1703
			w, -- 1703
			h, -- 1703
			42, -- 1703
			0.95 * fadeOut -- 1703
		) -- 1703
		return -- 1704
	end -- 1704
	local revealK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.34, t) * fadeOut -- 1708
	local boxW = math.min(w - 140, 820) -- 1709
	local boxH = math.min(h - 190, 390) -- 1710
	local bx = (w - boxW) * 0.5 -- 1711
	local by = (h - boxH) * 0.5 + 10 -- 1712
	fillVGradRect( -- 1715
		uiDraw, -- 1716
		bx, -- 1717
		by, -- 1718
		boxW, -- 1719
		boxH, -- 1720
		Color( -- 1721
			13, -- 1721
			12, -- 1721
			16, -- 1721
			math.floor(248 * revealK + 0.5) -- 1721
		), -- 1721
		Color( -- 1722
			24, -- 1722
			24, -- 1722
			30, -- 1722
			math.floor(248 * revealK + 0.5) -- 1722
		) -- 1722
	) -- 1722
	local cabEdgeX = bx + boxW * 0.58 -- 1725
	uiDraw:drawRect( -- 1726
		Rect(cabEdgeX, by, boxW - (cabEdgeX - bx), boxH), -- 1726
		Color( -- 1726
			42, -- 1726
			31, -- 1726
			24, -- 1726
			math.floor(246 * revealK + 0.5) -- 1726
		) -- 1726
	) -- 1726
	uiDraw:drawSegment( -- 1727
		Vec2(cabEdgeX, by), -- 1727
		Vec2(cabEdgeX, by + boxH), -- 1727
		2.4, -- 1727
		Color( -- 1727
			116, -- 1727
			92, -- 1727
			68, -- 1727
			math.floor(220 * revealK + 0.5) -- 1727
		) -- 1727
	) -- 1727
	local gi = 0 -- 1729
	do -- 1729
		gi = 0 -- 1730
		while gi < 5 do -- 1730
			local gx = cabEdgeX + 26 + gi * 44 -- 1731
			if gx < bx + boxW - 10 then -- 1731
				uiDraw:drawSegment( -- 1733
					Vec2(gx, by + 12), -- 1733
					Vec2(gx, by + boxH - 12), -- 1733
					1, -- 1733
					Color( -- 1733
						28, -- 1733
						20, -- 1733
						15, -- 1733
						math.floor(140 * revealK + 0.5) -- 1733
					) -- 1733
				) -- 1733
			end -- 1733
			gi = gi + 1 -- 1730
		end -- 1730
	end -- 1730
	fillHGradRect( -- 1737
		uiGlow, -- 1738
		cabEdgeX - 58, -- 1739
		by + 24, -- 1740
		58, -- 1741
		boxH - 48, -- 1742
		Color(168, 188, 210, 0), -- 1743
		Color( -- 1744
			186, -- 1744
			206, -- 1744
			226, -- 1744
			math.floor(42 * revealK + 0.5) -- 1744
		) -- 1744
	) -- 1744
	if self.knock2VisualT > 0 then -- 1744
		local k2 = 1 - clamp01(self.knock2VisualT / 0.9) -- 1749
		local k2A = math.floor((1 - k2) * 215 * fadeOut + 0.5) -- 1750
		drawCircleRing( -- 1751
			uiInkDraw, -- 1751
			cabEdgeX + 8, -- 1751
			by + boxH * 0.5, -- 1751
			10 + k2 * 56, -- 1751
			Color(0, 0, 0, 0), -- 1751
			1.6, -- 1751
			Color(232, 220, 196, k2A), -- 1751
			28 -- 1751
		) -- 1751
	end -- 1751
	local extendK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.08, ____exports.MUSEUM_TIMINGS.returnKnock2At + 1.05, t) -- 1755
	local wristX = bx + 115 + extendK * (cabEdgeX - bx - 168) -- 1756
	local wristY = by + boxH * 0.5 -- 1757
	drawPatchedCuff(uiInkDraw, uiGlow, { -- 1758
		wristX = wristX, -- 1759
		wristY = wristY, -- 1760
		angleRad = -0.04 * (1 - extendK), -- 1761
		scale = 1.02, -- 1762
		pose = "reach", -- 1763
		opacity = revealK, -- 1764
		stitchHighlight = 0.48 + 0.22 * extendK, -- 1765
		cuffPullBack = 0.06, -- 1766
		warmth = 0.16 -- 1767
	}) -- 1767
	uiInkDraw:drawRect( -- 1771
		Rect(bx, by, boxW, boxH), -- 1771
		Color(0, 0, 0, 0), -- 1771
		1.2, -- 1771
		toColor( -- 1771
			PALETTE.silkDim, -- 1771
			math.floor(160 * revealK + 0.5) -- 1771
		) -- 1771
	) -- 1771
	local tipA = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.45, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.95, t) * fadeOut -- 1772
	if tipA > 0.03 then -- 1772
		drawSilkVeil( -- 1774
			uiDraw, -- 1774
			uiArt, -- 1774
			"fe06_return_veil", -- 1774
			w * 0.5, -- 1774
			by - 30, -- 1774
			320, -- 1774
			32, -- 1774
			PALETTE.inkVoid, -- 1774
			0.72 * tipA, -- 1774
			1 -- 1774
		) -- 1774
		ctx.texts:put( -- 1775
			"xs", -- 1776
			"两声轻敲落回柜板 · 寻回小满", -- 1777
			w * 0.5, -- 1778
			by - 30, -- 1779
			toColor(PALETTE.textMid), -- 1780
			0.5, -- 1781
			0.5, -- 1782
			"Center", -- 1783
			1.2, -- 1784
			tipA * 0.9 -- 1785
		) -- 1785
	end -- 1785
	self:drawLetterbox( -- 1789
		uiInkDraw, -- 1789
		w, -- 1789
		h, -- 1789
		42, -- 1789
		0.95 * fadeOut -- 1789
	) -- 1789
end -- 1687
function WellMuseumPlugin.prototype.drawLetterbox(self, draw, w, h, barH, opacity) -- 1792
	local a = math.floor(244 * clamp01(opacity) + 0.5) -- 1793
	if a <= 2 then -- 1793
		return -- 1795
	end -- 1795
	draw:drawRect( -- 1797
		Rect(0, 0, w, barH), -- 1797
		Color(6, 8, 12, a) -- 1797
	) -- 1797
	draw:drawRect( -- 1798
		Rect(0, h - barH, w, barH), -- 1798
		Color(6, 8, 12, a) -- 1798
	) -- 1798
end -- 1792
function ____exports.createWellMuseumPlugin(contract) -- 1802
	return __TS__New(____exports.WellMuseumPlugin, contract) -- 1803
end -- 1802
return ____exports -- 1802