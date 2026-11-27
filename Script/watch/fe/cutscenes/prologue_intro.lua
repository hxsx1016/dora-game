-- [ts]: prologue_intro.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 19
local Color = ____Dora.Color -- 19
local Rect = ____Dora.Rect -- 19
local Vec2 = ____Dora.Vec2 -- 19
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 23
local CUFF_PALETTE = ____cuff_shots.CUFF_PALETTE -- 23
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 25
local computeFullscreenSlideRect = ____slideshow.computeFullscreenSlideRect -- 27
local drawPixelSlidePlate = ____slideshow.drawPixelSlidePlate -- 28
local drawPixelSlideshow = ____slideshow.drawPixelSlideshow -- 29
local ____theme = require("Script.watch.fe.theme") -- 31
local PALETTE = ____theme.PALETTE -- 32
local drawSilkVeil = ____theme.drawSilkVeil -- 34
local fillGradQuad = ____theme.fillGradQuad -- 35
local fillHGradRect = ____theme.fillHGradRect -- 36
local fillRadialGlow = ____theme.fillRadialGlow -- 37
local fillVGradRect = ____theme.fillVGradRect -- 38
local toColor = ____theme.toColor -- 40
--- 与 fe-01（P03/P05/G05）同源的明代青布补线袖口配色口径（直接取自 cuff_shots.CUFF_PALETTE，确保四镜视觉严格一致）
____exports.CUFF_SHARED_SPEC = { -- 59
	indigoCloth = CUFF_PALETTE.indigoBase, -- 60
	indigoTrim = CUFF_PALETTE.hemEdge, -- 61
	mendStitch = CUFF_PALETTE.stitchThread, -- 62
	armWrapCloth = CUFF_PALETTE.armWrapLinen, -- 63
	stitchCount = 6 -- 64
} -- 64
____exports.PROLOGUE_TIMINGS = { -- 67
	p01Duration = 4, -- 68
	p02ShadowDuration = 2, -- 69
	p02EscapeDuration = 7.5, -- 70
	p02HiddenFadeOut = 0.28, -- 71
	p02HiddenLinger = 0.85, -- 72
	p04FlashDuration = 1, -- 73
	heartbeatMinHz = 1.15, -- 74
	heartbeatMaxHz = 2.75 -- 75
} -- 75
local PROLOGUE_AUDIO = { -- 78
	fatherWake = "assets/audio/prologue/father_wake.wav", -- 79
	nightFire = "assets/audio/prologue/night_distant_fire.wav", -- 80
	bedCreak = "assets/audio/prologue/bed_creak.wav", -- 81
	doorCommotion = "assets/audio/prologue/door_commotion.wav", -- 82
	shadowStrike = "assets/audio/prologue/shadow_strike.wav", -- 83
	bowlRoll = "assets/audio/prologue/bowl_roll.wav", -- 84
	bowlHit = "assets/audio/prologue/bowl_hit.wav", -- 85
	heartbeat = "assets/audio/prologue/heartbeat.wav", -- 86
	cabinetShut = "assets/audio/prologue/cabinet_shut.wav", -- 87
	footstepsFade = "assets/audio/prologue/footsteps_fade.wav", -- 88
	distantGunflash = "assets/audio/prologue/distant_gunflash.wav" -- 89
} -- 89
local function clamp01(v) -- 116
	return math.max( -- 117
		0, -- 117
		math.min(1, v) -- 117
	) -- 117
end -- 116
local function smoothstep(edge0, edge1, x) -- 120
	if edge1 <= edge0 then -- 120
		return x >= edge1 and 1 or 0 -- 122
	end -- 122
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 124
	return t * t * (3 - 2 * t) -- 125
end -- 120
local function asRecord(value) -- 128
	if value ~= nil and type(value) == "table" then -- 128
		return value -- 130
	end -- 130
	return nil -- 132
end -- 128
local function readNum(rec, key) -- 135
	if rec == nil then -- 135
		return nil -- 137
	end -- 137
	local v = rec[key] -- 139
	return type(v) == "number" and v or nil -- 140
end -- 135
____exports.PrologueIntroPlugin = __TS__Class() -- 143
local PrologueIntroPlugin = ____exports.PrologueIntroPlugin -- 143
PrologueIntroPlugin.name = "PrologueIntroPlugin" -- 143
function PrologueIntroPlugin.prototype.____constructor(self) -- 143
	self.id = "fe03-prologue-intro" -- 144
	self.stage = "idle" -- 146
	self.rehearsalActive = false -- 147
	self.rehearsalSequence = false -- 148
	self.stageElapsed = 0 -- 149
	self.stageDuration = 0 -- 150
	self.escapeDuration = ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 153
	self.escapeRemaining = 0 -- 154
	self.escapePlayerX = 0 -- 155
	self.vignetteAlpha = 0 -- 156
	self.hiddenStartVignette = 0 -- 157
	self.heartbeatHz = 0 -- 158
	self.heartbeatPhase = 0 -- 159
	self.heartbeatBeatCount = 0 -- 160
	self.heartbeatPulse = 0 -- 161
	self.escapeRetryCount = 0 -- 162
	self.attemptSeq = 0 -- 163
	self.p04Active = false -- 166
	self.p04Elapsed = 0 -- 167
	self.p04FlashIntensity = 0 -- 168
	self.p04PostHintAlpha = 0 -- 169
	self.p04TriggeredOnce = false -- 170
	self.p04AnchorWorldX = 0 -- 171
	self.p04AnchorWorldY = 0 -- 172
	self.roomSessionId = 0 -- 174
	self.fireLoopActive = false -- 175
	self.lastRoomKey = "" -- 176
	self.enteredContractRehearsal = false -- 179
end -- 143
function PrologueIntroPlugin.prototype.onBindPlay(self, p, _view) -- 181
	self.roomSessionId = self.roomSessionId + 1 -- 182
	self.lastRoomKey = p.room.key -- 183
	self:clearTransientState(true) -- 184
	self:syncRuntimeHook() -- 185
end -- 181
function PrologueIntroPlugin.prototype.clearTransientState(self, clearRehearsal) -- 189
	if self.fireLoopActive and self.lastAudio ~= nil then -- 189
		self.lastAudio:stopLoop("fe03_night_fire", 0) -- 191
	end -- 191
	if clearRehearsal then -- 191
		self.rehearsalActive = false -- 194
		self.rehearsalSequence = false -- 195
		if self.enteredContractRehearsal and self.boundContract ~= nil then -- 195
			self.boundContract:exitRehearsal() -- 197
		end -- 197
		self.enteredContractRehearsal = false -- 199
	end -- 199
	self.stage = "idle" -- 201
	self.stageElapsed = 0 -- 202
	self.stageDuration = 0 -- 203
	self.escapeRemaining = 0 -- 204
	self.escapePlayerX = 0 -- 205
	self.vignetteAlpha = 0 -- 206
	self.hiddenStartVignette = 0 -- 207
	self.heartbeatHz = 0 -- 208
	self.heartbeatPhase = 0 -- 209
	self.heartbeatBeatCount = 0 -- 210
	self.heartbeatPulse = 0 -- 211
	self.escapeRetryCount = 0 -- 212
	self.p04Active = false -- 213
	self.p04Elapsed = 0 -- 214
	self.p04FlashIntensity = 0 -- 215
	self.p04PostHintAlpha = 0 -- 216
	self.p04TriggeredOnce = false -- 217
	self.fireLoopActive = false -- 218
	self.attemptSeq = self.attemptSeq + 1 -- 219
end -- 189
function PrologueIntroPlugin.prototype.syncRuntimeHook(self) -- 223
	local g = _G -- 224
	local ____temp_0 -- 225
	if g.package ~= nil then -- 225
		____temp_0 = g.package.loaded -- 225
	else -- 225
		____temp_0 = nil -- 225
	end -- 225
	local loaded = ____temp_0 -- 225
	if loaded == nil then -- 225
		return -- 227
	end -- 227
	local rawFe = loaded["watch.fe"] -- 229
	if rawFe ~= nil and type(rawFe) == "table" then -- 229
		local watchFe = rawFe -- 231
		if watchFe.prologue ~= self then -- 231
			watchFe.prologue = self -- 233
		end -- 233
		if self.boundContract == nil and watchFe.contract ~= nil and type(watchFe.contract) == "table" then -- 233
			self.boundContract = watchFe.contract -- 236
		end -- 236
	end -- 236
end -- 223
function PrologueIntroPlugin.prototype.startRehearsal(self, mode, escapeDuration, contract) -- 242
	self:clearTransientState(false) -- 243
	self.rehearsalActive = true -- 244
	self.rehearsalSequence = mode == "sequence" -- 245
	if contract ~= nil then -- 245
		self.boundContract = contract -- 247
	else -- 247
		self:syncRuntimeHook() -- 249
	end -- 249
	if self.boundContract ~= nil and not self.boundContract:isRehearsal() then -- 249
		self.boundContract:enterRehearsal("fe03-prologue") -- 252
		self.enteredContractRehearsal = true -- 253
	end -- 253
	self.escapeDuration = escapeDuration ~= nil and escapeDuration > 0.5 and escapeDuration or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 255
	if mode == "p01" or mode == "sequence" then -- 255
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 260
	elseif mode == "p02" then -- 260
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 262
	elseif mode == "p02_escape" then -- 262
		self:enterEscapeFromDoorway(false) -- 264
	elseif mode == "p04" then -- 264
		self:triggerP04(0, 0) -- 266
	end -- 266
end -- 242
function PrologueIntroPlugin.prototype.stopRehearsal(self) -- 271
	self:clearTransientState(true) -- 272
end -- 271
function PrologueIntroPlugin.prototype.seekRehearsal(self, stage, seconds) -- 276
	local t = math.max(0, seconds) -- 277
	self.rehearsalActive = true -- 278
	self.rehearsalSequence = false -- 279
	if stage == "p01_wake" then -- 279
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 281
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p01Duration, t) -- 282
		return -- 283
	end -- 283
	if stage == "p02_shadow" then -- 283
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 286
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02ShadowDuration, t) -- 287
		return -- 288
	end -- 288
	if stage == "p02_escape" then -- 288
		self:enterEscapeFromDoorway(false) -- 291
		local clamped = math.min(self.escapeDuration, t) -- 292
		self.stageElapsed = clamped -- 293
		self.escapeRemaining = math.max(0, self.escapeDuration - clamped) -- 294
		local u = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 295
		self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + u * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 296
		self.vignetteAlpha = clamp01(0.14 + u * 0.56) -- 298
		return -- 299
	end -- 299
	if stage == "p02_hidden" then -- 299
		self:enterHiddenCabinet() -- 302
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02HiddenLinger, t) -- 303
		local fadeK = clamp01(1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 304
		self.vignetteAlpha = self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut and 0 or self.hiddenStartVignette * fadeK -- 305
		return -- 308
	end -- 308
	if stage == "p04_flash" then -- 308
		self.stage = "idle" -- 311
		self:triggerP04(220, 0) -- 312
		self.p04Elapsed = math.min(____exports.PROLOGUE_TIMINGS.p04FlashDuration, t) -- 313
		self:recomputeP04Weights() -- 314
		return -- 315
	end -- 315
	self:clearTransientState(false) -- 317
end -- 276
function PrologueIntroPlugin.prototype.triggerCabinetEnter(self) -- 321
	if self.stage == "p02_escape" or self.stage == "p02_shadow" then -- 321
		self:enterHiddenCabinet() -- 323
	end -- 323
end -- 321
function PrologueIntroPlugin.prototype.retryEscape(self) -- 328
	self:enterEscapeFromDoorway(true) -- 329
end -- 328
function PrologueIntroPlugin.prototype.getSnapshot(self) -- 333
	local blocks = self.stage == "p01_wake" or self.stage == "p02_shadow" -- 334
	return { -- 335
		stage = self.stage, -- 336
		active = self.stage ~= "idle" or self.p04Active or self.p04PostHintAlpha > 0.01, -- 337
		isRehearsal = self.rehearsalActive, -- 338
		stageElapsed = self.stageElapsed, -- 339
		stageDuration = self.stageDuration, -- 340
		escapeRemaining = self.escapeRemaining, -- 341
		escapeDuration = self.escapeDuration, -- 342
		escapePlayerX = self.escapePlayerX, -- 343
		vignetteAlpha = self.vignetteAlpha, -- 344
		heartbeatHz = self.heartbeatHz, -- 345
		heartbeatBeatCount = self.heartbeatBeatCount, -- 346
		heartbeatPulse = self.heartbeatPulse, -- 347
		escapeRetryCount = self.escapeRetryCount, -- 348
		p04Active = self.p04Active, -- 349
		p04Elapsed = self.p04Elapsed, -- 350
		p04FlashIntensity = self.p04FlashIntensity, -- 351
		p04PostHintAlpha = self.p04PostHintAlpha, -- 352
		p04TriggeredOnce = self.p04TriggeredOnce, -- 353
		blocksPlayerControl = blocks, -- 354
		roomSessionId = self.roomSessionId -- 355
	} -- 355
end -- 333
function PrologueIntroPlugin.prototype.enterStage(self, next, duration) -- 359
	self.stage = next -- 360
	self.stageElapsed = 0 -- 361
	self.stageDuration = duration -- 362
	if next ~= "p02_escape" and next ~= "p02_hidden" then -- 362
		self.vignetteAlpha = 0 -- 364
		self.heartbeatHz = 0 -- 365
		self.heartbeatPulse = 0 -- 366
		self.heartbeatPhase = 0 -- 367
	end -- 367
end -- 359
function PrologueIntroPlugin.prototype.enterEscapeFromDoorway(self, isRetry) -- 371
	self.attemptSeq = self.attemptSeq + 1 -- 372
	self.stage = "p02_escape" -- 373
	self.stageElapsed = 0 -- 374
	self.stageDuration = self.escapeDuration -- 375
	self.escapeRemaining = self.escapeDuration -- 376
	self.escapePlayerX = 0 -- 377
	self.vignetteAlpha = 0 -- 379
	self.hiddenStartVignette = 0 -- 380
	self.heartbeatHz = 0 -- 381
	self.heartbeatPhase = 0 -- 382
	self.heartbeatBeatCount = 0 -- 383
	self.heartbeatPulse = 0 -- 384
	if isRetry then -- 384
		self.escapeRetryCount = self.escapeRetryCount + 1 -- 386
	end -- 386
end -- 371
function PrologueIntroPlugin.prototype.enterHiddenCabinet(self) -- 390
	self.hiddenStartVignette = self.vignetteAlpha > 0.01 and self.vignetteAlpha or 0.35 -- 391
	self.stage = "p02_hidden" -- 392
	self.stageElapsed = 0 -- 393
	self.stageDuration = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 394
	self.escapeRemaining = 0 -- 395
	self.escapePlayerX = 1 -- 396
	self.heartbeatHz = 0 -- 397
	self.heartbeatPulse = 0 -- 398
	self.heartbeatPhase = 0 -- 399
end -- 390
function PrologueIntroPlugin.prototype.triggerP04(self, anchorX, anchorY) -- 402
	self.p04Active = true -- 403
	self.p04Elapsed = 0 -- 404
	self.p04TriggeredOnce = true -- 405
	self.p04AnchorWorldX = anchorX -- 406
	self.p04AnchorWorldY = anchorY -- 407
	self:recomputeP04Weights() -- 408
end -- 402
function PrologueIntroPlugin.prototype.recomputeP04Weights(self) -- 411
	local t = self.p04Elapsed -- 412
	if t < 0.08 then -- 412
		self.p04FlashIntensity = clamp01(t / 0.08) -- 414
	elseif t < 0.55 then -- 414
		local k = (t - 0.08) / 0.47 -- 416
		local flicker = 0.86 + 0.14 * math.sin(t * 46) -- 417
		self.p04FlashIntensity = clamp01((1 - k * k) * flicker) -- 418
	else -- 418
		self.p04FlashIntensity = 0 -- 420
	end -- 420
	if t >= 0.18 then -- 420
		local reveal = smoothstep(0.18, 0.42, t) -- 423
		local settle = t > 0.55 and 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) or 0.85 -- 424
		self.p04PostHintAlpha = math.max(self.p04PostHintAlpha, reveal * settle) -- 425
		if t > 0.55 then -- 425
			self.p04PostHintAlpha = 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) -- 427
		end -- 427
	end -- 427
end -- 411
function PrologueIntroPlugin.prototype.cueKey(self, name) -- 432
	return (((("fe03:r" .. tostring(self.roomSessionId)) .. ":a") .. tostring(self.attemptSeq)) .. ":") .. name -- 433
end -- 432
function PrologueIntroPlugin.prototype.update(self, ctx) -- 436
	self.lastAudio = ctx.audio -- 437
	self:syncRuntimeHook() -- 438
	local p = ctx.p -- 439
	if self.lastRoomKey ~= "" and self.lastRoomKey ~= p.room.key then -- 439
		self:onBindPlay(p, ctx.view) -- 442
	end -- 442
	if ctx.paused or ctx.worldDt <= 0 then -- 442
		return -- 447
	end -- 447
	local dt = ctx.worldDt -- 450
	if not self.rehearsalActive then -- 450
		self:syncLiveBackendTriggers(ctx) -- 454
	end -- 454
	if self.stage == "p01_wake" then -- 454
		self:stepP01(ctx, dt) -- 459
	elseif self.stage == "p02_shadow" then -- 459
		self:stepP02Shadow(ctx, dt) -- 461
	elseif self.stage == "p02_escape" then -- 461
		self:stepP02Escape(ctx, dt) -- 463
	elseif self.stage == "p02_hidden" then -- 463
		self:stepP02Hidden(ctx, dt) -- 465
	end -- 465
	if self.p04Active then -- 465
		self:stepP04(ctx, dt) -- 470
	end -- 470
end -- 436
function PrologueIntroPlugin.prototype.syncLiveBackendTriggers(self, ctx) -- 474
	local p = ctx.p -- 475
	local pRec = asRecord(p) -- 476
	if p.room.key == "prologue" then -- 476
		local phase = p.phase -- 480
		if phase == "prologue-wake" and self.stage ~= "p01_wake" then -- 480
			self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 482
		elseif phase == "prologue-shadow" and self.stage ~= "p02_shadow" then -- 482
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 484
		elseif phase == "prologue-escape" and self.stage ~= "p02_escape" then -- 484
			local dur = readNum(pRec, "escapeDuration") or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 486
			self.escapeDuration = math.max(0.5, dur) -- 487
			self:enterEscapeFromDoorway(false) -- 488
		elseif phase == "prologue-hide" and self.stage ~= "p02_hidden" then -- 488
			self:enterHiddenCabinet() -- 490
		elseif (phase == "prologue-wait" or phase == "prologue-give") and (self.stage == "p02_escape" or self.stage == "p02_hidden") then -- 490
			self.stage = "idle" -- 495
			self.vignetteAlpha = 0 -- 496
			self.heartbeatHz = 0 -- 497
			self.heartbeatPulse = 0 -- 498
		end -- 498
	end -- 498
	local i = 0 -- 503
	do -- 503
		i = 0 -- 504
		while i < #ctx.events.rawEvents do -- 504
			local ev = ctx.events.rawEvents[i + 1] -- 505
			local ename = ev.name -- 506
			if ename == "prologueBeat" and ev.data.beat == "escapeRetry" and self.stage == "p02_escape" then -- 506
				self:retryEscape() -- 508
			elseif ename == "p04WallFlash" or ename == "wallPeekFlash" then -- 508
				if not self.p04TriggeredOnce then -- 508
					self:triggerP04(p.player.x, p.player.y) -- 511
				end -- 511
			end -- 511
			i = i + 1 -- 504
		end -- 504
	end -- 504
	if not self.p04TriggeredOnce and not p.childMode and p.player.alive and p.partner.alive then -- 504
		local inPrologueCourtyard = p.room.key == "prologue" and p.phase == "prologue-follow" and p.player.x >= p.ox + 470 and p.player.x <= p.ox + 635 -- 518
		local inStreetWallRoot = p.room.key == "street" and p.player.x >= p.ox + 115 and p.player.x <= p.ox + 265 and self:hasAliveEnemy(p) -- 521
		local inS1WellRoot = p.room.key == "s1-crossroad" and p.player.x >= p.ox + 185 and p.player.x <= p.ox + 320 -- 524
		if inPrologueCourtyard or inStreetWallRoot or inS1WellRoot then -- 524
			self:triggerP04(p.player.x, p.player.y) -- 527
		end -- 527
	end -- 527
end -- 474
function PrologueIntroPlugin.prototype.hasAliveEnemy(self, p) -- 532
	local i = 0 -- 533
	do -- 533
		i = 0 -- 534
		while i < #p.enemies do -- 534
			if p.enemies[i + 1].alive then -- 534
				return true -- 536
			end -- 536
			i = i + 1 -- 534
		end -- 534
	end -- 534
	return false -- 539
end -- 532
function PrologueIntroPlugin.prototype.stepP01(self, ctx, dt) -- 542
	self.stageElapsed = self.stageElapsed + dt -- 543
	local tick = ctx.p.ticks -- 544
	if not self.fireLoopActive then -- 544
		self.fireLoopActive = true -- 547
		ctx.audio:playLoop( -- 548
			"fe03_night_fire", -- 548
			"ambience", -- 548
			PROLOGUE_AUDIO.nightFire, -- 548
			0.34, -- 548
			tick -- 548
		) -- 548
	end -- 548
	if self.stageElapsed >= 0.12 then -- 548
		ctx.audio:playOnce( -- 551
			self:cueKey("p01_father_call"), -- 552
			"voice", -- 553
			PROLOGUE_AUDIO.fatherWake, -- 554
			0.92, -- 555
			"prologue:p01_call", -- 556
			tick -- 557
		) -- 557
	end -- 557
	if self.stageElapsed >= 1.9 then -- 557
		ctx.audio:playOnce( -- 561
			self:cueKey("p01_bed_press"), -- 562
			"sfx", -- 563
			PROLOGUE_AUDIO.bedCreak, -- 564
			0.68, -- 565
			"prologue:p01_bed_press", -- 566
			tick -- 567
		) -- 567
	end -- 567
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p01Duration then -- 567
		if self.rehearsalSequence then -- 567
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 573
		else -- 573
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p01Duration -- 575
			self.stage = "idle" -- 576
		end -- 576
	end -- 576
end -- 542
function PrologueIntroPlugin.prototype.stepP02Shadow(self, ctx, dt) -- 581
	self.stageElapsed = self.stageElapsed + dt -- 582
	local tick = ctx.p.ticks -- 583
	if self.stageElapsed >= 0.08 then -- 583
		ctx.audio:playOnce( -- 586
			self:cueKey("p02_door_commotion"), -- 587
			"ambience", -- 588
			PROLOGUE_AUDIO.doorCommotion, -- 589
			0.62, -- 590
			"prologue:p02_commotion", -- 591
			tick -- 592
		) -- 592
	end -- 592
	if self.stageElapsed >= 0.65 then -- 592
		ctx.audio:playOnce( -- 596
			self:cueKey("p02_shadow_strike"), -- 597
			"sfx", -- 598
			PROLOGUE_AUDIO.shadowStrike, -- 599
			0.85, -- 600
			"prologue:p02_shadow_cut", -- 601
			tick -- 602
		) -- 602
	end -- 602
	if self.stageElapsed >= 1.02 then -- 602
		ctx.audio:playOnce( -- 606
			self:cueKey("p02_bowl_roll"), -- 607
			"sfx", -- 608
			PROLOGUE_AUDIO.bowlRoll, -- 609
			0.76, -- 610
			"prologue:p02_bowl_roll", -- 611
			tick -- 612
		) -- 612
	end -- 612
	if self.stageElapsed >= 1.85 then -- 612
		ctx.audio:playOnce( -- 616
			self:cueKey("p02_bowl_hit"), -- 617
			"sfx", -- 618
			PROLOGUE_AUDIO.bowlHit, -- 619
			0.9, -- 620
			"prologue:p02_bowl_hit", -- 621
			tick -- 622
		) -- 622
	end -- 622
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02ShadowDuration then -- 622
		self:enterEscapeFromDoorway(false) -- 628
	end -- 628
end -- 581
function PrologueIntroPlugin.prototype.stepP02Escape(self, ctx, dt) -- 632
	self.stageElapsed = self.stageElapsed + dt -- 633
	local pRec = asRecord(ctx.p) -- 636
	local liveRemain = readNum(pRec, "escapeRemaining") -- 637
	if not self.rehearsalActive and liveRemain ~= nil then -- 637
		self.escapeRemaining = math.max(0, liveRemain) -- 639
	else -- 639
		self.escapeRemaining = math.max(0, self.escapeRemaining - dt) -- 641
	end -- 641
	if self.rehearsalActive then -- 641
		if ctx.input.moveX ~= 0 then -- 641
			self.escapePlayerX = clamp01(self.escapePlayerX + ctx.input.moveX * dt * 0.34) -- 647
		end -- 647
		if self.escapePlayerX >= 0.85 and ctx.input.interact.pressed or self.escapePlayerX >= 0.98 then -- 647
			self:enterHiddenCabinet() -- 650
			return -- 651
		end -- 651
	end -- 651
	if self.escapeRemaining <= 0 and (self.rehearsalActive or liveRemain == nil) then -- 651
		self:retryEscape() -- 657
		return -- 658
	end -- 658
	local urgency = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 661
	self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + urgency * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 662
	local prevCycle = math.floor(self.heartbeatPhase) -- 665
	self.heartbeatPhase = self.heartbeatPhase + dt * self.heartbeatHz -- 666
	local currCycle = math.floor(self.heartbeatPhase) -- 667
	if currCycle > prevCycle then -- 667
		self.heartbeatBeatCount = self.heartbeatBeatCount + 1 -- 669
		self.heartbeatPulse = 1 -- 670
		ctx.audio:playOnce( -- 671
			self:cueKey("p02_hb_" .. tostring(self.heartbeatBeatCount)), -- 672
			"sfx", -- 673
			PROLOGUE_AUDIO.heartbeat, -- 674
			0.44 + 0.48 * urgency, -- 675
			"prologue:p02_heartbeat:" .. tostring(self.heartbeatBeatCount), -- 676
			ctx.p.ticks -- 677
		) -- 677
	else -- 677
		local frac = self.heartbeatPhase - currCycle -- 681
		if frac >= 0.2 and frac <= 0.28 then -- 681
			self.heartbeatPulse = math.max(self.heartbeatPulse, 0.56) -- 683
		end -- 683
		self.heartbeatPulse = math.max(0, self.heartbeatPulse - dt * 3.8) -- 685
	end -- 685
	self.vignetteAlpha = clamp01(0.14 + urgency * 0.54 + self.heartbeatPulse * 0.16) -- 689
end -- 632
function PrologueIntroPlugin.prototype.stepP02Hidden(self, ctx, dt) -- 692
	self.stageElapsed = self.stageElapsed + dt -- 693
	local tick = ctx.p.ticks -- 694
	ctx.audio:playOnce( -- 696
		self:cueKey("p02_cabinet_shut"), -- 697
		"sfx", -- 698
		PROLOGUE_AUDIO.cabinetShut, -- 699
		0.78, -- 700
		"prologue:p02_cabinet_shut", -- 701
		tick -- 702
	) -- 702
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut then -- 702
		self.vignetteAlpha = 0 -- 707
	else -- 707
		self.vignetteAlpha = self.hiddenStartVignette * (1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 709
	end -- 709
	self.heartbeatHz = 0 -- 712
	self.heartbeatPulse = 0 -- 713
	if self.stageElapsed >= 0.3 then -- 713
		ctx.audio:playOnce( -- 717
			self:cueKey("p02_footsteps_fade"), -- 718
			"sfx", -- 719
			PROLOGUE_AUDIO.footstepsFade, -- 720
			0.65, -- 721
			"prologue:p02_footsteps_fade", -- 722
			tick -- 723
		) -- 723
	end -- 723
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenLinger then -- 723
		self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 728
		self.vignetteAlpha = 0 -- 729
		if not self.rehearsalActive then -- 729
			self.stage = "idle" -- 731
		end -- 731
	end -- 731
end -- 692
function PrologueIntroPlugin.prototype.stepP04(self, ctx, dt) -- 736
	if self.p04Elapsed == 0 then -- 736
		ctx.audio:playOnce( -- 738
			self:cueKey("p04_gunflash"), -- 739
			"sfx", -- 740
			PROLOGUE_AUDIO.distantGunflash, -- 741
			0.78, -- 742
			"prologue:p04_gunflash", -- 743
			ctx.p.ticks -- 744
		) -- 744
	end -- 744
	self.p04Elapsed = self.p04Elapsed + dt -- 747
	self:recomputeP04Weights() -- 748
	if self.p04Elapsed >= ____exports.PROLOGUE_TIMINGS.p04FlashDuration then -- 748
		self.p04Elapsed = ____exports.PROLOGUE_TIMINGS.p04FlashDuration -- 750
		self.p04FlashIntensity = 0 -- 751
		self.p04Active = false -- 752
		self.p04PostHintAlpha = 0.42 -- 754
	end -- 754
end -- 736
function PrologueIntroPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 759
	if not self.p04Active and self.p04PostHintAlpha <= 0.01 then -- 759
		return -- 766
	end -- 766
	self:drawP04WorldAction(fgDraw, fgGlow, ctx) -- 768
end -- 759
function PrologueIntroPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 772
	if self.stage == "p01_wake" then -- 772
		self:drawP01Wake( -- 780
			uiDraw, -- 780
			uiInkDraw, -- 780
			uiArt, -- 780
			uiGlow, -- 780
			ctx -- 780
		) -- 780
		return true -- 781
	end -- 781
	if self.stage == "p02_shadow" then -- 781
		self:drawP02ShadowAndBowl(uiDraw, uiInkDraw, uiGlow, ctx) -- 784
		return true -- 785
	end -- 785
	if self.stage == "p02_escape" then -- 785
		self:drawP02EscapeVignette(uiDraw, uiInkDraw, uiGlow, ctx) -- 788
		return true -- 790
	end -- 790
	if self.stage == "p02_hidden" then -- 790
		self:drawP02HiddenCabinet(uiDraw, uiInkDraw, uiGlow, ctx) -- 793
		return true -- 794
	end -- 794
	return false -- 796
end -- 772
function PrologueIntroPlugin.prototype.drawP01Wake(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 801
	local w = ctx.uiW -- 808
	local h = ctx.uiH -- 809
	local t = self.stageElapsed -- 810
	uiDraw:drawRect( -- 813
		Rect(0, 0, w, h), -- 813
		Color(6, 7, 11, 255) -- 813
	) -- 813
	local wakeOpen = smoothstep(0.75, 2.05, t) -- 815
	local blinkDip = t >= 1.25 and t <= 1.62 and math.sin((t - 1.25) / 0.37 * math.pi) * 0.24 or 0 -- 816
	local eyeOpen = clamp01(wakeOpen - blinkDip) -- 817
	local fadeOut = 1 - smoothstep(3.72, 4, t) -- 818
	if eyeOpen > 0.01 then -- 818
		local rect = computeFullscreenSlideRect(w, h) -- 821
		local pressImpulse = t >= 1.88 and t <= 2.16 and math.sin((t - 1.88) / 0.28 * math.pi) * 2.5 or 0 -- 823
		local slides = {{ -- 826
			slot = "slide_p01_01", -- 828
			start = 0, -- 829
			["end"] = 1.55, -- 830
			zoomFrom = 1, -- 831
			zoomTo = 1.03, -- 832
			transition = "cut" -- 833
		}, { -- 833
			slot = "slide_p01_02", -- 836
			start = 1.55, -- 837
			["end"] = 2.65, -- 838
			panFromY = 0.008, -- 839
			panToY = -0.006, -- 840
			zoomFrom = 1.01, -- 841
			zoomTo = 1.035, -- 842
			transition = "dark_dip", -- 843
			transitionDur = 0.24 -- 844
		}, { -- 844
			slot = "slide_p01_03", -- 847
			start = 2.65, -- 848
			["end"] = 4.05, -- 849
			panFromX = -0.014, -- 850
			panToX = 0.01, -- 851
			zoomFrom = 1, -- 852
			zoomTo = 1.025, -- 853
			transition = "dark_dip", -- 854
			transitionDur = 0.26 -- 855
		}} -- 855
		drawPixelSlideshow( -- 858
			uiDraw, -- 858
			uiInkDraw, -- 858
			uiArt, -- 858
			slides, -- 858
			t, -- 858
			rect, -- 858
			w, -- 858
			h, -- 858
			{opacity = eyeOpen * fadeOut, shakeY = -pressImpulse, layer = 1, instancePrefix = "p01_wake"} -- 858
		) -- 858
		local fireFlicker = 0.84 + 0.16 * math.sin(t * 9.5) * math.cos(t * 5.2) -- 866
		fillRadialGlow( -- 867
			uiGlow, -- 868
			w * 0.5, -- 869
			h * 0.48, -- 870
			w * 0.36, -- 871
			h * 0.3, -- 872
			Color( -- 873
				204, -- 873
				126, -- 873
				62, -- 873
				math.floor(28 * fireFlicker * eyeOpen * fadeOut + 0.5) -- 873
			), -- 873
			Color(120, 52, 28, 0), -- 874
			16 -- 875
		) -- 875
	end -- 875
	local lidH = h * 0.52 * (1 - eyeOpen) -- 880
	if lidH > 1 then -- 880
		uiInkDraw:drawRect( -- 882
			Rect(0, h - lidH, w, lidH), -- 882
			Color(5, 6, 9, 255) -- 882
		) -- 882
		uiInkDraw:drawRect( -- 883
			Rect(0, 0, w, lidH), -- 883
			Color(5, 6, 9, 255) -- 883
		) -- 883
		local feather = math.min(48, h * 0.09) -- 884
		fillVGradRect( -- 885
			uiInkDraw, -- 885
			0, -- 885
			h - lidH - feather, -- 885
			w, -- 885
			feather, -- 885
			Color(5, 6, 9, 0), -- 885
			Color(5, 6, 9, 240) -- 885
		) -- 885
		fillVGradRect( -- 886
			uiInkDraw, -- 886
			0, -- 886
			lidH, -- 886
			w, -- 886
			feather, -- 886
			Color(5, 6, 9, 240), -- 886
			Color(5, 6, 9, 0) -- 886
		) -- 886
	end -- 886
	local callAlpha = smoothstep(0.1, 0.32, t) * (1 - smoothstep(1.05, 1.55, t)) -- 890
	if callAlpha > 0.02 then -- 890
		drawSilkVeil( -- 892
			uiDraw, -- 892
			uiArt, -- 892
			"p01_call_veil", -- 892
			w * 0.5, -- 892
			h * 0.14, -- 892
			240, -- 892
			44, -- 892
			PALETTE.inkWash, -- 892
			0.78 * callAlpha, -- 892
			6 -- 892
		) -- 892
		ctx.texts:put( -- 893
			"sm", -- 894
			"「小满。」", -- 895
			w * 0.5, -- 896
			h * 0.14, -- 897
			toColor(PALETTE.textBright), -- 898
			0.5, -- 899
			0.5, -- 900
			"Center", -- 901
			2, -- 902
			callAlpha, -- 903
			0.08 -- 904
		) -- 904
	end -- 904
end -- 801
function PrologueIntroPlugin.prototype.drawP02ShadowAndBowl(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 911
	local w = ctx.uiW -- 917
	local h = ctx.uiH -- 918
	local t = self.stageElapsed -- 919
	local rect = computeFullscreenSlideRect(w, h) -- 920
	uiDraw:drawRect( -- 922
		Rect(0, 0, w, h), -- 922
		Color(6, 7, 11, 255) -- 922
	) -- 922
	local cutShake = t >= 0.62 and t <= 0.76 and math.sin(t * 110) * 3.2 or 0 -- 925
	local bowlHitShake = t >= 1.84 and t <= 1.98 and math.sin((t - 1.84) * 140) * 2.8 or 0 -- 926
	local slides = {{ -- 927
		slot = "slide_p02_01", -- 929
		start = 0, -- 930
		["end"] = 0.62, -- 931
		zoomFrom = 1, -- 932
		zoomTo = 1.02, -- 933
		transition = "cut" -- 934
	}, { -- 934
		slot = "slide_p02_02", -- 937
		start = 0.62, -- 938
		["end"] = 1.02, -- 939
		zoomFrom = 1.03, -- 940
		zoomTo = 1.01, -- 941
		transition = "cut" -- 942
	}, { -- 942
		slot = "slide_p02_03", -- 945
		start = 1.02, -- 946
		["end"] = 1.62, -- 947
		panFromX = -0.012, -- 948
		panToX = 0.008, -- 949
		transition = "dark_dip", -- 950
		transitionDur = 0.12 -- 951
	}, { -- 951
		slot = "slide_p02_04", -- 954
		start = 1.62, -- 955
		["end"] = 2.05, -- 956
		zoomFrom = 1.01, -- 957
		zoomTo = 1.025, -- 958
		transition = "cut" -- 959
	}} -- 959
	drawPixelSlideshow( -- 963
		uiDraw, -- 963
		uiInkDraw, -- 963
		ctx.uiArt, -- 963
		slides, -- 963
		t, -- 963
		rect, -- 963
		w, -- 963
		h, -- 963
		{letterboxH = 46, shakeX = cutShake + bowlHitShake, layer = 1, instancePrefix = "p02_shadow"} -- 963
	) -- 963
	if t >= 0.62 and t <= 0.72 then -- 963
		local flash = 1 - smoothstep(0.62, 0.72, t) -- 972
		uiGlow:drawRect( -- 973
			Rect(0, 0, w, h), -- 973
			Color( -- 973
				224, -- 973
				232, -- 973
				240, -- 973
				math.floor(52 * flash + 0.5) -- 973
			) -- 973
		) -- 973
	end -- 973
end -- 911
function PrologueIntroPlugin.prototype.drawP02EscapeVignette(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 979
	local w = ctx.uiW -- 985
	local h = ctx.uiH -- 986
	local a = clamp01(self.vignetteAlpha) -- 987
	if a > 0.005 then -- 987
		local edgeX = w * (0.09 + 0.06 * a) -- 990
		local edgeY = h * (0.11 + 0.07 * a) -- 991
		local peakA = math.floor(168 * a + 0.5) -- 992
		local deep = PALETTE.crimsonDeep -- 993
		local rouge = PALETTE.rouge -- 994
		local cEdge = Color(deep.r, deep.g, deep.b, peakA) -- 995
		local cZero = Color(deep.r, deep.g, deep.b, 0) -- 996
		fillHGradRect( -- 998
			uiDraw, -- 998
			0, -- 998
			0, -- 998
			edgeX, -- 998
			h, -- 998
			cEdge, -- 998
			cZero -- 998
		) -- 998
		fillHGradRect( -- 999
			uiDraw, -- 999
			w - edgeX, -- 999
			0, -- 999
			edgeX, -- 999
			h, -- 999
			cZero, -- 999
			cEdge -- 999
		) -- 999
		fillVGradRect( -- 1000
			uiDraw, -- 1000
			0, -- 1000
			0, -- 1000
			w, -- 1000
			edgeY, -- 1000
			cEdge, -- 1000
			cZero -- 1000
		) -- 1000
		fillVGradRect( -- 1001
			uiDraw, -- 1001
			0, -- 1001
			h - edgeY, -- 1001
			w, -- 1001
			edgeY, -- 1001
			cZero, -- 1001
			cEdge -- 1001
		) -- 1001
		if self.heartbeatPulse > 0.02 then -- 1001
			local pa = math.floor(62 * self.heartbeatPulse * a + 0.5) -- 1005
			local cPulse = Color(rouge.r, rouge.g, rouge.b, pa) -- 1006
			local cPulseZero = Color(rouge.r, rouge.g, rouge.b, 0) -- 1007
			fillHGradRect( -- 1008
				uiGlow, -- 1008
				0, -- 1008
				0, -- 1008
				edgeX * 0.72, -- 1008
				h, -- 1008
				cPulse, -- 1008
				cPulseZero -- 1008
			) -- 1008
			fillHGradRect( -- 1009
				uiGlow, -- 1009
				w - edgeX * 0.72, -- 1009
				0, -- 1009
				edgeX * 0.72, -- 1009
				h, -- 1009
				cPulseZero, -- 1009
				cPulse -- 1009
			) -- 1009
		end -- 1009
	end -- 1009
	if self.rehearsalActive then -- 1009
		local groundY = h * 0.24 -- 1015
		local doorX = w * 0.14 -- 1016
		local cabX = w * 0.8 -- 1017
		local childX = doorX + (cabX - doorX) * self.escapePlayerX -- 1018
		local wobble = math.sin(self.stageElapsed * 9.5) * 4 -- 1019
		uiInkDraw:drawRect( -- 1022
			Rect(doorX - 18, groundY, 16, 130), -- 1022
			Color(48, 36, 28, 220) -- 1022
		) -- 1022
		uiDraw:drawCircle( -- 1023
			Vec2(doorX + 18, groundY + 8), -- 1023
			8, -- 1023
			Color(168, 164, 152, 220) -- 1023
		) -- 1023
		uiDraw:drawRect( -- 1025
			Rect(cabX, groundY, 74, 108), -- 1025
			Color(42, 31, 24, 240), -- 1025
			1.2, -- 1025
			Color(118, 92, 68, 195) -- 1025
		) -- 1025
		uiInkDraw:drawSegment( -- 1026
			Vec2(cabX + 8 + wobble * 0.5, groundY + 6), -- 1026
			Vec2(cabX + 8 + wobble * 0.5, groundY + 100), -- 1026
			2.2, -- 1026
			Color(176, 144, 106, 210) -- 1026
		) -- 1026
		if not ctx.uiArt:tryPlace( -- 1026
			"child_run", -- 1028
			"p02_escape_child", -- 1028
			childX, -- 1028
			groundY, -- 1028
			46, -- 1028
			74, -- 1028
			{ -- 1028
				facing = 1, -- 1029
				frame = math.floor(self.stageElapsed * 10), -- 1030
				layer = 3 -- 1031
			} -- 1031
		) then -- 1031
			uiDraw:drawRect( -- 1033
				Rect(childX - 12, groundY, 24, 54), -- 1033
				Color(168, 72, 54, 235) -- 1033
			) -- 1033
		end -- 1033
	end -- 1033
end -- 979
function PrologueIntroPlugin.prototype.drawP02HiddenCabinet(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1040
	local w = ctx.uiW -- 1046
	local h = ctx.uiH -- 1047
	local t = self.stageElapsed -- 1048
	local closeK = smoothstep(0, 0.26, t) -- 1049
	local rect = computeFullscreenSlideRect(w, h) -- 1050
	uiDraw:drawRect( -- 1052
		Rect(0, 0, w, h), -- 1052
		Color(6, 7, 10, 252) -- 1052
	) -- 1052
	drawPixelSlidePlate( -- 1053
		uiDraw, -- 1054
		uiInkDraw, -- 1055
		ctx.uiArt, -- 1056
		"slide_p02_05", -- 1057
		"p02_hidden_cabinet_slide", -- 1058
		rect, -- 1059
		0.96, -- 1060
		1, -- 1061
		0, -- 1062
		0, -- 1063
		1 + closeK * 0.035 -- 1064
	) -- 1064
	local footFade = 1 - smoothstep(0.3, 0.8, t) -- 1068
	if footFade > 0.02 then -- 1068
		fillRadialGlow( -- 1070
			uiGlow, -- 1071
			w * 0.5 + (1 - footFade) * 32, -- 1072
			h * 0.45, -- 1073
			28, -- 1074
			84, -- 1075
			Color( -- 1076
				148, -- 1076
				168, -- 1076
				184, -- 1076
				math.floor(26 * footFade + 0.5) -- 1076
			), -- 1076
			Color(90, 110, 130, 0), -- 1077
			12 -- 1078
		) -- 1078
	end -- 1078
	if self.vignetteAlpha > 0.005 then -- 1078
		local a = math.floor(140 * self.vignetteAlpha + 0.5) -- 1084
		local edge = w * 0.08 -- 1085
		fillHGradRect( -- 1086
			uiInkDraw, -- 1086
			0, -- 1086
			0, -- 1086
			edge, -- 1086
			h, -- 1086
			Color(124, 38, 42, a), -- 1086
			Color(124, 38, 42, 0) -- 1086
		) -- 1086
		fillHGradRect( -- 1087
			uiInkDraw, -- 1087
			w - edge, -- 1087
			0, -- 1087
			edge, -- 1087
			h, -- 1087
			Color(124, 38, 42, 0), -- 1087
			Color(124, 38, 42, a) -- 1087
		) -- 1087
	end -- 1087
end -- 1040
function PrologueIntroPlugin.prototype.drawP04WorldAction(self, fgDraw, fgGlow, ctx) -- 1093
	local p = ctx.p -- 1098
	local cam = ctx.cam -- 1099
	local flash = self.p04FlashIntensity -- 1100
	local hintAlpha = self.p04PostHintAlpha -- 1101
	local zhou = p.childMode and p.partner or p.player -- 1103
	local xiao = p.childMode and p.player or p.partner -- 1104
	local zX = cam:sx(zhou.x) -- 1105
	local zY = cam:sy(zhou.y, zhou.depth) -- 1106
	local zH = cam:len(zhou.h) -- 1107
	local xX = cam:sx(xiao.x) -- 1108
	local xY = cam:sy(xiao.y, xiao.depth) -- 1109
	local xH = cam:len(xiao.h) -- 1110
	if flash > 0.01 then -- 1110
		fillGradQuad( -- 1114
			fgGlow, -- 1115
			cam.viewW, -- 1116
			cam.groundScreenY + cam:len(18), -- 1116
			Color( -- 1116
				238, -- 1116
				178, -- 1116
				108, -- 1116
				math.floor(88 * flash + 0.5) -- 1116
			), -- 1116
			cam.viewW, -- 1117
			cam.groundScreenY + cam:len(195), -- 1117
			Color( -- 1117
				224, -- 1117
				148, -- 1117
				82, -- 1117
				math.floor(62 * flash + 0.5) -- 1117
			), -- 1117
			zX - cam:len(140), -- 1118
			cam.groundScreenY + cam:len(140), -- 1118
			Color(200, 120, 62, 0), -- 1118
			zX - cam:len(140), -- 1119
			cam.groundScreenY, -- 1119
			Color(200, 120, 62, 0) -- 1119
		) -- 1119
		local shOpacity = 0.42 * flash -- 1122
		ctx.worldArt:tryPlace( -- 1123
			"soldier_cover", -- 1123
			"p04_wall_sh_zhou", -- 1123
			zX - cam:len(22), -- 1123
			zY + cam:len(10), -- 1123
			zH * 0.9, -- 1123
			zH * 1.15, -- 1123
			{ -- 1123
				facing = zhou.facing, -- 1124
				color = Color(8, 10, 14, 255), -- 1125
				opacity = shOpacity, -- 1126
				layer = 18 -- 1127
			} -- 1127
		) -- 1127
		ctx.worldArt:tryPlace( -- 1129
			"child_fear", -- 1129
			"p04_wall_sh_xiao", -- 1129
			xX - cam:len(18), -- 1129
			xY + cam:len(8), -- 1129
			xH * 0.85, -- 1129
			xH * 1.08, -- 1129
			{ -- 1129
				facing = xiao.facing, -- 1130
				color = Color(8, 10, 14, 255), -- 1131
				opacity = shOpacity, -- 1132
				layer = 18 -- 1133
			} -- 1133
		) -- 1133
		local shieldK = smoothstep(0.1, 0.24, self.p04Elapsed) * (1 - smoothstep(0.5, 0.78, self.p04Elapsed)) -- 1137
		if shieldK > 0.02 then -- 1137
			fillGradQuad( -- 1139
				fgDraw, -- 1140
				zX + cam:len(4), -- 1141
				zY + zH * 0.85, -- 1141
				Color( -- 1141
					10, -- 1141
					12, -- 1141
					18, -- 1141
					math.floor(74 * shieldK + 0.5) -- 1141
				), -- 1141
				zX + cam:len(4), -- 1142
				zY, -- 1142
				Color( -- 1142
					10, -- 1142
					12, -- 1142
					18, -- 1142
					math.floor(48 * shieldK + 0.5) -- 1142
				), -- 1142
				xX - cam:len(18), -- 1143
				xY, -- 1143
				Color(10, 12, 18, 0), -- 1143
				xX - cam:len(18), -- 1144
				xY + xH, -- 1144
				Color(10, 12, 18, 0) -- 1144
			) -- 1144
		end -- 1144
	end -- 1144
	if hintAlpha > 0.02 then -- 1144
		local baseWx = self.p04AnchorWorldX > 0 and self.p04AnchorWorldX or zhou.x -- 1151
		local hintBaseX = cam:sx(baseWx + 74) -- 1152
		local groundY = cam:sy(0, 0) -- 1153
		local boardY = groundY + cam:len(34) -- 1154
		local boardW = cam:len(62) -- 1155
		local aNorm = clamp01(hintAlpha + flash * 0.55) -- 1156
		ctx.worldArt:tryPlace( -- 1158
			"fe_beam_wood", -- 1158
			"p04_worn_board", -- 1158
			hintBaseX + boardW * 0.5, -- 1158
			boardY, -- 1158
			boardW, -- 1158
			cam:len(12), -- 1158
			{ -- 1158
				opacity = 0.78 * aNorm, -- 1159
				color = Color(235, 224, 206, 255), -- 1160
				layer = 24 -- 1161
			} -- 1161
		) -- 1161
		ctx.worldArt:tryPlace( -- 1163
			"fe_ground_brick", -- 1163
			"p04_stone_groove", -- 1163
			hintBaseX + boardW * 0.5 + cam:len(4), -- 1163
			groundY, -- 1163
			boardW + cam:len(36), -- 1163
			cam:len(9), -- 1163
			{ -- 1163
				opacity = 0.72 * aNorm, -- 1164
				color = Color(218, 226, 234, 255), -- 1165
				layer = 22 -- 1166
			} -- 1166
		) -- 1166
	end -- 1166
end -- 1093
return ____exports -- 1093