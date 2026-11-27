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
end -- 390
function TowerEndingsPlugin.prototype.resolveRoute(self, p, view) -- 431
	if self.rehearsalActive then -- 431
		return self.rehearsalRoute -- 433
	end -- 433
	if view.storyRoute == "soldier" then -- 433
		return "soldier" -- 436
	end -- 436
	if view.storyRoute == "child" then -- 436
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
	if storyRec ~= nil and storyRec.ending == "reunion" then -- 443
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
	if not keepIndoorDoorOpen then -- 457
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
	if contract ~= nil then -- 481
		contract:enterRehearsal(tag) -- 483
		contract:setMockRoute(route) -- 484
	end -- 484
	local isIndoor = (opts and opts.indoorRetry) == true -- 486
	self.sessionId = self.sessionId + 1 -- 487
	self:clearSequenceState(isIndoor) -- 488
	self.active = true -- 489
	self.doorClosedAfterRetry = false -- 490
	if isIndoor then -- 490
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 492
	end -- 492
	if (opts and opts.seekTime) ~= nil then -- 492
		self:seekRehearsal(opts.seekTime) -- 495
	end -- 495
end -- 473
function TowerEndingsPlugin.prototype.seekRehearsal(self, seconds) -- 500
	if not self.rehearsalActive then -- 500
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
	if not self.doorOpened and self.seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 513
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
	if contract ~= nil then -- 535
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
	if loaded == nil then -- 587
		return -- 589
	end -- 589
	local rawFe = loaded["watch.fe"] -- 591
	if rawFe ~= nil and type(rawFe) == "table" then -- 591
		local watchFe = rawFe -- 593
		if watchFe.towerEndings ~= self then -- 593
			watchFe.towerEndings = self -- 595
		end -- 595
	end -- 595
end -- 585
function TowerEndingsPlugin.prototype.onBindPlay(self, p, view) -- 602
	self:syncRuntimeHook() -- 603
	self.sessionId = self.sessionId + 1 -- 604
	self.loopsActive = false -- 605
	self.prevPhase = p.phase -- 606
	if self.rehearsalActive then -- 606
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
	if not isTower then -- 629
		self:clearSequenceState(false) -- 632
		self.indoorRetryCount = 0 -- 633
		self.doorClosedAfterRetry = false -- 634
		return -- 635
	end -- 635
	if sameRunIndoorRetry or alreadyCutscenePhase then -- 635
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 640
		self.doorClosedAfterRetry = false -- 641
		self:clearSequenceState(true) -- 642
		if p.phase == "tower-end" then -- 642
			self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.divergeEndSec -- 644
			self:syncDerivedMilestones(self.seqElapsed, route) -- 645
		end -- 645
		return -- 647
	end -- 647
	if p.phase == "tower-enter" or p.phase == "tower-desk" then -- 647
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
	if not self.rehearsalActive and p.room.key ~= "tower" then -- 669
		if self.loopsActive then -- 669
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 673
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 674
			self.loopsActive = false -- 675
		end -- 675
		self.active = false -- 677
		return -- 678
	end -- 678
	local route = self:resolveRoute(p, ctx.view) -- 681
	self.activeRoute = route -- 682
	if not self.rehearsalActive then -- 682
		self:stepLiveSync(ctx, route) -- 685
	else -- 685
		self:stepRehearsal(ctx, route) -- 687
	end -- 687
	if not self.active then -- 687
		local inInteractiveHall = not self.rehearsalActive and p.room.key == "tower" and (p.phase == "tower-enter" or p.phase == "tower-desk") -- 691
		if self.loopsActive and not inInteractiveHall then -- 691
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 694
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 695
			self.loopsActive = false -- 696
		end -- 696
		return -- 698
	end -- 698
	if not ctx.paused and ctx.worldDt > 0 then -- 698
		self.animTime = self.animTime + ctx.worldDt -- 703
		self:syncDerivedMilestones(self.seqElapsed, route) -- 704
		self:syncAudioCues(ctx.audio, ctx, route) -- 705
		self:stepInputGuard(ctx.input) -- 706
	elseif not ctx.paused then -- 706
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
	if phase == "tower-wait" then -- 723
		self.active = false -- 727
		return -- 728
	end -- 728
	if phase == "tower-enter" or phase == "tower-desk" then -- 728
		self.doorOpened = true -- 733
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 734
		if justEnteredEnter and self.indoorRetryCount == 0 and not ctx.paused then -- 734
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
	if not self.active then -- 744
		self.active = true -- 748
		self.staleInputMustRelease = ctx.input.interact.held or ctx.input.retry.held or ctx.input.interact.pressed -- 749
		self.confirmReady = false -- 750
	end -- 750
	if justEnteredKnock then -- 750
		self.seqElapsed = p.phaseTick / 60 -- 754
		self.holdElapsed = 0 -- 755
		self.staleInputMustRelease = true -- 756
		self.confirmReady = false -- 757
	elseif justEnteredGiven then -- 757
		self.doorOpened = true -- 759
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 760
	elseif justEnteredEnd then -- 760
		self.doorOpened = true -- 762
		self.seqElapsed = math.max(self.seqElapsed, 3.6) -- 764
	end -- 764
	if not ctx.paused and #ctx.events.rawEvents > 0 then -- 764
		local i = 0 -- 769
		do -- 769
			i = 0 -- 770
			while i < #ctx.events.rawEvents do -- 770
				local ev = ctx.events.rawEvents[i + 1] -- 771
				if ev.name == "knock" then -- 771
					local cnt = type(ev.data.count) == "number" and ev.data.count or self.knockCount + 1 -- 773
					if cnt >= 1 and self.knockCount < 1 then -- 773
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
					if cnt >= 2 and self.knockCount < 2 then -- 776
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
	if not ctx.paused and ctx.worldDt > 0 then -- 770
		if phase == "tower-knock" then -- 770
			local backendSec = math.min(____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60) -- 789
			self.seqElapsed = math.max(self.seqElapsed + ctx.worldDt, backendSec) -- 790
			if self.seqElapsed > ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 then -- 790
				self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 -- 792
			end -- 792
		else -- 792
			self.seqElapsed = self.seqElapsed + ctx.worldDt -- 795
			if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 795
				self.holdElapsed = self.holdElapsed + ctx.worldDt -- 797
			end -- 797
		end -- 797
	end -- 797
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 797
		self.doorClosedAfterRetry = true -- 803
	end -- 803
	self:syncDerivedMilestones(self.seqElapsed, route) -- 805
end -- 716
function TowerEndingsPlugin.prototype.stepRehearsal(self, ctx, route) -- 808
	self.active = true -- 809
	if not ctx.paused and ctx.worldDt > 0 then -- 809
		self.seqElapsed = self.seqElapsed + ctx.worldDt -- 811
		if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 811
			self.holdElapsed = self.holdElapsed + ctx.worldDt -- 813
		end -- 813
	end -- 813
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 813
		self.doorClosedAfterRetry = true -- 817
	end -- 817
	self:syncDerivedMilestones(self.seqElapsed, route) -- 819
end -- 808
function TowerEndingsPlugin.prototype.syncDerivedMilestones(self, t, route) -- 822
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec and self.knockCount < 1 then -- 822
		self.knockCount = 1 -- 824
	end -- 824
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec and self.knockCount < 2 then -- 824
		self.knockCount = 2 -- 827
	end -- 827
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec and self.replyKnockCount < 1 then -- 827
		self.replyKnockCount = 1 -- 830
	end -- 830
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec and self.replyKnockCount < 2 then -- 830
		self.replyKnockCount = 2 -- 833
	end -- 833
	if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 833
		self.doorOpened = true -- 836
	end -- 836
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec and not self.row1Written then -- 836
		self.row1Written = true -- 840
		self.registryAppendCount = self.registryAppendCount + 1 -- 841
	end -- 841
	if route == "soldier" and t >= 4.6 and not self.row2Written then -- 841
		self.row2Written = true -- 844
		self.registryAppendCount = self.registryAppendCount + 1 -- 845
	end -- 845
	if route == "child" and self.row2Written then -- 845
		self.row2Written = false -- 849
		self.registryAppendCount = self.row1Written and 1 or 0 -- 850
	end -- 850
end -- 822
function TowerEndingsPlugin.prototype.stepInputGuard(self, input) -- 854
	local keyHeld = input.interact.held or input.retry.held -- 855
	local keyPressed = input.interact.pressed or input.retry.pressed -- 856
	local readyTime = self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 857
	if self.staleInputMustRelease then -- 857
		if not keyHeld then -- 857
			self.staleInputMustRelease = false -- 861
		elseif keyPressed then -- 861
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 863
		end -- 863
		self.confirmReady = false -- 865
		return -- 866
	end -- 866
	if not readyTime then -- 866
		if keyPressed then -- 866
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 871
			self.staleInputMustRelease = keyHeld -- 872
		end -- 872
		self.confirmReady = false -- 874
		return -- 875
	end -- 875
	self.confirmReady = true -- 878
	if self.rehearsalActive and keyPressed then -- 878
		self.rehearsalAcknowledged = true -- 880
	end -- 880
end -- 854
function TowerEndingsPlugin.prototype.playTowerOnce(self, audio, tag, track, path, volume, cueId, tick, seq) -- 884
	if seq == nil then -- 884
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
	if indoorK > 0.05 then -- 905
		audio:playLoop( -- 907
			"tower_room_warm", -- 907
			"ambience", -- 907
			____exports.TOWER_AUDIO_FILES.roomWarm, -- 907
			lerp(0.06, 0.34, indoorK), -- 907
			tick -- 907
		) -- 907
	end -- 907
	if self.indoorRetryCount == 0 then -- 907
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec then -- 907
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
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec then -- 913
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
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 916
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
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec then -- 919
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
		if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 922
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
	if t >= 1.5 then -- 925
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
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 930
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
	if route == "child" then -- 933
		if t >= 4.35 then -- 933
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
		if t >= 4.45 then -- 938
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
		if t >= 5.2 then -- 941
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
		if t >= 4.28 then -- 944
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
		if t >= 4.62 then -- 948
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
		if t >= 5.55 then -- 951
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
		if t >= 6.02 then -- 954
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
	if t < ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 963
		return "[两下轻敲]  门外厚木上传来两声轻敲。" -- 965
	end -- 965
	if t < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 965
		return "[门内回敲]  静默一息，门后轻轻回敲两声。" -- 968
	end -- 968
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 968
		return route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 971
	end -- 971
	if t < ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 971
		return route == "child" and "她把针套与纸条摊在案前，守卒展开收籍末页。" or "两人站在值夜室内，守卒摊开收籍末页。" -- 976
	end -- 976
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 976
		return "守卒蘸墨提笔，在第一行写下「小满」。" -- 981
	end -- 981
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 981
		return "笔尖停在第二行上方。" -- 984
	end -- 984
	if route == "child" then -- 984
		if t < 6.7 then -- 984
			return F03_DIALOGUE -- 988
		end -- 988
		return "" -- 990
	end -- 990
	if t < 5.45 then -- 990
		return M03_DIALOGUE -- 993
	end -- 993
	if t < 6.85 then -- 993
		return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。" -- 996
	end -- 996
	return "" -- 998
end -- 962
function TowerEndingsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1003
	if not self.active then -- 1003
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
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1023
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
		if fadeOut > 0.01 then -- 1029
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
		if fadeIn > 0.01 then -- 1036
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
	if isLowpoly then -- 1083
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
						if lx > 4 * s and lx < doorL - 4 * s then -- 1179
							uiDraw:drawSegment( -- 1181
								Vec2(lx, by), -- 1181
								Vec2(lx, by + 46 * s), -- 1181
								0.9, -- 1181
								Color(36, 38, 44, 130) -- 1181
							) -- 1181
						end -- 1181
						local rx = doorR + stag + col * 68 * s -- 1183
						if rx > doorR + 4 * s and rx < ctx.uiW - 4 * s then -- 1183
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
	uiArt:tryPlacePath( -- 1195
		"assets/art/tex_diorama_ming.clip|ming_brick", -- 1195
		"fe05_porch_wall_l", -- 1195
		doorL * 0.5, -- 1195
		threshY + (ctx.uiH - threshY) * 0.5, -- 1195
		math.max(12, doorL), -- 1195
		math.max(12, ctx.uiH - threshY), -- 1195
		{ -- 1195
			color = isLowpoly and Color(86, 98, 114, 255) or Color(118, 114, 110, 255), -- 1196
			opacity = 0.42, -- 1197
			smooth = true, -- 1198
			layer = 0 -- 1199
		} -- 1199
	) -- 1199
	uiArt:tryPlacePath( -- 1201
		"assets/art/tex_diorama_ming.clip|ming_brick", -- 1201
		"fe05_porch_wall_r", -- 1201
		doorR + (ctx.uiW - doorR) * 0.5, -- 1201
		threshY + (ctx.uiH - threshY) * 0.5, -- 1201
		math.max(12, ctx.uiW - doorR), -- 1201
		math.max(12, ctx.uiH - threshY), -- 1201
		{ -- 1201
			color = isLowpoly and Color(86, 98, 114, 255) or Color(118, 114, 110, 255), -- 1202
			opacity = 0.42, -- 1203
			smooth = true, -- 1204
			layer = 0 -- 1205
		} -- 1205
	) -- 1205
	local innerWarm = 0.22 + openK * 0.78 + (r1Pulse + r2Pulse) * 0.14 -- 1209
	fillVGradRect( -- 1210
		uiDraw, -- 1211
		doorL, -- 1211
		threshY + 8 * s, -- 1211
		doorW, -- 1211
		doorH - 8 * s, -- 1211
		Color( -- 1212
			46, -- 1212
			32, -- 1212
			20, -- 1212
			math.floor(255 * math.min(1, innerWarm + 0.15) + 0.5) -- 1212
		), -- 1212
		Color( -- 1213
			118, -- 1213
			82, -- 1213
			42, -- 1213
			math.floor(255 * math.min(1, innerWarm) + 0.5) -- 1213
		) -- 1213
	) -- 1213
	local leafW = math.max(26 * s, doorW * (1 - openK * 0.76)) -- 1217
	local leafX = doorL + doorShakeX * (1 - openK) -- 1218
	if not uiArt:tryPlacePath( -- 1218
		"assets/art/cutscene_story_parts.clip|tower_porch_door", -- 1220
		"fe05_porch_door_leaf", -- 1221
		leafX + leafW * 0.5, -- 1222
		threshY + 10 * s, -- 1223
		leafW, -- 1224
		doorH - 12 * s, -- 1225
		{ -- 1226
			anchorX = 0.5, -- 1227
			anchorY = 0, -- 1228
			color = isLowpoly and Color(204, 212, 224, 255) or Color(238, 228, 214, 255), -- 1229
			opacity = 0.98, -- 1230
			smooth = true, -- 1231
			layer = 1 -- 1232
		} -- 1232
	) then -- 1232
		local woodCol = isLowpoly and toColor(shadeSurface( -- 1235
			MING_MATERIALS.mingTimberDark.base, -- 1236
			vec3(-0.2, 0.25, -0.95), -- 1236
			4, -- 1236
			1, -- 1236
			TOWER_WEST_LAMP_LIGHT, -- 1236
			MING_MATERIALS.mingTimberDark -- 1236
		)) or Color(76, 54, 38, 255) -- 1236
		uiDraw:drawRect( -- 1238
			Rect(leafX, threshY + 12 * s, leafW, doorH - 14 * s), -- 1239
			woodCol, -- 1240
			1.4, -- 1241
			Color(138, 106, 74, 185) -- 1242
		) -- 1242
	end -- 1242
	local seamGlowA = math.floor(92 + openK * 145 + (r1Pulse + r2Pulse) * 48 + 0.5) -- 1247
	fillRadialGlow( -- 1248
		uiGlow, -- 1249
		doorCx + openK * 24 * s, -- 1249
		threshY + 14 * s, -- 1249
		(92 + openK * 120) * s, -- 1250
		(26 + openK * 58) * s, -- 1250
		Color( -- 1251
			246, -- 1251
			204, -- 1251
			134, -- 1251
			math.min(220, seamGlowA) -- 1251
		), -- 1251
		Color(220, 156, 72, 0), -- 1252
		18 -- 1253
	) -- 1253
	local kx = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s -- 1257
	local ky = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s -- 1258
	if k1Pulse > 0.08 or k2Pulse > 0.08 then -- 1258
		local amp = math.max(k1Pulse, k2Pulse) -- 1260
		local r = (18 + (1 - amp) * 34) * s -- 1261
		strokeEllipse( -- 1262
			uiInkDraw, -- 1262
			kx + 24 * s, -- 1262
			ky, -- 1262
			r, -- 1262
			r * 0.85, -- 1262
			1.8 * s, -- 1262
			toColor( -- 1262
				PALETTE.amberCore, -- 1262
				math.floor(210 * amp + 0.5) -- 1262
			), -- 1262
			24 -- 1262
		) -- 1262
	end -- 1262
	if r1Pulse > 0.08 or r2Pulse > 0.08 then -- 1262
		local amp = math.max(r1Pulse, r2Pulse) -- 1265
		local r = (24 + (1 - amp) * 42) * s -- 1266
		strokeEllipse( -- 1267
			uiInkDraw, -- 1267
			doorCx + 30 * s, -- 1267
			ky + 16 * s, -- 1267
			r, -- 1267
			r * 0.9, -- 1267
			1.6 * s, -- 1267
			toColor( -- 1267
				PALETTE.amber, -- 1267
				math.floor(185 * amp + 0.5) -- 1267
			), -- 1267
			24 -- 1267
		) -- 1267
	end -- 1267
	if openK > 0.05 then -- 1267
		local lanX = ox + ____exports.TOWER_SHOT_LAYOUT.doorLanternX * s + (1 - openK) * 42 * s -- 1272
		local lanY = oy + ____exports.TOWER_SHOT_LAYOUT.doorLanternY * s -- 1273
		uiInkDraw:drawPolygon( -- 1275
			{ -- 1275
				Vec2(lanX + 76 * s, lanY + 42 * s), -- 1276
				Vec2(lanX + 12 * s, lanY + 34 * s), -- 1277
				Vec2(lanX + 8 * s, lanY + 12 * s), -- 1278
				Vec2(lanX + 78 * s, lanY + 12 * s) -- 1279
			}, -- 1279
			Color( -- 1280
				54, -- 1280
				48, -- 1280
				44, -- 1280
				math.floor(240 * openK + 0.5) -- 1280
			), -- 1280
			1, -- 1280
			Color( -- 1280
				98, -- 1280
				86, -- 1280
				74, -- 1280
				math.floor(180 * openK + 0.5) -- 1280
			) -- 1280
		) -- 1280
		self:drawMingLantern( -- 1281
			uiInkDraw, -- 1281
			uiGlow, -- 1281
			lanX, -- 1281
			lanY - 14 * s, -- 1281
			1.08 * s, -- 1281
			openK, -- 1281
			1 -- 1281
		) -- 1281
		fillRadialGlow( -- 1283
			uiGlow, -- 1284
			kx + 12 * s, -- 1284
			ky - 14 * s, -- 1284
			148 * s, -- 1285
			128 * s, -- 1285
			Color( -- 1286
				246, -- 1286
				208, -- 1286
				142, -- 1286
				math.floor(98 * openK + 0.5) -- 1286
			), -- 1286
			Color(232, 174, 92, 0), -- 1287
			18 -- 1288
		) -- 1288
	end -- 1288
	local stepInX = openK * 44 * s -- 1293
	local xiaomanX = doorCx - 66 * s + stepInX -- 1294
	local xiaomanY = threshY - 2 * s -- 1295
	uiDraw:drawEllipse( -- 1297
		Vec2(xiaomanX, xiaomanY + 2 * s), -- 1297
		34 * s, -- 1297
		8 * s, -- 1297
		Color(4, 6, 12, 190) -- 1297
	) -- 1297
	local childSlot = (k1Pulse > 0.25 or k2Pulse > 0.25) and "child_knock" or (openK > 0.45 and "child_offer" or "child_idle") -- 1298
	uiArt:tryPlace( -- 1299
		childSlot, -- 1299
		"fe05_porch_child", -- 1299
		xiaomanX, -- 1299
		xiaomanY, -- 1299
		108 * s, -- 1299
		148 * s, -- 1299
		{facing = 1, opacity = 0.98, layer = 2} -- 1299
	) -- 1299
	if openK > 0.15 then -- 1299
		local wristX = xiaomanX + 22 * s -- 1304
		local wristY = xiaomanY + 76 * s -- 1305
		uiInkDraw:drawRect( -- 1306
			Rect(wristX - 7 * s, wristY - 5 * s, 14 * s, 11 * s), -- 1307
			Color( -- 1308
				142, -- 1308
				118, -- 1308
				84, -- 1308
				math.floor(245 * openK + 0.5) -- 1308
			), -- 1308
			1, -- 1309
			Color( -- 1310
				222, -- 1310
				192, -- 1310
				128, -- 1310
				math.floor(235 * openK + 0.5) -- 1310
			) -- 1310
		) -- 1310
		uiInkDraw:drawSegment( -- 1312
			Vec2(wristX - 8 * s, wristY), -- 1313
			Vec2(wristX + 8 * s, wristY + 2 * s), -- 1314
			2 * s, -- 1315
			toColor( -- 1316
				CUFF_PALETTE.childCord, -- 1316
				math.floor(240 * openK + 0.5) -- 1316
			) -- 1316
		) -- 1316
	end -- 1316
	if route == "soldier" then -- 1316
		local zhouX = xiaomanX - 72 * s -- 1322
		local zhouY = threshY - 2 * s -- 1323
		uiDraw:drawEllipse( -- 1324
			Vec2(zhouX, zhouY + 2 * s), -- 1324
			42 * s, -- 1324
			9 * s, -- 1324
			Color(4, 6, 12, 190) -- 1324
		) -- 1324
		uiArt:tryPlace( -- 1325
			"soldier_idle", -- 1325
			"fe05_porch_soldier", -- 1325
			zhouX, -- 1325
			zhouY, -- 1325
			146 * s, -- 1325
			206 * s, -- 1325
			{facing = 1, opacity = 0.98, layer = 2} -- 1325
		) -- 1325
		local handMidX = (zhouX + xiaomanX) * 0.5 + 4 * s -- 1329
		local handMidY = threshY + 66 * s -- 1330
		uiInkDraw:drawSegment( -- 1331
			Vec2(zhouX + 20 * s, threshY + 106 * s), -- 1332
			Vec2(handMidX - 2 * s, handMidY), -- 1333
			6.2 * s, -- 1334
			toColor(CUFF_PALETTE.indigoBase, 245) -- 1335
		) -- 1335
		uiInkDraw:drawSegment( -- 1337
			Vec2(handMidX - 9 * s, handMidY + 9 * s), -- 1338
			Vec2(handMidX - 3 * s, handMidY + 13 * s), -- 1339
			1.9 * s, -- 1340
			toColor(CUFF_PALETTE.stitchThread, 240) -- 1341
		) -- 1341
		uiInkDraw:drawSegment( -- 1343
			Vec2(xiaomanX - 14 * s, threshY + 78 * s), -- 1344
			Vec2(handMidX + 2 * s, handMidY), -- 1345
			4.8 * s, -- 1346
			toColor(CUFF_PALETTE.childSleeve, 245) -- 1347
		) -- 1347
		uiInkDraw:drawDot( -- 1349
			Vec2(handMidX, handMidY), -- 1349
			4.8 * s, -- 1349
			toColor(CUFF_PALETTE.skinLight, 245) -- 1349
		) -- 1349
	end -- 1349
end -- 1057
function TowerEndingsPlugin.prototype.drawAct2And3Guardroom(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy) -- 1355
	local t = self.seqElapsed -- 1367
	local isLowpoly = route == "child" -- 1368
	local deskY = oy + ____exports.TOWER_SHOT_LAYOUT.deskTopY * s -- 1369
	local ____isLowpoly_9 -- 1372
	if isLowpoly then -- 1372
		____isLowpoly_9 = self:drawF03LowpolyRoomAndWindow( -- 1373
			uiDraw, -- 1373
			uiArt, -- 1373
			uiGlow, -- 1373
			ctx, -- 1373
			lampProg, -- 1373
			s, -- 1373
			ox, -- 1373
			oy -- 1373
		) -- 1373
	else -- 1373
		____isLowpoly_9 = self:drawM03PixelRoomAndWindow( -- 1374
			uiDraw, -- 1374
			uiArt, -- 1374
			uiGlow, -- 1374
			ctx, -- 1374
			s, -- 1374
			ox, -- 1374
			oy -- 1374
		) -- 1374
	end -- 1374
	local paintedRoomOk = ____isLowpoly_9 -- 1372
	if not paintedRoomOk then -- 1372
		local deskTopCol = isLowpoly and toColor(shadeSurface( -- 1378
			MING_MATERIALS.mingTimber.base, -- 1380
			vec3(-0.25, 0.9, -0.35), -- 1381
			0, -- 1382
			1, -- 1383
			lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1384
			MING_MATERIALS.mingTimber -- 1385
		)) or Color(86, 60, 42, 255) -- 1385
		local deskFrontCol = isLowpoly and toColor(shadeSurface( -- 1388
			MING_MATERIALS.mingTimberDark.base, -- 1390
			vec3(0, 0.1, -0.99), -- 1391
			-4, -- 1391
			1, -- 1393
			lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1394
			MING_MATERIALS.mingTimberDark -- 1395
		)) or Color(52, 36, 26, 255) -- 1395
		uiDraw:drawPolygon( -- 1398
			{ -- 1398
				Vec2(0, deskY - 120 * s), -- 1399
				Vec2(ctx.uiW, deskY - 120 * s), -- 1400
				Vec2(ctx.uiW, deskY + 42 * s), -- 1401
				Vec2(0, deskY + 42 * s) -- 1402
			}, -- 1402
			deskTopCol -- 1403
		) -- 1403
		uiDraw:drawRect( -- 1404
			Rect(0, 0, ctx.uiW, deskY - 118 * s), -- 1404
			deskFrontCol -- 1404
		) -- 1404
		local inkX = ox + ____exports.TOWER_SHOT_LAYOUT.inkstoneX * s -- 1405
		local inkY = oy + ____exports.TOWER_SHOT_LAYOUT.inkstoneY * s -- 1406
		uiDraw:drawPolygon( -- 1407
			{ -- 1407
				Vec2(inkX - 38 * s, inkY - 18 * s), -- 1408
				Vec2(inkX + 38 * s, inkY - 18 * s), -- 1409
				Vec2(inkX + 32 * s, inkY + 18 * s), -- 1410
				Vec2(inkX - 32 * s, inkY + 18 * s) -- 1411
			}, -- 1411
			Color(38, 44, 52, 255), -- 1412
			1.2, -- 1412
			Color(96, 106, 118, 185) -- 1412
		) -- 1412
	end -- 1412
	local lx = isLowpoly and ox + lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s or ox + ____exports.TOWER_SHOT_LAYOUT.lampDeskX * s -- 1416
	local ly = isLowpoly and oy + (lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34) * s or oy + ____exports.TOWER_SHOT_LAYOUT.lampDeskY * s -- 1419
	local lampWarmth = isLowpoly and 0.45 + 0.55 * lampProg or 0.92 -- 1422
	if not paintedRoomOk then -- 1422
		self:drawMingLantern( -- 1424
			uiInkDraw, -- 1424
			uiGlow, -- 1424
			lx, -- 1424
			ly, -- 1424
			1.02 * s, -- 1424
			1, -- 1424
			lampWarmth -- 1424
		) -- 1424
	elseif isLowpoly then -- 1424
		local moveVis = lampProg < 0.92 and 1 - smoothstep(0.75, 0.96, lampProg) or 0 -- 1427
		if moveVis > 0.03 then -- 1427
			self:drawMingLantern( -- 1429
				uiInkDraw, -- 1429
				uiGlow, -- 1429
				lx, -- 1429
				ly, -- 1429
				0.92 * s, -- 1429
				moveVis * 0.92, -- 1429
				lampWarmth -- 1429
			) -- 1429
		end -- 1429
		local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 1431
		fillRadialGlow( -- 1432
			uiGlow, -- 1433
			lx, -- 1434
			ly + 4 * s, -- 1435
			118 * s * flicker * (0.65 + 0.45 * lampProg), -- 1436
			118 * s * flicker * (0.65 + 0.45 * lampProg), -- 1437
			Color( -- 1438
				250, -- 1438
				208, -- 1438
				132, -- 1438
				math.floor((78 + 56 * lampProg) * flicker + 0.5) -- 1438
			), -- 1438
			Color(228, 162, 74, 0), -- 1439
			16 -- 1440
		) -- 1440
	else -- 1440
		local flicker = 0.92 + 0.08 * math.sin(self.animTime * 6.8) -- 1444
		fillRadialGlow( -- 1445
			uiGlow, -- 1446
			ox + 266 * s, -- 1447
			oy + 272 * s, -- 1448
			148 * s * flicker, -- 1449
			138 * s * flicker, -- 1450
			Color( -- 1451
				252, -- 1451
				212, -- 1451
				138, -- 1451
				math.floor(88 * flicker + 0.5) -- 1451
			), -- 1451
			Color(232, 168, 76, 0), -- 1452
			16 -- 1453
		) -- 1453
	end -- 1453
	if isLowpoly and lampProg > 0.04 then -- 1453
		local beamA = math.floor(62 * lampProg + 0.5) -- 1459
		fillGradQuad( -- 1460
			uiGlow, -- 1461
			lx + 10 * s, -- 1462
			ly + 30 * s, -- 1462
			Color(248, 206, 134, beamA), -- 1462
			lx + 10 * s, -- 1463
			ly - 32 * s, -- 1463
			Color( -- 1463
				248, -- 1463
				206, -- 1463
				134, -- 1463
				math.floor(beamA * 0.72 + 0.5) -- 1463
			), -- 1463
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.92) * s, -- 1464
			oy + (____exports.TOWER_SHOT_LAYOUT.row2Y - 58) * s, -- 1464
			Color(242, 198, 124, 0), -- 1464
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.85) * s, -- 1465
			oy + (____exports.TOWER_SHOT_LAYOUT.row1Y + 48) * s, -- 1465
			Color(242, 198, 124, 0) -- 1465
		) -- 1465
	end -- 1465
	local bookReveal = smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t) -- 1470
	if bookReveal > 0.02 then -- 1470
		self:drawRegisterBook( -- 1472
			uiDraw, -- 1472
			uiInkDraw, -- 1472
			uiArt, -- 1472
			uiGlow, -- 1472
			ctx, -- 1472
			route, -- 1472
			bookReveal, -- 1472
			lampProg, -- 1472
			s, -- 1472
			ox, -- 1472
			oy -- 1472
		) -- 1472
	end -- 1472
	self:drawDeskPropsAndBowl( -- 1476
		uiDraw, -- 1476
		uiInkDraw, -- 1476
		uiArt, -- 1476
		uiGlow, -- 1476
		ctx, -- 1476
		route, -- 1476
		s, -- 1476
		ox, -- 1476
		oy -- 1476
	) -- 1476
end -- 1355
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, lampProg, s, ox, oy) -- 1479
	local scaleCover = math.max(ctx.uiW / 960, ctx.uiH / 540) -- 1489
	local imgW = 960 * scaleCover -- 1490
	local imgH = 540 * scaleCover -- 1491
	local placedCold = uiArt:tryPlacePath( -- 1492
		"assets/art/cg_tower_desk_cold.png", -- 1493
		"fe05_f03_bg_cold", -- 1494
		ctx.uiW * 0.5, -- 1495
		ctx.uiH * 0.5, -- 1496
		imgW, -- 1497
		imgH, -- 1498
		{ -- 1499
			anchorX = 0.5, -- 1500
			anchorY = 0.5, -- 1501
			color = Color( -- 1502
				math.floor(212 + 43 * lampProg + 0.5), -- 1503
				math.floor(220 + 22 * lampProg + 0.5), -- 1504
				math.floor(238 - 36 * lampProg + 0.5), -- 1505
				255 -- 1506
			), -- 1506
			opacity = 1, -- 1508
			smooth = true, -- 1509
			layer = -8 -- 1510
		} -- 1510
	) -- 1510
	if placedCold then -- 1510
		if lampProg > 0.02 then -- 1510
			local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1516
			local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1517
			local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1518
			fillRadialGlow( -- 1519
				uiGlow, -- 1520
				wx + ww * 0.58, -- 1520
				wy + 22 * s, -- 1520
				580 * s, -- 1521
				420 * s, -- 1521
				Color( -- 1522
					248, -- 1522
					198, -- 1522
					122, -- 1522
					math.floor(92 * lampProg + 0.5) -- 1522
				), -- 1522
				Color(216, 152, 68, 0), -- 1523
				20 -- 1524
			) -- 1524
		end -- 1524
		return true -- 1527
	end -- 1527
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1531
	local wallTop = lerpRGBA( -- 1532
		rgba(18, 24, 38, 255), -- 1532
		rgba(46, 36, 28, 255), -- 1532
		lampProg -- 1532
	) -- 1532
	local wallBot = lerpRGBA( -- 1533
		rgba(12, 16, 26, 255), -- 1533
		rgba(28, 22, 20, 255), -- 1533
		lampProg -- 1533
	) -- 1533
	fillVGradRect( -- 1534
		uiDraw, -- 1534
		0, -- 1534
		0, -- 1534
		ctx.uiW, -- 1534
		ctx.uiH, -- 1534
		toColor(wallBot), -- 1534
		toColor(wallTop) -- 1534
	) -- 1534
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1535
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1536
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1537
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1538
	fillVGradRect( -- 1539
		uiDraw, -- 1539
		wx, -- 1539
		wy, -- 1539
		ww, -- 1539
		wh, -- 1539
		Color(34, 44, 62, 255), -- 1539
		Color(16, 24, 40, 255) -- 1539
	) -- 1539
	local sillCol = shadeSurface( -- 1540
		MING_MATERIALS.mingStoneStep.base, -- 1540
		vec3(0, 0.94, -0.34), -- 1540
		6, -- 1540
		1, -- 1540
		light, -- 1540
		MING_MATERIALS.mingStoneStep -- 1540
	) -- 1540
	uiDraw:drawRect( -- 1541
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1541
		toColor(sillCol) -- 1541
	) -- 1541
	return false -- 1542
end -- 1479
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1545
	local scaleCover = math.max(ctx.uiW / 960, ctx.uiH / 540) -- 1554
	local imgW = 960 * scaleCover -- 1555
	local imgH = 540 * scaleCover -- 1556
	local placedWarm = uiArt:tryPlacePath( -- 1557
		"assets/art/cg_tower_desk_warm.png", -- 1558
		"fe05_m03_bg_warm", -- 1559
		ctx.uiW * 0.5, -- 1560
		ctx.uiH * 0.5, -- 1561
		imgW, -- 1562
		imgH, -- 1563
		{ -- 1564
			anchorX = 0.5, -- 1565
			anchorY = 0.5, -- 1566
			opacity = 1, -- 1567
			smooth = true, -- 1568
			layer = -8 -- 1569
		} -- 1569
	) -- 1569
	if placedWarm then -- 1569
		fillRadialGlow( -- 1573
			uiGlow, -- 1574
			ox + 260 * s, -- 1574
			oy + 416 * s, -- 1574
			520 * s, -- 1575
			360 * s, -- 1575
			Color(246, 202, 134, 62), -- 1576
			Color(220, 158, 76, 0), -- 1577
			20 -- 1578
		) -- 1578
		return true -- 1580
	end -- 1580
	fillVGradRect( -- 1583
		uiDraw, -- 1584
		0, -- 1584
		0, -- 1584
		ctx.uiW, -- 1584
		ctx.uiH, -- 1584
		Color(26, 21, 20, 255), -- 1585
		Color(46, 36, 30, 255) -- 1586
	) -- 1586
	local groupX = ox + 210 * s -- 1588
	local groupY = oy + 300 * s -- 1589
	uiArt:tryPlace( -- 1590
		"soldier_idle", -- 1590
		"fe05_m03_room_soldier", -- 1590
		groupX - 38 * s, -- 1590
		groupY, -- 1590
		118 * s, -- 1590
		166 * s, -- 1590
		{facing = 1, opacity = 0.9, layer = 1} -- 1590
	) -- 1590
	uiArt:tryPlace( -- 1593
		"child_idle", -- 1593
		"fe05_m03_room_child", -- 1593
		groupX + 42 * s, -- 1593
		groupY, -- 1593
		86 * s, -- 1593
		116 * s, -- 1593
		{facing = 1, opacity = 0.92, layer = 1} -- 1593
	) -- 1593
	return false -- 1596
end -- 1545
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1599
	local t = self.seqElapsed -- 1612
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1613
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1614
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1615
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1616
	local midX = bx + bw * 0.5 -- 1617
	local midY = by + bh * 0.5 -- 1618
	uiDraw:drawRect( -- 1621
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1621
		Color( -- 1621
			10, -- 1621
			11, -- 1621
			16, -- 1621
			math.floor(108 * reveal + 0.5) -- 1621
		) -- 1621
	) -- 1621
	uiDraw:drawRect( -- 1622
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1622
		Color( -- 1622
			32, -- 1622
			46, -- 1622
			62, -- 1622
			math.floor(235 * reveal + 0.5) -- 1622
		), -- 1622
		1, -- 1622
		Color( -- 1622
			86, -- 1622
			104, -- 1622
			124, -- 1622
			math.floor(165 * reveal + 0.5) -- 1622
		) -- 1622
	) -- 1622
	if not uiArt:tryPlace( -- 1622
		"ink_song_paper", -- 1625
		"fe05_registry_paper", -- 1625
		midX, -- 1625
		midY, -- 1625
		bw, -- 1625
		bh, -- 1625
		{opacity = 0.98 * reveal, layer = 1} -- 1625
	) then -- 1625
		uiDraw:drawRect( -- 1626
			Rect(bx, by, bw, bh), -- 1627
			toColor( -- 1628
				PALETTE.xuanPaper, -- 1628
				math.floor(248 * reveal + 0.5) -- 1628
			), -- 1628
			1, -- 1629
			toColor( -- 1630
				PALETTE.silkDim, -- 1630
				math.floor(180 * reveal + 0.5) -- 1630
			) -- 1630
		) -- 1630
	end -- 1630
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1635
	fillRadialGlow( -- 1636
		uiGlow, -- 1637
		bx + bw * 0.34, -- 1637
		by + bh * 0.48, -- 1637
		bw * 0.58, -- 1638
		bh * 0.52, -- 1638
		Color( -- 1639
			246, -- 1639
			214, -- 1639
			156, -- 1639
			math.floor(44 * paperWarm * reveal + 0.5) -- 1639
		), -- 1639
		Color(238, 198, 128, 0), -- 1640
		16 -- 1641
	) -- 1641
	local padX = 44 * s -- 1645
	local padY = 32 * s -- 1646
	local inX = bx + padX -- 1647
	local inY = by + padY -- 1648
	local inW = bw - padX * 2 -- 1649
	local inH = bh - padY * 2 -- 1650
	local redSilk = toColor( -- 1651
		PALETTE.rouge, -- 1651
		math.floor(132 * reveal + 0.5) -- 1651
	) -- 1651
	local redFaint = toColor( -- 1652
		PALETTE.rouge, -- 1652
		math.floor(70 * reveal + 0.5) -- 1652
	) -- 1652
	uiInkDraw:drawRect( -- 1653
		Rect(inX, inY, inW, inH), -- 1653
		Color(0, 0, 0, 0), -- 1653
		1, -- 1653
		redSilk -- 1653
	) -- 1653
	uiInkDraw:drawRect( -- 1654
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1654
		Color(0, 0, 0, 0), -- 1654
		0.6, -- 1654
		redFaint -- 1654
	) -- 1654
	local headY = inY + inH - 28 * s -- 1657
	ctx.texts:put( -- 1658
		"md", -- 1658
		"北塔值夜收籍 · 末页", -- 1658
		inX + 18 * s, -- 1658
		headY, -- 1658
		toColor(PALETTE.xuanInk), -- 1658
		0, -- 1658
		0.5, -- 1658
		"Left", -- 1658
		2.2, -- 1658
		0.96 * reveal, -- 1658
		0 -- 1658
	) -- 1658
	ctx.texts:put( -- 1659
		"xs", -- 1659
		"宁村北塔", -- 1659
		inX + inW - 18 * s, -- 1659
		headY, -- 1659
		toColor(PALETTE.xuanInkSub), -- 1659
		1, -- 1659
		0.5, -- 1659
		"Right", -- 1659
		1.8, -- 1659
		0.8 * reveal, -- 1659
		0 -- 1659
	) -- 1659
	uiInkDraw:drawSegment( -- 1660
		Vec2(inX + 14 * s, headY - 22 * s), -- 1660
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1660
		0.9, -- 1660
		redSilk -- 1660
	) -- 1660
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1663
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1664
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1665
	ctx.texts:put( -- 1666
		"sm", -- 1666
		"肆拾壹", -- 1666
		inX + 18 * s, -- 1666
		row1Y, -- 1666
		toColor(PALETTE.rouge), -- 1666
		0, -- 1666
		0.5, -- 1666
		"Left", -- 1666
		1, -- 1666
		0.94 * reveal, -- 1666
		0 -- 1666
	) -- 1666
	if r1Prog > 0.02 then -- 1666
		ctx.texts:put( -- 1668
			"md", -- 1668
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1668
			inX + 96 * s, -- 1668
			row1Y, -- 1668
			toColor(PALETTE.xuanInk), -- 1668
			0, -- 1668
			0.5, -- 1668
			"Left", -- 1668
			1.6, -- 1668
			0.96 * math.min(1, r1Prog * 1.4), -- 1668
			0 -- 1668
		) -- 1668
	end -- 1668
	if r1Prog > 0.65 then -- 1668
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1671
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1672
		ctx.texts:put( -- 1675
			"xs", -- 1675
			subText, -- 1675
			inX + 96 * s, -- 1675
			row1SubY, -- 1675
			toColor(PALETTE.xuanInkSub), -- 1675
			0, -- 1675
			0.5, -- 1675
			"Left", -- 1675
			0.6, -- 1675
			0.88 * subA, -- 1675
			0 -- 1675
		) -- 1675
	end -- 1675
	uiInkDraw:drawSegment( -- 1677
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1677
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1677
		0.7, -- 1677
		redFaint -- 1677
	) -- 1677
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1680
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1681
	ctx.texts:put( -- 1682
		"sm", -- 1682
		"肆拾贰", -- 1682
		inX + 18 * s, -- 1682
		row2Y, -- 1682
		toColor(PALETTE.rouge), -- 1682
		0, -- 1682
		0.5, -- 1682
		"Left", -- 1682
		1, -- 1682
		0.94 * reveal, -- 1682
		0 -- 1682
	) -- 1682
	if route == "child" then -- 1682
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1686
		uiInkDraw:drawSegment( -- 1687
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1688
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1689
			1, -- 1690
			toColor(PALETTE.xuanInkSub, lineA) -- 1691
		) -- 1691
	else -- 1691
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1695
		if r2Prog <= 0.02 then -- 1695
			uiInkDraw:drawSegment( -- 1697
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1698
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1699
				0.9, -- 1700
				toColor( -- 1701
					PALETTE.xuanInkSub, -- 1701
					math.floor(105 * reveal + 0.5) -- 1701
				) -- 1701
			) -- 1701
		else -- 1701
			ctx.texts:put( -- 1704
				"md", -- 1704
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1704
				inX + 96 * s, -- 1704
				row2Y, -- 1704
				toColor(PALETTE.xuanInk), -- 1704
				0, -- 1704
				0.5, -- 1704
				"Left", -- 1704
				1.6, -- 1704
				0.96 * math.min(1, r2Prog * 1.4), -- 1704
				0 -- 1704
			) -- 1704
			if r2Prog > 0.65 then -- 1704
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1706
				ctx.texts:put( -- 1707
					"xs", -- 1707
					"守城戍卒亲口报出姓名，两人俱安。", -- 1707
					inX + 96 * s, -- 1707
					row2SubY, -- 1707
					toColor(PALETTE.xuanInkSub), -- 1707
					0, -- 1707
					0.5, -- 1707
					"Left", -- 1707
					0.6, -- 1707
					0.88 * subA, -- 1707
					0 -- 1707
				) -- 1707
			end -- 1707
		end -- 1707
	end -- 1707
	uiInkDraw:drawSegment( -- 1711
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1711
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1711
		0.7, -- 1711
		redFaint -- 1711
	) -- 1711
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1714
	if colophonA > 0.02 then -- 1714
		local signY = inY + 34 * s -- 1716
		ctx.texts:put( -- 1717
			"banner", -- 1717
			"向西守望", -- 1717
			midX - 24 * s, -- 1717
			signY, -- 1717
			toColor(PALETTE.xuanInk), -- 1717
			0.5, -- 1717
			0.5, -- 1717
			"Center", -- 1717
			6, -- 1717
			0.88 * colophonA, -- 1717
			0 -- 1717
		) -- 1717
	end -- 1717
	self:drawGuardBrushHand( -- 1721
		uiInkDraw, -- 1721
		uiArt, -- 1721
		route, -- 1721
		s, -- 1721
		ox, -- 1721
		oy -- 1721
	) -- 1721
end -- 1599
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, uiArt, route, s, ox, oy) -- 1724
	local t = self.seqElapsed -- 1732
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1733
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1734
	local row1X0 = hoverX -- 1735
	local row1X1 = hoverX + 142 * s -- 1736
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1737
	local tipX = hoverX -- 1739
	local tipY = hoverY -- 1740
	local alpha = 0 -- 1741
	local lifted = 0 -- 1742
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1742
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1746
		tipX = lerp(row1X0, row1X1, k) -- 1747
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1748
		alpha = smoothstep(2, 2.2, t) -- 1749
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1750
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1750
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1753
		tipX = lerp(row1X1, hoverX, moveK) -- 1754
		tipY = lerp(row1Y, hoverY, moveK) -- 1755
		alpha = 1 -- 1756
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1757
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1757
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1760
		tipX = hoverX + outK * 140 * s -- 1761
		tipY = hoverY + outK * 46 * s -- 1762
		lifted = (9 + outK * 28) * s -- 1763
		alpha = 1 - outK -- 1764
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1764
		if t < 4.6 then -- 1764
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1768
			tipX = hoverX -- 1769
			tipY = hoverY -- 1770
			lifted = lerp(9 * s, 0, dipK) -- 1771
			alpha = 1 -- 1772
		elseif t < 5.55 then -- 1772
			local wK = smoothstep(4.6, 5.55, t) -- 1774
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1775
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1776
			lifted = 0 -- 1777
			alpha = 1 -- 1778
		else -- 1778
			local outK = smoothstep(5.55, 6.05, t) -- 1780
			tipX = hoverX + 216 * s + outK * 115 * s -- 1781
			tipY = hoverY + outK * 52 * s -- 1782
			lifted = outK * 24 * s -- 1783
			alpha = 1 - outK -- 1784
		end -- 1784
	end -- 1784
	if alpha <= 0.02 then -- 1784
		return -- 1789
	end -- 1789
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1792
	local bx = tipX -- 1793
	local by = tipY + lifted -- 1794
	uiInkDraw:drawEllipse( -- 1796
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1796
		(5 + lifted * 0.22) * s, -- 1796
		2.8 * s, -- 1796
		Color( -- 1796
			20, -- 1796
			18, -- 1796
			16, -- 1796
			math.floor(78 * alpha + 0.5) -- 1796
		) -- 1796
	) -- 1796
	if uiArt:tryPlacePath( -- 1796
		"assets/art/cutscene_story_parts.clip|guard_brush_hand", -- 1799
		"fe05_guard_brush_hand", -- 1800
		bx, -- 1801
		by, -- 1802
		344 * s, -- 1803
		268 * s, -- 1804
		{ -- 1805
			anchorX = 0.03, -- 1806
			anchorY = 0.03, -- 1807
			opacity = clamp01(alpha), -- 1808
			smooth = true, -- 1809
			layer = 6 -- 1810
		} -- 1810
	) then -- 1810
		return -- 1813
	end -- 1813
	uiInkDraw:drawPolygon( -- 1816
		{ -- 1816
			Vec2(bx, by), -- 1817
			Vec2(bx + 15 * s, by - 4 * s), -- 1818
			Vec2(bx + 10 * s, by + 8 * s) -- 1819
		}, -- 1819
		Color(22, 22, 26, a) -- 1820
	) -- 1820
	uiInkDraw:drawSegment( -- 1821
		Vec2(bx + 12 * s, by + 2 * s), -- 1821
		Vec2(bx + 122 * s, by + 34 * s), -- 1821
		6.8 * s, -- 1821
		Color(142, 110, 74, a) -- 1821
	) -- 1821
end -- 1724
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1824
	local t = self.seqElapsed -- 1835
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1836
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1837
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1838
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1839
	if route == "child" then -- 1839
		local propA = smoothstep(1.55, 2.05, t) -- 1842
		if propA > 0.02 then -- 1842
			self:drawNeedleCaseOnDesk( -- 1844
				uiDraw, -- 1844
				uiInkDraw, -- 1844
				uiArt, -- 1844
				ncX + 42 * s, -- 1844
				ncY - 22 * s, -- 1844
				s, -- 1844
				propA, -- 1844
				true -- 1844
			) -- 1844
		end -- 1844
		local noteReadA = smoothstep(1.65, 2.1, t) * (1 - smoothstep(3.65, 4.15, t)) -- 1846
		if noteReadA > 0.02 then -- 1846
			local cardX = ncX + 52 * s -- 1848
			local cardY = ncY + 72 * s -- 1849
			uiInkDraw:drawRect( -- 1850
				Rect(cardX - 118 * s, cardY - 30 * s, 236 * s, 60 * s), -- 1851
				toColor( -- 1852
					PALETTE.xuanPaper, -- 1852
					math.floor(238 * noteReadA + 0.5) -- 1852
				), -- 1852
				1, -- 1853
				toColor( -- 1854
					PALETTE.rouge, -- 1854
					math.floor(110 * noteReadA + 0.5) -- 1854
				) -- 1854
			) -- 1854
			ctx.texts:put( -- 1856
				"xs", -- 1856
				NEEDLE_NOTE_LINES[1], -- 1856
				cardX, -- 1856
				cardY + 10 * s, -- 1856
				toColor(PALETTE.xuanInk), -- 1856
				0.5, -- 1856
				0.5, -- 1856
				"Center", -- 1856
				0.6, -- 1856
				0.94 * noteReadA, -- 1856
				0 -- 1856
			) -- 1856
			ctx.texts:put( -- 1857
				"xs", -- 1857
				"—— " .. NEEDLE_NOTE_LINES[2], -- 1857
				cardX + 74 * s, -- 1857
				cardY - 12 * s, -- 1857
				toColor(PALETTE.xuanInkSub), -- 1857
				1, -- 1857
				0.5, -- 1857
				"Right", -- 1857
				0.8, -- 1857
				0.88 * noteReadA, -- 1857
				0 -- 1857
			) -- 1857
		end -- 1857
		local bowlK = smoothstep(4.35, 5.15, t) -- 1859
		if bowlK > 0.02 then -- 1859
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1861
			self:drawWarmPorcelainBowl( -- 1862
				uiDraw, -- 1862
				uiInkDraw, -- 1862
				uiArt, -- 1862
				uiGlow, -- 1862
				bx, -- 1862
				bowlY, -- 1862
				s, -- 1862
				bowlK, -- 1862
				false, -- 1862
				0 -- 1862
			) -- 1862
		end -- 1862
	else -- 1862
		local needleK = smoothstep(5.45, 6.15, t) -- 1865
		if needleK > 0.02 then -- 1865
			local ny = lerp(ncY + 26 * s, ncY - 22 * s, needleK) -- 1867
			self:drawNeedleCaseOnDesk( -- 1868
				uiDraw, -- 1868
				uiInkDraw, -- 1868
				uiArt, -- 1868
				ncX + 64 * s, -- 1868
				ny, -- 1868
				s, -- 1868
				needleK, -- 1868
				false -- 1868
			) -- 1868
		end -- 1868
		local bowlK = smoothstep(5.8, 6.65, t) -- 1870
		if bowlK > 0.02 then -- 1870
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1872
			local handsK = smoothstep(5.95, 6.75, t) -- 1873
			self:drawWarmPorcelainBowl( -- 1874
				uiDraw, -- 1874
				uiInkDraw, -- 1874
				uiArt, -- 1874
				uiGlow, -- 1874
				bowlX, -- 1874
				by, -- 1874
				s, -- 1874
				bowlK, -- 1874
				true, -- 1874
				handsK -- 1874
			) -- 1874
		end -- 1874
		local cuffK = smoothstep(4.25, 4.85, t) -- 1877
		if cuffK > 0.02 then -- 1877
			drawPatchedCuff(uiInkDraw, uiGlow, { -- 1879
				wristX = ox + 116 * s, -- 1880
				wristY = oy + 168 * s, -- 1881
				angleRad = 0.06, -- 1882
				scale = 0.74 * s, -- 1883
				pose = "open", -- 1884
				opacity = 0.94 * cuffK, -- 1885
				stitchHighlight = 0.34, -- 1886
				warmth = 0.72, -- 1887
				uiArt = uiArt, -- 1888
				instanceKey = "fe05_m03_desk_cuff", -- 1889
				layer = 5 -- 1890
			}) -- 1890
		end -- 1890
	end -- 1890
end -- 1824
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, bgDraw, inkDraw, uiArt, cx, cy, s, alpha, withNote) -- 1897
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1907
	bgDraw:drawEllipse( -- 1908
		Vec2(cx + 4 * s, cy - 32 * s), -- 1908
		44 * s, -- 1908
		12 * s, -- 1908
		Color( -- 1908
			10, -- 1908
			10, -- 1908
			14, -- 1908
			math.floor(130 * alpha + 0.5) -- 1908
		) -- 1908
	) -- 1908
	if not uiArt:tryPlacePath( -- 1908
		"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 1910
		"fe05_desk_needle_pouch", -- 1911
		cx, -- 1912
		cy + 4 * s, -- 1913
		100 * s, -- 1914
		102 * s, -- 1915
		{ -- 1916
			anchorX = 0.5, -- 1917
			anchorY = 0.5, -- 1918
			angle = -10, -- 1919
			opacity = clamp01(alpha), -- 1920
			smooth = true, -- 1921
			layer = 5 -- 1922
		} -- 1922
	) then -- 1922
		inkDraw:drawPolygon( -- 1925
			{ -- 1925
				Vec2(cx - 32 * s, cy - 12 * s), -- 1926
				Vec2(cx + 26 * s, cy - 15 * s), -- 1927
				Vec2(cx + 30 * s, cy + 16 * s), -- 1928
				Vec2(cx - 28 * s, cy + 18 * s) -- 1929
			}, -- 1929
			Color(148, 124, 92, a), -- 1930
			1.3, -- 1930
			Color(88, 70, 50, a) -- 1930
		) -- 1930
	end -- 1930
	if withNote then -- 1930
		inkDraw:drawPolygon( -- 1934
			{ -- 1934
				Vec2(cx + 42 * s, cy - 18 * s), -- 1935
				Vec2(cx + 100 * s, cy - 12 * s), -- 1936
				Vec2(cx + 94 * s, cy + 24 * s), -- 1937
				Vec2(cx + 38 * s, cy + 18 * s) -- 1938
			}, -- 1938
			toColor(PALETTE.xuanPaper, a), -- 1939
			1, -- 1939
			toColor( -- 1939
				PALETTE.xuanInkSub, -- 1939
				math.floor(160 * alpha + 0.5) -- 1939
			) -- 1939
		) -- 1939
		inkDraw:drawSegment( -- 1940
			Vec2(cx + 50 * s, cy + 8 * s), -- 1940
			Vec2(cx + 84 * s, cy + 11 * s), -- 1940
			1.2 * s, -- 1940
			toColor( -- 1940
				PALETTE.xuanInk, -- 1940
				math.floor(170 * alpha + 0.5) -- 1940
			) -- 1940
		) -- 1940
		inkDraw:drawSegment( -- 1941
			Vec2(cx + 50 * s, cy - 2 * s), -- 1941
			Vec2(cx + 80 * s, cy + 1 * s), -- 1941
			1.2 * s, -- 1941
			toColor( -- 1941
				PALETTE.xuanInk, -- 1941
				math.floor(160 * alpha + 0.5) -- 1941
			) -- 1941
		) -- 1941
	end -- 1941
end -- 1897
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, bgDraw, inkDraw, uiArt, glow, cx, cy, s, alpha, heldByTwoHands, handsK) -- 1946
	local op = clamp01(alpha) -- 1958
	bgDraw:drawEllipse( -- 1959
		Vec2(cx, cy - 46 * s), -- 1959
		64 * s, -- 1959
		14 * s, -- 1959
		Color( -- 1959
			8, -- 1959
			9, -- 1959
			14, -- 1959
			math.floor(138 * op + 0.5) -- 1959
		) -- 1959
	) -- 1959
	if not uiArt:tryPlacePath( -- 1959
		"assets/art/cutscene_story_parts.clip|porridge_bowl", -- 1961
		"fe05_desk_porridge_bowl", -- 1962
		cx, -- 1963
		cy - 4 * s, -- 1964
		162 * s, -- 1965
		124 * s, -- 1966
		{ -- 1967
			anchorX = 0.5, -- 1968
			anchorY = 0.5, -- 1969
			opacity = op, -- 1970
			smooth = true, -- 1971
			layer = 5 -- 1972
		} -- 1972
	) then -- 1972
		local a = math.floor(255 * op + 0.5) -- 1975
		inkDraw:drawEllipse( -- 1976
			Vec2(cx, cy + 8 * s), -- 1976
			64 * s, -- 1976
			21 * s, -- 1976
			Color(224, 218, 206, a) -- 1976
		) -- 1976
	end -- 1976
	local wi = 0 -- 1980
	do -- 1980
		wi = 0 -- 1981
		while wi < 4 do -- 1981
			local cyc = (self.animTime * 0.36 + wi * 0.25) % 1 -- 1982
			local sx = cx + (wi - 1.5) * 20 * s + math.sin(self.animTime * 1.4 + wi * 2.1) * (8 + cyc * 10) * s -- 1983
			local sy = cy + (24 + cyc * 58) * s -- 1984
			local sr = (18 + cyc * 24) * s -- 1985
			local wa = math.floor(math.sin(cyc * math.pi) * 34 * op + 0.5) -- 1986
			if wa > 2 then -- 1986
				fillRadialGlow( -- 1988
					glow, -- 1988
					sx, -- 1988
					sy, -- 1988
					sr, -- 1988
					sr * 1.35, -- 1988
					Color(246, 238, 224, wa), -- 1988
					Color(246, 238, 224, 0), -- 1988
					12 -- 1988
				) -- 1988
			end -- 1988
			wi = wi + 1 -- 1981
		end -- 1981
	end -- 1981
	if heldByTwoHands and handsK > 0.02 then -- 1981
		local liftY = (1 - handsK) * 36 * s -- 1994
		local handOp = clamp01(handsK * op) -- 1995
		uiArt:tryPlacePath( -- 1996
			"assets/art/cutscene_story_parts.clip|xiaoman_cup_hands", -- 1997
			"fe05_m03_xiaoman_cup_hands", -- 1998
			cx, -- 1999
			cy - 34 * s - liftY, -- 2000
			258 * s, -- 2001
			186 * s, -- 2002
			{ -- 2003
				anchorX = 0.5, -- 2004
				anchorY = 0.5, -- 2005
				opacity = handOp, -- 2006
				smooth = true, -- 2007
				layer = 6 -- 2008
			} -- 2008
		) -- 2008
	end -- 2008
end -- 1946
function TowerEndingsPlugin.prototype.drawMingLantern(self, draw, glow, cx, cy, scale, alpha, warmth) -- 2015
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 2024
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 2025
	draw:drawSegment( -- 2027
		Vec2(cx - 10 * scale, cy + 28 * scale), -- 2027
		Vec2(cx, cy + 40 * scale), -- 2027
		1.8 * scale, -- 2027
		Color(88, 86, 82, a) -- 2027
	) -- 2027
	draw:drawSegment( -- 2028
		Vec2(cx + 10 * scale, cy + 28 * scale), -- 2028
		Vec2(cx, cy + 40 * scale), -- 2028
		1.8 * scale, -- 2028
		Color(88, 86, 82, a) -- 2028
	) -- 2028
	draw:drawRect( -- 2030
		Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), -- 2030
		Color(62, 46, 34, a), -- 2030
		1, -- 2030
		Color(118, 92, 66, a) -- 2030
	) -- 2030
	draw:drawRect( -- 2031
		Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), -- 2031
		Color(62, 46, 34, a), -- 2031
		1, -- 2031
		Color(118, 92, 66, a) -- 2031
	) -- 2031
	draw:drawRect( -- 2033
		Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale), -- 2034
		Color( -- 2035
			238, -- 2035
			198, -- 2035
			132, -- 2035
			math.floor(230 * alpha * (0.75 + 0.25 * warmth) + 0.5) -- 2035
		), -- 2035
		1.4 * scale, -- 2036
		Color(94, 70, 48, a) -- 2037
	) -- 2037
	draw:drawSegment( -- 2039
		Vec2(cx, cy - 18 * scale), -- 2039
		Vec2(cx, cy + 22 * scale), -- 2039
		1.1 * scale, -- 2039
		Color( -- 2039
			94, -- 2039
			70, -- 2039
			48, -- 2039
			math.floor(150 * alpha + 0.5) -- 2039
		) -- 2039
	) -- 2039
	draw:drawEllipse( -- 2040
		Vec2(cx, cy + 2 * scale), -- 2040
		4.6 * scale * flicker, -- 2040
		8.5 * scale * flicker, -- 2040
		Color(255, 244, 212, a) -- 2040
	) -- 2040
	fillRadialGlow( -- 2042
		glow, -- 2043
		cx, -- 2043
		cy + 2 * scale, -- 2043
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2044
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2045
		Color( -- 2046
			250, -- 2046
			208, -- 2046
			132, -- 2046
			math.floor(128 * alpha * warmth + 0.5) -- 2046
		), -- 2046
		Color(228, 162, 74, 0), -- 2047
		16 -- 2048
	) -- 2048
end -- 2015
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 2052
	local line = self.lastSubtitle -- 2061
	if line ~= "" then -- 2061
		local cy = barH + 34 * s -- 2063
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 2064
		drawSilkVeil( -- 2065
			uiDraw, -- 2065
			uiArt, -- 2065
			"fe05_sub_veil", -- 2065
			ctx.uiW * 0.5, -- 2065
			cy, -- 2065
			stripW, -- 2065
			48 * s, -- 2065
			PALETTE.inkWash, -- 2065
			0.82, -- 2065
			3 -- 2065
		) -- 2065
		drawHairline( -- 2066
			uiInkDraw, -- 2066
			uiArt, -- 2066
			"fe05_sub_hair", -- 2066
			ctx.uiW * 0.5, -- 2066
			cy + 21 * s, -- 2066
			stripW * 0.68, -- 2066
			PALETTE.silkDim, -- 2066
			0.54, -- 2066
			true, -- 2066
			4 -- 2066
		) -- 2066
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 2067
		ctx.texts:put( -- 2068
			isSpoken and "md" or "sm", -- 2069
			line, -- 2070
			ctx.uiW * 0.5, -- 2071
			cy - 1 * s, -- 2072
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 2073
			0.5, -- 2074
			0.5, -- 2075
			"Center", -- 2076
			isSpoken and 1.8 or 1, -- 2077
			0.98, -- 2078
			0.08 -- 2079
		) -- 2079
	end -- 2079
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 2079
		local rawHint = route == "child" and "按 E 收页 · 尾声与史话   ·   Esc 暂歇" or "团圆尾声   ·   按 E 收页与史话   ·   Esc 暂歇" -- 2085
		local hint = adaptHintSentence(rawHint, ctx.input.inputMode, ctx.input.gamepadLayout) -- 2088
		ctx.texts:put( -- 2089
			"xs", -- 2089
			hint, -- 2089
			ctx.uiW * 0.5, -- 2089
			barH * 0.5, -- 2089
			toColor(PALETTE.textMid), -- 2089
			0.5, -- 2089
			0.5, -- 2089
			"Center", -- 2089
			1.4, -- 2089
			0.88, -- 2089
			0.08 -- 2089
		) -- 2089
	end -- 2089
end -- 2052
function ____exports.createTowerEndingsPlugin() -- 2094
	return __TS__New(____exports.TowerEndingsPlugin) -- 2095
end -- 2094
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 2099
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 2100
	fe:registerPlugin(plugin) -- 2101
	return plugin -- 2102
end -- 2099
return ____exports -- 2099