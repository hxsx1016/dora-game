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
--- P01 父亲叫醒小满硬核明代木刻暗黑漫画 22 帧逐帧动画拍表（总长 4.00s，均速 5.5–7.5 fps，与 D30/D31 及 bed_creak 1.78s 精确咬合）：
-- 黑场火光透帐（F01–F04）→ 掀帐见火（F05–F08）→ 父亲粗手压褥撑床沿（F09–F14）→ 小满坐起望门（F15–F22）。
local P01_WAKE_COMIC_SEQ = { -- 77
	{slot = "comic_p01_f01", start = 0, ["end"] = 0.2, transition = "cut"}, -- 78
	{slot = "comic_p01_f02", start = 0.2, ["end"] = 0.4, transition = "cut"}, -- 79
	{slot = "comic_p01_f03", start = 0.4, ["end"] = 0.6, transition = "cut"}, -- 80
	{slot = "comic_p01_f04", start = 0.6, ["end"] = 0.8, transition = "cut"}, -- 81
	{slot = "comic_p01_f05", start = 0.8, ["end"] = 0.99, transition = "cut"}, -- 82
	{slot = "comic_p01_f06", start = 0.99, ["end"] = 1.18, transition = "cut"}, -- 83
	{slot = "comic_p01_f07", start = 1.18, ["end"] = 1.37, transition = "cut"}, -- 84
	{slot = "comic_p01_f08", start = 1.37, ["end"] = 1.56, transition = "cut"}, -- 85
	{slot = "comic_p01_f09", start = 1.56, ["end"] = 1.74, transition = "cut"}, -- 86
	{ -- 87
		slot = "comic_p01_f10", -- 87
		start = 1.74, -- 87
		["end"] = 1.92, -- 87
		transition = "cut", -- 87
		shakeAmp = 3.2, -- 87
		shakeFreq = 52 -- 87
	}, -- 87
	{slot = "comic_p01_f11", start = 1.92, ["end"] = 2.1, transition = "cut"}, -- 88
	{slot = "comic_p01_f12", start = 2.1, ["end"] = 2.28, transition = "cut"}, -- 89
	{slot = "comic_p01_f13", start = 2.28, ["end"] = 2.46, transition = "cut"}, -- 90
	{slot = "comic_p01_f14", start = 2.46, ["end"] = 2.64, transition = "cut"}, -- 91
	{slot = "comic_p01_f15", start = 2.64, ["end"] = 2.8, transition = "cut"}, -- 92
	{slot = "comic_p01_f16", start = 2.8, ["end"] = 2.96, transition = "cut"}, -- 93
	{slot = "comic_p01_f17", start = 2.96, ["end"] = 3.12, transition = "cut"}, -- 94
	{slot = "comic_p01_f18", start = 3.12, ["end"] = 3.28, transition = "cut"}, -- 95
	{slot = "comic_p01_f19", start = 3.28, ["end"] = 3.46, transition = "cut"}, -- 96
	{slot = "comic_p01_f20", start = 3.46, ["end"] = 3.64, transition = "cut"}, -- 97
	{slot = "comic_p01_f21", start = 3.64, ["end"] = 3.82, transition = "cut"}, -- 98
	{slot = "comic_p01_f22", start = 3.82, ["end"] = 4, transition = "cut"} -- 99
} -- 99
--- P02 硬核明代木刻暗黑漫画 25 帧逐帧动画拍表（总长 4.50s，动作峰值 9–12 fps + 1.55s 三色劈砍冲击 + 3.88s 破碗撞槛爆发）：
-- 全部时间点与 stepP02Shadow 音效触发毫秒级咬合。
local P02_SHADOW_COMIC_SEQ = { -- 106
	{slot = "comic_p02_f01", start = 0, ["end"] = 0.3, transition = "cut"}, -- 108
	{slot = "comic_p02_f02", start = 0.3, ["end"] = 0.6, transition = "cut"}, -- 109
	{slot = "comic_p02_f03", start = 0.6, ["end"] = 0.9, transition = "cut"}, -- 110
	{slot = "comic_p02_f04", start = 0.9, ["end"] = 1.22, transition = "cut"}, -- 111
	{slot = "comic_p02_f05", start = 1.22, ["end"] = 1.44, transition = "cut"}, -- 113
	{slot = "comic_p02_f06", start = 1.44, ["end"] = 1.55, transition = "cut"}, -- 114
	{ -- 115
		slot = "comic_p02_f07", -- 115
		start = 1.55, -- 115
		["end"] = 1.72, -- 115
		zoomFrom = 1.032, -- 115
		zoomTo = 1.032, -- 115
		transition = "cut", -- 115
		impactFlash = true, -- 115
		impactDur = 0.17, -- 115
		shakeAmp = 11, -- 115
		shakeFreq = 72 -- 115
	}, -- 115
	{ -- 116
		slot = "comic_p02_f08", -- 116
		start = 1.72, -- 116
		["end"] = 1.88, -- 116
		transition = "cut", -- 116
		shakeAmp = 4.5, -- 116
		shakeFreq = 56 -- 116
	}, -- 116
	{slot = "comic_p02_f09", start = 1.88, ["end"] = 2.08, transition = "cut"}, -- 118
	{slot = "comic_p02_f10", start = 2.08, ["end"] = 2.28, transition = "cut"}, -- 119
	{slot = "comic_p02_f11", start = 2.28, ["end"] = 2.48, transition = "cut"}, -- 120
	{slot = "comic_p02_f12", start = 2.48, ["end"] = 2.68, transition = "cut"}, -- 121
	{ -- 123
		slot = "comic_p02_f13", -- 123
		start = 2.68, -- 123
		["end"] = 2.83, -- 123
		transition = "slash_cut", -- 123
		transitionDur = 0.08 -- 123
	}, -- 123
	{slot = "comic_p02_f14", start = 2.83, ["end"] = 2.98, transition = "cut"}, -- 124
	{slot = "comic_p02_f15", start = 2.98, ["end"] = 3.13, transition = "cut"}, -- 125
	{slot = "comic_p02_f16", start = 3.13, ["end"] = 3.28, transition = "cut"}, -- 126
	{slot = "comic_p02_f17", start = 3.28, ["end"] = 3.44, transition = "cut"}, -- 127
	{slot = "comic_p02_f18", start = 3.44, ["end"] = 3.6, transition = "cut"}, -- 128
	{ -- 129
		slot = "comic_p02_f19", -- 129
		start = 3.6, -- 129
		["end"] = 3.76, -- 129
		transition = "cut", -- 129
		shakeAmp = 2.5 -- 129
	}, -- 129
	{ -- 131
		slot = "comic_p02_f20", -- 131
		start = 3.76, -- 131
		["end"] = 3.88, -- 131
		zoomFrom = 1.022, -- 131
		zoomTo = 1.022, -- 131
		transition = "cut", -- 131
		shakeAmp = 6, -- 131
		shakeFreq = 62 -- 131
	}, -- 131
	{ -- 132
		slot = "comic_p02_f21", -- 132
		start = 3.88, -- 132
		["end"] = 4.04, -- 132
		zoomFrom = 1.026, -- 132
		zoomTo = 1, -- 132
		transition = "cut", -- 132
		impactFlash = true, -- 132
		impactDur = 0.16, -- 132
		shakeAmp = 9.5, -- 132
		shakeFreq = 66 -- 132
	}, -- 132
	{ -- 133
		slot = "comic_p02_f22", -- 133
		start = 4.04, -- 133
		["end"] = 4.15, -- 133
		transition = "cut", -- 133
		shakeAmp = 3 -- 133
	}, -- 133
	{slot = "comic_p02_f23", start = 4.15, ["end"] = 4.26, transition = "cut"}, -- 134
	{slot = "comic_p02_f24", start = 4.26, ["end"] = 4.38, transition = "cut"}, -- 135
	{slot = "comic_p02_f25", start = 4.38, ["end"] = 4.5, transition = "cut"} -- 136
} -- 136
--- P02 入柜收声 8 帧逐帧合缝拍表（总长 1.80s：贼足四步掠过 → 双门对称收窄至 1% 一线冷月死寂）
local P02_HIDDEN_COMIC_SEQ = { -- 140
	{slot = "comic_p02_f26", start = 0, ["end"] = 0.22, transition = "cut"}, -- 141
	{slot = "comic_p02_f27", start = 0.22, ["end"] = 0.44, transition = "cut"}, -- 142
	{slot = "comic_p02_f28", start = 0.44, ["end"] = 0.66, transition = "cut"}, -- 143
	{slot = "comic_p02_f29", start = 0.66, ["end"] = 0.88, transition = "cut"}, -- 144
	{slot = "comic_p02_f30", start = 0.88, ["end"] = 1.08, transition = "cut"}, -- 145
	{slot = "comic_p02_f31", start = 1.08, ["end"] = 1.28, transition = "cut"}, -- 146
	{slot = "comic_p02_f32", start = 1.28, ["end"] = 1.5, transition = "cut"}, -- 147
	{slot = "comic_p02_f33", start = 1.5, ["end"] = 1.8, transition = "cut"} -- 148
} -- 148
local PROLOGUE_AUDIO = { -- 151
	fatherWake = "assets/audio/prologue/father_wake.wav", -- 152
	nightFire = "assets/audio/prologue/night_distant_fire.wav", -- 153
	bedCreak = "assets/audio/prologue/bed_creak.wav", -- 154
	doorCommotion = "assets/audio/prologue/door_commotion.wav", -- 155
	shadowStrike = "assets/audio/prologue/shadow_strike.wav", -- 156
	bowlRoll = "assets/audio/prologue/bowl_roll.wav", -- 157
	bowlHit = "assets/audio/prologue/bowl_hit.wav", -- 158
	heartbeat = "assets/audio/prologue/heartbeat.wav", -- 159
	cabinetShut = "assets/audio/prologue/cabinet_shut.wav", -- 160
	footstepsFade = "assets/audio/prologue/footsteps_fade.wav", -- 161
	distantGunflash = "assets/audio/prologue/distant_gunflash.wav" -- 162
} -- 162
local function clamp01(v) -- 189
	return math.max( -- 190
		0, -- 190
		math.min(1, v) -- 190
	) -- 190
end -- 189
local function smoothstep(edge0, edge1, x) -- 193
	if edge1 <= edge0 then -- 193
		return x >= edge1 and 1 or 0 -- 195
	end -- 195
	local t = clamp01((x - edge0) / (edge1 - edge0)) -- 197
	return t * t * (3 - 2 * t) -- 198
end -- 193
local function asRecord(value) -- 201
	if value ~= nil and type(value) == "table" then -- 201
		return value -- 203
	end -- 203
	return nil -- 205
end -- 201
local function readNum(rec, key) -- 208
	if rec == nil then -- 208
		return nil -- 210
	end -- 210
	local v = rec[key] -- 212
	return type(v) == "number" and v or nil -- 213
end -- 208
____exports.PrologueIntroPlugin = __TS__Class() -- 216
local PrologueIntroPlugin = ____exports.PrologueIntroPlugin -- 216
PrologueIntroPlugin.name = "PrologueIntroPlugin" -- 216
function PrologueIntroPlugin.prototype.____constructor(self) -- 216
	self.id = "fe03-prologue-intro" -- 217
	self.stage = "idle" -- 219
	self.rehearsalActive = false -- 220
	self.rehearsalSequence = false -- 221
	self.stageElapsed = 0 -- 222
	self.stageDuration = 0 -- 223
	self.escapeDuration = ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 226
	self.escapeRemaining = 0 -- 227
	self.escapePlayerX = 0 -- 228
	self.vignetteAlpha = 0 -- 229
	self.hiddenStartVignette = 0 -- 230
	self.heartbeatHz = 0 -- 231
	self.heartbeatPhase = 0 -- 232
	self.heartbeatBeatCount = 0 -- 233
	self.heartbeatPulse = 0 -- 234
	self.escapeRetryCount = 0 -- 235
	self.attemptSeq = 0 -- 236
	self.p04Active = false -- 239
	self.p04Elapsed = 0 -- 240
	self.p04FlashIntensity = 0 -- 241
	self.p04PostHintAlpha = 0 -- 242
	self.p04TriggeredOnce = false -- 243
	self.p04AnchorWorldX = 0 -- 244
	self.p04AnchorWorldY = 0 -- 245
	self.roomSessionId = 0 -- 247
	self.fireLoopActive = false -- 248
	self.lastRoomKey = "" -- 249
	self.enteredContractRehearsal = false -- 252
end -- 216
function PrologueIntroPlugin.prototype.onBindPlay(self, p, _view) -- 254
	self.roomSessionId = self.roomSessionId + 1 -- 255
	self.lastRoomKey = p.room.key -- 256
	self:clearTransientState(true) -- 257
	self:syncRuntimeHook() -- 258
end -- 254
function PrologueIntroPlugin.prototype.clearTransientState(self, clearRehearsal) -- 262
	if self.fireLoopActive and self.lastAudio ~= nil then -- 262
		self.lastAudio:stopLoop("fe03_night_fire", 0) -- 264
	end -- 264
	if clearRehearsal then -- 264
		self.rehearsalActive = false -- 267
		self.rehearsalSequence = false -- 268
		if self.enteredContractRehearsal and self.boundContract ~= nil then -- 268
			self.boundContract:exitRehearsal() -- 270
		end -- 270
		self.enteredContractRehearsal = false -- 272
	end -- 272
	self.stage = "idle" -- 274
	self.stageElapsed = 0 -- 275
	self.stageDuration = 0 -- 276
	self.escapeRemaining = 0 -- 277
	self.escapePlayerX = 0 -- 278
	self.vignetteAlpha = 0 -- 279
	self.hiddenStartVignette = 0 -- 280
	self.heartbeatHz = 0 -- 281
	self.heartbeatPhase = 0 -- 282
	self.heartbeatBeatCount = 0 -- 283
	self.heartbeatPulse = 0 -- 284
	self.escapeRetryCount = 0 -- 285
	self.p04Active = false -- 286
	self.p04Elapsed = 0 -- 287
	self.p04FlashIntensity = 0 -- 288
	self.p04PostHintAlpha = 0 -- 289
	self.p04TriggeredOnce = false -- 290
	self.fireLoopActive = false -- 291
	self.attemptSeq = self.attemptSeq + 1 -- 292
end -- 262
function PrologueIntroPlugin.prototype.syncRuntimeHook(self) -- 296
	local g = _G -- 297
	local ____temp_0 -- 298
	if g.package ~= nil then -- 298
		____temp_0 = g.package.loaded -- 298
	else -- 298
		____temp_0 = nil -- 298
	end -- 298
	local loaded = ____temp_0 -- 298
	if loaded == nil then -- 298
		return -- 300
	end -- 300
	local rawFe = loaded["watch.fe"] -- 302
	if rawFe ~= nil and type(rawFe) == "table" then -- 302
		local watchFe = rawFe -- 304
		if watchFe.prologue ~= self then -- 304
			watchFe.prologue = self -- 306
		end -- 306
		if self.boundContract == nil and watchFe.contract ~= nil and type(watchFe.contract) == "table" then -- 306
			self.boundContract = watchFe.contract -- 309
		end -- 309
	end -- 309
end -- 296
function PrologueIntroPlugin.prototype.startRehearsal(self, mode, escapeDuration, contract) -- 315
	self:clearTransientState(false) -- 316
	self.rehearsalActive = true -- 317
	self.rehearsalSequence = mode == "sequence" -- 318
	if contract ~= nil then -- 318
		self.boundContract = contract -- 320
	else -- 320
		self:syncRuntimeHook() -- 322
	end -- 322
	if self.boundContract ~= nil and not self.boundContract:isRehearsal() then -- 322
		self.boundContract:enterRehearsal("fe03-prologue") -- 325
		self.enteredContractRehearsal = true -- 326
	end -- 326
	self.escapeDuration = escapeDuration ~= nil and escapeDuration > 0.5 and escapeDuration or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 328
	if mode == "p01" or mode == "sequence" then -- 328
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 333
	elseif mode == "p02" then -- 333
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 335
	elseif mode == "p02_escape" then -- 335
		self:enterEscapeFromDoorway(false) -- 337
	elseif mode == "p04" then -- 337
		self:triggerP04(0, 0) -- 339
	end -- 339
end -- 315
function PrologueIntroPlugin.prototype.stopRehearsal(self) -- 344
	self:clearTransientState(true) -- 345
end -- 344
function PrologueIntroPlugin.prototype.seekRehearsal(self, stage, seconds) -- 349
	local t = math.max(0, seconds) -- 350
	self.rehearsalActive = true -- 351
	self.rehearsalSequence = false -- 352
	if stage == "p01_wake" then -- 352
		self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 354
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p01Duration, t) -- 355
		return -- 356
	end -- 356
	if stage == "p02_shadow" then -- 356
		self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 359
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02ShadowDuration, t) -- 360
		return -- 361
	end -- 361
	if stage == "p02_escape" then -- 361
		self:enterEscapeFromDoorway(false) -- 364
		local clamped = math.min(self.escapeDuration, t) -- 365
		self.stageElapsed = clamped -- 366
		self.escapeRemaining = math.max(0, self.escapeDuration - clamped) -- 367
		local u = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 368
		self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + u * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 369
		self.vignetteAlpha = clamp01(0.14 + u * 0.56) -- 371
		return -- 372
	end -- 372
	if stage == "p02_hidden" then -- 372
		self:enterHiddenCabinet() -- 375
		self.stageElapsed = math.min(____exports.PROLOGUE_TIMINGS.p02HiddenLinger, t) -- 376
		local fadeK = clamp01(1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 377
		self.vignetteAlpha = self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut and 0 or self.hiddenStartVignette * fadeK -- 378
		return -- 381
	end -- 381
	if stage == "p04_flash" then -- 381
		self.stage = "idle" -- 384
		self:triggerP04(220, 0) -- 385
		self.p04Elapsed = math.min(____exports.PROLOGUE_TIMINGS.p04FlashDuration, t) -- 386
		self:recomputeP04Weights() -- 387
		return -- 388
	end -- 388
	self:clearTransientState(false) -- 390
end -- 349
function PrologueIntroPlugin.prototype.triggerCabinetEnter(self) -- 394
	if self.stage == "p02_escape" or self.stage == "p02_shadow" then -- 394
		self:enterHiddenCabinet() -- 396
	end -- 396
end -- 394
function PrologueIntroPlugin.prototype.retryEscape(self) -- 401
	self:enterEscapeFromDoorway(true) -- 402
end -- 401
function PrologueIntroPlugin.prototype.getSnapshot(self) -- 406
	local blocks = self.stage == "p01_wake" or self.stage == "p02_shadow" -- 407
	return { -- 408
		stage = self.stage, -- 409
		active = self.stage ~= "idle" or self.p04Active or self.p04PostHintAlpha > 0.01, -- 410
		isRehearsal = self.rehearsalActive, -- 411
		stageElapsed = self.stageElapsed, -- 412
		stageDuration = self.stageDuration, -- 413
		escapeRemaining = self.escapeRemaining, -- 414
		escapeDuration = self.escapeDuration, -- 415
		escapePlayerX = self.escapePlayerX, -- 416
		vignetteAlpha = self.vignetteAlpha, -- 417
		heartbeatHz = self.heartbeatHz, -- 418
		heartbeatBeatCount = self.heartbeatBeatCount, -- 419
		heartbeatPulse = self.heartbeatPulse, -- 420
		escapeRetryCount = self.escapeRetryCount, -- 421
		p04Active = self.p04Active, -- 422
		p04Elapsed = self.p04Elapsed, -- 423
		p04FlashIntensity = self.p04FlashIntensity, -- 424
		p04PostHintAlpha = self.p04PostHintAlpha, -- 425
		p04TriggeredOnce = self.p04TriggeredOnce, -- 426
		blocksPlayerControl = blocks, -- 427
		roomSessionId = self.roomSessionId -- 428
	} -- 428
end -- 406
function PrologueIntroPlugin.prototype.enterStage(self, next, duration) -- 432
	self.stage = next -- 433
	self.stageElapsed = 0 -- 434
	self.stageDuration = duration -- 435
	if next ~= "p02_escape" and next ~= "p02_hidden" then -- 435
		self.vignetteAlpha = 0 -- 437
		self.heartbeatHz = 0 -- 438
		self.heartbeatPulse = 0 -- 439
		self.heartbeatPhase = 0 -- 440
	end -- 440
end -- 432
function PrologueIntroPlugin.prototype.enterEscapeFromDoorway(self, isRetry) -- 444
	self.attemptSeq = self.attemptSeq + 1 -- 445
	self.stage = "p02_escape" -- 446
	self.stageElapsed = 0 -- 447
	self.stageDuration = self.escapeDuration -- 448
	self.escapeRemaining = self.escapeDuration -- 449
	self.escapePlayerX = 0 -- 450
	self.vignetteAlpha = 0 -- 452
	self.hiddenStartVignette = 0 -- 453
	self.heartbeatHz = 0 -- 454
	self.heartbeatPhase = 0 -- 455
	self.heartbeatBeatCount = 0 -- 456
	self.heartbeatPulse = 0 -- 457
	if isRetry then -- 457
		self.escapeRetryCount = self.escapeRetryCount + 1 -- 459
	end -- 459
end -- 444
function PrologueIntroPlugin.prototype.enterHiddenCabinet(self) -- 463
	self.hiddenStartVignette = self.vignetteAlpha > 0.01 and self.vignetteAlpha or 0.35 -- 464
	self.stage = "p02_hidden" -- 465
	self.stageElapsed = 0 -- 466
	self.stageDuration = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 467
	self.escapeRemaining = 0 -- 468
	self.escapePlayerX = 1 -- 469
	self.heartbeatHz = 0 -- 470
	self.heartbeatPulse = 0 -- 471
	self.heartbeatPhase = 0 -- 472
end -- 463
function PrologueIntroPlugin.prototype.triggerP04(self, anchorX, anchorY) -- 475
	self.p04Active = true -- 476
	self.p04Elapsed = 0 -- 477
	self.p04TriggeredOnce = true -- 478
	self.p04AnchorWorldX = anchorX -- 479
	self.p04AnchorWorldY = anchorY -- 480
	self:recomputeP04Weights() -- 481
end -- 475
function PrologueIntroPlugin.prototype.recomputeP04Weights(self) -- 484
	local t = self.p04Elapsed -- 485
	if t < 0.08 then -- 485
		self.p04FlashIntensity = clamp01(t / 0.08) -- 487
	elseif t < 0.55 then -- 487
		local k = (t - 0.08) / 0.47 -- 489
		local flicker = 0.86 + 0.14 * math.sin(t * 46) -- 490
		self.p04FlashIntensity = clamp01((1 - k * k) * flicker) -- 491
	else -- 491
		self.p04FlashIntensity = 0 -- 493
	end -- 493
	if t >= 0.18 then -- 493
		local reveal = smoothstep(0.18, 0.42, t) -- 496
		local settle = t > 0.55 and 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) or 0.85 -- 497
		self.p04PostHintAlpha = math.max(self.p04PostHintAlpha, reveal * settle) -- 498
		if t > 0.55 then -- 498
			self.p04PostHintAlpha = 0.42 + 0.43 * (1 - smoothstep(0.55, 0.95, t)) -- 500
		end -- 500
	end -- 500
end -- 484
function PrologueIntroPlugin.prototype.cueKey(self, name) -- 505
	return (((("fe03:r" .. tostring(self.roomSessionId)) .. ":a") .. tostring(self.attemptSeq)) .. ":") .. name -- 506
end -- 505
function PrologueIntroPlugin.prototype.update(self, ctx) -- 509
	self.lastAudio = ctx.audio -- 510
	self:syncRuntimeHook() -- 511
	local p = ctx.p -- 512
	if self.lastRoomKey ~= "" and self.lastRoomKey ~= p.room.key then -- 512
		self:onBindPlay(p, ctx.view) -- 515
	end -- 515
	if ctx.paused or ctx.worldDt <= 0 then -- 515
		return -- 520
	end -- 520
	local dt = ctx.worldDt -- 523
	if not self.rehearsalActive then -- 523
		self:syncLiveBackendTriggers(ctx) -- 527
	end -- 527
	if self.stage == "p01_wake" then -- 527
		self:stepP01(ctx, dt) -- 532
	elseif self.stage == "p02_shadow" then -- 532
		self:stepP02Shadow(ctx, dt) -- 534
	elseif self.stage == "p02_escape" then -- 534
		self:stepP02Escape(ctx, dt) -- 536
	elseif self.stage == "p02_hidden" then -- 536
		self:stepP02Hidden(ctx, dt) -- 538
	end -- 538
	if self.p04Active then -- 538
		self:stepP04(ctx, dt) -- 543
	end -- 543
end -- 509
function PrologueIntroPlugin.prototype.syncLiveBackendTriggers(self, ctx) -- 547
	local p = ctx.p -- 548
	local pRec = asRecord(p) -- 549
	if p.room.key == "prologue" then -- 549
		local phase = p.phase -- 553
		if phase == "prologue-wake" and self.stage ~= "p01_wake" then -- 553
			self:enterStage("p01_wake", ____exports.PROLOGUE_TIMINGS.p01Duration) -- 555
		elseif phase == "prologue-shadow" and self.stage ~= "p02_shadow" then -- 555
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 557
		elseif phase == "prologue-escape" and self.stage ~= "p02_escape" then -- 557
			local dur = readNum(pRec, "escapeDuration") or ____exports.PROLOGUE_TIMINGS.p02EscapeDuration -- 559
			self.escapeDuration = math.max(0.5, dur) -- 560
			self:enterEscapeFromDoorway(false) -- 561
		elseif phase == "prologue-hide" and self.stage ~= "p02_hidden" then -- 561
			self:enterHiddenCabinet() -- 563
		elseif (phase == "prologue-wait" or phase == "prologue-give" or phase == "prologue-follow") and (self.stage == "p01_wake" or self.stage == "p02_shadow" or self.stage == "p02_escape" or self.stage == "p02_hidden") then -- 563
			self.stage = "idle" -- 571
			self.vignetteAlpha = 0 -- 572
			self.heartbeatHz = 0 -- 573
			self.heartbeatPulse = 0 -- 574
		end -- 574
	end -- 574
	local i = 0 -- 579
	do -- 579
		i = 0 -- 580
		while i < #ctx.events.rawEvents do -- 580
			local ev = ctx.events.rawEvents[i + 1] -- 581
			local ename = ev.name -- 582
			if ename == "prologueBeat" and ev.data.beat == "escapeRetry" and self.stage == "p02_escape" then -- 582
				self:retryEscape() -- 584
			elseif ename == "p04WallFlash" or ename == "wallPeekFlash" then -- 584
				if not self.p04TriggeredOnce and p.run.story.segments.p04_wall_flash ~= true then -- 584
					p.run.story.segments.p04_wall_flash = true -- 587
					self:triggerP04(p.player.x, p.player.y) -- 588
				end -- 588
			end -- 588
			i = i + 1 -- 580
		end -- 580
	end -- 580
	if not self.p04TriggeredOnce and p.run.story.segments.p04_wall_flash ~= true and not p.childMode and p.player.alive and p.partner.alive then -- 580
		local inPrologueCourtyard = p.room.key == "prologue" and p.phase == "prologue-follow" and p.player.x >= p.ox + 470 and p.player.x <= p.ox + 635 -- 595
		local inStreetWallRoot = p.room.key == "street" and p.player.x >= p.ox + 115 and p.player.x <= p.ox + 265 and self:hasAliveEnemy(p) -- 598
		local inS1WellRoot = p.room.key == "s1-crossroad" and p.player.x >= p.ox + 185 and p.player.x <= p.ox + 320 -- 601
		if inPrologueCourtyard or inStreetWallRoot or inS1WellRoot then -- 601
			p.run.story.segments.p04_wall_flash = true -- 604
			self:triggerP04(p.player.x, p.player.y) -- 605
		end -- 605
	end -- 605
end -- 547
function PrologueIntroPlugin.prototype.hasAliveEnemy(self, p) -- 610
	local i = 0 -- 611
	do -- 611
		i = 0 -- 612
		while i < #p.enemies do -- 612
			if p.enemies[i + 1].alive then -- 612
				return true -- 614
			end -- 614
			i = i + 1 -- 612
		end -- 612
	end -- 612
	return false -- 617
end -- 610
function PrologueIntroPlugin.prototype.stepP01(self, ctx, dt) -- 620
	self.stageElapsed = self.stageElapsed + dt -- 621
	local tick = ctx.p.ticks -- 622
	if not self.fireLoopActive then -- 622
		self.fireLoopActive = true -- 625
		ctx.audio:playLoop( -- 626
			"fe03_night_fire", -- 626
			"ambience", -- 626
			PROLOGUE_AUDIO.nightFire, -- 626
			0.34, -- 626
			tick -- 626
		) -- 626
	end -- 626
	if self.stageElapsed >= 0.12 then -- 626
		ctx.audio:playOnce( -- 629
			self:cueKey("p01_father_call"), -- 630
			"voice", -- 631
			PROLOGUE_AUDIO.fatherWake, -- 632
			0.92, -- 633
			"prologue:p01_call", -- 634
			tick -- 635
		) -- 635
	end -- 635
	if self.stageElapsed >= 1.9 then -- 635
		ctx.audio:playOnce( -- 639
			self:cueKey("p01_bed_press"), -- 640
			"sfx", -- 641
			PROLOGUE_AUDIO.bedCreak, -- 642
			0.68, -- 643
			"prologue:p01_bed_press", -- 644
			tick -- 645
		) -- 645
	end -- 645
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p01Duration then -- 645
		if self.rehearsalSequence then -- 645
			self:enterStage("p02_shadow", ____exports.PROLOGUE_TIMINGS.p02ShadowDuration) -- 651
		elseif self.rehearsalActive then -- 651
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p01Duration -- 653
			self.stage = "idle" -- 654
		else -- 654
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p01Duration -- 657
		end -- 657
	end -- 657
end -- 620
function PrologueIntroPlugin.prototype.stepP02Shadow(self, ctx, dt) -- 662
	self.stageElapsed = self.stageElapsed + dt -- 663
	local tick = ctx.p.ticks -- 664
	if self.stageElapsed >= 0.1 then -- 664
		ctx.audio:playOnce( -- 667
			self:cueKey("p02_door_commotion"), -- 668
			"ambience", -- 669
			PROLOGUE_AUDIO.doorCommotion, -- 670
			0.62, -- 671
			"prologue:p02_commotion", -- 672
			tick -- 673
		) -- 673
	end -- 673
	if self.stageElapsed >= 1.55 then -- 673
		ctx.audio:playOnce( -- 677
			self:cueKey("p02_shadow_strike"), -- 678
			"sfx", -- 679
			PROLOGUE_AUDIO.shadowStrike, -- 680
			0.88, -- 681
			"prologue:p02_shadow_cut", -- 682
			tick -- 683
		) -- 683
	end -- 683
	if self.stageElapsed >= 2.78 then -- 683
		ctx.audio:playOnce( -- 687
			self:cueKey("p02_bowl_roll"), -- 688
			"sfx", -- 689
			PROLOGUE_AUDIO.bowlRoll, -- 690
			0.78, -- 691
			"prologue:p02_bowl_roll", -- 692
			tick -- 693
		) -- 693
	end -- 693
	if self.stageElapsed >= 3.88 then -- 693
		ctx.audio:playOnce( -- 697
			self:cueKey("p02_bowl_hit"), -- 698
			"sfx", -- 699
			PROLOGUE_AUDIO.bowlHit, -- 700
			0.92, -- 701
			"prologue:p02_bowl_hit", -- 702
			tick -- 703
		) -- 703
	end -- 703
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02ShadowDuration then -- 703
		if self.rehearsalActive then -- 703
			self:enterEscapeFromDoorway(false) -- 710
		else -- 710
			self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02ShadowDuration -- 713
		end -- 713
	end -- 713
end -- 662
function PrologueIntroPlugin.prototype.stepP02Escape(self, ctx, dt) -- 718
	self.stageElapsed = self.stageElapsed + dt -- 719
	local pRec = asRecord(ctx.p) -- 722
	local liveRemain = readNum(pRec, "escapeRemaining") -- 723
	if not self.rehearsalActive and liveRemain ~= nil then -- 723
		self.escapeRemaining = math.max(0, liveRemain) -- 725
	else -- 725
		self.escapeRemaining = math.max(0, self.escapeRemaining - dt) -- 727
	end -- 727
	if self.rehearsalActive then -- 727
		if ctx.input.moveX ~= 0 then -- 727
			self.escapePlayerX = clamp01(self.escapePlayerX + ctx.input.moveX * dt * 0.34) -- 733
		end -- 733
		if self.escapePlayerX >= 0.85 and ctx.input.interact.pressed or self.escapePlayerX >= 0.98 then -- 733
			self:enterHiddenCabinet() -- 736
			return -- 737
		end -- 737
	end -- 737
	if self.escapeRemaining <= 0 and (self.rehearsalActive or liveRemain == nil) then -- 737
		self:retryEscape() -- 743
		return -- 744
	end -- 744
	local urgency = clamp01(1 - self.escapeRemaining / math.max(0.01, self.escapeDuration)) -- 747
	self.heartbeatHz = ____exports.PROLOGUE_TIMINGS.heartbeatMinHz + urgency * (____exports.PROLOGUE_TIMINGS.heartbeatMaxHz - ____exports.PROLOGUE_TIMINGS.heartbeatMinHz) -- 748
	local prevCycle = math.floor(self.heartbeatPhase) -- 751
	self.heartbeatPhase = self.heartbeatPhase + dt * self.heartbeatHz -- 752
	local currCycle = math.floor(self.heartbeatPhase) -- 753
	if currCycle > prevCycle then -- 753
		self.heartbeatBeatCount = self.heartbeatBeatCount + 1 -- 755
		self.heartbeatPulse = 1 -- 756
		ctx.audio:playOnce( -- 757
			self:cueKey("p02_hb_" .. tostring(self.heartbeatBeatCount)), -- 758
			"sfx", -- 759
			PROLOGUE_AUDIO.heartbeat, -- 760
			0.44 + 0.48 * urgency, -- 761
			"prologue:p02_heartbeat:" .. tostring(self.heartbeatBeatCount), -- 762
			ctx.p.ticks -- 763
		) -- 763
	else -- 763
		local frac = self.heartbeatPhase - currCycle -- 767
		if frac >= 0.2 and frac <= 0.28 then -- 767
			self.heartbeatPulse = math.max(self.heartbeatPulse, 0.56) -- 769
		end -- 769
		self.heartbeatPulse = math.max(0, self.heartbeatPulse - dt * 3.8) -- 771
	end -- 771
	self.vignetteAlpha = clamp01(0.14 + urgency * 0.54 + self.heartbeatPulse * 0.16) -- 775
end -- 718
function PrologueIntroPlugin.prototype.stepP02Hidden(self, ctx, dt) -- 778
	self.stageElapsed = self.stageElapsed + dt -- 779
	local tick = ctx.p.ticks -- 780
	ctx.audio:playOnce( -- 782
		self:cueKey("p02_cabinet_shut"), -- 783
		"sfx", -- 784
		PROLOGUE_AUDIO.cabinetShut, -- 785
		0.78, -- 786
		"prologue:p02_cabinet_shut", -- 787
		tick -- 788
	) -- 788
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut then -- 788
		self.vignetteAlpha = 0 -- 793
	else -- 793
		self.vignetteAlpha = self.hiddenStartVignette * (1 - self.stageElapsed / ____exports.PROLOGUE_TIMINGS.p02HiddenFadeOut) -- 795
	end -- 795
	self.heartbeatHz = 0 -- 798
	self.heartbeatPulse = 0 -- 799
	if self.stageElapsed >= 0.3 then -- 799
		ctx.audio:playOnce( -- 803
			self:cueKey("p02_footsteps_fade"), -- 804
			"sfx", -- 805
			PROLOGUE_AUDIO.footstepsFade, -- 806
			0.65, -- 807
			"prologue:p02_footsteps_fade", -- 808
			tick -- 809
		) -- 809
	end -- 809
	if self.stageElapsed >= ____exports.PROLOGUE_TIMINGS.p02HiddenLinger then -- 809
		self.stageElapsed = ____exports.PROLOGUE_TIMINGS.p02HiddenLinger -- 814
		self.vignetteAlpha = 0 -- 815
	end -- 815
end -- 778
function PrologueIntroPlugin.prototype.stepP04(self, ctx, dt) -- 819
	if self.p04Elapsed == 0 then -- 819
		ctx.audio:playOnce( -- 821
			self:cueKey("p04_gunflash"), -- 822
			"sfx", -- 823
			PROLOGUE_AUDIO.distantGunflash, -- 824
			0.78, -- 825
			"prologue:p04_gunflash", -- 826
			ctx.p.ticks -- 827
		) -- 827
	end -- 827
	self.p04Elapsed = self.p04Elapsed + dt -- 830
	self:recomputeP04Weights() -- 831
	if self.p04Elapsed >= ____exports.PROLOGUE_TIMINGS.p04FlashDuration then -- 831
		self.p04Elapsed = ____exports.PROLOGUE_TIMINGS.p04FlashDuration -- 833
		self.p04FlashIntensity = 0 -- 834
		self.p04Active = false -- 835
		self.p04PostHintAlpha = 0.42 -- 837
	end -- 837
end -- 819
function PrologueIntroPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 842
	if self.stage == "p02_escape" and not self.rehearsalActive and ctx.p.room.key == "prologue" then -- 842
		local cam = ctx.cam -- 849
		local cabX = cam:sx(ctx.p.ox + PROLOGUE_CABINET_X + 18) -- 850
		local cabY = cam:sy(0, 0) -- 851
		local pulse = 0.65 + 0.35 * math.sin(self.stageElapsed * 6.5) -- 852
		local sway = math.sin(self.stageElapsed * 9) * cam:len(2.5) -- 853
		fillRadialGlow( -- 855
			fgGlow, -- 856
			cabX + sway, -- 857
			cabY + cam:len(34), -- 858
			cam:len(38), -- 859
			cam:len(46), -- 860
			Color( -- 861
				232, -- 861
				178, -- 861
				104, -- 861
				math.floor(68 * pulse + 0.5) -- 861
			), -- 861
			Color(186, 118, 56, 0), -- 862
			14 -- 863
		) -- 863
		fgDraw:drawSegment( -- 865
			Vec2( -- 866
				cabX + sway, -- 866
				cabY + cam:len(4) -- 866
			), -- 866
			Vec2( -- 867
				cabX + sway, -- 867
				cabY + cam:len(54) -- 867
			), -- 867
			2, -- 868
			Color( -- 869
				238, -- 869
				198, -- 869
				134, -- 869
				math.floor(165 * pulse + 0.5) -- 869
			) -- 869
		) -- 869
	end -- 869
	if not self.p04Active and self.p04PostHintAlpha <= 0.01 then -- 869
		return -- 873
	end -- 873
	self:drawP04WorldAction(fgDraw, fgGlow, worldArt, ctx) -- 875
end -- 842
function PrologueIntroPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 879
	if self.stage == "p01_wake" then -- 879
		self:drawP01Wake( -- 887
			uiDraw, -- 887
			uiInkDraw, -- 887
			uiArt, -- 887
			uiGlow, -- 887
			ctx -- 887
		) -- 887
		return true -- 888
	end -- 888
	if self.stage == "p02_shadow" then -- 888
		self:drawP02ShadowAndBowl( -- 891
			uiDraw, -- 891
			uiInkDraw, -- 891
			uiArt, -- 891
			uiGlow, -- 891
			ctx -- 891
		) -- 891
		return true -- 892
	end -- 892
	if self.stage == "p02_escape" then -- 892
		self:drawP02EscapeVignette(uiDraw, uiInkDraw, uiGlow, ctx) -- 895
		return true -- 897
	end -- 897
	if self.stage == "p02_hidden" then -- 897
		self:drawP02HiddenCabinet( -- 900
			uiDraw, -- 900
			uiInkDraw, -- 900
			uiArt, -- 900
			uiGlow, -- 900
			ctx -- 900
		) -- 900
		return true -- 901
	end -- 901
	return false -- 903
end -- 879
function PrologueIntroPlugin.prototype.drawP01Wake(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 908
	local w = ctx.uiW -- 915
	local h = ctx.uiH -- 916
	local t = self.stageElapsed -- 917
	uiDraw:drawRect( -- 920
		Rect(0, 0, w, h), -- 920
		Color(6, 7, 11, 255) -- 920
	) -- 920
	local wakeOpen = smoothstep(0.28, 1.45, t) -- 923
	local blinkDip = t >= 0.96 and t <= 1.28 and math.sin((t - 0.96) / 0.32 * math.pi) * 0.22 or 0 -- 924
	local eyeOpen = clamp01(wakeOpen - blinkDip) -- 925
	local fadeOut = 1 - smoothstep(3.76, 4, t) -- 926
	local barH = math.floor(h * 0.068 + 0.5) -- 927
	if eyeOpen > 0.01 then -- 927
		drawComicSequence( -- 930
			uiDraw, -- 931
			uiInkDraw, -- 932
			uiArt, -- 933
			P01_WAKE_COMIC_SEQ, -- 934
			t, -- 935
			w, -- 936
			h, -- 937
			{ -- 938
				letterboxH = barH, -- 939
				opacity = clamp01(smoothstep(0.18, 0.58, t)) * fadeOut, -- 940
				layer = 2, -- 941
				instancePrefix = "p01_comic", -- 942
				accentBorder = true -- 943
			} -- 943
		) -- 943
	end -- 943
	local lidH = h * 0.52 * (1 - eyeOpen) -- 949
	if lidH > 1 then -- 949
		ctx.uiMask:drawRect( -- 951
			Rect(0, h - lidH, w, lidH), -- 951
			Color(5, 6, 9, 255) -- 951
		) -- 951
		ctx.uiMask:drawRect( -- 952
			Rect(0, 0, w, lidH), -- 952
			Color(5, 6, 9, 255) -- 952
		) -- 952
		local feather = math.min(46, h * 0.08) -- 953
		fillVGradRect( -- 954
			ctx.uiMask, -- 954
			0, -- 954
			h - lidH - feather, -- 954
			w, -- 954
			feather, -- 954
			Color(5, 6, 9, 0), -- 954
			Color(5, 6, 9, 235) -- 954
		) -- 954
		fillVGradRect( -- 955
			ctx.uiMask, -- 955
			0, -- 955
			lidH, -- 955
			w, -- 955
			feather, -- 955
			Color(5, 6, 9, 235), -- 955
			Color(5, 6, 9, 0) -- 955
		) -- 955
	end -- 955
	if self.rehearsalActive then -- 955
		local callAlpha = smoothstep(0.1, 0.32, t) * (1 - smoothstep(1.05, 1.55, t)) -- 960
		if callAlpha > 0.02 then -- 960
			drawSilkVeil( -- 962
				uiDraw, -- 962
				uiArt, -- 962
				"p01_call_veil", -- 962
				w * 0.5, -- 962
				h * 0.14, -- 962
				240, -- 962
				44, -- 962
				PALETTE.inkWash, -- 962
				0.72 * callAlpha, -- 962
				0 -- 962
			) -- 962
			ctx.texts:put( -- 963
				"sm", -- 964
				"「小满。」", -- 965
				w * 0.5, -- 966
				h * 0.14, -- 967
				toColor(PALETTE.textBright), -- 968
				0.5, -- 969
				0.5, -- 970
				"Center", -- 971
				2, -- 972
				callAlpha, -- 973
				0.08 -- 974
			) -- 974
		end -- 974
	end -- 974
end -- 908
function PrologueIntroPlugin.prototype.drawP02ShadowAndBowl(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 982
	local w = ctx.uiW -- 989
	local h = ctx.uiH -- 990
	local t = self.stageElapsed -- 991
	local barH = math.floor(h * 0.068 + 0.5) -- 992
	drawComicSequence( -- 993
		uiDraw, -- 994
		uiInkDraw, -- 995
		uiArt, -- 996
		P02_SHADOW_COMIC_SEQ, -- 997
		t, -- 998
		w, -- 999
		h, -- 1000
		{ -- 1001
			letterboxH = barH, -- 1002
			opacity = 1, -- 1003
			layer = 2, -- 1004
			instancePrefix = "fe03_p02_shadow", -- 1005
			accentBorder = true -- 1006
		} -- 1006
	) -- 1006
end -- 982
function PrologueIntroPlugin.prototype.drawP02EscapeVignette(self, uiDraw, uiInkDraw, uiGlow, ctx) -- 1013
	local w = ctx.uiW -- 1019
	local h = ctx.uiH -- 1020
	local a = clamp01(self.vignetteAlpha) -- 1021
	if a > 0.005 then -- 1021
		local edgeX = w * (0.09 + 0.06 * a) -- 1024
		local edgeY = h * (0.11 + 0.07 * a) -- 1025
		local peakA = math.floor(168 * a + 0.5) -- 1026
		local deep = PALETTE.crimsonDeep -- 1027
		local rouge = PALETTE.rouge -- 1028
		local cEdge = Color(deep.r, deep.g, deep.b, peakA) -- 1029
		local cZero = Color(deep.r, deep.g, deep.b, 0) -- 1030
		fillHGradRect( -- 1032
			uiDraw, -- 1032
			0, -- 1032
			0, -- 1032
			edgeX, -- 1032
			h, -- 1032
			cEdge, -- 1032
			cZero -- 1032
		) -- 1032
		fillHGradRect( -- 1033
			uiDraw, -- 1033
			w - edgeX, -- 1033
			0, -- 1033
			edgeX, -- 1033
			h, -- 1033
			cZero, -- 1033
			cEdge -- 1033
		) -- 1033
		fillVGradRect( -- 1034
			uiDraw, -- 1034
			0, -- 1034
			0, -- 1034
			w, -- 1034
			edgeY, -- 1034
			cEdge, -- 1034
			cZero -- 1034
		) -- 1034
		fillVGradRect( -- 1035
			uiDraw, -- 1035
			0, -- 1035
			h - edgeY, -- 1035
			w, -- 1035
			edgeY, -- 1035
			cZero, -- 1035
			cEdge -- 1035
		) -- 1035
		if self.heartbeatPulse > 0.02 then -- 1035
			local pa = math.floor(62 * self.heartbeatPulse * a + 0.5) -- 1039
			local cPulse = Color(rouge.r, rouge.g, rouge.b, pa) -- 1040
			local cPulseZero = Color(rouge.r, rouge.g, rouge.b, 0) -- 1041
			fillHGradRect( -- 1042
				uiGlow, -- 1042
				0, -- 1042
				0, -- 1042
				edgeX * 0.72, -- 1042
				h, -- 1042
				cPulse, -- 1042
				cPulseZero -- 1042
			) -- 1042
			fillHGradRect( -- 1043
				uiGlow, -- 1043
				w - edgeX * 0.72, -- 1043
				0, -- 1043
				edgeX * 0.72, -- 1043
				h, -- 1043
				cPulseZero, -- 1043
				cPulse -- 1043
			) -- 1043
		end -- 1043
	end -- 1043
	if self.rehearsalActive then -- 1043
		local groundY = h * 0.24 -- 1049
		local doorX = w * 0.14 -- 1050
		local cabX = w * 0.8 -- 1051
		local childX = doorX + (cabX - doorX) * self.escapePlayerX -- 1052
		local wobble = math.sin(self.stageElapsed * 9.5) * 4 -- 1053
		uiInkDraw:drawRect( -- 1056
			Rect(doorX - 18, groundY, 16, 130), -- 1056
			Color(48, 36, 28, 220) -- 1056
		) -- 1056
		uiDraw:drawCircle( -- 1057
			Vec2(doorX + 18, groundY + 8), -- 1057
			8, -- 1057
			Color(168, 164, 152, 220) -- 1057
		) -- 1057
		uiDraw:drawRect( -- 1059
			Rect(cabX, groundY, 74, 108), -- 1059
			Color(42, 31, 24, 240), -- 1059
			1.2, -- 1059
			Color(118, 92, 68, 195) -- 1059
		) -- 1059
		uiInkDraw:drawSegment( -- 1060
			Vec2(cabX + 8 + wobble * 0.5, groundY + 6), -- 1060
			Vec2(cabX + 8 + wobble * 0.5, groundY + 100), -- 1060
			2.2, -- 1060
			Color(176, 144, 106, 210) -- 1060
		) -- 1060
		if not ctx.uiArt:tryPlaceRun( -- 1060
			"child", -- 1062
			"p02_escape_child", -- 1062
			childX, -- 1062
			groundY, -- 1062
			46, -- 1062
			74, -- 1062
			self.stageElapsed * 1.8, -- 1062
			{facing = 1, layer = 3} -- 1062
		) then -- 1062
			uiDraw:drawRect( -- 1066
				Rect(childX - 12, groundY, 24, 54), -- 1066
				Color(168, 72, 54, 235) -- 1066
			) -- 1066
		end -- 1066
	end -- 1066
end -- 1013
function PrologueIntroPlugin.prototype.drawP02HiddenCabinet(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 1073
	local w = ctx.uiW -- 1080
	local h = ctx.uiH -- 1081
	local t = self.stageElapsed -- 1082
	drawComicSequence( -- 1084
		uiDraw, -- 1085
		uiInkDraw, -- 1086
		uiArt, -- 1087
		P02_HIDDEN_COMIC_SEQ, -- 1088
		t, -- 1089
		w, -- 1090
		h, -- 1091
		{ -- 1092
			letterboxH = math.floor(h * 0.055 + 0.5), -- 1093
			opacity = 1, -- 1094
			layer = 3, -- 1095
			instancePrefix = "fe03_p02_hidden", -- 1096
			accentBorder = false -- 1097
		} -- 1097
	) -- 1097
	if self.vignetteAlpha > 0.005 then -- 1097
		local a = math.floor(140 * self.vignetteAlpha + 0.5) -- 1103
		local edge = w * 0.08 -- 1104
		fillHGradRect( -- 1105
			uiInkDraw, -- 1105
			0, -- 1105
			0, -- 1105
			edge, -- 1105
			h, -- 1105
			Color(124, 38, 42, a), -- 1105
			Color(124, 38, 42, 0) -- 1105
		) -- 1105
		fillHGradRect( -- 1106
			uiInkDraw, -- 1106
			w - edge, -- 1106
			0, -- 1106
			edge, -- 1106
			h, -- 1106
			Color(124, 38, 42, 0), -- 1106
			Color(124, 38, 42, a) -- 1106
		) -- 1106
	end -- 1106
end -- 1073
function PrologueIntroPlugin.prototype.drawP04WorldAction(self, fgDraw, fgGlow, worldArt, ctx) -- 1112
	local p = ctx.p -- 1118
	local cam = ctx.cam -- 1119
	local flash = self.p04FlashIntensity -- 1120
	local hintAlpha = self.p04PostHintAlpha -- 1121
	local zhou = p.childMode and p.partner or p.player -- 1123
	local xiao = p.childMode and p.player or p.partner -- 1124
	local zX = cam:sx(zhou.x) -- 1125
	local zY = cam:sy(zhou.y, zhou.depth) -- 1126
	local zH = cam:len(zhou.h) -- 1127
	local xX = cam:sx(xiao.x) -- 1128
	local xY = cam:sy(xiao.y, xiao.depth) -- 1129
	local xH = cam:len(xiao.h) -- 1130
	if flash > 0.01 then -- 1130
		fillGradQuad( -- 1135
			fgGlow, -- 1136
			cam.viewW, -- 1137
			cam.groundScreenY + cam:len(18), -- 1137
			Color( -- 1137
				238, -- 1137
				178, -- 1137
				108, -- 1137
				math.floor(96 * flash + 0.5) -- 1137
			), -- 1137
			cam.viewW, -- 1138
			cam.groundScreenY + cam:len(195), -- 1138
			Color( -- 1138
				224, -- 1138
				148, -- 1138
				82, -- 1138
				math.floor(72 * flash + 0.5) -- 1138
			), -- 1138
			zX - cam:len(140), -- 1139
			cam.groundScreenY + cam:len(140), -- 1139
			Color(200, 120, 62, 0), -- 1139
			zX - cam:len(140), -- 1140
			cam.groundScreenY, -- 1140
			Color(200, 120, 62, 0) -- 1140
		) -- 1140
		local wallBaseY = cam.groundScreenY + cam:len(14) -- 1144
		local shAlpha = math.floor(148 * flash + 0.5) -- 1145
		local shCol = Color(8, 10, 14, shAlpha) -- 1146
		fgDraw:drawPolygon( -- 1148
			{ -- 1148
				Vec2( -- 1149
					zX - cam:len(14), -- 1149
					wallBaseY -- 1149
				), -- 1149
				Vec2( -- 1150
					zX + cam:len(6), -- 1150
					wallBaseY -- 1150
				), -- 1150
				Vec2( -- 1151
					zX - cam:len(38), -- 1151
					wallBaseY + zH * 1.18 -- 1151
				), -- 1151
				Vec2( -- 1152
					zX - cam:len(64), -- 1152
					wallBaseY + zH * 1.12 -- 1152
				) -- 1152
			}, -- 1152
			shCol -- 1153
		) -- 1153
		fgDraw:drawPolygon( -- 1155
			{ -- 1155
				Vec2( -- 1156
					xX - cam:len(10), -- 1156
					wallBaseY -- 1156
				), -- 1156
				Vec2( -- 1157
					xX + cam:len(6), -- 1157
					wallBaseY -- 1157
				), -- 1157
				Vec2( -- 1158
					xX - cam:len(26), -- 1158
					wallBaseY + xH * 1.12 -- 1158
				), -- 1158
				Vec2( -- 1159
					xX - cam:len(44), -- 1159
					wallBaseY + xH * 1.06 -- 1159
				) -- 1159
			}, -- 1159
			shCol -- 1160
		) -- 1160
		local shieldK = smoothstep(0.1, 0.24, self.p04Elapsed) * (1 - smoothstep(0.5, 0.78, self.p04Elapsed)) -- 1163
		if shieldK > 0.02 then -- 1163
			local armX = zX + cam:len(10) -- 1165
			local armY = zY + zH * 0.66 -- 1166
			local cuffW = cam:len(13) -- 1167
			local cuffH = cam:len(7) -- 1168
			local sa = math.floor(235 * shieldK + 0.5) -- 1169
			fgDraw:drawPolygon( -- 1170
				{ -- 1170
					Vec2( -- 1171
						zX + cam:len(2), -- 1171
						armY - cuffH * 0.4 -- 1171
					), -- 1171
					Vec2(armX + cuffW, armY + cuffH * 0.9), -- 1172
					Vec2(armX + cuffW * 0.72, armY + cuffH * 1.75), -- 1173
					Vec2( -- 1174
						zX - cam:len(2), -- 1174
						armY + cuffH * 0.5 -- 1174
					) -- 1174
				}, -- 1174
				toColor(____exports.CUFF_SHARED_SPEC.indigoCloth, sa) -- 1175
			) -- 1175
			fgDraw:drawSegment( -- 1177
				Vec2(armX + cuffW * 0.45, armY + cuffH * 0.75), -- 1178
				Vec2(armX + cuffW * 0.82, armY + cuffH * 1.25), -- 1179
				1.3, -- 1180
				toColor( -- 1181
					____exports.CUFF_SHARED_SPEC.mendStitch, -- 1181
					math.floor(210 * shieldK + 0.5) -- 1181
				) -- 1181
			) -- 1181
			fillGradQuad( -- 1184
				fgDraw, -- 1185
				zX + cam:len(4), -- 1186
				zY + zH * 0.85, -- 1186
				Color( -- 1186
					10, -- 1186
					12, -- 1186
					18, -- 1186
					math.floor(92 * shieldK + 0.5) -- 1186
				), -- 1186
				zX + cam:len(4), -- 1187
				zY, -- 1187
				Color( -- 1187
					10, -- 1187
					12, -- 1187
					18, -- 1187
					math.floor(62 * shieldK + 0.5) -- 1187
				), -- 1187
				xX - cam:len(18), -- 1188
				xY, -- 1188
				Color(10, 12, 18, 0), -- 1188
				xX - cam:len(18), -- 1189
				xY + xH, -- 1189
				Color(10, 12, 18, 0) -- 1189
			) -- 1189
		end -- 1189
	end -- 1189
	if hintAlpha > 0.02 then -- 1189
		local baseWx = self.p04AnchorWorldX > 0 and self.p04AnchorWorldX or zhou.x -- 1196
		local hintBaseX = cam:sx(baseWx + 74) -- 1197
		local groundY = cam:sy(0, 0) -- 1198
		local boardW = cam:len(62) -- 1199
		local sheenBoost = flash * 0.55 -- 1200
		local aNorm = clamp01(hintAlpha + sheenBoost) -- 1201
		local placedBoard = worldArt:tryPlacePath( -- 1203
			"assets/art/cutscene_well_museum.clip|p04_window_board", -- 1204
			"p04_polished_window_board", -- 1205
			hintBaseX + boardW * 0.5, -- 1206
			groundY - 2, -- 1207
			boardW * 1.15, -- 1208
			cam:len(68), -- 1209
			{ -- 1210
				anchorX = 0.5, -- 1211
				anchorY = 0, -- 1212
				color = Color( -- 1213
					math.floor(188 + 64 * flash + 0.5), -- 1214
					math.floor(184 + 54 * flash + 0.5), -- 1215
					math.floor(176 + 34 * flash + 0.5), -- 1216
					255 -- 1217
				), -- 1217
				opacity = 0.88 * aNorm, -- 1219
				smooth = true, -- 1220
				layer = 4200 -- 1221
			} -- 1221
		) -- 1221
		if not placedBoard then -- 1221
			local boardY = groundY + cam:len(34) -- 1225
			fgDraw:drawRect( -- 1226
				Rect( -- 1227
					hintBaseX, -- 1227
					boardY, -- 1227
					boardW, -- 1227
					cam:len(12) -- 1227
				), -- 1227
				Color( -- 1228
					54, -- 1228
					42, -- 1228
					32, -- 1228
					math.floor(165 * aNorm + 0.5) -- 1228
				), -- 1228
				1, -- 1229
				Color( -- 1230
					126, -- 1230
					102, -- 1230
					76, -- 1230
					math.floor(150 * aNorm + 0.5) -- 1230
				) -- 1230
			) -- 1230
		end -- 1230
		fillRadialGlow( -- 1234
			fgGlow, -- 1235
			hintBaseX + boardW * 0.52, -- 1236
			groundY + cam:len(8), -- 1237
			boardW * 0.55, -- 1238
			cam:len(12), -- 1239
			Color( -- 1240
				232, -- 1240
				214, -- 1240
				178, -- 1240
				math.floor((46 + 84 * flash) * aNorm + 0.5) -- 1240
			), -- 1240
			Color(214, 186, 142, 0), -- 1241
			12 -- 1242
		) -- 1242
	end -- 1242
end -- 1112
return ____exports -- 1112