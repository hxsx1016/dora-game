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
			local ev = ctx.events.rawEvents[i + 1] -- 499
			local ename = ev.name -- 500
			if ename == "prologueBeat" and ev.data.beat == "escapeRetry" and self.stage == "p02_escape" then -- 500
				self:retryEscape() -- 502
			elseif ename == "p04WallFlash" or ename == "wallPeekFlash" then -- 502
				if not self.p04TriggeredOnce then -- 502
					self:triggerP04(p.player.x, p.player.y) -- 505
				end -- 505
			end -- 505
			i = i + 1 -- 498
		end -- 498
	end -- 498
	if not self.p04TriggeredOnce and not p.childMode and p.player.alive and p.partner.alive then -- 498
		local inPrologueCourtyard = p.room.key == "prologue" and p.phase == "prologue-follow" and p.player.x >= p.ox + 470 and p.player.x <= p.ox + 635 -- 512
		local inStreetWallRoot = p.room.key == "street" and p.player.x >= p.ox + 115 and p.player.x <= p.ox + 265 and self:hasAliveEnemy(p) -- 515
		local inS1WellRoot = p.room.key == "s1-crossroad" and p.player.x >= p.ox + 185 and p.player.x <= p.ox + 320 -- 518
		if inPrologueCourtyard or inStreetWallRoot or inS1WellRoot then -- 518
			self:triggerP04(p.player.x, p.player.y) -- 521
		end -- 521
	end -- 521
end -- 468
function PrologueIntroPlugin.prototype.hasAliveEnemy(self, p) -- 526
	local i = 0 -- 527
	do -- 527
		i = 0 -- 528
		while i < #p.enemies do -- 528
			if p.enemies[i + 1].alive then -- 528
				return true -- 530
			end -- 530
			i = i + 1 -- 528
		end -- 528
	end -- 528
	return false -- 533
end -- 526
function PrologueIntroPlugin.prototype.stepP01(self, ctx, dt) -- 536
	self.stageElapsed = self.stageElapsed + dt -- 537
	local tick = ctx.p.ticks -- 538
	if not self.fireLoopActive then -- 538
		self.fireLoopActive = true -- 541
		ctx.audio:playLoop( -- 542
			"fe03_night_fire", -- 542
			"ambience", -- 542
			PROLOGUE_AUDIO.nightFire, -- 542
			0.34, -- 542
			tick -- 542
		) -- 542
	end -- 542
	if self.stageElapsed >= 0.12 then -- 542
		ctx.audio:playOnce( -- 545
			self:cueKey("p01_father_call"), -- 546
			"voice", -- 547
			PROLOGUE_AUDIO.fatherWake, -- 548
			0.92, -- 549
			"prologue:p01_call", -- 550
			tick -- 551
		) -- 551
	end -- 551
	if self.stageElapsed >= 1.9 then -- 551
		ctx.audio:playOnce( -- 555
			self:cueKey("p01_bed_press"), -- 556
			"sfx", -- 557
			PROLOGUE_AUDIO.bedCreak, -- 558
			0.68, -- 559
			"prologue:p01_bed_press", -- 560
			tick -- 561
		) -- 561
	end -- 561
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p01Duration then -- 561
		if self.rehearsalSequence then -- 561
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 567
		else -- 567
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p01Duration -- 569
			self.stage = "idle" -- 570
		end -- 570
	end -- 570
end -- 536
function PrologueIntroPlugin.prototype.stepP02Shadow(self, ctx, dt) -- 575
	self.stageElapsed = self.stageElapsed + dt -- 576
	local tick = ctx.p.ticks -- 577
	if self.stageElapsed >= 0.08 then -- 577
		ctx.audio:playOnce( -- 580
			self:cueKey("p02_door_commotion"), -- 581
			"ambience", -- 582
			PROLOGUE_AUDIO.doorCommotion, -- 583
			0.62, -- 584
			"prologue:p02_commotion", -- 585
			tick -- 586
		) -- 586
	end -- 586
	if self.stageElapsed >= 0.65 then -- 586
		ctx.audio:playOnce( -- 590
			self:cueKey("p02_shadow_strike"), -- 591
			"sfx", -- 592
			PROLOGUE_AUDIO.shadowStrike, -- 593
			0.85, -- 594
			"prologue:p02_shadow_cut", -- 595
			tick -- 596
		) -- 596
	end -- 596
	if self.stageElapsed >= 1.02 then -- 596
		ctx.audio:playOnce( -- 600
			self:cueKey("p02_bowl_roll"), -- 601
			"sfx", -- 602
			PROLOGUE_AUDIO.bowlRoll, -- 603
			0.76, -- 604
			"prologue:p02_bowl_roll", -- 605
			tick -- 606
		) -- 606
	end -- 606
	if self.stageElapsed >= 1.85 then -- 606
		ctx.audio:playOnce( -- 610
			self:cueKey("p02_bowl_hit"), -- 611
			"sfx", -- 612
			PROLOGUE_AUDIO.bowlHit, -- 613
			0.9, -- 614
			"prologue:p02_bowl_hit", -- 615
			tick -- 616
		) -- 616
	end -- 616
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02ShadowDuration then -- 616
		self:enterEscapeFromDoorway(false) -- 622
	end -- 622
end -- 575
function PrologueIntroPlugin.prototype.stepP02Escape(self, ctx, dt) -- 626
	self.stageElapsed = self.stageElapsed + dt -- 627
	local pRec = asRecord(ctx.p) -- 630
	local liveRemain = readNum(pRec, "escapeRemaining") -- 631
	if not self.rehearsalActive and liveRemain ~= nil then -- 631
		self.escapeRemaining = math.max(0, liveRemain) -- 633
	else -- 633
		self.escapeRemaining = math.max(0, self.escapeRemaining - dt) -- 635
	end -- 635
	if self.rehearsalActive then -- 635
		if ctx.input.moveX ~= 0 then -- 635
			self.escapePlayerX = clamp01(self.escapePlayerX + ctx.input.moveX * dt * 0.34) -- 641
		end -- 641
		if self.escapePlayerX >= 0.85 and ctx.input.interact.pressed or self.escapePlayerX >= 0.98 then -- 641
			self:enterHiddenCabinet() -- 644
			return -- 645
		end -- 645
	end -- 645
	if self.escapeRemaining <= 0 and (self.rehearsalActive or liveRemain == nil) then -- 645
		self:retryEscape() -- 651
		return -- 652
	end -- 652
	local urgency = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 655
	self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + urgency * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 656
	local prevCycle = math.floor(self.heartbeatPhase) -- 659
	self.heartbeatPhase = self.heartbeatPhase + dt * self.heartbeatHz -- 660
	local currCycle = math.floor(self.heartbeatPhase) -- 661
	if currCycle > prevCycle then -- 661
		self.heartbeatBeatCount = self.heartbeatBeatCount + 1 -- 663
		self.heartbeatPulse = 1 -- 664
		ctx.audio:playOnce( -- 665
			self:cueKey("p02_hb_" .. tostring(self.heartbeatBeatCount)), -- 666
			"sfx", -- 667
			PROLOGUE_AUDIO.heartbeat, -- 668
			0.44 + 0.48 * urgency, -- 669
			"prologue:p02_heartbeat:" .. tostring(self.heartbeatBeatCount), -- 670
			ctx.p.ticks -- 671
		) -- 671
	else -- 671
		local frac = self.heartbeatPhase - currCycle -- 675
		if frac >= 0.2 and frac <= 0.28 then -- 675
			self.heartbeatPulse = math.max(self.heartbeatPulse, 0.56) -- 677
		end -- 677
		self.heartbeatPulse = math.max(0, self.heartbeatPulse - dt * 3.8) -- 679
	end -- 679
	self.vignetteAlpha = clamp01(0.14 + urgency * 0.54 + self.heartbeatPulse * 0.16) -- 683
end -- 626
function PrologueIntroPlugin.prototype.stepP02Hidden(self, ctx, dt) -- 686
	self.stageElapsed = self.stageElapsed + dt -- 687
	local tick = ctx.p.ticks -- 688
	ctx.audio:playOnce( -- 690
		self:cueKey("p02_cabinet_shut"), -- 691
		"sfx", -- 692
		PROLOGUE_AUDIO.cabinetShut, -- 693
		0.78, -- 694
		"prologue:p02_cabinet_shut", -- 695
		tick -- 696
	) -- 696
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut then -- 696
		self.vignetteAlpha = 0 -- 701
	else -- 701
		self.vignetteAlpha = self.hiddenStartVignette * (1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 703
	end -- 703
	self.heartbeatHz = 0 -- 706
	self.heartbeatPulse = 0 -- 707
	if self.stageElapsed >= 0.3 then -- 707
		ctx.audio:playOnce( -- 711
			self:cueKey("p02_footsteps_fade"), -- 712
			"sfx", -- 713
			PROLOGUE_AUDIO.footstepsFade, -- 714
			0.65, -- 715
			"prologue:p02_footsteps_fade", -- 716
			tick -- 717
		) -- 717
	end -- 717
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenLinger then -- 717
		self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 722
		self.vignetteAlpha = 0 -- 723
		if not self.rehearsalActive then -- 723
			self.stage = "idle" -- 725
		end -- 725
	end -- 725
end -- 686
function PrologueIntroPlugin.prototype.stepP04(self, ctx, dt) -- 730
	if self.p04Elapsed == 0 then -- 730
		ctx.audio:playOnce( -- 732
			self:cueKey("p04_gunflash"), -- 733
			"sfx", -- 734
			PROLOGUE_AUDIO.distantGunflash, -- 735
			0.78, -- 736
			"prologue:p04_gunflash", -- 737
			ctx.p.ticks -- 738
		) -- 738
	end -- 738
	self.p04Elapsed = self.p04Elapsed + dt -- 741
	self:recomputeP04Weights() -- 742
	if self.p04Elapsed >= ____exports.PROLOGUE_TIMINGS.p04FlashDuration then -- 742
		self.p04Elapsed = ____exports.PROLOGUE_TIMINGS.p04FlashDuration -- 744
		self.p04FlashIntensity = 0 -- 745
		self.p04Active = false -- 746
		self.p04PostHintAlpha = 0.42 -- 748
	end -- 748
end -- 730
function PrologueIntroPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 753
	if not self.p04Active and self.p04PostHintAlpha <= 0.01 then -- 753
		return -- 760
	end -- 760
	self:drawP04WorldAction(fgDraw, fgGlow, worldArt, ctx) -- 762
end -- 753
function PrologueIntroPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 766
	if self.stage == "p01_wake" then -- 766
		self:drawP01Wake( -- 774
			uiDraw, -- 774
			uiInkDraw, -- 774
			uiArt, -- 774
			uiGlow, -- 774
			ctx -- 774
		) -- 774
		return true -- 775
	end -- 775
	if self.stage == "p02_shadow" then -- 775
		self:drawP02ShadowAndBowl( -- 778
			uiDraw, -- 778
			uiInkDraw, -- 778
			uiArt, -- 778
			uiGlow, -- 778
			ctx -- 778
		) -- 778
		return true -- 779
	end -- 779
	if self.stage == "p02_escape" then -- 779
		self:drawP02EscapeVignette(uiDraw, uiInkDraw, uiGlow, ctx) -- 782
		return true -- 784
	end -- 784
	if self.stage == "p02_hidden" then -- 784
		self:drawP02HiddenCabinet( -- 787
			uiDraw, -- 787
			uiInkDraw, -- 787
			uiArt, -- 787
			uiGlow, -- 787
			ctx -- 787
		) -- 787
		return true -- 788
	end -- 788
	return false -- 790
end -- 766
function PrologueIntroPlugin.prototype.drawP01Wake(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 795
	local w = ctx.uiW -- 802
	local h = ctx.uiH -- 803
	local t = self.stageElapsed -- 804
	uiDraw:drawRect( -- 807
		Rect(0, 0, w, h), -- 807
		Color(6, 7, 11, 255) -- 807
	) -- 807
	local wakeOpen = smoothstep(0.75, 2.1, t) -- 810
	local blinkDip = t >= 1.25 and t <= 1.62 and math.sin((t - 1.25) / 0.37 * math.pi) * 0.24 or 0 -- 811
	local eyeOpen = clamp01(wakeOpen - blinkDip) -- 812
	local sitPan = smoothstep(2.65, 3.85, t) -- 813
	local handPress = smoothstep(1.75, 2.35, t) * (1 - smoothstep(3.15, 3.85, t) * 0.65) -- 814
	local fadeOut = 1 - smoothstep(3.72, 4, t) -- 815
	if eyeOpen > 0.01 then -- 815
		local panX = -sitPan * w * 0.16 -- 818
		local sitLiftY = sitPan * h * 0.06 -- 819
		local fireFlicker = 0.84 + 0.16 * math.sin(t * 9.5) * math.cos(t * 5.2) -- 820
		fillVGradRect( -- 823
			uiDraw, -- 824
			0, -- 825
			0, -- 826
			w, -- 827
			h, -- 828
			Color( -- 829
				16, -- 829
				14, -- 829
				18, -- 829
				math.floor(255 * eyeOpen * fadeOut + 0.5) -- 829
			), -- 829
			Color( -- 830
				34, -- 830
				24, -- 830
				24, -- 830
				math.floor(255 * eyeOpen * fadeOut + 0.5) -- 830
			) -- 830
		) -- 830
		uiArt:tryPlacePath( -- 832
			"assets/art/tex_diorama_ming.clip|ming_cloth", -- 833
			"p01_canopy_linen", -- 834
			w * 0.5 + panX * 0.45 + math.sin(t * 1.1) * 6, -- 835
			h * 0.62 - sitLiftY * 0.5, -- 836
			w * 1.32, -- 837
			h * 0.84, -- 838
			{ -- 839
				color = Color(74, 62, 54, 255), -- 840
				opacity = 0.44 * eyeOpen * fadeOut, -- 841
				smooth = true, -- 842
				layer = -2 -- 843
			} -- 843
		) -- 843
		fillRadialGlow( -- 847
			uiGlow, -- 848
			w * 0.34 + panX * 0.4, -- 849
			h * 0.62 - sitLiftY, -- 850
			w * 0.42, -- 851
			h * 0.36, -- 852
			Color( -- 853
				186, -- 853
				108, -- 853
				56, -- 853
				math.floor(68 * fireFlicker * eyeOpen * fadeOut + 0.5) -- 853
			), -- 853
			Color(120, 52, 28, 0), -- 854
			18 -- 855
		) -- 855
		local fold = 0 -- 858
		do -- 858
			fold = 0 -- 859
			while fold < 11 do -- 859
				local fx = w * (0.04 + fold * 0.095) + panX * 0.55 + math.sin(t * 1.4 + fold) * 4 -- 860
				local fw = 22 + fold % 3 * 10 -- 861
				local col = fold & 1 == 0 and Color( -- 862
					52, -- 863
					42, -- 863
					36, -- 863
					math.floor(48 * eyeOpen * fadeOut + 0.5) -- 863
				) or Color( -- 863
					24, -- 864
					20, -- 864
					22, -- 864
					math.floor(62 * eyeOpen * fadeOut + 0.5) -- 864
				) -- 864
				fillHGradRect( -- 865
					uiDraw, -- 865
					fx, -- 865
					h * 0.24, -- 865
					fw, -- 865
					h * 0.72, -- 865
					Color(col.r, col.g, col.b, 0), -- 865
					col -- 865
				) -- 865
				fold = fold + 1 -- 859
			end -- 859
		end -- 859
		local doorVis = smoothstep(2.25, 3.2, t) -- 869
		if doorVis > 0.01 then -- 869
			local doorX = w * 0.84 + panX * 0.95 -- 871
			local crackW = 14 + sitPan * 18 -- 872
			local doorBot = h * 0.14 - sitLiftY * 0.4 -- 873
			local doorH = h * 0.72 -- 874
			uiDraw:drawRect( -- 876
				Rect(doorX - 46, doorBot, 46, doorH), -- 876
				Color( -- 876
					14, -- 876
					12, -- 876
					14, -- 876
					math.floor(235 * doorVis * fadeOut + 0.5) -- 876
				) -- 876
			) -- 876
			uiDraw:drawRect( -- 877
				Rect(doorX + crackW, doorBot, 54, doorH), -- 877
				Color( -- 877
					14, -- 877
					12, -- 877
					14, -- 877
					math.floor(235 * doorVis * fadeOut + 0.5) -- 877
				) -- 877
			) -- 877
			fillVGradRect( -- 879
				uiDraw, -- 880
				doorX, -- 881
				doorBot, -- 882
				crackW, -- 883
				doorH, -- 884
				Color( -- 885
					142, -- 885
					168, -- 885
					186, -- 885
					math.floor(170 * doorVis * fadeOut + 0.5) -- 885
				), -- 885
				Color( -- 886
					214, -- 886
					168, -- 886
					118, -- 886
					math.floor(195 * doorVis * fireFlicker * fadeOut + 0.5) -- 886
				) -- 886
			) -- 886
			fillGradQuad( -- 888
				uiGlow, -- 889
				doorX, -- 890
				doorBot, -- 890
				Color( -- 890
					164, -- 890
					188, -- 890
					204, -- 890
					math.floor(64 * doorVis * fadeOut + 0.5) -- 890
				), -- 890
				doorX + crackW, -- 891
				doorBot, -- 891
				Color( -- 891
					214, -- 891
					164, -- 891
					108, -- 891
					math.floor(54 * doorVis * fadeOut + 0.5) -- 891
				), -- 891
				doorX - 135, -- 892
				doorBot - 40, -- 892
				Color(120, 148, 170, 0), -- 892
				doorX - 190, -- 893
				doorBot + doorH * 0.48, -- 893
				Color(180, 130, 82, 0) -- 893
			) -- 893
		end -- 893
		local bedTopY = h * 0.27 - sitLiftY -- 898
		local dipX = w * 0.52 + panX * 0.7 -- 899
		local pressDepth = 22 * handPress -- 900
		uiDraw:drawPolygon( -- 902
			{ -- 902
				Vec2(0, 0), -- 903
				Vec2(w, 0), -- 904
				Vec2(w, bedTopY + 10), -- 905
				Vec2(dipX + 110, bedTopY + 6), -- 906
				Vec2(dipX + 38, bedTopY - pressDepth * 0.85), -- 907
				Vec2(dipX - 34, bedTopY - pressDepth), -- 908
				Vec2(dipX - 108, bedTopY + 5), -- 909
				Vec2(0, bedTopY + 12) -- 910
			}, -- 910
			Color( -- 911
				30, -- 911
				27, -- 911
				32, -- 911
				math.floor(248 * eyeOpen * fadeOut + 0.5) -- 911
			) -- 911
		) -- 911
		uiInkDraw:drawSegment( -- 914
			Vec2(dipX - 96, bedTopY + 4), -- 915
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 916
			1.6, -- 917
			Color( -- 918
				124, -- 918
				114, -- 918
				102, -- 918
				math.floor(145 * eyeOpen * fadeOut + 0.5) -- 918
			) -- 918
		) -- 918
		uiInkDraw:drawSegment( -- 920
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 921
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 922
			1.4, -- 923
			Color( -- 924
				92, -- 924
				82, -- 924
				74, -- 924
				math.floor(165 * eyeOpen * fadeOut + 0.5) -- 924
			) -- 924
		) -- 924
		uiInkDraw:drawSegment( -- 926
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 927
			Vec2(dipX + 106, bedTopY + 5), -- 928
			1.5, -- 929
			Color( -- 930
				138, -- 930
				122, -- 930
				106, -- 930
				math.floor(140 * eyeOpen * fadeOut + 0.5) -- 930
			) -- 930
		) -- 930
		if handPress > 0.02 then -- 930
			local hx = dipX -- 935
			local hy = bedTopY - pressDepth + 12 -- 936
			local handOp = handPress * fadeOut -- 937
			local warmR = math.floor(218 + 26 * fireFlicker + 0.5) -- 938
			local warmG = math.floor(192 + 18 * fireFlicker + 0.5) -- 939
			local warmB = math.floor(172 + 10 * fireFlicker + 0.5) -- 940
			if not uiArt:tryPlacePath( -- 940
				"assets/art/cutscene_story_parts.clip|prologue_father_hand", -- 942
				"p01_father_hand", -- 943
				hx + 18, -- 944
				hy + 32, -- 945
				360, -- 946
				295, -- 947
				{ -- 948
					anchorX = 0.48, -- 949
					anchorY = 0.36, -- 950
					color = Color(warmR, warmG, warmB, 255), -- 951
					opacity = handOp, -- 952
					smooth = true, -- 953
					layer = 2 -- 954
				} -- 954
			) then -- 954
				local ha = math.floor(245 * handOp + 0.5) -- 957
				uiDraw:drawPolygon( -- 958
					{ -- 958
						Vec2(hx - 62, hy + 135), -- 959
						Vec2(hx - 14, hy + 142), -- 960
						Vec2(hx + 8, hy + 28), -- 961
						Vec2(hx - 36, hy + 24) -- 962
					}, -- 962
					Color(42, 46, 54, ha) -- 963
				) -- 963
				uiDraw:drawPolygon( -- 964
					{ -- 964
						Vec2(hx - 38, hy + 26), -- 965
						Vec2(hx + 16, hy + 28), -- 966
						Vec2(hx + 34, hy + 2), -- 967
						Vec2(hx + 22, hy - 14), -- 968
						Vec2(hx - 26, hy - 12), -- 969
						Vec2(hx - 42, hy + 4) -- 970
					}, -- 970
					Color(148, 112, 86, ha) -- 971
				) -- 971
			end -- 971
		end -- 971
	end -- 971
	local lidH = h * 0.52 * (1 - eyeOpen) -- 977
	if lidH > 1 then -- 977
		uiDraw:drawRect( -- 979
			Rect(0, h - lidH, w, lidH), -- 979
			Color(5, 6, 9, 255) -- 979
		) -- 979
		uiDraw:drawRect( -- 980
			Rect(0, 0, w, lidH), -- 980
			Color(5, 6, 9, 255) -- 980
		) -- 980
		local feather = math.min(46, h * 0.08) -- 981
		fillVGradRect( -- 982
			uiDraw, -- 982
			0, -- 982
			h - lidH - feather, -- 982
			w, -- 982
			feather, -- 982
			Color(5, 6, 9, 0), -- 982
			Color(5, 6, 9, 235) -- 982
		) -- 982
		fillVGradRect( -- 983
			uiDraw, -- 983
			0, -- 983
			lidH, -- 983
			w, -- 983
			feather, -- 983
			Color(5, 6, 9, 235), -- 983
			Color(5, 6, 9, 0) -- 983
		) -- 983
	end -- 983
	local callAlpha = smoothstep(0.1, 0.32, t) * (1 - smoothstep(1.05, 1.55, t)) -- 987
	if callAlpha > 0.02 then -- 987
		drawSilkVeil( -- 989
			uiDraw, -- 989
			uiArt, -- 989
			"p01_call_veil", -- 989
			w * 0.5, -- 989
			h * 0.14, -- 989
			240, -- 989
			44, -- 989
			PALETTE.inkWash, -- 989
			0.72 * callAlpha, -- 989
			0 -- 989
		) -- 989
		ctx.texts:put( -- 990
			"sm", -- 991
			"「小满。」", -- 992
			w * 0.5, -- 993
			h * 0.14, -- 994
			toColor(PALETTE.textBright), -- 995
			0.5, -- 996
			0.5, -- 997
			"Center", -- 998
			2, -- 999
			callAlpha, -- 1000
			0.08 -- 1001
		) -- 1001
	end -- 1001
end -- 795
function PrologueIntroPlugin.prototype.drawP02ShadowAndBowl(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1008
	local w = ctx.uiW -- 1015
	local h = ctx.uiH -- 1016
	local t = self.stageElapsed -- 1017
	local fireFlicker = 0.85 + 0.15 * math.sin(t * 14) -- 1018
	local floorY = h * 0.25 -- 1021
	fillVGradRect( -- 1022
		uiDraw, -- 1022
		0, -- 1022
		floorY, -- 1022
		w, -- 1022
		h - floorY, -- 1022
		Color(38, 30, 28, 255), -- 1022
		Color(20, 18, 24, 255) -- 1022
	) -- 1022
	fillVGradRect( -- 1023
		uiDraw, -- 1023
		0, -- 1023
		0, -- 1023
		w, -- 1023
		floorY, -- 1023
		Color(12, 12, 16, 255), -- 1023
		Color(28, 24, 24, 255) -- 1023
	) -- 1023
	uiArt:tryPlacePath( -- 1024
		"assets/art/tex_diorama_ming.clip|ming_brick", -- 1024
		"p02_wall_brick_l", -- 1024
		w * 0.25, -- 1024
		floorY + (h - floorY) * 0.5, -- 1024
		w * 0.52, -- 1024
		h - floorY, -- 1024
		{ -- 1024
			color = Color(72, 60, 54, 255), -- 1025
			opacity = 0.52, -- 1026
			smooth = true, -- 1027
			layer = -4 -- 1028
		} -- 1028
	) -- 1028
	uiArt:tryPlacePath( -- 1030
		"assets/art/tex_diorama_ming.clip|ming_brick", -- 1030
		"p02_wall_brick_r", -- 1030
		w * 0.75, -- 1030
		floorY + (h - floorY) * 0.5, -- 1030
		w * 0.52, -- 1030
		h - floorY, -- 1030
		{ -- 1030
			color = Color(64, 54, 50, 255), -- 1031
			opacity = 0.52, -- 1032
			smooth = true, -- 1033
			layer = -4 -- 1034
		} -- 1034
	) -- 1034
	uiArt:tryPlacePath( -- 1036
		"assets/art/tex_diorama_ming.clip|ming_stone", -- 1036
		"p02_floor_stone", -- 1036
		w * 0.5, -- 1036
		floorY * 0.5, -- 1036
		w, -- 1036
		floorY, -- 1036
		{ -- 1036
			color = Color(62, 58, 56, 255), -- 1037
			opacity = 0.48, -- 1038
			smooth = true, -- 1039
			layer = -3 -- 1040
		} -- 1040
	) -- 1040
	fillRadialGlow( -- 1044
		uiGlow, -- 1045
		w * 0.12, -- 1046
		floorY + h * 0.28, -- 1047
		w * 0.52, -- 1048
		h * 0.44, -- 1049
		Color( -- 1050
			198, -- 1050
			116, -- 1050
			56, -- 1050
			math.floor(78 * fireFlicker + 0.5) -- 1050
		), -- 1050
		Color(120, 50, 24, 0), -- 1051
		18 -- 1052
	) -- 1052
	local cutProg = smoothstep(0.62, 1.05, t) -- 1056
	local tremble = math.sin(t * 18) * 3 -- 1057
	local p1X = w * 0.42 + tremble -- 1058
	local p2X = w * 0.56 - tremble * 0.6 -- 1059
	local parentDrop = cutProg * 36 -- 1060
	uiInkDraw:drawPolygon( -- 1061
		{ -- 1061
			Vec2(p1X - 42, floorY), -- 1062
			Vec2(p1X + 34, floorY), -- 1063
			Vec2(p1X + 26 + cutProg * 26, floorY + 218 - parentDrop), -- 1064
			Vec2(p1X - 28 + cutProg * 14, floorY + 226 - parentDrop) -- 1065
		}, -- 1065
		Color(10, 9, 13, 212) -- 1066
	) -- 1066
	uiInkDraw:drawCircle( -- 1067
		Vec2(p1X + cutProg * 20, floorY + 248 - parentDrop), -- 1067
		24, -- 1067
		Color(10, 9, 13, 212) -- 1067
	) -- 1067
	uiInkDraw:drawPolygon( -- 1068
		{ -- 1068
			Vec2(p2X - 36, floorY), -- 1069
			Vec2(p2X + 32, floorY), -- 1070
			Vec2(p2X + 20 + cutProg * 32, floorY + 186 - parentDrop * 0.8), -- 1071
			Vec2(p2X - 24 + cutProg * 18, floorY + 194 - parentDrop * 0.8) -- 1072
		}, -- 1072
		Color(11, 10, 14, 202) -- 1073
	) -- 1073
	uiInkDraw:drawCircle( -- 1074
		Vec2(p2X - 2 + cutProg * 26, floorY + 214 - parentDrop * 0.8), -- 1074
		21, -- 1074
		Color(11, 10, 14, 202) -- 1074
	) -- 1074
	if cutProg > 0.01 then -- 1074
		local sx = w * (0.02 + cutProg * 0.46) -- 1078
		uiInkDraw:drawPolygon( -- 1079
			{ -- 1079
				Vec2(0, floorY), -- 1080
				Vec2(sx + 58, floorY), -- 1081
				Vec2(sx + 135, h), -- 1082
				Vec2(0, h) -- 1083
			}, -- 1083
			Color( -- 1084
				6, -- 1084
				6, -- 1084
				10, -- 1084
				math.floor(234 * cutProg + 0.5) -- 1084
			) -- 1084
		) -- 1084
		uiInkDraw:drawPolygon( -- 1085
			{ -- 1085
				Vec2(sx + 20, floorY + 160), -- 1086
				Vec2(sx + 275 * cutProg, floorY + 260), -- 1087
				Vec2(sx + 268 * cutProg, floorY + 276), -- 1088
				Vec2(sx + 14, floorY + 178) -- 1089
			}, -- 1089
			Color( -- 1090
				5, -- 1090
				5, -- 1090
				8, -- 1090
				math.floor(232 * cutProg + 0.5) -- 1090
			) -- 1090
		) -- 1090
	end -- 1090
	local threshX = w * 0.66 -- 1094
	uiDraw:drawRect( -- 1095
		Rect(threshX, floorY - 22, 26, 30), -- 1095
		Color(54, 38, 28, 255), -- 1095
		1.2, -- 1095
		Color(112, 86, 62, 210) -- 1095
	) -- 1095
	uiInkDraw:drawSegment( -- 1096
		Vec2(threshX, floorY + 8), -- 1096
		Vec2(threshX + 26, floorY + 8), -- 1096
		1.6, -- 1096
		Color(156, 128, 96, 200) -- 1096
	) -- 1096
	local rollK = smoothstep(0.98, 1.85, t) -- 1099
	if t >= 0.96 then -- 1099
		local startX = w * 0.14 -- 1101
		local stopX = threshX - 22 -- 1102
		local bx = startX + (stopX - startX) * rollK -- 1103
		local bounce = rollK < 1 and math.abs(math.sin(rollK * math.pi * 3.5)) * (1 - rollK) * 18 or 0 -- 1104
		local by = floorY + 14 + bounce -- 1105
		uiInkDraw:drawEllipse( -- 1107
			Vec2(bx, floorY + 2), -- 1107
			22, -- 1107
			5.2, -- 1107
			Color(6, 6, 10, 175) -- 1107
		) -- 1107
		if not uiArt:tryPlacePath( -- 1107
			"assets/art/cutscene_story_parts.clip|prologue_bowl_roll", -- 1109
			"p02_rolling_bowl", -- 1110
			bx, -- 1111
			by, -- 1112
			58, -- 1113
			46, -- 1114
			{ -- 1115
				anchorX = 0.5, -- 1116
				anchorY = 0.5, -- 1117
				angle = rollK * 580, -- 1118
				smooth = true, -- 1119
				layer = 5 -- 1120
			} -- 1120
		) then -- 1120
			uiInkDraw:drawCircle( -- 1123
				Vec2(bx, by), -- 1123
				16, -- 1123
				Color(168, 164, 152, 245) -- 1123
			) -- 1123
		end -- 1123
		if t >= 1.84 then -- 1123
			local impact = 1 - smoothstep(1.84, 2, t) -- 1126
			if impact > 0.02 then -- 1126
				uiInkDraw:drawSegment( -- 1128
					Vec2(threshX - 2, floorY + 8), -- 1129
					Vec2(threshX - 14 - (1 - impact) * 12, floorY + 18 + (1 - impact) * 8), -- 1130
					1.4, -- 1131
					Color( -- 1132
						220, -- 1132
						210, -- 1132
						194, -- 1132
						math.floor(210 * impact + 0.5) -- 1132
					) -- 1132
				) -- 1132
			end -- 1132
		end -- 1132
	end -- 1132
	local wobble = math.sin(t * 11) * 4 -- 1139
	if not uiArt:tryPlacePath( -- 1139
		"assets/art/cutscene_well_museum.clip|prologue_cabinet_doors", -- 1141
		"p02_shadow_cabinet_edge", -- 1142
		w + 22 + wobble * 0.4, -- 1143
		floorY + 88, -- 1144
		195, -- 1145
		198, -- 1146
		{ -- 1147
			anchorX = 0.5, -- 1148
			anchorY = 0.5, -- 1149
			color = Color(172, 152, 134, 255), -- 1150
			opacity = 0.96, -- 1151
			smooth = true, -- 1152
			layer = 3 -- 1153
		} -- 1153
	) then -- 1153
		uiDraw:drawRect( -- 1156
			Rect(w - 72 + wobble * 0.3, floorY, 64, 142), -- 1156
			Color(42, 30, 24, 250), -- 1156
			1.1, -- 1156
			Color(94, 72, 54, 180) -- 1156
		) -- 1156
	end -- 1156
	uiInkDraw:drawRect( -- 1160
		Rect(0, h - 46, w, 46), -- 1160
		Color(6, 8, 12, 244) -- 1160
	) -- 1160
	uiInkDraw:drawRect( -- 1161
		Rect(0, 0, w, 46), -- 1161
		Color(6, 8, 12, 244) -- 1161
	) -- 1161
end -- 1008
function PrologueIntroPlugin.prototype.drawP02EscapeVignette(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1166
	local w = ctx.uiW -- 1172
	local h = ctx.uiH -- 1173
	local a = clamp01(self.vignetteAlpha) -- 1174
	if a > 0.005 then -- 1174
		local edgeX = w * (0.09 + 0.06 * a) -- 1177
		local edgeY = h * (0.11 + 0.07 * a) -- 1178
		local peakA = math.floor(168 * a + 0.5) -- 1179
		local deep = PALETTE.crimsonDeep -- 1180
		local rouge = PALETTE.rouge -- 1181
		local cEdge = Color(deep.r, deep.g, deep.b, peakA) -- 1182
		local cZero = Color(deep.r, deep.g, deep.b, 0) -- 1183
		fillHGradRect( -- 1185
			uiDraw, -- 1185
			0, -- 1185
			0, -- 1185
			edgeX, -- 1185
			h, -- 1185
			cEdge, -- 1185
			cZero -- 1185
		) -- 1185
		fillHGradRect( -- 1186
			uiDraw, -- 1186
			w - edgeX, -- 1186
			0, -- 1186
			edgeX, -- 1186
			h, -- 1186
			cZero, -- 1186
			cEdge -- 1186
		) -- 1186
		fillVGradRect( -- 1187
			uiDraw, -- 1187
			0, -- 1187
			0, -- 1187
			w, -- 1187
			edgeY, -- 1187
			cEdge, -- 1187
			cZero -- 1187
		) -- 1187
		fillVGradRect( -- 1188
			uiDraw, -- 1188
			0, -- 1188
			h - edgeY, -- 1188
			w, -- 1188
			edgeY, -- 1188
			cZero, -- 1188
			cEdge -- 1188
		) -- 1188
		if self.heartbeatPulse > 0.02 then -- 1188
			local pa = math.floor(62 * self.heartbeatPulse * a + 0.5) -- 1192
			local cPulse = Color(rouge.r, rouge.g, rouge.b, pa) -- 1193
			local cPulseZero = Color(rouge.r, rouge.g, rouge.b, 0) -- 1194
			fillHGradRect( -- 1195
				uiGlow, -- 1195
				0, -- 1195
				0, -- 1195
				edgeX * 0.72, -- 1195
				h, -- 1195
				cPulse, -- 1195
				cPulseZero -- 1195
			) -- 1195
			fillHGradRect( -- 1196
				uiGlow, -- 1196
				w - edgeX * 0.72, -- 1196
				0, -- 1196
				edgeX * 0.72, -- 1196
				h, -- 1196
				cPulseZero, -- 1196
				cPulse -- 1196
			) -- 1196
		end -- 1196
	end -- 1196
	if self.rehearsalActive then -- 1196
		local groundY = h * 0.24 -- 1202
		local doorX = w * 0.14 -- 1203
		local cabX = w * 0.8 -- 1204
		local childX = doorX + (cabX - doorX) * self.escapePlayerX -- 1205
		local wobble = math.sin(self.stageElapsed * 9.5) * 4 -- 1206
		uiInkDraw:drawRect( -- 1209
			Rect(doorX - 18, groundY, 16, 130), -- 1209
			Color(48, 36, 28, 220) -- 1209
		) -- 1209
		uiDraw:drawCircle( -- 1210
			Vec2(doorX + 18, groundY + 8), -- 1210
			8, -- 1210
			Color(168, 164, 152, 220) -- 1210
		) -- 1210
		uiDraw:drawRect( -- 1212
			Rect(cabX, groundY, 74, 108), -- 1212
			Color(42, 31, 24, 240), -- 1212
			1.2, -- 1212
			Color(118, 92, 68, 195) -- 1212
		) -- 1212
		uiInkDraw:drawSegment( -- 1213
			Vec2(cabX + 8 + wobble * 0.5, groundY + 6), -- 1213
			Vec2(cabX + 8 + wobble * 0.5, groundY + 100), -- 1213
			2.2, -- 1213
			Color(176, 144, 106, 210) -- 1213
		) -- 1213
		if not ctx.uiArt:tryPlace( -- 1213
			"child_run", -- 1215
			"p02_escape_child", -- 1215
			childX, -- 1215
			groundY, -- 1215
			46, -- 1215
			74, -- 1215
			{ -- 1215
				facing = 1, -- 1216
				frame = math.floor(self.stageElapsed * 10), -- 1217
				layer = 3 -- 1218
			} -- 1218
		) then -- 1218
			uiDraw:drawRect( -- 1220
				Rect(childX - 12, groundY, 24, 54), -- 1220
				Color(168, 72, 54, 235) -- 1220
			) -- 1220
		end -- 1220
	end -- 1220
end -- 1166
function PrologueIntroPlugin.prototype.drawP02HiddenCabinet(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1227
	local w = ctx.uiW -- 1234
	local h = ctx.uiH -- 1235
	local t = self.stageElapsed -- 1236
	local closeK = smoothstep(0, 0.26, t) -- 1237
	local doorW = w * (1.28 - 0.22 * closeK) -- 1240
	local doorH = h * 1.16 -- 1241
	local placedDoors = uiArt:tryPlacePath( -- 1242
		"assets/art/cutscene_well_museum.clip|prologue_cabinet_doors", -- 1243
		"p02_hidden_cabinet_doors", -- 1244
		w * 0.5, -- 1245
		h * 0.5, -- 1246
		doorW, -- 1247
		doorH, -- 1248
		{ -- 1249
			anchorX = 0.5, -- 1250
			anchorY = 0.5, -- 1251
			color = Color(78, 66, 56, 255), -- 1252
			opacity = 0.98, -- 1253
			smooth = true, -- 1254
			layer = 3 -- 1255
		} -- 1255
	) -- 1255
	if not placedDoors then -- 1255
		local slitW = w * (0.28 - 0.21 * closeK) -- 1259
		local leftW = (w - slitW) * 0.5 -- 1260
		uiDraw:drawRect( -- 1261
			Rect(0, 0, leftW, h), -- 1261
			Color(7, 7, 10, 248) -- 1261
		) -- 1261
		uiDraw:drawRect( -- 1262
			Rect(w - leftW, 0, leftW, h), -- 1262
			Color(7, 7, 10, 248) -- 1262
		) -- 1262
		uiInkDraw:drawSegment( -- 1263
			Vec2(leftW, 0), -- 1263
			Vec2(leftW, h), -- 1263
			1.4, -- 1263
			Color(66, 52, 40, 175) -- 1263
		) -- 1263
		uiInkDraw:drawSegment( -- 1264
			Vec2(w - leftW, 0), -- 1264
			Vec2(w - leftW, h), -- 1264
			1.4, -- 1264
			Color(66, 52, 40, 175) -- 1264
		) -- 1264
	else -- 1264
		local edgeW = w * 0.24 -- 1267
		fillHGradRect( -- 1268
			uiInkDraw, -- 1268
			0, -- 1268
			0, -- 1268
			edgeW, -- 1268
			h, -- 1268
			Color(5, 6, 9, 232), -- 1268
			Color(5, 6, 9, 0) -- 1268
		) -- 1268
		fillHGradRect( -- 1269
			uiInkDraw, -- 1269
			w - edgeW, -- 1269
			0, -- 1269
			edgeW, -- 1269
			h, -- 1269
			Color(5, 6, 9, 0), -- 1269
			Color(5, 6, 9, 232) -- 1269
		) -- 1269
	end -- 1269
	local footFade = 1 - smoothstep(0.3, 0.8, t) -- 1273
	if footFade > 0.02 then -- 1273
		local shadowX = w * 0.5 + (1 - footFade) * 38 -- 1275
		fillRadialGlow( -- 1276
			uiGlow, -- 1277
			shadowX, -- 1278
			h * 0.42, -- 1279
			32, -- 1280
			90, -- 1281
			Color( -- 1282
				148, -- 1282
				168, -- 1282
				184, -- 1282
				math.floor(32 * footFade + 0.5) -- 1282
			), -- 1282
			Color(90, 110, 130, 0), -- 1283
			12 -- 1284
		) -- 1284
	end -- 1284
	if self.vignetteAlpha > 0.005 then -- 1284
		local a = math.floor(140 * self.vignetteAlpha + 0.5) -- 1290
		local edge = w * 0.08 -- 1291
		fillHGradRect( -- 1292
			uiInkDraw, -- 1292
			0, -- 1292
			0, -- 1292
			edge, -- 1292
			h, -- 1292
			Color(124, 38, 42, a), -- 1292
			Color(124, 38, 42, 0) -- 1292
		) -- 1292
		fillHGradRect( -- 1293
			uiInkDraw, -- 1293
			w - edge, -- 1293
			0, -- 1293
			edge, -- 1293
			h, -- 1293
			Color(124, 38, 42, 0), -- 1293
			Color(124, 38, 42, a) -- 1293
		) -- 1293
	end -- 1293
end -- 1227
function PrologueIntroPlugin.prototype.drawP04WorldAction(self, fgDraw, fgGlow, worldArt, ctx) -- 1299
	local p = ctx.p -- 1305
	local cam = ctx.cam -- 1306
	local flash = self.p04FlashIntensity -- 1307
	local hintAlpha = self.p04PostHintAlpha -- 1308
	local zhou = p.childMode and p.partner or p.player -- 1310
	local xiao = p.childMode and p.player or p.partner -- 1311
	local zX = cam:sx(zhou.x) -- 1312
	local zY = cam:sy(zhou.y, zhou.depth) -- 1313
	local zH = cam:len(zhou.h) -- 1314
	local xX = cam:sx(xiao.x) -- 1315
	local xY = cam:sy(xiao.y, xiao.depth) -- 1316
	local xH = cam:len(xiao.h) -- 1317
	if flash > 0.01 then -- 1317
		fillGradQuad( -- 1322
			fgGlow, -- 1323
			cam.viewW, -- 1324
			cam.groundScreenY + cam:len(18), -- 1324
			Color( -- 1324
				238, -- 1324
				178, -- 1324
				108, -- 1324
				math.floor(96 * flash + 0.5) -- 1324
			), -- 1324
			cam.viewW, -- 1325
			cam.groundScreenY + cam:len(195), -- 1325
			Color( -- 1325
				224, -- 1325
				148, -- 1325
				82, -- 1325
				math.floor(72 * flash + 0.5) -- 1325
			), -- 1325
			zX - cam:len(140), -- 1326
			cam.groundScreenY + cam:len(140), -- 1326
			Color(200, 120, 62, 0), -- 1326
			zX - cam:len(140), -- 1327
			cam.groundScreenY, -- 1327
			Color(200, 120, 62, 0) -- 1327
		) -- 1327
		local wallBaseY = cam.groundScreenY + cam:len(14) -- 1331
		local shAlpha = math.floor(148 * flash + 0.5) -- 1332
		local shCol = Color(8, 10, 14, shAlpha) -- 1333
		fgDraw:drawPolygon( -- 1335
			{ -- 1335
				Vec2( -- 1336
					zX - cam:len(14), -- 1336
					wallBaseY -- 1336
				), -- 1336
				Vec2( -- 1337
					zX + cam:len(6), -- 1337
					wallBaseY -- 1337
				), -- 1337
				Vec2( -- 1338
					zX - cam:len(38), -- 1338
					wallBaseY + zH * 1.18 -- 1338
				), -- 1338
				Vec2( -- 1339
					zX - cam:len(64), -- 1339
					wallBaseY + zH * 1.12 -- 1339
				) -- 1339
			}, -- 1339
			shCol -- 1340
		) -- 1340
		fgDraw:drawPolygon( -- 1342
			{ -- 1342
				Vec2( -- 1343
					xX - cam:len(10), -- 1343
					wallBaseY -- 1343
				), -- 1343
				Vec2( -- 1344
					xX + cam:len(6), -- 1344
					wallBaseY -- 1344
				), -- 1344
				Vec2( -- 1345
					xX - cam:len(26), -- 1345
					wallBaseY + xH * 1.12 -- 1345
				), -- 1345
				Vec2( -- 1346
					xX - cam:len(44), -- 1346
					wallBaseY + xH * 1.06 -- 1346
				) -- 1346
			}, -- 1346
			shCol -- 1347
		) -- 1347
		local shieldK = smoothstep(0.1, 0.24, self.p04Elapsed) * (1 - smoothstep(0.5, 0.78, self.p04Elapsed)) -- 1350
		if shieldK > 0.02 then -- 1350
			local armX = zX + cam:len(10) -- 1352
			local armY = zY + zH * 0.66 -- 1353
			local cuffW = cam:len(13) -- 1354
			local cuffH = cam:len(7) -- 1355
			local sa = math.floor(235 * shieldK + 0.5) -- 1356
			fgDraw:drawPolygon( -- 1357
				{ -- 1357
					Vec2( -- 1358
						zX + cam:len(2), -- 1358
						armY - cuffH * 0.4 -- 1358
					), -- 1358
					Vec2(armX + cuffW, armY + cuffH * 0.9), -- 1359
					Vec2(armX + cuffW * 0.72, armY + cuffH * 1.75), -- 1360
					Vec2( -- 1361
						zX - cam:len(2), -- 1361
						armY + cuffH * 0.5 -- 1361
					) -- 1361
				}, -- 1361
				toColor(____exports.CUFF_SHARED_SPEC.indigoCloth, sa) -- 1362
			) -- 1362
			fgDraw:drawSegment( -- 1364
				Vec2(armX + cuffW * 0.45, armY + cuffH * 0.75), -- 1365
				Vec2(armX + cuffW * 0.82, armY + cuffH * 1.25), -- 1366
				1.3, -- 1367
				toColor( -- 1368
					____exports.CUFF_SHARED_SPEC.mendStitch, -- 1368
					math.floor(210 * shieldK + 0.5) -- 1368
				) -- 1368
			) -- 1368
			fillGradQuad( -- 1371
				fgDraw, -- 1372
				zX + cam:len(4), -- 1373
				zY + zH * 0.85, -- 1373
				Color( -- 1373
					10, -- 1373
					12, -- 1373
					18, -- 1373
					math.floor(92 * shieldK + 0.5) -- 1373
				), -- 1373
				zX + cam:len(4), -- 1374
				zY, -- 1374
				Color( -- 1374
					10, -- 1374
					12, -- 1374
					18, -- 1374
					math.floor(62 * shieldK + 0.5) -- 1374
				), -- 1374
				xX - cam:len(18), -- 1375
				xY, -- 1375
				Color(10, 12, 18, 0), -- 1375
				xX - cam:len(18), -- 1376
				xY + xH, -- 1376
				Color(10, 12, 18, 0) -- 1376
			) -- 1376
		end -- 1376
	end -- 1376
	if hintAlpha > 0.02 then -- 1376
		local baseWx = self.p04AnchorWorldX > 0 and self.p04AnchorWorldX or zhou.x -- 1383
		local hintBaseX = cam:sx(baseWx + 74) -- 1384
		local groundY = cam:sy(0, 0) -- 1385
		local boardW = cam:len(62) -- 1386
		local sheenBoost = flash * 0.55 -- 1387
		local aNorm = clamp01(hintAlpha + sheenBoost) -- 1388
		local placedBoard = worldArt:tryPlacePath( -- 1390
			"assets/art/cutscene_well_museum.clip|p04_window_board", -- 1391
			"p04_polished_window_board", -- 1392
			hintBaseX + boardW * 0.5, -- 1393
			groundY - 2, -- 1394
			boardW * 1.15, -- 1395
			cam:len(68), -- 1396
			{ -- 1397
				anchorX = 0.5, -- 1398
				anchorY = 0, -- 1399
				color = Color( -- 1400
					math.floor(188 + 64 * flash + 0.5), -- 1401
					math.floor(184 + 54 * flash + 0.5), -- 1402
					math.floor(176 + 34 * flash + 0.5), -- 1403
					255 -- 1404
				), -- 1404
				opacity = 0.88 * aNorm, -- 1406
				smooth = true, -- 1407
				layer = 4200 -- 1408
			} -- 1408
		) -- 1408
		if not placedBoard then -- 1408
			local boardY = groundY + cam:len(34) -- 1412
			fgDraw:drawRect( -- 1413
				Rect( -- 1414
					hintBaseX, -- 1414
					boardY, -- 1414
					boardW, -- 1414
					cam:len(12) -- 1414
				), -- 1414
				Color( -- 1415
					54, -- 1415
					42, -- 1415
					32, -- 1415
					math.floor(165 * aNorm + 0.5) -- 1415
				), -- 1415
				1, -- 1416
				Color( -- 1417
					126, -- 1417
					102, -- 1417
					76, -- 1417
					math.floor(150 * aNorm + 0.5) -- 1417
				) -- 1417
			) -- 1417
		end -- 1417
		fillRadialGlow( -- 1421
			fgGlow, -- 1422
			hintBaseX + boardW * 0.52, -- 1423
			groundY + cam:len(8), -- 1424
			boardW * 0.55, -- 1425
			cam:len(12), -- 1426
			Color( -- 1427
				232, -- 1427
				214, -- 1427
				178, -- 1427
				math.floor((46 + 84 * flash) * aNorm + 0.5) -- 1427
			), -- 1427
			Color(214, 186, 142, 0), -- 1428
			12 -- 1429
		) -- 1429
	end -- 1429
end -- 1299
return ____exports -- 1299