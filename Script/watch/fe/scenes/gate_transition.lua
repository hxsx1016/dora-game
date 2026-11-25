-- [ts]: gate_transition.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 24
local Color = ____Dora.Color -- 24
local Rect = ____Dora.Rect -- 24
local Vec2 = ____Dora.Vec2 -- 24
local ____play = require("watch.play") -- 25
local GATE_COUNT_END = ____play.GATE_COUNT_END -- 25
local ____lowpoly = require("watch.fe.renderer.lowpoly") -- 30
local GATE_NIGHTMARE_LIGHT = ____lowpoly.GATE_NIGHTMARE_LIGHT -- 31
local LP_BUCKET = ____lowpoly.LP_BUCKET -- 32
local LowpolyScene = ____lowpoly.LowpolyScene -- 34
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 35
local clamp01 = ____lowpoly.clamp01 -- 36
local projectWorld3D = ____lowpoly.projectWorld3D -- 37
local smoothstep = ____lowpoly.smoothstep -- 38
local vec3 = ____lowpoly.vec3 -- 39
local ____theme = require("watch.fe.theme") -- 41
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
	self.activeCountZh = "" -- 123
	self.g04LineAge = -1 -- 124
	self.g04LineTriggered = false -- 125
	self.reunionTimer = 0 -- 126
	self.reunionPixelReturn = 0 -- 127
	self.rehearsalKnockTimer = -1 -- 128
	self.rehearsalKnockStage = 0 -- 129
	self.lockFootX = 890 -- 130
	self.lockThresholdX = 848 -- 131
	self.subtitleCountShown = 0 -- 132
	self.gestureChangeCount = 0 -- 133
	self.lastGestureStage = 0 -- 134
	self.activeProjection = { -- 135
		morph = 0, -- 136
		focal = GATE_FOCAL, -- 137
		vpFracX = GATE_VP_FRAC_X, -- 138
		vpFracY = GATE_VP_FRAC_Y, -- 139
		vpOffsetX = 0, -- 140
		vpOffsetY = 0, -- 141
		baseDepth = 0 -- 142
	} -- 142
end -- 112
function GateTransitionPlugin.prototype.onBindPlay(self, _p, _view) -- 145
	self:resetState() -- 146
end -- 145
function GateTransitionPlugin.prototype.resetState(self) -- 149
	self.animTime = 0 -- 150
	self.active = false -- 151
	self.wasActive = false -- 152
	self.rawMorph = 0 -- 153
	self.effectiveMorph = 0 -- 154
	self.lastCountTick = -1 -- 155
	self.lastTriggeredCount = 0 -- 156
	self.countCueAge = 99 -- 157
	self.activeCountZh = "" -- 158
	self.g04LineAge = -1 -- 159
	self.g04LineTriggered = false -- 160
	self.reunionTimer = 0 -- 161
	self.reunionPixelReturn = 0 -- 162
	self.rehearsalKnockTimer = -1 -- 163
	self.rehearsalKnockStage = 0 -- 164
	self.subtitleCountShown = 0 -- 165
	self.gestureChangeCount = 0 -- 166
	self.lastGestureStage = 0 -- 167
end -- 149
function GateTransitionPlugin.prototype.getProjection(self) -- 170
	return self.activeProjection -- 171
end -- 170
function GateTransitionPlugin.prototype.getDebugState(self) -- 174
	local earToDoor = self.active and self.lastCountTick >= 1080 and self.lastCountTick < GATE_COUNT_END -- 175
	local breathPause = self.active and self.lastCountTick >= 1260 and self.lastCountTick < GATE_COUNT_END -- 176
	return { -- 177
		active = self.active, -- 178
		morph = self.rawMorph, -- 179
		effectiveMorph = self.effectiveMorph, -- 180
		countTick = math.max(0, self.lastCountTick), -- 181
		countNumber = self.lastTriggeredCount, -- 182
		lastTriggeredCount = self.lastTriggeredCount, -- 183
		earToDoor = earToDoor, -- 184
		breathPause = breathPause, -- 185
		g04Idle = self.g04LineTriggered, -- 186
		g05Waiting = self.rehearsalKnockStage > 0 and self.reunionTimer <= 0, -- 187
		reunionTimer = self.reunionTimer, -- 188
		reunionPixelReturn = self.reunionPixelReturn, -- 189
		thresholdWorldX = self.lockThresholdX, -- 190
		footWorldX = self.lockFootX, -- 191
		rehearsalKnockStage = self.rehearsalKnockStage, -- 192
		subtitleCountShown = self.subtitleCountShown, -- 193
		gestureChangeCount = self.gestureChangeCount -- 194
	} -- 194
end -- 174
function GateTransitionPlugin.prototype.shouldActivate(self, p, view) -- 198
	if p.room.key ~= "gate" then -- 198
		return false -- 200
	end -- 200
	if p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 200
		return true -- 203
	end -- 203
	if p.phase == "gate-walk" and view.storyRoute ~= "soldier" then -- 203
		return true -- 206
	end -- 206
	return false -- 208
end -- 198
function GateTransitionPlugin.prototype.gestureStageForTick(self, tick, view) -- 211
	if view.storyRoute == "soldier" and (view.gateReunion.completed or view.gateReunion.active) then -- 211
		return 5 -- 213
	end -- 213
	if tick >= view.countDurationTicks then -- 213
		return 4 -- 216
	end -- 216
	if tick >= 1260 then -- 216
		return 3 -- 219
	end -- 219
	if tick >= 1080 then -- 219
		return 2 -- 222
	end -- 222
	if tick >= 480 then -- 222
		return 1 -- 225
	end -- 225
	return 0 -- 227
end -- 211
function GateTransitionPlugin.prototype.update(self, ctx) -- 230
	local p = ctx.p -- 231
	local view = ctx.view -- 232
	local want = self:shouldActivate(p, view) -- 233
	if not want then -- 233
		if self.wasActive then -- 233
			ctx.cam:setAnchorLock(nil) -- 237
			ctx.audio:stopLoop("gate_wind", 0.25) -- 238
			ctx.audio:stopLoop("gate_water", 0.25) -- 239
			ctx.audio:stopLoop("gate_breath", 0.2) -- 240
			self.wasActive = false -- 241
		end -- 241
		self.active = false -- 243
		return -- 244
	end -- 244
	self.active = true -- 247
	local justEntered = not self.wasActive -- 248
	self.wasActive = true -- 249
	local ____opt_0 = p.room.story -- 249
	local g = ____opt_0 and ____opt_0.gate -- 251
	local doorX = g ~= nil and g.doorX or p.ox + 860 -- 252
	self.lockThresholdX = doorX + 14 -- 254
	self.lockFootX = p.player.x -- 255
	if not ctx.paused then -- 255
		self.animTime = self.animTime + ctx.worldDt -- 258
		if self.countCueAge < 20 then -- 258
			self.countCueAge = self.countCueAge + ctx.worldDt -- 260
		end -- 260
		if self.g04LineAge >= 0 and self.g04LineAge < 20 then -- 260
			self.g04LineAge = self.g04LineAge + ctx.worldDt -- 263
		end -- 263
	end -- 263
	if p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-walk" then -- 263
		self.rawMorph = 1 -- 269
	else -- 269
		self.rawMorph = clamp01(view.countElapsedTicks / math.max(1, view.countDurationTicks)) -- 271
	end -- 271
	local reunionDone = p.phase == "gate-hand" or view.storyRoute == "soldier" and view.gateReunion.completed -- 275
	if reunionDone then -- 275
		if not ctx.paused then -- 275
			self.reunionTimer = self.reunionTimer + ctx.worldDt -- 278
		end -- 278
		self.reunionPixelReturn = smoothstep(____exports.G05_PIXEL_RETURN_START, ____exports.G05_PIXEL_RETURN_END, self.reunionTimer) -- 280
		self.effectiveMorph = clamp01(1 - self.reunionPixelReturn) -- 281
	else -- 281
		self.reunionTimer = 0 -- 283
		self.reunionPixelReturn = 0 -- 284
		self.effectiveMorph = self.rawMorph -- 285
	end -- 285
	local lockCamera = (p.phase == "gate-count" or p.phase == "gate-wait") and self.reunionPixelReturn < 0.98 -- 289
	if lockCamera then -- 289
		local tiltLift = self.reunionPixelReturn * 0.055 -- 292
		ctx.cam:setAnchorLock({ -- 293
			footWorldX = self.lockFootX, -- 294
			footWorldY = p.player.y, -- 295
			footDepth = p.player.depth, -- 296
			thresholdWorldX = self.lockThresholdX, -- 297
			screenFootFracX = GATE_ANCHOR_FOOT_FRAC_X, -- 298
			screenFootFracY = GATE_ANCHOR_FOOT_FRAC_Y - tiltLift, -- 299
			zoomOverride = GATE_ANCHOR_ZOOM + self.reunionPixelReturn * 0.07 -- 300
		}) -- 300
	else -- 300
		ctx.cam:setAnchorLock(nil) -- 303
	end -- 303
	local breathPhase = self.animTime * 1.35 -- 307
	local breatheAmp = self.effectiveMorph > 0.01 and p.phase == "gate-count" and 1 - self.reunionPixelReturn or 0 -- 308
	self.activeProjection = { -- 309
		morph = self.effectiveMorph, -- 310
		focal = GATE_FOCAL, -- 311
		vpFracX = GATE_VP_FRAC_X, -- 312
		vpFracY = GATE_VP_FRAC_Y, -- 313
		vpOffsetX = math.sin(breathPhase * 0.7) * 3.5 * breatheAmp, -- 314
		vpOffsetY = math.cos(breathPhase) * 2.5 * breatheAmp, -- 315
		baseDepth = p.player.depth -- 316
	} -- 316
	local tick = view.countElapsedTicks -- 320
	local countNum = math.max( -- 321
		1, -- 321
		math.min(20, view.countNumber) -- 321
	) -- 321
	local jumped = self.lastCountTick >= 0 and (tick < self.lastCountTick or tick - self.lastCountTick > 36) -- 322
	local stage = self:gestureStageForTick(tick, view) -- 323
	if justEntered and tick > 12 then -- 323
		self.lastTriggeredCount = countNum -- 327
		self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 328
		self.countCueAge = 0.6 -- 329
		self.lastGestureStage = stage -- 330
		if tick >= view.countDurationTicks and view.storyRoute ~= "soldier" then -- 330
			self.g04LineTriggered = true -- 332
			self.g04LineAge = 0.5 -- 333
		end -- 333
	elseif jumped then -- 333
		self.lastTriggeredCount = countNum -- 336
		self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 337
		self.countCueAge = 0.35 -- 338
		self.lastGestureStage = stage -- 339
		if tick < view.countDurationTicks then -- 339
			self.g04LineTriggered = false -- 341
			self.g04LineAge = -1 -- 342
			self.rehearsalKnockTimer = -1 -- 343
			self.rehearsalKnockStage = 0 -- 344
		end -- 344
	elseif not ctx.paused and (p.phase == "gate-count" or p.phase == "gate-wait") then -- 344
		if countNum > self.lastTriggeredCount then -- 344
			self.lastTriggeredCount = countNum -- 348
			self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 349
			self.countCueAge = 0 -- 350
			self.subtitleCountShown = self.subtitleCountShown + 1 -- 351
			local dedupeKey = (("gate:count:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(countNum) -- 352
			ctx.audio:playOnce( -- 353
				dedupeKey, -- 354
				"voice", -- 355
				countVoicePath(countNum), -- 356
				countVoiceVolume(countNum), -- 357
				"gate:count:" .. tostring(countNum), -- 358
				tick -- 359
			) -- 359
			if countNum == 19 then -- 359
				ctx.audio:playOnce( -- 363
					"gate:breath19:" .. tostring(ctx.events.roomSessionId), -- 364
					"voice", -- 365
					GATE_AUDIO_ROOT .. "breath_soft.wav", -- 366
					0.48, -- 367
					"gate:breath_19", -- 368
					tick -- 369
				) -- 369
			end -- 369
		end -- 369
		if stage ~= self.lastGestureStage then -- 369
			self.lastGestureStage = stage -- 374
			self.gestureChangeCount = self.gestureChangeCount + 1 -- 375
		end -- 375
	end -- 375
	local isChildWait = p.phase == "gate-count" and tick >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 380
	if isChildWait and not self.g04LineTriggered and not ctx.paused then -- 380
		self.g04LineTriggered = true -- 384
		self.g04LineAge = 0 -- 385
	end -- 385
	local isSoldierWait = view.storyRoute == "soldier" and (p.phase == "gate-wait" or p.phase == "gate-count" and view.gateReunion.active and not view.gateReunion.completed) -- 389
	if isSoldierWait and view.isRehearsal and not ctx.paused then -- 389
		if self.rehearsalKnockTimer < 0 then -- 389
			self.rehearsalKnockTimer = 0 -- 393
			self.rehearsalKnockStage = 1 -- 394
			ctx.audio:playOnce( -- 395
				"gate:rehearsal:knock:1:" .. tostring(ctx.events.roomSessionId), -- 396
				"sfx", -- 397
				GATE_AUDIO_ROOT .. "knock_wall.wav", -- 398
				0.88, -- 399
				"knock:gate:1", -- 400
				tick -- 401
			) -- 401
		else -- 401
			self.rehearsalKnockTimer = self.rehearsalKnockTimer + ctx.worldDt -- 404
			if self.rehearsalKnockStage < 2 and self.rehearsalKnockTimer >= 12 / 60 then -- 404
				self.rehearsalKnockStage = 2 -- 406
				ctx.audio:playOnce( -- 407
					"gate:rehearsal:knock:2:" .. tostring(ctx.events.roomSessionId), -- 408
					"sfx", -- 409
					GATE_AUDIO_ROOT .. "knock_wall.wav", -- 410
					0.92, -- 411
					"knock:gate:2", -- 412
					tick -- 413
				) -- 413
			end -- 413
		end -- 413
	end -- 413
	if not ctx.paused then -- 413
		local voiceDuck = p.phase == "gate-count" and tick >= 1200 and tick <= 1480 and 0.52 or 1 -- 421
		local reunionCalm = reunionDone and 1 - self.reunionPixelReturn * 0.55 or 1 -- 422
		local windVol = (0.18 + 0.46 * self.effectiveMorph) * voiceDuck * reunionCalm -- 423
		local waterVol = (0.28 + 0.24 * self.effectiveMorph) * voiceDuck -- 424
		ctx.audio:playLoop( -- 425
			"gate_wind", -- 425
			"wind", -- 425
			GATE_AUDIO_ROOT .. "wind_loop.wav", -- 425
			windVol, -- 425
			tick -- 425
		) -- 425
		ctx.audio:playLoop( -- 426
			"gate_water", -- 426
			"water", -- 426
			GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 426
			waterVol, -- 426
			tick -- 426
		) -- 426
		if isChildWait then -- 426
			ctx.audio:playLoop( -- 428
				"gate_breath", -- 428
				"ambience", -- 428
				GATE_AUDIO_ROOT .. "breath_soft.wav", -- 428
				0.24, -- 428
				tick -- 428
			) -- 428
		else -- 428
			ctx.audio:stopLoop("gate_breath", 0.2) -- 430
		end -- 430
	end -- 430
	self.lastCountTick = tick -- 434
end -- 230
function GateTransitionPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 437
	if not self.active then -- 437
		return false -- 444
	end -- 444
	local cam = ctx.cam -- 446
	local w = cam.viewW -- 447
	local h = cam.viewH -- 448
	local m = self.effectiveMorph -- 449
	local skyTop = lerpRGBA( -- 452
		rgba(14, 10, 14, 255), -- 452
		rgba(8, 13, 22, 255), -- 452
		m -- 452
	) -- 452
	local skyMid = lerpRGBA( -- 453
		rgba(28, 17, 22, 255), -- 453
		rgba(16, 25, 38, 255), -- 453
		m -- 453
	) -- 453
	local skyHor = lerpRGBA( -- 454
		rgba(54, 28, 30, 255), -- 454
		rgba(30, 44, 62, 255), -- 454
		m -- 454
	) -- 454
	local splitY = h * 0.48 -- 455
	fillVGradRect( -- 456
		bgDraw, -- 456
		0, -- 456
		splitY, -- 456
		w, -- 456
		h - splitY, -- 456
		toColor(skyMid), -- 456
		toColor(skyTop) -- 456
	) -- 456
	fillVGradRect( -- 457
		bgDraw, -- 457
		0, -- 457
		0, -- 457
		w, -- 457
		splitY, -- 457
		toColor(skyHor), -- 457
		toColor(skyMid) -- 457
	) -- 457
	local pixelBgAlpha = 1 - smoothstep(0.08, 0.72, m) -- 460
	if pixelBgAlpha > 0.01 then -- 460
		local span = math.max(1, ctx.p.room.maxX - ctx.p.room.minX) -- 462
		local progress = (cam.x - ctx.p.room.minX) / span - 0.5 -- 463
		local artW = math.max(w, h * 16 / 9) + w * 0.12 -- 464
		local artH = artW * 9 / 16 -- 465
		backdropArt:tryPlace( -- 466
			"bgFar_gate", -- 466
			"gate_pixel_bg", -- 466
			w * (0.5 - progress * 0.09), -- 466
			(h - artH) * 0.5, -- 466
			artW, -- 466
			artH, -- 466
			{opacity = pixelBgAlpha, layer = 0} -- 466
		) -- 466
	end -- 466
	local farReveal = smoothstep(0.22, 0.85, m) -- 473
	if farReveal > 0.01 then -- 473
		local scene = __TS__New(LowpolyScene, cam, self.activeProjection, GATE_NIGHTMARE_LIGHT) -- 475
		local xMin = self.lockThresholdX - 320 -- 476
		local xMax = self.lockThresholdX + 680 -- 477
		local hillSep = smoothstep(0.45, 0.88, m) -- 480
		scene:addDistantRidge( -- 481
			{ -- 482
				{x = xMin, y = 112}, -- 483
				{x = self.lockThresholdX - 60, y = 176}, -- 484
				{x = self.lockThresholdX + 120, y = 146}, -- 485
				{x = self.lockThresholdX + 280, y = 204}, -- 486
				{x = self.lockThresholdX + 460, y = 164}, -- 487
				{x = xMax, y = 132} -- 488
			}, -- 488
			-40, -- 488
			520, -- 491
			MING_MATERIALS.distantHill, -- 492
			{bucket = LP_BUCKET.BACKDROP, opacity = farReveal * (0.55 + 0.45 * hillSep)} -- 493
		) -- 493
		scene:addFogBand( -- 497
			xMin, -- 497
			xMax, -- 497
			-30, -- 497
			190, -- 497
			360, -- 497
			rgba(38, 54, 74, 255), -- 497
			0.72 * hillSep, -- 497
			0.06 * hillSep, -- 497
			{bucket = LP_BUCKET.BACKDROP} -- 497
		) -- 497
		local wallMat = MING_MATERIALS.distantWall -- 502
		scene:addBox({ -- 503
			x0 = self.lockThresholdX + 40, -- 504
			x1 = xMax, -- 505
			y0 = -48, -- 506
			y1 = 96, -- 507
			z0 = 215, -- 508
			z1 = 260, -- 509
			material = wallMat, -- 510
			bucket = LP_BUCKET.BACKDROP, -- 511
			opacity = farReveal, -- 512
			highlightTopEdge = true, -- 513
			edgeWidth = 0 -- 514
		}) -- 514
		local merlonX = self.lockThresholdX + 64 -- 517
		local mi = 0 -- 518
		do -- 518
			mi = 0 -- 519
			while mi < 10 do -- 519
				scene:addBox({ -- 520
					x0 = merlonX, -- 521
					x1 = merlonX + 28, -- 522
					y0 = 96, -- 523
					y1 = 112, -- 524
					z0 = 215, -- 525
					z1 = 242, -- 526
					material = wallMat, -- 527
					bucket = LP_BUCKET.BACKDROP, -- 528
					opacity = farReveal, -- 529
					sortBias = 0.05, -- 530
					edgeWidth = 0 -- 531
				}) -- 531
				merlonX = merlonX + 56 -- 533
				mi = mi + 1 -- 519
			end -- 519
		end -- 519
		scene:addFogBand( -- 537
			xMin, -- 537
			xMax, -- 537
			-44, -- 537
			108, -- 537
			148, -- 537
			rgba(32, 46, 66, 255), -- 537
			0.64 * farReveal, -- 537
			0.04, -- 537
			{bucket = LP_BUCKET.BACKDROP} -- 537
		) -- 537
		local beaconP = projectWorld3D( -- 542
			self.lockThresholdX + 210, -- 542
			146, -- 542
			490, -- 542
			cam, -- 542
			self.activeProjection -- 542
		) -- 542
		local pulse = 0.82 + 0.18 * math.sin(self.animTime * 2.1) -- 543
		fillRadialGlow( -- 544
			bgGlow, -- 545
			beaconP.x, -- 546
			beaconP.y, -- 547
			34 * farReveal * pulse, -- 548
			34 * farReveal * pulse, -- 549
			Color( -- 550
				246, -- 550
				212, -- 550
				148, -- 550
				math.floor(92 * farReveal * pulse + 0.5) -- 550
			), -- 550
			Color(232, 180, 96, 0), -- 551
			16 -- 552
		) -- 552
		bgGlow:drawDot( -- 554
			Vec2(beaconP.x, beaconP.y), -- 554
			2.6 * farReveal, -- 554
			Color( -- 554
				255, -- 554
				244, -- 554
				212, -- 554
				math.floor(235 * farReveal + 0.5) -- 554
			) -- 554
		) -- 554
		local moatY = -36 -- 557
		local waterA = 0.42 * farReveal -- 558
		local ri = 0 -- 559
		do -- 559
			ri = 0 -- 560
			while ri < 6 do -- 560
				local rx = self.lockThresholdX + 110 + ri * 68 + math.sin(self.animTime * 1.1 + ri * 1.7) * 8 -- 561
				local pL = projectWorld3D( -- 562
					rx - 18, -- 562
					moatY - ri % 2 * 6, -- 562
					128 + ri * 12, -- 562
					cam, -- 562
					self.activeProjection -- 562
				) -- 562
				local pR = projectWorld3D( -- 563
					rx + 18, -- 563
					moatY - ri % 2 * 6, -- 563
					128 + ri * 12, -- 563
					cam, -- 563
					self.activeProjection -- 563
				) -- 563
				bgGlow:drawSegment( -- 564
					Vec2(pL.x, pL.y), -- 564
					Vec2(pR.x, pR.y), -- 564
					1.1, -- 564
					Color( -- 564
						168, -- 564
						198, -- 564
						224, -- 564
						math.floor(90 * waterA + 0.5) -- 564
					) -- 564
				) -- 564
				ri = ri + 1 -- 560
			end -- 560
		end -- 560
		scene:flush(bgDraw, bgGlow) -- 567
	end -- 567
	local mx = w * 0.66 -- 571
	local my = h * 0.82 -- 572
	local mr = math.max(15, h * 0.032) -- 573
	fillRadialGlow( -- 574
		bgGlow, -- 574
		mx, -- 574
		my, -- 574
		mr * 4.8, -- 574
		mr * 4.8, -- 574
		Color( -- 574
			164, -- 574
			202, -- 574
			232, -- 574
			math.floor(18 + 20 * m + 0.5) -- 574
		), -- 574
		Color(24, 42, 68, 0), -- 574
		18 -- 574
	) -- 574
	bgDraw:drawCircle( -- 575
		Vec2(mx, my), -- 575
		mr, -- 575
		Color( -- 575
			218, -- 575
			232, -- 575
			246, -- 575
			math.floor(115 + 85 * m + 0.5) -- 575
		) -- 575
	) -- 575
	return true -- 577
end -- 437
function GateTransitionPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 580
	if not self.active then -- 580
		return false -- 587
	end -- 587
	local p = ctx.p -- 589
	local cam = ctx.cam -- 590
	local m = self.effectiveMorph -- 591
	local thX = self.lockThresholdX -- 592
	local doorLeft = thX - 108 -- 593
	local scene = __TS__New(LowpolyScene, cam, self.activeProjection, GATE_NIGHTMARE_LIGHT) -- 595
	local closeFrac = p.phase == "gate-count" and 0.44 + 0.56 * clamp01(ctx.view.countElapsedTicks / 360) or 1 -- 598
	local stepReveal = smoothstep(0.18, 0.58, m) -- 603
	if stepReveal > 0.01 then -- 603
		local stairSpec = { -- 605
			x0 = thX + 108, -- 606
			x1 = thX + 292, -- 607
			y0 = -56, -- 608
			y1 = 2, -- 609
			steps = 5, -- 610
			label = "外壕石阶" -- 611
		} -- 611
		local k = 0 -- 614
		local n = stairSpec.steps + 1 -- 615
		local stepW = (stairSpec.x1 - stairSpec.x0) / n -- 616
		do -- 616
			k = 0 -- 617
			while k < n do -- 617
				local wy = stairSpec.y1 - (stairSpec.y1 - stairSpec.y0) * (k / math.max(1, n - 1)) -- 618
				local sx0 = stairSpec.x0 + k * stepW -- 619
				local sx1 = sx0 + stepW + 1 -- 620
				scene:addBox({ -- 621
					x0 = sx0, -- 622
					x1 = sx1, -- 623
					y0 = -78, -- 624
					y1 = wy, -- 625
					z0 = 26, -- 626
					z1 = 106, -- 627
					material = MING_MATERIALS.mingStoneStep, -- 628
					bucket = LP_BUCKET.MIDGROUND, -- 629
					opacity = stepReveal, -- 630
					sortBias = k * 0.02, -- 631
					highlightTopEdge = true, -- 632
					edgeWidth = 0.9 -- 633
				}) -- 633
				k = k + 1 -- 617
			end -- 617
		end -- 617
	end -- 617
	local wallReveal = smoothstep(0.02, 0.22, m) -- 640
	local frameLightStrength = smoothstep(0.1, 0.34, m) * (1 - 0.35 * smoothstep(0.85, 1, m)) -- 641
	if wallReveal > 0.01 then -- 641
		scene:addBox({ -- 643
			x0 = doorLeft - 140, -- 644
			x1 = thX - 18, -- 645
			y0 = -60, -- 646
			y1 = 230, -- 647
			z0 = -12, -- 648
			z1 = 88, -- 649
			material = MING_MATERIALS.mingBrick, -- 650
			bucket = LP_BUCKET.MIDGROUND, -- 651
			opacity = wallReveal, -- 652
			highlightTopEdge = true, -- 653
			edgeWidth = 0.75 -- 654
		}) -- 654
		scene:addBox({ -- 657
			x0 = thX - 18, -- 658
			x1 = thX, -- 659
			y0 = 0, -- 660
			y1 = 162, -- 661
			z0 = -6, -- 662
			z1 = 72, -- 663
			material = MING_MATERIALS.mingStoneStep, -- 664
			bucket = LP_BUCKET.MIDGROUND, -- 665
			opacity = wallReveal, -- 666
			sortBias = 0.08, -- 667
			highlightTopEdge = true, -- 668
			edgeWidth = 0.9 -- 669
		}) -- 669
		scene:addBox({ -- 672
			x0 = doorLeft - 40, -- 673
			x1 = thX + 76, -- 674
			y0 = 160, -- 675
			y1 = 214, -- 676
			z0 = -14, -- 677
			z1 = 82, -- 678
			material = MING_MATERIALS.mingBrickDark, -- 679
			bucket = LP_BUCKET.MIDGROUND, -- 680
			opacity = wallReveal, -- 681
			sortBias = 0.12, -- 682
			highlightTopEdge = true, -- 683
			edgeWidth = 0.8 -- 684
		}) -- 684
	end -- 684
	if frameLightStrength > 0.02 then -- 684
		scene:addLightShaft( -- 690
			thX + 16, -- 691
			thX + 34, -- 691
			160, -- 691
			thX - 4, -- 692
			thX + 24, -- 692
			0, -- 692
			16, -- 693
			rgba(220, 234, 248, 255), -- 694
			0.24 * frameLightStrength, -- 695
			0.04 * frameLightStrength -- 696
		) -- 696
		local pBotNear = scene:project(thX, 0, -6) -- 699
		local pBotFar = scene:project(thX, 0, 72) -- 700
		local pTopFar = scene:project(thX, 160, 72) -- 701
		local pTopNear = scene:project(thX, 160, -6) -- 702
		local glowA = math.floor(140 * frameLightStrength + 0.5) -- 703
		fgGlow:drawVertices({ -- 704
			{ -- 705
				Vec2(pBotNear.x, pBotNear.y), -- 705
				Color(224, 236, 248, glowA) -- 705
			}, -- 705
			{ -- 706
				Vec2(pBotFar.x, pBotFar.y), -- 706
				Color( -- 706
					168, -- 706
					196, -- 706
					224, -- 706
					math.floor(glowA * 0.25 + 0.5) -- 706
				) -- 706
			}, -- 706
			{ -- 707
				Vec2(pTopFar.x, pTopFar.y), -- 707
				Color( -- 707
					168, -- 707
					196, -- 707
					224, -- 707
					math.floor(glowA * 0.25 + 0.5) -- 707
				) -- 707
			}, -- 707
			{ -- 708
				Vec2(pBotNear.x, pBotNear.y), -- 708
				Color(224, 236, 248, glowA) -- 708
			}, -- 708
			{ -- 709
				Vec2(pTopFar.x, pTopFar.y), -- 709
				Color( -- 709
					168, -- 709
					196, -- 709
					224, -- 709
					math.floor(glowA * 0.25 + 0.5) -- 709
				) -- 709
			}, -- 709
			{ -- 710
				Vec2(pTopNear.x, pTopNear.y), -- 710
				Color(224, 236, 248, glowA) -- 710
			} -- 710
		}) -- 710
	end -- 710
	local doorAlpha = 1 - self.reunionPixelReturn -- 715
	local doorBotY = 160 * (1 - closeFrac) -- 716
	if 160 - doorBotY > 2 and doorAlpha > 0.02 then -- 716
		scene:addBox({ -- 718
			x0 = thX - 122, -- 719
			x1 = thX - 2, -- 720
			y0 = doorBotY, -- 721
			y1 = 160, -- 722
			z0 = 4, -- 723
			z1 = 22, -- 724
			material = MING_MATERIALS.mingTimberDark, -- 725
			bucket = LP_BUCKET.MIDGROUND, -- 726
			opacity = doorAlpha, -- 727
			sortBias = 0.04, -- 728
			edgeWidth = 0.9 -- 729
		}) -- 729
		local bandYs = {doorBotY + 12, doorBotY + 42, doorBotY + 72} -- 732
		local bi = 0 -- 733
		do -- 733
			bi = 0 -- 734
			while bi < #bandYs do -- 734
				local byBand = bandYs[bi + 1] -- 735
				if byBand + 6 < 158 then -- 735
					scene:addBox({ -- 737
						x0 = thX - 120, -- 738
						x1 = thX - 4, -- 739
						y0 = byBand, -- 740
						y1 = byBand + 6, -- 741
						z0 = 2, -- 742
						z1 = 10, -- 743
						material = MING_MATERIALS.mingIron, -- 744
						bucket = LP_BUCKET.MIDGROUND, -- 745
						opacity = doorAlpha, -- 746
						sortBias = 0.06, -- 747
						edgeWidth = 0.5 -- 748
					}) -- 748
				end -- 748
				bi = bi + 1 -- 734
			end -- 734
		end -- 734
		if closeFrac < 0.98 then -- 734
			local gapAlpha = (1 - closeFrac) * 0.65 * doorAlpha -- 754
			scene:addLightShaft( -- 755
				thX - 96, -- 756
				thX - 2, -- 756
				math.max(4, doorBotY), -- 756
				thX - 86, -- 757
				thX + 26, -- 757
				0, -- 757
				2, -- 758
				rgba(232, 188, 128, 255), -- 759
				gapAlpha * 0.42, -- 760
				gapAlpha * 0.14 -- 761
			) -- 761
		end -- 761
	end -- 761
	scene:addBox({ -- 767
		x0 = thX - 10, -- 768
		x1 = thX + 12, -- 769
		y0 = -12, -- 770
		y1 = 2, -- 771
		z0 = -14, -- 772
		z1 = 28, -- 773
		material = MING_MATERIALS.mingStoneStep, -- 774
		bucket = LP_BUCKET.WALK_DECK, -- 775
		sortBias = 0.02, -- 776
		highlightTopEdge = true, -- 777
		edgeWidth = 1.1 -- 778
	}) -- 778
	scene:addBox({ -- 782
		x0 = doorLeft - 140, -- 783
		x1 = thX + 132, -- 784
		y0 = -68, -- 785
		y1 = 0, -- 786
		z0 = -20, -- 787
		z1 = 42, -- 788
		material = MING_MATERIALS.mingBrickDark, -- 789
		bucket = LP_BUCKET.WALK_DECK, -- 790
		sortBias = 0, -- 791
		highlightTopEdge = true, -- 792
		edgeWidth = 0.85 -- 793
	}) -- 793
	local plankReveal = smoothstep(0.14, 0.52, m) -- 797
	if plankReveal > 0.01 then -- 797
		local overhangZ0 = -10 - 48 * plankReveal -- 799
		scene:addPlankDeck( -- 800
			thX + 58, -- 801
			thX + 340, -- 802
			0, -- 803
			overhangZ0, -- 804
			22, -- 805
			5, -- 806
			11, -- 807
			MING_MATERIALS.mingTimber, -- 808
			{ -- 809
				bucket = LP_BUCKET.WALK_DECK, -- 810
				opacity = plankReveal, -- 811
				sortBias = 0.25, -- 812
				withPosts = true, -- 813
				postBottomY = -78 -- 814
			} -- 814
		) -- 814
		scene:addBox({ -- 818
			x0 = thX + 244, -- 819
			x1 = thX + 260, -- 820
			y0 = 0, -- 821
			y1 = 38, -- 822
			z0 = -12, -- 823
			z1 = 6, -- 824
			material = MING_MATERIALS.mingTimberDark, -- 825
			bucket = LP_BUCKET.PROP, -- 826
			opacity = plankReveal, -- 827
			highlightTopEdge = true -- 828
		}) -- 828
		local clothBaseX = thX + 244 -- 831
		local clothTopY = 34 -- 832
		local windFreq = 2.8 + m * 1.4 -- 833
		local wave1 = math.sin(self.animTime * windFreq) * (4 + 6 * m) -- 834
		local wave2 = math.cos(self.animTime * windFreq * 0.85) * (3 + 4 * m) -- 835
		scene:addTri3D( -- 836
			vec3(clothBaseX, clothTopY, -12), -- 837
			vec3(clothBaseX + 7, clothTopY - 2, -12), -- 838
			vec3(clothBaseX - 8 + wave1, clothTopY - 24 + wave2 * 0.3, -15), -- 839
			MING_MATERIALS.mingRedCloth, -- 840
			{bucket = LP_BUCKET.PROP, opacity = plankReveal, sortBias = 0.35, edgeWidth = 0.9} -- 841
		) -- 841
		scene:addTri3D( -- 843
			vec3(clothBaseX + 7, clothTopY - 2, -12), -- 844
			vec3(clothBaseX - 8 + wave1, clothTopY - 24 + wave2 * 0.3, -15), -- 845
			vec3(clothBaseX + 2 + wave2, clothTopY - 20, -13), -- 846
			MING_MATERIALS.mingRedCloth, -- 847
			{bucket = LP_BUCKET.PROP, opacity = plankReveal * 0.9, sortBias = 0.36} -- 848
		) -- 848
	end -- 848
	scene:addContactShadow( -- 853
		p.player.x, -- 853
		p.player.y, -- 853
		16, -- 853
		12, -- 853
		0.62 + 0.28 * m, -- 853
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 853
	) -- 853
	scene:flush(fgDraw, fgGlow) -- 859
	local hidePartnerInside = self.reunionPixelReturn < 0.85 and closeFrac > 0.6 -- 863
	if hidePartnerInside then -- 863
		local wallRightX = cam:sx(thX - 1) -- 865
		local wallLeftX = cam:sx(doorLeft - 140) -- 866
		local wallW = math.max(2, wallRightX - wallLeftX) -- 867
		local wallTopY = cam:sy(164, p.player.depth) -- 868
		local wallBotY = cam:sy(0, p.player.depth) -- 869
		local wallH = math.max(2, wallTopY - wallBotY) -- 870
		local wallOp = clamp01((closeFrac - 0.6) / 0.28) * (1 - self.reunionPixelReturn) -- 871
		worldArt:tryPlace( -- 872
			"wall", -- 873
			"gate_closed_wall_mask", -- 874
			(wallLeftX + wallRightX) * 0.5, -- 875
			wallBotY, -- 876
			wallW, -- 877
			wallH, -- 878
			{ -- 879
				layer = 4102, -- 880
				color = Color(52, 56, 66, 255), -- 881
				opacity = wallOp -- 882
			} -- 882
		) -- 882
		local doorPanelL = cam:sx(thX - 112) -- 885
		local doorPanelR = cam:sx(thX - 1) -- 886
		worldArt:tryPlace( -- 887
			"prop_tower_door", -- 888
			"gate_closed_door_leaf", -- 889
			(doorPanelL + doorPanelR) * 0.5, -- 890
			wallBotY, -- 891
			math.max(2, doorPanelR - doorPanelL), -- 892
			wallH, -- 893
			{ -- 894
				layer = 4103, -- 895
				color = Color(86, 74, 62, 255), -- 896
				opacity = wallOp -- 897
			} -- 897
		) -- 897
	end -- 897
	local fgBeamAlpha = smoothstep(0.42, 0.95, m) * (1 - self.reunionPixelReturn) -- 903
	if fgBeamAlpha > 0.02 then -- 903
		scene:placeForegroundOccluder( -- 905
			worldArt, -- 906
			"cover_wood", -- 907
			"gate_fg_beam_right", -- 908
			thX + 266, -- 909
			thX + 356, -- 910
			-42, -- 910
			22, -- 912
			-68, -- 912
			{ -- 914
				color = Color(14, 17, 24, 255), -- 914
				opacity = 0.92 * fgBeamAlpha, -- 914
				layer = 5200 -- 914
			} -- 914
		) -- 914
	end -- 914
	return true -- 918
end -- 580
function GateTransitionPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 921
	return self.active and ctx.p.phase ~= "gate-walk" -- 928
end -- 921
function GateTransitionPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 931
	if not self.active then -- 931
		return -- 938
	end -- 938
	local p = ctx.p -- 940
	local view = ctx.view -- 941
	local cam = ctx.cam -- 942
	local tick = view.countElapsedTicks -- 943
	local cx = cam:sx(p.player.x) -- 944
	local by = cam:sy(p.player.y, p.player.depth) -- 945
	local H = cam:len(p.player.h) -- 946
	if p.phase == "gate-count" and tick >= 1080 and tick < view.countDurationTicks then -- 946
		local leanK = smoothstep(1080, 1130, tick) -- 950
		local doorSx = cam:sx(self.lockThresholdX) -- 951
		local headY = by + H * 0.8 -- 952
		local earPulse = 0.55 + 0.45 * math.sin(self.animTime * 2.2) -- 954
		fgGlow:drawArc( -- 955
			Vec2(doorSx + 4, headY), -- 956
			12 + (1 - earPulse) * 8, -- 957
			-38, -- 957
			38, -- 959
			1.1, -- 960
			Color( -- 961
				214, -- 961
				224, -- 961
				236, -- 961
				math.floor(78 * leanK * earPulse + 0.5) -- 961
			) -- 961
		) -- 961
		if tick >= 1260 then -- 961
			local breathCycle = self.animTime * 0.7 % 1 -- 965
			local bAlpha = math.sin(breathCycle * math.pi) * 0.48 -- 966
			local bx = cx - 10 - breathCycle * 18 -- 967
			local bY = headY - 4 + breathCycle * 6 -- 968
			fillRadialGlow( -- 969
				fgGlow, -- 970
				bx, -- 971
				bY, -- 972
				12 + breathCycle * 10, -- 973
				7 + breathCycle * 6, -- 974
				Color( -- 975
					220, -- 975
					232, -- 975
					244, -- 975
					math.floor(110 * bAlpha + 0.5) -- 975
				), -- 975
				Color(180, 204, 228, 0), -- 976
				12 -- 977
			) -- 977
		end -- 977
	end -- 977
	local isChildIdle = p.phase == "gate-count" and tick >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 983
	if isChildIdle then -- 983
		local pouchX = cx + cam:len(6) -- 987
		local pouchY = by + H * 0.48 -- 988
		local pulse = 0.72 + 0.28 * math.sin(self.animTime * 2.4) -- 989
		fillRadialGlow( -- 990
			fgGlow, -- 991
			pouchX, -- 992
			pouchY, -- 993
			18 * pulse, -- 994
			18 * pulse, -- 995
			Color( -- 996
				236, -- 996
				198, -- 996
				128, -- 996
				math.floor(64 * pulse + 0.5) -- 996
			), -- 996
			Color(220, 168, 86, 0), -- 997
			12 -- 998
		) -- 998
		fgGlow:drawDot( -- 1000
			Vec2(pouchX, pouchY), -- 1000
			2.1, -- 1000
			toColor( -- 1000
				PALETTE.amberCore, -- 1000
				math.floor(190 * pulse + 0.5) -- 1000
			) -- 1000
		) -- 1000
	end -- 1000
	local isSoldierWait = view.storyRoute == "soldier" and not view.gateReunion.completed and (p.phase == "gate-wait" or p.phase == "gate-count" and view.gateReunion.active) -- 1004
	if isSoldierWait then -- 1004
		local wallSx = cam:sx(self.lockThresholdX + 2) -- 1008
		local knockY = by + H * 0.56 -- 1009
		local ringCycle = self.animTime * 0.85 % 1 -- 1010
		local r1 = 8 + ringCycle * 34 -- 1011
		local a1 = (1 - ringCycle) * 0.72 -- 1012
		fgGlow:drawRing( -- 1013
			Vec2(wallSx, knockY), -- 1013
			math.max(1, r1 - 1.5), -- 1013
			r1, -- 1013
			Color(0, 0, 0, 0), -- 1013
			1.3, -- 1013
			toColor(PALETTE.amber, 210 * a1) -- 1013
		) -- 1013
		local handX = cx - cam:len(10) -- 1015
		local handY = by + H * 0.62 + math.sin(self.animTime * 2.6) * 2 -- 1016
		fgDraw:drawSegment( -- 1017
			Vec2( -- 1017
				cx - cam:len(3), -- 1017
				by + H * 0.56 -- 1017
			), -- 1017
			Vec2(handX, handY), -- 1017
			2.4, -- 1017
			Color(230, 206, 182, 220) -- 1017
		) -- 1017
		fgGlow:drawDot( -- 1018
			Vec2(handX, handY), -- 1018
			2.4, -- 1018
			toColor(PALETTE.amberCore, 165) -- 1018
		) -- 1018
	end -- 1018
end -- 931
function GateTransitionPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 1022
	if not self.active then -- 1022
		return false -- 1030
	end -- 1030
	local p = ctx.p -- 1032
	local view = ctx.view -- 1033
	local w = ctx.uiW -- 1034
	local h = ctx.uiH -- 1035
	if p.phase == "gate-walk" then -- 1035
		return false -- 1039
	end -- 1039
	local barH = math.floor(52 * (1 - self.reunionPixelReturn * 0.35) + 0.5) -- 1043
	uiDraw:drawRect( -- 1044
		Rect(0, h - barH, w, barH), -- 1044
		Color(8, 10, 16, 236) -- 1044
	) -- 1044
	uiDraw:drawRect( -- 1045
		Rect(0, 0, w, barH), -- 1045
		Color(8, 10, 16, 236) -- 1045
	) -- 1045
	uiInkDraw:drawSegment( -- 1046
		Vec2(0, h - barH), -- 1046
		Vec2(w, h - barH), -- 1046
		0.7, -- 1046
		toColor(PALETTE.silkDim, 68) -- 1046
	) -- 1046
	uiInkDraw:drawSegment( -- 1047
		Vec2(0, barH), -- 1047
		Vec2(w, barH), -- 1047
		0.7, -- 1047
		toColor(PALETTE.silkDim, 68) -- 1047
	) -- 1047
	local inCounting = p.phase == "gate-count" and view.countElapsedTicks < view.countDurationTicks -- 1050
	if inCounting and self.activeCountZh ~= "" then -- 1050
		local isBreathNum = view.countNumber == 19 -- 1052
		local fadeIn = smoothstep(0, 0.16, self.countCueAge) -- 1053
		local holdOut = 1 - smoothstep(isBreathNum and 2.1 or 1.15, isBreathNum and 2.85 or 1.65, self.countCueAge) -- 1054
		local numAlpha = clamp01(fadeIn * math.max(0.28, holdOut)) * (isBreathNum and 0.68 or 0.9) -- 1055
		local nx = w * 0.84 -- 1057
		local ny = h * 0.74 -- 1058
		drawMistCurve( -- 1059
			uiArt, -- 1059
			"gate_whisper_mist", -- 1059
			nx, -- 1059
			ny, -- 1059
			190, -- 1059
			44, -- 1059
			PALETTE.jadeMist, -- 1059
			0.18 * numAlpha, -- 1059
			0 -- 1059
		) -- 1059
		ctx.texts:put( -- 1060
			"banner", -- 1061
			self.activeCountZh, -- 1062
			nx, -- 1063
			ny + 6, -- 1064
			toColor(PALETTE.textBright), -- 1065
			0.5, -- 1066
			0.5, -- 1067
			"Center", -- 1068
			4, -- 1069
			numAlpha, -- 1070
			0.1 -- 1071
		) -- 1071
		local whisperText = view.countNumber == 18 and "「十八……」" or (view.countNumber == 19 and "「……十九……」" or ("「" .. self.activeCountZh) .. "……」") -- 1074
		drawSilkVeil( -- 1077
			uiDraw, -- 1077
			uiArt, -- 1077
			"gate_count_sub_veil", -- 1077
			w * 0.5, -- 1077
			26, -- 1077
			320, -- 1077
			36, -- 1077
			PALETTE.inkWash, -- 1077
			0.72 * numAlpha, -- 1077
			-1 -- 1077
		) -- 1077
		ctx.texts:put( -- 1078
			"sm", -- 1078
			whisperText, -- 1078
			w * 0.5, -- 1078
			26, -- 1078
			toColor(PALETTE.textMid), -- 1078
			0.5, -- 1078
			0.5, -- 1078
			"Center", -- 1078
			1.4, -- 1078
			numAlpha, -- 1078
			0.08 -- 1078
		) -- 1078
		return true -- 1079
	end -- 1079
	local isChildDone = p.phase == "gate-count" and view.countElapsedTicks >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 1083
	if isChildDone then -- 1083
		local lineAlpha = self.g04LineAge >= 0 and smoothstep(0, 0.25, self.g04LineAge) * (1 - smoothstep(3.8, 5.2, self.g04LineAge)) or 0.9 -- 1087
		if lineAlpha > 0.02 then -- 1087
			drawSilkVeil( -- 1091
				uiDraw, -- 1091
				uiArt, -- 1091
				"gate_g04_veil", -- 1091
				w * 0.5, -- 1091
				26, -- 1091
				460, -- 1091
				38, -- 1091
				PALETTE.inkWash, -- 1091
				0.78 * lineAlpha, -- 1091
				-1 -- 1091
			) -- 1091
			drawHairline( -- 1092
				uiInkDraw, -- 1092
				uiArt, -- 1092
				"gate_g04_line", -- 1092
				w * 0.5, -- 1092
				44, -- 1092
				300, -- 1092
				PALETTE.silkDim, -- 1092
				0.45 * lineAlpha, -- 1092
				true, -- 1092
				2 -- 1092
			) -- 1092
			ctx.texts:put( -- 1093
				"sm", -- 1094
				"「……二十了。我往北去了。」", -- 1095
				w * 0.5, -- 1096
				26, -- 1097
				toColor(PALETTE.textBright), -- 1098
				0.5, -- 1099
				0.5, -- 1100
				"Center", -- 1101
				1.2, -- 1102
				lineAlpha, -- 1103
				0.08 -- 1104
			) -- 1104
		end -- 1104
		if view.assistHintsEnabled then -- 1104
			ctx.texts:put( -- 1108
				"xs", -- 1109
				"松开后重新按方向键迈步", -- 1110
				w * 0.5, -- 1111
				h - 26, -- 1112
				toColor(PALETTE.textDim), -- 1113
				0.5, -- 1114
				0.5, -- 1115
				"Center", -- 1116
				1.2, -- 1117
				0.78, -- 1118
				0.08 -- 1119
			) -- 1119
		end -- 1119
		return true -- 1122
	end -- 1122
	return true -- 1126
end -- 1022
function ____exports.createGateTransitionPlugin() -- 1130
	return __TS__New(____exports.GateTransitionPlugin) -- 1131
end -- 1130
return ____exports -- 1130