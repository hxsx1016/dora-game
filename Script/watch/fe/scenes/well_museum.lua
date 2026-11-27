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
	if edge1 <= edge0 then -- 166
		return x >= edge1 and 1 or 0 -- 167
	end -- 167
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 169
	return t * t * (3 - 2 * t) -- 170
end -- 165
local function drawEllipseRing(draw, cx, cy, rx, ry, fillCol, borderWidth, borderCol, segments) -- 173
	if segments == nil then -- 182
		segments = 28 -- 182
	end -- 182
	if rx <= 0.5 or ry <= 0.5 then -- 184
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
	if segments == nil then -- 205
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
	if v ~= nil and type(v) == "table" then -- 211
		return v -- 212
	end -- 212
	return nil -- 214
end -- 210
local function readNum(rec, key) -- 217
	if rec == nil then -- 218
		return nil -- 219
	end -- 219
	local val = rec[key] -- 221
	return type(val) == "number" and val or nil -- 222
end -- 217
local function readBool(rec, key) -- 225
	if rec == nil then -- 226
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
	if injected ~= nil then -- 234
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
	if loaded == nil then -- 239
		return nil -- 240
	end -- 240
	local rawFe = loaded["watch.fe"] -- 242
	if rawFe ~= nil and type(rawFe) == "table" then -- 243
		local c = rawFe.contract -- 244
		if c ~= nil and type(c) == "table" then -- 245
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
	if loaded == nil then -- 255
		return false -- 256
	end -- 256
	local rawFe = loaded["watch.fe"] -- 258
	if rawFe == nil or type(rawFe) ~= "table" then -- 259
		return false -- 260
	end -- 260
	local prologue = rawFe.prologue -- 262
	if prologue == nil or type(prologue) ~= "table" then -- 263
		return false -- 264
	end -- 264
	local fn = prologue.getSnapshot -- 266
	if type(fn) ~= "function" then -- 267
		return false -- 268
	end -- 268
	local snap = asRecord(fn(prologue)) -- 270
	if readBool(snap, "blocksPlayerControl") == true then -- 271
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
	if loaded == nil then -- 359
		return -- 360
	end -- 360
	local rawFe = loaded["watch.fe"] -- 362
	if rawFe ~= nil and type(rawFe) == "table" then -- 363
		local watchFe = rawFe -- 364
		if watchFe.wellMuseum ~= self then -- 365
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
	if snap.phase ~= nil then -- 397
		self.prevPhase = snap.phase -- 398
		self.lastResumePhase = snap.phase -- 399
	end -- 399
	if snap.hallWalkX ~= nil then -- 401
		self.hallWalkX = clamp(snap.hallWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 402
		self.lastResumeWalkX = self.hallWalkX -- 403
	end -- 403
	if snap.hallCamX ~= nil then -- 405
		self.hallCamX = snap.hallCamX -- 406
	else -- 406
		self.hallCamX = self.hallWalkX -- 408
	end -- 408
	if snap.hallFacing ~= nil then -- 410
		self.hallFacing = snap.hallFacing >= 0 and 1 or -1 -- 411
	end -- 411
	if snap.holstered ~= nil then -- 413
		self.holstered = snap.holstered -- 414
	end -- 414
	if snap.childEchoPlayed ~= nil then -- 416
		self.childEchoPlayed = snap.childEchoPlayed -- 417
	end -- 417
	if snap.reflectElapsed ~= nil then -- 419
		self.reflectElapsed = math.max(0, snap.reflectElapsed) -- 420
	end -- 420
	if snap.lampElapsed ~= nil then -- 422
		self.lampElapsed = math.max(0, snap.lampElapsed) -- 423
	end -- 423
	if snap.returnElapsed ~= nil then -- 425
		self.returnElapsed = math.max(0, snap.returnElapsed) -- 426
	end -- 426
	if snap.artifactGrantCount ~= nil then -- 428
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
	if holstered ~= nil then -- 450
		self.holstered = holstered -- 451
	elseif self.hallWalkX >= self.caseX - 85 then -- 452
		self.holstered = true -- 453
	end -- 453
	self.savedResume = self:exportResumeState() -- 455
end -- 447
function WellMuseumPlugin.prototype.seekStageTime(self, stage, seconds) -- 459
	local s = math.max(0, seconds) -- 460
	if stage == "well_reflect" then -- 461
		self.reflectElapsed = math.min(____exports.MUSEUM_TIMINGS.wellReflectDuration, s) -- 462
	elseif stage == "lamp_turn" then -- 463
		self.lampElapsed = math.min(____exports.MUSEUM_TIMINGS.lampTurnDuration, s) -- 464
		self.lineDawnShown = self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt -- 465
	elseif stage == "return_cabinet" then -- 466
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
	if view.isRehearsal ~= self.rehearsal then -- 525
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
	if view.archive.childCleared and view.archive.soldierCleared and view.archive.artifactOwned then -- 557
		if self.artifactGrantCount < 1 then -- 558
			self.artifactGrantCount = 1 -- 559
		end -- 559
	elseif not view.archive.artifactOwned then -- 561
		self.artifactGrantCount = 0 -- 562
	end -- 562
	if isActiveMuseumPhase(phase) then -- 566
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
		if self.savedResume ~= nil and self.savedResume.phase == phase then -- 574
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
		if phase == "locked" or phase == "well_open" then -- 604
			self.savedResume = nil -- 605
		end -- 605
	end -- 605
end -- 523
function WellMuseumPlugin.prototype.resetPhaseTimersForEntry(self, phase, backendWalkX, backendHolstered, backendChildEcho) -- 610
	if phase == "well_reflect" then -- 616
		self.reflectElapsed = 0 -- 617
		self.enterHallSubmitted = false -- 618
		return -- 619
	end -- 619
	if phase == "hall_walk" then -- 621
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
	if phase == "lamp_turn" then -- 631
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
	if phase == "return_cabinet" then -- 643
		self.returnElapsed = 0 -- 644
		self.knock2Played = false -- 645
		self.returnCompleteSubmitted = false -- 646
	end -- 646
end -- 610
function WellMuseumPlugin.prototype.evaluateGate(self, p, view) -- 650
	if p.run.trial ~= nil then -- 651
		return {open = false, reason = "trial_mode"} -- 652
	end -- 652
	if p.room.key ~= "prologue" then -- 654
		return {open = false, reason = "not_prologue"} -- 655
	end -- 655
	if p.phase ~= "prologue-wait" and p.phase ~= "prologue-well" then -- 657
		return {open = false, reason = "after_cabinet_window"} -- 658
	end -- 658
	if isPrologueIntroBlocking() then -- 660
		return {open = false, reason = "prologue_intro_active"} -- 661
	end -- 661
	if not view.archive.childCleared or not view.archive.soldierCleared then -- 664
		return {open = false, reason = "requires_both_clear"} -- 665
	end -- 665
	if view.archive.museumPhase == "locked" then -- 667
		return {open = false, reason = "phase_locked"} -- 668
	end -- 668
	return {open = true, reason = "ok"} -- 670
end -- 650
function WellMuseumPlugin.prototype.submitMuseumIntent(self, p, target) -- 673
	local contract = resolveRuntimeContract(self.injectedContract) -- 674
	if contract == nil then -- 675
		return false -- 676
	end -- 676
	local intent = {kind = "museumInteract", target = target} -- 678
	return contract:submitIntent(p, intent) -- 679
end -- 673
function WellMuseumPlugin.prototype.syncLoops(self, ctx, wantWellDrip, dripVolume, wantHallAmbience) -- 682
	if wantWellDrip then -- 683
		ctx.audio:playLoop( -- 684
			LOOP_WELL_DRIP, -- 684
			"water", -- 684
			____exports.MUSEUM_AUDIO.wellDripLoop, -- 684
			dripVolume, -- 684
			ctx.p.ticks -- 684
		) -- 684
		self.wellDripPlaying = true -- 685
	elseif self.wellDripPlaying then -- 686
		ctx.audio:stopLoop(LOOP_WELL_DRIP) -- 687
		self.wellDripPlaying = false -- 688
	end -- 688
	if wantHallAmbience then -- 691
		ctx.audio:playLoop( -- 692
			LOOP_HALL_AMBIENCE, -- 692
			"ambience", -- 692
			____exports.MUSEUM_AUDIO.hallAmbienceLoop, -- 692
			0.34, -- 692
			ctx.p.ticks -- 692
		) -- 692
		self.hallAmbiencePlaying = true -- 693
	elseif self.hallAmbiencePlaying then -- 694
		ctx.audio:stopLoop(LOOP_HALL_AMBIENCE) -- 695
		self.hallAmbiencePlaying = false -- 696
	end -- 696
end -- 682
function WellMuseumPlugin.prototype.update(self, ctx) -- 700
	self:syncRuntimeHook() -- 701
	local p = ctx.p -- 702
	local view = ctx.view -- 703
	local phase = view.archive.museumPhase -- 704
	if view.isRehearsal ~= self.rehearsal then -- 705
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
	local interactPressed = ctx.input.interact.pressed or ctx.input.frameInteractPressed or sim ~= nil and sim.interact == true -- 722
	local moveX = sim ~= nil and sim.moveX ~= nil and sim.moveX or ctx.input.moveX -- 725
	if phase ~= self.prevPhase then -- 728
		local wasActive = isActiveMuseumPhase(self.prevPhase) -- 729
		self.prevPhase = phase -- 730
		if isActiveMuseumPhase(phase) then -- 731
			if phase == "well_reflect" then -- 732
				self:resetPhaseTimersForEntry("well_reflect") -- 733
				if view.archive.artifactOwned and self.artifactGrantCount < 1 then -- 734
					self.artifactGrantCount = 1 -- 735
				end -- 735
			elseif phase == "hall_walk" and not wasActive then -- 737
				self:resetPhaseTimersForEntry("hall_walk") -- 738
			elseif phase == "hall_walk" and wasActive then -- 739
				self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 740
				self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 741
				self.hallFacing = 1 -- 742
				self.hallIntroElapsed = 0 -- 743
				self.holstered = false -- 744
				self.childEchoPlayed = false -- 745
				self.childEchoCountdown = -1 -- 746
			elseif phase == "lamp_turn" then -- 747
				self:resetPhaseTimersForEntry("lamp_turn", self.hallWalkX, true, self.childEchoPlayed) -- 748
			elseif phase == "return_cabinet" then -- 749
				self:resetPhaseTimersForEntry("return_cabinet") -- 750
			end -- 750
		elseif phase == "done" then -- 752
			self.savedResume = nil -- 753
		end -- 753
	end -- 753
	local gate = self:evaluateGate(p, view) -- 757
	self.gateOpen = gate.open -- 758
	self.gateBlockedReason = gate.reason -- 759
	self.nearWell = gate.open and math.abs(p.player.x - self.wellWorldX) <= ____exports.WELL_INTERACT_REACH -- 760
	if ctx.paused then -- 763
		return -- 764
	end -- 764
	local wdt = math.max(0, ctx.worldDt) -- 767
	local udt = math.max(0, ctx.uiDt) -- 768
	self.animTime = self.animTime + wdt -- 769
	if self.revisitCalmTimer > 0 then -- 771
		self.revisitCalmTimer = math.max(0, self.revisitCalmTimer - wdt) -- 772
	end -- 772
	if self.childEchoVisualT > 0 then -- 774
		self.childEchoVisualT = math.max(0, self.childEchoVisualT - udt) -- 775
	end -- 775
	if self.knock1VisualT > 0 then -- 777
		self.knock1VisualT = math.max(0, self.knock1VisualT - wdt) -- 778
	end -- 778
	if self.knock2VisualT > 0 then -- 780
		self.knock2VisualT = math.max(0, self.knock2VisualT - wdt) -- 781
	end -- 781
	if view.visualMode ~= "museum" then -- 785
		local wantDrip = gate.open and phase == "well_open" and not view.archive.museumSeen -- 786
		local dist = math.abs(p.player.x - self.wellWorldX) -- 787
		local dripVol = clamp(0.46 - dist * 0.0014, 0.08, 0.46) -- 788
		self:syncLoops(ctx, wantDrip, dripVol, false) -- 789
		if gate.open and self.nearWell and interactPressed then -- 791
			local liveNeedsSecondEnter = not view.isRehearsal and p.room.key == "prologue" and view.archive.artifactOwned and not view.archive.museumSeen -- 792
			local alreadyAwarded = not liveNeedsSecondEnter and (view.archive.museumSeen or phase == "done" or view.archive.artifactOwned and self.artifactGrantCount >= 1) -- 796
			if (phase == "well_open" or liveNeedsSecondEnter) and not alreadyAwarded then -- 800
				self:submitMuseumIntent(p, "well_pickup") -- 801
			else -- 801
				self.revisitCalmTimer = 1.4 -- 804
				self.revisitCalmCount = self.revisitCalmCount + 1 -- 805
			end -- 805
		end -- 805
		return -- 808
	end -- 808
	local effectivePhase = p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 812
	if effectivePhase == "well_reflect" then -- 816
		local dripVol = clamp( -- 817
			0.44 * (1 - smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, self.reflectElapsed)), -- 817
			0, -- 817
			0.44 -- 817
		) -- 817
		self:syncLoops(ctx, dripVol > 0.03, dripVol, false) -- 818
		if wdt > 0 then -- 820
			self.reflectElapsed = self.reflectElapsed + wdt -- 821
		end -- 821
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 823
			if self.artifactGrantCount < 1 then -- 824
				self.artifactGrantCount = 1 -- 825
			end -- 825
			ctx.audio:playOnce( -- 827
				"fe06:e01:pickup:" .. tostring(self.roomSessionId), -- 828
				"sfx", -- 829
				____exports.MUSEUM_AUDIO.artifactPickup, -- 830
				0.86, -- 831
				"museum:e01:artifact_pickup", -- 832
				p.ticks -- 833
			) -- 833
		end -- 833
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellMatchCutStart then -- 836
			ctx.audio:playOnce( -- 837
				"fe06:e01:matchcut:" .. tostring(self.roomSessionId), -- 838
				"ambience", -- 839
				____exports.MUSEUM_AUDIO.matchCutTransition, -- 840
				0.78, -- 841
				"museum:e01:match_cut", -- 842
				p.ticks -- 843
			) -- 843
		end -- 843
		self.savedResume = self:exportResumeState() -- 846
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellReflectDuration and not self.enterHallSubmitted then -- 847
			self.enterHallSubmitted = true -- 848
			if p.room.key == "museum" then -- 849
				self.liveReflectDoneInMuseumRoom = true -- 850
			end -- 850
			self:submitMuseumIntent(p, "enter_hall") -- 852
			local contract = resolveRuntimeContract(self.injectedContract) -- 853
			if contract ~= nil and contract:isRehearsal() then -- 854
				contract:enterMockMuseum("hall_walk") -- 855
			end -- 855
		end -- 855
		return -- 858
	end -- 858
	if effectivePhase == "hall_walk" then -- 862
		self:syncLoops(ctx, false, 0, true) -- 863
		self.hallIntroElapsed = self.hallIntroElapsed + udt -- 864
		local ____view_isRehearsal_19 -- 868
		if view.isRehearsal then -- 868
			____view_isRehearsal_19 = nil -- 868
		else -- 868
			____view_isRehearsal_19 = asRecord(p) -- 868
		end -- 868
		local pRec = ____view_isRehearsal_19 -- 868
		local backendWalkX = readNum(pRec, "museumWalkX") or (not view.isRehearsal and p.room.key == "museum" and p.player.x - p.ox or nil) -- 869
		self.hallMoving = false -- 871
		local previousX = self.hallWalkX -- 872
		if backendWalkX ~= nil then -- 873
			self.hallWalkX = clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 874
		elseif udt > 0 and math.abs(moveX) > 0.05 then -- 875
			self.hallWalkX = clamp(self.hallWalkX + moveX * ____exports.MUSEUM_WALK_SPEED * udt, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 876
		end -- 876
		local delta = self.hallWalkX - previousX -- 878
		if math.abs(delta) > 0.01 then -- 879
			self.hallFacing = delta >= 0 and 1 or -1 -- 880
			self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 881
			self.hallMoving = true -- 882
			self.hallFootstepTimer = self.hallFootstepTimer + udt -- 883
			if self.hallFootstepTimer >= 0.46 then -- 884
				self.hallFootstepTimer = 0 -- 885
				ctx.audio:playOnce( -- 886
					(("fe06:e02:step:" .. tostring(self.roomSessionId)) .. ":") .. tostring(math.floor(self.hallWalkAnim * 2)), -- 887
					"sfx", -- 888
					____exports.MUSEUM_AUDIO.hallFootstep, -- 889
					0.46, -- 890
					"museum:e02:footstep", -- 891
					p.ticks -- 892
				) -- 892
			end -- 892
		else -- 892
			self.hallFootstepTimer = math.min(self.hallFootstepTimer, 0.22) -- 896
		end -- 896
		local camFollow = math.min(1, udt * 5.2) -- 900
		self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * camFollow -- 901
		local holsterThreshold = p.room.key == "museum" and self.caseX + 12 or self.caseX - 85 -- 904
		if not self.holstered and self.hallWalkX >= holsterThreshold then -- 905
			self.holstered = true -- 906
			ctx.audio:playOnce( -- 907
				"fe06:e02:holster:" .. tostring(self.roomSessionId), -- 908
				"sfx", -- 909
				____exports.MUSEUM_AUDIO.weaponHolster, -- 910
				0.76, -- 911
				"museum:e02:weapon_holster", -- 912
				p.ticks -- 913
			) -- 913
			if not self.childEchoPlayed then -- 915
				self.childEchoCountdown = ____exports.MUSEUM_TIMINGS.childEchoDelay -- 916
			end -- 916
		end -- 916
		if self.childEchoCountdown >= 0 and not self.childEchoPlayed then -- 920
			self.childEchoCountdown = self.childEchoCountdown - udt -- 921
			if self.childEchoCountdown <= 0 then -- 922
				self.childEchoCountdown = -1 -- 923
				self.childEchoPlayed = true -- 924
				self.childEchoVisualT = 2.1 -- 925
				ctx.audio:playOnce( -- 926
					"fe06:e02:child_echo:" .. tostring(self.roomSessionId), -- 927
					"sfx", -- 928
					____exports.MUSEUM_AUDIO.childStepsEcho, -- 929
					0.72, -- 930
					"museum:e02:child_steps_echo", -- 931
					p.ticks -- 932
				) -- 932
			end -- 932
		end -- 932
		local ____view_isRehearsal_20 -- 937
		if view.isRehearsal then -- 937
			____view_isRehearsal_20 = math.abs(self.hallWalkX - self.lampX) <= 72 -- 938
		else -- 938
			____view_isRehearsal_20 = (p.phase == "museum-hall" or p.phase == "museum-lamp") and math.abs(p.player.x - (self.lampX + p.ox)) <= 72 -- 939
		end -- 939
		self.nearLamp = ____view_isRehearsal_20 -- 937
		self.savedResume = self:exportResumeState() -- 941
		if self.nearLamp and interactPressed then -- 943
			self:submitMuseumIntent(p, "lamp_turn") -- 944
		end -- 944
		return -- 946
	end -- 946
	if effectivePhase == "lamp_turn" then -- 950
		self:syncLoops(ctx, false, 0, true) -- 951
		if wdt > 0 then -- 952
			self.lampElapsed = self.lampElapsed + wdt -- 953
		end -- 953
		if p.room.key == "museum" then -- 956
			local targetX = clamp(p.player.x - p.ox, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 957
			local delta = targetX - self.hallWalkX -- 958
			self.hallMoving = math.abs(delta) > 0.25 -- 959
			if self.hallMoving then -- 960
				self.hallFacing = delta >= 0 and 1 or -1 -- 961
				self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 962
			end -- 962
			self.hallWalkX = targetX -- 964
			self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * math.min(1, udt * 5.2) -- 965
		end -- 965
		ctx.audio:playOnce( -- 967
			"fe06:e02:lamp_turn:" .. tostring(self.roomSessionId), -- 968
			"sfx", -- 969
			____exports.MUSEUM_AUDIO.lampTurn, -- 970
			0.82, -- 971
			"museum:e02:lamp_turn", -- 972
			p.ticks -- 973
		) -- 973
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 975
			self.lineDawnShown = true -- 976
			ctx.audio:playOnce( -- 977
				"fe06:e02:line_dawn:" .. tostring(self.roomSessionId), -- 978
				"voice", -- 979
				____exports.MUSEUM_AUDIO.lineDawn, -- 980
				0.92, -- 981
				"museum:e02:line_dawn", -- 982
				p.ticks -- 983
			) -- 983
		end -- 983
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampKnock1At and not self.knock1Played then -- 986
			self.knock1Played = true -- 987
			self.knock1VisualT = 0.85 -- 988
			ctx.audio:playOnce( -- 989
				"fe06:e02:knock1:" .. tostring(self.roomSessionId), -- 990
				"sfx", -- 991
				____exports.MUSEUM_AUDIO.knockHallFirst, -- 992
				0.88, -- 993
				"museum:knock:1", -- 994
				p.ticks -- 995
			) -- 995
		end -- 995
		self.savedResume = self:exportResumeState() -- 998
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampTurnDuration and not self.beginReturnSubmitted then -- 1000
			self.beginReturnSubmitted = true -- 1001
			self:submitMuseumIntent(p, "begin_return_cabinet") -- 1002
			local contract = resolveRuntimeContract(self.injectedContract) -- 1003
			if contract ~= nil and contract:isRehearsal() then -- 1004
				contract:enterMockMuseum("return_cabinet") -- 1005
			end -- 1005
		end -- 1005
		return -- 1008
	end -- 1008
	if phase == "return_cabinet" then -- 1012
		self:syncLoops(ctx, false, 0, false) -- 1013
		if wdt > 0 then -- 1014
			self.returnElapsed = self.returnElapsed + wdt -- 1015
		end -- 1015
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnKnock2At and not self.knock2Played then -- 1017
			self.knock2Played = true -- 1018
			self.knock2VisualT = 0.9 -- 1019
			ctx.audio:playOnce( -- 1020
				"fe06:e02:knock2:" .. tostring(self.roomSessionId), -- 1021
				"sfx", -- 1022
				____exports.MUSEUM_AUDIO.knockCabinetSecond, -- 1023
				0.92, -- 1024
				"museum:knock:2", -- 1025
				p.ticks -- 1026
			) -- 1026
		end -- 1026
		self.savedResume = self:exportResumeState() -- 1029
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnCabinetDuration and not self.returnCompleteSubmitted then -- 1031
			self.returnCompleteSubmitted = true -- 1032
			self:submitMuseumIntent(p, "return_cabinet") -- 1033
		end -- 1033
	end -- 1033
end -- 700
function WellMuseumPlugin.prototype.drawBackdrop(self, bgDraw, _bgGlow, _backdropArt, ctx) -- 1038
	if ctx.view.visualMode ~= "museum" then -- 1044
		return false -- 1045
	end -- 1045
	bgDraw:drawRect( -- 1048
		Rect(0, 0, ctx.w, ctx.h), -- 1048
		Color(11, 13, 18, 255) -- 1048
	) -- 1048
	return true -- 1049
end -- 1038
function WellMuseumPlugin.prototype.drawWorld(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1052
	return ctx.view.visualMode == "museum" -- 1058
end -- 1052
function WellMuseumPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1061
	return ctx.view.visualMode == "museum" -- 1067
end -- 1061
function WellMuseumPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 1073
	if not self.gateOpen or ctx.view.visualMode == "museum" then -- 1079
		return -- 1080
	end -- 1080
	local cam = ctx.cam -- 1082
	local wellCx = cam:sx(self.wellWorldX) -- 1083
	local groundY = cam:sy(0, 0) -- 1084
	local phase = ctx.view.archive.museumPhase -- 1085
	local activeLure = phase == "well_open" and not ctx.view.archive.museumSeen -- 1086
	local archW = cam:len(68) -- 1089
	local archH = cam:len(96) -- 1090
	local archX = wellCx - archW * 0.54 -- 1091
	fillVGradRect( -- 1092
		fgDraw, -- 1093
		archX, -- 1094
		groundY, -- 1095
		archW, -- 1096
		archH, -- 1097
		Color(12, 16, 22, 232), -- 1098
		Color(18, 24, 34, 212) -- 1099
	) -- 1099
	fgDraw:drawRect( -- 1102
		Rect(archX - 4, groundY, 6, archH), -- 1102
		Color(48, 54, 62, 240) -- 1102
	) -- 1102
	fgDraw:drawRect( -- 1103
		Rect(archX + archW - 2, groundY, 6, archH), -- 1103
		Color(48, 54, 62, 240) -- 1103
	) -- 1103
	fgDraw:drawRect( -- 1104
		Rect(archX - 6, groundY + archH - 8, archW + 12, 10), -- 1104
		Color(62, 68, 76, 245) -- 1104
	) -- 1104
	local rimW = cam:len(38) -- 1107
	local rimH = cam:len(22) -- 1108
	local rimX = wellCx - rimW * 0.5 -- 1109
	fgDraw:drawRect( -- 1110
		Rect(rimX, groundY, rimW, rimH), -- 1111
		Color(46, 52, 60, 250), -- 1112
		1.2, -- 1113
		Color(102, 110, 120, 215) -- 1114
	) -- 1114
	fgDraw:drawEllipse( -- 1117
		Vec2(wellCx, groundY + rimH), -- 1117
		rimW * 0.52, -- 1117
		cam:len(5.5), -- 1117
		Color(74, 82, 92, 250) -- 1117
	) -- 1117
	fgDraw:drawEllipse( -- 1118
		Vec2(wellCx, groundY + rimH), -- 1118
		rimW * 0.38, -- 1118
		cam:len(3.8), -- 1118
		Color(8, 12, 18, 255) -- 1118
	) -- 1118
	local dripCycle = self.animTime * 0.58 % 1 -- 1121
	local rippleR = cam:len(3 + dripCycle * 11) -- 1122
	local rippleAlpha = math.floor((1 - dripCycle) * (activeLure and 155 or 42) + 0.5) -- 1123
	if activeLure then -- 1124
		local shimmer = 0.65 + 0.35 * math.sin(self.animTime * 2.9) -- 1125
		fgDraw:drawCircle( -- 1127
			Vec2(wellCx, groundY + rimH), -- 1127
			cam:len(2.8), -- 1127
			Color( -- 1127
				236, -- 1127
				244, -- 1127
				252, -- 1127
				math.floor(215 * shimmer + 0.5) -- 1127
			) -- 1127
		) -- 1127
		drawEllipseRing( -- 1128
			fgDraw, -- 1128
			wellCx, -- 1128
			groundY + rimH, -- 1128
			rippleR, -- 1128
			rippleR * 0.36, -- 1128
			Color(0, 0, 0, 0), -- 1128
			1.1, -- 1128
			Color(210, 226, 242, rippleAlpha), -- 1128
			24 -- 1128
		) -- 1128
		fillRadialGlow( -- 1129
			fgGlow, -- 1130
			wellCx, -- 1131
			groundY + rimH + cam:len(8), -- 1132
			cam:len(30), -- 1133
			cam:len(38), -- 1134
			Color( -- 1135
				206, -- 1135
				224, -- 1135
				244, -- 1135
				math.floor(52 * shimmer + 0.5) -- 1135
			), -- 1135
			Color(148, 178, 212, 0), -- 1136
			16 -- 1137
		) -- 1137
		if dripCycle < 0.24 then -- 1140
			local dropK = dripCycle / 0.24 -- 1141
			local dropY = groundY + archH * 0.72 - dropK * (archH * 0.72 - rimH) -- 1142
			fgDraw:drawSegment( -- 1143
				Vec2(wellCx, dropY), -- 1144
				Vec2( -- 1145
					wellCx, -- 1145
					dropY + cam:len(4.5) -- 1145
				), -- 1145
				1.4, -- 1146
				Color(214, 228, 244, 185) -- 1147
			) -- 1147
		end -- 1147
	elseif self.revisitCalmTimer > 0 then -- 1150
		local calmK = 1 - clamp01(self.revisitCalmTimer / 1.4) -- 1152
		local calmR = cam:len(3 + calmK * 10) -- 1153
		drawEllipseRing( -- 1154
			fgDraw, -- 1155
			wellCx, -- 1156
			groundY + rimH, -- 1157
			calmR, -- 1158
			calmR * 0.35, -- 1159
			Color(0, 0, 0, 0), -- 1160
			1, -- 1161
			Color( -- 1162
				148, -- 1162
				160, -- 1162
				172, -- 1162
				math.floor((1 - calmK) * 120 + 0.5) -- 1162
			), -- 1162
			24 -- 1163
		) -- 1163
	end -- 1163
end -- 1073
function WellMuseumPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1173
	local view = ctx.view -- 1180
	local phase = view.archive.museumPhase -- 1181
	if view.visualMode ~= "museum" then -- 1183
		if self.gateOpen and self.nearWell and view.assistHintsEnabled and phase == "well_open" and not view.archive.museumSeen then -- 1185
			local sx = ctx.cam:sx(self.wellWorldX) / ctx.uiScale -- 1186
			local sy = (ctx.cam:sy(0, 0) + ctx.cam:len(54)) / ctx.uiScale -- 1187
			drawSilkVeil( -- 1188
				uiDraw, -- 1188
				uiArt, -- 1188
				"fe06_well_hint_veil", -- 1188
				sx, -- 1188
				sy, -- 1188
				132, -- 1188
				26, -- 1188
				PALETTE.panelBg, -- 1188
				0.82, -- 1188
				1 -- 1188
			) -- 1188
			ctx.texts:put( -- 1189
				"xs", -- 1190
				"[E] 俯身看井", -- 1191
				sx, -- 1192
				sy, -- 1193
				toColor(PALETTE.textBright), -- 1194
				0.5, -- 1195
				0.5, -- 1196
				"Center", -- 1197
				0.6, -- 1198
				0.92 -- 1199
			) -- 1199
		end -- 1199
		return false -- 1202
	end -- 1202
	local w = ctx.uiW -- 1205
	local h = ctx.uiH -- 1206
	local effectivePhase = ctx.p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 1208
	if effectivePhase == "well_reflect" then -- 1212
		self:renderE01WellReflectMatchCut( -- 1213
			uiDraw, -- 1213
			uiInkDraw, -- 1213
			uiArt, -- 1213
			uiGlow, -- 1213
			ctx, -- 1213
			w, -- 1213
			h -- 1213
		) -- 1213
		return true -- 1214
	end -- 1214
	if effectivePhase == "hall_walk" then -- 1216
		self:renderE02MuseumHall( -- 1217
			uiDraw, -- 1217
			uiInkDraw, -- 1217
			uiArt, -- 1217
			uiGlow, -- 1217
			ctx, -- 1217
			w, -- 1217
			h, -- 1217
			0, -- 1217
			false -- 1217
		) -- 1217
		return true -- 1218
	end -- 1218
	if effectivePhase == "lamp_turn" then -- 1220
		local turnProg = smoothstep(0, 1.15, self.lampElapsed) -- 1221
		self:renderE02MuseumHall( -- 1222
			uiDraw, -- 1222
			uiInkDraw, -- 1222
			uiArt, -- 1222
			uiGlow, -- 1222
			ctx, -- 1222
			w, -- 1222
			h, -- 1222
			turnProg, -- 1222
			true -- 1222
		) -- 1222
		return true -- 1223
	end -- 1223
	if effectivePhase == "return_cabinet" then -- 1225
		self:renderE02ReturnCabinet( -- 1226
			uiDraw, -- 1226
			uiInkDraw, -- 1226
			uiArt, -- 1226
			uiGlow, -- 1226
			ctx, -- 1226
			w, -- 1226
			h -- 1226
		) -- 1226
		return true -- 1227
	end -- 1227
	return false -- 1229
end -- 1173
function WellMuseumPlugin.prototype.renderE01WellReflectMatchCut(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1235
	local t = self.reflectElapsed -- 1244
	local ax = self.wellAnchorX -- 1245
	local ay = self.wellAnchorY -- 1246
	local matchK = smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, t) -- 1247
	local wellAlpha = 1 - matchK -- 1248
	fillVGradRect( -- 1251
		uiDraw, -- 1252
		0, -- 1253
		0, -- 1254
		w, -- 1255
		h, -- 1256
		Color( -- 1257
			math.floor(8 + 14 * matchK + 0.5), -- 1258
			math.floor(10 + 16 * matchK + 0.5), -- 1259
			math.floor(15 + 20 * matchK + 0.5), -- 1260
			255 -- 1261
		), -- 1261
		Color( -- 1263
			math.floor(14 + 22 * matchK + 0.5), -- 1264
			math.floor(18 + 26 * matchK + 0.5), -- 1265
			math.floor(26 + 30 * matchK + 0.5), -- 1266
			255 -- 1267
		) -- 1267
	) -- 1267
	if wellAlpha > 0.01 then -- 1272
		local wellR = math.min(w, h) * (0.31 + matchK * 0.24) -- 1273
		uiDraw:drawCircle( -- 1275
			Vec2(ax, ay), -- 1275
			wellR + 36, -- 1275
			Color( -- 1275
				30, -- 1275
				35, -- 1275
				42, -- 1275
				math.floor(240 * wellAlpha + 0.5) -- 1275
			) -- 1275
		) -- 1275
		uiDraw:drawCircle( -- 1276
			Vec2(ax, ay), -- 1276
			wellR + 14, -- 1276
			Color( -- 1276
				20, -- 1276
				24, -- 1276
				30, -- 1276
				math.floor(250 * wellAlpha + 0.5) -- 1276
			) -- 1276
		) -- 1276
		uiDraw:drawCircle( -- 1278
			Vec2(ax, ay), -- 1278
			wellR, -- 1278
			Color( -- 1278
				7, -- 1278
				11, -- 1278
				17, -- 1278
				math.floor(255 * wellAlpha + 0.5) -- 1278
			) -- 1278
		) -- 1278
		local ri = 0 -- 1281
		do -- 1281
			ri = 0 -- 1282
			while ri < 3 do -- 1282
				local cyc = (t * 0.42 + ri * 0.33) % 1 -- 1283
				local r = 20 + cyc * (wellR * 0.85) -- 1284
				local ra = math.floor((1 - cyc) * 90 * wellAlpha + 0.5) -- 1285
				drawCircleRing( -- 1286
					uiInkDraw, -- 1286
					ax, -- 1286
					ay, -- 1286
					r, -- 1286
					Color(0, 0, 0, 0), -- 1286
					1.1, -- 1286
					Color(176, 198, 222, ra), -- 1286
					32 -- 1286
				) -- 1286
				ri = ri + 1 -- 1282
			end -- 1282
		end -- 1282
		local compassSlide = smoothstep(0.15, 0.95, t) -- 1290
		local compX = ax + (1 - compassSlide) * 140 -- 1291
		local compY = ay - (1 - compassSlide) * 90 -- 1292
		local compR = 62 -- 1293
		drawCircleRing( -- 1295
			uiInkDraw, -- 1296
			compX, -- 1297
			compY, -- 1298
			compR + 8, -- 1299
			Color( -- 1300
				98, -- 1300
				78, -- 1300
				48, -- 1300
				math.floor(218 * wellAlpha + 0.5) -- 1300
			), -- 1300
			2, -- 1301
			Color( -- 1302
				186, -- 1302
				154, -- 1302
				102, -- 1302
				math.floor(235 * wellAlpha + 0.5) -- 1302
			), -- 1302
			32 -- 1303
		) -- 1303
		drawCircleRing( -- 1306
			uiInkDraw, -- 1307
			compX, -- 1308
			compY, -- 1309
			compR, -- 1310
			Color( -- 1311
				16, -- 1311
				24, -- 1311
				36, -- 1311
				math.floor(145 * wellAlpha + 0.5) -- 1311
			), -- 1311
			1.2, -- 1312
			Color( -- 1313
				218, -- 1313
				226, -- 1313
				236, -- 1313
				math.floor(180 * wellAlpha + 0.5) -- 1313
			), -- 1313
			32 -- 1314
		) -- 1314
		uiInkDraw:drawSegment( -- 1317
			Vec2(compX, compY + compR - 6), -- 1317
			Vec2(compX, compY + compR - 18), -- 1317
			1.6, -- 1317
			Color( -- 1317
				224, -- 1317
				206, -- 1317
				168, -- 1317
				math.floor(190 * wellAlpha + 0.5) -- 1317
			) -- 1317
		) -- 1317
		uiInkDraw:drawSegment( -- 1318
			Vec2(compX, compY - compR + 6), -- 1318
			Vec2(compX, compY - compR + 18), -- 1318
			1.4, -- 1318
			Color( -- 1318
				168, -- 1318
				174, -- 1318
				182, -- 1318
				math.floor(165 * wellAlpha + 0.5) -- 1318
			) -- 1318
		) -- 1318
		uiInkDraw:drawSegment( -- 1319
			Vec2(compX - compR + 6, compY), -- 1319
			Vec2(compX - compR + 18, compY), -- 1319
			1.4, -- 1319
			Color( -- 1319
				168, -- 1319
				174, -- 1319
				182, -- 1319
				math.floor(165 * wellAlpha + 0.5) -- 1319
			) -- 1319
		) -- 1319
		uiInkDraw:drawSegment( -- 1320
			Vec2(compX + compR - 6, compY), -- 1320
			Vec2(compX + compR - 18, compY), -- 1320
			1.4, -- 1320
			Color( -- 1320
				168, -- 1320
				174, -- 1320
				182, -- 1320
				math.floor(165 * wellAlpha + 0.5) -- 1320
			) -- 1320
		) -- 1320
		local needleAng = -0.35 + math.sin(t * 2.2) * 0.08 * (1 - matchK) -- 1322
		local nx = math.cos(needleAng) * 34 -- 1323
		local ny = math.sin(needleAng) * 34 -- 1324
		uiInkDraw:drawSegment( -- 1325
			Vec2(compX, compY), -- 1325
			Vec2(compX + nx, compY + ny), -- 1325
			2.2, -- 1325
			Color( -- 1325
				208, -- 1325
				92, -- 1325
				82, -- 1325
				math.floor(215 * wellAlpha + 0.5) -- 1325
			) -- 1325
		) -- 1325
		uiInkDraw:drawSegment( -- 1326
			Vec2(compX, compY), -- 1326
			Vec2(compX - nx * 0.85, compY - ny * 0.85), -- 1326
			1.8, -- 1326
			Color( -- 1326
				214, -- 1326
				222, -- 1326
				232, -- 1326
				math.floor(185 * wellAlpha + 0.5) -- 1326
			) -- 1326
		) -- 1326
		if t >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 1329
			local pickK = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellMatchCutStart, t) -- 1330
			local liftY = ay + pickK * 14 -- 1331
			drawCircleRing( -- 1332
				uiInkDraw, -- 1333
				ax, -- 1334
				liftY, -- 1335
				24 + pickK * 12, -- 1336
				Color(0, 0, 0, 0), -- 1337
				1.6, -- 1338
				Color( -- 1339
					226, -- 1339
					204, -- 1339
					152, -- 1339
					math.floor(215 * (1 - matchK * 0.65) + 0.5) -- 1339
				), -- 1339
				28 -- 1340
			) -- 1340
			local capA = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellPickupAt + 0.35, t) * (1 - matchK) -- 1343
			if capA > 0.03 then -- 1344
				drawSilkVeil( -- 1345
					uiDraw, -- 1345
					uiArt, -- 1345
					"fe06_pickup_veil", -- 1345
					w * 0.5, -- 1345
					96, -- 1345
					300, -- 1345
					34, -- 1345
					PALETTE.inkVoid, -- 1345
					0.78 * capA, -- 1345
					1 -- 1345
				) -- 1345
				ctx.texts:put( -- 1346
					"sm", -- 1347
					"拾起「时间穿梭器」", -- 1348
					w * 0.5, -- 1349
					96, -- 1350
					toColor(PALETTE.amberCore), -- 1351
					0.5, -- 1352
					0.5, -- 1353
					"Center", -- 1354
					1.4, -- 1355
					capA -- 1356
				) -- 1356
			end -- 1356
		end -- 1356
	end -- 1356
	if matchK > 0.01 then -- 1363
		local caseW = 300 -- 1364
		local caseH = 276 -- 1365
		local caseX = self.glassAnchorX - caseW * 0.5 -- 1366
		local caseY = self.glassAnchorY - caseH * 0.54 -- 1367
		uiDraw:drawRect( -- 1369
			Rect(caseX - 80, caseY - 110, caseW + 160, caseH + 220), -- 1369
			Color( -- 1369
				24, -- 1369
				29, -- 1369
				36, -- 1369
				math.floor(190 * matchK + 0.5) -- 1369
			) -- 1369
		) -- 1369
		uiDraw:drawRect( -- 1370
			Rect(caseX, caseY, caseW, caseH), -- 1371
			Color( -- 1372
				18, -- 1372
				23, -- 1372
				30, -- 1372
				math.floor(220 * matchK + 0.5) -- 1372
			), -- 1372
			1.6, -- 1373
			Color( -- 1374
				164, -- 1374
				178, -- 1374
				194, -- 1374
				math.floor(185 * matchK + 0.5) -- 1374
			) -- 1374
		) -- 1374
		fillGradQuad( -- 1377
			uiInkDraw, -- 1378
			self.glassAnchorX - 42, -- 1379
			caseY + caseH - 6, -- 1379
			Color( -- 1379
				224, -- 1379
				236, -- 1379
				248, -- 1379
				math.floor(44 * matchK + 0.5) -- 1379
			), -- 1379
			self.glassAnchorX + 24, -- 1380
			caseY + caseH - 6, -- 1380
			Color( -- 1380
				238, -- 1380
				246, -- 1380
				255, -- 1380
				math.floor(78 * matchK + 0.5) -- 1380
			), -- 1380
			self.glassAnchorX - 18, -- 1381
			caseY + 6, -- 1381
			Color( -- 1381
				224, -- 1381
				236, -- 1381
				248, -- 1381
				math.floor(24 * matchK + 0.5) -- 1381
			), -- 1381
			self.glassAnchorX - 82, -- 1382
			caseY + 6, -- 1382
			Color(224, 236, 248, 0) -- 1382
		) -- 1382
		uiArt:tryPlace( -- 1385
			"prop_compass", -- 1385
			"fe06_match_compass", -- 1385
			self.glassAnchorX, -- 1385
			caseY + 72, -- 1385
			46, -- 1385
			46, -- 1385
			{opacity = matchK * 0.85, layer = 3} -- 1385
		) -- 1385
	end -- 1385
	local flashPeak = math.sin(matchK * math.pi) -- 1392
	local coreR = 8 + flashPeak * 18 -- 1393
	uiInkDraw:drawCircle( -- 1394
		Vec2(ax, ay), -- 1394
		coreR * 0.55, -- 1394
		Color(248, 252, 255, 248) -- 1394
	) -- 1394
	fillRadialGlow( -- 1395
		uiGlow, -- 1396
		ax, -- 1397
		ay, -- 1398
		52 + flashPeak * 145, -- 1399
		46 + flashPeak * 115, -- 1400
		Color( -- 1401
			238, -- 1401
			246, -- 1401
			255, -- 1401
			math.floor(145 + flashPeak * 95 + 0.5) -- 1401
		), -- 1401
		Color(174, 204, 238, 0), -- 1402
		20 -- 1403
	) -- 1403
	if flashPeak > 0.05 then -- 1406
		local rayW = 70 + flashPeak * 260 -- 1407
		fillHGradRect( -- 1408
			uiGlow, -- 1408
			ax - rayW, -- 1408
			ay - 2, -- 1408
			rayW, -- 1408
			4, -- 1408
			Color(224, 238, 252, 0), -- 1408
			Color( -- 1408
				242, -- 1408
				248, -- 1408
				255, -- 1408
				math.floor(160 * flashPeak + 0.5) -- 1408
			) -- 1408
		) -- 1408
		fillHGradRect( -- 1409
			uiGlow, -- 1409
			ax, -- 1409
			ay - 2, -- 1409
			rayW, -- 1409
			4, -- 1409
			Color( -- 1409
				242, -- 1409
				248, -- 1409
				255, -- 1409
				math.floor(160 * flashPeak + 0.5) -- 1409
			), -- 1409
			Color(224, 238, 252, 0) -- 1409
		) -- 1409
	end -- 1409
	self:drawLetterbox( -- 1412
		uiInkDraw, -- 1412
		w, -- 1412
		h, -- 1412
		42, -- 1412
		0.92 -- 1412
	) -- 1412
end -- 1235
function WellMuseumPlugin.prototype.renderE02MuseumHall(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, lampTurnProg, inLampTurn) -- 1418
	local floorY = 148 -- 1429
	local wallTopY = h - 86 -- 1430
	local halfW = w * 0.5 -- 1431
	local camMin = math.min(____exports.MUSEUM_HALL_WIDTH * 0.5, halfW - 40) -- 1432
	local camMax = math.max(____exports.MUSEUM_HALL_WIDTH * 0.5, ____exports.MUSEUM_HALL_WIDTH - halfW + 40) -- 1433
	local camX = clamp(self.hallCamX, camMin, camMax) -- 1434
	local function toScreenX(hx) -- 1435
		return halfW + (hx - camX) -- 1435
	end -- 1435
	fillVGradRect( -- 1438
		uiDraw, -- 1438
		0, -- 1438
		floorY, -- 1438
		w, -- 1438
		h - floorY, -- 1438
		Color(26, 31, 38, 255), -- 1438
		Color(16, 20, 26, 255) -- 1438
	) -- 1438
	uiDraw:drawRect( -- 1440
		Rect(0, wallTopY, w, h - wallTopY), -- 1440
		Color(11, 14, 19, 255) -- 1440
	) -- 1440
	local px = 0 -- 1442
	do -- 1442
		px = 40 -- 1443
		while px <= ____exports.MUSEUM_HALL_WIDTH do -- 1443
			local sx = toScreenX(px) -- 1444
			if sx >= -20 and sx <= w + 20 then -- 1445
				uiDraw:drawSegment( -- 1446
					Vec2(sx, floorY), -- 1446
					Vec2(sx, wallTopY), -- 1446
					1, -- 1446
					Color(38, 45, 54, 130) -- 1446
				) -- 1446
			end -- 1446
			px = px + 140 -- 1443
		end -- 1443
	end -- 1443
	fillVGradRect( -- 1450
		uiDraw, -- 1450
		0, -- 1450
		0, -- 1450
		w, -- 1450
		floorY, -- 1450
		Color(14, 17, 22, 255), -- 1450
		Color(32, 37, 45, 255) -- 1450
	) -- 1450
	uiDraw:drawSegment( -- 1451
		Vec2(0, floorY), -- 1451
		Vec2(w, floorY), -- 1451
		2, -- 1451
		Color(76, 86, 98, 220) -- 1451
	) -- 1451
	uiDraw:drawRect( -- 1452
		Rect(0, floorY, w, 12), -- 1452
		Color(20, 24, 31, 240) -- 1452
	) -- 1452
	local plaqueWorldX = self.caseX <= 260 and 108 or 180 -- 1455
	local plaqueX = toScreenX(plaqueWorldX) -- 1456
	if plaqueX > -240 and plaqueX < w + 240 then -- 1457
		local pw = 290 -- 1458
		local ph = 132 -- 1459
		local py = floorY + 135 -- 1460
		uiDraw:drawRect( -- 1461
			Rect(plaqueX - pw * 0.5, py, pw, ph), -- 1462
			Color(18, 22, 28, 238), -- 1463
			1.2, -- 1464
			Color(118, 128, 140, 170) -- 1465
		) -- 1465
		fillRadialGlow( -- 1467
			uiGlow, -- 1467
			plaqueX, -- 1467
			wallTopY - 8, -- 1467
			150, -- 1467
			120, -- 1467
			Color(224, 232, 240, 42), -- 1467
			Color(180, 196, 214, 0), -- 1467
			14 -- 1467
		) -- 1467
		ctx.texts:put( -- 1468
			"sm", -- 1469
			"海防抗战纪念展厅", -- 1470
			plaqueX, -- 1471
			py + 82, -- 1472
			toColor(PALETTE.textBright), -- 1473
			0.5, -- 1474
			0.5, -- 1475
			"Center", -- 1476
			2, -- 1477
			0.88 -- 1478
		) -- 1478
		ctx.texts:put( -- 1480
			"xs", -- 1481
			"温州宁村 · 守望史迹陈列", -- 1482
			plaqueX, -- 1483
			py + 46, -- 1484
			toColor(PALETTE.textDim), -- 1485
			0.5, -- 1486
			0.5, -- 1487
			"Center", -- 1488
			1, -- 1489
			0.78 -- 1490
		) -- 1490
	end -- 1490
	local caseSx = toScreenX(self.caseX) -- 1495
	if caseSx > -260 and caseSx < w + 260 then -- 1496
		local boardOffsets = self.caseX <= 260 and ({180, 390}) or ({-210, 210}) -- 1498
		local bi = 0 -- 1499
		do -- 1499
			bi = 0 -- 1500
			while bi < #boardOffsets do -- 1500
				local bx = caseSx + boardOffsets[bi + 1] -- 1501
				uiDraw:drawRect( -- 1502
					Rect(bx - 56, floorY + 112, 112, 154), -- 1502
					Color(20, 24, 30, 235), -- 1502
					1, -- 1502
					Color(88, 98, 110, 155) -- 1502
				) -- 1502
				uiDraw:drawRect( -- 1503
					Rect(bx - 42, floorY + 168, 84, 78), -- 1503
					Color(34, 40, 48, 220) -- 1503
				) -- 1503
				uiDraw:drawSegment( -- 1504
					Vec2(bx - 36, floorY + 146), -- 1504
					Vec2(bx + 36, floorY + 146), -- 1504
					1.6, -- 1504
					Color(138, 146, 156, 140) -- 1504
				) -- 1504
				uiDraw:drawSegment( -- 1505
					Vec2(bx - 28, floorY + 132), -- 1505
					Vec2(bx + 24, floorY + 132), -- 1505
					1.2, -- 1505
					Color(108, 116, 126, 115) -- 1505
				) -- 1505
				bi = bi + 1 -- 1500
			end -- 1500
		end -- 1500
		local pedW = 148 -- 1509
		local pedH = 92 -- 1510
		local glassH = 128 -- 1511
		uiDraw:drawRect( -- 1513
			Rect(caseSx - pedW * 0.5, floorY, pedW, pedH), -- 1514
			Color(22, 26, 33, 252), -- 1515
			1.2, -- 1516
			Color(96, 106, 118, 185) -- 1517
		) -- 1517
		uiDraw:drawRect( -- 1520
			Rect(caseSx - pedW * 0.46, floorY + pedH, pedW * 0.92, glassH), -- 1521
			Color(16, 22, 30, 165), -- 1522
			1.4, -- 1523
			Color(180, 196, 214, 195) -- 1524
		) -- 1524
		uiArt:tryPlace( -- 1527
			"prop_compass", -- 1527
			"fe06_hall_compass", -- 1527
			caseSx, -- 1527
			floorY + pedH + 34, -- 1527
			34, -- 1527
			34, -- 1527
			{opacity = 0.94, layer = 3} -- 1527
		) -- 1527
		uiDraw:drawRect( -- 1531
			Rect(caseSx - 30, floorY + pedH + 6, 60, 12), -- 1531
			Color(214, 212, 204, 190) -- 1531
		) -- 1531
		fillGradQuad( -- 1533
			uiInkDraw, -- 1534
			caseSx - 28, -- 1535
			floorY + pedH + glassH - 4, -- 1535
			Color(230, 240, 252, 42), -- 1535
			caseSx + 12, -- 1536
			floorY + pedH + glassH - 4, -- 1536
			Color(242, 248, 255, 72), -- 1536
			caseSx - 12, -- 1537
			floorY + pedH + 4, -- 1537
			Color(230, 240, 252, 18), -- 1537
			caseSx - 48, -- 1538
			floorY + pedH + 4, -- 1538
			Color(230, 240, 252, 0) -- 1538
		) -- 1538
		fillRadialGlow( -- 1540
			uiGlow, -- 1540
			caseSx, -- 1540
			floorY + pedH + glassH - 12, -- 1540
			86, -- 1540
			128, -- 1540
			Color(224, 236, 250, 56), -- 1540
			Color(168, 192, 220, 0), -- 1540
			16 -- 1540
		) -- 1540
		fillVGradRect( -- 1542
			uiDraw, -- 1542
			caseSx - pedW * 0.45, -- 1542
			floorY - 36, -- 1542
			pedW * 0.9, -- 1542
			36, -- 1542
			Color(168, 186, 206, 0), -- 1542
			Color(168, 186, 206, 28) -- 1542
		) -- 1542
	end -- 1542
	local lampSx = toScreenX(self.lampX) -- 1546
	local winSx = toScreenX(self.lampX + 108) -- 1547
	local reflectK = inLampTurn and smoothstep(____exports.MUSEUM_TIMINGS.lampReflectStart, 2.35, self.lampElapsed) or 0 -- 1548
	if winSx > -260 and winSx < w + 260 then -- 1552
		local winW = 204 -- 1553
		local winH = 312 -- 1554
		local winX = winSx - winW * 0.5 -- 1555
		local winY = floorY + 38 -- 1556
		fillVGradRect( -- 1558
			uiDraw, -- 1559
			winX, -- 1560
			winY, -- 1561
			winW, -- 1562
			winH, -- 1563
			Color( -- 1564
				math.floor(54 + 46 * reflectK + 0.5), -- 1565
				math.floor(68 + 42 * reflectK + 0.5), -- 1566
				math.floor(92 + 24 * reflectK + 0.5), -- 1567
				255 -- 1568
			), -- 1568
			Color( -- 1570
				math.floor(30 + 28 * reflectK + 0.5), -- 1571
				math.floor(44 + 34 * reflectK + 0.5), -- 1572
				math.floor(70 + 30 * reflectK + 0.5), -- 1573
				255 -- 1574
			) -- 1574
		) -- 1574
		if reflectK > 0.02 then -- 1579
			uiArt:tryPlace( -- 1580
				"bgFar_prologue", -- 1580
				"fe06_window_courtyard", -- 1580
				winSx, -- 1580
				winY + 26, -- 1580
				winW - 8, -- 1580
				winH - 52, -- 1580
				{ -- 1580
					opacity = reflectK * 0.48, -- 1581
					color = Color(238, 218, 186, 255), -- 1582
					layer = 1 -- 1583
				} -- 1583
			) -- 1583
			local cy = winY + 34 -- 1586
			local silA = math.floor(188 * reflectK + 0.5) -- 1587
			uiInkDraw:drawRect( -- 1588
				Rect(winX + 12, cy, 42, 118), -- 1588
				Color(24, 28, 36, silA) -- 1588
			) -- 1588
			uiInkDraw:drawRect( -- 1589
				Rect(winX + winW - 56, cy, 44, 134), -- 1589
				Color(24, 28, 36, silA) -- 1589
			) -- 1589
			uiInkDraw:drawRect( -- 1591
				Rect(winSx - 24, cy + 4, 48, 28), -- 1591
				Color( -- 1591
					46, -- 1591
					44, -- 1591
					42, -- 1591
					math.floor(215 * reflectK + 0.5) -- 1591
				), -- 1591
				1, -- 1591
				Color( -- 1591
					214, -- 1591
					186, -- 1591
					138, -- 1591
					math.floor(170 * reflectK + 0.5) -- 1591
				) -- 1591
			) -- 1591
			uiInkDraw:drawEllipse( -- 1592
				Vec2(winSx, cy + 32), -- 1592
				26, -- 1592
				7, -- 1592
				Color( -- 1592
					218, -- 1592
					194, -- 1592
					148, -- 1592
					math.floor(175 * reflectK + 0.5) -- 1592
				) -- 1592
			) -- 1592
			fillRadialGlow( -- 1594
				uiGlow, -- 1594
				winSx, -- 1594
				winY + winH * 0.48, -- 1594
				116, -- 1594
				128, -- 1594
				Color( -- 1594
					246, -- 1594
					218, -- 1594
					168, -- 1594
					math.floor(92 * reflectK + 0.5) -- 1594
				), -- 1594
				Color(214, 174, 112, 0), -- 1594
				18 -- 1594
			) -- 1594
		end -- 1594
		uiInkDraw:drawRect( -- 1598
			Rect(winX, winY, winW, winH), -- 1598
			Color(0, 0, 0, 0), -- 1598
			3, -- 1598
			Color(68, 76, 88, 245) -- 1598
		) -- 1598
		uiInkDraw:drawSegment( -- 1599
			Vec2(winSx, winY), -- 1599
			Vec2(winSx, winY + winH), -- 1599
			2, -- 1599
			Color(68, 76, 88, 235) -- 1599
		) -- 1599
		uiInkDraw:drawSegment( -- 1600
			Vec2(winX, winY + winH * 0.56), -- 1600
			Vec2(winX + winW, winY + winH * 0.56), -- 1600
			2, -- 1600
			Color(68, 76, 88, 235) -- 1600
		) -- 1600
		local standW = 34 -- 1603
		local standH = 96 -- 1604
		uiDraw:drawRect( -- 1605
			Rect(lampSx - standW * 0.5, floorY, standW, standH), -- 1605
			Color(34, 39, 48, 250), -- 1605
			1.1, -- 1605
			Color(108, 118, 130, 190) -- 1605
		) -- 1605
		local pivotY = floorY + standH + 44 -- 1607
		uiInkDraw:drawSegment( -- 1608
			Vec2(lampSx, floorY + standH), -- 1608
			Vec2(lampSx, pivotY), -- 1608
			3.2, -- 1608
			Color(136, 144, 154, 240) -- 1608
		) -- 1608
		uiInkDraw:drawCircle( -- 1609
			Vec2(lampSx, pivotY), -- 1609
			5.5, -- 1609
			Color(196, 178, 142, 245) -- 1609
		) -- 1609
		local aimDir = -0.65 + lampTurnProg * 1.48 -- 1611
		local headX = lampSx + math.sin(aimDir) * 20 -- 1612
		local headY = pivotY + math.cos(aimDir) * 14 -- 1613
		uiInkDraw:drawSegment( -- 1614
			Vec2(lampSx, pivotY), -- 1614
			Vec2(headX, headY), -- 1614
			6.2, -- 1614
			Color(188, 166, 126, 245) -- 1614
		) -- 1614
		uiInkDraw:drawCircle( -- 1615
			Vec2(headX, headY), -- 1615
			5.2, -- 1615
			Color(248, 234, 198, 248) -- 1615
		) -- 1615
		local beamLen = 132 + lampTurnProg * 76 -- 1618
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
				math.floor(68 + 44 * lampTurnProg + 0.5) -- 1625
			), -- 1625
			headX, -- 1626
			headY + 4, -- 1626
			Color( -- 1626
				246, -- 1626
				224, -- 1626
				178, -- 1626
				math.floor(68 + 44 * lampTurnProg + 0.5) -- 1626
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
			34, -- 1630
			34, -- 1630
			Color(246, 228, 186, 78), -- 1630
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
	if not uiArt:tryPlace( -- 1643
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
	if self.holstered and not inLampTurn and math.abs(self.hallWalkX - self.caseX) <= 130 then -- 1654
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
	if self.childEchoVisualT > 0 then -- 1671
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
	if not inLampTurn then -- 1693
		local fadeIn = smoothstep(0, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn, self.hallIntroElapsed) -- 1694
		local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold + ____exports.MUSEUM_TIMINGS.hallIntroFadeOut, self.hallIntroElapsed) -- 1695
		local introA = fadeIn * fadeOut -- 1700
		if introA > 0.02 then -- 1701
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
		if self.nearLamp and ctx.view.assistHintsEnabled then -- 1709
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
				"xs", -- 1711
				"[E] 转动西窗灯", -- 1711
				lampSx, -- 1711
				floorY + 158, -- 1711
				toColor(PALETTE.textBright), -- 1711
				0.5, -- 1711
				0.5, -- 1711
				"Center", -- 1711
				0.6, -- 1711
				0.94 -- 1711
			) -- 1711
		end -- 1711
	end -- 1711
	if inLampTurn and self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1716
		local lineA = smoothstep(____exports.MUSEUM_TIMINGS.lampLineAt, ____exports.MUSEUM_TIMINGS.lampLineAt + 0.45, self.lampElapsed) * (1 - smoothstep(____exports.MUSEUM_TIMINGS.lampTurnDuration - 0.35, ____exports.MUSEUM_TIMINGS.lampTurnDuration, self.lampElapsed)) -- 1717
		if lineA > 0.02 then -- 1719
			drawSilkVeil( -- 1720
				uiDraw, -- 1720
				uiArt, -- 1720
				"fe06_dawn_line_veil", -- 1720
				w * 0.5, -- 1720
				86, -- 1720
				440, -- 1720
				50, -- 1720
				PALETTE.inkVoid, -- 1720
				0.84 * lineA, -- 1720
				1 -- 1720
			) -- 1720
			ctx.texts:put( -- 1721
				"md", -- 1722
				____exports.MUSEUM_LINE_DAWN, -- 1722
				w * 0.5, -- 1724
				86, -- 1725
				toColor(PALETTE.amberCore), -- 1726
				0.5, -- 1727
				0.5, -- 1728
				"Center", -- 1729
				1.6, -- 1730
				lineA -- 1731
			) -- 1731
		end -- 1731
	end -- 1731
	if self.knock1VisualT > 0 then -- 1736
		local k1 = 1 - clamp01(self.knock1VisualT / 0.85) -- 1737
		local k1A = math.floor((1 - k1) * 205 + 0.5) -- 1738
		drawCircleRing( -- 1739
			uiInkDraw, -- 1739
			winSx, -- 1739
			floorY + 148, -- 1739
			12 + k1 * 64, -- 1739
			Color(0, 0, 0, 0), -- 1739
			1.6, -- 1739
			Color(242, 232, 206, k1A), -- 1739
			28 -- 1739
		) -- 1739
		drawCircleRing( -- 1740
			uiInkDraw, -- 1740
			winSx, -- 1740
			floorY + 148, -- 1740
			6 + k1 * 34, -- 1740
			Color(0, 0, 0, 0), -- 1740
			1.1, -- 1740
			Color( -- 1740
				242, -- 1740
				232, -- 1740
				206, -- 1740
				math.floor(k1A * 0.72 + 0.5) -- 1740
			), -- 1740
			24 -- 1740
		) -- 1740
	end -- 1740
	self:drawLetterbox( -- 1743
		uiInkDraw, -- 1743
		w, -- 1743
		h, -- 1743
		38, -- 1743
		0.9 -- 1743
	) -- 1743
end -- 1418
function WellMuseumPlugin.prototype.renderE02ReturnCabinet(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1749
	local t = self.returnElapsed -- 1758
	local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.returnFadeOutAt, ____exports.MUSEUM_TIMINGS.returnCabinetDuration, t) -- 1759
	uiDraw:drawRect( -- 1762
		Rect(0, 0, w, h), -- 1762
		Color( -- 1762
			7, -- 1762
			9, -- 1762
			13, -- 1762
			math.floor(252 * fadeOut + 0.5) -- 1762
		) -- 1762
	) -- 1762
	if t < ____exports.MUSEUM_TIMINGS.returnKnock2At then -- 1764
		self:drawLetterbox( -- 1765
			uiInkDraw, -- 1765
			w, -- 1765
			h, -- 1765
			42, -- 1765
			0.95 * fadeOut -- 1765
		) -- 1765
		return -- 1766
	end -- 1766
	local revealK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.34, t) * fadeOut -- 1770
	local boxW = math.min(w - 140, 820) -- 1771
	local boxH = math.min(h - 190, 390) -- 1772
	local bx = (w - boxW) * 0.5 -- 1773
	local by = (h - boxH) * 0.5 + 10 -- 1774
	fillVGradRect( -- 1777
		uiDraw, -- 1778
		bx, -- 1779
		by, -- 1780
		boxW, -- 1781
		boxH, -- 1782
		Color( -- 1783
			13, -- 1783
			12, -- 1783
			16, -- 1783
			math.floor(248 * revealK + 0.5) -- 1783
		), -- 1783
		Color( -- 1784
			24, -- 1784
			24, -- 1784
			30, -- 1784
			math.floor(248 * revealK + 0.5) -- 1784
		) -- 1784
	) -- 1784
	local cabEdgeX = bx + boxW * 0.58 -- 1787
	uiDraw:drawRect( -- 1788
		Rect(cabEdgeX, by, boxW - (cabEdgeX - bx), boxH), -- 1788
		Color( -- 1788
			42, -- 1788
			31, -- 1788
			24, -- 1788
			math.floor(246 * revealK + 0.5) -- 1788
		) -- 1788
	) -- 1788
	uiDraw:drawSegment( -- 1789
		Vec2(cabEdgeX, by), -- 1789
		Vec2(cabEdgeX, by + boxH), -- 1789
		2.4, -- 1789
		Color( -- 1789
			116, -- 1789
			92, -- 1789
			68, -- 1789
			math.floor(220 * revealK + 0.5) -- 1789
		) -- 1789
	) -- 1789
	local gi = 0 -- 1791
	do -- 1791
		gi = 0 -- 1792
		while gi < 5 do -- 1792
			local gx = cabEdgeX + 26 + gi * 44 -- 1793
			if gx < bx + boxW - 10 then -- 1794
				uiDraw:drawSegment( -- 1795
					Vec2(gx, by + 12), -- 1795
					Vec2(gx, by + boxH - 12), -- 1795
					1, -- 1795
					Color( -- 1795
						28, -- 1795
						20, -- 1795
						15, -- 1795
						math.floor(140 * revealK + 0.5) -- 1795
					) -- 1795
				) -- 1795
			end -- 1795
			gi = gi + 1 -- 1792
		end -- 1792
	end -- 1792
	fillHGradRect( -- 1799
		uiGlow, -- 1800
		cabEdgeX - 58, -- 1801
		by + 24, -- 1802
		58, -- 1803
		boxH - 48, -- 1804
		Color(168, 188, 210, 0), -- 1805
		Color( -- 1806
			186, -- 1806
			206, -- 1806
			226, -- 1806
			math.floor(42 * revealK + 0.5) -- 1806
		) -- 1806
	) -- 1806
	if self.knock2VisualT > 0 then -- 1810
		local k2 = 1 - clamp01(self.knock2VisualT / 0.9) -- 1811
		local k2A = math.floor((1 - k2) * 215 * fadeOut + 0.5) -- 1812
		drawCircleRing( -- 1813
			uiInkDraw, -- 1813
			cabEdgeX + 8, -- 1813
			by + boxH * 0.5, -- 1813
			10 + k2 * 56, -- 1813
			Color(0, 0, 0, 0), -- 1813
			1.6, -- 1813
			Color(232, 220, 196, k2A), -- 1813
			28 -- 1813
		) -- 1813
	end -- 1813
	local extendK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.08, ____exports.MUSEUM_TIMINGS.returnKnock2At + 1.05, t) -- 1817
	local wristX = bx + 115 + extendK * (cabEdgeX - bx - 168) -- 1818
	local wristY = by + boxH * 0.5 -- 1819
	drawPatchedCuff(uiInkDraw, uiGlow, { -- 1820
		wristX = wristX, -- 1821
		wristY = wristY, -- 1822
		angleRad = -0.04 * (1 - extendK), -- 1823
		scale = 1.02, -- 1824
		pose = "reach", -- 1825
		opacity = revealK, -- 1826
		stitchHighlight = 0.48 + 0.22 * extendK, -- 1827
		cuffPullBack = 0.06, -- 1828
		warmth = 0.16 -- 1829
	}) -- 1829
	uiInkDraw:drawRect( -- 1833
		Rect(bx, by, boxW, boxH), -- 1833
		Color(0, 0, 0, 0), -- 1833
		1.2, -- 1833
		toColor( -- 1833
			PALETTE.silkDim, -- 1833
			math.floor(160 * revealK + 0.5) -- 1833
		) -- 1833
	) -- 1833
	local tipA = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.45, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.95, t) * fadeOut -- 1834
	if tipA > 0.03 then -- 1835
		drawSilkVeil( -- 1836
			uiDraw, -- 1836
			uiArt, -- 1836
			"fe06_return_veil", -- 1836
			w * 0.5, -- 1836
			by - 30, -- 1836
			320, -- 1836
			32, -- 1836
			PALETTE.inkVoid, -- 1836
			0.72 * tipA, -- 1836
			1 -- 1836
		) -- 1836
		ctx.texts:put( -- 1837
			"xs", -- 1838
			"两声轻敲落回柜板 · 寻回小满", -- 1839
			w * 0.5, -- 1840
			by - 30, -- 1841
			toColor(PALETTE.textMid), -- 1842
			0.5, -- 1843
			0.5, -- 1844
			"Center", -- 1845
			1.2, -- 1846
			tipA * 0.9 -- 1847
		) -- 1847
	end -- 1847
	self:drawLetterbox( -- 1851
		uiInkDraw, -- 1851
		w, -- 1851
		h, -- 1851
		42, -- 1851
		0.95 * fadeOut -- 1851
	) -- 1851
end -- 1749
function WellMuseumPlugin.prototype.drawLetterbox(self, draw, w, h, barH, opacity) -- 1854
	local a = math.floor(244 * clamp01(opacity) + 0.5) -- 1855
	if a <= 2 then -- 1856
		return -- 1857
	end -- 1857
	draw:drawRect( -- 1859
		Rect(0, 0, w, barH), -- 1859
		Color(6, 8, 12, a) -- 1859
	) -- 1859
	draw:drawRect( -- 1860
		Rect(0, h - barH, w, barH), -- 1860
		Color(6, 8, 12, a) -- 1860
	) -- 1860
end -- 1854
function ____exports.createWellMuseumPlugin(contract) -- 1864
	return __TS__New(____exports.WellMuseumPlugin, contract) -- 1865
end -- 1864
return ____exports -- 1864
