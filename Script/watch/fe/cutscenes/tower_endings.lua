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
end -- 390
function TowerEndingsPlugin.prototype.resolveRoute(self, p, view) -- 431
	if self.rehearsalActive then -- 432
		return self.rehearsalRoute -- 433
	end -- 433
	if view.storyRoute == "soldier" then -- 435
		return "soldier" -- 436
	end -- 436
	if view.storyRoute == "child" then -- 438
		return "child" -- 439
	end -- 439
	local runRec = asRecord(p.run) -- 442
	local ____asRecord_1 = asRecord -- 443
	local ____temp_0 -- 443
	if runRec ~= nil then -- 443
		____temp_0 = runRec.story -- 443
	else -- 443
		____temp_0 = nil -- 443
	end -- 443
	local storyRec = ____asRecord_1(____temp_0) -- 443
	if storyRec ~= nil and storyRec.ending == "reunion" then -- 444
		return "soldier" -- 445
	end -- 445
	return p.childMode and "child" or "soldier" -- 448
end -- 431
function TowerEndingsPlugin.prototype.clearSequenceState(self, keepIndoorDoorOpen) -- 451
	self.active = keepIndoorDoorOpen -- 452
	self.seqElapsed = keepIndoorDoorOpen and ____exports.TOWER_ENDING_TIMINGS.indoorCutSec or 0 -- 453
	self.holdElapsed = 0 -- 454
	self.doorOpened = keepIndoorDoorOpen -- 455
	self.knockCount = keepIndoorDoorOpen and 2 or 0 -- 456
	self.replyKnockCount = keepIndoorDoorOpen and 2 or 0 -- 457
	if not keepIndoorDoorOpen then -- 458
		self.row1Written = false -- 459
		self.row2Written = false -- 460
		self.registryAppendCount = 0 -- 461
	end -- 461
	self.staleInputMustRelease = true -- 463
	self.confirmReady = false -- 464
	self.earlyInputBlockedCount = 0 -- 465
	self.rehearsalAcknowledged = false -- 466
	self.lastSubtitle = "" -- 467
end -- 451
function TowerEndingsPlugin.prototype.startRehearsal(self, route, contract, opts) -- 473
	self.rehearsalActive = true -- 478
	self.rehearsalRoute = route -- 479
	self.activeRoute = route -- 480
	local tag = opts and opts.tag or (route == "child" and "fe05-F03" or "fe05-M03") -- 481
	if contract ~= nil then -- 482
		contract:enterRehearsal(tag) -- 483
		contract:setMockRoute(route) -- 484
	end -- 484
	local isIndoor = (opts and opts.indoorRetry) == true -- 486
	self.sessionId = self.sessionId + 1 -- 487
	self:clearSequenceState(isIndoor) -- 488
	self.active = true -- 489
	self.doorClosedAfterRetry = false -- 490
	if isIndoor then -- 491
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 492
	end -- 492
	if (opts and opts.seekTime) ~= nil then -- 494
		self:seekRehearsal(opts.seekTime) -- 495
	end -- 495
end -- 473
function TowerEndingsPlugin.prototype.seekRehearsal(self, seconds) -- 500
	if not self.rehearsalActive then -- 501
		return -- 502
	end -- 502
	local t = math.max(0, seconds) -- 504
	self.seqElapsed = t -- 505
	self.holdElapsed = math.max(0, t - ____exports.TOWER_ENDING_TIMINGS.divergeEndSec) -- 506
	self.active = true -- 507
	self:syncDerivedMilestones(t, self.activeRoute) -- 508
	self.confirmReady = not self.staleInputMustRelease and t >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 509
end -- 500
function TowerEndingsPlugin.prototype.triggerIndoorRetry(self) -- 513
	if not self.doorOpened and self.seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 514
		self.doorOpened = true -- 515
	end -- 515
	self.indoorRetryCount = self.indoorRetryCount + 1 -- 517
	self.doorClosedAfterRetry = false -- 518
	self.doorOpened = true -- 519
	self.active = true -- 520
	self.seqElapsed = math.max( -- 521
		____exports.TOWER_ENDING_TIMINGS.indoorCutSec, -- 521
		math.min(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.row1StartSec) -- 521
	) -- 521
	self.holdElapsed = 0 -- 522
	self.knockCount = math.max(2, self.knockCount) -- 523
	self.replyKnockCount = math.max(2, self.replyKnockCount) -- 524
	self.staleInputMustRelease = true -- 526
	self.confirmReady = false -- 527
end -- 513
function TowerEndingsPlugin.prototype.stopRehearsal(self, contract) -- 531
	self.rehearsalActive = false -- 532
	self:clearSequenceState(false) -- 533
	self.indoorRetryCount = 0 -- 534
	self.doorClosedAfterRetry = false -- 535
	if contract ~= nil then -- 536
		contract:exitRehearsal() -- 537
	end -- 537
end -- 531
function TowerEndingsPlugin.prototype.getDebugState(self) -- 541
	local route = self.activeRoute -- 542
	local lampProg = route == "child" and smoothstep(5.2, 6.75, self.seqElapsed) or 0 -- 543
	local scaled = computeScaledAnchors(self.lastUiW, self.lastUiH, lampProg) -- 546
	local visualStyle = route == "child" and "lowpoly" or "pixel" -- 547
	local needleOnDesk = route == "soldier" and self.seqElapsed >= 5.55 -- 548
	local twoHandsBowl = route == "soldier" and self.seqElapsed >= 5.95 -- 549
	return { -- 551
		active = self.active, -- 552
		isRehearsal = self.rehearsalActive, -- 553
		route = route, -- 554
		visualStyle = visualStyle, -- 555
		stage = deriveStage(self.seqElapsed, self.active), -- 556
		seqElapsed = self.seqElapsed, -- 557
		holdElapsed = self.holdElapsed, -- 558
		doorOpened = self.doorOpened, -- 559
		knockCount = self.knockCount, -- 560
		replyKnockCount = self.replyKnockCount, -- 561
		row1Written = self.row1Written, -- 562
		row1Name = self.row1Written and "小满" or "", -- 563
		row2Written = self.row2Written, -- 564
		row2Name = self.row2Written and "周戍" or "", -- 565
		row2Blank = not self.row2Written, -- 566
		hasCompletionStamp = false, -- 567
		registryRowCapacity = 2, -- 568
		registryAppendCount = self.registryAppendCount, -- 569
		lampProgress = lampProg, -- 570
		lampAtWestWindow = route == "child" and lampProg >= 0.99, -- 571
		needleCaseOnDesk = needleOnDesk, -- 572
		twoHandsHoldingBowl = twoHandsBowl, -- 573
		staleInputMustRelease = self.staleInputMustRelease, -- 574
		confirmReady = self.confirmReady, -- 575
		earlyInputBlockedCount = self.earlyInputBlockedCount, -- 576
		rehearsalAcknowledged = self.rehearsalAcknowledged, -- 577
		indoorRetryCount = self.indoorRetryCount, -- 578
		doorClosedAfterRetry = self.doorClosedAfterRetry, -- 579
		subtitleText = self.lastSubtitle, -- 580
		anchors = scaled.anchors -- 581
	} -- 581
end -- 541
function TowerEndingsPlugin.prototype.syncRuntimeHook(self) -- 585
	local g = _G -- 586
	local ____temp_8 -- 587
	if g.package ~= nil then -- 587
		____temp_8 = g.package.loaded -- 587
	else -- 587
		____temp_8 = nil -- 587
	end -- 587
	local loaded = ____temp_8 -- 587
	if loaded == nil then -- 588
		return -- 589
	end -- 589
	local rawFe = loaded["watch.fe"] -- 591
	if rawFe ~= nil and type(rawFe) == "table" then -- 592
		local watchFe = rawFe -- 593
		if watchFe.towerEndings ~= self then -- 594
			watchFe.towerEndings = self -- 595
		end -- 595
	end -- 595
end -- 585
function TowerEndingsPlugin.prototype.onBindPlay(self, p, view) -- 602
	self:syncRuntimeHook() -- 603
	self.sessionId = self.sessionId + 1 -- 604
	self.loopsActive = false -- 605
	self.prevPhase = p.phase -- 606
	if self.rehearsalActive then -- 608
		return -- 609
	end -- 609
	local route = self:resolveRoute(p, view) -- 612
	local isTower = p.room.key == "tower" -- 613
	local alreadyCutscenePhase = isTower and (p.phase == "tower-given" or p.phase == "tower-end") -- 614
	local alreadyIndoorPhase = isTower and (p.phase == "tower-enter" or p.phase == "tower-desk" or alreadyCutscenePhase) -- 615
	local sameRunIndoorRetry = isTower and self.lastRoomKey == "tower" and self.doorOpened and p.run == self.lastRunRef and route == self.activeRoute and (p.checkpoint > 0 or alreadyIndoorPhase) -- 620
	self.activeRoute = route -- 627
	self.lastRoomKey = p.room.key -- 628
	self.lastRunRef = p.run -- 629
	if not isTower then -- 631
		self:clearSequenceState(false) -- 632
		self.indoorRetryCount = 0 -- 633
		self.doorClosedAfterRetry = false -- 634
		return -- 635
	end -- 635
	if sameRunIndoorRetry or alreadyCutscenePhase then -- 638
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 640
		self.doorClosedAfterRetry = false -- 641
		self:clearSequenceState(true) -- 642
		if p.phase == "tower-end" then -- 643
			self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.divergeEndSec -- 644
			self:syncDerivedMilestones(self.seqElapsed, route) -- 645
		end -- 645
		return -- 647
	end -- 647
	if p.phase == "tower-enter" or p.phase == "tower-desk" then -- 650
		self:clearSequenceState(false) -- 652
		self.doorOpened = true -- 653
		self.replyKnockCount = 2 -- 654
		self.active = false -- 655
		return -- 656
	end -- 656
	self:clearSequenceState(false) -- 660
	self.indoorRetryCount = 0 -- 661
	self.doorClosedAfterRetry = false -- 662
end -- 602
function TowerEndingsPlugin.prototype.update(self, ctx) -- 665
	self:syncRuntimeHook() -- 666
	self.lastUiW = ctx.uiW -- 667
	self.lastUiH = ctx.uiH -- 668
	local p = ctx.p -- 669
	if not self.rehearsalActive and p.room.key ~= "tower" then -- 671
		if self.loopsActive then -- 672
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 673
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 674
			self.loopsActive = false -- 675
		end -- 675
		self.active = false -- 677
		return -- 678
	end -- 678
	local route = self:resolveRoute(p, ctx.view) -- 681
	self.activeRoute = route -- 682
	if not self.rehearsalActive then -- 684
		self:stepLiveSync(ctx, route) -- 685
	else -- 685
		self:stepRehearsal(ctx, route) -- 687
	end -- 687
	if not self.active then -- 690
		local inInteractiveHall = not self.rehearsalActive and p.room.key == "tower" and (p.phase == "tower-enter" or p.phase == "tower-desk") -- 691
		if self.loopsActive and not inInteractiveHall then -- 693
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 694
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 695
			self.loopsActive = false -- 696
		end -- 696
		return -- 698
	end -- 698
	if not ctx.paused and ctx.worldDt > 0 then -- 702
		self.animTime = self.animTime + ctx.worldDt -- 703
		self:syncDerivedMilestones(self.seqElapsed, route) -- 704
		self:syncAudioCues(ctx.audio, ctx, route) -- 705
		self:stepInputGuard(ctx.input) -- 706
	elseif not ctx.paused then -- 707
		self:syncDerivedMilestones(self.seqElapsed, route) -- 709
		self:stepInputGuard(ctx.input) -- 710
	end -- 710
	self.lastSubtitle = self:composeSubtitle(route) -- 713
end -- 665
function TowerEndingsPlugin.prototype.stepLiveSync(self, ctx, route) -- 716
	local p = ctx.p -- 717
	local phase = p.phase -- 718
	local justEnteredKnock = self.prevPhase ~= "tower-knock" and phase == "tower-knock" -- 719
	local justEnteredEnter = self.prevPhase ~= "tower-enter" and phase == "tower-enter" -- 720
	local justEnteredGiven = self.prevPhase ~= "tower-given" and phase == "tower-given" -- 721
	local justEnteredEnd = self.prevPhase ~= "tower-end" and phase == "tower-end" -- 722
	self.prevPhase = phase -- 723
	if phase == "tower-wait" then -- 725
		self.active = false -- 727
		return -- 728
	end -- 728
	if phase == "tower-enter" or phase == "tower-desk" then -- 731
		self.doorOpened = true -- 733
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 734
		if justEnteredEnter and self.indoorRetryCount == 0 and not ctx.paused then -- 735
			local tick = p.ticks -- 736
			self:playTowerOnce( -- 737
				ctx.audio, -- 737
				"reply1", -- 737
				"sfx", -- 737
				____exports.TOWER_AUDIO_FILES.reply1, -- 737
				0.78, -- 737
				"tower:reply:1", -- 737
				tick -- 737
			) -- 737
			self:playTowerOnce( -- 738
				ctx.audio, -- 738
				"reply2", -- 738
				"sfx", -- 738
				____exports.TOWER_AUDIO_FILES.reply2, -- 738
				0.8, -- 738
				"tower:reply:2", -- 738
				tick -- 738
			) -- 738
			self:playTowerOnce( -- 739
				ctx.audio, -- 739
				"door_open", -- 739
				"sfx", -- 739
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 739
				0.84, -- 739
				"tower:door_open", -- 739
				tick -- 739
			) -- 739
		end -- 739
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.doorOpenSec) -- 741
		self.active = false -- 742
		self:syncDerivedMilestones(self.seqElapsed, route) -- 743
		return -- 744
	end -- 744
	if not self.active then -- 747
		self.active = true -- 748
		self.staleInputMustRelease = ctx.input.interact.held or ctx.input.retry.held or ctx.input.interact.pressed -- 749
		self.confirmReady = false -- 750
	end -- 750
	if justEnteredKnock then -- 753
		self.seqElapsed = p.phaseTick / 60 -- 754
		self.holdElapsed = 0 -- 755
		self.staleInputMustRelease = true -- 756
		self.confirmReady = false -- 757
	elseif justEnteredGiven then -- 758
		self.doorOpened = true -- 759
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 760
	elseif justEnteredEnd then -- 761
		self.doorOpened = true -- 762
		self.seqElapsed = math.max(self.seqElapsed, 3.6) -- 764
	end -- 764
	if not ctx.paused and #ctx.events.rawEvents > 0 then -- 768
		local i = 0 -- 769
		do -- 769
			i = 0 -- 770
			while i < #ctx.events.rawEvents do -- 770
				local ev = ctx.events.rawEvents[i + 1] -- 771
				if ev.name == "knock" then -- 772
					local cnt = type(ev.data.count) == "number" and ev.data.count or self.knockCount + 1 -- 773
					if cnt >= 1 and self.knockCount < 1 then -- 774
						self.knockCount = 1 -- 775
						self:playTowerOnce( -- 776
							ctx.audio, -- 776
							"knock1", -- 776
							"sfx", -- 776
							____exports.TOWER_AUDIO_FILES.knock1, -- 776
							0.88, -- 776
							"tower:knock:1", -- 776
							ev.tick, -- 776
							ev.seq -- 776
						) -- 776
					end -- 776
					if cnt >= 2 and self.knockCount < 2 then -- 778
						self.knockCount = 2 -- 779
						self:playTowerOnce( -- 780
							ctx.audio, -- 780
							"knock2", -- 780
							"sfx", -- 780
							____exports.TOWER_AUDIO_FILES.knock2, -- 780
							0.9, -- 780
							"tower:knock:2", -- 780
							ev.tick, -- 780
							ev.seq -- 780
						) -- 780
					end -- 780
				end -- 780
				i = i + 1 -- 770
			end -- 770
		end -- 770
	end -- 770
	if not ctx.paused and ctx.worldDt > 0 then -- 786
		if phase == "tower-knock" then -- 787
			local backendSec = math.min(____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60) -- 789
			self.seqElapsed = math.max(self.seqElapsed + ctx.worldDt, backendSec) -- 790
			if self.seqElapsed > ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 then -- 791
				self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 -- 792
			end -- 792
		else -- 792
			self.seqElapsed = self.seqElapsed + ctx.worldDt -- 795
			if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 796
				self.holdElapsed = self.holdElapsed + ctx.worldDt -- 797
			end -- 797
		end -- 797
	end -- 797
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 802
		self.doorClosedAfterRetry = true -- 803
	end -- 803
	self:syncDerivedMilestones(self.seqElapsed, route) -- 805
end -- 716
function TowerEndingsPlugin.prototype.stepRehearsal(self, ctx, route) -- 808
	self.active = true -- 809
	if not ctx.paused and ctx.worldDt > 0 then -- 810
		self.seqElapsed = self.seqElapsed + ctx.worldDt -- 811
		if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 812
			self.holdElapsed = self.holdElapsed + ctx.worldDt -- 813
		end -- 813
	end -- 813
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 816
		self.doorClosedAfterRetry = true -- 817
	end -- 817
	self:syncDerivedMilestones(self.seqElapsed, route) -- 819
end -- 808
function TowerEndingsPlugin.prototype.syncDerivedMilestones(self, t, route) -- 822
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec and self.knockCount < 1 then -- 823
		self.knockCount = 1 -- 824
	end -- 824
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec and self.knockCount < 2 then -- 826
		self.knockCount = 2 -- 827
	end -- 827
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec and self.replyKnockCount < 1 then -- 829
		self.replyKnockCount = 1 -- 830
	end -- 830
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec and self.replyKnockCount < 2 then -- 832
		self.replyKnockCount = 2 -- 833
	end -- 833
	if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 835
		self.doorOpened = true -- 836
	end -- 836
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec and not self.row1Written then -- 839
		self.row1Written = true -- 840
		self.registryAppendCount = self.registryAppendCount + 1 -- 841
	end -- 841
	if route == "soldier" and t >= 4.6 and not self.row2Written then -- 843
		self.row2Written = true -- 844
		self.registryAppendCount = self.registryAppendCount + 1 -- 845
	end -- 845
	if route == "child" and self.row2Written then -- 847
		self.row2Written = false -- 849
		self.registryAppendCount = self.row1Written and 1 or 0 -- 850
	end -- 850
end -- 822
function TowerEndingsPlugin.prototype.stepInputGuard(self, input) -- 854
	local keyHeld = input.interact.held or input.retry.held -- 855
	local keyPressed = input.interact.pressed or input.retry.pressed -- 856
	local readyTime = self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 857
	if self.staleInputMustRelease then -- 859
		if not keyHeld then -- 860
			self.staleInputMustRelease = false -- 861
		elseif keyPressed then -- 862
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 863
		end -- 863
		self.confirmReady = false -- 865
		return -- 866
	end -- 866
	if not readyTime then -- 869
		if keyPressed then -- 870
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 871
			self.staleInputMustRelease = keyHeld -- 872
		end -- 872
		self.confirmReady = false -- 874
		return -- 875
	end -- 875
	self.confirmReady = true -- 878
	if self.rehearsalActive and keyPressed then -- 879
		self.rehearsalAcknowledged = true -- 880
	end -- 880
end -- 854
function TowerEndingsPlugin.prototype.playTowerOnce(self, audio, tag, track, path, volume, cueId, tick, seq) -- 884
	if seq == nil then -- 892
		seq = -1 -- 892
	end -- 892
	local dedupeKey = (("tower:s" .. tostring(self.sessionId)) .. ":") .. tag -- 894
	audio:playOnce( -- 895
		dedupeKey, -- 895
		track, -- 895
		path, -- 895
		volume, -- 895
		cueId, -- 895
		tick, -- 895
		seq -- 895
	) -- 895
end -- 884
function TowerEndingsPlugin.prototype.syncAudioCues(self, audio, ctx, route) -- 898
	local t = self.seqElapsed -- 899
	local tick = ctx.p.ticks -- 900
	local indoorK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.5, t) -- 901
	self.loopsActive = true -- 904
	audio:playLoop( -- 905
		"tower_wind_cold", -- 905
		"wind", -- 905
		____exports.TOWER_AUDIO_FILES.windCold, -- 905
		lerp(0.36, 0.14, indoorK), -- 905
		tick -- 905
	) -- 905
	if indoorK > 0.05 then -- 906
		audio:playLoop( -- 907
			"tower_room_warm", -- 907
			"ambience", -- 907
			____exports.TOWER_AUDIO_FILES.roomWarm, -- 907
			lerp(0.06, 0.34, indoorK), -- 907
			tick -- 907
		) -- 907
	end -- 907
	if self.indoorRetryCount == 0 then -- 911
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec then -- 912
			self:playTowerOnce( -- 913
				audio, -- 913
				"knock1", -- 913
				"sfx", -- 913
				____exports.TOWER_AUDIO_FILES.knock1, -- 913
				0.88, -- 913
				"tower:knock:1", -- 913
				tick -- 913
			) -- 913
		end -- 913
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec then -- 915
			self:playTowerOnce( -- 916
				audio, -- 916
				"knock2", -- 916
				"sfx", -- 916
				____exports.TOWER_AUDIO_FILES.knock2, -- 916
				0.9, -- 916
				"tower:knock:2", -- 916
				tick -- 916
			) -- 916
		end -- 916
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 918
			self:playTowerOnce( -- 919
				audio, -- 919
				"reply1", -- 919
				"sfx", -- 919
				____exports.TOWER_AUDIO_FILES.reply1, -- 919
				0.78, -- 919
				"tower:reply:1", -- 919
				tick -- 919
			) -- 919
		end -- 919
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec then -- 921
			self:playTowerOnce( -- 922
				audio, -- 922
				"reply2", -- 922
				"sfx", -- 922
				____exports.TOWER_AUDIO_FILES.reply2, -- 922
				0.8, -- 922
				"tower:reply:2", -- 922
				tick -- 922
			) -- 922
		end -- 922
		if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 924
			self:playTowerOnce( -- 925
				audio, -- 925
				"door_open", -- 925
				"sfx", -- 925
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 925
				0.84, -- 925
				"tower:door_open", -- 925
				tick -- 925
			) -- 925
		end -- 925
	end -- 925
	if t >= 1.5 then -- 929
		self:playTowerOnce( -- 930
			audio, -- 930
			"book_open", -- 930
			"sfx", -- 930
			____exports.TOWER_AUDIO_FILES.bookOpen, -- 930
			0.82, -- 930
			"tower:book_open", -- 930
			tick -- 930
		) -- 930
	end -- 930
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 932
		self:playTowerOnce( -- 933
			audio, -- 933
			"brush1", -- 933
			"sfx", -- 933
			____exports.TOWER_AUDIO_FILES.brush1, -- 933
			0.8, -- 933
			"tower:brush:row1", -- 933
			tick -- 933
		) -- 933
	end -- 933
	if route == "child" then -- 936
		if t >= 4.35 then -- 937
			self:playTowerOnce( -- 938
				audio, -- 938
				"f03_line", -- 938
				"voice", -- 938
				____exports.TOWER_AUDIO_FILES.lineXiaomanLamp, -- 938
				0.86, -- 938
				"tower:f03:line_lamp", -- 938
				tick -- 938
			) -- 938
		end -- 938
		if t >= 4.45 then -- 940
			self:playTowerOnce( -- 941
				audio, -- 941
				"f03_bowl", -- 941
				"sfx", -- 941
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 941
				0.8, -- 941
				"tower:bowl_set", -- 941
				tick -- 941
			) -- 941
		end -- 941
		if t >= 5.2 then -- 943
			self:playTowerOnce( -- 944
				audio, -- 944
				"f03_lamp", -- 944
				"sfx", -- 944
				____exports.TOWER_AUDIO_FILES.lampMove, -- 944
				0.82, -- 944
				"tower:f03:lamp_move", -- 944
				tick -- 944
			) -- 944
		end -- 944
	else -- 944
		if t >= 4.28 then -- 947
			self:playTowerOnce( -- 948
				audio, -- 948
				"m03_line", -- 948
				"voice", -- 948
				____exports.TOWER_AUDIO_FILES.lineZhoushuName, -- 948
				0.9, -- 948
				"tower:m03:line_name", -- 948
				tick -- 948
			) -- 948
		end -- 948
		if t >= 4.62 then -- 950
			self:playTowerOnce( -- 951
				audio, -- 951
				"brush2", -- 951
				"sfx", -- 951
				____exports.TOWER_AUDIO_FILES.brush2, -- 951
				0.82, -- 951
				"tower:brush:row2", -- 951
				tick -- 951
			) -- 951
		end -- 951
		if t >= 5.55 then -- 953
			self:playTowerOnce( -- 954
				audio, -- 954
				"m03_needle", -- 954
				"sfx", -- 954
				____exports.TOWER_AUDIO_FILES.needlePlace, -- 954
				0.8, -- 954
				"tower:m03:needle_place", -- 954
				tick -- 954
			) -- 954
		end -- 954
		if t >= 6.02 then -- 956
			self:playTowerOnce( -- 957
				audio, -- 957
				"m03_bowl", -- 957
				"sfx", -- 957
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 957
				0.82, -- 957
				"tower:bowl_set", -- 957
				tick -- 957
			) -- 957
		end -- 957
	end -- 957
end -- 898
function TowerEndingsPlugin.prototype.composeSubtitle(self, route) -- 962
	local t = self.seqElapsed -- 963
	if t < ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 964
		return "[两下轻敲]  门外厚木上传来两声轻敲。" -- 965
	end -- 965
	if t < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 967
		return "[门内回敲]  静默一息，门后轻轻回敲两声。" -- 968
	end -- 968
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 970
		return route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 971
	end -- 971
	if t < ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 975
		return route == "child" and "她把针套与纸条摊在案前，守卒展开收籍末页。" or "两人站在值夜室内，守卒摊开收籍末页。" -- 976
	end -- 976
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 980
		return "守卒蘸墨提笔，在第一行写下「小满」。" -- 981
	end -- 981
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 983
		return "笔尖停在第二行上方。" -- 984
	end -- 984
	if route == "child" then -- 986
		if t < 6.7 then -- 987
			return F03_DIALOGUE -- 988
		end -- 988
		return "" -- 990
	end -- 990
	if t < 5.45 then -- 992
		return M03_DIALOGUE -- 993
	end -- 993
	if t < 6.85 then -- 995
		return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。" -- 996
	end -- 996
	return "" -- 998
end -- 962
function TowerEndingsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1003
	if not self.active then -- 1010
		return false -- 1011
	end -- 1011
	local route = self.activeRoute -- 1014
	local t = self.seqElapsed -- 1015
	local lampProg = route == "child" and smoothstep(5.2, 6.75, t) or 0 -- 1016
	local scaled = computeScaledAnchors(ctx.uiW, ctx.uiH, lampProg) -- 1017
	local s = scaled.s -- 1018
	local ox = scaled.ox -- 1019
	local oy = scaled.oy -- 1020
	uiDraw:drawRect( -- 1023
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1023
		Color(8, 10, 16, 255) -- 1023
	) -- 1023
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1025
		self:drawAct1PorchAndDoor( -- 1027
			uiDraw, -- 1027
			uiInkDraw, -- 1027
			uiArt, -- 1027
			uiGlow, -- 1027
			ctx, -- 1027
			route, -- 1027
			s, -- 1027
			ox, -- 1027
			oy -- 1027
		) -- 1027
		local fadeOut = smoothstep(1.22, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec, t) -- 1029
		if fadeOut > 0.01 then -- 1030
			uiInkDraw:drawRect( -- 1031
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1031
				Color( -- 1031
					8, -- 1031
					10, -- 1031
					16, -- 1031
					math.floor(230 * fadeOut + 0.5) -- 1031
				) -- 1031
			) -- 1031
		end -- 1031
	else -- 1031
		self:drawAct2And3Guardroom( -- 1035
			uiDraw, -- 1035
			uiInkDraw, -- 1035
			uiArt, -- 1035
			uiGlow, -- 1035
			ctx, -- 1035
			route, -- 1035
			lampProg, -- 1035
			s, -- 1035
			ox, -- 1035
			oy -- 1035
		) -- 1035
		local fadeIn = 1 - smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.24, t) -- 1036
		if fadeIn > 0.01 then -- 1037
			uiInkDraw:drawRect( -- 1038
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1038
				Color( -- 1038
					8, -- 1038
					10, -- 1038
					16, -- 1038
					math.floor(220 * fadeIn + 0.5) -- 1038
				) -- 1038
			) -- 1038
		end -- 1038
	end -- 1038
	local barH = math.floor(____exports.TOWER_SHOT_LAYOUT.letterboxH * s + 0.5) -- 1043
	uiInkDraw:drawRect( -- 1044
		Rect(0, ctx.uiH - barH, ctx.uiW, barH), -- 1044
		Color(7, 9, 14, 248) -- 1044
	) -- 1044
	uiInkDraw:drawRect( -- 1045
		Rect(0, 0, ctx.uiW, barH), -- 1045
		Color(7, 9, 14, 248) -- 1045
	) -- 1045
	uiInkDraw:drawSegment( -- 1046
		Vec2(0, ctx.uiH - barH), -- 1046
		Vec2(ctx.uiW, ctx.uiH - barH), -- 1046
		0.9, -- 1046
		toColor(PALETTE.silkDim, 82) -- 1046
	) -- 1046
	uiInkDraw:drawSegment( -- 1047
		Vec2(0, barH), -- 1047
		Vec2(ctx.uiW, barH), -- 1047
		0.9, -- 1047
		toColor(PALETTE.silkDim, 82) -- 1047
	) -- 1047
	self:drawDialogueSubtitle( -- 1050
		uiDraw, -- 1050
		uiInkDraw, -- 1050
		uiArt, -- 1050
		ctx, -- 1050
		route, -- 1050
		s, -- 1050
		barH -- 1050
	) -- 1050
	return true -- 1052
end -- 1003
function TowerEndingsPlugin.prototype.drawAct1PorchAndDoor(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1057
	local t = self.seqElapsed -- 1068
	local isLowpoly = route == "child" -- 1069
	local openK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, 1.24, t) -- 1070
	local doorCx = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s -- 1071
	local threshY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s -- 1072
	local doorW = ____exports.TOWER_SHOT_LAYOUT.doorW * s -- 1073
	local doorH = ____exports.TOWER_SHOT_LAYOUT.doorH * s -- 1074
	local doorL = doorCx - doorW * 0.5 -- 1075
	local doorR = doorCx + doorW * 0.5 -- 1076
	local k1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock1Sec) / 0.055) ^ 2) -- 1079
	local k2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock2Sec) / 0.055) ^ 2) -- 1080
	local r1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply1Sec) / 0.06) ^ 2) -- 1081
	local r2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply2Sec) / 0.06) ^ 2) -- 1082
	local doorShakeX = (k1Pulse + k2Pulse) * 2.4 * s * math.sin(t * 95) + (r1Pulse + r2Pulse) * 1.4 * s * math.sin(t * 80) -- 1083
	if isLowpoly then -- 1086
		local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, openK * 0.62) -- 1088
		fillVGradRect( -- 1089
			uiDraw, -- 1090
			0, -- 1090
			0, -- 1090
			ctx.uiW, -- 1090
			ctx.uiH, -- 1090
			Color(12, 16, 26, 255), -- 1091
			Color(20, 28, 44, 255) -- 1092
		) -- 1092
		local wallCol = shadeSurface( -- 1095
			MING_MATERIALS.mingBrickDark.base, -- 1095
			vec3(0, 0, -1), -- 1095
			24, -- 1095
			1, -- 1095
			light, -- 1095
			MING_MATERIALS.mingBrickDark -- 1095
		) -- 1095
		local jambCol = shadeSurface( -- 1096
			MING_MATERIALS.mingBrick.base, -- 1096
			vec3(0.75, 0.15, -0.64), -- 1096
			10, -- 1096
			1, -- 1096
			light, -- 1096
			MING_MATERIALS.mingBrick -- 1096
		) -- 1096
		local jambRCol = shadeSurface( -- 1097
			MING_MATERIALS.mingBrick.base, -- 1097
			vec3(-0.75, 0.15, -0.64), -- 1097
			10, -- 1097
			1, -- 1097
			light, -- 1097
			MING_MATERIALS.mingBrick -- 1097
		) -- 1097
		local lintelCol = shadeSurface( -- 1098
			MING_MATERIALS.mingStoneStep.base, -- 1098
			vec3(0, -0.55, -0.83), -- 1098
			6, -- 1098
			1, -- 1098
			light, -- 1098
			MING_MATERIALS.mingStoneStep -- 1098
		) -- 1098
		local stepCol = shadeSurface( -- 1099
			MING_MATERIALS.mingStoneStep.base, -- 1099
			vec3(0, 0.92, -0.39), -- 1099
			0, -- 1099
			1, -- 1099
			light, -- 1099
			MING_MATERIALS.mingStoneStep -- 1099
		) -- 1099
		uiDraw:drawRect( -- 1101
			Rect(0, threshY, doorL - 26 * s, ctx.uiH - threshY), -- 1101
			toColor(wallCol) -- 1101
		) -- 1101
		uiDraw:drawRect( -- 1102
			Rect(doorR + 26 * s, threshY, ctx.uiW - (doorR + 26 * s), ctx.uiH - threshY), -- 1102
			toColor(wallCol) -- 1102
		) -- 1102
		uiDraw:drawPolygon( -- 1104
			{ -- 1104
				Vec2(doorL - 26 * s, threshY), -- 1105
				Vec2(doorL, threshY + 12 * s), -- 1106
				Vec2(doorL, threshY + doorH - 8 * s), -- 1107
				Vec2(doorL - 26 * s, threshY + doorH + 18 * s) -- 1108
			}, -- 1108
			toColor(jambCol), -- 1109
			1, -- 1109
			toColor(PALETTE.silkDim, 68) -- 1109
		) -- 1109
		uiDraw:drawPolygon( -- 1110
			{ -- 1110
				Vec2(doorR + 26 * s, threshY), -- 1111
				Vec2(doorR, threshY + 12 * s), -- 1112
				Vec2(doorR, threshY + doorH - 8 * s), -- 1113
				Vec2(doorR + 26 * s, threshY + doorH + 18 * s) -- 1114
			}, -- 1114
			toColor(jambRCol), -- 1115
			1, -- 1115
			toColor(PALETTE.silkDim, 68) -- 1115
		) -- 1115
		uiDraw:drawPolygon( -- 1117
			{ -- 1117
				Vec2(doorL - 44 * s, threshY + doorH + 18 * s), -- 1118
				Vec2(doorR + 44 * s, threshY + doorH + 18 * s), -- 1119
				Vec2(doorR + 58 * s, threshY + doorH + 92 * s), -- 1120
				Vec2(doorL - 58 * s, threshY + doorH + 92 * s) -- 1121
			}, -- 1121
			toColor(lintelCol), -- 1122
			1.1, -- 1122
			toColor(STONE_EDGE_FALLBACK, 130) -- 1122
		) -- 1122
		uiDraw:drawRect( -- 1124
			Rect(0, 0, ctx.uiW, threshY), -- 1124
			Color(16, 20, 30, 255) -- 1124
		) -- 1124
		uiDraw:drawPolygon( -- 1125
			{ -- 1125
				Vec2(doorL - 58 * s, threshY - 20 * s), -- 1126
				Vec2(doorR + 58 * s, threshY - 20 * s), -- 1127
				Vec2(doorR + 28 * s, threshY + 12 * s), -- 1128
				Vec2(doorL - 28 * s, threshY + 12 * s) -- 1129
			}, -- 1129
			toColor(stepCol), -- 1130
			1, -- 1130
			toColor(STONE_EDGE_FALLBACK, 150) -- 1130
		) -- 1130
		uiDraw:drawPolygon( -- 1132
			{ -- 1132
				Vec2(0, 0), -- 1133
				Vec2(142 * s, 0), -- 1134
				Vec2(114 * s, ctx.uiH), -- 1135
				Vec2(0, ctx.uiH) -- 1136
			}, -- 1136
			Color(10, 14, 22, 220) -- 1137
		) -- 1137
		uiDraw:drawPolygon( -- 1138
			{ -- 1138
				Vec2(ctx.uiW - 142 * s, 0), -- 1139
				Vec2(ctx.uiW, 0), -- 1140
				Vec2(ctx.uiW, ctx.uiH), -- 1141
				Vec2(ctx.uiW - 114 * s, ctx.uiH) -- 1142
			}, -- 1142
			Color(10, 14, 22, 220) -- 1143
		) -- 1143
	else -- 1143
		fillVGradRect( -- 1146
			uiDraw, -- 1147
			0, -- 1147
			0, -- 1147
			ctx.uiW, -- 1147
			ctx.uiH, -- 1147
			Color(18, 22, 32, 255), -- 1148
			Color(32, 38, 52, 255) -- 1149
		) -- 1149
		uiDraw:drawPolygon( -- 1152
			{ -- 1152
				Vec2(0, threshY), -- 1153
				Vec2(doorL, threshY), -- 1154
				Vec2(doorL, threshY + 188 * s), -- 1155
				Vec2(doorL * 0.55, threshY + 230 * s), -- 1156
				Vec2(doorL * 0.22, threshY + 172 * s), -- 1157
				Vec2(0, threshY + 196 * s) -- 1158
			}, -- 1158
			Color(26, 30, 40, 235) -- 1159
		) -- 1159
		uiDraw:drawPolygon( -- 1160
			{ -- 1160
				Vec2(doorR, threshY), -- 1161
				Vec2(ctx.uiW, threshY), -- 1162
				Vec2(ctx.uiW, threshY + 218 * s), -- 1163
				Vec2(doorR + (ctx.uiW - doorR) * 0.56, threshY + 248 * s), -- 1164
				Vec2(doorR, threshY + 178 * s) -- 1165
			}, -- 1165
			Color(26, 30, 40, 235) -- 1166
		) -- 1166
		uiDraw:drawRect( -- 1168
			Rect(0, threshY, doorL, ctx.uiH - threshY), -- 1168
			Color(54, 56, 62, 255), -- 1168
			1, -- 1168
			Color(88, 90, 96, 155) -- 1168
		) -- 1168
		uiDraw:drawRect( -- 1169
			Rect(doorR, threshY, ctx.uiW - doorR, ctx.uiH - threshY), -- 1169
			Color(54, 56, 62, 255), -- 1169
			1, -- 1169
			Color(88, 90, 96, 155) -- 1169
		) -- 1169
		uiDraw:drawRect( -- 1170
			Rect(doorL - 28 * s, threshY + doorH, doorW + 56 * s, 68 * s), -- 1170
			Color(72, 68, 62, 255), -- 1170
			1, -- 1170
			Color(124, 114, 100, 175) -- 1170
		) -- 1170
		local row = 0 -- 1171
		do -- 1171
			row = 0 -- 1172
			while row < 10 do -- 1172
				local by = threshY + row * 46 * s -- 1173
				uiDraw:drawSegment( -- 1174
					Vec2(0, by), -- 1174
					Vec2(doorL, by), -- 1174
					1, -- 1174
					Color(34, 36, 42, 175) -- 1174
				) -- 1174
				uiDraw:drawSegment( -- 1175
					Vec2(doorR, by), -- 1175
					Vec2(ctx.uiW, by), -- 1175
					1, -- 1175
					Color(34, 36, 42, 175) -- 1175
				) -- 1175
				local stag = row % 2 * 34 * s -- 1176
				local col = 0 -- 1177
				do -- 1177
					col = 0 -- 1178
					while col < 7 do -- 1178
						local lx = stag + col * 68 * s -- 1179
						if lx > 4 * s and lx < doorL - 4 * s then -- 1180
							uiDraw:drawSegment( -- 1181
								Vec2(lx, by), -- 1181
								Vec2(lx, by + 46 * s), -- 1181
								0.9, -- 1181
								Color(36, 38, 44, 130) -- 1181
							) -- 1181
						end -- 1181
						local rx = doorR + stag + col * 68 * s -- 1183
						if rx > doorR + 4 * s and rx < ctx.uiW - 4 * s then -- 1184
							uiDraw:drawSegment( -- 1185
								Vec2(rx, by), -- 1185
								Vec2(rx, by + 46 * s), -- 1185
								0.9, -- 1185
								Color(36, 38, 44, 130) -- 1185
							) -- 1185
						end -- 1185
						col = col + 1 -- 1178
					end -- 1178
				end -- 1178
				row = row + 1 -- 1172
			end -- 1172
		end -- 1172
		uiDraw:drawRect( -- 1190
			Rect(0, 0, ctx.uiW, threshY), -- 1190
			Color(28, 26, 28, 255) -- 1190
		) -- 1190
		uiDraw:drawRect( -- 1191
			Rect(doorL - 36 * s, threshY - 12 * s, doorW + 72 * s, 22 * s), -- 1191
			Color(96, 94, 92, 255), -- 1191
			1, -- 1191
			Color(156, 152, 144, 175) -- 1191
		) -- 1191
	end -- 1191
	local innerWarm = 0.22 + openK * 0.78 + (r1Pulse + r2Pulse) * 0.14 -- 1195
	fillVGradRect( -- 1196
		uiDraw, -- 1197
		doorL, -- 1197
		threshY + 8 * s, -- 1197
		doorW, -- 1197
		doorH - 8 * s, -- 1197
		Color( -- 1198
			46, -- 1198
			32, -- 1198
			20, -- 1198
			math.floor(255 * math.min(1, innerWarm + 0.15) + 0.5) -- 1198
		), -- 1198
		Color( -- 1199
			118, -- 1199
			82, -- 1199
			42, -- 1199
			math.floor(255 * math.min(1, innerWarm) + 0.5) -- 1199
		) -- 1199
	) -- 1199
	local leafW = math.max(26 * s, doorW * (1 - openK * 0.76)) -- 1203
	local leafX = doorL + doorShakeX * (1 - openK) -- 1204
	local woodCol = isLowpoly and toColor(shadeSurface( -- 1205
		MING_MATERIALS.mingTimberDark.base, -- 1206
		vec3(-0.2, 0.25, -0.95), -- 1206
		4, -- 1206
		1, -- 1206
		TOWER_WEST_LAMP_LIGHT, -- 1206
		MING_MATERIALS.mingTimberDark -- 1206
	)) or Color(76, 54, 38, 255) -- 1207
	uiDraw:drawRect( -- 1208
		Rect(leafX, threshY + 12 * s, leafW, doorH - 14 * s), -- 1209
		woodCol, -- 1210
		1.4, -- 1211
		Color(138, 106, 74, 185) -- 1212
	) -- 1212
	local planks = 4 -- 1215
	local pi = 1 -- 1216
	do -- 1216
		pi = 1 -- 1217
		while pi < planks do -- 1217
			local px = leafX + leafW * pi / planks -- 1218
			uiDraw:drawSegment( -- 1219
				Vec2(px, threshY + 14 * s), -- 1219
				Vec2(px, threshY + doorH - 4 * s), -- 1219
				1.1, -- 1219
				Color(38, 26, 18, 185) -- 1219
			) -- 1219
			pi = pi + 1 -- 1217
		end -- 1217
	end -- 1217
	uiDraw:drawRect( -- 1221
		Rect(leafX + 4 * s, threshY + doorH * 0.24, leafW - 8 * s, 10 * s), -- 1221
		Color(54, 38, 26, 225) -- 1221
	) -- 1221
	uiDraw:drawRect( -- 1222
		Rect(leafX + 4 * s, threshY + doorH * 0.74, leafW - 8 * s, 10 * s), -- 1222
		Color(54, 38, 26, 225) -- 1222
	) -- 1222
	local ringX = leafX + leafW * 0.72 -- 1224
	local ringY = threshY + doorH * 0.56 -- 1225
	uiDraw:drawRect( -- 1226
		Rect(ringX - 6 * s, ringY + 4 * s, 12 * s, 12 * s), -- 1226
		Color(42, 46, 52, 235), -- 1226
		1, -- 1226
		Color(96, 100, 108, 170) -- 1226
	) -- 1226
	strokeEllipse( -- 1227
		uiDraw, -- 1227
		ringX, -- 1227
		ringY - 2 * s, -- 1227
		8 * s, -- 1227
		9 * s, -- 1227
		1.8 * s, -- 1227
		Color(108, 112, 118, 195), -- 1227
		16 -- 1227
	) -- 1227
	local seamGlowA = math.floor(92 + openK * 145 + (r1Pulse + r2Pulse) * 48 + 0.5) -- 1230
	fillRadialGlow( -- 1231
		uiGlow, -- 1232
		doorCx + openK * 24 * s, -- 1232
		threshY + 14 * s, -- 1232
		(92 + openK * 120) * s, -- 1233
		(26 + openK * 58) * s, -- 1233
		Color( -- 1234
			246, -- 1234
			204, -- 1234
			134, -- 1234
			math.min(220, seamGlowA) -- 1234
		), -- 1234
		Color(220, 156, 72, 0), -- 1235
		18 -- 1236
	) -- 1236
	local kx = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s -- 1240
	local ky = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s -- 1241
	if k1Pulse > 0.08 or k2Pulse > 0.08 then -- 1242
		local amp = math.max(k1Pulse, k2Pulse) -- 1243
		local r = (18 + (1 - amp) * 34) * s -- 1244
		strokeEllipse( -- 1245
			uiInkDraw, -- 1245
			kx + 24 * s, -- 1245
			ky, -- 1245
			r, -- 1245
			r * 0.85, -- 1245
			1.8 * s, -- 1245
			toColor( -- 1245
				PALETTE.amberCore, -- 1245
				math.floor(210 * amp + 0.5) -- 1245
			), -- 1245
			24 -- 1245
		) -- 1245
	end -- 1245
	if r1Pulse > 0.08 or r2Pulse > 0.08 then -- 1247
		local amp = math.max(r1Pulse, r2Pulse) -- 1248
		local r = (24 + (1 - amp) * 42) * s -- 1249
		strokeEllipse( -- 1250
			uiInkDraw, -- 1250
			doorCx + 30 * s, -- 1250
			ky + 16 * s, -- 1250
			r, -- 1250
			r * 0.9, -- 1250
			1.6 * s, -- 1250
			toColor( -- 1250
				PALETTE.amber, -- 1250
				math.floor(185 * amp + 0.5) -- 1250
			), -- 1250
			24 -- 1250
		) -- 1250
	end -- 1250
	if openK > 0.05 then -- 1254
		local lanX = ox + ____exports.TOWER_SHOT_LAYOUT.doorLanternX * s + (1 - openK) * 42 * s -- 1255
		local lanY = oy + ____exports.TOWER_SHOT_LAYOUT.doorLanternY * s -- 1256
		uiInkDraw:drawPolygon( -- 1258
			{ -- 1258
				Vec2(lanX + 76 * s, lanY + 42 * s), -- 1259
				Vec2(lanX + 12 * s, lanY + 34 * s), -- 1260
				Vec2(lanX + 8 * s, lanY + 12 * s), -- 1261
				Vec2(lanX + 78 * s, lanY + 12 * s) -- 1262
			}, -- 1262
			Color( -- 1263
				54, -- 1263
				48, -- 1263
				44, -- 1263
				math.floor(240 * openK + 0.5) -- 1263
			), -- 1263
			1, -- 1263
			Color( -- 1263
				98, -- 1263
				86, -- 1263
				74, -- 1263
				math.floor(180 * openK + 0.5) -- 1263
			) -- 1263
		) -- 1263
		self:drawMingLantern( -- 1264
			uiInkDraw, -- 1264
			uiGlow, -- 1264
			lanX, -- 1264
			lanY - 14 * s, -- 1264
			1.08 * s, -- 1264
			openK, -- 1264
			1 -- 1264
		) -- 1264
		fillRadialGlow( -- 1266
			uiGlow, -- 1267
			kx + 12 * s, -- 1267
			ky - 14 * s, -- 1267
			148 * s, -- 1268
			128 * s, -- 1268
			Color( -- 1269
				246, -- 1269
				208, -- 1269
				142, -- 1269
				math.floor(98 * openK + 0.5) -- 1269
			), -- 1269
			Color(232, 174, 92, 0), -- 1270
			18 -- 1271
		) -- 1271
	end -- 1271
	local stepInX = openK * 44 * s -- 1276
	local xiaomanX = doorCx - 66 * s + stepInX -- 1277
	local xiaomanY = threshY - 2 * s -- 1278
	uiDraw:drawEllipse( -- 1280
		Vec2(xiaomanX, xiaomanY + 2 * s), -- 1280
		34 * s, -- 1280
		8 * s, -- 1280
		Color(4, 6, 12, 190) -- 1280
	) -- 1280
	local childSlot = (k1Pulse > 0.25 or k2Pulse > 0.25) and "child_knock" or (openK > 0.45 and "child_offer" or "child_idle") -- 1281
	uiArt:tryPlace( -- 1282
		childSlot, -- 1282
		"fe05_porch_child", -- 1282
		xiaomanX, -- 1282
		xiaomanY, -- 1282
		108 * s, -- 1282
		148 * s, -- 1282
		{facing = 1, opacity = 0.98, layer = 2} -- 1282
	) -- 1282
	if openK > 0.15 then -- 1286
		local wristX = xiaomanX + 22 * s -- 1287
		local wristY = xiaomanY + 76 * s -- 1288
		uiInkDraw:drawRect( -- 1289
			Rect(wristX - 7 * s, wristY - 5 * s, 14 * s, 11 * s), -- 1290
			Color( -- 1291
				142, -- 1291
				118, -- 1291
				84, -- 1291
				math.floor(245 * openK + 0.5) -- 1291
			), -- 1291
			1, -- 1292
			Color( -- 1293
				222, -- 1293
				192, -- 1293
				128, -- 1293
				math.floor(235 * openK + 0.5) -- 1293
			) -- 1293
		) -- 1293
		uiInkDraw:drawSegment( -- 1295
			Vec2(wristX - 8 * s, wristY), -- 1296
			Vec2(wristX + 8 * s, wristY + 2 * s), -- 1297
			2 * s, -- 1298
			toColor( -- 1299
				CUFF_PALETTE.childCord, -- 1299
				math.floor(240 * openK + 0.5) -- 1299
			) -- 1299
		) -- 1299
	end -- 1299
	if route == "soldier" then -- 1303
		local zhouX = xiaomanX - 72 * s -- 1305
		local zhouY = threshY - 2 * s -- 1306
		uiDraw:drawEllipse( -- 1307
			Vec2(zhouX, zhouY + 2 * s), -- 1307
			42 * s, -- 1307
			9 * s, -- 1307
			Color(4, 6, 12, 190) -- 1307
		) -- 1307
		uiArt:tryPlace( -- 1308
			"soldier_idle", -- 1308
			"fe05_porch_soldier", -- 1308
			zhouX, -- 1308
			zhouY, -- 1308
			146 * s, -- 1308
			206 * s, -- 1308
			{facing = 1, opacity = 0.98, layer = 2} -- 1308
		) -- 1308
		local handMidX = (zhouX + xiaomanX) * 0.5 + 4 * s -- 1312
		local handMidY = threshY + 66 * s -- 1313
		uiInkDraw:drawSegment( -- 1314
			Vec2(zhouX + 20 * s, threshY + 106 * s), -- 1315
			Vec2(handMidX - 2 * s, handMidY), -- 1316
			6.2 * s, -- 1317
			toColor(CUFF_PALETTE.indigoBase, 245) -- 1318
		) -- 1318
		uiInkDraw:drawSegment( -- 1320
			Vec2(handMidX - 9 * s, handMidY + 9 * s), -- 1321
			Vec2(handMidX - 3 * s, handMidY + 13 * s), -- 1322
			1.9 * s, -- 1323
			toColor(CUFF_PALETTE.stitchThread, 240) -- 1324
		) -- 1324
		uiInkDraw:drawSegment( -- 1326
			Vec2(xiaomanX - 14 * s, threshY + 78 * s), -- 1327
			Vec2(handMidX + 2 * s, handMidY), -- 1328
			4.8 * s, -- 1329
			toColor(CUFF_PALETTE.childSleeve, 245) -- 1330
		) -- 1330
		uiInkDraw:drawDot( -- 1332
			Vec2(handMidX, handMidY), -- 1332
			4.8 * s, -- 1332
			toColor(CUFF_PALETTE.skinLight, 245) -- 1332
		) -- 1332
	end -- 1332
end -- 1057
function TowerEndingsPlugin.prototype.drawAct2And3Guardroom(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy) -- 1338
	local t = self.seqElapsed -- 1350
	local isLowpoly = route == "child" -- 1351
	local deskY = oy + ____exports.TOWER_SHOT_LAYOUT.deskTopY * s -- 1352
	if isLowpoly then -- 1355
		self:drawF03LowpolyRoomAndWindow( -- 1356
			uiDraw, -- 1356
			uiInkDraw, -- 1356
			uiArt, -- 1356
			uiGlow, -- 1356
			ctx, -- 1356
			lampProg, -- 1356
			s, -- 1356
			ox, -- 1356
			oy -- 1356
		) -- 1356
	else -- 1356
		self:drawM03PixelRoomAndWindow( -- 1358
			uiDraw, -- 1358
			uiInkDraw, -- 1358
			uiArt, -- 1358
			uiGlow, -- 1358
			ctx, -- 1358
			s, -- 1358
			ox, -- 1358
			oy -- 1358
		) -- 1358
	end -- 1358
	local deskTopCol = isLowpoly and toColor(shadeSurface( -- 1362
		MING_MATERIALS.mingTimber.base, -- 1364
		vec3(-0.25, 0.9, -0.35), -- 1365
		0, -- 1366
		1, -- 1367
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1368
		MING_MATERIALS.mingTimber -- 1369
	)) or Color(86, 60, 42, 255) -- 1371
	local deskFrontCol = isLowpoly and toColor(shadeSurface( -- 1372
		MING_MATERIALS.mingTimberDark.base, -- 1374
		vec3(0, 0.1, -0.99), -- 1375
		-4, -- 1376
		1, -- 1377
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1378
		MING_MATERIALS.mingTimberDark -- 1379
	)) or Color(52, 36, 26, 255) -- 1381
	uiDraw:drawPolygon( -- 1384
		{ -- 1384
			Vec2(0, deskY - 120 * s), -- 1385
			Vec2(ctx.uiW, deskY - 120 * s), -- 1386
			Vec2(ctx.uiW, deskY + 42 * s), -- 1387
			Vec2(0, deskY + 42 * s) -- 1388
		}, -- 1388
		deskTopCol -- 1389
	) -- 1389
	uiDraw:drawRect( -- 1390
		Rect(0, 0, ctx.uiW, deskY - 118 * s), -- 1390
		deskFrontCol -- 1390
	) -- 1390
	uiDraw:drawSegment( -- 1391
		Vec2(0, deskY + 42 * s), -- 1391
		Vec2(ctx.uiW, deskY + 42 * s), -- 1391
		1.6 * s, -- 1391
		Color(158, 126, 92, 165) -- 1391
	) -- 1391
	uiDraw:drawSegment( -- 1392
		Vec2(0, deskY - 118 * s), -- 1392
		Vec2(ctx.uiW, deskY - 118 * s), -- 1392
		2 * s, -- 1392
		Color(172, 138, 102, 155) -- 1392
	) -- 1392
	local inkX = ox + ____exports.TOWER_SHOT_LAYOUT.inkstoneX * s -- 1395
	local inkY = oy + ____exports.TOWER_SHOT_LAYOUT.inkstoneY * s -- 1396
	uiDraw:drawEllipse( -- 1397
		Vec2(inkX + 3 * s, inkY - 18 * s), -- 1397
		44 * s, -- 1397
		11 * s, -- 1397
		Color(10, 10, 14, 145) -- 1397
	) -- 1397
	uiDraw:drawPolygon( -- 1398
		{ -- 1398
			Vec2(inkX - 38 * s, inkY - 18 * s), -- 1399
			Vec2(inkX + 38 * s, inkY - 18 * s), -- 1400
			Vec2(inkX + 32 * s, inkY + 18 * s), -- 1401
			Vec2(inkX - 32 * s, inkY + 18 * s) -- 1402
		}, -- 1402
		Color(38, 44, 52, 255), -- 1403
		1.2, -- 1403
		Color(96, 106, 118, 185) -- 1403
	) -- 1403
	uiDraw:drawEllipse( -- 1404
		Vec2(inkX, inkY + 1 * s), -- 1404
		22 * s, -- 1404
		10 * s, -- 1404
		Color(12, 14, 18, 255) -- 1404
	) -- 1404
	strokeEllipse( -- 1405
		uiDraw, -- 1405
		inkX, -- 1405
		inkY + 1 * s, -- 1405
		22 * s, -- 1405
		10 * s, -- 1405
		1.1 * s, -- 1405
		Color(76, 86, 98, 165), -- 1405
		18 -- 1405
	) -- 1405
	local lx = isLowpoly and ox + lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s or ox + ____exports.TOWER_SHOT_LAYOUT.lampDeskX * s -- 1408
	local ly = isLowpoly and oy + (lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34) * s or oy + ____exports.TOWER_SHOT_LAYOUT.lampDeskY * s -- 1411
	local lampWarmth = isLowpoly and 0.45 + 0.55 * lampProg or 0.92 -- 1414
	self:drawMingLantern( -- 1415
		uiInkDraw, -- 1415
		uiGlow, -- 1415
		lx, -- 1415
		ly, -- 1415
		1.02 * s, -- 1415
		1, -- 1415
		lampWarmth -- 1415
	) -- 1415
	if isLowpoly and lampProg > 0.04 then -- 1418
		local beamA = math.floor(62 * lampProg + 0.5) -- 1419
		fillGradQuad( -- 1420
			uiGlow, -- 1421
			lx + 10 * s, -- 1422
			ly + 30 * s, -- 1422
			Color(248, 206, 134, beamA), -- 1422
			lx + 10 * s, -- 1423
			ly - 32 * s, -- 1423
			Color( -- 1423
				248, -- 1423
				206, -- 1423
				134, -- 1423
				math.floor(beamA * 0.72 + 0.5) -- 1423
			), -- 1423
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.92) * s, -- 1424
			oy + (____exports.TOWER_SHOT_LAYOUT.row2Y - 58) * s, -- 1424
			Color(242, 198, 124, 0), -- 1424
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.85) * s, -- 1425
			oy + (____exports.TOWER_SHOT_LAYOUT.row1Y + 48) * s, -- 1425
			Color(242, 198, 124, 0) -- 1425
		) -- 1425
	end -- 1425
	local bookReveal = smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t) -- 1430
	if bookReveal > 0.02 then -- 1431
		self:drawRegisterBook( -- 1432
			uiDraw, -- 1432
			uiInkDraw, -- 1432
			uiArt, -- 1432
			uiGlow, -- 1432
			ctx, -- 1432
			route, -- 1432
			bookReveal, -- 1432
			lampProg, -- 1432
			s, -- 1432
			ox, -- 1432
			oy -- 1432
		) -- 1432
	end -- 1432
	self:drawDeskPropsAndBowl( -- 1436
		uiDraw, -- 1436
		uiInkDraw, -- 1436
		uiArt, -- 1436
		uiGlow, -- 1436
		ctx, -- 1436
		route, -- 1436
		s, -- 1436
		ox, -- 1436
		oy -- 1436
	) -- 1436
end -- 1338
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, lampProg, s, ox, oy) -- 1439
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1450
	local wallTop = lerpRGBA( -- 1451
		rgba(18, 24, 38, 255), -- 1451
		rgba(46, 36, 28, 255), -- 1451
		lampProg -- 1451
	) -- 1451
	local wallBot = lerpRGBA( -- 1452
		rgba(12, 16, 26, 255), -- 1452
		rgba(28, 22, 20, 255), -- 1452
		lampProg -- 1452
	) -- 1452
	fillVGradRect( -- 1453
		uiDraw, -- 1453
		0, -- 1453
		0, -- 1453
		ctx.uiW, -- 1453
		ctx.uiH, -- 1453
		toColor(wallBot), -- 1453
		toColor(wallTop) -- 1453
	) -- 1453
	do -- 1453
		local p = 1 -- 1456
		while p < 12 do -- 1456
			local px = ctx.uiW * p / 12 -- 1457
			uiDraw:drawSegment( -- 1458
				Vec2(px, oy + 260 * s), -- 1458
				Vec2(px, ctx.uiH), -- 1458
				1, -- 1458
				Color(14, 14, 20, 96) -- 1458
			) -- 1458
			p = p + 1 -- 1456
		end -- 1456
	end -- 1456
	local beamCol = shadeSurface( -- 1462
		MING_MATERIALS.mingTimberDark.base, -- 1462
		vec3(-0.3, -0.6, -0.74), -- 1462
		18, -- 1462
		1, -- 1462
		light, -- 1462
		MING_MATERIALS.mingTimberDark -- 1462
	) -- 1462
	uiDraw:drawPolygon( -- 1463
		{ -- 1463
			Vec2(0, ctx.uiH - 96 * s), -- 1464
			Vec2(ctx.uiW, ctx.uiH - 72 * s), -- 1465
			Vec2(ctx.uiW, ctx.uiH - 42 * s), -- 1466
			Vec2(0, ctx.uiH - 42 * s) -- 1467
		}, -- 1467
		toColor(beamCol) -- 1468
	) -- 1468
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1471
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1472
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1473
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1474
	local embrasure = 24 * s -- 1475
	fillVGradRect( -- 1477
		uiDraw, -- 1477
		wx, -- 1477
		wy, -- 1477
		ww, -- 1477
		wh, -- 1477
		Color(34, 44, 62, 255), -- 1477
		Color(16, 24, 40, 255) -- 1477
	) -- 1477
	uiArt:tryPlace( -- 1479
		"bgFar_tower", -- 1479
		"fe05_f03_window_view", -- 1479
		wx + ww * 0.5, -- 1479
		wy, -- 1479
		ww, -- 1479
		wh, -- 1479
		{ -- 1479
			color = Color( -- 1480
				math.floor(138 + 68 * lampProg + 0.5), -- 1481
				math.floor(150 + 52 * lampProg + 0.5), -- 1482
				math.floor(178 + 26 * lampProg + 0.5), -- 1483
				255 -- 1484
			), -- 1484
			opacity = 0.84, -- 1486
			layer = 0 -- 1487
		} -- 1487
	) -- 1487
	if lampProg > 0.12 then -- 1490
		fillRadialGlow( -- 1491
			uiGlow, -- 1492
			wx + ww * 0.5, -- 1492
			wy + 26 * s, -- 1492
			ww * 0.65, -- 1493
			wh * 0.55, -- 1493
			Color( -- 1494
				248, -- 1494
				206, -- 1494
				134, -- 1494
				math.floor(92 * lampProg + 0.5) -- 1494
			), -- 1494
			Color(232, 174, 88, 0), -- 1495
			16 -- 1496
		) -- 1496
	end -- 1496
	local leftWall = shadeSurface( -- 1501
		MING_MATERIALS.mingBrick.base, -- 1501
		vec3(0.84, 0.22, -0.49), -- 1501
		10, -- 1501
		1, -- 1501
		light, -- 1501
		MING_MATERIALS.mingBrick -- 1501
	) -- 1501
	local rightWall = shadeSurface( -- 1502
		MING_MATERIALS.mingBrick.base, -- 1502
		vec3(-0.84, 0.22, -0.49), -- 1502
		10, -- 1502
		1, -- 1502
		light, -- 1502
		MING_MATERIALS.mingBrick -- 1502
	) -- 1502
	local sillCol = shadeSurface( -- 1503
		MING_MATERIALS.mingStoneStep.base, -- 1503
		vec3(0, 0.94, -0.34), -- 1503
		6, -- 1503
		1, -- 1503
		light, -- 1503
		MING_MATERIALS.mingStoneStep -- 1503
	) -- 1503
	uiDraw:drawPolygon( -- 1504
		{ -- 1504
			Vec2(wx - embrasure, wy - 12 * s), -- 1505
			Vec2(wx, wy), -- 1506
			Vec2(wx, wy + wh), -- 1507
			Vec2(wx - embrasure, wy + wh + 14 * s) -- 1508
		}, -- 1508
		toColor(leftWall) -- 1509
	) -- 1509
	uiDraw:drawPolygon( -- 1510
		{ -- 1510
			Vec2(wx + ww, wy), -- 1511
			Vec2(wx + ww + embrasure, wy - 12 * s), -- 1512
			Vec2(wx + ww + embrasure, wy + wh + 14 * s), -- 1513
			Vec2(wx + ww, wy + wh) -- 1514
		}, -- 1514
		toColor(rightWall) -- 1515
	) -- 1515
	uiDraw:drawPolygon( -- 1517
		{ -- 1517
			Vec2(wx - embrasure - 10 * s, wy - 16 * s), -- 1518
			Vec2(wx + ww + embrasure + 10 * s, wy - 16 * s), -- 1519
			Vec2(wx + ww + 4 * s, wy + 10 * s), -- 1520
			Vec2(wx - 4 * s, wy + 10 * s) -- 1521
		}, -- 1521
		toColor(sillCol), -- 1522
		1, -- 1522
		toColor(STONE_EDGE_FALLBACK, 110) -- 1522
	) -- 1522
	local bar = 1 -- 1525
	do -- 1525
		bar = 1 -- 1526
		while bar <= 3 do -- 1526
			local bx = wx + ww * bar / 4 -- 1527
			uiInkDraw:drawSegment( -- 1528
				Vec2(bx, wy + 6 * s), -- 1528
				Vec2(bx, wy + wh - 2 * s), -- 1528
				3 * s, -- 1528
				Color(46, 34, 26, 238) -- 1528
			) -- 1528
			bar = bar + 1 -- 1526
		end -- 1526
	end -- 1526
	uiInkDraw:drawSegment( -- 1530
		Vec2(wx, wy + wh * 0.56), -- 1530
		Vec2(wx + ww, wy + wh * 0.56), -- 1530
		3.2 * s, -- 1530
		Color(46, 34, 26, 238) -- 1530
	) -- 1530
	uiInkDraw:drawRect( -- 1531
		Rect(wx, wy, ww, wh), -- 1531
		Color(0, 0, 0, 0), -- 1531
		2.4 * s, -- 1531
		Color(66, 50, 38, 242) -- 1531
	) -- 1531
	if lampProg > 0.02 then -- 1534
		fillRadialGlow( -- 1535
			uiGlow, -- 1536
			wx + ww * 0.5, -- 1536
			wy + 34 * s, -- 1536
			540 * s, -- 1537
			390 * s, -- 1537
			Color( -- 1538
				246, -- 1538
				198, -- 1538
				122, -- 1538
				math.floor(74 * lampProg + 0.5) -- 1538
			), -- 1538
			Color(216, 154, 72, 0), -- 1539
			20 -- 1540
		) -- 1540
	end -- 1540
end -- 1439
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1545
	fillVGradRect( -- 1556
		uiDraw, -- 1557
		0, -- 1557
		0, -- 1557
		ctx.uiW, -- 1557
		ctx.uiH, -- 1557
		Color(26, 21, 20, 255), -- 1558
		Color(46, 36, 30, 255) -- 1559
	) -- 1559
	local r = 0 -- 1561
	do -- 1561
		r = 0 -- 1562
		while r < 9 do -- 1562
			local y = oy + (280 + r * 44) * s -- 1563
			uiDraw:drawSegment( -- 1564
				Vec2(0, y), -- 1564
				Vec2(ctx.uiW, y), -- 1564
				1, -- 1564
				Color(34, 27, 24, 150) -- 1564
			) -- 1564
			r = r + 1 -- 1562
		end -- 1562
	end -- 1562
	do -- 1562
		local p = 1 -- 1566
		while p < 12 do -- 1566
			local px = ctx.uiW * p / 12 -- 1567
			uiDraw:drawSegment( -- 1568
				Vec2(px, oy + 260 * s), -- 1568
				Vec2(px, ctx.uiH), -- 1568
				0.9, -- 1568
				Color(24, 18, 15, 92) -- 1568
			) -- 1568
			p = p + 1 -- 1566
		end -- 1566
	end -- 1566
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1572
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1573
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1574
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1575
	fillVGradRect( -- 1576
		uiDraw, -- 1576
		wx, -- 1576
		wy, -- 1576
		ww, -- 1576
		wh, -- 1576
		Color(56, 62, 74, 255), -- 1576
		Color(26, 34, 50, 255) -- 1576
	) -- 1576
	uiArt:tryPlace( -- 1577
		"bgFar_tower", -- 1577
		"fe05_m03_window_view", -- 1577
		wx + ww * 0.5, -- 1577
		wy, -- 1577
		ww, -- 1577
		wh, -- 1577
		{ -- 1577
			color = Color(224, 198, 168, 255), -- 1578
			opacity = 0.88, -- 1579
			layer = 0 -- 1580
		} -- 1580
	) -- 1580
	uiDraw:drawRect( -- 1582
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1582
		Color(92, 68, 48, 255), -- 1582
		1, -- 1582
		Color(148, 114, 82, 160) -- 1582
	) -- 1582
	local bar = 1 -- 1583
	do -- 1583
		bar = 1 -- 1584
		while bar <= 3 do -- 1584
			local bx = wx + ww * bar / 4 -- 1585
			uiInkDraw:drawSegment( -- 1586
				Vec2(bx, wy + 4 * s), -- 1586
				Vec2(bx, wy + wh - 2 * s), -- 1586
				3.2 * s, -- 1586
				Color(64, 46, 34, 245) -- 1586
			) -- 1586
			bar = bar + 1 -- 1584
		end -- 1584
	end -- 1584
	uiInkDraw:drawSegment( -- 1588
		Vec2(wx, wy + wh * 0.56), -- 1588
		Vec2(wx + ww, wy + wh * 0.56), -- 1588
		3.2 * s, -- 1588
		Color(64, 46, 34, 245) -- 1588
	) -- 1588
	uiInkDraw:drawRect( -- 1589
		Rect(wx, wy, ww, wh), -- 1589
		Color(0, 0, 0, 0), -- 1589
		2.8 * s, -- 1589
		Color(88, 64, 44, 245) -- 1589
	) -- 1589
	local groupX = ox + 216 * s -- 1592
	local groupY = oy + 276 * s -- 1593
	uiArt:tryPlace( -- 1594
		"soldier_idle", -- 1594
		"fe05_m03_room_soldier", -- 1594
		groupX - 36 * s, -- 1594
		groupY, -- 1594
		108 * s, -- 1594
		152 * s, -- 1594
		{ -- 1594
			facing = 1, -- 1595
			color = Color(224, 202, 174, 255), -- 1596
			opacity = 0.78, -- 1597
			layer = 1 -- 1598
		} -- 1598
	) -- 1598
	uiArt:tryPlace( -- 1600
		"child_idle", -- 1600
		"fe05_m03_room_child", -- 1600
		groupX + 34 * s, -- 1600
		groupY, -- 1600
		78 * s, -- 1600
		106 * s, -- 1600
		{ -- 1600
			facing = 1, -- 1601
			color = Color(236, 214, 188, 255), -- 1602
			opacity = 0.84, -- 1603
			layer = 1 -- 1604
		} -- 1604
	) -- 1604
	fillRadialGlow( -- 1608
		uiGlow, -- 1609
		ox + 260 * s, -- 1609
		oy + 416 * s, -- 1609
		520 * s, -- 1610
		360 * s, -- 1610
		Color(246, 202, 134, 72), -- 1611
		Color(220, 158, 76, 0), -- 1612
		20 -- 1613
	) -- 1613
end -- 1545
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1617
	local t = self.seqElapsed -- 1630
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1631
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1632
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1633
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1634
	local midX = bx + bw * 0.5 -- 1635
	local midY = by + bh * 0.5 -- 1636
	uiDraw:drawRect( -- 1639
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1639
		Color( -- 1639
			10, -- 1639
			11, -- 1639
			16, -- 1639
			math.floor(108 * reveal + 0.5) -- 1639
		) -- 1639
	) -- 1639
	uiDraw:drawRect( -- 1640
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1640
		Color( -- 1640
			32, -- 1640
			46, -- 1640
			62, -- 1640
			math.floor(235 * reveal + 0.5) -- 1640
		), -- 1640
		1, -- 1640
		Color( -- 1640
			86, -- 1640
			104, -- 1640
			124, -- 1640
			math.floor(165 * reveal + 0.5) -- 1640
		) -- 1640
	) -- 1640
	if not uiArt:tryPlace( -- 1643
		"ink_song_paper", -- 1643
		"fe05_registry_paper", -- 1643
		midX, -- 1643
		midY, -- 1643
		bw, -- 1643
		bh, -- 1643
		{opacity = 0.98 * reveal, layer = 1} -- 1643
	) then -- 1643
		uiDraw:drawRect( -- 1644
			Rect(bx, by, bw, bh), -- 1645
			toColor( -- 1646
				PALETTE.xuanPaper, -- 1646
				math.floor(248 * reveal + 0.5) -- 1646
			), -- 1646
			1, -- 1647
			toColor( -- 1648
				PALETTE.silkDim, -- 1648
				math.floor(180 * reveal + 0.5) -- 1648
			) -- 1648
		) -- 1648
	end -- 1648
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1653
	fillRadialGlow( -- 1654
		uiGlow, -- 1655
		bx + bw * 0.34, -- 1655
		by + bh * 0.48, -- 1655
		bw * 0.58, -- 1656
		bh * 0.52, -- 1656
		Color( -- 1657
			246, -- 1657
			214, -- 1657
			156, -- 1657
			math.floor(44 * paperWarm * reveal + 0.5) -- 1657
		), -- 1657
		Color(238, 198, 128, 0), -- 1658
		16 -- 1659
	) -- 1659
	local padX = 44 * s -- 1663
	local padY = 32 * s -- 1664
	local inX = bx + padX -- 1665
	local inY = by + padY -- 1666
	local inW = bw - padX * 2 -- 1667
	local inH = bh - padY * 2 -- 1668
	local redSilk = toColor( -- 1669
		PALETTE.rouge, -- 1669
		math.floor(132 * reveal + 0.5) -- 1669
	) -- 1669
	local redFaint = toColor( -- 1670
		PALETTE.rouge, -- 1670
		math.floor(70 * reveal + 0.5) -- 1670
	) -- 1670
	uiInkDraw:drawRect( -- 1671
		Rect(inX, inY, inW, inH), -- 1671
		Color(0, 0, 0, 0), -- 1671
		1, -- 1671
		redSilk -- 1671
	) -- 1671
	uiInkDraw:drawRect( -- 1672
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1672
		Color(0, 0, 0, 0), -- 1672
		0.6, -- 1672
		redFaint -- 1672
	) -- 1672
	local headY = inY + inH - 28 * s -- 1675
	ctx.texts:put( -- 1676
		"md", -- 1676
		"北塔值夜收籍 · 末页", -- 1676
		inX + 18 * s, -- 1676
		headY, -- 1676
		toColor(PALETTE.xuanInk), -- 1676
		0, -- 1676
		0.5, -- 1676
		"Left", -- 1676
		2.2, -- 1676
		0.96 * reveal, -- 1676
		0 -- 1676
	) -- 1676
	ctx.texts:put( -- 1677
		"xs", -- 1677
		"宁村北塔", -- 1677
		inX + inW - 18 * s, -- 1677
		headY, -- 1677
		toColor(PALETTE.xuanInkSub), -- 1677
		1, -- 1677
		0.5, -- 1677
		"Right", -- 1677
		1.8, -- 1677
		0.8 * reveal, -- 1677
		0 -- 1677
	) -- 1677
	uiInkDraw:drawSegment( -- 1678
		Vec2(inX + 14 * s, headY - 22 * s), -- 1678
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1678
		0.9, -- 1678
		redSilk -- 1678
	) -- 1678
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1681
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1682
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1683
	ctx.texts:put( -- 1684
		"sm", -- 1684
		"肆拾壹", -- 1684
		inX + 18 * s, -- 1684
		row1Y, -- 1684
		toColor(PALETTE.rouge), -- 1684
		0, -- 1684
		0.5, -- 1684
		"Left", -- 1684
		1, -- 1684
		0.94 * reveal, -- 1684
		0 -- 1684
	) -- 1684
	if r1Prog > 0.02 then -- 1685
		ctx.texts:put( -- 1686
			"md", -- 1686
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1686
			inX + 96 * s, -- 1686
			row1Y, -- 1686
			toColor(PALETTE.xuanInk), -- 1686
			0, -- 1686
			0.5, -- 1686
			"Left", -- 1686
			1.6, -- 1686
			0.96 * math.min(1, r1Prog * 1.4), -- 1686
			0 -- 1686
		) -- 1686
	end -- 1686
	if r1Prog > 0.65 then -- 1688
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1689
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1690
		ctx.texts:put( -- 1693
			"xs", -- 1693
			subText, -- 1693
			inX + 96 * s, -- 1693
			row1SubY, -- 1693
			toColor(PALETTE.xuanInkSub), -- 1693
			0, -- 1693
			0.5, -- 1693
			"Left", -- 1693
			0.6, -- 1693
			0.88 * subA, -- 1693
			0 -- 1693
		) -- 1693
	end -- 1693
	uiInkDraw:drawSegment( -- 1695
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1695
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1695
		0.7, -- 1695
		redFaint -- 1695
	) -- 1695
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1698
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1699
	ctx.texts:put( -- 1700
		"sm", -- 1700
		"肆拾贰", -- 1700
		inX + 18 * s, -- 1700
		row2Y, -- 1700
		toColor(PALETTE.rouge), -- 1700
		0, -- 1700
		0.5, -- 1700
		"Left", -- 1700
		1, -- 1700
		0.94 * reveal, -- 1700
		0 -- 1700
	) -- 1700
	if route == "child" then -- 1702
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1704
		uiInkDraw:drawSegment( -- 1705
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1706
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1707
			1, -- 1708
			toColor(PALETTE.xuanInkSub, lineA) -- 1709
		) -- 1709
	else -- 1709
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1713
		if r2Prog <= 0.02 then -- 1714
			uiInkDraw:drawSegment( -- 1715
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1716
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1717
				0.9, -- 1718
				toColor( -- 1719
					PALETTE.xuanInkSub, -- 1719
					math.floor(105 * reveal + 0.5) -- 1719
				) -- 1719
			) -- 1719
		else -- 1719
			ctx.texts:put( -- 1722
				"md", -- 1722
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1722
				inX + 96 * s, -- 1722
				row2Y, -- 1722
				toColor(PALETTE.xuanInk), -- 1722
				0, -- 1722
				0.5, -- 1722
				"Left", -- 1722
				1.6, -- 1722
				0.96 * math.min(1, r2Prog * 1.4), -- 1722
				0 -- 1722
			) -- 1722
			if r2Prog > 0.65 then -- 1723
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1724
				ctx.texts:put( -- 1725
					"xs", -- 1725
					"守城戍卒亲口报出姓名，两人俱安。", -- 1725
					inX + 96 * s, -- 1725
					row2SubY, -- 1725
					toColor(PALETTE.xuanInkSub), -- 1725
					0, -- 1725
					0.5, -- 1725
					"Left", -- 1725
					0.6, -- 1725
					0.88 * subA, -- 1725
					0 -- 1725
				) -- 1725
			end -- 1725
		end -- 1725
	end -- 1725
	uiInkDraw:drawSegment( -- 1729
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1729
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1729
		0.7, -- 1729
		redFaint -- 1729
	) -- 1729
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1732
	if colophonA > 0.02 then -- 1733
		local signY = inY + 34 * s -- 1734
		ctx.texts:put( -- 1735
			"banner", -- 1735
			"向西守望", -- 1735
			midX - 24 * s, -- 1735
			signY, -- 1735
			toColor(PALETTE.xuanInk), -- 1735
			0.5, -- 1735
			0.5, -- 1735
			"Center", -- 1735
			6, -- 1735
			0.88 * colophonA, -- 1735
			0 -- 1735
		) -- 1735
	end -- 1735
	self:drawGuardBrushHand( -- 1739
		uiInkDraw, -- 1739
		route, -- 1739
		s, -- 1739
		ox, -- 1739
		oy -- 1739
	) -- 1739
end -- 1617
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, route, s, ox, oy) -- 1742
	local t = self.seqElapsed -- 1749
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1750
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1751
	local row1X0 = hoverX -- 1752
	local row1X1 = hoverX + 142 * s -- 1753
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1754
	local tipX = hoverX -- 1756
	local tipY = hoverY -- 1757
	local alpha = 0 -- 1758
	local lifted = 0 -- 1759
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1761
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1763
		tipX = lerp(row1X0, row1X1, k) -- 1764
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1765
		alpha = smoothstep(2, 2.2, t) -- 1766
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1767
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1768
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1770
		tipX = lerp(row1X1, hoverX, moveK) -- 1771
		tipY = lerp(row1Y, hoverY, moveK) -- 1772
		alpha = 1 -- 1773
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1774
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1775
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1777
		tipX = hoverX + outK * 140 * s -- 1778
		tipY = hoverY + outK * 46 * s -- 1779
		lifted = (9 + outK * 28) * s -- 1780
		alpha = 1 - outK -- 1781
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1782
		if t < 4.6 then -- 1784
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1785
			tipX = hoverX -- 1786
			tipY = hoverY -- 1787
			lifted = lerp(9 * s, 0, dipK) -- 1788
			alpha = 1 -- 1789
		elseif t < 5.55 then -- 1790
			local wK = smoothstep(4.6, 5.55, t) -- 1791
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1792
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1793
			lifted = 0 -- 1794
			alpha = 1 -- 1795
		else -- 1795
			local outK = smoothstep(5.55, 6.05, t) -- 1797
			tipX = hoverX + 216 * s + outK * 115 * s -- 1798
			tipY = hoverY + outK * 52 * s -- 1799
			lifted = outK * 24 * s -- 1800
			alpha = 1 - outK -- 1801
		end -- 1801
	end -- 1801
	if alpha <= 0.02 then -- 1805
		return -- 1806
	end -- 1806
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1809
	local bx = tipX -- 1810
	local by = tipY + lifted -- 1811
	uiInkDraw:drawEllipse( -- 1813
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1813
		(5 + lifted * 0.22) * s, -- 1813
		2.8 * s, -- 1813
		Color( -- 1813
			20, -- 1813
			18, -- 1813
			16, -- 1813
			math.floor(78 * alpha + 0.5) -- 1813
		) -- 1813
	) -- 1813
	uiInkDraw:drawPolygon( -- 1815
		{ -- 1815
			Vec2(bx, by), -- 1816
			Vec2(bx + 15 * s, by - 4 * s), -- 1817
			Vec2(bx + 10 * s, by + 8 * s) -- 1818
		}, -- 1818
		Color(22, 22, 26, a) -- 1819
	) -- 1819
	uiInkDraw:drawSegment( -- 1821
		Vec2(bx + 12 * s, by + 2 * s), -- 1821
		Vec2(bx + 24 * s, by + 6 * s), -- 1821
		7.8 * s, -- 1821
		Color(164, 138, 92, a) -- 1821
	) -- 1821
	uiInkDraw:drawSegment( -- 1822
		Vec2(bx + 22 * s, by + 5 * s), -- 1822
		Vec2(bx + 122 * s, by + 34 * s), -- 1822
		6.8 * s, -- 1822
		Color(142, 110, 74, a) -- 1822
	) -- 1822
	uiInkDraw:drawSegment( -- 1823
		Vec2(bx + 22 * s, by + 5 * s), -- 1823
		Vec2(bx + 122 * s, by + 34 * s), -- 1823
		1.8 * s, -- 1823
		Color( -- 1823
			196, -- 1823
			164, -- 1823
			118, -- 1823
			math.floor(185 * alpha + 0.5) -- 1823
		) -- 1823
	) -- 1823
	uiInkDraw:drawPolygon( -- 1825
		{ -- 1825
			Vec2(bx + 44 * s, by - 6 * s), -- 1826
			Vec2(bx + 102 * s, by - 14 * s), -- 1827
			Vec2(bx + 110 * s, by + 18 * s), -- 1828
			Vec2(bx + 54 * s, by + 22 * s) -- 1829
		}, -- 1829
		Color(188, 154, 126, a), -- 1830
		1, -- 1830
		Color(128, 98, 76, a) -- 1830
	) -- 1830
	uiInkDraw:drawSegment( -- 1831
		Vec2(bx + 46 * s, by + 16 * s), -- 1831
		Vec2(bx + 76 * s, by + 20 * s), -- 1831
		5.2 * s, -- 1831
		Color(204, 170, 140, a) -- 1831
	) -- 1831
	uiInkDraw:drawSegment( -- 1832
		Vec2(bx + 48 * s, by + 2 * s), -- 1832
		Vec2(bx + 82 * s, by + 4 * s), -- 1832
		4.8 * s, -- 1832
		Color(180, 146, 118, a) -- 1832
	) -- 1832
	uiInkDraw:drawPolygon( -- 1833
		{ -- 1833
			Vec2(bx + 98 * s, by - 14 * s), -- 1834
			Vec2(bx + 224 * s, by - 32 * s), -- 1835
			Vec2(bx + 230 * s, by + 18 * s), -- 1836
			Vec2(bx + 104 * s, by + 20 * s) -- 1837
		}, -- 1837
		Color(54, 48, 44, a), -- 1838
		1.2, -- 1838
		Color(94, 84, 72, a) -- 1838
	) -- 1838
end -- 1742
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1841
	local t = self.seqElapsed -- 1852
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1853
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1854
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1855
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1856
	if route == "child" then -- 1858
		local propA = smoothstep(1.55, 2.05, t) -- 1860
		if propA > 0.02 then -- 1861
			self:drawNeedleCaseOnDesk( -- 1862
				uiInkDraw, -- 1862
				ncX, -- 1862
				ncY, -- 1862
				s, -- 1862
				propA, -- 1862
				true -- 1862
			) -- 1862
		end -- 1862
		local noteReadA = smoothstep(1.65, 2.1, t) * (1 - smoothstep(3.65, 4.15, t)) -- 1864
		if noteReadA > 0.02 then -- 1865
			local cardX = ncX + 18 * s -- 1866
			local cardY = ncY + 84 * s -- 1867
			uiInkDraw:drawRect( -- 1868
				Rect(cardX - 118 * s, cardY - 30 * s, 236 * s, 60 * s), -- 1869
				toColor( -- 1870
					PALETTE.xuanPaper, -- 1870
					math.floor(238 * noteReadA + 0.5) -- 1870
				), -- 1870
				1, -- 1871
				toColor( -- 1872
					PALETTE.rouge, -- 1872
					math.floor(110 * noteReadA + 0.5) -- 1872
				) -- 1872
			) -- 1872
			ctx.texts:put( -- 1874
				"xs", -- 1874
				NEEDLE_NOTE_LINES[1], -- 1874
				cardX, -- 1874
				cardY + 10 * s, -- 1874
				toColor(PALETTE.xuanInk), -- 1874
				0.5, -- 1874
				0.5, -- 1874
				"Center", -- 1874
				0.6, -- 1874
				0.94 * noteReadA, -- 1874
				0 -- 1874
			) -- 1874
			ctx.texts:put( -- 1875
				"xs", -- 1875
				"—— " .. NEEDLE_NOTE_LINES[2], -- 1875
				cardX + 74 * s, -- 1875
				cardY - 12 * s, -- 1875
				toColor(PALETTE.xuanInkSub), -- 1875
				1, -- 1875
				0.5, -- 1875
				"Right", -- 1875
				0.8, -- 1875
				0.88 * noteReadA, -- 1875
				0 -- 1875
			) -- 1875
		end -- 1875
		local bowlK = smoothstep(4.35, 5.15, t) -- 1878
		if bowlK > 0.02 then -- 1879
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1880
			self:drawWarmPorcelainBowl( -- 1881
				uiInkDraw, -- 1881
				uiGlow, -- 1881
				bx, -- 1881
				bowlY, -- 1881
				s, -- 1881
				bowlK, -- 1881
				false, -- 1881
				0 -- 1881
			) -- 1881
		end -- 1881
	else -- 1881
		local needleK = smoothstep(5.45, 6.15, t) -- 1885
		if needleK > 0.02 then -- 1886
			local ny = lerp(ncY + 46 * s, ncY, needleK) -- 1887
			self:drawNeedleCaseOnDesk( -- 1888
				uiInkDraw, -- 1888
				ncX + 74 * s, -- 1888
				ny, -- 1888
				s, -- 1888
				needleK, -- 1888
				false -- 1888
			) -- 1888
		end -- 1888
		local bowlK = smoothstep(5.8, 6.65, t) -- 1891
		if bowlK > 0.02 then -- 1892
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1893
			local handsK = smoothstep(5.95, 6.75, t) -- 1894
			local placedBowl = uiArt:tryPlace( -- 1895
				"sh_ending_bowl_hands", -- 1896
				"fe05_m03_bowl_hands_art", -- 1897
				bowlX, -- 1898
				by + 28 * s, -- 1899
				220 * s, -- 1900
				184 * s, -- 1901
				{opacity = bowlK * (0.45 + 0.55 * handsK), layer = 5} -- 1902
			) -- 1902
			if placedBowl then -- 1904
				uiDraw:drawEllipse( -- 1906
					Vec2(bowlX, by - 36 * s), -- 1906
					64 * s, -- 1906
					14 * s, -- 1906
					Color( -- 1906
						8, -- 1906
						9, -- 1906
						14, -- 1906
						math.floor(135 * bowlK + 0.5) -- 1906
					) -- 1906
				) -- 1906
				fillRadialGlow( -- 1907
					uiGlow, -- 1907
					bowlX, -- 1907
					by + 16 * s, -- 1907
					90 * s, -- 1907
					54 * s, -- 1907
					Color( -- 1908
						248, -- 1908
						214, -- 1908
						152, -- 1908
						math.floor(44 * bowlK + 0.5) -- 1908
					), -- 1908
					Color(248, 214, 152, 0), -- 1908
					14 -- 1908
				) -- 1908
			else -- 1908
				self:drawWarmPorcelainBowl( -- 1910
					uiInkDraw, -- 1910
					uiGlow, -- 1910
					bowlX, -- 1910
					by, -- 1910
					s, -- 1910
					bowlK, -- 1910
					true, -- 1910
					handsK -- 1910
				) -- 1910
			end -- 1910
		end -- 1910
		local cuffK = smoothstep(4.25, 4.85, t) -- 1914
		if cuffK > 0.02 then -- 1915
			local placedCuff = uiArt:tryPlace( -- 1916
				"sh_ending_cuff_hand", -- 1917
				"fe05_m03_cuff_art", -- 1918
				ox + 142 * s, -- 1919
				oy + 178 * s, -- 1920
				254 * s, -- 1921
				136 * s, -- 1922
				{opacity = 0.94 * cuffK, layer = 5} -- 1923
			) -- 1923
			if not placedCuff then -- 1925
				drawPatchedCuff(uiInkDraw, uiGlow, { -- 1926
					wristX = ox + 122 * s, -- 1927
					wristY = oy + 182 * s, -- 1928
					angleRad = 0.08, -- 1929
					scale = 0.6 * s, -- 1930
					pose = "open", -- 1931
					opacity = 0.92 * cuffK, -- 1932
					stitchHighlight = 0.34, -- 1933
					warmth = 0.72 -- 1934
				}) -- 1934
			end -- 1934
		end -- 1934
	end -- 1934
end -- 1841
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, draw, cx, cy, s, alpha, withNote) -- 1942
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1950
	draw:drawEllipse( -- 1952
		Vec2(cx + 4 * s, cy - 12 * s), -- 1952
		44 * s, -- 1952
		14 * s, -- 1952
		Color( -- 1952
			10, -- 1952
			10, -- 1952
			14, -- 1952
			math.floor(140 * alpha + 0.5) -- 1952
		) -- 1952
	) -- 1952
	draw:drawPolygon( -- 1954
		{ -- 1954
			Vec2(cx - 32 * s, cy - 12 * s), -- 1955
			Vec2(cx + 26 * s, cy - 15 * s), -- 1956
			Vec2(cx + 30 * s, cy + 16 * s), -- 1957
			Vec2(cx - 28 * s, cy + 18 * s) -- 1958
		}, -- 1958
		Color(148, 124, 92, a), -- 1959
		1.3, -- 1959
		Color(88, 70, 50, a) -- 1959
	) -- 1959
	draw:drawEllipse( -- 1961
		Vec2(cx + 18 * s, cy + 2 * s), -- 1961
		13 * s, -- 1961
		13 * s, -- 1961
		Color(188, 152, 86, a) -- 1961
	) -- 1961
	strokeEllipse( -- 1962
		draw, -- 1962
		cx + 18 * s, -- 1962
		cy + 2 * s, -- 1962
		13 * s, -- 1962
		13 * s, -- 1962
		1.5 * s, -- 1962
		Color(118, 92, 46, a), -- 1962
		18 -- 1962
	) -- 1962
	draw:drawDot( -- 1963
		Vec2(cx + 18 * s, cy + 2 * s), -- 1963
		2.5 * s, -- 1963
		Color(72, 54, 28, a) -- 1963
	) -- 1963
	draw:drawSegment( -- 1964
		Vec2(cx + 12 * s, cy - 2 * s), -- 1964
		Vec2(cx + 24 * s, cy + 6 * s), -- 1964
		1.5 * s, -- 1964
		Color(164, 48, 44, a) -- 1964
	) -- 1964
	draw:drawSegment( -- 1966
		Vec2(cx - 28 * s, cy + 4 * s), -- 1966
		Vec2(cx - 56 * s, cy - 8 * s), -- 1966
		2.4 * s, -- 1966
		toColor(CUFF_PALETTE.childCord, a) -- 1966
	) -- 1966
	draw:drawSegment( -- 1967
		Vec2(cx - 56 * s, cy - 8 * s), -- 1967
		Vec2(cx - 72 * s, cy + 6 * s), -- 1967
		2.2 * s, -- 1967
		toColor(CUFF_PALETTE.childCord, a) -- 1967
	) -- 1967
	draw:drawSegment( -- 1968
		Vec2(cx - 72 * s, cy + 6 * s), -- 1968
		Vec2(cx - 48 * s, cy + 16 * s), -- 1968
		2 * s, -- 1968
		toColor( -- 1968
			CUFF_PALETTE.childCord, -- 1968
			math.floor(215 * alpha + 0.5) -- 1968
		) -- 1968
	) -- 1968
	if withNote then -- 1970
		draw:drawPolygon( -- 1972
			{ -- 1972
				Vec2(cx + 38 * s, cy - 18 * s), -- 1973
				Vec2(cx + 96 * s, cy - 12 * s), -- 1974
				Vec2(cx + 90 * s, cy + 24 * s), -- 1975
				Vec2(cx + 34 * s, cy + 18 * s) -- 1976
			}, -- 1976
			toColor(PALETTE.xuanPaper, a), -- 1977
			1, -- 1977
			toColor( -- 1977
				PALETTE.xuanInkSub, -- 1977
				math.floor(160 * alpha + 0.5) -- 1977
			) -- 1977
		) -- 1977
		draw:drawSegment( -- 1978
			Vec2(cx + 46 * s, cy + 8 * s), -- 1978
			Vec2(cx + 80 * s, cy + 11 * s), -- 1978
			1.2 * s, -- 1978
			toColor( -- 1978
				PALETTE.xuanInk, -- 1978
				math.floor(170 * alpha + 0.5) -- 1978
			) -- 1978
		) -- 1978
		draw:drawSegment( -- 1979
			Vec2(cx + 46 * s, cy - 2 * s), -- 1979
			Vec2(cx + 76 * s, cy + 1 * s), -- 1979
			1.2 * s, -- 1979
			toColor( -- 1979
				PALETTE.xuanInk, -- 1979
				math.floor(160 * alpha + 0.5) -- 1979
			) -- 1979
		) -- 1979
	end -- 1979
end -- 1942
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, draw, glow, cx, cy, s, alpha, heldByTwoHands, handsK) -- 1984
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1994
	draw:drawEllipse( -- 1996
		Vec2(cx, cy - 36 * s), -- 1996
		58 * s, -- 1996
		14 * s, -- 1996
		Color( -- 1996
			8, -- 1996
			9, -- 1996
			14, -- 1996
			math.floor(150 * alpha + 0.5) -- 1996
		) -- 1996
	) -- 1996
	draw:drawPolygon( -- 1998
		{ -- 1998
			Vec2(cx - 32 * s, cy - 38 * s), -- 1999
			Vec2(cx + 32 * s, cy - 38 * s), -- 2000
			Vec2(cx + 62 * s, cy + 8 * s), -- 2001
			Vec2(cx - 62 * s, cy + 8 * s) -- 2002
		}, -- 2002
		Color(168, 166, 156, a), -- 2003
		1.4, -- 2003
		Color(98, 96, 88, a) -- 2003
	) -- 2003
	draw:drawPolygon( -- 2005
		{ -- 2005
			Vec2(cx + 8 * s, cy - 36 * s), -- 2006
			Vec2(cx + 32 * s, cy - 38 * s), -- 2007
			Vec2(cx + 62 * s, cy + 8 * s), -- 2008
			Vec2(cx + 22 * s, cy + 6 * s) -- 2009
		}, -- 2009
		Color( -- 2010
			122, -- 2010
			120, -- 2010
			112, -- 2010
			math.floor(160 * alpha + 0.5) -- 2010
		) -- 2010
	) -- 2010
	draw:drawEllipse( -- 2012
		Vec2(cx, cy + 8 * s), -- 2012
		64 * s, -- 2012
		21 * s, -- 2012
		Color(224, 218, 206, a) -- 2012
	) -- 2012
	strokeEllipse( -- 2013
		draw, -- 2013
		cx, -- 2013
		cy + 8 * s, -- 2013
		64 * s, -- 2013
		21 * s, -- 2013
		1.9 * s, -- 2013
		Color(116, 110, 100, a), -- 2013
		28 -- 2013
	) -- 2013
	draw:drawEllipse( -- 2014
		Vec2(cx, cy + 6 * s), -- 2014
		54 * s, -- 2014
		15 * s, -- 2014
		Color(196, 168, 122, a) -- 2014
	) -- 2014
	strokeEllipse( -- 2015
		draw, -- 2015
		cx, -- 2015
		cy + 6 * s, -- 2015
		54 * s, -- 2015
		15 * s, -- 2015
		1.1 * s, -- 2015
		Color(158, 132, 92, a), -- 2015
		24 -- 2015
	) -- 2015
	draw:drawSegment( -- 2017
		Vec2(cx - 46 * s, cy + 16 * s), -- 2017
		Vec2(cx - 10 * s, cy + 25 * s), -- 2017
		2 * s, -- 2017
		Color( -- 2017
			248, -- 2017
			246, -- 2017
			240, -- 2017
			math.floor(215 * alpha + 0.5) -- 2017
		) -- 2017
	) -- 2017
	local wi = 0 -- 2020
	do -- 2020
		wi = 0 -- 2021
		while wi < 3 do -- 2021
			local phase = self.animTime * 1.1 + wi * 2.05 -- 2022
			local baseX = cx + (wi - 1) * 18 * s -- 2023
			local baseY = cy + 16 * s -- 2024
			local segs = 4 -- 2025
			local prevX = baseX -- 2026
			local prevY = baseY -- 2027
			local si = 1 -- 2028
			do -- 2028
				si = 1 -- 2029
				while si <= segs do -- 2029
					local frac = si / segs -- 2030
					local nx = baseX + math.sin(phase + frac * 3.1) * (6.5 * frac) * s -- 2031
					local ny = baseY + frac * (36 + wi % 2 * 10) * s -- 2032
					local wa = math.floor(46 * (1 - frac * 0.72) * alpha + 0.5) -- 2033
					glow:drawSegment( -- 2034
						Vec2(prevX, prevY), -- 2034
						Vec2(nx, ny), -- 2034
						(2.2 - frac * 0.9) * s, -- 2034
						Color(244, 238, 226, wa) -- 2034
					) -- 2034
					prevX = nx -- 2035
					prevY = ny -- 2036
					si = si + 1 -- 2029
				end -- 2029
			end -- 2029
			wi = wi + 1 -- 2021
		end -- 2021
	end -- 2021
	if heldByTwoHands and handsK > 0.02 then -- 2041
		local ha = math.floor(255 * clamp01(handsK * alpha) + 0.5) -- 2042
		local skin = toColor(CUFF_PALETTE.childSkin, ha) -- 2043
		local skinSh = toColor(CUFF_PALETTE.childSkinShadow, ha) -- 2044
		local sleeve = toColor(CUFF_PALETTE.childSleeve, ha) -- 2045
		local spread = (1 - handsK) * 28 * s -- 2046
		draw:drawPolygon( -- 2049
			{ -- 2049
				Vec2(cx - 122 * s - spread, cy - 58 * s), -- 2050
				Vec2(cx - 72 * s - spread, cy - 30 * s), -- 2051
				Vec2(cx - 82 * s - spread, cy - 4 * s), -- 2052
				Vec2(cx - 134 * s - spread, cy - 26 * s) -- 2053
			}, -- 2053
			sleeve, -- 2054
			1.1, -- 2054
			skinSh -- 2054
		) -- 2054
		draw:drawPolygon( -- 2055
			{ -- 2055
				Vec2(cx - 76 * s - spread, cy - 28 * s), -- 2056
				Vec2(cx - 48 * s - spread, cy - 18 * s), -- 2057
				Vec2(cx - 44 * s - spread, cy + 6 * s), -- 2058
				Vec2(cx - 74 * s - spread, cy + 2 * s) -- 2059
			}, -- 2059
			skin, -- 2060
			1.1, -- 2060
			skinSh -- 2060
		) -- 2060
		draw:drawSegment( -- 2061
			Vec2(cx - 56 * s - spread, cy + 2 * s), -- 2061
			Vec2(cx - 38 * s - spread, cy + 12 * s), -- 2061
			4.6 * s, -- 2061
			skin -- 2061
		) -- 2061
		draw:drawSegment( -- 2062
			Vec2(cx - 58 * s - spread, cy - 7 * s), -- 2062
			Vec2(cx - 40 * s - spread, cy - 2 * s), -- 2062
			4.4 * s, -- 2062
			skin -- 2062
		) -- 2062
		draw:drawSegment( -- 2063
			Vec2(cx - 56 * s - spread, cy - 16 * s), -- 2063
			Vec2(cx - 40 * s - spread, cy - 14 * s), -- 2063
			4.2 * s, -- 2063
			skin -- 2063
		) -- 2063
		draw:drawPolygon( -- 2066
			{ -- 2066
				Vec2(cx + 122 * s + spread, cy - 58 * s), -- 2067
				Vec2(cx + 72 * s + spread, cy - 30 * s), -- 2068
				Vec2(cx + 82 * s + spread, cy - 4 * s), -- 2069
				Vec2(cx + 134 * s + spread, cy - 26 * s) -- 2070
			}, -- 2070
			sleeve, -- 2071
			1.1, -- 2071
			skinSh -- 2071
		) -- 2071
		draw:drawPolygon( -- 2072
			{ -- 2072
				Vec2(cx + 76 * s + spread, cy - 28 * s), -- 2073
				Vec2(cx + 48 * s + spread, cy - 18 * s), -- 2074
				Vec2(cx + 44 * s + spread, cy + 6 * s), -- 2075
				Vec2(cx + 74 * s + spread, cy + 2 * s) -- 2076
			}, -- 2076
			skin, -- 2077
			1.1, -- 2077
			skinSh -- 2077
		) -- 2077
		draw:drawSegment( -- 2078
			Vec2(cx + 56 * s + spread, cy + 2 * s), -- 2078
			Vec2(cx + 38 * s + spread, cy + 12 * s), -- 2078
			4.6 * s, -- 2078
			skin -- 2078
		) -- 2078
		draw:drawSegment( -- 2079
			Vec2(cx + 58 * s + spread, cy - 7 * s), -- 2079
			Vec2(cx + 40 * s + spread, cy - 2 * s), -- 2079
			4.4 * s, -- 2079
			skin -- 2079
		) -- 2079
		draw:drawSegment( -- 2080
			Vec2(cx + 56 * s + spread, cy - 16 * s), -- 2080
			Vec2(cx + 40 * s + spread, cy - 14 * s), -- 2080
			4.2 * s, -- 2080
			skin -- 2080
		) -- 2080
	end -- 2080
end -- 1984
function TowerEndingsPlugin.prototype.drawMingLantern(self, draw, glow, cx, cy, scale, alpha, warmth) -- 2085
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 2094
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 2095
	draw:drawSegment( -- 2097
		Vec2(cx - 10 * scale, cy + 28 * scale), -- 2097
		Vec2(cx, cy + 40 * scale), -- 2097
		1.8 * scale, -- 2097
		Color(88, 86, 82, a) -- 2097
	) -- 2097
	draw:drawSegment( -- 2098
		Vec2(cx + 10 * scale, cy + 28 * scale), -- 2098
		Vec2(cx, cy + 40 * scale), -- 2098
		1.8 * scale, -- 2098
		Color(88, 86, 82, a) -- 2098
	) -- 2098
	draw:drawRect( -- 2100
		Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), -- 2100
		Color(62, 46, 34, a), -- 2100
		1, -- 2100
		Color(118, 92, 66, a) -- 2100
	) -- 2100
	draw:drawRect( -- 2101
		Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), -- 2101
		Color(62, 46, 34, a), -- 2101
		1, -- 2101
		Color(118, 92, 66, a) -- 2101
	) -- 2101
	draw:drawRect( -- 2103
		Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale), -- 2104
		Color( -- 2105
			238, -- 2105
			198, -- 2105
			132, -- 2105
			math.floor(230 * alpha * (0.75 + 0.25 * warmth) + 0.5) -- 2105
		), -- 2105
		1.4 * scale, -- 2106
		Color(94, 70, 48, a) -- 2107
	) -- 2107
	draw:drawSegment( -- 2109
		Vec2(cx, cy - 18 * scale), -- 2109
		Vec2(cx, cy + 22 * scale), -- 2109
		1.1 * scale, -- 2109
		Color( -- 2109
			94, -- 2109
			70, -- 2109
			48, -- 2109
			math.floor(150 * alpha + 0.5) -- 2109
		) -- 2109
	) -- 2109
	draw:drawEllipse( -- 2110
		Vec2(cx, cy + 2 * scale), -- 2110
		4.6 * scale * flicker, -- 2110
		8.5 * scale * flicker, -- 2110
		Color(255, 244, 212, a) -- 2110
	) -- 2110
	fillRadialGlow( -- 2112
		glow, -- 2113
		cx, -- 2113
		cy + 2 * scale, -- 2113
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2114
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2115
		Color( -- 2116
			250, -- 2116
			208, -- 2116
			132, -- 2116
			math.floor(128 * alpha * warmth + 0.5) -- 2116
		), -- 2116
		Color(228, 162, 74, 0), -- 2117
		16 -- 2118
	) -- 2118
end -- 2085
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 2122
	local line = self.lastSubtitle -- 2131
	if line ~= "" then -- 2132
		local cy = barH + 34 * s -- 2133
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 2134
		drawSilkVeil( -- 2135
			uiDraw, -- 2135
			uiArt, -- 2135
			"fe05_sub_veil", -- 2135
			ctx.uiW * 0.5, -- 2135
			cy, -- 2135
			stripW, -- 2135
			48 * s, -- 2135
			PALETTE.inkWash, -- 2135
			0.82, -- 2135
			3 -- 2135
		) -- 2135
		drawHairline( -- 2136
			uiInkDraw, -- 2136
			uiArt, -- 2136
			"fe05_sub_hair", -- 2136
			ctx.uiW * 0.5, -- 2136
			cy + 21 * s, -- 2136
			stripW * 0.68, -- 2136
			PALETTE.silkDim, -- 2136
			0.54, -- 2136
			true, -- 2136
			4 -- 2136
		) -- 2136
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 2137
		ctx.texts:put( -- 2138
			isSpoken and "md" or "sm", -- 2139
			line, -- 2140
			ctx.uiW * 0.5, -- 2141
			cy - 1 * s, -- 2142
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 2143
			0.5, -- 2144
			0.5, -- 2145
			"Center", -- 2146
			isSpoken and 1.8 or 1, -- 2147
			0.98, -- 2148
			0.08 -- 2149
		) -- 2149
	end -- 2149
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 2154
		local rawHint = route == "child" and "按 E 收页 · 尾声与史话   ·   Esc 暂歇" or "团圆尾声   ·   按 E 收页与史话   ·   Esc 暂歇" -- 2155
		local hint = adaptHintSentence(rawHint, ctx.input.inputMode, ctx.input.gamepadLayout) -- 2158
		ctx.texts:put( -- 2159
			"xs", -- 2159
			hint, -- 2159
			ctx.uiW * 0.5, -- 2159
			barH * 0.5, -- 2159
			toColor(PALETTE.textMid), -- 2159
			0.5, -- 2159
			0.5, -- 2159
			"Center", -- 2159
			1.4, -- 2159
			0.88, -- 2159
			0.08 -- 2159
		) -- 2159
	end -- 2159
end -- 2122
function ____exports.createTowerEndingsPlugin() -- 2164
	return __TS__New(____exports.TowerEndingsPlugin) -- 2165
end -- 2164
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 2169
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 2170
	fe:registerPlugin(plugin) -- 2171
	return plugin -- 2172
end -- 2169
return ____exports -- 2169
