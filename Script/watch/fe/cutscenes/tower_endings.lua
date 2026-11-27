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
--- 精确对齐后端 tower-knock(36 拍 = 0.6s, 第 0 / 12 拍敲门) 与 8.0 秒配对演出节拍
____exports.TOWER_ENDING_TIMINGS = { -- 89
	knock1Sec = 0, -- 90
	knock2Sec = 0.2, -- 91
	reply1Sec = 0.42, -- 92
	reply2Sec = 0.54, -- 93
	doorOpenSec = 0.6, -- 94
	indoorCutSec = 1.4, -- 95
	row1StartSec = 2.2, -- 96
	row1EndSec = 3.4, -- 97
	pivotStartSec = 3.4, -- 98
	pivotEndSec = 4.2, -- 99
	divergeEndSec = 6.8, -- 100
	holdReadySec = TOWER_CONFIRM_TICKS / 60 -- 101
} -- 101
local TOWER_AUDIO_ROOT = "assets/audio/tower/" -- 104
____exports.TOWER_AUDIO_FILES = { -- 106
	knock1 = TOWER_AUDIO_ROOT .. "door_knock_1.wav", -- 107
	knock2 = TOWER_AUDIO_ROOT .. "door_knock_2.wav", -- 108
	reply1 = TOWER_AUDIO_ROOT .. "door_reply_1.wav", -- 109
	reply2 = TOWER_AUDIO_ROOT .. "door_reply_2.wav", -- 110
	doorOpen = TOWER_AUDIO_ROOT .. "door_open.wav", -- 111
	bookOpen = TOWER_AUDIO_ROOT .. "book_open.wav", -- 112
	brush1 = TOWER_AUDIO_ROOT .. "brush_write_1.wav", -- 113
	brush2 = TOWER_AUDIO_ROOT .. "brush_write_2.wav", -- 114
	lampMove = TOWER_AUDIO_ROOT .. "lamp_move.wav", -- 115
	needlePlace = TOWER_AUDIO_ROOT .. "needle_case_place.wav", -- 116
	bowlSet = TOWER_AUDIO_ROOT .. "bowl_set.wav", -- 117
	windCold = TOWER_AUDIO_ROOT .. "tower_wind_cold.wav", -- 118
	roomWarm = TOWER_AUDIO_ROOT .. "tower_room_warm.wav", -- 119
	lineXiaomanLamp = TOWER_AUDIO_ROOT .. "line_xiaoman_lamp.wav", -- 120
	lineZhoushuName = TOWER_AUDIO_ROOT .. "line_zhoushu_name.wav" -- 121
} -- 121
--- 同机位配对布局真源（基准 1280×720 逻辑坐标系，F03 与 M03 100% 共享）：
-- 保证两版并排对照时门扇、门槛、提灯、西窗、簿页、一/二行基线、悬停笔尖、案沿热碗 0.00 px 偏差。
____exports.TOWER_SHOT_LAYOUT = { -- 128
	refW = 1280, -- 129
	refH = 720, -- 130
	letterboxH = 60, -- 131
	doorCenterX = 640, -- 133
	thresholdY = 168, -- 134
	doorW = 248, -- 135
	doorH = 374, -- 136
	knockHandX = 574, -- 137
	knockHandY = 312, -- 138
	doorLanternX = 710, -- 139
	doorLanternY = 344, -- 140
	westWindowX = 88, -- 142
	westWindowY = 382, -- 143
	westWindowW = 236, -- 144
	westWindowH = 224, -- 145
	deskTopY = 260, -- 146
	lampDeskX = 356, -- 147
	lampDeskY = 332, -- 148
	lampWindowX = 206, -- 149
	lampWindowY = 422, -- 150
	bookX = 416, -- 151
	bookY = 196, -- 152
	bookW = 588, -- 153
	bookH = 386, -- 154
	row1Y = 454, -- 155
	row1SubY = 424, -- 156
	row2Y = 354, -- 157
	row2SubY = 324, -- 158
	brushHoverTipX = 556, -- 159
	brushHoverTipY = 358, -- 160
	needleCaseDeskX = 294, -- 161
	needleCaseDeskY = 204, -- 162
	bowlRimX = 954, -- 163
	bowlRimY = 184, -- 164
	inkstoneX = 1112, -- 165
	inkstoneY = 256 -- 166
} -- 166
local F03_DIALOGUE = "「朝西那盏灯，能留着吗？」" -- 228
local M03_DIALOGUE = "「周戍。」" -- 229
--- F03 拂晓冷室灯光预设（挪灯前），向 TOWER_WEST_LAMP_LIGHT（西窗暖灯）平滑插值
local TOWER_COLD_DAWN_LIGHT = { -- 232
	keyDir = normalize3(vec3(-0.34, 0.72, -0.6)), -- 233
	keyColor = rgba(146, 174, 206, 255), -- 234
	keyStrength = 0.74, -- 235
	rimDir = normalize3(vec3(0.68, 0.44, -0.58)), -- 236
	rimColor = rgba(182, 166, 140, 255), -- 237
	rimStrength = 0.24, -- 238
	ambientColor = rgba(18, 24, 38, 255), -- 239
	fogColor = rgba(16, 22, 34, 255), -- 240
	fogStartZ = 50, -- 241
	fogEndZ = 460, -- 242
	fogMaxAlpha = 0.78, -- 243
	shadowContrast = 0.78 -- 244
} -- 244
local function lerp(a, b, t) -- 247
	return a + (b - a) * t -- 248
end -- 247
local function lerpLightRig(a, b, t) -- 251
	local k = clamp01(t) -- 252
	return { -- 253
		keyDir = normalize3(vec3( -- 254
			lerp(a.keyDir.x, b.keyDir.x, k), -- 255
			lerp(a.keyDir.y, b.keyDir.y, k), -- 256
			lerp(a.keyDir.z, b.keyDir.z, k) -- 257
		)), -- 257
		keyColor = lerpRGBA(a.keyColor, b.keyColor, k), -- 259
		keyStrength = lerp(a.keyStrength, b.keyStrength, k), -- 260
		rimDir = normalize3(vec3( -- 261
			lerp(a.rimDir.x, b.rimDir.x, k), -- 262
			lerp(a.rimDir.y, b.rimDir.y, k), -- 263
			lerp(a.rimDir.z, b.rimDir.z, k) -- 264
		)), -- 264
		rimColor = lerpRGBA(a.rimColor, b.rimColor, k), -- 266
		rimStrength = lerp(a.rimStrength, b.rimStrength, k), -- 267
		ambientColor = lerpRGBA(a.ambientColor, b.ambientColor, k), -- 268
		fogColor = lerpRGBA(a.fogColor, b.fogColor, k), -- 269
		fogStartZ = lerp(a.fogStartZ, b.fogStartZ, k), -- 270
		fogEndZ = lerp(a.fogEndZ, b.fogEndZ, k), -- 271
		fogMaxAlpha = lerp(a.fogMaxAlpha, b.fogMaxAlpha, k), -- 272
		shadowContrast = lerp(a.shadowContrast, b.shadowContrast, k) -- 273
	} -- 273
end -- 251
local function computeScaledAnchors(uiW, uiH, lampProg) -- 277
	local s = math.min(uiW / ____exports.TOWER_SHOT_LAYOUT.refW, uiH / ____exports.TOWER_SHOT_LAYOUT.refH) -- 283
	local ox = (uiW - ____exports.TOWER_SHOT_LAYOUT.refW * s) * 0.5 -- 284
	local oy = (uiH - ____exports.TOWER_SHOT_LAYOUT.refH * s) * 0.5 -- 285
	local lx = lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) -- 286
	local ly = lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34 -- 287
	return {s = s, ox = ox, oy = oy, anchors = { -- 289
		doorCenterX = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s, -- 294
		thresholdY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s, -- 295
		knockHandX = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s, -- 296
		knockHandY = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s, -- 297
		bookX = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s, -- 298
		bookY = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s, -- 299
		bookW = ____exports.TOWER_SHOT_LAYOUT.bookW * s, -- 300
		bookH = ____exports.TOWER_SHOT_LAYOUT.bookH * s, -- 301
		row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s, -- 302
		row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s, -- 303
		brushHoverTipX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s, -- 304
		brushHoverTipY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s, -- 305
		bowlRimX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s, -- 306
		bowlRimY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s, -- 307
		lampCurX = ox + lx * s, -- 308
		lampCurY = oy + ly * s -- 309
	}} -- 309
end -- 277
local function deriveStage(seqElapsed, active) -- 314
	if not active then -- 315
		return "idle" -- 316
	end -- 316
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 318
		return "porch_knock" -- 319
	end -- 319
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 321
		return "door_open" -- 322
	end -- 322
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 324
		return "book_row1" -- 325
	end -- 325
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 327
		return "pivot_hover" -- 328
	end -- 328
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 330
		return "diverge_action" -- 331
	end -- 331
	return "ending_hold" -- 333
end -- 314
--- 将字符切片数组按进度拼接为前 n 段（避免 Lua 字节切片截断 UTF-8 汉字）
local function joinPrefixTokens(tokens, progress) -- 337
	if progress <= 0 or #tokens == 0 then -- 338
		return "" -- 339
	end -- 339
	local count = math.max( -- 341
		1, -- 341
		math.min( -- 341
			#tokens, -- 341
			math.ceil(progress * #tokens) -- 341
		) -- 341
	) -- 341
	local out = "" -- 342
	local i = 0 -- 343
	do -- 343
		i = 0 -- 344
		while i < count do -- 344
			out = out .. tokens[i + 1] -- 345
			i = i + 1 -- 344
		end -- 344
	end -- 344
	return out -- 347
end -- 337
local ROW1_TOKENS = { -- 350
	"小", -- 350
	"满", -- 350
	"  ", -- 350
	"·", -- 350
	"  ", -- 350
	"已", -- 350
	"收" -- 350
} -- 350
local ROW2_SOLDIER_TOKENS = { -- 351
	"周", -- 351
	"戍", -- 351
	"  ", -- 351
	"·", -- 351
	"  ", -- 351
	"兄", -- 351
	"妹", -- 351
	"同", -- 351
	"行", -- 351
	"  ", -- 351
	"·", -- 351
	"  ", -- 351
	"已", -- 351
	"收" -- 351
} -- 351
local function asRecord(v) -- 353
	if v ~= nil and type(v) == "table" then -- 354
		return v -- 355
	end -- 355
	return nil -- 357
end -- 353
--- 描边椭圆（Dora DrawNode.drawEllipse 仅支持填充，描边用等分折线保证锐利清晰）
local function strokeEllipse(draw, cx, cy, rx, ry, width, color, segments) -- 361
	if segments == nil then -- 369
		segments = 24 -- 369
	end -- 369
	if rx <= 0.5 or ry <= 0.5 or width <= 0.05 then -- 371
		return -- 372
	end -- 372
	local step = math.pi * 2 / segments -- 374
	local prevX = cx + rx -- 375
	local prevY = cy -- 376
	local i = 1 -- 377
	do -- 377
		i = 1 -- 378
		while i <= segments do -- 378
			local ang = i * step -- 379
			local nx = cx + math.cos(ang) * rx -- 380
			local ny = cy + math.sin(ang) * ry -- 381
			draw:drawSegment( -- 382
				Vec2(prevX, prevY), -- 382
				Vec2(nx, ny), -- 382
				width, -- 382
				color -- 382
			) -- 382
			prevX = nx -- 383
			prevY = ny -- 384
			i = i + 1 -- 378
		end -- 378
	end -- 378
end -- 361
local STONE_EDGE_FALLBACK = MING_MATERIALS.mingStoneStep.edge or PALETTE.silkDim -- 388
____exports.TowerEndingsPlugin = __TS__Class() -- 390
local TowerEndingsPlugin = ____exports.TowerEndingsPlugin -- 390
TowerEndingsPlugin.name = "TowerEndingsPlugin" -- 390
function TowerEndingsPlugin.prototype.____constructor(self) -- 390
	self.id = "fe-05-tower-endings" -- 391
	self.active = false -- 393
	self.rehearsalActive = false -- 394
	self.rehearsalRoute = "child" -- 395
	self.activeRoute = "child" -- 396
	self.seqElapsed = 0 -- 398
	self.holdElapsed = 0 -- 399
	self.animTime = 0 -- 400
	self.doorOpened = false -- 403
	self.knockCount = 0 -- 404
	self.replyKnockCount = 0 -- 405
	self.row1Written = false -- 406
	self.row2Written = false -- 407
	self.registryAppendCount = 0 -- 408
	self.staleInputMustRelease = false -- 411
	self.confirmReady = false -- 412
	self.earlyInputBlockedCount = 0 -- 413
	self.rehearsalAcknowledged = false -- 414
	self.lastRoomKey = "" -- 417
	self.indoorRetryCount = 0 -- 419
	self.doorClosedAfterRetry = false -- 420
	self.sessionId = 0 -- 421
	self.lastUiW = 1280 -- 424
	self.lastUiH = 720 -- 425
	self.lastSubtitle = "" -- 426
	self.prevPhase = "" -- 427
	self.loopsActive = false -- 428
	self.doorOpenOverlayElapsed = -1 -- 430
end -- 390
function TowerEndingsPlugin.prototype.resolveRoute(self, p, view) -- 433
	if self.rehearsalActive then -- 434
		return self.rehearsalRoute -- 435
	end -- 435
	if view.storyRoute == "soldier" then -- 437
		return "soldier" -- 438
	end -- 438
	if view.storyRoute == "child" then -- 440
		return "child" -- 441
	end -- 441
	local runRec = asRecord(p.run) -- 444
	local ____asRecord_1 = asRecord -- 445
	local ____temp_0 -- 445
	if runRec ~= nil then -- 445
		____temp_0 = runRec.story -- 445
	else -- 445
		____temp_0 = nil -- 445
	end -- 445
	local storyRec = ____asRecord_1(____temp_0) -- 445
	if storyRec ~= nil and storyRec.ending == "reunion" then -- 446
		return "soldier" -- 447
	end -- 447
	return p.childMode and "child" or "soldier" -- 450
end -- 433
function TowerEndingsPlugin.prototype.clearSequenceState(self, keepIndoorDoorOpen) -- 453
	self.active = keepIndoorDoorOpen -- 454
	self.seqElapsed = keepIndoorDoorOpen and ____exports.TOWER_ENDING_TIMINGS.indoorCutSec or 0 -- 455
	self.holdElapsed = 0 -- 456
	self.doorOpened = keepIndoorDoorOpen -- 457
	self.knockCount = keepIndoorDoorOpen and 2 or 0 -- 458
	self.replyKnockCount = keepIndoorDoorOpen and 2 or 0 -- 459
	if not keepIndoorDoorOpen then -- 460
		self.row1Written = false -- 461
		self.row2Written = false -- 462
		self.registryAppendCount = 0 -- 463
	end -- 463
	self.staleInputMustRelease = true -- 465
	self.confirmReady = false -- 466
	self.earlyInputBlockedCount = 0 -- 467
	self.rehearsalAcknowledged = false -- 468
	self.lastSubtitle = "" -- 469
	self.doorOpenOverlayElapsed = -1 -- 470
end -- 453
function TowerEndingsPlugin.prototype.startRehearsal(self, route, contract, opts) -- 476
	self.rehearsalActive = true -- 481
	self.rehearsalRoute = route -- 482
	self.activeRoute = route -- 483
	local tag = opts and opts.tag or (route == "child" and "fe05-F03" or "fe05-M03") -- 484
	if contract ~= nil then -- 485
		contract:enterRehearsal(tag) -- 486
		contract:setMockRoute(route) -- 487
	end -- 487
	local isIndoor = (opts and opts.indoorRetry) == true -- 489
	self.sessionId = self.sessionId + 1 -- 490
	self:clearSequenceState(isIndoor) -- 491
	self.active = true -- 492
	self.doorClosedAfterRetry = false -- 493
	if isIndoor then -- 494
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 495
	end -- 495
	if (opts and opts.seekTime) ~= nil then -- 497
		self:seekRehearsal(opts.seekTime) -- 498
	end -- 498
end -- 476
function TowerEndingsPlugin.prototype.seekRehearsal(self, seconds) -- 503
	if not self.rehearsalActive then -- 504
		return -- 505
	end -- 505
	local t = math.max(0, seconds) -- 507
	self.seqElapsed = t -- 508
	self.holdElapsed = math.max(0, t - ____exports.TOWER_ENDING_TIMINGS.divergeEndSec) -- 509
	self.active = true -- 510
	self:syncDerivedMilestones(t, self.activeRoute) -- 511
	self.confirmReady = not self.staleInputMustRelease and t >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 512
end -- 503
function TowerEndingsPlugin.prototype.triggerIndoorRetry(self) -- 516
	if not self.doorOpened and self.seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 517
		self.doorOpened = true -- 518
	end -- 518
	self.indoorRetryCount = self.indoorRetryCount + 1 -- 520
	self.doorClosedAfterRetry = false -- 521
	self.doorOpened = true -- 522
	self.active = true -- 523
	self.seqElapsed = math.max( -- 524
		____exports.TOWER_ENDING_TIMINGS.indoorCutSec, -- 524
		math.min(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.row1StartSec) -- 524
	) -- 524
	self.holdElapsed = 0 -- 525
	self.knockCount = math.max(2, self.knockCount) -- 526
	self.replyKnockCount = math.max(2, self.replyKnockCount) -- 527
	self.staleInputMustRelease = true -- 529
	self.confirmReady = false -- 530
end -- 516
function TowerEndingsPlugin.prototype.stopRehearsal(self, contract) -- 534
	self.rehearsalActive = false -- 535
	self:clearSequenceState(false) -- 536
	self.indoorRetryCount = 0 -- 537
	self.doorClosedAfterRetry = false -- 538
	if contract ~= nil then -- 539
		contract:exitRehearsal() -- 540
	end -- 540
end -- 534
function TowerEndingsPlugin.prototype.getDebugState(self) -- 544
	local route = self.activeRoute -- 545
	local lampProg = route == "child" and smoothstep(5.2, 6.75, self.seqElapsed) or 0 -- 546
	local scaled = computeScaledAnchors(self.lastUiW, self.lastUiH, lampProg) -- 549
	local visualStyle = route == "child" and "lowpoly" or "pixel" -- 550
	local needleOnDesk = route == "soldier" and self.seqElapsed >= 5.55 -- 551
	local twoHandsBowl = route == "soldier" and self.seqElapsed >= 5.95 -- 552
	return { -- 554
		active = self.active, -- 555
		isRehearsal = self.rehearsalActive, -- 556
		route = route, -- 557
		visualStyle = visualStyle, -- 558
		stage = deriveStage(self.seqElapsed, self.active), -- 559
		seqElapsed = self.seqElapsed, -- 560
		holdElapsed = self.holdElapsed, -- 561
		doorOpened = self.doorOpened, -- 562
		knockCount = self.knockCount, -- 563
		replyKnockCount = self.replyKnockCount, -- 564
		row1Written = self.row1Written, -- 565
		row1Name = self.row1Written and "小满" or "", -- 566
		row2Written = self.row2Written, -- 567
		row2Name = self.row2Written and "周戍" or "", -- 568
		row2Blank = not self.row2Written, -- 569
		hasCompletionStamp = false, -- 570
		registryRowCapacity = 2, -- 571
		registryAppendCount = self.registryAppendCount, -- 572
		lampProgress = lampProg, -- 573
		lampAtWestWindow = route == "child" and lampProg >= 0.99, -- 574
		needleCaseOnDesk = needleOnDesk, -- 575
		twoHandsHoldingBowl = twoHandsBowl, -- 576
		staleInputMustRelease = self.staleInputMustRelease, -- 577
		confirmReady = self.confirmReady, -- 578
		earlyInputBlockedCount = self.earlyInputBlockedCount, -- 579
		rehearsalAcknowledged = self.rehearsalAcknowledged, -- 580
		indoorRetryCount = self.indoorRetryCount, -- 581
		doorClosedAfterRetry = self.doorClosedAfterRetry, -- 582
		subtitleText = self.lastSubtitle, -- 583
		anchors = scaled.anchors -- 584
	} -- 584
end -- 544
function TowerEndingsPlugin.prototype.syncRuntimeHook(self) -- 588
	local g = _G -- 589
	local ____temp_8 -- 590
	if g.package ~= nil then -- 590
		____temp_8 = g.package.loaded -- 590
	else -- 590
		____temp_8 = nil -- 590
	end -- 590
	local loaded = ____temp_8 -- 590
	if loaded == nil then -- 591
		return -- 592
	end -- 592
	local rawFe = loaded["watch.fe"] -- 594
	if rawFe ~= nil and type(rawFe) == "table" then -- 595
		local watchFe = rawFe -- 596
		if watchFe.towerEndings ~= self then -- 597
			watchFe.towerEndings = self -- 598
		end -- 598
	end -- 598
end -- 588
function TowerEndingsPlugin.prototype.onBindPlay(self, p, view) -- 605
	self:syncRuntimeHook() -- 606
	self.sessionId = self.sessionId + 1 -- 607
	self.loopsActive = false -- 608
	self.prevPhase = p.phase -- 609
	if self.rehearsalActive then -- 611
		return -- 612
	end -- 612
	local route = self:resolveRoute(p, view) -- 615
	local isTower = p.room.key == "tower" -- 616
	local alreadyCutscenePhase = isTower and (p.phase == "tower-given" or p.phase == "tower-end") -- 617
	local alreadyIndoorPhase = isTower and (p.phase == "tower-enter" or p.phase == "tower-desk" or alreadyCutscenePhase) -- 618
	local sameRunIndoorRetry = isTower and self.lastRoomKey == "tower" and self.doorOpened and p.run == self.lastRunRef and route == self.activeRoute and (p.checkpoint > 0 or alreadyIndoorPhase) -- 623
	self.activeRoute = route -- 630
	self.lastRoomKey = p.room.key -- 631
	self.lastRunRef = p.run -- 632
	if not isTower then -- 634
		self:clearSequenceState(false) -- 635
		self.indoorRetryCount = 0 -- 636
		self.doorClosedAfterRetry = false -- 637
		return -- 638
	end -- 638
	if sameRunIndoorRetry or alreadyCutscenePhase then -- 641
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 643
		self.doorClosedAfterRetry = false -- 644
		self:clearSequenceState(true) -- 645
		if p.phase == "tower-end" then -- 646
			self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.divergeEndSec -- 647
			self:syncDerivedMilestones(self.seqElapsed, route) -- 648
		end -- 648
		return -- 650
	end -- 650
	if p.phase == "tower-enter" or p.phase == "tower-desk" then -- 653
		self:clearSequenceState(false) -- 655
		self.doorOpened = true -- 656
		self.replyKnockCount = 2 -- 657
		self.active = false -- 658
		return -- 659
	end -- 659
	self:clearSequenceState(false) -- 663
	self.indoorRetryCount = 0 -- 664
	self.doorClosedAfterRetry = false -- 665
end -- 605
function TowerEndingsPlugin.prototype.update(self, ctx) -- 668
	self:syncRuntimeHook() -- 669
	self.lastUiW = ctx.uiW -- 670
	self.lastUiH = ctx.uiH -- 671
	local p = ctx.p -- 672
	if not self.rehearsalActive and p.room.key ~= "tower" then -- 674
		if self.loopsActive then -- 675
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 676
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 677
			self.loopsActive = false -- 678
		end -- 678
		self.active = false -- 680
		return -- 681
	end -- 681
	local route = self:resolveRoute(p, ctx.view) -- 684
	self.activeRoute = route -- 685
	if not self.rehearsalActive then -- 687
		self:stepLiveSync(ctx, route) -- 688
	else -- 688
		self:stepRehearsal(ctx, route) -- 690
	end -- 690
	if not self.active then -- 693
		local inInteractiveHall = not self.rehearsalActive and p.room.key == "tower" and (p.phase == "tower-enter" or p.phase == "tower-desk") -- 694
		if self.loopsActive and not inInteractiveHall then -- 696
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 697
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 698
			self.loopsActive = false -- 699
		end -- 699
		return -- 701
	end -- 701
	if not ctx.paused and ctx.worldDt > 0 then -- 705
		self.animTime = self.animTime + ctx.worldDt -- 706
		self:syncDerivedMilestones(self.seqElapsed, route) -- 707
		self:syncAudioCues(ctx.audio, ctx, route) -- 708
		self:stepInputGuard(ctx.input) -- 709
	elseif not ctx.paused then -- 710
		self:syncDerivedMilestones(self.seqElapsed, route) -- 712
		self:stepInputGuard(ctx.input) -- 713
	end -- 713
	self.lastSubtitle = self:composeSubtitle(route) -- 716
end -- 668
function TowerEndingsPlugin.prototype.stepLiveSync(self, ctx, route) -- 719
	local p = ctx.p -- 720
	local phase = p.phase -- 721
	local cameFromKnock = self.prevPhase == "tower-knock" -- 722
	local justEnteredKnock = self.prevPhase ~= "tower-knock" and phase == "tower-knock" -- 723
	local justEnteredEnter = self.prevPhase ~= "tower-enter" and phase == "tower-enter" -- 724
	local justEnteredGiven = self.prevPhase ~= "tower-given" and phase == "tower-given" -- 725
	local justEnteredEnd = self.prevPhase ~= "tower-end" and phase == "tower-end" -- 726
	self.prevPhase = phase -- 727
	if phase == "tower-wait" then -- 729
		self.doorOpenOverlayElapsed = -1 -- 731
		self.active = false -- 732
		return -- 733
	end -- 733
	if phase == "tower-enter" then -- 736
		self.doorOpened = true -- 738
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 739
		if justEnteredEnter and self.indoorRetryCount == 0 and not ctx.paused then -- 740
			local tick = p.ticks -- 741
			self:playTowerOnce( -- 742
				ctx.audio, -- 742
				"reply1", -- 742
				"sfx", -- 742
				____exports.TOWER_AUDIO_FILES.reply1, -- 742
				0.78, -- 742
				"tower:reply:1", -- 742
				tick -- 742
			) -- 742
			self:playTowerOnce( -- 743
				ctx.audio, -- 743
				"reply2", -- 743
				"sfx", -- 743
				____exports.TOWER_AUDIO_FILES.reply2, -- 743
				0.8, -- 743
				"tower:reply:2", -- 743
				tick -- 743
			) -- 743
			self:playTowerOnce( -- 744
				ctx.audio, -- 744
				"door_open", -- 744
				"sfx", -- 744
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 744
				0.84, -- 744
				"tower:door_open", -- 744
				tick -- 744
			) -- 744
			ctx.audio:playLoop( -- 745
				"tower_room_warm", -- 745
				"ambience", -- 745
				____exports.TOWER_AUDIO_FILES.roomWarm, -- 745
				0.28, -- 745
				tick -- 745
			) -- 745
			self.loopsActive = true -- 746
			if cameFromKnock then -- 747
				self.doorOpenOverlayElapsed = 0 -- 748
			end -- 748
		end -- 748
		if self.doorOpenOverlayElapsed >= 0 then -- 751
			if p.player.x >= p.ox + 520 then -- 752
				self.doorOpenOverlayElapsed = -1 -- 753
			elseif not ctx.paused and ctx.worldDt > 0 then -- 754
				self.doorOpenOverlayElapsed = self.doorOpenOverlayElapsed + ctx.worldDt -- 755
				if self.doorOpenOverlayElapsed >= 0.9 then -- 756
					self.doorOpenOverlayElapsed = -1 -- 757
				end -- 757
			end -- 757
		end -- 757
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.doorOpenSec) -- 761
		self.active = false -- 762
		self:syncDerivedMilestones(self.seqElapsed, route) -- 763
		return -- 764
	end -- 764
	if phase == "tower-desk" then -- 767
		self.doorOpenOverlayElapsed = -1 -- 769
		self.doorOpened = true -- 770
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 771
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 772
		self.active = false -- 773
		self:syncDerivedMilestones(self.seqElapsed, route) -- 774
		return -- 775
	end -- 775
	if not self.active then -- 778
		self.active = true -- 779
		self.staleInputMustRelease = ctx.input.interact.held or ctx.input.retry.held or ctx.input.interact.pressed -- 780
		self.confirmReady = false -- 781
	end -- 781
	if justEnteredKnock then -- 784
		self.seqElapsed = p.phaseTick / 60 -- 785
		self.holdElapsed = 0 -- 786
		self.staleInputMustRelease = true -- 787
		self.confirmReady = false -- 788
	elseif justEnteredGiven then -- 789
		self.doorOpened = true -- 790
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 791
	elseif justEnteredEnd then -- 792
		self.doorOpened = true -- 793
		self.seqElapsed = math.max(self.seqElapsed, 3.6 + p.phaseTick / 60) -- 795
	end -- 795
	if not ctx.paused and #ctx.events.rawEvents > 0 then -- 799
		local i = 0 -- 800
		do -- 800
			i = 0 -- 801
			while i < #ctx.events.rawEvents do -- 801
				local ev = ctx.events.rawEvents[i + 1] -- 802
				if ev.name == "knock" then -- 803
					local cnt = type(ev.data.count) == "number" and ev.data.count or self.knockCount + 1 -- 804
					if cnt >= 1 and self.knockCount < 1 then -- 805
						self.knockCount = 1 -- 806
						self:playTowerOnce( -- 807
							ctx.audio, -- 807
							"knock1", -- 807
							"sfx", -- 807
							____exports.TOWER_AUDIO_FILES.knock1, -- 807
							0.88, -- 807
							"tower:knock:1", -- 807
							ev.tick, -- 807
							ev.seq -- 807
						) -- 807
					end -- 807
					if cnt >= 2 and self.knockCount < 2 then -- 809
						self.knockCount = 2 -- 810
						self:playTowerOnce( -- 811
							ctx.audio, -- 811
							"knock2", -- 811
							"sfx", -- 811
							____exports.TOWER_AUDIO_FILES.knock2, -- 811
							0.9, -- 811
							"tower:knock:2", -- 811
							ev.tick, -- 811
							ev.seq -- 811
						) -- 811
					end -- 811
				end -- 811
				i = i + 1 -- 801
			end -- 801
		end -- 801
	end -- 801
	if not ctx.paused and ctx.worldDt > 0 then -- 817
		if phase == "tower-knock" then -- 818
			local backendSec = math.min(____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60) -- 820
			self.seqElapsed = math.max(self.seqElapsed + ctx.worldDt, backendSec) -- 821
			if self.seqElapsed > ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 then -- 822
				self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 -- 823
			end -- 823
		else -- 823
			self.seqElapsed = self.seqElapsed + ctx.worldDt -- 826
			if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 827
				self.holdElapsed = self.holdElapsed + ctx.worldDt -- 828
			end -- 828
		end -- 828
	end -- 828
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 833
		self.doorClosedAfterRetry = true -- 834
	end -- 834
	self:syncDerivedMilestones(self.seqElapsed, route) -- 836
end -- 719
function TowerEndingsPlugin.prototype.stepRehearsal(self, ctx, route) -- 839
	self.active = true -- 840
	if not ctx.paused and ctx.worldDt > 0 then -- 841
		self.seqElapsed = self.seqElapsed + ctx.worldDt -- 842
		if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 843
			self.holdElapsed = self.holdElapsed + ctx.worldDt -- 844
		end -- 844
	end -- 844
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 847
		self.doorClosedAfterRetry = true -- 848
	end -- 848
	self:syncDerivedMilestones(self.seqElapsed, route) -- 850
end -- 839
function TowerEndingsPlugin.prototype.syncDerivedMilestones(self, t, route) -- 853
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec and self.knockCount < 1 then -- 854
		self.knockCount = 1 -- 855
	end -- 855
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec and self.knockCount < 2 then -- 857
		self.knockCount = 2 -- 858
	end -- 858
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec and self.replyKnockCount < 1 then -- 860
		self.replyKnockCount = 1 -- 861
	end -- 861
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec and self.replyKnockCount < 2 then -- 863
		self.replyKnockCount = 2 -- 864
	end -- 864
	if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 866
		self.doorOpened = true -- 867
	end -- 867
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec and not self.row1Written then -- 870
		self.row1Written = true -- 871
		self.registryAppendCount = self.registryAppendCount + 1 -- 872
	end -- 872
	if route == "soldier" and t >= 4.6 and not self.row2Written then -- 874
		self.row2Written = true -- 875
		self.registryAppendCount = self.registryAppendCount + 1 -- 876
	end -- 876
	if route == "child" and self.row2Written then -- 878
		self.row2Written = false -- 880
		self.registryAppendCount = self.row1Written and 1 or 0 -- 881
	end -- 881
end -- 853
function TowerEndingsPlugin.prototype.stepInputGuard(self, input) -- 885
	local keyHeld = input.interact.held or input.retry.held -- 886
	local keyPressed = input.interact.pressed or input.retry.pressed -- 887
	local readyTime = self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 888
	if self.staleInputMustRelease then -- 890
		if not keyHeld then -- 891
			self.staleInputMustRelease = false -- 892
		elseif keyPressed then -- 893
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 894
		end -- 894
		self.confirmReady = false -- 896
		return -- 897
	end -- 897
	if not readyTime then -- 900
		if keyPressed then -- 901
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 902
			self.staleInputMustRelease = keyHeld -- 903
		end -- 903
		self.confirmReady = false -- 905
		return -- 906
	end -- 906
	self.confirmReady = true -- 909
	if self.rehearsalActive and keyPressed then -- 910
		self.rehearsalAcknowledged = true -- 911
	end -- 911
end -- 885
function TowerEndingsPlugin.prototype.playTowerOnce(self, audio, tag, track, path, volume, cueId, tick, seq) -- 915
	if seq == nil then -- 923
		seq = -1 -- 923
	end -- 923
	local dedupeKey = (("tower:s" .. tostring(self.sessionId)) .. ":") .. tag -- 925
	audio:playOnce( -- 926
		dedupeKey, -- 926
		track, -- 926
		path, -- 926
		volume, -- 926
		cueId, -- 926
		tick, -- 926
		seq -- 926
	) -- 926
end -- 915
function TowerEndingsPlugin.prototype.syncAudioCues(self, audio, ctx, route) -- 929
	local t = self.seqElapsed -- 930
	local tick = ctx.p.ticks -- 931
	local indoorK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.5, t) -- 932
	self.loopsActive = true -- 935
	audio:playLoop( -- 936
		"tower_wind_cold", -- 936
		"wind", -- 936
		____exports.TOWER_AUDIO_FILES.windCold, -- 936
		lerp(0.36, 0.14, indoorK), -- 936
		tick -- 936
	) -- 936
	if indoorK > 0.05 then -- 937
		audio:playLoop( -- 938
			"tower_room_warm", -- 938
			"ambience", -- 938
			____exports.TOWER_AUDIO_FILES.roomWarm, -- 938
			lerp(0.06, 0.34, indoorK), -- 938
			tick -- 938
		) -- 938
	end -- 938
	if self.indoorRetryCount == 0 then -- 942
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec then -- 943
			self:playTowerOnce( -- 944
				audio, -- 944
				"knock1", -- 944
				"sfx", -- 944
				____exports.TOWER_AUDIO_FILES.knock1, -- 944
				0.88, -- 944
				"tower:knock:1", -- 944
				tick -- 944
			) -- 944
		end -- 944
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec then -- 946
			self:playTowerOnce( -- 947
				audio, -- 947
				"knock2", -- 947
				"sfx", -- 947
				____exports.TOWER_AUDIO_FILES.knock2, -- 947
				0.9, -- 947
				"tower:knock:2", -- 947
				tick -- 947
			) -- 947
		end -- 947
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 949
			self:playTowerOnce( -- 950
				audio, -- 950
				"reply1", -- 950
				"sfx", -- 950
				____exports.TOWER_AUDIO_FILES.reply1, -- 950
				0.78, -- 950
				"tower:reply:1", -- 950
				tick -- 950
			) -- 950
		end -- 950
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec then -- 952
			self:playTowerOnce( -- 953
				audio, -- 953
				"reply2", -- 953
				"sfx", -- 953
				____exports.TOWER_AUDIO_FILES.reply2, -- 953
				0.8, -- 953
				"tower:reply:2", -- 953
				tick -- 953
			) -- 953
		end -- 953
		if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 955
			self:playTowerOnce( -- 956
				audio, -- 956
				"door_open", -- 956
				"sfx", -- 956
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 956
				0.84, -- 956
				"tower:door_open", -- 956
				tick -- 956
			) -- 956
		end -- 956
	end -- 956
	if t >= 1.5 then -- 960
		self:playTowerOnce( -- 961
			audio, -- 961
			"book_open", -- 961
			"sfx", -- 961
			____exports.TOWER_AUDIO_FILES.bookOpen, -- 961
			0.82, -- 961
			"tower:book_open", -- 961
			tick -- 961
		) -- 961
	end -- 961
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 963
		self:playTowerOnce( -- 964
			audio, -- 964
			"brush1", -- 964
			"sfx", -- 964
			____exports.TOWER_AUDIO_FILES.brush1, -- 964
			0.8, -- 964
			"tower:brush:row1", -- 964
			tick -- 964
		) -- 964
	end -- 964
	if route == "child" then -- 967
		if t >= 4.35 then -- 968
			self:playTowerOnce( -- 969
				audio, -- 969
				"f03_line", -- 969
				"voice", -- 969
				____exports.TOWER_AUDIO_FILES.lineXiaomanLamp, -- 969
				0.86, -- 969
				"tower:f03:line_lamp", -- 969
				tick -- 969
			) -- 969
		end -- 969
		if t >= 4.45 then -- 971
			self:playTowerOnce( -- 972
				audio, -- 972
				"f03_bowl", -- 972
				"sfx", -- 972
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 972
				0.8, -- 972
				"tower:bowl_set", -- 972
				tick -- 972
			) -- 972
		end -- 972
		if t >= 5.2 then -- 974
			self:playTowerOnce( -- 975
				audio, -- 975
				"f03_lamp", -- 975
				"sfx", -- 975
				____exports.TOWER_AUDIO_FILES.lampMove, -- 975
				0.82, -- 975
				"tower:f03:lamp_move", -- 975
				tick -- 975
			) -- 975
		end -- 975
	else -- 975
		if t >= 4.28 then -- 978
			self:playTowerOnce( -- 979
				audio, -- 979
				"m03_line", -- 979
				"voice", -- 979
				____exports.TOWER_AUDIO_FILES.lineZhoushuName, -- 979
				0.9, -- 979
				"tower:m03:line_name", -- 979
				tick -- 979
			) -- 979
		end -- 979
		if t >= 4.62 then -- 981
			self:playTowerOnce( -- 982
				audio, -- 982
				"brush2", -- 982
				"sfx", -- 982
				____exports.TOWER_AUDIO_FILES.brush2, -- 982
				0.82, -- 982
				"tower:brush:row2", -- 982
				tick -- 982
			) -- 982
		end -- 982
		if t >= 5.55 then -- 984
			self:playTowerOnce( -- 985
				audio, -- 985
				"m03_needle", -- 985
				"sfx", -- 985
				____exports.TOWER_AUDIO_FILES.needlePlace, -- 985
				0.8, -- 985
				"tower:m03:needle_place", -- 985
				tick -- 985
			) -- 985
		end -- 985
		if t >= 6.02 then -- 987
			self:playTowerOnce( -- 988
				audio, -- 988
				"m03_bowl", -- 988
				"sfx", -- 988
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 988
				0.82, -- 988
				"tower:bowl_set", -- 988
				tick -- 988
			) -- 988
		end -- 988
	end -- 988
end -- 929
function TowerEndingsPlugin.prototype.composeSubtitle(self, route) -- 993
	local t = self.seqElapsed -- 994
	if t < ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 995
		return "[两下轻敲]  门外厚木上传来两声轻敲。" -- 996
	end -- 996
	if t < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 998
		return "[门内回敲]  静默一息，门后轻轻回敲两声。" -- 999
	end -- 999
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1001
		return route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 1002
	end -- 1002
	if t < ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 1006
		return route == "child" and "她把针套与纸条摊在案前，守卒展开收籍末页。" or "两人站在值夜室内，守卒摊开收籍末页。" -- 1007
	end -- 1007
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 1011
		return "守卒蘸墨提笔，在第一行写下「小满」。" -- 1012
	end -- 1012
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1014
		return "笔尖停在第二行上方。" -- 1015
	end -- 1015
	if route == "child" then -- 1017
		if t < 6.7 then -- 1018
			return F03_DIALOGUE -- 1019
		end -- 1019
		return "" -- 1021
	end -- 1021
	if t < 5.45 then -- 1023
		return M03_DIALOGUE -- 1024
	end -- 1024
	if t < 6.85 then -- 1026
		return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。" -- 1027
	end -- 1027
	return "" -- 1029
end -- 993
function TowerEndingsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1034
	if not self.active then -- 1041
		if not self.rehearsalActive and ctx.p.room.key == "tower" and ctx.p.phase == "tower-enter" and self.doorOpenOverlayElapsed >= 0 then -- 1042
			local u = clamp01(self.doorOpenOverlayElapsed / 0.9) -- 1044
			local fade = 1 - smoothstep(0.28, 1, u) -- 1045
			if fade > 0.02 then -- 1046
				local route = self.activeRoute -- 1047
				local openK = smoothstep(0, 0.55, u) -- 1048
				local cx = ctx.uiW * 0.5 -- 1049
				local cy = ctx.uiH * 0.46 -- 1050
				uiDraw:drawRect( -- 1051
					Rect(0, 0, ctx.uiW, ctx.uiH), -- 1051
					Color( -- 1051
						8, -- 1051
						10, -- 1051
						16, -- 1051
						math.floor(145 * fade + 0.5) -- 1051
					) -- 1051
				) -- 1051
				fillRadialGlow( -- 1052
					uiGlow, -- 1053
					cx + 42 * (1 - openK), -- 1054
					cy + 16, -- 1055
					ctx.uiW * (0.26 + 0.18 * openK), -- 1056
					ctx.uiH * (0.34 + 0.16 * openK), -- 1057
					Color( -- 1058
						248, -- 1058
						212, -- 1058
						144, -- 1058
						math.floor(128 * fade + 0.5) -- 1058
					), -- 1058
					Color(220, 154, 72, 0), -- 1059
					18 -- 1060
				) -- 1060
				self:drawMingLantern( -- 1062
					uiInkDraw, -- 1062
					uiGlow, -- 1062
					cx + 66 - openK * 24, -- 1062
					cy + 28, -- 1062
					1.05, -- 1062
					fade * (0.45 + 0.55 * openK), -- 1062
					1 -- 1062
				) -- 1062
				local cap = route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 1063
				drawSilkVeil( -- 1066
					uiDraw, -- 1066
					uiArt, -- 1066
					"tower_door_open_veil", -- 1066
					cx, -- 1066
					ctx.uiH - 86, -- 1066
					560, -- 1066
					38, -- 1066
					PALETTE.inkWarm, -- 1066
					0.78 * fade, -- 1066
					2 -- 1066
				) -- 1066
				ctx.texts:put( -- 1067
					"sm", -- 1067
					cap, -- 1067
					cx, -- 1067
					ctx.uiH - 86, -- 1067
					toColor(PALETTE.amberCore), -- 1067
					0.5, -- 1067
					0.5, -- 1067
					"Center", -- 1067
					1, -- 1067
					fade, -- 1067
					0.08 -- 1067
				) -- 1067
			end -- 1067
		end -- 1067
		return false -- 1070
	end -- 1070
	local route = self.activeRoute -- 1073
	local t = self.seqElapsed -- 1074
	local lampProg = route == "child" and smoothstep(5.2, 6.75, t) or 0 -- 1075
	local scaled = computeScaledAnchors(ctx.uiW, ctx.uiH, lampProg) -- 1076
	local s = scaled.s -- 1077
	local ox = scaled.ox -- 1078
	local oy = scaled.oy -- 1079
	uiDraw:drawRect( -- 1082
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1082
		Color(8, 10, 16, 255) -- 1082
	) -- 1082
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1084
		self:drawAct1PorchAndDoor( -- 1086
			uiDraw, -- 1086
			uiInkDraw, -- 1086
			uiArt, -- 1086
			uiGlow, -- 1086
			ctx, -- 1086
			route, -- 1086
			s, -- 1086
			ox, -- 1086
			oy -- 1086
		) -- 1086
		local fadeOut = smoothstep(1.22, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec, t) -- 1088
		if fadeOut > 0.01 then -- 1089
			uiInkDraw:drawRect( -- 1090
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1090
				Color( -- 1090
					8, -- 1090
					10, -- 1090
					16, -- 1090
					math.floor(230 * fadeOut + 0.5) -- 1090
				) -- 1090
			) -- 1090
		end -- 1090
	else -- 1090
		self:drawAct2And3Guardroom( -- 1094
			uiDraw, -- 1094
			uiInkDraw, -- 1094
			uiArt, -- 1094
			uiGlow, -- 1094
			ctx, -- 1094
			route, -- 1094
			lampProg, -- 1094
			s, -- 1094
			ox, -- 1094
			oy -- 1094
		) -- 1094
		local fadeIn = 1 - smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.24, t) -- 1095
		if fadeIn > 0.01 then -- 1096
			uiInkDraw:drawRect( -- 1097
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1097
				Color( -- 1097
					8, -- 1097
					10, -- 1097
					16, -- 1097
					math.floor(220 * fadeIn + 0.5) -- 1097
				) -- 1097
			) -- 1097
		end -- 1097
	end -- 1097
	local barH = math.floor(____exports.TOWER_SHOT_LAYOUT.letterboxH * s + 0.5) -- 1102
	uiInkDraw:drawRect( -- 1103
		Rect(0, ctx.uiH - barH, ctx.uiW, barH), -- 1103
		Color(7, 9, 14, 248) -- 1103
	) -- 1103
	uiInkDraw:drawRect( -- 1104
		Rect(0, 0, ctx.uiW, barH), -- 1104
		Color(7, 9, 14, 248) -- 1104
	) -- 1104
	uiInkDraw:drawSegment( -- 1105
		Vec2(0, ctx.uiH - barH), -- 1105
		Vec2(ctx.uiW, ctx.uiH - barH), -- 1105
		0.9, -- 1105
		toColor(PALETTE.silkDim, 82) -- 1105
	) -- 1105
	uiInkDraw:drawSegment( -- 1106
		Vec2(0, barH), -- 1106
		Vec2(ctx.uiW, barH), -- 1106
		0.9, -- 1106
		toColor(PALETTE.silkDim, 82) -- 1106
	) -- 1106
	self:drawDialogueSubtitle( -- 1109
		uiDraw, -- 1109
		uiInkDraw, -- 1109
		uiArt, -- 1109
		ctx, -- 1109
		route, -- 1109
		s, -- 1109
		barH -- 1109
	) -- 1109
	return true -- 1111
end -- 1034
function TowerEndingsPlugin.prototype.drawAct1PorchAndDoor(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1116
	local t = self.seqElapsed -- 1127
	local isLowpoly = route == "child" -- 1128
	local openK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, 1.24, t) -- 1129
	local doorCx = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s -- 1130
	local threshY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s -- 1131
	local doorW = ____exports.TOWER_SHOT_LAYOUT.doorW * s -- 1132
	local doorH = ____exports.TOWER_SHOT_LAYOUT.doorH * s -- 1133
	local doorL = doorCx - doorW * 0.5 -- 1134
	local doorR = doorCx + doorW * 0.5 -- 1135
	local k1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock1Sec) / 0.055) ^ 2) -- 1138
	local k2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock2Sec) / 0.055) ^ 2) -- 1139
	local r1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply1Sec) / 0.06) ^ 2) -- 1140
	local r2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply2Sec) / 0.06) ^ 2) -- 1141
	local doorShakeX = (k1Pulse + k2Pulse) * 2.4 * s * math.sin(t * 95) + (r1Pulse + r2Pulse) * 1.4 * s * math.sin(t * 80) -- 1142
	if isLowpoly then -- 1145
		local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, openK * 0.62) -- 1147
		fillVGradRect( -- 1148
			uiDraw, -- 1149
			0, -- 1149
			0, -- 1149
			ctx.uiW, -- 1149
			ctx.uiH, -- 1149
			Color(12, 16, 26, 255), -- 1150
			Color(20, 28, 44, 255) -- 1151
		) -- 1151
		local wallCol = shadeSurface( -- 1154
			MING_MATERIALS.mingBrickDark.base, -- 1154
			vec3(0, 0, -1), -- 1154
			24, -- 1154
			1, -- 1154
			light, -- 1154
			MING_MATERIALS.mingBrickDark -- 1154
		) -- 1154
		local jambCol = shadeSurface( -- 1155
			MING_MATERIALS.mingBrick.base, -- 1155
			vec3(0.75, 0.15, -0.64), -- 1155
			10, -- 1155
			1, -- 1155
			light, -- 1155
			MING_MATERIALS.mingBrick -- 1155
		) -- 1155
		local jambRCol = shadeSurface( -- 1156
			MING_MATERIALS.mingBrick.base, -- 1156
			vec3(-0.75, 0.15, -0.64), -- 1156
			10, -- 1156
			1, -- 1156
			light, -- 1156
			MING_MATERIALS.mingBrick -- 1156
		) -- 1156
		local lintelCol = shadeSurface( -- 1157
			MING_MATERIALS.mingStoneStep.base, -- 1157
			vec3(0, -0.55, -0.83), -- 1157
			6, -- 1157
			1, -- 1157
			light, -- 1157
			MING_MATERIALS.mingStoneStep -- 1157
		) -- 1157
		local stepCol = shadeSurface( -- 1158
			MING_MATERIALS.mingStoneStep.base, -- 1158
			vec3(0, 0.92, -0.39), -- 1158
			0, -- 1158
			1, -- 1158
			light, -- 1158
			MING_MATERIALS.mingStoneStep -- 1158
		) -- 1158
		uiDraw:drawRect( -- 1160
			Rect(0, threshY, doorL - 26 * s, ctx.uiH - threshY), -- 1160
			toColor(wallCol) -- 1160
		) -- 1160
		uiDraw:drawRect( -- 1161
			Rect(doorR + 26 * s, threshY, ctx.uiW - (doorR + 26 * s), ctx.uiH - threshY), -- 1161
			toColor(wallCol) -- 1161
		) -- 1161
		uiDraw:drawPolygon( -- 1163
			{ -- 1163
				Vec2(doorL - 26 * s, threshY), -- 1164
				Vec2(doorL, threshY + 12 * s), -- 1165
				Vec2(doorL, threshY + doorH - 8 * s), -- 1166
				Vec2(doorL - 26 * s, threshY + doorH + 18 * s) -- 1167
			}, -- 1167
			toColor(jambCol), -- 1168
			1, -- 1168
			toColor(PALETTE.silkDim, 68) -- 1168
		) -- 1168
		uiDraw:drawPolygon( -- 1169
			{ -- 1169
				Vec2(doorR + 26 * s, threshY), -- 1170
				Vec2(doorR, threshY + 12 * s), -- 1171
				Vec2(doorR, threshY + doorH - 8 * s), -- 1172
				Vec2(doorR + 26 * s, threshY + doorH + 18 * s) -- 1173
			}, -- 1173
			toColor(jambRCol), -- 1174
			1, -- 1174
			toColor(PALETTE.silkDim, 68) -- 1174
		) -- 1174
		uiDraw:drawPolygon( -- 1176
			{ -- 1176
				Vec2(doorL - 44 * s, threshY + doorH + 18 * s), -- 1177
				Vec2(doorR + 44 * s, threshY + doorH + 18 * s), -- 1178
				Vec2(doorR + 58 * s, threshY + doorH + 92 * s), -- 1179
				Vec2(doorL - 58 * s, threshY + doorH + 92 * s) -- 1180
			}, -- 1180
			toColor(lintelCol), -- 1181
			1.1, -- 1181
			toColor(STONE_EDGE_FALLBACK, 130) -- 1181
		) -- 1181
		uiDraw:drawRect( -- 1183
			Rect(0, 0, ctx.uiW, threshY), -- 1183
			Color(16, 20, 30, 255) -- 1183
		) -- 1183
		uiDraw:drawPolygon( -- 1184
			{ -- 1184
				Vec2(doorL - 58 * s, threshY - 20 * s), -- 1185
				Vec2(doorR + 58 * s, threshY - 20 * s), -- 1186
				Vec2(doorR + 28 * s, threshY + 12 * s), -- 1187
				Vec2(doorL - 28 * s, threshY + 12 * s) -- 1188
			}, -- 1188
			toColor(stepCol), -- 1189
			1, -- 1189
			toColor(STONE_EDGE_FALLBACK, 150) -- 1189
		) -- 1189
		uiDraw:drawPolygon( -- 1191
			{ -- 1191
				Vec2(0, 0), -- 1192
				Vec2(142 * s, 0), -- 1193
				Vec2(114 * s, ctx.uiH), -- 1194
				Vec2(0, ctx.uiH) -- 1195
			}, -- 1195
			Color(10, 14, 22, 220) -- 1196
		) -- 1196
		uiDraw:drawPolygon( -- 1197
			{ -- 1197
				Vec2(ctx.uiW - 142 * s, 0), -- 1198
				Vec2(ctx.uiW, 0), -- 1199
				Vec2(ctx.uiW, ctx.uiH), -- 1200
				Vec2(ctx.uiW - 114 * s, ctx.uiH) -- 1201
			}, -- 1201
			Color(10, 14, 22, 220) -- 1202
		) -- 1202
	else -- 1202
		fillVGradRect( -- 1205
			uiDraw, -- 1206
			0, -- 1206
			0, -- 1206
			ctx.uiW, -- 1206
			ctx.uiH, -- 1206
			Color(18, 22, 32, 255), -- 1207
			Color(32, 38, 52, 255) -- 1208
		) -- 1208
		uiDraw:drawPolygon( -- 1211
			{ -- 1211
				Vec2(0, threshY), -- 1212
				Vec2(doorL, threshY), -- 1213
				Vec2(doorL, threshY + 188 * s), -- 1214
				Vec2(doorL * 0.55, threshY + 230 * s), -- 1215
				Vec2(doorL * 0.22, threshY + 172 * s), -- 1216
				Vec2(0, threshY + 196 * s) -- 1217
			}, -- 1217
			Color(26, 30, 40, 235) -- 1218
		) -- 1218
		uiDraw:drawPolygon( -- 1219
			{ -- 1219
				Vec2(doorR, threshY), -- 1220
				Vec2(ctx.uiW, threshY), -- 1221
				Vec2(ctx.uiW, threshY + 218 * s), -- 1222
				Vec2(doorR + (ctx.uiW - doorR) * 0.56, threshY + 248 * s), -- 1223
				Vec2(doorR, threshY + 178 * s) -- 1224
			}, -- 1224
			Color(26, 30, 40, 235) -- 1225
		) -- 1225
		uiDraw:drawRect( -- 1227
			Rect(0, threshY, doorL, ctx.uiH - threshY), -- 1227
			Color(54, 56, 62, 255), -- 1227
			1, -- 1227
			Color(88, 90, 96, 155) -- 1227
		) -- 1227
		uiDraw:drawRect( -- 1228
			Rect(doorR, threshY, ctx.uiW - doorR, ctx.uiH - threshY), -- 1228
			Color(54, 56, 62, 255), -- 1228
			1, -- 1228
			Color(88, 90, 96, 155) -- 1228
		) -- 1228
		uiDraw:drawRect( -- 1229
			Rect(doorL - 28 * s, threshY + doorH, doorW + 56 * s, 68 * s), -- 1229
			Color(72, 68, 62, 255), -- 1229
			1, -- 1229
			Color(124, 114, 100, 175) -- 1229
		) -- 1229
		local row = 0 -- 1230
		do -- 1230
			row = 0 -- 1231
			while row < 10 do -- 1231
				local by = threshY + row * 46 * s -- 1232
				uiDraw:drawSegment( -- 1233
					Vec2(0, by), -- 1233
					Vec2(doorL, by), -- 1233
					1, -- 1233
					Color(34, 36, 42, 175) -- 1233
				) -- 1233
				uiDraw:drawSegment( -- 1234
					Vec2(doorR, by), -- 1234
					Vec2(ctx.uiW, by), -- 1234
					1, -- 1234
					Color(34, 36, 42, 175) -- 1234
				) -- 1234
				local stag = row % 2 * 34 * s -- 1235
				local col = 0 -- 1236
				do -- 1236
					col = 0 -- 1237
					while col < 7 do -- 1237
						local lx = stag + col * 68 * s -- 1238
						if lx > 4 * s and lx < doorL - 4 * s then -- 1239
							uiDraw:drawSegment( -- 1240
								Vec2(lx, by), -- 1240
								Vec2(lx, by + 46 * s), -- 1240
								0.9, -- 1240
								Color(36, 38, 44, 130) -- 1240
							) -- 1240
						end -- 1240
						local rx = doorR + stag + col * 68 * s -- 1242
						if rx > doorR + 4 * s and rx < ctx.uiW - 4 * s then -- 1243
							uiDraw:drawSegment( -- 1244
								Vec2(rx, by), -- 1244
								Vec2(rx, by + 46 * s), -- 1244
								0.9, -- 1244
								Color(36, 38, 44, 130) -- 1244
							) -- 1244
						end -- 1244
						col = col + 1 -- 1237
					end -- 1237
				end -- 1237
				row = row + 1 -- 1231
			end -- 1231
		end -- 1231
		uiDraw:drawRect( -- 1249
			Rect(0, 0, ctx.uiW, threshY), -- 1249
			Color(28, 26, 28, 255) -- 1249
		) -- 1249
		uiDraw:drawRect( -- 1250
			Rect(doorL - 36 * s, threshY - 12 * s, doorW + 72 * s, 22 * s), -- 1250
			Color(96, 94, 92, 255), -- 1250
			1, -- 1250
			Color(156, 152, 144, 175) -- 1250
		) -- 1250
	end -- 1250
	local innerWarm = 0.22 + openK * 0.78 + (r1Pulse + r2Pulse) * 0.14 -- 1254
	fillVGradRect( -- 1255
		uiDraw, -- 1256
		doorL, -- 1256
		threshY + 8 * s, -- 1256
		doorW, -- 1256
		doorH - 8 * s, -- 1256
		Color( -- 1257
			46, -- 1257
			32, -- 1257
			20, -- 1257
			math.floor(255 * math.min(1, innerWarm + 0.15) + 0.5) -- 1257
		), -- 1257
		Color( -- 1258
			118, -- 1258
			82, -- 1258
			42, -- 1258
			math.floor(255 * math.min(1, innerWarm) + 0.5) -- 1258
		) -- 1258
	) -- 1258
	local leafW = math.max(26 * s, doorW * (1 - openK * 0.76)) -- 1262
	local leafX = doorL + doorShakeX * (1 - openK) -- 1263
	local woodCol = isLowpoly and toColor(shadeSurface( -- 1264
		MING_MATERIALS.mingTimberDark.base, -- 1265
		vec3(-0.2, 0.25, -0.95), -- 1265
		4, -- 1265
		1, -- 1265
		TOWER_WEST_LAMP_LIGHT, -- 1265
		MING_MATERIALS.mingTimberDark -- 1265
	)) or Color(76, 54, 38, 255) -- 1266
	uiDraw:drawRect( -- 1267
		Rect(leafX, threshY + 12 * s, leafW, doorH - 14 * s), -- 1268
		woodCol, -- 1269
		1.4, -- 1270
		Color(138, 106, 74, 185) -- 1271
	) -- 1271
	local planks = 4 -- 1274
	local pi = 1 -- 1275
	do -- 1275
		pi = 1 -- 1276
		while pi < planks do -- 1276
			local px = leafX + leafW * pi / planks -- 1277
			uiDraw:drawSegment( -- 1278
				Vec2(px, threshY + 14 * s), -- 1278
				Vec2(px, threshY + doorH - 4 * s), -- 1278
				1.1, -- 1278
				Color(38, 26, 18, 185) -- 1278
			) -- 1278
			pi = pi + 1 -- 1276
		end -- 1276
	end -- 1276
	uiDraw:drawRect( -- 1280
		Rect(leafX + 4 * s, threshY + doorH * 0.24, leafW - 8 * s, 10 * s), -- 1280
		Color(54, 38, 26, 225) -- 1280
	) -- 1280
	uiDraw:drawRect( -- 1281
		Rect(leafX + 4 * s, threshY + doorH * 0.74, leafW - 8 * s, 10 * s), -- 1281
		Color(54, 38, 26, 225) -- 1281
	) -- 1281
	local ringX = leafX + leafW * 0.72 -- 1283
	local ringY = threshY + doorH * 0.56 -- 1284
	uiDraw:drawRect( -- 1285
		Rect(ringX - 6 * s, ringY + 4 * s, 12 * s, 12 * s), -- 1285
		Color(42, 46, 52, 235), -- 1285
		1, -- 1285
		Color(96, 100, 108, 170) -- 1285
	) -- 1285
	strokeEllipse( -- 1286
		uiDraw, -- 1286
		ringX, -- 1286
		ringY - 2 * s, -- 1286
		8 * s, -- 1286
		9 * s, -- 1286
		1.8 * s, -- 1286
		Color(108, 112, 118, 195), -- 1286
		16 -- 1286
	) -- 1286
	local seamGlowA = math.floor(92 + openK * 145 + (r1Pulse + r2Pulse) * 48 + 0.5) -- 1289
	fillRadialGlow( -- 1290
		uiGlow, -- 1291
		doorCx + openK * 24 * s, -- 1291
		threshY + 14 * s, -- 1291
		(92 + openK * 120) * s, -- 1292
		(26 + openK * 58) * s, -- 1292
		Color( -- 1293
			246, -- 1293
			204, -- 1293
			134, -- 1293
			math.min(220, seamGlowA) -- 1293
		), -- 1293
		Color(220, 156, 72, 0), -- 1294
		18 -- 1295
	) -- 1295
	local kx = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s -- 1299
	local ky = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s -- 1300
	if k1Pulse > 0.08 or k2Pulse > 0.08 then -- 1301
		local amp = math.max(k1Pulse, k2Pulse) -- 1302
		local r = (18 + (1 - amp) * 34) * s -- 1303
		strokeEllipse( -- 1304
			uiInkDraw, -- 1304
			kx + 24 * s, -- 1304
			ky, -- 1304
			r, -- 1304
			r * 0.85, -- 1304
			1.8 * s, -- 1304
			toColor( -- 1304
				PALETTE.amberCore, -- 1304
				math.floor(210 * amp + 0.5) -- 1304
			), -- 1304
			24 -- 1304
		) -- 1304
	end -- 1304
	if r1Pulse > 0.08 or r2Pulse > 0.08 then -- 1306
		local amp = math.max(r1Pulse, r2Pulse) -- 1307
		local r = (24 + (1 - amp) * 42) * s -- 1308
		strokeEllipse( -- 1309
			uiInkDraw, -- 1309
			doorCx + 30 * s, -- 1309
			ky + 16 * s, -- 1309
			r, -- 1309
			r * 0.9, -- 1309
			1.6 * s, -- 1309
			toColor( -- 1309
				PALETTE.amber, -- 1309
				math.floor(185 * amp + 0.5) -- 1309
			), -- 1309
			24 -- 1309
		) -- 1309
	end -- 1309
	if openK > 0.05 then -- 1313
		local lanX = ox + ____exports.TOWER_SHOT_LAYOUT.doorLanternX * s + (1 - openK) * 42 * s -- 1314
		local lanY = oy + ____exports.TOWER_SHOT_LAYOUT.doorLanternY * s -- 1315
		uiInkDraw:drawPolygon( -- 1317
			{ -- 1317
				Vec2(lanX + 76 * s, lanY + 42 * s), -- 1318
				Vec2(lanX + 12 * s, lanY + 34 * s), -- 1319
				Vec2(lanX + 8 * s, lanY + 12 * s), -- 1320
				Vec2(lanX + 78 * s, lanY + 12 * s) -- 1321
			}, -- 1321
			Color( -- 1322
				54, -- 1322
				48, -- 1322
				44, -- 1322
				math.floor(240 * openK + 0.5) -- 1322
			), -- 1322
			1, -- 1322
			Color( -- 1322
				98, -- 1322
				86, -- 1322
				74, -- 1322
				math.floor(180 * openK + 0.5) -- 1322
			) -- 1322
		) -- 1322
		self:drawMingLantern( -- 1323
			uiInkDraw, -- 1323
			uiGlow, -- 1323
			lanX, -- 1323
			lanY - 14 * s, -- 1323
			1.08 * s, -- 1323
			openK, -- 1323
			1 -- 1323
		) -- 1323
		fillRadialGlow( -- 1325
			uiGlow, -- 1326
			kx + 12 * s, -- 1326
			ky - 14 * s, -- 1326
			148 * s, -- 1327
			128 * s, -- 1327
			Color( -- 1328
				246, -- 1328
				208, -- 1328
				142, -- 1328
				math.floor(98 * openK + 0.5) -- 1328
			), -- 1328
			Color(232, 174, 92, 0), -- 1329
			18 -- 1330
		) -- 1330
	end -- 1330
	local stepInX = openK * 44 * s -- 1335
	local xiaomanX = doorCx - 66 * s + stepInX -- 1336
	local xiaomanY = threshY - 2 * s -- 1337
	uiDraw:drawEllipse( -- 1339
		Vec2(xiaomanX, xiaomanY + 2 * s), -- 1339
		34 * s, -- 1339
		8 * s, -- 1339
		Color(4, 6, 12, 190) -- 1339
	) -- 1339
	local childSlot = (k1Pulse > 0.25 or k2Pulse > 0.25) and "child_knock" or (openK > 0.45 and "child_offer" or "child_idle") -- 1340
	uiArt:tryPlace( -- 1341
		childSlot, -- 1341
		"fe05_porch_child", -- 1341
		xiaomanX, -- 1341
		xiaomanY, -- 1341
		108 * s, -- 1341
		148 * s, -- 1341
		{facing = 1, opacity = 0.98, layer = 2} -- 1341
	) -- 1341
	if openK > 0.15 then -- 1345
		local wristX = xiaomanX + 22 * s -- 1346
		local wristY = xiaomanY + 76 * s -- 1347
		uiInkDraw:drawRect( -- 1348
			Rect(wristX - 7 * s, wristY - 5 * s, 14 * s, 11 * s), -- 1349
			Color( -- 1350
				142, -- 1350
				118, -- 1350
				84, -- 1350
				math.floor(245 * openK + 0.5) -- 1350
			), -- 1350
			1, -- 1351
			Color( -- 1352
				222, -- 1352
				192, -- 1352
				128, -- 1352
				math.floor(235 * openK + 0.5) -- 1352
			) -- 1352
		) -- 1352
		uiInkDraw:drawSegment( -- 1354
			Vec2(wristX - 8 * s, wristY), -- 1355
			Vec2(wristX + 8 * s, wristY + 2 * s), -- 1356
			2 * s, -- 1357
			toColor( -- 1358
				CUFF_PALETTE.childCord, -- 1358
				math.floor(240 * openK + 0.5) -- 1358
			) -- 1358
		) -- 1358
	end -- 1358
	if route == "soldier" then -- 1362
		local zhouX = xiaomanX - 72 * s -- 1364
		local zhouY = threshY - 2 * s -- 1365
		uiDraw:drawEllipse( -- 1366
			Vec2(zhouX, zhouY + 2 * s), -- 1366
			42 * s, -- 1366
			9 * s, -- 1366
			Color(4, 6, 12, 190) -- 1366
		) -- 1366
		uiArt:tryPlace( -- 1367
			"soldier_idle", -- 1367
			"fe05_porch_soldier", -- 1367
			zhouX, -- 1367
			zhouY, -- 1367
			146 * s, -- 1367
			206 * s, -- 1367
			{facing = 1, opacity = 0.98, layer = 2} -- 1367
		) -- 1367
		local handMidX = (zhouX + xiaomanX) * 0.5 + 4 * s -- 1371
		local handMidY = threshY + 66 * s -- 1372
		uiInkDraw:drawSegment( -- 1373
			Vec2(zhouX + 20 * s, threshY + 106 * s), -- 1374
			Vec2(handMidX - 2 * s, handMidY), -- 1375
			6.2 * s, -- 1376
			toColor(CUFF_PALETTE.indigoBase, 245) -- 1377
		) -- 1377
		uiInkDraw:drawSegment( -- 1379
			Vec2(handMidX - 9 * s, handMidY + 9 * s), -- 1380
			Vec2(handMidX - 3 * s, handMidY + 13 * s), -- 1381
			1.9 * s, -- 1382
			toColor(CUFF_PALETTE.stitchThread, 240) -- 1383
		) -- 1383
		uiInkDraw:drawSegment( -- 1385
			Vec2(xiaomanX - 14 * s, threshY + 78 * s), -- 1386
			Vec2(handMidX + 2 * s, handMidY), -- 1387
			4.8 * s, -- 1388
			toColor(CUFF_PALETTE.childSleeve, 245) -- 1389
		) -- 1389
		uiInkDraw:drawDot( -- 1391
			Vec2(handMidX, handMidY), -- 1391
			4.8 * s, -- 1391
			toColor(CUFF_PALETTE.skinLight, 245) -- 1391
		) -- 1391
	end -- 1391
end -- 1116
function TowerEndingsPlugin.prototype.drawAct2And3Guardroom(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy) -- 1397
	local t = self.seqElapsed -- 1409
	local isLowpoly = route == "child" -- 1410
	local deskY = oy + ____exports.TOWER_SHOT_LAYOUT.deskTopY * s -- 1411
	if isLowpoly then -- 1414
		self:drawF03LowpolyRoomAndWindow( -- 1415
			uiDraw, -- 1415
			uiGlow, -- 1415
			ctx, -- 1415
			lampProg, -- 1415
			s, -- 1415
			ox, -- 1415
			oy -- 1415
		) -- 1415
	else -- 1415
		self:drawM03PixelRoomAndWindow( -- 1417
			uiDraw, -- 1417
			uiArt, -- 1417
			uiGlow, -- 1417
			ctx, -- 1417
			s, -- 1417
			ox, -- 1417
			oy -- 1417
		) -- 1417
	end -- 1417
	local deskTopCol = isLowpoly and toColor(shadeSurface( -- 1421
		MING_MATERIALS.mingTimber.base, -- 1423
		vec3(-0.25, 0.9, -0.35), -- 1424
		0, -- 1425
		1, -- 1426
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1427
		MING_MATERIALS.mingTimber -- 1428
	)) or Color(86, 60, 42, 255) -- 1430
	local deskFrontCol = isLowpoly and toColor(shadeSurface( -- 1431
		MING_MATERIALS.mingTimberDark.base, -- 1433
		vec3(0, 0.1, -0.99), -- 1434
		-4, -- 1435
		1, -- 1436
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1437
		MING_MATERIALS.mingTimberDark -- 1438
	)) or Color(52, 36, 26, 255) -- 1440
	uiDraw:drawPolygon( -- 1443
		{ -- 1443
			Vec2(0, deskY - 120 * s), -- 1444
			Vec2(ctx.uiW, deskY - 120 * s), -- 1445
			Vec2(ctx.uiW, deskY + 42 * s), -- 1446
			Vec2(0, deskY + 42 * s) -- 1447
		}, -- 1447
		deskTopCol -- 1448
	) -- 1448
	uiDraw:drawRect( -- 1449
		Rect(0, 0, ctx.uiW, deskY - 118 * s), -- 1449
		deskFrontCol -- 1449
	) -- 1449
	uiDraw:drawSegment( -- 1450
		Vec2(0, deskY + 42 * s), -- 1450
		Vec2(ctx.uiW, deskY + 42 * s), -- 1450
		1.6 * s, -- 1450
		Color(158, 126, 92, 165) -- 1450
	) -- 1450
	uiDraw:drawSegment( -- 1451
		Vec2(0, deskY - 118 * s), -- 1451
		Vec2(ctx.uiW, deskY - 118 * s), -- 1451
		2 * s, -- 1451
		Color(172, 138, 102, 155) -- 1451
	) -- 1451
	local inkX = ox + ____exports.TOWER_SHOT_LAYOUT.inkstoneX * s -- 1454
	local inkY = oy + ____exports.TOWER_SHOT_LAYOUT.inkstoneY * s -- 1455
	uiDraw:drawEllipse( -- 1456
		Vec2(inkX + 3 * s, inkY - 18 * s), -- 1456
		44 * s, -- 1456
		11 * s, -- 1456
		Color(10, 10, 14, 145) -- 1456
	) -- 1456
	uiDraw:drawPolygon( -- 1457
		{ -- 1457
			Vec2(inkX - 38 * s, inkY - 18 * s), -- 1458
			Vec2(inkX + 38 * s, inkY - 18 * s), -- 1459
			Vec2(inkX + 32 * s, inkY + 18 * s), -- 1460
			Vec2(inkX - 32 * s, inkY + 18 * s) -- 1461
		}, -- 1461
		Color(38, 44, 52, 255), -- 1462
		1.2, -- 1462
		Color(96, 106, 118, 185) -- 1462
	) -- 1462
	uiDraw:drawEllipse( -- 1463
		Vec2(inkX, inkY + 1 * s), -- 1463
		22 * s, -- 1463
		10 * s, -- 1463
		Color(12, 14, 18, 255) -- 1463
	) -- 1463
	strokeEllipse( -- 1464
		uiDraw, -- 1464
		inkX, -- 1464
		inkY + 1 * s, -- 1464
		22 * s, -- 1464
		10 * s, -- 1464
		1.1 * s, -- 1464
		Color(76, 86, 98, 165), -- 1464
		18 -- 1464
	) -- 1464
	local lx = isLowpoly and ox + lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s or ox + ____exports.TOWER_SHOT_LAYOUT.lampDeskX * s -- 1467
	local ly = isLowpoly and oy + (lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34) * s or oy + ____exports.TOWER_SHOT_LAYOUT.lampDeskY * s -- 1470
	local lampWarmth = isLowpoly and 0.45 + 0.55 * lampProg or 0.92 -- 1473
	self:drawMingLantern( -- 1474
		uiInkDraw, -- 1474
		uiGlow, -- 1474
		lx, -- 1474
		ly, -- 1474
		1.02 * s, -- 1474
		1, -- 1474
		lampWarmth -- 1474
	) -- 1474
	if isLowpoly and lampProg > 0.04 then -- 1477
		local beamA = math.floor(62 * lampProg + 0.5) -- 1478
		fillGradQuad( -- 1479
			uiGlow, -- 1480
			lx + 10 * s, -- 1481
			ly + 30 * s, -- 1481
			Color(248, 206, 134, beamA), -- 1481
			lx + 10 * s, -- 1482
			ly - 32 * s, -- 1482
			Color( -- 1482
				248, -- 1482
				206, -- 1482
				134, -- 1482
				math.floor(beamA * 0.72 + 0.5) -- 1482
			), -- 1482
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.92) * s, -- 1483
			oy + (____exports.TOWER_SHOT_LAYOUT.row2Y - 58) * s, -- 1483
			Color(242, 198, 124, 0), -- 1483
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.85) * s, -- 1484
			oy + (____exports.TOWER_SHOT_LAYOUT.row1Y + 48) * s, -- 1484
			Color(242, 198, 124, 0) -- 1484
		) -- 1484
	end -- 1484
	local bookReveal = smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t) -- 1489
	if bookReveal > 0.02 then -- 1490
		self:drawRegisterBook( -- 1491
			uiDraw, -- 1491
			uiInkDraw, -- 1491
			uiArt, -- 1491
			uiGlow, -- 1491
			ctx, -- 1491
			route, -- 1491
			bookReveal, -- 1491
			lampProg, -- 1491
			s, -- 1491
			ox, -- 1491
			oy -- 1491
		) -- 1491
	end -- 1491
	self:drawDeskPropsAndBowl( -- 1495
		uiDraw, -- 1495
		uiInkDraw, -- 1495
		uiGlow, -- 1495
		ctx, -- 1495
		route, -- 1495
		s, -- 1495
		ox, -- 1495
		oy -- 1495
	) -- 1495
end -- 1397
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiGlow, ctx, lampProg, s, ox, oy) -- 1498
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1507
	local wallTop = lerpRGBA( -- 1508
		rgba(18, 24, 38, 255), -- 1508
		rgba(46, 36, 28, 255), -- 1508
		lampProg -- 1508
	) -- 1508
	local wallBot = lerpRGBA( -- 1509
		rgba(12, 16, 26, 255), -- 1509
		rgba(28, 22, 20, 255), -- 1509
		lampProg -- 1509
	) -- 1509
	fillVGradRect( -- 1510
		uiDraw, -- 1510
		0, -- 1510
		0, -- 1510
		ctx.uiW, -- 1510
		ctx.uiH, -- 1510
		toColor(wallBot), -- 1510
		toColor(wallTop) -- 1510
	) -- 1510
	local beamCol = shadeSurface( -- 1513
		MING_MATERIALS.mingTimberDark.base, -- 1513
		vec3(-0.3, -0.6, -0.74), -- 1513
		18, -- 1513
		1, -- 1513
		light, -- 1513
		MING_MATERIALS.mingTimberDark -- 1513
	) -- 1513
	uiDraw:drawPolygon( -- 1514
		{ -- 1514
			Vec2(0, ctx.uiH - 96 * s), -- 1515
			Vec2(ctx.uiW, ctx.uiH - 72 * s), -- 1516
			Vec2(ctx.uiW, ctx.uiH - 42 * s), -- 1517
			Vec2(0, ctx.uiH - 42 * s) -- 1518
		}, -- 1518
		toColor(beamCol) -- 1519
	) -- 1519
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1522
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1523
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1524
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1525
	local embrasure = 24 * s -- 1526
	fillVGradRect( -- 1529
		uiDraw, -- 1529
		wx, -- 1529
		wy, -- 1529
		ww, -- 1529
		wh, -- 1529
		Color(34, 44, 62, 255), -- 1529
		Color(16, 24, 40, 255) -- 1529
	) -- 1529
	uiDraw:drawPolygon( -- 1530
		{ -- 1530
			Vec2(wx, wy), -- 1531
			Vec2(wx + ww, wy), -- 1532
			Vec2(wx + ww, wy + wh * 0.34), -- 1533
			Vec2(wx + ww * 0.56, wy + wh * 0.42), -- 1534
			Vec2(wx + ww * 0.22, wy + wh * 0.28), -- 1535
			Vec2(wx, wy + wh * 0.36) -- 1536
		}, -- 1536
		Color(20, 26, 38, 240) -- 1537
	) -- 1537
	if lampProg > 0.12 then -- 1539
		fillRadialGlow( -- 1540
			uiGlow, -- 1541
			wx + ww * 0.5, -- 1541
			wy + 26 * s, -- 1541
			ww * 0.65, -- 1542
			wh * 0.55, -- 1542
			Color( -- 1543
				248, -- 1543
				206, -- 1543
				134, -- 1543
				math.floor(92 * lampProg + 0.5) -- 1543
			), -- 1543
			Color(232, 174, 88, 0), -- 1544
			16 -- 1545
		) -- 1545
	end -- 1545
	local leftWall = shadeSurface( -- 1550
		MING_MATERIALS.mingBrick.base, -- 1550
		vec3(0.84, 0.22, -0.49), -- 1550
		10, -- 1550
		1, -- 1550
		light, -- 1550
		MING_MATERIALS.mingBrick -- 1550
	) -- 1550
	local rightWall = shadeSurface( -- 1551
		MING_MATERIALS.mingBrick.base, -- 1551
		vec3(-0.84, 0.22, -0.49), -- 1551
		10, -- 1551
		1, -- 1551
		light, -- 1551
		MING_MATERIALS.mingBrick -- 1551
	) -- 1551
	local sillCol = shadeSurface( -- 1552
		MING_MATERIALS.mingStoneStep.base, -- 1552
		vec3(0, 0.94, -0.34), -- 1552
		6, -- 1552
		1, -- 1552
		light, -- 1552
		MING_MATERIALS.mingStoneStep -- 1552
	) -- 1552
	uiDraw:drawPolygon( -- 1553
		{ -- 1553
			Vec2(wx - embrasure, wy - 12 * s), -- 1554
			Vec2(wx, wy), -- 1555
			Vec2(wx, wy + wh), -- 1556
			Vec2(wx - embrasure, wy + wh + 14 * s) -- 1557
		}, -- 1557
		toColor(leftWall) -- 1558
	) -- 1558
	uiDraw:drawPolygon( -- 1559
		{ -- 1559
			Vec2(wx + ww, wy), -- 1560
			Vec2(wx + ww + embrasure, wy - 12 * s), -- 1561
			Vec2(wx + ww + embrasure, wy + wh + 14 * s), -- 1562
			Vec2(wx + ww, wy + wh) -- 1563
		}, -- 1563
		toColor(rightWall) -- 1564
	) -- 1564
	uiDraw:drawPolygon( -- 1566
		{ -- 1566
			Vec2(wx - embrasure - 10 * s, wy - 16 * s), -- 1567
			Vec2(wx + ww + embrasure + 10 * s, wy - 16 * s), -- 1568
			Vec2(wx + ww + 4 * s, wy + 10 * s), -- 1569
			Vec2(wx - 4 * s, wy + 10 * s) -- 1570
		}, -- 1570
		toColor(sillCol), -- 1571
		1, -- 1571
		toColor(STONE_EDGE_FALLBACK, 140) -- 1571
	) -- 1571
	local bar = 1 -- 1574
	do -- 1574
		bar = 1 -- 1575
		while bar <= 3 do -- 1575
			local bx = wx + ww * bar / 4 -- 1576
			uiDraw:drawSegment( -- 1577
				Vec2(bx, wy + 6 * s), -- 1577
				Vec2(bx, wy + wh - 2 * s), -- 1577
				3 * s, -- 1577
				Color(46, 34, 26, 235) -- 1577
			) -- 1577
			bar = bar + 1 -- 1575
		end -- 1575
	end -- 1575
	uiDraw:drawSegment( -- 1579
		Vec2(wx, wy + wh * 0.56), -- 1579
		Vec2(wx + ww, wy + wh * 0.56), -- 1579
		3.2 * s, -- 1579
		Color(46, 34, 26, 235) -- 1579
	) -- 1579
	uiDraw:drawRect( -- 1580
		Rect(wx, wy, ww, wh), -- 1580
		Color(0, 0, 0, 0), -- 1580
		2.4 * s, -- 1580
		Color(66, 50, 38, 240) -- 1580
	) -- 1580
	if lampProg > 0.02 then -- 1583
		fillRadialGlow( -- 1584
			uiGlow, -- 1585
			wx + ww * 0.5, -- 1585
			wy + 34 * s, -- 1585
			540 * s, -- 1586
			390 * s, -- 1586
			Color( -- 1587
				246, -- 1587
				198, -- 1587
				122, -- 1587
				math.floor(74 * lampProg + 0.5) -- 1587
			), -- 1587
			Color(216, 154, 72, 0), -- 1588
			20 -- 1589
		) -- 1589
	end -- 1589
end -- 1498
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1594
	fillVGradRect( -- 1604
		uiDraw, -- 1605
		0, -- 1605
		0, -- 1605
		ctx.uiW, -- 1605
		ctx.uiH, -- 1605
		Color(26, 21, 20, 255), -- 1606
		Color(46, 36, 30, 255) -- 1607
	) -- 1607
	local r = 0 -- 1610
	do -- 1610
		r = 0 -- 1611
		while r < 9 do -- 1611
			local y = oy + (280 + r * 44) * s -- 1612
			uiDraw:drawSegment( -- 1613
				Vec2(0, y), -- 1613
				Vec2(ctx.uiW, y), -- 1613
				1, -- 1613
				Color(34, 27, 24, 150) -- 1613
			) -- 1613
			r = r + 1 -- 1611
		end -- 1611
	end -- 1611
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1617
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1618
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1619
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1620
	fillVGradRect( -- 1621
		uiDraw, -- 1621
		wx, -- 1621
		wy, -- 1621
		ww, -- 1621
		wh, -- 1621
		Color(56, 62, 74, 255), -- 1621
		Color(26, 34, 50, 255) -- 1621
	) -- 1621
	uiDraw:drawRect( -- 1622
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1622
		Color(92, 68, 48, 255), -- 1622
		1, -- 1622
		Color(148, 114, 82, 180) -- 1622
	) -- 1622
	local bar = 1 -- 1623
	do -- 1623
		bar = 1 -- 1624
		while bar <= 3 do -- 1624
			local bx = wx + ww * bar / 4 -- 1625
			uiDraw:drawSegment( -- 1626
				Vec2(bx, wy + 4 * s), -- 1626
				Vec2(bx, wy + wh - 2 * s), -- 1626
				3.2 * s, -- 1626
				Color(64, 46, 34, 245) -- 1626
			) -- 1626
			bar = bar + 1 -- 1624
		end -- 1624
	end -- 1624
	uiDraw:drawSegment( -- 1628
		Vec2(wx, wy + wh * 0.56), -- 1628
		Vec2(wx + ww, wy + wh * 0.56), -- 1628
		3.2 * s, -- 1628
		Color(64, 46, 34, 245) -- 1628
	) -- 1628
	uiDraw:drawRect( -- 1629
		Rect(wx, wy, ww, wh), -- 1629
		Color(0, 0, 0, 0), -- 1629
		2.8 * s, -- 1629
		Color(88, 64, 44, 245) -- 1629
	) -- 1629
	local groupX = ox + 210 * s -- 1632
	local groupY = oy + 300 * s -- 1633
	uiArt:tryPlace( -- 1634
		"soldier_idle", -- 1634
		"fe05_m03_room_soldier", -- 1634
		groupX - 38 * s, -- 1634
		groupY, -- 1634
		118 * s, -- 1634
		166 * s, -- 1634
		{facing = 1, opacity = 0.9, layer = 1} -- 1634
	) -- 1634
	uiArt:tryPlace( -- 1637
		"child_idle", -- 1637
		"fe05_m03_room_child", -- 1637
		groupX + 42 * s, -- 1637
		groupY, -- 1637
		86 * s, -- 1637
		116 * s, -- 1637
		{facing = 1, opacity = 0.92, layer = 1} -- 1637
	) -- 1637
	fillRadialGlow( -- 1642
		uiGlow, -- 1643
		ox + 260 * s, -- 1643
		oy + 416 * s, -- 1643
		520 * s, -- 1644
		360 * s, -- 1644
		Color(246, 202, 134, 68), -- 1645
		Color(220, 158, 76, 0), -- 1646
		20 -- 1647
	) -- 1647
end -- 1594
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1651
	local t = self.seqElapsed -- 1664
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1665
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1666
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1667
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1668
	local midX = bx + bw * 0.5 -- 1669
	local midY = by + bh * 0.5 -- 1670
	uiDraw:drawRect( -- 1673
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1673
		Color( -- 1673
			10, -- 1673
			11, -- 1673
			16, -- 1673
			math.floor(108 * reveal + 0.5) -- 1673
		) -- 1673
	) -- 1673
	uiDraw:drawRect( -- 1674
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1674
		Color( -- 1674
			32, -- 1674
			46, -- 1674
			62, -- 1674
			math.floor(235 * reveal + 0.5) -- 1674
		), -- 1674
		1, -- 1674
		Color( -- 1674
			86, -- 1674
			104, -- 1674
			124, -- 1674
			math.floor(165 * reveal + 0.5) -- 1674
		) -- 1674
	) -- 1674
	if not uiArt:tryPlace( -- 1677
		"ink_song_paper", -- 1677
		"fe05_registry_paper", -- 1677
		midX, -- 1677
		midY, -- 1677
		bw, -- 1677
		bh, -- 1677
		{opacity = 0.98 * reveal, layer = 1} -- 1677
	) then -- 1677
		uiDraw:drawRect( -- 1678
			Rect(bx, by, bw, bh), -- 1679
			toColor( -- 1680
				PALETTE.xuanPaper, -- 1680
				math.floor(248 * reveal + 0.5) -- 1680
			), -- 1680
			1, -- 1681
			toColor( -- 1682
				PALETTE.silkDim, -- 1682
				math.floor(180 * reveal + 0.5) -- 1682
			) -- 1682
		) -- 1682
	end -- 1682
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1687
	fillRadialGlow( -- 1688
		uiGlow, -- 1689
		bx + bw * 0.34, -- 1689
		by + bh * 0.48, -- 1689
		bw * 0.58, -- 1690
		bh * 0.52, -- 1690
		Color( -- 1691
			246, -- 1691
			214, -- 1691
			156, -- 1691
			math.floor(44 * paperWarm * reveal + 0.5) -- 1691
		), -- 1691
		Color(238, 198, 128, 0), -- 1692
		16 -- 1693
	) -- 1693
	local padX = 44 * s -- 1697
	local padY = 32 * s -- 1698
	local inX = bx + padX -- 1699
	local inY = by + padY -- 1700
	local inW = bw - padX * 2 -- 1701
	local inH = bh - padY * 2 -- 1702
	local redSilk = toColor( -- 1703
		PALETTE.rouge, -- 1703
		math.floor(132 * reveal + 0.5) -- 1703
	) -- 1703
	local redFaint = toColor( -- 1704
		PALETTE.rouge, -- 1704
		math.floor(70 * reveal + 0.5) -- 1704
	) -- 1704
	uiInkDraw:drawRect( -- 1705
		Rect(inX, inY, inW, inH), -- 1705
		Color(0, 0, 0, 0), -- 1705
		1, -- 1705
		redSilk -- 1705
	) -- 1705
	uiInkDraw:drawRect( -- 1706
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1706
		Color(0, 0, 0, 0), -- 1706
		0.6, -- 1706
		redFaint -- 1706
	) -- 1706
	local headY = inY + inH - 28 * s -- 1709
	ctx.texts:put( -- 1710
		"md", -- 1710
		"北塔值夜收籍 · 末页", -- 1710
		inX + 18 * s, -- 1710
		headY, -- 1710
		toColor(PALETTE.xuanInk), -- 1710
		0, -- 1710
		0.5, -- 1710
		"Left", -- 1710
		2.2, -- 1710
		0.96 * reveal, -- 1710
		0 -- 1710
	) -- 1710
	ctx.texts:put( -- 1711
		"xs", -- 1711
		"宁村北塔", -- 1711
		inX + inW - 18 * s, -- 1711
		headY, -- 1711
		toColor(PALETTE.xuanInkSub), -- 1711
		1, -- 1711
		0.5, -- 1711
		"Right", -- 1711
		1.8, -- 1711
		0.8 * reveal, -- 1711
		0 -- 1711
	) -- 1711
	uiInkDraw:drawSegment( -- 1712
		Vec2(inX + 14 * s, headY - 22 * s), -- 1712
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1712
		0.9, -- 1712
		redSilk -- 1712
	) -- 1712
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1715
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1716
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1717
	ctx.texts:put( -- 1718
		"sm", -- 1718
		"肆拾壹", -- 1718
		inX + 18 * s, -- 1718
		row1Y, -- 1718
		toColor(PALETTE.rouge), -- 1718
		0, -- 1718
		0.5, -- 1718
		"Left", -- 1718
		1, -- 1718
		0.94 * reveal, -- 1718
		0 -- 1718
	) -- 1718
	if r1Prog > 0.02 then -- 1719
		ctx.texts:put( -- 1720
			"md", -- 1720
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1720
			inX + 96 * s, -- 1720
			row1Y, -- 1720
			toColor(PALETTE.xuanInk), -- 1720
			0, -- 1720
			0.5, -- 1720
			"Left", -- 1720
			1.6, -- 1720
			0.96 * math.min(1, r1Prog * 1.4), -- 1720
			0 -- 1720
		) -- 1720
	end -- 1720
	if r1Prog > 0.65 then -- 1722
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1723
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1724
		ctx.texts:put( -- 1727
			"xs", -- 1727
			subText, -- 1727
			inX + 96 * s, -- 1727
			row1SubY, -- 1727
			toColor(PALETTE.xuanInkSub), -- 1727
			0, -- 1727
			0.5, -- 1727
			"Left", -- 1727
			0.6, -- 1727
			0.88 * subA, -- 1727
			0 -- 1727
		) -- 1727
	end -- 1727
	uiInkDraw:drawSegment( -- 1729
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1729
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1729
		0.7, -- 1729
		redFaint -- 1729
	) -- 1729
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1732
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1733
	ctx.texts:put( -- 1734
		"sm", -- 1734
		"肆拾贰", -- 1734
		inX + 18 * s, -- 1734
		row2Y, -- 1734
		toColor(PALETTE.rouge), -- 1734
		0, -- 1734
		0.5, -- 1734
		"Left", -- 1734
		1, -- 1734
		0.94 * reveal, -- 1734
		0 -- 1734
	) -- 1734
	if route == "child" then -- 1736
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1738
		uiInkDraw:drawSegment( -- 1739
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1740
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1741
			1, -- 1742
			toColor(PALETTE.xuanInkSub, lineA) -- 1743
		) -- 1743
	else -- 1743
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1747
		if r2Prog <= 0.02 then -- 1748
			uiInkDraw:drawSegment( -- 1749
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1750
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1751
				0.9, -- 1752
				toColor( -- 1753
					PALETTE.xuanInkSub, -- 1753
					math.floor(105 * reveal + 0.5) -- 1753
				) -- 1753
			) -- 1753
		else -- 1753
			ctx.texts:put( -- 1756
				"md", -- 1756
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1756
				inX + 96 * s, -- 1756
				row2Y, -- 1756
				toColor(PALETTE.xuanInk), -- 1756
				0, -- 1756
				0.5, -- 1756
				"Left", -- 1756
				1.6, -- 1756
				0.96 * math.min(1, r2Prog * 1.4), -- 1756
				0 -- 1756
			) -- 1756
			if r2Prog > 0.65 then -- 1757
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1758
				ctx.texts:put( -- 1759
					"xs", -- 1759
					"守城戍卒亲口报出姓名，两人俱安。", -- 1759
					inX + 96 * s, -- 1759
					row2SubY, -- 1759
					toColor(PALETTE.xuanInkSub), -- 1759
					0, -- 1759
					0.5, -- 1759
					"Left", -- 1759
					0.6, -- 1759
					0.88 * subA, -- 1759
					0 -- 1759
				) -- 1759
			end -- 1759
		end -- 1759
	end -- 1759
	uiInkDraw:drawSegment( -- 1763
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1763
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1763
		0.7, -- 1763
		redFaint -- 1763
	) -- 1763
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1766
	if colophonA > 0.02 then -- 1767
		local signY = inY + 34 * s -- 1768
		ctx.texts:put( -- 1769
			"banner", -- 1769
			"向西守望", -- 1769
			midX - 24 * s, -- 1769
			signY, -- 1769
			toColor(PALETTE.xuanInk), -- 1769
			0.5, -- 1769
			0.5, -- 1769
			"Center", -- 1769
			6, -- 1769
			0.88 * colophonA, -- 1769
			0 -- 1769
		) -- 1769
	end -- 1769
	self:drawGuardBrushHand( -- 1773
		uiInkDraw, -- 1773
		route, -- 1773
		s, -- 1773
		ox, -- 1773
		oy -- 1773
	) -- 1773
end -- 1651
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, route, s, ox, oy) -- 1776
	local t = self.seqElapsed -- 1783
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1784
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1785
	local row1X0 = hoverX -- 1786
	local row1X1 = hoverX + 142 * s -- 1787
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1788
	local tipX = hoverX -- 1790
	local tipY = hoverY -- 1791
	local alpha = 0 -- 1792
	local lifted = 0 -- 1793
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1795
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1797
		tipX = lerp(row1X0, row1X1, k) -- 1798
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1799
		alpha = smoothstep(2, 2.2, t) -- 1800
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1801
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1802
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1804
		tipX = lerp(row1X1, hoverX, moveK) -- 1805
		tipY = lerp(row1Y, hoverY, moveK) -- 1806
		alpha = 1 -- 1807
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1808
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1809
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1811
		tipX = hoverX + outK * 140 * s -- 1812
		tipY = hoverY + outK * 46 * s -- 1813
		lifted = (9 + outK * 28) * s -- 1814
		alpha = 1 - outK -- 1815
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1816
		if t < 4.6 then -- 1818
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1819
			tipX = hoverX -- 1820
			tipY = hoverY -- 1821
			lifted = lerp(9 * s, 0, dipK) -- 1822
			alpha = 1 -- 1823
		elseif t < 5.55 then -- 1824
			local wK = smoothstep(4.6, 5.55, t) -- 1825
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1826
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1827
			lifted = 0 -- 1828
			alpha = 1 -- 1829
		else -- 1829
			local outK = smoothstep(5.55, 6.05, t) -- 1831
			tipX = hoverX + 216 * s + outK * 115 * s -- 1832
			tipY = hoverY + outK * 52 * s -- 1833
			lifted = outK * 24 * s -- 1834
			alpha = 1 - outK -- 1835
		end -- 1835
	end -- 1835
	if alpha <= 0.02 then -- 1839
		return -- 1840
	end -- 1840
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1843
	local bx = tipX -- 1844
	local by = tipY + lifted -- 1845
	uiInkDraw:drawEllipse( -- 1847
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1847
		(5 + lifted * 0.22) * s, -- 1847
		2.8 * s, -- 1847
		Color( -- 1847
			20, -- 1847
			18, -- 1847
			16, -- 1847
			math.floor(78 * alpha + 0.5) -- 1847
		) -- 1847
	) -- 1847
	uiInkDraw:drawPolygon( -- 1849
		{ -- 1849
			Vec2(bx, by), -- 1850
			Vec2(bx + 15 * s, by - 4 * s), -- 1851
			Vec2(bx + 10 * s, by + 8 * s) -- 1852
		}, -- 1852
		Color(22, 22, 26, a) -- 1853
	) -- 1853
	uiInkDraw:drawSegment( -- 1855
		Vec2(bx + 12 * s, by + 2 * s), -- 1855
		Vec2(bx + 24 * s, by + 6 * s), -- 1855
		7.8 * s, -- 1855
		Color(164, 138, 92, a) -- 1855
	) -- 1855
	uiInkDraw:drawSegment( -- 1856
		Vec2(bx + 22 * s, by + 5 * s), -- 1856
		Vec2(bx + 122 * s, by + 34 * s), -- 1856
		6.8 * s, -- 1856
		Color(142, 110, 74, a) -- 1856
	) -- 1856
	uiInkDraw:drawSegment( -- 1857
		Vec2(bx + 22 * s, by + 5 * s), -- 1857
		Vec2(bx + 122 * s, by + 34 * s), -- 1857
		1.8 * s, -- 1857
		Color( -- 1857
			196, -- 1857
			164, -- 1857
			118, -- 1857
			math.floor(185 * alpha + 0.5) -- 1857
		) -- 1857
	) -- 1857
	uiInkDraw:drawPolygon( -- 1859
		{ -- 1859
			Vec2(bx + 44 * s, by - 6 * s), -- 1860
			Vec2(bx + 102 * s, by - 14 * s), -- 1861
			Vec2(bx + 110 * s, by + 18 * s), -- 1862
			Vec2(bx + 54 * s, by + 22 * s) -- 1863
		}, -- 1863
		Color(188, 154, 126, a), -- 1864
		1, -- 1864
		Color(128, 98, 76, a) -- 1864
	) -- 1864
	uiInkDraw:drawSegment( -- 1865
		Vec2(bx + 46 * s, by + 16 * s), -- 1865
		Vec2(bx + 76 * s, by + 20 * s), -- 1865
		5.2 * s, -- 1865
		Color(204, 170, 140, a) -- 1865
	) -- 1865
	uiInkDraw:drawSegment( -- 1866
		Vec2(bx + 48 * s, by + 2 * s), -- 1866
		Vec2(bx + 82 * s, by + 4 * s), -- 1866
		4.8 * s, -- 1866
		Color(180, 146, 118, a) -- 1866
	) -- 1866
	uiInkDraw:drawPolygon( -- 1867
		{ -- 1867
			Vec2(bx + 98 * s, by - 14 * s), -- 1868
			Vec2(bx + 224 * s, by - 32 * s), -- 1869
			Vec2(bx + 230 * s, by + 18 * s), -- 1870
			Vec2(bx + 104 * s, by + 20 * s) -- 1871
		}, -- 1871
		Color(54, 48, 44, a), -- 1872
		1.2, -- 1872
		Color(94, 84, 72, a) -- 1872
	) -- 1872
end -- 1776
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiGlow, ctx, route, s, ox, oy) -- 1875
	local t = self.seqElapsed -- 1885
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1886
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1887
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1888
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1889
	if route == "child" then -- 1891
		local propA = smoothstep(1.55, 2.05, t) -- 1893
		if propA > 0.02 then -- 1894
			self:drawNeedleCaseOnDesk( -- 1895
				uiInkDraw, -- 1895
				ncX, -- 1895
				ncY, -- 1895
				s, -- 1895
				propA, -- 1895
				true -- 1895
			) -- 1895
		end -- 1895
		local noteReadA = smoothstep(1.65, 2.1, t) * (1 - smoothstep(3.65, 4.15, t)) -- 1897
		if noteReadA > 0.02 then -- 1898
			local cardX = ncX + 18 * s -- 1899
			local cardY = ncY + 84 * s -- 1900
			uiInkDraw:drawRect( -- 1901
				Rect(cardX - 118 * s, cardY - 30 * s, 236 * s, 60 * s), -- 1902
				toColor( -- 1903
					PALETTE.xuanPaper, -- 1903
					math.floor(238 * noteReadA + 0.5) -- 1903
				), -- 1903
				1, -- 1904
				toColor( -- 1905
					PALETTE.rouge, -- 1905
					math.floor(110 * noteReadA + 0.5) -- 1905
				) -- 1905
			) -- 1905
			ctx.texts:put( -- 1907
				"xs", -- 1907
				NEEDLE_NOTE_LINES[1], -- 1907
				cardX, -- 1907
				cardY + 10 * s, -- 1907
				toColor(PALETTE.xuanInk), -- 1907
				0.5, -- 1907
				0.5, -- 1907
				"Center", -- 1907
				0.6, -- 1907
				0.94 * noteReadA, -- 1907
				0 -- 1907
			) -- 1907
			ctx.texts:put( -- 1908
				"xs", -- 1908
				"—— " .. NEEDLE_NOTE_LINES[2], -- 1908
				cardX + 74 * s, -- 1908
				cardY - 12 * s, -- 1908
				toColor(PALETTE.xuanInkSub), -- 1908
				1, -- 1908
				0.5, -- 1908
				"Right", -- 1908
				0.8, -- 1908
				0.88 * noteReadA, -- 1908
				0 -- 1908
			) -- 1908
		end -- 1908
		local bowlK = smoothstep(4.35, 5.15, t) -- 1911
		if bowlK > 0.02 then -- 1912
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1913
			self:drawWarmPorcelainBowl( -- 1914
				uiInkDraw, -- 1914
				uiGlow, -- 1914
				bx, -- 1914
				bowlY, -- 1914
				s, -- 1914
				bowlK, -- 1914
				false, -- 1914
				0 -- 1914
			) -- 1914
		end -- 1914
	else -- 1914
		local needleK = smoothstep(5.45, 6.15, t) -- 1918
		if needleK > 0.02 then -- 1919
			local ny = lerp(ncY + 46 * s, ncY, needleK) -- 1920
			self:drawNeedleCaseOnDesk( -- 1921
				uiInkDraw, -- 1921
				ncX, -- 1921
				ny, -- 1921
				s, -- 1921
				needleK, -- 1921
				false -- 1921
			) -- 1921
		end -- 1921
		local bowlK = smoothstep(5.8, 6.65, t) -- 1924
		if bowlK > 0.02 then -- 1925
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1926
			local handsK = smoothstep(5.95, 6.75, t) -- 1927
			self:drawWarmPorcelainBowl( -- 1928
				uiInkDraw, -- 1928
				uiGlow, -- 1928
				bowlX, -- 1928
				by, -- 1928
				s, -- 1928
				bowlK, -- 1928
				true, -- 1928
				handsK -- 1928
			) -- 1928
		end -- 1928
		local cuffK = smoothstep(4.25, 4.85, t) -- 1931
		if cuffK > 0.02 then -- 1932
			drawPatchedCuff(uiInkDraw, uiGlow, { -- 1933
				wristX = ox + 122 * s, -- 1934
				wristY = oy + 182 * s, -- 1935
				angleRad = 0.08, -- 1936
				scale = 0.6 * s, -- 1937
				pose = "open", -- 1938
				opacity = 0.92 * cuffK, -- 1939
				stitchHighlight = 0.34, -- 1940
				warmth = 0.72 -- 1941
			}) -- 1941
		end -- 1941
	end -- 1941
end -- 1875
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, draw, cx, cy, s, alpha, withNote) -- 1948
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1956
	draw:drawEllipse( -- 1958
		Vec2(cx + 4 * s, cy - 12 * s), -- 1958
		44 * s, -- 1958
		14 * s, -- 1958
		Color( -- 1958
			10, -- 1958
			10, -- 1958
			14, -- 1958
			math.floor(140 * alpha + 0.5) -- 1958
		) -- 1958
	) -- 1958
	draw:drawPolygon( -- 1960
		{ -- 1960
			Vec2(cx - 32 * s, cy - 12 * s), -- 1961
			Vec2(cx + 26 * s, cy - 15 * s), -- 1962
			Vec2(cx + 30 * s, cy + 16 * s), -- 1963
			Vec2(cx - 28 * s, cy + 18 * s) -- 1964
		}, -- 1964
		Color(148, 124, 92, a), -- 1965
		1.3, -- 1965
		Color(88, 70, 50, a) -- 1965
	) -- 1965
	draw:drawEllipse( -- 1967
		Vec2(cx + 18 * s, cy + 2 * s), -- 1967
		13 * s, -- 1967
		13 * s, -- 1967
		Color(188, 152, 86, a) -- 1967
	) -- 1967
	strokeEllipse( -- 1968
		draw, -- 1968
		cx + 18 * s, -- 1968
		cy + 2 * s, -- 1968
		13 * s, -- 1968
		13 * s, -- 1968
		1.5 * s, -- 1968
		Color(118, 92, 46, a), -- 1968
		18 -- 1968
	) -- 1968
	draw:drawDot( -- 1969
		Vec2(cx + 18 * s, cy + 2 * s), -- 1969
		2.5 * s, -- 1969
		Color(72, 54, 28, a) -- 1969
	) -- 1969
	draw:drawSegment( -- 1970
		Vec2(cx + 12 * s, cy - 2 * s), -- 1970
		Vec2(cx + 24 * s, cy + 6 * s), -- 1970
		1.5 * s, -- 1970
		Color(164, 48, 44, a) -- 1970
	) -- 1970
	draw:drawSegment( -- 1972
		Vec2(cx - 28 * s, cy + 4 * s), -- 1972
		Vec2(cx - 56 * s, cy - 8 * s), -- 1972
		2.4 * s, -- 1972
		toColor(CUFF_PALETTE.childCord, a) -- 1972
	) -- 1972
	draw:drawSegment( -- 1973
		Vec2(cx - 56 * s, cy - 8 * s), -- 1973
		Vec2(cx - 72 * s, cy + 6 * s), -- 1973
		2.2 * s, -- 1973
		toColor(CUFF_PALETTE.childCord, a) -- 1973
	) -- 1973
	draw:drawSegment( -- 1974
		Vec2(cx - 72 * s, cy + 6 * s), -- 1974
		Vec2(cx - 48 * s, cy + 16 * s), -- 1974
		2 * s, -- 1974
		toColor( -- 1974
			CUFF_PALETTE.childCord, -- 1974
			math.floor(215 * alpha + 0.5) -- 1974
		) -- 1974
	) -- 1974
	if withNote then -- 1976
		draw:drawPolygon( -- 1978
			{ -- 1978
				Vec2(cx + 38 * s, cy - 18 * s), -- 1979
				Vec2(cx + 96 * s, cy - 12 * s), -- 1980
				Vec2(cx + 90 * s, cy + 24 * s), -- 1981
				Vec2(cx + 34 * s, cy + 18 * s) -- 1982
			}, -- 1982
			toColor(PALETTE.xuanPaper, a), -- 1983
			1, -- 1983
			toColor( -- 1983
				PALETTE.xuanInkSub, -- 1983
				math.floor(160 * alpha + 0.5) -- 1983
			) -- 1983
		) -- 1983
		draw:drawSegment( -- 1984
			Vec2(cx + 46 * s, cy + 8 * s), -- 1984
			Vec2(cx + 80 * s, cy + 11 * s), -- 1984
			1.2 * s, -- 1984
			toColor( -- 1984
				PALETTE.xuanInk, -- 1984
				math.floor(170 * alpha + 0.5) -- 1984
			) -- 1984
		) -- 1984
		draw:drawSegment( -- 1985
			Vec2(cx + 46 * s, cy - 2 * s), -- 1985
			Vec2(cx + 76 * s, cy + 1 * s), -- 1985
			1.2 * s, -- 1985
			toColor( -- 1985
				PALETTE.xuanInk, -- 1985
				math.floor(160 * alpha + 0.5) -- 1985
			) -- 1985
		) -- 1985
	end -- 1985
end -- 1948
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, draw, glow, cx, cy, s, alpha, heldByTwoHands, handsK) -- 1990
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 2000
	draw:drawEllipse( -- 2002
		Vec2(cx, cy - 36 * s), -- 2002
		58 * s, -- 2002
		14 * s, -- 2002
		Color( -- 2002
			8, -- 2002
			9, -- 2002
			14, -- 2002
			math.floor(150 * alpha + 0.5) -- 2002
		) -- 2002
	) -- 2002
	draw:drawPolygon( -- 2004
		{ -- 2004
			Vec2(cx - 32 * s, cy - 38 * s), -- 2005
			Vec2(cx + 32 * s, cy - 38 * s), -- 2006
			Vec2(cx + 62 * s, cy + 8 * s), -- 2007
			Vec2(cx - 62 * s, cy + 8 * s) -- 2008
		}, -- 2008
		Color(168, 166, 156, a), -- 2009
		1.4, -- 2009
		Color(98, 96, 88, a) -- 2009
	) -- 2009
	draw:drawPolygon( -- 2011
		{ -- 2011
			Vec2(cx + 8 * s, cy - 36 * s), -- 2012
			Vec2(cx + 32 * s, cy - 38 * s), -- 2013
			Vec2(cx + 62 * s, cy + 8 * s), -- 2014
			Vec2(cx + 22 * s, cy + 6 * s) -- 2015
		}, -- 2015
		Color( -- 2016
			122, -- 2016
			120, -- 2016
			112, -- 2016
			math.floor(160 * alpha + 0.5) -- 2016
		) -- 2016
	) -- 2016
	draw:drawEllipse( -- 2018
		Vec2(cx, cy + 8 * s), -- 2018
		64 * s, -- 2018
		21 * s, -- 2018
		Color(224, 218, 206, a) -- 2018
	) -- 2018
	strokeEllipse( -- 2019
		draw, -- 2019
		cx, -- 2019
		cy + 8 * s, -- 2019
		64 * s, -- 2019
		21 * s, -- 2019
		1.9 * s, -- 2019
		Color(116, 110, 100, a), -- 2019
		28 -- 2019
	) -- 2019
	draw:drawEllipse( -- 2020
		Vec2(cx, cy + 6 * s), -- 2020
		54 * s, -- 2020
		15 * s, -- 2020
		Color(196, 168, 122, a) -- 2020
	) -- 2020
	strokeEllipse( -- 2021
		draw, -- 2021
		cx, -- 2021
		cy + 6 * s, -- 2021
		54 * s, -- 2021
		15 * s, -- 2021
		1.1 * s, -- 2021
		Color(158, 132, 92, a), -- 2021
		24 -- 2021
	) -- 2021
	draw:drawSegment( -- 2023
		Vec2(cx - 46 * s, cy + 16 * s), -- 2023
		Vec2(cx - 10 * s, cy + 25 * s), -- 2023
		2 * s, -- 2023
		Color( -- 2023
			248, -- 2023
			246, -- 2023
			240, -- 2023
			math.floor(215 * alpha + 0.5) -- 2023
		) -- 2023
	) -- 2023
	local wi = 0 -- 2026
	do -- 2026
		wi = 0 -- 2027
		while wi < 3 do -- 2027
			local phase = self.animTime * 1.1 + wi * 2.05 -- 2028
			local baseX = cx + (wi - 1) * 18 * s -- 2029
			local baseY = cy + 16 * s -- 2030
			local segs = 4 -- 2031
			local prevX = baseX -- 2032
			local prevY = baseY -- 2033
			local si = 1 -- 2034
			do -- 2034
				si = 1 -- 2035
				while si <= segs do -- 2035
					local frac = si / segs -- 2036
					local nx = baseX + math.sin(phase + frac * 3.1) * (6.5 * frac) * s -- 2037
					local ny = baseY + frac * (36 + wi % 2 * 10) * s -- 2038
					local wa = math.floor(46 * (1 - frac * 0.72) * alpha + 0.5) -- 2039
					glow:drawSegment( -- 2040
						Vec2(prevX, prevY), -- 2040
						Vec2(nx, ny), -- 2040
						(2.2 - frac * 0.9) * s, -- 2040
						Color(244, 238, 226, wa) -- 2040
					) -- 2040
					prevX = nx -- 2041
					prevY = ny -- 2042
					si = si + 1 -- 2035
				end -- 2035
			end -- 2035
			wi = wi + 1 -- 2027
		end -- 2027
	end -- 2027
	if heldByTwoHands and handsK > 0.02 then -- 2047
		local ha = math.floor(255 * clamp01(handsK * alpha) + 0.5) -- 2048
		local skin = toColor(CUFF_PALETTE.childSkin, ha) -- 2049
		local skinSh = toColor(CUFF_PALETTE.childSkinShadow, ha) -- 2050
		local sleeve = toColor(CUFF_PALETTE.childSleeve, ha) -- 2051
		local spread = (1 - handsK) * 28 * s -- 2052
		draw:drawPolygon( -- 2055
			{ -- 2055
				Vec2(cx - 122 * s - spread, cy - 58 * s), -- 2056
				Vec2(cx - 72 * s - spread, cy - 30 * s), -- 2057
				Vec2(cx - 82 * s - spread, cy - 4 * s), -- 2058
				Vec2(cx - 134 * s - spread, cy - 26 * s) -- 2059
			}, -- 2059
			sleeve, -- 2060
			1.1, -- 2060
			skinSh -- 2060
		) -- 2060
		draw:drawPolygon( -- 2061
			{ -- 2061
				Vec2(cx - 76 * s - spread, cy - 28 * s), -- 2062
				Vec2(cx - 48 * s - spread, cy - 18 * s), -- 2063
				Vec2(cx - 44 * s - spread, cy + 6 * s), -- 2064
				Vec2(cx - 74 * s - spread, cy + 2 * s) -- 2065
			}, -- 2065
			skin, -- 2066
			1.1, -- 2066
			skinSh -- 2066
		) -- 2066
		draw:drawSegment( -- 2067
			Vec2(cx - 56 * s - spread, cy + 2 * s), -- 2067
			Vec2(cx - 38 * s - spread, cy + 12 * s), -- 2067
			4.6 * s, -- 2067
			skin -- 2067
		) -- 2067
		draw:drawSegment( -- 2068
			Vec2(cx - 58 * s - spread, cy - 7 * s), -- 2068
			Vec2(cx - 40 * s - spread, cy - 2 * s), -- 2068
			4.4 * s, -- 2068
			skin -- 2068
		) -- 2068
		draw:drawSegment( -- 2069
			Vec2(cx - 56 * s - spread, cy - 16 * s), -- 2069
			Vec2(cx - 40 * s - spread, cy - 14 * s), -- 2069
			4.2 * s, -- 2069
			skin -- 2069
		) -- 2069
		draw:drawPolygon( -- 2072
			{ -- 2072
				Vec2(cx + 122 * s + spread, cy - 58 * s), -- 2073
				Vec2(cx + 72 * s + spread, cy - 30 * s), -- 2074
				Vec2(cx + 82 * s + spread, cy - 4 * s), -- 2075
				Vec2(cx + 134 * s + spread, cy - 26 * s) -- 2076
			}, -- 2076
			sleeve, -- 2077
			1.1, -- 2077
			skinSh -- 2077
		) -- 2077
		draw:drawPolygon( -- 2078
			{ -- 2078
				Vec2(cx + 76 * s + spread, cy - 28 * s), -- 2079
				Vec2(cx + 48 * s + spread, cy - 18 * s), -- 2080
				Vec2(cx + 44 * s + spread, cy + 6 * s), -- 2081
				Vec2(cx + 74 * s + spread, cy + 2 * s) -- 2082
			}, -- 2082
			skin, -- 2083
			1.1, -- 2083
			skinSh -- 2083
		) -- 2083
		draw:drawSegment( -- 2084
			Vec2(cx + 56 * s + spread, cy + 2 * s), -- 2084
			Vec2(cx + 38 * s + spread, cy + 12 * s), -- 2084
			4.6 * s, -- 2084
			skin -- 2084
		) -- 2084
		draw:drawSegment( -- 2085
			Vec2(cx + 58 * s + spread, cy - 7 * s), -- 2085
			Vec2(cx + 40 * s + spread, cy - 2 * s), -- 2085
			4.4 * s, -- 2085
			skin -- 2085
		) -- 2085
		draw:drawSegment( -- 2086
			Vec2(cx + 56 * s + spread, cy - 16 * s), -- 2086
			Vec2(cx + 40 * s + spread, cy - 14 * s), -- 2086
			4.2 * s, -- 2086
			skin -- 2086
		) -- 2086
	end -- 2086
end -- 1990
function TowerEndingsPlugin.prototype.drawMingLantern(self, draw, glow, cx, cy, scale, alpha, warmth) -- 2091
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 2100
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 2101
	draw:drawSegment( -- 2103
		Vec2(cx - 10 * scale, cy + 28 * scale), -- 2103
		Vec2(cx, cy + 40 * scale), -- 2103
		1.8 * scale, -- 2103
		Color(88, 86, 82, a) -- 2103
	) -- 2103
	draw:drawSegment( -- 2104
		Vec2(cx + 10 * scale, cy + 28 * scale), -- 2104
		Vec2(cx, cy + 40 * scale), -- 2104
		1.8 * scale, -- 2104
		Color(88, 86, 82, a) -- 2104
	) -- 2104
	draw:drawRect( -- 2106
		Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), -- 2106
		Color(62, 46, 34, a), -- 2106
		1, -- 2106
		Color(118, 92, 66, a) -- 2106
	) -- 2106
	draw:drawRect( -- 2107
		Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), -- 2107
		Color(62, 46, 34, a), -- 2107
		1, -- 2107
		Color(118, 92, 66, a) -- 2107
	) -- 2107
	draw:drawRect( -- 2109
		Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale), -- 2110
		Color( -- 2111
			238, -- 2111
			198, -- 2111
			132, -- 2111
			math.floor(230 * alpha * (0.75 + 0.25 * warmth) + 0.5) -- 2111
		), -- 2111
		1.4 * scale, -- 2112
		Color(94, 70, 48, a) -- 2113
	) -- 2113
	draw:drawSegment( -- 2115
		Vec2(cx, cy - 18 * scale), -- 2115
		Vec2(cx, cy + 22 * scale), -- 2115
		1.1 * scale, -- 2115
		Color( -- 2115
			94, -- 2115
			70, -- 2115
			48, -- 2115
			math.floor(150 * alpha + 0.5) -- 2115
		) -- 2115
	) -- 2115
	draw:drawEllipse( -- 2116
		Vec2(cx, cy + 2 * scale), -- 2116
		4.6 * scale * flicker, -- 2116
		8.5 * scale * flicker, -- 2116
		Color(255, 244, 212, a) -- 2116
	) -- 2116
	fillRadialGlow( -- 2118
		glow, -- 2119
		cx, -- 2119
		cy + 2 * scale, -- 2119
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2120
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2121
		Color( -- 2122
			250, -- 2122
			208, -- 2122
			132, -- 2122
			math.floor(128 * alpha * warmth + 0.5) -- 2122
		), -- 2122
		Color(228, 162, 74, 0), -- 2123
		16 -- 2124
	) -- 2124
end -- 2091
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 2128
	local line = self.lastSubtitle -- 2137
	if line ~= "" then -- 2138
		local cy = barH + 34 * s -- 2139
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 2140
		drawSilkVeil( -- 2141
			uiDraw, -- 2141
			uiArt, -- 2141
			"fe05_sub_veil", -- 2141
			ctx.uiW * 0.5, -- 2141
			cy, -- 2141
			stripW, -- 2141
			48 * s, -- 2141
			PALETTE.inkWash, -- 2141
			0.82, -- 2141
			3 -- 2141
		) -- 2141
		drawHairline( -- 2142
			uiInkDraw, -- 2142
			uiArt, -- 2142
			"fe05_sub_hair", -- 2142
			ctx.uiW * 0.5, -- 2142
			cy + 21 * s, -- 2142
			stripW * 0.68, -- 2142
			PALETTE.silkDim, -- 2142
			0.54, -- 2142
			true, -- 2142
			4 -- 2142
		) -- 2142
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 2143
		ctx.texts:put( -- 2144
			isSpoken and "md" or "sm", -- 2145
			line, -- 2146
			ctx.uiW * 0.5, -- 2147
			cy - 1 * s, -- 2148
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 2149
			0.5, -- 2150
			0.5, -- 2151
			"Center", -- 2152
			isSpoken and 1.8 or 1, -- 2153
			0.98, -- 2154
			0.08 -- 2155
		) -- 2155
	end -- 2155
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 2160
		local rawHint = route == "child" and "按 E 收页 · 尾声与史话   ·   Esc 暂歇" or "团圆尾声   ·   按 E 收页与史话   ·   Esc 暂歇" -- 2161
		local hint = adaptHintSentence(rawHint, ctx.input.inputMode, ctx.input.gamepadLayout) -- 2164
		ctx.texts:put( -- 2165
			"xs", -- 2165
			hint, -- 2165
			ctx.uiW * 0.5, -- 2165
			barH * 0.5, -- 2165
			toColor(PALETTE.textMid), -- 2165
			0.5, -- 2165
			0.5, -- 2165
			"Center", -- 2165
			1.4, -- 2165
			0.88, -- 2165
			0.08 -- 2165
		) -- 2165
	end -- 2165
end -- 2128
function ____exports.createTowerEndingsPlugin() -- 2170
	return __TS__New(____exports.TowerEndingsPlugin) -- 2171
end -- 2170
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 2175
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 2176
	fe:registerPlugin(plugin) -- 2177
	return plugin -- 2178
end -- 2175
return ____exports -- 2175
