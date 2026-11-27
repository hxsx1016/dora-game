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
local GATE_NIGHTMARE_LIGHT = ____lowpoly.GATE_NIGHTMARE_LIGHT -- 32
local LP_BUCKET = ____lowpoly.LP_BUCKET -- 33
local LowpolyScene = ____lowpoly.LowpolyScene -- 35
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 36
local clamp01 = ____lowpoly.clamp01 -- 37
local projectWorld3D = ____lowpoly.projectWorld3D -- 38
local smoothstep = ____lowpoly.smoothstep -- 39
local vec3 = ____lowpoly.vec3 -- 40
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
local COUNT_ZH = { -- 54
	"", -- 55
	"一", -- 55
	"二", -- 55
	"三", -- 55
	"四", -- 55
	"五", -- 55
	"六", -- 55
	"七", -- 55
	"八", -- 55
	"九", -- 55
	"十", -- 55
	"十一", -- 56
	"十二", -- 56
	"十三", -- 56
	"十四", -- 56
	"十五", -- 56
	"十六", -- 56
	"十七", -- 56
	"十八", -- 56
	"十九", -- 56
	"二十" -- 56
} -- 56
local GATE_AUDIO_ROOT = "assets/audio/gate/" -- 59
local GATE_ANCHOR_FOOT_FRAC_X = 0.36 -- 60
local GATE_ANCHOR_FOOT_FRAC_Y = 0.27 -- 61
local GATE_ANCHOR_ZOOM = 1.15 -- 62
local GATE_FOCAL = 410 -- 63
local GATE_VP_FRAC_X = 0.56 -- 64
local GATE_VP_FRAC_Y = 0.54 -- 65
--- 与 cuff_shots.ts G05 抬镜回切像素风同步的时序常数（秒）
____exports.G05_PIXEL_RETURN_START = 0.25 -- 68
____exports.G05_PIXEL_RETURN_END = 1.15 -- 69
local function pad2(n) -- 91
	local v = math.max( -- 92
		0, -- 92
		math.floor(n) -- 92
	) -- 92
	return v < 10 and "0" .. tostring(v) or "" .. tostring(v) -- 93
end -- 91
local function countVoicePath(n) -- 96
	return ((GATE_AUDIO_ROOT .. "count_") .. pad2(n)) .. ".wav" -- 97
end -- 96
local function countVoiceVolume(n) -- 100
	if n == 19 then -- 100
		return 0.68 -- 102
	end -- 102
	if n == 18 then -- 102
		return 0.8 -- 105
	end -- 105
	if n == 20 then -- 105
		return 0.96 -- 108
	end -- 108
	return 0.84 -- 110
end -- 100
____exports.GateTransitionPlugin = __TS__Class() -- 113
local GateTransitionPlugin = ____exports.GateTransitionPlugin -- 113
GateTransitionPlugin.name = "GateTransitionPlugin" -- 113
function GateTransitionPlugin.prototype.____constructor(self) -- 113
	self.id = "fe-01-gate-transition" -- 114
	self.animTime = 0 -- 116
	self.active = false -- 117
	self.wasActive = false -- 118
	self.rawMorph = 0 -- 119
	self.effectiveMorph = 0 -- 120
	self.lastCountTick = -1 -- 121
	self.lastTriggeredCount = 0 -- 122
	self.countCueAge = 99 -- 123
	self.pendingBreath19 = false -- 124
	self.activeCountZh = "" -- 125
	self.g04LineAge = -1 -- 126
	self.g04LineTriggered = false -- 127
	self.reunionTimer = 0 -- 128
	self.reunionPixelReturn = 0 -- 129
	self.rehearsalKnockTimer = -1 -- 130
	self.rehearsalKnockStage = 0 -- 131
	self.lockFootX = 890 -- 132
	self.lockThresholdX = 848 -- 133
	self.subtitleCountShown = 0 -- 134
	self.gestureChangeCount = 0 -- 135
	self.lastGestureStage = 0 -- 136
	self.activeProjection = { -- 137
		morph = 0, -- 138
		focal = GATE_FOCAL, -- 139
		vpFracX = GATE_VP_FRAC_X, -- 140
		vpFracY = GATE_VP_FRAC_Y, -- 141
		vpOffsetX = 0, -- 142
		vpOffsetY = 0, -- 143
		baseDepth = 0 -- 144
	} -- 144
end -- 113
function GateTransitionPlugin.prototype.onBindPlay(self, _p, _view) -- 147
	self:resetState() -- 148
end -- 147
function GateTransitionPlugin.prototype.resetState(self) -- 151
	self.animTime = 0 -- 152
	self.active = false -- 153
	self.wasActive = false -- 154
	self.rawMorph = 0 -- 155
	self.effectiveMorph = 0 -- 156
	self.lastCountTick = -1 -- 157
	self.lastTriggeredCount = 0 -- 158
	self.countCueAge = 99 -- 159
	self.pendingBreath19 = false -- 160
	self.activeCountZh = "" -- 161
	self.g04LineAge = -1 -- 162
	self.g04LineTriggered = false -- 163
	self.reunionTimer = 0 -- 164
	self.reunionPixelReturn = 0 -- 165
	self.rehearsalKnockTimer = -1 -- 166
	self.rehearsalKnockStage = 0 -- 167
	self.subtitleCountShown = 0 -- 168
	self.gestureChangeCount = 0 -- 169
	self.lastGestureStage = 0 -- 170
end -- 151
function GateTransitionPlugin.prototype.getProjection(self) -- 173
	return self.activeProjection -- 174
end -- 173
function GateTransitionPlugin.prototype.getDebugState(self) -- 177
	local earToDoor = self.active and self.lastCountTick >= 1080 and self.lastCountTick < GATE_COUNT_END -- 178
	local breathPause = self.active and self.lastCountTick >= 1260 and self.lastCountTick < GATE_COUNT_END -- 179
	return { -- 180
		active = self.active, -- 181
		morph = self.rawMorph, -- 182
		effectiveMorph = self.effectiveMorph, -- 183
		countTick = math.max(0, self.lastCountTick), -- 184
		countNumber = self.lastTriggeredCount, -- 185
		lastTriggeredCount = self.lastTriggeredCount, -- 186
		earToDoor = earToDoor, -- 187
		breathPause = breathPause, -- 188
		g04Idle = self.g04LineTriggered, -- 189
		g05Waiting = self.rehearsalKnockStage > 0 and self.reunionTimer <= 0, -- 190
		reunionTimer = self.reunionTimer, -- 191
		reunionPixelReturn = self.reunionPixelReturn, -- 192
		thresholdWorldX = self.lockThresholdX, -- 193
		footWorldX = self.lockFootX, -- 194
		rehearsalKnockStage = self.rehearsalKnockStage, -- 195
		subtitleCountShown = self.subtitleCountShown, -- 196
		gestureChangeCount = self.gestureChangeCount -- 197
	} -- 197
end -- 177
function GateTransitionPlugin.prototype.shouldActivate(self, p, view) -- 201
	if p.room.key ~= "gate" then -- 201
		return false -- 203
	end -- 203
	if p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 203
		return true -- 206
	end -- 206
	if p.phase == "gate-walk" and view.storyRoute ~= "soldier" then -- 206
		return true -- 209
	end -- 209
	return false -- 211
end -- 201
function GateTransitionPlugin.prototype.gestureStageForTick(self, tick, view) -- 214
	if view.storyRoute == "soldier" and (view.gateReunion.completed or view.gateReunion.active) then -- 214
		return 5 -- 216
	end -- 216
	if tick >= view.countDurationTicks then -- 216
		return 4 -- 219
	end -- 219
	if tick >= 1260 then -- 219
		return 3 -- 222
	end -- 222
	if tick >= 1080 then -- 222
		return 2 -- 225
	end -- 225
	if tick >= 480 then -- 225
		return 1 -- 228
	end -- 228
	return 0 -- 230
end -- 214
function GateTransitionPlugin.prototype.update(self, ctx) -- 233
	local p = ctx.p -- 234
	local view = ctx.view -- 235
	local want = self:shouldActivate(p, view) -- 236
	if not want then -- 236
		if self.wasActive then -- 236
			ctx.cam:setAnchorLock(nil) -- 240
			ctx.audio:stopLoop("gate_wind", 0.25) -- 241
			ctx.audio:stopLoop("gate_water", 0.25) -- 242
			ctx.audio:stopLoop("gate_breath", 0.2) -- 243
			self.wasActive = false -- 244
		end -- 244
		self.active = false -- 246
		return -- 247
	end -- 247
	self.active = true -- 250
	local justEntered = not self.wasActive -- 251
	self.wasActive = true -- 252
	local ____opt_0 = p.room.story -- 252
	local g = ____opt_0 and ____opt_0.gate -- 254
	local doorX = g ~= nil and g.doorX or p.ox + 860 -- 255
	self.lockThresholdX = doorX + 14 -- 257
	self.lockFootX = p.player.x -- 258
	if not ctx.paused then -- 258
		self.animTime = self.animTime + ctx.worldDt -- 261
		if self.countCueAge < 20 then -- 261
			self.countCueAge = self.countCueAge + ctx.worldDt -- 263
		end -- 263
		if self.g04LineAge >= 0 and self.g04LineAge < 20 then -- 263
			self.g04LineAge = self.g04LineAge + ctx.worldDt -- 266
		end -- 266
	end -- 266
	if p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-walk" then -- 266
		self.rawMorph = 1 -- 272
	else -- 272
		self.rawMorph = clamp01(view.countElapsedTicks / math.max(1, view.countDurationTicks)) -- 274
	end -- 274
	local reunionDone = p.phase == "gate-hand" or view.storyRoute == "soldier" and view.gateReunion.completed -- 278
	if reunionDone then -- 278
		if not ctx.paused then -- 278
			self.reunionTimer = self.reunionTimer + ctx.worldDt -- 281
		end -- 281
		self.reunionPixelReturn = smoothstep(____exports.G05_PIXEL_RETURN_START, ____exports.G05_PIXEL_RETURN_END, self.reunionTimer) -- 283
		self.effectiveMorph = clamp01(1 - self.reunionPixelReturn) -- 284
	else -- 284
		self.reunionTimer = 0 -- 286
		self.reunionPixelReturn = 0 -- 287
		self.effectiveMorph = self.rawMorph -- 288
	end -- 288
	local lockCamera = (p.phase == "gate-count" or p.phase == "gate-wait") and self.reunionPixelReturn < 0.98 -- 292
	if lockCamera then -- 292
		local tiltLift = self.reunionPixelReturn * 0.055 -- 295
		ctx.cam:setAnchorLock({ -- 296
			footWorldX = self.lockFootX, -- 297
			footWorldY = p.player.y, -- 298
			footDepth = p.player.depth, -- 299
			thresholdWorldX = self.lockThresholdX, -- 300
			screenFootFracX = GATE_ANCHOR_FOOT_FRAC_X, -- 301
			screenFootFracY = GATE_ANCHOR_FOOT_FRAC_Y - tiltLift, -- 302
			zoomOverride = GATE_ANCHOR_ZOOM + self.reunionPixelReturn * 0.07 -- 303
		}) -- 303
	else -- 303
		ctx.cam:setAnchorLock(nil) -- 306
	end -- 306
	local breathPhase = self.animTime * 1.35 -- 310
	local breatheAmp = self.effectiveMorph > 0.01 and p.phase == "gate-count" and 1 - self.reunionPixelReturn or 0 -- 311
	self.activeProjection = { -- 312
		morph = self.effectiveMorph, -- 313
		focal = GATE_FOCAL, -- 314
		vpFracX = GATE_VP_FRAC_X, -- 315
		vpFracY = GATE_VP_FRAC_Y, -- 316
		vpOffsetX = math.sin(breathPhase * 0.7) * 3.5 * breatheAmp, -- 317
		vpOffsetY = math.cos(breathPhase) * 2.5 * breatheAmp, -- 318
		baseDepth = p.player.depth -- 319
	} -- 319
	local tick = view.countElapsedTicks -- 323
	local countNum = math.max( -- 324
		1, -- 324
		math.min(20, view.countNumber) -- 324
	) -- 324
	local jumped = self.lastCountTick >= 0 and (tick < self.lastCountTick or tick - self.lastCountTick > 36) -- 325
	local stage = self:gestureStageForTick(tick, view) -- 326
	if justEntered and tick > 12 then -- 326
		self.lastTriggeredCount = countNum -- 330
		self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 331
		self.countCueAge = 0.6 -- 332
		self.lastGestureStage = stage -- 333
		if tick >= view.countDurationTicks and view.storyRoute ~= "soldier" then -- 333
			self.g04LineTriggered = true -- 335
			self.g04LineAge = 0.5 -- 336
		end -- 336
	elseif jumped then -- 336
		self.pendingBreath19 = false -- 339
		self.lastTriggeredCount = countNum -- 340
		self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 341
		self.countCueAge = 0.35 -- 342
		self.lastGestureStage = stage -- 343
		if tick < view.countDurationTicks then -- 343
			self.g04LineTriggered = false -- 345
			self.g04LineAge = -1 -- 346
			self.rehearsalKnockTimer = -1 -- 347
			self.rehearsalKnockStage = 0 -- 348
		end -- 348
	elseif not ctx.paused and (p.phase == "gate-count" or p.phase == "gate-wait") then -- 348
		if countNum > self.lastTriggeredCount then -- 348
			self.lastTriggeredCount = countNum -- 352
			self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 353
			self.countCueAge = 0 -- 354
			self.pendingBreath19 = countNum == 19 -- 355
			self.subtitleCountShown = self.subtitleCountShown + 1 -- 356
			local dedupeKey = (("gate:count:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(countNum) -- 357
			ctx.audio:playOnce( -- 358
				dedupeKey, -- 359
				"voice", -- 360
				countVoicePath(countNum), -- 361
				countVoiceVolume(countNum), -- 362
				"gate:count:" .. tostring(countNum), -- 363
				tick -- 364
			) -- 364
		end -- 364
		if stage ~= self.lastGestureStage then -- 364
			self.lastGestureStage = stage -- 368
			self.gestureChangeCount = self.gestureChangeCount + 1 -- 369
		end -- 369
	end -- 369
	if self.pendingBreath19 and self.countCueAge >= 0.78 and not ctx.paused and p.phase == "gate-count" then -- 369
		self.pendingBreath19 = false -- 374
		ctx.audio:playOnce( -- 375
			"gate:breath19:" .. tostring(ctx.events.roomSessionId), -- 376
			"voice", -- 377
			GATE_AUDIO_ROOT .. "breath_soft.wav", -- 378
			0.48, -- 379
			"gate:breath_19", -- 380
			tick -- 381
		) -- 381
	end -- 381
	local isChildWait = p.phase == "gate-count" and tick >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 386
	if isChildWait and not self.g04LineTriggered and not ctx.paused then -- 386
		self.g04LineTriggered = true -- 390
		self.g04LineAge = 0 -- 391
	end -- 391
	local isSoldierWait = view.storyRoute == "soldier" and (p.phase == "gate-wait" or p.phase == "gate-count" and view.gateReunion.active and not view.gateReunion.completed) -- 395
	if isSoldierWait and view.isRehearsal and not ctx.paused then -- 395
		if self.rehearsalKnockTimer < 0 then -- 395
			self.rehearsalKnockTimer = 0 -- 399
			self.rehearsalKnockStage = 1 -- 400
			ctx.audio:playOnce( -- 401
				"gate:rehearsal:knock:1:" .. tostring(ctx.events.roomSessionId), -- 402
				"sfx", -- 403
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 404
				0.88, -- 405
				"knock:gate:1", -- 406
				tick -- 407
			) -- 407
		else -- 407
			self.rehearsalKnockTimer = self.rehearsalKnockTimer + ctx.worldDt -- 410
			if self.rehearsalKnockStage < 2 and self.rehearsalKnockTimer >= 12 / 60 then -- 410
				self.rehearsalKnockStage = 2 -- 412
				ctx.audio:playOnce( -- 413
					"gate:rehearsal:knock:2:" .. tostring(ctx.events.roomSessionId), -- 414
					"sfx", -- 415
					GATE_AUDIO_ROOT .. "knock_wall.wav", -- 416
					0.92, -- 417
					"knock:gate:2", -- 418
					tick -- 419
				) -- 419
			end -- 419
		end -- 419
	end -- 419
	if not ctx.paused then -- 419
		local voiceDuck = p.phase == "gate-count" and countNum >= 18 and 0.32 + 0.68 * smoothstep(0.95, 1.55, self.countCueAge) or 1 -- 427
		local reunionCalm = reunionDone and 1 - self.reunionPixelReturn * 0.55 or 1 -- 429
		local windVol = (0.18 + 0.46 * self.effectiveMorph) * voiceDuck * reunionCalm -- 430
		local waterVol = (0.28 + 0.24 * self.effectiveMorph) * voiceDuck -- 431
		ctx.audio:playLoop( -- 432
			"gate_wind", -- 432
			"wind", -- 432
			GATE_AUDIO_ROOT .. "wind_loop.wav", -- 432
			windVol, -- 432
			tick -- 432
		) -- 432
		ctx.audio:playLoop( -- 433
			"gate_water", -- 433
			"water", -- 433
			GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 433
			waterVol, -- 433
			tick -- 433
		) -- 433
		if isChildWait then -- 433
			ctx.audio:playLoop( -- 435
				"gate_breath", -- 435
				"ambience", -- 435
				GATE_AUDIO_ROOT .. "breath_soft.wav", -- 435
				0.24, -- 435
				tick -- 435
			) -- 435
		else -- 435
			ctx.audio:stopLoop("gate_breath", 0.2) -- 437
		end -- 437
	end -- 437
	self.lastCountTick = tick -- 441
end -- 233
function GateTransitionPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 444
	if not self.active then -- 444
		return false -- 451
	end -- 451
	local cam = ctx.cam -- 453
	local w = cam.viewW -- 454
	local h = cam.viewH -- 455
	local m = self.effectiveMorph -- 456
	local skyTop = lerpRGBA( -- 459
		rgba(14, 10, 14, 255), -- 459
		rgba(8, 13, 22, 255), -- 459
		m -- 459
	) -- 459
	local skyMid = lerpRGBA( -- 460
		rgba(28, 17, 22, 255), -- 460
		rgba(16, 25, 38, 255), -- 460
		m -- 460
	) -- 460
	local skyHor = lerpRGBA( -- 461
		rgba(54, 28, 30, 255), -- 461
		rgba(30, 44, 62, 255), -- 461
		m -- 461
	) -- 461
	local splitY = h * 0.48 -- 462
	fillVGradRect( -- 463
		bgDraw, -- 463
		0, -- 463
		splitY, -- 463
		w, -- 463
		h - splitY, -- 463
		toColor(skyMid), -- 463
		toColor(skyTop) -- 463
	) -- 463
	fillVGradRect( -- 464
		bgDraw, -- 464
		0, -- 464
		0, -- 464
		w, -- 464
		splitY, -- 464
		toColor(skyHor), -- 464
		toColor(skyMid) -- 464
	) -- 464
	local pixelBgAlpha = 1 - smoothstep(0.08, 0.72, m) -- 467
	if pixelBgAlpha > 0.01 then -- 467
		local span = math.max(1, ctx.p.room.maxX - ctx.p.room.minX) -- 469
		local progress = (cam.x - ctx.p.room.minX) / span - 0.5 -- 470
		local artW = math.max(w, h * 16 / 9) + w * 0.12 -- 471
		local artH = artW * 9 / 16 -- 472
		backdropArt:tryPlace( -- 473
			"bgFar_gate", -- 473
			"gate_pixel_bg", -- 473
			w * (0.5 - progress * 0.09), -- 473
			(h - artH) * 0.5, -- 473
			artW, -- 473
			artH, -- 473
			{opacity = pixelBgAlpha, layer = 0} -- 473
		) -- 473
	end -- 473
	local farReveal = smoothstep(0.22, 0.85, m) -- 480
	if farReveal > 0.01 then -- 480
		local scene = __TS__New(LowpolyScene, cam, self.activeProjection, GATE_NIGHTMARE_LIGHT) -- 482
		local xMin = self.lockThresholdX - 320 -- 483
		local xMax = self.lockThresholdX + 680 -- 484
		local hillSep = smoothstep(0.45, 0.88, m) -- 487
		scene:addDistantRidge( -- 488
			{ -- 489
				{x = xMin, y = 112}, -- 490
				{x = self.lockThresholdX - 60, y = 176}, -- 491
				{x = self.lockThresholdX + 120, y = 146}, -- 492
				{x = self.lockThresholdX + 280, y = 204}, -- 493
				{x = self.lockThresholdX + 460, y = 164}, -- 494
				{x = xMax, y = 132} -- 495
			}, -- 495
			-40, -- 495
			520, -- 498
			MING_MATERIALS.distantHill, -- 499
			{bucket = LP_BUCKET.BACKDROP, opacity = farReveal * (0.55 + 0.45 * hillSep)} -- 500
		) -- 500
		scene:addFogBand( -- 504
			xMin, -- 504
			xMax, -- 504
			-30, -- 504
			190, -- 504
			360, -- 504
			rgba(38, 54, 74, 255), -- 504
			0.72 * hillSep, -- 504
			0.06 * hillSep, -- 504
			{bucket = LP_BUCKET.BACKDROP} -- 504
		) -- 504
		local wallMat = MING_MATERIALS.distantWall -- 509
		scene:addBox({ -- 510
			x0 = self.lockThresholdX + 40, -- 511
			x1 = xMax, -- 512
			y0 = -48, -- 513
			y1 = 96, -- 514
			z0 = 215, -- 515
			z1 = 260, -- 516
			material = wallMat, -- 517
			bucket = LP_BUCKET.BACKDROP, -- 518
			opacity = farReveal, -- 519
			highlightTopEdge = true, -- 520
			edgeWidth = 0 -- 521
		}) -- 521
		local merlonX = self.lockThresholdX + 64 -- 524
		local mi = 0 -- 525
		do -- 525
			mi = 0 -- 526
			while mi < 10 do -- 526
				scene:addBox({ -- 527
					x0 = merlonX, -- 528
					x1 = merlonX + 28, -- 529
					y0 = 96, -- 530
					y1 = 112, -- 531
					z0 = 215, -- 532
					z1 = 242, -- 533
					material = wallMat, -- 534
					bucket = LP_BUCKET.BACKDROP, -- 535
					opacity = farReveal, -- 536
					sortBias = 0.05, -- 537
					edgeWidth = 0 -- 538
				}) -- 538
				merlonX = merlonX + 56 -- 540
				mi = mi + 1 -- 526
			end -- 526
		end -- 526
		scene:addFogBand( -- 544
			xMin, -- 544
			xMax, -- 544
			-44, -- 544
			108, -- 544
			148, -- 544
			rgba(32, 46, 66, 255), -- 544
			0.64 * farReveal, -- 544
			0.04, -- 544
			{bucket = LP_BUCKET.BACKDROP} -- 544
		) -- 544
		local beaconP = projectWorld3D( -- 549
			self.lockThresholdX + 210, -- 549
			146, -- 549
			490, -- 549
			cam, -- 549
			self.activeProjection -- 549
		) -- 549
		local pulse = 0.82 + 0.18 * math.sin(self.animTime * 2.1) -- 550
		fillRadialGlow( -- 551
			bgGlow, -- 552
			beaconP.x, -- 553
			beaconP.y, -- 554
			34 * farReveal * pulse, -- 555
			34 * farReveal * pulse, -- 556
			Color( -- 557
				246, -- 557
				212, -- 557
				148, -- 557
				math.floor(92 * farReveal * pulse + 0.5) -- 557
			), -- 557
			Color(232, 180, 96, 0), -- 558
			16 -- 559
		) -- 559
		bgGlow:drawDot( -- 561
			Vec2(beaconP.x, beaconP.y), -- 561
			2.6 * farReveal, -- 561
			Color( -- 561
				255, -- 561
				244, -- 561
				212, -- 561
				math.floor(235 * farReveal + 0.5) -- 561
			) -- 561
		) -- 561
		local moatY = -36 -- 564
		local waterA = 0.42 * farReveal -- 565
		local ri = 0 -- 566
		do -- 566
			ri = 0 -- 567
			while ri < 6 do -- 567
				local rx = self.lockThresholdX + 110 + ri * 68 + math.sin(self.animTime * 1.1 + ri * 1.7) * 8 -- 568
				local pL = projectWorld3D( -- 569
					rx - 18, -- 569
					moatY - ri % 2 * 6, -- 569
					128 + ri * 12, -- 569
					cam, -- 569
					self.activeProjection -- 569
				) -- 569
				local pR = projectWorld3D( -- 570
					rx + 18, -- 570
					moatY - ri % 2 * 6, -- 570
					128 + ri * 12, -- 570
					cam, -- 570
					self.activeProjection -- 570
				) -- 570
				bgGlow:drawSegment( -- 571
					Vec2(pL.x, pL.y), -- 571
					Vec2(pR.x, pR.y), -- 571
					1.1, -- 571
					Color( -- 571
						168, -- 571
						198, -- 571
						224, -- 571
						math.floor(90 * waterA + 0.5) -- 571
					) -- 571
				) -- 571
				ri = ri + 1 -- 567
			end -- 567
		end -- 567
		scene:flush(bgDraw, bgGlow, ctx.dioramaBg) -- 574
	end -- 574
	local mx = w * 0.66 -- 578
	local my = h * 0.82 -- 579
	local mr = math.max(15, h * 0.032) -- 580
	fillRadialGlow( -- 581
		bgGlow, -- 581
		mx, -- 581
		my, -- 581
		mr * 4.8, -- 581
		mr * 4.8, -- 581
		Color( -- 581
			164, -- 581
			202, -- 581
			232, -- 581
			math.floor(18 + 20 * m + 0.5) -- 581
		), -- 581
		Color(24, 42, 68, 0), -- 581
		18 -- 581
	) -- 581
	bgDraw:drawCircle( -- 582
		Vec2(mx, my), -- 582
		mr, -- 582
		Color( -- 582
			218, -- 582
			232, -- 582
			246, -- 582
			math.floor(115 + 85 * m + 0.5) -- 582
		) -- 582
	) -- 582
	return true -- 584
end -- 444
function GateTransitionPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 587
	if not self.active then -- 587
		return false -- 594
	end -- 594
	local p = ctx.p -- 596
	local cam = ctx.cam -- 597
	local m = self.effectiveMorph -- 598
	local thX = self.lockThresholdX -- 599
	local doorLeft = thX - 108 -- 600
	local scene = __TS__New(LowpolyScene, cam, self.activeProjection, GATE_NIGHTMARE_LIGHT) -- 602
	local closeFrac = p.phase == "gate-count" and 0.44 + 0.56 * clamp01(ctx.view.countElapsedTicks / 360) or 1 -- 605
	local stepReveal = smoothstep(0.18, 0.58, m) -- 610
	if stepReveal > 0.01 then -- 610
		local stairSpec = { -- 612
			x0 = thX + 108, -- 613
			x1 = thX + 292, -- 614
			y0 = -56, -- 615
			y1 = 2, -- 616
			steps = 5, -- 617
			label = "外壕石阶" -- 618
		} -- 618
		local k = 0 -- 621
		local n = stairSpec.steps + 1 -- 622
		local stepW = (stairSpec.x1 - stairSpec.x0) / n -- 623
		do -- 623
			k = 0 -- 624
			while k < n do -- 624
				local wy = stairSpec.y1 - (stairSpec.y1 - stairSpec.y0) * (k / math.max(1, n - 1)) -- 625
				local sx0 = stairSpec.x0 + k * stepW -- 626
				local sx1 = sx0 + stepW + 1 -- 627
				scene:addBox({ -- 628
					x0 = sx0, -- 629
					x1 = sx1, -- 630
					y0 = -78, -- 631
					y1 = wy, -- 632
					z0 = 26, -- 633
					z1 = 106, -- 634
					material = MING_MATERIALS.mingStoneStep, -- 635
					bucket = LP_BUCKET.MIDGROUND, -- 636
					opacity = stepReveal, -- 637
					sortBias = k * 0.02, -- 638
					highlightTopEdge = true, -- 639
					edgeWidth = 0.9 -- 640
				}) -- 640
				k = k + 1 -- 624
			end -- 624
		end -- 624
	end -- 624
	local wallReveal = smoothstep(0.02, 0.22, m) -- 647
	local frameLightStrength = smoothstep(0.1, 0.34, m) * (1 - 0.35 * smoothstep(0.85, 1, m)) -- 648
	if wallReveal > 0.01 then -- 648
		scene:addBox({ -- 650
			x0 = doorLeft - 140, -- 651
			x1 = thX - 18, -- 652
			y0 = -60, -- 653
			y1 = 230, -- 654
			z0 = -12, -- 655
			z1 = 88, -- 656
			material = MING_MATERIALS.mingBrick, -- 657
			bucket = LP_BUCKET.MIDGROUND, -- 658
			opacity = wallReveal, -- 659
			highlightTopEdge = true, -- 660
			edgeWidth = 0.75 -- 661
		}) -- 661
		scene:addBox({ -- 664
			x0 = thX - 18, -- 665
			x1 = thX, -- 666
			y0 = 0, -- 667
			y1 = 162, -- 668
			z0 = -6, -- 669
			z1 = 72, -- 670
			material = MING_MATERIALS.mingStoneStep, -- 671
			bucket = LP_BUCKET.MIDGROUND, -- 672
			opacity = wallReveal, -- 673
			sortBias = 0.08, -- 674
			highlightTopEdge = true, -- 675
			edgeWidth = 0.9 -- 676
		}) -- 676
		scene:addBox({ -- 679
			x0 = doorLeft - 40, -- 680
			x1 = thX + 76, -- 681
			y0 = 160, -- 682
			y1 = 214, -- 683
			z0 = -14, -- 684
			z1 = 82, -- 685
			material = MING_MATERIALS.mingBrickDark, -- 686
			bucket = LP_BUCKET.MIDGROUND, -- 687
			opacity = wallReveal, -- 688
			sortBias = 0.12, -- 689
			highlightTopEdge = true, -- 690
			edgeWidth = 0.8 -- 691
		}) -- 691
	end -- 691
	if frameLightStrength > 0.02 then -- 691
		scene:addLightShaft( -- 697
			thX + 16, -- 698
			thX + 34, -- 698
			160, -- 698
			thX - 4, -- 699
			thX + 24, -- 699
			0, -- 699
			16, -- 700
			rgba(220, 234, 248, 255), -- 701
			0.24 * frameLightStrength, -- 702
			0.04 * frameLightStrength -- 703
		) -- 703
		local pBotNear = scene:project(thX, 0, -6) -- 706
		local pBotFar = scene:project(thX, 0, 72) -- 707
		local pTopFar = scene:project(thX, 160, 72) -- 708
		local pTopNear = scene:project(thX, 160, -6) -- 709
		local glowA = math.floor(140 * frameLightStrength + 0.5) -- 710
		fgGlow:drawVertices({ -- 711
			{ -- 712
				Vec2(pBotNear.x, pBotNear.y), -- 712
				Color(224, 236, 248, glowA) -- 712
			}, -- 712
			{ -- 713
				Vec2(pBotFar.x, pBotFar.y), -- 713
				Color( -- 713
					168, -- 713
					196, -- 713
					224, -- 713
					math.floor(glowA * 0.25 + 0.5) -- 713
				) -- 713
			}, -- 713
			{ -- 714
				Vec2(pTopFar.x, pTopFar.y), -- 714
				Color( -- 714
					168, -- 714
					196, -- 714
					224, -- 714
					math.floor(glowA * 0.25 + 0.5) -- 714
				) -- 714
			}, -- 714
			{ -- 715
				Vec2(pBotNear.x, pBotNear.y), -- 715
				Color(224, 236, 248, glowA) -- 715
			}, -- 715
			{ -- 716
				Vec2(pTopFar.x, pTopFar.y), -- 716
				Color( -- 716
					168, -- 716
					196, -- 716
					224, -- 716
					math.floor(glowA * 0.25 + 0.5) -- 716
				) -- 716
			}, -- 716
			{ -- 717
				Vec2(pTopNear.x, pTopNear.y), -- 717
				Color(224, 236, 248, glowA) -- 717
			} -- 717
		}) -- 717
	end -- 717
	local doorAlpha = 1 - self.reunionPixelReturn -- 722
	local doorBotY = 160 * (1 - closeFrac) -- 723
	if 160 - doorBotY > 2 and doorAlpha > 0.02 then -- 723
		scene:addBox({ -- 725
			x0 = thX - 122, -- 726
			x1 = thX - 2, -- 727
			y0 = doorBotY, -- 728
			y1 = 160, -- 729
			z0 = 4, -- 730
			z1 = 22, -- 731
			material = MING_MATERIALS.mingTimberDark, -- 732
			bucket = LP_BUCKET.MIDGROUND, -- 733
			opacity = doorAlpha, -- 734
			sortBias = 0.04, -- 735
			edgeWidth = 0.9 -- 736
		}) -- 736
		local bandYs = {doorBotY + 12, doorBotY + 42, doorBotY + 72} -- 739
		local bi = 0 -- 740
		do -- 740
			bi = 0 -- 741
			while bi < #bandYs do -- 741
				local byBand = bandYs[bi + 1] -- 742
				if byBand + 6 < 158 then -- 742
					scene:addBox({ -- 744
						x0 = thX - 120, -- 745
						x1 = thX - 4, -- 746
						y0 = byBand, -- 747
						y1 = byBand + 6, -- 748
						z0 = 2, -- 749
						z1 = 10, -- 750
						material = MING_MATERIALS.mingIron, -- 751
						bucket = LP_BUCKET.MIDGROUND, -- 752
						opacity = doorAlpha, -- 753
						sortBias = 0.06, -- 754
						edgeWidth = 0.5 -- 755
					}) -- 755
				end -- 755
				bi = bi + 1 -- 741
			end -- 741
		end -- 741
		if closeFrac < 0.98 then -- 741
			local gapAlpha = (1 - closeFrac) * 0.65 * doorAlpha -- 761
			scene:addLightShaft( -- 762
				thX - 96, -- 763
				thX - 2, -- 763
				math.max(4, doorBotY), -- 763
				thX - 86, -- 764
				thX + 26, -- 764
				0, -- 764
				2, -- 765
				rgba(232, 188, 128, 255), -- 766
				gapAlpha * 0.42, -- 767
				gapAlpha * 0.14 -- 768
			) -- 768
		end -- 768
	end -- 768
	scene:addBox({ -- 774
		x0 = thX - 10, -- 775
		x1 = thX + 12, -- 776
		y0 = -12, -- 777
		y1 = 2, -- 778
		z0 = -14, -- 779
		z1 = 28, -- 780
		material = MING_MATERIALS.mingStoneStep, -- 781
		bucket = LP_BUCKET.WALK_DECK, -- 782
		sortBias = 0.02, -- 783
		highlightTopEdge = true, -- 784
		edgeWidth = 1.1 -- 785
	}) -- 785
	scene:addBox({ -- 789
		x0 = doorLeft - 140, -- 790
		x1 = thX + 132, -- 791
		y0 = -68, -- 792
		y1 = 0, -- 793
		z0 = -20, -- 794
		z1 = 42, -- 795
		material = MING_MATERIALS.mingBrickDark, -- 796
		bucket = LP_BUCKET.WALK_DECK, -- 797
		sortBias = 0, -- 798
		highlightTopEdge = true, -- 799
		edgeWidth = 0.85 -- 800
	}) -- 800
	local plankReveal = smoothstep(0.14, 0.52, m) -- 804
	if plankReveal > 0.01 then -- 804
		local overhangZ0 = -10 - 48 * plankReveal -- 806
		scene:addPlankDeck( -- 807
			thX + 58, -- 808
			thX + 340, -- 809
			0, -- 810
			overhangZ0, -- 811
			22, -- 812
			5, -- 813
			11, -- 814
			MING_MATERIALS.mingTimber, -- 815
			{ -- 816
				bucket = LP_BUCKET.WALK_DECK, -- 817
				opacity = plankReveal, -- 818
				sortBias = 0.25, -- 819
				withPosts = true, -- 820
				postBottomY = -78 -- 821
			} -- 821
		) -- 821
		scene:addBox({ -- 825
			x0 = thX + 244, -- 826
			x1 = thX + 260, -- 827
			y0 = 0, -- 828
			y1 = 38, -- 829
			z0 = -12, -- 830
			z1 = 6, -- 831
			material = MING_MATERIALS.mingTimberDark, -- 832
			bucket = LP_BUCKET.PROP, -- 833
			opacity = plankReveal, -- 834
			highlightTopEdge = true -- 835
		}) -- 835
		local clothBaseX = thX + 244 -- 838
		local clothTopY = 34 -- 839
		local windFreq = 2.8 + m * 1.4 -- 840
		scene:addWavingQuad3D( -- 841
			vec3(clothBaseX - 11, clothTopY - 24, -15), -- 842
			vec3(clothBaseX + 5, clothTopY - 21, -13), -- 843
			vec3(clothBaseX + 8, clothTopY - 1, -12), -- 844
			vec3(clothBaseX - 1, clothTopY, -12), -- 845
			MING_MATERIALS.mingRedCloth, -- 846
			{ -- 847
				ampX = 4.5 + 5.5 * m, -- 847
				ampY = 2 + 1.5 * m, -- 847
				phase = self.animTime * windFreq, -- 847
				freqU = 1.6, -- 847
				freqV = 2.6, -- 847
				pin = "top" -- 847
			}, -- 847
			{ -- 848
				bucket = LP_BUCKET.PROP, -- 848
				opacity = plankReveal, -- 848
				sortBias = 0.35, -- 848
				subdivX = 3, -- 848
				subdivY = 4 -- 848
			} -- 848
		) -- 848
		scene:addCutout3D( -- 851
			"assets/art/diorama_cutouts.clip|north_tower_distant", -- 852
			thX + 365, -- 853
			18, -- 854
			250, -- 855
			74, -- 856
			95, -- 857
			{ -- 858
				bucket = LP_BUCKET.BACKDROP, -- 859
				opacity = 0.72 * plankReveal, -- 860
				color = rgba(146, 164, 186, 255), -- 861
				anchorX = 0.5, -- 862
				anchorY = 0, -- 863
				sortBias = 0.08 -- 864
			} -- 864
		) -- 864
		scene:addCutout3D( -- 867
			"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 868
			thX - 56, -- 869
			148, -- 870
			22, -- 871
			146, -- 872
			96, -- 873
			{ -- 874
				bucket = LP_BUCKET.MIDGROUND, -- 875
				opacity = 0.9, -- 876
				color = rgba(168, 184, 202, 255), -- 877
				anchorX = 0.5, -- 878
				anchorY = 0, -- 879
				sortBias = 0.12 -- 880
			} -- 880
		) -- 880
	end -- 880
	scene:addContactShadow( -- 886
		p.player.x, -- 886
		p.player.y, -- 886
		16, -- 886
		12, -- 886
		0.62 + 0.28 * m, -- 886
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 886
	) -- 886
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 892
	local hidePartnerInside = self.reunionPixelReturn < 0.85 and closeFrac > 0.6 -- 896
	if hidePartnerInside then -- 896
		local wallRightX = cam:sx(thX - 1) -- 898
		local wallLeftX = cam:sx(doorLeft - 140) -- 899
		local wallW = math.max(2, wallRightX - wallLeftX) -- 900
		local wallTopY = cam:sy(164, p.player.depth) -- 901
		local wallBotY = cam:sy(0, p.player.depth) -- 902
		local wallH = math.max(2, wallTopY - wallBotY) -- 903
		local wallOp = clamp01((closeFrac - 0.6) / 0.28) * (1 - self.reunionPixelReturn) -- 904
		worldArt:tryPlacePath( -- 905
			"assets/art/tex_diorama_ming.clip|ming_brick", -- 906
			"gate_closed_wall_mask", -- 907
			(wallLeftX + wallRightX) * 0.5, -- 908
			wallBotY, -- 909
			wallW, -- 910
			wallH, -- 911
			{ -- 912
				anchorX = 0.5, -- 913
				anchorY = 0, -- 914
				layer = 4102, -- 915
				color = Color(76, 84, 98, 255), -- 916
				opacity = wallOp, -- 917
				smooth = true -- 918
			} -- 918
		) -- 918
		local doorPanelL = cam:sx(thX - 112) -- 921
		local doorPanelR = cam:sx(thX - 1) -- 922
		worldArt:tryPlacePath( -- 923
			"assets/art/cutscene_story_parts.clip|tower_porch_door", -- 924
			"gate_closed_door_leaf", -- 925
			(doorPanelL + doorPanelR) * 0.5, -- 926
			wallBotY, -- 927
			math.max(2, doorPanelR - doorPanelL), -- 928
			wallH, -- 929
			{ -- 930
				anchorX = 0.5, -- 931
				anchorY = 0, -- 932
				layer = 4103, -- 933
				color = Color(156, 148, 140, 255), -- 934
				opacity = wallOp, -- 935
				smooth = true -- 936
			} -- 936
		) -- 936
	end -- 936
	local fgBeamAlpha = smoothstep(0.42, 0.95, m) * (1 - self.reunionPixelReturn) -- 942
	if fgBeamAlpha > 0.02 then -- 942
		local pRight = scene:project(thX + 318, 128, -54) -- 944
		worldArt:tryPlacePath( -- 945
			"assets/art/diorama_cutouts.clip|fg_pine_bough", -- 946
			"gate_fg_pine_right", -- 947
			pRight.x, -- 948
			pRight.y, -- 949
			cam:len(168), -- 950
			cam:len(108), -- 951
			{ -- 952
				anchorX = 0.5, -- 953
				anchorY = 0.5, -- 954
				facing = -1, -- 955
				color = Color(36, 48, 56, 255), -- 956
				opacity = 0.88 * fgBeamAlpha, -- 957
				smooth = true, -- 958
				layer = 5200 -- 959
			} -- 959
		) -- 959
	end -- 959
	return true -- 964
end -- 587
function GateTransitionPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 967
	return self.active and ctx.p.phase ~= "gate-walk" -- 974
end -- 967
function GateTransitionPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 977
	if not self.active then -- 977
		return -- 984
	end -- 984
	local p = ctx.p -- 986
	local view = ctx.view -- 987
	local cam = ctx.cam -- 988
	local tick = view.countElapsedTicks -- 989
	local cx = cam:sx(p.player.x) -- 990
	local by = cam:sy(p.player.y, p.player.depth) -- 991
	local H = cam:len(p.player.h) -- 992
	if p.phase == "gate-count" and tick >= 1080 and tick < view.countDurationTicks then -- 992
		local leanK = smoothstep(1080, 1130, tick) -- 996
		local doorSx = cam:sx(self.lockThresholdX) -- 997
		local headY = by + H * 0.8 -- 998
		local earPulse = 0.55 + 0.45 * math.sin(self.animTime * 2.2) -- 1000
		fgGlow:drawArc( -- 1001
			Vec2(doorSx + 4, headY), -- 1002
			12 + (1 - earPulse) * 8, -- 1003
			-38, -- 1003
			38, -- 1005
			1.1, -- 1006
			Color( -- 1007
				214, -- 1007
				224, -- 1007
				236, -- 1007
				math.floor(78 * leanK * earPulse + 0.5) -- 1007
			) -- 1007
		) -- 1007
		if tick >= 1260 then -- 1007
			local breathCycle = self.animTime * 0.7 % 1 -- 1011
			local bAlpha = math.sin(breathCycle * math.pi) * 0.48 -- 1012
			local bx = cx - 10 - breathCycle * 18 -- 1013
			local bY = headY - 4 + breathCycle * 6 -- 1014
			fillRadialGlow( -- 1015
				fgGlow, -- 1016
				bx, -- 1017
				bY, -- 1018
				12 + breathCycle * 10, -- 1019
				7 + breathCycle * 6, -- 1020
				Color( -- 1021
					220, -- 1021
					232, -- 1021
					244, -- 1021
					math.floor(110 * bAlpha + 0.5) -- 1021
				), -- 1021
				Color(180, 204, 228, 0), -- 1022
				12 -- 1023
			) -- 1023
		end -- 1023
	end -- 1023
	local isChildIdle = p.phase == "gate-count" and tick >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 1029
	if isChildIdle then -- 1029
		local pouchX = cx + cam:len(6) -- 1033
		local pouchY = by + H * 0.48 -- 1034
		local pulse = 0.72 + 0.28 * math.sin(self.animTime * 2.4) -- 1035
		fillRadialGlow( -- 1036
			fgGlow, -- 1037
			pouchX, -- 1038
			pouchY, -- 1039
			18 * pulse, -- 1040
			18 * pulse, -- 1041
			Color( -- 1042
				236, -- 1042
				198, -- 1042
				128, -- 1042
				math.floor(64 * pulse + 0.5) -- 1042
			), -- 1042
			Color(220, 168, 86, 0), -- 1043
			12 -- 1044
		) -- 1044
		fgGlow:drawDot( -- 1046
			Vec2(pouchX, pouchY), -- 1046
			2.1, -- 1046
			toColor( -- 1046
				PALETTE.amberCore, -- 1046
				math.floor(190 * pulse + 0.5) -- 1046
			) -- 1046
		) -- 1046
	end -- 1046
	local isSoldierWait = view.storyRoute == "soldier" and not view.gateReunion.completed and (p.phase == "gate-wait" or p.phase == "gate-count" and view.gateReunion.active) -- 1050
	if isSoldierWait then -- 1050
		local wallSx = cam:sx(self.lockThresholdX + 2) -- 1054
		local knockY = by + H * 0.56 -- 1055
		local ringCycle = self.animTime * 0.85 % 1 -- 1056
		local r1 = 8 + ringCycle * 34 -- 1057
		local a1 = (1 - ringCycle) * 0.72 -- 1058
		fgGlow:drawRing( -- 1059
			Vec2(wallSx, knockY), -- 1059
			math.max(1, r1 - 1.5), -- 1059
			r1, -- 1059
			Color(0, 0, 0, 0), -- 1059
			1.3, -- 1059
			toColor(PALETTE.amber, 210 * a1) -- 1059
		) -- 1059
		local handX = cx - cam:len(10) -- 1061
		local handY = by + H * 0.62 + math.sin(self.animTime * 2.6) * 2 -- 1062
		fgDraw:drawSegment( -- 1063
			Vec2( -- 1063
				cx - cam:len(3), -- 1063
				by + H * 0.56 -- 1063
			), -- 1063
			Vec2(handX, handY), -- 1063
			2.4, -- 1063
			Color(230, 206, 182, 220) -- 1063
		) -- 1063
		fgGlow:drawDot( -- 1064
			Vec2(handX, handY), -- 1064
			2.4, -- 1064
			toColor(PALETTE.amberCore, 165) -- 1064
		) -- 1064
	end -- 1064
end -- 977
function GateTransitionPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 1068
	if not self.active then -- 1068
		return false -- 1076
	end -- 1076
	local p = ctx.p -- 1078
	local view = ctx.view -- 1079
	local w = ctx.uiW -- 1080
	local h = ctx.uiH -- 1081
	if p.phase == "gate-walk" then -- 1081
		return false -- 1085
	end -- 1085
	local barH = math.floor(52 * (1 - self.reunionPixelReturn * 0.35) + 0.5) -- 1089
	uiDraw:drawRect( -- 1090
		Rect(0, h - barH, w, barH), -- 1090
		Color(8, 10, 16, 236) -- 1090
	) -- 1090
	uiDraw:drawRect( -- 1091
		Rect(0, 0, w, barH), -- 1091
		Color(8, 10, 16, 236) -- 1091
	) -- 1091
	uiInkDraw:drawSegment( -- 1092
		Vec2(0, h - barH), -- 1092
		Vec2(w, h - barH), -- 1092
		0.7, -- 1092
		toColor(PALETTE.silkDim, 68) -- 1092
	) -- 1092
	uiInkDraw:drawSegment( -- 1093
		Vec2(0, barH), -- 1093
		Vec2(w, barH), -- 1093
		0.7, -- 1093
		toColor(PALETTE.silkDim, 68) -- 1093
	) -- 1093
	local inCounting = p.phase == "gate-count" and view.countElapsedTicks < view.countDurationTicks -- 1096
	if inCounting and self.activeCountZh ~= "" then -- 1096
		local isBreathNum = view.countNumber == 19 -- 1098
		local fadeIn = smoothstep(0, 0.16, self.countCueAge) -- 1099
		local holdOut = 1 - smoothstep(isBreathNum and 2.1 or 1.15, isBreathNum and 2.85 or 1.65, self.countCueAge) -- 1100
		local numAlpha = clamp01(fadeIn * math.max(0.28, holdOut)) * (isBreathNum and 0.68 or 0.9) -- 1101
		local nx = w * 0.84 -- 1103
		local ny = h * 0.74 -- 1104
		drawMistCurve( -- 1105
			uiArt, -- 1105
			"gate_whisper_mist", -- 1105
			nx, -- 1105
			ny, -- 1105
			190, -- 1105
			44, -- 1105
			PALETTE.jadeMist, -- 1105
			0.18 * numAlpha, -- 1105
			0 -- 1105
		) -- 1105
		ctx.texts:put( -- 1106
			"banner", -- 1107
			self.activeCountZh, -- 1108
			nx, -- 1109
			ny + 6, -- 1110
			toColor(PALETTE.textBright), -- 1111
			0.5, -- 1112
			0.5, -- 1113
			"Center", -- 1114
			4, -- 1115
			numAlpha, -- 1116
			0.1 -- 1117
		) -- 1117
		local whisperText = view.countNumber == 18 and "「十八……」" or (view.countNumber == 19 and "「……十九……」" or ("「" .. self.activeCountZh) .. "……」") -- 1120
		drawSilkVeil( -- 1123
			uiDraw, -- 1123
			uiArt, -- 1123
			"gate_count_sub_veil", -- 1123
			w * 0.5, -- 1123
			26, -- 1123
			320, -- 1123
			36, -- 1123
			PALETTE.inkWash, -- 1123
			0.72 * numAlpha, -- 1123
			-1 -- 1123
		) -- 1123
		ctx.texts:put( -- 1124
			"sm", -- 1124
			whisperText, -- 1124
			w * 0.5, -- 1124
			26, -- 1124
			toColor(PALETTE.textMid), -- 1124
			0.5, -- 1124
			0.5, -- 1124
			"Center", -- 1124
			1.4, -- 1124
			numAlpha, -- 1124
			0.08 -- 1124
		) -- 1124
		return true -- 1125
	end -- 1125
	local isChildDone = p.phase == "gate-count" and view.countElapsedTicks >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 1129
	if isChildDone then -- 1129
		local lineAlpha = self.g04LineAge >= 0 and smoothstep(0, 0.25, self.g04LineAge) * (1 - smoothstep(3.8, 5.2, self.g04LineAge)) or 0.9 -- 1133
		if lineAlpha > 0.02 then -- 1133
			drawSilkVeil( -- 1137
				uiDraw, -- 1137
				uiArt, -- 1137
				"gate_g04_veil", -- 1137
				w * 0.5, -- 1137
				26, -- 1137
				460, -- 1137
				38, -- 1137
				PALETTE.inkWash, -- 1137
				0.78 * lineAlpha, -- 1137
				-1 -- 1137
			) -- 1137
			drawHairline( -- 1138
				uiInkDraw, -- 1138
				uiArt, -- 1138
				"gate_g04_line", -- 1138
				w * 0.5, -- 1138
				44, -- 1138
				300, -- 1138
				PALETTE.silkDim, -- 1138
				0.45 * lineAlpha, -- 1138
				true, -- 1138
				2 -- 1138
			) -- 1138
			ctx.texts:put( -- 1139
				"sm", -- 1140
				"「……二十了。我往北去了。」", -- 1141
				w * 0.5, -- 1142
				26, -- 1143
				toColor(PALETTE.textBright), -- 1144
				0.5, -- 1145
				0.5, -- 1146
				"Center", -- 1147
				1.2, -- 1148
				lineAlpha, -- 1149
				0.08 -- 1150
			) -- 1150
		end -- 1150
		if view.assistHintsEnabled then -- 1150
			ctx.texts:put( -- 1154
				"xs", -- 1155
				adaptHintSentence("松开后重新按方向键迈步", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1156
				w * 0.5, -- 1157
				h - 26, -- 1158
				toColor(PALETTE.textDim), -- 1159
				0.5, -- 1160
				0.5, -- 1161
				"Center", -- 1162
				1.2, -- 1163
				0.78, -- 1164
				0.08 -- 1165
			) -- 1165
		end -- 1165
		return true -- 1168
	end -- 1168
	return true -- 1172
end -- 1068
function ____exports.createGateTransitionPlugin() -- 1176
	return __TS__New(____exports.GateTransitionPlugin) -- 1177
end -- 1176
return ____exports -- 1176