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
function WellMuseumPlugin.prototype.____constructor(self, contract) -- 352
	self.id = "fe-06-well-museum" -- 287
	self.animTime = 0 -- 290
	self.prevPhase = "locked" -- 291
	self.roomSessionId = 0 -- 292
	self.rehearsal = false -- 293
	self.gateOpen = false -- 296
	self.gateBlockedReason = "locked" -- 297
	self.wellWorldX = ____exports.WELL_WORLD_X -- 298
	self.caseX = ____exports.MUSEUM_CASE_X -- 299
	self.lampX = ____exports.MUSEUM_LAMP_X -- 300
	self.nearWell = false -- 301
	self.revisitCalmTimer = 0 -- 302
	self.revisitCalmCount = 0 -- 303
	self.reflectElapsed = 0 -- 306
	self.wellAnchorX = 640 -- 307
	self.wellAnchorY = 388.8 -- 308
	self.glassAnchorX = 640 -- 309
	self.glassAnchorY = 388.8 -- 310
	self.enterHallSubmitted = false -- 311
	self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 314
	self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 315
	self.hallFacing = 1 -- 316
	self.hallWalkAnim = 0 -- 317
	self.hallMoving = false -- 318
	self.hallFootstepTimer = 0 -- 319
	self.hallIntroElapsed = 0 -- 320
	self.holstered = false -- 321
	self.childEchoCountdown = -1 -- 322
	self.childEchoPlayed = false -- 323
	self.childEchoVisualT = 0 -- 324
	self.nearLamp = false -- 325
	self.lampElapsed = 0 -- 327
	self.lineDawnShown = false -- 328
	self.knock1Played = false -- 329
	self.knock1VisualT = 0 -- 330
	self.beginReturnSubmitted = false -- 331
	self.returnElapsed = 0 -- 334
	self.knock2Played = false -- 335
	self.knock2VisualT = 0 -- 336
	self.returnCompleteSubmitted = false -- 337
	self.artifactGrantCount = 0 -- 340
	self.resumeRestoreCount = 0 -- 342
	self.lastResumePhase = "locked" -- 343
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 344
	self.lastVisualMode = "pixel" -- 345
	self.lastPaused = false -- 346
	self.wellDripPlaying = false -- 347
	self.hallAmbiencePlaying = false -- 348
	self.liveReflectDoneInMuseumRoom = false -- 349
	self.injectedContract = contract -- 353
end -- 352
function WellMuseumPlugin.prototype.syncRuntimeHook(self) -- 356
	local g = _G -- 357
	local ____temp_3 -- 358
	if g.package ~= nil then -- 358
		____temp_3 = g.package.loaded -- 358
	else -- 358
		____temp_3 = nil -- 358
	end -- 358
	local loaded = ____temp_3 -- 358
	if loaded == nil then -- 358
		return -- 360
	end -- 360
	local rawFe = loaded["watch.fe"] -- 362
	if rawFe ~= nil and type(rawFe) == "table" then -- 362
		local watchFe = rawFe -- 364
		if watchFe.wellMuseum ~= self then -- 364
			watchFe.wellMuseum = self -- 366
		end -- 366
	end -- 366
end -- 356
function WellMuseumPlugin.prototype.queueSimulatedInput(self, sim) -- 372
	self.simInput = {moveX = sim.moveX, interact = sim.interact} -- 373
end -- 372
function WellMuseumPlugin.prototype.exportResumeState(self) -- 380
	return { -- 381
		phase = self.prevPhase, -- 382
		hallWalkX = self.hallWalkX, -- 383
		hallCamX = self.hallCamX, -- 384
		hallFacing = self.hallFacing, -- 385
		holstered = self.holstered, -- 386
		childEchoPlayed = self.childEchoPlayed, -- 387
		reflectElapsed = self.reflectElapsed, -- 388
		lampElapsed = self.lampElapsed, -- 389
		returnElapsed = self.returnElapsed, -- 390
		artifactGrantCount = self.artifactGrantCount -- 391
	} -- 391
end -- 380
function WellMuseumPlugin.prototype.restoreResumeState(self, snap) -- 396
	if snap.phase ~= nil then -- 396
		self.prevPhase = snap.phase -- 398
		self.lastResumePhase = snap.phase -- 399
	end -- 399
	if snap.hallWalkX ~= nil then -- 399
		self.hallWalkX = clamp(snap.hallWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 402
		self.lastResumeWalkX = self.hallWalkX -- 403
	end -- 403
	if snap.hallCamX ~= nil then -- 403
		self.hallCamX = snap.hallCamX -- 406
	else -- 406
		self.hallCamX = self.hallWalkX -- 408
	end -- 408
	if snap.hallFacing ~= nil then -- 408
		self.hallFacing = snap.hallFacing >= 0 and 1 or -1 -- 411
	end -- 411
	if snap.holstered ~= nil then -- 411
		self.holstered = snap.holstered -- 414
	end -- 414
	if snap.childEchoPlayed ~= nil then -- 414
		self.childEchoPlayed = snap.childEchoPlayed -- 417
	end -- 417
	if snap.reflectElapsed ~= nil then -- 417
		self.reflectElapsed = math.max(0, snap.reflectElapsed) -- 420
	end -- 420
	if snap.lampElapsed ~= nil then -- 420
		self.lampElapsed = math.max(0, snap.lampElapsed) -- 423
	end -- 423
	if snap.returnElapsed ~= nil then -- 423
		self.returnElapsed = math.max(0, snap.returnElapsed) -- 426
	end -- 426
	if snap.artifactGrantCount ~= nil then -- 426
		self.artifactGrantCount = math.max(0, snap.artifactGrantCount) -- 429
	end -- 429
	self.savedResume = self:exportResumeState() -- 431
	self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 432
end -- 396
function WellMuseumPlugin.prototype.resetSessionCounters(self) -- 436
	self.artifactGrantCount = 0 -- 437
	self.revisitCalmCount = 0 -- 438
	self.revisitCalmTimer = 0 -- 439
	self.savedResume = nil -- 440
	self.resumeRestoreCount = 0 -- 441
	self.lastResumePhase = "locked" -- 442
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 443
end -- 436
function WellMuseumPlugin.prototype.setHallWalkPosition(self, x, holstered) -- 447
	self.hallWalkX = clamp(x, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 448
	self.hallCamX = self.hallWalkX -- 449
	if holstered ~= nil then -- 449
		self.holstered = holstered -- 451
	elseif self.hallWalkX >= self.caseX - 85 then -- 451
		self.holstered = true -- 453
	end -- 453
	self.savedResume = self:exportResumeState() -- 455
end -- 447
function WellMuseumPlugin.prototype.seekStageTime(self, stage, seconds) -- 459
	local s = math.max(0, seconds) -- 460
	if stage == "well_reflect" then -- 460
		self.reflectElapsed = math.min(____exports.MUSEUM_TIMINGS.wellReflectDuration, s) -- 462
	elseif stage == "lamp_turn" then -- 462
		self.lampElapsed = math.min(____exports.MUSEUM_TIMINGS.lampTurnDuration, s) -- 464
		self.lineDawnShown = self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt -- 465
	elseif stage == "return_cabinet" then -- 465
		self.returnElapsed = math.min(____exports.MUSEUM_TIMINGS.returnCabinetDuration, s) -- 467
	end -- 467
end -- 459
function WellMuseumPlugin.prototype.getDebugState(self) -- 471
	local reflectProg = clamp01(self.reflectElapsed / ____exports.MUSEUM_TIMINGS.wellReflectDuration) -- 472
	local matchStart = ____exports.MUSEUM_TIMINGS.wellMatchCutStart -- 473
	local matchSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.wellReflectDuration - matchStart) -- 474
	local matchProg = self.reflectElapsed <= matchStart and 0 or clamp01((self.reflectElapsed - matchStart) / matchSpan) -- 475
	local lampTurnProg = clamp01(self.lampElapsed / 1.15) -- 478
	local cuffStart = ____exports.MUSEUM_TIMINGS.returnKnock2At -- 479
	local cuffSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.returnFadeOutAt - cuffStart) -- 480
	local cuffProg = self.returnElapsed <= cuffStart and 0 or clamp01((self.returnElapsed - cuffStart) / cuffSpan) -- 481
	local dx = self.glassAnchorX - self.wellAnchorX -- 484
	local dy = self.glassAnchorY - self.wellAnchorY -- 485
	return { -- 486
		gateOpen = self.gateOpen, -- 487
		gateBlockedReason = self.gateBlockedReason, -- 488
		wellWorldX = self.wellWorldX, -- 489
		nearWell = self.nearWell, -- 490
		museumPhase = self.prevPhase, -- 491
		visualMode = self.lastVisualMode, -- 492
		reflectElapsed = self.reflectElapsed, -- 493
		reflectProgress = reflectProg, -- 494
		matchCutProgress = matchProg, -- 495
		wellAnchorX = self.wellAnchorX, -- 496
		wellAnchorY = self.wellAnchorY, -- 497
		glassAnchorX = self.glassAnchorX, -- 498
		glassAnchorY = self.glassAnchorY, -- 499
		matchCutAnchorDeltaPx = math.sqrt(dx * dx + dy * dy), -- 500
		hallWalkX = self.hallWalkX, -- 501
		hallCamX = self.hallCamX, -- 502
		holstered = self.holstered, -- 503
		childEchoPlayed = self.childEchoPlayed, -- 504
		nearLamp = self.nearLamp, -- 505
		lampElapsed = self.lampElapsed, -- 506
		lampTurnProgress = lampTurnProg, -- 507
		lineDawnShown = self.lineDawnShown, -- 508
		knock1Played = self.knock1Played, -- 509
		knock2Played = self.knock2Played, -- 510
		returnElapsed = self.returnElapsed, -- 511
		cuffReusedFromSharedPalette = true, -- 512
		cuffProgress = cuffProg, -- 513
		artifactGrantCount = self.artifactGrantCount, -- 514
		revisitCalmCount = self.revisitCalmCount, -- 515
		resumeRestoreCount = self.resumeRestoreCount, -- 516
		lastResumePhase = self.lastResumePhase, -- 517
		lastResumeWalkX = self.lastResumeWalkX, -- 518
		pausedFrozen = self.lastPaused -- 519
	} -- 519
end -- 471
function WellMuseumPlugin.prototype.onBindPlay(self, p, view) -- 523
	self:syncRuntimeHook() -- 524
	if view.isRehearsal ~= self.rehearsal then -- 524
		self.savedResume = nil -- 526
	end -- 526
	self.rehearsal = view.isRehearsal -- 528
	local ____view_isRehearsal_6 -- 529
	if view.isRehearsal then -- 529
		____view_isRehearsal_6 = nil -- 529
	else -- 529
		local ____opt_4 = p.room.story -- 529
		____view_isRehearsal_6 = ____opt_4 and ____opt_4.museum -- 529
	end -- 529
	local museum = ____view_isRehearsal_6 -- 529
	self.caseX = museum == nil and ____exports.MUSEUM_CASE_X or museum.cabinetX - p.ox -- 530
	self.lampX = museum == nil and ____exports.MUSEUM_LAMP_X or museum.lampX - p.ox -- 531
	self.animTime = 0 -- 532
	self.revisitCalmTimer = 0 -- 533
	self.childEchoVisualT = 0 -- 534
	self.knock1VisualT = 0 -- 535
	self.knock2VisualT = 0 -- 536
	self.wellDripPlaying = false -- 537
	self.hallAmbiencePlaying = false -- 538
	self.enterHallSubmitted = false -- 539
	self.beginReturnSubmitted = false -- 540
	self.returnCompleteSubmitted = false -- 541
	self.liveReflectDoneInMuseumRoom = false -- 542
	self.simInput = nil -- 543
	local phase = view.archive.museumPhase -- 545
	self.prevPhase = phase -- 546
	self.lastVisualMode = view.visualMode -- 547
	local pRec = asRecord(p) -- 551
	local backendWellX = readNum(pRec, "wellX") -- 552
	self.wellWorldX = backendWellX ~= nil and p.ox + backendWellX or p.ox + ____exports.WELL_WORLD_X -- 553
	self.hallMoving = false -- 554
	if view.archive.childCleared and view.archive.soldierCleared and view.archive.artifactOwned then -- 554
		if self.artifactGrantCount < 1 then -- 554
			self.artifactGrantCount = 1 -- 559
		end -- 559
	elseif not view.archive.artifactOwned then -- 559
		self.artifactGrantCount = 0 -- 562
	end -- 562
	if isActiveMuseumPhase(phase) then -- 562
		local ____view_isRehearsal_7 -- 567
		if view.isRehearsal then -- 567
			____view_isRehearsal_7 = nil -- 567
		else -- 567
			____view_isRehearsal_7 = asRecord(p.run) -- 567
		end -- 567
		local runRec = ____view_isRehearsal_7 -- 567
		local ____asRecord_9 = asRecord -- 568
		local ____temp_8 -- 568
		if pRec ~= nil then -- 568
			____temp_8 = pRec.archive -- 568
		else -- 568
			____temp_8 = nil -- 568
		end -- 568
		local ____asRecord_9_result_12 = ____asRecord_9(____temp_8) -- 568
		if ____asRecord_9_result_12 == nil then -- 568
			local ____asRecord_11 = asRecord -- 569
			local ____temp_10 -- 569
			if runRec ~= nil then -- 569
				____temp_10 = runRec.archive -- 569
			else -- 569
				____temp_10 = nil -- 569
			end -- 569
			____asRecord_9_result_12 = ____asRecord_11(____temp_10) -- 568
		end -- 568
		local archRec = ____asRecord_9_result_12 -- 568
		local backendWalkX = readNum(archRec, "museumWalkX") or readNum(pRec, "museumWalkX") -- 570
		local ____readBool_result_13 = readBool(archRec, "museumHolstered") -- 571
		if ____readBool_result_13 == nil then -- 571
			____readBool_result_13 = readBool(pRec, "museumHolstered") -- 571
		end -- 571
		local backendHolstered = ____readBool_result_13 -- 571
		local ____readBool_result_14 = readBool(archRec, "museumChildEchoPlayed") -- 572
		if ____readBool_result_14 == nil then -- 572
			____readBool_result_14 = readBool(pRec, "museumChildEchoPlayed") -- 572
		end -- 572
		local backendChildEcho = ____readBool_result_14 -- 572
		if self.savedResume ~= nil and self.savedResume.phase == phase then -- 572
			self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.savedResume.hallWalkX -- 575
			self.hallCamX = self.hallWalkX -- 576
			self.hallFacing = self.savedResume.hallFacing -- 577
			local ____backendHolstered_15 = backendHolstered -- 578
			if ____backendHolstered_15 == nil then -- 578
				____backendHolstered_15 = self.savedResume.holstered -- 578
			end -- 578
			self.holstered = ____backendHolstered_15 -- 578
			local ____backendChildEcho_16 = backendChildEcho -- 579
			if ____backendChildEcho_16 == nil then -- 579
				____backendChildEcho_16 = self.savedResume.childEchoPlayed -- 579
			end -- 579
			self.childEchoPlayed = ____backendChildEcho_16 -- 579
			self.reflectElapsed = self.savedResume.reflectElapsed -- 580
			self.lampElapsed = self.savedResume.lampElapsed -- 581
			self.returnElapsed = self.savedResume.returnElapsed -- 582
		else -- 582
			self:resetPhaseTimersForEntry(phase, backendWalkX, backendHolstered, backendChildEcho) -- 584
		end -- 584
		self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 586
		self.lastResumePhase = phase -- 587
		self.lastResumeWalkX = self.hallWalkX -- 588
	else -- 588
		self.reflectElapsed = 0 -- 591
		self.lampElapsed = 0 -- 592
		self.returnElapsed = 0 -- 593
		self.hallIntroElapsed = 0 -- 594
		self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 595
		self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 596
		self.hallFacing = 1 -- 597
		self.holstered = false -- 598
		self.childEchoCountdown = -1 -- 599
		self.childEchoPlayed = false -- 600
		self.lineDawnShown = false -- 601
		self.knock1Played = false -- 602
		self.knock2Played = false -- 603
		if phase == "locked" or phase == "well_open" then -- 603
			self.savedResume = nil -- 605
		end -- 605
	end -- 605
end -- 523
function WellMuseumPlugin.prototype.resetPhaseTimersForEntry(self, phase, backendWalkX, backendHolstered, backendChildEcho) -- 610
	if phase == "well_reflect" then -- 610
		self.reflectElapsed = 0 -- 617
		self.enterHallSubmitted = false -- 618
		return -- 619
	end -- 619
	if phase == "hall_walk" then -- 619
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or ____exports.MUSEUM_ENTRY_X -- 622
		self.hallCamX = self.hallWalkX -- 623
		self.hallFacing = 1 -- 624
		self.hallIntroElapsed = backendWalkX ~= nil and backendWalkX > 260 and 5 or 0 -- 625
		local ____backendHolstered_17 = backendHolstered -- 626
		if ____backendHolstered_17 == nil then -- 626
			____backendHolstered_17 = self.hallWalkX >= self.caseX - 85 -- 626
		end -- 626
		self.holstered = ____backendHolstered_17 -- 626
		local ____backendChildEcho_18 = backendChildEcho -- 627
		if ____backendChildEcho_18 == nil then -- 627
			____backendChildEcho_18 = self.hallWalkX >= self.caseX + 120 -- 627
		end -- 627
		self.childEchoPlayed = ____backendChildEcho_18 -- 627
		self.childEchoCountdown = -1 -- 628
		return -- 629
	end -- 629
	if phase == "lamp_turn" then -- 629
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.lampX - 36 -- 632
		self.hallCamX = self.hallWalkX -- 633
		self.hallFacing = 1 -- 634
		self.holstered = true -- 635
		self.childEchoPlayed = true -- 636
		self.lampElapsed = 0 -- 637
		self.lineDawnShown = false -- 638
		self.knock1Played = false -- 639
		self.beginReturnSubmitted = false -- 640
		return -- 641
	end -- 641
	if phase == "return_cabinet" then -- 641
		self.returnElapsed = 0 -- 644
		self.knock2Played = false -- 645
		self.returnCompleteSubmitted = false -- 646
	end -- 646
end -- 610
function WellMuseumPlugin.prototype.evaluateGate(self, p, view) -- 650
	if p.run.trial ~= nil then -- 650
		return {open = false, reason = "trial_mode"} -- 652
	end -- 652
	if p.room.key ~= "prologue" then -- 652
		return {open = false, reason = "not_prologue"} -- 655
	end -- 655
	if p.phase ~= "prologue-wait" and p.phase ~= "prologue-well" then -- 655
		return {open = false, reason = "after_cabinet_window"} -- 658
	end -- 658
	if isPrologueIntroBlocking() then -- 658
		return {open = false, reason = "prologue_intro_active"} -- 661
	end -- 661
	if not view.archive.childCleared or not view.archive.soldierCleared then -- 661
		return {open = false, reason = "requires_both_clear"} -- 665
	end -- 665
	if view.archive.museumPhase == "locked" then -- 665
		return {open = false, reason = "phase_locked"} -- 668
	end -- 668
	return {open = true, reason = "ok"} -- 670
end -- 650
function WellMuseumPlugin.prototype.submitMuseumIntent(self, p, target) -- 673
	local contract = resolveRuntimeContract(self.injectedContract) -- 674
	if contract == nil then -- 674
		return false -- 676
	end -- 676
	local intent = {kind = "museumInteract", target = target} -- 678
	return contract:submitIntent(p, intent) -- 679
end -- 673
function WellMuseumPlugin.prototype.syncLoops(self, ctx, wantWellDrip, dripVolume, wantHallAmbience) -- 682
	if wantWellDrip then -- 682
		ctx.audio:playLoop( -- 684
			LOOP_WELL_DRIP, -- 684
			"water", -- 684
			____exports.MUSEUM_AUDIO.wellDripLoop, -- 684
			dripVolume, -- 684
			ctx.p.ticks -- 684
		) -- 684
		self.wellDripPlaying = true -- 685
	elseif self.wellDripPlaying then -- 685
		ctx.audio:stopLoop(LOOP_WELL_DRIP) -- 687
		self.wellDripPlaying = false -- 688
	end -- 688
	if wantHallAmbience then -- 688
		ctx.audio:playLoop( -- 692
			LOOP_HALL_AMBIENCE, -- 692
			"ambience", -- 692
			____exports.MUSEUM_AUDIO.hallAmbienceLoop, -- 692
			0.34, -- 692
			ctx.p.ticks -- 692
		) -- 692
		self.hallAmbiencePlaying = true -- 693
	elseif self.hallAmbiencePlaying then -- 693
		ctx.audio:stopLoop(LOOP_HALL_AMBIENCE) -- 695
		self.hallAmbiencePlaying = false -- 696
	end -- 696
end -- 682
function WellMuseumPlugin.prototype.update(self, ctx) -- 700
	self:syncRuntimeHook() -- 701
	local p = ctx.p -- 702
	local view = ctx.view -- 703
	local phase = view.archive.museumPhase -- 704
	if view.isRehearsal ~= self.rehearsal then -- 704
		self:syncLoops(ctx, false, 0, false) -- 706
		self:onBindPlay(p, view) -- 707
	end -- 707
	self.roomSessionId = ctx.events.roomSessionId -- 709
	self.lastVisualMode = view.visualMode -- 710
	self.lastPaused = ctx.paused -- 711
	self.wellAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 714
	self.wellAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 715
	self.glassAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 716
	self.glassAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 717
	local sim = self.simInput -- 720
	self.simInput = nil -- 721
	local interactPressed = ctx.input.interact.pressed or sim ~= nil and sim.interact == true -- 722
	local moveX = sim ~= nil and sim.moveX ~= nil and sim.moveX or ctx.input.moveX -- 723
	if phase ~= self.prevPhase then -- 723
		local wasActive = isActiveMuseumPhase(self.prevPhase) -- 727
		self.prevPhase = phase -- 728
		if isActiveMuseumPhase(phase) then -- 728
			if phase == "well_reflect" then -- 728
				self:resetPhaseTimersForEntry("well_reflect") -- 731
				if view.archive.artifactOwned and self.artifactGrantCount < 1 then -- 731
					self.artifactGrantCount = 1 -- 733
				end -- 733
			elseif phase == "hall_walk" and not wasActive then -- 733
				self:resetPhaseTimersForEntry("hall_walk") -- 736
			elseif phase == "hall_walk" and wasActive then -- 736
				self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 738
				self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 739
				self.hallFacing = 1 -- 740
				self.hallIntroElapsed = 0 -- 741
				self.holstered = false -- 742
				self.childEchoPlayed = false -- 743
				self.childEchoCountdown = -1 -- 744
			elseif phase == "lamp_turn" then -- 744
				self:resetPhaseTimersForEntry("lamp_turn", self.hallWalkX, true, self.childEchoPlayed) -- 746
			elseif phase == "return_cabinet" then -- 746
				self:resetPhaseTimersForEntry("return_cabinet") -- 748
			end -- 748
		elseif phase == "done" then -- 748
			self.savedResume = nil -- 751
		end -- 751
	end -- 751
	local gate = self:evaluateGate(p, view) -- 755
	self.gateOpen = gate.open -- 756
	self.gateBlockedReason = gate.reason -- 757
	self.nearWell = gate.open and math.abs(p.player.x - self.wellWorldX) <= ____exports.WELL_INTERACT_REACH -- 758
	if ctx.paused then -- 758
		return -- 762
	end -- 762
	local wdt = math.max(0, ctx.worldDt) -- 765
	local udt = math.max(0, ctx.uiDt) -- 766
	self.animTime = self.animTime + wdt -- 767
	if self.revisitCalmTimer > 0 then -- 767
		self.revisitCalmTimer = math.max(0, self.revisitCalmTimer - wdt) -- 770
	end -- 770
	if self.childEchoVisualT > 0 then -- 770
		self.childEchoVisualT = math.max(0, self.childEchoVisualT - udt) -- 773
	end -- 773
	if self.knock1VisualT > 0 then -- 773
		self.knock1VisualT = math.max(0, self.knock1VisualT - wdt) -- 776
	end -- 776
	if self.knock2VisualT > 0 then -- 776
		self.knock2VisualT = math.max(0, self.knock2VisualT - wdt) -- 779
	end -- 779
	if view.visualMode ~= "museum" then -- 779
		local wantDrip = gate.open and phase == "well_open" and not view.archive.museumSeen -- 784
		local dist = math.abs(p.player.x - self.wellWorldX) -- 785
		local dripVol = clamp(0.46 - dist * 0.0014, 0.08, 0.46) -- 786
		self:syncLoops(ctx, wantDrip, dripVol, false) -- 787
		if gate.open and self.nearWell and interactPressed then -- 787
			local alreadyAwarded = view.archive.museumSeen or phase == "done" or view.archive.artifactOwned and self.artifactGrantCount >= 1 -- 790
			if phase == "well_open" and not alreadyAwarded then -- 790
				self:submitMuseumIntent(p, "well_pickup") -- 794
			else -- 794
				self.revisitCalmTimer = 1.4 -- 797
				self.revisitCalmCount = self.revisitCalmCount + 1 -- 798
			end -- 798
		end -- 798
		return -- 801
	end -- 801
	local effectivePhase = p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 805
	if effectivePhase == "well_reflect" then -- 805
		local dripVol = clamp( -- 810
			0.44 * (1 - smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, self.reflectElapsed)), -- 810
			0, -- 810
			0.44 -- 810
		) -- 810
		self:syncLoops(ctx, dripVol > 0.03, dripVol, false) -- 811
		if wdt > 0 then -- 811
			self.reflectElapsed = self.reflectElapsed + wdt -- 814
		end -- 814
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 814
			if self.artifactGrantCount < 1 then -- 814
				self.artifactGrantCount = 1 -- 818
			end -- 818
			ctx.audio:playOnce( -- 820
				"fe06:e01:pickup:" .. tostring(self.roomSessionId), -- 821
				"sfx", -- 822
				____exports.MUSEUM_AUDIO.artifactPickup, -- 823
				0.86, -- 824
				"museum:e01:artifact_pickup", -- 825
				p.ticks -- 826
			) -- 826
		end -- 826
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellMatchCutStart then -- 826
			ctx.audio:playOnce( -- 830
				"fe06:e01:matchcut:" .. tostring(self.roomSessionId), -- 831
				"ambience", -- 832
				____exports.MUSEUM_AUDIO.matchCutTransition, -- 833
				0.78, -- 834
				"museum:e01:match_cut", -- 835
				p.ticks -- 836
			) -- 836
		end -- 836
		self.savedResume = self:exportResumeState() -- 839
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellReflectDuration and not self.enterHallSubmitted then -- 839
			self.enterHallSubmitted = true -- 841
			if p.room.key == "museum" then -- 841
				self.liveReflectDoneInMuseumRoom = true -- 843
			end -- 843
			self:submitMuseumIntent(p, "enter_hall") -- 845
			local contract = resolveRuntimeContract(self.injectedContract) -- 846
			if contract ~= nil and contract:isRehearsal() then -- 846
				contract:enterMockMuseum("hall_walk") -- 848
			end -- 848
		end -- 848
		return -- 851
	end -- 851
	if effectivePhase == "hall_walk" then -- 851
		self:syncLoops(ctx, false, 0, true) -- 856
		self.hallIntroElapsed = self.hallIntroElapsed + udt -- 857
		local ____view_isRehearsal_19 -- 861
		if view.isRehearsal then -- 861
			____view_isRehearsal_19 = nil -- 861
		else -- 861
			____view_isRehearsal_19 = asRecord(p) -- 861
		end -- 861
		local pRec = ____view_isRehearsal_19 -- 861
		local backendWalkX = readNum(pRec, "museumWalkX") or (not view.isRehearsal and p.room.key == "museum" and p.player.x - p.ox or nil) -- 862
		self.hallMoving = false -- 864
		local previousX = self.hallWalkX -- 865
		if backendWalkX ~= nil then -- 865
			self.hallWalkX = clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 867
		elseif udt > 0 and math.abs(moveX) > 0.05 then -- 867
			self.hallWalkX = clamp(self.hallWalkX + moveX * ____exports.MUSEUM_WALK_SPEED * udt, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 869
		end -- 869
		local delta = self.hallWalkX - previousX -- 871
		if math.abs(delta) > 0.01 then -- 871
			self.hallFacing = delta >= 0 and 1 or -1 -- 873
			self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 874
			self.hallMoving = true -- 875
			self.hallFootstepTimer = self.hallFootstepTimer + udt -- 876
			if self.hallFootstepTimer >= 0.46 then -- 876
				self.hallFootstepTimer = 0 -- 878
				ctx.audio:playOnce( -- 879
					(("fe06:e02:step:" .. tostring(self.roomSessionId)) .. ":") .. tostring(math.floor(self.hallWalkAnim * 2)), -- 880
					"sfx", -- 881
					____exports.MUSEUM_AUDIO.hallFootstep, -- 882
					0.46, -- 883
					"museum:e02:footstep", -- 884
					p.ticks -- 885
				) -- 885
			end -- 885
		else -- 885
			self.hallFootstepTimer = math.min(self.hallFootstepTimer, 0.22) -- 889
		end -- 889
		local camFollow = math.min(1, udt * 5.2) -- 893
		self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * camFollow -- 894
		if not self.holstered and self.hallWalkX >= self.caseX - 85 then -- 894
			self.holstered = true -- 898
			ctx.audio:playOnce( -- 899
				"fe06:e02:holster:" .. tostring(self.roomSessionId), -- 900
				"sfx", -- 901
				____exports.MUSEUM_AUDIO.weaponHolster, -- 902
				0.76, -- 903
				"museum:e02:weapon_holster", -- 904
				p.ticks -- 905
			) -- 905
			if not self.childEchoPlayed then -- 905
				self.childEchoCountdown = ____exports.MUSEUM_TIMINGS.childEchoDelay -- 908
			end -- 908
		end -- 908
		if self.childEchoCountdown >= 0 and not self.childEchoPlayed then -- 908
			self.childEchoCountdown = self.childEchoCountdown - udt -- 913
			if self.childEchoCountdown <= 0 then -- 913
				self.childEchoCountdown = -1 -- 915
				self.childEchoPlayed = true -- 916
				self.childEchoVisualT = 2.1 -- 917
				ctx.audio:playOnce( -- 918
					"fe06:e02:child_echo:" .. tostring(self.roomSessionId), -- 919
					"sfx", -- 920
					____exports.MUSEUM_AUDIO.childStepsEcho, -- 921
					0.72, -- 922
					"museum:e02:child_steps_echo", -- 923
					p.ticks -- 924
				) -- 924
			end -- 924
		end -- 924
		local ____view_isRehearsal_20 -- 929
		if view.isRehearsal then -- 929
			____view_isRehearsal_20 = math.abs(self.hallWalkX - self.lampX) <= 72 -- 930
		else -- 930
			____view_isRehearsal_20 = p.phase == "museum-lamp" and p.player.x >= self.lampX + p.ox -- 931
		end -- 931
		self.nearLamp = ____view_isRehearsal_20 -- 929
		self.savedResume = self:exportResumeState() -- 932
		if self.nearLamp and interactPressed then -- 932
			self:submitMuseumIntent(p, "lamp_turn") -- 935
		end -- 935
		return -- 937
	end -- 937
	if effectivePhase == "lamp_turn" then -- 937
		self:syncLoops(ctx, false, 0, true) -- 942
		if wdt > 0 then -- 942
			self.lampElapsed = self.lampElapsed + wdt -- 944
		end -- 944
		if p.room.key == "museum" then -- 944
			local targetX = clamp(p.player.x - p.ox, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 948
			local delta = targetX - self.hallWalkX -- 949
			self.hallMoving = math.abs(delta) > 0.25 -- 950
			if self.hallMoving then -- 950
				self.hallFacing = delta >= 0 and 1 or -1 -- 952
				self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 953
			end -- 953
			self.hallWalkX = targetX -- 955
			self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * math.min(1, udt * 5.2) -- 956
		end -- 956
		ctx.audio:playOnce( -- 958
			"fe06:e02:lamp_turn:" .. tostring(self.roomSessionId), -- 959
			"sfx", -- 960
			____exports.MUSEUM_AUDIO.lampTurn, -- 961
			0.82, -- 962
			"museum:e02:lamp_turn", -- 963
			p.ticks -- 964
		) -- 964
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 964
			self.lineDawnShown = true -- 967
			ctx.audio:playOnce( -- 968
				"fe06:e02:line_dawn:" .. tostring(self.roomSessionId), -- 969
				"voice", -- 970
				____exports.MUSEUM_AUDIO.lineDawn, -- 971
				0.92, -- 972
				"museum:e02:line_dawn", -- 973
				p.ticks -- 974
			) -- 974
		end -- 974
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampKnock1At and not self.knock1Played then -- 974
			self.knock1Played = true -- 978
			self.knock1VisualT = 0.85 -- 979
			ctx.audio:playOnce( -- 980
				"fe06:e02:knock1:" .. tostring(self.roomSessionId), -- 981
				"sfx", -- 982
				____exports.MUSEUM_AUDIO.knockHallFirst, -- 983
				0.88, -- 984
				"museum:knock:1", -- 985
				p.ticks -- 986
			) -- 986
		end -- 986
		self.savedResume = self:exportResumeState() -- 989
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampTurnDuration and not self.beginReturnSubmitted then -- 989
			self.beginReturnSubmitted = true -- 992
			self:submitMuseumIntent(p, "begin_return_cabinet") -- 993
			local contract = resolveRuntimeContract(self.injectedContract) -- 994
			if contract ~= nil and contract:isRehearsal() then -- 994
				contract:enterMockMuseum("return_cabinet") -- 996
			end -- 996
		end -- 996
		return -- 999
	end -- 999
	if phase == "return_cabinet" then -- 999
		self:syncLoops(ctx, false, 0, false) -- 1004
		if wdt > 0 then -- 1004
			self.returnElapsed = self.returnElapsed + wdt -- 1006
		end -- 1006
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnKnock2At and not self.knock2Played then -- 1006
			self.knock2Played = true -- 1009
			self.knock2VisualT = 0.9 -- 1010
			ctx.audio:playOnce( -- 1011
				"fe06:e02:knock2:" .. tostring(self.roomSessionId), -- 1012
				"sfx", -- 1013
				____exports.MUSEUM_AUDIO.knockCabinetSecond, -- 1014
				0.92, -- 1015
				"museum:knock:2", -- 1016
				p.ticks -- 1017
			) -- 1017
		end -- 1017
		self.savedResume = self:exportResumeState() -- 1020
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnCabinetDuration and not self.returnCompleteSubmitted then -- 1020
			self.returnCompleteSubmitted = true -- 1023
			self:submitMuseumIntent(p, "return_cabinet") -- 1024
		end -- 1024
	end -- 1024
end -- 700
function WellMuseumPlugin.prototype.drawBackdrop(self, bgDraw, _bgGlow, _backdropArt, ctx) -- 1029
	if ctx.view.visualMode ~= "museum" then -- 1029
		return false -- 1036
	end -- 1036
	bgDraw:drawRect( -- 1039
		Rect(0, 0, ctx.w, ctx.h), -- 1039
		Color(11, 13, 18, 255) -- 1039
	) -- 1039
	return true -- 1040
end -- 1029
function WellMuseumPlugin.prototype.drawWorld(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1043
	return ctx.view.visualMode == "museum" -- 1049
end -- 1043
function WellMuseumPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1052
	return ctx.view.visualMode == "museum" -- 1058
end -- 1052
function WellMuseumPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 1064
	if not self.gateOpen or ctx.view.visualMode == "museum" then -- 1064
		return -- 1071
	end -- 1071
	local cam = ctx.cam -- 1073
	local wellCx = cam:sx(self.wellWorldX) -- 1074
	local groundY = cam:sy(0, 0) -- 1075
	local phase = ctx.view.archive.museumPhase -- 1076
	local activeLure = phase == "well_open" and not ctx.view.archive.museumSeen -- 1077
	local archW = cam:len(68) -- 1080
	local archH = cam:len(96) -- 1081
	local archX = wellCx - archW * 0.54 -- 1082
	fillVGradRect( -- 1083
		fgDraw, -- 1084
		archX, -- 1085
		groundY, -- 1086
		archW, -- 1087
		archH, -- 1088
		Color(12, 16, 22, 232), -- 1089
		Color(18, 24, 34, 212) -- 1090
	) -- 1090
	fgDraw:drawRect( -- 1093
		Rect(archX - 4, groundY, 6, archH), -- 1093
		Color(48, 54, 62, 240) -- 1093
	) -- 1093
	fgDraw:drawRect( -- 1094
		Rect(archX + archW - 2, groundY, 6, archH), -- 1094
		Color(48, 54, 62, 240) -- 1094
	) -- 1094
	fgDraw:drawRect( -- 1095
		Rect(archX - 6, groundY + archH - 8, archW + 12, 10), -- 1095
		Color(62, 68, 76, 245) -- 1095
	) -- 1095
	local rimW = cam:len(38) -- 1098
	local rimH = cam:len(22) -- 1099
	local rimX = wellCx - rimW * 0.5 -- 1100
	fgDraw:drawRect( -- 1101
		Rect(rimX, groundY, rimW, rimH), -- 1102
		Color(46, 52, 60, 250), -- 1103
		1.2, -- 1104
		Color(102, 110, 120, 215) -- 1105
	) -- 1105
	fgDraw:drawEllipse( -- 1108
		Vec2(wellCx, groundY + rimH), -- 1108
		rimW * 0.52, -- 1108
		cam:len(5.5), -- 1108
		Color(74, 82, 92, 250) -- 1108
	) -- 1108
	fgDraw:drawEllipse( -- 1109
		Vec2(wellCx, groundY + rimH), -- 1109
		rimW * 0.38, -- 1109
		cam:len(3.8), -- 1109
		Color(8, 12, 18, 255) -- 1109
	) -- 1109
	local dripCycle = self.animTime * 0.58 % 1 -- 1112
	local rippleR = cam:len(3 + dripCycle * 11) -- 1113
	local rippleAlpha = math.floor((1 - dripCycle) * (activeLure and 155 or 42) + 0.5) -- 1114
	if activeLure then -- 1114
		local shimmer = 0.65 + 0.35 * math.sin(self.animTime * 2.9) -- 1116
		fgDraw:drawCircle( -- 1118
			Vec2(wellCx, groundY + rimH), -- 1118
			cam:len(2.8), -- 1118
			Color( -- 1118
				236, -- 1118
				244, -- 1118
				252, -- 1118
				math.floor(215 * shimmer + 0.5) -- 1118
			) -- 1118
		) -- 1118
		drawEllipseRing( -- 1119
			fgDraw, -- 1119
			wellCx, -- 1119
			groundY + rimH, -- 1119
			rippleR, -- 1119
			rippleR * 0.36, -- 1119
			Color(0, 0, 0, 0), -- 1119
			1.1, -- 1119
			Color(210, 226, 242, rippleAlpha), -- 1119
			24 -- 1119
		) -- 1119
		fillRadialGlow( -- 1120
			fgGlow, -- 1121
			wellCx, -- 1122
			groundY + rimH + cam:len(8), -- 1123
			cam:len(30), -- 1124
			cam:len(38), -- 1125
			Color( -- 1126
				206, -- 1126
				224, -- 1126
				244, -- 1126
				math.floor(52 * shimmer + 0.5) -- 1126
			), -- 1126
			Color(148, 178, 212, 0), -- 1127
			16 -- 1128
		) -- 1128
		if dripCycle < 0.24 then -- 1128
			local dropK = dripCycle / 0.24 -- 1132
			local dropY = groundY + archH * 0.72 - dropK * (archH * 0.72 - rimH) -- 1133
			fgDraw:drawSegment( -- 1134
				Vec2(wellCx, dropY), -- 1135
				Vec2( -- 1136
					wellCx, -- 1136
					dropY + cam:len(4.5) -- 1136
				), -- 1136
				1.4, -- 1137
				Color(214, 228, 244, 185) -- 1138
			) -- 1138
		end -- 1138
	elseif self.revisitCalmTimer > 0 then -- 1138
		local calmK = 1 - clamp01(self.revisitCalmTimer / 1.4) -- 1143
		local calmR = cam:len(3 + calmK * 10) -- 1144
		drawEllipseRing( -- 1145
			fgDraw, -- 1146
			wellCx, -- 1147
			groundY + rimH, -- 1148
			calmR, -- 1149
			calmR * 0.35, -- 1150
			Color(0, 0, 0, 0), -- 1151
			1, -- 1152
			Color( -- 1153
				148, -- 1153
				160, -- 1153
				172, -- 1153
				math.floor((1 - calmK) * 120 + 0.5) -- 1153
			), -- 1153
			24 -- 1154
		) -- 1154
	end -- 1154
end -- 1064
function WellMuseumPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1164
	local view = ctx.view -- 1171
	local phase = view.archive.museumPhase -- 1172
	if view.visualMode ~= "museum" then -- 1172
		if self.gateOpen and self.nearWell and view.assistHintsEnabled and phase == "well_open" and not view.archive.museumSeen then -- 1172
			local sx = ctx.cam:sx(self.wellWorldX) / ctx.uiScale -- 1177
			local sy = (ctx.cam:sy(0, 0) + ctx.cam:len(54)) / ctx.uiScale -- 1178
			drawSilkVeil( -- 1179
				uiDraw, -- 1179
				uiArt, -- 1179
				"fe06_well_hint_veil", -- 1179
				sx, -- 1179
				sy, -- 1179
				132, -- 1179
				26, -- 1179
				PALETTE.panelBg, -- 1179
				0.82, -- 1179
				1 -- 1179
			) -- 1179
			ctx.texts:put( -- 1180
				"xs", -- 1181
				"[E] 俯身看井", -- 1182
				sx, -- 1183
				sy, -- 1184
				toColor(PALETTE.textBright), -- 1185
				0.5, -- 1186
				0.5, -- 1187
				"Center", -- 1188
				0.6, -- 1189
				0.92 -- 1190
			) -- 1190
		end -- 1190
		return false -- 1193
	end -- 1193
	local w = ctx.uiW -- 1196
	local h = ctx.uiH -- 1197
	local effectivePhase = ctx.p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 1199
	if effectivePhase == "well_reflect" then -- 1199
		self:renderE01WellReflectMatchCut( -- 1204
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
	if effectivePhase == "hall_walk" then -- 1205
		self:renderE02MuseumHall( -- 1208
			uiDraw, -- 1208
			uiInkDraw, -- 1208
			uiArt, -- 1208
			uiGlow, -- 1208
			ctx, -- 1208
			w, -- 1208
			h, -- 1208
			0, -- 1208
			false -- 1208
		) -- 1208
		return true -- 1209
	end -- 1209
	if effectivePhase == "lamp_turn" then -- 1209
		local turnProg = smoothstep(0, 1.15, self.lampElapsed) -- 1212
		self:renderE02MuseumHall( -- 1213
			uiDraw, -- 1213
			uiInkDraw, -- 1213
			uiArt, -- 1213
			uiGlow, -- 1213
			ctx, -- 1213
			w, -- 1213
			h, -- 1213
			turnProg, -- 1213
			true -- 1213
		) -- 1213
		return true -- 1214
	end -- 1214
	if effectivePhase == "return_cabinet" then -- 1214
		self:renderE02ReturnCabinet( -- 1217
			uiDraw, -- 1217
			uiInkDraw, -- 1217
			uiArt, -- 1217
			uiGlow, -- 1217
			ctx, -- 1217
			w, -- 1217
			h -- 1217
		) -- 1217
		return true -- 1218
	end -- 1218
	return false -- 1220
end -- 1164
function WellMuseumPlugin.prototype.renderE01WellReflectMatchCut(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1226
	local t = self.reflectElapsed -- 1235
	local ax = self.wellAnchorX -- 1236
	local ay = self.wellAnchorY -- 1237
	local matchK = smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, t) -- 1238
	local wellAlpha = 1 - matchK -- 1239
	fillVGradRect( -- 1242
		uiDraw, -- 1243
		0, -- 1244
		0, -- 1245
		w, -- 1246
		h, -- 1247
		Color( -- 1248
			math.floor(8 + 14 * matchK + 0.5), -- 1249
			math.floor(10 + 16 * matchK + 0.5), -- 1250
			math.floor(15 + 20 * matchK + 0.5), -- 1251
			255 -- 1252
		), -- 1252
		Color( -- 1254
			math.floor(14 + 22 * matchK + 0.5), -- 1255
			math.floor(18 + 26 * matchK + 0.5), -- 1256
			math.floor(26 + 30 * matchK + 0.5), -- 1257
			255 -- 1258
		) -- 1258
	) -- 1258
	if wellAlpha > 0.01 then -- 1258
		local wellR = math.min(w, h) * (0.31 + matchK * 0.24) -- 1264
		uiDraw:drawCircle( -- 1266
			Vec2(ax, ay), -- 1266
			wellR + 36, -- 1266
			Color( -- 1266
				30, -- 1266
				35, -- 1266
				42, -- 1266
				math.floor(240 * wellAlpha + 0.5) -- 1266
			) -- 1266
		) -- 1266
		uiDraw:drawCircle( -- 1267
			Vec2(ax, ay), -- 1267
			wellR + 14, -- 1267
			Color( -- 1267
				20, -- 1267
				24, -- 1267
				30, -- 1267
				math.floor(250 * wellAlpha + 0.5) -- 1267
			) -- 1267
		) -- 1267
		uiDraw:drawCircle( -- 1269
			Vec2(ax, ay), -- 1269
			wellR, -- 1269
			Color( -- 1269
				7, -- 1269
				11, -- 1269
				17, -- 1269
				math.floor(255 * wellAlpha + 0.5) -- 1269
			) -- 1269
		) -- 1269
		local ri = 0 -- 1272
		do -- 1272
			ri = 0 -- 1273
			while ri < 3 do -- 1273
				local cyc = (t * 0.42 + ri * 0.33) % 1 -- 1274
				local r = 20 + cyc * (wellR * 0.85) -- 1275
				local ra = math.floor((1 - cyc) * 90 * wellAlpha + 0.5) -- 1276
				drawCircleRing( -- 1277
					uiInkDraw, -- 1277
					ax, -- 1277
					ay, -- 1277
					r, -- 1277
					Color(0, 0, 0, 0), -- 1277
					1.1, -- 1277
					Color(176, 198, 222, ra), -- 1277
					32 -- 1277
				) -- 1277
				ri = ri + 1 -- 1273
			end -- 1273
		end -- 1273
		local compassSlide = smoothstep(0.15, 0.95, t) -- 1281
		local compX = ax + (1 - compassSlide) * 140 -- 1282
		local compY = ay - (1 - compassSlide) * 90 -- 1283
		local compR = 62 -- 1284
		drawCircleRing( -- 1286
			uiInkDraw, -- 1287
			compX, -- 1288
			compY, -- 1289
			compR + 8, -- 1290
			Color( -- 1291
				98, -- 1291
				78, -- 1291
				48, -- 1291
				math.floor(218 * wellAlpha + 0.5) -- 1291
			), -- 1291
			2, -- 1292
			Color( -- 1293
				186, -- 1293
				154, -- 1293
				102, -- 1293
				math.floor(235 * wellAlpha + 0.5) -- 1293
			), -- 1293
			32 -- 1294
		) -- 1294
		drawCircleRing( -- 1297
			uiInkDraw, -- 1298
			compX, -- 1299
			compY, -- 1300
			compR, -- 1301
			Color( -- 1302
				16, -- 1302
				24, -- 1302
				36, -- 1302
				math.floor(145 * wellAlpha + 0.5) -- 1302
			), -- 1302
			1.2, -- 1303
			Color( -- 1304
				218, -- 1304
				226, -- 1304
				236, -- 1304
				math.floor(180 * wellAlpha + 0.5) -- 1304
			), -- 1304
			32 -- 1305
		) -- 1305
		uiInkDraw:drawSegment( -- 1308
			Vec2(compX, compY + compR - 6), -- 1308
			Vec2(compX, compY + compR - 18), -- 1308
			1.6, -- 1308
			Color( -- 1308
				224, -- 1308
				206, -- 1308
				168, -- 1308
				math.floor(190 * wellAlpha + 0.5) -- 1308
			) -- 1308
		) -- 1308
		uiInkDraw:drawSegment( -- 1309
			Vec2(compX, compY - compR + 6), -- 1309
			Vec2(compX, compY - compR + 18), -- 1309
			1.4, -- 1309
			Color( -- 1309
				168, -- 1309
				174, -- 1309
				182, -- 1309
				math.floor(165 * wellAlpha + 0.5) -- 1309
			) -- 1309
		) -- 1309
		uiInkDraw:drawSegment( -- 1310
			Vec2(compX - compR + 6, compY), -- 1310
			Vec2(compX - compR + 18, compY), -- 1310
			1.4, -- 1310
			Color( -- 1310
				168, -- 1310
				174, -- 1310
				182, -- 1310
				math.floor(165 * wellAlpha + 0.5) -- 1310
			) -- 1310
		) -- 1310
		uiInkDraw:drawSegment( -- 1311
			Vec2(compX + compR - 6, compY), -- 1311
			Vec2(compX + compR - 18, compY), -- 1311
			1.4, -- 1311
			Color( -- 1311
				168, -- 1311
				174, -- 1311
				182, -- 1311
				math.floor(165 * wellAlpha + 0.5) -- 1311
			) -- 1311
		) -- 1311
		local needleAng = -0.35 + math.sin(t * 2.2) * 0.08 * (1 - matchK) -- 1313
		local nx = math.cos(needleAng) * 34 -- 1314
		local ny = math.sin(needleAng) * 34 -- 1315
		uiInkDraw:drawSegment( -- 1316
			Vec2(compX, compY), -- 1316
			Vec2(compX + nx, compY + ny), -- 1316
			2.2, -- 1316
			Color( -- 1316
				208, -- 1316
				92, -- 1316
				82, -- 1316
				math.floor(215 * wellAlpha + 0.5) -- 1316
			) -- 1316
		) -- 1316
		uiInkDraw:drawSegment( -- 1317
			Vec2(compX, compY), -- 1317
			Vec2(compX - nx * 0.85, compY - ny * 0.85), -- 1317
			1.8, -- 1317
			Color( -- 1317
				214, -- 1317
				222, -- 1317
				232, -- 1317
				math.floor(185 * wellAlpha + 0.5) -- 1317
			) -- 1317
		) -- 1317
		if t >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 1317
			local pickK = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellMatchCutStart, t) -- 1321
			local liftY = ay + pickK * 14 -- 1322
			drawCircleRing( -- 1323
				uiInkDraw, -- 1324
				ax, -- 1325
				liftY, -- 1326
				24 + pickK * 12, -- 1327
				Color(0, 0, 0, 0), -- 1328
				1.6, -- 1329
				Color( -- 1330
					226, -- 1330
					204, -- 1330
					152, -- 1330
					math.floor(215 * (1 - matchK * 0.65) + 0.5) -- 1330
				), -- 1330
				28 -- 1331
			) -- 1331
			local capA = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellPickupAt + 0.35, t) * (1 - matchK) -- 1334
			if capA > 0.03 then -- 1334
				drawSilkVeil( -- 1336
					uiDraw, -- 1336
					uiArt, -- 1336
					"fe06_pickup_veil", -- 1336
					w * 0.5, -- 1336
					96, -- 1336
					300, -- 1336
					34, -- 1336
					PALETTE.inkVoid, -- 1336
					0.78 * capA, -- 1336
					1 -- 1336
				) -- 1336
				ctx.texts:put( -- 1337
					"sm", -- 1338
					"拾起「时间穿梭器」", -- 1339
					w * 0.5, -- 1340
					96, -- 1341
					toColor(PALETTE.amberCore), -- 1342
					0.5, -- 1343
					0.5, -- 1344
					"Center", -- 1345
					1.4, -- 1346
					capA -- 1347
				) -- 1347
			end -- 1347
		end -- 1347
	end -- 1347
	if matchK > 0.01 then -- 1347
		local caseW = 300 -- 1355
		local caseH = 276 -- 1356
		local caseX = self.glassAnchorX - caseW * 0.5 -- 1357
		local caseY = self.glassAnchorY - caseH * 0.54 -- 1358
		uiDraw:drawRect( -- 1360
			Rect(caseX - 80, caseY - 110, caseW + 160, caseH + 220), -- 1360
			Color( -- 1360
				24, -- 1360
				29, -- 1360
				36, -- 1360
				math.floor(190 * matchK + 0.5) -- 1360
			) -- 1360
		) -- 1360
		uiDraw:drawRect( -- 1361
			Rect(caseX, caseY, caseW, caseH), -- 1362
			Color( -- 1363
				18, -- 1363
				23, -- 1363
				30, -- 1363
				math.floor(220 * matchK + 0.5) -- 1363
			), -- 1363
			1.6, -- 1364
			Color( -- 1365
				164, -- 1365
				178, -- 1365
				194, -- 1365
				math.floor(185 * matchK + 0.5) -- 1365
			) -- 1365
		) -- 1365
		fillGradQuad( -- 1368
			uiInkDraw, -- 1369
			self.glassAnchorX - 42, -- 1370
			caseY + caseH - 6, -- 1370
			Color( -- 1370
				224, -- 1370
				236, -- 1370
				248, -- 1370
				math.floor(44 * matchK + 0.5) -- 1370
			), -- 1370
			self.glassAnchorX + 24, -- 1371
			caseY + caseH - 6, -- 1371
			Color( -- 1371
				238, -- 1371
				246, -- 1371
				255, -- 1371
				math.floor(78 * matchK + 0.5) -- 1371
			), -- 1371
			self.glassAnchorX - 18, -- 1372
			caseY + 6, -- 1372
			Color( -- 1372
				224, -- 1372
				236, -- 1372
				248, -- 1372
				math.floor(24 * matchK + 0.5) -- 1372
			), -- 1372
			self.glassAnchorX - 82, -- 1373
			caseY + 6, -- 1373
			Color(224, 236, 248, 0) -- 1373
		) -- 1373
		uiArt:tryPlace( -- 1376
			"prop_compass", -- 1376
			"fe06_match_compass", -- 1376
			self.glassAnchorX, -- 1376
			caseY + 72, -- 1376
			46, -- 1376
			46, -- 1376
			{opacity = matchK * 0.85, layer = 3} -- 1376
		) -- 1376
	end -- 1376
	local flashPeak = math.sin(matchK * math.pi) -- 1383
	local coreR = 8 + flashPeak * 18 -- 1384
	uiInkDraw:drawCircle( -- 1385
		Vec2(ax, ay), -- 1385
		coreR * 0.55, -- 1385
		Color(248, 252, 255, 248) -- 1385
	) -- 1385
	fillRadialGlow( -- 1386
		uiGlow, -- 1387
		ax, -- 1388
		ay, -- 1389
		52 + flashPeak * 145, -- 1390
		46 + flashPeak * 115, -- 1391
		Color( -- 1392
			238, -- 1392
			246, -- 1392
			255, -- 1392
			math.floor(145 + flashPeak * 95 + 0.5) -- 1392
		), -- 1392
		Color(174, 204, 238, 0), -- 1393
		20 -- 1394
	) -- 1394
	if flashPeak > 0.05 then -- 1394
		local rayW = 70 + flashPeak * 260 -- 1398
		fillHGradRect( -- 1399
			uiGlow, -- 1399
			ax - rayW, -- 1399
			ay - 2, -- 1399
			rayW, -- 1399
			4, -- 1399
			Color(224, 238, 252, 0), -- 1399
			Color( -- 1399
				242, -- 1399
				248, -- 1399
				255, -- 1399
				math.floor(160 * flashPeak + 0.5) -- 1399
			) -- 1399
		) -- 1399
		fillHGradRect( -- 1400
			uiGlow, -- 1400
			ax, -- 1400
			ay - 2, -- 1400
			rayW, -- 1400
			4, -- 1400
			Color( -- 1400
				242, -- 1400
				248, -- 1400
				255, -- 1400
				math.floor(160 * flashPeak + 0.5) -- 1400
			), -- 1400
			Color(224, 238, 252, 0) -- 1400
		) -- 1400
	end -- 1400
	self:drawLetterbox( -- 1403
		uiInkDraw, -- 1403
		w, -- 1403
		h, -- 1403
		42, -- 1403
		0.92 -- 1403
	) -- 1403
end -- 1226
function WellMuseumPlugin.prototype.renderE02MuseumHall(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, lampTurnProg, inLampTurn) -- 1409
	local floorY = 148 -- 1420
	local wallTopY = h - 86 -- 1421
	local halfW = w * 0.5 -- 1422
	local camMin = math.min(____exports.MUSEUM_HALL_WIDTH * 0.5, halfW - 40) -- 1423
	local camMax = math.max(____exports.MUSEUM_HALL_WIDTH * 0.5, ____exports.MUSEUM_HALL_WIDTH - halfW + 40) -- 1424
	local camX = clamp(self.hallCamX, camMin, camMax) -- 1425
	local function toScreenX(hx) -- 1426
		return halfW + (hx - camX) -- 1426
	end -- 1426
	fillVGradRect( -- 1429
		uiDraw, -- 1429
		0, -- 1429
		floorY, -- 1429
		w, -- 1429
		h - floorY, -- 1429
		Color(26, 31, 38, 255), -- 1429
		Color(16, 20, 26, 255) -- 1429
	) -- 1429
	uiDraw:drawRect( -- 1431
		Rect(0, wallTopY, w, h - wallTopY), -- 1431
		Color(11, 14, 19, 255) -- 1431
	) -- 1431
	local px = 0 -- 1433
	do -- 1433
		px = 40 -- 1434
		while px <= ____exports.MUSEUM_HALL_WIDTH do -- 1434
			local sx = toScreenX(px) -- 1435
			if sx >= -20 and sx <= w + 20 then -- 1435
				uiDraw:drawSegment( -- 1437
					Vec2(sx, floorY), -- 1437
					Vec2(sx, wallTopY), -- 1437
					1, -- 1437
					Color(38, 45, 54, 130) -- 1437
				) -- 1437
			end -- 1437
			px = px + 140 -- 1434
		end -- 1434
	end -- 1434
	fillVGradRect( -- 1441
		uiDraw, -- 1441
		0, -- 1441
		0, -- 1441
		w, -- 1441
		floorY, -- 1441
		Color(14, 17, 22, 255), -- 1441
		Color(32, 37, 45, 255) -- 1441
	) -- 1441
	uiDraw:drawSegment( -- 1442
		Vec2(0, floorY), -- 1442
		Vec2(w, floorY), -- 1442
		2, -- 1442
		Color(76, 86, 98, 220) -- 1442
	) -- 1442
	uiDraw:drawRect( -- 1443
		Rect(0, floorY, w, 12), -- 1443
		Color(20, 24, 31, 240) -- 1443
	) -- 1443
	local plaqueX = toScreenX(180) -- 1446
	if plaqueX > -240 and plaqueX < w + 240 then -- 1446
		local pw = 290 -- 1448
		local ph = 132 -- 1449
		local py = floorY + 135 -- 1450
		uiDraw:drawRect( -- 1451
			Rect(plaqueX - pw * 0.5, py, pw, ph), -- 1452
			Color(18, 22, 28, 238), -- 1453
			1.2, -- 1454
			Color(118, 128, 140, 170) -- 1455
		) -- 1455
		fillRadialGlow( -- 1457
			uiGlow, -- 1457
			plaqueX, -- 1457
			wallTopY - 8, -- 1457
			150, -- 1457
			120, -- 1457
			Color(224, 232, 240, 42), -- 1457
			Color(180, 196, 214, 0), -- 1457
			14 -- 1457
		) -- 1457
		ctx.texts:put( -- 1458
			"sm", -- 1459
			"海防抗战纪念展厅", -- 1460
			plaqueX, -- 1461
			py + 82, -- 1462
			toColor(PALETTE.textBright), -- 1463
			0.5, -- 1464
			0.5, -- 1465
			"Center", -- 1466
			2, -- 1467
			0.88 -- 1468
		) -- 1468
		ctx.texts:put( -- 1470
			"xs", -- 1471
			"温州宁村 · 守望史迹陈列", -- 1472
			plaqueX, -- 1473
			py + 46, -- 1474
			toColor(PALETTE.textDim), -- 1475
			0.5, -- 1476
			0.5, -- 1477
			"Center", -- 1478
			1, -- 1479
			0.78 -- 1480
		) -- 1480
	end -- 1480
	local caseSx = toScreenX(self.caseX) -- 1485
	if caseSx > -260 and caseSx < w + 260 then -- 1485
		local boardOffsets = {-210, 210} -- 1488
		local bi = 0 -- 1489
		do -- 1489
			bi = 0 -- 1490
			while bi < #boardOffsets do -- 1490
				local bx = caseSx + boardOffsets[bi + 1] -- 1491
				uiDraw:drawRect( -- 1492
					Rect(bx - 56, floorY + 112, 112, 154), -- 1492
					Color(20, 24, 30, 235), -- 1492
					1, -- 1492
					Color(88, 98, 110, 155) -- 1492
				) -- 1492
				uiDraw:drawRect( -- 1493
					Rect(bx - 42, floorY + 168, 84, 78), -- 1493
					Color(34, 40, 48, 220) -- 1493
				) -- 1493
				uiDraw:drawSegment( -- 1494
					Vec2(bx - 36, floorY + 146), -- 1494
					Vec2(bx + 36, floorY + 146), -- 1494
					1.6, -- 1494
					Color(138, 146, 156, 140) -- 1494
				) -- 1494
				uiDraw:drawSegment( -- 1495
					Vec2(bx - 28, floorY + 132), -- 1495
					Vec2(bx + 24, floorY + 132), -- 1495
					1.2, -- 1495
					Color(108, 116, 126, 115) -- 1495
				) -- 1495
				bi = bi + 1 -- 1490
			end -- 1490
		end -- 1490
		local pedW = 148 -- 1499
		local pedH = 92 -- 1500
		local glassH = 128 -- 1501
		uiDraw:drawRect( -- 1503
			Rect(caseSx - pedW * 0.5, floorY, pedW, pedH), -- 1504
			Color(22, 26, 33, 252), -- 1505
			1.2, -- 1506
			Color(96, 106, 118, 185) -- 1507
		) -- 1507
		uiDraw:drawRect( -- 1510
			Rect(caseSx - pedW * 0.46, floorY + pedH, pedW * 0.92, glassH), -- 1511
			Color(16, 22, 30, 165), -- 1512
			1.4, -- 1513
			Color(180, 196, 214, 195) -- 1514
		) -- 1514
		uiArt:tryPlace( -- 1517
			"prop_compass", -- 1517
			"fe06_hall_compass", -- 1517
			caseSx, -- 1517
			floorY + pedH + 34, -- 1517
			34, -- 1517
			34, -- 1517
			{opacity = 0.94, layer = 3} -- 1517
		) -- 1517
		uiDraw:drawRect( -- 1521
			Rect(caseSx - 30, floorY + pedH + 6, 60, 12), -- 1521
			Color(214, 212, 204, 190) -- 1521
		) -- 1521
		fillGradQuad( -- 1523
			uiInkDraw, -- 1524
			caseSx - 28, -- 1525
			floorY + pedH + glassH - 4, -- 1525
			Color(230, 240, 252, 42), -- 1525
			caseSx + 12, -- 1526
			floorY + pedH + glassH - 4, -- 1526
			Color(242, 248, 255, 72), -- 1526
			caseSx - 12, -- 1527
			floorY + pedH + 4, -- 1527
			Color(230, 240, 252, 18), -- 1527
			caseSx - 48, -- 1528
			floorY + pedH + 4, -- 1528
			Color(230, 240, 252, 0) -- 1528
		) -- 1528
		fillRadialGlow( -- 1530
			uiGlow, -- 1530
			caseSx, -- 1530
			floorY + pedH + glassH - 12, -- 1530
			86, -- 1530
			128, -- 1530
			Color(224, 236, 250, 56), -- 1530
			Color(168, 192, 220, 0), -- 1530
			16 -- 1530
		) -- 1530
		fillVGradRect( -- 1532
			uiDraw, -- 1532
			caseSx - pedW * 0.45, -- 1532
			floorY - 36, -- 1532
			pedW * 0.9, -- 1532
			36, -- 1532
			Color(168, 186, 206, 0), -- 1532
			Color(168, 186, 206, 28) -- 1532
		) -- 1532
	end -- 1532
	local lampSx = toScreenX(self.lampX) -- 1536
	local winSx = toScreenX(self.lampX + 108) -- 1537
	local reflectK = inLampTurn and smoothstep(____exports.MUSEUM_TIMINGS.lampReflectStart, 2.35, self.lampElapsed) or 0 -- 1538
	if winSx > -260 and winSx < w + 260 then -- 1538
		local winW = 204 -- 1543
		local winH = 312 -- 1544
		local winX = winSx - winW * 0.5 -- 1545
		local winY = floorY + 38 -- 1546
		fillVGradRect( -- 1548
			uiDraw, -- 1549
			winX, -- 1550
			winY, -- 1551
			winW, -- 1552
			winH, -- 1553
			Color( -- 1554
				math.floor(54 + 46 * reflectK + 0.5), -- 1555
				math.floor(68 + 42 * reflectK + 0.5), -- 1556
				math.floor(92 + 24 * reflectK + 0.5), -- 1557
				255 -- 1558
			), -- 1558
			Color( -- 1560
				math.floor(30 + 28 * reflectK + 0.5), -- 1561
				math.floor(44 + 34 * reflectK + 0.5), -- 1562
				math.floor(70 + 30 * reflectK + 0.5), -- 1563
				255 -- 1564
			) -- 1564
		) -- 1564
		if reflectK > 0.02 then -- 1564
			uiArt:tryPlace( -- 1570
				"bgFar_prologue", -- 1570
				"fe06_window_courtyard", -- 1570
				winSx, -- 1570
				winY + 26, -- 1570
				winW - 8, -- 1570
				winH - 52, -- 1570
				{ -- 1570
					opacity = reflectK * 0.48, -- 1571
					color = Color(238, 218, 186, 255), -- 1572
					layer = 1 -- 1573
				} -- 1573
			) -- 1573
			local cy = winY + 34 -- 1576
			local silA = math.floor(188 * reflectK + 0.5) -- 1577
			uiInkDraw:drawRect( -- 1578
				Rect(winX + 12, cy, 42, 118), -- 1578
				Color(24, 28, 36, silA) -- 1578
			) -- 1578
			uiInkDraw:drawRect( -- 1579
				Rect(winX + winW - 56, cy, 44, 134), -- 1579
				Color(24, 28, 36, silA) -- 1579
			) -- 1579
			uiInkDraw:drawRect( -- 1581
				Rect(winSx - 24, cy + 4, 48, 28), -- 1581
				Color( -- 1581
					46, -- 1581
					44, -- 1581
					42, -- 1581
					math.floor(215 * reflectK + 0.5) -- 1581
				), -- 1581
				1, -- 1581
				Color( -- 1581
					214, -- 1581
					186, -- 1581
					138, -- 1581
					math.floor(170 * reflectK + 0.5) -- 1581
				) -- 1581
			) -- 1581
			uiInkDraw:drawEllipse( -- 1582
				Vec2(winSx, cy + 32), -- 1582
				26, -- 1582
				7, -- 1582
				Color( -- 1582
					218, -- 1582
					194, -- 1582
					148, -- 1582
					math.floor(175 * reflectK + 0.5) -- 1582
				) -- 1582
			) -- 1582
			fillRadialGlow( -- 1584
				uiGlow, -- 1584
				winSx, -- 1584
				winY + winH * 0.48, -- 1584
				116, -- 1584
				128, -- 1584
				Color( -- 1584
					246, -- 1584
					218, -- 1584
					168, -- 1584
					math.floor(92 * reflectK + 0.5) -- 1584
				), -- 1584
				Color(214, 174, 112, 0), -- 1584
				18 -- 1584
			) -- 1584
		end -- 1584
		uiInkDraw:drawRect( -- 1588
			Rect(winX, winY, winW, winH), -- 1588
			Color(0, 0, 0, 0), -- 1588
			3, -- 1588
			Color(68, 76, 88, 245) -- 1588
		) -- 1588
		uiInkDraw:drawSegment( -- 1589
			Vec2(winSx, winY), -- 1589
			Vec2(winSx, winY + winH), -- 1589
			2, -- 1589
			Color(68, 76, 88, 235) -- 1589
		) -- 1589
		uiInkDraw:drawSegment( -- 1590
			Vec2(winX, winY + winH * 0.56), -- 1590
			Vec2(winX + winW, winY + winH * 0.56), -- 1590
			2, -- 1590
			Color(68, 76, 88, 235) -- 1590
		) -- 1590
		local standW = 34 -- 1593
		local standH = 96 -- 1594
		uiDraw:drawRect( -- 1595
			Rect(lampSx - standW * 0.5, floorY, standW, standH), -- 1595
			Color(34, 39, 48, 250), -- 1595
			1.1, -- 1595
			Color(108, 118, 130, 190) -- 1595
		) -- 1595
		local pivotY = floorY + standH + 44 -- 1597
		uiInkDraw:drawSegment( -- 1598
			Vec2(lampSx, floorY + standH), -- 1598
			Vec2(lampSx, pivotY), -- 1598
			3.2, -- 1598
			Color(136, 144, 154, 240) -- 1598
		) -- 1598
		uiInkDraw:drawCircle( -- 1599
			Vec2(lampSx, pivotY), -- 1599
			5.5, -- 1599
			Color(196, 178, 142, 245) -- 1599
		) -- 1599
		local aimDir = -0.65 + lampTurnProg * 1.48 -- 1601
		local headX = lampSx + math.sin(aimDir) * 20 -- 1602
		local headY = pivotY + math.cos(aimDir) * 14 -- 1603
		uiInkDraw:drawSegment( -- 1604
			Vec2(lampSx, pivotY), -- 1604
			Vec2(headX, headY), -- 1604
			6.2, -- 1604
			Color(188, 166, 126, 245) -- 1604
		) -- 1604
		uiInkDraw:drawCircle( -- 1605
			Vec2(headX, headY), -- 1605
			5.2, -- 1605
			Color(248, 234, 198, 248) -- 1605
		) -- 1605
		local beamLen = 132 + lampTurnProg * 76 -- 1608
		local bxEnd = headX + math.sin(aimDir) * beamLen -- 1609
		local byEnd = headY + math.cos(aimDir) * 28 -- 1610
		local perpX = -math.cos(aimDir) * 18 -- 1611
		local perpY = math.sin(aimDir) * 34 -- 1612
		fillGradQuad( -- 1613
			uiGlow, -- 1614
			headX, -- 1615
			headY - 4, -- 1615
			Color( -- 1615
				246, -- 1615
				224, -- 1615
				178, -- 1615
				math.floor(68 + 44 * lampTurnProg + 0.5) -- 1615
			), -- 1615
			headX, -- 1616
			headY + 4, -- 1616
			Color( -- 1616
				246, -- 1616
				224, -- 1616
				178, -- 1616
				math.floor(68 + 44 * lampTurnProg + 0.5) -- 1616
			), -- 1616
			bxEnd + perpX, -- 1617
			byEnd + perpY + 34, -- 1617
			Color(238, 206, 148, 0), -- 1617
			bxEnd - perpX, -- 1618
			byEnd - perpY - 22, -- 1618
			Color(238, 206, 148, 0) -- 1618
		) -- 1618
		fillRadialGlow( -- 1620
			uiGlow, -- 1620
			headX, -- 1620
			headY, -- 1620
			34, -- 1620
			34, -- 1620
			Color(246, 228, 186, 78), -- 1620
			Color(224, 194, 140, 0), -- 1620
			14 -- 1620
		) -- 1620
	end -- 1620
	local playerSx = toScreenX(self.hallWalkX) -- 1624
	local moving = not inLampTurn and (self.hallMoving or math.abs(ctx.input.moveX) > 0.05) -- 1625
	local slot = moving and "soldier_run" or "soldier_idle" -- 1626
	local frame = moving and math.floor(self.hallWalkAnim) or 0 -- 1627
	local charH = math.floor(192 * math.max( -- 1628
		0.75, -- 1628
		math.min(1.25, h / 720) -- 1628
	) + 0.5) -- 1628
	local charW = math.floor(charH * 0.45 + 0.5) -- 1629
	uiDraw:drawEllipse( -- 1631
		Vec2(playerSx, floorY + 2), -- 1631
		34, -- 1631
		6.5, -- 1631
		Color(6, 8, 12, 178) -- 1631
	) -- 1631
	uiDraw:drawEllipse( -- 1632
		Vec2(playerSx, floorY - 14), -- 1632
		24, -- 1632
		4.5, -- 1632
		Color(16, 20, 28, 62) -- 1632
	) -- 1632
	if not uiArt:tryPlace( -- 1632
		slot, -- 1633
		"fe06_museum_zhoushu", -- 1633
		playerSx, -- 1633
		floorY + 2, -- 1633
		charW, -- 1633
		charH, -- 1633
		{facing = self.hallFacing, frame = frame, layer = 3} -- 1633
	) then -- 1633
		uiDraw:drawRect( -- 1639
			Rect(playerSx - 20, floorY + 2, 40, charH * 0.84), -- 1639
			toColor(CUFF_PALETTE.indigoBase) -- 1639
		) -- 1639
		uiDraw:drawCircle( -- 1640
			Vec2(playerSx, floorY + charH * 0.92), -- 1640
			16, -- 1640
			Color(66, 73, 76, 255) -- 1640
		) -- 1640
	end -- 1640
	if self.holstered and not inLampTurn and math.abs(self.hallWalkX - self.caseX) <= 130 then -- 1640
		local subA = clamp01(1 - math.abs(self.hallWalkX - self.caseX) / 145) * 0.86 -- 1645
		ctx.texts:put( -- 1646
			"xs", -- 1647
			"已收起随身器物", -- 1648
			caseSx, -- 1649
			floorY + 252, -- 1650
			toColor(PALETTE.textMid), -- 1651
			0.5, -- 1652
			0.5, -- 1653
			"Center", -- 1654
			0.9, -- 1655
			subA -- 1656
		) -- 1656
	end -- 1656
	if self.childEchoVisualT > 0 then -- 1656
		local echoK = 1 - clamp01(self.childEchoVisualT / 2.1) -- 1662
		local ex = math.min( -- 1663
			w - 110, -- 1663
			toScreenX(self.caseX + 310) -- 1663
		) -- 1663
		local ey = floorY + 32 -- 1664
		local ea = math.floor(math.sin(echoK * math.pi) * 165 + 0.5) -- 1665
		drawCircleRing( -- 1666
			uiInkDraw, -- 1666
			ex, -- 1666
			ey, -- 1666
			14 + echoK * 46, -- 1666
			Color(0, 0, 0, 0), -- 1666
			1.1, -- 1666
			Color(224, 214, 194, ea), -- 1666
			28 -- 1666
		) -- 1666
		drawCircleRing( -- 1667
			uiInkDraw, -- 1667
			ex, -- 1667
			ey, -- 1667
			8 + echoK * 28, -- 1667
			Color(0, 0, 0, 0), -- 1667
			0.9, -- 1667
			Color( -- 1667
				224, -- 1667
				214, -- 1667
				194, -- 1667
				math.floor(ea * 0.7 + 0.5) -- 1667
			), -- 1667
			24 -- 1667
		) -- 1667
		ctx.texts:put( -- 1668
			"xs", -- 1669
			"（远方传来轻快的孩童脚步声）", -- 1670
			w * 0.5, -- 1671
			84, -- 1672
			toColor(PALETTE.textMid), -- 1673
			0.5, -- 1674
			0.5, -- 1675
			"Center", -- 1676
			1, -- 1677
			math.sin(echoK * math.pi) * 0.85 -- 1678
		) -- 1678
	end -- 1678
	if not inLampTurn then -- 1678
		local fadeIn = smoothstep(0, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn, self.hallIntroElapsed) -- 1684
		local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold + ____exports.MUSEUM_TIMINGS.hallIntroFadeOut, self.hallIntroElapsed) -- 1685
		local introA = fadeIn * fadeOut -- 1690
		if introA > 0.02 then -- 1690
			drawSilkVeil( -- 1692
				uiDraw, -- 1692
				uiArt, -- 1692
				"fe06_hall_intro_veil", -- 1692
				w * 0.5, -- 1692
				h - 104, -- 1692
				480, -- 1692
				74, -- 1692
				PALETTE.inkVoid, -- 1692
				0.78 * introA, -- 1692
				1 -- 1692
			) -- 1692
			drawHairline( -- 1693
				uiInkDraw, -- 1693
				uiArt, -- 1693
				"fe06_hall_intro_line", -- 1693
				w * 0.5, -- 1693
				h - 106, -- 1693
				260, -- 1693
				PALETTE.silkLine, -- 1693
				0.45 * introA, -- 1693
				false, -- 1693
				4 -- 1693
			) -- 1693
			ctx.texts:put( -- 1694
				"md", -- 1694
				____exports.MUSEUM_HALL_TITLE, -- 1694
				w * 0.5, -- 1694
				h - 88, -- 1694
				toColor(PALETTE.textBright), -- 1694
				0.5, -- 1694
				0.5, -- 1694
				"Center", -- 1694
				1.8, -- 1694
				introA -- 1694
			) -- 1694
			ctx.texts:put( -- 1695
				"xs", -- 1695
				____exports.MUSEUM_HALL_SUBTITLE, -- 1695
				w * 0.5, -- 1695
				h - 122, -- 1695
				toColor(PALETTE.amberCore), -- 1695
				0.5, -- 1695
				0.5, -- 1695
				"Center", -- 1695
				1.2, -- 1695
				introA * 0.88 -- 1695
			) -- 1695
		end -- 1695
		if self.nearLamp and ctx.view.assistHintsEnabled then -- 1695
			drawSilkVeil( -- 1700
				uiDraw, -- 1700
				uiArt, -- 1700
				"fe06_lamp_hint_veil", -- 1700
				lampSx, -- 1700
				floorY + 158, -- 1700
				146, -- 1700
				28, -- 1700
				PALETTE.panelBg, -- 1700
				0.84, -- 1700
				1 -- 1700
			) -- 1700
			ctx.texts:put( -- 1701
				"xs", -- 1701
				"[E] 转动西窗灯", -- 1701
				lampSx, -- 1701
				floorY + 158, -- 1701
				toColor(PALETTE.textBright), -- 1701
				0.5, -- 1701
				0.5, -- 1701
				"Center", -- 1701
				0.6, -- 1701
				0.94 -- 1701
			) -- 1701
		end -- 1701
	end -- 1701
	if inLampTurn and self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1701
		local lineA = smoothstep(____exports.MUSEUM_TIMINGS.lampLineAt, ____exports.MUSEUM_TIMINGS.lampLineAt + 0.45, self.lampElapsed) * (1 - smoothstep(____exports.MUSEUM_TIMINGS.lampTurnDuration - 0.35, ____exports.MUSEUM_TIMINGS.lampTurnDuration, self.lampElapsed)) -- 1707
		if lineA > 0.02 then -- 1707
			drawSilkVeil( -- 1710
				uiDraw, -- 1710
				uiArt, -- 1710
				"fe06_dawn_line_veil", -- 1710
				w * 0.5, -- 1710
				86, -- 1710
				440, -- 1710
				50, -- 1710
				PALETTE.inkVoid, -- 1710
				0.84 * lineA, -- 1710
				1 -- 1710
			) -- 1710
			ctx.texts:put( -- 1711
				"md", -- 1712
				____exports.MUSEUM_LINE_DAWN, -- 1712
				w * 0.5, -- 1714
				86, -- 1715
				toColor(PALETTE.amberCore), -- 1716
				0.5, -- 1717
				0.5, -- 1718
				"Center", -- 1719
				1.6, -- 1720
				lineA -- 1721
			) -- 1721
		end -- 1721
	end -- 1721
	if self.knock1VisualT > 0 then -- 1721
		local k1 = 1 - clamp01(self.knock1VisualT / 0.85) -- 1727
		local k1A = math.floor((1 - k1) * 205 + 0.5) -- 1728
		drawCircleRing( -- 1729
			uiInkDraw, -- 1729
			winSx, -- 1729
			floorY + 148, -- 1729
			12 + k1 * 64, -- 1729
			Color(0, 0, 0, 0), -- 1729
			1.6, -- 1729
			Color(242, 232, 206, k1A), -- 1729
			28 -- 1729
		) -- 1729
		drawCircleRing( -- 1730
			uiInkDraw, -- 1730
			winSx, -- 1730
			floorY + 148, -- 1730
			6 + k1 * 34, -- 1730
			Color(0, 0, 0, 0), -- 1730
			1.1, -- 1730
			Color( -- 1730
				242, -- 1730
				232, -- 1730
				206, -- 1730
				math.floor(k1A * 0.72 + 0.5) -- 1730
			), -- 1730
			24 -- 1730
		) -- 1730
	end -- 1730
	self:drawLetterbox( -- 1733
		uiInkDraw, -- 1733
		w, -- 1733
		h, -- 1733
		38, -- 1733
		0.9 -- 1733
	) -- 1733
end -- 1409
function WellMuseumPlugin.prototype.renderE02ReturnCabinet(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1739
	local t = self.returnElapsed -- 1748
	local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.returnFadeOutAt, ____exports.MUSEUM_TIMINGS.returnCabinetDuration, t) -- 1749
	uiDraw:drawRect( -- 1752
		Rect(0, 0, w, h), -- 1752
		Color( -- 1752
			7, -- 1752
			9, -- 1752
			13, -- 1752
			math.floor(252 * fadeOut + 0.5) -- 1752
		) -- 1752
	) -- 1752
	if t < ____exports.MUSEUM_TIMINGS.returnKnock2At then -- 1752
		self:drawLetterbox( -- 1755
			uiInkDraw, -- 1755
			w, -- 1755
			h, -- 1755
			42, -- 1755
			0.95 * fadeOut -- 1755
		) -- 1755
		return -- 1756
	end -- 1756
	local revealK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.34, t) * fadeOut -- 1760
	local boxW = math.min(w - 140, 820) -- 1761
	local boxH = math.min(h - 190, 390) -- 1762
	local bx = (w - boxW) * 0.5 -- 1763
	local by = (h - boxH) * 0.5 + 10 -- 1764
	fillVGradRect( -- 1767
		uiDraw, -- 1768
		bx, -- 1769
		by, -- 1770
		boxW, -- 1771
		boxH, -- 1772
		Color( -- 1773
			13, -- 1773
			12, -- 1773
			16, -- 1773
			math.floor(248 * revealK + 0.5) -- 1773
		), -- 1773
		Color( -- 1774
			24, -- 1774
			24, -- 1774
			30, -- 1774
			math.floor(248 * revealK + 0.5) -- 1774
		) -- 1774
	) -- 1774
	local cabEdgeX = bx + boxW * 0.58 -- 1777
	uiDraw:drawRect( -- 1778
		Rect(cabEdgeX, by, boxW - (cabEdgeX - bx), boxH), -- 1778
		Color( -- 1778
			42, -- 1778
			31, -- 1778
			24, -- 1778
			math.floor(246 * revealK + 0.5) -- 1778
		) -- 1778
	) -- 1778
	uiDraw:drawSegment( -- 1779
		Vec2(cabEdgeX, by), -- 1779
		Vec2(cabEdgeX, by + boxH), -- 1779
		2.4, -- 1779
		Color( -- 1779
			116, -- 1779
			92, -- 1779
			68, -- 1779
			math.floor(220 * revealK + 0.5) -- 1779
		) -- 1779
	) -- 1779
	local gi = 0 -- 1781
	do -- 1781
		gi = 0 -- 1782
		while gi < 5 do -- 1782
			local gx = cabEdgeX + 26 + gi * 44 -- 1783
			if gx < bx + boxW - 10 then -- 1783
				uiDraw:drawSegment( -- 1785
					Vec2(gx, by + 12), -- 1785
					Vec2(gx, by + boxH - 12), -- 1785
					1, -- 1785
					Color( -- 1785
						28, -- 1785
						20, -- 1785
						15, -- 1785
						math.floor(140 * revealK + 0.5) -- 1785
					) -- 1785
				) -- 1785
			end -- 1785
			gi = gi + 1 -- 1782
		end -- 1782
	end -- 1782
	fillHGradRect( -- 1789
		uiGlow, -- 1790
		cabEdgeX - 58, -- 1791
		by + 24, -- 1792
		58, -- 1793
		boxH - 48, -- 1794
		Color(168, 188, 210, 0), -- 1795
		Color( -- 1796
			186, -- 1796
			206, -- 1796
			226, -- 1796
			math.floor(42 * revealK + 0.5) -- 1796
		) -- 1796
	) -- 1796
	if self.knock2VisualT > 0 then -- 1796
		local k2 = 1 - clamp01(self.knock2VisualT / 0.9) -- 1801
		local k2A = math.floor((1 - k2) * 215 * fadeOut + 0.5) -- 1802
		drawCircleRing( -- 1803
			uiInkDraw, -- 1803
			cabEdgeX + 8, -- 1803
			by + boxH * 0.5, -- 1803
			10 + k2 * 56, -- 1803
			Color(0, 0, 0, 0), -- 1803
			1.6, -- 1803
			Color(232, 220, 196, k2A), -- 1803
			28 -- 1803
		) -- 1803
	end -- 1803
	local extendK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.08, ____exports.MUSEUM_TIMINGS.returnKnock2At + 1.05, t) -- 1807
	local wristX = bx + 115 + extendK * (cabEdgeX - bx - 168) -- 1808
	local wristY = by + boxH * 0.5 -- 1809
	drawPatchedCuff(uiInkDraw, uiGlow, { -- 1810
		wristX = wristX, -- 1811
		wristY = wristY, -- 1812
		angleRad = -0.04 * (1 - extendK), -- 1813
		scale = 1.02, -- 1814
		pose = "reach", -- 1815
		opacity = revealK, -- 1816
		stitchHighlight = 0.48 + 0.22 * extendK, -- 1817
		cuffPullBack = 0.06, -- 1818
		warmth = 0.16 -- 1819
	}) -- 1819
	uiInkDraw:drawRect( -- 1823
		Rect(bx, by, boxW, boxH), -- 1823
		Color(0, 0, 0, 0), -- 1823
		1.2, -- 1823
		toColor( -- 1823
			PALETTE.silkDim, -- 1823
			math.floor(160 * revealK + 0.5) -- 1823
		) -- 1823
	) -- 1823
	local tipA = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.45, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.95, t) * fadeOut -- 1824
	if tipA > 0.03 then -- 1824
		drawSilkVeil( -- 1826
			uiDraw, -- 1826
			uiArt, -- 1826
			"fe06_return_veil", -- 1826
			w * 0.5, -- 1826
			by - 30, -- 1826
			320, -- 1826
			32, -- 1826
			PALETTE.inkVoid, -- 1826
			0.72 * tipA, -- 1826
			1 -- 1826
		) -- 1826
		ctx.texts:put( -- 1827
			"xs", -- 1828
			"两声轻敲落回柜板 · 寻回小满", -- 1829
			w * 0.5, -- 1830
			by - 30, -- 1831
			toColor(PALETTE.textMid), -- 1832
			0.5, -- 1833
			0.5, -- 1834
			"Center", -- 1835
			1.2, -- 1836
			tipA * 0.9 -- 1837
		) -- 1837
	end -- 1837
	self:drawLetterbox( -- 1841
		uiInkDraw, -- 1841
		w, -- 1841
		h, -- 1841
		42, -- 1841
		0.95 * fadeOut -- 1841
	) -- 1841
end -- 1739
function WellMuseumPlugin.prototype.drawLetterbox(self, draw, w, h, barH, opacity) -- 1844
	local a = math.floor(244 * clamp01(opacity) + 0.5) -- 1845
	if a <= 2 then -- 1845
		return -- 1847
	end -- 1847
	draw:drawRect( -- 1849
		Rect(0, 0, w, barH), -- 1849
		Color(6, 8, 12, a) -- 1849
	) -- 1849
	draw:drawRect( -- 1850
		Rect(0, h - barH, w, barH), -- 1850
		Color(6, 8, 12, a) -- 1850
	) -- 1850
end -- 1844
function ____exports.createWellMuseumPlugin(contract) -- 1854
	return __TS__New(____exports.WellMuseumPlugin, contract) -- 1855
end -- 1854
return ____exports -- 1854