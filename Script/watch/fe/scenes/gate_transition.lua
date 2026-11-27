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
local smoothstep = ____lowpoly.smoothstep -- 38
local vec3 = ____lowpoly.vec3 -- 39
local ____theme = require("Script.watch.fe.theme") -- 41
local PALETTE = ____theme.PALETTE -- 42
local fillRadialGlow = ____theme.fillRadialGlow -- 43
local fillVGradRect = ____theme.fillVGradRect -- 44
local lerpRGBA = ____theme.lerpRGBA -- 45
local rgba = ____theme.rgba -- 46
local toColor = ____theme.toColor -- 47
local COUNT_ZH = { -- 50
	"", -- 51
	"一", -- 51
	"二", -- 51
	"三", -- 51
	"四", -- 51
	"五", -- 51
	"六", -- 51
	"七", -- 51
	"八", -- 51
	"九", -- 51
	"十", -- 51
	"十一", -- 52
	"十二", -- 52
	"十三", -- 52
	"十四", -- 52
	"十五", -- 52
	"十六", -- 52
	"十七", -- 52
	"十八", -- 52
	"十九", -- 52
	"二十" -- 52
} -- 52
local GATE_AUDIO_ROOT = "assets/audio/gate/" -- 55
local GATE_ART = "assets/art/gate/" -- 56
local MOAT_MATTE = GATE_ART .. "moat-night.png" -- 57
local MOAT_FLAT = GATE_ART .. "moat-flat.png" -- 58
local GATE_FACADE = GATE_ART .. "brick-gate.png" -- 59
local GATE_FLAT = GATE_ART .. "brick-flat.png" -- 60
local STONE_APRON = GATE_ART .. "stone-apron.png" -- 61
local BOARD_EDGE = GATE_ART .. "board-edge.png" -- 62
local GATE_ANCHOR_FOOT_FRAC_X = 0.36 -- 63
local GATE_ANCHOR_FOOT_FRAC_Y = 0.27 -- 64
local GATE_ANCHOR_ZOOM = 1.15 -- 65
local GATE_FOCAL = 410 -- 66
local GATE_VP_FRAC_X = 0.56 -- 67
local GATE_VP_FRAC_Y = 0.54 -- 68
--- 与 cuff_shots.ts G05 抬镜回切像素风同步的时序常数（秒）
____exports.G05_PIXEL_RETURN_START = 0.25 -- 71
____exports.G05_PIXEL_RETURN_END = 1.15 -- 72
local function pad2(n) -- 94
	local v = math.max( -- 95
		0, -- 95
		math.floor(n) -- 95
	) -- 95
	return v < 10 and "0" .. tostring(v) or "" .. tostring(v) -- 96
end -- 94
local function countVoicePath(n) -- 99
	return ((GATE_AUDIO_ROOT .. "count_") .. pad2(n)) .. ".wav" -- 100
end -- 99
local function countVoiceVolume(n) -- 103
	if n == 19 then -- 103
		return 0.68 -- 105
	end -- 105
	if n == 18 then -- 105
		return 0.8 -- 108
	end -- 108
	if n == 20 then -- 108
		return 0.96 -- 111
	end -- 111
	return 0.84 -- 113
end -- 103
____exports.GateTransitionPlugin = __TS__Class() -- 116
local GateTransitionPlugin = ____exports.GateTransitionPlugin -- 116
GateTransitionPlugin.name = "GateTransitionPlugin" -- 116
function GateTransitionPlugin.prototype.____constructor(self) -- 116
	self.id = "fe-01-gate-transition" -- 117
	self.animTime = 0 -- 119
	self.active = false -- 120
	self.wasActive = false -- 121
	self.rawMorph = 0 -- 122
	self.effectiveMorph = 0 -- 123
	self.lastCountTick = -1 -- 124
	self.lastTriggeredCount = 0 -- 125
	self.countCueAge = 99 -- 126
	self.pendingBreath19 = false -- 127
	self.activeCountZh = "" -- 128
	self.g04LineTriggered = false -- 129
	self.reunionTimer = 0 -- 130
	self.reunionPixelReturn = 0 -- 131
	self.rehearsalKnockTimer = -1 -- 132
	self.rehearsalKnockStage = 0 -- 133
	self.lockFootX = 890 -- 134
	self.lockThresholdX = 848 -- 135
	self.subtitleCountShown = 0 -- 136
	self.gestureChangeCount = 0 -- 137
	self.lastGestureStage = 0 -- 138
	self.activeProjection = { -- 139
		morph = 0, -- 140
		focal = GATE_FOCAL, -- 141
		vpFracX = GATE_VP_FRAC_X, -- 142
		vpFracY = GATE_VP_FRAC_Y, -- 143
		vpOffsetX = 0, -- 144
		vpOffsetY = 0, -- 145
		baseDepth = 0 -- 146
	} -- 146
end -- 116
function GateTransitionPlugin.prototype.onBindPlay(self, _p, _view) -- 149
	self:resetState() -- 150
end -- 149
function GateTransitionPlugin.prototype.resetState(self) -- 153
	self.animTime = 0 -- 154
	self.active = false -- 155
	self.wasActive = false -- 156
	self.rawMorph = 0 -- 157
	self.effectiveMorph = 0 -- 158
	self.lastCountTick = -1 -- 159
	self.lastTriggeredCount = 0 -- 160
	self.countCueAge = 99 -- 161
	self.pendingBreath19 = false -- 162
	self.activeCountZh = "" -- 163
	self.g04LineTriggered = false -- 164
	self.reunionTimer = 0 -- 165
	self.reunionPixelReturn = 0 -- 166
	self.rehearsalKnockTimer = -1 -- 167
	self.rehearsalKnockStage = 0 -- 168
	self.subtitleCountShown = 0 -- 169
	self.gestureChangeCount = 0 -- 170
	self.lastGestureStage = 0 -- 171
end -- 153
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
	end -- 264
	if p.phase == "gate-wait" or p.phase == "gate-hand" or p.phase == "gate-walk" then -- 264
		self.rawMorph = 1 -- 270
	else -- 270
		self.rawMorph = clamp01(view.countElapsedTicks / math.max(1, view.countDurationTicks)) -- 272
	end -- 272
	local reunionDone = p.phase == "gate-hand" or view.storyRoute == "soldier" and view.gateReunion.completed -- 276
	if reunionDone then -- 276
		if not ctx.paused then -- 276
			self.reunionTimer = self.reunionTimer + ctx.worldDt -- 279
		end -- 279
		self.reunionPixelReturn = smoothstep(____exports.G05_PIXEL_RETURN_START, ____exports.G05_PIXEL_RETURN_END, self.reunionTimer) -- 281
		self.effectiveMorph = clamp01(1 - self.reunionPixelReturn) -- 282
	else -- 282
		self.reunionTimer = 0 -- 284
		self.reunionPixelReturn = 0 -- 285
		self.effectiveMorph = self.rawMorph -- 286
	end -- 286
	if p.phase == "gate-count" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 286
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
		end -- 332
	elseif jumped then -- 332
		self.pendingBreath19 = false -- 335
		self.lastTriggeredCount = countNum -- 336
		self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 337
		self.countCueAge = 0.35 -- 338
		self.lastGestureStage = stage -- 339
		if tick < view.countDurationTicks then -- 339
			self.g04LineTriggered = false -- 341
			self.rehearsalKnockTimer = -1 -- 342
			self.rehearsalKnockStage = 0 -- 343
		end -- 343
	elseif not ctx.paused and (p.phase == "gate-count" or p.phase == "gate-wait") then -- 343
		if countNum > self.lastTriggeredCount then -- 343
			self.lastTriggeredCount = countNum -- 347
			self.activeCountZh = COUNT_ZH[countNum + 1] or "" -- 348
			self.countCueAge = 0 -- 349
			self.pendingBreath19 = countNum == 19 -- 350
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
		end -- 359
		if stage ~= self.lastGestureStage then -- 359
			self.lastGestureStage = stage -- 363
			self.gestureChangeCount = self.gestureChangeCount + 1 -- 364
		end -- 364
	end -- 364
	if self.pendingBreath19 and self.countCueAge >= 0.78 and not ctx.paused and p.phase == "gate-count" then -- 364
		self.pendingBreath19 = false -- 369
		ctx.audio:playOnce( -- 370
			"gate:breath19:" .. tostring(ctx.events.roomSessionId), -- 371
			"voice", -- 372
			GATE_AUDIO_ROOT .. "breath_soft.wav", -- 373
			0.48, -- 374
			"gate:breath_19", -- 375
			tick -- 376
		) -- 376
	end -- 376
	local isChildWait = p.phase == "gate-count" and tick >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 381
	if isChildWait and not self.g04LineTriggered and not ctx.paused then -- 381
		self.g04LineTriggered = true -- 385
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
		local voiceDuck = p.phase == "gate-count" and countNum >= 18 and 0.32 + 0.68 * smoothstep(0.95, 1.55, self.countCueAge) or 1 -- 421
		local reunionCalm = reunionDone and 1 - self.reunionPixelReturn * 0.55 or 1 -- 423
		local windVol = (0.18 + 0.46 * self.effectiveMorph) * voiceDuck * reunionCalm -- 424
		local waterVol = (0.28 + 0.24 * self.effectiveMorph) * voiceDuck -- 425
		ctx.audio:playLoop( -- 426
			"gate_wind", -- 426
			"wind", -- 426
			GATE_AUDIO_ROOT .. "wind_loop.wav", -- 426
			windVol, -- 426
			tick -- 426
		) -- 426
		ctx.audio:playLoop( -- 427
			"gate_water", -- 427
			"water", -- 427
			GATE_AUDIO_ROOT .. "water_moat_loop.wav", -- 427
			waterVol, -- 427
			tick -- 427
		) -- 427
		if isChildWait then -- 427
			ctx.audio:playLoop( -- 429
				"gate_breath", -- 429
				"ambience", -- 429
				GATE_AUDIO_ROOT .. "breath_soft.wav", -- 429
				0.24, -- 429
				tick -- 429
			) -- 429
		else -- 429
			ctx.audio:stopLoop("gate_breath", 0.2) -- 431
		end -- 431
	end -- 431
	self.lastCountTick = tick -- 435
end -- 234
function GateTransitionPlugin.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 438
	if not self.active then -- 438
		return false -- 445
	end -- 445
	local cam = ctx.cam -- 447
	local w = cam.viewW -- 448
	local h = cam.viewH -- 449
	local m = self.effectiveMorph -- 450
	local skyLow = lerpRGBA( -- 452
		rgba(30, 22, 29, 255), -- 452
		rgba(29, 43, 59, 255), -- 452
		m -- 452
	) -- 452
	fillVGradRect( -- 453
		bgDraw, -- 453
		0, -- 453
		0, -- 453
		w, -- 453
		h, -- 453
		toColor(skyLow), -- 453
		Color(12, 18, 31, 255) -- 453
	) -- 453
	local width = math.max(w, h * 16 / 9) * 1.11 -- 455
	local height = width * 9 / 16 -- 456
	local span = math.max(1, ctx.p.room.maxX - ctx.p.room.minX) -- 457
	local progress = (cam.x - ctx.p.room.minX) / span - 0.5 -- 458
	local matteAlpha = smoothstep(0.14, 0.88, m) -- 459
	local drift = math.sin(self.animTime * 0.34) * h * 0.003 -- 460
	local mattePlaced = matteAlpha > 0.01 and backdropArt:tryPlacePath( -- 461
		MOAT_MATTE, -- 462
		"gate_moat_matte", -- 462
		w * (0.5 - progress * 0.046 + (1 - m) * 0.013) + drift, -- 463
		h * 0.5, -- 464
		width, -- 464
		height, -- 464
		{opacity = matteAlpha, layer = 1, smooth = true} -- 464
	) -- 464
	if not mattePlaced or matteAlpha < 0.999 then -- 464
		local flatX = w * (0.5 - progress * 0.046 + (1 - m) * 0.013) -- 467
		local outside = self.reunionPixelReturn <= 0.025 -- 468
		local flatPlaced = outside and backdropArt:tryPlacePath( -- 469
			MOAT_FLAT, -- 470
			"gate_moat_flat", -- 470
			flatX, -- 470
			h * 0.5, -- 470
			width, -- 470
			height, -- 470
			{layer = 0} -- 470
		) -- 470
		if not flatPlaced then -- 470
			backdropArt:tryPlace( -- 473
				"bgFar_gate", -- 474
				"gate_pixel_bg", -- 474
				flatX, -- 474
				(h - height) * 0.5, -- 474
				width, -- 474
				height, -- 474
				{layer = 0} -- 474
			) -- 474
		end -- 474
	end -- 474
	local moonReveal = smoothstep(0.18, 0.58, m) -- 480
	if moonReveal > 0.01 then -- 480
		local moonX = w * 0.745 -- 482
		local moonY = h * 0.827 -- 483
		local radius = h * 0.019 -- 484
		fillRadialGlow( -- 485
			bgGlow, -- 486
			moonX, -- 486
			moonY, -- 486
			radius * 5.2, -- 486
			radius * 4.4, -- 486
			Color( -- 487
				121, -- 487
				164, -- 487
				214, -- 487
				math.floor(50 * moonReveal + 0.5) -- 487
			), -- 487
			Color(82, 123, 171, 0), -- 488
			20 -- 488
		) -- 488
		fillRadialGlow( -- 490
			bgGlow, -- 491
			moonX, -- 491
			moonY, -- 491
			radius * 1.11, -- 491
			radius * 1.11, -- 491
			Color( -- 492
				232, -- 492
				239, -- 492
				243, -- 492
				math.floor(203 * moonReveal + 0.5) -- 492
			), -- 492
			Color(194, 213, 232, 0), -- 493
			24 -- 493
		) -- 493
		bgGlow:drawDot( -- 495
			Vec2(moonX, moonY), -- 495
			radius * 0.68, -- 495
			Color( -- 495
				187, -- 495
				202, -- 495
				218, -- 495
				math.floor(132 * moonReveal + 0.5) -- 495
			) -- 495
		) -- 495
	end -- 495
	local waterReveal = smoothstep(0.3, 0.86, m) -- 498
	do -- 498
		local i = 0 -- 499
		while i < 24 do -- 499
			if waterReveal <= 0.01 then -- 499
				break -- 501
			end -- 501
			local depth = i % 8 / 7 -- 503
			local flow = self.animTime * (0.62 + 0.32 * depth) + i * 1.91 -- 504
			local phase = math.sin(flow) -- 505
			local rippleX = w * (0.43 + i * 7 % 29 / 52) + h * 0.016 * phase -- 506
			local rippleY = h * (0.292 - depth * 0.216) + math.cos(flow * 0.7) * h * 0.003 -- 507
			local radius = h * (0.015 + 0.028 * depth) * (0.83 + 0.17 * phase) -- 508
			local alpha = math.floor(waterReveal * (8 + 17 * (0.5 + 0.5 * phase)) * (1 - 0.52 * depth) + 0.5) -- 509
			bgGlow:drawSegment( -- 510
				Vec2(rippleX - radius, rippleY), -- 511
				Vec2(rippleX + radius, rippleY), -- 511
				h * (0.00042 + 0.00035 * depth), -- 512
				Color(143, 182, 222, alpha) -- 512
			) -- 512
			i = i + 1 -- 499
		end -- 499
	end -- 499
	return true -- 515
end -- 438
function GateTransitionPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 518
	if not self.active then -- 518
		return false -- 525
	end -- 525
	local p = ctx.p -- 527
	local cam = ctx.cam -- 528
	local m = self.effectiveMorph -- 529
	local thX = self.lockThresholdX -- 530
	local doorLeft = thX - 108 -- 531
	local scene = __TS__New(LowpolyScene, cam, self.activeProjection, GATE_NIGHTMARE_LIGHT) -- 533
	local doorOpen = 1 - smoothstep(0, 360, ctx.view.countElapsedTicks) -- 535
	local facadeOpacity = 1 - smoothstep(0.4, 0.92, self.reunionPixelReturn) -- 536
	local stepReveal = smoothstep(0.18, 0.58, m) -- 539
	if stepReveal > 0.01 then -- 539
		local stairSpec = { -- 541
			x0 = thX + 108, -- 542
			x1 = thX + 292, -- 543
			y0 = -56, -- 544
			y1 = 2, -- 545
			steps = 5, -- 546
			label = "外壕石阶" -- 547
		} -- 547
		local k = 0 -- 550
		local n = stairSpec.steps + 1 -- 551
		local stepW = (stairSpec.x1 - stairSpec.x0) / n -- 552
		do -- 552
			k = 0 -- 553
			while k < n do -- 553
				local wy = stairSpec.y1 - (stairSpec.y1 - stairSpec.y0) * (k / math.max(1, n - 1)) -- 554
				local sx0 = stairSpec.x0 + k * stepW -- 555
				local sx1 = sx0 + stepW + 1 -- 556
				scene:addBox({ -- 557
					x0 = sx0, -- 558
					x1 = sx1, -- 559
					y0 = -78, -- 560
					y1 = wy, -- 561
					z0 = 26, -- 562
					z1 = 106, -- 563
					material = MING_MATERIALS.mingStoneStep, -- 564
					bucket = LP_BUCKET.MIDGROUND, -- 565
					opacity = stepReveal, -- 566
					sortBias = k * 0.02, -- 567
					highlightTopEdge = true, -- 568
					edgeWidth = 0.4 -- 569
				}) -- 569
				k = k + 1 -- 553
			end -- 553
		end -- 553
	end -- 553
	local wallReveal = smoothstep(0.025, 0.28, m) * facadeOpacity -- 575
	local frameLightStrength = smoothstep(0.065, 0.33, m) * (1 - 0.3 * smoothstep(0.53, 1, m)) -- 576
	local jambX = thX - 5 -- 577
	local jambDepth = 66 -- 578
	local wallHeight = 256 -- 579
	if wallReveal > 0.01 then -- 579
		scene:addBox({ -- 581
			x0 = doorLeft - 140, -- 582
			x1 = jambX, -- 582
			y0 = -8, -- 582
			y1 = wallHeight, -- 582
			z0 = 0, -- 583
			z1 = jambDepth, -- 583
			material = MING_MATERIALS.mingBrickDark, -- 583
			bucket = LP_BUCKET.MIDGROUND, -- 584
			opacity = wallReveal -- 584
		}) -- 584
		do -- 584
			local row = 0 -- 587
			while row < 16 do -- 587
				local y = row * 16 -- 588
				local courseOffset = row % 2 == 0 and 0 or 11 -- 589
				do -- 589
					local brick = 0 -- 590
					while brick < 4 do -- 590
						do -- 590
							local z0 = math.max(0, brick * 22 - courseOffset) + 0.45 -- 591
							local z1 = math.min(jambDepth, (brick + 1) * 22 - courseOffset) - 0.45 -- 592
							if z1 <= z0 then -- 592
								goto __continue68 -- 594
							end -- 594
							local light = frameLightStrength * (1 - (z0 + z1) / (2 * jambDepth)) -- 596
							local shade = 36 + (row * 5 + brick * 7) % 13 + 29 * light -- 597
							scene:addQuad3D( -- 598
								vec3(jambX, y + 0.5, z1), -- 599
								vec3(jambX, y + 0.5, z0), -- 599
								vec3(jambX, y + 15.1, z0), -- 600
								vec3(jambX, y + 15.1, z1), -- 600
								{base = rgba(shade * 0.87, shade * 1.04, shade * 1.2, 255)}, -- 601
								{ -- 602
									bucket = LP_BUCKET.MIDGROUND, -- 602
									opacity = wallReveal, -- 602
									unlit = true, -- 602
									bottomAo = 0.28, -- 602
									sortZOverride = jambDepth / 2, -- 602
									sortBias = 0.15 -- 602
								} -- 602
							) -- 602
						end -- 602
						::__continue68:: -- 602
						brick = brick + 1 -- 590
					end -- 590
				end -- 590
				row = row + 1 -- 587
			end -- 587
		end -- 587
	end -- 587
	if frameLightStrength > 0.02 then -- 587
		scene:addLightShaft( -- 609
			thX + 1, -- 610
			thX + 17, -- 610
			184, -- 610
			thX - 8, -- 610
			thX + 23, -- 610
			0, -- 610
			12, -- 610
			rgba(162, 187, 218, 255), -- 611
			0.095 * frameLightStrength, -- 611
			0.016 * frameLightStrength -- 611
		) -- 611
	end -- 611
	scene:addBox({ -- 616
		x0 = thX - 10, -- 617
		x1 = thX + 12, -- 618
		y0 = -12, -- 619
		y1 = 2, -- 620
		z0 = -14, -- 621
		z1 = 28, -- 622
		material = MING_MATERIALS.mingStoneStep, -- 623
		bucket = LP_BUCKET.WALK_DECK, -- 624
		sortBias = 0.02, -- 625
		highlightTopEdge = true, -- 626
		edgeWidth = 1.1 -- 627
	}) -- 627
	scene:addBox({ -- 631
		x0 = doorLeft - 140, -- 632
		x1 = thX + 132, -- 633
		y0 = -68, -- 634
		y1 = 0, -- 635
		z0 = -20, -- 636
		z1 = 42, -- 637
		material = MING_MATERIALS.mingBrickDark, -- 638
		bucket = LP_BUCKET.WALK_DECK, -- 639
		sortBias = 0, -- 640
		highlightTopEdge = true, -- 641
		edgeWidth = 0.85 -- 642
	}) -- 642
	local plankReveal = smoothstep(0.14, 0.52, m) -- 646
	local overhangZ0 = -10 - 48 * plankReveal -- 647
	if plankReveal > 0.01 then -- 647
		scene:addPlankDeck( -- 649
			thX + 58, -- 650
			thX + 340, -- 651
			0, -- 652
			overhangZ0, -- 653
			22, -- 654
			5, -- 655
			11, -- 656
			MING_MATERIALS.mingTimber, -- 657
			{ -- 658
				bucket = LP_BUCKET.WALK_DECK, -- 659
				opacity = plankReveal, -- 660
				sortBias = 0.25, -- 661
				withPosts = true, -- 662
				postBottomY = -78 -- 663
			} -- 663
		) -- 663
		self:drawDeckGrain( -- 666
			scene, -- 666
			thX + 58, -- 666
			thX + 340, -- 666
			overhangZ0, -- 666
			22, -- 666
			plankReveal -- 666
		) -- 666
		scene:addBox({ -- 668
			x0 = thX + 244, -- 669
			x1 = thX + 260, -- 670
			y0 = 0, -- 671
			y1 = 38, -- 672
			z0 = -12, -- 673
			z1 = 6, -- 674
			material = MING_MATERIALS.mingTimberDark, -- 675
			bucket = LP_BUCKET.PROP, -- 676
			opacity = plankReveal, -- 677
			highlightTopEdge = true -- 678
		}) -- 678
		local clothX = thX + 245 -- 681
		local clothY = 34 -- 682
		local wave = self.animTime * 3.5 -- 683
		do -- 683
			local fold = 0 -- 684
			while fold < 5 do -- 684
				local a = fold / 5 -- 685
				local b = (fold + 1) / 5 -- 686
				local xA = clothX + a * (-13 + 12 * math.sin(wave - a * 3.2)) -- 687
				local xB = clothX + b * (-13 + 12 * math.sin(wave - b * 3.2)) -- 688
				local yA = clothY - a * 24 -- 689
				local yB = clothY - b * 24 -- 690
				local clothLight = 0.88 + 0.16 * math.cos(wave - a * 3.2) -- 691
				scene:addQuad3D( -- 692
					vec3(xA, yA, -13), -- 693
					vec3(xA + 8 - 3 * a, yA - a, -13), -- 693
					vec3(xB + 8 - 3 * b, yB - 2 * b, -14), -- 694
					vec3(xB, yB, -14), -- 694
					{base = rgba(133 * clothLight, 48 * clothLight, 46 * clothLight, 255)}, -- 695
					{ -- 696
						bucket = LP_BUCKET.PROP, -- 696
						opacity = plankReveal, -- 696
						unlit = true, -- 696
						bottomAo = 0.1, -- 696
						sortBias = 0.35 -- 696
					} -- 696
				) -- 696
				fold = fold + 1 -- 684
			end -- 684
		end -- 684
	end -- 684
	scene:addContactShadow( -- 702
		p.player.x, -- 702
		p.player.y, -- 702
		16, -- 702
		12, -- 702
		0.62 + 0.28 * m, -- 702
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 702
	) -- 702
	scene:flush(fgDraw, fgGlow) -- 708
	local wallLeft = cam:sx(doorLeft - 140) -- 711
	local wallRight = cam:sx(jambX) -- 712
	local wallY = cam:sy(0, p.player.depth) -- 713
	local wallW = wallRight - wallLeft -- 714
	local wallH = cam:len(wallHeight) -- 715
	local wallX = (wallLeft + wallRight) * 0.5 -- 716
	local detail = smoothstep(0.09, 0.49, m) -- 717
	if facadeOpacity > 0.01 then -- 717
		if detail < 0.999 or facadeOpacity < 0.999 then -- 717
			local flatPlaced = worldArt:tryPlacePath( -- 720
				GATE_FLAT, -- 721
				"gate_facade_flat", -- 721
				wallX, -- 721
				wallY, -- 721
				wallW, -- 721
				wallH, -- 721
				{layer = 4101, opacity = facadeOpacity, anchorY = 0} -- 722
			) -- 722
			if not flatPlaced then -- 722
				worldArt:tryPlace( -- 725
					"wall", -- 725
					"gate_closed_wall", -- 725
					wallX, -- 725
					wallY, -- 725
					wallW, -- 725
					wallH, -- 725
					{ -- 726
						layer = 4101, -- 726
						color = Color(52, 56, 66, 255), -- 726
						opacity = facadeOpacity -- 726
					} -- 726
				) -- 726
				worldArt:tryPlace( -- 727
					"prop_tower_door", -- 727
					"gate_closed_door", -- 727
					cam:sx(thX - 56), -- 728
					wallY, -- 728
					cam:len(111), -- 728
					cam:len(164), -- 728
					{layer = 4102, opacity = facadeOpacity} -- 729
				) -- 729
			end -- 729
		end -- 729
		if detail > 0.01 then -- 729
			worldArt:tryPlacePath( -- 733
				GATE_FACADE, -- 734
				"gate_facade_detail", -- 734
				wallX, -- 734
				wallY, -- 734
				wallW, -- 734
				wallH, -- 734
				{layer = 4103, opacity = facadeOpacity * detail, anchorY = 0, smooth = true} -- 735
			) -- 735
		end -- 735
	end -- 735
	if doorOpen > 0.02 and facadeOpacity > 0.01 then -- 735
		local seamX = wallLeft + wallW * 0.654 -- 741
		local alpha = doorOpen * facadeOpacity -- 742
		fillRadialGlow( -- 743
			fgGlow, -- 744
			seamX, -- 744
			wallY + cam:len(2), -- 744
			cam:len(53), -- 744
			cam:len(7 + 9 * alpha), -- 744
			Color( -- 745
				161, -- 745
				102, -- 745
				51, -- 745
				math.floor(100 * alpha + 0.5) -- 745
			), -- 745
			Color(107, 62, 28, 0), -- 745
			18 -- 745
		) -- 745
		fgGlow:drawSegment( -- 747
			Vec2( -- 747
				seamX, -- 747
				wallY + cam:len(4) -- 747
			), -- 747
			Vec2(seamX, wallY + wallH * 0.64), -- 747
			cam:len(0.34 + 0.47 * alpha), -- 748
			Color( -- 748
				198, -- 748
				145, -- 748
				82, -- 748
				math.floor(62 * alpha + 0.5) -- 748
			) -- 748
		) -- 748
	end -- 748
	local apronFront = scene:project(thX + 132, 0, -20) -- 751
	local apronLeft = scene:project(doorLeft - 140, 0, -20) -- 752
	local apronBase = scene:project(doorLeft - 140, -68, -20) -- 753
	local plankLeft = scene:project(thX + 58, 0, overhangZ0) -- 754
	local apronRight = apronFront.x + (math.min(apronFront.x, plankLeft.x + 2) - apronFront.x) * plankReveal -- 755
	worldArt:tryPlacePath( -- 756
		STONE_APRON, -- 757
		"gate_stone_apron", -- 757
		(apronLeft.x + apronRight) * 0.5, -- 757
		apronBase.y, -- 757
		apronRight - apronLeft.x, -- 758
		apronLeft.y - apronBase.y, -- 758
		{layer = -2, anchorY = 0, opacity = 0.93, smooth = true} -- 759
	) -- 759
	if plankReveal > 0.01 then -- 759
		local edgeRight = scene:project(thX + 340, 0, overhangZ0) -- 763
		local edgeBottom = scene:project(thX + 58, -11, overhangZ0) -- 764
		worldArt:tryPlacePath( -- 765
			BOARD_EDGE, -- 766
			"gate_deck_wet_edge", -- 766
			(plankLeft.x + edgeRight.x) * 0.5, -- 766
			edgeBottom.y + 1, -- 766
			edgeRight.x - plankLeft.x, -- 767
			math.max(1, plankLeft.y - edgeBottom.y - 1), -- 767
			{layer = -1, anchorY = 0, opacity = plankReveal, smooth = true} -- 768
		) -- 768
	end -- 768
	return true -- 772
end -- 518
function GateTransitionPlugin.prototype.drawDeckGrain(self, scene, x0, x1, z0, z1, opacity) -- 775
	local gap = math.min(2.6, (z1 - z0) / 30) -- 779
	local boardDepth = (z1 - z0 - gap * 4) / 5 -- 780
	do -- 780
		local board = 0 -- 781
		while board < 5 do -- 781
			local edge = z0 + (boardDepth + gap) * board -- 782
			do -- 782
				local streak = 0 -- 783
				while streak < 13 do -- 783
					local seed = board * 17 + streak -- 784
					local start = x0 + 4 + seed * 73 % 237 -- 785
					local ____end = math.min(x1 - 2, start + 19 + seed * 19 % 58) -- 786
					local z = edge + boardDepth * (0.13 + 0.135 * (streak % 6)) -- 787
					local dark = streak % 3 == 0 -- 788
					local glint = math.floor(37 + 19 * math.sin(self.animTime * 0.87 + seed * 0.4) + 0.5) -- 789
					local grain = dark and rgba(20, 15, 17, 116) or rgba(135 + glint, 142 + glint, 151 + glint, glint) -- 790
					scene:addQuad3D( -- 791
						vec3(start, 0.18, z), -- 792
						vec3(____end, 0.18, z + 0.28), -- 792
						vec3(____end - 2, 0.18, z + 0.66), -- 793
						vec3(start + 3, 0.18, z + 0.73), -- 793
						{base = grain}, -- 794
						{ -- 795
							bucket = LP_BUCKET.WALK_DECK, -- 795
							opacity = opacity, -- 795
							unlit = true, -- 795
							sortZOverride = z0 - 0.8, -- 795
							sortBias = 0.4 -- 795
						} -- 795
					) -- 795
					streak = streak + 1 -- 783
				end -- 783
			end -- 783
			board = board + 1 -- 781
		end -- 781
	end -- 781
end -- 775
function GateTransitionPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 801
	return self.active and ctx.p.phase ~= "gate-walk" -- 808
end -- 801
function GateTransitionPlugin.prototype.drawActorsOverlay(self, _fgDraw, fgGlow, _worldArt, ctx) -- 811
	if not self.active then -- 811
		return -- 818
	end -- 818
	local ____ctx_2 = ctx -- 820
	local p = ____ctx_2.p -- 820
	local cam = ____ctx_2.cam -- 820
	local view = ____ctx_2.view -- 820
	local tick = view.countElapsedTicks -- 821
	local breathAge = self.countCueAge - 0.78 -- 824
	if p.phase == "gate-count" and tick >= 1260 and tick < view.countDurationTicks and breathAge >= 0 and breathAge < 1.2 then -- 824
		local drift = breathAge / 1.2 -- 827
		local unit = cam:len(1) -- 828
		local x = cam:sx(p.player.x - 15) - unit * 7 * drift -- 829
		local y = cam:sy(p.player.y, p.player.depth) + cam:len(p.player.h * 0.75 + 4 * drift) -- 830
		local alpha = smoothstep(0, 0.22, drift) * (1 - smoothstep(0.4, 1, drift)) -- 831
		fillRadialGlow( -- 832
			fgGlow, -- 833
			x, -- 833
			y, -- 833
			unit * (2 + 6 * drift), -- 833
			unit * (1 + 2.5 * drift), -- 833
			Color( -- 834
				200, -- 834
				222, -- 834
				244, -- 834
				math.floor(71 * alpha + 0.5) -- 834
			), -- 834
			Color(158, 184, 213, 0), -- 834
			16 -- 834
		) -- 834
	end -- 834
	if p.phase == "gate-wait" then -- 834
		local age = (p.phaseTick < 12 and p.phaseTick or p.phaseTick - 12) / 60 -- 840
		local opacity = 1 - smoothstep(0.06, 0.42, age) -- 841
		if opacity > 0.01 then -- 841
			local unit = cam:len(1) -- 843
			local x = cam:sx(self.lockThresholdX) -- 844
			local y = cam:sy(p.player.y, p.player.depth) + cam:len(p.player.h * 0.77) -- 845
			do -- 845
				local i = 0 -- 846
				while i < 7 do -- 846
					local px = x + unit * (i * 0.6 + (2 + i) * age) -- 847
					local py = y - unit * (i * 1.4 + (2 + i) * 6 * age * age) -- 848
					fgGlow:drawDot( -- 849
						Vec2(px, py), -- 849
						unit * (0.17 + i % 3 * 0.1), -- 849
						Color( -- 849
							181, -- 849
							202, -- 849
							220, -- 849
							math.floor(opacity * (90 - i * 7) + 0.5) -- 849
						) -- 849
					) -- 849
					i = i + 1 -- 846
				end -- 846
			end -- 846
		end -- 846
	end -- 846
end -- 811
function GateTransitionPlugin.prototype.drawCutsceneOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 855
	if not self.active or ctx.p.phase == "gate-walk" then -- 855
		return false -- 863
	end -- 863
	local ____ctx_3 = ctx -- 865
	local p = ____ctx_3.p -- 865
	local view = ____ctx_3.view -- 865
	local w = ctx.uiW -- 866
	local h = ctx.uiH -- 867
	local barH = math.floor(36 * (1 - self.reunionPixelReturn * 0.45) + 0.5) -- 868
	uiDraw:drawRect( -- 869
		Rect(0, h - barH, w, barH), -- 869
		Color(6, 9, 15, 255) -- 869
	) -- 869
	uiDraw:drawRect( -- 870
		Rect(0, 0, w, barH), -- 870
		Color(6, 9, 15, 255) -- 870
	) -- 870
	local isCounting = p.phase == "gate-count" and view.countElapsedTicks < view.countDurationTicks -- 872
	local isTwenty = self.lastTriggeredCount == 20 and self.countCueAge < 1.25 and (p.phase == "gate-count" or p.phase == "gate-wait") -- 873
	if (isCounting or isTwenty) and self.activeCountZh ~= "" then -- 873
		local relaxed = self.lastTriggeredCount == 19 -- 876
		local tail = relaxed and 2.35 or 0.92 -- 877
		local opacity = smoothstep(0, 0.12, self.countCueAge) * (1 - smoothstep(tail, tail + 0.3, self.countCueAge)) -- 878
		local text = isTwenty and "二十。" or (relaxed and "……十九……" or self.activeCountZh .. "……") -- 880
		ctx.texts:put( -- 881
			"sm", -- 881
			text, -- 881
			w * 0.5, -- 881
			barH * 0.51, -- 881
			toColor(PALETTE.textBright), -- 881
			0.5, -- 882
			0.5, -- 882
			"Center", -- 882
			0, -- 882
			opacity, -- 882
			0.04 -- 882
		) -- 882
	end -- 882
	if p.phase == "gate-count" and view.countElapsedTicks >= view.countDurationTicks and view.storyRoute ~= "soldier" and view.assistHintsEnabled then -- 882
		ctx.texts:put( -- 887
			"xs", -- 888
			adaptHintSentence("松开后重新按方向键迈步", ctx.input.inputMode, ctx.input.gamepadLayout), -- 888
			w * 0.5, -- 889
			h - barH * 0.5, -- 889
			toColor(PALETTE.textDim), -- 889
			0.5, -- 890
			0.5, -- 890
			"Center", -- 890
			1.2, -- 890
			0.78, -- 890
			0.08 -- 890
		) -- 890
	end -- 890
	return true -- 894
end -- 855
function ____exports.createGateTransitionPlugin() -- 898
	return __TS__New(____exports.GateTransitionPlugin) -- 899
end -- 898
return ____exports -- 898