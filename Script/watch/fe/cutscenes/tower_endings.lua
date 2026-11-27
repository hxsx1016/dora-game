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
local ____dialogues = require("Script.watch.dialogues") -- 36
local NEEDLE_NOTE_LINES = ____dialogues.NEEDLE_NOTE_LINES -- 36
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 37
local adaptHintSentence = ____control_prompts.adaptHintSentence -- 37
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 39
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 41
local TOWER_WEST_LAMP_LIGHT = ____lowpoly.TOWER_WEST_LAMP_LIGHT -- 42
local clamp01 = ____lowpoly.clamp01 -- 43
local normalize3 = ____lowpoly.normalize3 -- 44
local shadeSurface = ____lowpoly.shadeSurface -- 45
local smoothstep = ____lowpoly.smoothstep -- 46
local vec3 = ____lowpoly.vec3 -- 47
local ____theme = require("Script.watch.fe.theme") -- 49
local PALETTE = ____theme.PALETTE -- 50
local drawHairline = ____theme.drawHairline -- 52
local drawSilkVeil = ____theme.drawSilkVeil -- 53
local fillGradQuad = ____theme.fillGradQuad -- 54
local fillRadialGlow = ____theme.fillRadialGlow -- 55
local fillVGradRect = ____theme.fillVGradRect -- 56
local lerpRGBA = ____theme.lerpRGBA -- 57
local rgba = ____theme.rgba -- 58
local toColor = ____theme.toColor -- 59
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 61
local computeFullscreenSlideRect = ____slideshow.computeFullscreenSlideRect -- 62
local drawPixelSlidePlate = ____slideshow.drawPixelSlidePlate -- 63
--- 精确对齐后端 tower-knock(36 拍 = 0.6s, 第 0 / 12 拍敲门) 与 8.0 秒配对演出节拍
____exports.TOWER_ENDING_TIMINGS = { -- 93
	knock1Sec = 0, -- 94
	knock2Sec = 0.2, -- 95
	reply1Sec = 0.42, -- 96
	reply2Sec = 0.54, -- 97
	doorOpenSec = 0.6, -- 98
	indoorCutSec = 1.4, -- 99
	row1StartSec = 2.2, -- 100
	row1EndSec = 3.4, -- 101
	pivotStartSec = 3.4, -- 102
	pivotEndSec = 4.2, -- 103
	divergeEndSec = 6.8, -- 104
	holdReadySec = TOWER_CONFIRM_TICKS / 60 -- 105
} -- 105
local TOWER_AUDIO_ROOT = "assets/audio/tower/" -- 108
____exports.TOWER_AUDIO_FILES = { -- 110
	knock1 = TOWER_AUDIO_ROOT .. "door_knock_1.wav", -- 111
	knock2 = TOWER_AUDIO_ROOT .. "door_knock_2.wav", -- 112
	reply1 = TOWER_AUDIO_ROOT .. "door_reply_1.wav", -- 113
	reply2 = TOWER_AUDIO_ROOT .. "door_reply_2.wav", -- 114
	doorOpen = TOWER_AUDIO_ROOT .. "door_open.wav", -- 115
	bookOpen = TOWER_AUDIO_ROOT .. "book_open.wav", -- 116
	brush1 = TOWER_AUDIO_ROOT .. "brush_write_1.wav", -- 117
	brush2 = TOWER_AUDIO_ROOT .. "brush_write_2.wav", -- 118
	lampMove = TOWER_AUDIO_ROOT .. "lamp_move.wav", -- 119
	needlePlace = TOWER_AUDIO_ROOT .. "needle_case_place.wav", -- 120
	bowlSet = TOWER_AUDIO_ROOT .. "bowl_set.wav", -- 121
	windCold = TOWER_AUDIO_ROOT .. "tower_wind_cold.wav", -- 122
	roomWarm = TOWER_AUDIO_ROOT .. "tower_room_warm.wav", -- 123
	lineXiaomanLamp = TOWER_AUDIO_ROOT .. "line_xiaoman_lamp.wav", -- 124
	lineZhoushuName = TOWER_AUDIO_ROOT .. "line_zhoushu_name.wav" -- 125
} -- 125
--- 同机位配对布局真源（基准 1280×720 逻辑坐标系，F03 与 M03 100% 共享）：
-- 保证两版并排对照时门扇、门槛、提灯、西窗、簿页、一/二行基线、悬停笔尖、案沿热碗 0.00 px 偏差。
____exports.TOWER_SHOT_LAYOUT = { -- 132
	refW = 1280, -- 133
	refH = 720, -- 134
	letterboxH = 60, -- 135
	doorCenterX = 640, -- 137
	thresholdY = 168, -- 138
	doorW = 248, -- 139
	doorH = 374, -- 140
	knockHandX = 574, -- 141
	knockHandY = 312, -- 142
	doorLanternX = 710, -- 143
	doorLanternY = 344, -- 144
	westWindowX = 88, -- 146
	westWindowY = 382, -- 147
	westWindowW = 236, -- 148
	westWindowH = 224, -- 149
	deskTopY = 260, -- 150
	lampDeskX = 356, -- 151
	lampDeskY = 332, -- 152
	lampWindowX = 206, -- 153
	lampWindowY = 422, -- 154
	bookX = 416, -- 155
	bookY = 196, -- 156
	bookW = 588, -- 157
	bookH = 386, -- 158
	row1Y = 454, -- 159
	row1SubY = 424, -- 160
	row2Y = 354, -- 161
	row2SubY = 324, -- 162
	brushHoverTipX = 556, -- 163
	brushHoverTipY = 358, -- 164
	needleCaseDeskX = 294, -- 165
	needleCaseDeskY = 204, -- 166
	bowlRimX = 954, -- 167
	bowlRimY = 184, -- 168
	inkstoneX = 1112, -- 169
	inkstoneY = 256 -- 170
} -- 170
local F03_DIALOGUE = "「朝西那盏灯，能留着吗？」" -- 232
local M03_DIALOGUE = "「周戍。」" -- 233
--- F03 拂晓冷室灯光预设（挪灯前），向 TOWER_WEST_LAMP_LIGHT（西窗暖灯）平滑插值
local TOWER_COLD_DAWN_LIGHT = { -- 236
	keyDir = normalize3(vec3(-0.34, 0.72, -0.6)), -- 237
	keyColor = rgba(146, 174, 206, 255), -- 238
	keyStrength = 0.74, -- 239
	rimDir = normalize3(vec3(0.68, 0.44, -0.58)), -- 240
	rimColor = rgba(182, 166, 140, 255), -- 241
	rimStrength = 0.24, -- 242
	ambientColor = rgba(18, 24, 38, 255), -- 243
	fogColor = rgba(16, 22, 34, 255), -- 244
	fogStartZ = 50, -- 245
	fogEndZ = 460, -- 246
	fogMaxAlpha = 0.78, -- 247
	shadowContrast = 0.78 -- 248
} -- 248
local function lerp(a, b, t) -- 251
	return a + (b - a) * t -- 252
end -- 251
local function lerpLightRig(a, b, t) -- 255
	local k = clamp01(t) -- 256
	return { -- 257
		keyDir = normalize3(vec3( -- 258
			lerp(a.keyDir.x, b.keyDir.x, k), -- 259
			lerp(a.keyDir.y, b.keyDir.y, k), -- 260
			lerp(a.keyDir.z, b.keyDir.z, k) -- 261
		)), -- 261
		keyColor = lerpRGBA(a.keyColor, b.keyColor, k), -- 263
		keyStrength = lerp(a.keyStrength, b.keyStrength, k), -- 264
		rimDir = normalize3(vec3( -- 265
			lerp(a.rimDir.x, b.rimDir.x, k), -- 266
			lerp(a.rimDir.y, b.rimDir.y, k), -- 267
			lerp(a.rimDir.z, b.rimDir.z, k) -- 268
		)), -- 268
		rimColor = lerpRGBA(a.rimColor, b.rimColor, k), -- 270
		rimStrength = lerp(a.rimStrength, b.rimStrength, k), -- 271
		ambientColor = lerpRGBA(a.ambientColor, b.ambientColor, k), -- 272
		fogColor = lerpRGBA(a.fogColor, b.fogColor, k), -- 273
		fogStartZ = lerp(a.fogStartZ, b.fogStartZ, k), -- 274
		fogEndZ = lerp(a.fogEndZ, b.fogEndZ, k), -- 275
		fogMaxAlpha = lerp(a.fogMaxAlpha, b.fogMaxAlpha, k), -- 276
		shadowContrast = lerp(a.shadowContrast, b.shadowContrast, k) -- 277
	} -- 277
end -- 255
local function computeScaledAnchors(uiW, uiH, lampProg) -- 281
	local s = math.min(uiW / ____exports.TOWER_SHOT_LAYOUT.refW, uiH / ____exports.TOWER_SHOT_LAYOUT.refH) -- 287
	local ox = (uiW - ____exports.TOWER_SHOT_LAYOUT.refW * s) * 0.5 -- 288
	local oy = (uiH - ____exports.TOWER_SHOT_LAYOUT.refH * s) * 0.5 -- 289
	local lx = lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) -- 290
	local ly = lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34 -- 291
	return {s = s, ox = ox, oy = oy, anchors = { -- 293
		doorCenterX = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s, -- 298
		thresholdY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s, -- 299
		knockHandX = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s, -- 300
		knockHandY = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s, -- 301
		bookX = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s, -- 302
		bookY = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s, -- 303
		bookW = ____exports.TOWER_SHOT_LAYOUT.bookW * s, -- 304
		bookH = ____exports.TOWER_SHOT_LAYOUT.bookH * s, -- 305
		row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s, -- 306
		row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s, -- 307
		brushHoverTipX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s, -- 308
		brushHoverTipY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s, -- 309
		bowlRimX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s, -- 310
		bowlRimY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s, -- 311
		lampCurX = ox + lx * s, -- 312
		lampCurY = oy + ly * s -- 313
	}} -- 313
end -- 281
local function deriveStage(seqElapsed, active) -- 318
	if not active then -- 318
		return "idle" -- 320
	end -- 320
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 320
		return "porch_knock" -- 323
	end -- 323
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 323
		return "door_open" -- 326
	end -- 326
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 326
		return "book_row1" -- 329
	end -- 329
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 329
		return "pivot_hover" -- 332
	end -- 332
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 332
		return "diverge_action" -- 335
	end -- 335
	return "ending_hold" -- 337
end -- 318
--- 将字符切片数组按进度拼接为前 n 段（避免 Lua 字节切片截断 UTF-8 汉字）
local function joinPrefixTokens(tokens, progress) -- 341
	if progress <= 0 or #tokens == 0 then -- 341
		return "" -- 343
	end -- 343
	local count = math.max( -- 345
		1, -- 345
		math.min( -- 345
			#tokens, -- 345
			math.ceil(progress * #tokens) -- 345
		) -- 345
	) -- 345
	local out = "" -- 346
	local i = 0 -- 347
	do -- 347
		i = 0 -- 348
		while i < count do -- 348
			out = out .. tokens[i + 1] -- 349
			i = i + 1 -- 348
		end -- 348
	end -- 348
	return out -- 351
end -- 341
local ROW1_TOKENS = { -- 354
	"小", -- 354
	"满", -- 354
	"  ", -- 354
	"·", -- 354
	"  ", -- 354
	"已", -- 354
	"收" -- 354
} -- 354
local ROW2_SOLDIER_TOKENS = { -- 355
	"周", -- 355
	"戍", -- 355
	"  ", -- 355
	"·", -- 355
	"  ", -- 355
	"兄", -- 355
	"妹", -- 355
	"同", -- 355
	"行", -- 355
	"  ", -- 355
	"·", -- 355
	"  ", -- 355
	"已", -- 355
	"收" -- 355
} -- 355
local function asRecord(v) -- 357
	if v ~= nil and type(v) == "table" then -- 357
		return v -- 359
	end -- 359
	return nil -- 361
end -- 357
--- 描边椭圆（Dora DrawNode.drawEllipse 仅支持填充，描边用等分折线保证锐利清晰）
local function strokeEllipse(draw, cx, cy, rx, ry, width, color, segments) -- 365
	if segments == nil then -- 365
		segments = 24 -- 373
	end -- 373
	if rx <= 0.5 or ry <= 0.5 or width <= 0.05 then -- 373
		return -- 376
	end -- 376
	local step = math.pi * 2 / segments -- 378
	local prevX = cx + rx -- 379
	local prevY = cy -- 380
	local i = 1 -- 381
	do -- 381
		i = 1 -- 382
		while i <= segments do -- 382
			local ang = i * step -- 383
			local nx = cx + math.cos(ang) * rx -- 384
			local ny = cy + math.sin(ang) * ry -- 385
			draw:drawSegment( -- 386
				Vec2(prevX, prevY), -- 386
				Vec2(nx, ny), -- 386
				width, -- 386
				color -- 386
			) -- 386
			prevX = nx -- 387
			prevY = ny -- 388
			i = i + 1 -- 382
		end -- 382
	end -- 382
end -- 365
local STONE_EDGE_FALLBACK = MING_MATERIALS.mingStoneStep.edge or PALETTE.silkDim -- 392
____exports.TowerEndingsPlugin = __TS__Class() -- 394
local TowerEndingsPlugin = ____exports.TowerEndingsPlugin -- 394
TowerEndingsPlugin.name = "TowerEndingsPlugin" -- 394
function TowerEndingsPlugin.prototype.____constructor(self) -- 394
	self.id = "fe-05-tower-endings" -- 395
	self.active = false -- 397
	self.rehearsalActive = false -- 398
	self.rehearsalRoute = "child" -- 399
	self.activeRoute = "child" -- 400
	self.seqElapsed = 0 -- 402
	self.holdElapsed = 0 -- 403
	self.animTime = 0 -- 404
	self.doorOpened = false -- 407
	self.knockCount = 0 -- 408
	self.replyKnockCount = 0 -- 409
	self.row1Written = false -- 410
	self.row2Written = false -- 411
	self.registryAppendCount = 0 -- 412
	self.staleInputMustRelease = false -- 415
	self.confirmReady = false -- 416
	self.earlyInputBlockedCount = 0 -- 417
	self.rehearsalAcknowledged = false -- 418
	self.lastRoomKey = "" -- 421
	self.indoorRetryCount = 0 -- 423
	self.doorClosedAfterRetry = false -- 424
	self.sessionId = 0 -- 425
	self.lastUiW = 1280 -- 428
	self.lastUiH = 720 -- 429
	self.lastSubtitle = "" -- 430
	self.prevPhase = "" -- 431
	self.loopsActive = false -- 432
end -- 394
function TowerEndingsPlugin.prototype.resolveRoute(self, p, view) -- 435
	if self.rehearsalActive then -- 435
		return self.rehearsalRoute -- 437
	end -- 437
	if view.storyRoute == "soldier" then -- 437
		return "soldier" -- 440
	end -- 440
	if view.storyRoute == "child" then -- 440
		return "child" -- 443
	end -- 443
	local runRec = asRecord(p.run) -- 446
	local ____asRecord_1 = asRecord -- 447
	local ____temp_0 -- 447
	if runRec ~= nil then -- 447
		____temp_0 = runRec.story -- 447
	else -- 447
		____temp_0 = nil -- 447
	end -- 447
	local storyRec = ____asRecord_1(____temp_0) -- 447
	if storyRec ~= nil and storyRec.ending == "reunion" then -- 447
		return "soldier" -- 449
	end -- 449
	return p.childMode and "child" or "soldier" -- 452
end -- 435
function TowerEndingsPlugin.prototype.clearSequenceState(self, keepIndoorDoorOpen) -- 455
	self.active = keepIndoorDoorOpen -- 456
	self.seqElapsed = keepIndoorDoorOpen and ____exports.TOWER_ENDING_TIMINGS.indoorCutSec or 0 -- 457
	self.holdElapsed = 0 -- 458
	self.doorOpened = keepIndoorDoorOpen -- 459
	self.knockCount = keepIndoorDoorOpen and 2 or 0 -- 460
	self.replyKnockCount = keepIndoorDoorOpen and 2 or 0 -- 461
	if not keepIndoorDoorOpen then -- 461
		self.row1Written = false -- 463
		self.row2Written = false -- 464
		self.registryAppendCount = 0 -- 465
	end -- 465
	self.staleInputMustRelease = true -- 467
	self.confirmReady = false -- 468
	self.earlyInputBlockedCount = 0 -- 469
	self.rehearsalAcknowledged = false -- 470
	self.lastSubtitle = "" -- 471
end -- 455
function TowerEndingsPlugin.prototype.startRehearsal(self, route, contract, opts) -- 477
	self.rehearsalActive = true -- 482
	self.rehearsalRoute = route -- 483
	self.activeRoute = route -- 484
	local tag = opts and opts.tag or (route == "child" and "fe05-F03" or "fe05-M03") -- 485
	if contract ~= nil then -- 485
		contract:enterRehearsal(tag) -- 487
		contract:setMockRoute(route) -- 488
	end -- 488
	local isIndoor = (opts and opts.indoorRetry) == true -- 490
	self.sessionId = self.sessionId + 1 -- 491
	self:clearSequenceState(isIndoor) -- 492
	self.active = true -- 493
	self.doorClosedAfterRetry = false -- 494
	if isIndoor then -- 494
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 496
	end -- 496
	if (opts and opts.seekTime) ~= nil then -- 496
		self:seekRehearsal(opts.seekTime) -- 499
	end -- 499
end -- 477
function TowerEndingsPlugin.prototype.seekRehearsal(self, seconds) -- 504
	if not self.rehearsalActive then -- 504
		return -- 506
	end -- 506
	local t = math.max(0, seconds) -- 508
	self.seqElapsed = t -- 509
	self.holdElapsed = math.max(0, t - ____exports.TOWER_ENDING_TIMINGS.divergeEndSec) -- 510
	self.active = true -- 511
	self:syncDerivedMilestones(t, self.activeRoute) -- 512
	self.confirmReady = not self.staleInputMustRelease and t >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 513
end -- 504
function TowerEndingsPlugin.prototype.triggerIndoorRetry(self) -- 517
	if not self.doorOpened and self.seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 517
		self.doorOpened = true -- 519
	end -- 519
	self.indoorRetryCount = self.indoorRetryCount + 1 -- 521
	self.doorClosedAfterRetry = false -- 522
	self.doorOpened = true -- 523
	self.active = true -- 524
	self.seqElapsed = math.max( -- 525
		____exports.TOWER_ENDING_TIMINGS.indoorCutSec, -- 525
		math.min(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.row1StartSec) -- 525
	) -- 525
	self.holdElapsed = 0 -- 526
	self.knockCount = math.max(2, self.knockCount) -- 527
	self.replyKnockCount = math.max(2, self.replyKnockCount) -- 528
	self.staleInputMustRelease = true -- 530
	self.confirmReady = false -- 531
end -- 517
function TowerEndingsPlugin.prototype.stopRehearsal(self, contract) -- 535
	self.rehearsalActive = false -- 536
	self:clearSequenceState(false) -- 537
	self.indoorRetryCount = 0 -- 538
	self.doorClosedAfterRetry = false -- 539
	if contract ~= nil then -- 539
		contract:exitRehearsal() -- 541
	end -- 541
end -- 535
function TowerEndingsPlugin.prototype.getDebugState(self) -- 545
	local route = self.activeRoute -- 546
	local lampProg = route == "child" and smoothstep(5.2, 6.75, self.seqElapsed) or 0 -- 547
	local scaled = computeScaledAnchors(self.lastUiW, self.lastUiH, lampProg) -- 550
	local visualStyle = route == "child" and "lowpoly" or "pixel" -- 551
	local needleOnDesk = route == "soldier" and self.seqElapsed >= 5.55 -- 552
	local twoHandsBowl = route == "soldier" and self.seqElapsed >= 5.95 -- 553
	return { -- 555
		active = self.active, -- 556
		isRehearsal = self.rehearsalActive, -- 557
		route = route, -- 558
		visualStyle = visualStyle, -- 559
		stage = deriveStage(self.seqElapsed, self.active), -- 560
		seqElapsed = self.seqElapsed, -- 561
		holdElapsed = self.holdElapsed, -- 562
		doorOpened = self.doorOpened, -- 563
		knockCount = self.knockCount, -- 564
		replyKnockCount = self.replyKnockCount, -- 565
		row1Written = self.row1Written, -- 566
		row1Name = self.row1Written and "小满" or "", -- 567
		row2Written = self.row2Written, -- 568
		row2Name = self.row2Written and "周戍" or "", -- 569
		row2Blank = not self.row2Written, -- 570
		hasCompletionStamp = false, -- 571
		registryRowCapacity = 2, -- 572
		registryAppendCount = self.registryAppendCount, -- 573
		lampProgress = lampProg, -- 574
		lampAtWestWindow = route == "child" and lampProg >= 0.99, -- 575
		needleCaseOnDesk = needleOnDesk, -- 576
		twoHandsHoldingBowl = twoHandsBowl, -- 577
		staleInputMustRelease = self.staleInputMustRelease, -- 578
		confirmReady = self.confirmReady, -- 579
		earlyInputBlockedCount = self.earlyInputBlockedCount, -- 580
		rehearsalAcknowledged = self.rehearsalAcknowledged, -- 581
		indoorRetryCount = self.indoorRetryCount, -- 582
		doorClosedAfterRetry = self.doorClosedAfterRetry, -- 583
		subtitleText = self.lastSubtitle, -- 584
		anchors = scaled.anchors -- 585
	} -- 585
end -- 545
function TowerEndingsPlugin.prototype.syncRuntimeHook(self) -- 589
	local g = _G -- 590
	local ____temp_8 -- 591
	if g.package ~= nil then -- 591
		____temp_8 = g.package.loaded -- 591
	else -- 591
		____temp_8 = nil -- 591
	end -- 591
	local loaded = ____temp_8 -- 591
	if loaded == nil then -- 591
		return -- 593
	end -- 593
	local rawFe = loaded["watch.fe"] -- 595
	if rawFe ~= nil and type(rawFe) == "table" then -- 595
		local watchFe = rawFe -- 597
		if watchFe.towerEndings ~= self then -- 597
			watchFe.towerEndings = self -- 599
		end -- 599
	end -- 599
end -- 589
function TowerEndingsPlugin.prototype.onBindPlay(self, p, view) -- 606
	self:syncRuntimeHook() -- 607
	self.sessionId = self.sessionId + 1 -- 608
	self.loopsActive = false -- 609
	self.prevPhase = p.phase -- 610
	if self.rehearsalActive then -- 610
		return -- 613
	end -- 613
	local route = self:resolveRoute(p, view) -- 616
	local isTower = p.room.key == "tower" -- 617
	local alreadyCutscenePhase = isTower and (p.phase == "tower-given" or p.phase == "tower-end") -- 618
	local alreadyIndoorPhase = isTower and (p.phase == "tower-enter" or p.phase == "tower-desk" or alreadyCutscenePhase) -- 619
	local sameRunIndoorRetry = isTower and self.lastRoomKey == "tower" and self.doorOpened and p.run == self.lastRunRef and route == self.activeRoute and (p.checkpoint > 0 or alreadyIndoorPhase) -- 624
	self.activeRoute = route -- 631
	self.lastRoomKey = p.room.key -- 632
	self.lastRunRef = p.run -- 633
	if not isTower then -- 633
		self:clearSequenceState(false) -- 636
		self.indoorRetryCount = 0 -- 637
		self.doorClosedAfterRetry = false -- 638
		return -- 639
	end -- 639
	if sameRunIndoorRetry or alreadyCutscenePhase then -- 639
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 644
		self.doorClosedAfterRetry = false -- 645
		self:clearSequenceState(true) -- 646
		if p.phase == "tower-end" then -- 646
			self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.divergeEndSec -- 648
			self:syncDerivedMilestones(self.seqElapsed, route) -- 649
		end -- 649
		return -- 651
	end -- 651
	if p.phase == "tower-enter" or p.phase == "tower-desk" then -- 651
		self:clearSequenceState(false) -- 656
		self.doorOpened = true -- 657
		self.replyKnockCount = 2 -- 658
		self.active = false -- 659
		return -- 660
	end -- 660
	self:clearSequenceState(false) -- 664
	self.indoorRetryCount = 0 -- 665
	self.doorClosedAfterRetry = false -- 666
end -- 606
function TowerEndingsPlugin.prototype.update(self, ctx) -- 669
	self:syncRuntimeHook() -- 670
	self.lastUiW = ctx.uiW -- 671
	self.lastUiH = ctx.uiH -- 672
	local p = ctx.p -- 673
	if not self.rehearsalActive and p.room.key ~= "tower" then -- 673
		if self.loopsActive then -- 673
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 677
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 678
			self.loopsActive = false -- 679
		end -- 679
		self.active = false -- 681
		return -- 682
	end -- 682
	local route = self:resolveRoute(p, ctx.view) -- 685
	self.activeRoute = route -- 686
	if not self.rehearsalActive then -- 686
		self:stepLiveSync(ctx, route) -- 689
	else -- 689
		self:stepRehearsal(ctx, route) -- 691
	end -- 691
	if not self.active then -- 691
		local inInteractiveHall = not self.rehearsalActive and p.room.key == "tower" and (p.phase == "tower-enter" or p.phase == "tower-desk") -- 695
		if self.loopsActive and not inInteractiveHall then -- 695
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 698
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 699
			self.loopsActive = false -- 700
		end -- 700
		return -- 702
	end -- 702
	if not ctx.paused and ctx.worldDt > 0 then -- 702
		self.animTime = self.animTime + ctx.worldDt -- 707
		self:syncDerivedMilestones(self.seqElapsed, route) -- 708
		self:syncAudioCues(ctx.audio, ctx, route) -- 709
		self:stepInputGuard(ctx.input) -- 710
	elseif not ctx.paused then -- 710
		self:syncDerivedMilestones(self.seqElapsed, route) -- 713
		self:stepInputGuard(ctx.input) -- 714
	end -- 714
	self.lastSubtitle = self:composeSubtitle(route) -- 717
end -- 669
function TowerEndingsPlugin.prototype.stepLiveSync(self, ctx, route) -- 720
	local p = ctx.p -- 721
	local phase = p.phase -- 722
	local justEnteredKnock = self.prevPhase ~= "tower-knock" and phase == "tower-knock" -- 723
	local justEnteredEnter = self.prevPhase ~= "tower-enter" and phase == "tower-enter" -- 724
	local justEnteredGiven = self.prevPhase ~= "tower-given" and phase == "tower-given" -- 725
	local justEnteredEnd = self.prevPhase ~= "tower-end" and phase == "tower-end" -- 726
	self.prevPhase = phase -- 727
	if phase == "tower-wait" then -- 727
		self.active = false -- 731
		return -- 732
	end -- 732
	if phase == "tower-enter" or phase == "tower-desk" then -- 732
		self.doorOpened = true -- 737
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 738
		if justEnteredEnter and self.indoorRetryCount == 0 and not ctx.paused then -- 738
			local tick = p.ticks -- 740
			self:playTowerOnce( -- 741
				ctx.audio, -- 741
				"reply1", -- 741
				"sfx", -- 741
				____exports.TOWER_AUDIO_FILES.reply1, -- 741
				0.78, -- 741
				"tower:reply:1", -- 741
				tick -- 741
			) -- 741
			self:playTowerOnce( -- 742
				ctx.audio, -- 742
				"reply2", -- 742
				"sfx", -- 742
				____exports.TOWER_AUDIO_FILES.reply2, -- 742
				0.8, -- 742
				"tower:reply:2", -- 742
				tick -- 742
			) -- 742
			self:playTowerOnce( -- 743
				ctx.audio, -- 743
				"door_open", -- 743
				"sfx", -- 743
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 743
				0.84, -- 743
				"tower:door_open", -- 743
				tick -- 743
			) -- 743
		end -- 743
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.doorOpenSec) -- 745
		self.active = false -- 746
		self:syncDerivedMilestones(self.seqElapsed, route) -- 747
		return -- 748
	end -- 748
	if not self.active then -- 748
		self.active = true -- 752
		self.staleInputMustRelease = ctx.input.interact.held or ctx.input.retry.held or ctx.input.interact.pressed -- 753
		self.confirmReady = false -- 754
	end -- 754
	if justEnteredKnock then -- 754
		self.seqElapsed = p.phaseTick / 60 -- 758
		self.holdElapsed = 0 -- 759
		self.staleInputMustRelease = true -- 760
		self.confirmReady = false -- 761
	elseif justEnteredGiven then -- 761
		self.doorOpened = true -- 763
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 764
	elseif justEnteredEnd then -- 764
		self.doorOpened = true -- 766
		self.seqElapsed = math.max(self.seqElapsed, 3.6) -- 768
	end -- 768
	if not ctx.paused and #ctx.events.rawEvents > 0 then -- 768
		local i = 0 -- 773
		do -- 773
			i = 0 -- 774
			while i < #ctx.events.rawEvents do -- 774
				local ev = ctx.events.rawEvents[i + 1] -- 775
				if ev.name == "knock" then -- 775
					local cnt = type(ev.data.count) == "number" and ev.data.count or self.knockCount + 1 -- 777
					if cnt >= 1 and self.knockCount < 1 then -- 777
						self.knockCount = 1 -- 779
						self:playTowerOnce( -- 780
							ctx.audio, -- 780
							"knock1", -- 780
							"sfx", -- 780
							____exports.TOWER_AUDIO_FILES.knock1, -- 780
							0.88, -- 780
							"tower:knock:1", -- 780
							ev.tick, -- 780
							ev.seq -- 780
						) -- 780
					end -- 780
					if cnt >= 2 and self.knockCount < 2 then -- 780
						self.knockCount = 2 -- 783
						self:playTowerOnce( -- 784
							ctx.audio, -- 784
							"knock2", -- 784
							"sfx", -- 784
							____exports.TOWER_AUDIO_FILES.knock2, -- 784
							0.9, -- 784
							"tower:knock:2", -- 784
							ev.tick, -- 784
							ev.seq -- 784
						) -- 784
					end -- 784
				end -- 784
				i = i + 1 -- 774
			end -- 774
		end -- 774
	end -- 774
	if not ctx.paused and ctx.worldDt > 0 then -- 774
		if phase == "tower-knock" then -- 774
			local backendSec = math.min(____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60) -- 793
			self.seqElapsed = math.max(self.seqElapsed + ctx.worldDt, backendSec) -- 794
			if self.seqElapsed > ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 then -- 794
				self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 -- 796
			end -- 796
		else -- 796
			self.seqElapsed = self.seqElapsed + ctx.worldDt -- 799
			if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 799
				self.holdElapsed = self.holdElapsed + ctx.worldDt -- 801
			end -- 801
		end -- 801
	end -- 801
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 801
		self.doorClosedAfterRetry = true -- 807
	end -- 807
	self:syncDerivedMilestones(self.seqElapsed, route) -- 809
end -- 720
function TowerEndingsPlugin.prototype.stepRehearsal(self, ctx, route) -- 812
	self.active = true -- 813
	if not ctx.paused and ctx.worldDt > 0 then -- 813
		self.seqElapsed = self.seqElapsed + ctx.worldDt -- 815
		if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 815
			self.holdElapsed = self.holdElapsed + ctx.worldDt -- 817
		end -- 817
	end -- 817
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 817
		self.doorClosedAfterRetry = true -- 821
	end -- 821
	self:syncDerivedMilestones(self.seqElapsed, route) -- 823
end -- 812
function TowerEndingsPlugin.prototype.syncDerivedMilestones(self, t, route) -- 826
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec and self.knockCount < 1 then -- 826
		self.knockCount = 1 -- 828
	end -- 828
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec and self.knockCount < 2 then -- 828
		self.knockCount = 2 -- 831
	end -- 831
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec and self.replyKnockCount < 1 then -- 831
		self.replyKnockCount = 1 -- 834
	end -- 834
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec and self.replyKnockCount < 2 then -- 834
		self.replyKnockCount = 2 -- 837
	end -- 837
	if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 837
		self.doorOpened = true -- 840
	end -- 840
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec and not self.row1Written then -- 840
		self.row1Written = true -- 844
		self.registryAppendCount = self.registryAppendCount + 1 -- 845
	end -- 845
	if route == "soldier" and t >= 4.6 and not self.row2Written then -- 845
		self.row2Written = true -- 848
		self.registryAppendCount = self.registryAppendCount + 1 -- 849
	end -- 849
	if route == "child" and self.row2Written then -- 849
		self.row2Written = false -- 853
		self.registryAppendCount = self.row1Written and 1 or 0 -- 854
	end -- 854
end -- 826
function TowerEndingsPlugin.prototype.stepInputGuard(self, input) -- 858
	local keyHeld = input.interact.held or input.retry.held -- 859
	local keyPressed = input.interact.pressed or input.retry.pressed -- 860
	local readyTime = self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 861
	if self.staleInputMustRelease then -- 861
		if not keyHeld then -- 861
			self.staleInputMustRelease = false -- 865
		elseif keyPressed then -- 865
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 867
		end -- 867
		self.confirmReady = false -- 869
		return -- 870
	end -- 870
	if not readyTime then -- 870
		if keyPressed then -- 870
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 875
			self.staleInputMustRelease = keyHeld -- 876
		end -- 876
		self.confirmReady = false -- 878
		return -- 879
	end -- 879
	self.confirmReady = true -- 882
	if self.rehearsalActive and keyPressed then -- 882
		self.rehearsalAcknowledged = true -- 884
	end -- 884
end -- 858
function TowerEndingsPlugin.prototype.playTowerOnce(self, audio, tag, track, path, volume, cueId, tick, seq) -- 888
	if seq == nil then -- 888
		seq = -1 -- 896
	end -- 896
	local dedupeKey = (("tower:s" .. tostring(self.sessionId)) .. ":") .. tag -- 898
	audio:playOnce( -- 899
		dedupeKey, -- 899
		track, -- 899
		path, -- 899
		volume, -- 899
		cueId, -- 899
		tick, -- 899
		seq -- 899
	) -- 899
end -- 888
function TowerEndingsPlugin.prototype.syncAudioCues(self, audio, ctx, route) -- 902
	local t = self.seqElapsed -- 903
	local tick = ctx.p.ticks -- 904
	local indoorK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.5, t) -- 905
	self.loopsActive = true -- 908
	audio:playLoop( -- 909
		"tower_wind_cold", -- 909
		"wind", -- 909
		____exports.TOWER_AUDIO_FILES.windCold, -- 909
		lerp(0.36, 0.14, indoorK), -- 909
		tick -- 909
	) -- 909
	if indoorK > 0.05 then -- 909
		audio:playLoop( -- 911
			"tower_room_warm", -- 911
			"ambience", -- 911
			____exports.TOWER_AUDIO_FILES.roomWarm, -- 911
			lerp(0.06, 0.34, indoorK), -- 911
			tick -- 911
		) -- 911
	end -- 911
	if self.indoorRetryCount == 0 then -- 911
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec then -- 911
			self:playTowerOnce( -- 917
				audio, -- 917
				"knock1", -- 917
				"sfx", -- 917
				____exports.TOWER_AUDIO_FILES.knock1, -- 917
				0.88, -- 917
				"tower:knock:1", -- 917
				tick -- 917
			) -- 917
		end -- 917
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec then -- 917
			self:playTowerOnce( -- 920
				audio, -- 920
				"knock2", -- 920
				"sfx", -- 920
				____exports.TOWER_AUDIO_FILES.knock2, -- 920
				0.9, -- 920
				"tower:knock:2", -- 920
				tick -- 920
			) -- 920
		end -- 920
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 920
			self:playTowerOnce( -- 923
				audio, -- 923
				"reply1", -- 923
				"sfx", -- 923
				____exports.TOWER_AUDIO_FILES.reply1, -- 923
				0.78, -- 923
				"tower:reply:1", -- 923
				tick -- 923
			) -- 923
		end -- 923
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec then -- 923
			self:playTowerOnce( -- 926
				audio, -- 926
				"reply2", -- 926
				"sfx", -- 926
				____exports.TOWER_AUDIO_FILES.reply2, -- 926
				0.8, -- 926
				"tower:reply:2", -- 926
				tick -- 926
			) -- 926
		end -- 926
		if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 926
			self:playTowerOnce( -- 929
				audio, -- 929
				"door_open", -- 929
				"sfx", -- 929
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 929
				0.84, -- 929
				"tower:door_open", -- 929
				tick -- 929
			) -- 929
		end -- 929
	end -- 929
	if t >= 1.5 then -- 929
		self:playTowerOnce( -- 934
			audio, -- 934
			"book_open", -- 934
			"sfx", -- 934
			____exports.TOWER_AUDIO_FILES.bookOpen, -- 934
			0.82, -- 934
			"tower:book_open", -- 934
			tick -- 934
		) -- 934
	end -- 934
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 934
		self:playTowerOnce( -- 937
			audio, -- 937
			"brush1", -- 937
			"sfx", -- 937
			____exports.TOWER_AUDIO_FILES.brush1, -- 937
			0.8, -- 937
			"tower:brush:row1", -- 937
			tick -- 937
		) -- 937
	end -- 937
	if route == "child" then -- 937
		if t >= 4.35 then -- 937
			self:playTowerOnce( -- 942
				audio, -- 942
				"f03_line", -- 942
				"voice", -- 942
				____exports.TOWER_AUDIO_FILES.lineXiaomanLamp, -- 942
				0.86, -- 942
				"tower:f03:line_lamp", -- 942
				tick -- 942
			) -- 942
		end -- 942
		if t >= 4.45 then -- 942
			self:playTowerOnce( -- 945
				audio, -- 945
				"f03_bowl", -- 945
				"sfx", -- 945
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 945
				0.8, -- 945
				"tower:bowl_set", -- 945
				tick -- 945
			) -- 945
		end -- 945
		if t >= 5.2 then -- 945
			self:playTowerOnce( -- 948
				audio, -- 948
				"f03_lamp", -- 948
				"sfx", -- 948
				____exports.TOWER_AUDIO_FILES.lampMove, -- 948
				0.82, -- 948
				"tower:f03:lamp_move", -- 948
				tick -- 948
			) -- 948
		end -- 948
	else -- 948
		if t >= 4.28 then -- 948
			self:playTowerOnce( -- 952
				audio, -- 952
				"m03_line", -- 952
				"voice", -- 952
				____exports.TOWER_AUDIO_FILES.lineZhoushuName, -- 952
				0.9, -- 952
				"tower:m03:line_name", -- 952
				tick -- 952
			) -- 952
		end -- 952
		if t >= 4.62 then -- 952
			self:playTowerOnce( -- 955
				audio, -- 955
				"brush2", -- 955
				"sfx", -- 955
				____exports.TOWER_AUDIO_FILES.brush2, -- 955
				0.82, -- 955
				"tower:brush:row2", -- 955
				tick -- 955
			) -- 955
		end -- 955
		if t >= 5.55 then -- 955
			self:playTowerOnce( -- 958
				audio, -- 958
				"m03_needle", -- 958
				"sfx", -- 958
				____exports.TOWER_AUDIO_FILES.needlePlace, -- 958
				0.8, -- 958
				"tower:m03:needle_place", -- 958
				tick -- 958
			) -- 958
		end -- 958
		if t >= 6.02 then -- 958
			self:playTowerOnce( -- 961
				audio, -- 961
				"m03_bowl", -- 961
				"sfx", -- 961
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 961
				0.82, -- 961
				"tower:bowl_set", -- 961
				tick -- 961
			) -- 961
		end -- 961
	end -- 961
end -- 902
function TowerEndingsPlugin.prototype.composeSubtitle(self, route) -- 966
	local t = self.seqElapsed -- 967
	if t < ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 967
		return "[两下轻敲]  门外厚木上传来两声轻敲。" -- 969
	end -- 969
	if t < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 969
		return "[门内回敲]  静默一息，门后轻轻回敲两声。" -- 972
	end -- 972
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 972
		return route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 975
	end -- 975
	if t < ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 975
		return route == "child" and "她把针套与纸条摊在案前，守卒展开收籍末页。" or "两人站在值夜室内，守卒摊开收籍末页。" -- 980
	end -- 980
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 980
		return "守卒蘸墨提笔，在第一行写下「小满」。" -- 985
	end -- 985
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 985
		return "笔尖停在第二行上方。" -- 988
	end -- 988
	if route == "child" then -- 988
		if t < 6.7 then -- 988
			return F03_DIALOGUE -- 992
		end -- 992
		return "" -- 994
	end -- 994
	if t < 5.45 then -- 994
		return M03_DIALOGUE -- 997
	end -- 997
	if t < 6.85 then -- 997
		return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。" -- 1000
	end -- 1000
	return "" -- 1002
end -- 966
function TowerEndingsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1007
	if not self.active then -- 1007
		return false -- 1015
	end -- 1015
	local route = self.activeRoute -- 1018
	local t = self.seqElapsed -- 1019
	local lampProg = route == "child" and smoothstep(5.2, 6.75, t) or 0 -- 1020
	local scaled = computeScaledAnchors(ctx.uiW, ctx.uiH, lampProg) -- 1021
	local s = scaled.s -- 1022
	local ox = scaled.ox -- 1023
	local oy = scaled.oy -- 1024
	uiDraw:drawRect( -- 1027
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1027
		Color(8, 10, 16, 255) -- 1027
	) -- 1027
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1027
		self:drawAct1PorchAndDoor( -- 1031
			uiDraw, -- 1031
			uiInkDraw, -- 1031
			uiArt, -- 1031
			uiGlow, -- 1031
			ctx, -- 1031
			route, -- 1031
			s, -- 1031
			ox, -- 1031
			oy -- 1031
		) -- 1031
		local fadeOut = smoothstep(1.22, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec, t) -- 1033
		if fadeOut > 0.01 then -- 1033
			uiInkDraw:drawRect( -- 1035
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1035
				Color( -- 1035
					8, -- 1035
					10, -- 1035
					16, -- 1035
					math.floor(230 * fadeOut + 0.5) -- 1035
				) -- 1035
			) -- 1035
		end -- 1035
	else -- 1035
		self:drawAct2And3Guardroom( -- 1039
			uiDraw, -- 1039
			uiInkDraw, -- 1039
			uiArt, -- 1039
			uiGlow, -- 1039
			ctx, -- 1039
			route, -- 1039
			lampProg, -- 1039
			s, -- 1039
			ox, -- 1039
			oy -- 1039
		) -- 1039
		local fadeIn = 1 - smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.24, t) -- 1040
		if fadeIn > 0.01 then -- 1040
			uiInkDraw:drawRect( -- 1042
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1042
				Color( -- 1042
					8, -- 1042
					10, -- 1042
					16, -- 1042
					math.floor(220 * fadeIn + 0.5) -- 1042
				) -- 1042
			) -- 1042
		end -- 1042
	end -- 1042
	local barH = math.floor(____exports.TOWER_SHOT_LAYOUT.letterboxH * s + 0.5) -- 1047
	uiInkDraw:drawRect( -- 1048
		Rect(0, ctx.uiH - barH, ctx.uiW, barH), -- 1048
		Color(7, 9, 14, 248) -- 1048
	) -- 1048
	uiInkDraw:drawRect( -- 1049
		Rect(0, 0, ctx.uiW, barH), -- 1049
		Color(7, 9, 14, 248) -- 1049
	) -- 1049
	uiInkDraw:drawSegment( -- 1050
		Vec2(0, ctx.uiH - barH), -- 1050
		Vec2(ctx.uiW, ctx.uiH - barH), -- 1050
		0.9, -- 1050
		toColor(PALETTE.silkDim, 82) -- 1050
	) -- 1050
	uiInkDraw:drawSegment( -- 1051
		Vec2(0, barH), -- 1051
		Vec2(ctx.uiW, barH), -- 1051
		0.9, -- 1051
		toColor(PALETTE.silkDim, 82) -- 1051
	) -- 1051
	self:drawDialogueSubtitle( -- 1054
		uiDraw, -- 1054
		uiInkDraw, -- 1054
		uiArt, -- 1054
		ctx, -- 1054
		route, -- 1054
		s, -- 1054
		barH -- 1054
	) -- 1054
	return true -- 1056
end -- 1007
function TowerEndingsPlugin.prototype.drawAct1PorchAndDoor(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1061
	local t = self.seqElapsed -- 1072
	local isChild = route == "child" -- 1073
	local openK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, 1.24, t) -- 1074
	local doorCx = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s -- 1075
	local threshY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s -- 1076
	local k1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock1Sec) / 0.055) ^ 2) -- 1078
	local k2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock2Sec) / 0.055) ^ 2) -- 1079
	local r1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply1Sec) / 0.06) ^ 2) -- 1080
	local r2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply2Sec) / 0.06) ^ 2) -- 1081
	local doorShakeX = (k1Pulse + k2Pulse) * 2.4 * s * math.sin(t * 95) + (r1Pulse + r2Pulse) * 1.4 * s * math.sin(t * 80) -- 1082
	local rect = computeFullscreenSlideRect(ctx.uiW, ctx.uiH) -- 1085
	local shiftedRect = { -- 1086
		x = math.floor(rect.x + doorShakeX * (1 - openK) + 0.5), -- 1086
		y = rect.y, -- 1086
		w = rect.w, -- 1086
		h = rect.h -- 1086
	} -- 1086
	local closedSlot = isChild and "slide_tower_porch_f03_closed" or "slide_tower_porch_m03_closed" -- 1087
	local openSlot = isChild and "slide_tower_porch_f03_open" or "slide_tower_porch_m03_open" -- 1088
	if openK < 0.98 then -- 1088
		drawPixelSlidePlate( -- 1091
			uiDraw, -- 1091
			uiInkDraw, -- 1091
			uiArt, -- 1091
			closedSlot, -- 1091
			"fe05_porch_closed", -- 1091
			shiftedRect, -- 1091
			1, -- 1091
			0 -- 1091
		) -- 1091
	end -- 1091
	if openK > 0.02 then -- 1091
		drawPixelSlidePlate( -- 1094
			uiDraw, -- 1094
			uiInkDraw, -- 1094
			uiArt, -- 1094
			openSlot, -- 1094
			"fe05_porch_open", -- 1094
			rect, -- 1094
			openK, -- 1094
			1 -- 1094
		) -- 1094
	end -- 1094
	local seamGlowA = math.floor(52 + openK * 115 + (r1Pulse + r2Pulse) * 42 + 0.5) -- 1098
	fillRadialGlow( -- 1099
		uiGlow, -- 1100
		doorCx, -- 1101
		threshY + 46 * s, -- 1102
		(110 + openK * 140) * s, -- 1103
		(64 + openK * 92) * s, -- 1104
		Color( -- 1105
			246, -- 1105
			204, -- 1105
			134, -- 1105
			math.min(185, seamGlowA) -- 1105
		), -- 1105
		Color(220, 156, 72, 0), -- 1106
		18 -- 1107
	) -- 1107
	local kx = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s -- 1111
	local ky = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s -- 1112
	if k1Pulse > 0.08 or k2Pulse > 0.08 then -- 1112
		local amp = math.max(k1Pulse, k2Pulse) -- 1114
		local r = (18 + (1 - amp) * 34) * s -- 1115
		strokeEllipse( -- 1116
			uiInkDraw, -- 1116
			kx + 24 * s, -- 1116
			ky, -- 1116
			r, -- 1116
			r * 0.85, -- 1116
			1.8 * s, -- 1116
			toColor( -- 1116
				PALETTE.amberCore, -- 1116
				math.floor(210 * amp + 0.5) -- 1116
			), -- 1116
			24 -- 1116
		) -- 1116
	end -- 1116
	if r1Pulse > 0.08 or r2Pulse > 0.08 then -- 1116
		local amp = math.max(r1Pulse, r2Pulse) -- 1119
		local r = (24 + (1 - amp) * 42) * s -- 1120
		strokeEllipse( -- 1121
			uiInkDraw, -- 1121
			doorCx + 20 * s, -- 1121
			ky + 14 * s, -- 1121
			r, -- 1121
			r * 0.9, -- 1121
			1.6 * s, -- 1121
			toColor( -- 1121
				PALETTE.amber, -- 1121
				math.floor(185 * amp + 0.5) -- 1121
			), -- 1121
			24 -- 1121
		) -- 1121
	end -- 1121
	local stepInX = openK * 44 * s -- 1125
	local xiaomanX = doorCx - 66 * s + stepInX -- 1126
	local xiaomanY = threshY - 2 * s -- 1127
	uiDraw:drawEllipse( -- 1128
		Vec2(xiaomanX, xiaomanY + 2 * s), -- 1128
		34 * s, -- 1128
		8 * s, -- 1128
		Color(4, 6, 12, 190) -- 1128
	) -- 1128
	local childSlot = (k1Pulse > 0.25 or k2Pulse > 0.25) and "child_knock" or (openK > 0.45 and "child_offer" or "child_idle") -- 1129
	uiArt:tryPlace( -- 1130
		childSlot, -- 1130
		"fe05_porch_child", -- 1130
		xiaomanX, -- 1130
		xiaomanY, -- 1130
		108 * s, -- 1130
		148 * s, -- 1130
		{facing = 1, opacity = 0.98, layer = 3} -- 1130
	) -- 1130
	if route == "soldier" then -- 1130
		local zhouX = xiaomanX - 64 * s -- 1135
		local zhouY = threshY - 2 * s -- 1136
		uiDraw:drawEllipse( -- 1137
			Vec2(zhouX, zhouY + 2 * s), -- 1137
			42 * s, -- 1137
			9 * s, -- 1137
			Color(4, 6, 12, 190) -- 1137
		) -- 1137
		uiArt:tryPlace( -- 1138
			"fe_soldier_hand_hold", -- 1138
			"fe05_porch_soldier", -- 1138
			zhouX, -- 1138
			zhouY, -- 1138
			146 * s, -- 1138
			206 * s, -- 1138
			{facing = 1, opacity = 0.98, layer = 2} -- 1138
		) -- 1138
	end -- 1138
end -- 1061
function TowerEndingsPlugin.prototype.drawAct2And3Guardroom(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy) -- 1146
	local t = self.seqElapsed -- 1158
	local isChild = route == "child" -- 1159
	local rect = computeFullscreenSlideRect(ctx.uiW, ctx.uiH) -- 1160
	if isChild then -- 1160
		if lampProg < 0.98 then -- 1160
			drawPixelSlidePlate( -- 1165
				uiDraw, -- 1165
				uiInkDraw, -- 1165
				uiArt, -- 1165
				"slide_tower_room_f03_cold", -- 1165
				"fe05_room_f03_cold", -- 1165
				rect, -- 1165
				1, -- 1165
				0 -- 1165
			) -- 1165
		end -- 1165
		if lampProg > 0.02 then -- 1165
			drawPixelSlidePlate( -- 1168
				uiDraw, -- 1168
				uiInkDraw, -- 1168
				uiArt, -- 1168
				"slide_tower_room_f03_lit", -- 1168
				"fe05_room_f03_lit", -- 1168
				rect, -- 1168
				lampProg, -- 1168
				1 -- 1168
			) -- 1168
		end -- 1168
	else -- 1168
		drawPixelSlidePlate( -- 1171
			uiDraw, -- 1171
			uiInkDraw, -- 1171
			uiArt, -- 1171
			"slide_tower_room_m03_warm", -- 1171
			"fe05_room_m03_warm", -- 1171
			rect, -- 1171
			1, -- 1171
			0 -- 1171
		) -- 1171
	end -- 1171
	local lx = isChild and ox + lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s or ox + ____exports.TOWER_SHOT_LAYOUT.lampDeskX * s -- 1175
	local ly = isChild and oy + (lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34) * s or oy + ____exports.TOWER_SHOT_LAYOUT.lampDeskY * s -- 1178
	local lampWarmth = isChild and 0.45 + 0.55 * lampProg or 0.92 -- 1181
	if isChild and lampProg < 0.94 then -- 1181
		local movingOp = 1 - smoothstep(0.78, 0.94, lampProg) -- 1183
		self:drawMingLanternSprite( -- 1184
			uiArt, -- 1184
			uiGlow, -- 1184
			lx, -- 1184
			ly, -- 1184
			1.05 * s, -- 1184
			movingOp, -- 1184
			lampWarmth, -- 1184
			"fe05_lamp_move" -- 1184
		) -- 1184
	elseif isChild then -- 1184
		local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 1186
		fillRadialGlow( -- 1187
			uiGlow, -- 1188
			ox + ____exports.TOWER_SHOT_LAYOUT.lampWindowX * s, -- 1189
			oy + ____exports.TOWER_SHOT_LAYOUT.lampWindowY * s, -- 1190
			160 * s * flicker, -- 1191
			145 * s * flicker, -- 1192
			Color(250, 208, 132, 92), -- 1193
			Color(228, 162, 74, 0), -- 1194
			18 -- 1195
		) -- 1195
	end -- 1195
	if isChild and lampProg > 0.04 then -- 1195
		local beamA = math.floor(58 * lampProg + 0.5) -- 1201
		fillGradQuad( -- 1202
			uiGlow, -- 1203
			lx + 10 * s, -- 1204
			ly + 30 * s, -- 1204
			Color(248, 206, 134, beamA), -- 1204
			lx + 10 * s, -- 1205
			ly - 32 * s, -- 1205
			Color( -- 1205
				248, -- 1205
				206, -- 1205
				134, -- 1205
				math.floor(beamA * 0.72 + 0.5) -- 1205
			), -- 1205
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.92) * s, -- 1206
			oy + (____exports.TOWER_SHOT_LAYOUT.row2Y - 58) * s, -- 1206
			Color(242, 198, 124, 0), -- 1206
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.85) * s, -- 1207
			oy + (____exports.TOWER_SHOT_LAYOUT.row1Y + 48) * s, -- 1207
			Color(242, 198, 124, 0) -- 1207
		) -- 1207
	end -- 1207
	local bookReveal = smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t) -- 1212
	if bookReveal > 0.02 then -- 1212
		self:drawRegisterBook( -- 1214
			uiDraw, -- 1214
			uiInkDraw, -- 1214
			uiArt, -- 1214
			uiGlow, -- 1214
			ctx, -- 1214
			route, -- 1214
			bookReveal, -- 1214
			lampProg, -- 1214
			s, -- 1214
			ox, -- 1214
			oy -- 1214
		) -- 1214
	end -- 1214
	self:drawDeskPropsAndBowl( -- 1218
		uiDraw, -- 1218
		uiInkDraw, -- 1218
		uiArt, -- 1218
		uiGlow, -- 1218
		ctx, -- 1218
		route, -- 1218
		s, -- 1218
		ox, -- 1218
		oy -- 1218
	) -- 1218
end -- 1146
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiGlow, ctx, lampProg, s, ox, oy) -- 1221
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1230
	local wallTop = lerpRGBA( -- 1231
		rgba(18, 24, 38, 255), -- 1231
		rgba(46, 36, 28, 255), -- 1231
		lampProg -- 1231
	) -- 1231
	local wallBot = lerpRGBA( -- 1232
		rgba(12, 16, 26, 255), -- 1232
		rgba(28, 22, 20, 255), -- 1232
		lampProg -- 1232
	) -- 1232
	fillVGradRect( -- 1233
		uiDraw, -- 1233
		0, -- 1233
		0, -- 1233
		ctx.uiW, -- 1233
		ctx.uiH, -- 1233
		toColor(wallBot), -- 1233
		toColor(wallTop) -- 1233
	) -- 1233
	local beamCol = shadeSurface( -- 1236
		MING_MATERIALS.mingTimberDark.base, -- 1236
		vec3(-0.3, -0.6, -0.74), -- 1236
		18, -- 1236
		1, -- 1236
		light, -- 1236
		MING_MATERIALS.mingTimberDark -- 1236
	) -- 1236
	uiDraw:drawPolygon( -- 1237
		{ -- 1237
			Vec2(0, ctx.uiH - 96 * s), -- 1238
			Vec2(ctx.uiW, ctx.uiH - 72 * s), -- 1239
			Vec2(ctx.uiW, ctx.uiH - 42 * s), -- 1240
			Vec2(0, ctx.uiH - 42 * s) -- 1241
		}, -- 1241
		toColor(beamCol) -- 1242
	) -- 1242
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1245
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1246
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1247
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1248
	local embrasure = 24 * s -- 1249
	fillVGradRect( -- 1252
		uiDraw, -- 1252
		wx, -- 1252
		wy, -- 1252
		ww, -- 1252
		wh, -- 1252
		Color(34, 44, 62, 255), -- 1252
		Color(16, 24, 40, 255) -- 1252
	) -- 1252
	uiDraw:drawPolygon( -- 1253
		{ -- 1253
			Vec2(wx, wy), -- 1254
			Vec2(wx + ww, wy), -- 1255
			Vec2(wx + ww, wy + wh * 0.34), -- 1256
			Vec2(wx + ww * 0.56, wy + wh * 0.42), -- 1257
			Vec2(wx + ww * 0.22, wy + wh * 0.28), -- 1258
			Vec2(wx, wy + wh * 0.36) -- 1259
		}, -- 1259
		Color(20, 26, 38, 240) -- 1260
	) -- 1260
	if lampProg > 0.12 then -- 1260
		fillRadialGlow( -- 1263
			uiGlow, -- 1264
			wx + ww * 0.5, -- 1264
			wy + 26 * s, -- 1264
			ww * 0.65, -- 1265
			wh * 0.55, -- 1265
			Color( -- 1266
				248, -- 1266
				206, -- 1266
				134, -- 1266
				math.floor(92 * lampProg + 0.5) -- 1266
			), -- 1266
			Color(232, 174, 88, 0), -- 1267
			16 -- 1268
		) -- 1268
	end -- 1268
	local leftWall = shadeSurface( -- 1273
		MING_MATERIALS.mingBrick.base, -- 1273
		vec3(0.84, 0.22, -0.49), -- 1273
		10, -- 1273
		1, -- 1273
		light, -- 1273
		MING_MATERIALS.mingBrick -- 1273
	) -- 1273
	local rightWall = shadeSurface( -- 1274
		MING_MATERIALS.mingBrick.base, -- 1274
		vec3(-0.84, 0.22, -0.49), -- 1274
		10, -- 1274
		1, -- 1274
		light, -- 1274
		MING_MATERIALS.mingBrick -- 1274
	) -- 1274
	local sillCol = shadeSurface( -- 1275
		MING_MATERIALS.mingStoneStep.base, -- 1275
		vec3(0, 0.94, -0.34), -- 1275
		6, -- 1275
		1, -- 1275
		light, -- 1275
		MING_MATERIALS.mingStoneStep -- 1275
	) -- 1275
	uiDraw:drawPolygon( -- 1276
		{ -- 1276
			Vec2(wx - embrasure, wy - 12 * s), -- 1277
			Vec2(wx, wy), -- 1278
			Vec2(wx, wy + wh), -- 1279
			Vec2(wx - embrasure, wy + wh + 14 * s) -- 1280
		}, -- 1280
		toColor(leftWall) -- 1281
	) -- 1281
	uiDraw:drawPolygon( -- 1282
		{ -- 1282
			Vec2(wx + ww, wy), -- 1283
			Vec2(wx + ww + embrasure, wy - 12 * s), -- 1284
			Vec2(wx + ww + embrasure, wy + wh + 14 * s), -- 1285
			Vec2(wx + ww, wy + wh) -- 1286
		}, -- 1286
		toColor(rightWall) -- 1287
	) -- 1287
	uiDraw:drawPolygon( -- 1289
		{ -- 1289
			Vec2(wx - embrasure - 10 * s, wy - 16 * s), -- 1290
			Vec2(wx + ww + embrasure + 10 * s, wy - 16 * s), -- 1291
			Vec2(wx + ww + 4 * s, wy + 10 * s), -- 1292
			Vec2(wx - 4 * s, wy + 10 * s) -- 1293
		}, -- 1293
		toColor(sillCol), -- 1294
		1, -- 1294
		toColor(STONE_EDGE_FALLBACK, 140) -- 1294
	) -- 1294
	local bar = 1 -- 1297
	do -- 1297
		bar = 1 -- 1298
		while bar <= 3 do -- 1298
			local bx = wx + ww * bar / 4 -- 1299
			uiDraw:drawSegment( -- 1300
				Vec2(bx, wy + 6 * s), -- 1300
				Vec2(bx, wy + wh - 2 * s), -- 1300
				3 * s, -- 1300
				Color(46, 34, 26, 235) -- 1300
			) -- 1300
			bar = bar + 1 -- 1298
		end -- 1298
	end -- 1298
	uiDraw:drawSegment( -- 1302
		Vec2(wx, wy + wh * 0.56), -- 1302
		Vec2(wx + ww, wy + wh * 0.56), -- 1302
		3.2 * s, -- 1302
		Color(46, 34, 26, 235) -- 1302
	) -- 1302
	uiDraw:drawRect( -- 1303
		Rect(wx, wy, ww, wh), -- 1303
		Color(0, 0, 0, 0), -- 1303
		2.4 * s, -- 1303
		Color(66, 50, 38, 240) -- 1303
	) -- 1303
	if lampProg > 0.02 then -- 1303
		fillRadialGlow( -- 1307
			uiGlow, -- 1308
			wx + ww * 0.5, -- 1308
			wy + 34 * s, -- 1308
			540 * s, -- 1309
			390 * s, -- 1309
			Color( -- 1310
				246, -- 1310
				198, -- 1310
				122, -- 1310
				math.floor(74 * lampProg + 0.5) -- 1310
			), -- 1310
			Color(216, 154, 72, 0), -- 1311
			20 -- 1312
		) -- 1312
	end -- 1312
end -- 1221
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1317
	fillVGradRect( -- 1327
		uiDraw, -- 1328
		0, -- 1328
		0, -- 1328
		ctx.uiW, -- 1328
		ctx.uiH, -- 1328
		Color(26, 21, 20, 255), -- 1329
		Color(46, 36, 30, 255) -- 1330
	) -- 1330
	local r = 0 -- 1333
	do -- 1333
		r = 0 -- 1334
		while r < 9 do -- 1334
			local y = oy + (280 + r * 44) * s -- 1335
			uiDraw:drawSegment( -- 1336
				Vec2(0, y), -- 1336
				Vec2(ctx.uiW, y), -- 1336
				1, -- 1336
				Color(34, 27, 24, 150) -- 1336
			) -- 1336
			r = r + 1 -- 1334
		end -- 1334
	end -- 1334
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1340
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1341
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1342
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1343
	fillVGradRect( -- 1344
		uiDraw, -- 1344
		wx, -- 1344
		wy, -- 1344
		ww, -- 1344
		wh, -- 1344
		Color(56, 62, 74, 255), -- 1344
		Color(26, 34, 50, 255) -- 1344
	) -- 1344
	uiDraw:drawRect( -- 1345
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1345
		Color(92, 68, 48, 255), -- 1345
		1, -- 1345
		Color(148, 114, 82, 180) -- 1345
	) -- 1345
	local bar = 1 -- 1346
	do -- 1346
		bar = 1 -- 1347
		while bar <= 3 do -- 1347
			local bx = wx + ww * bar / 4 -- 1348
			uiDraw:drawSegment( -- 1349
				Vec2(bx, wy + 4 * s), -- 1349
				Vec2(bx, wy + wh - 2 * s), -- 1349
				3.2 * s, -- 1349
				Color(64, 46, 34, 245) -- 1349
			) -- 1349
			bar = bar + 1 -- 1347
		end -- 1347
	end -- 1347
	uiDraw:drawSegment( -- 1351
		Vec2(wx, wy + wh * 0.56), -- 1351
		Vec2(wx + ww, wy + wh * 0.56), -- 1351
		3.2 * s, -- 1351
		Color(64, 46, 34, 245) -- 1351
	) -- 1351
	uiDraw:drawRect( -- 1352
		Rect(wx, wy, ww, wh), -- 1352
		Color(0, 0, 0, 0), -- 1352
		2.8 * s, -- 1352
		Color(88, 64, 44, 245) -- 1352
	) -- 1352
	local groupX = ox + 210 * s -- 1355
	local groupY = oy + 300 * s -- 1356
	uiArt:tryPlace( -- 1357
		"soldier_idle", -- 1357
		"fe05_m03_room_soldier", -- 1357
		groupX - 38 * s, -- 1357
		groupY, -- 1357
		118 * s, -- 1357
		166 * s, -- 1357
		{facing = 1, opacity = 0.9, layer = 1} -- 1357
	) -- 1357
	uiArt:tryPlace( -- 1360
		"child_idle", -- 1360
		"fe05_m03_room_child", -- 1360
		groupX + 42 * s, -- 1360
		groupY, -- 1360
		86 * s, -- 1360
		116 * s, -- 1360
		{facing = 1, opacity = 0.92, layer = 1} -- 1360
	) -- 1360
	fillRadialGlow( -- 1365
		uiGlow, -- 1366
		ox + 260 * s, -- 1366
		oy + 416 * s, -- 1366
		520 * s, -- 1367
		360 * s, -- 1367
		Color(246, 202, 134, 68), -- 1368
		Color(220, 158, 76, 0), -- 1369
		20 -- 1370
	) -- 1370
end -- 1317
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1374
	local t = self.seqElapsed -- 1387
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1388
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1389
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1390
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1391
	local midX = bx + bw * 0.5 -- 1392
	local midY = by + bh * 0.5 -- 1393
	uiDraw:drawRect( -- 1396
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1396
		Color( -- 1396
			10, -- 1396
			11, -- 1396
			16, -- 1396
			math.floor(108 * reveal + 0.5) -- 1396
		) -- 1396
	) -- 1396
	uiDraw:drawRect( -- 1397
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1397
		Color( -- 1397
			32, -- 1397
			46, -- 1397
			62, -- 1397
			math.floor(235 * reveal + 0.5) -- 1397
		), -- 1397
		1, -- 1397
		Color( -- 1397
			86, -- 1397
			104, -- 1397
			124, -- 1397
			math.floor(165 * reveal + 0.5) -- 1397
		) -- 1397
	) -- 1397
	if not uiArt:tryPlace( -- 1397
		"ink_song_paper", -- 1400
		"fe05_registry_paper", -- 1400
		midX, -- 1400
		midY, -- 1400
		bw, -- 1400
		bh, -- 1400
		{opacity = 0.98 * reveal, layer = 1} -- 1400
	) then -- 1400
		uiDraw:drawRect( -- 1401
			Rect(bx, by, bw, bh), -- 1402
			toColor( -- 1403
				PALETTE.xuanPaper, -- 1403
				math.floor(248 * reveal + 0.5) -- 1403
			), -- 1403
			1, -- 1404
			toColor( -- 1405
				PALETTE.silkDim, -- 1405
				math.floor(180 * reveal + 0.5) -- 1405
			) -- 1405
		) -- 1405
	end -- 1405
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1410
	fillRadialGlow( -- 1411
		uiGlow, -- 1412
		bx + bw * 0.34, -- 1412
		by + bh * 0.48, -- 1412
		bw * 0.58, -- 1413
		bh * 0.52, -- 1413
		Color( -- 1414
			246, -- 1414
			214, -- 1414
			156, -- 1414
			math.floor(44 * paperWarm * reveal + 0.5) -- 1414
		), -- 1414
		Color(238, 198, 128, 0), -- 1415
		16 -- 1416
	) -- 1416
	local padX = 44 * s -- 1420
	local padY = 32 * s -- 1421
	local inX = bx + padX -- 1422
	local inY = by + padY -- 1423
	local inW = bw - padX * 2 -- 1424
	local inH = bh - padY * 2 -- 1425
	local redSilk = toColor( -- 1426
		PALETTE.rouge, -- 1426
		math.floor(132 * reveal + 0.5) -- 1426
	) -- 1426
	local redFaint = toColor( -- 1427
		PALETTE.rouge, -- 1427
		math.floor(70 * reveal + 0.5) -- 1427
	) -- 1427
	uiInkDraw:drawRect( -- 1428
		Rect(inX, inY, inW, inH), -- 1428
		Color(0, 0, 0, 0), -- 1428
		1, -- 1428
		redSilk -- 1428
	) -- 1428
	uiInkDraw:drawRect( -- 1429
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1429
		Color(0, 0, 0, 0), -- 1429
		0.6, -- 1429
		redFaint -- 1429
	) -- 1429
	local headY = inY + inH - 28 * s -- 1432
	ctx.texts:put( -- 1433
		"md", -- 1433
		"北塔值夜收籍 · 末页", -- 1433
		inX + 18 * s, -- 1433
		headY, -- 1433
		toColor(PALETTE.xuanInk), -- 1433
		0, -- 1433
		0.5, -- 1433
		"Left", -- 1433
		2.2, -- 1433
		0.96 * reveal, -- 1433
		0 -- 1433
	) -- 1433
	ctx.texts:put( -- 1434
		"xs", -- 1434
		"宁村北塔", -- 1434
		inX + inW - 18 * s, -- 1434
		headY, -- 1434
		toColor(PALETTE.xuanInkSub), -- 1434
		1, -- 1434
		0.5, -- 1434
		"Right", -- 1434
		1.8, -- 1434
		0.8 * reveal, -- 1434
		0 -- 1434
	) -- 1434
	uiInkDraw:drawSegment( -- 1435
		Vec2(inX + 14 * s, headY - 22 * s), -- 1435
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1435
		0.9, -- 1435
		redSilk -- 1435
	) -- 1435
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1438
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1439
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1440
	ctx.texts:put( -- 1441
		"sm", -- 1441
		"肆拾壹", -- 1441
		inX + 18 * s, -- 1441
		row1Y, -- 1441
		toColor(PALETTE.rouge), -- 1441
		0, -- 1441
		0.5, -- 1441
		"Left", -- 1441
		1, -- 1441
		0.94 * reveal, -- 1441
		0 -- 1441
	) -- 1441
	if r1Prog > 0.02 then -- 1441
		ctx.texts:put( -- 1443
			"md", -- 1443
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1443
			inX + 96 * s, -- 1443
			row1Y, -- 1443
			toColor(PALETTE.xuanInk), -- 1443
			0, -- 1443
			0.5, -- 1443
			"Left", -- 1443
			1.6, -- 1443
			0.96 * math.min(1, r1Prog * 1.4), -- 1443
			0 -- 1443
		) -- 1443
	end -- 1443
	if r1Prog > 0.65 then -- 1443
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1446
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1447
		ctx.texts:put( -- 1450
			"xs", -- 1450
			subText, -- 1450
			inX + 96 * s, -- 1450
			row1SubY, -- 1450
			toColor(PALETTE.xuanInkSub), -- 1450
			0, -- 1450
			0.5, -- 1450
			"Left", -- 1450
			0.6, -- 1450
			0.88 * subA, -- 1450
			0 -- 1450
		) -- 1450
	end -- 1450
	uiInkDraw:drawSegment( -- 1452
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1452
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1452
		0.7, -- 1452
		redFaint -- 1452
	) -- 1452
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1455
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1456
	ctx.texts:put( -- 1457
		"sm", -- 1457
		"肆拾贰", -- 1457
		inX + 18 * s, -- 1457
		row2Y, -- 1457
		toColor(PALETTE.rouge), -- 1457
		0, -- 1457
		0.5, -- 1457
		"Left", -- 1457
		1, -- 1457
		0.94 * reveal, -- 1457
		0 -- 1457
	) -- 1457
	if route == "child" then -- 1457
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1461
		uiInkDraw:drawSegment( -- 1462
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1463
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1464
			1, -- 1465
			toColor(PALETTE.xuanInkSub, lineA) -- 1466
		) -- 1466
	else -- 1466
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1470
		if r2Prog <= 0.02 then -- 1470
			uiInkDraw:drawSegment( -- 1472
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1473
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1474
				0.9, -- 1475
				toColor( -- 1476
					PALETTE.xuanInkSub, -- 1476
					math.floor(105 * reveal + 0.5) -- 1476
				) -- 1476
			) -- 1476
		else -- 1476
			ctx.texts:put( -- 1479
				"md", -- 1479
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1479
				inX + 96 * s, -- 1479
				row2Y, -- 1479
				toColor(PALETTE.xuanInk), -- 1479
				0, -- 1479
				0.5, -- 1479
				"Left", -- 1479
				1.6, -- 1479
				0.96 * math.min(1, r2Prog * 1.4), -- 1479
				0 -- 1479
			) -- 1479
			if r2Prog > 0.65 then -- 1479
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1481
				ctx.texts:put( -- 1482
					"xs", -- 1482
					"守城戍卒亲口报出姓名，两人俱安。", -- 1482
					inX + 96 * s, -- 1482
					row2SubY, -- 1482
					toColor(PALETTE.xuanInkSub), -- 1482
					0, -- 1482
					0.5, -- 1482
					"Left", -- 1482
					0.6, -- 1482
					0.88 * subA, -- 1482
					0 -- 1482
				) -- 1482
			end -- 1482
		end -- 1482
	end -- 1482
	uiInkDraw:drawSegment( -- 1486
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1486
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1486
		0.7, -- 1486
		redFaint -- 1486
	) -- 1486
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1489
	if colophonA > 0.02 then -- 1489
		local signY = inY + 34 * s -- 1491
		ctx.texts:put( -- 1492
			"banner", -- 1492
			"向西守望", -- 1492
			midX - 24 * s, -- 1492
			signY, -- 1492
			toColor(PALETTE.xuanInk), -- 1492
			0.5, -- 1492
			0.5, -- 1492
			"Center", -- 1492
			6, -- 1492
			0.88 * colophonA, -- 1492
			0 -- 1492
		) -- 1492
	end -- 1492
	self:drawGuardBrushHand( -- 1496
		uiInkDraw, -- 1496
		uiArt, -- 1496
		route, -- 1496
		s, -- 1496
		ox, -- 1496
		oy -- 1496
	) -- 1496
end -- 1374
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, uiArt, route, s, ox, oy) -- 1499
	local t = self.seqElapsed -- 1507
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1508
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1509
	local row1X0 = hoverX -- 1510
	local row1X1 = hoverX + 142 * s -- 1511
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1512
	local tipX = hoverX -- 1514
	local tipY = hoverY -- 1515
	local alpha = 0 -- 1516
	local lifted = 0 -- 1517
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1517
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1520
		tipX = lerp(row1X0, row1X1, k) -- 1521
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1522
		alpha = smoothstep(2, 2.2, t) -- 1523
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1524
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1524
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1526
		tipX = lerp(row1X1, hoverX, moveK) -- 1527
		tipY = lerp(row1Y, hoverY, moveK) -- 1528
		alpha = 1 -- 1529
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1530
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1530
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1532
		tipX = hoverX + outK * 140 * s -- 1533
		tipY = hoverY + outK * 46 * s -- 1534
		lifted = (9 + outK * 28) * s -- 1535
		alpha = 1 - outK -- 1536
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1536
		if t < 4.6 then -- 1536
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1539
			tipX = hoverX -- 1540
			tipY = hoverY -- 1541
			lifted = lerp(9 * s, 0, dipK) -- 1542
			alpha = 1 -- 1543
		elseif t < 5.55 then -- 1543
			local wK = smoothstep(4.6, 5.55, t) -- 1545
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1546
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1547
			lifted = 0 -- 1548
			alpha = 1 -- 1549
		else -- 1549
			local outK = smoothstep(5.55, 6.05, t) -- 1551
			tipX = hoverX + 216 * s + outK * 115 * s -- 1552
			tipY = hoverY + outK * 52 * s -- 1553
			lifted = outK * 24 * s -- 1554
			alpha = 1 - outK -- 1555
		end -- 1555
	end -- 1555
	if alpha <= 0.02 then -- 1555
		return -- 1560
	end -- 1560
	uiInkDraw:drawEllipse( -- 1564
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1564
		(5 + lifted * 0.22) * s, -- 1564
		2.8 * s, -- 1564
		Color( -- 1564
			20, -- 1564
			18, -- 1564
			16, -- 1564
			math.floor(78 * alpha + 0.5) -- 1564
		) -- 1564
	) -- 1564
	uiArt:tryPlace( -- 1566
		"fe_tower_brush_hand", -- 1566
		"fe05_brush_hand_px", -- 1566
		tipX, -- 1566
		tipY + lifted, -- 1566
		240 * s, -- 1566
		190 * s, -- 1566
		{ -- 1566
			opacity = clamp01(alpha), -- 1567
			layer = 6 -- 1568
		} -- 1568
	) -- 1568
end -- 1499
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1572
	local t = self.seqElapsed -- 1583
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1584
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1585
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1586
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1587
	if route == "child" then -- 1587
		local propA = smoothstep(1.55, 2.05, t) -- 1590
		if propA > 0.02 then -- 1590
			self:drawNeedleCaseOnDesk( -- 1592
				uiDraw, -- 1592
				uiArt, -- 1592
				ncX, -- 1592
				ncY, -- 1592
				s, -- 1592
				propA -- 1592
			) -- 1592
		end -- 1592
		local noteReadA = smoothstep(1.65, 2.1, t) * (1 - smoothstep(3.65, 4.15, t)) -- 1594
		if noteReadA > 0.02 then -- 1594
			local cardX = ncX + 18 * s -- 1596
			local cardY = ncY + 90 * s -- 1597
			uiInkDraw:drawRect( -- 1598
				Rect(cardX - 118 * s, cardY - 30 * s, 236 * s, 60 * s), -- 1599
				toColor( -- 1600
					PALETTE.xuanPaper, -- 1600
					math.floor(238 * noteReadA + 0.5) -- 1600
				), -- 1600
				1, -- 1601
				toColor( -- 1602
					PALETTE.rouge, -- 1602
					math.floor(110 * noteReadA + 0.5) -- 1602
				) -- 1602
			) -- 1602
			ctx.texts:put( -- 1604
				"xs", -- 1604
				NEEDLE_NOTE_LINES[1], -- 1604
				cardX, -- 1604
				cardY + 10 * s, -- 1604
				toColor(PALETTE.xuanInk), -- 1604
				0.5, -- 1604
				0.5, -- 1604
				"Center", -- 1604
				0.6, -- 1604
				0.94 * noteReadA, -- 1604
				0 -- 1604
			) -- 1604
			ctx.texts:put( -- 1605
				"xs", -- 1605
				"—— " .. NEEDLE_NOTE_LINES[2], -- 1605
				cardX + 74 * s, -- 1605
				cardY - 12 * s, -- 1605
				toColor(PALETTE.xuanInkSub), -- 1605
				1, -- 1605
				0.5, -- 1605
				"Right", -- 1605
				0.8, -- 1605
				0.88 * noteReadA, -- 1605
				0 -- 1605
			) -- 1605
		end -- 1605
		local bowlK = smoothstep(4.35, 5.15, t) -- 1607
		if bowlK > 0.02 then -- 1607
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1609
			self:drawWarmPorcelainBowl( -- 1610
				uiDraw, -- 1610
				uiArt, -- 1610
				bx, -- 1610
				bowlY, -- 1610
				s, -- 1610
				bowlK, -- 1610
				false -- 1610
			) -- 1610
		end -- 1610
	else -- 1610
		local needleK = smoothstep(5.45, 6.15, t) -- 1613
		if needleK > 0.02 then -- 1613
			local ny = lerp(ncY + 46 * s, ncY, needleK) -- 1615
			self:drawNeedleCaseOnDesk( -- 1616
				uiDraw, -- 1616
				uiArt, -- 1616
				ncX, -- 1616
				ny, -- 1616
				s, -- 1616
				needleK -- 1616
			) -- 1616
		end -- 1616
		local bowlK = smoothstep(5.8, 6.65, t) -- 1618
		if bowlK > 0.02 then -- 1618
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1620
			self:drawWarmPorcelainBowl( -- 1621
				uiDraw, -- 1621
				uiArt, -- 1621
				bowlX, -- 1621
				by, -- 1621
				s, -- 1621
				bowlK, -- 1621
				true -- 1621
			) -- 1621
		end -- 1621
		local cuffK = smoothstep(4.25, 4.85, t) -- 1624
		if cuffK > 0.02 then -- 1624
			uiArt:tryPlace( -- 1626
				"fe_tower_cuff_rest", -- 1626
				"fe05_m03_cuff_rest", -- 1626
				ox + 4 * s, -- 1626
				oy + 186 * s, -- 1626
				210 * s, -- 1626
				82 * s, -- 1626
				{opacity = 0.96 * cuffK, layer = 5} -- 1626
			) -- 1626
		end -- 1626
	end -- 1626
end -- 1572
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, draw, uiArt, cx, cy, s, alpha) -- 1635
	draw:drawEllipse( -- 1643
		Vec2(cx + 4 * s, cy - 16 * s), -- 1643
		48 * s, -- 1643
		14 * s, -- 1643
		Color( -- 1643
			10, -- 1643
			10, -- 1643
			14, -- 1643
			math.floor(135 * alpha + 0.5) -- 1643
		) -- 1643
	) -- 1643
	uiArt:tryPlace( -- 1644
		"fe_tower_pouch_note", -- 1644
		"fe05_pouch_px", -- 1644
		cx, -- 1644
		cy, -- 1644
		146 * s, -- 1644
		112 * s, -- 1644
		{ -- 1644
			opacity = clamp01(alpha), -- 1645
			layer = 5 -- 1646
		} -- 1646
	) -- 1646
end -- 1635
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, draw, uiArt, cx, cy, s, alpha, heldByTwoHands) -- 1651
	local by = cy - 34 * s -- 1660
	draw:drawEllipse( -- 1661
		Vec2(cx, by - 22 * s), -- 1661
		60 * s, -- 1661
		13 * s, -- 1661
		Color( -- 1661
			8, -- 1661
			9, -- 1661
			14, -- 1661
			math.floor(145 * alpha + 0.5) -- 1661
		) -- 1661
	) -- 1661
	if heldByTwoHands then -- 1661
		uiArt:tryPlace( -- 1663
			"fe_tower_bowl_hands", -- 1663
			"fe05_bowl_px", -- 1663
			cx, -- 1663
			by, -- 1663
			218 * s, -- 1663
			132 * s, -- 1663
			{ -- 1663
				opacity = clamp01(alpha), -- 1664
				layer = 6 -- 1665
			} -- 1665
		) -- 1665
	else -- 1665
		uiArt:tryPlace( -- 1668
			"fe_tower_bowl_solo", -- 1668
			"fe05_bowl_px", -- 1668
			cx, -- 1668
			by, -- 1668
			136 * s, -- 1668
			178 * s, -- 1668
			{ -- 1668
				opacity = clamp01(alpha), -- 1669
				layer = 6 -- 1670
			} -- 1670
		) -- 1670
	end -- 1670
	uiArt:tryPlace( -- 1674
		"fe_vfx_steam", -- 1674
		"fe05_bowl_steam", -- 1674
		cx, -- 1674
		by + 20 * s, -- 1674
		78 * s, -- 1674
		60 * s, -- 1674
		{ -- 1674
			frame = math.floor(self.animTime * 4.5), -- 1675
			opacity = 0.68 * clamp01(alpha), -- 1676
			layer = 7 -- 1677
		} -- 1677
	) -- 1677
end -- 1651
function TowerEndingsPlugin.prototype.drawMingLanternSprite(self, uiArt, glow, cx, cy, scale, alpha, warmth, key) -- 1682
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 1692
	uiArt:tryPlace( -- 1693
		"fe_tower_lantern_detail", -- 1693
		key, -- 1693
		cx, -- 1693
		cy - 16 * scale, -- 1693
		56 * scale, -- 1693
		92 * scale, -- 1693
		{ -- 1693
			opacity = clamp01(alpha), -- 1694
			layer = 5 -- 1695
		} -- 1695
	) -- 1695
	fillRadialGlow( -- 1697
		glow, -- 1698
		cx, -- 1698
		cy + 2 * scale, -- 1698
		96 * scale * flicker * (0.75 + 0.35 * warmth), -- 1699
		96 * scale * flicker * (0.75 + 0.35 * warmth), -- 1700
		Color( -- 1701
			250, -- 1701
			208, -- 1701
			132, -- 1701
			math.floor(115 * alpha * warmth + 0.5) -- 1701
		), -- 1701
		Color(228, 162, 74, 0), -- 1702
		16 -- 1703
	) -- 1703
end -- 1682
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 1707
	local line = self.lastSubtitle -- 1716
	if line ~= "" then -- 1716
		local cy = barH + 34 * s -- 1718
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 1719
		drawSilkVeil( -- 1720
			uiDraw, -- 1720
			uiArt, -- 1720
			"fe05_sub_veil", -- 1720
			ctx.uiW * 0.5, -- 1720
			cy, -- 1720
			stripW, -- 1720
			48 * s, -- 1720
			PALETTE.inkWash, -- 1720
			0.82, -- 1720
			3 -- 1720
		) -- 1720
		drawHairline( -- 1721
			uiInkDraw, -- 1721
			uiArt, -- 1721
			"fe05_sub_hair", -- 1721
			ctx.uiW * 0.5, -- 1721
			cy + 21 * s, -- 1721
			stripW * 0.68, -- 1721
			PALETTE.silkDim, -- 1721
			0.54, -- 1721
			true, -- 1721
			4 -- 1721
		) -- 1721
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 1722
		ctx.texts:put( -- 1723
			isSpoken and "md" or "sm", -- 1724
			line, -- 1725
			ctx.uiW * 0.5, -- 1726
			cy - 1 * s, -- 1727
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 1728
			0.5, -- 1729
			0.5, -- 1730
			"Center", -- 1731
			isSpoken and 1.8 or 1, -- 1732
			0.98, -- 1733
			0.08 -- 1734
		) -- 1734
	end -- 1734
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 1734
		local rawHint = route == "child" and "按 E 收页 · 尾声与史话   ·   Esc 暂歇" or "团圆尾声   ·   按 E 收页与史话   ·   Esc 暂歇" -- 1740
		local hint = adaptHintSentence(rawHint, ctx.input.inputMode, ctx.input.gamepadLayout) -- 1743
		ctx.texts:put( -- 1744
			"xs", -- 1744
			hint, -- 1744
			ctx.uiW * 0.5, -- 1744
			barH * 0.5, -- 1744
			toColor(PALETTE.textMid), -- 1744
			0.5, -- 1744
			0.5, -- 1744
			"Center", -- 1744
			1.4, -- 1744
			0.88, -- 1744
			0.08 -- 1744
		) -- 1744
	end -- 1744
end -- 1707
function ____exports.createTowerEndingsPlugin() -- 1749
	return __TS__New(____exports.TowerEndingsPlugin) -- 1750
end -- 1749
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 1754
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 1755
	fe:registerPlugin(plugin) -- 1756
	return plugin -- 1757
end -- 1754
return ____exports -- 1754