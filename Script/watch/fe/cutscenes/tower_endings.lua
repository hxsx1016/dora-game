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
local CUFF_PALETTE = ____cuff_shots.CUFF_PALETTE -- 34
local drawPatchedCuff = ____cuff_shots.drawPatchedCuff -- 34
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 36
local adaptHintSentence = ____control_prompts.adaptHintSentence -- 36
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 38
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 40
local TOWER_WEST_LAMP_LIGHT = ____lowpoly.TOWER_WEST_LAMP_LIGHT -- 41
local clamp01 = ____lowpoly.clamp01 -- 42
local normalize3 = ____lowpoly.normalize3 -- 43
local shadeSurface = ____lowpoly.shadeSurface -- 44
local smoothstep = ____lowpoly.smoothstep -- 45
local vec3 = ____lowpoly.vec3 -- 46
local ____theme = require("Script.watch.fe.theme") -- 48
local PALETTE = ____theme.PALETTE -- 49
local drawHairline = ____theme.drawHairline -- 51
local drawSilkVeil = ____theme.drawSilkVeil -- 52
local fillGradQuad = ____theme.fillGradQuad -- 53
local fillRadialGlow = ____theme.fillRadialGlow -- 54
local fillVGradRect = ____theme.fillVGradRect -- 55
local lerpRGBA = ____theme.lerpRGBA -- 56
local rgba = ____theme.rgba -- 57
local toColor = ____theme.toColor -- 58
--- 精确对齐后端 tower-knock(36 拍 = 0.6s, 第 0 / 12 拍敲门) 与 8.0 秒配对演出节拍
____exports.TOWER_ENDING_TIMINGS = { -- 88
	knock1Sec = 0, -- 89
	knock2Sec = 0.2, -- 90
	reply1Sec = 0.42, -- 91
	reply2Sec = 0.54, -- 92
	doorOpenSec = 0.6, -- 93
	indoorCutSec = 1.4, -- 94
	row1StartSec = 2.2, -- 95
	row1EndSec = 3.4, -- 96
	pivotStartSec = 3.4, -- 97
	pivotEndSec = 4.2, -- 98
	divergeEndSec = 6.8, -- 99
	holdReadySec = TOWER_CONFIRM_TICKS / 60 -- 100
} -- 100
local TOWER_AUDIO_ROOT = "assets/audio/tower/" -- 103
____exports.TOWER_AUDIO_FILES = { -- 105
	knock1 = TOWER_AUDIO_ROOT .. "door_knock_1.wav", -- 106
	knock2 = TOWER_AUDIO_ROOT .. "door_knock_2.wav", -- 107
	reply1 = TOWER_AUDIO_ROOT .. "door_reply_1.wav", -- 108
	reply2 = TOWER_AUDIO_ROOT .. "door_reply_2.wav", -- 109
	doorOpen = TOWER_AUDIO_ROOT .. "door_open.wav", -- 110
	bookOpen = TOWER_AUDIO_ROOT .. "book_open.wav", -- 111
	brush1 = TOWER_AUDIO_ROOT .. "brush_write_1.wav", -- 112
	brush2 = TOWER_AUDIO_ROOT .. "brush_write_2.wav", -- 113
	lampMove = TOWER_AUDIO_ROOT .. "lamp_move.wav", -- 114
	needlePlace = TOWER_AUDIO_ROOT .. "needle_case_place.wav", -- 115
	bowlSet = TOWER_AUDIO_ROOT .. "bowl_set.wav", -- 116
	windCold = TOWER_AUDIO_ROOT .. "tower_wind_cold.wav", -- 117
	roomWarm = TOWER_AUDIO_ROOT .. "tower_room_warm.wav", -- 118
	lineXiaomanLamp = TOWER_AUDIO_ROOT .. "line_xiaoman_lamp.wav", -- 119
	lineZhoushuName = TOWER_AUDIO_ROOT .. "line_zhoushu_name.wav" -- 120
} -- 120
--- 同机位配对布局真源（基准 1280×720 逻辑坐标系，F03 与 M03 100% 共享）：
-- 保证两版并排对照时门扇、门槛、提灯、西窗、簿页、一/二行基线、悬停笔尖、案沿热碗 0.00 px 偏差。
____exports.TOWER_SHOT_LAYOUT = { -- 127
	refW = 1280, -- 128
	refH = 720, -- 129
	letterboxH = 60, -- 130
	doorCenterX = 640, -- 132
	thresholdY = 168, -- 133
	doorW = 248, -- 134
	doorH = 374, -- 135
	knockHandX = 574, -- 136
	knockHandY = 312, -- 137
	doorLanternX = 710, -- 138
	doorLanternY = 344, -- 139
	westWindowX = 88, -- 141
	westWindowY = 382, -- 142
	westWindowW = 236, -- 143
	westWindowH = 224, -- 144
	deskTopY = 260, -- 145
	lampDeskX = 356, -- 146
	lampDeskY = 332, -- 147
	lampWindowX = 206, -- 148
	lampWindowY = 422, -- 149
	bookX = 416, -- 150
	bookY = 196, -- 151
	bookW = 588, -- 152
	bookH = 386, -- 153
	row1Y = 454, -- 154
	row1SubY = 424, -- 155
	row2Y = 354, -- 156
	row2SubY = 324, -- 157
	brushHoverTipX = 556, -- 158
	brushHoverTipY = 358, -- 159
	needleCaseDeskX = 294, -- 160
	needleCaseDeskY = 204, -- 161
	bowlRimX = 954, -- 162
	bowlRimY = 184, -- 163
	inkstoneX = 1112, -- 164
	inkstoneY = 256 -- 165
} -- 165
local F03_DIALOGUE = "「朝西那盏灯，能留着吗？」" -- 227
local M03_DIALOGUE = "「周戍。」" -- 228
--- F03 拂晓冷室灯光预设（挪灯前），向 TOWER_WEST_LAMP_LIGHT（西窗暖灯）平滑插值
local TOWER_COLD_DAWN_LIGHT = { -- 231
	keyDir = normalize3(vec3(-0.34, 0.72, -0.6)), -- 232
	keyColor = rgba(146, 174, 206, 255), -- 233
	keyStrength = 0.74, -- 234
	rimDir = normalize3(vec3(0.68, 0.44, -0.58)), -- 235
	rimColor = rgba(182, 166, 140, 255), -- 236
	rimStrength = 0.24, -- 237
	ambientColor = rgba(18, 24, 38, 255), -- 238
	fogColor = rgba(16, 22, 34, 255), -- 239
	fogStartZ = 50, -- 240
	fogEndZ = 460, -- 241
	fogMaxAlpha = 0.78, -- 242
	shadowContrast = 0.78 -- 243
} -- 243
local function lerp(a, b, t) -- 246
	return a + (b - a) * t -- 247
end -- 246
local function lerpLightRig(a, b, t) -- 250
	local k = clamp01(t) -- 251
	return { -- 252
		keyDir = normalize3(vec3( -- 253
			lerp(a.keyDir.x, b.keyDir.x, k), -- 254
			lerp(a.keyDir.y, b.keyDir.y, k), -- 255
			lerp(a.keyDir.z, b.keyDir.z, k) -- 256
		)), -- 256
		keyColor = lerpRGBA(a.keyColor, b.keyColor, k), -- 258
		keyStrength = lerp(a.keyStrength, b.keyStrength, k), -- 259
		rimDir = normalize3(vec3( -- 260
			lerp(a.rimDir.x, b.rimDir.x, k), -- 261
			lerp(a.rimDir.y, b.rimDir.y, k), -- 262
			lerp(a.rimDir.z, b.rimDir.z, k) -- 263
		)), -- 263
		rimColor = lerpRGBA(a.rimColor, b.rimColor, k), -- 265
		rimStrength = lerp(a.rimStrength, b.rimStrength, k), -- 266
		ambientColor = lerpRGBA(a.ambientColor, b.ambientColor, k), -- 267
		fogColor = lerpRGBA(a.fogColor, b.fogColor, k), -- 268
		fogStartZ = lerp(a.fogStartZ, b.fogStartZ, k), -- 269
		fogEndZ = lerp(a.fogEndZ, b.fogEndZ, k), -- 270
		fogMaxAlpha = lerp(a.fogMaxAlpha, b.fogMaxAlpha, k), -- 271
		shadowContrast = lerp(a.shadowContrast, b.shadowContrast, k) -- 272
	} -- 272
end -- 250
local function computeScaledAnchors(uiW, uiH, lampProg) -- 276
	local s = math.min(uiW / ____exports.TOWER_SHOT_LAYOUT.refW, uiH / ____exports.TOWER_SHOT_LAYOUT.refH) -- 282
	local ox = (uiW - ____exports.TOWER_SHOT_LAYOUT.refW * s) * 0.5 -- 283
	local oy = (uiH - ____exports.TOWER_SHOT_LAYOUT.refH * s) * 0.5 -- 284
	local lx = lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) -- 285
	local ly = lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34 -- 286
	return {s = s, ox = ox, oy = oy, anchors = { -- 288
		doorCenterX = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s, -- 293
		thresholdY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s, -- 294
		knockHandX = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s, -- 295
		knockHandY = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s, -- 296
		bookX = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s, -- 297
		bookY = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s, -- 298
		bookW = ____exports.TOWER_SHOT_LAYOUT.bookW * s, -- 299
		bookH = ____exports.TOWER_SHOT_LAYOUT.bookH * s, -- 300
		row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s, -- 301
		row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s, -- 302
		brushHoverTipX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s, -- 303
		brushHoverTipY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s, -- 304
		bowlRimX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s, -- 305
		bowlRimY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s, -- 306
		lampCurX = ox + lx * s, -- 307
		lampCurY = oy + ly * s -- 308
	}} -- 308
end -- 276
local function deriveStage(seqElapsed, active) -- 313
	if not active then -- 314
		return "idle" -- 315
	end -- 315
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 317
		return "porch_knock" -- 318
	end -- 318
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 320
		return "door_open" -- 321
	end -- 321
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 323
		return "book_row1" -- 324
	end -- 324
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 326
		return "pivot_hover" -- 327
	end -- 327
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 329
		return "diverge_action" -- 330
	end -- 330
	return "ending_hold" -- 332
end -- 313
--- 将字符切片数组按进度拼接为前 n 段（避免 Lua 字节切片截断 UTF-8 汉字）
local function joinPrefixTokens(tokens, progress) -- 336
	if progress <= 0 or #tokens == 0 then -- 337
		return "" -- 338
	end -- 338
	local count = math.max( -- 340
		1, -- 340
		math.min( -- 340
			#tokens, -- 340
			math.ceil(progress * #tokens) -- 340
		) -- 340
	) -- 340
	local out = "" -- 341
	local i = 0 -- 342
	do -- 342
		i = 0 -- 343
		while i < count do -- 343
			out = out .. tokens[i + 1] -- 344
			i = i + 1 -- 343
		end -- 343
	end -- 343
	return out -- 346
end -- 336
local ROW1_TOKENS = { -- 349
	"小", -- 349
	"满", -- 349
	"  ", -- 349
	"·", -- 349
	"  ", -- 349
	"已", -- 349
	"收" -- 349
} -- 349
local ROW2_SOLDIER_TOKENS = { -- 350
	"周", -- 350
	"戍", -- 350
	"  ", -- 350
	"·", -- 350
	"  ", -- 350
	"兄", -- 350
	"妹", -- 350
	"同", -- 350
	"行", -- 350
	"  ", -- 350
	"·", -- 350
	"  ", -- 350
	"已", -- 350
	"收" -- 350
} -- 350
local function asRecord(v) -- 352
	if v ~= nil and type(v) == "table" then -- 353
		return v -- 354
	end -- 354
	return nil -- 356
end -- 352
--- 描边椭圆（Dora DrawNode.drawEllipse 仅支持填充，描边用等分折线保证锐利清晰）
local function strokeEllipse(draw, cx, cy, rx, ry, width, color, segments) -- 360
	if segments == nil then -- 368
		segments = 24 -- 368
	end -- 368
	if rx <= 0.5 or ry <= 0.5 or width <= 0.05 then -- 370
		return -- 371
	end -- 371
	local step = math.pi * 2 / segments -- 373
	local prevX = cx + rx -- 374
	local prevY = cy -- 375
	local i = 1 -- 376
	do -- 376
		i = 1 -- 377
		while i <= segments do -- 377
			local ang = i * step -- 378
			local nx = cx + math.cos(ang) * rx -- 379
			local ny = cy + math.sin(ang) * ry -- 380
			draw:drawSegment( -- 381
				Vec2(prevX, prevY), -- 381
				Vec2(nx, ny), -- 381
				width, -- 381
				color -- 381
			) -- 381
			prevX = nx -- 382
			prevY = ny -- 383
			i = i + 1 -- 377
		end -- 377
	end -- 377
end -- 360
local STONE_EDGE_FALLBACK = MING_MATERIALS.mingStoneStep.edge or PALETTE.silkDim -- 387
____exports.TowerEndingsPlugin = __TS__Class() -- 389
local TowerEndingsPlugin = ____exports.TowerEndingsPlugin -- 389
TowerEndingsPlugin.name = "TowerEndingsPlugin" -- 389
function TowerEndingsPlugin.prototype.____constructor(self) -- 389
	self.id = "fe-05-tower-endings" -- 390
	self.active = false -- 392
	self.rehearsalActive = false -- 393
	self.rehearsalRoute = "child" -- 394
	self.activeRoute = "child" -- 395
	self.seqElapsed = 0 -- 397
	self.holdElapsed = 0 -- 398
	self.animTime = 0 -- 399
	self.doorOpened = false -- 402
	self.knockCount = 0 -- 403
	self.replyKnockCount = 0 -- 404
	self.row1Written = false -- 405
	self.row2Written = false -- 406
	self.registryAppendCount = 0 -- 407
	self.staleInputMustRelease = false -- 410
	self.confirmReady = false -- 411
	self.earlyInputBlockedCount = 0 -- 412
	self.rehearsalAcknowledged = false -- 413
	self.lastRoomKey = "" -- 416
	self.indoorRetryCount = 0 -- 418
	self.doorClosedAfterRetry = false -- 419
	self.sessionId = 0 -- 420
	self.lastUiW = 1280 -- 423
	self.lastUiH = 720 -- 424
	self.lastSubtitle = "" -- 425
	self.prevPhase = "" -- 426
	self.loopsActive = false -- 427
end -- 389
function TowerEndingsPlugin.prototype.resolveRoute(self, p, view) -- 430
	if self.rehearsalActive then -- 431
		return self.rehearsalRoute -- 432
	end -- 432
	if view.storyRoute == "soldier" then -- 434
		return "soldier" -- 435
	end -- 435
	if view.storyRoute == "child" then -- 437
		return "child" -- 438
	end -- 438
	local runRec = asRecord(p.run) -- 441
	local ____asRecord_1 = asRecord -- 442
	local ____temp_0 -- 442
	if runRec ~= nil then -- 442
		____temp_0 = runRec.story -- 442
	else -- 442
		____temp_0 = nil -- 442
	end -- 442
	local storyRec = ____asRecord_1(____temp_0) -- 442
	if storyRec ~= nil and storyRec.ending == "reunion" then -- 443
		return "soldier" -- 444
	end -- 444
	return p.childMode and "child" or "soldier" -- 447
end -- 430
function TowerEndingsPlugin.prototype.clearSequenceState(self, keepIndoorDoorOpen) -- 450
	self.active = keepIndoorDoorOpen -- 451
	self.seqElapsed = keepIndoorDoorOpen and ____exports.TOWER_ENDING_TIMINGS.indoorCutSec or 0 -- 452
	self.holdElapsed = 0 -- 453
	self.doorOpened = keepIndoorDoorOpen -- 454
	self.knockCount = keepIndoorDoorOpen and 2 or 0 -- 455
	self.replyKnockCount = keepIndoorDoorOpen and 2 or 0 -- 456
	if not keepIndoorDoorOpen then -- 457
		self.row1Written = false -- 458
		self.row2Written = false -- 459
		self.registryAppendCount = 0 -- 460
	end -- 460
	self.staleInputMustRelease = true -- 462
	self.confirmReady = false -- 463
	self.earlyInputBlockedCount = 0 -- 464
	self.rehearsalAcknowledged = false -- 465
	self.lastSubtitle = "" -- 466
end -- 450
function TowerEndingsPlugin.prototype.startRehearsal(self, route, contract, opts) -- 472
	self.rehearsalActive = true -- 477
	self.rehearsalRoute = route -- 478
	self.activeRoute = route -- 479
	local tag = opts and opts.tag or (route == "child" and "fe05-F03" or "fe05-M03") -- 480
	if contract ~= nil then -- 481
		contract:enterRehearsal(tag) -- 482
		contract:setMockRoute(route) -- 483
	end -- 483
	local isIndoor = (opts and opts.indoorRetry) == true -- 485
	self.sessionId = self.sessionId + 1 -- 486
	self:clearSequenceState(isIndoor) -- 487
	self.active = true -- 488
	self.doorClosedAfterRetry = false -- 489
	if isIndoor then -- 490
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 491
	end -- 491
	if (opts and opts.seekTime) ~= nil then -- 493
		self:seekRehearsal(opts.seekTime) -- 494
	end -- 494
end -- 472
function TowerEndingsPlugin.prototype.seekRehearsal(self, seconds) -- 499
	if not self.rehearsalActive then -- 500
		return -- 501
	end -- 501
	local t = math.max(0, seconds) -- 503
	self.seqElapsed = t -- 504
	self.holdElapsed = math.max(0, t - ____exports.TOWER_ENDING_TIMINGS.divergeEndSec) -- 505
	self.active = true -- 506
	self:syncDerivedMilestones(t, self.activeRoute) -- 507
	self.confirmReady = not self.staleInputMustRelease and t >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 508
end -- 499
function TowerEndingsPlugin.prototype.triggerIndoorRetry(self) -- 512
	if not self.doorOpened and self.seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 513
		self.doorOpened = true -- 514
	end -- 514
	self.indoorRetryCount = self.indoorRetryCount + 1 -- 516
	self.doorClosedAfterRetry = false -- 517
	self.doorOpened = true -- 518
	self.active = true -- 519
	self.seqElapsed = math.max( -- 520
		____exports.TOWER_ENDING_TIMINGS.indoorCutSec, -- 520
		math.min(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.row1StartSec) -- 520
	) -- 520
	self.holdElapsed = 0 -- 521
	self.knockCount = math.max(2, self.knockCount) -- 522
	self.replyKnockCount = math.max(2, self.replyKnockCount) -- 523
	self.staleInputMustRelease = true -- 525
	self.confirmReady = false -- 526
end -- 512
function TowerEndingsPlugin.prototype.stopRehearsal(self, contract) -- 530
	self.rehearsalActive = false -- 531
	self:clearSequenceState(false) -- 532
	self.indoorRetryCount = 0 -- 533
	self.doorClosedAfterRetry = false -- 534
	if contract ~= nil then -- 535
		contract:exitRehearsal() -- 536
	end -- 536
end -- 530
function TowerEndingsPlugin.prototype.getDebugState(self) -- 540
	local route = self.activeRoute -- 541
	local lampProg = route == "child" and smoothstep(5.2, 6.75, self.seqElapsed) or 0 -- 542
	local scaled = computeScaledAnchors(self.lastUiW, self.lastUiH, lampProg) -- 545
	local visualStyle = route == "child" and "lowpoly" or "pixel" -- 546
	local needleOnDesk = route == "soldier" and self.seqElapsed >= 5.55 -- 547
	local twoHandsBowl = route == "soldier" and self.seqElapsed >= 5.95 -- 548
	return { -- 550
		active = self.active, -- 551
		isRehearsal = self.rehearsalActive, -- 552
		route = route, -- 553
		visualStyle = visualStyle, -- 554
		stage = deriveStage(self.seqElapsed, self.active), -- 555
		seqElapsed = self.seqElapsed, -- 556
		holdElapsed = self.holdElapsed, -- 557
		doorOpened = self.doorOpened, -- 558
		knockCount = self.knockCount, -- 559
		replyKnockCount = self.replyKnockCount, -- 560
		row1Written = self.row1Written, -- 561
		row1Name = self.row1Written and "小满" or "", -- 562
		row2Written = self.row2Written, -- 563
		row2Name = self.row2Written and "周戍" or "", -- 564
		row2Blank = not self.row2Written, -- 565
		hasCompletionStamp = false, -- 566
		registryRowCapacity = 2, -- 567
		registryAppendCount = self.registryAppendCount, -- 568
		lampProgress = lampProg, -- 569
		lampAtWestWindow = route == "child" and lampProg >= 0.99, -- 570
		needleCaseOnDesk = needleOnDesk, -- 571
		twoHandsHoldingBowl = twoHandsBowl, -- 572
		staleInputMustRelease = self.staleInputMustRelease, -- 573
		confirmReady = self.confirmReady, -- 574
		earlyInputBlockedCount = self.earlyInputBlockedCount, -- 575
		rehearsalAcknowledged = self.rehearsalAcknowledged, -- 576
		indoorRetryCount = self.indoorRetryCount, -- 577
		doorClosedAfterRetry = self.doorClosedAfterRetry, -- 578
		subtitleText = self.lastSubtitle, -- 579
		anchors = scaled.anchors -- 580
	} -- 580
end -- 540
function TowerEndingsPlugin.prototype.syncRuntimeHook(self) -- 584
	local g = _G -- 585
	local ____temp_8 -- 586
	if g.package ~= nil then -- 586
		____temp_8 = g.package.loaded -- 586
	else -- 586
		____temp_8 = nil -- 586
	end -- 586
	local loaded = ____temp_8 -- 586
	if loaded == nil then -- 587
		return -- 588
	end -- 588
	local rawFe = loaded["watch.fe"] -- 590
	if rawFe ~= nil and type(rawFe) == "table" then -- 591
		local watchFe = rawFe -- 592
		if watchFe.towerEndings ~= self then -- 593
			watchFe.towerEndings = self -- 594
		end -- 594
	end -- 594
end -- 584
function TowerEndingsPlugin.prototype.onBindPlay(self, p, view) -- 601
	self:syncRuntimeHook() -- 602
	self.sessionId = self.sessionId + 1 -- 603
	self.loopsActive = false -- 604
	self.prevPhase = p.phase -- 605
	if self.rehearsalActive then -- 607
		return -- 608
	end -- 608
	local route = self:resolveRoute(p, view) -- 611
	local isTower = p.room.key == "tower" -- 612
	local alreadyCutscenePhase = isTower and (p.phase == "tower-given" or p.phase == "tower-end") -- 613
	local alreadyIndoorPhase = isTower and (p.phase == "tower-enter" or p.phase == "tower-desk" or alreadyCutscenePhase) -- 614
	local sameRunIndoorRetry = isTower and self.lastRoomKey == "tower" and self.doorOpened and p.run == self.lastRunRef and route == self.activeRoute and (p.checkpoint > 0 or alreadyIndoorPhase) -- 619
	self.activeRoute = route -- 626
	self.lastRoomKey = p.room.key -- 627
	self.lastRunRef = p.run -- 628
	if not isTower then -- 630
		self:clearSequenceState(false) -- 631
		self.indoorRetryCount = 0 -- 632
		self.doorClosedAfterRetry = false -- 633
		return -- 634
	end -- 634
	if sameRunIndoorRetry or alreadyCutscenePhase then -- 637
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 639
		self.doorClosedAfterRetry = false -- 640
		self:clearSequenceState(true) -- 641
		if p.phase == "tower-end" then -- 642
			self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.divergeEndSec -- 643
			self:syncDerivedMilestones(self.seqElapsed, route) -- 644
		end -- 644
		return -- 646
	end -- 646
	if p.phase == "tower-enter" or p.phase == "tower-desk" then -- 649
		self:clearSequenceState(false) -- 651
		self.doorOpened = true -- 652
		self.replyKnockCount = 2 -- 653
		self.active = false -- 654
		return -- 655
	end -- 655
	self:clearSequenceState(false) -- 659
	self.indoorRetryCount = 0 -- 660
	self.doorClosedAfterRetry = false -- 661
end -- 601
function TowerEndingsPlugin.prototype.update(self, ctx) -- 664
	self:syncRuntimeHook() -- 665
	self.lastUiW = ctx.uiW -- 666
	self.lastUiH = ctx.uiH -- 667
	local p = ctx.p -- 668
	if not self.rehearsalActive and p.room.key ~= "tower" then -- 670
		if self.loopsActive then -- 671
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 672
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 673
			self.loopsActive = false -- 674
		end -- 674
		self.active = false -- 676
		return -- 677
	end -- 677
	local route = self:resolveRoute(p, ctx.view) -- 680
	self.activeRoute = route -- 681
	if not self.rehearsalActive then -- 683
		self:stepLiveSync(ctx, route) -- 684
	else -- 684
		self:stepRehearsal(ctx, route) -- 686
	end -- 686
	if not self.active then -- 689
		local inInteractiveHall = not self.rehearsalActive and p.room.key == "tower" and (p.phase == "tower-enter" or p.phase == "tower-desk") -- 690
		if self.loopsActive and not inInteractiveHall then -- 692
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 693
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 694
			self.loopsActive = false -- 695
		end -- 695
		return -- 697
	end -- 697
	if not ctx.paused and ctx.worldDt > 0 then -- 701
		self.animTime = self.animTime + ctx.worldDt -- 702
		self:syncDerivedMilestones(self.seqElapsed, route) -- 703
		self:syncAudioCues(ctx.audio, ctx, route) -- 704
		self:stepInputGuard(ctx.input) -- 705
	elseif not ctx.paused then -- 706
		self:syncDerivedMilestones(self.seqElapsed, route) -- 708
		self:stepInputGuard(ctx.input) -- 709
	end -- 709
	self.lastSubtitle = self:composeSubtitle(route) -- 712
end -- 664
function TowerEndingsPlugin.prototype.stepLiveSync(self, ctx, route) -- 715
	local p = ctx.p -- 716
	local phase = p.phase -- 717
	local justEnteredKnock = self.prevPhase ~= "tower-knock" and phase == "tower-knock" -- 718
	local justEnteredEnter = self.prevPhase ~= "tower-enter" and phase == "tower-enter" -- 719
	local justEnteredGiven = self.prevPhase ~= "tower-given" and phase == "tower-given" -- 720
	local justEnteredEnd = self.prevPhase ~= "tower-end" and phase == "tower-end" -- 721
	self.prevPhase = phase -- 722
	if phase == "tower-wait" then -- 724
		self.active = false -- 726
		return -- 727
	end -- 727
	if phase == "tower-enter" or phase == "tower-desk" then -- 730
		self.doorOpened = true -- 732
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 733
		if justEnteredEnter and self.indoorRetryCount == 0 and not ctx.paused then -- 734
			local tick = p.ticks -- 735
			self:playTowerOnce( -- 736
				ctx.audio, -- 736
				"reply1", -- 736
				"sfx", -- 736
				____exports.TOWER_AUDIO_FILES.reply1, -- 736
				0.78, -- 736
				"tower:reply:1", -- 736
				tick -- 736
			) -- 736
			self:playTowerOnce( -- 737
				ctx.audio, -- 737
				"reply2", -- 737
				"sfx", -- 737
				____exports.TOWER_AUDIO_FILES.reply2, -- 737
				0.8, -- 737
				"tower:reply:2", -- 737
				tick -- 737
			) -- 737
			self:playTowerOnce( -- 738
				ctx.audio, -- 738
				"door_open", -- 738
				"sfx", -- 738
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 738
				0.84, -- 738
				"tower:door_open", -- 738
				tick -- 738
			) -- 738
		end -- 738
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.doorOpenSec) -- 740
		self.active = false -- 741
		self:syncDerivedMilestones(self.seqElapsed, route) -- 742
		return -- 743
	end -- 743
	if not self.active then -- 746
		self.active = true -- 747
		self.staleInputMustRelease = ctx.input.interact.held or ctx.input.retry.held or ctx.input.interact.pressed -- 748
		self.confirmReady = false -- 749
	end -- 749
	if justEnteredKnock then -- 752
		self.seqElapsed = p.phaseTick / 60 -- 753
		self.holdElapsed = 0 -- 754
		self.staleInputMustRelease = true -- 755
		self.confirmReady = false -- 756
	elseif justEnteredGiven then -- 757
		self.doorOpened = true -- 758
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 759
	elseif justEnteredEnd then -- 760
		self.doorOpened = true -- 761
		self.seqElapsed = math.max(self.seqElapsed, 3.6) -- 763
	end -- 763
	if not ctx.paused and #ctx.events.rawEvents > 0 then -- 767
		local i = 0 -- 768
		do -- 768
			i = 0 -- 769
			while i < #ctx.events.rawEvents do -- 769
				local ev = ctx.events.rawEvents[i + 1] -- 770
				if ev.name == "knock" then -- 771
					local cnt = type(ev.data.count) == "number" and ev.data.count or self.knockCount + 1 -- 772
					if cnt >= 1 and self.knockCount < 1 then -- 773
						self.knockCount = 1 -- 774
						self:playTowerOnce( -- 775
							ctx.audio, -- 775
							"knock1", -- 775
							"sfx", -- 775
							____exports.TOWER_AUDIO_FILES.knock1, -- 775
							0.88, -- 775
							"tower:knock:1", -- 775
							ev.tick, -- 775
							ev.seq -- 775
						) -- 775
					end -- 775
					if cnt >= 2 and self.knockCount < 2 then -- 777
						self.knockCount = 2 -- 778
						self:playTowerOnce( -- 779
							ctx.audio, -- 779
							"knock2", -- 779
							"sfx", -- 779
							____exports.TOWER_AUDIO_FILES.knock2, -- 779
							0.9, -- 779
							"tower:knock:2", -- 779
							ev.tick, -- 779
							ev.seq -- 779
						) -- 779
					end -- 779
				end -- 779
				i = i + 1 -- 769
			end -- 769
		end -- 769
	end -- 769
	if not ctx.paused and ctx.worldDt > 0 then -- 785
		if phase == "tower-knock" then -- 786
			local backendSec = math.min(____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60) -- 788
			self.seqElapsed = math.max(self.seqElapsed + ctx.worldDt, backendSec) -- 789
			if self.seqElapsed > ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 then -- 790
				self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 -- 791
			end -- 791
		else -- 791
			self.seqElapsed = self.seqElapsed + ctx.worldDt -- 794
			if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 795
				self.holdElapsed = self.holdElapsed + ctx.worldDt -- 796
			end -- 796
		end -- 796
	end -- 796
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 801
		self.doorClosedAfterRetry = true -- 802
	end -- 802
	self:syncDerivedMilestones(self.seqElapsed, route) -- 804
end -- 715
function TowerEndingsPlugin.prototype.stepRehearsal(self, ctx, route) -- 807
	self.active = true -- 808
	if not ctx.paused and ctx.worldDt > 0 then -- 809
		self.seqElapsed = self.seqElapsed + ctx.worldDt -- 810
		if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 811
			self.holdElapsed = self.holdElapsed + ctx.worldDt -- 812
		end -- 812
	end -- 812
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 815
		self.doorClosedAfterRetry = true -- 816
	end -- 816
	self:syncDerivedMilestones(self.seqElapsed, route) -- 818
end -- 807
function TowerEndingsPlugin.prototype.syncDerivedMilestones(self, t, route) -- 821
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec and self.knockCount < 1 then -- 822
		self.knockCount = 1 -- 823
	end -- 823
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec and self.knockCount < 2 then -- 825
		self.knockCount = 2 -- 826
	end -- 826
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec and self.replyKnockCount < 1 then -- 828
		self.replyKnockCount = 1 -- 829
	end -- 829
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec and self.replyKnockCount < 2 then -- 831
		self.replyKnockCount = 2 -- 832
	end -- 832
	if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 834
		self.doorOpened = true -- 835
	end -- 835
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec and not self.row1Written then -- 838
		self.row1Written = true -- 839
		self.registryAppendCount = self.registryAppendCount + 1 -- 840
	end -- 840
	if route == "soldier" and t >= 4.6 and not self.row2Written then -- 842
		self.row2Written = true -- 843
		self.registryAppendCount = self.registryAppendCount + 1 -- 844
	end -- 844
	if route == "child" and self.row2Written then -- 846
		self.row2Written = false -- 848
		self.registryAppendCount = self.row1Written and 1 or 0 -- 849
	end -- 849
end -- 821
function TowerEndingsPlugin.prototype.stepInputGuard(self, input) -- 853
	local keyHeld = input.interact.held or input.retry.held -- 854
	local keyPressed = input.interact.pressed or input.retry.pressed -- 855
	local readyTime = self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 856
	if self.staleInputMustRelease then -- 858
		if not keyHeld then -- 859
			self.staleInputMustRelease = false -- 860
		elseif keyPressed then -- 861
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 862
		end -- 862
		self.confirmReady = false -- 864
		return -- 865
	end -- 865
	if not readyTime then -- 868
		if keyPressed then -- 869
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 870
			self.staleInputMustRelease = keyHeld -- 871
		end -- 871
		self.confirmReady = false -- 873
		return -- 874
	end -- 874
	self.confirmReady = true -- 877
	if self.rehearsalActive and keyPressed then -- 878
		self.rehearsalAcknowledged = true -- 879
	end -- 879
end -- 853
function TowerEndingsPlugin.prototype.playTowerOnce(self, audio, tag, track, path, volume, cueId, tick, seq) -- 883
	if seq == nil then -- 891
		seq = -1 -- 891
	end -- 891
	local dedupeKey = (("tower:s" .. tostring(self.sessionId)) .. ":") .. tag -- 893
	audio:playOnce( -- 894
		dedupeKey, -- 894
		track, -- 894
		path, -- 894
		volume, -- 894
		cueId, -- 894
		tick, -- 894
		seq -- 894
	) -- 894
end -- 883
function TowerEndingsPlugin.prototype.syncAudioCues(self, audio, ctx, route) -- 897
	local t = self.seqElapsed -- 898
	local tick = ctx.p.ticks -- 899
	local indoorK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.5, t) -- 900
	self.loopsActive = true -- 903
	audio:playLoop( -- 904
		"tower_wind_cold", -- 904
		"wind", -- 904
		____exports.TOWER_AUDIO_FILES.windCold, -- 904
		lerp(0.36, 0.14, indoorK), -- 904
		tick -- 904
	) -- 904
	if indoorK > 0.05 then -- 905
		audio:playLoop( -- 906
			"tower_room_warm", -- 906
			"ambience", -- 906
			____exports.TOWER_AUDIO_FILES.roomWarm, -- 906
			lerp(0.06, 0.34, indoorK), -- 906
			tick -- 906
		) -- 906
	end -- 906
	if self.indoorRetryCount == 0 then -- 910
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec then -- 911
			self:playTowerOnce( -- 912
				audio, -- 912
				"knock1", -- 912
				"sfx", -- 912
				____exports.TOWER_AUDIO_FILES.knock1, -- 912
				0.88, -- 912
				"tower:knock:1", -- 912
				tick -- 912
			) -- 912
		end -- 912
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec then -- 914
			self:playTowerOnce( -- 915
				audio, -- 915
				"knock2", -- 915
				"sfx", -- 915
				____exports.TOWER_AUDIO_FILES.knock2, -- 915
				0.9, -- 915
				"tower:knock:2", -- 915
				tick -- 915
			) -- 915
		end -- 915
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 917
			self:playTowerOnce( -- 918
				audio, -- 918
				"reply1", -- 918
				"sfx", -- 918
				____exports.TOWER_AUDIO_FILES.reply1, -- 918
				0.78, -- 918
				"tower:reply:1", -- 918
				tick -- 918
			) -- 918
		end -- 918
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec then -- 920
			self:playTowerOnce( -- 921
				audio, -- 921
				"reply2", -- 921
				"sfx", -- 921
				____exports.TOWER_AUDIO_FILES.reply2, -- 921
				0.8, -- 921
				"tower:reply:2", -- 921
				tick -- 921
			) -- 921
		end -- 921
		if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 923
			self:playTowerOnce( -- 924
				audio, -- 924
				"door_open", -- 924
				"sfx", -- 924
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 924
				0.84, -- 924
				"tower:door_open", -- 924
				tick -- 924
			) -- 924
		end -- 924
	end -- 924
	if t >= 1.5 then -- 928
		self:playTowerOnce( -- 929
			audio, -- 929
			"book_open", -- 929
			"sfx", -- 929
			____exports.TOWER_AUDIO_FILES.bookOpen, -- 929
			0.82, -- 929
			"tower:book_open", -- 929
			tick -- 929
		) -- 929
	end -- 929
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 931
		self:playTowerOnce( -- 932
			audio, -- 932
			"brush1", -- 932
			"sfx", -- 932
			____exports.TOWER_AUDIO_FILES.brush1, -- 932
			0.8, -- 932
			"tower:brush:row1", -- 932
			tick -- 932
		) -- 932
	end -- 932
	if route == "child" then -- 935
		if t >= 4.35 then -- 936
			self:playTowerOnce( -- 937
				audio, -- 937
				"f03_line", -- 937
				"voice", -- 937
				____exports.TOWER_AUDIO_FILES.lineXiaomanLamp, -- 937
				0.86, -- 937
				"tower:f03:line_lamp", -- 937
				tick -- 937
			) -- 937
		end -- 937
		if t >= 4.45 then -- 939
			self:playTowerOnce( -- 940
				audio, -- 940
				"f03_bowl", -- 940
				"sfx", -- 940
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 940
				0.8, -- 940
				"tower:bowl_set", -- 940
				tick -- 940
			) -- 940
		end -- 940
		if t >= 5.2 then -- 942
			self:playTowerOnce( -- 943
				audio, -- 943
				"f03_lamp", -- 943
				"sfx", -- 943
				____exports.TOWER_AUDIO_FILES.lampMove, -- 943
				0.82, -- 943
				"tower:f03:lamp_move", -- 943
				tick -- 943
			) -- 943
		end -- 943
	else -- 943
		if t >= 4.28 then -- 946
			self:playTowerOnce( -- 947
				audio, -- 947
				"m03_line", -- 947
				"voice", -- 947
				____exports.TOWER_AUDIO_FILES.lineZhoushuName, -- 947
				0.9, -- 947
				"tower:m03:line_name", -- 947
				tick -- 947
			) -- 947
		end -- 947
		if t >= 4.62 then -- 949
			self:playTowerOnce( -- 950
				audio, -- 950
				"brush2", -- 950
				"sfx", -- 950
				____exports.TOWER_AUDIO_FILES.brush2, -- 950
				0.82, -- 950
				"tower:brush:row2", -- 950
				tick -- 950
			) -- 950
		end -- 950
		if t >= 5.55 then -- 952
			self:playTowerOnce( -- 953
				audio, -- 953
				"m03_needle", -- 953
				"sfx", -- 953
				____exports.TOWER_AUDIO_FILES.needlePlace, -- 953
				0.8, -- 953
				"tower:m03:needle_place", -- 953
				tick -- 953
			) -- 953
		end -- 953
		if t >= 6.02 then -- 955
			self:playTowerOnce( -- 956
				audio, -- 956
				"m03_bowl", -- 956
				"sfx", -- 956
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 956
				0.82, -- 956
				"tower:bowl_set", -- 956
				tick -- 956
			) -- 956
		end -- 956
	end -- 956
end -- 897
function TowerEndingsPlugin.prototype.composeSubtitle(self, route) -- 961
	local t = self.seqElapsed -- 962
	if t < ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 963
		return "[两下轻敲]  门外厚木上传来两声轻敲。" -- 964
	end -- 964
	if t < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 966
		return "[门内回敲]  静默一息，门后轻轻回敲两声。" -- 967
	end -- 967
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 969
		return route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 970
	end -- 970
	if t < ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 974
		return route == "child" and "她把针套与纸条摊在案前，守卒展开收籍末页。" or "两人站在值夜室内，守卒摊开收籍末页。" -- 975
	end -- 975
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 979
		return "守卒蘸墨提笔，在第一行写下「小满」。" -- 980
	end -- 980
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 982
		return "笔尖停在第二行上方。" -- 983
	end -- 983
	if route == "child" then -- 985
		if t < 6.7 then -- 986
			return F03_DIALOGUE -- 987
		end -- 987
		return "" -- 989
	end -- 989
	if t < 5.45 then -- 991
		return M03_DIALOGUE -- 992
	end -- 992
	if t < 6.85 then -- 994
		return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。" -- 995
	end -- 995
	return "" -- 997
end -- 961
function TowerEndingsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1002
	if not self.active then -- 1009
		return false -- 1010
	end -- 1010
	local route = self.activeRoute -- 1013
	local t = self.seqElapsed -- 1014
	local lampProg = route == "child" and smoothstep(5.2, 6.75, t) or 0 -- 1015
	local scaled = computeScaledAnchors(ctx.uiW, ctx.uiH, lampProg) -- 1016
	local s = scaled.s -- 1017
	local ox = scaled.ox -- 1018
	local oy = scaled.oy -- 1019
	uiDraw:drawRect( -- 1022
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1022
		Color(8, 10, 16, 255) -- 1022
	) -- 1022
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1024
		self:drawAct1PorchAndDoor( -- 1026
			uiDraw, -- 1026
			uiInkDraw, -- 1026
			uiArt, -- 1026
			uiGlow, -- 1026
			ctx, -- 1026
			route, -- 1026
			s, -- 1026
			ox, -- 1026
			oy -- 1026
		) -- 1026
		local fadeOut = smoothstep(1.22, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec, t) -- 1028
		if fadeOut > 0.01 then -- 1029
			uiInkDraw:drawRect( -- 1030
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1030
				Color( -- 1030
					8, -- 1030
					10, -- 1030
					16, -- 1030
					math.floor(230 * fadeOut + 0.5) -- 1030
				) -- 1030
			) -- 1030
		end -- 1030
	else -- 1030
		self:drawAct2And3Guardroom( -- 1034
			uiDraw, -- 1034
			uiInkDraw, -- 1034
			uiArt, -- 1034
			uiGlow, -- 1034
			ctx, -- 1034
			route, -- 1034
			lampProg, -- 1034
			s, -- 1034
			ox, -- 1034
			oy -- 1034
		) -- 1034
		local fadeIn = 1 - smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.24, t) -- 1035
		if fadeIn > 0.01 then -- 1036
			uiInkDraw:drawRect( -- 1037
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1037
				Color( -- 1037
					8, -- 1037
					10, -- 1037
					16, -- 1037
					math.floor(220 * fadeIn + 0.5) -- 1037
				) -- 1037
			) -- 1037
		end -- 1037
	end -- 1037
	local barH = math.floor(____exports.TOWER_SHOT_LAYOUT.letterboxH * s + 0.5) -- 1042
	uiInkDraw:drawRect( -- 1043
		Rect(0, ctx.uiH - barH, ctx.uiW, barH), -- 1043
		Color(7, 9, 14, 248) -- 1043
	) -- 1043
	uiInkDraw:drawRect( -- 1044
		Rect(0, 0, ctx.uiW, barH), -- 1044
		Color(7, 9, 14, 248) -- 1044
	) -- 1044
	uiInkDraw:drawSegment( -- 1045
		Vec2(0, ctx.uiH - barH), -- 1045
		Vec2(ctx.uiW, ctx.uiH - barH), -- 1045
		0.9, -- 1045
		toColor(PALETTE.silkDim, 82) -- 1045
	) -- 1045
	uiInkDraw:drawSegment( -- 1046
		Vec2(0, barH), -- 1046
		Vec2(ctx.uiW, barH), -- 1046
		0.9, -- 1046
		toColor(PALETTE.silkDim, 82) -- 1046
	) -- 1046
	self:drawDialogueSubtitle( -- 1049
		uiDraw, -- 1049
		uiInkDraw, -- 1049
		uiArt, -- 1049
		ctx, -- 1049
		route, -- 1049
		s, -- 1049
		barH -- 1049
	) -- 1049
	return true -- 1051
end -- 1002
function TowerEndingsPlugin.prototype.drawAct1PorchAndDoor(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1056
	local t = self.seqElapsed -- 1067
	local isLowpoly = route == "child" -- 1068
	local openK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, 1.24, t) -- 1069
	local doorCx = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s -- 1070
	local threshY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s -- 1071
	local doorW = ____exports.TOWER_SHOT_LAYOUT.doorW * s -- 1072
	local doorH = ____exports.TOWER_SHOT_LAYOUT.doorH * s -- 1073
	local doorL = doorCx - doorW * 0.5 -- 1074
	local doorR = doorCx + doorW * 0.5 -- 1075
	local k1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock1Sec) / 0.055) ^ 2) -- 1078
	local k2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock2Sec) / 0.055) ^ 2) -- 1079
	local r1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply1Sec) / 0.06) ^ 2) -- 1080
	local r2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply2Sec) / 0.06) ^ 2) -- 1081
	local doorShakeX = (k1Pulse + k2Pulse) * 2.4 * s * math.sin(t * 95) + (r1Pulse + r2Pulse) * 1.4 * s * math.sin(t * 80) -- 1082
	if isLowpoly then -- 1085
		local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, openK * 0.62) -- 1087
		fillVGradRect( -- 1088
			uiDraw, -- 1089
			0, -- 1089
			0, -- 1089
			ctx.uiW, -- 1089
			ctx.uiH, -- 1089
			Color(12, 16, 26, 255), -- 1090
			Color(20, 28, 44, 255) -- 1091
		) -- 1091
		local wallCol = shadeSurface( -- 1094
			MING_MATERIALS.mingBrickDark.base, -- 1094
			vec3(0, 0, -1), -- 1094
			24, -- 1094
			1, -- 1094
			light, -- 1094
			MING_MATERIALS.mingBrickDark -- 1094
		) -- 1094
		local jambCol = shadeSurface( -- 1095
			MING_MATERIALS.mingBrick.base, -- 1095
			vec3(0.75, 0.15, -0.64), -- 1095
			10, -- 1095
			1, -- 1095
			light, -- 1095
			MING_MATERIALS.mingBrick -- 1095
		) -- 1095
		local jambRCol = shadeSurface( -- 1096
			MING_MATERIALS.mingBrick.base, -- 1096
			vec3(-0.75, 0.15, -0.64), -- 1096
			10, -- 1096
			1, -- 1096
			light, -- 1096
			MING_MATERIALS.mingBrick -- 1096
		) -- 1096
		local lintelCol = shadeSurface( -- 1097
			MING_MATERIALS.mingStoneStep.base, -- 1097
			vec3(0, -0.55, -0.83), -- 1097
			6, -- 1097
			1, -- 1097
			light, -- 1097
			MING_MATERIALS.mingStoneStep -- 1097
		) -- 1097
		local stepCol = shadeSurface( -- 1098
			MING_MATERIALS.mingStoneStep.base, -- 1098
			vec3(0, 0.92, -0.39), -- 1098
			0, -- 1098
			1, -- 1098
			light, -- 1098
			MING_MATERIALS.mingStoneStep -- 1098
		) -- 1098
		uiDraw:drawRect( -- 1100
			Rect(0, threshY, doorL - 26 * s, ctx.uiH - threshY), -- 1100
			toColor(wallCol) -- 1100
		) -- 1100
		uiDraw:drawRect( -- 1101
			Rect(doorR + 26 * s, threshY, ctx.uiW - (doorR + 26 * s), ctx.uiH - threshY), -- 1101
			toColor(wallCol) -- 1101
		) -- 1101
		uiDraw:drawPolygon( -- 1103
			{ -- 1103
				Vec2(doorL - 26 * s, threshY), -- 1104
				Vec2(doorL, threshY + 12 * s), -- 1105
				Vec2(doorL, threshY + doorH - 8 * s), -- 1106
				Vec2(doorL - 26 * s, threshY + doorH + 18 * s) -- 1107
			}, -- 1107
			toColor(jambCol), -- 1108
			1, -- 1108
			toColor(PALETTE.silkDim, 68) -- 1108
		) -- 1108
		uiDraw:drawPolygon( -- 1109
			{ -- 1109
				Vec2(doorR + 26 * s, threshY), -- 1110
				Vec2(doorR, threshY + 12 * s), -- 1111
				Vec2(doorR, threshY + doorH - 8 * s), -- 1112
				Vec2(doorR + 26 * s, threshY + doorH + 18 * s) -- 1113
			}, -- 1113
			toColor(jambRCol), -- 1114
			1, -- 1114
			toColor(PALETTE.silkDim, 68) -- 1114
		) -- 1114
		uiDraw:drawPolygon( -- 1116
			{ -- 1116
				Vec2(doorL - 44 * s, threshY + doorH + 18 * s), -- 1117
				Vec2(doorR + 44 * s, threshY + doorH + 18 * s), -- 1118
				Vec2(doorR + 58 * s, threshY + doorH + 92 * s), -- 1119
				Vec2(doorL - 58 * s, threshY + doorH + 92 * s) -- 1120
			}, -- 1120
			toColor(lintelCol), -- 1121
			1.1, -- 1121
			toColor(STONE_EDGE_FALLBACK, 130) -- 1121
		) -- 1121
		uiDraw:drawRect( -- 1123
			Rect(0, 0, ctx.uiW, threshY), -- 1123
			Color(16, 20, 30, 255) -- 1123
		) -- 1123
		uiDraw:drawPolygon( -- 1124
			{ -- 1124
				Vec2(doorL - 58 * s, threshY - 20 * s), -- 1125
				Vec2(doorR + 58 * s, threshY - 20 * s), -- 1126
				Vec2(doorR + 28 * s, threshY + 12 * s), -- 1127
				Vec2(doorL - 28 * s, threshY + 12 * s) -- 1128
			}, -- 1128
			toColor(stepCol), -- 1129
			1, -- 1129
			toColor(STONE_EDGE_FALLBACK, 150) -- 1129
		) -- 1129
		uiDraw:drawPolygon( -- 1131
			{ -- 1131
				Vec2(0, 0), -- 1132
				Vec2(142 * s, 0), -- 1133
				Vec2(114 * s, ctx.uiH), -- 1134
				Vec2(0, ctx.uiH) -- 1135
			}, -- 1135
			Color(10, 14, 22, 220) -- 1136
		) -- 1136
		uiDraw:drawPolygon( -- 1137
			{ -- 1137
				Vec2(ctx.uiW - 142 * s, 0), -- 1138
				Vec2(ctx.uiW, 0), -- 1139
				Vec2(ctx.uiW, ctx.uiH), -- 1140
				Vec2(ctx.uiW - 114 * s, ctx.uiH) -- 1141
			}, -- 1141
			Color(10, 14, 22, 220) -- 1142
		) -- 1142
	else -- 1142
		fillVGradRect( -- 1145
			uiDraw, -- 1146
			0, -- 1146
			0, -- 1146
			ctx.uiW, -- 1146
			ctx.uiH, -- 1146
			Color(18, 22, 32, 255), -- 1147
			Color(32, 38, 52, 255) -- 1148
		) -- 1148
		uiDraw:drawPolygon( -- 1151
			{ -- 1151
				Vec2(0, threshY), -- 1152
				Vec2(doorL, threshY), -- 1153
				Vec2(doorL, threshY + 188 * s), -- 1154
				Vec2(doorL * 0.55, threshY + 230 * s), -- 1155
				Vec2(doorL * 0.22, threshY + 172 * s), -- 1156
				Vec2(0, threshY + 196 * s) -- 1157
			}, -- 1157
			Color(26, 30, 40, 235) -- 1158
		) -- 1158
		uiDraw:drawPolygon( -- 1159
			{ -- 1159
				Vec2(doorR, threshY), -- 1160
				Vec2(ctx.uiW, threshY), -- 1161
				Vec2(ctx.uiW, threshY + 218 * s), -- 1162
				Vec2(doorR + (ctx.uiW - doorR) * 0.56, threshY + 248 * s), -- 1163
				Vec2(doorR, threshY + 178 * s) -- 1164
			}, -- 1164
			Color(26, 30, 40, 235) -- 1165
		) -- 1165
		uiDraw:drawRect( -- 1167
			Rect(0, threshY, doorL, ctx.uiH - threshY), -- 1167
			Color(54, 56, 62, 255), -- 1167
			1, -- 1167
			Color(88, 90, 96, 155) -- 1167
		) -- 1167
		uiDraw:drawRect( -- 1168
			Rect(doorR, threshY, ctx.uiW - doorR, ctx.uiH - threshY), -- 1168
			Color(54, 56, 62, 255), -- 1168
			1, -- 1168
			Color(88, 90, 96, 155) -- 1168
		) -- 1168
		uiDraw:drawRect( -- 1169
			Rect(doorL - 28 * s, threshY + doorH, doorW + 56 * s, 68 * s), -- 1169
			Color(72, 68, 62, 255), -- 1169
			1, -- 1169
			Color(124, 114, 100, 175) -- 1169
		) -- 1169
		local row = 0 -- 1170
		do -- 1170
			row = 0 -- 1171
			while row < 10 do -- 1171
				local by = threshY + row * 46 * s -- 1172
				uiDraw:drawSegment( -- 1173
					Vec2(0, by), -- 1173
					Vec2(doorL, by), -- 1173
					1, -- 1173
					Color(34, 36, 42, 175) -- 1173
				) -- 1173
				uiDraw:drawSegment( -- 1174
					Vec2(doorR, by), -- 1174
					Vec2(ctx.uiW, by), -- 1174
					1, -- 1174
					Color(34, 36, 42, 175) -- 1174
				) -- 1174
				local stag = row % 2 * 34 * s -- 1175
				local col = 0 -- 1176
				do -- 1176
					col = 0 -- 1177
					while col < 7 do -- 1177
						local lx = stag + col * 68 * s -- 1178
						if lx > 4 * s and lx < doorL - 4 * s then -- 1179
							uiDraw:drawSegment( -- 1180
								Vec2(lx, by), -- 1180
								Vec2(lx, by + 46 * s), -- 1180
								0.9, -- 1180
								Color(36, 38, 44, 130) -- 1180
							) -- 1180
						end -- 1180
						local rx = doorR + stag + col * 68 * s -- 1182
						if rx > doorR + 4 * s and rx < ctx.uiW - 4 * s then -- 1183
							uiDraw:drawSegment( -- 1184
								Vec2(rx, by), -- 1184
								Vec2(rx, by + 46 * s), -- 1184
								0.9, -- 1184
								Color(36, 38, 44, 130) -- 1184
							) -- 1184
						end -- 1184
						col = col + 1 -- 1177
					end -- 1177
				end -- 1177
				row = row + 1 -- 1171
			end -- 1171
		end -- 1171
		uiDraw:drawRect( -- 1189
			Rect(0, 0, ctx.uiW, threshY), -- 1189
			Color(28, 26, 28, 255) -- 1189
		) -- 1189
		uiDraw:drawRect( -- 1190
			Rect(doorL - 36 * s, threshY - 12 * s, doorW + 72 * s, 22 * s), -- 1190
			Color(96, 94, 92, 255), -- 1190
			1, -- 1190
			Color(156, 152, 144, 175) -- 1190
		) -- 1190
	end -- 1190
	local innerWarm = 0.22 + openK * 0.78 + (r1Pulse + r2Pulse) * 0.14 -- 1194
	fillVGradRect( -- 1195
		uiDraw, -- 1196
		doorL, -- 1196
		threshY + 8 * s, -- 1196
		doorW, -- 1196
		doorH - 8 * s, -- 1196
		Color( -- 1197
			46, -- 1197
			32, -- 1197
			20, -- 1197
			math.floor(255 * math.min(1, innerWarm + 0.15) + 0.5) -- 1197
		), -- 1197
		Color( -- 1198
			118, -- 1198
			82, -- 1198
			42, -- 1198
			math.floor(255 * math.min(1, innerWarm) + 0.5) -- 1198
		) -- 1198
	) -- 1198
	local leafW = math.max(26 * s, doorW * (1 - openK * 0.76)) -- 1202
	local leafX = doorL + doorShakeX * (1 - openK) -- 1203
	local woodCol = isLowpoly and toColor(shadeSurface( -- 1204
		MING_MATERIALS.mingTimberDark.base, -- 1205
		vec3(-0.2, 0.25, -0.95), -- 1205
		4, -- 1205
		1, -- 1205
		TOWER_WEST_LAMP_LIGHT, -- 1205
		MING_MATERIALS.mingTimberDark -- 1205
	)) or Color(76, 54, 38, 255) -- 1206
	uiDraw:drawRect( -- 1207
		Rect(leafX, threshY + 12 * s, leafW, doorH - 14 * s), -- 1208
		woodCol, -- 1209
		1.4, -- 1210
		Color(138, 106, 74, 185) -- 1211
	) -- 1211
	local planks = 4 -- 1214
	local pi = 1 -- 1215
	do -- 1215
		pi = 1 -- 1216
		while pi < planks do -- 1216
			local px = leafX + leafW * pi / planks -- 1217
			uiDraw:drawSegment( -- 1218
				Vec2(px, threshY + 14 * s), -- 1218
				Vec2(px, threshY + doorH - 4 * s), -- 1218
				1.1, -- 1218
				Color(38, 26, 18, 185) -- 1218
			) -- 1218
			pi = pi + 1 -- 1216
		end -- 1216
	end -- 1216
	uiDraw:drawRect( -- 1220
		Rect(leafX + 4 * s, threshY + doorH * 0.24, leafW - 8 * s, 10 * s), -- 1220
		Color(54, 38, 26, 225) -- 1220
	) -- 1220
	uiDraw:drawRect( -- 1221
		Rect(leafX + 4 * s, threshY + doorH * 0.74, leafW - 8 * s, 10 * s), -- 1221
		Color(54, 38, 26, 225) -- 1221
	) -- 1221
	local ringX = leafX + leafW * 0.72 -- 1223
	local ringY = threshY + doorH * 0.56 -- 1224
	uiDraw:drawRect( -- 1225
		Rect(ringX - 6 * s, ringY + 4 * s, 12 * s, 12 * s), -- 1225
		Color(42, 46, 52, 235), -- 1225
		1, -- 1225
		Color(96, 100, 108, 170) -- 1225
	) -- 1225
	strokeEllipse( -- 1226
		uiDraw, -- 1226
		ringX, -- 1226
		ringY - 2 * s, -- 1226
		8 * s, -- 1226
		9 * s, -- 1226
		1.8 * s, -- 1226
		Color(108, 112, 118, 195), -- 1226
		16 -- 1226
	) -- 1226
	local seamGlowA = math.floor(92 + openK * 145 + (r1Pulse + r2Pulse) * 48 + 0.5) -- 1229
	fillRadialGlow( -- 1230
		uiGlow, -- 1231
		doorCx + openK * 24 * s, -- 1231
		threshY + 14 * s, -- 1231
		(92 + openK * 120) * s, -- 1232
		(26 + openK * 58) * s, -- 1232
		Color( -- 1233
			246, -- 1233
			204, -- 1233
			134, -- 1233
			math.min(220, seamGlowA) -- 1233
		), -- 1233
		Color(220, 156, 72, 0), -- 1234
		18 -- 1235
	) -- 1235
	local kx = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s -- 1239
	local ky = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s -- 1240
	if k1Pulse > 0.08 or k2Pulse > 0.08 then -- 1241
		local amp = math.max(k1Pulse, k2Pulse) -- 1242
		local r = (18 + (1 - amp) * 34) * s -- 1243
		strokeEllipse( -- 1244
			uiInkDraw, -- 1244
			kx + 24 * s, -- 1244
			ky, -- 1244
			r, -- 1244
			r * 0.85, -- 1244
			1.8 * s, -- 1244
			toColor( -- 1244
				PALETTE.amberCore, -- 1244
				math.floor(210 * amp + 0.5) -- 1244
			), -- 1244
			24 -- 1244
		) -- 1244
	end -- 1244
	if r1Pulse > 0.08 or r2Pulse > 0.08 then -- 1246
		local amp = math.max(r1Pulse, r2Pulse) -- 1247
		local r = (24 + (1 - amp) * 42) * s -- 1248
		strokeEllipse( -- 1249
			uiInkDraw, -- 1249
			doorCx + 30 * s, -- 1249
			ky + 16 * s, -- 1249
			r, -- 1249
			r * 0.9, -- 1249
			1.6 * s, -- 1249
			toColor( -- 1249
				PALETTE.amber, -- 1249
				math.floor(185 * amp + 0.5) -- 1249
			), -- 1249
			24 -- 1249
		) -- 1249
	end -- 1249
	if openK > 0.05 then -- 1253
		local lanX = ox + ____exports.TOWER_SHOT_LAYOUT.doorLanternX * s + (1 - openK) * 42 * s -- 1254
		local lanY = oy + ____exports.TOWER_SHOT_LAYOUT.doorLanternY * s -- 1255
		uiInkDraw:drawPolygon( -- 1257
			{ -- 1257
				Vec2(lanX + 76 * s, lanY + 42 * s), -- 1258
				Vec2(lanX + 12 * s, lanY + 34 * s), -- 1259
				Vec2(lanX + 8 * s, lanY + 12 * s), -- 1260
				Vec2(lanX + 78 * s, lanY + 12 * s) -- 1261
			}, -- 1261
			Color( -- 1262
				54, -- 1262
				48, -- 1262
				44, -- 1262
				math.floor(240 * openK + 0.5) -- 1262
			), -- 1262
			1, -- 1262
			Color( -- 1262
				98, -- 1262
				86, -- 1262
				74, -- 1262
				math.floor(180 * openK + 0.5) -- 1262
			) -- 1262
		) -- 1262
		self:drawMingLantern( -- 1263
			uiInkDraw, -- 1263
			uiGlow, -- 1263
			lanX, -- 1263
			lanY - 14 * s, -- 1263
			1.08 * s, -- 1263
			openK, -- 1263
			1 -- 1263
		) -- 1263
		fillRadialGlow( -- 1265
			uiGlow, -- 1266
			kx + 12 * s, -- 1266
			ky - 14 * s, -- 1266
			148 * s, -- 1267
			128 * s, -- 1267
			Color( -- 1268
				246, -- 1268
				208, -- 1268
				142, -- 1268
				math.floor(98 * openK + 0.5) -- 1268
			), -- 1268
			Color(232, 174, 92, 0), -- 1269
			18 -- 1270
		) -- 1270
	end -- 1270
	local stepInX = openK * 44 * s -- 1275
	local xiaomanX = doorCx - 66 * s + stepInX -- 1276
	local xiaomanY = threshY - 2 * s -- 1277
	uiDraw:drawEllipse( -- 1279
		Vec2(xiaomanX, xiaomanY + 2 * s), -- 1279
		34 * s, -- 1279
		8 * s, -- 1279
		Color(4, 6, 12, 190) -- 1279
	) -- 1279
	local childSlot = (k1Pulse > 0.25 or k2Pulse > 0.25) and "child_knock" or (openK > 0.45 and "child_offer" or "child_idle") -- 1280
	uiArt:tryPlace( -- 1281
		childSlot, -- 1281
		"fe05_porch_child", -- 1281
		xiaomanX, -- 1281
		xiaomanY, -- 1281
		108 * s, -- 1281
		148 * s, -- 1281
		{facing = 1, opacity = 0.98, layer = 2} -- 1281
	) -- 1281
	if openK > 0.15 then -- 1285
		local wristX = xiaomanX + 22 * s -- 1286
		local wristY = xiaomanY + 76 * s -- 1287
		uiInkDraw:drawRect( -- 1288
			Rect(wristX - 7 * s, wristY - 5 * s, 14 * s, 11 * s), -- 1289
			Color( -- 1290
				142, -- 1290
				118, -- 1290
				84, -- 1290
				math.floor(245 * openK + 0.5) -- 1290
			), -- 1290
			1, -- 1291
			Color( -- 1292
				222, -- 1292
				192, -- 1292
				128, -- 1292
				math.floor(235 * openK + 0.5) -- 1292
			) -- 1292
		) -- 1292
		uiInkDraw:drawSegment( -- 1294
			Vec2(wristX - 8 * s, wristY), -- 1295
			Vec2(wristX + 8 * s, wristY + 2 * s), -- 1296
			2 * s, -- 1297
			toColor( -- 1298
				CUFF_PALETTE.childCord, -- 1298
				math.floor(240 * openK + 0.5) -- 1298
			) -- 1298
		) -- 1298
	end -- 1298
	if route == "soldier" then -- 1302
		local zhouX = xiaomanX - 72 * s -- 1304
		local zhouY = threshY - 2 * s -- 1305
		uiDraw:drawEllipse( -- 1306
			Vec2(zhouX, zhouY + 2 * s), -- 1306
			42 * s, -- 1306
			9 * s, -- 1306
			Color(4, 6, 12, 190) -- 1306
		) -- 1306
		uiArt:tryPlace( -- 1307
			"soldier_idle", -- 1307
			"fe05_porch_soldier", -- 1307
			zhouX, -- 1307
			zhouY, -- 1307
			146 * s, -- 1307
			206 * s, -- 1307
			{facing = 1, opacity = 0.98, layer = 2} -- 1307
		) -- 1307
		local handMidX = (zhouX + xiaomanX) * 0.5 + 4 * s -- 1311
		local handMidY = threshY + 66 * s -- 1312
		uiInkDraw:drawSegment( -- 1313
			Vec2(zhouX + 20 * s, threshY + 106 * s), -- 1314
			Vec2(handMidX - 2 * s, handMidY), -- 1315
			6.2 * s, -- 1316
			toColor(CUFF_PALETTE.indigoBase, 245) -- 1317
		) -- 1317
		uiInkDraw:drawSegment( -- 1319
			Vec2(handMidX - 9 * s, handMidY + 9 * s), -- 1320
			Vec2(handMidX - 3 * s, handMidY + 13 * s), -- 1321
			1.9 * s, -- 1322
			toColor(CUFF_PALETTE.stitchThread, 240) -- 1323
		) -- 1323
		uiInkDraw:drawSegment( -- 1325
			Vec2(xiaomanX - 14 * s, threshY + 78 * s), -- 1326
			Vec2(handMidX + 2 * s, handMidY), -- 1327
			4.8 * s, -- 1328
			toColor(CUFF_PALETTE.childSleeve, 245) -- 1329
		) -- 1329
		uiInkDraw:drawDot( -- 1331
			Vec2(handMidX, handMidY), -- 1331
			4.8 * s, -- 1331
			toColor(CUFF_PALETTE.skinLight, 245) -- 1331
		) -- 1331
	end -- 1331
end -- 1056
function TowerEndingsPlugin.prototype.drawAct2And3Guardroom(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy) -- 1337
	local t = self.seqElapsed -- 1349
	local isLowpoly = route == "child" -- 1350
	local deskY = oy + ____exports.TOWER_SHOT_LAYOUT.deskTopY * s -- 1351
	if isLowpoly then -- 1354
		self:drawF03LowpolyRoomAndWindow( -- 1355
			uiDraw, -- 1355
			uiGlow, -- 1355
			ctx, -- 1355
			lampProg, -- 1355
			s, -- 1355
			ox, -- 1355
			oy -- 1355
		) -- 1355
	else -- 1355
		self:drawM03PixelRoomAndWindow( -- 1357
			uiDraw, -- 1357
			uiArt, -- 1357
			uiGlow, -- 1357
			ctx, -- 1357
			s, -- 1357
			ox, -- 1357
			oy -- 1357
		) -- 1357
	end -- 1357
	local deskTopCol = isLowpoly and toColor(shadeSurface( -- 1361
		MING_MATERIALS.mingTimber.base, -- 1363
		vec3(-0.25, 0.9, -0.35), -- 1364
		0, -- 1365
		1, -- 1366
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1367
		MING_MATERIALS.mingTimber -- 1368
	)) or Color(86, 60, 42, 255) -- 1370
	local deskFrontCol = isLowpoly and toColor(shadeSurface( -- 1371
		MING_MATERIALS.mingTimberDark.base, -- 1373
		vec3(0, 0.1, -0.99), -- 1374
		-4, -- 1375
		1, -- 1376
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1377
		MING_MATERIALS.mingTimberDark -- 1378
	)) or Color(52, 36, 26, 255) -- 1380
	uiDraw:drawPolygon( -- 1383
		{ -- 1383
			Vec2(0, deskY - 120 * s), -- 1384
			Vec2(ctx.uiW, deskY - 120 * s), -- 1385
			Vec2(ctx.uiW, deskY + 42 * s), -- 1386
			Vec2(0, deskY + 42 * s) -- 1387
		}, -- 1387
		deskTopCol -- 1388
	) -- 1388
	uiDraw:drawRect( -- 1389
		Rect(0, 0, ctx.uiW, deskY - 118 * s), -- 1389
		deskFrontCol -- 1389
	) -- 1389
	uiDraw:drawSegment( -- 1390
		Vec2(0, deskY + 42 * s), -- 1390
		Vec2(ctx.uiW, deskY + 42 * s), -- 1390
		1.6 * s, -- 1390
		Color(158, 126, 92, 165) -- 1390
	) -- 1390
	uiDraw:drawSegment( -- 1391
		Vec2(0, deskY - 118 * s), -- 1391
		Vec2(ctx.uiW, deskY - 118 * s), -- 1391
		2 * s, -- 1391
		Color(172, 138, 102, 155) -- 1391
	) -- 1391
	local inkX = ox + ____exports.TOWER_SHOT_LAYOUT.inkstoneX * s -- 1394
	local inkY = oy + ____exports.TOWER_SHOT_LAYOUT.inkstoneY * s -- 1395
	uiDraw:drawEllipse( -- 1396
		Vec2(inkX + 3 * s, inkY - 18 * s), -- 1396
		44 * s, -- 1396
		11 * s, -- 1396
		Color(10, 10, 14, 145) -- 1396
	) -- 1396
	uiDraw:drawPolygon( -- 1397
		{ -- 1397
			Vec2(inkX - 38 * s, inkY - 18 * s), -- 1398
			Vec2(inkX + 38 * s, inkY - 18 * s), -- 1399
			Vec2(inkX + 32 * s, inkY + 18 * s), -- 1400
			Vec2(inkX - 32 * s, inkY + 18 * s) -- 1401
		}, -- 1401
		Color(38, 44, 52, 255), -- 1402
		1.2, -- 1402
		Color(96, 106, 118, 185) -- 1402
	) -- 1402
	uiDraw:drawEllipse( -- 1403
		Vec2(inkX, inkY + 1 * s), -- 1403
		22 * s, -- 1403
		10 * s, -- 1403
		Color(12, 14, 18, 255) -- 1403
	) -- 1403
	strokeEllipse( -- 1404
		uiDraw, -- 1404
		inkX, -- 1404
		inkY + 1 * s, -- 1404
		22 * s, -- 1404
		10 * s, -- 1404
		1.1 * s, -- 1404
		Color(76, 86, 98, 165), -- 1404
		18 -- 1404
	) -- 1404
	local lx = isLowpoly and ox + lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s or ox + ____exports.TOWER_SHOT_LAYOUT.lampDeskX * s -- 1407
	local ly = isLowpoly and oy + (lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34) * s or oy + ____exports.TOWER_SHOT_LAYOUT.lampDeskY * s -- 1410
	local lampWarmth = isLowpoly and 0.45 + 0.55 * lampProg or 0.92 -- 1413
	self:drawMingLantern( -- 1414
		uiInkDraw, -- 1414
		uiGlow, -- 1414
		lx, -- 1414
		ly, -- 1414
		1.02 * s, -- 1414
		1, -- 1414
		lampWarmth -- 1414
	) -- 1414
	if isLowpoly and lampProg > 0.04 then -- 1417
		local beamA = math.floor(62 * lampProg + 0.5) -- 1418
		fillGradQuad( -- 1419
			uiGlow, -- 1420
			lx + 10 * s, -- 1421
			ly + 30 * s, -- 1421
			Color(248, 206, 134, beamA), -- 1421
			lx + 10 * s, -- 1422
			ly - 32 * s, -- 1422
			Color( -- 1422
				248, -- 1422
				206, -- 1422
				134, -- 1422
				math.floor(beamA * 0.72 + 0.5) -- 1422
			), -- 1422
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.92) * s, -- 1423
			oy + (____exports.TOWER_SHOT_LAYOUT.row2Y - 58) * s, -- 1423
			Color(242, 198, 124, 0), -- 1423
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.85) * s, -- 1424
			oy + (____exports.TOWER_SHOT_LAYOUT.row1Y + 48) * s, -- 1424
			Color(242, 198, 124, 0) -- 1424
		) -- 1424
	end -- 1424
	local bookReveal = smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t) -- 1429
	if bookReveal > 0.02 then -- 1430
		self:drawRegisterBook( -- 1431
			uiDraw, -- 1431
			uiInkDraw, -- 1431
			uiArt, -- 1431
			uiGlow, -- 1431
			ctx, -- 1431
			route, -- 1431
			bookReveal, -- 1431
			lampProg, -- 1431
			s, -- 1431
			ox, -- 1431
			oy -- 1431
		) -- 1431
	end -- 1431
	self:drawDeskPropsAndBowl( -- 1435
		uiDraw, -- 1435
		uiInkDraw, -- 1435
		uiGlow, -- 1435
		route, -- 1435
		s, -- 1435
		ox, -- 1435
		oy -- 1435
	) -- 1435
end -- 1337
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiGlow, ctx, lampProg, s, ox, oy) -- 1438
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1447
	local wallTop = lerpRGBA( -- 1448
		rgba(18, 24, 38, 255), -- 1448
		rgba(46, 36, 28, 255), -- 1448
		lampProg -- 1448
	) -- 1448
	local wallBot = lerpRGBA( -- 1449
		rgba(12, 16, 26, 255), -- 1449
		rgba(28, 22, 20, 255), -- 1449
		lampProg -- 1449
	) -- 1449
	fillVGradRect( -- 1450
		uiDraw, -- 1450
		0, -- 1450
		0, -- 1450
		ctx.uiW, -- 1450
		ctx.uiH, -- 1450
		toColor(wallBot), -- 1450
		toColor(wallTop) -- 1450
	) -- 1450
	local beamCol = shadeSurface( -- 1453
		MING_MATERIALS.mingTimberDark.base, -- 1453
		vec3(-0.3, -0.6, -0.74), -- 1453
		18, -- 1453
		1, -- 1453
		light, -- 1453
		MING_MATERIALS.mingTimberDark -- 1453
	) -- 1453
	uiDraw:drawPolygon( -- 1454
		{ -- 1454
			Vec2(0, ctx.uiH - 96 * s), -- 1455
			Vec2(ctx.uiW, ctx.uiH - 72 * s), -- 1456
			Vec2(ctx.uiW, ctx.uiH - 42 * s), -- 1457
			Vec2(0, ctx.uiH - 42 * s) -- 1458
		}, -- 1458
		toColor(beamCol) -- 1459
	) -- 1459
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1462
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1463
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1464
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1465
	local embrasure = 24 * s -- 1466
	fillVGradRect( -- 1469
		uiDraw, -- 1469
		wx, -- 1469
		wy, -- 1469
		ww, -- 1469
		wh, -- 1469
		Color(34, 44, 62, 255), -- 1469
		Color(16, 24, 40, 255) -- 1469
	) -- 1469
	uiDraw:drawPolygon( -- 1470
		{ -- 1470
			Vec2(wx, wy), -- 1471
			Vec2(wx + ww, wy), -- 1472
			Vec2(wx + ww, wy + wh * 0.34), -- 1473
			Vec2(wx + ww * 0.56, wy + wh * 0.42), -- 1474
			Vec2(wx + ww * 0.22, wy + wh * 0.28), -- 1475
			Vec2(wx, wy + wh * 0.36) -- 1476
		}, -- 1476
		Color(20, 26, 38, 240) -- 1477
	) -- 1477
	if lampProg > 0.12 then -- 1479
		fillRadialGlow( -- 1480
			uiGlow, -- 1481
			wx + ww * 0.5, -- 1481
			wy + 26 * s, -- 1481
			ww * 0.65, -- 1482
			wh * 0.55, -- 1482
			Color( -- 1483
				248, -- 1483
				206, -- 1483
				134, -- 1483
				math.floor(92 * lampProg + 0.5) -- 1483
			), -- 1483
			Color(232, 174, 88, 0), -- 1484
			16 -- 1485
		) -- 1485
	end -- 1485
	local leftWall = shadeSurface( -- 1490
		MING_MATERIALS.mingBrick.base, -- 1490
		vec3(0.84, 0.22, -0.49), -- 1490
		10, -- 1490
		1, -- 1490
		light, -- 1490
		MING_MATERIALS.mingBrick -- 1490
	) -- 1490
	local rightWall = shadeSurface( -- 1491
		MING_MATERIALS.mingBrick.base, -- 1491
		vec3(-0.84, 0.22, -0.49), -- 1491
		10, -- 1491
		1, -- 1491
		light, -- 1491
		MING_MATERIALS.mingBrick -- 1491
	) -- 1491
	local sillCol = shadeSurface( -- 1492
		MING_MATERIALS.mingStoneStep.base, -- 1492
		vec3(0, 0.94, -0.34), -- 1492
		6, -- 1492
		1, -- 1492
		light, -- 1492
		MING_MATERIALS.mingStoneStep -- 1492
	) -- 1492
	uiDraw:drawPolygon( -- 1493
		{ -- 1493
			Vec2(wx - embrasure, wy - 12 * s), -- 1494
			Vec2(wx, wy), -- 1495
			Vec2(wx, wy + wh), -- 1496
			Vec2(wx - embrasure, wy + wh + 14 * s) -- 1497
		}, -- 1497
		toColor(leftWall) -- 1498
	) -- 1498
	uiDraw:drawPolygon( -- 1499
		{ -- 1499
			Vec2(wx + ww, wy), -- 1500
			Vec2(wx + ww + embrasure, wy - 12 * s), -- 1501
			Vec2(wx + ww + embrasure, wy + wh + 14 * s), -- 1502
			Vec2(wx + ww, wy + wh) -- 1503
		}, -- 1503
		toColor(rightWall) -- 1504
	) -- 1504
	uiDraw:drawPolygon( -- 1506
		{ -- 1506
			Vec2(wx - embrasure - 10 * s, wy - 16 * s), -- 1507
			Vec2(wx + ww + embrasure + 10 * s, wy - 16 * s), -- 1508
			Vec2(wx + ww + 4 * s, wy + 10 * s), -- 1509
			Vec2(wx - 4 * s, wy + 10 * s) -- 1510
		}, -- 1510
		toColor(sillCol), -- 1511
		1, -- 1511
		toColor(STONE_EDGE_FALLBACK, 140) -- 1511
	) -- 1511
	local bar = 1 -- 1514
	do -- 1514
		bar = 1 -- 1515
		while bar <= 3 do -- 1515
			local bx = wx + ww * bar / 4 -- 1516
			uiDraw:drawSegment( -- 1517
				Vec2(bx, wy + 6 * s), -- 1517
				Vec2(bx, wy + wh - 2 * s), -- 1517
				3 * s, -- 1517
				Color(46, 34, 26, 235) -- 1517
			) -- 1517
			bar = bar + 1 -- 1515
		end -- 1515
	end -- 1515
	uiDraw:drawSegment( -- 1519
		Vec2(wx, wy + wh * 0.56), -- 1519
		Vec2(wx + ww, wy + wh * 0.56), -- 1519
		3.2 * s, -- 1519
		Color(46, 34, 26, 235) -- 1519
	) -- 1519
	uiDraw:drawRect( -- 1520
		Rect(wx, wy, ww, wh), -- 1520
		Color(0, 0, 0, 0), -- 1520
		2.4 * s, -- 1520
		Color(66, 50, 38, 240) -- 1520
	) -- 1520
	if lampProg > 0.02 then -- 1523
		fillRadialGlow( -- 1524
			uiGlow, -- 1525
			wx + ww * 0.5, -- 1525
			wy + 34 * s, -- 1525
			540 * s, -- 1526
			390 * s, -- 1526
			Color( -- 1527
				246, -- 1527
				198, -- 1527
				122, -- 1527
				math.floor(74 * lampProg + 0.5) -- 1527
			), -- 1527
			Color(216, 154, 72, 0), -- 1528
			20 -- 1529
		) -- 1529
	end -- 1529
end -- 1438
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1534
	fillVGradRect( -- 1544
		uiDraw, -- 1545
		0, -- 1545
		0, -- 1545
		ctx.uiW, -- 1545
		ctx.uiH, -- 1545
		Color(26, 21, 20, 255), -- 1546
		Color(46, 36, 30, 255) -- 1547
	) -- 1547
	local r = 0 -- 1550
	do -- 1550
		r = 0 -- 1551
		while r < 9 do -- 1551
			local y = oy + (280 + r * 44) * s -- 1552
			uiDraw:drawSegment( -- 1553
				Vec2(0, y), -- 1553
				Vec2(ctx.uiW, y), -- 1553
				1, -- 1553
				Color(34, 27, 24, 150) -- 1553
			) -- 1553
			r = r + 1 -- 1551
		end -- 1551
	end -- 1551
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1557
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1558
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1559
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1560
	fillVGradRect( -- 1561
		uiDraw, -- 1561
		wx, -- 1561
		wy, -- 1561
		ww, -- 1561
		wh, -- 1561
		Color(56, 62, 74, 255), -- 1561
		Color(26, 34, 50, 255) -- 1561
	) -- 1561
	uiDraw:drawRect( -- 1562
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1562
		Color(92, 68, 48, 255), -- 1562
		1, -- 1562
		Color(148, 114, 82, 180) -- 1562
	) -- 1562
	local bar = 1 -- 1563
	do -- 1563
		bar = 1 -- 1564
		while bar <= 3 do -- 1564
			local bx = wx + ww * bar / 4 -- 1565
			uiDraw:drawSegment( -- 1566
				Vec2(bx, wy + 4 * s), -- 1566
				Vec2(bx, wy + wh - 2 * s), -- 1566
				3.2 * s, -- 1566
				Color(64, 46, 34, 245) -- 1566
			) -- 1566
			bar = bar + 1 -- 1564
		end -- 1564
	end -- 1564
	uiDraw:drawSegment( -- 1568
		Vec2(wx, wy + wh * 0.56), -- 1568
		Vec2(wx + ww, wy + wh * 0.56), -- 1568
		3.2 * s, -- 1568
		Color(64, 46, 34, 245) -- 1568
	) -- 1568
	uiDraw:drawRect( -- 1569
		Rect(wx, wy, ww, wh), -- 1569
		Color(0, 0, 0, 0), -- 1569
		2.8 * s, -- 1569
		Color(88, 64, 44, 245) -- 1569
	) -- 1569
	local groupX = ox + 210 * s -- 1572
	local groupY = oy + 300 * s -- 1573
	uiArt:tryPlace( -- 1574
		"soldier_idle", -- 1574
		"fe05_m03_room_soldier", -- 1574
		groupX - 38 * s, -- 1574
		groupY, -- 1574
		118 * s, -- 1574
		166 * s, -- 1574
		{facing = 1, opacity = 0.9, layer = 1} -- 1574
	) -- 1574
	uiArt:tryPlace( -- 1577
		"child_idle", -- 1577
		"fe05_m03_room_child", -- 1577
		groupX + 42 * s, -- 1577
		groupY, -- 1577
		86 * s, -- 1577
		116 * s, -- 1577
		{facing = 1, opacity = 0.92, layer = 1} -- 1577
	) -- 1577
	fillRadialGlow( -- 1582
		uiGlow, -- 1583
		ox + 260 * s, -- 1583
		oy + 416 * s, -- 1583
		520 * s, -- 1584
		360 * s, -- 1584
		Color(246, 202, 134, 68), -- 1585
		Color(220, 158, 76, 0), -- 1586
		20 -- 1587
	) -- 1587
end -- 1534
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1591
	local t = self.seqElapsed -- 1604
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1605
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1606
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1607
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1608
	local midX = bx + bw * 0.5 -- 1609
	local midY = by + bh * 0.5 -- 1610
	uiDraw:drawRect( -- 1613
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1613
		Color( -- 1613
			10, -- 1613
			11, -- 1613
			16, -- 1613
			math.floor(108 * reveal + 0.5) -- 1613
		) -- 1613
	) -- 1613
	uiDraw:drawRect( -- 1614
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1614
		Color( -- 1614
			32, -- 1614
			46, -- 1614
			62, -- 1614
			math.floor(235 * reveal + 0.5) -- 1614
		), -- 1614
		1, -- 1614
		Color( -- 1614
			86, -- 1614
			104, -- 1614
			124, -- 1614
			math.floor(165 * reveal + 0.5) -- 1614
		) -- 1614
	) -- 1614
	if not uiArt:tryPlace( -- 1617
		"ink_song_paper", -- 1617
		"fe05_registry_paper", -- 1617
		midX, -- 1617
		midY, -- 1617
		bw, -- 1617
		bh, -- 1617
		{opacity = 0.98 * reveal, layer = 1} -- 1617
	) then -- 1617
		uiDraw:drawRect( -- 1618
			Rect(bx, by, bw, bh), -- 1619
			toColor( -- 1620
				PALETTE.xuanPaper, -- 1620
				math.floor(248 * reveal + 0.5) -- 1620
			), -- 1620
			1, -- 1621
			toColor( -- 1622
				PALETTE.silkDim, -- 1622
				math.floor(180 * reveal + 0.5) -- 1622
			) -- 1622
		) -- 1622
	end -- 1622
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1627
	fillRadialGlow( -- 1628
		uiGlow, -- 1629
		bx + bw * 0.34, -- 1629
		by + bh * 0.48, -- 1629
		bw * 0.58, -- 1630
		bh * 0.52, -- 1630
		Color( -- 1631
			246, -- 1631
			214, -- 1631
			156, -- 1631
			math.floor(44 * paperWarm * reveal + 0.5) -- 1631
		), -- 1631
		Color(238, 198, 128, 0), -- 1632
		16 -- 1633
	) -- 1633
	local padX = 44 * s -- 1637
	local padY = 32 * s -- 1638
	local inX = bx + padX -- 1639
	local inY = by + padY -- 1640
	local inW = bw - padX * 2 -- 1641
	local inH = bh - padY * 2 -- 1642
	local redSilk = toColor( -- 1643
		PALETTE.rouge, -- 1643
		math.floor(132 * reveal + 0.5) -- 1643
	) -- 1643
	local redFaint = toColor( -- 1644
		PALETTE.rouge, -- 1644
		math.floor(70 * reveal + 0.5) -- 1644
	) -- 1644
	uiInkDraw:drawRect( -- 1645
		Rect(inX, inY, inW, inH), -- 1645
		Color(0, 0, 0, 0), -- 1645
		1, -- 1645
		redSilk -- 1645
	) -- 1645
	uiInkDraw:drawRect( -- 1646
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1646
		Color(0, 0, 0, 0), -- 1646
		0.6, -- 1646
		redFaint -- 1646
	) -- 1646
	local headY = inY + inH - 28 * s -- 1649
	ctx.texts:put( -- 1650
		"md", -- 1650
		"北塔值夜收籍 · 末页", -- 1650
		inX + 18 * s, -- 1650
		headY, -- 1650
		toColor(PALETTE.xuanInk), -- 1650
		0, -- 1650
		0.5, -- 1650
		"Left", -- 1650
		2.2, -- 1650
		0.96 * reveal, -- 1650
		0 -- 1650
	) -- 1650
	ctx.texts:put( -- 1651
		"xs", -- 1651
		"宁村北塔", -- 1651
		inX + inW - 18 * s, -- 1651
		headY, -- 1651
		toColor(PALETTE.xuanInkSub), -- 1651
		1, -- 1651
		0.5, -- 1651
		"Right", -- 1651
		1.8, -- 1651
		0.8 * reveal, -- 1651
		0 -- 1651
	) -- 1651
	uiInkDraw:drawSegment( -- 1652
		Vec2(inX + 14 * s, headY - 22 * s), -- 1652
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1652
		0.9, -- 1652
		redSilk -- 1652
	) -- 1652
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1655
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1656
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1657
	ctx.texts:put( -- 1658
		"sm", -- 1658
		"肆拾壹", -- 1658
		inX + 18 * s, -- 1658
		row1Y, -- 1658
		toColor(PALETTE.rouge), -- 1658
		0, -- 1658
		0.5, -- 1658
		"Left", -- 1658
		1, -- 1658
		0.94 * reveal, -- 1658
		0 -- 1658
	) -- 1658
	if r1Prog > 0.02 then -- 1659
		ctx.texts:put( -- 1660
			"md", -- 1660
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1660
			inX + 96 * s, -- 1660
			row1Y, -- 1660
			toColor(PALETTE.xuanInk), -- 1660
			0, -- 1660
			0.5, -- 1660
			"Left", -- 1660
			1.6, -- 1660
			0.96 * math.min(1, r1Prog * 1.4), -- 1660
			0 -- 1660
		) -- 1660
	end -- 1660
	if r1Prog > 0.65 then -- 1662
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1663
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1664
		ctx.texts:put( -- 1667
			"xs", -- 1667
			subText, -- 1667
			inX + 96 * s, -- 1667
			row1SubY, -- 1667
			toColor(PALETTE.xuanInkSub), -- 1667
			0, -- 1667
			0.5, -- 1667
			"Left", -- 1667
			0.6, -- 1667
			0.88 * subA, -- 1667
			0 -- 1667
		) -- 1667
	end -- 1667
	uiInkDraw:drawSegment( -- 1669
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1669
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1669
		0.7, -- 1669
		redFaint -- 1669
	) -- 1669
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1672
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1673
	ctx.texts:put( -- 1674
		"sm", -- 1674
		"肆拾贰", -- 1674
		inX + 18 * s, -- 1674
		row2Y, -- 1674
		toColor(PALETTE.rouge), -- 1674
		0, -- 1674
		0.5, -- 1674
		"Left", -- 1674
		1, -- 1674
		0.94 * reveal, -- 1674
		0 -- 1674
	) -- 1674
	if route == "child" then -- 1676
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1678
		uiInkDraw:drawSegment( -- 1679
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1680
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1681
			1, -- 1682
			toColor(PALETTE.xuanInkSub, lineA) -- 1683
		) -- 1683
	else -- 1683
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1687
		if r2Prog <= 0.02 then -- 1688
			uiInkDraw:drawSegment( -- 1689
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1690
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1691
				0.9, -- 1692
				toColor( -- 1693
					PALETTE.xuanInkSub, -- 1693
					math.floor(105 * reveal + 0.5) -- 1693
				) -- 1693
			) -- 1693
		else -- 1693
			ctx.texts:put( -- 1696
				"md", -- 1696
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1696
				inX + 96 * s, -- 1696
				row2Y, -- 1696
				toColor(PALETTE.xuanInk), -- 1696
				0, -- 1696
				0.5, -- 1696
				"Left", -- 1696
				1.6, -- 1696
				0.96 * math.min(1, r2Prog * 1.4), -- 1696
				0 -- 1696
			) -- 1696
			if r2Prog > 0.65 then -- 1697
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1698
				ctx.texts:put( -- 1699
					"xs", -- 1699
					"守城戍卒亲口报出姓名，两人俱安。", -- 1699
					inX + 96 * s, -- 1699
					row2SubY, -- 1699
					toColor(PALETTE.xuanInkSub), -- 1699
					0, -- 1699
					0.5, -- 1699
					"Left", -- 1699
					0.6, -- 1699
					0.88 * subA, -- 1699
					0 -- 1699
				) -- 1699
			end -- 1699
		end -- 1699
	end -- 1699
	uiInkDraw:drawSegment( -- 1703
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1703
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1703
		0.7, -- 1703
		redFaint -- 1703
	) -- 1703
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1706
	if colophonA > 0.02 then -- 1707
		local signY = inY + 34 * s -- 1708
		ctx.texts:put( -- 1709
			"banner", -- 1709
			"向西守望", -- 1709
			midX - 24 * s, -- 1709
			signY, -- 1709
			toColor(PALETTE.xuanInk), -- 1709
			0.5, -- 1709
			0.5, -- 1709
			"Center", -- 1709
			6, -- 1709
			0.88 * colophonA, -- 1709
			0 -- 1709
		) -- 1709
	end -- 1709
	self:drawGuardBrushHand( -- 1713
		uiInkDraw, -- 1713
		route, -- 1713
		s, -- 1713
		ox, -- 1713
		oy -- 1713
	) -- 1713
end -- 1591
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, route, s, ox, oy) -- 1716
	local t = self.seqElapsed -- 1723
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1724
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1725
	local row1X0 = hoverX -- 1726
	local row1X1 = hoverX + 142 * s -- 1727
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1728
	local tipX = hoverX -- 1730
	local tipY = hoverY -- 1731
	local alpha = 0 -- 1732
	local lifted = 0 -- 1733
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1735
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1737
		tipX = lerp(row1X0, row1X1, k) -- 1738
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1739
		alpha = smoothstep(2, 2.2, t) -- 1740
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1741
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1742
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1744
		tipX = lerp(row1X1, hoverX, moveK) -- 1745
		tipY = lerp(row1Y, hoverY, moveK) -- 1746
		alpha = 1 -- 1747
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1748
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1749
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1751
		tipX = hoverX + outK * 140 * s -- 1752
		tipY = hoverY + outK * 46 * s -- 1753
		lifted = (9 + outK * 28) * s -- 1754
		alpha = 1 - outK -- 1755
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1756
		if t < 4.6 then -- 1758
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1759
			tipX = hoverX -- 1760
			tipY = hoverY -- 1761
			lifted = lerp(9 * s, 0, dipK) -- 1762
			alpha = 1 -- 1763
		elseif t < 5.55 then -- 1764
			local wK = smoothstep(4.6, 5.55, t) -- 1765
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1766
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1767
			lifted = 0 -- 1768
			alpha = 1 -- 1769
		else -- 1769
			local outK = smoothstep(5.55, 6.05, t) -- 1771
			tipX = hoverX + 216 * s + outK * 115 * s -- 1772
			tipY = hoverY + outK * 52 * s -- 1773
			lifted = outK * 24 * s -- 1774
			alpha = 1 - outK -- 1775
		end -- 1775
	end -- 1775
	if alpha <= 0.02 then -- 1779
		return -- 1780
	end -- 1780
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1783
	local bx = tipX -- 1784
	local by = tipY + lifted -- 1785
	uiInkDraw:drawEllipse( -- 1787
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1787
		(5 + lifted * 0.22) * s, -- 1787
		2.8 * s, -- 1787
		Color( -- 1787
			20, -- 1787
			18, -- 1787
			16, -- 1787
			math.floor(78 * alpha + 0.5) -- 1787
		) -- 1787
	) -- 1787
	uiInkDraw:drawPolygon( -- 1789
		{ -- 1789
			Vec2(bx, by), -- 1790
			Vec2(bx + 15 * s, by - 4 * s), -- 1791
			Vec2(bx + 10 * s, by + 8 * s) -- 1792
		}, -- 1792
		Color(22, 22, 26, a) -- 1793
	) -- 1793
	uiInkDraw:drawSegment( -- 1795
		Vec2(bx + 12 * s, by + 2 * s), -- 1795
		Vec2(bx + 24 * s, by + 6 * s), -- 1795
		7.8 * s, -- 1795
		Color(164, 138, 92, a) -- 1795
	) -- 1795
	uiInkDraw:drawSegment( -- 1796
		Vec2(bx + 22 * s, by + 5 * s), -- 1796
		Vec2(bx + 122 * s, by + 34 * s), -- 1796
		6.8 * s, -- 1796
		Color(142, 110, 74, a) -- 1796
	) -- 1796
	uiInkDraw:drawSegment( -- 1797
		Vec2(bx + 22 * s, by + 5 * s), -- 1797
		Vec2(bx + 122 * s, by + 34 * s), -- 1797
		1.8 * s, -- 1797
		Color( -- 1797
			196, -- 1797
			164, -- 1797
			118, -- 1797
			math.floor(185 * alpha + 0.5) -- 1797
		) -- 1797
	) -- 1797
	uiInkDraw:drawPolygon( -- 1799
		{ -- 1799
			Vec2(bx + 44 * s, by - 6 * s), -- 1800
			Vec2(bx + 102 * s, by - 14 * s), -- 1801
			Vec2(bx + 110 * s, by + 18 * s), -- 1802
			Vec2(bx + 54 * s, by + 22 * s) -- 1803
		}, -- 1803
		Color(188, 154, 126, a), -- 1804
		1, -- 1804
		Color(128, 98, 76, a) -- 1804
	) -- 1804
	uiInkDraw:drawSegment( -- 1805
		Vec2(bx + 46 * s, by + 16 * s), -- 1805
		Vec2(bx + 76 * s, by + 20 * s), -- 1805
		5.2 * s, -- 1805
		Color(204, 170, 140, a) -- 1805
	) -- 1805
	uiInkDraw:drawSegment( -- 1806
		Vec2(bx + 48 * s, by + 2 * s), -- 1806
		Vec2(bx + 82 * s, by + 4 * s), -- 1806
		4.8 * s, -- 1806
		Color(180, 146, 118, a) -- 1806
	) -- 1806
	uiInkDraw:drawPolygon( -- 1807
		{ -- 1807
			Vec2(bx + 98 * s, by - 14 * s), -- 1808
			Vec2(bx + 224 * s, by - 32 * s), -- 1809
			Vec2(bx + 230 * s, by + 18 * s), -- 1810
			Vec2(bx + 104 * s, by + 20 * s) -- 1811
		}, -- 1811
		Color(54, 48, 44, a), -- 1812
		1.2, -- 1812
		Color(94, 84, 72, a) -- 1812
	) -- 1812
end -- 1716
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiGlow, route, s, ox, oy) -- 1815
	local t = self.seqElapsed -- 1824
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1825
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1826
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1827
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1828
	if route == "child" then -- 1830
		local propA = smoothstep(1.55, 2.05, t) -- 1832
		if propA > 0.02 then -- 1833
			self:drawNeedleCaseOnDesk( -- 1834
				uiInkDraw, -- 1834
				ncX, -- 1834
				ncY, -- 1834
				s, -- 1834
				propA, -- 1834
				true -- 1834
			) -- 1834
		end -- 1834
		local bowlK = smoothstep(4.35, 5.15, t) -- 1837
		if bowlK > 0.02 then -- 1838
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1839
			self:drawWarmPorcelainBowl( -- 1840
				uiInkDraw, -- 1840
				uiGlow, -- 1840
				bx, -- 1840
				bowlY, -- 1840
				s, -- 1840
				bowlK, -- 1840
				false, -- 1840
				0 -- 1840
			) -- 1840
		end -- 1840
	else -- 1840
		local needleK = smoothstep(5.45, 6.15, t) -- 1844
		if needleK > 0.02 then -- 1845
			local ny = lerp(ncY + 46 * s, ncY, needleK) -- 1846
			self:drawNeedleCaseOnDesk( -- 1847
				uiInkDraw, -- 1847
				ncX, -- 1847
				ny, -- 1847
				s, -- 1847
				needleK, -- 1847
				false -- 1847
			) -- 1847
		end -- 1847
		local bowlK = smoothstep(5.8, 6.65, t) -- 1850
		if bowlK > 0.02 then -- 1851
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1852
			local handsK = smoothstep(5.95, 6.75, t) -- 1853
			self:drawWarmPorcelainBowl( -- 1854
				uiInkDraw, -- 1854
				uiGlow, -- 1854
				bowlX, -- 1854
				by, -- 1854
				s, -- 1854
				bowlK, -- 1854
				true, -- 1854
				handsK -- 1854
			) -- 1854
		end -- 1854
		local cuffK = smoothstep(4.25, 4.85, t) -- 1857
		if cuffK > 0.02 then -- 1858
			drawPatchedCuff(uiInkDraw, uiGlow, { -- 1859
				wristX = ox + 122 * s, -- 1860
				wristY = oy + 182 * s, -- 1861
				angleRad = 0.08, -- 1862
				scale = 0.6 * s, -- 1863
				pose = "open", -- 1864
				opacity = 0.92 * cuffK, -- 1865
				stitchHighlight = 0.34, -- 1866
				warmth = 0.72 -- 1867
			}) -- 1867
		end -- 1867
	end -- 1867
end -- 1815
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, draw, cx, cy, s, alpha, withNote) -- 1874
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1882
	draw:drawEllipse( -- 1884
		Vec2(cx + 4 * s, cy - 12 * s), -- 1884
		44 * s, -- 1884
		14 * s, -- 1884
		Color( -- 1884
			10, -- 1884
			10, -- 1884
			14, -- 1884
			math.floor(140 * alpha + 0.5) -- 1884
		) -- 1884
	) -- 1884
	draw:drawPolygon( -- 1886
		{ -- 1886
			Vec2(cx - 32 * s, cy - 12 * s), -- 1887
			Vec2(cx + 26 * s, cy - 15 * s), -- 1888
			Vec2(cx + 30 * s, cy + 16 * s), -- 1889
			Vec2(cx - 28 * s, cy + 18 * s) -- 1890
		}, -- 1890
		Color(148, 124, 92, a), -- 1891
		1.3, -- 1891
		Color(88, 70, 50, a) -- 1891
	) -- 1891
	draw:drawEllipse( -- 1893
		Vec2(cx + 18 * s, cy + 2 * s), -- 1893
		13 * s, -- 1893
		13 * s, -- 1893
		Color(188, 152, 86, a) -- 1893
	) -- 1893
	strokeEllipse( -- 1894
		draw, -- 1894
		cx + 18 * s, -- 1894
		cy + 2 * s, -- 1894
		13 * s, -- 1894
		13 * s, -- 1894
		1.5 * s, -- 1894
		Color(118, 92, 46, a), -- 1894
		18 -- 1894
	) -- 1894
	draw:drawDot( -- 1895
		Vec2(cx + 18 * s, cy + 2 * s), -- 1895
		2.5 * s, -- 1895
		Color(72, 54, 28, a) -- 1895
	) -- 1895
	draw:drawSegment( -- 1896
		Vec2(cx + 12 * s, cy - 2 * s), -- 1896
		Vec2(cx + 24 * s, cy + 6 * s), -- 1896
		1.5 * s, -- 1896
		Color(164, 48, 44, a) -- 1896
	) -- 1896
	draw:drawSegment( -- 1898
		Vec2(cx - 28 * s, cy + 4 * s), -- 1898
		Vec2(cx - 56 * s, cy - 8 * s), -- 1898
		2.4 * s, -- 1898
		toColor(CUFF_PALETTE.childCord, a) -- 1898
	) -- 1898
	draw:drawSegment( -- 1899
		Vec2(cx - 56 * s, cy - 8 * s), -- 1899
		Vec2(cx - 72 * s, cy + 6 * s), -- 1899
		2.2 * s, -- 1899
		toColor(CUFF_PALETTE.childCord, a) -- 1899
	) -- 1899
	draw:drawSegment( -- 1900
		Vec2(cx - 72 * s, cy + 6 * s), -- 1900
		Vec2(cx - 48 * s, cy + 16 * s), -- 1900
		2 * s, -- 1900
		toColor( -- 1900
			CUFF_PALETTE.childCord, -- 1900
			math.floor(215 * alpha + 0.5) -- 1900
		) -- 1900
	) -- 1900
	if withNote then -- 1902
		draw:drawPolygon( -- 1904
			{ -- 1904
				Vec2(cx + 38 * s, cy - 18 * s), -- 1905
				Vec2(cx + 96 * s, cy - 12 * s), -- 1906
				Vec2(cx + 90 * s, cy + 24 * s), -- 1907
				Vec2(cx + 34 * s, cy + 18 * s) -- 1908
			}, -- 1908
			toColor(PALETTE.xuanPaper, a), -- 1909
			1, -- 1909
			toColor( -- 1909
				PALETTE.xuanInkSub, -- 1909
				math.floor(160 * alpha + 0.5) -- 1909
			) -- 1909
		) -- 1909
		draw:drawSegment( -- 1910
			Vec2(cx + 46 * s, cy + 8 * s), -- 1910
			Vec2(cx + 80 * s, cy + 11 * s), -- 1910
			1.2 * s, -- 1910
			toColor( -- 1910
				PALETTE.xuanInk, -- 1910
				math.floor(170 * alpha + 0.5) -- 1910
			) -- 1910
		) -- 1910
		draw:drawSegment( -- 1911
			Vec2(cx + 46 * s, cy - 2 * s), -- 1911
			Vec2(cx + 76 * s, cy + 1 * s), -- 1911
			1.2 * s, -- 1911
			toColor( -- 1911
				PALETTE.xuanInk, -- 1911
				math.floor(160 * alpha + 0.5) -- 1911
			) -- 1911
		) -- 1911
	end -- 1911
end -- 1874
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, draw, glow, cx, cy, s, alpha, heldByTwoHands, handsK) -- 1916
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1926
	draw:drawEllipse( -- 1928
		Vec2(cx, cy - 36 * s), -- 1928
		58 * s, -- 1928
		14 * s, -- 1928
		Color( -- 1928
			8, -- 1928
			9, -- 1928
			14, -- 1928
			math.floor(150 * alpha + 0.5) -- 1928
		) -- 1928
	) -- 1928
	draw:drawPolygon( -- 1930
		{ -- 1930
			Vec2(cx - 32 * s, cy - 38 * s), -- 1931
			Vec2(cx + 32 * s, cy - 38 * s), -- 1932
			Vec2(cx + 62 * s, cy + 8 * s), -- 1933
			Vec2(cx - 62 * s, cy + 8 * s) -- 1934
		}, -- 1934
		Color(168, 166, 156, a), -- 1935
		1.4, -- 1935
		Color(98, 96, 88, a) -- 1935
	) -- 1935
	draw:drawPolygon( -- 1937
		{ -- 1937
			Vec2(cx + 8 * s, cy - 36 * s), -- 1938
			Vec2(cx + 32 * s, cy - 38 * s), -- 1939
			Vec2(cx + 62 * s, cy + 8 * s), -- 1940
			Vec2(cx + 22 * s, cy + 6 * s) -- 1941
		}, -- 1941
		Color( -- 1942
			122, -- 1942
			120, -- 1942
			112, -- 1942
			math.floor(160 * alpha + 0.5) -- 1942
		) -- 1942
	) -- 1942
	draw:drawEllipse( -- 1944
		Vec2(cx, cy + 8 * s), -- 1944
		64 * s, -- 1944
		21 * s, -- 1944
		Color(224, 218, 206, a) -- 1944
	) -- 1944
	strokeEllipse( -- 1945
		draw, -- 1945
		cx, -- 1945
		cy + 8 * s, -- 1945
		64 * s, -- 1945
		21 * s, -- 1945
		1.9 * s, -- 1945
		Color(116, 110, 100, a), -- 1945
		28 -- 1945
	) -- 1945
	draw:drawEllipse( -- 1946
		Vec2(cx, cy + 6 * s), -- 1946
		54 * s, -- 1946
		15 * s, -- 1946
		Color(196, 168, 122, a) -- 1946
	) -- 1946
	strokeEllipse( -- 1947
		draw, -- 1947
		cx, -- 1947
		cy + 6 * s, -- 1947
		54 * s, -- 1947
		15 * s, -- 1947
		1.1 * s, -- 1947
		Color(158, 132, 92, a), -- 1947
		24 -- 1947
	) -- 1947
	draw:drawSegment( -- 1949
		Vec2(cx - 46 * s, cy + 16 * s), -- 1949
		Vec2(cx - 10 * s, cy + 25 * s), -- 1949
		2 * s, -- 1949
		Color( -- 1949
			248, -- 1949
			246, -- 1949
			240, -- 1949
			math.floor(215 * alpha + 0.5) -- 1949
		) -- 1949
	) -- 1949
	local wi = 0 -- 1952
	do -- 1952
		wi = 0 -- 1953
		while wi < 3 do -- 1953
			local phase = self.animTime * 1.1 + wi * 2.05 -- 1954
			local baseX = cx + (wi - 1) * 18 * s -- 1955
			local baseY = cy + 16 * s -- 1956
			local segs = 4 -- 1957
			local prevX = baseX -- 1958
			local prevY = baseY -- 1959
			local si = 1 -- 1960
			do -- 1960
				si = 1 -- 1961
				while si <= segs do -- 1961
					local frac = si / segs -- 1962
					local nx = baseX + math.sin(phase + frac * 3.1) * (6.5 * frac) * s -- 1963
					local ny = baseY + frac * (36 + wi % 2 * 10) * s -- 1964
					local wa = math.floor(46 * (1 - frac * 0.72) * alpha + 0.5) -- 1965
					glow:drawSegment( -- 1966
						Vec2(prevX, prevY), -- 1966
						Vec2(nx, ny), -- 1966
						(2.2 - frac * 0.9) * s, -- 1966
						Color(244, 238, 226, wa) -- 1966
					) -- 1966
					prevX = nx -- 1967
					prevY = ny -- 1968
					si = si + 1 -- 1961
				end -- 1961
			end -- 1961
			wi = wi + 1 -- 1953
		end -- 1953
	end -- 1953
	if heldByTwoHands and handsK > 0.02 then -- 1973
		local ha = math.floor(255 * clamp01(handsK * alpha) + 0.5) -- 1974
		local skin = toColor(CUFF_PALETTE.childSkin, ha) -- 1975
		local skinSh = toColor(CUFF_PALETTE.childSkinShadow, ha) -- 1976
		local sleeve = toColor(CUFF_PALETTE.childSleeve, ha) -- 1977
		local spread = (1 - handsK) * 28 * s -- 1978
		draw:drawPolygon( -- 1981
			{ -- 1981
				Vec2(cx - 122 * s - spread, cy - 58 * s), -- 1982
				Vec2(cx - 72 * s - spread, cy - 30 * s), -- 1983
				Vec2(cx - 82 * s - spread, cy - 4 * s), -- 1984
				Vec2(cx - 134 * s - spread, cy - 26 * s) -- 1985
			}, -- 1985
			sleeve, -- 1986
			1.1, -- 1986
			skinSh -- 1986
		) -- 1986
		draw:drawPolygon( -- 1987
			{ -- 1987
				Vec2(cx - 76 * s - spread, cy - 28 * s), -- 1988
				Vec2(cx - 48 * s - spread, cy - 18 * s), -- 1989
				Vec2(cx - 44 * s - spread, cy + 6 * s), -- 1990
				Vec2(cx - 74 * s - spread, cy + 2 * s) -- 1991
			}, -- 1991
			skin, -- 1992
			1.1, -- 1992
			skinSh -- 1992
		) -- 1992
		draw:drawSegment( -- 1993
			Vec2(cx - 56 * s - spread, cy + 2 * s), -- 1993
			Vec2(cx - 38 * s - spread, cy + 12 * s), -- 1993
			4.6 * s, -- 1993
			skin -- 1993
		) -- 1993
		draw:drawSegment( -- 1994
			Vec2(cx - 58 * s - spread, cy - 7 * s), -- 1994
			Vec2(cx - 40 * s - spread, cy - 2 * s), -- 1994
			4.4 * s, -- 1994
			skin -- 1994
		) -- 1994
		draw:drawSegment( -- 1995
			Vec2(cx - 56 * s - spread, cy - 16 * s), -- 1995
			Vec2(cx - 40 * s - spread, cy - 14 * s), -- 1995
			4.2 * s, -- 1995
			skin -- 1995
		) -- 1995
		draw:drawPolygon( -- 1998
			{ -- 1998
				Vec2(cx + 122 * s + spread, cy - 58 * s), -- 1999
				Vec2(cx + 72 * s + spread, cy - 30 * s), -- 2000
				Vec2(cx + 82 * s + spread, cy - 4 * s), -- 2001
				Vec2(cx + 134 * s + spread, cy - 26 * s) -- 2002
			}, -- 2002
			sleeve, -- 2003
			1.1, -- 2003
			skinSh -- 2003
		) -- 2003
		draw:drawPolygon( -- 2004
			{ -- 2004
				Vec2(cx + 76 * s + spread, cy - 28 * s), -- 2005
				Vec2(cx + 48 * s + spread, cy - 18 * s), -- 2006
				Vec2(cx + 44 * s + spread, cy + 6 * s), -- 2007
				Vec2(cx + 74 * s + spread, cy + 2 * s) -- 2008
			}, -- 2008
			skin, -- 2009
			1.1, -- 2009
			skinSh -- 2009
		) -- 2009
		draw:drawSegment( -- 2010
			Vec2(cx + 56 * s + spread, cy + 2 * s), -- 2010
			Vec2(cx + 38 * s + spread, cy + 12 * s), -- 2010
			4.6 * s, -- 2010
			skin -- 2010
		) -- 2010
		draw:drawSegment( -- 2011
			Vec2(cx + 58 * s + spread, cy - 7 * s), -- 2011
			Vec2(cx + 40 * s + spread, cy - 2 * s), -- 2011
			4.4 * s, -- 2011
			skin -- 2011
		) -- 2011
		draw:drawSegment( -- 2012
			Vec2(cx + 56 * s + spread, cy - 16 * s), -- 2012
			Vec2(cx + 40 * s + spread, cy - 14 * s), -- 2012
			4.2 * s, -- 2012
			skin -- 2012
		) -- 2012
	end -- 2012
end -- 1916
function TowerEndingsPlugin.prototype.drawMingLantern(self, draw, glow, cx, cy, scale, alpha, warmth) -- 2017
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 2026
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 2027
	draw:drawSegment( -- 2029
		Vec2(cx - 10 * scale, cy + 28 * scale), -- 2029
		Vec2(cx, cy + 40 * scale), -- 2029
		1.8 * scale, -- 2029
		Color(88, 86, 82, a) -- 2029
	) -- 2029
	draw:drawSegment( -- 2030
		Vec2(cx + 10 * scale, cy + 28 * scale), -- 2030
		Vec2(cx, cy + 40 * scale), -- 2030
		1.8 * scale, -- 2030
		Color(88, 86, 82, a) -- 2030
	) -- 2030
	draw:drawRect( -- 2032
		Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), -- 2032
		Color(62, 46, 34, a), -- 2032
		1, -- 2032
		Color(118, 92, 66, a) -- 2032
	) -- 2032
	draw:drawRect( -- 2033
		Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), -- 2033
		Color(62, 46, 34, a), -- 2033
		1, -- 2033
		Color(118, 92, 66, a) -- 2033
	) -- 2033
	draw:drawRect( -- 2035
		Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale), -- 2036
		Color( -- 2037
			238, -- 2037
			198, -- 2037
			132, -- 2037
			math.floor(230 * alpha * (0.75 + 0.25 * warmth) + 0.5) -- 2037
		), -- 2037
		1.4 * scale, -- 2038
		Color(94, 70, 48, a) -- 2039
	) -- 2039
	draw:drawSegment( -- 2041
		Vec2(cx, cy - 18 * scale), -- 2041
		Vec2(cx, cy + 22 * scale), -- 2041
		1.1 * scale, -- 2041
		Color( -- 2041
			94, -- 2041
			70, -- 2041
			48, -- 2041
			math.floor(150 * alpha + 0.5) -- 2041
		) -- 2041
	) -- 2041
	draw:drawEllipse( -- 2042
		Vec2(cx, cy + 2 * scale), -- 2042
		4.6 * scale * flicker, -- 2042
		8.5 * scale * flicker, -- 2042
		Color(255, 244, 212, a) -- 2042
	) -- 2042
	fillRadialGlow( -- 2044
		glow, -- 2045
		cx, -- 2045
		cy + 2 * scale, -- 2045
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2046
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2047
		Color( -- 2048
			250, -- 2048
			208, -- 2048
			132, -- 2048
			math.floor(128 * alpha * warmth + 0.5) -- 2048
		), -- 2048
		Color(228, 162, 74, 0), -- 2049
		16 -- 2050
	) -- 2050
end -- 2017
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 2054
	local line = self.lastSubtitle -- 2063
	if line ~= "" then -- 2064
		local cy = barH + 34 * s -- 2065
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 2066
		drawSilkVeil( -- 2067
			uiDraw, -- 2067
			uiArt, -- 2067
			"fe05_sub_veil", -- 2067
			ctx.uiW * 0.5, -- 2067
			cy, -- 2067
			stripW, -- 2067
			48 * s, -- 2067
			PALETTE.inkWash, -- 2067
			0.82, -- 2067
			3 -- 2067
		) -- 2067
		drawHairline( -- 2068
			uiInkDraw, -- 2068
			uiArt, -- 2068
			"fe05_sub_hair", -- 2068
			ctx.uiW * 0.5, -- 2068
			cy + 21 * s, -- 2068
			stripW * 0.68, -- 2068
			PALETTE.silkDim, -- 2068
			0.54, -- 2068
			true, -- 2068
			4 -- 2068
		) -- 2068
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 2069
		ctx.texts:put( -- 2070
			isSpoken and "md" or "sm", -- 2071
			line, -- 2072
			ctx.uiW * 0.5, -- 2073
			cy - 1 * s, -- 2074
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 2075
			0.5, -- 2076
			0.5, -- 2077
			"Center", -- 2078
			isSpoken and 1.8 or 1, -- 2079
			0.98, -- 2080
			0.08 -- 2081
		) -- 2081
	end -- 2081
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 2086
		local rawHint = route == "child" and "按 E 再次启程   ·   Esc 暂歇" or "团圆尾声   ·   按 E 再次启程   ·   Esc 暂歇" -- 2087
		local hint = adaptHintSentence(rawHint, ctx.input.inputMode, ctx.input.gamepadLayout) -- 2090
		ctx.texts:put( -- 2091
			"xs", -- 2091
			hint, -- 2091
			ctx.uiW * 0.5, -- 2091
			barH * 0.5, -- 2091
			toColor(PALETTE.textMid), -- 2091
			0.5, -- 2091
			0.5, -- 2091
			"Center", -- 2091
			1.4, -- 2091
			0.88, -- 2091
			0.08 -- 2091
		) -- 2091
	end -- 2091
end -- 2054
function ____exports.createTowerEndingsPlugin() -- 2096
	return __TS__New(____exports.TowerEndingsPlugin) -- 2097
end -- 2096
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 2101
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 2102
	fe:registerPlugin(plugin) -- 2103
	return plugin -- 2104
end -- 2101
return ____exports -- 2101
