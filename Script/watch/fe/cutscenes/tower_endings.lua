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
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 49
local drawComicSequence = ____slideshow.drawComicSequence -- 49
local ____theme = require("Script.watch.fe.theme") -- 50
local PALETTE = ____theme.PALETTE -- 51
local drawHairline = ____theme.drawHairline -- 53
local drawSilkVeil = ____theme.drawSilkVeil -- 54
local fillGradQuad = ____theme.fillGradQuad -- 55
local fillRadialGlow = ____theme.fillRadialGlow -- 56
local fillVGradRect = ____theme.fillVGradRect -- 57
local lerpRGBA = ____theme.lerpRGBA -- 58
local rgba = ____theme.rgba -- 59
local toColor = ____theme.toColor -- 60
--- 精确对齐后端 tower-knock(36 拍 = 0.6s, 第 0 / 12 拍敲门) 与 8.0 秒配对演出节拍
____exports.TOWER_ENDING_TIMINGS = { -- 90
	knock1Sec = 0, -- 91
	knock2Sec = 0.2, -- 92
	reply1Sec = 0.42, -- 93
	reply2Sec = 0.54, -- 94
	doorOpenSec = 0.6, -- 95
	indoorCutSec = 1.4, -- 96
	row1StartSec = 2.2, -- 97
	row1EndSec = 3.4, -- 98
	pivotStartSec = 3.4, -- 99
	pivotEndSec = 4.2, -- 100
	divergeEndSec = 6.8, -- 101
	holdReadySec = TOWER_CONFIRM_TICKS / 60 -- 102
} -- 102
local TOWER_AUDIO_ROOT = "assets/audio/tower/" -- 105
____exports.TOWER_AUDIO_FILES = { -- 107
	knock1 = TOWER_AUDIO_ROOT .. "door_knock_1.wav", -- 108
	knock2 = TOWER_AUDIO_ROOT .. "door_knock_2.wav", -- 109
	reply1 = TOWER_AUDIO_ROOT .. "door_reply_1.wav", -- 110
	reply2 = TOWER_AUDIO_ROOT .. "door_reply_2.wav", -- 111
	doorOpen = TOWER_AUDIO_ROOT .. "door_open.wav", -- 112
	bookOpen = TOWER_AUDIO_ROOT .. "book_open.wav", -- 113
	brush1 = TOWER_AUDIO_ROOT .. "brush_write_1.wav", -- 114
	brush2 = TOWER_AUDIO_ROOT .. "brush_write_2.wav", -- 115
	lampMove = TOWER_AUDIO_ROOT .. "lamp_move.wav", -- 116
	needlePlace = TOWER_AUDIO_ROOT .. "needle_case_place.wav", -- 117
	bowlSet = TOWER_AUDIO_ROOT .. "bowl_set.wav", -- 118
	windCold = TOWER_AUDIO_ROOT .. "tower_wind_cold.wav", -- 119
	roomWarm = TOWER_AUDIO_ROOT .. "tower_room_warm.wav", -- 120
	lineXiaomanLamp = TOWER_AUDIO_ROOT .. "line_xiaoman_lamp.wav", -- 121
	lineZhoushuName = TOWER_AUDIO_ROOT .. "line_zhoushu_name.wav" -- 122
} -- 122
--- 同机位配对布局真源（基准 1280×720 逻辑坐标系，F03 与 M03 100% 共享）：
-- 保证两版并排对照时门扇、门槛、提灯、西窗、簿页、一/二行基线、悬停笔尖、案沿热碗 0.00 px 偏差。
____exports.TOWER_SHOT_LAYOUT = { -- 129
	refW = 1280, -- 130
	refH = 720, -- 131
	letterboxH = 60, -- 132
	doorCenterX = 640, -- 134
	thresholdY = 168, -- 135
	doorW = 248, -- 136
	doorH = 374, -- 137
	knockHandX = 574, -- 138
	knockHandY = 312, -- 139
	doorLanternX = 710, -- 140
	doorLanternY = 344, -- 141
	westWindowX = 88, -- 143
	westWindowY = 382, -- 144
	westWindowW = 236, -- 145
	westWindowH = 224, -- 146
	deskTopY = 260, -- 147
	lampDeskX = 356, -- 148
	lampDeskY = 332, -- 149
	lampWindowX = 206, -- 150
	lampWindowY = 422, -- 151
	bookX = 416, -- 152
	bookY = 196, -- 153
	bookW = 588, -- 154
	bookH = 386, -- 155
	row1Y = 454, -- 156
	row1SubY = 424, -- 157
	row2Y = 354, -- 158
	row2SubY = 324, -- 159
	brushHoverTipX = 556, -- 160
	brushHoverTipY = 358, -- 161
	needleCaseDeskX = 294, -- 162
	needleCaseDeskY = 204, -- 163
	bowlRimX = 954, -- 164
	bowlRimY = 184, -- 165
	inkstoneX = 1112, -- 166
	inkstoneY = 256 -- 167
} -- 167
local F03_DIALOGUE = "「朝西那盏灯，能留着吗？」" -- 229
local M03_DIALOGUE = "「周戍。」" -- 230
--- F03 / M03 北塔门廊同机位配对硬核漫画拍表（0.00..0.60s 门外两叩 → 0.60..1.40s 推门提灯）
local F03_PORCH_COMIC_SEQ = {{ -- 233
	slot = "comic_tower_f03_porch_01_knock", -- 234
	start = 0, -- 234
	["end"] = 0.6, -- 234
	zoomFrom = 1, -- 234
	zoomTo = 1.012, -- 234
	transition = "cut" -- 234
}, { -- 234
	slot = "comic_tower_f03_porch_02_open", -- 235
	start = 0.6, -- 235
	["end"] = 1.5, -- 235
	zoomFrom = 1.008, -- 235
	zoomTo = 1.02, -- 235
	transition = "cut" -- 235
}} -- 235
local M03_PORCH_COMIC_SEQ = {{ -- 237
	slot = "comic_tower_m03_porch_01_knock", -- 238
	start = 0, -- 238
	["end"] = 0.6, -- 238
	zoomFrom = 1, -- 238
	zoomTo = 1.012, -- 238
	transition = "cut" -- 238
}, { -- 238
	slot = "comic_tower_m03_porch_02_open", -- 239
	start = 0.6, -- 239
	["end"] = 1.5, -- 239
	zoomFrom = 1.008, -- 239
	zoomTo = 1.02, -- 239
	transition = "cut" -- 239
}} -- 239
--- F03 拂晓冷室灯光预设（挪灯前），向 TOWER_WEST_LAMP_LIGHT（西窗暖灯）平滑插值
local TOWER_COLD_DAWN_LIGHT = { -- 243
	keyDir = normalize3(vec3(-0.34, 0.72, -0.6)), -- 244
	keyColor = rgba(146, 174, 206, 255), -- 245
	keyStrength = 0.74, -- 246
	rimDir = normalize3(vec3(0.68, 0.44, -0.58)), -- 247
	rimColor = rgba(182, 166, 140, 255), -- 248
	rimStrength = 0.24, -- 249
	ambientColor = rgba(18, 24, 38, 255), -- 250
	fogColor = rgba(16, 22, 34, 255), -- 251
	fogStartZ = 50, -- 252
	fogEndZ = 460, -- 253
	fogMaxAlpha = 0.78, -- 254
	shadowContrast = 0.78 -- 255
} -- 255
local function lerp(a, b, t) -- 258
	return a + (b - a) * t -- 259
end -- 258
local function lerpLightRig(a, b, t) -- 262
	local k = clamp01(t) -- 263
	return { -- 264
		keyDir = normalize3(vec3( -- 265
			lerp(a.keyDir.x, b.keyDir.x, k), -- 266
			lerp(a.keyDir.y, b.keyDir.y, k), -- 267
			lerp(a.keyDir.z, b.keyDir.z, k) -- 268
		)), -- 268
		keyColor = lerpRGBA(a.keyColor, b.keyColor, k), -- 270
		keyStrength = lerp(a.keyStrength, b.keyStrength, k), -- 271
		rimDir = normalize3(vec3( -- 272
			lerp(a.rimDir.x, b.rimDir.x, k), -- 273
			lerp(a.rimDir.y, b.rimDir.y, k), -- 274
			lerp(a.rimDir.z, b.rimDir.z, k) -- 275
		)), -- 275
		rimColor = lerpRGBA(a.rimColor, b.rimColor, k), -- 277
		rimStrength = lerp(a.rimStrength, b.rimStrength, k), -- 278
		ambientColor = lerpRGBA(a.ambientColor, b.ambientColor, k), -- 279
		fogColor = lerpRGBA(a.fogColor, b.fogColor, k), -- 280
		fogStartZ = lerp(a.fogStartZ, b.fogStartZ, k), -- 281
		fogEndZ = lerp(a.fogEndZ, b.fogEndZ, k), -- 282
		fogMaxAlpha = lerp(a.fogMaxAlpha, b.fogMaxAlpha, k), -- 283
		shadowContrast = lerp(a.shadowContrast, b.shadowContrast, k) -- 284
	} -- 284
end -- 262
local function computeScaledAnchors(uiW, uiH, lampProg) -- 288
	local s = math.min(uiW / ____exports.TOWER_SHOT_LAYOUT.refW, uiH / ____exports.TOWER_SHOT_LAYOUT.refH) -- 294
	local ox = (uiW - ____exports.TOWER_SHOT_LAYOUT.refW * s) * 0.5 -- 295
	local oy = (uiH - ____exports.TOWER_SHOT_LAYOUT.refH * s) * 0.5 -- 296
	local lx = lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) -- 297
	local ly = lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34 -- 298
	return {s = s, ox = ox, oy = oy, anchors = { -- 300
		doorCenterX = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s, -- 305
		thresholdY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s, -- 306
		knockHandX = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s, -- 307
		knockHandY = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s, -- 308
		bookX = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s, -- 309
		bookY = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s, -- 310
		bookW = ____exports.TOWER_SHOT_LAYOUT.bookW * s, -- 311
		bookH = ____exports.TOWER_SHOT_LAYOUT.bookH * s, -- 312
		row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s, -- 313
		row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s, -- 314
		brushHoverTipX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s, -- 315
		brushHoverTipY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s, -- 316
		bowlRimX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s, -- 317
		bowlRimY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s, -- 318
		lampCurX = ox + lx * s, -- 319
		lampCurY = oy + ly * s -- 320
	}} -- 320
end -- 288
local function deriveStage(seqElapsed, active) -- 325
	if not active then -- 325
		return "idle" -- 327
	end -- 327
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 327
		return "porch_knock" -- 330
	end -- 330
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 330
		return "door_open" -- 333
	end -- 333
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 333
		return "book_row1" -- 336
	end -- 336
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 336
		return "pivot_hover" -- 339
	end -- 339
	if seqElapsed < ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 339
		return "diverge_action" -- 342
	end -- 342
	return "ending_hold" -- 344
end -- 325
--- 将字符切片数组按进度拼接为前 n 段（避免 Lua 字节切片截断 UTF-8 汉字）
local function joinPrefixTokens(tokens, progress) -- 348
	if progress <= 0 or #tokens == 0 then -- 348
		return "" -- 350
	end -- 350
	local count = math.max( -- 352
		1, -- 352
		math.min( -- 352
			#tokens, -- 352
			math.ceil(progress * #tokens) -- 352
		) -- 352
	) -- 352
	local out = "" -- 353
	local i = 0 -- 354
	do -- 354
		i = 0 -- 355
		while i < count do -- 355
			out = out .. tokens[i + 1] -- 356
			i = i + 1 -- 355
		end -- 355
	end -- 355
	return out -- 358
end -- 348
local ROW1_TOKENS = { -- 361
	"小", -- 361
	"满", -- 361
	"  ", -- 361
	"·", -- 361
	"  ", -- 361
	"已", -- 361
	"收" -- 361
} -- 361
local ROW2_SOLDIER_TOKENS = { -- 362
	"周", -- 362
	"戍", -- 362
	"  ", -- 362
	"·", -- 362
	"  ", -- 362
	"兄", -- 362
	"妹", -- 362
	"同", -- 362
	"行", -- 362
	"  ", -- 362
	"·", -- 362
	"  ", -- 362
	"已", -- 362
	"收" -- 362
} -- 362
local function asRecord(v) -- 364
	if v ~= nil and type(v) == "table" then -- 364
		return v -- 366
	end -- 366
	return nil -- 368
end -- 364
--- 描边椭圆（Dora DrawNode.drawEllipse 仅支持填充，描边用等分折线保证锐利清晰）
local function strokeEllipse(draw, cx, cy, rx, ry, width, color, segments) -- 372
	if segments == nil then -- 372
		segments = 24 -- 380
	end -- 380
	if rx <= 0.5 or ry <= 0.5 or width <= 0.05 then -- 380
		return -- 383
	end -- 383
	local step = math.pi * 2 / segments -- 385
	local prevX = cx + rx -- 386
	local prevY = cy -- 387
	local i = 1 -- 388
	do -- 388
		i = 1 -- 389
		while i <= segments do -- 389
			local ang = i * step -- 390
			local nx = cx + math.cos(ang) * rx -- 391
			local ny = cy + math.sin(ang) * ry -- 392
			draw:drawSegment( -- 393
				Vec2(prevX, prevY), -- 393
				Vec2(nx, ny), -- 393
				width, -- 393
				color -- 393
			) -- 393
			prevX = nx -- 394
			prevY = ny -- 395
			i = i + 1 -- 389
		end -- 389
	end -- 389
end -- 372
local STONE_EDGE_FALLBACK = MING_MATERIALS.mingStoneStep.edge or PALETTE.silkDim -- 399
____exports.TowerEndingsPlugin = __TS__Class() -- 401
local TowerEndingsPlugin = ____exports.TowerEndingsPlugin -- 401
TowerEndingsPlugin.name = "TowerEndingsPlugin" -- 401
function TowerEndingsPlugin.prototype.____constructor(self) -- 401
	self.id = "fe-05-tower-endings" -- 402
	self.active = false -- 404
	self.rehearsalActive = false -- 405
	self.rehearsalRoute = "child" -- 406
	self.activeRoute = "child" -- 407
	self.seqElapsed = 0 -- 409
	self.holdElapsed = 0 -- 410
	self.animTime = 0 -- 411
	self.doorOpened = false -- 414
	self.knockCount = 0 -- 415
	self.replyKnockCount = 0 -- 416
	self.row1Written = false -- 417
	self.row2Written = false -- 418
	self.registryAppendCount = 0 -- 419
	self.staleInputMustRelease = false -- 422
	self.confirmReady = false -- 423
	self.earlyInputBlockedCount = 0 -- 424
	self.rehearsalAcknowledged = false -- 425
	self.lastRoomKey = "" -- 428
	self.indoorRetryCount = 0 -- 430
	self.doorClosedAfterRetry = false -- 431
	self.sessionId = 0 -- 432
	self.lastUiW = 1280 -- 435
	self.lastUiH = 720 -- 436
	self.lastSubtitle = "" -- 437
	self.prevPhase = "" -- 438
	self.loopsActive = false -- 439
	self.doorOpenOverlayElapsed = -1 -- 441
end -- 401
function TowerEndingsPlugin.prototype.resolveRoute(self, p, view) -- 444
	if self.rehearsalActive then -- 444
		return self.rehearsalRoute -- 446
	end -- 446
	if view.storyRoute == "soldier" then -- 446
		return "soldier" -- 449
	end -- 449
	if view.storyRoute == "child" then -- 449
		return "child" -- 452
	end -- 452
	local runRec = asRecord(p.run) -- 455
	local ____asRecord_1 = asRecord -- 456
	local ____temp_0 -- 456
	if runRec ~= nil then -- 456
		____temp_0 = runRec.story -- 456
	else -- 456
		____temp_0 = nil -- 456
	end -- 456
	local storyRec = ____asRecord_1(____temp_0) -- 456
	if storyRec ~= nil and storyRec.ending == "reunion" then -- 456
		return "soldier" -- 458
	end -- 458
	return p.childMode and "child" or "soldier" -- 461
end -- 444
function TowerEndingsPlugin.prototype.clearSequenceState(self, keepIndoorDoorOpen) -- 464
	self.active = keepIndoorDoorOpen -- 465
	self.seqElapsed = keepIndoorDoorOpen and ____exports.TOWER_ENDING_TIMINGS.indoorCutSec or 0 -- 466
	self.holdElapsed = 0 -- 467
	self.doorOpened = keepIndoorDoorOpen -- 468
	self.knockCount = keepIndoorDoorOpen and 2 or 0 -- 469
	self.replyKnockCount = keepIndoorDoorOpen and 2 or 0 -- 470
	if not keepIndoorDoorOpen then -- 470
		self.row1Written = false -- 472
		self.row2Written = false -- 473
		self.registryAppendCount = 0 -- 474
	end -- 474
	self.staleInputMustRelease = true -- 476
	self.confirmReady = false -- 477
	self.earlyInputBlockedCount = 0 -- 478
	self.rehearsalAcknowledged = false -- 479
	self.lastSubtitle = "" -- 480
	self.doorOpenOverlayElapsed = -1 -- 481
end -- 464
function TowerEndingsPlugin.prototype.startRehearsal(self, route, contract, opts) -- 487
	self.rehearsalActive = true -- 492
	self.rehearsalRoute = route -- 493
	self.activeRoute = route -- 494
	local tag = opts and opts.tag or (route == "child" and "fe05-F03" or "fe05-M03") -- 495
	if contract ~= nil then -- 495
		contract:enterRehearsal(tag) -- 497
		contract:setMockRoute(route) -- 498
	end -- 498
	local isIndoor = (opts and opts.indoorRetry) == true -- 500
	self.sessionId = self.sessionId + 1 -- 501
	self:clearSequenceState(isIndoor) -- 502
	self.active = true -- 503
	self.doorClosedAfterRetry = false -- 504
	if isIndoor then -- 504
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 506
	end -- 506
	if (opts and opts.seekTime) ~= nil then -- 506
		self:seekRehearsal(opts.seekTime) -- 509
	end -- 509
end -- 487
function TowerEndingsPlugin.prototype.seekRehearsal(self, seconds) -- 514
	if not self.rehearsalActive then -- 514
		return -- 516
	end -- 516
	local t = math.max(0, seconds) -- 518
	self.seqElapsed = t -- 519
	self.holdElapsed = math.max(0, t - ____exports.TOWER_ENDING_TIMINGS.divergeEndSec) -- 520
	self.active = true -- 521
	self:syncDerivedMilestones(t, self.activeRoute) -- 522
	self.confirmReady = not self.staleInputMustRelease and t >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 523
end -- 514
function TowerEndingsPlugin.prototype.triggerIndoorRetry(self) -- 527
	if not self.doorOpened and self.seqElapsed < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 527
		self.doorOpened = true -- 529
	end -- 529
	self.indoorRetryCount = self.indoorRetryCount + 1 -- 531
	self.doorClosedAfterRetry = false -- 532
	self.doorOpened = true -- 533
	self.active = true -- 534
	self.seqElapsed = math.max( -- 535
		____exports.TOWER_ENDING_TIMINGS.indoorCutSec, -- 535
		math.min(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.row1StartSec) -- 535
	) -- 535
	self.holdElapsed = 0 -- 536
	self.knockCount = math.max(2, self.knockCount) -- 537
	self.replyKnockCount = math.max(2, self.replyKnockCount) -- 538
	self.staleInputMustRelease = true -- 540
	self.confirmReady = false -- 541
end -- 527
function TowerEndingsPlugin.prototype.stopRehearsal(self, contract) -- 545
	self.rehearsalActive = false -- 546
	self:clearSequenceState(false) -- 547
	self.indoorRetryCount = 0 -- 548
	self.doorClosedAfterRetry = false -- 549
	if contract ~= nil then -- 549
		contract:exitRehearsal() -- 551
	end -- 551
end -- 545
function TowerEndingsPlugin.prototype.getDebugState(self) -- 555
	local route = self.activeRoute -- 556
	local lampProg = route == "child" and smoothstep(5.2, 6.75, self.seqElapsed) or 0 -- 557
	local scaled = computeScaledAnchors(self.lastUiW, self.lastUiH, lampProg) -- 560
	local visualStyle = route == "child" and "lowpoly" or "pixel" -- 561
	local needleOnDesk = route == "soldier" and self.seqElapsed >= 5.55 -- 562
	local twoHandsBowl = route == "soldier" and self.seqElapsed >= 5.95 -- 563
	return { -- 565
		active = self.active, -- 566
		isRehearsal = self.rehearsalActive, -- 567
		route = route, -- 568
		visualStyle = visualStyle, -- 569
		stage = deriveStage(self.seqElapsed, self.active), -- 570
		seqElapsed = self.seqElapsed, -- 571
		holdElapsed = self.holdElapsed, -- 572
		doorOpened = self.doorOpened, -- 573
		knockCount = self.knockCount, -- 574
		replyKnockCount = self.replyKnockCount, -- 575
		row1Written = self.row1Written, -- 576
		row1Name = self.row1Written and "小满" or "", -- 577
		row2Written = self.row2Written, -- 578
		row2Name = self.row2Written and "周戍" or "", -- 579
		row2Blank = not self.row2Written, -- 580
		hasCompletionStamp = false, -- 581
		registryRowCapacity = 2, -- 582
		registryAppendCount = self.registryAppendCount, -- 583
		lampProgress = lampProg, -- 584
		lampAtWestWindow = route == "child" and lampProg >= 0.99, -- 585
		needleCaseOnDesk = needleOnDesk, -- 586
		twoHandsHoldingBowl = twoHandsBowl, -- 587
		staleInputMustRelease = self.staleInputMustRelease, -- 588
		confirmReady = self.confirmReady, -- 589
		earlyInputBlockedCount = self.earlyInputBlockedCount, -- 590
		rehearsalAcknowledged = self.rehearsalAcknowledged, -- 591
		indoorRetryCount = self.indoorRetryCount, -- 592
		doorClosedAfterRetry = self.doorClosedAfterRetry, -- 593
		subtitleText = self.lastSubtitle, -- 594
		anchors = scaled.anchors -- 595
	} -- 595
end -- 555
function TowerEndingsPlugin.prototype.syncRuntimeHook(self) -- 599
	local g = _G -- 600
	local ____temp_8 -- 601
	if g.package ~= nil then -- 601
		____temp_8 = g.package.loaded -- 601
	else -- 601
		____temp_8 = nil -- 601
	end -- 601
	local loaded = ____temp_8 -- 601
	if loaded == nil then -- 601
		return -- 603
	end -- 603
	local rawFe = loaded["watch.fe"] -- 605
	if rawFe ~= nil and type(rawFe) == "table" then -- 605
		local watchFe = rawFe -- 607
		if watchFe.towerEndings ~= self then -- 607
			watchFe.towerEndings = self -- 609
		end -- 609
	end -- 609
end -- 599
function TowerEndingsPlugin.prototype.onBindPlay(self, p, view) -- 616
	self:syncRuntimeHook() -- 617
	self.sessionId = self.sessionId + 1 -- 618
	self.loopsActive = false -- 619
	self.prevPhase = p.phase -- 620
	if self.rehearsalActive then -- 620
		return -- 623
	end -- 623
	local route = self:resolveRoute(p, view) -- 626
	local isTower = p.room.key == "tower" -- 627
	local alreadyCutscenePhase = isTower and (p.phase == "tower-given" or p.phase == "tower-end") -- 628
	local alreadyIndoorPhase = isTower and (p.phase == "tower-enter" or p.phase == "tower-desk" or alreadyCutscenePhase) -- 629
	local sameRunIndoorRetry = isTower and self.lastRoomKey == "tower" and self.doorOpened and p.run == self.lastRunRef and route == self.activeRoute and (p.checkpoint > 0 or alreadyIndoorPhase) -- 634
	self.activeRoute = route -- 641
	self.lastRoomKey = p.room.key -- 642
	self.lastRunRef = p.run -- 643
	if not isTower then -- 643
		self:clearSequenceState(false) -- 646
		self.indoorRetryCount = 0 -- 647
		self.doorClosedAfterRetry = false -- 648
		return -- 649
	end -- 649
	if sameRunIndoorRetry or alreadyCutscenePhase then -- 649
		self.indoorRetryCount = self.indoorRetryCount + 1 -- 654
		self.doorClosedAfterRetry = false -- 655
		self:clearSequenceState(true) -- 656
		if p.phase == "tower-end" then -- 656
			self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.divergeEndSec -- 658
			self:syncDerivedMilestones(self.seqElapsed, route) -- 659
		end -- 659
		return -- 661
	end -- 661
	if p.phase == "tower-enter" or p.phase == "tower-desk" then -- 661
		self:clearSequenceState(false) -- 666
		self.doorOpened = true -- 667
		self.replyKnockCount = 2 -- 668
		self.active = false -- 669
		return -- 670
	end -- 670
	self:clearSequenceState(false) -- 674
	self.indoorRetryCount = 0 -- 675
	self.doorClosedAfterRetry = false -- 676
end -- 616
function TowerEndingsPlugin.prototype.update(self, ctx) -- 679
	self:syncRuntimeHook() -- 680
	self.lastUiW = ctx.uiW -- 681
	self.lastUiH = ctx.uiH -- 682
	local p = ctx.p -- 683
	if not self.rehearsalActive and p.room.key ~= "tower" then -- 683
		if self.loopsActive then -- 683
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 687
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 688
			self.loopsActive = false -- 689
		end -- 689
		self.active = false -- 691
		return -- 692
	end -- 692
	local route = self:resolveRoute(p, ctx.view) -- 695
	self.activeRoute = route -- 696
	if not self.rehearsalActive then -- 696
		self:stepLiveSync(ctx, route) -- 699
	else -- 699
		self:stepRehearsal(ctx, route) -- 701
	end -- 701
	if not self.active then -- 701
		local inInteractiveHall = not self.rehearsalActive and p.room.key == "tower" and (p.phase == "tower-enter" or p.phase == "tower-desk") -- 705
		if self.loopsActive and not inInteractiveHall then -- 705
			ctx.audio:stopLoop("tower_wind_cold", 0.15) -- 708
			ctx.audio:stopLoop("tower_room_warm", 0.15) -- 709
			self.loopsActive = false -- 710
		end -- 710
		return -- 712
	end -- 712
	if not ctx.paused and ctx.worldDt > 0 then -- 712
		self.animTime = self.animTime + ctx.worldDt -- 717
		self:syncDerivedMilestones(self.seqElapsed, route) -- 718
		self:syncAudioCues(ctx.audio, ctx, route) -- 719
		self:stepInputGuard(ctx.input) -- 720
	elseif not ctx.paused then -- 720
		self:syncDerivedMilestones(self.seqElapsed, route) -- 723
		self:stepInputGuard(ctx.input) -- 724
	end -- 724
	self.lastSubtitle = self:composeSubtitle(route) -- 727
end -- 679
function TowerEndingsPlugin.prototype.stepLiveSync(self, ctx, route) -- 730
	local p = ctx.p -- 731
	local phase = p.phase -- 732
	local cameFromKnock = self.prevPhase == "tower-knock" -- 733
	local justEnteredKnock = self.prevPhase ~= "tower-knock" and phase == "tower-knock" -- 734
	local justEnteredEnter = self.prevPhase ~= "tower-enter" and phase == "tower-enter" -- 735
	local justEnteredGiven = self.prevPhase ~= "tower-given" and phase == "tower-given" -- 736
	local justEnteredEnd = self.prevPhase ~= "tower-end" and phase == "tower-end" -- 737
	self.prevPhase = phase -- 738
	if phase == "tower-wait" then -- 738
		self.doorOpenOverlayElapsed = -1 -- 742
		self.active = false -- 743
		return -- 744
	end -- 744
	if phase == "tower-enter" then -- 744
		self.doorOpened = true -- 749
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 750
		if justEnteredEnter and self.indoorRetryCount == 0 and not ctx.paused then -- 750
			local tick = p.ticks -- 752
			self:playTowerOnce( -- 753
				ctx.audio, -- 753
				"reply1", -- 753
				"sfx", -- 753
				____exports.TOWER_AUDIO_FILES.reply1, -- 753
				0.78, -- 753
				"tower:reply:1", -- 753
				tick -- 753
			) -- 753
			self:playTowerOnce( -- 754
				ctx.audio, -- 754
				"reply2", -- 754
				"sfx", -- 754
				____exports.TOWER_AUDIO_FILES.reply2, -- 754
				0.8, -- 754
				"tower:reply:2", -- 754
				tick -- 754
			) -- 754
			self:playTowerOnce( -- 755
				ctx.audio, -- 755
				"door_open", -- 755
				"sfx", -- 755
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 755
				0.84, -- 755
				"tower:door_open", -- 755
				tick -- 755
			) -- 755
			ctx.audio:playLoop( -- 756
				"tower_room_warm", -- 756
				"ambience", -- 756
				____exports.TOWER_AUDIO_FILES.roomWarm, -- 756
				0.28, -- 756
				tick -- 756
			) -- 756
			self.loopsActive = true -- 757
			if cameFromKnock then -- 757
				self.doorOpenOverlayElapsed = 0 -- 759
			end -- 759
		end -- 759
		if self.doorOpenOverlayElapsed >= 0 then -- 759
			if p.player.x >= p.ox + 520 then -- 759
				self.doorOpenOverlayElapsed = -1 -- 764
			elseif not ctx.paused and ctx.worldDt > 0 then -- 764
				self.doorOpenOverlayElapsed = self.doorOpenOverlayElapsed + ctx.worldDt -- 766
				if self.doorOpenOverlayElapsed >= 0.9 then -- 766
					self.doorOpenOverlayElapsed = -1 -- 768
				end -- 768
			end -- 768
		end -- 768
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.doorOpenSec) -- 772
		self.active = false -- 773
		self:syncDerivedMilestones(self.seqElapsed, route) -- 774
		return -- 775
	end -- 775
	if phase == "tower-desk" then -- 775
		self.doorOpenOverlayElapsed = -1 -- 780
		self.doorOpened = true -- 781
		self.replyKnockCount = math.max(2, self.replyKnockCount) -- 782
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 783
		self.active = false -- 784
		self:syncDerivedMilestones(self.seqElapsed, route) -- 785
		return -- 786
	end -- 786
	if not self.active then -- 786
		self.active = true -- 790
		self.staleInputMustRelease = ctx.input.interact.held or ctx.input.retry.held or ctx.input.interact.pressed -- 791
		self.confirmReady = false -- 792
	end -- 792
	if justEnteredKnock then -- 792
		self.seqElapsed = p.phaseTick / 60 -- 796
		self.holdElapsed = 0 -- 797
		self.staleInputMustRelease = true -- 798
		self.confirmReady = false -- 799
	elseif justEnteredGiven then -- 799
		self.doorOpened = true -- 801
		self.seqElapsed = math.max(self.seqElapsed, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec) -- 802
	elseif justEnteredEnd then -- 802
		self.doorOpened = true -- 804
		self.seqElapsed = math.max(self.seqElapsed, 3.6 + p.phaseTick / 60) -- 806
	end -- 806
	if not ctx.paused and #ctx.events.rawEvents > 0 then -- 806
		local i = 0 -- 811
		do -- 811
			i = 0 -- 812
			while i < #ctx.events.rawEvents do -- 812
				local ev = ctx.events.rawEvents[i + 1] -- 813
				if ev.name == "knock" then -- 813
					local cnt = type(ev.data.count) == "number" and ev.data.count or self.knockCount + 1 -- 815
					if cnt >= 1 and self.knockCount < 1 then -- 815
						self.knockCount = 1 -- 817
						self:playTowerOnce( -- 818
							ctx.audio, -- 818
							"knock1", -- 818
							"sfx", -- 818
							____exports.TOWER_AUDIO_FILES.knock1, -- 818
							0.88, -- 818
							"tower:knock:1", -- 818
							ev.tick, -- 818
							ev.seq -- 818
						) -- 818
					end -- 818
					if cnt >= 2 and self.knockCount < 2 then -- 818
						self.knockCount = 2 -- 821
						self:playTowerOnce( -- 822
							ctx.audio, -- 822
							"knock2", -- 822
							"sfx", -- 822
							____exports.TOWER_AUDIO_FILES.knock2, -- 822
							0.9, -- 822
							"tower:knock:2", -- 822
							ev.tick, -- 822
							ev.seq -- 822
						) -- 822
					end -- 822
				end -- 822
				i = i + 1 -- 812
			end -- 812
		end -- 812
	end -- 812
	if not ctx.paused and ctx.worldDt > 0 then -- 812
		if phase == "tower-knock" then -- 812
			local backendSec = math.min(____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001, p.phaseTick / 60) -- 831
			self.seqElapsed = math.max(self.seqElapsed + ctx.worldDt, backendSec) -- 832
			if self.seqElapsed > ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 then -- 832
				self.seqElapsed = ____exports.TOWER_ENDING_TIMINGS.doorOpenSec - 0.001 -- 834
			end -- 834
		else -- 834
			self.seqElapsed = self.seqElapsed + ctx.worldDt -- 837
			if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 837
				self.holdElapsed = self.holdElapsed + ctx.worldDt -- 839
			end -- 839
		end -- 839
	end -- 839
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 839
		self.doorClosedAfterRetry = true -- 845
	end -- 845
	self:syncDerivedMilestones(self.seqElapsed, route) -- 847
end -- 730
function TowerEndingsPlugin.prototype.stepRehearsal(self, ctx, route) -- 850
	self.active = true -- 851
	if not ctx.paused and ctx.worldDt > 0 then -- 851
		self.seqElapsed = self.seqElapsed + ctx.worldDt -- 853
		if self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.divergeEndSec then -- 853
			self.holdElapsed = self.holdElapsed + ctx.worldDt -- 855
		end -- 855
	end -- 855
	if self.indoorRetryCount > 0 and not self.doorOpened then -- 855
		self.doorClosedAfterRetry = true -- 859
	end -- 859
	self:syncDerivedMilestones(self.seqElapsed, route) -- 861
end -- 850
function TowerEndingsPlugin.prototype.syncDerivedMilestones(self, t, route) -- 864
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec and self.knockCount < 1 then -- 864
		self.knockCount = 1 -- 866
	end -- 866
	if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec and self.knockCount < 2 then -- 866
		self.knockCount = 2 -- 869
	end -- 869
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec and self.replyKnockCount < 1 then -- 869
		self.replyKnockCount = 1 -- 872
	end -- 872
	if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec and self.replyKnockCount < 2 then -- 872
		self.replyKnockCount = 2 -- 875
	end -- 875
	if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 875
		self.doorOpened = true -- 878
	end -- 878
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec and not self.row1Written then -- 878
		self.row1Written = true -- 882
		self.registryAppendCount = self.registryAppendCount + 1 -- 883
	end -- 883
	if route == "soldier" and t >= 4.6 and not self.row2Written then -- 883
		self.row2Written = true -- 886
		self.registryAppendCount = self.registryAppendCount + 1 -- 887
	end -- 887
	if route == "child" and self.row2Written then -- 887
		self.row2Written = false -- 891
		self.registryAppendCount = self.row1Written and 1 or 0 -- 892
	end -- 892
end -- 864
function TowerEndingsPlugin.prototype.stepInputGuard(self, input) -- 896
	local keyHeld = input.interact.held or input.retry.held -- 897
	local keyPressed = input.interact.pressed or input.retry.pressed -- 898
	local readyTime = self.seqElapsed >= ____exports.TOWER_ENDING_TIMINGS.holdReadySec -- 899
	if self.staleInputMustRelease then -- 899
		if not keyHeld then -- 899
			self.staleInputMustRelease = false -- 903
		elseif keyPressed then -- 903
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 905
		end -- 905
		self.confirmReady = false -- 907
		return -- 908
	end -- 908
	if not readyTime then -- 908
		if keyPressed then -- 908
			self.earlyInputBlockedCount = self.earlyInputBlockedCount + 1 -- 913
			self.staleInputMustRelease = keyHeld -- 914
		end -- 914
		self.confirmReady = false -- 916
		return -- 917
	end -- 917
	self.confirmReady = true -- 920
	if self.rehearsalActive and keyPressed then -- 920
		self.rehearsalAcknowledged = true -- 922
	end -- 922
end -- 896
function TowerEndingsPlugin.prototype.playTowerOnce(self, audio, tag, track, path, volume, cueId, tick, seq) -- 926
	if seq == nil then -- 926
		seq = -1 -- 934
	end -- 934
	local dedupeKey = (("tower:s" .. tostring(self.sessionId)) .. ":") .. tag -- 936
	audio:playOnce( -- 937
		dedupeKey, -- 937
		track, -- 937
		path, -- 937
		volume, -- 937
		cueId, -- 937
		tick, -- 937
		seq -- 937
	) -- 937
end -- 926
function TowerEndingsPlugin.prototype.syncAudioCues(self, audio, ctx, route) -- 940
	local t = self.seqElapsed -- 941
	local tick = ctx.p.ticks -- 942
	local indoorK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.5, t) -- 943
	self.loopsActive = true -- 946
	audio:playLoop( -- 947
		"tower_wind_cold", -- 947
		"wind", -- 947
		____exports.TOWER_AUDIO_FILES.windCold, -- 947
		lerp(0.36, 0.14, indoorK), -- 947
		tick -- 947
	) -- 947
	if indoorK > 0.05 then -- 947
		audio:playLoop( -- 949
			"tower_room_warm", -- 949
			"ambience", -- 949
			____exports.TOWER_AUDIO_FILES.roomWarm, -- 949
			lerp(0.06, 0.34, indoorK), -- 949
			tick -- 949
		) -- 949
	end -- 949
	if self.indoorRetryCount == 0 then -- 949
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock1Sec then -- 949
			self:playTowerOnce( -- 955
				audio, -- 955
				"knock1", -- 955
				"sfx", -- 955
				____exports.TOWER_AUDIO_FILES.knock1, -- 955
				0.88, -- 955
				"tower:knock:1", -- 955
				tick -- 955
			) -- 955
		end -- 955
		if t >= ____exports.TOWER_ENDING_TIMINGS.knock2Sec then -- 955
			self:playTowerOnce( -- 958
				audio, -- 958
				"knock2", -- 958
				"sfx", -- 958
				____exports.TOWER_AUDIO_FILES.knock2, -- 958
				0.9, -- 958
				"tower:knock:2", -- 958
				tick -- 958
			) -- 958
		end -- 958
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 958
			self:playTowerOnce( -- 961
				audio, -- 961
				"reply1", -- 961
				"sfx", -- 961
				____exports.TOWER_AUDIO_FILES.reply1, -- 961
				0.78, -- 961
				"tower:reply:1", -- 961
				tick -- 961
			) -- 961
		end -- 961
		if t >= ____exports.TOWER_ENDING_TIMINGS.reply2Sec then -- 961
			self:playTowerOnce( -- 964
				audio, -- 964
				"reply2", -- 964
				"sfx", -- 964
				____exports.TOWER_AUDIO_FILES.reply2, -- 964
				0.8, -- 964
				"tower:reply:2", -- 964
				tick -- 964
			) -- 964
		end -- 964
		if t >= ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 964
			self:playTowerOnce( -- 967
				audio, -- 967
				"door_open", -- 967
				"sfx", -- 967
				____exports.TOWER_AUDIO_FILES.doorOpen, -- 967
				0.84, -- 967
				"tower:door_open", -- 967
				tick -- 967
			) -- 967
		end -- 967
	end -- 967
	if t >= 1.5 then -- 967
		self:playTowerOnce( -- 972
			audio, -- 972
			"book_open", -- 972
			"sfx", -- 972
			____exports.TOWER_AUDIO_FILES.bookOpen, -- 972
			0.82, -- 972
			"tower:book_open", -- 972
			tick -- 972
		) -- 972
	end -- 972
	if t >= ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 972
		self:playTowerOnce( -- 975
			audio, -- 975
			"brush1", -- 975
			"sfx", -- 975
			____exports.TOWER_AUDIO_FILES.brush1, -- 975
			0.8, -- 975
			"tower:brush:row1", -- 975
			tick -- 975
		) -- 975
	end -- 975
	if route == "child" then -- 975
		if t >= 4.35 then -- 975
			self:playTowerOnce( -- 980
				audio, -- 980
				"f03_line", -- 980
				"voice", -- 980
				____exports.TOWER_AUDIO_FILES.lineXiaomanLamp, -- 980
				0.86, -- 980
				"tower:f03:line_lamp", -- 980
				tick -- 980
			) -- 980
		end -- 980
		if t >= 4.45 then -- 980
			self:playTowerOnce( -- 983
				audio, -- 983
				"f03_bowl", -- 983
				"sfx", -- 983
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 983
				0.8, -- 983
				"tower:bowl_set", -- 983
				tick -- 983
			) -- 983
		end -- 983
		if t >= 5.2 then -- 983
			self:playTowerOnce( -- 986
				audio, -- 986
				"f03_lamp", -- 986
				"sfx", -- 986
				____exports.TOWER_AUDIO_FILES.lampMove, -- 986
				0.82, -- 986
				"tower:f03:lamp_move", -- 986
				tick -- 986
			) -- 986
		end -- 986
	else -- 986
		if t >= 4.28 then -- 986
			self:playTowerOnce( -- 990
				audio, -- 990
				"m03_line", -- 990
				"voice", -- 990
				____exports.TOWER_AUDIO_FILES.lineZhoushuName, -- 990
				0.9, -- 990
				"tower:m03:line_name", -- 990
				tick -- 990
			) -- 990
		end -- 990
		if t >= 4.62 then -- 990
			self:playTowerOnce( -- 993
				audio, -- 993
				"brush2", -- 993
				"sfx", -- 993
				____exports.TOWER_AUDIO_FILES.brush2, -- 993
				0.82, -- 993
				"tower:brush:row2", -- 993
				tick -- 993
			) -- 993
		end -- 993
		if t >= 5.55 then -- 993
			self:playTowerOnce( -- 996
				audio, -- 996
				"m03_needle", -- 996
				"sfx", -- 996
				____exports.TOWER_AUDIO_FILES.needlePlace, -- 996
				0.8, -- 996
				"tower:m03:needle_place", -- 996
				tick -- 996
			) -- 996
		end -- 996
		if t >= 6.02 then -- 996
			self:playTowerOnce( -- 999
				audio, -- 999
				"m03_bowl", -- 999
				"sfx", -- 999
				____exports.TOWER_AUDIO_FILES.bowlSet, -- 999
				0.82, -- 999
				"tower:bowl_set", -- 999
				tick -- 999
			) -- 999
		end -- 999
	end -- 999
end -- 940
function TowerEndingsPlugin.prototype.composeSubtitle(self, route) -- 1004
	local t = self.seqElapsed -- 1005
	if t < ____exports.TOWER_ENDING_TIMINGS.reply1Sec then -- 1005
		return "[两下轻敲]  门外厚木上传来两声轻敲。" -- 1007
	end -- 1007
	if t < ____exports.TOWER_ENDING_TIMINGS.doorOpenSec then -- 1007
		return "[门内回敲]  静默一息，门后轻轻回敲两声。" -- 1010
	end -- 1010
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1010
		return route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 1013
	end -- 1013
	if t < ____exports.TOWER_ENDING_TIMINGS.row1StartSec then -- 1013
		return route == "child" and "她把针套与纸条摊在案前，守卒展开收籍末页。" or "两人站在值夜室内，守卒摊开收籍末页。" -- 1018
	end -- 1018
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotStartSec then -- 1018
		return "守卒蘸墨提笔，在第一行写下「小满」。" -- 1023
	end -- 1023
	if t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1023
		return "笔尖停在第二行上方。" -- 1026
	end -- 1026
	if route == "child" then -- 1026
		if t < 6.7 then -- 1026
			return F03_DIALOGUE -- 1030
		end -- 1030
		return "" -- 1032
	end -- 1032
	if t < 5.45 then -- 1032
		return M03_DIALOGUE -- 1035
	end -- 1035
	if t < 6.85 then -- 1035
		return "守卒写满第二行。小满解下针套轻放案上，两只手端起热碗。" -- 1038
	end -- 1038
	return "" -- 1040
end -- 1004
function TowerEndingsPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 1045
	if not self.active then -- 1045
		if not self.rehearsalActive and ctx.p.room.key == "tower" and ctx.p.phase == "tower-enter" and self.doorOpenOverlayElapsed >= 0 then -- 1045
			local u = clamp01(self.doorOpenOverlayElapsed / 0.9) -- 1055
			local fade = 1 - smoothstep(0.28, 1, u) -- 1056
			if fade > 0.02 then -- 1056
				local route = self.activeRoute -- 1058
				local openK = smoothstep(0, 0.55, u) -- 1059
				local cx = ctx.uiW * 0.5 -- 1060
				local cy = ctx.uiH * 0.46 -- 1061
				uiDraw:drawRect( -- 1062
					Rect(0, 0, ctx.uiW, ctx.uiH), -- 1062
					Color( -- 1062
						8, -- 1062
						10, -- 1062
						16, -- 1062
						math.floor(145 * fade + 0.5) -- 1062
					) -- 1062
				) -- 1062
				fillRadialGlow( -- 1063
					uiGlow, -- 1064
					cx + 42 * (1 - openK), -- 1065
					cy + 16, -- 1066
					ctx.uiW * (0.26 + 0.18 * openK), -- 1067
					ctx.uiH * (0.34 + 0.16 * openK), -- 1068
					Color( -- 1069
						248, -- 1069
						212, -- 1069
						144, -- 1069
						math.floor(128 * fade + 0.5) -- 1069
					), -- 1069
					Color(220, 154, 72, 0), -- 1070
					18 -- 1071
				) -- 1071
				self:drawMingLantern( -- 1073
					uiInkDraw, -- 1073
					uiGlow, -- 1073
					cx + 66 - openK * 24, -- 1073
					cy + 28, -- 1073
					1.05, -- 1073
					fade * (0.45 + 0.55 * openK), -- 1073
					1 -- 1073
				) -- 1073
				local cap = route == "child" and "守卒推门提灯，暖光先照见她腕上的针套。" or "守卒推门提灯，周戍牵小满一同跨过门槛。" -- 1074
				drawSilkVeil( -- 1077
					uiDraw, -- 1077
					uiArt, -- 1077
					"tower_door_open_veil", -- 1077
					cx, -- 1077
					ctx.uiH - 86, -- 1077
					560, -- 1077
					38, -- 1077
					PALETTE.inkWarm, -- 1077
					0.78 * fade, -- 1077
					2 -- 1077
				) -- 1077
				ctx.texts:put( -- 1078
					"sm", -- 1078
					cap, -- 1078
					cx, -- 1078
					ctx.uiH - 86, -- 1078
					toColor(PALETTE.amberCore), -- 1078
					0.5, -- 1078
					0.5, -- 1078
					"Center", -- 1078
					1, -- 1078
					fade, -- 1078
					0.08 -- 1078
				) -- 1078
			end -- 1078
		end -- 1078
		return false -- 1081
	end -- 1081
	local route = self.activeRoute -- 1084
	local t = self.seqElapsed -- 1085
	local lampProg = route == "child" and smoothstep(5.2, 6.75, t) or 0 -- 1086
	local scaled = computeScaledAnchors(ctx.uiW, ctx.uiH, lampProg) -- 1087
	local s = scaled.s -- 1088
	local ox = scaled.ox -- 1089
	local oy = scaled.oy -- 1090
	uiDraw:drawRect( -- 1093
		Rect(0, 0, ctx.uiW, ctx.uiH), -- 1093
		Color(8, 10, 16, 255) -- 1093
	) -- 1093
	if t < ____exports.TOWER_ENDING_TIMINGS.indoorCutSec then -- 1093
		self:drawAct1PorchAndDoor( -- 1097
			uiDraw, -- 1097
			uiInkDraw, -- 1097
			uiArt, -- 1097
			uiGlow, -- 1097
			ctx, -- 1097
			route, -- 1097
			s, -- 1097
			ox, -- 1097
			oy -- 1097
		) -- 1097
		local fadeOut = smoothstep(1.22, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec, t) -- 1099
		if fadeOut > 0.01 then -- 1099
			uiInkDraw:drawRect( -- 1101
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1101
				Color( -- 1101
					8, -- 1101
					10, -- 1101
					16, -- 1101
					math.floor(230 * fadeOut + 0.5) -- 1101
				) -- 1101
			) -- 1101
		end -- 1101
	else -- 1101
		self:drawAct2And3Guardroom( -- 1105
			uiDraw, -- 1105
			uiInkDraw, -- 1105
			uiArt, -- 1105
			uiGlow, -- 1105
			ctx, -- 1105
			route, -- 1105
			lampProg, -- 1105
			s, -- 1105
			ox, -- 1105
			oy -- 1105
		) -- 1105
		local fadeIn = 1 - smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, ____exports.TOWER_ENDING_TIMINGS.indoorCutSec + 0.24, t) -- 1106
		if fadeIn > 0.01 then -- 1106
			uiInkDraw:drawRect( -- 1108
				Rect(0, 0, ctx.uiW, ctx.uiH), -- 1108
				Color( -- 1108
					8, -- 1108
					10, -- 1108
					16, -- 1108
					math.floor(220 * fadeIn + 0.5) -- 1108
				) -- 1108
			) -- 1108
		end -- 1108
	end -- 1108
	local barH = math.floor(____exports.TOWER_SHOT_LAYOUT.letterboxH * s + 0.5) -- 1113
	uiInkDraw:drawRect( -- 1114
		Rect(0, ctx.uiH - barH, ctx.uiW, barH), -- 1114
		Color(7, 9, 14, 248) -- 1114
	) -- 1114
	uiInkDraw:drawRect( -- 1115
		Rect(0, 0, ctx.uiW, barH), -- 1115
		Color(7, 9, 14, 248) -- 1115
	) -- 1115
	uiInkDraw:drawSegment( -- 1116
		Vec2(0, ctx.uiH - barH), -- 1116
		Vec2(ctx.uiW, ctx.uiH - barH), -- 1116
		0.9, -- 1116
		toColor(PALETTE.silkDim, 82) -- 1116
	) -- 1116
	uiInkDraw:drawSegment( -- 1117
		Vec2(0, barH), -- 1117
		Vec2(ctx.uiW, barH), -- 1117
		0.9, -- 1117
		toColor(PALETTE.silkDim, 82) -- 1117
	) -- 1117
	self:drawDialogueSubtitle( -- 1120
		uiDraw, -- 1120
		uiInkDraw, -- 1120
		uiArt, -- 1120
		ctx, -- 1120
		route, -- 1120
		s, -- 1120
		barH -- 1120
	) -- 1120
	return true -- 1122
end -- 1045
function TowerEndingsPlugin.prototype.drawAct1PorchAndDoor(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, s, ox, oy) -- 1127
	local t = self.seqElapsed -- 1138
	local openK = smoothstep(____exports.TOWER_ENDING_TIMINGS.doorOpenSec, 1.24, t) -- 1139
	local doorCx = ox + ____exports.TOWER_SHOT_LAYOUT.doorCenterX * s -- 1140
	local threshY = oy + ____exports.TOWER_SHOT_LAYOUT.thresholdY * s -- 1141
	local k1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock1Sec) / 0.055) ^ 2) -- 1144
	local k2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.knock2Sec) / 0.055) ^ 2) -- 1145
	local r1Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply1Sec) / 0.06) ^ 2) -- 1146
	local r2Pulse = math.exp(-((t - ____exports.TOWER_ENDING_TIMINGS.reply2Sec) / 0.06) ^ 2) -- 1147
	drawComicSequence( -- 1149
		uiDraw, -- 1150
		uiInkDraw, -- 1151
		uiArt, -- 1152
		route == "child" and F03_PORCH_COMIC_SEQ or M03_PORCH_COMIC_SEQ, -- 1153
		t, -- 1154
		ctx.uiW, -- 1155
		ctx.uiH, -- 1156
		{ -- 1157
			letterboxH = 0, -- 1158
			opacity = 1, -- 1159
			layer = 1, -- 1160
			instancePrefix = route == "child" and "fe05_f03_porch" or "fe05_m03_porch", -- 1161
			accentBorder = false -- 1162
		} -- 1162
	) -- 1162
	if openK > 0.05 then -- 1162
		fillRadialGlow( -- 1168
			uiGlow, -- 1169
			doorCx + 18 * s, -- 1170
			threshY + 148 * s, -- 1171
			(140 + openK * 140) * s, -- 1172
			(160 + openK * 110) * s, -- 1173
			Color( -- 1174
				246, -- 1174
				204, -- 1174
				134, -- 1174
				math.floor(92 * openK + 0.5) -- 1174
			), -- 1174
			Color(220, 156, 72, 0), -- 1175
			18 -- 1176
		) -- 1176
	end -- 1176
	local kx = ox + ____exports.TOWER_SHOT_LAYOUT.knockHandX * s -- 1179
	local ky = oy + ____exports.TOWER_SHOT_LAYOUT.knockHandY * s -- 1180
	if k1Pulse > 0.08 or k2Pulse > 0.08 then -- 1180
		local amp = math.max(k1Pulse, k2Pulse) -- 1182
		local r = (18 + (1 - amp) * 34) * s -- 1183
		strokeEllipse( -- 1184
			uiInkDraw, -- 1184
			kx + 24 * s, -- 1184
			ky, -- 1184
			r, -- 1184
			r * 0.85, -- 1184
			1.8 * s, -- 1184
			toColor( -- 1184
				PALETTE.amberCore, -- 1184
				math.floor(215 * amp + 0.5) -- 1184
			), -- 1184
			24 -- 1184
		) -- 1184
	end -- 1184
	if r1Pulse > 0.08 or r2Pulse > 0.08 then -- 1184
		local amp = math.max(r1Pulse, r2Pulse) -- 1187
		local r = (24 + (1 - amp) * 42) * s -- 1188
		strokeEllipse( -- 1189
			uiInkDraw, -- 1189
			doorCx + 30 * s, -- 1189
			ky + 16 * s, -- 1189
			r, -- 1189
			r * 0.9, -- 1189
			1.6 * s, -- 1189
			toColor( -- 1189
				PALETTE.amber, -- 1189
				math.floor(190 * amp + 0.5) -- 1189
			), -- 1189
			24 -- 1189
		) -- 1189
	end -- 1189
end -- 1127
function TowerEndingsPlugin.prototype.drawAct2And3Guardroom(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, lampProg, s, ox, oy) -- 1195
	local t = self.seqElapsed -- 1207
	local isLowpoly = route == "child" -- 1208
	local deskY = oy + ____exports.TOWER_SHOT_LAYOUT.deskTopY * s -- 1209
	local ____isLowpoly_9 -- 1212
	if isLowpoly then -- 1212
		____isLowpoly_9 = self:drawF03LowpolyRoomAndWindow( -- 1213
			uiDraw, -- 1213
			uiArt, -- 1213
			uiGlow, -- 1213
			ctx, -- 1213
			lampProg, -- 1213
			s, -- 1213
			ox, -- 1213
			oy -- 1213
		) -- 1213
	else -- 1213
		____isLowpoly_9 = self:drawM03PixelRoomAndWindow( -- 1214
			uiDraw, -- 1214
			uiArt, -- 1214
			uiGlow, -- 1214
			ctx, -- 1214
			s, -- 1214
			ox, -- 1214
			oy -- 1214
		) -- 1214
	end -- 1214
	local paintedRoomOk = ____isLowpoly_9 -- 1212
	if not paintedRoomOk then -- 1212
		local deskTopCol = isLowpoly and toColor(shadeSurface( -- 1218
			MING_MATERIALS.mingTimber.base, -- 1220
			vec3(-0.25, 0.9, -0.35), -- 1221
			0, -- 1222
			1, -- 1223
			lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1224
			MING_MATERIALS.mingTimber -- 1225
		)) or Color(86, 60, 42, 255) -- 1225
		local deskFrontCol = isLowpoly and toColor(shadeSurface( -- 1228
			MING_MATERIALS.mingTimberDark.base, -- 1230
			vec3(0, 0.1, -0.99), -- 1231
			-4, -- 1231
			1, -- 1233
			lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg), -- 1234
			MING_MATERIALS.mingTimberDark -- 1235
		)) or Color(52, 36, 26, 255) -- 1235
		uiDraw:drawPolygon( -- 1238
			{ -- 1238
				Vec2(0, deskY - 120 * s), -- 1239
				Vec2(ctx.uiW, deskY - 120 * s), -- 1240
				Vec2(ctx.uiW, deskY + 42 * s), -- 1241
				Vec2(0, deskY + 42 * s) -- 1242
			}, -- 1242
			deskTopCol -- 1243
		) -- 1243
		uiDraw:drawRect( -- 1244
			Rect(0, 0, ctx.uiW, deskY - 118 * s), -- 1244
			deskFrontCol -- 1244
		) -- 1244
		local inkX = ox + ____exports.TOWER_SHOT_LAYOUT.inkstoneX * s -- 1245
		local inkY = oy + ____exports.TOWER_SHOT_LAYOUT.inkstoneY * s -- 1246
		uiDraw:drawPolygon( -- 1247
			{ -- 1247
				Vec2(inkX - 38 * s, inkY - 18 * s), -- 1248
				Vec2(inkX + 38 * s, inkY - 18 * s), -- 1249
				Vec2(inkX + 32 * s, inkY + 18 * s), -- 1250
				Vec2(inkX - 32 * s, inkY + 18 * s) -- 1251
			}, -- 1251
			Color(38, 44, 52, 255), -- 1252
			1.2, -- 1252
			Color(96, 106, 118, 185) -- 1252
		) -- 1252
	end -- 1252
	local lx = isLowpoly and ox + lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskX, ____exports.TOWER_SHOT_LAYOUT.lampWindowX, lampProg) * s or ox + ____exports.TOWER_SHOT_LAYOUT.lampDeskX * s -- 1256
	local ly = isLowpoly and oy + (lerp(____exports.TOWER_SHOT_LAYOUT.lampDeskY, ____exports.TOWER_SHOT_LAYOUT.lampWindowY, lampProg) + math.sin(math.pi * lampProg) * 34) * s or oy + ____exports.TOWER_SHOT_LAYOUT.lampDeskY * s -- 1259
	local lampWarmth = isLowpoly and 0.45 + 0.55 * lampProg or 0.92 -- 1262
	if not paintedRoomOk then -- 1262
		self:drawMingLantern( -- 1264
			uiInkDraw, -- 1264
			uiGlow, -- 1264
			lx, -- 1264
			ly, -- 1264
			1.02 * s, -- 1264
			1, -- 1264
			lampWarmth -- 1264
		) -- 1264
	elseif isLowpoly then -- 1264
		local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 1267
		fillRadialGlow( -- 1268
			uiGlow, -- 1269
			lx, -- 1270
			ly + 4 * s, -- 1271
			118 * s * flicker * (0.65 + 0.45 * lampProg), -- 1272
			118 * s * flicker * (0.65 + 0.45 * lampProg), -- 1273
			Color( -- 1274
				250, -- 1274
				208, -- 1274
				132, -- 1274
				math.floor((78 + 56 * lampProg) * flicker + 0.5) -- 1274
			), -- 1274
			Color(228, 162, 74, 0), -- 1275
			16 -- 1276
		) -- 1276
	else -- 1276
		local flicker = 0.92 + 0.08 * math.sin(self.animTime * 6.8) -- 1280
		fillRadialGlow( -- 1281
			uiGlow, -- 1282
			ox + 266 * s, -- 1283
			oy + 272 * s, -- 1284
			148 * s * flicker, -- 1285
			138 * s * flicker, -- 1286
			Color( -- 1287
				252, -- 1287
				212, -- 1287
				138, -- 1287
				math.floor(88 * flicker + 0.5) -- 1287
			), -- 1287
			Color(232, 168, 76, 0), -- 1288
			16 -- 1289
		) -- 1289
	end -- 1289
	if isLowpoly and lampProg > 0.04 then -- 1289
		local beamA = math.floor(62 * lampProg + 0.5) -- 1295
		fillGradQuad( -- 1296
			uiGlow, -- 1297
			lx + 10 * s, -- 1298
			ly + 30 * s, -- 1298
			Color(248, 206, 134, beamA), -- 1298
			lx + 10 * s, -- 1299
			ly - 32 * s, -- 1299
			Color( -- 1299
				248, -- 1299
				206, -- 1299
				134, -- 1299
				math.floor(beamA * 0.72 + 0.5) -- 1299
			), -- 1299
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.92) * s, -- 1300
			oy + (____exports.TOWER_SHOT_LAYOUT.row2Y - 58) * s, -- 1300
			Color(242, 198, 124, 0), -- 1300
			ox + (____exports.TOWER_SHOT_LAYOUT.bookX + ____exports.TOWER_SHOT_LAYOUT.bookW * 0.85) * s, -- 1301
			oy + (____exports.TOWER_SHOT_LAYOUT.row1Y + 48) * s, -- 1301
			Color(242, 198, 124, 0) -- 1301
		) -- 1301
	end -- 1301
	local bookReveal = smoothstep(____exports.TOWER_ENDING_TIMINGS.indoorCutSec, 1.85, t) -- 1306
	if bookReveal > 0.02 then -- 1306
		self:drawRegisterBook( -- 1308
			uiDraw, -- 1308
			uiInkDraw, -- 1308
			uiArt, -- 1308
			uiGlow, -- 1308
			ctx, -- 1308
			route, -- 1308
			bookReveal, -- 1308
			lampProg, -- 1308
			s, -- 1308
			ox, -- 1308
			oy -- 1308
		) -- 1308
	end -- 1308
	self:drawDeskPropsAndBowl( -- 1312
		uiDraw, -- 1312
		uiInkDraw, -- 1312
		uiArt, -- 1312
		uiGlow, -- 1312
		ctx, -- 1312
		route, -- 1312
		paintedRoomOk, -- 1312
		s, -- 1312
		ox, -- 1312
		oy -- 1312
	) -- 1312
end -- 1195
function TowerEndingsPlugin.prototype.drawF03LowpolyRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, lampProg, s, ox, oy) -- 1315
	local scaleCover = math.max(ctx.uiW / 960, ctx.uiH / 540) -- 1325
	local imgW = 960 * scaleCover -- 1326
	local imgH = 540 * scaleCover -- 1327
	local t = self.seqElapsed -- 1328
	local f03Slot = t < 3.4 and "comic_tower_f03_room_01_cold" or (t < 5.2 and "comic_tower_f03_room_02_hover" or (t < 6.2 and "comic_tower_f03_room_03_move_lamp" or "comic_tower_f03_room_04_lit_bowl")) -- 1329
	local placedComic = uiArt:tryPlace( -- 1334
		f03Slot, -- 1335
		"fe05_f03_comic_bg", -- 1336
		ctx.uiW * 0.5, -- 1337
		ctx.uiH * 0.5, -- 1338
		imgW, -- 1339
		imgH, -- 1340
		{opacity = 1, layer = -8} -- 1341
	) -- 1341
	if placedComic then -- 1341
		if lampProg > 0.02 then -- 1341
			local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1348
			local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1349
			local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1350
			fillRadialGlow( -- 1351
				uiGlow, -- 1352
				wx + ww * 0.58, -- 1352
				wy + 22 * s, -- 1352
				580 * s, -- 1353
				420 * s, -- 1353
				Color( -- 1354
					248, -- 1354
					198, -- 1354
					122, -- 1354
					math.floor(92 * lampProg + 0.5) -- 1354
				), -- 1354
				Color(216, 152, 68, 0), -- 1355
				20 -- 1356
			) -- 1356
		end -- 1356
		return true -- 1359
	end -- 1359
	local light = lerpLightRig(TOWER_COLD_DAWN_LIGHT, TOWER_WEST_LAMP_LIGHT, lampProg) -- 1363
	local wallTop = lerpRGBA( -- 1364
		rgba(18, 24, 38, 255), -- 1364
		rgba(46, 36, 28, 255), -- 1364
		lampProg -- 1364
	) -- 1364
	local wallBot = lerpRGBA( -- 1365
		rgba(12, 16, 26, 255), -- 1365
		rgba(28, 22, 20, 255), -- 1365
		lampProg -- 1365
	) -- 1365
	fillVGradRect( -- 1366
		uiDraw, -- 1366
		0, -- 1366
		0, -- 1366
		ctx.uiW, -- 1366
		ctx.uiH, -- 1366
		toColor(wallBot), -- 1366
		toColor(wallTop) -- 1366
	) -- 1366
	local wx = ox + ____exports.TOWER_SHOT_LAYOUT.westWindowX * s -- 1367
	local wy = oy + ____exports.TOWER_SHOT_LAYOUT.westWindowY * s -- 1368
	local ww = ____exports.TOWER_SHOT_LAYOUT.westWindowW * s -- 1369
	local wh = ____exports.TOWER_SHOT_LAYOUT.westWindowH * s -- 1370
	fillVGradRect( -- 1371
		uiDraw, -- 1371
		wx, -- 1371
		wy, -- 1371
		ww, -- 1371
		wh, -- 1371
		Color(34, 44, 62, 255), -- 1371
		Color(16, 24, 40, 255) -- 1371
	) -- 1371
	local sillCol = shadeSurface( -- 1372
		MING_MATERIALS.mingStoneStep.base, -- 1372
		vec3(0, 0.94, -0.34), -- 1372
		6, -- 1372
		1, -- 1372
		light, -- 1372
		MING_MATERIALS.mingStoneStep -- 1372
	) -- 1372
	uiDraw:drawRect( -- 1373
		Rect(wx - 12 * s, wy - 14 * s, ww + 24 * s, 18 * s), -- 1373
		toColor(sillCol) -- 1373
	) -- 1373
	return false -- 1374
end -- 1315
function TowerEndingsPlugin.prototype.drawM03PixelRoomAndWindow(self, uiDraw, uiArt, uiGlow, ctx, s, ox, oy) -- 1377
	local scaleCover = math.max(ctx.uiW / 960, ctx.uiH / 540) -- 1386
	local imgW = 960 * scaleCover -- 1387
	local imgH = 540 * scaleCover -- 1388
	local t = self.seqElapsed -- 1389
	local m03Slot = t < 4.2 and "comic_tower_m03_room_01_warm" or (t < 5.45 and "comic_tower_m03_room_02_speak" or (t < 6.08 and "comic_tower_m03_room_03_pouch" or "comic_tower_m03_room_04_bowl")) -- 1390
	local placedWarm = uiArt:tryPlace( -- 1395
		m03Slot, -- 1396
		"fe05_m03_comic_bg", -- 1397
		ctx.uiW * 0.5, -- 1398
		ctx.uiH * 0.5, -- 1399
		imgW, -- 1400
		imgH, -- 1401
		{opacity = 1, layer = -8} -- 1402
	) -- 1402
	if placedWarm then -- 1402
		fillRadialGlow( -- 1408
			uiGlow, -- 1409
			ox + 260 * s, -- 1409
			oy + 416 * s, -- 1409
			520 * s, -- 1410
			360 * s, -- 1410
			Color(246, 202, 134, 62), -- 1411
			Color(220, 158, 76, 0), -- 1412
			20 -- 1413
		) -- 1413
		return true -- 1415
	end -- 1415
	fillVGradRect( -- 1418
		uiDraw, -- 1419
		0, -- 1419
		0, -- 1419
		ctx.uiW, -- 1419
		ctx.uiH, -- 1419
		Color(26, 21, 20, 255), -- 1420
		Color(46, 36, 30, 255) -- 1421
	) -- 1421
	local groupX = ox + 210 * s -- 1423
	local groupY = oy + 300 * s -- 1424
	uiArt:tryPlace( -- 1425
		"soldier_idle", -- 1425
		"fe05_m03_room_soldier", -- 1425
		groupX - 38 * s, -- 1425
		groupY, -- 1425
		118 * s, -- 1425
		166 * s, -- 1425
		{facing = 1, opacity = 0.9, layer = 1} -- 1425
	) -- 1425
	uiArt:tryPlace( -- 1428
		"child_idle", -- 1428
		"fe05_m03_room_child", -- 1428
		groupX + 42 * s, -- 1428
		groupY, -- 1428
		86 * s, -- 1428
		116 * s, -- 1428
		{facing = 1, opacity = 0.92, layer = 1} -- 1428
	) -- 1428
	return false -- 1431
end -- 1377
function TowerEndingsPlugin.prototype.drawRegisterBook(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, reveal, lampProg, s, ox, oy) -- 1434
	local t = self.seqElapsed -- 1447
	local bx = ox + ____exports.TOWER_SHOT_LAYOUT.bookX * s -- 1448
	local by = oy + ____exports.TOWER_SHOT_LAYOUT.bookY * s -- 1449
	local bw = ____exports.TOWER_SHOT_LAYOUT.bookW * s -- 1450
	local bh = ____exports.TOWER_SHOT_LAYOUT.bookH * s -- 1451
	local midX = bx + bw * 0.5 -- 1452
	local midY = by + bh * 0.5 -- 1453
	uiDraw:drawRect( -- 1456
		Rect(bx - 6 * s, by - 8 * s, bw + 14 * s, bh + 10 * s), -- 1456
		Color( -- 1456
			10, -- 1456
			11, -- 1456
			16, -- 1456
			math.floor(108 * reveal + 0.5) -- 1456
		) -- 1456
	) -- 1456
	uiDraw:drawRect( -- 1457
		Rect(bx - 12 * s, by + 12 * s, 15 * s, bh - 24 * s), -- 1457
		Color( -- 1457
			32, -- 1457
			46, -- 1457
			62, -- 1457
			math.floor(235 * reveal + 0.5) -- 1457
		), -- 1457
		1, -- 1457
		Color( -- 1457
			86, -- 1457
			104, -- 1457
			124, -- 1457
			math.floor(165 * reveal + 0.5) -- 1457
		) -- 1457
	) -- 1457
	if not uiArt:tryPlace( -- 1457
		"ink_song_paper", -- 1460
		"fe05_registry_paper", -- 1460
		midX, -- 1460
		midY, -- 1460
		bw, -- 1460
		bh, -- 1460
		{opacity = 0.98 * reveal, layer = 1} -- 1460
	) then -- 1460
		uiDraw:drawRect( -- 1461
			Rect(bx, by, bw, bh), -- 1462
			toColor( -- 1463
				PALETTE.xuanPaper, -- 1463
				math.floor(248 * reveal + 0.5) -- 1463
			), -- 1463
			1, -- 1464
			toColor( -- 1465
				PALETTE.silkDim, -- 1465
				math.floor(180 * reveal + 0.5) -- 1465
			) -- 1465
		) -- 1465
	end -- 1465
	local paperWarm = route == "child" and 0.18 + 0.82 * lampProg or 0.72 -- 1470
	fillRadialGlow( -- 1471
		uiGlow, -- 1472
		bx + bw * 0.34, -- 1472
		by + bh * 0.48, -- 1472
		bw * 0.58, -- 1473
		bh * 0.52, -- 1473
		Color( -- 1474
			246, -- 1474
			214, -- 1474
			156, -- 1474
			math.floor(44 * paperWarm * reveal + 0.5) -- 1474
		), -- 1474
		Color(238, 198, 128, 0), -- 1475
		16 -- 1476
	) -- 1476
	local padX = 44 * s -- 1480
	local padY = 32 * s -- 1481
	local inX = bx + padX -- 1482
	local inY = by + padY -- 1483
	local inW = bw - padX * 2 -- 1484
	local inH = bh - padY * 2 -- 1485
	local redSilk = toColor( -- 1486
		PALETTE.rouge, -- 1486
		math.floor(132 * reveal + 0.5) -- 1486
	) -- 1486
	local redFaint = toColor( -- 1487
		PALETTE.rouge, -- 1487
		math.floor(70 * reveal + 0.5) -- 1487
	) -- 1487
	uiInkDraw:drawRect( -- 1488
		Rect(inX, inY, inW, inH), -- 1488
		Color(0, 0, 0, 0), -- 1488
		1, -- 1488
		redSilk -- 1488
	) -- 1488
	uiInkDraw:drawRect( -- 1489
		Rect(inX + 4 * s, inY + 4 * s, inW - 8 * s, inH - 8 * s), -- 1489
		Color(0, 0, 0, 0), -- 1489
		0.6, -- 1489
		redFaint -- 1489
	) -- 1489
	local headY = inY + inH - 28 * s -- 1492
	ctx.texts:put( -- 1493
		"md", -- 1493
		"北塔值夜收籍 · 末页", -- 1493
		inX + 18 * s, -- 1493
		headY, -- 1493
		toColor(PALETTE.xuanInk), -- 1493
		0, -- 1493
		0.5, -- 1493
		"Left", -- 1493
		2.2, -- 1493
		0.96 * reveal, -- 1493
		0 -- 1493
	) -- 1493
	ctx.texts:put( -- 1494
		"xs", -- 1494
		"宁村北塔", -- 1494
		inX + inW - 18 * s, -- 1494
		headY, -- 1494
		toColor(PALETTE.xuanInkSub), -- 1494
		1, -- 1494
		0.5, -- 1494
		"Right", -- 1494
		1.8, -- 1494
		0.8 * reveal, -- 1494
		0 -- 1494
	) -- 1494
	uiInkDraw:drawSegment( -- 1495
		Vec2(inX + 14 * s, headY - 22 * s), -- 1495
		Vec2(inX + inW - 14 * s, headY - 22 * s), -- 1495
		0.9, -- 1495
		redSilk -- 1495
	) -- 1495
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1498
	local row1SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row1SubY * s -- 1499
	local r1Prog = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1500
	ctx.texts:put( -- 1501
		"sm", -- 1501
		"肆拾壹", -- 1501
		inX + 18 * s, -- 1501
		row1Y, -- 1501
		toColor(PALETTE.rouge), -- 1501
		0, -- 1501
		0.5, -- 1501
		"Left", -- 1501
		1, -- 1501
		0.94 * reveal, -- 1501
		0 -- 1501
	) -- 1501
	if r1Prog > 0.02 then -- 1501
		ctx.texts:put( -- 1503
			"md", -- 1503
			joinPrefixTokens(ROW1_TOKENS, r1Prog), -- 1503
			inX + 96 * s, -- 1503
			row1Y, -- 1503
			toColor(PALETTE.xuanInk), -- 1503
			0, -- 1503
			0.5, -- 1503
			"Left", -- 1503
			1.6, -- 1503
			0.96 * math.min(1, r1Prog * 1.4), -- 1503
			0 -- 1503
		) -- 1503
	end -- 1503
	if r1Prog > 0.65 then -- 1503
		local subA = smoothstep(0.65, 1, r1Prog) * reveal -- 1506
		local subText = route == "child" and "怀黄铜指南针、手书一纸；守城戍卒周戍所托。" or "与守城戍卒同行抵塔，安然入室。" -- 1507
		ctx.texts:put( -- 1510
			"xs", -- 1510
			subText, -- 1510
			inX + 96 * s, -- 1510
			row1SubY, -- 1510
			toColor(PALETTE.xuanInkSub), -- 1510
			0, -- 1510
			0.5, -- 1510
			"Left", -- 1510
			0.6, -- 1510
			0.88 * subA, -- 1510
			0 -- 1510
		) -- 1510
	end -- 1510
	uiInkDraw:drawSegment( -- 1512
		Vec2(inX + 16 * s, row1SubY - 24 * s), -- 1512
		Vec2(inX + inW - 16 * s, row1SubY - 24 * s), -- 1512
		0.7, -- 1512
		redFaint -- 1512
	) -- 1512
	local row2Y = oy + ____exports.TOWER_SHOT_LAYOUT.row2Y * s -- 1515
	local row2SubY = oy + ____exports.TOWER_SHOT_LAYOUT.row2SubY * s -- 1516
	ctx.texts:put( -- 1517
		"sm", -- 1517
		"肆拾贰", -- 1517
		inX + 18 * s, -- 1517
		row2Y, -- 1517
		toColor(PALETTE.rouge), -- 1517
		0, -- 1517
		0.5, -- 1517
		"Left", -- 1517
		1, -- 1517
		0.94 * reveal, -- 1517
		0 -- 1517
	) -- 1517
	if route == "child" then -- 1517
		local lineA = math.floor((105 + 55 * lampProg) * reveal + 0.5) -- 1521
		uiInkDraw:drawSegment( -- 1522
			Vec2(inX + 96 * s, row2Y - 9 * s), -- 1523
			Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1524
			1, -- 1525
			toColor(PALETTE.xuanInkSub, lineA) -- 1526
		) -- 1526
	else -- 1526
		local r2Prog = smoothstep(4.6, 5.55, t) -- 1530
		if r2Prog <= 0.02 then -- 1530
			uiInkDraw:drawSegment( -- 1532
				Vec2(inX + 96 * s, row2Y - 9 * s), -- 1533
				Vec2(inX + inW - 26 * s, row2Y - 9 * s), -- 1534
				0.9, -- 1535
				toColor( -- 1536
					PALETTE.xuanInkSub, -- 1536
					math.floor(105 * reveal + 0.5) -- 1536
				) -- 1536
			) -- 1536
		else -- 1536
			ctx.texts:put( -- 1539
				"md", -- 1539
				joinPrefixTokens(ROW2_SOLDIER_TOKENS, r2Prog), -- 1539
				inX + 96 * s, -- 1539
				row2Y, -- 1539
				toColor(PALETTE.xuanInk), -- 1539
				0, -- 1539
				0.5, -- 1539
				"Left", -- 1539
				1.6, -- 1539
				0.96 * math.min(1, r2Prog * 1.4), -- 1539
				0 -- 1539
			) -- 1539
			if r2Prog > 0.65 then -- 1539
				local subA = smoothstep(0.65, 1, r2Prog) * reveal -- 1541
				ctx.texts:put( -- 1542
					"xs", -- 1542
					"守城戍卒亲口报出姓名，两人俱安。", -- 1542
					inX + 96 * s, -- 1542
					row2SubY, -- 1542
					toColor(PALETTE.xuanInkSub), -- 1542
					0, -- 1542
					0.5, -- 1542
					"Left", -- 1542
					0.6, -- 1542
					0.88 * subA, -- 1542
					0 -- 1542
				) -- 1542
			end -- 1542
		end -- 1542
	end -- 1542
	uiInkDraw:drawSegment( -- 1546
		Vec2(inX + 16 * s, row2SubY - 24 * s), -- 1546
		Vec2(inX + inW - 16 * s, row2SubY - 24 * s), -- 1546
		0.7, -- 1546
		redFaint -- 1546
	) -- 1546
	local colophonA = smoothstep(6.7, 7.6, t) * reveal -- 1549
	if colophonA > 0.02 then -- 1549
		local signY = inY + 34 * s -- 1551
		ctx.texts:put( -- 1552
			"banner", -- 1552
			"向西守望", -- 1552
			midX - 24 * s, -- 1552
			signY, -- 1552
			toColor(PALETTE.xuanInk), -- 1552
			0.5, -- 1552
			0.5, -- 1552
			"Center", -- 1552
			6, -- 1552
			0.88 * colophonA, -- 1552
			0 -- 1552
		) -- 1552
	end -- 1552
	self:drawGuardBrushHand( -- 1556
		uiInkDraw, -- 1556
		uiArt, -- 1556
		route, -- 1556
		s, -- 1556
		ox, -- 1556
		oy -- 1556
	) -- 1556
end -- 1434
function TowerEndingsPlugin.prototype.drawGuardBrushHand(self, uiInkDraw, uiArt, route, s, ox, oy) -- 1559
	local t = self.seqElapsed -- 1567
	local hoverX = ox + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipX * s -- 1568
	local hoverY = oy + ____exports.TOWER_SHOT_LAYOUT.brushHoverTipY * s -- 1569
	local row1X0 = hoverX -- 1570
	local row1X1 = hoverX + 142 * s -- 1571
	local row1Y = oy + ____exports.TOWER_SHOT_LAYOUT.row1Y * s -- 1572
	local tipX = hoverX -- 1574
	local tipY = hoverY -- 1575
	local alpha = 0 -- 1576
	local lifted = 0 -- 1577
	if t >= 2 and t < ____exports.TOWER_ENDING_TIMINGS.row1EndSec then -- 1577
		local k = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1StartSec, ____exports.TOWER_ENDING_TIMINGS.row1EndSec, t) -- 1581
		tipX = lerp(row1X0, row1X1, k) -- 1582
		tipY = row1Y + math.sin(k * math.pi * 6) * 3.5 * s -- 1583
		alpha = smoothstep(2, 2.2, t) -- 1584
		lifted = (1 - smoothstep(2.12, 2.22, t)) * 12 * s -- 1585
	elseif t >= ____exports.TOWER_ENDING_TIMINGS.row1EndSec and t < ____exports.TOWER_ENDING_TIMINGS.pivotEndSec then -- 1585
		local moveK = smoothstep(____exports.TOWER_ENDING_TIMINGS.row1EndSec, 3.6, t) -- 1588
		tipX = lerp(row1X1, hoverX, moveK) -- 1589
		tipY = lerp(row1Y, hoverY, moveK) -- 1590
		alpha = 1 -- 1591
		lifted = 9 * s + math.sin(self.animTime * 2.4) * 1.2 * s -- 1592
	elseif route == "child" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 4.95 then -- 1592
		local outK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.95, t) -- 1595
		tipX = hoverX + outK * 140 * s -- 1596
		tipY = hoverY + outK * 46 * s -- 1597
		lifted = (9 + outK * 28) * s -- 1598
		alpha = 1 - outK -- 1599
	elseif route == "soldier" and t >= ____exports.TOWER_ENDING_TIMINGS.pivotEndSec and t < 6.05 then -- 1599
		if t < 4.6 then -- 1599
			local dipK = smoothstep(____exports.TOWER_ENDING_TIMINGS.pivotEndSec, 4.6, t) -- 1603
			tipX = hoverX -- 1604
			tipY = hoverY -- 1605
			lifted = lerp(9 * s, 0, dipK) -- 1606
			alpha = 1 -- 1607
		elseif t < 5.55 then -- 1607
			local wK = smoothstep(4.6, 5.55, t) -- 1609
			tipX = lerp(hoverX, hoverX + 216 * s, wK) -- 1610
			tipY = hoverY - 2 * s + math.sin(wK * math.pi * 8) * 3.2 * s -- 1611
			lifted = 0 -- 1612
			alpha = 1 -- 1613
		else -- 1613
			local outK = smoothstep(5.55, 6.05, t) -- 1615
			tipX = hoverX + 216 * s + outK * 115 * s -- 1616
			tipY = hoverY + outK * 52 * s -- 1617
			lifted = outK * 24 * s -- 1618
			alpha = 1 - outK -- 1619
		end -- 1619
	end -- 1619
	if alpha <= 0.02 then -- 1619
		return -- 1624
	end -- 1624
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1627
	local bx = tipX -- 1628
	local by = tipY + lifted -- 1629
	uiInkDraw:drawEllipse( -- 1631
		Vec2(tipX + 4 * s, tipY - 3 * s), -- 1631
		(5 + lifted * 0.22) * s, -- 1631
		2.8 * s, -- 1631
		Color( -- 1631
			20, -- 1631
			18, -- 1631
			16, -- 1631
			math.floor(78 * alpha + 0.5) -- 1631
		) -- 1631
	) -- 1631
	if uiArt:tryPlacePath( -- 1631
		"assets/art/cutscene_story_parts.clip|guard_brush_hand", -- 1634
		"fe05_guard_brush_hand", -- 1635
		bx, -- 1636
		by, -- 1637
		344 * s, -- 1638
		268 * s, -- 1639
		{ -- 1640
			anchorX = 0.03, -- 1641
			anchorY = 0.03, -- 1642
			opacity = clamp01(alpha), -- 1643
			smooth = true, -- 1644
			layer = 6 -- 1645
		} -- 1645
	) then -- 1645
		return -- 1648
	end -- 1648
	uiInkDraw:drawPolygon( -- 1651
		{ -- 1651
			Vec2(bx, by), -- 1652
			Vec2(bx + 15 * s, by - 4 * s), -- 1653
			Vec2(bx + 10 * s, by + 8 * s) -- 1654
		}, -- 1654
		Color(22, 22, 26, a) -- 1655
	) -- 1655
	uiInkDraw:drawSegment( -- 1656
		Vec2(bx + 12 * s, by + 2 * s), -- 1656
		Vec2(bx + 122 * s, by + 34 * s), -- 1656
		6.8 * s, -- 1656
		Color(142, 110, 74, a) -- 1656
	) -- 1656
end -- 1559
function TowerEndingsPlugin.prototype.drawDeskPropsAndBowl(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx, route, paintedRoomOk, s, ox, oy) -- 1659
	local t = self.seqElapsed -- 1671
	local ncX = ox + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskX * s -- 1672
	local ncY = oy + ____exports.TOWER_SHOT_LAYOUT.needleCaseDeskY * s -- 1673
	local bowlX = ox + ____exports.TOWER_SHOT_LAYOUT.bowlRimX * s -- 1674
	local bowlY = oy + ____exports.TOWER_SHOT_LAYOUT.bowlRimY * s -- 1675
	if paintedRoomOk then -- 1675
		if route == "child" then -- 1675
			local noteReadA = smoothstep(1.65, 2.1, t) * (1 - smoothstep(3.65, 4.15, t)) -- 1680
			if noteReadA > 0.02 then -- 1680
				local cardX = ncX + 52 * s -- 1682
				local cardY = ncY + 72 * s -- 1683
				uiInkDraw:drawRect( -- 1684
					Rect(cardX - 118 * s, cardY - 30 * s, 236 * s, 60 * s), -- 1685
					toColor( -- 1686
						PALETTE.xuanPaper, -- 1686
						math.floor(238 * noteReadA + 0.5) -- 1686
					), -- 1686
					1, -- 1687
					toColor( -- 1688
						PALETTE.rouge, -- 1688
						math.floor(110 * noteReadA + 0.5) -- 1688
					) -- 1688
				) -- 1688
				ctx.texts:put( -- 1690
					"xs", -- 1690
					NEEDLE_NOTE_LINES[1], -- 1690
					cardX, -- 1690
					cardY + 10 * s, -- 1690
					toColor(PALETTE.xuanInk), -- 1690
					0.5, -- 1690
					0.5, -- 1690
					"Center", -- 1690
					0.6, -- 1690
					0.94 * noteReadA, -- 1690
					0 -- 1690
				) -- 1690
				ctx.texts:put( -- 1691
					"xs", -- 1691
					"—— " .. NEEDLE_NOTE_LINES[2], -- 1691
					cardX + 74 * s, -- 1691
					cardY - 12 * s, -- 1691
					toColor(PALETTE.xuanInkSub), -- 1691
					1, -- 1691
					0.5, -- 1691
					"Right", -- 1691
					0.8, -- 1691
					0.88 * noteReadA, -- 1691
					0 -- 1691
				) -- 1691
			end -- 1691
		end -- 1691
		local steamStart = route == "child" and 6.2 or 6.08 -- 1694
		local steamOp = smoothstep(steamStart, steamStart + 0.45, t) -- 1695
		if steamOp > 0.02 then -- 1695
			local steamCx = route == "child" and ox + 1110 * s or ox + 1050 * s -- 1697
			local steamCy = oy + 196 * s -- 1698
			local wi = 0 -- 1699
			do -- 1699
				wi = 0 -- 1700
				while wi < 4 do -- 1700
					local cyc = (self.animTime * 0.34 + wi * 0.25) % 1 -- 1701
					local sx = steamCx + (wi - 1.5) * 16 * s + math.sin(self.animTime * 1.4 + wi * 2.1) * (6 + cyc * 8) * s -- 1702
					local sy = steamCy + (18 + cyc * 54) * s -- 1703
					local sr = (15 + cyc * 20) * s -- 1704
					local wa = math.floor(math.sin(cyc * math.pi) * 28 * steamOp + 0.5) -- 1705
					if wa > 2 then -- 1705
						fillRadialGlow( -- 1707
							uiGlow, -- 1707
							sx, -- 1707
							sy, -- 1707
							sr, -- 1707
							sr * 1.35, -- 1707
							Color(246, 238, 224, wa), -- 1707
							Color(246, 238, 224, 0), -- 1707
							12 -- 1707
						) -- 1707
					end -- 1707
					wi = wi + 1 -- 1700
				end -- 1700
			end -- 1700
		end -- 1700
		return -- 1711
	end -- 1711
	if route == "child" then -- 1711
		local propA = smoothstep(1.55, 2.05, t) -- 1715
		if propA > 0.02 then -- 1715
			self:drawNeedleCaseOnDesk( -- 1717
				uiDraw, -- 1717
				uiInkDraw, -- 1717
				uiArt, -- 1717
				ncX + 42 * s, -- 1717
				ncY - 22 * s, -- 1717
				s, -- 1717
				propA, -- 1717
				true -- 1717
			) -- 1717
		end -- 1717
		local noteReadA = smoothstep(1.65, 2.1, t) * (1 - smoothstep(3.65, 4.15, t)) -- 1719
		if noteReadA > 0.02 then -- 1719
			local cardX = ncX + 52 * s -- 1721
			local cardY = ncY + 72 * s -- 1722
			uiInkDraw:drawRect( -- 1723
				Rect(cardX - 118 * s, cardY - 30 * s, 236 * s, 60 * s), -- 1724
				toColor( -- 1725
					PALETTE.xuanPaper, -- 1725
					math.floor(238 * noteReadA + 0.5) -- 1725
				), -- 1725
				1, -- 1726
				toColor( -- 1727
					PALETTE.rouge, -- 1727
					math.floor(110 * noteReadA + 0.5) -- 1727
				) -- 1727
			) -- 1727
			ctx.texts:put( -- 1729
				"xs", -- 1729
				NEEDLE_NOTE_LINES[1], -- 1729
				cardX, -- 1729
				cardY + 10 * s, -- 1729
				toColor(PALETTE.xuanInk), -- 1729
				0.5, -- 1729
				0.5, -- 1729
				"Center", -- 1729
				0.6, -- 1729
				0.94 * noteReadA, -- 1729
				0 -- 1729
			) -- 1729
			ctx.texts:put( -- 1730
				"xs", -- 1730
				"—— " .. NEEDLE_NOTE_LINES[2], -- 1730
				cardX + 74 * s, -- 1730
				cardY - 12 * s, -- 1730
				toColor(PALETTE.xuanInkSub), -- 1730
				1, -- 1730
				0.5, -- 1730
				"Right", -- 1730
				0.8, -- 1730
				0.88 * noteReadA, -- 1730
				0 -- 1730
			) -- 1730
		end -- 1730
		local bowlK = smoothstep(4.35, 5.15, t) -- 1732
		if bowlK > 0.02 then -- 1732
			local bx = lerp(bowlX + 135 * s, bowlX, bowlK) -- 1734
			self:drawWarmPorcelainBowl( -- 1735
				uiDraw, -- 1735
				uiInkDraw, -- 1735
				uiArt, -- 1735
				uiGlow, -- 1735
				bx, -- 1735
				bowlY, -- 1735
				s, -- 1735
				bowlK, -- 1735
				false, -- 1735
				0 -- 1735
			) -- 1735
		end -- 1735
	else -- 1735
		local needleK = smoothstep(5.45, 6.15, t) -- 1738
		if needleK > 0.02 then -- 1738
			local ny = lerp(ncY + 26 * s, ncY - 22 * s, needleK) -- 1740
			self:drawNeedleCaseOnDesk( -- 1741
				uiDraw, -- 1741
				uiInkDraw, -- 1741
				uiArt, -- 1741
				ncX + 64 * s, -- 1741
				ny, -- 1741
				s, -- 1741
				needleK, -- 1741
				false -- 1741
			) -- 1741
		end -- 1741
		local bowlK = smoothstep(5.8, 6.65, t) -- 1743
		if bowlK > 0.02 then -- 1743
			local by = lerp(bowlY - 54 * s, bowlY, bowlK) -- 1745
			local handsK = smoothstep(5.95, 6.75, t) -- 1746
			self:drawWarmPorcelainBowl( -- 1747
				uiDraw, -- 1747
				uiInkDraw, -- 1747
				uiArt, -- 1747
				uiGlow, -- 1747
				bowlX, -- 1747
				by, -- 1747
				s, -- 1747
				bowlK, -- 1747
				true, -- 1747
				handsK -- 1747
			) -- 1747
		end -- 1747
		local cuffK = smoothstep(4.25, 4.85, t) -- 1750
		if cuffK > 0.02 then -- 1750
			drawPatchedCuff(uiInkDraw, uiGlow, { -- 1752
				wristX = ox + 116 * s, -- 1753
				wristY = oy + 168 * s, -- 1754
				angleRad = 0.06, -- 1755
				scale = 0.74 * s, -- 1756
				pose = "open", -- 1757
				opacity = 0.94 * cuffK, -- 1758
				stitchHighlight = 0.34, -- 1759
				warmth = 0.72, -- 1760
				uiArt = uiArt, -- 1761
				instanceKey = "fe05_m03_desk_cuff", -- 1762
				layer = 5 -- 1763
			}) -- 1763
		end -- 1763
	end -- 1763
end -- 1659
function TowerEndingsPlugin.prototype.drawNeedleCaseOnDesk(self, bgDraw, inkDraw, uiArt, cx, cy, s, alpha, withNote) -- 1770
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1780
	bgDraw:drawEllipse( -- 1781
		Vec2(cx + 4 * s, cy - 32 * s), -- 1781
		44 * s, -- 1781
		12 * s, -- 1781
		Color( -- 1781
			10, -- 1781
			10, -- 1781
			14, -- 1781
			math.floor(130 * alpha + 0.5) -- 1781
		) -- 1781
	) -- 1781
	if not uiArt:tryPlacePath( -- 1781
		"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 1783
		"fe05_desk_needle_pouch", -- 1784
		cx, -- 1785
		cy + 4 * s, -- 1786
		100 * s, -- 1787
		102 * s, -- 1788
		{ -- 1789
			anchorX = 0.5, -- 1790
			anchorY = 0.5, -- 1791
			angle = -10, -- 1792
			opacity = clamp01(alpha), -- 1793
			smooth = true, -- 1794
			layer = 5 -- 1795
		} -- 1795
	) then -- 1795
		inkDraw:drawPolygon( -- 1798
			{ -- 1798
				Vec2(cx - 32 * s, cy - 12 * s), -- 1799
				Vec2(cx + 26 * s, cy - 15 * s), -- 1800
				Vec2(cx + 30 * s, cy + 16 * s), -- 1801
				Vec2(cx - 28 * s, cy + 18 * s) -- 1802
			}, -- 1802
			Color(148, 124, 92, a), -- 1803
			1.3, -- 1803
			Color(88, 70, 50, a) -- 1803
		) -- 1803
	end -- 1803
	if withNote then -- 1803
		inkDraw:drawPolygon( -- 1807
			{ -- 1807
				Vec2(cx + 42 * s, cy - 18 * s), -- 1808
				Vec2(cx + 100 * s, cy - 12 * s), -- 1809
				Vec2(cx + 94 * s, cy + 24 * s), -- 1810
				Vec2(cx + 38 * s, cy + 18 * s) -- 1811
			}, -- 1811
			toColor(PALETTE.xuanPaper, a), -- 1812
			1, -- 1812
			toColor( -- 1812
				PALETTE.xuanInkSub, -- 1812
				math.floor(160 * alpha + 0.5) -- 1812
			) -- 1812
		) -- 1812
		inkDraw:drawSegment( -- 1813
			Vec2(cx + 50 * s, cy + 8 * s), -- 1813
			Vec2(cx + 84 * s, cy + 11 * s), -- 1813
			1.2 * s, -- 1813
			toColor( -- 1813
				PALETTE.xuanInk, -- 1813
				math.floor(170 * alpha + 0.5) -- 1813
			) -- 1813
		) -- 1813
		inkDraw:drawSegment( -- 1814
			Vec2(cx + 50 * s, cy - 2 * s), -- 1814
			Vec2(cx + 80 * s, cy + 1 * s), -- 1814
			1.2 * s, -- 1814
			toColor( -- 1814
				PALETTE.xuanInk, -- 1814
				math.floor(160 * alpha + 0.5) -- 1814
			) -- 1814
		) -- 1814
	end -- 1814
end -- 1770
function TowerEndingsPlugin.prototype.drawWarmPorcelainBowl(self, bgDraw, inkDraw, uiArt, glow, cx, cy, s, alpha, heldByTwoHands, handsK) -- 1819
	local op = clamp01(alpha) -- 1831
	bgDraw:drawEllipse( -- 1832
		Vec2(cx, cy - 46 * s), -- 1832
		64 * s, -- 1832
		14 * s, -- 1832
		Color( -- 1832
			8, -- 1832
			9, -- 1832
			14, -- 1832
			math.floor(138 * op + 0.5) -- 1832
		) -- 1832
	) -- 1832
	if not uiArt:tryPlacePath( -- 1832
		"assets/art/cutscene_story_parts.clip|porridge_bowl", -- 1834
		"fe05_desk_porridge_bowl", -- 1835
		cx, -- 1836
		cy - 4 * s, -- 1837
		162 * s, -- 1838
		124 * s, -- 1839
		{ -- 1840
			anchorX = 0.5, -- 1841
			anchorY = 0.5, -- 1842
			opacity = op, -- 1843
			smooth = true, -- 1844
			layer = 5 -- 1845
		} -- 1845
	) then -- 1845
		local a = math.floor(255 * op + 0.5) -- 1848
		inkDraw:drawEllipse( -- 1849
			Vec2(cx, cy + 8 * s), -- 1849
			64 * s, -- 1849
			21 * s, -- 1849
			Color(224, 218, 206, a) -- 1849
		) -- 1849
	end -- 1849
	local wi = 0 -- 1853
	do -- 1853
		wi = 0 -- 1854
		while wi < 4 do -- 1854
			local cyc = (self.animTime * 0.36 + wi * 0.25) % 1 -- 1855
			local sx = cx + (wi - 1.5) * 20 * s + math.sin(self.animTime * 1.4 + wi * 2.1) * (8 + cyc * 10) * s -- 1856
			local sy = cy + (24 + cyc * 58) * s -- 1857
			local sr = (18 + cyc * 24) * s -- 1858
			local wa = math.floor(math.sin(cyc * math.pi) * 34 * op + 0.5) -- 1859
			if wa > 2 then -- 1859
				fillRadialGlow( -- 1861
					glow, -- 1861
					sx, -- 1861
					sy, -- 1861
					sr, -- 1861
					sr * 1.35, -- 1861
					Color(246, 238, 224, wa), -- 1861
					Color(246, 238, 224, 0), -- 1861
					12 -- 1861
				) -- 1861
			end -- 1861
			wi = wi + 1 -- 1854
		end -- 1854
	end -- 1854
	if heldByTwoHands and handsK > 0.02 then -- 1854
		local liftY = (1 - handsK) * 36 * s -- 1867
		local handOp = clamp01(handsK * op) -- 1868
		uiArt:tryPlacePath( -- 1869
			"assets/art/cutscene_story_parts.clip|xiaoman_cup_hands", -- 1870
			"fe05_m03_xiaoman_cup_hands", -- 1871
			cx, -- 1872
			cy - 34 * s - liftY, -- 1873
			258 * s, -- 1874
			186 * s, -- 1875
			{ -- 1876
				anchorX = 0.5, -- 1877
				anchorY = 0.5, -- 1878
				opacity = handOp, -- 1879
				smooth = true, -- 1880
				layer = 6 -- 1881
			} -- 1881
		) -- 1881
	end -- 1881
end -- 1819
function TowerEndingsPlugin.prototype.drawMingLantern(self, draw, glow, cx, cy, scale, alpha, warmth) -- 1888
	local a = math.floor(255 * clamp01(alpha) + 0.5) -- 1897
	local flicker = 0.92 + 0.08 * math.sin(self.animTime * 7.2) -- 1898
	draw:drawSegment( -- 1900
		Vec2(cx - 10 * scale, cy + 28 * scale), -- 1900
		Vec2(cx, cy + 40 * scale), -- 1900
		1.8 * scale, -- 1900
		Color(88, 86, 82, a) -- 1900
	) -- 1900
	draw:drawSegment( -- 1901
		Vec2(cx + 10 * scale, cy + 28 * scale), -- 1901
		Vec2(cx, cy + 40 * scale), -- 1901
		1.8 * scale, -- 1901
		Color(88, 86, 82, a) -- 1901
	) -- 1901
	draw:drawRect( -- 1903
		Rect(cx - 17 * scale, cy + 22 * scale, 34 * scale, 7 * scale), -- 1903
		Color(62, 46, 34, a), -- 1903
		1, -- 1903
		Color(118, 92, 66, a) -- 1903
	) -- 1903
	draw:drawRect( -- 1904
		Rect(cx - 18 * scale, cy - 26 * scale, 36 * scale, 8 * scale), -- 1904
		Color(62, 46, 34, a), -- 1904
		1, -- 1904
		Color(118, 92, 66, a) -- 1904
	) -- 1904
	draw:drawRect( -- 1906
		Rect(cx - 14 * scale, cy - 18 * scale, 28 * scale, 40 * scale), -- 1907
		Color( -- 1908
			238, -- 1908
			198, -- 1908
			132, -- 1908
			math.floor(230 * alpha * (0.75 + 0.25 * warmth) + 0.5) -- 1908
		), -- 1908
		1.4 * scale, -- 1909
		Color(94, 70, 48, a) -- 1910
	) -- 1910
	draw:drawSegment( -- 1912
		Vec2(cx, cy - 18 * scale), -- 1912
		Vec2(cx, cy + 22 * scale), -- 1912
		1.1 * scale, -- 1912
		Color( -- 1912
			94, -- 1912
			70, -- 1912
			48, -- 1912
			math.floor(150 * alpha + 0.5) -- 1912
		) -- 1912
	) -- 1912
	draw:drawEllipse( -- 1913
		Vec2(cx, cy + 2 * scale), -- 1913
		4.6 * scale * flicker, -- 1913
		8.5 * scale * flicker, -- 1913
		Color(255, 244, 212, a) -- 1913
	) -- 1913
	fillRadialGlow( -- 1915
		glow, -- 1916
		cx, -- 1916
		cy + 2 * scale, -- 1916
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 1917
		94 * scale * flicker * (0.75 + 0.35 * warmth), -- 1918
		Color( -- 1919
			250, -- 1919
			208, -- 1919
			132, -- 1919
			math.floor(128 * alpha * warmth + 0.5) -- 1919
		), -- 1919
		Color(228, 162, 74, 0), -- 1920
		16 -- 1921
	) -- 1921
end -- 1888
function TowerEndingsPlugin.prototype.drawDialogueSubtitle(self, uiDraw, uiInkDraw, uiArt, ctx, route, s, barH) -- 1925
	local line = self.lastSubtitle -- 1934
	if line ~= "" then -- 1934
		local cy = barH + 34 * s -- 1936
		local stripW = math.min(ctx.uiW - 120 * s, 720 * s) -- 1937
		drawSilkVeil( -- 1938
			uiDraw, -- 1938
			uiArt, -- 1938
			"fe05_sub_veil", -- 1938
			ctx.uiW * 0.5, -- 1938
			cy, -- 1938
			stripW, -- 1938
			48 * s, -- 1938
			PALETTE.inkWash, -- 1938
			0.82, -- 1938
			3 -- 1938
		) -- 1938
		drawHairline( -- 1939
			uiInkDraw, -- 1939
			uiArt, -- 1939
			"fe05_sub_hair", -- 1939
			ctx.uiW * 0.5, -- 1939
			cy + 21 * s, -- 1939
			stripW * 0.68, -- 1939
			PALETTE.silkDim, -- 1939
			0.54, -- 1939
			true, -- 1939
			4 -- 1939
		) -- 1939
		local isSpoken = line == F03_DIALOGUE or line == M03_DIALOGUE -- 1940
		ctx.texts:put( -- 1941
			isSpoken and "md" or "sm", -- 1942
			line, -- 1943
			ctx.uiW * 0.5, -- 1944
			cy - 1 * s, -- 1945
			toColor(isSpoken and PALETTE.amberCore or PALETTE.textBright), -- 1946
			0.5, -- 1947
			0.5, -- 1948
			"Center", -- 1949
			isSpoken and 1.8 or 1, -- 1950
			0.98, -- 1951
			0.08 -- 1952
		) -- 1952
	end -- 1952
	if ctx.view.assistHintsEnabled and self.confirmReady then -- 1952
		local rawHint = route == "child" and "按 E 收页 · 尾声与史话   ·   Esc 暂歇" or "团圆尾声   ·   按 E 收页与史话   ·   Esc 暂歇" -- 1958
		local hint = getActiveTarget():adaptHintSentence(rawHint, ctx.input.inputMode, ctx.input.gamepadLayout) -- 1961
		ctx.texts:put( -- 1962
			"xs", -- 1962
			hint, -- 1962
			ctx.uiW * 0.5, -- 1962
			barH * 0.5, -- 1962
			toColor(PALETTE.textMid), -- 1962
			0.5, -- 1962
			0.5, -- 1962
			"Center", -- 1962
			1.4, -- 1962
			0.88, -- 1962
			0.08 -- 1962
		) -- 1962
	end -- 1962
end -- 1925
function ____exports.createTowerEndingsPlugin() -- 1967
	return __TS__New(____exports.TowerEndingsPlugin) -- 1968
end -- 1967
--- 供 M2 接线或独立验收脚本一键挂载（按 id 幂等覆盖）
function ____exports.attachTowerEndingsPlugin(fe) -- 1972
	local plugin = __TS__New(____exports.TowerEndingsPlugin) -- 1973
	fe:registerPlugin(plugin) -- 1974
	return plugin -- 1975
end -- 1972
return ____exports -- 1972