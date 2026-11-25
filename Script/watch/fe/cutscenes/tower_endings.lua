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
function TowerEndingsPlugin.prototype.onBindPlay(self, p, view) -- 585
	self.sessionId = self.sessionId + 1 -- 586
	self.loopsActive = false -- 587
	self.prevPhase = p.phase -- 588
	if self.rehearsalActive then -- 588
		return -- 591
	end -- 591
	local route = self:resolveRoute(p, view) -- 594
	local isTower = p.room.key == "tower" -- 595
	local alreadyIndoorPhase = isTower and (p.phase == "tower-given" or p.phase == "tower-end") -- 596
	local sameRunIndoorRetry = isTower and self.lastRoomKey == "tower" and self.doorOpened and p.run == self.lastRunRef and route == self.activeRoute and (p.checkpoint > 0 or alreadyIndoorPhase) -- 597
	self.activeRoute = route -- 604
	self.lastRoomKey = p.room.key -- 605
	self.lastRunRef = p.run -- 606
	if not isTower then -- 606
		self:clearSequenceState(false) -- 609
		self.indoorRetryCount = 0 -- 610
		self.doorClosedAfterRetry = false -- 611
		return -- 612
	end -- 612
	if sameRunIndoorRetry or alreadyIndoorPhase then -- 612
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 617
		self.doorClosedAfterRetry = false -- 618
		self:clearSequenceState(true) -- 619
		if p.phase == "tower-end" then -- 619
			self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.divergeEndSec -- 621
			self:syncDerivedMilestones(self.seqElapsed, route) -- 622
		end -- 622
		return -- 624
	end -- 624
	self:clearSequenceState(false) -- 628
	self.indoorRetryCount = 0 -- 629
	self.doorClosedAfterRetry = false -- 630
end -- 585
function TowerEndingsPlugin.prototype.update(self, ctx) -- 633
	self.lastUiW = ctx.uiW -- 634
	self.lastUiH = ctx.uiH -- 635
	local p = ctx.p -- 636
	if not self.rehearsalActive and p.room.key ~= "tower" then -- 636
		if self.loopsActive then -- 636
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 640
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 641
			self.loopsActive = false -- 642
		end -- 642
		self.active = false -- 644
		return -- 645
	end -- 645
	local route = self:resolveRoute(p, ctx.view) -- 648
	self.activeRoute = route -- 649
	if not self.rehearsalActive then -- 649
		self:stepLiveSync(ctx, route) -- 652
	else -- 652
		self:stepRehearsal(ctx, route) -- 654
	end -- 654
	if not self.active then -- 654
		if self.loopsActive then -- 654
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 659
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 660
			self.loopsActive = false -- 661
		end -- 661
		return -- 663
	end -- 663
	if not ctx.paused and ctx.worldDt > 0 then -- 663
		self.animTime = self.animTime + ctx.worldDt -- 668
		self:syncDerivedMilestones(self.seqElapsed, route) -- 669
		self:syncAudioCues(ctx.audio, ctx, route) -- 670
		self:stepInputGuard(ctx.input) -- 671
	elseif not ctx.paused then -- 671
		self:syncDerivedMilestones(self.seqElapsed, route) -- 674
		self:stepInputGuard(ctx.input) -- 675
	end -- 675
	self.lastSubtitle = self:composeSubtitle(route) -- 678
end -- 633
function TowerEndingsPlugin.prototype.stepLiveSync(self, ctx, route) -- 681
	local p = ctx.p -- 682
	local phase = p.phase -- 683
	local justEnteredKnock = self.prevPhase ~= "tower-knock" and phase == "tower-knock" -- 684
	local justEnteredGiven = self.prevPhase ~= "tower-given" and phase == "tower-given" -- 685
	local justEnteredEnd = self.prevPhase ~= "tower-end" and phase == "tower-end" -- 686
	self.prevPhase = phase -- 687
	if phase == "tower-wait" then -- 687
		self.active = false -- 691
		return -- 692
	end -- 692
	if not self.active then -- 692
		self.active = true -- 696
		self.staleInputMustRelease = ctx.input.interact.held or ctx.input.retry.held or ctx.input.interact.pressed -- 697
		self.confirmReady = false -- 698
	end -- 698
	if justEnteredKnock then -- 698
		self.seqElapsed = p.phaseTick / 60 -- 702
		self.holdElapsed = 0 -- 703
		self.staleInputMustRelease = true -- 704
		self.confirmReady = false -- 705
	elseif justEnteredGiven then -- 705
		self.doorOpened = true -- 707
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.doorOpenSec) -- 708
	elseif justEnteredEnd then -- 708
		self.doorOpened = true -- 710
		self.seqElapsed = math.max(self.seqElapsed, 3.6) -- 712
	end -- 712
	if not ctx.paused and #ctx.events.rawEvents > 0 then -- 712
		local i = 0 -- 717
		do -- 717
			i = 0 -- 718
			while i < #ctx.events.rawEvents do -- 718
				local ev = ctx.events.rawEvents[i + 1] -- 719
				if ev.name == "knock" then -- 719
					local cnt = type(ev.data.count) == "number" and ev.data.count or self.knockCount + 1 -- 721
					if cnt >= 1 and self.knockCount < 1 then -- 721
						self.knockCount = 1 -- 723
						self:playTowerOnce( -- 724
							ctx.audio, -- 724
							"knock1", -- 724
							"sfx", -- 724
							____exports.TOWER_AUDIO_FILES.knock1, -- 724
							0.88, -- 724
							"tower:knock:1", -- 724
							ev.tick, -- 724
							ev.seq -- 724
						) -- 724
					end -- 724
					if cnt >= 2 and self.knockCount < 2 then -- 724
						self.knockCount = 2 -- 727
						self:playTowerOnce( -- 728
							ctx.audio, -- 728
							"knock2", -- 728
							"sfx", -- 728
							____exports.TOWER_AUDIO_FILES.knock2, -- 728
							0.9, -- 728
							"tower:knock:2", -- 728
							ev.tick, -- 728
							ev.seq -- 728
						) -- 728
					end -- 728
				end -- 728
				i = i + 1 -- 718
			end -- 718
		end -- 718
	end -- 718
	if not ctx.paused and ctx.worldDt > 0 then -- 718
		if phase == "tower-knock" then -- 718
			local backendSec = math.min(____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60) -- 737
			self.seqElapsed = math.max(self.seqElapsed + ctx.worldDt, backendSec) -- 738
			if self.seqElapsed > ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 then -- 738
				self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 -- 740
			end -- 740
		else -- 740
			self.seqElapsed = self.seqElapsed + ctx.worldDt -- 743
			if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 743
				self.holdElapsed = self.holdElapsed + ctx.worldDt -- 745
			end -- 745
		end -- 745
	end -- 745
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 745
		self.doorClosedAfterRetry = true -- 751
	end -- 751
	self:syncDerivedMilestones(self.seqElapsed, route) -- 753
end -- 681
function TowerEndingsPlugin.prototype.stepRehearsal(self, ctx, route) -- 756
	self.active = true -- 757
	if not ctx.paused and ctx.worldDt > 0 then -- 757
		self.seqElapsed = self.seqElapsed + ctx.worldDt -- 759
		if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 759
			self.holdElapsed = self.holdElapsed + ctx.worldDt -- 761
		end -- 761
	end -- 761
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 761
		self.doorClosedAfterRetry = true -- 765
	end -- 765
	self:syncDerivedMilestones(self.seqElapsed, route) -- 767
end -- 756
function TowerEndingsPlugin.prototype.syncDerivedMilestones(self, t, route) -- 770
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec and self.knockCount < 1 then -- 770
		self.knockCount = 1 -- 772
	end -- 772
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec and self.knockCount < 2 then -- 772
		self.knockCount = 2 -- 775
	end -- 775
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec and self.replyKnockCount < 1 then -- 775
		self.replyKnockCount = 1 -- 778
	end -- 778
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec and self.replyKnockCount < 2 then -- 778
		self.replyKnockCount = 2 -- 781
	end -- 781
	if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 781
		self.doorOpened = true -- 784
	end -- 784
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec and not self.row1Written then -- 784
		self.row1Written = true -- 788
		self.registryAppendCount = self.registryAppendCount + 1 -- 789
	end -- 789
	if route == "soldier" and t >= 4.6 and not self.row2Written then -- 789
		self.row2Written = true -- 792
		self.registryAppendCount = self.registryAppendCount + 1 -- 793
	end -- 793
	if route == "child" and self.row2Written then -- 793
		self.row2Written = false -- 797
		self.registryAppendCount = self.row1Written and 1 or 0 -- 798
	end -- 798
end -- 770
function TowerEndingsPlugin.prototype.stepInputGuard(self, input) -- 802
	local keyHeld = input.interact.held or input.retry.held -- 803
	local keyPressed = input.interact.pressed or input.retry.pressed -- 804
	local readyTime = self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 805
	if self.staleInputMustRelease then -- 805
		if not keyHeld then -- 805
			self.staleInputMustRelease = false -- 809
		elseif keyPressed then -- 809
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 811
		end -- 811
		self.confirmReady = false -- 813
		return -- 814
	end -- 814
	if not readyTime then -- 814
		if keyPressed then -- 814
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 819
			self.staleInputMustRelease = keyHeld -- 820
		end -- 820
		self.confirmReady = false -- 822
		return -- 823
	end -- 823
	self.confirmReady = true -- 826
	if self.rehearsalActive and keyPressed then -- 826
		self.rehearsalAcknowledged = true -- 828
	end -- 828
end -- 802
function TowerEndingsPlugin.prototype.playTowerOnce(self, audio, tag, track, path, volume, cueId, tick, seq) -- 832
	if seq == nil then -- 832
		seq = -1 -- 840
	end -- 840
	local dedupeKey = (("tower:s" .. tostring(self.sessionId)) .. ":") .. tag -- 842
	audio:playOnce( -- 843
		dedupeKey, -- 843
		track, -- 843
		path, -- 843
		volume, -- 843
		cueId, -- 843
		tick, -- 843
		seq -- 843
	) -- 843
end -- 832
function TowerEndingsPlugin.prototype.syncAudioCues(self, audio, ctx, route) -- 846
	local t = self.seqElapsed -- 847
	local tick = ctx.p.ticks -- 848
	local indoorK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.5, t) -- 849
	self.loopsActive = true -- 852
	audio:playLoop( -- 853
		"tower_wind_cold", -- 853
		"wind", -- 853
		____exports.TOWER_AUDIO_FILES.windCold, -- 853
		lerp(0.36, 0.14, indoorK), -- 853
		tick -- 853
	) -- 853
	if indoorK > 0.05 then -- 853
		audio:playLoop( -- 855
			"tower_room_warm", -- 855
			"ambience", -- 855
			____exports.TOWER_AUDIO_FILES.roomWarm, -- 855
			lerp(0.06, 0.34, indoorK), -- 855
			tick -- 855
		) -- 855
	end -- 855
	if self.indoorRetryCount == 0 then -- 855
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec then -- 855
			self:playTowerOnce( -- 861
				audio, -- 861
				"knock1", -- 861
				"sfx", -- 861
				____exports.TOWER_AUDIO_FILES.knock1, -- 861
				0.88, -- 861
				"tower:knock:1", -- 861
				tick -- 861
			) -- 861
		end -- 861
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec then -- 861
			self:playTowerOnce( -- 864
				audio, -- 864
				"knock2", -- 864
				"sfx", -- 864
				____exports.TOWER_AUDIO_FILES.knock2, -- 864
				0.9, -- 864
				"tower:knock:2", -- 864
				tick -- 864
			) -- 864
		end -- 864
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 864
			self:playTowerOnce( -- 867
				audio, -- 867
				"reply1", -- 867
				"sfx", -- 867
				____exports.TOWER_AUDIO_FILES.reply1, -- 867
				0.78, -- 867
				"tower:reply:1", -- 867
				tick -- 867
			) -- 867
		end -- 867
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec then -- 867
			self:playTowerOnce( -- 870
				audio, -- 870
				"reply2", -- 870
				"sfx", -- 870
				____exports.TOWER_AUDIO_FILES.reply2, -- 870
				0.8, -- 870
				"tower:reply:2", -- 870
				tick -- 870
			) -- 870
		end -- 870
		if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 870
			self:playTowerOnce( -- 873
				audio, -- 873
				"door_open", -- 873
				"sfx", -- 873
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 873
				0.84, -- 873
				"tower:door_open", -- 873
				tick -- 873
			) -- 873
		end -- 873
	end -- 873
	if t >= 1.5 then -- 873
		self:playTowerOnce( -- 878
			audio, -- 878
			"book_open", -- 878
			"sfx", -- 878
			____exports.TOWER_AUDIO_FILES.bookOpen, -- 878
			0.82, -- 878
			"tower:book_open", -- 878
			tick -- 878
		) -- 878
	end -- 878
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 878
		self:playTowerOnce( -- 881
			audio, -- 881
			"brush1", -- 881
			"sfx", -- 881
			____exports.TOWER_AUDIO_FILES.brush1, -- 881
			0.8, -- 881
			"tower:brush:row1", -- 881
			tick -- 881
		) -- 881
	end -- 881
	if route == "child" then -- 881
		if t >= 4.35 then -- 881
			self:playTowerOnce( -- 886
				audio, -- 886
				"f03_line", -- 886
				"voice", -- 886
				____exports.TOWER_AUDIO_FILES.lineXiaomanLamp, -- 886
				0.86, -- 886
				"tower:f03:line_lamp", -- 886
				tick -- 886
			) -- 886
		end -- 886
		if t >= 4.45 then -- 886
			self:playTowerOnce( -- 889
				audio, -- 889
				"f03_bowl", -- 889
				"sfx", -- 889
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 889
				0.8, -- 889
				"tower:bowl_set", -- 889
				tick -- 889
			) -- 889
		end -- 889
		if t >= 5.2 then -- 889
			self:playTowerOnce( -- 892
				audio, -- 892
				"f03_lamp", -- 892
				"sfx", -- 892
				____exports.TOWER_AUDIO_FILES.lampMove, -- 892
				0.82, -- 892
				"tower:f03:lamp_move", -- 892
				tick -- 892
			) -- 892
		end -- 892
	else -- 892
		if t >= 4.28 then -- 892
			self:playTowerOnce( -- 896
				audio, -- 896
				"m03_line", -- 896
				"voice", -- 896
				____exports.TOWER_AUDIO_FILES.lineZhoushuName, -- 896
				0.9, -- 896
				"tower:m03:line_name", -- 896
				tick -- 896
			) -- 896
		end -- 896
		if t >= 4.62 then -- 896
			self:playTowerOnce( -- 899
				audio, -- 899
				"brush2", -- 899
				"sfx", -- 899
				____exports.TOWER_AUDIO_FILES.brush2, -- 899
				0.82, -- 899
				"tower:brush:row2", -- 899
				tick -- 899
			) -- 899
		end -- 899
		if t >= 5.55 then -- 899
			self:playTowerOnce( -- 902
				audio, -- 902
				"m03_needle", -- 902
				"sfx", -- 902
				____exports.TOWER_AUDIO_FILES.needlePlace, -- 902
				0.8, -- 902
				"tower:m03:needle_place", -- 902
				tick -- 902
			) -- 902
		end -- 902
		if t >= 6.02 then -- 902
			self:playTowerOnce( -- 905
				audio, -- 905
				"m03_bowl", -- 905
				"sfx", -- 905
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 905
				0.82, -- 905
				"tower:bowl_set", -- 905
				tick -- 905
			) -- 905
		end -- 905
	end -- 905
end -- 846
function TowerEndingsPlugin.prototype.composeSubtitle(self, route) -- 910
	local t = self.seqElapsed -- 911
	if t < ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 911
		return "[两下轻敲]  门外厚木上传来两声轻敲。" -- 913
	end -- 913
	if t < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 913
		return "[门内回敲]  静默一息，门后轻轻回敲两声。" -- 916
	end -- 916
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 916
		return route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 919
	end -- 919
	if t < ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 919
		return route == "child" and "她把针套与纸条摊在案前，守卒展开收籍末页。" or "两人站在值夜室内，守卒摊开收籍末页。" -- 924
	end -- 924
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 924
		return "守卒蘸墨提笔，在第一行写下「小满」。" -- 929
	end -- 929
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 929
		return "笔尖停在第二行上方。" -- 932
	end -- 932
	if route == "child" then -- 932
		if t < 6.7 then -- 932
			return F03_DIALOGUE -- 936
		end -- 936
		return "" -- 938
	end -- 938
	if t < 5.45 then -- 938
		return M03_DIALOGUE -- 941
	end -- 941
	if t < 6.85 then -- 941
		return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。" -- 944
	end -- 944
	return "" -- 946
end -- 910
function TowerEndingsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 951
	if not self.active then -- 951
		return false -- 959
	end -- 959
	local route = self.activeRoute -- 962
	local t = self.seqElapsed -- 963
	local lampProg = route == "child" and smoothstep(5.2, 6.75, t) or 0 -- 964
	local scaled = computeScaledAnchors(ctx.uiW, ctx.uiH, lampProg) -- 965
	local s = scaled.s -- 966
	local ox = scaled.ox -- 967
	local oy = scaled.oy -- 968
	uiDraw:drawRect( -- 971
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 971
		Color(8, 10, 16, 255) -- 971
	) -- 971
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 971
		self:drawAct1PorchAndDoor( -- 975
			uiDraw, -- 975
			uiInkDraw, -- 975
			uiArt, -- 975
			uiGlow, -- 975
			ctx, -- 975
			route, -- 975
			s, -- 975
			ox, -- 975
			oy -- 975
		) -- 975
		local fadeOut = smoothstep(1.22, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec, t) -- 977
		if fadeOut > 0.01 then -- 977
			uiInkDraw:drawRect( -- 979
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 979
				Color( -- 979
					8, -- 979
					10, -- 979
					16, -- 979
					math.floor(230 * fadeOut + 0.5) -- 979
				) -- 979
			) -- 979
		end -- 979
	else -- 979
		self:drawAct2And3Guardroom( -- 983
			uiDraw, -- 983
			uiInkDraw, -- 983
			uiArt, -- 983
			uiGlow, -- 983
			ctx, -- 983
			route, -- 983
			lampProg, -- 983
			s, -- 983
			ox, -- 983
			oy -- 983
		) -- 983
		local fadeIn = 1 - smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.24, t) -- 984
		if fadeIn > 0.01 then -- 984
			uiInkDraw:drawRect( -- 986
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 986
				Color( -- 986
					8, -- 986
					10, -- 986
					16, -- 986
					math.floor(220 * fadeIn + 0.5) -- 986
				) -- 986
			) -- 986
		end -- 986
	end -- 986
	local barH = math.floor(____exports.TOWER_SHOT_LAYOUT.letterboxH * s + 0.5) -- 991
	uiInkDraw:drawRect( -- 992
		Rect(0, ctx.uiH - barH, ctx.uiW, barH), -- 992
		Color(7, 9, 14, 248) -- 992
	) -- 992
	uiInkDraw:drawRect( -- 993
		Rect(0, 0, ctx.uiW, barH), -- 993
		Color(7, 9, 14, 248) -- 993
	) -- 993
	uiInkDraw:drawSegment( -- 994
		Vec2(0, ctx.uiH - barH), -- 994
		Vec2(ctx.uiW, ctx.uiH - barH), -- 994
		0.9, -- 994
		toColor(PALETTE.silkDim, 82) -- 994
	) -- 994
	uiInkDraw:drawSegment( -- 995
		Vec2(0, barH), -- 995
		Vec2(ctx.uiW, barH), -- 995
		0.9, -- 995
		toColor(PALETTE.silkDim, 82) -- 995
	) -- 995
	self:drawDialogueSubtitle( -- 998
		uiDraw, -- 998
		uiInkDraw, -- 998
		uiArt, -- 998
		ctx, -- 998
		route, -- 998
		s, -- 998
		barH -- 998
	) -- 998
	return true -- 1000
end -- 951
function TowerEndingsPlugin.prototype.drawAct1PorchAndDoor(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1005
	local t = self.seqElapsed -- 1016
	local isLowpoly = route == "child" -- 1017
	local openK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, 1.24, t) -- 1018
	local doorCx = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s -- 1019
	local threshY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s -- 1020
	local doorW = ____exports.TOWER_SHOT_LAYOUT.doorW * s -- 1021
	local doorH = ____exports.TOWER_SHOT_LAYOUT.doorH * s -- 1022
	local doorL = doorCx - doorW * 0.5 -- 1023
	local doorR = doorCx + doorW * 0.5 -- 1024
	local k1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock1Sec) / 0.055) ^ 2) -- 1027
	local k2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock2Sec) / 0.055) ^ 2) -- 1028
	local r1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply1Sec) / 0.06) ^ 2) -- 1029
	local r2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply2Sec) / 0.06) ^ 2) -- 1030
	local doorShakeX = (k1Pulse + k2Pulse) * 2.4 * s * math.sin(t * 95) + (r1Pulse + r2Pulse) * 1.4 * s * math.sin(t * 80) -- 1031
	if isLowpoly then -- 1031
		local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, openK * 0.62) -- 1036
		fillVGradRect( -- 1037
			uiDraw, -- 1038
			0, -- 1038
			0, -- 1038
			ctx.uiW, -- 1038
			ctx.uiH, -- 1038
			Color(12, 16, 26, 255), -- 1039
			Color(20, 28, 44, 255) -- 1040
		) -- 1040
		local wallCol = shadeSurface( -- 1043
			MING_MATERIALS.mingBrickDark.base, -- 1043
			vec3(0, 0, -1), -- 1043
			24, -- 1043
			1, -- 1043
			light, -- 1043
			MING_MATERIALS.mingBrickDark -- 1043
		) -- 1043
		local jambCol = shadeSurface( -- 1044
			MING_MATERIALS.mingBrick.base, -- 1044
			vec3(0.75, 0.15, -0.64), -- 1044
			10, -- 1044
			1, -- 1044
			light, -- 1044
			MING_MATERIALS.mingBrick -- 1044
		) -- 1044
		local jambRCol = shadeSurface( -- 1045
			MING_MATERIALS.mingBrick.base, -- 1045
			vec3(-0.75, 0.15, -0.64), -- 1045
			10, -- 1045
			1, -- 1045
			light, -- 1045
			MING_MATERIALS.mingBrick -- 1045
		) -- 1045
		local lintelCol = shadeSurface( -- 1046
			MING_MATERIALS.mingStoneStep.base, -- 1046
			vec3(0, -0.55, -0.83), -- 1046
			6, -- 1046
			1, -- 1046
			light, -- 1046
			MING_MATERIALS.mingStoneStep -- 1046
		) -- 1046
		local stepCol = shadeSurface( -- 1047
			MING_MATERIALS.mingStoneStep.base, -- 1047
			vec3(0, 0.92, -0.39), -- 1047
			0, -- 1047
			1, -- 1047
			light, -- 1047
			MING_MATERIALS.mingStoneStep -- 1047
		) -- 1047
		uiDraw:drawRect( -- 1049
			Rect(0, threshY, doorL - 26 * s, ctx.uiH - threshY), -- 1049
			toColor(wallCol) -- 1049
		) -- 1049
		uiDraw:drawRect( -- 1050
			Rect(doorR + 26 * s, threshY, ctx.uiW - (doorR + 26 * s), ctx.uiH - threshY), -- 1050
			toColor(wallCol) -- 1050
		) -- 1050
		uiDraw:drawPolygon( -- 1052
			{ -- 1052
				Vec2(doorL - 26 * s, threshY), -- 1053
				Vec2(doorL, threshY + 12 * s), -- 1054
				Vec2(doorL, threshY + doorH - 8 * s), -- 1055
				Vec2(doorL - 26 * s, threshY + doorH + 18 * s) -- 1056
			}, -- 1056
			toColor(jambCol), -- 1057
			1, -- 1057
			toColor(PALETTE.silkDim, 68) -- 1057
		) -- 1057
		uiDraw:drawPolygon( -- 1058
			{ -- 1058
				Vec2(doorR + 26 * s, threshY), -- 1059
				Vec2(doorR, threshY + 12 * s), -- 1060
				Vec2(doorR, threshY + doorH - 8 * s), -- 1061
				Vec2(doorR + 26 * s, threshY + doorH + 18 * s) -- 1062
			}, -- 1062
			toColor(jambRCol), -- 1063
			1, -- 1063
			toColor(PALETTE.silkDim, 68) -- 1063
		) -- 1063
		uiDraw:drawPolygon( -- 1065
			{ -- 1065
				Vec2(doorL - 44 * s, threshY + doorH + 18 * s), -- 1066
				Vec2(doorR + 44 * s, threshY + doorH + 18 * s), -- 1067
				Vec2(doorR + 58 * s, threshY + doorH + 92 * s), -- 1068
				Vec2(doorL - 58 * s, threshY + doorH + 92 * s) -- 1069
			}, -- 1069
			toColor(lintelCol), -- 1070
			1.1, -- 1070
			toColor(STONE_EDGE_FALLBACK, 130) -- 1070
		) -- 1070
		uiDraw:drawRect( -- 1072
			Rect(0, 0, ctx.uiW, threshY), -- 1072
			Color(16, 20, 30, 255) -- 1072
		) -- 1072
		uiDraw:drawPolygon( -- 1073
			{ -- 1073
				Vec2(doorL - 58 * s, threshY - 20 * s), -- 1074
				Vec2(doorR + 58 * s, threshY - 20 * s), -- 1075
				Vec2(doorR + 28 * s, threshY + 12 * s), -- 1076
				Vec2(doorL - 28 * s, threshY + 12 * s) -- 1077
			}, -- 1077
			toColor(stepCol), -- 1078
			1, -- 1078
			toColor(STONE_EDGE_FALLBACK, 150) -- 1078
		) -- 1078
		uiDraw:drawPolygon( -- 1080
			{ -- 1080
				Vec2(0, 0), -- 1081
				Vec2(142 * s, 0), -- 1082
				Vec2(114 * s, ctx.uiH), -- 1083
				Vec2(0, ctx.uiH) -- 1084
			}, -- 1084
			Color(10, 14, 22, 220) -- 1085
		) -- 1085
		uiDraw:drawPolygon( -- 1086
			{ -- 1086
				Vec2(ctx.uiW - 142 * s, 0), -- 1087
				Vec2(ctx.uiW, 0), -- 1088
				Vec2(ctx.uiW, ctx.uiH), -- 1089
				Vec2(ctx.uiW - 114 * s, ctx.uiH) -- 1090
			}, -- 1090
			Color(10, 14, 22, 220) -- 1091
		) -- 1091
	else -- 1091
		fillVGradRect( -- 1094
			uiDraw, -- 1095
			0, -- 1095
			0, -- 1095
			ctx.uiW, -- 1095
			ctx.uiH, -- 1095
			Color(18, 22, 32, 255), -- 1096
			Color(32, 38, 52, 255) -- 1097
		) -- 1097
		uiDraw:drawPolygon( -- 1100
			{ -- 1100
				Vec2(0, threshY), -- 1101
				Vec2(doorL, threshY), -- 1102
				Vec2(doorL, threshY + 188 * s), -- 1103
				Vec2(doorL * 0.55, threshY + 230 * s), -- 1104
				Vec2(doorL * 0.22, threshY + 172 * s), -- 1105
				Vec2(0, threshY + 196 * s) -- 1106
			}, -- 1106
			Color(26, 30, 40, 235) -- 1107
		) -- 1107
		uiDraw:drawPolygon( -- 1108
			{ -- 1108
				Vec2(doorR, threshY), -- 1109
				Vec2(ctx.uiW, threshY), -- 1110
				Vec2(ctx.uiW, threshY + 218 * s), -- 1111
				Vec2(doorR + (ctx.uiW - doorR) * 0.56, threshY + 248 * s), -- 1112
				Vec2(doorR, threshY + 178 * s) -- 1113
			}, -- 1113
			Color(26, 30, 40, 235) -- 1114
		) -- 1114
		uiDraw:drawRect( -- 1116
			Rect(0, threshY, doorL, ctx.uiH - threshY), -- 1116
			Color(54, 56, 62, 255), -- 1116
			1, -- 1116
			Color(88, 90, 96, 155) -- 1116
		) -- 1116
		uiDraw:drawRect( -- 1117
			Rect(doorR, threshY, ctx.uiW - doorR, ctx.uiH - threshY), -- 1117
			Color(54, 56, 62, 255), -- 1117
			1, -- 1117
			Color(88, 90, 96, 155) -- 1117
		) -- 1117
		uiDraw:drawRect( -- 1118
			Rect(doorL - 28 * s, threshY + doorH, doorW + 56 * s, 68 * s), -- 1118
			Color(72, 68, 62, 255), -- 1118
			1, -- 1118
			Color(124, 114, 100, 175) -- 1118
		) -- 1118
		local row = 0 -- 1119
		do -- 1119
			row = 0 -- 1120
			while row < 10 do -- 1120
				local by = threshY + row * 46 * s -- 1121
				uiDraw:drawSegment( -- 1122
					Vec2(0, by), -- 1122
					Vec2(doorL, by), -- 1122
					1, -- 1122
					Color(34, 36, 42, 175) -- 1122
				) -- 1122
				uiDraw:drawSegment( -- 1123
					Vec2(doorR, by), -- 1123
					Vec2(ctx.uiW, by), -- 1123
					1, -- 1123
					Color(34, 36, 42, 175) -- 1123
				) -- 1123
				local stag = row % 2 * 34 * s -- 1124
				local col = 0 -- 1125
				do -- 1125
					col = 0 -- 1126
					while col < 7 do -- 1126
						local lx = stag + col * 68 * s -- 1127
						if lx > 4 * s and lx < doorL - 4 * s then -- 1127
							uiDraw:drawSegment( -- 1129
								Vec2(lx, by), -- 1129
								Vec2(lx, by + 46 * s), -- 1129
								0.9, -- 1129
								Color(36, 38, 44, 130) -- 1129
							) -- 1129
						end -- 1129
						local rx = doorR + stag + col * 68 * s -- 1131
						if rx > doorR + 4 * s and rx < ctx.uiW - 4 * s then -- 1131
							uiDraw:drawSegment( -- 1133
								Vec2(rx, by), -- 1133
								Vec2(rx, by + 46 * s), -- 1133
								0.9, -- 1133
								Color(36, 38, 44, 130) -- 1133
							) -- 1133
						end -- 1133
						col = col + 1 -- 1126
					end -- 1126
				end -- 1126
				row = row + 1 -- 1120
			end -- 1120
		end -- 1120
		uiDraw:drawRect( -- 1138
			Rect(0, 0, ctx.uiW, threshY), -- 1138
			Color(28, 26, 28, 255) -- 1138
		) -- 1138
		uiDraw:drawRect( -- 1139
			Rect(doorL - 36 * s, threshY - 12 * s, doorW + 72 * s, 22 * s), -- 1139
			Color(96, 94, 92, 255), -- 1139
			1, -- 1139
			Color(156, 152, 144, 175) -- 1139
		) -- 1139
	end -- 1139
	local innerWarm = 0.22 + openK * 0.78 + (r1Pulse + r2Pulse) * 0.14 -- 1143
	fillVGradRect( -- 1144
		uiDraw, -- 1145
		doorL, -- 1145
		threshY + 8 * s, -- 1145
		doorW, -- 1145
		doorH - 8 * s, -- 1145
		Color( -- 1146
			46, -- 1146
			32, -- 1146
			20, -- 1146
			math.floor(255 * math.min(1, innerWarm + 0.15) + 0.5) -- 1146
		), -- 1146
		Color( -- 1147
			118, -- 1147
			82, -- 1147
			42, -- 1147
			math.floor(255 * math.min(1, innerWarm) + 0.5) -- 1147
		) -- 1147
	) -- 1147
	local leafW = math.max(26 * s, doorW * (1 - openK * 0.76)) -- 1151
	local leafX = doorL + doorShakeX * (1 - openK) -- 1152
	local woodCol = isLowpoly and toColor(shadeSurface( -- 1153
		MING_MATERIALS.mingTimberDark.base, -- 1154
		vec3(-0.2, 0.25, -0.95), -- 1154
		4, -- 1154
		1, -- 1154
		TOWER_WEST_LAMP_LIGHT, -- 1154
		MING_MATERIALS.mingTimberDark -- 1154
	)) or Color(76, 54, 38, 255) -- 1154
	uiDraw:drawRect( -- 1156
		Rect(leafX, threshY + 12 * s, leafW, doorH - 14 * s), -- 1157
		woodCol, -- 1158
		1.4, -- 1159
		Color(138, 106, 74, 185) -- 1160
	) -- 1160
	local planks = 4 -- 1163
	local pi = 1 -- 1164
	do -- 1164
		pi = 1 -- 1165
		while pi < planks do -- 1165
			local px = leafX + leafW * pi / planks -- 1166
			uiDraw:drawSegment( -- 1167
				Vec2(px, threshY + 14 * s), -- 1167
				Vec2(px, threshY + doorH - 4 * s), -- 1167
				1.1, -- 1167
				Color(38, 26, 18, 185) -- 1167
			) -- 1167
			pi = pi + 1 -- 1165
		end -- 1165
	end -- 1165
	uiDraw:drawRect( -- 1169
		Rect(leafX + 4 * s, threshY + doorH * 0.24, leafW - 8 * s, 10 * s), -- 1169
		Color(54, 38, 26, 225) -- 1169
	) -- 1169
	uiDraw:drawRect( -- 1170
		Rect(leafX + 4 * s, threshY + doorH * 0.74, leafW - 8 * s, 10 * s), -- 1170
		Color(54, 38, 26, 225) -- 1170
	) -- 1170
	local ringX = leafX + leafW * 0.72 -- 1172
	local ringY = threshY + doorH * 0.56 -- 1173
	uiDraw:drawRect( -- 1174
		Rect(ringX - 6 * s, ringY + 4 * s, 12 * s, 12 * s), -- 1174
		Color(42, 46, 52, 235), -- 1174
		1, -- 1174
		Color(96, 100, 108, 170) -- 1174
	) -- 1174
	strokeEllipse( -- 1175
		uiDraw, -- 1175
		ringX, -- 1175
		ringY - 2 * s, -- 1175
		8 * s, -- 1175
		9 * s, -- 1175
		1.8 * s, -- 1175
		Color(108, 112, 118, 195), -- 1175
		16 -- 1175
	) -- 1175
	local seamGlowA = math.floor(92 + openK * 145 + (r1Pulse + r2Pulse) * 48 + 0.5) -- 1178
	fillRadialGlow( -- 1179
		uiGlow, -- 1180
		doorCx + openK * 24 * s, -- 1180
		threshY + 14 * s, -- 1180
		(92 + openK * 120) * s, -- 1181
		(26 + openK * 58) * s, -- 1181
		Color( -- 1182
			246, -- 1182
			204, -- 1182
			134, -- 1182
			math.min(220, seamGlowA) -- 1182
		), -- 1182
		Color(220, 156, 72, 0), -- 1183
		18 -- 1184
	) -- 1184
	local kx = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s -- 1188
	local ky = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s -- 1189
	if k1Pulse > 0.08 or k2Pulse > 0.08 then -- 1189
		local amp = math.max(k1Pulse, k2Pulse) -- 1191
		local r = (18 + (1 - amp) * 34) * s -- 1192
		strokeEllipse( -- 1193
			uiInkDraw, -- 1193
			kx + 24 * s, -- 1193
			ky, -- 1193
			r, -- 1193
			r * 0.85, -- 1193
			1.8 * s, -- 1193
			toColor( -- 1193
				PALETTE.amberCore, -- 1193
				math.floor(210 * amp + 0.5) -- 1193
			), -- 1193
			24 -- 1193
		) -- 1193
	end -- 1193
	if r1Pulse > 0.08 or r2Pulse > 0.08 then -- 1193
		local amp = math.max(r1Pulse, r2Pulse) -- 1196
		local r = (24 + (1 - amp) * 42) * s -- 1197
		strokeEllipse( -- 1198
			uiInkDraw, -- 1198
			doorCx + 30 * s, -- 1198
			ky + 16 * s, -- 1198
			r, -- 1198
			r * 0.9, -- 1198
			1.6 * s, -- 1198
			toColor( -- 1198
				PALETTE.amber, -- 1198
				math.floor(185 * amp + 0.5) -- 1198
			), -- 1198
			24 -- 1198
		) -- 1198
	end -- 1198
	if openK > 0.05 then -- 1198
		local lanX = ox + ____exports.TOWER_SHOT_LAYOUT.doorLanternX * s + (1 - openK) * 42 * s -- 1203
		local lanY = oy + ____exports.TOWER_SHOT_LAYOUT.doorLanternY * s -- 1204
		uiInkDraw:drawPolygon( -- 1206
			{ -- 1206
				Vec2(lanX + 76 * s, lanY + 42 * s), -- 1207
				Vec2(lanX + 12 * s, lanY + 34 * s), -- 1208
				Vec2(lanX + 8 * s, lanY + 12 * s), -- 1209
				Vec2(lanX + 78 * s, lanY + 12 * s) -- 1210
			}, -- 1210
			Color( -- 1211
				54, -- 1211
				48, -- 1211
				44, -- 1211
				math.floor(240 * openK + 0.5) -- 1211
			), -- 1211
			1, -- 1211
			Color( -- 1211
				98, -- 1211
				86, -- 1211
				74, -- 1211
				math.floor(180 * openK + 0.5) -- 1211
			) -- 1211
		) -- 1211
		self:drawMingLantern( -- 1212
			uiInkDraw, -- 1212
			uiGlow, -- 1212
			lanX, -- 1212
			lanY - 14 * s, -- 1212
			1.08 * s, -- 1212
			openK, -- 1212
			1 -- 1212
		) -- 1212
		fillRadialGlow( -- 1214
			uiGlow, -- 1215
			kx + 12 * s, -- 1215
			ky - 14 * s, -- 1215
			148 * s, -- 1216
			128 * s, -- 1216
			Color( -- 1217
				246, -- 1217
				208, -- 1217
				142, -- 1217
				math.floor(98 * openK + 0.5) -- 1217
			), -- 1217
			Color(232, 174, 92, 0), -- 1218
			18 -- 1219
		) -- 1219
	end -- 1219
	local stepInX = openK * 44 * s -- 1224
	local xiaomanX = doorCx - 66 * s + stepInX -- 1225
	local xiaomanY = threshY - 2 * s -- 1226
	uiDraw:drawEllipse( -- 1228
		Vec2(xiaomanX, xiaomanY + 2 * s), -- 1228
		34 * s, -- 1228
		8 * s, -- 1228
		Color(4, 6, 12, 190) -- 1228
	) -- 1228
	local childSlot = (k1Pulse > 0.25 or k2Pulse > 0.25) and "child_knock" or (openK > 0.45 and "child_offer" or "child_idle") -- 1229
	uiArt:tryPlace( -- 1230
		childSlot, -- 1230
		"fe05_porch_child", -- 1230
		xiaomanX, -- 1230
		xiaomanY, -- 1230
		108 * s, -- 1230
		148 * s, -- 1230
		{facing = 1, opacity = 0.98, layer = 2} -- 1230
	) -- 1230
	if openK > 0.15 then -- 1230
		local wristX = xiaomanX + 22 * s -- 1235
		local wristY = xiaomanY + 76 * s -- 1236
		uiInkDraw:drawRect( -- 1237
			Rect(wristX - 7 * s, wristY - 5 * s, 14 * s, 11 * s), -- 1238
			Color( -- 1239
				142, -- 1239
				118, -- 1239
				84, -- 1239
				math.floor(245 * openK + 0.5) -- 1239
			), -- 1239
			1, -- 1240
			Color( -- 1241
				222, -- 1241
				192, -- 1241
				128, -- 1241
				math.floor(235 * openK + 0.5) -- 1241
			) -- 1241
		) -- 1241
		uiInkDraw:drawSegment( -- 1243
			Vec2(wristX - 8 * s, wristY), -- 1244
			Vec2(wristX + 8 * s, wristY + 2 * s), -- 1245
			2 * s, -- 1246
			toColor( -- 1247
				CUFF_PALETTE.childCord, -- 1247
				math.floor(240 * openK + 0.5) -- 1247
			) -- 1247
		) -- 1247
	end -- 1247
	if route == "soldier" then -- 1247
		local zhouX = xiaomanX - 72 * s -- 1253
		local zhouY = threshY - 2 * s -- 1254
		uiDraw:drawEllipse( -- 1255
			Vec2(zhouX, zhouY + 2 * s), -- 1255
			42 * s, -- 1255
			9 * s, -- 1255
			Color(4, 6, 12, 190) -- 1255
		) -- 1255
		uiArt:tryPlace( -- 1256
			"soldier_idle", -- 1256
			"fe05_porch_soldier", -- 1256
			zhouX, -- 1256
			zhouY, -- 1256
			146 * s, -- 1256
			206 * s, -- 1256
			{facing = 1, opacity = 0.98, layer = 2} -- 1256
		) -- 1256
		local handMidX = (zhouX + xiaomanX) * 0.5 + 4 * s -- 1260
		local handMidY = threshY + 66 * s -- 1261
		uiInkDraw:drawSegment( -- 1262
			Vec2(zhouX + 20 * s, threshY + 106 * s), -- 1263
			Vec2(handMidX - 2 * s, handMidY), -- 1264
			6.2 * s, -- 1265
			toColor(CUFF_PALETTE.indigoBase, 245) -- 1266
		) -- 1266
		uiInkDraw:drawSegment( -- 1268
			Vec2(handMidX - 9 * s, handMidY + 9 * s), -- 1269
			Vec2(handMidX - 3 * s, handMidY + 13 * s), -- 1270
			1.9 * s, -- 1271
			toColor(CUFF_PALETTE.stitchThread, 240) -- 1272
		) -- 1272
		uiInkDraw:drawSegment( -- 1274
			Vec2(xiaomanX - 14 * s, threshY + 78 * s), -- 1275
			Vec2(handMidX + 2 * s, handMidY), -- 1276
			4.8 * s, -- 1277
			toColor(CUFF_PALETTE.childSleeve, 245) -- 1278
		) -- 1278
		uiInkDraw:drawDot( -- 1280
			Vec2(handMidX, handMidY), -- 1280
			4.8 * s, -- 1280
			toColor(CUFF_PALETTE.skinLight, 245) -- 1280
		) -- 1280
	end -- 1280
end -- 1005
function TowerEndingsPlugin.prototype.drawAct2And3Guardroom(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy) -- 1286
	local t = self.seqElapsed -- 1298
	local isLowpoly = route == "child" -- 1299
	local deskY = oy + ____exports.TOWER_SHOT_LAYOUT.deskTopY * s -- 1300
	if isLowpoly then -- 1300
		self:drawF03LowpolyRoomAndWindow( -- 1304
			uiDraw, -- 1304
			uiGlow, -- 1304
			ctx, -- 1304
			lampProg, -- 1304
			s, -- 1304
			ox, -- 1304
			oy -- 1304
		) -- 1304
	else -- 1304
		self:drawM03PixelRoomAndWindow( -- 1306
			uiDraw, -- 1306
			uiArt, -- 1306
			uiGlow, -- 1306
			ctx, -- 1306
			s, -- 1306
			ox, -- 1306
			oy -- 1306
		) -- 1306
	end -- 1306
	local deskTopCol = isLowpoly and toColor(shadeSurface( -- 1310
		MING_MATERIALS.mingTimber.base, -- 1312
		vec3(-0.25, 0.9, -0.35), -- 1313
		0, -- 1314
		1, -- 1315
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1316
		MING_MATERIALS.mingTimber -- 1317
	)) or Color(86, 60, 42, 255) -- 1317
	local deskFrontCol = isLowpoly and toColor(shadeSurface( -- 1320
		MING_MATERIALS.mingTimberDark.base, -- 1322
		vec3(0, 0.1, -0.99), -- 1323
		-4, -- 1323
		1, -- 1325
		lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1326
		MING_MATERIALS.mingTimberDark -- 1327
	)) or Color(52, 36, 26, 255) -- 1327
	uiDraw:drawPolygon( -- 1332
		{ -- 1332
			Vec2(0, deskY - 120 * s), -- 1333
			Vec2(ctx.uiW, deskY - 120 * s), -- 1334
			Vec2(ctx.uiW, deskY + 42 * s), -- 1335
			Vec2(0, deskY + 42 * s) -- 1336
		}, -- 1336
		deskTopCol -- 1337
	) -- 1337
	uiDraw:drawRect( -- 1338
		Rect(0, 0, ctx.uiW, deskY - 118 * s), -- 1338
		deskFrontCol -- 1338
	) -- 1338
	uiDraw:drawSegment( -- 1339
		Vec2(0, deskY + 42 * s), -- 1339
		Vec2(ctx.uiW, deskY + 42 * s), -- 1339
		1.6 * s, -- 1339
		Color(158, 126, 92, 165) -- 1339
	) -- 1339
	uiDraw:drawSegment( -- 1340
		Vec2(0, deskY - 118 * s), -- 1340
		Vec2(ctx.uiW, deskY - 118 * s), -- 1340
		2 * s, -- 1340
		Color(172, 138, 102, 155) -- 1340
	) -- 1340
	local inkX = ox + ____exports.TOWER_SHOT_LAYOUT.inkstoneX * s -- 1343
	local inkY = oy + ____exports.TOWER_SHOT_LAYOUT.inkstoneY * s -- 1344
	uiDraw:drawEllipse( -- 1345
		Vec2(inkX + 3 * s, inkY - 18 * s), -- 1345
		44 * s, -- 1345
		11 * s, -- 1345
		Color(10, 10, 14, 145) -- 1345
	) -- 1345
	uiDraw:drawPolygon( -- 1346
		{ -- 1346
			Vec2(inkX - 38 * s, inkY - 18 * s), -- 1347
			Vec2(inkX + 38 * s, inkY - 18 * s), -- 1348
			Vec2(inkX + 32 * s, inkY + 18 * s), -- 1349
			Vec2(inkX - 32 * s, inkY + 18 * s) -- 1350
		}, -- 1350
		Color(38, 44, 52, 255), -- 1351
		1.2, -- 1351
		Color(96, 106, 118, 185) -- 1351
	) -- 1351
	uiDraw:drawEllipse( -- 1352
		Vec2(inkX, inkY + 1 * s), -- 1352
		22 * s, -- 1352
		10 * s, -- 1352
		Color(12, 14, 18, 255) -- 1352
	) -- 1352
	strokeEllipse( -- 1353
		uiDraw, -- 1353
		inkX, -- 1353
		inkY + 1 * s, -- 1353
		22 * s, -- 1353
		10 * s, -- 1353
		1.1 * s, -- 1353
		Color(76, 86, 98, 165), -- 1353
		18 -- 1353
	) -- 1353
	local lx = isLowpoly and ox + lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s or ox + ____exports.TOWER_SHOT_LAYOUT.lampDeskX * s -- 1356
	local ly = isLowpoly and oy + (lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34) * s or oy + ____exports.TOWER_SHOT_LAYOUT.lampDeskY * s -- 1359
	local lampWarmth = isLowpoly and 0.45 + 0.55 * lampProg or 0.92 -- 1362
	self:drawMingLantern( -- 1363
		uiInkDraw, -- 1363
		uiGlow, -- 1363
		lx, -- 1363
		ly, -- 1363
		1.02 * s, -- 1363
		1, -- 1363
		lampWarmth -- 1363
	) -- 1363
	if isLowpoly and lampProg > 0.04 then -- 1363
		local beamA = math.floor(62 * lampProg + 0.5) -- 1367
		fillGradQuad( -- 1368
			uiGlow, -- 1369
			lx + 10 * s, -- 1370
			ly + 30 * s, -- 1370
			Color(248, 206, 134, beamA), -- 1370
			lx + 10 * s, -- 1371
			ly - 32 * s, -- 1371
			Color( -- 1371
				248, -- 1371
				206, -- 1371
				134, -- 1371
				math.floor(beamA * 0.72 + 0.5) -- 1371
			), -- 1371
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.92) * s, -- 1372
			oy + (____exports.TOWER_SHOT_LAYOUT.row2Y - 58) * s, -- 1372
			Color(242, 198, 124, 0), -- 1372
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.85) * s, -- 1373
			oy + (____exports.TOWER_SHOT_LAYOUT.row1Y + 48) * s, -- 1373
			Color(242, 198, 124, 0) -- 1373
		) -- 1373
	end -- 1373
	local bookReveal = smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t) -- 1378
	if bookReveal > 0.02 then -- 1378
		self:drawRegisterBook( -- 1380
			uiDraw, -- 1380
			uiInkDraw, -- 1380
			uiArt, -- 1380
			uiGlow, -- 1380
			ctx, -- 1380
			route, -- 1380
			bookReveal, -- 1380
			lampProg, -- 1380
			s, -- 1380
			ox, -- 1380
			oy -- 1380
		) -- 1380
	end -- 1380
	self:drawDeskPropsAndBowl( -- 1384
		uiDraw, -- 1384
		uiInkDraw, -- 1384
		uiGlow, -- 1384
		route, -- 1384
		s, -- 1384
		ox, -- 1384
		oy -- 1384
	) -- 1384
end -- 1286
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiGlow, ctx, lampProg, s, ox, oy) -- 1387
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1396
	local wallTop = lerpRGBA( -- 1397
		rgba(18, 24, 38, 255), -- 1397
		rgba(46, 36, 28, 255), -- 1397
		lampProg -- 1397
	) -- 1397
	local wallBot = lerpRGBA( -- 1398
		rgba(12, 16, 26, 255), -- 1398
		rgba(28, 22, 20, 255), -- 1398
		lampProg -- 1398
	) -- 1398
	fillVGradRect( -- 1399
		uiDraw, -- 1399
		0, -- 1399
		0, -- 1399
		ctx.uiW, -- 1399
		ctx.uiH, -- 1399
		toColor(wallBot), -- 1399
		toColor(wallTop) -- 1399
	) -- 1399
	local beamCol = shadeSurface( -- 1402
		MING_MATERIALS.mingTimberDark.base, -- 1402
		vec3(-0.3, -0.6, -0.74), -- 1402
		18, -- 1402
		1, -- 1402
		light, -- 1402
		MING_MATERIALS.mingTimberDark -- 1402
	) -- 1402
	uiDraw:drawPolygon( -- 1403
		{ -- 1403
			Vec2(0, ctx.uiH - 96 * s), -- 1404
			Vec2(ctx.uiW, ctx.uiH - 72 * s), -- 1405
			Vec2(ctx.uiW, ctx.uiH - 42 * s), -- 1406
			Vec2(0, ctx.uiH - 42 * s) -- 1407
		}, -- 1407
		toColor(beamCol) -- 1408
	) -- 1408
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1411
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1412
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1413
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1414
	local embrasure = 24 * s -- 1415
	fillVGradRect( -- 1418
		uiDraw, -- 1418
		wx, -- 1418
		wy, -- 1418
		ww, -- 1418
		wh, -- 1418
		Color(34, 44, 62, 255), -- 1418
		Color(16, 24, 40, 255) -- 1418
	) -- 1418
	uiDraw:drawPolygon( -- 1419
		{ -- 1419
			Vec2(wx, wy), -- 1420
			Vec2(wx + ww, wy), -- 1421
			Vec2(wx + ww, wy + wh * 0.34), -- 1422
			Vec2(wx + ww * 0.56, wy + wh * 0.42), -- 1423
			Vec2(wx + ww * 0.22, wy + wh * 0.28), -- 1424
			Vec2(wx, wy + wh * 0.36) -- 1425
		}, -- 1425
		Color(20, 26, 38, 240) -- 1426
	) -- 1426
	if lampProg > 0.12 then -- 1426
		fillRadialGlow( -- 1429
			uiGlow, -- 1430
			wx + ww * 0.5, -- 1430
			wy + 26 * s, -- 1430
			ww * 0.65, -- 1431
			wh * 0.55, -- 1431
			Color( -- 1432
				248, -- 1432
				206, -- 1432
				134, -- 1432
				math.floor(92 * lampProg + 0.5) -- 1432
			), -- 1432
			Color(232, 174, 88, 0), -- 1433
			16 -- 1434
		) -- 1434
	end -- 1434
	local leftWall = shadeSurface( -- 1439
		MING_MATERIALS.mingBrick.base, -- 1439
		vec3(0.84, 0.22, -0.49), -- 1439
		10, -- 1439
		1, -- 1439
		light, -- 1439
		MING_MATERIALS.mingBrick -- 1439
	) -- 1439
	local rightWall = shadeSurface( -- 1440
		MING_MATERIALS.mingBrick.base, -- 1440
		vec3(-0.84, 0.22, -0.49), -- 1440
		10, -- 1440
		1, -- 1440
		light, -- 1440
		MING_MATERIALS.mingBrick -- 1440
	) -- 1440
	local sillCol = shadeSurface( -- 1441
		MING_MATERIALS.mingStoneStep.base, -- 1441
		vec3(0, 0.94, -0.34), -- 1441
		6, -- 1441
		1, -- 1441
		light, -- 1441
		MING_MATERIALS.mingStoneStep -- 1441
	) -- 1441
	uiDraw:drawPolygon( -- 1442
		{ -- 1442
			Vec2(wx - embrasure, wy - 12 * s), -- 1443
			Vec2(wx, wy), -- 1444
			Vec2(wx, wy + wh), -- 1445
			Vec2(wx - embrasure, wy + wh + 14 * s) -- 1446
		}, -- 1446
		toColor(leftWall) -- 1447
	) -- 1447
	uiDraw:drawPolygon( -- 1448
		{ -- 1448
			Vec2(wx + ww, wy), -- 1449
			Vec2(wx + ww + embrasure, wy - 12 * s), -- 1450
			Vec2(wx + ww + embrasure, wy + wh + 14 * s), -- 1451
			Vec2(wx + ww, wy + wh) -- 1452
		}, -- 1452
		toColor(rightWall) -- 1453
	) -- 1453
	uiDraw:drawPolygon( -- 1455
		{ -- 1455
			Vec2(wx - embrasure - 10 * s, wy - 16 * s), -- 1456
			Vec2(wx + ww + embrasure + 10 * s, wy - 16 * s), -- 1457
			Vec2(wx + ww + 4 * s, wy + 10 * s), -- 1458
			Vec2(wx - 4 * s, wy + 10 * s) -- 1459
		}, -- 1459
		toColor(sillCol), -- 1460
		1, -- 1460
		toColor(STONE_EDGE_FALLBACK, 140) -- 1460
	) -- 1460
	local bar = 1 -- 1463
	do -- 1463
		bar = 1 -- 1464
		while bar <= 3 do -- 1464
			local bx = wx + ww * bar / 4 -- 1465
			uiDraw:drawSegment( -- 1466
				Vec2(bx, wy + 6 * s), -- 1466
				Vec2(bx, wy + wh - 2 * s), -- 1466
				3 * s, -- 1466
				Color(46, 34, 26, 235) -- 1466
			) -- 1466
			bar = bar + 1 -- 1464
		end -- 1464
	end -- 1464
	uiDraw:drawSegment( -- 1468
		Vec2(wx, wy + wh * 0.56), -- 1468
		Vec2(wx + ww, wy + wh * 0.56), -- 1468
		3.2 * s, -- 1468
		Color(46, 34, 26, 235) -- 1468
	) -- 1468
	uiDraw:drawRect( -- 1469
		Rect(wx, wy, ww, wh), -- 1469
		Color(0, 0, 0, 0), -- 1469
		2.4 * s, -- 1469
		Color(66, 50, 38, 240) -- 1469
	) -- 1469
	if lampProg > 0.02 then -- 1469
		fillRadialGlow( -- 1473
			uiGlow, -- 1474
			wx + ww * 0.5, -- 1474
			wy + 34 * s, -- 1474
			540 * s, -- 1475
			390 * s, -- 1475
			Color( -- 1476
				246, -- 1476
				198, -- 1476
				122, -- 1476
				math.floor(74 * lampProg + 0.5) -- 1476
			), -- 1476
			Color(216, 154, 72, 0), -- 1477
			20 -- 1478
		) -- 1478
	end -- 1478
end -- 1387
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1483
	fillVGradRect( -- 1493
		uiDraw, -- 1494
		0, -- 1494
		0, -- 1494
		ctx.uiW, -- 1494
		ctx.uiH, -- 1494
		Color(26, 21, 20, 255), -- 1495
		Color(46, 36, 30, 255) -- 1496
	) -- 1496
	local r = 0 -- 1499
	do -- 1499
		r = 0 -- 1500
		while r < 9 do -- 1500
			local y = oy + (280 + r * 44) * s -- 1501
			uiDraw:drawSegment( -- 1502
				Vec2(0, y), -- 1502
				Vec2(ctx.uiW, y), -- 1502
				1, -- 1502
				Color(34, 27, 24, 150) -- 1502
			) -- 1502
			r = r + 1 -- 1500
		end -- 1500
	end -- 1500
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1506
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1507
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1508
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1509
	fillVGradRect( -- 1510
		uiDraw, -- 1510
		wx, -- 1510
		wy, -- 1510
		ww, -- 1510
		wh, -- 1510
		Color(56, 62, 74, 255), -- 1510
		Color(26, 34, 50, 255) -- 1510
	) -- 1510
	uiDraw:drawRect( -- 1511
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1511
		Color(92, 68, 48, 255), -- 1511
		1, -- 1511
		Color(148, 114, 82, 180) -- 1511
	) -- 1511
	local bar = 1 -- 1512
	do -- 1512
		bar = 1 -- 1513
		while bar <= 3 do -- 1513
			local bx = wx + ww * bar / 4 -- 1514
			uiDraw:drawSegment( -- 1515
				Vec2(bx, wy + 4 * s), -- 1515
				Vec2(bx, wy + wh - 2 * s), -- 1515
				3.2 * s, -- 1515
				Color(64, 46, 34, 245) -- 1515
			) -- 1515
			bar = bar + 1 -- 1513
		end -- 1513
	end -- 1513
	uiDraw:drawSegment( -- 1517
		Vec2(wx, wy + wh * 0.56), -- 1517
		Vec2(wx + ww, wy + wh * 0.56), -- 1517
		3.2 * s, -- 1517
		Color(64, 46, 34, 245) -- 1517
	) -- 1517
	uiDraw:drawRect( -- 1518
		Rect(wx, wy, ww, wh), -- 1518
		Color(0, 0, 0, 0), -- 1518
		2.8 * s, -- 1518
		Color(88, 64, 44, 245) -- 1518
	) -- 1518
	local groupX = ox + 210 * s -- 1521
	local groupY = oy + 300 * s -- 1522
	uiArt:tryPlace( -- 1523
		"soldier_idle", -- 1523
		"fe05_m03_room_soldier", -- 1523
		groupX - 38 * s, -- 1523
		groupY, -- 1523
		118 * s, -- 1523
		166 * s, -- 1523
		{facing = 1, opacity = 0.9, layer = 1} -- 1523
	) -- 1523
	uiArt:tryPlace( -- 1526
		"child_idle", -- 1526
		"fe05_m03_room_child", -- 1526
		groupX + 42 * s, -- 1526
		groupY, -- 1526
		86 * s, -- 1526
		116 * s, -- 1526
		{facing = 1, opacity = 0.92, layer = 1} -- 1526
	) -- 1526
	fillRadialGlow( -- 1531
		uiGlow, -- 1532
		ox + 260 * s, -- 1532
		oy + 416 * s, -- 1532
		520 * s, -- 1533
		360 * s, -- 1533
		Color(246, 202, 134, 68), -- 1534
		Color(220, 158, 76, 0), -- 1535
		20 -- 1536
	) -- 1536
end -- 1483
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1540
	local t = self.seqElapsed -- 1553
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1554
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1555
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1556
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1557
	local midX = bx + bw * 0.5 -- 1558
	local midY = by + bh * 0.5 -- 1559
	uiDraw:drawRect( -- 1562
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1562
		Color( -- 1562
			10, -- 1562
			11, -- 1562
			16, -- 1562
			math.floor(108 * reveal + 0.5) -- 1562
		) -- 1562
	) -- 1562
	uiDraw:drawRect( -- 1563
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1563
		Color( -- 1563
			32, -- 1563
			46, -- 1563
			62, -- 1563
			math.floor(235 * reveal + 0.5) -- 1563
		), -- 1563
		1, -- 1563
		Color( -- 1563
			86, -- 1563
			104, -- 1563
			124, -- 1563
			math.floor(165 * reveal + 0.5) -- 1563
		) -- 1563
	) -- 1563
	if not uiArt:tryPlace( -- 1563
		"ink_song_paper", -- 1566
		"fe05_registry_paper", -- 1566
		midX, -- 1566
		midY, -- 1566
		bw, -- 1566
		bh, -- 1566
		{opacity = 0.98 * reveal, layer = 1} -- 1566
	) then -- 1566
		uiDraw:drawRect( -- 1567
			Rect(bx, by, bw, bh), -- 1568
			toColor( -- 1569
				PALETTE.xuanPaper, -- 1569
				math.floor(248 * reveal + 0.5) -- 1569
			), -- 1569
			1, -- 1570
			toColor( -- 1571
				PALETTE.silkDim, -- 1571
				math.floor(180 * reveal + 0.5) -- 1571
			) -- 1571
		) -- 1571
	end -- 1571
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1576
	fillRadialGlow( -- 1577
		uiGlow, -- 1578
		bx + bw * 0.34, -- 1578
		by + bh * 0.48, -- 1578
		bw * 0.58, -- 1579
		bh * 0.52, -- 1579
		Color( -- 1580
			246, -- 1580
			214, -- 1580
			156, -- 1580
			math.floor(44 * paperWarm * reveal + 0.5) -- 1580
		), -- 1580
		Color(238, 198, 128, 0), -- 1581
		16 -- 1582
	) -- 1582
	local padX = 44 * s -- 1586
	local padY = 32 * s -- 1587
	local inX = bx + padX -- 1588
	local inY = by + padY -- 1589
	local inW = bw - padX * 2 -- 1590
	local inH = bh - padY * 2 -- 1591
	local redSilk = toColor( -- 1592
		PALETTE.rouge, -- 1592
		math.floor(132 * reveal + 0.5) -- 1592
	) -- 1592
	local redFaint = toColor( -- 1593
		PALETTE.rouge, -- 1593
		math.floor(70 * reveal + 0.5) -- 1593
	) -- 1593
	uiInkDraw:drawRect( -- 1594
		Rect(inX, inY, inW, inH), -- 1594
		Color(0, 0, 0, 0), -- 1594
		1, -- 1594
		redSilk -- 1594
	) -- 1594
	uiInkDraw:drawRect( -- 1595
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1595
		Color(0, 0, 0, 0), -- 1595
		0.6, -- 1595
		redFaint -- 1595
	) -- 1595
	local headY = inY + inH - 28 * s -- 1598
	ctx.texts:put( -- 1599
		"md", -- 1599
		"北塔值夜收籍 · 末页", -- 1599
		inX + 18 * s, -- 1599
		headY, -- 1599
		toColor(PALETTE.xuanInk), -- 1599
		0, -- 1599
		0.5, -- 1599
		"Left", -- 1599
		2.2, -- 1599
		0.96 * reveal, -- 1599
		0 -- 1599
	) -- 1599
	ctx.texts:put( -- 1600
		"xs", -- 1600
		"宁村北塔", -- 1600
		inX + inW - 18 * s, -- 1600
		headY, -- 1600
		toColor(PALETTE.xuanInkSub), -- 1600
		1, -- 1600
		0.5, -- 1600
		"Right", -- 1600
		1.8, -- 1600
		0.8 * reveal, -- 1600
		0 -- 1600
	) -- 1600
	uiInkDraw:drawSegment( -- 1601
		Vec2(inX + 14 * s, headY - 22 * s), -- 1601
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1601
		0.9, -- 1601
		redSilk -- 1601
	) -- 1601
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1604
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1605
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1606
	ctx.texts:put( -- 1607
		"sm", -- 1607
		"肆拾壹", -- 1607
		inX + 18 * s, -- 1607
		row1Y, -- 1607
		toColor(PALETTE.rouge), -- 1607
		0, -- 1607
		0.5, -- 1607
		"Left", -- 1607
		1, -- 1607
		0.94 * reveal, -- 1607
		0 -- 1607
	) -- 1607
	if r1Prog > 0.02 then -- 1607
		ctx.texts:put( -- 1609
			"md", -- 1609
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1609
			inX + 96 * s, -- 1609
			row1Y, -- 1609
			toColor(PALETTE.xuanInk), -- 1609
			0, -- 1609
			0.5, -- 1609
			"Left", -- 1609
			1.6, -- 1609
			0.96 * math.min(1, r1Prog * 1.4), -- 1609
			0 -- 1609
		) -- 1609
	end -- 1609
	if r1Prog > 0.65 then -- 1609
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1612
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1613
		ctx.texts:put( -- 1616
			"xs", -- 1616
			subText, -- 1616
			inX + 96 * s, -- 1616
			row1SubY, -- 1616
			toColor(PALETTE.xuanInkSub), -- 1616
			0, -- 1616
			0.5, -- 1616
			"Left", -- 1616
			0.6, -- 1616
			0.88 * subA, -- 1616
			0 -- 1616
		) -- 1616
	end -- 1616
	uiInkDraw:drawSegment( -- 1618
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1618
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1618
		0.7, -- 1618
		redFaint -- 1618
	) -- 1618
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1621
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1622
	ctx.texts:put( -- 1623
		"sm", -- 1623
		"肆拾贰", -- 1623
		inX + 18 * s, -- 1623
		row2Y, -- 1623
		toColor(PALETTE.rouge), -- 1623
		0, -- 1623
		0.5, -- 1623
		"Left", -- 1623
		1, -- 1623
		0.94 * reveal, -- 1623
		0 -- 1623
	) -- 1623
	if route == "child" then -- 1623
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1627
		uiInkDraw:drawSegment( -- 1628
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1629
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1630
			1, -- 1631
			toColor(PALETTE.xuanInkSub, lineA) -- 1632
		) -- 1632
	else -- 1632
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1636
		if r2Prog <= 0.02 then -- 1636
			uiInkDraw:drawSegment( -- 1638
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1639
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1640
				0.9, -- 1641
				toColor( -- 1642
					PALETTE.xuanInkSub, -- 1642
					math.floor(105 * reveal + 0.5) -- 1642
				) -- 1642
			) -- 1642
		else -- 1642
			ctx.texts:put( -- 1645
				"md", -- 1645
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1645
				inX + 96 * s, -- 1645
				row2Y, -- 1645
				toColor(PALETTE.xuanInk), -- 1645
				0, -- 1645
				0.5, -- 1645
				"Left", -- 1645
				1.6, -- 1645
				0.96 * math.min(1, r2Prog * 1.4), -- 1645
				0 -- 1645
			) -- 1645
			if r2Prog > 0.65 then -- 1645
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1647
				ctx.texts:put( -- 1648
					"xs", -- 1648
					"守城戍卒亲口报出姓名，两人俱安。", -- 1648
					inX + 96 * s, -- 1648
					row2SubY, -- 1648
					toColor(PALETTE.xuanInkSub), -- 1648
					0, -- 1648
					0.5, -- 1648
					"Left", -- 1648
					0.6, -- 1648
					0.88 * subA, -- 1648
					0 -- 1648
				) -- 1648
			end -- 1648
		end -- 1648
	end -- 1648
	uiInkDraw:drawSegment( -- 1652
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1652
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1652
		0.7, -- 1652
		redFaint -- 1652
	) -- 1652
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1655
	if colophonA > 0.02 then -- 1655
		local signY = inY + 34 * s -- 1657
		ctx.texts:put( -- 1658
			"banner", -- 1658
			"向西守望", -- 1658
			midX - 24 * s, -- 1658
			signY, -- 1658
			toColor(PALETTE.xuanInk), -- 1658
			0.5, -- 1658
			0.5, -- 1658
			"Center", -- 1658
			6, -- 1658
			0.88 * colophonA, -- 1658
			0 -- 1658
		) -- 1658
	end -- 1658
	self:drawGuardBrushHand( -- 1662
		uiInkDraw, -- 1662
		route, -- 1662
		s, -- 1662
		ox, -- 1662
		oy -- 1662
	) -- 1662
end -- 1540
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, route, s, ox, oy) -- 1665
	local t = self.seqElapsed -- 1672
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1673
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1674
	local row1X0 = hoverX -- 1675
	local row1X1 = hoverX + 142 * s -- 1676
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1677
	local tipX = hoverX -- 1679
	local tipY = hoverY -- 1680
	local alpha = 0 -- 1681
	local lifted = 0 -- 1682
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1682
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1686
		tipX = lerp(row1X0, row1X1, k) -- 1687
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1688
		alpha = smoothstep(2, 2.2, t) -- 1689
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1690
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1690
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1693
		tipX = lerp(row1X1, hoverX, moveK) -- 1694
		tipY = lerp(row1Y, hoverY, moveK) -- 1695
		alpha = 1 -- 1696
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1697
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1697
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1700
		tipX = hoverX + outK * 140 * s -- 1701
		tipY = hoverY + outK * 46 * s -- 1702
		lifted = (9 + outK * 28) * s -- 1703
		alpha = 1 - outK -- 1704
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1704
		if t < 4.6 then -- 1704
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1708
			tipX = hoverX -- 1709
			tipY = hoverY -- 1710
			lifted = lerp(9 * s, 0, dipK) -- 1711
			alpha = 1 -- 1712
		elseif t < 5.55 then -- 1712
			local wK = smoothstep(4.6, 5.55, t) -- 1714
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1715
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1716
			lifted = 0 -- 1717
			alpha = 1 -- 1718
		else -- 1718
			local outK = smoothstep(5.55, 6.05, t) -- 1720
			tipX = hoverX + 216 * s + outK * 115 * s -- 1721
			tipY = hoverY + outK * 52 * s -- 1722
			lifted = outK * 24 * s -- 1723
			alpha = 1 - outK -- 1724
		end -- 1724
	end -- 1724
	if alpha <= 0.02 then -- 1724
		return -- 1729
	end -- 1729
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1732
	local bx = tipX -- 1733
	local by = tipY + lifted -- 1734
	uiInkDraw:drawEllipse( -- 1736
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1736
		(5 + lifted * 0.22) * s, -- 1736
		2.8 * s, -- 1736
		Color( -- 1736
			20, -- 1736
			18, -- 1736
			16, -- 1736
			math.floor(78 * alpha + 0.5) -- 1736
		) -- 1736
	) -- 1736
	uiInkDraw:drawPolygon( -- 1738
		{ -- 1738
			Vec2(bx, by), -- 1739
			Vec2(bx + 15 * s, by - 4 * s), -- 1740
			Vec2(bx + 10 * s, by + 8 * s) -- 1741
		}, -- 1741
		Color(22, 22, 26, a) -- 1742
	) -- 1742
	uiInkDraw:drawSegment( -- 1744
		Vec2(bx + 12 * s, by + 2 * s), -- 1744
		Vec2(bx + 24 * s, by + 6 * s), -- 1744
		7.8 * s, -- 1744
		Color(164, 138, 92, a) -- 1744
	) -- 1744
	uiInkDraw:drawSegment( -- 1745
		Vec2(bx + 22 * s, by + 5 * s), -- 1745
		Vec2(bx + 122 * s, by + 34 * s), -- 1745
		6.8 * s, -- 1745
		Color(142, 110, 74, a) -- 1745
	) -- 1745
	uiInkDraw:drawSegment( -- 1746
		Vec2(bx + 22 * s, by + 5 * s), -- 1746
		Vec2(bx + 122 * s, by + 34 * s), -- 1746
		1.8 * s, -- 1746
		Color( -- 1746
			196, -- 1746
			164, -- 1746
			118, -- 1746
			math.floor(185 * alpha + 0.5) -- 1746
		) -- 1746
	) -- 1746
	uiInkDraw:drawPolygon( -- 1748
		{ -- 1748
			Vec2(bx + 44 * s, by - 6 * s), -- 1749
			Vec2(bx + 102 * s, by - 14 * s), -- 1750
			Vec2(bx + 110 * s, by + 18 * s), -- 1751
			Vec2(bx + 54 * s, by + 22 * s) -- 1752
		}, -- 1752
		Color(188, 154, 126, a), -- 1753
		1, -- 1753
		Color(128, 98, 76, a) -- 1753
	) -- 1753
	uiInkDraw:drawSegment( -- 1754
		Vec2(bx + 46 * s, by + 16 * s), -- 1754
		Vec2(bx + 76 * s, by + 20 * s), -- 1754
		5.2 * s, -- 1754
		Color(204, 170, 140, a) -- 1754
	) -- 1754
	uiInkDraw:drawSegment( -- 1755
		Vec2(bx + 48 * s, by + 2 * s), -- 1755
		Vec2(bx + 82 * s, by + 4 * s), -- 1755
		4.8 * s, -- 1755
		Color(180, 146, 118, a) -- 1755
	) -- 1755
	uiInkDraw:drawPolygon( -- 1756
		{ -- 1756
			Vec2(bx + 98 * s, by - 14 * s), -- 1757
			Vec2(bx + 224 * s, by - 32 * s), -- 1758
			Vec2(bx + 230 * s, by + 18 * s), -- 1759
			Vec2(bx + 104 * s, by + 20 * s) -- 1760
		}, -- 1760
		Color(54, 48, 44, a), -- 1761
		1.2, -- 1761
		Color(94, 84, 72, a) -- 1761
	) -- 1761
end -- 1665
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiGlow, route, s, ox, oy) -- 1764
	local t = self.seqElapsed -- 1773
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1774
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1775
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1776
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1777
	if route == "child" then -- 1777
		local propA = smoothstep(1.55, 2.05, t) -- 1781
		if propA > 0.02 then -- 1781
			self:drawNeedleCaseOnDesk( -- 1783
				uiInkDraw, -- 1783
				ncX, -- 1783
				ncY, -- 1783
				s, -- 1783
				propA, -- 1783
				true -- 1783
			) -- 1783
		end -- 1783
		local bowlK = smoothstep(4.35, 5.15, t) -- 1786
		if bowlK > 0.02 then -- 1786
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1788
			self:drawWarmPorcelainBowl( -- 1789
				uiInkDraw, -- 1789
				uiGlow, -- 1789
				bx, -- 1789
				bowlY, -- 1789
				s, -- 1789
				bowlK, -- 1789
				false, -- 1789
				0 -- 1789
			) -- 1789
		end -- 1789
	else -- 1789
		local needleK = smoothstep(5.45, 6.15, t) -- 1793
		if needleK > 0.02 then -- 1793
			local ny = lerp(ncY + 46 * s, ncY, needleK) -- 1795
			self:drawNeedleCaseOnDesk( -- 1796
				uiInkDraw, -- 1796
				ncX, -- 1796
				ny, -- 1796
				s, -- 1796
				needleK, -- 1796
				false -- 1796
			) -- 1796
		end -- 1796
		local bowlK = smoothstep(5.8, 6.65, t) -- 1799
		if bowlK > 0.02 then -- 1799
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1801
			local handsK = smoothstep(5.95, 6.75, t) -- 1802
			self:drawWarmPorcelainBowl( -- 1803
				uiInkDraw, -- 1803
				uiGlow, -- 1803
				bowlX, -- 1803
				by, -- 1803
				s, -- 1803
				bowlK, -- 1803
				true, -- 1803
				handsK -- 1803
			) -- 1803
		end -- 1803
		local cuffK = smoothstep(4.25, 4.85, t) -- 1806
		if cuffK > 0.02 then -- 1806
			drawPatchedCuff(uiInkDraw, uiGlow, { -- 1808
				wristX = ox + 122 * s, -- 1809
				wristY = oy + 182 * s, -- 1810
				angleRad = 0.08, -- 1811
				scale = 0.6 * s, -- 1812
				pose = "open", -- 1813
				opacity = 0.92 * cuffK, -- 1814
				stitchHighlight = 0.34, -- 1815
				warmth = 0.72 -- 1816
			}) -- 1816
		end -- 1816
	end -- 1816
end -- 1764
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, draw, cx, cy, s, alpha, withNote) -- 1823
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1831
	draw:drawEllipse( -- 1833
		Vec2(cx + 4 * s, cy - 12 * s), -- 1833
		44 * s, -- 1833
		14 * s, -- 1833
		Color( -- 1833
			10, -- 1833
			10, -- 1833
			14, -- 1833
			math.floor(140 * alpha + 0.5) -- 1833
		) -- 1833
	) -- 1833
	draw:drawPolygon( -- 1835
		{ -- 1835
			Vec2(cx - 32 * s, cy - 12 * s), -- 1836
			Vec2(cx + 26 * s, cy - 15 * s), -- 1837
			Vec2(cx + 30 * s, cy + 16 * s), -- 1838
			Vec2(cx - 28 * s, cy + 18 * s) -- 1839
		}, -- 1839
		Color(148, 124, 92, a), -- 1840
		1.3, -- 1840
		Color(88, 70, 50, a) -- 1840
	) -- 1840
	draw:drawEllipse( -- 1842
		Vec2(cx + 18 * s, cy + 2 * s), -- 1842
		13 * s, -- 1842
		13 * s, -- 1842
		Color(188, 152, 86, a) -- 1842
	) -- 1842
	strokeEllipse( -- 1843
		draw, -- 1843
		cx + 18 * s, -- 1843
		cy + 2 * s, -- 1843
		13 * s, -- 1843
		13 * s, -- 1843
		1.5 * s, -- 1843
		Color(118, 92, 46, a), -- 1843
		18 -- 1843
	) -- 1843
	draw:drawDot( -- 1844
		Vec2(cx + 18 * s, cy + 2 * s), -- 1844
		2.5 * s, -- 1844
		Color(72, 54, 28, a) -- 1844
	) -- 1844
	draw:drawSegment( -- 1845
		Vec2(cx + 12 * s, cy - 2 * s), -- 1845
		Vec2(cx + 24 * s, cy + 6 * s), -- 1845
		1.5 * s, -- 1845
		Color(164, 48, 44, a) -- 1845
	) -- 1845
	draw:drawSegment( -- 1847
		Vec2(cx - 28 * s, cy + 4 * s), -- 1847
		Vec2(cx - 56 * s, cy - 8 * s), -- 1847
		2.4 * s, -- 1847
		toColor(CUFF_PALETTE.childCord, a) -- 1847
	) -- 1847
	draw:drawSegment( -- 1848
		Vec2(cx - 56 * s, cy - 8 * s), -- 1848
		Vec2(cx - 72 * s, cy + 6 * s), -- 1848
		2.2 * s, -- 1848
		toColor(CUFF_PALETTE.childCord, a) -- 1848
	) -- 1848
	draw:drawSegment( -- 1849
		Vec2(cx - 72 * s, cy + 6 * s), -- 1849
		Vec2(cx - 48 * s, cy + 16 * s), -- 1849
		2 * s, -- 1849
		toColor( -- 1849
			CUFF_PALETTE.childCord, -- 1849
			math.floor(215 * alpha + 0.5) -- 1849
		) -- 1849
	) -- 1849
	if withNote then -- 1849
		draw:drawPolygon( -- 1853
			{ -- 1853
				Vec2(cx + 38 * s, cy - 18 * s), -- 1854
				Vec2(cx + 96 * s, cy - 12 * s), -- 1855
				Vec2(cx + 90 * s, cy + 24 * s), -- 1856
				Vec2(cx + 34 * s, cy + 18 * s) -- 1857
			}, -- 1857
			toColor(PALETTE.xuanPaper, a), -- 1858
			1, -- 1858
			toColor( -- 1858
				PALETTE.xuanInkSub, -- 1858
				math.floor(160 * alpha + 0.5) -- 1858
			) -- 1858
		) -- 1858
		draw:drawSegment( -- 1859
			Vec2(cx + 46 * s, cy + 8 * s), -- 1859
			Vec2(cx + 80 * s, cy + 11 * s), -- 1859
			1.2 * s, -- 1859
			toColor( -- 1859
				PALETTE.xuanInk, -- 1859
				math.floor(170 * alpha + 0.5) -- 1859
			) -- 1859
		) -- 1859
		draw:drawSegment( -- 1860
			Vec2(cx + 46 * s, cy - 2 * s), -- 1860
			Vec2(cx + 76 * s, cy + 1 * s), -- 1860
			1.2 * s, -- 1860
			toColor( -- 1860
				PALETTE.xuanInk, -- 1860
				math.floor(160 * alpha + 0.5) -- 1860
			) -- 1860
		) -- 1860
	end -- 1860
end -- 1823
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, draw, glow, cx, cy, s, alpha, heldByTwoHands, handsK) -- 1865
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1875
	draw:drawEllipse( -- 1877
		Vec2(cx, cy - 36 * s), -- 1877
		58 * s, -- 1877
		14 * s, -- 1877
		Color( -- 1877
			8, -- 1877
			9, -- 1877
			14, -- 1877
			math.floor(150 * alpha + 0.5) -- 1877
		) -- 1877
	) -- 1877
	draw:drawPolygon( -- 1879
		{ -- 1879
			Vec2(cx - 32 * s, cy - 38 * s), -- 1880
			Vec2(cx + 32 * s, cy - 38 * s), -- 1881
			Vec2(cx + 62 * s, cy + 8 * s), -- 1882
			Vec2(cx - 62 * s, cy + 8 * s) -- 1883
		}, -- 1883
		Color(168, 166, 156, a), -- 1884
		1.4, -- 1884
		Color(98, 96, 88, a) -- 1884
	) -- 1884
	draw:drawPolygon( -- 1886
		{ -- 1886
			Vec2(cx + 8 * s, cy - 36 * s), -- 1887
			Vec2(cx + 32 * s, cy - 38 * s), -- 1888
			Vec2(cx + 62 * s, cy + 8 * s), -- 1889
			Vec2(cx + 22 * s, cy + 6 * s) -- 1890
		}, -- 1890
		Color( -- 1891
			122, -- 1891
			120, -- 1891
			112, -- 1891
			math.floor(160 * alpha + 0.5) -- 1891
		) -- 1891
	) -- 1891
	draw:drawEllipse( -- 1893
		Vec2(cx, cy + 8 * s), -- 1893
		64 * s, -- 1893
		21 * s, -- 1893
		Color(224, 218, 206, a) -- 1893
	) -- 1893
	strokeEllipse( -- 1894
		draw, -- 1894
		cx, -- 1894
		cy + 8 * s, -- 1894
		64 * s, -- 1894
		21 * s, -- 1894
		1.9 * s, -- 1894
		Color(116, 110, 100, a), -- 1894
		28 -- 1894
	) -- 1894
	draw:drawEllipse( -- 1895
		Vec2(cx, cy + 6 * s), -- 1895
		54 * s, -- 1895
		15 * s, -- 1895
		Color(196, 168, 122, a) -- 1895
	) -- 1895
	strokeEllipse( -- 1896
		draw, -- 1896
		cx, -- 1896
		cy + 6 * s, -- 1896
		54 * s, -- 1896
		15 * s, -- 1896
		1.1 * s, -- 1896
		Color(158, 132, 92, a), -- 1896
		24 -- 1896
	) -- 1896
	draw:drawSegment( -- 1898
		Vec2(cx - 46 * s, cy + 16 * s), -- 1898
		Vec2(cx - 10 * s, cy + 25 * s), -- 1898
		2 * s, -- 1898
		Color( -- 1898
			248, -- 1898
			246, -- 1898
			240, -- 1898
			math.floor(215 * alpha + 0.5) -- 1898
		) -- 1898
	) -- 1898
	local wi = 0 -- 1901
	do -- 1901
		wi = 0 -- 1902
		while wi < 3 do -- 1902
			local phase = self.animTime * 1.1 + wi * 2.05 -- 1903
			local baseX = cx + (wi - 1) * 18 * s -- 1904
			local baseY = cy + 16 * s -- 1905
			local segs = 4 -- 1906
			local prevX = baseX -- 1907
			local prevY = baseY -- 1908
			local si = 1 -- 1909
			do -- 1909
				si = 1 -- 1910
				while si <= segs do -- 1910
					local frac = si / segs -- 1911
					local nx = baseX + math.sin(phase + frac * 3.1) * (6.5 * frac) * s -- 1912
					local ny = baseY + frac * (36 + wi % 2 * 10) * s -- 1913
					local wa = math.floor(46 * (1 - frac * 0.72) * alpha + 0.5) -- 1914
					glow:drawSegment( -- 1915
						Vec2(prevX, prevY), -- 1915
						Vec2(nx, ny), -- 1915
						(2.2 - frac * 0.9) * s, -- 1915
						Color(244, 238, 226, wa) -- 1915
					) -- 1915
					prevX = nx -- 1916
					prevY = ny -- 1917
					si = si + 1 -- 1910
				end -- 1910
			end -- 1910
			wi = wi + 1 -- 1902
		end -- 1902
	end -- 1902
	if heldByTwoHands and handsK > 0.02 then -- 1902
		local ha = math.floor(255 * clamp01(handsK * alpha) + 0.5) -- 1923
		local skin = toColor(CUFF_PALETTE.childSkin, ha) -- 1924
		local skinSh = toColor(CUFF_PALETTE.childSkinShadow, ha) -- 1925
		local sleeve = toColor(CUFF_PALETTE.childSleeve, ha) -- 1926
		local spread = (1 - handsK) * 28 * s -- 1927
		draw:drawPolygon( -- 1930
			{ -- 1930
				Vec2(cx - 122 * s - spread, cy - 58 * s), -- 1931
				Vec2(cx - 72 * s - spread, cy - 30 * s), -- 1932
				Vec2(cx - 82 * s - spread, cy - 4 * s), -- 1933
				Vec2(cx - 134 * s - spread, cy - 26 * s) -- 1934
			}, -- 1934
			sleeve, -- 1935
			1.1, -- 1935
			skinSh -- 1935
		) -- 1935
		draw:drawPolygon( -- 1936
			{ -- 1936
				Vec2(cx - 76 * s - spread, cy - 28 * s), -- 1937
				Vec2(cx - 48 * s - spread, cy - 18 * s), -- 1938
				Vec2(cx - 44 * s - spread, cy + 6 * s), -- 1939
				Vec2(cx - 74 * s - spread, cy + 2 * s) -- 1940
			}, -- 1940
			skin, -- 1941
			1.1, -- 1941
			skinSh -- 1941
		) -- 1941
		draw:drawSegment( -- 1942
			Vec2(cx - 56 * s - spread, cy + 2 * s), -- 1942
			Vec2(cx - 38 * s - spread, cy + 12 * s), -- 1942
			4.6 * s, -- 1942
			skin -- 1942
		) -- 1942
		draw:drawSegment( -- 1943
			Vec2(cx - 58 * s - spread, cy - 7 * s), -- 1943
			Vec2(cx - 40 * s - spread, cy - 2 * s), -- 1943
			4.4 * s, -- 1943
			skin -- 1943
		) -- 1943
		draw:drawSegment( -- 1944
			Vec2(cx - 56 * s - spread, cy - 16 * s), -- 1944
			Vec2(cx - 40 * s - spread, cy - 14 * s), -- 1944
			4.2 * s, -- 1944
			skin -- 1944
		) -- 1944
		draw:drawPolygon( -- 1947
			{ -- 1947
				Vec2(cx + 122 * s + spread, cy - 58 * s), -- 1948
				Vec2(cx + 72 * s + spread, cy - 30 * s), -- 1949
				Vec2(cx + 82 * s + spread, cy - 4 * s), -- 1950
				Vec2(cx + 134 * s + spread, cy - 26 * s) -- 1951
			}, -- 1951
			sleeve, -- 1952
			1.1, -- 1952
			skinSh -- 1952
		) -- 1952
		draw:drawPolygon( -- 1953
			{ -- 1953
				Vec2(cx + 76 * s + spread, cy - 28 * s), -- 1954
				Vec2(cx + 48 * s + spread, cy - 18 * s), -- 1955
				Vec2(cx + 44 * s + spread, cy + 6 * s), -- 1956
				Vec2(cx + 74 * s + spread, cy + 2 * s) -- 1957
			}, -- 1957
			skin, -- 1958
			1.1, -- 1958
			skinSh -- 1958
		) -- 1958
		draw:drawSegment( -- 1959
			Vec2(cx + 56 * s + spread, cy + 2 * s), -- 1959
			Vec2(cx + 38 * s + spread, cy + 12 * s), -- 1959
			4.6 * s, -- 1959
			skin -- 1959
		) -- 1959
		draw:drawSegment( -- 1960
			Vec2(cx + 58 * s + spread, cy - 7 * s), -- 1960
			Vec2(cx + 40 * s + spread, cy - 2 * s), -- 1960
			4.4 * s, -- 1960
			skin -- 1960
		) -- 1960
		draw:drawSegment( -- 1961
			Vec2(cx + 56 * s + spread, cy - 16 * s), -- 1961
			Vec2(cx + 40 * s + spread, cy - 14 * s), -- 1961
			4.2 * s, -- 1961
			skin -- 1961
		) -- 1961
	end -- 1961
end -- 1865
function TowerEndingsPlugin.prototype.drawMingLantern(self, draw, glow, cx, cy, scale, alpha, warmth) -- 1966
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1975
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 1976
	draw:drawSegment( -- 1978
		Vec2(cx - 10 * scale, cy + 28 * scale), -- 1978
		Vec2(cx, cy + 40 * scale), -- 1978
		1.8 * scale, -- 1978
		Color(88, 86, 82, a) -- 1978
	) -- 1978
	draw:drawSegment( -- 1979
		Vec2(cx + 10 * scale, cy + 28 * scale), -- 1979
		Vec2(cx, cy + 40 * scale), -- 1979
		1.8 * scale, -- 1979
		Color(88, 86, 82, a) -- 1979
	) -- 1979
	draw:drawRect( -- 1981
		Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), -- 1981
		Color(62, 46, 34, a), -- 1981
		1, -- 1981
		Color(118, 92, 66, a) -- 1981
	) -- 1981
	draw:drawRect( -- 1982
		Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), -- 1982
		Color(62, 46, 34, a), -- 1982
		1, -- 1982
		Color(118, 92, 66, a) -- 1982
	) -- 1982
	draw:drawRect( -- 1984
		Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale), -- 1985
		Color( -- 1986
			238, -- 1986
			198, -- 1986
			132, -- 1986
			math.floor(230 * alpha * (0.75 + 0.25 * warmth) + 0.5) -- 1986
		), -- 1986
		1.4 * scale, -- 1987
		Color(94, 70, 48, a) -- 1988
	) -- 1988
	draw:drawSegment( -- 1990
		Vec2(cx, cy - 18 * scale), -- 1990
		Vec2(cx, cy + 22 * scale), -- 1990
		1.1 * scale, -- 1990
		Color( -- 1990
			94, -- 1990
			70, -- 1990
			48, -- 1990
			math.floor(150 * alpha + 0.5) -- 1990
		) -- 1990
	) -- 1990
	draw:drawEllipse( -- 1991
		Vec2(cx, cy + 2 * scale), -- 1991
		4.6 * scale * flicker, -- 1991
		8.5 * scale * flicker, -- 1991
		Color(255, 244, 212, a) -- 1991
	) -- 1991
	fillRadialGlow( -- 1993
		glow, -- 1994
		cx, -- 1994
		cy + 2 * scale, -- 1994
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 1995
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 1996
		Color( -- 1997
			250, -- 1997
			208, -- 1997
			132, -- 1997
			math.floor(128 * alpha * warmth + 0.5) -- 1997
		), -- 1997
		Color(228, 162, 74, 0), -- 1998
		16 -- 1999
	) -- 1999
end -- 1966
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 2003
	local line = self.lastSubtitle -- 2012
	if line ~= "" then -- 2012
		local cy = barH + 34 * s -- 2014
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 2015
		drawSilkVeil( -- 2016
			uiDraw, -- 2016
			uiArt, -- 2016
			"fe05_sub_veil", -- 2016
			ctx.uiW * 0.5, -- 2016
			cy, -- 2016
			stripW, -- 2016
			48 * s, -- 2016
			PALETTE.inkWash, -- 2016
			0.82, -- 2016
			3 -- 2016
		) -- 2016
		drawHairline( -- 2017
			uiInkDraw, -- 2017
			uiArt, -- 2017
			"fe05_sub_hair", -- 2017
			ctx.uiW * 0.5, -- 2017
			cy + 21 * s, -- 2017
			stripW * 0.68, -- 2017
			PALETTE.silkDim, -- 2017
			0.54, -- 2017
			true, -- 2017
			4 -- 2017
		) -- 2017
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 2018
		ctx.texts:put( -- 2019
			isSpoken and "md" or "sm", -- 2020
			line, -- 2021
			ctx.uiW * 0.5, -- 2022
			cy - 1 * s, -- 2023
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 2024
			0.5, -- 2025
			0.5, -- 2026
			"Center", -- 2027
			isSpoken and 1.8 or 1, -- 2028
			0.98, -- 2029
			0.08 -- 2030
		) -- 2030
	end -- 2030
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 2030
		local hint = route == "child" and "按 E 再次启程   ·   Esc 暂歇" or "团圆尾声   ·   按 E 再次启程   ·   Esc 暂歇" -- 2036
		ctx.texts:put( -- 2039
			"xs", -- 2039
			hint, -- 2039
			ctx.uiW * 0.5, -- 2039
			barH * 0.5, -- 2039
			toColor(PALETTE.textMid), -- 2039
			0.5, -- 2039
			0.5, -- 2039
			"Center", -- 2039
			1.4, -- 2039
			0.88, -- 2039
			0.08 -- 2039
		) -- 2039
	end -- 2039
end -- 2003
function ____exports.createTowerEndingsPlugin() -- 2044
	return __TS__New(____exports.TowerEndingsPlugin) -- 2045
end -- 2044
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 2049
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 2050
	fe:registerPlugin(plugin) -- 2051
	return plugin -- 2052
end -- 2049
return ____exports -- 2049