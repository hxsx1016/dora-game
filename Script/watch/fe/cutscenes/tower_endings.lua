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
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 37
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 39
local TOWER_WEST_LAMP_LIGHT = ____lowpoly.TOWER_WEST_LAMP_LIGHT -- 40
local clamp01 = ____lowpoly.clamp01 -- 41
local normalize3 = ____lowpoly.normalize3 -- 42
local shadeSurface = ____lowpoly.shadeSurface -- 43
local smoothstep = ____lowpoly.smoothstep -- 44
local vec3 = ____lowpoly.vec3 -- 45
local ____theme = require("Script.watch.fe.theme") -- 47
local PALETTE = ____theme.PALETTE -- 48
local drawHairline = ____theme.drawHairline -- 50
local drawSilkVeil = ____theme.drawSilkVeil -- 51
local fillGradQuad = ____theme.fillGradQuad -- 52
local fillRadialGlow = ____theme.fillRadialGlow -- 53
local fillVGradRect = ____theme.fillVGradRect -- 54
local lerpRGBA = ____theme.lerpRGBA -- 55
local rgba = ____theme.rgba -- 56
local toColor = ____theme.toColor -- 57
--- 精确对齐后端 tower-knock(36 拍 = 0.6s, 第 0 / 12 拍敲门) 与 8.0 秒配对演出节拍
____exports.TOWER_ENDING_TIMINGS = { -- 87
	knock1Sec = 0, -- 88
	knock2Sec = 0.2, -- 89
	reply1Sec = 0.42, -- 90
	reply2Sec = 0.54, -- 91
	doorOpenSec = 0.6, -- 92
	indoorCutSec = 1.4, -- 93
	row1StartSec = 2.2, -- 94
	row1EndSec = 3.4, -- 95
	pivotStartSec = 3.4, -- 96
	pivotEndSec = 4.2, -- 97
	divergeEndSec = 6.8, -- 98
	holdReadySec = TOWER_CONFIRM_TICKS / 60 -- 99
} -- 99
local TOWER_AUDIO_ROOT = "assets/audio/tower/" -- 102
____exports.TOWER_AUDIO_FILES = { -- 104
	knock1 = TOWER_AUDIO_ROOT .. "door_knock_1.wav", -- 105
	knock2 = TOWER_AUDIO_ROOT .. "door_knock_2.wav", -- 106
	reply1 = TOWER_AUDIO_ROOT .. "door_reply_1.wav", -- 107
	reply2 = TOWER_AUDIO_ROOT .. "door_reply_2.wav", -- 108
	doorOpen = TOWER_AUDIO_ROOT .. "door_open.wav", -- 109
	bookOpen = TOWER_AUDIO_ROOT .. "book_open.wav", -- 110
	brush1 = TOWER_AUDIO_ROOT .. "brush_write_1.wav", -- 111
	brush2 = TOWER_AUDIO_ROOT .. "brush_write_2.wav", -- 112
	lampMove = TOWER_AUDIO_ROOT .. "lamp_move.wav", -- 113
	needlePlace = TOWER_AUDIO_ROOT .. "needle_case_place.wav", -- 114
	bowlSet = TOWER_AUDIO_ROOT .. "bowl_set.wav", -- 115
	windCold = TOWER_AUDIO_ROOT .. "tower_wind_cold.wav", -- 116
	roomWarm = TOWER_AUDIO_ROOT .. "tower_room_warm.wav", -- 117
	lineXiaomanLamp = TOWER_AUDIO_ROOT .. "line_xiaoman_lamp.wav", -- 118
	lineZhoushuName = TOWER_AUDIO_ROOT .. "line_zhoushu_name.wav" -- 119
} -- 119
--- 同机位配对布局真源（基准 1280×720 逻辑坐标系，F03 与 M03 100% 共享）：
-- 保证两版并排对照时门扇、门槛、提灯、西窗、簿页、一/二行基线、悬停笔尖、案沿热碗 0.00 px 偏差。
____exports.TOWER_SHOT_LAYOUT = { -- 126
	refW = 1280, -- 127
	refH = 720, -- 128
	letterboxH = 60, -- 129
	doorCenterX = 640, -- 131
	thresholdY = 168, -- 132
	doorW = 248, -- 133
	doorH = 374, -- 134
	knockHandX = 574, -- 135
	knockHandY = 312, -- 136
	doorLanternX = 710, -- 137
	doorLanternY = 344, -- 138
	westWindowX = 88, -- 140
	westWindowY = 382, -- 141
	westWindowW = 236, -- 142
	westWindowH = 224, -- 143
	deskTopY = 260, -- 144
	lampDeskX = 356, -- 145
	lampDeskY = 332, -- 146
	lampWindowX = 206, -- 147
	lampWindowY = 422, -- 148
	bookX = 416, -- 149
	bookY = 196, -- 150
	bookW = 588, -- 151
	bookH = 386, -- 152
	row1Y = 454, -- 153
	row1SubY = 424, -- 154
	row2Y = 354, -- 155
	row2SubY = 324, -- 156
	brushHoverTipX = 556, -- 157
	brushHoverTipY = 358, -- 158
	needleCaseDeskX = 294, -- 159
	needleCaseDeskY = 204, -- 160
	bowlRimX = 954, -- 161
	bowlRimY = 184, -- 162
	inkstoneX = 1112, -- 163
	inkstoneY = 256 -- 164
} -- 164
local F03_DIALOGUE = "「朝西那盏灯，能留着吗？」" -- 226
local M03_DIALOGUE = "「周戍。」" -- 227
--- F03 拂晓冷室灯光预设（挪灯前），向 TOWER_WEST_LAMP_LIGHT（西窗暖灯）平滑插值
local TOWER_COLD_DAWN_LIGHT = { -- 230
	keyDir = normalize3(vec3(-0.34, 0.72, -0.6)), -- 231
	keyColor = rgba(146, 174, 206, 255), -- 232
	keyStrength = 0.74, -- 233
	rimDir = normalize3(vec3(0.68, 0.44, -0.58)), -- 234
	rimColor = rgba(182, 166, 140, 255), -- 235
	rimStrength = 0.24, -- 236
	ambientColor = rgba(18, 24, 38, 255), -- 237
	fogColor = rgba(16, 22, 34, 255), -- 238
	fogStartZ = 50, -- 239
	fogEndZ = 460, -- 240
	fogMaxAlpha = 0.78, -- 241
	shadowContrast = 0.78 -- 242
} -- 242
local function lerp(a, b, t) -- 245
	return a + (b - a) * t -- 246
end -- 245
local function lerpLightRig(a, b, t) -- 249
	local k = clamp01(t) -- 250
	return { -- 251
		keyDir = normalize3(vec3( -- 252
			lerp(a.keyDir.x, b.keyDir.x, k), -- 253
			lerp(a.keyDir.y, b.keyDir.y, k), -- 254
			lerp(a.keyDir.z, b.keyDir.z, k) -- 255
		)), -- 255
		keyColor = lerpRGBA(a.keyColor, b.keyColor, k), -- 257
		keyStrength = lerp(a.keyStrength, b.keyStrength, k), -- 258
		rimDir = normalize3(vec3( -- 259
			lerp(a.rimDir.x, b.rimDir.x, k), -- 260
			lerp(a.rimDir.y, b.rimDir.y, k), -- 261
			lerp(a.rimDir.z, b.rimDir.z, k) -- 262
		)), -- 262
		rimColor = lerpRGBA(a.rimColor, b.rimColor, k), -- 264
		rimStrength = lerp(a.rimStrength, b.rimStrength, k), -- 265
		ambientColor = lerpRGBA(a.ambientColor, b.ambientColor, k), -- 266
		fogColor = lerpRGBA(a.fogColor, b.fogColor, k), -- 267
		fogStartZ = lerp(a.fogStartZ, b.fogStartZ, k), -- 268
		fogEndZ = lerp(a.fogEndZ, b.fogEndZ, k), -- 269
		fogMaxAlpha = lerp(a.fogMaxAlpha, b.fogMaxAlpha, k), -- 270
		shadowContrast = lerp(a.shadowContrast, b.shadowContrast, k) -- 271
	} -- 271
end -- 249
local function computeScaledAnchors(uiW, uiH, lampProg) -- 275
	local s = math.min(uiW / ____exports.TOWER_SHOT_LAYOUT.refW, uiH / ____exports.TOWER_SHOT_LAYOUT.refH) -- 281
	local ox = (uiW - ____exports.TOWER_SHOT_LAYOUT.refW * s) * 0.5 -- 282
	local oy = (uiH - ____exports.TOWER_SHOT_LAYOUT.refH * s) * 0.5 -- 283
	local lx = lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) -- 284
	local ly = lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34 -- 285
	return {s = s, ox = ox, oy = oy, anchors = { -- 287
		doorCenterX = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s, -- 292
		thresholdY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s, -- 293
		knockHandX = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s, -- 294
		knockHandY = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s, -- 295
		bookX = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s, -- 296
		bookY = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s, -- 297
		bookW = ____exports.TOWER_SHOT_LAYOUT.bookW * s, -- 298
		bookH = ____exports.TOWER_SHOT_LAYOUT.bookH * s, -- 299
		row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s, -- 300
		row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s, -- 301
		brushHoverTipX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s, -- 302
		brushHoverTipY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s, -- 303
		bowlRimX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s, -- 304
		bowlRimY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s, -- 305
		lampCurX = ox + lx * s, -- 306
		lampCurY = oy + ly * s -- 307
	}} -- 307
end -- 275
local function deriveStage(seqElapsed, active) -- 312
	if not active then -- 312
		return "idle" -- 314
	end -- 314
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 314
		return "porch_knock" -- 317
	end -- 317
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 317
		return "door_open" -- 320
	end -- 320
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 320
		return "book_row1" -- 323
	end -- 323
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 323
		return "pivot_hover" -- 326
	end -- 326
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 326
		return "diverge_action" -- 329
	end -- 329
	return "ending_hold" -- 331
end -- 312
--- 将字符切片数组按进度拼接为前 n 段（避免 Lua 字节切片截断 UTF-8 汉字）
local function joinPrefixTokens(tokens, progress) -- 335
	if progress <= 0 or #tokens == 0 then -- 335
		return "" -- 337
	end -- 337
	local count = math.max( -- 339
		1, -- 339
		math.min( -- 339
			#tokens, -- 339
			math.ceil(progress * #tokens) -- 339
		) -- 339
	) -- 339
	local out = "" -- 340
	local i = 0 -- 341
	do -- 341
		i = 0 -- 342
		while i < count do -- 342
			out = out .. tokens[i + 1] -- 343
			i = i + 1 -- 342
		end -- 342
	end -- 342
	return out -- 345
end -- 335
local ROW1_TOKENS = { -- 348
	"小", -- 348
	"满", -- 348
	"  ", -- 348
	"·", -- 348
	"  ", -- 348
	"已", -- 348
	"收" -- 348
} -- 348
local ROW2_SOLDIER_TOKENS = { -- 349
	"周", -- 349
	"戍", -- 349
	"  ", -- 349
	"·", -- 349
	"  ", -- 349
	"兄", -- 349
	"妹", -- 349
	"同", -- 349
	"行", -- 349
	"  ", -- 349
	"·", -- 349
	"  ", -- 349
	"已", -- 349
	"收" -- 349
} -- 349
local function asRecord(v) -- 351
	if v ~= nil and type(v) == "table" then -- 351
		return v -- 353
	end -- 353
	return nil -- 355
end -- 351
--- 描边椭圆（Dora DrawNode.drawEllipse 仅支持填充，描边用等分折线保证锐利清晰）
local function strokeEllipse(draw, cx, cy, rx, ry, width, color, segments) -- 359
	if segments == nil then -- 359
		segments = 24 -- 367
	end -- 367
	if rx <= 0.5 or ry <= 0.5 or width <= 0.05 then -- 367
		return -- 370
	end -- 370
	local step = math.pi * 2 / segments -- 372
	local prevX = cx + rx -- 373
	local prevY = cy -- 374
	local i = 1 -- 375
	do -- 375
		i = 1 -- 376
		while i <= segments do -- 376
			local ang = i * step -- 377
			local nx = cx + math.cos(ang) * rx -- 378
			local ny = cy + math.sin(ang) * ry -- 379
			draw:drawSegment( -- 380
				Vec2(prevX, prevY), -- 380
				Vec2(nx, ny), -- 380
				width, -- 380
				color -- 380
			) -- 380
			prevX = nx -- 381
			prevY = ny -- 382
			i = i + 1 -- 376
		end -- 376
	end -- 376
end -- 359
local STONE_EDGE_FALLBACK = MING_MATERIALS.mingStoneStep.edge or PALETTE.silkDim -- 386
____exports.TowerEndingsPlugin = __TS__Class() -- 388
local TowerEndingsPlugin = ____exports.TowerEndingsPlugin -- 388
TowerEndingsPlugin.name = "TowerEndingsPlugin" -- 388
function TowerEndingsPlugin.prototype.____constructor(self) -- 388
	self.id = "fe-05-tower-endings" -- 389
	self.active = false -- 391
	self.rehearsalActive = false -- 392
	self.rehearsalRoute = "child" -- 393
	self.activeRoute = "child" -- 394
	self.seqElapsed = 0 -- 396
	self.holdElapsed = 0 -- 397
	self.animTime = 0 -- 398
	self.doorOpened = false -- 401
	self.knockCount = 0 -- 402
	self.replyKnockCount = 0 -- 403
	self.row1Written = false -- 404
	self.row2Written = false -- 405
	self.registryAppendCount = 0 -- 406
	self.staleInputMustRelease = false -- 409
	self.confirmReady = false -- 410
	self.earlyInputBlockedCount = 0 -- 411
	self.rehearsalAcknowledged = false -- 412
	self.lastRoomKey = "" -- 415
	self.indoorRetryCount = 0 -- 417
	self.doorClosedAfterRetry = false -- 418
	self.sessionId = 0 -- 419
	self.lastUiW = 1280 -- 422
	self.lastUiH = 720 -- 423
	self.lastSubtitle = "" -- 424
	self.prevPhase = "" -- 425
	self.loopsActive = false -- 426
end -- 388
function TowerEndingsPlugin.prototype.resolveRoute(self, p, view) -- 429
	if self.rehearsalActive then -- 429
		return self.rehearsalRoute -- 431
	end -- 431
	if view.storyRoute == "soldier" then -- 431
		return "soldier" -- 434
	end -- 434
	if view.storyRoute == "child" then -- 434
		return "child" -- 437
	end -- 437
	local runRec = asRecord(p.run) -- 440
	local ____asRecord_1 = asRecord -- 441
	local ____temp_0 -- 441
	if runRec ~= nil then -- 441
		____temp_0 = runRec.story -- 441
	else -- 441
		____temp_0 = nil -- 441
	end -- 441
	local storyRec = ____asRecord_1(____temp_0) -- 441
	if storyRec ~= nil and storyRec.ending == "reunion" then -- 441
		return "soldier" -- 443
	end -- 443
	return p.childMode and "child" or "soldier" -- 446
end -- 429
function TowerEndingsPlugin.prototype.clearSequenceState(self, keepIndoorDoorOpen) -- 449
	self.active = keepIndoorDoorOpen -- 450
	self.seqElapsed = keepIndoorDoorOpen and ____exports.TOWER_ENDING_TIMINGS.indoorCutSec or 0 -- 451
	self.holdElapsed = 0 -- 452
	self.doorOpened = keepIndoorDoorOpen -- 453
	self.knockCount = keepIndoorDoorOpen and 2 or 0 -- 454
	self.replyKnockCount = keepIndoorDoorOpen and 2 or 0 -- 455
	if not keepIndoorDoorOpen then -- 455
		self.row1Written = false -- 457
		self.row2Written = false -- 458
		self.registryAppendCount = 0 -- 459
	end -- 459
	self.staleInputMustRelease = true -- 461
	self.confirmReady = false -- 462
	self.earlyInputBlockedCount = 0 -- 463
	self.rehearsalAcknowledged = false -- 464
	self.lastSubtitle = "" -- 465
end -- 449
function TowerEndingsPlugin.prototype.startRehearsal(self, route, contract, opts) -- 471
	self.rehearsalActive = true -- 476
	self.rehearsalRoute = route -- 477
	self.activeRoute = route -- 478
	local tag = opts and opts.tag or (route == "child" and "fe05-F03" or "fe05-M03") -- 479
	if contract ~= nil then -- 479
		contract:enterRehearsal(tag) -- 481
		contract:setMockRoute(route) -- 482
	end -- 482
	local isIndoor = (opts and opts.indoorRetry) == true -- 484
	self.sessionId = self.sessionId + 1 -- 485
	self:clearSequenceState(isIndoor) -- 486
	self.active = true -- 487
	self.doorClosedAfterRetry = false -- 488
	if isIndoor then -- 488
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 490
	end -- 490
	if (opts and opts.seekTime) ~= nil then -- 490
		self:seekRehearsal(opts.seekTime) -- 493
	end -- 493
end -- 471
function TowerEndingsPlugin.prototype.seekRehearsal(self, seconds) -- 498
	if not self.rehearsalActive then -- 498
		return -- 500
	end -- 500
	local t = math.max(0, seconds) -- 502
	self.seqElapsed = t -- 503
	self.holdElapsed = math.max(0, t - ____exports.TOWER_ENDING_TIMINGS.divergeEndSec) -- 504
	self.active = true -- 505
	self:syncDerivedMilestones(t, self.activeRoute) -- 506
	self.confirmReady = not self.staleInputMustRelease and t >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 507
end -- 498
function TowerEndingsPlugin.prototype.triggerIndoorRetry(self) -- 511
	if not self.doorOpened and self.seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 511
		self.doorOpened = true -- 513
	end -- 513
	self.indoorRetryCount = self.indoorRetryCount + 1 -- 515
	self.doorClosedAfterRetry = false -- 516
	self.doorOpened = true -- 517
	self.active = true -- 518
	self.seqElapsed = math.max( -- 519
		____exports.TOWER_ENDING_TIMINGS.indoorCutSec, -- 519
		math.min(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.row1StartSec) -- 519
	) -- 519
	self.holdElapsed = 0 -- 520
	self.knockCount = math.max(2, self.knockCount) -- 521
	self.replyKnockCount = math.max(2, self.replyKnockCount) -- 522
	self.staleInputMustRelease = true -- 524
	self.confirmReady = false -- 525
end -- 511
function TowerEndingsPlugin.prototype.stopRehearsal(self, contract) -- 529
	self.rehearsalActive = false -- 530
	self:clearSequenceState(false) -- 531
	self.indoorRetryCount = 0 -- 532
	self.doorClosedAfterRetry = false -- 533
	if contract ~= nil then -- 533
		contract:exitRehearsal() -- 535
	end -- 535
end -- 529
function TowerEndingsPlugin.prototype.getDebugState(self) -- 539
	local route = self.activeRoute -- 540
	local lampProg = route == "child" and smoothstep(5.2, 6.75, self.seqElapsed) or 0 -- 541
	local scaled = computeScaledAnchors(self.lastUiW, self.lastUiH, lampProg) -- 544
	local visualStyle = route == "child" and "lowpoly" or "pixel" -- 545
	local needleOnDesk = route == "soldier" and self.seqElapsed >= 5.55 -- 546
	local twoHandsBowl = route == "soldier" and self.seqElapsed >= 5.95 -- 547
	return { -- 549
		active = self.active, -- 550
		isRehearsal = self.rehearsalActive, -- 551
		route = route, -- 552
		visualStyle = visualStyle, -- 553
		stage = deriveStage(self.seqElapsed, self.active), -- 554
		seqElapsed = self.seqElapsed, -- 555
		holdElapsed = self.holdElapsed, -- 556
		doorOpened = self.doorOpened, -- 557
		knockCount = self.knockCount, -- 558
		replyKnockCount = self.replyKnockCount, -- 559
		row1Written = self.row1Written, -- 560
		row1Name = self.row1Written and "小满" or "", -- 561
		row2Written = self.row2Written, -- 562
		row2Name = self.row2Written and "周戍" or "", -- 563
		row2Blank = not self.row2Written, -- 564
		hasCompletionStamp = false, -- 565
		registryRowCapacity = 2, -- 566
		registryAppendCount = self.registryAppendCount, -- 567
		lampProgress = lampProg, -- 568
		lampAtWestWindow = route == "child" and lampProg >= 0.99, -- 569
		needleCaseOnDesk = needleOnDesk, -- 570
		twoHandsHoldingBowl = twoHandsBowl, -- 571
		staleInputMustRelease = self.staleInputMustRelease, -- 572
		confirmReady = self.confirmReady, -- 573
		earlyInputBlockedCount = self.earlyInputBlockedCount, -- 574
		rehearsalAcknowledged = self.rehearsalAcknowledged, -- 575
		indoorRetryCount = self.indoorRetryCount, -- 576
		doorClosedAfterRetry = self.doorClosedAfterRetry, -- 577
		subtitleText = self.lastSubtitle, -- 578
		anchors = scaled.anchors -- 579
	} -- 579
end -- 539
function TowerEndingsPlugin.prototype.syncRuntimeHook(self) -- 583
	local g = _G -- 584
	local ____temp_8 -- 585
	if g.package ~= nil then -- 585
		____temp_8 = g.package.loaded -- 585
	else -- 585
		____temp_8 = nil -- 585
	end -- 585
	local loaded = ____temp_8 -- 585
	if loaded == nil then -- 585
		return -- 587
	end -- 587
	local rawFe = loaded["watch.fe"] -- 589
	if rawFe ~= nil and type(rawFe) == "table" then -- 589
		local watchFe = rawFe -- 591
		if watchFe.towerEndings ~= self then -- 591
			watchFe.towerEndings = self -- 593
		end -- 593
	end -- 593
end -- 583
function TowerEndingsPlugin.prototype.onBindPlay(self, p, view) -- 600
	self:syncRuntimeHook() -- 601
	self.sessionId = self.sessionId + 1 -- 602
	self.loopsActive = false -- 603
	self.prevPhase = p.phase -- 604
	if self.rehearsalActive then -- 604
		return -- 607
	end -- 607
	local route = self:resolveRoute(p, view) -- 610
	local isTower = p.room.key == "tower" -- 611
	local alreadyIndoorPhase = isTower and (p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end") -- 612
	local sameRunIndoorRetry = isTower and self.lastRoomKey == "tower" and self.doorOpened and p.run == self.lastRunRef and route == self.activeRoute and (p.checkpoint > 0 or alreadyIndoorPhase) -- 618
	self.activeRoute = route -- 625
	self.lastRoomKey = p.room.key -- 626
	self.lastRunRef = p.run -- 627
	if not isTower then -- 627
		self:clearSequenceState(false) -- 630
		self.indoorRetryCount = 0 -- 631
		self.doorClosedAfterRetry = false -- 632
		return -- 633
	end -- 633
	if sameRunIndoorRetry or alreadyIndoorPhase then -- 633
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 638
		self.doorClosedAfterRetry = false -- 639
		self:clearSequenceState(true) -- 640
		if p.phase == "tower-end" then -- 640
			self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.divergeEndSec -- 642
			self:syncDerivedMilestones(self.seqElapsed, route) -- 643
		end -- 643
		return -- 645
	end -- 645
	self:clearSequenceState(false) -- 649
	self.indoorRetryCount = 0 -- 650
	self.doorClosedAfterRetry = false -- 651
end -- 600
function TowerEndingsPlugin.prototype.update(self, ctx) -- 654
	self:syncRuntimeHook() -- 655
	self.lastUiW = ctx.uiW -- 656
	self.lastUiH = ctx.uiH -- 657
	local p = ctx.p -- 658
	if not self.rehearsalActive and p.room.key ~= "tower" then -- 658
		if self.loopsActive then -- 658
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 662
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 663
			self.loopsActive = false -- 664
		end -- 664
		self.active = false -- 666
		return -- 667
	end -- 667
	local route = self:resolveRoute(p, ctx.view) -- 670
	self.activeRoute = route -- 671
	if not self.rehearsalActive then -- 671
		self:stepLiveSync(ctx, route) -- 674
	else -- 674
		self:stepRehearsal(ctx, route) -- 676
	end -- 676
	if not self.active then -- 676
		local inInteractiveHall = not self.rehearsalActive and p.room.key == "tower" and (p.phase == "tower-enter" or p.phase == "tower-desk") -- 680
		if self.loopsActive and not inInteractiveHall then -- 680
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 683
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 684
			self.loopsActive = false -- 685
		end -- 685
		return -- 687
	end -- 687
	if not ctx.paused and ctx.worldDt > 0 then -- 687
		self.animTime = self.animTime + ctx.worldDt -- 692
		self:syncDerivedMilestones(self.seqElapsed, route) -- 693
		self:syncAudioCues(ctx.audio, ctx, route) -- 694
		self:stepInputGuard(ctx.input) -- 695
	elseif not ctx.paused then -- 695
		self:syncDerivedMilestones(self.seqElapsed, route) -- 698
		self:stepInputGuard(ctx.input) -- 699
	end -- 699
	self.lastSubtitle = self:composeSubtitle(route) -- 702
end -- 654
function TowerEndingsPlugin.prototype.stepLiveSync(self, ctx, route) -- 705
	local p = ctx.p -- 706
	local phase = p.phase -- 707
	local justEnteredKnock = self.prevPhase ~= "tower-knock" and phase == "tower-knock" -- 708
	local justEnteredEnter = self.prevPhase ~= "tower-enter" and phase == "tower-enter" -- 709
	local justEnteredGiven = self.prevPhase ~= "tower-given" and phase == "tower-given" -- 710
	local justEnteredEnd = self.prevPhase ~= "tower-end" and phase == "tower-end" -- 711
	self.prevPhase = phase -- 712
	if phase == "tower-wait" then -- 712
		self.active = false -- 716
		return -- 717
	end -- 717
	if phase == "tower-enter" or phase == "tower-desk" then -- 717
		self.doorOpened = true -- 722
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 723
		if justEnteredEnter and self.indoorRetryCount == 0 and not ctx.paused then -- 723
			local tick = p.ticks -- 725
			self:playTowerOnce( -- 726
				ctx.audio, -- 726
				"reply1", -- 726
				"sfx", -- 726
				____exports.TOWER_AUDIO_FILES.reply1, -- 726
				0.78, -- 726
				"tower:reply:1", -- 726
				tick -- 726
			) -- 726
			self:playTowerOnce( -- 727
				ctx.audio, -- 727
				"reply2", -- 727
				"sfx", -- 727
				____exports.TOWER_AUDIO_FILES.reply2, -- 727
				0.8, -- 727
				"tower:reply:2", -- 727
				tick -- 727
			) -- 727
			self:playTowerOnce( -- 728
				ctx.audio, -- 728
				"door_open", -- 728
				"sfx", -- 728
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 728
				0.84, -- 728
				"tower:door_open", -- 728
				tick -- 728
			) -- 728
		end -- 728
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.doorOpenSec) -- 730
		self.active = false -- 731
		self:syncDerivedMilestones(self.seqElapsed, route) -- 732
		return -- 733
	end -- 733
	if not self.active then -- 733
		self.active = true -- 737
		self.staleInputMustRelease = ctx.input.interact.held or ctx.input.retry.held or ctx.input.interact.pressed -- 738
		self.confirmReady = false -- 739
	end -- 739
	if justEnteredKnock then -- 739
		self.seqElapsed = p.phaseTick / 60 -- 743
		self.holdElapsed = 0 -- 744
		self.staleInputMustRelease = true -- 745
		self.confirmReady = false -- 746
	elseif justEnteredGiven then -- 746
		self.doorOpened = true -- 748
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 749
	elseif justEnteredEnd then -- 749
		self.doorOpened = true -- 751
		self.seqElapsed = math.max(self.seqElapsed, 3.6) -- 753
	end -- 753
	if not ctx.paused and #ctx.events.rawEvents > 0 then -- 753
		local i = 0 -- 758
		do -- 758
			i = 0 -- 759
			while i < #ctx.events.rawEvents do -- 759
				local ev = ctx.events.rawEvents[i + 1] -- 760
				if ev.name == "knock" then -- 760
					local cnt = type(ev.data.count) == "number" and ev.data.count or self.knockCount + 1 -- 762
					if cnt >= 1 and self.knockCount < 1 then -- 762
						self.knockCount = 1 -- 764
						self:playTowerOnce( -- 765
							ctx.audio, -- 765
							"knock1", -- 765
							"sfx", -- 765
							____exports.TOWER_AUDIO_FILES.knock1, -- 765
							0.88, -- 765
							"tower:knock:1", -- 765
							ev.tick, -- 765
							ev.seq -- 765
						) -- 765
					end -- 765
					if cnt >= 2 and self.knockCount < 2 then -- 765
						self.knockCount = 2 -- 768
						self:playTowerOnce( -- 769
							ctx.audio, -- 769
							"knock2", -- 769
							"sfx", -- 769
							____exports.TOWER_AUDIO_FILES.knock2, -- 769
							0.9, -- 769
							"tower:knock:2", -- 769
							ev.tick, -- 769
							ev.seq -- 769
						) -- 769
					end -- 769
				end -- 769
				i = i + 1 -- 759
			end -- 759
		end -- 759
	end -- 759
	if not ctx.paused and ctx.worldDt > 0 then -- 759
		if phase == "tower-knock" then -- 759
			local backendSec = math.min(____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60) -- 778
			self.seqElapsed = math.max(self.seqElapsed + ctx.worldDt, backendSec) -- 779
			if self.seqElapsed > ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 then -- 779
				self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 -- 781
			end -- 781
		else -- 781
			self.seqElapsed = self.seqElapsed + ctx.worldDt -- 784
			if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 784
				self.holdElapsed = self.holdElapsed + ctx.worldDt -- 786
			end -- 786
		end -- 786
	end -- 786
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 786
		self.doorClosedAfterRetry = true -- 792
	end -- 792
	self:syncDerivedMilestones(self.seqElapsed, route) -- 794
end -- 705
function TowerEndingsPlugin.prototype.stepRehearsal(self, ctx, route) -- 797
	self.active = true -- 798
	if not ctx.paused and ctx.worldDt > 0 then -- 798
		self.seqElapsed = self.seqElapsed + ctx.worldDt -- 800
		if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 800
			self.holdElapsed = self.holdElapsed + ctx.worldDt -- 802
		end -- 802
	end -- 802
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 802
		self.doorClosedAfterRetry = true -- 806
	end -- 806
	self:syncDerivedMilestones(self.seqElapsed, route) -- 808
end -- 797
function TowerEndingsPlugin.prototype.syncDerivedMilestones(self, t, route) -- 811
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec and self.knockCount < 1 then -- 811
		self.knockCount = 1 -- 813
	end -- 813
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec and self.knockCount < 2 then -- 813
		self.knockCount = 2 -- 816
	end -- 816
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec and self.replyKnockCount < 1 then -- 816
		self.replyKnockCount = 1 -- 819
	end -- 819
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec and self.replyKnockCount < 2 then -- 819
		self.replyKnockCount = 2 -- 822
	end -- 822
	if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 822
		self.doorOpened = true -- 825
	end -- 825
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec and not self.row1Written then -- 825
		self.row1Written = true -- 829
		self.registryAppendCount = self.registryAppendCount + 1 -- 830
	end -- 830
	if route == "soldier" and t >= 4.6 and not self.row2Written then -- 830
		self.row2Written = true -- 833
		self.registryAppendCount = self.registryAppendCount + 1 -- 834
	end -- 834
	if route == "child" and self.row2Written then -- 834
		self.row2Written = false -- 838
		self.registryAppendCount = self.row1Written and 1 or 0 -- 839
	end -- 839
end -- 811
function TowerEndingsPlugin.prototype.stepInputGuard(self, input) -- 843
	local keyHeld = input.interact.held or input.retry.held -- 844
	local keyPressed = input.interact.pressed or input.retry.pressed -- 845
	local readyTime = self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 846
	if self.staleInputMustRelease then -- 846
		if not keyHeld then -- 846
			self.staleInputMustRelease = false -- 850
		elseif keyPressed then -- 850
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 852
		end -- 852
		self.confirmReady = false -- 854
		return -- 855
	end -- 855
	if not readyTime then -- 855
		if keyPressed then -- 855
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 860
			self.staleInputMustRelease = keyHeld -- 861
		end -- 861
		self.confirmReady = false -- 863
		return -- 864
	end -- 864
	self.confirmReady = true -- 867
	if self.rehearsalActive and keyPressed then -- 867
		self.rehearsalAcknowledged = true -- 869
	end -- 869
end -- 843
function TowerEndingsPlugin.prototype.playTowerOnce(self, audio, tag, track, path, volume, cueId, tick, seq) -- 873
	if seq == nil then -- 873
		seq = -1 -- 881
	end -- 881
	local dedupeKey = (("tower:s" .. tostring(self.sessionId)) .. ":") .. tag -- 883
	audio:playOnce( -- 884
		dedupeKey, -- 884
		track, -- 884
		path, -- 884
		volume, -- 884
		cueId, -- 884
		tick, -- 884
		seq -- 884
	) -- 884
end -- 873
function TowerEndingsPlugin.prototype.syncAudioCues(self, audio, ctx, route) -- 887
	local t = self.seqElapsed -- 888
	local tick = ctx.p.ticks -- 889
	local indoorK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.5, t) -- 890
	self.loopsActive = true -- 893
	audio:playLoop( -- 894
		"tower_wind_cold", -- 894
		"wind", -- 894
		____exports.TOWER_AUDIO_FILES.windCold, -- 894
		lerp(0.36, 0.14, indoorK), -- 894
		tick -- 894
	) -- 894
	if indoorK > 0.05 then -- 894
		audio:playLoop( -- 896
			"tower_room_warm", -- 896
			"ambience", -- 896
			____exports.TOWER_AUDIO_FILES.roomWarm, -- 896
			lerp(0.06, 0.34, indoorK), -- 896
			tick -- 896
		) -- 896
	end -- 896
	if self.indoorRetryCount == 0 then -- 896
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec then -- 896
			self:playTowerOnce( -- 902
				audio, -- 902
				"knock1", -- 902
				"sfx", -- 902
				____exports.TOWER_AUDIO_FILES.knock1, -- 902
				0.88, -- 902
				"tower:knock:1", -- 902
				tick -- 902
			) -- 902
		end -- 902
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec then -- 902
			self:playTowerOnce( -- 905
				audio, -- 905
				"knock2", -- 905
				"sfx", -- 905
				____exports.TOWER_AUDIO_FILES.knock2, -- 905
				0.9, -- 905
				"tower:knock:2", -- 905
				tick -- 905
			) -- 905
		end -- 905
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 905
			self:playTowerOnce( -- 908
				audio, -- 908
				"reply1", -- 908
				"sfx", -- 908
				____exports.TOWER_AUDIO_FILES.reply1, -- 908
				0.78, -- 908
				"tower:reply:1", -- 908
				tick -- 908
			) -- 908
		end -- 908
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec then -- 908
			self:playTowerOnce( -- 911
				audio, -- 911
				"reply2", -- 911
				"sfx", -- 911
				____exports.TOWER_AUDIO_FILES.reply2, -- 911
				0.8, -- 911
				"tower:reply:2", -- 911
				tick -- 911
			) -- 911
		end -- 911
		if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 911
			self:playTowerOnce( -- 914
				audio, -- 914
				"door_open", -- 914
				"sfx", -- 914
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 914
				0.84, -- 914
				"tower:door_open", -- 914
				tick -- 914
			) -- 914
		end -- 914
	end -- 914
	if t >= 1.5 then -- 914
		self:playTowerOnce( -- 919
			audio, -- 919
			"book_open", -- 919
			"sfx", -- 919
			____exports.TOWER_AUDIO_FILES.bookOpen, -- 919
			0.82, -- 919
			"tower:book_open", -- 919
			tick -- 919
		) -- 919
	end -- 919
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 919
		self:playTowerOnce( -- 922
			audio, -- 922
			"brush1", -- 922
			"sfx", -- 922
			____exports.TOWER_AUDIO_FILES.brush1, -- 922
			0.8, -- 922
			"tower:brush:row1", -- 922
			tick -- 922
		) -- 922
	end -- 922
	if route == "child" then -- 922
		if t >= 4.35 then -- 922
			self:playTowerOnce( -- 927
				audio, -- 927
				"f03_line", -- 927
				"voice", -- 927
				____exports.TOWER_AUDIO_FILES.lineXiaomanLamp, -- 927
				0.86, -- 927
				"tower:f03:line_lamp", -- 927
				tick -- 927
			) -- 927
		end -- 927
		if t >= 4.45 then -- 927
			self:playTowerOnce( -- 930
				audio, -- 930
				"f03_bowl", -- 930
				"sfx", -- 930
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 930
				0.8, -- 930
				"tower:bowl_set", -- 930
				tick -- 930
			) -- 930
		end -- 930
		if t >= 5.2 then -- 930
			self:playTowerOnce( -- 933
				audio, -- 933
				"f03_lamp", -- 933
				"sfx", -- 933
				____exports.TOWER_AUDIO_FILES.lampMove, -- 933
				0.82, -- 933
				"tower:f03:lamp_move", -- 933
				tick -- 933
			) -- 933
		end -- 933
	else -- 933
		if t >= 4.28 then -- 933
			self:playTowerOnce( -- 937
				audio, -- 937
				"m03_line", -- 937
				"voice", -- 937
				____exports.TOWER_AUDIO_FILES.lineZhoushuName, -- 937
				0.9, -- 937
				"tower:m03:line_name", -- 937
				tick -- 937
			) -- 937
		end -- 937
		if t >= 4.62 then -- 937
			self:playTowerOnce( -- 940
				audio, -- 940
				"brush2", -- 940
				"sfx", -- 940
				____exports.TOWER_AUDIO_FILES.brush2, -- 940
				0.82, -- 940
				"tower:brush:row2", -- 940
				tick -- 940
			) -- 940
		end -- 940
		if t >= 5.55 then -- 940
			self:playTowerOnce( -- 943
				audio, -- 943
				"m03_needle", -- 943
				"sfx", -- 943
				____exports.TOWER_AUDIO_FILES.needlePlace, -- 943
				0.8, -- 943
				"tower:m03:needle_place", -- 943
				tick -- 943
			) -- 943
		end -- 943
		if t >= 6.02 then -- 943
			self:playTowerOnce( -- 946
				audio, -- 946
				"m03_bowl", -- 946
				"sfx", -- 946
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 946
				0.82, -- 946
				"tower:bowl_set", -- 946
				tick -- 946
			) -- 946
		end -- 946
	end -- 946
end -- 887
function TowerEndingsPlugin.prototype.composeSubtitle(self, route) -- 951
	local t = self.seqElapsed -- 952
	if t < ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 952
		return "[两下轻敲]  门外厚木上传来两声轻敲。" -- 954
	end -- 954
	if t < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 954
		return "[门内回敲]  静默一息，门后轻轻回敲两声。" -- 957
	end -- 957
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 957
		return route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 960
	end -- 960
	if t < ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 960
		return route == "child" and "她把针套与纸条摊在案前，守卒展开收籍末页。" or "两人站在值夜室内，守卒摊开收籍末页。" -- 965
	end -- 965
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 965
		return "守卒蘸墨提笔，在第一行写下「小满」。" -- 970
	end -- 970
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 970
		return "笔尖停在第二行上方。" -- 973
	end -- 973
	if route == "child" then -- 973
		if t < 6.7 then -- 973
			return F03_DIALOGUE -- 977
		end -- 977
		return "" -- 979
	end -- 979
	if t < 5.45 then -- 979
		return M03_DIALOGUE -- 982
	end -- 982
	if t < 6.85 then -- 982
		return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。" -- 985
	end -- 985
	return "" -- 987
end -- 951
function TowerEndingsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 992
	if not self.active then -- 992
		return false -- 1000
	end -- 1000
	local route = self.activeRoute -- 1003
	local t = self.seqElapsed -- 1004
	local lampProg = route == "child" and smoothstep(5.2, 6.75, t) or 0 -- 1005
	local scaled = computeScaledAnchors(ctx.uiW, ctx.uiH, lampProg) -- 1006
	local s = scaled.s -- 1007
	local ox = scaled.ox -- 1008
	local oy = scaled.oy -- 1009
	uiDraw:drawRect( -- 1012
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1012
		Color(8, 10, 16, 255) -- 1012
	) -- 1012
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1012
		self:drawAct1PorchAndDoor( -- 1016
			uiDraw, -- 1016
			uiInkDraw, -- 1016
			uiArt, -- 1016
			uiGlow, -- 1016
			ctx, -- 1016
			route, -- 1016
			s, -- 1016
			ox, -- 1016
			oy -- 1016
		) -- 1016
		local fadeOut = smoothstep(1.22, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec, t) -- 1018
		if fadeOut > 0.01 then -- 1018
			uiInkDraw:drawRect( -- 1020
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1020
				Color( -- 1020
					8, -- 1020
					10, -- 1020
					16, -- 1020
					math.floor(230 * fadeOut + 0.5) -- 1020
				) -- 1020
			) -- 1020
		end -- 1020
	else -- 1020
		self:drawAct2And3Guardroom( -- 1024
			uiDraw, -- 1024
			uiInkDraw, -- 1024
			uiArt, -- 1024
			uiGlow, -- 1024
			ctx, -- 1024
			route, -- 1024
			lampProg, -- 1024
			s, -- 1024
			ox, -- 1024
			oy -- 1024
		) -- 1024
		local fadeIn = 1 - smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.24, t) -- 1025
		if fadeIn > 0.01 then -- 1025
			uiInkDraw:drawRect( -- 1027
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1027
				Color( -- 1027
					8, -- 1027
					10, -- 1027
					16, -- 1027
					math.floor(220 * fadeIn + 0.5) -- 1027
				) -- 1027
			) -- 1027
		end -- 1027
	end -- 1027
	local barH = math.floor(____exports.TOWER_SHOT_LAYOUT.letterboxH * s + 0.5) -- 1032
	uiInkDraw:drawRect( -- 1033
		Rect(0, ctx.uiH - barH, ctx.uiW, barH), -- 1033
		Color(7, 9, 14, 248) -- 1033
	) -- 1033
	uiInkDraw:drawRect( -- 1034
		Rect(0, 0, ctx.uiW, barH), -- 1034
		Color(7, 9, 14, 248) -- 1034
	) -- 1034
	uiInkDraw:drawSegment( -- 1035
		Vec2(0, ctx.uiH - barH), -- 1035
		Vec2(ctx.uiW, ctx.uiH - barH), -- 1035
		0.9, -- 1035
		toColor(PALETTE.silkDim, 82) -- 1035
	) -- 1035
	uiInkDraw:drawSegment( -- 1036
		Vec2(0, barH), -- 1036
		Vec2(ctx.uiW, barH), -- 1036
		0.9, -- 1036
		toColor(PALETTE.silkDim, 82) -- 1036
	) -- 1036
	self:drawDialogueSubtitle( -- 1039
		uiDraw, -- 1039
		uiInkDraw, -- 1039
		uiArt, -- 1039
		ctx, -- 1039
		route, -- 1039
		s, -- 1039
		barH -- 1039
	) -- 1039
	return true -- 1041
end -- 992
function TowerEndingsPlugin.prototype.drawAct1PorchAndDoor(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1046
	local t = self.seqElapsed -- 1057
	local isLowpoly = route == "child" -- 1058
	local openK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, 1.24, t) -- 1059
	local doorCx = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s -- 1060
	local threshY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s -- 1061
	local doorW = ____exports.TOWER_SHOT_LAYOUT.doorW * s -- 1062
	local doorH = ____exports.TOWER_SHOT_LAYOUT.doorH * s -- 1063
	local doorL = doorCx - doorW * 0.5 -- 1064
	local doorR = doorCx + doorW * 0.5 -- 1065
	local k1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock1Sec) / 0.055) ^ 2) -- 1068
	local k2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock2Sec) / 0.055) ^ 2) -- 1069
	local r1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply1Sec) / 0.06) ^ 2) -- 1070
	local r2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply2Sec) / 0.06) ^ 2) -- 1071
	local doorShakeX = (k1Pulse + k2Pulse) * 2.4 * s * math.sin(t * 95) + (r1Pulse + r2Pulse) * 1.4 * s * math.sin(t * 80) -- 1072
	if isLowpoly then -- 1072
		local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, openK * 0.62) -- 1077
		fillVGradRect( -- 1078
			uiDraw, -- 1079
			0, -- 1079
			0, -- 1079
			ctx.uiW, -- 1079
			ctx.uiH, -- 1079
			Color(12, 16, 26, 255), -- 1080
			Color(20, 28, 44, 255) -- 1081
		) -- 1081
		local wallCol = shadeSurface( -- 1084
			MING_MATERIALS.mingBrickDark.base, -- 1084
			vec3(0, 0, -1), -- 1084
			24, -- 1084
			1, -- 1084
			light, -- 1084
			MING_MATERIALS.mingBrickDark -- 1084
		) -- 1084
		local jambCol = shadeSurface( -- 1085
			MING_MATERIALS.mingBrick.base, -- 1085
			vec3(0.75, 0.15, -0.64), -- 1085
			10, -- 1085
			1, -- 1085
			light, -- 1085
			MING_MATERIALS.mingBrick -- 1085
		) -- 1085
		local jambRCol = shadeSurface( -- 1086
			MING_MATERIALS.mingBrick.base, -- 1086
			vec3(-0.75, 0.15, -0.64), -- 1086
			10, -- 1086
			1, -- 1086
			light, -- 1086
			MING_MATERIALS.mingBrick -- 1086
		) -- 1086
		local lintelCol = shadeSurface( -- 1087
			MING_MATERIALS.mingStoneStep.base, -- 1087
			vec3(0, -0.55, -0.83), -- 1087
			6, -- 1087
			1, -- 1087
			light, -- 1087
			MING_MATERIALS.mingStoneStep -- 1087
		) -- 1087
		local stepCol = shadeSurface( -- 1088
			MING_MATERIALS.mingStoneStep.base, -- 1088
			vec3(0, 0.92, -0.39), -- 1088
			0, -- 1088
			1, -- 1088
			light, -- 1088
			MING_MATERIALS.mingStoneStep -- 1088
		) -- 1088
		uiDraw:drawRect( -- 1090
			Rect(0, threshY, doorL - 26 * s, ctx.uiH - threshY), -- 1090
			toColor(wallCol) -- 1090
		) -- 1090
		uiDraw:drawRect( -- 1091
			Rect(doorR + 26 * s, threshY, ctx.uiW - (doorR + 26 * s), ctx.uiH - threshY), -- 1091
			toColor(wallCol) -- 1091
		) -- 1091
		uiDraw:drawPolygon( -- 1093
			{ -- 1093
				Vec2(doorL - 26 * s, threshY), -- 1094
				Vec2(doorL, threshY + 12 * s), -- 1095
				Vec2(doorL, threshY + doorH - 8 * s), -- 1096
				Vec2(doorL - 26 * s, threshY + doorH + 18 * s) -- 1097
			}, -- 1097
			toColor(jambCol), -- 1098
			1, -- 1098
			toColor(PALETTE.silkDim, 68) -- 1098
		) -- 1098
		uiDraw:drawPolygon( -- 1099
			{ -- 1099
				Vec2(doorR + 26 * s, threshY), -- 1100
				Vec2(doorR, threshY + 12 * s), -- 1101
				Vec2(doorR, threshY + doorH - 8 * s), -- 1102
				Vec2(doorR + 26 * s, threshY + doorH + 18 * s) -- 1103
			}, -- 1103
			toColor(jambRCol), -- 1104
			1, -- 1104
			toColor(PALETTE.silkDim, 68) -- 1104
		) -- 1104
		uiDraw:drawPolygon( -- 1106
			{ -- 1106
				Vec2(doorL - 44 * s, threshY + doorH + 18 * s), -- 1107
				Vec2(doorR + 44 * s, threshY + doorH + 18 * s), -- 1108
				Vec2(doorR + 58 * s, threshY + doorH + 92 * s), -- 1109
				Vec2(doorL - 58 * s, threshY + doorH + 92 * s) -- 1110
			}, -- 1110
			toColor(lintelCol), -- 1111
			1.1, -- 1111
			toColor(STONE_EDGE_FALLBACK, 130) -- 1111
		) -- 1111
		uiDraw:drawRect( -- 1113
			Rect(0, 0, ctx.uiW, threshY), -- 1113
			Color(16, 20, 30, 255) -- 1113
		) -- 1113
		uiDraw:drawPolygon( -- 1114
			{ -- 1114
				Vec2(doorL - 58 * s, threshY - 20 * s), -- 1115
				Vec2(doorR + 58 * s, threshY - 20 * s), -- 1116
				Vec2(doorR + 28 * s, threshY + 12 * s), -- 1117
				Vec2(doorL - 28 * s, threshY + 12 * s) -- 1118
			}, -- 1118
			toColor(stepCol), -- 1119
			1, -- 1119
			toColor(STONE_EDGE_FALLBACK, 150) -- 1119
		) -- 1119
		uiDraw:drawPolygon( -- 1121
			{ -- 1121
				Vec2(0, 0), -- 1122
				Vec2(142 * s, 0), -- 1123
				Vec2(114 * s, ctx.uiH), -- 1124
				Vec2(0, ctx.uiH) -- 1125
			}, -- 1125
			Color(10, 14, 22, 220) -- 1126
		) -- 1126
		uiDraw:drawPolygon( -- 1127
			{ -- 1127
				Vec2(ctx.uiW - 142 * s, 0), -- 1128
				Vec2(ctx.uiW, 0), -- 1129
				Vec2(ctx.uiW, ctx.uiH), -- 1130
				Vec2(ctx.uiW - 114 * s, ctx.uiH) -- 1131
			}, -- 1131
			Color(10, 14, 22, 220) -- 1132
		) -- 1132
	else -- 1132
		fillVGradRect( -- 1135
			uiDraw, -- 1136
			0, -- 1136
			0, -- 1136
			ctx.uiW, -- 1136
			ctx.uiH, -- 1136
			Color(18, 22, 32, 255), -- 1137
			Color(32, 38, 52, 255) -- 1138
		) -- 1138
		uiDraw:drawPolygon( -- 1141
			{ -- 1141
				Vec2(0, threshY), -- 1142
				Vec2(doorL, threshY), -- 1143
				Vec2(doorL, threshY + 188 * s), -- 1144
				Vec2(doorL * 0.55, threshY + 230 * s), -- 1145
				Vec2(doorL * 0.22, threshY + 172 * s), -- 1146
				Vec2(0, threshY + 196 * s) -- 1147
			}, -- 1147
			Color(26, 30, 40, 235) -- 1148
		) -- 1148
		uiDraw:drawPolygon( -- 1149
			{ -- 1149
				Vec2(doorR, threshY), -- 1150
				Vec2(ctx.uiW, threshY), -- 1151
				Vec2(ctx.uiW, threshY + 218 * s), -- 1152
				Vec2(doorR + (ctx.uiW - doorR) * 0.56, threshY + 248 * s), -- 1153
				Vec2(doorR, threshY + 178 * s) -- 1154
			}, -- 1154
			Color(26, 30, 40, 235) -- 1155
		) -- 1155
		uiDraw:drawRect( -- 1157
			Rect(0, threshY, doorL, ctx.uiH - threshY), -- 1157
			Color(54, 56, 62, 255), -- 1157
			1, -- 1157
			Color(88, 90, 96, 155) -- 1157
		) -- 1157
		uiDraw:drawRect( -- 1158
			Rect(doorR, threshY, ctx.uiW - doorR, ctx.uiH - threshY), -- 1158
			Color(54, 56, 62, 255), -- 1158
			1, -- 1158
			Color(88, 90, 96, 155) -- 1158
		) -- 1158
		uiDraw:drawRect( -- 1159
			Rect(doorL - 28 * s, threshY + doorH, doorW + 56 * s, 68 * s), -- 1159
			Color(72, 68, 62, 255), -- 1159
			1, -- 1159
			Color(124, 114, 100, 175) -- 1159
		) -- 1159
		local row = 0 -- 1160
		do -- 1160
			row = 0 -- 1161
			while row < 10 do -- 1161
				local by = threshY + row * 46 * s -- 1162
				uiDraw:drawSegment( -- 1163
					Vec2(0, by), -- 1163
					Vec2(doorL, by), -- 1163
					1, -- 1163
					Color(34, 36, 42, 175) -- 1163
				) -- 1163
				uiDraw:drawSegment( -- 1164
					Vec2(doorR, by), -- 1164
					Vec2(ctx.uiW, by), -- 1164
					1, -- 1164
					Color(34, 36, 42, 175) -- 1164
				) -- 1164
				local stag = row % 2 * 34 * s -- 1165
				local col = 0 -- 1166
				do -- 1166
					col = 0 -- 1167
					while col < 7 do -- 1167
						local lx = stag + col * 68 * s -- 1168
						if lx > 4 * s and lx < doorL - 4 * s then -- 1168
							uiDraw:drawSegment( -- 1170
								Vec2(lx, by), -- 1170
								Vec2(lx, by + 46 * s), -- 1170
								0.9, -- 1170
								Color(36, 38, 44, 130) -- 1170
							) -- 1170
						end -- 1170
						local rx = doorR + stag + col * 68 * s -- 1172
						if rx > doorR + 4 * s and rx < ctx.uiW - 4 * s then -- 1172
							uiDraw:drawSegment( -- 1174
								Vec2(rx, by), -- 1174
								Vec2(rx, by + 46 * s), -- 1174
								0.9, -- 1174
								Color(36, 38, 44, 130) -- 1174
							) -- 1174
						end -- 1174
						col = col + 1 -- 1167
					end -- 1167
				end -- 1167
				row = row + 1 -- 1161
			end -- 1161
		end -- 1161
		uiDraw:drawRect( -- 1179
			Rect(0, 0, ctx.uiW, threshY), -- 1179
			Color(28, 26, 28, 255) -- 1179
		) -- 1179
		uiDraw:drawRect( -- 1180
			Rect(doorL - 36 * s, threshY - 12 * s, doorW + 72 * s, 22 * s), -- 1180
			Color(96, 94, 92, 255), -- 1180
			1, -- 1180
			Color(156, 152, 144, 175) -- 1180
		) -- 1180
	end -- 1180
	local innerWarm = 0.22 + openK * 0.78 + (r1Pulse + r2Pulse) * 0.14 -- 1184
	fillVGradRect( -- 1185
		uiDraw, -- 1186
		doorL, -- 1186
		threshY + 8 * s, -- 1186
		doorW, -- 1186
		doorH - 8 * s, -- 1186
		Color( -- 1187
			46, -- 1187
			32, -- 1187
			20, -- 1187
			math.floor(255 * math.min(1, innerWarm + 0.15) + 0.5) -- 1187
		), -- 1187
		Color( -- 1188
			118, -- 1188
			82, -- 1188
			42, -- 1188
			math.floor(255 * math.min(1, innerWarm) + 0.5) -- 1188
		) -- 1188
	) -- 1188
	local leafW = math.max(26 * s, doorW * (1 - openK * 0.76)) -- 1192
	local leafX = doorL + doorShakeX * (1 - openK) -- 1193
	local woodCol = isLowpoly and toColor(shadeSurface( -- 1194
		MING_MATERIALS.mingTimberDark.base, -- 1195
		vec3(-0.2, 0.25, -0.95), -- 1195
		4, -- 1195
		1, -- 1195
		TOWER_WEST_LAMP_LIGHT, -- 1195
		MING_MATERIALS.mingTimberDark -- 1195
	)) or Color(76, 54, 38, 255) -- 1195
	uiDraw:drawRect( -- 1197
		Rect(leafX, threshY + 12 * s, leafW, doorH - 14 * s), -- 1198
		woodCol, -- 1199
		1.4, -- 1200
		Color(138, 106, 74, 185) -- 1201
	) -- 1201
	local planks = 4 -- 1204
	local pi = 1 -- 1205
	do -- 1205
		pi = 1 -- 1206
		while pi < planks do -- 1206
			local px = leafX + leafW * pi / planks -- 1207
			uiDraw:drawSegment( -- 1208
				Vec2(px, threshY + 14 * s), -- 1208
				Vec2(px, threshY + doorH - 4 * s), -- 1208
				1.1, -- 1208
				Color(38, 26, 18, 185) -- 1208
			) -- 1208
			pi = pi + 1 -- 1206
		end -- 1206
	end -- 1206
	uiDraw:drawRect( -- 1210
		Rect(leafX + 4 * s, threshY + doorH * 0.24, leafW - 8 * s, 10 * s), -- 1210
		Color(54, 38, 26, 225) -- 1210
	) -- 1210
	uiDraw:drawRect( -- 1211
		Rect(leafX + 4 * s, threshY + doorH * 0.74, leafW - 8 * s, 10 * s), -- 1211
		Color(54, 38, 26, 225) -- 1211
	) -- 1211
	local ringX = leafX + leafW * 0.72 -- 1213
	local ringY = threshY + doorH * 0.56 -- 1214
	uiDraw:drawRect( -- 1215
		Rect(ringX - 6 * s, ringY + 4 * s, 12 * s, 12 * s), -- 1215
		Color(42, 46, 52, 235), -- 1215
		1, -- 1215
		Color(96, 100, 108, 170) -- 1215
	) -- 1215
	strokeEllipse( -- 1216
		uiDraw, -- 1216
		ringX, -- 1216
		ringY - 2 * s, -- 1216
		8 * s, -- 1216
		9 * s, -- 1216
		1.8 * s, -- 1216
		Color(108, 112, 118, 195), -- 1216
		16 -- 1216
	) -- 1216
	local seamGlowA = math.floor(92 + openK * 145 + (r1Pulse + r2Pulse) * 48 + 0.5) -- 1219
	fillRadialGlow( -- 1220
		uiGlow, -- 1221
		doorCx + openK * 24 * s, -- 1221
		threshY + 14 * s, -- 1221
		(92 + openK * 120) * s, -- 1222
		(26 + openK * 58) * s, -- 1222
		Color( -- 1223
			246, -- 1223
			204, -- 1223
			134, -- 1223
			math.min(220, seamGlowA) -- 1223
		), -- 1223
		Color(220, 156, 72, 0), -- 1224
		18 -- 1225
	) -- 1225
	local kx = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s -- 1229
	local ky = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s -- 1230
	if k1Pulse > 0.08 or k2Pulse > 0.08 then -- 1230
		local amp = math.max(k1Pulse, k2Pulse) -- 1232
		local r = (18 + (1 - amp) * 34) * s -- 1233
		strokeEllipse( -- 1234
			uiInkDraw, -- 1234
			kx + 24 * s, -- 1234
			ky, -- 1234
			r, -- 1234
			r * 0.85, -- 1234
			1.8 * s, -- 1234
			toColor( -- 1234
				PALETTE.amberCore, -- 1234
				math.floor(210 * amp + 0.5) -- 1234
			), -- 1234
			24 -- 1234
		) -- 1234
	end -- 1234
	if r1Pulse > 0.08 or r2Pulse > 0.08 then -- 1234
		local amp = math.max(r1Pulse, r2Pulse) -- 1237
		local r = (24 + (1 - amp) * 42) * s -- 1238
		strokeEllipse( -- 1239
			uiInkDraw, -- 1239
			doorCx + 30 * s, -- 1239
			ky + 16 * s, -- 1239
			r, -- 1239
			r * 0.9, -- 1239
			1.6 * s, -- 1239
			toColor( -- 1239
				PALETTE.amber, -- 1239
				math.floor(185 * amp + 0.5) -- 1239
			), -- 1239
			24 -- 1239
		) -- 1239
	end -- 1239
	if openK > 0.05 then -- 1239
		local lanX = ox + ____exports.TOWER_SHOT_LAYOUT.doorLanternX * s + (1 - openK) * 42 * s -- 1244
		local lanY = oy + ____exports.TOWER_SHOT_LAYOUT.doorLanternY * s -- 1245
		uiInkDraw:drawPolygon( -- 1247
			{ -- 1247
				Vec2(lanX + 76 * s, lanY + 42 * s), -- 1248
				Vec2(lanX + 12 * s, lanY + 34 * s), -- 1249
				Vec2(lanX + 8 * s, lanY + 12 * s), -- 1250
				Vec2(lanX + 78 * s, lanY + 12 * s) -- 1251
			}, -- 1251
			Color( -- 1252
				54, -- 1252
				48, -- 1252
				44, -- 1252
				math.floor(240 * openK + 0.5) -- 1252
			), -- 1252
			1, -- 1252
			Color( -- 1252
				98, -- 1252
				86, -- 1252
				74, -- 1252
				math.floor(180 * openK + 0.5) -- 1252
			) -- 1252
		) -- 1252
		self:drawMingLantern( -- 1253
			uiInkDraw, -- 1253
			uiGlow, -- 1253
			lanX, -- 1253
			lanY - 14 * s, -- 1253
			1.08 * s, -- 1253
			openK, -- 1253
			1 -- 1253
		) -- 1253
		fillRadialGlow( -- 1255
			uiGlow, -- 1256
			kx + 12 * s, -- 1256
			ky - 14 * s, -- 1256
			148 * s, -- 1257
			128 * s, -- 1257
			Color( -- 1258
				246, -- 1258
				208, -- 1258
				142, -- 1258
				math.floor(98 * openK + 0.5) -- 1258
			), -- 1258
			Color(232, 174, 92, 0), -- 1259
			18 -- 1260
		) -- 1260
	end -- 1260
	local stepInX = openK * 44 * s -- 1265
	local xiaomanX = doorCx - 66 * s + stepInX -- 1266
	local xiaomanY = threshY - 2 * s -- 1267
	uiDraw:drawEllipse( -- 1269
		Vec2(xiaomanX, xiaomanY + 2 * s), -- 1269
		34 * s, -- 1269
		8 * s, -- 1269
		Color(4, 6, 12, 190) -- 1269
	) -- 1269
	local childSlot = (k1Pulse > 0.25 or k2Pulse > 0.25) and "child_knock" or (openK > 0.45 and "child_offer" or "child_idle") -- 1270
	uiArt:tryPlace( -- 1271
		childSlot, -- 1271
		"fe05_porch_child", -- 1271
		xiaomanX, -- 1271
		xiaomanY, -- 1271
		108 * s, -- 1271
		148 * s, -- 1271
		{facing = 1, opacity = 0.98, layer = 2} -- 1271
	) -- 1271
	if openK > 0.15 then -- 1271
		local wristX = xiaomanX + 22 * s -- 1276
		local wristY = xiaomanY + 76 * s -- 1277
		uiInkDraw:drawRect( -- 1278
			Rect(wristX - 7 * s, wristY - 5 * s, 14 * s, 11 * s), -- 1279
			Color( -- 1280
				142, -- 1280
				118, -- 1280
				84, -- 1280
				math.floor(245 * openK + 0.5) -- 1280
			), -- 1280
			1, -- 1281
			Color( -- 1282
				222, -- 1282
				192, -- 1282
				128, -- 1282
				math.floor(235 * openK + 0.5) -- 1282
			) -- 1282
		) -- 1282
		uiInkDraw:drawSegment( -- 1284
			Vec2(wristX - 8 * s, wristY), -- 1285
			Vec2(wristX + 8 * s, wristY + 2 * s), -- 1286
			2 * s, -- 1287
			toColor( -- 1288
				CUFF_PALETTE.childCord, -- 1288
				math.floor(240 * openK + 0.5) -- 1288
			) -- 1288
		) -- 1288
	end -- 1288
	if route == "soldier" then -- 1288
		local zhouX = xiaomanX - 72 * s -- 1294
		local zhouY = threshY - 2 * s -- 1295
		uiDraw:drawEllipse( -- 1296
			Vec2(zhouX, zhouY + 2 * s), -- 1296
			42 * s, -- 1296
			9 * s, -- 1296
			Color(4, 6, 12, 190) -- 1296
		) -- 1296
		uiArt:tryPlace( -- 1297
			"soldier_idle", -- 1297
			"fe05_porch_soldier", -- 1297
			zhouX, -- 1297
			zhouY, -- 1297
			146 * s, -- 1297
			206 * s, -- 1297
			{facing = 1, opacity = 0.98, layer = 2} -- 1297
		) -- 1297
		local handMidX = (zhouX + xiaomanX) * 0.5 + 4 * s -- 1301
		local handMidY = threshY + 66 * s -- 1302
		uiInkDraw:drawSegment( -- 1303
			Vec2(zhouX + 20 * s, threshY + 106 * s), -- 1304
			Vec2(handMidX - 2 * s, handMidY), -- 1305
			6.2 * s, -- 1306
			toColor(CUFF_PALETTE.indigoBase, 245) -- 1307
		) -- 1307
		uiInkDraw:drawSegment( -- 1309
			Vec2(handMidX - 9 * s, handMidY + 9 * s), -- 1310
			Vec2(handMidX - 3 * s, handMidY + 13 * s), -- 1311
			1.9 * s, -- 1312
			toColor(CUFF_PALETTE.stitchThread, 240) -- 1313
		) -- 1313
		uiInkDraw:drawSegment( -- 1315
			Vec2(xiaomanX - 14 * s, threshY + 78 * s), -- 1316
			Vec2(handMidX + 2 * s, handMidY), -- 1317
			4.8 * s, -- 1318
			toColor(CUFF_PALETTE.childSleeve, 245) -- 1319
		) -- 1319
		uiInkDraw:drawDot( -- 1321
			Vec2(handMidX, handMidY), -- 1321
			4.8 * s, -- 1321
			toColor(CUFF_PALETTE.skinLight, 245) -- 1321
		) -- 1321
	end -- 1321
end -- 1046
function TowerEndingsPlugin.prototype.drawAct2And3Guardroom(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy) -- 1327
	local t = self.seqElapsed -- 1339
	local isLowpoly = route == "child" -- 1340
	local deskY = oy + ____exports.TOWER_SHOT_LAYOUT.deskTopY * s -- 1341
	if isLowpoly then -- 1341
		self:drawF03LowpolyRoomAndWindow( -- 1345
			uiDraw, -- 1345
			uiGlow, -- 1345
			ctx, -- 1345
			lampProg, -- 1345
			s, -- 1345
			ox, -- 1345
			oy -- 1345
		) -- 1345
	else -- 1345
		self:drawM03PixelRoomAndWindow( -- 1347
			uiDraw, -- 1347
			uiArt, -- 1347
			uiGlow, -- 1347
			ctx, -- 1347
			s, -- 1347
			ox, -- 1347
			oy -- 1347
		) -- 1347
	end -- 1347
	local deskTopCol = isLowpoly and toColor(shadeSurface( -- 1351
		MING_MATERIALS.mingTimber.base, -- 1353
		vec3(-0.25, 0.9, -0.35), -- 1354
		0, -- 1355
		1, -- 1356
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1357
		MING_MATERIALS.mingTimber -- 1358
	)) or Color(86, 60, 42, 255) -- 1358
	local deskFrontCol = isLowpoly and toColor(shadeSurface( -- 1361
		MING_MATERIALS.mingTimberDark.base, -- 1363
		vec3(0, 0.1, -0.99), -- 1364
		-4, -- 1364
		1, -- 1366
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1367
		MING_MATERIALS.mingTimberDark -- 1368
	)) or Color(52, 36, 26, 255) -- 1368
	uiDraw:drawPolygon( -- 1373
		{ -- 1373
			Vec2(0, deskY - 120 * s), -- 1374
			Vec2(ctx.uiW, deskY - 120 * s), -- 1375
			Vec2(ctx.uiW, deskY + 42 * s), -- 1376
			Vec2(0, deskY + 42 * s) -- 1377
		}, -- 1377
		deskTopCol -- 1378
	) -- 1378
	uiDraw:drawRect( -- 1379
		Rect(0, 0, ctx.uiW, deskY - 118 * s), -- 1379
		deskFrontCol -- 1379
	) -- 1379
	uiDraw:drawSegment( -- 1380
		Vec2(0, deskY + 42 * s), -- 1380
		Vec2(ctx.uiW, deskY + 42 * s), -- 1380
		1.6 * s, -- 1380
		Color(158, 126, 92, 165) -- 1380
	) -- 1380
	uiDraw:drawSegment( -- 1381
		Vec2(0, deskY - 118 * s), -- 1381
		Vec2(ctx.uiW, deskY - 118 * s), -- 1381
		2 * s, -- 1381
		Color(172, 138, 102, 155) -- 1381
	) -- 1381
	local inkX = ox + ____exports.TOWER_SHOT_LAYOUT.inkstoneX * s -- 1384
	local inkY = oy + ____exports.TOWER_SHOT_LAYOUT.inkstoneY * s -- 1385
	uiDraw:drawEllipse( -- 1386
		Vec2(inkX + 3 * s, inkY - 18 * s), -- 1386
		44 * s, -- 1386
		11 * s, -- 1386
		Color(10, 10, 14, 145) -- 1386
	) -- 1386
	uiDraw:drawPolygon( -- 1387
		{ -- 1387
			Vec2(inkX - 38 * s, inkY - 18 * s), -- 1388
			Vec2(inkX + 38 * s, inkY - 18 * s), -- 1389
			Vec2(inkX + 32 * s, inkY + 18 * s), -- 1390
			Vec2(inkX - 32 * s, inkY + 18 * s) -- 1391
		}, -- 1391
		Color(38, 44, 52, 255), -- 1392
		1.2, -- 1392
		Color(96, 106, 118, 185) -- 1392
	) -- 1392
	uiDraw:drawEllipse( -- 1393
		Vec2(inkX, inkY + 1 * s), -- 1393
		22 * s, -- 1393
		10 * s, -- 1393
		Color(12, 14, 18, 255) -- 1393
	) -- 1393
	strokeEllipse( -- 1394
		uiDraw, -- 1394
		inkX, -- 1394
		inkY + 1 * s, -- 1394
		22 * s, -- 1394
		10 * s, -- 1394
		1.1 * s, -- 1394
		Color(76, 86, 98, 165), -- 1394
		18 -- 1394
	) -- 1394
	local lx = isLowpoly and ox + lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s or ox + ____exports.TOWER_SHOT_LAYOUT.lampDeskX * s -- 1397
	local ly = isLowpoly and oy + (lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34) * s or oy + ____exports.TOWER_SHOT_LAYOUT.lampDeskY * s -- 1400
	local lampWarmth = isLowpoly and 0.45 + 0.55 * lampProg or 0.92 -- 1403
	self:drawMingLantern( -- 1404
		uiInkDraw, -- 1404
		uiGlow, -- 1404
		lx, -- 1404
		ly, -- 1404
		1.02 * s, -- 1404
		1, -- 1404
		lampWarmth -- 1404
	) -- 1404
	if isLowpoly and lampProg > 0.04 then -- 1404
		local beamA = math.floor(62 * lampProg + 0.5) -- 1408
		fillGradQuad( -- 1409
			uiGlow, -- 1410
			lx + 10 * s, -- 1411
			ly + 30 * s, -- 1411
			Color(248, 206, 134, beamA), -- 1411
			lx + 10 * s, -- 1412
			ly - 32 * s, -- 1412
			Color( -- 1412
				248, -- 1412
				206, -- 1412
				134, -- 1412
				math.floor(beamA * 0.72 + 0.5) -- 1412
			), -- 1412
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.92) * s, -- 1413
			oy + (____exports.TOWER_SHOT_LAYOUT.row2Y - 58) * s, -- 1413
			Color(242, 198, 124, 0), -- 1413
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.85) * s, -- 1414
			oy + (____exports.TOWER_SHOT_LAYOUT.row1Y + 48) * s, -- 1414
			Color(242, 198, 124, 0) -- 1414
		) -- 1414
	end -- 1414
	local bookReveal = smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t) -- 1419
	if bookReveal > 0.02 then -- 1419
		self:drawRegisterBook( -- 1421
			uiDraw, -- 1421
			uiInkDraw, -- 1421
			uiArt, -- 1421
			uiGlow, -- 1421
			ctx, -- 1421
			route, -- 1421
			bookReveal, -- 1421
			lampProg, -- 1421
			s, -- 1421
			ox, -- 1421
			oy -- 1421
		) -- 1421
	end -- 1421
	self:drawDeskPropsAndBowl( -- 1425
		uiDraw, -- 1425
		uiInkDraw, -- 1425
		uiGlow, -- 1425
		route, -- 1425
		s, -- 1425
		ox, -- 1425
		oy -- 1425
	) -- 1425
end -- 1327
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiGlow, ctx, lampProg, s, ox, oy) -- 1428
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1437
	local wallTop = lerpRGBA( -- 1438
		rgba(18, 24, 38, 255), -- 1438
		rgba(46, 36, 28, 255), -- 1438
		lampProg -- 1438
	) -- 1438
	local wallBot = lerpRGBA( -- 1439
		rgba(12, 16, 26, 255), -- 1439
		rgba(28, 22, 20, 255), -- 1439
		lampProg -- 1439
	) -- 1439
	fillVGradRect( -- 1440
		uiDraw, -- 1440
		0, -- 1440
		0, -- 1440
		ctx.uiW, -- 1440
		ctx.uiH, -- 1440
		toColor(wallBot), -- 1440
		toColor(wallTop) -- 1440
	) -- 1440
	local beamCol = shadeSurface( -- 1443
		MING_MATERIALS.mingTimberDark.base, -- 1443
		vec3(-0.3, -0.6, -0.74), -- 1443
		18, -- 1443
		1, -- 1443
		light, -- 1443
		MING_MATERIALS.mingTimberDark -- 1443
	) -- 1443
	uiDraw:drawPolygon( -- 1444
		{ -- 1444
			Vec2(0, ctx.uiH - 96 * s), -- 1445
			Vec2(ctx.uiW, ctx.uiH - 72 * s), -- 1446
			Vec2(ctx.uiW, ctx.uiH - 42 * s), -- 1447
			Vec2(0, ctx.uiH - 42 * s) -- 1448
		}, -- 1448
		toColor(beamCol) -- 1449
	) -- 1449
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1452
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1453
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1454
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1455
	local embrasure = 24 * s -- 1456
	fillVGradRect( -- 1459
		uiDraw, -- 1459
		wx, -- 1459
		wy, -- 1459
		ww, -- 1459
		wh, -- 1459
		Color(34, 44, 62, 255), -- 1459
		Color(16, 24, 40, 255) -- 1459
	) -- 1459
	uiDraw:drawPolygon( -- 1460
		{ -- 1460
			Vec2(wx, wy), -- 1461
			Vec2(wx + ww, wy), -- 1462
			Vec2(wx + ww, wy + wh * 0.34), -- 1463
			Vec2(wx + ww * 0.56, wy + wh * 0.42), -- 1464
			Vec2(wx + ww * 0.22, wy + wh * 0.28), -- 1465
			Vec2(wx, wy + wh * 0.36) -- 1466
		}, -- 1466
		Color(20, 26, 38, 240) -- 1467
	) -- 1467
	if lampProg > 0.12 then -- 1467
		fillRadialGlow( -- 1470
			uiGlow, -- 1471
			wx + ww * 0.5, -- 1471
			wy + 26 * s, -- 1471
			ww * 0.65, -- 1472
			wh * 0.55, -- 1472
			Color( -- 1473
				248, -- 1473
				206, -- 1473
				134, -- 1473
				math.floor(92 * lampProg + 0.5) -- 1473
			), -- 1473
			Color(232, 174, 88, 0), -- 1474
			16 -- 1475
		) -- 1475
	end -- 1475
	local leftWall = shadeSurface( -- 1480
		MING_MATERIALS.mingBrick.base, -- 1480
		vec3(0.84, 0.22, -0.49), -- 1480
		10, -- 1480
		1, -- 1480
		light, -- 1480
		MING_MATERIALS.mingBrick -- 1480
	) -- 1480
	local rightWall = shadeSurface( -- 1481
		MING_MATERIALS.mingBrick.base, -- 1481
		vec3(-0.84, 0.22, -0.49), -- 1481
		10, -- 1481
		1, -- 1481
		light, -- 1481
		MING_MATERIALS.mingBrick -- 1481
	) -- 1481
	local sillCol = shadeSurface( -- 1482
		MING_MATERIALS.mingStoneStep.base, -- 1482
		vec3(0, 0.94, -0.34), -- 1482
		6, -- 1482
		1, -- 1482
		light, -- 1482
		MING_MATERIALS.mingStoneStep -- 1482
	) -- 1482
	uiDraw:drawPolygon( -- 1483
		{ -- 1483
			Vec2(wx - embrasure, wy - 12 * s), -- 1484
			Vec2(wx, wy), -- 1485
			Vec2(wx, wy + wh), -- 1486
			Vec2(wx - embrasure, wy + wh + 14 * s) -- 1487
		}, -- 1487
		toColor(leftWall) -- 1488
	) -- 1488
	uiDraw:drawPolygon( -- 1489
		{ -- 1489
			Vec2(wx + ww, wy), -- 1490
			Vec2(wx + ww + embrasure, wy - 12 * s), -- 1491
			Vec2(wx + ww + embrasure, wy + wh + 14 * s), -- 1492
			Vec2(wx + ww, wy + wh) -- 1493
		}, -- 1493
		toColor(rightWall) -- 1494
	) -- 1494
	uiDraw:drawPolygon( -- 1496
		{ -- 1496
			Vec2(wx - embrasure - 10 * s, wy - 16 * s), -- 1497
			Vec2(wx + ww + embrasure + 10 * s, wy - 16 * s), -- 1498
			Vec2(wx + ww + 4 * s, wy + 10 * s), -- 1499
			Vec2(wx - 4 * s, wy + 10 * s) -- 1500
		}, -- 1500
		toColor(sillCol), -- 1501
		1, -- 1501
		toColor(STONE_EDGE_FALLBACK, 140) -- 1501
	) -- 1501
	local bar = 1 -- 1504
	do -- 1504
		bar = 1 -- 1505
		while bar <= 3 do -- 1505
			local bx = wx + ww * bar / 4 -- 1506
			uiDraw:drawSegment( -- 1507
				Vec2(bx, wy + 6 * s), -- 1507
				Vec2(bx, wy + wh - 2 * s), -- 1507
				3 * s, -- 1507
				Color(46, 34, 26, 235) -- 1507
			) -- 1507
			bar = bar + 1 -- 1505
		end -- 1505
	end -- 1505
	uiDraw:drawSegment( -- 1509
		Vec2(wx, wy + wh * 0.56), -- 1509
		Vec2(wx + ww, wy + wh * 0.56), -- 1509
		3.2 * s, -- 1509
		Color(46, 34, 26, 235) -- 1509
	) -- 1509
	uiDraw:drawRect( -- 1510
		Rect(wx, wy, ww, wh), -- 1510
		Color(0, 0, 0, 0), -- 1510
		2.4 * s, -- 1510
		Color(66, 50, 38, 240) -- 1510
	) -- 1510
	if lampProg > 0.02 then -- 1510
		fillRadialGlow( -- 1514
			uiGlow, -- 1515
			wx + ww * 0.5, -- 1515
			wy + 34 * s, -- 1515
			540 * s, -- 1516
			390 * s, -- 1516
			Color( -- 1517
				246, -- 1517
				198, -- 1517
				122, -- 1517
				math.floor(74 * lampProg + 0.5) -- 1517
			), -- 1517
			Color(216, 154, 72, 0), -- 1518
			20 -- 1519
		) -- 1519
	end -- 1519
end -- 1428
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1524
	fillVGradRect( -- 1534
		uiDraw, -- 1535
		0, -- 1535
		0, -- 1535
		ctx.uiW, -- 1535
		ctx.uiH, -- 1535
		Color(26, 21, 20, 255), -- 1536
		Color(46, 36, 30, 255) -- 1537
	) -- 1537
	local r = 0 -- 1540
	do -- 1540
		r = 0 -- 1541
		while r < 9 do -- 1541
			local y = oy + (280 + r * 44) * s -- 1542
			uiDraw:drawSegment( -- 1543
				Vec2(0, y), -- 1543
				Vec2(ctx.uiW, y), -- 1543
				1, -- 1543
				Color(34, 27, 24, 150) -- 1543
			) -- 1543
			r = r + 1 -- 1541
		end -- 1541
	end -- 1541
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1547
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1548
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1549
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1550
	fillVGradRect( -- 1551
		uiDraw, -- 1551
		wx, -- 1551
		wy, -- 1551
		ww, -- 1551
		wh, -- 1551
		Color(56, 62, 74, 255), -- 1551
		Color(26, 34, 50, 255) -- 1551
	) -- 1551
	uiDraw:drawRect( -- 1552
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1552
		Color(92, 68, 48, 255), -- 1552
		1, -- 1552
		Color(148, 114, 82, 180) -- 1552
	) -- 1552
	local bar = 1 -- 1553
	do -- 1553
		bar = 1 -- 1554
		while bar <= 3 do -- 1554
			local bx = wx + ww * bar / 4 -- 1555
			uiDraw:drawSegment( -- 1556
				Vec2(bx, wy + 4 * s), -- 1556
				Vec2(bx, wy + wh - 2 * s), -- 1556
				3.2 * s, -- 1556
				Color(64, 46, 34, 245) -- 1556
			) -- 1556
			bar = bar + 1 -- 1554
		end -- 1554
	end -- 1554
	uiDraw:drawSegment( -- 1558
		Vec2(wx, wy + wh * 0.56), -- 1558
		Vec2(wx + ww, wy + wh * 0.56), -- 1558
		3.2 * s, -- 1558
		Color(64, 46, 34, 245) -- 1558
	) -- 1558
	uiDraw:drawRect( -- 1559
		Rect(wx, wy, ww, wh), -- 1559
		Color(0, 0, 0, 0), -- 1559
		2.8 * s, -- 1559
		Color(88, 64, 44, 245) -- 1559
	) -- 1559
	local groupX = ox + 210 * s -- 1562
	local groupY = oy + 300 * s -- 1563
	uiArt:tryPlace( -- 1564
		"soldier_idle", -- 1564
		"fe05_m03_room_soldier", -- 1564
		groupX - 38 * s, -- 1564
		groupY, -- 1564
		118 * s, -- 1564
		166 * s, -- 1564
		{facing = 1, opacity = 0.9, layer = 1} -- 1564
	) -- 1564
	uiArt:tryPlace( -- 1567
		"child_idle", -- 1567
		"fe05_m03_room_child", -- 1567
		groupX + 42 * s, -- 1567
		groupY, -- 1567
		86 * s, -- 1567
		116 * s, -- 1567
		{facing = 1, opacity = 0.92, layer = 1} -- 1567
	) -- 1567
	fillRadialGlow( -- 1572
		uiGlow, -- 1573
		ox + 260 * s, -- 1573
		oy + 416 * s, -- 1573
		520 * s, -- 1574
		360 * s, -- 1574
		Color(246, 202, 134, 68), -- 1575
		Color(220, 158, 76, 0), -- 1576
		20 -- 1577
	) -- 1577
end -- 1524
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1581
	local t = self.seqElapsed -- 1594
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1595
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1596
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1597
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1598
	local midX = bx + bw * 0.5 -- 1599
	local midY = by + bh * 0.5 -- 1600
	uiDraw:drawRect( -- 1603
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1603
		Color( -- 1603
			10, -- 1603
			11, -- 1603
			16, -- 1603
			math.floor(108 * reveal + 0.5) -- 1603
		) -- 1603
	) -- 1603
	uiDraw:drawRect( -- 1604
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1604
		Color( -- 1604
			32, -- 1604
			46, -- 1604
			62, -- 1604
			math.floor(235 * reveal + 0.5) -- 1604
		), -- 1604
		1, -- 1604
		Color( -- 1604
			86, -- 1604
			104, -- 1604
			124, -- 1604
			math.floor(165 * reveal + 0.5) -- 1604
		) -- 1604
	) -- 1604
	if not uiArt:tryPlace( -- 1604
		"ink_song_paper", -- 1607
		"fe05_registry_paper", -- 1607
		midX, -- 1607
		midY, -- 1607
		bw, -- 1607
		bh, -- 1607
		{opacity = 0.98 * reveal, layer = 1} -- 1607
	) then -- 1607
		uiDraw:drawRect( -- 1608
			Rect(bx, by, bw, bh), -- 1609
			toColor( -- 1610
				PALETTE.xuanPaper, -- 1610
				math.floor(248 * reveal + 0.5) -- 1610
			), -- 1610
			1, -- 1611
			toColor( -- 1612
				PALETTE.silkDim, -- 1612
				math.floor(180 * reveal + 0.5) -- 1612
			) -- 1612
		) -- 1612
	end -- 1612
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1617
	fillRadialGlow( -- 1618
		uiGlow, -- 1619
		bx + bw * 0.34, -- 1619
		by + bh * 0.48, -- 1619
		bw * 0.58, -- 1620
		bh * 0.52, -- 1620
		Color( -- 1621
			246, -- 1621
			214, -- 1621
			156, -- 1621
			math.floor(44 * paperWarm * reveal + 0.5) -- 1621
		), -- 1621
		Color(238, 198, 128, 0), -- 1622
		16 -- 1623
	) -- 1623
	local padX = 44 * s -- 1627
	local padY = 32 * s -- 1628
	local inX = bx + padX -- 1629
	local inY = by + padY -- 1630
	local inW = bw - padX * 2 -- 1631
	local inH = bh - padY * 2 -- 1632
	local redSilk = toColor( -- 1633
		PALETTE.rouge, -- 1633
		math.floor(132 * reveal + 0.5) -- 1633
	) -- 1633
	local redFaint = toColor( -- 1634
		PALETTE.rouge, -- 1634
		math.floor(70 * reveal + 0.5) -- 1634
	) -- 1634
	uiInkDraw:drawRect( -- 1635
		Rect(inX, inY, inW, inH), -- 1635
		Color(0, 0, 0, 0), -- 1635
		1, -- 1635
		redSilk -- 1635
	) -- 1635
	uiInkDraw:drawRect( -- 1636
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1636
		Color(0, 0, 0, 0), -- 1636
		0.6, -- 1636
		redFaint -- 1636
	) -- 1636
	local headY = inY + inH - 28 * s -- 1639
	ctx.texts:put( -- 1640
		"md", -- 1640
		"北塔值夜收籍 · 末页", -- 1640
		inX + 18 * s, -- 1640
		headY, -- 1640
		toColor(PALETTE.xuanInk), -- 1640
		0, -- 1640
		0.5, -- 1640
		"Left", -- 1640
		2.2, -- 1640
		0.96 * reveal, -- 1640
		0 -- 1640
	) -- 1640
	ctx.texts:put( -- 1641
		"xs", -- 1641
		"宁村北塔", -- 1641
		inX + inW - 18 * s, -- 1641
		headY, -- 1641
		toColor(PALETTE.xuanInkSub), -- 1641
		1, -- 1641
		0.5, -- 1641
		"Right", -- 1641
		1.8, -- 1641
		0.8 * reveal, -- 1641
		0 -- 1641
	) -- 1641
	uiInkDraw:drawSegment( -- 1642
		Vec2(inX + 14 * s, headY - 22 * s), -- 1642
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1642
		0.9, -- 1642
		redSilk -- 1642
	) -- 1642
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1645
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1646
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1647
	ctx.texts:put( -- 1648
		"sm", -- 1648
		"肆拾壹", -- 1648
		inX + 18 * s, -- 1648
		row1Y, -- 1648
		toColor(PALETTE.rouge), -- 1648
		0, -- 1648
		0.5, -- 1648
		"Left", -- 1648
		1, -- 1648
		0.94 * reveal, -- 1648
		0 -- 1648
	) -- 1648
	if r1Prog > 0.02 then -- 1648
		ctx.texts:put( -- 1650
			"md", -- 1650
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1650
			inX + 96 * s, -- 1650
			row1Y, -- 1650
			toColor(PALETTE.xuanInk), -- 1650
			0, -- 1650
			0.5, -- 1650
			"Left", -- 1650
			1.6, -- 1650
			0.96 * math.min(1, r1Prog * 1.4), -- 1650
			0 -- 1650
		) -- 1650
	end -- 1650
	if r1Prog > 0.65 then -- 1650
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1653
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1654
		ctx.texts:put( -- 1657
			"xs", -- 1657
			subText, -- 1657
			inX + 96 * s, -- 1657
			row1SubY, -- 1657
			toColor(PALETTE.xuanInkSub), -- 1657
			0, -- 1657
			0.5, -- 1657
			"Left", -- 1657
			0.6, -- 1657
			0.88 * subA, -- 1657
			0 -- 1657
		) -- 1657
	end -- 1657
	uiInkDraw:drawSegment( -- 1659
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1659
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1659
		0.7, -- 1659
		redFaint -- 1659
	) -- 1659
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1662
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1663
	ctx.texts:put( -- 1664
		"sm", -- 1664
		"肆拾贰", -- 1664
		inX + 18 * s, -- 1664
		row2Y, -- 1664
		toColor(PALETTE.rouge), -- 1664
		0, -- 1664
		0.5, -- 1664
		"Left", -- 1664
		1, -- 1664
		0.94 * reveal, -- 1664
		0 -- 1664
	) -- 1664
	if route == "child" then -- 1664
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1668
		uiInkDraw:drawSegment( -- 1669
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1670
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1671
			1, -- 1672
			toColor(PALETTE.xuanInkSub, lineA) -- 1673
		) -- 1673
	else -- 1673
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1677
		if r2Prog <= 0.02 then -- 1677
			uiInkDraw:drawSegment( -- 1679
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1680
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1681
				0.9, -- 1682
				toColor( -- 1683
					PALETTE.xuanInkSub, -- 1683
					math.floor(105 * reveal + 0.5) -- 1683
				) -- 1683
			) -- 1683
		else -- 1683
			ctx.texts:put( -- 1686
				"md", -- 1686
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1686
				inX + 96 * s, -- 1686
				row2Y, -- 1686
				toColor(PALETTE.xuanInk), -- 1686
				0, -- 1686
				0.5, -- 1686
				"Left", -- 1686
				1.6, -- 1686
				0.96 * math.min(1, r2Prog * 1.4), -- 1686
				0 -- 1686
			) -- 1686
			if r2Prog > 0.65 then -- 1686
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1688
				ctx.texts:put( -- 1689
					"xs", -- 1689
					"守城戍卒亲口报出姓名，两人俱安。", -- 1689
					inX + 96 * s, -- 1689
					row2SubY, -- 1689
					toColor(PALETTE.xuanInkSub), -- 1689
					0, -- 1689
					0.5, -- 1689
					"Left", -- 1689
					0.6, -- 1689
					0.88 * subA, -- 1689
					0 -- 1689
				) -- 1689
			end -- 1689
		end -- 1689
	end -- 1689
	uiInkDraw:drawSegment( -- 1693
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1693
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1693
		0.7, -- 1693
		redFaint -- 1693
	) -- 1693
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1696
	if colophonA > 0.02 then -- 1696
		local signY = inY + 34 * s -- 1698
		ctx.texts:put( -- 1699
			"banner", -- 1699
			"向西守望", -- 1699
			midX - 24 * s, -- 1699
			signY, -- 1699
			toColor(PALETTE.xuanInk), -- 1699
			0.5, -- 1699
			0.5, -- 1699
			"Center", -- 1699
			6, -- 1699
			0.88 * colophonA, -- 1699
			0 -- 1699
		) -- 1699
	end -- 1699
	self:drawGuardBrushHand( -- 1703
		uiInkDraw, -- 1703
		route, -- 1703
		s, -- 1703
		ox, -- 1703
		oy -- 1703
	) -- 1703
end -- 1581
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, route, s, ox, oy) -- 1706
	local t = self.seqElapsed -- 1713
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1714
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1715
	local row1X0 = hoverX -- 1716
	local row1X1 = hoverX + 142 * s -- 1717
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1718
	local tipX = hoverX -- 1720
	local tipY = hoverY -- 1721
	local alpha = 0 -- 1722
	local lifted = 0 -- 1723
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1723
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1727
		tipX = lerp(row1X0, row1X1, k) -- 1728
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1729
		alpha = smoothstep(2, 2.2, t) -- 1730
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1731
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1731
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1734
		tipX = lerp(row1X1, hoverX, moveK) -- 1735
		tipY = lerp(row1Y, hoverY, moveK) -- 1736
		alpha = 1 -- 1737
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1738
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1738
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1741
		tipX = hoverX + outK * 140 * s -- 1742
		tipY = hoverY + outK * 46 * s -- 1743
		lifted = (9 + outK * 28) * s -- 1744
		alpha = 1 - outK -- 1745
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1745
		if t < 4.6 then -- 1745
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1749
			tipX = hoverX -- 1750
			tipY = hoverY -- 1751
			lifted = lerp(9 * s, 0, dipK) -- 1752
			alpha = 1 -- 1753
		elseif t < 5.55 then -- 1753
			local wK = smoothstep(4.6, 5.55, t) -- 1755
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1756
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1757
			lifted = 0 -- 1758
			alpha = 1 -- 1759
		else -- 1759
			local outK = smoothstep(5.55, 6.05, t) -- 1761
			tipX = hoverX + 216 * s + outK * 115 * s -- 1762
			tipY = hoverY + outK * 52 * s -- 1763
			lifted = outK * 24 * s -- 1764
			alpha = 1 - outK -- 1765
		end -- 1765
	end -- 1765
	if alpha <= 0.02 then -- 1765
		return -- 1770
	end -- 1770
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1773
	local bx = tipX -- 1774
	local by = tipY + lifted -- 1775
	uiInkDraw:drawEllipse( -- 1777
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1777
		(5 + lifted * 0.22) * s, -- 1777
		2.8 * s, -- 1777
		Color( -- 1777
			20, -- 1777
			18, -- 1777
			16, -- 1777
			math.floor(78 * alpha + 0.5) -- 1777
		) -- 1777
	) -- 1777
	uiInkDraw:drawPolygon( -- 1779
		{ -- 1779
			Vec2(bx, by), -- 1780
			Vec2(bx + 15 * s, by - 4 * s), -- 1781
			Vec2(bx + 10 * s, by + 8 * s) -- 1782
		}, -- 1782
		Color(22, 22, 26, a) -- 1783
	) -- 1783
	uiInkDraw:drawSegment( -- 1785
		Vec2(bx + 12 * s, by + 2 * s), -- 1785
		Vec2(bx + 24 * s, by + 6 * s), -- 1785
		7.8 * s, -- 1785
		Color(164, 138, 92, a) -- 1785
	) -- 1785
	uiInkDraw:drawSegment( -- 1786
		Vec2(bx + 22 * s, by + 5 * s), -- 1786
		Vec2(bx + 122 * s, by + 34 * s), -- 1786
		6.8 * s, -- 1786
		Color(142, 110, 74, a) -- 1786
	) -- 1786
	uiInkDraw:drawSegment( -- 1787
		Vec2(bx + 22 * s, by + 5 * s), -- 1787
		Vec2(bx + 122 * s, by + 34 * s), -- 1787
		1.8 * s, -- 1787
		Color( -- 1787
			196, -- 1787
			164, -- 1787
			118, -- 1787
			math.floor(185 * alpha + 0.5) -- 1787
		) -- 1787
	) -- 1787
	uiInkDraw:drawPolygon( -- 1789
		{ -- 1789
			Vec2(bx + 44 * s, by - 6 * s), -- 1790
			Vec2(bx + 102 * s, by - 14 * s), -- 1791
			Vec2(bx + 110 * s, by + 18 * s), -- 1792
			Vec2(bx + 54 * s, by + 22 * s) -- 1793
		}, -- 1793
		Color(188, 154, 126, a), -- 1794
		1, -- 1794
		Color(128, 98, 76, a) -- 1794
	) -- 1794
	uiInkDraw:drawSegment( -- 1795
		Vec2(bx + 46 * s, by + 16 * s), -- 1795
		Vec2(bx + 76 * s, by + 20 * s), -- 1795
		5.2 * s, -- 1795
		Color(204, 170, 140, a) -- 1795
	) -- 1795
	uiInkDraw:drawSegment( -- 1796
		Vec2(bx + 48 * s, by + 2 * s), -- 1796
		Vec2(bx + 82 * s, by + 4 * s), -- 1796
		4.8 * s, -- 1796
		Color(180, 146, 118, a) -- 1796
	) -- 1796
	uiInkDraw:drawPolygon( -- 1797
		{ -- 1797
			Vec2(bx + 98 * s, by - 14 * s), -- 1798
			Vec2(bx + 224 * s, by - 32 * s), -- 1799
			Vec2(bx + 230 * s, by + 18 * s), -- 1800
			Vec2(bx + 104 * s, by + 20 * s) -- 1801
		}, -- 1801
		Color(54, 48, 44, a), -- 1802
		1.2, -- 1802
		Color(94, 84, 72, a) -- 1802
	) -- 1802
end -- 1706
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiGlow, route, s, ox, oy) -- 1805
	local t = self.seqElapsed -- 1814
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1815
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1816
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1817
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1818
	if route == "child" then -- 1818
		local propA = smoothstep(1.55, 2.05, t) -- 1822
		if propA > 0.02 then -- 1822
			self:drawNeedleCaseOnDesk( -- 1824
				uiInkDraw, -- 1824
				ncX, -- 1824
				ncY, -- 1824
				s, -- 1824
				propA, -- 1824
				true -- 1824
			) -- 1824
		end -- 1824
		local bowlK = smoothstep(4.35, 5.15, t) -- 1827
		if bowlK > 0.02 then -- 1827
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1829
			self:drawWarmPorcelainBowl( -- 1830
				uiInkDraw, -- 1830
				uiGlow, -- 1830
				bx, -- 1830
				bowlY, -- 1830
				s, -- 1830
				bowlK, -- 1830
				false, -- 1830
				0 -- 1830
			) -- 1830
		end -- 1830
	else -- 1830
		local needleK = smoothstep(5.45, 6.15, t) -- 1834
		if needleK > 0.02 then -- 1834
			local ny = lerp(ncY + 46 * s, ncY, needleK) -- 1836
			self:drawNeedleCaseOnDesk( -- 1837
				uiInkDraw, -- 1837
				ncX, -- 1837
				ny, -- 1837
				s, -- 1837
				needleK, -- 1837
				false -- 1837
			) -- 1837
		end -- 1837
		local bowlK = smoothstep(5.8, 6.65, t) -- 1840
		if bowlK > 0.02 then -- 1840
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1842
			local handsK = smoothstep(5.95, 6.75, t) -- 1843
			self:drawWarmPorcelainBowl( -- 1844
				uiInkDraw, -- 1844
				uiGlow, -- 1844
				bowlX, -- 1844
				by, -- 1844
				s, -- 1844
				bowlK, -- 1844
				true, -- 1844
				handsK -- 1844
			) -- 1844
		end -- 1844
		local cuffK = smoothstep(4.25, 4.85, t) -- 1847
		if cuffK > 0.02 then -- 1847
			drawPatchedCuff(uiInkDraw, uiGlow, { -- 1849
				wristX = ox + 122 * s, -- 1850
				wristY = oy + 182 * s, -- 1851
				angleRad = 0.08, -- 1852
				scale = 0.6 * s, -- 1853
				pose = "open", -- 1854
				opacity = 0.92 * cuffK, -- 1855
				stitchHighlight = 0.34, -- 1856
				warmth = 0.72 -- 1857
			}) -- 1857
		end -- 1857
	end -- 1857
end -- 1805
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, draw, cx, cy, s, alpha, withNote) -- 1864
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1872
	draw:drawEllipse( -- 1874
		Vec2(cx + 4 * s, cy - 12 * s), -- 1874
		44 * s, -- 1874
		14 * s, -- 1874
		Color( -- 1874
			10, -- 1874
			10, -- 1874
			14, -- 1874
			math.floor(140 * alpha + 0.5) -- 1874
		) -- 1874
	) -- 1874
	draw:drawPolygon( -- 1876
		{ -- 1876
			Vec2(cx - 32 * s, cy - 12 * s), -- 1877
			Vec2(cx + 26 * s, cy - 15 * s), -- 1878
			Vec2(cx + 30 * s, cy + 16 * s), -- 1879
			Vec2(cx - 28 * s, cy + 18 * s) -- 1880
		}, -- 1880
		Color(148, 124, 92, a), -- 1881
		1.3, -- 1881
		Color(88, 70, 50, a) -- 1881
	) -- 1881
	draw:drawEllipse( -- 1883
		Vec2(cx + 18 * s, cy + 2 * s), -- 1883
		13 * s, -- 1883
		13 * s, -- 1883
		Color(188, 152, 86, a) -- 1883
	) -- 1883
	strokeEllipse( -- 1884
		draw, -- 1884
		cx + 18 * s, -- 1884
		cy + 2 * s, -- 1884
		13 * s, -- 1884
		13 * s, -- 1884
		1.5 * s, -- 1884
		Color(118, 92, 46, a), -- 1884
		18 -- 1884
	) -- 1884
	draw:drawDot( -- 1885
		Vec2(cx + 18 * s, cy + 2 * s), -- 1885
		2.5 * s, -- 1885
		Color(72, 54, 28, a) -- 1885
	) -- 1885
	draw:drawSegment( -- 1886
		Vec2(cx + 12 * s, cy - 2 * s), -- 1886
		Vec2(cx + 24 * s, cy + 6 * s), -- 1886
		1.5 * s, -- 1886
		Color(164, 48, 44, a) -- 1886
	) -- 1886
	draw:drawSegment( -- 1888
		Vec2(cx - 28 * s, cy + 4 * s), -- 1888
		Vec2(cx - 56 * s, cy - 8 * s), -- 1888
		2.4 * s, -- 1888
		toColor(CUFF_PALETTE.childCord, a) -- 1888
	) -- 1888
	draw:drawSegment( -- 1889
		Vec2(cx - 56 * s, cy - 8 * s), -- 1889
		Vec2(cx - 72 * s, cy + 6 * s), -- 1889
		2.2 * s, -- 1889
		toColor(CUFF_PALETTE.childCord, a) -- 1889
	) -- 1889
	draw:drawSegment( -- 1890
		Vec2(cx - 72 * s, cy + 6 * s), -- 1890
		Vec2(cx - 48 * s, cy + 16 * s), -- 1890
		2 * s, -- 1890
		toColor( -- 1890
			CUFF_PALETTE.childCord, -- 1890
			math.floor(215 * alpha + 0.5) -- 1890
		) -- 1890
	) -- 1890
	if withNote then -- 1890
		draw:drawPolygon( -- 1894
			{ -- 1894
				Vec2(cx + 38 * s, cy - 18 * s), -- 1895
				Vec2(cx + 96 * s, cy - 12 * s), -- 1896
				Vec2(cx + 90 * s, cy + 24 * s), -- 1897
				Vec2(cx + 34 * s, cy + 18 * s) -- 1898
			}, -- 1898
			toColor(PALETTE.xuanPaper, a), -- 1899
			1, -- 1899
			toColor( -- 1899
				PALETTE.xuanInkSub, -- 1899
				math.floor(160 * alpha + 0.5) -- 1899
			) -- 1899
		) -- 1899
		draw:drawSegment( -- 1900
			Vec2(cx + 46 * s, cy + 8 * s), -- 1900
			Vec2(cx + 80 * s, cy + 11 * s), -- 1900
			1.2 * s, -- 1900
			toColor( -- 1900
				PALETTE.xuanInk, -- 1900
				math.floor(170 * alpha + 0.5) -- 1900
			) -- 1900
		) -- 1900
		draw:drawSegment( -- 1901
			Vec2(cx + 46 * s, cy - 2 * s), -- 1901
			Vec2(cx + 76 * s, cy + 1 * s), -- 1901
			1.2 * s, -- 1901
			toColor( -- 1901
				PALETTE.xuanInk, -- 1901
				math.floor(160 * alpha + 0.5) -- 1901
			) -- 1901
		) -- 1901
	end -- 1901
end -- 1864
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, draw, glow, cx, cy, s, alpha, heldByTwoHands, handsK) -- 1906
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1916
	draw:drawEllipse( -- 1918
		Vec2(cx, cy - 36 * s), -- 1918
		58 * s, -- 1918
		14 * s, -- 1918
		Color( -- 1918
			8, -- 1918
			9, -- 1918
			14, -- 1918
			math.floor(150 * alpha + 0.5) -- 1918
		) -- 1918
	) -- 1918
	draw:drawPolygon( -- 1920
		{ -- 1920
			Vec2(cx - 32 * s, cy - 38 * s), -- 1921
			Vec2(cx + 32 * s, cy - 38 * s), -- 1922
			Vec2(cx + 62 * s, cy + 8 * s), -- 1923
			Vec2(cx - 62 * s, cy + 8 * s) -- 1924
		}, -- 1924
		Color(168, 166, 156, a), -- 1925
		1.4, -- 1925
		Color(98, 96, 88, a) -- 1925
	) -- 1925
	draw:drawPolygon( -- 1927
		{ -- 1927
			Vec2(cx + 8 * s, cy - 36 * s), -- 1928
			Vec2(cx + 32 * s, cy - 38 * s), -- 1929
			Vec2(cx + 62 * s, cy + 8 * s), -- 1930
			Vec2(cx + 22 * s, cy + 6 * s) -- 1931
		}, -- 1931
		Color( -- 1932
			122, -- 1932
			120, -- 1932
			112, -- 1932
			math.floor(160 * alpha + 0.5) -- 1932
		) -- 1932
	) -- 1932
	draw:drawEllipse( -- 1934
		Vec2(cx, cy + 8 * s), -- 1934
		64 * s, -- 1934
		21 * s, -- 1934
		Color(224, 218, 206, a) -- 1934
	) -- 1934
	strokeEllipse( -- 1935
		draw, -- 1935
		cx, -- 1935
		cy + 8 * s, -- 1935
		64 * s, -- 1935
		21 * s, -- 1935
		1.9 * s, -- 1935
		Color(116, 110, 100, a), -- 1935
		28 -- 1935
	) -- 1935
	draw:drawEllipse( -- 1936
		Vec2(cx, cy + 6 * s), -- 1936
		54 * s, -- 1936
		15 * s, -- 1936
		Color(196, 168, 122, a) -- 1936
	) -- 1936
	strokeEllipse( -- 1937
		draw, -- 1937
		cx, -- 1937
		cy + 6 * s, -- 1937
		54 * s, -- 1937
		15 * s, -- 1937
		1.1 * s, -- 1937
		Color(158, 132, 92, a), -- 1937
		24 -- 1937
	) -- 1937
	draw:drawSegment( -- 1939
		Vec2(cx - 46 * s, cy + 16 * s), -- 1939
		Vec2(cx - 10 * s, cy + 25 * s), -- 1939
		2 * s, -- 1939
		Color( -- 1939
			248, -- 1939
			246, -- 1939
			240, -- 1939
			math.floor(215 * alpha + 0.5) -- 1939
		) -- 1939
	) -- 1939
	local wi = 0 -- 1942
	do -- 1942
		wi = 0 -- 1943
		while wi < 3 do -- 1943
			local phase = self.animTime * 1.1 + wi * 2.05 -- 1944
			local baseX = cx + (wi - 1) * 18 * s -- 1945
			local baseY = cy + 16 * s -- 1946
			local segs = 4 -- 1947
			local prevX = baseX -- 1948
			local prevY = baseY -- 1949
			local si = 1 -- 1950
			do -- 1950
				si = 1 -- 1951
				while si <= segs do -- 1951
					local frac = si / segs -- 1952
					local nx = baseX + math.sin(phase + frac * 3.1) * (6.5 * frac) * s -- 1953
					local ny = baseY + frac * (36 + wi % 2 * 10) * s -- 1954
					local wa = math.floor(46 * (1 - frac * 0.72) * alpha + 0.5) -- 1955
					glow:drawSegment( -- 1956
						Vec2(prevX, prevY), -- 1956
						Vec2(nx, ny), -- 1956
						(2.2 - frac * 0.9) * s, -- 1956
						Color(244, 238, 226, wa) -- 1956
					) -- 1956
					prevX = nx -- 1957
					prevY = ny -- 1958
					si = si + 1 -- 1951
				end -- 1951
			end -- 1951
			wi = wi + 1 -- 1943
		end -- 1943
	end -- 1943
	if heldByTwoHands and handsK > 0.02 then -- 1943
		local ha = math.floor(255 * clamp01(handsK * alpha) + 0.5) -- 1964
		local skin = toColor(CUFF_PALETTE.childSkin, ha) -- 1965
		local skinSh = toColor(CUFF_PALETTE.childSkinShadow, ha) -- 1966
		local sleeve = toColor(CUFF_PALETTE.childSleeve, ha) -- 1967
		local spread = (1 - handsK) * 28 * s -- 1968
		draw:drawPolygon( -- 1971
			{ -- 1971
				Vec2(cx - 122 * s - spread, cy - 58 * s), -- 1972
				Vec2(cx - 72 * s - spread, cy - 30 * s), -- 1973
				Vec2(cx - 82 * s - spread, cy - 4 * s), -- 1974
				Vec2(cx - 134 * s - spread, cy - 26 * s) -- 1975
			}, -- 1975
			sleeve, -- 1976
			1.1, -- 1976
			skinSh -- 1976
		) -- 1976
		draw:drawPolygon( -- 1977
			{ -- 1977
				Vec2(cx - 76 * s - spread, cy - 28 * s), -- 1978
				Vec2(cx - 48 * s - spread, cy - 18 * s), -- 1979
				Vec2(cx - 44 * s - spread, cy + 6 * s), -- 1980
				Vec2(cx - 74 * s - spread, cy + 2 * s) -- 1981
			}, -- 1981
			skin, -- 1982
			1.1, -- 1982
			skinSh -- 1982
		) -- 1982
		draw:drawSegment( -- 1983
			Vec2(cx - 56 * s - spread, cy + 2 * s), -- 1983
			Vec2(cx - 38 * s - spread, cy + 12 * s), -- 1983
			4.6 * s, -- 1983
			skin -- 1983
		) -- 1983
		draw:drawSegment( -- 1984
			Vec2(cx - 58 * s - spread, cy - 7 * s), -- 1984
			Vec2(cx - 40 * s - spread, cy - 2 * s), -- 1984
			4.4 * s, -- 1984
			skin -- 1984
		) -- 1984
		draw:drawSegment( -- 1985
			Vec2(cx - 56 * s - spread, cy - 16 * s), -- 1985
			Vec2(cx - 40 * s - spread, cy - 14 * s), -- 1985
			4.2 * s, -- 1985
			skin -- 1985
		) -- 1985
		draw:drawPolygon( -- 1988
			{ -- 1988
				Vec2(cx + 122 * s + spread, cy - 58 * s), -- 1989
				Vec2(cx + 72 * s + spread, cy - 30 * s), -- 1990
				Vec2(cx + 82 * s + spread, cy - 4 * s), -- 1991
				Vec2(cx + 134 * s + spread, cy - 26 * s) -- 1992
			}, -- 1992
			sleeve, -- 1993
			1.1, -- 1993
			skinSh -- 1993
		) -- 1993
		draw:drawPolygon( -- 1994
			{ -- 1994
				Vec2(cx + 76 * s + spread, cy - 28 * s), -- 1995
				Vec2(cx + 48 * s + spread, cy - 18 * s), -- 1996
				Vec2(cx + 44 * s + spread, cy + 6 * s), -- 1997
				Vec2(cx + 74 * s + spread, cy + 2 * s) -- 1998
			}, -- 1998
			skin, -- 1999
			1.1, -- 1999
			skinSh -- 1999
		) -- 1999
		draw:drawSegment( -- 2000
			Vec2(cx + 56 * s + spread, cy + 2 * s), -- 2000
			Vec2(cx + 38 * s + spread, cy + 12 * s), -- 2000
			4.6 * s, -- 2000
			skin -- 2000
		) -- 2000
		draw:drawSegment( -- 2001
			Vec2(cx + 58 * s + spread, cy - 7 * s), -- 2001
			Vec2(cx + 40 * s + spread, cy - 2 * s), -- 2001
			4.4 * s, -- 2001
			skin -- 2001
		) -- 2001
		draw:drawSegment( -- 2002
			Vec2(cx + 56 * s + spread, cy - 16 * s), -- 2002
			Vec2(cx + 40 * s + spread, cy - 14 * s), -- 2002
			4.2 * s, -- 2002
			skin -- 2002
		) -- 2002
	end -- 2002
end -- 1906
function TowerEndingsPlugin.prototype.drawMingLantern(self, draw, glow, cx, cy, scale, alpha, warmth) -- 2007
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 2016
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 2017
	draw:drawSegment( -- 2019
		Vec2(cx - 10 * scale, cy + 28 * scale), -- 2019
		Vec2(cx, cy + 40 * scale), -- 2019
		1.8 * scale, -- 2019
		Color(88, 86, 82, a) -- 2019
	) -- 2019
	draw:drawSegment( -- 2020
		Vec2(cx + 10 * scale, cy + 28 * scale), -- 2020
		Vec2(cx, cy + 40 * scale), -- 2020
		1.8 * scale, -- 2020
		Color(88, 86, 82, a) -- 2020
	) -- 2020
	draw:drawRect( -- 2022
		Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), -- 2022
		Color(62, 46, 34, a), -- 2022
		1, -- 2022
		Color(118, 92, 66, a) -- 2022
	) -- 2022
	draw:drawRect( -- 2023
		Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), -- 2023
		Color(62, 46, 34, a), -- 2023
		1, -- 2023
		Color(118, 92, 66, a) -- 2023
	) -- 2023
	draw:drawRect( -- 2025
		Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale), -- 2026
		Color( -- 2027
			238, -- 2027
			198, -- 2027
			132, -- 2027
			math.floor(230 * alpha * (0.75 + 0.25 * warmth) + 0.5) -- 2027
		), -- 2027
		1.4 * scale, -- 2028
		Color(94, 70, 48, a) -- 2029
	) -- 2029
	draw:drawSegment( -- 2031
		Vec2(cx, cy - 18 * scale), -- 2031
		Vec2(cx, cy + 22 * scale), -- 2031
		1.1 * scale, -- 2031
		Color( -- 2031
			94, -- 2031
			70, -- 2031
			48, -- 2031
			math.floor(150 * alpha + 0.5) -- 2031
		) -- 2031
	) -- 2031
	draw:drawEllipse( -- 2032
		Vec2(cx, cy + 2 * scale), -- 2032
		4.6 * scale * flicker, -- 2032
		8.5 * scale * flicker, -- 2032
		Color(255, 244, 212, a) -- 2032
	) -- 2032
	fillRadialGlow( -- 2034
		glow, -- 2035
		cx, -- 2035
		cy + 2 * scale, -- 2035
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2036
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2037
		Color( -- 2038
			250, -- 2038
			208, -- 2038
			132, -- 2038
			math.floor(128 * alpha * warmth + 0.5) -- 2038
		), -- 2038
		Color(228, 162, 74, 0), -- 2039
		16 -- 2040
	) -- 2040
end -- 2007
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 2044
	local line = self.lastSubtitle -- 2053
	if line ~= "" then -- 2053
		local cy = barH + 34 * s -- 2055
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 2056
		drawSilkVeil( -- 2057
			uiDraw, -- 2057
			uiArt, -- 2057
			"fe05_sub_veil", -- 2057
			ctx.uiW * 0.5, -- 2057
			cy, -- 2057
			stripW, -- 2057
			48 * s, -- 2057
			PALETTE.inkWash, -- 2057
			0.82, -- 2057
			3 -- 2057
		) -- 2057
		drawHairline( -- 2058
			uiInkDraw, -- 2058
			uiArt, -- 2058
			"fe05_sub_hair", -- 2058
			ctx.uiW * 0.5, -- 2058
			cy + 21 * s, -- 2058
			stripW * 0.68, -- 2058
			PALETTE.silkDim, -- 2058
			0.54, -- 2058
			true, -- 2058
			4 -- 2058
		) -- 2058
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 2059
		ctx.texts:put( -- 2060
			isSpoken and "md" or "sm", -- 2061
			line, -- 2062
			ctx.uiW * 0.5, -- 2063
			cy - 1 * s, -- 2064
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 2065
			0.5, -- 2066
			0.5, -- 2067
			"Center", -- 2068
			isSpoken and 1.8 or 1, -- 2069
			0.98, -- 2070
			0.08 -- 2071
		) -- 2071
	end -- 2071
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 2071
		local hint = route == "child" and "按 E 再次启程   ·   Esc 暂歇" or "团圆尾声   ·   按 E 再次启程   ·   Esc 暂歇" -- 2077
		ctx.texts:put( -- 2080
			"xs", -- 2080
			hint, -- 2080
			ctx.uiW * 0.5, -- 2080
			barH * 0.5, -- 2080
			toColor(PALETTE.textMid), -- 2080
			0.5, -- 2080
			0.5, -- 2080
			"Center", -- 2080
			1.4, -- 2080
			0.88, -- 2080
			0.08 -- 2080
		) -- 2080
	end -- 2080
end -- 2044
function ____exports.createTowerEndingsPlugin() -- 2085
	return __TS__New(____exports.TowerEndingsPlugin) -- 2086
end -- 2085
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 2090
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 2091
	fe:registerPlugin(plugin) -- 2092
	return plugin -- 2093
end -- 2090
return ____exports -- 2090