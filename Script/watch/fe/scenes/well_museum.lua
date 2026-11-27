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
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 43
local drawComicSequence = ____slideshow.drawComicSequence -- 43
local ____target = require("Script.watch.target") -- 44
local getActiveTarget = ____target.getActiveTarget -- 44
local ____theme = require("Script.watch.fe.theme") -- 45
local PALETTE = ____theme.PALETTE -- 46
local drawHairline = ____theme.drawHairline -- 47
local drawSilkVeil = ____theme.drawSilkVeil -- 48
local fillGradQuad = ____theme.fillGradQuad -- 49
local fillHGradRect = ____theme.fillHGradRect -- 50
local fillRadialGlow = ____theme.fillRadialGlow -- 51
local fillVGradRect = ____theme.fillVGradRect -- 52
local toColor = ____theme.toColor -- 54
____exports.WELL_WORLD_X = 430 -- 57
____exports.WELL_INTERACT_REACH = 46 -- 58
____exports.MATCH_CUT_ANCHOR_NX = 0.5 -- 59
____exports.MATCH_CUT_ANCHOR_NY = 0.54 -- 60
____exports.MUSEUM_HALL_WIDTH = 1360 -- 61
____exports.MUSEUM_ENTRY_X = 180 -- 62
____exports.MUSEUM_CASE_X = 600 -- 63
____exports.MUSEUM_LAMP_X = 1140 -- 64
____exports.MUSEUM_WALK_SPEED = 156 -- 65
____exports.MUSEUM_LINE_DAWN = "「小满，外头天亮了。」" -- 66
____exports.MUSEUM_HALL_TITLE = "现代 · 宁村海防抗战纪念展厅" -- 67
____exports.MUSEUM_HALL_SUBTITLE = "山河安然，守望未绝" -- 68
____exports.MUSEUM_TIMINGS = { -- 70
	wellReflectDuration = 3.2, -- 71
	wellPickupAt = 1.1, -- 72
	wellMatchCutStart = 1.9, -- 73
	hallIntroFadeIn = 0.55, -- 74
	hallIntroHold = 3.4, -- 75
	hallIntroFadeOut = 0.85, -- 76
	childEchoDelay = 0.52, -- 77
	lampTurnDuration = 3.8, -- 78
	lampReflectStart = 0.65, -- 79
	lampLineAt = 1.45, -- 80
	lampKnock1At = 3.15, -- 81
	returnCabinetDuration = 2.6, -- 82
	returnKnock2At = 0.42, -- 83
	returnFadeOutAt = 2.2 -- 84
} -- 84
local MUSEUM_AUDIO_ROOT = "assets/audio/museum/" -- 87
____exports.MUSEUM_AUDIO = { -- 88
	wellDripLoop = MUSEUM_AUDIO_ROOT .. "well_drip_loop.wav", -- 89
	artifactPickup = MUSEUM_AUDIO_ROOT .. "artifact_pickup.wav", -- 90
	matchCutTransition = MUSEUM_AUDIO_ROOT .. "match_cut_transition.wav", -- 91
	hallAmbienceLoop = MUSEUM_AUDIO_ROOT .. "hall_ambience_loop.wav", -- 92
	hallFootstep = MUSEUM_AUDIO_ROOT .. "hall_footstep.wav", -- 93
	weaponHolster = MUSEUM_AUDIO_ROOT .. "weapon_holster.wav", -- 94
	childStepsEcho = MUSEUM_AUDIO_ROOT .. "child_steps_echo.wav", -- 95
	lampTurn = MUSEUM_AUDIO_ROOT .. "lamp_turn.wav", -- 96
	knockHallFirst = MUSEUM_AUDIO_ROOT .. "knock_hall_first.wav", -- 97
	knockCabinetSecond = MUSEUM_AUDIO_ROOT .. "knock_cabinet_second.wav", -- 98
	lineDawn = MUSEUM_AUDIO_ROOT .. "line_dawn.wav" -- 99
} -- 99
local LOOP_WELL_DRIP = "fe06_well_drip" -- 102
local LOOP_HALL_AMBIENCE = "fe06_hall_ambience" -- 103
--- E01 井底白灯 → 指南针叠合 → 0px 光学匹配剪辑闪切 → 现代玻璃展柜硬核漫画拍表（3.2s）
local E01_MATCH_COMIC_SEQ = {{ -- 106
	slot = "comic_museum_e01_01_well_water", -- 107
	start = 0, -- 107
	["end"] = 0.92, -- 107
	zoomFrom = 1, -- 107
	zoomTo = 1.012, -- 107
	transition = "cut" -- 107
}, { -- 107
	slot = "comic_museum_e01_02_compass_align", -- 108
	start = 0.92, -- 108
	["end"] = 1.9, -- 108
	zoomFrom = 1.005, -- 108
	zoomTo = 1.018, -- 108
	transition = "cut" -- 108
}, { -- 108
	slot = "comic_museum_e01_03_match_flash", -- 109
	start = 1.9, -- 109
	["end"] = 2.26, -- 109
	zoomFrom = 1.03, -- 109
	zoomTo = 1.03, -- 109
	transition = "cut", -- 109
	impactFlash = true, -- 109
	impactDur = 0.24, -- 109
	shakeAmp = 5.5, -- 109
	shakeFreq = 64 -- 109
}, { -- 109
	slot = "comic_museum_e01_04_vitrine_emerge", -- 110
	start = 2.26, -- 110
	["end"] = 3.6, -- 110
	zoomFrom = 1.014, -- 110
	zoomTo = 1, -- 110
	transition = "cut" -- 110
}} -- 110
--- E02 现代展厅西窗转灯与破晓映古井硬核漫画拍表（3.8s）
local E02_LAMP_COMIC_SEQ = {{ -- 114
	slot = "comic_museum_e02_01_west_window", -- 115
	start = 0, -- 115
	["end"] = 0.55, -- 115
	zoomFrom = 1, -- 115
	zoomTo = 1.01, -- 115
	transition = "cut" -- 115
}, { -- 115
	slot = "comic_museum_e02_02_lamp_turn", -- 116
	start = 0.55, -- 116
	["end"] = 1.48, -- 116
	zoomFrom = 1.006, -- 116
	zoomTo = 1.018, -- 116
	transition = "cut" -- 116
}, { -- 116
	slot = "comic_museum_e02_03_dawn_well_reflect", -- 117
	start = 1.48, -- 117
	["end"] = 4.5, -- 117
	zoomFrom = 1.012, -- 117
	zoomTo = 1, -- 117
	transition = "cut" -- 117
}} -- 117
--- E02 尾声：第二声实木轻叩落回明初厨柜缝与四镜同源五针补线袖口（2.6s）
local E02_RETURN_COMIC_SEQ = {{ -- 121
	slot = "comic_museum_e02_04_cabinet_cuff_return", -- 122
	start = 0, -- 122
	["end"] = 3, -- 122
	zoomFrom = 1.015, -- 122
	zoomTo = 1, -- 122
	transition = "cut", -- 122
	shakeAmp = 2.8, -- 122
	shakeFreq = 50 -- 122
}} -- 122
local function clamp(v, lo, hi) -- 179
	return math.max( -- 180
		lo, -- 180
		math.min(hi, v) -- 180
	) -- 180
end -- 179
local function clamp01(v) -- 183
	return clamp(v, 0, 1) -- 184
end -- 183
local function smoothstep(edge0, edge1, x) -- 187
	if edge1 <= edge0 then -- 187
		return x >= edge1 and 1 or 0 -- 189
	end -- 189
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 191
	return t * t * (3 - 2 * t) -- 192
end -- 187
local function drawEllipseRing(draw, cx, cy, rx, ry, fillCol, borderWidth, borderCol, segments) -- 195
	if segments == nil then -- 195
		segments = 28 -- 204
	end -- 204
	if rx <= 0.5 or ry <= 0.5 then -- 204
		return -- 207
	end -- 207
	local pts = {} -- 209
	local step = math.pi * 2 / segments -- 210
	local i = 0 -- 211
	do -- 211
		i = 0 -- 212
		while i < segments do -- 212
			local a = i * step -- 213
			pts[#pts + 1] = Vec2( -- 214
				cx + math.cos(a) * rx, -- 214
				cy + math.sin(a) * ry -- 214
			) -- 214
			i = i + 1 -- 212
		end -- 212
	end -- 212
	draw:drawPolygon(pts, fillCol, borderWidth, borderCol) -- 216
end -- 195
local function drawCircleRing(draw, cx, cy, r, fillCol, borderWidth, borderCol, segments) -- 219
	if segments == nil then -- 219
		segments = 28 -- 227
	end -- 227
	drawEllipseRing( -- 229
		draw, -- 229
		cx, -- 229
		cy, -- 229
		r, -- 229
		r, -- 229
		fillCol, -- 229
		borderWidth, -- 229
		borderCol, -- 229
		segments -- 229
	) -- 229
end -- 219
local function asRecord(v) -- 232
	if v ~= nil and type(v) == "table" then -- 232
		return v -- 234
	end -- 234
	return nil -- 236
end -- 232
local function readNum(rec, key) -- 239
	if rec == nil then -- 239
		return nil -- 241
	end -- 241
	local val = rec[key] -- 243
	return type(val) == "number" and val or nil -- 244
end -- 239
local function readBool(rec, key) -- 247
	if rec == nil then -- 247
		return nil -- 249
	end -- 249
	local val = rec[key] -- 251
	local ____temp_0 -- 252
	if type(val) == "boolean" then -- 252
		____temp_0 = val -- 252
	else -- 252
		____temp_0 = nil -- 252
	end -- 252
	return ____temp_0 -- 252
end -- 247
local function resolveRuntimeContract(injected) -- 255
	if injected ~= nil then -- 255
		return injected -- 257
	end -- 257
	local g = _G -- 259
	local ____temp_1 -- 260
	if g.package ~= nil then -- 260
		____temp_1 = g.package.loaded -- 260
	else -- 260
		____temp_1 = nil -- 260
	end -- 260
	local loaded = ____temp_1 -- 260
	if loaded == nil then -- 260
		return nil -- 262
	end -- 262
	local rawFe = loaded["watch.fe"] -- 264
	if rawFe ~= nil and type(rawFe) == "table" then -- 264
		local c = rawFe.contract -- 266
		if c ~= nil and type(c) == "table" then -- 266
			return c -- 268
		end -- 268
	end -- 268
	return nil -- 271
end -- 255
local function isPrologueIntroBlocking() -- 274
	local g = _G -- 275
	local ____temp_2 -- 276
	if g.package ~= nil then -- 276
		____temp_2 = g.package.loaded -- 276
	else -- 276
		____temp_2 = nil -- 276
	end -- 276
	local loaded = ____temp_2 -- 276
	if loaded == nil then -- 276
		return false -- 278
	end -- 278
	local rawFe = loaded["watch.fe"] -- 280
	if rawFe == nil or type(rawFe) ~= "table" then -- 280
		return false -- 282
	end -- 282
	local prologue = rawFe.prologue -- 284
	if prologue == nil or type(prologue) ~= "table" then -- 284
		return false -- 286
	end -- 286
	local fn = prologue.getSnapshot -- 288
	if type(fn) ~= "function" then -- 288
		return false -- 290
	end -- 290
	local snap = asRecord(fn(prologue)) -- 292
	if readBool(snap, "blocksPlayerControl") == true then -- 292
		return true -- 294
	end -- 294
	local stage = snap ~= nil and type(snap.stage) == "string" and snap.stage or "idle" -- 297
	return stage == "p02_escape" or stage == "p02_hidden" -- 298
end -- 274
local function isActiveMuseumPhase(phase) -- 301
	return phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" -- 302
end -- 301
____exports.WellMuseumPlugin = __TS__Class() -- 308
local WellMuseumPlugin = ____exports.WellMuseumPlugin -- 308
WellMuseumPlugin.name = "WellMuseumPlugin" -- 308
function WellMuseumPlugin.prototype.____constructor(self, contract) -- 374
	self.id = "fe-06-well-museum" -- 309
	self.animTime = 0 -- 312
	self.prevPhase = "locked" -- 313
	self.roomSessionId = 0 -- 314
	self.rehearsal = false -- 315
	self.gateOpen = false -- 318
	self.gateBlockedReason = "locked" -- 319
	self.wellWorldX = ____exports.WELL_WORLD_X -- 320
	self.caseX = ____exports.MUSEUM_CASE_X -- 321
	self.lampX = ____exports.MUSEUM_LAMP_X -- 322
	self.nearWell = false -- 323
	self.revisitCalmTimer = 0 -- 324
	self.revisitCalmCount = 0 -- 325
	self.reflectElapsed = 0 -- 328
	self.wellAnchorX = 640 -- 329
	self.wellAnchorY = 388.8 -- 330
	self.glassAnchorX = 640 -- 331
	self.glassAnchorY = 388.8 -- 332
	self.enterHallSubmitted = false -- 333
	self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 336
	self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 337
	self.hallFacing = 1 -- 338
	self.hallWalkAnim = 0 -- 339
	self.hallMoving = false -- 340
	self.hallFootstepTimer = 0 -- 341
	self.hallIntroElapsed = 0 -- 342
	self.holstered = false -- 343
	self.childEchoCountdown = -1 -- 344
	self.childEchoPlayed = false -- 345
	self.childEchoVisualT = 0 -- 346
	self.nearLamp = false -- 347
	self.lampElapsed = 0 -- 349
	self.lineDawnShown = false -- 350
	self.knock1Played = false -- 351
	self.knock1VisualT = 0 -- 352
	self.beginReturnSubmitted = false -- 353
	self.returnElapsed = 0 -- 356
	self.knock2Played = false -- 357
	self.knock2VisualT = 0 -- 358
	self.returnCompleteSubmitted = false -- 359
	self.artifactGrantCount = 0 -- 362
	self.resumeRestoreCount = 0 -- 364
	self.lastResumePhase = "locked" -- 365
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 366
	self.lastVisualMode = "pixel" -- 367
	self.lastPaused = false -- 368
	self.wellDripPlaying = false -- 369
	self.hallAmbiencePlaying = false -- 370
	self.liveReflectDoneInMuseumRoom = false -- 371
	self.injectedContract = contract -- 375
end -- 374
function WellMuseumPlugin.prototype.syncRuntimeHook(self) -- 378
	local g = _G -- 379
	local ____temp_3 -- 380
	if g.package ~= nil then -- 380
		____temp_3 = g.package.loaded -- 380
	else -- 380
		____temp_3 = nil -- 380
	end -- 380
	local loaded = ____temp_3 -- 380
	if loaded == nil then -- 380
		return -- 382
	end -- 382
	local rawFe = loaded["watch.fe"] -- 384
	if rawFe ~= nil and type(rawFe) == "table" then -- 384
		local watchFe = rawFe -- 386
		if watchFe.wellMuseum ~= self then -- 386
			watchFe.wellMuseum = self -- 388
		end -- 388
	end -- 388
end -- 378
function WellMuseumPlugin.prototype.queueSimulatedInput(self, sim) -- 394
	self.simInput = {moveX = sim.moveX, interact = sim.interact} -- 395
end -- 394
function WellMuseumPlugin.prototype.exportResumeState(self) -- 402
	return { -- 403
		phase = self.prevPhase, -- 404
		hallWalkX = self.hallWalkX, -- 405
		hallCamX = self.hallCamX, -- 406
		hallFacing = self.hallFacing, -- 407
		holstered = self.holstered, -- 408
		childEchoPlayed = self.childEchoPlayed, -- 409
		reflectElapsed = self.reflectElapsed, -- 410
		lampElapsed = self.lampElapsed, -- 411
		returnElapsed = self.returnElapsed, -- 412
		artifactGrantCount = self.artifactGrantCount -- 413
	} -- 413
end -- 402
function WellMuseumPlugin.prototype.restoreResumeState(self, snap) -- 418
	if snap.phase ~= nil then -- 418
		self.prevPhase = snap.phase -- 420
		self.lastResumePhase = snap.phase -- 421
	end -- 421
	if snap.hallWalkX ~= nil then -- 421
		self.hallWalkX = clamp(snap.hallWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 424
		self.lastResumeWalkX = self.hallWalkX -- 425
	end -- 425
	if snap.hallCamX ~= nil then -- 425
		self.hallCamX = snap.hallCamX -- 428
	else -- 428
		self.hallCamX = self.hallWalkX -- 430
	end -- 430
	if snap.hallFacing ~= nil then -- 430
		self.hallFacing = snap.hallFacing >= 0 and 1 or -1 -- 433
	end -- 433
	if snap.holstered ~= nil then -- 433
		self.holstered = snap.holstered -- 436
	end -- 436
	if snap.childEchoPlayed ~= nil then -- 436
		self.childEchoPlayed = snap.childEchoPlayed -- 439
	end -- 439
	if snap.reflectElapsed ~= nil then -- 439
		self.reflectElapsed = math.max(0, snap.reflectElapsed) -- 442
	end -- 442
	if snap.lampElapsed ~= nil then -- 442
		self.lampElapsed = math.max(0, snap.lampElapsed) -- 445
	end -- 445
	if snap.returnElapsed ~= nil then -- 445
		self.returnElapsed = math.max(0, snap.returnElapsed) -- 448
	end -- 448
	if snap.artifactGrantCount ~= nil then -- 448
		self.artifactGrantCount = math.max(0, snap.artifactGrantCount) -- 451
	end -- 451
	self.savedResume = self:exportResumeState() -- 453
	self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 454
end -- 418
function WellMuseumPlugin.prototype.resetSessionCounters(self) -- 458
	self.artifactGrantCount = 0 -- 459
	self.revisitCalmCount = 0 -- 460
	self.revisitCalmTimer = 0 -- 461
	self.savedResume = nil -- 462
	self.resumeRestoreCount = 0 -- 463
	self.lastResumePhase = "locked" -- 464
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 465
end -- 458
function WellMuseumPlugin.prototype.setHallWalkPosition(self, x, holstered) -- 469
	self.hallWalkX = clamp(x, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 470
	self.hallCamX = self.hallWalkX -- 471
	if holstered ~= nil then -- 471
		self.holstered = holstered -- 473
	elseif self.hallWalkX >= self.caseX - 85 then -- 473
		self.holstered = true -- 475
	end -- 475
	self.savedResume = self:exportResumeState() -- 477
end -- 469
function WellMuseumPlugin.prototype.seekStageTime(self, stage, seconds) -- 481
	local s = math.max(0, seconds) -- 482
	if stage == "well_reflect" then -- 482
		self.reflectElapsed = math.min(____exports.MUSEUM_TIMINGS.wellReflectDuration, s) -- 484
	elseif stage == "lamp_turn" then -- 484
		self.lampElapsed = math.min(____exports.MUSEUM_TIMINGS.lampTurnDuration, s) -- 486
		self.lineDawnShown = self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt -- 487
	elseif stage == "return_cabinet" then -- 487
		self.returnElapsed = math.min(____exports.MUSEUM_TIMINGS.returnCabinetDuration, s) -- 489
	end -- 489
end -- 481
function WellMuseumPlugin.prototype.getDebugState(self) -- 493
	local reflectProg = clamp01(self.reflectElapsed / ____exports.MUSEUM_TIMINGS.wellReflectDuration) -- 494
	local matchStart = ____exports.MUSEUM_TIMINGS.wellMatchCutStart -- 495
	local matchSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.wellReflectDuration - matchStart) -- 496
	local matchProg = self.reflectElapsed <= matchStart and 0 or clamp01((self.reflectElapsed - matchStart) / matchSpan) -- 497
	local lampTurnProg = clamp01(self.lampElapsed / 1.15) -- 500
	local cuffStart = ____exports.MUSEUM_TIMINGS.returnKnock2At -- 501
	local cuffSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.returnFadeOutAt - cuffStart) -- 502
	local cuffProg = self.returnElapsed <= cuffStart and 0 or clamp01((self.returnElapsed - cuffStart) / cuffSpan) -- 503
	local dx = self.glassAnchorX - self.wellAnchorX -- 506
	local dy = self.glassAnchorY - self.wellAnchorY -- 507
	return { -- 508
		gateOpen = self.gateOpen, -- 509
		gateBlockedReason = self.gateBlockedReason, -- 510
		wellWorldX = self.wellWorldX, -- 511
		nearWell = self.nearWell, -- 512
		museumPhase = self.prevPhase, -- 513
		visualMode = self.lastVisualMode, -- 514
		reflectElapsed = self.reflectElapsed, -- 515
		reflectProgress = reflectProg, -- 516
		matchCutProgress = matchProg, -- 517
		wellAnchorX = self.wellAnchorX, -- 518
		wellAnchorY = self.wellAnchorY, -- 519
		glassAnchorX = self.glassAnchorX, -- 520
		glassAnchorY = self.glassAnchorY, -- 521
		matchCutAnchorDeltaPx = math.sqrt(dx * dx + dy * dy), -- 522
		hallWalkX = self.hallWalkX, -- 523
		hallCamX = self.hallCamX, -- 524
		holstered = self.holstered, -- 525
		childEchoPlayed = self.childEchoPlayed, -- 526
		nearLamp = self.nearLamp, -- 527
		lampElapsed = self.lampElapsed, -- 528
		lampTurnProgress = lampTurnProg, -- 529
		lineDawnShown = self.lineDawnShown, -- 530
		knock1Played = self.knock1Played, -- 531
		knock2Played = self.knock2Played, -- 532
		returnElapsed = self.returnElapsed, -- 533
		cuffReusedFromSharedPalette = true, -- 534
		cuffProgress = cuffProg, -- 535
		artifactGrantCount = self.artifactGrantCount, -- 536
		revisitCalmCount = self.revisitCalmCount, -- 537
		resumeRestoreCount = self.resumeRestoreCount, -- 538
		lastResumePhase = self.lastResumePhase, -- 539
		lastResumeWalkX = self.lastResumeWalkX, -- 540
		pausedFrozen = self.lastPaused -- 541
	} -- 541
end -- 493
function WellMuseumPlugin.prototype.onBindPlay(self, p, view) -- 545
	self:syncRuntimeHook() -- 546
	if view.isRehearsal ~= self.rehearsal then -- 546
		self.savedResume = nil -- 548
	end -- 548
	self.rehearsal = view.isRehearsal -- 550
	local ____view_isRehearsal_6 -- 551
	if view.isRehearsal then -- 551
		____view_isRehearsal_6 = nil -- 551
	else -- 551
		local ____opt_4 = p.room.story -- 551
		____view_isRehearsal_6 = ____opt_4 and ____opt_4.museum -- 551
	end -- 551
	local museum = ____view_isRehearsal_6 -- 551
	self.caseX = museum == nil and ____exports.MUSEUM_CASE_X or museum.cabinetX - p.ox -- 552
	self.lampX = museum == nil and ____exports.MUSEUM_LAMP_X or museum.lampX - p.ox -- 553
	self.animTime = 0 -- 554
	self.revisitCalmTimer = 0 -- 555
	self.childEchoVisualT = 0 -- 556
	self.knock1VisualT = 0 -- 557
	self.knock2VisualT = 0 -- 558
	self.wellDripPlaying = false -- 559
	self.hallAmbiencePlaying = false -- 560
	self.enterHallSubmitted = false -- 561
	self.beginReturnSubmitted = false -- 562
	self.returnCompleteSubmitted = false -- 563
	self.liveReflectDoneInMuseumRoom = false -- 564
	self.simInput = nil -- 565
	local phase = view.archive.museumPhase -- 567
	self.prevPhase = phase -- 568
	self.lastVisualMode = view.visualMode -- 569
	local pRec = asRecord(p) -- 573
	local backendWellX = readNum(pRec, "wellX") -- 574
	self.wellWorldX = backendWellX ~= nil and p.ox + backendWellX or p.ox + ____exports.WELL_WORLD_X -- 575
	self.hallMoving = false -- 576
	if view.archive.childCleared and view.archive.soldierCleared and view.archive.artifactOwned then -- 576
		if self.artifactGrantCount < 1 then -- 576
			self.artifactGrantCount = 1 -- 581
		end -- 581
	elseif not view.archive.artifactOwned then -- 581
		self.artifactGrantCount = 0 -- 584
	end -- 584
	if isActiveMuseumPhase(phase) then -- 584
		local ____view_isRehearsal_7 -- 589
		if view.isRehearsal then -- 589
			____view_isRehearsal_7 = nil -- 589
		else -- 589
			____view_isRehearsal_7 = asRecord(p.run) -- 589
		end -- 589
		local runRec = ____view_isRehearsal_7 -- 589
		local ____asRecord_9 = asRecord -- 590
		local ____temp_8 -- 590
		if pRec ~= nil then -- 590
			____temp_8 = pRec.archive -- 590
		else -- 590
			____temp_8 = nil -- 590
		end -- 590
		local ____asRecord_9_result_12 = ____asRecord_9(____temp_8) -- 590
		if ____asRecord_9_result_12 == nil then -- 590
			local ____asRecord_11 = asRecord -- 591
			local ____temp_10 -- 591
			if runRec ~= nil then -- 591
				____temp_10 = runRec.archive -- 591
			else -- 591
				____temp_10 = nil -- 591
			end -- 591
			____asRecord_9_result_12 = ____asRecord_11(____temp_10) -- 590
		end -- 590
		local archRec = ____asRecord_9_result_12 -- 590
		local backendWalkX = readNum(archRec, "museumWalkX") or readNum(pRec, "museumWalkX") -- 592
		local ____readBool_result_13 = readBool(archRec, "museumHolstered") -- 593
		if ____readBool_result_13 == nil then -- 593
			____readBool_result_13 = readBool(pRec, "museumHolstered") -- 593
		end -- 593
		local backendHolstered = ____readBool_result_13 -- 593
		local ____readBool_result_14 = readBool(archRec, "museumChildEchoPlayed") -- 594
		if ____readBool_result_14 == nil then -- 594
			____readBool_result_14 = readBool(pRec, "museumChildEchoPlayed") -- 594
		end -- 594
		local backendChildEcho = ____readBool_result_14 -- 594
		if self.savedResume ~= nil and self.savedResume.phase == phase then -- 594
			self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.savedResume.hallWalkX -- 597
			self.hallCamX = self.hallWalkX -- 598
			self.hallFacing = self.savedResume.hallFacing -- 599
			local ____backendHolstered_15 = backendHolstered -- 600
			if ____backendHolstered_15 == nil then -- 600
				____backendHolstered_15 = self.savedResume.holstered -- 600
			end -- 600
			self.holstered = ____backendHolstered_15 -- 600
			local ____backendChildEcho_16 = backendChildEcho -- 601
			if ____backendChildEcho_16 == nil then -- 601
				____backendChildEcho_16 = self.savedResume.childEchoPlayed -- 601
			end -- 601
			self.childEchoPlayed = ____backendChildEcho_16 -- 601
			self.reflectElapsed = self.savedResume.reflectElapsed -- 602
			self.lampElapsed = self.savedResume.lampElapsed -- 603
			self.returnElapsed = self.savedResume.returnElapsed -- 604
		else -- 604
			self:resetPhaseTimersForEntry(phase, backendWalkX, backendHolstered, backendChildEcho) -- 606
		end -- 606
		self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 608
		self.lastResumePhase = phase -- 609
		self.lastResumeWalkX = self.hallWalkX -- 610
	else -- 610
		self.reflectElapsed = 0 -- 613
		self.lampElapsed = 0 -- 614
		self.returnElapsed = 0 -- 615
		self.hallIntroElapsed = 0 -- 616
		self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 617
		self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 618
		self.hallFacing = 1 -- 619
		self.holstered = false -- 620
		self.childEchoCountdown = -1 -- 621
		self.childEchoPlayed = false -- 622
		self.lineDawnShown = false -- 623
		self.knock1Played = false -- 624
		self.knock2Played = false -- 625
		if phase == "locked" or phase == "well_open" then -- 625
			self.savedResume = nil -- 627
		end -- 627
	end -- 627
end -- 545
function WellMuseumPlugin.prototype.resetPhaseTimersForEntry(self, phase, backendWalkX, backendHolstered, backendChildEcho) -- 632
	if phase == "well_reflect" then -- 632
		self.reflectElapsed = 0 -- 639
		self.enterHallSubmitted = false -- 640
		return -- 641
	end -- 641
	if phase == "hall_walk" then -- 641
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or ____exports.MUSEUM_ENTRY_X -- 644
		self.hallCamX = self.hallWalkX -- 645
		self.hallFacing = 1 -- 646
		self.hallIntroElapsed = backendWalkX ~= nil and backendWalkX > 260 and 5 or 0 -- 647
		local ____backendHolstered_17 = backendHolstered -- 648
		if ____backendHolstered_17 == nil then -- 648
			____backendHolstered_17 = self.hallWalkX >= self.caseX - 85 -- 648
		end -- 648
		self.holstered = ____backendHolstered_17 -- 648
		local ____backendChildEcho_18 = backendChildEcho -- 649
		if ____backendChildEcho_18 == nil then -- 649
			____backendChildEcho_18 = self.hallWalkX >= self.caseX + 120 -- 649
		end -- 649
		self.childEchoPlayed = ____backendChildEcho_18 -- 649
		self.childEchoCountdown = -1 -- 650
		return -- 651
	end -- 651
	if phase == "lamp_turn" then -- 651
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.lampX - 36 -- 654
		self.hallCamX = self.hallWalkX -- 655
		self.hallFacing = 1 -- 656
		self.holstered = true -- 657
		self.childEchoPlayed = true -- 658
		self.lampElapsed = 0 -- 659
		self.lineDawnShown = false -- 660
		self.knock1Played = false -- 661
		self.beginReturnSubmitted = false -- 662
		return -- 663
	end -- 663
	if phase == "return_cabinet" then -- 663
		self.returnElapsed = 0 -- 666
		self.knock2Played = false -- 667
		self.returnCompleteSubmitted = false -- 668
	end -- 668
end -- 632
function WellMuseumPlugin.prototype.evaluateGate(self, p, view) -- 672
	if p.run.source == "chapter" then -- 672
		return {open = false, reason = "chapter_preview"} -- 674
	end -- 674
	if p.room.key ~= "prologue" then -- 674
		return {open = false, reason = "not_prologue"} -- 677
	end -- 677
	if p.phase ~= "prologue-wait" and p.phase ~= "prologue-well" then -- 677
		return {open = false, reason = "after_cabinet_window"} -- 680
	end -- 680
	if isPrologueIntroBlocking() then -- 680
		return {open = false, reason = "prologue_intro_active"} -- 683
	end -- 683
	if not view.archive.childCleared or not view.archive.soldierCleared then -- 683
		return {open = false, reason = "requires_both_clear"} -- 687
	end -- 687
	if view.archive.museumPhase == "locked" then -- 687
		return {open = false, reason = "phase_locked"} -- 690
	end -- 690
	return {open = true, reason = "ok"} -- 692
end -- 672
function WellMuseumPlugin.prototype.submitMuseumIntent(self, p, target) -- 695
	local contract = resolveRuntimeContract(self.injectedContract) -- 696
	if contract == nil then -- 696
		return false -- 698
	end -- 698
	local intent = {kind = "museumInteract", target = target} -- 700
	return contract:submitIntent(p, intent) -- 701
end -- 695
function WellMuseumPlugin.prototype.syncLoops(self, ctx, wantWellDrip, dripVolume, wantHallAmbience) -- 704
	if wantWellDrip then -- 704
		ctx.audio:playLoop( -- 706
			LOOP_WELL_DRIP, -- 706
			"water", -- 706
			____exports.MUSEUM_AUDIO.wellDripLoop, -- 706
			dripVolume, -- 706
			ctx.p.ticks -- 706
		) -- 706
		self.wellDripPlaying = true -- 707
	elseif self.wellDripPlaying then -- 707
		ctx.audio:stopLoop(LOOP_WELL_DRIP) -- 709
		self.wellDripPlaying = false -- 710
	end -- 710
	if wantHallAmbience then -- 710
		ctx.audio:playLoop( -- 714
			LOOP_HALL_AMBIENCE, -- 714
			"ambience", -- 714
			____exports.MUSEUM_AUDIO.hallAmbienceLoop, -- 714
			0.34, -- 714
			ctx.p.ticks -- 714
		) -- 714
		self.hallAmbiencePlaying = true -- 715
	elseif self.hallAmbiencePlaying then -- 715
		ctx.audio:stopLoop(LOOP_HALL_AMBIENCE) -- 717
		self.hallAmbiencePlaying = false -- 718
	end -- 718
end -- 704
function WellMuseumPlugin.prototype.update(self, ctx) -- 722
	self:syncRuntimeHook() -- 723
	local p = ctx.p -- 724
	local view = ctx.view -- 725
	local phase = view.archive.museumPhase -- 726
	if view.isRehearsal ~= self.rehearsal then -- 726
		self:syncLoops(ctx, false, 0, false) -- 728
		self:onBindPlay(p, view) -- 729
	end -- 729
	self.roomSessionId = ctx.events.roomSessionId -- 731
	self.lastVisualMode = view.visualMode -- 732
	self.lastPaused = ctx.paused -- 733
	self.wellAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 736
	self.wellAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 737
	self.glassAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 738
	self.glassAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 739
	local sim = self.simInput -- 742
	self.simInput = nil -- 743
	local interactPressed = ctx.input.interact.pressed or ctx.input.frameInteractPressed or sim ~= nil and sim.interact == true -- 744
	local moveX = sim ~= nil and sim.moveX ~= nil and sim.moveX or ctx.input.moveX -- 747
	if phase ~= self.prevPhase then -- 747
		local wasActive = isActiveMuseumPhase(self.prevPhase) -- 751
		self.prevPhase = phase -- 752
		if isActiveMuseumPhase(phase) then -- 752
			if phase == "well_reflect" then -- 752
				self:resetPhaseTimersForEntry("well_reflect") -- 755
				if view.archive.artifactOwned and self.artifactGrantCount < 1 then -- 755
					self.artifactGrantCount = 1 -- 757
				end -- 757
			elseif phase == "hall_walk" and not wasActive then -- 757
				self:resetPhaseTimersForEntry("hall_walk") -- 760
			elseif phase == "hall_walk" and wasActive then -- 760
				self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 762
				self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 763
				self.hallFacing = 1 -- 764
				self.hallIntroElapsed = 0 -- 765
				self.holstered = false -- 766
				self.childEchoPlayed = false -- 767
				self.childEchoCountdown = -1 -- 768
			elseif phase == "lamp_turn" then -- 768
				self:resetPhaseTimersForEntry("lamp_turn", self.hallWalkX, true, self.childEchoPlayed) -- 770
			elseif phase == "return_cabinet" then -- 770
				self:resetPhaseTimersForEntry("return_cabinet") -- 772
			end -- 772
		elseif phase == "done" then -- 772
			self.savedResume = nil -- 775
		end -- 775
	end -- 775
	local gate = self:evaluateGate(p, view) -- 779
	self.gateOpen = gate.open -- 780
	self.gateBlockedReason = gate.reason -- 781
	self.nearWell = gate.open and math.abs(p.player.x - self.wellWorldX) <= ____exports.WELL_INTERACT_REACH -- 782
	if ctx.paused then -- 782
		return -- 786
	end -- 786
	local wdt = math.max(0, ctx.worldDt) -- 789
	local udt = math.max(0, ctx.uiDt) -- 790
	self.animTime = self.animTime + wdt -- 791
	if self.revisitCalmTimer > 0 then -- 791
		self.revisitCalmTimer = math.max(0, self.revisitCalmTimer - wdt) -- 794
	end -- 794
	if self.childEchoVisualT > 0 then -- 794
		self.childEchoVisualT = math.max(0, self.childEchoVisualT - udt) -- 797
	end -- 797
	if self.knock1VisualT > 0 then -- 797
		self.knock1VisualT = math.max(0, self.knock1VisualT - wdt) -- 800
	end -- 800
	if self.knock2VisualT > 0 then -- 800
		self.knock2VisualT = math.max(0, self.knock2VisualT - wdt) -- 803
	end -- 803
	if view.visualMode ~= "museum" then -- 803
		local wantDrip = gate.open and phase == "well_open" and not view.archive.museumSeen -- 808
		local dist = math.abs(p.player.x - self.wellWorldX) -- 809
		local dripVol = clamp(0.46 - dist * 0.0014, 0.08, 0.46) -- 810
		self:syncLoops(ctx, wantDrip, dripVol, false) -- 811
		if gate.open and self.nearWell and interactPressed then -- 811
			local liveNeedsSecondEnter = not view.isRehearsal and p.room.key == "prologue" and view.archive.artifactOwned and not view.archive.museumSeen -- 814
			local alreadyAwarded = not liveNeedsSecondEnter and (view.archive.museumSeen or phase == "done" or view.archive.artifactOwned and self.artifactGrantCount >= 1) -- 818
			if (phase == "well_open" or liveNeedsSecondEnter) and not alreadyAwarded then -- 818
				self:submitMuseumIntent(p, "well_pickup") -- 823
			else -- 823
				self.revisitCalmTimer = 1.4 -- 826
				self.revisitCalmCount = self.revisitCalmCount + 1 -- 827
			end -- 827
		end -- 827
		return -- 830
	end -- 830
	local effectivePhase = p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 834
	if effectivePhase == "well_reflect" then -- 834
		local dripVol = clamp( -- 839
			0.44 * (1 - smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, self.reflectElapsed)), -- 839
			0, -- 839
			0.44 -- 839
		) -- 839
		self:syncLoops(ctx, dripVol > 0.03, dripVol, false) -- 840
		if wdt > 0 then -- 840
			self.reflectElapsed = self.reflectElapsed + wdt -- 843
		end -- 843
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 843
			if self.artifactGrantCount < 1 then -- 843
				self.artifactGrantCount = 1 -- 847
			end -- 847
			ctx.audio:playOnce( -- 849
				"fe06:e01:pickup:" .. tostring(self.roomSessionId), -- 850
				"sfx", -- 851
				____exports.MUSEUM_AUDIO.artifactPickup, -- 852
				0.86, -- 853
				"museum:e01:artifact_pickup", -- 854
				p.ticks -- 855
			) -- 855
		end -- 855
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellMatchCutStart then -- 855
			ctx.audio:playOnce( -- 859
				"fe06:e01:matchcut:" .. tostring(self.roomSessionId), -- 860
				"ambience", -- 861
				____exports.MUSEUM_AUDIO.matchCutTransition, -- 862
				0.78, -- 863
				"museum:e01:match_cut", -- 864
				p.ticks -- 865
			) -- 865
		end -- 865
		self.savedResume = self:exportResumeState() -- 868
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellReflectDuration and not self.enterHallSubmitted then -- 868
			self.enterHallSubmitted = true -- 870
			if p.room.key == "museum" then -- 870
				self.liveReflectDoneInMuseumRoom = true -- 872
			end -- 872
			self:submitMuseumIntent(p, "enter_hall") -- 874
			local contract = resolveRuntimeContract(self.injectedContract) -- 875
			if contract ~= nil and contract:isRehearsal() then -- 875
				contract:enterMockMuseum("hall_walk") -- 877
			end -- 877
		end -- 877
		return -- 880
	end -- 880
	if effectivePhase == "hall_walk" then -- 880
		self:syncLoops(ctx, false, 0, true) -- 885
		self.hallIntroElapsed = self.hallIntroElapsed + udt -- 886
		local ____view_isRehearsal_19 -- 890
		if view.isRehearsal then -- 890
			____view_isRehearsal_19 = nil -- 890
		else -- 890
			____view_isRehearsal_19 = asRecord(p) -- 890
		end -- 890
		local pRec = ____view_isRehearsal_19 -- 890
		local backendWalkX = readNum(pRec, "museumWalkX") or (not view.isRehearsal and p.room.key == "museum" and p.player.x - p.ox or nil) -- 891
		self.hallMoving = false -- 893
		local previousX = self.hallWalkX -- 894
		if backendWalkX ~= nil then -- 894
			self.hallWalkX = clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 896
		elseif udt > 0 and math.abs(moveX) > 0.05 then -- 896
			self.hallWalkX = clamp(self.hallWalkX + moveX * ____exports.MUSEUM_WALK_SPEED * udt, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 898
		end -- 898
		local delta = self.hallWalkX - previousX -- 900
		if math.abs(delta) > 0.01 then -- 900
			self.hallFacing = delta >= 0 and 1 or -1 -- 902
			self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 903
			self.hallMoving = true -- 904
			self.hallFootstepTimer = self.hallFootstepTimer + udt -- 905
			if self.hallFootstepTimer >= 0.46 then -- 905
				self.hallFootstepTimer = 0 -- 907
				ctx.audio:playOnce( -- 908
					(("fe06:e02:step:" .. tostring(self.roomSessionId)) .. ":") .. tostring(math.floor(self.hallWalkAnim * 2)), -- 909
					"sfx", -- 910
					____exports.MUSEUM_AUDIO.hallFootstep, -- 911
					0.46, -- 912
					"museum:e02:footstep", -- 913
					p.ticks -- 914
				) -- 914
			end -- 914
		else -- 914
			self.hallFootstepTimer = math.min(self.hallFootstepTimer, 0.22) -- 918
		end -- 918
		local camFollow = math.min(1, udt * 5.2) -- 922
		self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * camFollow -- 923
		local holsterThreshold = p.room.key == "museum" and self.caseX + 12 or self.caseX - 85 -- 926
		if not self.holstered and self.hallWalkX >= holsterThreshold then -- 926
			self.holstered = true -- 928
			ctx.audio:playOnce( -- 929
				"fe06:e02:holster:" .. tostring(self.roomSessionId), -- 930
				"sfx", -- 931
				____exports.MUSEUM_AUDIO.weaponHolster, -- 932
				0.76, -- 933
				"museum:e02:weapon_holster", -- 934
				p.ticks -- 935
			) -- 935
			if not self.childEchoPlayed then -- 935
				self.childEchoCountdown = ____exports.MUSEUM_TIMINGS.childEchoDelay -- 938
			end -- 938
		end -- 938
		if self.childEchoCountdown >= 0 and not self.childEchoPlayed then -- 938
			self.childEchoCountdown = self.childEchoCountdown - udt -- 943
			if self.childEchoCountdown <= 0 then -- 943
				self.childEchoCountdown = -1 -- 945
				self.childEchoPlayed = true -- 946
				self.childEchoVisualT = 2.1 -- 947
				ctx.audio:playOnce( -- 948
					"fe06:e02:child_echo:" .. tostring(self.roomSessionId), -- 949
					"sfx", -- 950
					____exports.MUSEUM_AUDIO.childStepsEcho, -- 951
					0.72, -- 952
					"museum:e02:child_steps_echo", -- 953
					p.ticks -- 954
				) -- 954
			end -- 954
		end -- 954
		local ____view_isRehearsal_20 -- 959
		if view.isRehearsal then -- 959
			____view_isRehearsal_20 = math.abs(self.hallWalkX - self.lampX) <= 72 -- 960
		else -- 960
			____view_isRehearsal_20 = (p.phase == "museum-hall" or p.phase == "museum-lamp") and math.abs(p.player.x - (self.lampX + p.ox)) <= 72 -- 961
		end -- 961
		self.nearLamp = ____view_isRehearsal_20 -- 959
		self.savedResume = self:exportResumeState() -- 963
		if self.nearLamp and interactPressed then -- 963
			self:submitMuseumIntent(p, "lamp_turn") -- 966
		end -- 966
		return -- 968
	end -- 968
	if effectivePhase == "lamp_turn" then -- 968
		self:syncLoops(ctx, false, 0, true) -- 973
		if wdt > 0 then -- 973
			self.lampElapsed = self.lampElapsed + wdt -- 975
		end -- 975
		if p.room.key == "museum" then -- 975
			local targetX = clamp(p.player.x - p.ox, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 979
			local delta = targetX - self.hallWalkX -- 980
			self.hallMoving = math.abs(delta) > 0.25 -- 981
			if self.hallMoving then -- 981
				self.hallFacing = delta >= 0 and 1 or -1 -- 983
				self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 984
			end -- 984
			self.hallWalkX = targetX -- 986
			self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * math.min(1, udt * 5.2) -- 987
		end -- 987
		ctx.audio:playOnce( -- 989
			"fe06:e02:lamp_turn:" .. tostring(self.roomSessionId), -- 990
			"sfx", -- 991
			____exports.MUSEUM_AUDIO.lampTurn, -- 992
			0.82, -- 993
			"museum:e02:lamp_turn", -- 994
			p.ticks -- 995
		) -- 995
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 995
			self.lineDawnShown = true -- 998
			ctx.audio:playOnce( -- 999
				"fe06:e02:line_dawn:" .. tostring(self.roomSessionId), -- 1000
				"voice", -- 1001
				____exports.MUSEUM_AUDIO.lineDawn, -- 1002
				0.92, -- 1003
				"museum:e02:line_dawn", -- 1004
				p.ticks -- 1005
			) -- 1005
		end -- 1005
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampKnock1At and not self.knock1Played then -- 1005
			self.knock1Played = true -- 1009
			self.knock1VisualT = 0.85 -- 1010
			ctx.audio:playOnce( -- 1011
				"fe06:e02:knock1:" .. tostring(self.roomSessionId), -- 1012
				"sfx", -- 1013
				____exports.MUSEUM_AUDIO.knockHallFirst, -- 1014
				0.88, -- 1015
				"museum:knock:1", -- 1016
				p.ticks -- 1017
			) -- 1017
		end -- 1017
		self.savedResume = self:exportResumeState() -- 1020
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampTurnDuration and not self.beginReturnSubmitted then -- 1020
			self.beginReturnSubmitted = true -- 1023
			self:submitMuseumIntent(p, "begin_return_cabinet") -- 1024
			local contract = resolveRuntimeContract(self.injectedContract) -- 1025
			if contract ~= nil and contract:isRehearsal() then -- 1025
				contract:enterMockMuseum("return_cabinet") -- 1027
			end -- 1027
		end -- 1027
		return -- 1030
	end -- 1030
	if phase == "return_cabinet" then -- 1030
		self:syncLoops(ctx, false, 0, false) -- 1035
		if wdt > 0 then -- 1035
			self.returnElapsed = self.returnElapsed + wdt -- 1037
		end -- 1037
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnKnock2At and not self.knock2Played then -- 1037
			self.knock2Played = true -- 1040
			self.knock2VisualT = 0.9 -- 1041
			ctx.audio:playOnce( -- 1042
				"fe06:e02:knock2:" .. tostring(self.roomSessionId), -- 1043
				"sfx", -- 1044
				____exports.MUSEUM_AUDIO.knockCabinetSecond, -- 1045
				0.92, -- 1046
				"museum:knock:2", -- 1047
				p.ticks -- 1048
			) -- 1048
		end -- 1048
		self.savedResume = self:exportResumeState() -- 1051
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnCabinetDuration and not self.returnCompleteSubmitted then -- 1051
			self.returnCompleteSubmitted = true -- 1054
			self:submitMuseumIntent(p, "return_cabinet") -- 1055
		end -- 1055
	end -- 1055
end -- 722
function WellMuseumPlugin.prototype.drawBackdrop(self, bgDraw, _bgGlow, _backdropArt, ctx) -- 1060
	if ctx.view.visualMode ~= "museum" then -- 1060
		return false -- 1067
	end -- 1067
	bgDraw:drawRect( -- 1070
		Rect(0, 0, ctx.w, ctx.h), -- 1070
		Color(11, 13, 18, 255) -- 1070
	) -- 1070
	return true -- 1071
end -- 1060
function WellMuseumPlugin.prototype.drawWorld(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1074
	return ctx.view.visualMode == "museum" -- 1080
end -- 1074
function WellMuseumPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1083
	return ctx.view.visualMode == "museum" -- 1089
end -- 1083
function WellMuseumPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 1095
	if not self.gateOpen or ctx.view.visualMode == "museum" then -- 1095
		return -- 1102
	end -- 1102
	local cam = ctx.cam -- 1104
	local wellCx = cam:sx(self.wellWorldX) -- 1105
	local groundY = cam:sy(0, 0) -- 1106
	local phase = ctx.view.archive.museumPhase -- 1107
	local activeLure = phase == "well_open" and not ctx.view.archive.museumSeen -- 1108
	local archW = cam:len(68) -- 1111
	local archH = cam:len(96) -- 1112
	local archX = wellCx - archW * 0.54 -- 1113
	fillVGradRect( -- 1114
		fgDraw, -- 1115
		archX, -- 1116
		groundY, -- 1117
		archW, -- 1118
		archH, -- 1119
		Color(12, 16, 22, 232), -- 1120
		Color(18, 24, 34, 212) -- 1121
	) -- 1121
	fgDraw:drawRect( -- 1124
		Rect(archX - 4, groundY, 6, archH), -- 1124
		Color(48, 54, 62, 240) -- 1124
	) -- 1124
	fgDraw:drawRect( -- 1125
		Rect(archX + archW - 2, groundY, 6, archH), -- 1125
		Color(48, 54, 62, 240) -- 1125
	) -- 1125
	fgDraw:drawRect( -- 1126
		Rect(archX - 6, groundY + archH - 8, archW + 12, 10), -- 1126
		Color(62, 68, 76, 245) -- 1126
	) -- 1126
	local rimW = cam:len(38) -- 1129
	local rimH = cam:len(22) -- 1130
	local rimX = wellCx - rimW * 0.5 -- 1131
	fgDraw:drawRect( -- 1132
		Rect(rimX, groundY, rimW, rimH), -- 1133
		Color(46, 52, 60, 250), -- 1134
		1.2, -- 1135
		Color(102, 110, 120, 215) -- 1136
	) -- 1136
	fgDraw:drawEllipse( -- 1139
		Vec2(wellCx, groundY + rimH), -- 1139
		rimW * 0.52, -- 1139
		cam:len(5.5), -- 1139
		Color(74, 82, 92, 250) -- 1139
	) -- 1139
	fgDraw:drawEllipse( -- 1140
		Vec2(wellCx, groundY + rimH), -- 1140
		rimW * 0.38, -- 1140
		cam:len(3.8), -- 1140
		Color(8, 12, 18, 255) -- 1140
	) -- 1140
	local dripCycle = self.animTime * 0.58 % 1 -- 1143
	local rippleR = cam:len(3 + dripCycle * 11) -- 1144
	local rippleAlpha = math.floor((1 - dripCycle) * (activeLure and 155 or 42) + 0.5) -- 1145
	if activeLure then -- 1145
		local shimmer = 0.65 + 0.35 * math.sin(self.animTime * 2.9) -- 1147
		fgDraw:drawCircle( -- 1149
			Vec2(wellCx, groundY + rimH), -- 1149
			cam:len(2.8), -- 1149
			Color( -- 1149
				236, -- 1149
				244, -- 1149
				252, -- 1149
				math.floor(215 * shimmer + 0.5) -- 1149
			) -- 1149
		) -- 1149
		drawEllipseRing( -- 1150
			fgDraw, -- 1150
			wellCx, -- 1150
			groundY + rimH, -- 1150
			rippleR, -- 1150
			rippleR * 0.36, -- 1150
			Color(0, 0, 0, 0), -- 1150
			1.1, -- 1150
			Color(210, 226, 242, rippleAlpha), -- 1150
			24 -- 1150
		) -- 1150
		fillRadialGlow( -- 1151
			fgGlow, -- 1152
			wellCx, -- 1153
			groundY + rimH + cam:len(8), -- 1154
			cam:len(30), -- 1155
			cam:len(38), -- 1156
			Color( -- 1157
				206, -- 1157
				224, -- 1157
				244, -- 1157
				math.floor(52 * shimmer + 0.5) -- 1157
			), -- 1157
			Color(148, 178, 212, 0), -- 1158
			16 -- 1159
		) -- 1159
		if dripCycle < 0.24 then -- 1159
			local dropK = dripCycle / 0.24 -- 1163
			local dropY = groundY + archH * 0.72 - dropK * (archH * 0.72 - rimH) -- 1164
			fgDraw:drawSegment( -- 1165
				Vec2(wellCx, dropY), -- 1166
				Vec2( -- 1167
					wellCx, -- 1167
					dropY + cam:len(4.5) -- 1167
				), -- 1167
				1.4, -- 1168
				Color(214, 228, 244, 185) -- 1169
			) -- 1169
		end -- 1169
	elseif self.revisitCalmTimer > 0 then -- 1169
		local calmK = 1 - clamp01(self.revisitCalmTimer / 1.4) -- 1174
		local calmR = cam:len(3 + calmK * 10) -- 1175
		drawEllipseRing( -- 1176
			fgDraw, -- 1177
			wellCx, -- 1178
			groundY + rimH, -- 1179
			calmR, -- 1180
			calmR * 0.35, -- 1181
			Color(0, 0, 0, 0), -- 1182
			1, -- 1183
			Color( -- 1184
				148, -- 1184
				160, -- 1184
				172, -- 1184
				math.floor((1 - calmK) * 120 + 0.5) -- 1184
			), -- 1184
			24 -- 1185
		) -- 1185
	end -- 1185
end -- 1095
function WellMuseumPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1195
	local view = ctx.view -- 1202
	local phase = view.archive.museumPhase -- 1203
	if view.visualMode ~= "museum" then -- 1203
		if self.gateOpen and self.nearWell and view.assistHintsEnabled and phase == "well_open" and not view.archive.museumSeen then -- 1203
			local sx = ctx.cam:sx(self.wellWorldX) / ctx.uiScale -- 1208
			local sy = (ctx.cam:sy(0, 0) + ctx.cam:len(54)) / ctx.uiScale -- 1209
			drawSilkVeil( -- 1210
				uiDraw, -- 1210
				uiArt, -- 1210
				"fe06_well_hint_veil", -- 1210
				sx, -- 1210
				sy, -- 1210
				132, -- 1210
				26, -- 1210
				PALETTE.panelBg, -- 1210
				0.82, -- 1210
				1 -- 1210
			) -- 1210
			ctx.texts:put( -- 1211
				"xs", -- 1212
				getActiveTarget():adaptHintSentence("[E] 俯身看井", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1213
				sx, -- 1214
				sy, -- 1215
				toColor(PALETTE.textBright), -- 1216
				0.5, -- 1217
				0.5, -- 1218
				"Center", -- 1219
				0.6, -- 1220
				0.92 -- 1221
			) -- 1221
		end -- 1221
		return false -- 1224
	end -- 1224
	local w = ctx.uiW -- 1227
	local h = ctx.uiH -- 1228
	local effectivePhase = ctx.p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 1230
	if effectivePhase == "well_reflect" then -- 1230
		self:renderE01WellReflectMatchCut( -- 1235
			uiDraw, -- 1235
			uiInkDraw, -- 1235
			uiArt, -- 1235
			uiGlow, -- 1235
			ctx, -- 1235
			w, -- 1235
			h -- 1235
		) -- 1235
		return true -- 1236
	end -- 1236
	if effectivePhase == "hall_walk" then -- 1236
		self:renderE02MuseumHall( -- 1239
			uiDraw, -- 1239
			uiInkDraw, -- 1239
			uiArt, -- 1239
			uiGlow, -- 1239
			ctx, -- 1239
			w, -- 1239
			h, -- 1239
			0, -- 1239
			false -- 1239
		) -- 1239
		return true -- 1240
	end -- 1240
	if effectivePhase == "lamp_turn" then -- 1240
		local turnProg = smoothstep(0, 1.15, self.lampElapsed) -- 1243
		self:renderE02MuseumHall( -- 1244
			uiDraw, -- 1244
			uiInkDraw, -- 1244
			uiArt, -- 1244
			uiGlow, -- 1244
			ctx, -- 1244
			w, -- 1244
			h, -- 1244
			turnProg, -- 1244
			true -- 1244
		) -- 1244
		return true -- 1245
	end -- 1245
	if effectivePhase == "return_cabinet" then -- 1245
		self:renderE02ReturnCabinet( -- 1248
			uiDraw, -- 1248
			uiInkDraw, -- 1248
			uiArt, -- 1248
			uiGlow, -- 1248
			ctx, -- 1248
			w, -- 1248
			h -- 1248
		) -- 1248
		return true -- 1249
	end -- 1249
	return false -- 1251
end -- 1195
function WellMuseumPlugin.prototype.renderE01WellReflectMatchCut(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1257
	local t = self.reflectElapsed -- 1266
	local ax = self.wellAnchorX -- 1267
	local ay = self.wellAnchorY -- 1268
	local matchK = smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, t) -- 1269
	drawComicSequence( -- 1271
		uiDraw, -- 1272
		uiInkDraw, -- 1273
		uiArt, -- 1274
		E01_MATCH_COMIC_SEQ, -- 1275
		t, -- 1276
		w, -- 1277
		h, -- 1278
		{ -- 1279
			letterboxH = 42, -- 1280
			opacity = 1, -- 1281
			layer = 1, -- 1282
			instancePrefix = "fe06_e01_comic", -- 1283
			accentBorder = true -- 1284
		} -- 1284
	) -- 1284
	if t >= ____exports.MUSEUM_TIMINGS.wellPickupAt and matchK < 0.85 then -- 1284
		local capA = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellPickupAt + 0.35, t) * (1 - matchK) -- 1290
		if capA > 0.03 then -- 1290
			drawSilkVeil( -- 1292
				uiDraw, -- 1292
				uiArt, -- 1292
				"fe06_pickup_veil", -- 1292
				w * 0.5, -- 1292
				96, -- 1292
				300, -- 1292
				34, -- 1292
				PALETTE.inkVoid, -- 1292
				0.78 * capA, -- 1292
				5 -- 1292
			) -- 1292
			ctx.texts:put( -- 1293
				"sm", -- 1294
				"拾起「时间穿梭器」", -- 1295
				w * 0.5, -- 1296
				96, -- 1297
				toColor(PALETTE.amberCore), -- 1298
				0.5, -- 1299
				0.5, -- 1300
				"Center", -- 1301
				1.4, -- 1302
				capA -- 1303
			) -- 1303
		end -- 1303
	end -- 1303
	local flashPeak = math.sin(matchK * math.pi) -- 1309
	local coreR = 7 + flashPeak * 16 -- 1310
	uiInkDraw:drawCircle( -- 1311
		Vec2(ax, ay), -- 1311
		coreR * 0.52, -- 1311
		Color( -- 1311
			248, -- 1311
			252, -- 1311
			255, -- 1311
			math.floor(180 + 68 * flashPeak + 0.5) -- 1311
		) -- 1311
	) -- 1311
	fillRadialGlow( -- 1312
		uiGlow, -- 1313
		ax, -- 1314
		ay, -- 1315
		48 + flashPeak * 135, -- 1316
		44 + flashPeak * 108, -- 1317
		Color( -- 1318
			238, -- 1318
			246, -- 1318
			255, -- 1318
			math.floor(92 + flashPeak * 128 + 0.5) -- 1318
		), -- 1318
		Color(174, 204, 238, 0), -- 1319
		20 -- 1320
	) -- 1320
	if flashPeak > 0.05 then -- 1320
		local rayW = 70 + flashPeak * 260 -- 1323
		fillHGradRect( -- 1324
			uiGlow, -- 1324
			ax - rayW, -- 1324
			ay - 2, -- 1324
			rayW, -- 1324
			4, -- 1324
			Color(224, 238, 252, 0), -- 1324
			Color( -- 1324
				242, -- 1324
				248, -- 1324
				255, -- 1324
				math.floor(150 * flashPeak + 0.5) -- 1324
			) -- 1324
		) -- 1324
		fillHGradRect( -- 1325
			uiGlow, -- 1325
			ax, -- 1325
			ay - 2, -- 1325
			rayW, -- 1325
			4, -- 1325
			Color( -- 1325
				242, -- 1325
				248, -- 1325
				255, -- 1325
				math.floor(150 * flashPeak + 0.5) -- 1325
			), -- 1325
			Color(224, 238, 252, 0) -- 1325
		) -- 1325
	end -- 1325
end -- 1257
function WellMuseumPlugin.prototype.renderE02MuseumHall(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, lampTurnProg, inLampTurn) -- 1332
	if inLampTurn then -- 1332
		drawComicSequence( -- 1344
			uiDraw, -- 1345
			uiInkDraw, -- 1346
			uiArt, -- 1347
			E02_LAMP_COMIC_SEQ, -- 1348
			self.lampElapsed, -- 1349
			w, -- 1350
			h, -- 1351
			{ -- 1352
				letterboxH = 42, -- 1353
				opacity = 1, -- 1354
				layer = 1, -- 1355
				instancePrefix = "fe06_e02_lamp_comic", -- 1356
				accentBorder = true -- 1357
			} -- 1357
		) -- 1357
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1357
			local lineA = smoothstep(____exports.MUSEUM_TIMINGS.lampLineAt, ____exports.MUSEUM_TIMINGS.lampLineAt + 0.45, self.lampElapsed) * (1 - smoothstep(____exports.MUSEUM_TIMINGS.lampTurnDuration - 0.35, ____exports.MUSEUM_TIMINGS.lampTurnDuration, self.lampElapsed)) -- 1361
			if lineA > 0.02 then -- 1361
				drawSilkVeil( -- 1364
					uiDraw, -- 1364
					uiArt, -- 1364
					"fe06_dawn_line_veil", -- 1364
					w * 0.5, -- 1364
					86, -- 1364
					440, -- 1364
					50, -- 1364
					PALETTE.inkVoid, -- 1364
					0.84 * lineA, -- 1364
					6 -- 1364
				) -- 1364
				ctx.texts:put( -- 1365
					"md", -- 1366
					____exports.MUSEUM_LINE_DAWN, -- 1366
					w * 0.5, -- 1368
					86, -- 1369
					toColor(PALETTE.amberCore), -- 1370
					0.5, -- 1371
					0.5, -- 1372
					"Center", -- 1373
					1.6, -- 1374
					lineA -- 1375
				) -- 1375
			end -- 1375
		end -- 1375
		if self.knock1VisualT > 0 then -- 1375
			local k1 = 1 - clamp01(self.knock1VisualT / 0.85) -- 1380
			local k1A = math.floor((1 - k1) * 215 + 0.5) -- 1381
			drawCircleRing( -- 1382
				uiInkDraw, -- 1382
				w * 0.62, -- 1382
				h * 0.48, -- 1382
				14 + k1 * 68, -- 1382
				Color(0, 0, 0, 0), -- 1382
				1.8, -- 1382
				Color(242, 232, 206, k1A), -- 1382
				28 -- 1382
			) -- 1382
			drawCircleRing( -- 1383
				uiInkDraw, -- 1383
				w * 0.62, -- 1383
				h * 0.48, -- 1383
				7 + k1 * 36, -- 1383
				Color(0, 0, 0, 0), -- 1383
				1.2, -- 1383
				Color( -- 1383
					242, -- 1383
					232, -- 1383
					206, -- 1383
					math.floor(k1A * 0.72 + 0.5) -- 1383
				), -- 1383
				24 -- 1383
			) -- 1383
		end -- 1383
		return -- 1385
	end -- 1385
	local floorY = 148 -- 1387
	local wallTopY = h - 86 -- 1388
	local halfW = w * 0.5 -- 1389
	local camMin = math.min(____exports.MUSEUM_HALL_WIDTH * 0.5, halfW - 40) -- 1390
	local camMax = math.max(____exports.MUSEUM_HALL_WIDTH * 0.5, ____exports.MUSEUM_HALL_WIDTH - halfW + 40) -- 1391
	local camX = clamp(self.hallCamX, camMin, camMax) -- 1392
	local function toScreenX(hx) -- 1393
		return halfW + (hx - camX) -- 1393
	end -- 1393
	fillVGradRect( -- 1396
		uiDraw, -- 1396
		0, -- 1396
		floorY, -- 1396
		w, -- 1396
		h - floorY, -- 1396
		Color(26, 31, 38, 255), -- 1396
		Color(16, 20, 26, 255) -- 1396
	) -- 1396
	fillVGradRect( -- 1397
		uiDraw, -- 1397
		0, -- 1397
		0, -- 1397
		w, -- 1397
		floorY, -- 1397
		Color(14, 17, 22, 255), -- 1397
		Color(32, 37, 45, 255) -- 1397
	) -- 1397
	local bgW = math.max(w * 1.18, ____exports.MUSEUM_HALL_WIDTH + 200) -- 1398
	local bgH = h -- 1399
	local bgCenterX = toScreenX(____exports.MUSEUM_HALL_WIDTH * 0.5) -- 1400
	local paintedHall = uiArt:tryPlacePath( -- 1401
		"assets/art/bg_museum_hall.png", -- 1402
		"fe06_museum_hall_bg", -- 1403
		bgCenterX, -- 1404
		h * 0.5, -- 1405
		bgW, -- 1406
		bgH, -- 1407
		{ -- 1408
			anchorX = 0.5, -- 1409
			anchorY = 0.5, -- 1410
			opacity = 1, -- 1411
			smooth = true, -- 1412
			layer = -6 -- 1413
		} -- 1413
	) -- 1413
	if not paintedHall then -- 1413
		uiDraw:drawRect( -- 1417
			Rect(0, wallTopY, w, h - wallTopY), -- 1417
			Color(11, 14, 19, 255) -- 1417
		) -- 1417
		uiDraw:drawSegment( -- 1418
			Vec2(0, floorY), -- 1418
			Vec2(w, floorY), -- 1418
			2, -- 1418
			Color(76, 86, 98, 220) -- 1418
		) -- 1418
	end -- 1418
	local plaqueWorldX = self.caseX <= 260 and 108 or 180 -- 1422
	local plaqueX = toScreenX(plaqueWorldX) -- 1423
	if plaqueX > -240 and plaqueX < w + 240 then -- 1423
		local pw = 286 -- 1425
		local ph = 112 -- 1426
		local py = floorY + 146 -- 1427
		drawSilkVeil( -- 1428
			uiDraw, -- 1428
			uiArt, -- 1428
			"fe06_plaque_veil", -- 1428
			plaqueX, -- 1428
			py + ph * 0.5, -- 1428
			pw, -- 1428
			ph, -- 1428
			PALETTE.inkVoid, -- 1428
			0.62, -- 1428
			0 -- 1428
		) -- 1428
		fillRadialGlow( -- 1429
			uiGlow, -- 1429
			plaqueX, -- 1429
			wallTopY - 8, -- 1429
			150, -- 1429
			120, -- 1429
			Color(224, 232, 240, 38), -- 1429
			Color(180, 196, 214, 0), -- 1429
			14 -- 1429
		) -- 1429
		ctx.texts:put( -- 1430
			"sm", -- 1431
			"海防抗战纪念展厅", -- 1432
			plaqueX, -- 1433
			py + 72, -- 1434
			toColor(PALETTE.textBright), -- 1435
			0.5, -- 1436
			0.5, -- 1437
			"Center", -- 1438
			2, -- 1439
			0.9 -- 1440
		) -- 1440
		ctx.texts:put( -- 1442
			"xs", -- 1443
			"温州宁村 · 守望史迹陈列", -- 1444
			plaqueX, -- 1445
			py + 38, -- 1446
			toColor(PALETTE.textMid), -- 1447
			0.5, -- 1448
			0.5, -- 1449
			"Center", -- 1450
			1, -- 1451
			0.8 -- 1452
		) -- 1452
	end -- 1452
	local caseSx = toScreenX(self.caseX) -- 1457
	if caseSx > -260 and caseSx < w + 260 then -- 1457
		local pedW = 148 -- 1459
		local pedH = 92 -- 1460
		local glassH = 128 -- 1461
		if not paintedHall then -- 1461
			uiDraw:drawRect( -- 1463
				Rect(caseSx - pedW * 0.5, floorY, pedW, pedH), -- 1463
				Color(22, 26, 33, 252), -- 1463
				1.2, -- 1463
				Color(96, 106, 118, 185) -- 1463
			) -- 1463
			uiDraw:drawRect( -- 1464
				Rect(caseSx - pedW * 0.46, floorY + pedH, pedW * 0.92, glassH), -- 1464
				Color(16, 22, 30, 165), -- 1464
				1.4, -- 1464
				Color(180, 196, 214, 195) -- 1464
			) -- 1464
		end -- 1464
		uiArt:tryPlace( -- 1467
			"prop_compass", -- 1467
			"fe06_hall_compass", -- 1467
			caseSx - 6, -- 1467
			floorY + pedH + 18, -- 1467
			32, -- 1467
			32, -- 1467
			{opacity = 0.96, layer = 2} -- 1467
		) -- 1467
		uiArt:tryPlacePath( -- 1471
			"assets/art/cutscene_cuff_rig.clip|cuff_zhou_open", -- 1471
			"fe06_hall_cuff_relic", -- 1471
			caseSx + 14, -- 1471
			floorY + pedH + 14, -- 1471
			58, -- 1471
			26, -- 1471
			{ -- 1471
				anchorX = 0.5, -- 1472
				anchorY = 0.5, -- 1473
				angle = -8, -- 1474
				opacity = 0.34, -- 1475
				smooth = true, -- 1476
				layer = 1 -- 1477
			} -- 1477
		) -- 1477
		fillGradQuad( -- 1479
			uiInkDraw, -- 1480
			caseSx - 28, -- 1481
			floorY + pedH + glassH - 4, -- 1481
			Color(230, 240, 252, 36), -- 1481
			caseSx + 12, -- 1482
			floorY + pedH + glassH - 4, -- 1482
			Color(242, 248, 255, 62), -- 1482
			caseSx - 12, -- 1483
			floorY + pedH + 4, -- 1483
			Color(230, 240, 252, 14), -- 1483
			caseSx - 48, -- 1484
			floorY + pedH + 4, -- 1484
			Color(230, 240, 252, 0) -- 1484
		) -- 1484
		fillRadialGlow( -- 1486
			uiGlow, -- 1486
			caseSx, -- 1486
			floorY + pedH + glassH - 12, -- 1486
			86, -- 1486
			128, -- 1486
			Color(224, 236, 250, 52), -- 1486
			Color(168, 192, 220, 0), -- 1486
			16 -- 1486
		) -- 1486
	end -- 1486
	local lampSx = toScreenX(self.lampX) -- 1490
	local winSx = toScreenX(self.lampX + 108) -- 1491
	local reflectK = inLampTurn and smoothstep(____exports.MUSEUM_TIMINGS.lampReflectStart, 2.35, self.lampElapsed) or 0 -- 1492
	if winSx > -260 and winSx < w + 260 then -- 1492
		local winW = 204 -- 1497
		local winH = 312 -- 1498
		local winX = winSx - winW * 0.5 -- 1499
		local winY = floorY + 38 -- 1500
		if not paintedHall then -- 1500
			fillVGradRect( -- 1502
				uiDraw, -- 1502
				winX, -- 1502
				winY, -- 1502
				winW, -- 1502
				winH, -- 1502
				Color(54, 68, 92, 255), -- 1502
				Color(30, 44, 70, 255) -- 1502
			) -- 1502
			uiInkDraw:drawRect( -- 1503
				Rect(winX, winY, winW, winH), -- 1503
				Color(0, 0, 0, 0), -- 1503
				3, -- 1503
				Color(68, 76, 88, 245) -- 1503
			) -- 1503
		end -- 1503
		if reflectK > 0.02 then -- 1503
			uiArt:tryPlace( -- 1508
				"bgFar_prologue", -- 1508
				"fe06_window_courtyard", -- 1508
				winSx, -- 1508
				winY + 26, -- 1508
				winW - 8, -- 1508
				winH - 52, -- 1508
				{ -- 1508
					opacity = reflectK * 0.52, -- 1509
					color = Color(242, 222, 188, 255), -- 1510
					layer = 1 -- 1511
				} -- 1511
			) -- 1511
			fillRadialGlow( -- 1513
				uiGlow, -- 1513
				winSx, -- 1513
				winY + winH * 0.48, -- 1513
				136, -- 1513
				152, -- 1513
				Color( -- 1513
					248, -- 1513
					220, -- 1513
					170, -- 1513
					math.floor(98 * reflectK + 0.5) -- 1513
				), -- 1513
				Color(214, 174, 112, 0), -- 1513
				18 -- 1513
			) -- 1513
		end -- 1513
		local aimDir = -0.65 + lampTurnProg * 1.48 -- 1517
		local lampH = 192 -- 1518
		local lampW = lampH * (236 / 360) -- 1519
		local headX = lampSx + 18 + math.sin(aimDir) * 20 -- 1520
		local headY = floorY + lampH - 34 + math.cos(aimDir) * 10 -- 1521
		if not uiArt:tryPlacePath( -- 1521
			"assets/art/cutscene_well_museum.clip|museum_brass_lamp", -- 1523
			"fe06_museum_brass_lamp", -- 1524
			lampSx, -- 1525
			floorY, -- 1526
			lampW, -- 1527
			lampH, -- 1528
			{ -- 1529
				anchorX = 0.5, -- 1530
				anchorY = 0, -- 1531
				angle = 0, -- 1532
				opacity = 0.98, -- 1533
				smooth = true, -- 1534
				layer = 4 -- 1535
			} -- 1535
		) then -- 1535
			uiDraw:drawRect( -- 1538
				Rect(lampSx - 17, floorY, 34, 96), -- 1538
				Color(34, 39, 48, 250) -- 1538
			) -- 1538
		end -- 1538
		local beamLen = 138 + lampTurnProg * 86 -- 1542
		local bxEnd = headX + math.sin(aimDir) * beamLen -- 1543
		local byEnd = headY + math.cos(aimDir) * 28 -- 1544
		local perpX = -math.cos(aimDir) * 18 -- 1545
		local perpY = math.sin(aimDir) * 34 -- 1546
		fillGradQuad( -- 1547
			uiGlow, -- 1548
			headX, -- 1549
			headY - 4, -- 1549
			Color( -- 1549
				246, -- 1549
				224, -- 1549
				178, -- 1549
				math.floor(68 + 46 * lampTurnProg + 0.5) -- 1549
			), -- 1549
			headX, -- 1550
			headY + 4, -- 1550
			Color( -- 1550
				246, -- 1550
				224, -- 1550
				178, -- 1550
				math.floor(68 + 46 * lampTurnProg + 0.5) -- 1550
			), -- 1550
			bxEnd + perpX, -- 1551
			byEnd + perpY + 34, -- 1551
			Color(238, 206, 148, 0), -- 1551
			bxEnd - perpX, -- 1552
			byEnd - perpY - 22, -- 1552
			Color(238, 206, 148, 0) -- 1552
		) -- 1552
		fillRadialGlow( -- 1554
			uiGlow, -- 1554
			headX, -- 1554
			headY, -- 1554
			38, -- 1554
			38, -- 1554
			Color(248, 228, 186, 82), -- 1554
			Color(224, 194, 140, 0), -- 1554
			14 -- 1554
		) -- 1554
	end -- 1554
	local playerSx = toScreenX(self.hallWalkX) -- 1558
	local moving = not inLampTurn and self.hallMoving -- 1559
	local slot = moving and "soldier_run" or "soldier_idle" -- 1560
	local frame = moving and math.floor(self.hallWalkAnim) or 0 -- 1561
	local charH = math.floor(192 * math.max( -- 1562
		0.75, -- 1562
		math.min(1.25, h / 720) -- 1562
	) + 0.5) -- 1562
	local charW = math.floor(charH * 0.45 + 0.5) -- 1563
	uiDraw:drawEllipse( -- 1565
		Vec2(playerSx, floorY + 2), -- 1565
		34, -- 1565
		6.5, -- 1565
		Color(6, 8, 12, 178) -- 1565
	) -- 1565
	uiDraw:drawEllipse( -- 1566
		Vec2(playerSx, floorY - 14), -- 1566
		24, -- 1566
		4.5, -- 1566
		Color(16, 20, 28, 62) -- 1566
	) -- 1566
	local pose = {facing = self.hallFacing, frame = frame, layer = 3} -- 1567
	local running = moving and uiArt:tryPlaceRun( -- 1572
		"soldier", -- 1572
		"fe06_museum_zhoushu", -- 1572
		playerSx, -- 1572
		floorY + 2, -- 1572
		charW, -- 1573
		charH, -- 1573
		self.hallWalkAnim / 4, -- 1573
		pose -- 1573
	) -- 1573
	if not running and not uiArt:tryPlace( -- 1573
		slot, -- 1574
		"fe06_museum_zhoushu", -- 1574
		playerSx, -- 1574
		floorY + 2, -- 1574
		charW, -- 1574
		charH, -- 1574
		pose -- 1574
	) then -- 1574
		uiDraw:drawRect( -- 1576
			Rect(playerSx - 20, floorY + 2, 40, charH * 0.84), -- 1576
			toColor(CUFF_PALETTE.indigoBase) -- 1576
		) -- 1576
		uiDraw:drawCircle( -- 1577
			Vec2(playerSx, floorY + charH * 0.92), -- 1577
			16, -- 1577
			Color(66, 73, 76, 255) -- 1577
		) -- 1577
	end -- 1577
	if self.holstered and not inLampTurn and math.abs(self.hallWalkX - self.caseX) <= 130 then -- 1577
		local subA = clamp01(1 - math.abs(self.hallWalkX - self.caseX) / 145) * 0.86 -- 1582
		ctx.texts:put( -- 1583
			"xs", -- 1584
			"已收起随身器物", -- 1585
			caseSx, -- 1586
			floorY + 252, -- 1587
			toColor(PALETTE.textMid), -- 1588
			0.5, -- 1589
			0.5, -- 1590
			"Center", -- 1591
			0.9, -- 1592
			subA -- 1593
		) -- 1593
	end -- 1593
	if self.childEchoVisualT > 0 then -- 1593
		local echoK = 1 - clamp01(self.childEchoVisualT / 2.1) -- 1599
		local ex = math.min( -- 1600
			w - 110, -- 1600
			toScreenX(self.caseX + 310) -- 1600
		) -- 1600
		local ey = floorY + 32 -- 1601
		local ea = math.floor(math.sin(echoK * math.pi) * 165 + 0.5) -- 1602
		drawCircleRing( -- 1603
			uiInkDraw, -- 1603
			ex, -- 1603
			ey, -- 1603
			14 + echoK * 46, -- 1603
			Color(0, 0, 0, 0), -- 1603
			1.1, -- 1603
			Color(224, 214, 194, ea), -- 1603
			28 -- 1603
		) -- 1603
		drawCircleRing( -- 1604
			uiInkDraw, -- 1604
			ex, -- 1604
			ey, -- 1604
			8 + echoK * 28, -- 1604
			Color(0, 0, 0, 0), -- 1604
			0.9, -- 1604
			Color( -- 1604
				224, -- 1604
				214, -- 1604
				194, -- 1604
				math.floor(ea * 0.7 + 0.5) -- 1604
			), -- 1604
			24 -- 1604
		) -- 1604
		ctx.texts:put( -- 1605
			"xs", -- 1606
			"（远方传来轻快的孩童脚步声）", -- 1607
			w * 0.5, -- 1608
			84, -- 1609
			toColor(PALETTE.textMid), -- 1610
			0.5, -- 1611
			0.5, -- 1612
			"Center", -- 1613
			1, -- 1614
			math.sin(echoK * math.pi) * 0.85 -- 1615
		) -- 1615
	end -- 1615
	if not inLampTurn then -- 1615
		local fadeIn = smoothstep(0, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn, self.hallIntroElapsed) -- 1621
		local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold + ____exports.MUSEUM_TIMINGS.hallIntroFadeOut, self.hallIntroElapsed) -- 1622
		local introA = fadeIn * fadeOut -- 1627
		if introA > 0.02 then -- 1627
			drawSilkVeil( -- 1629
				uiDraw, -- 1629
				uiArt, -- 1629
				"fe06_hall_intro_veil", -- 1629
				w * 0.5, -- 1629
				h - 104, -- 1629
				480, -- 1629
				74, -- 1629
				PALETTE.inkVoid, -- 1629
				0.78 * introA, -- 1629
				1 -- 1629
			) -- 1629
			drawHairline( -- 1630
				uiInkDraw, -- 1630
				uiArt, -- 1630
				"fe06_hall_intro_line", -- 1630
				w * 0.5, -- 1630
				h - 106, -- 1630
				260, -- 1630
				PALETTE.silkLine, -- 1630
				0.45 * introA, -- 1630
				false, -- 1630
				4 -- 1630
			) -- 1630
			ctx.texts:put( -- 1631
				"md", -- 1631
				____exports.MUSEUM_HALL_TITLE, -- 1631
				w * 0.5, -- 1631
				h - 88, -- 1631
				toColor(PALETTE.textBright), -- 1631
				0.5, -- 1631
				0.5, -- 1631
				"Center", -- 1631
				1.8, -- 1631
				introA -- 1631
			) -- 1631
			ctx.texts:put( -- 1632
				"xs", -- 1632
				____exports.MUSEUM_HALL_SUBTITLE, -- 1632
				w * 0.5, -- 1632
				h - 122, -- 1632
				toColor(PALETTE.amberCore), -- 1632
				0.5, -- 1632
				0.5, -- 1632
				"Center", -- 1632
				1.2, -- 1632
				introA * 0.88 -- 1632
			) -- 1632
		end -- 1632
		if self.nearLamp and ctx.view.assistHintsEnabled then -- 1632
			drawSilkVeil( -- 1637
				uiDraw, -- 1637
				uiArt, -- 1637
				"fe06_lamp_hint_veil", -- 1637
				lampSx, -- 1637
				floorY + 158, -- 1637
				146, -- 1637
				28, -- 1637
				PALETTE.panelBg, -- 1637
				0.84, -- 1637
				1 -- 1637
			) -- 1637
			ctx.texts:put( -- 1638
				"xs", -- 1639
				getActiveTarget():adaptHintSentence("[E] 转动西窗灯", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1640
				lampSx, -- 1641
				floorY + 158, -- 1642
				toColor(PALETTE.textBright), -- 1643
				0.5, -- 1644
				0.5, -- 1645
				"Center", -- 1646
				0.6, -- 1647
				0.94 -- 1648
			) -- 1648
		end -- 1648
	end -- 1648
	if inLampTurn and self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1648
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
end -- 1332
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
	local revealK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.3, t) * fadeOut -- 1708
	local barH = 42 -- 1709
	local localT = math.max(0, t - ____exports.MUSEUM_TIMINGS.returnKnock2At) -- 1710
	drawComicSequence( -- 1712
		uiDraw, -- 1713
		uiInkDraw, -- 1714
		uiArt, -- 1715
		E02_RETURN_COMIC_SEQ, -- 1716
		localT, -- 1717
		w, -- 1718
		h, -- 1719
		{ -- 1720
			letterboxH = barH, -- 1721
			opacity = revealK, -- 1722
			layer = 2, -- 1723
			instancePrefix = "fe06_e02_return_comic", -- 1724
			accentBorder = true -- 1725
		} -- 1725
	) -- 1725
	if self.knock2VisualT > 0 then -- 1725
		local k2 = 1 - clamp01(self.knock2VisualT / 0.9) -- 1731
		local k2A = math.floor((1 - k2) * 195 * fadeOut + 0.5) -- 1732
		local kx = w * 0.74 -- 1733
		local ky = h * 0.34 -- 1734
		fillRadialGlow( -- 1735
			uiGlow, -- 1735
			kx, -- 1735
			ky, -- 1735
			26 + k2 * 56, -- 1735
			26 + k2 * 56, -- 1735
			Color( -- 1735
				238, -- 1735
				224, -- 1735
				194, -- 1735
				math.floor(k2A * 0.45 + 0.5) -- 1735
			), -- 1735
			Color(238, 224, 194, 0), -- 1735
			16 -- 1735
		) -- 1735
		drawCircleRing( -- 1736
			uiInkDraw, -- 1736
			kx, -- 1736
			ky, -- 1736
			12 + k2 * 58, -- 1736
			Color(0, 0, 0, 0), -- 1736
			1.4, -- 1736
			Color(232, 220, 196, k2A), -- 1736
			28 -- 1736
		) -- 1736
	end -- 1736
	local tipA = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.45, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.95, t) * fadeOut -- 1739
	if tipA > 0.03 then -- 1739
		drawSilkVeil( -- 1741
			uiDraw, -- 1741
			uiArt, -- 1741
			"fe06_return_veil", -- 1741
			w * 0.5, -- 1741
			barH + 34, -- 1741
			320, -- 1741
			32, -- 1741
			PALETTE.inkVoid, -- 1741
			0.72 * tipA, -- 1741
			6 -- 1741
		) -- 1741
		ctx.texts:put( -- 1742
			"xs", -- 1743
			"两声轻敲落回柜板 · 寻回小满", -- 1744
			w * 0.5, -- 1745
			barH + 34, -- 1746
			toColor(PALETTE.textMid), -- 1747
			0.5, -- 1748
			0.5, -- 1749
			"Center", -- 1750
			1.2, -- 1751
			tipA * 0.9 -- 1752
		) -- 1752
	end -- 1752
end -- 1687
function WellMuseumPlugin.prototype.drawLetterbox(self, draw, w, h, barH, opacity) -- 1757
	local a = math.floor(244 * clamp01(opacity) + 0.5) -- 1758
	if a <= 2 then -- 1758
		return -- 1760
	end -- 1760
	draw:drawRect( -- 1762
		Rect(0, 0, w, barH), -- 1762
		Color(6, 8, 12, a) -- 1762
	) -- 1762
	draw:drawRect( -- 1763
		Rect(0, h - barH, w, barH), -- 1763
		Color(6, 8, 12, a) -- 1763
	) -- 1763
end -- 1757
function ____exports.createWellMuseumPlugin(contract) -- 1767
	return __TS__New(____exports.WellMuseumPlugin, contract) -- 1768
end -- 1767
return ____exports -- 1767