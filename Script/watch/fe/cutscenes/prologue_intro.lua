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
	if edge1 <= edge0 then -- 114
		return x >= edge1 and 1 or 0 -- 116
	end -- 116
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 118
	return t * t * (3 - 2 * t) -- 119
end -- 114
local function asRecord(value) -- 122
	if value ~= nil and type(value) == "table" then -- 122
		return value -- 124
	end -- 124
	return nil -- 126
end -- 122
local function readNum(rec, key) -- 129
	if rec == nil then -- 129
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
	if self.fireLoopActive and self.lastAudio ~= nil then -- 183
		self.lastAudio:stopLoop("fe03_night_fire", 0) -- 185
	end -- 185
	if clearRehearsal then -- 185
		self.rehearsalActive = false -- 188
		self.rehearsalSequence = false -- 189
		if self.enteredContractRehearsal and self.boundContract ~= nil then -- 189
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
	if loaded == nil then -- 219
		return -- 221
	end -- 221
	local rawFe = loaded["watch.fe"] -- 223
	if rawFe ~= nil and type(rawFe) == "table" then -- 223
		local watchFe = rawFe -- 225
		if watchFe.prologue ~= self then -- 225
			watchFe.prologue = self -- 227
		end -- 227
		if self.boundContract == nil and watchFe.contract ~= nil and type(watchFe.contract) == "table" then -- 227
			self.boundContract = watchFe.contract -- 230
		end -- 230
	end -- 230
end -- 217
function PrologueIntroPlugin.prototype.startRehearsal(self, mode, escapeDuration, contract) -- 236
	self:clearTransientState(false) -- 237
	self.rehearsalActive = true -- 238
	self.rehearsalSequence = mode == "sequence" -- 239
	if contract ~= nil then -- 239
		self.boundContract = contract -- 241
	else -- 241
		self:syncRuntimeHook() -- 243
	end -- 243
	if self.boundContract ~= nil and not self.boundContract:isRehearsal() then -- 243
		self.boundContract:enterRehearsal("fe03-prologue") -- 246
		self.enteredContractRehearsal = true -- 247
	end -- 247
	self.escapeDuration = escapeDuration ~= nil and escapeDuration > 0.5 and escapeDuration or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 249
	if mode == "p01" or mode == "sequence" then -- 249
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 254
	elseif mode == "p02" then -- 254
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 256
	elseif mode == "p02_escape" then -- 256
		self:enterEscapeFromDoorway(false) -- 258
	elseif mode == "p04" then -- 258
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
	if stage == "p01_wake" then -- 273
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 275
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p01Duration, t) -- 276
		return -- 277
	end -- 277
	if stage == "p02_shadow" then -- 277
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 280
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02ShadowDuration, t) -- 281
		return -- 282
	end -- 282
	if stage == "p02_escape" then -- 282
		self:enterEscapeFromDoorway(false) -- 285
		local clamped = math.min(self.escapeDuration, t) -- 286
		self.stageElapsed = clamped -- 287
		self.escapeRemaining = math.max(0, self.escapeDuration - clamped) -- 288
		local u = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 289
		self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + u * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 290
		self.vignetteAlpha = clamp01(0.14 + u * 0.56) -- 292
		return -- 293
	end -- 293
	if stage == "p02_hidden" then -- 293
		self:enterHiddenCabinet() -- 296
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02HiddenLinger, t) -- 297
		local fadeK = clamp01(1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 298
		self.vignetteAlpha = self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut and 0 or self.hiddenStartVignette * fadeK -- 299
		return -- 302
	end -- 302
	if stage == "p04_flash" then -- 302
		self.stage = "idle" -- 305
		self:triggerP04(220, 0) -- 306
		self.p04Elapsed = math.min(____exports.PROLOGUE_TIMINGS.p04FlashDuration, t) -- 307
		self:recomputeP04Weights() -- 308
		return -- 309
	end -- 309
	self:clearTransientState(false) -- 311
end -- 270
function PrologueIntroPlugin.prototype.triggerCabinetEnter(self) -- 315
	if self.stage == "p02_escape" or self.stage == "p02_shadow" then -- 315
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
	if next ~= "p02_escape" and next ~= "p02_hidden" then -- 356
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
	if isRetry then -- 378
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
	if t < 0.08 then -- 406
		self.p04FlashIntensity = clamp01(t / 0.08) -- 408
	elseif t < 0.55 then -- 408
		local k = (t - 0.08) / 0.47 -- 410
		local flicker = 0.86 + 0.14 * math.sin(t * 46) -- 411
		self.p04FlashIntensity = clamp01((1 - k * k) * flicker) -- 412
	else -- 412
		self.p04FlashIntensity = 0 -- 414
	end -- 414
	if t >= 0.18 then -- 414
		local reveal = smoothstep(0.18, 0.42, t) -- 417
		local settle = t > 0.55 and 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) or 0.85 -- 418
		self.p04PostHintAlpha = math.max(self.p04PostHintAlpha, reveal * settle) -- 419
		if t > 0.55 then -- 419
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
	if self.lastRoomKey ~= "" and self.lastRoomKey ~= p.room.key then -- 433
		self:onBindPlay(p, ctx.view) -- 436
	end -- 436
	if ctx.paused or ctx.worldDt <= 0 then -- 436
		return -- 441
	end -- 441
	local dt = ctx.worldDt -- 444
	if not self.rehearsalActive then -- 444
		self:syncLiveBackendTriggers(ctx) -- 448
	end -- 448
	if self.stage == "p01_wake" then -- 448
		self:stepP01(ctx, dt) -- 453
	elseif self.stage == "p02_shadow" then -- 453
		self:stepP02Shadow(ctx, dt) -- 455
	elseif self.stage == "p02_escape" then -- 455
		self:stepP02Escape(ctx, dt) -- 457
	elseif self.stage == "p02_hidden" then -- 457
		self:stepP02Hidden(ctx, dt) -- 459
	end -- 459
	if self.p04Active then -- 459
		self:stepP04(ctx, dt) -- 464
	end -- 464
end -- 430
function PrologueIntroPlugin.prototype.syncLiveBackendTriggers(self, ctx) -- 468
	local p = ctx.p -- 469
	local pRec = asRecord(p) -- 470
	if p.room.key == "prologue" then -- 470
		local phase = p.phase -- 474
		if phase == "prologue-wake" and self.stage ~= "p01_wake" then -- 474
			self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 476
		elseif phase == "prologue-shadow" and self.stage ~= "p02_shadow" then -- 476
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 478
		elseif phase == "prologue-escape" and self.stage ~= "p02_escape" then -- 478
			local dur = readNum(pRec, "escapeDuration") or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 480
			self.escapeDuration = math.max(0.5, dur) -- 481
			self:enterEscapeFromDoorway(false) -- 482
		elseif phase == "prologue-hide" and self.stage ~= "p02_hidden" then -- 482
			self:enterHiddenCabinet() -- 484
		elseif (phase == "prologue-wait" or phase == "prologue-give") and (self.stage == "p02_escape" or self.stage == "p02_hidden") then -- 484
			self.stage = "idle" -- 489
			self.vignetteAlpha = 0 -- 490
			self.heartbeatHz = 0 -- 491
			self.heartbeatPulse = 0 -- 492
		end -- 492
	end -- 492
	local i = 0 -- 497
	do -- 497
		i = 0 -- 498
		while i < #ctx.events.rawEvents do -- 498
			local ename = ctx.events.rawEvents[i + 1].name -- 499
			if ename == "p04WallFlash" or ename == "wallPeekFlash" then -- 499
				if not self.p04TriggeredOnce then -- 499
					self:triggerP04(p.player.x, p.player.y) -- 502
				end -- 502
			end -- 502
			i = i + 1 -- 498
		end -- 498
	end -- 498
	if not self.p04TriggeredOnce and not p.childMode and p.player.alive and p.partner.alive then -- 498
		local inPrologueCourtyard = p.room.key == "prologue" and p.phase == "prologue-follow" and p.player.x >= p.ox + 470 and p.player.x <= p.ox + 635 -- 509
		local inStreetWallRoot = p.room.key == "street" and p.player.x >= p.ox + 115 and p.player.x <= p.ox + 265 and self:hasAliveEnemy(p) -- 512
		local inS1WellRoot = p.room.key == "s1-crossroad" and p.player.x >= p.ox + 185 and p.player.x <= p.ox + 320 -- 515
		if inPrologueCourtyard or inStreetWallRoot or inS1WellRoot then -- 515
			self:triggerP04(p.player.x, p.player.y) -- 518
		end -- 518
	end -- 518
end -- 468
function PrologueIntroPlugin.prototype.hasAliveEnemy(self, p) -- 523
	local i = 0 -- 524
	do -- 524
		i = 0 -- 525
		while i < #p.enemies do -- 525
			if p.enemies[i + 1].alive then -- 525
				return true -- 527
			end -- 527
			i = i + 1 -- 525
		end -- 525
	end -- 525
	return false -- 530
end -- 523
function PrologueIntroPlugin.prototype.stepP01(self, ctx, dt) -- 533
	self.stageElapsed = self.stageElapsed + dt -- 534
	local tick = ctx.p.ticks -- 535
	if not self.fireLoopActive then -- 535
		self.fireLoopActive = true -- 538
		ctx.audio:playLoop( -- 539
			"fe03_night_fire", -- 539
			"ambience", -- 539
			PROLOGUE_AUDIO.nightFire, -- 539
			0.34, -- 539
			tick -- 539
		) -- 539
	end -- 539
	if self.stageElapsed >= 0.12 then -- 539
		ctx.audio:playOnce( -- 542
			self:cueKey("p01_father_call"), -- 543
			"voice", -- 544
			PROLOGUE_AUDIO.fatherWake, -- 545
			0.92, -- 546
			"prologue:p01_call", -- 547
			tick -- 548
		) -- 548
	end -- 548
	if self.stageElapsed >= 1.9 then -- 548
		ctx.audio:playOnce( -- 552
			self:cueKey("p01_bed_press"), -- 553
			"sfx", -- 554
			PROLOGUE_AUDIO.bedCreak, -- 555
			0.68, -- 556
			"prologue:p01_bed_press", -- 557
			tick -- 558
		) -- 558
	end -- 558
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p01Duration then -- 558
		if self.rehearsalSequence then -- 558
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 564
		else -- 564
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p01Duration -- 566
			self.stage = "idle" -- 567
		end -- 567
	end -- 567
end -- 533
function PrologueIntroPlugin.prototype.stepP02Shadow(self, ctx, dt) -- 572
	self.stageElapsed = self.stageElapsed + dt -- 573
	local tick = ctx.p.ticks -- 574
	if self.stageElapsed >= 0.08 then -- 574
		ctx.audio:playOnce( -- 577
			self:cueKey("p02_door_commotion"), -- 578
			"ambience", -- 579
			PROLOGUE_AUDIO.doorCommotion, -- 580
			0.62, -- 581
			"prologue:p02_commotion", -- 582
			tick -- 583
		) -- 583
	end -- 583
	if self.stageElapsed >= 0.65 then -- 583
		ctx.audio:playOnce( -- 587
			self:cueKey("p02_shadow_strike"), -- 588
			"sfx", -- 589
			PROLOGUE_AUDIO.shadowStrike, -- 590
			0.85, -- 591
			"prologue:p02_shadow_cut", -- 592
			tick -- 593
		) -- 593
	end -- 593
	if self.stageElapsed >= 1.02 then -- 593
		ctx.audio:playOnce( -- 597
			self:cueKey("p02_bowl_roll"), -- 598
			"sfx", -- 599
			PROLOGUE_AUDIO.bowlRoll, -- 600
			0.76, -- 601
			"prologue:p02_bowl_roll", -- 602
			tick -- 603
		) -- 603
	end -- 603
	if self.stageElapsed >= 1.85 then -- 603
		ctx.audio:playOnce( -- 607
			self:cueKey("p02_bowl_hit"), -- 608
			"sfx", -- 609
			PROLOGUE_AUDIO.bowlHit, -- 610
			0.9, -- 611
			"prologue:p02_bowl_hit", -- 612
			tick -- 613
		) -- 613
	end -- 613
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02ShadowDuration then -- 613
		self:enterEscapeFromDoorway(false) -- 619
	end -- 619
end -- 572
function PrologueIntroPlugin.prototype.stepP02Escape(self, ctx, dt) -- 623
	self.stageElapsed = self.stageElapsed + dt -- 624
	local pRec = asRecord(ctx.p) -- 627
	local liveRemain = readNum(pRec, "escapeRemaining") -- 628
	if not self.rehearsalActive and liveRemain ~= nil then -- 628
		self.escapeRemaining = math.max(0, liveRemain) -- 630
	else -- 630
		self.escapeRemaining = math.max(0, self.escapeRemaining - dt) -- 632
	end -- 632
	if self.rehearsalActive then -- 632
		if ctx.input.moveX ~= 0 then -- 632
			self.escapePlayerX = clamp01(self.escapePlayerX + ctx.input.moveX * dt * 0.34) -- 638
		end -- 638
		if self.escapePlayerX >= 0.85 and ctx.input.interact.pressed or self.escapePlayerX >= 0.98 then -- 638
			self:enterHiddenCabinet() -- 641
			return -- 642
		end -- 642
	end -- 642
	if self.escapeRemaining <= 0 then -- 642
		self:retryEscape() -- 648
		return -- 649
	end -- 649
	local urgency = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 652
	self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + urgency * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 653
	local prevCycle = math.floor(self.heartbeatPhase) -- 656
	self.heartbeatPhase = self.heartbeatPhase + dt * self.heartbeatHz -- 657
	local currCycle = math.floor(self.heartbeatPhase) -- 658
	if currCycle > prevCycle then -- 658
		self.heartbeatBeatCount = self.heartbeatBeatCount + 1 -- 660
		self.heartbeatPulse = 1 -- 661
		ctx.audio:playOnce( -- 662
			self:cueKey("p02_hb_" .. tostring(self.heartbeatBeatCount)), -- 663
			"sfx", -- 664
			PROLOGUE_AUDIO.heartbeat, -- 665
			0.44 + 0.48 * urgency, -- 666
			"prologue:p02_heartbeat:" .. tostring(self.heartbeatBeatCount), -- 667
			ctx.p.ticks -- 668
		) -- 668
	else -- 668
		local frac = self.heartbeatPhase - currCycle -- 672
		if frac >= 0.2 and frac <= 0.28 then -- 672
			self.heartbeatPulse = math.max(self.heartbeatPulse, 0.56) -- 674
		end -- 674
		self.heartbeatPulse = math.max(0, self.heartbeatPulse - dt * 3.8) -- 676
	end -- 676
	self.vignetteAlpha = clamp01(0.14 + urgency * 0.54 + self.heartbeatPulse * 0.16) -- 680
end -- 623
function PrologueIntroPlugin.prototype.stepP02Hidden(self, ctx, dt) -- 683
	self.stageElapsed = self.stageElapsed + dt -- 684
	local tick = ctx.p.ticks -- 685
	ctx.audio:playOnce( -- 687
		self:cueKey("p02_cabinet_shut"), -- 688
		"sfx", -- 689
		PROLOGUE_AUDIO.cabinetShut, -- 690
		0.78, -- 691
		"prologue:p02_cabinet_shut", -- 692
		tick -- 693
	) -- 693
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut then -- 693
		self.vignetteAlpha = 0 -- 698
	else -- 698
		self.vignetteAlpha = self.hiddenStartVignette * (1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 700
	end -- 700
	self.heartbeatHz = 0 -- 703
	self.heartbeatPulse = 0 -- 704
	if self.stageElapsed >= 0.3 then -- 704
		ctx.audio:playOnce( -- 708
			self:cueKey("p02_footsteps_fade"), -- 709
			"sfx", -- 710
			PROLOGUE_AUDIO.footstepsFade, -- 711
			0.65, -- 712
			"prologue:p02_footsteps_fade", -- 713
			tick -- 714
		) -- 714
	end -- 714
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenLinger then -- 714
		self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 719
		self.vignetteAlpha = 0 -- 720
		if not self.rehearsalActive then -- 720
			self.stage = "idle" -- 722
		end -- 722
	end -- 722
end -- 683
function PrologueIntroPlugin.prototype.stepP04(self, ctx, dt) -- 727
	if self.p04Elapsed == 0 then -- 727
		ctx.audio:playOnce( -- 729
			self:cueKey("p04_gunflash"), -- 730
			"sfx", -- 731
			PROLOGUE_AUDIO.distantGunflash, -- 732
			0.78, -- 733
			"prologue:p04_gunflash", -- 734
			ctx.p.ticks -- 735
		) -- 735
	end -- 735
	self.p04Elapsed = self.p04Elapsed + dt -- 738
	self:recomputeP04Weights() -- 739
	if self.p04Elapsed >= ____exports.PROLOGUE_TIMINGS.p04FlashDuration then -- 739
		self.p04Elapsed = ____exports.PROLOGUE_TIMINGS.p04FlashDuration -- 741
		self.p04FlashIntensity = 0 -- 742
		self.p04Active = false -- 743
		self.p04PostHintAlpha = 0.42 -- 745
	end -- 745
end -- 727
function PrologueIntroPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 750
	if not self.p04Active and self.p04PostHintAlpha <= 0.01 then -- 750
		return -- 757
	end -- 757
	self:drawP04WorldAction(fgDraw, fgGlow, ctx) -- 759
end -- 750
function PrologueIntroPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 763
	if self.stage == "p01_wake" then -- 763
		self:drawP01Wake( -- 771
			uiDraw, -- 771
			uiInkDraw, -- 771
			uiArt, -- 771
			uiGlow, -- 771
			ctx -- 771
		) -- 771
		return true -- 772
	end -- 772
	if self.stage == "p02_shadow" then -- 772
		self:drawP02ShadowAndBowl(uiDraw, uiInkDraw, uiGlow, ctx) -- 775
		return true -- 776
	end -- 776
	if self.stage == "p02_escape" then -- 776
		self:drawP02EscapeVignette(uiDraw, uiInkDraw, uiGlow, ctx) -- 779
		return self.rehearsalActive -- 781
	end -- 781
	if self.stage == "p02_hidden" then -- 781
		self:drawP02HiddenCabinet(uiDraw, uiInkDraw, uiGlow, ctx) -- 784
		return true -- 785
	end -- 785
	return false -- 787
end -- 763
function PrologueIntroPlugin.prototype.drawP01Wake(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 792
	local w = ctx.uiW -- 799
	local h = ctx.uiH -- 800
	local t = self.stageElapsed -- 801
	uiDraw:drawRect( -- 804
		Rect(0, 0, w, h), -- 804
		Color(6, 7, 11, 255) -- 804
	) -- 804
	local wakeOpen = smoothstep(0.75, 2.1, t) -- 807
	local blinkDip = t >= 1.25 and t <= 1.62 and math.sin((t - 1.25) / 0.37 * math.pi) * 0.24 or 0 -- 808
	local eyeOpen = clamp01(wakeOpen - blinkDip) -- 809
	local sitPan = smoothstep(2.65, 3.85, t) -- 810
	local handPress = smoothstep(1.75, 2.35, t) * (1 - smoothstep(3.15, 3.85, t) * 0.65) -- 811
	local fadeOut = 1 - smoothstep(3.72, 4, t) -- 812
	if eyeOpen > 0.01 then -- 812
		local panX = -sitPan * w * 0.16 -- 815
		local sitLiftY = sitPan * h * 0.06 -- 816
		local fireFlicker = 0.84 + 0.16 * math.sin(t * 9.5) * math.cos(t * 5.2) -- 817
		fillVGradRect( -- 820
			uiDraw, -- 821
			0, -- 822
			0, -- 823
			w, -- 824
			h, -- 825
			Color( -- 826
				16, -- 826
				14, -- 826
				18, -- 826
				math.floor(255 * eyeOpen * fadeOut + 0.5) -- 826
			), -- 826
			Color( -- 827
				34, -- 827
				24, -- 827
				24, -- 827
				math.floor(255 * eyeOpen * fadeOut + 0.5) -- 827
			) -- 827
		) -- 827
		fillRadialGlow( -- 830
			uiGlow, -- 831
			w * 0.34 + panX * 0.4, -- 832
			h * 0.62 - sitLiftY, -- 833
			w * 0.42, -- 834
			h * 0.36, -- 835
			Color( -- 836
				186, -- 836
				108, -- 836
				56, -- 836
				math.floor(68 * fireFlicker * eyeOpen * fadeOut + 0.5) -- 836
			), -- 836
			Color(120, 52, 28, 0), -- 837
			18 -- 838
		) -- 838
		local fold = 0 -- 841
		do -- 841
			fold = 0 -- 842
			while fold < 11 do -- 842
				local fx = w * (0.04 + fold * 0.095) + panX * 0.55 + math.sin(t * 1.4 + fold) * 4 -- 843
				local fw = 22 + fold % 3 * 10 -- 844
				local col = fold & 1 == 0 and Color( -- 845
					52, -- 846
					42, -- 846
					36, -- 846
					math.floor(64 * eyeOpen * fadeOut + 0.5) -- 846
				) or Color( -- 846
					24, -- 847
					20, -- 847
					22, -- 847
					math.floor(78 * eyeOpen * fadeOut + 0.5) -- 847
				) -- 847
				fillHGradRect( -- 848
					uiDraw, -- 848
					fx, -- 848
					h * 0.24, -- 848
					fw, -- 848
					h * 0.72, -- 848
					Color(col.r, col.g, col.b, 0), -- 848
					col -- 848
				) -- 848
				fold = fold + 1 -- 842
			end -- 842
		end -- 842
		local doorVis = smoothstep(2.25, 3.2, t) -- 852
		if doorVis > 0.01 then -- 852
			local doorX = w * 0.84 + panX * 0.95 -- 854
			local crackW = 14 + sitPan * 18 -- 855
			local doorBot = h * 0.14 - sitLiftY * 0.4 -- 856
			local doorH = h * 0.72 -- 857
			uiDraw:drawRect( -- 859
				Rect(doorX - 46, doorBot, 46, doorH), -- 859
				Color( -- 859
					14, -- 859
					12, -- 859
					14, -- 859
					math.floor(235 * doorVis * fadeOut + 0.5) -- 859
				) -- 859
			) -- 859
			uiDraw:drawRect( -- 860
				Rect(doorX + crackW, doorBot, 54, doorH), -- 860
				Color( -- 860
					14, -- 860
					12, -- 860
					14, -- 860
					math.floor(235 * doorVis * fadeOut + 0.5) -- 860
				) -- 860
			) -- 860
			fillVGradRect( -- 862
				uiDraw, -- 863
				doorX, -- 864
				doorBot, -- 865
				crackW, -- 866
				doorH, -- 867
				Color( -- 868
					142, -- 868
					168, -- 868
					186, -- 868
					math.floor(170 * doorVis * fadeOut + 0.5) -- 868
				), -- 868
				Color( -- 869
					214, -- 869
					168, -- 869
					118, -- 869
					math.floor(195 * doorVis * fireFlicker * fadeOut + 0.5) -- 869
				) -- 869
			) -- 869
			fillGradQuad( -- 871
				uiGlow, -- 872
				doorX, -- 873
				doorBot, -- 873
				Color( -- 873
					164, -- 873
					188, -- 873
					204, -- 873
					math.floor(64 * doorVis * fadeOut + 0.5) -- 873
				), -- 873
				doorX + crackW, -- 874
				doorBot, -- 874
				Color( -- 874
					214, -- 874
					164, -- 874
					108, -- 874
					math.floor(54 * doorVis * fadeOut + 0.5) -- 874
				), -- 874
				doorX - 135, -- 875
				doorBot - 40, -- 875
				Color(120, 148, 170, 0), -- 875
				doorX - 190, -- 876
				doorBot + doorH * 0.48, -- 876
				Color(180, 130, 82, 0) -- 876
			) -- 876
		end -- 876
		local bedTopY = h * 0.27 - sitLiftY -- 881
		local dipX = w * 0.52 + panX * 0.7 -- 882
		local pressDepth = 22 * handPress -- 883
		uiDraw:drawPolygon( -- 885
			{ -- 885
				Vec2(0, 0), -- 886
				Vec2(w, 0), -- 887
				Vec2(w, bedTopY + 10), -- 888
				Vec2(dipX + 110, bedTopY + 6), -- 889
				Vec2(dipX + 38, bedTopY - pressDepth * 0.85), -- 890
				Vec2(dipX - 34, bedTopY - pressDepth), -- 891
				Vec2(dipX - 108, bedTopY + 5), -- 892
				Vec2(0, bedTopY + 12) -- 893
			}, -- 893
			Color( -- 894
				30, -- 894
				27, -- 894
				32, -- 894
				math.floor(248 * eyeOpen * fadeOut + 0.5) -- 894
			) -- 894
		) -- 894
		uiInkDraw:drawSegment( -- 897
			Vec2(dipX - 96, bedTopY + 4), -- 898
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 899
			1.6, -- 900
			Color( -- 901
				124, -- 901
				114, -- 901
				102, -- 901
				math.floor(145 * eyeOpen * fadeOut + 0.5) -- 901
			) -- 901
		) -- 901
		uiInkDraw:drawSegment( -- 903
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 904
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 905
			1.4, -- 906
			Color( -- 907
				92, -- 907
				82, -- 907
				74, -- 907
				math.floor(165 * eyeOpen * fadeOut + 0.5) -- 907
			) -- 907
		) -- 907
		uiInkDraw:drawSegment( -- 909
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 910
			Vec2(dipX + 106, bedTopY + 5), -- 911
			1.5, -- 912
			Color( -- 913
				138, -- 913
				122, -- 913
				106, -- 913
				math.floor(140 * eyeOpen * fadeOut + 0.5) -- 913
			) -- 913
		) -- 913
		if handPress > 0.02 then -- 913
			local hx = dipX -- 918
			local hy = bedTopY - pressDepth + 14 -- 919
			local ha = math.floor(245 * handPress * fadeOut + 0.5) -- 920
			uiDraw:drawPolygon( -- 922
				{ -- 922
					Vec2(hx - 62, hy + 135), -- 923
					Vec2(hx - 14, hy + 142), -- 924
					Vec2(hx + 8, hy + 28), -- 925
					Vec2(hx - 36, hy + 24) -- 926
				}, -- 926
				Color(42, 46, 54, ha) -- 927
			) -- 927
			uiDraw:drawPolygon( -- 929
				{ -- 929
					Vec2(hx - 38, hy + 26), -- 930
					Vec2(hx + 16, hy + 28), -- 931
					Vec2(hx + 34, hy + 2), -- 932
					Vec2(hx + 22, hy - 14), -- 933
					Vec2(hx - 26, hy - 12), -- 934
					Vec2(hx - 42, hy + 4) -- 935
				}, -- 935
				Color(148, 112, 86, ha) -- 936
			) -- 936
			local f = 0 -- 938
			do -- 938
				f = 0 -- 939
				while f < 3 do -- 939
					local fx = hx - 16 + f * 15 -- 940
					uiInkDraw:drawSegment( -- 941
						Vec2(fx, hy + 10), -- 941
						Vec2(fx + 2, hy - 11), -- 941
						1.4, -- 941
						Color(68, 46, 36, ha) -- 941
					) -- 941
					f = f + 1 -- 939
				end -- 939
			end -- 939
			uiInkDraw:drawSegment( -- 943
				Vec2(hx - 34, hy + 22), -- 944
				Vec2(hx + 24, hy + 12), -- 945
				1.8, -- 946
				Color( -- 947
					214, -- 947
					168, -- 947
					126, -- 947
					math.floor(175 * handPress * fireFlicker * fadeOut + 0.5) -- 947
				) -- 947
			) -- 947
		end -- 947
	end -- 947
	local lidH = h * 0.52 * (1 - eyeOpen) -- 953
	if lidH > 1 then -- 953
		uiDraw:drawRect( -- 955
			Rect(0, h - lidH, w, lidH), -- 955
			Color(5, 6, 9, 255) -- 955
		) -- 955
		uiDraw:drawRect( -- 956
			Rect(0, 0, w, lidH), -- 956
			Color(5, 6, 9, 255) -- 956
		) -- 956
		local feather = math.min(46, h * 0.08) -- 957
		fillVGradRect( -- 958
			uiDraw, -- 958
			0, -- 958
			h - lidH - feather, -- 958
			w, -- 958
			feather, -- 958
			Color(5, 6, 9, 0), -- 958
			Color(5, 6, 9, 235) -- 958
		) -- 958
		fillVGradRect( -- 959
			uiDraw, -- 959
			0, -- 959
			lidH, -- 959
			w, -- 959
			feather, -- 959
			Color(5, 6, 9, 235), -- 959
			Color(5, 6, 9, 0) -- 959
		) -- 959
	end -- 959
	local callAlpha = smoothstep(0.1, 0.32, t) * (1 - smoothstep(1.05, 1.55, t)) -- 963
	if callAlpha > 0.02 then -- 963
		drawSilkVeil( -- 965
			uiDraw, -- 965
			uiArt, -- 965
			"p01_call_veil", -- 965
			w * 0.5, -- 965
			h * 0.14, -- 965
			240, -- 965
			44, -- 965
			PALETTE.inkWash, -- 965
			0.72 * callAlpha, -- 965
			0 -- 965
		) -- 965
		ctx.texts:put( -- 966
			"sm", -- 967
			"「小满。」", -- 968
			w * 0.5, -- 969
			h * 0.14, -- 970
			toColor(PALETTE.textBright), -- 971
			0.5, -- 972
			0.5, -- 973
			"Center", -- 974
			2, -- 975
			callAlpha, -- 976
			0.08 -- 977
		) -- 977
	end -- 977
end -- 792
function PrologueIntroPlugin.prototype.drawP02ShadowAndBowl(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 984
	local w = ctx.uiW -- 990
	local h = ctx.uiH -- 991
	local t = self.stageElapsed -- 992
	local fireFlicker = 0.85 + 0.15 * math.sin(t * 14) -- 993
	local floorY = h * 0.25 -- 996
	fillVGradRect( -- 997
		uiDraw, -- 997
		0, -- 997
		floorY, -- 997
		w, -- 997
		h - floorY, -- 997
		Color(38, 30, 28, 255), -- 997
		Color(20, 18, 24, 255) -- 997
	) -- 997
	fillVGradRect( -- 998
		uiDraw, -- 998
		0, -- 998
		0, -- 998
		w, -- 998
		floorY, -- 998
		Color(12, 12, 16, 255), -- 998
		Color(28, 24, 24, 255) -- 998
	) -- 998
	local row = 1 -- 1001
	do -- 1001
		row = 1 -- 1002
		while row <= 6 do -- 1002
			local ry = floorY + (h - floorY) * (row / 7) -- 1003
			uiInkDraw:drawSegment( -- 1004
				Vec2(0, ry), -- 1004
				Vec2(w, ry), -- 1004
				0.9, -- 1004
				Color(18, 16, 20, 110) -- 1004
			) -- 1004
			row = row + 1 -- 1002
		end -- 1002
	end -- 1002
	fillRadialGlow( -- 1008
		uiGlow, -- 1009
		w * 0.12, -- 1010
		floorY + h * 0.28, -- 1011
		w * 0.52, -- 1012
		h * 0.44, -- 1013
		Color( -- 1014
			198, -- 1014
			116, -- 1014
			56, -- 1014
			math.floor(78 * fireFlicker + 0.5) -- 1014
		), -- 1014
		Color(120, 50, 24, 0), -- 1015
		18 -- 1016
	) -- 1016
	local cutProg = smoothstep(0.62, 1.05, t) -- 1020
	local tremble = math.sin(t * 18) * 3 -- 1021
	local p1X = w * 0.42 + tremble -- 1022
	local p2X = w * 0.56 - tremble * 0.6 -- 1023
	local parentDrop = cutProg * 36 -- 1024
	uiDraw:drawPolygon( -- 1026
		{ -- 1026
			Vec2(p1X - 42, floorY), -- 1027
			Vec2(p1X + 34, floorY), -- 1028
			Vec2(p1X + 26 + cutProg * 26, floorY + 218 - parentDrop), -- 1029
			Vec2(p1X - 28 + cutProg * 14, floorY + 226 - parentDrop) -- 1030
		}, -- 1030
		Color(10, 9, 13, 215) -- 1031
	) -- 1031
	uiDraw:drawCircle( -- 1032
		Vec2(p1X + cutProg * 20, floorY + 248 - parentDrop), -- 1032
		24, -- 1032
		Color(10, 9, 13, 215) -- 1032
	) -- 1032
	uiDraw:drawPolygon( -- 1034
		{ -- 1034
			Vec2(p2X - 36, floorY), -- 1035
			Vec2(p2X + 32, floorY), -- 1036
			Vec2(p2X + 20 + cutProg * 32, floorY + 186 - parentDrop * 0.8), -- 1037
			Vec2(p2X - 24 + cutProg * 18, floorY + 194 - parentDrop * 0.8) -- 1038
		}, -- 1038
		Color(11, 10, 14, 205) -- 1039
	) -- 1039
	uiDraw:drawCircle( -- 1040
		Vec2(p2X - 2 + cutProg * 26, floorY + 214 - parentDrop * 0.8), -- 1040
		21, -- 1040
		Color(11, 10, 14, 205) -- 1040
	) -- 1040
	if cutProg > 0.01 then -- 1040
		local sx = w * (0.02 + cutProg * 0.46) -- 1044
		uiDraw:drawPolygon( -- 1045
			{ -- 1045
				Vec2(0, floorY), -- 1046
				Vec2(sx + 58, floorY), -- 1047
				Vec2(sx + 135, h), -- 1048
				Vec2(0, h) -- 1049
			}, -- 1049
			Color( -- 1050
				6, -- 1050
				6, -- 1050
				10, -- 1050
				math.floor(238 * cutProg + 0.5) -- 1050
			) -- 1050
		) -- 1050
		uiDraw:drawPolygon( -- 1052
			{ -- 1052
				Vec2(sx + 20, floorY + 160), -- 1053
				Vec2(sx + 275 * cutProg, floorY + 260), -- 1054
				Vec2(sx + 268 * cutProg, floorY + 276), -- 1055
				Vec2(sx + 14, floorY + 178) -- 1056
			}, -- 1056
			Color( -- 1057
				5, -- 1057
				5, -- 1057
				8, -- 1057
				math.floor(235 * cutProg + 0.5) -- 1057
			) -- 1057
		) -- 1057
	end -- 1057
	local threshX = w * 0.66 -- 1061
	uiDraw:drawRect( -- 1062
		Rect(threshX, floorY - 22, 26, 30), -- 1062
		Color(54, 38, 28, 255), -- 1062
		1.2, -- 1062
		Color(112, 86, 62, 210) -- 1062
	) -- 1062
	uiInkDraw:drawSegment( -- 1063
		Vec2(threshX, floorY + 8), -- 1063
		Vec2(threshX + 26, floorY + 8), -- 1063
		1.6, -- 1063
		Color(156, 128, 96, 200) -- 1063
	) -- 1063
	local rollK = smoothstep(0.98, 1.85, t) -- 1066
	if t >= 0.96 then -- 1066
		local startX = w * 0.14 -- 1068
		local stopX = threshX - 18 -- 1069
		local bx = startX + (stopX - startX) * rollK -- 1070
		local bounce = rollK < 1 and math.abs(math.sin(rollK * math.pi * 3.5)) * (1 - rollK) * 18 or 0 -- 1071
		local by = floorY + 8 + bounce -- 1072
		local tilt = rollK * math.pi * 3.2 -- 1073
		local br = 16 -- 1074
		uiDraw:drawEllipse( -- 1077
			Vec2(bx, floorY + 2), -- 1077
			18, -- 1077
			4.5, -- 1077
			Color(6, 6, 10, 175) -- 1077
		) -- 1077
		uiDraw:drawCircle( -- 1079
			Vec2(bx, by), -- 1079
			br, -- 1079
			Color(168, 164, 152, 245) -- 1079
		) -- 1079
		uiDraw:drawEllipse( -- 1080
			Vec2( -- 1081
				bx + math.cos(tilt) * 4, -- 1081
				by + math.sin(tilt) * 4 -- 1081
			), -- 1081
			br * 0.72, -- 1082
			br * 0.36, -- 1083
			Color(64, 60, 56, 235) -- 1084
		) -- 1084
		uiInkDraw:drawArc( -- 1087
			Vec2(bx, by), -- 1087
			br - 1, -- 1087
			20, -- 1087
			155, -- 1087
			1.5, -- 1087
			Color(224, 222, 214, 215) -- 1087
		) -- 1087
		if t >= 1.84 then -- 1087
			local impact = 1 - smoothstep(1.84, 2, t) -- 1089
			if impact > 0.02 then -- 1089
				uiInkDraw:drawSegment( -- 1091
					Vec2(threshX - 2, floorY + 8), -- 1092
					Vec2(threshX - 14 - (1 - impact) * 12, floorY + 18 + (1 - impact) * 8), -- 1093
					1.4, -- 1094
					Color( -- 1095
						220, -- 1095
						210, -- 1095
						194, -- 1095
						math.floor(210 * impact + 0.5) -- 1095
					) -- 1095
				) -- 1095
			end -- 1095
		end -- 1095
	end -- 1095
	local wobble = math.sin(t * 11) * 5 -- 1102
	uiDraw:drawRect( -- 1103
		Rect(w - 72 + wobble * 0.3, floorY, 64, 142), -- 1103
		Color(42, 30, 24, 250), -- 1103
		1.1, -- 1103
		Color(94, 72, 54, 180) -- 1103
	) -- 1103
	uiInkDraw:drawSegment( -- 1104
		Vec2(w - 70 + wobble, floorY + 6), -- 1104
		Vec2(w - 70 + wobble, floorY + 136), -- 1104
		2, -- 1104
		Color(146, 118, 88, 185) -- 1104
	) -- 1104
	uiDraw:drawRect( -- 1107
		Rect(0, h - 46, w, 46), -- 1107
		Color(6, 8, 12, 244) -- 1107
	) -- 1107
	uiDraw:drawRect( -- 1108
		Rect(0, 0, w, 46), -- 1108
		Color(6, 8, 12, 244) -- 1108
	) -- 1108
end -- 984
function PrologueIntroPlugin.prototype.drawP02EscapeVignette(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1113
	local w = ctx.uiW -- 1119
	local h = ctx.uiH -- 1120
	local a = clamp01(self.vignetteAlpha) -- 1121
	if a > 0.005 then -- 1121
		local edgeX = w * (0.09 + 0.06 * a) -- 1124
		local edgeY = h * (0.11 + 0.07 * a) -- 1125
		local peakA = math.floor(168 * a + 0.5) -- 1126
		local deep = PALETTE.crimsonDeep -- 1127
		local rouge = PALETTE.rouge -- 1128
		local cEdge = Color(deep.r, deep.g, deep.b, peakA) -- 1129
		local cZero = Color(deep.r, deep.g, deep.b, 0) -- 1130
		fillHGradRect( -- 1132
			uiDraw, -- 1132
			0, -- 1132
			0, -- 1132
			edgeX, -- 1132
			h, -- 1132
			cEdge, -- 1132
			cZero -- 1132
		) -- 1132
		fillHGradRect( -- 1133
			uiDraw, -- 1133
			w - edgeX, -- 1133
			0, -- 1133
			edgeX, -- 1133
			h, -- 1133
			cZero, -- 1133
			cEdge -- 1133
		) -- 1133
		fillVGradRect( -- 1134
			uiDraw, -- 1134
			0, -- 1134
			0, -- 1134
			w, -- 1134
			edgeY, -- 1134
			cEdge, -- 1134
			cZero -- 1134
		) -- 1134
		fillVGradRect( -- 1135
			uiDraw, -- 1135
			0, -- 1135
			h - edgeY, -- 1135
			w, -- 1135
			edgeY, -- 1135
			cZero, -- 1135
			cEdge -- 1135
		) -- 1135
		if self.heartbeatPulse > 0.02 then -- 1135
			local pa = math.floor(62 * self.heartbeatPulse * a + 0.5) -- 1139
			local cPulse = Color(rouge.r, rouge.g, rouge.b, pa) -- 1140
			local cPulseZero = Color(rouge.r, rouge.g, rouge.b, 0) -- 1141
			fillHGradRect( -- 1142
				uiGlow, -- 1142
				0, -- 1142
				0, -- 1142
				edgeX * 0.72, -- 1142
				h, -- 1142
				cPulse, -- 1142
				cPulseZero -- 1142
			) -- 1142
			fillHGradRect( -- 1143
				uiGlow, -- 1143
				w - edgeX * 0.72, -- 1143
				0, -- 1143
				edgeX * 0.72, -- 1143
				h, -- 1143
				cPulseZero, -- 1143
				cPulse -- 1143
			) -- 1143
		end -- 1143
	end -- 1143
	if self.rehearsalActive then -- 1143
		local groundY = h * 0.24 -- 1149
		local doorX = w * 0.14 -- 1150
		local cabX = w * 0.8 -- 1151
		local childX = doorX + (cabX - doorX) * self.escapePlayerX -- 1152
		local wobble = math.sin(self.stageElapsed * 9.5) * 4 -- 1153
		uiInkDraw:drawRect( -- 1156
			Rect(doorX - 18, groundY, 16, 130), -- 1156
			Color(48, 36, 28, 220) -- 1156
		) -- 1156
		uiDraw:drawCircle( -- 1157
			Vec2(doorX + 18, groundY + 8), -- 1157
			8, -- 1157
			Color(168, 164, 152, 220) -- 1157
		) -- 1157
		uiDraw:drawRect( -- 1159
			Rect(cabX, groundY, 74, 108), -- 1159
			Color(42, 31, 24, 240), -- 1159
			1.2, -- 1159
			Color(118, 92, 68, 195) -- 1159
		) -- 1159
		uiInkDraw:drawSegment( -- 1160
			Vec2(cabX + 8 + wobble * 0.5, groundY + 6), -- 1160
			Vec2(cabX + 8 + wobble * 0.5, groundY + 100), -- 1160
			2.2, -- 1160
			Color(176, 144, 106, 210) -- 1160
		) -- 1160
		if not ctx.uiArt:tryPlaceRun( -- 1160
			"child", -- 1162
			"p02_escape_child", -- 1162
			childX, -- 1162
			groundY, -- 1162
			46, -- 1162
			74, -- 1162
			self.stageElapsed * 1.8, -- 1162
			{facing = 1, layer = 3} -- 1162
		) then -- 1162
			uiDraw:drawRect( -- 1166
				Rect(childX - 12, groundY, 24, 54), -- 1166
				Color(168, 72, 54, 235) -- 1166
			) -- 1166
		end -- 1166
	end -- 1166
end -- 1113
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