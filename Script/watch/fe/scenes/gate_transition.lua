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
	local artW = math.max(w, h * 16 / 9) -- 464
	local artH = artW * 9 / 16 -- 465
	local artX = w * 0.5 -- 466
	local artY = (h - artH) * 0.5 -- 467
	local w0 = 1 - smoothstep(0.02, 0.14, m) -- 469
	if w0 > 0.01 then -- 469
		backdropArt:tryPlace( -- 471
			"bgFar_gate", -- 471
			"gate_px_stage0", -- 471
			artX, -- 471
			artY, -- 471
			artW, -- 471
			artH, -- 471
			{opacity = w0, layer = 0} -- 471
		) -- 471
	end -- 471
	local gateStages = { -- 473
		"comic_gate_f01", -- 474
		"comic_gate_f02", -- 474
		"comic_gate_f03", -- 474
		"comic_gate_f04", -- 474
		"comic_gate_f05", -- 474
		"comic_gate_f06", -- 475
		"comic_gate_f07", -- 475
		"comic_gate_f08", -- 475
		"comic_gate_f09", -- 475
		"comic_gate_f10" -- 475
	} -- 475
	local pos = clamp01((m - 0.04) / 0.94) * (#gateStages - 1) -- 477
	local idxA = math.min( -- 478
		#gateStages - 1, -- 478
		math.floor(pos) -- 478
	) -- 478
	local idxB = math.min(#gateStages - 1, idxA + 1) -- 479
	local frac = smoothstep(0, 1, pos - idxA) -- 480
	local comicVis = smoothstep(0.02, 0.14, m) -- 481
	if comicVis > 0.01 then -- 481
		if idxA == idxB then -- 481
			backdropArt:tryPlace( -- 484
				gateStages[idxA + 1], -- 484
				"gate_px_stageA", -- 484
				artX, -- 484
				artY, -- 484
				artW, -- 484
				artH, -- 484
				{opacity = comicVis, layer = 1} -- 484
			) -- 484
		else -- 484
			local opA = comicVis * (1 - frac) -- 486
			local opB = comicVis * frac -- 487
			if opA > 0.01 then -- 487
				backdropArt:tryPlace( -- 489
					gateStages[idxA + 1], -- 489
					"gate_px_stageA", -- 489
					artX, -- 489
					artY, -- 489
					artW, -- 489
					artH, -- 489
					{opacity = opA, layer = 1} -- 489
				) -- 489
			end -- 489
			if opB > 0.01 then -- 489
				backdropArt:tryPlace( -- 492
					gateStages[idxB + 1], -- 492
					"gate_px_stageB", -- 492
					artX, -- 492
					artY, -- 492
					artW, -- 492
					artH, -- 492
					{opacity = opB, layer = 2} -- 492
				) -- 492
			end -- 492
		end -- 492
	end -- 492
	local beaconVis = smoothstep(0.55, 0.88, m) -- 498
	if beaconVis > 0.02 then -- 498
		local pulse = 0.82 + 0.18 * math.sin(self.animTime * 2.1) -- 500
		fillRadialGlow( -- 501
			bgGlow, -- 502
			w * 0.86, -- 503
			h * 0.64, -- 504
			26 * beaconVis * pulse, -- 505
			26 * beaconVis * pulse, -- 506
			Color( -- 507
				246, -- 507
				212, -- 507
				148, -- 507
				math.floor(78 * beaconVis * pulse + 0.5) -- 507
			), -- 507
			Color(232, 180, 96, 0), -- 508
			14 -- 509
		) -- 509
	end -- 509
	return true -- 513
end -- 444
function GateTransitionPlugin.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 516
	if not self.active then -- 516
		return false -- 523
	end -- 523
	local p = ctx.p -- 525
	local cam = ctx.cam -- 526
	local m = self.effectiveMorph -- 527
	local thX = self.lockThresholdX -- 528
	local doorLeft = thX - 108 -- 529
	local scene = __TS__New(LowpolyScene, cam, self.activeProjection, GATE_NIGHTMARE_LIGHT) -- 531
	local closeFrac = p.phase == "gate-count" and 0.44 + 0.56 * clamp01(ctx.view.countElapsedTicks / 360) or 1 -- 534
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
					edgeWidth = 0.9 -- 569
				}) -- 569
				k = k + 1 -- 553
			end -- 553
		end -- 553
	end -- 553
	local wallReveal = smoothstep(0.02, 0.22, m) -- 576
	local frameLightStrength = smoothstep(0.1, 0.34, m) * (1 - 0.35 * smoothstep(0.85, 1, m)) -- 577
	if wallReveal > 0.01 then -- 577
		scene:addBox({ -- 579
			x0 = doorLeft - 140, -- 580
			x1 = thX - 18, -- 581
			y0 = -60, -- 582
			y1 = 230, -- 583
			z0 = -12, -- 584
			z1 = 88, -- 585
			material = MING_MATERIALS.mingBrick, -- 586
			bucket = LP_BUCKET.MIDGROUND, -- 587
			opacity = wallReveal, -- 588
			highlightTopEdge = true, -- 589
			edgeWidth = 0.75 -- 590
		}) -- 590
		scene:addBox({ -- 593
			x0 = thX - 18, -- 594
			x1 = thX, -- 595
			y0 = 0, -- 596
			y1 = 162, -- 597
			z0 = -6, -- 598
			z1 = 72, -- 599
			material = MING_MATERIALS.mingStoneStep, -- 600
			bucket = LP_BUCKET.MIDGROUND, -- 601
			opacity = wallReveal, -- 602
			sortBias = 0.08, -- 603
			highlightTopEdge = true, -- 604
			edgeWidth = 0.9 -- 605
		}) -- 605
		scene:addBox({ -- 608
			x0 = doorLeft - 40, -- 609
			x1 = thX + 76, -- 610
			y0 = 160, -- 611
			y1 = 214, -- 612
			z0 = -14, -- 613
			z1 = 82, -- 614
			material = MING_MATERIALS.mingBrickDark, -- 615
			bucket = LP_BUCKET.MIDGROUND, -- 616
			opacity = wallReveal, -- 617
			sortBias = 0.12, -- 618
			highlightTopEdge = true, -- 619
			edgeWidth = 0.8 -- 620
		}) -- 620
	end -- 620
	if frameLightStrength > 0.02 then -- 620
		scene:addLightShaft( -- 626
			thX + 16, -- 627
			thX + 34, -- 627
			160, -- 627
			thX - 4, -- 628
			thX + 24, -- 628
			0, -- 628
			16, -- 629
			rgba(220, 234, 248, 255), -- 630
			0.24 * frameLightStrength, -- 631
			0.04 * frameLightStrength -- 632
		) -- 632
		local pBotNear = scene:project(thX, 0, -6) -- 635
		local pBotFar = scene:project(thX, 0, 72) -- 636
		local pTopFar = scene:project(thX, 160, 72) -- 637
		local pTopNear = scene:project(thX, 160, -6) -- 638
		local glowA = math.floor(140 * frameLightStrength + 0.5) -- 639
		fgGlow:drawVertices({ -- 640
			{ -- 641
				Vec2(pBotNear.x, pBotNear.y), -- 641
				Color(224, 236, 248, glowA) -- 641
			}, -- 641
			{ -- 642
				Vec2(pBotFar.x, pBotFar.y), -- 642
				Color( -- 642
					168, -- 642
					196, -- 642
					224, -- 642
					math.floor(glowA * 0.25 + 0.5) -- 642
				) -- 642
			}, -- 642
			{ -- 643
				Vec2(pTopFar.x, pTopFar.y), -- 643
				Color( -- 643
					168, -- 643
					196, -- 643
					224, -- 643
					math.floor(glowA * 0.25 + 0.5) -- 643
				) -- 643
			}, -- 643
			{ -- 644
				Vec2(pBotNear.x, pBotNear.y), -- 644
				Color(224, 236, 248, glowA) -- 644
			}, -- 644
			{ -- 645
				Vec2(pTopFar.x, pTopFar.y), -- 645
				Color( -- 645
					168, -- 645
					196, -- 645
					224, -- 645
					math.floor(glowA * 0.25 + 0.5) -- 645
				) -- 645
			}, -- 645
			{ -- 646
				Vec2(pTopNear.x, pTopNear.y), -- 646
				Color(224, 236, 248, glowA) -- 646
			} -- 646
		}) -- 646
	end -- 646
	local doorAlpha = 1 - self.reunionPixelReturn -- 651
	local doorBotY = 160 * (1 - closeFrac) -- 652
	if 160 - doorBotY > 2 and doorAlpha > 0.02 then -- 652
		scene:addBox({ -- 654
			x0 = thX - 122, -- 655
			x1 = thX - 2, -- 656
			y0 = doorBotY, -- 657
			y1 = 160, -- 658
			z0 = 4, -- 659
			z1 = 22, -- 660
			material = MING_MATERIALS.mingTimberDark, -- 661
			bucket = LP_BUCKET.MIDGROUND, -- 662
			opacity = doorAlpha, -- 663
			sortBias = 0.04, -- 664
			edgeWidth = 0.9 -- 665
		}) -- 665
		local bandYs = {doorBotY + 12, doorBotY + 42, doorBotY + 72} -- 668
		local bi = 0 -- 669
		do -- 669
			bi = 0 -- 670
			while bi < #bandYs do -- 670
				local byBand = bandYs[bi + 1] -- 671
				if byBand + 6 < 158 then -- 671
					scene:addBox({ -- 673
						x0 = thX - 120, -- 674
						x1 = thX - 4, -- 675
						y0 = byBand, -- 676
						y1 = byBand + 6, -- 677
						z0 = 2, -- 678
						z1 = 10, -- 679
						material = MING_MATERIALS.mingIron, -- 680
						bucket = LP_BUCKET.MIDGROUND, -- 681
						opacity = doorAlpha, -- 682
						sortBias = 0.06, -- 683
						edgeWidth = 0.5 -- 684
					}) -- 684
				end -- 684
				bi = bi + 1 -- 670
			end -- 670
		end -- 670
		if closeFrac < 0.98 then -- 670
			local gapAlpha = (1 - closeFrac) * 0.65 * doorAlpha -- 690
			scene:addLightShaft( -- 691
				thX - 96, -- 692
				thX - 2, -- 692
				math.max(4, doorBotY), -- 692
				thX - 86, -- 693
				thX + 26, -- 693
				0, -- 693
				2, -- 694
				rgba(232, 188, 128, 255), -- 695
				gapAlpha * 0.42, -- 696
				gapAlpha * 0.14 -- 697
			) -- 697
		end -- 697
	end -- 697
	scene:addBox({ -- 703
		x0 = thX - 10, -- 704
		x1 = thX + 12, -- 705
		y0 = -12, -- 706
		y1 = 2, -- 707
		z0 = -14, -- 708
		z1 = 28, -- 709
		material = MING_MATERIALS.mingStoneStep, -- 710
		bucket = LP_BUCKET.WALK_DECK, -- 711
		sortBias = 0.02, -- 712
		highlightTopEdge = true, -- 713
		edgeWidth = 1.1 -- 714
	}) -- 714
	scene:addBox({ -- 718
		x0 = doorLeft - 140, -- 719
		x1 = thX + 132, -- 720
		y0 = -68, -- 721
		y1 = 0, -- 722
		z0 = -20, -- 723
		z1 = 42, -- 724
		material = MING_MATERIALS.mingBrickDark, -- 725
		bucket = LP_BUCKET.WALK_DECK, -- 726
		sortBias = 0, -- 727
		highlightTopEdge = true, -- 728
		edgeWidth = 0.85 -- 729
	}) -- 729
	local plankReveal = smoothstep(0.14, 0.52, m) -- 733
	if plankReveal > 0.01 then -- 733
		local overhangZ0 = -10 - 48 * plankReveal -- 735
		scene:addPlankDeck( -- 736
			thX + 58, -- 737
			thX + 340, -- 738
			0, -- 739
			overhangZ0, -- 740
			22, -- 741
			5, -- 742
			11, -- 743
			MING_MATERIALS.mingTimber, -- 744
			{ -- 745
				bucket = LP_BUCKET.WALK_DECK, -- 746
				opacity = plankReveal, -- 747
				sortBias = 0.25, -- 748
				withPosts = true, -- 749
				postBottomY = -78 -- 750
			} -- 750
		) -- 750
		scene:addBox({ -- 754
			x0 = thX + 244, -- 755
			x1 = thX + 260, -- 756
			y0 = 0, -- 757
			y1 = 38, -- 758
			z0 = -12, -- 759
			z1 = 6, -- 760
			material = MING_MATERIALS.mingTimberDark, -- 761
			bucket = LP_BUCKET.PROP, -- 762
			opacity = plankReveal, -- 763
			highlightTopEdge = true -- 764
		}) -- 764
		local clothReveal = smoothstep(0.28, 0.55, m) -- 767
		if clothReveal > 0.02 then -- 767
			local clothX = cam:sx(thX + 244) -- 769
			local clothY = cam:sy(32, p.player.depth) -- 770
			worldArt:tryPlace( -- 771
				"fe_red_cloth", -- 771
				"gate_px_red_cloth", -- 771
				clothX, -- 771
				clothY, -- 771
				cam:len(30), -- 771
				cam:len(22), -- 771
				{ -- 771
					frame = math.floor(self.animTime * 4.5), -- 772
					opacity = clothReveal * 0.96, -- 773
					layer = 36 -- 774
				} -- 774
			) -- 774
		end -- 774
		scene:addCutout3D( -- 779
			"assets/art/diorama_cutouts.clip|north_tower_distant", -- 780
			thX + 365, -- 781
			18, -- 782
			250, -- 783
			74, -- 784
			95, -- 785
			{ -- 786
				bucket = LP_BUCKET.BACKDROP, -- 787
				opacity = 0.72 * plankReveal, -- 788
				color = rgba(146, 164, 186, 255), -- 789
				anchorX = 0.5, -- 790
				anchorY = 0, -- 791
				sortBias = 0.08 -- 792
			} -- 792
		) -- 792
		scene:addCutout3D( -- 795
			"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 796
			thX - 56, -- 797
			148, -- 798
			22, -- 799
			146, -- 800
			96, -- 801
			{ -- 802
				bucket = LP_BUCKET.MIDGROUND, -- 803
				opacity = 0.9, -- 804
				color = rgba(168, 184, 202, 255), -- 805
				anchorX = 0.5, -- 806
				anchorY = 0, -- 807
				sortBias = 0.12 -- 808
			} -- 808
		) -- 808
	end -- 808
	scene:addContactShadow( -- 814
		p.player.x, -- 814
		p.player.y, -- 814
		16, -- 814
		12, -- 814
		0.62 + 0.28 * m, -- 814
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 814
	) -- 814
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 820
	local hidePartnerInside = self.reunionPixelReturn < 0.85 and closeFrac > 0.6 -- 824
	if hidePartnerInside then -- 824
		local wallRightX = cam:sx(thX - 1) -- 826
		local wallLeftX = cam:sx(doorLeft - 140) -- 827
		local wallW = math.max(2, wallRightX - wallLeftX) -- 828
		local wallTopY = cam:sy(164, p.player.depth) -- 829
		local wallBotY = cam:sy(0, p.player.depth) -- 830
		local wallH = math.max(2, wallTopY - wallBotY) -- 831
		local wallOp = clamp01((closeFrac - 0.6) / 0.28) * (1 - self.reunionPixelReturn) -- 832
		worldArt:tryPlacePath( -- 833
			"assets/art/tex_diorama_ming.clip|ming_brick", -- 834
			"gate_closed_wall_mask", -- 835
			(wallLeftX + wallRightX) * 0.5, -- 836
			wallBotY, -- 837
			wallW, -- 838
			wallH, -- 839
			{ -- 840
				anchorX = 0.5, -- 841
				anchorY = 0, -- 842
				layer = 4102, -- 843
				color = Color(76, 84, 98, 255), -- 844
				opacity = wallOp, -- 845
				smooth = true -- 846
			} -- 846
		) -- 846
		local doorPanelL = cam:sx(thX - 112) -- 849
		local doorPanelR = cam:sx(thX - 1) -- 850
		worldArt:tryPlacePath( -- 851
			"assets/art/cutscene_story_parts.clip|tower_porch_door", -- 852
			"gate_closed_door_leaf", -- 853
			(doorPanelL + doorPanelR) * 0.5, -- 854
			wallBotY, -- 855
			math.max(2, doorPanelR - doorPanelL), -- 856
			wallH, -- 857
			{ -- 858
				anchorX = 0.5, -- 859
				anchorY = 0, -- 860
				layer = 4103, -- 861
				color = Color(156, 148, 140, 255), -- 862
				opacity = wallOp, -- 863
				smooth = true -- 864
			} -- 864
		) -- 864
	end -- 864
	local fgBeamAlpha = smoothstep(0.42, 0.95, m) * (1 - self.reunionPixelReturn) -- 870
	if fgBeamAlpha > 0.02 then -- 870
		local pRight = scene:project(thX + 318, 128, -54) -- 872
		worldArt:tryPlacePath( -- 873
			"assets/art/diorama_cutouts.clip|fg_pine_bough", -- 874
			"gate_fg_pine_right", -- 875
			pRight.x, -- 876
			pRight.y, -- 877
			cam:len(168), -- 878
			cam:len(108), -- 879
			{ -- 880
				anchorX = 0.5, -- 881
				anchorY = 0.5, -- 882
				facing = -1, -- 883
				color = Color(36, 48, 56, 255), -- 884
				opacity = 0.88 * fgBeamAlpha, -- 885
				smooth = true, -- 886
				layer = 5200 -- 887
			} -- 887
		) -- 887
	end -- 887
	return true -- 892
end -- 516
function GateTransitionPlugin.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, ctx) -- 895
	return self.active and ctx.p.phase ~= "gate-walk" -- 902
end -- 895
function GateTransitionPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 905
	if not self.active then -- 905
		return -- 912
	end -- 912
	local p = ctx.p -- 914
	local view = ctx.view -- 915
	local cam = ctx.cam -- 916
	local tick = view.countElapsedTicks -- 917
	local cx = cam:sx(p.player.x) -- 918
	local by = cam:sy(p.player.y, p.player.depth) -- 919
	local H = cam:len(p.player.h) -- 920
	if p.phase == "gate-count" and tick >= 1080 and tick < view.countDurationTicks then -- 920
		local leanK = smoothstep(1080, 1130, tick) -- 924
		local doorSx = cam:sx(self.lockThresholdX) -- 925
		local headY = by + H * 0.8 -- 926
		local earPulse = 0.55 + 0.45 * math.sin(self.animTime * 2.2) -- 928
		fgGlow:drawArc( -- 929
			Vec2(doorSx + 4, headY), -- 930
			12 + (1 - earPulse) * 8, -- 931
			-38, -- 931
			38, -- 933
			1.1, -- 934
			Color( -- 935
				214, -- 935
				224, -- 935
				236, -- 935
				math.floor(78 * leanK * earPulse + 0.5) -- 935
			) -- 935
		) -- 935
		if tick >= 1260 then -- 935
			local breathCycle = self.animTime * 0.7 % 1 -- 939
			local bAlpha = math.sin(breathCycle * math.pi) * 0.48 -- 940
			local bx = cx - 10 - breathCycle * 18 -- 941
			local bY = headY - 4 + breathCycle * 6 -- 942
			fillRadialGlow( -- 943
				fgGlow, -- 944
				bx, -- 945
				bY, -- 946
				12 + breathCycle * 10, -- 947
				7 + breathCycle * 6, -- 948
				Color( -- 949
					220, -- 949
					232, -- 949
					244, -- 949
					math.floor(110 * bAlpha + 0.5) -- 949
				), -- 949
				Color(180, 204, 228, 0), -- 950
				12 -- 951
			) -- 951
		end -- 951
	end -- 951
	local isChildIdle = p.phase == "gate-count" and tick >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 957
	if isChildIdle then -- 957
		local pouchX = cx + cam:len(6) -- 961
		local pouchY = by + H * 0.48 -- 962
		local pulse = 0.72 + 0.28 * math.sin(self.animTime * 2.4) -- 963
		fillRadialGlow( -- 964
			fgGlow, -- 965
			pouchX, -- 966
			pouchY, -- 967
			18 * pulse, -- 968
			18 * pulse, -- 969
			Color( -- 970
				236, -- 970
				198, -- 970
				128, -- 970
				math.floor(64 * pulse + 0.5) -- 970
			), -- 970
			Color(220, 168, 86, 0), -- 971
			12 -- 972
		) -- 972
		fgGlow:drawDot( -- 974
			Vec2(pouchX, pouchY), -- 974
			2.1, -- 974
			toColor( -- 974
				PALETTE.amberCore, -- 974
				math.floor(190 * pulse + 0.5) -- 974
			) -- 974
		) -- 974
	end -- 974
	local isSoldierWait = view.storyRoute == "soldier" and not view.gateReunion.completed and (p.phase == "gate-wait" or p.phase == "gate-count" and view.gateReunion.active) -- 978
	if isSoldierWait then -- 978
		local wallSx = cam:sx(self.lockThresholdX + 2) -- 982
		local knockY = by + H * 0.56 -- 983
		local ringCycle = self.animTime * 0.85 % 1 -- 984
		local r1 = 8 + ringCycle * 34 -- 985
		local a1 = (1 - ringCycle) * 0.72 -- 986
		fgGlow:drawRing( -- 987
			Vec2(wallSx, knockY), -- 987
			math.max(1, r1 - 1.5), -- 987
			r1, -- 987
			Color(0, 0, 0, 0), -- 987
			1.3, -- 987
			toColor(PALETTE.amber, 210 * a1) -- 987
		) -- 987
		local handX = cx - cam:len(10) -- 989
		local handY = by + H * 0.62 + math.sin(self.animTime * 2.6) * 2 -- 990
		fgDraw:drawSegment( -- 991
			Vec2( -- 991
				cx - cam:len(3), -- 991
				by + H * 0.56 -- 991
			), -- 991
			Vec2(handX, handY), -- 991
			2.4, -- 991
			Color(230, 206, 182, 220) -- 991
		) -- 991
		fgGlow:drawDot( -- 992
			Vec2(handX, handY), -- 992
			2.4, -- 992
			toColor(PALETTE.amberCore, 165) -- 992
		) -- 992
	end -- 992
end -- 905
function GateTransitionPlugin.prototype.drawCutsceneOverlay(self, uiDraw, uiInkDraw, uiArt, _uiGlow, ctx) -- 996
	if not self.active then -- 996
		return false -- 1004
	end -- 1004
	local p = ctx.p -- 1006
	local view = ctx.view -- 1007
	local w = ctx.uiW -- 1008
	local h = ctx.uiH -- 1009
	if p.phase == "gate-walk" then -- 1009
		return false -- 1013
	end -- 1013
	local barH = math.floor(52 * (1 - self.reunionPixelReturn * 0.35) + 0.5) -- 1017
	uiDraw:drawRect( -- 1018
		Rect(0, h - barH, w, barH), -- 1018
		Color(8, 10, 16, 236) -- 1018
	) -- 1018
	uiDraw:drawRect( -- 1019
		Rect(0, 0, w, barH), -- 1019
		Color(8, 10, 16, 236) -- 1019
	) -- 1019
	uiInkDraw:drawSegment( -- 1020
		Vec2(0, h - barH), -- 1020
		Vec2(w, h - barH), -- 1020
		0.7, -- 1020
		toColor(PALETTE.silkDim, 68) -- 1020
	) -- 1020
	uiInkDraw:drawSegment( -- 1021
		Vec2(0, barH), -- 1021
		Vec2(w, barH), -- 1021
		0.7, -- 1021
		toColor(PALETTE.silkDim, 68) -- 1021
	) -- 1021
	local inCounting = p.phase == "gate-count" and view.countElapsedTicks < view.countDurationTicks -- 1024
	if inCounting and self.activeCountZh ~= "" then -- 1024
		local isBreathNum = view.countNumber == 19 -- 1026
		local fadeIn = smoothstep(0, 0.16, self.countCueAge) -- 1027
		local holdOut = 1 - smoothstep(isBreathNum and 2.1 or 1.15, isBreathNum and 2.85 or 1.65, self.countCueAge) -- 1028
		local numAlpha = clamp01(fadeIn * math.max(0.28, holdOut)) * (isBreathNum and 0.68 or 0.9) -- 1029
		local nx = w * 0.84 -- 1031
		local ny = h * 0.74 -- 1032
		drawMistCurve( -- 1033
			uiArt, -- 1033
			"gate_whisper_mist", -- 1033
			nx, -- 1033
			ny, -- 1033
			190, -- 1033
			44, -- 1033
			PALETTE.jadeMist, -- 1033
			0.18 * numAlpha, -- 1033
			0 -- 1033
		) -- 1033
		ctx.texts:put( -- 1034
			"banner", -- 1035
			self.activeCountZh, -- 1036
			nx, -- 1037
			ny + 6, -- 1038
			toColor(PALETTE.textBright), -- 1039
			0.5, -- 1040
			0.5, -- 1041
			"Center", -- 1042
			4, -- 1043
			numAlpha, -- 1044
			0.1 -- 1045
		) -- 1045
		local whisperText = view.countNumber == 18 and "「十八……」" or (view.countNumber == 19 and "「……十九……」" or ("「" .. self.activeCountZh) .. "……」") -- 1048
		drawSilkVeil( -- 1051
			uiDraw, -- 1051
			uiArt, -- 1051
			"gate_count_sub_veil", -- 1051
			w * 0.5, -- 1051
			26, -- 1051
			320, -- 1051
			36, -- 1051
			PALETTE.inkWash, -- 1051
			0.72 * numAlpha, -- 1051
			-1 -- 1051
		) -- 1051
		ctx.texts:put( -- 1052
			"sm", -- 1052
			whisperText, -- 1052
			w * 0.5, -- 1052
			26, -- 1052
			toColor(PALETTE.textMid), -- 1052
			0.5, -- 1052
			0.5, -- 1052
			"Center", -- 1052
			1.4, -- 1052
			numAlpha, -- 1052
			0.08 -- 1052
		) -- 1052
		return true -- 1053
	end -- 1053
	local isChildDone = p.phase == "gate-count" and view.countElapsedTicks >= view.countDurationTicks and view.storyRoute ~= "soldier" -- 1057
	if isChildDone then -- 1057
		local lineAlpha = self.g04LineAge >= 0 and smoothstep(0, 0.25, self.g04LineAge) * (1 - smoothstep(3.8, 5.2, self.g04LineAge)) or 0.9 -- 1061
		if lineAlpha > 0.02 then -- 1061
			drawSilkVeil( -- 1065
				uiDraw, -- 1065
				uiArt, -- 1065
				"gate_g04_veil", -- 1065
				w * 0.5, -- 1065
				26, -- 1065
				460, -- 1065
				38, -- 1065
				PALETTE.inkWash, -- 1065
				0.78 * lineAlpha, -- 1065
				-1 -- 1065
			) -- 1065
			drawHairline( -- 1066
				uiInkDraw, -- 1066
				uiArt, -- 1066
				"gate_g04_line", -- 1066
				w * 0.5, -- 1066
				44, -- 1066
				300, -- 1066
				PALETTE.silkDim, -- 1066
				0.45 * lineAlpha, -- 1066
				true, -- 1066
				2 -- 1066
			) -- 1066
			ctx.texts:put( -- 1067
				"sm", -- 1068
				"「……二十了。我往北去了。」", -- 1069
				w * 0.5, -- 1070
				26, -- 1071
				toColor(PALETTE.textBright), -- 1072
				0.5, -- 1073
				0.5, -- 1074
				"Center", -- 1075
				1.2, -- 1076
				lineAlpha, -- 1077
				0.08 -- 1078
			) -- 1078
		end -- 1078
		if view.assistHintsEnabled then -- 1078
			ctx.texts:put( -- 1082
				"xs", -- 1083
				getActiveTarget():adaptHintSentence("松开后重新按方向键迈步", ctx.input.inputMode, ctx.input.gamepadLayout), -- 1084
				w * 0.5, -- 1085
				h - 26, -- 1086
				toColor(PALETTE.textDim), -- 1087
				0.5, -- 1088
				0.5, -- 1089
				"Center", -- 1090
				1.2, -- 1091
				0.78, -- 1092
				0.08 -- 1093
			) -- 1093
		end -- 1093
		return true -- 1096
	end -- 1096
	return true -- 1100
end -- 996
function ____exports.createGateTransitionPlugin() -- 1104
	return __TS__New(____exports.GateTransitionPlugin) -- 1105
end -- 1104
return ____exports -- 1104