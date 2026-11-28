-- [ts]: tower_endings.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 28
local Color = ____Dora.Color -- 28
local Rect = ____Dora.Rect -- 28
local Vec2 = ____Dora.Vec2 -- 28
local ____play = require("Script.watch.play") -- 29
local TOWER_CONFIRM_TICKS = ____play.TOWER_CONFIRM_TICKS -- 29
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 34
local drawPatchedCuff = ____cuff_shots.drawPatchedCuff -- 34
local ____dialogues = require("Script.watch.dialogues") -- 36
local NEEDLE_NOTE_LINES = ____dialogues.NEEDLE_NOTE_LINES -- 36
local ____target = require("Script.watch.target") -- 37
local getActiveTarget = ____target.getActiveTarget -- 37
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 39
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 41
local TOWER_WEST_LAMP_LIGHT = ____lowpoly.TOWER_WEST_LAMP_LIGHT -- 42
local clamp01 = ____lowpoly.clamp01 -- 43
local normalize3 = ____lowpoly.normalize3 -- 44
local shadeSurface = ____lowpoly.shadeSurface -- 45
local smoothstep = ____lowpoly.smoothstep -- 46
local vec3 = ____lowpoly.vec3 -- 47
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 49
local drawComicSequence = ____slideshow.drawComicSequence -- 49
local ____theme = require("Script.watch.fe.theme") -- 50
local PALETTE = ____theme.PALETTE -- 51
local drawHairline = ____theme.drawHairline -- 53
local drawSilkVeil = ____theme.drawSilkVeil -- 54
local fillGradQuad = ____theme.fillGradQuad -- 55
local fillRadialGlow = ____theme.fillRadialGlow -- 56
local fillVGradRect = ____theme.fillVGradRect -- 57
local lerpRGBA = ____theme.lerpRGBA -- 58
local rgba = ____theme.rgba -- 59
local toColor = ____theme.toColor -- 60
--- 精确对齐后端 tower-knock(36 拍 = 0.6s, 第 0 / 12 拍敲门) 与 8.0 秒配对演出节拍
____exports.TOWER_ENDING_TIMINGS = { -- 90
	knock1Sec = 0, -- 91
	knock2Sec = 0.2, -- 92
	reply1Sec = 0.42, -- 93
	reply2Sec = 0.54, -- 94
	doorOpenSec = 0.6, -- 95
	indoorCutSec = 1.4, -- 96
	row1StartSec = 2.2, -- 97
	row1EndSec = 3.4, -- 98
	pivotStartSec = 3.4, -- 99
	pivotEndSec = 4.2, -- 100
	divergeEndSec = 6.8, -- 101
	holdReadySec = TOWER_CONFIRM_TICKS / 60 -- 102
} -- 102
local TOWER_AUDIO_ROOT = "assets/audio/tower/" -- 105
____exports.TOWER_AUDIO_FILES = { -- 107
	knock1 = TOWER_AUDIO_ROOT .. "door_knock_1.wav", -- 108
	knock2 = TOWER_AUDIO_ROOT .. "door_knock_2.wav", -- 109
	reply1 = TOWER_AUDIO_ROOT .. "door_reply_1.wav", -- 110
	reply2 = TOWER_AUDIO_ROOT .. "door_reply_2.wav", -- 111
	doorOpen = TOWER_AUDIO_ROOT .. "door_open.wav", -- 112
	bookOpen = TOWER_AUDIO_ROOT .. "book_open.wav", -- 113
	brush1 = TOWER_AUDIO_ROOT .. "brush_write_1.wav", -- 114
	brush2 = TOWER_AUDIO_ROOT .. "brush_write_2.wav", -- 115
	lampMove = TOWER_AUDIO_ROOT .. "lamp_move.wav", -- 116
	needlePlace = TOWER_AUDIO_ROOT .. "needle_case_place.wav", -- 117
	bowlSet = TOWER_AUDIO_ROOT .. "bowl_set.wav", -- 118
	windCold = TOWER_AUDIO_ROOT .. "tower_wind_cold.wav", -- 119
	roomWarm = TOWER_AUDIO_ROOT .. "tower_room_warm.wav", -- 120
	lineXiaomanLamp = TOWER_AUDIO_ROOT .. "line_xiaoman_lamp.wav", -- 121
	lineZhoushuName = TOWER_AUDIO_ROOT .. "line_zhoushu_name.wav" -- 122
} -- 122
--- 同机位配对布局真源（基准 1280×720 逻辑坐标系，F03 与 M03 100% 共享）：
-- 保证两版并排对照时门扇、门槛、提灯、西窗、簿页、一/二行基线、悬停笔尖、案沿热碗 0.00 px 偏差。
____exports.TOWER_SHOT_LAYOUT = { -- 129
	refW = 1280, -- 130
	refH = 720, -- 131
	letterboxH = 60, -- 132
	doorCenterX = 640, -- 134
	thresholdY = 168, -- 135
	doorW = 248, -- 136
	doorH = 374, -- 137
	knockHandX = 574, -- 138
	knockHandY = 312, -- 139
	doorLanternX = 710, -- 140
	doorLanternY = 344, -- 141
	westWindowX = 88, -- 143
	westWindowY = 382, -- 144
	westWindowW = 236, -- 145
	westWindowH = 224, -- 146
	deskTopY = 260, -- 147
	lampDeskX = 356, -- 148
	lampDeskY = 332, -- 149
	lampWindowX = 206, -- 150
	lampWindowY = 422, -- 151
	bookX = 416, -- 152
	bookY = 196, -- 153
	bookW = 588, -- 154
	bookH = 386, -- 155
	row1Y = 454, -- 156
	row1SubY = 424, -- 157
	row2Y = 354, -- 158
	row2SubY = 324, -- 159
	brushHoverTipX = 556, -- 160
	brushHoverTipY = 358, -- 161
	needleCaseDeskX = 294, -- 162
	needleCaseDeskY = 204, -- 163
	bowlRimX = 954, -- 164
	bowlRimY = 184, -- 165
	inkstoneX = 1112, -- 166
	inkstoneY = 256 -- 167
} -- 167
local F03_DIALOGUE = "「朝西那盏灯，能留着吗？」" -- 229
local M03_DIALOGUE = "「周戍。」" -- 230
--- F03 / M03 北塔门廊同机位配对 8 帧逐帧动画拍表（0.00..0.60s 叩门透光 → 0.60..1.50s 推门提灯跨槛，5.3–8.0 fps）
local F03_PORCH_COMIC_SEQ = { -- 233
	{slot = "comic_f03_f01", start = 0, ["end"] = 0.16, transition = "cut"}, -- 234
	{ -- 235
		slot = "comic_f03_f02", -- 235
		start = 0.16, -- 235
		["end"] = 0.3, -- 235
		transition = "cut", -- 235
		shakeAmp = 2.2, -- 235
		shakeFreq = 54 -- 235
	}, -- 235
	{slot = "comic_f03_f03", start = 0.3, ["end"] = 0.46, transition = "cut"}, -- 236
	{slot = "comic_f03_f04", start = 0.46, ["end"] = 0.62, transition = "cut"}, -- 237
	{slot = "comic_f03_f05", start = 0.62, ["end"] = 0.82, transition = "cut"}, -- 238
	{slot = "comic_f03_f06", start = 0.82, ["end"] = 1.02, transition = "cut"}, -- 239
	{slot = "comic_f03_f07", start = 1.02, ["end"] = 1.24, transition = "cut"}, -- 240
	{slot = "comic_f03_f08", start = 1.24, ["end"] = 1.5, transition = "cut"} -- 241
} -- 241
local M03_PORCH_COMIC_SEQ = { -- 243
	{slot = "comic_m03_f01", start = 0, ["end"] = 0.16, transition = "cut"}, -- 244
	{ -- 245
		slot = "comic_m03_f02", -- 245
		start = 0.16, -- 245
		["end"] = 0.3, -- 245
		transition = "cut", -- 245
		shakeAmp = 2.2, -- 245
		shakeFreq = 54 -- 245
	}, -- 245
	{slot = "comic_m03_f03", start = 0.3, ["end"] = 0.46, transition = "cut"}, -- 246
	{slot = "comic_m03_f04", start = 0.46, ["end"] = 0.62, transition = "cut"}, -- 247
	{slot = "comic_m03_f05", start = 0.62, ["end"] = 0.82, transition = "cut"}, -- 248
	{slot = "comic_m03_f06", start = 0.82, ["end"] = 1.02, transition = "cut"}, -- 249
	{slot = "comic_m03_f07", start = 1.02, ["end"] = 1.24, transition = "cut"}, -- 250
	{slot = "comic_m03_f08", start = 1.24, ["end"] = 1.5, transition = "cut"} -- 251
} -- 251
--- F03 拂晓冷室灯光预设（挪灯前），向 TOWER_WEST_LAMP_LIGHT（西窗暖灯）平滑插值
local TOWER_COLD_DAWN_LIGHT = { -- 255
	keyDir = normalize3(vec3(-0.34, 0.72, -0.6)), -- 256
	keyColor = rgba(146, 174, 206, 255), -- 257
	keyStrength = 0.74, -- 258
	rimDir = normalize3(vec3(0.68, 0.44, -0.58)), -- 259
	rimColor = rgba(182, 166, 140, 255), -- 260
	rimStrength = 0.24, -- 261
	ambientColor = rgba(18, 24, 38, 255), -- 262
	fogColor = rgba(16, 22, 34, 255), -- 263
	fogStartZ = 50, -- 264
	fogEndZ = 460, -- 265
	fogMaxAlpha = 0.78, -- 266
	shadowContrast = 0.78 -- 267
} -- 267
local function lerp(a, b, t) -- 270
	return a + (b - a) * t -- 271
end -- 270
local function lerpLightRig(a, b, t) -- 274
	local k = clamp01(t) -- 275
	return { -- 276
		keyDir = normalize3(vec3( -- 277
			lerp(a.keyDir.x, b.keyDir.x, k), -- 278
			lerp(a.keyDir.y, b.keyDir.y, k), -- 279
			lerp(a.keyDir.z, b.keyDir.z, k) -- 280
		)), -- 280
		keyColor = lerpRGBA(a.keyColor, b.keyColor, k), -- 282
		keyStrength = lerp(a.keyStrength, b.keyStrength, k), -- 283
		rimDir = normalize3(vec3( -- 284
			lerp(a.rimDir.x, b.rimDir.x, k), -- 285
			lerp(a.rimDir.y, b.rimDir.y, k), -- 286
			lerp(a.rimDir.z, b.rimDir.z, k) -- 287
		)), -- 287
		rimColor = lerpRGBA(a.rimColor, b.rimColor, k), -- 289
		rimStrength = lerp(a.rimStrength, b.rimStrength, k), -- 290
		ambientColor = lerpRGBA(a.ambientColor, b.ambientColor, k), -- 291
		fogColor = lerpRGBA(a.fogColor, b.fogColor, k), -- 292
		fogStartZ = lerp(a.fogStartZ, b.fogStartZ, k), -- 293
		fogEndZ = lerp(a.fogEndZ, b.fogEndZ, k), -- 294
		fogMaxAlpha = lerp(a.fogMaxAlpha, b.fogMaxAlpha, k), -- 295
		shadowContrast = lerp(a.shadowContrast, b.shadowContrast, k) -- 296
	} -- 296
end -- 274
local function computeScaledAnchors(uiW, uiH, lampProg) -- 300
	local s = math.min(uiW / ____exports.TOWER_SHOT_LAYOUT.refW, uiH / ____exports.TOWER_SHOT_LAYOUT.refH) -- 306
	local ox = (uiW - ____exports.TOWER_SHOT_LAYOUT.refW * s) * 0.5 -- 307
	local oy = (uiH - ____exports.TOWER_SHOT_LAYOUT.refH * s) * 0.5 -- 308
	local lx = lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) -- 309
	local ly = lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34 -- 310
	return {s = s, ox = ox, oy = oy, anchors = { -- 312
		doorCenterX = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s, -- 317
		thresholdY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s, -- 318
		knockHandX = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s, -- 319
		knockHandY = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s, -- 320
		bookX = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s, -- 321
		bookY = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s, -- 322
		bookW = ____exports.TOWER_SHOT_LAYOUT.bookW * s, -- 323
		bookH = ____exports.TOWER_SHOT_LAYOUT.bookH * s, -- 324
		row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s, -- 325
		row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s, -- 326
		brushHoverTipX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s, -- 327
		brushHoverTipY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s, -- 328
		bowlRimX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s, -- 329
		bowlRimY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s, -- 330
		lampCurX = ox + lx * s, -- 331
		lampCurY = oy + ly * s -- 332
	}} -- 332
end -- 300
local function deriveStage(seqElapsed, active) -- 337
	if not active then -- 337
		return "idle" -- 339
	end -- 339
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 339
		return "porch_knock" -- 342
	end -- 342
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 342
		return "door_open" -- 345
	end -- 345
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 345
		return "book_row1" -- 348
	end -- 348
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 348
		return "pivot_hover" -- 351
	end -- 351
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 351
		return "diverge_action" -- 354
	end -- 354
	return "ending_hold" -- 356
end -- 337
--- 将字符切片数组按进度拼接为前 n 段（避免 Lua 字节切片截断 UTF-8 汉字）
local function joinPrefixTokens(tokens, progress) -- 360
	if progress <= 0 or #tokens == 0 then -- 360
		return "" -- 362
	end -- 362
	local count = math.max( -- 364
		1, -- 364
		math.min( -- 364
			#tokens, -- 364
			math.ceil(progress * #tokens) -- 364
		) -- 364
	) -- 364
	local out = "" -- 365
	local i = 0 -- 366
	do -- 366
		i = 0 -- 367
		while i < count do -- 367
			out = out .. tokens[i + 1] -- 368
			i = i + 1 -- 367
		end -- 367
	end -- 367
	return out -- 370
end -- 360
local ROW1_TOKENS = { -- 373
	"小", -- 373
	"满", -- 373
	"  ", -- 373
	"·", -- 373
	"  ", -- 373
	"已", -- 373
	"收" -- 373
} -- 373
local ROW2_SOLDIER_TOKENS = { -- 374
	"周", -- 374
	"戍", -- 374
	"  ", -- 374
	"·", -- 374
	"  ", -- 374
	"兄", -- 374
	"妹", -- 374
	"同", -- 374
	"行", -- 374
	"  ", -- 374
	"·", -- 374
	"  ", -- 374
	"已", -- 374
	"收" -- 374
} -- 374
local function asRecord(v) -- 376
	if v ~= nil and type(v) == "table" then -- 376
		return v -- 378
	end -- 378
	return nil -- 380
end -- 376
--- 描边椭圆（Dora DrawNode.drawEllipse 仅支持填充，描边用等分折线保证锐利清晰）
local function strokeEllipse(draw, cx, cy, rx, ry, width, color, segments) -- 384
	if segments == nil then -- 384
		segments = 24 -- 392
	end -- 392
	if rx <= 0.5 or ry <= 0.5 or width <= 0.05 then -- 392
		return -- 395
	end -- 395
	local step = math.pi * 2 / segments -- 397
	local prevX = cx + rx -- 398
	local prevY = cy -- 399
	local i = 1 -- 400
	do -- 400
		i = 1 -- 401
		while i <= segments do -- 401
			local ang = i * step -- 402
			local nx = cx + math.cos(ang) * rx -- 403
			local ny = cy + math.sin(ang) * ry -- 404
			draw:drawSegment( -- 405
				Vec2(prevX, prevY), -- 405
				Vec2(nx, ny), -- 405
				width, -- 405
				color -- 405
			) -- 405
			prevX = nx -- 406
			prevY = ny -- 407
			i = i + 1 -- 401
		end -- 401
	end -- 401
end -- 384
local STONE_EDGE_FALLBACK = MING_MATERIALS.mingStoneStep.edge or PALETTE.silkDim -- 411
____exports.TowerEndingsPlugin = __TS__Class() -- 413
local TowerEndingsPlugin = ____exports.TowerEndingsPlugin -- 413
TowerEndingsPlugin.name = "TowerEndingsPlugin" -- 413
function TowerEndingsPlugin.prototype.____constructor(self) -- 413
	self.id = "fe-05-tower-endings" -- 414
	self.active = false -- 416
	self.rehearsalActive = false -- 417
	self.rehearsalRoute = "child" -- 418
	self.activeRoute = "child" -- 419
	self.seqElapsed = 0 -- 421
	self.holdElapsed = 0 -- 422
	self.animTime = 0 -- 423
	self.doorOpened = false -- 426
	self.knockCount = 0 -- 427
	self.replyKnockCount = 0 -- 428
	self.row1Written = false -- 429
	self.row2Written = false -- 430
	self.registryAppendCount = 0 -- 431
	self.staleInputMustRelease = false -- 434
	self.confirmReady = false -- 435
	self.earlyInputBlockedCount = 0 -- 436
	self.rehearsalAcknowledged = false -- 437
	self.lastRoomKey = "" -- 440
	self.indoorRetryCount = 0 -- 442
	self.doorClosedAfterRetry = false -- 443
	self.sessionId = 0 -- 444
	self.lastUiW = 1280 -- 447
	self.lastUiH = 720 -- 448
	self.lastSubtitle = "" -- 449
	self.prevPhase = "" -- 450
	self.loopsActive = false -- 451
	self.doorOpenOverlayElapsed = -1 -- 453
end -- 413
function TowerEndingsPlugin.prototype.resolveRoute(self, p, view) -- 456
	if self.rehearsalActive then -- 456
		return self.rehearsalRoute -- 458
	end -- 458
	if view.storyRoute == "soldier" then -- 458
		return "soldier" -- 461
	end -- 461
	if view.storyRoute == "child" then -- 461
		return "child" -- 464
	end -- 464
	local runRec = asRecord(p.run) -- 467
	local ____asRecord_1 = asRecord -- 468
	local ____temp_0 -- 468
	if runRec ~= nil then -- 468
		____temp_0 = runRec.story -- 468
	else -- 468
		____temp_0 = nil -- 468
	end -- 468
	local storyRec = ____asRecord_1(____temp_0) -- 468
	if storyRec ~= nil and storyRec.ending == "reunion" then -- 468
		return "soldier" -- 470
	end -- 470
	return p.childMode and "child" or "soldier" -- 473
end -- 456
function TowerEndingsPlugin.prototype.clearSequenceState(self, keepIndoorDoorOpen) -- 476
	self.active = keepIndoorDoorOpen -- 477
	self.seqElapsed = keepIndoorDoorOpen and ____exports.TOWER_ENDING_TIMINGS.indoorCutSec or 0 -- 478
	self.holdElapsed = 0 -- 479
	self.doorOpened = keepIndoorDoorOpen -- 480
	self.knockCount = keepIndoorDoorOpen and 2 or 0 -- 481
	self.replyKnockCount = keepIndoorDoorOpen and 2 or 0 -- 482
	if not keepIndoorDoorOpen then -- 482
		self.row1Written = false -- 484
		self.row2Written = false -- 485
		self.registryAppendCount = 0 -- 486
	end -- 486
	self.staleInputMustRelease = true -- 488
	self.confirmReady = false -- 489
	self.earlyInputBlockedCount = 0 -- 490
	self.rehearsalAcknowledged = false -- 491
	self.lastSubtitle = "" -- 492
	self.doorOpenOverlayElapsed = -1 -- 493
end -- 476
function TowerEndingsPlugin.prototype.startRehearsal(self, route, contract, opts) -- 499
	self.rehearsalActive = true -- 504
	self.rehearsalRoute = route -- 505
	self.activeRoute = route -- 506
	local tag = opts and opts.tag or (route == "child" and "fe05-F03" or "fe05-M03") -- 507
	if contract ~= nil then -- 507
		contract:enterRehearsal(tag) -- 509
		contract:setMockRoute(route) -- 510
	end -- 510
	local isIndoor = (opts and opts.indoorRetry) == true -- 512
	self.sessionId = self.sessionId + 1 -- 513
	self:clearSequenceState(isIndoor) -- 514
	self.active = true -- 515
	self.doorClosedAfterRetry = false -- 516
	if isIndoor then -- 516
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 518
	end -- 518
	if (opts and opts.seekTime) ~= nil then -- 518
		self:seekRehearsal(opts.seekTime) -- 521
	end -- 521
end -- 499
function TowerEndingsPlugin.prototype.seekRehearsal(self, seconds) -- 526
	if not self.rehearsalActive then -- 526
		return -- 528
	end -- 528
	local t = math.max(0, seconds) -- 530
	self.seqElapsed = t -- 531
	self.holdElapsed = math.max(0, t - ____exports.TOWER_ENDING_TIMINGS.divergeEndSec) -- 532
	self.active = true -- 533
	self:syncDerivedMilestones(t, self.activeRoute) -- 534
	self.confirmReady = not self.staleInputMustRelease and t >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 535
end -- 526
function TowerEndingsPlugin.prototype.triggerIndoorRetry(self) -- 539
	if not self.doorOpened and self.seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 539
		self.doorOpened = true -- 541
	end -- 541
	self.indoorRetryCount = self.indoorRetryCount + 1 -- 543
	self.doorClosedAfterRetry = false -- 544
	self.doorOpened = true -- 545
	self.active = true -- 546
	self.seqElapsed = math.max( -- 547
		____exports.TOWER_ENDING_TIMINGS.indoorCutSec, -- 547
		math.min(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.row1StartSec) -- 547
	) -- 547
	self.holdElapsed = 0 -- 548
	self.knockCount = math.max(2, self.knockCount) -- 549
	self.replyKnockCount = math.max(2, self.replyKnockCount) -- 550
	self.staleInputMustRelease = true -- 552
	self.confirmReady = false -- 553
end -- 539
function TowerEndingsPlugin.prototype.stopRehearsal(self, contract) -- 557
	self.rehearsalActive = false -- 558
	self:clearSequenceState(false) -- 559
	self.indoorRetryCount = 0 -- 560
	self.doorClosedAfterRetry = false -- 561
	if contract ~= nil then -- 561
		contract:exitRehearsal() -- 563
	end -- 563
end -- 557
function TowerEndingsPlugin.prototype.getDebugState(self) -- 567
	local route = self.activeRoute -- 568
	local lampProg = route == "child" and smoothstep(5.2, 6.75, self.seqElapsed) or 0 -- 569
	local scaled = computeScaledAnchors(self.lastUiW, self.lastUiH, lampProg) -- 572
	local visualStyle = route == "child" and "lowpoly" or "pixel" -- 573
	local needleOnDesk = route == "soldier" and self.seqElapsed >= 5.55 -- 574
	local twoHandsBowl = route == "soldier" and self.seqElapsed >= 5.95 -- 575
	return { -- 577
		active = self.active, -- 578
		isRehearsal = self.rehearsalActive, -- 579
		route = route, -- 580
		visualStyle = visualStyle, -- 581
		stage = deriveStage(self.seqElapsed, self.active), -- 582
		seqElapsed = self.seqElapsed, -- 583
		holdElapsed = self.holdElapsed, -- 584
		doorOpened = self.doorOpened, -- 585
		knockCount = self.knockCount, -- 586
		replyKnockCount = self.replyKnockCount, -- 587
		row1Written = self.row1Written, -- 588
		row1Name = self.row1Written and "小满" or "", -- 589
		row2Written = self.row2Written, -- 590
		row2Name = self.row2Written and "周戍" or "", -- 591
		row2Blank = not self.row2Written, -- 592
		hasCompletionStamp = false, -- 593
		registryRowCapacity = 2, -- 594
		registryAppendCount = self.registryAppendCount, -- 595
		lampProgress = lampProg, -- 596
		lampAtWestWindow = route == "child" and lampProg >= 0.99, -- 597
		needleCaseOnDesk = needleOnDesk, -- 598
		twoHandsHoldingBowl = twoHandsBowl, -- 599
		staleInputMustRelease = self.staleInputMustRelease, -- 600
		confirmReady = self.confirmReady, -- 601
		earlyInputBlockedCount = self.earlyInputBlockedCount, -- 602
		rehearsalAcknowledged = self.rehearsalAcknowledged, -- 603
		indoorRetryCount = self.indoorRetryCount, -- 604
		doorClosedAfterRetry = self.doorClosedAfterRetry, -- 605
		subtitleText = self.lastSubtitle, -- 606
		anchors = scaled.anchors -- 607
	} -- 607
end -- 567
function TowerEndingsPlugin.prototype.syncRuntimeHook(self) -- 611
	local g = _G -- 612
	local ____temp_8 -- 613
	if g.package ~= nil then -- 613
		____temp_8 = g.package.loaded -- 613
	else -- 613
		____temp_8 = nil -- 613
	end -- 613
	local loaded = ____temp_8 -- 613
	if loaded == nil then -- 613
		return -- 615
	end -- 615
	local rawFe = loaded["watch.fe"] -- 617
	if rawFe ~= nil and type(rawFe) == "table" then -- 617
		local watchFe = rawFe -- 619
		if watchFe.towerEndings ~= self then -- 619
			watchFe.towerEndings = self -- 621
		end -- 621
	end -- 621
end -- 611
function TowerEndingsPlugin.prototype.onBindPlay(self, p, view) -- 628
	self:syncRuntimeHook() -- 629
	self.sessionId = self.sessionId + 1 -- 630
	self.loopsActive = false -- 631
	self.prevPhase = p.phase -- 632
	if self.rehearsalActive then -- 632
		return -- 635
	end -- 635
	local route = self:resolveRoute(p, view) -- 638
	local isTower = p.room.key == "tower" -- 639
	local alreadyCutscenePhase = isTower and (p.phase == "tower-given" or p.phase == "tower-end") -- 640
	local alreadyIndoorPhase = isTower and (p.phase == "tower-enter" or p.phase == "tower-desk" or alreadyCutscenePhase) -- 641
	local sameRunIndoorRetry = isTower and self.lastRoomKey == "tower" and self.doorOpened and p.run == self.lastRunRef and route == self.activeRoute and (p.checkpoint > 0 or alreadyIndoorPhase) -- 646
	self.activeRoute = route -- 653
	self.lastRoomKey = p.room.key -- 654
	self.lastRunRef = p.run -- 655
	if not isTower then -- 655
		self:clearSequenceState(false) -- 658
		self.indoorRetryCount = 0 -- 659
		self.doorClosedAfterRetry = false -- 660
		return -- 661
	end -- 661
	if sameRunIndoorRetry or alreadyCutscenePhase then -- 661
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 666
		self.doorClosedAfterRetry = false -- 667
		self:clearSequenceState(true) -- 668
		if p.phase == "tower-end" then -- 668
			self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.divergeEndSec -- 670
			self:syncDerivedMilestones(self.seqElapsed, route) -- 671
		end -- 671
		return -- 673
	end -- 673
	if p.phase == "tower-enter" or p.phase == "tower-desk" then -- 673
		self:clearSequenceState(false) -- 678
		self.doorOpened = true -- 679
		self.replyKnockCount = 2 -- 680
		self.active = false -- 681
		return -- 682
	end -- 682
	self:clearSequenceState(false) -- 686
	self.indoorRetryCount = 0 -- 687
	self.doorClosedAfterRetry = false -- 688
end -- 628
function TowerEndingsPlugin.prototype.update(self, ctx) -- 691
	self:syncRuntimeHook() -- 692
	self.lastUiW = ctx.uiW -- 693
	self.lastUiH = ctx.uiH -- 694
	local p = ctx.p -- 695
	if not self.rehearsalActive and p.room.key ~= "tower" then -- 695
		if self.loopsActive then -- 695
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 699
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 700
			self.loopsActive = false -- 701
		end -- 701
		self.active = false -- 703
		return -- 704
	end -- 704
	local route = self:resolveRoute(p, ctx.view) -- 707
	self.activeRoute = route -- 708
	if not self.rehearsalActive then -- 708
		self:stepLiveSync(ctx, route) -- 711
	else -- 711
		self:stepRehearsal(ctx, route) -- 713
	end -- 713
	if not self.active then -- 713
		local inInteractiveHall = not self.rehearsalActive and p.room.key == "tower" and (p.phase == "tower-enter" or p.phase == "tower-desk") -- 717
		if self.loopsActive and not inInteractiveHall then -- 717
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 720
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 721
			self.loopsActive = false -- 722
		end -- 722
		return -- 724
	end -- 724
	if not ctx.paused and ctx.worldDt > 0 then -- 724
		self.animTime = self.animTime + ctx.worldDt -- 729
		self:syncDerivedMilestones(self.seqElapsed, route) -- 730
		self:syncAudioCues(ctx.audio, ctx, route) -- 731
		self:stepInputGuard(ctx.input) -- 732
	elseif not ctx.paused then -- 732
		self:syncDerivedMilestones(self.seqElapsed, route) -- 735
		self:stepInputGuard(ctx.input) -- 736
	end -- 736
	self.lastSubtitle = self:composeSubtitle(route) -- 739
end -- 691
function TowerEndingsPlugin.prototype.stepLiveSync(self, ctx, route) -- 742
	local p = ctx.p -- 743
	local phase = p.phase -- 744
	local cameFromKnock = self.prevPhase == "tower-knock" -- 745
	local justEnteredKnock = self.prevPhase ~= "tower-knock" and phase == "tower-knock" -- 746
	local justEnteredEnter = self.prevPhase ~= "tower-enter" and phase == "tower-enter" -- 747
	local justEnteredGiven = self.prevPhase ~= "tower-given" and phase == "tower-given" -- 748
	local justEnteredEnd = self.prevPhase ~= "tower-end" and phase == "tower-end" -- 749
	self.prevPhase = phase -- 750
	if phase == "tower-wait" then -- 750
		self.doorOpenOverlayElapsed = -1 -- 754
		self.active = false -- 755
		return -- 756
	end -- 756
	if phase == "tower-enter" then -- 756
		self.doorOpened = true -- 761
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 762
		if justEnteredEnter and self.indoorRetryCount == 0 and not ctx.paused then -- 762
			local tick = p.ticks -- 764
			self:playTowerOnce( -- 765
				ctx.audio, -- 765
				"reply1", -- 765
				"sfx", -- 765
				____exports.TOWER_AUDIO_FILES.reply1, -- 765
				0.78, -- 765
				"tower:reply:1", -- 765
				tick -- 765
			) -- 765
			self:playTowerOnce( -- 766
				ctx.audio, -- 766
				"reply2", -- 766
				"sfx", -- 766
				____exports.TOWER_AUDIO_FILES.reply2, -- 766
				0.8, -- 766
				"tower:reply:2", -- 766
				tick -- 766
			) -- 766
			self:playTowerOnce( -- 767
				ctx.audio, -- 767
				"door_open", -- 767
				"sfx", -- 767
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 767
				0.84, -- 767
				"tower:door_open", -- 767
				tick -- 767
			) -- 767
			ctx.audio:playLoop( -- 768
				"tower_room_warm", -- 768
				"ambience", -- 768
				____exports.TOWER_AUDIO_FILES.roomWarm, -- 768
				0.28, -- 768
				tick -- 768
			) -- 768
			self.loopsActive = true -- 769
			if cameFromKnock then -- 769
				self.doorOpenOverlayElapsed = 0 -- 771
			end -- 771
		end -- 771
		if self.doorOpenOverlayElapsed >= 0 then -- 771
			if p.player.x >= p.ox + 520 then -- 771
				self.doorOpenOverlayElapsed = -1 -- 776
			elseif not ctx.paused and ctx.worldDt > 0 then -- 776
				self.doorOpenOverlayElapsed = self.doorOpenOverlayElapsed + ctx.worldDt -- 778
				if self.doorOpenOverlayElapsed >= 0.9 then -- 778
					self.doorOpenOverlayElapsed = -1 -- 780
				end -- 780
			end -- 780
		end -- 780
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.doorOpenSec) -- 784
		self.active = false -- 785
		self:syncDerivedMilestones(self.seqElapsed, route) -- 786
		return -- 787
	end -- 787
	if phase == "tower-desk" then -- 787
		self.doorOpenOverlayElapsed = -1 -- 792
		self.doorOpened = true -- 793
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 794
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 795
		self.active = false -- 796
		self:syncDerivedMilestones(self.seqElapsed, route) -- 797
		return -- 798
	end -- 798
	if not self.active then -- 798
		self.active = true -- 802
		self.staleInputMustRelease = ctx.input.interact.held or ctx.input.retry.held or ctx.input.interact.pressed -- 803
		self.confirmReady = false -- 804
	end -- 804
	if justEnteredKnock then -- 804
		self.seqElapsed = p.phaseTick / 60 -- 808
		self.holdElapsed = 0 -- 809
		self.staleInputMustRelease = true -- 810
		self.confirmReady = false -- 811
	elseif justEnteredGiven then -- 811
		self.doorOpened = true -- 813
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 814
	elseif justEnteredEnd then -- 814
		self.doorOpened = true -- 816
		self.seqElapsed = math.max(self.seqElapsed, 3.6 + p.phaseTick / 60) -- 818
	end -- 818
	if not ctx.paused and #ctx.events.rawEvents > 0 then -- 818
		local i = 0 -- 823
		do -- 823
			i = 0 -- 824
			while i < #ctx.events.rawEvents do -- 824
				local ev = ctx.events.rawEvents[i + 1] -- 825
				if ev.name == "knock" then -- 825
					local cnt = type(ev.data.count) == "number" and ev.data.count or self.knockCount + 1 -- 827
					if cnt >= 1 and self.knockCount < 1 then -- 827
						self.knockCount = 1 -- 829
						self:playTowerOnce( -- 830
							ctx.audio, -- 830
							"knock1", -- 830
							"sfx", -- 830
							____exports.TOWER_AUDIO_FILES.knock1, -- 830
							0.88, -- 830
							"tower:knock:1", -- 830
							ev.tick, -- 830
							ev.seq -- 830
						) -- 830
					end -- 830
					if cnt >= 2 and self.knockCount < 2 then -- 830
						self.knockCount = 2 -- 833
						self:playTowerOnce( -- 834
							ctx.audio, -- 834
							"knock2", -- 834
							"sfx", -- 834
							____exports.TOWER_AUDIO_FILES.knock2, -- 834
							0.9, -- 834
							"tower:knock:2", -- 834
							ev.tick, -- 834
							ev.seq -- 834
						) -- 834
					end -- 834
				end -- 834
				i = i + 1 -- 824
			end -- 824
		end -- 824
	end -- 824
	if not ctx.paused and ctx.worldDt > 0 then -- 824
		if phase == "tower-knock" then -- 824
			local backendSec = math.min(____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60) -- 843
			self.seqElapsed = math.max(self.seqElapsed + ctx.worldDt, backendSec) -- 844
			if self.seqElapsed > ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 then -- 844
				self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 -- 846
			end -- 846
		else -- 846
			self.seqElapsed = self.seqElapsed + ctx.worldDt -- 849
			if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 849
				self.holdElapsed = self.holdElapsed + ctx.worldDt -- 851
			end -- 851
		end -- 851
	end -- 851
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 851
		self.doorClosedAfterRetry = true -- 857
	end -- 857
	self:syncDerivedMilestones(self.seqElapsed, route) -- 859
end -- 742
function TowerEndingsPlugin.prototype.stepRehearsal(self, ctx, route) -- 862
	self.active = true -- 863
	if not ctx.paused and ctx.worldDt > 0 then -- 863
		self.seqElapsed = self.seqElapsed + ctx.worldDt -- 865
		if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 865
			self.holdElapsed = self.holdElapsed + ctx.worldDt -- 867
		end -- 867
	end -- 867
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 867
		self.doorClosedAfterRetry = true -- 871
	end -- 871
	self:syncDerivedMilestones(self.seqElapsed, route) -- 873
end -- 862
function TowerEndingsPlugin.prototype.syncDerivedMilestones(self, t, route) -- 876
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec and self.knockCount < 1 then -- 876
		self.knockCount = 1 -- 878
	end -- 878
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec and self.knockCount < 2 then -- 878
		self.knockCount = 2 -- 881
	end -- 881
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec and self.replyKnockCount < 1 then -- 881
		self.replyKnockCount = 1 -- 884
	end -- 884
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec and self.replyKnockCount < 2 then -- 884
		self.replyKnockCount = 2 -- 887
	end -- 887
	if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 887
		self.doorOpened = true -- 890
	end -- 890
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec and not self.row1Written then -- 890
		self.row1Written = true -- 894
		self.registryAppendCount = self.registryAppendCount + 1 -- 895
	end -- 895
	if route == "soldier" and t >= 4.6 and not self.row2Written then -- 895
		self.row2Written = true -- 898
		self.registryAppendCount = self.registryAppendCount + 1 -- 899
	end -- 899
	if route == "child" and self.row2Written then -- 899
		self.row2Written = false -- 903
		self.registryAppendCount = self.row1Written and 1 or 0 -- 904
	end -- 904
end -- 876
function TowerEndingsPlugin.prototype.stepInputGuard(self, input) -- 908
	local keyHeld = input.interact.held or input.retry.held -- 909
	local keyPressed = input.interact.pressed or input.retry.pressed -- 910
	local readyTime = self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 911
	if self.staleInputMustRelease then -- 911
		if not keyHeld then -- 911
			self.staleInputMustRelease = false -- 915
		elseif keyPressed then -- 915
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 917
		end -- 917
		self.confirmReady = false -- 919
		return -- 920
	end -- 920
	if not readyTime then -- 920
		if keyPressed then -- 920
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 925
			self.staleInputMustRelease = keyHeld -- 926
		end -- 926
		self.confirmReady = false -- 928
		return -- 929
	end -- 929
	self.confirmReady = true -- 932
	if self.rehearsalActive and keyPressed then -- 932
		self.rehearsalAcknowledged = true -- 934
	end -- 934
end -- 908
function TowerEndingsPlugin.prototype.playTowerOnce(self, audio, tag, track, path, volume, cueId, tick, seq) -- 938
	if seq == nil then -- 938
		seq = -1 -- 946
	end -- 946
	local dedupeKey = (("tower:s" .. tostring(self.sessionId)) .. ":") .. tag -- 948
	audio:playOnce( -- 949
		dedupeKey, -- 949
		track, -- 949
		path, -- 949
		volume, -- 949
		cueId, -- 949
		tick, -- 949
		seq -- 949
	) -- 949
end -- 938
function TowerEndingsPlugin.prototype.syncAudioCues(self, audio, ctx, route) -- 952
	local t = self.seqElapsed -- 953
	local tick = ctx.p.ticks -- 954
	local indoorK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.5, t) -- 955
	self.loopsActive = true -- 958
	audio:playLoop( -- 959
		"tower_wind_cold", -- 959
		"wind", -- 959
		____exports.TOWER_AUDIO_FILES.windCold, -- 959
		lerp(0.36, 0.14, indoorK), -- 959
		tick -- 959
	) -- 959
	if indoorK > 0.05 then -- 959
		audio:playLoop( -- 961
			"tower_room_warm", -- 961
			"ambience", -- 961
			____exports.TOWER_AUDIO_FILES.roomWarm, -- 961
			lerp(0.06, 0.34, indoorK), -- 961
			tick -- 961
		) -- 961
	end -- 961
	if self.indoorRetryCount == 0 then -- 961
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec then -- 961
			self:playTowerOnce( -- 967
				audio, -- 967
				"knock1", -- 967
				"sfx", -- 967
				____exports.TOWER_AUDIO_FILES.knock1, -- 967
				0.88, -- 967
				"tower:knock:1", -- 967
				tick -- 967
			) -- 967
		end -- 967
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec then -- 967
			self:playTowerOnce( -- 970
				audio, -- 970
				"knock2", -- 970
				"sfx", -- 970
				____exports.TOWER_AUDIO_FILES.knock2, -- 970
				0.9, -- 970
				"tower:knock:2", -- 970
				tick -- 970
			) -- 970
		end -- 970
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 970
			self:playTowerOnce( -- 973
				audio, -- 973
				"reply1", -- 973
				"sfx", -- 973
				____exports.TOWER_AUDIO_FILES.reply1, -- 973
				0.78, -- 973
				"tower:reply:1", -- 973
				tick -- 973
			) -- 973
		end -- 973
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec then -- 973
			self:playTowerOnce( -- 976
				audio, -- 976
				"reply2", -- 976
				"sfx", -- 976
				____exports.TOWER_AUDIO_FILES.reply2, -- 976
				0.8, -- 976
				"tower:reply:2", -- 976
				tick -- 976
			) -- 976
		end -- 976
		if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 976
			self:playTowerOnce( -- 979
				audio, -- 979
				"door_open", -- 979
				"sfx", -- 979
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 979
				0.84, -- 979
				"tower:door_open", -- 979
				tick -- 979
			) -- 979
		end -- 979
	end -- 979
	if t >= 1.5 then -- 979
		self:playTowerOnce( -- 984
			audio, -- 984
			"book_open", -- 984
			"sfx", -- 984
			____exports.TOWER_AUDIO_FILES.bookOpen, -- 984
			0.82, -- 984
			"tower:book_open", -- 984
			tick -- 984
		) -- 984
	end -- 984
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 984
		self:playTowerOnce( -- 987
			audio, -- 987
			"brush1", -- 987
			"sfx", -- 987
			____exports.TOWER_AUDIO_FILES.brush1, -- 987
			0.8, -- 987
			"tower:brush:row1", -- 987
			tick -- 987
		) -- 987
	end -- 987
	if route == "child" then -- 987
		if t >= 4.35 then -- 987
			self:playTowerOnce( -- 992
				audio, -- 992
				"f03_line", -- 992
				"voice", -- 992
				____exports.TOWER_AUDIO_FILES.lineXiaomanLamp, -- 992
				0.86, -- 992
				"tower:f03:line_lamp", -- 992
				tick -- 992
			) -- 992
		end -- 992
		if t >= 4.45 then -- 992
			self:playTowerOnce( -- 995
				audio, -- 995
				"f03_bowl", -- 995
				"sfx", -- 995
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 995
				0.8, -- 995
				"tower:bowl_set", -- 995
				tick -- 995
			) -- 995
		end -- 995
		if t >= 5.2 then -- 995
			self:playTowerOnce( -- 998
				audio, -- 998
				"f03_lamp", -- 998
				"sfx", -- 998
				____exports.TOWER_AUDIO_FILES.lampMove, -- 998
				0.82, -- 998
				"tower:f03:lamp_move", -- 998
				tick -- 998
			) -- 998
		end -- 998
	else -- 998
		if t >= 4.28 then -- 998
			self:playTowerOnce( -- 1002
				audio, -- 1002
				"m03_line", -- 1002
				"voice", -- 1002
				____exports.TOWER_AUDIO_FILES.lineZhoushuName, -- 1002
				0.9, -- 1002
				"tower:m03:line_name", -- 1002
				tick -- 1002
			) -- 1002
		end -- 1002
		if t >= 4.62 then -- 1002
			self:playTowerOnce( -- 1005
				audio, -- 1005
				"brush2", -- 1005
				"sfx", -- 1005
				____exports.TOWER_AUDIO_FILES.brush2, -- 1005
				0.82, -- 1005
				"tower:brush:row2", -- 1005
				tick -- 1005
			) -- 1005
		end -- 1005
		if t >= 5.55 then -- 1005
			self:playTowerOnce( -- 1008
				audio, -- 1008
				"m03_needle", -- 1008
				"sfx", -- 1008
				____exports.TOWER_AUDIO_FILES.needlePlace, -- 1008
				0.8, -- 1008
				"tower:m03:needle_place", -- 1008
				tick -- 1008
			) -- 1008
		end -- 1008
		if t >= 6.02 then -- 1008
			self:playTowerOnce( -- 1011
				audio, -- 1011
				"m03_bowl", -- 1011
				"sfx", -- 1011
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 1011
				0.82, -- 1011
				"tower:bowl_set", -- 1011
				tick -- 1011
			) -- 1011
		end -- 1011
	end -- 1011
end -- 952
function TowerEndingsPlugin.prototype.composeSubtitle(self, route) -- 1016
	local t = self.seqElapsed -- 1017
	if t < ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 1017
		return "[两下轻敲]  门外厚木上传来两声轻敲。" -- 1019
	end -- 1019
	if t < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 1019
		return "[门内回敲]  静默一息，门后轻轻回敲两声。" -- 1022
	end -- 1022
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1022
		return route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 1025
	end -- 1025
	if t < ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 1025
		return route == "child" and "她把针套与纸条摊在案前，守卒展开收籍末页。" or "两人站在值夜室内，守卒摊开收籍末页。" -- 1030
	end -- 1030
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 1030
		return "守卒蘸墨提笔，在第一行写下「小满」。" -- 1035
	end -- 1035
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1035
		return "笔尖停在第二行上方。" -- 1038
	end -- 1038
	if route == "child" then -- 1038
		if t < 6.7 then -- 1038
			return F03_DIALOGUE -- 1042
		end -- 1042
		return "" -- 1044
	end -- 1044
	if t < 5.45 then -- 1044
		return M03_DIALOGUE -- 1047
	end -- 1047
	if t < 6.85 then -- 1047
		return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。" -- 1050
	end -- 1050
	return "" -- 1052
end -- 1016
function TowerEndingsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1057
	if not self.active then -- 1057
		if not self.rehearsalActive and ctx.p.room.key == "tower" and ctx.p.phase == "tower-enter" and self.doorOpenOverlayElapsed >= 0 then -- 1057
			local u = clamp01(self.doorOpenOverlayElapsed / 0.9) -- 1067
			local fade = 1 - smoothstep(0.28, 1, u) -- 1068
			if fade > 0.02 then -- 1068
				local route = self.activeRoute -- 1070
				local openK = smoothstep(0, 0.55, u) -- 1071
				local cx = ctx.uiW * 0.5 -- 1072
				local cy = ctx.uiH * 0.46 -- 1073
				uiDraw:drawRect( -- 1074
					Rect(0, 0, ctx.uiW, ctx.uiH), -- 1074
					Color( -- 1074
						8, -- 1074
						10, -- 1074
						16, -- 1074
						math.floor(145 * fade + 0.5) -- 1074
					) -- 1074
				) -- 1074
				fillRadialGlow( -- 1075
					uiGlow, -- 1076
					cx + 42 * (1 - openK), -- 1077
					cy + 16, -- 1078
					ctx.uiW * (0.26 + 0.18 * openK), -- 1079
					ctx.uiH * (0.34 + 0.16 * openK), -- 1080
					Color( -- 1081
						248, -- 1081
						212, -- 1081
						144, -- 1081
						math.floor(128 * fade + 0.5) -- 1081
					), -- 1081
					Color(220, 154, 72, 0), -- 1082
					18 -- 1083
				) -- 1083
				self:drawMingLantern( -- 1085
					uiInkDraw, -- 1085
					uiGlow, -- 1085
					cx + 66 - openK * 24, -- 1085
					cy + 28, -- 1085
					1.05, -- 1085
					fade * (0.45 + 0.55 * openK), -- 1085
					1 -- 1085
				) -- 1085
				local cap = route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 1086
				drawSilkVeil( -- 1089
					uiDraw, -- 1089
					uiArt, -- 1089
					"tower_door_open_veil", -- 1089
					cx, -- 1089
					ctx.uiH - 86, -- 1089
					560, -- 1089
					38, -- 1089
					PALETTE.inkWarm, -- 1089
					0.78 * fade, -- 1089
					2 -- 1089
				) -- 1089
				ctx.texts:put( -- 1090
					"sm", -- 1090
					cap, -- 1090
					cx, -- 1090
					ctx.uiH - 86, -- 1090
					toColor(PALETTE.amberCore), -- 1090
					0.5, -- 1090
					0.5, -- 1090
					"Center", -- 1090
					1, -- 1090
					fade, -- 1090
					0.08 -- 1090
				) -- 1090
			end -- 1090
		end -- 1090
		return false -- 1093
	end -- 1093
	local route = self.activeRoute -- 1096
	local t = self.seqElapsed -- 1097
	local lampProg = route == "child" and smoothstep(5.2, 6.75, t) or 0 -- 1098
	local scaled = computeScaledAnchors(ctx.uiW, ctx.uiH, lampProg) -- 1099
	local s = scaled.s -- 1100
	local ox = scaled.ox -- 1101
	local oy = scaled.oy -- 1102
	uiDraw:drawRect( -- 1105
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1105
		Color(8, 10, 16, 255) -- 1105
	) -- 1105
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1105
		self:drawAct1PorchAndDoor( -- 1109
			uiDraw, -- 1109
			uiInkDraw, -- 1109
			uiArt, -- 1109
			uiGlow, -- 1109
			ctx, -- 1109
			route, -- 1109
			s, -- 1109
			ox, -- 1109
			oy -- 1109
		) -- 1109
		local fadeOut = smoothstep(1.22, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec, t) -- 1111
		if fadeOut > 0.01 then -- 1111
			uiInkDraw:drawRect( -- 1113
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1113
				Color( -- 1113
					8, -- 1113
					10, -- 1113
					16, -- 1113
					math.floor(230 * fadeOut + 0.5) -- 1113
				) -- 1113
			) -- 1113
		end -- 1113
	else -- 1113
		self:drawAct2And3Guardroom( -- 1117
			uiDraw, -- 1117
			uiInkDraw, -- 1117
			uiArt, -- 1117
			uiGlow, -- 1117
			ctx, -- 1117
			route, -- 1117
			lampProg, -- 1117
			s, -- 1117
			ox, -- 1117
			oy -- 1117
		) -- 1117
		local fadeIn = 1 - smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.24, t) -- 1118
		if fadeIn > 0.01 then -- 1118
			uiInkDraw:drawRect( -- 1120
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1120
				Color( -- 1120
					8, -- 1120
					10, -- 1120
					16, -- 1120
					math.floor(220 * fadeIn + 0.5) -- 1120
				) -- 1120
			) -- 1120
		end -- 1120
	end -- 1120
	local barH = math.floor(____exports.TOWER_SHOT_LAYOUT.letterboxH * s + 0.5) -- 1125
	uiInkDraw:drawRect( -- 1126
		Rect(0, ctx.uiH - barH, ctx.uiW, barH), -- 1126
		Color(7, 9, 14, 248) -- 1126
	) -- 1126
	uiInkDraw:drawRect( -- 1127
		Rect(0, 0, ctx.uiW, barH), -- 1127
		Color(7, 9, 14, 248) -- 1127
	) -- 1127
	uiInkDraw:drawSegment( -- 1128
		Vec2(0, ctx.uiH - barH), -- 1128
		Vec2(ctx.uiW, ctx.uiH - barH), -- 1128
		0.9, -- 1128
		toColor(PALETTE.silkDim, 82) -- 1128
	) -- 1128
	uiInkDraw:drawSegment( -- 1129
		Vec2(0, barH), -- 1129
		Vec2(ctx.uiW, barH), -- 1129
		0.9, -- 1129
		toColor(PALETTE.silkDim, 82) -- 1129
	) -- 1129
	self:drawDialogueSubtitle( -- 1132
		uiDraw, -- 1132
		uiInkDraw, -- 1132
		uiArt, -- 1132
		ctx, -- 1132
		route, -- 1132
		s, -- 1132
		barH -- 1132
	) -- 1132
	return true -- 1134
end -- 1057
function TowerEndingsPlugin.prototype.drawAct1PorchAndDoor(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1139
	local t = self.seqElapsed -- 1150
	local openK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, 1.24, t) -- 1151
	local doorCx = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s -- 1152
	local threshY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s -- 1153
	local k1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock1Sec) / 0.055) ^ 2) -- 1156
	local k2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock2Sec) / 0.055) ^ 2) -- 1157
	local r1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply1Sec) / 0.06) ^ 2) -- 1158
	local r2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply2Sec) / 0.06) ^ 2) -- 1159
	drawComicSequence( -- 1161
		uiDraw, -- 1162
		uiInkDraw, -- 1163
		uiArt, -- 1164
		route == "child" and F03_PORCH_COMIC_SEQ or M03_PORCH_COMIC_SEQ, -- 1165
		t, -- 1166
		ctx.uiW, -- 1167
		ctx.uiH, -- 1168
		{ -- 1169
			letterboxH = 0, -- 1170
			opacity = 1, -- 1171
			layer = 1, -- 1172
			instancePrefix = route == "child" and "fe05_f03_porch" or "fe05_m03_porch", -- 1173
			accentBorder = false -- 1174
		} -- 1174
	) -- 1174
	if openK > 0.05 then -- 1174
		fillRadialGlow( -- 1180
			uiGlow, -- 1181
			doorCx + 18 * s, -- 1182
			threshY + 148 * s, -- 1183
			(140 + openK * 140) * s, -- 1184
			(160 + openK * 110) * s, -- 1185
			Color( -- 1186
				246, -- 1186
				204, -- 1186
				134, -- 1186
				math.floor(92 * openK + 0.5) -- 1186
			), -- 1186
			Color(220, 156, 72, 0), -- 1187
			18 -- 1188
		) -- 1188
	end -- 1188
	local kx = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s -- 1191
	local ky = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s -- 1192
	if k1Pulse > 0.08 or k2Pulse > 0.08 then -- 1192
		local amp = math.max(k1Pulse, k2Pulse) -- 1194
		local r = (18 + (1 - amp) * 34) * s -- 1195
		strokeEllipse( -- 1196
			uiInkDraw, -- 1196
			kx + 24 * s, -- 1196
			ky, -- 1196
			r, -- 1196
			r * 0.85, -- 1196
			1.8 * s, -- 1196
			toColor( -- 1196
				PALETTE.amberCore, -- 1196
				math.floor(215 * amp + 0.5) -- 1196
			), -- 1196
			24 -- 1196
		) -- 1196
	end -- 1196
	if r1Pulse > 0.08 or r2Pulse > 0.08 then -- 1196
		local amp = math.max(r1Pulse, r2Pulse) -- 1199
		local r = (24 + (1 - amp) * 42) * s -- 1200
		strokeEllipse( -- 1201
			uiInkDraw, -- 1201
			doorCx + 30 * s, -- 1201
			ky + 16 * s, -- 1201
			r, -- 1201
			r * 0.9, -- 1201
			1.6 * s, -- 1201
			toColor( -- 1201
				PALETTE.amber, -- 1201
				math.floor(190 * amp + 0.5) -- 1201
			), -- 1201
			24 -- 1201
		) -- 1201
	end -- 1201
end -- 1139
function TowerEndingsPlugin.prototype.drawAct2And3Guardroom(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy) -- 1207
	local t = self.seqElapsed -- 1219
	local isLowpoly = route == "child" -- 1220
	local deskY = oy + ____exports.TOWER_SHOT_LAYOUT.deskTopY * s -- 1221
	local ____isLowpoly_9 -- 1224
	if isLowpoly then -- 1224
		____isLowpoly_9 = self:drawF03LowpolyRoomAndWindow( -- 1225
			uiDraw, -- 1225
			uiArt, -- 1225
			uiGlow, -- 1225
			ctx, -- 1225
			lampProg, -- 1225
			s, -- 1225
			ox, -- 1225
			oy -- 1225
		) -- 1225
	else -- 1225
		____isLowpoly_9 = self:drawM03PixelRoomAndWindow( -- 1226
			uiDraw, -- 1226
			uiArt, -- 1226
			uiGlow, -- 1226
			ctx, -- 1226
			s, -- 1226
			ox, -- 1226
			oy -- 1226
		) -- 1226
	end -- 1226
	local paintedRoomOk = ____isLowpoly_9 -- 1224
	if not paintedRoomOk then -- 1224
		local deskTopCol = isLowpoly and toColor(shadeSurface( -- 1230
			MING_MATERIALS.mingTimber.base, -- 1232
			vec3(-0.25, 0.9, -0.35), -- 1233
			0, -- 1234
			1, -- 1235
			lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1236
			MING_MATERIALS.mingTimber -- 1237
		)) or Color(86, 60, 42, 255) -- 1237
		local deskFrontCol = isLowpoly and toColor(shadeSurface( -- 1240
			MING_MATERIALS.mingTimberDark.base, -- 1242
			vec3(0, 0.1, -0.99), -- 1243
			-4, -- 1243
			1, -- 1245
			lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1246
			MING_MATERIALS.mingTimberDark -- 1247
		)) or Color(52, 36, 26, 255) -- 1247
		uiDraw:drawPolygon( -- 1250
			{ -- 1250
				Vec2(0, deskY - 120 * s), -- 1251
				Vec2(ctx.uiW, deskY - 120 * s), -- 1252
				Vec2(ctx.uiW, deskY + 42 * s), -- 1253
				Vec2(0, deskY + 42 * s) -- 1254
			}, -- 1254
			deskTopCol -- 1255
		) -- 1255
		uiDraw:drawRect( -- 1256
			Rect(0, 0, ctx.uiW, deskY - 118 * s), -- 1256
			deskFrontCol -- 1256
		) -- 1256
		local inkX = ox + ____exports.TOWER_SHOT_LAYOUT.inkstoneX * s -- 1257
		local inkY = oy + ____exports.TOWER_SHOT_LAYOUT.inkstoneY * s -- 1258
		uiDraw:drawPolygon( -- 1259
			{ -- 1259
				Vec2(inkX - 38 * s, inkY - 18 * s), -- 1260
				Vec2(inkX + 38 * s, inkY - 18 * s), -- 1261
				Vec2(inkX + 32 * s, inkY + 18 * s), -- 1262
				Vec2(inkX - 32 * s, inkY + 18 * s) -- 1263
			}, -- 1263
			Color(38, 44, 52, 255), -- 1264
			1.2, -- 1264
			Color(96, 106, 118, 185) -- 1264
		) -- 1264
	end -- 1264
	local lx = isLowpoly and ox + lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s or ox + ____exports.TOWER_SHOT_LAYOUT.lampDeskX * s -- 1268
	local ly = isLowpoly and oy + (lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34) * s or oy + ____exports.TOWER_SHOT_LAYOUT.lampDeskY * s -- 1271
	local lampWarmth = isLowpoly and 0.45 + 0.55 * lampProg or 0.92 -- 1274
	if not paintedRoomOk then -- 1274
		self:drawMingLantern( -- 1276
			uiInkDraw, -- 1276
			uiGlow, -- 1276
			lx, -- 1276
			ly, -- 1276
			1.02 * s, -- 1276
			1, -- 1276
			lampWarmth -- 1276
		) -- 1276
	elseif isLowpoly then -- 1276
		local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 1279
		fillRadialGlow( -- 1280
			uiGlow, -- 1281
			lx, -- 1282
			ly + 4 * s, -- 1283
			118 * s * flicker * (0.65 + 0.45 * lampProg), -- 1284
			118 * s * flicker * (0.65 + 0.45 * lampProg), -- 1285
			Color( -- 1286
				250, -- 1286
				208, -- 1286
				132, -- 1286
				math.floor((78 + 56 * lampProg) * flicker + 0.5) -- 1286
			), -- 1286
			Color(228, 162, 74, 0), -- 1287
			16 -- 1288
		) -- 1288
	else -- 1288
		local flicker = 0.92 + 0.08 * math.sin(self.animTime * 6.8) -- 1292
		fillRadialGlow( -- 1293
			uiGlow, -- 1294
			ox + 266 * s, -- 1295
			oy + 272 * s, -- 1296
			148 * s * flicker, -- 1297
			138 * s * flicker, -- 1298
			Color( -- 1299
				252, -- 1299
				212, -- 1299
				138, -- 1299
				math.floor(88 * flicker + 0.5) -- 1299
			), -- 1299
			Color(232, 168, 76, 0), -- 1300
			16 -- 1301
		) -- 1301
	end -- 1301
	if isLowpoly and lampProg > 0.04 then -- 1301
		local beamA = math.floor(62 * lampProg + 0.5) -- 1307
		fillGradQuad( -- 1308
			uiGlow, -- 1309
			lx + 10 * s, -- 1310
			ly + 30 * s, -- 1310
			Color(248, 206, 134, beamA), -- 1310
			lx + 10 * s, -- 1311
			ly - 32 * s, -- 1311
			Color( -- 1311
				248, -- 1311
				206, -- 1311
				134, -- 1311
				math.floor(beamA * 0.72 + 0.5) -- 1311
			), -- 1311
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.92) * s, -- 1312
			oy + (____exports.TOWER_SHOT_LAYOUT.row2Y - 58) * s, -- 1312
			Color(242, 198, 124, 0), -- 1312
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.85) * s, -- 1313
			oy + (____exports.TOWER_SHOT_LAYOUT.row1Y + 48) * s, -- 1313
			Color(242, 198, 124, 0) -- 1313
		) -- 1313
	end -- 1313
	local bookReveal = smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t) -- 1318
	if bookReveal > 0.02 then -- 1318
		self:drawRegisterBook( -- 1320
			uiDraw, -- 1320
			uiInkDraw, -- 1320
			uiArt, -- 1320
			uiGlow, -- 1320
			ctx, -- 1320
			route, -- 1320
			bookReveal, -- 1320
			lampProg, -- 1320
			s, -- 1320
			ox, -- 1320
			oy -- 1320
		) -- 1320
	end -- 1320
	self:drawDeskPropsAndBowl( -- 1324
		uiDraw, -- 1324
		uiInkDraw, -- 1324
		uiArt, -- 1324
		uiGlow, -- 1324
		ctx, -- 1324
		route, -- 1324
		paintedRoomOk, -- 1324
		s, -- 1324
		ox, -- 1324
		oy -- 1324
	) -- 1324
end -- 1207
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, lampProg, s, ox, oy) -- 1327
	local scaleCover = math.max(ctx.uiW / 960, ctx.uiH / 540) -- 1337
	local imgW = 960 * scaleCover -- 1338
	local imgH = 540 * scaleCover -- 1339
	local t = self.seqElapsed -- 1340
	local f03Slot = t < 2.4 and "comic_f03_f09" or (t < 3.4 and "comic_f03_f10" or (t < 4.3 and "comic_f03_f11" or (t < 5.2 and "comic_f03_f12" or (t < 5.45 and "comic_f03_f13" or (t < 5.7 and "comic_f03_f14" or (t < 5.95 and "comic_f03_f15" or (t < 6.2 and "comic_f03_f16" or (t < 6.65 and "comic_f03_f17" or (t < 7.1 and "comic_f03_f18" or (t < 7.6 and "comic_f03_f19" or "comic_f03_f20")))))))))) -- 1341
	local placedComic = uiArt:tryPlace( -- 1353
		f03Slot, -- 1354
		"fe05_f03_comic_bg", -- 1355
		ctx.uiW * 0.5, -- 1356
		ctx.uiH * 0.5, -- 1357
		imgW, -- 1358
		imgH, -- 1359
		{opacity = 1, layer = -8} -- 1360
	) -- 1360
	if placedComic then -- 1360
		if lampProg > 0.02 then -- 1360
			local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1367
			local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1368
			local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1369
			fillRadialGlow( -- 1370
				uiGlow, -- 1371
				wx + ww * 0.58, -- 1371
				wy + 22 * s, -- 1371
				580 * s, -- 1372
				420 * s, -- 1372
				Color( -- 1373
					248, -- 1373
					198, -- 1373
					122, -- 1373
					math.floor(92 * lampProg + 0.5) -- 1373
				), -- 1373
				Color(216, 152, 68, 0), -- 1374
				20 -- 1375
			) -- 1375
		end -- 1375
		return true -- 1378
	end -- 1378
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1382
	local wallTop = lerpRGBA( -- 1383
		rgba(18, 24, 38, 255), -- 1383
		rgba(46, 36, 28, 255), -- 1383
		lampProg -- 1383
	) -- 1383
	local wallBot = lerpRGBA( -- 1384
		rgba(12, 16, 26, 255), -- 1384
		rgba(28, 22, 20, 255), -- 1384
		lampProg -- 1384
	) -- 1384
	fillVGradRect( -- 1385
		uiDraw, -- 1385
		0, -- 1385
		0, -- 1385
		ctx.uiW, -- 1385
		ctx.uiH, -- 1385
		toColor(wallBot), -- 1385
		toColor(wallTop) -- 1385
	) -- 1385
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1386
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1387
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1388
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1389
	fillVGradRect( -- 1390
		uiDraw, -- 1390
		wx, -- 1390
		wy, -- 1390
		ww, -- 1390
		wh, -- 1390
		Color(34, 44, 62, 255), -- 1390
		Color(16, 24, 40, 255) -- 1390
	) -- 1390
	local sillCol = shadeSurface( -- 1391
		MING_MATERIALS.mingStoneStep.base, -- 1391
		vec3(0, 0.94, -0.34), -- 1391
		6, -- 1391
		1, -- 1391
		light, -- 1391
		MING_MATERIALS.mingStoneStep -- 1391
	) -- 1391
	uiDraw:drawRect( -- 1392
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1392
		toColor(sillCol) -- 1392
	) -- 1392
	return false -- 1393
end -- 1327
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1396
	local scaleCover = math.max(ctx.uiW / 960, ctx.uiH / 540) -- 1405
	local imgW = 960 * scaleCover -- 1406
	local imgH = 540 * scaleCover -- 1407
	local t = self.seqElapsed -- 1408
	local m03Slot = t < 2.4 and "comic_m03_f09" or (t < 3.2 and "comic_m03_f10" or (t < 3.75 and "comic_m03_f11" or (t < 4.2 and "comic_m03_f12" or (t < 4.68 and "comic_m03_f13" or (t < 5.16 and "comic_m03_f14" or (t < 5.62 and "comic_m03_f15" or (t < 6.08 and "comic_m03_f16" or (t < 6.55 and "comic_m03_f17" or (t < 7.05 and "comic_m03_f18" or (t < 7.6 and "comic_m03_f19" or "comic_m03_f20")))))))))) -- 1409
	local placedWarm = uiArt:tryPlace( -- 1421
		m03Slot, -- 1422
		"fe05_m03_comic_bg", -- 1423
		ctx.uiW * 0.5, -- 1424
		ctx.uiH * 0.5, -- 1425
		imgW, -- 1426
		imgH, -- 1427
		{opacity = 1, layer = -8} -- 1428
	) -- 1428
	if placedWarm then -- 1428
		fillRadialGlow( -- 1434
			uiGlow, -- 1435
			ox + 260 * s, -- 1435
			oy + 416 * s, -- 1435
			520 * s, -- 1436
			360 * s, -- 1436
			Color(246, 202, 134, 62), -- 1437
			Color(220, 158, 76, 0), -- 1438
			20 -- 1439
		) -- 1439
		return true -- 1441
	end -- 1441
	fillVGradRect( -- 1444
		uiDraw, -- 1445
		0, -- 1445
		0, -- 1445
		ctx.uiW, -- 1445
		ctx.uiH, -- 1445
		Color(26, 21, 20, 255), -- 1446
		Color(46, 36, 30, 255) -- 1447
	) -- 1447
	local groupX = ox + 210 * s -- 1449
	local groupY = oy + 300 * s -- 1450
	uiArt:tryPlace( -- 1451
		"soldier_idle", -- 1451
		"fe05_m03_room_soldier", -- 1451
		groupX - 38 * s, -- 1451
		groupY, -- 1451
		118 * s, -- 1451
		166 * s, -- 1451
		{facing = 1, opacity = 0.9, layer = 1} -- 1451
	) -- 1451
	uiArt:tryPlace( -- 1454
		"child_idle", -- 1454
		"fe05_m03_room_child", -- 1454
		groupX + 42 * s, -- 1454
		groupY, -- 1454
		86 * s, -- 1454
		116 * s, -- 1454
		{facing = 1, opacity = 0.92, layer = 1} -- 1454
	) -- 1454
	return false -- 1457
end -- 1396
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1460
	local t = self.seqElapsed -- 1473
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1474
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1475
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1476
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1477
	local midX = bx + bw * 0.5 -- 1478
	local midY = by + bh * 0.5 -- 1479
	uiDraw:drawRect( -- 1482
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1482
		Color( -- 1482
			10, -- 1482
			11, -- 1482
			16, -- 1482
			math.floor(108 * reveal + 0.5) -- 1482
		) -- 1482
	) -- 1482
	uiDraw:drawRect( -- 1483
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1483
		Color( -- 1483
			32, -- 1483
			46, -- 1483
			62, -- 1483
			math.floor(235 * reveal + 0.5) -- 1483
		), -- 1483
		1, -- 1483
		Color( -- 1483
			86, -- 1483
			104, -- 1483
			124, -- 1483
			math.floor(165 * reveal + 0.5) -- 1483
		) -- 1483
	) -- 1483
	if not uiArt:tryPlace( -- 1483
		"ink_song_paper", -- 1486
		"fe05_registry_paper", -- 1486
		midX, -- 1486
		midY, -- 1486
		bw, -- 1486
		bh, -- 1486
		{opacity = 0.98 * reveal, layer = 1} -- 1486
	) then -- 1486
		uiDraw:drawRect( -- 1487
			Rect(bx, by, bw, bh), -- 1488
			toColor( -- 1489
				PALETTE.xuanPaper, -- 1489
				math.floor(248 * reveal + 0.5) -- 1489
			), -- 1489
			1, -- 1490
			toColor( -- 1491
				PALETTE.silkDim, -- 1491
				math.floor(180 * reveal + 0.5) -- 1491
			) -- 1491
		) -- 1491
	end -- 1491
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1496
	fillRadialGlow( -- 1497
		uiGlow, -- 1498
		bx + bw * 0.34, -- 1498
		by + bh * 0.48, -- 1498
		bw * 0.58, -- 1499
		bh * 0.52, -- 1499
		Color( -- 1500
			246, -- 1500
			214, -- 1500
			156, -- 1500
			math.floor(44 * paperWarm * reveal + 0.5) -- 1500
		), -- 1500
		Color(238, 198, 128, 0), -- 1501
		16 -- 1502
	) -- 1502
	local padX = 44 * s -- 1506
	local padY = 32 * s -- 1507
	local inX = bx + padX -- 1508
	local inY = by + padY -- 1509
	local inW = bw - padX * 2 -- 1510
	local inH = bh - padY * 2 -- 1511
	local redSilk = toColor( -- 1512
		PALETTE.rouge, -- 1512
		math.floor(132 * reveal + 0.5) -- 1512
	) -- 1512
	local redFaint = toColor( -- 1513
		PALETTE.rouge, -- 1513
		math.floor(70 * reveal + 0.5) -- 1513
	) -- 1513
	uiInkDraw:drawRect( -- 1514
		Rect(inX, inY, inW, inH), -- 1514
		Color(0, 0, 0, 0), -- 1514
		1, -- 1514
		redSilk -- 1514
	) -- 1514
	uiInkDraw:drawRect( -- 1515
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1515
		Color(0, 0, 0, 0), -- 1515
		0.6, -- 1515
		redFaint -- 1515
	) -- 1515
	local headY = inY + inH - 28 * s -- 1518
	ctx.texts:put( -- 1519
		"md", -- 1519
		"北塔值夜收籍 · 末页", -- 1519
		inX + 18 * s, -- 1519
		headY, -- 1519
		toColor(PALETTE.xuanInk), -- 1519
		0, -- 1519
		0.5, -- 1519
		"Left", -- 1519
		2.2, -- 1519
		0.96 * reveal, -- 1519
		0 -- 1519
	) -- 1519
	ctx.texts:put( -- 1520
		"xs", -- 1520
		"宁村北塔", -- 1520
		inX + inW - 18 * s, -- 1520
		headY, -- 1520
		toColor(PALETTE.xuanInkSub), -- 1520
		1, -- 1520
		0.5, -- 1520
		"Right", -- 1520
		1.8, -- 1520
		0.8 * reveal, -- 1520
		0 -- 1520
	) -- 1520
	uiInkDraw:drawSegment( -- 1521
		Vec2(inX + 14 * s, headY - 22 * s), -- 1521
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1521
		0.9, -- 1521
		redSilk -- 1521
	) -- 1521
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1524
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1525
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1526
	ctx.texts:put( -- 1527
		"sm", -- 1527
		"肆拾壹", -- 1527
		inX + 18 * s, -- 1527
		row1Y, -- 1527
		toColor(PALETTE.rouge), -- 1527
		0, -- 1527
		0.5, -- 1527
		"Left", -- 1527
		1, -- 1527
		0.94 * reveal, -- 1527
		0 -- 1527
	) -- 1527
	if r1Prog > 0.02 then -- 1527
		ctx.texts:put( -- 1529
			"md", -- 1529
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1529
			inX + 96 * s, -- 1529
			row1Y, -- 1529
			toColor(PALETTE.xuanInk), -- 1529
			0, -- 1529
			0.5, -- 1529
			"Left", -- 1529
			1.6, -- 1529
			0.96 * math.min(1, r1Prog * 1.4), -- 1529
			0 -- 1529
		) -- 1529
	end -- 1529
	if r1Prog > 0.65 then -- 1529
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1532
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1533
		ctx.texts:put( -- 1536
			"xs", -- 1536
			subText, -- 1536
			inX + 96 * s, -- 1536
			row1SubY, -- 1536
			toColor(PALETTE.xuanInkSub), -- 1536
			0, -- 1536
			0.5, -- 1536
			"Left", -- 1536
			0.6, -- 1536
			0.88 * subA, -- 1536
			0 -- 1536
		) -- 1536
	end -- 1536
	uiInkDraw:drawSegment( -- 1538
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1538
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1538
		0.7, -- 1538
		redFaint -- 1538
	) -- 1538
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1541
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1542
	ctx.texts:put( -- 1543
		"sm", -- 1543
		"肆拾贰", -- 1543
		inX + 18 * s, -- 1543
		row2Y, -- 1543
		toColor(PALETTE.rouge), -- 1543
		0, -- 1543
		0.5, -- 1543
		"Left", -- 1543
		1, -- 1543
		0.94 * reveal, -- 1543
		0 -- 1543
	) -- 1543
	if route == "child" then -- 1543
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1547
		uiInkDraw:drawSegment( -- 1548
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1549
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1550
			1, -- 1551
			toColor(PALETTE.xuanInkSub, lineA) -- 1552
		) -- 1552
	else -- 1552
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1556
		if r2Prog <= 0.02 then -- 1556
			uiInkDraw:drawSegment( -- 1558
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1559
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1560
				0.9, -- 1561
				toColor( -- 1562
					PALETTE.xuanInkSub, -- 1562
					math.floor(105 * reveal + 0.5) -- 1562
				) -- 1562
			) -- 1562
		else -- 1562
			ctx.texts:put( -- 1565
				"md", -- 1565
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1565
				inX + 96 * s, -- 1565
				row2Y, -- 1565
				toColor(PALETTE.xuanInk), -- 1565
				0, -- 1565
				0.5, -- 1565
				"Left", -- 1565
				1.6, -- 1565
				0.96 * math.min(1, r2Prog * 1.4), -- 1565
				0 -- 1565
			) -- 1565
			if r2Prog > 0.65 then -- 1565
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1567
				ctx.texts:put( -- 1568
					"xs", -- 1568
					"守城戍卒亲口报出姓名，两人俱安。", -- 1568
					inX + 96 * s, -- 1568
					row2SubY, -- 1568
					toColor(PALETTE.xuanInkSub), -- 1568
					0, -- 1568
					0.5, -- 1568
					"Left", -- 1568
					0.6, -- 1568
					0.88 * subA, -- 1568
					0 -- 1568
				) -- 1568
			end -- 1568
		end -- 1568
	end -- 1568
	uiInkDraw:drawSegment( -- 1572
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1572
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1572
		0.7, -- 1572
		redFaint -- 1572
	) -- 1572
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1575
	if colophonA > 0.02 then -- 1575
		local signY = inY + 34 * s -- 1577
		ctx.texts:put( -- 1578
			"banner", -- 1578
			"向西守望", -- 1578
			midX - 24 * s, -- 1578
			signY, -- 1578
			toColor(PALETTE.xuanInk), -- 1578
			0.5, -- 1578
			0.5, -- 1578
			"Center", -- 1578
			6, -- 1578
			0.88 * colophonA, -- 1578
			0 -- 1578
		) -- 1578
	end -- 1578
	self:drawGuardBrushHand( -- 1582
		uiInkDraw, -- 1582
		uiArt, -- 1582
		route, -- 1582
		s, -- 1582
		ox, -- 1582
		oy -- 1582
	) -- 1582
end -- 1460
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, uiArt, route, s, ox, oy) -- 1585
	local t = self.seqElapsed -- 1593
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1594
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1595
	local row1X0 = hoverX -- 1596
	local row1X1 = hoverX + 142 * s -- 1597
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1598
	local tipX = hoverX -- 1600
	local tipY = hoverY -- 1601
	local alpha = 0 -- 1602
	local lifted = 0 -- 1603
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1603
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1607
		tipX = lerp(row1X0, row1X1, k) -- 1608
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1609
		alpha = smoothstep(2, 2.2, t) -- 1610
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1611
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1611
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1614
		tipX = lerp(row1X1, hoverX, moveK) -- 1615
		tipY = lerp(row1Y, hoverY, moveK) -- 1616
		alpha = 1 -- 1617
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1618
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1618
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1621
		tipX = hoverX + outK * 140 * s -- 1622
		tipY = hoverY + outK * 46 * s -- 1623
		lifted = (9 + outK * 28) * s -- 1624
		alpha = 1 - outK -- 1625
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1625
		if t < 4.6 then -- 1625
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1629
			tipX = hoverX -- 1630
			tipY = hoverY -- 1631
			lifted = lerp(9 * s, 0, dipK) -- 1632
			alpha = 1 -- 1633
		elseif t < 5.55 then -- 1633
			local wK = smoothstep(4.6, 5.55, t) -- 1635
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1636
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1637
			lifted = 0 -- 1638
			alpha = 1 -- 1639
		else -- 1639
			local outK = smoothstep(5.55, 6.05, t) -- 1641
			tipX = hoverX + 216 * s + outK * 115 * s -- 1642
			tipY = hoverY + outK * 52 * s -- 1643
			lifted = outK * 24 * s -- 1644
			alpha = 1 - outK -- 1645
		end -- 1645
	end -- 1645
	if alpha <= 0.02 then -- 1645
		return -- 1650
	end -- 1650
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1653
	local bx = tipX -- 1654
	local by = tipY + lifted -- 1655
	uiInkDraw:drawEllipse( -- 1657
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1657
		(5 + lifted * 0.22) * s, -- 1657
		2.8 * s, -- 1657
		Color( -- 1657
			20, -- 1657
			18, -- 1657
			16, -- 1657
			math.floor(78 * alpha + 0.5) -- 1657
		) -- 1657
	) -- 1657
	if uiArt:tryPlacePath( -- 1657
		"assets/art/cutscene_story_parts.clip|guard_brush_hand", -- 1660
		"fe05_guard_brush_hand", -- 1661
		bx, -- 1662
		by, -- 1663
		344 * s, -- 1664
		268 * s, -- 1665
		{ -- 1666
			anchorX = 0.03, -- 1667
			anchorY = 0.03, -- 1668
			opacity = clamp01(alpha), -- 1669
			smooth = true, -- 1670
			layer = 6 -- 1671
		} -- 1671
	) then -- 1671
		return -- 1674
	end -- 1674
	uiInkDraw:drawPolygon( -- 1677
		{ -- 1677
			Vec2(bx, by), -- 1678
			Vec2(bx + 15 * s, by - 4 * s), -- 1679
			Vec2(bx + 10 * s, by + 8 * s) -- 1680
		}, -- 1680
		Color(22, 22, 26, a) -- 1681
	) -- 1681
	uiInkDraw:drawSegment( -- 1682
		Vec2(bx + 12 * s, by + 2 * s), -- 1682
		Vec2(bx + 122 * s, by + 34 * s), -- 1682
		6.8 * s, -- 1682
		Color(142, 110, 74, a) -- 1682
	) -- 1682
end -- 1585
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, paintedRoomOk, s, ox, oy) -- 1685
	local t = self.seqElapsed -- 1697
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1698
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1699
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1700
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1701
	if paintedRoomOk then -- 1701
		if route == "child" then -- 1701
			local noteReadA = smoothstep(1.65, 2.1, t) * (1 - smoothstep(3.65, 4.15, t)) -- 1706
			if noteReadA > 0.02 then -- 1706
				local cardX = ncX + 52 * s -- 1708
				local cardY = ncY + 72 * s -- 1709
				uiInkDraw:drawRect( -- 1710
					Rect(cardX - 118 * s, cardY - 30 * s, 236 * s, 60 * s), -- 1711
					toColor( -- 1712
						PALETTE.xuanPaper, -- 1712
						math.floor(238 * noteReadA + 0.5) -- 1712
					), -- 1712
					1, -- 1713
					toColor( -- 1714
						PALETTE.rouge, -- 1714
						math.floor(110 * noteReadA + 0.5) -- 1714
					) -- 1714
				) -- 1714
				ctx.texts:put( -- 1716
					"xs", -- 1716
					NEEDLE_NOTE_LINES[1], -- 1716
					cardX, -- 1716
					cardY + 10 * s, -- 1716
					toColor(PALETTE.xuanInk), -- 1716
					0.5, -- 1716
					0.5, -- 1716
					"Center", -- 1716
					0.6, -- 1716
					0.94 * noteReadA, -- 1716
					0 -- 1716
				) -- 1716
				ctx.texts:put( -- 1717
					"xs", -- 1717
					"—— " .. NEEDLE_NOTE_LINES[2], -- 1717
					cardX + 74 * s, -- 1717
					cardY - 12 * s, -- 1717
					toColor(PALETTE.xuanInkSub), -- 1717
					1, -- 1717
					0.5, -- 1717
					"Right", -- 1717
					0.8, -- 1717
					0.88 * noteReadA, -- 1717
					0 -- 1717
				) -- 1717
			end -- 1717
		end -- 1717
		local steamStart = route == "child" and 6.2 or 6.08 -- 1720
		local steamOp = smoothstep(steamStart, steamStart + 0.45, t) -- 1721
		if steamOp > 0.02 then -- 1721
			local steamCx = route == "child" and ox + 1110 * s or ox + 1050 * s -- 1723
			local steamCy = oy + 196 * s -- 1724
			local wi = 0 -- 1725
			do -- 1725
				wi = 0 -- 1726
				while wi < 4 do -- 1726
					local cyc = (self.animTime * 0.34 + wi * 0.25) % 1 -- 1727
					local sx = steamCx + (wi - 1.5) * 16 * s + math.sin(self.animTime * 1.4 + wi * 2.1) * (6 + cyc * 8) * s -- 1728
					local sy = steamCy + (18 + cyc * 54) * s -- 1729
					local sr = (15 + cyc * 20) * s -- 1730
					local wa = math.floor(math.sin(cyc * math.pi) * 28 * steamOp + 0.5) -- 1731
					if wa > 2 then -- 1731
						fillRadialGlow( -- 1733
							uiGlow, -- 1733
							sx, -- 1733
							sy, -- 1733
							sr, -- 1733
							sr * 1.35, -- 1733
							Color(246, 238, 224, wa), -- 1733
							Color(246, 238, 224, 0), -- 1733
							12 -- 1733
						) -- 1733
					end -- 1733
					wi = wi + 1 -- 1726
				end -- 1726
			end -- 1726
		end -- 1726
		return -- 1737
	end -- 1737
	if route == "child" then -- 1737
		local propA = smoothstep(1.55, 2.05, t) -- 1741
		if propA > 0.02 then -- 1741
			self:drawNeedleCaseOnDesk( -- 1743
				uiDraw, -- 1743
				uiInkDraw, -- 1743
				uiArt, -- 1743
				ncX + 42 * s, -- 1743
				ncY - 22 * s, -- 1743
				s, -- 1743
				propA, -- 1743
				true -- 1743
			) -- 1743
		end -- 1743
		local noteReadA = smoothstep(1.65, 2.1, t) * (1 - smoothstep(3.65, 4.15, t)) -- 1745
		if noteReadA > 0.02 then -- 1745
			local cardX = ncX + 52 * s -- 1747
			local cardY = ncY + 72 * s -- 1748
			uiInkDraw:drawRect( -- 1749
				Rect(cardX - 118 * s, cardY - 30 * s, 236 * s, 60 * s), -- 1750
				toColor( -- 1751
					PALETTE.xuanPaper, -- 1751
					math.floor(238 * noteReadA + 0.5) -- 1751
				), -- 1751
				1, -- 1752
				toColor( -- 1753
					PALETTE.rouge, -- 1753
					math.floor(110 * noteReadA + 0.5) -- 1753
				) -- 1753
			) -- 1753
			ctx.texts:put( -- 1755
				"xs", -- 1755
				NEEDLE_NOTE_LINES[1], -- 1755
				cardX, -- 1755
				cardY + 10 * s, -- 1755
				toColor(PALETTE.xuanInk), -- 1755
				0.5, -- 1755
				0.5, -- 1755
				"Center", -- 1755
				0.6, -- 1755
				0.94 * noteReadA, -- 1755
				0 -- 1755
			) -- 1755
			ctx.texts:put( -- 1756
				"xs", -- 1756
				"—— " .. NEEDLE_NOTE_LINES[2], -- 1756
				cardX + 74 * s, -- 1756
				cardY - 12 * s, -- 1756
				toColor(PALETTE.xuanInkSub), -- 1756
				1, -- 1756
				0.5, -- 1756
				"Right", -- 1756
				0.8, -- 1756
				0.88 * noteReadA, -- 1756
				0 -- 1756
			) -- 1756
		end -- 1756
		local bowlK = smoothstep(4.35, 5.15, t) -- 1758
		if bowlK > 0.02 then -- 1758
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1760
			self:drawWarmPorcelainBowl( -- 1761
				uiDraw, -- 1761
				uiInkDraw, -- 1761
				uiArt, -- 1761
				uiGlow, -- 1761
				bx, -- 1761
				bowlY, -- 1761
				s, -- 1761
				bowlK, -- 1761
				false, -- 1761
				0 -- 1761
			) -- 1761
		end -- 1761
	else -- 1761
		local needleK = smoothstep(5.45, 6.15, t) -- 1764
		if needleK > 0.02 then -- 1764
			local ny = lerp(ncY + 26 * s, ncY - 22 * s, needleK) -- 1766
			self:drawNeedleCaseOnDesk( -- 1767
				uiDraw, -- 1767
				uiInkDraw, -- 1767
				uiArt, -- 1767
				ncX + 64 * s, -- 1767
				ny, -- 1767
				s, -- 1767
				needleK, -- 1767
				false -- 1767
			) -- 1767
		end -- 1767
		local bowlK = smoothstep(5.8, 6.65, t) -- 1769
		if bowlK > 0.02 then -- 1769
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1771
			local handsK = smoothstep(5.95, 6.75, t) -- 1772
			self:drawWarmPorcelainBowl( -- 1773
				uiDraw, -- 1773
				uiInkDraw, -- 1773
				uiArt, -- 1773
				uiGlow, -- 1773
				bowlX, -- 1773
				by, -- 1773
				s, -- 1773
				bowlK, -- 1773
				true, -- 1773
				handsK -- 1773
			) -- 1773
		end -- 1773
		local cuffK = smoothstep(4.25, 4.85, t) -- 1776
		if cuffK > 0.02 then -- 1776
			drawPatchedCuff(uiInkDraw, uiGlow, { -- 1778
				wristX = ox + 116 * s, -- 1779
				wristY = oy + 168 * s, -- 1780
				angleRad = 0.06, -- 1781
				scale = 0.74 * s, -- 1782
				pose = "open", -- 1783
				opacity = 0.94 * cuffK, -- 1784
				stitchHighlight = 0.34, -- 1785
				warmth = 0.72, -- 1786
				uiArt = uiArt, -- 1787
				instanceKey = "fe05_m03_desk_cuff", -- 1788
				layer = 5 -- 1789
			}) -- 1789
		end -- 1789
	end -- 1789
end -- 1685
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, bgDraw, inkDraw, uiArt, cx, cy, s, alpha, withNote) -- 1796
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1806
	bgDraw:drawEllipse( -- 1807
		Vec2(cx + 4 * s, cy - 32 * s), -- 1807
		44 * s, -- 1807
		12 * s, -- 1807
		Color( -- 1807
			10, -- 1807
			10, -- 1807
			14, -- 1807
			math.floor(130 * alpha + 0.5) -- 1807
		) -- 1807
	) -- 1807
	if not uiArt:tryPlacePath( -- 1807
		"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 1809
		"fe05_desk_needle_pouch", -- 1810
		cx, -- 1811
		cy + 4 * s, -- 1812
		100 * s, -- 1813
		102 * s, -- 1814
		{ -- 1815
			anchorX = 0.5, -- 1816
			anchorY = 0.5, -- 1817
			angle = -10, -- 1818
			opacity = clamp01(alpha), -- 1819
			smooth = true, -- 1820
			layer = 5 -- 1821
		} -- 1821
	) then -- 1821
		inkDraw:drawPolygon( -- 1824
			{ -- 1824
				Vec2(cx - 32 * s, cy - 12 * s), -- 1825
				Vec2(cx + 26 * s, cy - 15 * s), -- 1826
				Vec2(cx + 30 * s, cy + 16 * s), -- 1827
				Vec2(cx - 28 * s, cy + 18 * s) -- 1828
			}, -- 1828
			Color(148, 124, 92, a), -- 1829
			1.3, -- 1829
			Color(88, 70, 50, a) -- 1829
		) -- 1829
	end -- 1829
	if withNote then -- 1829
		inkDraw:drawPolygon( -- 1833
			{ -- 1833
				Vec2(cx + 42 * s, cy - 18 * s), -- 1834
				Vec2(cx + 100 * s, cy - 12 * s), -- 1835
				Vec2(cx + 94 * s, cy + 24 * s), -- 1836
				Vec2(cx + 38 * s, cy + 18 * s) -- 1837
			}, -- 1837
			toColor(PALETTE.xuanPaper, a), -- 1838
			1, -- 1838
			toColor( -- 1838
				PALETTE.xuanInkSub, -- 1838
				math.floor(160 * alpha + 0.5) -- 1838
			) -- 1838
		) -- 1838
		inkDraw:drawSegment( -- 1839
			Vec2(cx + 50 * s, cy + 8 * s), -- 1839
			Vec2(cx + 84 * s, cy + 11 * s), -- 1839
			1.2 * s, -- 1839
			toColor( -- 1839
				PALETTE.xuanInk, -- 1839
				math.floor(170 * alpha + 0.5) -- 1839
			) -- 1839
		) -- 1839
		inkDraw:drawSegment( -- 1840
			Vec2(cx + 50 * s, cy - 2 * s), -- 1840
			Vec2(cx + 80 * s, cy + 1 * s), -- 1840
			1.2 * s, -- 1840
			toColor( -- 1840
				PALETTE.xuanInk, -- 1840
				math.floor(160 * alpha + 0.5) -- 1840
			) -- 1840
		) -- 1840
	end -- 1840
end -- 1796
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, bgDraw, inkDraw, uiArt, glow, cx, cy, s, alpha, heldByTwoHands, handsK) -- 1845
	local op = clamp01(alpha) -- 1857
	bgDraw:drawEllipse( -- 1858
		Vec2(cx, cy - 46 * s), -- 1858
		64 * s, -- 1858
		14 * s, -- 1858
		Color( -- 1858
			8, -- 1858
			9, -- 1858
			14, -- 1858
			math.floor(138 * op + 0.5) -- 1858
		) -- 1858
	) -- 1858
	if not uiArt:tryPlacePath( -- 1858
		"assets/art/cutscene_story_parts.clip|porridge_bowl", -- 1860
		"fe05_desk_porridge_bowl", -- 1861
		cx, -- 1862
		cy - 4 * s, -- 1863
		162 * s, -- 1864
		124 * s, -- 1865
		{ -- 1866
			anchorX = 0.5, -- 1867
			anchorY = 0.5, -- 1868
			opacity = op, -- 1869
			smooth = true, -- 1870
			layer = 5 -- 1871
		} -- 1871
	) then -- 1871
		local a = math.floor(255 * op + 0.5) -- 1874
		inkDraw:drawEllipse( -- 1875
			Vec2(cx, cy + 8 * s), -- 1875
			64 * s, -- 1875
			21 * s, -- 1875
			Color(224, 218, 206, a) -- 1875
		) -- 1875
	end -- 1875
	local wi = 0 -- 1879
	do -- 1879
		wi = 0 -- 1880
		while wi < 4 do -- 1880
			local cyc = (self.animTime * 0.36 + wi * 0.25) % 1 -- 1881
			local sx = cx + (wi - 1.5) * 20 * s + math.sin(self.animTime * 1.4 + wi * 2.1) * (8 + cyc * 10) * s -- 1882
			local sy = cy + (24 + cyc * 58) * s -- 1883
			local sr = (18 + cyc * 24) * s -- 1884
			local wa = math.floor(math.sin(cyc * math.pi) * 34 * op + 0.5) -- 1885
			if wa > 2 then -- 1885
				fillRadialGlow( -- 1887
					glow, -- 1887
					sx, -- 1887
					sy, -- 1887
					sr, -- 1887
					sr * 1.35, -- 1887
					Color(246, 238, 224, wa), -- 1887
					Color(246, 238, 224, 0), -- 1887
					12 -- 1887
				) -- 1887
			end -- 1887
			wi = wi + 1 -- 1880
		end -- 1880
	end -- 1880
	if heldByTwoHands and handsK > 0.02 then -- 1880
		local liftY = (1 - handsK) * 36 * s -- 1893
		local handOp = clamp01(handsK * op) -- 1894
		uiArt:tryPlacePath( -- 1895
			"assets/art/cutscene_story_parts.clip|xiaoman_cup_hands", -- 1896
			"fe05_m03_xiaoman_cup_hands", -- 1897
			cx, -- 1898
			cy - 34 * s - liftY, -- 1899
			258 * s, -- 1900
			186 * s, -- 1901
			{ -- 1902
				anchorX = 0.5, -- 1903
				anchorY = 0.5, -- 1904
				opacity = handOp, -- 1905
				smooth = true, -- 1906
				layer = 6 -- 1907
			} -- 1907
		) -- 1907
	end -- 1907
end -- 1845
function TowerEndingsPlugin.prototype.drawMingLantern(self, draw, glow, cx, cy, scale, alpha, warmth) -- 1914
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1923
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 1924
	draw:drawSegment( -- 1926
		Vec2(cx - 10 * scale, cy + 28 * scale), -- 1926
		Vec2(cx, cy + 40 * scale), -- 1926
		1.8 * scale, -- 1926
		Color(88, 86, 82, a) -- 1926
	) -- 1926
	draw:drawSegment( -- 1927
		Vec2(cx + 10 * scale, cy + 28 * scale), -- 1927
		Vec2(cx, cy + 40 * scale), -- 1927
		1.8 * scale, -- 1927
		Color(88, 86, 82, a) -- 1927
	) -- 1927
	draw:drawRect( -- 1929
		Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), -- 1929
		Color(62, 46, 34, a), -- 1929
		1, -- 1929
		Color(118, 92, 66, a) -- 1929
	) -- 1929
	draw:drawRect( -- 1930
		Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), -- 1930
		Color(62, 46, 34, a), -- 1930
		1, -- 1930
		Color(118, 92, 66, a) -- 1930
	) -- 1930
	draw:drawRect( -- 1932
		Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale), -- 1933
		Color( -- 1934
			238, -- 1934
			198, -- 1934
			132, -- 1934
			math.floor(230 * alpha * (0.75 + 0.25 * warmth) + 0.5) -- 1934
		), -- 1934
		1.4 * scale, -- 1935
		Color(94, 70, 48, a) -- 1936
	) -- 1936
	draw:drawSegment( -- 1938
		Vec2(cx, cy - 18 * scale), -- 1938
		Vec2(cx, cy + 22 * scale), -- 1938
		1.1 * scale, -- 1938
		Color( -- 1938
			94, -- 1938
			70, -- 1938
			48, -- 1938
			math.floor(150 * alpha + 0.5) -- 1938
		) -- 1938
	) -- 1938
	draw:drawEllipse( -- 1939
		Vec2(cx, cy + 2 * scale), -- 1939
		4.6 * scale * flicker, -- 1939
		8.5 * scale * flicker, -- 1939
		Color(255, 244, 212, a) -- 1939
	) -- 1939
	fillRadialGlow( -- 1941
		glow, -- 1942
		cx, -- 1942
		cy + 2 * scale, -- 1942
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 1943
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 1944
		Color( -- 1945
			250, -- 1945
			208, -- 1945
			132, -- 1945
			math.floor(128 * alpha * warmth + 0.5) -- 1945
		), -- 1945
		Color(228, 162, 74, 0), -- 1946
		16 -- 1947
	) -- 1947
end -- 1914
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 1951
	local line = self.lastSubtitle -- 1960
	if line ~= "" then -- 1960
		local cy = barH + 34 * s -- 1962
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 1963
		drawSilkVeil( -- 1964
			uiDraw, -- 1964
			uiArt, -- 1964
			"fe05_sub_veil", -- 1964
			ctx.uiW * 0.5, -- 1964
			cy, -- 1964
			stripW, -- 1964
			48 * s, -- 1964
			PALETTE.inkWash, -- 1964
			0.82, -- 1964
			3 -- 1964
		) -- 1964
		drawHairline( -- 1965
			uiInkDraw, -- 1965
			uiArt, -- 1965
			"fe05_sub_hair", -- 1965
			ctx.uiW * 0.5, -- 1965
			cy + 21 * s, -- 1965
			stripW * 0.68, -- 1965
			PALETTE.silkDim, -- 1965
			0.54, -- 1965
			true, -- 1965
			4 -- 1965
		) -- 1965
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 1966
		ctx.texts:put( -- 1967
			isSpoken and "md" or "sm", -- 1968
			line, -- 1969
			ctx.uiW * 0.5, -- 1970
			cy - 1 * s, -- 1971
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 1972
			0.5, -- 1973
			0.5, -- 1974
			"Center", -- 1975
			isSpoken and 1.8 or 1, -- 1976
			0.98, -- 1977
			0.08 -- 1978
		) -- 1978
	end -- 1978
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 1978
		local rawHint = route == "child" and "按 E 收页 · 尾声与史话   ·   Esc 暂歇" or "团圆尾声   ·   按 E 收页与史话   ·   Esc 暂歇" -- 1984
		local hint = getActiveTarget():adaptHintSentence(rawHint, ctx.input.inputMode, ctx.input.gamepadLayout) -- 1987
		ctx.texts:put( -- 1988
			"xs", -- 1988
			hint, -- 1988
			ctx.uiW * 0.5, -- 1988
			barH * 0.5, -- 1988
			toColor(PALETTE.textMid), -- 1988
			0.5, -- 1988
			0.5, -- 1988
			"Center", -- 1988
			1.4, -- 1988
			0.88, -- 1988
			0.08 -- 1988
		) -- 1988
	end -- 1988
end -- 1951
function ____exports.createTowerEndingsPlugin() -- 1993
	return __TS__New(____exports.TowerEndingsPlugin) -- 1994
end -- 1993
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 1998
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 1999
	fe:registerPlugin(plugin) -- 2000
	return plugin -- 2001
end -- 1998
return ____exports -- 1998