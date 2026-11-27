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
local ____target = require("Script.watch.target") -- 30
local getActiveTarget = ____target.getActiveTarget -- 30
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
	if n == 19 then -- 101
		return 0.68 -- 102
	end -- 102
	if n == 18 then -- 104
		return 0.8 -- 105
	end -- 105
	if n == 20 then -- 107
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
	if p.room.key ~= "gate" then -- 202
		return false -- 203
	end -- 203
	if p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 205
		return true -- 206
	end -- 206
	if p.phase == "gate-walk" and view.storyRoute ~= "soldier" then -- 208
		return true -- 209
	end -- 209
	return false -- 211
end -- 201
function GateTransitionPlugin.prototype.gestureStageForTick(self, tick, view) -- 214
	if view.storyRoute == "soldier" and (view.gateReunion.completed or view.gateReunion.active) then -- 215
		return 5 -- 216
	end -- 216
	if tick >= view.countDurationTicks then -- 218
		return 4 -- 219
	end -- 219
	if tick >= 1260 then -- 221
		return 3 -- 222
	end -- 222
	if tick >= 1080 then -- 224
		return 2 -- 225
	end -- 225
	if tick >= 480 then -- 227
		return 1 -- 228
	end -- 228
	return 0 -- 230
end -- 214
function GateTransitionPlugin.prototype.update(self, ctx) -- 233
	local p = ctx.p -- 234
	local view = ctx.view -- 235
	local want = self:shouldActivate(p, view) -- 236
	if not want then -- 238
		if self.wasActive then -- 239
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
	local ____opt_0 = p.room.story -- 254
	local g = ____opt_0 and ____opt_0.gate -- 254
	local doorX = g ~= nil and g.doorX or p.ox + 860 -- 255
	self.lockThresholdX = doorX + 14 -- 257
	self.lockFootX = p.player.x -- 258
	if not ctx.paused then -- 260
		self.animTime = self.animTime + ctx.worldDt -- 261
		if self.countCueAge < 20 then -- 262
			self.countCueAge = self.countCueAge + ctx.worldDt -- 263
		end -- 263
		if self.g04LineAge >= 0 and self.g04LineAge < 20 then -- 265
			self.g04LineAge = self.g04LineAge + ctx.worldDt -- 266
		end -- 266
	end -- 266
	if p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-walk" then -- 271
		self.rawMorph = 1 -- 272
	else -- 272
		self.rawMorph = clamp01(view.countElapsedTicks / math.max(1, view.countDurationTicks)) -- 274
	end -- 274
	local reunionDone = p.phase == "gate-hand" or view.storyRoute == "soldier" and view.gateReunion.completed -- 278
	if reunionDone then -- 279
		if not ctx.paused then -- 280
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
	if lockCamera then -- 293
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
	if justEntered and tick > 12 then -- 328
		self.lastTriggeredCount = countNum -- 330
		self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 331
		self.countCueAge = 0.6 -- 332
		self.lastGestureStage = stage -- 333
		if tick >= view.countDurationTicks and view.storyRoute ~= "soldier" then -- 334
			self.g04LineTriggered = true -- 335
			self.g04LineAge = 0.5 -- 336
		end -- 336
	elseif jumped then -- 338
		self.pendingBreath19 = false -- 339
		self.lastTriggeredCount = countNum -- 340
		self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 341
		self.countCueAge = 0.35 -- 342
		self.lastGestureStage = stage -- 343
		if tick < view.countDurationTicks then -- 344
			self.g04LineTriggered = false -- 345
			self.g04LineAge = -1 -- 346
			self.rehearsalKnockTimer = -1 -- 347
			self.rehearsalKnockStage = 0 -- 348
		end -- 348
	elseif not ctx.paused and (p.phase == "gate-count" or p.phase == "gate-wait") then -- 350
		if countNum > self.lastTriggeredCount then -- 351
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
		if stage ~= self.lastGestureStage then -- 367
			self.lastGestureStage = stage -- 368
			self.gestureChangeCount = self.gestureChangeCount + 1 -- 369
		end -- 369
	end -- 369
	if self.pendingBreath19 and self.countCueAge >= 0.78 and not ctx.paused and p.phase == "gate-count" then -- 373
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
	if isChildWait and not self.g04LineTriggered and not ctx.paused then -- 389
		self.g04LineTriggered = true -- 390
		self.g04LineAge = 0 -- 391
	end -- 391
	local isSoldierWait = view.storyRoute == "soldier" and (p.phase == "gate-wait" or p.phase == "gate-count" and view.gateReunion.active and not view.gateReunion.completed) -- 395
	if isSoldierWait and view.isRehearsal and not ctx.paused then -- 397
		if self.rehearsalKnockTimer < 0 then -- 398
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
			if self.rehearsalKnockStage < 2 and self.rehearsalKnockTimer >= 12 / 60 then -- 411
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
	if not ctx.paused then -- 426
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
		if isChildWait then -- 434
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
	if not self.active then -- 450
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
	if pixelBgAlpha > 0.01 then -- 468
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
	if farReveal > 0.01 then -- 481
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
			-40, -- 497
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
		scene:flush(bgDraw, bgGlow) -- 574
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
	if not self.active then -- 593
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
	if stepReveal > 0.01 then -- 611
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
	if wallReveal > 0.01 then -- 649
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
	if frameLightStrength > 0.02 then -- 696
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
	if 160 - doorBotY > 2 and doorAlpha > 0.02 then -- 724
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
				if byBand + 6 < 158 then -- 743
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
		if closeFrac < 0.98 then -- 760
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
	if plankReveal > 0.01 then -- 805
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
		local wave1 = math.sin(self.animTime * windFreq) * (4 + 6 * m) -- 841
		local wave2 = math.cos(self.animTime * windFreq * 0.85) * (3 + 4 * m) -- 842
		scene:addTri3D( -- 843
			vec3(clothBaseX, clothTopY, -12), -- 844
			vec3(clothBaseX + 7, clothTopY - 2, -12), -- 845
			vec3(clothBaseX - 8 + wave1, clothTopY - 24 + wave2 * 0.3, -15), -- 846
			MING_MATERIALS.mingRedCloth, -- 847
			{bucket = LP_BUCKET.PROP, opacity = plankReveal, sortBias = 0.35, edgeWidth = 0.9} -- 848
		) -- 848
		scene:addTri3D( -- 850
			vec3(clothBaseX + 7, clothTopY - 2, -12), -- 851
			vec3(clothBaseX - 8 + wave1, clothTopY - 24 + wave2 * 0.3, -15), -- 852
			vec3(clothBaseX + 2 + wave2, clothTopY - 20, -13), -- 853
			MING_MATERIALS.mingRedCloth, -- 854
			{bucket = LP_BUCKET.PROP, opacity = plankReveal * 0.9, sortBias = 0.36} -- 855
		) -- 855
	end -- 855
	scene:addContactShadow( -- 860
		p.player.x, -- 860
		p.player.y, -- 860
		16, -- 860
		12, -- 860
		0.62 + 0.28 * m, -- 860
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 860
	) -- 860
	scene:flush(fgDraw, fgGlow) -- 866
	local hidePartnerInside = self.reunionPixelReturn < 0.85 and closeFrac > 0.6 -- 870
	if hidePartnerInside then -- 871
		local wallRightX = cam:sx(thX - 1) -- 872
		local wallLeftX = cam:sx(doorLeft - 140) -- 873
		local wallW = math.max(2, wallRightX - wallLeftX) -- 874
		local wallTopY = cam:sy(164, p.player.depth) -- 875
		local wallBotY = cam:sy(0, p.player.depth) -- 876
		local wallH = math.max(2, wallTopY - wallBotY) -- 877
		local wallOp = clamp01((closeFrac - 0.6) / 0.28) * (1 - self.reunionPixelReturn) -- 878
		worldArt:tryPlace( -- 879
			"wall", -- 880
			"gate_closed_wall_mask", -- 881
			(wallLeftX + wallRightX) * 0.5, -- 882
			wallBotY, -- 883
			wallW, -- 884
			wallH, -- 885
			{ -- 886
				layer = 4102, -- 887
				color = Color(52, 56, 66, 255), -- 888
				opacity = wallOp -- 889
			} -- 889
		) -- 889
		local doorPanelL = cam:sx(thX - 112) -- 892
		local doorPanelR = cam:sx(thX - 1) -- 893
		worldArt:tryPlace( -- 894
			"prop_tower_door", -- 895
			"gate_closed_door_leaf", -- 896
			(doorPanelL + doorPanelR) * 0.5, -- 897
			wallBotY, -- 898
			math.max(2, doorPanelR - doorPanelL), -- 899
			wallH, -- 900
			{ -- 901
				layer = 4103, -- 902
				color = Color(86, 74, 62, 255), -- 903
				opacity = wallOp -- 904
			} -- 904
		) -- 904
	end -- 904
	local fgBeamAlpha = smoothstep(0.42, 0.95, m) * (1 - self.reunionPixelReturn) -- 910
	if fgBeamAlpha > 0.02 then -- 911
		scene:placeForegroundOccluder( -- 912
			worldArt, -- 913
			"cover_wood", -- 914
			"gate_fg_beam_right", -- 915
			thX + 266, -- 916
			thX + 356, -- 917
			-42, -- 918
			22, -- 919
			-68, -- 920
			{ -- 921
				color = Color(14, 17, 24, 255), -- 921
				opacity = 0.92 * fgBeamAlpha, -- 921
				layer = 5200 -- 921
			} -- 921
		) -- 921
	end -- 921
	return true -- 925
end -- 587
function GateTransitionPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 928
	return self.active and ctx.p.phase ~= "gate-walk" -- 935
end -- 928
function GateTransitionPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 938
	if not self.active then -- 944
		return -- 945
	end -- 945
	local p = ctx.p -- 947
	local view = ctx.view -- 948
	local cam = ctx.cam -- 949
	local tick = view.countElapsedTicks -- 950
	local cx = cam:sx(p.player.x) -- 951
	local by = cam:sy(p.player.y, p.player.depth) -- 952
	local H = cam:len(p.player.h) -- 953
	if p.phase == "gate-count" and tick >= 1080 and tick < view.countDurationTicks then -- 956
		local leanK = smoothstep(1080, 1130, tick) -- 957
		local doorSx = cam:sx(self.lockThresholdX) -- 958
		local headY = by + H * 0.8 -- 959
		local earPulse = 0.55 + 0.45 * math.sin(self.animTime * 2.2) -- 961
		fgGlow:drawArc( -- 962
			Vec2(doorSx + 4, headY), -- 963
			12 + (1 - earPulse) * 8, -- 964
			-38, -- 965
			38, -- 966
			1.1, -- 967
			Color( -- 968
				214, -- 968
				224, -- 968
				236, -- 968
				math.floor(78 * leanK * earPulse + 0.5) -- 968
			) -- 968
		) -- 968
		if tick >= 1260 then -- 971
			local breathCycle = self.animTime * 0.7 % 1 -- 972
			local bAlpha = math.sin(breathCycle * math.pi) * 0.48 -- 973
			local bx = cx - 10 - breathCycle * 18 -- 974
			local bY = headY - 4 + breathCycle * 6 -- 975
			fillRadialGlow( -- 976
				fgGlow, -- 977
				bx, -- 978
				bY, -- 979
				12 + breathCycle * 10, -- 980
				7 + breathCycle * 6, -- 981
				Color( -- 982
					220, -- 982
					232, -- 982
					244, -- 982
					math.floor(110 * bAlpha + 0.5) -- 982
				), -- 982
				Color(180, 204, 228, 0), -- 983
				12 -- 984
			) -- 984
		end -- 984
	end -- 984
	local isChildIdle = p.phase == "gate-count" and tick >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 990
	if isChildIdle then -- 993
		local pouchX = cx + cam:len(6) -- 994
		local pouchY = by + H * 0.48 -- 995
		local pulse = 0.72 + 0.28 * math.sin(self.animTime * 2.4) -- 996
		fillRadialGlow( -- 997
			fgGlow, -- 998
			pouchX, -- 999
			pouchY, -- 1000
			18 * pulse, -- 1001
			18 * pulse, -- 1002
			Color( -- 1003
				236, -- 1003
				198, -- 1003
				128, -- 1003
				math.floor(64 * pulse + 0.5) -- 1003
			), -- 1003
			Color(220, 168, 86, 0), -- 1004
			12 -- 1005
		) -- 1005
		fgGlow:drawDot( -- 1007
			Vec2(pouchX, pouchY), -- 1007
			2.1, -- 1007
			toColor( -- 1007
				PALETTE.amberCore, -- 1007
				math.floor(190 * pulse + 0.5) -- 1007
			) -- 1007
		) -- 1007
	end -- 1007
	local isSoldierWait = view.storyRoute == "soldier" and not view.gateReunion.completed and (p.phase == "gate-wait" or p.phase == "gate-count" and view.gateReunion.active) -- 1011
	if isSoldierWait then -- 1014
		local wallSx = cam:sx(self.lockThresholdX + 2) -- 1015
		local knockY = by + H * 0.56 -- 1016
		local ringCycle = self.animTime * 0.85 % 1 -- 1017
		local r1 = 8 + ringCycle * 34 -- 1018
		local a1 = (1 - ringCycle) * 0.72 -- 1019
		fgGlow:drawRing( -- 1020
			Vec2(wallSx, knockY), -- 1020
			math.max(1, r1 - 1.5), -- 1020
			r1, -- 1020
			Color(0, 0, 0, 0), -- 1020
			1.3, -- 1020
			toColor(PALETTE.amber, 210 * a1) -- 1020
		) -- 1020
		local handX = cx - cam:len(10) -- 1022
		local handY = by + H * 0.62 + math.sin(self.animTime * 2.6) * 2 -- 1023
		fgDraw:drawSegment( -- 1024
			Vec2( -- 1024
				cx - cam:len(3), -- 1024
				by + H * 0.56 -- 1024
			), -- 1024
			Vec2(handX, handY), -- 1024
			2.4, -- 1024
			Color(230, 206, 182, 220) -- 1024
		) -- 1024
		fgGlow:drawDot( -- 1025
			Vec2(handX, handY), -- 1025
			2.4, -- 1025
			toColor(PALETTE.amberCore, 165) -- 1025
		) -- 1025
	end -- 1025
end -- 938
function GateTransitionPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 1029
	if not self.active then -- 1036
		return false -- 1037
	end -- 1037
	local p = ctx.p -- 1039
	local view = ctx.view -- 1040
	local w = ctx.uiW -- 1041
	local h = ctx.uiH -- 1042
	if p.phase == "gate-walk" then -- 1045
		return false -- 1046
	end -- 1046
	local barH = math.floor(52 * (1 - self.reunionPixelReturn * 0.35) + 0.5) -- 1050
	uiDraw:drawRect( -- 1051
		Rect(0, h - barH, w, barH), -- 1051
		Color(8, 10, 16, 236) -- 1051
	) -- 1051
	uiDraw:drawRect( -- 1052
		Rect(0, 0, w, barH), -- 1052
		Color(8, 10, 16, 236) -- 1052
	) -- 1052
	uiInkDraw:drawSegment( -- 1053
		Vec2(0, h - barH), -- 1053
		Vec2(w, h - barH), -- 1053
		0.7, -- 1053
		toColor(PALETTE.silkDim, 68) -- 1053
	) -- 1053
	uiInkDraw:drawSegment( -- 1054
		Vec2(0, barH), -- 1054
		Vec2(w, barH), -- 1054
		0.7, -- 1054
		toColor(PALETTE.silkDim, 68) -- 1054
	) -- 1054
	local inCounting = p.phase == "gate-count" and view.countElapsedTicks < view.countDurationTicks -- 1057
	if inCounting and self.activeCountZh ~= "" then -- 1058
		local isBreathNum = view.countNumber == 19 -- 1059
		local fadeIn = smoothstep(0, 0.16, self.countCueAge) -- 1060
		local holdOut = 1 - smoothstep(isBreathNum and 2.1 or 1.15, isBreathNum and 2.85 or 1.65, self.countCueAge) -- 1061
		local numAlpha = clamp01(fadeIn * math.max(0.28, holdOut)) * (isBreathNum and 0.68 or 0.9) -- 1062
		local nx = w * 0.84 -- 1064
		local ny = h * 0.74 -- 1065
		drawMistCurve( -- 1066
			uiArt, -- 1066
			"gate_whisper_mist", -- 1066
			nx, -- 1066
			ny, -- 1066
			190, -- 1066
			44, -- 1066
			PALETTE.jadeMist, -- 1066
			0.18 * numAlpha, -- 1066
			0 -- 1066
		) -- 1066
		ctx.texts:put( -- 1067
			"banner", -- 1068
			self.activeCountZh, -- 1069
			nx, -- 1070
			ny + 6, -- 1071
			toColor(PALETTE.textBright), -- 1072
			0.5, -- 1073
			0.5, -- 1074
			"Center", -- 1075
			4, -- 1076
			numAlpha, -- 1077
			0.1 -- 1078
		) -- 1078
		local whisperText = view.countNumber == 18 and "「十八……」" or (view.countNumber == 19 and "「……十九……」" or ("「" .. self.activeCountZh) .. "……」") -- 1081
		drawSilkVeil( -- 1084
			uiDraw, -- 1084
			uiArt, -- 1084
			"gate_count_sub_veil", -- 1084
			w * 0.5, -- 1084
			26, -- 1084
			320, -- 1084
			36, -- 1084
			PALETTE.inkWash, -- 1084
			0.72 * numAlpha, -- 1084
			-1 -- 1084
		) -- 1084
		ctx.texts:put( -- 1085
			"sm", -- 1085
			whisperText, -- 1085
			w * 0.5, -- 1085
			26, -- 1085
			toColor(PALETTE.textMid), -- 1085
			0.5, -- 1085
			0.5, -- 1085
			"Center", -- 1085
			1.4, -- 1085
			numAlpha, -- 1085
			0.08 -- 1085
		) -- 1085
		return true -- 1086
	end -- 1086
	local isChildDone = p.phase == "gate-count" and view.countElapsedTicks >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 1090
	if isChildDone then -- 1093
		local lineAlpha = self.g04LineAge >= 0 and smoothstep(0, 0.25, self.g04LineAge) * (1 - smoothstep(3.8, 5.2, self.g04LineAge)) or 0.9 -- 1094
		if lineAlpha > 0.02 then -- 1097
			drawSilkVeil( -- 1098
				uiDraw, -- 1098
				uiArt, -- 1098
				"gate_g04_veil", -- 1098
				w * 0.5, -- 1098
				26, -- 1098
				460, -- 1098
				38, -- 1098
				PALETTE.inkWash, -- 1098
				0.78 * lineAlpha, -- 1098
				-1 -- 1098
			) -- 1098
			drawHairline( -- 1099
				uiInkDraw, -- 1099
				uiArt, -- 1099
				"gate_g04_line", -- 1099
				w * 0.5, -- 1099
				44, -- 1099
				300, -- 1099
				PALETTE.silkDim, -- 1099
				0.45 * lineAlpha, -- 1099
				true, -- 1099
				2 -- 1099
			) -- 1099
			ctx.texts:put( -- 1100
				"sm", -- 1101
				"「……二十了。我往北去了。」", -- 1102
				w * 0.5, -- 1103
				26, -- 1104
				toColor(PALETTE.textBright), -- 1105
				0.5, -- 1106
				0.5, -- 1107
				"Center", -- 1108
				1.2, -- 1109
				lineAlpha, -- 1110
				0.08 -- 1111
			) -- 1111
		end -- 1111
		if view.assistHintsEnabled then -- 1114
			ctx.texts:put( -- 1115
				"xs", -- 1116
				getActiveTarget():adaptHintSentence("松开后重新按方向键迈步", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1117
				w * 0.5, -- 1118
				h - 26, -- 1119
				toColor(PALETTE.textDim), -- 1120
				0.5, -- 1121
				0.5, -- 1122
				"Center", -- 1123
				1.2, -- 1124
				0.78, -- 1125
				0.08 -- 1126
			) -- 1126
		end -- 1126
		return true -- 1129
	end -- 1129
	return true -- 1133
end -- 1029
function ____exports.createGateTransitionPlugin() -- 1137
	return __TS__New(____exports.GateTransitionPlugin) -- 1138
end -- 1137
return ____exports -- 1137
