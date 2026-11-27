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
		uiDraw:drawCircle( -- 1275
			Vec2(ax, ay), -- 1275
			wellR * 1.05, -- 1275
			Color( -- 1275
				7, -- 1275
				11, -- 1275
				17, -- 1275
				math.floor(255 * wellAlpha + 0.5) -- 1275
			) -- 1275
		) -- 1275
		uiArt:tryPlacePath( -- 1276
			"assets/art/tex_diorama_ming.clip|ming_water", -- 1277
			"fe06_well_water_tex", -- 1278
			ax + math.sin(t * 0.8) * 6, -- 1279
			ay + math.cos(t * 0.6) * 5, -- 1280
			wellR * 1.48, -- 1281
			wellR * 1.48, -- 1282
			{ -- 1283
				color = Color(74, 96, 122, 255), -- 1284
				opacity = 0.44 * wellAlpha, -- 1285
				smooth = true, -- 1286
				layer = 0 -- 1287
			} -- 1287
		) -- 1287
		local rimSize = wellR * 2.86 -- 1290
		if not uiArt:tryPlacePath( -- 1290
			"assets/art/cutscene_well_museum.clip|well_topdown_rim", -- 1292
			"fe06_well_topdown_rim", -- 1293
			ax, -- 1294
			ay, -- 1295
			rimSize, -- 1296
			rimSize * (361 / 369), -- 1297
			{ -- 1298
				anchorX = 0.5, -- 1299
				anchorY = 0.5, -- 1300
				color = Color(176, 188, 198, 255), -- 1301
				opacity = wellAlpha, -- 1302
				smooth = true, -- 1303
				layer = 2 -- 1304
			} -- 1304
		) then -- 1304
			uiDraw:drawCircle( -- 1307
				Vec2(ax, ay), -- 1307
				wellR + 36, -- 1307
				Color( -- 1307
					30, -- 1307
					35, -- 1307
					42, -- 1307
					math.floor(240 * wellAlpha + 0.5) -- 1307
				) -- 1307
			) -- 1307
			uiDraw:drawCircle( -- 1308
				Vec2(ax, ay), -- 1308
				wellR, -- 1308
				Color( -- 1308
					7, -- 1308
					11, -- 1308
					17, -- 1308
					math.floor(255 * wellAlpha + 0.5) -- 1308
				) -- 1308
			) -- 1308
		end -- 1308
		local ri = 0 -- 1312
		do -- 1312
			ri = 0 -- 1313
			while ri < 3 do -- 1313
				local cyc = (t * 0.42 + ri * 0.33) % 1 -- 1314
				local r = 20 + cyc * (wellR * 0.85) -- 1315
				local ra = math.floor((1 - cyc) * 88 * wellAlpha + 0.5) -- 1316
				drawCircleRing( -- 1317
					uiInkDraw, -- 1317
					ax, -- 1317
					ay, -- 1317
					r, -- 1317
					Color(0, 0, 0, 0), -- 1317
					1.1, -- 1317
					Color(176, 198, 222, ra), -- 1317
					32 -- 1317
				) -- 1317
				ri = ri + 1 -- 1313
			end -- 1313
		end -- 1313
		local compassSlide = smoothstep(0.15, 0.95, t) -- 1321
		local compX = ax + (1 - compassSlide) * 140 -- 1322
		local compY = ay - (1 - compassSlide) * 90 -- 1323
		local compR = 62 -- 1324
		uiArt:tryPlacePath( -- 1325
			"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 1326
			"fe06_well_compass_pouch", -- 1327
			compX - 18, -- 1328
			compY - 22, -- 1329
			168, -- 1330
			172, -- 1331
			{ -- 1332
				anchorX = 0.5, -- 1333
				anchorY = 0.5, -- 1334
				angle = -18, -- 1335
				opacity = 0.86 * wellAlpha, -- 1336
				smooth = true, -- 1337
				layer = 3 -- 1338
			} -- 1338
		) -- 1338
		drawCircleRing( -- 1341
			uiInkDraw, -- 1342
			compX, -- 1343
			compY, -- 1344
			compR, -- 1345
			Color( -- 1346
				16, -- 1346
				24, -- 1346
				36, -- 1346
				math.floor(112 * wellAlpha + 0.5) -- 1346
			), -- 1346
			1.4, -- 1347
			Color( -- 1348
				218, -- 1348
				226, -- 1348
				236, -- 1348
				math.floor(175 * wellAlpha + 0.5) -- 1348
			), -- 1348
			32 -- 1349
		) -- 1349
		local needleAng = -0.35 + math.sin(t * 2.2) * 0.08 * (1 - matchK) -- 1351
		local nx = math.cos(needleAng) * 34 -- 1352
		local ny = math.sin(needleAng) * 34 -- 1353
		uiInkDraw:drawSegment( -- 1354
			Vec2(compX, compY), -- 1354
			Vec2(compX + nx, compY + ny), -- 1354
			2.2, -- 1354
			Color( -- 1354
				208, -- 1354
				92, -- 1354
				82, -- 1354
				math.floor(215 * wellAlpha + 0.5) -- 1354
			) -- 1354
		) -- 1354
		uiInkDraw:drawSegment( -- 1355
			Vec2(compX, compY), -- 1355
			Vec2(compX - nx * 0.85, compY - ny * 0.85), -- 1355
			1.8, -- 1355
			Color( -- 1355
				214, -- 1355
				222, -- 1355
				232, -- 1355
				math.floor(185 * wellAlpha + 0.5) -- 1355
			) -- 1355
		) -- 1355
		if t >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 1355
			local pickK = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellMatchCutStart, t) -- 1359
			local liftY = ay + pickK * 14 -- 1360
			drawCircleRing( -- 1361
				uiInkDraw, -- 1362
				ax, -- 1363
				liftY, -- 1364
				24 + pickK * 12, -- 1365
				Color(0, 0, 0, 0), -- 1366
				1.6, -- 1367
				Color( -- 1368
					226, -- 1368
					204, -- 1368
					152, -- 1368
					math.floor(215 * (1 - matchK * 0.65) + 0.5) -- 1368
				), -- 1368
				28 -- 1369
			) -- 1369
			local capA = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellPickupAt + 0.35, t) * (1 - matchK) -- 1371
			if capA > 0.03 then -- 1371
				drawSilkVeil( -- 1373
					uiDraw, -- 1373
					uiArt, -- 1373
					"fe06_pickup_veil", -- 1373
					w * 0.5, -- 1373
					96, -- 1373
					300, -- 1373
					34, -- 1373
					PALETTE.inkVoid, -- 1373
					0.78 * capA, -- 1373
					5 -- 1373
				) -- 1373
				ctx.texts:put( -- 1374
					"sm", -- 1375
					"拾起「时间穿梭器」", -- 1376
					w * 0.5, -- 1377
					96, -- 1378
					toColor(PALETTE.amberCore), -- 1379
					0.5, -- 1380
					0.5, -- 1381
					"Center", -- 1382
					1.4, -- 1383
					capA -- 1384
				) -- 1384
			end -- 1384
		end -- 1384
	end -- 1384
	if matchK > 0.01 then -- 1384
		local cover = math.max(w / 960, h / 540) -- 1392
		uiArt:tryPlacePath( -- 1393
			"assets/art/bg_museum_hall.png", -- 1394
			"fe06_match_museum_bg", -- 1395
			w * 0.5 + (self.glassAnchorX - w * 0.47) * 0.4, -- 1396
			h * 0.5, -- 1397
			960 * cover, -- 1398
			540 * cover, -- 1399
			{ -- 1400
				anchorX = 0.5, -- 1401
				anchorY = 0.5, -- 1402
				opacity = matchK * 0.94, -- 1403
				smooth = true, -- 1404
				layer = 1 -- 1405
			} -- 1405
		) -- 1405
		local caseW = 240 -- 1408
		local caseH = 224 -- 1409
		local caseX = self.glassAnchorX - caseW * 0.5 -- 1410
		local caseY = self.glassAnchorY - caseH * 0.54 -- 1411
		fillGradQuad( -- 1412
			uiInkDraw, -- 1413
			self.glassAnchorX - 42, -- 1414
			caseY + caseH - 6, -- 1414
			Color( -- 1414
				224, -- 1414
				236, -- 1414
				248, -- 1414
				math.floor(44 * matchK + 0.5) -- 1414
			), -- 1414
			self.glassAnchorX + 24, -- 1415
			caseY + caseH - 6, -- 1415
			Color( -- 1415
				238, -- 1415
				246, -- 1415
				255, -- 1415
				math.floor(78 * matchK + 0.5) -- 1415
			), -- 1415
			self.glassAnchorX - 18, -- 1416
			caseY + 6, -- 1416
			Color( -- 1416
				224, -- 1416
				236, -- 1416
				248, -- 1416
				math.floor(24 * matchK + 0.5) -- 1416
			), -- 1416
			self.glassAnchorX - 82, -- 1417
			caseY + 6, -- 1417
			Color(224, 236, 248, 0) -- 1417
		) -- 1417
		uiArt:tryPlace( -- 1419
			"prop_compass", -- 1419
			"fe06_match_compass", -- 1419
			self.glassAnchorX, -- 1419
			caseY + 72, -- 1419
			46, -- 1419
			46, -- 1419
			{opacity = matchK * 0.9, layer = 4} -- 1419
		) -- 1419
	end -- 1419
	local flashPeak = math.sin(matchK * math.pi) -- 1426
	local coreR = 8 + flashPeak * 18 -- 1427
	uiInkDraw:drawCircle( -- 1428
		Vec2(ax, ay), -- 1428
		coreR * 0.55, -- 1428
		Color(248, 252, 255, 248) -- 1428
	) -- 1428
	fillRadialGlow( -- 1429
		uiGlow, -- 1430
		ax, -- 1431
		ay, -- 1432
		52 + flashPeak * 145, -- 1433
		46 + flashPeak * 115, -- 1434
		Color( -- 1435
			238, -- 1435
			246, -- 1435
			255, -- 1435
			math.floor(145 + flashPeak * 95 + 0.5) -- 1435
		), -- 1435
		Color(174, 204, 238, 0), -- 1436
		20 -- 1437
	) -- 1437
	if flashPeak > 0.05 then -- 1437
		local rayW = 70 + flashPeak * 260 -- 1441
		fillHGradRect( -- 1442
			uiGlow, -- 1442
			ax - rayW, -- 1442
			ay - 2, -- 1442
			rayW, -- 1442
			4, -- 1442
			Color(224, 238, 252, 0), -- 1442
			Color( -- 1442
				242, -- 1442
				248, -- 1442
				255, -- 1442
				math.floor(160 * flashPeak + 0.5) -- 1442
			) -- 1442
		) -- 1442
		fillHGradRect( -- 1443
			uiGlow, -- 1443
			ax, -- 1443
			ay - 2, -- 1443
			rayW, -- 1443
			4, -- 1443
			Color( -- 1443
				242, -- 1443
				248, -- 1443
				255, -- 1443
				math.floor(160 * flashPeak + 0.5) -- 1443
			), -- 1443
			Color(224, 238, 252, 0) -- 1443
		) -- 1443
	end -- 1443
	self:drawLetterbox( -- 1446
		uiInkDraw, -- 1446
		w, -- 1446
		h, -- 1446
		42, -- 1446
		0.92 -- 1446
	) -- 1446
end -- 1236
function WellMuseumPlugin.prototype.renderE02MuseumHall(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, lampTurnProg, inLampTurn) -- 1452
	local floorY = 148 -- 1463
	local wallTopY = h - 86 -- 1464
	local halfW = w * 0.5 -- 1465
	local camMin = math.min(____exports.MUSEUM_HALL_WIDTH * 0.5, halfW - 40) -- 1466
	local camMax = math.max(____exports.MUSEUM_HALL_WIDTH * 0.5, ____exports.MUSEUM_HALL_WIDTH - halfW + 40) -- 1467
	local camX = clamp(self.hallCamX, camMin, camMax) -- 1468
	local function toScreenX(hx) -- 1469
		return halfW + (hx - camX) -- 1469
	end -- 1469
	fillVGradRect( -- 1472
		uiDraw, -- 1472
		0, -- 1472
		floorY, -- 1472
		w, -- 1472
		h - floorY, -- 1472
		Color(26, 31, 38, 255), -- 1472
		Color(16, 20, 26, 255) -- 1472
	) -- 1472
	fillVGradRect( -- 1473
		uiDraw, -- 1473
		0, -- 1473
		0, -- 1473
		w, -- 1473
		floorY, -- 1473
		Color(14, 17, 22, 255), -- 1473
		Color(32, 37, 45, 255) -- 1473
	) -- 1473
	local bgW = math.max(w * 1.18, ____exports.MUSEUM_HALL_WIDTH + 200) -- 1474
	local bgH = h -- 1475
	local bgCenterX = toScreenX(____exports.MUSEUM_HALL_WIDTH * 0.5) -- 1476
	local paintedHall = uiArt:tryPlacePath( -- 1477
		"assets/art/bg_museum_hall.png", -- 1478
		"fe06_museum_hall_bg", -- 1479
		bgCenterX, -- 1480
		h * 0.5, -- 1481
		bgW, -- 1482
		bgH, -- 1483
		{ -- 1484
			anchorX = 0.5, -- 1485
			anchorY = 0.5, -- 1486
			opacity = 1, -- 1487
			smooth = true, -- 1488
			layer = -6 -- 1489
		} -- 1489
	) -- 1489
	if not paintedHall then -- 1489
		uiDraw:drawRect( -- 1493
			Rect(0, wallTopY, w, h - wallTopY), -- 1493
			Color(11, 14, 19, 255) -- 1493
		) -- 1493
		uiDraw:drawSegment( -- 1494
			Vec2(0, floorY), -- 1494
			Vec2(w, floorY), -- 1494
			2, -- 1494
			Color(76, 86, 98, 220) -- 1494
		) -- 1494
	end -- 1494
	local plaqueWorldX = self.caseX <= 260 and 108 or 180 -- 1498
	local plaqueX = toScreenX(plaqueWorldX) -- 1499
	if plaqueX > -240 and plaqueX < w + 240 then -- 1499
		local pw = 286 -- 1501
		local ph = 112 -- 1502
		local py = floorY + 146 -- 1503
		drawSilkVeil( -- 1504
			uiDraw, -- 1504
			uiArt, -- 1504
			"fe06_plaque_veil", -- 1504
			plaqueX, -- 1504
			py + ph * 0.5, -- 1504
			pw, -- 1504
			ph, -- 1504
			PALETTE.inkVoid, -- 1504
			0.62, -- 1504
			0 -- 1504
		) -- 1504
		fillRadialGlow( -- 1505
			uiGlow, -- 1505
			plaqueX, -- 1505
			wallTopY - 8, -- 1505
			150, -- 1505
			120, -- 1505
			Color(224, 232, 240, 38), -- 1505
			Color(180, 196, 214, 0), -- 1505
			14 -- 1505
		) -- 1505
		ctx.texts:put( -- 1506
			"sm", -- 1507
			"海防抗战纪念展厅", -- 1508
			plaqueX, -- 1509
			py + 72, -- 1510
			toColor(PALETTE.textBright), -- 1511
			0.5, -- 1512
			0.5, -- 1513
			"Center", -- 1514
			2, -- 1515
			0.9 -- 1516
		) -- 1516
		ctx.texts:put( -- 1518
			"xs", -- 1519
			"温州宁村 · 守望史迹陈列", -- 1520
			plaqueX, -- 1521
			py + 38, -- 1522
			toColor(PALETTE.textMid), -- 1523
			0.5, -- 1524
			0.5, -- 1525
			"Center", -- 1526
			1, -- 1527
			0.8 -- 1528
		) -- 1528
	end -- 1528
	local caseSx = toScreenX(self.caseX) -- 1533
	if caseSx > -260 and caseSx < w + 260 then -- 1533
		local pedW = 148 -- 1535
		local pedH = 92 -- 1536
		local glassH = 128 -- 1537
		if not paintedHall then -- 1537
			uiDraw:drawRect( -- 1539
				Rect(caseSx - pedW * 0.5, floorY, pedW, pedH), -- 1539
				Color(22, 26, 33, 252), -- 1539
				1.2, -- 1539
				Color(96, 106, 118, 185) -- 1539
			) -- 1539
			uiDraw:drawRect( -- 1540
				Rect(caseSx - pedW * 0.46, floorY + pedH, pedW * 0.92, glassH), -- 1540
				Color(16, 22, 30, 165), -- 1540
				1.4, -- 1540
				Color(180, 196, 214, 195) -- 1540
			) -- 1540
		end -- 1540
		uiArt:tryPlace( -- 1543
			"prop_compass", -- 1543
			"fe06_hall_compass", -- 1543
			caseSx - 6, -- 1543
			floorY + pedH + 18, -- 1543
			32, -- 1543
			32, -- 1543
			{opacity = 0.96, layer = 2} -- 1543
		) -- 1543
		uiArt:tryPlacePath( -- 1547
			"assets/art/cutscene_cuff_rig.clip|cuff_zhou_open", -- 1547
			"fe06_hall_cuff_relic", -- 1547
			caseSx + 14, -- 1547
			floorY + pedH + 14, -- 1547
			58, -- 1547
			26, -- 1547
			{ -- 1547
				anchorX = 0.5, -- 1548
				anchorY = 0.5, -- 1549
				angle = -8, -- 1550
				opacity = 0.34, -- 1551
				smooth = true, -- 1552
				layer = 1 -- 1553
			} -- 1553
		) -- 1553
		fillGradQuad( -- 1555
			uiInkDraw, -- 1556
			caseSx - 28, -- 1557
			floorY + pedH + glassH - 4, -- 1557
			Color(230, 240, 252, 36), -- 1557
			caseSx + 12, -- 1558
			floorY + pedH + glassH - 4, -- 1558
			Color(242, 248, 255, 62), -- 1558
			caseSx - 12, -- 1559
			floorY + pedH + 4, -- 1559
			Color(230, 240, 252, 14), -- 1559
			caseSx - 48, -- 1560
			floorY + pedH + 4, -- 1560
			Color(230, 240, 252, 0) -- 1560
		) -- 1560
		fillRadialGlow( -- 1562
			uiGlow, -- 1562
			caseSx, -- 1562
			floorY + pedH + glassH - 12, -- 1562
			86, -- 1562
			128, -- 1562
			Color(224, 236, 250, 52), -- 1562
			Color(168, 192, 220, 0), -- 1562
			16 -- 1562
		) -- 1562
	end -- 1562
	local lampSx = toScreenX(self.lampX) -- 1566
	local winSx = toScreenX(self.lampX + 108) -- 1567
	local reflectK = inLampTurn and smoothstep(____exports.MUSEUM_TIMINGS.lampReflectStart, 2.35, self.lampElapsed) or 0 -- 1568
	if winSx > -260 and winSx < w + 260 then -- 1568
		local winW = 204 -- 1573
		local winH = 312 -- 1574
		local winX = winSx - winW * 0.5 -- 1575
		local winY = floorY + 38 -- 1576
		if not paintedHall then -- 1576
			fillVGradRect( -- 1578
				uiDraw, -- 1578
				winX, -- 1578
				winY, -- 1578
				winW, -- 1578
				winH, -- 1578
				Color(54, 68, 92, 255), -- 1578
				Color(30, 44, 70, 255) -- 1578
			) -- 1578
			uiInkDraw:drawRect( -- 1579
				Rect(winX, winY, winW, winH), -- 1579
				Color(0, 0, 0, 0), -- 1579
				3, -- 1579
				Color(68, 76, 88, 245) -- 1579
			) -- 1579
		end -- 1579
		if reflectK > 0.02 then -- 1579
			uiArt:tryPlace( -- 1584
				"bgFar_prologue", -- 1584
				"fe06_window_courtyard", -- 1584
				winSx, -- 1584
				winY + 26, -- 1584
				winW - 8, -- 1584
				winH - 52, -- 1584
				{ -- 1584
					opacity = reflectK * 0.52, -- 1585
					color = Color(242, 222, 188, 255), -- 1586
					layer = 1 -- 1587
				} -- 1587
			) -- 1587
			fillRadialGlow( -- 1589
				uiGlow, -- 1589
				winSx, -- 1589
				winY + winH * 0.48, -- 1589
				136, -- 1589
				152, -- 1589
				Color( -- 1589
					248, -- 1589
					220, -- 1589
					170, -- 1589
					math.floor(98 * reflectK + 0.5) -- 1589
				), -- 1589
				Color(214, 174, 112, 0), -- 1589
				18 -- 1589
			) -- 1589
		end -- 1589
		local aimDir = -0.65 + lampTurnProg * 1.48 -- 1593
		local lampH = 192 -- 1594
		local lampW = lampH * (236 / 360) -- 1595
		local headX = lampSx + 18 + math.sin(aimDir) * 20 -- 1596
		local headY = floorY + lampH - 34 + math.cos(aimDir) * 10 -- 1597
		if not uiArt:tryPlacePath( -- 1597
			"assets/art/cutscene_well_museum.clip|museum_brass_lamp", -- 1599
			"fe06_museum_brass_lamp", -- 1600
			lampSx, -- 1601
			floorY, -- 1602
			lampW, -- 1603
			lampH, -- 1604
			{ -- 1605
				anchorX = 0.5, -- 1606
				anchorY = 0, -- 1607
				angle = 0, -- 1608
				opacity = 0.98, -- 1609
				smooth = true, -- 1610
				layer = 4 -- 1611
			} -- 1611
		) then -- 1611
			uiDraw:drawRect( -- 1614
				Rect(lampSx - 17, floorY, 34, 96), -- 1614
				Color(34, 39, 48, 250) -- 1614
			) -- 1614
		end -- 1614
		local beamLen = 138 + lampTurnProg * 86 -- 1618
		local bxEnd = headX + math.sin(aimDir) * beamLen -- 1619
		local byEnd = headY + math.cos(aimDir) * 28 -- 1620
		local perpX = -math.cos(aimDir) * 18 -- 1621
		local perpY = math.sin(aimDir) * 34 -- 1622
		fillGradQuad( -- 1623
			uiGlow, -- 1624
			headX, -- 1625
			headY - 4, -- 1625
			Color( -- 1625
				246, -- 1625
				224, -- 1625
				178, -- 1625
				math.floor(68 + 46 * lampTurnProg + 0.5) -- 1625
			), -- 1625
			headX, -- 1626
			headY + 4, -- 1626
			Color( -- 1626
				246, -- 1626
				224, -- 1626
				178, -- 1626
				math.floor(68 + 46 * lampTurnProg + 0.5) -- 1626
			), -- 1626
			bxEnd + perpX, -- 1627
			byEnd + perpY + 34, -- 1627
			Color(238, 206, 148, 0), -- 1627
			bxEnd - perpX, -- 1628
			byEnd - perpY - 22, -- 1628
			Color(238, 206, 148, 0) -- 1628
		) -- 1628
		fillRadialGlow( -- 1630
			uiGlow, -- 1630
			headX, -- 1630
			headY, -- 1630
			38, -- 1630
			38, -- 1630
			Color(248, 228, 186, 82), -- 1630
			Color(224, 194, 140, 0), -- 1630
			14 -- 1630
		) -- 1630
	end -- 1630
	local playerSx = toScreenX(self.hallWalkX) -- 1634
	local moving = not inLampTurn and (self.hallMoving or math.abs(ctx.input.moveX) > 0.05) -- 1635
	local slot = moving and "soldier_run" or "soldier_idle" -- 1636
	local frame = moving and math.floor(self.hallWalkAnim) or 0 -- 1637
	local charH = math.floor(192 * math.max( -- 1638
		0.75, -- 1638
		math.min(1.25, h / 720) -- 1638
	) + 0.5) -- 1638
	local charW = math.floor(charH * 0.45 + 0.5) -- 1639
	uiDraw:drawEllipse( -- 1641
		Vec2(playerSx, floorY + 2), -- 1641
		34, -- 1641
		6.5, -- 1641
		Color(6, 8, 12, 178) -- 1641
	) -- 1641
	uiDraw:drawEllipse( -- 1642
		Vec2(playerSx, floorY - 14), -- 1642
		24, -- 1642
		4.5, -- 1642
		Color(16, 20, 28, 62) -- 1642
	) -- 1642
	if not uiArt:tryPlace( -- 1642
		slot, -- 1643
		"fe06_museum_zhoushu", -- 1643
		playerSx, -- 1643
		floorY + 2, -- 1643
		charW, -- 1643
		charH, -- 1643
		{facing = self.hallFacing, frame = frame, layer = 3} -- 1643
	) then -- 1643
		uiDraw:drawRect( -- 1649
			Rect(playerSx - 20, floorY + 2, 40, charH * 0.84), -- 1649
			toColor(CUFF_PALETTE.indigoBase) -- 1649
		) -- 1649
		uiDraw:drawCircle( -- 1650
			Vec2(playerSx, floorY + charH * 0.92), -- 1650
			16, -- 1650
			Color(66, 73, 76, 255) -- 1650
		) -- 1650
	end -- 1650
	if self.holstered and not inLampTurn and math.abs(self.hallWalkX - self.caseX) <= 130 then -- 1650
		local subA = clamp01(1 - math.abs(self.hallWalkX - self.caseX) / 145) * 0.86 -- 1655
		ctx.texts:put( -- 1656
			"xs", -- 1657
			"已收起随身器物", -- 1658
			caseSx, -- 1659
			floorY + 252, -- 1660
			toColor(PALETTE.textMid), -- 1661
			0.5, -- 1662
			0.5, -- 1663
			"Center", -- 1664
			0.9, -- 1665
			subA -- 1666
		) -- 1666
	end -- 1666
	if self.childEchoVisualT > 0 then -- 1666
		local echoK = 1 - clamp01(self.childEchoVisualT / 2.1) -- 1672
		local ex = math.min( -- 1673
			w - 110, -- 1673
			toScreenX(self.caseX + 310) -- 1673
		) -- 1673
		local ey = floorY + 32 -- 1674
		local ea = math.floor(math.sin(echoK * math.pi) * 165 + 0.5) -- 1675
		drawCircleRing( -- 1676
			uiInkDraw, -- 1676
			ex, -- 1676
			ey, -- 1676
			14 + echoK * 46, -- 1676
			Color(0, 0, 0, 0), -- 1676
			1.1, -- 1676
			Color(224, 214, 194, ea), -- 1676
			28 -- 1676
		) -- 1676
		drawCircleRing( -- 1677
			uiInkDraw, -- 1677
			ex, -- 1677
			ey, -- 1677
			8 + echoK * 28, -- 1677
			Color(0, 0, 0, 0), -- 1677
			0.9, -- 1677
			Color( -- 1677
				224, -- 1677
				214, -- 1677
				194, -- 1677
				math.floor(ea * 0.7 + 0.5) -- 1677
			), -- 1677
			24 -- 1677
		) -- 1677
		ctx.texts:put( -- 1678
			"xs", -- 1679
			"（远方传来轻快的孩童脚步声）", -- 1680
			w * 0.5, -- 1681
			84, -- 1682
			toColor(PALETTE.textMid), -- 1683
			0.5, -- 1684
			0.5, -- 1685
			"Center", -- 1686
			1, -- 1687
			math.sin(echoK * math.pi) * 0.85 -- 1688
		) -- 1688
	end -- 1688
	if not inLampTurn then -- 1688
		local fadeIn = smoothstep(0, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn, self.hallIntroElapsed) -- 1694
		local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold + ____exports.MUSEUM_TIMINGS.hallIntroFadeOut, self.hallIntroElapsed) -- 1695
		local introA = fadeIn * fadeOut -- 1700
		if introA > 0.02 then -- 1700
			drawSilkVeil( -- 1702
				uiDraw, -- 1702
				uiArt, -- 1702
				"fe06_hall_intro_veil", -- 1702
				w * 0.5, -- 1702
				h - 104, -- 1702
				480, -- 1702
				74, -- 1702
				PALETTE.inkVoid, -- 1702
				0.78 * introA, -- 1702
				1 -- 1702
			) -- 1702
			drawHairline( -- 1703
				uiInkDraw, -- 1703
				uiArt, -- 1703
				"fe06_hall_intro_line", -- 1703
				w * 0.5, -- 1703
				h - 106, -- 1703
				260, -- 1703
				PALETTE.silkLine, -- 1703
				0.45 * introA, -- 1703
				false, -- 1703
				4 -- 1703
			) -- 1703
			ctx.texts:put( -- 1704
				"md", -- 1704
				____exports.MUSEUM_HALL_TITLE, -- 1704
				w * 0.5, -- 1704
				h - 88, -- 1704
				toColor(PALETTE.textBright), -- 1704
				0.5, -- 1704
				0.5, -- 1704
				"Center", -- 1704
				1.8, -- 1704
				introA -- 1704
			) -- 1704
			ctx.texts:put( -- 1705
				"xs", -- 1705
				____exports.MUSEUM_HALL_SUBTITLE, -- 1705
				w * 0.5, -- 1705
				h - 122, -- 1705
				toColor(PALETTE.amberCore), -- 1705
				0.5, -- 1705
				0.5, -- 1705
				"Center", -- 1705
				1.2, -- 1705
				introA * 0.88 -- 1705
			) -- 1705
		end -- 1705
		if self.nearLamp and ctx.view.assistHintsEnabled then -- 1705
			drawSilkVeil( -- 1710
				uiDraw, -- 1710
				uiArt, -- 1710
				"fe06_lamp_hint_veil", -- 1710
				lampSx, -- 1710
				floorY + 158, -- 1710
				146, -- 1710
				28, -- 1710
				PALETTE.panelBg, -- 1710
				0.84, -- 1710
				1 -- 1710
			) -- 1710
			ctx.texts:put( -- 1711
				"xs", -- 1712
				getActiveTarget():adaptHintSentence("[E] 转动西窗灯", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1713
				lampSx, -- 1714
				floorY + 158, -- 1715
				toColor(PALETTE.textBright), -- 1716
				0.5, -- 1717
				0.5, -- 1718
				"Center", -- 1719
				0.6, -- 1720
				0.94 -- 1721
			) -- 1721
		end -- 1721
	end -- 1721
	if inLampTurn and self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1721
		local lineA = smoothstep(____exports.MUSEUM_TIMINGS.lampLineAt, ____exports.MUSEUM_TIMINGS.lampLineAt + 0.45, self.lampElapsed) * (1 - smoothstep(____exports.MUSEUM_TIMINGS.lampTurnDuration - 0.35, ____exports.MUSEUM_TIMINGS.lampTurnDuration, self.lampElapsed)) -- 1728
		if lineA > 0.02 then -- 1728
			drawSilkVeil( -- 1731
				uiDraw, -- 1731
				uiArt, -- 1731
				"fe06_dawn_line_veil", -- 1731
				w * 0.5, -- 1731
				86, -- 1731
				440, -- 1731
				50, -- 1731
				PALETTE.inkVoid, -- 1731
				0.84 * lineA, -- 1731
				1 -- 1731
			) -- 1731
			ctx.texts:put( -- 1732
				"md", -- 1733
				____exports.MUSEUM_LINE_DAWN, -- 1733
				w * 0.5, -- 1735
				86, -- 1736
				toColor(PALETTE.amberCore), -- 1737
				0.5, -- 1738
				0.5, -- 1739
				"Center", -- 1740
				1.6, -- 1741
				lineA -- 1742
			) -- 1742
		end -- 1742
	end -- 1742
	if self.knock1VisualT > 0 then -- 1742
		local k1 = 1 - clamp01(self.knock1VisualT / 0.85) -- 1748
		local k1A = math.floor((1 - k1) * 205 + 0.5) -- 1749
		drawCircleRing( -- 1750
			uiInkDraw, -- 1750
			winSx, -- 1750
			floorY + 148, -- 1750
			12 + k1 * 64, -- 1750
			Color(0, 0, 0, 0), -- 1750
			1.6, -- 1750
			Color(242, 232, 206, k1A), -- 1750
			28 -- 1750
		) -- 1750
		drawCircleRing( -- 1751
			uiInkDraw, -- 1751
			winSx, -- 1751
			floorY + 148, -- 1751
			6 + k1 * 34, -- 1751
			Color(0, 0, 0, 0), -- 1751
			1.1, -- 1751
			Color( -- 1751
				242, -- 1751
				232, -- 1751
				206, -- 1751
				math.floor(k1A * 0.72 + 0.5) -- 1751
			), -- 1751
			24 -- 1751
		) -- 1751
	end -- 1751
	self:drawLetterbox( -- 1754
		uiInkDraw, -- 1754
		w, -- 1754
		h, -- 1754
		38, -- 1754
		0.9 -- 1754
	) -- 1754
end -- 1452
function WellMuseumPlugin.prototype.renderE02ReturnCabinet(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1760
	local t = self.returnElapsed -- 1769
	local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.returnFadeOutAt, ____exports.MUSEUM_TIMINGS.returnCabinetDuration, t) -- 1770
	uiDraw:drawRect( -- 1773
		Rect(0, 0, w, h), -- 1773
		Color( -- 1773
			7, -- 1773
			9, -- 1773
			13, -- 1773
			math.floor(252 * fadeOut + 0.5) -- 1773
		) -- 1773
	) -- 1773
	if t < ____exports.MUSEUM_TIMINGS.returnKnock2At then -- 1773
		self:drawLetterbox( -- 1776
			uiInkDraw, -- 1776
			w, -- 1776
			h, -- 1776
			42, -- 1776
			0.95 * fadeOut -- 1776
		) -- 1776
		return -- 1777
	end -- 1777
	local revealK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.34, t) * fadeOut -- 1781
	local barH = 42 -- 1782
	local by = barH -- 1783
	local boxH = math.max(120, h - barH * 2) -- 1784
	fillVGradRect( -- 1786
		uiDraw, -- 1787
		0, -- 1788
		by, -- 1789
		w, -- 1790
		boxH, -- 1791
		Color( -- 1792
			12, -- 1792
			11, -- 1792
			16, -- 1792
			math.floor(248 * revealK + 0.5) -- 1792
		), -- 1792
		Color( -- 1793
			22, -- 1793
			22, -- 1793
			28, -- 1793
			math.floor(248 * revealK + 0.5) -- 1793
		) -- 1793
	) -- 1793
	local cabEdgeX = w * 0.58 -- 1795
	uiArt:tryPlacePath( -- 1796
		"assets/art/tex_diorama_ming.clip|ming_timber", -- 1797
		"fe06_return_cab_wood", -- 1798
		cabEdgeX + (w - cabEdgeX) * 0.5, -- 1799
		by + boxH * 0.5, -- 1800
		math.max(12, w - cabEdgeX), -- 1801
		boxH, -- 1802
		{ -- 1803
			color = Color(110, 90, 74, 255), -- 1804
			opacity = 0.94 * revealK, -- 1805
			smooth = true, -- 1806
			layer = 1 -- 1807
		} -- 1807
	) -- 1807
	uiArt:tryPlacePath( -- 1810
		"assets/art/cutscene_well_museum.clip|prologue_cabinet_doors", -- 1811
		"fe06_return_cab_door", -- 1812
		cabEdgeX + 110, -- 1813
		by + boxH * 0.5, -- 1814
		340, -- 1815
		boxH * 0.92, -- 1816
		{ -- 1817
			anchorX = 0.5, -- 1818
			anchorY = 0.5, -- 1819
			color = Color(138, 120, 102, 255), -- 1820
			opacity = 0.85 * revealK, -- 1821
			smooth = true, -- 1822
			layer = 2 -- 1823
		} -- 1823
	) -- 1823
	uiDraw:drawSegment( -- 1826
		Vec2(cabEdgeX, by), -- 1826
		Vec2(cabEdgeX, by + boxH), -- 1826
		2.4, -- 1826
		Color( -- 1826
			128, -- 1826
			102, -- 1826
			76, -- 1826
			math.floor(210 * revealK + 0.5) -- 1826
		) -- 1826
	) -- 1826
	fillHGradRect( -- 1827
		uiGlow, -- 1828
		cabEdgeX - 68, -- 1829
		by + 24, -- 1830
		68, -- 1831
		boxH - 48, -- 1832
		Color(168, 188, 210, 0), -- 1833
		Color( -- 1834
			186, -- 1834
			206, -- 1834
			226, -- 1834
			math.floor(48 * revealK + 0.5) -- 1834
		) -- 1834
	) -- 1834
	if self.knock2VisualT > 0 then -- 1834
		local k2 = 1 - clamp01(self.knock2VisualT / 0.9) -- 1839
		local k2A = math.floor((1 - k2) * 185 * fadeOut + 0.5) -- 1840
		fillRadialGlow( -- 1841
			uiGlow, -- 1841
			cabEdgeX + 6, -- 1841
			by + boxH * 0.5, -- 1841
			26 + k2 * 52, -- 1841
			26 + k2 * 52, -- 1841
			Color( -- 1841
				238, -- 1841
				224, -- 1841
				194, -- 1841
				math.floor(k2A * 0.42 + 0.5) -- 1841
			), -- 1841
			Color(238, 224, 194, 0), -- 1841
			16 -- 1841
		) -- 1841
		drawCircleRing( -- 1842
			uiInkDraw, -- 1842
			cabEdgeX + 8, -- 1842
			by + boxH * 0.5, -- 1842
			12 + k2 * 54, -- 1842
			Color(0, 0, 0, 0), -- 1842
			1.3, -- 1842
			Color(232, 220, 196, k2A), -- 1842
			28 -- 1842
		) -- 1842
	end -- 1842
	local extendK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.08, ____exports.MUSEUM_TIMINGS.returnKnock2At + 1.05, t) -- 1846
	local wristX = w * 0.14 + extendK * (cabEdgeX - w * 0.24) -- 1847
	local wristY = by + boxH * 0.5 -- 1848
	drawPatchedCuff(uiInkDraw, uiGlow, { -- 1849
		wristX = wristX, -- 1850
		wristY = wristY, -- 1851
		angleRad = -0.04 * (1 - extendK), -- 1852
		scale = 1.18, -- 1853
		pose = "reach", -- 1854
		opacity = revealK, -- 1855
		stitchHighlight = 0.48 + 0.22 * extendK, -- 1856
		cuffPullBack = 0.06, -- 1857
		warmth = 0.16, -- 1858
		uiArt = uiArt, -- 1859
		instanceKey = "fe06_return_zhou_cuff", -- 1860
		layer = 4 -- 1861
	}) -- 1861
	local tipA = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.45, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.95, t) * fadeOut -- 1864
	if tipA > 0.03 then -- 1864
		drawSilkVeil( -- 1866
			uiDraw, -- 1866
			uiArt, -- 1866
			"fe06_return_veil", -- 1866
			w * 0.5, -- 1866
			barH + 34, -- 1866
			320, -- 1866
			32, -- 1866
			PALETTE.inkVoid, -- 1866
			0.72 * tipA, -- 1866
			6 -- 1866
		) -- 1866
		ctx.texts:put( -- 1867
			"xs", -- 1868
			"两声轻敲落回柜板 · 寻回小满", -- 1869
			w * 0.5, -- 1870
			barH + 34, -- 1871
			toColor(PALETTE.textMid), -- 1872
			0.5, -- 1873
			0.5, -- 1874
			"Center", -- 1875
			1.2, -- 1876
			tipA * 0.9 -- 1877
		) -- 1877
	end -- 1877
	self:drawLetterbox( -- 1881
		uiInkDraw, -- 1881
		w, -- 1881
		h, -- 1881
		barH, -- 1881
		0.95 * fadeOut -- 1881
	) -- 1881
end -- 1760
function WellMuseumPlugin.prototype.drawLetterbox(self, draw, w, h, barH, opacity) -- 1884
	local a = math.floor(244 * clamp01(opacity) + 0.5) -- 1885
	if a <= 2 then -- 1885
		return -- 1887
	end -- 1887
	draw:drawRect( -- 1889
		Rect(0, 0, w, barH), -- 1889
		Color(6, 8, 12, a) -- 1889
	) -- 1889
	draw:drawRect( -- 1890
		Rect(0, h - barH, w, barH), -- 1890
		Color(6, 8, 12, a) -- 1890
	) -- 1890
end -- 1884
function ____exports.createWellMuseumPlugin(contract) -- 1894
	return __TS__New(____exports.WellMuseumPlugin, contract) -- 1895
end -- 1894
return ____exports -- 1894