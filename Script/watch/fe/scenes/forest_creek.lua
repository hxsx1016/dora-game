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
		-40, -- 453
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
		x1 = ox + 1190, -- 559
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
		x0 = ox + 1180, -- 571
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
		vec3(ox + 1170, -6, -44), -- 584
		vec3(ox + 1640, -6, -44), -- 585
		vec3(ox + 1640, -2, -10), -- 586
		vec3(ox + 1170, -2, -10), -- 587
		MAT_CREEK_WATER, -- 588
		{bucket = LP_BUCKET.WALK_DECK, sortBias = 0.08, edgeWidth = 0} -- 589
	) -- 589
	scene:addQuad3D( -- 591
		vec3(ox + 1170, -2, 24), -- 592
		vec3(ox + 1660, -2, 24), -- 593
		vec3(ox + 1660, 4, 196), -- 594
		vec3(ox + 1170, 4, 196), -- 595
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
	scene:addTri3D( -- 654
		vec3(ox + 286, 0, 12), -- 655
		vec3(ox + 318, 12, 12), -- 656
		vec3(ox + 306, 76, 22), -- 657
		MAT_ROOT_ARCH, -- 658
		{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.9} -- 659
	) -- 659
	scene:addTri3D( -- 661
		vec3(ox + 372, 12, 12), -- 662
		vec3(ox + 412, 0, 12), -- 663
		vec3(ox + 382, 78, 22), -- 664
		MAT_ROOT_ARCH, -- 665
		{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.9} -- 666
	) -- 666
	scene:addQuad3D( -- 668
		vec3(ox + 298, 48, 14), -- 669
		vec3(ox + 394, 52, 14), -- 670
		vec3(ox + 384, 86, 36), -- 671
		vec3(ox + 306, 82, 36), -- 672
		MAT_ROOT_ARCH, -- 673
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.1, edgeWidth = 1} -- 674
	) -- 674
	scene:addQuad3D( -- 677
		vec3(ox + 306, 0, 34), -- 678
		vec3(ox + 382, 0, 34), -- 679
		vec3(ox + 376, 48, 34), -- 680
		vec3(ox + 312, 48, 34), -- 681
		{ -- 682
			base = rgba(10, 16, 18, 215), -- 682
			edge = rgba(164, 192, 188, 130) -- 682
		}, -- 682
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.05, edgeWidth = 1} -- 683
	) -- 683
	scene:addBox({ -- 686
		x0 = ox + 690, -- 687
		x1 = ox + 810, -- 688
		y0 = -10, -- 689
		y1 = 5, -- 690
		z0 = 26, -- 691
		z1 = 60, -- 692
		material = MAT_CANAL_STONE, -- 693
		bucket = LP_BUCKET.MIDGROUND, -- 694
		highlightTopEdge = true, -- 695
		edgeWidth = 0.9 -- 696
	}) -- 696
	scene:addQuad3D( -- 698
		vec3(ox + 706, 5, 28), -- 699
		vec3(ox + 742, 5, 28), -- 700
		vec3(ox + 736, 20, 44), -- 701
		vec3(ox + 700, 18, 44), -- 702
		MAT_CANAL_STONE, -- 703
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.22, edgeWidth = 1} -- 704
	) -- 704
	do -- 704
		i = 0 -- 708
		while i < #p.room.solids do -- 708
			local s = p.room.solids[i + 1] -- 709
			if s.passable == true then -- 710
				self:buildGrassCluster( -- 711
					scene, -- 711
					s.x, -- 711
					s.x + s.w, -- 711
					s.y, -- 711
					s.h, -- 711
					8 -- 711
				) -- 711
			elseif s.x >= ox + 1500 then -- 712
				scene:addBox({ -- 714
					x0 = s.x, -- 715
					x1 = s.x + s.w, -- 716
					y0 = s.y, -- 717
					y1 = s.y + s.h, -- 718
					z0 = 10, -- 719
					z1 = 72, -- 720
					material = MING_MATERIALS.mingBrickDark, -- 721
					bucket = LP_BUCKET.MIDGROUND, -- 722
					highlightTopEdge = true -- 723
				}) -- 723
			end -- 723
			i = i + 1 -- 708
		end -- 708
	end -- 708
	do -- 708
		i = 0 -- 729
		while i < #TWIG_OFFSETS do -- 729
			local tx = ox + TWIG_OFFSETS[i + 1] -- 730
			scene:addTri3D( -- 731
				vec3(tx - 12, 0.8, -5), -- 732
				vec3(tx + 12, 0.8, -3), -- 733
				vec3(tx + 3, 6.2, 2), -- 734
				MAT_TWIG, -- 735
				{bucket = LP_BUCKET.PROP, sortBias = 0.15, edgeWidth = 1} -- 736
			) -- 736
			scene:addTri3D( -- 738
				vec3(tx - 8, 0.8, 3), -- 739
				vec3(tx + 14, 0.8, 5), -- 740
				vec3(tx - 2, 5.2, -2), -- 741
				MAT_TWIG, -- 742
				{bucket = LP_BUCKET.PROP, sortBias = 0.16, edgeWidth = 0.9} -- 743
			) -- 743
			i = i + 1 -- 729
		end -- 729
	end -- 729
	scene:addContactShadow( -- 748
		p.player.x, -- 748
		p.player.y, -- 748
		14, -- 748
		10, -- 748
		0.8, -- 748
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 748
	) -- 748
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 749
		scene:addContactShadow( -- 750
			p.dogX, -- 750
			0, -- 750
			18, -- 750
			11, -- 750
			0.82, -- 750
			{bucket = LP_BUCKET.PROP, sortBias = 0.44} -- 750
		) -- 750
	end -- 750
	scene:flush(fgDraw, fgGlow) -- 753
	self:drawCreekWaterReflection(fgDraw, fgGlow, p, cam) -- 756
	do -- 756
		i = 0 -- 759
		while i < #self.splinters do -- 759
			local sp = self.splinters[i + 1] -- 760
			local a = clamp01(sp.life / sp.maxLife) -- 761
			local sx = cam:sx(sp.x) -- 762
			local sy = cam:sy(sp.y) -- 763
			fgDraw:drawSegment( -- 764
				Vec2(sx - sp.len, sy - 1), -- 764
				Vec2(sx + sp.len, sy + 2), -- 764
				1.3, -- 764
				Color( -- 764
					204, -- 764
					182, -- 764
					146, -- 764
					math.floor(235 * a + 0.5) -- 764
				) -- 764
			) -- 764
			i = i + 1 -- 759
		end -- 759
	end -- 759
	return true -- 767
end -- 545
function ForestCreekScene.prototype.buildGrassCluster(self, scene, x0, x1, y0, h, z) -- 770
	local count = math.max( -- 771
		7, -- 771
		math.floor((x1 - x0) / 10) -- 771
	) -- 771
	local span = (x1 - x0) / count -- 772
	local k = 0 -- 773
	do -- 773
		k = 0 -- 774
		while k < count do -- 774
			local bx = x0 + (k + 0.5) * span -- 775
			local lean = (k * 29 % 11 - 5) * 1.3 -- 776
			local sway = math.sin(self.animTime * 1.9 + bx * 0.06) * 2.8 + lean -- 777
			local tipH = h * (0.58 + k * 37 % 10 * 0.048) -- 778
			scene:addTri3D( -- 779
				vec3(bx - span * 0.42, y0, z), -- 780
				vec3(bx + span * 0.42, y0, z), -- 781
				vec3(bx + sway, y0 + tipH, z - 2), -- 782
				MAT_GRASS_BACK, -- 783
				{bucket = LP_BUCKET.PROP, sortBias = 0.1 + k * 0.005, edgeWidth = 0.45} -- 784
			) -- 784
			k = k + 1 -- 774
		end -- 774
	end -- 774
end -- 770
function ForestCreekScene.prototype.drawCreekWaterReflection(self, fgDraw, fgGlow, p, cam) -- 789
	local ox = p.ox -- 795
	if cam:sx(ox + 1230) > cam.viewW + 120 then -- 796
		return -- 797
	end -- 797
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 799
	local reflCenterX = ox + 1438 -- 800
	local r = 0 -- 803
	do -- 803
		r = 0 -- 804
		while r < 10 do -- 804
			local z = r < 4 and -34 + r * 6 or 32 + (r - 4) * 24 -- 805
			local wx = ox + 1295 + r * 32 + math.sin(self.ripplePhase * 0.75 + r * 1.4) * 14 -- 806
			local pL = projectWorld3D( -- 807
				wx - 26, -- 807
				-3, -- 807
				z, -- 807
				cam, -- 807
				self.proj -- 807
			) -- 807
			local pR = projectWorld3D( -- 808
				wx + 26, -- 808
				-3, -- 808
				z, -- 808
				cam, -- 808
				self.proj -- 808
			) -- 808
			fgGlow:drawSegment( -- 809
				Vec2(pL.x, pL.y), -- 809
				Vec2(pR.x, pR.y), -- 809
				1.1, -- 809
				Color(146, 178, 198, 72) -- 809
			) -- 809
			r = r + 1 -- 804
		end -- 804
	end -- 804
	local bands = 9 -- 813
	do -- 813
		r = 0 -- 814
		while r < bands do -- 814
			local frac = r / (bands - 1) -- 815
			local z = -34 + frac * 22 -- 816
			local drift = math.sin(self.ripplePhase * (1.25 + frac * 0.4) + r * 1.35) * (6 + frac * 9) -- 817
			local halfW = (18 - frac * 8) * (0.75 + 0.25 * math.cos(self.ripplePhase * 1.7 + r)) -- 818
			local wy = -4.5 + frac * 2.5 -- 819
			local pL = projectWorld3D( -- 820
				reflCenterX + drift - halfW, -- 820
				wy, -- 820
				z, -- 820
				cam, -- 820
				self.proj -- 820
			) -- 820
			local pR = projectWorld3D( -- 821
				reflCenterX + drift + halfW, -- 821
				wy, -- 821
				z, -- 821
				cam, -- 821
				self.proj -- 821
			) -- 821
			local a = (0.42 + 0.5 * (1 - frac)) * lampPulse -- 822
			fgDraw:drawSegment( -- 823
				Vec2(pL.x, pL.y), -- 823
				Vec2(pR.x, pR.y), -- 823
				2.1 - frac * 0.7, -- 823
				Color( -- 823
					242, -- 823
					198, -- 823
					118, -- 823
					math.floor(190 * a + 0.5) -- 823
				) -- 823
			) -- 823
			fgGlow:drawSegment( -- 824
				Vec2(pL.x, pL.y), -- 824
				Vec2(pR.x, pR.y), -- 824
				3.6 - frac * 1.1, -- 824
				Color( -- 824
					248, -- 824
					214, -- 824
					140, -- 824
					math.floor(135 * a + 0.5) -- 824
				) -- 824
			) -- 824
			r = r + 1 -- 814
		end -- 814
	end -- 814
	local poolP = projectWorld3D( -- 827
		reflCenterX + 22, -- 827
		0, -- 827
		56, -- 827
		cam, -- 827
		self.proj -- 827
	) -- 827
	fillRadialGlow( -- 828
		fgGlow, -- 829
		poolP.x, -- 830
		poolP.y, -- 831
		58 * lampPulse, -- 832
		18 * lampPulse, -- 833
		Color( -- 834
			246, -- 834
			206, -- 834
			128, -- 834
			math.floor(92 * lampPulse + 0.5) -- 834
		), -- 834
		Color(232, 174, 88, 0), -- 835
		16 -- 836
	) -- 836
end -- 789
function ForestCreekScene.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, _ctx) -- 841
	return true -- 847
end -- 841
function ForestCreekScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 851
	local p = ctx.p -- 857
	local cam = ctx.cam -- 858
	local px = cam:sx(p.player.x) -- 861
	local pTopY = cam:sy(p.player.y + p.player.h) -- 862
	local fDir = p.player.facing >= 0 and 1 or -1 -- 863
	local shY = pTopY - cam:len(16.5) -- 864
	fgDraw:drawSegment( -- 865
		Vec2( -- 866
			px - fDir * cam:len(7.5), -- 866
			shY - cam:len(4) -- 866
		), -- 866
		Vec2( -- 867
			px - fDir * cam:len(5.5), -- 867
			shY + cam:len(3.5) -- 867
		), -- 867
		1.3, -- 868
		Color(196, 212, 220, 145) -- 869
	) -- 869
	fgDraw:drawSegment( -- 871
		Vec2( -- 872
			px - fDir * cam:len(5.5), -- 872
			shY + cam:len(3.5) -- 872
		), -- 872
		Vec2( -- 873
			px + fDir * cam:len(3.5), -- 873
			shY + cam:len(5.2) -- 873
		), -- 873
		1.2, -- 874
		Color(206, 220, 228, 135) -- 875
	) -- 875
	if self.xiaomanListenTimer > 0 then -- 879
		local k = smoothstep(0, 0.12, self.xiaomanListenTimer) * clamp01(self.xiaomanListenTimer / 0.52) -- 880
		local earX = px + self.xiaomanListenDir * cam:len(8) -- 881
		local earY = pTopY - cam:len(10) -- 882
		local r1 = cam:len(6.5 + (1 - k) * 8) -- 883
		local r2 = cam:len(11.5 + (1 - k) * 11) -- 884
		local startAng = self.xiaomanListenDir > 0 and -34 or 146 -- 885
		local endAng = self.xiaomanListenDir > 0 and 34 or 214 -- 886
		fgDraw:drawArc( -- 887
			Vec2(earX, earY), -- 887
			r1, -- 887
			startAng, -- 887
			endAng, -- 887
			1.3, -- 887
			Color( -- 887
				224, -- 887
				218, -- 887
				198, -- 887
				math.floor(185 * k + 0.5) -- 887
			) -- 887
		) -- 887
		fgGlow:drawArc( -- 888
			Vec2(earX, earY), -- 888
			r2, -- 888
			startAng, -- 888
			endAng, -- 888
			1.1, -- 888
			Color( -- 888
				204, -- 888
				218, -- 888
				224, -- 888
				math.floor(135 * k + 0.5) -- 888
			) -- 888
		) -- 888
	end -- 888
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 892
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 893
		local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 894
		local headX = cam:sx(p.dogX + f * 11) -- 895
		local headY = cam:sy(23.5) -- 896
		local earH = cam:len(alert and 7.6 or 4.8) -- 897
		local earCol = alert and Color(224, 222, 212, 220) or Color(176, 194, 202, 170) -- 898
		fgDraw:drawPolygon( -- 899
			{ -- 899
				Vec2(headX - f * 3.4, headY), -- 900
				Vec2(headX - f * 0.8, headY + earH), -- 901
				Vec2(headX + f * 2.4, headY + 0.8) -- 902
			}, -- 902
			Color(38, 36, 34, 235), -- 903
			1.1, -- 903
			earCol -- 903
		) -- 903
		if alert then -- 904
			local waveR = cam:len(8 + self.animTime * 20 % 13) -- 905
			fgGlow:drawArc( -- 906
				Vec2(headX, headY + earH * 0.75), -- 906
				waveR, -- 906
				42, -- 906
				138, -- 906
				1.2, -- 906
				Color(226, 208, 174, 145) -- 906
			) -- 906
		end -- 906
	end -- 906
	if ctx.paused then -- 911
		local pX = cam.viewW * (0.78 + self.creekReveal * 0.24) -- 912
		worldArt:tryPlace( -- 913
			"pine", -- 913
			"fe04_pause_creek_branch", -- 913
			pX, -- 913
			cam.viewH * 0.42, -- 913
			cam.viewW * 0.48, -- 913
			cam.viewH * 0.62, -- 913
			{ -- 913
				color = Color(14, 20, 22, 255), -- 914
				opacity = 0.9 * (1 - self.creekReveal * 0.7), -- 915
				layer = 5300 -- 916
			} -- 916
		) -- 916
	end -- 916
end -- 851
function ForestCreekScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 927
	local p = ctx.p -- 934
	local cam = ctx.cam -- 935
	local ox = p.ox -- 936
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 937
	local i = 0 -- 940
	do -- 940
		i = 0 -- 941
		while i < #p.room.solids do -- 941
			do -- 941
				local s = p.room.solids[i + 1] -- 942
				if s.passable ~= true then -- 943
					goto __continue66 -- 944
				end -- 944
				local blades = math.max( -- 946
					7, -- 946
					math.floor(s.w / 10) -- 946
				) -- 946
				local span = s.w / blades -- 947
				local k = 0 -- 948
				do -- 948
					k = 0 -- 949
					while k < blades do -- 949
						local bx = s.x + (k + 0.5) * span -- 950
						local lean = (k * 23 % 9 - 4) * 1.6 -- 951
						local sway = math.sin(self.animTime * 2.1 + bx * 0.06) * 2.6 + lean -- 952
						local tipH = math.min(18, s.h * (0.48 + k * 19 % 7 * 0.048)) -- 953
						local pL = projectWorld3D( -- 954
							bx - span * 0.36, -- 954
							s.y - 2, -- 954
							-18, -- 954
							cam, -- 954
							self.proj -- 954
						) -- 954
						local pR = projectWorld3D( -- 955
							bx + span * 0.36, -- 955
							s.y - 2, -- 955
							-18, -- 955
							cam, -- 955
							self.proj -- 955
						) -- 955
						local pT = projectWorld3D( -- 956
							bx + sway, -- 956
							s.y + tipH, -- 956
							-20, -- 956
							cam, -- 956
							self.proj -- 956
						) -- 956
						drawUiTri( -- 957
							uiDraw, -- 957
							pL, -- 957
							pR, -- 957
							pT, -- 957
							Color(11, 18, 17, 232), -- 957
							Color(14, 22, 20, 232), -- 957
							Color(32, 50, 44, 218), -- 957
							inv -- 957
						) -- 957
						k = k + 1 -- 949
					end -- 949
				end -- 949
			end -- 949
			::__continue66:: -- 949
			i = i + 1 -- 941
		end -- 941
	end -- 941
	local nearCreek = smoothstep(ox + 1060, ox + 1240, p.player.x) -- 963
	if nearCreek > 0.02 then -- 964
		local w = cam.viewW -- 965
		local h = cam.viewH -- 966
		local partShift = self.creekReveal * w * 0.38 -- 967
		local liftShift = self.creekReveal * h * 0.16 -- 968
		local canopyAlpha = math.floor(244 * nearCreek * (1 - self.creekReveal * 0.28) + 0.5) -- 969
		local cTrunk = Color(14, 18, 18, canopyAlpha) -- 970
		local cDark = Color(11, 20, 20, canopyAlpha) -- 971
		local cLeaf = Color( -- 972
			22, -- 972
			36, -- 972
			33, -- 972
			math.floor(canopyAlpha * 0.94 + 0.5) -- 972
		) -- 972
		local sway = math.sin(self.animTime * 1.45) * 5 -- 973
		drawUiQuad( -- 976
			uiDraw, -- 977
			{x = w * 0.56 + partShift + sway * 0.4, y = h * 0.67 + liftShift}, -- 978
			{x = w * 1.06 + partShift, y = h * 0.84 + liftShift}, -- 979
			{x = w * 1.06 + partShift, y = h * 0.96 + liftShift}, -- 980
			{x = w * 0.54 + partShift + sway * 0.4, y = h * 0.74 + liftShift}, -- 981
			cTrunk, -- 982
			cDark, -- 983
			inv -- 984
		) -- 984
		local clusters = { -- 987
			{ -- 988
				fx = 0.56, -- 988
				fy = 0.66, -- 988
				rw = 118, -- 988
				rh = 92, -- 988
				drop = 112 -- 988
			}, -- 988
			{ -- 989
				fx = 0.68, -- 989
				fy = 0.62, -- 989
				rw = 138, -- 989
				rh = 108, -- 989
				drop = 134 -- 989
			}, -- 989
			{ -- 990
				fx = 0.81, -- 990
				fy = 0.64, -- 990
				rw = 146, -- 990
				rh = 112, -- 990
				drop = 124 -- 990
			}, -- 990
			{ -- 991
				fx = 0.94, -- 991
				fy = 0.7, -- 991
				rw = 142, -- 991
				rh = 118, -- 991
				drop = 116 -- 991
			}, -- 991
			{ -- 992
				fx = 0.74, -- 992
				fy = 0.78, -- 992
				rw = 165, -- 992
				rh = 110, -- 992
				drop = 92 -- 992
			} -- 992
		} -- 992
		local ci = 0 -- 994
		do -- 994
			ci = 0 -- 995
			while ci < #clusters do -- 995
				local cl = clusters[ci + 1] -- 996
				local bx = w * cl.fx + partShift + sway * (0.5 + ci * 0.12) -- 997
				local by = h * cl.fy + liftShift -- 998
				drawUiTri( -- 999
					uiDraw, -- 1000
					{x = bx - cl.rw * 0.65, y = by + cl.rh * 0.85}, -- 1001
					{x = bx + cl.rw * 0.72, y = by + cl.rh * 0.62}, -- 1002
					{x = bx - cl.rw * 0.12 + sway * 0.6, y = by - cl.drop * 0.68}, -- 1003
					cDark, -- 1004
					cDark, -- 1005
					cLeaf, -- 1006
					inv -- 1007
				) -- 1007
				drawUiTri( -- 1009
					uiDraw, -- 1010
					{x = bx - cl.rw * 0.28, y = by + cl.rh * 0.92}, -- 1011
					{x = bx + cl.rw * 0.88, y = by + cl.rh * 0.82}, -- 1012
					{x = bx + cl.rw * 0.24 + sway * 0.8, y = by - cl.drop * 0.54}, -- 1013
					cDark, -- 1014
					cTrunk, -- 1015
					cLeaf, -- 1016
					inv -- 1017
				) -- 1017
				ci = ci + 1 -- 995
			end -- 995
		end -- 995
		local lShift = self.creekReveal * w * 0.22 -- 1022
		drawUiTri( -- 1023
			uiDraw, -- 1024
			{x = -30 - lShift, y = h + 16}, -- 1025
			{x = w * 0.3 - lShift, y = h + 16}, -- 1026
			{x = w * 0.12 - lShift - sway * 0.5, y = h * 0.68 + liftShift * 0.5}, -- 1027
			cDark, -- 1028
			cDark, -- 1029
			cLeaf, -- 1030
			inv -- 1031
		) -- 1031
	end -- 1031
	return false -- 1035
end -- 927
return ____exports -- 927
