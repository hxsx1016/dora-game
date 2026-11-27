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
function PrologueIntroPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 753
	if not self.p04Active and self.p04PostHintAlpha <= 0.01 then -- 753
		return -- 760
	end -- 760
	self:drawP04WorldAction(fgDraw, fgGlow, ctx) -- 762
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
		self:drawP02ShadowAndBowl(uiDraw, uiInkDraw, uiGlow, ctx) -- 778
		return true -- 779
	end -- 779
	if self.stage == "p02_escape" then -- 779
		self:drawP02EscapeVignette(uiDraw, uiInkDraw, uiGlow, ctx) -- 782
		return true -- 784
	end -- 784
	if self.stage == "p02_hidden" then -- 784
		self:drawP02HiddenCabinet(uiDraw, uiInkDraw, uiGlow, ctx) -- 787
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
		fillRadialGlow( -- 833
			uiGlow, -- 834
			w * 0.34 + panX * 0.4, -- 835
			h * 0.62 - sitLiftY, -- 836
			w * 0.42, -- 837
			h * 0.36, -- 838
			Color( -- 839
				186, -- 839
				108, -- 839
				56, -- 839
				math.floor(68 * fireFlicker * eyeOpen * fadeOut + 0.5) -- 839
			), -- 839
			Color(120, 52, 28, 0), -- 840
			18 -- 841
		) -- 841
		local fold = 0 -- 844
		do -- 844
			fold = 0 -- 845
			while fold < 11 do -- 845
				local fx = w * (0.04 + fold * 0.095) + panX * 0.55 + math.sin(t * 1.4 + fold) * 4 -- 846
				local fw = 22 + fold % 3 * 10 -- 847
				local col = fold & 1 == 0 and Color( -- 848
					52, -- 849
					42, -- 849
					36, -- 849
					math.floor(64 * eyeOpen * fadeOut + 0.5) -- 849
				) or Color( -- 849
					24, -- 850
					20, -- 850
					22, -- 850
					math.floor(78 * eyeOpen * fadeOut + 0.5) -- 850
				) -- 850
				fillHGradRect( -- 851
					uiDraw, -- 851
					fx, -- 851
					h * 0.24, -- 851
					fw, -- 851
					h * 0.72, -- 851
					Color(col.r, col.g, col.b, 0), -- 851
					col -- 851
				) -- 851
				fold = fold + 1 -- 845
			end -- 845
		end -- 845
		local doorVis = smoothstep(2.25, 3.2, t) -- 855
		if doorVis > 0.01 then -- 855
			local doorX = w * 0.84 + panX * 0.95 -- 857
			local crackW = 14 + sitPan * 18 -- 858
			local doorBot = h * 0.14 - sitLiftY * 0.4 -- 859
			local doorH = h * 0.72 -- 860
			uiDraw:drawRect( -- 862
				Rect(doorX - 46, doorBot, 46, doorH), -- 862
				Color( -- 862
					14, -- 862
					12, -- 862
					14, -- 862
					math.floor(235 * doorVis * fadeOut + 0.5) -- 862
				) -- 862
			) -- 862
			uiDraw:drawRect( -- 863
				Rect(doorX + crackW, doorBot, 54, doorH), -- 863
				Color( -- 863
					14, -- 863
					12, -- 863
					14, -- 863
					math.floor(235 * doorVis * fadeOut + 0.5) -- 863
				) -- 863
			) -- 863
			fillVGradRect( -- 865
				uiDraw, -- 866
				doorX, -- 867
				doorBot, -- 868
				crackW, -- 869
				doorH, -- 870
				Color( -- 871
					142, -- 871
					168, -- 871
					186, -- 871
					math.floor(170 * doorVis * fadeOut + 0.5) -- 871
				), -- 871
				Color( -- 872
					214, -- 872
					168, -- 872
					118, -- 872
					math.floor(195 * doorVis * fireFlicker * fadeOut + 0.5) -- 872
				) -- 872
			) -- 872
			fillGradQuad( -- 874
				uiGlow, -- 875
				doorX, -- 876
				doorBot, -- 876
				Color( -- 876
					164, -- 876
					188, -- 876
					204, -- 876
					math.floor(64 * doorVis * fadeOut + 0.5) -- 876
				), -- 876
				doorX + crackW, -- 877
				doorBot, -- 877
				Color( -- 877
					214, -- 877
					164, -- 877
					108, -- 877
					math.floor(54 * doorVis * fadeOut + 0.5) -- 877
				), -- 877
				doorX - 135, -- 878
				doorBot - 40, -- 878
				Color(120, 148, 170, 0), -- 878
				doorX - 190, -- 879
				doorBot + doorH * 0.48, -- 879
				Color(180, 130, 82, 0) -- 879
			) -- 879
		end -- 879
		local bedTopY = h * 0.27 - sitLiftY -- 884
		local dipX = w * 0.52 + panX * 0.7 -- 885
		local pressDepth = 22 * handPress -- 886
		uiDraw:drawPolygon( -- 888
			{ -- 888
				Vec2(0, 0), -- 889
				Vec2(w, 0), -- 890
				Vec2(w, bedTopY + 10), -- 891
				Vec2(dipX + 110, bedTopY + 6), -- 892
				Vec2(dipX + 38, bedTopY - pressDepth * 0.85), -- 893
				Vec2(dipX - 34, bedTopY - pressDepth), -- 894
				Vec2(dipX - 108, bedTopY + 5), -- 895
				Vec2(0, bedTopY + 12) -- 896
			}, -- 896
			Color( -- 897
				30, -- 897
				27, -- 897
				32, -- 897
				math.floor(248 * eyeOpen * fadeOut + 0.5) -- 897
			) -- 897
		) -- 897
		uiInkDraw:drawSegment( -- 900
			Vec2(dipX - 96, bedTopY + 4), -- 901
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 902
			1.6, -- 903
			Color( -- 904
				124, -- 904
				114, -- 904
				102, -- 904
				math.floor(145 * eyeOpen * fadeOut + 0.5) -- 904
			) -- 904
		) -- 904
		uiInkDraw:drawSegment( -- 906
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 907
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 908
			1.4, -- 909
			Color( -- 910
				92, -- 910
				82, -- 910
				74, -- 910
				math.floor(165 * eyeOpen * fadeOut + 0.5) -- 910
			) -- 910
		) -- 910
		uiInkDraw:drawSegment( -- 912
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 913
			Vec2(dipX + 106, bedTopY + 5), -- 914
			1.5, -- 915
			Color( -- 916
				138, -- 916
				122, -- 916
				106, -- 916
				math.floor(140 * eyeOpen * fadeOut + 0.5) -- 916
			) -- 916
		) -- 916
		if handPress > 0.02 then -- 916
			local hx = dipX -- 921
			local hy = bedTopY - pressDepth + 14 -- 922
			local ha = math.floor(245 * handPress * fadeOut + 0.5) -- 923
			uiDraw:drawPolygon( -- 925
				{ -- 925
					Vec2(hx - 62, hy + 135), -- 926
					Vec2(hx - 14, hy + 142), -- 927
					Vec2(hx + 8, hy + 28), -- 928
					Vec2(hx - 36, hy + 24) -- 929
				}, -- 929
				Color(42, 46, 54, ha) -- 930
			) -- 930
			uiDraw:drawPolygon( -- 932
				{ -- 932
					Vec2(hx - 38, hy + 26), -- 933
					Vec2(hx + 16, hy + 28), -- 934
					Vec2(hx + 34, hy + 2), -- 935
					Vec2(hx + 22, hy - 14), -- 936
					Vec2(hx - 26, hy - 12), -- 937
					Vec2(hx - 42, hy + 4) -- 938
				}, -- 938
				Color(148, 112, 86, ha) -- 939
			) -- 939
			local f = 0 -- 941
			do -- 941
				f = 0 -- 942
				while f < 3 do -- 942
					local fx = hx - 16 + f * 15 -- 943
					uiInkDraw:drawSegment( -- 944
						Vec2(fx, hy + 10), -- 944
						Vec2(fx + 2, hy - 11), -- 944
						1.4, -- 944
						Color(68, 46, 36, ha) -- 944
					) -- 944
					f = f + 1 -- 942
				end -- 942
			end -- 942
			uiInkDraw:drawSegment( -- 946
				Vec2(hx - 34, hy + 22), -- 947
				Vec2(hx + 24, hy + 12), -- 948
				1.8, -- 949
				Color( -- 950
					214, -- 950
					168, -- 950
					126, -- 950
					math.floor(175 * handPress * fireFlicker * fadeOut + 0.5) -- 950
				) -- 950
			) -- 950
		end -- 950
	end -- 950
	local lidH = h * 0.52 * (1 - eyeOpen) -- 956
	if lidH > 1 then -- 956
		uiDraw:drawRect( -- 958
			Rect(0, h - lidH, w, lidH), -- 958
			Color(5, 6, 9, 255) -- 958
		) -- 958
		uiDraw:drawRect( -- 959
			Rect(0, 0, w, lidH), -- 959
			Color(5, 6, 9, 255) -- 959
		) -- 959
		local feather = math.min(46, h * 0.08) -- 960
		fillVGradRect( -- 961
			uiDraw, -- 961
			0, -- 961
			h - lidH - feather, -- 961
			w, -- 961
			feather, -- 961
			Color(5, 6, 9, 0), -- 961
			Color(5, 6, 9, 235) -- 961
		) -- 961
		fillVGradRect( -- 962
			uiDraw, -- 962
			0, -- 962
			lidH, -- 962
			w, -- 962
			feather, -- 962
			Color(5, 6, 9, 235), -- 962
			Color(5, 6, 9, 0) -- 962
		) -- 962
	end -- 962
	local callAlpha = smoothstep(0.1, 0.32, t) * (1 - smoothstep(1.05, 1.55, t)) -- 966
	if callAlpha > 0.02 then -- 966
		drawSilkVeil( -- 968
			uiDraw, -- 968
			uiArt, -- 968
			"p01_call_veil", -- 968
			w * 0.5, -- 968
			h * 0.14, -- 968
			240, -- 968
			44, -- 968
			PALETTE.inkWash, -- 968
			0.72 * callAlpha, -- 968
			0 -- 968
		) -- 968
		ctx.texts:put( -- 969
			"sm", -- 970
			"「小满。」", -- 971
			w * 0.5, -- 972
			h * 0.14, -- 973
			toColor(PALETTE.textBright), -- 974
			0.5, -- 975
			0.5, -- 976
			"Center", -- 977
			2, -- 978
			callAlpha, -- 979
			0.08 -- 980
		) -- 980
	end -- 980
end -- 795
function PrologueIntroPlugin.prototype.drawP02ShadowAndBowl(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 987
	local w = ctx.uiW -- 993
	local h = ctx.uiH -- 994
	local t = self.stageElapsed -- 995
	local fireFlicker = 0.85 + 0.15 * math.sin(t * 14) -- 996
	local floorY = h * 0.25 -- 999
	fillVGradRect( -- 1000
		uiDraw, -- 1000
		0, -- 1000
		floorY, -- 1000
		w, -- 1000
		h - floorY, -- 1000
		Color(38, 30, 28, 255), -- 1000
		Color(20, 18, 24, 255) -- 1000
	) -- 1000
	fillVGradRect( -- 1001
		uiDraw, -- 1001
		0, -- 1001
		0, -- 1001
		w, -- 1001
		floorY, -- 1001
		Color(12, 12, 16, 255), -- 1001
		Color(28, 24, 24, 255) -- 1001
	) -- 1001
	local row = 1 -- 1004
	do -- 1004
		row = 1 -- 1005
		while row <= 6 do -- 1005
			local ry = floorY + (h - floorY) * (row / 7) -- 1006
			uiInkDraw:drawSegment( -- 1007
				Vec2(0, ry), -- 1007
				Vec2(w, ry), -- 1007
				0.9, -- 1007
				Color(18, 16, 20, 110) -- 1007
			) -- 1007
			row = row + 1 -- 1005
		end -- 1005
	end -- 1005
	fillRadialGlow( -- 1011
		uiGlow, -- 1012
		w * 0.12, -- 1013
		floorY + h * 0.28, -- 1014
		w * 0.52, -- 1015
		h * 0.44, -- 1016
		Color( -- 1017
			198, -- 1017
			116, -- 1017
			56, -- 1017
			math.floor(78 * fireFlicker + 0.5) -- 1017
		), -- 1017
		Color(120, 50, 24, 0), -- 1018
		18 -- 1019
	) -- 1019
	local cutProg = smoothstep(0.62, 1.05, t) -- 1023
	local tremble = math.sin(t * 18) * 3 -- 1024
	local p1X = w * 0.42 + tremble -- 1025
	local p2X = w * 0.56 - tremble * 0.6 -- 1026
	local parentDrop = cutProg * 36 -- 1027
	uiDraw:drawPolygon( -- 1029
		{ -- 1029
			Vec2(p1X - 42, floorY), -- 1030
			Vec2(p1X + 34, floorY), -- 1031
			Vec2(p1X + 26 + cutProg * 26, floorY + 218 - parentDrop), -- 1032
			Vec2(p1X - 28 + cutProg * 14, floorY + 226 - parentDrop) -- 1033
		}, -- 1033
		Color(10, 9, 13, 215) -- 1034
	) -- 1034
	uiDraw:drawCircle( -- 1035
		Vec2(p1X + cutProg * 20, floorY + 248 - parentDrop), -- 1035
		24, -- 1035
		Color(10, 9, 13, 215) -- 1035
	) -- 1035
	uiDraw:drawPolygon( -- 1037
		{ -- 1037
			Vec2(p2X - 36, floorY), -- 1038
			Vec2(p2X + 32, floorY), -- 1039
			Vec2(p2X + 20 + cutProg * 32, floorY + 186 - parentDrop * 0.8), -- 1040
			Vec2(p2X - 24 + cutProg * 18, floorY + 194 - parentDrop * 0.8) -- 1041
		}, -- 1041
		Color(11, 10, 14, 205) -- 1042
	) -- 1042
	uiDraw:drawCircle( -- 1043
		Vec2(p2X - 2 + cutProg * 26, floorY + 214 - parentDrop * 0.8), -- 1043
		21, -- 1043
		Color(11, 10, 14, 205) -- 1043
	) -- 1043
	if cutProg > 0.01 then -- 1043
		local sx = w * (0.02 + cutProg * 0.46) -- 1047
		uiDraw:drawPolygon( -- 1048
			{ -- 1048
				Vec2(0, floorY), -- 1049
				Vec2(sx + 58, floorY), -- 1050
				Vec2(sx + 135, h), -- 1051
				Vec2(0, h) -- 1052
			}, -- 1052
			Color( -- 1053
				6, -- 1053
				6, -- 1053
				10, -- 1053
				math.floor(238 * cutProg + 0.5) -- 1053
			) -- 1053
		) -- 1053
		uiDraw:drawPolygon( -- 1055
			{ -- 1055
				Vec2(sx + 20, floorY + 160), -- 1056
				Vec2(sx + 275 * cutProg, floorY + 260), -- 1057
				Vec2(sx + 268 * cutProg, floorY + 276), -- 1058
				Vec2(sx + 14, floorY + 178) -- 1059
			}, -- 1059
			Color( -- 1060
				5, -- 1060
				5, -- 1060
				8, -- 1060
				math.floor(235 * cutProg + 0.5) -- 1060
			) -- 1060
		) -- 1060
	end -- 1060
	local threshX = w * 0.66 -- 1064
	uiDraw:drawRect( -- 1065
		Rect(threshX, floorY - 22, 26, 30), -- 1065
		Color(54, 38, 28, 255), -- 1065
		1.2, -- 1065
		Color(112, 86, 62, 210) -- 1065
	) -- 1065
	uiInkDraw:drawSegment( -- 1066
		Vec2(threshX, floorY + 8), -- 1066
		Vec2(threshX + 26, floorY + 8), -- 1066
		1.6, -- 1066
		Color(156, 128, 96, 200) -- 1066
	) -- 1066
	local rollK = smoothstep(0.98, 1.85, t) -- 1069
	if t >= 0.96 then -- 1069
		local startX = w * 0.14 -- 1071
		local stopX = threshX - 18 -- 1072
		local bx = startX + (stopX - startX) * rollK -- 1073
		local bounce = rollK < 1 and math.abs(math.sin(rollK * math.pi * 3.5)) * (1 - rollK) * 18 or 0 -- 1074
		local by = floorY + 8 + bounce -- 1075
		local tilt = rollK * math.pi * 3.2 -- 1076
		local br = 16 -- 1077
		uiDraw:drawEllipse( -- 1080
			Vec2(bx, floorY + 2), -- 1080
			18, -- 1080
			4.5, -- 1080
			Color(6, 6, 10, 175) -- 1080
		) -- 1080
		uiDraw:drawCircle( -- 1082
			Vec2(bx, by), -- 1082
			br, -- 1082
			Color(168, 164, 152, 245) -- 1082
		) -- 1082
		uiDraw:drawEllipse( -- 1083
			Vec2( -- 1084
				bx + math.cos(tilt) * 4, -- 1084
				by + math.sin(tilt) * 4 -- 1084
			), -- 1084
			br * 0.72, -- 1085
			br * 0.36, -- 1086
			Color(64, 60, 56, 235) -- 1087
		) -- 1087
		uiInkDraw:drawArc( -- 1090
			Vec2(bx, by), -- 1090
			br - 1, -- 1090
			20, -- 1090
			155, -- 1090
			1.5, -- 1090
			Color(224, 222, 214, 215) -- 1090
		) -- 1090
		if t >= 1.84 then -- 1090
			local impact = 1 - smoothstep(1.84, 2, t) -- 1092
			if impact > 0.02 then -- 1092
				uiInkDraw:drawSegment( -- 1094
					Vec2(threshX - 2, floorY + 8), -- 1095
					Vec2(threshX - 14 - (1 - impact) * 12, floorY + 18 + (1 - impact) * 8), -- 1096
					1.4, -- 1097
					Color( -- 1098
						220, -- 1098
						210, -- 1098
						194, -- 1098
						math.floor(210 * impact + 0.5) -- 1098
					) -- 1098
				) -- 1098
			end -- 1098
		end -- 1098
	end -- 1098
	local wobble = math.sin(t * 11) * 5 -- 1105
	uiDraw:drawRect( -- 1106
		Rect(w - 72 + wobble * 0.3, floorY, 64, 142), -- 1106
		Color(42, 30, 24, 250), -- 1106
		1.1, -- 1106
		Color(94, 72, 54, 180) -- 1106
	) -- 1106
	uiInkDraw:drawSegment( -- 1107
		Vec2(w - 70 + wobble, floorY + 6), -- 1107
		Vec2(w - 70 + wobble, floorY + 136), -- 1107
		2, -- 1107
		Color(146, 118, 88, 185) -- 1107
	) -- 1107
	uiDraw:drawRect( -- 1110
		Rect(0, h - 46, w, 46), -- 1110
		Color(6, 8, 12, 244) -- 1110
	) -- 1110
	uiDraw:drawRect( -- 1111
		Rect(0, 0, w, 46), -- 1111
		Color(6, 8, 12, 244) -- 1111
	) -- 1111
end -- 987
function PrologueIntroPlugin.prototype.drawP02EscapeVignette(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1116
	local w = ctx.uiW -- 1122
	local h = ctx.uiH -- 1123
	local a = clamp01(self.vignetteAlpha) -- 1124
	if a > 0.005 then -- 1124
		local edgeX = w * (0.09 + 0.06 * a) -- 1127
		local edgeY = h * (0.11 + 0.07 * a) -- 1128
		local peakA = math.floor(168 * a + 0.5) -- 1129
		local deep = PALETTE.crimsonDeep -- 1130
		local rouge = PALETTE.rouge -- 1131
		local cEdge = Color(deep.r, deep.g, deep.b, peakA) -- 1132
		local cZero = Color(deep.r, deep.g, deep.b, 0) -- 1133
		fillHGradRect( -- 1135
			uiDraw, -- 1135
			0, -- 1135
			0, -- 1135
			edgeX, -- 1135
			h, -- 1135
			cEdge, -- 1135
			cZero -- 1135
		) -- 1135
		fillHGradRect( -- 1136
			uiDraw, -- 1136
			w - edgeX, -- 1136
			0, -- 1136
			edgeX, -- 1136
			h, -- 1136
			cZero, -- 1136
			cEdge -- 1136
		) -- 1136
		fillVGradRect( -- 1137
			uiDraw, -- 1137
			0, -- 1137
			0, -- 1137
			w, -- 1137
			edgeY, -- 1137
			cEdge, -- 1137
			cZero -- 1137
		) -- 1137
		fillVGradRect( -- 1138
			uiDraw, -- 1138
			0, -- 1138
			h - edgeY, -- 1138
			w, -- 1138
			edgeY, -- 1138
			cZero, -- 1138
			cEdge -- 1138
		) -- 1138
		if self.heartbeatPulse > 0.02 then -- 1138
			local pa = math.floor(62 * self.heartbeatPulse * a + 0.5) -- 1142
			local cPulse = Color(rouge.r, rouge.g, rouge.b, pa) -- 1143
			local cPulseZero = Color(rouge.r, rouge.g, rouge.b, 0) -- 1144
			fillHGradRect( -- 1145
				uiGlow, -- 1145
				0, -- 1145
				0, -- 1145
				edgeX * 0.72, -- 1145
				h, -- 1145
				cPulse, -- 1145
				cPulseZero -- 1145
			) -- 1145
			fillHGradRect( -- 1146
				uiGlow, -- 1146
				w - edgeX * 0.72, -- 1146
				0, -- 1146
				edgeX * 0.72, -- 1146
				h, -- 1146
				cPulseZero, -- 1146
				cPulse -- 1146
			) -- 1146
		end -- 1146
	end -- 1146
	if self.rehearsalActive then -- 1146
		local groundY = h * 0.24 -- 1152
		local doorX = w * 0.14 -- 1153
		local cabX = w * 0.8 -- 1154
		local childX = doorX + (cabX - doorX) * self.escapePlayerX -- 1155
		local wobble = math.sin(self.stageElapsed * 9.5) * 4 -- 1156
		uiInkDraw:drawRect( -- 1159
			Rect(doorX - 18, groundY, 16, 130), -- 1159
			Color(48, 36, 28, 220) -- 1159
		) -- 1159
		uiDraw:drawCircle( -- 1160
			Vec2(doorX + 18, groundY + 8), -- 1160
			8, -- 1160
			Color(168, 164, 152, 220) -- 1160
		) -- 1160
		uiDraw:drawRect( -- 1162
			Rect(cabX, groundY, 74, 108), -- 1162
			Color(42, 31, 24, 240), -- 1162
			1.2, -- 1162
			Color(118, 92, 68, 195) -- 1162
		) -- 1162
		uiInkDraw:drawSegment( -- 1163
			Vec2(cabX + 8 + wobble * 0.5, groundY + 6), -- 1163
			Vec2(cabX + 8 + wobble * 0.5, groundY + 100), -- 1163
			2.2, -- 1163
			Color(176, 144, 106, 210) -- 1163
		) -- 1163
		if not ctx.uiArt:tryPlaceRun( -- 1163
			"child", -- 1165
			"p02_escape_child", -- 1165
			childX, -- 1165
			groundY, -- 1165
			46, -- 1165
			74, -- 1165
			self.stageElapsed * 1.8, -- 1165
			{facing = 1, layer = 3} -- 1165
		) then -- 1165
			uiDraw:drawRect( -- 1169
				Rect(childX - 12, groundY, 24, 54), -- 1169
				Color(168, 72, 54, 235) -- 1169
			) -- 1169
		end -- 1169
	end -- 1169
end -- 1116
function PrologueIntroPlugin.prototype.drawP02HiddenCabinet(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1176
	local w = ctx.uiW -- 1182
	local h = ctx.uiH -- 1183
	local t = self.stageElapsed -- 1184
	local closeK = smoothstep(0, 0.26, t) -- 1185
	local slitW = w * (0.28 - 0.21 * closeK) -- 1188
	local leftW = (w - slitW) * 0.5 -- 1189
	uiDraw:drawRect( -- 1190
		Rect(0, 0, leftW, h), -- 1190
		Color(7, 7, 10, 248) -- 1190
	) -- 1190
	uiDraw:drawRect( -- 1191
		Rect(w - leftW, 0, leftW, h), -- 1191
		Color(7, 7, 10, 248) -- 1191
	) -- 1191
	uiInkDraw:drawSegment( -- 1192
		Vec2(leftW, 0), -- 1192
		Vec2(leftW, h), -- 1192
		1.4, -- 1192
		Color(66, 52, 40, 175) -- 1192
	) -- 1192
	uiInkDraw:drawSegment( -- 1193
		Vec2(w - leftW, 0), -- 1193
		Vec2(w - leftW, h), -- 1193
		1.4, -- 1193
		Color(66, 52, 40, 175) -- 1193
	) -- 1193
	local footFade = 1 - smoothstep(0.3, 0.8, t) -- 1196
	if footFade > 0.02 then -- 1196
		local shadowX = w * 0.5 + (1 - footFade) * 38 -- 1198
		fillRadialGlow( -- 1199
			uiGlow, -- 1200
			shadowX, -- 1201
			h * 0.42, -- 1202
			32, -- 1203
			90, -- 1204
			Color( -- 1205
				148, -- 1205
				168, -- 1205
				184, -- 1205
				math.floor(32 * footFade + 0.5) -- 1205
			), -- 1205
			Color(90, 110, 130, 0), -- 1206
			12 -- 1207
		) -- 1207
	end -- 1207
	if self.vignetteAlpha > 0.005 then -- 1207
		local a = math.floor(140 * self.vignetteAlpha + 0.5) -- 1213
		local edge = w * 0.08 -- 1214
		fillHGradRect( -- 1215
			uiDraw, -- 1215
			0, -- 1215
			0, -- 1215
			edge, -- 1215
			h, -- 1215
			Color(124, 38, 42, a), -- 1215
			Color(124, 38, 42, 0) -- 1215
		) -- 1215
		fillHGradRect( -- 1216
			uiDraw, -- 1216
			w - edge, -- 1216
			0, -- 1216
			edge, -- 1216
			h, -- 1216
			Color(124, 38, 42, 0), -- 1216
			Color(124, 38, 42, a) -- 1216
		) -- 1216
	end -- 1216
end -- 1176
function PrologueIntroPlugin.prototype.drawP04WorldAction(self, fgDraw, fgGlow, ctx) -- 1222
	local p = ctx.p -- 1227
	local cam = ctx.cam -- 1228
	local flash = self.p04FlashIntensity -- 1229
	local hintAlpha = self.p04PostHintAlpha -- 1230
	local zhou = p.childMode and p.partner or p.player -- 1232
	local xiao = p.childMode and p.player or p.partner -- 1233
	local zX = cam:sx(zhou.x) -- 1234
	local zY = cam:sy(zhou.y, zhou.depth) -- 1235
	local zH = cam:len(zhou.h) -- 1236
	local xX = cam:sx(xiao.x) -- 1237
	local xY = cam:sy(xiao.y, xiao.depth) -- 1238
	local xH = cam:len(xiao.h) -- 1239
	if flash > 0.01 then -- 1239
		fillGradQuad( -- 1244
			fgGlow, -- 1245
			cam.viewW, -- 1246
			cam.groundScreenY + cam:len(18), -- 1246
			Color( -- 1246
				238, -- 1246
				178, -- 1246
				108, -- 1246
				math.floor(96 * flash + 0.5) -- 1246
			), -- 1246
			cam.viewW, -- 1247
			cam.groundScreenY + cam:len(195), -- 1247
			Color( -- 1247
				224, -- 1247
				148, -- 1247
				82, -- 1247
				math.floor(72 * flash + 0.5) -- 1247
			), -- 1247
			zX - cam:len(140), -- 1248
			cam.groundScreenY + cam:len(140), -- 1248
			Color(200, 120, 62, 0), -- 1248
			zX - cam:len(140), -- 1249
			cam.groundScreenY, -- 1249
			Color(200, 120, 62, 0) -- 1249
		) -- 1249
		local wallBaseY = cam.groundScreenY + cam:len(14) -- 1253
		local shAlpha = math.floor(148 * flash + 0.5) -- 1254
		local shCol = Color(8, 10, 14, shAlpha) -- 1255
		fgDraw:drawPolygon( -- 1257
			{ -- 1257
				Vec2( -- 1258
					zX - cam:len(14), -- 1258
					wallBaseY -- 1258
				), -- 1258
				Vec2( -- 1259
					zX + cam:len(6), -- 1259
					wallBaseY -- 1259
				), -- 1259
				Vec2( -- 1260
					zX - cam:len(38), -- 1260
					wallBaseY + zH * 1.18 -- 1260
				), -- 1260
				Vec2( -- 1261
					zX - cam:len(64), -- 1261
					wallBaseY + zH * 1.12 -- 1261
				) -- 1261
			}, -- 1261
			shCol -- 1262
		) -- 1262
		fgDraw:drawPolygon( -- 1264
			{ -- 1264
				Vec2( -- 1265
					xX - cam:len(10), -- 1265
					wallBaseY -- 1265
				), -- 1265
				Vec2( -- 1266
					xX + cam:len(6), -- 1266
					wallBaseY -- 1266
				), -- 1266
				Vec2( -- 1267
					xX - cam:len(26), -- 1267
					wallBaseY + xH * 1.12 -- 1267
				), -- 1267
				Vec2( -- 1268
					xX - cam:len(44), -- 1268
					wallBaseY + xH * 1.06 -- 1268
				) -- 1268
			}, -- 1268
			shCol -- 1269
		) -- 1269
		local shieldK = smoothstep(0.1, 0.24, self.p04Elapsed) * (1 - smoothstep(0.5, 0.78, self.p04Elapsed)) -- 1272
		if shieldK > 0.02 then -- 1272
			local armX = zX + cam:len(10) -- 1274
			local armY = zY + zH * 0.66 -- 1275
			local cuffW = cam:len(13) -- 1276
			local cuffH = cam:len(7) -- 1277
			local sa = math.floor(235 * shieldK + 0.5) -- 1278
			fgDraw:drawPolygon( -- 1279
				{ -- 1279
					Vec2( -- 1280
						zX + cam:len(2), -- 1280
						armY - cuffH * 0.4 -- 1280
					), -- 1280
					Vec2(armX + cuffW, armY + cuffH * 0.9), -- 1281
					Vec2(armX + cuffW * 0.72, armY + cuffH * 1.75), -- 1282
					Vec2( -- 1283
						zX - cam:len(2), -- 1283
						armY + cuffH * 0.5 -- 1283
					) -- 1283
				}, -- 1283
				toColor(____exports.CUFF_SHARED_SPEC.indigoCloth, sa) -- 1284
			) -- 1284
			fgDraw:drawSegment( -- 1286
				Vec2(armX + cuffW * 0.45, armY + cuffH * 0.75), -- 1287
				Vec2(armX + cuffW * 0.82, armY + cuffH * 1.25), -- 1288
				1.3, -- 1289
				toColor( -- 1290
					____exports.CUFF_SHARED_SPEC.mendStitch, -- 1290
					math.floor(210 * shieldK + 0.5) -- 1290
				) -- 1290
			) -- 1290
			fillGradQuad( -- 1293
				fgDraw, -- 1294
				zX + cam:len(4), -- 1295
				zY + zH * 0.85, -- 1295
				Color( -- 1295
					10, -- 1295
					12, -- 1295
					18, -- 1295
					math.floor(92 * shieldK + 0.5) -- 1295
				), -- 1295
				zX + cam:len(4), -- 1296
				zY, -- 1296
				Color( -- 1296
					10, -- 1296
					12, -- 1296
					18, -- 1296
					math.floor(62 * shieldK + 0.5) -- 1296
				), -- 1296
				xX - cam:len(18), -- 1297
				xY, -- 1297
				Color(10, 12, 18, 0), -- 1297
				xX - cam:len(18), -- 1298
				xY + xH, -- 1298
				Color(10, 12, 18, 0) -- 1298
			) -- 1298
		end -- 1298
	end -- 1298
	if hintAlpha > 0.02 then -- 1298
		local baseWx = self.p04AnchorWorldX > 0 and self.p04AnchorWorldX or zhou.x -- 1305
		local hintBaseX = cam:sx(baseWx + 74) -- 1306
		local groundY = cam:sy(0, 0) -- 1307
		local boardY = groundY + cam:len(34) -- 1308
		local boardW = cam:len(62) -- 1309
		local sheenBoost = flash * 0.55 -- 1310
		local aNorm = clamp01(hintAlpha + sheenBoost) -- 1311
		fgDraw:drawRect( -- 1314
			Rect( -- 1315
				hintBaseX, -- 1315
				boardY, -- 1315
				boardW, -- 1315
				cam:len(12) -- 1315
			), -- 1315
			Color( -- 1316
				54, -- 1316
				42, -- 1316
				32, -- 1316
				math.floor(165 * aNorm + 0.5) -- 1316
			), -- 1316
			1, -- 1317
			Color( -- 1318
				126, -- 1318
				102, -- 1318
				76, -- 1318
				math.floor(150 * aNorm + 0.5) -- 1318
			) -- 1318
		) -- 1318
		fgDraw:drawSegment( -- 1320
			Vec2(hintBaseX + 2, boardY + 1), -- 1321
			Vec2(hintBaseX + boardW - 2, boardY + 1), -- 1322
			2, -- 1323
			Color( -- 1324
				214, -- 1324
				198, -- 1324
				168, -- 1324
				math.floor(215 * aNorm + 0.5) -- 1324
			) -- 1324
		) -- 1324
		local grooveX0 = hintBaseX - cam:len(18) -- 1328
		local grooveX1 = hintBaseX + boardW + cam:len(26) -- 1329
		fgDraw:drawRect( -- 1330
			Rect( -- 1331
				grooveX0, -- 1331
				groundY + 1, -- 1331
				grooveX1 - grooveX0, -- 1331
				cam:len(4) -- 1331
			), -- 1331
			Color( -- 1332
				22, -- 1332
				26, -- 1332
				32, -- 1332
				math.floor(170 * aNorm + 0.5) -- 1332
			) -- 1332
		) -- 1332
		fgDraw:drawSegment( -- 1334
			Vec2( -- 1335
				grooveX0 + 4, -- 1335
				groundY + cam:len(5) -- 1335
			), -- 1335
			Vec2( -- 1336
				grooveX1 - 4, -- 1336
				groundY + cam:len(5) -- 1336
			), -- 1336
			1.6, -- 1337
			Color( -- 1338
				196, -- 1338
				204, -- 1338
				210, -- 1338
				math.floor(195 * aNorm + 0.5) -- 1338
			) -- 1338
		) -- 1338
	end -- 1338
end -- 1222
return ____exports -- 1222