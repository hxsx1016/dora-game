-- [ts]: forest_creek.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 18
local Color = ____Dora.Color -- 18
local Content = ____Dora.Content -- 18
local Rect = ____Dora.Rect -- 18
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
	if not ctx.paused and ctx.worldDt > 0 then -- 264
		local dt = ctx.worldDt -- 267
		self.animTime = self.animTime + dt -- 268
		self.ripplePhase = self.ripplePhase + dt * 2.4 -- 270
		if self.xiaomanListenTimer > 0 then -- 270
			self.xiaomanListenTimer = math.max(0, self.xiaomanListenTimer - dt) -- 273
		end -- 273
		local movingFast = not p.player.crouch and (math.abs(p.player.vx) > 10 or not p.player.onGround) -- 277
		local i = 0 -- 278
		do -- 278
			i = 0 -- 279
			while i < #TWIG_OFFSETS do -- 279
				local tx = ox + TWIG_OFFSETS[i + 1] -- 280
				local lastSnapAt = self.twigTriggered[i] or -99 -- 281
				if movingFast and math.abs(p.player.x - tx) <= 18 and p.player.y <= 8 and self.animTime - lastSnapAt > 2.4 then -- 281
					self.twigTriggered[i] = self.animTime -- 283
					self:triggerTwigSnap(ctx, tx, p.dogX >= p.player.x and 1 or -1) -- 284
				end -- 284
				i = i + 1 -- 279
			end -- 279
		end -- 279
		if p.room.story ~= nil and p.room.story.dog ~= nil then -- 279
			if p.dogState == "ear" and self.prevDogState ~= "ear" then -- 279
				self.dogAlertCount = self.dogAlertCount + 1 -- 291
				self:triggerTwigSnap(ctx, p.player.x, p.dogX >= p.player.x and 1 or -1) -- 292
				ctx.audio:playOnce( -- 293
					(("fe04:forest:dog_alert:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogAlertCount), -- 294
					"sfx", -- 295
					CHILD_AUDIO_ROOT .. "dog_alert.wav", -- 296
					0.82, -- 297
					"fe04:forest:dog_alert", -- 298
					p.ticks, -- 299
					-1, -- 299
					{pan = ctx.audio:panForWorldX(p.dogX)} -- 301
				) -- 301
			elseif p.dogState == "chase" and self.prevDogState ~= "chase" then -- 301
				self.dogAlertCount = self.dogAlertCount + 1 -- 304
				local chasePath = Content:exist("assets/audio/foley/dog_chase_bark.wav") and "assets/audio/foley/dog_chase_bark.wav" or CHILD_AUDIO_ROOT .. "dog_alert.wav" -- 305
				ctx.audio:playOnce( -- 308
					(("fe04:forest:dog_chase:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogAlertCount), -- 309
					"sfx", -- 310
					chasePath, -- 311
					0.9, -- 312
					"fe04:forest:dog_chase", -- 313
					p.ticks, -- 314
					-1, -- 314
					{pan = ctx.audio:panForWorldX(p.dogX)} -- 316
				) -- 316
			end -- 316
			local dogDx = math.abs(p.dogX - self.prevDogX) -- 320
			if dogDx > 0.01 and (p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back") then -- 320
				self.dogStepAccum = self.dogStepAccum + dogDx -- 322
				local stepStride = p.dogState == "chase" and 28 or 42 -- 323
				if self.dogStepAccum >= stepStride then -- 323
					self.dogStepAccum = 0 -- 325
					local dist = math.abs(p.player.x - p.dogX) -- 326
					if dist < 420 then -- 326
						self.dogStepCount = self.dogStepCount + 1 -- 328
						local vol = 0.24 + 0.48 * clamp01(1 - dist / 420) -- 329
						ctx.audio:playOnce( -- 330
							(("fe04:forest:dog_step:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogStepCount), -- 331
							"sfx", -- 332
							CHILD_AUDIO_ROOT .. "dog_step.wav", -- 333
							vol, -- 334
							"fe04:forest:dog_step", -- 335
							p.ticks, -- 336
							-1, -- 336
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
				if sp.life > 0 then -- 351
					sp.vy = sp.vy - 320 * dt -- 353
					sp.x = sp.x + sp.vx * dt -- 354
					sp.y = sp.y + sp.vy * dt -- 355
					if sp.y < 0 then -- 355
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
		__TS__ArraySetLength(self.splinters, w) -- 349
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
		if creekApproach > 0.02 then -- 371
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
		-1, -- 400
		{pan = ctx.audio:panForWorldX(worldX)} -- 402
	) -- 402
	local i = 0 -- 404
	do -- 404
		i = 0 -- 405
		while i < 6 do -- 405
			local ang = (0.2 + self:rand() * 0.6) * math.pi -- 406
			local spd = 45 + self:rand() * 75 -- 407
			local ____self_splinters_0 = self.splinters -- 407
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
function ForestCreekScene.prototype.drawBackdrop(self, bgDraw, bgGlow, _backdropArt, ctx) -- 420
	local p = ctx.p -- 426
	local cam = ctx.cam -- 427
	local ox = p.ox -- 428
	local w = cam.viewW -- 429
	local h = cam.viewH -- 430
	local dawn = smoothstep(ox + 1120, ox + 1460, p.player.x) -- 433
	local skyTop = lerpRGBA( -- 434
		rgba(8, 14, 18, 255), -- 434
		rgba(16, 26, 38, 255), -- 434
		dawn -- 434
	) -- 434
	local skyMid = lerpRGBA( -- 435
		rgba(16, 28, 32, 255), -- 435
		rgba(32, 46, 62, 255), -- 435
		dawn -- 435
	) -- 435
	local skyHor = lerpRGBA( -- 436
		rgba(28, 44, 48, 255), -- 436
		rgba(62, 78, 94, 255), -- 436
		dawn -- 436
	) -- 436
	local splitY = h * 0.46 -- 437
	fillVGradRect( -- 438
		bgDraw, -- 438
		0, -- 438
		splitY, -- 438
		w, -- 438
		h - splitY, -- 438
		toColor(skyMid), -- 438
		toColor(skyTop) -- 438
	) -- 438
	fillVGradRect( -- 439
		bgDraw, -- 439
		0, -- 439
		0, -- 439
		w, -- 439
		splitY, -- 439
		toColor(skyHor), -- 439
		toColor(skyMid) -- 439
	) -- 439
	local scene = __TS__New(LowpolyScene, cam, self.proj, FOREST_CREEK_LIGHT) -- 441
	scene:addDistantRidge( -- 444
		{ -- 445
			{x = ox - 180, y = 128}, -- 446
			{x = ox + 220, y = 186}, -- 447
			{x = ox + 620, y = 152}, -- 448
			{x = ox + 1040, y = 204}, -- 449
			{x = ox + 1420, y = 168}, -- 450
			{x = ox + 1780, y = 196} -- 451
		}, -- 451
		-40, -- 451
		460, -- 454
		MING_MATERIALS.distantHill, -- 455
		{bucket = LP_BUCKET.BACKDROP} -- 456
	) -- 456
	local treeXs = { -- 460
		80, -- 460
		210, -- 460
		360, -- 460
		510, -- 460
		670, -- 460
		840, -- 460
		1010, -- 460
		1180, -- 460
		1290 -- 460
	} -- 460
	local i = 0 -- 461
	do -- 461
		i = 0 -- 462
		while i < #treeXs do -- 462
			local tx = ox + treeXs[i + 1] -- 463
			local tz = 185 + i % 3 * 42 -- 464
			local tw = 12 + i % 2 * 5 -- 465
			scene:addBox({ -- 466
				x0 = tx - tw * 0.5, -- 467
				x1 = tx + tw * 0.5, -- 468
				y0 = -20, -- 469
				y1 = 185 + i % 2 * 20, -- 470
				z0 = tz, -- 471
				z1 = tz + 16, -- 472
				material = MING_MATERIALS.distantWall, -- 473
				bucket = LP_BUCKET.BACKDROP, -- 474
				edgeWidth = 0 -- 475
			}) -- 475
			local lean = (i % 3 - 1) * 7 -- 478
			local baseH = 92 + i % 2 * 14 -- 479
			local tier = 0 -- 480
			do -- 480
				tier = 0 -- 481
				while tier < 3 do -- 481
					local ty0 = baseH + tier * 32 -- 482
					local ty1 = ty0 + 52 - tier * 6 -- 483
					local half = 50 - tier * 11 -- 484
					local colShift = tier * 4 -- 485
					scene:addTri3D( -- 486
						vec3(tx - half + lean * 0.4, ty0, tz - 4 - tier * 2), -- 487
						vec3(tx + half + lean * 0.4, ty0 + 4, tz - 4 - tier * 2), -- 488
						vec3(tx + lean, ty1, tz + 4), -- 489
						{base = rgba(18 + colShift, 30 + colShift, 32 + colShift, 255)}, -- 490
						{bucket = LP_BUCKET.BACKDROP, sortBias = 0.04 + tier * 0.01} -- 491
					) -- 491
					tier = tier + 1 -- 481
				end -- 481
			end -- 481
			i = i + 1 -- 462
		end -- 462
	end -- 462
	local towerX = ox + 1525 -- 497
	scene:addBox({ -- 498
		x0 = towerX - 24, -- 499
		x1 = towerX + 24, -- 500
		y0 = 44, -- 501
		y1 = 174, -- 502
		z0 = 332, -- 503
		z1 = 356, -- 504
		material = MING_MATERIALS.distantWall, -- 505
		bucket = LP_BUCKET.BACKDROP, -- 506
		sortBias = 0.12, -- 507
		edgeWidth = 0 -- 508
	}) -- 508
	scene:addTri3D( -- 511
		vec3(towerX - 34, 174, 330), -- 512
		vec3(towerX + 34, 174, 330), -- 513
		vec3(towerX, 200, 344), -- 514
		MING_MATERIALS.mingTile, -- 515
		{bucket = LP_BUCKET.BACKDROP, sortBias = 0.14} -- 516
	) -- 516
	scene:addFogBand( -- 520
		ox - 160, -- 520
		ox + 1780, -- 520
		-30, -- 520
		148, -- 520
		250, -- 520
		rgba(28, 42, 48, 255), -- 520
		0.62, -- 520
		0.06, -- 520
		{bucket = LP_BUCKET.BACKDROP} -- 520
	) -- 520
	scene:flush(bgDraw, bgGlow) -- 524
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 527
	local lampPt = projectWorld3D( -- 528
		towerX - 4, -- 528
		146, -- 528
		330, -- 528
		cam, -- 528
		self.proj -- 528
	) -- 528
	fillRadialGlow( -- 529
		bgGlow, -- 530
		lampPt.x, -- 531
		lampPt.y, -- 532
		42 * lampPulse, -- 533
		42 * lampPulse, -- 534
		Color( -- 535
			246, -- 535
			208, -- 535
			134, -- 535
			math.floor(115 * lampPulse + 0.5) -- 535
		), -- 535
		Color(232, 176, 86, 0), -- 536
		16 -- 537
	) -- 537
	bgDraw:drawRect( -- 539
		Rect(lampPt.x - 3.5, lampPt.y - 5.5, 7, 11), -- 539
		Color(255, 232, 174, 240) -- 539
	) -- 539
	bgGlow:drawDot( -- 540
		Vec2(lampPt.x, lampPt.y), -- 540
		3.4, -- 540
		Color(255, 246, 218, 250) -- 540
	) -- 540
	return true -- 542
end -- 420
function ForestCreekScene.prototype.drawWorld(self, fgDraw, fgGlow, _worldArt, ctx) -- 545
	local p = ctx.p -- 551
	local cam = ctx.cam -- 552
	local ox = p.ox -- 553
	local scene = __TS__New(LowpolyScene, cam, self.proj, FOREST_CREEK_LIGHT) -- 554
	scene:addBox({ -- 557
		x0 = ox - 40, -- 558
		x1 = ox + 1320, -- 559
		y0 = -52, -- 560
		y1 = 0, -- 561
		z0 = -26, -- 562
		z1 = 92, -- 563
		material = MAT_MOSS_GROUND, -- 564
		bucket = LP_BUCKET.MIDGROUND, -- 565
		highlightTopEdge = true, -- 566
		edgeWidth = 0.7 -- 567
	}) -- 567
	scene:addBox({ -- 570
		x0 = ox + 1320, -- 571
		x1 = ox + 1620, -- 572
		y0 = -14, -- 573
		y1 = 0, -- 574
		z0 = -10, -- 575
		z1 = 24, -- 576
		material = MING_MATERIALS.mingStoneStep, -- 577
		bucket = LP_BUCKET.WALK_DECK, -- 578
		highlightTopEdge = true, -- 579
		edgeWidth = 0.9 -- 580
	}) -- 580
	scene:addQuad3D( -- 583
		vec3(ox + 1250, -6, -44), -- 584
		vec3(ox + 1640, -6, -44), -- 585
		vec3(ox + 1640, -2, -10), -- 586
		vec3(ox + 1250, -2, -10), -- 587
		MAT_CREEK_WATER, -- 588
		{bucket = LP_BUCKET.WALK_DECK, sortBias = 0.08, edgeWidth = 0} -- 589
	) -- 589
	scene:addQuad3D( -- 591
		vec3(ox + 1250, -2, 24), -- 592
		vec3(ox + 1660, -2, 24), -- 593
		vec3(ox + 1660, 4, 196), -- 594
		vec3(ox + 1250, 4, 196), -- 595
		MAT_CREEK_WATER, -- 596
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.04, edgeWidth = 0} -- 597
	) -- 597
	local midTrunks = { -- 601
		150, -- 601
		415, -- 601
		650, -- 601
		910, -- 601
		1255 -- 601
	} -- 601
	local i = 0 -- 602
	do -- 602
		i = 0 -- 603
		while i < #midTrunks do -- 603
			local tx = ox + midTrunks[i + 1] -- 604
			local tz = 38 + i % 2 * 18 -- 605
			local halfW = 10 + i % 2 * 2 -- 606
			local topW = halfW * 0.62 -- 607
			scene:addQuad3D( -- 609
				vec3(tx - halfW, -10, tz), -- 610
				vec3(tx + halfW, -10, tz), -- 611
				vec3(tx + topW, 205, tz), -- 612
				vec3(tx - topW, 205, tz), -- 613
				MAT_PINE_TRUNK, -- 614
				{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.7} -- 615
			) -- 615
			local bDir = i % 2 == 0 and 1 or -1 -- 618
			scene:addTri3D( -- 619
				vec3(tx - topW * 0.5, 118, tz - 2), -- 620
				vec3(tx + bDir * 56, 108, tz - 4), -- 621
				vec3(tx + bDir * 12, 142, tz - 2), -- 622
				MAT_PINE_NEEDLE, -- 623
				{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.08, edgeWidth = 0.6} -- 624
			) -- 624
			scene:addTri3D( -- 626
				vec3(tx - bDir * 44, 146, tz - 2), -- 627
				vec3(tx + bDir * 48, 152, tz - 3), -- 628
				vec3(tx, 198, tz - 2), -- 629
				MAT_PINE_NEEDLE, -- 630
				{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.1, edgeWidth = 0.6} -- 631
			) -- 631
			i = i + 1 -- 603
		end -- 603
	end -- 603
	do -- 603
		i = 0 -- 636
		while i < #p.room.stairs do -- 636
			local st = p.room.stairs[i + 1] -- 637
			scene:addBox({ -- 638
				x0 = st.x0, -- 639
				x1 = st.x1, -- 640
				y0 = 0, -- 641
				y1 = st.y1, -- 642
				z0 = -14, -- 643
				z1 = 42, -- 644
				material = i == 1 and MAT_ROOT_ARCH or MING_MATERIALS.mingStoneStep, -- 645
				bucket = LP_BUCKET.WALK_DECK, -- 646
				highlightTopEdge = true, -- 647
				edgeWidth = 0.9 -- 648
			}) -- 648
			i = i + 1 -- 636
		end -- 636
	end -- 636
	scene:addTri3D( -- 655
		vec3(ox + 958, 0, 12), -- 656
		vec3(ox + 998, 22, 12), -- 657
		vec3(ox + 986, 104, 22), -- 658
		MAT_ROOT_ARCH, -- 659
		{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.9} -- 660
	) -- 660
	scene:addTri3D( -- 662
		vec3(ox + 1086, 22, 12), -- 663
		vec3(ox + 1134, 0, 12), -- 664
		vec3(ox + 1098, 106, 22), -- 665
		MAT_ROOT_ARCH, -- 666
		{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.9} -- 667
	) -- 667
	scene:addQuad3D( -- 669
		vec3(ox + 972, 74, 14), -- 670
		vec3(ox + 1110, 78, 14), -- 671
		vec3(ox + 1094, 116, 36), -- 672
		vec3(ox + 986, 112, 36), -- 673
		MAT_ROOT_ARCH, -- 674
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.1, edgeWidth = 1} -- 675
	) -- 675
	scene:addQuad3D( -- 678
		vec3(ox + 992, 22, 34), -- 679
		vec3(ox + 1088, 22, 34), -- 680
		vec3(ox + 1080, 74, 34), -- 681
		vec3(ox + 1000, 74, 34), -- 682
		{ -- 683
			base = rgba(10, 16, 18, 215), -- 683
			edge = rgba(164, 192, 188, 130) -- 683
		}, -- 683
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.05, edgeWidth = 1} -- 684
	) -- 684
	scene:addBox({ -- 687
		x0 = ox + 830, -- 688
		x1 = ox + 1230, -- 689
		y0 = -10, -- 690
		y1 = 5, -- 691
		z0 = 26, -- 692
		z1 = 60, -- 693
		material = MAT_CANAL_STONE, -- 694
		bucket = LP_BUCKET.MIDGROUND, -- 695
		highlightTopEdge = true, -- 696
		edgeWidth = 0.9 -- 697
	}) -- 697
	scene:addQuad3D( -- 700
		vec3(ox + 858, 5, 28), -- 701
		vec3(ox + 894, 5, 28), -- 702
		vec3(ox + 888, 20, 44), -- 703
		vec3(ox + 852, 18, 44), -- 704
		MAT_CANAL_STONE, -- 705
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.22, edgeWidth = 1} -- 706
	) -- 706
	do -- 706
		i = 0 -- 710
		while i < #p.room.solids do -- 710
			local s = p.room.solids[i + 1] -- 711
			if s.passable == true then -- 711
				self:buildGrassCluster( -- 713
					scene, -- 713
					s.x, -- 713
					s.x + s.w, -- 713
					s.y, -- 713
					s.h, -- 713
					8 -- 713
				) -- 713
			elseif s.x >= ox + 1500 then -- 713
				scene:addBox({ -- 716
					x0 = s.x, -- 717
					x1 = s.x + s.w, -- 718
					y0 = s.y, -- 719
					y1 = s.y + s.h, -- 720
					z0 = 10, -- 721
					z1 = 72, -- 722
					material = MING_MATERIALS.mingBrickDark, -- 723
					bucket = LP_BUCKET.MIDGROUND, -- 724
					highlightTopEdge = true -- 725
				}) -- 725
			end -- 725
			i = i + 1 -- 710
		end -- 710
	end -- 710
	do -- 710
		i = 0 -- 731
		while i < #TWIG_OFFSETS do -- 731
			local tx = ox + TWIG_OFFSETS[i + 1] -- 732
			scene:addTri3D( -- 733
				vec3(tx - 12, 0.8, -5), -- 734
				vec3(tx + 12, 0.8, -3), -- 735
				vec3(tx + 3, 6.2, 2), -- 736
				MAT_TWIG, -- 737
				{bucket = LP_BUCKET.PROP, sortBias = 0.15, edgeWidth = 1} -- 738
			) -- 738
			scene:addTri3D( -- 740
				vec3(tx - 8, 0.8, 3), -- 741
				vec3(tx + 14, 0.8, 5), -- 742
				vec3(tx - 2, 5.2, -2), -- 743
				MAT_TWIG, -- 744
				{bucket = LP_BUCKET.PROP, sortBias = 0.16, edgeWidth = 0.9} -- 745
			) -- 745
			i = i + 1 -- 731
		end -- 731
	end -- 731
	scene:addContactShadow( -- 750
		p.player.x, -- 750
		p.player.y, -- 750
		14, -- 750
		10, -- 750
		0.8, -- 750
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 750
	) -- 750
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 750
		scene:addContactShadow( -- 752
			p.dogX, -- 752
			0, -- 752
			18, -- 752
			11, -- 752
			0.82, -- 752
			{bucket = LP_BUCKET.PROP, sortBias = 0.44} -- 752
		) -- 752
	end -- 752
	scene:flush(fgDraw, fgGlow) -- 755
	self:drawCreekWaterReflection(fgDraw, fgGlow, p, cam) -- 758
	do -- 758
		i = 0 -- 761
		while i < #self.splinters do -- 761
			local sp = self.splinters[i + 1] -- 762
			local a = clamp01(sp.life / sp.maxLife) -- 763
			local sx = cam:sx(sp.x) -- 764
			local sy = cam:sy(sp.y) -- 765
			fgDraw:drawSegment( -- 766
				Vec2(sx - sp.len, sy - 1), -- 766
				Vec2(sx + sp.len, sy + 2), -- 766
				1.3, -- 766
				Color( -- 766
					204, -- 766
					182, -- 766
					146, -- 766
					math.floor(235 * a + 0.5) -- 766
				) -- 766
			) -- 766
			i = i + 1 -- 761
		end -- 761
	end -- 761
	return true -- 769
end -- 545
function ForestCreekScene.prototype.buildGrassCluster(self, scene, x0, x1, y0, h, z) -- 772
	local count = math.max( -- 773
		7, -- 773
		math.floor((x1 - x0) / 10) -- 773
	) -- 773
	local span = (x1 - x0) / count -- 774
	local k = 0 -- 775
	do -- 775
		k = 0 -- 776
		while k < count do -- 776
			local bx = x0 + (k + 0.5) * span -- 777
			local lean = (k * 29 % 11 - 5) * 1.3 -- 778
			local sway = math.sin(self.animTime * 1.9 + bx * 0.06) * 2.8 + lean -- 779
			local tipH = h * (0.58 + k * 37 % 10 * 0.048) -- 780
			scene:addTri3D( -- 781
				vec3(bx - span * 0.42, y0, z), -- 782
				vec3(bx + span * 0.42, y0, z), -- 783
				vec3(bx + sway, y0 + tipH, z - 2), -- 784
				MAT_GRASS_BACK, -- 785
				{bucket = LP_BUCKET.PROP, sortBias = 0.1 + k * 0.005, edgeWidth = 0.45} -- 786
			) -- 786
			k = k + 1 -- 776
		end -- 776
	end -- 776
end -- 772
function ForestCreekScene.prototype.drawCreekWaterReflection(self, fgDraw, fgGlow, p, cam) -- 791
	local ox = p.ox -- 797
	if cam:sx(ox + 1230) > cam.viewW + 120 then -- 797
		return -- 799
	end -- 799
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 801
	local reflCenterX = ox + 1438 -- 802
	local r = 0 -- 805
	do -- 805
		r = 0 -- 806
		while r < 10 do -- 806
			local z = r < 4 and -34 + r * 6 or 32 + (r - 4) * 24 -- 807
			local wx = ox + 1295 + r * 32 + math.sin(self.ripplePhase * 0.75 + r * 1.4) * 14 -- 808
			local pL = projectWorld3D( -- 809
				wx - 26, -- 809
				-3, -- 809
				z, -- 809
				cam, -- 809
				self.proj -- 809
			) -- 809
			local pR = projectWorld3D( -- 810
				wx + 26, -- 810
				-3, -- 810
				z, -- 810
				cam, -- 810
				self.proj -- 810
			) -- 810
			fgGlow:drawSegment( -- 811
				Vec2(pL.x, pL.y), -- 811
				Vec2(pR.x, pR.y), -- 811
				1.1, -- 811
				Color(146, 178, 198, 72) -- 811
			) -- 811
			r = r + 1 -- 806
		end -- 806
	end -- 806
	local bands = 9 -- 815
	do -- 815
		r = 0 -- 816
		while r < bands do -- 816
			local frac = r / (bands - 1) -- 817
			local z = -34 + frac * 22 -- 818
			local drift = math.sin(self.ripplePhase * (1.25 + frac * 0.4) + r * 1.35) * (6 + frac * 9) -- 819
			local halfW = (18 - frac * 8) * (0.75 + 0.25 * math.cos(self.ripplePhase * 1.7 + r)) -- 820
			local wy = -4.5 + frac * 2.5 -- 821
			local pL = projectWorld3D( -- 822
				reflCenterX + drift - halfW, -- 822
				wy, -- 822
				z, -- 822
				cam, -- 822
				self.proj -- 822
			) -- 822
			local pR = projectWorld3D( -- 823
				reflCenterX + drift + halfW, -- 823
				wy, -- 823
				z, -- 823
				cam, -- 823
				self.proj -- 823
			) -- 823
			local a = (0.42 + 0.5 * (1 - frac)) * lampPulse -- 824
			fgDraw:drawSegment( -- 825
				Vec2(pL.x, pL.y), -- 825
				Vec2(pR.x, pR.y), -- 825
				2.1 - frac * 0.7, -- 825
				Color( -- 825
					242, -- 825
					198, -- 825
					118, -- 825
					math.floor(190 * a + 0.5) -- 825
				) -- 825
			) -- 825
			fgGlow:drawSegment( -- 826
				Vec2(pL.x, pL.y), -- 826
				Vec2(pR.x, pR.y), -- 826
				3.6 - frac * 1.1, -- 826
				Color( -- 826
					248, -- 826
					214, -- 826
					140, -- 826
					math.floor(135 * a + 0.5) -- 826
				) -- 826
			) -- 826
			r = r + 1 -- 816
		end -- 816
	end -- 816
	local poolP = projectWorld3D( -- 829
		reflCenterX + 22, -- 829
		0, -- 829
		56, -- 829
		cam, -- 829
		self.proj -- 829
	) -- 829
	fillRadialGlow( -- 830
		fgGlow, -- 831
		poolP.x, -- 832
		poolP.y, -- 833
		58 * lampPulse, -- 834
		18 * lampPulse, -- 835
		Color( -- 836
			246, -- 836
			206, -- 836
			128, -- 836
			math.floor(92 * lampPulse + 0.5) -- 836
		), -- 836
		Color(232, 174, 88, 0), -- 837
		16 -- 838
	) -- 838
end -- 791
function ForestCreekScene.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, _ctx) -- 843
	return true -- 849
end -- 843
function ForestCreekScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 853
	local p = ctx.p -- 859
	local cam = ctx.cam -- 860
	local px = cam:sx(p.player.x) -- 863
	local pTopY = cam:sy(p.player.y + p.player.h) -- 864
	local fDir = p.player.facing >= 0 and 1 or -1 -- 865
	local shY = pTopY - cam:len(16.5) -- 866
	fgDraw:drawSegment( -- 867
		Vec2( -- 868
			px - fDir * cam:len(7.5), -- 868
			shY - cam:len(4) -- 868
		), -- 868
		Vec2( -- 869
			px - fDir * cam:len(5.5), -- 869
			shY + cam:len(3.5) -- 869
		), -- 869
		1.3, -- 870
		Color(196, 212, 220, 145) -- 871
	) -- 871
	fgDraw:drawSegment( -- 873
		Vec2( -- 874
			px - fDir * cam:len(5.5), -- 874
			shY + cam:len(3.5) -- 874
		), -- 874
		Vec2( -- 875
			px + fDir * cam:len(3.5), -- 875
			shY + cam:len(5.2) -- 875
		), -- 875
		1.2, -- 876
		Color(206, 220, 228, 135) -- 877
	) -- 877
	if self.xiaomanListenTimer > 0 then -- 877
		local k = smoothstep(0, 0.12, self.xiaomanListenTimer) * clamp01(self.xiaomanListenTimer / 0.52) -- 882
		local earX = px + self.xiaomanListenDir * cam:len(8) -- 883
		local earY = pTopY - cam:len(10) -- 884
		local r1 = cam:len(6.5 + (1 - k) * 8) -- 885
		local r2 = cam:len(11.5 + (1 - k) * 11) -- 886
		local startAng = self.xiaomanListenDir > 0 and -34 or 146 -- 887
		local endAng = self.xiaomanListenDir > 0 and 34 or 214 -- 888
		fgDraw:drawArc( -- 889
			Vec2(earX, earY), -- 889
			r1, -- 889
			startAng, -- 889
			endAng, -- 889
			1.3, -- 889
			Color( -- 889
				224, -- 889
				218, -- 889
				198, -- 889
				math.floor(185 * k + 0.5) -- 889
			) -- 889
		) -- 889
		fgGlow:drawArc( -- 890
			Vec2(earX, earY), -- 890
			r2, -- 890
			startAng, -- 890
			endAng, -- 890
			1.1, -- 890
			Color( -- 890
				204, -- 890
				218, -- 890
				224, -- 890
				math.floor(135 * k + 0.5) -- 890
			) -- 890
		) -- 890
	end -- 890
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 890
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 895
		local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 896
		local headX = cam:sx(p.dogX + f * 11) -- 897
		local headY = cam:sy(23.5) -- 898
		local earH = cam:len(alert and 7.6 or 4.8) -- 899
		local earCol = alert and Color(224, 222, 212, 220) or Color(176, 194, 202, 170) -- 900
		fgDraw:drawPolygon( -- 901
			{ -- 901
				Vec2(headX - f * 3.4, headY), -- 902
				Vec2(headX - f * 0.8, headY + earH), -- 903
				Vec2(headX + f * 2.4, headY + 0.8) -- 904
			}, -- 904
			Color(38, 36, 34, 235), -- 905
			1.1, -- 905
			earCol -- 905
		) -- 905
		if alert then -- 905
			local waveR = cam:len(8 + self.animTime * 20 % 13) -- 907
			fgGlow:drawArc( -- 908
				Vec2(headX, headY + earH * 0.75), -- 908
				waveR, -- 908
				42, -- 908
				138, -- 908
				1.2, -- 908
				Color(226, 208, 174, 145) -- 908
			) -- 908
		end -- 908
	end -- 908
	if ctx.paused then -- 908
		local pX = cam.viewW * (0.78 + self.creekReveal * 0.24) -- 914
		worldArt:tryPlace( -- 915
			"pine", -- 915
			"fe04_pause_creek_branch", -- 915
			pX, -- 915
			cam.viewH * 0.42, -- 915
			cam.viewW * 0.48, -- 915
			cam.viewH * 0.62, -- 915
			{ -- 915
				color = Color(14, 20, 22, 255), -- 916
				opacity = 0.9 * (1 - self.creekReveal * 0.7), -- 917
				layer = 5300 -- 918
			} -- 918
		) -- 918
	end -- 918
end -- 853
function ForestCreekScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 929
	local p = ctx.p -- 936
	local cam = ctx.cam -- 937
	local ox = p.ox -- 938
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 939
	local i = 0 -- 942
	do -- 942
		i = 0 -- 943
		while i < #p.room.solids do -- 943
			do -- 943
				local s = p.room.solids[i + 1] -- 944
				if s.passable ~= true then -- 944
					goto __continue66 -- 946
				end -- 946
				local blades = math.max( -- 948
					7, -- 948
					math.floor(s.w / 10) -- 948
				) -- 948
				local span = s.w / blades -- 949
				local k = 0 -- 950
				do -- 950
					k = 0 -- 951
					while k < blades do -- 951
						local bx = s.x + (k + 0.5) * span -- 952
						local lean = (k * 23 % 9 - 4) * 1.6 -- 953
						local sway = math.sin(self.animTime * 2.1 + bx * 0.06) * 2.6 + lean -- 954
						local tipH = math.min(18, s.h * (0.48 + k * 19 % 7 * 0.048)) -- 955
						local pL = projectWorld3D( -- 956
							bx - span * 0.36, -- 956
							s.y - 2, -- 956
							-18, -- 956
							cam, -- 956
							self.proj -- 956
						) -- 956
						local pR = projectWorld3D( -- 957
							bx + span * 0.36, -- 957
							s.y - 2, -- 957
							-18, -- 957
							cam, -- 957
							self.proj -- 957
						) -- 957
						local pT = projectWorld3D( -- 958
							bx + sway, -- 958
							s.y + tipH, -- 958
							-20, -- 958
							cam, -- 958
							self.proj -- 958
						) -- 958
						drawUiTri( -- 959
							uiDraw, -- 959
							pL, -- 959
							pR, -- 959
							pT, -- 959
							Color(11, 18, 17, 232), -- 959
							Color(14, 22, 20, 232), -- 959
							Color(32, 50, 44, 218), -- 959
							inv -- 959
						) -- 959
						k = k + 1 -- 951
					end -- 951
				end -- 951
			end -- 951
			::__continue66:: -- 951
			i = i + 1 -- 943
		end -- 943
	end -- 943
	local nearCreek = smoothstep(ox + 1060, ox + 1240, p.player.x) -- 965
	if nearCreek > 0.02 then -- 965
		local w = cam.viewW -- 967
		local h = cam.viewH -- 968
		local partShift = self.creekReveal * w * 0.38 -- 969
		local liftShift = self.creekReveal * h * 0.16 -- 970
		local canopyAlpha = math.floor(244 * nearCreek * (1 - self.creekReveal * 0.28) + 0.5) -- 971
		local cTrunk = Color(14, 18, 18, canopyAlpha) -- 972
		local cDark = Color(11, 20, 20, canopyAlpha) -- 973
		local cLeaf = Color( -- 974
			22, -- 974
			36, -- 974
			33, -- 974
			math.floor(canopyAlpha * 0.94 + 0.5) -- 974
		) -- 974
		local sway = math.sin(self.animTime * 1.45) * 5 -- 975
		drawUiQuad( -- 978
			uiDraw, -- 979
			{x = w * 0.56 + partShift + sway * 0.4, y = h * 0.67 + liftShift}, -- 980
			{x = w * 1.06 + partShift, y = h * 0.84 + liftShift}, -- 981
			{x = w * 1.06 + partShift, y = h * 0.96 + liftShift}, -- 982
			{x = w * 0.54 + partShift + sway * 0.4, y = h * 0.74 + liftShift}, -- 983
			cTrunk, -- 984
			cDark, -- 985
			inv -- 986
		) -- 986
		local clusters = { -- 989
			{ -- 990
				fx = 0.56, -- 990
				fy = 0.66, -- 990
				rw = 118, -- 990
				rh = 92, -- 990
				drop = 112 -- 990
			}, -- 990
			{ -- 991
				fx = 0.68, -- 991
				fy = 0.62, -- 991
				rw = 138, -- 991
				rh = 108, -- 991
				drop = 134 -- 991
			}, -- 991
			{ -- 992
				fx = 0.81, -- 992
				fy = 0.64, -- 992
				rw = 146, -- 992
				rh = 112, -- 992
				drop = 124 -- 992
			}, -- 992
			{ -- 993
				fx = 0.94, -- 993
				fy = 0.7, -- 993
				rw = 142, -- 993
				rh = 118, -- 993
				drop = 116 -- 993
			}, -- 993
			{ -- 994
				fx = 0.74, -- 994
				fy = 0.78, -- 994
				rw = 165, -- 994
				rh = 110, -- 994
				drop = 92 -- 994
			} -- 994
		} -- 994
		local ci = 0 -- 996
		do -- 996
			ci = 0 -- 997
			while ci < #clusters do -- 997
				local cl = clusters[ci + 1] -- 998
				local bx = w * cl.fx + partShift + sway * (0.5 + ci * 0.12) -- 999
				local by = h * cl.fy + liftShift -- 1000
				drawUiTri( -- 1001
					uiDraw, -- 1002
					{x = bx - cl.rw * 0.65, y = by + cl.rh * 0.85}, -- 1003
					{x = bx + cl.rw * 0.72, y = by + cl.rh * 0.62}, -- 1004
					{x = bx - cl.rw * 0.12 + sway * 0.6, y = by - cl.drop * 0.68}, -- 1005
					cDark, -- 1006
					cDark, -- 1007
					cLeaf, -- 1008
					inv -- 1009
				) -- 1009
				drawUiTri( -- 1011
					uiDraw, -- 1012
					{x = bx - cl.rw * 0.28, y = by + cl.rh * 0.92}, -- 1013
					{x = bx + cl.rw * 0.88, y = by + cl.rh * 0.82}, -- 1014
					{x = bx + cl.rw * 0.24 + sway * 0.8, y = by - cl.drop * 0.54}, -- 1015
					cDark, -- 1016
					cTrunk, -- 1017
					cLeaf, -- 1018
					inv -- 1019
				) -- 1019
				ci = ci + 1 -- 997
			end -- 997
		end -- 997
		local lShift = self.creekReveal * w * 0.22 -- 1024
		drawUiTri( -- 1025
			uiDraw, -- 1026
			{x = -30 - lShift, y = h + 16}, -- 1027
			{x = w * 0.3 - lShift, y = h + 16}, -- 1028
			{x = w * 0.12 - lShift - sway * 0.5, y = h * 0.68 + liftShift * 0.5}, -- 1029
			cDark, -- 1030
			cDark, -- 1031
			cLeaf, -- 1032
			inv -- 1033
		) -- 1033
	end -- 1033
	return false -- 1037
end -- 929
return ____exports -- 929