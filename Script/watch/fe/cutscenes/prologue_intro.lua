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
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 23
local CUFF_PALETTE = ____cuff_shots.CUFF_PALETTE -- 23
local ____theme = require("Script.watch.fe.theme") -- 25
local PALETTE = ____theme.PALETTE -- 26
local drawSilkVeil = ____theme.drawSilkVeil -- 28
local fillGradQuad = ____theme.fillGradQuad -- 29
local fillHGradRect = ____theme.fillHGradRect -- 30
local fillRadialGlow = ____theme.fillRadialGlow -- 31
local fillVGradRect = ____theme.fillVGradRect -- 32
local toColor = ____theme.toColor -- 34
--- 与 fe-01（P03/P05/G05）同源的明代青布补线袖口配色口径（直接取自 cuff_shots.CUFF_PALETTE，确保四镜视觉严格一致）
____exports.CUFF_SHARED_SPEC = { -- 53
	indigoCloth = CUFF_PALETTE.indigoBase, -- 54
	indigoTrim = CUFF_PALETTE.hemEdge, -- 55
	mendStitch = CUFF_PALETTE.stitchThread, -- 56
	armWrapCloth = CUFF_PALETTE.armWrapLinen, -- 57
	stitchCount = 6 -- 58
} -- 58
____exports.PROLOGUE_TIMINGS = { -- 61
	p01Duration = 4, -- 62
	p02ShadowDuration = 2, -- 63
	p02EscapeDuration = 7.5, -- 64
	p02HiddenFadeOut = 0.28, -- 65
	p02HiddenLinger = 0.85, -- 66
	p04FlashDuration = 1, -- 67
	heartbeatMinHz = 1.15, -- 68
	heartbeatMaxHz = 2.75 -- 69
} -- 69
local PROLOGUE_AUDIO = { -- 72
	fatherWake = "assets/audio/prologue/father_wake.wav", -- 73
	nightFire = "assets/audio/prologue/night_distant_fire.wav", -- 74
	bedCreak = "assets/audio/prologue/bed_creak.wav", -- 75
	doorCommotion = "assets/audio/prologue/door_commotion.wav", -- 76
	shadowStrike = "assets/audio/prologue/shadow_strike.wav", -- 77
	bowlRoll = "assets/audio/prologue/bowl_roll.wav", -- 78
	bowlHit = "assets/audio/prologue/bowl_hit.wav", -- 79
	heartbeat = "assets/audio/prologue/heartbeat.wav", -- 80
	cabinetShut = "assets/audio/prologue/cabinet_shut.wav", -- 81
	footstepsFade = "assets/audio/prologue/footsteps_fade.wav", -- 82
	distantGunflash = "assets/audio/prologue/distant_gunflash.wav" -- 83
} -- 83
local function clamp01(v) -- 110
	return math.max( -- 111
		0, -- 111
		math.min(1, v) -- 111
	) -- 111
end -- 110
local function smoothstep(edge0, edge1, x) -- 114
	if edge1 <= edge0 then -- 115
		return x >= edge1 and 1 or 0 -- 116
	end -- 116
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 118
	return t * t * (3 - 2 * t) -- 119
end -- 114
local function asRecord(value) -- 122
	if value ~= nil and type(value) == "table" then -- 123
		return value -- 124
	end -- 124
	return nil -- 126
end -- 122
local function readNum(rec, key) -- 129
	if rec == nil then -- 130
		return nil -- 131
	end -- 131
	local v = rec[key] -- 133
	return type(v) == "number" and v or nil -- 134
end -- 129
____exports.PrologueIntroPlugin = __TS__Class() -- 137
local PrologueIntroPlugin = ____exports.PrologueIntroPlugin -- 137
PrologueIntroPlugin.name = "PrologueIntroPlugin" -- 137
function PrologueIntroPlugin.prototype.____constructor(self) -- 137
	self.id = "fe03-prologue-intro" -- 138
	self.stage = "idle" -- 140
	self.rehearsalActive = false -- 141
	self.rehearsalSequence = false -- 142
	self.stageElapsed = 0 -- 143
	self.stageDuration = 0 -- 144
	self.escapeDuration = ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 147
	self.escapeRemaining = 0 -- 148
	self.escapePlayerX = 0 -- 149
	self.vignetteAlpha = 0 -- 150
	self.hiddenStartVignette = 0 -- 151
	self.heartbeatHz = 0 -- 152
	self.heartbeatPhase = 0 -- 153
	self.heartbeatBeatCount = 0 -- 154
	self.heartbeatPulse = 0 -- 155
	self.escapeRetryCount = 0 -- 156
	self.attemptSeq = 0 -- 157
	self.p04Active = false -- 160
	self.p04Elapsed = 0 -- 161
	self.p04FlashIntensity = 0 -- 162
	self.p04PostHintAlpha = 0 -- 163
	self.p04TriggeredOnce = false -- 164
	self.p04AnchorWorldX = 0 -- 165
	self.p04AnchorWorldY = 0 -- 166
	self.roomSessionId = 0 -- 168
	self.fireLoopActive = false -- 169
	self.lastRoomKey = "" -- 170
	self.enteredContractRehearsal = false -- 173
end -- 137
function PrologueIntroPlugin.prototype.onBindPlay(self, p, _view) -- 175
	self.roomSessionId = self.roomSessionId + 1 -- 176
	self.lastRoomKey = p.room.key -- 177
	self:clearTransientState(true) -- 178
	self:syncRuntimeHook() -- 179
end -- 175
function PrologueIntroPlugin.prototype.clearTransientState(self, clearRehearsal) -- 183
	if self.fireLoopActive and self.lastAudio ~= nil then -- 184
		self.lastAudio:stopLoop("fe03_night_fire", 0) -- 185
	end -- 185
	if clearRehearsal then -- 187
		self.rehearsalActive = false -- 188
		self.rehearsalSequence = false -- 189
		if self.enteredContractRehearsal and self.boundContract ~= nil then -- 190
			self.boundContract:exitRehearsal() -- 191
		end -- 191
		self.enteredContractRehearsal = false -- 193
	end -- 193
	self.stage = "idle" -- 195
	self.stageElapsed = 0 -- 196
	self.stageDuration = 0 -- 197
	self.escapeRemaining = 0 -- 198
	self.escapePlayerX = 0 -- 199
	self.vignetteAlpha = 0 -- 200
	self.hiddenStartVignette = 0 -- 201
	self.heartbeatHz = 0 -- 202
	self.heartbeatPhase = 0 -- 203
	self.heartbeatBeatCount = 0 -- 204
	self.heartbeatPulse = 0 -- 205
	self.escapeRetryCount = 0 -- 206
	self.p04Active = false -- 207
	self.p04Elapsed = 0 -- 208
	self.p04FlashIntensity = 0 -- 209
	self.p04PostHintAlpha = 0 -- 210
	self.p04TriggeredOnce = false -- 211
	self.fireLoopActive = false -- 212
	self.attemptSeq = self.attemptSeq + 1 -- 213
end -- 183
function PrologueIntroPlugin.prototype.syncRuntimeHook(self) -- 217
	local g = _G -- 218
	local ____temp_0 -- 219
	if g.package ~= nil then -- 219
		____temp_0 = g.package.loaded -- 219
	else -- 219
		____temp_0 = nil -- 219
	end -- 219
	local loaded = ____temp_0 -- 219
	if loaded == nil then -- 220
		return -- 221
	end -- 221
	local rawFe = loaded["watch.fe"] -- 223
	if rawFe ~= nil and type(rawFe) == "table" then -- 224
		local watchFe = rawFe -- 225
		if watchFe.prologue ~= self then -- 226
			watchFe.prologue = self -- 227
		end -- 227
		if self.boundContract == nil and watchFe.contract ~= nil and type(watchFe.contract) == "table" then -- 229
			self.boundContract = watchFe.contract -- 230
		end -- 230
	end -- 230
end -- 217
function PrologueIntroPlugin.prototype.startRehearsal(self, mode, escapeDuration, contract) -- 236
	self:clearTransientState(false) -- 237
	self.rehearsalActive = true -- 238
	self.rehearsalSequence = mode == "sequence" -- 239
	if contract ~= nil then -- 240
		self.boundContract = contract -- 241
	else -- 241
		self:syncRuntimeHook() -- 243
	end -- 243
	if self.boundContract ~= nil and not self.boundContract:isRehearsal() then -- 245
		self.boundContract:enterRehearsal("fe03-prologue") -- 246
		self.enteredContractRehearsal = true -- 247
	end -- 247
	self.escapeDuration = escapeDuration ~= nil and escapeDuration > 0.5 and escapeDuration or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 249
	if mode == "p01" or mode == "sequence" then -- 253
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 254
	elseif mode == "p02" then -- 255
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 256
	elseif mode == "p02_escape" then -- 257
		self:enterEscapeFromDoorway(false) -- 258
	elseif mode == "p04" then -- 259
		self:triggerP04(0, 0) -- 260
	end -- 260
end -- 236
function PrologueIntroPlugin.prototype.stopRehearsal(self) -- 265
	self:clearTransientState(true) -- 266
end -- 265
function PrologueIntroPlugin.prototype.seekRehearsal(self, stage, seconds) -- 270
	local t = math.max(0, seconds) -- 271
	self.rehearsalActive = true -- 272
	self.rehearsalSequence = false -- 273
	if stage == "p01_wake" then -- 274
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 275
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p01Duration, t) -- 276
		return -- 277
	end -- 277
	if stage == "p02_shadow" then -- 279
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 280
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02ShadowDuration, t) -- 281
		return -- 282
	end -- 282
	if stage == "p02_escape" then -- 284
		self:enterEscapeFromDoorway(false) -- 285
		local clamped = math.min(self.escapeDuration, t) -- 286
		self.stageElapsed = clamped -- 287
		self.escapeRemaining = math.max(0, self.escapeDuration - clamped) -- 288
		local u = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 289
		self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + u * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 290
		self.vignetteAlpha = clamp01(0.14 + u * 0.56) -- 292
		return -- 293
	end -- 293
	if stage == "p02_hidden" then -- 295
		self:enterHiddenCabinet() -- 296
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02HiddenLinger, t) -- 297
		local fadeK = clamp01(1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 298
		self.vignetteAlpha = self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut and 0 or self.hiddenStartVignette * fadeK -- 299
		return -- 302
	end -- 302
	if stage == "p04_flash" then -- 304
		self.stage = "idle" -- 305
		self:triggerP04(220, 0) -- 306
		self.p04Elapsed = math.min(____exports.PROLOGUE_TIMINGS.p04FlashDuration, t) -- 307
		self:recomputeP04Weights() -- 308
		return -- 309
	end -- 309
	self:clearTransientState(false) -- 311
end -- 270
function PrologueIntroPlugin.prototype.triggerCabinetEnter(self) -- 315
	if self.stage == "p02_escape" or self.stage == "p02_shadow" then -- 316
		self:enterHiddenCabinet() -- 317
	end -- 317
end -- 315
function PrologueIntroPlugin.prototype.retryEscape(self) -- 322
	self:enterEscapeFromDoorway(true) -- 323
end -- 322
function PrologueIntroPlugin.prototype.getSnapshot(self) -- 327
	local blocks = self.stage == "p01_wake" or self.stage == "p02_shadow" -- 328
	return { -- 329
		stage = self.stage, -- 330
		active = self.stage ~= "idle" or self.p04Active or self.p04PostHintAlpha > 0.01, -- 331
		isRehearsal = self.rehearsalActive, -- 332
		stageElapsed = self.stageElapsed, -- 333
		stageDuration = self.stageDuration, -- 334
		escapeRemaining = self.escapeRemaining, -- 335
		escapeDuration = self.escapeDuration, -- 336
		escapePlayerX = self.escapePlayerX, -- 337
		vignetteAlpha = self.vignetteAlpha, -- 338
		heartbeatHz = self.heartbeatHz, -- 339
		heartbeatBeatCount = self.heartbeatBeatCount, -- 340
		heartbeatPulse = self.heartbeatPulse, -- 341
		escapeRetryCount = self.escapeRetryCount, -- 342
		p04Active = self.p04Active, -- 343
		p04Elapsed = self.p04Elapsed, -- 344
		p04FlashIntensity = self.p04FlashIntensity, -- 345
		p04PostHintAlpha = self.p04PostHintAlpha, -- 346
		p04TriggeredOnce = self.p04TriggeredOnce, -- 347
		blocksPlayerControl = blocks, -- 348
		roomSessionId = self.roomSessionId -- 349
	} -- 349
end -- 327
function PrologueIntroPlugin.prototype.enterStage(self, next, duration) -- 353
	self.stage = next -- 354
	self.stageElapsed = 0 -- 355
	self.stageDuration = duration -- 356
	if next ~= "p02_escape" and next ~= "p02_hidden" then -- 357
		self.vignetteAlpha = 0 -- 358
		self.heartbeatHz = 0 -- 359
		self.heartbeatPulse = 0 -- 360
		self.heartbeatPhase = 0 -- 361
	end -- 361
end -- 353
function PrologueIntroPlugin.prototype.enterEscapeFromDoorway(self, isRetry) -- 365
	self.attemptSeq = self.attemptSeq + 1 -- 366
	self.stage = "p02_escape" -- 367
	self.stageElapsed = 0 -- 368
	self.stageDuration = self.escapeDuration -- 369
	self.escapeRemaining = self.escapeDuration -- 370
	self.escapePlayerX = 0 -- 371
	self.vignetteAlpha = 0 -- 373
	self.hiddenStartVignette = 0 -- 374
	self.heartbeatHz = 0 -- 375
	self.heartbeatPhase = 0 -- 376
	self.heartbeatBeatCount = 0 -- 377
	self.heartbeatPulse = 0 -- 378
	if isRetry then -- 379
		self.escapeRetryCount = self.escapeRetryCount + 1 -- 380
	end -- 380
end -- 365
function PrologueIntroPlugin.prototype.enterHiddenCabinet(self) -- 384
	self.hiddenStartVignette = self.vignetteAlpha > 0.01 and self.vignetteAlpha or 0.35 -- 385
	self.stage = "p02_hidden" -- 386
	self.stageElapsed = 0 -- 387
	self.stageDuration = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 388
	self.escapeRemaining = 0 -- 389
	self.escapePlayerX = 1 -- 390
	self.heartbeatHz = 0 -- 391
	self.heartbeatPulse = 0 -- 392
	self.heartbeatPhase = 0 -- 393
end -- 384
function PrologueIntroPlugin.prototype.triggerP04(self, anchorX, anchorY) -- 396
	self.p04Active = true -- 397
	self.p04Elapsed = 0 -- 398
	self.p04TriggeredOnce = true -- 399
	self.p04AnchorWorldX = anchorX -- 400
	self.p04AnchorWorldY = anchorY -- 401
	self:recomputeP04Weights() -- 402
end -- 396
function PrologueIntroPlugin.prototype.recomputeP04Weights(self) -- 405
	local t = self.p04Elapsed -- 406
	if t < 0.08 then -- 407
		self.p04FlashIntensity = clamp01(t / 0.08) -- 408
	elseif t < 0.55 then -- 409
		local k = (t - 0.08) / 0.47 -- 410
		local flicker = 0.86 + 0.14 * math.sin(t * 46) -- 411
		self.p04FlashIntensity = clamp01((1 - k * k) * flicker) -- 412
	else -- 412
		self.p04FlashIntensity = 0 -- 414
	end -- 414
	if t >= 0.18 then -- 416
		local reveal = smoothstep(0.18, 0.42, t) -- 417
		local settle = t > 0.55 and 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) or 0.85 -- 418
		self.p04PostHintAlpha = math.max(self.p04PostHintAlpha, reveal * settle) -- 419
		if t > 0.55 then -- 420
			self.p04PostHintAlpha = 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) -- 421
		end -- 421
	end -- 421
end -- 405
function PrologueIntroPlugin.prototype.cueKey(self, name) -- 426
	return (((("fe03:r" .. tostring(self.roomSessionId)) .. ":a") .. tostring(self.attemptSeq)) .. ":") .. name -- 427
end -- 426
function PrologueIntroPlugin.prototype.update(self, ctx) -- 430
	self.lastAudio = ctx.audio -- 431
	self:syncRuntimeHook() -- 432
	local p = ctx.p -- 433
	if self.lastRoomKey ~= "" and self.lastRoomKey ~= p.room.key then -- 435
		self:onBindPlay(p, ctx.view) -- 436
	end -- 436
	if ctx.paused or ctx.worldDt <= 0 then -- 440
		return -- 441
	end -- 441
	local dt = ctx.worldDt -- 444
	if not self.rehearsalActive then -- 447
		self:syncLiveBackendTriggers(ctx) -- 448
	end -- 448
	if self.stage == "p01_wake" then -- 452
		self:stepP01(ctx, dt) -- 453
	elseif self.stage == "p02_shadow" then -- 454
		self:stepP02Shadow(ctx, dt) -- 455
	elseif self.stage == "p02_escape" then -- 456
		self:stepP02Escape(ctx, dt) -- 457
	elseif self.stage == "p02_hidden" then -- 458
		self:stepP02Hidden(ctx, dt) -- 459
	end -- 459
	if self.p04Active then -- 463
		self:stepP04(ctx, dt) -- 464
	end -- 464
end -- 430
function PrologueIntroPlugin.prototype.syncLiveBackendTriggers(self, ctx) -- 468
	local p = ctx.p -- 469
	local pRec = asRecord(p) -- 470
	if p.room.key == "prologue" then -- 473
		local phase = p.phase -- 474
		if phase == "prologue-wake" and self.stage ~= "p01_wake" then -- 475
			self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 476
		elseif phase == "prologue-shadow" and self.stage ~= "p02_shadow" then -- 477
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 478
		elseif phase == "prologue-escape" and self.stage ~= "p02_escape" then -- 479
			local dur = readNum(pRec, "escapeDuration") or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 480
			self.escapeDuration = math.max(0.5, dur) -- 481
			self:enterEscapeFromDoorway(false) -- 482
		elseif phase == "prologue-hide" and self.stage ~= "p02_hidden" then -- 483
			self:enterHiddenCabinet() -- 484
		elseif (phase == "prologue-wait" or phase == "prologue-give" or phase == "prologue-follow") and (self.stage == "p01_wake" or self.stage == "p02_shadow" or self.stage == "p02_escape" or self.stage == "p02_hidden") then -- 486
			self.stage = "idle" -- 492
			self.vignetteAlpha = 0 -- 493
			self.heartbeatHz = 0 -- 494
			self.heartbeatPulse = 0 -- 495
		end -- 495
	end -- 495
	local i = 0 -- 500
	do -- 500
		i = 0 -- 501
		while i < #ctx.events.rawEvents do -- 501
			local ev = ctx.events.rawEvents[i + 1] -- 502
			local ename = ev.name -- 503
			if ename == "prologueBeat" and ev.data.beat == "escapeRetry" and self.stage == "p02_escape" then -- 504
				self:retryEscape() -- 505
			elseif ename == "p04WallFlash" or ename == "wallPeekFlash" then -- 506
				if not self.p04TriggeredOnce and p.run.story.segments.p04_wall_flash ~= true then -- 507
					p.run.story.segments.p04_wall_flash = true -- 508
					self:triggerP04(p.player.x, p.player.y) -- 509
				end -- 509
			end -- 509
			i = i + 1 -- 501
		end -- 501
	end -- 501
	if not self.p04TriggeredOnce and p.run.story.segments.p04_wall_flash ~= true and not p.childMode and p.player.alive and p.partner.alive then -- 515
		local inPrologueCourtyard = p.room.key == "prologue" and p.phase == "prologue-follow" and p.player.x >= p.ox + 470 and p.player.x <= p.ox + 635 -- 516
		local inStreetWallRoot = p.room.key == "street" and p.player.x >= p.ox + 115 and p.player.x <= p.ox + 265 and self:hasAliveEnemy(p) -- 519
		local inS1WellRoot = p.room.key == "s1-crossroad" and p.player.x >= p.ox + 185 and p.player.x <= p.ox + 320 -- 522
		if inPrologueCourtyard or inStreetWallRoot or inS1WellRoot then -- 524
			p.run.story.segments.p04_wall_flash = true -- 525
			self:triggerP04(p.player.x, p.player.y) -- 526
		end -- 526
	end -- 526
end -- 468
function PrologueIntroPlugin.prototype.hasAliveEnemy(self, p) -- 531
	local i = 0 -- 532
	do -- 532
		i = 0 -- 533
		while i < #p.enemies do -- 533
			if p.enemies[i + 1].alive then -- 534
				return true -- 535
			end -- 535
			i = i + 1 -- 533
		end -- 533
	end -- 533
	return false -- 538
end -- 531
function PrologueIntroPlugin.prototype.stepP01(self, ctx, dt) -- 541
	self.stageElapsed = self.stageElapsed + dt -- 542
	local tick = ctx.p.ticks -- 543
	if not self.fireLoopActive then -- 545
		self.fireLoopActive = true -- 546
		ctx.audio:playLoop( -- 547
			"fe03_night_fire", -- 547
			"ambience", -- 547
			PROLOGUE_AUDIO.nightFire, -- 547
			0.34, -- 547
			tick -- 547
		) -- 547
	end -- 547
	if self.stageElapsed >= 0.12 then -- 549
		ctx.audio:playOnce( -- 550
			self:cueKey("p01_father_call"), -- 551
			"voice", -- 552
			PROLOGUE_AUDIO.fatherWake, -- 553
			0.92, -- 554
			"prologue:p01_call", -- 555
			tick -- 556
		) -- 556
	end -- 556
	if self.stageElapsed >= 1.9 then -- 559
		ctx.audio:playOnce( -- 560
			self:cueKey("p01_bed_press"), -- 561
			"sfx", -- 562
			PROLOGUE_AUDIO.bedCreak, -- 563
			0.68, -- 564
			"prologue:p01_bed_press", -- 565
			tick -- 566
		) -- 566
	end -- 566
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p01Duration then -- 570
		if self.rehearsalSequence then -- 571
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 572
		elseif self.rehearsalActive then -- 573
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p01Duration -- 574
			self.stage = "idle" -- 575
		else -- 575
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p01Duration -- 578
		end -- 578
	end -- 578
end -- 541
function PrologueIntroPlugin.prototype.stepP02Shadow(self, ctx, dt) -- 583
	self.stageElapsed = self.stageElapsed + dt -- 584
	local tick = ctx.p.ticks -- 585
	if self.stageElapsed >= 0.08 then -- 587
		ctx.audio:playOnce( -- 588
			self:cueKey("p02_door_commotion"), -- 589
			"ambience", -- 590
			PROLOGUE_AUDIO.doorCommotion, -- 591
			0.62, -- 592
			"prologue:p02_commotion", -- 593
			tick -- 594
		) -- 594
	end -- 594
	if self.stageElapsed >= 0.65 then -- 597
		ctx.audio:playOnce( -- 598
			self:cueKey("p02_shadow_strike"), -- 599
			"sfx", -- 600
			PROLOGUE_AUDIO.shadowStrike, -- 601
			0.85, -- 602
			"prologue:p02_shadow_cut", -- 603
			tick -- 604
		) -- 604
	end -- 604
	if self.stageElapsed >= 1.02 then -- 607
		ctx.audio:playOnce( -- 608
			self:cueKey("p02_bowl_roll"), -- 609
			"sfx", -- 610
			PROLOGUE_AUDIO.bowlRoll, -- 611
			0.76, -- 612
			"prologue:p02_bowl_roll", -- 613
			tick -- 614
		) -- 614
	end -- 614
	if self.stageElapsed >= 1.85 then -- 617
		ctx.audio:playOnce( -- 618
			self:cueKey("p02_bowl_hit"), -- 619
			"sfx", -- 620
			PROLOGUE_AUDIO.bowlHit, -- 621
			0.9, -- 622
			"prologue:p02_bowl_hit", -- 623
			tick -- 624
		) -- 624
	end -- 624
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02ShadowDuration then -- 628
		if self.rehearsalActive then -- 629
			self:enterEscapeFromDoorway(false) -- 631
		else -- 631
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02ShadowDuration -- 634
		end -- 634
	end -- 634
end -- 583
function PrologueIntroPlugin.prototype.stepP02Escape(self, ctx, dt) -- 639
	self.stageElapsed = self.stageElapsed + dt -- 640
	local pRec = asRecord(ctx.p) -- 643
	local liveRemain = readNum(pRec, "escapeRemaining") -- 644
	if not self.rehearsalActive and liveRemain ~= nil then -- 645
		self.escapeRemaining = math.max(0, liveRemain) -- 646
	else -- 646
		self.escapeRemaining = math.max(0, self.escapeRemaining - dt) -- 648
	end -- 648
	if self.rehearsalActive then -- 652
		if ctx.input.moveX ~= 0 then -- 653
			self.escapePlayerX = clamp01(self.escapePlayerX + ctx.input.moveX * dt * 0.34) -- 654
		end -- 654
		if self.escapePlayerX >= 0.85 and ctx.input.interact.pressed or self.escapePlayerX >= 0.98 then -- 656
			self:enterHiddenCabinet() -- 657
			return -- 658
		end -- 658
	end -- 658
	if self.escapeRemaining <= 0 and (self.rehearsalActive or liveRemain == nil) then -- 663
		self:retryEscape() -- 664
		return -- 665
	end -- 665
	local urgency = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 668
	self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + urgency * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 669
	local prevCycle = math.floor(self.heartbeatPhase) -- 672
	self.heartbeatPhase = self.heartbeatPhase + dt * self.heartbeatHz -- 673
	local currCycle = math.floor(self.heartbeatPhase) -- 674
	if currCycle > prevCycle then -- 675
		self.heartbeatBeatCount = self.heartbeatBeatCount + 1 -- 676
		self.heartbeatPulse = 1 -- 677
		ctx.audio:playOnce( -- 678
			self:cueKey("p02_hb_" .. tostring(self.heartbeatBeatCount)), -- 679
			"sfx", -- 680
			PROLOGUE_AUDIO.heartbeat, -- 681
			0.44 + 0.48 * urgency, -- 682
			"prologue:p02_heartbeat:" .. tostring(self.heartbeatBeatCount), -- 683
			ctx.p.ticks -- 684
		) -- 684
	else -- 684
		local frac = self.heartbeatPhase - currCycle -- 688
		if frac >= 0.2 and frac <= 0.28 then -- 689
			self.heartbeatPulse = math.max(self.heartbeatPulse, 0.56) -- 690
		end -- 690
		self.heartbeatPulse = math.max(0, self.heartbeatPulse - dt * 3.8) -- 692
	end -- 692
	self.vignetteAlpha = clamp01(0.14 + urgency * 0.54 + self.heartbeatPulse * 0.16) -- 696
end -- 639
function PrologueIntroPlugin.prototype.stepP02Hidden(self, ctx, dt) -- 699
	self.stageElapsed = self.stageElapsed + dt -- 700
	local tick = ctx.p.ticks -- 701
	ctx.audio:playOnce( -- 703
		self:cueKey("p02_cabinet_shut"), -- 704
		"sfx", -- 705
		PROLOGUE_AUDIO.cabinetShut, -- 706
		0.78, -- 707
		"prologue:p02_cabinet_shut", -- 708
		tick -- 709
	) -- 709
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut then -- 713
		self.vignetteAlpha = 0 -- 714
	else -- 714
		self.vignetteAlpha = self.hiddenStartVignette * (1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 716
	end -- 716
	self.heartbeatHz = 0 -- 719
	self.heartbeatPulse = 0 -- 720
	if self.stageElapsed >= 0.3 then -- 723
		ctx.audio:playOnce( -- 724
			self:cueKey("p02_footsteps_fade"), -- 725
			"sfx", -- 726
			PROLOGUE_AUDIO.footstepsFade, -- 727
			0.65, -- 728
			"prologue:p02_footsteps_fade", -- 729
			tick -- 730
		) -- 730
	end -- 730
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenLinger then -- 734
		self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 735
		self.vignetteAlpha = 0 -- 736
	end -- 736
end -- 699
function PrologueIntroPlugin.prototype.stepP04(self, ctx, dt) -- 740
	if self.p04Elapsed == 0 then -- 741
		ctx.audio:playOnce( -- 742
			self:cueKey("p04_gunflash"), -- 743
			"sfx", -- 744
			PROLOGUE_AUDIO.distantGunflash, -- 745
			0.78, -- 746
			"prologue:p04_gunflash", -- 747
			ctx.p.ticks -- 748
		) -- 748
	end -- 748
	self.p04Elapsed = self.p04Elapsed + dt -- 751
	self:recomputeP04Weights() -- 752
	if self.p04Elapsed >= ____exports.PROLOGUE_TIMINGS.p04FlashDuration then -- 753
		self.p04Elapsed = ____exports.PROLOGUE_TIMINGS.p04FlashDuration -- 754
		self.p04FlashIntensity = 0 -- 755
		self.p04Active = false -- 756
		self.p04PostHintAlpha = 0.42 -- 758
	end -- 758
end -- 740
function PrologueIntroPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 763
	if self.stage == "p02_escape" and not self.rehearsalActive and ctx.p.room.key == "prologue" then -- 769
		local cam = ctx.cam -- 770
		local cabX = cam:sx(ctx.p.ox + PROLOGUE_CABINET_X + 18) -- 771
		local cabY = cam:sy(0, 0) -- 772
		local pulse = 0.65 + 0.35 * math.sin(self.stageElapsed * 6.5) -- 773
		local sway = math.sin(self.stageElapsed * 9) * cam:len(2.5) -- 774
		fillRadialGlow( -- 776
			fgGlow, -- 777
			cabX + sway, -- 778
			cabY + cam:len(34), -- 779
			cam:len(38), -- 780
			cam:len(46), -- 781
			Color( -- 782
				232, -- 782
				178, -- 782
				104, -- 782
				math.floor(68 * pulse + 0.5) -- 782
			), -- 782
			Color(186, 118, 56, 0), -- 783
			14 -- 784
		) -- 784
		fgDraw:drawSegment( -- 786
			Vec2( -- 787
				cabX + sway, -- 787
				cabY + cam:len(4) -- 787
			), -- 787
			Vec2( -- 788
				cabX + sway, -- 788
				cabY + cam:len(54) -- 788
			), -- 788
			2, -- 789
			Color( -- 790
				238, -- 790
				198, -- 790
				134, -- 790
				math.floor(165 * pulse + 0.5) -- 790
			) -- 790
		) -- 790
	end -- 790
	if not self.p04Active and self.p04PostHintAlpha <= 0.01 then -- 793
		return -- 794
	end -- 794
	self:drawP04WorldAction(fgDraw, fgGlow, ctx) -- 796
end -- 763
function PrologueIntroPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 800
	if self.stage == "p01_wake" then -- 807
		self:drawP01Wake( -- 808
			uiDraw, -- 808
			uiInkDraw, -- 808
			uiArt, -- 808
			uiGlow, -- 808
			ctx -- 808
		) -- 808
		return true -- 809
	end -- 809
	if self.stage == "p02_shadow" then -- 811
		self:drawP02ShadowAndBowl(uiDraw, uiInkDraw, uiGlow, ctx) -- 812
		return true -- 813
	end -- 813
	if self.stage == "p02_escape" then -- 815
		self:drawP02EscapeVignette(uiDraw, uiInkDraw, uiGlow, ctx) -- 816
		return true -- 818
	end -- 818
	if self.stage == "p02_hidden" then -- 820
		self:drawP02HiddenCabinet(uiDraw, uiInkDraw, uiGlow, ctx) -- 821
		return true -- 822
	end -- 822
	return false -- 824
end -- 800
function PrologueIntroPlugin.prototype.drawP01Wake(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 829
	local w = ctx.uiW -- 836
	local h = ctx.uiH -- 837
	local t = self.stageElapsed -- 838
	uiDraw:drawRect( -- 841
		Rect(0, 0, w, h), -- 841
		Color(6, 7, 11, 255) -- 841
	) -- 841
	local wakeOpen = smoothstep(0.75, 2.1, t) -- 844
	local blinkDip = t >= 1.25 and t <= 1.62 and math.sin((t - 1.25) / 0.37 * math.pi) * 0.24 or 0 -- 845
	local eyeOpen = clamp01(wakeOpen - blinkDip) -- 846
	local sitPan = smoothstep(2.65, 3.85, t) -- 847
	local handPress = smoothstep(1.75, 2.35, t) * (1 - smoothstep(3.15, 3.85, t) * 0.65) -- 848
	local fadeOut = 1 - smoothstep(3.72, 4, t) -- 849
	if eyeOpen > 0.01 then -- 851
		local panX = -sitPan * w * 0.16 -- 852
		local sitLiftY = sitPan * h * 0.06 -- 853
		local fireFlicker = 0.84 + 0.16 * math.sin(t * 9.5) * math.cos(t * 5.2) -- 854
		fillVGradRect( -- 857
			uiDraw, -- 858
			0, -- 859
			0, -- 860
			w, -- 861
			h, -- 862
			Color( -- 863
				16, -- 863
				14, -- 863
				18, -- 863
				math.floor(255 * eyeOpen * fadeOut + 0.5) -- 863
			), -- 863
			Color( -- 864
				34, -- 864
				24, -- 864
				24, -- 864
				math.floor(255 * eyeOpen * fadeOut + 0.5) -- 864
			) -- 864
		) -- 864
		fillRadialGlow( -- 867
			uiGlow, -- 868
			w * 0.34 + panX * 0.4, -- 869
			h * 0.62 - sitLiftY, -- 870
			w * 0.42, -- 871
			h * 0.36, -- 872
			Color( -- 873
				186, -- 873
				108, -- 873
				56, -- 873
				math.floor(68 * fireFlicker * eyeOpen * fadeOut + 0.5) -- 873
			), -- 873
			Color(120, 52, 28, 0), -- 874
			18 -- 875
		) -- 875
		local fold = 0 -- 878
		do -- 878
			fold = 0 -- 879
			while fold < 11 do -- 879
				local fx = w * (0.04 + fold * 0.095) + panX * 0.55 + math.sin(t * 1.4 + fold) * 4 -- 880
				local fw = 22 + fold % 3 * 10 -- 881
				local col = fold & 1 == 0 and Color( -- 882
					52, -- 883
					42, -- 883
					36, -- 883
					math.floor(64 * eyeOpen * fadeOut + 0.5) -- 883
				) or Color( -- 884
					24, -- 884
					20, -- 884
					22, -- 884
					math.floor(78 * eyeOpen * fadeOut + 0.5) -- 884
				) -- 884
				fillHGradRect( -- 885
					uiDraw, -- 885
					fx, -- 885
					h * 0.24, -- 885
					fw, -- 885
					h * 0.72, -- 885
					Color(col.r, col.g, col.b, 0), -- 885
					col -- 885
				) -- 885
				fold = fold + 1 -- 879
			end -- 879
		end -- 879
		local doorVis = smoothstep(2.25, 3.2, t) -- 889
		if doorVis > 0.01 then -- 890
			local doorX = w * 0.84 + panX * 0.95 -- 891
			local crackW = 14 + sitPan * 18 -- 892
			local doorBot = h * 0.14 - sitLiftY * 0.4 -- 893
			local doorH = h * 0.72 -- 894
			uiDraw:drawRect( -- 896
				Rect(doorX - 46, doorBot, 46, doorH), -- 896
				Color( -- 896
					14, -- 896
					12, -- 896
					14, -- 896
					math.floor(235 * doorVis * fadeOut + 0.5) -- 896
				) -- 896
			) -- 896
			uiDraw:drawRect( -- 897
				Rect(doorX + crackW, doorBot, 54, doorH), -- 897
				Color( -- 897
					14, -- 897
					12, -- 897
					14, -- 897
					math.floor(235 * doorVis * fadeOut + 0.5) -- 897
				) -- 897
			) -- 897
			fillVGradRect( -- 899
				uiDraw, -- 900
				doorX, -- 901
				doorBot, -- 902
				crackW, -- 903
				doorH, -- 904
				Color( -- 905
					142, -- 905
					168, -- 905
					186, -- 905
					math.floor(170 * doorVis * fadeOut + 0.5) -- 905
				), -- 905
				Color( -- 906
					214, -- 906
					168, -- 906
					118, -- 906
					math.floor(195 * doorVis * fireFlicker * fadeOut + 0.5) -- 906
				) -- 906
			) -- 906
			fillGradQuad( -- 908
				uiGlow, -- 909
				doorX, -- 910
				doorBot, -- 910
				Color( -- 910
					164, -- 910
					188, -- 910
					204, -- 910
					math.floor(64 * doorVis * fadeOut + 0.5) -- 910
				), -- 910
				doorX + crackW, -- 911
				doorBot, -- 911
				Color( -- 911
					214, -- 911
					164, -- 911
					108, -- 911
					math.floor(54 * doorVis * fadeOut + 0.5) -- 911
				), -- 911
				doorX - 135, -- 912
				doorBot - 40, -- 912
				Color(120, 148, 170, 0), -- 912
				doorX - 190, -- 913
				doorBot + doorH * 0.48, -- 913
				Color(180, 130, 82, 0) -- 913
			) -- 913
		end -- 913
		local bedTopY = h * 0.27 - sitLiftY -- 918
		local dipX = w * 0.52 + panX * 0.7 -- 919
		local pressDepth = 22 * handPress -- 920
		uiDraw:drawPolygon( -- 922
			{ -- 922
				Vec2(0, 0), -- 923
				Vec2(w, 0), -- 924
				Vec2(w, bedTopY + 10), -- 925
				Vec2(dipX + 110, bedTopY + 6), -- 926
				Vec2(dipX + 38, bedTopY - pressDepth * 0.85), -- 927
				Vec2(dipX - 34, bedTopY - pressDepth), -- 928
				Vec2(dipX - 108, bedTopY + 5), -- 929
				Vec2(0, bedTopY + 12) -- 930
			}, -- 930
			Color( -- 931
				30, -- 931
				27, -- 931
				32, -- 931
				math.floor(248 * eyeOpen * fadeOut + 0.5) -- 931
			) -- 931
		) -- 931
		uiInkDraw:drawSegment( -- 934
			Vec2(dipX - 96, bedTopY + 4), -- 935
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 936
			1.6, -- 937
			Color( -- 938
				124, -- 938
				114, -- 938
				102, -- 938
				math.floor(145 * eyeOpen * fadeOut + 0.5) -- 938
			) -- 938
		) -- 938
		uiInkDraw:drawSegment( -- 940
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 941
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 942
			1.4, -- 943
			Color( -- 944
				92, -- 944
				82, -- 944
				74, -- 944
				math.floor(165 * eyeOpen * fadeOut + 0.5) -- 944
			) -- 944
		) -- 944
		uiInkDraw:drawSegment( -- 946
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 947
			Vec2(dipX + 106, bedTopY + 5), -- 948
			1.5, -- 949
			Color( -- 950
				138, -- 950
				122, -- 950
				106, -- 950
				math.floor(140 * eyeOpen * fadeOut + 0.5) -- 950
			) -- 950
		) -- 950
		if handPress > 0.02 then -- 954
			local hx = dipX -- 955
			local hy = bedTopY - pressDepth + 14 -- 956
			local ha = math.floor(245 * handPress * fadeOut + 0.5) -- 957
			uiDraw:drawPolygon( -- 959
				{ -- 959
					Vec2(hx - 62, hy + 135), -- 960
					Vec2(hx - 14, hy + 142), -- 961
					Vec2(hx + 8, hy + 28), -- 962
					Vec2(hx - 36, hy + 24) -- 963
				}, -- 963
				Color(42, 46, 54, ha) -- 964
			) -- 964
			uiDraw:drawPolygon( -- 966
				{ -- 966
					Vec2(hx - 38, hy + 26), -- 967
					Vec2(hx + 16, hy + 28), -- 968
					Vec2(hx + 34, hy + 2), -- 969
					Vec2(hx + 22, hy - 14), -- 970
					Vec2(hx - 26, hy - 12), -- 971
					Vec2(hx - 42, hy + 4) -- 972
				}, -- 972
				Color(148, 112, 86, ha) -- 973
			) -- 973
			local f = 0 -- 975
			do -- 975
				f = 0 -- 976
				while f < 3 do -- 976
					local fx = hx - 16 + f * 15 -- 977
					uiInkDraw:drawSegment( -- 978
						Vec2(fx, hy + 10), -- 978
						Vec2(fx + 2, hy - 11), -- 978
						1.4, -- 978
						Color(68, 46, 36, ha) -- 978
					) -- 978
					f = f + 1 -- 976
				end -- 976
			end -- 976
			uiInkDraw:drawSegment( -- 980
				Vec2(hx - 34, hy + 22), -- 981
				Vec2(hx + 24, hy + 12), -- 982
				1.8, -- 983
				Color( -- 984
					214, -- 984
					168, -- 984
					126, -- 984
					math.floor(175 * handPress * fireFlicker * fadeOut + 0.5) -- 984
				) -- 984
			) -- 984
		end -- 984
	end -- 984
	local lidH = h * 0.52 * (1 - eyeOpen) -- 990
	if lidH > 1 then -- 991
		uiDraw:drawRect( -- 992
			Rect(0, h - lidH, w, lidH), -- 992
			Color(5, 6, 9, 255) -- 992
		) -- 992
		uiDraw:drawRect( -- 993
			Rect(0, 0, w, lidH), -- 993
			Color(5, 6, 9, 255) -- 993
		) -- 993
		local feather = math.min(46, h * 0.08) -- 994
		fillVGradRect( -- 995
			uiDraw, -- 995
			0, -- 995
			h - lidH - feather, -- 995
			w, -- 995
			feather, -- 995
			Color(5, 6, 9, 0), -- 995
			Color(5, 6, 9, 235) -- 995
		) -- 995
		fillVGradRect( -- 996
			uiDraw, -- 996
			0, -- 996
			lidH, -- 996
			w, -- 996
			feather, -- 996
			Color(5, 6, 9, 235), -- 996
			Color(5, 6, 9, 0) -- 996
		) -- 996
	end -- 996
	if self.rehearsalActive then -- 1000
		local callAlpha = smoothstep(0.1, 0.32, t) * (1 - smoothstep(1.05, 1.55, t)) -- 1001
		if callAlpha > 0.02 then -- 1002
			drawSilkVeil( -- 1003
				uiDraw, -- 1003
				uiArt, -- 1003
				"p01_call_veil", -- 1003
				w * 0.5, -- 1003
				h * 0.14, -- 1003
				240, -- 1003
				44, -- 1003
				PALETTE.inkWash, -- 1003
				0.72 * callAlpha, -- 1003
				0 -- 1003
			) -- 1003
			ctx.texts:put( -- 1004
				"sm", -- 1005
				"「小满。」", -- 1006
				w * 0.5, -- 1007
				h * 0.14, -- 1008
				toColor(PALETTE.textBright), -- 1009
				0.5, -- 1010
				0.5, -- 1011
				"Center", -- 1012
				2, -- 1013
				callAlpha, -- 1014
				0.08 -- 1015
			) -- 1015
		end -- 1015
	end -- 1015
end -- 829
function PrologueIntroPlugin.prototype.drawP02ShadowAndBowl(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1023
	local w = ctx.uiW -- 1029
	local h = ctx.uiH -- 1030
	local t = self.stageElapsed -- 1031
	local fireFlicker = 0.85 + 0.15 * math.sin(t * 14) -- 1032
	local floorY = h * 0.25 -- 1035
	fillVGradRect( -- 1036
		uiDraw, -- 1036
		0, -- 1036
		floorY, -- 1036
		w, -- 1036
		h - floorY, -- 1036
		Color(38, 30, 28, 255), -- 1036
		Color(20, 18, 24, 255) -- 1036
	) -- 1036
	fillVGradRect( -- 1037
		uiDraw, -- 1037
		0, -- 1037
		0, -- 1037
		w, -- 1037
		floorY, -- 1037
		Color(12, 12, 16, 255), -- 1037
		Color(28, 24, 24, 255) -- 1037
	) -- 1037
	local row = 1 -- 1040
	do -- 1040
		row = 1 -- 1041
		while row <= 6 do -- 1041
			local ry = floorY + (h - floorY) * (row / 7) -- 1042
			uiInkDraw:drawSegment( -- 1043
				Vec2(0, ry), -- 1043
				Vec2(w, ry), -- 1043
				0.9, -- 1043
				Color(18, 16, 20, 110) -- 1043
			) -- 1043
			row = row + 1 -- 1041
		end -- 1041
	end -- 1041
	fillRadialGlow( -- 1047
		uiGlow, -- 1048
		w * 0.12, -- 1049
		floorY + h * 0.28, -- 1050
		w * 0.52, -- 1051
		h * 0.44, -- 1052
		Color( -- 1053
			198, -- 1053
			116, -- 1053
			56, -- 1053
			math.floor(78 * fireFlicker + 0.5) -- 1053
		), -- 1053
		Color(120, 50, 24, 0), -- 1054
		18 -- 1055
	) -- 1055
	local cutProg = smoothstep(0.62, 1.05, t) -- 1059
	local tremble = math.sin(t * 18) * 3 -- 1060
	local p1X = w * 0.42 + tremble -- 1061
	local p2X = w * 0.56 - tremble * 0.6 -- 1062
	local parentDrop = cutProg * 36 -- 1063
	uiDraw:drawPolygon( -- 1065
		{ -- 1065
			Vec2(p1X - 42, floorY), -- 1066
			Vec2(p1X + 34, floorY), -- 1067
			Vec2(p1X + 26 + cutProg * 26, floorY + 218 - parentDrop), -- 1068
			Vec2(p1X - 28 + cutProg * 14, floorY + 226 - parentDrop) -- 1069
		}, -- 1069
		Color(10, 9, 13, 215) -- 1070
	) -- 1070
	uiDraw:drawCircle( -- 1071
		Vec2(p1X + cutProg * 20, floorY + 248 - parentDrop), -- 1071
		24, -- 1071
		Color(10, 9, 13, 215) -- 1071
	) -- 1071
	uiDraw:drawPolygon( -- 1073
		{ -- 1073
			Vec2(p2X - 36, floorY), -- 1074
			Vec2(p2X + 32, floorY), -- 1075
			Vec2(p2X + 20 + cutProg * 32, floorY + 186 - parentDrop * 0.8), -- 1076
			Vec2(p2X - 24 + cutProg * 18, floorY + 194 - parentDrop * 0.8) -- 1077
		}, -- 1077
		Color(11, 10, 14, 205) -- 1078
	) -- 1078
	uiDraw:drawCircle( -- 1079
		Vec2(p2X - 2 + cutProg * 26, floorY + 214 - parentDrop * 0.8), -- 1079
		21, -- 1079
		Color(11, 10, 14, 205) -- 1079
	) -- 1079
	if cutProg > 0.01 then -- 1082
		local sx = w * (0.02 + cutProg * 0.46) -- 1083
		uiDraw:drawPolygon( -- 1084
			{ -- 1084
				Vec2(0, floorY), -- 1085
				Vec2(sx + 58, floorY), -- 1086
				Vec2(sx + 135, h), -- 1087
				Vec2(0, h) -- 1088
			}, -- 1088
			Color( -- 1089
				6, -- 1089
				6, -- 1089
				10, -- 1089
				math.floor(238 * cutProg + 0.5) -- 1089
			) -- 1089
		) -- 1089
		uiDraw:drawPolygon( -- 1091
			{ -- 1091
				Vec2(sx + 20, floorY + 160), -- 1092
				Vec2(sx + 275 * cutProg, floorY + 260), -- 1093
				Vec2(sx + 268 * cutProg, floorY + 276), -- 1094
				Vec2(sx + 14, floorY + 178) -- 1095
			}, -- 1095
			Color( -- 1096
				5, -- 1096
				5, -- 1096
				8, -- 1096
				math.floor(235 * cutProg + 0.5) -- 1096
			) -- 1096
		) -- 1096
	end -- 1096
	local threshX = w * 0.66 -- 1100
	uiDraw:drawRect( -- 1101
		Rect(threshX, floorY - 22, 26, 30), -- 1101
		Color(54, 38, 28, 255), -- 1101
		1.2, -- 1101
		Color(112, 86, 62, 210) -- 1101
	) -- 1101
	uiInkDraw:drawSegment( -- 1102
		Vec2(threshX, floorY + 8), -- 1102
		Vec2(threshX + 26, floorY + 8), -- 1102
		1.6, -- 1102
		Color(156, 128, 96, 200) -- 1102
	) -- 1102
	local rollK = smoothstep(0.98, 1.85, t) -- 1105
	if t >= 0.96 then -- 1106
		local startX = w * 0.14 -- 1107
		local stopX = threshX - 18 -- 1108
		local bx = startX + (stopX - startX) * rollK -- 1109
		local bounce = rollK < 1 and math.abs(math.sin(rollK * math.pi * 3.5)) * (1 - rollK) * 18 or 0 -- 1110
		local by = floorY + 8 + bounce -- 1111
		local tilt = rollK * math.pi * 3.2 -- 1112
		local br = 16 -- 1113
		uiDraw:drawEllipse( -- 1116
			Vec2(bx, floorY + 2), -- 1116
			18, -- 1116
			4.5, -- 1116
			Color(6, 6, 10, 175) -- 1116
		) -- 1116
		uiDraw:drawCircle( -- 1118
			Vec2(bx, by), -- 1118
			br, -- 1118
			Color(168, 164, 152, 245) -- 1118
		) -- 1118
		uiDraw:drawEllipse( -- 1119
			Vec2( -- 1120
				bx + math.cos(tilt) * 4, -- 1120
				by + math.sin(tilt) * 4 -- 1120
			), -- 1120
			br * 0.72, -- 1121
			br * 0.36, -- 1122
			Color(64, 60, 56, 235) -- 1123
		) -- 1123
		uiInkDraw:drawArc( -- 1126
			Vec2(bx, by), -- 1126
			br - 1, -- 1126
			20, -- 1126
			155, -- 1126
			1.5, -- 1126
			Color(224, 222, 214, 215) -- 1126
		) -- 1126
		if t >= 1.84 then -- 1127
			local impact = 1 - smoothstep(1.84, 2, t) -- 1128
			if impact > 0.02 then -- 1129
				uiInkDraw:drawSegment( -- 1130
					Vec2(threshX - 2, floorY + 8), -- 1131
					Vec2(threshX - 14 - (1 - impact) * 12, floorY + 18 + (1 - impact) * 8), -- 1132
					1.4, -- 1133
					Color( -- 1134
						220, -- 1134
						210, -- 1134
						194, -- 1134
						math.floor(210 * impact + 0.5) -- 1134
					) -- 1134
				) -- 1134
			end -- 1134
		end -- 1134
	end -- 1134
	local wobble = math.sin(t * 11) * 5 -- 1141
	uiDraw:drawRect( -- 1142
		Rect(w - 72 + wobble * 0.3, floorY, 64, 142), -- 1142
		Color(42, 30, 24, 250), -- 1142
		1.1, -- 1142
		Color(94, 72, 54, 180) -- 1142
	) -- 1142
	uiInkDraw:drawSegment( -- 1143
		Vec2(w - 70 + wobble, floorY + 6), -- 1143
		Vec2(w - 70 + wobble, floorY + 136), -- 1143
		2, -- 1143
		Color(146, 118, 88, 185) -- 1143
	) -- 1143
	uiDraw:drawRect( -- 1146
		Rect(0, h - 46, w, 46), -- 1146
		Color(6, 8, 12, 244) -- 1146
	) -- 1146
	uiDraw:drawRect( -- 1147
		Rect(0, 0, w, 46), -- 1147
		Color(6, 8, 12, 244) -- 1147
	) -- 1147
end -- 1023
function PrologueIntroPlugin.prototype.drawP02EscapeVignette(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1152
	local w = ctx.uiW -- 1158
	local h = ctx.uiH -- 1159
	local a = clamp01(self.vignetteAlpha) -- 1160
	if a > 0.005 then -- 1162
		local edgeX = w * (0.09 + 0.06 * a) -- 1163
		local edgeY = h * (0.11 + 0.07 * a) -- 1164
		local peakA = math.floor(168 * a + 0.5) -- 1165
		local deep = PALETTE.crimsonDeep -- 1166
		local rouge = PALETTE.rouge -- 1167
		local cEdge = Color(deep.r, deep.g, deep.b, peakA) -- 1168
		local cZero = Color(deep.r, deep.g, deep.b, 0) -- 1169
		fillHGradRect( -- 1171
			uiDraw, -- 1171
			0, -- 1171
			0, -- 1171
			edgeX, -- 1171
			h, -- 1171
			cEdge, -- 1171
			cZero -- 1171
		) -- 1171
		fillHGradRect( -- 1172
			uiDraw, -- 1172
			w - edgeX, -- 1172
			0, -- 1172
			edgeX, -- 1172
			h, -- 1172
			cZero, -- 1172
			cEdge -- 1172
		) -- 1172
		fillVGradRect( -- 1173
			uiDraw, -- 1173
			0, -- 1173
			0, -- 1173
			w, -- 1173
			edgeY, -- 1173
			cEdge, -- 1173
			cZero -- 1173
		) -- 1173
		fillVGradRect( -- 1174
			uiDraw, -- 1174
			0, -- 1174
			h - edgeY, -- 1174
			w, -- 1174
			edgeY, -- 1174
			cZero, -- 1174
			cEdge -- 1174
		) -- 1174
		if self.heartbeatPulse > 0.02 then -- 1177
			local pa = math.floor(62 * self.heartbeatPulse * a + 0.5) -- 1178
			local cPulse = Color(rouge.r, rouge.g, rouge.b, pa) -- 1179
			local cPulseZero = Color(rouge.r, rouge.g, rouge.b, 0) -- 1180
			fillHGradRect( -- 1181
				uiGlow, -- 1181
				0, -- 1181
				0, -- 1181
				edgeX * 0.72, -- 1181
				h, -- 1181
				cPulse, -- 1181
				cPulseZero -- 1181
			) -- 1181
			fillHGradRect( -- 1182
				uiGlow, -- 1182
				w - edgeX * 0.72, -- 1182
				0, -- 1182
				edgeX * 0.72, -- 1182
				h, -- 1182
				cPulseZero, -- 1182
				cPulse -- 1182
			) -- 1182
		end -- 1182
	end -- 1182
	if self.rehearsalActive then -- 1187
		local groundY = h * 0.24 -- 1188
		local doorX = w * 0.14 -- 1189
		local cabX = w * 0.8 -- 1190
		local childX = doorX + (cabX - doorX) * self.escapePlayerX -- 1191
		local wobble = math.sin(self.stageElapsed * 9.5) * 4 -- 1192
		uiInkDraw:drawRect( -- 1195
			Rect(doorX - 18, groundY, 16, 130), -- 1195
			Color(48, 36, 28, 220) -- 1195
		) -- 1195
		uiDraw:drawCircle( -- 1196
			Vec2(doorX + 18, groundY + 8), -- 1196
			8, -- 1196
			Color(168, 164, 152, 220) -- 1196
		) -- 1196
		uiDraw:drawRect( -- 1198
			Rect(cabX, groundY, 74, 108), -- 1198
			Color(42, 31, 24, 240), -- 1198
			1.2, -- 1198
			Color(118, 92, 68, 195) -- 1198
		) -- 1198
		uiInkDraw:drawSegment( -- 1199
			Vec2(cabX + 8 + wobble * 0.5, groundY + 6), -- 1199
			Vec2(cabX + 8 + wobble * 0.5, groundY + 100), -- 1199
			2.2, -- 1199
			Color(176, 144, 106, 210) -- 1199
		) -- 1199
		if not ctx.uiArt:tryPlace( -- 1201
			"child_run", -- 1201
			"p02_escape_child", -- 1201
			childX, -- 1201
			groundY, -- 1201
			46, -- 1201
			74, -- 1201
			{ -- 1201
				facing = 1, -- 1202
				frame = math.floor(self.stageElapsed * 10), -- 1203
				layer = 3 -- 1204
			} -- 1204
		) then -- 1204
			uiDraw:drawRect( -- 1206
				Rect(childX - 12, groundY, 24, 54), -- 1206
				Color(168, 72, 54, 235) -- 1206
			) -- 1206
		end -- 1206
	end -- 1206
end -- 1152
function PrologueIntroPlugin.prototype.drawP02HiddenCabinet(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1213
	local w = ctx.uiW -- 1219
	local h = ctx.uiH -- 1220
	local t = self.stageElapsed -- 1221
	local closeK = smoothstep(0, 0.26, t) -- 1222
	local slitW = w * (0.28 - 0.21 * closeK) -- 1225
	local leftW = (w - slitW) * 0.5 -- 1226
	uiDraw:drawRect( -- 1227
		Rect(0, 0, leftW, h), -- 1227
		Color(7, 7, 10, 248) -- 1227
	) -- 1227
	uiDraw:drawRect( -- 1228
		Rect(w - leftW, 0, leftW, h), -- 1228
		Color(7, 7, 10, 248) -- 1228
	) -- 1228
	uiInkDraw:drawSegment( -- 1229
		Vec2(leftW, 0), -- 1229
		Vec2(leftW, h), -- 1229
		1.4, -- 1229
		Color(66, 52, 40, 175) -- 1229
	) -- 1229
	uiInkDraw:drawSegment( -- 1230
		Vec2(w - leftW, 0), -- 1230
		Vec2(w - leftW, h), -- 1230
		1.4, -- 1230
		Color(66, 52, 40, 175) -- 1230
	) -- 1230
	local footFade = 1 - smoothstep(0.3, 0.8, t) -- 1233
	if footFade > 0.02 then -- 1234
		local shadowX = w * 0.5 + (1 - footFade) * 38 -- 1235
		fillRadialGlow( -- 1236
			uiGlow, -- 1237
			shadowX, -- 1238
			h * 0.42, -- 1239
			32, -- 1240
			90, -- 1241
			Color( -- 1242
				148, -- 1242
				168, -- 1242
				184, -- 1242
				math.floor(32 * footFade + 0.5) -- 1242
			), -- 1242
			Color(90, 110, 130, 0), -- 1243
			12 -- 1244
		) -- 1244
	end -- 1244
	if self.vignetteAlpha > 0.005 then -- 1249
		local a = math.floor(140 * self.vignetteAlpha + 0.5) -- 1250
		local edge = w * 0.08 -- 1251
		fillHGradRect( -- 1252
			uiDraw, -- 1252
			0, -- 1252
			0, -- 1252
			edge, -- 1252
			h, -- 1252
			Color(124, 38, 42, a), -- 1252
			Color(124, 38, 42, 0) -- 1252
		) -- 1252
		fillHGradRect( -- 1253
			uiDraw, -- 1253
			w - edge, -- 1253
			0, -- 1253
			edge, -- 1253
			h, -- 1253
			Color(124, 38, 42, 0), -- 1253
			Color(124, 38, 42, a) -- 1253
		) -- 1253
	end -- 1253
end -- 1213
function PrologueIntroPlugin.prototype.drawP04WorldAction(self, fgDraw, fgGlow, ctx) -- 1259
	local p = ctx.p -- 1264
	local cam = ctx.cam -- 1265
	local flash = self.p04FlashIntensity -- 1266
	local hintAlpha = self.p04PostHintAlpha -- 1267
	local zhou = p.childMode and p.partner or p.player -- 1269
	local xiao = p.childMode and p.player or p.partner -- 1270
	local zX = cam:sx(zhou.x) -- 1271
	local zY = cam:sy(zhou.y, zhou.depth) -- 1272
	local zH = cam:len(zhou.h) -- 1273
	local xX = cam:sx(xiao.x) -- 1274
	local xY = cam:sy(xiao.y, xiao.depth) -- 1275
	local xH = cam:len(xiao.h) -- 1276
	if flash > 0.01 then -- 1279
		fillGradQuad( -- 1281
			fgGlow, -- 1282
			cam.viewW, -- 1283
			cam.groundScreenY + cam:len(18), -- 1283
			Color( -- 1283
				238, -- 1283
				178, -- 1283
				108, -- 1283
				math.floor(96 * flash + 0.5) -- 1283
			), -- 1283
			cam.viewW, -- 1284
			cam.groundScreenY + cam:len(195), -- 1284
			Color( -- 1284
				224, -- 1284
				148, -- 1284
				82, -- 1284
				math.floor(72 * flash + 0.5) -- 1284
			), -- 1284
			zX - cam:len(140), -- 1285
			cam.groundScreenY + cam:len(140), -- 1285
			Color(200, 120, 62, 0), -- 1285
			zX - cam:len(140), -- 1286
			cam.groundScreenY, -- 1286
			Color(200, 120, 62, 0) -- 1286
		) -- 1286
		local wallBaseY = cam.groundScreenY + cam:len(14) -- 1290
		local shAlpha = math.floor(148 * flash + 0.5) -- 1291
		local shCol = Color(8, 10, 14, shAlpha) -- 1292
		fgDraw:drawPolygon( -- 1294
			{ -- 1294
				Vec2( -- 1295
					zX - cam:len(14), -- 1295
					wallBaseY -- 1295
				), -- 1295
				Vec2( -- 1296
					zX + cam:len(6), -- 1296
					wallBaseY -- 1296
				), -- 1296
				Vec2( -- 1297
					zX - cam:len(38), -- 1297
					wallBaseY + zH * 1.18 -- 1297
				), -- 1297
				Vec2( -- 1298
					zX - cam:len(64), -- 1298
					wallBaseY + zH * 1.12 -- 1298
				) -- 1298
			}, -- 1298
			shCol -- 1299
		) -- 1299
		fgDraw:drawPolygon( -- 1301
			{ -- 1301
				Vec2( -- 1302
					xX - cam:len(10), -- 1302
					wallBaseY -- 1302
				), -- 1302
				Vec2( -- 1303
					xX + cam:len(6), -- 1303
					wallBaseY -- 1303
				), -- 1303
				Vec2( -- 1304
					xX - cam:len(26), -- 1304
					wallBaseY + xH * 1.12 -- 1304
				), -- 1304
				Vec2( -- 1305
					xX - cam:len(44), -- 1305
					wallBaseY + xH * 1.06 -- 1305
				) -- 1305
			}, -- 1305
			shCol -- 1306
		) -- 1306
		local shieldK = smoothstep(0.1, 0.24, self.p04Elapsed) * (1 - smoothstep(0.5, 0.78, self.p04Elapsed)) -- 1309
		if shieldK > 0.02 then -- 1310
			local armX = zX + cam:len(10) -- 1311
			local armY = zY + zH * 0.66 -- 1312
			local cuffW = cam:len(13) -- 1313
			local cuffH = cam:len(7) -- 1314
			local sa = math.floor(235 * shieldK + 0.5) -- 1315
			fgDraw:drawPolygon( -- 1316
				{ -- 1316
					Vec2( -- 1317
						zX + cam:len(2), -- 1317
						armY - cuffH * 0.4 -- 1317
					), -- 1317
					Vec2(armX + cuffW, armY + cuffH * 0.9), -- 1318
					Vec2(armX + cuffW * 0.72, armY + cuffH * 1.75), -- 1319
					Vec2( -- 1320
						zX - cam:len(2), -- 1320
						armY + cuffH * 0.5 -- 1320
					) -- 1320
				}, -- 1320
				toColor(____exports.CUFF_SHARED_SPEC.indigoCloth, sa) -- 1321
			) -- 1321
			fgDraw:drawSegment( -- 1323
				Vec2(armX + cuffW * 0.45, armY + cuffH * 0.75), -- 1324
				Vec2(armX + cuffW * 0.82, armY + cuffH * 1.25), -- 1325
				1.3, -- 1326
				toColor( -- 1327
					____exports.CUFF_SHARED_SPEC.mendStitch, -- 1327
					math.floor(210 * shieldK + 0.5) -- 1327
				) -- 1327
			) -- 1327
			fillGradQuad( -- 1330
				fgDraw, -- 1331
				zX + cam:len(4), -- 1332
				zY + zH * 0.85, -- 1332
				Color( -- 1332
					10, -- 1332
					12, -- 1332
					18, -- 1332
					math.floor(92 * shieldK + 0.5) -- 1332
				), -- 1332
				zX + cam:len(4), -- 1333
				zY, -- 1333
				Color( -- 1333
					10, -- 1333
					12, -- 1333
					18, -- 1333
					math.floor(62 * shieldK + 0.5) -- 1333
				), -- 1333
				xX - cam:len(18), -- 1334
				xY, -- 1334
				Color(10, 12, 18, 0), -- 1334
				xX - cam:len(18), -- 1335
				xY + xH, -- 1335
				Color(10, 12, 18, 0) -- 1335
			) -- 1335
		end -- 1335
	end -- 1335
	if hintAlpha > 0.02 then -- 1341
		local baseWx = self.p04AnchorWorldX > 0 and self.p04AnchorWorldX or zhou.x -- 1342
		local hintBaseX = cam:sx(baseWx + 74) -- 1343
		local groundY = cam:sy(0, 0) -- 1344
		local boardY = groundY + cam:len(34) -- 1345
		local boardW = cam:len(62) -- 1346
		local sheenBoost = flash * 0.55 -- 1347
		local aNorm = clamp01(hintAlpha + sheenBoost) -- 1348
		fgDraw:drawRect( -- 1351
			Rect( -- 1352
				hintBaseX, -- 1352
				boardY, -- 1352
				boardW, -- 1352
				cam:len(12) -- 1352
			), -- 1352
			Color( -- 1353
				54, -- 1353
				42, -- 1353
				32, -- 1353
				math.floor(165 * aNorm + 0.5) -- 1353
			), -- 1353
			1, -- 1354
			Color( -- 1355
				126, -- 1355
				102, -- 1355
				76, -- 1355
				math.floor(150 * aNorm + 0.5) -- 1355
			) -- 1355
		) -- 1355
		fgDraw:drawSegment( -- 1357
			Vec2(hintBaseX + 2, boardY + 1), -- 1358
			Vec2(hintBaseX + boardW - 2, boardY + 1), -- 1359
			2, -- 1360
			Color( -- 1361
				214, -- 1361
				198, -- 1361
				168, -- 1361
				math.floor(215 * aNorm + 0.5) -- 1361
			) -- 1361
		) -- 1361
		local grooveX0 = hintBaseX - cam:len(18) -- 1365
		local grooveX1 = hintBaseX + boardW + cam:len(26) -- 1366
		fgDraw:drawRect( -- 1367
			Rect( -- 1368
				grooveX0, -- 1368
				groundY + 1, -- 1368
				grooveX1 - grooveX0, -- 1368
				cam:len(4) -- 1368
			), -- 1368
			Color( -- 1369
				22, -- 1369
				26, -- 1369
				32, -- 1369
				math.floor(170 * aNorm + 0.5) -- 1369
			) -- 1369
		) -- 1369
		fgDraw:drawSegment( -- 1371
			Vec2( -- 1372
				grooveX0 + 4, -- 1372
				groundY + cam:len(5) -- 1372
			), -- 1372
			Vec2( -- 1373
				grooveX1 - 4, -- 1373
				groundY + cam:len(5) -- 1373
			), -- 1373
			1.6, -- 1374
			Color( -- 1375
				196, -- 1375
				204, -- 1375
				210, -- 1375
				math.floor(195 * aNorm + 0.5) -- 1375
			) -- 1375
		) -- 1375
	end -- 1375
end -- 1259
return ____exports -- 1259
