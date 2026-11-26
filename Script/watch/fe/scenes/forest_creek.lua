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
local MAT_ROOT_ARCH = { -- 87
	base = rgba(58, 46, 38, 255), -- 88
	edge = rgba(146, 134, 116, 170), -- 89
	minShade = 0.22, -- 90
	rimBoost = 0.24, -- 91
	bottomAo = 0.36 -- 92
} -- 92
local MAT_CANAL_STONE = { -- 95
	base = rgba(68, 78, 86, 255), -- 96
	edge = rgba(164, 186, 198, 190), -- 97
	minShade = 0.26, -- 98
	rimBoost = 0.28, -- 99
	bottomAo = 0.3 -- 100
} -- 100
local MAT_GRASS_BACK = { -- 103
	base = rgba(36, 56, 50, 255), -- 104
	edge = rgba(96, 128, 116, 135), -- 105
	minShade = 0.28, -- 106
	rimBoost = 0.16, -- 107
	bottomAo = 0.32 -- 108
} -- 108
local MAT_CREEK_WATER = { -- 111
	base = rgba(24, 38, 48, 255), -- 112
	edge = rgba(120, 152, 168, 110), -- 113
	minShade = 0.35, -- 114
	rimBoost = 0.22, -- 115
	bottomAo = 0.12 -- 116
} -- 116
local MAT_TWIG = { -- 119
	base = rgba(114, 92, 68, 255), -- 120
	edge = rgba(188, 166, 134, 190), -- 121
	minShade = 0.3, -- 122
	rimBoost = 0.26, -- 123
	bottomAo = 0.2 -- 124
} -- 124
local function drawUiTri(uiDraw, p0, p1, p2, c0, c1, c2, invScale) -- 127
	uiDraw:drawVertices({ -- 137
		{ -- 138
			Vec2(p0.x * invScale, p0.y * invScale), -- 138
			c0 -- 138
		}, -- 138
		{ -- 139
			Vec2(p1.x * invScale, p1.y * invScale), -- 139
			c1 -- 139
		}, -- 139
		{ -- 140
			Vec2(p2.x * invScale, p2.y * invScale), -- 140
			c2 -- 140
		} -- 140
	}) -- 140
end -- 127
local function drawUiQuad(uiDraw, p0, p1, p2, p3, cBot, cTop, invScale) -- 144
	local v0 = Vec2(p0.x * invScale, p0.y * invScale) -- 154
	local v1 = Vec2(p1.x * invScale, p1.y * invScale) -- 155
	local v2 = Vec2(p2.x * invScale, p2.y * invScale) -- 156
	local v3 = Vec2(p3.x * invScale, p3.y * invScale) -- 157
	uiDraw:drawVertices({{v0, cBot}, {v1, cBot}, {v2, cTop}}) -- 158
	uiDraw:drawVertices({{v0, cBot}, {v2, cTop}, {v3, cTop}}) -- 163
end -- 144
____exports.ForestCreekScene = __TS__Class() -- 170
local ForestCreekScene = ____exports.ForestCreekScene -- 170
ForestCreekScene.name = "ForestCreekScene" -- 170
function ForestCreekScene.prototype.____constructor(self) -- 170
	self.animTime = 0 -- 171
	self.active = false -- 172
	self.ripplePhase = 0 -- 173
	self.creekReveal = 0 -- 174
	self.creekWaterVol = 0 -- 175
	self.twigSnapCount = 0 -- 177
	self.twigTriggered = {} -- 178
	self.xiaomanListenTimer = 0 -- 179
	self.xiaomanListenDir = 1 -- 180
	self.prevDogState = "patrol" -- 182
	self.dogAlertCount = 0 -- 183
	self.dogStepCount = 0 -- 184
	self.dogStepAccum = 0 -- 185
	self.prevDogX = 0 -- 186
	self.splinters = {} -- 188
	self.rng = 9417 -- 189
	self.proj = { -- 191
		morph = 1, -- 192
		focal = 405, -- 193
		vpFracX = 0.54, -- 194
		vpFracY = 0.5, -- 195
		vpOffsetX = 0, -- 196
		vpOffsetY = 0, -- 197
		baseDepth = 0 -- 198
	} -- 198
end -- 170
function ForestCreekScene.prototype.reset(self) -- 201
	self.animTime = 0 -- 202
	self.active = false -- 203
	self.ripplePhase = 0 -- 204
	self.creekReveal = 0 -- 205
	self.creekWaterVol = 0 -- 206
	self.twigSnapCount = 0 -- 207
	self.twigTriggered = {} -- 208
	self.xiaomanListenTimer = 0 -- 209
	self.xiaomanListenDir = 1 -- 210
	self.prevDogState = "patrol" -- 211
	self.dogAlertCount = 0 -- 212
	self.dogStepCount = 0 -- 213
	self.dogStepAccum = 0 -- 214
	self.prevDogX = 0 -- 215
	self.splinters = {} -- 216
end -- 201
function ForestCreekScene.prototype.rand(self) -- 219
	self.rng = (self.rng * 1664525 + 1013904223) % 4294967296 -- 220
	return self.rng / 4294967296 -- 221
end -- 219
function ForestCreekScene.prototype.getProjection(self) -- 224
	return self.proj -- 225
end -- 224
function ForestCreekScene.prototype.getDebugState(self, p) -- 228
	local px = p ~= nil and p.player.x or 0 -- 229
	local ox = p ~= nil and p.ox or 0 -- 230
	local reflectionVisible = self.active and px >= ox + 1140 -- 231
	local trueLampVisible = self.active and self.creekReveal >= 0.35 -- 232
	return { -- 233
		active = self.active, -- 234
		twigSnapCount = self.twigSnapCount, -- 235
		xiaomanListenTimer = self.xiaomanListenTimer, -- 236
		dogAlertCount = self.dogAlertCount, -- 237
		dogStepCount = self.dogStepCount, -- 238
		creekReveal = self.creekReveal, -- 239
		ripplePhase = self.ripplePhase, -- 240
		trueLampVisible = trueLampVisible, -- 241
		reflectionVisible = reflectionVisible, -- 242
		creekWaterVol = self.creekWaterVol -- 243
	} -- 243
end -- 228
function ForestCreekScene.prototype.update(self, ctx) -- 247
	local p = ctx.p -- 248
	self.active = true -- 249
	local ox = p.ox -- 250
	ctx.cam:setAnchorLock(nil) -- 253
	self.creekReveal = smoothstep(ox + 1310, ox + 1435, p.player.x) -- 256
	if not ctx.paused and ctx.worldDt > 0 then -- 256
		local dt = ctx.worldDt -- 259
		self.animTime = self.animTime + dt -- 260
		self.ripplePhase = self.ripplePhase + dt * 2.4 -- 262
		if self.xiaomanListenTimer > 0 then -- 262
			self.xiaomanListenTimer = math.max(0, self.xiaomanListenTimer - dt) -- 265
		end -- 265
		local movingFast = not p.player.crouch and (math.abs(p.player.vx) > 10 or not p.player.onGround) -- 269
		local i = 0 -- 270
		do -- 270
			i = 0 -- 271
			while i < #TWIG_OFFSETS do -- 271
				local tx = ox + TWIG_OFFSETS[i + 1] -- 272
				local lastSnapAt = self.twigTriggered[i] or -99 -- 273
				if movingFast and math.abs(p.player.x - tx) <= 18 and p.player.y <= 8 and self.animTime - lastSnapAt > 2.4 then -- 273
					self.twigTriggered[i] = self.animTime -- 275
					self:triggerTwigSnap(ctx, tx, p.dogX >= p.player.x and 1 or -1) -- 276
				end -- 276
				i = i + 1 -- 271
			end -- 271
		end -- 271
		if p.room.story ~= nil and p.room.story.dog ~= nil then -- 271
			if p.dogState == "ear" and self.prevDogState ~= "ear" then -- 271
				self.dogAlertCount = self.dogAlertCount + 1 -- 283
				self:triggerTwigSnap(ctx, p.player.x, p.dogX >= p.player.x and 1 or -1) -- 284
				ctx.audio:playOnce( -- 285
					(("fe04:forest:dog_alert:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogAlertCount), -- 286
					"sfx", -- 287
					CHILD_AUDIO_ROOT .. "dog_alert.wav", -- 288
					0.82, -- 289
					"fe04:forest:dog_alert", -- 290
					p.ticks -- 291
				) -- 291
			elseif p.dogState == "chase" and self.prevDogState ~= "chase" then -- 291
				self.dogAlertCount = self.dogAlertCount + 1 -- 294
				ctx.audio:playOnce( -- 295
					(("fe04:forest:dog_chase:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogAlertCount), -- 296
					"sfx", -- 297
					CHILD_AUDIO_ROOT .. "dog_alert.wav", -- 298
					0.9, -- 299
					"fe04:forest:dog_chase", -- 300
					p.ticks -- 301
				) -- 301
			end -- 301
			local dogDx = math.abs(p.dogX - self.prevDogX) -- 305
			if dogDx > 0.01 and (p.dogState == "patrol" or p.dogState == "chase" or p.dogState == "back") then -- 305
				self.dogStepAccum = self.dogStepAccum + dogDx -- 307
				local stepStride = p.dogState == "chase" and 28 or 42 -- 308
				if self.dogStepAccum >= stepStride then -- 308
					self.dogStepAccum = 0 -- 310
					local dist = math.abs(p.player.x - p.dogX) -- 311
					if dist < 420 then -- 311
						self.dogStepCount = self.dogStepCount + 1 -- 313
						local vol = 0.24 + 0.48 * clamp01(1 - dist / 420) -- 314
						ctx.audio:playOnce( -- 315
							(("fe04:forest:dog_step:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.dogStepCount), -- 316
							"sfx", -- 317
							CHILD_AUDIO_ROOT .. "dog_step.wav", -- 318
							vol, -- 319
							"fe04:forest:dog_step", -- 320
							p.ticks -- 321
						) -- 321
					end -- 321
				end -- 321
			end -- 321
			self.prevDogX = p.dogX -- 326
			self.prevDogState = p.dogState -- 327
		end -- 327
		local w = 0 -- 331
		do -- 331
			i = 0 -- 332
			while i < #self.splinters do -- 332
				local sp = self.splinters[i + 1] -- 333
				sp.life = sp.life - dt -- 334
				if sp.life > 0 then -- 334
					sp.vy = sp.vy - 320 * dt -- 336
					sp.x = sp.x + sp.vx * dt -- 337
					sp.y = sp.y + sp.vy * dt -- 338
					if sp.y < 0 then -- 338
						sp.y = 0 -- 340
						sp.vy = 0 -- 341
						sp.vx = sp.vx * 0.4 -- 342
					end -- 342
					self.splinters[w + 1] = sp -- 344
					w = w + 1 -- 345
				end -- 345
				i = i + 1 -- 332
			end -- 332
		end -- 332
		__TS__ArraySetLength(self.splinters, w) -- 332
		local creekApproach = smoothstep(ox + 1140, ox + 1410, p.player.x) -- 351
		local windVol = 0.34 * (1 - creekApproach * 0.42) -- 352
		self.creekWaterVol = 0.02 + 0.54 * creekApproach -- 353
		ctx.audio:playLoop( -- 354
			"fe04_forest_wind", -- 354
			"wind", -- 354
			CHILD_AUDIO_ROOT .. "forest_wind_loop.wav", -- 354
			windVol, -- 354
			p.ticks -- 354
		) -- 354
		if creekApproach > 0.02 then -- 354
			ctx.audio:playLoop( -- 356
				"fe04_creek_water", -- 356
				"water", -- 356
				CHILD_AUDIO_ROOT .. "creek_loop.wav", -- 356
				self.creekWaterVol, -- 356
				p.ticks -- 356
			) -- 356
		else -- 356
			ctx.audio:stopLoop("fe04_creek_water", 0.25) -- 358
		end -- 358
	end -- 358
	self.proj = { -- 362
		morph = 1, -- 363
		focal = 405, -- 364
		vpFracX = 0.54, -- 365
		vpFracY = 0.5, -- 366
		vpOffsetX = math.sin(self.animTime * 0.55) * 1.8, -- 367
		vpOffsetY = math.cos(self.animTime * 0.72) * 1.2, -- 368
		baseDepth = 0 -- 369
	} -- 369
end -- 247
function ForestCreekScene.prototype.triggerTwigSnap(self, ctx, worldX, listenDir) -- 373
	self.twigSnapCount = self.twigSnapCount + 1 -- 374
	self.xiaomanListenTimer = 0.52 -- 375
	self.xiaomanListenDir = listenDir >= 0 and 1 or -1 -- 376
	ctx.audio:playOnce( -- 377
		(("fe04:forest:twig:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(self.twigSnapCount), -- 378
		"sfx", -- 379
		CHILD_AUDIO_ROOT .. "twig_snap.wav", -- 380
		0.84, -- 381
		"fe04:forest:twig_snap", -- 382
		ctx.p.ticks -- 383
	) -- 383
	local i = 0 -- 385
	do -- 385
		i = 0 -- 386
		while i < 6 do -- 386
			local ang = (0.2 + self:rand() * 0.6) * math.pi -- 387
			local spd = 45 + self:rand() * 75 -- 388
			local ____self_splinters_0 = self.splinters -- 388
			____self_splinters_0[#____self_splinters_0 + 1] = { -- 389
				x = worldX + (self:rand() - 0.5) * 10, -- 390
				y = 2, -- 391
				vx = math.cos(ang) * spd * (self:rand() > 0.5 and 1 or -1), -- 392
				vy = math.sin(ang) * spd, -- 393
				len = 3.5 + self:rand() * 3.5, -- 394
				life = 0.38 + self:rand() * 0.22, -- 395
				maxLife = 0.6 -- 396
			} -- 396
			i = i + 1 -- 386
		end -- 386
	end -- 386
end -- 373
function ForestCreekScene.prototype.drawBackdrop(self, bgDraw, bgGlow, _backdropArt, ctx) -- 401
	local p = ctx.p -- 407
	local cam = ctx.cam -- 408
	local ox = p.ox -- 409
	local w = cam.viewW -- 410
	local h = cam.viewH -- 411
	local dawn = smoothstep(ox + 1120, ox + 1460, p.player.x) -- 414
	local skyTop = lerpRGBA( -- 415
		rgba(8, 14, 18, 255), -- 415
		rgba(16, 26, 38, 255), -- 415
		dawn -- 415
	) -- 415
	local skyMid = lerpRGBA( -- 416
		rgba(16, 28, 32, 255), -- 416
		rgba(32, 46, 62, 255), -- 416
		dawn -- 416
	) -- 416
	local skyHor = lerpRGBA( -- 417
		rgba(28, 44, 48, 255), -- 417
		rgba(62, 78, 94, 255), -- 417
		dawn -- 417
	) -- 417
	local splitY = h * 0.46 -- 418
	fillVGradRect( -- 419
		bgDraw, -- 419
		0, -- 419
		splitY, -- 419
		w, -- 419
		h - splitY, -- 419
		toColor(skyMid), -- 419
		toColor(skyTop) -- 419
	) -- 419
	fillVGradRect( -- 420
		bgDraw, -- 420
		0, -- 420
		0, -- 420
		w, -- 420
		splitY, -- 420
		toColor(skyHor), -- 420
		toColor(skyMid) -- 420
	) -- 420
	local scene = __TS__New(LowpolyScene, cam, self.proj, FOREST_CREEK_LIGHT) -- 422
	scene:addDistantRidge( -- 425
		{ -- 426
			{x = ox - 180, y = 128}, -- 427
			{x = ox + 220, y = 186}, -- 428
			{x = ox + 620, y = 152}, -- 429
			{x = ox + 1040, y = 204}, -- 430
			{x = ox + 1420, y = 168}, -- 431
			{x = ox + 1780, y = 196} -- 432
		}, -- 432
		-40, -- 432
		460, -- 435
		MING_MATERIALS.distantHill, -- 436
		{bucket = LP_BUCKET.BACKDROP} -- 437
	) -- 437
	local treeXs = { -- 441
		80, -- 441
		210, -- 441
		360, -- 441
		510, -- 441
		670, -- 441
		840, -- 441
		1010, -- 441
		1180, -- 441
		1290 -- 441
	} -- 441
	local i = 0 -- 442
	do -- 442
		i = 0 -- 443
		while i < #treeXs do -- 443
			local tx = ox + treeXs[i + 1] -- 444
			local tz = 185 + i % 3 * 42 -- 445
			local tw = 12 + i % 2 * 5 -- 446
			scene:addBox({ -- 447
				x0 = tx - tw * 0.5, -- 448
				x1 = tx + tw * 0.5, -- 449
				y0 = -20, -- 450
				y1 = 185 + i % 2 * 20, -- 451
				z0 = tz, -- 452
				z1 = tz + 16, -- 453
				material = MING_MATERIALS.distantWall, -- 454
				bucket = LP_BUCKET.BACKDROP, -- 455
				edgeWidth = 0 -- 456
			}) -- 456
			local lean = (i % 3 - 1) * 7 -- 459
			local baseH = 92 + i % 2 * 14 -- 460
			local tier = 0 -- 461
			do -- 461
				tier = 0 -- 462
				while tier < 3 do -- 462
					local ty0 = baseH + tier * 32 -- 463
					local ty1 = ty0 + 52 - tier * 6 -- 464
					local half = 50 - tier * 11 -- 465
					local colShift = tier * 4 -- 466
					scene:addTri3D( -- 467
						vec3(tx - half + lean * 0.4, ty0, tz - 4 - tier * 2), -- 468
						vec3(tx + half + lean * 0.4, ty0 + 4, tz - 4 - tier * 2), -- 469
						vec3(tx + lean, ty1, tz + 4), -- 470
						{base = rgba(18 + colShift, 30 + colShift, 32 + colShift, 255)}, -- 471
						{bucket = LP_BUCKET.BACKDROP, sortBias = 0.04 + tier * 0.01} -- 472
					) -- 472
					tier = tier + 1 -- 462
				end -- 462
			end -- 462
			i = i + 1 -- 443
		end -- 443
	end -- 443
	local towerX = ox + 1525 -- 478
	scene:addBox({ -- 479
		x0 = towerX - 24, -- 480
		x1 = towerX + 24, -- 481
		y0 = 44, -- 482
		y1 = 174, -- 483
		z0 = 332, -- 484
		z1 = 356, -- 485
		material = MING_MATERIALS.distantWall, -- 486
		bucket = LP_BUCKET.BACKDROP, -- 487
		sortBias = 0.12, -- 488
		edgeWidth = 0 -- 489
	}) -- 489
	scene:addTri3D( -- 492
		vec3(towerX - 34, 174, 330), -- 493
		vec3(towerX + 34, 174, 330), -- 494
		vec3(towerX, 200, 344), -- 495
		MING_MATERIALS.mingTile, -- 496
		{bucket = LP_BUCKET.BACKDROP, sortBias = 0.14} -- 497
	) -- 497
	scene:addFogBand( -- 501
		ox - 160, -- 501
		ox + 1780, -- 501
		-30, -- 501
		148, -- 501
		250, -- 501
		rgba(28, 42, 48, 255), -- 501
		0.62, -- 501
		0.06, -- 501
		{bucket = LP_BUCKET.BACKDROP} -- 501
	) -- 501
	scene:flush(bgDraw, bgGlow) -- 505
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 508
	local lampPt = projectWorld3D( -- 509
		towerX - 4, -- 509
		146, -- 509
		330, -- 509
		cam, -- 509
		self.proj -- 509
	) -- 509
	fillRadialGlow( -- 510
		bgGlow, -- 511
		lampPt.x, -- 512
		lampPt.y, -- 513
		42 * lampPulse, -- 514
		42 * lampPulse, -- 515
		Color( -- 516
			246, -- 516
			208, -- 516
			134, -- 516
			math.floor(115 * lampPulse + 0.5) -- 516
		), -- 516
		Color(232, 176, 86, 0), -- 517
		16 -- 518
	) -- 518
	bgDraw:drawRect( -- 520
		Rect(lampPt.x - 3.5, lampPt.y - 5.5, 7, 11), -- 520
		Color(255, 232, 174, 240) -- 520
	) -- 520
	bgGlow:drawDot( -- 521
		Vec2(lampPt.x, lampPt.y), -- 521
		3.4, -- 521
		Color(255, 246, 218, 250) -- 521
	) -- 521
	return true -- 523
end -- 401
function ForestCreekScene.prototype.drawWorld(self, fgDraw, fgGlow, _worldArt, ctx) -- 526
	local p = ctx.p -- 532
	local cam = ctx.cam -- 533
	local ox = p.ox -- 534
	local scene = __TS__New(LowpolyScene, cam, self.proj, FOREST_CREEK_LIGHT) -- 535
	scene:addBox({ -- 538
		x0 = ox - 40, -- 539
		x1 = ox + 1320, -- 540
		y0 = -52, -- 541
		y1 = 0, -- 542
		z0 = -26, -- 543
		z1 = 92, -- 544
		material = MAT_MOSS_GROUND, -- 545
		bucket = LP_BUCKET.MIDGROUND, -- 546
		highlightTopEdge = true, -- 547
		edgeWidth = 0.7 -- 548
	}) -- 548
	scene:addBox({ -- 551
		x0 = ox + 1320, -- 552
		x1 = ox + 1620, -- 553
		y0 = -14, -- 554
		y1 = 0, -- 555
		z0 = -10, -- 556
		z1 = 24, -- 557
		material = MING_MATERIALS.mingStoneStep, -- 558
		bucket = LP_BUCKET.WALK_DECK, -- 559
		highlightTopEdge = true, -- 560
		edgeWidth = 0.9 -- 561
	}) -- 561
	scene:addQuad3D( -- 564
		vec3(ox + 1250, -6, -44), -- 565
		vec3(ox + 1640, -6, -44), -- 566
		vec3(ox + 1640, -2, -10), -- 567
		vec3(ox + 1250, -2, -10), -- 568
		MAT_CREEK_WATER, -- 569
		{bucket = LP_BUCKET.WALK_DECK, sortBias = 0.08, edgeWidth = 0} -- 570
	) -- 570
	scene:addQuad3D( -- 572
		vec3(ox + 1250, -2, 24), -- 573
		vec3(ox + 1660, -2, 24), -- 574
		vec3(ox + 1660, 4, 196), -- 575
		vec3(ox + 1250, 4, 196), -- 576
		MAT_CREEK_WATER, -- 577
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.04, edgeWidth = 0} -- 578
	) -- 578
	local midTrunks = { -- 582
		150, -- 582
		415, -- 582
		650, -- 582
		910, -- 582
		1255 -- 582
	} -- 582
	local i = 0 -- 583
	do -- 583
		i = 0 -- 584
		while i < #midTrunks do -- 584
			local tx = ox + midTrunks[i + 1] -- 585
			scene:addBox({ -- 586
				x0 = tx - 14, -- 587
				x1 = tx + 14, -- 588
				y0 = -10, -- 589
				y1 = 210, -- 590
				z0 = 36 + i % 2 * 18, -- 591
				z1 = 68 + i % 2 * 18, -- 592
				material = MAT_PINE_TRUNK, -- 593
				bucket = LP_BUCKET.MIDGROUND, -- 594
				edgeWidth = 0.7 -- 595
			}) -- 595
			i = i + 1 -- 584
		end -- 584
	end -- 584
	do -- 584
		i = 0 -- 600
		while i < #p.room.stairs do -- 600
			local st = p.room.stairs[i + 1] -- 601
			scene:addBox({ -- 602
				x0 = st.x0, -- 603
				x1 = st.x1, -- 604
				y0 = 0, -- 605
				y1 = st.y1, -- 606
				z0 = -14, -- 607
				z1 = 42, -- 608
				material = i == 1 and MAT_ROOT_ARCH or MING_MATERIALS.mingStoneStep, -- 609
				bucket = LP_BUCKET.WALK_DECK, -- 610
				highlightTopEdge = true, -- 611
				edgeWidth = 0.9 -- 612
			}) -- 612
			i = i + 1 -- 600
		end -- 600
	end -- 600
	scene:addTri3D( -- 619
		vec3(ox + 958, 0, 12), -- 620
		vec3(ox + 998, 22, 12), -- 621
		vec3(ox + 986, 104, 22), -- 622
		MAT_ROOT_ARCH, -- 623
		{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.9} -- 624
	) -- 624
	scene:addTri3D( -- 626
		vec3(ox + 1086, 22, 12), -- 627
		vec3(ox + 1134, 0, 12), -- 628
		vec3(ox + 1098, 106, 22), -- 629
		MAT_ROOT_ARCH, -- 630
		{bucket = LP_BUCKET.MIDGROUND, edgeWidth = 0.9} -- 631
	) -- 631
	scene:addQuad3D( -- 633
		vec3(ox + 972, 74, 14), -- 634
		vec3(ox + 1110, 78, 14), -- 635
		vec3(ox + 1094, 116, 36), -- 636
		vec3(ox + 986, 112, 36), -- 637
		MAT_ROOT_ARCH, -- 638
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.1, edgeWidth = 1} -- 639
	) -- 639
	scene:addQuad3D( -- 642
		vec3(ox + 992, 22, 34), -- 643
		vec3(ox + 1088, 22, 34), -- 644
		vec3(ox + 1080, 74, 34), -- 645
		vec3(ox + 1000, 74, 34), -- 646
		{ -- 647
			base = rgba(10, 16, 18, 215), -- 647
			edge = rgba(164, 192, 188, 130) -- 647
		}, -- 647
		{bucket = LP_BUCKET.MIDGROUND, unlit = true, sortBias = -0.05, edgeWidth = 1} -- 648
	) -- 648
	scene:addBox({ -- 651
		x0 = ox + 830, -- 652
		x1 = ox + 1230, -- 653
		y0 = -10, -- 654
		y1 = 5, -- 655
		z0 = 26, -- 656
		z1 = 60, -- 657
		material = MAT_CANAL_STONE, -- 658
		bucket = LP_BUCKET.MIDGROUND, -- 659
		highlightTopEdge = true, -- 660
		edgeWidth = 0.9 -- 661
	}) -- 661
	scene:addQuad3D( -- 664
		vec3(ox + 858, 5, 28), -- 665
		vec3(ox + 894, 5, 28), -- 666
		vec3(ox + 888, 20, 44), -- 667
		vec3(ox + 852, 18, 44), -- 668
		MAT_CANAL_STONE, -- 669
		{bucket = LP_BUCKET.MIDGROUND, sortBias = 0.22, edgeWidth = 1} -- 670
	) -- 670
	do -- 670
		i = 0 -- 674
		while i < #p.room.solids do -- 674
			local s = p.room.solids[i + 1] -- 675
			if s.passable == true then -- 675
				self:buildGrassCluster( -- 677
					scene, -- 677
					s.x, -- 677
					s.x + s.w, -- 677
					s.y, -- 677
					s.h, -- 677
					8 -- 677
				) -- 677
			elseif s.x >= ox + 1500 then -- 677
				scene:addBox({ -- 680
					x0 = s.x, -- 681
					x1 = s.x + s.w, -- 682
					y0 = s.y, -- 683
					y1 = s.y + s.h, -- 684
					z0 = 10, -- 685
					z1 = 72, -- 686
					material = MING_MATERIALS.mingBrickDark, -- 687
					bucket = LP_BUCKET.MIDGROUND, -- 688
					highlightTopEdge = true -- 689
				}) -- 689
			end -- 689
			i = i + 1 -- 674
		end -- 674
	end -- 674
	do -- 674
		i = 0 -- 695
		while i < #TWIG_OFFSETS do -- 695
			local tx = ox + TWIG_OFFSETS[i + 1] -- 696
			scene:addTri3D( -- 697
				vec3(tx - 12, 0.8, -5), -- 698
				vec3(tx + 12, 0.8, -3), -- 699
				vec3(tx + 3, 6.2, 2), -- 700
				MAT_TWIG, -- 701
				{bucket = LP_BUCKET.PROP, sortBias = 0.15, edgeWidth = 1} -- 702
			) -- 702
			scene:addTri3D( -- 704
				vec3(tx - 8, 0.8, 3), -- 705
				vec3(tx + 14, 0.8, 5), -- 706
				vec3(tx - 2, 5.2, -2), -- 707
				MAT_TWIG, -- 708
				{bucket = LP_BUCKET.PROP, sortBias = 0.16, edgeWidth = 0.9} -- 709
			) -- 709
			i = i + 1 -- 695
		end -- 695
	end -- 695
	scene:addContactShadow( -- 714
		p.player.x, -- 714
		p.player.y, -- 714
		14, -- 714
		10, -- 714
		0.8, -- 714
		{bucket = LP_BUCKET.PROP, sortBias = 0.45} -- 714
	) -- 714
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 714
		scene:addContactShadow( -- 716
			p.dogX, -- 716
			0, -- 716
			18, -- 716
			11, -- 716
			0.82, -- 716
			{bucket = LP_BUCKET.PROP, sortBias = 0.44} -- 716
		) -- 716
	end -- 716
	scene:flush(fgDraw, fgGlow) -- 719
	self:drawCreekWaterReflection(fgDraw, fgGlow, p, cam) -- 722
	do -- 722
		i = 0 -- 725
		while i < #self.splinters do -- 725
			local sp = self.splinters[i + 1] -- 726
			local a = clamp01(sp.life / sp.maxLife) -- 727
			local sx = cam:sx(sp.x) -- 728
			local sy = cam:sy(sp.y) -- 729
			fgDraw:drawSegment( -- 730
				Vec2(sx - sp.len, sy - 1), -- 730
				Vec2(sx + sp.len, sy + 2), -- 730
				1.3, -- 730
				Color( -- 730
					204, -- 730
					182, -- 730
					146, -- 730
					math.floor(235 * a + 0.5) -- 730
				) -- 730
			) -- 730
			i = i + 1 -- 725
		end -- 725
	end -- 725
	return true -- 733
end -- 526
function ForestCreekScene.prototype.buildGrassCluster(self, scene, x0, x1, y0, h, z) -- 736
	local count = math.max( -- 737
		7, -- 737
		math.floor((x1 - x0) / 10) -- 737
	) -- 737
	local span = (x1 - x0) / count -- 738
	local k = 0 -- 739
	do -- 739
		k = 0 -- 740
		while k < count do -- 740
			local bx = x0 + (k + 0.5) * span -- 741
			local lean = (k * 29 % 11 - 5) * 1.3 -- 742
			local sway = math.sin(self.animTime * 1.9 + bx * 0.06) * 2.8 + lean -- 743
			local tipH = h * (0.58 + k * 37 % 10 * 0.048) -- 744
			scene:addTri3D( -- 745
				vec3(bx - span * 0.42, y0, z), -- 746
				vec3(bx + span * 0.42, y0, z), -- 747
				vec3(bx + sway, y0 + tipH, z - 2), -- 748
				MAT_GRASS_BACK, -- 749
				{bucket = LP_BUCKET.PROP, sortBias = 0.1 + k * 0.005, edgeWidth = 0.45} -- 750
			) -- 750
			k = k + 1 -- 740
		end -- 740
	end -- 740
end -- 736
function ForestCreekScene.prototype.drawCreekWaterReflection(self, fgDraw, fgGlow, p, cam) -- 755
	local ox = p.ox -- 761
	if cam:sx(ox + 1230) > cam.viewW + 120 then -- 761
		return -- 763
	end -- 763
	local lampPulse = 0.84 + 0.16 * math.sin(self.animTime * 2.3) -- 765
	local reflCenterX = ox + 1438 -- 766
	local r = 0 -- 769
	do -- 769
		r = 0 -- 770
		while r < 10 do -- 770
			local z = r < 4 and -34 + r * 6 or 32 + (r - 4) * 24 -- 771
			local wx = ox + 1295 + r * 32 + math.sin(self.ripplePhase * 0.75 + r * 1.4) * 14 -- 772
			local pL = projectWorld3D( -- 773
				wx - 26, -- 773
				-3, -- 773
				z, -- 773
				cam, -- 773
				self.proj -- 773
			) -- 773
			local pR = projectWorld3D( -- 774
				wx + 26, -- 774
				-3, -- 774
				z, -- 774
				cam, -- 774
				self.proj -- 774
			) -- 774
			fgGlow:drawSegment( -- 775
				Vec2(pL.x, pL.y), -- 775
				Vec2(pR.x, pR.y), -- 775
				1.1, -- 775
				Color(146, 178, 198, 72) -- 775
			) -- 775
			r = r + 1 -- 770
		end -- 770
	end -- 770
	local bands = 9 -- 779
	do -- 779
		r = 0 -- 780
		while r < bands do -- 780
			local frac = r / (bands - 1) -- 781
			local z = -34 + frac * 22 -- 782
			local drift = math.sin(self.ripplePhase * (1.25 + frac * 0.4) + r * 1.35) * (6 + frac * 9) -- 783
			local halfW = (18 - frac * 8) * (0.75 + 0.25 * math.cos(self.ripplePhase * 1.7 + r)) -- 784
			local wy = -4.5 + frac * 2.5 -- 785
			local pL = projectWorld3D( -- 786
				reflCenterX + drift - halfW, -- 786
				wy, -- 786
				z, -- 786
				cam, -- 786
				self.proj -- 786
			) -- 786
			local pR = projectWorld3D( -- 787
				reflCenterX + drift + halfW, -- 787
				wy, -- 787
				z, -- 787
				cam, -- 787
				self.proj -- 787
			) -- 787
			local a = (0.42 + 0.5 * (1 - frac)) * lampPulse -- 788
			fgDraw:drawSegment( -- 789
				Vec2(pL.x, pL.y), -- 789
				Vec2(pR.x, pR.y), -- 789
				2.1 - frac * 0.7, -- 789
				Color( -- 789
					242, -- 789
					198, -- 789
					118, -- 789
					math.floor(190 * a + 0.5) -- 789
				) -- 789
			) -- 789
			fgGlow:drawSegment( -- 790
				Vec2(pL.x, pL.y), -- 790
				Vec2(pR.x, pR.y), -- 790
				3.6 - frac * 1.1, -- 790
				Color( -- 790
					248, -- 790
					214, -- 790
					140, -- 790
					math.floor(135 * a + 0.5) -- 790
				) -- 790
			) -- 790
			r = r + 1 -- 780
		end -- 780
	end -- 780
	local poolP = projectWorld3D( -- 793
		reflCenterX + 22, -- 793
		0, -- 793
		56, -- 793
		cam, -- 793
		self.proj -- 793
	) -- 793
	fillRadialGlow( -- 794
		fgGlow, -- 795
		poolP.x, -- 796
		poolP.y, -- 797
		58 * lampPulse, -- 798
		18 * lampPulse, -- 799
		Color( -- 800
			246, -- 800
			206, -- 800
			128, -- 800
			math.floor(92 * lampPulse + 0.5) -- 800
		), -- 800
		Color(232, 174, 88, 0), -- 801
		16 -- 802
	) -- 802
end -- 755
function ForestCreekScene.prototype.drawPropsOverlay(self, _fgDraw, _fgGlow, _worldArt, _ctx) -- 807
	return true -- 813
end -- 807
function ForestCreekScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 817
	local p = ctx.p -- 823
	local cam = ctx.cam -- 824
	local px = cam:sx(p.player.x) -- 827
	local pTopY = cam:sy(p.player.y + p.player.h) -- 828
	local fDir = p.player.facing >= 0 and 1 or -1 -- 829
	local shY = pTopY - cam:len(16.5) -- 830
	fgDraw:drawSegment( -- 831
		Vec2( -- 832
			px - fDir * cam:len(7.5), -- 832
			shY - cam:len(4) -- 832
		), -- 832
		Vec2( -- 833
			px - fDir * cam:len(5.5), -- 833
			shY + cam:len(3.5) -- 833
		), -- 833
		1.3, -- 834
		Color(196, 212, 220, 145) -- 835
	) -- 835
	fgDraw:drawSegment( -- 837
		Vec2( -- 838
			px - fDir * cam:len(5.5), -- 838
			shY + cam:len(3.5) -- 838
		), -- 838
		Vec2( -- 839
			px + fDir * cam:len(3.5), -- 839
			shY + cam:len(5.2) -- 839
		), -- 839
		1.2, -- 840
		Color(206, 220, 228, 135) -- 841
	) -- 841
	if self.xiaomanListenTimer > 0 then -- 841
		local k = smoothstep(0, 0.12, self.xiaomanListenTimer) * clamp01(self.xiaomanListenTimer / 0.52) -- 846
		local earX = px + self.xiaomanListenDir * cam:len(8) -- 847
		local earY = pTopY - cam:len(10) -- 848
		local r1 = cam:len(6.5 + (1 - k) * 8) -- 849
		local r2 = cam:len(11.5 + (1 - k) * 11) -- 850
		local startAng = self.xiaomanListenDir > 0 and -34 or 146 -- 851
		local endAng = self.xiaomanListenDir > 0 and 34 or 214 -- 852
		fgDraw:drawArc( -- 853
			Vec2(earX, earY), -- 853
			r1, -- 853
			startAng, -- 853
			endAng, -- 853
			1.3, -- 853
			Color( -- 853
				224, -- 853
				218, -- 853
				198, -- 853
				math.floor(185 * k + 0.5) -- 853
			) -- 853
		) -- 853
		fgGlow:drawArc( -- 854
			Vec2(earX, earY), -- 854
			r2, -- 854
			startAng, -- 854
			endAng, -- 854
			1.1, -- 854
			Color( -- 854
				204, -- 854
				218, -- 854
				224, -- 854
				math.floor(135 * k + 0.5) -- 854
			) -- 854
		) -- 854
	end -- 854
	if p.room.story ~= nil and p.room.story.dog ~= nil then -- 854
		local alert = p.dogState == "ear" or p.dogState == "chase" -- 859
		local f = p.dogState == "chase" and (p.player.x >= p.dogX and 1 or -1) or p.dogDir -- 860
		local headX = cam:sx(p.dogX + f * 11) -- 861
		local headY = cam:sy(23.5) -- 862
		local earH = cam:len(alert and 7.6 or 4.8) -- 863
		local earCol = alert and Color(224, 222, 212, 220) or Color(176, 194, 202, 170) -- 864
		fgDraw:drawPolygon( -- 865
			{ -- 865
				Vec2(headX - f * 3.4, headY), -- 866
				Vec2(headX - f * 0.8, headY + earH), -- 867
				Vec2(headX + f * 2.4, headY + 0.8) -- 868
			}, -- 868
			Color(38, 36, 34, 235), -- 869
			1.1, -- 869
			earCol -- 869
		) -- 869
		if alert then -- 869
			local waveR = cam:len(8 + self.animTime * 20 % 13) -- 871
			fgGlow:drawArc( -- 872
				Vec2(headX, headY + earH * 0.75), -- 872
				waveR, -- 872
				42, -- 872
				138, -- 872
				1.2, -- 872
				Color(226, 208, 174, 145) -- 872
			) -- 872
		end -- 872
	end -- 872
	if ctx.paused then -- 872
		local pX = cam.viewW * (0.78 + self.creekReveal * 0.24) -- 878
		worldArt:tryPlace( -- 879
			"pine", -- 879
			"fe04_pause_creek_branch", -- 879
			pX, -- 879
			cam.viewH * 0.42, -- 879
			cam.viewW * 0.48, -- 879
			cam.viewH * 0.62, -- 879
			{ -- 879
				color = Color(14, 20, 22, 255), -- 880
				opacity = 0.9 * (1 - self.creekReveal * 0.7), -- 881
				layer = 5300 -- 882
			} -- 882
		) -- 882
	end -- 882
end -- 817
function ForestCreekScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 893
	local p = ctx.p -- 900
	local cam = ctx.cam -- 901
	local ox = p.ox -- 902
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 903
	local i = 0 -- 906
	do -- 906
		i = 0 -- 907
		while i < #p.room.solids do -- 907
			do -- 907
				local s = p.room.solids[i + 1] -- 908
				if s.passable ~= true then -- 908
					goto __continue66 -- 910
				end -- 910
				local blades = math.max( -- 912
					7, -- 912
					math.floor(s.w / 10) -- 912
				) -- 912
				local span = s.w / blades -- 913
				local k = 0 -- 914
				do -- 914
					k = 0 -- 915
					while k < blades do -- 915
						local bx = s.x + (k + 0.5) * span -- 916
						local lean = (k * 23 % 9 - 4) * 1.6 -- 917
						local sway = math.sin(self.animTime * 2.1 + bx * 0.06) * 2.6 + lean -- 918
						local tipH = math.min(18, s.h * (0.48 + k * 19 % 7 * 0.048)) -- 919
						local pL = projectWorld3D( -- 920
							bx - span * 0.36, -- 920
							s.y - 2, -- 920
							-18, -- 920
							cam, -- 920
							self.proj -- 920
						) -- 920
						local pR = projectWorld3D( -- 921
							bx + span * 0.36, -- 921
							s.y - 2, -- 921
							-18, -- 921
							cam, -- 921
							self.proj -- 921
						) -- 921
						local pT = projectWorld3D( -- 922
							bx + sway, -- 922
							s.y + tipH, -- 922
							-20, -- 922
							cam, -- 922
							self.proj -- 922
						) -- 922
						drawUiTri( -- 923
							uiDraw, -- 923
							pL, -- 923
							pR, -- 923
							pT, -- 923
							Color(11, 18, 17, 232), -- 923
							Color(14, 22, 20, 232), -- 923
							Color(32, 50, 44, 218), -- 923
							inv -- 923
						) -- 923
						k = k + 1 -- 915
					end -- 915
				end -- 915
			end -- 915
			::__continue66:: -- 915
			i = i + 1 -- 907
		end -- 907
	end -- 907
	local nearCreek = smoothstep(ox + 1060, ox + 1240, p.player.x) -- 929
	if nearCreek > 0.02 then -- 929
		local w = cam.viewW -- 931
		local h = cam.viewH -- 932
		local partShift = self.creekReveal * w * 0.38 -- 933
		local liftShift = self.creekReveal * h * 0.16 -- 934
		local canopyAlpha = math.floor(244 * nearCreek * (1 - self.creekReveal * 0.28) + 0.5) -- 935
		local cTrunk = Color(14, 18, 18, canopyAlpha) -- 936
		local cDark = Color(11, 20, 20, canopyAlpha) -- 937
		local cLeaf = Color( -- 938
			22, -- 938
			36, -- 938
			33, -- 938
			math.floor(canopyAlpha * 0.94 + 0.5) -- 938
		) -- 938
		local sway = math.sin(self.animTime * 1.45) * 5 -- 939
		drawUiQuad( -- 942
			uiDraw, -- 943
			{x = w * 0.56 + partShift + sway * 0.4, y = h * 0.67 + liftShift}, -- 944
			{x = w * 1.06 + partShift, y = h * 0.84 + liftShift}, -- 945
			{x = w * 1.06 + partShift, y = h * 0.96 + liftShift}, -- 946
			{x = w * 0.54 + partShift + sway * 0.4, y = h * 0.74 + liftShift}, -- 947
			cTrunk, -- 948
			cDark, -- 949
			inv -- 950
		) -- 950
		local clusters = { -- 953
			{ -- 954
				fx = 0.56, -- 954
				fy = 0.66, -- 954
				rw = 118, -- 954
				rh = 92, -- 954
				drop = 112 -- 954
			}, -- 954
			{ -- 955
				fx = 0.68, -- 955
				fy = 0.62, -- 955
				rw = 138, -- 955
				rh = 108, -- 955
				drop = 134 -- 955
			}, -- 955
			{ -- 956
				fx = 0.81, -- 956
				fy = 0.64, -- 956
				rw = 146, -- 956
				rh = 112, -- 956
				drop = 124 -- 956
			}, -- 956
			{ -- 957
				fx = 0.94, -- 957
				fy = 0.7, -- 957
				rw = 142, -- 957
				rh = 118, -- 957
				drop = 116 -- 957
			}, -- 957
			{ -- 958
				fx = 0.74, -- 958
				fy = 0.78, -- 958
				rw = 165, -- 958
				rh = 110, -- 958
				drop = 92 -- 958
			} -- 958
		} -- 958
		local ci = 0 -- 960
		do -- 960
			ci = 0 -- 961
			while ci < #clusters do -- 961
				local cl = clusters[ci + 1] -- 962
				local bx = w * cl.fx + partShift + sway * (0.5 + ci * 0.12) -- 963
				local by = h * cl.fy + liftShift -- 964
				drawUiTri( -- 965
					uiDraw, -- 966
					{x = bx - cl.rw * 0.65, y = by + cl.rh * 0.85}, -- 967
					{x = bx + cl.rw * 0.72, y = by + cl.rh * 0.62}, -- 968
					{x = bx - cl.rw * 0.12 + sway * 0.6, y = by - cl.drop * 0.68}, -- 969
					cDark, -- 970
					cDark, -- 971
					cLeaf, -- 972
					inv -- 973
				) -- 973
				drawUiTri( -- 975
					uiDraw, -- 976
					{x = bx - cl.rw * 0.28, y = by + cl.rh * 0.92}, -- 977
					{x = bx + cl.rw * 0.88, y = by + cl.rh * 0.82}, -- 978
					{x = bx + cl.rw * 0.24 + sway * 0.8, y = by - cl.drop * 0.54}, -- 979
					cDark, -- 980
					cTrunk, -- 981
					cLeaf, -- 982
					inv -- 983
				) -- 983
				ci = ci + 1 -- 961
			end -- 961
		end -- 961
		local lShift = self.creekReveal * w * 0.22 -- 988
		drawUiTri( -- 989
			uiDraw, -- 990
			{x = -30 - lShift, y = h + 16}, -- 991
			{x = w * 0.3 - lShift, y = h + 16}, -- 992
			{x = w * 0.12 - lShift - sway * 0.5, y = h * 0.68 + liftShift * 0.5}, -- 993
			cDark, -- 994
			cDark, -- 995
			cLeaf, -- 996
			inv -- 997
		) -- 997
	end -- 997
	return false -- 1001
end -- 893
return ____exports -- 893