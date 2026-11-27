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
		uiGlow, -- 1436
		ctx, -- 1436
		route, -- 1436
		s, -- 1436
		ox, -- 1436
		oy -- 1436
	) -- 1436
end -- 1338
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiGlow, ctx, lampProg, s, ox, oy) -- 1439
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1448
	local wallTop = lerpRGBA( -- 1449
		rgba(18, 24, 38, 255), -- 1449
		rgba(46, 36, 28, 255), -- 1449
		lampProg -- 1449
	) -- 1449
	local wallBot = lerpRGBA( -- 1450
		rgba(12, 16, 26, 255), -- 1450
		rgba(28, 22, 20, 255), -- 1450
		lampProg -- 1450
	) -- 1450
	fillVGradRect( -- 1451
		uiDraw, -- 1451
		0, -- 1451
		0, -- 1451
		ctx.uiW, -- 1451
		ctx.uiH, -- 1451
		toColor(wallBot), -- 1451
		toColor(wallTop) -- 1451
	) -- 1451
	local beamCol = shadeSurface( -- 1454
		MING_MATERIALS.mingTimberDark.base, -- 1454
		vec3(-0.3, -0.6, -0.74), -- 1454
		18, -- 1454
		1, -- 1454
		light, -- 1454
		MING_MATERIALS.mingTimberDark -- 1454
	) -- 1454
	uiDraw:drawPolygon( -- 1455
		{ -- 1455
			Vec2(0, ctx.uiH - 96 * s), -- 1456
			Vec2(ctx.uiW, ctx.uiH - 72 * s), -- 1457
			Vec2(ctx.uiW, ctx.uiH - 42 * s), -- 1458
			Vec2(0, ctx.uiH - 42 * s) -- 1459
		}, -- 1459
		toColor(beamCol) -- 1460
	) -- 1460
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1463
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1464
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1465
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1466
	local embrasure = 24 * s -- 1467
	fillVGradRect( -- 1470
		uiDraw, -- 1470
		wx, -- 1470
		wy, -- 1470
		ww, -- 1470
		wh, -- 1470
		Color(34, 44, 62, 255), -- 1470
		Color(16, 24, 40, 255) -- 1470
	) -- 1470
	uiDraw:drawPolygon( -- 1471
		{ -- 1471
			Vec2(wx, wy), -- 1472
			Vec2(wx + ww, wy), -- 1473
			Vec2(wx + ww, wy + wh * 0.34), -- 1474
			Vec2(wx + ww * 0.56, wy + wh * 0.42), -- 1475
			Vec2(wx + ww * 0.22, wy + wh * 0.28), -- 1476
			Vec2(wx, wy + wh * 0.36) -- 1477
		}, -- 1477
		Color(20, 26, 38, 240) -- 1478
	) -- 1478
	if lampProg > 0.12 then -- 1480
		fillRadialGlow( -- 1481
			uiGlow, -- 1482
			wx + ww * 0.5, -- 1482
			wy + 26 * s, -- 1482
			ww * 0.65, -- 1483
			wh * 0.55, -- 1483
			Color( -- 1484
				248, -- 1484
				206, -- 1484
				134, -- 1484
				math.floor(92 * lampProg + 0.5) -- 1484
			), -- 1484
			Color(232, 174, 88, 0), -- 1485
			16 -- 1486
		) -- 1486
	end -- 1486
	local leftWall = shadeSurface( -- 1491
		MING_MATERIALS.mingBrick.base, -- 1491
		vec3(0.84, 0.22, -0.49), -- 1491
		10, -- 1491
		1, -- 1491
		light, -- 1491
		MING_MATERIALS.mingBrick -- 1491
	) -- 1491
	local rightWall = shadeSurface( -- 1492
		MING_MATERIALS.mingBrick.base, -- 1492
		vec3(-0.84, 0.22, -0.49), -- 1492
		10, -- 1492
		1, -- 1492
		light, -- 1492
		MING_MATERIALS.mingBrick -- 1492
	) -- 1492
	local sillCol = shadeSurface( -- 1493
		MING_MATERIALS.mingStoneStep.base, -- 1493
		vec3(0, 0.94, -0.34), -- 1493
		6, -- 1493
		1, -- 1493
		light, -- 1493
		MING_MATERIALS.mingStoneStep -- 1493
	) -- 1493
	uiDraw:drawPolygon( -- 1494
		{ -- 1494
			Vec2(wx - embrasure, wy - 12 * s), -- 1495
			Vec2(wx, wy), -- 1496
			Vec2(wx, wy + wh), -- 1497
			Vec2(wx - embrasure, wy + wh + 14 * s) -- 1498
		}, -- 1498
		toColor(leftWall) -- 1499
	) -- 1499
	uiDraw:drawPolygon( -- 1500
		{ -- 1500
			Vec2(wx + ww, wy), -- 1501
			Vec2(wx + ww + embrasure, wy - 12 * s), -- 1502
			Vec2(wx + ww + embrasure, wy + wh + 14 * s), -- 1503
			Vec2(wx + ww, wy + wh) -- 1504
		}, -- 1504
		toColor(rightWall) -- 1505
	) -- 1505
	uiDraw:drawPolygon( -- 1507
		{ -- 1507
			Vec2(wx - embrasure - 10 * s, wy - 16 * s), -- 1508
			Vec2(wx + ww + embrasure + 10 * s, wy - 16 * s), -- 1509
			Vec2(wx + ww + 4 * s, wy + 10 * s), -- 1510
			Vec2(wx - 4 * s, wy + 10 * s) -- 1511
		}, -- 1511
		toColor(sillCol), -- 1512
		1, -- 1512
		toColor(STONE_EDGE_FALLBACK, 140) -- 1512
	) -- 1512
	local bar = 1 -- 1515
	do -- 1515
		bar = 1 -- 1516
		while bar <= 3 do -- 1516
			local bx = wx + ww * bar / 4 -- 1517
			uiDraw:drawSegment( -- 1518
				Vec2(bx, wy + 6 * s), -- 1518
				Vec2(bx, wy + wh - 2 * s), -- 1518
				3 * s, -- 1518
				Color(46, 34, 26, 235) -- 1518
			) -- 1518
			bar = bar + 1 -- 1516
		end -- 1516
	end -- 1516
	uiDraw:drawSegment( -- 1520
		Vec2(wx, wy + wh * 0.56), -- 1520
		Vec2(wx + ww, wy + wh * 0.56), -- 1520
		3.2 * s, -- 1520
		Color(46, 34, 26, 235) -- 1520
	) -- 1520
	uiDraw:drawRect( -- 1521
		Rect(wx, wy, ww, wh), -- 1521
		Color(0, 0, 0, 0), -- 1521
		2.4 * s, -- 1521
		Color(66, 50, 38, 240) -- 1521
	) -- 1521
	if lampProg > 0.02 then -- 1524
		fillRadialGlow( -- 1525
			uiGlow, -- 1526
			wx + ww * 0.5, -- 1526
			wy + 34 * s, -- 1526
			540 * s, -- 1527
			390 * s, -- 1527
			Color( -- 1528
				246, -- 1528
				198, -- 1528
				122, -- 1528
				math.floor(74 * lampProg + 0.5) -- 1528
			), -- 1528
			Color(216, 154, 72, 0), -- 1529
			20 -- 1530
		) -- 1530
	end -- 1530
end -- 1439
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1535
	fillVGradRect( -- 1545
		uiDraw, -- 1546
		0, -- 1546
		0, -- 1546
		ctx.uiW, -- 1546
		ctx.uiH, -- 1546
		Color(26, 21, 20, 255), -- 1547
		Color(46, 36, 30, 255) -- 1548
	) -- 1548
	local r = 0 -- 1551
	do -- 1551
		r = 0 -- 1552
		while r < 9 do -- 1552
			local y = oy + (280 + r * 44) * s -- 1553
			uiDraw:drawSegment( -- 1554
				Vec2(0, y), -- 1554
				Vec2(ctx.uiW, y), -- 1554
				1, -- 1554
				Color(34, 27, 24, 150) -- 1554
			) -- 1554
			r = r + 1 -- 1552
		end -- 1552
	end -- 1552
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1558
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1559
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1560
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1561
	fillVGradRect( -- 1562
		uiDraw, -- 1562
		wx, -- 1562
		wy, -- 1562
		ww, -- 1562
		wh, -- 1562
		Color(56, 62, 74, 255), -- 1562
		Color(26, 34, 50, 255) -- 1562
	) -- 1562
	uiDraw:drawRect( -- 1563
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1563
		Color(92, 68, 48, 255), -- 1563
		1, -- 1563
		Color(148, 114, 82, 180) -- 1563
	) -- 1563
	local bar = 1 -- 1564
	do -- 1564
		bar = 1 -- 1565
		while bar <= 3 do -- 1565
			local bx = wx + ww * bar / 4 -- 1566
			uiDraw:drawSegment( -- 1567
				Vec2(bx, wy + 4 * s), -- 1567
				Vec2(bx, wy + wh - 2 * s), -- 1567
				3.2 * s, -- 1567
				Color(64, 46, 34, 245) -- 1567
			) -- 1567
			bar = bar + 1 -- 1565
		end -- 1565
	end -- 1565
	uiDraw:drawSegment( -- 1569
		Vec2(wx, wy + wh * 0.56), -- 1569
		Vec2(wx + ww, wy + wh * 0.56), -- 1569
		3.2 * s, -- 1569
		Color(64, 46, 34, 245) -- 1569
	) -- 1569
	uiDraw:drawRect( -- 1570
		Rect(wx, wy, ww, wh), -- 1570
		Color(0, 0, 0, 0), -- 1570
		2.8 * s, -- 1570
		Color(88, 64, 44, 245) -- 1570
	) -- 1570
	local groupX = ox + 210 * s -- 1573
	local groupY = oy + 300 * s -- 1574
	uiArt:tryPlace( -- 1575
		"soldier_idle", -- 1575
		"fe05_m03_room_soldier", -- 1575
		groupX - 38 * s, -- 1575
		groupY, -- 1575
		118 * s, -- 1575
		166 * s, -- 1575
		{facing = 1, opacity = 0.9, layer = 1} -- 1575
	) -- 1575
	uiArt:tryPlace( -- 1578
		"child_idle", -- 1578
		"fe05_m03_room_child", -- 1578
		groupX + 42 * s, -- 1578
		groupY, -- 1578
		86 * s, -- 1578
		116 * s, -- 1578
		{facing = 1, opacity = 0.92, layer = 1} -- 1578
	) -- 1578
	fillRadialGlow( -- 1583
		uiGlow, -- 1584
		ox + 260 * s, -- 1584
		oy + 416 * s, -- 1584
		520 * s, -- 1585
		360 * s, -- 1585
		Color(246, 202, 134, 68), -- 1586
		Color(220, 158, 76, 0), -- 1587
		20 -- 1588
	) -- 1588
end -- 1535
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1592
	local t = self.seqElapsed -- 1605
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1606
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1607
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1608
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1609
	local midX = bx + bw * 0.5 -- 1610
	local midY = by + bh * 0.5 -- 1611
	uiDraw:drawRect( -- 1614
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1614
		Color( -- 1614
			10, -- 1614
			11, -- 1614
			16, -- 1614
			math.floor(108 * reveal + 0.5) -- 1614
		) -- 1614
	) -- 1614
	uiDraw:drawRect( -- 1615
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1615
		Color( -- 1615
			32, -- 1615
			46, -- 1615
			62, -- 1615
			math.floor(235 * reveal + 0.5) -- 1615
		), -- 1615
		1, -- 1615
		Color( -- 1615
			86, -- 1615
			104, -- 1615
			124, -- 1615
			math.floor(165 * reveal + 0.5) -- 1615
		) -- 1615
	) -- 1615
	if not uiArt:tryPlace( -- 1618
		"ink_song_paper", -- 1618
		"fe05_registry_paper", -- 1618
		midX, -- 1618
		midY, -- 1618
		bw, -- 1618
		bh, -- 1618
		{opacity = 0.98 * reveal, layer = 1} -- 1618
	) then -- 1618
		uiDraw:drawRect( -- 1619
			Rect(bx, by, bw, bh), -- 1620
			toColor( -- 1621
				PALETTE.xuanPaper, -- 1621
				math.floor(248 * reveal + 0.5) -- 1621
			), -- 1621
			1, -- 1622
			toColor( -- 1623
				PALETTE.silkDim, -- 1623
				math.floor(180 * reveal + 0.5) -- 1623
			) -- 1623
		) -- 1623
	end -- 1623
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1628
	fillRadialGlow( -- 1629
		uiGlow, -- 1630
		bx + bw * 0.34, -- 1630
		by + bh * 0.48, -- 1630
		bw * 0.58, -- 1631
		bh * 0.52, -- 1631
		Color( -- 1632
			246, -- 1632
			214, -- 1632
			156, -- 1632
			math.floor(44 * paperWarm * reveal + 0.5) -- 1632
		), -- 1632
		Color(238, 198, 128, 0), -- 1633
		16 -- 1634
	) -- 1634
	local padX = 44 * s -- 1638
	local padY = 32 * s -- 1639
	local inX = bx + padX -- 1640
	local inY = by + padY -- 1641
	local inW = bw - padX * 2 -- 1642
	local inH = bh - padY * 2 -- 1643
	local redSilk = toColor( -- 1644
		PALETTE.rouge, -- 1644
		math.floor(132 * reveal + 0.5) -- 1644
	) -- 1644
	local redFaint = toColor( -- 1645
		PALETTE.rouge, -- 1645
		math.floor(70 * reveal + 0.5) -- 1645
	) -- 1645
	uiInkDraw:drawRect( -- 1646
		Rect(inX, inY, inW, inH), -- 1646
		Color(0, 0, 0, 0), -- 1646
		1, -- 1646
		redSilk -- 1646
	) -- 1646
	uiInkDraw:drawRect( -- 1647
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1647
		Color(0, 0, 0, 0), -- 1647
		0.6, -- 1647
		redFaint -- 1647
	) -- 1647
	local headY = inY + inH - 28 * s -- 1650
	ctx.texts:put( -- 1651
		"md", -- 1651
		"北塔值夜收籍 · 末页", -- 1651
		inX + 18 * s, -- 1651
		headY, -- 1651
		toColor(PALETTE.xuanInk), -- 1651
		0, -- 1651
		0.5, -- 1651
		"Left", -- 1651
		2.2, -- 1651
		0.96 * reveal, -- 1651
		0 -- 1651
	) -- 1651
	ctx.texts:put( -- 1652
		"xs", -- 1652
		"宁村北塔", -- 1652
		inX + inW - 18 * s, -- 1652
		headY, -- 1652
		toColor(PALETTE.xuanInkSub), -- 1652
		1, -- 1652
		0.5, -- 1652
		"Right", -- 1652
		1.8, -- 1652
		0.8 * reveal, -- 1652
		0 -- 1652
	) -- 1652
	uiInkDraw:drawSegment( -- 1653
		Vec2(inX + 14 * s, headY - 22 * s), -- 1653
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1653
		0.9, -- 1653
		redSilk -- 1653
	) -- 1653
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1656
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1657
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1658
	ctx.texts:put( -- 1659
		"sm", -- 1659
		"肆拾壹", -- 1659
		inX + 18 * s, -- 1659
		row1Y, -- 1659
		toColor(PALETTE.rouge), -- 1659
		0, -- 1659
		0.5, -- 1659
		"Left", -- 1659
		1, -- 1659
		0.94 * reveal, -- 1659
		0 -- 1659
	) -- 1659
	if r1Prog > 0.02 then -- 1660
		ctx.texts:put( -- 1661
			"md", -- 1661
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1661
			inX + 96 * s, -- 1661
			row1Y, -- 1661
			toColor(PALETTE.xuanInk), -- 1661
			0, -- 1661
			0.5, -- 1661
			"Left", -- 1661
			1.6, -- 1661
			0.96 * math.min(1, r1Prog * 1.4), -- 1661
			0 -- 1661
		) -- 1661
	end -- 1661
	if r1Prog > 0.65 then -- 1663
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1664
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1665
		ctx.texts:put( -- 1668
			"xs", -- 1668
			subText, -- 1668
			inX + 96 * s, -- 1668
			row1SubY, -- 1668
			toColor(PALETTE.xuanInkSub), -- 1668
			0, -- 1668
			0.5, -- 1668
			"Left", -- 1668
			0.6, -- 1668
			0.88 * subA, -- 1668
			0 -- 1668
		) -- 1668
	end -- 1668
	uiInkDraw:drawSegment( -- 1670
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1670
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1670
		0.7, -- 1670
		redFaint -- 1670
	) -- 1670
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1673
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1674
	ctx.texts:put( -- 1675
		"sm", -- 1675
		"肆拾贰", -- 1675
		inX + 18 * s, -- 1675
		row2Y, -- 1675
		toColor(PALETTE.rouge), -- 1675
		0, -- 1675
		0.5, -- 1675
		"Left", -- 1675
		1, -- 1675
		0.94 * reveal, -- 1675
		0 -- 1675
	) -- 1675
	if route == "child" then -- 1677
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1679
		uiInkDraw:drawSegment( -- 1680
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1681
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1682
			1, -- 1683
			toColor(PALETTE.xuanInkSub, lineA) -- 1684
		) -- 1684
	else -- 1684
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1688
		if r2Prog <= 0.02 then -- 1689
			uiInkDraw:drawSegment( -- 1690
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1691
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1692
				0.9, -- 1693
				toColor( -- 1694
					PALETTE.xuanInkSub, -- 1694
					math.floor(105 * reveal + 0.5) -- 1694
				) -- 1694
			) -- 1694
		else -- 1694
			ctx.texts:put( -- 1697
				"md", -- 1697
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1697
				inX + 96 * s, -- 1697
				row2Y, -- 1697
				toColor(PALETTE.xuanInk), -- 1697
				0, -- 1697
				0.5, -- 1697
				"Left", -- 1697
				1.6, -- 1697
				0.96 * math.min(1, r2Prog * 1.4), -- 1697
				0 -- 1697
			) -- 1697
			if r2Prog > 0.65 then -- 1698
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1699
				ctx.texts:put( -- 1700
					"xs", -- 1700
					"守城戍卒亲口报出姓名，两人俱安。", -- 1700
					inX + 96 * s, -- 1700
					row2SubY, -- 1700
					toColor(PALETTE.xuanInkSub), -- 1700
					0, -- 1700
					0.5, -- 1700
					"Left", -- 1700
					0.6, -- 1700
					0.88 * subA, -- 1700
					0 -- 1700
				) -- 1700
			end -- 1700
		end -- 1700
	end -- 1700
	uiInkDraw:drawSegment( -- 1704
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1704
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1704
		0.7, -- 1704
		redFaint -- 1704
	) -- 1704
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1707
	if colophonA > 0.02 then -- 1708
		local signY = inY + 34 * s -- 1709
		ctx.texts:put( -- 1710
			"banner", -- 1710
			"向西守望", -- 1710
			midX - 24 * s, -- 1710
			signY, -- 1710
			toColor(PALETTE.xuanInk), -- 1710
			0.5, -- 1710
			0.5, -- 1710
			"Center", -- 1710
			6, -- 1710
			0.88 * colophonA, -- 1710
			0 -- 1710
		) -- 1710
	end -- 1710
	self:drawGuardBrushHand( -- 1714
		uiInkDraw, -- 1714
		route, -- 1714
		s, -- 1714
		ox, -- 1714
		oy -- 1714
	) -- 1714
end -- 1592
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, route, s, ox, oy) -- 1717
	local t = self.seqElapsed -- 1724
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1725
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1726
	local row1X0 = hoverX -- 1727
	local row1X1 = hoverX + 142 * s -- 1728
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1729
	local tipX = hoverX -- 1731
	local tipY = hoverY -- 1732
	local alpha = 0 -- 1733
	local lifted = 0 -- 1734
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1736
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1738
		tipX = lerp(row1X0, row1X1, k) -- 1739
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1740
		alpha = smoothstep(2, 2.2, t) -- 1741
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1742
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1743
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1745
		tipX = lerp(row1X1, hoverX, moveK) -- 1746
		tipY = lerp(row1Y, hoverY, moveK) -- 1747
		alpha = 1 -- 1748
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1749
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1750
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1752
		tipX = hoverX + outK * 140 * s -- 1753
		tipY = hoverY + outK * 46 * s -- 1754
		lifted = (9 + outK * 28) * s -- 1755
		alpha = 1 - outK -- 1756
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1757
		if t < 4.6 then -- 1759
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1760
			tipX = hoverX -- 1761
			tipY = hoverY -- 1762
			lifted = lerp(9 * s, 0, dipK) -- 1763
			alpha = 1 -- 1764
		elseif t < 5.55 then -- 1765
			local wK = smoothstep(4.6, 5.55, t) -- 1766
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1767
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1768
			lifted = 0 -- 1769
			alpha = 1 -- 1770
		else -- 1770
			local outK = smoothstep(5.55, 6.05, t) -- 1772
			tipX = hoverX + 216 * s + outK * 115 * s -- 1773
			tipY = hoverY + outK * 52 * s -- 1774
			lifted = outK * 24 * s -- 1775
			alpha = 1 - outK -- 1776
		end -- 1776
	end -- 1776
	if alpha <= 0.02 then -- 1780
		return -- 1781
	end -- 1781
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1784
	local bx = tipX -- 1785
	local by = tipY + lifted -- 1786
	uiInkDraw:drawEllipse( -- 1788
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1788
		(5 + lifted * 0.22) * s, -- 1788
		2.8 * s, -- 1788
		Color( -- 1788
			20, -- 1788
			18, -- 1788
			16, -- 1788
			math.floor(78 * alpha + 0.5) -- 1788
		) -- 1788
	) -- 1788
	uiInkDraw:drawPolygon( -- 1790
		{ -- 1790
			Vec2(bx, by), -- 1791
			Vec2(bx + 15 * s, by - 4 * s), -- 1792
			Vec2(bx + 10 * s, by + 8 * s) -- 1793
		}, -- 1793
		Color(22, 22, 26, a) -- 1794
	) -- 1794
	uiInkDraw:drawSegment( -- 1796
		Vec2(bx + 12 * s, by + 2 * s), -- 1796
		Vec2(bx + 24 * s, by + 6 * s), -- 1796
		7.8 * s, -- 1796
		Color(164, 138, 92, a) -- 1796
	) -- 1796
	uiInkDraw:drawSegment( -- 1797
		Vec2(bx + 22 * s, by + 5 * s), -- 1797
		Vec2(bx + 122 * s, by + 34 * s), -- 1797
		6.8 * s, -- 1797
		Color(142, 110, 74, a) -- 1797
	) -- 1797
	uiInkDraw:drawSegment( -- 1798
		Vec2(bx + 22 * s, by + 5 * s), -- 1798
		Vec2(bx + 122 * s, by + 34 * s), -- 1798
		1.8 * s, -- 1798
		Color( -- 1798
			196, -- 1798
			164, -- 1798
			118, -- 1798
			math.floor(185 * alpha + 0.5) -- 1798
		) -- 1798
	) -- 1798
	uiInkDraw:drawPolygon( -- 1800
		{ -- 1800
			Vec2(bx + 44 * s, by - 6 * s), -- 1801
			Vec2(bx + 102 * s, by - 14 * s), -- 1802
			Vec2(bx + 110 * s, by + 18 * s), -- 1803
			Vec2(bx + 54 * s, by + 22 * s) -- 1804
		}, -- 1804
		Color(188, 154, 126, a), -- 1805
		1, -- 1805
		Color(128, 98, 76, a) -- 1805
	) -- 1805
	uiInkDraw:drawSegment( -- 1806
		Vec2(bx + 46 * s, by + 16 * s), -- 1806
		Vec2(bx + 76 * s, by + 20 * s), -- 1806
		5.2 * s, -- 1806
		Color(204, 170, 140, a) -- 1806
	) -- 1806
	uiInkDraw:drawSegment( -- 1807
		Vec2(bx + 48 * s, by + 2 * s), -- 1807
		Vec2(bx + 82 * s, by + 4 * s), -- 1807
		4.8 * s, -- 1807
		Color(180, 146, 118, a) -- 1807
	) -- 1807
	uiInkDraw:drawPolygon( -- 1808
		{ -- 1808
			Vec2(bx + 98 * s, by - 14 * s), -- 1809
			Vec2(bx + 224 * s, by - 32 * s), -- 1810
			Vec2(bx + 230 * s, by + 18 * s), -- 1811
			Vec2(bx + 104 * s, by + 20 * s) -- 1812
		}, -- 1812
		Color(54, 48, 44, a), -- 1813
		1.2, -- 1813
		Color(94, 84, 72, a) -- 1813
	) -- 1813
end -- 1717
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiGlow, ctx, route, s, ox, oy) -- 1816
	local t = self.seqElapsed -- 1826
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1827
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1828
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1829
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1830
	if route == "child" then -- 1832
		local propA = smoothstep(1.55, 2.05, t) -- 1834
		if propA > 0.02 then -- 1835
			self:drawNeedleCaseOnDesk( -- 1836
				uiInkDraw, -- 1836
				ncX, -- 1836
				ncY, -- 1836
				s, -- 1836
				propA, -- 1836
				true -- 1836
			) -- 1836
		end -- 1836
		local noteReadA = smoothstep(1.65, 2.1, t) * (1 - smoothstep(3.65, 4.15, t)) -- 1838
		if noteReadA > 0.02 then -- 1839
			local cardX = ncX + 18 * s -- 1840
			local cardY = ncY + 84 * s -- 1841
			uiInkDraw:drawRect( -- 1842
				Rect(cardX - 118 * s, cardY - 30 * s, 236 * s, 60 * s), -- 1843
				toColor( -- 1844
					PALETTE.xuanPaper, -- 1844
					math.floor(238 * noteReadA + 0.5) -- 1844
				), -- 1844
				1, -- 1845
				toColor( -- 1846
					PALETTE.rouge, -- 1846
					math.floor(110 * noteReadA + 0.5) -- 1846
				) -- 1846
			) -- 1846
			ctx.texts:put( -- 1848
				"xs", -- 1848
				NEEDLE_NOTE_LINES[1], -- 1848
				cardX, -- 1848
				cardY + 10 * s, -- 1848
				toColor(PALETTE.xuanInk), -- 1848
				0.5, -- 1848
				0.5, -- 1848
				"Center", -- 1848
				0.6, -- 1848
				0.94 * noteReadA, -- 1848
				0 -- 1848
			) -- 1848
			ctx.texts:put( -- 1849
				"xs", -- 1849
				"—— " .. NEEDLE_NOTE_LINES[2], -- 1849
				cardX + 74 * s, -- 1849
				cardY - 12 * s, -- 1849
				toColor(PALETTE.xuanInkSub), -- 1849
				1, -- 1849
				0.5, -- 1849
				"Right", -- 1849
				0.8, -- 1849
				0.88 * noteReadA, -- 1849
				0 -- 1849
			) -- 1849
		end -- 1849
		local bowlK = smoothstep(4.35, 5.15, t) -- 1852
		if bowlK > 0.02 then -- 1853
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1854
			self:drawWarmPorcelainBowl( -- 1855
				uiInkDraw, -- 1855
				uiGlow, -- 1855
				bx, -- 1855
				bowlY, -- 1855
				s, -- 1855
				bowlK, -- 1855
				false, -- 1855
				0 -- 1855
			) -- 1855
		end -- 1855
	else -- 1855
		local needleK = smoothstep(5.45, 6.15, t) -- 1859
		if needleK > 0.02 then -- 1860
			local ny = lerp(ncY + 46 * s, ncY, needleK) -- 1861
			self:drawNeedleCaseOnDesk( -- 1862
				uiInkDraw, -- 1862
				ncX, -- 1862
				ny, -- 1862
				s, -- 1862
				needleK, -- 1862
				false -- 1862
			) -- 1862
		end -- 1862
		local bowlK = smoothstep(5.8, 6.65, t) -- 1865
		if bowlK > 0.02 then -- 1866
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1867
			local handsK = smoothstep(5.95, 6.75, t) -- 1868
			self:drawWarmPorcelainBowl( -- 1869
				uiInkDraw, -- 1869
				uiGlow, -- 1869
				bowlX, -- 1869
				by, -- 1869
				s, -- 1869
				bowlK, -- 1869
				true, -- 1869
				handsK -- 1869
			) -- 1869
		end -- 1869
		local cuffK = smoothstep(4.25, 4.85, t) -- 1872
		if cuffK > 0.02 then -- 1873
			drawPatchedCuff(uiInkDraw, uiGlow, { -- 1874
				wristX = ox + 122 * s, -- 1875
				wristY = oy + 182 * s, -- 1876
				angleRad = 0.08, -- 1877
				scale = 0.6 * s, -- 1878
				pose = "open", -- 1879
				opacity = 0.92 * cuffK, -- 1880
				stitchHighlight = 0.34, -- 1881
				warmth = 0.72 -- 1882
			}) -- 1882
		end -- 1882
	end -- 1882
end -- 1816
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, draw, cx, cy, s, alpha, withNote) -- 1889
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1897
	draw:drawEllipse( -- 1899
		Vec2(cx + 4 * s, cy - 12 * s), -- 1899
		44 * s, -- 1899
		14 * s, -- 1899
		Color( -- 1899
			10, -- 1899
			10, -- 1899
			14, -- 1899
			math.floor(140 * alpha + 0.5) -- 1899
		) -- 1899
	) -- 1899
	draw:drawPolygon( -- 1901
		{ -- 1901
			Vec2(cx - 32 * s, cy - 12 * s), -- 1902
			Vec2(cx + 26 * s, cy - 15 * s), -- 1903
			Vec2(cx + 30 * s, cy + 16 * s), -- 1904
			Vec2(cx - 28 * s, cy + 18 * s) -- 1905
		}, -- 1905
		Color(148, 124, 92, a), -- 1906
		1.3, -- 1906
		Color(88, 70, 50, a) -- 1906
	) -- 1906
	draw:drawEllipse( -- 1908
		Vec2(cx + 18 * s, cy + 2 * s), -- 1908
		13 * s, -- 1908
		13 * s, -- 1908
		Color(188, 152, 86, a) -- 1908
	) -- 1908
	strokeEllipse( -- 1909
		draw, -- 1909
		cx + 18 * s, -- 1909
		cy + 2 * s, -- 1909
		13 * s, -- 1909
		13 * s, -- 1909
		1.5 * s, -- 1909
		Color(118, 92, 46, a), -- 1909
		18 -- 1909
	) -- 1909
	draw:drawDot( -- 1910
		Vec2(cx + 18 * s, cy + 2 * s), -- 1910
		2.5 * s, -- 1910
		Color(72, 54, 28, a) -- 1910
	) -- 1910
	draw:drawSegment( -- 1911
		Vec2(cx + 12 * s, cy - 2 * s), -- 1911
		Vec2(cx + 24 * s, cy + 6 * s), -- 1911
		1.5 * s, -- 1911
		Color(164, 48, 44, a) -- 1911
	) -- 1911
	draw:drawSegment( -- 1913
		Vec2(cx - 28 * s, cy + 4 * s), -- 1913
		Vec2(cx - 56 * s, cy - 8 * s), -- 1913
		2.4 * s, -- 1913
		toColor(CUFF_PALETTE.childCord, a) -- 1913
	) -- 1913
	draw:drawSegment( -- 1914
		Vec2(cx - 56 * s, cy - 8 * s), -- 1914
		Vec2(cx - 72 * s, cy + 6 * s), -- 1914
		2.2 * s, -- 1914
		toColor(CUFF_PALETTE.childCord, a) -- 1914
	) -- 1914
	draw:drawSegment( -- 1915
		Vec2(cx - 72 * s, cy + 6 * s), -- 1915
		Vec2(cx - 48 * s, cy + 16 * s), -- 1915
		2 * s, -- 1915
		toColor( -- 1915
			CUFF_PALETTE.childCord, -- 1915
			math.floor(215 * alpha + 0.5) -- 1915
		) -- 1915
	) -- 1915
	if withNote then -- 1917
		draw:drawPolygon( -- 1919
			{ -- 1919
				Vec2(cx + 38 * s, cy - 18 * s), -- 1920
				Vec2(cx + 96 * s, cy - 12 * s), -- 1921
				Vec2(cx + 90 * s, cy + 24 * s), -- 1922
				Vec2(cx + 34 * s, cy + 18 * s) -- 1923
			}, -- 1923
			toColor(PALETTE.xuanPaper, a), -- 1924
			1, -- 1924
			toColor( -- 1924
				PALETTE.xuanInkSub, -- 1924
				math.floor(160 * alpha + 0.5) -- 1924
			) -- 1924
		) -- 1924
		draw:drawSegment( -- 1925
			Vec2(cx + 46 * s, cy + 8 * s), -- 1925
			Vec2(cx + 80 * s, cy + 11 * s), -- 1925
			1.2 * s, -- 1925
			toColor( -- 1925
				PALETTE.xuanInk, -- 1925
				math.floor(170 * alpha + 0.5) -- 1925
			) -- 1925
		) -- 1925
		draw:drawSegment( -- 1926
			Vec2(cx + 46 * s, cy - 2 * s), -- 1926
			Vec2(cx + 76 * s, cy + 1 * s), -- 1926
			1.2 * s, -- 1926
			toColor( -- 1926
				PALETTE.xuanInk, -- 1926
				math.floor(160 * alpha + 0.5) -- 1926
			) -- 1926
		) -- 1926
	end -- 1926
end -- 1889
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, draw, glow, cx, cy, s, alpha, heldByTwoHands, handsK) -- 1931
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1941
	draw:drawEllipse( -- 1943
		Vec2(cx, cy - 36 * s), -- 1943
		58 * s, -- 1943
		14 * s, -- 1943
		Color( -- 1943
			8, -- 1943
			9, -- 1943
			14, -- 1943
			math.floor(150 * alpha + 0.5) -- 1943
		) -- 1943
	) -- 1943
	draw:drawPolygon( -- 1945
		{ -- 1945
			Vec2(cx - 32 * s, cy - 38 * s), -- 1946
			Vec2(cx + 32 * s, cy - 38 * s), -- 1947
			Vec2(cx + 62 * s, cy + 8 * s), -- 1948
			Vec2(cx - 62 * s, cy + 8 * s) -- 1949
		}, -- 1949
		Color(168, 166, 156, a), -- 1950
		1.4, -- 1950
		Color(98, 96, 88, a) -- 1950
	) -- 1950
	draw:drawPolygon( -- 1952
		{ -- 1952
			Vec2(cx + 8 * s, cy - 36 * s), -- 1953
			Vec2(cx + 32 * s, cy - 38 * s), -- 1954
			Vec2(cx + 62 * s, cy + 8 * s), -- 1955
			Vec2(cx + 22 * s, cy + 6 * s) -- 1956
		}, -- 1956
		Color( -- 1957
			122, -- 1957
			120, -- 1957
			112, -- 1957
			math.floor(160 * alpha + 0.5) -- 1957
		) -- 1957
	) -- 1957
	draw:drawEllipse( -- 1959
		Vec2(cx, cy + 8 * s), -- 1959
		64 * s, -- 1959
		21 * s, -- 1959
		Color(224, 218, 206, a) -- 1959
	) -- 1959
	strokeEllipse( -- 1960
		draw, -- 1960
		cx, -- 1960
		cy + 8 * s, -- 1960
		64 * s, -- 1960
		21 * s, -- 1960
		1.9 * s, -- 1960
		Color(116, 110, 100, a), -- 1960
		28 -- 1960
	) -- 1960
	draw:drawEllipse( -- 1961
		Vec2(cx, cy + 6 * s), -- 1961
		54 * s, -- 1961
		15 * s, -- 1961
		Color(196, 168, 122, a) -- 1961
	) -- 1961
	strokeEllipse( -- 1962
		draw, -- 1962
		cx, -- 1962
		cy + 6 * s, -- 1962
		54 * s, -- 1962
		15 * s, -- 1962
		1.1 * s, -- 1962
		Color(158, 132, 92, a), -- 1962
		24 -- 1962
	) -- 1962
	draw:drawSegment( -- 1964
		Vec2(cx - 46 * s, cy + 16 * s), -- 1964
		Vec2(cx - 10 * s, cy + 25 * s), -- 1964
		2 * s, -- 1964
		Color( -- 1964
			248, -- 1964
			246, -- 1964
			240, -- 1964
			math.floor(215 * alpha + 0.5) -- 1964
		) -- 1964
	) -- 1964
	local wi = 0 -- 1967
	do -- 1967
		wi = 0 -- 1968
		while wi < 3 do -- 1968
			local phase = self.animTime * 1.1 + wi * 2.05 -- 1969
			local baseX = cx + (wi - 1) * 18 * s -- 1970
			local baseY = cy + 16 * s -- 1971
			local segs = 4 -- 1972
			local prevX = baseX -- 1973
			local prevY = baseY -- 1974
			local si = 1 -- 1975
			do -- 1975
				si = 1 -- 1976
				while si <= segs do -- 1976
					local frac = si / segs -- 1977
					local nx = baseX + math.sin(phase + frac * 3.1) * (6.5 * frac) * s -- 1978
					local ny = baseY + frac * (36 + wi % 2 * 10) * s -- 1979
					local wa = math.floor(46 * (1 - frac * 0.72) * alpha + 0.5) -- 1980
					glow:drawSegment( -- 1981
						Vec2(prevX, prevY), -- 1981
						Vec2(nx, ny), -- 1981
						(2.2 - frac * 0.9) * s, -- 1981
						Color(244, 238, 226, wa) -- 1981
					) -- 1981
					prevX = nx -- 1982
					prevY = ny -- 1983
					si = si + 1 -- 1976
				end -- 1976
			end -- 1976
			wi = wi + 1 -- 1968
		end -- 1968
	end -- 1968
	if heldByTwoHands and handsK > 0.02 then -- 1988
		local ha = math.floor(255 * clamp01(handsK * alpha) + 0.5) -- 1989
		local skin = toColor(CUFF_PALETTE.childSkin, ha) -- 1990
		local skinSh = toColor(CUFF_PALETTE.childSkinShadow, ha) -- 1991
		local sleeve = toColor(CUFF_PALETTE.childSleeve, ha) -- 1992
		local spread = (1 - handsK) * 28 * s -- 1993
		draw:drawPolygon( -- 1996
			{ -- 1996
				Vec2(cx - 122 * s - spread, cy - 58 * s), -- 1997
				Vec2(cx - 72 * s - spread, cy - 30 * s), -- 1998
				Vec2(cx - 82 * s - spread, cy - 4 * s), -- 1999
				Vec2(cx - 134 * s - spread, cy - 26 * s) -- 2000
			}, -- 2000
			sleeve, -- 2001
			1.1, -- 2001
			skinSh -- 2001
		) -- 2001
		draw:drawPolygon( -- 2002
			{ -- 2002
				Vec2(cx - 76 * s - spread, cy - 28 * s), -- 2003
				Vec2(cx - 48 * s - spread, cy - 18 * s), -- 2004
				Vec2(cx - 44 * s - spread, cy + 6 * s), -- 2005
				Vec2(cx - 74 * s - spread, cy + 2 * s) -- 2006
			}, -- 2006
			skin, -- 2007
			1.1, -- 2007
			skinSh -- 2007
		) -- 2007
		draw:drawSegment( -- 2008
			Vec2(cx - 56 * s - spread, cy + 2 * s), -- 2008
			Vec2(cx - 38 * s - spread, cy + 12 * s), -- 2008
			4.6 * s, -- 2008
			skin -- 2008
		) -- 2008
		draw:drawSegment( -- 2009
			Vec2(cx - 58 * s - spread, cy - 7 * s), -- 2009
			Vec2(cx - 40 * s - spread, cy - 2 * s), -- 2009
			4.4 * s, -- 2009
			skin -- 2009
		) -- 2009
		draw:drawSegment( -- 2010
			Vec2(cx - 56 * s - spread, cy - 16 * s), -- 2010
			Vec2(cx - 40 * s - spread, cy - 14 * s), -- 2010
			4.2 * s, -- 2010
			skin -- 2010
		) -- 2010
		draw:drawPolygon( -- 2013
			{ -- 2013
				Vec2(cx + 122 * s + spread, cy - 58 * s), -- 2014
				Vec2(cx + 72 * s + spread, cy - 30 * s), -- 2015
				Vec2(cx + 82 * s + spread, cy - 4 * s), -- 2016
				Vec2(cx + 134 * s + spread, cy - 26 * s) -- 2017
			}, -- 2017
			sleeve, -- 2018
			1.1, -- 2018
			skinSh -- 2018
		) -- 2018
		draw:drawPolygon( -- 2019
			{ -- 2019
				Vec2(cx + 76 * s + spread, cy - 28 * s), -- 2020
				Vec2(cx + 48 * s + spread, cy - 18 * s), -- 2021
				Vec2(cx + 44 * s + spread, cy + 6 * s), -- 2022
				Vec2(cx + 74 * s + spread, cy + 2 * s) -- 2023
			}, -- 2023
			skin, -- 2024
			1.1, -- 2024
			skinSh -- 2024
		) -- 2024
		draw:drawSegment( -- 2025
			Vec2(cx + 56 * s + spread, cy + 2 * s), -- 2025
			Vec2(cx + 38 * s + spread, cy + 12 * s), -- 2025
			4.6 * s, -- 2025
			skin -- 2025
		) -- 2025
		draw:drawSegment( -- 2026
			Vec2(cx + 58 * s + spread, cy - 7 * s), -- 2026
			Vec2(cx + 40 * s + spread, cy - 2 * s), -- 2026
			4.4 * s, -- 2026
			skin -- 2026
		) -- 2026
		draw:drawSegment( -- 2027
			Vec2(cx + 56 * s + spread, cy - 16 * s), -- 2027
			Vec2(cx + 40 * s + spread, cy - 14 * s), -- 2027
			4.2 * s, -- 2027
			skin -- 2027
		) -- 2027
	end -- 2027
end -- 1931
function TowerEndingsPlugin.prototype.drawMingLantern(self, draw, glow, cx, cy, scale, alpha, warmth) -- 2032
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 2041
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 2042
	draw:drawSegment( -- 2044
		Vec2(cx - 10 * scale, cy + 28 * scale), -- 2044
		Vec2(cx, cy + 40 * scale), -- 2044
		1.8 * scale, -- 2044
		Color(88, 86, 82, a) -- 2044
	) -- 2044
	draw:drawSegment( -- 2045
		Vec2(cx + 10 * scale, cy + 28 * scale), -- 2045
		Vec2(cx, cy + 40 * scale), -- 2045
		1.8 * scale, -- 2045
		Color(88, 86, 82, a) -- 2045
	) -- 2045
	draw:drawRect( -- 2047
		Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), -- 2047
		Color(62, 46, 34, a), -- 2047
		1, -- 2047
		Color(118, 92, 66, a) -- 2047
	) -- 2047
	draw:drawRect( -- 2048
		Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), -- 2048
		Color(62, 46, 34, a), -- 2048
		1, -- 2048
		Color(118, 92, 66, a) -- 2048
	) -- 2048
	draw:drawRect( -- 2050
		Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale), -- 2051
		Color( -- 2052
			238, -- 2052
			198, -- 2052
			132, -- 2052
			math.floor(230 * alpha * (0.75 + 0.25 * warmth) + 0.5) -- 2052
		), -- 2052
		1.4 * scale, -- 2053
		Color(94, 70, 48, a) -- 2054
	) -- 2054
	draw:drawSegment( -- 2056
		Vec2(cx, cy - 18 * scale), -- 2056
		Vec2(cx, cy + 22 * scale), -- 2056
		1.1 * scale, -- 2056
		Color( -- 2056
			94, -- 2056
			70, -- 2056
			48, -- 2056
			math.floor(150 * alpha + 0.5) -- 2056
		) -- 2056
	) -- 2056
	draw:drawEllipse( -- 2057
		Vec2(cx, cy + 2 * scale), -- 2057
		4.6 * scale * flicker, -- 2057
		8.5 * scale * flicker, -- 2057
		Color(255, 244, 212, a) -- 2057
	) -- 2057
	fillRadialGlow( -- 2059
		glow, -- 2060
		cx, -- 2060
		cy + 2 * scale, -- 2060
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2061
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2062
		Color( -- 2063
			250, -- 2063
			208, -- 2063
			132, -- 2063
			math.floor(128 * alpha * warmth + 0.5) -- 2063
		), -- 2063
		Color(228, 162, 74, 0), -- 2064
		16 -- 2065
	) -- 2065
end -- 2032
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 2069
	local line = self.lastSubtitle -- 2078
	if line ~= "" then -- 2079
		local cy = barH + 34 * s -- 2080
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 2081
		drawSilkVeil( -- 2082
			uiDraw, -- 2082
			uiArt, -- 2082
			"fe05_sub_veil", -- 2082
			ctx.uiW * 0.5, -- 2082
			cy, -- 2082
			stripW, -- 2082
			48 * s, -- 2082
			PALETTE.inkWash, -- 2082
			0.82, -- 2082
			3 -- 2082
		) -- 2082
		drawHairline( -- 2083
			uiInkDraw, -- 2083
			uiArt, -- 2083
			"fe05_sub_hair", -- 2083
			ctx.uiW * 0.5, -- 2083
			cy + 21 * s, -- 2083
			stripW * 0.68, -- 2083
			PALETTE.silkDim, -- 2083
			0.54, -- 2083
			true, -- 2083
			4 -- 2083
		) -- 2083
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 2084
		ctx.texts:put( -- 2085
			isSpoken and "md" or "sm", -- 2086
			line, -- 2087
			ctx.uiW * 0.5, -- 2088
			cy - 1 * s, -- 2089
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 2090
			0.5, -- 2091
			0.5, -- 2092
			"Center", -- 2093
			isSpoken and 1.8 or 1, -- 2094
			0.98, -- 2095
			0.08 -- 2096
		) -- 2096
	end -- 2096
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 2101
		local rawHint = route == "child" and "按 E 收页 · 尾声与史话   ·   Esc 暂歇" or "团圆尾声   ·   按 E 收页与史话   ·   Esc 暂歇" -- 2102
		local hint = getActiveTarget():adaptHintSentence(rawHint, ctx.input.inputMode, ctx.input.gamepadLayout) -- 2105
		ctx.texts:put( -- 2106
			"xs", -- 2106
			hint, -- 2106
			ctx.uiW * 0.5, -- 2106
			barH * 0.5, -- 2106
			toColor(PALETTE.textMid), -- 2106
			0.5, -- 2106
			0.5, -- 2106
			"Center", -- 2106
			1.4, -- 2106
			0.88, -- 2106
			0.08 -- 2106
		) -- 2106
	end -- 2106
end -- 2069
function ____exports.createTowerEndingsPlugin() -- 2111
	return __TS__New(____exports.TowerEndingsPlugin) -- 2112
end -- 2111
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 2116
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 2117
	fe:registerPlugin(plugin) -- 2118
	return plugin -- 2119
end -- 2116
return ____exports -- 2116
