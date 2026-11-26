-- [ts]: tower_endings.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 28
local Color = ____Dora.Color -- 28
local Rect = ____Dora.Rect -- 28
local Vec2 = ____Dora.Vec2 -- 28
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
	holdReadySec = 8 -- 99
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
	local alreadyIndoorPhase = isTower and (p.phase == "tower-given" or p.phase == "tower-end") -- 612
	local sameRunIndoorRetry = isTower and self.lastRoomKey == "tower" and self.doorOpened and p.run == self.lastRunRef and route == self.activeRoute and (p.checkpoint > 0 or alreadyIndoorPhase) -- 613
	self.activeRoute = route -- 620
	self.lastRoomKey = p.room.key -- 621
	self.lastRunRef = p.run -- 622
	if not isTower then -- 622
		self:clearSequenceState(false) -- 625
		self.indoorRetryCount = 0 -- 626
		self.doorClosedAfterRetry = false -- 627
		return -- 628
	end -- 628
	if sameRunIndoorRetry or alreadyIndoorPhase then -- 628
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 633
		self.doorClosedAfterRetry = false -- 634
		self:clearSequenceState(true) -- 635
		if p.phase == "tower-end" then -- 635
			self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.divergeEndSec -- 637
			self:syncDerivedMilestones(self.seqElapsed, route) -- 638
		end -- 638
		return -- 640
	end -- 640
	self:clearSequenceState(false) -- 644
	self.indoorRetryCount = 0 -- 645
	self.doorClosedAfterRetry = false -- 646
end -- 600
function TowerEndingsPlugin.prototype.update(self, ctx) -- 649
	self:syncRuntimeHook() -- 650
	self.lastUiW = ctx.uiW -- 651
	self.lastUiH = ctx.uiH -- 652
	local p = ctx.p -- 653
	if not self.rehearsalActive and p.room.key ~= "tower" then -- 653
		if self.loopsActive then -- 653
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 657
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 658
			self.loopsActive = false -- 659
		end -- 659
		self.active = false -- 661
		return -- 662
	end -- 662
	local route = self:resolveRoute(p, ctx.view) -- 665
	self.activeRoute = route -- 666
	if not self.rehearsalActive then -- 666
		self:stepLiveSync(ctx, route) -- 669
	else -- 669
		self:stepRehearsal(ctx, route) -- 671
	end -- 671
	if not self.active then -- 671
		if self.loopsActive then -- 671
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 676
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 677
			self.loopsActive = false -- 678
		end -- 678
		return -- 680
	end -- 680
	if not ctx.paused and ctx.worldDt > 0 then -- 680
		self.animTime = self.animTime + ctx.worldDt -- 685
		self:syncDerivedMilestones(self.seqElapsed, route) -- 686
		self:syncAudioCues(ctx.audio, ctx, route) -- 687
		self:stepInputGuard(ctx.input) -- 688
	elseif not ctx.paused then -- 688
		self:syncDerivedMilestones(self.seqElapsed, route) -- 691
		self:stepInputGuard(ctx.input) -- 692
	end -- 692
	self.lastSubtitle = self:composeSubtitle(route) -- 695
end -- 649
function TowerEndingsPlugin.prototype.stepLiveSync(self, ctx, route) -- 698
	local p = ctx.p -- 699
	local phase = p.phase -- 700
	local justEnteredKnock = self.prevPhase ~= "tower-knock" and phase == "tower-knock" -- 701
	local justEnteredGiven = self.prevPhase ~= "tower-given" and phase == "tower-given" -- 702
	local justEnteredEnd = self.prevPhase ~= "tower-end" and phase == "tower-end" -- 703
	self.prevPhase = phase -- 704
	if phase == "tower-wait" then -- 704
		self.active = false -- 708
		return -- 709
	end -- 709
	if not self.active then -- 709
		self.active = true -- 713
		self.staleInputMustRelease = ctx.input.interact.held or ctx.input.retry.held or ctx.input.interact.pressed -- 714
		self.confirmReady = false -- 715
	end -- 715
	if justEnteredKnock then -- 715
		self.seqElapsed = p.phaseTick / 60 -- 719
		self.holdElapsed = 0 -- 720
		self.staleInputMustRelease = true -- 721
		self.confirmReady = false -- 722
	elseif justEnteredGiven then -- 722
		self.doorOpened = true -- 724
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.doorOpenSec) -- 725
	elseif justEnteredEnd then -- 725
		self.doorOpened = true -- 727
		self.seqElapsed = math.max(self.seqElapsed, 3.6) -- 729
	end -- 729
	if not ctx.paused and #ctx.events.rawEvents > 0 then -- 729
		local i = 0 -- 734
		do -- 734
			i = 0 -- 735
			while i < #ctx.events.rawEvents do -- 735
				local ev = ctx.events.rawEvents[i + 1] -- 736
				if ev.name == "knock" then -- 736
					local cnt = type(ev.data.count) == "number" and ev.data.count or self.knockCount + 1 -- 738
					if cnt >= 1 and self.knockCount < 1 then -- 738
						self.knockCount = 1 -- 740
						self:playTowerOnce( -- 741
							ctx.audio, -- 741
							"knock1", -- 741
							"sfx", -- 741
							____exports.TOWER_AUDIO_FILES.knock1, -- 741
							0.88, -- 741
							"tower:knock:1", -- 741
							ev.tick, -- 741
							ev.seq -- 741
						) -- 741
					end -- 741
					if cnt >= 2 and self.knockCount < 2 then -- 741
						self.knockCount = 2 -- 744
						self:playTowerOnce( -- 745
							ctx.audio, -- 745
							"knock2", -- 745
							"sfx", -- 745
							____exports.TOWER_AUDIO_FILES.knock2, -- 745
							0.9, -- 745
							"tower:knock:2", -- 745
							ev.tick, -- 745
							ev.seq -- 745
						) -- 745
					end -- 745
				end -- 745
				i = i + 1 -- 735
			end -- 735
		end -- 735
	end -- 735
	if not ctx.paused and ctx.worldDt > 0 then -- 735
		if phase == "tower-knock" then -- 735
			local backendSec = math.min(____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60) -- 754
			self.seqElapsed = math.max(self.seqElapsed + ctx.worldDt, backendSec) -- 755
			if self.seqElapsed > ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 then -- 755
				self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 -- 757
			end -- 757
		else -- 757
			self.seqElapsed = self.seqElapsed + ctx.worldDt -- 760
			if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 760
				self.holdElapsed = self.holdElapsed + ctx.worldDt -- 762
			end -- 762
		end -- 762
	end -- 762
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 762
		self.doorClosedAfterRetry = true -- 768
	end -- 768
	self:syncDerivedMilestones(self.seqElapsed, route) -- 770
end -- 698
function TowerEndingsPlugin.prototype.stepRehearsal(self, ctx, route) -- 773
	self.active = true -- 774
	if not ctx.paused and ctx.worldDt > 0 then -- 774
		self.seqElapsed = self.seqElapsed + ctx.worldDt -- 776
		if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 776
			self.holdElapsed = self.holdElapsed + ctx.worldDt -- 778
		end -- 778
	end -- 778
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 778
		self.doorClosedAfterRetry = true -- 782
	end -- 782
	self:syncDerivedMilestones(self.seqElapsed, route) -- 784
end -- 773
function TowerEndingsPlugin.prototype.syncDerivedMilestones(self, t, route) -- 787
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec and self.knockCount < 1 then -- 787
		self.knockCount = 1 -- 789
	end -- 789
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec and self.knockCount < 2 then -- 789
		self.knockCount = 2 -- 792
	end -- 792
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec and self.replyKnockCount < 1 then -- 792
		self.replyKnockCount = 1 -- 795
	end -- 795
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec and self.replyKnockCount < 2 then -- 795
		self.replyKnockCount = 2 -- 798
	end -- 798
	if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 798
		self.doorOpened = true -- 801
	end -- 801
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec and not self.row1Written then -- 801
		self.row1Written = true -- 805
		self.registryAppendCount = self.registryAppendCount + 1 -- 806
	end -- 806
	if route == "soldier" and t >= 4.6 and not self.row2Written then -- 806
		self.row2Written = true -- 809
		self.registryAppendCount = self.registryAppendCount + 1 -- 810
	end -- 810
	if route == "child" and self.row2Written then -- 810
		self.row2Written = false -- 814
		self.registryAppendCount = self.row1Written and 1 or 0 -- 815
	end -- 815
end -- 787
function TowerEndingsPlugin.prototype.stepInputGuard(self, input) -- 819
	local keyHeld = input.interact.held or input.retry.held -- 820
	local keyPressed = input.interact.pressed or input.retry.pressed -- 821
	local readyTime = self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 822
	if self.staleInputMustRelease then -- 822
		if not keyHeld then -- 822
			self.staleInputMustRelease = false -- 826
		elseif keyPressed then -- 826
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 828
		end -- 828
		self.confirmReady = false -- 830
		return -- 831
	end -- 831
	if not readyTime then -- 831
		if keyPressed then -- 831
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 836
			self.staleInputMustRelease = keyHeld -- 837
		end -- 837
		self.confirmReady = false -- 839
		return -- 840
	end -- 840
	self.confirmReady = true -- 843
	if self.rehearsalActive and keyPressed then -- 843
		self.rehearsalAcknowledged = true -- 845
	end -- 845
end -- 819
function TowerEndingsPlugin.prototype.playTowerOnce(self, audio, tag, track, path, volume, cueId, tick, seq) -- 849
	if seq == nil then -- 849
		seq = -1 -- 857
	end -- 857
	local dedupeKey = (("tower:s" .. tostring(self.sessionId)) .. ":") .. tag -- 859
	audio:playOnce( -- 860
		dedupeKey, -- 860
		track, -- 860
		path, -- 860
		volume, -- 860
		cueId, -- 860
		tick, -- 860
		seq -- 860
	) -- 860
end -- 849
function TowerEndingsPlugin.prototype.syncAudioCues(self, audio, ctx, route) -- 863
	local t = self.seqElapsed -- 864
	local tick = ctx.p.ticks -- 865
	local indoorK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.5, t) -- 866
	self.loopsActive = true -- 869
	audio:playLoop( -- 870
		"tower_wind_cold", -- 870
		"wind", -- 870
		____exports.TOWER_AUDIO_FILES.windCold, -- 870
		lerp(0.36, 0.14, indoorK), -- 870
		tick -- 870
	) -- 870
	if indoorK > 0.05 then -- 870
		audio:playLoop( -- 872
			"tower_room_warm", -- 872
			"ambience", -- 872
			____exports.TOWER_AUDIO_FILES.roomWarm, -- 872
			lerp(0.06, 0.34, indoorK), -- 872
			tick -- 872
		) -- 872
	end -- 872
	if self.indoorRetryCount == 0 then -- 872
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec then -- 872
			self:playTowerOnce( -- 878
				audio, -- 878
				"knock1", -- 878
				"sfx", -- 878
				____exports.TOWER_AUDIO_FILES.knock1, -- 878
				0.88, -- 878
				"tower:knock:1", -- 878
				tick -- 878
			) -- 878
		end -- 878
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec then -- 878
			self:playTowerOnce( -- 881
				audio, -- 881
				"knock2", -- 881
				"sfx", -- 881
				____exports.TOWER_AUDIO_FILES.knock2, -- 881
				0.9, -- 881
				"tower:knock:2", -- 881
				tick -- 881
			) -- 881
		end -- 881
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 881
			self:playTowerOnce( -- 884
				audio, -- 884
				"reply1", -- 884
				"sfx", -- 884
				____exports.TOWER_AUDIO_FILES.reply1, -- 884
				0.78, -- 884
				"tower:reply:1", -- 884
				tick -- 884
			) -- 884
		end -- 884
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec then -- 884
			self:playTowerOnce( -- 887
				audio, -- 887
				"reply2", -- 887
				"sfx", -- 887
				____exports.TOWER_AUDIO_FILES.reply2, -- 887
				0.8, -- 887
				"tower:reply:2", -- 887
				tick -- 887
			) -- 887
		end -- 887
		if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 887
			self:playTowerOnce( -- 890
				audio, -- 890
				"door_open", -- 890
				"sfx", -- 890
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 890
				0.84, -- 890
				"tower:door_open", -- 890
				tick -- 890
			) -- 890
		end -- 890
	end -- 890
	if t >= 1.5 then -- 890
		self:playTowerOnce( -- 895
			audio, -- 895
			"book_open", -- 895
			"sfx", -- 895
			____exports.TOWER_AUDIO_FILES.bookOpen, -- 895
			0.82, -- 895
			"tower:book_open", -- 895
			tick -- 895
		) -- 895
	end -- 895
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 895
		self:playTowerOnce( -- 898
			audio, -- 898
			"brush1", -- 898
			"sfx", -- 898
			____exports.TOWER_AUDIO_FILES.brush1, -- 898
			0.8, -- 898
			"tower:brush:row1", -- 898
			tick -- 898
		) -- 898
	end -- 898
	if route == "child" then -- 898
		if t >= 4.35 then -- 898
			self:playTowerOnce( -- 903
				audio, -- 903
				"f03_line", -- 903
				"voice", -- 903
				____exports.TOWER_AUDIO_FILES.lineXiaomanLamp, -- 903
				0.86, -- 903
				"tower:f03:line_lamp", -- 903
				tick -- 903
			) -- 903
		end -- 903
		if t >= 4.45 then -- 903
			self:playTowerOnce( -- 906
				audio, -- 906
				"f03_bowl", -- 906
				"sfx", -- 906
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 906
				0.8, -- 906
				"tower:bowl_set", -- 906
				tick -- 906
			) -- 906
		end -- 906
		if t >= 5.2 then -- 906
			self:playTowerOnce( -- 909
				audio, -- 909
				"f03_lamp", -- 909
				"sfx", -- 909
				____exports.TOWER_AUDIO_FILES.lampMove, -- 909
				0.82, -- 909
				"tower:f03:lamp_move", -- 909
				tick -- 909
			) -- 909
		end -- 909
	else -- 909
		if t >= 4.28 then -- 909
			self:playTowerOnce( -- 913
				audio, -- 913
				"m03_line", -- 913
				"voice", -- 913
				____exports.TOWER_AUDIO_FILES.lineZhoushuName, -- 913
				0.9, -- 913
				"tower:m03:line_name", -- 913
				tick -- 913
			) -- 913
		end -- 913
		if t >= 4.62 then -- 913
			self:playTowerOnce( -- 916
				audio, -- 916
				"brush2", -- 916
				"sfx", -- 916
				____exports.TOWER_AUDIO_FILES.brush2, -- 916
				0.82, -- 916
				"tower:brush:row2", -- 916
				tick -- 916
			) -- 916
		end -- 916
		if t >= 5.55 then -- 916
			self:playTowerOnce( -- 919
				audio, -- 919
				"m03_needle", -- 919
				"sfx", -- 919
				____exports.TOWER_AUDIO_FILES.needlePlace, -- 919
				0.8, -- 919
				"tower:m03:needle_place", -- 919
				tick -- 919
			) -- 919
		end -- 919
		if t >= 6.02 then -- 919
			self:playTowerOnce( -- 922
				audio, -- 922
				"m03_bowl", -- 922
				"sfx", -- 922
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 922
				0.82, -- 922
				"tower:bowl_set", -- 922
				tick -- 922
			) -- 922
		end -- 922
	end -- 922
end -- 863
function TowerEndingsPlugin.prototype.composeSubtitle(self, route) -- 927
	local t = self.seqElapsed -- 928
	if t < ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 928
		return "[两下轻敲]  门外厚木上传来两声轻敲。" -- 930
	end -- 930
	if t < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 930
		return "[门内回敲]  静默一息，门后轻轻回敲两声。" -- 933
	end -- 933
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 933
		return route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 936
	end -- 936
	if t < ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 936
		return route == "child" and "她把针套与纸条摊在案前，守卒展开收籍末页。" or "两人站在值夜室内，守卒摊开收籍末页。" -- 941
	end -- 941
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 941
		return "守卒蘸墨提笔，在第一行写下「小满」。" -- 946
	end -- 946
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 946
		return "笔尖停在第二行上方。" -- 949
	end -- 949
	if route == "child" then -- 949
		if t < 6.7 then -- 949
			return F03_DIALOGUE -- 953
		end -- 953
		return "" -- 955
	end -- 955
	if t < 5.45 then -- 955
		return M03_DIALOGUE -- 958
	end -- 958
	if t < 6.85 then -- 958
		return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。" -- 961
	end -- 961
	return "" -- 963
end -- 927
function TowerEndingsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 968
	if not self.active then -- 968
		return false -- 976
	end -- 976
	local route = self.activeRoute -- 979
	local t = self.seqElapsed -- 980
	local lampProg = route == "child" and smoothstep(5.2, 6.75, t) or 0 -- 981
	local scaled = computeScaledAnchors(ctx.uiW, ctx.uiH, lampProg) -- 982
	local s = scaled.s -- 983
	local ox = scaled.ox -- 984
	local oy = scaled.oy -- 985
	uiDraw:drawRect( -- 988
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 988
		Color(8, 10, 16, 255) -- 988
	) -- 988
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 988
		self:drawAct1PorchAndDoor( -- 992
			uiDraw, -- 992
			uiInkDraw, -- 992
			uiArt, -- 992
			uiGlow, -- 992
			ctx, -- 992
			route, -- 992
			s, -- 992
			ox, -- 992
			oy -- 992
		) -- 992
		local fadeOut = smoothstep(1.22, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec, t) -- 994
		if fadeOut > 0.01 then -- 994
			uiInkDraw:drawRect( -- 996
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 996
				Color( -- 996
					8, -- 996
					10, -- 996
					16, -- 996
					math.floor(230 * fadeOut + 0.5) -- 996
				) -- 996
			) -- 996
		end -- 996
	else -- 996
		self:drawAct2And3Guardroom( -- 1000
			uiDraw, -- 1000
			uiInkDraw, -- 1000
			uiArt, -- 1000
			uiGlow, -- 1000
			ctx, -- 1000
			route, -- 1000
			lampProg, -- 1000
			s, -- 1000
			ox, -- 1000
			oy -- 1000
		) -- 1000
		local fadeIn = 1 - smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.24, t) -- 1001
		if fadeIn > 0.01 then -- 1001
			uiInkDraw:drawRect( -- 1003
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1003
				Color( -- 1003
					8, -- 1003
					10, -- 1003
					16, -- 1003
					math.floor(220 * fadeIn + 0.5) -- 1003
				) -- 1003
			) -- 1003
		end -- 1003
	end -- 1003
	local barH = math.floor(____exports.TOWER_SHOT_LAYOUT.letterboxH * s + 0.5) -- 1008
	uiInkDraw:drawRect( -- 1009
		Rect(0, ctx.uiH - barH, ctx.uiW, barH), -- 1009
		Color(7, 9, 14, 248) -- 1009
	) -- 1009
	uiInkDraw:drawRect( -- 1010
		Rect(0, 0, ctx.uiW, barH), -- 1010
		Color(7, 9, 14, 248) -- 1010
	) -- 1010
	uiInkDraw:drawSegment( -- 1011
		Vec2(0, ctx.uiH - barH), -- 1011
		Vec2(ctx.uiW, ctx.uiH - barH), -- 1011
		0.9, -- 1011
		toColor(PALETTE.silkDim, 82) -- 1011
	) -- 1011
	uiInkDraw:drawSegment( -- 1012
		Vec2(0, barH), -- 1012
		Vec2(ctx.uiW, barH), -- 1012
		0.9, -- 1012
		toColor(PALETTE.silkDim, 82) -- 1012
	) -- 1012
	self:drawDialogueSubtitle( -- 1015
		uiDraw, -- 1015
		uiInkDraw, -- 1015
		uiArt, -- 1015
		ctx, -- 1015
		route, -- 1015
		s, -- 1015
		barH -- 1015
	) -- 1015
	return true -- 1017
end -- 968
function TowerEndingsPlugin.prototype.drawAct1PorchAndDoor(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1022
	local t = self.seqElapsed -- 1033
	local isLowpoly = route == "child" -- 1034
	local openK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, 1.24, t) -- 1035
	local doorCx = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s -- 1036
	local threshY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s -- 1037
	local doorW = ____exports.TOWER_SHOT_LAYOUT.doorW * s -- 1038
	local doorH = ____exports.TOWER_SHOT_LAYOUT.doorH * s -- 1039
	local doorL = doorCx - doorW * 0.5 -- 1040
	local doorR = doorCx + doorW * 0.5 -- 1041
	local k1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock1Sec) / 0.055) ^ 2) -- 1044
	local k2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock2Sec) / 0.055) ^ 2) -- 1045
	local r1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply1Sec) / 0.06) ^ 2) -- 1046
	local r2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply2Sec) / 0.06) ^ 2) -- 1047
	local doorShakeX = (k1Pulse + k2Pulse) * 2.4 * s * math.sin(t * 95) + (r1Pulse + r2Pulse) * 1.4 * s * math.sin(t * 80) -- 1048
	if isLowpoly then -- 1048
		local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, openK * 0.62) -- 1053
		fillVGradRect( -- 1054
			uiDraw, -- 1055
			0, -- 1055
			0, -- 1055
			ctx.uiW, -- 1055
			ctx.uiH, -- 1055
			Color(12, 16, 26, 255), -- 1056
			Color(20, 28, 44, 255) -- 1057
		) -- 1057
		local wallCol = shadeSurface( -- 1060
			MING_MATERIALS.mingBrickDark.base, -- 1060
			vec3(0, 0, -1), -- 1060
			24, -- 1060
			1, -- 1060
			light, -- 1060
			MING_MATERIALS.mingBrickDark -- 1060
		) -- 1060
		local jambCol = shadeSurface( -- 1061
			MING_MATERIALS.mingBrick.base, -- 1061
			vec3(0.75, 0.15, -0.64), -- 1061
			10, -- 1061
			1, -- 1061
			light, -- 1061
			MING_MATERIALS.mingBrick -- 1061
		) -- 1061
		local jambRCol = shadeSurface( -- 1062
			MING_MATERIALS.mingBrick.base, -- 1062
			vec3(-0.75, 0.15, -0.64), -- 1062
			10, -- 1062
			1, -- 1062
			light, -- 1062
			MING_MATERIALS.mingBrick -- 1062
		) -- 1062
		local lintelCol = shadeSurface( -- 1063
			MING_MATERIALS.mingStoneStep.base, -- 1063
			vec3(0, -0.55, -0.83), -- 1063
			6, -- 1063
			1, -- 1063
			light, -- 1063
			MING_MATERIALS.mingStoneStep -- 1063
		) -- 1063
		local stepCol = shadeSurface( -- 1064
			MING_MATERIALS.mingStoneStep.base, -- 1064
			vec3(0, 0.92, -0.39), -- 1064
			0, -- 1064
			1, -- 1064
			light, -- 1064
			MING_MATERIALS.mingStoneStep -- 1064
		) -- 1064
		uiDraw:drawRect( -- 1066
			Rect(0, threshY, doorL - 26 * s, ctx.uiH - threshY), -- 1066
			toColor(wallCol) -- 1066
		) -- 1066
		uiDraw:drawRect( -- 1067
			Rect(doorR + 26 * s, threshY, ctx.uiW - (doorR + 26 * s), ctx.uiH - threshY), -- 1067
			toColor(wallCol) -- 1067
		) -- 1067
		uiDraw:drawPolygon( -- 1069
			{ -- 1069
				Vec2(doorL - 26 * s, threshY), -- 1070
				Vec2(doorL, threshY + 12 * s), -- 1071
				Vec2(doorL, threshY + doorH - 8 * s), -- 1072
				Vec2(doorL - 26 * s, threshY + doorH + 18 * s) -- 1073
			}, -- 1073
			toColor(jambCol), -- 1074
			1, -- 1074
			toColor(PALETTE.silkDim, 68) -- 1074
		) -- 1074
		uiDraw:drawPolygon( -- 1075
			{ -- 1075
				Vec2(doorR + 26 * s, threshY), -- 1076
				Vec2(doorR, threshY + 12 * s), -- 1077
				Vec2(doorR, threshY + doorH - 8 * s), -- 1078
				Vec2(doorR + 26 * s, threshY + doorH + 18 * s) -- 1079
			}, -- 1079
			toColor(jambRCol), -- 1080
			1, -- 1080
			toColor(PALETTE.silkDim, 68) -- 1080
		) -- 1080
		uiDraw:drawPolygon( -- 1082
			{ -- 1082
				Vec2(doorL - 44 * s, threshY + doorH + 18 * s), -- 1083
				Vec2(doorR + 44 * s, threshY + doorH + 18 * s), -- 1084
				Vec2(doorR + 58 * s, threshY + doorH + 92 * s), -- 1085
				Vec2(doorL - 58 * s, threshY + doorH + 92 * s) -- 1086
			}, -- 1086
			toColor(lintelCol), -- 1087
			1.1, -- 1087
			toColor(STONE_EDGE_FALLBACK, 130) -- 1087
		) -- 1087
		uiDraw:drawRect( -- 1089
			Rect(0, 0, ctx.uiW, threshY), -- 1089
			Color(16, 20, 30, 255) -- 1089
		) -- 1089
		uiDraw:drawPolygon( -- 1090
			{ -- 1090
				Vec2(doorL - 58 * s, threshY - 20 * s), -- 1091
				Vec2(doorR + 58 * s, threshY - 20 * s), -- 1092
				Vec2(doorR + 28 * s, threshY + 12 * s), -- 1093
				Vec2(doorL - 28 * s, threshY + 12 * s) -- 1094
			}, -- 1094
			toColor(stepCol), -- 1095
			1, -- 1095
			toColor(STONE_EDGE_FALLBACK, 150) -- 1095
		) -- 1095
		uiDraw:drawPolygon( -- 1097
			{ -- 1097
				Vec2(0, 0), -- 1098
				Vec2(142 * s, 0), -- 1099
				Vec2(114 * s, ctx.uiH), -- 1100
				Vec2(0, ctx.uiH) -- 1101
			}, -- 1101
			Color(10, 14, 22, 220) -- 1102
		) -- 1102
		uiDraw:drawPolygon( -- 1103
			{ -- 1103
				Vec2(ctx.uiW - 142 * s, 0), -- 1104
				Vec2(ctx.uiW, 0), -- 1105
				Vec2(ctx.uiW, ctx.uiH), -- 1106
				Vec2(ctx.uiW - 114 * s, ctx.uiH) -- 1107
			}, -- 1107
			Color(10, 14, 22, 220) -- 1108
		) -- 1108
	else -- 1108
		fillVGradRect( -- 1111
			uiDraw, -- 1112
			0, -- 1112
			0, -- 1112
			ctx.uiW, -- 1112
			ctx.uiH, -- 1112
			Color(18, 22, 32, 255), -- 1113
			Color(32, 38, 52, 255) -- 1114
		) -- 1114
		uiDraw:drawPolygon( -- 1117
			{ -- 1117
				Vec2(0, threshY), -- 1118
				Vec2(doorL, threshY), -- 1119
				Vec2(doorL, threshY + 188 * s), -- 1120
				Vec2(doorL * 0.55, threshY + 230 * s), -- 1121
				Vec2(doorL * 0.22, threshY + 172 * s), -- 1122
				Vec2(0, threshY + 196 * s) -- 1123
			}, -- 1123
			Color(26, 30, 40, 235) -- 1124
		) -- 1124
		uiDraw:drawPolygon( -- 1125
			{ -- 1125
				Vec2(doorR, threshY), -- 1126
				Vec2(ctx.uiW, threshY), -- 1127
				Vec2(ctx.uiW, threshY + 218 * s), -- 1128
				Vec2(doorR + (ctx.uiW - doorR) * 0.56, threshY + 248 * s), -- 1129
				Vec2(doorR, threshY + 178 * s) -- 1130
			}, -- 1130
			Color(26, 30, 40, 235) -- 1131
		) -- 1131
		uiDraw:drawRect( -- 1133
			Rect(0, threshY, doorL, ctx.uiH - threshY), -- 1133
			Color(54, 56, 62, 255), -- 1133
			1, -- 1133
			Color(88, 90, 96, 155) -- 1133
		) -- 1133
		uiDraw:drawRect( -- 1134
			Rect(doorR, threshY, ctx.uiW - doorR, ctx.uiH - threshY), -- 1134
			Color(54, 56, 62, 255), -- 1134
			1, -- 1134
			Color(88, 90, 96, 155) -- 1134
		) -- 1134
		uiDraw:drawRect( -- 1135
			Rect(doorL - 28 * s, threshY + doorH, doorW + 56 * s, 68 * s), -- 1135
			Color(72, 68, 62, 255), -- 1135
			1, -- 1135
			Color(124, 114, 100, 175) -- 1135
		) -- 1135
		local row = 0 -- 1136
		do -- 1136
			row = 0 -- 1137
			while row < 10 do -- 1137
				local by = threshY + row * 46 * s -- 1138
				uiDraw:drawSegment( -- 1139
					Vec2(0, by), -- 1139
					Vec2(doorL, by), -- 1139
					1, -- 1139
					Color(34, 36, 42, 175) -- 1139
				) -- 1139
				uiDraw:drawSegment( -- 1140
					Vec2(doorR, by), -- 1140
					Vec2(ctx.uiW, by), -- 1140
					1, -- 1140
					Color(34, 36, 42, 175) -- 1140
				) -- 1140
				local stag = row % 2 * 34 * s -- 1141
				local col = 0 -- 1142
				do -- 1142
					col = 0 -- 1143
					while col < 7 do -- 1143
						local lx = stag + col * 68 * s -- 1144
						if lx > 4 * s and lx < doorL - 4 * s then -- 1144
							uiDraw:drawSegment( -- 1146
								Vec2(lx, by), -- 1146
								Vec2(lx, by + 46 * s), -- 1146
								0.9, -- 1146
								Color(36, 38, 44, 130) -- 1146
							) -- 1146
						end -- 1146
						local rx = doorR + stag + col * 68 * s -- 1148
						if rx > doorR + 4 * s and rx < ctx.uiW - 4 * s then -- 1148
							uiDraw:drawSegment( -- 1150
								Vec2(rx, by), -- 1150
								Vec2(rx, by + 46 * s), -- 1150
								0.9, -- 1150
								Color(36, 38, 44, 130) -- 1150
							) -- 1150
						end -- 1150
						col = col + 1 -- 1143
					end -- 1143
				end -- 1143
				row = row + 1 -- 1137
			end -- 1137
		end -- 1137
		uiDraw:drawRect( -- 1155
			Rect(0, 0, ctx.uiW, threshY), -- 1155
			Color(28, 26, 28, 255) -- 1155
		) -- 1155
		uiDraw:drawRect( -- 1156
			Rect(doorL - 36 * s, threshY - 12 * s, doorW + 72 * s, 22 * s), -- 1156
			Color(96, 94, 92, 255), -- 1156
			1, -- 1156
			Color(156, 152, 144, 175) -- 1156
		) -- 1156
	end -- 1156
	local innerWarm = 0.22 + openK * 0.78 + (r1Pulse + r2Pulse) * 0.14 -- 1160
	fillVGradRect( -- 1161
		uiDraw, -- 1162
		doorL, -- 1162
		threshY + 8 * s, -- 1162
		doorW, -- 1162
		doorH - 8 * s, -- 1162
		Color( -- 1163
			46, -- 1163
			32, -- 1163
			20, -- 1163
			math.floor(255 * math.min(1, innerWarm + 0.15) + 0.5) -- 1163
		), -- 1163
		Color( -- 1164
			118, -- 1164
			82, -- 1164
			42, -- 1164
			math.floor(255 * math.min(1, innerWarm) + 0.5) -- 1164
		) -- 1164
	) -- 1164
	local leafW = math.max(26 * s, doorW * (1 - openK * 0.76)) -- 1168
	local leafX = doorL + doorShakeX * (1 - openK) -- 1169
	local woodCol = isLowpoly and toColor(shadeSurface( -- 1170
		MING_MATERIALS.mingTimberDark.base, -- 1171
		vec3(-0.2, 0.25, -0.95), -- 1171
		4, -- 1171
		1, -- 1171
		TOWER_WEST_LAMP_LIGHT, -- 1171
		MING_MATERIALS.mingTimberDark -- 1171
	)) or Color(76, 54, 38, 255) -- 1171
	uiDraw:drawRect( -- 1173
		Rect(leafX, threshY + 12 * s, leafW, doorH - 14 * s), -- 1174
		woodCol, -- 1175
		1.4, -- 1176
		Color(138, 106, 74, 185) -- 1177
	) -- 1177
	local planks = 4 -- 1180
	local pi = 1 -- 1181
	do -- 1181
		pi = 1 -- 1182
		while pi < planks do -- 1182
			local px = leafX + leafW * pi / planks -- 1183
			uiDraw:drawSegment( -- 1184
				Vec2(px, threshY + 14 * s), -- 1184
				Vec2(px, threshY + doorH - 4 * s), -- 1184
				1.1, -- 1184
				Color(38, 26, 18, 185) -- 1184
			) -- 1184
			pi = pi + 1 -- 1182
		end -- 1182
	end -- 1182
	uiDraw:drawRect( -- 1186
		Rect(leafX + 4 * s, threshY + doorH * 0.24, leafW - 8 * s, 10 * s), -- 1186
		Color(54, 38, 26, 225) -- 1186
	) -- 1186
	uiDraw:drawRect( -- 1187
		Rect(leafX + 4 * s, threshY + doorH * 0.74, leafW - 8 * s, 10 * s), -- 1187
		Color(54, 38, 26, 225) -- 1187
	) -- 1187
	local ringX = leafX + leafW * 0.72 -- 1189
	local ringY = threshY + doorH * 0.56 -- 1190
	uiDraw:drawRect( -- 1191
		Rect(ringX - 6 * s, ringY + 4 * s, 12 * s, 12 * s), -- 1191
		Color(42, 46, 52, 235), -- 1191
		1, -- 1191
		Color(96, 100, 108, 170) -- 1191
	) -- 1191
	strokeEllipse( -- 1192
		uiDraw, -- 1192
		ringX, -- 1192
		ringY - 2 * s, -- 1192
		8 * s, -- 1192
		9 * s, -- 1192
		1.8 * s, -- 1192
		Color(108, 112, 118, 195), -- 1192
		16 -- 1192
	) -- 1192
	local seamGlowA = math.floor(92 + openK * 145 + (r1Pulse + r2Pulse) * 48 + 0.5) -- 1195
	fillRadialGlow( -- 1196
		uiGlow, -- 1197
		doorCx + openK * 24 * s, -- 1197
		threshY + 14 * s, -- 1197
		(92 + openK * 120) * s, -- 1198
		(26 + openK * 58) * s, -- 1198
		Color( -- 1199
			246, -- 1199
			204, -- 1199
			134, -- 1199
			math.min(220, seamGlowA) -- 1199
		), -- 1199
		Color(220, 156, 72, 0), -- 1200
		18 -- 1201
	) -- 1201
	local kx = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s -- 1205
	local ky = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s -- 1206
	if k1Pulse > 0.08 or k2Pulse > 0.08 then -- 1206
		local amp = math.max(k1Pulse, k2Pulse) -- 1208
		local r = (18 + (1 - amp) * 34) * s -- 1209
		strokeEllipse( -- 1210
			uiInkDraw, -- 1210
			kx + 24 * s, -- 1210
			ky, -- 1210
			r, -- 1210
			r * 0.85, -- 1210
			1.8 * s, -- 1210
			toColor( -- 1210
				PALETTE.amberCore, -- 1210
				math.floor(210 * amp + 0.5) -- 1210
			), -- 1210
			24 -- 1210
		) -- 1210
	end -- 1210
	if r1Pulse > 0.08 or r2Pulse > 0.08 then -- 1210
		local amp = math.max(r1Pulse, r2Pulse) -- 1213
		local r = (24 + (1 - amp) * 42) * s -- 1214
		strokeEllipse( -- 1215
			uiInkDraw, -- 1215
			doorCx + 30 * s, -- 1215
			ky + 16 * s, -- 1215
			r, -- 1215
			r * 0.9, -- 1215
			1.6 * s, -- 1215
			toColor( -- 1215
				PALETTE.amber, -- 1215
				math.floor(185 * amp + 0.5) -- 1215
			), -- 1215
			24 -- 1215
		) -- 1215
	end -- 1215
	if openK > 0.05 then -- 1215
		local lanX = ox + ____exports.TOWER_SHOT_LAYOUT.doorLanternX * s + (1 - openK) * 42 * s -- 1220
		local lanY = oy + ____exports.TOWER_SHOT_LAYOUT.doorLanternY * s -- 1221
		uiInkDraw:drawPolygon( -- 1223
			{ -- 1223
				Vec2(lanX + 76 * s, lanY + 42 * s), -- 1224
				Vec2(lanX + 12 * s, lanY + 34 * s), -- 1225
				Vec2(lanX + 8 * s, lanY + 12 * s), -- 1226
				Vec2(lanX + 78 * s, lanY + 12 * s) -- 1227
			}, -- 1227
			Color( -- 1228
				54, -- 1228
				48, -- 1228
				44, -- 1228
				math.floor(240 * openK + 0.5) -- 1228
			), -- 1228
			1, -- 1228
			Color( -- 1228
				98, -- 1228
				86, -- 1228
				74, -- 1228
				math.floor(180 * openK + 0.5) -- 1228
			) -- 1228
		) -- 1228
		self:drawMingLantern( -- 1229
			uiInkDraw, -- 1229
			uiGlow, -- 1229
			lanX, -- 1229
			lanY - 14 * s, -- 1229
			1.08 * s, -- 1229
			openK, -- 1229
			1 -- 1229
		) -- 1229
		fillRadialGlow( -- 1231
			uiGlow, -- 1232
			kx + 12 * s, -- 1232
			ky - 14 * s, -- 1232
			148 * s, -- 1233
			128 * s, -- 1233
			Color( -- 1234
				246, -- 1234
				208, -- 1234
				142, -- 1234
				math.floor(98 * openK + 0.5) -- 1234
			), -- 1234
			Color(232, 174, 92, 0), -- 1235
			18 -- 1236
		) -- 1236
	end -- 1236
	local stepInX = openK * 44 * s -- 1241
	local xiaomanX = doorCx - 66 * s + stepInX -- 1242
	local xiaomanY = threshY - 2 * s -- 1243
	uiDraw:drawEllipse( -- 1245
		Vec2(xiaomanX, xiaomanY + 2 * s), -- 1245
		34 * s, -- 1245
		8 * s, -- 1245
		Color(4, 6, 12, 190) -- 1245
	) -- 1245
	local childSlot = (k1Pulse > 0.25 or k2Pulse > 0.25) and "child_knock" or (openK > 0.45 and "child_offer" or "child_idle") -- 1246
	uiArt:tryPlace( -- 1247
		childSlot, -- 1247
		"fe05_porch_child", -- 1247
		xiaomanX, -- 1247
		xiaomanY, -- 1247
		108 * s, -- 1247
		148 * s, -- 1247
		{facing = 1, opacity = 0.98, layer = 2} -- 1247
	) -- 1247
	if openK > 0.15 then -- 1247
		local wristX = xiaomanX + 22 * s -- 1252
		local wristY = xiaomanY + 76 * s -- 1253
		uiInkDraw:drawRect( -- 1254
			Rect(wristX - 7 * s, wristY - 5 * s, 14 * s, 11 * s), -- 1255
			Color( -- 1256
				142, -- 1256
				118, -- 1256
				84, -- 1256
				math.floor(245 * openK + 0.5) -- 1256
			), -- 1256
			1, -- 1257
			Color( -- 1258
				222, -- 1258
				192, -- 1258
				128, -- 1258
				math.floor(235 * openK + 0.5) -- 1258
			) -- 1258
		) -- 1258
		uiInkDraw:drawSegment( -- 1260
			Vec2(wristX - 8 * s, wristY), -- 1261
			Vec2(wristX + 8 * s, wristY + 2 * s), -- 1262
			2 * s, -- 1263
			toColor( -- 1264
				CUFF_PALETTE.childCord, -- 1264
				math.floor(240 * openK + 0.5) -- 1264
			) -- 1264
		) -- 1264
	end -- 1264
	if route == "soldier" then -- 1264
		local zhouX = xiaomanX - 72 * s -- 1270
		local zhouY = threshY - 2 * s -- 1271
		uiDraw:drawEllipse( -- 1272
			Vec2(zhouX, zhouY + 2 * s), -- 1272
			42 * s, -- 1272
			9 * s, -- 1272
			Color(4, 6, 12, 190) -- 1272
		) -- 1272
		uiArt:tryPlace( -- 1273
			"soldier_idle", -- 1273
			"fe05_porch_soldier", -- 1273
			zhouX, -- 1273
			zhouY, -- 1273
			146 * s, -- 1273
			206 * s, -- 1273
			{facing = 1, opacity = 0.98, layer = 2} -- 1273
		) -- 1273
		local handMidX = (zhouX + xiaomanX) * 0.5 + 4 * s -- 1277
		local handMidY = threshY + 66 * s -- 1278
		uiInkDraw:drawSegment( -- 1279
			Vec2(zhouX + 20 * s, threshY + 106 * s), -- 1280
			Vec2(handMidX - 2 * s, handMidY), -- 1281
			6.2 * s, -- 1282
			toColor(CUFF_PALETTE.indigoBase, 245) -- 1283
		) -- 1283
		uiInkDraw:drawSegment( -- 1285
			Vec2(handMidX - 9 * s, handMidY + 9 * s), -- 1286
			Vec2(handMidX - 3 * s, handMidY + 13 * s), -- 1287
			1.9 * s, -- 1288
			toColor(CUFF_PALETTE.stitchThread, 240) -- 1289
		) -- 1289
		uiInkDraw:drawSegment( -- 1291
			Vec2(xiaomanX - 14 * s, threshY + 78 * s), -- 1292
			Vec2(handMidX + 2 * s, handMidY), -- 1293
			4.8 * s, -- 1294
			toColor(CUFF_PALETTE.childSleeve, 245) -- 1295
		) -- 1295
		uiInkDraw:drawDot( -- 1297
			Vec2(handMidX, handMidY), -- 1297
			4.8 * s, -- 1297
			toColor(CUFF_PALETTE.skinLight, 245) -- 1297
		) -- 1297
	end -- 1297
end -- 1022
function TowerEndingsPlugin.prototype.drawAct2And3Guardroom(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy) -- 1303
	local t = self.seqElapsed -- 1315
	local isLowpoly = route == "child" -- 1316
	local deskY = oy + ____exports.TOWER_SHOT_LAYOUT.deskTopY * s -- 1317
	if isLowpoly then -- 1317
		self:drawF03LowpolyRoomAndWindow( -- 1321
			uiDraw, -- 1321
			uiGlow, -- 1321
			ctx, -- 1321
			lampProg, -- 1321
			s, -- 1321
			ox, -- 1321
			oy -- 1321
		) -- 1321
	else -- 1321
		self:drawM03PixelRoomAndWindow( -- 1323
			uiDraw, -- 1323
			uiArt, -- 1323
			uiGlow, -- 1323
			ctx, -- 1323
			s, -- 1323
			ox, -- 1323
			oy -- 1323
		) -- 1323
	end -- 1323
	local deskTopCol = isLowpoly and toColor(shadeSurface( -- 1327
		MING_MATERIALS.mingTimber.base, -- 1329
		vec3(-0.25, 0.9, -0.35), -- 1330
		0, -- 1331
		1, -- 1332
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1333
		MING_MATERIALS.mingTimber -- 1334
	)) or Color(86, 60, 42, 255) -- 1334
	local deskFrontCol = isLowpoly and toColor(shadeSurface( -- 1337
		MING_MATERIALS.mingTimberDark.base, -- 1339
		vec3(0, 0.1, -0.99), -- 1340
		-4, -- 1340
		1, -- 1342
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1343
		MING_MATERIALS.mingTimberDark -- 1344
	)) or Color(52, 36, 26, 255) -- 1344
	uiDraw:drawPolygon( -- 1349
		{ -- 1349
			Vec2(0, deskY - 120 * s), -- 1350
			Vec2(ctx.uiW, deskY - 120 * s), -- 1351
			Vec2(ctx.uiW, deskY + 42 * s), -- 1352
			Vec2(0, deskY + 42 * s) -- 1353
		}, -- 1353
		deskTopCol -- 1354
	) -- 1354
	uiDraw:drawRect( -- 1355
		Rect(0, 0, ctx.uiW, deskY - 118 * s), -- 1355
		deskFrontCol -- 1355
	) -- 1355
	uiDraw:drawSegment( -- 1356
		Vec2(0, deskY + 42 * s), -- 1356
		Vec2(ctx.uiW, deskY + 42 * s), -- 1356
		1.6 * s, -- 1356
		Color(158, 126, 92, 165) -- 1356
	) -- 1356
	uiDraw:drawSegment( -- 1357
		Vec2(0, deskY - 118 * s), -- 1357
		Vec2(ctx.uiW, deskY - 118 * s), -- 1357
		2 * s, -- 1357
		Color(172, 138, 102, 155) -- 1357
	) -- 1357
	local inkX = ox + ____exports.TOWER_SHOT_LAYOUT.inkstoneX * s -- 1360
	local inkY = oy + ____exports.TOWER_SHOT_LAYOUT.inkstoneY * s -- 1361
	uiDraw:drawEllipse( -- 1362
		Vec2(inkX + 3 * s, inkY - 18 * s), -- 1362
		44 * s, -- 1362
		11 * s, -- 1362
		Color(10, 10, 14, 145) -- 1362
	) -- 1362
	uiDraw:drawPolygon( -- 1363
		{ -- 1363
			Vec2(inkX - 38 * s, inkY - 18 * s), -- 1364
			Vec2(inkX + 38 * s, inkY - 18 * s), -- 1365
			Vec2(inkX + 32 * s, inkY + 18 * s), -- 1366
			Vec2(inkX - 32 * s, inkY + 18 * s) -- 1367
		}, -- 1367
		Color(38, 44, 52, 255), -- 1368
		1.2, -- 1368
		Color(96, 106, 118, 185) -- 1368
	) -- 1368
	uiDraw:drawEllipse( -- 1369
		Vec2(inkX, inkY + 1 * s), -- 1369
		22 * s, -- 1369
		10 * s, -- 1369
		Color(12, 14, 18, 255) -- 1369
	) -- 1369
	strokeEllipse( -- 1370
		uiDraw, -- 1370
		inkX, -- 1370
		inkY + 1 * s, -- 1370
		22 * s, -- 1370
		10 * s, -- 1370
		1.1 * s, -- 1370
		Color(76, 86, 98, 165), -- 1370
		18 -- 1370
	) -- 1370
	local lx = isLowpoly and ox + lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s or ox + ____exports.TOWER_SHOT_LAYOUT.lampDeskX * s -- 1373
	local ly = isLowpoly and oy + (lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34) * s or oy + ____exports.TOWER_SHOT_LAYOUT.lampDeskY * s -- 1376
	local lampWarmth = isLowpoly and 0.45 + 0.55 * lampProg or 0.92 -- 1379
	self:drawMingLantern( -- 1380
		uiInkDraw, -- 1380
		uiGlow, -- 1380
		lx, -- 1380
		ly, -- 1380
		1.02 * s, -- 1380
		1, -- 1380
		lampWarmth -- 1380
	) -- 1380
	if isLowpoly and lampProg > 0.04 then -- 1380
		local beamA = math.floor(62 * lampProg + 0.5) -- 1384
		fillGradQuad( -- 1385
			uiGlow, -- 1386
			lx + 10 * s, -- 1387
			ly + 30 * s, -- 1387
			Color(248, 206, 134, beamA), -- 1387
			lx + 10 * s, -- 1388
			ly - 32 * s, -- 1388
			Color( -- 1388
				248, -- 1388
				206, -- 1388
				134, -- 1388
				math.floor(beamA * 0.72 + 0.5) -- 1388
			), -- 1388
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.92) * s, -- 1389
			oy + (____exports.TOWER_SHOT_LAYOUT.row2Y - 58) * s, -- 1389
			Color(242, 198, 124, 0), -- 1389
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.85) * s, -- 1390
			oy + (____exports.TOWER_SHOT_LAYOUT.row1Y + 48) * s, -- 1390
			Color(242, 198, 124, 0) -- 1390
		) -- 1390
	end -- 1390
	local bookReveal = smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t) -- 1395
	if bookReveal > 0.02 then -- 1395
		self:drawRegisterBook( -- 1397
			uiDraw, -- 1397
			uiInkDraw, -- 1397
			uiArt, -- 1397
			uiGlow, -- 1397
			ctx, -- 1397
			route, -- 1397
			bookReveal, -- 1397
			lampProg, -- 1397
			s, -- 1397
			ox, -- 1397
			oy -- 1397
		) -- 1397
	end -- 1397
	self:drawDeskPropsAndBowl( -- 1401
		uiDraw, -- 1401
		uiInkDraw, -- 1401
		uiGlow, -- 1401
		route, -- 1401
		s, -- 1401
		ox, -- 1401
		oy -- 1401
	) -- 1401
end -- 1303
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiGlow, ctx, lampProg, s, ox, oy) -- 1404
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1413
	local wallTop = lerpRGBA( -- 1414
		rgba(18, 24, 38, 255), -- 1414
		rgba(46, 36, 28, 255), -- 1414
		lampProg -- 1414
	) -- 1414
	local wallBot = lerpRGBA( -- 1415
		rgba(12, 16, 26, 255), -- 1415
		rgba(28, 22, 20, 255), -- 1415
		lampProg -- 1415
	) -- 1415
	fillVGradRect( -- 1416
		uiDraw, -- 1416
		0, -- 1416
		0, -- 1416
		ctx.uiW, -- 1416
		ctx.uiH, -- 1416
		toColor(wallBot), -- 1416
		toColor(wallTop) -- 1416
	) -- 1416
	local beamCol = shadeSurface( -- 1419
		MING_MATERIALS.mingTimberDark.base, -- 1419
		vec3(-0.3, -0.6, -0.74), -- 1419
		18, -- 1419
		1, -- 1419
		light, -- 1419
		MING_MATERIALS.mingTimberDark -- 1419
	) -- 1419
	uiDraw:drawPolygon( -- 1420
		{ -- 1420
			Vec2(0, ctx.uiH - 96 * s), -- 1421
			Vec2(ctx.uiW, ctx.uiH - 72 * s), -- 1422
			Vec2(ctx.uiW, ctx.uiH - 42 * s), -- 1423
			Vec2(0, ctx.uiH - 42 * s) -- 1424
		}, -- 1424
		toColor(beamCol) -- 1425
	) -- 1425
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1428
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1429
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1430
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1431
	local embrasure = 24 * s -- 1432
	fillVGradRect( -- 1435
		uiDraw, -- 1435
		wx, -- 1435
		wy, -- 1435
		ww, -- 1435
		wh, -- 1435
		Color(34, 44, 62, 255), -- 1435
		Color(16, 24, 40, 255) -- 1435
	) -- 1435
	uiDraw:drawPolygon( -- 1436
		{ -- 1436
			Vec2(wx, wy), -- 1437
			Vec2(wx + ww, wy), -- 1438
			Vec2(wx + ww, wy + wh * 0.34), -- 1439
			Vec2(wx + ww * 0.56, wy + wh * 0.42), -- 1440
			Vec2(wx + ww * 0.22, wy + wh * 0.28), -- 1441
			Vec2(wx, wy + wh * 0.36) -- 1442
		}, -- 1442
		Color(20, 26, 38, 240) -- 1443
	) -- 1443
	if lampProg > 0.12 then -- 1443
		fillRadialGlow( -- 1446
			uiGlow, -- 1447
			wx + ww * 0.5, -- 1447
			wy + 26 * s, -- 1447
			ww * 0.65, -- 1448
			wh * 0.55, -- 1448
			Color( -- 1449
				248, -- 1449
				206, -- 1449
				134, -- 1449
				math.floor(92 * lampProg + 0.5) -- 1449
			), -- 1449
			Color(232, 174, 88, 0), -- 1450
			16 -- 1451
		) -- 1451
	end -- 1451
	local leftWall = shadeSurface( -- 1456
		MING_MATERIALS.mingBrick.base, -- 1456
		vec3(0.84, 0.22, -0.49), -- 1456
		10, -- 1456
		1, -- 1456
		light, -- 1456
		MING_MATERIALS.mingBrick -- 1456
	) -- 1456
	local rightWall = shadeSurface( -- 1457
		MING_MATERIALS.mingBrick.base, -- 1457
		vec3(-0.84, 0.22, -0.49), -- 1457
		10, -- 1457
		1, -- 1457
		light, -- 1457
		MING_MATERIALS.mingBrick -- 1457
	) -- 1457
	local sillCol = shadeSurface( -- 1458
		MING_MATERIALS.mingStoneStep.base, -- 1458
		vec3(0, 0.94, -0.34), -- 1458
		6, -- 1458
		1, -- 1458
		light, -- 1458
		MING_MATERIALS.mingStoneStep -- 1458
	) -- 1458
	uiDraw:drawPolygon( -- 1459
		{ -- 1459
			Vec2(wx - embrasure, wy - 12 * s), -- 1460
			Vec2(wx, wy), -- 1461
			Vec2(wx, wy + wh), -- 1462
			Vec2(wx - embrasure, wy + wh + 14 * s) -- 1463
		}, -- 1463
		toColor(leftWall) -- 1464
	) -- 1464
	uiDraw:drawPolygon( -- 1465
		{ -- 1465
			Vec2(wx + ww, wy), -- 1466
			Vec2(wx + ww + embrasure, wy - 12 * s), -- 1467
			Vec2(wx + ww + embrasure, wy + wh + 14 * s), -- 1468
			Vec2(wx + ww, wy + wh) -- 1469
		}, -- 1469
		toColor(rightWall) -- 1470
	) -- 1470
	uiDraw:drawPolygon( -- 1472
		{ -- 1472
			Vec2(wx - embrasure - 10 * s, wy - 16 * s), -- 1473
			Vec2(wx + ww + embrasure + 10 * s, wy - 16 * s), -- 1474
			Vec2(wx + ww + 4 * s, wy + 10 * s), -- 1475
			Vec2(wx - 4 * s, wy + 10 * s) -- 1476
		}, -- 1476
		toColor(sillCol), -- 1477
		1, -- 1477
		toColor(STONE_EDGE_FALLBACK, 140) -- 1477
	) -- 1477
	local bar = 1 -- 1480
	do -- 1480
		bar = 1 -- 1481
		while bar <= 3 do -- 1481
			local bx = wx + ww * bar / 4 -- 1482
			uiDraw:drawSegment( -- 1483
				Vec2(bx, wy + 6 * s), -- 1483
				Vec2(bx, wy + wh - 2 * s), -- 1483
				3 * s, -- 1483
				Color(46, 34, 26, 235) -- 1483
			) -- 1483
			bar = bar + 1 -- 1481
		end -- 1481
	end -- 1481
	uiDraw:drawSegment( -- 1485
		Vec2(wx, wy + wh * 0.56), -- 1485
		Vec2(wx + ww, wy + wh * 0.56), -- 1485
		3.2 * s, -- 1485
		Color(46, 34, 26, 235) -- 1485
	) -- 1485
	uiDraw:drawRect( -- 1486
		Rect(wx, wy, ww, wh), -- 1486
		Color(0, 0, 0, 0), -- 1486
		2.4 * s, -- 1486
		Color(66, 50, 38, 240) -- 1486
	) -- 1486
	if lampProg > 0.02 then -- 1486
		fillRadialGlow( -- 1490
			uiGlow, -- 1491
			wx + ww * 0.5, -- 1491
			wy + 34 * s, -- 1491
			540 * s, -- 1492
			390 * s, -- 1492
			Color( -- 1493
				246, -- 1493
				198, -- 1493
				122, -- 1493
				math.floor(74 * lampProg + 0.5) -- 1493
			), -- 1493
			Color(216, 154, 72, 0), -- 1494
			20 -- 1495
		) -- 1495
	end -- 1495
end -- 1404
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1500
	fillVGradRect( -- 1510
		uiDraw, -- 1511
		0, -- 1511
		0, -- 1511
		ctx.uiW, -- 1511
		ctx.uiH, -- 1511
		Color(26, 21, 20, 255), -- 1512
		Color(46, 36, 30, 255) -- 1513
	) -- 1513
	local r = 0 -- 1516
	do -- 1516
		r = 0 -- 1517
		while r < 9 do -- 1517
			local y = oy + (280 + r * 44) * s -- 1518
			uiDraw:drawSegment( -- 1519
				Vec2(0, y), -- 1519
				Vec2(ctx.uiW, y), -- 1519
				1, -- 1519
				Color(34, 27, 24, 150) -- 1519
			) -- 1519
			r = r + 1 -- 1517
		end -- 1517
	end -- 1517
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1523
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1524
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1525
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1526
	fillVGradRect( -- 1527
		uiDraw, -- 1527
		wx, -- 1527
		wy, -- 1527
		ww, -- 1527
		wh, -- 1527
		Color(56, 62, 74, 255), -- 1527
		Color(26, 34, 50, 255) -- 1527
	) -- 1527
	uiDraw:drawRect( -- 1528
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1528
		Color(92, 68, 48, 255), -- 1528
		1, -- 1528
		Color(148, 114, 82, 180) -- 1528
	) -- 1528
	local bar = 1 -- 1529
	do -- 1529
		bar = 1 -- 1530
		while bar <= 3 do -- 1530
			local bx = wx + ww * bar / 4 -- 1531
			uiDraw:drawSegment( -- 1532
				Vec2(bx, wy + 4 * s), -- 1532
				Vec2(bx, wy + wh - 2 * s), -- 1532
				3.2 * s, -- 1532
				Color(64, 46, 34, 245) -- 1532
			) -- 1532
			bar = bar + 1 -- 1530
		end -- 1530
	end -- 1530
	uiDraw:drawSegment( -- 1534
		Vec2(wx, wy + wh * 0.56), -- 1534
		Vec2(wx + ww, wy + wh * 0.56), -- 1534
		3.2 * s, -- 1534
		Color(64, 46, 34, 245) -- 1534
	) -- 1534
	uiDraw:drawRect( -- 1535
		Rect(wx, wy, ww, wh), -- 1535
		Color(0, 0, 0, 0), -- 1535
		2.8 * s, -- 1535
		Color(88, 64, 44, 245) -- 1535
	) -- 1535
	local groupX = ox + 210 * s -- 1538
	local groupY = oy + 300 * s -- 1539
	uiArt:tryPlace( -- 1540
		"soldier_idle", -- 1540
		"fe05_m03_room_soldier", -- 1540
		groupX - 38 * s, -- 1540
		groupY, -- 1540
		118 * s, -- 1540
		166 * s, -- 1540
		{facing = 1, opacity = 0.9, layer = 1} -- 1540
	) -- 1540
	uiArt:tryPlace( -- 1543
		"child_idle", -- 1543
		"fe05_m03_room_child", -- 1543
		groupX + 42 * s, -- 1543
		groupY, -- 1543
		86 * s, -- 1543
		116 * s, -- 1543
		{facing = 1, opacity = 0.92, layer = 1} -- 1543
	) -- 1543
	fillRadialGlow( -- 1548
		uiGlow, -- 1549
		ox + 260 * s, -- 1549
		oy + 416 * s, -- 1549
		520 * s, -- 1550
		360 * s, -- 1550
		Color(246, 202, 134, 68), -- 1551
		Color(220, 158, 76, 0), -- 1552
		20 -- 1553
	) -- 1553
end -- 1500
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1557
	local t = self.seqElapsed -- 1570
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1571
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1572
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1573
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1574
	local midX = bx + bw * 0.5 -- 1575
	local midY = by + bh * 0.5 -- 1576
	uiDraw:drawRect( -- 1579
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1579
		Color( -- 1579
			10, -- 1579
			11, -- 1579
			16, -- 1579
			math.floor(108 * reveal + 0.5) -- 1579
		) -- 1579
	) -- 1579
	uiDraw:drawRect( -- 1580
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1580
		Color( -- 1580
			32, -- 1580
			46, -- 1580
			62, -- 1580
			math.floor(235 * reveal + 0.5) -- 1580
		), -- 1580
		1, -- 1580
		Color( -- 1580
			86, -- 1580
			104, -- 1580
			124, -- 1580
			math.floor(165 * reveal + 0.5) -- 1580
		) -- 1580
	) -- 1580
	if not uiArt:tryPlace( -- 1580
		"ink_song_paper", -- 1583
		"fe05_registry_paper", -- 1583
		midX, -- 1583
		midY, -- 1583
		bw, -- 1583
		bh, -- 1583
		{opacity = 0.98 * reveal, layer = 1} -- 1583
	) then -- 1583
		uiDraw:drawRect( -- 1584
			Rect(bx, by, bw, bh), -- 1585
			toColor( -- 1586
				PALETTE.xuanPaper, -- 1586
				math.floor(248 * reveal + 0.5) -- 1586
			), -- 1586
			1, -- 1587
			toColor( -- 1588
				PALETTE.silkDim, -- 1588
				math.floor(180 * reveal + 0.5) -- 1588
			) -- 1588
		) -- 1588
	end -- 1588
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1593
	fillRadialGlow( -- 1594
		uiGlow, -- 1595
		bx + bw * 0.34, -- 1595
		by + bh * 0.48, -- 1595
		bw * 0.58, -- 1596
		bh * 0.52, -- 1596
		Color( -- 1597
			246, -- 1597
			214, -- 1597
			156, -- 1597
			math.floor(44 * paperWarm * reveal + 0.5) -- 1597
		), -- 1597
		Color(238, 198, 128, 0), -- 1598
		16 -- 1599
	) -- 1599
	local padX = 44 * s -- 1603
	local padY = 32 * s -- 1604
	local inX = bx + padX -- 1605
	local inY = by + padY -- 1606
	local inW = bw - padX * 2 -- 1607
	local inH = bh - padY * 2 -- 1608
	local redSilk = toColor( -- 1609
		PALETTE.rouge, -- 1609
		math.floor(132 * reveal + 0.5) -- 1609
	) -- 1609
	local redFaint = toColor( -- 1610
		PALETTE.rouge, -- 1610
		math.floor(70 * reveal + 0.5) -- 1610
	) -- 1610
	uiInkDraw:drawRect( -- 1611
		Rect(inX, inY, inW, inH), -- 1611
		Color(0, 0, 0, 0), -- 1611
		1, -- 1611
		redSilk -- 1611
	) -- 1611
	uiInkDraw:drawRect( -- 1612
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1612
		Color(0, 0, 0, 0), -- 1612
		0.6, -- 1612
		redFaint -- 1612
	) -- 1612
	local headY = inY + inH - 28 * s -- 1615
	ctx.texts:put( -- 1616
		"md", -- 1616
		"北塔值夜收籍 · 末页", -- 1616
		inX + 18 * s, -- 1616
		headY, -- 1616
		toColor(PALETTE.xuanInk), -- 1616
		0, -- 1616
		0.5, -- 1616
		"Left", -- 1616
		2.2, -- 1616
		0.96 * reveal, -- 1616
		0 -- 1616
	) -- 1616
	ctx.texts:put( -- 1617
		"xs", -- 1617
		"宁村北塔", -- 1617
		inX + inW - 18 * s, -- 1617
		headY, -- 1617
		toColor(PALETTE.xuanInkSub), -- 1617
		1, -- 1617
		0.5, -- 1617
		"Right", -- 1617
		1.8, -- 1617
		0.8 * reveal, -- 1617
		0 -- 1617
	) -- 1617
	uiInkDraw:drawSegment( -- 1618
		Vec2(inX + 14 * s, headY - 22 * s), -- 1618
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1618
		0.9, -- 1618
		redSilk -- 1618
	) -- 1618
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1621
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1622
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1623
	ctx.texts:put( -- 1624
		"sm", -- 1624
		"肆拾壹", -- 1624
		inX + 18 * s, -- 1624
		row1Y, -- 1624
		toColor(PALETTE.rouge), -- 1624
		0, -- 1624
		0.5, -- 1624
		"Left", -- 1624
		1, -- 1624
		0.94 * reveal, -- 1624
		0 -- 1624
	) -- 1624
	if r1Prog > 0.02 then -- 1624
		ctx.texts:put( -- 1626
			"md", -- 1626
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1626
			inX + 96 * s, -- 1626
			row1Y, -- 1626
			toColor(PALETTE.xuanInk), -- 1626
			0, -- 1626
			0.5, -- 1626
			"Left", -- 1626
			1.6, -- 1626
			0.96 * math.min(1, r1Prog * 1.4), -- 1626
			0 -- 1626
		) -- 1626
	end -- 1626
	if r1Prog > 0.65 then -- 1626
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1629
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1630
		ctx.texts:put( -- 1633
			"xs", -- 1633
			subText, -- 1633
			inX + 96 * s, -- 1633
			row1SubY, -- 1633
			toColor(PALETTE.xuanInkSub), -- 1633
			0, -- 1633
			0.5, -- 1633
			"Left", -- 1633
			0.6, -- 1633
			0.88 * subA, -- 1633
			0 -- 1633
		) -- 1633
	end -- 1633
	uiInkDraw:drawSegment( -- 1635
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1635
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1635
		0.7, -- 1635
		redFaint -- 1635
	) -- 1635
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1638
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1639
	ctx.texts:put( -- 1640
		"sm", -- 1640
		"肆拾贰", -- 1640
		inX + 18 * s, -- 1640
		row2Y, -- 1640
		toColor(PALETTE.rouge), -- 1640
		0, -- 1640
		0.5, -- 1640
		"Left", -- 1640
		1, -- 1640
		0.94 * reveal, -- 1640
		0 -- 1640
	) -- 1640
	if route == "child" then -- 1640
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1644
		uiInkDraw:drawSegment( -- 1645
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1646
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1647
			1, -- 1648
			toColor(PALETTE.xuanInkSub, lineA) -- 1649
		) -- 1649
	else -- 1649
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1653
		if r2Prog <= 0.02 then -- 1653
			uiInkDraw:drawSegment( -- 1655
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1656
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1657
				0.9, -- 1658
				toColor( -- 1659
					PALETTE.xuanInkSub, -- 1659
					math.floor(105 * reveal + 0.5) -- 1659
				) -- 1659
			) -- 1659
		else -- 1659
			ctx.texts:put( -- 1662
				"md", -- 1662
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1662
				inX + 96 * s, -- 1662
				row2Y, -- 1662
				toColor(PALETTE.xuanInk), -- 1662
				0, -- 1662
				0.5, -- 1662
				"Left", -- 1662
				1.6, -- 1662
				0.96 * math.min(1, r2Prog * 1.4), -- 1662
				0 -- 1662
			) -- 1662
			if r2Prog > 0.65 then -- 1662
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1664
				ctx.texts:put( -- 1665
					"xs", -- 1665
					"守城戍卒亲口报出姓名，两人俱安。", -- 1665
					inX + 96 * s, -- 1665
					row2SubY, -- 1665
					toColor(PALETTE.xuanInkSub), -- 1665
					0, -- 1665
					0.5, -- 1665
					"Left", -- 1665
					0.6, -- 1665
					0.88 * subA, -- 1665
					0 -- 1665
				) -- 1665
			end -- 1665
		end -- 1665
	end -- 1665
	uiInkDraw:drawSegment( -- 1669
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1669
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1669
		0.7, -- 1669
		redFaint -- 1669
	) -- 1669
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1672
	if colophonA > 0.02 then -- 1672
		local signY = inY + 34 * s -- 1674
		ctx.texts:put( -- 1675
			"banner", -- 1675
			"向西守望", -- 1675
			midX - 24 * s, -- 1675
			signY, -- 1675
			toColor(PALETTE.xuanInk), -- 1675
			0.5, -- 1675
			0.5, -- 1675
			"Center", -- 1675
			6, -- 1675
			0.88 * colophonA, -- 1675
			0 -- 1675
		) -- 1675
	end -- 1675
	self:drawGuardBrushHand( -- 1679
		uiInkDraw, -- 1679
		route, -- 1679
		s, -- 1679
		ox, -- 1679
		oy -- 1679
	) -- 1679
end -- 1557
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, route, s, ox, oy) -- 1682
	local t = self.seqElapsed -- 1689
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1690
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1691
	local row1X0 = hoverX -- 1692
	local row1X1 = hoverX + 142 * s -- 1693
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1694
	local tipX = hoverX -- 1696
	local tipY = hoverY -- 1697
	local alpha = 0 -- 1698
	local lifted = 0 -- 1699
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1699
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1703
		tipX = lerp(row1X0, row1X1, k) -- 1704
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1705
		alpha = smoothstep(2, 2.2, t) -- 1706
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1707
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1707
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1710
		tipX = lerp(row1X1, hoverX, moveK) -- 1711
		tipY = lerp(row1Y, hoverY, moveK) -- 1712
		alpha = 1 -- 1713
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1714
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1714
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1717
		tipX = hoverX + outK * 140 * s -- 1718
		tipY = hoverY + outK * 46 * s -- 1719
		lifted = (9 + outK * 28) * s -- 1720
		alpha = 1 - outK -- 1721
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1721
		if t < 4.6 then -- 1721
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1725
			tipX = hoverX -- 1726
			tipY = hoverY -- 1727
			lifted = lerp(9 * s, 0, dipK) -- 1728
			alpha = 1 -- 1729
		elseif t < 5.55 then -- 1729
			local wK = smoothstep(4.6, 5.55, t) -- 1731
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1732
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1733
			lifted = 0 -- 1734
			alpha = 1 -- 1735
		else -- 1735
			local outK = smoothstep(5.55, 6.05, t) -- 1737
			tipX = hoverX + 216 * s + outK * 115 * s -- 1738
			tipY = hoverY + outK * 52 * s -- 1739
			lifted = outK * 24 * s -- 1740
			alpha = 1 - outK -- 1741
		end -- 1741
	end -- 1741
	if alpha <= 0.02 then -- 1741
		return -- 1746
	end -- 1746
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1749
	local bx = tipX -- 1750
	local by = tipY + lifted -- 1751
	uiInkDraw:drawEllipse( -- 1753
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1753
		(5 + lifted * 0.22) * s, -- 1753
		2.8 * s, -- 1753
		Color( -- 1753
			20, -- 1753
			18, -- 1753
			16, -- 1753
			math.floor(78 * alpha + 0.5) -- 1753
		) -- 1753
	) -- 1753
	uiInkDraw:drawPolygon( -- 1755
		{ -- 1755
			Vec2(bx, by), -- 1756
			Vec2(bx + 15 * s, by - 4 * s), -- 1757
			Vec2(bx + 10 * s, by + 8 * s) -- 1758
		}, -- 1758
		Color(22, 22, 26, a) -- 1759
	) -- 1759
	uiInkDraw:drawSegment( -- 1761
		Vec2(bx + 12 * s, by + 2 * s), -- 1761
		Vec2(bx + 24 * s, by + 6 * s), -- 1761
		7.8 * s, -- 1761
		Color(164, 138, 92, a) -- 1761
	) -- 1761
	uiInkDraw:drawSegment( -- 1762
		Vec2(bx + 22 * s, by + 5 * s), -- 1762
		Vec2(bx + 122 * s, by + 34 * s), -- 1762
		6.8 * s, -- 1762
		Color(142, 110, 74, a) -- 1762
	) -- 1762
	uiInkDraw:drawSegment( -- 1763
		Vec2(bx + 22 * s, by + 5 * s), -- 1763
		Vec2(bx + 122 * s, by + 34 * s), -- 1763
		1.8 * s, -- 1763
		Color( -- 1763
			196, -- 1763
			164, -- 1763
			118, -- 1763
			math.floor(185 * alpha + 0.5) -- 1763
		) -- 1763
	) -- 1763
	uiInkDraw:drawPolygon( -- 1765
		{ -- 1765
			Vec2(bx + 44 * s, by - 6 * s), -- 1766
			Vec2(bx + 102 * s, by - 14 * s), -- 1767
			Vec2(bx + 110 * s, by + 18 * s), -- 1768
			Vec2(bx + 54 * s, by + 22 * s) -- 1769
		}, -- 1769
		Color(188, 154, 126, a), -- 1770
		1, -- 1770
		Color(128, 98, 76, a) -- 1770
	) -- 1770
	uiInkDraw:drawSegment( -- 1771
		Vec2(bx + 46 * s, by + 16 * s), -- 1771
		Vec2(bx + 76 * s, by + 20 * s), -- 1771
		5.2 * s, -- 1771
		Color(204, 170, 140, a) -- 1771
	) -- 1771
	uiInkDraw:drawSegment( -- 1772
		Vec2(bx + 48 * s, by + 2 * s), -- 1772
		Vec2(bx + 82 * s, by + 4 * s), -- 1772
		4.8 * s, -- 1772
		Color(180, 146, 118, a) -- 1772
	) -- 1772
	uiInkDraw:drawPolygon( -- 1773
		{ -- 1773
			Vec2(bx + 98 * s, by - 14 * s), -- 1774
			Vec2(bx + 224 * s, by - 32 * s), -- 1775
			Vec2(bx + 230 * s, by + 18 * s), -- 1776
			Vec2(bx + 104 * s, by + 20 * s) -- 1777
		}, -- 1777
		Color(54, 48, 44, a), -- 1778
		1.2, -- 1778
		Color(94, 84, 72, a) -- 1778
	) -- 1778
end -- 1682
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiGlow, route, s, ox, oy) -- 1781
	local t = self.seqElapsed -- 1790
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1791
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1792
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1793
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1794
	if route == "child" then -- 1794
		local propA = smoothstep(1.55, 2.05, t) -- 1798
		if propA > 0.02 then -- 1798
			self:drawNeedleCaseOnDesk( -- 1800
				uiInkDraw, -- 1800
				ncX, -- 1800
				ncY, -- 1800
				s, -- 1800
				propA, -- 1800
				true -- 1800
			) -- 1800
		end -- 1800
		local bowlK = smoothstep(4.35, 5.15, t) -- 1803
		if bowlK > 0.02 then -- 1803
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1805
			self:drawWarmPorcelainBowl( -- 1806
				uiInkDraw, -- 1806
				uiGlow, -- 1806
				bx, -- 1806
				bowlY, -- 1806
				s, -- 1806
				bowlK, -- 1806
				false, -- 1806
				0 -- 1806
			) -- 1806
		end -- 1806
	else -- 1806
		local needleK = smoothstep(5.45, 6.15, t) -- 1810
		if needleK > 0.02 then -- 1810
			local ny = lerp(ncY + 46 * s, ncY, needleK) -- 1812
			self:drawNeedleCaseOnDesk( -- 1813
				uiInkDraw, -- 1813
				ncX, -- 1813
				ny, -- 1813
				s, -- 1813
				needleK, -- 1813
				false -- 1813
			) -- 1813
		end -- 1813
		local bowlK = smoothstep(5.8, 6.65, t) -- 1816
		if bowlK > 0.02 then -- 1816
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1818
			local handsK = smoothstep(5.95, 6.75, t) -- 1819
			self:drawWarmPorcelainBowl( -- 1820
				uiInkDraw, -- 1820
				uiGlow, -- 1820
				bowlX, -- 1820
				by, -- 1820
				s, -- 1820
				bowlK, -- 1820
				true, -- 1820
				handsK -- 1820
			) -- 1820
		end -- 1820
		local cuffK = smoothstep(4.25, 4.85, t) -- 1823
		if cuffK > 0.02 then -- 1823
			drawPatchedCuff(uiInkDraw, uiGlow, { -- 1825
				wristX = ox + 122 * s, -- 1826
				wristY = oy + 182 * s, -- 1827
				angleRad = 0.08, -- 1828
				scale = 0.6 * s, -- 1829
				pose = "open", -- 1830
				opacity = 0.92 * cuffK, -- 1831
				stitchHighlight = 0.34, -- 1832
				warmth = 0.72 -- 1833
			}) -- 1833
		end -- 1833
	end -- 1833
end -- 1781
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, draw, cx, cy, s, alpha, withNote) -- 1840
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1848
	draw:drawEllipse( -- 1850
		Vec2(cx + 4 * s, cy - 12 * s), -- 1850
		44 * s, -- 1850
		14 * s, -- 1850
		Color( -- 1850
			10, -- 1850
			10, -- 1850
			14, -- 1850
			math.floor(140 * alpha + 0.5) -- 1850
		) -- 1850
	) -- 1850
	draw:drawPolygon( -- 1852
		{ -- 1852
			Vec2(cx - 32 * s, cy - 12 * s), -- 1853
			Vec2(cx + 26 * s, cy - 15 * s), -- 1854
			Vec2(cx + 30 * s, cy + 16 * s), -- 1855
			Vec2(cx - 28 * s, cy + 18 * s) -- 1856
		}, -- 1856
		Color(148, 124, 92, a), -- 1857
		1.3, -- 1857
		Color(88, 70, 50, a) -- 1857
	) -- 1857
	draw:drawEllipse( -- 1859
		Vec2(cx + 18 * s, cy + 2 * s), -- 1859
		13 * s, -- 1859
		13 * s, -- 1859
		Color(188, 152, 86, a) -- 1859
	) -- 1859
	strokeEllipse( -- 1860
		draw, -- 1860
		cx + 18 * s, -- 1860
		cy + 2 * s, -- 1860
		13 * s, -- 1860
		13 * s, -- 1860
		1.5 * s, -- 1860
		Color(118, 92, 46, a), -- 1860
		18 -- 1860
	) -- 1860
	draw:drawDot( -- 1861
		Vec2(cx + 18 * s, cy + 2 * s), -- 1861
		2.5 * s, -- 1861
		Color(72, 54, 28, a) -- 1861
	) -- 1861
	draw:drawSegment( -- 1862
		Vec2(cx + 12 * s, cy - 2 * s), -- 1862
		Vec2(cx + 24 * s, cy + 6 * s), -- 1862
		1.5 * s, -- 1862
		Color(164, 48, 44, a) -- 1862
	) -- 1862
	draw:drawSegment( -- 1864
		Vec2(cx - 28 * s, cy + 4 * s), -- 1864
		Vec2(cx - 56 * s, cy - 8 * s), -- 1864
		2.4 * s, -- 1864
		toColor(CUFF_PALETTE.childCord, a) -- 1864
	) -- 1864
	draw:drawSegment( -- 1865
		Vec2(cx - 56 * s, cy - 8 * s), -- 1865
		Vec2(cx - 72 * s, cy + 6 * s), -- 1865
		2.2 * s, -- 1865
		toColor(CUFF_PALETTE.childCord, a) -- 1865
	) -- 1865
	draw:drawSegment( -- 1866
		Vec2(cx - 72 * s, cy + 6 * s), -- 1866
		Vec2(cx - 48 * s, cy + 16 * s), -- 1866
		2 * s, -- 1866
		toColor( -- 1866
			CUFF_PALETTE.childCord, -- 1866
			math.floor(215 * alpha + 0.5) -- 1866
		) -- 1866
	) -- 1866
	if withNote then -- 1866
		draw:drawPolygon( -- 1870
			{ -- 1870
				Vec2(cx + 38 * s, cy - 18 * s), -- 1871
				Vec2(cx + 96 * s, cy - 12 * s), -- 1872
				Vec2(cx + 90 * s, cy + 24 * s), -- 1873
				Vec2(cx + 34 * s, cy + 18 * s) -- 1874
			}, -- 1874
			toColor(PALETTE.xuanPaper, a), -- 1875
			1, -- 1875
			toColor( -- 1875
				PALETTE.xuanInkSub, -- 1875
				math.floor(160 * alpha + 0.5) -- 1875
			) -- 1875
		) -- 1875
		draw:drawSegment( -- 1876
			Vec2(cx + 46 * s, cy + 8 * s), -- 1876
			Vec2(cx + 80 * s, cy + 11 * s), -- 1876
			1.2 * s, -- 1876
			toColor( -- 1876
				PALETTE.xuanInk, -- 1876
				math.floor(170 * alpha + 0.5) -- 1876
			) -- 1876
		) -- 1876
		draw:drawSegment( -- 1877
			Vec2(cx + 46 * s, cy - 2 * s), -- 1877
			Vec2(cx + 76 * s, cy + 1 * s), -- 1877
			1.2 * s, -- 1877
			toColor( -- 1877
				PALETTE.xuanInk, -- 1877
				math.floor(160 * alpha + 0.5) -- 1877
			) -- 1877
		) -- 1877
	end -- 1877
end -- 1840
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, draw, glow, cx, cy, s, alpha, heldByTwoHands, handsK) -- 1882
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1892
	draw:drawEllipse( -- 1894
		Vec2(cx, cy - 36 * s), -- 1894
		58 * s, -- 1894
		14 * s, -- 1894
		Color( -- 1894
			8, -- 1894
			9, -- 1894
			14, -- 1894
			math.floor(150 * alpha + 0.5) -- 1894
		) -- 1894
	) -- 1894
	draw:drawPolygon( -- 1896
		{ -- 1896
			Vec2(cx - 32 * s, cy - 38 * s), -- 1897
			Vec2(cx + 32 * s, cy - 38 * s), -- 1898
			Vec2(cx + 62 * s, cy + 8 * s), -- 1899
			Vec2(cx - 62 * s, cy + 8 * s) -- 1900
		}, -- 1900
		Color(168, 166, 156, a), -- 1901
		1.4, -- 1901
		Color(98, 96, 88, a) -- 1901
	) -- 1901
	draw:drawPolygon( -- 1903
		{ -- 1903
			Vec2(cx + 8 * s, cy - 36 * s), -- 1904
			Vec2(cx + 32 * s, cy - 38 * s), -- 1905
			Vec2(cx + 62 * s, cy + 8 * s), -- 1906
			Vec2(cx + 22 * s, cy + 6 * s) -- 1907
		}, -- 1907
		Color( -- 1908
			122, -- 1908
			120, -- 1908
			112, -- 1908
			math.floor(160 * alpha + 0.5) -- 1908
		) -- 1908
	) -- 1908
	draw:drawEllipse( -- 1910
		Vec2(cx, cy + 8 * s), -- 1910
		64 * s, -- 1910
		21 * s, -- 1910
		Color(224, 218, 206, a) -- 1910
	) -- 1910
	strokeEllipse( -- 1911
		draw, -- 1911
		cx, -- 1911
		cy + 8 * s, -- 1911
		64 * s, -- 1911
		21 * s, -- 1911
		1.9 * s, -- 1911
		Color(116, 110, 100, a), -- 1911
		28 -- 1911
	) -- 1911
	draw:drawEllipse( -- 1912
		Vec2(cx, cy + 6 * s), -- 1912
		54 * s, -- 1912
		15 * s, -- 1912
		Color(196, 168, 122, a) -- 1912
	) -- 1912
	strokeEllipse( -- 1913
		draw, -- 1913
		cx, -- 1913
		cy + 6 * s, -- 1913
		54 * s, -- 1913
		15 * s, -- 1913
		1.1 * s, -- 1913
		Color(158, 132, 92, a), -- 1913
		24 -- 1913
	) -- 1913
	draw:drawSegment( -- 1915
		Vec2(cx - 46 * s, cy + 16 * s), -- 1915
		Vec2(cx - 10 * s, cy + 25 * s), -- 1915
		2 * s, -- 1915
		Color( -- 1915
			248, -- 1915
			246, -- 1915
			240, -- 1915
			math.floor(215 * alpha + 0.5) -- 1915
		) -- 1915
	) -- 1915
	local wi = 0 -- 1918
	do -- 1918
		wi = 0 -- 1919
		while wi < 3 do -- 1919
			local phase = self.animTime * 1.1 + wi * 2.05 -- 1920
			local baseX = cx + (wi - 1) * 18 * s -- 1921
			local baseY = cy + 16 * s -- 1922
			local segs = 4 -- 1923
			local prevX = baseX -- 1924
			local prevY = baseY -- 1925
			local si = 1 -- 1926
			do -- 1926
				si = 1 -- 1927
				while si <= segs do -- 1927
					local frac = si / segs -- 1928
					local nx = baseX + math.sin(phase + frac * 3.1) * (6.5 * frac) * s -- 1929
					local ny = baseY + frac * (36 + wi % 2 * 10) * s -- 1930
					local wa = math.floor(46 * (1 - frac * 0.72) * alpha + 0.5) -- 1931
					glow:drawSegment( -- 1932
						Vec2(prevX, prevY), -- 1932
						Vec2(nx, ny), -- 1932
						(2.2 - frac * 0.9) * s, -- 1932
						Color(244, 238, 226, wa) -- 1932
					) -- 1932
					prevX = nx -- 1933
					prevY = ny -- 1934
					si = si + 1 -- 1927
				end -- 1927
			end -- 1927
			wi = wi + 1 -- 1919
		end -- 1919
	end -- 1919
	if heldByTwoHands and handsK > 0.02 then -- 1919
		local ha = math.floor(255 * clamp01(handsK * alpha) + 0.5) -- 1940
		local skin = toColor(CUFF_PALETTE.childSkin, ha) -- 1941
		local skinSh = toColor(CUFF_PALETTE.childSkinShadow, ha) -- 1942
		local sleeve = toColor(CUFF_PALETTE.childSleeve, ha) -- 1943
		local spread = (1 - handsK) * 28 * s -- 1944
		draw:drawPolygon( -- 1947
			{ -- 1947
				Vec2(cx - 122 * s - spread, cy - 58 * s), -- 1948
				Vec2(cx - 72 * s - spread, cy - 30 * s), -- 1949
				Vec2(cx - 82 * s - spread, cy - 4 * s), -- 1950
				Vec2(cx - 134 * s - spread, cy - 26 * s) -- 1951
			}, -- 1951
			sleeve, -- 1952
			1.1, -- 1952
			skinSh -- 1952
		) -- 1952
		draw:drawPolygon( -- 1953
			{ -- 1953
				Vec2(cx - 76 * s - spread, cy - 28 * s), -- 1954
				Vec2(cx - 48 * s - spread, cy - 18 * s), -- 1955
				Vec2(cx - 44 * s - spread, cy + 6 * s), -- 1956
				Vec2(cx - 74 * s - spread, cy + 2 * s) -- 1957
			}, -- 1957
			skin, -- 1958
			1.1, -- 1958
			skinSh -- 1958
		) -- 1958
		draw:drawSegment( -- 1959
			Vec2(cx - 56 * s - spread, cy + 2 * s), -- 1959
			Vec2(cx - 38 * s - spread, cy + 12 * s), -- 1959
			4.6 * s, -- 1959
			skin -- 1959
		) -- 1959
		draw:drawSegment( -- 1960
			Vec2(cx - 58 * s - spread, cy - 7 * s), -- 1960
			Vec2(cx - 40 * s - spread, cy - 2 * s), -- 1960
			4.4 * s, -- 1960
			skin -- 1960
		) -- 1960
		draw:drawSegment( -- 1961
			Vec2(cx - 56 * s - spread, cy - 16 * s), -- 1961
			Vec2(cx - 40 * s - spread, cy - 14 * s), -- 1961
			4.2 * s, -- 1961
			skin -- 1961
		) -- 1961
		draw:drawPolygon( -- 1964
			{ -- 1964
				Vec2(cx + 122 * s + spread, cy - 58 * s), -- 1965
				Vec2(cx + 72 * s + spread, cy - 30 * s), -- 1966
				Vec2(cx + 82 * s + spread, cy - 4 * s), -- 1967
				Vec2(cx + 134 * s + spread, cy - 26 * s) -- 1968
			}, -- 1968
			sleeve, -- 1969
			1.1, -- 1969
			skinSh -- 1969
		) -- 1969
		draw:drawPolygon( -- 1970
			{ -- 1970
				Vec2(cx + 76 * s + spread, cy - 28 * s), -- 1971
				Vec2(cx + 48 * s + spread, cy - 18 * s), -- 1972
				Vec2(cx + 44 * s + spread, cy + 6 * s), -- 1973
				Vec2(cx + 74 * s + spread, cy + 2 * s) -- 1974
			}, -- 1974
			skin, -- 1975
			1.1, -- 1975
			skinSh -- 1975
		) -- 1975
		draw:drawSegment( -- 1976
			Vec2(cx + 56 * s + spread, cy + 2 * s), -- 1976
			Vec2(cx + 38 * s + spread, cy + 12 * s), -- 1976
			4.6 * s, -- 1976
			skin -- 1976
		) -- 1976
		draw:drawSegment( -- 1977
			Vec2(cx + 58 * s + spread, cy - 7 * s), -- 1977
			Vec2(cx + 40 * s + spread, cy - 2 * s), -- 1977
			4.4 * s, -- 1977
			skin -- 1977
		) -- 1977
		draw:drawSegment( -- 1978
			Vec2(cx + 56 * s + spread, cy - 16 * s), -- 1978
			Vec2(cx + 40 * s + spread, cy - 14 * s), -- 1978
			4.2 * s, -- 1978
			skin -- 1978
		) -- 1978
	end -- 1978
end -- 1882
function TowerEndingsPlugin.prototype.drawMingLantern(self, draw, glow, cx, cy, scale, alpha, warmth) -- 1983
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1992
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 1993
	draw:drawSegment( -- 1995
		Vec2(cx - 10 * scale, cy + 28 * scale), -- 1995
		Vec2(cx, cy + 40 * scale), -- 1995
		1.8 * scale, -- 1995
		Color(88, 86, 82, a) -- 1995
	) -- 1995
	draw:drawSegment( -- 1996
		Vec2(cx + 10 * scale, cy + 28 * scale), -- 1996
		Vec2(cx, cy + 40 * scale), -- 1996
		1.8 * scale, -- 1996
		Color(88, 86, 82, a) -- 1996
	) -- 1996
	draw:drawRect( -- 1998
		Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), -- 1998
		Color(62, 46, 34, a), -- 1998
		1, -- 1998
		Color(118, 92, 66, a) -- 1998
	) -- 1998
	draw:drawRect( -- 1999
		Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), -- 1999
		Color(62, 46, 34, a), -- 1999
		1, -- 1999
		Color(118, 92, 66, a) -- 1999
	) -- 1999
	draw:drawRect( -- 2001
		Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale), -- 2002
		Color( -- 2003
			238, -- 2003
			198, -- 2003
			132, -- 2003
			math.floor(230 * alpha * (0.75 + 0.25 * warmth) + 0.5) -- 2003
		), -- 2003
		1.4 * scale, -- 2004
		Color(94, 70, 48, a) -- 2005
	) -- 2005
	draw:drawSegment( -- 2007
		Vec2(cx, cy - 18 * scale), -- 2007
		Vec2(cx, cy + 22 * scale), -- 2007
		1.1 * scale, -- 2007
		Color( -- 2007
			94, -- 2007
			70, -- 2007
			48, -- 2007
			math.floor(150 * alpha + 0.5) -- 2007
		) -- 2007
	) -- 2007
	draw:drawEllipse( -- 2008
		Vec2(cx, cy + 2 * scale), -- 2008
		4.6 * scale * flicker, -- 2008
		8.5 * scale * flicker, -- 2008
		Color(255, 244, 212, a) -- 2008
	) -- 2008
	fillRadialGlow( -- 2010
		glow, -- 2011
		cx, -- 2011
		cy + 2 * scale, -- 2011
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2012
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 2013
		Color( -- 2014
			250, -- 2014
			208, -- 2014
			132, -- 2014
			math.floor(128 * alpha * warmth + 0.5) -- 2014
		), -- 2014
		Color(228, 162, 74, 0), -- 2015
		16 -- 2016
	) -- 2016
end -- 1983
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 2020
	local line = self.lastSubtitle -- 2029
	if line ~= "" then -- 2029
		local cy = barH + 34 * s -- 2031
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 2032
		drawSilkVeil( -- 2033
			uiDraw, -- 2033
			uiArt, -- 2033
			"fe05_sub_veil", -- 2033
			ctx.uiW * 0.5, -- 2033
			cy, -- 2033
			stripW, -- 2033
			48 * s, -- 2033
			PALETTE.inkWash, -- 2033
			0.82, -- 2033
			3 -- 2033
		) -- 2033
		drawHairline( -- 2034
			uiInkDraw, -- 2034
			uiArt, -- 2034
			"fe05_sub_hair", -- 2034
			ctx.uiW * 0.5, -- 2034
			cy + 21 * s, -- 2034
			stripW * 0.68, -- 2034
			PALETTE.silkDim, -- 2034
			0.54, -- 2034
			true, -- 2034
			4 -- 2034
		) -- 2034
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 2035
		ctx.texts:put( -- 2036
			isSpoken and "md" or "sm", -- 2037
			line, -- 2038
			ctx.uiW * 0.5, -- 2039
			cy - 1 * s, -- 2040
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 2041
			0.5, -- 2042
			0.5, -- 2043
			"Center", -- 2044
			isSpoken and 1.8 or 1, -- 2045
			0.98, -- 2046
			0.08 -- 2047
		) -- 2047
	end -- 2047
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 2047
		local hint = route == "child" and "按 E 再次启程   ·   Esc 暂歇" or "团圆尾声   ·   按 E 再次启程   ·   Esc 暂歇" -- 2053
		ctx.texts:put( -- 2056
			"xs", -- 2056
			hint, -- 2056
			ctx.uiW * 0.5, -- 2056
			barH * 0.5, -- 2056
			toColor(PALETTE.textMid), -- 2056
			0.5, -- 2056
			0.5, -- 2056
			"Center", -- 2056
			1.4, -- 2056
			0.88, -- 2056
			0.08 -- 2056
		) -- 2056
	end -- 2056
end -- 2020
function ____exports.createTowerEndingsPlugin() -- 2061
	return __TS__New(____exports.TowerEndingsPlugin) -- 2062
end -- 2061
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 2066
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 2067
	fe:registerPlugin(plugin) -- 2068
	return plugin -- 2069
end -- 2066
return ____exports -- 2066