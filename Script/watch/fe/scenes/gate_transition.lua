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
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 30
local GATE_NIGHTMARE_LIGHT = ____lowpoly.GATE_NIGHTMARE_LIGHT -- 31
local LP_BUCKET = ____lowpoly.LP_BUCKET -- 32
local LowpolyScene = ____lowpoly.LowpolyScene -- 34
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 35
local clamp01 = ____lowpoly.clamp01 -- 36
local projectWorld3D = ____lowpoly.projectWorld3D -- 37
local smoothstep = ____lowpoly.smoothstep -- 38
local vec3 = ____lowpoly.vec3 -- 39
local ____theme = require("Script.watch.fe.theme") -- 41
local PALETTE = ____theme.PALETTE -- 42
local drawHairline = ____theme.drawHairline -- 43
local drawMistCurve = ____theme.drawMistCurve -- 44
local drawSilkVeil = ____theme.drawSilkVeil -- 45
local fillRadialGlow = ____theme.fillRadialGlow -- 46
local fillVGradRect = ____theme.fillVGradRect -- 47
local lerpRGBA = ____theme.lerpRGBA -- 48
local rgba = ____theme.rgba -- 49
local toColor = ____theme.toColor -- 50
local COUNT_ZH = { -- 53
	"", -- 54
	"一", -- 54
	"二", -- 54
	"三", -- 54
	"四", -- 54
	"五", -- 54
	"六", -- 54
	"七", -- 54
	"八", -- 54
	"九", -- 54
	"十", -- 54
	"十一", -- 55
	"十二", -- 55
	"十三", -- 55
	"十四", -- 55
	"十五", -- 55
	"十六", -- 55
	"十七", -- 55
	"十八", -- 55
	"十九", -- 55
	"二十" -- 55
} -- 55
local GATE_AUDIO_ROOT = "assets/audio/gate/" -- 58
local GATE_ANCHOR_FOOT_FRAC_X = 0.36 -- 59
local GATE_ANCHOR_FOOT_FRAC_Y = 0.27 -- 60
local GATE_ANCHOR_ZOOM = 1.15 -- 61
local GATE_FOCAL = 410 -- 62
local GATE_VP_FRAC_X = 0.56 -- 63
local GATE_VP_FRAC_Y = 0.54 -- 64
--- 与 cuff_shots.ts G05 抬镜回切像素风同步的时序常数（秒）
____exports.G05_PIXEL_RETURN_START = 0.25 -- 67
____exports.G05_PIXEL_RETURN_END = 1.15 -- 68
local function pad2(n) -- 90
	local v = math.max( -- 91
		0, -- 91
		math.floor(n) -- 91
	) -- 91
	return v < 10 and "0" .. tostring(v) or "" .. tostring(v) -- 92
end -- 90
local function countVoicePath(n) -- 95
	return ((GATE_AUDIO_ROOT .. "count_") .. pad2(n)) .. ".wav" -- 96
end -- 95
local function countVoiceVolume(n) -- 99
	if n == 19 then -- 99
		return 0.68 -- 101
	end -- 101
	if n == 18 then -- 101
		return 0.8 -- 104
	end -- 104
	if n == 20 then -- 104
		return 0.96 -- 107
	end -- 107
	return 0.84 -- 109
end -- 99
____exports.GateTransitionPlugin = __TS__Class() -- 112
local GateTransitionPlugin = ____exports.GateTransitionPlugin -- 112
GateTransitionPlugin.name = "GateTransitionPlugin" -- 112
function GateTransitionPlugin.prototype.____constructor(self) -- 112
	self.id = "fe-01-gate-transition" -- 113
	self.animTime = 0 -- 115
	self.active = false -- 116
	self.wasActive = false -- 117
	self.rawMorph = 0 -- 118
	self.effectiveMorph = 0 -- 119
	self.lastCountTick = -1 -- 120
	self.lastTriggeredCount = 0 -- 121
	self.countCueAge = 99 -- 122
	self.pendingBreath19 = false -- 123
	self.activeCountZh = "" -- 124
	self.g04LineAge = -1 -- 125
	self.g04LineTriggered = false -- 126
	self.reunionTimer = 0 -- 127
	self.reunionPixelReturn = 0 -- 128
	self.rehearsalKnockTimer = -1 -- 129
	self.rehearsalKnockStage = 0 -- 130
	self.lockFootX = 890 -- 131
	self.lockThresholdX = 848 -- 132
	self.subtitleCountShown = 0 -- 133
	self.gestureChangeCount = 0 -- 134
	self.lastGestureStage = 0 -- 135
	self.activeProjection = { -- 136
		morph = 0, -- 137
		focal = GATE_FOCAL, -- 138
		vpFracX = GATE_VP_FRAC_X, -- 139
		vpFracY = GATE_VP_FRAC_Y, -- 140
		vpOffsetX = 0, -- 141
		vpOffsetY = 0, -- 142
		baseDepth = 0 -- 143
	} -- 143
end -- 112
function GateTransitionPlugin.prototype.onBindPlay(self, _p, _view) -- 146
	self:resetState() -- 147
end -- 146
function GateTransitionPlugin.prototype.resetState(self) -- 150
	self.animTime = 0 -- 151
	self.active = false -- 152
	self.wasActive = false -- 153
	self.rawMorph = 0 -- 154
	self.effectiveMorph = 0 -- 155
	self.lastCountTick = -1 -- 156
	self.lastTriggeredCount = 0 -- 157
	self.countCueAge = 99 -- 158
	self.pendingBreath19 = false -- 159
	self.activeCountZh = "" -- 160
	self.g04LineAge = -1 -- 161
	self.g04LineTriggered = false -- 162
	self.reunionTimer = 0 -- 163
	self.reunionPixelReturn = 0 -- 164
	self.rehearsalKnockTimer = -1 -- 165
	self.rehearsalKnockStage = 0 -- 166
	self.subtitleCountShown = 0 -- 167
	self.gestureChangeCount = 0 -- 168
	self.lastGestureStage = 0 -- 169
end -- 150
function GateTransitionPlugin.prototype.getProjection(self) -- 172
	return self.activeProjection -- 173
end -- 172
function GateTransitionPlugin.prototype.getDebugState(self) -- 176
	local earToDoor = self.active and self.lastCountTick >= 1080 and self.lastCountTick < GATE_COUNT_END -- 177
	local breathPause = self.active and self.lastCountTick >= 1260 and self.lastCountTick < GATE_COUNT_END -- 178
	return { -- 179
		active = self.active, -- 180
		morph = self.rawMorph, -- 181
		effectiveMorph = self.effectiveMorph, -- 182
		countTick = math.max(0, self.lastCountTick), -- 183
		countNumber = self.lastTriggeredCount, -- 184
		lastTriggeredCount = self.lastTriggeredCount, -- 185
		earToDoor = earToDoor, -- 186
		breathPause = breathPause, -- 187
		g04Idle = self.g04LineTriggered, -- 188
		g05Waiting = self.rehearsalKnockStage > 0 and self.reunionTimer <= 0, -- 189
		reunionTimer = self.reunionTimer, -- 190
		reunionPixelReturn = self.reunionPixelReturn, -- 191
		thresholdWorldX = self.lockThresholdX, -- 192
		footWorldX = self.lockFootX, -- 193
		rehearsalKnockStage = self.rehearsalKnockStage, -- 194
		subtitleCountShown = self.subtitleCountShown, -- 195
		gestureChangeCount = self.gestureChangeCount -- 196
	} -- 196
end -- 176
function GateTransitionPlugin.prototype.shouldActivate(self, p, view) -- 200
	if p.room.key ~= "gate" then -- 200
		return false -- 202
	end -- 202
	if p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 202
		return true -- 205
	end -- 205
	if p.phase == "gate-walk" and view.storyRoute ~= "soldier" then -- 205
		return true -- 208
	end -- 208
	return false -- 210
end -- 200
function GateTransitionPlugin.prototype.gestureStageForTick(self, tick, view) -- 213
	if view.storyRoute == "soldier" and (view.gateReunion.completed or view.gateReunion.active) then -- 213
		return 5 -- 215
	end -- 215
	if tick >= view.countDurationTicks then -- 215
		return 4 -- 218
	end -- 218
	if tick >= 1260 then -- 218
		return 3 -- 221
	end -- 221
	if tick >= 1080 then -- 221
		return 2 -- 224
	end -- 224
	if tick >= 480 then -- 224
		return 1 -- 227
	end -- 227
	return 0 -- 229
end -- 213
function GateTransitionPlugin.prototype.update(self, ctx) -- 232
	local p = ctx.p -- 233
	local view = ctx.view -- 234
	local want = self:shouldActivate(p, view) -- 235
	if not want then -- 235
		if self.wasActive then -- 235
			ctx.cam:setAnchorLock(nil) -- 239
			ctx.audio:stopLoop("gate_wind", 0.25) -- 240
			ctx.audio:stopLoop("gate_water", 0.25) -- 241
			ctx.audio:stopLoop("gate_breath", 0.2) -- 242
			self.wasActive = false -- 243
		end -- 243
		self.active = false -- 245
		return -- 246
	end -- 246
	self.active = true -- 249
	local justEntered = not self.wasActive -- 250
	self.wasActive = true -- 251
	local ____opt_0 = p.room.story -- 251
	local g = ____opt_0 and ____opt_0.gate -- 253
	local doorX = g ~= nil and g.doorX or p.ox + 860 -- 254
	self.lockThresholdX = doorX + 14 -- 256
	self.lockFootX = p.player.x -- 257
	if not ctx.paused then -- 257
		self.animTime = self.animTime + ctx.worldDt -- 260
		if self.countCueAge < 20 then -- 260
			self.countCueAge = self.countCueAge + ctx.worldDt -- 262
		end -- 262
		if self.g04LineAge >= 0 and self.g04LineAge < 20 then -- 262
			self.g04LineAge = self.g04LineAge + ctx.worldDt -- 265
		end -- 265
	end -- 265
	if p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-walk" then -- 265
		self.rawMorph = 1 -- 271
	else -- 271
		self.rawMorph = clamp01(view.countElapsedTicks / math.max(1, view.countDurationTicks)) -- 273
	end -- 273
	local reunionDone = p.phase == "gate-hand" or view.storyRoute == "soldier" and view.gateReunion.completed -- 277
	if reunionDone then -- 277
		if not ctx.paused then -- 277
			self.reunionTimer = self.reunionTimer + ctx.worldDt -- 280
		end -- 280
		self.reunionPixelReturn = smoothstep(____exports.G05_PIXEL_RETURN_START, ____exports.G05_PIXEL_RETURN_END, self.reunionTimer) -- 282
		self.effectiveMorph = clamp01(1 - self.reunionPixelReturn) -- 283
	else -- 283
		self.reunionTimer = 0 -- 285
		self.reunionPixelReturn = 0 -- 286
		self.effectiveMorph = self.rawMorph -- 287
	end -- 287
	local lockCamera = (p.phase == "gate-count" or p.phase == "gate-wait") and self.reunionPixelReturn < 0.98 -- 291
	if lockCamera then -- 291
		local tiltLift = self.reunionPixelReturn * 0.055 -- 294
		ctx.cam:setAnchorLock({ -- 295
			footWorldX = self.lockFootX, -- 296
			footWorldY = p.player.y, -- 297
			footDepth = p.player.depth, -- 298
			thresholdWorldX = self.lockThresholdX, -- 299
			screenFootFracX = GATE_ANCHOR_FOOT_FRAC_X, -- 300
			screenFootFracY = GATE_ANCHOR_FOOT_FRAC_Y - tiltLift, -- 301
			zoomOverride = GATE_ANCHOR_ZOOM + self.reunionPixelReturn * 0.07 -- 302
		}) -- 302
	else -- 302
		ctx.cam:setAnchorLock(nil) -- 305
	end -- 305
	local breathPhase = self.animTime * 1.35 -- 309
	local breatheAmp = self.effectiveMorph > 0.01 and p.phase == "gate-count" and 1 - self.reunionPixelReturn or 0 -- 310
	self.activeProjection = { -- 311
		morph = self.effectiveMorph, -- 312
		focal = GATE_FOCAL, -- 313
		vpFracX = GATE_VP_FRAC_X, -- 314
		vpFracY = GATE_VP_FRAC_Y, -- 315
		vpOffsetX = math.sin(breathPhase * 0.7) * 3.5 * breatheAmp, -- 316
		vpOffsetY = math.cos(breathPhase) * 2.5 * breatheAmp, -- 317
		baseDepth = p.player.depth -- 318
	} -- 318
	local tick = view.countElapsedTicks -- 322
	local countNum = math.max( -- 323
		1, -- 323
		math.min(20, view.countNumber) -- 323
	) -- 323
	local jumped = self.lastCountTick >= 0 and (tick < self.lastCountTick or tick - self.lastCountTick > 36) -- 324
	local stage = self:gestureStageForTick(tick, view) -- 325
	if justEntered and tick > 12 then -- 325
		self.lastTriggeredCount = countNum -- 329
		self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 330
		self.countCueAge = 0.6 -- 331
		self.lastGestureStage = stage -- 332
		if tick >= view.countDurationTicks and view.storyRoute ~= "soldier" then -- 332
			self.g04LineTriggered = true -- 334
			self.g04LineAge = 0.5 -- 335
		end -- 335
	elseif jumped then -- 335
		self.pendingBreath19 = false -- 338
		self.lastTriggeredCount = countNum -- 339
		self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 340
		self.countCueAge = 0.35 -- 341
		self.lastGestureStage = stage -- 342
		if tick < view.countDurationTicks then -- 342
			self.g04LineTriggered = false -- 344
			self.g04LineAge = -1 -- 345
			self.rehearsalKnockTimer = -1 -- 346
			self.rehearsalKnockStage = 0 -- 347
		end -- 347
	elseif not ctx.paused and (p.phase == "gate-count" or p.phase == "gate-wait") then -- 347
		if countNum > self.lastTriggeredCount then -- 347
			self.lastTriggeredCount = countNum -- 351
			self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 352
			self.countCueAge = 0 -- 353
			self.pendingBreath19 = countNum == 19 -- 354
			self.subtitleCountShown = self.subtitleCountShown + 1 -- 355
			local dedupeKey = (("gate:count:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(countNum) -- 356
			ctx.audio:playOnce( -- 357
				dedupeKey, -- 358
				"voice", -- 359
				countVoicePath(countNum), -- 360
				countVoiceVolume(countNum), -- 361
				"gate:count:" .. tostring(countNum), -- 362
				tick -- 363
			) -- 363
		end -- 363
		if stage ~= self.lastGestureStage then -- 363
			self.lastGestureStage = stage -- 367
			self.gestureChangeCount = self.gestureChangeCount + 1 -- 368
		end -- 368
	end -- 368
	if self.pendingBreath19 and self.countCueAge >= 0.78 and not ctx.paused and p.phase == "gate-count" then -- 368
		self.pendingBreath19 = false -- 373
		ctx.audio:playOnce( -- 374
			"gate:breath19:" .. tostring(ctx.events.roomSessionId), -- 375
			"voice", -- 376
			GATE_AUDIO_ROOT .. "breath_soft.wav", -- 377
			0.48, -- 378
			"gate:breath_19", -- 379
			tick -- 380
		) -- 380
	end -- 380
	local isChildWait = p.phase == "gate-count" and tick >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 385
	if isChildWait and not self.g04LineTriggered and not ctx.paused then -- 385
		self.g04LineTriggered = true -- 389
		self.g04LineAge = 0 -- 390
	end -- 390
	local isSoldierWait = view.storyRoute == "soldier" and (p.phase == "gate-wait" or p.phase == "gate-count" and view.gateReunion.active and not view.gateReunion.completed) -- 394
	if isSoldierWait and view.isRehearsal and not ctx.paused then -- 394
		if self.rehearsalKnockTimer < 0 then -- 394
			self.rehearsalKnockTimer = 0 -- 398
			self.rehearsalKnockStage = 1 -- 399
			ctx.audio:playOnce( -- 400
				"gate:rehearsal:knock:1:" .. tostring(ctx.events.roomSessionId), -- 401
				"sfx", -- 402
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 403
				0.88, -- 404
				"knock:gate:1", -- 405
				tick -- 406
			) -- 406
		else -- 406
			self.rehearsalKnockTimer = self.rehearsalKnockTimer + ctx.worldDt -- 409
			if self.rehearsalKnockStage < 2 and self.rehearsalKnockTimer >= 12 / 60 then -- 409
				self.rehearsalKnockStage = 2 -- 411
				ctx.audio:playOnce( -- 412
					"gate:rehearsal:knock:2:" .. tostring(ctx.events.roomSessionId), -- 413
					"sfx", -- 414
					GATE_AUDIO_ROOT .. "knock_wall.wav", -- 415
					0.92, -- 416
					"knock:gate:2", -- 417
					tick -- 418
				) -- 418
			end -- 418
		end -- 418
	end -- 418
	if not ctx.paused then -- 418
		local voiceDuck = p.phase == "gate-count" and countNum >= 18 and 0.32 + 0.68 * smoothstep(0.95, 1.55, self.countCueAge) or 1 -- 426
		local reunionCalm = reunionDone and 1 - self.reunionPixelReturn * 0.55 or 1 -- 428
		local windVol = (0.18 + 0.46 * self.effectiveMorph) * voiceDuck * reunionCalm -- 429
		local waterVol = (0.28 + 0.24 * self.effectiveMorph) * voiceDuck -- 430
		ctx.audio:playLoop( -- 431
			"gate_wind", -- 431
			"wind", -- 431
			GATE_AUDIO_ROOT .. "wind_loop.wav", -- 431
			windVol, -- 431
			tick -- 431
		) -- 431
		ctx.audio:playLoop( -- 432
			"gate_water", -- 432
			"water", -- 432
			GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 432
			waterVol, -- 432
			tick -- 432
		) -- 432
		if isChildWait then -- 432
			ctx.audio:playLoop( -- 434
				"gate_breath", -- 434
				"ambience", -- 434
				GATE_AUDIO_ROOT .. "breath_soft.wav", -- 434
				0.24, -- 434
				tick -- 434
			) -- 434
		else -- 434
			ctx.audio:stopLoop("gate_breath", 0.2) -- 436
		end -- 436
	end -- 436
	self.lastCountTick = tick -- 440
end -- 232
function GateTransitionPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 443
	if not self.active then -- 443
		return false -- 450
	end -- 450
	local cam = ctx.cam -- 452
	local w = cam.viewW -- 453
	local h = cam.viewH -- 454
	local m = self.effectiveMorph -- 455
	local skyTop = lerpRGBA( -- 458
		rgba(14, 10, 14, 255), -- 458
		rgba(8, 13, 22, 255), -- 458
		m -- 458
	) -- 458
	local skyMid = lerpRGBA( -- 459
		rgba(28, 17, 22, 255), -- 459
		rgba(16, 25, 38, 255), -- 459
		m -- 459
	) -- 459
	local skyHor = lerpRGBA( -- 460
		rgba(54, 28, 30, 255), -- 460
		rgba(30, 44, 62, 255), -- 460
		m -- 460
	) -- 460
	local splitY = h * 0.48 -- 461
	fillVGradRect( -- 462
		bgDraw, -- 462
		0, -- 462
		splitY, -- 462
		w, -- 462
		h - splitY, -- 462
		toColor(skyMid), -- 462
		toColor(skyTop) -- 462
	) -- 462
	fillVGradRect( -- 463
		bgDraw, -- 463
		0, -- 463
		0, -- 463
		w, -- 463
		splitY, -- 463
		toColor(skyHor), -- 463
		toColor(skyMid) -- 463
	) -- 463
	local pixelBgAlpha = 1 - smoothstep(0.08, 0.72, m) -- 466
	if pixelBgAlpha > 0.01 then -- 466
		local span = math.max(1, ctx.p.room.maxX - ctx.p.room.minX) -- 468
		local progress = (cam.x - ctx.p.room.minX) / span - 0.5 -- 469
		local artW = math.max(w, h * 16 / 9) + w * 0.12 -- 470
		local artH = artW * 9 / 16 -- 471
		backdropArt:tryPlace( -- 472
			"bgFar_gate", -- 472
			"gate_pixel_bg", -- 472
			w * (0.5 - progress * 0.09), -- 472
			(h - artH) * 0.5, -- 472
			artW, -- 472
			artH, -- 472
			{opacity = pixelBgAlpha, layer = 0} -- 472
		) -- 472
	end -- 472
	local farReveal = smoothstep(0.22, 0.85, m) -- 479
	if farReveal > 0.01 then -- 479
		local scene = __TS__New(LowpolyScene, cam, self.activeProjection, GATE_NIGHTMARE_LIGHT) -- 481
		local xMin = self.lockThresholdX - 320 -- 482
		local xMax = self.lockThresholdX + 680 -- 483
		local hillSep = smoothstep(0.45, 0.88, m) -- 486
		scene:addDistantRidge( -- 487
			{ -- 488
				{x = xMin, y = 112}, -- 489
				{x = self.lockThresholdX - 60, y = 176}, -- 490
				{x = self.lockThresholdX + 120, y = 146}, -- 491
				{x = self.lockThresholdX + 280, y = 204}, -- 492
				{x = self.lockThresholdX + 460, y = 164}, -- 493
				{x = xMax, y = 132} -- 494
			}, -- 494
			-40, -- 494
			520, -- 497
			MING_MATERIALS.distantHill, -- 498
			{bucket = LP_BUCKET.BACKDROP, opacity = farReveal * (0.55 + 0.45 * hillSep)} -- 499
		) -- 499
		scene:addFogBand( -- 503
			xMin, -- 503
			xMax, -- 503
			-30, -- 503
			190, -- 503
			360, -- 503
			rgba(38, 54, 74, 255), -- 503
			0.72 * hillSep, -- 503
			0.06 * hillSep, -- 503
			{bucket = LP_BUCKET.BACKDROP} -- 503
		) -- 503
		local wallMat = MING_MATERIALS.distantWall -- 508
		scene:addBox({ -- 509
			x0 = self.lockThresholdX + 40, -- 510
			x1 = xMax, -- 511
			y0 = -48, -- 512
			y1 = 96, -- 513
			z0 = 215, -- 514
			z1 = 260, -- 515
			material = wallMat, -- 516
			bucket = LP_BUCKET.BACKDROP, -- 517
			opacity = farReveal, -- 518
			highlightTopEdge = true, -- 519
			edgeWidth = 0 -- 520
		}) -- 520
		local merlonX = self.lockThresholdX + 64 -- 523
		local mi = 0 -- 524
		do -- 524
			mi = 0 -- 525
			while mi < 10 do -- 525
				scene:addBox({ -- 526
					x0 = merlonX, -- 527
					x1 = merlonX + 28, -- 528
					y0 = 96, -- 529
					y1 = 112, -- 530
					z0 = 215, -- 531
					z1 = 242, -- 532
					material = wallMat, -- 533
					bucket = LP_BUCKET.BACKDROP, -- 534
					opacity = farReveal, -- 535
					sortBias = 0.05, -- 536
					edgeWidth = 0 -- 537
				}) -- 537
				merlonX = merlonX + 56 -- 539
				mi = mi + 1 -- 525
			end -- 525
		end -- 525
		scene:addFogBand( -- 543
			xMin, -- 543
			xMax, -- 543
			-44, -- 543
			108, -- 543
			148, -- 543
			rgba(32, 46, 66, 255), -- 543
			0.64 * farReveal, -- 543
			0.04, -- 543
			{bucket = LP_BUCKET.BACKDROP} -- 543
		) -- 543
		local beaconP = projectWorld3D( -- 548
			self.lockThresholdX + 210, -- 548
			146, -- 548
			490, -- 548
			cam, -- 548
			self.activeProjection -- 548
		) -- 548
		local pulse = 0.82 + 0.18 * math.sin(self.animTime * 2.1) -- 549
		fillRadialGlow( -- 550
			bgGlow, -- 551
			beaconP.x, -- 552
			beaconP.y, -- 553
			34 * farReveal * pulse, -- 554
			34 * farReveal * pulse, -- 555
			Color( -- 556
				246, -- 556
				212, -- 556
				148, -- 556
				math.floor(92 * farReveal * pulse + 0.5) -- 556
			), -- 556
			Color(232, 180, 96, 0), -- 557
			16 -- 558
		) -- 558
		bgGlow:drawDot( -- 560
			Vec2(beaconP.x, beaconP.y), -- 560
			2.6 * farReveal, -- 560
			Color( -- 560
				255, -- 560
				244, -- 560
				212, -- 560
				math.floor(235 * farReveal + 0.5) -- 560
			) -- 560
		) -- 560
		local moatY = -36 -- 563
		local waterA = 0.42 * farReveal -- 564
		local ri = 0 -- 565
		do -- 565
			ri = 0 -- 566
			while ri < 6 do -- 566
				local rx = self.lockThresholdX + 110 + ri * 68 + math.sin(self.animTime * 1.1 + ri * 1.7) * 8 -- 567
				local pL = projectWorld3D( -- 568
					rx - 18, -- 568
					moatY - ri % 2 * 6, -- 568
					128 + ri * 12, -- 568
					cam, -- 568
					self.activeProjection -- 568
				) -- 568
				local pR = projectWorld3D( -- 569
					rx + 18, -- 569
					moatY - ri % 2 * 6, -- 569
					128 + ri * 12, -- 569
					cam, -- 569
					self.activeProjection -- 569
				) -- 569
				bgGlow:drawSegment( -- 570
					Vec2(pL.x, pL.y), -- 570
					Vec2(pR.x, pR.y), -- 570
					1.1, -- 570
					Color( -- 570
						168, -- 570
						198, -- 570
						224, -- 570
						math.floor(90 * waterA + 0.5) -- 570
					) -- 570
				) -- 570
				ri = ri + 1 -- 566
			end -- 566
		end -- 566
		scene:flush(bgDraw, bgGlow) -- 573
	end -- 573
	local mx = w * 0.66 -- 577
	local my = h * 0.82 -- 578
	local mr = math.max(15, h * 0.032) -- 579
	fillRadialGlow( -- 580
		bgGlow, -- 580
		mx, -- 580
		my, -- 580
		mr * 4.8, -- 580
		mr * 4.8, -- 580
		Color( -- 580
			164, -- 580
			202, -- 580
			232, -- 580
			math.floor(18 + 20 * m + 0.5) -- 580
		), -- 580
		Color(24, 42, 68, 0), -- 580
		18 -- 580
	) -- 580
	bgDraw:drawCircle( -- 581
		Vec2(mx, my), -- 581
		mr, -- 581
		Color( -- 581
			218, -- 581
			232, -- 581
			246, -- 581
			math.floor(115 + 85 * m + 0.5) -- 581
		) -- 581
	) -- 581
	return true -- 583
end -- 443
function GateTransitionPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 586
	if not self.active then -- 586
		return false -- 593
	end -- 593
	local p = ctx.p -- 595
	local cam = ctx.cam -- 596
	local m = self.effectiveMorph -- 597
	local thX = self.lockThresholdX -- 598
	local doorLeft = thX - 108 -- 599
	local scene = __TS__New(LowpolyScene, cam, self.activeProjection, GATE_NIGHTMARE_LIGHT) -- 601
	local closeFrac = p.phase == "gate-count" and 0.44 + 0.56 * clamp01(ctx.view.countElapsedTicks / 360) or 1 -- 604
	local stepReveal = smoothstep(0.18, 0.58, m) -- 609
	if stepReveal > 0.01 then -- 609
		local stairSpec = { -- 611
			x0 = thX + 108, -- 612
			x1 = thX + 292, -- 613
			y0 = -56, -- 614
			y1 = 2, -- 615
			steps = 5, -- 616
			label = "外壕石阶" -- 617
		} -- 617
		local k = 0 -- 620
		local n = stairSpec.steps + 1 -- 621
		local stepW = (stairSpec.x1 - stairSpec.x0) / n -- 622
		do -- 622
			k = 0 -- 623
			while k < n do -- 623
				local wy = stairSpec.y1 - (stairSpec.y1 - stairSpec.y0) * (k / math.max(1, n - 1)) -- 624
				local sx0 = stairSpec.x0 + k * stepW -- 625
				local sx1 = sx0 + stepW + 1 -- 626
				scene:addBox({ -- 627
					x0 = sx0, -- 628
					x1 = sx1, -- 629
					y0 = -78, -- 630
					y1 = wy, -- 631
					z0 = 26, -- 632
					z1 = 106, -- 633
					material = MING_MATERIALS.mingStoneStep, -- 634
					bucket = LP_BUCKET.MIDGROUND, -- 635
					opacity = stepReveal, -- 636
					sortBias = k * 0.02, -- 637
					highlightTopEdge = true, -- 638
					edgeWidth = 0.9 -- 639
				}) -- 639
				k = k + 1 -- 623
			end -- 623
		end -- 623
	end -- 623
	local wallReveal = smoothstep(0.02, 0.22, m) -- 646
	local frameLightStrength = smoothstep(0.1, 0.34, m) * (1 - 0.35 * smoothstep(0.85, 1, m)) -- 647
	if wallReveal > 0.01 then -- 647
		scene:addBox({ -- 649
			x0 = doorLeft - 140, -- 650
			x1 = thX - 18, -- 651
			y0 = -60, -- 652
			y1 = 230, -- 653
			z0 = -12, -- 654
			z1 = 88, -- 655
			material = MING_MATERIALS.mingBrick, -- 656
			bucket = LP_BUCKET.MIDGROUND, -- 657
			opacity = wallReveal, -- 658
			highlightTopEdge = true, -- 659
			edgeWidth = 0.75 -- 660
		}) -- 660
		scene:addBox({ -- 663
			x0 = thX - 18, -- 664
			x1 = thX, -- 665
			y0 = 0, -- 666
			y1 = 162, -- 667
			z0 = -6, -- 668
			z1 = 72, -- 669
			material = MING_MATERIALS.mingStoneStep, -- 670
			bucket = LP_BUCKET.MIDGROUND, -- 671
			opacity = wallReveal, -- 672
			sortBias = 0.08, -- 673
			highlightTopEdge = true, -- 674
			edgeWidth = 0.9 -- 675
		}) -- 675
		scene:addBox({ -- 678
			x0 = doorLeft - 40, -- 679
			x1 = thX + 76, -- 680
			y0 = 160, -- 681
			y1 = 214, -- 682
			z0 = -14, -- 683
			z1 = 82, -- 684
			material = MING_MATERIALS.mingBrickDark, -- 685
			bucket = LP_BUCKET.MIDGROUND, -- 686
			opacity = wallReveal, -- 687
			sortBias = 0.12, -- 688
			highlightTopEdge = true, -- 689
			edgeWidth = 0.8 -- 690
		}) -- 690
	end -- 690
	if frameLightStrength > 0.02 then -- 690
		scene:addLightShaft( -- 696
			thX + 16, -- 697
			thX + 34, -- 697
			160, -- 697
			thX - 4, -- 698
			thX + 24, -- 698
			0, -- 698
			16, -- 699
			rgba(220, 234, 248, 255), -- 700
			0.24 * frameLightStrength, -- 701
			0.04 * frameLightStrength -- 702
		) -- 702
		local pBotNear = scene:project(thX, 0, -6) -- 705
		local pBotFar = scene:project(thX, 0, 72) -- 706
		local pTopFar = scene:project(thX, 160, 72) -- 707
		local pTopNear = scene:project(thX, 160, -6) -- 708
		local glowA = math.floor(140 * frameLightStrength + 0.5) -- 709
		fgGlow:drawVertices({ -- 710
			{ -- 711
				Vec2(pBotNear.x, pBotNear.y), -- 711
				Color(224, 236, 248, glowA) -- 711
			}, -- 711
			{ -- 712
				Vec2(pBotFar.x, pBotFar.y), -- 712
				Color( -- 712
					168, -- 712
					196, -- 712
					224, -- 712
					math.floor(glowA * 0.25 + 0.5) -- 712
				) -- 712
			}, -- 712
			{ -- 713
				Vec2(pTopFar.x, pTopFar.y), -- 713
				Color( -- 713
					168, -- 713
					196, -- 713
					224, -- 713
					math.floor(glowA * 0.25 + 0.5) -- 713
				) -- 713
			}, -- 713
			{ -- 714
				Vec2(pBotNear.x, pBotNear.y), -- 714
				Color(224, 236, 248, glowA) -- 714
			}, -- 714
			{ -- 715
				Vec2(pTopFar.x, pTopFar.y), -- 715
				Color( -- 715
					168, -- 715
					196, -- 715
					224, -- 715
					math.floor(glowA * 0.25 + 0.5) -- 715
				) -- 715
			}, -- 715
			{ -- 716
				Vec2(pTopNear.x, pTopNear.y), -- 716
				Color(224, 236, 248, glowA) -- 716
			} -- 716
		}) -- 716
	end -- 716
	local doorAlpha = 1 - self.reunionPixelReturn -- 721
	local doorBotY = 160 * (1 - closeFrac) -- 722
	if 160 - doorBotY > 2 and doorAlpha > 0.02 then -- 722
		scene:addBox({ -- 724
			x0 = thX - 122, -- 725
			x1 = thX - 2, -- 726
			y0 = doorBotY, -- 727
			y1 = 160, -- 728
			z0 = 4, -- 729
			z1 = 22, -- 730
			material = MING_MATERIALS.mingTimberDark, -- 731
			bucket = LP_BUCKET.MIDGROUND, -- 732
			opacity = doorAlpha, -- 733
			sortBias = 0.04, -- 734
			edgeWidth = 0.9 -- 735
		}) -- 735
		local bandYs = {doorBotY + 12, doorBotY + 42, doorBotY + 72} -- 738
		local bi = 0 -- 739
		do -- 739
			bi = 0 -- 740
			while bi < #bandYs do -- 740
				local byBand = bandYs[bi + 1] -- 741
				if byBand + 6 < 158 then -- 741
					scene:addBox({ -- 743
						x0 = thX - 120, -- 744
						x1 = thX - 4, -- 745
						y0 = byBand, -- 746
						y1 = byBand + 6, -- 747
						z0 = 2, -- 748
						z1 = 10, -- 749
						material = MING_MATERIALS.mingIron, -- 750
						bucket = LP_BUCKET.MIDGROUND, -- 751
						opacity = doorAlpha, -- 752
						sortBias = 0.06, -- 753
						edgeWidth = 0.5 -- 754
					}) -- 754
				end -- 754
				bi = bi + 1 -- 740
			end -- 740
		end -- 740
		if closeFrac < 0.98 then -- 740
			local gapAlpha = (1 - closeFrac) * 0.65 * doorAlpha -- 760
			scene:addLightShaft( -- 761
				thX - 96, -- 762
				thX - 2, -- 762
				math.max(4, doorBotY), -- 762
				thX - 86, -- 763
				thX + 26, -- 763
				0, -- 763
				2, -- 764
				rgba(232, 188, 128, 255), -- 765
				gapAlpha * 0.42, -- 766
				gapAlpha * 0.14 -- 767
			) -- 767
		end -- 767
	end -- 767
	scene:addBox({ -- 773
		x0 = thX - 10, -- 774
		x1 = thX + 12, -- 775
		y0 = -12, -- 776
		y1 = 2, -- 777
		z0 = -14, -- 778
		z1 = 28, -- 779
		material = MING_MATERIALS.mingStoneStep, -- 780
		bucket = LP_BUCKET.WALK_DECK, -- 781
		sortBias = 0.02, -- 782
		highlightTopEdge = true, -- 783
		edgeWidth = 1.1 -- 784
	}) -- 784
	scene:addBox({ -- 788
		x0 = doorLeft - 140, -- 789
		x1 = thX + 132, -- 790
		y0 = -68, -- 791
		y1 = 0, -- 792
		z0 = -20, -- 793
		z1 = 42, -- 794
		material = MING_MATERIALS.mingBrickDark, -- 795
		bucket = LP_BUCKET.WALK_DECK, -- 796
		sortBias = 0, -- 797
		highlightTopEdge = true, -- 798
		edgeWidth = 0.85 -- 799
	}) -- 799
	local plankReveal = smoothstep(0.14, 0.52, m) -- 803
	if plankReveal > 0.01 then -- 803
		local overhangZ0 = -10 - 48 * plankReveal -- 805
		scene:addPlankDeck( -- 806
			thX + 58, -- 807
			thX + 340, -- 808
			0, -- 809
			overhangZ0, -- 810
			22, -- 811
			5, -- 812
			11, -- 813
			MING_MATERIALS.mingTimber, -- 814
			{ -- 815
				bucket = LP_BUCKET.WALK_DECK, -- 816
				opacity = plankReveal, -- 817
				sortBias = 0.25, -- 818
				withPosts = true, -- 819
				postBottomY = -78 -- 820
			} -- 820
		) -- 820
		scene:addBox({ -- 824
			x0 = thX + 244, -- 825
			x1 = thX + 260, -- 826
			y0 = 0, -- 827
			y1 = 38, -- 828
			z0 = -12, -- 829
			z1 = 6, -- 830
			material = MING_MATERIALS.mingTimberDark, -- 831
			bucket = LP_BUCKET.PROP, -- 832
			opacity = plankReveal, -- 833
			highlightTopEdge = true -- 834
		}) -- 834
		local clothBaseX = thX + 244 -- 837
		local clothTopY = 34 -- 838
		local windFreq = 2.8 + m * 1.4 -- 839
		local wave1 = math.sin(self.animTime * windFreq) * (4 + 6 * m) -- 840
		local wave2 = math.cos(self.animTime * windFreq * 0.85) * (3 + 4 * m) -- 841
		scene:addTri3D( -- 842
			vec3(clothBaseX, clothTopY, -12), -- 843
			vec3(clothBaseX + 7, clothTopY - 2, -12), -- 844
			vec3(clothBaseX - 8 + wave1, clothTopY - 24 + wave2 * 0.3, -15), -- 845
			MING_MATERIALS.mingRedCloth, -- 846
			{bucket = LP_BUCKET.PROP, opacity = plankReveal, sortBias = 0.35, edgeWidth = 0.9} -- 847
		) -- 847
		scene:addTri3D( -- 849
			vec3(clothBaseX + 7, clothTopY - 2, -12), -- 850
			vec3(clothBaseX - 8 + wave1, clothTopY - 24 + wave2 * 0.3, -15), -- 851
			vec3(clothBaseX + 2 + wave2, clothTopY - 20, -13), -- 852
			MING_MATERIALS.mingRedCloth, -- 853
			{bucket = LP_BUCKET.PROP, opacity = plankReveal * 0.9, sortBias = 0.36} -- 854
		) -- 854
	end -- 854
	scene:addContactShadow( -- 859
		p.player.x, -- 859
		p.player.y, -- 859
		16, -- 859
		12, -- 859
		0.62 + 0.28 * m, -- 859
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 859
	) -- 859
	scene:flush(fgDraw, fgGlow) -- 865
	local hidePartnerInside = self.reunionPixelReturn < 0.85 and closeFrac > 0.6 -- 869
	if hidePartnerInside then -- 869
		local wallRightX = cam:sx(thX - 1) -- 871
		local wallLeftX = cam:sx(doorLeft - 140) -- 872
		local wallW = math.max(2, wallRightX - wallLeftX) -- 873
		local wallTopY = cam:sy(164, p.player.depth) -- 874
		local wallBotY = cam:sy(0, p.player.depth) -- 875
		local wallH = math.max(2, wallTopY - wallBotY) -- 876
		local wallOp = clamp01((closeFrac - 0.6) / 0.28) * (1 - self.reunionPixelReturn) -- 877
		worldArt:tryPlace( -- 878
			"wall", -- 879
			"gate_closed_wall_mask", -- 880
			(wallLeftX + wallRightX) * 0.5, -- 881
			wallBotY, -- 882
			wallW, -- 883
			wallH, -- 884
			{ -- 885
				layer = 4102, -- 886
				color = Color(52, 56, 66, 255), -- 887
				opacity = wallOp -- 888
			} -- 888
		) -- 888
		local doorPanelL = cam:sx(thX - 112) -- 891
		local doorPanelR = cam:sx(thX - 1) -- 892
		worldArt:tryPlace( -- 893
			"prop_tower_door", -- 894
			"gate_closed_door_leaf", -- 895
			(doorPanelL + doorPanelR) * 0.5, -- 896
			wallBotY, -- 897
			math.max(2, doorPanelR - doorPanelL), -- 898
			wallH, -- 899
			{ -- 900
				layer = 4103, -- 901
				color = Color(86, 74, 62, 255), -- 902
				opacity = wallOp -- 903
			} -- 903
		) -- 903
	end -- 903
	local fgBeamAlpha = smoothstep(0.42, 0.95, m) * (1 - self.reunionPixelReturn) -- 909
	if fgBeamAlpha > 0.02 then -- 909
		scene:placeForegroundOccluder( -- 911
			worldArt, -- 912
			"cover_wood", -- 913
			"gate_fg_beam_right", -- 914
			thX + 266, -- 915
			thX + 356, -- 916
			-42, -- 916
			22, -- 918
			-68, -- 918
			{ -- 920
				color = Color(14, 17, 24, 255), -- 920
				opacity = 0.92 * fgBeamAlpha, -- 920
				layer = 5200 -- 920
			} -- 920
		) -- 920
	end -- 920
	return true -- 924
end -- 586
function GateTransitionPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 927
	return self.active and ctx.p.phase ~= "gate-walk" -- 934
end -- 927
function GateTransitionPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 937
	if not self.active then -- 937
		return -- 944
	end -- 944
	local p = ctx.p -- 946
	local view = ctx.view -- 947
	local cam = ctx.cam -- 948
	local tick = view.countElapsedTicks -- 949
	local cx = cam:sx(p.player.x) -- 950
	local by = cam:sy(p.player.y, p.player.depth) -- 951
	local H = cam:len(p.player.h) -- 952
	if p.phase == "gate-count" and tick >= 1080 and tick < view.countDurationTicks then -- 952
		local leanK = smoothstep(1080, 1130, tick) -- 956
		local doorSx = cam:sx(self.lockThresholdX) -- 957
		local headY = by + H * 0.8 -- 958
		local earPulse = 0.55 + 0.45 * math.sin(self.animTime * 2.2) -- 960
		fgGlow:drawArc( -- 961
			Vec2(doorSx + 4, headY), -- 962
			12 + (1 - earPulse) * 8, -- 963
			-38, -- 963
			38, -- 965
			1.1, -- 966
			Color( -- 967
				214, -- 967
				224, -- 967
				236, -- 967
				math.floor(78 * leanK * earPulse + 0.5) -- 967
			) -- 967
		) -- 967
		if tick >= 1260 then -- 967
			local breathCycle = self.animTime * 0.7 % 1 -- 971
			local bAlpha = math.sin(breathCycle * math.pi) * 0.48 -- 972
			local bx = cx - 10 - breathCycle * 18 -- 973
			local bY = headY - 4 + breathCycle * 6 -- 974
			fillRadialGlow( -- 975
				fgGlow, -- 976
				bx, -- 977
				bY, -- 978
				12 + breathCycle * 10, -- 979
				7 + breathCycle * 6, -- 980
				Color( -- 981
					220, -- 981
					232, -- 981
					244, -- 981
					math.floor(110 * bAlpha + 0.5) -- 981
				), -- 981
				Color(180, 204, 228, 0), -- 982
				12 -- 983
			) -- 983
		end -- 983
	end -- 983
	local isChildIdle = p.phase == "gate-count" and tick >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 989
	if isChildIdle then -- 989
		local pouchX = cx + cam:len(6) -- 993
		local pouchY = by + H * 0.48 -- 994
		local pulse = 0.72 + 0.28 * math.sin(self.animTime * 2.4) -- 995
		fillRadialGlow( -- 996
			fgGlow, -- 997
			pouchX, -- 998
			pouchY, -- 999
			18 * pulse, -- 1000
			18 * pulse, -- 1001
			Color( -- 1002
				236, -- 1002
				198, -- 1002
				128, -- 1002
				math.floor(64 * pulse + 0.5) -- 1002
			), -- 1002
			Color(220, 168, 86, 0), -- 1003
			12 -- 1004
		) -- 1004
		fgGlow:drawDot( -- 1006
			Vec2(pouchX, pouchY), -- 1006
			2.1, -- 1006
			toColor( -- 1006
				PALETTE.amberCore, -- 1006
				math.floor(190 * pulse + 0.5) -- 1006
			) -- 1006
		) -- 1006
	end -- 1006
	local isSoldierWait = view.storyRoute == "soldier" and not view.gateReunion.completed and (p.phase == "gate-wait" or p.phase == "gate-count" and view.gateReunion.active) -- 1010
	if isSoldierWait then -- 1010
		local wallSx = cam:sx(self.lockThresholdX + 2) -- 1014
		local knockY = by + H * 0.56 -- 1015
		local ringCycle = self.animTime * 0.85 % 1 -- 1016
		local r1 = 8 + ringCycle * 34 -- 1017
		local a1 = (1 - ringCycle) * 0.72 -- 1018
		fgGlow:drawRing( -- 1019
			Vec2(wallSx, knockY), -- 1019
			math.max(1, r1 - 1.5), -- 1019
			r1, -- 1019
			Color(0, 0, 0, 0), -- 1019
			1.3, -- 1019
			toColor(PALETTE.amber, 210 * a1) -- 1019
		) -- 1019
		local handX = cx - cam:len(10) -- 1021
		local handY = by + H * 0.62 + math.sin(self.animTime * 2.6) * 2 -- 1022
		fgDraw:drawSegment( -- 1023
			Vec2( -- 1023
				cx - cam:len(3), -- 1023
				by + H * 0.56 -- 1023
			), -- 1023
			Vec2(handX, handY), -- 1023
			2.4, -- 1023
			Color(230, 206, 182, 220) -- 1023
		) -- 1023
		fgGlow:drawDot( -- 1024
			Vec2(handX, handY), -- 1024
			2.4, -- 1024
			toColor(PALETTE.amberCore, 165) -- 1024
		) -- 1024
	end -- 1024
end -- 937
function GateTransitionPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 1028
	if not self.active then -- 1028
		return false -- 1036
	end -- 1036
	local p = ctx.p -- 1038
	local view = ctx.view -- 1039
	local w = ctx.uiW -- 1040
	local h = ctx.uiH -- 1041
	if p.phase == "gate-walk" then -- 1041
		return false -- 1045
	end -- 1045
	local barH = math.floor(52 * (1 - self.reunionPixelReturn * 0.35) + 0.5) -- 1049
	uiDraw:drawRect( -- 1050
		Rect(0, h - barH, w, barH), -- 1050
		Color(8, 10, 16, 236) -- 1050
	) -- 1050
	uiDraw:drawRect( -- 1051
		Rect(0, 0, w, barH), -- 1051
		Color(8, 10, 16, 236) -- 1051
	) -- 1051
	uiInkDraw:drawSegment( -- 1052
		Vec2(0, h - barH), -- 1052
		Vec2(w, h - barH), -- 1052
		0.7, -- 1052
		toColor(PALETTE.silkDim, 68) -- 1052
	) -- 1052
	uiInkDraw:drawSegment( -- 1053
		Vec2(0, barH), -- 1053
		Vec2(w, barH), -- 1053
		0.7, -- 1053
		toColor(PALETTE.silkDim, 68) -- 1053
	) -- 1053
	local inCounting = p.phase == "gate-count" and view.countElapsedTicks < view.countDurationTicks -- 1056
	if inCounting and self.activeCountZh ~= "" then -- 1056
		local isBreathNum = view.countNumber == 19 -- 1058
		local fadeIn = smoothstep(0, 0.16, self.countCueAge) -- 1059
		local holdOut = 1 - smoothstep(isBreathNum and 2.1 or 1.15, isBreathNum and 2.85 or 1.65, self.countCueAge) -- 1060
		local numAlpha = clamp01(fadeIn * math.max(0.28, holdOut)) * (isBreathNum and 0.68 or 0.9) -- 1061
		local nx = w * 0.84 -- 1063
		local ny = h * 0.74 -- 1064
		drawMistCurve( -- 1065
			uiArt, -- 1065
			"gate_whisper_mist", -- 1065
			nx, -- 1065
			ny, -- 1065
			190, -- 1065
			44, -- 1065
			PALETTE.jadeMist, -- 1065
			0.18 * numAlpha, -- 1065
			0 -- 1065
		) -- 1065
		ctx.texts:put( -- 1066
			"banner", -- 1067
			self.activeCountZh, -- 1068
			nx, -- 1069
			ny + 6, -- 1070
			toColor(PALETTE.textBright), -- 1071
			0.5, -- 1072
			0.5, -- 1073
			"Center", -- 1074
			4, -- 1075
			numAlpha, -- 1076
			0.1 -- 1077
		) -- 1077
		local whisperText = view.countNumber == 18 and "「十八……」" or (view.countNumber == 19 and "「……十九……」" or ("「" .. self.activeCountZh) .. "……」") -- 1080
		drawSilkVeil( -- 1083
			uiDraw, -- 1083
			uiArt, -- 1083
			"gate_count_sub_veil", -- 1083
			w * 0.5, -- 1083
			26, -- 1083
			320, -- 1083
			36, -- 1083
			PALETTE.inkWash, -- 1083
			0.72 * numAlpha, -- 1083
			-1 -- 1083
		) -- 1083
		ctx.texts:put( -- 1084
			"sm", -- 1084
			whisperText, -- 1084
			w * 0.5, -- 1084
			26, -- 1084
			toColor(PALETTE.textMid), -- 1084
			0.5, -- 1084
			0.5, -- 1084
			"Center", -- 1084
			1.4, -- 1084
			numAlpha, -- 1084
			0.08 -- 1084
		) -- 1084
		return true -- 1085
	end -- 1085
	local isChildDone = p.phase == "gate-count" and view.countElapsedTicks >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 1089
	if isChildDone then -- 1089
		local lineAlpha = self.g04LineAge >= 0 and smoothstep(0, 0.25, self.g04LineAge) * (1 - smoothstep(3.8, 5.2, self.g04LineAge)) or 0.9 -- 1093
		if lineAlpha > 0.02 then -- 1093
			drawSilkVeil( -- 1097
				uiDraw, -- 1097
				uiArt, -- 1097
				"gate_g04_veil", -- 1097
				w * 0.5, -- 1097
				26, -- 1097
				460, -- 1097
				38, -- 1097
				PALETTE.inkWash, -- 1097
				0.78 * lineAlpha, -- 1097
				-1 -- 1097
			) -- 1097
			drawHairline( -- 1098
				uiInkDraw, -- 1098
				uiArt, -- 1098
				"gate_g04_line", -- 1098
				w * 0.5, -- 1098
				44, -- 1098
				300, -- 1098
				PALETTE.silkDim, -- 1098
				0.45 * lineAlpha, -- 1098
				true, -- 1098
				2 -- 1098
			) -- 1098
			ctx.texts:put( -- 1099
				"sm", -- 1100
				"「……二十了。我往北去了。」", -- 1101
				w * 0.5, -- 1102
				26, -- 1103
				toColor(PALETTE.textBright), -- 1104
				0.5, -- 1105
				0.5, -- 1106
				"Center", -- 1107
				1.2, -- 1108
				lineAlpha, -- 1109
				0.08 -- 1110
			) -- 1110
		end -- 1110
		if view.assistHintsEnabled then -- 1110
			ctx.texts:put( -- 1114
				"xs", -- 1115
				"松开后重新按方向键迈步", -- 1116
				w * 0.5, -- 1117
				h - 26, -- 1118
				toColor(PALETTE.textDim), -- 1119
				0.5, -- 1120
				0.5, -- 1121
				"Center", -- 1122
				1.2, -- 1123
				0.78, -- 1124
				0.08 -- 1125
			) -- 1125
		end -- 1125
		return true -- 1128
	end -- 1128
	return true -- 1132
end -- 1028
function ____exports.createGateTransitionPlugin() -- 1136
	return __TS__New(____exports.GateTransitionPlugin) -- 1137
end -- 1136
return ____exports -- 1136