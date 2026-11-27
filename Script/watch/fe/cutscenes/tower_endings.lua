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
	if not active then -- 313
		return "idle" -- 315
	end -- 315
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 315
		return "porch_knock" -- 318
	end -- 318
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 318
		return "door_open" -- 321
	end -- 321
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 321
		return "book_row1" -- 324
	end -- 324
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 324
		return "pivot_hover" -- 327
	end -- 327
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 327
		return "diverge_action" -- 330
	end -- 330
	return "ending_hold" -- 332
end -- 313
--- 将字符切片数组按进度拼接为前 n 段（避免 Lua 字节切片截断 UTF-8 汉字）
local function joinPrefixTokens(tokens, progress) -- 336
	if progress <= 0 or #tokens == 0 then -- 336
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
	if v ~= nil and type(v) == "table" then -- 352
		return v -- 354
	end -- 354
	return nil -- 356
end -- 352
--- 描边椭圆（Dora DrawNode.drawEllipse 仅支持填充，描边用等分折线保证锐利清晰）
local function strokeEllipse(draw, cx, cy, rx, ry, width, color, segments) -- 360
	if segments == nil then -- 360
		segments = 24 -- 368
	end -- 368
	if rx <= 0.5 or ry <= 0.5 or width <= 0.05 then -- 368
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
	if self.rehearsalActive then -- 430
		return self.rehearsalRoute -- 432
	end -- 432
	if view.storyRoute == "soldier" then -- 432
		return "soldier" -- 435
	end -- 435
	if view.storyRoute == "child" then -- 435
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
	if storyRec ~= nil and storyRec.ending == "reunion" then -- 442
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
	if not keepIndoorDoorOpen then -- 456
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
	if contract ~= nil then -- 480
		contract:enterRehearsal(tag) -- 482
		contract:setMockRoute(route) -- 483
	end -- 483
	local isIndoor = (opts and opts.indoorRetry) == true -- 485
	self.sessionId = self.sessionId + 1 -- 486
	self:clearSequenceState(isIndoor) -- 487
	self.active = true -- 488
	self.doorClosedAfterRetry = false -- 489
	if isIndoor then -- 489
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 491
	end -- 491
	if (opts and opts.seekTime) ~= nil then -- 491
		self:seekRehearsal(opts.seekTime) -- 494
	end -- 494
end -- 472
function TowerEndingsPlugin.prototype.seekRehearsal(self, seconds) -- 499
	if not self.rehearsalActive then -- 499
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
	if not self.doorOpened and self.seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 512
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
	if contract ~= nil then -- 534
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
	if loaded == nil then -- 586
		return -- 588
	end -- 588
	local rawFe = loaded["watch.fe"] -- 590
	if rawFe ~= nil and type(rawFe) == "table" then -- 590
		local watchFe = rawFe -- 592
		if watchFe.towerEndings ~= self then -- 592
			watchFe.towerEndings = self -- 594
		end -- 594
	end -- 594
end -- 584
function TowerEndingsPlugin.prototype.onBindPlay(self, p, view) -- 601
	self:syncRuntimeHook() -- 602
	self.sessionId = self.sessionId + 1 -- 603
	self.loopsActive = false -- 604
	self.prevPhase = p.phase -- 605
	if self.rehearsalActive then -- 605
		return -- 608
	end -- 608
	local route = self:resolveRoute(p, view) -- 611
	local isTower = p.room.key == "tower" -- 612
	local alreadyIndoorPhase = isTower and (p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end") -- 613
	local sameRunIndoorRetry = isTower and self.lastRoomKey == "tower" and self.doorOpened and p.run == self.lastRunRef and route == self.activeRoute and (p.checkpoint > 0 or alreadyIndoorPhase) -- 619
	self.activeRoute = route -- 626
	self.lastRoomKey = p.room.key -- 627
	self.lastRunRef = p.run -- 628
	if not isTower then -- 628
		self:clearSequenceState(false) -- 631
		self.indoorRetryCount = 0 -- 632
		self.doorClosedAfterRetry = false -- 633
		return -- 634
	end -- 634
	if sameRunIndoorRetry or alreadyIndoorPhase then -- 634
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 639
		self.doorClosedAfterRetry = false -- 640
		self:clearSequenceState(true) -- 641
		if p.phase == "tower-end" then -- 641
			self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.divergeEndSec -- 643
			self:syncDerivedMilestones(self.seqElapsed, route) -- 644
		end -- 644
		return -- 646
	end -- 646
	self:clearSequenceState(false) -- 650
	self.indoorRetryCount = 0 -- 651
	self.doorClosedAfterRetry = false -- 652
end -- 601
function TowerEndingsPlugin.prototype.update(self, ctx) -- 655
	self:syncRuntimeHook() -- 656
	self.lastUiW = ctx.uiW -- 657
	self.lastUiH = ctx.uiH -- 658
	local p = ctx.p -- 659
	if not self.rehearsalActive and p.room.key ~= "tower" then -- 659
		if self.loopsActive then -- 659
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 663
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 664
			self.loopsActive = false -- 665
		end -- 665
		self.active = false -- 667
		return -- 668
	end -- 668
	local route = self:resolveRoute(p, ctx.view) -- 671
	self.activeRoute = route -- 672
	if not self.rehearsalActive then -- 672
		self:stepLiveSync(ctx, route) -- 675
	else -- 675
		self:stepRehearsal(ctx, route) -- 677
	end -- 677
	if not self.active then -- 677
		local inInteractiveHall = not self.rehearsalActive and p.room.key == "tower" and (p.phase == "tower-enter" or p.phase == "tower-desk") -- 681
		if self.loopsActive and not inInteractiveHall then -- 681
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 684
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 685
			self.loopsActive = false -- 686
		end -- 686
		return -- 688
	end -- 688
	if not ctx.paused and ctx.worldDt > 0 then -- 688
		self.animTime = self.animTime + ctx.worldDt -- 693
		self:syncDerivedMilestones(self.seqElapsed, route) -- 694
		self:syncAudioCues(ctx.audio, ctx, route) -- 695
		self:stepInputGuard(ctx.input) -- 696
	elseif not ctx.paused then -- 696
		self:syncDerivedMilestones(self.seqElapsed, route) -- 699
		self:stepInputGuard(ctx.input) -- 700
	end -- 700
	self.lastSubtitle = self:composeSubtitle(route) -- 703
end -- 655
function TowerEndingsPlugin.prototype.stepLiveSync(self, ctx, route) -- 706
	local p = ctx.p -- 707
	local phase = p.phase -- 708
	local justEnteredKnock = self.prevPhase ~= "tower-knock" and phase == "tower-knock" -- 709
	local justEnteredEnter = self.prevPhase ~= "tower-enter" and phase == "tower-enter" -- 710
	local justEnteredGiven = self.prevPhase ~= "tower-given" and phase == "tower-given" -- 711
	local justEnteredEnd = self.prevPhase ~= "tower-end" and phase == "tower-end" -- 712
	self.prevPhase = phase -- 713
	if phase == "tower-wait" then -- 713
		self.active = false -- 717
		return -- 718
	end -- 718
	if phase == "tower-enter" or phase == "tower-desk" then -- 718
		self.doorOpened = true -- 723
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 724
		if justEnteredEnter and self.indoorRetryCount == 0 and not ctx.paused then -- 724
			local tick = p.ticks -- 726
			self:playTowerOnce( -- 727
				ctx.audio, -- 727
				"reply1", -- 727
				"sfx", -- 727
				____exports.TOWER_AUDIO_FILES.reply1, -- 727
				0.78, -- 727
				"tower:reply:1", -- 727
				tick -- 727
			) -- 727
			self:playTowerOnce( -- 728
				ctx.audio, -- 728
				"reply2", -- 728
				"sfx", -- 728
				____exports.TOWER_AUDIO_FILES.reply2, -- 728
				0.8, -- 728
				"tower:reply:2", -- 728
				tick -- 728
			) -- 728
			self:playTowerOnce( -- 729
				ctx.audio, -- 729
				"door_open", -- 729
				"sfx", -- 729
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 729
				0.84, -- 729
				"tower:door_open", -- 729
				tick -- 729
			) -- 729
		end -- 729
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.doorOpenSec) -- 731
		self.active = false -- 732
		self:syncDerivedMilestones(self.seqElapsed, route) -- 733
		return -- 734
	end -- 734
	if not self.active then -- 734
		self.active = true -- 738
		self.staleInputMustRelease = ctx.input.interact.held or ctx.input.retry.held or ctx.input.interact.pressed -- 739
		self.confirmReady = false -- 740
	end -- 740
	if justEnteredKnock then -- 740
		self.seqElapsed = p.phaseTick / 60 -- 744
		self.holdElapsed = 0 -- 745
		self.staleInputMustRelease = true -- 746
		self.confirmReady = false -- 747
	elseif justEnteredGiven then -- 747
		self.doorOpened = true -- 749
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 750
	elseif justEnteredEnd then -- 750
		self.doorOpened = true -- 752
		self.seqElapsed = math.max(self.seqElapsed, 3.6) -- 754
	end -- 754
	if not ctx.paused and #ctx.events.rawEvents > 0 then -- 754
		local i = 0 -- 759
		do -- 759
			i = 0 -- 760
			while i < #ctx.events.rawEvents do -- 760
				local ev = ctx.events.rawEvents[i + 1] -- 761
				if ev.name == "knock" then -- 761
					local cnt = type(ev.data.count) == "number" and ev.data.count or self.knockCount + 1 -- 763
					if cnt >= 1 and self.knockCount < 1 then -- 763
						self.knockCount = 1 -- 765
						self:playTowerOnce( -- 766
							ctx.audio, -- 766
							"knock1", -- 766
							"sfx", -- 766
							____exports.TOWER_AUDIO_FILES.knock1, -- 766
							0.88, -- 766
							"tower:knock:1", -- 766
							ev.tick, -- 766
							ev.seq -- 766
						) -- 766
					end -- 766
					if cnt >= 2 and self.knockCount < 2 then -- 766
						self.knockCount = 2 -- 769
						self:playTowerOnce( -- 770
							ctx.audio, -- 770
							"knock2", -- 770
							"sfx", -- 770
							____exports.TOWER_AUDIO_FILES.knock2, -- 770
							0.9, -- 770
							"tower:knock:2", -- 770
							ev.tick, -- 770
							ev.seq -- 770
						) -- 770
					end -- 770
				end -- 770
				i = i + 1 -- 760
			end -- 760
		end -- 760
	end -- 760
	if not ctx.paused and ctx.worldDt > 0 then -- 760
		if phase == "tower-knock" then -- 760
			local backendSec = math.min(____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60) -- 779
			self.seqElapsed = math.max(self.seqElapsed + ctx.worldDt, backendSec) -- 780
			if self.seqElapsed > ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 then -- 780
				self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 -- 782
			end -- 782
		else -- 782
			self.seqElapsed = self.seqElapsed + ctx.worldDt -- 785
			if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 785
				self.holdElapsed = self.holdElapsed + ctx.worldDt -- 787
			end -- 787
		end -- 787
	end -- 787
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 787
		self.doorClosedAfterRetry = true -- 793
	end -- 793
	self:syncDerivedMilestones(self.seqElapsed, route) -- 795
end -- 706
function TowerEndingsPlugin.prototype.stepRehearsal(self, ctx, route) -- 798
	self.active = true -- 799
	if not ctx.paused and ctx.worldDt > 0 then -- 799
		self.seqElapsed = self.seqElapsed + ctx.worldDt -- 801
		if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 801
			self.holdElapsed = self.holdElapsed + ctx.worldDt -- 803
		end -- 803
	end -- 803
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 803
		self.doorClosedAfterRetry = true -- 807
	end -- 807
	self:syncDerivedMilestones(self.seqElapsed, route) -- 809
end -- 798
function TowerEndingsPlugin.prototype.syncDerivedMilestones(self, t, route) -- 812
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec and self.knockCount < 1 then -- 812
		self.knockCount = 1 -- 814
	end -- 814
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec and self.knockCount < 2 then -- 814
		self.knockCount = 2 -- 817
	end -- 817
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec and self.replyKnockCount < 1 then -- 817
		self.replyKnockCount = 1 -- 820
	end -- 820
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec and self.replyKnockCount < 2 then -- 820
		self.replyKnockCount = 2 -- 823
	end -- 823
	if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 823
		self.doorOpened = true -- 826
	end -- 826
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec and not self.row1Written then -- 826
		self.row1Written = true -- 830
		self.registryAppendCount = self.registryAppendCount + 1 -- 831
	end -- 831
	if route == "soldier" and t >= 4.6 and not self.row2Written then -- 831
		self.row2Written = true -- 834
		self.registryAppendCount = self.registryAppendCount + 1 -- 835
	end -- 835
	if route == "child" and self.row2Written then -- 835
		self.row2Written = false -- 839
		self.registryAppendCount = self.row1Written and 1 or 0 -- 840
	end -- 840
end -- 812
function TowerEndingsPlugin.prototype.stepInputGuard(self, input) -- 844
	local keyHeld = input.interact.held or input.retry.held -- 845
	local keyPressed = input.interact.pressed or input.retry.pressed -- 846
	local readyTime = self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 847
	if self.staleInputMustRelease then -- 847
		if not keyHeld then -- 847
			self.staleInputMustRelease = false -- 851
		elseif keyPressed then -- 851
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 853
		end -- 853
		self.confirmReady = false -- 855
		return -- 856
	end -- 856
	if not readyTime then -- 856
		if keyPressed then -- 856
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 861
			self.staleInputMustRelease = keyHeld -- 862
		end -- 862
		self.confirmReady = false -- 864
		return -- 865
	end -- 865
	self.confirmReady = true -- 868
	if self.rehearsalActive and keyPressed then -- 868
		self.rehearsalAcknowledged = true -- 870
	end -- 870
end -- 844
function TowerEndingsPlugin.prototype.playTowerOnce(self, audio, tag, track, path, volume, cueId, tick, seq) -- 874
	if seq == nil then -- 874
		seq = -1 -- 882
	end -- 882
	local dedupeKey = (("tower:s" .. tostring(self.sessionId)) .. ":") .. tag -- 884
	audio:playOnce( -- 885
		dedupeKey, -- 885
		track, -- 885
		path, -- 885
		volume, -- 885
		cueId, -- 885
		tick, -- 885
		seq -- 885
	) -- 885
end -- 874
function TowerEndingsPlugin.prototype.syncAudioCues(self, audio, ctx, route) -- 888
	local t = self.seqElapsed -- 889
	local tick = ctx.p.ticks -- 890
	local indoorK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.5, t) -- 891
	self.loopsActive = true -- 894
	audio:playLoop( -- 895
		"tower_wind_cold", -- 895
		"wind", -- 895
		____exports.TOWER_AUDIO_FILES.windCold, -- 895
		lerp(0.36, 0.14, indoorK), -- 895
		tick -- 895
	) -- 895
	if indoorK > 0.05 then -- 895
		audio:playLoop( -- 897
			"tower_room_warm", -- 897
			"ambience", -- 897
			____exports.TOWER_AUDIO_FILES.roomWarm, -- 897
			lerp(0.06, 0.34, indoorK), -- 897
			tick -- 897
		) -- 897
	end -- 897
	if self.indoorRetryCount == 0 then -- 897
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec then -- 897
			self:playTowerOnce( -- 903
				audio, -- 903
				"knock1", -- 903
				"sfx", -- 903
				____exports.TOWER_AUDIO_FILES.knock1, -- 903
				0.88, -- 903
				"tower:knock:1", -- 903
				tick -- 903
			) -- 903
		end -- 903
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec then -- 903
			self:playTowerOnce( -- 906
				audio, -- 906
				"knock2", -- 906
				"sfx", -- 906
				____exports.TOWER_AUDIO_FILES.knock2, -- 906
				0.9, -- 906
				"tower:knock:2", -- 906
				tick -- 906
			) -- 906
		end -- 906
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 906
			self:playTowerOnce( -- 909
				audio, -- 909
				"reply1", -- 909
				"sfx", -- 909
				____exports.TOWER_AUDIO_FILES.reply1, -- 909
				0.78, -- 909
				"tower:reply:1", -- 909
				tick -- 909
			) -- 909
		end -- 909
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec then -- 909
			self:playTowerOnce( -- 912
				audio, -- 912
				"reply2", -- 912
				"sfx", -- 912
				____exports.TOWER_AUDIO_FILES.reply2, -- 912
				0.8, -- 912
				"tower:reply:2", -- 912
				tick -- 912
			) -- 912
		end -- 912
		if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 912
			self:playTowerOnce( -- 915
				audio, -- 915
				"door_open", -- 915
				"sfx", -- 915
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 915
				0.84, -- 915
				"tower:door_open", -- 915
				tick -- 915
			) -- 915
		end -- 915
	end -- 915
	if t >= 1.5 then -- 915
		self:playTowerOnce( -- 920
			audio, -- 920
			"book_open", -- 920
			"sfx", -- 920
			____exports.TOWER_AUDIO_FILES.bookOpen, -- 920
			0.82, -- 920
			"tower:book_open", -- 920
			tick -- 920
		) -- 920
	end -- 920
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 920
		self:playTowerOnce( -- 923
			audio, -- 923
			"brush1", -- 923
			"sfx", -- 923
			____exports.TOWER_AUDIO_FILES.brush1, -- 923
			0.8, -- 923
			"tower:brush:row1", -- 923
			tick -- 923
		) -- 923
	end -- 923
	if route == "child" then -- 923
		if t >= 4.35 then -- 923
			self:playTowerOnce( -- 928
				audio, -- 928
				"f03_line", -- 928
				"voice", -- 928
				____exports.TOWER_AUDIO_FILES.lineXiaomanLamp, -- 928
				0.86, -- 928
				"tower:f03:line_lamp", -- 928
				tick -- 928
			) -- 928
		end -- 928
		if t >= 4.45 then -- 928
			self:playTowerOnce( -- 931
				audio, -- 931
				"f03_bowl", -- 931
				"sfx", -- 931
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 931
				0.8, -- 931
				"tower:bowl_set", -- 931
				tick -- 931
			) -- 931
		end -- 931
		if t >= 5.2 then -- 931
			self:playTowerOnce( -- 934
				audio, -- 934
				"f03_lamp", -- 934
				"sfx", -- 934
				____exports.TOWER_AUDIO_FILES.lampMove, -- 934
				0.82, -- 934
				"tower:f03:lamp_move", -- 934
				tick -- 934
			) -- 934
		end -- 934
	else -- 934
		if t >= 4.28 then -- 934
			self:playTowerOnce( -- 938
				audio, -- 938
				"m03_line", -- 938
				"voice", -- 938
				____exports.TOWER_AUDIO_FILES.lineZhoushuName, -- 938
				0.9, -- 938
				"tower:m03:line_name", -- 938
				tick -- 938
			) -- 938
		end -- 938
		if t >= 4.62 then -- 938
			self:playTowerOnce( -- 941
				audio, -- 941
				"brush2", -- 941
				"sfx", -- 941
				____exports.TOWER_AUDIO_FILES.brush2, -- 941
				0.82, -- 941
				"tower:brush:row2", -- 941
				tick -- 941
			) -- 941
		end -- 941
		if t >= 5.55 then -- 941
			self:playTowerOnce( -- 944
				audio, -- 944
				"m03_needle", -- 944
				"sfx", -- 944
				____exports.TOWER_AUDIO_FILES.needlePlace, -- 944
				0.8, -- 944
				"tower:m03:needle_place", -- 944
				tick -- 944
			) -- 944
		end -- 944
		if t >= 6.02 then -- 944
			self:playTowerOnce( -- 947
				audio, -- 947
				"m03_bowl", -- 947
				"sfx", -- 947
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 947
				0.82, -- 947
				"tower:bowl_set", -- 947
				tick -- 947
			) -- 947
		end -- 947
	end -- 947
end -- 888
function TowerEndingsPlugin.prototype.composeSubtitle(self, route) -- 952
	local t = self.seqElapsed -- 953
	if t < ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 953
		return "[两下轻敲]  门外厚木上传来两声轻敲。" -- 955
	end -- 955
	if t < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 955
		return "[门内回敲]  静默一息，门后轻轻回敲两声。" -- 958
	end -- 958
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 958
		return route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 961
	end -- 961
	if t < ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 961
		return route == "child" and "她把针套与纸条摊在案前，守卒展开收籍末页。" or "两人站在值夜室内，守卒摊开收籍末页。" -- 966
	end -- 966
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 966
		return "守卒蘸墨提笔，在第一行写下「小满」。" -- 971
	end -- 971
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 971
		return "笔尖停在第二行上方。" -- 974
	end -- 974
	if route == "child" then -- 974
		if t < 6.7 then -- 974
			return F03_DIALOGUE -- 978
		end -- 978
		return "" -- 980
	end -- 980
	if t < 5.45 then -- 980
		return M03_DIALOGUE -- 983
	end -- 983
	if t < 6.85 then -- 983
		return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。" -- 986
	end -- 986
	return "" -- 988
end -- 952
function TowerEndingsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 993
	if not self.active then -- 993
		return false -- 1001
	end -- 1001
	local route = self.activeRoute -- 1004
	local t = self.seqElapsed -- 1005
	local lampProg = route == "child" and smoothstep(5.2, 6.75, t) or 0 -- 1006
	local scaled = computeScaledAnchors(ctx.uiW, ctx.uiH, lampProg) -- 1007
	local s = scaled.s -- 1008
	local ox = scaled.ox -- 1009
	local oy = scaled.oy -- 1010
	uiDraw:drawRect( -- 1013
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1013
		Color(8, 10, 16, 255) -- 1013
	) -- 1013
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1013
		self:drawAct1PorchAndDoor( -- 1017
			uiDraw, -- 1017
			uiInkDraw, -- 1017
			uiArt, -- 1017
			uiGlow, -- 1017
			ctx, -- 1017
			route, -- 1017
			s, -- 1017
			ox, -- 1017
			oy -- 1017
		) -- 1017
		local fadeOut = smoothstep(1.22, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec, t) -- 1019
		if fadeOut > 0.01 then -- 1019
			uiInkDraw:drawRect( -- 1021
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1021
				Color( -- 1021
					8, -- 1021
					10, -- 1021
					16, -- 1021
					math.floor(230 * fadeOut + 0.5) -- 1021
				) -- 1021
			) -- 1021
		end -- 1021
	else -- 1021
		self:drawAct2And3Guardroom( -- 1025
			uiDraw, -- 1025
			uiInkDraw, -- 1025
			uiArt, -- 1025
			uiGlow, -- 1025
			ctx, -- 1025
			route, -- 1025
			lampProg, -- 1025
			s, -- 1025
			ox, -- 1025
			oy -- 1025
		) -- 1025
		local fadeIn = 1 - smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.24, t) -- 1026
		if fadeIn > 0.01 then -- 1026
			uiInkDraw:drawRect( -- 1028
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1028
				Color( -- 1028
					8, -- 1028
					10, -- 1028
					16, -- 1028
					math.floor(220 * fadeIn + 0.5) -- 1028
				) -- 1028
			) -- 1028
		end -- 1028
	end -- 1028
	local barH = math.floor(____exports.TOWER_SHOT_LAYOUT.letterboxH * s + 0.5) -- 1033
	uiInkDraw:drawRect( -- 1034
		Rect(0, ctx.uiH - barH, ctx.uiW, barH), -- 1034
		Color(7, 9, 14, 248) -- 1034
	) -- 1034
	uiInkDraw:drawRect( -- 1035
		Rect(0, 0, ctx.uiW, barH), -- 1035
		Color(7, 9, 14, 248) -- 1035
	) -- 1035
	uiInkDraw:drawSegment( -- 1036
		Vec2(0, ctx.uiH - barH), -- 1036
		Vec2(ctx.uiW, ctx.uiH - barH), -- 1036
		0.9, -- 1036
		toColor(PALETTE.silkDim, 82) -- 1036
	) -- 1036
	uiInkDraw:drawSegment( -- 1037
		Vec2(0, barH), -- 1037
		Vec2(ctx.uiW, barH), -- 1037
		0.9, -- 1037
		toColor(PALETTE.silkDim, 82) -- 1037
	) -- 1037
	self:drawDialogueSubtitle( -- 1040
		uiDraw, -- 1040
		uiInkDraw, -- 1040
		uiArt, -- 1040
		ctx, -- 1040
		route, -- 1040
		s, -- 1040
		barH -- 1040
	) -- 1040
	return true -- 1042
end -- 993
function TowerEndingsPlugin.prototype.drawAct1PorchAndDoor(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1047
	local t = self.seqElapsed -- 1058
	local isLowpoly = route == "child" -- 1059
	local openK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, 1.24, t) -- 1060
	local doorCx = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s -- 1061
	local threshY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s -- 1062
	local doorW = ____exports.TOWER_SHOT_LAYOUT.doorW * s -- 1063
	local doorH = ____exports.TOWER_SHOT_LAYOUT.doorH * s -- 1064
	local doorL = doorCx - doorW * 0.5 -- 1065
	local doorR = doorCx + doorW * 0.5 -- 1066
	local k1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock1Sec) / 0.055) ^ 2) -- 1069
	local k2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock2Sec) / 0.055) ^ 2) -- 1070
	local r1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply1Sec) / 0.06) ^ 2) -- 1071
	local r2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply2Sec) / 0.06) ^ 2) -- 1072
	local doorShakeX = (k1Pulse + k2Pulse) * 2.4 * s * math.sin(t * 95) + (r1Pulse + r2Pulse) * 1.4 * s * math.sin(t * 80) -- 1073
	if isLowpoly then -- 1073
		local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, openK * 0.62) -- 1078
		fillVGradRect( -- 1079
			uiDraw, -- 1080
			0, -- 1080
			0, -- 1080
			ctx.uiW, -- 1080
			ctx.uiH, -- 1080
			Color(12, 16, 26, 255), -- 1081
			Color(20, 28, 44, 255) -- 1082
		) -- 1082
		local wallCol = shadeSurface( -- 1085
			MING_MATERIALS.mingBrickDark.base, -- 1085
			vec3(0, 0, -1), -- 1085
			24, -- 1085
			1, -- 1085
			light, -- 1085
			MING_MATERIALS.mingBrickDark -- 1085
		) -- 1085
		local jambCol = shadeSurface( -- 1086
			MING_MATERIALS.mingBrick.base, -- 1086
			vec3(0.75, 0.15, -0.64), -- 1086
			10, -- 1086
			1, -- 1086
			light, -- 1086
			MING_MATERIALS.mingBrick -- 1086
		) -- 1086
		local jambRCol = shadeSurface( -- 1087
			MING_MATERIALS.mingBrick.base, -- 1087
			vec3(-0.75, 0.15, -0.64), -- 1087
			10, -- 1087
			1, -- 1087
			light, -- 1087
			MING_MATERIALS.mingBrick -- 1087
		) -- 1087
		local lintelCol = shadeSurface( -- 1088
			MING_MATERIALS.mingStoneStep.base, -- 1088
			vec3(0, -0.55, -0.83), -- 1088
			6, -- 1088
			1, -- 1088
			light, -- 1088
			MING_MATERIALS.mingStoneStep -- 1088
		) -- 1088
		local stepCol = shadeSurface( -- 1089
			MING_MATERIALS.mingStoneStep.base, -- 1089
			vec3(0, 0.92, -0.39), -- 1089
			0, -- 1089
			1, -- 1089
			light, -- 1089
			MING_MATERIALS.mingStoneStep -- 1089
		) -- 1089
		uiDraw:drawRect( -- 1091
			Rect(0, threshY, doorL - 26 * s, ctx.uiH - threshY), -- 1091
			toColor(wallCol) -- 1091
		) -- 1091
		uiDraw:drawRect( -- 1092
			Rect(doorR + 26 * s, threshY, ctx.uiW - (doorR + 26 * s), ctx.uiH - threshY), -- 1092
			toColor(wallCol) -- 1092
		) -- 1092
		uiDraw:drawPolygon( -- 1094
			{ -- 1094
				Vec2(doorL - 26 * s, threshY), -- 1095
				Vec2(doorL, threshY + 12 * s), -- 1096
				Vec2(doorL, threshY + doorH - 8 * s), -- 1097
				Vec2(doorL - 26 * s, threshY + doorH + 18 * s) -- 1098
			}, -- 1098
			toColor(jambCol), -- 1099
			1, -- 1099
			toColor(PALETTE.silkDim, 68) -- 1099
		) -- 1099
		uiDraw:drawPolygon( -- 1100
			{ -- 1100
				Vec2(doorR + 26 * s, threshY), -- 1101
				Vec2(doorR, threshY + 12 * s), -- 1102
				Vec2(doorR, threshY + doorH - 8 * s), -- 1103
				Vec2(doorR + 26 * s, threshY + doorH + 18 * s) -- 1104
			}, -- 1104
			toColor(jambRCol), -- 1105
			1, -- 1105
			toColor(PALETTE.silkDim, 68) -- 1105
		) -- 1105
		uiDraw:drawPolygon( -- 1107
			{ -- 1107
				Vec2(doorL - 44 * s, threshY + doorH + 18 * s), -- 1108
				Vec2(doorR + 44 * s, threshY + doorH + 18 * s), -- 1109
				Vec2(doorR + 58 * s, threshY + doorH + 92 * s), -- 1110
				Vec2(doorL - 58 * s, threshY + doorH + 92 * s) -- 1111
			}, -- 1111
			toColor(lintelCol), -- 1112
			1.1, -- 1112
			toColor(STONE_EDGE_FALLBACK, 130) -- 1112
		) -- 1112
		uiDraw:drawRect( -- 1114
			Rect(0, 0, ctx.uiW, threshY), -- 1114
			Color(16, 20, 30, 255) -- 1114
		) -- 1114
		uiDraw:drawPolygon( -- 1115
			{ -- 1115
				Vec2(doorL - 58 * s, threshY - 20 * s), -- 1116
				Vec2(doorR + 58 * s, threshY - 20 * s), -- 1117
				Vec2(doorR + 28 * s, threshY + 12 * s), -- 1118
				Vec2(doorL - 28 * s, threshY + 12 * s) -- 1119
			}, -- 1119
			toColor(stepCol), -- 1120
			1, -- 1120
			toColor(STONE_EDGE_FALLBACK, 150) -- 1120
		) -- 1120
		uiDraw:drawPolygon( -- 1122
			{ -- 1122
				Vec2(0, 0), -- 1123
				Vec2(142 * s, 0), -- 1124
				Vec2(114 * s, ctx.uiH), -- 1125
				Vec2(0, ctx.uiH) -- 1126
			}, -- 1126
			Color(10, 14, 22, 220) -- 1127
		) -- 1127
		uiDraw:drawPolygon( -- 1128
			{ -- 1128
				Vec2(ctx.uiW - 142 * s, 0), -- 1129
				Vec2(ctx.uiW, 0), -- 1130
				Vec2(ctx.uiW, ctx.uiH), -- 1131
				Vec2(ctx.uiW - 114 * s, ctx.uiH) -- 1132
			}, -- 1132
			Color(10, 14, 22, 220) -- 1133
		) -- 1133
	else -- 1133
		fillVGradRect( -- 1136
			uiDraw, -- 1137
			0, -- 1137
			0, -- 1137
			ctx.uiW, -- 1137
			ctx.uiH, -- 1137
			Color(18, 22, 32, 255), -- 1138
			Color(32, 38, 52, 255) -- 1139
		) -- 1139
		uiDraw:drawPolygon( -- 1142
			{ -- 1142
				Vec2(0, threshY), -- 1143
				Vec2(doorL, threshY), -- 1144
				Vec2(doorL, threshY + 188 * s), -- 1145
				Vec2(doorL * 0.55, threshY + 230 * s), -- 1146
				Vec2(doorL * 0.22, threshY + 172 * s), -- 1147
				Vec2(0, threshY + 196 * s) -- 1148
			}, -- 1148
			Color(26, 30, 40, 235) -- 1149
		) -- 1149
		uiDraw:drawPolygon( -- 1150
			{ -- 1150
				Vec2(doorR, threshY), -- 1151
				Vec2(ctx.uiW, threshY), -- 1152
				Vec2(ctx.uiW, threshY + 218 * s), -- 1153
				Vec2(doorR + (ctx.uiW - doorR) * 0.56, threshY + 248 * s), -- 1154
				Vec2(doorR, threshY + 178 * s) -- 1155
			}, -- 1155
			Color(26, 30, 40, 235) -- 1156
		) -- 1156
		uiDraw:drawRect( -- 1158
			Rect(0, threshY, doorL, ctx.uiH - threshY), -- 1158
			Color(54, 56, 62, 255), -- 1158
			1, -- 1158
			Color(88, 90, 96, 155) -- 1158
		) -- 1158
		uiDraw:drawRect( -- 1159
			Rect(doorR, threshY, ctx.uiW - doorR, ctx.uiH - threshY), -- 1159
			Color(54, 56, 62, 255), -- 1159
			1, -- 1159
			Color(88, 90, 96, 155) -- 1159
		) -- 1159
		uiDraw:drawRect( -- 1160
			Rect(doorL - 28 * s, threshY + doorH, doorW + 56 * s, 68 * s), -- 1160
			Color(72, 68, 62, 255), -- 1160
			1, -- 1160
			Color(124, 114, 100, 175) -- 1160
		) -- 1160
		local row = 0 -- 1161
		do -- 1161
			row = 0 -- 1162
			while row < 10 do -- 1162
				local by = threshY + row * 46 * s -- 1163
				uiDraw:drawSegment( -- 1164
					Vec2(0, by), -- 1164
					Vec2(doorL, by), -- 1164
					1, -- 1164
					Color(34, 36, 42, 175) -- 1164
				) -- 1164
				uiDraw:drawSegment( -- 1165
					Vec2(doorR, by), -- 1165
					Vec2(ctx.uiW, by), -- 1165
					1, -- 1165
					Color(34, 36, 42, 175) -- 1165
				) -- 1165
				local stag = row % 2 * 34 * s -- 1166
				local col = 0 -- 1167
				do -- 1167
					col = 0 -- 1168
					while col < 7 do -- 1168
						local lx = stag + col * 68 * s -- 1169
						if lx > 4 * s and lx < doorL - 4 * s then -- 1169
							uiDraw:drawSegment( -- 1171
								Vec2(lx, by), -- 1171
								Vec2(lx, by + 46 * s), -- 1171
								0.9, -- 1171
								Color(36, 38, 44, 130) -- 1171
							) -- 1171
						end -- 1171
						local rx = doorR + stag + col * 68 * s -- 1173
						if rx > doorR + 4 * s and rx < ctx.uiW - 4 * s then -- 1173
							uiDraw:drawSegment( -- 1175
								Vec2(rx, by), -- 1175
								Vec2(rx, by + 46 * s), -- 1175
								0.9, -- 1175
								Color(36, 38, 44, 130) -- 1175
							) -- 1175
						end -- 1175
						col = col + 1 -- 1168
					end -- 1168
				end -- 1168
				row = row + 1 -- 1162
			end -- 1162
		end -- 1162
		uiDraw:drawRect( -- 1180
			Rect(0, 0, ctx.uiW, threshY), -- 1180
			Color(28, 26, 28, 255) -- 1180
		) -- 1180
		uiDraw:drawRect( -- 1181
			Rect(doorL - 36 * s, threshY - 12 * s, doorW + 72 * s, 22 * s), -- 1181
			Color(96, 94, 92, 255), -- 1181
			1, -- 1181
			Color(156, 152, 144, 175) -- 1181
		) -- 1181
	end -- 1181
	local innerWarm = 0.22 + openK * 0.78 + (r1Pulse + r2Pulse) * 0.14 -- 1185
	fillVGradRect( -- 1186
		uiDraw, -- 1187
		doorL, -- 1187
		threshY + 8 * s, -- 1187
		doorW, -- 1187
		doorH - 8 * s, -- 1187
		Color( -- 1188
			46, -- 1188
			32, -- 1188
			20, -- 1188
			math.floor(255 * math.min(1, innerWarm + 0.15) + 0.5) -- 1188
		), -- 1188
		Color( -- 1189
			118, -- 1189
			82, -- 1189
			42, -- 1189
			math.floor(255 * math.min(1, innerWarm) + 0.5) -- 1189
		) -- 1189
	) -- 1189
	local leafW = math.max(26 * s, doorW * (1 - openK * 0.76)) -- 1193
	local leafX = doorL + doorShakeX * (1 - openK) -- 1194
	local woodCol = isLowpoly and toColor(shadeSurface( -- 1195
		MING_MATERIALS.mingTimberDark.base, -- 1196
		vec3(-0.2, 0.25, -0.95), -- 1196
		4, -- 1196
		1, -- 1196
		TOWER_WEST_LAMP_LIGHT, -- 1196
		MING_MATERIALS.mingTimberDark -- 1196
	)) or Color(76, 54, 38, 255) -- 1196
	uiDraw:drawRect( -- 1198
		Rect(leafX, threshY + 12 * s, leafW, doorH - 14 * s), -- 1199
		woodCol, -- 1200
		1.4, -- 1201
		Color(138, 106, 74, 185) -- 1202
	) -- 1202
	local planks = 4 -- 1205
	local pi = 1 -- 1206
	do -- 1206
		pi = 1 -- 1207
		while pi < planks do -- 1207
			local px = leafX + leafW * pi / planks -- 1208
			uiDraw:drawSegment( -- 1209
				Vec2(px, threshY + 14 * s), -- 1209
				Vec2(px, threshY + doorH - 4 * s), -- 1209
				1.1, -- 1209
				Color(38, 26, 18, 185) -- 1209
			) -- 1209
			pi = pi + 1 -- 1207
		end -- 1207
	end -- 1207
	uiDraw:drawRect( -- 1211
		Rect(leafX + 4 * s, threshY + doorH * 0.24, leafW - 8 * s, 10 * s), -- 1211
		Color(54, 38, 26, 225) -- 1211
	) -- 1211
	uiDraw:drawRect( -- 1212
		Rect(leafX + 4 * s, threshY + doorH * 0.74, leafW - 8 * s, 10 * s), -- 1212
		Color(54, 38, 26, 225) -- 1212
	) -- 1212
	local ringX = leafX + leafW * 0.72 -- 1214
	local ringY = threshY + doorH * 0.56 -- 1215
	uiDraw:drawRect( -- 1216
		Rect(ringX - 6 * s, ringY + 4 * s, 12 * s, 12 * s), -- 1216
		Color(42, 46, 52, 235), -- 1216
		1, -- 1216
		Color(96, 100, 108, 170) -- 1216
	) -- 1216
	strokeEllipse( -- 1217
		uiDraw, -- 1217
		ringX, -- 1217
		ringY - 2 * s, -- 1217
		8 * s, -- 1217
		9 * s, -- 1217
		1.8 * s, -- 1217
		Color(108, 112, 118, 195), -- 1217
		16 -- 1217
	) -- 1217
	local seamGlowA = math.floor(92 + openK * 145 + (r1Pulse + r2Pulse) * 48 + 0.5) -- 1220
	fillRadialGlow( -- 1221
		uiGlow, -- 1222
		doorCx + openK * 24 * s, -- 1222
		threshY + 14 * s, -- 1222
		(92 + openK * 120) * s, -- 1223
		(26 + openK * 58) * s, -- 1223
		Color( -- 1224
			246, -- 1224
			204, -- 1224
			134, -- 1224
			math.min(220, seamGlowA) -- 1224
		), -- 1224
		Color(220, 156, 72, 0), -- 1225
		18 -- 1226
	) -- 1226
	local kx = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s -- 1230
	local ky = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s -- 1231
	if k1Pulse > 0.08 or k2Pulse > 0.08 then -- 1231
		local amp = math.max(k1Pulse, k2Pulse) -- 1233
		local r = (18 + (1 - amp) * 34) * s -- 1234
		strokeEllipse( -- 1235
			uiInkDraw, -- 1235
			kx + 24 * s, -- 1235
			ky, -- 1235
			r, -- 1235
			r * 0.85, -- 1235
			1.8 * s, -- 1235
			toColor( -- 1235
				PALETTE.amberCore, -- 1235
				math.floor(210 * amp + 0.5) -- 1235
			), -- 1235
			24 -- 1235
		) -- 1235
	end -- 1235
	if r1Pulse > 0.08 or r2Pulse > 0.08 then -- 1235
		local amp = math.max(r1Pulse, r2Pulse) -- 1238
		local r = (24 + (1 - amp) * 42) * s -- 1239
		strokeEllipse( -- 1240
			uiInkDraw, -- 1240
			doorCx + 30 * s, -- 1240
			ky + 16 * s, -- 1240
			r, -- 1240
			r * 0.9, -- 1240
			1.6 * s, -- 1240
			toColor( -- 1240
				PALETTE.amber, -- 1240
				math.floor(185 * amp + 0.5) -- 1240
			), -- 1240
			24 -- 1240
		) -- 1240
	end -- 1240
	if openK > 0.05 then -- 1240
		local lanX = ox + ____exports.TOWER_SHOT_LAYOUT.doorLanternX * s + (1 - openK) * 42 * s -- 1245
		local lanY = oy + ____exports.TOWER_SHOT_LAYOUT.doorLanternY * s -- 1246
		uiInkDraw:drawPolygon( -- 1248
			{ -- 1248
				Vec2(lanX + 76 * s, lanY + 42 * s), -- 1249
				Vec2(lanX + 12 * s, lanY + 34 * s), -- 1250
				Vec2(lanX + 8 * s, lanY + 12 * s), -- 1251
				Vec2(lanX + 78 * s, lanY + 12 * s) -- 1252
			}, -- 1252
			Color( -- 1253
				54, -- 1253
				48, -- 1253
				44, -- 1253
				math.floor(240 * openK + 0.5) -- 1253
			), -- 1253
			1, -- 1253
			Color( -- 1253
				98, -- 1253
				86, -- 1253
				74, -- 1253
				math.floor(180 * openK + 0.5) -- 1253
			) -- 1253
		) -- 1253
		self:drawMingLantern( -- 1254
			uiInkDraw, -- 1254
			uiGlow, -- 1254
			lanX, -- 1254
			lanY - 14 * s, -- 1254
			1.08 * s, -- 1254
			openK, -- 1254
			1 -- 1254
		) -- 1254
		fillRadialGlow( -- 1256
			uiGlow, -- 1257
			kx + 12 * s, -- 1257
			ky - 14 * s, -- 1257
			148 * s, -- 1258
			128 * s, -- 1258
			Color( -- 1259
				246, -- 1259
				208, -- 1259
				142, -- 1259
				math.floor(98 * openK + 0.5) -- 1259
			), -- 1259
			Color(232, 174, 92, 0), -- 1260
			18 -- 1261
		) -- 1261
	end -- 1261
	local stepInX = openK * 44 * s -- 1266
	local xiaomanX = doorCx - 66 * s + stepInX -- 1267
	local xiaomanY = threshY - 2 * s -- 1268
	uiDraw:drawEllipse( -- 1270
		Vec2(xiaomanX, xiaomanY + 2 * s), -- 1270
		34 * s, -- 1270
		8 * s, -- 1270
		Color(4, 6, 12, 190) -- 1270
	) -- 1270
	local childSlot = (k1Pulse > 0.25 or k2Pulse > 0.25) and "child_knock" or (openK > 0.45 and "child_offer" or "child_idle") -- 1271
	uiArt:tryPlace( -- 1272
		childSlot, -- 1272
		"fe05_porch_child", -- 1272
		xiaomanX, -- 1272
		xiaomanY, -- 1272
		108 * s, -- 1272
		148 * s, -- 1272
		{facing = 1, opacity = 0.98, layer = 2} -- 1272
	) -- 1272
	if openK > 0.15 then -- 1272
		local wristX = xiaomanX + 22 * s -- 1277
		local wristY = xiaomanY + 76 * s -- 1278
		uiInkDraw:drawRect( -- 1279
			Rect(wristX - 7 * s, wristY - 5 * s, 14 * s, 11 * s), -- 1280
			Color( -- 1281
				142, -- 1281
				118, -- 1281
				84, -- 1281
				math.floor(245 * openK + 0.5) -- 1281
			), -- 1281
			1, -- 1282
			Color( -- 1283
				222, -- 1283
				192, -- 1283
				128, -- 1283
				math.floor(235 * openK + 0.5) -- 1283
			) -- 1283
		) -- 1283
		uiInkDraw:drawSegment( -- 1285
			Vec2(wristX - 8 * s, wristY), -- 1286
			Vec2(wristX + 8 * s, wristY + 2 * s), -- 1287
			2 * s, -- 1288
			toColor( -- 1289
				CUFF_PALETTE.childCord, -- 1289
				math.floor(240 * openK + 0.5) -- 1289
			) -- 1289
		) -- 1289
	end -- 1289
	if route == "soldier" then -- 1289
		local zhouX = xiaomanX - 72 * s -- 1295
		local zhouY = threshY - 2 * s -- 1296
		uiDraw:drawEllipse( -- 1297
			Vec2(zhouX, zhouY + 2 * s), -- 1297
			42 * s, -- 1297
			9 * s, -- 1297
			Color(4, 6, 12, 190) -- 1297
		) -- 1297
		uiArt:tryPlace( -- 1298
			"soldier_idle", -- 1298
			"fe05_porch_soldier", -- 1298
			zhouX, -- 1298
			zhouY, -- 1298
			146 * s, -- 1298
			206 * s, -- 1298
			{facing = 1, opacity = 0.98, layer = 2} -- 1298
		) -- 1298
		local handMidX = (zhouX + xiaomanX) * 0.5 + 4 * s -- 1302
		local handMidY = threshY + 66 * s -- 1303
		uiInkDraw:drawSegment( -- 1304
			Vec2(zhouX + 20 * s, threshY + 106 * s), -- 1305
			Vec2(handMidX - 2 * s, handMidY), -- 1306
			6.2 * s, -- 1307
			toColor(CUFF_PALETTE.indigoBase, 245) -- 1308
		) -- 1308
		uiInkDraw:drawSegment( -- 1310
			Vec2(handMidX - 9 * s, handMidY + 9 * s), -- 1311
			Vec2(handMidX - 3 * s, handMidY + 13 * s), -- 1312
			1.9 * s, -- 1313
			toColor(CUFF_PALETTE.stitchThread, 240) -- 1314
		) -- 1314
		uiInkDraw:drawSegment( -- 1316
			Vec2(xiaomanX - 14 * s, threshY + 78 * s), -- 1317
			Vec2(handMidX + 2 * s, handMidY), -- 1318
			4.8 * s, -- 1319
			toColor(CUFF_PALETTE.childSleeve, 245) -- 1320
		) -- 1320
		uiInkDraw:drawDot( -- 1322
			Vec2(handMidX, handMidY), -- 1322
			4.8 * s, -- 1322
			toColor(CUFF_PALETTE.skinLight, 245) -- 1322
		) -- 1322
	end -- 1322
end -- 1047
function TowerEndingsPlugin.prototype.drawAct2And3Guardroom(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy) -- 1328
	local t = self.seqElapsed -- 1340
	local isLowpoly = route == "child" -- 1341
	local deskY = oy + ____exports.TOWER_SHOT_LAYOUT.deskTopY * s -- 1342
	if isLowpoly then -- 1342
		self:drawF03LowpolyRoomAndWindow( -- 1346
			uiDraw, -- 1346
			uiGlow, -- 1346
			ctx, -- 1346
			lampProg, -- 1346
			s, -- 1346
			ox, -- 1346
			oy -- 1346
		) -- 1346
	else -- 1346
		self:drawM03PixelRoomAndWindow( -- 1348
			uiDraw, -- 1348
			uiArt, -- 1348
			uiGlow, -- 1348
			ctx, -- 1348
			s, -- 1348
			ox, -- 1348
			oy -- 1348
		) -- 1348
	end -- 1348
	local deskTopCol = isLowpoly and toColor(shadeSurface( -- 1352
		MING_MATERIALS.mingTimber.base, -- 1354
		vec3(-0.25, 0.9, -0.35), -- 1355
		0, -- 1356
		1, -- 1357
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1358
		MING_MATERIALS.mingTimber -- 1359
	)) or Color(86, 60, 42, 255) -- 1359
	local deskFrontCol = isLowpoly and toColor(shadeSurface( -- 1362
		MING_MATERIALS.mingTimberDark.base, -- 1364
		vec3(0, 0.1, -0.99), -- 1365
		-4, -- 1365
		1, -- 1367
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1368
		MING_MATERIALS.mingTimberDark -- 1369
	)) or Color(52, 36, 26, 255) -- 1369
	uiDraw:drawPolygon( -- 1374
		{ -- 1374
			Vec2(0, deskY - 120 * s), -- 1375
			Vec2(ctx.uiW, deskY - 120 * s), -- 1376
			Vec2(ctx.uiW, deskY + 42 * s), -- 1377
			Vec2(0, deskY + 42 * s) -- 1378
		}, -- 1378
		deskTopCol -- 1379
	) -- 1379
	uiDraw:drawRect( -- 1380
		Rect(0, 0, ctx.uiW, deskY - 118 * s), -- 1380
		deskFrontCol -- 1380
	) -- 1380
	uiDraw:drawSegment( -- 1381
		Vec2(0, deskY + 42 * s), -- 1381
		Vec2(ctx.uiW, deskY + 42 * s), -- 1381
		1.6 * s, -- 1381
		Color(158, 126, 92, 165) -- 1381
	) -- 1381
	uiDraw:drawSegment( -- 1382
		Vec2(0, deskY - 118 * s), -- 1382
		Vec2(ctx.uiW, deskY - 118 * s), -- 1382
		2 * s, -- 1382
		Color(172, 138, 102, 155) -- 1382
	) -- 1382
	local inkX = ox + ____exports.TOWER_SHOT_LAYOUT.inkstoneX * s -- 1385
	local inkY = oy + ____exports.TOWER_SHOT_LAYOUT.inkstoneY * s -- 1386
	uiDraw:drawEllipse( -- 1387
		Vec2(inkX + 3 * s, inkY - 18 * s), -- 1387
		44 * s, -- 1387
		11 * s, -- 1387
		Color(10, 10, 14, 145) -- 1387
	) -- 1387
	uiDraw:drawPolygon( -- 1388
		{ -- 1388
			Vec2(inkX - 38 * s, inkY - 18 * s), -- 1389
			Vec2(inkX + 38 * s, inkY - 18 * s), -- 1390
			Vec2(inkX + 32 * s, inkY + 18 * s), -- 1391
			Vec2(inkX - 32 * s, inkY + 18 * s) -- 1392
		}, -- 1392
		Color(38, 44, 52, 255), -- 1393
		1.2, -- 1393
		Color(96, 106, 118, 185) -- 1393
	) -- 1393
	uiDraw:drawEllipse( -- 1394
		Vec2(inkX, inkY + 1 * s), -- 1394
		22 * s, -- 1394
		10 * s, -- 1394
		Color(12, 14, 18, 255) -- 1394
	) -- 1394
	strokeEllipse( -- 1395
		uiDraw, -- 1395
		inkX, -- 1395
		inkY + 1 * s, -- 1395
		22 * s, -- 1395
		10 * s, -- 1395
		1.1 * s, -- 1395
		Color(76, 86, 98, 165), -- 1395
		18 -- 1395
	) -- 1395
	local lx = isLowpoly and ox + lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s or ox + ____exports.TOWER_SHOT_LAYOUT.lampDeskX * s -- 1398
	local ly = isLowpoly and oy + (lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34) * s or oy + ____exports.TOWER_SHOT_LAYOUT.lampDeskY * s -- 1401
	local lampWarmth = isLowpoly and 0.45 + 0.55 * lampProg or 0.92 -- 1404
	self:drawMingLantern( -- 1405
		uiInkDraw, -- 1405
		uiGlow, -- 1405
		lx, -- 1405
		ly, -- 1405
		1.02 * s, -- 1405
		1, -- 1405
		lampWarmth -- 1405
	) -- 1405
	if isLowpoly and lampProg > 0.04 then -- 1405
		local beamA = math.floor(62 * lampProg + 0.5) -- 1409
		fillGradQuad( -- 1410
			uiGlow, -- 1411
			lx + 10 * s, -- 1412
			ly + 30 * s, -- 1412
			Color(248, 206, 134, beamA), -- 1412
			lx + 10 * s, -- 1413
			ly - 32 * s, -- 1413
			Color( -- 1413
				248, -- 1413
				206, -- 1413
				134, -- 1413
				math.floor(beamA * 0.72 + 0.5) -- 1413
			), -- 1413
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.92) * s, -- 1414
			oy + (____exports.TOWER_SHOT_LAYOUT.row2Y - 58) * s, -- 1414
			Color(242, 198, 124, 0), -- 1414
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.85) * s, -- 1415
			oy + (____exports.TOWER_SHOT_LAYOUT.row1Y + 48) * s, -- 1415
			Color(242, 198, 124, 0) -- 1415
		) -- 1415
	end -- 1415
	local bookReveal = smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t) -- 1420
	if bookReveal > 0.02 then -- 1420
		self:drawRegisterBook( -- 1422
			uiDraw, -- 1422
			uiInkDraw, -- 1422
			uiArt, -- 1422
			uiGlow, -- 1422
			ctx, -- 1422
			route, -- 1422
			bookReveal, -- 1422
			lampProg, -- 1422
			s, -- 1422
			ox, -- 1422
			oy -- 1422
		) -- 1422
	end -- 1422
	self:drawDeskPropsAndBowl( -- 1426
		uiDraw, -- 1426
		uiInkDraw, -- 1426
		uiGlow, -- 1426
		route, -- 1426
		s, -- 1426
		ox, -- 1426
		oy -- 1426
	) -- 1426
end -- 1328
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiGlow, ctx, lampProg, s, ox, oy) -- 1429
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1438
	local wallTop = lerpRGBA( -- 1439
		rgba(18, 24, 38, 255), -- 1439
		rgba(46, 36, 28, 255), -- 1439
		lampProg -- 1439
	) -- 1439
	local wallBot = lerpRGBA( -- 1440
		rgba(12, 16, 26, 255), -- 1440
		rgba(28, 22, 20, 255), -- 1440
		lampProg -- 1440
	) -- 1440
	fillVGradRect( -- 1441
		uiDraw, -- 1441
		0, -- 1441
		0, -- 1441
		ctx.uiW, -- 1441
		ctx.uiH, -- 1441
		toColor(wallBot), -- 1441
		toColor(wallTop) -- 1441
	) -- 1441
	local beamCol = shadeSurface( -- 1444
		MING_MATERIALS.mingTimberDark.base, -- 1444
		vec3(-0.3, -0.6, -0.74), -- 1444
		18, -- 1444
		1, -- 1444
		light, -- 1444
		MING_MATERIALS.mingTimberDark -- 1444
	) -- 1444
	uiDraw:drawPolygon( -- 1445
		{ -- 1445
			Vec2(0, ctx.uiH - 96 * s), -- 1446
			Vec2(ctx.uiW, ctx.uiH - 72 * s), -- 1447
			Vec2(ctx.uiW, ctx.uiH - 42 * s), -- 1448
			Vec2(0, ctx.uiH - 42 * s) -- 1449
		}, -- 1449
		toColor(beamCol) -- 1450
	) -- 1450
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1453
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1454
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1455
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1456
	local embrasure = 24 * s -- 1457
	fillVGradRect( -- 1460
		uiDraw, -- 1460
		wx, -- 1460
		wy, -- 1460
		ww, -- 1460
		wh, -- 1460
		Color(34, 44, 62, 255), -- 1460
		Color(16, 24, 40, 255) -- 1460
	) -- 1460
	uiDraw:drawPolygon( -- 1461
		{ -- 1461
			Vec2(wx, wy), -- 1462
			Vec2(wx + ww, wy), -- 1463
			Vec2(wx + ww, wy + wh * 0.34), -- 1464
			Vec2(wx + ww * 0.56, wy + wh * 0.42), -- 1465
			Vec2(wx + ww * 0.22, wy + wh * 0.28), -- 1466
			Vec2(wx, wy + wh * 0.36) -- 1467
		}, -- 1467
		Color(20, 26, 38, 240) -- 1468
	) -- 1468
	if lampProg > 0.12 then -- 1468
		fillRadialGlow( -- 1471
			uiGlow, -- 1472
			wx + ww * 0.5, -- 1472
			wy + 26 * s, -- 1472
			ww * 0.65, -- 1473
			wh * 0.55, -- 1473
			Color( -- 1474
				248, -- 1474
				206, -- 1474
				134, -- 1474
				math.floor(92 * lampProg + 0.5) -- 1474
			), -- 1474
			Color(232, 174, 88, 0), -- 1475
			16 -- 1476
		) -- 1476
	end -- 1476
	local leftWall = shadeSurface( -- 1481
		MING_MATERIALS.mingBrick.base, -- 1481
		vec3(0.84, 0.22, -0.49), -- 1481
		10, -- 1481
		1, -- 1481
		light, -- 1481
		MING_MATERIALS.mingBrick -- 1481
	) -- 1481
	local rightWall = shadeSurface( -- 1482
		MING_MATERIALS.mingBrick.base, -- 1482
		vec3(-0.84, 0.22, -0.49), -- 1482
		10, -- 1482
		1, -- 1482
		light, -- 1482
		MING_MATERIALS.mingBrick -- 1482
	) -- 1482
	local sillCol = shadeSurface( -- 1483
		MING_MATERIALS.mingStoneStep.base, -- 1483
		vec3(0, 0.94, -0.34), -- 1483
		6, -- 1483
		1, -- 1483
		light, -- 1483
		MING_MATERIALS.mingStoneStep -- 1483
	) -- 1483
	uiDraw:drawPolygon( -- 1484
		{ -- 1484
			Vec2(wx - embrasure, wy - 12 * s), -- 1485
			Vec2(wx, wy), -- 1486
			Vec2(wx, wy + wh), -- 1487
			Vec2(wx - embrasure, wy + wh + 14 * s) -- 1488
		}, -- 1488
		toColor(leftWall) -- 1489
	) -- 1489
	uiDraw:drawPolygon( -- 1490
		{ -- 1490
			Vec2(wx + ww, wy), -- 1491
			Vec2(wx + ww + embrasure, wy - 12 * s), -- 1492
			Vec2(wx + ww + embrasure, wy + wh + 14 * s), -- 1493
			Vec2(wx + ww, wy + wh) -- 1494
		}, -- 1494
		toColor(rightWall) -- 1495
	) -- 1495
	uiDraw:drawPolygon( -- 1497
		{ -- 1497
			Vec2(wx - embrasure - 10 * s, wy - 16 * s), -- 1498
			Vec2(wx + ww + embrasure + 10 * s, wy - 16 * s), -- 1499
			Vec2(wx + ww + 4 * s, wy + 10 * s), -- 1500
			Vec2(wx - 4 * s, wy + 10 * s) -- 1501
		}, -- 1501
		toColor(sillCol), -- 1502
		1, -- 1502
		toColor(STONE_EDGE_FALLBACK, 140) -- 1502
	) -- 1502
	local bar = 1 -- 1505
	do -- 1505
		bar = 1 -- 1506
		while bar <= 3 do -- 1506
			local bx = wx + ww * bar / 4 -- 1507
			uiDraw:drawSegment( -- 1508
				Vec2(bx, wy + 6 * s), -- 1508
				Vec2(bx, wy + wh - 2 * s), -- 1508
				3 * s, -- 1508
				Color(46, 34, 26, 235) -- 1508
			) -- 1508
			bar = bar + 1 -- 1506
		end -- 1506
	end -- 1506
	uiDraw:drawSegment( -- 1510
		Vec2(wx, wy + wh * 0.56), -- 1510
		Vec2(wx + ww, wy + wh * 0.56), -- 1510
		3.2 * s, -- 1510
		Color(46, 34, 26, 235) -- 1510
	) -- 1510
	uiDraw:drawRect( -- 1511
		Rect(wx, wy, ww, wh), -- 1511
		Color(0, 0, 0, 0), -- 1511
		2.4 * s, -- 1511
		Color(66, 50, 38, 240) -- 1511
	) -- 1511
	if lampProg > 0.02 then -- 1511
		fillRadialGlow( -- 1515
			uiGlow, -- 1516
			wx + ww * 0.5, -- 1516
			wy + 34 * s, -- 1516
			540 * s, -- 1517
			390 * s, -- 1517
			Color( -- 1518
				246, -- 1518
				198, -- 1518
				122, -- 1518
				math.floor(74 * lampProg + 0.5) -- 1518
			), -- 1518
			Color(216, 154, 72, 0), -- 1519
			20 -- 1520
		) -- 1520
	end -- 1520
end -- 1429
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1525
	fillVGradRect( -- 1535
		uiDraw, -- 1536
		0, -- 1536
		0, -- 1536
		ctx.uiW, -- 1536
		ctx.uiH, -- 1536
		Color(26, 21, 20, 255), -- 1537
		Color(46, 36, 30, 255) -- 1538
	) -- 1538
	local r = 0 -- 1541
	do -- 1541
		r = 0 -- 1542
		while r < 9 do -- 1542
			local y = oy + (280 + r * 44) * s -- 1543
			uiDraw:drawSegment( -- 1544
				Vec2(0, y), -- 1544
				Vec2(ctx.uiW, y), -- 1544
				1, -- 1544
				Color(34, 27, 24, 150) -- 1544
			) -- 1544
			r = r + 1 -- 1542
		end -- 1542
	end -- 1542
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1548
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1549
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1550
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1551
	fillVGradRect( -- 1552
		uiDraw, -- 1552
		wx, -- 1552
		wy, -- 1552
		ww, -- 1552
		wh, -- 1552
		Color(56, 62, 74, 255), -- 1552
		Color(26, 34, 50, 255) -- 1552
	) -- 1552
	uiDraw:drawRect( -- 1553
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1553
		Color(92, 68, 48, 255), -- 1553
		1, -- 1553
		Color(148, 114, 82, 180) -- 1553
	) -- 1553
	local bar = 1 -- 1554
	do -- 1554
		bar = 1 -- 1555
		while bar <= 3 do -- 1555
			local bx = wx + ww * bar / 4 -- 1556
			uiDraw:drawSegment( -- 1557
				Vec2(bx, wy + 4 * s), -- 1557
				Vec2(bx, wy + wh - 2 * s), -- 1557
				3.2 * s, -- 1557
				Color(64, 46, 34, 245) -- 1557
			) -- 1557
			bar = bar + 1 -- 1555
		end -- 1555
	end -- 1555
	uiDraw:drawSegment( -- 1559
		Vec2(wx, wy + wh * 0.56), -- 1559
		Vec2(wx + ww, wy + wh * 0.56), -- 1559
		3.2 * s, -- 1559
		Color(64, 46, 34, 245) -- 1559
	) -- 1559
	uiDraw:drawRect( -- 1560
		Rect(wx, wy, ww, wh), -- 1560
		Color(0, 0, 0, 0), -- 1560
		2.8 * s, -- 1560
		Color(88, 64, 44, 245) -- 1560
	) -- 1560
	local groupX = ox + 210 * s -- 1563
	local groupY = oy + 300 * s -- 1564
	uiArt:tryPlace( -- 1565
		"soldier_idle", -- 1565
		"fe05_m03_room_soldier", -- 1565
		groupX - 38 * s, -- 1565
		groupY, -- 1565
		118 * s, -- 1565
		166 * s, -- 1565
		{facing = 1, opacity = 0.9, layer = 1} -- 1565
	) -- 1565
	uiArt:tryPlace( -- 1568
		"child_idle", -- 1568
		"fe05_m03_room_child", -- 1568
		groupX + 42 * s, -- 1568
		groupY, -- 1568
		86 * s, -- 1568
		116 * s, -- 1568
		{facing = 1, opacity = 0.92, layer = 1} -- 1568
	) -- 1568
	fillRadialGlow( -- 1573
		uiGlow, -- 1574
		ox + 260 * s, -- 1574
		oy + 416 * s, -- 1574
		520 * s, -- 1575
		360 * s, -- 1575
		Color(246, 202, 134, 68), -- 1576
		Color(220, 158, 76, 0), -- 1577
		20 -- 1578
	) -- 1578
end -- 1525
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1582
	local t = self.seqElapsed -- 1595
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1596
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1597
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1598
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1599
	local midX = bx + bw * 0.5 -- 1600
	local midY = by + bh * 0.5 -- 1601
	uiDraw:drawRect( -- 1604
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1604
		Color( -- 1604
			10, -- 1604
			11, -- 1604
			16, -- 1604
			math.floor(108 * reveal + 0.5) -- 1604
		) -- 1604
	) -- 1604
	uiDraw:drawRect( -- 1605
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1605
		Color( -- 1605
			32, -- 1605
			46, -- 1605
			62, -- 1605
			math.floor(235 * reveal + 0.5) -- 1605
		), -- 1605
		1, -- 1605
		Color( -- 1605
			86, -- 1605
			104, -- 1605
			124, -- 1605
			math.floor(165 * reveal + 0.5) -- 1605
		) -- 1605
	) -- 1605
	if not uiArt:tryPlace( -- 1605
		"ink_song_paper", -- 1608
		"fe05_registry_paper", -- 1608
		midX, -- 1608
		midY, -- 1608
		bw, -- 1608
		bh, -- 1608
		{opacity = 0.98 * reveal, layer = 1} -- 1608
	) then -- 1608
		uiDraw:drawRect( -- 1609
			Rect(bx, by, bw, bh), -- 1610
			toColor( -- 1611
				PALETTE.xuanPaper, -- 1611
				math.floor(248 * reveal + 0.5) -- 1611
			), -- 1611
			1, -- 1612
			toColor( -- 1613
				PALETTE.silkDim, -- 1613
				math.floor(180 * reveal + 0.5) -- 1613
			) -- 1613
		) -- 1613
	end -- 1613
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1618
	fillRadialGlow( -- 1619
		uiGlow, -- 1620
		bx + bw * 0.34, -- 1620
		by + bh * 0.48, -- 1620
		bw * 0.58, -- 1621
		bh * 0.52, -- 1621
		Color( -- 1622
			246, -- 1622
			214, -- 1622
			156, -- 1622
			math.floor(44 * paperWarm * reveal + 0.5) -- 1622
		), -- 1622
		Color(238, 198, 128, 0), -- 1623
		16 -- 1624
	) -- 1624
	local padX = 44 * s -- 1628
	local padY = 32 * s -- 1629
	local inX = bx + padX -- 1630
	local inY = by + padY -- 1631
	local inW = bw - padX * 2 -- 1632
	local inH = bh - padY * 2 -- 1633
	local redSilk = toColor( -- 1634
		PALETTE.rouge, -- 1634
		math.floor(132 * reveal + 0.5) -- 1634
	) -- 1634
	local redFaint = toColor( -- 1635
		PALETTE.rouge, -- 1635
		math.floor(70 * reveal + 0.5) -- 1635
	) -- 1635
	uiInkDraw:drawRect( -- 1636
		Rect(inX, inY, inW, inH), -- 1636
		Color(0, 0, 0, 0), -- 1636
		1, -- 1636
		redSilk -- 1636
	) -- 1636
	uiInkDraw:drawRect( -- 1637
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1637
		Color(0, 0, 0, 0), -- 1637
		0.6, -- 1637
		redFaint -- 1637
	) -- 1637
	local headY = inY + inH - 28 * s -- 1640
	ctx.texts:put( -- 1641
		"md", -- 1641
		"北塔值夜收籍 · 末页", -- 1641
		inX + 18 * s, -- 1641
		headY, -- 1641
		toColor(PALETTE.xuanInk), -- 1641
		0, -- 1641
		0.5, -- 1641
		"Left", -- 1641
		2.2, -- 1641
		0.96 * reveal, -- 1641
		0 -- 1641
	) -- 1641
	ctx.texts:put( -- 1642
		"xs", -- 1642
		"宁村北塔", -- 1642
		inX + inW - 18 * s, -- 1642
		headY, -- 1642
		toColor(PALETTE.xuanInkSub), -- 1642
		1, -- 1642
		0.5, -- 1642
		"Right", -- 1642
		1.8, -- 1642
		0.8 * reveal, -- 1642
		0 -- 1642
	) -- 1642
	uiInkDraw:drawSegment( -- 1643
		Vec2(inX + 14 * s, headY - 22 * s), -- 1643
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1643
		0.9, -- 1643
		redSilk -- 1643
	) -- 1643
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1646
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1647
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1648
	ctx.texts:put( -- 1649
		"sm", -- 1649
		"肆拾壹", -- 1649
		inX + 18 * s, -- 1649
		row1Y, -- 1649
		toColor(PALETTE.rouge), -- 1649
		0, -- 1649
		0.5, -- 1649
		"Left", -- 1649
		1, -- 1649
		0.94 * reveal, -- 1649
		0 -- 1649
	) -- 1649
	if r1Prog > 0.02 then -- 1649
		ctx.texts:put( -- 1651
			"md", -- 1651
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1651
			inX + 96 * s, -- 1651
			row1Y, -- 1651
			toColor(PALETTE.xuanInk), -- 1651
			0, -- 1651
			0.5, -- 1651
			"Left", -- 1651
			1.6, -- 1651
			0.96 * math.min(1, r1Prog * 1.4), -- 1651
			0 -- 1651
		) -- 1651
	end -- 1651
	if r1Prog > 0.65 then -- 1651
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1654
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1655
		ctx.texts:put( -- 1658
			"xs", -- 1658
			subText, -- 1658
			inX + 96 * s, -- 1658
			row1SubY, -- 1658
			toColor(PALETTE.xuanInkSub), -- 1658
			0, -- 1658
			0.5, -- 1658
			"Left", -- 1658
			0.6, -- 1658
			0.88 * subA, -- 1658
			0 -- 1658
		) -- 1658
	end -- 1658
	uiInkDraw:drawSegment( -- 1660
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1660
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1660
		0.7, -- 1660
		redFaint -- 1660
	) -- 1660
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1663
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1664
	ctx.texts:put( -- 1665
		"sm", -- 1665
		"肆拾贰", -- 1665
		inX + 18 * s, -- 1665
		row2Y, -- 1665
		toColor(PALETTE.rouge), -- 1665
		0, -- 1665
		0.5, -- 1665
		"Left", -- 1665
		1, -- 1665
		0.94 * reveal, -- 1665
		0 -- 1665
	) -- 1665
	if route == "child" then -- 1665
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1669
		uiInkDraw:drawSegment( -- 1670
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1671
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1672
			1, -- 1673
			toColor(PALETTE.xuanInkSub, lineA) -- 1674
		) -- 1674
	else -- 1674
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1678
		if r2Prog <= 0.02 then -- 1678
			uiInkDraw:drawSegment( -- 1680
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1681
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1682
				0.9, -- 1683
				toColor( -- 1684
					PALETTE.xuanInkSub, -- 1684
					math.floor(105 * reveal + 0.5) -- 1684
				) -- 1684
			) -- 1684
		else -- 1684
			ctx.texts:put( -- 1687
				"md", -- 1687
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1687
				inX + 96 * s, -- 1687
				row2Y, -- 1687
				toColor(PALETTE.xuanInk), -- 1687
				0, -- 1687
				0.5, -- 1687
				"Left", -- 1687
				1.6, -- 1687
				0.96 * math.min(1, r2Prog * 1.4), -- 1687
				0 -- 1687
			) -- 1687
			if r2Prog > 0.65 then -- 1687
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1689
				ctx.texts:put( -- 1690
					"xs", -- 1690
					"守城戍卒亲口报出姓名，两人俱安。", -- 1690
					inX + 96 * s, -- 1690
					row2SubY, -- 1690
					toColor(PALETTE.xuanInkSub), -- 1690
					0, -- 1690
					0.5, -- 1690
					"Left", -- 1690
					0.6, -- 1690
					0.88 * subA, -- 1690
					0 -- 1690
				) -- 1690
			end -- 1690
		end -- 1690
	end -- 1690
	uiInkDraw:drawSegment( -- 1694
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1694
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1694
		0.7, -- 1694
		redFaint -- 1694
	) -- 1694
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1697
	if colophonA > 0.02 then -- 1697
		local signY = inY + 34 * s -- 1699
		ctx.texts:put( -- 1700
			"banner", -- 1700
			"向西守望", -- 1700
			midX - 24 * s, -- 1700
			signY, -- 1700
			toColor(PALETTE.xuanInk), -- 1700
			0.5, -- 1700
			0.5, -- 1700
			"Center", -- 1700
			6, -- 1700
			0.88 * colophonA, -- 1700
			0 -- 1700
		) -- 1700
	end -- 1700
	self:drawGuardBrushHand( -- 1704
		uiInkDraw, -- 1704
		route, -- 1704
		s, -- 1704
		ox, -- 1704
		oy -- 1704
	) -- 1704
end -- 1582
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, route, s, ox, oy) -- 1707
	local t = self.seqElapsed -- 1714
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1715
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1716
	local row1X0 = hoverX -- 1717
	local row1X1 = hoverX + 142 * s -- 1718
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1719
	local tipX = hoverX -- 1721
	local tipY = hoverY -- 1722
	local alpha = 0 -- 1723
	local lifted = 0 -- 1724
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1724
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1728
		tipX = lerp(row1X0, row1X1, k) -- 1729
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1730
		alpha = smoothstep(2, 2.2, t) -- 1731
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1732
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1732
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1735
		tipX = lerp(row1X1, hoverX, moveK) -- 1736
		tipY = lerp(row1Y, hoverY, moveK) -- 1737
		alpha = 1 -- 1738
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1739
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1739
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1742
		tipX = hoverX + outK * 140 * s -- 1743
		tipY = hoverY + outK * 46 * s -- 1744
		lifted = (9 + outK * 28) * s -- 1745
		alpha = 1 - outK -- 1746
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1746
		if t < 4.6 then -- 1746
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1750
			tipX = hoverX -- 1751
			tipY = hoverY -- 1752
			lifted = lerp(9 * s, 0, dipK) -- 1753
			alpha = 1 -- 1754
		elseif t < 5.55 then -- 1754
			local wK = smoothstep(4.6, 5.55, t) -- 1756
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1757
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1758
			lifted = 0 -- 1759
			alpha = 1 -- 1760
		else -- 1760
			local outK = smoothstep(5.55, 6.05, t) -- 1762
			tipX = hoverX + 216 * s + outK * 115 * s -- 1763
			tipY = hoverY + outK * 52 * s -- 1764
			lifted = outK * 24 * s -- 1765
			alpha = 1 - outK -- 1766
		end -- 1766
	end -- 1766
	if alpha <= 0.02 then -- 1766
		return -- 1771
	end -- 1771
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1774
	local bx = tipX -- 1775
	local by = tipY + lifted -- 1776
	uiInkDraw:drawEllipse( -- 1778
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1778
		(5 + lifted * 0.22) * s, -- 1778
		2.8 * s, -- 1778
		Color( -- 1778
			20, -- 1778
			18, -- 1778
			16, -- 1778
			math.floor(78 * alpha + 0.5) -- 1778
		) -- 1778
	) -- 1778
	uiInkDraw:drawPolygon( -- 1780
		{ -- 1780
			Vec2(bx, by), -- 1781
			Vec2(bx + 15 * s, by - 4 * s), -- 1782
			Vec2(bx + 10 * s, by + 8 * s) -- 1783
		}, -- 1783
		Color(22, 22, 26, a) -- 1784
	) -- 1784
	uiInkDraw:drawSegment( -- 1786
		Vec2(bx + 12 * s, by + 2 * s), -- 1786
		Vec2(bx + 24 * s, by + 6 * s), -- 1786
		7.8 * s, -- 1786
		Color(164, 138, 92, a) -- 1786
	) -- 1786
	uiInkDraw:drawSegment( -- 1787
		Vec2(bx + 22 * s, by + 5 * s), -- 1787
		Vec2(bx + 122 * s, by + 34 * s), -- 1787
		6.8 * s, -- 1787
		Color(142, 110, 74, a) -- 1787
	) -- 1787
	uiInkDraw:drawSegment( -- 1788
		Vec2(bx + 22 * s, by + 5 * s), -- 1788
		Vec2(bx + 122 * s, by + 34 * s), -- 1788
		1.8 * s, -- 1788
		Color( -- 1788
			196, -- 1788
			164, -- 1788
			118, -- 1788
			math.floor(185 * alpha + 0.5) -- 1788
		) -- 1788
	) -- 1788
	uiInkDraw:drawPolygon( -- 1790
		{ -- 1790
			Vec2(bx + 44 * s, by - 6 * s), -- 1791
			Vec2(bx + 102 * s, by - 14 * s), -- 1792
			Vec2(bx + 110 * s, by + 18 * s), -- 1793
			Vec2(bx + 54 * s, by + 22 * s) -- 1794
		}, -- 1794
		Color(188, 154, 126, a), -- 1795
		1, -- 1795
		Color(128, 98, 76, a) -- 1795
	) -- 1795
	uiInkDraw:drawSegment( -- 1796
		Vec2(bx + 46 * s, by + 16 * s), -- 1796
		Vec2(bx + 76 * s, by + 20 * s), -- 1796
		5.2 * s, -- 1796
		Color(204, 170, 140, a) -- 1796
	) -- 1796
	uiInkDraw:drawSegment( -- 1797
		Vec2(bx + 48 * s, by + 2 * s), -- 1797
		Vec2(bx + 82 * s, by + 4 * s), -- 1797
		4.8 * s, -- 1797
		Color(180, 146, 118, a) -- 1797
	) -- 1797
	uiInkDraw:drawPolygon( -- 1798
		{ -- 1798
			Vec2(bx + 98 * s, by - 14 * s), -- 1799
			Vec2(bx + 224 * s, by - 32 * s), -- 1800
			Vec2(bx + 230 * s, by + 18 * s), -- 1801
			Vec2(bx + 104 * s, by + 20 * s) -- 1802
		}, -- 1802
		Color(54, 48, 44, a), -- 1803
		1.2, -- 1803
		Color(94, 84, 72, a) -- 1803
	) -- 1803
end -- 1707
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiGlow, route, s, ox, oy) -- 1806
	local t = self.seqElapsed -- 1815
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1816
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1817
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1818
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1819
	if route == "child" then -- 1819
		local propA = smoothstep(1.55, 2.05, t) -- 1823
		if propA > 0.02 then -- 1823
			self:drawNeedleCaseOnDesk( -- 1825
				uiInkDraw, -- 1825
				ncX, -- 1825
				ncY, -- 1825
				s, -- 1825
				propA, -- 1825
				true -- 1825
			) -- 1825
		end -- 1825
		local bowlK = smoothstep(4.35, 5.15, t) -- 1828
		if bowlK > 0.02 then -- 1828
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1830
			self:drawWarmPorcelainBowl( -- 1831
				uiInkDraw, -- 1831
				uiGlow, -- 1831
				bx, -- 1831
				bowlY, -- 1831
				s, -- 1831
				bowlK, -- 1831
				false, -- 1831
				0 -- 1831
			) -- 1831
		end -- 1831
	else -- 1831
		local needleK = smoothstep(5.45, 6.15, t) -- 1835
		if needleK > 0.02 then -- 1835
			local ny = lerp(ncY + 46 * s, ncY, needleK) -- 1837
			self:drawNeedleCaseOnDesk( -- 1838
				uiInkDraw, -- 1838
				ncX, -- 1838
				ny, -- 1838
				s, -- 1838
				needleK, -- 1838
				false -- 1838
			) -- 1838
		end -- 1838
		local bowlK = smoothstep(5.8, 6.65, t) -- 1841
		if bowlK > 0.02 then -- 1841
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1843
			local handsK = smoothstep(5.95, 6.75, t) -- 1844
			self:drawWarmPorcelainBowl( -- 1845
				uiInkDraw, -- 1845
				uiGlow, -- 1845
				bowlX, -- 1845
				by, -- 1845
				s, -- 1845
				bowlK, -- 1845
				true, -- 1845
				handsK -- 1845
			) -- 1845
		end -- 1845
		local cuffK = smoothstep(4.25, 4.85, t) -- 1848
		if cuffK > 0.02 then -- 1848
			drawPatchedCuff(uiInkDraw, uiGlow, { -- 1850
				wristX = ox + 122 * s, -- 1851
				wristY = oy + 182 * s, -- 1852
				angleRad = 0.08, -- 1853
				scale = 0.6 * s, -- 1854
				pose = "open", -- 1855
				opacity = 0.92 * cuffK, -- 1856
				stitchHighlight = 0.34, -- 1857
				warmth = 0.72 -- 1858
			}) -- 1858
		end -- 1858
	end -- 1858
end -- 1806
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, draw, cx, cy, s, alpha, withNote) -- 1865
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1873
	draw:drawEllipse( -- 1875
		Vec2(cx + 4 * s, cy - 12 * s), -- 1875
		44 * s, -- 1875
		14 * s, -- 1875
		Color( -- 1875
			10, -- 1875
			10, -- 1875
			14, -- 1875
			math.floor(140 * alpha + 0.5) -- 1875
		) -- 1875
	) -- 1875
	draw:drawPolygon( -- 1877
		{ -- 1877
			Vec2(cx - 32 * s, cy - 12 * s), -- 1878
			Vec2(cx + 26 * s, cy - 15 * s), -- 1879
			Vec2(cx + 30 * s, cy + 16 * s), -- 1880
			Vec2(cx - 28 * s, cy + 18 * s) -- 1881
		}, -- 1881
		Color(148, 124, 92, a), -- 1882
		1.3, -- 1882
		Color(88, 70, 50, a) -- 1882
	) -- 1882
	draw:drawEllipse( -- 1884
		Vec2(cx + 18 * s, cy + 2 * s), -- 1884
		13 * s, -- 1884
		13 * s, -- 1884
		Color(188, 152, 86, a) -- 1884
	) -- 1884
	strokeEllipse( -- 1885
		draw, -- 1885
		cx + 18 * s, -- 1885
		cy + 2 * s, -- 1885
		13 * s, -- 1885
		13 * s, -- 1885
		1.5 * s, -- 1885
		Color(118, 92, 46, a), -- 1885
		18 -- 1885
	) -- 1885
	draw:drawDot( -- 1886
		Vec2(cx + 18 * s, cy + 2 * s), -- 1886
		2.5 * s, -- 1886
		Color(72, 54, 28, a) -- 1886
	) -- 1886
	draw:drawSegment( -- 1887
		Vec2(cx + 12 * s, cy - 2 * s), -- 1887
		Vec2(cx + 24 * s, cy + 6 * s), -- 1887
		1.5 * s, -- 1887
		Color(164, 48, 44, a) -- 1887
	) -- 1887
	draw:drawSegment( -- 1889
		Vec2(cx - 28 * s, cy + 4 * s), -- 1889
		Vec2(cx - 56 * s, cy - 8 * s), -- 1889
		2.4 * s, -- 1889
		toColor(CUFF_PALETTE.childCord, a) -- 1889
	) -- 1889
	draw:drawSegment( -- 1890
		Vec2(cx - 56 * s, cy - 8 * s), -- 1890
		Vec2(cx - 72 * s, cy + 6 * s), -- 1890
		2.2 * s, -- 1890
		toColor(CUFF_PALETTE.childCord, a) -- 1890
	) -- 1890
	draw:drawSegment( -- 1891
		Vec2(cx - 72 * s, cy + 6 * s), -- 1891
		Vec2(cx - 48 * s, cy + 16 * s), -- 1891
		2 * s, -- 1891
		toColor( -- 1891
			CUFF_PALETTE.childCord, -- 1891
			math.floor(215 * alpha + 0.5) -- 1891
		) -- 1891
	) -- 1891
	if withNote then -- 1891
		draw:drawPolygon( -- 1895
			{ -- 1895
				Vec2(cx + 38 * s, cy - 18 * s), -- 1896
				Vec2(cx + 96 * s, cy - 12 * s), -- 1897
				Vec2(cx + 90 * s, cy + 24 * s), -- 1898
				Vec2(cx + 34 * s, cy + 18 * s) -- 1899
			}, -- 1899
			toColor(PALETTE.xuanPaper, a), -- 1900
			1, -- 1900
			toColor( -- 1900
				PALETTE.xuanInkSub, -- 1900
				math.floor(160 * alpha + 0.5) -- 1900
			) -- 1900
		) -- 1900
		draw:drawSegment( -- 1901
			Vec2(cx + 46 * s, cy + 8 * s), -- 1901
			Vec2(cx + 80 * s, cy + 11 * s), -- 1901
			1.2 * s, -- 1901
			toColor( -- 1901
				PALETTE.xuanInk, -- 1901
				math.floor(170 * alpha + 0.5) -- 1901
			) -- 1901
		) -- 1901
		draw:drawSegment( -- 1902
			Vec2(cx + 46 * s, cy - 2 * s), -- 1902
			Vec2(cx + 76 * s, cy + 1 * s), -- 1902
			1.2 * s, -- 1902
			toColor( -- 1902
				PALETTE.xuanInk, -- 1902
				math.floor(160 * alpha + 0.5) -- 1902
			) -- 1902
		) -- 1902
	end -- 1902
end -- 1865
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, draw, glow, cx, cy, s, alpha, heldByTwoHands, handsK) -- 1907
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1917
	draw:drawEllipse( -- 1919
		Vec2(cx, cy - 36 * s), -- 1919
		58 * s, -- 1919
		14 * s, -- 1919
		Color( -- 1919
			8, -- 1919
			9, -- 1919
			14, -- 1919
			math.floor(150 * alpha + 0.5) -- 1919
		) -- 1919
	) -- 1919
	draw:drawPolygon( -- 1921
		{ -- 1921
			Vec2(cx - 32 * s, cy - 38 * s), -- 1922
			Vec2(cx + 32 * s, cy - 38 * s), -- 1923
			Vec2(cx + 62 * s, cy + 8 * s), -- 1924
			Vec2(cx - 62 * s, cy + 8 * s) -- 1925
		}, -- 1925
		Color(168, 166, 156, a), -- 1926
		1.4, -- 1926
		Color(98, 96, 88, a) -- 1926
	) -- 1926
	draw:drawPolygon( -- 1928
		{ -- 1928
			Vec2(cx + 8 * s, cy - 36 * s), -- 1929
			Vec2(cx + 32 * s, cy - 38 * s), -- 1930
			Vec2(cx + 62 * s, cy + 8 * s), -- 1931
			Vec2(cx + 22 * s, cy + 6 * s) -- 1932
		}, -- 1932
		Color( -- 1933
			122, -- 1933
			120, -- 1933
			112, -- 1933
			math.floor(160 * alpha + 0.5) -- 1933
		) -- 1933
	) -- 1933
	draw:drawEllipse( -- 1935
		Vec2(cx, cy + 8 * s), -- 1935
		64 * s, -- 1935
		21 * s, -- 1935
		Color(224, 218, 206, a) -- 1935
	) -- 1935
	strokeEllipse( -- 1936
		draw, -- 1936
		cx, -- 1936
		cy + 8 * s, -- 1936
		64 * s, -- 1936
		21 * s, -- 1936
		1.9 * s, -- 1936
		Color(116, 110, 100, a), -- 1936
		28 -- 1936
	) -- 1936
	draw:drawEllipse( -- 1937
		Vec2(cx, cy + 6 * s), -- 1937
		54 * s, -- 1937
		15 * s, -- 1937
		Color(196, 168, 122, a) -- 1937
	) -- 1937
	strokeEllipse( -- 1938
		draw, -- 1938
		cx, -- 1938
		cy + 6 * s, -- 1938
		54 * s, -- 1938
		15 * s, -- 1938
		1.1 * s, -- 1938
		Color(158, 132, 92, a), -- 1938
		24 -- 1938
	) -- 1938
	draw:drawSegment( -- 1940
		Vec2(cx - 46 * s, cy + 16 * s), -- 1940
		Vec2(cx - 10 * s, cy + 25 * s), -- 1940
		2 * s, -- 1940
		Color( -- 1940
			248, -- 1940
			246, -- 1940
			240, -- 1940
			math.floor(215 * alpha + 0.5) -- 1940
		) -- 1940
	) -- 1940
	local wi = 0 -- 1943
	do -- 1943
		wi = 0 -- 1944
		while wi < 3 do -- 1944
			local phase = self.animTime * 1.1 + wi * 2.05 -- 1945
			local baseX = cx + (wi - 1) * 18 * s -- 1946
			local baseY = cy + 16 * s -- 1947
			local segs = 4 -- 1948
			local prevX = baseX -- 1949
			local prevY = baseY -- 1950
			local si = 1 -- 1951
			do -- 1951
				si = 1 -- 1952
				while si <= segs do -- 1952
					local frac = si / segs -- 1953
					local nx = baseX + math.sin(phase + frac * 3.1) * (6.5 * frac) * s -- 1954
					local ny = baseY + frac * (36 + wi % 2 * 10) * s -- 1955
					local wa = math.floor(46 * (1 - frac * 0.72) * alpha + 0.5) -- 1956
					glow:drawSegment( -- 1957
						Vec2(prevX, prevY), -- 1957
						Vec2(nx, ny), -- 1957
						(2.2 - frac * 0.9) * s, -- 1957
						Color(244, 238, 226, wa) -- 1957
					) -- 1957
					prevX = nx -- 1958
					prevY = ny -- 1959
					si = si + 1 -- 1952
				end -- 1952
			end -- 1952
			wi = wi + 1 -- 1944
		end -- 1944
	end -- 1944
	if heldByTwoHands and handsK > 0.02 then -- 1944
		local ha = math.floor(255 * clamp01(handsK * alpha) + 0.5) -- 1965
		local skin = toColor(CUFF_PALETTE.childSkin, ha) -- 1966
		local skinSh = toColor(CUFF_PALETTE.childSkinShadow, ha) -- 1967
		local sleeve = toColor(CUFF_PALETTE.childSleeve, ha) -- 1968
		local spread = (1 - handsK) * 28 * s -- 1969
		draw:drawPolygon( -- 1972
			{ -- 1972
				Vec2(cx - 122 * s - spread, cy - 58 * s), -- 1973
				Vec2(cx - 72 * s - spread, cy - 30 * s), -- 1974
				Vec2(cx - 82 * s - spread, cy - 4 * s), -- 1975
				Vec2(cx - 134 * s - spread, cy - 26 * s) -- 1976
			}, -- 1976
			sleeve, -- 1977
			1.1, -- 1977
			skinSh -- 1977
		) -- 1977
		draw:drawPolygon( -- 1978
			{ -- 1978
				Vec2(cx - 76 * s - spread, cy - 28 * s), -- 1979
				Vec2(cx - 48 * s - spread, cy - 18 * s), -- 1980
				Vec2(cx - 44 * s - spread, cy + 6 * s), -- 1981
				Vec2(cx - 74 * s - spread, cy + 2 * s) -- 1982
			}, -- 1982
			skin, -- 1983
			1.1, -- 1983
			skinSh -- 1983
		) -- 1983
		draw:drawSegment( -- 1984
			Vec2(cx - 56 * s - spread, cy + 2 * s), -- 1984
			Vec2(cx - 38 * s - spread, cy + 12 * s), -- 1984
			4.6 * s, -- 1984
			skin -- 1984
		) -- 1984
		draw:drawSegment( -- 1985
			Vec2(cx - 58 * s - spread, cy - 7 * s), -- 1985
			Vec2(cx - 40 * s - spread, cy - 2 * s), -- 1985
			4.4 * s, -- 1985
			skin -- 1985
		) -- 1985
		draw:drawSegment( -- 1986
			Vec2(cx - 56 * s - spread, cy - 16 * s), -- 1986
			Vec2(cx - 40 * s - spread, cy - 14 * s), -- 1986
			4.2 * s, -- 1986
			skin -- 1986
		) -- 1986
		draw:drawPolygon( -- 1989
			{ -- 1989
				Vec2(cx + 122 * s + spread, cy - 58 * s), -- 1990
				Vec2(cx + 72 * s + spread, cy - 30 * s), -- 1991
				Vec2(cx + 82 * s + spread, cy - 4 * s), -- 1992
				Vec2(cx + 134 * s + spread, cy - 26 * s) -- 1993
			}, -- 1993
			sleeve, -- 1994
			1.1, -- 1994
			skinSh -- 1994
		) -- 1994
		draw:drawPolygon( -- 1995
			{ -- 1995
				Vec2(cx + 76 * s + spread, cy - 28 * s), -- 1996
				Vec2(cx + 48 * s + spread, cy - 18 * s), -- 1997
				Vec2(cx + 44 * s + spread, cy + 6 * s), -- 1998
				Vec2(cx + 74 * s + spread, cy + 2 * s) -- 1999
			}, -- 1999
			skin, -- 2000
			1.1, -- 2000
			skinSh -- 2000
		) -- 2000
		draw:drawSegment( -- 2001
			Vec2(cx + 56 * s + spread, cy + 2 * s), -- 2001
			Vec2(cx + 38 * s + spread, cy + 12 * s), -- 2001
			4.6 * s, -- 2001
			skin -- 2001
		) -- 2001
		draw:drawSegment( -- 2002
			Vec2(cx + 58 * s + spread, cy - 7 * s), -- 2002
			Vec2(cx + 40 * s + spread, cy - 2 * s), -- 2002
			4.4 * s, -- 2002
			skin -- 2002
		) -- 2002
		draw:drawSegment( -- 2003
			Vec2(cx + 56 * s + spread, cy - 16 * s), -- 2003
			Vec2(cx + 40 * s + spread, cy - 14 * s), -- 2003
			4.2 * s, -- 2003
			skin -- 2003
		) -- 2003
	end -- 2003
end -- 1907
function TowerEndingsPlugin.prototype.drawMingLantern(self, draw, glow, cx, cy, scale, alpha, warmth) -- 2008
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 2017
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 2018
	draw:drawSegment( -- 2020
		Vec2(cx - 10 * scale, cy + 28 * scale), -- 2020
		Vec2(cx, cy + 40 * scale), -- 2020
		1.8 * scale, -- 2020
		Color(88, 86, 82, a) -- 2020
	) -- 2020
	draw:drawSegment( -- 2021
		Vec2(cx + 10 * scale, cy + 28 * scale), -- 2021
		Vec2(cx, cy + 40 * scale), -- 2021
		1.8 * scale, -- 2021
		Color(88, 86, 82, a) -- 2021
	) -- 2021
	draw:drawRect( -- 2023
		Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), -- 2023
		Color(62, 46, 34, a), -- 2023
		1, -- 2023
		Color(118, 92, 66, a) -- 2023
	) -- 2023
	draw:drawRect( -- 2024
		Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), -- 2024
		Color(62, 46, 34, a), -- 2024
		1, -- 2024
		Color(118, 92, 66, a) -- 2024
	) -- 2024
	draw:drawRect( -- 2026
		Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale), -- 2027
		Color( -- 2028
			238, -- 2028
			198, -- 2028
			132, -- 2028
			math.floor(230 * alpha * (0.75 + 0.25 * warmth) + 0.5) -- 2028
		), -- 2028
		1.4 * scale, -- 2029
		Color(94, 70, 48, a) -- 2030
	) -- 2030
	draw:drawSegment( -- 2032
		Vec2(cx, cy - 18 * scale), -- 2032
		Vec2(cx, cy + 22 * scale), -- 2032
		1.1 * scale, -- 2032
		Color( -- 2032
			94, -- 2032
			70, -- 2032
			48, -- 2032
			math.floor(150 * alpha + 0.5) -- 2032
		) -- 2032
	) -- 2032
	draw:drawEllipse( -- 2033
		Vec2(cx, cy + 2 * scale), -- 2033
		4.6 * scale * flicker, -- 2033
		8.5 * scale * flicker, -- 2033
		Color(255, 244, 212, a) -- 2033
	) -- 2033
	fillRadialGlow( -- 2035
		glow, -- 2036
		cx, -- 2036
		cy + 2 * scale, -- 2036
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2037
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2038
		Color( -- 2039
			250, -- 2039
			208, -- 2039
			132, -- 2039
			math.floor(128 * alpha * warmth + 0.5) -- 2039
		), -- 2039
		Color(228, 162, 74, 0), -- 2040
		16 -- 2041
	) -- 2041
end -- 2008
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 2045
	local line = self.lastSubtitle -- 2054
	if line ~= "" then -- 2054
		local cy = barH + 34 * s -- 2056
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 2057
		drawSilkVeil( -- 2058
			uiDraw, -- 2058
			uiArt, -- 2058
			"fe05_sub_veil", -- 2058
			ctx.uiW * 0.5, -- 2058
			cy, -- 2058
			stripW, -- 2058
			48 * s, -- 2058
			PALETTE.inkWash, -- 2058
			0.82, -- 2058
			3 -- 2058
		) -- 2058
		drawHairline( -- 2059
			uiInkDraw, -- 2059
			uiArt, -- 2059
			"fe05_sub_hair", -- 2059
			ctx.uiW * 0.5, -- 2059
			cy + 21 * s, -- 2059
			stripW * 0.68, -- 2059
			PALETTE.silkDim, -- 2059
			0.54, -- 2059
			true, -- 2059
			4 -- 2059
		) -- 2059
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 2060
		ctx.texts:put( -- 2061
			isSpoken and "md" or "sm", -- 2062
			line, -- 2063
			ctx.uiW * 0.5, -- 2064
			cy - 1 * s, -- 2065
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 2066
			0.5, -- 2067
			0.5, -- 2068
			"Center", -- 2069
			isSpoken and 1.8 or 1, -- 2070
			0.98, -- 2071
			0.08 -- 2072
		) -- 2072
	end -- 2072
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 2072
		local rawHint = route == "child" and "按 E 再次启程   ·   Esc 暂歇" or "团圆尾声   ·   按 E 再次启程   ·   Esc 暂歇" -- 2078
		local hint = adaptHintSentence(rawHint, ctx.input.inputMode, ctx.input.gamepadLayout) -- 2081
		ctx.texts:put( -- 2082
			"xs", -- 2082
			hint, -- 2082
			ctx.uiW * 0.5, -- 2082
			barH * 0.5, -- 2082
			toColor(PALETTE.textMid), -- 2082
			0.5, -- 2082
			0.5, -- 2082
			"Center", -- 2082
			1.4, -- 2082
			0.88, -- 2082
			0.08 -- 2082
		) -- 2082
	end -- 2082
end -- 2045
function ____exports.createTowerEndingsPlugin() -- 2087
	return __TS__New(____exports.TowerEndingsPlugin) -- 2088
end -- 2087
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 2092
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 2093
	fe:registerPlugin(plugin) -- 2094
	return plugin -- 2095
end -- 2092
return ____exports -- 2092