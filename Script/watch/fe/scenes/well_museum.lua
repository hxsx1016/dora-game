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
____exports.WELL_WORLD_X = 430 -- 55
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
function WellMuseumPlugin.prototype.____constructor(self, contract) -- 350
	self.id = "fe-06-well-museum" -- 287
	self.animTime = 0 -- 290
	self.prevPhase = "locked" -- 291
	self.roomSessionId = 0 -- 292
	self.rehearsal = false -- 293
	self.gateOpen = false -- 296
	self.gateBlockedReason = "locked" -- 297
	self.wellWorldX = ____exports.WELL_WORLD_X -- 298
	self.nearWell = false -- 299
	self.revisitCalmTimer = 0 -- 300
	self.revisitCalmCount = 0 -- 301
	self.reflectElapsed = 0 -- 304
	self.wellAnchorX = 640 -- 305
	self.wellAnchorY = 388.8 -- 306
	self.glassAnchorX = 640 -- 307
	self.glassAnchorY = 388.8 -- 308
	self.enterHallSubmitted = false -- 309
	self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 312
	self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 313
	self.hallFacing = 1 -- 314
	self.hallWalkAnim = 0 -- 315
	self.hallMoving = false -- 316
	self.hallFootstepTimer = 0 -- 317
	self.hallIntroElapsed = 0 -- 318
	self.holstered = false -- 319
	self.childEchoCountdown = -1 -- 320
	self.childEchoPlayed = false -- 321
	self.childEchoVisualT = 0 -- 322
	self.nearLamp = false -- 323
	self.lampElapsed = 0 -- 325
	self.lineDawnShown = false -- 326
	self.knock1Played = false -- 327
	self.knock1VisualT = 0 -- 328
	self.beginReturnSubmitted = false -- 329
	self.returnElapsed = 0 -- 332
	self.knock2Played = false -- 333
	self.knock2VisualT = 0 -- 334
	self.returnCompleteSubmitted = false -- 335
	self.artifactGrantCount = 0 -- 338
	self.resumeRestoreCount = 0 -- 340
	self.lastResumePhase = "locked" -- 341
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 342
	self.lastVisualMode = "pixel" -- 343
	self.lastPaused = false -- 344
	self.wellDripPlaying = false -- 345
	self.hallAmbiencePlaying = false -- 346
	self.liveReflectDoneInMuseumRoom = false -- 347
	self.injectedContract = contract -- 351
end -- 350
function WellMuseumPlugin.prototype.syncRuntimeHook(self) -- 354
	local g = _G -- 355
	local ____temp_3 -- 356
	if g.package ~= nil then -- 356
		____temp_3 = g.package.loaded -- 356
	else -- 356
		____temp_3 = nil -- 356
	end -- 356
	local loaded = ____temp_3 -- 356
	if loaded == nil then -- 356
		return -- 358
	end -- 358
	local rawFe = loaded["watch.fe"] -- 360
	if rawFe ~= nil and type(rawFe) == "table" then -- 360
		local watchFe = rawFe -- 362
		if watchFe.wellMuseum ~= self then -- 362
			watchFe.wellMuseum = self -- 364
		end -- 364
	end -- 364
end -- 354
function WellMuseumPlugin.prototype.queueSimulatedInput(self, sim) -- 370
	self.simInput = {moveX = sim.moveX, interact = sim.interact} -- 371
end -- 370
function WellMuseumPlugin.prototype.exportResumeState(self) -- 378
	return { -- 379
		phase = self.prevPhase, -- 380
		hallWalkX = self.hallWalkX, -- 381
		hallCamX = self.hallCamX, -- 382
		hallFacing = self.hallFacing, -- 383
		holstered = self.holstered, -- 384
		childEchoPlayed = self.childEchoPlayed, -- 385
		reflectElapsed = self.reflectElapsed, -- 386
		lampElapsed = self.lampElapsed, -- 387
		returnElapsed = self.returnElapsed, -- 388
		artifactGrantCount = self.artifactGrantCount -- 389
	} -- 389
end -- 378
function WellMuseumPlugin.prototype.restoreResumeState(self, snap) -- 394
	if snap.phase ~= nil then -- 394
		self.prevPhase = snap.phase -- 396
		self.lastResumePhase = snap.phase -- 397
	end -- 397
	if snap.hallWalkX ~= nil then -- 397
		self.hallWalkX = clamp(snap.hallWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 400
		self.lastResumeWalkX = self.hallWalkX -- 401
	end -- 401
	if snap.hallCamX ~= nil then -- 401
		self.hallCamX = snap.hallCamX -- 404
	else -- 404
		self.hallCamX = self.hallWalkX -- 406
	end -- 406
	if snap.hallFacing ~= nil then -- 406
		self.hallFacing = snap.hallFacing >= 0 and 1 or -1 -- 409
	end -- 409
	if snap.holstered ~= nil then -- 409
		self.holstered = snap.holstered -- 412
	end -- 412
	if snap.childEchoPlayed ~= nil then -- 412
		self.childEchoPlayed = snap.childEchoPlayed -- 415
	end -- 415
	if snap.reflectElapsed ~= nil then -- 415
		self.reflectElapsed = math.max(0, snap.reflectElapsed) -- 418
	end -- 418
	if snap.lampElapsed ~= nil then -- 418
		self.lampElapsed = math.max(0, snap.lampElapsed) -- 421
	end -- 421
	if snap.returnElapsed ~= nil then -- 421
		self.returnElapsed = math.max(0, snap.returnElapsed) -- 424
	end -- 424
	if snap.artifactGrantCount ~= nil then -- 424
		self.artifactGrantCount = math.max(0, snap.artifactGrantCount) -- 427
	end -- 427
	self.savedResume = self:exportResumeState() -- 429
	self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 430
end -- 394
function WellMuseumPlugin.prototype.resetSessionCounters(self) -- 434
	self.artifactGrantCount = 0 -- 435
	self.revisitCalmCount = 0 -- 436
	self.revisitCalmTimer = 0 -- 437
	self.savedResume = nil -- 438
	self.resumeRestoreCount = 0 -- 439
	self.lastResumePhase = "locked" -- 440
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 441
end -- 434
function WellMuseumPlugin.prototype.setHallWalkPosition(self, x, holstered) -- 445
	self.hallWalkX = clamp(x, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 446
	self.hallCamX = self.hallWalkX -- 447
	if holstered ~= nil then -- 447
		self.holstered = holstered -- 449
	elseif self.hallWalkX >= ____exports.MUSEUM_CASE_X - 85 then -- 449
		self.holstered = true -- 451
	end -- 451
	self.savedResume = self:exportResumeState() -- 453
end -- 445
function WellMuseumPlugin.prototype.seekStageTime(self, stage, seconds) -- 457
	local s = math.max(0, seconds) -- 458
	if stage == "well_reflect" then -- 458
		self.reflectElapsed = math.min(____exports.MUSEUM_TIMINGS.wellReflectDuration, s) -- 460
	elseif stage == "lamp_turn" then -- 460
		self.lampElapsed = math.min(____exports.MUSEUM_TIMINGS.lampTurnDuration, s) -- 462
		self.lineDawnShown = self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt -- 463
	elseif stage == "return_cabinet" then -- 463
		self.returnElapsed = math.min(____exports.MUSEUM_TIMINGS.returnCabinetDuration, s) -- 465
	end -- 465
end -- 457
function WellMuseumPlugin.prototype.getDebugState(self) -- 469
	local reflectProg = clamp01(self.reflectElapsed / ____exports.MUSEUM_TIMINGS.wellReflectDuration) -- 470
	local matchStart = ____exports.MUSEUM_TIMINGS.wellMatchCutStart -- 471
	local matchSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.wellReflectDuration - matchStart) -- 472
	local matchProg = self.reflectElapsed <= matchStart and 0 or clamp01((self.reflectElapsed - matchStart) / matchSpan) -- 473
	local lampTurnProg = clamp01(self.lampElapsed / 1.15) -- 476
	local cuffStart = ____exports.MUSEUM_TIMINGS.returnKnock2At -- 477
	local cuffSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.returnFadeOutAt - cuffStart) -- 478
	local cuffProg = self.returnElapsed <= cuffStart and 0 or clamp01((self.returnElapsed - cuffStart) / cuffSpan) -- 479
	local dx = self.glassAnchorX - self.wellAnchorX -- 482
	local dy = self.glassAnchorY - self.wellAnchorY -- 483
	return { -- 484
		gateOpen = self.gateOpen, -- 485
		gateBlockedReason = self.gateBlockedReason, -- 486
		wellWorldX = self.wellWorldX, -- 487
		nearWell = self.nearWell, -- 488
		museumPhase = self.prevPhase, -- 489
		visualMode = self.lastVisualMode, -- 490
		reflectElapsed = self.reflectElapsed, -- 491
		reflectProgress = reflectProg, -- 492
		matchCutProgress = matchProg, -- 493
		wellAnchorX = self.wellAnchorX, -- 494
		wellAnchorY = self.wellAnchorY, -- 495
		glassAnchorX = self.glassAnchorX, -- 496
		glassAnchorY = self.glassAnchorY, -- 497
		matchCutAnchorDeltaPx = math.sqrt(dx * dx + dy * dy), -- 498
		hallWalkX = self.hallWalkX, -- 499
		hallCamX = self.hallCamX, -- 500
		holstered = self.holstered, -- 501
		childEchoPlayed = self.childEchoPlayed, -- 502
		nearLamp = self.nearLamp, -- 503
		lampElapsed = self.lampElapsed, -- 504
		lampTurnProgress = lampTurnProg, -- 505
		lineDawnShown = self.lineDawnShown, -- 506
		knock1Played = self.knock1Played, -- 507
		knock2Played = self.knock2Played, -- 508
		returnElapsed = self.returnElapsed, -- 509
		cuffReusedFromSharedPalette = true, -- 510
		cuffProgress = cuffProg, -- 511
		artifactGrantCount = self.artifactGrantCount, -- 512
		revisitCalmCount = self.revisitCalmCount, -- 513
		resumeRestoreCount = self.resumeRestoreCount, -- 514
		lastResumePhase = self.lastResumePhase, -- 515
		lastResumeWalkX = self.lastResumeWalkX, -- 516
		pausedFrozen = self.lastPaused -- 517
	} -- 517
end -- 469
function WellMuseumPlugin.prototype.onBindPlay(self, p, view) -- 521
	self:syncRuntimeHook() -- 522
	if view.isRehearsal ~= self.rehearsal then -- 522
		self.savedResume = nil -- 524
	end -- 524
	self.rehearsal = view.isRehearsal -- 526
	self.animTime = 0 -- 527
	self.revisitCalmTimer = 0 -- 528
	self.childEchoVisualT = 0 -- 529
	self.knock1VisualT = 0 -- 530
	self.knock2VisualT = 0 -- 531
	self.wellDripPlaying = false -- 532
	self.hallAmbiencePlaying = false -- 533
	self.enterHallSubmitted = false -- 534
	self.beginReturnSubmitted = false -- 535
	self.returnCompleteSubmitted = false -- 536
	self.liveReflectDoneInMuseumRoom = false -- 537
	self.simInput = nil -- 538
	local phase = view.archive.museumPhase -- 540
	self.prevPhase = phase -- 541
	self.lastVisualMode = view.visualMode -- 542
	local ____view_isRehearsal_4 -- 545
	if view.isRehearsal then -- 545
		____view_isRehearsal_4 = nil -- 545
	else -- 545
		____view_isRehearsal_4 = asRecord(p) -- 545
	end -- 545
	local pRec = ____view_isRehearsal_4 -- 545
	local backendWellX = readNum(pRec, "wellX") -- 546
	self.wellWorldX = backendWellX ~= nil and p.ox + backendWellX or p.ox + ____exports.WELL_WORLD_X -- 547
	self.hallMoving = false -- 548
	if view.archive.childCleared and view.archive.soldierCleared and view.archive.artifactOwned then -- 548
		if self.artifactGrantCount < 1 then -- 548
			self.artifactGrantCount = 1 -- 553
		end -- 553
	elseif not view.archive.artifactOwned then -- 553
		self.artifactGrantCount = 0 -- 556
	end -- 556
	if isActiveMuseumPhase(phase) then -- 556
		local ____view_isRehearsal_5 -- 561
		if view.isRehearsal then -- 561
			____view_isRehearsal_5 = nil -- 561
		else -- 561
			____view_isRehearsal_5 = asRecord(p.run) -- 561
		end -- 561
		local runRec = ____view_isRehearsal_5 -- 561
		local ____asRecord_7 = asRecord -- 562
		local ____temp_6 -- 562
		if pRec ~= nil then -- 562
			____temp_6 = pRec.archive -- 562
		else -- 562
			____temp_6 = nil -- 562
		end -- 562
		local ____asRecord_7_result_10 = ____asRecord_7(____temp_6) -- 562
		if ____asRecord_7_result_10 == nil then -- 562
			local ____asRecord_9 = asRecord -- 563
			local ____temp_8 -- 563
			if runRec ~= nil then -- 563
				____temp_8 = runRec.archive -- 563
			else -- 563
				____temp_8 = nil -- 563
			end -- 563
			____asRecord_7_result_10 = ____asRecord_9(____temp_8) -- 562
		end -- 562
		local archRec = ____asRecord_7_result_10 -- 562
		local backendWalkX = readNum(archRec, "museumWalkX") or readNum(pRec, "museumWalkX") -- 564
		local ____readBool_result_11 = readBool(archRec, "museumHolstered") -- 565
		if ____readBool_result_11 == nil then -- 565
			____readBool_result_11 = readBool(pRec, "museumHolstered") -- 565
		end -- 565
		local backendHolstered = ____readBool_result_11 -- 565
		local ____readBool_result_12 = readBool(archRec, "museumChildEchoPlayed") -- 566
		if ____readBool_result_12 == nil then -- 566
			____readBool_result_12 = readBool(pRec, "museumChildEchoPlayed") -- 566
		end -- 566
		local backendChildEcho = ____readBool_result_12 -- 566
		if self.savedResume ~= nil and self.savedResume.phase == phase then -- 566
			self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.savedResume.hallWalkX -- 569
			self.hallCamX = self.hallWalkX -- 570
			self.hallFacing = self.savedResume.hallFacing -- 571
			local ____backendHolstered_13 = backendHolstered -- 572
			if ____backendHolstered_13 == nil then -- 572
				____backendHolstered_13 = self.savedResume.holstered -- 572
			end -- 572
			self.holstered = ____backendHolstered_13 -- 572
			local ____backendChildEcho_14 = backendChildEcho -- 573
			if ____backendChildEcho_14 == nil then -- 573
				____backendChildEcho_14 = self.savedResume.childEchoPlayed -- 573
			end -- 573
			self.childEchoPlayed = ____backendChildEcho_14 -- 573
			self.reflectElapsed = self.savedResume.reflectElapsed -- 574
			self.lampElapsed = self.savedResume.lampElapsed -- 575
			self.returnElapsed = self.savedResume.returnElapsed -- 576
		else -- 576
			self:resetPhaseTimersForEntry(phase, backendWalkX, backendHolstered, backendChildEcho) -- 578
		end -- 578
		self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 580
		self.lastResumePhase = phase -- 581
		self.lastResumeWalkX = self.hallWalkX -- 582
	else -- 582
		self.reflectElapsed = 0 -- 585
		self.lampElapsed = 0 -- 586
		self.returnElapsed = 0 -- 587
		self.hallIntroElapsed = 0 -- 588
		self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 589
		self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 590
		self.hallFacing = 1 -- 591
		self.holstered = false -- 592
		self.childEchoCountdown = -1 -- 593
		self.childEchoPlayed = false -- 594
		self.lineDawnShown = false -- 595
		self.knock1Played = false -- 596
		self.knock2Played = false -- 597
		if phase == "locked" or phase == "well_open" then -- 597
			self.savedResume = nil -- 599
		end -- 599
	end -- 599
end -- 521
function WellMuseumPlugin.prototype.resetPhaseTimersForEntry(self, phase, backendWalkX, backendHolstered, backendChildEcho) -- 604
	if phase == "well_reflect" then -- 604
		self.reflectElapsed = 0 -- 611
		self.enterHallSubmitted = false -- 612
		return -- 613
	end -- 613
	if phase == "hall_walk" then -- 613
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or ____exports.MUSEUM_ENTRY_X -- 616
		self.hallCamX = self.hallWalkX -- 617
		self.hallFacing = 1 -- 618
		self.hallIntroElapsed = backendWalkX ~= nil and backendWalkX > 260 and 5 or 0 -- 619
		local ____backendHolstered_15 = backendHolstered -- 620
		if ____backendHolstered_15 == nil then -- 620
			____backendHolstered_15 = self.hallWalkX >= ____exports.MUSEUM_CASE_X - 85 -- 620
		end -- 620
		self.holstered = ____backendHolstered_15 -- 620
		local ____backendChildEcho_16 = backendChildEcho -- 621
		if ____backendChildEcho_16 == nil then -- 621
			____backendChildEcho_16 = self.hallWalkX >= ____exports.MUSEUM_CASE_X + 120 -- 621
		end -- 621
		self.childEchoPlayed = ____backendChildEcho_16 -- 621
		self.childEchoCountdown = -1 -- 622
		return -- 623
	end -- 623
	if phase == "lamp_turn" then -- 623
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or ____exports.MUSEUM_LAMP_X - 36 -- 626
		self.hallCamX = self.hallWalkX -- 627
		self.hallFacing = 1 -- 628
		self.holstered = true -- 629
		self.childEchoPlayed = true -- 630
		self.lampElapsed = 0 -- 631
		self.lineDawnShown = false -- 632
		self.knock1Played = false -- 633
		self.beginReturnSubmitted = false -- 634
		return -- 635
	end -- 635
	if phase == "return_cabinet" then -- 635
		self.returnElapsed = 0 -- 638
		self.knock2Played = false -- 639
		self.returnCompleteSubmitted = false -- 640
	end -- 640
end -- 604
function WellMuseumPlugin.prototype.evaluateGate(self, p, view) -- 644
	if p.run.trial ~= nil then -- 644
		return {open = false, reason = "trial_mode"} -- 646
	end -- 646
	if p.room.key ~= "prologue" then -- 646
		return {open = false, reason = "not_prologue"} -- 649
	end -- 649
	if p.phase ~= "prologue-wait" and p.phase ~= "prologue-well" then -- 649
		return {open = false, reason = "after_cabinet_window"} -- 652
	end -- 652
	if isPrologueIntroBlocking() then -- 652
		return {open = false, reason = "prologue_intro_active"} -- 655
	end -- 655
	if not view.archive.childCleared or not view.archive.soldierCleared then -- 655
		return {open = false, reason = "requires_both_clear"} -- 659
	end -- 659
	if view.archive.museumPhase == "locked" then -- 659
		return {open = false, reason = "phase_locked"} -- 662
	end -- 662
	return {open = true, reason = "ok"} -- 664
end -- 644
function WellMuseumPlugin.prototype.submitMuseumIntent(self, p, target) -- 667
	local contract = resolveRuntimeContract(self.injectedContract) -- 668
	if contract == nil then -- 668
		return false -- 670
	end -- 670
	local intent = {kind = "museumInteract", target = target} -- 672
	return contract:submitIntent(p, intent) -- 673
end -- 667
function WellMuseumPlugin.prototype.syncLoops(self, ctx, wantWellDrip, dripVolume, wantHallAmbience) -- 676
	if wantWellDrip then -- 676
		ctx.audio:playLoop( -- 678
			LOOP_WELL_DRIP, -- 678
			"water", -- 678
			____exports.MUSEUM_AUDIO.wellDripLoop, -- 678
			dripVolume, -- 678
			ctx.p.ticks -- 678
		) -- 678
		self.wellDripPlaying = true -- 679
	elseif self.wellDripPlaying then -- 679
		ctx.audio:stopLoop(LOOP_WELL_DRIP) -- 681
		self.wellDripPlaying = false -- 682
	end -- 682
	if wantHallAmbience then -- 682
		ctx.audio:playLoop( -- 686
			LOOP_HALL_AMBIENCE, -- 686
			"ambience", -- 686
			____exports.MUSEUM_AUDIO.hallAmbienceLoop, -- 686
			0.34, -- 686
			ctx.p.ticks -- 686
		) -- 686
		self.hallAmbiencePlaying = true -- 687
	elseif self.hallAmbiencePlaying then -- 687
		ctx.audio:stopLoop(LOOP_HALL_AMBIENCE) -- 689
		self.hallAmbiencePlaying = false -- 690
	end -- 690
end -- 676
function WellMuseumPlugin.prototype.update(self, ctx) -- 694
	self:syncRuntimeHook() -- 695
	local p = ctx.p -- 696
	local view = ctx.view -- 697
	local phase = view.archive.museumPhase -- 698
	if view.isRehearsal ~= self.rehearsal then -- 698
		self:syncLoops(ctx, false, 0, false) -- 700
		self:onBindPlay(p, view) -- 701
	end -- 701
	self.roomSessionId = ctx.events.roomSessionId -- 703
	self.lastVisualMode = view.visualMode -- 704
	self.lastPaused = ctx.paused -- 705
	self.wellAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 708
	self.wellAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 709
	self.glassAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 710
	self.glassAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 711
	local sim = self.simInput -- 714
	self.simInput = nil -- 715
	local interactPressed = ctx.input.interact.pressed or sim ~= nil and sim.interact == true -- 716
	local moveX = sim ~= nil and sim.moveX ~= nil and sim.moveX or ctx.input.moveX -- 717
	if phase ~= self.prevPhase then -- 717
		local wasActive = isActiveMuseumPhase(self.prevPhase) -- 721
		self.prevPhase = phase -- 722
		if isActiveMuseumPhase(phase) then -- 722
			if phase == "well_reflect" then -- 722
				self:resetPhaseTimersForEntry("well_reflect") -- 725
				if view.archive.artifactOwned and self.artifactGrantCount < 1 then -- 725
					self.artifactGrantCount = 1 -- 727
				end -- 727
			elseif phase == "hall_walk" and not wasActive then -- 727
				self:resetPhaseTimersForEntry("hall_walk") -- 730
			elseif phase == "hall_walk" and wasActive then -- 730
				self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 732
				self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 733
				self.hallFacing = 1 -- 734
				self.hallIntroElapsed = 0 -- 735
				self.holstered = false -- 736
				self.childEchoPlayed = false -- 737
				self.childEchoCountdown = -1 -- 738
			elseif phase == "lamp_turn" then -- 738
				self:resetPhaseTimersForEntry("lamp_turn", self.hallWalkX, true, self.childEchoPlayed) -- 740
			elseif phase == "return_cabinet" then -- 740
				self:resetPhaseTimersForEntry("return_cabinet") -- 742
			end -- 742
		elseif phase == "done" then -- 742
			self.savedResume = nil -- 745
		end -- 745
	end -- 745
	local gate = self:evaluateGate(p, view) -- 749
	self.gateOpen = gate.open -- 750
	self.gateBlockedReason = gate.reason -- 751
	self.nearWell = gate.open and math.abs(p.player.x - self.wellWorldX) <= ____exports.WELL_INTERACT_REACH -- 752
	if ctx.paused then -- 752
		return -- 756
	end -- 756
	local wdt = math.max(0, ctx.worldDt) -- 759
	local udt = math.max(0, ctx.uiDt) -- 760
	self.animTime = self.animTime + wdt -- 761
	if self.revisitCalmTimer > 0 then -- 761
		self.revisitCalmTimer = math.max(0, self.revisitCalmTimer - wdt) -- 764
	end -- 764
	if self.childEchoVisualT > 0 then -- 764
		self.childEchoVisualT = math.max(0, self.childEchoVisualT - udt) -- 767
	end -- 767
	if self.knock1VisualT > 0 then -- 767
		self.knock1VisualT = math.max(0, self.knock1VisualT - wdt) -- 770
	end -- 770
	if self.knock2VisualT > 0 then -- 770
		self.knock2VisualT = math.max(0, self.knock2VisualT - wdt) -- 773
	end -- 773
	if view.visualMode ~= "museum" then -- 773
		local wantDrip = gate.open and phase == "well_open" and not view.archive.museumSeen -- 778
		local dist = math.abs(p.player.x - self.wellWorldX) -- 779
		local dripVol = clamp(0.46 - dist * 0.0014, 0.08, 0.46) -- 780
		self:syncLoops(ctx, wantDrip, dripVol, false) -- 781
		if gate.open and self.nearWell and interactPressed then -- 781
			local alreadyAwarded = view.archive.museumSeen or phase == "done" or view.archive.artifactOwned and self.artifactGrantCount >= 1 -- 784
			if phase == "well_open" and not alreadyAwarded then -- 784
				self:submitMuseumIntent(p, "well_pickup") -- 788
			else -- 788
				self.revisitCalmTimer = 1.4 -- 791
				self.revisitCalmCount = self.revisitCalmCount + 1 -- 792
			end -- 792
		end -- 792
		return -- 795
	end -- 795
	local effectivePhase = p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 799
	if effectivePhase == "well_reflect" then -- 799
		local dripVol = clamp( -- 804
			0.44 * (1 - smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, self.reflectElapsed)), -- 804
			0, -- 804
			0.44 -- 804
		) -- 804
		self:syncLoops(ctx, dripVol > 0.03, dripVol, false) -- 805
		if wdt > 0 then -- 805
			self.reflectElapsed = self.reflectElapsed + wdt -- 808
		end -- 808
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 808
			if self.artifactGrantCount < 1 then -- 808
				self.artifactGrantCount = 1 -- 812
			end -- 812
			ctx.audio:playOnce( -- 814
				"fe06:e01:pickup:" .. tostring(self.roomSessionId), -- 815
				"sfx", -- 816
				____exports.MUSEUM_AUDIO.artifactPickup, -- 817
				0.86, -- 818
				"museum:e01:artifact_pickup", -- 819
				p.ticks -- 820
			) -- 820
		end -- 820
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellMatchCutStart then -- 820
			ctx.audio:playOnce( -- 824
				"fe06:e01:matchcut:" .. tostring(self.roomSessionId), -- 825
				"ambience", -- 826
				____exports.MUSEUM_AUDIO.matchCutTransition, -- 827
				0.78, -- 828
				"museum:e01:match_cut", -- 829
				p.ticks -- 830
			) -- 830
		end -- 830
		self.savedResume = self:exportResumeState() -- 833
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellReflectDuration and not self.enterHallSubmitted then -- 833
			self.enterHallSubmitted = true -- 835
			if p.room.key == "museum" then -- 835
				self.liveReflectDoneInMuseumRoom = true -- 837
			end -- 837
			self:submitMuseumIntent(p, "enter_hall") -- 839
			local contract = resolveRuntimeContract(self.injectedContract) -- 840
			if contract ~= nil and contract:isRehearsal() then -- 840
				contract:enterMockMuseum("hall_walk") -- 842
			end -- 842
		end -- 842
		return -- 845
	end -- 845
	if effectivePhase == "hall_walk" then -- 845
		self:syncLoops(ctx, false, 0, true) -- 850
		self.hallIntroElapsed = self.hallIntroElapsed + udt -- 851
		local ____view_isRehearsal_17 -- 855
		if view.isRehearsal then -- 855
			____view_isRehearsal_17 = nil -- 855
		else -- 855
			____view_isRehearsal_17 = asRecord(p) -- 855
		end -- 855
		local pRec = ____view_isRehearsal_17 -- 855
		local backendWalkX = readNum(pRec, "museumWalkX") or (not view.isRehearsal and p.room.key == "museum" and p.player.x - p.ox or nil) -- 856
		self.hallMoving = false -- 858
		local previousX = self.hallWalkX -- 859
		if backendWalkX ~= nil then -- 859
			self.hallWalkX = clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 861
		elseif udt > 0 and math.abs(moveX) > 0.05 then -- 861
			self.hallWalkX = clamp(self.hallWalkX + moveX * ____exports.MUSEUM_WALK_SPEED * udt, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 863
		end -- 863
		local delta = self.hallWalkX - previousX -- 865
		if math.abs(delta) > 0.01 then -- 865
			self.hallFacing = delta >= 0 and 1 or -1 -- 867
			self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 868
			self.hallMoving = true -- 869
			self.hallFootstepTimer = self.hallFootstepTimer + udt -- 870
			if self.hallFootstepTimer >= 0.46 then -- 870
				self.hallFootstepTimer = 0 -- 872
				ctx.audio:playOnce( -- 873
					(("fe06:e02:step:" .. tostring(self.roomSessionId)) .. ":") .. tostring(math.floor(self.hallWalkAnim * 2)), -- 874
					"sfx", -- 875
					____exports.MUSEUM_AUDIO.hallFootstep, -- 876
					0.46, -- 877
					"museum:e02:footstep", -- 878
					p.ticks -- 879
				) -- 879
			end -- 879
		else -- 879
			self.hallFootstepTimer = math.min(self.hallFootstepTimer, 0.22) -- 883
		end -- 883
		local camFollow = math.min(1, udt * 5.2) -- 887
		self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * camFollow -- 888
		if not self.holstered and self.hallWalkX >= ____exports.MUSEUM_CASE_X - 85 then -- 888
			self.holstered = true -- 892
			ctx.audio:playOnce( -- 893
				"fe06:e02:holster:" .. tostring(self.roomSessionId), -- 894
				"sfx", -- 895
				____exports.MUSEUM_AUDIO.weaponHolster, -- 896
				0.76, -- 897
				"museum:e02:weapon_holster", -- 898
				p.ticks -- 899
			) -- 899
			if not self.childEchoPlayed then -- 899
				self.childEchoCountdown = ____exports.MUSEUM_TIMINGS.childEchoDelay -- 902
			end -- 902
		end -- 902
		if self.childEchoCountdown >= 0 and not self.childEchoPlayed then -- 902
			self.childEchoCountdown = self.childEchoCountdown - udt -- 907
			if self.childEchoCountdown <= 0 then -- 907
				self.childEchoCountdown = -1 -- 909
				self.childEchoPlayed = true -- 910
				self.childEchoVisualT = 2.1 -- 911
				ctx.audio:playOnce( -- 912
					"fe06:e02:child_echo:" .. tostring(self.roomSessionId), -- 913
					"sfx", -- 914
					____exports.MUSEUM_AUDIO.childStepsEcho, -- 915
					0.72, -- 916
					"museum:e02:child_steps_echo", -- 917
					p.ticks -- 918
				) -- 918
			end -- 918
		end -- 918
		self.nearLamp = math.abs(self.hallWalkX - ____exports.MUSEUM_LAMP_X) <= 72 -- 923
		self.savedResume = self:exportResumeState() -- 924
		if self.nearLamp and interactPressed then -- 924
			self:submitMuseumIntent(p, "lamp_turn") -- 927
		end -- 927
		return -- 929
	end -- 929
	if effectivePhase == "lamp_turn" then -- 929
		self:syncLoops(ctx, false, 0, true) -- 934
		if wdt > 0 then -- 934
			self.lampElapsed = self.lampElapsed + wdt -- 936
		end -- 936
		if p.room.key == "museum" then -- 936
			local targetX = clamp(p.player.x - p.ox, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 940
			local delta = targetX - self.hallWalkX -- 941
			self.hallMoving = math.abs(delta) > 0.25 -- 942
			if self.hallMoving then -- 942
				self.hallFacing = delta >= 0 and 1 or -1 -- 944
				self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 945
			end -- 945
			self.hallWalkX = targetX -- 947
			self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * math.min(1, udt * 5.2) -- 948
		end -- 948
		ctx.audio:playOnce( -- 950
			"fe06:e02:lamp_turn:" .. tostring(self.roomSessionId), -- 951
			"sfx", -- 952
			____exports.MUSEUM_AUDIO.lampTurn, -- 953
			0.82, -- 954
			"museum:e02:lamp_turn", -- 955
			p.ticks -- 956
		) -- 956
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 956
			self.lineDawnShown = true -- 959
			ctx.audio:playOnce( -- 960
				"fe06:e02:line_dawn:" .. tostring(self.roomSessionId), -- 961
				"voice", -- 962
				____exports.MUSEUM_AUDIO.lineDawn, -- 963
				0.92, -- 964
				"museum:e02:line_dawn", -- 965
				p.ticks -- 966
			) -- 966
		end -- 966
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampKnock1At and not self.knock1Played then -- 966
			self.knock1Played = true -- 970
			self.knock1VisualT = 0.85 -- 971
			ctx.audio:playOnce( -- 972
				"fe06:e02:knock1:" .. tostring(self.roomSessionId), -- 973
				"sfx", -- 974
				____exports.MUSEUM_AUDIO.knockHallFirst, -- 975
				0.88, -- 976
				"museum:knock:1", -- 977
				p.ticks -- 978
			) -- 978
		end -- 978
		self.savedResume = self:exportResumeState() -- 981
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampTurnDuration and not self.beginReturnSubmitted then -- 981
			self.beginReturnSubmitted = true -- 984
			self:submitMuseumIntent(p, "begin_return_cabinet") -- 985
			local contract = resolveRuntimeContract(self.injectedContract) -- 986
			if contract ~= nil and contract:isRehearsal() then -- 986
				contract:enterMockMuseum("return_cabinet") -- 988
			end -- 988
		end -- 988
		return -- 991
	end -- 991
	if phase == "return_cabinet" then -- 991
		self:syncLoops(ctx, false, 0, false) -- 996
		if wdt > 0 then -- 996
			self.returnElapsed = self.returnElapsed + wdt -- 998
		end -- 998
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnKnock2At and not self.knock2Played then -- 998
			self.knock2Played = true -- 1001
			self.knock2VisualT = 0.9 -- 1002
			ctx.audio:playOnce( -- 1003
				"fe06:e02:knock2:" .. tostring(self.roomSessionId), -- 1004
				"sfx", -- 1005
				____exports.MUSEUM_AUDIO.knockCabinetSecond, -- 1006
				0.92, -- 1007
				"museum:knock:2", -- 1008
				p.ticks -- 1009
			) -- 1009
		end -- 1009
		self.savedResume = self:exportResumeState() -- 1012
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnCabinetDuration and not self.returnCompleteSubmitted then -- 1012
			self.returnCompleteSubmitted = true -- 1015
			self:submitMuseumIntent(p, "return_cabinet") -- 1016
		end -- 1016
	end -- 1016
end -- 694
function WellMuseumPlugin.prototype.drawBackdrop(self, bgDraw, _bgGlow, _backdropArt, ctx) -- 1021
	if ctx.view.visualMode ~= "museum" then -- 1021
		return false -- 1028
	end -- 1028
	bgDraw:drawRect( -- 1031
		Rect(0, 0, ctx.w, ctx.h), -- 1031
		Color(11, 13, 18, 255) -- 1031
	) -- 1031
	return true -- 1032
end -- 1021
function WellMuseumPlugin.prototype.drawWorld(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1035
	return ctx.view.visualMode == "museum" -- 1041
end -- 1035
function WellMuseumPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1044
	return ctx.view.visualMode == "museum" -- 1050
end -- 1044
function WellMuseumPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 1056
	if not self.gateOpen or ctx.view.visualMode == "museum" then -- 1056
		return -- 1063
	end -- 1063
	local cam = ctx.cam -- 1065
	local wellCx = cam:sx(self.wellWorldX) -- 1066
	local groundY = cam:sy(0, 0) -- 1067
	local phase = ctx.view.archive.museumPhase -- 1068
	local activeLure = phase == "well_open" and not ctx.view.archive.museumSeen -- 1069
	local archW = cam:len(68) -- 1072
	local archH = cam:len(96) -- 1073
	local archX = wellCx - archW * 0.54 -- 1074
	fillVGradRect( -- 1075
		fgDraw, -- 1076
		archX, -- 1077
		groundY, -- 1078
		archW, -- 1079
		archH, -- 1080
		Color(12, 16, 22, 232), -- 1081
		Color(18, 24, 34, 212) -- 1082
	) -- 1082
	fgDraw:drawRect( -- 1085
		Rect(archX - 4, groundY, 6, archH), -- 1085
		Color(48, 54, 62, 240) -- 1085
	) -- 1085
	fgDraw:drawRect( -- 1086
		Rect(archX + archW - 2, groundY, 6, archH), -- 1086
		Color(48, 54, 62, 240) -- 1086
	) -- 1086
	fgDraw:drawRect( -- 1087
		Rect(archX - 6, groundY + archH - 8, archW + 12, 10), -- 1087
		Color(62, 68, 76, 245) -- 1087
	) -- 1087
	local rimW = cam:len(38) -- 1090
	local rimH = cam:len(22) -- 1091
	local rimX = wellCx - rimW * 0.5 -- 1092
	fgDraw:drawRect( -- 1093
		Rect(rimX, groundY, rimW, rimH), -- 1094
		Color(46, 52, 60, 250), -- 1095
		1.2, -- 1096
		Color(102, 110, 120, 215) -- 1097
	) -- 1097
	fgDraw:drawEllipse( -- 1100
		Vec2(wellCx, groundY + rimH), -- 1100
		rimW * 0.52, -- 1100
		cam:len(5.5), -- 1100
		Color(74, 82, 92, 250) -- 1100
	) -- 1100
	fgDraw:drawEllipse( -- 1101
		Vec2(wellCx, groundY + rimH), -- 1101
		rimW * 0.38, -- 1101
		cam:len(3.8), -- 1101
		Color(8, 12, 18, 255) -- 1101
	) -- 1101
	local dripCycle = self.animTime * 0.58 % 1 -- 1104
	local rippleR = cam:len(3 + dripCycle * 11) -- 1105
	local rippleAlpha = math.floor((1 - dripCycle) * (activeLure and 155 or 42) + 0.5) -- 1106
	if activeLure then -- 1106
		local shimmer = 0.65 + 0.35 * math.sin(self.animTime * 2.9) -- 1108
		fgDraw:drawCircle( -- 1110
			Vec2(wellCx, groundY + rimH), -- 1110
			cam:len(2.8), -- 1110
			Color( -- 1110
				236, -- 1110
				244, -- 1110
				252, -- 1110
				math.floor(215 * shimmer + 0.5) -- 1110
			) -- 1110
		) -- 1110
		drawEllipseRing( -- 1111
			fgDraw, -- 1111
			wellCx, -- 1111
			groundY + rimH, -- 1111
			rippleR, -- 1111
			rippleR * 0.36, -- 1111
			Color(0, 0, 0, 0), -- 1111
			1.1, -- 1111
			Color(210, 226, 242, rippleAlpha), -- 1111
			24 -- 1111
		) -- 1111
		fillRadialGlow( -- 1112
			fgGlow, -- 1113
			wellCx, -- 1114
			groundY + rimH + cam:len(8), -- 1115
			cam:len(30), -- 1116
			cam:len(38), -- 1117
			Color( -- 1118
				206, -- 1118
				224, -- 1118
				244, -- 1118
				math.floor(52 * shimmer + 0.5) -- 1118
			), -- 1118
			Color(148, 178, 212, 0), -- 1119
			16 -- 1120
		) -- 1120
		if dripCycle < 0.24 then -- 1120
			local dropK = dripCycle / 0.24 -- 1124
			local dropY = groundY + archH * 0.72 - dropK * (archH * 0.72 - rimH) -- 1125
			fgDraw:drawSegment( -- 1126
				Vec2(wellCx, dropY), -- 1127
				Vec2( -- 1128
					wellCx, -- 1128
					dropY + cam:len(4.5) -- 1128
				), -- 1128
				1.4, -- 1129
				Color(214, 228, 244, 185) -- 1130
			) -- 1130
		end -- 1130
	elseif self.revisitCalmTimer > 0 then -- 1130
		local calmK = 1 - clamp01(self.revisitCalmTimer / 1.4) -- 1135
		local calmR = cam:len(3 + calmK * 10) -- 1136
		drawEllipseRing( -- 1137
			fgDraw, -- 1138
			wellCx, -- 1139
			groundY + rimH, -- 1140
			calmR, -- 1141
			calmR * 0.35, -- 1142
			Color(0, 0, 0, 0), -- 1143
			1, -- 1144
			Color( -- 1145
				148, -- 1145
				160, -- 1145
				172, -- 1145
				math.floor((1 - calmK) * 120 + 0.5) -- 1145
			), -- 1145
			24 -- 1146
		) -- 1146
	end -- 1146
end -- 1056
function WellMuseumPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1156
	local view = ctx.view -- 1163
	local phase = view.archive.museumPhase -- 1164
	if view.visualMode ~= "museum" then -- 1164
		if self.gateOpen and self.nearWell and view.assistHintsEnabled and phase == "well_open" and not view.archive.museumSeen then -- 1164
			local sx = ctx.cam:sx(self.wellWorldX) / ctx.uiScale -- 1169
			local sy = (ctx.cam:sy(0, 0) + ctx.cam:len(54)) / ctx.uiScale -- 1170
			drawSilkVeil( -- 1171
				uiDraw, -- 1171
				uiArt, -- 1171
				"fe06_well_hint_veil", -- 1171
				sx, -- 1171
				sy, -- 1171
				132, -- 1171
				26, -- 1171
				PALETTE.panelBg, -- 1171
				0.82, -- 1171
				1 -- 1171
			) -- 1171
			ctx.texts:put( -- 1172
				"xs", -- 1173
				"[E] 俯身看井", -- 1174
				sx, -- 1175
				sy, -- 1176
				toColor(PALETTE.textBright), -- 1177
				0.5, -- 1178
				0.5, -- 1179
				"Center", -- 1180
				0.6, -- 1181
				0.92 -- 1182
			) -- 1182
		end -- 1182
		return false -- 1185
	end -- 1185
	local w = ctx.uiW -- 1188
	local h = ctx.uiH -- 1189
	local effectivePhase = ctx.p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 1191
	if effectivePhase == "well_reflect" then -- 1191
		self:renderE01WellReflectMatchCut( -- 1196
			uiDraw, -- 1196
			uiInkDraw, -- 1196
			uiArt, -- 1196
			uiGlow, -- 1196
			ctx, -- 1196
			w, -- 1196
			h -- 1196
		) -- 1196
		return true -- 1197
	end -- 1197
	if effectivePhase == "hall_walk" then -- 1197
		self:renderE02MuseumHall( -- 1200
			uiDraw, -- 1200
			uiInkDraw, -- 1200
			uiArt, -- 1200
			uiGlow, -- 1200
			ctx, -- 1200
			w, -- 1200
			h, -- 1200
			0, -- 1200
			false -- 1200
		) -- 1200
		return true -- 1201
	end -- 1201
	if effectivePhase == "lamp_turn" then -- 1201
		local turnProg = smoothstep(0, 1.15, self.lampElapsed) -- 1204
		self:renderE02MuseumHall( -- 1205
			uiDraw, -- 1205
			uiInkDraw, -- 1205
			uiArt, -- 1205
			uiGlow, -- 1205
			ctx, -- 1205
			w, -- 1205
			h, -- 1205
			turnProg, -- 1205
			true -- 1205
		) -- 1205
		return true -- 1206
	end -- 1206
	if effectivePhase == "return_cabinet" then -- 1206
		self:renderE02ReturnCabinet( -- 1209
			uiDraw, -- 1209
			uiInkDraw, -- 1209
			uiArt, -- 1209
			uiGlow, -- 1209
			ctx, -- 1209
			w, -- 1209
			h -- 1209
		) -- 1209
		return true -- 1210
	end -- 1210
	return false -- 1212
end -- 1156
function WellMuseumPlugin.prototype.renderE01WellReflectMatchCut(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1218
	local t = self.reflectElapsed -- 1227
	local ax = self.wellAnchorX -- 1228
	local ay = self.wellAnchorY -- 1229
	local matchK = smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, t) -- 1230
	local wellAlpha = 1 - matchK -- 1231
	fillVGradRect( -- 1234
		uiDraw, -- 1235
		0, -- 1236
		0, -- 1237
		w, -- 1238
		h, -- 1239
		Color( -- 1240
			math.floor(8 + 14 * matchK + 0.5), -- 1241
			math.floor(10 + 16 * matchK + 0.5), -- 1242
			math.floor(15 + 20 * matchK + 0.5), -- 1243
			255 -- 1244
		), -- 1244
		Color( -- 1246
			math.floor(14 + 22 * matchK + 0.5), -- 1247
			math.floor(18 + 26 * matchK + 0.5), -- 1248
			math.floor(26 + 30 * matchK + 0.5), -- 1249
			255 -- 1250
		) -- 1250
	) -- 1250
	if wellAlpha > 0.01 then -- 1250
		local wellR = math.min(w, h) * (0.31 + matchK * 0.24) -- 1256
		uiDraw:drawCircle( -- 1258
			Vec2(ax, ay), -- 1258
			wellR + 36, -- 1258
			Color( -- 1258
				30, -- 1258
				35, -- 1258
				42, -- 1258
				math.floor(240 * wellAlpha + 0.5) -- 1258
			) -- 1258
		) -- 1258
		uiDraw:drawCircle( -- 1259
			Vec2(ax, ay), -- 1259
			wellR + 14, -- 1259
			Color( -- 1259
				20, -- 1259
				24, -- 1259
				30, -- 1259
				math.floor(250 * wellAlpha + 0.5) -- 1259
			) -- 1259
		) -- 1259
		uiDraw:drawCircle( -- 1261
			Vec2(ax, ay), -- 1261
			wellR, -- 1261
			Color( -- 1261
				7, -- 1261
				11, -- 1261
				17, -- 1261
				math.floor(255 * wellAlpha + 0.5) -- 1261
			) -- 1261
		) -- 1261
		local ri = 0 -- 1264
		do -- 1264
			ri = 0 -- 1265
			while ri < 3 do -- 1265
				local cyc = (t * 0.42 + ri * 0.33) % 1 -- 1266
				local r = 20 + cyc * (wellR * 0.85) -- 1267
				local ra = math.floor((1 - cyc) * 90 * wellAlpha + 0.5) -- 1268
				drawCircleRing( -- 1269
					uiInkDraw, -- 1269
					ax, -- 1269
					ay, -- 1269
					r, -- 1269
					Color(0, 0, 0, 0), -- 1269
					1.1, -- 1269
					Color(176, 198, 222, ra), -- 1269
					32 -- 1269
				) -- 1269
				ri = ri + 1 -- 1265
			end -- 1265
		end -- 1265
		local compassSlide = smoothstep(0.15, 0.95, t) -- 1273
		local compX = ax + (1 - compassSlide) * 140 -- 1274
		local compY = ay - (1 - compassSlide) * 90 -- 1275
		local compR = 62 -- 1276
		drawCircleRing( -- 1278
			uiInkDraw, -- 1279
			compX, -- 1280
			compY, -- 1281
			compR + 8, -- 1282
			Color( -- 1283
				98, -- 1283
				78, -- 1283
				48, -- 1283
				math.floor(218 * wellAlpha + 0.5) -- 1283
			), -- 1283
			2, -- 1284
			Color( -- 1285
				186, -- 1285
				154, -- 1285
				102, -- 1285
				math.floor(235 * wellAlpha + 0.5) -- 1285
			), -- 1285
			32 -- 1286
		) -- 1286
		drawCircleRing( -- 1289
			uiInkDraw, -- 1290
			compX, -- 1291
			compY, -- 1292
			compR, -- 1293
			Color( -- 1294
				16, -- 1294
				24, -- 1294
				36, -- 1294
				math.floor(145 * wellAlpha + 0.5) -- 1294
			), -- 1294
			1.2, -- 1295
			Color( -- 1296
				218, -- 1296
				226, -- 1296
				236, -- 1296
				math.floor(180 * wellAlpha + 0.5) -- 1296
			), -- 1296
			32 -- 1297
		) -- 1297
		uiInkDraw:drawSegment( -- 1300
			Vec2(compX, compY + compR - 6), -- 1300
			Vec2(compX, compY + compR - 18), -- 1300
			1.6, -- 1300
			Color( -- 1300
				224, -- 1300
				206, -- 1300
				168, -- 1300
				math.floor(190 * wellAlpha + 0.5) -- 1300
			) -- 1300
		) -- 1300
		uiInkDraw:drawSegment( -- 1301
			Vec2(compX, compY - compR + 6), -- 1301
			Vec2(compX, compY - compR + 18), -- 1301
			1.4, -- 1301
			Color( -- 1301
				168, -- 1301
				174, -- 1301
				182, -- 1301
				math.floor(165 * wellAlpha + 0.5) -- 1301
			) -- 1301
		) -- 1301
		uiInkDraw:drawSegment( -- 1302
			Vec2(compX - compR + 6, compY), -- 1302
			Vec2(compX - compR + 18, compY), -- 1302
			1.4, -- 1302
			Color( -- 1302
				168, -- 1302
				174, -- 1302
				182, -- 1302
				math.floor(165 * wellAlpha + 0.5) -- 1302
			) -- 1302
		) -- 1302
		uiInkDraw:drawSegment( -- 1303
			Vec2(compX + compR - 6, compY), -- 1303
			Vec2(compX + compR - 18, compY), -- 1303
			1.4, -- 1303
			Color( -- 1303
				168, -- 1303
				174, -- 1303
				182, -- 1303
				math.floor(165 * wellAlpha + 0.5) -- 1303
			) -- 1303
		) -- 1303
		local needleAng = -0.35 + math.sin(t * 2.2) * 0.08 * (1 - matchK) -- 1305
		local nx = math.cos(needleAng) * 34 -- 1306
		local ny = math.sin(needleAng) * 34 -- 1307
		uiInkDraw:drawSegment( -- 1308
			Vec2(compX, compY), -- 1308
			Vec2(compX + nx, compY + ny), -- 1308
			2.2, -- 1308
			Color( -- 1308
				208, -- 1308
				92, -- 1308
				82, -- 1308
				math.floor(215 * wellAlpha + 0.5) -- 1308
			) -- 1308
		) -- 1308
		uiInkDraw:drawSegment( -- 1309
			Vec2(compX, compY), -- 1309
			Vec2(compX - nx * 0.85, compY - ny * 0.85), -- 1309
			1.8, -- 1309
			Color( -- 1309
				214, -- 1309
				222, -- 1309
				232, -- 1309
				math.floor(185 * wellAlpha + 0.5) -- 1309
			) -- 1309
		) -- 1309
		if t >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 1309
			local pickK = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellMatchCutStart, t) -- 1313
			local liftY = ay + pickK * 14 -- 1314
			drawCircleRing( -- 1315
				uiInkDraw, -- 1316
				ax, -- 1317
				liftY, -- 1318
				24 + pickK * 12, -- 1319
				Color(0, 0, 0, 0), -- 1320
				1.6, -- 1321
				Color( -- 1322
					226, -- 1322
					204, -- 1322
					152, -- 1322
					math.floor(215 * (1 - matchK * 0.65) + 0.5) -- 1322
				), -- 1322
				28 -- 1323
			) -- 1323
			local capA = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellPickupAt + 0.35, t) * (1 - matchK) -- 1326
			if capA > 0.03 then -- 1326
				drawSilkVeil( -- 1328
					uiDraw, -- 1328
					uiArt, -- 1328
					"fe06_pickup_veil", -- 1328
					w * 0.5, -- 1328
					96, -- 1328
					300, -- 1328
					34, -- 1328
					PALETTE.inkVoid, -- 1328
					0.78 * capA, -- 1328
					1 -- 1328
				) -- 1328
				ctx.texts:put( -- 1329
					"sm", -- 1330
					"拾起「时间穿梭器」", -- 1331
					w * 0.5, -- 1332
					96, -- 1333
					toColor(PALETTE.amberCore), -- 1334
					0.5, -- 1335
					0.5, -- 1336
					"Center", -- 1337
					1.4, -- 1338
					capA -- 1339
				) -- 1339
			end -- 1339
		end -- 1339
	end -- 1339
	if matchK > 0.01 then -- 1339
		local caseW = 300 -- 1347
		local caseH = 276 -- 1348
		local caseX = self.glassAnchorX - caseW * 0.5 -- 1349
		local caseY = self.glassAnchorY - caseH * 0.54 -- 1350
		uiDraw:drawRect( -- 1352
			Rect(caseX - 80, caseY - 110, caseW + 160, caseH + 220), -- 1352
			Color( -- 1352
				24, -- 1352
				29, -- 1352
				36, -- 1352
				math.floor(190 * matchK + 0.5) -- 1352
			) -- 1352
		) -- 1352
		uiDraw:drawRect( -- 1353
			Rect(caseX, caseY, caseW, caseH), -- 1354
			Color( -- 1355
				18, -- 1355
				23, -- 1355
				30, -- 1355
				math.floor(220 * matchK + 0.5) -- 1355
			), -- 1355
			1.6, -- 1356
			Color( -- 1357
				164, -- 1357
				178, -- 1357
				194, -- 1357
				math.floor(185 * matchK + 0.5) -- 1357
			) -- 1357
		) -- 1357
		fillGradQuad( -- 1360
			uiInkDraw, -- 1361
			self.glassAnchorX - 42, -- 1362
			caseY + caseH - 6, -- 1362
			Color( -- 1362
				224, -- 1362
				236, -- 1362
				248, -- 1362
				math.floor(44 * matchK + 0.5) -- 1362
			), -- 1362
			self.glassAnchorX + 24, -- 1363
			caseY + caseH - 6, -- 1363
			Color( -- 1363
				238, -- 1363
				246, -- 1363
				255, -- 1363
				math.floor(78 * matchK + 0.5) -- 1363
			), -- 1363
			self.glassAnchorX - 18, -- 1364
			caseY + 6, -- 1364
			Color( -- 1364
				224, -- 1364
				236, -- 1364
				248, -- 1364
				math.floor(24 * matchK + 0.5) -- 1364
			), -- 1364
			self.glassAnchorX - 82, -- 1365
			caseY + 6, -- 1365
			Color(224, 236, 248, 0) -- 1365
		) -- 1365
		uiArt:tryPlace( -- 1368
			"prop_compass", -- 1368
			"fe06_match_compass", -- 1368
			self.glassAnchorX, -- 1368
			caseY + 72, -- 1368
			46, -- 1368
			46, -- 1368
			{opacity = matchK * 0.85, layer = 3} -- 1368
		) -- 1368
	end -- 1368
	local flashPeak = math.sin(matchK * math.pi) -- 1375
	local coreR = 8 + flashPeak * 18 -- 1376
	uiInkDraw:drawCircle( -- 1377
		Vec2(ax, ay), -- 1377
		coreR * 0.55, -- 1377
		Color(248, 252, 255, 248) -- 1377
	) -- 1377
	fillRadialGlow( -- 1378
		uiGlow, -- 1379
		ax, -- 1380
		ay, -- 1381
		52 + flashPeak * 145, -- 1382
		46 + flashPeak * 115, -- 1383
		Color( -- 1384
			238, -- 1384
			246, -- 1384
			255, -- 1384
			math.floor(145 + flashPeak * 95 + 0.5) -- 1384
		), -- 1384
		Color(174, 204, 238, 0), -- 1385
		20 -- 1386
	) -- 1386
	if flashPeak > 0.05 then -- 1386
		local rayW = 70 + flashPeak * 260 -- 1390
		fillHGradRect( -- 1391
			uiGlow, -- 1391
			ax - rayW, -- 1391
			ay - 2, -- 1391
			rayW, -- 1391
			4, -- 1391
			Color(224, 238, 252, 0), -- 1391
			Color( -- 1391
				242, -- 1391
				248, -- 1391
				255, -- 1391
				math.floor(160 * flashPeak + 0.5) -- 1391
			) -- 1391
		) -- 1391
		fillHGradRect( -- 1392
			uiGlow, -- 1392
			ax, -- 1392
			ay - 2, -- 1392
			rayW, -- 1392
			4, -- 1392
			Color( -- 1392
				242, -- 1392
				248, -- 1392
				255, -- 1392
				math.floor(160 * flashPeak + 0.5) -- 1392
			), -- 1392
			Color(224, 238, 252, 0) -- 1392
		) -- 1392
	end -- 1392
	self:drawLetterbox( -- 1395
		uiInkDraw, -- 1395
		w, -- 1395
		h, -- 1395
		42, -- 1395
		0.92 -- 1395
	) -- 1395
end -- 1218
function WellMuseumPlugin.prototype.renderE02MuseumHall(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, lampTurnProg, inLampTurn) -- 1401
	local floorY = 148 -- 1412
	local wallTopY = h - 86 -- 1413
	local halfW = w * 0.5 -- 1414
	local camMin = math.min(____exports.MUSEUM_HALL_WIDTH * 0.5, halfW - 40) -- 1415
	local camMax = math.max(____exports.MUSEUM_HALL_WIDTH * 0.5, ____exports.MUSEUM_HALL_WIDTH - halfW + 40) -- 1416
	local camX = clamp(self.hallCamX, camMin, camMax) -- 1417
	local function toScreenX(hx) -- 1418
		return halfW + (hx - camX) -- 1418
	end -- 1418
	fillVGradRect( -- 1421
		uiDraw, -- 1421
		0, -- 1421
		floorY, -- 1421
		w, -- 1421
		h - floorY, -- 1421
		Color(26, 31, 38, 255), -- 1421
		Color(16, 20, 26, 255) -- 1421
	) -- 1421
	uiDraw:drawRect( -- 1423
		Rect(0, wallTopY, w, h - wallTopY), -- 1423
		Color(11, 14, 19, 255) -- 1423
	) -- 1423
	local px = 0 -- 1425
	do -- 1425
		px = 40 -- 1426
		while px <= ____exports.MUSEUM_HALL_WIDTH do -- 1426
			local sx = toScreenX(px) -- 1427
			if sx >= -20 and sx <= w + 20 then -- 1427
				uiDraw:drawSegment( -- 1429
					Vec2(sx, floorY), -- 1429
					Vec2(sx, wallTopY), -- 1429
					1, -- 1429
					Color(38, 45, 54, 130) -- 1429
				) -- 1429
			end -- 1429
			px = px + 140 -- 1426
		end -- 1426
	end -- 1426
	fillVGradRect( -- 1433
		uiDraw, -- 1433
		0, -- 1433
		0, -- 1433
		w, -- 1433
		floorY, -- 1433
		Color(14, 17, 22, 255), -- 1433
		Color(32, 37, 45, 255) -- 1433
	) -- 1433
	uiDraw:drawSegment( -- 1434
		Vec2(0, floorY), -- 1434
		Vec2(w, floorY), -- 1434
		2, -- 1434
		Color(76, 86, 98, 220) -- 1434
	) -- 1434
	uiDraw:drawRect( -- 1435
		Rect(0, floorY, w, 12), -- 1435
		Color(20, 24, 31, 240) -- 1435
	) -- 1435
	local plaqueX = toScreenX(180) -- 1438
	if plaqueX > -240 and plaqueX < w + 240 then -- 1438
		local pw = 290 -- 1440
		local ph = 132 -- 1441
		local py = floorY + 135 -- 1442
		uiDraw:drawRect( -- 1443
			Rect(plaqueX - pw * 0.5, py, pw, ph), -- 1444
			Color(18, 22, 28, 238), -- 1445
			1.2, -- 1446
			Color(118, 128, 140, 170) -- 1447
		) -- 1447
		fillRadialGlow( -- 1449
			uiGlow, -- 1449
			plaqueX, -- 1449
			wallTopY - 8, -- 1449
			150, -- 1449
			120, -- 1449
			Color(224, 232, 240, 42), -- 1449
			Color(180, 196, 214, 0), -- 1449
			14 -- 1449
		) -- 1449
		ctx.texts:put( -- 1450
			"sm", -- 1451
			"海防抗战纪念展厅", -- 1452
			plaqueX, -- 1453
			py + 82, -- 1454
			toColor(PALETTE.textBright), -- 1455
			0.5, -- 1456
			0.5, -- 1457
			"Center", -- 1458
			2, -- 1459
			0.88 -- 1460
		) -- 1460
		ctx.texts:put( -- 1462
			"xs", -- 1463
			"温州宁村 · 守望史迹陈列", -- 1464
			plaqueX, -- 1465
			py + 46, -- 1466
			toColor(PALETTE.textDim), -- 1467
			0.5, -- 1468
			0.5, -- 1469
			"Center", -- 1470
			1, -- 1471
			0.78 -- 1472
		) -- 1472
	end -- 1472
	local caseSx = toScreenX(____exports.MUSEUM_CASE_X) -- 1477
	if caseSx > -260 and caseSx < w + 260 then -- 1477
		local boardOffsets = {-210, 210} -- 1480
		local bi = 0 -- 1481
		do -- 1481
			bi = 0 -- 1482
			while bi < #boardOffsets do -- 1482
				local bx = caseSx + boardOffsets[bi + 1] -- 1483
				uiDraw:drawRect( -- 1484
					Rect(bx - 56, floorY + 112, 112, 154), -- 1484
					Color(20, 24, 30, 235), -- 1484
					1, -- 1484
					Color(88, 98, 110, 155) -- 1484
				) -- 1484
				uiDraw:drawRect( -- 1485
					Rect(bx - 42, floorY + 168, 84, 78), -- 1485
					Color(34, 40, 48, 220) -- 1485
				) -- 1485
				uiDraw:drawSegment( -- 1486
					Vec2(bx - 36, floorY + 146), -- 1486
					Vec2(bx + 36, floorY + 146), -- 1486
					1.6, -- 1486
					Color(138, 146, 156, 140) -- 1486
				) -- 1486
				uiDraw:drawSegment( -- 1487
					Vec2(bx - 28, floorY + 132), -- 1487
					Vec2(bx + 24, floorY + 132), -- 1487
					1.2, -- 1487
					Color(108, 116, 126, 115) -- 1487
				) -- 1487
				bi = bi + 1 -- 1482
			end -- 1482
		end -- 1482
		local pedW = 148 -- 1491
		local pedH = 92 -- 1492
		local glassH = 128 -- 1493
		uiDraw:drawRect( -- 1495
			Rect(caseSx - pedW * 0.5, floorY, pedW, pedH), -- 1496
			Color(22, 26, 33, 252), -- 1497
			1.2, -- 1498
			Color(96, 106, 118, 185) -- 1499
		) -- 1499
		uiDraw:drawRect( -- 1502
			Rect(caseSx - pedW * 0.46, floorY + pedH, pedW * 0.92, glassH), -- 1503
			Color(16, 22, 30, 165), -- 1504
			1.4, -- 1505
			Color(180, 196, 214, 195) -- 1506
		) -- 1506
		uiArt:tryPlace( -- 1509
			"prop_compass", -- 1509
			"fe06_hall_compass", -- 1509
			caseSx, -- 1509
			floorY + pedH + 34, -- 1509
			34, -- 1509
			34, -- 1509
			{opacity = 0.94, layer = 3} -- 1509
		) -- 1509
		uiDraw:drawRect( -- 1513
			Rect(caseSx - 30, floorY + pedH + 6, 60, 12), -- 1513
			Color(214, 212, 204, 190) -- 1513
		) -- 1513
		fillGradQuad( -- 1515
			uiInkDraw, -- 1516
			caseSx - 28, -- 1517
			floorY + pedH + glassH - 4, -- 1517
			Color(230, 240, 252, 42), -- 1517
			caseSx + 12, -- 1518
			floorY + pedH + glassH - 4, -- 1518
			Color(242, 248, 255, 72), -- 1518
			caseSx - 12, -- 1519
			floorY + pedH + 4, -- 1519
			Color(230, 240, 252, 18), -- 1519
			caseSx - 48, -- 1520
			floorY + pedH + 4, -- 1520
			Color(230, 240, 252, 0) -- 1520
		) -- 1520
		fillRadialGlow( -- 1522
			uiGlow, -- 1522
			caseSx, -- 1522
			floorY + pedH + glassH - 12, -- 1522
			86, -- 1522
			128, -- 1522
			Color(224, 236, 250, 56), -- 1522
			Color(168, 192, 220, 0), -- 1522
			16 -- 1522
		) -- 1522
		fillVGradRect( -- 1524
			uiDraw, -- 1524
			caseSx - pedW * 0.45, -- 1524
			floorY - 36, -- 1524
			pedW * 0.9, -- 1524
			36, -- 1524
			Color(168, 186, 206, 0), -- 1524
			Color(168, 186, 206, 28) -- 1524
		) -- 1524
	end -- 1524
	local lampSx = toScreenX(____exports.MUSEUM_LAMP_X) -- 1528
	local winSx = toScreenX(____exports.MUSEUM_LAMP_X + 108) -- 1529
	local reflectK = inLampTurn and smoothstep(____exports.MUSEUM_TIMINGS.lampReflectStart, 2.35, self.lampElapsed) or 0 -- 1530
	if winSx > -260 and winSx < w + 260 then -- 1530
		local winW = 204 -- 1535
		local winH = 312 -- 1536
		local winX = winSx - winW * 0.5 -- 1537
		local winY = floorY + 38 -- 1538
		fillVGradRect( -- 1540
			uiDraw, -- 1541
			winX, -- 1542
			winY, -- 1543
			winW, -- 1544
			winH, -- 1545
			Color( -- 1546
				math.floor(54 + 46 * reflectK + 0.5), -- 1547
				math.floor(68 + 42 * reflectK + 0.5), -- 1548
				math.floor(92 + 24 * reflectK + 0.5), -- 1549
				255 -- 1550
			), -- 1550
			Color( -- 1552
				math.floor(30 + 28 * reflectK + 0.5), -- 1553
				math.floor(44 + 34 * reflectK + 0.5), -- 1554
				math.floor(70 + 30 * reflectK + 0.5), -- 1555
				255 -- 1556
			) -- 1556
		) -- 1556
		if reflectK > 0.02 then -- 1556
			uiArt:tryPlace( -- 1562
				"bgFar_prologue", -- 1562
				"fe06_window_courtyard", -- 1562
				winSx, -- 1562
				winY + 26, -- 1562
				winW - 8, -- 1562
				winH - 52, -- 1562
				{ -- 1562
					opacity = reflectK * 0.48, -- 1563
					color = Color(238, 218, 186, 255), -- 1564
					layer = 1 -- 1565
				} -- 1565
			) -- 1565
			local cy = winY + 34 -- 1568
			local silA = math.floor(188 * reflectK + 0.5) -- 1569
			uiInkDraw:drawRect( -- 1570
				Rect(winX + 12, cy, 42, 118), -- 1570
				Color(24, 28, 36, silA) -- 1570
			) -- 1570
			uiInkDraw:drawRect( -- 1571
				Rect(winX + winW - 56, cy, 44, 134), -- 1571
				Color(24, 28, 36, silA) -- 1571
			) -- 1571
			uiInkDraw:drawRect( -- 1573
				Rect(winSx - 24, cy + 4, 48, 28), -- 1573
				Color( -- 1573
					46, -- 1573
					44, -- 1573
					42, -- 1573
					math.floor(215 * reflectK + 0.5) -- 1573
				), -- 1573
				1, -- 1573
				Color( -- 1573
					214, -- 1573
					186, -- 1573
					138, -- 1573
					math.floor(170 * reflectK + 0.5) -- 1573
				) -- 1573
			) -- 1573
			uiInkDraw:drawEllipse( -- 1574
				Vec2(winSx, cy + 32), -- 1574
				26, -- 1574
				7, -- 1574
				Color( -- 1574
					218, -- 1574
					194, -- 1574
					148, -- 1574
					math.floor(175 * reflectK + 0.5) -- 1574
				) -- 1574
			) -- 1574
			fillRadialGlow( -- 1576
				uiGlow, -- 1576
				winSx, -- 1576
				winY + winH * 0.48, -- 1576
				116, -- 1576
				128, -- 1576
				Color( -- 1576
					246, -- 1576
					218, -- 1576
					168, -- 1576
					math.floor(92 * reflectK + 0.5) -- 1576
				), -- 1576
				Color(214, 174, 112, 0), -- 1576
				18 -- 1576
			) -- 1576
		end -- 1576
		uiInkDraw:drawRect( -- 1580
			Rect(winX, winY, winW, winH), -- 1580
			Color(0, 0, 0, 0), -- 1580
			3, -- 1580
			Color(68, 76, 88, 245) -- 1580
		) -- 1580
		uiInkDraw:drawSegment( -- 1581
			Vec2(winSx, winY), -- 1581
			Vec2(winSx, winY + winH), -- 1581
			2, -- 1581
			Color(68, 76, 88, 235) -- 1581
		) -- 1581
		uiInkDraw:drawSegment( -- 1582
			Vec2(winX, winY + winH * 0.56), -- 1582
			Vec2(winX + winW, winY + winH * 0.56), -- 1582
			2, -- 1582
			Color(68, 76, 88, 235) -- 1582
		) -- 1582
		local standW = 34 -- 1585
		local standH = 96 -- 1586
		uiDraw:drawRect( -- 1587
			Rect(lampSx - standW * 0.5, floorY, standW, standH), -- 1587
			Color(34, 39, 48, 250), -- 1587
			1.1, -- 1587
			Color(108, 118, 130, 190) -- 1587
		) -- 1587
		local pivotY = floorY + standH + 44 -- 1589
		uiInkDraw:drawSegment( -- 1590
			Vec2(lampSx, floorY + standH), -- 1590
			Vec2(lampSx, pivotY), -- 1590
			3.2, -- 1590
			Color(136, 144, 154, 240) -- 1590
		) -- 1590
		uiInkDraw:drawCircle( -- 1591
			Vec2(lampSx, pivotY), -- 1591
			5.5, -- 1591
			Color(196, 178, 142, 245) -- 1591
		) -- 1591
		local aimDir = -0.65 + lampTurnProg * 1.48 -- 1593
		local headX = lampSx + math.sin(aimDir) * 20 -- 1594
		local headY = pivotY + math.cos(aimDir) * 14 -- 1595
		uiInkDraw:drawSegment( -- 1596
			Vec2(lampSx, pivotY), -- 1596
			Vec2(headX, headY), -- 1596
			6.2, -- 1596
			Color(188, 166, 126, 245) -- 1596
		) -- 1596
		uiInkDraw:drawCircle( -- 1597
			Vec2(headX, headY), -- 1597
			5.2, -- 1597
			Color(248, 234, 198, 248) -- 1597
		) -- 1597
		local beamLen = 132 + lampTurnProg * 76 -- 1600
		local bxEnd = headX + math.sin(aimDir) * beamLen -- 1601
		local byEnd = headY + math.cos(aimDir) * 28 -- 1602
		local perpX = -math.cos(aimDir) * 18 -- 1603
		local perpY = math.sin(aimDir) * 34 -- 1604
		fillGradQuad( -- 1605
			uiGlow, -- 1606
			headX, -- 1607
			headY - 4, -- 1607
			Color( -- 1607
				246, -- 1607
				224, -- 1607
				178, -- 1607
				math.floor(68 + 44 * lampTurnProg + 0.5) -- 1607
			), -- 1607
			headX, -- 1608
			headY + 4, -- 1608
			Color( -- 1608
				246, -- 1608
				224, -- 1608
				178, -- 1608
				math.floor(68 + 44 * lampTurnProg + 0.5) -- 1608
			), -- 1608
			bxEnd + perpX, -- 1609
			byEnd + perpY + 34, -- 1609
			Color(238, 206, 148, 0), -- 1609
			bxEnd - perpX, -- 1610
			byEnd - perpY - 22, -- 1610
			Color(238, 206, 148, 0) -- 1610
		) -- 1610
		fillRadialGlow( -- 1612
			uiGlow, -- 1612
			headX, -- 1612
			headY, -- 1612
			34, -- 1612
			34, -- 1612
			Color(246, 228, 186, 78), -- 1612
			Color(224, 194, 140, 0), -- 1612
			14 -- 1612
		) -- 1612
	end -- 1612
	local playerSx = toScreenX(self.hallWalkX) -- 1616
	local moving = not inLampTurn and (self.hallMoving or math.abs(ctx.input.moveX) > 0.05) -- 1617
	local slot = moving and "soldier_run" or "soldier_idle" -- 1618
	local frame = moving and math.floor(self.hallWalkAnim) or 0 -- 1619
	local charH = math.floor(192 * math.max( -- 1620
		0.75, -- 1620
		math.min(1.25, h / 720) -- 1620
	) + 0.5) -- 1620
	local charW = math.floor(charH * 0.45 + 0.5) -- 1621
	uiDraw:drawEllipse( -- 1623
		Vec2(playerSx, floorY + 2), -- 1623
		34, -- 1623
		6.5, -- 1623
		Color(6, 8, 12, 178) -- 1623
	) -- 1623
	uiDraw:drawEllipse( -- 1624
		Vec2(playerSx, floorY - 14), -- 1624
		24, -- 1624
		4.5, -- 1624
		Color(16, 20, 28, 62) -- 1624
	) -- 1624
	if not uiArt:tryPlace( -- 1624
		slot, -- 1625
		"fe06_museum_zhoushu", -- 1625
		playerSx, -- 1625
		floorY + 2, -- 1625
		charW, -- 1625
		charH, -- 1625
		{facing = self.hallFacing, frame = frame, layer = 3} -- 1625
	) then -- 1625
		uiDraw:drawRect( -- 1631
			Rect(playerSx - 20, floorY + 2, 40, charH * 0.84), -- 1631
			toColor(CUFF_PALETTE.indigoBase) -- 1631
		) -- 1631
		uiDraw:drawCircle( -- 1632
			Vec2(playerSx, floorY + charH * 0.92), -- 1632
			16, -- 1632
			Color(66, 73, 76, 255) -- 1632
		) -- 1632
	end -- 1632
	if self.holstered and not inLampTurn and math.abs(self.hallWalkX - ____exports.MUSEUM_CASE_X) <= 130 then -- 1632
		local subA = clamp01(1 - math.abs(self.hallWalkX - ____exports.MUSEUM_CASE_X) / 145) * 0.86 -- 1637
		ctx.texts:put( -- 1638
			"xs", -- 1639
			"已收起随身器物", -- 1640
			caseSx, -- 1641
			floorY + 252, -- 1642
			toColor(PALETTE.textMid), -- 1643
			0.5, -- 1644
			0.5, -- 1645
			"Center", -- 1646
			0.9, -- 1647
			subA -- 1648
		) -- 1648
	end -- 1648
	if self.childEchoVisualT > 0 then -- 1648
		local echoK = 1 - clamp01(self.childEchoVisualT / 2.1) -- 1654
		local ex = math.min( -- 1655
			w - 110, -- 1655
			toScreenX(____exports.MUSEUM_CASE_X + 310) -- 1655
		) -- 1655
		local ey = floorY + 32 -- 1656
		local ea = math.floor(math.sin(echoK * math.pi) * 165 + 0.5) -- 1657
		drawCircleRing( -- 1658
			uiInkDraw, -- 1658
			ex, -- 1658
			ey, -- 1658
			14 + echoK * 46, -- 1658
			Color(0, 0, 0, 0), -- 1658
			1.1, -- 1658
			Color(224, 214, 194, ea), -- 1658
			28 -- 1658
		) -- 1658
		drawCircleRing( -- 1659
			uiInkDraw, -- 1659
			ex, -- 1659
			ey, -- 1659
			8 + echoK * 28, -- 1659
			Color(0, 0, 0, 0), -- 1659
			0.9, -- 1659
			Color( -- 1659
				224, -- 1659
				214, -- 1659
				194, -- 1659
				math.floor(ea * 0.7 + 0.5) -- 1659
			), -- 1659
			24 -- 1659
		) -- 1659
		ctx.texts:put( -- 1660
			"xs", -- 1661
			"（远方传来轻快的孩童脚步声）", -- 1662
			w * 0.5, -- 1663
			84, -- 1664
			toColor(PALETTE.textMid), -- 1665
			0.5, -- 1666
			0.5, -- 1667
			"Center", -- 1668
			1, -- 1669
			math.sin(echoK * math.pi) * 0.85 -- 1670
		) -- 1670
	end -- 1670
	if not inLampTurn then -- 1670
		local fadeIn = smoothstep(0, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn, self.hallIntroElapsed) -- 1676
		local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold + ____exports.MUSEUM_TIMINGS.hallIntroFadeOut, self.hallIntroElapsed) -- 1677
		local introA = fadeIn * fadeOut -- 1682
		if introA > 0.02 then -- 1682
			drawSilkVeil( -- 1684
				uiDraw, -- 1684
				uiArt, -- 1684
				"fe06_hall_intro_veil", -- 1684
				w * 0.5, -- 1684
				h - 104, -- 1684
				480, -- 1684
				74, -- 1684
				PALETTE.inkVoid, -- 1684
				0.78 * introA, -- 1684
				1 -- 1684
			) -- 1684
			drawHairline( -- 1685
				uiInkDraw, -- 1685
				uiArt, -- 1685
				"fe06_hall_intro_line", -- 1685
				w * 0.5, -- 1685
				h - 106, -- 1685
				260, -- 1685
				PALETTE.silkLine, -- 1685
				0.45 * introA, -- 1685
				false, -- 1685
				4 -- 1685
			) -- 1685
			ctx.texts:put( -- 1686
				"md", -- 1686
				____exports.MUSEUM_HALL_TITLE, -- 1686
				w * 0.5, -- 1686
				h - 88, -- 1686
				toColor(PALETTE.textBright), -- 1686
				0.5, -- 1686
				0.5, -- 1686
				"Center", -- 1686
				1.8, -- 1686
				introA -- 1686
			) -- 1686
			ctx.texts:put( -- 1687
				"xs", -- 1687
				____exports.MUSEUM_HALL_SUBTITLE, -- 1687
				w * 0.5, -- 1687
				h - 122, -- 1687
				toColor(PALETTE.amberCore), -- 1687
				0.5, -- 1687
				0.5, -- 1687
				"Center", -- 1687
				1.2, -- 1687
				introA * 0.88 -- 1687
			) -- 1687
		end -- 1687
		if self.nearLamp and ctx.view.assistHintsEnabled then -- 1687
			drawSilkVeil( -- 1692
				uiDraw, -- 1692
				uiArt, -- 1692
				"fe06_lamp_hint_veil", -- 1692
				lampSx, -- 1692
				floorY + 158, -- 1692
				146, -- 1692
				28, -- 1692
				PALETTE.panelBg, -- 1692
				0.84, -- 1692
				1 -- 1692
			) -- 1692
			ctx.texts:put( -- 1693
				"xs", -- 1693
				"[E] 转动西窗灯", -- 1693
				lampSx, -- 1693
				floorY + 158, -- 1693
				toColor(PALETTE.textBright), -- 1693
				0.5, -- 1693
				0.5, -- 1693
				"Center", -- 1693
				0.6, -- 1693
				0.94 -- 1693
			) -- 1693
		end -- 1693
	end -- 1693
	if inLampTurn and self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1693
		local lineA = smoothstep(____exports.MUSEUM_TIMINGS.lampLineAt, ____exports.MUSEUM_TIMINGS.lampLineAt + 0.45, self.lampElapsed) * (1 - smoothstep(____exports.MUSEUM_TIMINGS.lampTurnDuration - 0.35, ____exports.MUSEUM_TIMINGS.lampTurnDuration, self.lampElapsed)) -- 1699
		if lineA > 0.02 then -- 1699
			drawSilkVeil( -- 1702
				uiDraw, -- 1702
				uiArt, -- 1702
				"fe06_dawn_line_veil", -- 1702
				w * 0.5, -- 1702
				86, -- 1702
				440, -- 1702
				50, -- 1702
				PALETTE.inkVoid, -- 1702
				0.84 * lineA, -- 1702
				1 -- 1702
			) -- 1702
			ctx.texts:put( -- 1703
				"md", -- 1704
				____exports.MUSEUM_LINE_DAWN, -- 1704
				w * 0.5, -- 1706
				86, -- 1707
				toColor(PALETTE.amberCore), -- 1708
				0.5, -- 1709
				0.5, -- 1710
				"Center", -- 1711
				1.6, -- 1712
				lineA -- 1713
			) -- 1713
		end -- 1713
	end -- 1713
	if self.knock1VisualT > 0 then -- 1713
		local k1 = 1 - clamp01(self.knock1VisualT / 0.85) -- 1719
		local k1A = math.floor((1 - k1) * 205 + 0.5) -- 1720
		drawCircleRing( -- 1721
			uiInkDraw, -- 1721
			winSx, -- 1721
			floorY + 148, -- 1721
			12 + k1 * 64, -- 1721
			Color(0, 0, 0, 0), -- 1721
			1.6, -- 1721
			Color(242, 232, 206, k1A), -- 1721
			28 -- 1721
		) -- 1721
		drawCircleRing( -- 1722
			uiInkDraw, -- 1722
			winSx, -- 1722
			floorY + 148, -- 1722
			6 + k1 * 34, -- 1722
			Color(0, 0, 0, 0), -- 1722
			1.1, -- 1722
			Color( -- 1722
				242, -- 1722
				232, -- 1722
				206, -- 1722
				math.floor(k1A * 0.72 + 0.5) -- 1722
			), -- 1722
			24 -- 1722
		) -- 1722
	end -- 1722
	self:drawLetterbox( -- 1725
		uiInkDraw, -- 1725
		w, -- 1725
		h, -- 1725
		38, -- 1725
		0.9 -- 1725
	) -- 1725
end -- 1401
function WellMuseumPlugin.prototype.renderE02ReturnCabinet(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1731
	local t = self.returnElapsed -- 1740
	local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.returnFadeOutAt, ____exports.MUSEUM_TIMINGS.returnCabinetDuration, t) -- 1741
	uiDraw:drawRect( -- 1744
		Rect(0, 0, w, h), -- 1744
		Color( -- 1744
			7, -- 1744
			9, -- 1744
			13, -- 1744
			math.floor(252 * fadeOut + 0.5) -- 1744
		) -- 1744
	) -- 1744
	if t < ____exports.MUSEUM_TIMINGS.returnKnock2At then -- 1744
		self:drawLetterbox( -- 1747
			uiInkDraw, -- 1747
			w, -- 1747
			h, -- 1747
			42, -- 1747
			0.95 * fadeOut -- 1747
		) -- 1747
		return -- 1748
	end -- 1748
	local revealK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.34, t) * fadeOut -- 1752
	local boxW = math.min(w - 140, 820) -- 1753
	local boxH = math.min(h - 190, 390) -- 1754
	local bx = (w - boxW) * 0.5 -- 1755
	local by = (h - boxH) * 0.5 + 10 -- 1756
	fillVGradRect( -- 1759
		uiDraw, -- 1760
		bx, -- 1761
		by, -- 1762
		boxW, -- 1763
		boxH, -- 1764
		Color( -- 1765
			13, -- 1765
			12, -- 1765
			16, -- 1765
			math.floor(248 * revealK + 0.5) -- 1765
		), -- 1765
		Color( -- 1766
			24, -- 1766
			24, -- 1766
			30, -- 1766
			math.floor(248 * revealK + 0.5) -- 1766
		) -- 1766
	) -- 1766
	local cabEdgeX = bx + boxW * 0.58 -- 1769
	uiDraw:drawRect( -- 1770
		Rect(cabEdgeX, by, boxW - (cabEdgeX - bx), boxH), -- 1770
		Color( -- 1770
			42, -- 1770
			31, -- 1770
			24, -- 1770
			math.floor(246 * revealK + 0.5) -- 1770
		) -- 1770
	) -- 1770
	uiDraw:drawSegment( -- 1771
		Vec2(cabEdgeX, by), -- 1771
		Vec2(cabEdgeX, by + boxH), -- 1771
		2.4, -- 1771
		Color( -- 1771
			116, -- 1771
			92, -- 1771
			68, -- 1771
			math.floor(220 * revealK + 0.5) -- 1771
		) -- 1771
	) -- 1771
	local gi = 0 -- 1773
	do -- 1773
		gi = 0 -- 1774
		while gi < 5 do -- 1774
			local gx = cabEdgeX + 26 + gi * 44 -- 1775
			if gx < bx + boxW - 10 then -- 1775
				uiDraw:drawSegment( -- 1777
					Vec2(gx, by + 12), -- 1777
					Vec2(gx, by + boxH - 12), -- 1777
					1, -- 1777
					Color( -- 1777
						28, -- 1777
						20, -- 1777
						15, -- 1777
						math.floor(140 * revealK + 0.5) -- 1777
					) -- 1777
				) -- 1777
			end -- 1777
			gi = gi + 1 -- 1774
		end -- 1774
	end -- 1774
	fillHGradRect( -- 1781
		uiGlow, -- 1782
		cabEdgeX - 58, -- 1783
		by + 24, -- 1784
		58, -- 1785
		boxH - 48, -- 1786
		Color(168, 188, 210, 0), -- 1787
		Color( -- 1788
			186, -- 1788
			206, -- 1788
			226, -- 1788
			math.floor(42 * revealK + 0.5) -- 1788
		) -- 1788
	) -- 1788
	if self.knock2VisualT > 0 then -- 1788
		local k2 = 1 - clamp01(self.knock2VisualT / 0.9) -- 1793
		local k2A = math.floor((1 - k2) * 215 * fadeOut + 0.5) -- 1794
		drawCircleRing( -- 1795
			uiInkDraw, -- 1795
			cabEdgeX + 8, -- 1795
			by + boxH * 0.5, -- 1795
			10 + k2 * 56, -- 1795
			Color(0, 0, 0, 0), -- 1795
			1.6, -- 1795
			Color(232, 220, 196, k2A), -- 1795
			28 -- 1795
		) -- 1795
	end -- 1795
	local extendK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.08, ____exports.MUSEUM_TIMINGS.returnKnock2At + 1.05, t) -- 1799
	local wristX = bx + 115 + extendK * (cabEdgeX - bx - 168) -- 1800
	local wristY = by + boxH * 0.5 -- 1801
	drawPatchedCuff(uiInkDraw, uiGlow, { -- 1802
		wristX = wristX, -- 1803
		wristY = wristY, -- 1804
		angleRad = -0.04 * (1 - extendK), -- 1805
		scale = 1.02, -- 1806
		pose = "reach", -- 1807
		opacity = revealK, -- 1808
		stitchHighlight = 0.48 + 0.22 * extendK, -- 1809
		cuffPullBack = 0.06, -- 1810
		warmth = 0.16 -- 1811
	}) -- 1811
	uiInkDraw:drawRect( -- 1815
		Rect(bx, by, boxW, boxH), -- 1815
		Color(0, 0, 0, 0), -- 1815
		1.2, -- 1815
		toColor( -- 1815
			PALETTE.silkDim, -- 1815
			math.floor(160 * revealK + 0.5) -- 1815
		) -- 1815
	) -- 1815
	local tipA = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.45, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.95, t) * fadeOut -- 1816
	if tipA > 0.03 then -- 1816
		drawSilkVeil( -- 1818
			uiDraw, -- 1818
			uiArt, -- 1818
			"fe06_return_veil", -- 1818
			w * 0.5, -- 1818
			by - 30, -- 1818
			320, -- 1818
			32, -- 1818
			PALETTE.inkVoid, -- 1818
			0.72 * tipA, -- 1818
			1 -- 1818
		) -- 1818
		ctx.texts:put( -- 1819
			"xs", -- 1820
			"两声轻敲落回柜板 · 寻回小满", -- 1821
			w * 0.5, -- 1822
			by - 30, -- 1823
			toColor(PALETTE.textMid), -- 1824
			0.5, -- 1825
			0.5, -- 1826
			"Center", -- 1827
			1.2, -- 1828
			tipA * 0.9 -- 1829
		) -- 1829
	end -- 1829
	self:drawLetterbox( -- 1833
		uiInkDraw, -- 1833
		w, -- 1833
		h, -- 1833
		42, -- 1833
		0.95 * fadeOut -- 1833
	) -- 1833
end -- 1731
function WellMuseumPlugin.prototype.drawLetterbox(self, draw, w, h, barH, opacity) -- 1836
	local a = math.floor(244 * clamp01(opacity) + 0.5) -- 1837
	if a <= 2 then -- 1837
		return -- 1839
	end -- 1839
	draw:drawRect( -- 1841
		Rect(0, 0, w, barH), -- 1841
		Color(6, 8, 12, a) -- 1841
	) -- 1841
	draw:drawRect( -- 1842
		Rect(0, h - barH, w, barH), -- 1842
		Color(6, 8, 12, a) -- 1842
	) -- 1842
end -- 1836
function ____exports.createWellMuseumPlugin(contract) -- 1846
	return __TS__New(____exports.WellMuseumPlugin, contract) -- 1847
end -- 1846
return ____exports -- 1846