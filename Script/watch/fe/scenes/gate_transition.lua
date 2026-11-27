-- [ts]: gate_transition.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 24
local Color = ____Dora.Color -- 24
local Rect = ____Dora.Rect -- 24
local Vec2 = ____Dora.Vec2 -- 24
local ____play = require("Script.watch.play") -- 25
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 25
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 30
local adaptHintSentence = ____control_prompts.adaptHintSentence -- 30
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 31
local clamp01 = ____lowpoly.clamp01 -- 37
local smoothstep = ____lowpoly.smoothstep -- 39
local ____theme = require("Script.watch.fe.theme") -- 42
local PALETTE = ____theme.PALETTE -- 43
local drawHairline = ____theme.drawHairline -- 44
local drawMistCurve = ____theme.drawMistCurve -- 45
local drawSilkVeil = ____theme.drawSilkVeil -- 46
local fillRadialGlow = ____theme.fillRadialGlow -- 47
local fillVGradRect = ____theme.fillVGradRect -- 48
local lerpRGBA = ____theme.lerpRGBA -- 49
local rgba = ____theme.rgba -- 50
local toColor = ____theme.toColor -- 51
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 53
local drawChildColdMoonGrade = ____slideshow.drawChildColdMoonGrade -- 53
local COUNT_ZH = { -- 55
	"", -- 56
	"一", -- 56
	"二", -- 56
	"三", -- 56
	"四", -- 56
	"五", -- 56
	"六", -- 56
	"七", -- 56
	"八", -- 56
	"九", -- 56
	"十", -- 56
	"十一", -- 57
	"十二", -- 57
	"十三", -- 57
	"十四", -- 57
	"十五", -- 57
	"十六", -- 57
	"十七", -- 57
	"十八", -- 57
	"十九", -- 57
	"二十" -- 57
} -- 57
local GATE_AUDIO_ROOT = "assets/audio/gate/" -- 60
local GATE_ANCHOR_FOOT_FRAC_X = 0.36 -- 61
local GATE_ANCHOR_FOOT_FRAC_Y = 0.27 -- 62
local GATE_ANCHOR_ZOOM = 1.15 -- 63
local GATE_FOCAL = 410 -- 64
local GATE_VP_FRAC_X = 0.56 -- 65
local GATE_VP_FRAC_Y = 0.54 -- 66
--- 与 cuff_shots.ts G05 抬镜回切像素风同步的时序常数（秒）
____exports.G05_PIXEL_RETURN_START = 0.25 -- 69
____exports.G05_PIXEL_RETURN_END = 1.15 -- 70
local function pad2(n) -- 92
	local v = math.max( -- 93
		0, -- 93
		math.floor(n) -- 93
	) -- 93
	return v < 10 and "0" .. tostring(v) or "" .. tostring(v) -- 94
end -- 92
local function countVoicePath(n) -- 97
	return ((GATE_AUDIO_ROOT .. "count_") .. pad2(n)) .. ".wav" -- 98
end -- 97
local function countVoiceVolume(n) -- 101
	if n == 19 then -- 101
		return 0.68 -- 103
	end -- 103
	if n == 18 then -- 103
		return 0.8 -- 106
	end -- 106
	if n == 20 then -- 106
		return 0.96 -- 109
	end -- 109
	return 0.84 -- 111
end -- 101
____exports.GateTransitionPlugin = __TS__Class() -- 114
local GateTransitionPlugin = ____exports.GateTransitionPlugin -- 114
GateTransitionPlugin.name = "GateTransitionPlugin" -- 114
function GateTransitionPlugin.prototype.____constructor(self) -- 114
	self.id = "fe-01-gate-transition" -- 115
	self.animTime = 0 -- 117
	self.active = false -- 118
	self.wasActive = false -- 119
	self.rawMorph = 0 -- 120
	self.effectiveMorph = 0 -- 121
	self.lastCountTick = -1 -- 122
	self.lastTriggeredCount = 0 -- 123
	self.countCueAge = 99 -- 124
	self.pendingBreath19 = false -- 125
	self.activeCountZh = "" -- 126
	self.g04LineAge = -1 -- 127
	self.g04LineTriggered = false -- 128
	self.reunionTimer = 0 -- 129
	self.reunionPixelReturn = 0 -- 130
	self.rehearsalKnockTimer = -1 -- 131
	self.rehearsalKnockStage = 0 -- 132
	self.lockFootX = 890 -- 133
	self.lockThresholdX = 848 -- 134
	self.subtitleCountShown = 0 -- 135
	self.gestureChangeCount = 0 -- 136
	self.lastGestureStage = 0 -- 137
	self.activeProjection = { -- 138
		morph = 0, -- 139
		focal = GATE_FOCAL, -- 140
		vpFracX = GATE_VP_FRAC_X, -- 141
		vpFracY = GATE_VP_FRAC_Y, -- 142
		vpOffsetX = 0, -- 143
		vpOffsetY = 0, -- 144
		baseDepth = 0 -- 145
	} -- 145
end -- 114
function GateTransitionPlugin.prototype.onBindPlay(self, _p, _view) -- 148
	self:resetState() -- 149
end -- 148
function GateTransitionPlugin.prototype.resetState(self) -- 152
	self.animTime = 0 -- 153
	self.active = false -- 154
	self.wasActive = false -- 155
	self.rawMorph = 0 -- 156
	self.effectiveMorph = 0 -- 157
	self.lastCountTick = -1 -- 158
	self.lastTriggeredCount = 0 -- 159
	self.countCueAge = 99 -- 160
	self.pendingBreath19 = false -- 161
	self.activeCountZh = "" -- 162
	self.g04LineAge = -1 -- 163
	self.g04LineTriggered = false -- 164
	self.reunionTimer = 0 -- 165
	self.reunionPixelReturn = 0 -- 166
	self.rehearsalKnockTimer = -1 -- 167
	self.rehearsalKnockStage = 0 -- 168
	self.subtitleCountShown = 0 -- 169
	self.gestureChangeCount = 0 -- 170
	self.lastGestureStage = 0 -- 171
end -- 152
function GateTransitionPlugin.prototype.getProjection(self) -- 174
	return self.activeProjection -- 175
end -- 174
function GateTransitionPlugin.prototype.getDebugState(self) -- 178
	local earToDoor = self.active and self.lastCountTick >= 1080 and self.lastCountTick < GATE_COUNT_END -- 179
	local breathPause = self.active and self.lastCountTick >= 1260 and self.lastCountTick < GATE_COUNT_END -- 180
	return { -- 181
		active = self.active, -- 182
		morph = self.rawMorph, -- 183
		effectiveMorph = self.effectiveMorph, -- 184
		countTick = math.max(0, self.lastCountTick), -- 185
		countNumber = self.lastTriggeredCount, -- 186
		lastTriggeredCount = self.lastTriggeredCount, -- 187
		earToDoor = earToDoor, -- 188
		breathPause = breathPause, -- 189
		g04Idle = self.g04LineTriggered, -- 190
		g05Waiting = self.rehearsalKnockStage > 0 and self.reunionTimer <= 0, -- 191
		reunionTimer = self.reunionTimer, -- 192
		reunionPixelReturn = self.reunionPixelReturn, -- 193
		thresholdWorldX = self.lockThresholdX, -- 194
		footWorldX = self.lockFootX, -- 195
		rehearsalKnockStage = self.rehearsalKnockStage, -- 196
		subtitleCountShown = self.subtitleCountShown, -- 197
		gestureChangeCount = self.gestureChangeCount -- 198
	} -- 198
end -- 178
function GateTransitionPlugin.prototype.shouldActivate(self, p, view) -- 202
	if p.room.key ~= "gate" then -- 202
		return false -- 204
	end -- 204
	if p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 204
		return true -- 207
	end -- 207
	if p.phase == "gate-walk" and view.storyRoute ~= "soldier" then -- 207
		return true -- 210
	end -- 210
	return false -- 212
end -- 202
function GateTransitionPlugin.prototype.gestureStageForTick(self, tick, view) -- 215
	if view.storyRoute == "soldier" and (view.gateReunion.completed or view.gateReunion.active) then -- 215
		return 5 -- 217
	end -- 217
	if tick >= view.countDurationTicks then -- 217
		return 4 -- 220
	end -- 220
	if tick >= 1260 then -- 220
		return 3 -- 223
	end -- 223
	if tick >= 1080 then -- 223
		return 2 -- 226
	end -- 226
	if tick >= 480 then -- 226
		return 1 -- 229
	end -- 229
	return 0 -- 231
end -- 215
function GateTransitionPlugin.prototype.update(self, ctx) -- 234
	local p = ctx.p -- 235
	local view = ctx.view -- 236
	local want = self:shouldActivate(p, view) -- 237
	if not want then -- 237
		if self.wasActive then -- 237
			ctx.cam:setAnchorLock(nil) -- 241
			ctx.audio:stopLoop("gate_wind", 0.25) -- 242
			ctx.audio:stopLoop("gate_water", 0.25) -- 243
			ctx.audio:stopLoop("gate_breath", 0.2) -- 244
			self.wasActive = false -- 245
		end -- 245
		self.active = false -- 247
		return -- 248
	end -- 248
	self.active = true -- 251
	local justEntered = not self.wasActive -- 252
	self.wasActive = true -- 253
	local ____opt_0 = p.room.story -- 253
	local g = ____opt_0 and ____opt_0.gate -- 255
	local doorX = g ~= nil and g.doorX or p.ox + 860 -- 256
	self.lockThresholdX = doorX + 14 -- 258
	self.lockFootX = p.player.x -- 259
	if not ctx.paused then -- 259
		self.animTime = self.animTime + ctx.worldDt -- 262
		if self.countCueAge < 20 then -- 262
			self.countCueAge = self.countCueAge + ctx.worldDt -- 264
		end -- 264
		if self.g04LineAge >= 0 and self.g04LineAge < 20 then -- 264
			self.g04LineAge = self.g04LineAge + ctx.worldDt -- 267
		end -- 267
	end -- 267
	if p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-walk" then -- 267
		self.rawMorph = 1 -- 273
	else -- 273
		self.rawMorph = clamp01(view.countElapsedTicks / math.max(1, view.countDurationTicks)) -- 275
	end -- 275
	local reunionDone = p.phase == "gate-hand" or view.storyRoute == "soldier" and view.gateReunion.completed -- 279
	if reunionDone then -- 279
		if not ctx.paused then -- 279
			self.reunionTimer = self.reunionTimer + ctx.worldDt -- 282
		end -- 282
		self.reunionPixelReturn = smoothstep(____exports.G05_PIXEL_RETURN_START, ____exports.G05_PIXEL_RETURN_END, self.reunionTimer) -- 284
		self.effectiveMorph = clamp01(1 - self.reunionPixelReturn) -- 285
	else -- 285
		self.reunionTimer = 0 -- 287
		self.reunionPixelReturn = 0 -- 288
		self.effectiveMorph = self.rawMorph -- 289
	end -- 289
	local lockCamera = (p.phase == "gate-count" or p.phase == "gate-wait") and self.reunionPixelReturn < 0.98 -- 293
	if lockCamera then -- 293
		local tiltLift = self.reunionPixelReturn * 0.055 -- 296
		ctx.cam:setAnchorLock({ -- 297
			footWorldX = self.lockFootX, -- 298
			footWorldY = p.player.y, -- 299
			footDepth = p.player.depth, -- 300
			thresholdWorldX = self.lockThresholdX, -- 301
			screenFootFracX = GATE_ANCHOR_FOOT_FRAC_X, -- 302
			screenFootFracY = GATE_ANCHOR_FOOT_FRAC_Y - tiltLift, -- 303
			zoomOverride = GATE_ANCHOR_ZOOM + self.reunionPixelReturn * 0.07 -- 304
		}) -- 304
	else -- 304
		ctx.cam:setAnchorLock(nil) -- 307
	end -- 307
	local breathPhase = self.animTime * 1.35 -- 311
	local breatheAmp = self.effectiveMorph > 0.01 and p.phase == "gate-count" and 1 - self.reunionPixelReturn or 0 -- 312
	self.activeProjection = { -- 313
		morph = self.effectiveMorph, -- 314
		focal = GATE_FOCAL, -- 315
		vpFracX = GATE_VP_FRAC_X, -- 316
		vpFracY = GATE_VP_FRAC_Y, -- 317
		vpOffsetX = math.sin(breathPhase * 0.7) * 3.5 * breatheAmp, -- 318
		vpOffsetY = math.cos(breathPhase) * 2.5 * breatheAmp, -- 319
		baseDepth = p.player.depth -- 320
	} -- 320
	local tick = view.countElapsedTicks -- 324
	local countNum = math.max( -- 325
		1, -- 325
		math.min(20, view.countNumber) -- 325
	) -- 325
	local jumped = self.lastCountTick >= 0 and (tick < self.lastCountTick or tick - self.lastCountTick > 36) -- 326
	local stage = self:gestureStageForTick(tick, view) -- 327
	if justEntered and tick > 12 then -- 327
		self.lastTriggeredCount = countNum -- 331
		self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 332
		self.countCueAge = 0.6 -- 333
		self.lastGestureStage = stage -- 334
		if tick >= view.countDurationTicks and view.storyRoute ~= "soldier" then -- 334
			self.g04LineTriggered = true -- 336
			self.g04LineAge = 0.5 -- 337
		end -- 337
	elseif jumped then -- 337
		self.pendingBreath19 = false -- 340
		self.lastTriggeredCount = countNum -- 341
		self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 342
		self.countCueAge = 0.35 -- 343
		self.lastGestureStage = stage -- 344
		if tick < view.countDurationTicks then -- 344
			self.g04LineTriggered = false -- 346
			self.g04LineAge = -1 -- 347
			self.rehearsalKnockTimer = -1 -- 348
			self.rehearsalKnockStage = 0 -- 349
		end -- 349
	elseif not ctx.paused and (p.phase == "gate-count" or p.phase == "gate-wait") then -- 349
		if countNum > self.lastTriggeredCount then -- 349
			self.lastTriggeredCount = countNum -- 353
			self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 354
			self.countCueAge = 0 -- 355
			self.pendingBreath19 = countNum == 19 -- 356
			self.subtitleCountShown = self.subtitleCountShown + 1 -- 357
			local dedupeKey = (("gate:count:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(countNum) -- 358
			ctx.audio:playOnce( -- 359
				dedupeKey, -- 360
				"voice", -- 361
				countVoicePath(countNum), -- 362
				countVoiceVolume(countNum), -- 363
				"gate:count:" .. tostring(countNum), -- 364
				tick -- 365
			) -- 365
		end -- 365
		if stage ~= self.lastGestureStage then -- 365
			self.lastGestureStage = stage -- 369
			self.gestureChangeCount = self.gestureChangeCount + 1 -- 370
		end -- 370
	end -- 370
	if self.pendingBreath19 and self.countCueAge >= 0.78 and not ctx.paused and p.phase == "gate-count" then -- 370
		self.pendingBreath19 = false -- 375
		ctx.audio:playOnce( -- 376
			"gate:breath19:" .. tostring(ctx.events.roomSessionId), -- 377
			"voice", -- 378
			GATE_AUDIO_ROOT .. "breath_soft.wav", -- 379
			0.48, -- 380
			"gate:breath_19", -- 381
			tick -- 382
		) -- 382
	end -- 382
	local isChildWait = p.phase == "gate-count" and tick >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 387
	if isChildWait and not self.g04LineTriggered and not ctx.paused then -- 387
		self.g04LineTriggered = true -- 391
		self.g04LineAge = 0 -- 392
	end -- 392
	local isSoldierWait = view.storyRoute == "soldier" and (p.phase == "gate-wait" or p.phase == "gate-count" and view.gateReunion.active and not view.gateReunion.completed) -- 396
	if isSoldierWait and view.isRehearsal and not ctx.paused then -- 396
		if self.rehearsalKnockTimer < 0 then -- 396
			self.rehearsalKnockTimer = 0 -- 400
			self.rehearsalKnockStage = 1 -- 401
			ctx.audio:playOnce( -- 402
				"gate:rehearsal:knock:1:" .. tostring(ctx.events.roomSessionId), -- 403
				"sfx", -- 404
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 405
				0.88, -- 406
				"knock:gate:1", -- 407
				tick -- 408
			) -- 408
		else -- 408
			self.rehearsalKnockTimer = self.rehearsalKnockTimer + ctx.worldDt -- 411
			if self.rehearsalKnockStage < 2 and self.rehearsalKnockTimer >= 12 / 60 then -- 411
				self.rehearsalKnockStage = 2 -- 413
				ctx.audio:playOnce( -- 414
					"gate:rehearsal:knock:2:" .. tostring(ctx.events.roomSessionId), -- 415
					"sfx", -- 416
					GATE_AUDIO_ROOT .. "knock_wall.wav", -- 417
					0.92, -- 418
					"knock:gate:2", -- 419
					tick -- 420
				) -- 420
			end -- 420
		end -- 420
	end -- 420
	if not ctx.paused then -- 420
		local voiceDuck = p.phase == "gate-count" and countNum >= 18 and 0.32 + 0.68 * smoothstep(0.95, 1.55, self.countCueAge) or 1 -- 428
		local reunionCalm = reunionDone and 1 - self.reunionPixelReturn * 0.55 or 1 -- 430
		local windVol = (0.18 + 0.46 * self.effectiveMorph) * voiceDuck * reunionCalm -- 431
		local waterVol = (0.28 + 0.24 * self.effectiveMorph) * voiceDuck -- 432
		ctx.audio:playLoop( -- 433
			"gate_wind", -- 433
			"wind", -- 433
			GATE_AUDIO_ROOT .. "wind_loop.wav", -- 433
			windVol, -- 433
			tick -- 433
		) -- 433
		ctx.audio:playLoop( -- 434
			"gate_water", -- 434
			"water", -- 434
			GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 434
			waterVol, -- 434
			tick -- 434
		) -- 434
		if isChildWait then -- 434
			ctx.audio:playLoop( -- 436
				"gate_breath", -- 436
				"ambience", -- 436
				GATE_AUDIO_ROOT .. "breath_soft.wav", -- 436
				0.24, -- 436
				tick -- 436
			) -- 436
		else -- 436
			ctx.audio:stopLoop("gate_breath", 0.2) -- 438
		end -- 438
	end -- 438
	self.lastCountTick = tick -- 442
end -- 234
function GateTransitionPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 445
	if not self.active then -- 445
		return false -- 452
	end -- 452
	local cam = ctx.cam -- 454
	local w = cam.viewW -- 455
	local h = cam.viewH -- 456
	local m = self.effectiveMorph -- 457
	local skyTop = lerpRGBA( -- 460
		rgba(14, 10, 14, 255), -- 460
		rgba(8, 13, 22, 255), -- 460
		m -- 460
	) -- 460
	local skyBot = lerpRGBA( -- 461
		rgba(36, 22, 26, 255), -- 461
		rgba(22, 34, 48, 255), -- 461
		m -- 461
	) -- 461
	fillVGradRect( -- 462
		bgDraw, -- 462
		0, -- 462
		0, -- 462
		w, -- 462
		h, -- 462
		toColor(skyBot), -- 462
		toColor(skyTop) -- 462
	) -- 462
	local artW = math.max(w, h * 16 / 9) -- 467
	local artH = artW * 9 / 16 -- 468
	local artX = w * 0.5 -- 469
	local artY = (h - artH) * 0.5 -- 470
	local w0 = 1 - smoothstep(0.05, 0.28, m) -- 472
	local w1 = smoothstep(0.04, 0.25, m) * (1 - smoothstep(0.32, 0.55, m)) -- 473
	local w2 = smoothstep(0.28, 0.5, m) * (1 - smoothstep(0.58, 0.8, m)) -- 474
	local w3 = smoothstep(0.54, 0.76, m) * (1 - smoothstep(0.82, 0.98, m)) -- 475
	local w4 = smoothstep(0.78, 0.96, m) -- 476
	if w0 > 0.01 then -- 476
		backdropArt:tryPlace( -- 479
			"bgFar_gate", -- 479
			"gate_px_stage0", -- 479
			artX, -- 479
			artY, -- 479
			artW, -- 479
			artH, -- 479
			{opacity = w0, layer = 0} -- 479
		) -- 479
	end -- 479
	if w1 > 0.01 then -- 479
		backdropArt:tryPlace( -- 482
			"slide_gate_01", -- 482
			"gate_px_stage1", -- 482
			artX, -- 482
			artY, -- 482
			artW, -- 482
			artH, -- 482
			{opacity = w1, layer = 1} -- 482
		) -- 482
	end -- 482
	if w2 > 0.01 then -- 482
		backdropArt:tryPlace( -- 485
			"slide_gate_02", -- 485
			"gate_px_stage2", -- 485
			artX, -- 485
			artY, -- 485
			artW, -- 485
			artH, -- 485
			{opacity = w2, layer = 2} -- 485
		) -- 485
	end -- 485
	if w3 > 0.01 then -- 485
		backdropArt:tryPlace( -- 488
			"slide_gate_03", -- 488
			"gate_px_stage3", -- 488
			artX, -- 488
			artY, -- 488
			artW, -- 488
			artH, -- 488
			{opacity = w3, layer = 3} -- 488
		) -- 488
	end -- 488
	if w4 > 0.01 then -- 488
		backdropArt:tryPlace( -- 491
			"slide_gate_04", -- 491
			"gate_px_stage4", -- 491
			artX, -- 491
			artY, -- 491
			artW, -- 491
			artH, -- 491
			{opacity = w4, layer = 4} -- 491
		) -- 491
	end -- 491
	local beaconVis = smoothstep(0.55, 0.88, m) -- 495
	if beaconVis > 0.02 then -- 495
		local pulse = 0.82 + 0.18 * math.sin(self.animTime * 2.1) -- 497
		fillRadialGlow( -- 498
			bgGlow, -- 499
			w * 0.86, -- 500
			h * 0.64, -- 501
			26 * beaconVis * pulse, -- 502
			26 * beaconVis * pulse, -- 503
			Color( -- 504
				246, -- 504
				212, -- 504
				148, -- 504
				math.floor(78 * beaconVis * pulse + 0.5) -- 504
			), -- 504
			Color(232, 180, 96, 0), -- 505
			14 -- 506
		) -- 506
	end -- 506
	return true -- 510
end -- 445
function GateTransitionPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 513
	if not self.active then -- 513
		return false -- 520
	end -- 520
	local p = ctx.p -- 522
	local cam = ctx.cam -- 523
	local m = self.effectiveMorph -- 524
	local thX = self.lockThresholdX -- 525
	local doorLeft = thX - 108 -- 526
	local closeFrac = p.phase == "gate-count" and 0.44 + 0.56 * clamp01(ctx.view.countElapsedTicks / 360) or 1 -- 528
	local groundY = cam:sy(0, p.player.depth) -- 533
	local deckL = cam:sx(doorLeft - 140) -- 534
	local deckR = cam:sx(thX + 180) -- 535
	local tileW = math.max( -- 536
		48, -- 536
		math.floor(cam:len(54) + 0.5) -- 536
	) -- 536
	local tileH = math.max( -- 537
		12, -- 537
		math.floor(cam:len(16) + 0.5) -- 537
	) -- 537
	local tx = deckL -- 538
	local ti = 0 -- 539
	while tx < deckR and ti < 24 do -- 539
		worldArt:tryPlace( -- 541
			"fe_road_stone", -- 541
			"gate_px_road_" .. tostring(ti), -- 541
			tx + tileW * 0.5, -- 541
			groundY - tileH + 2, -- 541
			tileW + 2, -- 541
			tileH, -- 541
			{ -- 541
				opacity = 0.94, -- 542
				color = Color( -- 543
					math.floor(230 - 52 * m + 0.5), -- 543
					math.floor(234 - 38 * m + 0.5), -- 543
					math.floor(240 - 18 * m + 0.5), -- 543
					255 -- 543
				), -- 543
				layer = 12 -- 544
			} -- 544
		) -- 544
		tx = tx + tileW -- 546
		ti = ti + 1 -- 547
	end -- 547
	fgDraw:drawRect( -- 550
		Rect( -- 550
			0, -- 550
			0, -- 550
			cam.viewW, -- 550
			math.max(0, groundY - tileH + 3) -- 550
		), -- 550
		Color( -- 550
			8, -- 550
			11, -- 550
			18, -- 550
			math.floor(215 * (0.45 + 0.55 * m) + 0.5) -- 550
		) -- 550
	) -- 550
	local hidePartnerInside = self.reunionPixelReturn < 0.85 and closeFrac > 0.6 -- 553
	if hidePartnerInside then -- 553
		local wallRightX = cam:sx(thX - 1) -- 555
		local wallLeftX = cam:sx(doorLeft - 140) -- 556
		local wallW = math.max(2, wallRightX - wallLeftX) -- 557
		local wallTopY = cam:sy(164, p.player.depth) -- 558
		local wallBotY = cam:sy(0, p.player.depth) -- 559
		local wallH = math.max(2, wallTopY - wallBotY) -- 560
		local wallOp = clamp01((closeFrac - 0.6) / 0.28) * (1 - self.reunionPixelReturn) -- 561
		worldArt:tryPlace( -- 562
			"wall", -- 563
			"gate_closed_wall_mask", -- 564
			(wallLeftX + wallRightX) * 0.5, -- 565
			wallBotY, -- 566
			wallW, -- 567
			wallH, -- 568
			{ -- 569
				layer = 4102, -- 570
				color = Color( -- 571
					math.floor(92 - 28 * m + 0.5), -- 571
					math.floor(98 - 26 * m + 0.5), -- 571
					math.floor(112 - 20 * m + 0.5), -- 571
					255 -- 571
				), -- 571
				opacity = wallOp -- 572
			} -- 572
		) -- 572
		local doorPanelL = cam:sx(thX - 112) -- 575
		local doorPanelR = cam:sx(thX - 1) -- 576
		worldArt:tryPlace( -- 577
			"prop_tower_door", -- 578
			"gate_closed_door_leaf", -- 579
			(doorPanelL + doorPanelR) * 0.5, -- 580
			wallBotY, -- 581
			math.max(2, doorPanelR - doorPanelL), -- 582
			wallH, -- 583
			{ -- 584
				layer = 4103, -- 585
				color = Color( -- 586
					math.floor(138 - 34 * m + 0.5), -- 586
					math.floor(122 - 30 * m + 0.5), -- 586
					math.floor(108 - 22 * m + 0.5), -- 586
					255 -- 586
				), -- 586
				opacity = wallOp -- 587
			} -- 587
		) -- 587
	end -- 587
	local clothReveal = smoothstep(0.28, 0.55, m) -- 593
	if clothReveal > 0.02 then -- 593
		local clothX = cam:sx(thX + 244) -- 595
		local clothY = cam:sy(32, p.player.depth) -- 596
		worldArt:tryPlace( -- 597
			"fe_red_cloth", -- 597
			"gate_px_red_cloth", -- 597
			clothX, -- 597
			clothY, -- 597
			cam:len(30), -- 597
			cam:len(22), -- 597
			{ -- 597
				frame = math.floor(self.animTime * 4.5), -- 598
				opacity = clothReveal * 0.96, -- 599
				layer = 36 -- 600
			} -- 600
		) -- 600
	end -- 600
	local footSx = cam:sx(p.player.x) -- 605
	local footSy = cam:sy(p.player.y, p.player.depth) -- 606
	fgDraw:drawEllipse( -- 607
		Vec2(footSx, footSy + 1), -- 607
		cam:len(14), -- 607
		cam:len(4.2), -- 607
		Color( -- 607
			6, -- 607
			9, -- 607
			15, -- 607
			math.floor(165 + 45 * m + 0.5) -- 607
		) -- 607
	) -- 607
	drawChildColdMoonGrade( -- 610
		fgDraw, -- 610
		fgGlow, -- 610
		cam.viewW, -- 610
		cam.viewH, -- 610
		m * (1 - self.reunionPixelReturn), -- 610
		self.reunionPixelReturn -- 610
	) -- 610
	return true -- 612
end -- 513
function GateTransitionPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 615
	return self.active and ctx.p.phase ~= "gate-walk" -- 622
end -- 615
function GateTransitionPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 625
	if not self.active then -- 625
		return -- 632
	end -- 632
	local p = ctx.p -- 634
	local view = ctx.view -- 635
	local cam = ctx.cam -- 636
	local tick = view.countElapsedTicks -- 637
	local cx = cam:sx(p.player.x) -- 638
	local by = cam:sy(p.player.y, p.player.depth) -- 639
	local H = cam:len(p.player.h) -- 640
	if p.phase == "gate-count" and tick >= 1080 and tick < view.countDurationTicks then -- 640
		local leanK = smoothstep(1080, 1130, tick) -- 644
		local doorSx = cam:sx(self.lockThresholdX) -- 645
		local headY = by + H * 0.8 -- 646
		local earPulse = 0.55 + 0.45 * math.sin(self.animTime * 2.2) -- 648
		fgGlow:drawArc( -- 649
			Vec2(doorSx + 4, headY), -- 650
			12 + (1 - earPulse) * 8, -- 651
			-38, -- 651
			38, -- 653
			1.1, -- 654
			Color( -- 655
				214, -- 655
				224, -- 655
				236, -- 655
				math.floor(78 * leanK * earPulse + 0.5) -- 655
			) -- 655
		) -- 655
		if tick >= 1260 then -- 655
			local breathCycle = self.animTime * 0.7 % 1 -- 659
			local bAlpha = math.sin(breathCycle * math.pi) * 0.48 -- 660
			local bx = cx - 10 - breathCycle * 18 -- 661
			local bY = headY - 4 + breathCycle * 6 -- 662
			fillRadialGlow( -- 663
				fgGlow, -- 664
				bx, -- 665
				bY, -- 666
				12 + breathCycle * 10, -- 667
				7 + breathCycle * 6, -- 668
				Color( -- 669
					220, -- 669
					232, -- 669
					244, -- 669
					math.floor(110 * bAlpha + 0.5) -- 669
				), -- 669
				Color(180, 204, 228, 0), -- 670
				12 -- 671
			) -- 671
		end -- 671
	end -- 671
	local isChildIdle = p.phase == "gate-count" and tick >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 677
	if isChildIdle then -- 677
		local pouchX = cx + cam:len(6) -- 681
		local pouchY = by + H * 0.48 -- 682
		local pulse = 0.72 + 0.28 * math.sin(self.animTime * 2.4) -- 683
		fillRadialGlow( -- 684
			fgGlow, -- 685
			pouchX, -- 686
			pouchY, -- 687
			18 * pulse, -- 688
			18 * pulse, -- 689
			Color( -- 690
				236, -- 690
				198, -- 690
				128, -- 690
				math.floor(64 * pulse + 0.5) -- 690
			), -- 690
			Color(220, 168, 86, 0), -- 691
			12 -- 692
		) -- 692
		fgGlow:drawDot( -- 694
			Vec2(pouchX, pouchY), -- 694
			2.1, -- 694
			toColor( -- 694
				PALETTE.amberCore, -- 694
				math.floor(190 * pulse + 0.5) -- 694
			) -- 694
		) -- 694
	end -- 694
	local isSoldierWait = view.storyRoute == "soldier" and not view.gateReunion.completed and (p.phase == "gate-wait" or p.phase == "gate-count" and view.gateReunion.active) -- 698
	if isSoldierWait then -- 698
		local wallSx = cam:sx(self.lockThresholdX + 2) -- 702
		local knockY = by + H * 0.56 -- 703
		local ringCycle = self.animTime * 0.85 % 1 -- 704
		local r1 = 8 + ringCycle * 34 -- 705
		local a1 = (1 - ringCycle) * 0.72 -- 706
		fgGlow:drawRing( -- 707
			Vec2(wallSx, knockY), -- 707
			math.max(1, r1 - 1.5), -- 707
			r1, -- 707
			Color(0, 0, 0, 0), -- 707
			1.3, -- 707
			toColor(PALETTE.amber, 210 * a1) -- 707
		) -- 707
	end -- 707
end -- 625
function GateTransitionPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 711
	if not self.active then -- 711
		return false -- 719
	end -- 719
	local p = ctx.p -- 721
	local view = ctx.view -- 722
	local w = ctx.uiW -- 723
	local h = ctx.uiH -- 724
	if p.phase == "gate-walk" then -- 724
		return false -- 728
	end -- 728
	local barH = math.floor(52 * (1 - self.reunionPixelReturn * 0.35) + 0.5) -- 732
	uiDraw:drawRect( -- 733
		Rect(0, h - barH, w, barH), -- 733
		Color(8, 10, 16, 236) -- 733
	) -- 733
	uiDraw:drawRect( -- 734
		Rect(0, 0, w, barH), -- 734
		Color(8, 10, 16, 236) -- 734
	) -- 734
	uiInkDraw:drawSegment( -- 735
		Vec2(0, h - barH), -- 735
		Vec2(w, h - barH), -- 735
		0.7, -- 735
		toColor(PALETTE.silkDim, 68) -- 735
	) -- 735
	uiInkDraw:drawSegment( -- 736
		Vec2(0, barH), -- 736
		Vec2(w, barH), -- 736
		0.7, -- 736
		toColor(PALETTE.silkDim, 68) -- 736
	) -- 736
	local inCounting = p.phase == "gate-count" and view.countElapsedTicks < view.countDurationTicks -- 739
	if inCounting and self.activeCountZh ~= "" then -- 739
		local isBreathNum = view.countNumber == 19 -- 741
		local fadeIn = smoothstep(0, 0.16, self.countCueAge) -- 742
		local holdOut = 1 - smoothstep(isBreathNum and 2.1 or 1.15, isBreathNum and 2.85 or 1.65, self.countCueAge) -- 743
		local numAlpha = clamp01(fadeIn * math.max(0.28, holdOut)) * (isBreathNum and 0.68 or 0.9) -- 744
		local nx = w * 0.84 -- 746
		local ny = h * 0.74 -- 747
		drawMistCurve( -- 748
			uiArt, -- 748
			"gate_whisper_mist", -- 748
			nx, -- 748
			ny, -- 748
			190, -- 748
			44, -- 748
			PALETTE.jadeMist, -- 748
			0.18 * numAlpha, -- 748
			0 -- 748
		) -- 748
		ctx.texts:put( -- 749
			"banner", -- 750
			self.activeCountZh, -- 751
			nx, -- 752
			ny + 6, -- 753
			toColor(PALETTE.textBright), -- 754
			0.5, -- 755
			0.5, -- 756
			"Center", -- 757
			4, -- 758
			numAlpha, -- 759
			0.1 -- 760
		) -- 760
		local whisperText = view.countNumber == 18 and "「十八……」" or (view.countNumber == 19 and "「……十九……」" or ("「" .. self.activeCountZh) .. "……」") -- 763
		drawSilkVeil( -- 766
			uiDraw, -- 766
			uiArt, -- 766
			"gate_count_sub_veil", -- 766
			w * 0.5, -- 766
			26, -- 766
			320, -- 766
			36, -- 766
			PALETTE.inkWash, -- 766
			0.72 * numAlpha, -- 766
			-1 -- 766
		) -- 766
		ctx.texts:put( -- 767
			"sm", -- 767
			whisperText, -- 767
			w * 0.5, -- 767
			26, -- 767
			toColor(PALETTE.textMid), -- 767
			0.5, -- 767
			0.5, -- 767
			"Center", -- 767
			1.4, -- 767
			numAlpha, -- 767
			0.08 -- 767
		) -- 767
		return true -- 768
	end -- 768
	local isChildDone = p.phase == "gate-count" and view.countElapsedTicks >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 772
	if isChildDone then -- 772
		local lineAlpha = self.g04LineAge >= 0 and smoothstep(0, 0.25, self.g04LineAge) * (1 - smoothstep(3.8, 5.2, self.g04LineAge)) or 0.9 -- 776
		if lineAlpha > 0.02 then -- 776
			drawSilkVeil( -- 780
				uiDraw, -- 780
				uiArt, -- 780
				"gate_g04_veil", -- 780
				w * 0.5, -- 780
				26, -- 780
				460, -- 780
				38, -- 780
				PALETTE.inkWash, -- 780
				0.78 * lineAlpha, -- 780
				-1 -- 780
			) -- 780
			drawHairline( -- 781
				uiInkDraw, -- 781
				uiArt, -- 781
				"gate_g04_line", -- 781
				w * 0.5, -- 781
				44, -- 781
				300, -- 781
				PALETTE.silkDim, -- 781
				0.45 * lineAlpha, -- 781
				true, -- 781
				2 -- 781
			) -- 781
			ctx.texts:put( -- 782
				"sm", -- 783
				"「……二十了。我往北去了。」", -- 784
				w * 0.5, -- 785
				26, -- 786
				toColor(PALETTE.textBright), -- 787
				0.5, -- 788
				0.5, -- 789
				"Center", -- 790
				1.2, -- 791
				lineAlpha, -- 792
				0.08 -- 793
			) -- 793
		end -- 793
		if view.assistHintsEnabled then -- 793
			ctx.texts:put( -- 797
				"xs", -- 798
				adaptHintSentence("松开后重新按方向键迈步", ctx.input.inputMode, ctx.input.gamepadLayout), -- 799
				w * 0.5, -- 800
				h - 26, -- 801
				toColor(PALETTE.textDim), -- 802
				0.5, -- 803
				0.5, -- 804
				"Center", -- 805
				1.2, -- 806
				0.78, -- 807
				0.08 -- 808
			) -- 808
		end -- 808
		return true -- 811
	end -- 811
	return true -- 815
end -- 711
function ____exports.createGateTransitionPlugin() -- 819
	return __TS__New(____exports.GateTransitionPlugin) -- 820
end -- 819
return ____exports -- 819