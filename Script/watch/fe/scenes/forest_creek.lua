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
			local useB = i % 2 == 1 -- 486
			local framePath = useB and "assets/art/diorama_cutouts.clip|pine_gnarled_b" or "assets/art/diorama_cutouts.clip|pine_gnarled_a" -- 487
			local treeH = 215 + i % 3 * 26 -- 490
			local treeW = useB and treeH * (308 / 364) or treeH * (400 / 310) -- 491
			local depthDim = math.max(0.45, 1 - (tz - 170) / 360) -- 492
			scene:addCutout3D( -- 493
				framePath, -- 493
				tx, -- 493
				-12, -- 493
				tz, -- 493
				treeW, -- 493
				treeH, -- 493
				{ -- 493
					bucket = LP_BUCKET.BACKDROP, -- 494
					facing = i % 3 == 0 and -1 or 1, -- 495
					anchorX = 0.5, -- 496
					anchorY = 0, -- 497
					color = rgba( -- 498
						math.floor(92 * depthDim + 18 + 0.5), -- 499
						math.floor(118 * depthDim + 24 + 0.5), -- 500
						math.floor(124 * depthDim + 28 + 0.5), -- 501
						255 -- 502
					), -- 502
					opacity = 0.92, -- 504
					sortBias = 0.04 + i % 3 * 0.01 -- 505
				} -- 505
			) -- 505
			i = i + 1 -- 483
		end -- 483
	end -- 483
	local towerX = ox + 1525 -- 510
	scene:addCutout3D( -- 511
		"assets/art/diorama_cutouts.clip|north_tower_distant", -- 512
		towerX, -- 513
		34, -- 514
		340, -- 515
		126, -- 516
		162, -- 517
		{ -- 518
			bucket = LP_BUCKET.BACKDROP, -- 519
			anchorX = 0.5, -- 520
			anchorY = 0, -- 521
			color = rgba(154, 174, 192, 255), -- 522
			opacity = 0.95, -- 523
			sortBias = 0.14 -- 524
		} -- 524
	) -- 524
	scene:addFogBand( -- 529
		ox - 160, -- 529
		ox + 1780, -- 529
		-30, -- 529
		148, -- 529
		250, -- 529
		rgba(28, 42, 48, 255), -- 529
		0.62, -- 529
		0.06, -- 529
		{bucket = LP_BUCKET.BACKDROP} -- 529
	) -- 529
	scene:flush(bgDraw, bgGlow, ctx.dioramaBg) -- 533
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 536
	local lampPt = projectWorld3D( -- 537
		towerX - 4, -- 537
		146, -- 537
		330, -- 537
		cam, -- 537
		self.proj -- 537
	) -- 537
	fillRadialGlow( -- 538
		bgGlow, -- 539
		lampPt.x, -- 540
		lampPt.y, -- 541
		42 * lampPulse, -- 542
		42 * lampPulse, -- 543
		Color( -- 544
			246, -- 544
			208, -- 544
			134, -- 544
			math.floor(115 * lampPulse + 0.5) -- 544
		), -- 544
		Color(232, 176, 86, 0), -- 545
		16 -- 546
	) -- 546
	bgDraw:drawRect( -- 548
		Rect(lampPt.x - 3.5, lampPt.y - 5.5, 7, 11), -- 548
		Color(255, 232, 174, 240) -- 548
	) -- 548
	bgGlow:drawDot( -- 549
		Vec2(lampPt.x, lampPt.y), -- 549
		3.4, -- 549
		Color(255, 246, 218, 250) -- 549
	) -- 549
	return true -- 551
end -- 441
function ForestCreekScene.prototype.drawWorld(self, fgDraw, fgGlow, _worldArt, ctx) -- 554
	local p = ctx.p -- 560
	local cam = ctx.cam -- 561
	local ox = p.ox -- 562
	local scene = __TS__New(LowpolyScene, cam, self.proj, FOREST_CREEK_LIGHT) -- 563
	scene:addBox({ -- 566
		x0 = ox - 40, -- 567
		x1 = ox + 1190, -- 568
		y0 = -52, -- 569
		y1 = 0, -- 570
		z0 = -26, -- 571
		z1 = 92, -- 572
		material = MAT_MOSS_GROUND, -- 573
		bucket = LP_BUCKET.MIDGROUND, -- 574
		highlightTopEdge = true, -- 575
		edgeWidth = 0.7 -- 576
	}) -- 576
	scene:addBox({ -- 579
		x0 = ox + 1180, -- 580
		x1 = ox + 1620, -- 581
		y0 = -14, -- 582
		y1 = 0, -- 583
		z0 = -10, -- 584
		z1 = 24, -- 585
		material = MING_MATERIALS.mingStoneStep, -- 586
		bucket = LP_BUCKET.WALK_DECK, -- 587
		highlightTopEdge = true, -- 588
		edgeWidth = 0.9 -- 589
	}) -- 589
	scene:addWavingQuad3D( -- 592
		vec3(ox + 1170, -6, -44), -- 593
		vec3(ox + 1640, -6, -44), -- 594
		vec3(ox + 1640, -2, -10), -- 595
		vec3(ox + 1170, -2, -10), -- 596
		MAT_CREEK_WATER, -- 597
		{ -- 598
			ampX = 3.4, -- 598
			ampY = 1.4, -- 598
			phase = self.ripplePhase, -- 598
			freqU = 5.2, -- 598
			freqV = 3.1, -- 598
			pin = "none" -- 598
		}, -- 598
		{bucket = LP_BUCKET.WALK_DECK, sortBias = 0.08, subdivX = 6, subdivY = 3} -- 599
	) -- 599
	scene:addWavingQuad3D( -- 601
		vec3(ox + 1170, -2, 24), -- 602
		vec3(ox + 1660, -2, 24), -- 603
		vec3(ox + 1660, 4, 196), -- 604
		vec3(ox + 1170, 4, 196), -- 605
		MAT_CREEK_WATER, -- 606
		{ -- 607
			ampX = 4.2, -- 607
			ampY = 1.6, -- 607
			phase = self.ripplePhase * 0.88 + 1.2, -- 607
			freqU = 6.4, -- 607
			freqV = 3.6, -- 607
			pin = "none" -- 607
		}, -- 607
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.04, subdivX = 6, subdivY = 4} -- 608
	) -- 608
	local midTrunks = { -- 612
		150, -- 612
		415, -- 612
		650, -- 612
		910, -- 612
		1255 -- 612
	} -- 612
	local i = 0 -- 613
	do -- 613
		i = 0 -- 614
		while i < #midTrunks do -- 614
			local tx = ox + midTrunks[i + 1] -- 615
			local tz = 42 + i % 2 * 18 -- 616
			local useB = i % 2 == 0 -- 617
			local framePath = useB and "assets/art/diorama_cutouts.clip|pine_gnarled_b" or "assets/art/diorama_cutouts.clip|pine_gnarled_a" -- 618
			local treeH = 228 + i % 2 * 24 -- 621
			local treeW = useB and treeH * (308 / 364) or treeH * (400 / 310) -- 622
			scene:addCutout3D( -- 623
				framePath, -- 623
				tx, -- 623
				-8, -- 623
				tz, -- 623
				treeW, -- 623
				treeH, -- 623
				{ -- 623
					bucket = LP_BUCKET.MIDGROUND, -- 624
					facing = i % 2 == 0 and 1 or -1, -- 625
					anchorX = 0.5, -- 626
					anchorY = 0, -- 627
					color = rgba(142, 164, 168, 255), -- 628
					opacity = 0.96, -- 629
					sortBias = 0.06 -- 630
				} -- 630
			) -- 630
			i = i + 1 -- 614
		end -- 614
	end -- 614
	do -- 614
		i = 0 -- 635
		while i < #p.room.stairs do -- 635
			local st = p.room.stairs[i + 1] -- 636
			scene:addBox({ -- 637
				x0 = st.x0, -- 638
				x1 = st.x1, -- 639
				y0 = 0, -- 640
				y1 = st.y1, -- 641
				z0 = -14, -- 642
				z1 = 42, -- 643
				material = i == 1 and MAT_ROOT_ARCH or MING_MATERIALS.mingStoneStep, -- 644
				bucket = LP_BUCKET.WALK_DECK, -- 645
				highlightTopEdge = true, -- 646
				edgeWidth = 0.9 -- 647
			}) -- 647
			i = i + 1 -- 635
		end -- 635
	end -- 635
	scene:addCutout3D( -- 653
		"assets/art/diorama_cutouts.clip|root_archway", -- 654
		ox + 348, -- 655
		-4, -- 655
		18, -- 657
		148, -- 658
		100, -- 659
		{ -- 660
			bucket = LP_BUCKET.MIDGROUND, -- 661
			anchorX = 0.5, -- 662
			anchorY = 0, -- 663
			color = rgba(176, 194, 186, 255), -- 664
			opacity = 0.98, -- 665
			sortBias = 0.14 -- 666
		} -- 666
	) -- 666
	scene:addBox({ -- 670
		x0 = ox + 690, -- 671
		x1 = ox + 810, -- 672
		y0 = -10, -- 673
		y1 = 5, -- 674
		z0 = 26, -- 675
		z1 = 60, -- 676
		material = MAT_CANAL_STONE, -- 677
		bucket = LP_BUCKET.MIDGROUND, -- 678
		highlightTopEdge = true, -- 679
		edgeWidth = 0.9 -- 680
	}) -- 680
	scene:addQuad3D( -- 682
		vec3(ox + 706, 5, 28), -- 683
		vec3(ox + 742, 5, 28), -- 684
		vec3(ox + 736, 20, 44), -- 685
		vec3(ox + 700, 18, 44), -- 686
		MAT_CANAL_STONE, -- 687
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.22, edgeWidth = 1} -- 688
	) -- 688
	do -- 688
		i = 0 -- 692
		while i < #p.room.solids do -- 692
			local s = p.room.solids[i + 1] -- 693
			if s.passable == true then -- 693
				self:buildGrassCluster( -- 695
					scene, -- 695
					s.x, -- 695
					s.x + s.w, -- 695
					s.y, -- 695
					s.h, -- 695
					8 -- 695
				) -- 695
			elseif s.x >= ox + 1500 then -- 695
				scene:addBox({ -- 698
					x0 = s.x, -- 699
					x1 = s.x + s.w, -- 700
					y0 = s.y, -- 701
					y1 = s.y + s.h, -- 702
					z0 = 10, -- 703
					z1 = 72, -- 704
					material = MING_MATERIALS.mingBrickDark, -- 705
					bucket = LP_BUCKET.MIDGROUND, -- 706
					highlightTopEdge = true -- 707
				}) -- 707
			end -- 707
			i = i + 1 -- 692
		end -- 692
	end -- 692
	do -- 692
		i = 0 -- 713
		while i < #TWIG_OFFSETS do -- 713
			local tx = ox + TWIG_OFFSETS[i + 1] -- 714
			scene:addTri3D( -- 715
				vec3(tx - 12, 0.8, -5), -- 716
				vec3(tx + 12, 0.8, -3), -- 717
				vec3(tx + 3, 6.2, 2), -- 718
				MAT_TWIG, -- 719
				{bucket = LP_BUCKET.PROP, sortBias = 0.15, edgeWidth = 1} -- 720
			) -- 720
			scene:addTri3D( -- 722
				vec3(tx - 8, 0.8, 3), -- 723
				vec3(tx + 14, 0.8, 5), -- 724
				vec3(tx - 2, 5.2, -2), -- 725
				MAT_TWIG, -- 726
				{bucket = LP_BUCKET.PROP, sortBias = 0.16, edgeWidth = 0.9} -- 727
			) -- 727
			i = i + 1 -- 713
		end -- 713
	end -- 713
	scene:addContactShadow( -- 732
		p.player.x, -- 732
		p.player.y, -- 732
		14, -- 732
		10, -- 732
		0.8, -- 732
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 732
	) -- 732
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 732
		scene:addContactShadow( -- 734
			p.dogX, -- 734
			0, -- 734
			18, -- 734
			11, -- 734
			0.82, -- 734
			{bucket = LP_BUCKET.PROP, sortBias = 0.44} -- 734
		) -- 734
	end -- 734
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 737
	self:drawCreekWaterReflection(fgDraw, fgGlow, p, cam) -- 740
	do -- 740
		i = 0 -- 743
		while i < #self.splinters do -- 743
			local sp = self.splinters[i + 1] -- 744
			local a = clamp01(sp.life / sp.maxLife) -- 745
			local sx = cam:sx(sp.x) -- 746
			local sy = cam:sy(sp.y) -- 747
			fgDraw:drawSegment( -- 748
				Vec2(sx - sp.len, sy - 1), -- 748
				Vec2(sx + sp.len, sy + 2), -- 748
				1.3, -- 748
				Color( -- 748
					204, -- 748
					182, -- 748
					146, -- 748
					math.floor(235 * a + 0.5) -- 748
				) -- 748
			) -- 748
			i = i + 1 -- 743
		end -- 743
	end -- 743
	return true -- 751
end -- 554
function ForestCreekScene.prototype.buildGrassCluster(self, scene, x0, x1, y0, h, z) -- 754
	local count = math.max( -- 755
		7, -- 755
		math.floor((x1 - x0) / 10) -- 755
	) -- 755
	local span = (x1 - x0) / count -- 756
	local k = 0 -- 757
	do -- 757
		k = 0 -- 758
		while k < count do -- 758
			local bx = x0 + (k + 0.5) * span -- 759
			local lean = (k * 29 % 11 - 5) * 1.3 -- 760
			local sway = math.sin(self.animTime * 1.9 + bx * 0.06) * 2.8 + lean -- 761
			local tipH = h * (0.58 + k * 37 % 10 * 0.048) -- 762
			scene:addTri3D( -- 763
				vec3(bx - span * 0.42, y0, z), -- 764
				vec3(bx + span * 0.42, y0, z), -- 765
				vec3(bx + sway, y0 + tipH, z - 2), -- 766
				MAT_GRASS_BACK, -- 767
				{bucket = LP_BUCKET.PROP, sortBias = 0.1 + k * 0.005, edgeWidth = 0.45} -- 768
			) -- 768
			k = k + 1 -- 758
		end -- 758
	end -- 758
end -- 754
function ForestCreekScene.prototype.drawCreekWaterReflection(self, fgDraw, fgGlow, p, cam) -- 773
	local ox = p.ox -- 779
	if cam:sx(ox + 1230) > cam.viewW + 120 then -- 779
		return -- 781
	end -- 781
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 783
	local reflCenterX = ox + 1438 -- 784
	local r = 0 -- 787
	do -- 787
		r = 0 -- 788
		while r < 10 do -- 788
			local z = r < 4 and -34 + r * 6 or 32 + (r - 4) * 24 -- 789
			local wx = ox + 1295 + r * 32 + math.sin(self.ripplePhase * 0.75 + r * 1.4) * 14 -- 790
			local pL = projectWorld3D( -- 791
				wx - 26, -- 791
				-3, -- 791
				z, -- 791
				cam, -- 791
				self.proj -- 791
			) -- 791
			local pR = projectWorld3D( -- 792
				wx + 26, -- 792
				-3, -- 792
				z, -- 792
				cam, -- 792
				self.proj -- 792
			) -- 792
			fgGlow:drawSegment( -- 793
				Vec2(pL.x, pL.y), -- 793
				Vec2(pR.x, pR.y), -- 793
				1.1, -- 793
				Color(146, 178, 198, 72) -- 793
			) -- 793
			r = r + 1 -- 788
		end -- 788
	end -- 788
	local bands = 9 -- 797
	do -- 797
		r = 0 -- 798
		while r < bands do -- 798
			local frac = r / (bands - 1) -- 799
			local z = -34 + frac * 22 -- 800
			local drift = math.sin(self.ripplePhase * (1.25 + frac * 0.4) + r * 1.35) * (6 + frac * 9) -- 801
			local halfW = (18 - frac * 8) * (0.75 + 0.25 * math.cos(self.ripplePhase * 1.7 + r)) -- 802
			local wy = -4.5 + frac * 2.5 -- 803
			local pL = projectWorld3D( -- 804
				reflCenterX + drift - halfW, -- 804
				wy, -- 804
				z, -- 804
				cam, -- 804
				self.proj -- 804
			) -- 804
			local pR = projectWorld3D( -- 805
				reflCenterX + drift + halfW, -- 805
				wy, -- 805
				z, -- 805
				cam, -- 805
				self.proj -- 805
			) -- 805
			local a = (0.42 + 0.5 * (1 - frac)) * lampPulse -- 806
			fgDraw:drawSegment( -- 807
				Vec2(pL.x, pL.y), -- 807
				Vec2(pR.x, pR.y), -- 807
				2.1 - frac * 0.7, -- 807
				Color( -- 807
					242, -- 807
					198, -- 807
					118, -- 807
					math.floor(190 * a + 0.5) -- 807
				) -- 807
			) -- 807
			fgGlow:drawSegment( -- 808
				Vec2(pL.x, pL.y), -- 808
				Vec2(pR.x, pR.y), -- 808
				3.6 - frac * 1.1, -- 808
				Color( -- 808
					248, -- 808
					214, -- 808
					140, -- 808
					math.floor(135 * a + 0.5) -- 808
				) -- 808
			) -- 808
			r = r + 1 -- 798
		end -- 798
	end -- 798
	local poolP = projectWorld3D( -- 811
		reflCenterX + 22, -- 811
		0, -- 811
		56, -- 811
		cam, -- 811
		self.proj -- 811
	) -- 811
	fillRadialGlow( -- 812
		fgGlow, -- 813
		poolP.x, -- 814
		poolP.y, -- 815
		58 * lampPulse, -- 816
		18 * lampPulse, -- 817
		Color( -- 818
			246, -- 818
			206, -- 818
			128, -- 818
			math.floor(92 * lampPulse + 0.5) -- 818
		), -- 818
		Color(232, 174, 88, 0), -- 819
		16 -- 820
	) -- 820
end -- 773
function ForestCreekScene.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, _ctx) -- 825
	return true -- 831
end -- 825
function ForestCreekScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 835
	local p = ctx.p -- 841
	local cam = ctx.cam -- 842
	local px = cam:sx(p.player.x) -- 845
	local pTopY = cam:sy(p.player.y + p.player.h) -- 846
	local fDir = p.player.facing >= 0 and 1 or -1 -- 847
	local shY = pTopY - cam:len(16.5) -- 848
	fgDraw:drawSegment( -- 849
		Vec2( -- 850
			px - fDir * cam:len(7.5), -- 850
			shY - cam:len(4) -- 850
		), -- 850
		Vec2( -- 851
			px - fDir * cam:len(5.5), -- 851
			shY + cam:len(3.5) -- 851
		), -- 851
		1.3, -- 852
		Color(196, 212, 220, 145) -- 853
	) -- 853
	fgDraw:drawSegment( -- 855
		Vec2( -- 856
			px - fDir * cam:len(5.5), -- 856
			shY + cam:len(3.5) -- 856
		), -- 856
		Vec2( -- 857
			px + fDir * cam:len(3.5), -- 857
			shY + cam:len(5.2) -- 857
		), -- 857
		1.2, -- 858
		Color(206, 220, 228, 135) -- 859
	) -- 859
	if self.xiaomanListenTimer > 0 then -- 859
		local k = smoothstep(0, 0.12, self.xiaomanListenTimer) * clamp01(self.xiaomanListenTimer / 0.52) -- 864
		local earX = px + self.xiaomanListenDir * cam:len(8) -- 865
		local earY = pTopY - cam:len(10) -- 866
		local r1 = cam:len(6.5 + (1 - k) * 8) -- 867
		local r2 = cam:len(11.5 + (1 - k) * 11) -- 868
		local startAng = self.xiaomanListenDir > 0 and -34 or 146 -- 869
		local endAng = self.xiaomanListenDir > 0 and 34 or 214 -- 870
		fgDraw:drawArc( -- 871
			Vec2(earX, earY), -- 871
			r1, -- 871
			startAng, -- 871
			endAng, -- 871
			1.3, -- 871
			Color( -- 871
				224, -- 871
				218, -- 871
				198, -- 871
				math.floor(185 * k + 0.5) -- 871
			) -- 871
		) -- 871
		fgGlow:drawArc( -- 872
			Vec2(earX, earY), -- 872
			r2, -- 872
			startAng, -- 872
			endAng, -- 872
			1.1, -- 872
			Color( -- 872
				204, -- 872
				218, -- 872
				224, -- 872
				math.floor(135 * k + 0.5) -- 872
			) -- 872
		) -- 872
	end -- 872
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 872
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 877
		local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 878
		local headX = cam:sx(p.dogX + f * 11) -- 879
		local headY = cam:sy(23.5) -- 880
		local earH = cam:len(alert and 7.6 or 4.8) -- 881
		local earCol = alert and Color(224, 222, 212, 220) or Color(176, 194, 202, 170) -- 882
		fgDraw:drawPolygon( -- 883
			{ -- 883
				Vec2(headX - f * 3.4, headY), -- 884
				Vec2(headX - f * 0.8, headY + earH), -- 885
				Vec2(headX + f * 2.4, headY + 0.8) -- 886
			}, -- 886
			Color(38, 36, 34, 235), -- 887
			1.1, -- 887
			earCol -- 887
		) -- 887
		if alert then -- 887
			local waveR = cam:len(8 + self.animTime * 20 % 13) -- 889
			fgGlow:drawArc( -- 890
				Vec2(headX, headY + earH * 0.75), -- 890
				waveR, -- 890
				42, -- 890
				138, -- 890
				1.2, -- 890
				Color(226, 208, 174, 145) -- 890
			) -- 890
		end -- 890
	end -- 890
	if ctx.paused then -- 890
		local pX = cam.viewW * (0.78 + self.creekReveal * 0.24) -- 896
		worldArt:tryPlace( -- 897
			"pine", -- 897
			"fe04_pause_creek_branch", -- 897
			pX, -- 897
			cam.viewH * 0.42, -- 897
			cam.viewW * 0.48, -- 897
			cam.viewH * 0.62, -- 897
			{ -- 897
				color = Color(14, 20, 22, 255), -- 898
				opacity = 0.9 * (1 - self.creekReveal * 0.7), -- 899
				layer = 5300 -- 900
			} -- 900
		) -- 900
	end -- 900
end -- 835
function ForestCreekScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, uiArt, _uiGlow, ctx) -- 911
	local p = ctx.p -- 918
	local cam = ctx.cam -- 919
	local ox = p.ox -- 920
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 921
	local i = 0 -- 924
	do -- 924
		i = 0 -- 925
		while i < #p.room.solids do -- 925
			do -- 925
				local s = p.room.solids[i + 1] -- 926
				if s.passable ~= true then -- 926
					goto __continue64 -- 928
				end -- 928
				local blades = math.max( -- 930
					7, -- 930
					math.floor(s.w / 10) -- 930
				) -- 930
				local span = s.w / blades -- 931
				local k = 0 -- 932
				do -- 932
					k = 0 -- 933
					while k < blades do -- 933
						local bx = s.x + (k + 0.5) * span -- 934
						local lean = (k * 23 % 9 - 4) * 1.6 -- 935
						local sway = math.sin(self.animTime * 2.1 + bx * 0.06) * 2.6 + lean -- 936
						local tipH = math.min(18, s.h * (0.48 + k * 19 % 7 * 0.048)) -- 937
						local pL = projectWorld3D( -- 938
							bx - span * 0.36, -- 938
							s.y - 2, -- 938
							-18, -- 938
							cam, -- 938
							self.proj -- 938
						) -- 938
						local pR = projectWorld3D( -- 939
							bx + span * 0.36, -- 939
							s.y - 2, -- 939
							-18, -- 939
							cam, -- 939
							self.proj -- 939
						) -- 939
						local pT = projectWorld3D( -- 940
							bx + sway, -- 940
							s.y + tipH, -- 940
							-20, -- 940
							cam, -- 940
							self.proj -- 940
						) -- 940
						drawUiTri( -- 941
							uiDraw, -- 941
							pL, -- 941
							pR, -- 941
							pT, -- 941
							Color(11, 18, 17, 232), -- 941
							Color(14, 22, 20, 232), -- 941
							Color(32, 50, 44, 218), -- 941
							inv -- 941
						) -- 941
						k = k + 1 -- 933
					end -- 933
				end -- 933
			end -- 933
			::__continue64:: -- 933
			i = i + 1 -- 925
		end -- 925
	end -- 925
	local nearCreek = smoothstep(ox + 1060, ox + 1240, p.player.x) -- 947
	if nearCreek > 0.02 then -- 947
		local uw = ctx.uiW -- 949
		local uh = ctx.uiH -- 950
		local partShift = self.creekReveal * uw * 0.4 -- 951
		local liftShift = self.creekReveal * uh * 0.18 -- 952
		local boughOp = clamp01(nearCreek * (1 - self.creekReveal * 0.34)) -- 953
		local sway = math.sin(self.animTime * 1.45) * 6 -- 954
		local boughTint = Color(34, 52, 50, 255) -- 955
		uiArt:tryPlacePath( -- 958
			"assets/art/diorama_cutouts.clip|fg_pine_bough", -- 959
			"forest_fg_bough_right_main", -- 960
			uw * 0.78 + partShift + sway * 0.5, -- 961
			uh * 0.78 + liftShift, -- 962
			uw * 0.56, -- 963
			uh * 0.46, -- 964
			{ -- 965
				anchorX = 0.5, -- 966
				anchorY = 0.5, -- 967
				facing = -1, -- 968
				angle = 4 + math.sin(self.animTime * 1.2) * 1.4, -- 969
				color = boughTint, -- 970
				opacity = 0.96 * boughOp, -- 971
				smooth = true, -- 972
				layer = 0 -- 973
			} -- 973
		) -- 973
		uiArt:tryPlacePath( -- 976
			"assets/art/diorama_cutouts.clip|fg_pine_bough", -- 977
			"forest_fg_bough_right_sub", -- 978
			uw * 0.94 + partShift * 0.85 + sway * 0.3, -- 979
			uh * 0.66 + liftShift * 0.8, -- 980
			uw * 0.42, -- 981
			uh * 0.34, -- 982
			{ -- 983
				anchorX = 0.5, -- 984
				anchorY = 0.5, -- 985
				facing = -1, -- 986
				angle = -8, -- 987
				color = Color(24, 38, 38, 255), -- 988
				opacity = 0.9 * boughOp, -- 989
				smooth = true, -- 990
				layer = 0 -- 991
			} -- 991
		) -- 991
		local lShift = self.creekReveal * uw * 0.24 -- 995
		uiArt:tryPlacePath( -- 996
			"assets/art/diorama_cutouts.clip|fg_pine_bough", -- 997
			"forest_fg_bough_left", -- 998
			uw * 0.16 - lShift - sway * 0.4, -- 999
			uh * 0.82 + liftShift * 0.55, -- 1000
			uw * 0.44, -- 1001
			uh * 0.36, -- 1002
			{ -- 1003
				anchorX = 0.5, -- 1004
				anchorY = 0.5, -- 1005
				facing = 1, -- 1006
				angle = -6 - math.sin(self.animTime * 1.1) * 1.2, -- 1007
				color = boughTint, -- 1008
				opacity = 0.88 * boughOp, -- 1009
				smooth = true, -- 1010
				layer = 0 -- 1011
			} -- 1011
		) -- 1011
	end -- 1011
	return false -- 1016
end -- 911
return ____exports -- 911