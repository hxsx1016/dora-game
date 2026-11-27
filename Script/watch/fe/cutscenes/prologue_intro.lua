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
--- P01 父亲叫醒小满硬核明代木刻暗黑漫画逐帧拍表（总长 4.00s，与 D30/D31 及 bed_creak 1.78s 精确咬合）：
-- 黑场透光 → 掀帐见火 → 父亲粗手压褥撑床沿 → 坐起望见火光门缝无缝衔接 P02。
local P01_WAKE_COMIC_SEQ = {{ -- 77
	slot = "comic_p01_01_curtain_dark", -- 79
	start = 0, -- 80
	["end"] = 0.92, -- 81
	zoomFrom = 1, -- 82
	zoomTo = 1.014, -- 83
	transition = "cut" -- 84
}, { -- 84
	slot = "comic_p01_02_curtain_glow", -- 87
	start = 0.92, -- 88
	["end"] = 1.78, -- 89
	zoomFrom = 1.005, -- 90
	zoomTo = 1.018, -- 91
	transition = "cut" -- 92
}, { -- 92
	slot = "comic_p01_03_hand_bedrail", -- 95
	start = 1.78, -- 96
	["end"] = 2.9, -- 97
	zoomFrom = 1.012, -- 98
	zoomTo = 1.024, -- 99
	transition = "cut", -- 100
	shakeAmp = 3.2, -- 101
	shakeFreq = 52 -- 102
}, { -- 102
	slot = "comic_p01_04_look_door", -- 105
	start = 2.9, -- 106
	["end"] = 4, -- 107
	zoomFrom = 1.008, -- 108
	zoomTo = 1.02, -- 109
	transition = "cut" -- 110
}} -- 110
--- P02 硬核明代木刻暗黑漫画逐帧拍表（总长 4.50s，等步幅跨度 + 零重影硬切 + 1.55s 单帧冲击 + 3.88s 撞槛定格）：
-- 全部时间点与 stepP02Shadow 音效触发毫秒级咬合。
local P02_SHADOW_COMIC_SEQ = { -- 118
	{ -- 119
		slot = "comic_p02_01_shadows", -- 120
		start = 0, -- 121
		["end"] = 0.85, -- 122
		zoomFrom = 1, -- 123
		zoomTo = 1.012, -- 124
		transition = "cut" -- 125
	}, -- 125
	{ -- 127
		slot = "comic_p02_02a_door_intrude", -- 128
		start = 0.85, -- 129
		["end"] = 1.55, -- 130
		zoomFrom = 1.01, -- 131
		zoomTo = 1.022, -- 132
		transition = "cut" -- 133
	}, -- 133
	{ -- 135
		slot = "comic_p02_03_impact_cut", -- 136
		start = 1.55, -- 137
		["end"] = 1.74, -- 138
		zoomFrom = 1.035, -- 139
		zoomTo = 1.035, -- 140
		transition = "cut", -- 141
		impactFlash = true, -- 142
		impactDur = 0.19, -- 143
		shakeAmp = 11, -- 144
		shakeFreq = 72 -- 145
	}, -- 145
	{ -- 147
		slot = "comic_p02_04_shadows_fall", -- 148
		start = 1.74, -- 149
		["end"] = 2.7, -- 150
		zoomFrom = 1.015, -- 151
		zoomTo = 1, -- 152
		transition = "cut", -- 153
		shakeAmp = 3.5, -- 154
		shakeFreq = 48 -- 155
	}, -- 155
	{ -- 157
		slot = "comic_p02_05_bowl_roll1", -- 158
		start = 2.7, -- 159
		["end"] = 3.32, -- 160
		zoomFrom = 1, -- 161
		zoomTo = 1.014, -- 162
		transition = "slash_cut", -- 163
		transitionDur = 0.1 -- 164
	}, -- 164
	{ -- 166
		slot = "comic_p02_06_bowl_roll2", -- 167
		start = 3.32, -- 168
		["end"] = 3.88, -- 169
		zoomFrom = 1.008, -- 170
		zoomTo = 1.02, -- 171
		transition = "cut", -- 172
		shakeAmp = 2.5 -- 173
	}, -- 173
	{ -- 175
		slot = "comic_p02_07_bowl_smash", -- 176
		start = 3.88, -- 177
		["end"] = 4.5, -- 178
		zoomFrom = 1.028, -- 179
		zoomTo = 1, -- 180
		transition = "cut", -- 181
		impactFlash = true, -- 182
		impactDur = 0.18, -- 183
		shakeAmp = 9.5, -- 184
		shakeFreq = 66 -- 185
	} -- 185
} -- 185
--- P02 入柜收声三阶合缝拍表（总长 1.80s：贼足掠过 → 门缝半合 → 合缝一线冷月死寂）
local P02_HIDDEN_COMIC_SEQ = {{ -- 190
	slot = "comic_p02_08a_cabinet_slit", -- 192
	start = 0, -- 193
	["end"] = 0.65, -- 194
	zoomFrom = 1, -- 195
	zoomTo = 1.008, -- 196
	transition = "cut" -- 197
}, { -- 197
	slot = "comic_p02_08m_cabinet_narrowing", -- 200
	start = 0.65, -- 201
	["end"] = 1.12, -- 202
	zoomFrom = 1, -- 203
	zoomTo = 1.005, -- 204
	transition = "cut" -- 205
}, { -- 205
	slot = "comic_p02_08b_cabinet_shut", -- 208
	start = 1.12, -- 209
	["end"] = 1.8, -- 210
	zoomFrom = 1, -- 211
	zoomTo = 1, -- 212
	transition = "cut" -- 213
}} -- 213
local PROLOGUE_AUDIO = { -- 217
	fatherWake = "assets/audio/prologue/father_wake.wav", -- 218
	nightFire = "assets/audio/prologue/night_distant_fire.wav", -- 219
	bedCreak = "assets/audio/prologue/bed_creak.wav", -- 220
	doorCommotion = "assets/audio/prologue/door_commotion.wav", -- 221
	shadowStrike = "assets/audio/prologue/shadow_strike.wav", -- 222
	bowlRoll = "assets/audio/prologue/bowl_roll.wav", -- 223
	bowlHit = "assets/audio/prologue/bowl_hit.wav", -- 224
	heartbeat = "assets/audio/prologue/heartbeat.wav", -- 225
	cabinetShut = "assets/audio/prologue/cabinet_shut.wav", -- 226
	footstepsFade = "assets/audio/prologue/footsteps_fade.wav", -- 227
	distantGunflash = "assets/audio/prologue/distant_gunflash.wav" -- 228
} -- 228
local function clamp01(v) -- 255
	return math.max( -- 256
		0, -- 256
		math.min(1, v) -- 256
	) -- 256
end -- 255
local function smoothstep(edge0, edge1, x) -- 259
	if edge1 <= edge0 then -- 259
		return x >= edge1 and 1 or 0 -- 261
	end -- 261
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 263
	return t * t * (3 - 2 * t) -- 264
end -- 259
local function asRecord(value) -- 267
	if value ~= nil and type(value) == "table" then -- 267
		return value -- 269
	end -- 269
	return nil -- 271
end -- 267
local function readNum(rec, key) -- 274
	if rec == nil then -- 274
		return nil -- 276
	end -- 276
	local v = rec[key] -- 278
	return type(v) == "number" and v or nil -- 279
end -- 274
____exports.PrologueIntroPlugin = __TS__Class() -- 282
local PrologueIntroPlugin = ____exports.PrologueIntroPlugin -- 282
PrologueIntroPlugin.name = "PrologueIntroPlugin" -- 282
function PrologueIntroPlugin.prototype.____constructor(self) -- 282
	self.id = "fe03-prologue-intro" -- 283
	self.stage = "idle" -- 285
	self.rehearsalActive = false -- 286
	self.rehearsalSequence = false -- 287
	self.stageElapsed = 0 -- 288
	self.stageDuration = 0 -- 289
	self.escapeDuration = ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 292
	self.escapeRemaining = 0 -- 293
	self.escapePlayerX = 0 -- 294
	self.vignetteAlpha = 0 -- 295
	self.hiddenStartVignette = 0 -- 296
	self.heartbeatHz = 0 -- 297
	self.heartbeatPhase = 0 -- 298
	self.heartbeatBeatCount = 0 -- 299
	self.heartbeatPulse = 0 -- 300
	self.escapeRetryCount = 0 -- 301
	self.attemptSeq = 0 -- 302
	self.p04Active = false -- 305
	self.p04Elapsed = 0 -- 306
	self.p04FlashIntensity = 0 -- 307
	self.p04PostHintAlpha = 0 -- 308
	self.p04TriggeredOnce = false -- 309
	self.p04AnchorWorldX = 0 -- 310
	self.p04AnchorWorldY = 0 -- 311
	self.roomSessionId = 0 -- 313
	self.fireLoopActive = false -- 314
	self.lastRoomKey = "" -- 315
	self.enteredContractRehearsal = false -- 318
end -- 282
function PrologueIntroPlugin.prototype.onBindPlay(self, p, _view) -- 320
	self.roomSessionId = self.roomSessionId + 1 -- 321
	self.lastRoomKey = p.room.key -- 322
	self:clearTransientState(true) -- 323
	self:syncRuntimeHook() -- 324
end -- 320
function PrologueIntroPlugin.prototype.clearTransientState(self, clearRehearsal) -- 328
	if self.fireLoopActive and self.lastAudio ~= nil then -- 328
		self.lastAudio:stopLoop("fe03_night_fire", 0) -- 330
	end -- 330
	if clearRehearsal then -- 330
		self.rehearsalActive = false -- 333
		self.rehearsalSequence = false -- 334
		if self.enteredContractRehearsal and self.boundContract ~= nil then -- 334
			self.boundContract:exitRehearsal() -- 336
		end -- 336
		self.enteredContractRehearsal = false -- 338
	end -- 338
	self.stage = "idle" -- 340
	self.stageElapsed = 0 -- 341
	self.stageDuration = 0 -- 342
	self.escapeRemaining = 0 -- 343
	self.escapePlayerX = 0 -- 344
	self.vignetteAlpha = 0 -- 345
	self.hiddenStartVignette = 0 -- 346
	self.heartbeatHz = 0 -- 347
	self.heartbeatPhase = 0 -- 348
	self.heartbeatBeatCount = 0 -- 349
	self.heartbeatPulse = 0 -- 350
	self.escapeRetryCount = 0 -- 351
	self.p04Active = false -- 352
	self.p04Elapsed = 0 -- 353
	self.p04FlashIntensity = 0 -- 354
	self.p04PostHintAlpha = 0 -- 355
	self.p04TriggeredOnce = false -- 356
	self.fireLoopActive = false -- 357
	self.attemptSeq = self.attemptSeq + 1 -- 358
end -- 328
function PrologueIntroPlugin.prototype.syncRuntimeHook(self) -- 362
	local g = _G -- 363
	local ____temp_0 -- 364
	if g.package ~= nil then -- 364
		____temp_0 = g.package.loaded -- 364
	else -- 364
		____temp_0 = nil -- 364
	end -- 364
	local loaded = ____temp_0 -- 364
	if loaded == nil then -- 364
		return -- 366
	end -- 366
	local rawFe = loaded["watch.fe"] -- 368
	if rawFe ~= nil and type(rawFe) == "table" then -- 368
		local watchFe = rawFe -- 370
		if watchFe.prologue ~= self then -- 370
			watchFe.prologue = self -- 372
		end -- 372
		if self.boundContract == nil and watchFe.contract ~= nil and type(watchFe.contract) == "table" then -- 372
			self.boundContract = watchFe.contract -- 375
		end -- 375
	end -- 375
end -- 362
function PrologueIntroPlugin.prototype.startRehearsal(self, mode, escapeDuration, contract) -- 381
	self:clearTransientState(false) -- 382
	self.rehearsalActive = true -- 383
	self.rehearsalSequence = mode == "sequence" -- 384
	if contract ~= nil then -- 384
		self.boundContract = contract -- 386
	else -- 386
		self:syncRuntimeHook() -- 388
	end -- 388
	if self.boundContract ~= nil and not self.boundContract:isRehearsal() then -- 388
		self.boundContract:enterRehearsal("fe03-prologue") -- 391
		self.enteredContractRehearsal = true -- 392
	end -- 392
	self.escapeDuration = escapeDuration ~= nil and escapeDuration > 0.5 and escapeDuration or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 394
	if mode == "p01" or mode == "sequence" then -- 394
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 399
	elseif mode == "p02" then -- 399
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 401
	elseif mode == "p02_escape" then -- 401
		self:enterEscapeFromDoorway(false) -- 403
	elseif mode == "p04" then -- 403
		self:triggerP04(0, 0) -- 405
	end -- 405
end -- 381
function PrologueIntroPlugin.prototype.stopRehearsal(self) -- 410
	self:clearTransientState(true) -- 411
end -- 410
function PrologueIntroPlugin.prototype.seekRehearsal(self, stage, seconds) -- 415
	local t = math.max(0, seconds) -- 416
	self.rehearsalActive = true -- 417
	self.rehearsalSequence = false -- 418
	if stage == "p01_wake" then -- 418
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 420
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p01Duration, t) -- 421
		return -- 422
	end -- 422
	if stage == "p02_shadow" then -- 422
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 425
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02ShadowDuration, t) -- 426
		return -- 427
	end -- 427
	if stage == "p02_escape" then -- 427
		self:enterEscapeFromDoorway(false) -- 430
		local clamped = math.min(self.escapeDuration, t) -- 431
		self.stageElapsed = clamped -- 432
		self.escapeRemaining = math.max(0, self.escapeDuration - clamped) -- 433
		local u = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 434
		self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + u * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 435
		self.vignetteAlpha = clamp01(0.14 + u * 0.56) -- 437
		return -- 438
	end -- 438
	if stage == "p02_hidden" then -- 438
		self:enterHiddenCabinet() -- 441
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02HiddenLinger, t) -- 442
		local fadeK = clamp01(1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 443
		self.vignetteAlpha = self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut and 0 or self.hiddenStartVignette * fadeK -- 444
		return -- 447
	end -- 447
	if stage == "p04_flash" then -- 447
		self.stage = "idle" -- 450
		self:triggerP04(220, 0) -- 451
		self.p04Elapsed = math.min(____exports.PROLOGUE_TIMINGS.p04FlashDuration, t) -- 452
		self:recomputeP04Weights() -- 453
		return -- 454
	end -- 454
	self:clearTransientState(false) -- 456
end -- 415
function PrologueIntroPlugin.prototype.triggerCabinetEnter(self) -- 460
	if self.stage == "p02_escape" or self.stage == "p02_shadow" then -- 460
		self:enterHiddenCabinet() -- 462
	end -- 462
end -- 460
function PrologueIntroPlugin.prototype.retryEscape(self) -- 467
	self:enterEscapeFromDoorway(true) -- 468
end -- 467
function PrologueIntroPlugin.prototype.getSnapshot(self) -- 472
	local blocks = self.stage == "p01_wake" or self.stage == "p02_shadow" -- 473
	return { -- 474
		stage = self.stage, -- 475
		active = self.stage ~= "idle" or self.p04Active or self.p04PostHintAlpha > 0.01, -- 476
		isRehearsal = self.rehearsalActive, -- 477
		stageElapsed = self.stageElapsed, -- 478
		stageDuration = self.stageDuration, -- 479
		escapeRemaining = self.escapeRemaining, -- 480
		escapeDuration = self.escapeDuration, -- 481
		escapePlayerX = self.escapePlayerX, -- 482
		vignetteAlpha = self.vignetteAlpha, -- 483
		heartbeatHz = self.heartbeatHz, -- 484
		heartbeatBeatCount = self.heartbeatBeatCount, -- 485
		heartbeatPulse = self.heartbeatPulse, -- 486
		escapeRetryCount = self.escapeRetryCount, -- 487
		p04Active = self.p04Active, -- 488
		p04Elapsed = self.p04Elapsed, -- 489
		p04FlashIntensity = self.p04FlashIntensity, -- 490
		p04PostHintAlpha = self.p04PostHintAlpha, -- 491
		p04TriggeredOnce = self.p04TriggeredOnce, -- 492
		blocksPlayerControl = blocks, -- 493
		roomSessionId = self.roomSessionId -- 494
	} -- 494
end -- 472
function PrologueIntroPlugin.prototype.enterStage(self, next, duration) -- 498
	self.stage = next -- 499
	self.stageElapsed = 0 -- 500
	self.stageDuration = duration -- 501
	if next ~= "p02_escape" and next ~= "p02_hidden" then -- 501
		self.vignetteAlpha = 0 -- 503
		self.heartbeatHz = 0 -- 504
		self.heartbeatPulse = 0 -- 505
		self.heartbeatPhase = 0 -- 506
	end -- 506
end -- 498
function PrologueIntroPlugin.prototype.enterEscapeFromDoorway(self, isRetry) -- 510
	self.attemptSeq = self.attemptSeq + 1 -- 511
	self.stage = "p02_escape" -- 512
	self.stageElapsed = 0 -- 513
	self.stageDuration = self.escapeDuration -- 514
	self.escapeRemaining = self.escapeDuration -- 515
	self.escapePlayerX = 0 -- 516
	self.vignetteAlpha = 0 -- 518
	self.hiddenStartVignette = 0 -- 519
	self.heartbeatHz = 0 -- 520
	self.heartbeatPhase = 0 -- 521
	self.heartbeatBeatCount = 0 -- 522
	self.heartbeatPulse = 0 -- 523
	if isRetry then -- 523
		self.escapeRetryCount = self.escapeRetryCount + 1 -- 525
	end -- 525
end -- 510
function PrologueIntroPlugin.prototype.enterHiddenCabinet(self) -- 529
	self.hiddenStartVignette = self.vignetteAlpha > 0.01 and self.vignetteAlpha or 0.35 -- 530
	self.stage = "p02_hidden" -- 531
	self.stageElapsed = 0 -- 532
	self.stageDuration = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 533
	self.escapeRemaining = 0 -- 534
	self.escapePlayerX = 1 -- 535
	self.heartbeatHz = 0 -- 536
	self.heartbeatPulse = 0 -- 537
	self.heartbeatPhase = 0 -- 538
end -- 529
function PrologueIntroPlugin.prototype.triggerP04(self, anchorX, anchorY) -- 541
	self.p04Active = true -- 542
	self.p04Elapsed = 0 -- 543
	self.p04TriggeredOnce = true -- 544
	self.p04AnchorWorldX = anchorX -- 545
	self.p04AnchorWorldY = anchorY -- 546
	self:recomputeP04Weights() -- 547
end -- 541
function PrologueIntroPlugin.prototype.recomputeP04Weights(self) -- 550
	local t = self.p04Elapsed -- 551
	if t < 0.08 then -- 551
		self.p04FlashIntensity = clamp01(t / 0.08) -- 553
	elseif t < 0.55 then -- 553
		local k = (t - 0.08) / 0.47 -- 555
		local flicker = 0.86 + 0.14 * math.sin(t * 46) -- 556
		self.p04FlashIntensity = clamp01((1 - k * k) * flicker) -- 557
	else -- 557
		self.p04FlashIntensity = 0 -- 559
	end -- 559
	if t >= 0.18 then -- 559
		local reveal = smoothstep(0.18, 0.42, t) -- 562
		local settle = t > 0.55 and 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) or 0.85 -- 563
		self.p04PostHintAlpha = math.max(self.p04PostHintAlpha, reveal * settle) -- 564
		if t > 0.55 then -- 564
			self.p04PostHintAlpha = 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) -- 566
		end -- 566
	end -- 566
end -- 550
function PrologueIntroPlugin.prototype.cueKey(self, name) -- 571
	return (((("fe03:r" .. tostring(self.roomSessionId)) .. ":a") .. tostring(self.attemptSeq)) .. ":") .. name -- 572
end -- 571
function PrologueIntroPlugin.prototype.update(self, ctx) -- 575
	self.lastAudio = ctx.audio -- 576
	self:syncRuntimeHook() -- 577
	local p = ctx.p -- 578
	if self.lastRoomKey ~= "" and self.lastRoomKey ~= p.room.key then -- 578
		self:onBindPlay(p, ctx.view) -- 581
	end -- 581
	if ctx.paused or ctx.worldDt <= 0 then -- 581
		return -- 586
	end -- 586
	local dt = ctx.worldDt -- 589
	if not self.rehearsalActive then -- 589
		self:syncLiveBackendTriggers(ctx) -- 593
	end -- 593
	if self.stage == "p01_wake" then -- 593
		self:stepP01(ctx, dt) -- 598
	elseif self.stage == "p02_shadow" then -- 598
		self:stepP02Shadow(ctx, dt) -- 600
	elseif self.stage == "p02_escape" then -- 600
		self:stepP02Escape(ctx, dt) -- 602
	elseif self.stage == "p02_hidden" then -- 602
		self:stepP02Hidden(ctx, dt) -- 604
	end -- 604
	if self.p04Active then -- 604
		self:stepP04(ctx, dt) -- 609
	end -- 609
end -- 575
function PrologueIntroPlugin.prototype.syncLiveBackendTriggers(self, ctx) -- 613
	local p = ctx.p -- 614
	local pRec = asRecord(p) -- 615
	if p.room.key == "prologue" then -- 615
		local phase = p.phase -- 619
		if phase == "prologue-wake" and self.stage ~= "p01_wake" then -- 619
			self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 621
		elseif phase == "prologue-shadow" and self.stage ~= "p02_shadow" then -- 621
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 623
		elseif phase == "prologue-escape" and self.stage ~= "p02_escape" then -- 623
			local dur = readNum(pRec, "escapeDuration") or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 625
			self.escapeDuration = math.max(0.5, dur) -- 626
			self:enterEscapeFromDoorway(false) -- 627
		elseif phase == "prologue-hide" and self.stage ~= "p02_hidden" then -- 627
			self:enterHiddenCabinet() -- 629
		elseif (phase == "prologue-wait" or phase == "prologue-give" or phase == "prologue-follow") and (self.stage == "p01_wake" or self.stage == "p02_shadow" or self.stage == "p02_escape" or self.stage == "p02_hidden") then -- 629
			self.stage = "idle" -- 637
			self.vignetteAlpha = 0 -- 638
			self.heartbeatHz = 0 -- 639
			self.heartbeatPulse = 0 -- 640
		end -- 640
	end -- 640
	local i = 0 -- 645
	do -- 645
		i = 0 -- 646
		while i < #ctx.events.rawEvents do -- 646
			local ev = ctx.events.rawEvents[i + 1] -- 647
			local ename = ev.name -- 648
			if ename == "prologueBeat" and ev.data.beat == "escapeRetry" and self.stage == "p02_escape" then -- 648
				self:retryEscape() -- 650
			elseif ename == "p04WallFlash" or ename == "wallPeekFlash" then -- 650
				if not self.p04TriggeredOnce and p.run.story.segments.p04_wall_flash ~= true then -- 650
					p.run.story.segments.p04_wall_flash = true -- 653
					self:triggerP04(p.player.x, p.player.y) -- 654
				end -- 654
			end -- 654
			i = i + 1 -- 646
		end -- 646
	end -- 646
	if not self.p04TriggeredOnce and p.run.story.segments.p04_wall_flash ~= true and not p.childMode and p.player.alive and p.partner.alive then -- 646
		local inPrologueCourtyard = p.room.key == "prologue" and p.phase == "prologue-follow" and p.player.x >= p.ox + 470 and p.player.x <= p.ox + 635 -- 661
		local inStreetWallRoot = p.room.key == "street" and p.player.x >= p.ox + 115 and p.player.x <= p.ox + 265 and self:hasAliveEnemy(p) -- 664
		local inS1WellRoot = p.room.key == "s1-crossroad" and p.player.x >= p.ox + 185 and p.player.x <= p.ox + 320 -- 667
		if inPrologueCourtyard or inStreetWallRoot or inS1WellRoot then -- 667
			p.run.story.segments.p04_wall_flash = true -- 670
			self:triggerP04(p.player.x, p.player.y) -- 671
		end -- 671
	end -- 671
end -- 613
function PrologueIntroPlugin.prototype.hasAliveEnemy(self, p) -- 676
	local i = 0 -- 677
	do -- 677
		i = 0 -- 678
		while i < #p.enemies do -- 678
			if p.enemies[i + 1].alive then -- 678
				return true -- 680
			end -- 680
			i = i + 1 -- 678
		end -- 678
	end -- 678
	return false -- 683
end -- 676
function PrologueIntroPlugin.prototype.stepP01(self, ctx, dt) -- 686
	self.stageElapsed = self.stageElapsed + dt -- 687
	local tick = ctx.p.ticks -- 688
	if not self.fireLoopActive then -- 688
		self.fireLoopActive = true -- 691
		ctx.audio:playLoop( -- 692
			"fe03_night_fire", -- 692
			"ambience", -- 692
			PROLOGUE_AUDIO.nightFire, -- 692
			0.34, -- 692
			tick -- 692
		) -- 692
	end -- 692
	if self.stageElapsed >= 0.12 then -- 692
		ctx.audio:playOnce( -- 695
			self:cueKey("p01_father_call"), -- 696
			"voice", -- 697
			PROLOGUE_AUDIO.fatherWake, -- 698
			0.92, -- 699
			"prologue:p01_call", -- 700
			tick -- 701
		) -- 701
	end -- 701
	if self.stageElapsed >= 1.9 then -- 701
		ctx.audio:playOnce( -- 705
			self:cueKey("p01_bed_press"), -- 706
			"sfx", -- 707
			PROLOGUE_AUDIO.bedCreak, -- 708
			0.68, -- 709
			"prologue:p01_bed_press", -- 710
			tick -- 711
		) -- 711
	end -- 711
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p01Duration then -- 711
		if self.rehearsalSequence then -- 711
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 717
		elseif self.rehearsalActive then -- 717
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p01Duration -- 719
			self.stage = "idle" -- 720
		else -- 720
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p01Duration -- 723
		end -- 723
	end -- 723
end -- 686
function PrologueIntroPlugin.prototype.stepP02Shadow(self, ctx, dt) -- 728
	self.stageElapsed = self.stageElapsed + dt -- 729
	local tick = ctx.p.ticks -- 730
	if self.stageElapsed >= 0.1 then -- 730
		ctx.audio:playOnce( -- 733
			self:cueKey("p02_door_commotion"), -- 734
			"ambience", -- 735
			PROLOGUE_AUDIO.doorCommotion, -- 736
			0.62, -- 737
			"prologue:p02_commotion", -- 738
			tick -- 739
		) -- 739
	end -- 739
	if self.stageElapsed >= 1.55 then -- 739
		ctx.audio:playOnce( -- 743
			self:cueKey("p02_shadow_strike"), -- 744
			"sfx", -- 745
			PROLOGUE_AUDIO.shadowStrike, -- 746
			0.88, -- 747
			"prologue:p02_shadow_cut", -- 748
			tick -- 749
		) -- 749
	end -- 749
	if self.stageElapsed >= 2.78 then -- 749
		ctx.audio:playOnce( -- 753
			self:cueKey("p02_bowl_roll"), -- 754
			"sfx", -- 755
			PROLOGUE_AUDIO.bowlRoll, -- 756
			0.78, -- 757
			"prologue:p02_bowl_roll", -- 758
			tick -- 759
		) -- 759
	end -- 759
	if self.stageElapsed >= 3.88 then -- 759
		ctx.audio:playOnce( -- 763
			self:cueKey("p02_bowl_hit"), -- 764
			"sfx", -- 765
			PROLOGUE_AUDIO.bowlHit, -- 766
			0.92, -- 767
			"prologue:p02_bowl_hit", -- 768
			tick -- 769
		) -- 769
	end -- 769
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02ShadowDuration then -- 769
		if self.rehearsalActive then -- 769
			self:enterEscapeFromDoorway(false) -- 776
		else -- 776
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02ShadowDuration -- 779
		end -- 779
	end -- 779
end -- 728
function PrologueIntroPlugin.prototype.stepP02Escape(self, ctx, dt) -- 784
	self.stageElapsed = self.stageElapsed + dt -- 785
	local pRec = asRecord(ctx.p) -- 788
	local liveRemain = readNum(pRec, "escapeRemaining") -- 789
	if not self.rehearsalActive and liveRemain ~= nil then -- 789
		self.escapeRemaining = math.max(0, liveRemain) -- 791
	else -- 791
		self.escapeRemaining = math.max(0, self.escapeRemaining - dt) -- 793
	end -- 793
	if self.rehearsalActive then -- 793
		if ctx.input.moveX ~= 0 then -- 793
			self.escapePlayerX = clamp01(self.escapePlayerX + ctx.input.moveX * dt * 0.34) -- 799
		end -- 799
		if self.escapePlayerX >= 0.85 and ctx.input.interact.pressed or self.escapePlayerX >= 0.98 then -- 799
			self:enterHiddenCabinet() -- 802
			return -- 803
		end -- 803
	end -- 803
	if self.escapeRemaining <= 0 and (self.rehearsalActive or liveRemain == nil) then -- 803
		self:retryEscape() -- 809
		return -- 810
	end -- 810
	local urgency = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 813
	self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + urgency * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 814
	local prevCycle = math.floor(self.heartbeatPhase) -- 817
	self.heartbeatPhase = self.heartbeatPhase + dt * self.heartbeatHz -- 818
	local currCycle = math.floor(self.heartbeatPhase) -- 819
	if currCycle > prevCycle then -- 819
		self.heartbeatBeatCount = self.heartbeatBeatCount + 1 -- 821
		self.heartbeatPulse = 1 -- 822
		ctx.audio:playOnce( -- 823
			self:cueKey("p02_hb_" .. tostring(self.heartbeatBeatCount)), -- 824
			"sfx", -- 825
			PROLOGUE_AUDIO.heartbeat, -- 826
			0.44 + 0.48 * urgency, -- 827
			"prologue:p02_heartbeat:" .. tostring(self.heartbeatBeatCount), -- 828
			ctx.p.ticks -- 829
		) -- 829
	else -- 829
		local frac = self.heartbeatPhase - currCycle -- 833
		if frac >= 0.2 and frac <= 0.28 then -- 833
			self.heartbeatPulse = math.max(self.heartbeatPulse, 0.56) -- 835
		end -- 835
		self.heartbeatPulse = math.max(0, self.heartbeatPulse - dt * 3.8) -- 837
	end -- 837
	self.vignetteAlpha = clamp01(0.14 + urgency * 0.54 + self.heartbeatPulse * 0.16) -- 841
end -- 784
function PrologueIntroPlugin.prototype.stepP02Hidden(self, ctx, dt) -- 844
	self.stageElapsed = self.stageElapsed + dt -- 845
	local tick = ctx.p.ticks -- 846
	ctx.audio:playOnce( -- 848
		self:cueKey("p02_cabinet_shut"), -- 849
		"sfx", -- 850
		PROLOGUE_AUDIO.cabinetShut, -- 851
		0.78, -- 852
		"prologue:p02_cabinet_shut", -- 853
		tick -- 854
	) -- 854
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut then -- 854
		self.vignetteAlpha = 0 -- 859
	else -- 859
		self.vignetteAlpha = self.hiddenStartVignette * (1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 861
	end -- 861
	self.heartbeatHz = 0 -- 864
	self.heartbeatPulse = 0 -- 865
	if self.stageElapsed >= 0.3 then -- 865
		ctx.audio:playOnce( -- 869
			self:cueKey("p02_footsteps_fade"), -- 870
			"sfx", -- 871
			PROLOGUE_AUDIO.footstepsFade, -- 872
			0.65, -- 873
			"prologue:p02_footsteps_fade", -- 874
			tick -- 875
		) -- 875
	end -- 875
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenLinger then -- 875
		self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 880
		self.vignetteAlpha = 0 -- 881
	end -- 881
end -- 844
function PrologueIntroPlugin.prototype.stepP04(self, ctx, dt) -- 885
	if self.p04Elapsed == 0 then -- 885
		ctx.audio:playOnce( -- 887
			self:cueKey("p04_gunflash"), -- 888
			"sfx", -- 889
			PROLOGUE_AUDIO.distantGunflash, -- 890
			0.78, -- 891
			"prologue:p04_gunflash", -- 892
			ctx.p.ticks -- 893
		) -- 893
	end -- 893
	self.p04Elapsed = self.p04Elapsed + dt -- 896
	self:recomputeP04Weights() -- 897
	if self.p04Elapsed >= ____exports.PROLOGUE_TIMINGS.p04FlashDuration then -- 897
		self.p04Elapsed = ____exports.PROLOGUE_TIMINGS.p04FlashDuration -- 899
		self.p04FlashIntensity = 0 -- 900
		self.p04Active = false -- 901
		self.p04PostHintAlpha = 0.42 -- 903
	end -- 903
end -- 885
function PrologueIntroPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 908
	if self.stage == "p02_escape" and not self.rehearsalActive and ctx.p.room.key == "prologue" then -- 908
		local cam = ctx.cam -- 915
		local cabX = cam:sx(ctx.p.ox + PROLOGUE_CABINET_X + 18) -- 916
		local cabY = cam:sy(0, 0) -- 917
		local pulse = 0.65 + 0.35 * math.sin(self.stageElapsed * 6.5) -- 918
		local sway = math.sin(self.stageElapsed * 9) * cam:len(2.5) -- 919
		fillRadialGlow( -- 921
			fgGlow, -- 922
			cabX + sway, -- 923
			cabY + cam:len(34), -- 924
			cam:len(38), -- 925
			cam:len(46), -- 926
			Color( -- 927
				232, -- 927
				178, -- 927
				104, -- 927
				math.floor(68 * pulse + 0.5) -- 927
			), -- 927
			Color(186, 118, 56, 0), -- 928
			14 -- 929
		) -- 929
		fgDraw:drawSegment( -- 931
			Vec2( -- 932
				cabX + sway, -- 932
				cabY + cam:len(4) -- 932
			), -- 932
			Vec2( -- 933
				cabX + sway, -- 933
				cabY + cam:len(54) -- 933
			), -- 933
			2, -- 934
			Color( -- 935
				238, -- 935
				198, -- 935
				134, -- 935
				math.floor(165 * pulse + 0.5) -- 935
			) -- 935
		) -- 935
	end -- 935
	if not self.p04Active and self.p04PostHintAlpha <= 0.01 then -- 935
		return -- 939
	end -- 939
	self:drawP04WorldAction(fgDraw, fgGlow, worldArt, ctx) -- 941
end -- 908
function PrologueIntroPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 945
	if self.stage == "p01_wake" then -- 945
		self:drawP01Wake( -- 953
			uiDraw, -- 953
			uiInkDraw, -- 953
			uiArt, -- 953
			uiGlow, -- 953
			ctx -- 953
		) -- 953
		return true -- 954
	end -- 954
	if self.stage == "p02_shadow" then -- 954
		self:drawP02ShadowAndBowl( -- 957
			uiDraw, -- 957
			uiInkDraw, -- 957
			uiArt, -- 957
			uiGlow, -- 957
			ctx -- 957
		) -- 957
		return true -- 958
	end -- 958
	if self.stage == "p02_escape" then -- 958
		self:drawP02EscapeVignette(uiDraw, uiInkDraw, uiGlow, ctx) -- 961
		return true -- 963
	end -- 963
	if self.stage == "p02_hidden" then -- 963
		self:drawP02HiddenCabinet( -- 966
			uiDraw, -- 966
			uiInkDraw, -- 966
			uiArt, -- 966
			uiGlow, -- 966
			ctx -- 966
		) -- 966
		return true -- 967
	end -- 967
	return false -- 969
end -- 945
function PrologueIntroPlugin.prototype.drawP01Wake(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 974
	local w = ctx.uiW -- 981
	local h = ctx.uiH -- 982
	local t = self.stageElapsed -- 983
	uiDraw:drawRect( -- 986
		Rect(0, 0, w, h), -- 986
		Color(6, 7, 11, 255) -- 986
	) -- 986
	local wakeOpen = smoothstep(0.28, 1.45, t) -- 989
	local blinkDip = t >= 0.96 and t <= 1.28 and math.sin((t - 0.96) / 0.32 * math.pi) * 0.22 or 0 -- 990
	local eyeOpen = clamp01(wakeOpen - blinkDip) -- 991
	local fadeOut = 1 - smoothstep(3.76, 4, t) -- 992
	local barH = math.floor(h * 0.068 + 0.5) -- 993
	if eyeOpen > 0.01 then -- 993
		drawComicSequence( -- 996
			uiDraw, -- 997
			uiInkDraw, -- 998
			uiArt, -- 999
			P01_WAKE_COMIC_SEQ, -- 1000
			t, -- 1001
			w, -- 1002
			h, -- 1003
			{ -- 1004
				letterboxH = barH, -- 1005
				opacity = clamp01(smoothstep(0.18, 0.58, t)) * fadeOut, -- 1006
				layer = 2, -- 1007
				instancePrefix = "p01_comic", -- 1008
				accentBorder = true -- 1009
			} -- 1009
		) -- 1009
	end -- 1009
	local lidH = h * 0.52 * (1 - eyeOpen) -- 1015
	if lidH > 1 then -- 1015
		ctx.uiMask:drawRect( -- 1017
			Rect(0, h - lidH, w, lidH), -- 1017
			Color(5, 6, 9, 255) -- 1017
		) -- 1017
		ctx.uiMask:drawRect( -- 1018
			Rect(0, 0, w, lidH), -- 1018
			Color(5, 6, 9, 255) -- 1018
		) -- 1018
		local feather = math.min(46, h * 0.08) -- 1019
		fillVGradRect( -- 1020
			ctx.uiMask, -- 1020
			0, -- 1020
			h - lidH - feather, -- 1020
			w, -- 1020
			feather, -- 1020
			Color(5, 6, 9, 0), -- 1020
			Color(5, 6, 9, 235) -- 1020
		) -- 1020
		fillVGradRect( -- 1021
			ctx.uiMask, -- 1021
			0, -- 1021
			lidH, -- 1021
			w, -- 1021
			feather, -- 1021
			Color(5, 6, 9, 235), -- 1021
			Color(5, 6, 9, 0) -- 1021
		) -- 1021
	end -- 1021
	if self.rehearsalActive then -- 1021
		local callAlpha = smoothstep(0.1, 0.32, t) * (1 - smoothstep(1.05, 1.55, t)) -- 1026
		if callAlpha > 0.02 then -- 1026
			drawSilkVeil( -- 1028
				uiDraw, -- 1028
				uiArt, -- 1028
				"p01_call_veil", -- 1028
				w * 0.5, -- 1028
				h * 0.14, -- 1028
				240, -- 1028
				44, -- 1028
				PALETTE.inkWash, -- 1028
				0.72 * callAlpha, -- 1028
				0 -- 1028
			) -- 1028
			ctx.texts:put( -- 1029
				"sm", -- 1030
				"「小满。」", -- 1031
				w * 0.5, -- 1032
				h * 0.14, -- 1033
				toColor(PALETTE.textBright), -- 1034
				0.5, -- 1035
				0.5, -- 1036
				"Center", -- 1037
				2, -- 1038
				callAlpha, -- 1039
				0.08 -- 1040
			) -- 1040
		end -- 1040
	end -- 1040
end -- 974
function PrologueIntroPlugin.prototype.drawP02ShadowAndBowl(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 1048
	local w = ctx.uiW -- 1055
	local h = ctx.uiH -- 1056
	local t = self.stageElapsed -- 1057
	local barH = math.floor(h * 0.068 + 0.5) -- 1058
	drawComicSequence( -- 1059
		uiDraw, -- 1060
		uiInkDraw, -- 1061
		uiArt, -- 1062
		P02_SHADOW_COMIC_SEQ, -- 1063
		t, -- 1064
		w, -- 1065
		h, -- 1066
		{ -- 1067
			letterboxH = barH, -- 1068
			opacity = 1, -- 1069
			layer = 2, -- 1070
			instancePrefix = "fe03_p02_shadow", -- 1071
			accentBorder = true -- 1072
		} -- 1072
	) -- 1072
end -- 1048
function PrologueIntroPlugin.prototype.drawP02EscapeVignette(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1079
	local w = ctx.uiW -- 1085
	local h = ctx.uiH -- 1086
	local a = clamp01(self.vignetteAlpha) -- 1087
	if a > 0.005 then -- 1087
		local edgeX = w * (0.09 + 0.06 * a) -- 1090
		local edgeY = h * (0.11 + 0.07 * a) -- 1091
		local peakA = math.floor(168 * a + 0.5) -- 1092
		local deep = PALETTE.crimsonDeep -- 1093
		local rouge = PALETTE.rouge -- 1094
		local cEdge = Color(deep.r, deep.g, deep.b, peakA) -- 1095
		local cZero = Color(deep.r, deep.g, deep.b, 0) -- 1096
		fillHGradRect( -- 1098
			uiDraw, -- 1098
			0, -- 1098
			0, -- 1098
			edgeX, -- 1098
			h, -- 1098
			cEdge, -- 1098
			cZero -- 1098
		) -- 1098
		fillHGradRect( -- 1099
			uiDraw, -- 1099
			w - edgeX, -- 1099
			0, -- 1099
			edgeX, -- 1099
			h, -- 1099
			cZero, -- 1099
			cEdge -- 1099
		) -- 1099
		fillVGradRect( -- 1100
			uiDraw, -- 1100
			0, -- 1100
			0, -- 1100
			w, -- 1100
			edgeY, -- 1100
			cEdge, -- 1100
			cZero -- 1100
		) -- 1100
		fillVGradRect( -- 1101
			uiDraw, -- 1101
			0, -- 1101
			h - edgeY, -- 1101
			w, -- 1101
			edgeY, -- 1101
			cZero, -- 1101
			cEdge -- 1101
		) -- 1101
		if self.heartbeatPulse > 0.02 then -- 1101
			local pa = math.floor(62 * self.heartbeatPulse * a + 0.5) -- 1105
			local cPulse = Color(rouge.r, rouge.g, rouge.b, pa) -- 1106
			local cPulseZero = Color(rouge.r, rouge.g, rouge.b, 0) -- 1107
			fillHGradRect( -- 1108
				uiGlow, -- 1108
				0, -- 1108
				0, -- 1108
				edgeX * 0.72, -- 1108
				h, -- 1108
				cPulse, -- 1108
				cPulseZero -- 1108
			) -- 1108
			fillHGradRect( -- 1109
				uiGlow, -- 1109
				w - edgeX * 0.72, -- 1109
				0, -- 1109
				edgeX * 0.72, -- 1109
				h, -- 1109
				cPulseZero, -- 1109
				cPulse -- 1109
			) -- 1109
		end -- 1109
	end -- 1109
	if self.rehearsalActive then -- 1109
		local groundY = h * 0.24 -- 1115
		local doorX = w * 0.14 -- 1116
		local cabX = w * 0.8 -- 1117
		local childX = doorX + (cabX - doorX) * self.escapePlayerX -- 1118
		local wobble = math.sin(self.stageElapsed * 9.5) * 4 -- 1119
		uiInkDraw:drawRect( -- 1122
			Rect(doorX - 18, groundY, 16, 130), -- 1122
			Color(48, 36, 28, 220) -- 1122
		) -- 1122
		uiDraw:drawCircle( -- 1123
			Vec2(doorX + 18, groundY + 8), -- 1123
			8, -- 1123
			Color(168, 164, 152, 220) -- 1123
		) -- 1123
		uiDraw:drawRect( -- 1125
			Rect(cabX, groundY, 74, 108), -- 1125
			Color(42, 31, 24, 240), -- 1125
			1.2, -- 1125
			Color(118, 92, 68, 195) -- 1125
		) -- 1125
		uiInkDraw:drawSegment( -- 1126
			Vec2(cabX + 8 + wobble * 0.5, groundY + 6), -- 1126
			Vec2(cabX + 8 + wobble * 0.5, groundY + 100), -- 1126
			2.2, -- 1126
			Color(176, 144, 106, 210) -- 1126
		) -- 1126
		if not ctx.uiArt:tryPlaceRun( -- 1126
			"child", -- 1128
			"p02_escape_child", -- 1128
			childX, -- 1128
			groundY, -- 1128
			46, -- 1128
			74, -- 1128
			self.stageElapsed * 1.8, -- 1128
			{facing = 1, layer = 3} -- 1128
		) then -- 1128
			uiDraw:drawRect( -- 1132
				Rect(childX - 12, groundY, 24, 54), -- 1132
				Color(168, 72, 54, 235) -- 1132
			) -- 1132
		end -- 1132
	end -- 1132
end -- 1079
function PrologueIntroPlugin.prototype.drawP02HiddenCabinet(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 1139
	local w = ctx.uiW -- 1146
	local h = ctx.uiH -- 1147
	local t = self.stageElapsed -- 1148
	drawComicSequence( -- 1150
		uiDraw, -- 1151
		uiInkDraw, -- 1152
		uiArt, -- 1153
		P02_HIDDEN_COMIC_SEQ, -- 1154
		t, -- 1155
		w, -- 1156
		h, -- 1157
		{ -- 1158
			letterboxH = math.floor(h * 0.055 + 0.5), -- 1159
			opacity = 1, -- 1160
			layer = 3, -- 1161
			instancePrefix = "fe03_p02_hidden", -- 1162
			accentBorder = false -- 1163
		} -- 1163
	) -- 1163
	if self.vignetteAlpha > 0.005 then -- 1163
		local a = math.floor(140 * self.vignetteAlpha + 0.5) -- 1169
		local edge = w * 0.08 -- 1170
		fillHGradRect( -- 1171
			uiInkDraw, -- 1171
			0, -- 1171
			0, -- 1171
			edge, -- 1171
			h, -- 1171
			Color(124, 38, 42, a), -- 1171
			Color(124, 38, 42, 0) -- 1171
		) -- 1171
		fillHGradRect( -- 1172
			uiInkDraw, -- 1172
			w - edge, -- 1172
			0, -- 1172
			edge, -- 1172
			h, -- 1172
			Color(124, 38, 42, 0), -- 1172
			Color(124, 38, 42, a) -- 1172
		) -- 1172
	end -- 1172
end -- 1139
function PrologueIntroPlugin.prototype.drawP04WorldAction(self, fgDraw, fgGlow, worldArt, ctx) -- 1178
	local p = ctx.p -- 1184
	local cam = ctx.cam -- 1185
	local flash = self.p04FlashIntensity -- 1186
	local hintAlpha = self.p04PostHintAlpha -- 1187
	local zhou = p.childMode and p.partner or p.player -- 1189
	local xiao = p.childMode and p.player or p.partner -- 1190
	local zX = cam:sx(zhou.x) -- 1191
	local zY = cam:sy(zhou.y, zhou.depth) -- 1192
	local zH = cam:len(zhou.h) -- 1193
	local xX = cam:sx(xiao.x) -- 1194
	local xY = cam:sy(xiao.y, xiao.depth) -- 1195
	local xH = cam:len(xiao.h) -- 1196
	if flash > 0.01 then -- 1196
		fillGradQuad( -- 1201
			fgGlow, -- 1202
			cam.viewW, -- 1203
			cam.groundScreenY + cam:len(18), -- 1203
			Color( -- 1203
				238, -- 1203
				178, -- 1203
				108, -- 1203
				math.floor(96 * flash + 0.5) -- 1203
			), -- 1203
			cam.viewW, -- 1204
			cam.groundScreenY + cam:len(195), -- 1204
			Color( -- 1204
				224, -- 1204
				148, -- 1204
				82, -- 1204
				math.floor(72 * flash + 0.5) -- 1204
			), -- 1204
			zX - cam:len(140), -- 1205
			cam.groundScreenY + cam:len(140), -- 1205
			Color(200, 120, 62, 0), -- 1205
			zX - cam:len(140), -- 1206
			cam.groundScreenY, -- 1206
			Color(200, 120, 62, 0) -- 1206
		) -- 1206
		local wallBaseY = cam.groundScreenY + cam:len(14) -- 1210
		local shAlpha = math.floor(148 * flash + 0.5) -- 1211
		local shCol = Color(8, 10, 14, shAlpha) -- 1212
		fgDraw:drawPolygon( -- 1214
			{ -- 1214
				Vec2( -- 1215
					zX - cam:len(14), -- 1215
					wallBaseY -- 1215
				), -- 1215
				Vec2( -- 1216
					zX + cam:len(6), -- 1216
					wallBaseY -- 1216
				), -- 1216
				Vec2( -- 1217
					zX - cam:len(38), -- 1217
					wallBaseY + zH * 1.18 -- 1217
				), -- 1217
				Vec2( -- 1218
					zX - cam:len(64), -- 1218
					wallBaseY + zH * 1.12 -- 1218
				) -- 1218
			}, -- 1218
			shCol -- 1219
		) -- 1219
		fgDraw:drawPolygon( -- 1221
			{ -- 1221
				Vec2( -- 1222
					xX - cam:len(10), -- 1222
					wallBaseY -- 1222
				), -- 1222
				Vec2( -- 1223
					xX + cam:len(6), -- 1223
					wallBaseY -- 1223
				), -- 1223
				Vec2( -- 1224
					xX - cam:len(26), -- 1224
					wallBaseY + xH * 1.12 -- 1224
				), -- 1224
				Vec2( -- 1225
					xX - cam:len(44), -- 1225
					wallBaseY + xH * 1.06 -- 1225
				) -- 1225
			}, -- 1225
			shCol -- 1226
		) -- 1226
		local shieldK = smoothstep(0.1, 0.24, self.p04Elapsed) * (1 - smoothstep(0.5, 0.78, self.p04Elapsed)) -- 1229
		if shieldK > 0.02 then -- 1229
			local armX = zX + cam:len(10) -- 1231
			local armY = zY + zH * 0.66 -- 1232
			local cuffW = cam:len(13) -- 1233
			local cuffH = cam:len(7) -- 1234
			local sa = math.floor(235 * shieldK + 0.5) -- 1235
			fgDraw:drawPolygon( -- 1236
				{ -- 1236
					Vec2( -- 1237
						zX + cam:len(2), -- 1237
						armY - cuffH * 0.4 -- 1237
					), -- 1237
					Vec2(armX + cuffW, armY + cuffH * 0.9), -- 1238
					Vec2(armX + cuffW * 0.72, armY + cuffH * 1.75), -- 1239
					Vec2( -- 1240
						zX - cam:len(2), -- 1240
						armY + cuffH * 0.5 -- 1240
					) -- 1240
				}, -- 1240
				toColor(____exports.CUFF_SHARED_SPEC.indigoCloth, sa) -- 1241
			) -- 1241
			fgDraw:drawSegment( -- 1243
				Vec2(armX + cuffW * 0.45, armY + cuffH * 0.75), -- 1244
				Vec2(armX + cuffW * 0.82, armY + cuffH * 1.25), -- 1245
				1.3, -- 1246
				toColor( -- 1247
					____exports.CUFF_SHARED_SPEC.mendStitch, -- 1247
					math.floor(210 * shieldK + 0.5) -- 1247
				) -- 1247
			) -- 1247
			fillGradQuad( -- 1250
				fgDraw, -- 1251
				zX + cam:len(4), -- 1252
				zY + zH * 0.85, -- 1252
				Color( -- 1252
					10, -- 1252
					12, -- 1252
					18, -- 1252
					math.floor(92 * shieldK + 0.5) -- 1252
				), -- 1252
				zX + cam:len(4), -- 1253
				zY, -- 1253
				Color( -- 1253
					10, -- 1253
					12, -- 1253
					18, -- 1253
					math.floor(62 * shieldK + 0.5) -- 1253
				), -- 1253
				xX - cam:len(18), -- 1254
				xY, -- 1254
				Color(10, 12, 18, 0), -- 1254
				xX - cam:len(18), -- 1255
				xY + xH, -- 1255
				Color(10, 12, 18, 0) -- 1255
			) -- 1255
		end -- 1255
	end -- 1255
	if hintAlpha > 0.02 then -- 1255
		local baseWx = self.p04AnchorWorldX > 0 and self.p04AnchorWorldX or zhou.x -- 1262
		local hintBaseX = cam:sx(baseWx + 74) -- 1263
		local groundY = cam:sy(0, 0) -- 1264
		local boardW = cam:len(62) -- 1265
		local sheenBoost = flash * 0.55 -- 1266
		local aNorm = clamp01(hintAlpha + sheenBoost) -- 1267
		local placedBoard = worldArt:tryPlacePath( -- 1269
			"assets/art/cutscene_well_museum.clip|p04_window_board", -- 1270
			"p04_polished_window_board", -- 1271
			hintBaseX + boardW * 0.5, -- 1272
			groundY - 2, -- 1273
			boardW * 1.15, -- 1274
			cam:len(68), -- 1275
			{ -- 1276
				anchorX = 0.5, -- 1277
				anchorY = 0, -- 1278
				color = Color( -- 1279
					math.floor(188 + 64 * flash + 0.5), -- 1280
					math.floor(184 + 54 * flash + 0.5), -- 1281
					math.floor(176 + 34 * flash + 0.5), -- 1282
					255 -- 1283
				), -- 1283
				opacity = 0.88 * aNorm, -- 1285
				smooth = true, -- 1286
				layer = 4200 -- 1287
			} -- 1287
		) -- 1287
		if not placedBoard then -- 1287
			local boardY = groundY + cam:len(34) -- 1291
			fgDraw:drawRect( -- 1292
				Rect( -- 1293
					hintBaseX, -- 1293
					boardY, -- 1293
					boardW, -- 1293
					cam:len(12) -- 1293
				), -- 1293
				Color( -- 1294
					54, -- 1294
					42, -- 1294
					32, -- 1294
					math.floor(165 * aNorm + 0.5) -- 1294
				), -- 1294
				1, -- 1295
				Color( -- 1296
					126, -- 1296
					102, -- 1296
					76, -- 1296
					math.floor(150 * aNorm + 0.5) -- 1296
				) -- 1296
			) -- 1296
		end -- 1296
		fillRadialGlow( -- 1300
			fgGlow, -- 1301
			hintBaseX + boardW * 0.52, -- 1302
			groundY + cam:len(8), -- 1303
			boardW * 0.55, -- 1304
			cam:len(12), -- 1305
			Color( -- 1306
				232, -- 1306
				214, -- 1306
				178, -- 1306
				math.floor((46 + 84 * flash) * aNorm + 0.5) -- 1306
			), -- 1306
			Color(214, 186, 142, 0), -- 1307
			12 -- 1308
		) -- 1308
	end -- 1308
end -- 1178
return ____exports -- 1178