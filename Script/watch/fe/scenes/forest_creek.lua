-- [ts]: forest_creek.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 18
local Color = ____Dora.Color -- 18
local Content = ____Dora.Content -- 18
local Vec2 = ____Dora.Vec2 -- 18
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 23
local FOREST_CREEK_LIGHT = ____lowpoly.FOREST_CREEK_LIGHT -- 24
local LP_BUCKET = ____lowpoly.LP_BUCKET -- 25
local LowpolyScene = ____lowpoly.LowpolyScene -- 28
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 29
local clamp01 = ____lowpoly.clamp01 -- 30
local projectWorld3D = ____lowpoly.projectWorld3D -- 31
local smoothstep = ____lowpoly.smoothstep -- 32
local vec3 = ____lowpoly.vec3 -- 33
local ____theme = require("Script.watch.fe.theme") -- 35
local fillRadialGlow = ____theme.fillRadialGlow -- 36
local fillVGradRect = ____theme.fillVGradRect -- 37
local lerpRGBA = ____theme.lerpRGBA -- 38
local rgba = ____theme.rgba -- 39
local toColor = ____theme.toColor -- 40
local CHILD_AUDIO_ROOT = "assets/audio/child/" -- 43
--- 林径枯枝集群位置（段内 X）
local TWIG_OFFSETS = {235, 455, 865, 1115} -- 46
local MAT_MOSS_GROUND = { -- 71
	base = rgba(44, 58, 52, 255), -- 72
	edge = rgba(108, 134, 122, 145), -- 73
	minShade = 0.24, -- 74
	rimBoost = 0.2, -- 75
	bottomAo = 0.34 -- 76
} -- 76
local MAT_PINE_TRUNK = { -- 79
	base = rgba(46, 38, 34, 255), -- 80
	edge = rgba(98, 92, 86, 130), -- 81
	minShade = 0.2, -- 82
	rimBoost = 0.16, -- 83
	bottomAo = 0.4 -- 84
} -- 84
local MAT_PINE_NEEDLE = { -- 87
	base = rgba(24, 42, 38, 255), -- 88
	edge = rgba(78, 108, 98, 135), -- 89
	minShade = 0.22, -- 90
	rimBoost = 0.18, -- 91
	bottomAo = 0.36 -- 92
} -- 92
local MAT_ROOT_ARCH = { -- 95
	base = rgba(58, 46, 38, 255), -- 96
	edge = rgba(146, 134, 116, 170), -- 97
	minShade = 0.22, -- 98
	rimBoost = 0.24, -- 99
	bottomAo = 0.36 -- 100
} -- 100
local MAT_CANAL_STONE = { -- 103
	base = rgba(68, 78, 86, 255), -- 104
	edge = rgba(164, 186, 198, 190), -- 105
	minShade = 0.26, -- 106
	rimBoost = 0.28, -- 107
	bottomAo = 0.3 -- 108
} -- 108
local MAT_GRASS_BACK = { -- 111
	base = rgba(36, 56, 50, 255), -- 112
	edge = rgba(96, 128, 116, 135), -- 113
	minShade = 0.28, -- 114
	rimBoost = 0.16, -- 115
	bottomAo = 0.32 -- 116
} -- 116
local MAT_CREEK_WATER = { -- 119
	base = rgba(24, 38, 48, 255), -- 120
	edge = rgba(120, 152, 168, 110), -- 121
	minShade = 0.35, -- 122
	rimBoost = 0.22, -- 123
	bottomAo = 0.12 -- 124
} -- 124
local MAT_TWIG = { -- 127
	base = rgba(114, 92, 68, 255), -- 128
	edge = rgba(188, 166, 134, 190), -- 129
	minShade = 0.3, -- 130
	rimBoost = 0.26, -- 131
	bottomAo = 0.2 -- 132
} -- 132
local function drawUiTri(uiDraw, p0, p1, p2, c0, c1, c2, invScale) -- 135
	uiDraw:drawVertices({ -- 145
		{ -- 146
			Vec2(p0.x * invScale, p0.y * invScale), -- 146
			c0 -- 146
		}, -- 146
		{ -- 147
			Vec2(p1.x * invScale, p1.y * invScale), -- 147
			c1 -- 147
		}, -- 147
		{ -- 148
			Vec2(p2.x * invScale, p2.y * invScale), -- 148
			c2 -- 148
		} -- 148
	}) -- 148
end -- 135
local function drawUiQuad(uiDraw, p0, p1, p2, p3, cBot, cTop, invScale) -- 152
	local v0 = Vec2(p0.x * invScale, p0.y * invScale) -- 162
	local v1 = Vec2(p1.x * invScale, p1.y * invScale) -- 163
	local v2 = Vec2(p2.x * invScale, p2.y * invScale) -- 164
	local v3 = Vec2(p3.x * invScale, p3.y * invScale) -- 165
	uiDraw:drawVertices({{v0, cBot}, {v1, cBot}, {v2, cTop}}) -- 166
	uiDraw:drawVertices({{v0, cBot}, {v2, cTop}, {v3, cTop}}) -- 171
end -- 152
____exports.ForestCreekScene = __TS__Class() -- 178
local ForestCreekScene = ____exports.ForestCreekScene -- 178
ForestCreekScene.name = "ForestCreekScene" -- 178
function ForestCreekScene.prototype.____constructor(self) -- 178
	self.animTime = 0 -- 179
	self.active = false -- 180
	self.ripplePhase = 0 -- 181
	self.creekReveal = 0 -- 182
	self.creekWaterVol = 0 -- 183
	self.twigSnapCount = 0 -- 185
	self.twigTriggered = {} -- 186
	self.xiaomanListenTimer = 0 -- 187
	self.xiaomanListenDir = 1 -- 188
	self.prevDogState = "patrol" -- 190
	self.dogAlertCount = 0 -- 191
	self.dogStepCount = 0 -- 192
	self.dogStepAccum = 0 -- 193
	self.prevDogX = 0 -- 194
	self.splinters = {} -- 196
	self.rng = 9417 -- 197
	self.proj = { -- 199
		morph = 1, -- 200
		focal = 405, -- 201
		vpFracX = 0.54, -- 202
		vpFracY = 0.5, -- 203
		vpOffsetX = 0, -- 204
		vpOffsetY = 0, -- 205
		baseDepth = 0 -- 206
	} -- 206
end -- 178
function ForestCreekScene.prototype.reset(self) -- 209
	self.animTime = 0 -- 210
	self.active = false -- 211
	self.ripplePhase = 0 -- 212
	self.creekReveal = 0 -- 213
	self.creekWaterVol = 0 -- 214
	self.twigSnapCount = 0 -- 215
	self.twigTriggered = {} -- 216
	self.xiaomanListenTimer = 0 -- 217
	self.xiaomanListenDir = 1 -- 218
	self.prevDogState = "patrol" -- 219
	self.dogAlertCount = 0 -- 220
	self.dogStepCount = 0 -- 221
	self.dogStepAccum = 0 -- 222
	self.prevDogX = 0 -- 223
	self.splinters = {} -- 224
end -- 209
function ForestCreekScene.prototype.rand(self) -- 227
	self.rng = (self.rng * 1664525 + 1013904223) % 4294967296 -- 228
	return self.rng / 4294967296 -- 229
end -- 227
function ForestCreekScene.prototype.getProjection(self) -- 232
	return self.proj -- 233
end -- 232
function ForestCreekScene.prototype.getDebugState(self, p) -- 236
	local px = p ~= nil and p.player.x or 0 -- 237
	local ox = p ~= nil and p.ox or 0 -- 238
	local reflectionVisible = self.active and px >= ox + 1140 -- 239
	local trueLampVisible = self.active and self.creekReveal >= 0.35 -- 240
	return { -- 241
		active = self.active, -- 242
		twigSnapCount = self.twigSnapCount, -- 243
		xiaomanListenTimer = self.xiaomanListenTimer, -- 244
		dogAlertCount = self.dogAlertCount, -- 245
		dogStepCount = self.dogStepCount, -- 246
		creekReveal = self.creekReveal, -- 247
		ripplePhase = self.ripplePhase, -- 248
		trueLampVisible = trueLampVisible, -- 249
		reflectionVisible = reflectionVisible, -- 250
		creekWaterVol = self.creekWaterVol -- 251
	} -- 251
end -- 236
function ForestCreekScene.prototype.update(self, ctx) -- 255
	local p = ctx.p -- 256
	self.active = true -- 257
	local ox = p.ox -- 258
	ctx.cam:setAnchorLock(nil) -- 261
	self.creekReveal = smoothstep(ox + 1310, ox + 1435, p.player.x) -- 264
	if not ctx.paused and ctx.worldDt > 0 then -- 266
		local dt = ctx.worldDt -- 267
		self.animTime = self.animTime + dt -- 268
		self.ripplePhase = self.ripplePhase + dt * 2.4 -- 270
		if self.xiaomanListenTimer > 0 then -- 272
			self.xiaomanListenTimer = math.max(0, self.xiaomanListenTimer - dt) -- 273
		end -- 273
		local movingFast = not p.player.crouch and (math.abs(p.player.vx) > 10 or not p.player.onGround) -- 277
		local i = 0 -- 278
		do -- 278
			i = 0 -- 279
			while i < #TWIG_OFFSETS do -- 279
				local tx = ox + TWIG_OFFSETS[i + 1] -- 280
				local lastSnapAt = self.twigTriggered[i] or -99 -- 281
				if movingFast and math.abs(p.player.x - tx) <= 18 and p.player.y <= 8 and self.animTime - lastSnapAt > 2.4 then -- 282
					self.twigTriggered[i] = self.animTime -- 283
					self:triggerTwigSnap(ctx, tx, p.dogX >= p.player.x and 1 or -1) -- 284
				end -- 284
				i = i + 1 -- 279
			end -- 279
		end -- 279
		if p.room.story ~= nil and p.room.story.dog ~= nil then -- 289
			if p.dogState == "ear" and self.prevDogState ~= "ear" then -- 290
				self.dogAlertCount = self.dogAlertCount + 1 -- 291
				self:triggerTwigSnap(ctx, p.player.x, p.dogX >= p.player.x and 1 or -1) -- 292
				ctx.audio:playOnce( -- 293
					(("fe04:forest:dog_alert:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogAlertCount), -- 294
					"sfx", -- 295
					CHILD_AUDIO_ROOT .. "dog_alert.wav", -- 296
					0.82, -- 297
					"fe04:forest:dog_alert", -- 298
					p.ticks, -- 299
					-1, -- 300
					{pan = ctx.audio:panForWorldX(p.dogX)} -- 301
				) -- 301
			elseif p.dogState == "chase" and self.prevDogState ~= "chase" then -- 303
				self.dogAlertCount = self.dogAlertCount + 1 -- 304
				local chasePath = Content:exist("assets/audio/foley/dog_chase_bark.wav") and "assets/audio/foley/dog_chase_bark.wav" or CHILD_AUDIO_ROOT .. "dog_alert.wav" -- 305
				ctx.audio:playOnce( -- 308
					(("fe04:forest:dog_chase:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogAlertCount), -- 309
					"sfx", -- 310
					chasePath, -- 311
					0.9, -- 312
					"fe04:forest:dog_chase", -- 313
					p.ticks, -- 314
					-1, -- 315
					{pan = ctx.audio:panForWorldX(p.dogX)} -- 316
				) -- 316
			end -- 316
			local dogDx = math.abs(p.dogX - self.prevDogX) -- 320
			if dogDx > 0.01 and (p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back") then -- 321
				self.dogStepAccum = self.dogStepAccum + dogDx -- 322
				local stepStride = p.dogState == "chase" and 28 or 42 -- 323
				if self.dogStepAccum >= stepStride then -- 324
					self.dogStepAccum = 0 -- 325
					local dist = math.abs(p.player.x - p.dogX) -- 326
					if dist < 420 then -- 327
						self.dogStepCount = self.dogStepCount + 1 -- 328
						local vol = 0.24 + 0.48 * clamp01(1 - dist / 420) -- 329
						ctx.audio:playOnce( -- 330
							(("fe04:forest:dog_step:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogStepCount), -- 331
							"sfx", -- 332
							CHILD_AUDIO_ROOT .. "dog_step.wav", -- 333
							vol, -- 334
							"fe04:forest:dog_step", -- 335
							p.ticks, -- 336
							-1, -- 337
							{pan = ctx.audio:panForWorldX(p.dogX)} -- 338
						) -- 338
					end -- 338
				end -- 338
			end -- 338
			self.prevDogX = p.dogX -- 343
			self.prevDogState = p.dogState -- 344
		end -- 344
		local w = 0 -- 348
		do -- 348
			i = 0 -- 349
			while i < #self.splinters do -- 349
				local sp = self.splinters[i + 1] -- 350
				sp.life = sp.life - dt -- 351
				if sp.life > 0 then -- 352
					sp.vy = sp.vy - 320 * dt -- 353
					sp.x = sp.x + sp.vx * dt -- 354
					sp.y = sp.y + sp.vy * dt -- 355
					if sp.y < 0 then -- 356
						sp.y = 0 -- 357
						sp.vy = 0 -- 358
						sp.vx = sp.vx * 0.4 -- 359
					end -- 359
					self.splinters[w + 1] = sp -- 361
					w = w + 1 -- 362
				end -- 362
				i = i + 1 -- 349
			end -- 349
		end -- 349
		__TS__ArraySetLength(self.splinters, w) -- 365
		local creekApproach = smoothstep(ox + 1140, ox + 1410, p.player.x) -- 368
		local windVol = 0.34 * (1 - creekApproach * 0.42) -- 369
		self.creekWaterVol = 0.02 + 0.54 * creekApproach -- 370
		ctx.audio:playLoop( -- 371
			"fe04_forest_wind", -- 371
			"wind", -- 371
			CHILD_AUDIO_ROOT .. "forest_wind_loop.wav", -- 371
			windVol, -- 371
			p.ticks -- 371
		) -- 371
		if creekApproach > 0.02 then -- 372
			ctx.audio:playLoop( -- 373
				"fe04_creek_water", -- 373
				"water", -- 373
				CHILD_AUDIO_ROOT .. "creek_loop.wav", -- 373
				self.creekWaterVol, -- 373
				p.ticks -- 373
			) -- 373
		else -- 373
			ctx.audio:stopLoop("fe04_creek_water", 0.25) -- 375
		end -- 375
	end -- 375
	self.proj = { -- 379
		morph = 1, -- 380
		focal = 405, -- 381
		vpFracX = 0.54, -- 382
		vpFracY = 0.5, -- 383
		vpOffsetX = math.sin(self.animTime * 0.55) * 1.8, -- 384
		vpOffsetY = math.cos(self.animTime * 0.72) * 1.2, -- 385
		baseDepth = 0 -- 386
	} -- 386
end -- 255
function ForestCreekScene.prototype.triggerTwigSnap(self, ctx, worldX, listenDir) -- 390
	self.twigSnapCount = self.twigSnapCount + 1 -- 391
	self.xiaomanListenTimer = 0.52 -- 392
	self.xiaomanListenDir = listenDir >= 0 and 1 or -1 -- 393
	ctx.audio:playOnce( -- 394
		(("fe04:forest:twig:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.twigSnapCount), -- 395
		"sfx", -- 396
		CHILD_AUDIO_ROOT .. "twig_snap.wav", -- 397
		0.84, -- 398
		"fe04:forest:twig_snap", -- 399
		ctx.p.ticks, -- 400
		-1, -- 401
		{pan = ctx.audio:panForWorldX(worldX)} -- 402
	) -- 402
	local i = 0 -- 404
	do -- 404
		i = 0 -- 405
		while i < 6 do -- 405
			local ang = (0.2 + self:rand() * 0.6) * math.pi -- 406
			local spd = 45 + self:rand() * 75 -- 407
			local ____self_splinters_0 = self.splinters -- 408
			____self_splinters_0[#____self_splinters_0 + 1] = { -- 408
				x = worldX + (self:rand() - 0.5) * 10, -- 409
				y = 2, -- 410
				vx = math.cos(ang) * spd * (self:rand() > 0.5 and 1 or -1), -- 411
				vy = math.sin(ang) * spd, -- 412
				len = 3.5 + self:rand() * 3.5, -- 413
				life = 0.38 + self:rand() * 0.22, -- 414
				maxLife = 0.6 -- 415
			} -- 415
			i = i + 1 -- 405
		end -- 405
	end -- 405
end -- 390
function ForestCreekScene.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 420
	local p = ctx.p -- 426
	local cam = ctx.cam -- 427
	local ox = p.ox -- 428
	local w = cam.viewW -- 429
	local h = cam.viewH -- 430
	local dawn = smoothstep(ox + 1120, ox + 1460, p.player.x) -- 434
	local span = math.max(1, p.room.maxX - p.room.minX) -- 435
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 436
	local artW = math.max(w, h * 16 / 9) * 1.24 -- 437
	local artH = artW * 9 / 16 -- 438
	local artY = math.min( -- 439
		0, -- 439
		math.max(h - artH, cam.groundScreenY - artH * 0.24) -- 439
	) -- 439
	local tintR = math.floor(138 + dawn * 58 + 0.5) -- 440
	local tintG = math.floor(158 + dawn * 46 + 0.5) -- 441
	local tintB = math.floor(176 + dawn * 38 + 0.5) -- 442
	local hasPainted = backdropArt:tryPlace( -- 443
		"bgFar_forest", -- 443
		"lp_bg_forest", -- 443
		w * (0.5 - progress * 0.08), -- 443
		artY, -- 443
		artW, -- 443
		artH, -- 443
		{ -- 443
			color = Color(tintR, tintG, tintB, 255), -- 444
			opacity = 0.9, -- 445
			layer = 0 -- 446
		} -- 446
	) -- 446
	local skyTop = lerpRGBA( -- 449
		rgba(8, 14, 18, 255), -- 449
		rgba(16, 26, 38, 255), -- 449
		dawn -- 449
	) -- 449
	local skyMid = lerpRGBA( -- 450
		rgba(16, 28, 32, 255), -- 450
		rgba(32, 46, 62, 255), -- 450
		dawn -- 450
	) -- 450
	local skyHor = lerpRGBA( -- 451
		rgba(28, 44, 48, 255), -- 451
		rgba(62, 78, 94, 255), -- 451
		dawn -- 451
	) -- 451
	local splitY = h * 0.46 -- 452
	fillVGradRect( -- 453
		bgDraw, -- 453
		0, -- 453
		splitY, -- 453
		w, -- 453
		h - splitY, -- 453
		toColor(skyMid), -- 453
		toColor(skyTop) -- 453
	) -- 453
	fillVGradRect( -- 454
		bgDraw, -- 454
		0, -- 454
		0, -- 454
		w, -- 454
		splitY, -- 454
		toColor(skyHor), -- 454
		toColor(skyMid) -- 454
	) -- 454
	if not hasPainted then -- 456
		local scene = __TS__New(LowpolyScene, cam, self.proj, FOREST_CREEK_LIGHT) -- 457
		scene:addDistantRidge( -- 458
			{ -- 459
				{x = ox - 180, y = 128}, -- 460
				{x = ox + 220, y = 186}, -- 461
				{x = ox + 620, y = 152}, -- 462
				{x = ox + 1040, y = 204}, -- 463
				{x = ox + 1420, y = 168}, -- 464
				{x = ox + 1780, y = 196} -- 465
			}, -- 465
			-40, -- 467
			460, -- 468
			MING_MATERIALS.distantHill, -- 469
			{bucket = LP_BUCKET.BACKDROP} -- 470
		) -- 470
		scene:flush(bgDraw, bgGlow) -- 472
	end -- 472
	local mistShift = (self.animTime * 10 + cam.x * 0.14) % (w + 460) - 230 -- 476
	backdropArt:tryPlace( -- 477
		"ink_mist_curve", -- 477
		"lp_forest_mist_a", -- 477
		mistShift, -- 477
		h * 0.34, -- 477
		620, -- 477
		124, -- 477
		{ -- 477
			color = Color(142, 174, 182, 255), -- 478
			opacity = 0.24, -- 479
			layer = 4 -- 480
		} -- 480
	) -- 480
	backdropArt:tryPlace( -- 482
		"ink_mist_curve", -- 482
		"lp_forest_mist_b", -- 482
		(mistShift + w * 0.5) % (w + 460) - 230, -- 482
		h * 0.48, -- 482
		520, -- 482
		96, -- 482
		{ -- 482
			color = Color(120, 152, 166, 255), -- 483
			opacity = 0.17, -- 484
			layer = 4, -- 485
			facing = -1 -- 486
		} -- 486
	) -- 486
	local towerX = ox + 1525 -- 490
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 491
	local lampPt = projectWorld3D( -- 492
		towerX - 4, -- 492
		146, -- 492
		330, -- 492
		cam, -- 492
		self.proj -- 492
	) -- 492
	if dawn > 0.05 then -- 493
		fillRadialGlow( -- 494
			bgGlow, -- 494
			lampPt.x, -- 494
			lampPt.y - 18, -- 494
			240, -- 494
			120, -- 494
			Color( -- 495
				226, -- 495
				186, -- 495
				134, -- 495
				math.floor(52 * dawn * lampPulse + 0.5) -- 495
			), -- 495
			Color(226, 186, 134, 0), -- 495
			16 -- 495
		) -- 495
	end -- 495
	fillRadialGlow( -- 498
		bgGlow, -- 499
		lampPt.x, -- 500
		lampPt.y, -- 501
		48 * lampPulse, -- 502
		48 * lampPulse, -- 503
		Color( -- 504
			248, -- 504
			212, -- 504
			138, -- 504
			math.floor(135 * lampPulse + 0.5) -- 504
		), -- 504
		Color(232, 176, 86, 0), -- 505
		16 -- 506
	) -- 506
	bgGlow:drawDot( -- 508
		Vec2(lampPt.x, lampPt.y), -- 508
		4, -- 508
		Color(255, 246, 218, 252) -- 508
	) -- 508
	return true -- 510
end -- 420
function ForestCreekScene.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 513
	local p = ctx.p -- 519
	local cam = ctx.cam -- 520
	local ox = p.ox -- 521
	local scene = __TS__New(LowpolyScene, cam, self.proj, FOREST_CREEK_LIGHT) -- 522
	scene:addBox({ -- 525
		x0 = ox - 40, -- 526
		x1 = ox + 1190, -- 527
		y0 = -52, -- 528
		y1 = 0, -- 529
		z0 = -26, -- 530
		z1 = 92, -- 531
		material = MAT_MOSS_GROUND, -- 532
		bucket = LP_BUCKET.MIDGROUND, -- 533
		highlightTopEdge = true, -- 534
		edgeWidth = 0.7 -- 535
	}) -- 535
	scene:addBox({ -- 538
		x0 = ox + 1180, -- 539
		x1 = ox + 1620, -- 540
		y0 = -14, -- 541
		y1 = 0, -- 542
		z0 = -10, -- 543
		z1 = 24, -- 544
		material = MING_MATERIALS.mingStoneStep, -- 545
		bucket = LP_BUCKET.WALK_DECK, -- 546
		highlightTopEdge = true, -- 547
		edgeWidth = 0.9 -- 548
	}) -- 548
	scene:addQuad3D( -- 551
		vec3(ox + 1170, -6, -44), -- 552
		vec3(ox + 1640, -6, -44), -- 553
		vec3(ox + 1640, -2, -10), -- 554
		vec3(ox + 1170, -2, -10), -- 555
		MAT_CREEK_WATER, -- 556
		{bucket = LP_BUCKET.WALK_DECK, sortBias = 0.08, edgeWidth = 0} -- 557
	) -- 557
	scene:addQuad3D( -- 559
		vec3(ox + 1170, -2, 24), -- 560
		vec3(ox + 1660, -2, 24), -- 561
		vec3(ox + 1660, 4, 196), -- 562
		vec3(ox + 1170, 4, 196), -- 563
		MAT_CREEK_WATER, -- 564
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.04, edgeWidth = 0} -- 565
	) -- 565
	local midTrunks = { -- 569
		150, -- 569
		445, -- 569
		655, -- 569
		920, -- 569
		1235 -- 569
	} -- 569
	local i = 0 -- 570
	do -- 570
		i = 0 -- 571
		while i < #midTrunks do -- 571
			local tx = ox + midTrunks[i + 1] -- 572
			local groundY = cam:sy(0) -- 573
			worldArt:tryPlace( -- 574
				"pine", -- 574
				"fe04_forest_mid_pine_" .. tostring(i), -- 574
				cam:sx(tx), -- 574
				groundY - cam:len(4), -- 574
				cam:len(164), -- 574
				cam:len(148), -- 574
				{ -- 574
					layer = -2, -- 575
					facing = i % 2 == 0 and 1 or -1, -- 576
					color = Color(118, 142, 148, 255), -- 577
					opacity = 0.78 -- 578
				} -- 578
			) -- 578
			i = i + 1 -- 571
		end -- 571
	end -- 571
	do -- 571
		i = 0 -- 583
		while i < #p.room.stairs do -- 583
			local st = p.room.stairs[i + 1] -- 584
			scene:addBox({ -- 585
				x0 = st.x0, -- 586
				x1 = st.x1, -- 587
				y0 = 0, -- 588
				y1 = st.y1, -- 589
				z0 = -14, -- 590
				z1 = 42, -- 591
				material = i == 1 and MAT_ROOT_ARCH or MING_MATERIALS.mingStoneStep, -- 592
				bucket = LP_BUCKET.WALK_DECK, -- 593
				highlightTopEdge = true, -- 594
				edgeWidth = 0.6 -- 595
			}) -- 595
			i = i + 1 -- 583
		end -- 583
	end -- 583
	local hasRootArt = worldArt:tryPlace( -- 601
		"sh_root_burrow", -- 602
		"fe04_forest_root_burrow", -- 603
		cam:sx(ox + 346), -- 604
		cam:sy(0) - cam:len(4), -- 605
		cam:len(138), -- 606
		cam:len(96), -- 607
		{layer = 1, opacity = 0.96} -- 608
	) -- 608
	if not hasRootArt then -- 610
		scene:addTri3D( -- 611
			vec3(ox + 286, 0, 12), -- 612
			vec3(ox + 318, 12, 12), -- 613
			vec3(ox + 306, 76, 22), -- 614
			MAT_ROOT_ARCH, -- 615
			{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.7} -- 616
		) -- 616
		scene:addTri3D( -- 618
			vec3(ox + 372, 12, 12), -- 619
			vec3(ox + 412, 0, 12), -- 620
			vec3(ox + 382, 78, 22), -- 621
			MAT_ROOT_ARCH, -- 622
			{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.7} -- 623
		) -- 623
	end -- 623
	scene:addBox({ -- 627
		x0 = ox + 690, -- 628
		x1 = ox + 810, -- 629
		y0 = -10, -- 630
		y1 = 5, -- 631
		z0 = 26, -- 632
		z1 = 60, -- 633
		material = MAT_CANAL_STONE, -- 634
		bucket = LP_BUCKET.MIDGROUND, -- 635
		highlightTopEdge = true, -- 636
		edgeWidth = 0.6 -- 637
	}) -- 637
	scene:addQuad3D( -- 639
		vec3(ox + 695, -0.5, -6), -- 640
		vec3(ox + 1125, -0.5, -6), -- 641
		vec3(ox + 1125, 0.5, 20), -- 642
		vec3(ox + 695, 0.5, 20), -- 643
		{base = rgba(24, 42, 54, 185)}, -- 644
		{bucket = LP_BUCKET.WALK_DECK, unlit = true, sortBias = 0.14, edgeWidth = 0} -- 645
	) -- 645
	do -- 645
		i = 0 -- 649
		while i < #p.room.solids do -- 649
			local s = p.room.solids[i + 1] -- 650
			if s.passable == true then -- 651
				self:buildGrassCluster( -- 652
					scene, -- 652
					s.x, -- 652
					s.x + s.w, -- 652
					s.y, -- 652
					s.h, -- 652
					8 -- 652
				) -- 652
			elseif s.x >= ox + 1500 then -- 653
				worldArt:tryPlace( -- 655
					"pine", -- 655
					"fe04_forest_creek_edge_pine", -- 655
					cam:sx(s.x + s.w * 0.5), -- 655
					cam:sy(0) - cam:len(6), -- 655
					cam:len(165), -- 655
					cam:len(168), -- 655
					{ -- 655
						layer = 2, -- 656
						color = Color(76, 98, 104, 255), -- 657
						opacity = 0.92 -- 658
					} -- 658
				) -- 658
			end -- 658
			i = i + 1 -- 649
		end -- 649
	end -- 649
	do -- 649
		i = 0 -- 664
		while i < #TWIG_OFFSETS do -- 664
			local tx = ox + TWIG_OFFSETS[i + 1] -- 665
			scene:addTri3D( -- 666
				vec3(tx - 12, 0.8, -5), -- 667
				vec3(tx + 12, 0.8, -3), -- 668
				vec3(tx + 3, 6.2, 2), -- 669
				MAT_TWIG, -- 670
				{bucket = LP_BUCKET.PROP, sortBias = 0.15, edgeWidth = 1} -- 671
			) -- 671
			scene:addTri3D( -- 673
				vec3(tx - 8, 0.8, 3), -- 674
				vec3(tx + 14, 0.8, 5), -- 675
				vec3(tx - 2, 5.2, -2), -- 676
				MAT_TWIG, -- 677
				{bucket = LP_BUCKET.PROP, sortBias = 0.16, edgeWidth = 0.9} -- 678
			) -- 678
			i = i + 1 -- 664
		end -- 664
	end -- 664
	scene:addContactShadow( -- 683
		p.player.x, -- 683
		p.player.y, -- 683
		14, -- 683
		10, -- 683
		0.8, -- 683
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 683
	) -- 683
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 684
		scene:addContactShadow( -- 685
			p.dogX, -- 685
			0, -- 685
			18, -- 685
			11, -- 685
			0.82, -- 685
			{bucket = LP_BUCKET.PROP, sortBias = 0.44} -- 685
		) -- 685
	end -- 685
	scene:flush(fgDraw, fgGlow) -- 688
	self:drawCreekWaterReflection(fgDraw, fgGlow, p, cam) -- 691
	do -- 691
		i = 0 -- 694
		while i < #self.splinters do -- 694
			local sp = self.splinters[i + 1] -- 695
			local a = clamp01(sp.life / sp.maxLife) -- 696
			local sx = cam:sx(sp.x) -- 697
			local sy = cam:sy(sp.y) -- 698
			fgDraw:drawSegment( -- 699
				Vec2(sx - sp.len, sy - 1), -- 699
				Vec2(sx + sp.len, sy + 2), -- 699
				1.3, -- 699
				Color( -- 699
					204, -- 699
					182, -- 699
					146, -- 699
					math.floor(235 * a + 0.5) -- 699
				) -- 699
			) -- 699
			i = i + 1 -- 694
		end -- 694
	end -- 694
	return true -- 702
end -- 513
function ForestCreekScene.prototype.buildGrassCluster(self, scene, x0, x1, y0, h, z) -- 705
	local count = math.max( -- 706
		7, -- 706
		math.floor((x1 - x0) / 10) -- 706
	) -- 706
	local span = (x1 - x0) / count -- 707
	local k = 0 -- 708
	do -- 708
		k = 0 -- 709
		while k < count do -- 709
			local bx = x0 + (k + 0.5) * span -- 710
			local lean = (k * 29 % 11 - 5) * 1.3 -- 711
			local sway = math.sin(self.animTime * 1.9 + bx * 0.06) * 2.8 + lean -- 712
			local tipH = h * (0.58 + k * 37 % 10 * 0.048) -- 713
			scene:addTri3D( -- 714
				vec3(bx - span * 0.42, y0, z), -- 715
				vec3(bx + span * 0.42, y0, z), -- 716
				vec3(bx + sway, y0 + tipH, z - 2), -- 717
				MAT_GRASS_BACK, -- 718
				{bucket = LP_BUCKET.PROP, sortBias = 0.1 + k * 0.005, edgeWidth = 0.45} -- 719
			) -- 719
			k = k + 1 -- 709
		end -- 709
	end -- 709
end -- 705
function ForestCreekScene.prototype.drawCreekWaterReflection(self, fgDraw, fgGlow, p, cam) -- 724
	local ox = p.ox -- 730
	if cam:sx(ox + 1230) > cam.viewW + 120 then -- 731
		return -- 732
	end -- 732
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 734
	local reflCenterX = ox + 1438 -- 735
	local r = 0 -- 738
	do -- 738
		r = 0 -- 739
		while r < 14 do -- 739
			local z = r < 6 and -36 + r * 4.5 or 28 + (r - 6) * 20 -- 740
			local wx = ox + 1255 + r * 26 + math.sin(self.ripplePhase * 0.72 + r * 1.25) * 16 -- 741
			local spanW = 24 + r % 3 * 12 -- 742
			local pL = projectWorld3D( -- 743
				wx - spanW, -- 743
				-3, -- 743
				z, -- 743
				cam, -- 743
				self.proj -- 743
			) -- 743
			local pR = projectWorld3D( -- 744
				wx + spanW, -- 744
				-3, -- 744
				z, -- 744
				cam, -- 744
				self.proj -- 744
			) -- 744
			fgGlow:drawSegment( -- 745
				Vec2(pL.x, pL.y), -- 745
				Vec2(pR.x, pR.y), -- 745
				1.3, -- 745
				Color(148, 184, 208, 64) -- 745
			) -- 745
			r = r + 1 -- 739
		end -- 739
	end -- 739
	local bands = 16 -- 749
	do -- 749
		r = 0 -- 750
		while r < bands do -- 750
			local frac = r / (bands - 1) -- 751
			local z = -36 + frac * 62 -- 752
			local drift = math.sin(self.ripplePhase * (1.2 + frac * 0.45) + r * 1.15) * (5 + frac * 11) -- 753
			local halfW = (24 - frac * 11) * (0.72 + 0.28 * math.cos(self.ripplePhase * 1.65 + r)) -- 754
			local wy = -4.5 + frac * 3.2 -- 755
			local pL = projectWorld3D( -- 756
				reflCenterX + drift - halfW, -- 756
				wy, -- 756
				z, -- 756
				cam, -- 756
				self.proj -- 756
			) -- 756
			local pR = projectWorld3D( -- 757
				reflCenterX + drift + halfW, -- 757
				wy, -- 757
				z, -- 757
				cam, -- 757
				self.proj -- 757
			) -- 757
			local a = (0.36 + 0.56 * (1 - frac * 0.75)) * lampPulse -- 758
			fgDraw:drawSegment( -- 759
				Vec2(pL.x, pL.y), -- 759
				Vec2(pR.x, pR.y), -- 759
				1.9 - frac * 0.6, -- 759
				Color( -- 759
					242, -- 759
					198, -- 759
					118, -- 759
					math.floor(178 * a + 0.5) -- 759
				) -- 759
			) -- 759
			fgGlow:drawSegment( -- 760
				Vec2(pL.x, pL.y), -- 760
				Vec2(pR.x, pR.y), -- 760
				4.2 - frac * 1.4, -- 760
				Color( -- 760
					248, -- 760
					214, -- 760
					140, -- 760
					math.floor(128 * a + 0.5) -- 760
				) -- 760
			) -- 760
			r = r + 1 -- 750
		end -- 750
	end -- 750
	local poolP = projectWorld3D( -- 763
		reflCenterX + 14, -- 763
		0, -- 763
		48, -- 763
		cam, -- 763
		self.proj -- 763
	) -- 763
	fillRadialGlow( -- 764
		fgGlow, -- 765
		poolP.x, -- 766
		poolP.y, -- 767
		82 * lampPulse, -- 768
		24 * lampPulse, -- 769
		Color( -- 770
			246, -- 770
			206, -- 770
			128, -- 770
			math.floor(98 * lampPulse + 0.5) -- 770
		), -- 770
		Color(232, 174, 88, 0), -- 771
		18 -- 772
	) -- 772
end -- 724
function ForestCreekScene.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, _ctx) -- 777
	return true -- 783
end -- 777
function ForestCreekScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 787
	local p = ctx.p -- 793
	local cam = ctx.cam -- 794
	local px = cam:sx(p.player.x) -- 797
	local pTopY = cam:sy(p.player.y + p.player.h) -- 798
	local fDir = p.player.facing >= 0 and 1 or -1 -- 799
	local shY = pTopY - cam:len(16.5) -- 800
	fgDraw:drawSegment( -- 801
		Vec2( -- 802
			px - fDir * cam:len(7.5), -- 802
			shY - cam:len(4) -- 802
		), -- 802
		Vec2( -- 803
			px - fDir * cam:len(5.5), -- 803
			shY + cam:len(3.5) -- 803
		), -- 803
		1.3, -- 804
		Color(196, 212, 220, 145) -- 805
	) -- 805
	fgDraw:drawSegment( -- 807
		Vec2( -- 808
			px - fDir * cam:len(5.5), -- 808
			shY + cam:len(3.5) -- 808
		), -- 808
		Vec2( -- 809
			px + fDir * cam:len(3.5), -- 809
			shY + cam:len(5.2) -- 809
		), -- 809
		1.2, -- 810
		Color(206, 220, 228, 135) -- 811
	) -- 811
	if self.xiaomanListenTimer > 0 then -- 815
		local k = smoothstep(0, 0.12, self.xiaomanListenTimer) * clamp01(self.xiaomanListenTimer / 0.52) -- 816
		local earX = px + self.xiaomanListenDir * cam:len(8) -- 817
		local earY = pTopY - cam:len(10) -- 818
		local r1 = cam:len(6.5 + (1 - k) * 8) -- 819
		local r2 = cam:len(11.5 + (1 - k) * 11) -- 820
		local startAng = self.xiaomanListenDir > 0 and -34 or 146 -- 821
		local endAng = self.xiaomanListenDir > 0 and 34 or 214 -- 822
		fgDraw:drawArc( -- 823
			Vec2(earX, earY), -- 823
			r1, -- 823
			startAng, -- 823
			endAng, -- 823
			1.3, -- 823
			Color( -- 823
				224, -- 823
				218, -- 823
				198, -- 823
				math.floor(185 * k + 0.5) -- 823
			) -- 823
		) -- 823
		fgGlow:drawArc( -- 824
			Vec2(earX, earY), -- 824
			r2, -- 824
			startAng, -- 824
			endAng, -- 824
			1.1, -- 824
			Color( -- 824
				204, -- 824
				218, -- 824
				224, -- 824
				math.floor(135 * k + 0.5) -- 824
			) -- 824
		) -- 824
	end -- 824
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 828
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 829
		local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 830
		local headX = cam:sx(p.dogX + f * 11) -- 831
		local headY = cam:sy(23.5) -- 832
		local earH = cam:len(alert and 7.6 or 4.8) -- 833
		local earCol = alert and Color(224, 222, 212, 220) or Color(176, 194, 202, 170) -- 834
		fgDraw:drawPolygon( -- 835
			{ -- 835
				Vec2(headX - f * 3.4, headY), -- 836
				Vec2(headX - f * 0.8, headY + earH), -- 837
				Vec2(headX + f * 2.4, headY + 0.8) -- 838
			}, -- 838
			Color(38, 36, 34, 235), -- 839
			1.1, -- 839
			earCol -- 839
		) -- 839
		if alert then -- 840
			local waveR = cam:len(8 + self.animTime * 20 % 13) -- 841
			fgGlow:drawArc( -- 842
				Vec2(headX, headY + earH * 0.75), -- 842
				waveR, -- 842
				42, -- 842
				138, -- 842
				1.2, -- 842
				Color(226, 208, 174, 145) -- 842
			) -- 842
		end -- 842
	end -- 842
	if ctx.paused then -- 847
		local pX = cam.viewW * (0.78 + self.creekReveal * 0.24) -- 848
		worldArt:tryPlace( -- 849
			"pine", -- 849
			"fe04_pause_creek_branch", -- 849
			pX, -- 849
			cam.viewH * 0.42, -- 849
			cam.viewW * 0.48, -- 849
			cam.viewH * 0.62, -- 849
			{ -- 849
				color = Color(14, 20, 22, 255), -- 850
				opacity = 0.9 * (1 - self.creekReveal * 0.7), -- 851
				layer = 5300 -- 852
			} -- 852
		) -- 852
	end -- 852
end -- 787
function ForestCreekScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, uiArt, _uiGlow, ctx) -- 863
	local p = ctx.p -- 870
	local cam = ctx.cam -- 871
	local ox = p.ox -- 872
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 873
	local i = 0 -- 876
	do -- 876
		i = 0 -- 877
		while i < #p.room.solids do -- 877
			do -- 877
				local s = p.room.solids[i + 1] -- 878
				if s.passable ~= true then -- 879
					goto __continue65 -- 880
				end -- 880
				local blades = math.max( -- 882
					7, -- 882
					math.floor(s.w / 10) -- 882
				) -- 882
				local span = s.w / blades -- 883
				local k = 0 -- 884
				do -- 884
					k = 0 -- 885
					while k < blades do -- 885
						local bx = s.x + (k + 0.5) * span -- 886
						local lean = (k * 23 % 9 - 4) * 1.6 -- 887
						local sway = math.sin(self.animTime * 2.1 + bx * 0.06) * 2.6 + lean -- 888
						local tipH = math.min(18, s.h * (0.48 + k * 19 % 7 * 0.048)) -- 889
						local pL = projectWorld3D( -- 890
							bx - span * 0.36, -- 890
							s.y - 2, -- 890
							-18, -- 890
							cam, -- 890
							self.proj -- 890
						) -- 890
						local pR = projectWorld3D( -- 891
							bx + span * 0.36, -- 891
							s.y - 2, -- 891
							-18, -- 891
							cam, -- 891
							self.proj -- 891
						) -- 891
						local pT = projectWorld3D( -- 892
							bx + sway, -- 892
							s.y + tipH, -- 892
							-20, -- 892
							cam, -- 892
							self.proj -- 892
						) -- 892
						drawUiTri( -- 893
							uiDraw, -- 893
							pL, -- 893
							pR, -- 893
							pT, -- 893
							Color(11, 18, 17, 232), -- 893
							Color(14, 22, 20, 232), -- 893
							Color(32, 50, 44, 218), -- 893
							inv -- 893
						) -- 893
						k = k + 1 -- 885
					end -- 885
				end -- 885
			end -- 885
			::__continue65:: -- 885
			i = i + 1 -- 877
		end -- 877
	end -- 877
	if p.player.crouch and p.player.x >= ox + 292 and p.player.x <= ox + 468 then -- 898
		local vw = ctx.uiW -- 899
		local vh = ctx.uiH -- 900
		fillVGradRect( -- 901
			uiDraw, -- 901
			0, -- 901
			vh - vh * 0.18, -- 901
			vw, -- 901
			vh * 0.18, -- 901
			Color(8, 12, 11, 0), -- 901
			Color(8, 12, 11, 152) -- 901
		) -- 901
		fillVGradRect( -- 902
			uiDraw, -- 902
			0, -- 902
			0, -- 902
			vw, -- 902
			vh * 0.1, -- 902
			Color(8, 12, 11, 128), -- 902
			Color(8, 12, 11, 0) -- 902
		) -- 902
	end -- 902
	local nearCreek = smoothstep(ox + 1060, ox + 1240, p.player.x) -- 906
	if nearCreek > 0.02 then -- 907
		local w = ctx.uiW -- 908
		local h = ctx.uiH -- 909
		local partShift = self.creekReveal * w * 0.36 -- 910
		local liftShift = self.creekReveal * h * 0.14 -- 911
		local sway = math.sin(self.animTime * 1.45) * 4 -- 912
		local op = nearCreek * (0.92 - self.creekReveal * 0.42) -- 913
		uiArt:tryPlace( -- 915
			"pine", -- 915
			"fe04_creek_fg_pine_r1", -- 915
			w * 0.84 + partShift + sway * 0.5, -- 915
			h * 0.12 + liftShift, -- 915
			w * 0.42, -- 915
			h * 0.78, -- 915
			{ -- 915
				color = Color(12, 20, 22, 255), -- 916
				opacity = op, -- 917
				layer = 3, -- 918
				facing = -1 -- 919
			} -- 919
		) -- 919
		uiArt:tryPlace( -- 921
			"pine", -- 921
			"fe04_creek_fg_pine_r2", -- 921
			w * 0.68 + partShift * 1.15 + sway * 0.35, -- 921
			h * 0.24 + liftShift * 1.1, -- 921
			w * 0.32, -- 921
			h * 0.64, -- 921
			{ -- 921
				color = Color(16, 28, 28, 255), -- 922
				opacity = op * 0.85, -- 923
				layer = 2 -- 924
			} -- 924
		) -- 924
		local lShift = self.creekReveal * w * 0.24 -- 927
		uiArt:tryPlace( -- 928
			"pine", -- 928
			"fe04_creek_fg_pine_l", -- 928
			w * 0.06 - lShift - sway * 0.4, -- 928
			h * 0.16 + liftShift * 0.5, -- 928
			w * 0.34, -- 928
			h * 0.72, -- 928
			{ -- 928
				color = Color(12, 20, 22, 255), -- 929
				opacity = op * 0.82, -- 930
				layer = 2 -- 931
			} -- 931
		) -- 931
	end -- 931
	return false -- 935
end -- 863
return ____exports -- 863
