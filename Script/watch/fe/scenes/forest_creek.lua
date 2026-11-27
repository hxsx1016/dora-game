-- [ts]: forest_creek.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 18
local Color = ____Dora.Color -- 18
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
					p.ticks -- 299
				) -- 299
			elseif p.dogState == "chase" and self.prevDogState ~= "chase" then -- 301
				self.dogAlertCount = self.dogAlertCount + 1 -- 302
				ctx.audio:playOnce( -- 303
					(("fe04:forest:dog_chase:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogAlertCount), -- 304
					"sfx", -- 305
					CHILD_AUDIO_ROOT .. "dog_alert.wav", -- 306
					0.9, -- 307
					"fe04:forest:dog_chase", -- 308
					p.ticks -- 309
				) -- 309
			end -- 309
			local dogDx = math.abs(p.dogX - self.prevDogX) -- 313
			if dogDx > 0.01 and (p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back") then -- 314
				self.dogStepAccum = self.dogStepAccum + dogDx -- 315
				local stepStride = p.dogState == "chase" and 28 or 42 -- 316
				if self.dogStepAccum >= stepStride then -- 317
					self.dogStepAccum = 0 -- 318
					local dist = math.abs(p.player.x - p.dogX) -- 319
					if dist < 420 then -- 320
						self.dogStepCount = self.dogStepCount + 1 -- 321
						local vol = 0.24 + 0.48 * clamp01(1 - dist / 420) -- 322
						ctx.audio:playOnce( -- 323
							(("fe04:forest:dog_step:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogStepCount), -- 324
							"sfx", -- 325
							CHILD_AUDIO_ROOT .. "dog_step.wav", -- 326
							vol, -- 327
							"fe04:forest:dog_step", -- 328
							p.ticks -- 329
						) -- 329
					end -- 329
				end -- 329
			end -- 329
			self.prevDogX = p.dogX -- 334
			self.prevDogState = p.dogState -- 335
		end -- 335
		local w = 0 -- 339
		do -- 339
			i = 0 -- 340
			while i < #self.splinters do -- 340
				local sp = self.splinters[i + 1] -- 341
				sp.life = sp.life - dt -- 342
				if sp.life > 0 then -- 343
					sp.vy = sp.vy - 320 * dt -- 344
					sp.x = sp.x + sp.vx * dt -- 345
					sp.y = sp.y + sp.vy * dt -- 346
					if sp.y < 0 then -- 347
						sp.y = 0 -- 348
						sp.vy = 0 -- 349
						sp.vx = sp.vx * 0.4 -- 350
					end -- 350
					self.splinters[w + 1] = sp -- 352
					w = w + 1 -- 353
				end -- 353
				i = i + 1 -- 340
			end -- 340
		end -- 340
		__TS__ArraySetLength(self.splinters, w) -- 356
		local creekApproach = smoothstep(ox + 1140, ox + 1410, p.player.x) -- 359
		local windVol = 0.34 * (1 - creekApproach * 0.42) -- 360
		self.creekWaterVol = 0.02 + 0.54 * creekApproach -- 361
		ctx.audio:playLoop( -- 362
			"fe04_forest_wind", -- 362
			"wind", -- 362
			CHILD_AUDIO_ROOT .. "forest_wind_loop.wav", -- 362
			windVol, -- 362
			p.ticks -- 362
		) -- 362
		if creekApproach > 0.02 then -- 363
			ctx.audio:playLoop( -- 364
				"fe04_creek_water", -- 364
				"water", -- 364
				CHILD_AUDIO_ROOT .. "creek_loop.wav", -- 364
				self.creekWaterVol, -- 364
				p.ticks -- 364
			) -- 364
		else -- 364
			ctx.audio:stopLoop("fe04_creek_water", 0.25) -- 366
		end -- 366
	end -- 366
	self.proj = { -- 370
		morph = 1, -- 371
		focal = 405, -- 372
		vpFracX = 0.54, -- 373
		vpFracY = 0.5, -- 374
		vpOffsetX = math.sin(self.animTime * 0.55) * 1.8, -- 375
		vpOffsetY = math.cos(self.animTime * 0.72) * 1.2, -- 376
		baseDepth = 0 -- 377
	} -- 377
end -- 255
function ForestCreekScene.prototype.triggerTwigSnap(self, ctx, worldX, listenDir) -- 381
	self.twigSnapCount = self.twigSnapCount + 1 -- 382
	self.xiaomanListenTimer = 0.52 -- 383
	self.xiaomanListenDir = listenDir >= 0 and 1 or -1 -- 384
	ctx.audio:playOnce( -- 385
		(("fe04:forest:twig:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.twigSnapCount), -- 386
		"sfx", -- 387
		CHILD_AUDIO_ROOT .. "twig_snap.wav", -- 388
		0.84, -- 389
		"fe04:forest:twig_snap", -- 390
		ctx.p.ticks -- 391
	) -- 391
	local i = 0 -- 393
	do -- 393
		i = 0 -- 394
		while i < 6 do -- 394
			local ang = (0.2 + self:rand() * 0.6) * math.pi -- 395
			local spd = 45 + self:rand() * 75 -- 396
			local ____self_splinters_0 = self.splinters -- 397
			____self_splinters_0[#____self_splinters_0 + 1] = { -- 397
				x = worldX + (self:rand() - 0.5) * 10, -- 398
				y = 2, -- 399
				vx = math.cos(ang) * spd * (self:rand() > 0.5 and 1 or -1), -- 400
				vy = math.sin(ang) * spd, -- 401
				len = 3.5 + self:rand() * 3.5, -- 402
				life = 0.38 + self:rand() * 0.22, -- 403
				maxLife = 0.6 -- 404
			} -- 404
			i = i + 1 -- 394
		end -- 394
	end -- 394
end -- 381
function ForestCreekScene.prototype.drawBackdrop(self, bgDraw, bgGlow, _backdropArt, ctx) -- 409
	local p = ctx.p -- 415
	local cam = ctx.cam -- 416
	local ox = p.ox -- 417
	local w = cam.viewW -- 418
	local h = cam.viewH -- 419
	local dawn = smoothstep(ox + 1120, ox + 1460, p.player.x) -- 422
	local skyTop = lerpRGBA( -- 423
		rgba(8, 14, 18, 255), -- 423
		rgba(16, 26, 38, 255), -- 423
		dawn -- 423
	) -- 423
	local skyMid = lerpRGBA( -- 424
		rgba(16, 28, 32, 255), -- 424
		rgba(32, 46, 62, 255), -- 424
		dawn -- 424
	) -- 424
	local skyHor = lerpRGBA( -- 425
		rgba(28, 44, 48, 255), -- 425
		rgba(62, 78, 94, 255), -- 425
		dawn -- 425
	) -- 425
	local splitY = h * 0.46 -- 426
	fillVGradRect( -- 427
		bgDraw, -- 427
		0, -- 427
		splitY, -- 427
		w, -- 427
		h - splitY, -- 427
		toColor(skyMid), -- 427
		toColor(skyTop) -- 427
	) -- 427
	fillVGradRect( -- 428
		bgDraw, -- 428
		0, -- 428
		0, -- 428
		w, -- 428
		splitY, -- 428
		toColor(skyHor), -- 428
		toColor(skyMid) -- 428
	) -- 428
	local scene = __TS__New(LowpolyScene, cam, self.proj, FOREST_CREEK_LIGHT) -- 430
	scene:addDistantRidge( -- 433
		{ -- 434
			{x = ox - 180, y = 128}, -- 435
			{x = ox + 220, y = 186}, -- 436
			{x = ox + 620, y = 152}, -- 437
			{x = ox + 1040, y = 204}, -- 438
			{x = ox + 1420, y = 168}, -- 439
			{x = ox + 1780, y = 196} -- 440
		}, -- 440
		-40, -- 442
		460, -- 443
		MING_MATERIALS.distantHill, -- 444
		{bucket = LP_BUCKET.BACKDROP} -- 445
	) -- 445
	local treeXs = { -- 449
		80, -- 449
		210, -- 449
		360, -- 449
		510, -- 449
		670, -- 449
		840, -- 449
		1010, -- 449
		1180, -- 449
		1290 -- 449
	} -- 449
	local i = 0 -- 450
	do -- 450
		i = 0 -- 451
		while i < #treeXs do -- 451
			local tx = ox + treeXs[i + 1] -- 452
			local tz = 185 + i % 3 * 42 -- 453
			local tw = 12 + i % 2 * 5 -- 454
			scene:addBox({ -- 455
				x0 = tx - tw * 0.5, -- 456
				x1 = tx + tw * 0.5, -- 457
				y0 = -20, -- 458
				y1 = 185 + i % 2 * 20, -- 459
				z0 = tz, -- 460
				z1 = tz + 16, -- 461
				material = MING_MATERIALS.distantWall, -- 462
				bucket = LP_BUCKET.BACKDROP, -- 463
				edgeWidth = 0 -- 464
			}) -- 464
			local lean = (i % 3 - 1) * 7 -- 467
			local baseH = 92 + i % 2 * 14 -- 468
			local tier = 0 -- 469
			do -- 469
				tier = 0 -- 470
				while tier < 3 do -- 470
					local ty0 = baseH + tier * 32 -- 471
					local ty1 = ty0 + 52 - tier * 6 -- 472
					local half = 50 - tier * 11 -- 473
					local colShift = tier * 4 -- 474
					scene:addTri3D( -- 475
						vec3(tx - half + lean * 0.4, ty0, tz - 4 - tier * 2), -- 476
						vec3(tx + half + lean * 0.4, ty0 + 4, tz - 4 - tier * 2), -- 477
						vec3(tx + lean, ty1, tz + 4), -- 478
						{base = rgba(18 + colShift, 30 + colShift, 32 + colShift, 255)}, -- 479
						{bucket = LP_BUCKET.BACKDROP, sortBias = 0.04 + tier * 0.01} -- 480
					) -- 480
					tier = tier + 1 -- 470
				end -- 470
			end -- 470
			i = i + 1 -- 451
		end -- 451
	end -- 451
	local towerX = ox + 1525 -- 486
	scene:addBox({ -- 487
		x0 = towerX - 24, -- 488
		x1 = towerX + 24, -- 489
		y0 = 44, -- 490
		y1 = 174, -- 491
		z0 = 332, -- 492
		z1 = 356, -- 493
		material = MING_MATERIALS.distantWall, -- 494
		bucket = LP_BUCKET.BACKDROP, -- 495
		sortBias = 0.12, -- 496
		edgeWidth = 0 -- 497
	}) -- 497
	scene:addTri3D( -- 500
		vec3(towerX - 34, 174, 330), -- 501
		vec3(towerX + 34, 174, 330), -- 502
		vec3(towerX, 200, 344), -- 503
		MING_MATERIALS.mingTile, -- 504
		{bucket = LP_BUCKET.BACKDROP, sortBias = 0.14} -- 505
	) -- 505
	scene:addFogBand( -- 509
		ox - 160, -- 509
		ox + 1780, -- 509
		-30, -- 509
		148, -- 509
		250, -- 509
		rgba(28, 42, 48, 255), -- 509
		0.62, -- 509
		0.06, -- 509
		{bucket = LP_BUCKET.BACKDROP} -- 509
	) -- 509
	scene:flush(bgDraw, bgGlow) -- 513
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 516
	local lampPt = projectWorld3D( -- 517
		towerX - 4, -- 517
		146, -- 517
		330, -- 517
		cam, -- 517
		self.proj -- 517
	) -- 517
	fillRadialGlow( -- 518
		bgGlow, -- 519
		lampPt.x, -- 520
		lampPt.y, -- 521
		42 * lampPulse, -- 522
		42 * lampPulse, -- 523
		Color( -- 524
			246, -- 524
			208, -- 524
			134, -- 524
			math.floor(115 * lampPulse + 0.5) -- 524
		), -- 524
		Color(232, 176, 86, 0), -- 525
		16 -- 526
	) -- 526
	bgDraw:drawRect( -- 528
		Rect(lampPt.x - 3.5, lampPt.y - 5.5, 7, 11), -- 528
		Color(255, 232, 174, 240) -- 528
	) -- 528
	bgGlow:drawDot( -- 529
		Vec2(lampPt.x, lampPt.y), -- 529
		3.4, -- 529
		Color(255, 246, 218, 250) -- 529
	) -- 529
	return true -- 531
end -- 409
function ForestCreekScene.prototype.drawWorld(self, fgDraw, fgGlow, _worldArt, ctx) -- 534
	local p = ctx.p -- 540
	local cam = ctx.cam -- 541
	local ox = p.ox -- 542
	local scene = __TS__New(LowpolyScene, cam, self.proj, FOREST_CREEK_LIGHT) -- 543
	scene:addBox({ -- 546
		x0 = ox - 40, -- 547
		x1 = ox + 1190, -- 548
		y0 = -52, -- 549
		y1 = 0, -- 550
		z0 = -26, -- 551
		z1 = 92, -- 552
		material = MAT_MOSS_GROUND, -- 553
		bucket = LP_BUCKET.MIDGROUND, -- 554
		highlightTopEdge = true, -- 555
		edgeWidth = 0.7 -- 556
	}) -- 556
	scene:addBox({ -- 559
		x0 = ox + 1180, -- 560
		x1 = ox + 1620, -- 561
		y0 = -14, -- 562
		y1 = 0, -- 563
		z0 = -10, -- 564
		z1 = 24, -- 565
		material = MING_MATERIALS.mingStoneStep, -- 566
		bucket = LP_BUCKET.WALK_DECK, -- 567
		highlightTopEdge = true, -- 568
		edgeWidth = 0.9 -- 569
	}) -- 569
	scene:addQuad3D( -- 572
		vec3(ox + 1170, -6, -44), -- 573
		vec3(ox + 1640, -6, -44), -- 574
		vec3(ox + 1640, -2, -10), -- 575
		vec3(ox + 1170, -2, -10), -- 576
		MAT_CREEK_WATER, -- 577
		{bucket = LP_BUCKET.WALK_DECK, sortBias = 0.08, edgeWidth = 0} -- 578
	) -- 578
	scene:addQuad3D( -- 580
		vec3(ox + 1170, -2, 24), -- 581
		vec3(ox + 1660, -2, 24), -- 582
		vec3(ox + 1660, 4, 196), -- 583
		vec3(ox + 1170, 4, 196), -- 584
		MAT_CREEK_WATER, -- 585
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.04, edgeWidth = 0} -- 586
	) -- 586
	local midTrunks = { -- 590
		150, -- 590
		415, -- 590
		650, -- 590
		910, -- 590
		1255 -- 590
	} -- 590
	local i = 0 -- 591
	do -- 591
		i = 0 -- 592
		while i < #midTrunks do -- 592
			local tx = ox + midTrunks[i + 1] -- 593
			local tz = 38 + i % 2 * 18 -- 594
			local halfW = 10 + i % 2 * 2 -- 595
			local topW = halfW * 0.62 -- 596
			scene:addQuad3D( -- 598
				vec3(tx - halfW, -10, tz), -- 599
				vec3(tx + halfW, -10, tz), -- 600
				vec3(tx + topW, 205, tz), -- 601
				vec3(tx - topW, 205, tz), -- 602
				MAT_PINE_TRUNK, -- 603
				{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.7} -- 604
			) -- 604
			local bDir = i % 2 == 0 and 1 or -1 -- 607
			scene:addTri3D( -- 608
				vec3(tx - topW * 0.5, 118, tz - 2), -- 609
				vec3(tx + bDir * 56, 108, tz - 4), -- 610
				vec3(tx + bDir * 12, 142, tz - 2), -- 611
				MAT_PINE_NEEDLE, -- 612
				{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.08, edgeWidth = 0.6} -- 613
			) -- 613
			scene:addTri3D( -- 615
				vec3(tx - bDir * 44, 146, tz - 2), -- 616
				vec3(tx + bDir * 48, 152, tz - 3), -- 617
				vec3(tx, 198, tz - 2), -- 618
				MAT_PINE_NEEDLE, -- 619
				{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.1, edgeWidth = 0.6} -- 620
			) -- 620
			i = i + 1 -- 592
		end -- 592
	end -- 592
	do -- 592
		i = 0 -- 625
		while i < #p.room.stairs do -- 625
			local st = p.room.stairs[i + 1] -- 626
			scene:addBox({ -- 627
				x0 = st.x0, -- 628
				x1 = st.x1, -- 629
				y0 = 0, -- 630
				y1 = st.y1, -- 631
				z0 = -14, -- 632
				z1 = 42, -- 633
				material = i == 1 and MAT_ROOT_ARCH or MING_MATERIALS.mingStoneStep, -- 634
				bucket = LP_BUCKET.WALK_DECK, -- 635
				highlightTopEdge = true, -- 636
				edgeWidth = 0.9 -- 637
			}) -- 637
			i = i + 1 -- 625
		end -- 625
	end -- 625
	scene:addTri3D( -- 643
		vec3(ox + 286, 0, 12), -- 644
		vec3(ox + 318, 12, 12), -- 645
		vec3(ox + 306, 76, 22), -- 646
		MAT_ROOT_ARCH, -- 647
		{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.9} -- 648
	) -- 648
	scene:addTri3D( -- 650
		vec3(ox + 372, 12, 12), -- 651
		vec3(ox + 412, 0, 12), -- 652
		vec3(ox + 382, 78, 22), -- 653
		MAT_ROOT_ARCH, -- 654
		{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.9} -- 655
	) -- 655
	scene:addQuad3D( -- 657
		vec3(ox + 298, 48, 14), -- 658
		vec3(ox + 394, 52, 14), -- 659
		vec3(ox + 384, 86, 36), -- 660
		vec3(ox + 306, 82, 36), -- 661
		MAT_ROOT_ARCH, -- 662
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.1, edgeWidth = 1} -- 663
	) -- 663
	scene:addQuad3D( -- 666
		vec3(ox + 306, 0, 34), -- 667
		vec3(ox + 382, 0, 34), -- 668
		vec3(ox + 376, 48, 34), -- 669
		vec3(ox + 312, 48, 34), -- 670
		{ -- 671
			base = rgba(10, 16, 18, 215), -- 671
			edge = rgba(164, 192, 188, 130) -- 671
		}, -- 671
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.05, edgeWidth = 1} -- 672
	) -- 672
	scene:addBox({ -- 675
		x0 = ox + 690, -- 676
		x1 = ox + 810, -- 677
		y0 = -10, -- 678
		y1 = 5, -- 679
		z0 = 26, -- 680
		z1 = 60, -- 681
		material = MAT_CANAL_STONE, -- 682
		bucket = LP_BUCKET.MIDGROUND, -- 683
		highlightTopEdge = true, -- 684
		edgeWidth = 0.9 -- 685
	}) -- 685
	scene:addQuad3D( -- 687
		vec3(ox + 706, 5, 28), -- 688
		vec3(ox + 742, 5, 28), -- 689
		vec3(ox + 736, 20, 44), -- 690
		vec3(ox + 700, 18, 44), -- 691
		MAT_CANAL_STONE, -- 692
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.22, edgeWidth = 1} -- 693
	) -- 693
	do -- 693
		i = 0 -- 697
		while i < #p.room.solids do -- 697
			local s = p.room.solids[i + 1] -- 698
			if s.passable == true then -- 699
				self:buildGrassCluster( -- 700
					scene, -- 700
					s.x, -- 700
					s.x + s.w, -- 700
					s.y, -- 700
					s.h, -- 700
					8 -- 700
				) -- 700
			elseif s.x >= ox + 1500 then -- 701
				scene:addBox({ -- 703
					x0 = s.x, -- 704
					x1 = s.x + s.w, -- 705
					y0 = s.y, -- 706
					y1 = s.y + s.h, -- 707
					z0 = 10, -- 708
					z1 = 72, -- 709
					material = MING_MATERIALS.mingBrickDark, -- 710
					bucket = LP_BUCKET.MIDGROUND, -- 711
					highlightTopEdge = true -- 712
				}) -- 712
			end -- 712
			i = i + 1 -- 697
		end -- 697
	end -- 697
	do -- 697
		i = 0 -- 718
		while i < #TWIG_OFFSETS do -- 718
			local tx = ox + TWIG_OFFSETS[i + 1] -- 719
			scene:addTri3D( -- 720
				vec3(tx - 12, 0.8, -5), -- 721
				vec3(tx + 12, 0.8, -3), -- 722
				vec3(tx + 3, 6.2, 2), -- 723
				MAT_TWIG, -- 724
				{bucket = LP_BUCKET.PROP, sortBias = 0.15, edgeWidth = 1} -- 725
			) -- 725
			scene:addTri3D( -- 727
				vec3(tx - 8, 0.8, 3), -- 728
				vec3(tx + 14, 0.8, 5), -- 729
				vec3(tx - 2, 5.2, -2), -- 730
				MAT_TWIG, -- 731
				{bucket = LP_BUCKET.PROP, sortBias = 0.16, edgeWidth = 0.9} -- 732
			) -- 732
			i = i + 1 -- 718
		end -- 718
	end -- 718
	scene:addContactShadow( -- 737
		p.player.x, -- 737
		p.player.y, -- 737
		14, -- 737
		10, -- 737
		0.8, -- 737
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 737
	) -- 737
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 738
		scene:addContactShadow( -- 739
			p.dogX, -- 739
			0, -- 739
			18, -- 739
			11, -- 739
			0.82, -- 739
			{bucket = LP_BUCKET.PROP, sortBias = 0.44} -- 739
		) -- 739
	end -- 739
	scene:flush(fgDraw, fgGlow) -- 742
	self:drawCreekWaterReflection(fgDraw, fgGlow, p, cam) -- 745
	do -- 745
		i = 0 -- 748
		while i < #self.splinters do -- 748
			local sp = self.splinters[i + 1] -- 749
			local a = clamp01(sp.life / sp.maxLife) -- 750
			local sx = cam:sx(sp.x) -- 751
			local sy = cam:sy(sp.y) -- 752
			fgDraw:drawSegment( -- 753
				Vec2(sx - sp.len, sy - 1), -- 753
				Vec2(sx + sp.len, sy + 2), -- 753
				1.3, -- 753
				Color( -- 753
					204, -- 753
					182, -- 753
					146, -- 753
					math.floor(235 * a + 0.5) -- 753
				) -- 753
			) -- 753
			i = i + 1 -- 748
		end -- 748
	end -- 748
	return true -- 756
end -- 534
function ForestCreekScene.prototype.buildGrassCluster(self, scene, x0, x1, y0, h, z) -- 759
	local count = math.max( -- 760
		7, -- 760
		math.floor((x1 - x0) / 10) -- 760
	) -- 760
	local span = (x1 - x0) / count -- 761
	local k = 0 -- 762
	do -- 762
		k = 0 -- 763
		while k < count do -- 763
			local bx = x0 + (k + 0.5) * span -- 764
			local lean = (k * 29 % 11 - 5) * 1.3 -- 765
			local sway = math.sin(self.animTime * 1.9 + bx * 0.06) * 2.8 + lean -- 766
			local tipH = h * (0.58 + k * 37 % 10 * 0.048) -- 767
			scene:addTri3D( -- 768
				vec3(bx - span * 0.42, y0, z), -- 769
				vec3(bx + span * 0.42, y0, z), -- 770
				vec3(bx + sway, y0 + tipH, z - 2), -- 771
				MAT_GRASS_BACK, -- 772
				{bucket = LP_BUCKET.PROP, sortBias = 0.1 + k * 0.005, edgeWidth = 0.45} -- 773
			) -- 773
			k = k + 1 -- 763
		end -- 763
	end -- 763
end -- 759
function ForestCreekScene.prototype.drawCreekWaterReflection(self, fgDraw, fgGlow, p, cam) -- 778
	local ox = p.ox -- 784
	if cam:sx(ox + 1230) > cam.viewW + 120 then -- 785
		return -- 786
	end -- 786
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 788
	local reflCenterX = ox + 1438 -- 789
	local r = 0 -- 792
	do -- 792
		r = 0 -- 793
		while r < 10 do -- 793
			local z = r < 4 and -34 + r * 6 or 32 + (r - 4) * 24 -- 794
			local wx = ox + 1295 + r * 32 + math.sin(self.ripplePhase * 0.75 + r * 1.4) * 14 -- 795
			local pL = projectWorld3D( -- 796
				wx - 26, -- 796
				-3, -- 796
				z, -- 796
				cam, -- 796
				self.proj -- 796
			) -- 796
			local pR = projectWorld3D( -- 797
				wx + 26, -- 797
				-3, -- 797
				z, -- 797
				cam, -- 797
				self.proj -- 797
			) -- 797
			fgGlow:drawSegment( -- 798
				Vec2(pL.x, pL.y), -- 798
				Vec2(pR.x, pR.y), -- 798
				1.1, -- 798
				Color(146, 178, 198, 72) -- 798
			) -- 798
			r = r + 1 -- 793
		end -- 793
	end -- 793
	local bands = 9 -- 802
	do -- 802
		r = 0 -- 803
		while r < bands do -- 803
			local frac = r / (bands - 1) -- 804
			local z = -34 + frac * 22 -- 805
			local drift = math.sin(self.ripplePhase * (1.25 + frac * 0.4) + r * 1.35) * (6 + frac * 9) -- 806
			local halfW = (18 - frac * 8) * (0.75 + 0.25 * math.cos(self.ripplePhase * 1.7 + r)) -- 807
			local wy = -4.5 + frac * 2.5 -- 808
			local pL = projectWorld3D( -- 809
				reflCenterX + drift - halfW, -- 809
				wy, -- 809
				z, -- 809
				cam, -- 809
				self.proj -- 809
			) -- 809
			local pR = projectWorld3D( -- 810
				reflCenterX + drift + halfW, -- 810
				wy, -- 810
				z, -- 810
				cam, -- 810
				self.proj -- 810
			) -- 810
			local a = (0.42 + 0.5 * (1 - frac)) * lampPulse -- 811
			fgDraw:drawSegment( -- 812
				Vec2(pL.x, pL.y), -- 812
				Vec2(pR.x, pR.y), -- 812
				2.1 - frac * 0.7, -- 812
				Color( -- 812
					242, -- 812
					198, -- 812
					118, -- 812
					math.floor(190 * a + 0.5) -- 812
				) -- 812
			) -- 812
			fgGlow:drawSegment( -- 813
				Vec2(pL.x, pL.y), -- 813
				Vec2(pR.x, pR.y), -- 813
				3.6 - frac * 1.1, -- 813
				Color( -- 813
					248, -- 813
					214, -- 813
					140, -- 813
					math.floor(135 * a + 0.5) -- 813
				) -- 813
			) -- 813
			r = r + 1 -- 803
		end -- 803
	end -- 803
	local poolP = projectWorld3D( -- 816
		reflCenterX + 22, -- 816
		0, -- 816
		56, -- 816
		cam, -- 816
		self.proj -- 816
	) -- 816
	fillRadialGlow( -- 817
		fgGlow, -- 818
		poolP.x, -- 819
		poolP.y, -- 820
		58 * lampPulse, -- 821
		18 * lampPulse, -- 822
		Color( -- 823
			246, -- 823
			206, -- 823
			128, -- 823
			math.floor(92 * lampPulse + 0.5) -- 823
		), -- 823
		Color(232, 174, 88, 0), -- 824
		16 -- 825
	) -- 825
end -- 778
function ForestCreekScene.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, _ctx) -- 830
	return true -- 836
end -- 830
function ForestCreekScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 840
	local p = ctx.p -- 846
	local cam = ctx.cam -- 847
	local px = cam:sx(p.player.x) -- 850
	local pTopY = cam:sy(p.player.y + p.player.h) -- 851
	local fDir = p.player.facing >= 0 and 1 or -1 -- 852
	local shY = pTopY - cam:len(16.5) -- 853
	fgDraw:drawSegment( -- 854
		Vec2( -- 855
			px - fDir * cam:len(7.5), -- 855
			shY - cam:len(4) -- 855
		), -- 855
		Vec2( -- 856
			px - fDir * cam:len(5.5), -- 856
			shY + cam:len(3.5) -- 856
		), -- 856
		1.3, -- 857
		Color(196, 212, 220, 145) -- 858
	) -- 858
	fgDraw:drawSegment( -- 860
		Vec2( -- 861
			px - fDir * cam:len(5.5), -- 861
			shY + cam:len(3.5) -- 861
		), -- 861
		Vec2( -- 862
			px + fDir * cam:len(3.5), -- 862
			shY + cam:len(5.2) -- 862
		), -- 862
		1.2, -- 863
		Color(206, 220, 228, 135) -- 864
	) -- 864
	if self.xiaomanListenTimer > 0 then -- 868
		local k = smoothstep(0, 0.12, self.xiaomanListenTimer) * clamp01(self.xiaomanListenTimer / 0.52) -- 869
		local earX = px + self.xiaomanListenDir * cam:len(8) -- 870
		local earY = pTopY - cam:len(10) -- 871
		local r1 = cam:len(6.5 + (1 - k) * 8) -- 872
		local r2 = cam:len(11.5 + (1 - k) * 11) -- 873
		local startAng = self.xiaomanListenDir > 0 and -34 or 146 -- 874
		local endAng = self.xiaomanListenDir > 0 and 34 or 214 -- 875
		fgDraw:drawArc( -- 876
			Vec2(earX, earY), -- 876
			r1, -- 876
			startAng, -- 876
			endAng, -- 876
			1.3, -- 876
			Color( -- 876
				224, -- 876
				218, -- 876
				198, -- 876
				math.floor(185 * k + 0.5) -- 876
			) -- 876
		) -- 876
		fgGlow:drawArc( -- 877
			Vec2(earX, earY), -- 877
			r2, -- 877
			startAng, -- 877
			endAng, -- 877
			1.1, -- 877
			Color( -- 877
				204, -- 877
				218, -- 877
				224, -- 877
				math.floor(135 * k + 0.5) -- 877
			) -- 877
		) -- 877
	end -- 877
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 881
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 882
		local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 883
		local headX = cam:sx(p.dogX + f * 11) -- 884
		local headY = cam:sy(23.5) -- 885
		local earH = cam:len(alert and 7.6 or 4.8) -- 886
		local earCol = alert and Color(224, 222, 212, 220) or Color(176, 194, 202, 170) -- 887
		fgDraw:drawPolygon( -- 888
			{ -- 888
				Vec2(headX - f * 3.4, headY), -- 889
				Vec2(headX - f * 0.8, headY + earH), -- 890
				Vec2(headX + f * 2.4, headY + 0.8) -- 891
			}, -- 891
			Color(38, 36, 34, 235), -- 892
			1.1, -- 892
			earCol -- 892
		) -- 892
		if alert then -- 893
			local waveR = cam:len(8 + self.animTime * 20 % 13) -- 894
			fgGlow:drawArc( -- 895
				Vec2(headX, headY + earH * 0.75), -- 895
				waveR, -- 895
				42, -- 895
				138, -- 895
				1.2, -- 895
				Color(226, 208, 174, 145) -- 895
			) -- 895
		end -- 895
	end -- 895
	if ctx.paused then -- 900
		local pX = cam.viewW * (0.78 + self.creekReveal * 0.24) -- 901
		worldArt:tryPlace( -- 902
			"pine", -- 902
			"fe04_pause_creek_branch", -- 902
			pX, -- 902
			cam.viewH * 0.42, -- 902
			cam.viewW * 0.48, -- 902
			cam.viewH * 0.62, -- 902
			{ -- 902
				color = Color(14, 20, 22, 255), -- 903
				opacity = 0.9 * (1 - self.creekReveal * 0.7), -- 904
				layer = 5300 -- 905
			} -- 905
		) -- 905
	end -- 905
end -- 840
function ForestCreekScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 916
	local p = ctx.p -- 923
	local cam = ctx.cam -- 924
	local ox = p.ox -- 925
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 926
	local i = 0 -- 929
	do -- 929
		i = 0 -- 930
		while i < #p.room.solids do -- 930
			do -- 930
				local s = p.room.solids[i + 1] -- 931
				if s.passable ~= true then -- 932
					goto __continue66 -- 933
				end -- 933
				local blades = math.max( -- 935
					7, -- 935
					math.floor(s.w / 10) -- 935
				) -- 935
				local span = s.w / blades -- 936
				local k = 0 -- 937
				do -- 937
					k = 0 -- 938
					while k < blades do -- 938
						local bx = s.x + (k + 0.5) * span -- 939
						local lean = (k * 23 % 9 - 4) * 1.6 -- 940
						local sway = math.sin(self.animTime * 2.1 + bx * 0.06) * 2.6 + lean -- 941
						local tipH = math.min(18, s.h * (0.48 + k * 19 % 7 * 0.048)) -- 942
						local pL = projectWorld3D( -- 943
							bx - span * 0.36, -- 943
							s.y - 2, -- 943
							-18, -- 943
							cam, -- 943
							self.proj -- 943
						) -- 943
						local pR = projectWorld3D( -- 944
							bx + span * 0.36, -- 944
							s.y - 2, -- 944
							-18, -- 944
							cam, -- 944
							self.proj -- 944
						) -- 944
						local pT = projectWorld3D( -- 945
							bx + sway, -- 945
							s.y + tipH, -- 945
							-20, -- 945
							cam, -- 945
							self.proj -- 945
						) -- 945
						drawUiTri( -- 946
							uiDraw, -- 946
							pL, -- 946
							pR, -- 946
							pT, -- 946
							Color(11, 18, 17, 232), -- 946
							Color(14, 22, 20, 232), -- 946
							Color(32, 50, 44, 218), -- 946
							inv -- 946
						) -- 946
						k = k + 1 -- 938
					end -- 938
				end -- 938
			end -- 938
			::__continue66:: -- 938
			i = i + 1 -- 930
		end -- 930
	end -- 930
	local nearCreek = smoothstep(ox + 1060, ox + 1240, p.player.x) -- 952
	if nearCreek > 0.02 then -- 953
		local w = cam.viewW -- 954
		local h = cam.viewH -- 955
		local partShift = self.creekReveal * w * 0.38 -- 956
		local liftShift = self.creekReveal * h * 0.16 -- 957
		local canopyAlpha = math.floor(244 * nearCreek * (1 - self.creekReveal * 0.28) + 0.5) -- 958
		local cTrunk = Color(14, 18, 18, canopyAlpha) -- 959
		local cDark = Color(11, 20, 20, canopyAlpha) -- 960
		local cLeaf = Color( -- 961
			22, -- 961
			36, -- 961
			33, -- 961
			math.floor(canopyAlpha * 0.94 + 0.5) -- 961
		) -- 961
		local sway = math.sin(self.animTime * 1.45) * 5 -- 962
		drawUiQuad( -- 965
			uiDraw, -- 966
			{x = w * 0.56 + partShift + sway * 0.4, y = h * 0.67 + liftShift}, -- 967
			{x = w * 1.06 + partShift, y = h * 0.84 + liftShift}, -- 968
			{x = w * 1.06 + partShift, y = h * 0.96 + liftShift}, -- 969
			{x = w * 0.54 + partShift + sway * 0.4, y = h * 0.74 + liftShift}, -- 970
			cTrunk, -- 971
			cDark, -- 972
			inv -- 973
		) -- 973
		local clusters = { -- 976
			{ -- 977
				fx = 0.56, -- 977
				fy = 0.66, -- 977
				rw = 118, -- 977
				rh = 92, -- 977
				drop = 112 -- 977
			}, -- 977
			{ -- 978
				fx = 0.68, -- 978
				fy = 0.62, -- 978
				rw = 138, -- 978
				rh = 108, -- 978
				drop = 134 -- 978
			}, -- 978
			{ -- 979
				fx = 0.81, -- 979
				fy = 0.64, -- 979
				rw = 146, -- 979
				rh = 112, -- 979
				drop = 124 -- 979
			}, -- 979
			{ -- 980
				fx = 0.94, -- 980
				fy = 0.7, -- 980
				rw = 142, -- 980
				rh = 118, -- 980
				drop = 116 -- 980
			}, -- 980
			{ -- 981
				fx = 0.74, -- 981
				fy = 0.78, -- 981
				rw = 165, -- 981
				rh = 110, -- 981
				drop = 92 -- 981
			} -- 981
		} -- 981
		local ci = 0 -- 983
		do -- 983
			ci = 0 -- 984
			while ci < #clusters do -- 984
				local cl = clusters[ci + 1] -- 985
				local bx = w * cl.fx + partShift + sway * (0.5 + ci * 0.12) -- 986
				local by = h * cl.fy + liftShift -- 987
				drawUiTri( -- 988
					uiDraw, -- 989
					{x = bx - cl.rw * 0.65, y = by + cl.rh * 0.85}, -- 990
					{x = bx + cl.rw * 0.72, y = by + cl.rh * 0.62}, -- 991
					{x = bx - cl.rw * 0.12 + sway * 0.6, y = by - cl.drop * 0.68}, -- 992
					cDark, -- 993
					cDark, -- 994
					cLeaf, -- 995
					inv -- 996
				) -- 996
				drawUiTri( -- 998
					uiDraw, -- 999
					{x = bx - cl.rw * 0.28, y = by + cl.rh * 0.92}, -- 1000
					{x = bx + cl.rw * 0.88, y = by + cl.rh * 0.82}, -- 1001
					{x = bx + cl.rw * 0.24 + sway * 0.8, y = by - cl.drop * 0.54}, -- 1002
					cDark, -- 1003
					cTrunk, -- 1004
					cLeaf, -- 1005
					inv -- 1006
				) -- 1006
				ci = ci + 1 -- 984
			end -- 984
		end -- 984
		local lShift = self.creekReveal * w * 0.22 -- 1011
		drawUiTri( -- 1012
			uiDraw, -- 1013
			{x = -30 - lShift, y = h + 16}, -- 1014
			{x = w * 0.3 - lShift, y = h + 16}, -- 1015
			{x = w * 0.12 - lShift - sway * 0.5, y = h * 0.68 + liftShift * 0.5}, -- 1016
			cDark, -- 1017
			cDark, -- 1018
			cLeaf, -- 1019
			inv -- 1020
		) -- 1020
	end -- 1020
	return false -- 1024
end -- 916
return ____exports -- 916
