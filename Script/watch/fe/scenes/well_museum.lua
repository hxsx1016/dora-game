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
local ____target = require("Script.watch.target") -- 43
local getActiveTarget = ____target.getActiveTarget -- 43
local ____theme = require("Script.watch.fe.theme") -- 44
local PALETTE = ____theme.PALETTE -- 45
local drawHairline = ____theme.drawHairline -- 46
local drawSilkVeil = ____theme.drawSilkVeil -- 47
local fillGradQuad = ____theme.fillGradQuad -- 48
local fillHGradRect = ____theme.fillHGradRect -- 49
local fillRadialGlow = ____theme.fillRadialGlow -- 50
local fillVGradRect = ____theme.fillVGradRect -- 51
local toColor = ____theme.toColor -- 53
____exports.WELL_WORLD_X = 430 -- 56
____exports.WELL_INTERACT_REACH = 46 -- 57
____exports.MATCH_CUT_ANCHOR_NX = 0.5 -- 58
____exports.MATCH_CUT_ANCHOR_NY = 0.54 -- 59
____exports.MUSEUM_HALL_WIDTH = 1360 -- 60
____exports.MUSEUM_ENTRY_X = 180 -- 61
____exports.MUSEUM_CASE_X = 600 -- 62
____exports.MUSEUM_LAMP_X = 1140 -- 63
____exports.MUSEUM_WALK_SPEED = 156 -- 64
____exports.MUSEUM_LINE_DAWN = "「小满，外头天亮了。」" -- 65
____exports.MUSEUM_HALL_TITLE = "现代 · 宁村海防抗战纪念展厅" -- 66
____exports.MUSEUM_HALL_SUBTITLE = "山河安然，守望未绝" -- 67
____exports.MUSEUM_TIMINGS = { -- 69
	wellReflectDuration = 3.2, -- 70
	wellPickupAt = 1.1, -- 71
	wellMatchCutStart = 1.9, -- 72
	hallIntroFadeIn = 0.55, -- 73
	hallIntroHold = 3.4, -- 74
	hallIntroFadeOut = 0.85, -- 75
	childEchoDelay = 0.52, -- 76
	lampTurnDuration = 3.8, -- 77
	lampReflectStart = 0.65, -- 78
	lampLineAt = 1.45, -- 79
	lampKnock1At = 3.15, -- 80
	returnCabinetDuration = 2.6, -- 81
	returnKnock2At = 0.42, -- 82
	returnFadeOutAt = 2.2 -- 83
} -- 83
local MUSEUM_AUDIO_ROOT = "assets/audio/museum/" -- 86
____exports.MUSEUM_AUDIO = { -- 87
	wellDripLoop = MUSEUM_AUDIO_ROOT .. "well_drip_loop.wav", -- 88
	artifactPickup = MUSEUM_AUDIO_ROOT .. "artifact_pickup.wav", -- 89
	matchCutTransition = MUSEUM_AUDIO_ROOT .. "match_cut_transition.wav", -- 90
	hallAmbienceLoop = MUSEUM_AUDIO_ROOT .. "hall_ambience_loop.wav", -- 91
	hallFootstep = MUSEUM_AUDIO_ROOT .. "hall_footstep.wav", -- 92
	weaponHolster = MUSEUM_AUDIO_ROOT .. "weapon_holster.wav", -- 93
	childStepsEcho = MUSEUM_AUDIO_ROOT .. "child_steps_echo.wav", -- 94
	lampTurn = MUSEUM_AUDIO_ROOT .. "lamp_turn.wav", -- 95
	knockHallFirst = MUSEUM_AUDIO_ROOT .. "knock_hall_first.wav", -- 96
	knockCabinetSecond = MUSEUM_AUDIO_ROOT .. "knock_cabinet_second.wav", -- 97
	lineDawn = MUSEUM_AUDIO_ROOT .. "line_dawn.wav" -- 98
} -- 98
local LOOP_WELL_DRIP = "fe06_well_drip" -- 101
local LOOP_HALL_AMBIENCE = "fe06_hall_ambience" -- 102
local function clamp(v, lo, hi) -- 158
	return math.max( -- 159
		lo, -- 159
		math.min(hi, v) -- 159
	) -- 159
end -- 158
local function clamp01(v) -- 162
	return clamp(v, 0, 1) -- 163
end -- 162
local function smoothstep(edge0, edge1, x) -- 166
	if edge1 <= edge0 then -- 166
		return x >= edge1 and 1 or 0 -- 168
	end -- 168
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 170
	return t * t * (3 - 2 * t) -- 171
end -- 166
local function drawEllipseRing(draw, cx, cy, rx, ry, fillCol, borderWidth, borderCol, segments) -- 174
	if segments == nil then -- 174
		segments = 28 -- 183
	end -- 183
	if rx <= 0.5 or ry <= 0.5 then -- 183
		return -- 186
	end -- 186
	local pts = {} -- 188
	local step = math.pi * 2 / segments -- 189
	local i = 0 -- 190
	do -- 190
		i = 0 -- 191
		while i < segments do -- 191
			local a = i * step -- 192
			pts[#pts + 1] = Vec2( -- 193
				cx + math.cos(a) * rx, -- 193
				cy + math.sin(a) * ry -- 193
			) -- 193
			i = i + 1 -- 191
		end -- 191
	end -- 191
	draw:drawPolygon(pts, fillCol, borderWidth, borderCol) -- 195
end -- 174
local function drawCircleRing(draw, cx, cy, r, fillCol, borderWidth, borderCol, segments) -- 198
	if segments == nil then -- 198
		segments = 28 -- 206
	end -- 206
	drawEllipseRing( -- 208
		draw, -- 208
		cx, -- 208
		cy, -- 208
		r, -- 208
		r, -- 208
		fillCol, -- 208
		borderWidth, -- 208
		borderCol, -- 208
		segments -- 208
	) -- 208
end -- 198
local function asRecord(v) -- 211
	if v ~= nil and type(v) == "table" then -- 211
		return v -- 213
	end -- 213
	return nil -- 215
end -- 211
local function readNum(rec, key) -- 218
	if rec == nil then -- 218
		return nil -- 220
	end -- 220
	local val = rec[key] -- 222
	return type(val) == "number" and val or nil -- 223
end -- 218
local function readBool(rec, key) -- 226
	if rec == nil then -- 226
		return nil -- 228
	end -- 228
	local val = rec[key] -- 230
	local ____temp_0 -- 231
	if type(val) == "boolean" then -- 231
		____temp_0 = val -- 231
	else -- 231
		____temp_0 = nil -- 231
	end -- 231
	return ____temp_0 -- 231
end -- 226
local function resolveRuntimeContract(injected) -- 234
	if injected ~= nil then -- 234
		return injected -- 236
	end -- 236
	local g = _G -- 238
	local ____temp_1 -- 239
	if g.package ~= nil then -- 239
		____temp_1 = g.package.loaded -- 239
	else -- 239
		____temp_1 = nil -- 239
	end -- 239
	local loaded = ____temp_1 -- 239
	if loaded == nil then -- 239
		return nil -- 241
	end -- 241
	local rawFe = loaded["watch.fe"] -- 243
	if rawFe ~= nil and type(rawFe) == "table" then -- 243
		local c = rawFe.contract -- 245
		if c ~= nil and type(c) == "table" then -- 245
			return c -- 247
		end -- 247
	end -- 247
	return nil -- 250
end -- 234
local function isPrologueIntroBlocking() -- 253
	local g = _G -- 254
	local ____temp_2 -- 255
	if g.package ~= nil then -- 255
		____temp_2 = g.package.loaded -- 255
	else -- 255
		____temp_2 = nil -- 255
	end -- 255
	local loaded = ____temp_2 -- 255
	if loaded == nil then -- 255
		return false -- 257
	end -- 257
	local rawFe = loaded["watch.fe"] -- 259
	if rawFe == nil or type(rawFe) ~= "table" then -- 259
		return false -- 261
	end -- 261
	local prologue = rawFe.prologue -- 263
	if prologue == nil or type(prologue) ~= "table" then -- 263
		return false -- 265
	end -- 265
	local fn = prologue.getSnapshot -- 267
	if type(fn) ~= "function" then -- 267
		return false -- 269
	end -- 269
	local snap = asRecord(fn(prologue)) -- 271
	if readBool(snap, "blocksPlayerControl") == true then -- 271
		return true -- 273
	end -- 273
	local stage = snap ~= nil and type(snap.stage) == "string" and snap.stage or "idle" -- 276
	return stage == "p02_escape" or stage == "p02_hidden" -- 277
end -- 253
local function isActiveMuseumPhase(phase) -- 280
	return phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" -- 281
end -- 280
____exports.WellMuseumPlugin = __TS__Class() -- 287
local WellMuseumPlugin = ____exports.WellMuseumPlugin -- 287
WellMuseumPlugin.name = "WellMuseumPlugin" -- 287
function WellMuseumPlugin.prototype.____constructor(self, contract) -- 353
	self.id = "fe-06-well-museum" -- 288
	self.animTime = 0 -- 291
	self.prevPhase = "locked" -- 292
	self.roomSessionId = 0 -- 293
	self.rehearsal = false -- 294
	self.gateOpen = false -- 297
	self.gateBlockedReason = "locked" -- 298
	self.wellWorldX = ____exports.WELL_WORLD_X -- 299
	self.caseX = ____exports.MUSEUM_CASE_X -- 300
	self.lampX = ____exports.MUSEUM_LAMP_X -- 301
	self.nearWell = false -- 302
	self.revisitCalmTimer = 0 -- 303
	self.revisitCalmCount = 0 -- 304
	self.reflectElapsed = 0 -- 307
	self.wellAnchorX = 640 -- 308
	self.wellAnchorY = 388.8 -- 309
	self.glassAnchorX = 640 -- 310
	self.glassAnchorY = 388.8 -- 311
	self.enterHallSubmitted = false -- 312
	self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 315
	self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 316
	self.hallFacing = 1 -- 317
	self.hallWalkAnim = 0 -- 318
	self.hallMoving = false -- 319
	self.hallFootstepTimer = 0 -- 320
	self.hallIntroElapsed = 0 -- 321
	self.holstered = false -- 322
	self.childEchoCountdown = -1 -- 323
	self.childEchoPlayed = false -- 324
	self.childEchoVisualT = 0 -- 325
	self.nearLamp = false -- 326
	self.lampElapsed = 0 -- 328
	self.lineDawnShown = false -- 329
	self.knock1Played = false -- 330
	self.knock1VisualT = 0 -- 331
	self.beginReturnSubmitted = false -- 332
	self.returnElapsed = 0 -- 335
	self.knock2Played = false -- 336
	self.knock2VisualT = 0 -- 337
	self.returnCompleteSubmitted = false -- 338
	self.artifactGrantCount = 0 -- 341
	self.resumeRestoreCount = 0 -- 343
	self.lastResumePhase = "locked" -- 344
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 345
	self.lastVisualMode = "pixel" -- 346
	self.lastPaused = false -- 347
	self.wellDripPlaying = false -- 348
	self.hallAmbiencePlaying = false -- 349
	self.liveReflectDoneInMuseumRoom = false -- 350
	self.injectedContract = contract -- 354
end -- 353
function WellMuseumPlugin.prototype.syncRuntimeHook(self) -- 357
	local g = _G -- 358
	local ____temp_3 -- 359
	if g.package ~= nil then -- 359
		____temp_3 = g.package.loaded -- 359
	else -- 359
		____temp_3 = nil -- 359
	end -- 359
	local loaded = ____temp_3 -- 359
	if loaded == nil then -- 359
		return -- 361
	end -- 361
	local rawFe = loaded["watch.fe"] -- 363
	if rawFe ~= nil and type(rawFe) == "table" then -- 363
		local watchFe = rawFe -- 365
		if watchFe.wellMuseum ~= self then -- 365
			watchFe.wellMuseum = self -- 367
		end -- 367
	end -- 367
end -- 357
function WellMuseumPlugin.prototype.queueSimulatedInput(self, sim) -- 373
	self.simInput = {moveX = sim.moveX, interact = sim.interact} -- 374
end -- 373
function WellMuseumPlugin.prototype.exportResumeState(self) -- 381
	return { -- 382
		phase = self.prevPhase, -- 383
		hallWalkX = self.hallWalkX, -- 384
		hallCamX = self.hallCamX, -- 385
		hallFacing = self.hallFacing, -- 386
		holstered = self.holstered, -- 387
		childEchoPlayed = self.childEchoPlayed, -- 388
		reflectElapsed = self.reflectElapsed, -- 389
		lampElapsed = self.lampElapsed, -- 390
		returnElapsed = self.returnElapsed, -- 391
		artifactGrantCount = self.artifactGrantCount -- 392
	} -- 392
end -- 381
function WellMuseumPlugin.prototype.restoreResumeState(self, snap) -- 397
	if snap.phase ~= nil then -- 397
		self.prevPhase = snap.phase -- 399
		self.lastResumePhase = snap.phase -- 400
	end -- 400
	if snap.hallWalkX ~= nil then -- 400
		self.hallWalkX = clamp(snap.hallWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 403
		self.lastResumeWalkX = self.hallWalkX -- 404
	end -- 404
	if snap.hallCamX ~= nil then -- 404
		self.hallCamX = snap.hallCamX -- 407
	else -- 407
		self.hallCamX = self.hallWalkX -- 409
	end -- 409
	if snap.hallFacing ~= nil then -- 409
		self.hallFacing = snap.hallFacing >= 0 and 1 or -1 -- 412
	end -- 412
	if snap.holstered ~= nil then -- 412
		self.holstered = snap.holstered -- 415
	end -- 415
	if snap.childEchoPlayed ~= nil then -- 415
		self.childEchoPlayed = snap.childEchoPlayed -- 418
	end -- 418
	if snap.reflectElapsed ~= nil then -- 418
		self.reflectElapsed = math.max(0, snap.reflectElapsed) -- 421
	end -- 421
	if snap.lampElapsed ~= nil then -- 421
		self.lampElapsed = math.max(0, snap.lampElapsed) -- 424
	end -- 424
	if snap.returnElapsed ~= nil then -- 424
		self.returnElapsed = math.max(0, snap.returnElapsed) -- 427
	end -- 427
	if snap.artifactGrantCount ~= nil then -- 427
		self.artifactGrantCount = math.max(0, snap.artifactGrantCount) -- 430
	end -- 430
	self.savedResume = self:exportResumeState() -- 432
	self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 433
end -- 397
function WellMuseumPlugin.prototype.resetSessionCounters(self) -- 437
	self.artifactGrantCount = 0 -- 438
	self.revisitCalmCount = 0 -- 439
	self.revisitCalmTimer = 0 -- 440
	self.savedResume = nil -- 441
	self.resumeRestoreCount = 0 -- 442
	self.lastResumePhase = "locked" -- 443
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 444
end -- 437
function WellMuseumPlugin.prototype.setHallWalkPosition(self, x, holstered) -- 448
	self.hallWalkX = clamp(x, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 449
	self.hallCamX = self.hallWalkX -- 450
	if holstered ~= nil then -- 450
		self.holstered = holstered -- 452
	elseif self.hallWalkX >= self.caseX - 85 then -- 452
		self.holstered = true -- 454
	end -- 454
	self.savedResume = self:exportResumeState() -- 456
end -- 448
function WellMuseumPlugin.prototype.seekStageTime(self, stage, seconds) -- 460
	local s = math.max(0, seconds) -- 461
	if stage == "well_reflect" then -- 461
		self.reflectElapsed = math.min(____exports.MUSEUM_TIMINGS.wellReflectDuration, s) -- 463
	elseif stage == "lamp_turn" then -- 463
		self.lampElapsed = math.min(____exports.MUSEUM_TIMINGS.lampTurnDuration, s) -- 465
		self.lineDawnShown = self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt -- 466
	elseif stage == "return_cabinet" then -- 466
		self.returnElapsed = math.min(____exports.MUSEUM_TIMINGS.returnCabinetDuration, s) -- 468
	end -- 468
end -- 460
function WellMuseumPlugin.prototype.getDebugState(self) -- 472
	local reflectProg = clamp01(self.reflectElapsed / ____exports.MUSEUM_TIMINGS.wellReflectDuration) -- 473
	local matchStart = ____exports.MUSEUM_TIMINGS.wellMatchCutStart -- 474
	local matchSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.wellReflectDuration - matchStart) -- 475
	local matchProg = self.reflectElapsed <= matchStart and 0 or clamp01((self.reflectElapsed - matchStart) / matchSpan) -- 476
	local lampTurnProg = clamp01(self.lampElapsed / 1.15) -- 479
	local cuffStart = ____exports.MUSEUM_TIMINGS.returnKnock2At -- 480
	local cuffSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.returnFadeOutAt - cuffStart) -- 481
	local cuffProg = self.returnElapsed <= cuffStart and 0 or clamp01((self.returnElapsed - cuffStart) / cuffSpan) -- 482
	local dx = self.glassAnchorX - self.wellAnchorX -- 485
	local dy = self.glassAnchorY - self.wellAnchorY -- 486
	return { -- 487
		gateOpen = self.gateOpen, -- 488
		gateBlockedReason = self.gateBlockedReason, -- 489
		wellWorldX = self.wellWorldX, -- 490
		nearWell = self.nearWell, -- 491
		museumPhase = self.prevPhase, -- 492
		visualMode = self.lastVisualMode, -- 493
		reflectElapsed = self.reflectElapsed, -- 494
		reflectProgress = reflectProg, -- 495
		matchCutProgress = matchProg, -- 496
		wellAnchorX = self.wellAnchorX, -- 497
		wellAnchorY = self.wellAnchorY, -- 498
		glassAnchorX = self.glassAnchorX, -- 499
		glassAnchorY = self.glassAnchorY, -- 500
		matchCutAnchorDeltaPx = math.sqrt(dx * dx + dy * dy), -- 501
		hallWalkX = self.hallWalkX, -- 502
		hallCamX = self.hallCamX, -- 503
		holstered = self.holstered, -- 504
		childEchoPlayed = self.childEchoPlayed, -- 505
		nearLamp = self.nearLamp, -- 506
		lampElapsed = self.lampElapsed, -- 507
		lampTurnProgress = lampTurnProg, -- 508
		lineDawnShown = self.lineDawnShown, -- 509
		knock1Played = self.knock1Played, -- 510
		knock2Played = self.knock2Played, -- 511
		returnElapsed = self.returnElapsed, -- 512
		cuffReusedFromSharedPalette = true, -- 513
		cuffProgress = cuffProg, -- 514
		artifactGrantCount = self.artifactGrantCount, -- 515
		revisitCalmCount = self.revisitCalmCount, -- 516
		resumeRestoreCount = self.resumeRestoreCount, -- 517
		lastResumePhase = self.lastResumePhase, -- 518
		lastResumeWalkX = self.lastResumeWalkX, -- 519
		pausedFrozen = self.lastPaused -- 520
	} -- 520
end -- 472
function WellMuseumPlugin.prototype.onBindPlay(self, p, view) -- 524
	self:syncRuntimeHook() -- 525
	if view.isRehearsal ~= self.rehearsal then -- 525
		self.savedResume = nil -- 527
	end -- 527
	self.rehearsal = view.isRehearsal -- 529
	local ____view_isRehearsal_6 -- 530
	if view.isRehearsal then -- 530
		____view_isRehearsal_6 = nil -- 530
	else -- 530
		local ____opt_4 = p.room.story -- 530
		____view_isRehearsal_6 = ____opt_4 and ____opt_4.museum -- 530
	end -- 530
	local museum = ____view_isRehearsal_6 -- 530
	self.caseX = museum == nil and ____exports.MUSEUM_CASE_X or museum.cabinetX - p.ox -- 531
	self.lampX = museum == nil and ____exports.MUSEUM_LAMP_X or museum.lampX - p.ox -- 532
	self.animTime = 0 -- 533
	self.revisitCalmTimer = 0 -- 534
	self.childEchoVisualT = 0 -- 535
	self.knock1VisualT = 0 -- 536
	self.knock2VisualT = 0 -- 537
	self.wellDripPlaying = false -- 538
	self.hallAmbiencePlaying = false -- 539
	self.enterHallSubmitted = false -- 540
	self.beginReturnSubmitted = false -- 541
	self.returnCompleteSubmitted = false -- 542
	self.liveReflectDoneInMuseumRoom = false -- 543
	self.simInput = nil -- 544
	local phase = view.archive.museumPhase -- 546
	self.prevPhase = phase -- 547
	self.lastVisualMode = view.visualMode -- 548
	local pRec = asRecord(p) -- 552
	local backendWellX = readNum(pRec, "wellX") -- 553
	self.wellWorldX = backendWellX ~= nil and p.ox + backendWellX or p.ox + ____exports.WELL_WORLD_X -- 554
	self.hallMoving = false -- 555
	if view.archive.childCleared and view.archive.soldierCleared and view.archive.artifactOwned then -- 555
		if self.artifactGrantCount < 1 then -- 555
			self.artifactGrantCount = 1 -- 560
		end -- 560
	elseif not view.archive.artifactOwned then -- 560
		self.artifactGrantCount = 0 -- 563
	end -- 563
	if isActiveMuseumPhase(phase) then -- 563
		local ____view_isRehearsal_7 -- 568
		if view.isRehearsal then -- 568
			____view_isRehearsal_7 = nil -- 568
		else -- 568
			____view_isRehearsal_7 = asRecord(p.run) -- 568
		end -- 568
		local runRec = ____view_isRehearsal_7 -- 568
		local ____asRecord_9 = asRecord -- 569
		local ____temp_8 -- 569
		if pRec ~= nil then -- 569
			____temp_8 = pRec.archive -- 569
		else -- 569
			____temp_8 = nil -- 569
		end -- 569
		local ____asRecord_9_result_12 = ____asRecord_9(____temp_8) -- 569
		if ____asRecord_9_result_12 == nil then -- 569
			local ____asRecord_11 = asRecord -- 570
			local ____temp_10 -- 570
			if runRec ~= nil then -- 570
				____temp_10 = runRec.archive -- 570
			else -- 570
				____temp_10 = nil -- 570
			end -- 570
			____asRecord_9_result_12 = ____asRecord_11(____temp_10) -- 569
		end -- 569
		local archRec = ____asRecord_9_result_12 -- 569
		local backendWalkX = readNum(archRec, "museumWalkX") or readNum(pRec, "museumWalkX") -- 571
		local ____readBool_result_13 = readBool(archRec, "museumHolstered") -- 572
		if ____readBool_result_13 == nil then -- 572
			____readBool_result_13 = readBool(pRec, "museumHolstered") -- 572
		end -- 572
		local backendHolstered = ____readBool_result_13 -- 572
		local ____readBool_result_14 = readBool(archRec, "museumChildEchoPlayed") -- 573
		if ____readBool_result_14 == nil then -- 573
			____readBool_result_14 = readBool(pRec, "museumChildEchoPlayed") -- 573
		end -- 573
		local backendChildEcho = ____readBool_result_14 -- 573
		if self.savedResume ~= nil and self.savedResume.phase == phase then -- 573
			self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.savedResume.hallWalkX -- 576
			self.hallCamX = self.hallWalkX -- 577
			self.hallFacing = self.savedResume.hallFacing -- 578
			local ____backendHolstered_15 = backendHolstered -- 579
			if ____backendHolstered_15 == nil then -- 579
				____backendHolstered_15 = self.savedResume.holstered -- 579
			end -- 579
			self.holstered = ____backendHolstered_15 -- 579
			local ____backendChildEcho_16 = backendChildEcho -- 580
			if ____backendChildEcho_16 == nil then -- 580
				____backendChildEcho_16 = self.savedResume.childEchoPlayed -- 580
			end -- 580
			self.childEchoPlayed = ____backendChildEcho_16 -- 580
			self.reflectElapsed = self.savedResume.reflectElapsed -- 581
			self.lampElapsed = self.savedResume.lampElapsed -- 582
			self.returnElapsed = self.savedResume.returnElapsed -- 583
		else -- 583
			self:resetPhaseTimersForEntry(phase, backendWalkX, backendHolstered, backendChildEcho) -- 585
		end -- 585
		self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 587
		self.lastResumePhase = phase -- 588
		self.lastResumeWalkX = self.hallWalkX -- 589
	else -- 589
		self.reflectElapsed = 0 -- 592
		self.lampElapsed = 0 -- 593
		self.returnElapsed = 0 -- 594
		self.hallIntroElapsed = 0 -- 595
		self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 596
		self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 597
		self.hallFacing = 1 -- 598
		self.holstered = false -- 599
		self.childEchoCountdown = -1 -- 600
		self.childEchoPlayed = false -- 601
		self.lineDawnShown = false -- 602
		self.knock1Played = false -- 603
		self.knock2Played = false -- 604
		if phase == "locked" or phase == "well_open" then -- 604
			self.savedResume = nil -- 606
		end -- 606
	end -- 606
end -- 524
function WellMuseumPlugin.prototype.resetPhaseTimersForEntry(self, phase, backendWalkX, backendHolstered, backendChildEcho) -- 611
	if phase == "well_reflect" then -- 611
		self.reflectElapsed = 0 -- 618
		self.enterHallSubmitted = false -- 619
		return -- 620
	end -- 620
	if phase == "hall_walk" then -- 620
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or ____exports.MUSEUM_ENTRY_X -- 623
		self.hallCamX = self.hallWalkX -- 624
		self.hallFacing = 1 -- 625
		self.hallIntroElapsed = backendWalkX ~= nil and backendWalkX > 260 and 5 or 0 -- 626
		local ____backendHolstered_17 = backendHolstered -- 627
		if ____backendHolstered_17 == nil then -- 627
			____backendHolstered_17 = self.hallWalkX >= self.caseX - 85 -- 627
		end -- 627
		self.holstered = ____backendHolstered_17 -- 627
		local ____backendChildEcho_18 = backendChildEcho -- 628
		if ____backendChildEcho_18 == nil then -- 628
			____backendChildEcho_18 = self.hallWalkX >= self.caseX + 120 -- 628
		end -- 628
		self.childEchoPlayed = ____backendChildEcho_18 -- 628
		self.childEchoCountdown = -1 -- 629
		return -- 630
	end -- 630
	if phase == "lamp_turn" then -- 630
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.lampX - 36 -- 633
		self.hallCamX = self.hallWalkX -- 634
		self.hallFacing = 1 -- 635
		self.holstered = true -- 636
		self.childEchoPlayed = true -- 637
		self.lampElapsed = 0 -- 638
		self.lineDawnShown = false -- 639
		self.knock1Played = false -- 640
		self.beginReturnSubmitted = false -- 641
		return -- 642
	end -- 642
	if phase == "return_cabinet" then -- 642
		self.returnElapsed = 0 -- 645
		self.knock2Played = false -- 646
		self.returnCompleteSubmitted = false -- 647
	end -- 647
end -- 611
function WellMuseumPlugin.prototype.evaluateGate(self, p, view) -- 651
	if p.run.source == "chapter" then -- 651
		return {open = false, reason = "chapter_preview"} -- 653
	end -- 653
	if p.room.key ~= "prologue" then -- 653
		return {open = false, reason = "not_prologue"} -- 656
	end -- 656
	if p.phase ~= "prologue-wait" and p.phase ~= "prologue-well" then -- 656
		return {open = false, reason = "after_cabinet_window"} -- 659
	end -- 659
	if isPrologueIntroBlocking() then -- 659
		return {open = false, reason = "prologue_intro_active"} -- 662
	end -- 662
	if not view.archive.childCleared or not view.archive.soldierCleared then -- 662
		return {open = false, reason = "requires_both_clear"} -- 666
	end -- 666
	if view.archive.museumPhase == "locked" then -- 666
		return {open = false, reason = "phase_locked"} -- 669
	end -- 669
	return {open = true, reason = "ok"} -- 671
end -- 651
function WellMuseumPlugin.prototype.submitMuseumIntent(self, p, target) -- 674
	local contract = resolveRuntimeContract(self.injectedContract) -- 675
	if contract == nil then -- 675
		return false -- 677
	end -- 677
	local intent = {kind = "museumInteract", target = target} -- 679
	return contract:submitIntent(p, intent) -- 680
end -- 674
function WellMuseumPlugin.prototype.syncLoops(self, ctx, wantWellDrip, dripVolume, wantHallAmbience) -- 683
	if wantWellDrip then -- 683
		ctx.audio:playLoop( -- 685
			LOOP_WELL_DRIP, -- 685
			"water", -- 685
			____exports.MUSEUM_AUDIO.wellDripLoop, -- 685
			dripVolume, -- 685
			ctx.p.ticks -- 685
		) -- 685
		self.wellDripPlaying = true -- 686
	elseif self.wellDripPlaying then -- 686
		ctx.audio:stopLoop(LOOP_WELL_DRIP) -- 688
		self.wellDripPlaying = false -- 689
	end -- 689
	if wantHallAmbience then -- 689
		ctx.audio:playLoop( -- 693
			LOOP_HALL_AMBIENCE, -- 693
			"ambience", -- 693
			____exports.MUSEUM_AUDIO.hallAmbienceLoop, -- 693
			0.34, -- 693
			ctx.p.ticks -- 693
		) -- 693
		self.hallAmbiencePlaying = true -- 694
	elseif self.hallAmbiencePlaying then -- 694
		ctx.audio:stopLoop(LOOP_HALL_AMBIENCE) -- 696
		self.hallAmbiencePlaying = false -- 697
	end -- 697
end -- 683
function WellMuseumPlugin.prototype.update(self, ctx) -- 701
	self:syncRuntimeHook() -- 702
	local p = ctx.p -- 703
	local view = ctx.view -- 704
	local phase = view.archive.museumPhase -- 705
	if view.isRehearsal ~= self.rehearsal then -- 705
		self:syncLoops(ctx, false, 0, false) -- 707
		self:onBindPlay(p, view) -- 708
	end -- 708
	self.roomSessionId = ctx.events.roomSessionId -- 710
	self.lastVisualMode = view.visualMode -- 711
	self.lastPaused = ctx.paused -- 712
	self.wellAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 715
	self.wellAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 716
	self.glassAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 717
	self.glassAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 718
	local sim = self.simInput -- 721
	self.simInput = nil -- 722
	local interactPressed = ctx.input.interact.pressed or ctx.input.frameInteractPressed or sim ~= nil and sim.interact == true -- 723
	local moveX = sim ~= nil and sim.moveX ~= nil and sim.moveX or ctx.input.moveX -- 726
	if phase ~= self.prevPhase then -- 726
		local wasActive = isActiveMuseumPhase(self.prevPhase) -- 730
		self.prevPhase = phase -- 731
		if isActiveMuseumPhase(phase) then -- 731
			if phase == "well_reflect" then -- 731
				self:resetPhaseTimersForEntry("well_reflect") -- 734
				if view.archive.artifactOwned and self.artifactGrantCount < 1 then -- 734
					self.artifactGrantCount = 1 -- 736
				end -- 736
			elseif phase == "hall_walk" and not wasActive then -- 736
				self:resetPhaseTimersForEntry("hall_walk") -- 739
			elseif phase == "hall_walk" and wasActive then -- 739
				self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 741
				self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 742
				self.hallFacing = 1 -- 743
				self.hallIntroElapsed = 0 -- 744
				self.holstered = false -- 745
				self.childEchoPlayed = false -- 746
				self.childEchoCountdown = -1 -- 747
			elseif phase == "lamp_turn" then -- 747
				self:resetPhaseTimersForEntry("lamp_turn", self.hallWalkX, true, self.childEchoPlayed) -- 749
			elseif phase == "return_cabinet" then -- 749
				self:resetPhaseTimersForEntry("return_cabinet") -- 751
			end -- 751
		elseif phase == "done" then -- 751
			self.savedResume = nil -- 754
		end -- 754
	end -- 754
	local gate = self:evaluateGate(p, view) -- 758
	self.gateOpen = gate.open -- 759
	self.gateBlockedReason = gate.reason -- 760
	self.nearWell = gate.open and math.abs(p.player.x - self.wellWorldX) <= ____exports.WELL_INTERACT_REACH -- 761
	if ctx.paused then -- 761
		return -- 765
	end -- 765
	local wdt = math.max(0, ctx.worldDt) -- 768
	local udt = math.max(0, ctx.uiDt) -- 769
	self.animTime = self.animTime + wdt -- 770
	if self.revisitCalmTimer > 0 then -- 770
		self.revisitCalmTimer = math.max(0, self.revisitCalmTimer - wdt) -- 773
	end -- 773
	if self.childEchoVisualT > 0 then -- 773
		self.childEchoVisualT = math.max(0, self.childEchoVisualT - udt) -- 776
	end -- 776
	if self.knock1VisualT > 0 then -- 776
		self.knock1VisualT = math.max(0, self.knock1VisualT - wdt) -- 779
	end -- 779
	if self.knock2VisualT > 0 then -- 779
		self.knock2VisualT = math.max(0, self.knock2VisualT - wdt) -- 782
	end -- 782
	if view.visualMode ~= "museum" then -- 782
		local wantDrip = gate.open and phase == "well_open" and not view.archive.museumSeen -- 787
		local dist = math.abs(p.player.x - self.wellWorldX) -- 788
		local dripVol = clamp(0.46 - dist * 0.0014, 0.08, 0.46) -- 789
		self:syncLoops(ctx, wantDrip, dripVol, false) -- 790
		if gate.open and self.nearWell and interactPressed then -- 790
			local liveNeedsSecondEnter = not view.isRehearsal and p.room.key == "prologue" and view.archive.artifactOwned and not view.archive.museumSeen -- 793
			local alreadyAwarded = not liveNeedsSecondEnter and (view.archive.museumSeen or phase == "done" or view.archive.artifactOwned and self.artifactGrantCount >= 1) -- 797
			if (phase == "well_open" or liveNeedsSecondEnter) and not alreadyAwarded then -- 797
				self:submitMuseumIntent(p, "well_pickup") -- 802
			else -- 802
				self.revisitCalmTimer = 1.4 -- 805
				self.revisitCalmCount = self.revisitCalmCount + 1 -- 806
			end -- 806
		end -- 806
		return -- 809
	end -- 809
	local effectivePhase = p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 813
	if effectivePhase == "well_reflect" then -- 813
		local dripVol = clamp( -- 818
			0.44 * (1 - smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, self.reflectElapsed)), -- 818
			0, -- 818
			0.44 -- 818
		) -- 818
		self:syncLoops(ctx, dripVol > 0.03, dripVol, false) -- 819
		if wdt > 0 then -- 819
			self.reflectElapsed = self.reflectElapsed + wdt -- 822
		end -- 822
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 822
			if self.artifactGrantCount < 1 then -- 822
				self.artifactGrantCount = 1 -- 826
			end -- 826
			ctx.audio:playOnce( -- 828
				"fe06:e01:pickup:" .. tostring(self.roomSessionId), -- 829
				"sfx", -- 830
				____exports.MUSEUM_AUDIO.artifactPickup, -- 831
				0.86, -- 832
				"museum:e01:artifact_pickup", -- 833
				p.ticks -- 834
			) -- 834
		end -- 834
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellMatchCutStart then -- 834
			ctx.audio:playOnce( -- 838
				"fe06:e01:matchcut:" .. tostring(self.roomSessionId), -- 839
				"ambience", -- 840
				____exports.MUSEUM_AUDIO.matchCutTransition, -- 841
				0.78, -- 842
				"museum:e01:match_cut", -- 843
				p.ticks -- 844
			) -- 844
		end -- 844
		self.savedResume = self:exportResumeState() -- 847
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellReflectDuration and not self.enterHallSubmitted then -- 847
			self.enterHallSubmitted = true -- 849
			if p.room.key == "museum" then -- 849
				self.liveReflectDoneInMuseumRoom = true -- 851
			end -- 851
			self:submitMuseumIntent(p, "enter_hall") -- 853
			local contract = resolveRuntimeContract(self.injectedContract) -- 854
			if contract ~= nil and contract:isRehearsal() then -- 854
				contract:enterMockMuseum("hall_walk") -- 856
			end -- 856
		end -- 856
		return -- 859
	end -- 859
	if effectivePhase == "hall_walk" then -- 859
		self:syncLoops(ctx, false, 0, true) -- 864
		self.hallIntroElapsed = self.hallIntroElapsed + udt -- 865
		local ____view_isRehearsal_19 -- 869
		if view.isRehearsal then -- 869
			____view_isRehearsal_19 = nil -- 869
		else -- 869
			____view_isRehearsal_19 = asRecord(p) -- 869
		end -- 869
		local pRec = ____view_isRehearsal_19 -- 869
		local backendWalkX = readNum(pRec, "museumWalkX") or (not view.isRehearsal and p.room.key == "museum" and p.player.x - p.ox or nil) -- 870
		self.hallMoving = false -- 872
		local previousX = self.hallWalkX -- 873
		if backendWalkX ~= nil then -- 873
			self.hallWalkX = clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 875
		elseif udt > 0 and math.abs(moveX) > 0.05 then -- 875
			self.hallWalkX = clamp(self.hallWalkX + moveX * ____exports.MUSEUM_WALK_SPEED * udt, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 877
		end -- 877
		local delta = self.hallWalkX - previousX -- 879
		if math.abs(delta) > 0.01 then -- 879
			self.hallFacing = delta >= 0 and 1 or -1 -- 881
			self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 882
			self.hallMoving = true -- 883
			self.hallFootstepTimer = self.hallFootstepTimer + udt -- 884
			if self.hallFootstepTimer >= 0.46 then -- 884
				self.hallFootstepTimer = 0 -- 886
				ctx.audio:playOnce( -- 887
					(("fe06:e02:step:" .. tostring(self.roomSessionId)) .. ":") .. tostring(math.floor(self.hallWalkAnim * 2)), -- 888
					"sfx", -- 889
					____exports.MUSEUM_AUDIO.hallFootstep, -- 890
					0.46, -- 891
					"museum:e02:footstep", -- 892
					p.ticks -- 893
				) -- 893
			end -- 893
		else -- 893
			self.hallFootstepTimer = math.min(self.hallFootstepTimer, 0.22) -- 897
		end -- 897
		local camFollow = math.min(1, udt * 5.2) -- 901
		self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * camFollow -- 902
		local holsterThreshold = p.room.key == "museum" and self.caseX + 12 or self.caseX - 85 -- 905
		if not self.holstered and self.hallWalkX >= holsterThreshold then -- 905
			self.holstered = true -- 907
			ctx.audio:playOnce( -- 908
				"fe06:e02:holster:" .. tostring(self.roomSessionId), -- 909
				"sfx", -- 910
				____exports.MUSEUM_AUDIO.weaponHolster, -- 911
				0.76, -- 912
				"museum:e02:weapon_holster", -- 913
				p.ticks -- 914
			) -- 914
			if not self.childEchoPlayed then -- 914
				self.childEchoCountdown = ____exports.MUSEUM_TIMINGS.childEchoDelay -- 917
			end -- 917
		end -- 917
		if self.childEchoCountdown >= 0 and not self.childEchoPlayed then -- 917
			self.childEchoCountdown = self.childEchoCountdown - udt -- 922
			if self.childEchoCountdown <= 0 then -- 922
				self.childEchoCountdown = -1 -- 924
				self.childEchoPlayed = true -- 925
				self.childEchoVisualT = 2.1 -- 926
				ctx.audio:playOnce( -- 927
					"fe06:e02:child_echo:" .. tostring(self.roomSessionId), -- 928
					"sfx", -- 929
					____exports.MUSEUM_AUDIO.childStepsEcho, -- 930
					0.72, -- 931
					"museum:e02:child_steps_echo", -- 932
					p.ticks -- 933
				) -- 933
			end -- 933
		end -- 933
		local ____view_isRehearsal_20 -- 938
		if view.isRehearsal then -- 938
			____view_isRehearsal_20 = math.abs(self.hallWalkX - self.lampX) <= 72 -- 939
		else -- 939
			____view_isRehearsal_20 = (p.phase == "museum-hall" or p.phase == "museum-lamp") and math.abs(p.player.x - (self.lampX + p.ox)) <= 72 -- 940
		end -- 940
		self.nearLamp = ____view_isRehearsal_20 -- 938
		self.savedResume = self:exportResumeState() -- 942
		if self.nearLamp and interactPressed then -- 942
			self:submitMuseumIntent(p, "lamp_turn") -- 945
		end -- 945
		return -- 947
	end -- 947
	if effectivePhase == "lamp_turn" then -- 947
		self:syncLoops(ctx, false, 0, true) -- 952
		if wdt > 0 then -- 952
			self.lampElapsed = self.lampElapsed + wdt -- 954
		end -- 954
		if p.room.key == "museum" then -- 954
			local targetX = clamp(p.player.x - p.ox, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 958
			local delta = targetX - self.hallWalkX -- 959
			self.hallMoving = math.abs(delta) > 0.25 -- 960
			if self.hallMoving then -- 960
				self.hallFacing = delta >= 0 and 1 or -1 -- 962
				self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 963
			end -- 963
			self.hallWalkX = targetX -- 965
			self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * math.min(1, udt * 5.2) -- 966
		end -- 966
		ctx.audio:playOnce( -- 968
			"fe06:e02:lamp_turn:" .. tostring(self.roomSessionId), -- 969
			"sfx", -- 970
			____exports.MUSEUM_AUDIO.lampTurn, -- 971
			0.82, -- 972
			"museum:e02:lamp_turn", -- 973
			p.ticks -- 974
		) -- 974
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 974
			self.lineDawnShown = true -- 977
			ctx.audio:playOnce( -- 978
				"fe06:e02:line_dawn:" .. tostring(self.roomSessionId), -- 979
				"voice", -- 980
				____exports.MUSEUM_AUDIO.lineDawn, -- 981
				0.92, -- 982
				"museum:e02:line_dawn", -- 983
				p.ticks -- 984
			) -- 984
		end -- 984
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampKnock1At and not self.knock1Played then -- 984
			self.knock1Played = true -- 988
			self.knock1VisualT = 0.85 -- 989
			ctx.audio:playOnce( -- 990
				"fe06:e02:knock1:" .. tostring(self.roomSessionId), -- 991
				"sfx", -- 992
				____exports.MUSEUM_AUDIO.knockHallFirst, -- 993
				0.88, -- 994
				"museum:knock:1", -- 995
				p.ticks -- 996
			) -- 996
		end -- 996
		self.savedResume = self:exportResumeState() -- 999
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampTurnDuration and not self.beginReturnSubmitted then -- 999
			self.beginReturnSubmitted = true -- 1002
			self:submitMuseumIntent(p, "begin_return_cabinet") -- 1003
			local contract = resolveRuntimeContract(self.injectedContract) -- 1004
			if contract ~= nil and contract:isRehearsal() then -- 1004
				contract:enterMockMuseum("return_cabinet") -- 1006
			end -- 1006
		end -- 1006
		return -- 1009
	end -- 1009
	if phase == "return_cabinet" then -- 1009
		self:syncLoops(ctx, false, 0, false) -- 1014
		if wdt > 0 then -- 1014
			self.returnElapsed = self.returnElapsed + wdt -- 1016
		end -- 1016
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnKnock2At and not self.knock2Played then -- 1016
			self.knock2Played = true -- 1019
			self.knock2VisualT = 0.9 -- 1020
			ctx.audio:playOnce( -- 1021
				"fe06:e02:knock2:" .. tostring(self.roomSessionId), -- 1022
				"sfx", -- 1023
				____exports.MUSEUM_AUDIO.knockCabinetSecond, -- 1024
				0.92, -- 1025
				"museum:knock:2", -- 1026
				p.ticks -- 1027
			) -- 1027
		end -- 1027
		self.savedResume = self:exportResumeState() -- 1030
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnCabinetDuration and not self.returnCompleteSubmitted then -- 1030
			self.returnCompleteSubmitted = true -- 1033
			self:submitMuseumIntent(p, "return_cabinet") -- 1034
		end -- 1034
	end -- 1034
end -- 701
function WellMuseumPlugin.prototype.drawBackdrop(self, bgDraw, _bgGlow, _backdropArt, ctx) -- 1039
	if ctx.view.visualMode ~= "museum" then -- 1039
		return false -- 1046
	end -- 1046
	bgDraw:drawRect( -- 1049
		Rect(0, 0, ctx.w, ctx.h), -- 1049
		Color(11, 13, 18, 255) -- 1049
	) -- 1049
	return true -- 1050
end -- 1039
function WellMuseumPlugin.prototype.drawWorld(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1053
	return ctx.view.visualMode == "museum" -- 1059
end -- 1053
function WellMuseumPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1062
	return ctx.view.visualMode == "museum" -- 1068
end -- 1062
function WellMuseumPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 1074
	if not self.gateOpen or ctx.view.visualMode == "museum" then -- 1074
		return -- 1081
	end -- 1081
	local cam = ctx.cam -- 1083
	local wellCx = cam:sx(self.wellWorldX) -- 1084
	local groundY = cam:sy(0, 0) -- 1085
	local phase = ctx.view.archive.museumPhase -- 1086
	local activeLure = phase == "well_open" and not ctx.view.archive.museumSeen -- 1087
	local archW = cam:len(68) -- 1090
	local archH = cam:len(96) -- 1091
	local archX = wellCx - archW * 0.54 -- 1092
	fillVGradRect( -- 1093
		fgDraw, -- 1094
		archX, -- 1095
		groundY, -- 1096
		archW, -- 1097
		archH, -- 1098
		Color(12, 16, 22, 232), -- 1099
		Color(18, 24, 34, 212) -- 1100
	) -- 1100
	fgDraw:drawRect( -- 1103
		Rect(archX - 4, groundY, 6, archH), -- 1103
		Color(48, 54, 62, 240) -- 1103
	) -- 1103
	fgDraw:drawRect( -- 1104
		Rect(archX + archW - 2, groundY, 6, archH), -- 1104
		Color(48, 54, 62, 240) -- 1104
	) -- 1104
	fgDraw:drawRect( -- 1105
		Rect(archX - 6, groundY + archH - 8, archW + 12, 10), -- 1105
		Color(62, 68, 76, 245) -- 1105
	) -- 1105
	local rimW = cam:len(38) -- 1108
	local rimH = cam:len(22) -- 1109
	local rimX = wellCx - rimW * 0.5 -- 1110
	fgDraw:drawRect( -- 1111
		Rect(rimX, groundY, rimW, rimH), -- 1112
		Color(46, 52, 60, 250), -- 1113
		1.2, -- 1114
		Color(102, 110, 120, 215) -- 1115
	) -- 1115
	fgDraw:drawEllipse( -- 1118
		Vec2(wellCx, groundY + rimH), -- 1118
		rimW * 0.52, -- 1118
		cam:len(5.5), -- 1118
		Color(74, 82, 92, 250) -- 1118
	) -- 1118
	fgDraw:drawEllipse( -- 1119
		Vec2(wellCx, groundY + rimH), -- 1119
		rimW * 0.38, -- 1119
		cam:len(3.8), -- 1119
		Color(8, 12, 18, 255) -- 1119
	) -- 1119
	local dripCycle = self.animTime * 0.58 % 1 -- 1122
	local rippleR = cam:len(3 + dripCycle * 11) -- 1123
	local rippleAlpha = math.floor((1 - dripCycle) * (activeLure and 155 or 42) + 0.5) -- 1124
	if activeLure then -- 1124
		local shimmer = 0.65 + 0.35 * math.sin(self.animTime * 2.9) -- 1126
		fgDraw:drawCircle( -- 1128
			Vec2(wellCx, groundY + rimH), -- 1128
			cam:len(2.8), -- 1128
			Color( -- 1128
				236, -- 1128
				244, -- 1128
				252, -- 1128
				math.floor(215 * shimmer + 0.5) -- 1128
			) -- 1128
		) -- 1128
		drawEllipseRing( -- 1129
			fgDraw, -- 1129
			wellCx, -- 1129
			groundY + rimH, -- 1129
			rippleR, -- 1129
			rippleR * 0.36, -- 1129
			Color(0, 0, 0, 0), -- 1129
			1.1, -- 1129
			Color(210, 226, 242, rippleAlpha), -- 1129
			24 -- 1129
		) -- 1129
		fillRadialGlow( -- 1130
			fgGlow, -- 1131
			wellCx, -- 1132
			groundY + rimH + cam:len(8), -- 1133
			cam:len(30), -- 1134
			cam:len(38), -- 1135
			Color( -- 1136
				206, -- 1136
				224, -- 1136
				244, -- 1136
				math.floor(52 * shimmer + 0.5) -- 1136
			), -- 1136
			Color(148, 178, 212, 0), -- 1137
			16 -- 1138
		) -- 1138
		if dripCycle < 0.24 then -- 1138
			local dropK = dripCycle / 0.24 -- 1142
			local dropY = groundY + archH * 0.72 - dropK * (archH * 0.72 - rimH) -- 1143
			fgDraw:drawSegment( -- 1144
				Vec2(wellCx, dropY), -- 1145
				Vec2( -- 1146
					wellCx, -- 1146
					dropY + cam:len(4.5) -- 1146
				), -- 1146
				1.4, -- 1147
				Color(214, 228, 244, 185) -- 1148
			) -- 1148
		end -- 1148
	elseif self.revisitCalmTimer > 0 then -- 1148
		local calmK = 1 - clamp01(self.revisitCalmTimer / 1.4) -- 1153
		local calmR = cam:len(3 + calmK * 10) -- 1154
		drawEllipseRing( -- 1155
			fgDraw, -- 1156
			wellCx, -- 1157
			groundY + rimH, -- 1158
			calmR, -- 1159
			calmR * 0.35, -- 1160
			Color(0, 0, 0, 0), -- 1161
			1, -- 1162
			Color( -- 1163
				148, -- 1163
				160, -- 1163
				172, -- 1163
				math.floor((1 - calmK) * 120 + 0.5) -- 1163
			), -- 1163
			24 -- 1164
		) -- 1164
	end -- 1164
end -- 1074
function WellMuseumPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1174
	local view = ctx.view -- 1181
	local phase = view.archive.museumPhase -- 1182
	if view.visualMode ~= "museum" then -- 1182
		if self.gateOpen and self.nearWell and view.assistHintsEnabled and phase == "well_open" and not view.archive.museumSeen then -- 1182
			local sx = ctx.cam:sx(self.wellWorldX) / ctx.uiScale -- 1187
			local sy = (ctx.cam:sy(0, 0) + ctx.cam:len(54)) / ctx.uiScale -- 1188
			drawSilkVeil( -- 1189
				uiDraw, -- 1189
				uiArt, -- 1189
				"fe06_well_hint_veil", -- 1189
				sx, -- 1189
				sy, -- 1189
				132, -- 1189
				26, -- 1189
				PALETTE.panelBg, -- 1189
				0.82, -- 1189
				1 -- 1189
			) -- 1189
			ctx.texts:put( -- 1190
				"xs", -- 1191
				getActiveTarget():adaptHintSentence("[E] 俯身看井", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1192
				sx, -- 1193
				sy, -- 1194
				toColor(PALETTE.textBright), -- 1195
				0.5, -- 1196
				0.5, -- 1197
				"Center", -- 1198
				0.6, -- 1199
				0.92 -- 1200
			) -- 1200
		end -- 1200
		return false -- 1203
	end -- 1203
	local w = ctx.uiW -- 1206
	local h = ctx.uiH -- 1207
	local effectivePhase = ctx.p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 1209
	if effectivePhase == "well_reflect" then -- 1209
		self:renderE01WellReflectMatchCut( -- 1214
			uiDraw, -- 1214
			uiInkDraw, -- 1214
			uiArt, -- 1214
			uiGlow, -- 1214
			ctx, -- 1214
			w, -- 1214
			h -- 1214
		) -- 1214
		return true -- 1215
	end -- 1215
	if effectivePhase == "hall_walk" then -- 1215
		self:renderE02MuseumHall( -- 1218
			uiDraw, -- 1218
			uiInkDraw, -- 1218
			uiArt, -- 1218
			uiGlow, -- 1218
			ctx, -- 1218
			w, -- 1218
			h, -- 1218
			0, -- 1218
			false -- 1218
		) -- 1218
		return true -- 1219
	end -- 1219
	if effectivePhase == "lamp_turn" then -- 1219
		local turnProg = smoothstep(0, 1.15, self.lampElapsed) -- 1222
		self:renderE02MuseumHall( -- 1223
			uiDraw, -- 1223
			uiInkDraw, -- 1223
			uiArt, -- 1223
			uiGlow, -- 1223
			ctx, -- 1223
			w, -- 1223
			h, -- 1223
			turnProg, -- 1223
			true -- 1223
		) -- 1223
		return true -- 1224
	end -- 1224
	if effectivePhase == "return_cabinet" then -- 1224
		self:renderE02ReturnCabinet( -- 1227
			uiDraw, -- 1227
			uiInkDraw, -- 1227
			uiArt, -- 1227
			uiGlow, -- 1227
			ctx, -- 1227
			w, -- 1227
			h -- 1227
		) -- 1227
		return true -- 1228
	end -- 1228
	return false -- 1230
end -- 1174
function WellMuseumPlugin.prototype.renderE01WellReflectMatchCut(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1236
	local t = self.reflectElapsed -- 1245
	local ax = self.wellAnchorX -- 1246
	local ay = self.wellAnchorY -- 1247
	local matchK = smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, t) -- 1248
	local wellAlpha = 1 - matchK -- 1249
	fillVGradRect( -- 1252
		uiDraw, -- 1253
		0, -- 1254
		0, -- 1255
		w, -- 1256
		h, -- 1257
		Color( -- 1258
			math.floor(8 + 14 * matchK + 0.5), -- 1259
			math.floor(10 + 16 * matchK + 0.5), -- 1260
			math.floor(15 + 20 * matchK + 0.5), -- 1261
			255 -- 1262
		), -- 1262
		Color( -- 1264
			math.floor(14 + 22 * matchK + 0.5), -- 1265
			math.floor(18 + 26 * matchK + 0.5), -- 1266
			math.floor(26 + 30 * matchK + 0.5), -- 1267
			255 -- 1268
		) -- 1268
	) -- 1268
	if wellAlpha > 0.01 then -- 1268
		local wellR = math.min(w, h) * (0.31 + matchK * 0.24) -- 1274
		uiDraw:drawCircle( -- 1276
			Vec2(ax, ay), -- 1276
			wellR + 36, -- 1276
			Color( -- 1276
				30, -- 1276
				35, -- 1276
				42, -- 1276
				math.floor(240 * wellAlpha + 0.5) -- 1276
			) -- 1276
		) -- 1276
		uiDraw:drawCircle( -- 1277
			Vec2(ax, ay), -- 1277
			wellR + 14, -- 1277
			Color( -- 1277
				20, -- 1277
				24, -- 1277
				30, -- 1277
				math.floor(250 * wellAlpha + 0.5) -- 1277
			) -- 1277
		) -- 1277
		uiDraw:drawCircle( -- 1279
			Vec2(ax, ay), -- 1279
			wellR, -- 1279
			Color( -- 1279
				7, -- 1279
				11, -- 1279
				17, -- 1279
				math.floor(255 * wellAlpha + 0.5) -- 1279
			) -- 1279
		) -- 1279
		local ri = 0 -- 1282
		do -- 1282
			ri = 0 -- 1283
			while ri < 3 do -- 1283
				local cyc = (t * 0.42 + ri * 0.33) % 1 -- 1284
				local r = 20 + cyc * (wellR * 0.85) -- 1285
				local ra = math.floor((1 - cyc) * 90 * wellAlpha + 0.5) -- 1286
				drawCircleRing( -- 1287
					uiInkDraw, -- 1287
					ax, -- 1287
					ay, -- 1287
					r, -- 1287
					Color(0, 0, 0, 0), -- 1287
					1.1, -- 1287
					Color(176, 198, 222, ra), -- 1287
					32 -- 1287
				) -- 1287
				ri = ri + 1 -- 1283
			end -- 1283
		end -- 1283
		local compassSlide = smoothstep(0.15, 0.95, t) -- 1291
		local compX = ax + (1 - compassSlide) * 140 -- 1292
		local compY = ay - (1 - compassSlide) * 90 -- 1293
		local compR = 62 -- 1294
		drawCircleRing( -- 1296
			uiInkDraw, -- 1297
			compX, -- 1298
			compY, -- 1299
			compR + 8, -- 1300
			Color( -- 1301
				98, -- 1301
				78, -- 1301
				48, -- 1301
				math.floor(218 * wellAlpha + 0.5) -- 1301
			), -- 1301
			2, -- 1302
			Color( -- 1303
				186, -- 1303
				154, -- 1303
				102, -- 1303
				math.floor(235 * wellAlpha + 0.5) -- 1303
			), -- 1303
			32 -- 1304
		) -- 1304
		drawCircleRing( -- 1307
			uiInkDraw, -- 1308
			compX, -- 1309
			compY, -- 1310
			compR, -- 1311
			Color( -- 1312
				16, -- 1312
				24, -- 1312
				36, -- 1312
				math.floor(145 * wellAlpha + 0.5) -- 1312
			), -- 1312
			1.2, -- 1313
			Color( -- 1314
				218, -- 1314
				226, -- 1314
				236, -- 1314
				math.floor(180 * wellAlpha + 0.5) -- 1314
			), -- 1314
			32 -- 1315
		) -- 1315
		uiInkDraw:drawSegment( -- 1318
			Vec2(compX, compY + compR - 6), -- 1318
			Vec2(compX, compY + compR - 18), -- 1318
			1.6, -- 1318
			Color( -- 1318
				224, -- 1318
				206, -- 1318
				168, -- 1318
				math.floor(190 * wellAlpha + 0.5) -- 1318
			) -- 1318
		) -- 1318
		uiInkDraw:drawSegment( -- 1319
			Vec2(compX, compY - compR + 6), -- 1319
			Vec2(compX, compY - compR + 18), -- 1319
			1.4, -- 1319
			Color( -- 1319
				168, -- 1319
				174, -- 1319
				182, -- 1319
				math.floor(165 * wellAlpha + 0.5) -- 1319
			) -- 1319
		) -- 1319
		uiInkDraw:drawSegment( -- 1320
			Vec2(compX - compR + 6, compY), -- 1320
			Vec2(compX - compR + 18, compY), -- 1320
			1.4, -- 1320
			Color( -- 1320
				168, -- 1320
				174, -- 1320
				182, -- 1320
				math.floor(165 * wellAlpha + 0.5) -- 1320
			) -- 1320
		) -- 1320
		uiInkDraw:drawSegment( -- 1321
			Vec2(compX + compR - 6, compY), -- 1321
			Vec2(compX + compR - 18, compY), -- 1321
			1.4, -- 1321
			Color( -- 1321
				168, -- 1321
				174, -- 1321
				182, -- 1321
				math.floor(165 * wellAlpha + 0.5) -- 1321
			) -- 1321
		) -- 1321
		local needleAng = -0.35 + math.sin(t * 2.2) * 0.08 * (1 - matchK) -- 1323
		local nx = math.cos(needleAng) * 34 -- 1324
		local ny = math.sin(needleAng) * 34 -- 1325
		uiInkDraw:drawSegment( -- 1326
			Vec2(compX, compY), -- 1326
			Vec2(compX + nx, compY + ny), -- 1326
			2.2, -- 1326
			Color( -- 1326
				208, -- 1326
				92, -- 1326
				82, -- 1326
				math.floor(215 * wellAlpha + 0.5) -- 1326
			) -- 1326
		) -- 1326
		uiInkDraw:drawSegment( -- 1327
			Vec2(compX, compY), -- 1327
			Vec2(compX - nx * 0.85, compY - ny * 0.85), -- 1327
			1.8, -- 1327
			Color( -- 1327
				214, -- 1327
				222, -- 1327
				232, -- 1327
				math.floor(185 * wellAlpha + 0.5) -- 1327
			) -- 1327
		) -- 1327
		if t >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 1327
			local pickK = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellMatchCutStart, t) -- 1331
			local liftY = ay + pickK * 14 -- 1332
			drawCircleRing( -- 1333
				uiInkDraw, -- 1334
				ax, -- 1335
				liftY, -- 1336
				24 + pickK * 12, -- 1337
				Color(0, 0, 0, 0), -- 1338
				1.6, -- 1339
				Color( -- 1340
					226, -- 1340
					204, -- 1340
					152, -- 1340
					math.floor(215 * (1 - matchK * 0.65) + 0.5) -- 1340
				), -- 1340
				28 -- 1341
			) -- 1341
			local capA = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellPickupAt + 0.35, t) * (1 - matchK) -- 1344
			if capA > 0.03 then -- 1344
				drawSilkVeil( -- 1346
					uiDraw, -- 1346
					uiArt, -- 1346
					"fe06_pickup_veil", -- 1346
					w * 0.5, -- 1346
					96, -- 1346
					300, -- 1346
					34, -- 1346
					PALETTE.inkVoid, -- 1346
					0.78 * capA, -- 1346
					1 -- 1346
				) -- 1346
				ctx.texts:put( -- 1347
					"sm", -- 1348
					"拾起「时间穿梭器」", -- 1349
					w * 0.5, -- 1350
					96, -- 1351
					toColor(PALETTE.amberCore), -- 1352
					0.5, -- 1353
					0.5, -- 1354
					"Center", -- 1355
					1.4, -- 1356
					capA -- 1357
				) -- 1357
			end -- 1357
		end -- 1357
	end -- 1357
	if matchK > 0.01 then -- 1357
		local caseW = 300 -- 1365
		local caseH = 276 -- 1366
		local caseX = self.glassAnchorX - caseW * 0.5 -- 1367
		local caseY = self.glassAnchorY - caseH * 0.54 -- 1368
		uiDraw:drawRect( -- 1370
			Rect(caseX - 80, caseY - 110, caseW + 160, caseH + 220), -- 1370
			Color( -- 1370
				24, -- 1370
				29, -- 1370
				36, -- 1370
				math.floor(190 * matchK + 0.5) -- 1370
			) -- 1370
		) -- 1370
		uiDraw:drawRect( -- 1371
			Rect(caseX, caseY, caseW, caseH), -- 1372
			Color( -- 1373
				18, -- 1373
				23, -- 1373
				30, -- 1373
				math.floor(220 * matchK + 0.5) -- 1373
			), -- 1373
			1.6, -- 1374
			Color( -- 1375
				164, -- 1375
				178, -- 1375
				194, -- 1375
				math.floor(185 * matchK + 0.5) -- 1375
			) -- 1375
		) -- 1375
		fillGradQuad( -- 1378
			uiInkDraw, -- 1379
			self.glassAnchorX - 42, -- 1380
			caseY + caseH - 6, -- 1380
			Color( -- 1380
				224, -- 1380
				236, -- 1380
				248, -- 1380
				math.floor(44 * matchK + 0.5) -- 1380
			), -- 1380
			self.glassAnchorX + 24, -- 1381
			caseY + caseH - 6, -- 1381
			Color( -- 1381
				238, -- 1381
				246, -- 1381
				255, -- 1381
				math.floor(78 * matchK + 0.5) -- 1381
			), -- 1381
			self.glassAnchorX - 18, -- 1382
			caseY + 6, -- 1382
			Color( -- 1382
				224, -- 1382
				236, -- 1382
				248, -- 1382
				math.floor(24 * matchK + 0.5) -- 1382
			), -- 1382
			self.glassAnchorX - 82, -- 1383
			caseY + 6, -- 1383
			Color(224, 236, 248, 0) -- 1383
		) -- 1383
		uiArt:tryPlace( -- 1386
			"prop_compass", -- 1386
			"fe06_match_compass", -- 1386
			self.glassAnchorX, -- 1386
			caseY + 72, -- 1386
			46, -- 1386
			46, -- 1386
			{opacity = matchK * 0.85, layer = 3} -- 1386
		) -- 1386
	end -- 1386
	local flashPeak = math.sin(matchK * math.pi) -- 1393
	local coreR = 8 + flashPeak * 18 -- 1394
	uiInkDraw:drawCircle( -- 1395
		Vec2(ax, ay), -- 1395
		coreR * 0.55, -- 1395
		Color(248, 252, 255, 248) -- 1395
	) -- 1395
	fillRadialGlow( -- 1396
		uiGlow, -- 1397
		ax, -- 1398
		ay, -- 1399
		52 + flashPeak * 145, -- 1400
		46 + flashPeak * 115, -- 1401
		Color( -- 1402
			238, -- 1402
			246, -- 1402
			255, -- 1402
			math.floor(145 + flashPeak * 95 + 0.5) -- 1402
		), -- 1402
		Color(174, 204, 238, 0), -- 1403
		20 -- 1404
	) -- 1404
	if flashPeak > 0.05 then -- 1404
		local rayW = 70 + flashPeak * 260 -- 1408
		fillHGradRect( -- 1409
			uiGlow, -- 1409
			ax - rayW, -- 1409
			ay - 2, -- 1409
			rayW, -- 1409
			4, -- 1409
			Color(224, 238, 252, 0), -- 1409
			Color( -- 1409
				242, -- 1409
				248, -- 1409
				255, -- 1409
				math.floor(160 * flashPeak + 0.5) -- 1409
			) -- 1409
		) -- 1409
		fillHGradRect( -- 1410
			uiGlow, -- 1410
			ax, -- 1410
			ay - 2, -- 1410
			rayW, -- 1410
			4, -- 1410
			Color( -- 1410
				242, -- 1410
				248, -- 1410
				255, -- 1410
				math.floor(160 * flashPeak + 0.5) -- 1410
			), -- 1410
			Color(224, 238, 252, 0) -- 1410
		) -- 1410
	end -- 1410
	self:drawLetterbox( -- 1413
		uiInkDraw, -- 1413
		w, -- 1413
		h, -- 1413
		42, -- 1413
		0.92 -- 1413
	) -- 1413
end -- 1236
function WellMuseumPlugin.prototype.renderE02MuseumHall(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, lampTurnProg, inLampTurn) -- 1419
	local floorY = 148 -- 1430
	local wallTopY = h - 86 -- 1431
	local halfW = w * 0.5 -- 1432
	local camMin = math.min(____exports.MUSEUM_HALL_WIDTH * 0.5, halfW - 40) -- 1433
	local camMax = math.max(____exports.MUSEUM_HALL_WIDTH * 0.5, ____exports.MUSEUM_HALL_WIDTH - halfW + 40) -- 1434
	local camX = clamp(self.hallCamX, camMin, camMax) -- 1435
	local function toScreenX(hx) -- 1436
		return halfW + (hx - camX) -- 1436
	end -- 1436
	fillVGradRect( -- 1439
		uiDraw, -- 1439
		0, -- 1439
		floorY, -- 1439
		w, -- 1439
		h - floorY, -- 1439
		Color(26, 31, 38, 255), -- 1439
		Color(16, 20, 26, 255) -- 1439
	) -- 1439
	uiDraw:drawRect( -- 1441
		Rect(0, wallTopY, w, h - wallTopY), -- 1441
		Color(11, 14, 19, 255) -- 1441
	) -- 1441
	local px = 0 -- 1443
	do -- 1443
		px = 40 -- 1444
		while px <= ____exports.MUSEUM_HALL_WIDTH do -- 1444
			local sx = toScreenX(px) -- 1445
			if sx >= -20 and sx <= w + 20 then -- 1445
				uiDraw:drawSegment( -- 1447
					Vec2(sx, floorY), -- 1447
					Vec2(sx, wallTopY), -- 1447
					1, -- 1447
					Color(38, 45, 54, 130) -- 1447
				) -- 1447
			end -- 1447
			px = px + 140 -- 1444
		end -- 1444
	end -- 1444
	fillVGradRect( -- 1451
		uiDraw, -- 1451
		0, -- 1451
		0, -- 1451
		w, -- 1451
		floorY, -- 1451
		Color(14, 17, 22, 255), -- 1451
		Color(32, 37, 45, 255) -- 1451
	) -- 1451
	uiDraw:drawSegment( -- 1452
		Vec2(0, floorY), -- 1452
		Vec2(w, floorY), -- 1452
		2, -- 1452
		Color(76, 86, 98, 220) -- 1452
	) -- 1452
	uiDraw:drawRect( -- 1453
		Rect(0, floorY, w, 12), -- 1453
		Color(20, 24, 31, 240) -- 1453
	) -- 1453
	local plaqueWorldX = self.caseX <= 260 and 108 or 180 -- 1456
	local plaqueX = toScreenX(plaqueWorldX) -- 1457
	if plaqueX > -240 and plaqueX < w + 240 then -- 1457
		local pw = 290 -- 1459
		local ph = 132 -- 1460
		local py = floorY + 135 -- 1461
		uiDraw:drawRect( -- 1462
			Rect(plaqueX - pw * 0.5, py, pw, ph), -- 1463
			Color(18, 22, 28, 238), -- 1464
			1.2, -- 1465
			Color(118, 128, 140, 170) -- 1466
		) -- 1466
		fillRadialGlow( -- 1468
			uiGlow, -- 1468
			plaqueX, -- 1468
			wallTopY - 8, -- 1468
			150, -- 1468
			120, -- 1468
			Color(224, 232, 240, 42), -- 1468
			Color(180, 196, 214, 0), -- 1468
			14 -- 1468
		) -- 1468
		ctx.texts:put( -- 1469
			"sm", -- 1470
			"海防抗战纪念展厅", -- 1471
			plaqueX, -- 1472
			py + 82, -- 1473
			toColor(PALETTE.textBright), -- 1474
			0.5, -- 1475
			0.5, -- 1476
			"Center", -- 1477
			2, -- 1478
			0.88 -- 1479
		) -- 1479
		ctx.texts:put( -- 1481
			"xs", -- 1482
			"温州宁村 · 守望史迹陈列", -- 1483
			plaqueX, -- 1484
			py + 46, -- 1485
			toColor(PALETTE.textDim), -- 1486
			0.5, -- 1487
			0.5, -- 1488
			"Center", -- 1489
			1, -- 1490
			0.78 -- 1491
		) -- 1491
	end -- 1491
	local caseSx = toScreenX(self.caseX) -- 1496
	if caseSx > -260 and caseSx < w + 260 then -- 1496
		local boardOffsets = self.caseX <= 260 and ({180, 390}) or ({-210, 210}) -- 1499
		local bi = 0 -- 1500
		do -- 1500
			bi = 0 -- 1501
			while bi < #boardOffsets do -- 1501
				local bx = caseSx + boardOffsets[bi + 1] -- 1502
				uiDraw:drawRect( -- 1503
					Rect(bx - 56, floorY + 112, 112, 154), -- 1503
					Color(20, 24, 30, 235), -- 1503
					1, -- 1503
					Color(88, 98, 110, 155) -- 1503
				) -- 1503
				uiDraw:drawRect( -- 1504
					Rect(bx - 42, floorY + 168, 84, 78), -- 1504
					Color(34, 40, 48, 220) -- 1504
				) -- 1504
				uiDraw:drawSegment( -- 1505
					Vec2(bx - 36, floorY + 146), -- 1505
					Vec2(bx + 36, floorY + 146), -- 1505
					1.6, -- 1505
					Color(138, 146, 156, 140) -- 1505
				) -- 1505
				uiDraw:drawSegment( -- 1506
					Vec2(bx - 28, floorY + 132), -- 1506
					Vec2(bx + 24, floorY + 132), -- 1506
					1.2, -- 1506
					Color(108, 116, 126, 115) -- 1506
				) -- 1506
				bi = bi + 1 -- 1501
			end -- 1501
		end -- 1501
		local pedW = 148 -- 1510
		local pedH = 92 -- 1511
		local glassH = 128 -- 1512
		uiDraw:drawRect( -- 1514
			Rect(caseSx - pedW * 0.5, floorY, pedW, pedH), -- 1515
			Color(22, 26, 33, 252), -- 1516
			1.2, -- 1517
			Color(96, 106, 118, 185) -- 1518
		) -- 1518
		uiDraw:drawRect( -- 1521
			Rect(caseSx - pedW * 0.46, floorY + pedH, pedW * 0.92, glassH), -- 1522
			Color(16, 22, 30, 165), -- 1523
			1.4, -- 1524
			Color(180, 196, 214, 195) -- 1525
		) -- 1525
		uiArt:tryPlace( -- 1528
			"prop_compass", -- 1528
			"fe06_hall_compass", -- 1528
			caseSx, -- 1528
			floorY + pedH + 34, -- 1528
			34, -- 1528
			34, -- 1528
			{opacity = 0.94, layer = 3} -- 1528
		) -- 1528
		uiDraw:drawRect( -- 1532
			Rect(caseSx - 30, floorY + pedH + 6, 60, 12), -- 1532
			Color(214, 212, 204, 190) -- 1532
		) -- 1532
		fillGradQuad( -- 1534
			uiInkDraw, -- 1535
			caseSx - 28, -- 1536
			floorY + pedH + glassH - 4, -- 1536
			Color(230, 240, 252, 42), -- 1536
			caseSx + 12, -- 1537
			floorY + pedH + glassH - 4, -- 1537
			Color(242, 248, 255, 72), -- 1537
			caseSx - 12, -- 1538
			floorY + pedH + 4, -- 1538
			Color(230, 240, 252, 18), -- 1538
			caseSx - 48, -- 1539
			floorY + pedH + 4, -- 1539
			Color(230, 240, 252, 0) -- 1539
		) -- 1539
		fillRadialGlow( -- 1541
			uiGlow, -- 1541
			caseSx, -- 1541
			floorY + pedH + glassH - 12, -- 1541
			86, -- 1541
			128, -- 1541
			Color(224, 236, 250, 56), -- 1541
			Color(168, 192, 220, 0), -- 1541
			16 -- 1541
		) -- 1541
		fillVGradRect( -- 1543
			uiDraw, -- 1543
			caseSx - pedW * 0.45, -- 1543
			floorY - 36, -- 1543
			pedW * 0.9, -- 1543
			36, -- 1543
			Color(168, 186, 206, 0), -- 1543
			Color(168, 186, 206, 28) -- 1543
		) -- 1543
	end -- 1543
	local lampSx = toScreenX(self.lampX) -- 1547
	local winSx = toScreenX(self.lampX + 108) -- 1548
	local reflectK = inLampTurn and smoothstep(____exports.MUSEUM_TIMINGS.lampReflectStart, 2.35, self.lampElapsed) or 0 -- 1549
	if winSx > -260 and winSx < w + 260 then -- 1549
		local winW = 204 -- 1554
		local winH = 312 -- 1555
		local winX = winSx - winW * 0.5 -- 1556
		local winY = floorY + 38 -- 1557
		fillVGradRect( -- 1559
			uiDraw, -- 1560
			winX, -- 1561
			winY, -- 1562
			winW, -- 1563
			winH, -- 1564
			Color( -- 1565
				math.floor(54 + 46 * reflectK + 0.5), -- 1566
				math.floor(68 + 42 * reflectK + 0.5), -- 1567
				math.floor(92 + 24 * reflectK + 0.5), -- 1568
				255 -- 1569
			), -- 1569
			Color( -- 1571
				math.floor(30 + 28 * reflectK + 0.5), -- 1572
				math.floor(44 + 34 * reflectK + 0.5), -- 1573
				math.floor(70 + 30 * reflectK + 0.5), -- 1574
				255 -- 1575
			) -- 1575
		) -- 1575
		if reflectK > 0.02 then -- 1575
			uiArt:tryPlace( -- 1581
				"bgFar_prologue", -- 1581
				"fe06_window_courtyard", -- 1581
				winSx, -- 1581
				winY + 26, -- 1581
				winW - 8, -- 1581
				winH - 52, -- 1581
				{ -- 1581
					opacity = reflectK * 0.48, -- 1582
					color = Color(238, 218, 186, 255), -- 1583
					layer = 1 -- 1584
				} -- 1584
			) -- 1584
			local cy = winY + 34 -- 1587
			local silA = math.floor(188 * reflectK + 0.5) -- 1588
			uiInkDraw:drawRect( -- 1589
				Rect(winX + 12, cy, 42, 118), -- 1589
				Color(24, 28, 36, silA) -- 1589
			) -- 1589
			uiInkDraw:drawRect( -- 1590
				Rect(winX + winW - 56, cy, 44, 134), -- 1590
				Color(24, 28, 36, silA) -- 1590
			) -- 1590
			uiInkDraw:drawRect( -- 1592
				Rect(winSx - 24, cy + 4, 48, 28), -- 1592
				Color( -- 1592
					46, -- 1592
					44, -- 1592
					42, -- 1592
					math.floor(215 * reflectK + 0.5) -- 1592
				), -- 1592
				1, -- 1592
				Color( -- 1592
					214, -- 1592
					186, -- 1592
					138, -- 1592
					math.floor(170 * reflectK + 0.5) -- 1592
				) -- 1592
			) -- 1592
			uiInkDraw:drawEllipse( -- 1593
				Vec2(winSx, cy + 32), -- 1593
				26, -- 1593
				7, -- 1593
				Color( -- 1593
					218, -- 1593
					194, -- 1593
					148, -- 1593
					math.floor(175 * reflectK + 0.5) -- 1593
				) -- 1593
			) -- 1593
			fillRadialGlow( -- 1595
				uiGlow, -- 1595
				winSx, -- 1595
				winY + winH * 0.48, -- 1595
				116, -- 1595
				128, -- 1595
				Color( -- 1595
					246, -- 1595
					218, -- 1595
					168, -- 1595
					math.floor(92 * reflectK + 0.5) -- 1595
				), -- 1595
				Color(214, 174, 112, 0), -- 1595
				18 -- 1595
			) -- 1595
		end -- 1595
		uiInkDraw:drawRect( -- 1599
			Rect(winX, winY, winW, winH), -- 1599
			Color(0, 0, 0, 0), -- 1599
			3, -- 1599
			Color(68, 76, 88, 245) -- 1599
		) -- 1599
		uiInkDraw:drawSegment( -- 1600
			Vec2(winSx, winY), -- 1600
			Vec2(winSx, winY + winH), -- 1600
			2, -- 1600
			Color(68, 76, 88, 235) -- 1600
		) -- 1600
		uiInkDraw:drawSegment( -- 1601
			Vec2(winX, winY + winH * 0.56), -- 1601
			Vec2(winX + winW, winY + winH * 0.56), -- 1601
			2, -- 1601
			Color(68, 76, 88, 235) -- 1601
		) -- 1601
		local standW = 34 -- 1604
		local standH = 96 -- 1605
		uiDraw:drawRect( -- 1606
			Rect(lampSx - standW * 0.5, floorY, standW, standH), -- 1606
			Color(34, 39, 48, 250), -- 1606
			1.1, -- 1606
			Color(108, 118, 130, 190) -- 1606
		) -- 1606
		local pivotY = floorY + standH + 44 -- 1608
		uiInkDraw:drawSegment( -- 1609
			Vec2(lampSx, floorY + standH), -- 1609
			Vec2(lampSx, pivotY), -- 1609
			3.2, -- 1609
			Color(136, 144, 154, 240) -- 1609
		) -- 1609
		uiInkDraw:drawCircle( -- 1610
			Vec2(lampSx, pivotY), -- 1610
			5.5, -- 1610
			Color(196, 178, 142, 245) -- 1610
		) -- 1610
		local aimDir = -0.65 + lampTurnProg * 1.48 -- 1612
		local headX = lampSx + math.sin(aimDir) * 20 -- 1613
		local headY = pivotY + math.cos(aimDir) * 14 -- 1614
		uiInkDraw:drawSegment( -- 1615
			Vec2(lampSx, pivotY), -- 1615
			Vec2(headX, headY), -- 1615
			6.2, -- 1615
			Color(188, 166, 126, 245) -- 1615
		) -- 1615
		uiInkDraw:drawCircle( -- 1616
			Vec2(headX, headY), -- 1616
			5.2, -- 1616
			Color(248, 234, 198, 248) -- 1616
		) -- 1616
		local beamLen = 132 + lampTurnProg * 76 -- 1619
		local bxEnd = headX + math.sin(aimDir) * beamLen -- 1620
		local byEnd = headY + math.cos(aimDir) * 28 -- 1621
		local perpX = -math.cos(aimDir) * 18 -- 1622
		local perpY = math.sin(aimDir) * 34 -- 1623
		fillGradQuad( -- 1624
			uiGlow, -- 1625
			headX, -- 1626
			headY - 4, -- 1626
			Color( -- 1626
				246, -- 1626
				224, -- 1626
				178, -- 1626
				math.floor(68 + 44 * lampTurnProg + 0.5) -- 1626
			), -- 1626
			headX, -- 1627
			headY + 4, -- 1627
			Color( -- 1627
				246, -- 1627
				224, -- 1627
				178, -- 1627
				math.floor(68 + 44 * lampTurnProg + 0.5) -- 1627
			), -- 1627
			bxEnd + perpX, -- 1628
			byEnd + perpY + 34, -- 1628
			Color(238, 206, 148, 0), -- 1628
			bxEnd - perpX, -- 1629
			byEnd - perpY - 22, -- 1629
			Color(238, 206, 148, 0) -- 1629
		) -- 1629
		fillRadialGlow( -- 1631
			uiGlow, -- 1631
			headX, -- 1631
			headY, -- 1631
			34, -- 1631
			34, -- 1631
			Color(246, 228, 186, 78), -- 1631
			Color(224, 194, 140, 0), -- 1631
			14 -- 1631
		) -- 1631
	end -- 1631
	local playerSx = toScreenX(self.hallWalkX) -- 1635
	local moving = not inLampTurn and (self.hallMoving or math.abs(ctx.input.moveX) > 0.05) -- 1636
	local slot = moving and "soldier_run" or "soldier_idle" -- 1637
	local frame = moving and math.floor(self.hallWalkAnim) or 0 -- 1638
	local charH = math.floor(192 * math.max( -- 1639
		0.75, -- 1639
		math.min(1.25, h / 720) -- 1639
	) + 0.5) -- 1639
	local charW = math.floor(charH * 0.45 + 0.5) -- 1640
	uiDraw:drawEllipse( -- 1642
		Vec2(playerSx, floorY + 2), -- 1642
		34, -- 1642
		6.5, -- 1642
		Color(6, 8, 12, 178) -- 1642
	) -- 1642
	uiDraw:drawEllipse( -- 1643
		Vec2(playerSx, floorY - 14), -- 1643
		24, -- 1643
		4.5, -- 1643
		Color(16, 20, 28, 62) -- 1643
	) -- 1643
	if not uiArt:tryPlace( -- 1643
		slot, -- 1644
		"fe06_museum_zhoushu", -- 1644
		playerSx, -- 1644
		floorY + 2, -- 1644
		charW, -- 1644
		charH, -- 1644
		{facing = self.hallFacing, frame = frame, layer = 3} -- 1644
	) then -- 1644
		uiDraw:drawRect( -- 1650
			Rect(playerSx - 20, floorY + 2, 40, charH * 0.84), -- 1650
			toColor(CUFF_PALETTE.indigoBase) -- 1650
		) -- 1650
		uiDraw:drawCircle( -- 1651
			Vec2(playerSx, floorY + charH * 0.92), -- 1651
			16, -- 1651
			Color(66, 73, 76, 255) -- 1651
		) -- 1651
	end -- 1651
	if self.holstered and not inLampTurn and math.abs(self.hallWalkX - self.caseX) <= 130 then -- 1651
		local subA = clamp01(1 - math.abs(self.hallWalkX - self.caseX) / 145) * 0.86 -- 1656
		ctx.texts:put( -- 1657
			"xs", -- 1658
			"已收起随身器物", -- 1659
			caseSx, -- 1660
			floorY + 252, -- 1661
			toColor(PALETTE.textMid), -- 1662
			0.5, -- 1663
			0.5, -- 1664
			"Center", -- 1665
			0.9, -- 1666
			subA -- 1667
		) -- 1667
	end -- 1667
	if self.childEchoVisualT > 0 then -- 1667
		local echoK = 1 - clamp01(self.childEchoVisualT / 2.1) -- 1673
		local ex = math.min( -- 1674
			w - 110, -- 1674
			toScreenX(self.caseX + 310) -- 1674
		) -- 1674
		local ey = floorY + 32 -- 1675
		local ea = math.floor(math.sin(echoK * math.pi) * 165 + 0.5) -- 1676
		drawCircleRing( -- 1677
			uiInkDraw, -- 1677
			ex, -- 1677
			ey, -- 1677
			14 + echoK * 46, -- 1677
			Color(0, 0, 0, 0), -- 1677
			1.1, -- 1677
			Color(224, 214, 194, ea), -- 1677
			28 -- 1677
		) -- 1677
		drawCircleRing( -- 1678
			uiInkDraw, -- 1678
			ex, -- 1678
			ey, -- 1678
			8 + echoK * 28, -- 1678
			Color(0, 0, 0, 0), -- 1678
			0.9, -- 1678
			Color( -- 1678
				224, -- 1678
				214, -- 1678
				194, -- 1678
				math.floor(ea * 0.7 + 0.5) -- 1678
			), -- 1678
			24 -- 1678
		) -- 1678
		ctx.texts:put( -- 1679
			"xs", -- 1680
			"（远方传来轻快的孩童脚步声）", -- 1681
			w * 0.5, -- 1682
			84, -- 1683
			toColor(PALETTE.textMid), -- 1684
			0.5, -- 1685
			0.5, -- 1686
			"Center", -- 1687
			1, -- 1688
			math.sin(echoK * math.pi) * 0.85 -- 1689
		) -- 1689
	end -- 1689
	if not inLampTurn then -- 1689
		local fadeIn = smoothstep(0, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn, self.hallIntroElapsed) -- 1695
		local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold + ____exports.MUSEUM_TIMINGS.hallIntroFadeOut, self.hallIntroElapsed) -- 1696
		local introA = fadeIn * fadeOut -- 1701
		if introA > 0.02 then -- 1701
			drawSilkVeil( -- 1703
				uiDraw, -- 1703
				uiArt, -- 1703
				"fe06_hall_intro_veil", -- 1703
				w * 0.5, -- 1703
				h - 104, -- 1703
				480, -- 1703
				74, -- 1703
				PALETTE.inkVoid, -- 1703
				0.78 * introA, -- 1703
				1 -- 1703
			) -- 1703
			drawHairline( -- 1704
				uiInkDraw, -- 1704
				uiArt, -- 1704
				"fe06_hall_intro_line", -- 1704
				w * 0.5, -- 1704
				h - 106, -- 1704
				260, -- 1704
				PALETTE.silkLine, -- 1704
				0.45 * introA, -- 1704
				false, -- 1704
				4 -- 1704
			) -- 1704
			ctx.texts:put( -- 1705
				"md", -- 1705
				____exports.MUSEUM_HALL_TITLE, -- 1705
				w * 0.5, -- 1705
				h - 88, -- 1705
				toColor(PALETTE.textBright), -- 1705
				0.5, -- 1705
				0.5, -- 1705
				"Center", -- 1705
				1.8, -- 1705
				introA -- 1705
			) -- 1705
			ctx.texts:put( -- 1706
				"xs", -- 1706
				____exports.MUSEUM_HALL_SUBTITLE, -- 1706
				w * 0.5, -- 1706
				h - 122, -- 1706
				toColor(PALETTE.amberCore), -- 1706
				0.5, -- 1706
				0.5, -- 1706
				"Center", -- 1706
				1.2, -- 1706
				introA * 0.88 -- 1706
			) -- 1706
		end -- 1706
		if self.nearLamp and ctx.view.assistHintsEnabled then -- 1706
			drawSilkVeil( -- 1711
				uiDraw, -- 1711
				uiArt, -- 1711
				"fe06_lamp_hint_veil", -- 1711
				lampSx, -- 1711
				floorY + 158, -- 1711
				146, -- 1711
				28, -- 1711
				PALETTE.panelBg, -- 1711
				0.84, -- 1711
				1 -- 1711
			) -- 1711
			ctx.texts:put( -- 1712
				"xs", -- 1713
				getActiveTarget():adaptHintSentence("[E] 转动西窗灯", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1714
				lampSx, -- 1715
				floorY + 158, -- 1716
				toColor(PALETTE.textBright), -- 1717
				0.5, -- 1718
				0.5, -- 1719
				"Center", -- 1720
				0.6, -- 1721
				0.94 -- 1722
			) -- 1722
		end -- 1722
	end -- 1722
	if inLampTurn and self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1722
		local lineA = smoothstep(____exports.MUSEUM_TIMINGS.lampLineAt, ____exports.MUSEUM_TIMINGS.lampLineAt + 0.45, self.lampElapsed) * (1 - smoothstep(____exports.MUSEUM_TIMINGS.lampTurnDuration - 0.35, ____exports.MUSEUM_TIMINGS.lampTurnDuration, self.lampElapsed)) -- 1729
		if lineA > 0.02 then -- 1729
			drawSilkVeil( -- 1732
				uiDraw, -- 1732
				uiArt, -- 1732
				"fe06_dawn_line_veil", -- 1732
				w * 0.5, -- 1732
				86, -- 1732
				440, -- 1732
				50, -- 1732
				PALETTE.inkVoid, -- 1732
				0.84 * lineA, -- 1732
				1 -- 1732
			) -- 1732
			ctx.texts:put( -- 1733
				"md", -- 1734
				____exports.MUSEUM_LINE_DAWN, -- 1734
				w * 0.5, -- 1736
				86, -- 1737
				toColor(PALETTE.amberCore), -- 1738
				0.5, -- 1739
				0.5, -- 1740
				"Center", -- 1741
				1.6, -- 1742
				lineA -- 1743
			) -- 1743
		end -- 1743
	end -- 1743
	if self.knock1VisualT > 0 then -- 1743
		local k1 = 1 - clamp01(self.knock1VisualT / 0.85) -- 1749
		local k1A = math.floor((1 - k1) * 205 + 0.5) -- 1750
		drawCircleRing( -- 1751
			uiInkDraw, -- 1751
			winSx, -- 1751
			floorY + 148, -- 1751
			12 + k1 * 64, -- 1751
			Color(0, 0, 0, 0), -- 1751
			1.6, -- 1751
			Color(242, 232, 206, k1A), -- 1751
			28 -- 1751
		) -- 1751
		drawCircleRing( -- 1752
			uiInkDraw, -- 1752
			winSx, -- 1752
			floorY + 148, -- 1752
			6 + k1 * 34, -- 1752
			Color(0, 0, 0, 0), -- 1752
			1.1, -- 1752
			Color( -- 1752
				242, -- 1752
				232, -- 1752
				206, -- 1752
				math.floor(k1A * 0.72 + 0.5) -- 1752
			), -- 1752
			24 -- 1752
		) -- 1752
	end -- 1752
	self:drawLetterbox( -- 1755
		uiInkDraw, -- 1755
		w, -- 1755
		h, -- 1755
		38, -- 1755
		0.9 -- 1755
	) -- 1755
end -- 1419
function WellMuseumPlugin.prototype.renderE02ReturnCabinet(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1761
	local t = self.returnElapsed -- 1770
	local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.returnFadeOutAt, ____exports.MUSEUM_TIMINGS.returnCabinetDuration, t) -- 1771
	uiDraw:drawRect( -- 1774
		Rect(0, 0, w, h), -- 1774
		Color( -- 1774
			7, -- 1774
			9, -- 1774
			13, -- 1774
			math.floor(252 * fadeOut + 0.5) -- 1774
		) -- 1774
	) -- 1774
	if t < ____exports.MUSEUM_TIMINGS.returnKnock2At then -- 1774
		self:drawLetterbox( -- 1777
			uiInkDraw, -- 1777
			w, -- 1777
			h, -- 1777
			42, -- 1777
			0.95 * fadeOut -- 1777
		) -- 1777
		return -- 1778
	end -- 1778
	local revealK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.34, t) * fadeOut -- 1782
	local boxW = math.min(w - 140, 820) -- 1783
	local boxH = math.min(h - 190, 390) -- 1784
	local bx = (w - boxW) * 0.5 -- 1785
	local by = (h - boxH) * 0.5 + 10 -- 1786
	fillVGradRect( -- 1789
		uiDraw, -- 1790
		bx, -- 1791
		by, -- 1792
		boxW, -- 1793
		boxH, -- 1794
		Color( -- 1795
			13, -- 1795
			12, -- 1795
			16, -- 1795
			math.floor(248 * revealK + 0.5) -- 1795
		), -- 1795
		Color( -- 1796
			24, -- 1796
			24, -- 1796
			30, -- 1796
			math.floor(248 * revealK + 0.5) -- 1796
		) -- 1796
	) -- 1796
	local cabEdgeX = bx + boxW * 0.58 -- 1799
	uiDraw:drawRect( -- 1800
		Rect(cabEdgeX, by, boxW - (cabEdgeX - bx), boxH), -- 1800
		Color( -- 1800
			42, -- 1800
			31, -- 1800
			24, -- 1800
			math.floor(246 * revealK + 0.5) -- 1800
		) -- 1800
	) -- 1800
	uiDraw:drawSegment( -- 1801
		Vec2(cabEdgeX, by), -- 1801
		Vec2(cabEdgeX, by + boxH), -- 1801
		2.4, -- 1801
		Color( -- 1801
			116, -- 1801
			92, -- 1801
			68, -- 1801
			math.floor(220 * revealK + 0.5) -- 1801
		) -- 1801
	) -- 1801
	local gi = 0 -- 1803
	do -- 1803
		gi = 0 -- 1804
		while gi < 5 do -- 1804
			local gx = cabEdgeX + 26 + gi * 44 -- 1805
			if gx < bx + boxW - 10 then -- 1805
				uiDraw:drawSegment( -- 1807
					Vec2(gx, by + 12), -- 1807
					Vec2(gx, by + boxH - 12), -- 1807
					1, -- 1807
					Color( -- 1807
						28, -- 1807
						20, -- 1807
						15, -- 1807
						math.floor(140 * revealK + 0.5) -- 1807
					) -- 1807
				) -- 1807
			end -- 1807
			gi = gi + 1 -- 1804
		end -- 1804
	end -- 1804
	fillHGradRect( -- 1811
		uiGlow, -- 1812
		cabEdgeX - 58, -- 1813
		by + 24, -- 1814
		58, -- 1815
		boxH - 48, -- 1816
		Color(168, 188, 210, 0), -- 1817
		Color( -- 1818
			186, -- 1818
			206, -- 1818
			226, -- 1818
			math.floor(42 * revealK + 0.5) -- 1818
		) -- 1818
	) -- 1818
	if self.knock2VisualT > 0 then -- 1818
		local k2 = 1 - clamp01(self.knock2VisualT / 0.9) -- 1823
		local k2A = math.floor((1 - k2) * 215 * fadeOut + 0.5) -- 1824
		drawCircleRing( -- 1825
			uiInkDraw, -- 1825
			cabEdgeX + 8, -- 1825
			by + boxH * 0.5, -- 1825
			10 + k2 * 56, -- 1825
			Color(0, 0, 0, 0), -- 1825
			1.6, -- 1825
			Color(232, 220, 196, k2A), -- 1825
			28 -- 1825
		) -- 1825
	end -- 1825
	local extendK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.08, ____exports.MUSEUM_TIMINGS.returnKnock2At + 1.05, t) -- 1829
	local wristX = bx + 115 + extendK * (cabEdgeX - bx - 168) -- 1830
	local wristY = by + boxH * 0.5 -- 1831
	drawPatchedCuff(uiInkDraw, uiGlow, { -- 1832
		wristX = wristX, -- 1833
		wristY = wristY, -- 1834
		angleRad = -0.04 * (1 - extendK), -- 1835
		scale = 1.02, -- 1836
		pose = "reach", -- 1837
		opacity = revealK, -- 1838
		stitchHighlight = 0.48 + 0.22 * extendK, -- 1839
		cuffPullBack = 0.06, -- 1840
		warmth = 0.16 -- 1841
	}) -- 1841
	uiInkDraw:drawRect( -- 1845
		Rect(bx, by, boxW, boxH), -- 1845
		Color(0, 0, 0, 0), -- 1845
		1.2, -- 1845
		toColor( -- 1845
			PALETTE.silkDim, -- 1845
			math.floor(160 * revealK + 0.5) -- 1845
		) -- 1845
	) -- 1845
	local tipA = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.45, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.95, t) * fadeOut -- 1846
	if tipA > 0.03 then -- 1846
		drawSilkVeil( -- 1848
			uiDraw, -- 1848
			uiArt, -- 1848
			"fe06_return_veil", -- 1848
			w * 0.5, -- 1848
			by - 30, -- 1848
			320, -- 1848
			32, -- 1848
			PALETTE.inkVoid, -- 1848
			0.72 * tipA, -- 1848
			1 -- 1848
		) -- 1848
		ctx.texts:put( -- 1849
			"xs", -- 1850
			"两声轻敲落回柜板 · 寻回小满", -- 1851
			w * 0.5, -- 1852
			by - 30, -- 1853
			toColor(PALETTE.textMid), -- 1854
			0.5, -- 1855
			0.5, -- 1856
			"Center", -- 1857
			1.2, -- 1858
			tipA * 0.9 -- 1859
		) -- 1859
	end -- 1859
	self:drawLetterbox( -- 1863
		uiInkDraw, -- 1863
		w, -- 1863
		h, -- 1863
		42, -- 1863
		0.95 * fadeOut -- 1863
	) -- 1863
end -- 1761
function WellMuseumPlugin.prototype.drawLetterbox(self, draw, w, h, barH, opacity) -- 1866
	local a = math.floor(244 * clamp01(opacity) + 0.5) -- 1867
	if a <= 2 then -- 1867
		return -- 1869
	end -- 1869
	draw:drawRect( -- 1871
		Rect(0, 0, w, barH), -- 1871
		Color(6, 8, 12, a) -- 1871
	) -- 1871
	draw:drawRect( -- 1872
		Rect(0, h - barH, w, barH), -- 1872
		Color(6, 8, 12, a) -- 1872
	) -- 1872
end -- 1866
function ____exports.createWellMuseumPlugin(contract) -- 1876
	return __TS__New(____exports.WellMuseumPlugin, contract) -- 1877
end -- 1876
return ____exports -- 1876