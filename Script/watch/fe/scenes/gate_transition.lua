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
	local skyBot = lerpRGBA( -- 460
		rgba(36, 22, 26, 255), -- 460
		rgba(22, 34, 48, 255), -- 460
		m -- 460
	) -- 460
	fillVGradRect( -- 461
		bgDraw, -- 461
		0, -- 461
		0, -- 461
		w, -- 461
		h, -- 461
		toColor(skyBot), -- 461
		toColor(skyTop) -- 461
	) -- 461
	local artW = math.max(w, h * 16 / 9) -- 466
	local artH = artW * 9 / 16 -- 467
	local artX = w * 0.5 -- 468
	local artY = (h - artH) * 0.5 -- 469
	local w0 = 1 - smoothstep(0.05, 0.28, m) -- 471
	local w1 = smoothstep(0.04, 0.25, m) * (1 - smoothstep(0.32, 0.55, m)) -- 472
	local w2 = smoothstep(0.28, 0.5, m) * (1 - smoothstep(0.58, 0.8, m)) -- 473
	local w3 = smoothstep(0.54, 0.76, m) * (1 - smoothstep(0.82, 0.98, m)) -- 474
	local w4 = smoothstep(0.78, 0.96, m) -- 475
	if w0 > 0.01 then -- 475
		backdropArt:tryPlace( -- 478
			"bgFar_gate", -- 478
			"gate_px_stage0", -- 478
			artX, -- 478
			artY, -- 478
			artW, -- 478
			artH, -- 478
			{opacity = w0, layer = 0} -- 478
		) -- 478
	end -- 478
	if w1 > 0.01 then -- 478
		backdropArt:tryPlace( -- 481
			"slide_gate_01", -- 481
			"gate_px_stage1", -- 481
			artX, -- 481
			artY, -- 481
			artW, -- 481
			artH, -- 481
			{opacity = w1, layer = 1} -- 481
		) -- 481
	end -- 481
	if w2 > 0.01 then -- 481
		backdropArt:tryPlace( -- 484
			"slide_gate_02", -- 484
			"gate_px_stage2", -- 484
			artX, -- 484
			artY, -- 484
			artW, -- 484
			artH, -- 484
			{opacity = w2, layer = 2} -- 484
		) -- 484
	end -- 484
	if w3 > 0.01 then -- 484
		backdropArt:tryPlace( -- 487
			"slide_gate_03", -- 487
			"gate_px_stage3", -- 487
			artX, -- 487
			artY, -- 487
			artW, -- 487
			artH, -- 487
			{opacity = w3, layer = 3} -- 487
		) -- 487
	end -- 487
	if w4 > 0.01 then -- 487
		backdropArt:tryPlace( -- 490
			"slide_gate_04", -- 490
			"gate_px_stage4", -- 490
			artX, -- 490
			artY, -- 490
			artW, -- 490
			artH, -- 490
			{opacity = w4, layer = 4} -- 490
		) -- 490
	end -- 490
	local beaconVis = smoothstep(0.55, 0.88, m) -- 494
	if beaconVis > 0.02 then -- 494
		local pulse = 0.82 + 0.18 * math.sin(self.animTime * 2.1) -- 496
		fillRadialGlow( -- 497
			bgGlow, -- 498
			w * 0.86, -- 499
			h * 0.64, -- 500
			26 * beaconVis * pulse, -- 501
			26 * beaconVis * pulse, -- 502
			Color( -- 503
				246, -- 503
				212, -- 503
				148, -- 503
				math.floor(78 * beaconVis * pulse + 0.5) -- 503
			), -- 503
			Color(232, 180, 96, 0), -- 504
			14 -- 505
		) -- 505
	end -- 505
	return true -- 509
end -- 444
function GateTransitionPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 512
	if not self.active then -- 512
		return false -- 519
	end -- 519
	local p = ctx.p -- 521
	local cam = ctx.cam -- 522
	local m = self.effectiveMorph -- 523
	local thX = self.lockThresholdX -- 524
	local doorLeft = thX - 108 -- 525
	local scene = __TS__New(LowpolyScene, cam, self.activeProjection, GATE_NIGHTMARE_LIGHT) -- 527
	local closeFrac = p.phase == "gate-count" and 0.44 + 0.56 * clamp01(ctx.view.countElapsedTicks / 360) or 1 -- 530
	local stepReveal = smoothstep(0.18, 0.58, m) -- 535
	if stepReveal > 0.01 then -- 535
		local stairSpec = { -- 537
			x0 = thX + 108, -- 538
			x1 = thX + 292, -- 539
			y0 = -56, -- 540
			y1 = 2, -- 541
			steps = 5, -- 542
			label = "外壕石阶" -- 543
		} -- 543
		local k = 0 -- 546
		local n = stairSpec.steps + 1 -- 547
		local stepW = (stairSpec.x1 - stairSpec.x0) / n -- 548
		do -- 548
			k = 0 -- 549
			while k < n do -- 549
				local wy = stairSpec.y1 - (stairSpec.y1 - stairSpec.y0) * (k / math.max(1, n - 1)) -- 550
				local sx0 = stairSpec.x0 + k * stepW -- 551
				local sx1 = sx0 + stepW + 1 -- 552
				scene:addBox({ -- 553
					x0 = sx0, -- 554
					x1 = sx1, -- 555
					y0 = -78, -- 556
					y1 = wy, -- 557
					z0 = 26, -- 558
					z1 = 106, -- 559
					material = MING_MATERIALS.mingStoneStep, -- 560
					bucket = LP_BUCKET.MIDGROUND, -- 561
					opacity = stepReveal, -- 562
					sortBias = k * 0.02, -- 563
					highlightTopEdge = true, -- 564
					edgeWidth = 0.9 -- 565
				}) -- 565
				k = k + 1 -- 549
			end -- 549
		end -- 549
	end -- 549
	local wallReveal = smoothstep(0.02, 0.22, m) -- 572
	local frameLightStrength = smoothstep(0.1, 0.34, m) * (1 - 0.35 * smoothstep(0.85, 1, m)) -- 573
	if wallReveal > 0.01 then -- 573
		scene:addBox({ -- 575
			x0 = doorLeft - 140, -- 576
			x1 = thX - 18, -- 577
			y0 = -60, -- 578
			y1 = 230, -- 579
			z0 = -12, -- 580
			z1 = 88, -- 581
			material = MING_MATERIALS.mingBrick, -- 582
			bucket = LP_BUCKET.MIDGROUND, -- 583
			opacity = wallReveal, -- 584
			highlightTopEdge = true, -- 585
			edgeWidth = 0.75 -- 586
		}) -- 586
		scene:addBox({ -- 589
			x0 = thX - 18, -- 590
			x1 = thX, -- 591
			y0 = 0, -- 592
			y1 = 162, -- 593
			z0 = -6, -- 594
			z1 = 72, -- 595
			material = MING_MATERIALS.mingStoneStep, -- 596
			bucket = LP_BUCKET.MIDGROUND, -- 597
			opacity = wallReveal, -- 598
			sortBias = 0.08, -- 599
			highlightTopEdge = true, -- 600
			edgeWidth = 0.9 -- 601
		}) -- 601
		scene:addBox({ -- 604
			x0 = doorLeft - 40, -- 605
			x1 = thX + 76, -- 606
			y0 = 160, -- 607
			y1 = 214, -- 608
			z0 = -14, -- 609
			z1 = 82, -- 610
			material = MING_MATERIALS.mingBrickDark, -- 611
			bucket = LP_BUCKET.MIDGROUND, -- 612
			opacity = wallReveal, -- 613
			sortBias = 0.12, -- 614
			highlightTopEdge = true, -- 615
			edgeWidth = 0.8 -- 616
		}) -- 616
	end -- 616
	if frameLightStrength > 0.02 then -- 616
		scene:addLightShaft( -- 622
			thX + 16, -- 623
			thX + 34, -- 623
			160, -- 623
			thX - 4, -- 624
			thX + 24, -- 624
			0, -- 624
			16, -- 625
			rgba(220, 234, 248, 255), -- 626
			0.24 * frameLightStrength, -- 627
			0.04 * frameLightStrength -- 628
		) -- 628
		local pBotNear = scene:project(thX, 0, -6) -- 631
		local pBotFar = scene:project(thX, 0, 72) -- 632
		local pTopFar = scene:project(thX, 160, 72) -- 633
		local pTopNear = scene:project(thX, 160, -6) -- 634
		local glowA = math.floor(140 * frameLightStrength + 0.5) -- 635
		fgGlow:drawVertices({ -- 636
			{ -- 637
				Vec2(pBotNear.x, pBotNear.y), -- 637
				Color(224, 236, 248, glowA) -- 637
			}, -- 637
			{ -- 638
				Vec2(pBotFar.x, pBotFar.y), -- 638
				Color( -- 638
					168, -- 638
					196, -- 638
					224, -- 638
					math.floor(glowA * 0.25 + 0.5) -- 638
				) -- 638
			}, -- 638
			{ -- 639
				Vec2(pTopFar.x, pTopFar.y), -- 639
				Color( -- 639
					168, -- 639
					196, -- 639
					224, -- 639
					math.floor(glowA * 0.25 + 0.5) -- 639
				) -- 639
			}, -- 639
			{ -- 640
				Vec2(pBotNear.x, pBotNear.y), -- 640
				Color(224, 236, 248, glowA) -- 640
			}, -- 640
			{ -- 641
				Vec2(pTopFar.x, pTopFar.y), -- 641
				Color( -- 641
					168, -- 641
					196, -- 641
					224, -- 641
					math.floor(glowA * 0.25 + 0.5) -- 641
				) -- 641
			}, -- 641
			{ -- 642
				Vec2(pTopNear.x, pTopNear.y), -- 642
				Color(224, 236, 248, glowA) -- 642
			} -- 642
		}) -- 642
	end -- 642
	local doorAlpha = 1 - self.reunionPixelReturn -- 647
	local doorBotY = 160 * (1 - closeFrac) -- 648
	if 160 - doorBotY > 2 and doorAlpha > 0.02 then -- 648
		scene:addBox({ -- 650
			x0 = thX - 122, -- 651
			x1 = thX - 2, -- 652
			y0 = doorBotY, -- 653
			y1 = 160, -- 654
			z0 = 4, -- 655
			z1 = 22, -- 656
			material = MING_MATERIALS.mingTimberDark, -- 657
			bucket = LP_BUCKET.MIDGROUND, -- 658
			opacity = doorAlpha, -- 659
			sortBias = 0.04, -- 660
			edgeWidth = 0.9 -- 661
		}) -- 661
		local bandYs = {doorBotY + 12, doorBotY + 42, doorBotY + 72} -- 664
		local bi = 0 -- 665
		do -- 665
			bi = 0 -- 666
			while bi < #bandYs do -- 666
				local byBand = bandYs[bi + 1] -- 667
				if byBand + 6 < 158 then -- 667
					scene:addBox({ -- 669
						x0 = thX - 120, -- 670
						x1 = thX - 4, -- 671
						y0 = byBand, -- 672
						y1 = byBand + 6, -- 673
						z0 = 2, -- 674
						z1 = 10, -- 675
						material = MING_MATERIALS.mingIron, -- 676
						bucket = LP_BUCKET.MIDGROUND, -- 677
						opacity = doorAlpha, -- 678
						sortBias = 0.06, -- 679
						edgeWidth = 0.5 -- 680
					}) -- 680
				end -- 680
				bi = bi + 1 -- 666
			end -- 666
		end -- 666
		if closeFrac < 0.98 then -- 666
			local gapAlpha = (1 - closeFrac) * 0.65 * doorAlpha -- 686
			scene:addLightShaft( -- 687
				thX - 96, -- 688
				thX - 2, -- 688
				math.max(4, doorBotY), -- 688
				thX - 86, -- 689
				thX + 26, -- 689
				0, -- 689
				2, -- 690
				rgba(232, 188, 128, 255), -- 691
				gapAlpha * 0.42, -- 692
				gapAlpha * 0.14 -- 693
			) -- 693
		end -- 693
	end -- 693
	scene:addBox({ -- 699
		x0 = thX - 10, -- 700
		x1 = thX + 12, -- 701
		y0 = -12, -- 702
		y1 = 2, -- 703
		z0 = -14, -- 704
		z1 = 28, -- 705
		material = MING_MATERIALS.mingStoneStep, -- 706
		bucket = LP_BUCKET.WALK_DECK, -- 707
		sortBias = 0.02, -- 708
		highlightTopEdge = true, -- 709
		edgeWidth = 1.1 -- 710
	}) -- 710
	scene:addBox({ -- 714
		x0 = doorLeft - 140, -- 715
		x1 = thX + 132, -- 716
		y0 = -68, -- 717
		y1 = 0, -- 718
		z0 = -20, -- 719
		z1 = 42, -- 720
		material = MING_MATERIALS.mingBrickDark, -- 721
		bucket = LP_BUCKET.WALK_DECK, -- 722
		sortBias = 0, -- 723
		highlightTopEdge = true, -- 724
		edgeWidth = 0.85 -- 725
	}) -- 725
	local plankReveal = smoothstep(0.14, 0.52, m) -- 729
	if plankReveal > 0.01 then -- 729
		local overhangZ0 = -10 - 48 * plankReveal -- 731
		scene:addPlankDeck( -- 732
			thX + 58, -- 733
			thX + 340, -- 734
			0, -- 735
			overhangZ0, -- 736
			22, -- 737
			5, -- 738
			11, -- 739
			MING_MATERIALS.mingTimber, -- 740
			{ -- 741
				bucket = LP_BUCKET.WALK_DECK, -- 742
				opacity = plankReveal, -- 743
				sortBias = 0.25, -- 744
				withPosts = true, -- 745
				postBottomY = -78 -- 746
			} -- 746
		) -- 746
		scene:addBox({ -- 750
			x0 = thX + 244, -- 751
			x1 = thX + 260, -- 752
			y0 = 0, -- 753
			y1 = 38, -- 754
			z0 = -12, -- 755
			z1 = 6, -- 756
			material = MING_MATERIALS.mingTimberDark, -- 757
			bucket = LP_BUCKET.PROP, -- 758
			opacity = plankReveal, -- 759
			highlightTopEdge = true -- 760
		}) -- 760
		local clothReveal = smoothstep(0.28, 0.55, m) -- 763
		if clothReveal > 0.02 then -- 763
			local clothX = cam:sx(thX + 244) -- 765
			local clothY = cam:sy(32, p.player.depth) -- 766
			worldArt:tryPlace( -- 767
				"fe_red_cloth", -- 767
				"gate_px_red_cloth", -- 767
				clothX, -- 767
				clothY, -- 767
				cam:len(30), -- 767
				cam:len(22), -- 767
				{ -- 767
					frame = math.floor(self.animTime * 4.5), -- 768
					opacity = clothReveal * 0.96, -- 769
					layer = 36 -- 770
				} -- 770
			) -- 770
		end -- 770
		scene:addCutout3D( -- 775
			"assets/art/diorama_cutouts.clip|north_tower_distant", -- 776
			thX + 365, -- 777
			18, -- 778
			250, -- 779
			74, -- 780
			95, -- 781
			{ -- 782
				bucket = LP_BUCKET.BACKDROP, -- 783
				opacity = 0.72 * plankReveal, -- 784
				color = rgba(146, 164, 186, 255), -- 785
				anchorX = 0.5, -- 786
				anchorY = 0, -- 787
				sortBias = 0.08 -- 788
			} -- 788
		) -- 788
		scene:addCutout3D( -- 791
			"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 792
			thX - 56, -- 793
			148, -- 794
			22, -- 795
			146, -- 796
			96, -- 797
			{ -- 798
				bucket = LP_BUCKET.MIDGROUND, -- 799
				opacity = 0.9, -- 800
				color = rgba(168, 184, 202, 255), -- 801
				anchorX = 0.5, -- 802
				anchorY = 0, -- 803
				sortBias = 0.12 -- 804
			} -- 804
		) -- 804
	end -- 804
	scene:addContactShadow( -- 810
		p.player.x, -- 810
		p.player.y, -- 810
		16, -- 810
		12, -- 810
		0.62 + 0.28 * m, -- 810
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 810
	) -- 810
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 816
	local hidePartnerInside = self.reunionPixelReturn < 0.85 and closeFrac > 0.6 -- 820
	if hidePartnerInside then -- 820
		local wallRightX = cam:sx(thX - 1) -- 822
		local wallLeftX = cam:sx(doorLeft - 140) -- 823
		local wallW = math.max(2, wallRightX - wallLeftX) -- 824
		local wallTopY = cam:sy(164, p.player.depth) -- 825
		local wallBotY = cam:sy(0, p.player.depth) -- 826
		local wallH = math.max(2, wallTopY - wallBotY) -- 827
		local wallOp = clamp01((closeFrac - 0.6) / 0.28) * (1 - self.reunionPixelReturn) -- 828
		worldArt:tryPlacePath( -- 829
			"assets/art/tex_diorama_ming.clip|ming_brick", -- 830
			"gate_closed_wall_mask", -- 831
			(wallLeftX + wallRightX) * 0.5, -- 832
			wallBotY, -- 833
			wallW, -- 834
			wallH, -- 835
			{ -- 836
				anchorX = 0.5, -- 837
				anchorY = 0, -- 838
				layer = 4102, -- 839
				color = Color(76, 84, 98, 255), -- 840
				opacity = wallOp, -- 841
				smooth = true -- 842
			} -- 842
		) -- 842
		local doorPanelL = cam:sx(thX - 112) -- 845
		local doorPanelR = cam:sx(thX - 1) -- 846
		worldArt:tryPlacePath( -- 847
			"assets/art/cutscene_story_parts.clip|tower_porch_door", -- 848
			"gate_closed_door_leaf", -- 849
			(doorPanelL + doorPanelR) * 0.5, -- 850
			wallBotY, -- 851
			math.max(2, doorPanelR - doorPanelL), -- 852
			wallH, -- 853
			{ -- 854
				anchorX = 0.5, -- 855
				anchorY = 0, -- 856
				layer = 4103, -- 857
				color = Color(156, 148, 140, 255), -- 858
				opacity = wallOp, -- 859
				smooth = true -- 860
			} -- 860
		) -- 860
	end -- 860
	local fgBeamAlpha = smoothstep(0.42, 0.95, m) * (1 - self.reunionPixelReturn) -- 866
	if fgBeamAlpha > 0.02 then -- 866
		local pRight = scene:project(thX + 318, 128, -54) -- 868
		worldArt:tryPlacePath( -- 869
			"assets/art/diorama_cutouts.clip|fg_pine_bough", -- 870
			"gate_fg_pine_right", -- 871
			pRight.x, -- 872
			pRight.y, -- 873
			cam:len(168), -- 874
			cam:len(108), -- 875
			{ -- 876
				anchorX = 0.5, -- 877
				anchorY = 0.5, -- 878
				facing = -1, -- 879
				color = Color(36, 48, 56, 255), -- 880
				opacity = 0.88 * fgBeamAlpha, -- 881
				smooth = true, -- 882
				layer = 5200 -- 883
			} -- 883
		) -- 883
	end -- 883
	return true -- 888
end -- 512
function GateTransitionPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 891
	return self.active and ctx.p.phase ~= "gate-walk" -- 898
end -- 891
function GateTransitionPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 901
	if not self.active then -- 901
		return -- 908
	end -- 908
	local p = ctx.p -- 910
	local view = ctx.view -- 911
	local cam = ctx.cam -- 912
	local tick = view.countElapsedTicks -- 913
	local cx = cam:sx(p.player.x) -- 914
	local by = cam:sy(p.player.y, p.player.depth) -- 915
	local H = cam:len(p.player.h) -- 916
	if p.phase == "gate-count" and tick >= 1080 and tick < view.countDurationTicks then -- 916
		local leanK = smoothstep(1080, 1130, tick) -- 920
		local doorSx = cam:sx(self.lockThresholdX) -- 921
		local headY = by + H * 0.8 -- 922
		local earPulse = 0.55 + 0.45 * math.sin(self.animTime * 2.2) -- 924
		fgGlow:drawArc( -- 925
			Vec2(doorSx + 4, headY), -- 926
			12 + (1 - earPulse) * 8, -- 927
			-38, -- 927
			38, -- 929
			1.1, -- 930
			Color( -- 931
				214, -- 931
				224, -- 931
				236, -- 931
				math.floor(78 * leanK * earPulse + 0.5) -- 931
			) -- 931
		) -- 931
		if tick >= 1260 then -- 931
			local breathCycle = self.animTime * 0.7 % 1 -- 935
			local bAlpha = math.sin(breathCycle * math.pi) * 0.48 -- 936
			local bx = cx - 10 - breathCycle * 18 -- 937
			local bY = headY - 4 + breathCycle * 6 -- 938
			fillRadialGlow( -- 939
				fgGlow, -- 940
				bx, -- 941
				bY, -- 942
				12 + breathCycle * 10, -- 943
				7 + breathCycle * 6, -- 944
				Color( -- 945
					220, -- 945
					232, -- 945
					244, -- 945
					math.floor(110 * bAlpha + 0.5) -- 945
				), -- 945
				Color(180, 204, 228, 0), -- 946
				12 -- 947
			) -- 947
		end -- 947
	end -- 947
	local isChildIdle = p.phase == "gate-count" and tick >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 953
	if isChildIdle then -- 953
		local pouchX = cx + cam:len(6) -- 957
		local pouchY = by + H * 0.48 -- 958
		local pulse = 0.72 + 0.28 * math.sin(self.animTime * 2.4) -- 959
		fillRadialGlow( -- 960
			fgGlow, -- 961
			pouchX, -- 962
			pouchY, -- 963
			18 * pulse, -- 964
			18 * pulse, -- 965
			Color( -- 966
				236, -- 966
				198, -- 966
				128, -- 966
				math.floor(64 * pulse + 0.5) -- 966
			), -- 966
			Color(220, 168, 86, 0), -- 967
			12 -- 968
		) -- 968
		fgGlow:drawDot( -- 970
			Vec2(pouchX, pouchY), -- 970
			2.1, -- 970
			toColor( -- 970
				PALETTE.amberCore, -- 970
				math.floor(190 * pulse + 0.5) -- 970
			) -- 970
		) -- 970
	end -- 970
	local isSoldierWait = view.storyRoute == "soldier" and not view.gateReunion.completed and (p.phase == "gate-wait" or p.phase == "gate-count" and view.gateReunion.active) -- 974
	if isSoldierWait then -- 974
		local wallSx = cam:sx(self.lockThresholdX + 2) -- 978
		local knockY = by + H * 0.56 -- 979
		local ringCycle = self.animTime * 0.85 % 1 -- 980
		local r1 = 8 + ringCycle * 34 -- 981
		local a1 = (1 - ringCycle) * 0.72 -- 982
		fgGlow:drawRing( -- 983
			Vec2(wallSx, knockY), -- 983
			math.max(1, r1 - 1.5), -- 983
			r1, -- 983
			Color(0, 0, 0, 0), -- 983
			1.3, -- 983
			toColor(PALETTE.amber, 210 * a1) -- 983
		) -- 983
		local handX = cx - cam:len(10) -- 985
		local handY = by + H * 0.62 + math.sin(self.animTime * 2.6) * 2 -- 986
		fgDraw:drawSegment( -- 987
			Vec2( -- 987
				cx - cam:len(3), -- 987
				by + H * 0.56 -- 987
			), -- 987
			Vec2(handX, handY), -- 987
			2.4, -- 987
			Color(230, 206, 182, 220) -- 987
		) -- 987
		fgGlow:drawDot( -- 988
			Vec2(handX, handY), -- 988
			2.4, -- 988
			toColor(PALETTE.amberCore, 165) -- 988
		) -- 988
	end -- 988
end -- 901
function GateTransitionPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 992
	if not self.active then -- 992
		return false -- 1000
	end -- 1000
	local p = ctx.p -- 1002
	local view = ctx.view -- 1003
	local w = ctx.uiW -- 1004
	local h = ctx.uiH -- 1005
	if p.phase == "gate-walk" then -- 1005
		return false -- 1009
	end -- 1009
	local barH = math.floor(52 * (1 - self.reunionPixelReturn * 0.35) + 0.5) -- 1013
	uiDraw:drawRect( -- 1014
		Rect(0, h - barH, w, barH), -- 1014
		Color(8, 10, 16, 236) -- 1014
	) -- 1014
	uiDraw:drawRect( -- 1015
		Rect(0, 0, w, barH), -- 1015
		Color(8, 10, 16, 236) -- 1015
	) -- 1015
	uiInkDraw:drawSegment( -- 1016
		Vec2(0, h - barH), -- 1016
		Vec2(w, h - barH), -- 1016
		0.7, -- 1016
		toColor(PALETTE.silkDim, 68) -- 1016
	) -- 1016
	uiInkDraw:drawSegment( -- 1017
		Vec2(0, barH), -- 1017
		Vec2(w, barH), -- 1017
		0.7, -- 1017
		toColor(PALETTE.silkDim, 68) -- 1017
	) -- 1017
	local inCounting = p.phase == "gate-count" and view.countElapsedTicks < view.countDurationTicks -- 1020
	if inCounting and self.activeCountZh ~= "" then -- 1020
		local isBreathNum = view.countNumber == 19 -- 1022
		local fadeIn = smoothstep(0, 0.16, self.countCueAge) -- 1023
		local holdOut = 1 - smoothstep(isBreathNum and 2.1 or 1.15, isBreathNum and 2.85 or 1.65, self.countCueAge) -- 1024
		local numAlpha = clamp01(fadeIn * math.max(0.28, holdOut)) * (isBreathNum and 0.68 or 0.9) -- 1025
		local nx = w * 0.84 -- 1027
		local ny = h * 0.74 -- 1028
		drawMistCurve( -- 1029
			uiArt, -- 1029
			"gate_whisper_mist", -- 1029
			nx, -- 1029
			ny, -- 1029
			190, -- 1029
			44, -- 1029
			PALETTE.jadeMist, -- 1029
			0.18 * numAlpha, -- 1029
			0 -- 1029
		) -- 1029
		ctx.texts:put( -- 1030
			"banner", -- 1031
			self.activeCountZh, -- 1032
			nx, -- 1033
			ny + 6, -- 1034
			toColor(PALETTE.textBright), -- 1035
			0.5, -- 1036
			0.5, -- 1037
			"Center", -- 1038
			4, -- 1039
			numAlpha, -- 1040
			0.1 -- 1041
		) -- 1041
		local whisperText = view.countNumber == 18 and "「十八……」" or (view.countNumber == 19 and "「……十九……」" or ("「" .. self.activeCountZh) .. "……」") -- 1044
		drawSilkVeil( -- 1047
			uiDraw, -- 1047
			uiArt, -- 1047
			"gate_count_sub_veil", -- 1047
			w * 0.5, -- 1047
			26, -- 1047
			320, -- 1047
			36, -- 1047
			PALETTE.inkWash, -- 1047
			0.72 * numAlpha, -- 1047
			-1 -- 1047
		) -- 1047
		ctx.texts:put( -- 1048
			"sm", -- 1048
			whisperText, -- 1048
			w * 0.5, -- 1048
			26, -- 1048
			toColor(PALETTE.textMid), -- 1048
			0.5, -- 1048
			0.5, -- 1048
			"Center", -- 1048
			1.4, -- 1048
			numAlpha, -- 1048
			0.08 -- 1048
		) -- 1048
		return true -- 1049
	end -- 1049
	local isChildDone = p.phase == "gate-count" and view.countElapsedTicks >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 1053
	if isChildDone then -- 1053
		local lineAlpha = self.g04LineAge >= 0 and smoothstep(0, 0.25, self.g04LineAge) * (1 - smoothstep(3.8, 5.2, self.g04LineAge)) or 0.9 -- 1057
		if lineAlpha > 0.02 then -- 1057
			drawSilkVeil( -- 1061
				uiDraw, -- 1061
				uiArt, -- 1061
				"gate_g04_veil", -- 1061
				w * 0.5, -- 1061
				26, -- 1061
				460, -- 1061
				38, -- 1061
				PALETTE.inkWash, -- 1061
				0.78 * lineAlpha, -- 1061
				-1 -- 1061
			) -- 1061
			drawHairline( -- 1062
				uiInkDraw, -- 1062
				uiArt, -- 1062
				"gate_g04_line", -- 1062
				w * 0.5, -- 1062
				44, -- 1062
				300, -- 1062
				PALETTE.silkDim, -- 1062
				0.45 * lineAlpha, -- 1062
				true, -- 1062
				2 -- 1062
			) -- 1062
			ctx.texts:put( -- 1063
				"sm", -- 1064
				"「……二十了。我往北去了。」", -- 1065
				w * 0.5, -- 1066
				26, -- 1067
				toColor(PALETTE.textBright), -- 1068
				0.5, -- 1069
				0.5, -- 1070
				"Center", -- 1071
				1.2, -- 1072
				lineAlpha, -- 1073
				0.08 -- 1074
			) -- 1074
		end -- 1074
		if view.assistHintsEnabled then -- 1074
			ctx.texts:put( -- 1078
				"xs", -- 1079
				adaptHintSentence("松开后重新按方向键迈步", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1080
				w * 0.5, -- 1081
				h - 26, -- 1082
				toColor(PALETTE.textDim), -- 1083
				0.5, -- 1084
				0.5, -- 1085
				"Center", -- 1086
				1.2, -- 1087
				0.78, -- 1088
				0.08 -- 1089
			) -- 1089
		end -- 1089
		return true -- 1092
	end -- 1092
	return true -- 1096
end -- 992
function ____exports.createGateTransitionPlugin() -- 1100
	return __TS__New(____exports.GateTransitionPlugin) -- 1101
end -- 1100
return ____exports -- 1100