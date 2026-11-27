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
		elseif (phase == "prologue-wait" or phase == "prologue-give" or phase == "prologue-follow") and (self.stage == "p01_wake" or self.stage == "p02_shadow" or self.stage == "p02_escape" or self.stage == "p02_hidden") then -- 484
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
			if ename == "prologueBeat" and ev.data.beat == "escapeRetry" and self.stage == "p02_escape" then -- 503
				self:retryEscape() -- 505
			elseif ename == "p04WallFlash" or ename == "wallPeekFlash" then -- 505
				if not self.p04TriggeredOnce and p.run.story.segments.p04_wall_flash ~= true then -- 505
					p.run.story.segments.p04_wall_flash = true -- 508
					self:triggerP04(p.player.x, p.player.y) -- 509
				end -- 509
			end -- 509
			i = i + 1 -- 501
		end -- 501
	end -- 501
	if not self.p04TriggeredOnce and p.run.story.segments.p04_wall_flash ~= true and not p.childMode and p.player.alive and p.partner.alive then -- 501
		local inPrologueCourtyard = p.room.key == "prologue" and p.phase == "prologue-follow" and p.player.x >= p.ox + 470 and p.player.x <= p.ox + 635 -- 516
		local inStreetWallRoot = p.room.key == "street" and p.player.x >= p.ox + 115 and p.player.x <= p.ox + 265 and self:hasAliveEnemy(p) -- 519
		local inS1WellRoot = p.room.key == "s1-crossroad" and p.player.x >= p.ox + 185 and p.player.x <= p.ox + 320 -- 522
		if inPrologueCourtyard or inStreetWallRoot or inS1WellRoot then -- 522
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
			if p.enemies[i + 1].alive then -- 533
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
	if not self.fireLoopActive then -- 543
		self.fireLoopActive = true -- 546
		ctx.audio:playLoop( -- 547
			"fe03_night_fire", -- 547
			"ambience", -- 547
			PROLOGUE_AUDIO.nightFire, -- 547
			0.34, -- 547
			tick -- 547
		) -- 547
	end -- 547
	if self.stageElapsed >= 0.12 then -- 547
		ctx.audio:playOnce( -- 550
			self:cueKey("p01_father_call"), -- 551
			"voice", -- 552
			PROLOGUE_AUDIO.fatherWake, -- 553
			0.92, -- 554
			"prologue:p01_call", -- 555
			tick -- 556
		) -- 556
	end -- 556
	if self.stageElapsed >= 1.9 then -- 556
		ctx.audio:playOnce( -- 560
			self:cueKey("p01_bed_press"), -- 561
			"sfx", -- 562
			PROLOGUE_AUDIO.bedCreak, -- 563
			0.68, -- 564
			"prologue:p01_bed_press", -- 565
			tick -- 566
		) -- 566
	end -- 566
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p01Duration then -- 566
		if self.rehearsalSequence then -- 566
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 572
		elseif self.rehearsalActive then -- 572
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
	if self.stageElapsed >= 0.08 then -- 585
		ctx.audio:playOnce( -- 588
			self:cueKey("p02_door_commotion"), -- 589
			"ambience", -- 590
			PROLOGUE_AUDIO.doorCommotion, -- 591
			0.62, -- 592
			"prologue:p02_commotion", -- 593
			tick -- 594
		) -- 594
	end -- 594
	if self.stageElapsed >= 0.65 then -- 594
		ctx.audio:playOnce( -- 598
			self:cueKey("p02_shadow_strike"), -- 599
			"sfx", -- 600
			PROLOGUE_AUDIO.shadowStrike, -- 601
			0.85, -- 602
			"prologue:p02_shadow_cut", -- 603
			tick -- 604
		) -- 604
	end -- 604
	if self.stageElapsed >= 1.02 then -- 604
		ctx.audio:playOnce( -- 608
			self:cueKey("p02_bowl_roll"), -- 609
			"sfx", -- 610
			PROLOGUE_AUDIO.bowlRoll, -- 611
			0.76, -- 612
			"prologue:p02_bowl_roll", -- 613
			tick -- 614
		) -- 614
	end -- 614
	if self.stageElapsed >= 1.85 then -- 614
		ctx.audio:playOnce( -- 618
			self:cueKey("p02_bowl_hit"), -- 619
			"sfx", -- 620
			PROLOGUE_AUDIO.bowlHit, -- 621
			0.9, -- 622
			"prologue:p02_bowl_hit", -- 623
			tick -- 624
		) -- 624
	end -- 624
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02ShadowDuration then -- 624
		if self.rehearsalActive then -- 624
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
	if not self.rehearsalActive and liveRemain ~= nil then -- 644
		self.escapeRemaining = math.max(0, liveRemain) -- 646
	else -- 646
		self.escapeRemaining = math.max(0, self.escapeRemaining - dt) -- 648
	end -- 648
	if self.rehearsalActive then -- 648
		if ctx.input.moveX ~= 0 then -- 648
			self.escapePlayerX = clamp01(self.escapePlayerX + ctx.input.moveX * dt * 0.34) -- 654
		end -- 654
		if self.escapePlayerX >= 0.85 and ctx.input.interact.pressed or self.escapePlayerX >= 0.98 then -- 654
			self:enterHiddenCabinet() -- 657
			return -- 658
		end -- 658
	end -- 658
	if self.escapeRemaining <= 0 and (self.rehearsalActive or liveRemain == nil) then -- 658
		self:retryEscape() -- 664
		return -- 665
	end -- 665
	local urgency = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 668
	self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + urgency * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 669
	local prevCycle = math.floor(self.heartbeatPhase) -- 672
	self.heartbeatPhase = self.heartbeatPhase + dt * self.heartbeatHz -- 673
	local currCycle = math.floor(self.heartbeatPhase) -- 674
	if currCycle > prevCycle then -- 674
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
		if frac >= 0.2 and frac <= 0.28 then -- 688
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
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut then -- 709
		self.vignetteAlpha = 0 -- 714
	else -- 714
		self.vignetteAlpha = self.hiddenStartVignette * (1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 716
	end -- 716
	self.heartbeatHz = 0 -- 719
	self.heartbeatPulse = 0 -- 720
	if self.stageElapsed >= 0.3 then -- 720
		ctx.audio:playOnce( -- 724
			self:cueKey("p02_footsteps_fade"), -- 725
			"sfx", -- 726
			PROLOGUE_AUDIO.footstepsFade, -- 727
			0.65, -- 728
			"prologue:p02_footsteps_fade", -- 729
			tick -- 730
		) -- 730
	end -- 730
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenLinger then -- 730
		self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 735
		self.vignetteAlpha = 0 -- 736
	end -- 736
end -- 699
function PrologueIntroPlugin.prototype.stepP04(self, ctx, dt) -- 740
	if self.p04Elapsed == 0 then -- 740
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
	if self.p04Elapsed >= ____exports.PROLOGUE_TIMINGS.p04FlashDuration then -- 752
		self.p04Elapsed = ____exports.PROLOGUE_TIMINGS.p04FlashDuration -- 754
		self.p04FlashIntensity = 0 -- 755
		self.p04Active = false -- 756
		self.p04PostHintAlpha = 0.42 -- 758
	end -- 758
end -- 740
function PrologueIntroPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 763
	if self.stage == "p02_escape" and not self.rehearsalActive and ctx.p.room.key == "prologue" then -- 763
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
	if not self.p04Active and self.p04PostHintAlpha <= 0.01 then -- 790
		return -- 794
	end -- 794
	self:drawP04WorldAction(fgDraw, fgGlow, worldArt, ctx) -- 796
end -- 763
function PrologueIntroPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 800
	if self.stage == "p01_wake" then -- 800
		self:drawP01Wake( -- 808
			uiDraw, -- 808
			uiInkDraw, -- 808
			uiArt, -- 808
			uiGlow, -- 808
			ctx -- 808
		) -- 808
		return true -- 809
	end -- 809
	if self.stage == "p02_shadow" then -- 809
		self:drawP02ShadowAndBowl( -- 812
			uiDraw, -- 812
			uiInkDraw, -- 812
			uiArt, -- 812
			uiGlow, -- 812
			ctx -- 812
		) -- 812
		return true -- 813
	end -- 813
	if self.stage == "p02_escape" then -- 813
		self:drawP02EscapeVignette(uiDraw, uiInkDraw, uiGlow, ctx) -- 816
		return true -- 818
	end -- 818
	if self.stage == "p02_hidden" then -- 818
		self:drawP02HiddenCabinet( -- 821
			uiDraw, -- 821
			uiInkDraw, -- 821
			uiArt, -- 821
			uiGlow, -- 821
			ctx -- 821
		) -- 821
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
	if eyeOpen > 0.01 then -- 849
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
		uiArt:tryPlacePath( -- 866
			"assets/art/tex_diorama_ming.clip|ming_cloth", -- 867
			"p01_canopy_linen", -- 868
			w * 0.5 + panX * 0.45 + math.sin(t * 1.1) * 6, -- 869
			h * 0.62 - sitLiftY * 0.5, -- 870
			w * 1.32, -- 871
			h * 0.84, -- 872
			{ -- 873
				color = Color(74, 62, 54, 255), -- 874
				opacity = 0.44 * eyeOpen * fadeOut, -- 875
				smooth = true, -- 876
				layer = -2 -- 877
			} -- 877
		) -- 877
		fillRadialGlow( -- 881
			uiGlow, -- 882
			w * 0.34 + panX * 0.4, -- 883
			h * 0.62 - sitLiftY, -- 884
			w * 0.42, -- 885
			h * 0.36, -- 886
			Color( -- 887
				186, -- 887
				108, -- 887
				56, -- 887
				math.floor(68 * fireFlicker * eyeOpen * fadeOut + 0.5) -- 887
			), -- 887
			Color(120, 52, 28, 0), -- 888
			18 -- 889
		) -- 889
		local fold = 0 -- 892
		do -- 892
			fold = 0 -- 893
			while fold < 11 do -- 893
				local fx = w * (0.04 + fold * 0.095) + panX * 0.55 + math.sin(t * 1.4 + fold) * 4 -- 894
				local fw = 22 + fold % 3 * 10 -- 895
				local col = fold & 1 == 0 and Color( -- 896
					52, -- 897
					42, -- 897
					36, -- 897
					math.floor(48 * eyeOpen * fadeOut + 0.5) -- 897
				) or Color( -- 897
					24, -- 898
					20, -- 898
					22, -- 898
					math.floor(62 * eyeOpen * fadeOut + 0.5) -- 898
				) -- 898
				fillHGradRect( -- 899
					uiDraw, -- 899
					fx, -- 899
					h * 0.24, -- 899
					fw, -- 899
					h * 0.72, -- 899
					Color(col.r, col.g, col.b, 0), -- 899
					col -- 899
				) -- 899
				fold = fold + 1 -- 893
			end -- 893
		end -- 893
		local doorVis = smoothstep(2.25, 3.2, t) -- 903
		if doorVis > 0.01 then -- 903
			local doorX = w * 0.84 + panX * 0.95 -- 905
			local crackW = 14 + sitPan * 18 -- 906
			local doorBot = h * 0.14 - sitLiftY * 0.4 -- 907
			local doorH = h * 0.72 -- 908
			uiDraw:drawRect( -- 910
				Rect(doorX - 46, doorBot, 46, doorH), -- 910
				Color( -- 910
					14, -- 910
					12, -- 910
					14, -- 910
					math.floor(235 * doorVis * fadeOut + 0.5) -- 910
				) -- 910
			) -- 910
			uiDraw:drawRect( -- 911
				Rect(doorX + crackW, doorBot, 54, doorH), -- 911
				Color( -- 911
					14, -- 911
					12, -- 911
					14, -- 911
					math.floor(235 * doorVis * fadeOut + 0.5) -- 911
				) -- 911
			) -- 911
			fillVGradRect( -- 913
				uiDraw, -- 914
				doorX, -- 915
				doorBot, -- 916
				crackW, -- 917
				doorH, -- 918
				Color( -- 919
					142, -- 919
					168, -- 919
					186, -- 919
					math.floor(170 * doorVis * fadeOut + 0.5) -- 919
				), -- 919
				Color( -- 920
					214, -- 920
					168, -- 920
					118, -- 920
					math.floor(195 * doorVis * fireFlicker * fadeOut + 0.5) -- 920
				) -- 920
			) -- 920
			fillGradQuad( -- 922
				uiGlow, -- 923
				doorX, -- 924
				doorBot, -- 924
				Color( -- 924
					164, -- 924
					188, -- 924
					204, -- 924
					math.floor(64 * doorVis * fadeOut + 0.5) -- 924
				), -- 924
				doorX + crackW, -- 925
				doorBot, -- 925
				Color( -- 925
					214, -- 925
					164, -- 925
					108, -- 925
					math.floor(54 * doorVis * fadeOut + 0.5) -- 925
				), -- 925
				doorX - 135, -- 926
				doorBot - 40, -- 926
				Color(120, 148, 170, 0), -- 926
				doorX - 190, -- 927
				doorBot + doorH * 0.48, -- 927
				Color(180, 130, 82, 0) -- 927
			) -- 927
		end -- 927
		local bedTopY = h * 0.27 - sitLiftY -- 932
		local dipX = w * 0.52 + panX * 0.7 -- 933
		local pressDepth = 22 * handPress -- 934
		uiDraw:drawPolygon( -- 936
			{ -- 936
				Vec2(0, 0), -- 937
				Vec2(w, 0), -- 938
				Vec2(w, bedTopY + 10), -- 939
				Vec2(dipX + 110, bedTopY + 6), -- 940
				Vec2(dipX + 38, bedTopY - pressDepth * 0.85), -- 941
				Vec2(dipX - 34, bedTopY - pressDepth), -- 942
				Vec2(dipX - 108, bedTopY + 5), -- 943
				Vec2(0, bedTopY + 12) -- 944
			}, -- 944
			Color( -- 945
				30, -- 945
				27, -- 945
				32, -- 945
				math.floor(248 * eyeOpen * fadeOut + 0.5) -- 945
			) -- 945
		) -- 945
		uiInkDraw:drawSegment( -- 948
			Vec2(dipX - 96, bedTopY + 4), -- 949
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 950
			1.6, -- 951
			Color( -- 952
				124, -- 952
				114, -- 952
				102, -- 952
				math.floor(145 * eyeOpen * fadeOut + 0.5) -- 952
			) -- 952
		) -- 952
		uiInkDraw:drawSegment( -- 954
			Vec2(dipX - 30, bedTopY - pressDepth + 2), -- 955
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 956
			1.4, -- 957
			Color( -- 958
				92, -- 958
				82, -- 958
				74, -- 958
				math.floor(165 * eyeOpen * fadeOut + 0.5) -- 958
			) -- 958
		) -- 958
		uiInkDraw:drawSegment( -- 960
			Vec2(dipX + 38, bedTopY - pressDepth * 0.85 + 2), -- 961
			Vec2(dipX + 106, bedTopY + 5), -- 962
			1.5, -- 963
			Color( -- 964
				138, -- 964
				122, -- 964
				106, -- 964
				math.floor(140 * eyeOpen * fadeOut + 0.5) -- 964
			) -- 964
		) -- 964
		if handPress > 0.02 then -- 964
			local hx = dipX -- 969
			local hy = bedTopY - pressDepth + 12 -- 970
			local handOp = handPress * fadeOut -- 971
			local warmR = math.floor(218 + 26 * fireFlicker + 0.5) -- 972
			local warmG = math.floor(192 + 18 * fireFlicker + 0.5) -- 973
			local warmB = math.floor(172 + 10 * fireFlicker + 0.5) -- 974
			if not uiArt:tryPlacePath( -- 974
				"assets/art/cutscene_story_parts.clip|prologue_father_hand", -- 976
				"p01_father_hand", -- 977
				hx + 18, -- 978
				hy + 32, -- 979
				360, -- 980
				295, -- 981
				{ -- 982
					anchorX = 0.48, -- 983
					anchorY = 0.36, -- 984
					color = Color(warmR, warmG, warmB, 255), -- 985
					opacity = handOp, -- 986
					smooth = true, -- 987
					layer = 2 -- 988
				} -- 988
			) then -- 988
				local ha = math.floor(245 * handOp + 0.5) -- 991
				uiDraw:drawPolygon( -- 992
					{ -- 992
						Vec2(hx - 62, hy + 135), -- 993
						Vec2(hx - 14, hy + 142), -- 994
						Vec2(hx + 8, hy + 28), -- 995
						Vec2(hx - 36, hy + 24) -- 996
					}, -- 996
					Color(42, 46, 54, ha) -- 997
				) -- 997
				uiDraw:drawPolygon( -- 998
					{ -- 998
						Vec2(hx - 38, hy + 26), -- 999
						Vec2(hx + 16, hy + 28), -- 1000
						Vec2(hx + 34, hy + 2), -- 1001
						Vec2(hx + 22, hy - 14), -- 1002
						Vec2(hx - 26, hy - 12), -- 1003
						Vec2(hx - 42, hy + 4) -- 1004
					}, -- 1004
					Color(148, 112, 86, ha) -- 1005
				) -- 1005
			end -- 1005
		end -- 1005
	end -- 1005
	local lidH = h * 0.52 * (1 - eyeOpen) -- 1011
	if lidH > 1 then -- 1011
		ctx.uiMask:drawRect( -- 1013
			Rect(0, h - lidH, w, lidH), -- 1013
			Color(5, 6, 9, 255) -- 1013
		) -- 1013
		ctx.uiMask:drawRect( -- 1014
			Rect(0, 0, w, lidH), -- 1014
			Color(5, 6, 9, 255) -- 1014
		) -- 1014
		local feather = math.min(46, h * 0.08) -- 1015
		fillVGradRect( -- 1016
			ctx.uiMask, -- 1016
			0, -- 1016
			h - lidH - feather, -- 1016
			w, -- 1016
			feather, -- 1016
			Color(5, 6, 9, 0), -- 1016
			Color(5, 6, 9, 235) -- 1016
		) -- 1016
		fillVGradRect( -- 1017
			ctx.uiMask, -- 1017
			0, -- 1017
			lidH, -- 1017
			w, -- 1017
			feather, -- 1017
			Color(5, 6, 9, 235), -- 1017
			Color(5, 6, 9, 0) -- 1017
		) -- 1017
	end -- 1017
	if self.rehearsalActive then -- 1017
		local callAlpha = smoothstep(0.1, 0.32, t) * (1 - smoothstep(1.05, 1.55, t)) -- 1022
		if callAlpha > 0.02 then -- 1022
			drawSilkVeil( -- 1024
				uiDraw, -- 1024
				uiArt, -- 1024
				"p01_call_veil", -- 1024
				w * 0.5, -- 1024
				h * 0.14, -- 1024
				240, -- 1024
				44, -- 1024
				PALETTE.inkWash, -- 1024
				0.72 * callAlpha, -- 1024
				0 -- 1024
			) -- 1024
			ctx.texts:put( -- 1025
				"sm", -- 1026
				"「小满。」", -- 1027
				w * 0.5, -- 1028
				h * 0.14, -- 1029
				toColor(PALETTE.textBright), -- 1030
				0.5, -- 1031
				0.5, -- 1032
				"Center", -- 1033
				2, -- 1034
				callAlpha, -- 1035
				0.08 -- 1036
			) -- 1036
		end -- 1036
	end -- 1036
end -- 829
function PrologueIntroPlugin.prototype.drawP02ShadowAndBowl(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1044
	local w = ctx.uiW -- 1051
	local h = ctx.uiH -- 1052
	local t = self.stageElapsed -- 1053
	local fireFlicker = 0.85 + 0.15 * math.sin(t * 14) -- 1054
	local floorY = h * 0.25 -- 1057
	fillVGradRect( -- 1058
		uiDraw, -- 1058
		0, -- 1058
		floorY, -- 1058
		w, -- 1058
		h - floorY, -- 1058
		Color(38, 30, 28, 255), -- 1058
		Color(20, 18, 24, 255) -- 1058
	) -- 1058
	fillVGradRect( -- 1059
		uiDraw, -- 1059
		0, -- 1059
		0, -- 1059
		w, -- 1059
		floorY, -- 1059
		Color(12, 12, 16, 255), -- 1059
		Color(28, 24, 24, 255) -- 1059
	) -- 1059
	uiArt:tryPlacePath( -- 1060
		"assets/art/tex_diorama_ming.clip|ming_brick", -- 1060
		"p02_wall_brick_l", -- 1060
		w * 0.25, -- 1060
		floorY + (h - floorY) * 0.5, -- 1060
		w * 0.52, -- 1060
		h - floorY, -- 1060
		{ -- 1060
			color = Color(72, 60, 54, 255), -- 1061
			opacity = 0.52, -- 1062
			smooth = true, -- 1063
			layer = -4 -- 1064
		} -- 1064
	) -- 1064
	uiArt:tryPlacePath( -- 1066
		"assets/art/tex_diorama_ming.clip|ming_brick", -- 1066
		"p02_wall_brick_r", -- 1066
		w * 0.75, -- 1066
		floorY + (h - floorY) * 0.5, -- 1066
		w * 0.52, -- 1066
		h - floorY, -- 1066
		{ -- 1066
			color = Color(64, 54, 50, 255), -- 1067
			opacity = 0.52, -- 1068
			smooth = true, -- 1069
			layer = -4 -- 1070
		} -- 1070
	) -- 1070
	uiArt:tryPlacePath( -- 1072
		"assets/art/tex_diorama_ming.clip|ming_stone", -- 1072
		"p02_floor_stone", -- 1072
		w * 0.5, -- 1072
		floorY * 0.5, -- 1072
		w, -- 1072
		floorY, -- 1072
		{ -- 1072
			color = Color(62, 58, 56, 255), -- 1073
			opacity = 0.48, -- 1074
			smooth = true, -- 1075
			layer = -3 -- 1076
		} -- 1076
	) -- 1076
	fillRadialGlow( -- 1080
		uiGlow, -- 1081
		w * 0.12, -- 1082
		floorY + h * 0.28, -- 1083
		w * 0.52, -- 1084
		h * 0.44, -- 1085
		Color( -- 1086
			198, -- 1086
			116, -- 1086
			56, -- 1086
			math.floor(78 * fireFlicker + 0.5) -- 1086
		), -- 1086
		Color(120, 50, 24, 0), -- 1087
		18 -- 1088
	) -- 1088
	local cutProg = smoothstep(0.62, 1.05, t) -- 1092
	local tremble = math.sin(t * 18) * 3 -- 1093
	local p1X = w * 0.42 + tremble -- 1094
	local p2X = w * 0.56 - tremble * 0.6 -- 1095
	local parentDrop = cutProg * 36 -- 1096
	uiInkDraw:drawPolygon( -- 1097
		{ -- 1097
			Vec2(p1X - 42, floorY), -- 1098
			Vec2(p1X + 34, floorY), -- 1099
			Vec2(p1X + 26 + cutProg * 26, floorY + 218 - parentDrop), -- 1100
			Vec2(p1X - 28 + cutProg * 14, floorY + 226 - parentDrop) -- 1101
		}, -- 1101
		Color(10, 9, 13, 212) -- 1102
	) -- 1102
	uiInkDraw:drawCircle( -- 1103
		Vec2(p1X + cutProg * 20, floorY + 248 - parentDrop), -- 1103
		24, -- 1103
		Color(10, 9, 13, 212) -- 1103
	) -- 1103
	uiInkDraw:drawPolygon( -- 1104
		{ -- 1104
			Vec2(p2X - 36, floorY), -- 1105
			Vec2(p2X + 32, floorY), -- 1106
			Vec2(p2X + 20 + cutProg * 32, floorY + 186 - parentDrop * 0.8), -- 1107
			Vec2(p2X - 24 + cutProg * 18, floorY + 194 - parentDrop * 0.8) -- 1108
		}, -- 1108
		Color(11, 10, 14, 202) -- 1109
	) -- 1109
	uiInkDraw:drawCircle( -- 1110
		Vec2(p2X - 2 + cutProg * 26, floorY + 214 - parentDrop * 0.8), -- 1110
		21, -- 1110
		Color(11, 10, 14, 202) -- 1110
	) -- 1110
	if cutProg > 0.01 then -- 1110
		local sx = w * (0.02 + cutProg * 0.46) -- 1114
		uiInkDraw:drawPolygon( -- 1115
			{ -- 1115
				Vec2(0, floorY), -- 1116
				Vec2(sx + 58, floorY), -- 1117
				Vec2(sx + 135, h), -- 1118
				Vec2(0, h) -- 1119
			}, -- 1119
			Color( -- 1120
				6, -- 1120
				6, -- 1120
				10, -- 1120
				math.floor(234 * cutProg + 0.5) -- 1120
			) -- 1120
		) -- 1120
		uiInkDraw:drawPolygon( -- 1121
			{ -- 1121
				Vec2(sx + 20, floorY + 160), -- 1122
				Vec2(sx + 275 * cutProg, floorY + 260), -- 1123
				Vec2(sx + 268 * cutProg, floorY + 276), -- 1124
				Vec2(sx + 14, floorY + 178) -- 1125
			}, -- 1125
			Color( -- 1126
				5, -- 1126
				5, -- 1126
				8, -- 1126
				math.floor(232 * cutProg + 0.5) -- 1126
			) -- 1126
		) -- 1126
	end -- 1126
	local threshX = w * 0.66 -- 1130
	uiDraw:drawRect( -- 1131
		Rect(threshX, floorY - 22, 26, 30), -- 1131
		Color(54, 38, 28, 255), -- 1131
		1.2, -- 1131
		Color(112, 86, 62, 210) -- 1131
	) -- 1131
	uiInkDraw:drawSegment( -- 1132
		Vec2(threshX, floorY + 8), -- 1132
		Vec2(threshX + 26, floorY + 8), -- 1132
		1.6, -- 1132
		Color(156, 128, 96, 200) -- 1132
	) -- 1132
	local rollK = smoothstep(0.98, 1.85, t) -- 1135
	if t >= 0.96 then -- 1135
		local startX = w * 0.14 -- 1137
		local stopX = threshX - 22 -- 1138
		local bx = startX + (stopX - startX) * rollK -- 1139
		local bounce = rollK < 1 and math.abs(math.sin(rollK * math.pi * 3.5)) * (1 - rollK) * 18 or 0 -- 1140
		local by = floorY + 14 + bounce -- 1141
		uiInkDraw:drawEllipse( -- 1143
			Vec2(bx, floorY + 2), -- 1143
			22, -- 1143
			5.2, -- 1143
			Color(6, 6, 10, 175) -- 1143
		) -- 1143
		if not uiArt:tryPlacePath( -- 1143
			"assets/art/cutscene_story_parts.clip|prologue_bowl_roll", -- 1145
			"p02_rolling_bowl", -- 1146
			bx, -- 1147
			by, -- 1148
			58, -- 1149
			46, -- 1150
			{ -- 1151
				anchorX = 0.5, -- 1152
				anchorY = 0.5, -- 1153
				angle = rollK * 580, -- 1154
				smooth = true, -- 1155
				layer = 5 -- 1156
			} -- 1156
		) then -- 1156
			uiInkDraw:drawCircle( -- 1159
				Vec2(bx, by), -- 1159
				16, -- 1159
				Color(168, 164, 152, 245) -- 1159
			) -- 1159
		end -- 1159
		if t >= 1.84 then -- 1159
			local impact = 1 - smoothstep(1.84, 2, t) -- 1162
			if impact > 0.02 then -- 1162
				uiInkDraw:drawSegment( -- 1164
					Vec2(threshX - 2, floorY + 8), -- 1165
					Vec2(threshX - 14 - (1 - impact) * 12, floorY + 18 + (1 - impact) * 8), -- 1166
					1.4, -- 1167
					Color( -- 1168
						220, -- 1168
						210, -- 1168
						194, -- 1168
						math.floor(210 * impact + 0.5) -- 1168
					) -- 1168
				) -- 1168
			end -- 1168
		end -- 1168
	end -- 1168
	local wobble = math.sin(t * 11) * 4 -- 1175
	if not uiArt:tryPlacePath( -- 1175
		"assets/art/cutscene_well_museum.clip|prologue_cabinet_doors", -- 1177
		"p02_shadow_cabinet_edge", -- 1178
		w + 22 + wobble * 0.4, -- 1179
		floorY + 88, -- 1180
		195, -- 1181
		198, -- 1182
		{ -- 1183
			anchorX = 0.5, -- 1184
			anchorY = 0.5, -- 1185
			color = Color(172, 152, 134, 255), -- 1186
			opacity = 0.96, -- 1187
			smooth = true, -- 1188
			layer = 3 -- 1189
		} -- 1189
	) then -- 1189
		uiDraw:drawRect( -- 1192
			Rect(w - 72 + wobble * 0.3, floorY, 64, 142), -- 1192
			Color(42, 30, 24, 250), -- 1192
			1.1, -- 1192
			Color(94, 72, 54, 180) -- 1192
		) -- 1192
	end -- 1192
	uiInkDraw:drawRect( -- 1196
		Rect(0, h - 46, w, 46), -- 1196
		Color(6, 8, 12, 244) -- 1196
	) -- 1196
	uiInkDraw:drawRect( -- 1197
		Rect(0, 0, w, 46), -- 1197
		Color(6, 8, 12, 244) -- 1197
	) -- 1197
end -- 1044
function PrologueIntroPlugin.prototype.drawP02EscapeVignette(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1202
	local w = ctx.uiW -- 1208
	local h = ctx.uiH -- 1209
	local a = clamp01(self.vignetteAlpha) -- 1210
	if a > 0.005 then -- 1210
		local edgeX = w * (0.09 + 0.06 * a) -- 1213
		local edgeY = h * (0.11 + 0.07 * a) -- 1214
		local peakA = math.floor(168 * a + 0.5) -- 1215
		local deep = PALETTE.crimsonDeep -- 1216
		local rouge = PALETTE.rouge -- 1217
		local cEdge = Color(deep.r, deep.g, deep.b, peakA) -- 1218
		local cZero = Color(deep.r, deep.g, deep.b, 0) -- 1219
		fillHGradRect( -- 1221
			uiDraw, -- 1221
			0, -- 1221
			0, -- 1221
			edgeX, -- 1221
			h, -- 1221
			cEdge, -- 1221
			cZero -- 1221
		) -- 1221
		fillHGradRect( -- 1222
			uiDraw, -- 1222
			w - edgeX, -- 1222
			0, -- 1222
			edgeX, -- 1222
			h, -- 1222
			cZero, -- 1222
			cEdge -- 1222
		) -- 1222
		fillVGradRect( -- 1223
			uiDraw, -- 1223
			0, -- 1223
			0, -- 1223
			w, -- 1223
			edgeY, -- 1223
			cEdge, -- 1223
			cZero -- 1223
		) -- 1223
		fillVGradRect( -- 1224
			uiDraw, -- 1224
			0, -- 1224
			h - edgeY, -- 1224
			w, -- 1224
			edgeY, -- 1224
			cZero, -- 1224
			cEdge -- 1224
		) -- 1224
		if self.heartbeatPulse > 0.02 then -- 1224
			local pa = math.floor(62 * self.heartbeatPulse * a + 0.5) -- 1228
			local cPulse = Color(rouge.r, rouge.g, rouge.b, pa) -- 1229
			local cPulseZero = Color(rouge.r, rouge.g, rouge.b, 0) -- 1230
			fillHGradRect( -- 1231
				uiGlow, -- 1231
				0, -- 1231
				0, -- 1231
				edgeX * 0.72, -- 1231
				h, -- 1231
				cPulse, -- 1231
				cPulseZero -- 1231
			) -- 1231
			fillHGradRect( -- 1232
				uiGlow, -- 1232
				w - edgeX * 0.72, -- 1232
				0, -- 1232
				edgeX * 0.72, -- 1232
				h, -- 1232
				cPulseZero, -- 1232
				cPulse -- 1232
			) -- 1232
		end -- 1232
	end -- 1232
	if self.rehearsalActive then -- 1232
		local groundY = h * 0.24 -- 1238
		local doorX = w * 0.14 -- 1239
		local cabX = w * 0.8 -- 1240
		local childX = doorX + (cabX - doorX) * self.escapePlayerX -- 1241
		local wobble = math.sin(self.stageElapsed * 9.5) * 4 -- 1242
		uiInkDraw:drawRect( -- 1245
			Rect(doorX - 18, groundY, 16, 130), -- 1245
			Color(48, 36, 28, 220) -- 1245
		) -- 1245
		uiDraw:drawCircle( -- 1246
			Vec2(doorX + 18, groundY + 8), -- 1246
			8, -- 1246
			Color(168, 164, 152, 220) -- 1246
		) -- 1246
		uiDraw:drawRect( -- 1248
			Rect(cabX, groundY, 74, 108), -- 1248
			Color(42, 31, 24, 240), -- 1248
			1.2, -- 1248
			Color(118, 92, 68, 195) -- 1248
		) -- 1248
		uiInkDraw:drawSegment( -- 1249
			Vec2(cabX + 8 + wobble * 0.5, groundY + 6), -- 1249
			Vec2(cabX + 8 + wobble * 0.5, groundY + 100), -- 1249
			2.2, -- 1249
			Color(176, 144, 106, 210) -- 1249
		) -- 1249
		if not ctx.uiArt:tryPlace( -- 1249
			"child_run", -- 1251
			"p02_escape_child", -- 1251
			childX, -- 1251
			groundY, -- 1251
			46, -- 1251
			74, -- 1251
			{ -- 1251
				facing = 1, -- 1252
				frame = math.floor(self.stageElapsed * 10), -- 1253
				layer = 3 -- 1254
			} -- 1254
		) then -- 1254
			uiDraw:drawRect( -- 1256
				Rect(childX - 12, groundY, 24, 54), -- 1256
				Color(168, 72, 54, 235) -- 1256
			) -- 1256
		end -- 1256
	end -- 1256
end -- 1202
function PrologueIntroPlugin.prototype.drawP02HiddenCabinet(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1263
	local w = ctx.uiW -- 1270
	local h = ctx.uiH -- 1271
	local t = self.stageElapsed -- 1272
	local closeK = smoothstep(0, 0.26, t) -- 1273
	local doorW = w * (1.28 - 0.22 * closeK) -- 1276
	local doorH = h * 1.16 -- 1277
	local placedDoors = uiArt:tryPlacePath( -- 1278
		"assets/art/cutscene_well_museum.clip|prologue_cabinet_doors", -- 1279
		"p02_hidden_cabinet_doors", -- 1280
		w * 0.5, -- 1281
		h * 0.5, -- 1282
		doorW, -- 1283
		doorH, -- 1284
		{ -- 1285
			anchorX = 0.5, -- 1286
			anchorY = 0.5, -- 1287
			color = Color(78, 66, 56, 255), -- 1288
			opacity = 0.98, -- 1289
			smooth = true, -- 1290
			layer = 3 -- 1291
		} -- 1291
	) -- 1291
	if not placedDoors then -- 1291
		local slitW = w * (0.28 - 0.21 * closeK) -- 1295
		local leftW = (w - slitW) * 0.5 -- 1296
		uiDraw:drawRect( -- 1297
			Rect(0, 0, leftW, h), -- 1297
			Color(7, 7, 10, 248) -- 1297
		) -- 1297
		uiDraw:drawRect( -- 1298
			Rect(w - leftW, 0, leftW, h), -- 1298
			Color(7, 7, 10, 248) -- 1298
		) -- 1298
		uiInkDraw:drawSegment( -- 1299
			Vec2(leftW, 0), -- 1299
			Vec2(leftW, h), -- 1299
			1.4, -- 1299
			Color(66, 52, 40, 175) -- 1299
		) -- 1299
		uiInkDraw:drawSegment( -- 1300
			Vec2(w - leftW, 0), -- 1300
			Vec2(w - leftW, h), -- 1300
			1.4, -- 1300
			Color(66, 52, 40, 175) -- 1300
		) -- 1300
	else -- 1300
		local edgeW = w * 0.24 -- 1303
		fillHGradRect( -- 1304
			uiInkDraw, -- 1304
			0, -- 1304
			0, -- 1304
			edgeW, -- 1304
			h, -- 1304
			Color(5, 6, 9, 232), -- 1304
			Color(5, 6, 9, 0) -- 1304
		) -- 1304
		fillHGradRect( -- 1305
			uiInkDraw, -- 1305
			w - edgeW, -- 1305
			0, -- 1305
			edgeW, -- 1305
			h, -- 1305
			Color(5, 6, 9, 0), -- 1305
			Color(5, 6, 9, 232) -- 1305
		) -- 1305
	end -- 1305
	local footFade = 1 - smoothstep(0.3, 0.8, t) -- 1309
	if footFade > 0.02 then -- 1309
		local shadowX = w * 0.5 + (1 - footFade) * 38 -- 1311
		fillRadialGlow( -- 1312
			uiGlow, -- 1313
			shadowX, -- 1314
			h * 0.42, -- 1315
			32, -- 1316
			90, -- 1317
			Color( -- 1318
				148, -- 1318
				168, -- 1318
				184, -- 1318
				math.floor(32 * footFade + 0.5) -- 1318
			), -- 1318
			Color(90, 110, 130, 0), -- 1319
			12 -- 1320
		) -- 1320
	end -- 1320
	if self.vignetteAlpha > 0.005 then -- 1320
		local a = math.floor(140 * self.vignetteAlpha + 0.5) -- 1326
		local edge = w * 0.08 -- 1327
		fillHGradRect( -- 1328
			uiInkDraw, -- 1328
			0, -- 1328
			0, -- 1328
			edge, -- 1328
			h, -- 1328
			Color(124, 38, 42, a), -- 1328
			Color(124, 38, 42, 0) -- 1328
		) -- 1328
		fillHGradRect( -- 1329
			uiInkDraw, -- 1329
			w - edge, -- 1329
			0, -- 1329
			edge, -- 1329
			h, -- 1329
			Color(124, 38, 42, 0), -- 1329
			Color(124, 38, 42, a) -- 1329
		) -- 1329
	end -- 1329
end -- 1263
function PrologueIntroPlugin.prototype.drawP04WorldAction(self, fgDraw, fgGlow, worldArt, ctx) -- 1335
	local p = ctx.p -- 1341
	local cam = ctx.cam -- 1342
	local flash = self.p04FlashIntensity -- 1343
	local hintAlpha = self.p04PostHintAlpha -- 1344
	local zhou = p.childMode and p.partner or p.player -- 1346
	local xiao = p.childMode and p.player or p.partner -- 1347
	local zX = cam:sx(zhou.x) -- 1348
	local zY = cam:sy(zhou.y, zhou.depth) -- 1349
	local zH = cam:len(zhou.h) -- 1350
	local xX = cam:sx(xiao.x) -- 1351
	local xY = cam:sy(xiao.y, xiao.depth) -- 1352
	local xH = cam:len(xiao.h) -- 1353
	if flash > 0.01 then -- 1353
		fillGradQuad( -- 1358
			fgGlow, -- 1359
			cam.viewW, -- 1360
			cam.groundScreenY + cam:len(18), -- 1360
			Color( -- 1360
				238, -- 1360
				178, -- 1360
				108, -- 1360
				math.floor(96 * flash + 0.5) -- 1360
			), -- 1360
			cam.viewW, -- 1361
			cam.groundScreenY + cam:len(195), -- 1361
			Color( -- 1361
				224, -- 1361
				148, -- 1361
				82, -- 1361
				math.floor(72 * flash + 0.5) -- 1361
			), -- 1361
			zX - cam:len(140), -- 1362
			cam.groundScreenY + cam:len(140), -- 1362
			Color(200, 120, 62, 0), -- 1362
			zX - cam:len(140), -- 1363
			cam.groundScreenY, -- 1363
			Color(200, 120, 62, 0) -- 1363
		) -- 1363
		local wallBaseY = cam.groundScreenY + cam:len(14) -- 1367
		local shAlpha = math.floor(148 * flash + 0.5) -- 1368
		local shCol = Color(8, 10, 14, shAlpha) -- 1369
		fgDraw:drawPolygon( -- 1371
			{ -- 1371
				Vec2( -- 1372
					zX - cam:len(14), -- 1372
					wallBaseY -- 1372
				), -- 1372
				Vec2( -- 1373
					zX + cam:len(6), -- 1373
					wallBaseY -- 1373
				), -- 1373
				Vec2( -- 1374
					zX - cam:len(38), -- 1374
					wallBaseY + zH * 1.18 -- 1374
				), -- 1374
				Vec2( -- 1375
					zX - cam:len(64), -- 1375
					wallBaseY + zH * 1.12 -- 1375
				) -- 1375
			}, -- 1375
			shCol -- 1376
		) -- 1376
		fgDraw:drawPolygon( -- 1378
			{ -- 1378
				Vec2( -- 1379
					xX - cam:len(10), -- 1379
					wallBaseY -- 1379
				), -- 1379
				Vec2( -- 1380
					xX + cam:len(6), -- 1380
					wallBaseY -- 1380
				), -- 1380
				Vec2( -- 1381
					xX - cam:len(26), -- 1381
					wallBaseY + xH * 1.12 -- 1381
				), -- 1381
				Vec2( -- 1382
					xX - cam:len(44), -- 1382
					wallBaseY + xH * 1.06 -- 1382
				) -- 1382
			}, -- 1382
			shCol -- 1383
		) -- 1383
		local shieldK = smoothstep(0.1, 0.24, self.p04Elapsed) * (1 - smoothstep(0.5, 0.78, self.p04Elapsed)) -- 1386
		if shieldK > 0.02 then -- 1386
			local armX = zX + cam:len(10) -- 1388
			local armY = zY + zH * 0.66 -- 1389
			local cuffW = cam:len(13) -- 1390
			local cuffH = cam:len(7) -- 1391
			local sa = math.floor(235 * shieldK + 0.5) -- 1392
			fgDraw:drawPolygon( -- 1393
				{ -- 1393
					Vec2( -- 1394
						zX + cam:len(2), -- 1394
						armY - cuffH * 0.4 -- 1394
					), -- 1394
					Vec2(armX + cuffW, armY + cuffH * 0.9), -- 1395
					Vec2(armX + cuffW * 0.72, armY + cuffH * 1.75), -- 1396
					Vec2( -- 1397
						zX - cam:len(2), -- 1397
						armY + cuffH * 0.5 -- 1397
					) -- 1397
				}, -- 1397
				toColor(____exports.CUFF_SHARED_SPEC.indigoCloth, sa) -- 1398
			) -- 1398
			fgDraw:drawSegment( -- 1400
				Vec2(armX + cuffW * 0.45, armY + cuffH * 0.75), -- 1401
				Vec2(armX + cuffW * 0.82, armY + cuffH * 1.25), -- 1402
				1.3, -- 1403
				toColor( -- 1404
					____exports.CUFF_SHARED_SPEC.mendStitch, -- 1404
					math.floor(210 * shieldK + 0.5) -- 1404
				) -- 1404
			) -- 1404
			fillGradQuad( -- 1407
				fgDraw, -- 1408
				zX + cam:len(4), -- 1409
				zY + zH * 0.85, -- 1409
				Color( -- 1409
					10, -- 1409
					12, -- 1409
					18, -- 1409
					math.floor(92 * shieldK + 0.5) -- 1409
				), -- 1409
				zX + cam:len(4), -- 1410
				zY, -- 1410
				Color( -- 1410
					10, -- 1410
					12, -- 1410
					18, -- 1410
					math.floor(62 * shieldK + 0.5) -- 1410
				), -- 1410
				xX - cam:len(18), -- 1411
				xY, -- 1411
				Color(10, 12, 18, 0), -- 1411
				xX - cam:len(18), -- 1412
				xY + xH, -- 1412
				Color(10, 12, 18, 0) -- 1412
			) -- 1412
		end -- 1412
	end -- 1412
	if hintAlpha > 0.02 then -- 1412
		local baseWx = self.p04AnchorWorldX > 0 and self.p04AnchorWorldX or zhou.x -- 1419
		local hintBaseX = cam:sx(baseWx + 74) -- 1420
		local groundY = cam:sy(0, 0) -- 1421
		local boardW = cam:len(62) -- 1422
		local sheenBoost = flash * 0.55 -- 1423
		local aNorm = clamp01(hintAlpha + sheenBoost) -- 1424
		local placedBoard = worldArt:tryPlacePath( -- 1426
			"assets/art/cutscene_well_museum.clip|p04_window_board", -- 1427
			"p04_polished_window_board", -- 1428
			hintBaseX + boardW * 0.5, -- 1429
			groundY - 2, -- 1430
			boardW * 1.15, -- 1431
			cam:len(68), -- 1432
			{ -- 1433
				anchorX = 0.5, -- 1434
				anchorY = 0, -- 1435
				color = Color( -- 1436
					math.floor(188 + 64 * flash + 0.5), -- 1437
					math.floor(184 + 54 * flash + 0.5), -- 1438
					math.floor(176 + 34 * flash + 0.5), -- 1439
					255 -- 1440
				), -- 1440
				opacity = 0.88 * aNorm, -- 1442
				smooth = true, -- 1443
				layer = 4200 -- 1444
			} -- 1444
		) -- 1444
		if not placedBoard then -- 1444
			local boardY = groundY + cam:len(34) -- 1448
			fgDraw:drawRect( -- 1449
				Rect( -- 1450
					hintBaseX, -- 1450
					boardY, -- 1450
					boardW, -- 1450
					cam:len(12) -- 1450
				), -- 1450
				Color( -- 1451
					54, -- 1451
					42, -- 1451
					32, -- 1451
					math.floor(165 * aNorm + 0.5) -- 1451
				), -- 1451
				1, -- 1452
				Color( -- 1453
					126, -- 1453
					102, -- 1453
					76, -- 1453
					math.floor(150 * aNorm + 0.5) -- 1453
				) -- 1453
			) -- 1453
		end -- 1453
		fillRadialGlow( -- 1457
			fgGlow, -- 1458
			hintBaseX + boardW * 0.52, -- 1459
			groundY + cam:len(8), -- 1460
			boardW * 0.55, -- 1461
			cam:len(12), -- 1462
			Color( -- 1463
				232, -- 1463
				214, -- 1463
				178, -- 1463
				math.floor((46 + 84 * flash) * aNorm + 0.5) -- 1463
			), -- 1463
			Color(214, 186, 142, 0), -- 1464
			12 -- 1465
		) -- 1465
	end -- 1465
end -- 1335
return ____exports -- 1335