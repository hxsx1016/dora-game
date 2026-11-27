-- [ts]: prologue_intro.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 19
local Color = ____Dora.Color -- 19
local Rect = ____Dora.Rect -- 19
local Vec2 = ____Dora.Vec2 -- 19
local ____play = require("Script.watch.play") -- 20
local PROLOGUE_CABINET_X = ____play.PROLOGUE_CABINET_X -- 20
local PROLOGUE_HIDE_TICKS = ____play.PROLOGUE_HIDE_TICKS -- 20
local PROLOGUE_SHADOW_TICKS = ____play.PROLOGUE_SHADOW_TICKS -- 20
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 23
local CUFF_PALETTE = ____cuff_shots.CUFF_PALETTE -- 23
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 25
local drawComicSequence = ____slideshow.drawComicSequence -- 25
local ____theme = require("Script.watch.fe.theme") -- 26
local PALETTE = ____theme.PALETTE -- 27
local drawSilkVeil = ____theme.drawSilkVeil -- 29
local fillGradQuad = ____theme.fillGradQuad -- 30
local fillHGradRect = ____theme.fillHGradRect -- 31
local fillRadialGlow = ____theme.fillRadialGlow -- 32
local fillVGradRect = ____theme.fillVGradRect -- 33
local toColor = ____theme.toColor -- 35
--- 与 fe-01（P03/P05/G05）同源的明代青布补线袖口配色口径（直接取自 cuff_shots.CUFF_PALETTE，确保四镜视觉严格一致）
____exports.CUFF_SHARED_SPEC = { -- 54
	indigoCloth = CUFF_PALETTE.indigoBase, -- 55
	indigoTrim = CUFF_PALETTE.hemEdge, -- 56
	mendStitch = CUFF_PALETTE.stitchThread, -- 57
	armWrapCloth = CUFF_PALETTE.armWrapLinen, -- 58
	stitchCount = 6 -- 59
} -- 59
____exports.PROLOGUE_TIMINGS = { -- 62
	p01Duration = 4, -- 63
	p02ShadowDuration = PROLOGUE_SHADOW_TICKS / 60, -- 64
	p02EscapeDuration = 7.5, -- 65
	p02HiddenFadeOut = 0.28, -- 66
	p02HiddenLinger = PROLOGUE_HIDE_TICKS / 60, -- 67
	p04FlashDuration = 1, -- 68
	heartbeatMinHz = 1.15, -- 69
	heartbeatMaxHz = 2.75 -- 70
} -- 70
--- P02 硬核明代木刻暗黑漫画逐帧拍表（总长 4.50s，等步幅跨度 + 零重影硬切 + 1.55s 单帧冲击 + 3.88s 撞槛定格）：
-- 全部时间点与 stepP02Shadow 音效触发毫秒级咬合。
local P02_SHADOW_COMIC_SEQ = { -- 77
	{ -- 78
		slot = "comic_p02_01_shadows", -- 79
		start = 0, -- 80
		["end"] = 0.85, -- 81
		zoomFrom = 1, -- 82
		zoomTo = 1.012, -- 83
		transition = "cut" -- 84
	}, -- 84
	{ -- 86
		slot = "comic_p02_02a_door_intrude", -- 87
		start = 0.85, -- 88
		["end"] = 1.55, -- 89
		zoomFrom = 1.01, -- 90
		zoomTo = 1.022, -- 91
		transition = "cut" -- 92
	}, -- 92
	{ -- 94
		slot = "comic_p02_03_impact_cut", -- 95
		start = 1.55, -- 96
		["end"] = 1.74, -- 97
		zoomFrom = 1.035, -- 98
		zoomTo = 1.035, -- 99
		transition = "cut", -- 100
		impactFlash = true, -- 101
		impactDur = 0.19, -- 102
		shakeAmp = 11, -- 103
		shakeFreq = 72 -- 104
	}, -- 104
	{ -- 106
		slot = "comic_p02_04_shadows_fall", -- 107
		start = 1.74, -- 108
		["end"] = 2.7, -- 109
		zoomFrom = 1.015, -- 110
		zoomTo = 1, -- 111
		transition = "cut", -- 112
		shakeAmp = 3.5, -- 113
		shakeFreq = 48 -- 114
	}, -- 114
	{ -- 116
		slot = "comic_p02_05_bowl_roll1", -- 117
		start = 2.7, -- 118
		["end"] = 3.32, -- 119
		zoomFrom = 1, -- 120
		zoomTo = 1.014, -- 121
		transition = "slash_cut", -- 122
		transitionDur = 0.1 -- 123
	}, -- 123
	{ -- 125
		slot = "comic_p02_06_bowl_roll2", -- 126
		start = 3.32, -- 127
		["end"] = 3.88, -- 128
		zoomFrom = 1.008, -- 129
		zoomTo = 1.02, -- 130
		transition = "cut", -- 131
		shakeAmp = 2.5 -- 132
	}, -- 132
	{ -- 134
		slot = "comic_p02_07_bowl_smash", -- 135
		start = 3.88, -- 136
		["end"] = 4.5, -- 137
		zoomFrom = 1.028, -- 138
		zoomTo = 1, -- 139
		transition = "cut", -- 140
		impactFlash = true, -- 141
		impactDur = 0.18, -- 142
		shakeAmp = 9.5, -- 143
		shakeFreq = 66 -- 144
	} -- 144
} -- 144
--- P02 入柜收声三阶合缝拍表（总长 1.80s：贼足掠过 → 门缝半合 → 合缝一线冷月死寂）
local P02_HIDDEN_COMIC_SEQ = {{ -- 149
	slot = "comic_p02_08a_cabinet_slit", -- 151
	start = 0, -- 152
	["end"] = 0.65, -- 153
	zoomFrom = 1, -- 154
	zoomTo = 1.008, -- 155
	transition = "cut" -- 156
}, { -- 156
	slot = "comic_p02_08m_cabinet_narrowing", -- 159
	start = 0.65, -- 160
	["end"] = 1.12, -- 161
	zoomFrom = 1, -- 162
	zoomTo = 1.005, -- 163
	transition = "cut" -- 164
}, { -- 164
	slot = "comic_p02_08b_cabinet_shut", -- 167
	start = 1.12, -- 168
	["end"] = 1.8, -- 169
	zoomFrom = 1, -- 170
	zoomTo = 1, -- 171
	transition = "cut" -- 172
}} -- 172
local PROLOGUE_AUDIO = { -- 176
	fatherWake = "assets/audio/prologue/father_wake.wav", -- 177
	nightFire = "assets/audio/prologue/night_distant_fire.wav", -- 178
	bedCreak = "assets/audio/prologue/bed_creak.wav", -- 179
	doorCommotion = "assets/audio/prologue/door_commotion.wav", -- 180
	shadowStrike = "assets/audio/prologue/shadow_strike.wav", -- 181
	bowlRoll = "assets/audio/prologue/bowl_roll.wav", -- 182
	bowlHit = "assets/audio/prologue/bowl_hit.wav", -- 183
	heartbeat = "assets/audio/prologue/heartbeat.wav", -- 184
	cabinetShut = "assets/audio/prologue/cabinet_shut.wav", -- 185
	footstepsFade = "assets/audio/prologue/footsteps_fade.wav", -- 186
	distantGunflash = "assets/audio/prologue/distant_gunflash.wav" -- 187
} -- 187
local function clamp01(v) -- 214
	return math.max( -- 215
		0, -- 215
		math.min(1, v) -- 215
	) -- 215
end -- 214
local function smoothstep(edge0, edge1, x) -- 218
	if edge1 <= edge0 then -- 218
		return x >= edge1 and 1 or 0 -- 220
	end -- 220
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 222
	return t * t * (3 - 2 * t) -- 223
end -- 218
local function asRecord(value) -- 226
	if value ~= nil and type(value) == "table" then -- 226
		return value -- 228
	end -- 228
	return nil -- 230
end -- 226
local function readNum(rec, key) -- 233
	if rec == nil then -- 233
		return nil -- 235
	end -- 235
	local v = rec[key] -- 237
	return type(v) == "number" and v or nil -- 238
end -- 233
____exports.PrologueIntroPlugin = __TS__Class() -- 241
local PrologueIntroPlugin = ____exports.PrologueIntroPlugin -- 241
PrologueIntroPlugin.name = "PrologueIntroPlugin" -- 241
function PrologueIntroPlugin.prototype.____constructor(self) -- 241
	self.id = "fe03-prologue-intro" -- 242
	self.stage = "idle" -- 244
	self.rehearsalActive = false -- 245
	self.rehearsalSequence = false -- 246
	self.stageElapsed = 0 -- 247
	self.stageDuration = 0 -- 248
	self.escapeDuration = ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 251
	self.escapeRemaining = 0 -- 252
	self.escapePlayerX = 0 -- 253
	self.vignetteAlpha = 0 -- 254
	self.hiddenStartVignette = 0 -- 255
	self.heartbeatHz = 0 -- 256
	self.heartbeatPhase = 0 -- 257
	self.heartbeatBeatCount = 0 -- 258
	self.heartbeatPulse = 0 -- 259
	self.escapeRetryCount = 0 -- 260
	self.attemptSeq = 0 -- 261
	self.p04Active = false -- 264
	self.p04Elapsed = 0 -- 265
	self.p04FlashIntensity = 0 -- 266
	self.p04PostHintAlpha = 0 -- 267
	self.p04TriggeredOnce = false -- 268
	self.p04AnchorWorldX = 0 -- 269
	self.p04AnchorWorldY = 0 -- 270
	self.roomSessionId = 0 -- 272
	self.fireLoopActive = false -- 273
	self.lastRoomKey = "" -- 274
	self.enteredContractRehearsal = false -- 277
end -- 241
function PrologueIntroPlugin.prototype.onBindPlay(self, p, _view) -- 279
	self.roomSessionId = self.roomSessionId + 1 -- 280
	self.lastRoomKey = p.room.key -- 281
	self:clearTransientState(true) -- 282
	self:syncRuntimeHook() -- 283
end -- 279
function PrologueIntroPlugin.prototype.clearTransientState(self, clearRehearsal) -- 287
	if self.fireLoopActive and self.lastAudio ~= nil then -- 287
		self.lastAudio:stopLoop("fe03_night_fire", 0) -- 289
	end -- 289
	if clearRehearsal then -- 289
		self.rehearsalActive = false -- 292
		self.rehearsalSequence = false -- 293
		if self.enteredContractRehearsal and self.boundContract ~= nil then -- 293
			self.boundContract:exitRehearsal() -- 295
		end -- 295
		self.enteredContractRehearsal = false -- 297
	end -- 297
	self.stage = "idle" -- 299
	self.stageElapsed = 0 -- 300
	self.stageDuration = 0 -- 301
	self.escapeRemaining = 0 -- 302
	self.escapePlayerX = 0 -- 303
	self.vignetteAlpha = 0 -- 304
	self.hiddenStartVignette = 0 -- 305
	self.heartbeatHz = 0 -- 306
	self.heartbeatPhase = 0 -- 307
	self.heartbeatBeatCount = 0 -- 308
	self.heartbeatPulse = 0 -- 309
	self.escapeRetryCount = 0 -- 310
	self.p04Active = false -- 311
	self.p04Elapsed = 0 -- 312
	self.p04FlashIntensity = 0 -- 313
	self.p04PostHintAlpha = 0 -- 314
	self.p04TriggeredOnce = false -- 315
	self.fireLoopActive = false -- 316
	self.attemptSeq = self.attemptSeq + 1 -- 317
end -- 287
function PrologueIntroPlugin.prototype.syncRuntimeHook(self) -- 321
	local g = _G -- 322
	local ____temp_0 -- 323
	if g.package ~= nil then -- 323
		____temp_0 = g.package.loaded -- 323
	else -- 323
		____temp_0 = nil -- 323
	end -- 323
	local loaded = ____temp_0 -- 323
	if loaded == nil then -- 323
		return -- 325
	end -- 325
	local rawFe = loaded["watch.fe"] -- 327
	if rawFe ~= nil and type(rawFe) == "table" then -- 327
		local watchFe = rawFe -- 329
		if watchFe.prologue ~= self then -- 329
			watchFe.prologue = self -- 331
		end -- 331
		if self.boundContract == nil and watchFe.contract ~= nil and type(watchFe.contract) == "table" then -- 331
			self.boundContract = watchFe.contract -- 334
		end -- 334
	end -- 334
end -- 321
function PrologueIntroPlugin.prototype.startRehearsal(self, mode, escapeDuration, contract) -- 340
	self:clearTransientState(false) -- 341
	self.rehearsalActive = true -- 342
	self.rehearsalSequence = mode == "sequence" -- 343
	if contract ~= nil then -- 343
		self.boundContract = contract -- 345
	else -- 345
		self:syncRuntimeHook() -- 347
	end -- 347
	if self.boundContract ~= nil and not self.boundContract:isRehearsal() then -- 347
		self.boundContract:enterRehearsal("fe03-prologue") -- 350
		self.enteredContractRehearsal = true -- 351
	end -- 351
	self.escapeDuration = escapeDuration ~= nil and escapeDuration > 0.5 and escapeDuration or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 353
	if mode == "p01" or mode == "sequence" then -- 353
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 358
	elseif mode == "p02" then -- 358
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 360
	elseif mode == "p02_escape" then -- 360
		self:enterEscapeFromDoorway(false) -- 362
	elseif mode == "p04" then -- 362
		self:triggerP04(0, 0) -- 364
	end -- 364
end -- 340
function PrologueIntroPlugin.prototype.stopRehearsal(self) -- 369
	self:clearTransientState(true) -- 370
end -- 369
function PrologueIntroPlugin.prototype.seekRehearsal(self, stage, seconds) -- 374
	local t = math.max(0, seconds) -- 375
	self.rehearsalActive = true -- 376
	self.rehearsalSequence = false -- 377
	if stage == "p01_wake" then -- 377
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 379
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p01Duration, t) -- 380
		return -- 381
	end -- 381
	if stage == "p02_shadow" then -- 381
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 384
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02ShadowDuration, t) -- 385
		return -- 386
	end -- 386
	if stage == "p02_escape" then -- 386
		self:enterEscapeFromDoorway(false) -- 389
		local clamped = math.min(self.escapeDuration, t) -- 390
		self.stageElapsed = clamped -- 391
		self.escapeRemaining = math.max(0, self.escapeDuration - clamped) -- 392
		local u = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 393
		self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + u * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 394
		self.vignetteAlpha = clamp01(0.14 + u * 0.56) -- 396
		return -- 397
	end -- 397
	if stage == "p02_hidden" then -- 397
		self:enterHiddenCabinet() -- 400
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02HiddenLinger, t) -- 401
		local fadeK = clamp01(1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 402
		self.vignetteAlpha = self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut and 0 or self.hiddenStartVignette * fadeK -- 403
		return -- 406
	end -- 406
	if stage == "p04_flash" then -- 406
		self.stage = "idle" -- 409
		self:triggerP04(220, 0) -- 410
		self.p04Elapsed = math.min(____exports.PROLOGUE_TIMINGS.p04FlashDuration, t) -- 411
		self:recomputeP04Weights() -- 412
		return -- 413
	end -- 413
	self:clearTransientState(false) -- 415
end -- 374
function PrologueIntroPlugin.prototype.triggerCabinetEnter(self) -- 419
	if self.stage == "p02_escape" or self.stage == "p02_shadow" then -- 419
		self:enterHiddenCabinet() -- 421
	end -- 421
end -- 419
function PrologueIntroPlugin.prototype.retryEscape(self) -- 426
	self:enterEscapeFromDoorway(true) -- 427
end -- 426
function PrologueIntroPlugin.prototype.getSnapshot(self) -- 431
	local blocks = self.stage == "p01_wake" or self.stage == "p02_shadow" -- 432
	return { -- 433
		stage = self.stage, -- 434
		active = self.stage ~= "idle" or self.p04Active or self.p04PostHintAlpha > 0.01, -- 435
		isRehearsal = self.rehearsalActive, -- 436
		stageElapsed = self.stageElapsed, -- 437
		stageDuration = self.stageDuration, -- 438
		escapeRemaining = self.escapeRemaining, -- 439
		escapeDuration = self.escapeDuration, -- 440
		escapePlayerX = self.escapePlayerX, -- 441
		vignetteAlpha = self.vignetteAlpha, -- 442
		heartbeatHz = self.heartbeatHz, -- 443
		heartbeatBeatCount = self.heartbeatBeatCount, -- 444
		heartbeatPulse = self.heartbeatPulse, -- 445
		escapeRetryCount = self.escapeRetryCount, -- 446
		p04Active = self.p04Active, -- 447
		p04Elapsed = self.p04Elapsed, -- 448
		p04FlashIntensity = self.p04FlashIntensity, -- 449
		p04PostHintAlpha = self.p04PostHintAlpha, -- 450
		p04TriggeredOnce = self.p04TriggeredOnce, -- 451
		blocksPlayerControl = blocks, -- 452
		roomSessionId = self.roomSessionId -- 453
	} -- 453
end -- 431
function PrologueIntroPlugin.prototype.enterStage(self, next, duration) -- 457
	self.stage = next -- 458
	self.stageElapsed = 0 -- 459
	self.stageDuration = duration -- 460
	if next ~= "p02_escape" and next ~= "p02_hidden" then -- 460
		self.vignetteAlpha = 0 -- 462
		self.heartbeatHz = 0 -- 463
		self.heartbeatPulse = 0 -- 464
		self.heartbeatPhase = 0 -- 465
	end -- 465
end -- 457
function PrologueIntroPlugin.prototype.enterEscapeFromDoorway(self, isRetry) -- 469
	self.attemptSeq = self.attemptSeq + 1 -- 470
	self.stage = "p02_escape" -- 471
	self.stageElapsed = 0 -- 472
	self.stageDuration = self.escapeDuration -- 473
	self.escapeRemaining = self.escapeDuration -- 474
	self.escapePlayerX = 0 -- 475
	self.vignetteAlpha = 0 -- 477
	self.hiddenStartVignette = 0 -- 478
	self.heartbeatHz = 0 -- 479
	self.heartbeatPhase = 0 -- 480
	self.heartbeatBeatCount = 0 -- 481
	self.heartbeatPulse = 0 -- 482
	if isRetry then -- 482
		self.escapeRetryCount = self.escapeRetryCount + 1 -- 484
	end -- 484
end -- 469
function PrologueIntroPlugin.prototype.enterHiddenCabinet(self) -- 488
	self.hiddenStartVignette = self.vignetteAlpha > 0.01 and self.vignetteAlpha or 0.35 -- 489
	self.stage = "p02_hidden" -- 490
	self.stageElapsed = 0 -- 491
	self.stageDuration = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 492
	self.escapeRemaining = 0 -- 493
	self.escapePlayerX = 1 -- 494
	self.heartbeatHz = 0 -- 495
	self.heartbeatPulse = 0 -- 496
	self.heartbeatPhase = 0 -- 497
end -- 488
function PrologueIntroPlugin.prototype.triggerP04(self, anchorX, anchorY) -- 500
	self.p04Active = true -- 501
	self.p04Elapsed = 0 -- 502
	self.p04TriggeredOnce = true -- 503
	self.p04AnchorWorldX = anchorX -- 504
	self.p04AnchorWorldY = anchorY -- 505
	self:recomputeP04Weights() -- 506
end -- 500
function PrologueIntroPlugin.prototype.recomputeP04Weights(self) -- 509
	local t = self.p04Elapsed -- 510
	if t < 0.08 then -- 510
		self.p04FlashIntensity = clamp01(t / 0.08) -- 512
	elseif t < 0.55 then -- 512
		local k = (t - 0.08) / 0.47 -- 514
		local flicker = 0.86 + 0.14 * math.sin(t * 46) -- 515
		self.p04FlashIntensity = clamp01((1 - k * k) * flicker) -- 516
	else -- 516
		self.p04FlashIntensity = 0 -- 518
	end -- 518
	if t >= 0.18 then -- 518
		local reveal = smoothstep(0.18, 0.42, t) -- 521
		local settle = t > 0.55 and 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) or 0.85 -- 522
		self.p04PostHintAlpha = math.max(self.p04PostHintAlpha, reveal * settle) -- 523
		if t > 0.55 then -- 523
			self.p04PostHintAlpha = 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) -- 525
		end -- 525
	end -- 525
end -- 509
function PrologueIntroPlugin.prototype.cueKey(self, name) -- 530
	return (((("fe03:r" .. tostring(self.roomSessionId)) .. ":a") .. tostring(self.attemptSeq)) .. ":") .. name -- 531
end -- 530
function PrologueIntroPlugin.prototype.update(self, ctx) -- 534
	self.lastAudio = ctx.audio -- 535
	self:syncRuntimeHook() -- 536
	local p = ctx.p -- 537
	if self.lastRoomKey ~= "" and self.lastRoomKey ~= p.room.key then -- 537
		self:onBindPlay(p, ctx.view) -- 540
	end -- 540
	if ctx.paused or ctx.worldDt <= 0 then -- 540
		return -- 545
	end -- 545
	local dt = ctx.worldDt -- 548
	if not self.rehearsalActive then -- 548
		self:syncLiveBackendTriggers(ctx) -- 552
	end -- 552
	if self.stage == "p01_wake" then -- 552
		self:stepP01(ctx, dt) -- 557
	elseif self.stage == "p02_shadow" then -- 557
		self:stepP02Shadow(ctx, dt) -- 559
	elseif self.stage == "p02_escape" then -- 559
		self:stepP02Escape(ctx, dt) -- 561
	elseif self.stage == "p02_hidden" then -- 561
		self:stepP02Hidden(ctx, dt) -- 563
	end -- 563
	if self.p04Active then -- 563
		self:stepP04(ctx, dt) -- 568
	end -- 568
end -- 534
function PrologueIntroPlugin.prototype.syncLiveBackendTriggers(self, ctx) -- 572
	local p = ctx.p -- 573
	local pRec = asRecord(p) -- 574
	if p.room.key == "prologue" then -- 574
		local phase = p.phase -- 578
		if phase == "prologue-wake" and self.stage ~= "p01_wake" then -- 578
			self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 580
		elseif phase == "prologue-shadow" and self.stage ~= "p02_shadow" then -- 580
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 582
		elseif phase == "prologue-escape" and self.stage ~= "p02_escape" then -- 582
			local dur = readNum(pRec, "escapeDuration") or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 584
			self.escapeDuration = math.max(0.5, dur) -- 585
			self:enterEscapeFromDoorway(false) -- 586
		elseif phase == "prologue-hide" and self.stage ~= "p02_hidden" then -- 586
			self:enterHiddenCabinet() -- 588
		elseif (phase == "prologue-wait" or phase == "prologue-give" or phase == "prologue-follow") and (self.stage == "p01_wake" or self.stage == "p02_shadow" or self.stage == "p02_escape" or self.stage == "p02_hidden") then -- 588
			self.stage = "idle" -- 596
			self.vignetteAlpha = 0 -- 597
			self.heartbeatHz = 0 -- 598
			self.heartbeatPulse = 0 -- 599
		end -- 599
	end -- 599
	local i = 0 -- 604
	do -- 604
		i = 0 -- 605
		while i < #ctx.events.rawEvents do -- 605
			local ev = ctx.events.rawEvents[i + 1] -- 606
			local ename = ev.name -- 607
			if ename == "prologueBeat" and ev.data.beat == "escapeRetry" and self.stage == "p02_escape" then -- 607
				self:retryEscape() -- 609
			elseif ename == "p04WallFlash" or ename == "wallPeekFlash" then -- 609
				if not self.p04TriggeredOnce and p.run.story.segments.p04_wall_flash ~= true then -- 609
					p.run.story.segments.p04_wall_flash = true -- 612
					self:triggerP04(p.player.x, p.player.y) -- 613
				end -- 613
			end -- 613
			i = i + 1 -- 605
		end -- 605
	end -- 605
	if not self.p04TriggeredOnce and p.run.story.segments.p04_wall_flash ~= true and not p.childMode and p.player.alive and p.partner.alive then -- 605
		local inPrologueCourtyard = p.room.key == "prologue" and p.phase == "prologue-follow" and p.player.x >= p.ox + 470 and p.player.x <= p.ox + 635 -- 620
		local inStreetWallRoot = p.room.key == "street" and p.player.x >= p.ox + 115 and p.player.x <= p.ox + 265 and self:hasAliveEnemy(p) -- 623
		local inS1WellRoot = p.room.key == "s1-crossroad" and p.player.x >= p.ox + 185 and p.player.x <= p.ox + 320 -- 626
		if inPrologueCourtyard or inStreetWallRoot or inS1WellRoot then -- 626
			p.run.story.segments.p04_wall_flash = true -- 629
			self:triggerP04(p.player.x, p.player.y) -- 630
		end -- 630
	end -- 630
end -- 572
function PrologueIntroPlugin.prototype.hasAliveEnemy(self, p) -- 635
	local i = 0 -- 636
	do -- 636
		i = 0 -- 637
		while i < #p.enemies do -- 637
			if p.enemies[i + 1].alive then -- 637
				return true -- 639
			end -- 639
			i = i + 1 -- 637
		end -- 637
	end -- 637
	return false -- 642
end -- 635
function PrologueIntroPlugin.prototype.stepP01(self, ctx, dt) -- 645
	self.stageElapsed = self.stageElapsed + dt -- 646
	local tick = ctx.p.ticks -- 647
	if not self.fireLoopActive then -- 647
		self.fireLoopActive = true -- 650
		ctx.audio:playLoop( -- 651
			"fe03_night_fire", -- 651
			"ambience", -- 651
			PROLOGUE_AUDIO.nightFire, -- 651
			0.34, -- 651
			tick -- 651
		) -- 651
	end -- 651
	if self.stageElapsed >= 0.12 then -- 651
		ctx.audio:playOnce( -- 654
			self:cueKey("p01_father_call"), -- 655
			"voice", -- 656
			PROLOGUE_AUDIO.fatherWake, -- 657
			0.92, -- 658
			"prologue:p01_call", -- 659
			tick -- 660
		) -- 660
	end -- 660
	if self.stageElapsed >= 1.9 then -- 660
		ctx.audio:playOnce( -- 664
			self:cueKey("p01_bed_press"), -- 665
			"sfx", -- 666
			PROLOGUE_AUDIO.bedCreak, -- 667
			0.68, -- 668
			"prologue:p01_bed_press", -- 669
			tick -- 670
		) -- 670
	end -- 670
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p01Duration then -- 670
		if self.rehearsalSequence then -- 670
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 676
		elseif self.rehearsalActive then -- 676
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p01Duration -- 678
			self.stage = "idle" -- 679
		else -- 679
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p01Duration -- 682
		end -- 682
	end -- 682
end -- 645
function PrologueIntroPlugin.prototype.stepP02Shadow(self, ctx, dt) -- 687
	self.stageElapsed = self.stageElapsed + dt -- 688
	local tick = ctx.p.ticks -- 689
	if self.stageElapsed >= 0.1 then -- 689
		ctx.audio:playOnce( -- 692
			self:cueKey("p02_door_commotion"), -- 693
			"ambience", -- 694
			PROLOGUE_AUDIO.doorCommotion, -- 695
			0.62, -- 696
			"prologue:p02_commotion", -- 697
			tick -- 698
		) -- 698
	end -- 698
	if self.stageElapsed >= 1.55 then -- 698
		ctx.audio:playOnce( -- 702
			self:cueKey("p02_shadow_strike"), -- 703
			"sfx", -- 704
			PROLOGUE_AUDIO.shadowStrike, -- 705
			0.88, -- 706
			"prologue:p02_shadow_cut", -- 707
			tick -- 708
		) -- 708
	end -- 708
	if self.stageElapsed >= 2.78 then -- 708
		ctx.audio:playOnce( -- 712
			self:cueKey("p02_bowl_roll"), -- 713
			"sfx", -- 714
			PROLOGUE_AUDIO.bowlRoll, -- 715
			0.78, -- 716
			"prologue:p02_bowl_roll", -- 717
			tick -- 718
		) -- 718
	end -- 718
	if self.stageElapsed >= 3.88 then -- 718
		ctx.audio:playOnce( -- 722
			self:cueKey("p02_bowl_hit"), -- 723
			"sfx", -- 724
			PROLOGUE_AUDIO.bowlHit, -- 725
			0.92, -- 726
			"prologue:p02_bowl_hit", -- 727
			tick -- 728
		) -- 728
	end -- 728
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02ShadowDuration then -- 728
		if self.rehearsalActive then -- 728
			self:enterEscapeFromDoorway(false) -- 735
		else -- 735
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02ShadowDuration -- 738
		end -- 738
	end -- 738
end -- 687
function PrologueIntroPlugin.prototype.stepP02Escape(self, ctx, dt) -- 743
	self.stageElapsed = self.stageElapsed + dt -- 744
	local pRec = asRecord(ctx.p) -- 747
	local liveRemain = readNum(pRec, "escapeRemaining") -- 748
	if not self.rehearsalActive and liveRemain ~= nil then -- 748
		self.escapeRemaining = math.max(0, liveRemain) -- 750
	else -- 750
		self.escapeRemaining = math.max(0, self.escapeRemaining - dt) -- 752
	end -- 752
	if self.rehearsalActive then -- 752
		if ctx.input.moveX ~= 0 then -- 752
			self.escapePlayerX = clamp01(self.escapePlayerX + ctx.input.moveX * dt * 0.34) -- 758
		end -- 758
		if self.escapePlayerX >= 0.85 and ctx.input.interact.pressed or self.escapePlayerX >= 0.98 then -- 758
			self:enterHiddenCabinet() -- 761
			return -- 762
		end -- 762
	end -- 762
	if self.escapeRemaining <= 0 and (self.rehearsalActive or liveRemain == nil) then -- 762
		self:retryEscape() -- 768
		return -- 769
	end -- 769
	local urgency = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 772
	self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + urgency * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 773
	local prevCycle = math.floor(self.heartbeatPhase) -- 776
	self.heartbeatPhase = self.heartbeatPhase + dt * self.heartbeatHz -- 777
	local currCycle = math.floor(self.heartbeatPhase) -- 778
	if currCycle > prevCycle then -- 778
		self.heartbeatBeatCount = self.heartbeatBeatCount + 1 -- 780
		self.heartbeatPulse = 1 -- 781
		ctx.audio:playOnce( -- 782
			self:cueKey("p02_hb_" .. tostring(self.heartbeatBeatCount)), -- 783
			"sfx", -- 784
			PROLOGUE_AUDIO.heartbeat, -- 785
			0.44 + 0.48 * urgency, -- 786
			"prologue:p02_heartbeat:" .. tostring(self.heartbeatBeatCount), -- 787
			ctx.p.ticks -- 788
		) -- 788
	else -- 788
		local frac = self.heartbeatPhase - currCycle -- 792
		if frac >= 0.2 and frac <= 0.28 then -- 792
			self.heartbeatPulse = math.max(self.heartbeatPulse, 0.56) -- 794
		end -- 794
		self.heartbeatPulse = math.max(0, self.heartbeatPulse - dt * 3.8) -- 796
	end -- 796
	self.vignetteAlpha = clamp01(0.14 + urgency * 0.54 + self.heartbeatPulse * 0.16) -- 800
end -- 743
function PrologueIntroPlugin.prototype.stepP02Hidden(self, ctx, dt) -- 803
	self.stageElapsed = self.stageElapsed + dt -- 804
	local tick = ctx.p.ticks -- 805
	ctx.audio:playOnce( -- 807
		self:cueKey("p02_cabinet_shut"), -- 808
		"sfx", -- 809
		PROLOGUE_AUDIO.cabinetShut, -- 810
		0.78, -- 811
		"prologue:p02_cabinet_shut", -- 812
		tick -- 813
	) -- 813
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut then -- 813
		self.vignetteAlpha = 0 -- 818
	else -- 818
		self.vignetteAlpha = self.hiddenStartVignette * (1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 820
	end -- 820
	self.heartbeatHz = 0 -- 823
	self.heartbeatPulse = 0 -- 824
	if self.stageElapsed >= 0.3 then -- 824
		ctx.audio:playOnce( -- 828
			self:cueKey("p02_footsteps_fade"), -- 829
			"sfx", -- 830
			PROLOGUE_AUDIO.footstepsFade, -- 831
			0.65, -- 832
			"prologue:p02_footsteps_fade", -- 833
			tick -- 834
		) -- 834
	end -- 834
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenLinger then -- 834
		self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 839
		self.vignetteAlpha = 0 -- 840
	end -- 840
end -- 803
function PrologueIntroPlugin.prototype.stepP04(self, ctx, dt) -- 844
	if self.p04Elapsed == 0 then -- 844
		ctx.audio:playOnce( -- 846
			self:cueKey("p04_gunflash"), -- 847
			"sfx", -- 848
			PROLOGUE_AUDIO.distantGunflash, -- 849
			0.78, -- 850
			"prologue:p04_gunflash", -- 851
			ctx.p.ticks -- 852
		) -- 852
	end -- 852
	self.p04Elapsed = self.p04Elapsed + dt -- 855
	self:recomputeP04Weights() -- 856
	if self.p04Elapsed >= ____exports.PROLOGUE_TIMINGS.p04FlashDuration then -- 856
		self.p04Elapsed = ____exports.PROLOGUE_TIMINGS.p04FlashDuration -- 858
		self.p04FlashIntensity = 0 -- 859
		self.p04Active = false -- 860
		self.p04PostHintAlpha = 0.42 -- 862
	end -- 862
end -- 844
function PrologueIntroPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 867
	if self.stage == "p02_escape" and not self.rehearsalActive and ctx.p.room.key == "prologue" then -- 867
		local cam = ctx.cam -- 874
		local cabX = cam:sx(ctx.p.ox + PROLOGUE_CABINET_X + 18) -- 875
		local cabY = cam:sy(0, 0) -- 876
		local pulse = 0.65 + 0.35 * math.sin(self.stageElapsed * 6.5) -- 877
		local sway = math.sin(self.stageElapsed * 9) * cam:len(2.5) -- 878
		fillRadialGlow( -- 880
			fgGlow, -- 881
			cabX + sway, -- 882
			cabY + cam:len(34), -- 883
			cam:len(38), -- 884
			cam:len(46), -- 885
			Color( -- 886
				232, -- 886
				178, -- 886
				104, -- 886
				math.floor(68 * pulse + 0.5) -- 886
			), -- 886
			Color(186, 118, 56, 0), -- 887
			14 -- 888
		) -- 888
		fgDraw:drawSegment( -- 890
			Vec2( -- 891
				cabX + sway, -- 891
				cabY + cam:len(4) -- 891
			), -- 891
			Vec2( -- 892
				cabX + sway, -- 892
				cabY + cam:len(54) -- 892
			), -- 892
			2, -- 893
			Color( -- 894
				238, -- 894
				198, -- 894
				134, -- 894
				math.floor(165 * pulse + 0.5) -- 894
			) -- 894
		) -- 894
	end -- 894
	if not self.p04Active and self.p04PostHintAlpha <= 0.01 then -- 894
		return -- 898
	end -- 898
	self:drawP04WorldAction(fgDraw, fgGlow, worldArt, ctx) -- 900
end -- 867
function PrologueIntroPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 904
	if self.stage == "p01_wake" then -- 904
		self:drawP01Wake( -- 912
			uiDraw, -- 912
			uiInkDraw, -- 912
			uiArt, -- 912
			uiGlow, -- 912
			ctx -- 912
		) -- 912
		return true -- 913
	end -- 913
	if self.stage == "p02_shadow" then -- 913
		self:drawP02ShadowAndBowl( -- 916
			uiDraw, -- 916
			uiInkDraw, -- 916
			uiArt, -- 916
			uiGlow, -- 916
			ctx -- 916
		) -- 916
		return true -- 917
	end -- 917
	if self.stage == "p02_escape" then -- 917
		self:drawP02EscapeVignette(uiDraw, uiInkDraw, uiGlow, ctx) -- 920
		return true -- 922
	end -- 922
	if self.stage == "p02_hidden" then -- 922
		self:drawP02HiddenCabinet( -- 925
			uiDraw, -- 925
			uiInkDraw, -- 925
			uiArt, -- 925
			uiGlow, -- 925
			ctx -- 925
		) -- 925
		return true -- 926
	end -- 926
	return false -- 928
end -- 904
function PrologueIntroPlugin.prototype.drawP01Wake(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 933
	local w = ctx.uiW -- 940
	local h = ctx.uiH -- 941
	local t = self.stageElapsed -- 942
	uiDraw:drawRect( -- 945
		Rect(0, 0, w, h), -- 945
		Color(6, 7, 11, 255) -- 945
	) -- 945
	local wakeOpen = smoothstep(0.75, 2.1, t) -- 948
	local blinkDip = t >= 1.25 and t <= 1.62 and math.sin((t - 1.25) / 0.37 * math.pi) * 0.24 or 0 -- 949
	local eyeOpen = clamp01(wakeOpen - blinkDip) -- 950
	local sitPan = smoothstep(2.65, 3.85, t) -- 951
	local handPress = smoothstep(1.75, 2.35, t) * (1 - smoothstep(3.15, 3.85, t) * 0.65) -- 952
	local fadeOut = 1 - smoothstep(3.72, 4, t) -- 953
	if eyeOpen > 0.01 then -- 953
		local panX = -sitPan * w * 0.16 -- 956
		local sitLiftY = sitPan * h * 0.06 -- 957
		local fireFlicker = 0.84 + 0.16 * math.sin(t * 9.5) * math.cos(t * 5.2) -- 958
		fillVGradRect( -- 961
			uiDraw, -- 962
			0, -- 963
			0, -- 964
			w, -- 965
			h, -- 966
			Color( -- 967
				16, -- 967
				14, -- 967
				18, -- 967
				math.floor(255 * eyeOpen * fadeOut + 0.5) -- 967
			), -- 967
			Color( -- 968
				34, -- 968
				24, -- 968
				24, -- 968
				math.floor(255 * eyeOpen * fadeOut + 0.5) -- 968
			) -- 968
		) -- 968
		uiArt:tryPlacePath( -- 970
			"assets/art/tex_diorama_ming.clip|ming_cloth", -- 971
			"p01_canopy_linen", -- 972
			w * 0.5 + panX * 0.45 + math.sin(t * 1.1) * 6, -- 973
			h * 0.62 - sitLiftY * 0.5, -- 974
			w * 1.32, -- 975
			h * 0.84, -- 976
			{ -- 977
				color = Color(74, 62, 54, 255), -- 978
				opacity = 0.44 * eyeOpen * fadeOut, -- 979
				smooth = true, -- 980
				layer = -2 -- 981
			} -- 981
		) -- 981
		fillRadialGlow( -- 985
			uiGlow, -- 986
			w * 0.34 + panX * 0.4, -- 987
			h * 0.62 - sitLiftY, -- 988
			w * 0.42, -- 989
			h * 0.36, -- 990
			Color( -- 991
				186, -- 991
				108, -- 991
				56, -- 991
				math.floor(68 * fireFlicker * eyeOpen * fadeOut + 0.5) -- 991
			), -- 991
			Color(120, 52, 28, 0), -- 992
			18 -- 993
		) -- 993
		local fold = 0 -- 996
		do -- 996
			fold = 0 -- 997
			while fold < 11 do -- 997
				local fx = w * (0.04 + fold * 0.095) + panX * 0.55 + math.sin(t * 1.4 + fold) * 4 -- 998
				local fw = 22 + fold % 3 * 10 -- 999
				local col = fold & 1 == 0 and Color( -- 1000
					52, -- 1001
					42, -- 1001
					36, -- 1001
					math.floor(48 * eyeOpen * fadeOut + 0.5) -- 1001
				) or Color( -- 1001
					24, -- 1002
					20, -- 1002
					22, -- 1002
					math.floor(62 * eyeOpen * fadeOut + 0.5) -- 1002
				) -- 1002
				fillHGradRect( -- 1003
					uiDraw, -- 1003
					fx, -- 1003
					h * 0.24, -- 1003
					fw, -- 1003
					h * 0.72, -- 1003
					Color(col.r, col.g, col.b, 0), -- 1003
					col -- 1003
				) -- 1003
				fold = fold + 1 -- 997
			end -- 997
		end -- 997
		local doorVis = smoothstep(2.25, 3.2, t) -- 1007
		if doorVis > 0.01 then -- 1007
			local doorX = w * 0.84 + panX * 0.95 -- 1009
			local crackW = 14 + sitPan * 18 -- 1010
			local doorBot = h * 0.14 - sitLiftY * 0.4 -- 1011
			local doorH = h * 0.72 -- 1012
			uiDraw:drawRect( -- 1014
				Rect(doorX - 46, doorBot, 46, doorH), -- 1014
				Color( -- 1014
					14, -- 1014
					12, -- 1014
					14, -- 1014
					math.floor(235 * doorVis * fadeOut + 0.5) -- 1014
				) -- 1014
			) -- 1014
			uiDraw:drawRect( -- 1015
				Rect(doorX + crackW, doorBot, 54, doorH), -- 1015
				Color( -- 1015
					14, -- 1015
					12, -- 1015
					14, -- 1015
					math.floor(235 * doorVis * fadeOut + 0.5) -- 1015
				) -- 1015
			) -- 1015
			fillVGradRect( -- 1017
				uiDraw, -- 1018
				doorX, -- 1019
				doorBot, -- 1020
				crackW, -- 1021
				doorH, -- 1022
				Color( -- 1023
					142, -- 1023
					168, -- 1023
					186, -- 1023
					math.floor(170 * doorVis * fadeOut + 0.5) -- 1023
				), -- 1023
				Color( -- 1024
					214, -- 1024
					168, -- 1024
					118, -- 1024
					math.floor(195 * doorVis * fireFlicker * fadeOut + 0.5) -- 1024
				) -- 1024
			) -- 1024
			fillGradQuad( -- 1026
				uiGlow, -- 1027
				doorX, -- 1028
				doorBot, -- 1028
				Color( -- 1028
					164, -- 1028
					188, -- 1028
					204, -- 1028
					math.floor(64 * doorVis * fadeOut + 0.5) -- 1028
				), -- 1028
				doorX + crackW, -- 1029
				doorBot, -- 1029
				Color( -- 1029
					214, -- 1029
					164, -- 1029
					108, -- 1029
					math.floor(54 * doorVis * fadeOut + 0.5) -- 1029
				), -- 1029
				doorX - 135, -- 1030
				doorBot - 40, -- 1030
				Color(120, 148, 170, 0), -- 1030
				doorX - 190, -- 1031
				doorBot + doorH * 0.48, -- 1031
				Color(180, 130, 82, 0) -- 1031
			) -- 1031
		end -- 1031
		local bedTopY = h * 0.27 - sitLiftY -- 1036
		local dipX = w * 0.52 + panX * 0.7 -- 1037
		local pressDepth = 22 * handPress -- 1038
		uiDraw:drawPolygon( -- 1040
			{ -- 1040
				Vec2(0, 0), -- 1041
				Vec2(w, 0), -- 1042
				Vec2(w, bedTopY + 10), -- 1043
				Vec2(dipX + 110, bedTopY + 6), -- 1044
				Vec2(dipX + 38, bedTopY - pressDepth * 0.85), -- 1045
				Vec2(dipX - 34, bedTopY - pressDepth), -- 1046
				Vec2(dipX - 108, bedTopY + 5), -- 1047
				Vec2(0, bedTopY + 12) -- 1048
			}, -- 1048
			Color( -- 1049
				30, -- 1049
				27, -- 1049
				32, -- 1049
				math.floor(248 * eyeOpen * fadeOut + 0.5) -- 1049
			) -- 1049
		) -- 1049
		uiInkDraw:drawSegment( -- 1052
			Vec2(dipX - 96, bedTopY + 4), -- 1053
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 1054
			1.6, -- 1055
			Color( -- 1056
				124, -- 1056
				114, -- 1056
				102, -- 1056
				math.floor(145 * eyeOpen * fadeOut + 0.5) -- 1056
			) -- 1056
		) -- 1056
		uiInkDraw:drawSegment( -- 1058
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 1059
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 1060
			1.4, -- 1061
			Color( -- 1062
				92, -- 1062
				82, -- 1062
				74, -- 1062
				math.floor(165 * eyeOpen * fadeOut + 0.5) -- 1062
			) -- 1062
		) -- 1062
		uiInkDraw:drawSegment( -- 1064
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 1065
			Vec2(dipX + 106, bedTopY + 5), -- 1066
			1.5, -- 1067
			Color( -- 1068
				138, -- 1068
				122, -- 1068
				106, -- 1068
				math.floor(140 * eyeOpen * fadeOut + 0.5) -- 1068
			) -- 1068
		) -- 1068
		if handPress > 0.02 then -- 1068
			local hx = dipX -- 1073
			local hy = bedTopY - pressDepth + 12 -- 1074
			local handOp = handPress * fadeOut -- 1075
			local warmR = math.floor(218 + 26 * fireFlicker + 0.5) -- 1076
			local warmG = math.floor(192 + 18 * fireFlicker + 0.5) -- 1077
			local warmB = math.floor(172 + 10 * fireFlicker + 0.5) -- 1078
			if not uiArt:tryPlacePath( -- 1078
				"assets/art/cutscene_story_parts.clip|prologue_father_hand", -- 1080
				"p01_father_hand", -- 1081
				hx + 18, -- 1082
				hy + 32, -- 1083
				360, -- 1084
				295, -- 1085
				{ -- 1086
					anchorX = 0.48, -- 1087
					anchorY = 0.36, -- 1088
					color = Color(warmR, warmG, warmB, 255), -- 1089
					opacity = handOp, -- 1090
					smooth = true, -- 1091
					layer = 2 -- 1092
				} -- 1092
			) then -- 1092
				local ha = math.floor(245 * handOp + 0.5) -- 1095
				uiDraw:drawPolygon( -- 1096
					{ -- 1096
						Vec2(hx - 62, hy + 135), -- 1097
						Vec2(hx - 14, hy + 142), -- 1098
						Vec2(hx + 8, hy + 28), -- 1099
						Vec2(hx - 36, hy + 24) -- 1100
					}, -- 1100
					Color(42, 46, 54, ha) -- 1101
				) -- 1101
				uiDraw:drawPolygon( -- 1102
					{ -- 1102
						Vec2(hx - 38, hy + 26), -- 1103
						Vec2(hx + 16, hy + 28), -- 1104
						Vec2(hx + 34, hy + 2), -- 1105
						Vec2(hx + 22, hy - 14), -- 1106
						Vec2(hx - 26, hy - 12), -- 1107
						Vec2(hx - 42, hy + 4) -- 1108
					}, -- 1108
					Color(148, 112, 86, ha) -- 1109
				) -- 1109
			end -- 1109
		end -- 1109
	end -- 1109
	local lidH = h * 0.52 * (1 - eyeOpen) -- 1115
	if lidH > 1 then -- 1115
		ctx.uiMask:drawRect( -- 1117
			Rect(0, h - lidH, w, lidH), -- 1117
			Color(5, 6, 9, 255) -- 1117
		) -- 1117
		ctx.uiMask:drawRect( -- 1118
			Rect(0, 0, w, lidH), -- 1118
			Color(5, 6, 9, 255) -- 1118
		) -- 1118
		local feather = math.min(46, h * 0.08) -- 1119
		fillVGradRect( -- 1120
			ctx.uiMask, -- 1120
			0, -- 1120
			h - lidH - feather, -- 1120
			w, -- 1120
			feather, -- 1120
			Color(5, 6, 9, 0), -- 1120
			Color(5, 6, 9, 235) -- 1120
		) -- 1120
		fillVGradRect( -- 1121
			ctx.uiMask, -- 1121
			0, -- 1121
			lidH, -- 1121
			w, -- 1121
			feather, -- 1121
			Color(5, 6, 9, 235), -- 1121
			Color(5, 6, 9, 0) -- 1121
		) -- 1121
	end -- 1121
	if self.rehearsalActive then -- 1121
		local callAlpha = smoothstep(0.1, 0.32, t) * (1 - smoothstep(1.05, 1.55, t)) -- 1126
		if callAlpha > 0.02 then -- 1126
			drawSilkVeil( -- 1128
				uiDraw, -- 1128
				uiArt, -- 1128
				"p01_call_veil", -- 1128
				w * 0.5, -- 1128
				h * 0.14, -- 1128
				240, -- 1128
				44, -- 1128
				PALETTE.inkWash, -- 1128
				0.72 * callAlpha, -- 1128
				0 -- 1128
			) -- 1128
			ctx.texts:put( -- 1129
				"sm", -- 1130
				"「小满。」", -- 1131
				w * 0.5, -- 1132
				h * 0.14, -- 1133
				toColor(PALETTE.textBright), -- 1134
				0.5, -- 1135
				0.5, -- 1136
				"Center", -- 1137
				2, -- 1138
				callAlpha, -- 1139
				0.08 -- 1140
			) -- 1140
		end -- 1140
	end -- 1140
end -- 933
function PrologueIntroPlugin.prototype.drawP02ShadowAndBowl(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 1148
	local w = ctx.uiW -- 1155
	local h = ctx.uiH -- 1156
	local t = self.stageElapsed -- 1157
	local barH = math.floor(h * 0.068 + 0.5) -- 1158
	drawComicSequence( -- 1159
		uiDraw, -- 1160
		uiInkDraw, -- 1161
		uiArt, -- 1162
		P02_SHADOW_COMIC_SEQ, -- 1163
		t, -- 1164
		w, -- 1165
		h, -- 1166
		{ -- 1167
			letterboxH = barH, -- 1168
			opacity = 1, -- 1169
			layer = 2, -- 1170
			instancePrefix = "fe03_p02_shadow", -- 1171
			accentBorder = true -- 1172
		} -- 1172
	) -- 1172
end -- 1148
function PrologueIntroPlugin.prototype.drawP02EscapeVignette(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1179
	local w = ctx.uiW -- 1185
	local h = ctx.uiH -- 1186
	local a = clamp01(self.vignetteAlpha) -- 1187
	if a > 0.005 then -- 1187
		local edgeX = w * (0.09 + 0.06 * a) -- 1190
		local edgeY = h * (0.11 + 0.07 * a) -- 1191
		local peakA = math.floor(168 * a + 0.5) -- 1192
		local deep = PALETTE.crimsonDeep -- 1193
		local rouge = PALETTE.rouge -- 1194
		local cEdge = Color(deep.r, deep.g, deep.b, peakA) -- 1195
		local cZero = Color(deep.r, deep.g, deep.b, 0) -- 1196
		fillHGradRect( -- 1198
			uiDraw, -- 1198
			0, -- 1198
			0, -- 1198
			edgeX, -- 1198
			h, -- 1198
			cEdge, -- 1198
			cZero -- 1198
		) -- 1198
		fillHGradRect( -- 1199
			uiDraw, -- 1199
			w - edgeX, -- 1199
			0, -- 1199
			edgeX, -- 1199
			h, -- 1199
			cZero, -- 1199
			cEdge -- 1199
		) -- 1199
		fillVGradRect( -- 1200
			uiDraw, -- 1200
			0, -- 1200
			0, -- 1200
			w, -- 1200
			edgeY, -- 1200
			cEdge, -- 1200
			cZero -- 1200
		) -- 1200
		fillVGradRect( -- 1201
			uiDraw, -- 1201
			0, -- 1201
			h - edgeY, -- 1201
			w, -- 1201
			edgeY, -- 1201
			cZero, -- 1201
			cEdge -- 1201
		) -- 1201
		if self.heartbeatPulse > 0.02 then -- 1201
			local pa = math.floor(62 * self.heartbeatPulse * a + 0.5) -- 1205
			local cPulse = Color(rouge.r, rouge.g, rouge.b, pa) -- 1206
			local cPulseZero = Color(rouge.r, rouge.g, rouge.b, 0) -- 1207
			fillHGradRect( -- 1208
				uiGlow, -- 1208
				0, -- 1208
				0, -- 1208
				edgeX * 0.72, -- 1208
				h, -- 1208
				cPulse, -- 1208
				cPulseZero -- 1208
			) -- 1208
			fillHGradRect( -- 1209
				uiGlow, -- 1209
				w - edgeX * 0.72, -- 1209
				0, -- 1209
				edgeX * 0.72, -- 1209
				h, -- 1209
				cPulseZero, -- 1209
				cPulse -- 1209
			) -- 1209
		end -- 1209
	end -- 1209
	if self.rehearsalActive then -- 1209
		local groundY = h * 0.24 -- 1215
		local doorX = w * 0.14 -- 1216
		local cabX = w * 0.8 -- 1217
		local childX = doorX + (cabX - doorX) * self.escapePlayerX -- 1218
		local wobble = math.sin(self.stageElapsed * 9.5) * 4 -- 1219
		uiInkDraw:drawRect( -- 1222
			Rect(doorX - 18, groundY, 16, 130), -- 1222
			Color(48, 36, 28, 220) -- 1222
		) -- 1222
		uiDraw:drawCircle( -- 1223
			Vec2(doorX + 18, groundY + 8), -- 1223
			8, -- 1223
			Color(168, 164, 152, 220) -- 1223
		) -- 1223
		uiDraw:drawRect( -- 1225
			Rect(cabX, groundY, 74, 108), -- 1225
			Color(42, 31, 24, 240), -- 1225
			1.2, -- 1225
			Color(118, 92, 68, 195) -- 1225
		) -- 1225
		uiInkDraw:drawSegment( -- 1226
			Vec2(cabX + 8 + wobble * 0.5, groundY + 6), -- 1226
			Vec2(cabX + 8 + wobble * 0.5, groundY + 100), -- 1226
			2.2, -- 1226
			Color(176, 144, 106, 210) -- 1226
		) -- 1226
		if not ctx.uiArt:tryPlaceRun( -- 1226
			"child", -- 1228
			"p02_escape_child", -- 1228
			childX, -- 1228
			groundY, -- 1228
			46, -- 1228
			74, -- 1228
			self.stageElapsed * 1.8, -- 1228
			{facing = 1, layer = 3} -- 1228
		) then -- 1228
			uiDraw:drawRect( -- 1232
				Rect(childX - 12, groundY, 24, 54), -- 1232
				Color(168, 72, 54, 235) -- 1232
			) -- 1232
		end -- 1232
	end -- 1232
end -- 1179
function PrologueIntroPlugin.prototype.drawP02HiddenCabinet(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 1239
	local w = ctx.uiW -- 1246
	local h = ctx.uiH -- 1247
	local t = self.stageElapsed -- 1248
	drawComicSequence( -- 1250
		uiDraw, -- 1251
		uiInkDraw, -- 1252
		uiArt, -- 1253
		P02_HIDDEN_COMIC_SEQ, -- 1254
		t, -- 1255
		w, -- 1256
		h, -- 1257
		{ -- 1258
			letterboxH = math.floor(h * 0.055 + 0.5), -- 1259
			opacity = 1, -- 1260
			layer = 3, -- 1261
			instancePrefix = "fe03_p02_hidden", -- 1262
			accentBorder = false -- 1263
		} -- 1263
	) -- 1263
	if self.vignetteAlpha > 0.005 then -- 1263
		local a = math.floor(140 * self.vignetteAlpha + 0.5) -- 1269
		local edge = w * 0.08 -- 1270
		fillHGradRect( -- 1271
			uiInkDraw, -- 1271
			0, -- 1271
			0, -- 1271
			edge, -- 1271
			h, -- 1271
			Color(124, 38, 42, a), -- 1271
			Color(124, 38, 42, 0) -- 1271
		) -- 1271
		fillHGradRect( -- 1272
			uiInkDraw, -- 1272
			w - edge, -- 1272
			0, -- 1272
			edge, -- 1272
			h, -- 1272
			Color(124, 38, 42, 0), -- 1272
			Color(124, 38, 42, a) -- 1272
		) -- 1272
	end -- 1272
end -- 1239
function PrologueIntroPlugin.prototype.drawP04WorldAction(self, fgDraw, fgGlow, worldArt, ctx) -- 1278
	local p = ctx.p -- 1284
	local cam = ctx.cam -- 1285
	local flash = self.p04FlashIntensity -- 1286
	local hintAlpha = self.p04PostHintAlpha -- 1287
	local zhou = p.childMode and p.partner or p.player -- 1289
	local xiao = p.childMode and p.player or p.partner -- 1290
	local zX = cam:sx(zhou.x) -- 1291
	local zY = cam:sy(zhou.y, zhou.depth) -- 1292
	local zH = cam:len(zhou.h) -- 1293
	local xX = cam:sx(xiao.x) -- 1294
	local xY = cam:sy(xiao.y, xiao.depth) -- 1295
	local xH = cam:len(xiao.h) -- 1296
	if flash > 0.01 then -- 1296
		fillGradQuad( -- 1301
			fgGlow, -- 1302
			cam.viewW, -- 1303
			cam.groundScreenY + cam:len(18), -- 1303
			Color( -- 1303
				238, -- 1303
				178, -- 1303
				108, -- 1303
				math.floor(96 * flash + 0.5) -- 1303
			), -- 1303
			cam.viewW, -- 1304
			cam.groundScreenY + cam:len(195), -- 1304
			Color( -- 1304
				224, -- 1304
				148, -- 1304
				82, -- 1304
				math.floor(72 * flash + 0.5) -- 1304
			), -- 1304
			zX - cam:len(140), -- 1305
			cam.groundScreenY + cam:len(140), -- 1305
			Color(200, 120, 62, 0), -- 1305
			zX - cam:len(140), -- 1306
			cam.groundScreenY, -- 1306
			Color(200, 120, 62, 0) -- 1306
		) -- 1306
		local wallBaseY = cam.groundScreenY + cam:len(14) -- 1310
		local shAlpha = math.floor(148 * flash + 0.5) -- 1311
		local shCol = Color(8, 10, 14, shAlpha) -- 1312
		fgDraw:drawPolygon( -- 1314
			{ -- 1314
				Vec2( -- 1315
					zX - cam:len(14), -- 1315
					wallBaseY -- 1315
				), -- 1315
				Vec2( -- 1316
					zX + cam:len(6), -- 1316
					wallBaseY -- 1316
				), -- 1316
				Vec2( -- 1317
					zX - cam:len(38), -- 1317
					wallBaseY + zH * 1.18 -- 1317
				), -- 1317
				Vec2( -- 1318
					zX - cam:len(64), -- 1318
					wallBaseY + zH * 1.12 -- 1318
				) -- 1318
			}, -- 1318
			shCol -- 1319
		) -- 1319
		fgDraw:drawPolygon( -- 1321
			{ -- 1321
				Vec2( -- 1322
					xX - cam:len(10), -- 1322
					wallBaseY -- 1322
				), -- 1322
				Vec2( -- 1323
					xX + cam:len(6), -- 1323
					wallBaseY -- 1323
				), -- 1323
				Vec2( -- 1324
					xX - cam:len(26), -- 1324
					wallBaseY + xH * 1.12 -- 1324
				), -- 1324
				Vec2( -- 1325
					xX - cam:len(44), -- 1325
					wallBaseY + xH * 1.06 -- 1325
				) -- 1325
			}, -- 1325
			shCol -- 1326
		) -- 1326
		local shieldK = smoothstep(0.1, 0.24, self.p04Elapsed) * (1 - smoothstep(0.5, 0.78, self.p04Elapsed)) -- 1329
		if shieldK > 0.02 then -- 1329
			local armX = zX + cam:len(10) -- 1331
			local armY = zY + zH * 0.66 -- 1332
			local cuffW = cam:len(13) -- 1333
			local cuffH = cam:len(7) -- 1334
			local sa = math.floor(235 * shieldK + 0.5) -- 1335
			fgDraw:drawPolygon( -- 1336
				{ -- 1336
					Vec2( -- 1337
						zX + cam:len(2), -- 1337
						armY - cuffH * 0.4 -- 1337
					), -- 1337
					Vec2(armX + cuffW, armY + cuffH * 0.9), -- 1338
					Vec2(armX + cuffW * 0.72, armY + cuffH * 1.75), -- 1339
					Vec2( -- 1340
						zX - cam:len(2), -- 1340
						armY + cuffH * 0.5 -- 1340
					) -- 1340
				}, -- 1340
				toColor(____exports.CUFF_SHARED_SPEC.indigoCloth, sa) -- 1341
			) -- 1341
			fgDraw:drawSegment( -- 1343
				Vec2(armX + cuffW * 0.45, armY + cuffH * 0.75), -- 1344
				Vec2(armX + cuffW * 0.82, armY + cuffH * 1.25), -- 1345
				1.3, -- 1346
				toColor( -- 1347
					____exports.CUFF_SHARED_SPEC.mendStitch, -- 1347
					math.floor(210 * shieldK + 0.5) -- 1347
				) -- 1347
			) -- 1347
			fillGradQuad( -- 1350
				fgDraw, -- 1351
				zX + cam:len(4), -- 1352
				zY + zH * 0.85, -- 1352
				Color( -- 1352
					10, -- 1352
					12, -- 1352
					18, -- 1352
					math.floor(92 * shieldK + 0.5) -- 1352
				), -- 1352
				zX + cam:len(4), -- 1353
				zY, -- 1353
				Color( -- 1353
					10, -- 1353
					12, -- 1353
					18, -- 1353
					math.floor(62 * shieldK + 0.5) -- 1353
				), -- 1353
				xX - cam:len(18), -- 1354
				xY, -- 1354
				Color(10, 12, 18, 0), -- 1354
				xX - cam:len(18), -- 1355
				xY + xH, -- 1355
				Color(10, 12, 18, 0) -- 1355
			) -- 1355
		end -- 1355
	end -- 1355
	if hintAlpha > 0.02 then -- 1355
		local baseWx = self.p04AnchorWorldX > 0 and self.p04AnchorWorldX or zhou.x -- 1362
		local hintBaseX = cam:sx(baseWx + 74) -- 1363
		local groundY = cam:sy(0, 0) -- 1364
		local boardW = cam:len(62) -- 1365
		local sheenBoost = flash * 0.55 -- 1366
		local aNorm = clamp01(hintAlpha + sheenBoost) -- 1367
		local placedBoard = worldArt:tryPlacePath( -- 1369
			"assets/art/cutscene_well_museum.clip|p04_window_board", -- 1370
			"p04_polished_window_board", -- 1371
			hintBaseX + boardW * 0.5, -- 1372
			groundY - 2, -- 1373
			boardW * 1.15, -- 1374
			cam:len(68), -- 1375
			{ -- 1376
				anchorX = 0.5, -- 1377
				anchorY = 0, -- 1378
				color = Color( -- 1379
					math.floor(188 + 64 * flash + 0.5), -- 1380
					math.floor(184 + 54 * flash + 0.5), -- 1381
					math.floor(176 + 34 * flash + 0.5), -- 1382
					255 -- 1383
				), -- 1383
				opacity = 0.88 * aNorm, -- 1385
				smooth = true, -- 1386
				layer = 4200 -- 1387
			} -- 1387
		) -- 1387
		if not placedBoard then -- 1387
			local boardY = groundY + cam:len(34) -- 1391
			fgDraw:drawRect( -- 1392
				Rect( -- 1393
					hintBaseX, -- 1393
					boardY, -- 1393
					boardW, -- 1393
					cam:len(12) -- 1393
				), -- 1393
				Color( -- 1394
					54, -- 1394
					42, -- 1394
					32, -- 1394
					math.floor(165 * aNorm + 0.5) -- 1394
				), -- 1394
				1, -- 1395
				Color( -- 1396
					126, -- 1396
					102, -- 1396
					76, -- 1396
					math.floor(150 * aNorm + 0.5) -- 1396
				) -- 1396
			) -- 1396
		end -- 1396
		fillRadialGlow( -- 1400
			fgGlow, -- 1401
			hintBaseX + boardW * 0.52, -- 1402
			groundY + cam:len(8), -- 1403
			boardW * 0.55, -- 1404
			cam:len(12), -- 1405
			Color( -- 1406
				232, -- 1406
				214, -- 1406
				178, -- 1406
				math.floor((46 + 84 * flash) * aNorm + 0.5) -- 1406
			), -- 1406
			Color(214, 186, 142, 0), -- 1407
			12 -- 1408
		) -- 1408
	end -- 1408
end -- 1278
return ____exports -- 1278