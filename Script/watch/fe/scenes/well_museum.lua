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
--- E01 井底白灯波纹 → 指南针叠合 → 0px 光学匹配剪辑闪切 → 现代玻璃展柜 16 帧逐帧动画拍表（3.60s，峰值 8.5 fps）
local E01_MATCH_COMIC_SEQ = { -- 106
	{slot = "comic_e01_f01", start = 0, ["end"] = 0.23, transition = "cut"}, -- 107
	{slot = "comic_e01_f02", start = 0.23, ["end"] = 0.46, transition = "cut"}, -- 108
	{slot = "comic_e01_f03", start = 0.46, ["end"] = 0.69, transition = "cut"}, -- 109
	{slot = "comic_e01_f04", start = 0.69, ["end"] = 0.92, transition = "cut"}, -- 110
	{slot = "comic_e01_f05", start = 0.92, ["end"] = 1.16, transition = "cut"}, -- 111
	{slot = "comic_e01_f06", start = 1.16, ["end"] = 1.4, transition = "cut"}, -- 112
	{slot = "comic_e01_f07", start = 1.4, ["end"] = 1.66, transition = "cut"}, -- 113
	{ -- 114
		slot = "comic_e01_f08", -- 114
		start = 1.66, -- 114
		["end"] = 1.86, -- 114
		zoomFrom = 1.02, -- 114
		zoomTo = 1.02, -- 114
		transition = "cut", -- 114
		impactFlash = true, -- 114
		impactDur = 0.16, -- 114
		shakeAmp = 4.5, -- 114
		shakeFreq = 60 -- 114
	}, -- 114
	{ -- 115
		slot = "comic_e01_f09", -- 115
		start = 1.86, -- 115
		["end"] = 1.98, -- 115
		zoomFrom = 1.028, -- 115
		zoomTo = 1.028, -- 115
		transition = "cut", -- 115
		impactFlash = true, -- 115
		impactDur = 0.18, -- 115
		shakeAmp = 5.5, -- 115
		shakeFreq = 64 -- 115
	}, -- 115
	{ -- 116
		slot = "comic_e01_f10", -- 116
		start = 1.98, -- 116
		["end"] = 2.1, -- 116
		transition = "cut", -- 116
		shakeAmp = 3.5, -- 116
		shakeFreq = 56 -- 116
	}, -- 116
	{slot = "comic_e01_f11", start = 2.1, ["end"] = 2.24, transition = "cut"}, -- 117
	{slot = "comic_e01_f12", start = 2.24, ["end"] = 2.48, transition = "cut"}, -- 118
	{slot = "comic_e01_f13", start = 2.48, ["end"] = 2.74, transition = "cut"}, -- 119
	{slot = "comic_e01_f14", start = 2.74, ["end"] = 3.04, transition = "cut"}, -- 120
	{slot = "comic_e01_f15", start = 3.04, ["end"] = 3.34, transition = "cut"}, -- 121
	{slot = "comic_e01_f16", start = 3.34, ["end"] = 3.6, transition = "cut"} -- 122
} -- 122
--- E02 现代展厅西窗转灯与破晓映古井 12 帧逐帧动画拍表（4.50s）
local E02_LAMP_COMIC_SEQ = { -- 126
	{slot = "comic_e02_f01", start = 0, ["end"] = 0.2, transition = "cut"}, -- 127
	{slot = "comic_e02_f02", start = 0.2, ["end"] = 0.4, transition = "cut"}, -- 128
	{slot = "comic_e02_f03", start = 0.4, ["end"] = 0.6, transition = "cut"}, -- 129
	{slot = "comic_e02_f04", start = 0.6, ["end"] = 0.8, transition = "cut"}, -- 130
	{slot = "comic_e02_f05", start = 0.8, ["end"] = 1.02, transition = "cut"}, -- 131
	{slot = "comic_e02_f06", start = 1.02, ["end"] = 1.24, transition = "cut"}, -- 132
	{slot = "comic_e02_f07", start = 1.24, ["end"] = 1.46, transition = "cut"}, -- 133
	{slot = "comic_e02_f08", start = 1.46, ["end"] = 1.68, transition = "cut"}, -- 134
	{slot = "comic_e02_f09", start = 1.68, ["end"] = 2.25, transition = "cut"}, -- 135
	{slot = "comic_e02_f10", start = 2.25, ["end"] = 2.85, transition = "cut"}, -- 136
	{slot = "comic_e02_f11", start = 2.85, ["end"] = 3.95, transition = "cut"}, -- 137
	{slot = "comic_e02_f12", start = 3.95, ["end"] = 4.5, transition = "cut"} -- 138
} -- 138
--- E02 尾声：实木轻叩落回明初厨柜缝与四镜同源五针补线袖口 8 帧逐帧动画拍表（3.00s）
local E02_RETURN_COMIC_SEQ = { -- 142
	{slot = "comic_e02_f13", start = 0, ["end"] = 0.16, transition = "cut"}, -- 143
	{slot = "comic_e02_f14", start = 0.16, ["end"] = 0.32, transition = "cut"}, -- 144
	{slot = "comic_e02_f15", start = 0.32, ["end"] = 0.48, transition = "cut"}, -- 145
	{ -- 146
		slot = "comic_e02_f16", -- 146
		start = 0.48, -- 146
		["end"] = 0.68, -- 146
		transition = "cut", -- 146
		shakeAmp = 4.2, -- 146
		shakeFreq = 56 -- 146
	}, -- 146
	{slot = "comic_e02_f17", start = 0.68, ["end"] = 1.1, transition = "cut"}, -- 147
	{slot = "comic_e02_f18", start = 1.1, ["end"] = 1.58, transition = "cut"}, -- 148
	{slot = "comic_e02_f19", start = 1.58, ["end"] = 2.12, transition = "cut"}, -- 149
	{slot = "comic_e02_f20", start = 2.12, ["end"] = 3, transition = "cut"} -- 150
} -- 150
local function clamp(v, lo, hi) -- 207
	return math.max( -- 208
		lo, -- 208
		math.min(hi, v) -- 208
	) -- 208
end -- 207
local function clamp01(v) -- 211
	return clamp(v, 0, 1) -- 212
end -- 211
local function smoothstep(edge0, edge1, x) -- 215
	if edge1 <= edge0 then -- 215
		return x >= edge1 and 1 or 0 -- 217
	end -- 217
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 219
	return t * t * (3 - 2 * t) -- 220
end -- 215
local function drawEllipseRing(draw, cx, cy, rx, ry, fillCol, borderWidth, borderCol, segments) -- 223
	if segments == nil then -- 223
		segments = 28 -- 232
	end -- 232
	if rx <= 0.5 or ry <= 0.5 then -- 232
		return -- 235
	end -- 235
	local pts = {} -- 237
	local step = math.pi * 2 / segments -- 238
	local i = 0 -- 239
	do -- 239
		i = 0 -- 240
		while i < segments do -- 240
			local a = i * step -- 241
			pts[#pts + 1] = Vec2( -- 242
				cx + math.cos(a) * rx, -- 242
				cy + math.sin(a) * ry -- 242
			) -- 242
			i = i + 1 -- 240
		end -- 240
	end -- 240
	draw:drawPolygon(pts, fillCol, borderWidth, borderCol) -- 244
end -- 223
local function drawCircleRing(draw, cx, cy, r, fillCol, borderWidth, borderCol, segments) -- 247
	if segments == nil then -- 247
		segments = 28 -- 255
	end -- 255
	drawEllipseRing( -- 257
		draw, -- 257
		cx, -- 257
		cy, -- 257
		r, -- 257
		r, -- 257
		fillCol, -- 257
		borderWidth, -- 257
		borderCol, -- 257
		segments -- 257
	) -- 257
end -- 247
local function asRecord(v) -- 260
	if v ~= nil and type(v) == "table" then -- 260
		return v -- 262
	end -- 262
	return nil -- 264
end -- 260
local function readNum(rec, key) -- 267
	if rec == nil then -- 267
		return nil -- 269
	end -- 269
	local val = rec[key] -- 271
	return type(val) == "number" and val or nil -- 272
end -- 267
local function readBool(rec, key) -- 275
	if rec == nil then -- 275
		return nil -- 277
	end -- 277
	local val = rec[key] -- 279
	local ____temp_0 -- 280
	if type(val) == "boolean" then -- 280
		____temp_0 = val -- 280
	else -- 280
		____temp_0 = nil -- 280
	end -- 280
	return ____temp_0 -- 280
end -- 275
local function resolveRuntimeContract(injected) -- 283
	if injected ~= nil then -- 283
		return injected -- 285
	end -- 285
	local g = _G -- 287
	local ____temp_1 -- 288
	if g.package ~= nil then -- 288
		____temp_1 = g.package.loaded -- 288
	else -- 288
		____temp_1 = nil -- 288
	end -- 288
	local loaded = ____temp_1 -- 288
	if loaded == nil then -- 288
		return nil -- 290
	end -- 290
	local rawFe = loaded["watch.fe"] -- 292
	if rawFe ~= nil and type(rawFe) == "table" then -- 292
		local c = rawFe.contract -- 294
		if c ~= nil and type(c) == "table" then -- 294
			return c -- 296
		end -- 296
	end -- 296
	return nil -- 299
end -- 283
local function isPrologueIntroBlocking() -- 302
	local g = _G -- 303
	local ____temp_2 -- 304
	if g.package ~= nil then -- 304
		____temp_2 = g.package.loaded -- 304
	else -- 304
		____temp_2 = nil -- 304
	end -- 304
	local loaded = ____temp_2 -- 304
	if loaded == nil then -- 304
		return false -- 306
	end -- 306
	local rawFe = loaded["watch.fe"] -- 308
	if rawFe == nil or type(rawFe) ~= "table" then -- 308
		return false -- 310
	end -- 310
	local prologue = rawFe.prologue -- 312
	if prologue == nil or type(prologue) ~= "table" then -- 312
		return false -- 314
	end -- 314
	local fn = prologue.getSnapshot -- 316
	if type(fn) ~= "function" then -- 316
		return false -- 318
	end -- 318
	local snap = asRecord(fn(prologue)) -- 320
	if readBool(snap, "blocksPlayerControl") == true then -- 320
		return true -- 322
	end -- 322
	local stage = snap ~= nil and type(snap.stage) == "string" and snap.stage or "idle" -- 325
	return stage == "p02_escape" or stage == "p02_hidden" -- 326
end -- 302
local function isActiveMuseumPhase(phase) -- 329
	return phase == "well_reflect" or phase == "hall_walk" or phase == "lamp_turn" or phase == "return_cabinet" -- 330
end -- 329
____exports.WellMuseumPlugin = __TS__Class() -- 336
local WellMuseumPlugin = ____exports.WellMuseumPlugin -- 336
WellMuseumPlugin.name = "WellMuseumPlugin" -- 336
function WellMuseumPlugin.prototype.____constructor(self, contract) -- 402
	self.id = "fe-06-well-museum" -- 337
	self.animTime = 0 -- 340
	self.prevPhase = "locked" -- 341
	self.roomSessionId = 0 -- 342
	self.rehearsal = false -- 343
	self.gateOpen = false -- 346
	self.gateBlockedReason = "locked" -- 347
	self.wellWorldX = ____exports.WELL_WORLD_X -- 348
	self.caseX = ____exports.MUSEUM_CASE_X -- 349
	self.lampX = ____exports.MUSEUM_LAMP_X -- 350
	self.nearWell = false -- 351
	self.revisitCalmTimer = 0 -- 352
	self.revisitCalmCount = 0 -- 353
	self.reflectElapsed = 0 -- 356
	self.wellAnchorX = 640 -- 357
	self.wellAnchorY = 388.8 -- 358
	self.glassAnchorX = 640 -- 359
	self.glassAnchorY = 388.8 -- 360
	self.enterHallSubmitted = false -- 361
	self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 364
	self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 365
	self.hallFacing = 1 -- 366
	self.hallWalkAnim = 0 -- 367
	self.hallMoving = false -- 368
	self.hallFootstepTimer = 0 -- 369
	self.hallIntroElapsed = 0 -- 370
	self.holstered = false -- 371
	self.childEchoCountdown = -1 -- 372
	self.childEchoPlayed = false -- 373
	self.childEchoVisualT = 0 -- 374
	self.nearLamp = false -- 375
	self.lampElapsed = 0 -- 377
	self.lineDawnShown = false -- 378
	self.knock1Played = false -- 379
	self.knock1VisualT = 0 -- 380
	self.beginReturnSubmitted = false -- 381
	self.returnElapsed = 0 -- 384
	self.knock2Played = false -- 385
	self.knock2VisualT = 0 -- 386
	self.returnCompleteSubmitted = false -- 387
	self.artifactGrantCount = 0 -- 390
	self.resumeRestoreCount = 0 -- 392
	self.lastResumePhase = "locked" -- 393
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 394
	self.lastVisualMode = "pixel" -- 395
	self.lastPaused = false -- 396
	self.wellDripPlaying = false -- 397
	self.hallAmbiencePlaying = false -- 398
	self.liveReflectDoneInMuseumRoom = false -- 399
	self.injectedContract = contract -- 403
end -- 402
function WellMuseumPlugin.prototype.syncRuntimeHook(self) -- 406
	local g = _G -- 407
	local ____temp_3 -- 408
	if g.package ~= nil then -- 408
		____temp_3 = g.package.loaded -- 408
	else -- 408
		____temp_3 = nil -- 408
	end -- 408
	local loaded = ____temp_3 -- 408
	if loaded == nil then -- 408
		return -- 410
	end -- 410
	local rawFe = loaded["watch.fe"] -- 412
	if rawFe ~= nil and type(rawFe) == "table" then -- 412
		local watchFe = rawFe -- 414
		if watchFe.wellMuseum ~= self then -- 414
			watchFe.wellMuseum = self -- 416
		end -- 416
	end -- 416
end -- 406
function WellMuseumPlugin.prototype.queueSimulatedInput(self, sim) -- 422
	self.simInput = {moveX = sim.moveX, interact = sim.interact} -- 423
end -- 422
function WellMuseumPlugin.prototype.exportResumeState(self) -- 430
	return { -- 431
		phase = self.prevPhase, -- 432
		hallWalkX = self.hallWalkX, -- 433
		hallCamX = self.hallCamX, -- 434
		hallFacing = self.hallFacing, -- 435
		holstered = self.holstered, -- 436
		childEchoPlayed = self.childEchoPlayed, -- 437
		reflectElapsed = self.reflectElapsed, -- 438
		lampElapsed = self.lampElapsed, -- 439
		returnElapsed = self.returnElapsed, -- 440
		artifactGrantCount = self.artifactGrantCount -- 441
	} -- 441
end -- 430
function WellMuseumPlugin.prototype.restoreResumeState(self, snap) -- 446
	if snap.phase ~= nil then -- 446
		self.prevPhase = snap.phase -- 448
		self.lastResumePhase = snap.phase -- 449
	end -- 449
	if snap.hallWalkX ~= nil then -- 449
		self.hallWalkX = clamp(snap.hallWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 452
		self.lastResumeWalkX = self.hallWalkX -- 453
	end -- 453
	if snap.hallCamX ~= nil then -- 453
		self.hallCamX = snap.hallCamX -- 456
	else -- 456
		self.hallCamX = self.hallWalkX -- 458
	end -- 458
	if snap.hallFacing ~= nil then -- 458
		self.hallFacing = snap.hallFacing >= 0 and 1 or -1 -- 461
	end -- 461
	if snap.holstered ~= nil then -- 461
		self.holstered = snap.holstered -- 464
	end -- 464
	if snap.childEchoPlayed ~= nil then -- 464
		self.childEchoPlayed = snap.childEchoPlayed -- 467
	end -- 467
	if snap.reflectElapsed ~= nil then -- 467
		self.reflectElapsed = math.max(0, snap.reflectElapsed) -- 470
	end -- 470
	if snap.lampElapsed ~= nil then -- 470
		self.lampElapsed = math.max(0, snap.lampElapsed) -- 473
	end -- 473
	if snap.returnElapsed ~= nil then -- 473
		self.returnElapsed = math.max(0, snap.returnElapsed) -- 476
	end -- 476
	if snap.artifactGrantCount ~= nil then -- 476
		self.artifactGrantCount = math.max(0, snap.artifactGrantCount) -- 479
	end -- 479
	self.savedResume = self:exportResumeState() -- 481
	self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 482
end -- 446
function WellMuseumPlugin.prototype.resetSessionCounters(self) -- 486
	self.artifactGrantCount = 0 -- 487
	self.revisitCalmCount = 0 -- 488
	self.revisitCalmTimer = 0 -- 489
	self.savedResume = nil -- 490
	self.resumeRestoreCount = 0 -- 491
	self.lastResumePhase = "locked" -- 492
	self.lastResumeWalkX = ____exports.MUSEUM_ENTRY_X -- 493
end -- 486
function WellMuseumPlugin.prototype.setHallWalkPosition(self, x, holstered) -- 497
	self.hallWalkX = clamp(x, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 498
	self.hallCamX = self.hallWalkX -- 499
	if holstered ~= nil then -- 499
		self.holstered = holstered -- 501
	elseif self.hallWalkX >= self.caseX - 85 then -- 501
		self.holstered = true -- 503
	end -- 503
	self.savedResume = self:exportResumeState() -- 505
end -- 497
function WellMuseumPlugin.prototype.seekStageTime(self, stage, seconds) -- 509
	local s = math.max(0, seconds) -- 510
	if stage == "well_reflect" then -- 510
		self.reflectElapsed = math.min(____exports.MUSEUM_TIMINGS.wellReflectDuration, s) -- 512
	elseif stage == "lamp_turn" then -- 512
		self.lampElapsed = math.min(____exports.MUSEUM_TIMINGS.lampTurnDuration, s) -- 514
		self.lineDawnShown = self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt -- 515
	elseif stage == "return_cabinet" then -- 515
		self.returnElapsed = math.min(____exports.MUSEUM_TIMINGS.returnCabinetDuration, s) -- 517
	end -- 517
end -- 509
function WellMuseumPlugin.prototype.getDebugState(self) -- 521
	local reflectProg = clamp01(self.reflectElapsed / ____exports.MUSEUM_TIMINGS.wellReflectDuration) -- 522
	local matchStart = ____exports.MUSEUM_TIMINGS.wellMatchCutStart -- 523
	local matchSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.wellReflectDuration - matchStart) -- 524
	local matchProg = self.reflectElapsed <= matchStart and 0 or clamp01((self.reflectElapsed - matchStart) / matchSpan) -- 525
	local lampTurnProg = clamp01(self.lampElapsed / 1.15) -- 528
	local cuffStart = ____exports.MUSEUM_TIMINGS.returnKnock2At -- 529
	local cuffSpan = math.max(0.01, ____exports.MUSEUM_TIMINGS.returnFadeOutAt - cuffStart) -- 530
	local cuffProg = self.returnElapsed <= cuffStart and 0 or clamp01((self.returnElapsed - cuffStart) / cuffSpan) -- 531
	local dx = self.glassAnchorX - self.wellAnchorX -- 534
	local dy = self.glassAnchorY - self.wellAnchorY -- 535
	return { -- 536
		gateOpen = self.gateOpen, -- 537
		gateBlockedReason = self.gateBlockedReason, -- 538
		wellWorldX = self.wellWorldX, -- 539
		nearWell = self.nearWell, -- 540
		museumPhase = self.prevPhase, -- 541
		visualMode = self.lastVisualMode, -- 542
		reflectElapsed = self.reflectElapsed, -- 543
		reflectProgress = reflectProg, -- 544
		matchCutProgress = matchProg, -- 545
		wellAnchorX = self.wellAnchorX, -- 546
		wellAnchorY = self.wellAnchorY, -- 547
		glassAnchorX = self.glassAnchorX, -- 548
		glassAnchorY = self.glassAnchorY, -- 549
		matchCutAnchorDeltaPx = math.sqrt(dx * dx + dy * dy), -- 550
		hallWalkX = self.hallWalkX, -- 551
		hallCamX = self.hallCamX, -- 552
		holstered = self.holstered, -- 553
		childEchoPlayed = self.childEchoPlayed, -- 554
		nearLamp = self.nearLamp, -- 555
		lampElapsed = self.lampElapsed, -- 556
		lampTurnProgress = lampTurnProg, -- 557
		lineDawnShown = self.lineDawnShown, -- 558
		knock1Played = self.knock1Played, -- 559
		knock2Played = self.knock2Played, -- 560
		returnElapsed = self.returnElapsed, -- 561
		cuffReusedFromSharedPalette = true, -- 562
		cuffProgress = cuffProg, -- 563
		artifactGrantCount = self.artifactGrantCount, -- 564
		revisitCalmCount = self.revisitCalmCount, -- 565
		resumeRestoreCount = self.resumeRestoreCount, -- 566
		lastResumePhase = self.lastResumePhase, -- 567
		lastResumeWalkX = self.lastResumeWalkX, -- 568
		pausedFrozen = self.lastPaused -- 569
	} -- 569
end -- 521
function WellMuseumPlugin.prototype.onBindPlay(self, p, view) -- 573
	self:syncRuntimeHook() -- 574
	if view.isRehearsal ~= self.rehearsal then -- 574
		self.savedResume = nil -- 576
	end -- 576
	self.rehearsal = view.isRehearsal -- 578
	local ____view_isRehearsal_6 -- 579
	if view.isRehearsal then -- 579
		____view_isRehearsal_6 = nil -- 579
	else -- 579
		local ____opt_4 = p.room.story -- 579
		____view_isRehearsal_6 = ____opt_4 and ____opt_4.museum -- 579
	end -- 579
	local museum = ____view_isRehearsal_6 -- 579
	self.caseX = museum == nil and ____exports.MUSEUM_CASE_X or museum.cabinetX - p.ox -- 580
	self.lampX = museum == nil and ____exports.MUSEUM_LAMP_X or museum.lampX - p.ox -- 581
	self.animTime = 0 -- 582
	self.revisitCalmTimer = 0 -- 583
	self.childEchoVisualT = 0 -- 584
	self.knock1VisualT = 0 -- 585
	self.knock2VisualT = 0 -- 586
	self.wellDripPlaying = false -- 587
	self.hallAmbiencePlaying = false -- 588
	self.enterHallSubmitted = false -- 589
	self.beginReturnSubmitted = false -- 590
	self.returnCompleteSubmitted = false -- 591
	self.liveReflectDoneInMuseumRoom = false -- 592
	self.simInput = nil -- 593
	local phase = view.archive.museumPhase -- 595
	self.prevPhase = phase -- 596
	self.lastVisualMode = view.visualMode -- 597
	local pRec = asRecord(p) -- 601
	local backendWellX = readNum(pRec, "wellX") -- 602
	self.wellWorldX = backendWellX ~= nil and p.ox + backendWellX or p.ox + ____exports.WELL_WORLD_X -- 603
	self.hallMoving = false -- 604
	if view.archive.childCleared and view.archive.soldierCleared and view.archive.artifactOwned then -- 604
		if self.artifactGrantCount < 1 then -- 604
			self.artifactGrantCount = 1 -- 609
		end -- 609
	elseif not view.archive.artifactOwned then -- 609
		self.artifactGrantCount = 0 -- 612
	end -- 612
	if isActiveMuseumPhase(phase) then -- 612
		local ____view_isRehearsal_7 -- 617
		if view.isRehearsal then -- 617
			____view_isRehearsal_7 = nil -- 617
		else -- 617
			____view_isRehearsal_7 = asRecord(p.run) -- 617
		end -- 617
		local runRec = ____view_isRehearsal_7 -- 617
		local ____asRecord_9 = asRecord -- 618
		local ____temp_8 -- 618
		if pRec ~= nil then -- 618
			____temp_8 = pRec.archive -- 618
		else -- 618
			____temp_8 = nil -- 618
		end -- 618
		local ____asRecord_9_result_12 = ____asRecord_9(____temp_8) -- 618
		if ____asRecord_9_result_12 == nil then -- 618
			local ____asRecord_11 = asRecord -- 619
			local ____temp_10 -- 619
			if runRec ~= nil then -- 619
				____temp_10 = runRec.archive -- 619
			else -- 619
				____temp_10 = nil -- 619
			end -- 619
			____asRecord_9_result_12 = ____asRecord_11(____temp_10) -- 618
		end -- 618
		local archRec = ____asRecord_9_result_12 -- 618
		local backendWalkX = readNum(archRec, "museumWalkX") or readNum(pRec, "museumWalkX") -- 620
		local ____readBool_result_13 = readBool(archRec, "museumHolstered") -- 621
		if ____readBool_result_13 == nil then -- 621
			____readBool_result_13 = readBool(pRec, "museumHolstered") -- 621
		end -- 621
		local backendHolstered = ____readBool_result_13 -- 621
		local ____readBool_result_14 = readBool(archRec, "museumChildEchoPlayed") -- 622
		if ____readBool_result_14 == nil then -- 622
			____readBool_result_14 = readBool(pRec, "museumChildEchoPlayed") -- 622
		end -- 622
		local backendChildEcho = ____readBool_result_14 -- 622
		if self.savedResume ~= nil and self.savedResume.phase == phase then -- 622
			self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.savedResume.hallWalkX -- 625
			self.hallCamX = self.hallWalkX -- 626
			self.hallFacing = self.savedResume.hallFacing -- 627
			local ____backendHolstered_15 = backendHolstered -- 628
			if ____backendHolstered_15 == nil then -- 628
				____backendHolstered_15 = self.savedResume.holstered -- 628
			end -- 628
			self.holstered = ____backendHolstered_15 -- 628
			local ____backendChildEcho_16 = backendChildEcho -- 629
			if ____backendChildEcho_16 == nil then -- 629
				____backendChildEcho_16 = self.savedResume.childEchoPlayed -- 629
			end -- 629
			self.childEchoPlayed = ____backendChildEcho_16 -- 629
			self.reflectElapsed = self.savedResume.reflectElapsed -- 630
			self.lampElapsed = self.savedResume.lampElapsed -- 631
			self.returnElapsed = self.savedResume.returnElapsed -- 632
		else -- 632
			self:resetPhaseTimersForEntry(phase, backendWalkX, backendHolstered, backendChildEcho) -- 634
		end -- 634
		self.resumeRestoreCount = self.resumeRestoreCount + 1 -- 636
		self.lastResumePhase = phase -- 637
		self.lastResumeWalkX = self.hallWalkX -- 638
	else -- 638
		self.reflectElapsed = 0 -- 641
		self.lampElapsed = 0 -- 642
		self.returnElapsed = 0 -- 643
		self.hallIntroElapsed = 0 -- 644
		self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 645
		self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 646
		self.hallFacing = 1 -- 647
		self.holstered = false -- 648
		self.childEchoCountdown = -1 -- 649
		self.childEchoPlayed = false -- 650
		self.lineDawnShown = false -- 651
		self.knock1Played = false -- 652
		self.knock2Played = false -- 653
		if phase == "locked" or phase == "well_open" then -- 653
			self.savedResume = nil -- 655
		end -- 655
	end -- 655
end -- 573
function WellMuseumPlugin.prototype.resetPhaseTimersForEntry(self, phase, backendWalkX, backendHolstered, backendChildEcho) -- 660
	if phase == "well_reflect" then -- 660
		self.reflectElapsed = 0 -- 667
		self.enterHallSubmitted = false -- 668
		return -- 669
	end -- 669
	if phase == "hall_walk" then -- 669
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or ____exports.MUSEUM_ENTRY_X -- 672
		self.hallCamX = self.hallWalkX -- 673
		self.hallFacing = 1 -- 674
		self.hallIntroElapsed = backendWalkX ~= nil and backendWalkX > 260 and 5 or 0 -- 675
		local ____backendHolstered_17 = backendHolstered -- 676
		if ____backendHolstered_17 == nil then -- 676
			____backendHolstered_17 = self.hallWalkX >= self.caseX - 85 -- 676
		end -- 676
		self.holstered = ____backendHolstered_17 -- 676
		local ____backendChildEcho_18 = backendChildEcho -- 677
		if ____backendChildEcho_18 == nil then -- 677
			____backendChildEcho_18 = self.hallWalkX >= self.caseX + 120 -- 677
		end -- 677
		self.childEchoPlayed = ____backendChildEcho_18 -- 677
		self.childEchoCountdown = -1 -- 678
		return -- 679
	end -- 679
	if phase == "lamp_turn" then -- 679
		self.hallWalkX = backendWalkX ~= nil and clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) or self.lampX - 36 -- 682
		self.hallCamX = self.hallWalkX -- 683
		self.hallFacing = 1 -- 684
		self.holstered = true -- 685
		self.childEchoPlayed = true -- 686
		self.lampElapsed = 0 -- 687
		self.lineDawnShown = false -- 688
		self.knock1Played = false -- 689
		self.beginReturnSubmitted = false -- 690
		return -- 691
	end -- 691
	if phase == "return_cabinet" then -- 691
		self.returnElapsed = 0 -- 694
		self.knock2Played = false -- 695
		self.returnCompleteSubmitted = false -- 696
	end -- 696
end -- 660
function WellMuseumPlugin.prototype.evaluateGate(self, p, view) -- 700
	if p.run.source == "chapter" then -- 700
		return {open = false, reason = "chapter_preview"} -- 702
	end -- 702
	if p.room.key ~= "prologue" then -- 702
		return {open = false, reason = "not_prologue"} -- 705
	end -- 705
	if p.phase ~= "prologue-wait" and p.phase ~= "prologue-well" then -- 705
		return {open = false, reason = "after_cabinet_window"} -- 708
	end -- 708
	if isPrologueIntroBlocking() then -- 708
		return {open = false, reason = "prologue_intro_active"} -- 711
	end -- 711
	if not view.archive.childCleared or not view.archive.soldierCleared then -- 711
		return {open = false, reason = "requires_both_clear"} -- 715
	end -- 715
	if view.archive.museumPhase == "locked" then -- 715
		return {open = false, reason = "phase_locked"} -- 718
	end -- 718
	return {open = true, reason = "ok"} -- 720
end -- 700
function WellMuseumPlugin.prototype.submitMuseumIntent(self, p, target) -- 723
	local contract = resolveRuntimeContract(self.injectedContract) -- 724
	if contract == nil then -- 724
		return false -- 726
	end -- 726
	local intent = {kind = "museumInteract", target = target} -- 728
	return contract:submitIntent(p, intent) -- 729
end -- 723
function WellMuseumPlugin.prototype.syncLoops(self, ctx, wantWellDrip, dripVolume, wantHallAmbience) -- 732
	if wantWellDrip then -- 732
		ctx.audio:playLoop( -- 734
			LOOP_WELL_DRIP, -- 734
			"water", -- 734
			____exports.MUSEUM_AUDIO.wellDripLoop, -- 734
			dripVolume, -- 734
			ctx.p.ticks -- 734
		) -- 734
		self.wellDripPlaying = true -- 735
	elseif self.wellDripPlaying then -- 735
		ctx.audio:stopLoop(LOOP_WELL_DRIP) -- 737
		self.wellDripPlaying = false -- 738
	end -- 738
	if wantHallAmbience then -- 738
		ctx.audio:playLoop( -- 742
			LOOP_HALL_AMBIENCE, -- 742
			"ambience", -- 742
			____exports.MUSEUM_AUDIO.hallAmbienceLoop, -- 742
			0.34, -- 742
			ctx.p.ticks -- 742
		) -- 742
		self.hallAmbiencePlaying = true -- 743
	elseif self.hallAmbiencePlaying then -- 743
		ctx.audio:stopLoop(LOOP_HALL_AMBIENCE) -- 745
		self.hallAmbiencePlaying = false -- 746
	end -- 746
end -- 732
function WellMuseumPlugin.prototype.update(self, ctx) -- 750
	self:syncRuntimeHook() -- 751
	local p = ctx.p -- 752
	local view = ctx.view -- 753
	local phase = view.archive.museumPhase -- 754
	if view.isRehearsal ~= self.rehearsal then -- 754
		self:syncLoops(ctx, false, 0, false) -- 756
		self:onBindPlay(p, view) -- 757
	end -- 757
	self.roomSessionId = ctx.events.roomSessionId -- 759
	self.lastVisualMode = view.visualMode -- 760
	self.lastPaused = ctx.paused -- 761
	self.wellAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 764
	self.wellAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 765
	self.glassAnchorX = ctx.uiW * ____exports.MATCH_CUT_ANCHOR_NX -- 766
	self.glassAnchorY = ctx.uiH * ____exports.MATCH_CUT_ANCHOR_NY -- 767
	local sim = self.simInput -- 770
	self.simInput = nil -- 771
	local interactPressed = ctx.input.interact.pressed or ctx.input.frameInteractPressed or sim ~= nil and sim.interact == true -- 772
	local moveX = sim ~= nil and sim.moveX ~= nil and sim.moveX or ctx.input.moveX -- 775
	if phase ~= self.prevPhase then -- 775
		local wasActive = isActiveMuseumPhase(self.prevPhase) -- 779
		self.prevPhase = phase -- 780
		if isActiveMuseumPhase(phase) then -- 780
			if phase == "well_reflect" then -- 780
				self:resetPhaseTimersForEntry("well_reflect") -- 783
				if view.archive.artifactOwned and self.artifactGrantCount < 1 then -- 783
					self.artifactGrantCount = 1 -- 785
				end -- 785
			elseif phase == "hall_walk" and not wasActive then -- 785
				self:resetPhaseTimersForEntry("hall_walk") -- 788
			elseif phase == "hall_walk" and wasActive then -- 788
				self.hallWalkX = ____exports.MUSEUM_ENTRY_X -- 790
				self.hallCamX = ____exports.MUSEUM_ENTRY_X -- 791
				self.hallFacing = 1 -- 792
				self.hallIntroElapsed = 0 -- 793
				self.holstered = false -- 794
				self.childEchoPlayed = false -- 795
				self.childEchoCountdown = -1 -- 796
			elseif phase == "lamp_turn" then -- 796
				self:resetPhaseTimersForEntry("lamp_turn", self.hallWalkX, true, self.childEchoPlayed) -- 798
			elseif phase == "return_cabinet" then -- 798
				self:resetPhaseTimersForEntry("return_cabinet") -- 800
			end -- 800
		elseif phase == "done" then -- 800
			self.savedResume = nil -- 803
		end -- 803
	end -- 803
	local gate = self:evaluateGate(p, view) -- 807
	self.gateOpen = gate.open -- 808
	self.gateBlockedReason = gate.reason -- 809
	self.nearWell = gate.open and math.abs(p.player.x - self.wellWorldX) <= ____exports.WELL_INTERACT_REACH -- 810
	if ctx.paused then -- 810
		return -- 814
	end -- 814
	local wdt = math.max(0, ctx.worldDt) -- 817
	local udt = math.max(0, ctx.uiDt) -- 818
	self.animTime = self.animTime + wdt -- 819
	if self.revisitCalmTimer > 0 then -- 819
		self.revisitCalmTimer = math.max(0, self.revisitCalmTimer - wdt) -- 822
	end -- 822
	if self.childEchoVisualT > 0 then -- 822
		self.childEchoVisualT = math.max(0, self.childEchoVisualT - udt) -- 825
	end -- 825
	if self.knock1VisualT > 0 then -- 825
		self.knock1VisualT = math.max(0, self.knock1VisualT - wdt) -- 828
	end -- 828
	if self.knock2VisualT > 0 then -- 828
		self.knock2VisualT = math.max(0, self.knock2VisualT - wdt) -- 831
	end -- 831
	if view.visualMode ~= "museum" then -- 831
		local wantDrip = gate.open and phase == "well_open" and not view.archive.museumSeen -- 836
		local dist = math.abs(p.player.x - self.wellWorldX) -- 837
		local dripVol = clamp(0.46 - dist * 0.0014, 0.08, 0.46) -- 838
		self:syncLoops(ctx, wantDrip, dripVol, false) -- 839
		if gate.open and self.nearWell and interactPressed then -- 839
			local liveNeedsSecondEnter = not view.isRehearsal and p.room.key == "prologue" and view.archive.artifactOwned and not view.archive.museumSeen -- 842
			local alreadyAwarded = not liveNeedsSecondEnter and (view.archive.museumSeen or phase == "done" or view.archive.artifactOwned and self.artifactGrantCount >= 1) -- 846
			if (phase == "well_open" or liveNeedsSecondEnter) and not alreadyAwarded then -- 846
				self:submitMuseumIntent(p, "well_pickup") -- 851
			else -- 851
				self.revisitCalmTimer = 1.4 -- 854
				self.revisitCalmCount = self.revisitCalmCount + 1 -- 855
			end -- 855
		end -- 855
		return -- 858
	end -- 858
	local effectivePhase = p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 862
	if effectivePhase == "well_reflect" then -- 862
		local dripVol = clamp( -- 867
			0.44 * (1 - smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, self.reflectElapsed)), -- 867
			0, -- 867
			0.44 -- 867
		) -- 867
		self:syncLoops(ctx, dripVol > 0.03, dripVol, false) -- 868
		if wdt > 0 then -- 868
			self.reflectElapsed = self.reflectElapsed + wdt -- 871
		end -- 871
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellPickupAt then -- 871
			if self.artifactGrantCount < 1 then -- 871
				self.artifactGrantCount = 1 -- 875
			end -- 875
			ctx.audio:playOnce( -- 877
				"fe06:e01:pickup:" .. tostring(self.roomSessionId), -- 878
				"sfx", -- 879
				____exports.MUSEUM_AUDIO.artifactPickup, -- 880
				0.86, -- 881
				"museum:e01:artifact_pickup", -- 882
				p.ticks -- 883
			) -- 883
		end -- 883
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellMatchCutStart then -- 883
			ctx.audio:playOnce( -- 887
				"fe06:e01:matchcut:" .. tostring(self.roomSessionId), -- 888
				"ambience", -- 889
				____exports.MUSEUM_AUDIO.matchCutTransition, -- 890
				0.78, -- 891
				"museum:e01:match_cut", -- 892
				p.ticks -- 893
			) -- 893
		end -- 893
		self.savedResume = self:exportResumeState() -- 896
		if self.reflectElapsed >= ____exports.MUSEUM_TIMINGS.wellReflectDuration and not self.enterHallSubmitted then -- 896
			self.enterHallSubmitted = true -- 898
			if p.room.key == "museum" then -- 898
				self.liveReflectDoneInMuseumRoom = true -- 900
			end -- 900
			self:submitMuseumIntent(p, "enter_hall") -- 902
			local contract = resolveRuntimeContract(self.injectedContract) -- 903
			if contract ~= nil and contract:isRehearsal() then -- 903
				contract:enterMockMuseum("hall_walk") -- 905
			end -- 905
		end -- 905
		return -- 908
	end -- 908
	if effectivePhase == "hall_walk" then -- 908
		self:syncLoops(ctx, false, 0, true) -- 913
		self.hallIntroElapsed = self.hallIntroElapsed + udt -- 914
		local ____view_isRehearsal_19 -- 918
		if view.isRehearsal then -- 918
			____view_isRehearsal_19 = nil -- 918
		else -- 918
			____view_isRehearsal_19 = asRecord(p) -- 918
		end -- 918
		local pRec = ____view_isRehearsal_19 -- 918
		local backendWalkX = readNum(pRec, "museumWalkX") or (not view.isRehearsal and p.room.key == "museum" and p.player.x - p.ox or nil) -- 919
		self.hallMoving = false -- 921
		local previousX = self.hallWalkX -- 922
		if backendWalkX ~= nil then -- 922
			self.hallWalkX = clamp(backendWalkX, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 924
		elseif udt > 0 and math.abs(moveX) > 0.05 then -- 924
			self.hallWalkX = clamp(self.hallWalkX + moveX * ____exports.MUSEUM_WALK_SPEED * udt, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 926
		end -- 926
		local delta = self.hallWalkX - previousX -- 928
		if math.abs(delta) > 0.01 then -- 928
			self.hallFacing = delta >= 0 and 1 or -1 -- 930
			self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 931
			self.hallMoving = true -- 932
			self.hallFootstepTimer = self.hallFootstepTimer + udt -- 933
			if self.hallFootstepTimer >= 0.46 then -- 933
				self.hallFootstepTimer = 0 -- 935
				ctx.audio:playOnce( -- 936
					(("fe06:e02:step:" .. tostring(self.roomSessionId)) .. ":") .. tostring(math.floor(self.hallWalkAnim * 2)), -- 937
					"sfx", -- 938
					____exports.MUSEUM_AUDIO.hallFootstep, -- 939
					0.46, -- 940
					"museum:e02:footstep", -- 941
					p.ticks -- 942
				) -- 942
			end -- 942
		else -- 942
			self.hallFootstepTimer = math.min(self.hallFootstepTimer, 0.22) -- 946
		end -- 946
		local camFollow = math.min(1, udt * 5.2) -- 950
		self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * camFollow -- 951
		local holsterThreshold = p.room.key == "museum" and self.caseX + 12 or self.caseX - 85 -- 954
		if not self.holstered and self.hallWalkX >= holsterThreshold then -- 954
			self.holstered = true -- 956
			ctx.audio:playOnce( -- 957
				"fe06:e02:holster:" .. tostring(self.roomSessionId), -- 958
				"sfx", -- 959
				____exports.MUSEUM_AUDIO.weaponHolster, -- 960
				0.76, -- 961
				"museum:e02:weapon_holster", -- 962
				p.ticks -- 963
			) -- 963
			if not self.childEchoPlayed then -- 963
				self.childEchoCountdown = ____exports.MUSEUM_TIMINGS.childEchoDelay -- 966
			end -- 966
		end -- 966
		if self.childEchoCountdown >= 0 and not self.childEchoPlayed then -- 966
			self.childEchoCountdown = self.childEchoCountdown - udt -- 971
			if self.childEchoCountdown <= 0 then -- 971
				self.childEchoCountdown = -1 -- 973
				self.childEchoPlayed = true -- 974
				self.childEchoVisualT = 2.1 -- 975
				ctx.audio:playOnce( -- 976
					"fe06:e02:child_echo:" .. tostring(self.roomSessionId), -- 977
					"sfx", -- 978
					____exports.MUSEUM_AUDIO.childStepsEcho, -- 979
					0.72, -- 980
					"museum:e02:child_steps_echo", -- 981
					p.ticks -- 982
				) -- 982
			end -- 982
		end -- 982
		local ____view_isRehearsal_20 -- 987
		if view.isRehearsal then -- 987
			____view_isRehearsal_20 = math.abs(self.hallWalkX - self.lampX) <= 72 -- 988
		else -- 988
			____view_isRehearsal_20 = (p.phase == "museum-hall" or p.phase == "museum-lamp") and math.abs(p.player.x - (self.lampX + p.ox)) <= 72 -- 989
		end -- 989
		self.nearLamp = ____view_isRehearsal_20 -- 987
		self.savedResume = self:exportResumeState() -- 991
		if self.nearLamp and interactPressed then -- 991
			self:submitMuseumIntent(p, "lamp_turn") -- 994
		end -- 994
		return -- 996
	end -- 996
	if effectivePhase == "lamp_turn" then -- 996
		self:syncLoops(ctx, false, 0, true) -- 1001
		if wdt > 0 then -- 1001
			self.lampElapsed = self.lampElapsed + wdt -- 1003
		end -- 1003
		if p.room.key == "museum" then -- 1003
			local targetX = clamp(p.player.x - p.ox, 90, ____exports.MUSEUM_HALL_WIDTH - 90) -- 1007
			local delta = targetX - self.hallWalkX -- 1008
			self.hallMoving = math.abs(delta) > 0.25 -- 1009
			if self.hallMoving then -- 1009
				self.hallFacing = delta >= 0 and 1 or -1 -- 1011
				self.hallWalkAnim = self.hallWalkAnim + udt * 8.5 -- 1012
			end -- 1012
			self.hallWalkX = targetX -- 1014
			self.hallCamX = self.hallCamX + (self.hallWalkX - self.hallCamX) * math.min(1, udt * 5.2) -- 1015
		end -- 1015
		ctx.audio:playOnce( -- 1017
			"fe06:e02:lamp_turn:" .. tostring(self.roomSessionId), -- 1018
			"sfx", -- 1019
			____exports.MUSEUM_AUDIO.lampTurn, -- 1020
			0.82, -- 1021
			"museum:e02:lamp_turn", -- 1022
			p.ticks -- 1023
		) -- 1023
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1023
			self.lineDawnShown = true -- 1026
			ctx.audio:playOnce( -- 1027
				"fe06:e02:line_dawn:" .. tostring(self.roomSessionId), -- 1028
				"voice", -- 1029
				____exports.MUSEUM_AUDIO.lineDawn, -- 1030
				0.92, -- 1031
				"museum:e02:line_dawn", -- 1032
				p.ticks -- 1033
			) -- 1033
		end -- 1033
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampKnock1At and not self.knock1Played then -- 1033
			self.knock1Played = true -- 1037
			self.knock1VisualT = 0.85 -- 1038
			ctx.audio:playOnce( -- 1039
				"fe06:e02:knock1:" .. tostring(self.roomSessionId), -- 1040
				"sfx", -- 1041
				____exports.MUSEUM_AUDIO.knockHallFirst, -- 1042
				0.88, -- 1043
				"museum:knock:1", -- 1044
				p.ticks -- 1045
			) -- 1045
		end -- 1045
		self.savedResume = self:exportResumeState() -- 1048
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampTurnDuration and not self.beginReturnSubmitted then -- 1048
			self.beginReturnSubmitted = true -- 1051
			self:submitMuseumIntent(p, "begin_return_cabinet") -- 1052
			local contract = resolveRuntimeContract(self.injectedContract) -- 1053
			if contract ~= nil and contract:isRehearsal() then -- 1053
				contract:enterMockMuseum("return_cabinet") -- 1055
			end -- 1055
		end -- 1055
		return -- 1058
	end -- 1058
	if phase == "return_cabinet" then -- 1058
		self:syncLoops(ctx, false, 0, false) -- 1063
		if wdt > 0 then -- 1063
			self.returnElapsed = self.returnElapsed + wdt -- 1065
		end -- 1065
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnKnock2At and not self.knock2Played then -- 1065
			self.knock2Played = true -- 1068
			self.knock2VisualT = 0.9 -- 1069
			ctx.audio:playOnce( -- 1070
				"fe06:e02:knock2:" .. tostring(self.roomSessionId), -- 1071
				"sfx", -- 1072
				____exports.MUSEUM_AUDIO.knockCabinetSecond, -- 1073
				0.92, -- 1074
				"museum:knock:2", -- 1075
				p.ticks -- 1076
			) -- 1076
		end -- 1076
		self.savedResume = self:exportResumeState() -- 1079
		if self.returnElapsed >= ____exports.MUSEUM_TIMINGS.returnCabinetDuration and not self.returnCompleteSubmitted then -- 1079
			self.returnCompleteSubmitted = true -- 1082
			self:submitMuseumIntent(p, "return_cabinet") -- 1083
		end -- 1083
	end -- 1083
end -- 750
function WellMuseumPlugin.prototype.drawBackdrop(self, bgDraw, _bgGlow, _backdropArt, ctx) -- 1088
	if ctx.view.visualMode ~= "museum" then -- 1088
		return false -- 1095
	end -- 1095
	bgDraw:drawRect( -- 1098
		Rect(0, 0, ctx.w, ctx.h), -- 1098
		Color(11, 13, 18, 255) -- 1098
	) -- 1098
	return true -- 1099
end -- 1088
function WellMuseumPlugin.prototype.drawWorld(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1102
	return ctx.view.visualMode == "museum" -- 1108
end -- 1102
function WellMuseumPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 1111
	return ctx.view.visualMode == "museum" -- 1117
end -- 1111
function WellMuseumPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 1123
	if not self.gateOpen or ctx.view.visualMode == "museum" then -- 1123
		return -- 1130
	end -- 1130
	local cam = ctx.cam -- 1132
	local wellCx = cam:sx(self.wellWorldX) -- 1133
	local groundY = cam:sy(0, 0) -- 1134
	local phase = ctx.view.archive.museumPhase -- 1135
	local activeLure = phase == "well_open" and not ctx.view.archive.museumSeen -- 1136
	local archW = cam:len(68) -- 1139
	local archH = cam:len(96) -- 1140
	local archX = wellCx - archW * 0.54 -- 1141
	fillVGradRect( -- 1142
		fgDraw, -- 1143
		archX, -- 1144
		groundY, -- 1145
		archW, -- 1146
		archH, -- 1147
		Color(12, 16, 22, 232), -- 1148
		Color(18, 24, 34, 212) -- 1149
	) -- 1149
	fgDraw:drawRect( -- 1152
		Rect(archX - 4, groundY, 6, archH), -- 1152
		Color(48, 54, 62, 240) -- 1152
	) -- 1152
	fgDraw:drawRect( -- 1153
		Rect(archX + archW - 2, groundY, 6, archH), -- 1153
		Color(48, 54, 62, 240) -- 1153
	) -- 1153
	fgDraw:drawRect( -- 1154
		Rect(archX - 6, groundY + archH - 8, archW + 12, 10), -- 1154
		Color(62, 68, 76, 245) -- 1154
	) -- 1154
	local rimW = cam:len(38) -- 1157
	local rimH = cam:len(22) -- 1158
	local rimX = wellCx - rimW * 0.5 -- 1159
	fgDraw:drawRect( -- 1160
		Rect(rimX, groundY, rimW, rimH), -- 1161
		Color(46, 52, 60, 250), -- 1162
		1.2, -- 1163
		Color(102, 110, 120, 215) -- 1164
	) -- 1164
	fgDraw:drawEllipse( -- 1167
		Vec2(wellCx, groundY + rimH), -- 1167
		rimW * 0.52, -- 1167
		cam:len(5.5), -- 1167
		Color(74, 82, 92, 250) -- 1167
	) -- 1167
	fgDraw:drawEllipse( -- 1168
		Vec2(wellCx, groundY + rimH), -- 1168
		rimW * 0.38, -- 1168
		cam:len(3.8), -- 1168
		Color(8, 12, 18, 255) -- 1168
	) -- 1168
	local dripCycle = self.animTime * 0.58 % 1 -- 1171
	local rippleR = cam:len(3 + dripCycle * 11) -- 1172
	local rippleAlpha = math.floor((1 - dripCycle) * (activeLure and 155 or 42) + 0.5) -- 1173
	if activeLure then -- 1173
		local shimmer = 0.65 + 0.35 * math.sin(self.animTime * 2.9) -- 1175
		fgDraw:drawCircle( -- 1177
			Vec2(wellCx, groundY + rimH), -- 1177
			cam:len(2.8), -- 1177
			Color( -- 1177
				236, -- 1177
				244, -- 1177
				252, -- 1177
				math.floor(215 * shimmer + 0.5) -- 1177
			) -- 1177
		) -- 1177
		drawEllipseRing( -- 1178
			fgDraw, -- 1178
			wellCx, -- 1178
			groundY + rimH, -- 1178
			rippleR, -- 1178
			rippleR * 0.36, -- 1178
			Color(0, 0, 0, 0), -- 1178
			1.1, -- 1178
			Color(210, 226, 242, rippleAlpha), -- 1178
			24 -- 1178
		) -- 1178
		fillRadialGlow( -- 1179
			fgGlow, -- 1180
			wellCx, -- 1181
			groundY + rimH + cam:len(8), -- 1182
			cam:len(30), -- 1183
			cam:len(38), -- 1184
			Color( -- 1185
				206, -- 1185
				224, -- 1185
				244, -- 1185
				math.floor(52 * shimmer + 0.5) -- 1185
			), -- 1185
			Color(148, 178, 212, 0), -- 1186
			16 -- 1187
		) -- 1187
		if dripCycle < 0.24 then -- 1187
			local dropK = dripCycle / 0.24 -- 1191
			local dropY = groundY + archH * 0.72 - dropK * (archH * 0.72 - rimH) -- 1192
			fgDraw:drawSegment( -- 1193
				Vec2(wellCx, dropY), -- 1194
				Vec2( -- 1195
					wellCx, -- 1195
					dropY + cam:len(4.5) -- 1195
				), -- 1195
				1.4, -- 1196
				Color(214, 228, 244, 185) -- 1197
			) -- 1197
		end -- 1197
	elseif self.revisitCalmTimer > 0 then -- 1197
		local calmK = 1 - clamp01(self.revisitCalmTimer / 1.4) -- 1202
		local calmR = cam:len(3 + calmK * 10) -- 1203
		drawEllipseRing( -- 1204
			fgDraw, -- 1205
			wellCx, -- 1206
			groundY + rimH, -- 1207
			calmR, -- 1208
			calmR * 0.35, -- 1209
			Color(0, 0, 0, 0), -- 1210
			1, -- 1211
			Color( -- 1212
				148, -- 1212
				160, -- 1212
				172, -- 1212
				math.floor((1 - calmK) * 120 + 0.5) -- 1212
			), -- 1212
			24 -- 1213
		) -- 1213
	end -- 1213
end -- 1123
function WellMuseumPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1223
	local view = ctx.view -- 1230
	local phase = view.archive.museumPhase -- 1231
	if view.visualMode ~= "museum" then -- 1231
		if self.gateOpen and self.nearWell and view.assistHintsEnabled and phase == "well_open" and not view.archive.museumSeen then -- 1231
			local sx = ctx.cam:sx(self.wellWorldX) / ctx.uiScale -- 1236
			local sy = (ctx.cam:sy(0, 0) + ctx.cam:len(54)) / ctx.uiScale -- 1237
			drawSilkVeil( -- 1238
				uiDraw, -- 1238
				uiArt, -- 1238
				"fe06_well_hint_veil", -- 1238
				sx, -- 1238
				sy, -- 1238
				132, -- 1238
				26, -- 1238
				PALETTE.panelBg, -- 1238
				0.82, -- 1238
				1 -- 1238
			) -- 1238
			ctx.texts:put( -- 1239
				"xs", -- 1240
				getActiveTarget():adaptHintSentence("[E] 俯身看井", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1241
				sx, -- 1242
				sy, -- 1243
				toColor(PALETTE.textBright), -- 1244
				0.5, -- 1245
				0.5, -- 1246
				"Center", -- 1247
				0.6, -- 1248
				0.92 -- 1249
			) -- 1249
		end -- 1249
		return false -- 1252
	end -- 1252
	local w = ctx.uiW -- 1255
	local h = ctx.uiH -- 1256
	local effectivePhase = ctx.p.room.key == "museum" and phase == "well_reflect" and self.liveReflectDoneInMuseumRoom and "hall_walk" or phase -- 1258
	if effectivePhase == "well_reflect" then -- 1258
		self:renderE01WellReflectMatchCut( -- 1263
			uiDraw, -- 1263
			uiInkDraw, -- 1263
			uiArt, -- 1263
			uiGlow, -- 1263
			ctx, -- 1263
			w, -- 1263
			h -- 1263
		) -- 1263
		return true -- 1264
	end -- 1264
	if effectivePhase == "hall_walk" then -- 1264
		self:renderE02MuseumHall( -- 1267
			uiDraw, -- 1267
			uiInkDraw, -- 1267
			uiArt, -- 1267
			uiGlow, -- 1267
			ctx, -- 1267
			w, -- 1267
			h, -- 1267
			0, -- 1267
			false -- 1267
		) -- 1267
		return true -- 1268
	end -- 1268
	if effectivePhase == "lamp_turn" then -- 1268
		local turnProg = smoothstep(0, 1.15, self.lampElapsed) -- 1271
		self:renderE02MuseumHall( -- 1272
			uiDraw, -- 1272
			uiInkDraw, -- 1272
			uiArt, -- 1272
			uiGlow, -- 1272
			ctx, -- 1272
			w, -- 1272
			h, -- 1272
			turnProg, -- 1272
			true -- 1272
		) -- 1272
		return true -- 1273
	end -- 1273
	if effectivePhase == "return_cabinet" then -- 1273
		self:renderE02ReturnCabinet( -- 1276
			uiDraw, -- 1276
			uiInkDraw, -- 1276
			uiArt, -- 1276
			uiGlow, -- 1276
			ctx, -- 1276
			w, -- 1276
			h -- 1276
		) -- 1276
		return true -- 1277
	end -- 1277
	return false -- 1279
end -- 1223
function WellMuseumPlugin.prototype.renderE01WellReflectMatchCut(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1285
	local t = self.reflectElapsed -- 1294
	local ax = self.wellAnchorX -- 1295
	local ay = self.wellAnchorY -- 1296
	local matchK = smoothstep(____exports.MUSEUM_TIMINGS.wellMatchCutStart, ____exports.MUSEUM_TIMINGS.wellReflectDuration, t) -- 1297
	drawComicSequence( -- 1299
		uiDraw, -- 1300
		uiInkDraw, -- 1301
		uiArt, -- 1302
		E01_MATCH_COMIC_SEQ, -- 1303
		t, -- 1304
		w, -- 1305
		h, -- 1306
		{ -- 1307
			letterboxH = 42, -- 1308
			opacity = 1, -- 1309
			layer = 1, -- 1310
			instancePrefix = "fe06_e01_comic", -- 1311
			accentBorder = true -- 1312
		} -- 1312
	) -- 1312
	if t >= ____exports.MUSEUM_TIMINGS.wellPickupAt and matchK < 0.85 then -- 1312
		local capA = smoothstep(____exports.MUSEUM_TIMINGS.wellPickupAt, ____exports.MUSEUM_TIMINGS.wellPickupAt + 0.35, t) * (1 - matchK) -- 1318
		if capA > 0.03 then -- 1318
			drawSilkVeil( -- 1320
				uiDraw, -- 1320
				uiArt, -- 1320
				"fe06_pickup_veil", -- 1320
				w * 0.5, -- 1320
				96, -- 1320
				300, -- 1320
				34, -- 1320
				PALETTE.inkVoid, -- 1320
				0.78 * capA, -- 1320
				5 -- 1320
			) -- 1320
			ctx.texts:put( -- 1321
				"sm", -- 1322
				"拾起「时间穿梭器」", -- 1323
				w * 0.5, -- 1324
				96, -- 1325
				toColor(PALETTE.amberCore), -- 1326
				0.5, -- 1327
				0.5, -- 1328
				"Center", -- 1329
				1.4, -- 1330
				capA -- 1331
			) -- 1331
		end -- 1331
	end -- 1331
	local flashPeak = math.sin(matchK * math.pi) -- 1337
	local coreR = 7 + flashPeak * 16 -- 1338
	uiInkDraw:drawCircle( -- 1339
		Vec2(ax, ay), -- 1339
		coreR * 0.52, -- 1339
		Color( -- 1339
			248, -- 1339
			252, -- 1339
			255, -- 1339
			math.floor(180 + 68 * flashPeak + 0.5) -- 1339
		) -- 1339
	) -- 1339
	fillRadialGlow( -- 1340
		uiGlow, -- 1341
		ax, -- 1342
		ay, -- 1343
		48 + flashPeak * 135, -- 1344
		44 + flashPeak * 108, -- 1345
		Color( -- 1346
			238, -- 1346
			246, -- 1346
			255, -- 1346
			math.floor(92 + flashPeak * 128 + 0.5) -- 1346
		), -- 1346
		Color(174, 204, 238, 0), -- 1347
		20 -- 1348
	) -- 1348
	if flashPeak > 0.05 then -- 1348
		local rayW = 70 + flashPeak * 260 -- 1351
		fillHGradRect( -- 1352
			uiGlow, -- 1352
			ax - rayW, -- 1352
			ay - 2, -- 1352
			rayW, -- 1352
			4, -- 1352
			Color(224, 238, 252, 0), -- 1352
			Color( -- 1352
				242, -- 1352
				248, -- 1352
				255, -- 1352
				math.floor(150 * flashPeak + 0.5) -- 1352
			) -- 1352
		) -- 1352
		fillHGradRect( -- 1353
			uiGlow, -- 1353
			ax, -- 1353
			ay - 2, -- 1353
			rayW, -- 1353
			4, -- 1353
			Color( -- 1353
				242, -- 1353
				248, -- 1353
				255, -- 1353
				math.floor(150 * flashPeak + 0.5) -- 1353
			), -- 1353
			Color(224, 238, 252, 0) -- 1353
		) -- 1353
	end -- 1353
end -- 1285
function WellMuseumPlugin.prototype.renderE02MuseumHall(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h, lampTurnProg, inLampTurn) -- 1360
	if inLampTurn then -- 1360
		drawComicSequence( -- 1372
			uiDraw, -- 1373
			uiInkDraw, -- 1374
			uiArt, -- 1375
			E02_LAMP_COMIC_SEQ, -- 1376
			self.lampElapsed, -- 1377
			w, -- 1378
			h, -- 1379
			{ -- 1380
				letterboxH = 42, -- 1381
				opacity = 1, -- 1382
				layer = 1, -- 1383
				instancePrefix = "fe06_e02_lamp_comic", -- 1384
				accentBorder = true -- 1385
			} -- 1385
		) -- 1385
		if self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1385
			local lineA = smoothstep(____exports.MUSEUM_TIMINGS.lampLineAt, ____exports.MUSEUM_TIMINGS.lampLineAt + 0.45, self.lampElapsed) * (1 - smoothstep(____exports.MUSEUM_TIMINGS.lampTurnDuration - 0.35, ____exports.MUSEUM_TIMINGS.lampTurnDuration, self.lampElapsed)) -- 1389
			if lineA > 0.02 then -- 1389
				drawSilkVeil( -- 1392
					uiDraw, -- 1392
					uiArt, -- 1392
					"fe06_dawn_line_veil", -- 1392
					w * 0.5, -- 1392
					86, -- 1392
					440, -- 1392
					50, -- 1392
					PALETTE.inkVoid, -- 1392
					0.84 * lineA, -- 1392
					6 -- 1392
				) -- 1392
				ctx.texts:put( -- 1393
					"md", -- 1394
					____exports.MUSEUM_LINE_DAWN, -- 1394
					w * 0.5, -- 1396
					86, -- 1397
					toColor(PALETTE.amberCore), -- 1398
					0.5, -- 1399
					0.5, -- 1400
					"Center", -- 1401
					1.6, -- 1402
					lineA -- 1403
				) -- 1403
			end -- 1403
		end -- 1403
		if self.knock1VisualT > 0 then -- 1403
			local k1 = 1 - clamp01(self.knock1VisualT / 0.85) -- 1408
			local k1A = math.floor((1 - k1) * 215 + 0.5) -- 1409
			drawCircleRing( -- 1410
				uiInkDraw, -- 1410
				w * 0.62, -- 1410
				h * 0.48, -- 1410
				14 + k1 * 68, -- 1410
				Color(0, 0, 0, 0), -- 1410
				1.8, -- 1410
				Color(242, 232, 206, k1A), -- 1410
				28 -- 1410
			) -- 1410
			drawCircleRing( -- 1411
				uiInkDraw, -- 1411
				w * 0.62, -- 1411
				h * 0.48, -- 1411
				7 + k1 * 36, -- 1411
				Color(0, 0, 0, 0), -- 1411
				1.2, -- 1411
				Color( -- 1411
					242, -- 1411
					232, -- 1411
					206, -- 1411
					math.floor(k1A * 0.72 + 0.5) -- 1411
				), -- 1411
				24 -- 1411
			) -- 1411
		end -- 1411
		return -- 1413
	end -- 1413
	local floorY = 148 -- 1415
	local wallTopY = h - 86 -- 1416
	local halfW = w * 0.5 -- 1417
	local camMin = math.min(____exports.MUSEUM_HALL_WIDTH * 0.5, halfW - 40) -- 1418
	local camMax = math.max(____exports.MUSEUM_HALL_WIDTH * 0.5, ____exports.MUSEUM_HALL_WIDTH - halfW + 40) -- 1419
	local camX = clamp(self.hallCamX, camMin, camMax) -- 1420
	local function toScreenX(hx) -- 1421
		return halfW + (hx - camX) -- 1421
	end -- 1421
	fillVGradRect( -- 1424
		uiDraw, -- 1424
		0, -- 1424
		floorY, -- 1424
		w, -- 1424
		h - floorY, -- 1424
		Color(26, 31, 38, 255), -- 1424
		Color(16, 20, 26, 255) -- 1424
	) -- 1424
	fillVGradRect( -- 1425
		uiDraw, -- 1425
		0, -- 1425
		0, -- 1425
		w, -- 1425
		floorY, -- 1425
		Color(14, 17, 22, 255), -- 1425
		Color(32, 37, 45, 255) -- 1425
	) -- 1425
	local bgW = math.max(w * 1.18, ____exports.MUSEUM_HALL_WIDTH + 200) -- 1426
	local bgH = h -- 1427
	local bgCenterX = toScreenX(____exports.MUSEUM_HALL_WIDTH * 0.5) -- 1428
	local paintedHall = uiArt:tryPlacePath( -- 1429
		"assets/art/bg_museum_hall.png", -- 1430
		"fe06_museum_hall_bg", -- 1431
		bgCenterX, -- 1432
		h * 0.5, -- 1433
		bgW, -- 1434
		bgH, -- 1435
		{ -- 1436
			anchorX = 0.5, -- 1437
			anchorY = 0.5, -- 1438
			opacity = 1, -- 1439
			smooth = true, -- 1440
			layer = -6 -- 1441
		} -- 1441
	) -- 1441
	if not paintedHall then -- 1441
		uiDraw:drawRect( -- 1445
			Rect(0, wallTopY, w, h - wallTopY), -- 1445
			Color(11, 14, 19, 255) -- 1445
		) -- 1445
		uiDraw:drawSegment( -- 1446
			Vec2(0, floorY), -- 1446
			Vec2(w, floorY), -- 1446
			2, -- 1446
			Color(76, 86, 98, 220) -- 1446
		) -- 1446
	end -- 1446
	local plaqueWorldX = self.caseX <= 260 and 108 or 180 -- 1450
	local plaqueX = toScreenX(plaqueWorldX) -- 1451
	if plaqueX > -240 and plaqueX < w + 240 then -- 1451
		local pw = 286 -- 1453
		local ph = 112 -- 1454
		local py = floorY + 146 -- 1455
		drawSilkVeil( -- 1456
			uiDraw, -- 1456
			uiArt, -- 1456
			"fe06_plaque_veil", -- 1456
			plaqueX, -- 1456
			py + ph * 0.5, -- 1456
			pw, -- 1456
			ph, -- 1456
			PALETTE.inkVoid, -- 1456
			0.62, -- 1456
			0 -- 1456
		) -- 1456
		fillRadialGlow( -- 1457
			uiGlow, -- 1457
			plaqueX, -- 1457
			wallTopY - 8, -- 1457
			150, -- 1457
			120, -- 1457
			Color(224, 232, 240, 38), -- 1457
			Color(180, 196, 214, 0), -- 1457
			14 -- 1457
		) -- 1457
		ctx.texts:put( -- 1458
			"sm", -- 1459
			"海防抗战纪念展厅", -- 1460
			plaqueX, -- 1461
			py + 72, -- 1462
			toColor(PALETTE.textBright), -- 1463
			0.5, -- 1464
			0.5, -- 1465
			"Center", -- 1466
			2, -- 1467
			0.9 -- 1468
		) -- 1468
		ctx.texts:put( -- 1470
			"xs", -- 1471
			"温州宁村 · 守望史迹陈列", -- 1472
			plaqueX, -- 1473
			py + 38, -- 1474
			toColor(PALETTE.textMid), -- 1475
			0.5, -- 1476
			0.5, -- 1477
			"Center", -- 1478
			1, -- 1479
			0.8 -- 1480
		) -- 1480
	end -- 1480
	local caseSx = toScreenX(self.caseX) -- 1485
	if caseSx > -260 and caseSx < w + 260 then -- 1485
		local pedW = 148 -- 1487
		local pedH = 92 -- 1488
		local glassH = 128 -- 1489
		if not paintedHall then -- 1489
			uiDraw:drawRect( -- 1491
				Rect(caseSx - pedW * 0.5, floorY, pedW, pedH), -- 1491
				Color(22, 26, 33, 252), -- 1491
				1.2, -- 1491
				Color(96, 106, 118, 185) -- 1491
			) -- 1491
			uiDraw:drawRect( -- 1492
				Rect(caseSx - pedW * 0.46, floorY + pedH, pedW * 0.92, glassH), -- 1492
				Color(16, 22, 30, 165), -- 1492
				1.4, -- 1492
				Color(180, 196, 214, 195) -- 1492
			) -- 1492
		end -- 1492
		uiArt:tryPlace( -- 1495
			"prop_compass", -- 1495
			"fe06_hall_compass", -- 1495
			caseSx - 6, -- 1495
			floorY + pedH + 18, -- 1495
			32, -- 1495
			32, -- 1495
			{opacity = 0.96, layer = 2} -- 1495
		) -- 1495
		uiArt:tryPlacePath( -- 1499
			"assets/art/cutscene_cuff_rig.clip|cuff_zhou_open", -- 1499
			"fe06_hall_cuff_relic", -- 1499
			caseSx + 14, -- 1499
			floorY + pedH + 14, -- 1499
			58, -- 1499
			26, -- 1499
			{ -- 1499
				anchorX = 0.5, -- 1500
				anchorY = 0.5, -- 1501
				angle = -8, -- 1502
				opacity = 0.34, -- 1503
				smooth = true, -- 1504
				layer = 1 -- 1505
			} -- 1505
		) -- 1505
		fillGradQuad( -- 1507
			uiInkDraw, -- 1508
			caseSx - 28, -- 1509
			floorY + pedH + glassH - 4, -- 1509
			Color(230, 240, 252, 36), -- 1509
			caseSx + 12, -- 1510
			floorY + pedH + glassH - 4, -- 1510
			Color(242, 248, 255, 62), -- 1510
			caseSx - 12, -- 1511
			floorY + pedH + 4, -- 1511
			Color(230, 240, 252, 14), -- 1511
			caseSx - 48, -- 1512
			floorY + pedH + 4, -- 1512
			Color(230, 240, 252, 0) -- 1512
		) -- 1512
		fillRadialGlow( -- 1514
			uiGlow, -- 1514
			caseSx, -- 1514
			floorY + pedH + glassH - 12, -- 1514
			86, -- 1514
			128, -- 1514
			Color(224, 236, 250, 52), -- 1514
			Color(168, 192, 220, 0), -- 1514
			16 -- 1514
		) -- 1514
	end -- 1514
	local lampSx = toScreenX(self.lampX) -- 1518
	local winSx = toScreenX(self.lampX + 108) -- 1519
	local reflectK = inLampTurn and smoothstep(____exports.MUSEUM_TIMINGS.lampReflectStart, 2.35, self.lampElapsed) or 0 -- 1520
	if winSx > -260 and winSx < w + 260 then -- 1520
		local winW = 204 -- 1525
		local winH = 312 -- 1526
		local winX = winSx - winW * 0.5 -- 1527
		local winY = floorY + 38 -- 1528
		if not paintedHall then -- 1528
			fillVGradRect( -- 1530
				uiDraw, -- 1530
				winX, -- 1530
				winY, -- 1530
				winW, -- 1530
				winH, -- 1530
				Color(54, 68, 92, 255), -- 1530
				Color(30, 44, 70, 255) -- 1530
			) -- 1530
			uiInkDraw:drawRect( -- 1531
				Rect(winX, winY, winW, winH), -- 1531
				Color(0, 0, 0, 0), -- 1531
				3, -- 1531
				Color(68, 76, 88, 245) -- 1531
			) -- 1531
		end -- 1531
		if reflectK > 0.02 then -- 1531
			uiArt:tryPlace( -- 1536
				"bgFar_prologue", -- 1536
				"fe06_window_courtyard", -- 1536
				winSx, -- 1536
				winY + 26, -- 1536
				winW - 8, -- 1536
				winH - 52, -- 1536
				{ -- 1536
					opacity = reflectK * 0.52, -- 1537
					color = Color(242, 222, 188, 255), -- 1538
					layer = 1 -- 1539
				} -- 1539
			) -- 1539
			fillRadialGlow( -- 1541
				uiGlow, -- 1541
				winSx, -- 1541
				winY + winH * 0.48, -- 1541
				136, -- 1541
				152, -- 1541
				Color( -- 1541
					248, -- 1541
					220, -- 1541
					170, -- 1541
					math.floor(98 * reflectK + 0.5) -- 1541
				), -- 1541
				Color(214, 174, 112, 0), -- 1541
				18 -- 1541
			) -- 1541
		end -- 1541
		local aimDir = -0.65 + lampTurnProg * 1.48 -- 1545
		local lampH = 192 -- 1546
		local lampW = lampH * (236 / 360) -- 1547
		local headX = lampSx + 18 + math.sin(aimDir) * 20 -- 1548
		local headY = floorY + lampH - 34 + math.cos(aimDir) * 10 -- 1549
		if not uiArt:tryPlacePath( -- 1549
			"assets/art/cutscene_well_museum.clip|museum_brass_lamp", -- 1551
			"fe06_museum_brass_lamp", -- 1552
			lampSx, -- 1553
			floorY, -- 1554
			lampW, -- 1555
			lampH, -- 1556
			{ -- 1557
				anchorX = 0.5, -- 1558
				anchorY = 0, -- 1559
				angle = 0, -- 1560
				opacity = 0.98, -- 1561
				smooth = true, -- 1562
				layer = 4 -- 1563
			} -- 1563
		) then -- 1563
			uiDraw:drawRect( -- 1566
				Rect(lampSx - 17, floorY, 34, 96), -- 1566
				Color(34, 39, 48, 250) -- 1566
			) -- 1566
		end -- 1566
		local beamLen = 138 + lampTurnProg * 86 -- 1570
		local bxEnd = headX + math.sin(aimDir) * beamLen -- 1571
		local byEnd = headY + math.cos(aimDir) * 28 -- 1572
		local perpX = -math.cos(aimDir) * 18 -- 1573
		local perpY = math.sin(aimDir) * 34 -- 1574
		fillGradQuad( -- 1575
			uiGlow, -- 1576
			headX, -- 1577
			headY - 4, -- 1577
			Color( -- 1577
				246, -- 1577
				224, -- 1577
				178, -- 1577
				math.floor(68 + 46 * lampTurnProg + 0.5) -- 1577
			), -- 1577
			headX, -- 1578
			headY + 4, -- 1578
			Color( -- 1578
				246, -- 1578
				224, -- 1578
				178, -- 1578
				math.floor(68 + 46 * lampTurnProg + 0.5) -- 1578
			), -- 1578
			bxEnd + perpX, -- 1579
			byEnd + perpY + 34, -- 1579
			Color(238, 206, 148, 0), -- 1579
			bxEnd - perpX, -- 1580
			byEnd - perpY - 22, -- 1580
			Color(238, 206, 148, 0) -- 1580
		) -- 1580
		fillRadialGlow( -- 1582
			uiGlow, -- 1582
			headX, -- 1582
			headY, -- 1582
			38, -- 1582
			38, -- 1582
			Color(248, 228, 186, 82), -- 1582
			Color(224, 194, 140, 0), -- 1582
			14 -- 1582
		) -- 1582
	end -- 1582
	local playerSx = toScreenX(self.hallWalkX) -- 1586
	local moving = not inLampTurn and self.hallMoving -- 1587
	local slot = moving and "soldier_run" or "soldier_idle" -- 1588
	local frame = moving and math.floor(self.hallWalkAnim) or 0 -- 1589
	local charH = math.floor(192 * math.max( -- 1590
		0.75, -- 1590
		math.min(1.25, h / 720) -- 1590
	) + 0.5) -- 1590
	local charW = math.floor(charH * 0.45 + 0.5) -- 1591
	uiDraw:drawEllipse( -- 1593
		Vec2(playerSx, floorY + 2), -- 1593
		34, -- 1593
		6.5, -- 1593
		Color(6, 8, 12, 178) -- 1593
	) -- 1593
	uiDraw:drawEllipse( -- 1594
		Vec2(playerSx, floorY - 14), -- 1594
		24, -- 1594
		4.5, -- 1594
		Color(16, 20, 28, 62) -- 1594
	) -- 1594
	local pose = {facing = self.hallFacing, frame = frame, layer = 3} -- 1595
	local running = moving and uiArt:tryPlaceRun( -- 1600
		"soldier", -- 1600
		"fe06_museum_zhoushu", -- 1600
		playerSx, -- 1600
		floorY + 2, -- 1600
		charW, -- 1601
		charH, -- 1601
		self.hallWalkAnim / 4, -- 1601
		pose -- 1601
	) -- 1601
	if not running and not uiArt:tryPlace( -- 1601
		slot, -- 1602
		"fe06_museum_zhoushu", -- 1602
		playerSx, -- 1602
		floorY + 2, -- 1602
		charW, -- 1602
		charH, -- 1602
		pose -- 1602
	) then -- 1602
		uiDraw:drawRect( -- 1604
			Rect(playerSx - 20, floorY + 2, 40, charH * 0.84), -- 1604
			toColor(CUFF_PALETTE.indigoBase) -- 1604
		) -- 1604
		uiDraw:drawCircle( -- 1605
			Vec2(playerSx, floorY + charH * 0.92), -- 1605
			16, -- 1605
			Color(66, 73, 76, 255) -- 1605
		) -- 1605
	end -- 1605
	if self.holstered and not inLampTurn and math.abs(self.hallWalkX - self.caseX) <= 130 then -- 1605
		local subA = clamp01(1 - math.abs(self.hallWalkX - self.caseX) / 145) * 0.86 -- 1610
		ctx.texts:put( -- 1611
			"xs", -- 1612
			"已收起随身器物", -- 1613
			caseSx, -- 1614
			floorY + 252, -- 1615
			toColor(PALETTE.textMid), -- 1616
			0.5, -- 1617
			0.5, -- 1618
			"Center", -- 1619
			0.9, -- 1620
			subA -- 1621
		) -- 1621
	end -- 1621
	if self.childEchoVisualT > 0 then -- 1621
		local echoK = 1 - clamp01(self.childEchoVisualT / 2.1) -- 1627
		local ex = math.min( -- 1628
			w - 110, -- 1628
			toScreenX(self.caseX + 310) -- 1628
		) -- 1628
		local ey = floorY + 32 -- 1629
		local ea = math.floor(math.sin(echoK * math.pi) * 165 + 0.5) -- 1630
		drawCircleRing( -- 1631
			uiInkDraw, -- 1631
			ex, -- 1631
			ey, -- 1631
			14 + echoK * 46, -- 1631
			Color(0, 0, 0, 0), -- 1631
			1.1, -- 1631
			Color(224, 214, 194, ea), -- 1631
			28 -- 1631
		) -- 1631
		drawCircleRing( -- 1632
			uiInkDraw, -- 1632
			ex, -- 1632
			ey, -- 1632
			8 + echoK * 28, -- 1632
			Color(0, 0, 0, 0), -- 1632
			0.9, -- 1632
			Color( -- 1632
				224, -- 1632
				214, -- 1632
				194, -- 1632
				math.floor(ea * 0.7 + 0.5) -- 1632
			), -- 1632
			24 -- 1632
		) -- 1632
		ctx.texts:put( -- 1633
			"xs", -- 1634
			"（远方传来轻快的孩童脚步声）", -- 1635
			w * 0.5, -- 1636
			84, -- 1637
			toColor(PALETTE.textMid), -- 1638
			0.5, -- 1639
			0.5, -- 1640
			"Center", -- 1641
			1, -- 1642
			math.sin(echoK * math.pi) * 0.85 -- 1643
		) -- 1643
	end -- 1643
	if not inLampTurn then -- 1643
		local fadeIn = smoothstep(0, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn, self.hallIntroElapsed) -- 1649
		local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold, ____exports.MUSEUM_TIMINGS.hallIntroFadeIn + ____exports.MUSEUM_TIMINGS.hallIntroHold + ____exports.MUSEUM_TIMINGS.hallIntroFadeOut, self.hallIntroElapsed) -- 1650
		local introA = fadeIn * fadeOut -- 1655
		if introA > 0.02 then -- 1655
			drawSilkVeil( -- 1657
				uiDraw, -- 1657
				uiArt, -- 1657
				"fe06_hall_intro_veil", -- 1657
				w * 0.5, -- 1657
				h - 104, -- 1657
				480, -- 1657
				74, -- 1657
				PALETTE.inkVoid, -- 1657
				0.78 * introA, -- 1657
				1 -- 1657
			) -- 1657
			drawHairline( -- 1658
				uiInkDraw, -- 1658
				uiArt, -- 1658
				"fe06_hall_intro_line", -- 1658
				w * 0.5, -- 1658
				h - 106, -- 1658
				260, -- 1658
				PALETTE.silkLine, -- 1658
				0.45 * introA, -- 1658
				false, -- 1658
				4 -- 1658
			) -- 1658
			ctx.texts:put( -- 1659
				"md", -- 1659
				____exports.MUSEUM_HALL_TITLE, -- 1659
				w * 0.5, -- 1659
				h - 88, -- 1659
				toColor(PALETTE.textBright), -- 1659
				0.5, -- 1659
				0.5, -- 1659
				"Center", -- 1659
				1.8, -- 1659
				introA -- 1659
			) -- 1659
			ctx.texts:put( -- 1660
				"xs", -- 1660
				____exports.MUSEUM_HALL_SUBTITLE, -- 1660
				w * 0.5, -- 1660
				h - 122, -- 1660
				toColor(PALETTE.amberCore), -- 1660
				0.5, -- 1660
				0.5, -- 1660
				"Center", -- 1660
				1.2, -- 1660
				introA * 0.88 -- 1660
			) -- 1660
		end -- 1660
		if self.nearLamp and ctx.view.assistHintsEnabled then -- 1660
			drawSilkVeil( -- 1665
				uiDraw, -- 1665
				uiArt, -- 1665
				"fe06_lamp_hint_veil", -- 1665
				lampSx, -- 1665
				floorY + 158, -- 1665
				146, -- 1665
				28, -- 1665
				PALETTE.panelBg, -- 1665
				0.84, -- 1665
				1 -- 1665
			) -- 1665
			ctx.texts:put( -- 1666
				"xs", -- 1667
				getActiveTarget():adaptHintSentence("[E] 转动西窗灯", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1668
				lampSx, -- 1669
				floorY + 158, -- 1670
				toColor(PALETTE.textBright), -- 1671
				0.5, -- 1672
				0.5, -- 1673
				"Center", -- 1674
				0.6, -- 1675
				0.94 -- 1676
			) -- 1676
		end -- 1676
	end -- 1676
	if inLampTurn and self.lampElapsed >= ____exports.MUSEUM_TIMINGS.lampLineAt then -- 1676
		local lineA = smoothstep(____exports.MUSEUM_TIMINGS.lampLineAt, ____exports.MUSEUM_TIMINGS.lampLineAt + 0.45, self.lampElapsed) * (1 - smoothstep(____exports.MUSEUM_TIMINGS.lampTurnDuration - 0.35, ____exports.MUSEUM_TIMINGS.lampTurnDuration, self.lampElapsed)) -- 1683
		if lineA > 0.02 then -- 1683
			drawSilkVeil( -- 1686
				uiDraw, -- 1686
				uiArt, -- 1686
				"fe06_dawn_line_veil", -- 1686
				w * 0.5, -- 1686
				86, -- 1686
				440, -- 1686
				50, -- 1686
				PALETTE.inkVoid, -- 1686
				0.84 * lineA, -- 1686
				1 -- 1686
			) -- 1686
			ctx.texts:put( -- 1687
				"md", -- 1688
				____exports.MUSEUM_LINE_DAWN, -- 1688
				w * 0.5, -- 1690
				86, -- 1691
				toColor(PALETTE.amberCore), -- 1692
				0.5, -- 1693
				0.5, -- 1694
				"Center", -- 1695
				1.6, -- 1696
				lineA -- 1697
			) -- 1697
		end -- 1697
	end -- 1697
	if self.knock1VisualT > 0 then -- 1697
		local k1 = 1 - clamp01(self.knock1VisualT / 0.85) -- 1703
		local k1A = math.floor((1 - k1) * 205 + 0.5) -- 1704
		drawCircleRing( -- 1705
			uiInkDraw, -- 1705
			winSx, -- 1705
			floorY + 148, -- 1705
			12 + k1 * 64, -- 1705
			Color(0, 0, 0, 0), -- 1705
			1.6, -- 1705
			Color(242, 232, 206, k1A), -- 1705
			28 -- 1705
		) -- 1705
		drawCircleRing( -- 1706
			uiInkDraw, -- 1706
			winSx, -- 1706
			floorY + 148, -- 1706
			6 + k1 * 34, -- 1706
			Color(0, 0, 0, 0), -- 1706
			1.1, -- 1706
			Color( -- 1706
				242, -- 1706
				232, -- 1706
				206, -- 1706
				math.floor(k1A * 0.72 + 0.5) -- 1706
			), -- 1706
			24 -- 1706
		) -- 1706
	end -- 1706
	self:drawLetterbox( -- 1709
		uiInkDraw, -- 1709
		w, -- 1709
		h, -- 1709
		38, -- 1709
		0.9 -- 1709
	) -- 1709
end -- 1360
function WellMuseumPlugin.prototype.renderE02ReturnCabinet(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, w, h) -- 1715
	local t = self.returnElapsed -- 1724
	local fadeOut = 1 - smoothstep(____exports.MUSEUM_TIMINGS.returnFadeOutAt, ____exports.MUSEUM_TIMINGS.returnCabinetDuration, t) -- 1725
	uiDraw:drawRect( -- 1728
		Rect(0, 0, w, h), -- 1728
		Color( -- 1728
			7, -- 1728
			9, -- 1728
			13, -- 1728
			math.floor(252 * fadeOut + 0.5) -- 1728
		) -- 1728
	) -- 1728
	if t < ____exports.MUSEUM_TIMINGS.returnKnock2At then -- 1728
		self:drawLetterbox( -- 1731
			uiInkDraw, -- 1731
			w, -- 1731
			h, -- 1731
			42, -- 1731
			0.95 * fadeOut -- 1731
		) -- 1731
		return -- 1732
	end -- 1732
	local revealK = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.3, t) * fadeOut -- 1736
	local barH = 42 -- 1737
	local localT = math.max(0, t - ____exports.MUSEUM_TIMINGS.returnKnock2At) -- 1738
	drawComicSequence( -- 1740
		uiDraw, -- 1741
		uiInkDraw, -- 1742
		uiArt, -- 1743
		E02_RETURN_COMIC_SEQ, -- 1744
		localT, -- 1745
		w, -- 1746
		h, -- 1747
		{ -- 1748
			letterboxH = barH, -- 1749
			opacity = revealK, -- 1750
			layer = 2, -- 1751
			instancePrefix = "fe06_e02_return_comic", -- 1752
			accentBorder = true -- 1753
		} -- 1753
	) -- 1753
	if self.knock2VisualT > 0 then -- 1753
		local k2 = 1 - clamp01(self.knock2VisualT / 0.9) -- 1759
		local k2A = math.floor((1 - k2) * 195 * fadeOut + 0.5) -- 1760
		local kx = w * 0.74 -- 1761
		local ky = h * 0.34 -- 1762
		fillRadialGlow( -- 1763
			uiGlow, -- 1763
			kx, -- 1763
			ky, -- 1763
			26 + k2 * 56, -- 1763
			26 + k2 * 56, -- 1763
			Color( -- 1763
				238, -- 1763
				224, -- 1763
				194, -- 1763
				math.floor(k2A * 0.45 + 0.5) -- 1763
			), -- 1763
			Color(238, 224, 194, 0), -- 1763
			16 -- 1763
		) -- 1763
		drawCircleRing( -- 1764
			uiInkDraw, -- 1764
			kx, -- 1764
			ky, -- 1764
			12 + k2 * 58, -- 1764
			Color(0, 0, 0, 0), -- 1764
			1.4, -- 1764
			Color(232, 220, 196, k2A), -- 1764
			28 -- 1764
		) -- 1764
	end -- 1764
	local tipA = smoothstep(____exports.MUSEUM_TIMINGS.returnKnock2At + 0.45, ____exports.MUSEUM_TIMINGS.returnKnock2At + 0.95, t) * fadeOut -- 1767
	if tipA > 0.03 then -- 1767
		drawSilkVeil( -- 1769
			uiDraw, -- 1769
			uiArt, -- 1769
			"fe06_return_veil", -- 1769
			w * 0.5, -- 1769
			barH + 34, -- 1769
			320, -- 1769
			32, -- 1769
			PALETTE.inkVoid, -- 1769
			0.72 * tipA, -- 1769
			6 -- 1769
		) -- 1769
		ctx.texts:put( -- 1770
			"xs", -- 1771
			"两声轻敲落回柜板 · 寻回小满", -- 1772
			w * 0.5, -- 1773
			barH + 34, -- 1774
			toColor(PALETTE.textMid), -- 1775
			0.5, -- 1776
			0.5, -- 1777
			"Center", -- 1778
			1.2, -- 1779
			tipA * 0.9 -- 1780
		) -- 1780
	end -- 1780
end -- 1715
function WellMuseumPlugin.prototype.drawLetterbox(self, draw, w, h, barH, opacity) -- 1785
	local a = math.floor(244 * clamp01(opacity) + 0.5) -- 1786
	if a <= 2 then -- 1786
		return -- 1788
	end -- 1788
	draw:drawRect( -- 1790
		Rect(0, 0, w, barH), -- 1790
		Color(6, 8, 12, a) -- 1790
	) -- 1790
	draw:drawRect( -- 1791
		Rect(0, h - barH, w, barH), -- 1791
		Color(6, 8, 12, a) -- 1791
	) -- 1791
end -- 1785
function ____exports.createWellMuseumPlugin(contract) -- 1795
	return __TS__New(____exports.WellMuseumPlugin, contract) -- 1796
end -- 1795
return ____exports -- 1795