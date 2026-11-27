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
	if not active then -- 314
		return "idle" -- 316
	end -- 316
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 316
		return "porch_knock" -- 319
	end -- 319
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 319
		return "door_open" -- 322
	end -- 322
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 322
		return "book_row1" -- 325
	end -- 325
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 325
		return "pivot_hover" -- 328
	end -- 328
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 328
		return "diverge_action" -- 331
	end -- 331
	return "ending_hold" -- 333
end -- 314
--- 将字符切片数组按进度拼接为前 n 段（避免 Lua 字节切片截断 UTF-8 汉字）
local function joinPrefixTokens(tokens, progress) -- 337
	if progress <= 0 or #tokens == 0 then -- 337
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
	if v ~= nil and type(v) == "table" then -- 353
		return v -- 355
	end -- 355
	return nil -- 357
end -- 353
--- 描边椭圆（Dora DrawNode.drawEllipse 仅支持填充，描边用等分折线保证锐利清晰）
local function strokeEllipse(draw, cx, cy, rx, ry, width, color, segments) -- 361
	if segments == nil then -- 361
		segments = 24 -- 369
	end -- 369
	if rx <= 0.5 or ry <= 0.5 or width <= 0.05 then -- 369
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
	if self.rehearsalActive then -- 433
		return self.rehearsalRoute -- 435
	end -- 435
	if view.storyRoute == "soldier" then -- 435
		return "soldier" -- 438
	end -- 438
	if view.storyRoute == "child" then -- 438
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
	if storyRec ~= nil and storyRec.ending == "reunion" then -- 445
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
	if not keepIndoorDoorOpen then -- 459
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
	if contract ~= nil then -- 484
		contract:enterRehearsal(tag) -- 486
		contract:setMockRoute(route) -- 487
	end -- 487
	local isIndoor = (opts and opts.indoorRetry) == true -- 489
	self.sessionId = self.sessionId + 1 -- 490
	self:clearSequenceState(isIndoor) -- 491
	self.active = true -- 492
	self.doorClosedAfterRetry = false -- 493
	if isIndoor then -- 493
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 495
	end -- 495
	if (opts and opts.seekTime) ~= nil then -- 495
		self:seekRehearsal(opts.seekTime) -- 498
	end -- 498
end -- 476
function TowerEndingsPlugin.prototype.seekRehearsal(self, seconds) -- 503
	if not self.rehearsalActive then -- 503
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
	if not self.doorOpened and self.seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 516
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
	if contract ~= nil then -- 538
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
	if loaded == nil then -- 590
		return -- 592
	end -- 592
	local rawFe = loaded["watch.fe"] -- 594
	if rawFe ~= nil and type(rawFe) == "table" then -- 594
		local watchFe = rawFe -- 596
		if watchFe.towerEndings ~= self then -- 596
			watchFe.towerEndings = self -- 598
		end -- 598
	end -- 598
end -- 588
function TowerEndingsPlugin.prototype.onBindPlay(self, p, view) -- 605
	self:syncRuntimeHook() -- 606
	self.sessionId = self.sessionId + 1 -- 607
	self.loopsActive = false -- 608
	self.prevPhase = p.phase -- 609
	if self.rehearsalActive then -- 609
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
	if not isTower then -- 632
		self:clearSequenceState(false) -- 635
		self.indoorRetryCount = 0 -- 636
		self.doorClosedAfterRetry = false -- 637
		return -- 638
	end -- 638
	if sameRunIndoorRetry or alreadyCutscenePhase then -- 638
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 643
		self.doorClosedAfterRetry = false -- 644
		self:clearSequenceState(true) -- 645
		if p.phase == "tower-end" then -- 645
			self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.divergeEndSec -- 647
			self:syncDerivedMilestones(self.seqElapsed, route) -- 648
		end -- 648
		return -- 650
	end -- 650
	if p.phase == "tower-enter" or p.phase == "tower-desk" then -- 650
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
	if not self.rehearsalActive and p.room.key ~= "tower" then -- 672
		if self.loopsActive then -- 672
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 676
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 677
			self.loopsActive = false -- 678
		end -- 678
		self.active = false -- 680
		return -- 681
	end -- 681
	local route = self:resolveRoute(p, ctx.view) -- 684
	self.activeRoute = route -- 685
	if not self.rehearsalActive then -- 685
		self:stepLiveSync(ctx, route) -- 688
	else -- 688
		self:stepRehearsal(ctx, route) -- 690
	end -- 690
	if not self.active then -- 690
		local inInteractiveHall = not self.rehearsalActive and p.room.key == "tower" and (p.phase == "tower-enter" or p.phase == "tower-desk") -- 694
		if self.loopsActive and not inInteractiveHall then -- 694
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 697
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 698
			self.loopsActive = false -- 699
		end -- 699
		return -- 701
	end -- 701
	if not ctx.paused and ctx.worldDt > 0 then -- 701
		self.animTime = self.animTime + ctx.worldDt -- 706
		self:syncDerivedMilestones(self.seqElapsed, route) -- 707
		self:syncAudioCues(ctx.audio, ctx, route) -- 708
		self:stepInputGuard(ctx.input) -- 709
	elseif not ctx.paused then -- 709
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
	if phase == "tower-wait" then -- 727
		self.doorOpenOverlayElapsed = -1 -- 731
		self.active = false -- 732
		return -- 733
	end -- 733
	if phase == "tower-enter" then -- 733
		self.doorOpened = true -- 738
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 739
		if justEnteredEnter and self.indoorRetryCount == 0 and not ctx.paused then -- 739
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
			if cameFromKnock then -- 746
				self.doorOpenOverlayElapsed = 0 -- 748
			end -- 748
		end -- 748
		if self.doorOpenOverlayElapsed >= 0 then -- 748
			if p.player.x >= p.ox + 520 then -- 748
				self.doorOpenOverlayElapsed = -1 -- 753
			elseif not ctx.paused and ctx.worldDt > 0 then -- 753
				self.doorOpenOverlayElapsed = self.doorOpenOverlayElapsed + ctx.worldDt -- 755
				if self.doorOpenOverlayElapsed >= 0.9 then -- 755
					self.doorOpenOverlayElapsed = -1 -- 757
				end -- 757
			end -- 757
		end -- 757
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.doorOpenSec) -- 761
		self.active = false -- 762
		self:syncDerivedMilestones(self.seqElapsed, route) -- 763
		return -- 764
	end -- 764
	if phase == "tower-desk" then -- 764
		self.doorOpenOverlayElapsed = -1 -- 769
		self.doorOpened = true -- 770
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 771
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 772
		self.active = false -- 773
		self:syncDerivedMilestones(self.seqElapsed, route) -- 774
		return -- 775
	end -- 775
	if not self.active then -- 775
		self.active = true -- 779
		self.staleInputMustRelease = ctx.input.interact.held or ctx.input.retry.held or ctx.input.interact.pressed -- 780
		self.confirmReady = false -- 781
	end -- 781
	if justEnteredKnock then -- 781
		self.seqElapsed = p.phaseTick / 60 -- 785
		self.holdElapsed = 0 -- 786
		self.staleInputMustRelease = true -- 787
		self.confirmReady = false -- 788
	elseif justEnteredGiven then -- 788
		self.doorOpened = true -- 790
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 791
	elseif justEnteredEnd then -- 791
		self.doorOpened = true -- 793
		self.seqElapsed = math.max(self.seqElapsed, 3.6 + p.phaseTick / 60) -- 795
	end -- 795
	if not ctx.paused and #ctx.events.rawEvents > 0 then -- 795
		local i = 0 -- 800
		do -- 800
			i = 0 -- 801
			while i < #ctx.events.rawEvents do -- 801
				local ev = ctx.events.rawEvents[i + 1] -- 802
				if ev.name == "knock" then -- 802
					local cnt = type(ev.data.count) == "number" and ev.data.count or self.knockCount + 1 -- 804
					if cnt >= 1 and self.knockCount < 1 then -- 804
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
					if cnt >= 2 and self.knockCount < 2 then -- 807
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
	if not ctx.paused and ctx.worldDt > 0 then -- 801
		if phase == "tower-knock" then -- 801
			local backendSec = math.min(____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60) -- 820
			self.seqElapsed = math.max(self.seqElapsed + ctx.worldDt, backendSec) -- 821
			if self.seqElapsed > ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 then -- 821
				self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 -- 823
			end -- 823
		else -- 823
			self.seqElapsed = self.seqElapsed + ctx.worldDt -- 826
			if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 826
				self.holdElapsed = self.holdElapsed + ctx.worldDt -- 828
			end -- 828
		end -- 828
	end -- 828
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 828
		self.doorClosedAfterRetry = true -- 834
	end -- 834
	self:syncDerivedMilestones(self.seqElapsed, route) -- 836
end -- 719
function TowerEndingsPlugin.prototype.stepRehearsal(self, ctx, route) -- 839
	self.active = true -- 840
	if not ctx.paused and ctx.worldDt > 0 then -- 840
		self.seqElapsed = self.seqElapsed + ctx.worldDt -- 842
		if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 842
			self.holdElapsed = self.holdElapsed + ctx.worldDt -- 844
		end -- 844
	end -- 844
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 844
		self.doorClosedAfterRetry = true -- 848
	end -- 848
	self:syncDerivedMilestones(self.seqElapsed, route) -- 850
end -- 839
function TowerEndingsPlugin.prototype.syncDerivedMilestones(self, t, route) -- 853
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec and self.knockCount < 1 then -- 853
		self.knockCount = 1 -- 855
	end -- 855
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec and self.knockCount < 2 then -- 855
		self.knockCount = 2 -- 858
	end -- 858
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec and self.replyKnockCount < 1 then -- 858
		self.replyKnockCount = 1 -- 861
	end -- 861
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec and self.replyKnockCount < 2 then -- 861
		self.replyKnockCount = 2 -- 864
	end -- 864
	if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 864
		self.doorOpened = true -- 867
	end -- 867
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec and not self.row1Written then -- 867
		self.row1Written = true -- 871
		self.registryAppendCount = self.registryAppendCount + 1 -- 872
	end -- 872
	if route == "soldier" and t >= 4.6 and not self.row2Written then -- 872
		self.row2Written = true -- 875
		self.registryAppendCount = self.registryAppendCount + 1 -- 876
	end -- 876
	if route == "child" and self.row2Written then -- 876
		self.row2Written = false -- 880
		self.registryAppendCount = self.row1Written and 1 or 0 -- 881
	end -- 881
end -- 853
function TowerEndingsPlugin.prototype.stepInputGuard(self, input) -- 885
	local keyHeld = input.interact.held or input.retry.held -- 886
	local keyPressed = input.interact.pressed or input.retry.pressed -- 887
	local readyTime = self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 888
	if self.staleInputMustRelease then -- 888
		if not keyHeld then -- 888
			self.staleInputMustRelease = false -- 892
		elseif keyPressed then -- 892
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 894
		end -- 894
		self.confirmReady = false -- 896
		return -- 897
	end -- 897
	if not readyTime then -- 897
		if keyPressed then -- 897
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 902
			self.staleInputMustRelease = keyHeld -- 903
		end -- 903
		self.confirmReady = false -- 905
		return -- 906
	end -- 906
	self.confirmReady = true -- 909
	if self.rehearsalActive and keyPressed then -- 909
		self.rehearsalAcknowledged = true -- 911
	end -- 911
end -- 885
function TowerEndingsPlugin.prototype.playTowerOnce(self, audio, tag, track, path, volume, cueId, tick, seq) -- 915
	if seq == nil then -- 915
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
	if indoorK > 0.05 then -- 936
		audio:playLoop( -- 938
			"tower_room_warm", -- 938
			"ambience", -- 938
			____exports.TOWER_AUDIO_FILES.roomWarm, -- 938
			lerp(0.06, 0.34, indoorK), -- 938
			tick -- 938
		) -- 938
	end -- 938
	if self.indoorRetryCount == 0 then -- 938
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec then -- 938
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
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec then -- 944
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
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 947
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
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec then -- 950
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
		if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 953
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
	if t >= 1.5 then -- 956
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
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 961
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
	if route == "child" then -- 964
		if t >= 4.35 then -- 964
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
		if t >= 4.45 then -- 969
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
		if t >= 5.2 then -- 972
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
		if t >= 4.28 then -- 975
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
		if t >= 4.62 then -- 979
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
		if t >= 5.55 then -- 982
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
		if t >= 6.02 then -- 985
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
	if t < ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 994
		return "[两下轻敲]  门外厚木上传来两声轻敲。" -- 996
	end -- 996
	if t < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 996
		return "[门内回敲]  静默一息，门后轻轻回敲两声。" -- 999
	end -- 999
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 999
		return route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 1002
	end -- 1002
	if t < ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 1002
		return route == "child" and "她把针套与纸条摊在案前，守卒展开收籍末页。" or "两人站在值夜室内，守卒摊开收籍末页。" -- 1007
	end -- 1007
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 1007
		return "守卒蘸墨提笔，在第一行写下「小满」。" -- 1012
	end -- 1012
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1012
		return "笔尖停在第二行上方。" -- 1015
	end -- 1015
	if route == "child" then -- 1015
		if t < 6.7 then -- 1015
			return F03_DIALOGUE -- 1019
		end -- 1019
		return "" -- 1021
	end -- 1021
	if t < 5.45 then -- 1021
		return M03_DIALOGUE -- 1024
	end -- 1024
	if t < 6.85 then -- 1024
		return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。" -- 1027
	end -- 1027
	return "" -- 1029
end -- 993
function TowerEndingsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1034
	if not self.active then -- 1034
		if not self.rehearsalActive and ctx.p.room.key == "tower" and ctx.p.phase == "tower-enter" and self.doorOpenOverlayElapsed >= 0 then -- 1034
			local u = clamp01(self.doorOpenOverlayElapsed / 0.9) -- 1044
			local fade = 1 - smoothstep(0.28, 1, u) -- 1045
			if fade > 0.02 then -- 1045
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
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1082
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
		if fadeOut > 0.01 then -- 1088
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
		if fadeIn > 0.01 then -- 1095
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
	if isLowpoly then -- 1142
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
						if lx > 4 * s and lx < doorL - 4 * s then -- 1238
							uiDraw:drawSegment( -- 1240
								Vec2(lx, by), -- 1240
								Vec2(lx, by + 46 * s), -- 1240
								0.9, -- 1240
								Color(36, 38, 44, 130) -- 1240
							) -- 1240
						end -- 1240
						local rx = doorR + stag + col * 68 * s -- 1242
						if rx > doorR + 4 * s and rx < ctx.uiW - 4 * s then -- 1242
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
	uiArt:tryPlacePath( -- 1254
		"assets/art/tex_diorama_ming.clip|ming_brick", -- 1254
		"fe05_porch_wall_l", -- 1254
		doorL * 0.5, -- 1254
		threshY + (ctx.uiH - threshY) * 0.5, -- 1254
		math.max(12, doorL), -- 1254
		math.max(12, ctx.uiH - threshY), -- 1254
		{ -- 1254
			color = isLowpoly and Color(86, 98, 114, 255) or Color(118, 114, 110, 255), -- 1255
			opacity = 0.42, -- 1256
			smooth = true, -- 1257
			layer = 0 -- 1258
		} -- 1258
	) -- 1258
	uiArt:tryPlacePath( -- 1260
		"assets/art/tex_diorama_ming.clip|ming_brick", -- 1260
		"fe05_porch_wall_r", -- 1260
		doorR + (ctx.uiW - doorR) * 0.5, -- 1260
		threshY + (ctx.uiH - threshY) * 0.5, -- 1260
		math.max(12, ctx.uiW - doorR), -- 1260
		math.max(12, ctx.uiH - threshY), -- 1260
		{ -- 1260
			color = isLowpoly and Color(86, 98, 114, 255) or Color(118, 114, 110, 255), -- 1261
			opacity = 0.42, -- 1262
			smooth = true, -- 1263
			layer = 0 -- 1264
		} -- 1264
	) -- 1264
	local innerWarm = 0.22 + openK * 0.78 + (r1Pulse + r2Pulse) * 0.14 -- 1268
	fillVGradRect( -- 1269
		uiDraw, -- 1270
		doorL, -- 1270
		threshY + 8 * s, -- 1270
		doorW, -- 1270
		doorH - 8 * s, -- 1270
		Color( -- 1271
			46, -- 1271
			32, -- 1271
			20, -- 1271
			math.floor(255 * math.min(1, innerWarm + 0.15) + 0.5) -- 1271
		), -- 1271
		Color( -- 1272
			118, -- 1272
			82, -- 1272
			42, -- 1272
			math.floor(255 * math.min(1, innerWarm) + 0.5) -- 1272
		) -- 1272
	) -- 1272
	local leafW = math.max(26 * s, doorW * (1 - openK * 0.76)) -- 1276
	local leafX = doorL + doorShakeX * (1 - openK) -- 1277
	if not uiArt:tryPlacePath( -- 1277
		"assets/art/cutscene_story_parts.clip|tower_porch_door", -- 1279
		"fe05_porch_door_leaf", -- 1280
		leafX + leafW * 0.5, -- 1281
		threshY + 10 * s, -- 1282
		leafW, -- 1283
		doorH - 12 * s, -- 1284
		{ -- 1285
			anchorX = 0.5, -- 1286
			anchorY = 0, -- 1287
			color = isLowpoly and Color(204, 212, 224, 255) or Color(238, 228, 214, 255), -- 1288
			opacity = 0.98, -- 1289
			smooth = true, -- 1290
			layer = 1 -- 1291
		} -- 1291
	) then -- 1291
		local woodCol = isLowpoly and toColor(shadeSurface( -- 1294
			MING_MATERIALS.mingTimberDark.base, -- 1295
			vec3(-0.2, 0.25, -0.95), -- 1295
			4, -- 1295
			1, -- 1295
			TOWER_WEST_LAMP_LIGHT, -- 1295
			MING_MATERIALS.mingTimberDark -- 1295
		)) or Color(76, 54, 38, 255) -- 1295
		uiDraw:drawRect( -- 1297
			Rect(leafX, threshY + 12 * s, leafW, doorH - 14 * s), -- 1298
			woodCol, -- 1299
			1.4, -- 1300
			Color(138, 106, 74, 185) -- 1301
		) -- 1301
	end -- 1301
	local seamGlowA = math.floor(92 + openK * 145 + (r1Pulse + r2Pulse) * 48 + 0.5) -- 1306
	fillRadialGlow( -- 1307
		uiGlow, -- 1308
		doorCx + openK * 24 * s, -- 1308
		threshY + 14 * s, -- 1308
		(92 + openK * 120) * s, -- 1309
		(26 + openK * 58) * s, -- 1309
		Color( -- 1310
			246, -- 1310
			204, -- 1310
			134, -- 1310
			math.min(220, seamGlowA) -- 1310
		), -- 1310
		Color(220, 156, 72, 0), -- 1311
		18 -- 1312
	) -- 1312
	local kx = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s -- 1316
	local ky = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s -- 1317
	if k1Pulse > 0.08 or k2Pulse > 0.08 then -- 1317
		local amp = math.max(k1Pulse, k2Pulse) -- 1319
		local r = (18 + (1 - amp) * 34) * s -- 1320
		strokeEllipse( -- 1321
			uiInkDraw, -- 1321
			kx + 24 * s, -- 1321
			ky, -- 1321
			r, -- 1321
			r * 0.85, -- 1321
			1.8 * s, -- 1321
			toColor( -- 1321
				PALETTE.amberCore, -- 1321
				math.floor(210 * amp + 0.5) -- 1321
			), -- 1321
			24 -- 1321
		) -- 1321
	end -- 1321
	if r1Pulse > 0.08 or r2Pulse > 0.08 then -- 1321
		local amp = math.max(r1Pulse, r2Pulse) -- 1324
		local r = (24 + (1 - amp) * 42) * s -- 1325
		strokeEllipse( -- 1326
			uiInkDraw, -- 1326
			doorCx + 30 * s, -- 1326
			ky + 16 * s, -- 1326
			r, -- 1326
			r * 0.9, -- 1326
			1.6 * s, -- 1326
			toColor( -- 1326
				PALETTE.amber, -- 1326
				math.floor(185 * amp + 0.5) -- 1326
			), -- 1326
			24 -- 1326
		) -- 1326
	end -- 1326
	if openK > 0.05 then -- 1326
		local lanX = ox + ____exports.TOWER_SHOT_LAYOUT.doorLanternX * s + (1 - openK) * 42 * s -- 1331
		local lanY = oy + ____exports.TOWER_SHOT_LAYOUT.doorLanternY * s -- 1332
		uiInkDraw:drawPolygon( -- 1334
			{ -- 1334
				Vec2(lanX + 76 * s, lanY + 42 * s), -- 1335
				Vec2(lanX + 12 * s, lanY + 34 * s), -- 1336
				Vec2(lanX + 8 * s, lanY + 12 * s), -- 1337
				Vec2(lanX + 78 * s, lanY + 12 * s) -- 1338
			}, -- 1338
			Color( -- 1339
				54, -- 1339
				48, -- 1339
				44, -- 1339
				math.floor(240 * openK + 0.5) -- 1339
			), -- 1339
			1, -- 1339
			Color( -- 1339
				98, -- 1339
				86, -- 1339
				74, -- 1339
				math.floor(180 * openK + 0.5) -- 1339
			) -- 1339
		) -- 1339
		self:drawMingLantern( -- 1340
			uiInkDraw, -- 1340
			uiGlow, -- 1340
			lanX, -- 1340
			lanY - 14 * s, -- 1340
			1.08 * s, -- 1340
			openK, -- 1340
			1 -- 1340
		) -- 1340
		fillRadialGlow( -- 1342
			uiGlow, -- 1343
			kx + 12 * s, -- 1343
			ky - 14 * s, -- 1343
			148 * s, -- 1344
			128 * s, -- 1344
			Color( -- 1345
				246, -- 1345
				208, -- 1345
				142, -- 1345
				math.floor(98 * openK + 0.5) -- 1345
			), -- 1345
			Color(232, 174, 92, 0), -- 1346
			18 -- 1347
		) -- 1347
	end -- 1347
	local stepInX = openK * 44 * s -- 1352
	local xiaomanX = doorCx - 66 * s + stepInX -- 1353
	local xiaomanY = threshY - 2 * s -- 1354
	uiDraw:drawEllipse( -- 1356
		Vec2(xiaomanX, xiaomanY + 2 * s), -- 1356
		34 * s, -- 1356
		8 * s, -- 1356
		Color(4, 6, 12, 190) -- 1356
	) -- 1356
	local childSlot = (k1Pulse > 0.25 or k2Pulse > 0.25) and "child_knock" or (openK > 0.45 and "child_offer" or "child_idle") -- 1357
	uiArt:tryPlace( -- 1358
		childSlot, -- 1358
		"fe05_porch_child", -- 1358
		xiaomanX, -- 1358
		xiaomanY, -- 1358
		108 * s, -- 1358
		148 * s, -- 1358
		{facing = 1, opacity = 0.98, layer = 2} -- 1358
	) -- 1358
	if openK > 0.15 then -- 1358
		local wristX = xiaomanX + 22 * s -- 1363
		local wristY = xiaomanY + 76 * s -- 1364
		uiInkDraw:drawRect( -- 1365
			Rect(wristX - 7 * s, wristY - 5 * s, 14 * s, 11 * s), -- 1366
			Color( -- 1367
				142, -- 1367
				118, -- 1367
				84, -- 1367
				math.floor(245 * openK + 0.5) -- 1367
			), -- 1367
			1, -- 1368
			Color( -- 1369
				222, -- 1369
				192, -- 1369
				128, -- 1369
				math.floor(235 * openK + 0.5) -- 1369
			) -- 1369
		) -- 1369
		uiInkDraw:drawSegment( -- 1371
			Vec2(wristX - 8 * s, wristY), -- 1372
			Vec2(wristX + 8 * s, wristY + 2 * s), -- 1373
			2 * s, -- 1374
			toColor( -- 1375
				CUFF_PALETTE.childCord, -- 1375
				math.floor(240 * openK + 0.5) -- 1375
			) -- 1375
		) -- 1375
	end -- 1375
	if route == "soldier" then -- 1375
		local zhouX = xiaomanX - 72 * s -- 1381
		local zhouY = threshY - 2 * s -- 1382
		uiDraw:drawEllipse( -- 1383
			Vec2(zhouX, zhouY + 2 * s), -- 1383
			42 * s, -- 1383
			9 * s, -- 1383
			Color(4, 6, 12, 190) -- 1383
		) -- 1383
		uiArt:tryPlace( -- 1384
			"soldier_idle", -- 1384
			"fe05_porch_soldier", -- 1384
			zhouX, -- 1384
			zhouY, -- 1384
			146 * s, -- 1384
			206 * s, -- 1384
			{facing = 1, opacity = 0.98, layer = 2} -- 1384
		) -- 1384
		local handMidX = (zhouX + xiaomanX) * 0.5 + 4 * s -- 1388
		local handMidY = threshY + 66 * s -- 1389
		uiInkDraw:drawSegment( -- 1390
			Vec2(zhouX + 20 * s, threshY + 106 * s), -- 1391
			Vec2(handMidX - 2 * s, handMidY), -- 1392
			6.2 * s, -- 1393
			toColor(CUFF_PALETTE.indigoBase, 245) -- 1394
		) -- 1394
		uiInkDraw:drawSegment( -- 1396
			Vec2(handMidX - 9 * s, handMidY + 9 * s), -- 1397
			Vec2(handMidX - 3 * s, handMidY + 13 * s), -- 1398
			1.9 * s, -- 1399
			toColor(CUFF_PALETTE.stitchThread, 240) -- 1400
		) -- 1400
		uiInkDraw:drawSegment( -- 1402
			Vec2(xiaomanX - 14 * s, threshY + 78 * s), -- 1403
			Vec2(handMidX + 2 * s, handMidY), -- 1404
			4.8 * s, -- 1405
			toColor(CUFF_PALETTE.childSleeve, 245) -- 1406
		) -- 1406
		uiInkDraw:drawDot( -- 1408
			Vec2(handMidX, handMidY), -- 1408
			4.8 * s, -- 1408
			toColor(CUFF_PALETTE.skinLight, 245) -- 1408
		) -- 1408
	end -- 1408
end -- 1116
function TowerEndingsPlugin.prototype.drawAct2And3Guardroom(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy) -- 1414
	local t = self.seqElapsed -- 1426
	local isLowpoly = route == "child" -- 1427
	local deskY = oy + ____exports.TOWER_SHOT_LAYOUT.deskTopY * s -- 1428
	local ____isLowpoly_9 -- 1431
	if isLowpoly then -- 1431
		____isLowpoly_9 = self:drawF03LowpolyRoomAndWindow( -- 1432
			uiDraw, -- 1432
			uiArt, -- 1432
			uiGlow, -- 1432
			ctx, -- 1432
			lampProg, -- 1432
			s, -- 1432
			ox, -- 1432
			oy -- 1432
		) -- 1432
	else -- 1432
		____isLowpoly_9 = self:drawM03PixelRoomAndWindow( -- 1433
			uiDraw, -- 1433
			uiArt, -- 1433
			uiGlow, -- 1433
			ctx, -- 1433
			s, -- 1433
			ox, -- 1433
			oy -- 1433
		) -- 1433
	end -- 1433
	local paintedRoomOk = ____isLowpoly_9 -- 1431
	if not paintedRoomOk then -- 1431
		local deskTopCol = isLowpoly and toColor(shadeSurface( -- 1437
			MING_MATERIALS.mingTimber.base, -- 1439
			vec3(-0.25, 0.9, -0.35), -- 1440
			0, -- 1441
			1, -- 1442
			lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1443
			MING_MATERIALS.mingTimber -- 1444
		)) or Color(86, 60, 42, 255) -- 1444
		local deskFrontCol = isLowpoly and toColor(shadeSurface( -- 1447
			MING_MATERIALS.mingTimberDark.base, -- 1449
			vec3(0, 0.1, -0.99), -- 1450
			-4, -- 1450
			1, -- 1452
			lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1453
			MING_MATERIALS.mingTimberDark -- 1454
		)) or Color(52, 36, 26, 255) -- 1454
		uiDraw:drawPolygon( -- 1457
			{ -- 1457
				Vec2(0, deskY - 120 * s), -- 1458
				Vec2(ctx.uiW, deskY - 120 * s), -- 1459
				Vec2(ctx.uiW, deskY + 42 * s), -- 1460
				Vec2(0, deskY + 42 * s) -- 1461
			}, -- 1461
			deskTopCol -- 1462
		) -- 1462
		uiDraw:drawRect( -- 1463
			Rect(0, 0, ctx.uiW, deskY - 118 * s), -- 1463
			deskFrontCol -- 1463
		) -- 1463
		local inkX = ox + ____exports.TOWER_SHOT_LAYOUT.inkstoneX * s -- 1464
		local inkY = oy + ____exports.TOWER_SHOT_LAYOUT.inkstoneY * s -- 1465
		uiDraw:drawPolygon( -- 1466
			{ -- 1466
				Vec2(inkX - 38 * s, inkY - 18 * s), -- 1467
				Vec2(inkX + 38 * s, inkY - 18 * s), -- 1468
				Vec2(inkX + 32 * s, inkY + 18 * s), -- 1469
				Vec2(inkX - 32 * s, inkY + 18 * s) -- 1470
			}, -- 1470
			Color(38, 44, 52, 255), -- 1471
			1.2, -- 1471
			Color(96, 106, 118, 185) -- 1471
		) -- 1471
	end -- 1471
	local lx = isLowpoly and ox + lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s or ox + ____exports.TOWER_SHOT_LAYOUT.lampDeskX * s -- 1475
	local ly = isLowpoly and oy + (lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34) * s or oy + ____exports.TOWER_SHOT_LAYOUT.lampDeskY * s -- 1478
	local lampWarmth = isLowpoly and 0.45 + 0.55 * lampProg or 0.92 -- 1481
	if not paintedRoomOk then -- 1481
		self:drawMingLantern( -- 1483
			uiInkDraw, -- 1483
			uiGlow, -- 1483
			lx, -- 1483
			ly, -- 1483
			1.02 * s, -- 1483
			1, -- 1483
			lampWarmth -- 1483
		) -- 1483
	elseif isLowpoly then -- 1483
		local moveVis = lampProg < 0.92 and 1 - smoothstep(0.75, 0.96, lampProg) or 0 -- 1486
		if moveVis > 0.03 then -- 1486
			self:drawMingLantern( -- 1488
				uiInkDraw, -- 1488
				uiGlow, -- 1488
				lx, -- 1488
				ly, -- 1488
				0.92 * s, -- 1488
				moveVis * 0.92, -- 1488
				lampWarmth -- 1488
			) -- 1488
		end -- 1488
		local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 1490
		fillRadialGlow( -- 1491
			uiGlow, -- 1492
			lx, -- 1493
			ly + 4 * s, -- 1494
			118 * s * flicker * (0.65 + 0.45 * lampProg), -- 1495
			118 * s * flicker * (0.65 + 0.45 * lampProg), -- 1496
			Color( -- 1497
				250, -- 1497
				208, -- 1497
				132, -- 1497
				math.floor((78 + 56 * lampProg) * flicker + 0.5) -- 1497
			), -- 1497
			Color(228, 162, 74, 0), -- 1498
			16 -- 1499
		) -- 1499
	else -- 1499
		local flicker = 0.92 + 0.08 * math.sin(self.animTime * 6.8) -- 1503
		fillRadialGlow( -- 1504
			uiGlow, -- 1505
			ox + 266 * s, -- 1506
			oy + 272 * s, -- 1507
			148 * s * flicker, -- 1508
			138 * s * flicker, -- 1509
			Color( -- 1510
				252, -- 1510
				212, -- 1510
				138, -- 1510
				math.floor(88 * flicker + 0.5) -- 1510
			), -- 1510
			Color(232, 168, 76, 0), -- 1511
			16 -- 1512
		) -- 1512
	end -- 1512
	if isLowpoly and lampProg > 0.04 then -- 1512
		local beamA = math.floor(62 * lampProg + 0.5) -- 1518
		fillGradQuad( -- 1519
			uiGlow, -- 1520
			lx + 10 * s, -- 1521
			ly + 30 * s, -- 1521
			Color(248, 206, 134, beamA), -- 1521
			lx + 10 * s, -- 1522
			ly - 32 * s, -- 1522
			Color( -- 1522
				248, -- 1522
				206, -- 1522
				134, -- 1522
				math.floor(beamA * 0.72 + 0.5) -- 1522
			), -- 1522
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.92) * s, -- 1523
			oy + (____exports.TOWER_SHOT_LAYOUT.row2Y - 58) * s, -- 1523
			Color(242, 198, 124, 0), -- 1523
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.85) * s, -- 1524
			oy + (____exports.TOWER_SHOT_LAYOUT.row1Y + 48) * s, -- 1524
			Color(242, 198, 124, 0) -- 1524
		) -- 1524
	end -- 1524
	local bookReveal = smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t) -- 1529
	if bookReveal > 0.02 then -- 1529
		self:drawRegisterBook( -- 1531
			uiDraw, -- 1531
			uiInkDraw, -- 1531
			uiArt, -- 1531
			uiGlow, -- 1531
			ctx, -- 1531
			route, -- 1531
			bookReveal, -- 1531
			lampProg, -- 1531
			s, -- 1531
			ox, -- 1531
			oy -- 1531
		) -- 1531
	end -- 1531
	self:drawDeskPropsAndBowl( -- 1535
		uiDraw, -- 1535
		uiInkDraw, -- 1535
		uiArt, -- 1535
		uiGlow, -- 1535
		ctx, -- 1535
		route, -- 1535
		s, -- 1535
		ox, -- 1535
		oy -- 1535
	) -- 1535
end -- 1414
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, lampProg, s, ox, oy) -- 1538
	local scaleCover = math.max(ctx.uiW / 960, ctx.uiH / 540) -- 1548
	local imgW = 960 * scaleCover -- 1549
	local imgH = 540 * scaleCover -- 1550
	local placedCold = uiArt:tryPlacePath( -- 1551
		"assets/art/cg_tower_desk_cold.png", -- 1552
		"fe05_f03_bg_cold", -- 1553
		ctx.uiW * 0.5, -- 1554
		ctx.uiH * 0.5, -- 1555
		imgW, -- 1556
		imgH, -- 1557
		{ -- 1558
			anchorX = 0.5, -- 1559
			anchorY = 0.5, -- 1560
			color = Color( -- 1561
				math.floor(212 + 43 * lampProg + 0.5), -- 1562
				math.floor(220 + 22 * lampProg + 0.5), -- 1563
				math.floor(238 - 36 * lampProg + 0.5), -- 1564
				255 -- 1565
			), -- 1565
			opacity = 1, -- 1567
			smooth = true, -- 1568
			layer = -8 -- 1569
		} -- 1569
	) -- 1569
	if placedCold then -- 1569
		if lampProg > 0.02 then -- 1569
			local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1575
			local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1576
			local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1577
			fillRadialGlow( -- 1578
				uiGlow, -- 1579
				wx + ww * 0.58, -- 1579
				wy + 22 * s, -- 1579
				580 * s, -- 1580
				420 * s, -- 1580
				Color( -- 1581
					248, -- 1581
					198, -- 1581
					122, -- 1581
					math.floor(92 * lampProg + 0.5) -- 1581
				), -- 1581
				Color(216, 152, 68, 0), -- 1582
				20 -- 1583
			) -- 1583
		end -- 1583
		return true -- 1586
	end -- 1586
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1590
	local wallTop = lerpRGBA( -- 1591
		rgba(18, 24, 38, 255), -- 1591
		rgba(46, 36, 28, 255), -- 1591
		lampProg -- 1591
	) -- 1591
	local wallBot = lerpRGBA( -- 1592
		rgba(12, 16, 26, 255), -- 1592
		rgba(28, 22, 20, 255), -- 1592
		lampProg -- 1592
	) -- 1592
	fillVGradRect( -- 1593
		uiDraw, -- 1593
		0, -- 1593
		0, -- 1593
		ctx.uiW, -- 1593
		ctx.uiH, -- 1593
		toColor(wallBot), -- 1593
		toColor(wallTop) -- 1593
	) -- 1593
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1594
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1595
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1596
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1597
	fillVGradRect( -- 1598
		uiDraw, -- 1598
		wx, -- 1598
		wy, -- 1598
		ww, -- 1598
		wh, -- 1598
		Color(34, 44, 62, 255), -- 1598
		Color(16, 24, 40, 255) -- 1598
	) -- 1598
	local sillCol = shadeSurface( -- 1599
		MING_MATERIALS.mingStoneStep.base, -- 1599
		vec3(0, 0.94, -0.34), -- 1599
		6, -- 1599
		1, -- 1599
		light, -- 1599
		MING_MATERIALS.mingStoneStep -- 1599
	) -- 1599
	uiDraw:drawRect( -- 1600
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1600
		toColor(sillCol) -- 1600
	) -- 1600
	return false -- 1601
end -- 1538
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1604
	local scaleCover = math.max(ctx.uiW / 960, ctx.uiH / 540) -- 1613
	local imgW = 960 * scaleCover -- 1614
	local imgH = 540 * scaleCover -- 1615
	local placedWarm = uiArt:tryPlacePath( -- 1616
		"assets/art/cg_tower_desk_warm.png", -- 1617
		"fe05_m03_bg_warm", -- 1618
		ctx.uiW * 0.5, -- 1619
		ctx.uiH * 0.5, -- 1620
		imgW, -- 1621
		imgH, -- 1622
		{ -- 1623
			anchorX = 0.5, -- 1624
			anchorY = 0.5, -- 1625
			opacity = 1, -- 1626
			smooth = true, -- 1627
			layer = -8 -- 1628
		} -- 1628
	) -- 1628
	if placedWarm then -- 1628
		fillRadialGlow( -- 1632
			uiGlow, -- 1633
			ox + 260 * s, -- 1633
			oy + 416 * s, -- 1633
			520 * s, -- 1634
			360 * s, -- 1634
			Color(246, 202, 134, 62), -- 1635
			Color(220, 158, 76, 0), -- 1636
			20 -- 1637
		) -- 1637
		return true -- 1639
	end -- 1639
	fillVGradRect( -- 1642
		uiDraw, -- 1643
		0, -- 1643
		0, -- 1643
		ctx.uiW, -- 1643
		ctx.uiH, -- 1643
		Color(26, 21, 20, 255), -- 1644
		Color(46, 36, 30, 255) -- 1645
	) -- 1645
	local groupX = ox + 210 * s -- 1647
	local groupY = oy + 300 * s -- 1648
	uiArt:tryPlace( -- 1649
		"soldier_idle", -- 1649
		"fe05_m03_room_soldier", -- 1649
		groupX - 38 * s, -- 1649
		groupY, -- 1649
		118 * s, -- 1649
		166 * s, -- 1649
		{facing = 1, opacity = 0.9, layer = 1} -- 1649
	) -- 1649
	uiArt:tryPlace( -- 1652
		"child_idle", -- 1652
		"fe05_m03_room_child", -- 1652
		groupX + 42 * s, -- 1652
		groupY, -- 1652
		86 * s, -- 1652
		116 * s, -- 1652
		{facing = 1, opacity = 0.92, layer = 1} -- 1652
	) -- 1652
	return false -- 1655
end -- 1604
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1658
	local t = self.seqElapsed -- 1671
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1672
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1673
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1674
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1675
	local midX = bx + bw * 0.5 -- 1676
	local midY = by + bh * 0.5 -- 1677
	uiDraw:drawRect( -- 1680
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1680
		Color( -- 1680
			10, -- 1680
			11, -- 1680
			16, -- 1680
			math.floor(108 * reveal + 0.5) -- 1680
		) -- 1680
	) -- 1680
	uiDraw:drawRect( -- 1681
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1681
		Color( -- 1681
			32, -- 1681
			46, -- 1681
			62, -- 1681
			math.floor(235 * reveal + 0.5) -- 1681
		), -- 1681
		1, -- 1681
		Color( -- 1681
			86, -- 1681
			104, -- 1681
			124, -- 1681
			math.floor(165 * reveal + 0.5) -- 1681
		) -- 1681
	) -- 1681
	if not uiArt:tryPlace( -- 1681
		"ink_song_paper", -- 1684
		"fe05_registry_paper", -- 1684
		midX, -- 1684
		midY, -- 1684
		bw, -- 1684
		bh, -- 1684
		{opacity = 0.98 * reveal, layer = 1} -- 1684
	) then -- 1684
		uiDraw:drawRect( -- 1685
			Rect(bx, by, bw, bh), -- 1686
			toColor( -- 1687
				PALETTE.xuanPaper, -- 1687
				math.floor(248 * reveal + 0.5) -- 1687
			), -- 1687
			1, -- 1688
			toColor( -- 1689
				PALETTE.silkDim, -- 1689
				math.floor(180 * reveal + 0.5) -- 1689
			) -- 1689
		) -- 1689
	end -- 1689
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1694
	fillRadialGlow( -- 1695
		uiGlow, -- 1696
		bx + bw * 0.34, -- 1696
		by + bh * 0.48, -- 1696
		bw * 0.58, -- 1697
		bh * 0.52, -- 1697
		Color( -- 1698
			246, -- 1698
			214, -- 1698
			156, -- 1698
			math.floor(44 * paperWarm * reveal + 0.5) -- 1698
		), -- 1698
		Color(238, 198, 128, 0), -- 1699
		16 -- 1700
	) -- 1700
	local padX = 44 * s -- 1704
	local padY = 32 * s -- 1705
	local inX = bx + padX -- 1706
	local inY = by + padY -- 1707
	local inW = bw - padX * 2 -- 1708
	local inH = bh - padY * 2 -- 1709
	local redSilk = toColor( -- 1710
		PALETTE.rouge, -- 1710
		math.floor(132 * reveal + 0.5) -- 1710
	) -- 1710
	local redFaint = toColor( -- 1711
		PALETTE.rouge, -- 1711
		math.floor(70 * reveal + 0.5) -- 1711
	) -- 1711
	uiInkDraw:drawRect( -- 1712
		Rect(inX, inY, inW, inH), -- 1712
		Color(0, 0, 0, 0), -- 1712
		1, -- 1712
		redSilk -- 1712
	) -- 1712
	uiInkDraw:drawRect( -- 1713
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1713
		Color(0, 0, 0, 0), -- 1713
		0.6, -- 1713
		redFaint -- 1713
	) -- 1713
	local headY = inY + inH - 28 * s -- 1716
	ctx.texts:put( -- 1717
		"md", -- 1717
		"北塔值夜收籍 · 末页", -- 1717
		inX + 18 * s, -- 1717
		headY, -- 1717
		toColor(PALETTE.xuanInk), -- 1717
		0, -- 1717
		0.5, -- 1717
		"Left", -- 1717
		2.2, -- 1717
		0.96 * reveal, -- 1717
		0 -- 1717
	) -- 1717
	ctx.texts:put( -- 1718
		"xs", -- 1718
		"宁村北塔", -- 1718
		inX + inW - 18 * s, -- 1718
		headY, -- 1718
		toColor(PALETTE.xuanInkSub), -- 1718
		1, -- 1718
		0.5, -- 1718
		"Right", -- 1718
		1.8, -- 1718
		0.8 * reveal, -- 1718
		0 -- 1718
	) -- 1718
	uiInkDraw:drawSegment( -- 1719
		Vec2(inX + 14 * s, headY - 22 * s), -- 1719
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1719
		0.9, -- 1719
		redSilk -- 1719
	) -- 1719
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1722
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1723
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1724
	ctx.texts:put( -- 1725
		"sm", -- 1725
		"肆拾壹", -- 1725
		inX + 18 * s, -- 1725
		row1Y, -- 1725
		toColor(PALETTE.rouge), -- 1725
		0, -- 1725
		0.5, -- 1725
		"Left", -- 1725
		1, -- 1725
		0.94 * reveal, -- 1725
		0 -- 1725
	) -- 1725
	if r1Prog > 0.02 then -- 1725
		ctx.texts:put( -- 1727
			"md", -- 1727
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1727
			inX + 96 * s, -- 1727
			row1Y, -- 1727
			toColor(PALETTE.xuanInk), -- 1727
			0, -- 1727
			0.5, -- 1727
			"Left", -- 1727
			1.6, -- 1727
			0.96 * math.min(1, r1Prog * 1.4), -- 1727
			0 -- 1727
		) -- 1727
	end -- 1727
	if r1Prog > 0.65 then -- 1727
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1730
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1731
		ctx.texts:put( -- 1734
			"xs", -- 1734
			subText, -- 1734
			inX + 96 * s, -- 1734
			row1SubY, -- 1734
			toColor(PALETTE.xuanInkSub), -- 1734
			0, -- 1734
			0.5, -- 1734
			"Left", -- 1734
			0.6, -- 1734
			0.88 * subA, -- 1734
			0 -- 1734
		) -- 1734
	end -- 1734
	uiInkDraw:drawSegment( -- 1736
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1736
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1736
		0.7, -- 1736
		redFaint -- 1736
	) -- 1736
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1739
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1740
	ctx.texts:put( -- 1741
		"sm", -- 1741
		"肆拾贰", -- 1741
		inX + 18 * s, -- 1741
		row2Y, -- 1741
		toColor(PALETTE.rouge), -- 1741
		0, -- 1741
		0.5, -- 1741
		"Left", -- 1741
		1, -- 1741
		0.94 * reveal, -- 1741
		0 -- 1741
	) -- 1741
	if route == "child" then -- 1741
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1745
		uiInkDraw:drawSegment( -- 1746
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1747
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1748
			1, -- 1749
			toColor(PALETTE.xuanInkSub, lineA) -- 1750
		) -- 1750
	else -- 1750
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1754
		if r2Prog <= 0.02 then -- 1754
			uiInkDraw:drawSegment( -- 1756
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1757
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1758
				0.9, -- 1759
				toColor( -- 1760
					PALETTE.xuanInkSub, -- 1760
					math.floor(105 * reveal + 0.5) -- 1760
				) -- 1760
			) -- 1760
		else -- 1760
			ctx.texts:put( -- 1763
				"md", -- 1763
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1763
				inX + 96 * s, -- 1763
				row2Y, -- 1763
				toColor(PALETTE.xuanInk), -- 1763
				0, -- 1763
				0.5, -- 1763
				"Left", -- 1763
				1.6, -- 1763
				0.96 * math.min(1, r2Prog * 1.4), -- 1763
				0 -- 1763
			) -- 1763
			if r2Prog > 0.65 then -- 1763
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1765
				ctx.texts:put( -- 1766
					"xs", -- 1766
					"守城戍卒亲口报出姓名，两人俱安。", -- 1766
					inX + 96 * s, -- 1766
					row2SubY, -- 1766
					toColor(PALETTE.xuanInkSub), -- 1766
					0, -- 1766
					0.5, -- 1766
					"Left", -- 1766
					0.6, -- 1766
					0.88 * subA, -- 1766
					0 -- 1766
				) -- 1766
			end -- 1766
		end -- 1766
	end -- 1766
	uiInkDraw:drawSegment( -- 1770
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1770
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1770
		0.7, -- 1770
		redFaint -- 1770
	) -- 1770
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1773
	if colophonA > 0.02 then -- 1773
		local signY = inY + 34 * s -- 1775
		ctx.texts:put( -- 1776
			"banner", -- 1776
			"向西守望", -- 1776
			midX - 24 * s, -- 1776
			signY, -- 1776
			toColor(PALETTE.xuanInk), -- 1776
			0.5, -- 1776
			0.5, -- 1776
			"Center", -- 1776
			6, -- 1776
			0.88 * colophonA, -- 1776
			0 -- 1776
		) -- 1776
	end -- 1776
	self:drawGuardBrushHand( -- 1780
		uiInkDraw, -- 1780
		uiArt, -- 1780
		route, -- 1780
		s, -- 1780
		ox, -- 1780
		oy -- 1780
	) -- 1780
end -- 1658
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, uiArt, route, s, ox, oy) -- 1783
	local t = self.seqElapsed -- 1791
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1792
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1793
	local row1X0 = hoverX -- 1794
	local row1X1 = hoverX + 142 * s -- 1795
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1796
	local tipX = hoverX -- 1798
	local tipY = hoverY -- 1799
	local alpha = 0 -- 1800
	local lifted = 0 -- 1801
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1801
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1805
		tipX = lerp(row1X0, row1X1, k) -- 1806
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1807
		alpha = smoothstep(2, 2.2, t) -- 1808
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1809
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1809
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1812
		tipX = lerp(row1X1, hoverX, moveK) -- 1813
		tipY = lerp(row1Y, hoverY, moveK) -- 1814
		alpha = 1 -- 1815
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1816
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1816
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1819
		tipX = hoverX + outK * 140 * s -- 1820
		tipY = hoverY + outK * 46 * s -- 1821
		lifted = (9 + outK * 28) * s -- 1822
		alpha = 1 - outK -- 1823
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1823
		if t < 4.6 then -- 1823
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1827
			tipX = hoverX -- 1828
			tipY = hoverY -- 1829
			lifted = lerp(9 * s, 0, dipK) -- 1830
			alpha = 1 -- 1831
		elseif t < 5.55 then -- 1831
			local wK = smoothstep(4.6, 5.55, t) -- 1833
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1834
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1835
			lifted = 0 -- 1836
			alpha = 1 -- 1837
		else -- 1837
			local outK = smoothstep(5.55, 6.05, t) -- 1839
			tipX = hoverX + 216 * s + outK * 115 * s -- 1840
			tipY = hoverY + outK * 52 * s -- 1841
			lifted = outK * 24 * s -- 1842
			alpha = 1 - outK -- 1843
		end -- 1843
	end -- 1843
	if alpha <= 0.02 then -- 1843
		return -- 1848
	end -- 1848
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1851
	local bx = tipX -- 1852
	local by = tipY + lifted -- 1853
	uiInkDraw:drawEllipse( -- 1855
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1855
		(5 + lifted * 0.22) * s, -- 1855
		2.8 * s, -- 1855
		Color( -- 1855
			20, -- 1855
			18, -- 1855
			16, -- 1855
			math.floor(78 * alpha + 0.5) -- 1855
		) -- 1855
	) -- 1855
	if uiArt:tryPlacePath( -- 1855
		"assets/art/cutscene_story_parts.clip|guard_brush_hand", -- 1858
		"fe05_guard_brush_hand", -- 1859
		bx, -- 1860
		by, -- 1861
		344 * s, -- 1862
		268 * s, -- 1863
		{ -- 1864
			anchorX = 0.03, -- 1865
			anchorY = 0.03, -- 1866
			opacity = clamp01(alpha), -- 1867
			smooth = true, -- 1868
			layer = 6 -- 1869
		} -- 1869
	) then -- 1869
		return -- 1872
	end -- 1872
	uiInkDraw:drawPolygon( -- 1875
		{ -- 1875
			Vec2(bx, by), -- 1876
			Vec2(bx + 15 * s, by - 4 * s), -- 1877
			Vec2(bx + 10 * s, by + 8 * s) -- 1878
		}, -- 1878
		Color(22, 22, 26, a) -- 1879
	) -- 1879
	uiInkDraw:drawSegment( -- 1880
		Vec2(bx + 12 * s, by + 2 * s), -- 1880
		Vec2(bx + 122 * s, by + 34 * s), -- 1880
		6.8 * s, -- 1880
		Color(142, 110, 74, a) -- 1880
	) -- 1880
end -- 1783
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1883
	local t = self.seqElapsed -- 1894
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1895
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1896
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1897
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1898
	if route == "child" then -- 1898
		local propA = smoothstep(1.55, 2.05, t) -- 1901
		if propA > 0.02 then -- 1901
			self:drawNeedleCaseOnDesk( -- 1903
				uiDraw, -- 1903
				uiInkDraw, -- 1903
				uiArt, -- 1903
				ncX + 42 * s, -- 1903
				ncY - 22 * s, -- 1903
				s, -- 1903
				propA, -- 1903
				true -- 1903
			) -- 1903
		end -- 1903
		local noteReadA = smoothstep(1.65, 2.1, t) * (1 - smoothstep(3.65, 4.15, t)) -- 1905
		if noteReadA > 0.02 then -- 1905
			local cardX = ncX + 52 * s -- 1907
			local cardY = ncY + 72 * s -- 1908
			uiInkDraw:drawRect( -- 1909
				Rect(cardX - 118 * s, cardY - 30 * s, 236 * s, 60 * s), -- 1910
				toColor( -- 1911
					PALETTE.xuanPaper, -- 1911
					math.floor(238 * noteReadA + 0.5) -- 1911
				), -- 1911
				1, -- 1912
				toColor( -- 1913
					PALETTE.rouge, -- 1913
					math.floor(110 * noteReadA + 0.5) -- 1913
				) -- 1913
			) -- 1913
			ctx.texts:put( -- 1915
				"xs", -- 1915
				NEEDLE_NOTE_LINES[1], -- 1915
				cardX, -- 1915
				cardY + 10 * s, -- 1915
				toColor(PALETTE.xuanInk), -- 1915
				0.5, -- 1915
				0.5, -- 1915
				"Center", -- 1915
				0.6, -- 1915
				0.94 * noteReadA, -- 1915
				0 -- 1915
			) -- 1915
			ctx.texts:put( -- 1916
				"xs", -- 1916
				"—— " .. NEEDLE_NOTE_LINES[2], -- 1916
				cardX + 74 * s, -- 1916
				cardY - 12 * s, -- 1916
				toColor(PALETTE.xuanInkSub), -- 1916
				1, -- 1916
				0.5, -- 1916
				"Right", -- 1916
				0.8, -- 1916
				0.88 * noteReadA, -- 1916
				0 -- 1916
			) -- 1916
		end -- 1916
		local bowlK = smoothstep(4.35, 5.15, t) -- 1918
		if bowlK > 0.02 then -- 1918
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1920
			self:drawWarmPorcelainBowl( -- 1921
				uiDraw, -- 1921
				uiInkDraw, -- 1921
				uiArt, -- 1921
				uiGlow, -- 1921
				bx, -- 1921
				bowlY, -- 1921
				s, -- 1921
				bowlK, -- 1921
				false, -- 1921
				0 -- 1921
			) -- 1921
		end -- 1921
	else -- 1921
		local needleK = smoothstep(5.45, 6.15, t) -- 1924
		if needleK > 0.02 then -- 1924
			local ny = lerp(ncY + 26 * s, ncY - 22 * s, needleK) -- 1926
			self:drawNeedleCaseOnDesk( -- 1927
				uiDraw, -- 1927
				uiInkDraw, -- 1927
				uiArt, -- 1927
				ncX + 64 * s, -- 1927
				ny, -- 1927
				s, -- 1927
				needleK, -- 1927
				false -- 1927
			) -- 1927
		end -- 1927
		local bowlK = smoothstep(5.8, 6.65, t) -- 1929
		if bowlK > 0.02 then -- 1929
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1931
			local handsK = smoothstep(5.95, 6.75, t) -- 1932
			self:drawWarmPorcelainBowl( -- 1933
				uiDraw, -- 1933
				uiInkDraw, -- 1933
				uiArt, -- 1933
				uiGlow, -- 1933
				bowlX, -- 1933
				by, -- 1933
				s, -- 1933
				bowlK, -- 1933
				true, -- 1933
				handsK -- 1933
			) -- 1933
		end -- 1933
		local cuffK = smoothstep(4.25, 4.85, t) -- 1936
		if cuffK > 0.02 then -- 1936
			drawPatchedCuff(uiInkDraw, uiGlow, { -- 1938
				wristX = ox + 116 * s, -- 1939
				wristY = oy + 168 * s, -- 1940
				angleRad = 0.06, -- 1941
				scale = 0.74 * s, -- 1942
				pose = "open", -- 1943
				opacity = 0.94 * cuffK, -- 1944
				stitchHighlight = 0.34, -- 1945
				warmth = 0.72, -- 1946
				uiArt = uiArt, -- 1947
				instanceKey = "fe05_m03_desk_cuff", -- 1948
				layer = 5 -- 1949
			}) -- 1949
		end -- 1949
	end -- 1949
end -- 1883
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, bgDraw, inkDraw, uiArt, cx, cy, s, alpha, withNote) -- 1956
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1966
	bgDraw:drawEllipse( -- 1967
		Vec2(cx + 4 * s, cy - 32 * s), -- 1967
		44 * s, -- 1967
		12 * s, -- 1967
		Color( -- 1967
			10, -- 1967
			10, -- 1967
			14, -- 1967
			math.floor(130 * alpha + 0.5) -- 1967
		) -- 1967
	) -- 1967
	if not uiArt:tryPlacePath( -- 1967
		"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 1969
		"fe05_desk_needle_pouch", -- 1970
		cx, -- 1971
		cy + 4 * s, -- 1972
		100 * s, -- 1973
		102 * s, -- 1974
		{ -- 1975
			anchorX = 0.5, -- 1976
			anchorY = 0.5, -- 1977
			angle = -10, -- 1978
			opacity = clamp01(alpha), -- 1979
			smooth = true, -- 1980
			layer = 5 -- 1981
		} -- 1981
	) then -- 1981
		inkDraw:drawPolygon( -- 1984
			{ -- 1984
				Vec2(cx - 32 * s, cy - 12 * s), -- 1985
				Vec2(cx + 26 * s, cy - 15 * s), -- 1986
				Vec2(cx + 30 * s, cy + 16 * s), -- 1987
				Vec2(cx - 28 * s, cy + 18 * s) -- 1988
			}, -- 1988
			Color(148, 124, 92, a), -- 1989
			1.3, -- 1989
			Color(88, 70, 50, a) -- 1989
		) -- 1989
	end -- 1989
	if withNote then -- 1989
		inkDraw:drawPolygon( -- 1993
			{ -- 1993
				Vec2(cx + 42 * s, cy - 18 * s), -- 1994
				Vec2(cx + 100 * s, cy - 12 * s), -- 1995
				Vec2(cx + 94 * s, cy + 24 * s), -- 1996
				Vec2(cx + 38 * s, cy + 18 * s) -- 1997
			}, -- 1997
			toColor(PALETTE.xuanPaper, a), -- 1998
			1, -- 1998
			toColor( -- 1998
				PALETTE.xuanInkSub, -- 1998
				math.floor(160 * alpha + 0.5) -- 1998
			) -- 1998
		) -- 1998
		inkDraw:drawSegment( -- 1999
			Vec2(cx + 50 * s, cy + 8 * s), -- 1999
			Vec2(cx + 84 * s, cy + 11 * s), -- 1999
			1.2 * s, -- 1999
			toColor( -- 1999
				PALETTE.xuanInk, -- 1999
				math.floor(170 * alpha + 0.5) -- 1999
			) -- 1999
		) -- 1999
		inkDraw:drawSegment( -- 2000
			Vec2(cx + 50 * s, cy - 2 * s), -- 2000
			Vec2(cx + 80 * s, cy + 1 * s), -- 2000
			1.2 * s, -- 2000
			toColor( -- 2000
				PALETTE.xuanInk, -- 2000
				math.floor(160 * alpha + 0.5) -- 2000
			) -- 2000
		) -- 2000
	end -- 2000
end -- 1956
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, bgDraw, inkDraw, uiArt, glow, cx, cy, s, alpha, heldByTwoHands, handsK) -- 2005
	local op = clamp01(alpha) -- 2017
	bgDraw:drawEllipse( -- 2018
		Vec2(cx, cy - 46 * s), -- 2018
		64 * s, -- 2018
		14 * s, -- 2018
		Color( -- 2018
			8, -- 2018
			9, -- 2018
			14, -- 2018
			math.floor(138 * op + 0.5) -- 2018
		) -- 2018
	) -- 2018
	if not uiArt:tryPlacePath( -- 2018
		"assets/art/cutscene_story_parts.clip|porridge_bowl", -- 2020
		"fe05_desk_porridge_bowl", -- 2021
		cx, -- 2022
		cy - 4 * s, -- 2023
		162 * s, -- 2024
		124 * s, -- 2025
		{ -- 2026
			anchorX = 0.5, -- 2027
			anchorY = 0.5, -- 2028
			opacity = op, -- 2029
			smooth = true, -- 2030
			layer = 5 -- 2031
		} -- 2031
	) then -- 2031
		local a = math.floor(255 * op + 0.5) -- 2034
		inkDraw:drawEllipse( -- 2035
			Vec2(cx, cy + 8 * s), -- 2035
			64 * s, -- 2035
			21 * s, -- 2035
			Color(224, 218, 206, a) -- 2035
		) -- 2035
	end -- 2035
	local wi = 0 -- 2039
	do -- 2039
		wi = 0 -- 2040
		while wi < 4 do -- 2040
			local cyc = (self.animTime * 0.36 + wi * 0.25) % 1 -- 2041
			local sx = cx + (wi - 1.5) * 20 * s + math.sin(self.animTime * 1.4 + wi * 2.1) * (8 + cyc * 10) * s -- 2042
			local sy = cy + (24 + cyc * 58) * s -- 2043
			local sr = (18 + cyc * 24) * s -- 2044
			local wa = math.floor(math.sin(cyc * math.pi) * 34 * op + 0.5) -- 2045
			if wa > 2 then -- 2045
				fillRadialGlow( -- 2047
					glow, -- 2047
					sx, -- 2047
					sy, -- 2047
					sr, -- 2047
					sr * 1.35, -- 2047
					Color(246, 238, 224, wa), -- 2047
					Color(246, 238, 224, 0), -- 2047
					12 -- 2047
				) -- 2047
			end -- 2047
			wi = wi + 1 -- 2040
		end -- 2040
	end -- 2040
	if heldByTwoHands and handsK > 0.02 then -- 2040
		local liftY = (1 - handsK) * 36 * s -- 2053
		local handOp = clamp01(handsK * op) -- 2054
		uiArt:tryPlacePath( -- 2055
			"assets/art/cutscene_story_parts.clip|xiaoman_cup_hands", -- 2056
			"fe05_m03_xiaoman_cup_hands", -- 2057
			cx, -- 2058
			cy - 34 * s - liftY, -- 2059
			258 * s, -- 2060
			186 * s, -- 2061
			{ -- 2062
				anchorX = 0.5, -- 2063
				anchorY = 0.5, -- 2064
				opacity = handOp, -- 2065
				smooth = true, -- 2066
				layer = 6 -- 2067
			} -- 2067
		) -- 2067
	end -- 2067
end -- 2005
function TowerEndingsPlugin.prototype.drawMingLantern(self, draw, glow, cx, cy, scale, alpha, warmth) -- 2074
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 2083
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 2084
	draw:drawSegment( -- 2086
		Vec2(cx - 10 * scale, cy + 28 * scale), -- 2086
		Vec2(cx, cy + 40 * scale), -- 2086
		1.8 * scale, -- 2086
		Color(88, 86, 82, a) -- 2086
	) -- 2086
	draw:drawSegment( -- 2087
		Vec2(cx + 10 * scale, cy + 28 * scale), -- 2087
		Vec2(cx, cy + 40 * scale), -- 2087
		1.8 * scale, -- 2087
		Color(88, 86, 82, a) -- 2087
	) -- 2087
	draw:drawRect( -- 2089
		Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), -- 2089
		Color(62, 46, 34, a), -- 2089
		1, -- 2089
		Color(118, 92, 66, a) -- 2089
	) -- 2089
	draw:drawRect( -- 2090
		Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), -- 2090
		Color(62, 46, 34, a), -- 2090
		1, -- 2090
		Color(118, 92, 66, a) -- 2090
	) -- 2090
	draw:drawRect( -- 2092
		Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale), -- 2093
		Color( -- 2094
			238, -- 2094
			198, -- 2094
			132, -- 2094
			math.floor(230 * alpha * (0.75 + 0.25 * warmth) + 0.5) -- 2094
		), -- 2094
		1.4 * scale, -- 2095
		Color(94, 70, 48, a) -- 2096
	) -- 2096
	draw:drawSegment( -- 2098
		Vec2(cx, cy - 18 * scale), -- 2098
		Vec2(cx, cy + 22 * scale), -- 2098
		1.1 * scale, -- 2098
		Color( -- 2098
			94, -- 2098
			70, -- 2098
			48, -- 2098
			math.floor(150 * alpha + 0.5) -- 2098
		) -- 2098
	) -- 2098
	draw:drawEllipse( -- 2099
		Vec2(cx, cy + 2 * scale), -- 2099
		4.6 * scale * flicker, -- 2099
		8.5 * scale * flicker, -- 2099
		Color(255, 244, 212, a) -- 2099
	) -- 2099
	fillRadialGlow( -- 2101
		glow, -- 2102
		cx, -- 2102
		cy + 2 * scale, -- 2102
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2103
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2104
		Color( -- 2105
			250, -- 2105
			208, -- 2105
			132, -- 2105
			math.floor(128 * alpha * warmth + 0.5) -- 2105
		), -- 2105
		Color(228, 162, 74, 0), -- 2106
		16 -- 2107
	) -- 2107
end -- 2074
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 2111
	local line = self.lastSubtitle -- 2120
	if line ~= "" then -- 2120
		local cy = barH + 34 * s -- 2122
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 2123
		drawSilkVeil( -- 2124
			uiDraw, -- 2124
			uiArt, -- 2124
			"fe05_sub_veil", -- 2124
			ctx.uiW * 0.5, -- 2124
			cy, -- 2124
			stripW, -- 2124
			48 * s, -- 2124
			PALETTE.inkWash, -- 2124
			0.82, -- 2124
			3 -- 2124
		) -- 2124
		drawHairline( -- 2125
			uiInkDraw, -- 2125
			uiArt, -- 2125
			"fe05_sub_hair", -- 2125
			ctx.uiW * 0.5, -- 2125
			cy + 21 * s, -- 2125
			stripW * 0.68, -- 2125
			PALETTE.silkDim, -- 2125
			0.54, -- 2125
			true, -- 2125
			4 -- 2125
		) -- 2125
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 2126
		ctx.texts:put( -- 2127
			isSpoken and "md" or "sm", -- 2128
			line, -- 2129
			ctx.uiW * 0.5, -- 2130
			cy - 1 * s, -- 2131
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 2132
			0.5, -- 2133
			0.5, -- 2134
			"Center", -- 2135
			isSpoken and 1.8 or 1, -- 2136
			0.98, -- 2137
			0.08 -- 2138
		) -- 2138
	end -- 2138
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 2138
		local rawHint = route == "child" and "按 E 收页 · 尾声与史话   ·   Esc 暂歇" or "团圆尾声   ·   按 E 收页与史话   ·   Esc 暂歇" -- 2144
		local hint = getActiveTarget():adaptHintSentence(rawHint, ctx.input.inputMode, ctx.input.gamepadLayout) -- 2147
		ctx.texts:put( -- 2148
			"xs", -- 2148
			hint, -- 2148
			ctx.uiW * 0.5, -- 2148
			barH * 0.5, -- 2148
			toColor(PALETTE.textMid), -- 2148
			0.5, -- 2148
			0.5, -- 2148
			"Center", -- 2148
			1.4, -- 2148
			0.88, -- 2148
			0.08 -- 2148
		) -- 2148
	end -- 2148
end -- 2111
function ____exports.createTowerEndingsPlugin() -- 2153
	return __TS__New(____exports.TowerEndingsPlugin) -- 2154
end -- 2153
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 2158
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 2159
	fe:registerPlugin(plugin) -- 2160
	return plugin -- 2161
end -- 2158
return ____exports -- 2158