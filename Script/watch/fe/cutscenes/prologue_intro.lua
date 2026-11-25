-- [ts]: prologue_intro.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 19
local Color = ____Dora.Color -- 19
local Rect = ____Dora.Rect -- 19
local Vec2 = ____Dora.Vec2 -- 19
local ____theme = require("watch.fe.theme") -- 24
local PALETTE = ____theme.PALETTE -- 25
local drawSilkVeil = ____theme.drawSilkVeil -- 27
local fillGradQuad = ____theme.fillGradQuad -- 28
local fillHGradRect = ____theme.fillHGradRect -- 29
local fillRadialGlow = ____theme.fillRadialGlow -- 30
local fillVGradRect = ____theme.fillVGradRect -- 31
local rgba = ____theme.rgba -- 32
local toColor = ____theme.toColor -- 33
--- 与 fe-01（P03/P05/G05）共享的明代青布补线袖口配色口径，确保四镜视觉同源
____exports.CUFF_SHARED_SPEC = { -- 52
	indigoCloth = rgba(43, 62, 76, 255), -- 53
	indigoTrim = rgba(74, 98, 112, 255), -- 54
	mendStitch = rgba(214, 203, 184, 240), -- 55
	armWrapCloth = rgba(110, 99, 84, 255), -- 56
	stitchCount = 5 -- 57
} -- 57
____exports.PROLOGUE_TIMINGS = { -- 60
	p01Duration = 4, -- 61
	p02ShadowDuration = 2, -- 62
	p02EscapeDuration = 7.5, -- 63
	p02HiddenFadeOut = 0.28, -- 64
	p02HiddenLinger = 0.85, -- 65
	p04FlashDuration = 1, -- 66
	heartbeatMinHz = 1.15, -- 67
	heartbeatMaxHz = 2.75 -- 68
} -- 68
local PROLOGUE_AUDIO = { -- 71
	fatherWake = "assets/audio/prologue/father_wake.wav", -- 72
	nightFire = "assets/audio/prologue/night_distant_fire.wav", -- 73
	bedCreak = "assets/audio/prologue/bed_creak.wav", -- 74
	doorCommotion = "assets/audio/prologue/door_commotion.wav", -- 75
	shadowStrike = "assets/audio/prologue/shadow_strike.wav", -- 76
	bowlRoll = "assets/audio/prologue/bowl_roll.wav", -- 77
	bowlHit = "assets/audio/prologue/bowl_hit.wav", -- 78
	heartbeat = "assets/audio/prologue/heartbeat.wav", -- 79
	cabinetShut = "assets/audio/prologue/cabinet_shut.wav", -- 80
	footstepsFade = "assets/audio/prologue/footsteps_fade.wav", -- 81
	distantGunflash = "assets/audio/prologue/distant_gunflash.wav" -- 82
} -- 82
local function clamp01(v) -- 109
	return math.max( -- 110
		0, -- 110
		math.min(1, v) -- 110
	) -- 110
end -- 109
local function smoothstep(edge0, edge1, x) -- 113
	if edge1 <= edge0 then -- 113
		return x >= edge1 and 1 or 0 -- 115
	end -- 115
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 117
	return t * t * (3 - 2 * t) -- 118
end -- 113
local function asRecord(value) -- 121
	if value ~= nil and type(value) == "table" then -- 121
		return value -- 123
	end -- 123
	return nil -- 125
end -- 121
local function readNum(rec, key) -- 128
	if rec == nil then -- 128
		return nil -- 130
	end -- 130
	local v = rec[key] -- 132
	return type(v) == "number" and v or nil -- 133
end -- 128
____exports.PrologueIntroPlugin = __TS__Class() -- 136
local PrologueIntroPlugin = ____exports.PrologueIntroPlugin -- 136
PrologueIntroPlugin.name = "PrologueIntroPlugin" -- 136
function PrologueIntroPlugin.prototype.____constructor(self) -- 136
	self.id = "fe03-prologue-intro" -- 137
	self.stage = "idle" -- 139
	self.rehearsalActive = false -- 140
	self.rehearsalSequence = false -- 141
	self.stageElapsed = 0 -- 142
	self.stageDuration = 0 -- 143
	self.escapeDuration = ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 146
	self.escapeRemaining = 0 -- 147
	self.escapePlayerX = 0 -- 148
	self.vignetteAlpha = 0 -- 149
	self.hiddenStartVignette = 0 -- 150
	self.heartbeatHz = 0 -- 151
	self.heartbeatPhase = 0 -- 152
	self.heartbeatBeatCount = 0 -- 153
	self.heartbeatPulse = 0 -- 154
	self.escapeRetryCount = 0 -- 155
	self.attemptSeq = 0 -- 156
	self.p04Active = false -- 159
	self.p04Elapsed = 0 -- 160
	self.p04FlashIntensity = 0 -- 161
	self.p04PostHintAlpha = 0 -- 162
	self.p04TriggeredOnce = false -- 163
	self.p04AnchorWorldX = 0 -- 164
	self.p04AnchorWorldY = 0 -- 165
	self.roomSessionId = 0 -- 167
	self.fireLoopActive = false -- 168
	self.lastRoomKey = "" -- 169
	self.enteredContractRehearsal = false -- 172
end -- 136
function PrologueIntroPlugin.prototype.onBindPlay(self, p, _view) -- 174
	self.roomSessionId = self.roomSessionId + 1 -- 175
	self.lastRoomKey = p.room.key -- 176
	self:clearTransientState(true) -- 177
	self:syncRuntimeHook() -- 178
end -- 174
function PrologueIntroPlugin.prototype.clearTransientState(self, clearRehearsal) -- 182
	if self.fireLoopActive and self.lastAudio ~= nil then -- 182
		self.lastAudio:stopLoop("fe03_night_fire", 0) -- 184
	end -- 184
	if clearRehearsal then -- 184
		self.rehearsalActive = false -- 187
		self.rehearsalSequence = false -- 188
		if self.enteredContractRehearsal and self.boundContract ~= nil then -- 188
			self.boundContract:exitRehearsal() -- 190
		end -- 190
		self.enteredContractRehearsal = false -- 192
	end -- 192
	self.stage = "idle" -- 194
	self.stageElapsed = 0 -- 195
	self.stageDuration = 0 -- 196
	self.escapeRemaining = 0 -- 197
	self.escapePlayerX = 0 -- 198
	self.vignetteAlpha = 0 -- 199
	self.hiddenStartVignette = 0 -- 200
	self.heartbeatHz = 0 -- 201
	self.heartbeatPhase = 0 -- 202
	self.heartbeatBeatCount = 0 -- 203
	self.heartbeatPulse = 0 -- 204
	self.escapeRetryCount = 0 -- 205
	self.p04Active = false -- 206
	self.p04Elapsed = 0 -- 207
	self.p04FlashIntensity = 0 -- 208
	self.p04PostHintAlpha = 0 -- 209
	self.p04TriggeredOnce = false -- 210
	self.fireLoopActive = false -- 211
	self.attemptSeq = self.attemptSeq + 1 -- 212
end -- 182
function PrologueIntroPlugin.prototype.syncRuntimeHook(self) -- 216
	local g = _G -- 217
	local ____temp_0 -- 218
	if g.package ~= nil then -- 218
		____temp_0 = g.package.loaded -- 218
	else -- 218
		____temp_0 = nil -- 218
	end -- 218
	local loaded = ____temp_0 -- 218
	if loaded == nil then -- 218
		return -- 220
	end -- 220
	local rawFe = loaded["watch.fe"] -- 222
	if rawFe ~= nil and type(rawFe) == "table" then -- 222
		local watchFe = rawFe -- 224
		if watchFe.prologue ~= self then -- 224
			watchFe.prologue = self -- 226
		end -- 226
		if self.boundContract == nil and watchFe.contract ~= nil and type(watchFe.contract) == "table" then -- 226
			self.boundContract = watchFe.contract -- 229
		end -- 229
	end -- 229
end -- 216
function PrologueIntroPlugin.prototype.startRehearsal(self, mode, escapeDuration, contract) -- 235
	self:clearTransientState(false) -- 236
	self.rehearsalActive = true -- 237
	self.rehearsalSequence = mode == "sequence" -- 238
	if contract ~= nil then -- 238
		self.boundContract = contract -- 240
	else -- 240
		self:syncRuntimeHook() -- 242
	end -- 242
	if self.boundContract ~= nil and not self.boundContract:isRehearsal() then -- 242
		self.boundContract:enterRehearsal("fe03-prologue") -- 245
		self.enteredContractRehearsal = true -- 246
	end -- 246
	self.escapeDuration = escapeDuration ~= nil and escapeDuration > 0.5 and escapeDuration or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 248
	if mode == "p01" or mode == "sequence" then -- 248
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 253
	elseif mode == "p02" then -- 253
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 255
	elseif mode == "p02_escape" then -- 255
		self:enterEscapeFromDoorway(false) -- 257
	elseif mode == "p04" then -- 257
		self:triggerP04(0, 0) -- 259
	end -- 259
end -- 235
function PrologueIntroPlugin.prototype.stopRehearsal(self) -- 264
	self:clearTransientState(true) -- 265
end -- 264
function PrologueIntroPlugin.prototype.seekRehearsal(self, stage, seconds) -- 269
	local t = math.max(0, seconds) -- 270
	self.rehearsalActive = true -- 271
	self.rehearsalSequence = false -- 272
	if stage == "p01_wake" then -- 272
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 274
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p01Duration, t) -- 275
		return -- 276
	end -- 276
	if stage == "p02_shadow" then -- 276
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 279
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02ShadowDuration, t) -- 280
		return -- 281
	end -- 281
	if stage == "p02_escape" then -- 281
		self:enterEscapeFromDoorway(false) -- 284
		local clamped = math.min(self.escapeDuration, t) -- 285
		self.stageElapsed = clamped -- 286
		self.escapeRemaining = math.max(0, self.escapeDuration - clamped) -- 287
		local u = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 288
		self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + u * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 289
		self.vignetteAlpha = clamp01(0.14 + u * 0.56) -- 291
		return -- 292
	end -- 292
	if stage == "p02_hidden" then -- 292
		self:enterHiddenCabinet() -- 295
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02HiddenLinger, t) -- 296
		local fadeK = clamp01(1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 297
		self.vignetteAlpha = self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut and 0 or self.hiddenStartVignette * fadeK -- 298
		return -- 301
	end -- 301
	if stage == "p04_flash" then -- 301
		self.stage = "idle" -- 304
		self:triggerP04(220, 0) -- 305
		self.p04Elapsed = math.min(____exports.PROLOGUE_TIMINGS.p04FlashDuration, t) -- 306
		self:recomputeP04Weights() -- 307
		return -- 308
	end -- 308
	self:clearTransientState(false) -- 310
end -- 269
function PrologueIntroPlugin.prototype.triggerCabinetEnter(self) -- 314
	if self.stage == "p02_escape" or self.stage == "p02_shadow" then -- 314
		self:enterHiddenCabinet() -- 316
	end -- 316
end -- 314
function PrologueIntroPlugin.prototype.retryEscape(self) -- 321
	self:enterEscapeFromDoorway(true) -- 322
end -- 321
function PrologueIntroPlugin.prototype.getSnapshot(self) -- 326
	local blocks = self.stage == "p01_wake" or self.stage == "p02_shadow" -- 327
	return { -- 328
		stage = self.stage, -- 329
		active = self.stage ~= "idle" or self.p04Active or self.p04PostHintAlpha > 0.01, -- 330
		isRehearsal = self.rehearsalActive, -- 331
		stageElapsed = self.stageElapsed, -- 332
		stageDuration = self.stageDuration, -- 333
		escapeRemaining = self.escapeRemaining, -- 334
		escapeDuration = self.escapeDuration, -- 335
		escapePlayerX = self.escapePlayerX, -- 336
		vignetteAlpha = self.vignetteAlpha, -- 337
		heartbeatHz = self.heartbeatHz, -- 338
		heartbeatBeatCount = self.heartbeatBeatCount, -- 339
		heartbeatPulse = self.heartbeatPulse, -- 340
		escapeRetryCount = self.escapeRetryCount, -- 341
		p04Active = self.p04Active, -- 342
		p04Elapsed = self.p04Elapsed, -- 343
		p04FlashIntensity = self.p04FlashIntensity, -- 344
		p04PostHintAlpha = self.p04PostHintAlpha, -- 345
		p04TriggeredOnce = self.p04TriggeredOnce, -- 346
		blocksPlayerControl = blocks, -- 347
		roomSessionId = self.roomSessionId -- 348
	} -- 348
end -- 326
function PrologueIntroPlugin.prototype.enterStage(self, next, duration) -- 352
	self.stage = next -- 353
	self.stageElapsed = 0 -- 354
	self.stageDuration = duration -- 355
	if next ~= "p02_escape" and next ~= "p02_hidden" then -- 355
		self.vignetteAlpha = 0 -- 357
		self.heartbeatHz = 0 -- 358
		self.heartbeatPulse = 0 -- 359
		self.heartbeatPhase = 0 -- 360
	end -- 360
end -- 352
function PrologueIntroPlugin.prototype.enterEscapeFromDoorway(self, isRetry) -- 364
	self.attemptSeq = self.attemptSeq + 1 -- 365
	self.stage = "p02_escape" -- 366
	self.stageElapsed = 0 -- 367
	self.stageDuration = self.escapeDuration -- 368
	self.escapeRemaining = self.escapeDuration -- 369
	self.escapePlayerX = 0 -- 370
	self.vignetteAlpha = 0 -- 372
	self.hiddenStartVignette = 0 -- 373
	self.heartbeatHz = 0 -- 374
	self.heartbeatPhase = 0 -- 375
	self.heartbeatBeatCount = 0 -- 376
	self.heartbeatPulse = 0 -- 377
	if isRetry then -- 377
		self.escapeRetryCount = self.escapeRetryCount + 1 -- 379
	end -- 379
end -- 364
function PrologueIntroPlugin.prototype.enterHiddenCabinet(self) -- 383
	self.hiddenStartVignette = self.vignetteAlpha > 0.01 and self.vignetteAlpha or 0.35 -- 384
	self.stage = "p02_hidden" -- 385
	self.stageElapsed = 0 -- 386
	self.stageDuration = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 387
	self.escapeRemaining = 0 -- 388
	self.escapePlayerX = 1 -- 389
	self.heartbeatHz = 0 -- 390
	self.heartbeatPulse = 0 -- 391
	self.heartbeatPhase = 0 -- 392
end -- 383
function PrologueIntroPlugin.prototype.triggerP04(self, anchorX, anchorY) -- 395
	self.p04Active = true -- 396
	self.p04Elapsed = 0 -- 397
	self.p04TriggeredOnce = true -- 398
	self.p04AnchorWorldX = anchorX -- 399
	self.p04AnchorWorldY = anchorY -- 400
	self:recomputeP04Weights() -- 401
end -- 395
function PrologueIntroPlugin.prototype.recomputeP04Weights(self) -- 404
	local t = self.p04Elapsed -- 405
	if t < 0.08 then -- 405
		self.p04FlashIntensity = clamp01(t / 0.08) -- 407
	elseif t < 0.55 then -- 407
		local k = (t - 0.08) / 0.47 -- 409
		local flicker = 0.86 + 0.14 * math.sin(t * 46) -- 410
		self.p04FlashIntensity = clamp01((1 - k * k) * flicker) -- 411
	else -- 411
		self.p04FlashIntensity = 0 -- 413
	end -- 413
	if t >= 0.18 then -- 413
		local reveal = smoothstep(0.18, 0.42, t) -- 416
		local settle = t > 0.55 and 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) or 0.85 -- 417
		self.p04PostHintAlpha = math.max(self.p04PostHintAlpha, reveal * settle) -- 418
		if t > 0.55 then -- 418
			self.p04PostHintAlpha = 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) -- 420
		end -- 420
	end -- 420
end -- 404
function PrologueIntroPlugin.prototype.cueKey(self, name) -- 425
	return (((("fe03:r" .. tostring(self.roomSessionId)) .. ":a") .. tostring(self.attemptSeq)) .. ":") .. name -- 426
end -- 425
function PrologueIntroPlugin.prototype.update(self, ctx) -- 429
	self.lastAudio = ctx.audio -- 430
	self:syncRuntimeHook() -- 431
	local p = ctx.p -- 432
	if self.lastRoomKey ~= "" and self.lastRoomKey ~= p.room.key then -- 432
		self:onBindPlay(p, ctx.view) -- 435
	end -- 435
	if ctx.paused or ctx.worldDt <= 0 then -- 435
		return -- 440
	end -- 440
	local dt = ctx.worldDt -- 443
	if not self.rehearsalActive then -- 443
		self:syncLiveBackendTriggers(ctx) -- 447
	end -- 447
	if self.stage == "p01_wake" then -- 447
		self:stepP01(ctx, dt) -- 452
	elseif self.stage == "p02_shadow" then -- 452
		self:stepP02Shadow(ctx, dt) -- 454
	elseif self.stage == "p02_escape" then -- 454
		self:stepP02Escape(ctx, dt) -- 456
	elseif self.stage == "p02_hidden" then -- 456
		self:stepP02Hidden(ctx, dt) -- 458
	end -- 458
	if self.p04Active then -- 458
		self:stepP04(ctx, dt) -- 463
	end -- 463
end -- 429
function PrologueIntroPlugin.prototype.syncLiveBackendTriggers(self, ctx) -- 467
	local p = ctx.p -- 468
	local pRec = asRecord(p) -- 469
	if p.room.key == "prologue" then -- 469
		local phase = p.phase -- 473
		if phase == "prologue-wake" and self.stage ~= "p01_wake" then -- 473
			self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 475
		elseif phase == "prologue-shadow" and self.stage ~= "p02_shadow" then -- 475
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 477
		elseif phase == "prologue-escape" and self.stage ~= "p02_escape" then -- 477
			local dur = readNum(pRec, "escapeDuration") or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 479
			self.escapeDuration = math.max(0.5, dur) -- 480
			self:enterEscapeFromDoorway(false) -- 481
		elseif phase == "prologue-hide" and self.stage ~= "p02_hidden" then -- 481
			self:enterHiddenCabinet() -- 483
		elseif (phase == "prologue-wait" or phase == "prologue-give") and (self.stage == "p02_escape" or self.stage == "p02_hidden") then -- 483
			self.stage = "idle" -- 488
			self.vignetteAlpha = 0 -- 489
			self.heartbeatHz = 0 -- 490
			self.heartbeatPulse = 0 -- 491
		end -- 491
	end -- 491
	local i = 0 -- 496
	do -- 496
		i = 0 -- 497
		while i < #ctx.events.rawEvents do -- 497
			local ename = ctx.events.rawEvents[i + 1].name -- 498
			if ename == "p04WallFlash" or ename == "wallPeekFlash" then -- 498
				if not self.p04TriggeredOnce then -- 498
					self:triggerP04(p.player.x, p.player.y) -- 501
				end -- 501
			end -- 501
			i = i + 1 -- 497
		end -- 497
	end -- 497
	if not self.p04TriggeredOnce and not p.childMode and p.player.alive and p.partner.alive then -- 497
		local inPrologueCourtyard = p.room.key == "prologue" and p.phase == "prologue-follow" and p.player.x >= p.ox + 470 and p.player.x <= p.ox + 635 -- 508
		local inStreetWallRoot = p.room.key == "street" and p.player.x >= p.ox + 115 and p.player.x <= p.ox + 265 and self:hasAliveEnemy(p) -- 511
		local inS1WellRoot = p.room.key == "s1-crossroad" and p.player.x >= p.ox + 185 and p.player.x <= p.ox + 320 -- 514
		if inPrologueCourtyard or inStreetWallRoot or inS1WellRoot then -- 514
			self:triggerP04(p.player.x, p.player.y) -- 517
		end -- 517
	end -- 517
end -- 467
function PrologueIntroPlugin.prototype.hasAliveEnemy(self, p) -- 522
	local i = 0 -- 523
	do -- 523
		i = 0 -- 524
		while i < #p.enemies do -- 524
			if p.enemies[i + 1].alive then -- 524
				return true -- 526
			end -- 526
			i = i + 1 -- 524
		end -- 524
	end -- 524
	return false -- 529
end -- 522
function PrologueIntroPlugin.prototype.stepP01(self, ctx, dt) -- 532
	self.stageElapsed = self.stageElapsed + dt -- 533
	local tick = ctx.p.ticks -- 534
	if not self.fireLoopActive then -- 534
		self.fireLoopActive = true -- 537
		ctx.audio:playLoop( -- 538
			"fe03_night_fire", -- 538
			"ambience", -- 538
			PROLOGUE_AUDIO.nightFire, -- 538
			0.34, -- 538
			tick -- 538
		) -- 538
	end -- 538
	if self.stageElapsed >= 0.12 then -- 538
		ctx.audio:playOnce( -- 541
			self:cueKey("p01_father_call"), -- 542
			"voice", -- 543
			PROLOGUE_AUDIO.fatherWake, -- 544
			0.92, -- 545
			"prologue:p01_call", -- 546
			tick -- 547
		) -- 547
	end -- 547
	if self.stageElapsed >= 1.9 then -- 547
		ctx.audio:playOnce( -- 551
			self:cueKey("p01_bed_press"), -- 552
			"sfx", -- 553
			PROLOGUE_AUDIO.bedCreak, -- 554
			0.68, -- 555
			"prologue:p01_bed_press", -- 556
			tick -- 557
		) -- 557
	end -- 557
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p01Duration then -- 557
		if self.rehearsalSequence then -- 557
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 563
		else -- 563
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p01Duration -- 565
			self.stage = "idle" -- 566
		end -- 566
	end -- 566
end -- 532
function PrologueIntroPlugin.prototype.stepP02Shadow(self, ctx, dt) -- 571
	self.stageElapsed = self.stageElapsed + dt -- 572
	local tick = ctx.p.ticks -- 573
	if self.stageElapsed >= 0.08 then -- 573
		ctx.audio:playOnce( -- 576
			self:cueKey("p02_door_commotion"), -- 577
			"ambience", -- 578
			PROLOGUE_AUDIO.doorCommotion, -- 579
			0.62, -- 580
			"prologue:p02_commotion", -- 581
			tick -- 582
		) -- 582
	end -- 582
	if self.stageElapsed >= 0.65 then -- 582
		ctx.audio:playOnce( -- 586
			self:cueKey("p02_shadow_strike"), -- 587
			"sfx", -- 588
			PROLOGUE_AUDIO.shadowStrike, -- 589
			0.85, -- 590
			"prologue:p02_shadow_cut", -- 591
			tick -- 592
		) -- 592
	end -- 592
	if self.stageElapsed >= 1.02 then -- 592
		ctx.audio:playOnce( -- 596
			self:cueKey("p02_bowl_roll"), -- 597
			"sfx", -- 598
			PROLOGUE_AUDIO.bowlRoll, -- 599
			0.76, -- 600
			"prologue:p02_bowl_roll", -- 601
			tick -- 602
		) -- 602
	end -- 602
	if self.stageElapsed >= 1.85 then -- 602
		ctx.audio:playOnce( -- 606
			self:cueKey("p02_bowl_hit"), -- 607
			"sfx", -- 608
			PROLOGUE_AUDIO.bowlHit, -- 609
			0.9, -- 610
			"prologue:p02_bowl_hit", -- 611
			tick -- 612
		) -- 612
	end -- 612
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02ShadowDuration then -- 612
		self:enterEscapeFromDoorway(false) -- 618
	end -- 618
end -- 571
function PrologueIntroPlugin.prototype.stepP02Escape(self, ctx, dt) -- 622
	self.stageElapsed = self.stageElapsed + dt -- 623
	local pRec = asRecord(ctx.p) -- 626
	local liveRemain = readNum(pRec, "escapeRemaining") -- 627
	if not self.rehearsalActive and liveRemain ~= nil then -- 627
		self.escapeRemaining = math.max(0, liveRemain) -- 629
	else -- 629
		self.escapeRemaining = math.max(0, self.escapeRemaining - dt) -- 631
	end -- 631
	if self.rehearsalActive then -- 631
		if ctx.input.moveX ~= 0 then -- 631
			self.escapePlayerX = clamp01(self.escapePlayerX + ctx.input.moveX * dt * 0.34) -- 637
		end -- 637
		if self.escapePlayerX >= 0.85 and ctx.input.interact.pressed or self.escapePlayerX >= 0.98 then -- 637
			self:enterHiddenCabinet() -- 640
			return -- 641
		end -- 641
	end -- 641
	if self.escapeRemaining <= 0 then -- 641
		self:retryEscape() -- 647
		return -- 648
	end -- 648
	local urgency = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 651
	self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + urgency * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 652
	local prevCycle = math.floor(self.heartbeatPhase) -- 655
	self.heartbeatPhase = self.heartbeatPhase + dt * self.heartbeatHz -- 656
	local currCycle = math.floor(self.heartbeatPhase) -- 657
	if currCycle > prevCycle then -- 657
		self.heartbeatBeatCount = self.heartbeatBeatCount + 1 -- 659
		self.heartbeatPulse = 1 -- 660
		ctx.audio:playOnce( -- 661
			self:cueKey("p02_hb_" .. tostring(self.heartbeatBeatCount)), -- 662
			"sfx", -- 663
			PROLOGUE_AUDIO.heartbeat, -- 664
			0.44 + 0.48 * urgency, -- 665
			"prologue:p02_heartbeat:" .. tostring(self.heartbeatBeatCount), -- 666
			ctx.p.ticks -- 667
		) -- 667
	else -- 667
		local frac = self.heartbeatPhase - currCycle -- 671
		if frac >= 0.2 and frac <= 0.28 then -- 671
			self.heartbeatPulse = math.max(self.heartbeatPulse, 0.56) -- 673
		end -- 673
		self.heartbeatPulse = math.max(0, self.heartbeatPulse - dt * 3.8) -- 675
	end -- 675
	self.vignetteAlpha = clamp01(0.14 + urgency * 0.54 + self.heartbeatPulse * 0.16) -- 679
end -- 622
function PrologueIntroPlugin.prototype.stepP02Hidden(self, ctx, dt) -- 682
	self.stageElapsed = self.stageElapsed + dt -- 683
	local tick = ctx.p.ticks -- 684
	ctx.audio:playOnce( -- 686
		self:cueKey("p02_cabinet_shut"), -- 687
		"sfx", -- 688
		PROLOGUE_AUDIO.cabinetShut, -- 689
		0.78, -- 690
		"prologue:p02_cabinet_shut", -- 691
		tick -- 692
	) -- 692
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut then -- 692
		self.vignetteAlpha = 0 -- 697
	else -- 697
		self.vignetteAlpha = self.hiddenStartVignette * (1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 699
	end -- 699
	self.heartbeatHz = 0 -- 702
	self.heartbeatPulse = 0 -- 703
	if self.stageElapsed >= 0.3 then -- 703
		ctx.audio:playOnce( -- 707
			self:cueKey("p02_footsteps_fade"), -- 708
			"sfx", -- 709
			PROLOGUE_AUDIO.footstepsFade, -- 710
			0.65, -- 711
			"prologue:p02_footsteps_fade", -- 712
			tick -- 713
		) -- 713
	end -- 713
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenLinger then -- 713
		self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 718
		self.vignetteAlpha = 0 -- 719
		if not self.rehearsalActive then -- 719
			self.stage = "idle" -- 721
		end -- 721
	end -- 721
end -- 682
function PrologueIntroPlugin.prototype.stepP04(self, ctx, dt) -- 726
	if self.p04Elapsed == 0 then -- 726
		ctx.audio:playOnce( -- 728
			self:cueKey("p04_gunflash"), -- 729
			"sfx", -- 730
			PROLOGUE_AUDIO.distantGunflash, -- 731
			0.78, -- 732
			"prologue:p04_gunflash", -- 733
			ctx.p.ticks -- 734
		) -- 734
	end -- 734
	self.p04Elapsed = self.p04Elapsed + dt -- 737
	self:recomputeP04Weights() -- 738
	if self.p04Elapsed >= ____exports.PROLOGUE_TIMINGS.p04FlashDuration then -- 738
		self.p04Elapsed = ____exports.PROLOGUE_TIMINGS.p04FlashDuration -- 740
		self.p04FlashIntensity = 0 -- 741
		self.p04Active = false -- 742
		self.p04PostHintAlpha = 0.42 -- 744
	end -- 744
end -- 726
function PrologueIntroPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 749
	if not self.p04Active and self.p04PostHintAlpha <= 0.01 then -- 749
		return -- 756
	end -- 756
	self:drawP04WorldAction(fgDraw, fgGlow, ctx) -- 758
end -- 749
function PrologueIntroPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 762
	if self.stage == "p01_wake" then -- 762
		self:drawP01Wake( -- 770
			uiDraw, -- 770
			uiInkDraw, -- 770
			uiArt, -- 770
			uiGlow, -- 770
			ctx -- 770
		) -- 770
		return true -- 771
	end -- 771
	if self.stage == "p02_shadow" then -- 771
		self:drawP02ShadowAndBowl(uiDraw, uiInkDraw, uiGlow, ctx) -- 774
		return true -- 775
	end -- 775
	if self.stage == "p02_escape" then -- 775
		self:drawP02EscapeVignette(uiDraw, uiInkDraw, uiGlow, ctx) -- 778
		return self.rehearsalActive -- 780
	end -- 780
	if self.stage == "p02_hidden" then -- 780
		self:drawP02HiddenCabinet(uiDraw, uiInkDraw, uiGlow, ctx) -- 783
		return true -- 784
	end -- 784
	return false -- 786
end -- 762
function PrologueIntroPlugin.prototype.drawP01Wake(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 791
	local w = ctx.uiW -- 798
	local h = ctx.uiH -- 799
	local t = self.stageElapsed -- 800
	uiDraw:drawRect( -- 803
		Rect(0, 0, w, h), -- 803
		Color(6, 7, 11, 255) -- 803
	) -- 803
	local wakeOpen = smoothstep(0.75, 2.1, t) -- 806
	local blinkDip = t >= 1.25 and t <= 1.62 and math.sin((t - 1.25) / 0.37 * math.pi) * 0.24 or 0 -- 807
	local eyeOpen = clamp01(wakeOpen - blinkDip) -- 808
	local sitPan = smoothstep(2.65, 3.85, t) -- 809
	local handPress = smoothstep(1.75, 2.35, t) * (1 - smoothstep(3.15, 3.85, t) * 0.65) -- 810
	local fadeOut = 1 - smoothstep(3.72, 4, t) -- 811
	if eyeOpen > 0.01 then -- 811
		local panX = -sitPan * w * 0.16 -- 814
		local sitLiftY = sitPan * h * 0.06 -- 815
		local fireFlicker = 0.84 + 0.16 * math.sin(t * 9.5) * math.cos(t * 5.2) -- 816
		fillVGradRect( -- 819
			uiDraw, -- 820
			0, -- 821
			0, -- 822
			w, -- 823
			h, -- 824
			Color( -- 825
				16, -- 825
				14, -- 825
				18, -- 825
				math.floor(255 * eyeOpen * fadeOut + 0.5) -- 825
			), -- 825
			Color( -- 826
				34, -- 826
				24, -- 826
				24, -- 826
				math.floor(255 * eyeOpen * fadeOut + 0.5) -- 826
			) -- 826
		) -- 826
		fillRadialGlow( -- 829
			uiGlow, -- 830
			w * 0.34 + panX * 0.4, -- 831
			h * 0.62 - sitLiftY, -- 832
			w * 0.42, -- 833
			h * 0.36, -- 834
			Color( -- 835
				186, -- 835
				108, -- 835
				56, -- 835
				math.floor(68 * fireFlicker * eyeOpen * fadeOut + 0.5) -- 835
			), -- 835
			Color(120, 52, 28, 0), -- 836
			18 -- 837
		) -- 837
		local fold = 0 -- 840
		do -- 840
			fold = 0 -- 841
			while fold < 11 do -- 841
				local fx = w * (0.04 + fold * 0.095) + panX * 0.55 + math.sin(t * 1.4 + fold) * 4 -- 842
				local fw = 22 + fold % 3 * 10 -- 843
				local col = fold & 1 == 0 and Color( -- 844
					52, -- 845
					42, -- 845
					36, -- 845
					math.floor(64 * eyeOpen * fadeOut + 0.5) -- 845
				) or Color( -- 845
					24, -- 846
					20, -- 846
					22, -- 846
					math.floor(78 * eyeOpen * fadeOut + 0.5) -- 846
				) -- 846
				fillHGradRect( -- 847
					uiDraw, -- 847
					fx, -- 847
					h * 0.24, -- 847
					fw, -- 847
					h * 0.72, -- 847
					Color(col.r, col.g, col.b, 0), -- 847
					col -- 847
				) -- 847
				fold = fold + 1 -- 841
			end -- 841
		end -- 841
		local doorVis = smoothstep(2.25, 3.2, t) -- 851
		if doorVis > 0.01 then -- 851
			local doorX = w * 0.84 + panX * 0.95 -- 853
			local crackW = 14 + sitPan * 18 -- 854
			local doorBot = h * 0.14 - sitLiftY * 0.4 -- 855
			local doorH = h * 0.72 -- 856
			uiDraw:drawRect( -- 858
				Rect(doorX - 46, doorBot, 46, doorH), -- 858
				Color( -- 858
					14, -- 858
					12, -- 858
					14, -- 858
					math.floor(235 * doorVis * fadeOut + 0.5) -- 858
				) -- 858
			) -- 858
			uiDraw:drawRect( -- 859
				Rect(doorX + crackW, doorBot, 54, doorH), -- 859
				Color( -- 859
					14, -- 859
					12, -- 859
					14, -- 859
					math.floor(235 * doorVis * fadeOut + 0.5) -- 859
				) -- 859
			) -- 859
			fillVGradRect( -- 861
				uiDraw, -- 862
				doorX, -- 863
				doorBot, -- 864
				crackW, -- 865
				doorH, -- 866
				Color( -- 867
					142, -- 867
					168, -- 867
					186, -- 867
					math.floor(170 * doorVis * fadeOut + 0.5) -- 867
				), -- 867
				Color( -- 868
					214, -- 868
					168, -- 868
					118, -- 868
					math.floor(195 * doorVis * fireFlicker * fadeOut + 0.5) -- 868
				) -- 868
			) -- 868
			fillGradQuad( -- 870
				uiGlow, -- 871
				doorX, -- 872
				doorBot, -- 872
				Color( -- 872
					164, -- 872
					188, -- 872
					204, -- 872
					math.floor(64 * doorVis * fadeOut + 0.5) -- 872
				), -- 872
				doorX + crackW, -- 873
				doorBot, -- 873
				Color( -- 873
					214, -- 873
					164, -- 873
					108, -- 873
					math.floor(54 * doorVis * fadeOut + 0.5) -- 873
				), -- 873
				doorX - 135, -- 874
				doorBot - 40, -- 874
				Color(120, 148, 170, 0), -- 874
				doorX - 190, -- 875
				doorBot + doorH * 0.48, -- 875
				Color(180, 130, 82, 0) -- 875
			) -- 875
		end -- 875
		local bedTopY = h * 0.27 - sitLiftY -- 880
		local dipX = w * 0.52 + panX * 0.7 -- 881
		local pressDepth = 22 * handPress -- 882
		uiDraw:drawPolygon( -- 884
			{ -- 884
				Vec2(0, 0), -- 885
				Vec2(w, 0), -- 886
				Vec2(w, bedTopY + 10), -- 887
				Vec2(dipX + 110, bedTopY + 6), -- 888
				Vec2(dipX + 38, bedTopY - pressDepth * 0.85), -- 889
				Vec2(dipX - 34, bedTopY - pressDepth), -- 890
				Vec2(dipX - 108, bedTopY + 5), -- 891
				Vec2(0, bedTopY + 12) -- 892
			}, -- 892
			Color( -- 893
				30, -- 893
				27, -- 893
				32, -- 893
				math.floor(248 * eyeOpen * fadeOut + 0.5) -- 893
			) -- 893
		) -- 893
		uiInkDraw:drawSegment( -- 896
			Vec2(dipX - 96, bedTopY + 4), -- 897
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 898
			1.6, -- 899
			Color( -- 900
				124, -- 900
				114, -- 900
				102, -- 900
				math.floor(145 * eyeOpen * fadeOut + 0.5) -- 900
			) -- 900
		) -- 900
		uiInkDraw:drawSegment( -- 902
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 903
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 904
			1.4, -- 905
			Color( -- 906
				92, -- 906
				82, -- 906
				74, -- 906
				math.floor(165 * eyeOpen * fadeOut + 0.5) -- 906
			) -- 906
		) -- 906
		uiInkDraw:drawSegment( -- 908
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 909
			Vec2(dipX + 106, bedTopY + 5), -- 910
			1.5, -- 911
			Color( -- 912
				138, -- 912
				122, -- 912
				106, -- 912
				math.floor(140 * eyeOpen * fadeOut + 0.5) -- 912
			) -- 912
		) -- 912
		if handPress > 0.02 then -- 912
			local hx = dipX -- 917
			local hy = bedTopY - pressDepth + 14 -- 918
			local ha = math.floor(245 * handPress * fadeOut + 0.5) -- 919
			uiDraw:drawPolygon( -- 921
				{ -- 921
					Vec2(hx - 62, hy + 135), -- 922
					Vec2(hx - 14, hy + 142), -- 923
					Vec2(hx + 8, hy + 28), -- 924
					Vec2(hx - 36, hy + 24) -- 925
				}, -- 925
				Color(42, 46, 54, ha) -- 926
			) -- 926
			uiDraw:drawPolygon( -- 928
				{ -- 928
					Vec2(hx - 38, hy + 26), -- 929
					Vec2(hx + 16, hy + 28), -- 930
					Vec2(hx + 34, hy + 2), -- 931
					Vec2(hx + 22, hy - 14), -- 932
					Vec2(hx - 26, hy - 12), -- 933
					Vec2(hx - 42, hy + 4) -- 934
				}, -- 934
				Color(148, 112, 86, ha) -- 935
			) -- 935
			local f = 0 -- 937
			do -- 937
				f = 0 -- 938
				while f < 3 do -- 938
					local fx = hx - 16 + f * 15 -- 939
					uiInkDraw:drawSegment( -- 940
						Vec2(fx, hy + 10), -- 940
						Vec2(fx + 2, hy - 11), -- 940
						1.4, -- 940
						Color(68, 46, 36, ha) -- 940
					) -- 940
					f = f + 1 -- 938
				end -- 938
			end -- 938
			uiInkDraw:drawSegment( -- 942
				Vec2(hx - 34, hy + 22), -- 943
				Vec2(hx + 24, hy + 12), -- 944
				1.8, -- 945
				Color( -- 946
					214, -- 946
					168, -- 946
					126, -- 946
					math.floor(175 * handPress * fireFlicker * fadeOut + 0.5) -- 946
				) -- 946
			) -- 946
		end -- 946
	end -- 946
	local lidH = h * 0.52 * (1 - eyeOpen) -- 952
	if lidH > 1 then -- 952
		uiDraw:drawRect( -- 954
			Rect(0, h - lidH, w, lidH), -- 954
			Color(5, 6, 9, 255) -- 954
		) -- 954
		uiDraw:drawRect( -- 955
			Rect(0, 0, w, lidH), -- 955
			Color(5, 6, 9, 255) -- 955
		) -- 955
		local feather = math.min(46, h * 0.08) -- 956
		fillVGradRect( -- 957
			uiDraw, -- 957
			0, -- 957
			h - lidH - feather, -- 957
			w, -- 957
			feather, -- 957
			Color(5, 6, 9, 0), -- 957
			Color(5, 6, 9, 235) -- 957
		) -- 957
		fillVGradRect( -- 958
			uiDraw, -- 958
			0, -- 958
			lidH, -- 958
			w, -- 958
			feather, -- 958
			Color(5, 6, 9, 235), -- 958
			Color(5, 6, 9, 0) -- 958
		) -- 958
	end -- 958
	local callAlpha = smoothstep(0.1, 0.32, t) * (1 - smoothstep(1.05, 1.55, t)) -- 962
	if callAlpha > 0.02 then -- 962
		drawSilkVeil( -- 964
			uiDraw, -- 964
			uiArt, -- 964
			"p01_call_veil", -- 964
			w * 0.5, -- 964
			h * 0.14, -- 964
			240, -- 964
			44, -- 964
			PALETTE.inkWash, -- 964
			0.72 * callAlpha, -- 964
			0 -- 964
		) -- 964
		ctx.texts:put( -- 965
			"sm", -- 966
			"「小满。」", -- 967
			w * 0.5, -- 968
			h * 0.14, -- 969
			toColor(PALETTE.textBright), -- 970
			0.5, -- 971
			0.5, -- 972
			"Center", -- 973
			2, -- 974
			callAlpha, -- 975
			0.08 -- 976
		) -- 976
	end -- 976
end -- 791
function PrologueIntroPlugin.prototype.drawP02ShadowAndBowl(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 983
	local w = ctx.uiW -- 989
	local h = ctx.uiH -- 990
	local t = self.stageElapsed -- 991
	local fireFlicker = 0.85 + 0.15 * math.sin(t * 14) -- 992
	local floorY = h * 0.25 -- 995
	fillVGradRect( -- 996
		uiDraw, -- 996
		0, -- 996
		floorY, -- 996
		w, -- 996
		h - floorY, -- 996
		Color(38, 30, 28, 255), -- 996
		Color(20, 18, 24, 255) -- 996
	) -- 996
	fillVGradRect( -- 997
		uiDraw, -- 997
		0, -- 997
		0, -- 997
		w, -- 997
		floorY, -- 997
		Color(12, 12, 16, 255), -- 997
		Color(28, 24, 24, 255) -- 997
	) -- 997
	local row = 1 -- 1000
	do -- 1000
		row = 1 -- 1001
		while row <= 6 do -- 1001
			local ry = floorY + (h - floorY) * (row / 7) -- 1002
			uiInkDraw:drawSegment( -- 1003
				Vec2(0, ry), -- 1003
				Vec2(w, ry), -- 1003
				0.9, -- 1003
				Color(18, 16, 20, 110) -- 1003
			) -- 1003
			row = row + 1 -- 1001
		end -- 1001
	end -- 1001
	fillRadialGlow( -- 1007
		uiGlow, -- 1008
		w * 0.12, -- 1009
		floorY + h * 0.28, -- 1010
		w * 0.52, -- 1011
		h * 0.44, -- 1012
		Color( -- 1013
			198, -- 1013
			116, -- 1013
			56, -- 1013
			math.floor(78 * fireFlicker + 0.5) -- 1013
		), -- 1013
		Color(120, 50, 24, 0), -- 1014
		18 -- 1015
	) -- 1015
	local cutProg = smoothstep(0.62, 1.05, t) -- 1019
	local tremble = math.sin(t * 18) * 3 -- 1020
	local p1X = w * 0.42 + tremble -- 1021
	local p2X = w * 0.56 - tremble * 0.6 -- 1022
	local parentDrop = cutProg * 36 -- 1023
	uiDraw:drawPolygon( -- 1025
		{ -- 1025
			Vec2(p1X - 42, floorY), -- 1026
			Vec2(p1X + 34, floorY), -- 1027
			Vec2(p1X + 26 + cutProg * 26, floorY + 218 - parentDrop), -- 1028
			Vec2(p1X - 28 + cutProg * 14, floorY + 226 - parentDrop) -- 1029
		}, -- 1029
		Color(10, 9, 13, 215) -- 1030
	) -- 1030
	uiDraw:drawCircle( -- 1031
		Vec2(p1X + cutProg * 20, floorY + 248 - parentDrop), -- 1031
		24, -- 1031
		Color(10, 9, 13, 215) -- 1031
	) -- 1031
	uiDraw:drawPolygon( -- 1033
		{ -- 1033
			Vec2(p2X - 36, floorY), -- 1034
			Vec2(p2X + 32, floorY), -- 1035
			Vec2(p2X + 20 + cutProg * 32, floorY + 186 - parentDrop * 0.8), -- 1036
			Vec2(p2X - 24 + cutProg * 18, floorY + 194 - parentDrop * 0.8) -- 1037
		}, -- 1037
		Color(11, 10, 14, 205) -- 1038
	) -- 1038
	uiDraw:drawCircle( -- 1039
		Vec2(p2X - 2 + cutProg * 26, floorY + 214 - parentDrop * 0.8), -- 1039
		21, -- 1039
		Color(11, 10, 14, 205) -- 1039
	) -- 1039
	if cutProg > 0.01 then -- 1039
		local sx = w * (0.02 + cutProg * 0.46) -- 1043
		uiDraw:drawPolygon( -- 1044
			{ -- 1044
				Vec2(0, floorY), -- 1045
				Vec2(sx + 58, floorY), -- 1046
				Vec2(sx + 135, h), -- 1047
				Vec2(0, h) -- 1048
			}, -- 1048
			Color( -- 1049
				6, -- 1049
				6, -- 1049
				10, -- 1049
				math.floor(238 * cutProg + 0.5) -- 1049
			) -- 1049
		) -- 1049
		uiDraw:drawPolygon( -- 1051
			{ -- 1051
				Vec2(sx + 20, floorY + 160), -- 1052
				Vec2(sx + 275 * cutProg, floorY + 260), -- 1053
				Vec2(sx + 268 * cutProg, floorY + 276), -- 1054
				Vec2(sx + 14, floorY + 178) -- 1055
			}, -- 1055
			Color( -- 1056
				5, -- 1056
				5, -- 1056
				8, -- 1056
				math.floor(235 * cutProg + 0.5) -- 1056
			) -- 1056
		) -- 1056
	end -- 1056
	local threshX = w * 0.66 -- 1060
	uiDraw:drawRect( -- 1061
		Rect(threshX, floorY - 22, 26, 30), -- 1061
		Color(54, 38, 28, 255), -- 1061
		1.2, -- 1061
		Color(112, 86, 62, 210) -- 1061
	) -- 1061
	uiInkDraw:drawSegment( -- 1062
		Vec2(threshX, floorY + 8), -- 1062
		Vec2(threshX + 26, floorY + 8), -- 1062
		1.6, -- 1062
		Color(156, 128, 96, 200) -- 1062
	) -- 1062
	local rollK = smoothstep(0.98, 1.85, t) -- 1065
	if t >= 0.96 then -- 1065
		local startX = w * 0.14 -- 1067
		local stopX = threshX - 18 -- 1068
		local bx = startX + (stopX - startX) * rollK -- 1069
		local bounce = rollK < 1 and math.abs(math.sin(rollK * math.pi * 3.5)) * (1 - rollK) * 18 or 0 -- 1070
		local by = floorY + 8 + bounce -- 1071
		local tilt = rollK * math.pi * 3.2 -- 1072
		local br = 16 -- 1073
		uiDraw:drawEllipse( -- 1076
			Vec2(bx, floorY + 2), -- 1076
			18, -- 1076
			4.5, -- 1076
			Color(6, 6, 10, 175) -- 1076
		) -- 1076
		uiDraw:drawCircle( -- 1078
			Vec2(bx, by), -- 1078
			br, -- 1078
			Color(168, 164, 152, 245) -- 1078
		) -- 1078
		uiDraw:drawEllipse( -- 1079
			Vec2( -- 1080
				bx + math.cos(tilt) * 4, -- 1080
				by + math.sin(tilt) * 4 -- 1080
			), -- 1080
			br * 0.72, -- 1081
			br * 0.36, -- 1082
			Color(64, 60, 56, 235) -- 1083
		) -- 1083
		uiInkDraw:drawArc( -- 1086
			Vec2(bx, by), -- 1086
			br - 1, -- 1086
			20, -- 1086
			155, -- 1086
			1.5, -- 1086
			Color(224, 222, 214, 215) -- 1086
		) -- 1086
		if t >= 1.84 then -- 1086
			local impact = 1 - smoothstep(1.84, 2, t) -- 1088
			if impact > 0.02 then -- 1088
				uiInkDraw:drawSegment( -- 1090
					Vec2(threshX - 2, floorY + 8), -- 1091
					Vec2(threshX - 14 - (1 - impact) * 12, floorY + 18 + (1 - impact) * 8), -- 1092
					1.4, -- 1093
					Color( -- 1094
						220, -- 1094
						210, -- 1094
						194, -- 1094
						math.floor(210 * impact + 0.5) -- 1094
					) -- 1094
				) -- 1094
			end -- 1094
		end -- 1094
	end -- 1094
	local wobble = math.sin(t * 11) * 5 -- 1101
	uiDraw:drawRect( -- 1102
		Rect(w - 72 + wobble * 0.3, floorY, 64, 142), -- 1102
		Color(42, 30, 24, 250), -- 1102
		1.1, -- 1102
		Color(94, 72, 54, 180) -- 1102
	) -- 1102
	uiInkDraw:drawSegment( -- 1103
		Vec2(w - 70 + wobble, floorY + 6), -- 1103
		Vec2(w - 70 + wobble, floorY + 136), -- 1103
		2, -- 1103
		Color(146, 118, 88, 185) -- 1103
	) -- 1103
	uiDraw:drawRect( -- 1106
		Rect(0, h - 46, w, 46), -- 1106
		Color(6, 8, 12, 244) -- 1106
	) -- 1106
	uiDraw:drawRect( -- 1107
		Rect(0, 0, w, 46), -- 1107
		Color(6, 8, 12, 244) -- 1107
	) -- 1107
end -- 983
function PrologueIntroPlugin.prototype.drawP02EscapeVignette(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1112
	local w = ctx.uiW -- 1118
	local h = ctx.uiH -- 1119
	local a = clamp01(self.vignetteAlpha) -- 1120
	if a > 0.005 then -- 1120
		local edgeX = w * (0.09 + 0.06 * a) -- 1123
		local edgeY = h * (0.11 + 0.07 * a) -- 1124
		local peakA = math.floor(168 * a + 0.5) -- 1125
		local deep = PALETTE.crimsonDeep -- 1126
		local rouge = PALETTE.rouge -- 1127
		local cEdge = Color(deep.r, deep.g, deep.b, peakA) -- 1128
		local cZero = Color(deep.r, deep.g, deep.b, 0) -- 1129
		fillHGradRect( -- 1131
			uiDraw, -- 1131
			0, -- 1131
			0, -- 1131
			edgeX, -- 1131
			h, -- 1131
			cEdge, -- 1131
			cZero -- 1131
		) -- 1131
		fillHGradRect( -- 1132
			uiDraw, -- 1132
			w - edgeX, -- 1132
			0, -- 1132
			edgeX, -- 1132
			h, -- 1132
			cZero, -- 1132
			cEdge -- 1132
		) -- 1132
		fillVGradRect( -- 1133
			uiDraw, -- 1133
			0, -- 1133
			0, -- 1133
			w, -- 1133
			edgeY, -- 1133
			cEdge, -- 1133
			cZero -- 1133
		) -- 1133
		fillVGradRect( -- 1134
			uiDraw, -- 1134
			0, -- 1134
			h - edgeY, -- 1134
			w, -- 1134
			edgeY, -- 1134
			cZero, -- 1134
			cEdge -- 1134
		) -- 1134
		if self.heartbeatPulse > 0.02 then -- 1134
			local pa = math.floor(62 * self.heartbeatPulse * a + 0.5) -- 1138
			local cPulse = Color(rouge.r, rouge.g, rouge.b, pa) -- 1139
			local cPulseZero = Color(rouge.r, rouge.g, rouge.b, 0) -- 1140
			fillHGradRect( -- 1141
				uiGlow, -- 1141
				0, -- 1141
				0, -- 1141
				edgeX * 0.72, -- 1141
				h, -- 1141
				cPulse, -- 1141
				cPulseZero -- 1141
			) -- 1141
			fillHGradRect( -- 1142
				uiGlow, -- 1142
				w - edgeX * 0.72, -- 1142
				0, -- 1142
				edgeX * 0.72, -- 1142
				h, -- 1142
				cPulseZero, -- 1142
				cPulse -- 1142
			) -- 1142
		end -- 1142
	end -- 1142
	if self.rehearsalActive then -- 1142
		local groundY = h * 0.24 -- 1148
		local doorX = w * 0.14 -- 1149
		local cabX = w * 0.8 -- 1150
		local childX = doorX + (cabX - doorX) * self.escapePlayerX -- 1151
		local wobble = math.sin(self.stageElapsed * 9.5) * 4 -- 1152
		uiInkDraw:drawRect( -- 1155
			Rect(doorX - 18, groundY, 16, 130), -- 1155
			Color(48, 36, 28, 220) -- 1155
		) -- 1155
		uiDraw:drawCircle( -- 1156
			Vec2(doorX + 18, groundY + 8), -- 1156
			8, -- 1156
			Color(168, 164, 152, 220) -- 1156
		) -- 1156
		uiDraw:drawRect( -- 1158
			Rect(cabX, groundY, 74, 108), -- 1158
			Color(42, 31, 24, 240), -- 1158
			1.2, -- 1158
			Color(118, 92, 68, 195) -- 1158
		) -- 1158
		uiInkDraw:drawSegment( -- 1159
			Vec2(cabX + 8 + wobble * 0.5, groundY + 6), -- 1159
			Vec2(cabX + 8 + wobble * 0.5, groundY + 100), -- 1159
			2.2, -- 1159
			Color(176, 144, 106, 210) -- 1159
		) -- 1159
		if not ctx.uiArt:tryPlace( -- 1159
			"child_run", -- 1161
			"p02_escape_child", -- 1161
			childX, -- 1161
			groundY, -- 1161
			46, -- 1161
			74, -- 1161
			{ -- 1161
				facing = 1, -- 1162
				frame = math.floor(self.stageElapsed * 10), -- 1163
				layer = 3 -- 1164
			} -- 1164
		) then -- 1164
			uiDraw:drawRect( -- 1166
				Rect(childX - 12, groundY, 24, 54), -- 1166
				Color(168, 72, 54, 235) -- 1166
			) -- 1166
		end -- 1166
	end -- 1166
end -- 1112
function PrologueIntroPlugin.prototype.drawP02HiddenCabinet(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1173
	local w = ctx.uiW -- 1179
	local h = ctx.uiH -- 1180
	local t = self.stageElapsed -- 1181
	local closeK = smoothstep(0, 0.26, t) -- 1182
	local slitW = w * (0.28 - 0.21 * closeK) -- 1185
	local leftW = (w - slitW) * 0.5 -- 1186
	uiDraw:drawRect( -- 1187
		Rect(0, 0, leftW, h), -- 1187
		Color(7, 7, 10, 248) -- 1187
	) -- 1187
	uiDraw:drawRect( -- 1188
		Rect(w - leftW, 0, leftW, h), -- 1188
		Color(7, 7, 10, 248) -- 1188
	) -- 1188
	uiInkDraw:drawSegment( -- 1189
		Vec2(leftW, 0), -- 1189
		Vec2(leftW, h), -- 1189
		1.4, -- 1189
		Color(66, 52, 40, 175) -- 1189
	) -- 1189
	uiInkDraw:drawSegment( -- 1190
		Vec2(w - leftW, 0), -- 1190
		Vec2(w - leftW, h), -- 1190
		1.4, -- 1190
		Color(66, 52, 40, 175) -- 1190
	) -- 1190
	local footFade = 1 - smoothstep(0.3, 0.8, t) -- 1193
	if footFade > 0.02 then -- 1193
		local shadowX = w * 0.5 + (1 - footFade) * 38 -- 1195
		fillRadialGlow( -- 1196
			uiGlow, -- 1197
			shadowX, -- 1198
			h * 0.42, -- 1199
			32, -- 1200
			90, -- 1201
			Color( -- 1202
				148, -- 1202
				168, -- 1202
				184, -- 1202
				math.floor(32 * footFade + 0.5) -- 1202
			), -- 1202
			Color(90, 110, 130, 0), -- 1203
			12 -- 1204
		) -- 1204
	end -- 1204
	if self.vignetteAlpha > 0.005 then -- 1204
		local a = math.floor(140 * self.vignetteAlpha + 0.5) -- 1210
		local edge = w * 0.08 -- 1211
		fillHGradRect( -- 1212
			uiDraw, -- 1212
			0, -- 1212
			0, -- 1212
			edge, -- 1212
			h, -- 1212
			Color(124, 38, 42, a), -- 1212
			Color(124, 38, 42, 0) -- 1212
		) -- 1212
		fillHGradRect( -- 1213
			uiDraw, -- 1213
			w - edge, -- 1213
			0, -- 1213
			edge, -- 1213
			h, -- 1213
			Color(124, 38, 42, 0), -- 1213
			Color(124, 38, 42, a) -- 1213
		) -- 1213
	end -- 1213
end -- 1173
function PrologueIntroPlugin.prototype.drawP04WorldAction(self, fgDraw, fgGlow, ctx) -- 1219
	local p = ctx.p -- 1224
	local cam = ctx.cam -- 1225
	local flash = self.p04FlashIntensity -- 1226
	local hintAlpha = self.p04PostHintAlpha -- 1227
	local zhou = p.childMode and p.partner or p.player -- 1229
	local xiao = p.childMode and p.player or p.partner -- 1230
	local zX = cam:sx(zhou.x) -- 1231
	local zY = cam:sy(zhou.y, zhou.depth) -- 1232
	local zH = cam:len(zhou.h) -- 1233
	local xX = cam:sx(xiao.x) -- 1234
	local xY = cam:sy(xiao.y, xiao.depth) -- 1235
	local xH = cam:len(xiao.h) -- 1236
	if flash > 0.01 then -- 1236
		fillGradQuad( -- 1241
			fgGlow, -- 1242
			cam.viewW, -- 1243
			cam.groundScreenY + cam:len(18), -- 1243
			Color( -- 1243
				238, -- 1243
				178, -- 1243
				108, -- 1243
				math.floor(96 * flash + 0.5) -- 1243
			), -- 1243
			cam.viewW, -- 1244
			cam.groundScreenY + cam:len(195), -- 1244
			Color( -- 1244
				224, -- 1244
				148, -- 1244
				82, -- 1244
				math.floor(72 * flash + 0.5) -- 1244
			), -- 1244
			zX - cam:len(140), -- 1245
			cam.groundScreenY + cam:len(140), -- 1245
			Color(200, 120, 62, 0), -- 1245
			zX - cam:len(140), -- 1246
			cam.groundScreenY, -- 1246
			Color(200, 120, 62, 0) -- 1246
		) -- 1246
		local wallBaseY = cam.groundScreenY + cam:len(14) -- 1250
		local shAlpha = math.floor(148 * flash + 0.5) -- 1251
		local shCol = Color(8, 10, 14, shAlpha) -- 1252
		fgDraw:drawPolygon( -- 1254
			{ -- 1254
				Vec2( -- 1255
					zX - cam:len(14), -- 1255
					wallBaseY -- 1255
				), -- 1255
				Vec2( -- 1256
					zX + cam:len(6), -- 1256
					wallBaseY -- 1256
				), -- 1256
				Vec2( -- 1257
					zX - cam:len(38), -- 1257
					wallBaseY + zH * 1.18 -- 1257
				), -- 1257
				Vec2( -- 1258
					zX - cam:len(64), -- 1258
					wallBaseY + zH * 1.12 -- 1258
				) -- 1258
			}, -- 1258
			shCol -- 1259
		) -- 1259
		fgDraw:drawPolygon( -- 1261
			{ -- 1261
				Vec2( -- 1262
					xX - cam:len(10), -- 1262
					wallBaseY -- 1262
				), -- 1262
				Vec2( -- 1263
					xX + cam:len(6), -- 1263
					wallBaseY -- 1263
				), -- 1263
				Vec2( -- 1264
					xX - cam:len(26), -- 1264
					wallBaseY + xH * 1.12 -- 1264
				), -- 1264
				Vec2( -- 1265
					xX - cam:len(44), -- 1265
					wallBaseY + xH * 1.06 -- 1265
				) -- 1265
			}, -- 1265
			shCol -- 1266
		) -- 1266
		local shieldK = smoothstep(0.1, 0.24, self.p04Elapsed) * (1 - smoothstep(0.5, 0.78, self.p04Elapsed)) -- 1269
		if shieldK > 0.02 then -- 1269
			local armX = zX + cam:len(10) -- 1271
			local armY = zY + zH * 0.66 -- 1272
			local cuffW = cam:len(13) -- 1273
			local cuffH = cam:len(7) -- 1274
			local sa = math.floor(235 * shieldK + 0.5) -- 1275
			fgDraw:drawPolygon( -- 1276
				{ -- 1276
					Vec2( -- 1277
						zX + cam:len(2), -- 1277
						armY - cuffH * 0.4 -- 1277
					), -- 1277
					Vec2(armX + cuffW, armY + cuffH * 0.9), -- 1278
					Vec2(armX + cuffW * 0.72, armY + cuffH * 1.75), -- 1279
					Vec2( -- 1280
						zX - cam:len(2), -- 1280
						armY + cuffH * 0.5 -- 1280
					) -- 1280
				}, -- 1280
				toColor(____exports.CUFF_SHARED_SPEC.indigoCloth, sa) -- 1281
			) -- 1281
			fgDraw:drawSegment( -- 1283
				Vec2(armX + cuffW * 0.45, armY + cuffH * 0.75), -- 1284
				Vec2(armX + cuffW * 0.82, armY + cuffH * 1.25), -- 1285
				1.3, -- 1286
				toColor( -- 1287
					____exports.CUFF_SHARED_SPEC.mendStitch, -- 1287
					math.floor(210 * shieldK + 0.5) -- 1287
				) -- 1287
			) -- 1287
			fillGradQuad( -- 1290
				fgDraw, -- 1291
				zX + cam:len(4), -- 1292
				zY + zH * 0.85, -- 1292
				Color( -- 1292
					10, -- 1292
					12, -- 1292
					18, -- 1292
					math.floor(92 * shieldK + 0.5) -- 1292
				), -- 1292
				zX + cam:len(4), -- 1293
				zY, -- 1293
				Color( -- 1293
					10, -- 1293
					12, -- 1293
					18, -- 1293
					math.floor(62 * shieldK + 0.5) -- 1293
				), -- 1293
				xX - cam:len(18), -- 1294
				xY, -- 1294
				Color(10, 12, 18, 0), -- 1294
				xX - cam:len(18), -- 1295
				xY + xH, -- 1295
				Color(10, 12, 18, 0) -- 1295
			) -- 1295
		end -- 1295
	end -- 1295
	if hintAlpha > 0.02 then -- 1295
		local baseWx = self.p04AnchorWorldX > 0 and self.p04AnchorWorldX or zhou.x -- 1302
		local hintBaseX = cam:sx(baseWx + 74) -- 1303
		local groundY = cam:sy(0, 0) -- 1304
		local boardY = groundY + cam:len(34) -- 1305
		local boardW = cam:len(62) -- 1306
		local sheenBoost = flash * 0.55 -- 1307
		local aNorm = clamp01(hintAlpha + sheenBoost) -- 1308
		fgDraw:drawRect( -- 1311
			Rect( -- 1312
				hintBaseX, -- 1312
				boardY, -- 1312
				boardW, -- 1312
				cam:len(12) -- 1312
			), -- 1312
			Color( -- 1313
				54, -- 1313
				42, -- 1313
				32, -- 1313
				math.floor(165 * aNorm + 0.5) -- 1313
			), -- 1313
			1, -- 1314
			Color( -- 1315
				126, -- 1315
				102, -- 1315
				76, -- 1315
				math.floor(150 * aNorm + 0.5) -- 1315
			) -- 1315
		) -- 1315
		fgDraw:drawSegment( -- 1317
			Vec2(hintBaseX + 2, boardY + 1), -- 1318
			Vec2(hintBaseX + boardW - 2, boardY + 1), -- 1319
			2, -- 1320
			Color( -- 1321
				214, -- 1321
				198, -- 1321
				168, -- 1321
				math.floor(215 * aNorm + 0.5) -- 1321
			) -- 1321
		) -- 1321
		local grooveX0 = hintBaseX - cam:len(18) -- 1325
		local grooveX1 = hintBaseX + boardW + cam:len(26) -- 1326
		fgDraw:drawRect( -- 1327
			Rect( -- 1328
				grooveX0, -- 1328
				groundY + 1, -- 1328
				grooveX1 - grooveX0, -- 1328
				cam:len(4) -- 1328
			), -- 1328
			Color( -- 1329
				22, -- 1329
				26, -- 1329
				32, -- 1329
				math.floor(170 * aNorm + 0.5) -- 1329
			) -- 1329
		) -- 1329
		fgDraw:drawSegment( -- 1331
			Vec2( -- 1332
				grooveX0 + 4, -- 1332
				groundY + cam:len(5) -- 1332
			), -- 1332
			Vec2( -- 1333
				grooveX1 - 4, -- 1333
				groundY + cam:len(5) -- 1333
			), -- 1333
			1.6, -- 1334
			Color( -- 1335
				196, -- 1335
				204, -- 1335
				210, -- 1335
				math.floor(195 * aNorm + 0.5) -- 1335
			) -- 1335
		) -- 1335
	end -- 1335
end -- 1219
return ____exports -- 1219