-- [ts]: well_museum.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 29
local Color = ____Dora.Color -- 29
local Rect = ____Dora.Rect -- 29
local Vec2 = ____Dora.Vec2 -- 29
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 43
local adaptHintSentence = ____control_prompts.adaptHintSentence -- 43
local ____theme = require("Script.watch.fe.theme") -- 44
local PALETTE = ____theme.PALETTE -- 45
local drawHairline = ____theme.drawHairline -- 46
local drawSilkVeil = ____theme.drawSilkVeil -- 47
local fillGradQuad = ____theme.fillGradQuad -- 48
local fillHGradRect = ____theme.fillHGradRect -- 49
local fillRadialGlow = ____theme.fillRadialGlow -- 50
local toColor = ____theme.toColor -- 53
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 55
local computeCenteredSlideRect = ____slideshow.computeCenteredSlideRect -- 56
local computeFullscreenSlideRect = ____slideshow.computeFullscreenSlideRect -- 57
local drawPixelSlidePlate = ____slideshow.drawPixelSlidePlate -- 58
local drawSlideFrameChrome = ____slideshow.drawSlideFrameChrome -- 59
____exports.WELL_WORLD_X = 430 -- 62
____exports.WELL_INTERACT_REACH = 46 -- 63
____exports.MATCH_CUT_ANCHOR_NX = 0.5 -- 64
____exports.MATCH_CUT_ANCHOR_NY = 0.54 -- 65
____exports.MUSEUM_HALL_WIDTH = 1360 -- 66
____exports.MUSEUM_ENTRY_X = 180 -- 67
____exports.MUSEUM_CASE_X = 600 -- 68
____exports.MUSEUM_LAMP_X = 1140 -- 69
____exports.MUSEUM_WALK_SPEED = 156 -- 70
____exports.MUSEUM_LINE_DAWN = "「小满，外头天亮了。」" -- 71
____exports.MUSEUM_HALL_TITLE = "现代 · 宁村海防抗战纪念展厅" -- 72
____exports.MUSEUM_HALL_SUBTITLE = "山河安然，守望未绝" -- 73
____exports.MUSEUM_TIMINGS = { -- 75
	wellReflectDuration = 3.2, -- 76
	wellPickupAt = 1.1, -- 77
	wellMatchCutStart = 1.9, -- 78
	hallIntroFadeIn = 0.55, -- 79
	hallIntroHold = 3.4, -- 80
	hallIntroFadeOut = 0.85, -- 81
	childEchoDelay = 0.52, -- 82
	lampTurnDuration = 3.8, -- 83
	lampReflectStart = 0.65, -- 84
	lampLineAt = 1.45, -- 85
	lampKnock1At = 3.15, -- 86
	returnCabinetDuration = 2.6, -- 87
	returnKnock2At = 0.42, -- 88
	returnFadeOutAt = 2.2 -- 89
} -- 89
local MUSEUM_AUDIO_ROOT = "assets/audio/museum/" -- 92
____exports.MUSEUM_AUDIO = { -- 93
	wellDripLoop = MUSEUM_AUDIO_ROOT .. "well_drip_loop.wav", -- 94
	artifactPickup = MUSEUM_AUDIO_ROOT .. "artifact_pickup.wav", -- 95
	matchCutTransition = MUSEUM_AUDIO_ROOT .. "match_cut_transition.wav", -- 96
	hallAmbienceLoop = MUSEUM_AUDIO_ROOT .. "hall_ambience_loop.wav", -- 97
	hallFootstep = MUSEUM_AUDIO_ROOT .. "hall_footstep.wav", -- 98
	weaponHolster = MUSEUM_AUDIO_ROOT .. "weapon_holster.wav", -- 99
	childStepsEcho = MUSEUM_AUDIO_ROOT .. "child_steps_echo.wav", -- 100
	lampTurn = MUSEUM_AUDIO_ROOT .. "lamp_turn.wav", -- 101
	knockHallFirst = MUSEUM_AUDIO_ROOT .. "knock_hall_first.wav", -- 102
	knockCabinetSecond = MUSEUM_AUDIO_ROOT .. "knock_cabinet_second.wav", -- 103
	lineDawn = MUSEUM_AUDIO_ROOT .. "line_dawn.wav" -- 104
} -- 104
local LOOP_WELL_DRIP = "fe06_well_drip" -- 107
local LOOP_HALL_AMBIENCE = "fe06_hall_ambience" -- 108
local function clamp(v, lo, hi) -- 164
	return math.max( -- 165
		lo, -- 165
		math.min(hi, v) -- 165
	) -- 165
end -- 164
local function clamp01(v) -- 168
	return clamp(v, 0, 1) -- 169
end -- 168
local function smoothstep(edge0, edge1, x) -- 172
	if edge1 <= edge0 then -- 172
		return x >= edge1 and 1 or 0 -- 174
	end -- 174
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 176
	return t * t * (3 - 2 * t) -- 177
end -- 172
local function drawEllipseRing(draw, cx, cy, rx, ry, fillCol, borderWidth, borderCol, segments) -- 180
	if segments == nil then -- 180
		segments = 28 -- 189
	end -- 189
	if rx <= 0.5 or ry <= 0.5 then -- 189
		return -- 192
	end -- 192
	local pts = {} -- 194
	local step = math.pi * 2 / segments -- 195
	local i = 0 -- 196
	do -- 196
		i = 0 -- 197
		while i < segments do -- 197
			local a = i * step -- 198
			pts[#pts + 1] = Vec2( -- 199
				cx + math.cos(a) * rx, -- 199
				cy + math.sin(a) * ry -- 199
			) -- 199
			i = i + 1 -- 197
		end -- 197
	end -- 197
	draw:drawPolygon(pts, fillCol, borderWidth, borderCol) -- 201
end -- 180
local function drawCircleRing(draw, cx, cy, r, fillCol, borderWidth, borderCol, segments) -- 204
	if segments == nil then -- 204
		segments = 28 -- 212
	end -- 212
	drawEllipseRing( -- 214
		draw, -- 214
		cx, -- 214
		cy, -- 214
		r, -- 214
		r, -- 214
		fillCol, -- 214
		borderWidth, -- 214
		borderCol, -- 214
		segments -- 214
	) -- 214
end -- 204
local function asRecord(v) -- 217
	if v ~= nil and type(v) == "table" then -- 217
		return v -- 219
	end -- 219
	return nil -- 221
end -- 217
local function readNum(rec, key) -- 224
	if rec == nil then -- 224
		return nil -- 226
	end -- 226
	local val = rec[key] -- 228
	return type(val) == "number" and val or nil -- 229
end -- 224
local function readBool(rec, key) -- 232
	if rec == nil then -- 232
		return nil -- 234
	end -- 234
	local val = rec[key] -- 236
	local ____temp_0 -- 237
	if type(val) == "boolean" then -- 237
		____temp_0 = val -- 237
	else -- 237
		____temp_0 = nil -- 237
	end -- 237
	return ____temp_0 -- 237
end -- 232
local function resolveRuntimeContract(injected) -- 240
	if injected ~= nil then -- 240
		return injected -- 242
	end -- 242
	local g = _G -- 244
	local ____temp_1 -- 245
	if g.package ~= nil then -- 245
		____temp_1 = g.package.loaded -- 245
	else -- 245
		____temp_1 = nil -- 245
	end -- 245
	local loaded = ____temp_1 -- 245
	if loaded == nil then -- 245
		return nil -- 247
	end -- 247
	local rawFe = loaded["watch.fe"] -- 249
	if rawFe ~= nil and type(rawFe) == "table" then -- 249
		local c = rawFe.contract -- 251
		if c ~= nil and type(c) == "table" then -- 251
			return c -- 253
		end -- 253
	end -- 253
	return nil -- 256
end -- 240
local function isPrologueIntroBlocking() -- 259
	local g = _G -- 260
	local ____temp_2 -- 261
	if g.package ~= nil then -- 261
		____temp_2 = g.package.loaded -- 261
	else -- 261
		____temp_2 = nil -- 261
	end -- 261
	local loaded = ____temp_2 -- 261
	if loaded == nil then -- 261
		return false -- 263
	end -- 263
	local rawFe = loaded["watch.fe"] -- 265
	if rawFe == nil or type(rawFe) ~= "table" then -- 265
		return false -- 267
	end -- 267
	local prologue = rawFe.prologue -- 269
	if prologue == nil or type(prologue) ~= "table" then -- 269
		return false -- 271
	end -- 271
	local fn = prologue.getSnapshot -- 273
	if type(fn) ~= "function" then -- 273
		return false -- 275
	end -- 275
	local snap = asRecord(fn(prologue)) -- 277
	if readBool(snap, "blocksPlayerControl") == true then -- 277
		return true -- 279
	end -- 279
	local stage = snap ~= nil and type(snap.stage) == "string" and snap.stage or "idle" -- 282
	return stage == "p02_escape" or stage == "p02_hidden" -- 283
end -- 259
local function isActiveMuseumPhase(phase) -- 286
	return phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" -- 287
end -- 286
____exports.WellMuseumPlugin = __TS__Class() -- 293
local WellMuseumPlugin = ____exports.WellMuseumPlugin -- 293
WellMuseumPlugin.name = "WellMuseumPlugin" -- 293
function WellMuseumPlugin.prototype.____constructor(self, contract) -- 359
	self.id = "fe-06-well-museum" -- 294
	self.animTime = 0 -- 297
	self.prevPhase = "locked" -- 298
	self.roomSessionId = 0 -- 299
	self.rehearsal = false -- 300
	self.gateOpen = false -- 303
	self.gateBlockedReason = "locked" -- 304
	self.wellWorldX = ____exports.WELL_WORLD_X -- 305
	self.caseX = ____exports.MUSEUM_CASE_X -- 306
	self.lampX = ____exports.MUSEUM_LAMP_X -- 307
	self.nearWell = false -- 308
	self.revisitCalmTimer = 0 -- 309
	self.revisitCalmCount = 0 -- 310
	self.reflectElapsed = 0 -- 313
	self.wellAnchorX = 640 -- 314
	self.wellAnchorY = 388.8 -- 315
	self.glassAnchorX = 640 -- 316
	self.glassAnchorY = 388.8 -- 317
	self.enterHallSubmitted = false -- 318
	self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 321
	self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 322
	self.hallFacing = 1 -- 323
	self.hallWalkAnim = 0 -- 324
	self.hallMoving = false -- 325
	self.hallFootstepTimer = 0 -- 326
	self.hallIntroElapsed = 0 -- 327
	self.holstered = false -- 328
	self.childEchoCountdown = -1 -- 329
	self.childEchoPlayed = false -- 330
	self.childEchoVisualT = 0 -- 331
	self.nearLamp = false -- 332
	self.lampElapsed = 0 -- 334
	self.lineDawnShown = false -- 335
	self.knock1Played = false -- 336
	self.knock1VisualT = 0 -- 337
	self.beginReturnSubmitted = false -- 338
	self.returnElapsed = 0 -- 341
	self.knock2Played = false -- 342
	self.knock2VisualT = 0 -- 343
	self.returnCompleteSubmitted = false -- 344
	self.artifactGrantCount = 0 -- 347
	self.resumeRestoreCount = 0 -- 349
	self.lastResumePhase = "locked" -- 350
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 351
	self.lastVisualMode = "pixel" -- 352
	self.lastPaused = false -- 353
	self.wellDripPlaying = false -- 354
	self.hallAmbiencePlaying = false -- 355
	self.liveReflectDoneInMuseumRoom = false -- 356
	self.injectedContract = contract -- 360
end -- 359
function WellMuseumPlugin.prototype.syncRuntimeHook(self) -- 363
	local g = _G -- 364
	local ____temp_3 -- 365
	if g.package ~= nil then -- 365
		____temp_3 = g.package.loaded -- 365
	else -- 365
		____temp_3 = nil -- 365
	end -- 365
	local loaded = ____temp_3 -- 365
	if loaded == nil then -- 365
		return -- 367
	end -- 367
	local rawFe = loaded["watch.fe"] -- 369
	if rawFe ~= nil and type(rawFe) == "table" then -- 369
		local watchFe = rawFe -- 371
		if watchFe.wellMuseum ~= self then -- 371
			watchFe.wellMuseum = self -- 373
		end -- 373
	end -- 373
end -- 363
function WellMuseumPlugin.prototype.queueSimulatedInput(self, sim) -- 379
	self.simInput = {moveX = sim.moveX, interact = sim.interact} -- 380
end -- 379
function WellMuseumPlugin.prototype.exportResumeState(self) -- 387
	return { -- 388
		phase = self.prevPhase, -- 389
		hallWalkX = self.hallWalkX, -- 390
		hallCamX = self.hallCamX, -- 391
		hallFacing = self.hallFacing, -- 392
		holstered = self.holstered, -- 393
		childEchoPlayed = self.childEchoPlayed, -- 394
		reflectElapsed = self.reflectElapsed, -- 395
		lampElapsed = self.lampElapsed, -- 396
		returnElapsed = self.returnElapsed, -- 397
		artifactGrantCount = self.artifactGrantCount -- 398
	} -- 398
end -- 387
function WellMuseumPlugin.prototype.restoreResumeState(self, snap) -- 403
	if snap.phase ~= nil then -- 403
		self.prevPhase = snap.phase -- 405
		self.lastResumePhase = snap.phase -- 406
	end -- 406
	if snap.hallWalkX ~= nil then -- 406
		self.hallWalkX = clamp(snap.hallWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 409
		self.lastResumeWalkX = self.hallWalkX -- 410
	end -- 410
	if snap.hallCamX ~= nil then -- 410
		self.hallCamX = snap.hallCamX -- 413
	else -- 413
		self.hallCamX = self.hallWalkX -- 415
	end -- 415
	if snap.hallFacing ~= nil then -- 415
		self.hallFacing = snap.hallFacing >= 0 and 1 or -1 -- 418
	end -- 418
	if snap.holstered ~= nil then -- 418
		self.holstered = snap.holstered -- 421
	end -- 421
	if snap.childEchoPlayed ~= nil then -- 421
		self.childEchoPlayed = snap.childEchoPlayed -- 424
	end -- 424
	if snap.reflectElapsed ~= nil then -- 424
		self.reflectElapsed = math.max(0, snap.reflectElapsed) -- 427
	end -- 427
	if snap.lampElapsed ~= nil then -- 427
		self.lampElapsed = math.max(0, snap.lampElapsed) -- 430
	end -- 430
	if snap.returnElapsed ~= nil then -- 430
		self.returnElapsed = math.max(0, snap.returnElapsed) -- 433
	end -- 433
	if snap.artifactGrantCount ~= nil then -- 433
		self.artifactGrantCount = math.max(0, snap.artifactGrantCount) -- 436
	end -- 436
	self.savedResume = self:exportResumeState() -- 438
	self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 439
end -- 403
function WellMuseumPlugin.prototype.resetSessionCounters(self) -- 443
	self.artifactGrantCount = 0 -- 444
	self.revisitCalmCount = 0 -- 445
	self.revisitCalmTimer = 0 -- 446
	self.savedResume = nil -- 447
	self.resumeRestoreCount = 0 -- 448
	self.lastResumePhase = "locked" -- 449
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 450
end -- 443
function WellMuseumPlugin.prototype.setHallWalkPosition(self, x, holstered) -- 454
	self.hallWalkX = clamp(x, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 455
	self.hallCamX = self.hallWalkX -- 456
	if holstered ~= nil then -- 456
		self.holstered = holstered -- 458
	elseif self.hallWalkX >= self.caseX - 85 then -- 458
		self.holstered = true -- 460
	end -- 460
	self.savedResume = self:exportResumeState() -- 462
end -- 454
function WellMuseumPlugin.prototype.seekStageTime(self, stage, seconds) -- 466
	local s = math.max(0, seconds) -- 467
	if stage == "well_reflect" then -- 467
		self.reflectElapsed = math.min(____exports.MUSEUM_TIMINGS.wellReflectDuration, s) -- 469
	elseif stage == "lamp_turn" then -- 469
		self.lampElapsed = math.min(____exports.MUSEUM_TIMINGS.lampTurnDuration, s) -- 471
		self.lineDawnShown = self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt -- 472
	elseif stage == "return_cabinet" then -- 472
		self.returnElapsed = math.min(____exports.MUSEUM_TIMINGS.returnCabinetDuration, s) -- 474
	end -- 474
end -- 466
function WellMuseumPlugin.prototype.getDebugState(self) -- 478
	local reflectProg = clamp01(self.reflectElapsed / ____exports.MUSEUM_TIMINGS.wellReflectDuration) -- 479
	local matchStart = ____exports.MUSEUM_TIMINGS.wellMatchCutStart -- 480
	local matchSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.wellReflectDuration - matchStart) -- 481
	local matchProg = self.reflectElapsed <= matchStart and 0 or clamp01((self.reflectElapsed - matchStart) / matchSpan) -- 482
	local lampTurnProg = clamp01(self.lampElapsed / 1.15) -- 485
	local cuffStart = ____exports.MUSEUM_TIMINGS.returnKnock2At -- 486
	local cuffSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.returnFadeOutAt - cuffStart) -- 487
	local cuffProg = self.returnElapsed <= cuffStart and 0 or clamp01((self.returnElapsed - cuffStart) / cuffSpan) -- 488
	local dx = self.glassAnchorX - self.wellAnchorX -- 491
	local dy = self.glassAnchorY - self.wellAnchorY -- 492
	return { -- 493
		gateOpen = self.gateOpen, -- 494
		gateBlockedReason = self.gateBlockedReason, -- 495
		wellWorldX = self.wellWorldX, -- 496
		nearWell = self.nearWell, -- 497
		museumPhase = self.prevPhase, -- 498
		visualMode = self.lastVisualMode, -- 499
		reflectElapsed = self.reflectElapsed, -- 500
		reflectProgress = reflectProg, -- 501
		matchCutProgress = matchProg, -- 502
		wellAnchorX = self.wellAnchorX, -- 503
		wellAnchorY = self.wellAnchorY, -- 504
		glassAnchorX = self.glassAnchorX, -- 505
		glassAnchorY = self.glassAnchorY, -- 506
		matchCutAnchorDeltaPx = math.sqrt(dx * dx + dy * dy), -- 507
		hallWalkX = self.hallWalkX, -- 508
		hallCamX = self.hallCamX, -- 509
		holstered = self.holstered, -- 510
		childEchoPlayed = self.childEchoPlayed, -- 511
		nearLamp = self.nearLamp, -- 512
		lampElapsed = self.lampElapsed, -- 513
		lampTurnProgress = lampTurnProg, -- 514
		lineDawnShown = self.lineDawnShown, -- 515
		knock1Played = self.knock1Played, -- 516
		knock2Played = self.knock2Played, -- 517
		returnElapsed = self.returnElapsed, -- 518
		cuffReusedFromSharedPalette = true, -- 519
		cuffProgress = cuffProg, -- 520
		artifactGrantCount = self.artifactGrantCount, -- 521
		revisitCalmCount = self.revisitCalmCount, -- 522
		resumeRestoreCount = self.resumeRestoreCount, -- 523
		lastResumePhase = self.lastResumePhase, -- 524
		lastResumeWalkX = self.lastResumeWalkX, -- 525
		pausedFrozen = self.lastPaused -- 526
	} -- 526
end -- 478
function WellMuseumPlugin.prototype.onBindPlay(self, p, view) -- 530
	self:syncRuntimeHook() -- 531
	if view.isRehearsal ~= self.rehearsal then -- 531
		self.savedResume = nil -- 533
	end -- 533
	self.rehearsal = view.isRehearsal -- 535
	local ____view_isRehearsal_6 -- 536
	if view.isRehearsal then -- 536
		____view_isRehearsal_6 = nil -- 536
	else -- 536
		local ____opt_4 = p.room.story -- 536
		____view_isRehearsal_6 = ____opt_4 and ____opt_4.museum -- 536
	end -- 536
	local museum = ____view_isRehearsal_6 -- 536
	self.caseX = museum == nil and ____exports.MUSEUM_CASE_X or museum.cabinetX - p.ox -- 537
	self.lampX = museum == nil and ____exports.MUSEUM_LAMP_X or museum.lampX - p.ox -- 538
	self.animTime = 0 -- 539
	self.revisitCalmTimer = 0 -- 540
	self.childEchoVisualT = 0 -- 541
	self.knock1VisualT = 0 -- 542
	self.knock2VisualT = 0 -- 543
	self.wellDripPlaying = false -- 544
	self.hallAmbiencePlaying = false -- 545
	self.enterHallSubmitted = false -- 546
	self.beginReturnSubmitted = false -- 547
	self.returnCompleteSubmitted = false -- 548
	self.liveReflectDoneInMuseumRoom = false -- 549
	self.simInput = nil -- 550
	local phase = view.archive.museumPhase -- 552
	self.prevPhase = phase -- 553
	self.lastVisualMode = view.visualMode -- 554
	local pRec = asRecord(p) -- 558
	local backendWellX = readNum(pRec, "wellX") -- 559
	self.wellWorldX = backendWellX ~= nil and p.ox + backendWellX or p.ox + ____exports.WELL_WORLD_X -- 560
	self.hallMoving = false -- 561
	if view.archive.childCleared and view.archive.soldierCleared and view.archive.artifactOwned then -- 561
		if self.artifactGrantCount < 1 then -- 561
			self.artifactGrantCount = 1 -- 566
		end -- 566
	elseif not view.archive.artifactOwned then -- 566
		self.artifactGrantCount = 0 -- 569
	end -- 569
	if isActiveMuseumPhase(phase) then -- 569
		local ____view_isRehearsal_7 -- 574
		if view.isRehearsal then -- 574
			____view_isRehearsal_7 = nil -- 574
		else -- 574
			____view_isRehearsal_7 = asRecord(p.run) -- 574
		end -- 574
		local runRec = ____view_isRehearsal_7 -- 574
		local ____asRecord_9 = asRecord -- 575
		local ____temp_8 -- 575
		if pRec ~= nil then -- 575
			____temp_8 = pRec.archive -- 575
		else -- 575
			____temp_8 = nil -- 575
		end -- 575
		local ____asRecord_9_result_12 = ____asRecord_9(____temp_8) -- 575
		if ____asRecord_9_result_12 == nil then -- 575
			local ____asRecord_11 = asRecord -- 576
			local ____temp_10 -- 576
			if runRec ~= nil then -- 576
				____temp_10 = runRec.archive -- 576
			else -- 576
				____temp_10 = nil -- 576
			end -- 576
			____asRecord_9_result_12 = ____asRecord_11(____temp_10) -- 575
		end -- 575
		local archRec = ____asRecord_9_result_12 -- 575
		local backendWalkX = readNum(archRec, "museumWalkX") or readNum(pRec, "museumWalkX") -- 577
		local ____readBool_result_13 = readBool(archRec, "museumHolstered") -- 578
		if ____readBool_result_13 == nil then -- 578
			____readBool_result_13 = readBool(pRec, "museumHolstered") -- 578
		end -- 578
		local backendHolstered = ____readBool_result_13 -- 578
		local ____readBool_result_14 = readBool(archRec, "museumChildEchoPlayed") -- 579
		if ____readBool_result_14 == nil then -- 579
			____readBool_result_14 = readBool(pRec, "museumChildEchoPlayed") -- 579
		end -- 579
		local backendChildEcho = ____readBool_result_14 -- 579
		if self.savedResume ~= nil and self.savedResume.phase == phase then -- 579
			self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.savedResume.hallWalkX -- 582
			self.hallCamX = self.hallWalkX -- 583
			self.hallFacing = self.savedResume.hallFacing -- 584
			local ____backendHolstered_15 = backendHolstered -- 585
			if ____backendHolstered_15 == nil then -- 585
				____backendHolstered_15 = self.savedResume.holstered -- 585
			end -- 585
			self.holstered = ____backendHolstered_15 -- 585
			local ____backendChildEcho_16 = backendChildEcho -- 586
			if ____backendChildEcho_16 == nil then -- 586
				____backendChildEcho_16 = self.savedResume.childEchoPlayed -- 586
			end -- 586
			self.childEchoPlayed = ____backendChildEcho_16 -- 586
			self.reflectElapsed = self.savedResume.reflectElapsed -- 587
			self.lampElapsed = self.savedResume.lampElapsed -- 588
			self.returnElapsed = self.savedResume.returnElapsed -- 589
		else -- 589
			self:resetPhaseTimersForEntry(phase, backendWalkX, backendHolstered, backendChildEcho) -- 591
		end -- 591
		self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 593
		self.lastResumePhase = phase -- 594
		self.lastResumeWalkX = self.hallWalkX -- 595
	else -- 595
		self.reflectElapsed = 0 -- 598
		self.lampElapsed = 0 -- 599
		self.returnElapsed = 0 -- 600
		self.hallIntroElapsed = 0 -- 601
		self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 602
		self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 603
		self.hallFacing = 1 -- 604
		self.holstered = false -- 605
		self.childEchoCountdown = -1 -- 606
		self.childEchoPlayed = false -- 607
		self.lineDawnShown = false -- 608
		self.knock1Played = false -- 609
		self.knock2Played = false -- 610
		if phase == "locked" or phase == "well_open" then -- 610
			self.savedResume = nil -- 612
		end -- 612
	end -- 612
end -- 530
function WellMuseumPlugin.prototype.resetPhaseTimersForEntry(self, phase, backendWalkX, backendHolstered, backendChildEcho) -- 617
	if phase == "well_reflect" then -- 617
		self.reflectElapsed = 0 -- 624
		self.enterHallSubmitted = false -- 625
		return -- 626
	end -- 626
	if phase == "hall_walk" then -- 626
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or ____exports.MUSEUM_ENTRY_X -- 629
		self.hallCamX = self.hallWalkX -- 630
		self.hallFacing = 1 -- 631
		self.hallIntroElapsed = backendWalkX ~= nil and backendWalkX > 260 and 5 or 0 -- 632
		local ____backendHolstered_17 = backendHolstered -- 633
		if ____backendHolstered_17 == nil then -- 633
			____backendHolstered_17 = self.hallWalkX >= self.caseX - 85 -- 633
		end -- 633
		self.holstered = ____backendHolstered_17 -- 633
		local ____backendChildEcho_18 = backendChildEcho -- 634
		if ____backendChildEcho_18 == nil then -- 634
			____backendChildEcho_18 = self.hallWalkX >= self.caseX + 120 -- 634
		end -- 634
		self.childEchoPlayed = ____backendChildEcho_18 -- 634
		self.childEchoCountdown = -1 -- 635
		return -- 636
	end -- 636
	if phase == "lamp_turn" then -- 636
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.lampX - 36 -- 639
		self.hallCamX = self.hallWalkX -- 640
		self.hallFacing = 1 -- 641
		self.holstered = true -- 642
		self.childEchoPlayed = true -- 643
		self.lampElapsed = 0 -- 644
		self.lineDawnShown = false -- 645
		self.knock1Played = false -- 646
		self.beginReturnSubmitted = false -- 647
		return -- 648
	end -- 648
	if phase == "return_cabinet" then -- 648
		self.returnElapsed = 0 -- 651
		self.knock2Played = false -- 652
		self.returnCompleteSubmitted = false -- 653
	end -- 653
end -- 617
function WellMuseumPlugin.prototype.evaluateGate(self, p, view) -- 657
	if p.run.trial ~= nil then -- 657
		return {open = false, reason = "trial_mode"} -- 659
	end -- 659
	if p.room.key ~= "prologue" then -- 659
		return {open = false, reason = "not_prologue"} -- 662
	end -- 662
	if p.phase ~= "prologue-wait" and p.phase ~= "prologue-well" then -- 662
		return {open = false, reason = "after_cabinet_window"} -- 665
	end -- 665
	if isPrologueIntroBlocking() then -- 665
		return {open = false, reason = "prologue_intro_active"} -- 668
	end -- 668
	if not view.archive.childCleared or not view.archive.soldierCleared then -- 668
		return {open = false, reason = "requires_both_clear"} -- 672
	end -- 672
	if view.archive.museumPhase == "locked" then -- 672
		return {open = false, reason = "phase_locked"} -- 675
	end -- 675
	return {open = true, reason = "ok"} -- 677
end -- 657
function WellMuseumPlugin.prototype.submitMuseumIntent(self, p, target) -- 680
	local contract = resolveRuntimeContract(self.injectedContract) -- 681
	if contract == nil then -- 681
		return false -- 683
	end -- 683
	local intent = {kind = "museumInteract", target = target} -- 685
	return contract:submitIntent(p, intent) -- 686
end -- 680
function WellMuseumPlugin.prototype.syncLoops(self, ctx, wantWellDrip, dripVolume, wantHallAmbience) -- 689
	if wantWellDrip then -- 689
		ctx.audio:playLoop( -- 691
			LOOP_WELL_DRIP, -- 691
			"water", -- 691
			____exports.MUSEUM_AUDIO.wellDripLoop, -- 691
			dripVolume, -- 691
			ctx.p.ticks -- 691
		) -- 691
		self.wellDripPlaying = true -- 692
	elseif self.wellDripPlaying then -- 692
		ctx.audio:stopLoop(LOOP_WELL_DRIP) -- 694
		self.wellDripPlaying = false -- 695
	end -- 695
	if wantHallAmbience then -- 695
		ctx.audio:playLoop( -- 699
			LOOP_HALL_AMBIENCE, -- 699
			"ambience", -- 699
			____exports.MUSEUM_AUDIO.hallAmbienceLoop, -- 699
			0.34, -- 699
			ctx.p.ticks -- 699
		) -- 699
		self.hallAmbiencePlaying = true -- 700
	elseif self.hallAmbiencePlaying then -- 700
		ctx.audio:stopLoop(LOOP_HALL_AMBIENCE) -- 702
		self.hallAmbiencePlaying = false -- 703
	end -- 703
end -- 689
function WellMuseumPlugin.prototype.update(self, ctx) -- 707
	self:syncRuntimeHook() -- 708
	local p = ctx.p -- 709
	local view = ctx.view -- 710
	local phase = view.archive.museumPhase -- 711
	if view.isRehearsal ~= self.rehearsal then -- 711
		self:syncLoops(ctx, false, 0, false) -- 713
		self:onBindPlay(p, view) -- 714
	end -- 714
	self.roomSessionId = ctx.events.roomSessionId -- 716
	self.lastVisualMode = view.visualMode -- 717
	self.lastPaused = ctx.paused -- 718
	self.wellAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 721
	self.wellAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 722
	self.glassAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 723
	self.glassAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 724
	local sim = self.simInput -- 727
	self.simInput = nil -- 728
	local interactPressed = ctx.input.interact.pressed or ctx.input.frameInteractPressed or sim ~= nil and sim.interact == true -- 729
	local moveX = sim ~= nil and sim.moveX ~= nil and sim.moveX or ctx.input.moveX -- 732
	if phase ~= self.prevPhase then -- 732
		local wasActive = isActiveMuseumPhase(self.prevPhase) -- 736
		self.prevPhase = phase -- 737
		if isActiveMuseumPhase(phase) then -- 737
			if phase == "well_reflect" then -- 737
				self:resetPhaseTimersForEntry("well_reflect") -- 740
				if view.archive.artifactOwned and self.artifactGrantCount < 1 then -- 740
					self.artifactGrantCount = 1 -- 742
				end -- 742
			elseif phase == "hall_walk" and not wasActive then -- 742
				self:resetPhaseTimersForEntry("hall_walk") -- 745
			elseif phase == "hall_walk" and wasActive then -- 745
				self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 747
				self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 748
				self.hallFacing = 1 -- 749
				self.hallIntroElapsed = 0 -- 750
				self.holstered = false -- 751
				self.childEchoPlayed = false -- 752
				self.childEchoCountdown = -1 -- 753
			elseif phase == "lamp_turn" then -- 753
				self:resetPhaseTimersForEntry("lamp_turn", self.hallWalkX, true, self.childEchoPlayed) -- 755
			elseif phase == "return_cabinet" then -- 755
				self:resetPhaseTimersForEntry("return_cabinet") -- 757
			end -- 757
		elseif phase == "done" then -- 757
			self.savedResume = nil -- 760
		end -- 760
	end -- 760
	local gate = self:evaluateGate(p, view) -- 764
	self.gateOpen = gate.open -- 765
	self.gateBlockedReason = gate.reason -- 766
	self.nearWell = gate.open and math.abs(p.player.x - self.wellWorldX) <= ____exports.WELL_INTERACT_REACH -- 767
	if ctx.paused then -- 767
		return -- 771
	end -- 771
	local wdt = math.max(0, ctx.worldDt) -- 774
	local udt = math.max(0, ctx.uiDt) -- 775
	self.animTime = self.animTime + wdt -- 776
	if self.revisitCalmTimer > 0 then -- 776
		self.revisitCalmTimer = math.max(0, self.revisitCalmTimer - wdt) -- 779
	end -- 779
	if self.childEchoVisualT > 0 then -- 779
		self.childEchoVisualT = math.max(0, self.childEchoVisualT - udt) -- 782
	end -- 782
	if self.knock1VisualT > 0 then -- 782
		self.knock1VisualT = math.max(0, self.knock1VisualT - wdt) -- 785
	end -- 785
	if self.knock2VisualT > 0 then -- 785
		self.knock2VisualT = math.max(0, self.knock2VisualT - wdt) -- 788
	end -- 788
	if view.visualMode ~= "museum" then -- 788
		local wantDrip = gate.open and phase == "well_open" and not view.archive.museumSeen -- 793
		local dist = math.abs(p.player.x - self.wellWorldX) -- 794
		local dripVol = clamp(0.46 - dist * 0.0014, 0.08, 0.46) -- 795
		self:syncLoops(ctx, wantDrip, dripVol, false) -- 796
		if gate.open and self.nearWell and interactPressed then -- 796
			local liveNeedsSecondEnter = not view.isRehearsal and p.room.key == "prologue" and view.archive.artifactOwned and not view.archive.museumSeen -- 799
			local alreadyAwarded = not liveNeedsSecondEnter and (view.archive.museumSeen or phase == "done" or view.archive.artifactOwned and self.artifactGrantCount >= 1) -- 803
			if (phase == "well_open" or liveNeedsSecondEnter) and not alreadyAwarded then -- 803
				self:submitMuseumIntent(p, "well_pickup") -- 808
			else -- 808
				self.revisitCalmTimer = 1.4 -- 811
				self.revisitCalmCount = self.revisitCalmCount + 1 -- 812
			end -- 812
		end -- 812
		return -- 815
	end -- 815
	local effectivePhase = p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 819
	if effectivePhase == "well_reflect" then -- 819
		local dripVol = clamp( -- 824
			0.44 * (1 - smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, self.reflectElapsed)), -- 824
			0, -- 824
			0.44 -- 824
		) -- 824
		self:syncLoops(ctx, dripVol > 0.03, dripVol, false) -- 825
		if wdt > 0 then -- 825
			self.reflectElapsed = self.reflectElapsed + wdt -- 828
		end -- 828
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 828
			if self.artifactGrantCount < 1 then -- 828
				self.artifactGrantCount = 1 -- 832
			end -- 832
			ctx.audio:playOnce( -- 834
				"fe06:e01:pickup:" .. tostring(self.roomSessionId), -- 835
				"sfx", -- 836
				____exports.MUSEUM_AUDIO.artifactPickup, -- 837
				0.86, -- 838
				"museum:e01:artifact_pickup", -- 839
				p.ticks -- 840
			) -- 840
		end -- 840
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellMatchCutStart then -- 840
			ctx.audio:playOnce( -- 844
				"fe06:e01:matchcut:" .. tostring(self.roomSessionId), -- 845
				"ambience", -- 846
				____exports.MUSEUM_AUDIO.matchCutTransition, -- 847
				0.78, -- 848
				"museum:e01:match_cut", -- 849
				p.ticks -- 850
			) -- 850
		end -- 850
		self.savedResume = self:exportResumeState() -- 853
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellReflectDuration and not self.enterHallSubmitted then -- 853
			self.enterHallSubmitted = true -- 855
			if p.room.key == "museum" then -- 855
				self.liveReflectDoneInMuseumRoom = true -- 857
			end -- 857
			self:submitMuseumIntent(p, "enter_hall") -- 859
			local contract = resolveRuntimeContract(self.injectedContract) -- 860
			if contract ~= nil and contract:isRehearsal() then -- 860
				contract:enterMockMuseum("hall_walk") -- 862
			end -- 862
		end -- 862
		return -- 865
	end -- 865
	if effectivePhase == "hall_walk" then -- 865
		self:syncLoops(ctx, false, 0, true) -- 870
		self.hallIntroElapsed = self.hallIntroElapsed + udt -- 871
		local ____view_isRehearsal_19 -- 875
		if view.isRehearsal then -- 875
			____view_isRehearsal_19 = nil -- 875
		else -- 875
			____view_isRehearsal_19 = asRecord(p) -- 875
		end -- 875
		local pRec = ____view_isRehearsal_19 -- 875
		local backendWalkX = readNum(pRec, "museumWalkX") or (not view.isRehearsal and p.room.key == "museum" and p.player.x - p.ox or nil) -- 876
		self.hallMoving = false -- 878
		local previousX = self.hallWalkX -- 879
		if backendWalkX ~= nil then -- 879
			self.hallWalkX = clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 881
		elseif udt > 0 and math.abs(moveX) > 0.05 then -- 881
			self.hallWalkX = clamp(self.hallWalkX + moveX * ____exports.MUSEUM_WALK_SPEED * udt, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 883
		end -- 883
		local delta = self.hallWalkX - previousX -- 885
		if math.abs(delta) > 0.01 then -- 885
			self.hallFacing = delta >= 0 and 1 or -1 -- 887
			self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 888
			self.hallMoving = true -- 889
			self.hallFootstepTimer = self.hallFootstepTimer + udt -- 890
			if self.hallFootstepTimer >= 0.46 then -- 890
				self.hallFootstepTimer = 0 -- 892
				ctx.audio:playOnce( -- 893
					(("fe06:e02:step:" .. tostring(self.roomSessionId)) .. ":") .. tostring(math.floor(self.hallWalkAnim * 2)), -- 894
					"sfx", -- 895
					____exports.MUSEUM_AUDIO.hallFootstep, -- 896
					0.46, -- 897
					"museum:e02:footstep", -- 898
					p.ticks -- 899
				) -- 899
			end -- 899
		else -- 899
			self.hallFootstepTimer = math.min(self.hallFootstepTimer, 0.22) -- 903
		end -- 903
		local camFollow = math.min(1, udt * 5.2) -- 907
		self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * camFollow -- 908
		local holsterThreshold = p.room.key == "museum" and self.caseX + 12 or self.caseX - 85 -- 911
		if not self.holstered and self.hallWalkX >= holsterThreshold then -- 911
			self.holstered = true -- 913
			ctx.audio:playOnce( -- 914
				"fe06:e02:holster:" .. tostring(self.roomSessionId), -- 915
				"sfx", -- 916
				____exports.MUSEUM_AUDIO.weaponHolster, -- 917
				0.76, -- 918
				"museum:e02:weapon_holster", -- 919
				p.ticks -- 920
			) -- 920
			if not self.childEchoPlayed then -- 920
				self.childEchoCountdown = ____exports.MUSEUM_TIMINGS.childEchoDelay -- 923
			end -- 923
		end -- 923
		if self.childEchoCountdown >= 0 and not self.childEchoPlayed then -- 923
			self.childEchoCountdown = self.childEchoCountdown - udt -- 928
			if self.childEchoCountdown <= 0 then -- 928
				self.childEchoCountdown = -1 -- 930
				self.childEchoPlayed = true -- 931
				self.childEchoVisualT = 2.1 -- 932
				ctx.audio:playOnce( -- 933
					"fe06:e02:child_echo:" .. tostring(self.roomSessionId), -- 934
					"sfx", -- 935
					____exports.MUSEUM_AUDIO.childStepsEcho, -- 936
					0.72, -- 937
					"museum:e02:child_steps_echo", -- 938
					p.ticks -- 939
				) -- 939
			end -- 939
		end -- 939
		local ____view_isRehearsal_20 -- 944
		if view.isRehearsal then -- 944
			____view_isRehearsal_20 = math.abs(self.hallWalkX - self.lampX) <= 72 -- 945
		else -- 945
			____view_isRehearsal_20 = (p.phase == "museum-hall" or p.phase == "museum-lamp") and math.abs(p.player.x - (self.lampX + p.ox)) <= 72 -- 946
		end -- 946
		self.nearLamp = ____view_isRehearsal_20 -- 944
		self.savedResume = self:exportResumeState() -- 948
		if self.nearLamp and interactPressed then -- 948
			self:submitMuseumIntent(p, "lamp_turn") -- 951
		end -- 951
		return -- 953
	end -- 953
	if effectivePhase == "lamp_turn" then -- 953
		self:syncLoops(ctx, false, 0, true) -- 958
		if wdt > 0 then -- 958
			self.lampElapsed = self.lampElapsed + wdt -- 960
		end -- 960
		if p.room.key == "museum" then -- 960
			local targetX = clamp(p.player.x - p.ox, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 964
			local delta = targetX - self.hallWalkX -- 965
			self.hallMoving = math.abs(delta) > 0.25 -- 966
			if self.hallMoving then -- 966
				self.hallFacing = delta >= 0 and 1 or -1 -- 968
				self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 969
			end -- 969
			self.hallWalkX = targetX -- 971
			self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * math.min(1, udt * 5.2) -- 972
		end -- 972
		ctx.audio:playOnce( -- 974
			"fe06:e02:lamp_turn:" .. tostring(self.roomSessionId), -- 975
			"sfx", -- 976
			____exports.MUSEUM_AUDIO.lampTurn, -- 977
			0.82, -- 978
			"museum:e02:lamp_turn", -- 979
			p.ticks -- 980
		) -- 980
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 980
			self.lineDawnShown = true -- 983
			ctx.audio:playOnce( -- 984
				"fe06:e02:line_dawn:" .. tostring(self.roomSessionId), -- 985
				"voice", -- 986
				____exports.MUSEUM_AUDIO.lineDawn, -- 987
				0.92, -- 988
				"museum:e02:line_dawn", -- 989
				p.ticks -- 990
			) -- 990
		end -- 990
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampKnock1At and not self.knock1Played then -- 990
			self.knock1Played = true -- 994
			self.knock1VisualT = 0.85 -- 995
			ctx.audio:playOnce( -- 996
				"fe06:e02:knock1:" .. tostring(self.roomSessionId), -- 997
				"sfx", -- 998
				____exports.MUSEUM_AUDIO.knockHallFirst, -- 999
				0.88, -- 1000
				"museum:knock:1", -- 1001
				p.ticks -- 1002
			) -- 1002
		end -- 1002
		self.savedResume = self:exportResumeState() -- 1005
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampTurnDuration and not self.beginReturnSubmitted then -- 1005
			self.beginReturnSubmitted = true -- 1008
			self:submitMuseumIntent(p, "begin_return_cabinet") -- 1009
			local contract = resolveRuntimeContract(self.injectedContract) -- 1010
			if contract ~= nil and contract:isRehearsal() then -- 1010
				contract:enterMockMuseum("return_cabinet") -- 1012
			end -- 1012
		end -- 1012
		return -- 1015
	end -- 1015
	if phase == "return_cabinet" then -- 1015
		self:syncLoops(ctx, false, 0, false) -- 1020
		if wdt > 0 then -- 1020
			self.returnElapsed = self.returnElapsed + wdt -- 1022
		end -- 1022
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnKnock2At and not self.knock2Played then -- 1022
			self.knock2Played = true -- 1025
			self.knock2VisualT = 0.9 -- 1026
			ctx.audio:playOnce( -- 1027
				"fe06:e02:knock2:" .. tostring(self.roomSessionId), -- 1028
				"sfx", -- 1029
				____exports.MUSEUM_AUDIO.knockCabinetSecond, -- 1030
				0.92, -- 1031
				"museum:knock:2", -- 1032
				p.ticks -- 1033
			) -- 1033
		end -- 1033
		self.savedResume = self:exportResumeState() -- 1036
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnCabinetDuration and not self.returnCompleteSubmitted then -- 1036
			self.returnCompleteSubmitted = true -- 1039
			self:submitMuseumIntent(p, "return_cabinet") -- 1040
		end -- 1040
	end -- 1040
end -- 707
function WellMuseumPlugin.prototype.drawBackdrop(self, bgDraw, _bgGlow, _backdropArt, ctx) -- 1045
	if ctx.view.visualMode ~= "museum" then -- 1045
		return false -- 1052
	end -- 1052
	bgDraw:drawRect( -- 1055
		Rect(0, 0, ctx.w, ctx.h), -- 1055
		Color(11, 13, 18, 255) -- 1055
	) -- 1055
	return true -- 1056
end -- 1045
function WellMuseumPlugin.prototype.drawWorld(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1059
	return ctx.view.visualMode == "museum" -- 1065
end -- 1059
function WellMuseumPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1068
	return ctx.view.visualMode == "museum" -- 1074
end -- 1068
function WellMuseumPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1080
	if not self.gateOpen or ctx.view.visualMode == "museum" then -- 1080
		return -- 1087
	end -- 1087
	local cam = ctx.cam -- 1089
	local wellCx = cam:sx(self.wellWorldX) -- 1090
	local groundY = cam:sy(0, 0) -- 1091
	local phase = ctx.view.archive.museumPhase -- 1092
	local activeLure = phase == "well_open" and not ctx.view.archive.museumSeen -- 1093
	local rimH = cam:len(26) -- 1095
	worldArt:tryPlace( -- 1097
		"fe_well_rim", -- 1097
		"fe06_world_well_px", -- 1097
		wellCx, -- 1097
		groundY - 2, -- 1097
		cam:len(68), -- 1097
		cam:len(38), -- 1097
		{opacity = 0.98, layer = 36} -- 1097
	) -- 1097
	local dripCycle = self.animTime * 0.58 % 1 -- 1102
	local rippleR = cam:len(3 + dripCycle * 11) -- 1103
	local rippleAlpha = math.floor((1 - dripCycle) * (activeLure and 155 or 42) + 0.5) -- 1104
	if activeLure then -- 1104
		local shimmer = 0.65 + 0.35 * math.sin(self.animTime * 2.9) -- 1106
		fgDraw:drawCircle( -- 1107
			Vec2(wellCx, groundY + rimH), -- 1107
			cam:len(2.6), -- 1107
			Color( -- 1107
				236, -- 1107
				244, -- 1107
				252, -- 1107
				math.floor(215 * shimmer + 0.5) -- 1107
			) -- 1107
		) -- 1107
		drawEllipseRing( -- 1108
			fgDraw, -- 1108
			wellCx, -- 1108
			groundY + rimH, -- 1108
			rippleR, -- 1108
			rippleR * 0.36, -- 1108
			Color(0, 0, 0, 0), -- 1108
			1.1, -- 1108
			Color(210, 226, 242, rippleAlpha), -- 1108
			24 -- 1108
		) -- 1108
		fillRadialGlow( -- 1109
			fgGlow, -- 1110
			wellCx, -- 1111
			groundY + rimH + cam:len(8), -- 1112
			cam:len(30), -- 1113
			cam:len(38), -- 1114
			Color( -- 1115
				206, -- 1115
				224, -- 1115
				244, -- 1115
				math.floor(52 * shimmer + 0.5) -- 1115
			), -- 1115
			Color(148, 178, 212, 0), -- 1116
			16 -- 1117
		) -- 1117
		if dripCycle < 0.24 then -- 1117
			local dropK = dripCycle / 0.24 -- 1120
			local dropY = groundY + cam:len(64) - dropK * cam:len(38) -- 1121
			fgDraw:drawSegment( -- 1122
				Vec2(wellCx, dropY), -- 1123
				Vec2( -- 1124
					wellCx, -- 1124
					dropY + cam:len(4.5) -- 1124
				), -- 1124
				1.4, -- 1125
				Color(214, 228, 244, 185) -- 1126
			) -- 1126
		end -- 1126
	elseif self.revisitCalmTimer > 0 then -- 1126
		local calmK = 1 - clamp01(self.revisitCalmTimer / 1.4) -- 1130
		local calmR = cam:len(3 + calmK * 10) -- 1131
		drawEllipseRing( -- 1132
			fgDraw, -- 1133
			wellCx, -- 1134
			groundY + rimH, -- 1135
			calmR, -- 1136
			calmR * 0.35, -- 1137
			Color(0, 0, 0, 0), -- 1138
			1, -- 1139
			Color( -- 1140
				148, -- 1140
				160, -- 1140
				172, -- 1140
				math.floor((1 - calmK) * 120 + 0.5) -- 1140
			), -- 1140
			24 -- 1141
		) -- 1141
	end -- 1141
end -- 1080
function WellMuseumPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1151
	local view = ctx.view -- 1158
	local phase = view.archive.museumPhase -- 1159
	if view.visualMode ~= "museum" then -- 1159
		if self.gateOpen and self.nearWell and view.assistHintsEnabled and phase == "well_open" and not view.archive.museumSeen then -- 1159
			local sx = ctx.cam:sx(self.wellWorldX) / ctx.uiScale -- 1164
			local sy = (ctx.cam:sy(0, 0) + ctx.cam:len(54)) / ctx.uiScale -- 1165
			drawSilkVeil( -- 1166
				uiDraw, -- 1166
				uiArt, -- 1166
				"fe06_well_hint_veil", -- 1166
				sx, -- 1166
				sy, -- 1166
				132, -- 1166
				26, -- 1166
				PALETTE.panelBg, -- 1166
				0.82, -- 1166
				1 -- 1166
			) -- 1166
			ctx.texts:put( -- 1167
				"xs", -- 1168
				adaptHintSentence("[E] 俯身看井", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1169
				sx, -- 1170
				sy, -- 1171
				toColor(PALETTE.textBright), -- 1172
				0.5, -- 1173
				0.5, -- 1174
				"Center", -- 1175
				0.6, -- 1176
				0.92 -- 1177
			) -- 1177
		end -- 1177
		return false -- 1180
	end -- 1180
	local w = ctx.uiW -- 1183
	local h = ctx.uiH -- 1184
	local effectivePhase = ctx.p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 1186
	if effectivePhase == "well_reflect" then -- 1186
		self:renderE01WellReflectMatchCut( -- 1191
			uiDraw, -- 1191
			uiInkDraw, -- 1191
			uiArt, -- 1191
			uiGlow, -- 1191
			ctx, -- 1191
			w, -- 1191
			h -- 1191
		) -- 1191
		return true -- 1192
	end -- 1192
	if effectivePhase == "hall_walk" then -- 1192
		self:renderE02MuseumHall( -- 1195
			uiDraw, -- 1195
			uiInkDraw, -- 1195
			uiArt, -- 1195
			uiGlow, -- 1195
			ctx, -- 1195
			w, -- 1195
			h, -- 1195
			0, -- 1195
			false -- 1195
		) -- 1195
		return true -- 1196
	end -- 1196
	if effectivePhase == "lamp_turn" then -- 1196
		local turnProg = smoothstep(0, 1.15, self.lampElapsed) -- 1199
		self:renderE02MuseumHall( -- 1200
			uiDraw, -- 1200
			uiInkDraw, -- 1200
			uiArt, -- 1200
			uiGlow, -- 1200
			ctx, -- 1200
			w, -- 1200
			h, -- 1200
			turnProg, -- 1200
			true -- 1200
		) -- 1200
		return true -- 1201
	end -- 1201
	if effectivePhase == "return_cabinet" then -- 1201
		self:renderE02ReturnCabinet( -- 1204
			uiDraw, -- 1204
			uiInkDraw, -- 1204
			uiArt, -- 1204
			uiGlow, -- 1204
			ctx, -- 1204
			w, -- 1204
			h -- 1204
		) -- 1204
		return true -- 1205
	end -- 1205
	return false -- 1207
end -- 1151
function WellMuseumPlugin.prototype.renderE01WellReflectMatchCut(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1213
	local t = self.reflectElapsed -- 1222
	local ax = self.wellAnchorX -- 1223
	local ay = self.wellAnchorY -- 1224
	local compK = smoothstep(0.45, 1.15, t) -- 1225
	local matchK = smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, t) -- 1226
	local rect = computeFullscreenSlideRect(w, h) -- 1227
	uiDraw:drawRect( -- 1229
		Rect(0, 0, w, h), -- 1229
		Color(8, 10, 15, 255) -- 1229
	) -- 1229
	local wellOp = 1 - compK * 0.85 -- 1232
	local compOp = compK * (1 - matchK * 0.85) -- 1233
	if wellOp > 0.02 then -- 1233
		drawPixelSlidePlate( -- 1235
			uiDraw, -- 1235
			uiInkDraw, -- 1235
			uiArt, -- 1235
			"slide_e01_well", -- 1235
			"fe06_e01_well", -- 1235
			rect, -- 1235
			wellOp, -- 1235
			0, -- 1235
			0, -- 1235
			0, -- 1235
			1 + compK * 0.03 -- 1235
		) -- 1235
	end -- 1235
	if compOp > 0.02 then -- 1235
		drawPixelSlidePlate( -- 1238
			uiDraw, -- 1238
			uiInkDraw, -- 1238
			uiArt, -- 1238
			"slide_e01_compass", -- 1238
			"fe06_e01_comp", -- 1238
			rect, -- 1238
			compOp, -- 1238
			1, -- 1238
			0, -- 1238
			0, -- 1238
			1 + matchK * 0.03 -- 1238
		) -- 1238
	end -- 1238
	if matchK > 0.02 then -- 1238
		drawPixelSlidePlate( -- 1241
			uiDraw, -- 1241
			uiInkDraw, -- 1241
			uiArt, -- 1241
			"slide_e01_vitrine", -- 1241
			"fe06_e01_vitrine", -- 1241
			rect, -- 1241
			matchK, -- 1241
			2, -- 1241
			0, -- 1241
			0, -- 1241
			1.03 - matchK * 0.03 -- 1241
		) -- 1241
	end -- 1241
	local wellAlpha = 1 - matchK -- 1245
	if wellAlpha > 0.02 then -- 1245
		local ri = 0 -- 1247
		do -- 1247
			ri = 0 -- 1248
			while ri < 3 do -- 1248
				local cyc = (t * 0.42 + ri * 0.33) % 1 -- 1249
				local r = 18 + cyc * 140 -- 1250
				local ra = math.floor((1 - cyc) * 76 * wellAlpha + 0.5) -- 1251
				drawCircleRing( -- 1252
					uiInkDraw, -- 1252
					ax, -- 1252
					ay, -- 1252
					r, -- 1252
					Color(0, 0, 0, 0), -- 1252
					1, -- 1252
					Color(176, 198, 222, ra), -- 1252
					32 -- 1252
				) -- 1252
				ri = ri + 1 -- 1248
			end -- 1248
		end -- 1248
		if t >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 1248
			local capA = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellPickupAt + 0.35, t) * (1 - matchK) -- 1255
			if capA > 0.03 then -- 1255
				drawSilkVeil( -- 1257
					uiDraw, -- 1257
					uiArt, -- 1257
					"fe06_pickup_veil", -- 1257
					w * 0.5, -- 1257
					96, -- 1257
					300, -- 1257
					34, -- 1257
					PALETTE.inkVoid, -- 1257
					0.78 * capA, -- 1257
					6 -- 1257
				) -- 1257
				ctx.texts:put( -- 1258
					"sm", -- 1258
					"拾起「时间穿梭器」", -- 1258
					w * 0.5, -- 1258
					96, -- 1258
					toColor(PALETTE.amberCore), -- 1258
					0.5, -- 1258
					0.5, -- 1258
					"Center", -- 1258
					1.4, -- 1258
					capA -- 1258
				) -- 1258
			end -- 1258
		end -- 1258
	end -- 1258
	local flashPeak = math.sin(matchK * math.pi) -- 1264
	local coreR = 7 + flashPeak * 16 -- 1265
	uiInkDraw:drawCircle( -- 1266
		Vec2(ax, ay), -- 1266
		coreR * 0.52, -- 1266
		Color(248, 252, 255, 245) -- 1266
	) -- 1266
	fillRadialGlow( -- 1267
		uiGlow, -- 1268
		ax, -- 1268
		ay, -- 1268
		48 + flashPeak * 140, -- 1269
		42 + flashPeak * 110, -- 1269
		Color( -- 1270
			238, -- 1270
			246, -- 1270
			255, -- 1270
			math.floor(135 + flashPeak * 95 + 0.5) -- 1270
		), -- 1270
		Color(174, 204, 238, 0), -- 1271
		20 -- 1272
	) -- 1272
	if flashPeak > 0.05 then -- 1272
		local rayW = 68 + flashPeak * 240 -- 1275
		fillHGradRect( -- 1276
			uiGlow, -- 1276
			ax - rayW, -- 1276
			ay - 2, -- 1276
			rayW, -- 1276
			4, -- 1276
			Color(224, 238, 252, 0), -- 1276
			Color( -- 1276
				242, -- 1276
				248, -- 1276
				255, -- 1276
				math.floor(150 * flashPeak + 0.5) -- 1276
			) -- 1276
		) -- 1276
		fillHGradRect( -- 1277
			uiGlow, -- 1277
			ax, -- 1277
			ay - 2, -- 1277
			rayW, -- 1277
			4, -- 1277
			Color( -- 1277
				242, -- 1277
				248, -- 1277
				255, -- 1277
				math.floor(150 * flashPeak + 0.5) -- 1277
			), -- 1277
			Color(224, 238, 252, 0) -- 1277
		) -- 1277
	end -- 1277
	self:drawLetterbox( -- 1280
		uiInkDraw, -- 1280
		w, -- 1280
		h, -- 1280
		42, -- 1280
		0.92 -- 1280
	) -- 1280
end -- 1213
function WellMuseumPlugin.prototype.renderE02MuseumHall(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, lampTurnProg, inLampTurn) -- 1286
	local floorY = 148 -- 1297
	local halfW = w * 0.5 -- 1298
	local camMin = math.min(____exports.MUSEUM_HALL_WIDTH * 0.5, halfW - 40) -- 1299
	local camMax = math.max(____exports.MUSEUM_HALL_WIDTH * 0.5, ____exports.MUSEUM_HALL_WIDTH - halfW + 40) -- 1300
	local camX = clamp(self.hallCamX, camMin, camMax) -- 1301
	local function toScreenX(hx) -- 1302
		return halfW + (hx - camX) -- 1302
	end -- 1302
	uiDraw:drawRect( -- 1305
		Rect(0, 0, w, h), -- 1305
		Color(13, 17, 23, 255) -- 1305
	) -- 1305
	local hallScreenW = math.max(w * 1.15, ____exports.MUSEUM_HALL_WIDTH + 120) -- 1306
	local hallScreenH = math.max( -- 1307
		h, -- 1307
		math.floor(hallScreenW * 9 / 16 + 0.5) -- 1307
	) -- 1307
	local hallCenterSx = toScreenX(____exports.MUSEUM_HALL_WIDTH * 0.5) -- 1308
	uiArt:tryPlace( -- 1309
		"slide_e02_museum_hall", -- 1309
		"fe06_hall_panorama", -- 1309
		math.floor(hallCenterSx + 0.5), -- 1309
		math.floor((h - hallScreenH) * 0.5 + 18 + 0.5), -- 1309
		math.floor(hallScreenW + 0.5), -- 1309
		hallScreenH, -- 1309
		{opacity = 1, layer = 0} -- 1309
	) -- 1309
	local plaqueWorldX = self.caseX <= 260 and 108 or 180 -- 1315
	local plaqueX = toScreenX(plaqueWorldX) -- 1316
	if plaqueX > -240 and plaqueX < w + 240 then -- 1316
		local py = floorY + 180 -- 1318
		ctx.texts:put( -- 1319
			"sm", -- 1319
			"海防抗战纪念展厅", -- 1319
			plaqueX, -- 1319
			py + 34, -- 1319
			toColor(PALETTE.textBright), -- 1319
			0.5, -- 1319
			0.5, -- 1319
			"Center", -- 1319
			2, -- 1319
			0.9 -- 1319
		) -- 1319
		ctx.texts:put( -- 1320
			"xs", -- 1320
			"温州宁村 · 守望史迹陈列", -- 1320
			plaqueX, -- 1320
			py - 2, -- 1320
			toColor(PALETTE.amber), -- 1320
			0.5, -- 1320
			0.5, -- 1320
			"Center", -- 1320
			1, -- 1320
			0.8 -- 1320
		) -- 1320
	end -- 1320
	local caseSx = toScreenX(self.caseX) -- 1324
	if caseSx > -240 and caseSx < w + 240 then -- 1324
		fillRadialGlow( -- 1326
			uiGlow, -- 1326
			caseSx, -- 1326
			floorY + 190, -- 1326
			96, -- 1326
			138, -- 1326
			Color(224, 236, 250, 48), -- 1326
			Color(168, 192, 220, 0), -- 1326
			16 -- 1326
		) -- 1326
	end -- 1326
	local lampSx = toScreenX(self.lampX) -- 1330
	local winSx = toScreenX(self.lampX + 108) -- 1331
	local reflectK = inLampTurn and smoothstep(____exports.MUSEUM_TIMINGS.lampReflectStart, 2.35, self.lampElapsed) or 0 -- 1332
	if winSx > -260 and winSx < w + 260 then -- 1332
		local winW = 248 -- 1337
		local winH = 310 -- 1338
		local winY = floorY + 34 -- 1339
		if reflectK > 0.02 then -- 1339
			uiArt:tryPlace( -- 1342
				"slide_e02_window_dawn", -- 1342
				"fe06_window_dawn_px", -- 1342
				math.floor(winSx + 0.5), -- 1342
				math.floor(winY + winH * 0.5 + 0.5), -- 1342
				winW, -- 1342
				winH, -- 1342
				{opacity = reflectK * 0.86, layer = 1} -- 1342
			) -- 1342
			fillRadialGlow( -- 1346
				uiGlow, -- 1346
				winSx, -- 1346
				winY + winH * 0.48, -- 1346
				136, -- 1346
				148, -- 1346
				Color( -- 1346
					246, -- 1346
					218, -- 1346
					168, -- 1346
					math.floor(86 * reflectK + 0.5) -- 1346
				), -- 1346
				Color(214, 174, 112, 0), -- 1346
				18 -- 1346
			) -- 1346
		end -- 1346
		local aimDir = -0.58 + lampTurnProg * 1.4 -- 1350
		local headX = lampSx + math.sin(aimDir) * 14 -- 1351
		local headY = floorY + 146 + math.cos(aimDir) * 10 -- 1352
		local beamLen = 132 + lampTurnProg * 84 -- 1353
		local bxEnd = headX + math.sin(aimDir) * beamLen -- 1354
		local byEnd = headY + math.cos(aimDir) * 28 -- 1355
		local perpX = -math.cos(aimDir) * 18 -- 1356
		local perpY = math.sin(aimDir) * 34 -- 1357
		fillGradQuad( -- 1358
			uiGlow, -- 1359
			headX, -- 1360
			headY - 4, -- 1360
			Color( -- 1360
				246, -- 1360
				224, -- 1360
				178, -- 1360
				math.floor(58 + 44 * lampTurnProg + 0.5) -- 1360
			), -- 1360
			headX, -- 1361
			headY + 4, -- 1361
			Color( -- 1361
				246, -- 1361
				224, -- 1361
				178, -- 1361
				math.floor(58 + 44 * lampTurnProg + 0.5) -- 1361
			), -- 1361
			bxEnd + perpX, -- 1362
			byEnd + perpY + 34, -- 1362
			Color(238, 206, 148, 0), -- 1362
			bxEnd - perpX, -- 1363
			byEnd - perpY - 22, -- 1363
			Color(238, 206, 148, 0) -- 1363
		) -- 1363
		fillRadialGlow( -- 1365
			uiGlow, -- 1365
			headX, -- 1365
			headY, -- 1365
			34, -- 1365
			34, -- 1365
			Color(246, 228, 186, 72), -- 1365
			Color(224, 194, 140, 0), -- 1365
			14 -- 1365
		) -- 1365
	end -- 1365
	local playerSx = toScreenX(self.hallWalkX) -- 1369
	local moving = not inLampTurn and (self.hallMoving or math.abs(ctx.input.moveX) > 0.05) -- 1370
	local slot = moving and "soldier_run" or "soldier_idle" -- 1371
	local frame = moving and math.floor(self.hallWalkAnim) or 0 -- 1372
	local charH = math.floor(192 * math.max( -- 1373
		0.75, -- 1373
		math.min(1.25, h / 720) -- 1373
	) + 0.5) -- 1373
	local charW = math.floor(charH * 0.45 + 0.5) -- 1374
	uiDraw:drawEllipse( -- 1375
		Vec2(playerSx, floorY + 2), -- 1375
		34, -- 1375
		6.5, -- 1375
		Color(6, 8, 12, 178) -- 1375
	) -- 1375
	uiArt:tryPlace( -- 1376
		slot, -- 1376
		"fe06_museum_zhoushu", -- 1376
		playerSx, -- 1376
		floorY + 2, -- 1376
		charW, -- 1376
		charH, -- 1376
		{facing = self.hallFacing, frame = frame, layer = 3} -- 1376
	) -- 1376
	if self.holstered and not inLampTurn and math.abs(self.hallWalkX - self.caseX) <= 130 then -- 1376
		local subA = clamp01(1 - math.abs(self.hallWalkX - self.caseX) / 145) * 0.86 -- 1384
		ctx.texts:put( -- 1385
			"xs", -- 1385
			"已收起随身器物", -- 1385
			caseSx, -- 1385
			floorY + 252, -- 1385
			toColor(PALETTE.textMid), -- 1385
			0.5, -- 1385
			0.5, -- 1385
			"Center", -- 1385
			0.9, -- 1385
			subA -- 1385
		) -- 1385
	end -- 1385
	if self.childEchoVisualT > 0 then -- 1385
		local echoK = 1 - clamp01(self.childEchoVisualT / 2.1) -- 1390
		local ex = math.min( -- 1391
			w - 110, -- 1391
			toScreenX(self.caseX + 310) -- 1391
		) -- 1391
		local ey = floorY + 32 -- 1392
		local ea = math.floor(math.sin(echoK * math.pi) * 165 + 0.5) -- 1393
		drawCircleRing( -- 1394
			uiInkDraw, -- 1394
			ex, -- 1394
			ey, -- 1394
			14 + echoK * 46, -- 1394
			Color(0, 0, 0, 0), -- 1394
			1.1, -- 1394
			Color(224, 214, 194, ea), -- 1394
			28 -- 1394
		) -- 1394
		drawCircleRing( -- 1395
			uiInkDraw, -- 1395
			ex, -- 1395
			ey, -- 1395
			8 + echoK * 28, -- 1395
			Color(0, 0, 0, 0), -- 1395
			0.9, -- 1395
			Color( -- 1395
				224, -- 1395
				214, -- 1395
				194, -- 1395
				math.floor(ea * 0.7 + 0.5) -- 1395
			), -- 1395
			24 -- 1395
		) -- 1395
		ctx.texts:put( -- 1396
			"xs", -- 1396
			"（远方传来轻快的孩童脚步声）", -- 1396
			w * 0.5, -- 1396
			84, -- 1396
			toColor(PALETTE.textMid), -- 1396
			0.5, -- 1396
			0.5, -- 1396
			"Center", -- 1396
			1, -- 1396
			math.sin(echoK * math.pi) * 0.85 -- 1396
		) -- 1396
	end -- 1396
	if not inLampTurn then -- 1396
		local fadeIn = smoothstep(0, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn, self.hallIntroElapsed) -- 1401
		local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold + ____exports.MUSEUM_TIMINGS.hallIntroFadeOut, self.hallIntroElapsed) -- 1402
		local introA = fadeIn * fadeOut -- 1407
		if introA > 0.02 then -- 1407
			drawSilkVeil( -- 1409
				uiDraw, -- 1409
				uiArt, -- 1409
				"fe06_hall_intro_veil", -- 1409
				w * 0.5, -- 1409
				h - 104, -- 1409
				480, -- 1409
				74, -- 1409
				PALETTE.inkVoid, -- 1409
				0.78 * introA, -- 1409
				5 -- 1409
			) -- 1409
			drawHairline( -- 1410
				uiInkDraw, -- 1410
				uiArt, -- 1410
				"fe06_hall_intro_line", -- 1410
				w * 0.5, -- 1410
				h - 106, -- 1410
				260, -- 1410
				PALETTE.silkLine, -- 1410
				0.45 * introA, -- 1410
				false, -- 1410
				6 -- 1410
			) -- 1410
			ctx.texts:put( -- 1411
				"md", -- 1411
				____exports.MUSEUM_HALL_TITLE, -- 1411
				w * 0.5, -- 1411
				h - 88, -- 1411
				toColor(PALETTE.textBright), -- 1411
				0.5, -- 1411
				0.5, -- 1411
				"Center", -- 1411
				1.8, -- 1411
				introA -- 1411
			) -- 1411
			ctx.texts:put( -- 1412
				"xs", -- 1412
				____exports.MUSEUM_HALL_SUBTITLE, -- 1412
				w * 0.5, -- 1412
				h - 122, -- 1412
				toColor(PALETTE.amberCore), -- 1412
				0.5, -- 1412
				0.5, -- 1412
				"Center", -- 1412
				1.2, -- 1412
				introA * 0.88 -- 1412
			) -- 1412
		end -- 1412
		if self.nearLamp and ctx.view.assistHintsEnabled then -- 1412
			drawSilkVeil( -- 1416
				uiDraw, -- 1416
				uiArt, -- 1416
				"fe06_lamp_hint_veil", -- 1416
				lampSx, -- 1416
				floorY + 158, -- 1416
				146, -- 1416
				28, -- 1416
				PALETTE.panelBg, -- 1416
				0.84, -- 1416
				5 -- 1416
			) -- 1416
			ctx.texts:put( -- 1417
				"xs", -- 1418
				adaptHintSentence("[E] 转动西窗灯", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1419
				lampSx, -- 1420
				floorY + 158, -- 1421
				toColor(PALETTE.textBright), -- 1422
				0.5, -- 1423
				0.5, -- 1424
				"Center", -- 1425
				0.6, -- 1426
				0.94 -- 1427
			) -- 1427
		end -- 1427
	end -- 1427
	if inLampTurn and self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1427
		local lineA = smoothstep(____exports.MUSEUM_TIMINGS.lampLineAt, ____exports.MUSEUM_TIMINGS.lampLineAt + 0.45, self.lampElapsed) * (1 - smoothstep(____exports.MUSEUM_TIMINGS.lampTurnDuration - 0.35, ____exports.MUSEUM_TIMINGS.lampTurnDuration, self.lampElapsed)) -- 1434
		if lineA > 0.02 then -- 1434
			drawSilkVeil( -- 1437
				uiDraw, -- 1437
				uiArt, -- 1437
				"fe06_dawn_line_veil", -- 1437
				w * 0.5, -- 1437
				86, -- 1437
				440, -- 1437
				50, -- 1437
				PALETTE.inkVoid, -- 1437
				0.84 * lineA, -- 1437
				5 -- 1437
			) -- 1437
			ctx.texts:put( -- 1438
				"md", -- 1438
				____exports.MUSEUM_LINE_DAWN, -- 1438
				w * 0.5, -- 1438
				86, -- 1438
				toColor(PALETTE.amberCore), -- 1438
				0.5, -- 1438
				0.5, -- 1438
				"Center", -- 1438
				1.6, -- 1438
				lineA -- 1438
			) -- 1438
		end -- 1438
	end -- 1438
	if self.knock1VisualT > 0 then -- 1438
		local k1 = 1 - clamp01(self.knock1VisualT / 0.85) -- 1443
		local k1A = math.floor((1 - k1) * 205 + 0.5) -- 1444
		drawCircleRing( -- 1445
			uiInkDraw, -- 1445
			winSx, -- 1445
			floorY + 148, -- 1445
			12 + k1 * 64, -- 1445
			Color(0, 0, 0, 0), -- 1445
			1.6, -- 1445
			Color(242, 232, 206, k1A), -- 1445
			28 -- 1445
		) -- 1445
		drawCircleRing( -- 1446
			uiInkDraw, -- 1446
			winSx, -- 1446
			floorY + 148, -- 1446
			6 + k1 * 34, -- 1446
			Color(0, 0, 0, 0), -- 1446
			1.1, -- 1446
			Color( -- 1446
				242, -- 1446
				232, -- 1446
				206, -- 1446
				math.floor(k1A * 0.72 + 0.5) -- 1446
			), -- 1446
			24 -- 1446
		) -- 1446
	end -- 1446
	self:drawLetterbox( -- 1449
		uiInkDraw, -- 1449
		w, -- 1449
		h, -- 1449
		38, -- 1449
		0.9 -- 1449
	) -- 1449
end -- 1286
function WellMuseumPlugin.prototype.renderE02ReturnCabinet(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx, w, h) -- 1455
	local t = self.returnElapsed -- 1464
	local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.returnFadeOutAt, ____exports.MUSEUM_TIMINGS.returnCabinetDuration, t) -- 1465
	uiDraw:drawRect( -- 1467
		Rect(0, 0, w, h), -- 1467
		Color( -- 1467
			7, -- 1467
			9, -- 1467
			13, -- 1467
			math.floor(252 * fadeOut + 0.5) -- 1467
		) -- 1467
	) -- 1467
	if t < ____exports.MUSEUM_TIMINGS.returnKnock2At then -- 1467
		self:drawLetterbox( -- 1470
			uiInkDraw, -- 1470
			w, -- 1470
			h, -- 1470
			42, -- 1470
			0.95 * fadeOut -- 1470
		) -- 1470
		return -- 1471
	end -- 1471
	local revealK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.34, t) * fadeOut -- 1474
	local rect = computeCenteredSlideRect( -- 1475
		w, -- 1475
		h, -- 1475
		860, -- 1475
		484, -- 1475
		12 -- 1475
	) -- 1475
	local knockShake = self.knock2VisualT > 0.65 and math.sin(t * 120) * 2.4 or 0 -- 1476
	local shiftedRect = { -- 1477
		x = math.floor(rect.x + knockShake + 0.5), -- 1477
		y = rect.y, -- 1477
		w = rect.w, -- 1477
		h = rect.h -- 1477
	} -- 1477
	drawPixelSlidePlate( -- 1479
		uiDraw, -- 1480
		uiInkDraw, -- 1481
		uiArt, -- 1482
		"slide_e02_return_cabinet", -- 1483
		"fe06_return_cab_px", -- 1484
		shiftedRect, -- 1485
		revealK, -- 1486
		2, -- 1487
		0, -- 1488
		0, -- 1489
		1 + (1 - revealK) * 0.02 -- 1490
	) -- 1490
	drawSlideFrameChrome( -- 1492
		uiDraw, -- 1492
		uiInkDraw, -- 1492
		uiArt, -- 1492
		shiftedRect, -- 1492
		w, -- 1492
		h, -- 1492
		{frameOpacity = 0.92, opacity = revealK, layer = 2, instancePrefix = "fe06_return_cab"} -- 1492
	) -- 1492
	if self.knock2VisualT > 0 then -- 1492
		local k2 = 1 - clamp01(self.knock2VisualT / 0.9) -- 1501
		local k2A = math.floor((1 - k2) * 215 * fadeOut + 0.5) -- 1502
		drawCircleRing( -- 1503
			uiInkDraw, -- 1503
			rect.x + rect.w * 0.78, -- 1503
			rect.y + rect.h * 0.5, -- 1503
			10 + k2 * 56, -- 1503
			Color(0, 0, 0, 0), -- 1503
			1.6, -- 1503
			Color(232, 220, 196, k2A), -- 1503
			28 -- 1503
		) -- 1503
	end -- 1503
	local tipA = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.45, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.95, t) * fadeOut -- 1506
	if tipA > 0.03 then -- 1506
		drawSilkVeil( -- 1508
			uiDraw, -- 1508
			uiArt, -- 1508
			"fe06_return_veil", -- 1508
			w * 0.5, -- 1508
			rect.y - 26, -- 1508
			320, -- 1508
			32, -- 1508
			PALETTE.inkVoid, -- 1508
			0.72 * tipA, -- 1508
			7 -- 1508
		) -- 1508
		ctx.texts:put( -- 1509
			"xs", -- 1509
			"两声轻敲落回柜板 · 寻回小满", -- 1509
			w * 0.5, -- 1509
			rect.y - 26, -- 1509
			toColor(PALETTE.textMid), -- 1509
			0.5, -- 1509
			0.5, -- 1509
			"Center", -- 1509
			1.2, -- 1509
			tipA * 0.9 -- 1509
		) -- 1509
	end -- 1509
	self:drawLetterbox( -- 1512
		uiInkDraw, -- 1512
		w, -- 1512
		h, -- 1512
		42, -- 1512
		0.95 * fadeOut -- 1512
	) -- 1512
end -- 1455
function WellMuseumPlugin.prototype.drawLetterbox(self, draw, w, h, barH, opacity) -- 1515
	local a = math.floor(244 * clamp01(opacity) + 0.5) -- 1516
	if a <= 2 then -- 1516
		return -- 1518
	end -- 1518
	draw:drawRect( -- 1520
		Rect(0, 0, w, barH), -- 1520
		Color(6, 8, 12, a) -- 1520
	) -- 1520
	draw:drawRect( -- 1521
		Rect(0, h - barH, w, barH), -- 1521
		Color(6, 8, 12, a) -- 1521
	) -- 1521
end -- 1515
function ____exports.createWellMuseumPlugin(contract) -- 1525
	return __TS__New(____exports.WellMuseumPlugin, contract) -- 1526
end -- 1525
return ____exports -- 1525