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
local DIORAMA_TEX_CLIP = ____lowpoly.DIORAMA_TEX_CLIP -- 24
local FOREST_CREEK_LIGHT = ____lowpoly.FOREST_CREEK_LIGHT -- 25
local LP_BUCKET = ____lowpoly.LP_BUCKET -- 26
local LowpolyScene = ____lowpoly.LowpolyScene -- 29
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 30
local clamp01 = ____lowpoly.clamp01 -- 31
local projectWorld3D = ____lowpoly.projectWorld3D -- 32
local smoothstep = ____lowpoly.smoothstep -- 33
local vec3 = ____lowpoly.vec3 -- 34
local ____theme = require("Script.watch.fe.theme") -- 36
local fillRadialGlow = ____theme.fillRadialGlow -- 37
local fillVGradRect = ____theme.fillVGradRect -- 38
local lerpRGBA = ____theme.lerpRGBA -- 39
local rgba = ____theme.rgba -- 40
local toColor = ____theme.toColor -- 41
local CHILD_AUDIO_ROOT = "assets/audio/child/" -- 44
--- 林径枯枝集群位置（段内 X）
local TWIG_OFFSETS = {235, 455, 865, 1115} -- 47
local MAT_MOSS_GROUND = { -- 72
	base = rgba(44, 58, 52, 255), -- 73
	edge = rgba(108, 134, 122, 115), -- 74
	minShade = 0.28, -- 75
	rimBoost = 0.2, -- 76
	bottomAo = 0.32, -- 77
	texture = DIORAMA_TEX_CLIP .. "ming_stone", -- 78
	textureTint = rgba(132, 154, 142, 255), -- 79
	subdivX = 4, -- 80
	subdivY = 2 -- 81
} -- 81
local MAT_PINE_TRUNK = { -- 84
	base = rgba(46, 38, 34, 255), -- 85
	edge = rgba(98, 92, 86, 100), -- 86
	minShade = 0.24, -- 87
	rimBoost = 0.16, -- 88
	bottomAo = 0.38, -- 89
	texture = DIORAMA_TEX_CLIP .. "ming_timber", -- 90
	textureTint = rgba(126, 112, 102, 255), -- 91
	subdivX = 2, -- 92
	subdivY = 3 -- 93
} -- 93
local MAT_PINE_NEEDLE = { -- 96
	base = rgba(24, 42, 38, 255), -- 97
	edge = rgba(78, 108, 98, 105), -- 98
	minShade = 0.22, -- 99
	rimBoost = 0.18, -- 100
	bottomAo = 0.36 -- 101
} -- 101
local MAT_ROOT_ARCH = { -- 104
	base = rgba(58, 46, 38, 255), -- 105
	edge = rgba(146, 134, 116, 130), -- 106
	minShade = 0.26, -- 107
	rimBoost = 0.24, -- 108
	bottomAo = 0.34, -- 109
	texture = DIORAMA_TEX_CLIP .. "ming_timber", -- 110
	textureTint = rgba(146, 126, 108, 255), -- 111
	subdivX = 2, -- 112
	subdivY = 2 -- 113
} -- 113
local MAT_CANAL_STONE = { -- 116
	base = rgba(68, 78, 86, 255), -- 117
	edge = rgba(164, 186, 198, 145), -- 118
	minShade = 0.3, -- 119
	rimBoost = 0.28, -- 120
	bottomAo = 0.28, -- 121
	texture = DIORAMA_TEX_CLIP .. "ming_stone", -- 122
	textureTint = rgba(168, 184, 196, 255), -- 123
	subdivX = 2, -- 124
	subdivY = 2 -- 125
} -- 125
local MAT_GRASS_BACK = { -- 128
	base = rgba(36, 56, 50, 255), -- 129
	edge = rgba(96, 128, 116, 105), -- 130
	minShade = 0.28, -- 131
	rimBoost = 0.16, -- 132
	bottomAo = 0.32 -- 133
} -- 133
local MAT_CREEK_WATER = { -- 136
	base = rgba(24, 38, 48, 255), -- 137
	edge = rgba(120, 152, 168, 90), -- 138
	minShade = 0.44, -- 139
	rimBoost = 0.22, -- 140
	bottomAo = 0.1, -- 141
	texture = DIORAMA_TEX_CLIP .. "ming_water", -- 142
	textureTint = rgba(188, 212, 224, 255), -- 143
	subdivX = 6, -- 144
	subdivY = 3 -- 145
} -- 145
local MAT_TWIG = { -- 148
	base = rgba(114, 92, 68, 255), -- 149
	edge = rgba(188, 166, 134, 190), -- 150
	minShade = 0.3, -- 151
	rimBoost = 0.26, -- 152
	bottomAo = 0.2 -- 153
} -- 153
local function drawUiTri(uiDraw, p0, p1, p2, c0, c1, c2, invScale) -- 156
	uiDraw:drawVertices({ -- 166
		{ -- 167
			Vec2(p0.x * invScale, p0.y * invScale), -- 167
			c0 -- 167
		}, -- 167
		{ -- 168
			Vec2(p1.x * invScale, p1.y * invScale), -- 168
			c1 -- 168
		}, -- 168
		{ -- 169
			Vec2(p2.x * invScale, p2.y * invScale), -- 169
			c2 -- 169
		} -- 169
	}) -- 169
end -- 156
local function drawUiQuad(uiDraw, p0, p1, p2, p3, cBot, cTop, invScale) -- 173
	local v0 = Vec2(p0.x * invScale, p0.y * invScale) -- 183
	local v1 = Vec2(p1.x * invScale, p1.y * invScale) -- 184
	local v2 = Vec2(p2.x * invScale, p2.y * invScale) -- 185
	local v3 = Vec2(p3.x * invScale, p3.y * invScale) -- 186
	uiDraw:drawVertices({{v0, cBot}, {v1, cBot}, {v2, cTop}}) -- 187
	uiDraw:drawVertices({{v0, cBot}, {v2, cTop}, {v3, cTop}}) -- 192
end -- 173
____exports.ForestCreekScene = __TS__Class() -- 199
local ForestCreekScene = ____exports.ForestCreekScene -- 199
ForestCreekScene.name = "ForestCreekScene" -- 199
function ForestCreekScene.prototype.____constructor(self) -- 199
	self.animTime = 0 -- 200
	self.active = false -- 201
	self.ripplePhase = 0 -- 202
	self.creekReveal = 0 -- 203
	self.creekWaterVol = 0 -- 204
	self.twigSnapCount = 0 -- 206
	self.twigTriggered = {} -- 207
	self.xiaomanListenTimer = 0 -- 208
	self.xiaomanListenDir = 1 -- 209
	self.prevDogState = "patrol" -- 211
	self.dogAlertCount = 0 -- 212
	self.dogStepCount = 0 -- 213
	self.dogStepAccum = 0 -- 214
	self.prevDogX = 0 -- 215
	self.splinters = {} -- 217
	self.rng = 9417 -- 218
	self.proj = { -- 220
		morph = 1, -- 221
		focal = 405, -- 222
		vpFracX = 0.54, -- 223
		vpFracY = 0.5, -- 224
		vpOffsetX = 0, -- 225
		vpOffsetY = 0, -- 226
		baseDepth = 0 -- 227
	} -- 227
end -- 199
function ForestCreekScene.prototype.reset(self) -- 230
	self.animTime = 0 -- 231
	self.active = false -- 232
	self.ripplePhase = 0 -- 233
	self.creekReveal = 0 -- 234
	self.creekWaterVol = 0 -- 235
	self.twigSnapCount = 0 -- 236
	self.twigTriggered = {} -- 237
	self.xiaomanListenTimer = 0 -- 238
	self.xiaomanListenDir = 1 -- 239
	self.prevDogState = "patrol" -- 240
	self.dogAlertCount = 0 -- 241
	self.dogStepCount = 0 -- 242
	self.dogStepAccum = 0 -- 243
	self.prevDogX = 0 -- 244
	self.splinters = {} -- 245
end -- 230
function ForestCreekScene.prototype.rand(self) -- 248
	self.rng = (self.rng * 1664525 + 1013904223) % 4294967296 -- 249
	return self.rng / 4294967296 -- 250
end -- 248
function ForestCreekScene.prototype.getProjection(self) -- 253
	return self.proj -- 254
end -- 253
function ForestCreekScene.prototype.getDebugState(self, p) -- 257
	local px = p ~= nil and p.player.x or 0 -- 258
	local ox = p ~= nil and p.ox or 0 -- 259
	local reflectionVisible = self.active and px >= ox + 1140 -- 260
	local trueLampVisible = self.active and self.creekReveal >= 0.35 -- 261
	return { -- 262
		active = self.active, -- 263
		twigSnapCount = self.twigSnapCount, -- 264
		xiaomanListenTimer = self.xiaomanListenTimer, -- 265
		dogAlertCount = self.dogAlertCount, -- 266
		dogStepCount = self.dogStepCount, -- 267
		creekReveal = self.creekReveal, -- 268
		ripplePhase = self.ripplePhase, -- 269
		trueLampVisible = trueLampVisible, -- 270
		reflectionVisible = reflectionVisible, -- 271
		creekWaterVol = self.creekWaterVol -- 272
	} -- 272
end -- 257
function ForestCreekScene.prototype.update(self, ctx) -- 276
	local p = ctx.p -- 277
	self.active = true -- 278
	local ox = p.ox -- 279
	ctx.cam:setAnchorLock(nil) -- 282
	self.creekReveal = smoothstep(ox + 1310, ox + 1435, p.player.x) -- 285
	if not ctx.paused and ctx.worldDt > 0 then -- 285
		local dt = ctx.worldDt -- 288
		self.animTime = self.animTime + dt -- 289
		self.ripplePhase = self.ripplePhase + dt * 2.4 -- 291
		if self.xiaomanListenTimer > 0 then -- 291
			self.xiaomanListenTimer = math.max(0, self.xiaomanListenTimer - dt) -- 294
		end -- 294
		local movingFast = not p.player.crouch and (math.abs(p.player.vx) > 10 or not p.player.onGround) -- 298
		local i = 0 -- 299
		do -- 299
			i = 0 -- 300
			while i < #TWIG_OFFSETS do -- 300
				local tx = ox + TWIG_OFFSETS[i + 1] -- 301
				local lastSnapAt = self.twigTriggered[i] or -99 -- 302
				if movingFast and math.abs(p.player.x - tx) <= 18 and p.player.y <= 8 and self.animTime - lastSnapAt > 2.4 then -- 302
					self.twigTriggered[i] = self.animTime -- 304
					self:triggerTwigSnap(ctx, tx, p.dogX >= p.player.x and 1 or -1) -- 305
				end -- 305
				i = i + 1 -- 300
			end -- 300
		end -- 300
		if p.room.story ~= nil and p.room.story.dog ~= nil then -- 300
			if p.dogState == "ear" and self.prevDogState ~= "ear" then -- 300
				self.dogAlertCount = self.dogAlertCount + 1 -- 312
				self:triggerTwigSnap(ctx, p.player.x, p.dogX >= p.player.x and 1 or -1) -- 313
				ctx.audio:playOnce( -- 314
					(("fe04:forest:dog_alert:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogAlertCount), -- 315
					"sfx", -- 316
					CHILD_AUDIO_ROOT .. "dog_alert.wav", -- 317
					0.82, -- 318
					"fe04:forest:dog_alert", -- 319
					p.ticks, -- 320
					-1, -- 320
					{pan = ctx.audio:panForWorldX(p.dogX)} -- 322
				) -- 322
			elseif p.dogState == "chase" and self.prevDogState ~= "chase" then -- 322
				self.dogAlertCount = self.dogAlertCount + 1 -- 325
				local chasePath = Content:exist("assets/audio/foley/dog_chase_bark.wav") and "assets/audio/foley/dog_chase_bark.wav" or CHILD_AUDIO_ROOT .. "dog_alert.wav" -- 326
				ctx.audio:playOnce( -- 329
					(("fe04:forest:dog_chase:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogAlertCount), -- 330
					"sfx", -- 331
					chasePath, -- 332
					0.9, -- 333
					"fe04:forest:dog_chase", -- 334
					p.ticks, -- 335
					-1, -- 335
					{pan = ctx.audio:panForWorldX(p.dogX)} -- 337
				) -- 337
			end -- 337
			local dogDx = math.abs(p.dogX - self.prevDogX) -- 341
			if dogDx > 0.01 and (p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back") then -- 341
				self.dogStepAccum = self.dogStepAccum + dogDx -- 343
				local stepStride = p.dogState == "chase" and 28 or 42 -- 344
				if self.dogStepAccum >= stepStride then -- 344
					self.dogStepAccum = 0 -- 346
					local dist = math.abs(p.player.x - p.dogX) -- 347
					if dist < 420 then -- 347
						self.dogStepCount = self.dogStepCount + 1 -- 349
						local vol = 0.24 + 0.48 * clamp01(1 - dist / 420) -- 350
						ctx.audio:playOnce( -- 351
							(("fe04:forest:dog_step:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogStepCount), -- 352
							"sfx", -- 353
							CHILD_AUDIO_ROOT .. "dog_step.wav", -- 354
							vol, -- 355
							"fe04:forest:dog_step", -- 356
							p.ticks, -- 357
							-1, -- 357
							{pan = ctx.audio:panForWorldX(p.dogX)} -- 359
						) -- 359
					end -- 359
				end -- 359
			end -- 359
			self.prevDogX = p.dogX -- 364
			self.prevDogState = p.dogState -- 365
		end -- 365
		local w = 0 -- 369
		do -- 369
			i = 0 -- 370
			while i < #self.splinters do -- 370
				local sp = self.splinters[i + 1] -- 371
				sp.life = sp.life - dt -- 372
				if sp.life > 0 then -- 372
					sp.vy = sp.vy - 320 * dt -- 374
					sp.x = sp.x + sp.vx * dt -- 375
					sp.y = sp.y + sp.vy * dt -- 376
					if sp.y < 0 then -- 376
						sp.y = 0 -- 378
						sp.vy = 0 -- 379
						sp.vx = sp.vx * 0.4 -- 380
					end -- 380
					self.splinters[w + 1] = sp -- 382
					w = w + 1 -- 383
				end -- 383
				i = i + 1 -- 370
			end -- 370
		end -- 370
		__TS__ArraySetLength(self.splinters, w) -- 370
		local creekApproach = smoothstep(ox + 1140, ox + 1410, p.player.x) -- 389
		local windVol = 0.34 * (1 - creekApproach * 0.42) -- 390
		self.creekWaterVol = 0.02 + 0.54 * creekApproach -- 391
		ctx.audio:playLoop( -- 392
			"fe04_forest_wind", -- 392
			"wind", -- 392
			CHILD_AUDIO_ROOT .. "forest_wind_loop.wav", -- 392
			windVol, -- 392
			p.ticks -- 392
		) -- 392
		if creekApproach > 0.02 then -- 392
			ctx.audio:playLoop( -- 394
				"fe04_creek_water", -- 394
				"water", -- 394
				CHILD_AUDIO_ROOT .. "creek_loop.wav", -- 394
				self.creekWaterVol, -- 394
				p.ticks -- 394
			) -- 394
		else -- 394
			ctx.audio:stopLoop("fe04_creek_water", 0.25) -- 396
		end -- 396
	end -- 396
	self.proj = { -- 400
		morph = 1, -- 401
		focal = 405, -- 402
		vpFracX = 0.54, -- 403
		vpFracY = 0.5, -- 404
		vpOffsetX = math.sin(self.animTime * 0.55) * 1.8, -- 405
		vpOffsetY = math.cos(self.animTime * 0.72) * 1.2, -- 406
		baseDepth = 0 -- 407
	} -- 407
end -- 276
function ForestCreekScene.prototype.triggerTwigSnap(self, ctx, worldX, listenDir) -- 411
	self.twigSnapCount = self.twigSnapCount + 1 -- 412
	self.xiaomanListenTimer = 0.52 -- 413
	self.xiaomanListenDir = listenDir >= 0 and 1 or -1 -- 414
	ctx.audio:playOnce( -- 415
		(("fe04:forest:twig:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.twigSnapCount), -- 416
		"sfx", -- 417
		CHILD_AUDIO_ROOT .. "twig_snap.wav", -- 418
		0.84, -- 419
		"fe04:forest:twig_snap", -- 420
		ctx.p.ticks, -- 421
		-1, -- 421
		{pan = ctx.audio:panForWorldX(worldX)} -- 423
	) -- 423
	local i = 0 -- 425
	do -- 425
		i = 0 -- 426
		while i < 6 do -- 426
			local ang = (0.2 + self:rand() * 0.6) * math.pi -- 427
			local spd = 45 + self:rand() * 75 -- 428
			local ____self_splinters_0 = self.splinters -- 428
			____self_splinters_0[#____self_splinters_0 + 1] = { -- 429
				x = worldX + (self:rand() - 0.5) * 10, -- 430
				y = 2, -- 431
				vx = math.cos(ang) * spd * (self:rand() > 0.5 and 1 or -1), -- 432
				vy = math.sin(ang) * spd, -- 433
				len = 3.5 + self:rand() * 3.5, -- 434
				life = 0.38 + self:rand() * 0.22, -- 435
				maxLife = 0.6 -- 436
			} -- 436
			i = i + 1 -- 426
		end -- 426
	end -- 426
end -- 411
function ForestCreekScene.prototype.drawBackdrop(self, bgDraw, bgGlow, _backdropArt, ctx) -- 441
	local p = ctx.p -- 447
	local cam = ctx.cam -- 448
	local ox = p.ox -- 449
	local w = cam.viewW -- 450
	local h = cam.viewH -- 451
	local dawn = smoothstep(ox + 1120, ox + 1460, p.player.x) -- 454
	local skyTop = lerpRGBA( -- 455
		rgba(8, 14, 18, 255), -- 455
		rgba(16, 26, 38, 255), -- 455
		dawn -- 455
	) -- 455
	local skyMid = lerpRGBA( -- 456
		rgba(16, 28, 32, 255), -- 456
		rgba(32, 46, 62, 255), -- 456
		dawn -- 456
	) -- 456
	local skyHor = lerpRGBA( -- 457
		rgba(28, 44, 48, 255), -- 457
		rgba(62, 78, 94, 255), -- 457
		dawn -- 457
	) -- 457
	local splitY = h * 0.46 -- 458
	fillVGradRect( -- 459
		bgDraw, -- 459
		0, -- 459
		splitY, -- 459
		w, -- 459
		h - splitY, -- 459
		toColor(skyMid), -- 459
		toColor(skyTop) -- 459
	) -- 459
	fillVGradRect( -- 460
		bgDraw, -- 460
		0, -- 460
		0, -- 460
		w, -- 460
		splitY, -- 460
		toColor(skyHor), -- 460
		toColor(skyMid) -- 460
	) -- 460
	local scene = __TS__New(LowpolyScene, cam, self.proj, FOREST_CREEK_LIGHT) -- 462
	scene:addDistantRidge( -- 465
		{ -- 466
			{x = ox - 180, y = 128}, -- 467
			{x = ox + 220, y = 186}, -- 468
			{x = ox + 620, y = 152}, -- 469
			{x = ox + 1040, y = 204}, -- 470
			{x = ox + 1420, y = 168}, -- 471
			{x = ox + 1780, y = 196} -- 472
		}, -- 472
		-40, -- 472
		460, -- 475
		MING_MATERIALS.distantHill, -- 476
		{bucket = LP_BUCKET.BACKDROP} -- 477
	) -- 477
	local treeXs = { -- 481
		80, -- 481
		210, -- 481
		360, -- 481
		510, -- 481
		670, -- 481
		840, -- 481
		1010, -- 481
		1180, -- 481
		1290 -- 481
	} -- 481
	local i = 0 -- 482
	do -- 482
		i = 0 -- 483
		while i < #treeXs do -- 483
			local tx = ox + treeXs[i + 1] -- 484
			local tz = 185 + i % 3 * 42 -- 485
			local tw = 12 + i % 2 * 5 -- 486
			scene:addBox({ -- 487
				x0 = tx - tw * 0.5, -- 488
				x1 = tx + tw * 0.5, -- 489
				y0 = -20, -- 490
				y1 = 185 + i % 2 * 20, -- 491
				z0 = tz, -- 492
				z1 = tz + 16, -- 493
				material = MING_MATERIALS.distantWall, -- 494
				bucket = LP_BUCKET.BACKDROP, -- 495
				edgeWidth = 0 -- 496
			}) -- 496
			local lean = (i % 3 - 1) * 7 -- 499
			local baseH = 92 + i % 2 * 14 -- 500
			local tier = 0 -- 501
			do -- 501
				tier = 0 -- 502
				while tier < 3 do -- 502
					local ty0 = baseH + tier * 32 -- 503
					local ty1 = ty0 + 52 - tier * 6 -- 504
					local half = 50 - tier * 11 -- 505
					local colShift = tier * 4 -- 506
					scene:addTri3D( -- 507
						vec3(tx - half + lean * 0.4, ty0, tz - 4 - tier * 2), -- 508
						vec3(tx + half + lean * 0.4, ty0 + 4, tz - 4 - tier * 2), -- 509
						vec3(tx + lean, ty1, tz + 4), -- 510
						{base = rgba(18 + colShift, 30 + colShift, 32 + colShift, 255)}, -- 511
						{bucket = LP_BUCKET.BACKDROP, sortBias = 0.04 + tier * 0.01} -- 512
					) -- 512
					tier = tier + 1 -- 502
				end -- 502
			end -- 502
			i = i + 1 -- 483
		end -- 483
	end -- 483
	local towerX = ox + 1525 -- 518
	scene:addBox({ -- 519
		x0 = towerX - 24, -- 520
		x1 = towerX + 24, -- 521
		y0 = 44, -- 522
		y1 = 174, -- 523
		z0 = 332, -- 524
		z1 = 356, -- 525
		material = MING_MATERIALS.distantWall, -- 526
		bucket = LP_BUCKET.BACKDROP, -- 527
		sortBias = 0.12, -- 528
		edgeWidth = 0 -- 529
	}) -- 529
	scene:addTri3D( -- 532
		vec3(towerX - 34, 174, 330), -- 533
		vec3(towerX + 34, 174, 330), -- 534
		vec3(towerX, 200, 344), -- 535
		MING_MATERIALS.mingTile, -- 536
		{bucket = LP_BUCKET.BACKDROP, sortBias = 0.14} -- 537
	) -- 537
	scene:addFogBand( -- 541
		ox - 160, -- 541
		ox + 1780, -- 541
		-30, -- 541
		148, -- 541
		250, -- 541
		rgba(28, 42, 48, 255), -- 541
		0.62, -- 541
		0.06, -- 541
		{bucket = LP_BUCKET.BACKDROP} -- 541
	) -- 541
	scene:flush(bgDraw, bgGlow, ctx.dioramaBg) -- 545
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 548
	local lampPt = projectWorld3D( -- 549
		towerX - 4, -- 549
		146, -- 549
		330, -- 549
		cam, -- 549
		self.proj -- 549
	) -- 549
	fillRadialGlow( -- 550
		bgGlow, -- 551
		lampPt.x, -- 552
		lampPt.y, -- 553
		42 * lampPulse, -- 554
		42 * lampPulse, -- 555
		Color( -- 556
			246, -- 556
			208, -- 556
			134, -- 556
			math.floor(115 * lampPulse + 0.5) -- 556
		), -- 556
		Color(232, 176, 86, 0), -- 557
		16 -- 558
	) -- 558
	bgDraw:drawRect( -- 560
		Rect(lampPt.x - 3.5, lampPt.y - 5.5, 7, 11), -- 560
		Color(255, 232, 174, 240) -- 560
	) -- 560
	bgGlow:drawDot( -- 561
		Vec2(lampPt.x, lampPt.y), -- 561
		3.4, -- 561
		Color(255, 246, 218, 250) -- 561
	) -- 561
	return true -- 563
end -- 441
function ForestCreekScene.prototype.drawWorld(self, fgDraw, fgGlow, _worldArt, ctx) -- 566
	local p = ctx.p -- 572
	local cam = ctx.cam -- 573
	local ox = p.ox -- 574
	local scene = __TS__New(LowpolyScene, cam, self.proj, FOREST_CREEK_LIGHT) -- 575
	scene:addBox({ -- 578
		x0 = ox - 40, -- 579
		x1 = ox + 1190, -- 580
		y0 = -52, -- 581
		y1 = 0, -- 582
		z0 = -26, -- 583
		z1 = 92, -- 584
		material = MAT_MOSS_GROUND, -- 585
		bucket = LP_BUCKET.MIDGROUND, -- 586
		highlightTopEdge = true, -- 587
		edgeWidth = 0.7 -- 588
	}) -- 588
	scene:addBox({ -- 591
		x0 = ox + 1180, -- 592
		x1 = ox + 1620, -- 593
		y0 = -14, -- 594
		y1 = 0, -- 595
		z0 = -10, -- 596
		z1 = 24, -- 597
		material = MING_MATERIALS.mingStoneStep, -- 598
		bucket = LP_BUCKET.WALK_DECK, -- 599
		highlightTopEdge = true, -- 600
		edgeWidth = 0.9 -- 601
	}) -- 601
	scene:addWavingQuad3D( -- 604
		vec3(ox + 1170, -6, -44), -- 605
		vec3(ox + 1640, -6, -44), -- 606
		vec3(ox + 1640, -2, -10), -- 607
		vec3(ox + 1170, -2, -10), -- 608
		MAT_CREEK_WATER, -- 609
		{ -- 610
			ampX = 3.4, -- 610
			ampY = 1.4, -- 610
			phase = self.ripplePhase, -- 610
			freqU = 5.2, -- 610
			freqV = 3.1, -- 610
			pin = "none" -- 610
		}, -- 610
		{bucket = LP_BUCKET.WALK_DECK, sortBias = 0.08, subdivX = 6, subdivY = 3} -- 611
	) -- 611
	scene:addWavingQuad3D( -- 613
		vec3(ox + 1170, -2, 24), -- 614
		vec3(ox + 1660, -2, 24), -- 615
		vec3(ox + 1660, 4, 196), -- 616
		vec3(ox + 1170, 4, 196), -- 617
		MAT_CREEK_WATER, -- 618
		{ -- 619
			ampX = 4.2, -- 619
			ampY = 1.6, -- 619
			phase = self.ripplePhase * 0.88 + 1.2, -- 619
			freqU = 6.4, -- 619
			freqV = 3.6, -- 619
			pin = "none" -- 619
		}, -- 619
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.04, subdivX = 6, subdivY = 4} -- 620
	) -- 620
	local midTrunks = { -- 624
		150, -- 624
		415, -- 624
		650, -- 624
		910, -- 624
		1255 -- 624
	} -- 624
	local i = 0 -- 625
	do -- 625
		i = 0 -- 626
		while i < #midTrunks do -- 626
			local tx = ox + midTrunks[i + 1] -- 627
			local tz = 38 + i % 2 * 18 -- 628
			local halfW = 10 + i % 2 * 2 -- 629
			local topW = halfW * 0.62 -- 630
			scene:addQuad3D( -- 632
				vec3(tx - halfW, -10, tz), -- 633
				vec3(tx + halfW, -10, tz), -- 634
				vec3(tx + topW, 205, tz), -- 635
				vec3(tx - topW, 205, tz), -- 636
				MAT_PINE_TRUNK, -- 637
				{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.7} -- 638
			) -- 638
			local bDir = i % 2 == 0 and 1 or -1 -- 641
			scene:addTri3D( -- 642
				vec3(tx - topW * 0.5, 118, tz - 2), -- 643
				vec3(tx + bDir * 56, 108, tz - 4), -- 644
				vec3(tx + bDir * 12, 142, tz - 2), -- 645
				MAT_PINE_NEEDLE, -- 646
				{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.08, edgeWidth = 0.6} -- 647
			) -- 647
			scene:addTri3D( -- 649
				vec3(tx - bDir * 44, 146, tz - 2), -- 650
				vec3(tx + bDir * 48, 152, tz - 3), -- 651
				vec3(tx, 198, tz - 2), -- 652
				MAT_PINE_NEEDLE, -- 653
				{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.1, edgeWidth = 0.6} -- 654
			) -- 654
			i = i + 1 -- 626
		end -- 626
	end -- 626
	do -- 626
		i = 0 -- 659
		while i < #p.room.stairs do -- 659
			local st = p.room.stairs[i + 1] -- 660
			scene:addBox({ -- 661
				x0 = st.x0, -- 662
				x1 = st.x1, -- 663
				y0 = 0, -- 664
				y1 = st.y1, -- 665
				z0 = -14, -- 666
				z1 = 42, -- 667
				material = i == 1 and MAT_ROOT_ARCH or MING_MATERIALS.mingStoneStep, -- 668
				bucket = LP_BUCKET.WALK_DECK, -- 669
				highlightTopEdge = true, -- 670
				edgeWidth = 0.9 -- 671
			}) -- 671
			i = i + 1 -- 659
		end -- 659
	end -- 659
	scene:addTri3D( -- 677
		vec3(ox + 286, 0, 12), -- 678
		vec3(ox + 318, 12, 12), -- 679
		vec3(ox + 306, 76, 22), -- 680
		MAT_ROOT_ARCH, -- 681
		{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.9} -- 682
	) -- 682
	scene:addTri3D( -- 684
		vec3(ox + 372, 12, 12), -- 685
		vec3(ox + 412, 0, 12), -- 686
		vec3(ox + 382, 78, 22), -- 687
		MAT_ROOT_ARCH, -- 688
		{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.9} -- 689
	) -- 689
	scene:addQuad3D( -- 691
		vec3(ox + 298, 48, 14), -- 692
		vec3(ox + 394, 52, 14), -- 693
		vec3(ox + 384, 86, 36), -- 694
		vec3(ox + 306, 82, 36), -- 695
		MAT_ROOT_ARCH, -- 696
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.1, edgeWidth = 1} -- 697
	) -- 697
	scene:addQuad3D( -- 700
		vec3(ox + 306, 0, 34), -- 701
		vec3(ox + 382, 0, 34), -- 702
		vec3(ox + 376, 48, 34), -- 703
		vec3(ox + 312, 48, 34), -- 704
		{ -- 705
			base = rgba(10, 16, 18, 215), -- 705
			edge = rgba(164, 192, 188, 130) -- 705
		}, -- 705
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.05, edgeWidth = 1} -- 706
	) -- 706
	scene:addBox({ -- 709
		x0 = ox + 690, -- 710
		x1 = ox + 810, -- 711
		y0 = -10, -- 712
		y1 = 5, -- 713
		z0 = 26, -- 714
		z1 = 60, -- 715
		material = MAT_CANAL_STONE, -- 716
		bucket = LP_BUCKET.MIDGROUND, -- 717
		highlightTopEdge = true, -- 718
		edgeWidth = 0.9 -- 719
	}) -- 719
	scene:addQuad3D( -- 721
		vec3(ox + 706, 5, 28), -- 722
		vec3(ox + 742, 5, 28), -- 723
		vec3(ox + 736, 20, 44), -- 724
		vec3(ox + 700, 18, 44), -- 725
		MAT_CANAL_STONE, -- 726
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.22, edgeWidth = 1} -- 727
	) -- 727
	do -- 727
		i = 0 -- 731
		while i < #p.room.solids do -- 731
			local s = p.room.solids[i + 1] -- 732
			if s.passable == true then -- 732
				self:buildGrassCluster( -- 734
					scene, -- 734
					s.x, -- 734
					s.x + s.w, -- 734
					s.y, -- 734
					s.h, -- 734
					8 -- 734
				) -- 734
			elseif s.x >= ox + 1500 then -- 734
				scene:addBox({ -- 737
					x0 = s.x, -- 738
					x1 = s.x + s.w, -- 739
					y0 = s.y, -- 740
					y1 = s.y + s.h, -- 741
					z0 = 10, -- 742
					z1 = 72, -- 743
					material = MING_MATERIALS.mingBrickDark, -- 744
					bucket = LP_BUCKET.MIDGROUND, -- 745
					highlightTopEdge = true -- 746
				}) -- 746
			end -- 746
			i = i + 1 -- 731
		end -- 731
	end -- 731
	do -- 731
		i = 0 -- 752
		while i < #TWIG_OFFSETS do -- 752
			local tx = ox + TWIG_OFFSETS[i + 1] -- 753
			scene:addTri3D( -- 754
				vec3(tx - 12, 0.8, -5), -- 755
				vec3(tx + 12, 0.8, -3), -- 756
				vec3(tx + 3, 6.2, 2), -- 757
				MAT_TWIG, -- 758
				{bucket = LP_BUCKET.PROP, sortBias = 0.15, edgeWidth = 1} -- 759
			) -- 759
			scene:addTri3D( -- 761
				vec3(tx - 8, 0.8, 3), -- 762
				vec3(tx + 14, 0.8, 5), -- 763
				vec3(tx - 2, 5.2, -2), -- 764
				MAT_TWIG, -- 765
				{bucket = LP_BUCKET.PROP, sortBias = 0.16, edgeWidth = 0.9} -- 766
			) -- 766
			i = i + 1 -- 752
		end -- 752
	end -- 752
	scene:addContactShadow( -- 771
		p.player.x, -- 771
		p.player.y, -- 771
		14, -- 771
		10, -- 771
		0.8, -- 771
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 771
	) -- 771
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 771
		scene:addContactShadow( -- 773
			p.dogX, -- 773
			0, -- 773
			18, -- 773
			11, -- 773
			0.82, -- 773
			{bucket = LP_BUCKET.PROP, sortBias = 0.44} -- 773
		) -- 773
	end -- 773
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 776
	self:drawCreekWaterReflection(fgDraw, fgGlow, p, cam) -- 779
	do -- 779
		i = 0 -- 782
		while i < #self.splinters do -- 782
			local sp = self.splinters[i + 1] -- 783
			local a = clamp01(sp.life / sp.maxLife) -- 784
			local sx = cam:sx(sp.x) -- 785
			local sy = cam:sy(sp.y) -- 786
			fgDraw:drawSegment( -- 787
				Vec2(sx - sp.len, sy - 1), -- 787
				Vec2(sx + sp.len, sy + 2), -- 787
				1.3, -- 787
				Color( -- 787
					204, -- 787
					182, -- 787
					146, -- 787
					math.floor(235 * a + 0.5) -- 787
				) -- 787
			) -- 787
			i = i + 1 -- 782
		end -- 782
	end -- 782
	return true -- 790
end -- 566
function ForestCreekScene.prototype.buildGrassCluster(self, scene, x0, x1, y0, h, z) -- 793
	local count = math.max( -- 794
		7, -- 794
		math.floor((x1 - x0) / 10) -- 794
	) -- 794
	local span = (x1 - x0) / count -- 795
	local k = 0 -- 796
	do -- 796
		k = 0 -- 797
		while k < count do -- 797
			local bx = x0 + (k + 0.5) * span -- 798
			local lean = (k * 29 % 11 - 5) * 1.3 -- 799
			local sway = math.sin(self.animTime * 1.9 + bx * 0.06) * 2.8 + lean -- 800
			local tipH = h * (0.58 + k * 37 % 10 * 0.048) -- 801
			scene:addTri3D( -- 802
				vec3(bx - span * 0.42, y0, z), -- 803
				vec3(bx + span * 0.42, y0, z), -- 804
				vec3(bx + sway, y0 + tipH, z - 2), -- 805
				MAT_GRASS_BACK, -- 806
				{bucket = LP_BUCKET.PROP, sortBias = 0.1 + k * 0.005, edgeWidth = 0.45} -- 807
			) -- 807
			k = k + 1 -- 797
		end -- 797
	end -- 797
end -- 793
function ForestCreekScene.prototype.drawCreekWaterReflection(self, fgDraw, fgGlow, p, cam) -- 812
	local ox = p.ox -- 818
	if cam:sx(ox + 1230) > cam.viewW + 120 then -- 818
		return -- 820
	end -- 820
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 822
	local reflCenterX = ox + 1438 -- 823
	local r = 0 -- 826
	do -- 826
		r = 0 -- 827
		while r < 10 do -- 827
			local z = r < 4 and -34 + r * 6 or 32 + (r - 4) * 24 -- 828
			local wx = ox + 1295 + r * 32 + math.sin(self.ripplePhase * 0.75 + r * 1.4) * 14 -- 829
			local pL = projectWorld3D( -- 830
				wx - 26, -- 830
				-3, -- 830
				z, -- 830
				cam, -- 830
				self.proj -- 830
			) -- 830
			local pR = projectWorld3D( -- 831
				wx + 26, -- 831
				-3, -- 831
				z, -- 831
				cam, -- 831
				self.proj -- 831
			) -- 831
			fgGlow:drawSegment( -- 832
				Vec2(pL.x, pL.y), -- 832
				Vec2(pR.x, pR.y), -- 832
				1.1, -- 832
				Color(146, 178, 198, 72) -- 832
			) -- 832
			r = r + 1 -- 827
		end -- 827
	end -- 827
	local bands = 9 -- 836
	do -- 836
		r = 0 -- 837
		while r < bands do -- 837
			local frac = r / (bands - 1) -- 838
			local z = -34 + frac * 22 -- 839
			local drift = math.sin(self.ripplePhase * (1.25 + frac * 0.4) + r * 1.35) * (6 + frac * 9) -- 840
			local halfW = (18 - frac * 8) * (0.75 + 0.25 * math.cos(self.ripplePhase * 1.7 + r)) -- 841
			local wy = -4.5 + frac * 2.5 -- 842
			local pL = projectWorld3D( -- 843
				reflCenterX + drift - halfW, -- 843
				wy, -- 843
				z, -- 843
				cam, -- 843
				self.proj -- 843
			) -- 843
			local pR = projectWorld3D( -- 844
				reflCenterX + drift + halfW, -- 844
				wy, -- 844
				z, -- 844
				cam, -- 844
				self.proj -- 844
			) -- 844
			local a = (0.42 + 0.5 * (1 - frac)) * lampPulse -- 845
			fgDraw:drawSegment( -- 846
				Vec2(pL.x, pL.y), -- 846
				Vec2(pR.x, pR.y), -- 846
				2.1 - frac * 0.7, -- 846
				Color( -- 846
					242, -- 846
					198, -- 846
					118, -- 846
					math.floor(190 * a + 0.5) -- 846
				) -- 846
			) -- 846
			fgGlow:drawSegment( -- 847
				Vec2(pL.x, pL.y), -- 847
				Vec2(pR.x, pR.y), -- 847
				3.6 - frac * 1.1, -- 847
				Color( -- 847
					248, -- 847
					214, -- 847
					140, -- 847
					math.floor(135 * a + 0.5) -- 847
				) -- 847
			) -- 847
			r = r + 1 -- 837
		end -- 837
	end -- 837
	local poolP = projectWorld3D( -- 850
		reflCenterX + 22, -- 850
		0, -- 850
		56, -- 850
		cam, -- 850
		self.proj -- 850
	) -- 850
	fillRadialGlow( -- 851
		fgGlow, -- 852
		poolP.x, -- 853
		poolP.y, -- 854
		58 * lampPulse, -- 855
		18 * lampPulse, -- 856
		Color( -- 857
			246, -- 857
			206, -- 857
			128, -- 857
			math.floor(92 * lampPulse + 0.5) -- 857
		), -- 857
		Color(232, 174, 88, 0), -- 858
		16 -- 859
	) -- 859
end -- 812
function ForestCreekScene.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, _ctx) -- 864
	return true -- 870
end -- 864
function ForestCreekScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 874
	local p = ctx.p -- 880
	local cam = ctx.cam -- 881
	local px = cam:sx(p.player.x) -- 884
	local pTopY = cam:sy(p.player.y + p.player.h) -- 885
	local fDir = p.player.facing >= 0 and 1 or -1 -- 886
	local shY = pTopY - cam:len(16.5) -- 887
	fgDraw:drawSegment( -- 888
		Vec2( -- 889
			px - fDir * cam:len(7.5), -- 889
			shY - cam:len(4) -- 889
		), -- 889
		Vec2( -- 890
			px - fDir * cam:len(5.5), -- 890
			shY + cam:len(3.5) -- 890
		), -- 890
		1.3, -- 891
		Color(196, 212, 220, 145) -- 892
	) -- 892
	fgDraw:drawSegment( -- 894
		Vec2( -- 895
			px - fDir * cam:len(5.5), -- 895
			shY + cam:len(3.5) -- 895
		), -- 895
		Vec2( -- 896
			px + fDir * cam:len(3.5), -- 896
			shY + cam:len(5.2) -- 896
		), -- 896
		1.2, -- 897
		Color(206, 220, 228, 135) -- 898
	) -- 898
	if self.xiaomanListenTimer > 0 then -- 898
		local k = smoothstep(0, 0.12, self.xiaomanListenTimer) * clamp01(self.xiaomanListenTimer / 0.52) -- 903
		local earX = px + self.xiaomanListenDir * cam:len(8) -- 904
		local earY = pTopY - cam:len(10) -- 905
		local r1 = cam:len(6.5 + (1 - k) * 8) -- 906
		local r2 = cam:len(11.5 + (1 - k) * 11) -- 907
		local startAng = self.xiaomanListenDir > 0 and -34 or 146 -- 908
		local endAng = self.xiaomanListenDir > 0 and 34 or 214 -- 909
		fgDraw:drawArc( -- 910
			Vec2(earX, earY), -- 910
			r1, -- 910
			startAng, -- 910
			endAng, -- 910
			1.3, -- 910
			Color( -- 910
				224, -- 910
				218, -- 910
				198, -- 910
				math.floor(185 * k + 0.5) -- 910
			) -- 910
		) -- 910
		fgGlow:drawArc( -- 911
			Vec2(earX, earY), -- 911
			r2, -- 911
			startAng, -- 911
			endAng, -- 911
			1.1, -- 911
			Color( -- 911
				204, -- 911
				218, -- 911
				224, -- 911
				math.floor(135 * k + 0.5) -- 911
			) -- 911
		) -- 911
	end -- 911
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 911
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 916
		local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 917
		local headX = cam:sx(p.dogX + f * 11) -- 918
		local headY = cam:sy(23.5) -- 919
		local earH = cam:len(alert and 7.6 or 4.8) -- 920
		local earCol = alert and Color(224, 222, 212, 220) or Color(176, 194, 202, 170) -- 921
		fgDraw:drawPolygon( -- 922
			{ -- 922
				Vec2(headX - f * 3.4, headY), -- 923
				Vec2(headX - f * 0.8, headY + earH), -- 924
				Vec2(headX + f * 2.4, headY + 0.8) -- 925
			}, -- 925
			Color(38, 36, 34, 235), -- 926
			1.1, -- 926
			earCol -- 926
		) -- 926
		if alert then -- 926
			local waveR = cam:len(8 + self.animTime * 20 % 13) -- 928
			fgGlow:drawArc( -- 929
				Vec2(headX, headY + earH * 0.75), -- 929
				waveR, -- 929
				42, -- 929
				138, -- 929
				1.2, -- 929
				Color(226, 208, 174, 145) -- 929
			) -- 929
		end -- 929
	end -- 929
	if ctx.paused then -- 929
		local pX = cam.viewW * (0.78 + self.creekReveal * 0.24) -- 935
		worldArt:tryPlace( -- 936
			"pine", -- 936
			"fe04_pause_creek_branch", -- 936
			pX, -- 936
			cam.viewH * 0.42, -- 936
			cam.viewW * 0.48, -- 936
			cam.viewH * 0.62, -- 936
			{ -- 936
				color = Color(14, 20, 22, 255), -- 937
				opacity = 0.9 * (1 - self.creekReveal * 0.7), -- 938
				layer = 5300 -- 939
			} -- 939
		) -- 939
	end -- 939
end -- 874
function ForestCreekScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 950
	local p = ctx.p -- 957
	local cam = ctx.cam -- 958
	local ox = p.ox -- 959
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 960
	local i = 0 -- 963
	do -- 963
		i = 0 -- 964
		while i < #p.room.solids do -- 964
			do -- 964
				local s = p.room.solids[i + 1] -- 965
				if s.passable ~= true then -- 965
					goto __continue66 -- 967
				end -- 967
				local blades = math.max( -- 969
					7, -- 969
					math.floor(s.w / 10) -- 969
				) -- 969
				local span = s.w / blades -- 970
				local k = 0 -- 971
				do -- 971
					k = 0 -- 972
					while k < blades do -- 972
						local bx = s.x + (k + 0.5) * span -- 973
						local lean = (k * 23 % 9 - 4) * 1.6 -- 974
						local sway = math.sin(self.animTime * 2.1 + bx * 0.06) * 2.6 + lean -- 975
						local tipH = math.min(18, s.h * (0.48 + k * 19 % 7 * 0.048)) -- 976
						local pL = projectWorld3D( -- 977
							bx - span * 0.36, -- 977
							s.y - 2, -- 977
							-18, -- 977
							cam, -- 977
							self.proj -- 977
						) -- 977
						local pR = projectWorld3D( -- 978
							bx + span * 0.36, -- 978
							s.y - 2, -- 978
							-18, -- 978
							cam, -- 978
							self.proj -- 978
						) -- 978
						local pT = projectWorld3D( -- 979
							bx + sway, -- 979
							s.y + tipH, -- 979
							-20, -- 979
							cam, -- 979
							self.proj -- 979
						) -- 979
						drawUiTri( -- 980
							uiDraw, -- 980
							pL, -- 980
							pR, -- 980
							pT, -- 980
							Color(11, 18, 17, 232), -- 980
							Color(14, 22, 20, 232), -- 980
							Color(32, 50, 44, 218), -- 980
							inv -- 980
						) -- 980
						k = k + 1 -- 972
					end -- 972
				end -- 972
			end -- 972
			::__continue66:: -- 972
			i = i + 1 -- 964
		end -- 964
	end -- 964
	local nearCreek = smoothstep(ox + 1060, ox + 1240, p.player.x) -- 986
	if nearCreek > 0.02 then -- 986
		local w = cam.viewW -- 988
		local h = cam.viewH -- 989
		local partShift = self.creekReveal * w * 0.38 -- 990
		local liftShift = self.creekReveal * h * 0.16 -- 991
		local canopyAlpha = math.floor(244 * nearCreek * (1 - self.creekReveal * 0.28) + 0.5) -- 992
		local cTrunk = Color(14, 18, 18, canopyAlpha) -- 993
		local cDark = Color(11, 20, 20, canopyAlpha) -- 994
		local cLeaf = Color( -- 995
			22, -- 995
			36, -- 995
			33, -- 995
			math.floor(canopyAlpha * 0.94 + 0.5) -- 995
		) -- 995
		local sway = math.sin(self.animTime * 1.45) * 5 -- 996
		drawUiQuad( -- 999
			uiDraw, -- 1000
			{x = w * 0.56 + partShift + sway * 0.4, y = h * 0.67 + liftShift}, -- 1001
			{x = w * 1.06 + partShift, y = h * 0.84 + liftShift}, -- 1002
			{x = w * 1.06 + partShift, y = h * 0.96 + liftShift}, -- 1003
			{x = w * 0.54 + partShift + sway * 0.4, y = h * 0.74 + liftShift}, -- 1004
			cTrunk, -- 1005
			cDark, -- 1006
			inv -- 1007
		) -- 1007
		local clusters = { -- 1010
			{ -- 1011
				fx = 0.56, -- 1011
				fy = 0.66, -- 1011
				rw = 118, -- 1011
				rh = 92, -- 1011
				drop = 112 -- 1011
			}, -- 1011
			{ -- 1012
				fx = 0.68, -- 1012
				fy = 0.62, -- 1012
				rw = 138, -- 1012
				rh = 108, -- 1012
				drop = 134 -- 1012
			}, -- 1012
			{ -- 1013
				fx = 0.81, -- 1013
				fy = 0.64, -- 1013
				rw = 146, -- 1013
				rh = 112, -- 1013
				drop = 124 -- 1013
			}, -- 1013
			{ -- 1014
				fx = 0.94, -- 1014
				fy = 0.7, -- 1014
				rw = 142, -- 1014
				rh = 118, -- 1014
				drop = 116 -- 1014
			}, -- 1014
			{ -- 1015
				fx = 0.74, -- 1015
				fy = 0.78, -- 1015
				rw = 165, -- 1015
				rh = 110, -- 1015
				drop = 92 -- 1015
			} -- 1015
		} -- 1015
		local ci = 0 -- 1017
		do -- 1017
			ci = 0 -- 1018
			while ci < #clusters do -- 1018
				local cl = clusters[ci + 1] -- 1019
				local bx = w * cl.fx + partShift + sway * (0.5 + ci * 0.12) -- 1020
				local by = h * cl.fy + liftShift -- 1021
				drawUiTri( -- 1022
					uiDraw, -- 1023
					{x = bx - cl.rw * 0.65, y = by + cl.rh * 0.85}, -- 1024
					{x = bx + cl.rw * 0.72, y = by + cl.rh * 0.62}, -- 1025
					{x = bx - cl.rw * 0.12 + sway * 0.6, y = by - cl.drop * 0.68}, -- 1026
					cDark, -- 1027
					cDark, -- 1028
					cLeaf, -- 1029
					inv -- 1030
				) -- 1030
				drawUiTri( -- 1032
					uiDraw, -- 1033
					{x = bx - cl.rw * 0.28, y = by + cl.rh * 0.92}, -- 1034
					{x = bx + cl.rw * 0.88, y = by + cl.rh * 0.82}, -- 1035
					{x = bx + cl.rw * 0.24 + sway * 0.8, y = by - cl.drop * 0.54}, -- 1036
					cDark, -- 1037
					cTrunk, -- 1038
					cLeaf, -- 1039
					inv -- 1040
				) -- 1040
				ci = ci + 1 -- 1018
			end -- 1018
		end -- 1018
		local lShift = self.creekReveal * w * 0.22 -- 1045
		drawUiTri( -- 1046
			uiDraw, -- 1047
			{x = -30 - lShift, y = h + 16}, -- 1048
			{x = w * 0.3 - lShift, y = h + 16}, -- 1049
			{x = w * 0.12 - lShift - sway * 0.5, y = h * 0.68 + liftShift * 0.5}, -- 1050
			cDark, -- 1051
			cDark, -- 1052
			cLeaf, -- 1053
			inv -- 1054
		) -- 1054
	end -- 1054
	return false -- 1058
end -- 950
return ____exports -- 950