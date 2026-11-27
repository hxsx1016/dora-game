-- [ts]: village_undertable.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 19
local Color = ____Dora.Color -- 19
local Rect = ____Dora.Rect -- 19
local Vec2 = ____Dora.Vec2 -- 19
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 24
local LP_BUCKET = ____lowpoly.LP_BUCKET -- 25
local LowpolyScene = ____lowpoly.LowpolyScene -- 28
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 29
local VILLAGE_UNDERTABLE_LIGHT = ____lowpoly.VILLAGE_UNDERTABLE_LIGHT -- 30
local clamp01 = ____lowpoly.clamp01 -- 31
local projectWorld3D = ____lowpoly.projectWorld3D -- 32
local vec3 = ____lowpoly.vec3 -- 34
local ____theme = require("Script.watch.fe.theme") -- 36
local fillRadialGlow = ____theme.fillRadialGlow -- 39
local fillVGradRect = ____theme.fillVGradRect -- 40
local rgba = ____theme.rgba -- 41
local toColor = ____theme.toColor -- 42
local GRAVITY = 1000 -- 45
local BOTTLE_FLY_T = 0.62 -- 46
local CHILD_AUDIO_ROOT = "assets/audio/child/" -- 47
--- 空村铁盆世界坐标（位于拾荒者巡逻右侧、与硬砖 brickX=608 ± 34 清晰分离、完全在听觉半径 480 内）
____exports.VILLAGE_BASIN_OFFSET_X = 548 -- 50
____exports.VILLAGE_BASIN_HIT_RADIUS = 24 -- 51
____exports.VILLAGE_SURFACE_HIT_RADIUS = 34 -- 52
local MAT_CLAY_STOVE = { -- 95
	base = rgba(74, 68, 62, 255), -- 96
	edge = rgba(128, 120, 110, 145), -- 97
	minShade = 0.22, -- 98
	rimBoost = 0.16, -- 99
	bottomAo = 0.36 -- 100
} -- 100
local MAT_SOFT_EARTH = { -- 103
	base = rgba(66, 54, 43, 255), -- 104
	edge = rgba(96, 80, 64, 95), -- 105
	minShade = 0.3, -- 106
	rimBoost = 0.06, -- 107
	bottomAo = 0.24 -- 108
} -- 108
local MAT_HARD_BRICK = { -- 111
	base = rgba(126, 132, 142, 255), -- 112
	edge = rgba(220, 226, 234, 210), -- 113
	minShade = 0.32, -- 114
	rimBoost = 0.3, -- 115
	bottomAo = 0.22 -- 116
} -- 116
local MAT_IRON_BASIN = { -- 119
	base = rgba(58, 66, 78, 255), -- 120
	edge = rgba(214, 224, 238, 225), -- 121
	minShade = 0.24, -- 122
	rimBoost = 0.38, -- 123
	bottomAo = 0.28 -- 124
} -- 124
local MAT_TABLE_WOOD = { -- 127
	base = rgba(78, 56, 40, 255), -- 128
	edge = rgba(142, 110, 82, 155), -- 129
	minShade = 0.18, -- 130
	rimBoost = 0.18, -- 131
	bottomAo = 0.42 -- 132
} -- 132
local MAT_CULVERT_STONE = { -- 135
	base = rgba(76, 84, 96, 255), -- 136
	edge = rgba(178, 194, 210, 195), -- 137
	minShade = 0.26, -- 138
	rimBoost = 0.28, -- 139
	bottomAo = 0.34 -- 140
} -- 140
local function drawEllipseRing(draw, cx, cy, rx, ry, lineW, col, segs) -- 143
	if segs == nil then -- 151
		segs = 22 -- 151
	end -- 151
	local pts = {} -- 153
	local i = 0 -- 154
	do -- 154
		i = 0 -- 155
		while i < segs do -- 155
			local a = i / segs * math.pi * 2 -- 156
			pts[#pts + 1] = Vec2( -- 157
				cx + math.cos(a) * rx, -- 157
				cy + math.sin(a) * ry -- 157
			) -- 157
			i = i + 1 -- 155
		end -- 155
	end -- 155
	draw:drawPolygon( -- 159
		pts, -- 159
		Color(0, 0, 0, 0), -- 159
		lineW, -- 159
		col -- 159
	) -- 159
end -- 143
local function drawUiQuad(uiDraw, p0, p1, p2, p3, cBot, cTop, invScale, edgeCol, edgeW) -- 162
	if edgeW == nil then -- 172
		edgeW = 0 -- 172
	end -- 172
	local v0 = Vec2(p0.x * invScale, p0.y * invScale) -- 174
	local v1 = Vec2(p1.x * invScale, p1.y * invScale) -- 175
	local v2 = Vec2(p2.x * invScale, p2.y * invScale) -- 176
	local v3 = Vec2(p3.x * invScale, p3.y * invScale) -- 177
	uiDraw:drawVertices({{v0, cBot}, {v1, cBot}, {v2, cTop}}) -- 178
	uiDraw:drawVertices({{v0, cBot}, {v2, cTop}, {v3, cTop}}) -- 183
	if edgeCol ~= nil and edgeW > 0 then -- 188
		local half = edgeW * 0.5 -- 189
		uiDraw:drawSegment(v0, v1, half, edgeCol) -- 190
		uiDraw:drawSegment(v1, v2, half, edgeCol) -- 191
		uiDraw:drawSegment(v2, v3, half, edgeCol) -- 192
		uiDraw:drawSegment(v3, v0, half, edgeCol) -- 193
	end -- 193
end -- 162
____exports.VillageUndertableScene = __TS__Class() -- 197
local VillageUndertableScene = ____exports.VillageUndertableScene -- 197
VillageUndertableScene.name = "VillageUndertableScene" -- 197
function VillageUndertableScene.prototype.____constructor(self) -- 197
	self.animTime = 0 -- 198
	self.active = false -- 199
	self.underTableFocus = 0 -- 200
	self.lastSurface = "" -- 201
	self.lastLandX = -1 -- 202
	self.brickHits = 0 -- 203
	self.ironHits = 0 -- 204
	self.softHits = 0 -- 205
	self.basinShakeTimer = 0 -- 208
	self.basinShakeMax = 1.15 -- 209
	self.basinShakeAngle = 0 -- 210
	self.shoeToePauseTimer = 0 -- 213
	self.shoeTurnBlend = 1 -- 214
	self.shoeFacing = -1 -- 215
	self.prevScavState = "patrol" -- 216
	self.prevScavX = 0 -- 217
	self.scavStridePhase = 0 -- 218
	self.shards = {} -- 220
	self.rings = {} -- 221
	self.rng = 7321 -- 222
	self.proj = { -- 224
		morph = 1, -- 225
		focal = 390, -- 226
		vpFracX = 0.54, -- 227
		vpFracY = 0.44, -- 228
		vpOffsetX = 0, -- 229
		vpOffsetY = 0, -- 230
		baseDepth = 0 -- 231
	} -- 231
end -- 197
function VillageUndertableScene.prototype.reset(self) -- 234
	self.animTime = 0 -- 235
	self.active = false -- 236
	self.underTableFocus = 0 -- 237
	self.lastSurface = "" -- 238
	self.lastLandX = -1 -- 239
	self.brickHits = 0 -- 240
	self.ironHits = 0 -- 241
	self.softHits = 0 -- 242
	self.basinShakeTimer = 0 -- 243
	self.basinShakeAngle = 0 -- 244
	self.shoeToePauseTimer = 0 -- 245
	self.shoeTurnBlend = 1 -- 246
	self.shoeFacing = -1 -- 247
	self.prevScavState = "patrol" -- 248
	self.prevScavX = 0 -- 249
	self.scavStridePhase = 0 -- 250
	self.shards = {} -- 251
	self.rings = {} -- 252
end -- 234
function VillageUndertableScene.prototype.rand(self) -- 255
	self.rng = (self.rng * 1664525 + 1013904223) % 4294967296 -- 256
	return self.rng / 4294967296 -- 257
end -- 255
function VillageUndertableScene.prototype.getProjection(self) -- 260
	return self.proj -- 261
end -- 260
function VillageUndertableScene.prototype.getBasinWorldX(self, p) -- 264
	return p.ox + ____exports.VILLAGE_BASIN_OFFSET_X -- 265
end -- 264
function VillageUndertableScene.prototype.getBrickWorldX(self, p) -- 268
	return p.room.brickX or p.ox + 608 -- 269
end -- 268
function VillageUndertableScene.prototype.getSoftWorldX(self, p) -- 272
	return p.room.softX or p.ox + 272 -- 273
end -- 272
function VillageUndertableScene.prototype.getCulvertWorldX(self, p) -- 276
	return p.ox + 600 -- 278
end -- 276
function VillageUndertableScene.prototype.classifyLandingSurface(self, p, x, explicitSurface) -- 282
	if explicitSurface == "iron" or explicitSurface == "basin" then -- 283
		return "iron" -- 284
	end -- 284
	if explicitSurface == "soft" or explicitSurface == "dirt" then -- 286
		return "soft" -- 287
	end -- 287
	if explicitSurface == "brick" then -- 289
		return "brick" -- 290
	end -- 290
	local basinX = self:getBasinWorldX(p) -- 292
	if math.abs(x - basinX) <= ____exports.VILLAGE_BASIN_HIT_RADIUS then -- 293
		return "iron" -- 294
	end -- 294
	local softX = self:getSoftWorldX(p) -- 296
	if math.abs(x - softX) <= ____exports.VILLAGE_SURFACE_HIT_RADIUS then -- 297
		return "soft" -- 298
	end -- 298
	return "brick" -- 300
end -- 282
function VillageUndertableScene.prototype.getDebugState(self, p) -- 303
	return { -- 304
		active = self.active, -- 305
		basinWorldX = p ~= nil and self:getBasinWorldX(p) or ____exports.VILLAGE_BASIN_OFFSET_X, -- 306
		brickWorldX = p ~= nil and self:getBrickWorldX(p) or 608, -- 307
		softWorldX = p ~= nil and self:getSoftWorldX(p) or 272, -- 308
		culvertWorldX = p ~= nil and self:getCulvertWorldX(p) or 440, -- 309
		lastSurface = self.lastSurface, -- 310
		brickHits = self.brickHits, -- 311
		ironHits = self.ironHits, -- 312
		softHits = self.softHits, -- 313
		basinShakeTimer = self.basinShakeTimer, -- 314
		basinShakeAngle = self.basinShakeAngle, -- 315
		shoeToePauseTimer = self.shoeToePauseTimer, -- 316
		shoeFacing = self.shoeFacing, -- 317
		scavTargetX = p ~= nil and p.scavTargetX or 0, -- 318
		underTableFocus = self.underTableFocus, -- 319
		lastLandX = self.lastLandX -- 320
	} -- 320
end -- 303
function VillageUndertableScene.prototype.update(self, ctx) -- 324
	local p = ctx.p -- 325
	self.active = true -- 326
	local arch = p.room.arch -- 329
	local nearTable = p.player.x >= arch.x0 - 80 and p.player.x <= arch.x1 + 30 -- 330
	local targetFocus = (p.player.crouch or nearTable) and 1 or 0.72 -- 331
	if not ctx.paused and ctx.worldDt > 0 then -- 332
		local dt = ctx.worldDt -- 333
		self.animTime = self.animTime + dt -- 334
		self.underTableFocus = self.underTableFocus + (targetFocus - self.underTableFocus) * math.min(1, dt * 4.5) -- 335
		if self.basinShakeTimer > 0 then -- 338
			self.basinShakeTimer = math.max(0, self.basinShakeTimer - dt) -- 339
			local elapsed = self.basinShakeMax - self.basinShakeTimer -- 340
			self.basinShakeAngle = math.sin(elapsed * 38) * math.exp(-elapsed * 3.1) * 0.24 -- 341
		else -- 341
			self.basinShakeAngle = 0 -- 343
		end -- 343
		if self.shoeToePauseTimer > 0 then -- 347
			self.shoeToePauseTimer = math.max(0, self.shoeToePauseTimer - dt) -- 348
		end -- 348
		local scavDx = p.scavX - self.prevScavX -- 350
		if math.abs(scavDx) > 0.02 then -- 351
			self.scavStridePhase = self.scavStridePhase + math.abs(scavDx) * 0.16 -- 352
		elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" then -- 353
			self.scavStridePhase = self.scavStridePhase + dt * (p.scavState == "chase" and 11.5 or 6.2) -- 354
		end -- 354
		self.prevScavX = p.scavX -- 356
		local desiredFacing = self:computeDesiredShoeFacing(p) -- 359
		if self.shoeToePauseTimer <= 0 then -- 360
			self.shoeFacing = desiredFacing -- 361
			self.shoeTurnBlend = math.min(1, self.shoeTurnBlend + dt * 6) -- 362
		end -- 362
		local i = 0 -- 366
		do -- 366
			i = 0 -- 367
			while i < #ctx.events.rawEvents do -- 367
				local ev = ctx.events.rawEvents[i + 1] -- 368
				if ev.name == "bottleLanded" then -- 369
					self:onBottleLanded(ctx, ev) -- 370
				end -- 370
				i = i + 1 -- 367
			end -- 367
		end -- 367
		if p.scavState == "turn" and self.prevScavState ~= "turn" then -- 375
			if self.lastSurface == "brick" and self.shoeToePauseTimer <= 0 then -- 376
				self.shoeToePauseTimer = 0.14 -- 377
			end -- 377
		end -- 377
		self.prevScavState = p.scavState -- 380
		local w = 0 -- 383
		do -- 383
			i = 0 -- 384
			while i < #self.shards do -- 384
				local sp = self.shards[i + 1] -- 385
				sp.life = sp.life - dt -- 386
				if sp.life > 0 then -- 387
					sp.vy = sp.vy - (sp.kind == "soft" and 180 or 420) * dt -- 388
					sp.x = sp.x + sp.vx * dt -- 389
					sp.y = sp.y + sp.vy * dt -- 390
					if sp.y < 0 then -- 391
						sp.y = 0 -- 392
						sp.vy = -sp.vy * 0.28 -- 393
						sp.vx = sp.vx * 0.62 -- 394
					end -- 394
					self.shards[w + 1] = sp -- 396
					w = w + 1 -- 397
				end -- 397
				i = i + 1 -- 384
			end -- 384
		end -- 384
		__TS__ArraySetLength(self.shards, w) -- 400
		w = 0 -- 403
		do -- 403
			i = 0 -- 404
			while i < #self.rings do -- 404
				local rg = self.rings[i + 1] -- 405
				rg.age = rg.age + dt -- 406
				if rg.age < rg.duration then -- 407
					self.rings[w + 1] = rg -- 408
					w = w + 1 -- 409
				end -- 409
				i = i + 1 -- 404
			end -- 404
		end -- 404
		__TS__ArraySetLength(self.rings, w) -- 412
		ctx.audio:playLoop( -- 415
			"fe04_village_night", -- 415
			"ambience", -- 415
			CHILD_AUDIO_ROOT .. "village_night_loop.wav", -- 415
			0.24, -- 415
			p.ticks -- 415
		) -- 415
	elseif self.underTableFocus == 0 then -- 416
		self.underTableFocus = targetFocus -- 417
	end -- 417
	local focusAnchorX = math.max( -- 421
		p.ox + 305, -- 421
		math.min(p.ox + 455, p.ox + 355 + (p.player.x - (p.ox + 320)) * 0.28) -- 421
	) -- 421
	local zoom = 1.04 + (1 - self.underTableFocus) * 0.04 -- 422
	ctx.cam:setAnchorLock({ -- 423
		footWorldX = focusAnchorX, -- 424
		footWorldY = 0, -- 425
		footDepth = 0, -- 426
		thresholdWorldX = p.ox + 440, -- 427
		screenFootFracX = 0.5, -- 428
		screenFootFracY = 0.235, -- 429
		zoomOverride = zoom -- 430
	}) -- 430
	self.proj = { -- 433
		morph = 1, -- 434
		focal = 390, -- 435
		vpFracX = 0.54, -- 436
		vpFracY = 0.43 - self.underTableFocus * 0.03, -- 437
		vpOffsetX = math.sin(self.animTime * 0.65) * 1.4, -- 438
		vpOffsetY = math.cos(self.animTime * 0.85) * 1, -- 439
		baseDepth = 0 -- 440
	} -- 440
end -- 324
function VillageUndertableScene.prototype.computeDesiredShoeFacing(self, p) -- 444
	if p.scavState == "chase" then -- 445
		return p.player.x >= p.scavX and 1 or -1 -- 446
	end -- 446
	if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 448
		if math.abs(p.scavTargetX - p.scavX) > 2 then -- 449
			return p.scavTargetX >= p.scavX and 1 or -1 -- 450
		end -- 450
	end -- 450
	if p.scavState == "back" and p.room.scavenger ~= nil then -- 453
		local home = math.max( -- 454
			p.room.scavenger.x0, -- 454
			math.min(p.room.scavenger.x1, p.scavX) -- 454
		) -- 454
		if math.abs(home - p.scavX) > 2 then -- 455
			return home > p.scavX and 1 or -1 -- 456
		end -- 456
	end -- 456
	return p.scavDir >= 0 and 1 or -1 -- 459
end -- 444
function VillageUndertableScene.prototype.onBottleLanded(self, ctx, ev) -- 462
	local p = ctx.p -- 463
	local x = type(ev.data.x) == "number" and ev.data.x or p.bottleLandX -- 464
	local y = type(ev.data.y) == "number" and ev.data.y or math.max(0, p.bottleLandY) -- 465
	local explicitSurface = type(ev.data.surface) == "string" and ev.data.surface or nil -- 466
	local surface = self:classifyLandingSurface(p, x, explicitSurface) -- 467
	self.lastSurface = surface -- 469
	self.lastLandX = x -- 470
	if surface == "iron" then -- 472
		self.ironHits = self.ironHits + 1 -- 473
		self.basinShakeTimer = self.basinShakeMax -- 474
		self.shoeToePauseTimer = 0 -- 475
		self.shoeTurnBlend = 0.25 -- 476
		local bx = self:getBasinWorldX(p) -- 477
		local ____self_rings_0 = self.rings -- 479
		____self_rings_0[#____self_rings_0 + 1] = { -- 479
			x = bx, -- 479
			y = 12, -- 479
			age = 0, -- 479
			duration = 1.05, -- 479
			maxRadius = 84, -- 479
			kind = "iron" -- 479
		} -- 479
		local ____self_rings_1 = self.rings -- 480
		____self_rings_1[#____self_rings_1 + 1] = { -- 480
			x = bx, -- 480
			y = 12, -- 480
			age = -0.14, -- 480
			duration = 1.2, -- 480
			maxRadius = 112, -- 480
			kind = "iron" -- 480
		} -- 480
		local ____self_rings_2 = self.rings -- 481
		____self_rings_2[#____self_rings_2 + 1] = { -- 481
			x = bx, -- 481
			y = 12, -- 481
			age = -0.28, -- 481
			duration = 1.32, -- 481
			maxRadius = 136, -- 481
			kind = "iron" -- 481
		} -- 481
		self:spawnShards(bx, 12, "iron", 7) -- 482
		local key = (((("fe04:village:iron_ring:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(ev.tick)) .. ":") .. tostring(ev.seq) -- 485
		ctx.audio:playOnce( -- 486
			key, -- 487
			"sfx", -- 488
			CHILD_AUDIO_ROOT .. "bottle_iron_ring.wav", -- 489
			0.82, -- 490
			"fe04:bottle:iron_ring", -- 491
			ev.tick, -- 492
			ev.seq -- 493
		) -- 493
	elseif surface == "brick" then -- 495
		self.brickHits = self.brickHits + 1 -- 496
		self.shoeToePauseTimer = 0.14 -- 498
		local ____self_rings_3 = self.rings -- 499
		____self_rings_3[#____self_rings_3 + 1] = { -- 499
			x = x, -- 499
			y = math.max(2, y), -- 499
			age = 0, -- 499
			duration = 0.44, -- 499
			maxRadius = 58, -- 499
			kind = "brick" -- 499
		} -- 499
		self:spawnShards( -- 500
			x, -- 500
			math.max(2, y), -- 500
			"brick", -- 500
			9 -- 500
		) -- 500
	else -- 500
		self.softHits = self.softHits + 1 -- 502
		local ____self_rings_4 = self.rings -- 503
		____self_rings_4[#____self_rings_4 + 1] = { -- 503
			x = x, -- 503
			y = math.max(2, y), -- 503
			age = 0, -- 503
			duration = 0.36, -- 503
			maxRadius = 24, -- 503
			kind = "soft" -- 503
		} -- 503
		self:spawnShards( -- 504
			x, -- 504
			math.max(2, y), -- 504
			"soft", -- 504
			6 -- 504
		) -- 504
		local audioKey = ((((((("r" .. tostring(ctx.events.roomSessionId)) .. ":cp") .. tostring(ctx.events.checkpoint)) .. ":t") .. tostring(ev.tick)) .. ":s") .. tostring(ev.seq)) .. ":bottleLanded" -- 507
		if not ctx.audio:hasPlayed(audioKey) then -- 508
			local key = (((("fe04:village:soft_thud:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(ev.tick)) .. ":") .. tostring(ev.seq) -- 509
			ctx.audio:playOnce( -- 510
				key, -- 511
				"sfx", -- 512
				CHILD_AUDIO_ROOT .. "bottle_soft.wav", -- 513
				0.76, -- 514
				"fe04:bottle:soft_thud", -- 515
				ev.tick, -- 516
				ev.seq -- 517
			) -- 517
		end -- 517
	end -- 517
end -- 462
function VillageUndertableScene.prototype.spawnShards(self, x, y, kind, count) -- 523
	local i = 0 -- 524
	do -- 524
		i = 0 -- 525
		while i < count do -- 525
			local ang = (0.18 + self:rand() * 0.64) * math.pi -- 526
			local spd = (kind == "soft" and 28 or 65) + self:rand() * (kind == "soft" and 36 or 95) -- 527
			local ____self_shards_5 = self.shards -- 528
			____self_shards_5[#____self_shards_5 + 1] = { -- 528
				x = x + (self:rand() - 0.5) * 10, -- 529
				y = y + 2, -- 530
				vx = math.cos(ang) * spd * (self:rand() > 0.5 and 1 or -1), -- 531
				vy = math.sin(ang) * spd, -- 532
				size = kind == "soft" and 2.2 + self:rand() * 2.4 or 1.8 + self:rand() * 2.2, -- 533
				life = (kind == "soft" and 0.34 or 0.48) + self:rand() * 0.22, -- 534
				maxLife = 0.65, -- 535
				kind = kind -- 536
			} -- 536
			i = i + 1 -- 525
		end -- 525
	end -- 525
end -- 523
function VillageUndertableScene.prototype.triggerRehearsalImpact(self, ctx, surface) -- 542
	local p = ctx.p -- 543
	local x = surface == "iron" and self:getBasinWorldX(p) or (surface == "soft" and self:getSoftWorldX(p) or self:getBrickWorldX(p)) -- 544
	self:onBottleLanded(ctx, {seq = 9000 + self.brickHits + self.ironHits + self.softHits, tick = p.ticks, name = "bottleLanded", data = {x = x, y = 0, surface = surface, heard = true}}) -- 547
end -- 542
function VillageUndertableScene.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 555
	local p = ctx.p -- 561
	local cam = ctx.cam -- 562
	local w = cam.viewW -- 563
	local h = cam.viewH -- 564
	local ox = p.ox -- 565
	local span = math.max(1, p.room.maxX - p.room.minX) -- 568
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 569
	local artW = math.max(w, h * 16 / 9) * 1.24 -- 570
	local artH = artW * 9 / 16 -- 571
	local artY = math.min( -- 572
		0, -- 572
		math.max(h - artH, cam.groundScreenY - artH * 0.24) -- 572
	) -- 572
	local hasPainted = backdropArt:tryPlace( -- 573
		"bgFar_village", -- 573
		"lp_bg_village", -- 573
		w * (0.5 - progress * 0.08), -- 573
		artY, -- 573
		artW, -- 573
		artH, -- 573
		{ -- 573
			color = Color(138, 152, 176, 255), -- 574
			opacity = 0.88, -- 575
			layer = 0 -- 576
		} -- 576
	) -- 576
	local splitY = h * 0.5 -- 579
	fillVGradRect( -- 580
		bgDraw, -- 580
		0, -- 580
		splitY, -- 580
		w, -- 580
		h - splitY, -- 580
		Color(14, 18, 26, 255), -- 580
		Color(7, 9, 15, 255) -- 580
	) -- 580
	fillVGradRect( -- 581
		bgDraw, -- 581
		0, -- 581
		0, -- 581
		w, -- 581
		splitY, -- 581
		Color(24, 28, 38, 255), -- 581
		Color(14, 18, 26, 255) -- 581
	) -- 581
	if not hasPainted then -- 583
		local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 584
		scene:addDistantRidge( -- 585
			{ -- 586
				{x = ox - 140, y = 120}, -- 587
				{x = ox + 120, y = 162}, -- 588
				{x = ox + 360, y = 138}, -- 589
				{x = ox + 590, y = 176}, -- 590
				{x = ox + 860, y = 132} -- 591
			}, -- 591
			-20, -- 593
			420, -- 594
			MING_MATERIALS.distantHill, -- 595
			{bucket = LP_BUCKET.BACKDROP} -- 596
		) -- 596
		scene:flush(bgDraw, bgGlow) -- 598
	end -- 598
	local mistShift = (self.animTime * 9 + cam.x * 0.12) % (w + 420) - 210 -- 602
	backdropArt:tryPlace( -- 603
		"ink_mist_curve", -- 603
		"lp_village_mist", -- 603
		mistShift, -- 603
		h * 0.3, -- 603
		580, -- 603
		114, -- 603
		{ -- 603
			color = Color(128, 148, 174, 255), -- 604
			opacity = 0.2, -- 605
			layer = 4 -- 606
		} -- 606
	) -- 606
	local doorSx = cam:sx(ox + 436) -- 610
	if doorSx > 0 then -- 611
		bgGlow:drawRect( -- 612
			Rect( -- 612
				0, -- 612
				0, -- 612
				math.min(w, doorSx), -- 612
				h -- 612
			), -- 612
			Color(6, 8, 14, 72) -- 612
		) -- 612
	end -- 612
	local mx = w * 0.8 -- 616
	local my = h * 0.84 -- 617
	fillRadialGlow( -- 618
		bgGlow, -- 618
		mx, -- 618
		my, -- 618
		108, -- 618
		108, -- 618
		Color(188, 206, 224, 30), -- 618
		Color(24, 32, 46, 0), -- 618
		16 -- 618
	) -- 618
	local towerPt = projectWorld3D( -- 620
		ox + 668, -- 620
		152, -- 620
		410, -- 620
		cam, -- 620
		self.proj -- 620
	) -- 620
	fillRadialGlow( -- 621
		bgGlow, -- 621
		towerPt.x, -- 621
		towerPt.y, -- 621
		24, -- 621
		24, -- 621
		Color(238, 198, 132, 62), -- 621
		Color(238, 198, 132, 0), -- 621
		12 -- 621
	) -- 621
	bgGlow:drawDot( -- 622
		Vec2(towerPt.x, towerPt.y), -- 622
		2.2, -- 622
		Color(252, 232, 186, 205) -- 622
	) -- 622
	return true -- 624
end -- 555
function VillageUndertableScene.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 627
	local p = ctx.p -- 633
	local cam = ctx.cam -- 634
	local ox = p.ox -- 635
	local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 636
	scene:addBox({ -- 639
		x0 = ox - 40, -- 640
		x1 = ox + 436, -- 641
		y0 = -52, -- 642
		y1 = 0, -- 643
		z0 = -32, -- 644
		z1 = 112, -- 645
		material = MING_MATERIALS.mingTimberDark, -- 646
		bucket = LP_BUCKET.MIDGROUND, -- 647
		highlightTopEdge = true, -- 648
		edgeWidth = 0.7 -- 649
	}) -- 649
	scene:addBox({ -- 651
		x0 = ox + 436, -- 652
		x1 = ox + 760, -- 653
		y0 = -52, -- 654
		y1 = 0, -- 655
		z0 = -32, -- 656
		z1 = 126, -- 657
		material = MING_MATERIALS.mingBrickDark, -- 658
		bucket = LP_BUCKET.MIDGROUND, -- 659
		highlightTopEdge = true, -- 660
		edgeWidth = 0.8 -- 661
	}) -- 661
	scene:addBeveledFrame( -- 665
		ox + 424, -- 665
		ox + 452, -- 665
		0, -- 665
		116, -- 665
		10, -- 665
		16, -- 665
		18, -- 665
		96, -- 665
		MAT_TABLE_WOOD, -- 665
		{ -- 665
			bucket = LP_BUCKET.MIDGROUND, -- 666
			innerRimLight = rgba(196, 188, 174, 255), -- 667
			innerRimStrength = 0.28 -- 668
		} -- 668
	) -- 668
	scene:addBox({ -- 672
		x0 = ox + 96, -- 673
		x1 = ox + 101, -- 674
		y0 = 0, -- 675
		y1 = 52, -- 676
		z0 = -6, -- 677
		z1 = 24, -- 678
		material = MAT_TABLE_WOOD, -- 679
		bucket = LP_BUCKET.WALK_DECK, -- 680
		edgeWidth = 0.8 -- 681
	}) -- 681
	scene:addBox({ -- 683
		x0 = ox + 123, -- 684
		x1 = ox + 128, -- 685
		y0 = 0, -- 686
		y1 = 52, -- 687
		z0 = -6, -- 688
		z1 = 24, -- 689
		material = MAT_TABLE_WOOD, -- 690
		bucket = LP_BUCKET.WALK_DECK, -- 691
		edgeWidth = 0.8 -- 692
	}) -- 692
	scene:addBox({ -- 694
		x0 = ox + 95, -- 695
		x1 = ox + 129, -- 696
		y0 = 24, -- 697
		y1 = 28, -- 698
		z0 = -8, -- 699
		z1 = 26, -- 700
		material = MING_MATERIALS.mingTimber, -- 701
		bucket = LP_BUCKET.WALK_DECK, -- 702
		sortBias = 0.05 -- 703
	}) -- 703
	scene:addBox({ -- 705
		x0 = ox + 94, -- 706
		x1 = ox + 130, -- 707
		y0 = 48, -- 708
		y1 = 52, -- 709
		z0 = -8, -- 710
		z1 = 26, -- 711
		material = MING_MATERIALS.mingTimber, -- 712
		bucket = LP_BUCKET.WALK_DECK, -- 713
		highlightTopEdge = true, -- 714
		sortBias = 0.06 -- 715
	}) -- 715
	scene:addBox({ -- 718
		x0 = ox + 672, -- 719
		x1 = ox + 720, -- 720
		y0 = 0, -- 721
		y1 = 96, -- 722
		z0 = -14, -- 723
		z1 = 96, -- 724
		material = MING_MATERIALS.mingBrick, -- 725
		bucket = LP_BUCKET.MIDGROUND, -- 726
		highlightTopEdge = true, -- 727
		edgeWidth = 0.9 -- 728
	}) -- 728
	scene:addBox({ -- 730
		x0 = ox + 666, -- 731
		x1 = ox + 726, -- 732
		y0 = 96, -- 733
		y1 = 106, -- 734
		z0 = -18, -- 735
		z1 = 100, -- 736
		material = MING_MATERIALS.mingTile, -- 737
		bucket = LP_BUCKET.MIDGROUND, -- 738
		sortBias = 0.08 -- 739
	}) -- 739
	local arch = p.room.arch -- 744
	scene:addBox({ -- 746
		x0 = arch.x0 - 1, -- 747
		x1 = arch.x0 + 7, -- 748
		y0 = 0, -- 749
		y1 = arch.h, -- 750
		z0 = 12, -- 751
		z1 = 22, -- 752
		material = MAT_TABLE_WOOD, -- 753
		bucket = LP_BUCKET.MIDGROUND, -- 754
		edgeWidth = 0.8 -- 755
	}) -- 755
	scene:addBox({ -- 757
		x0 = arch.x1 - 7, -- 758
		x1 = arch.x1 + 1, -- 759
		y0 = 0, -- 760
		y1 = arch.h, -- 761
		z0 = 12, -- 762
		z1 = 22, -- 763
		material = MAT_TABLE_WOOD, -- 764
		bucket = LP_BUCKET.MIDGROUND, -- 765
		edgeWidth = 0.8 -- 766
	}) -- 766
	scene:addBox({ -- 769
		x0 = arch.x0 + 7, -- 770
		x1 = arch.x1 - 7, -- 771
		y0 = arch.h - 5, -- 772
		y1 = arch.h, -- 773
		z0 = 14, -- 774
		z1 = 20, -- 775
		material = MAT_TABLE_WOOD, -- 776
		bucket = LP_BUCKET.MIDGROUND, -- 777
		edgeWidth = 0.6 -- 778
	}) -- 778
	scene:addBox({ -- 781
		x0 = arch.x0 - 8, -- 782
		x1 = arch.x1 + 8, -- 783
		y0 = arch.h, -- 784
		y1 = arch.h + 8, -- 785
		z0 = 4, -- 786
		z1 = 28, -- 787
		material = MAT_TABLE_WOOD, -- 788
		bucket = LP_BUCKET.WALK_DECK, -- 789
		highlightTopEdge = true, -- 790
		edgeWidth = 0.8 -- 791
	}) -- 791
	local culvertX = self:getCulvertWorldX(p) -- 795
	self:buildCulvertEntrance(scene, culvertX) -- 796
	local softX = self:getSoftWorldX(p) -- 800
	self:buildSoftDirtPatch(scene, softX) -- 801
	local brickX = self:getBrickWorldX(p) -- 804
	self:buildHardBrickPatch(scene, brickX) -- 805
	local basinX = self:getBasinWorldX(p) -- 808
	local basinShakeDeg = self.basinShakeAngle * 180 / math.pi * 0.65 -- 809
	local hasBasinArt = worldArt:tryPlace( -- 810
		"sh_iron_basin", -- 811
		"fe04_village_iron_basin", -- 812
		cam:sx(basinX + math.sin(self.basinShakeAngle * 1.4) * 2.5), -- 813
		cam:sy(0) - cam:len(4), -- 814
		cam:len(44), -- 815
		cam:len(28), -- 816
		{layer = 3, angle = basinShakeDeg} -- 817
	) -- 817
	if not hasBasinArt then -- 819
		self:buildIronBasin(scene, basinX) -- 820
	end -- 820
	worldArt:tryPlace( -- 823
		"grass_low", -- 823
		"fe04_village_soft_grass", -- 823
		cam:sx(softX), -- 823
		cam:sy(0) - cam:len(2), -- 823
		cam:len(46), -- 823
		cam:len(14), -- 823
		{ -- 823
			layer = 2, -- 824
			color = Color(108, 114, 96, 255), -- 825
			opacity = 0.78 -- 826
		} -- 826
	) -- 826
	local grateX0 = cam:sx(ox + 566) -- 830
	local grateX1 = cam:sx(ox + 642) -- 831
	local gY = cam:sy(0) -- 832
	local weaverPulse = 0.86 + 0.14 * math.sin(self.animTime * 2.4) -- 833
	fillRadialGlow( -- 834
		fgGlow, -- 834
		cam:sx(ox + 678), -- 834
		cam:sy(64), -- 834
		cam:len(56), -- 834
		cam:len(48), -- 834
		Color( -- 835
			246, -- 835
			194, -- 835
			116, -- 835
			math.floor(62 * weaverPulse + 0.5) -- 835
		), -- 835
		Color(246, 174, 82, 0), -- 835
		14 -- 835
	) -- 835
	do -- 835
		local gb = 0 -- 836
		while gb < 5 do -- 836
			local gx = grateX0 + (grateX1 - grateX0) * (gb + 0.5) / 5 -- 837
			fgGlow:drawSegment( -- 838
				Vec2( -- 838
					gx, -- 838
					gY + cam:len(38) -- 838
				), -- 838
				Vec2( -- 838
					gx - cam:len(10), -- 838
					gY + 2 -- 838
				), -- 838
				1.6, -- 838
				Color(172, 196, 218, 42) -- 838
			) -- 838
			gb = gb + 1 -- 836
		end -- 836
	end -- 836
	scene:addLightShaft( -- 842
		ox + 570, -- 843
		ox + 710, -- 843
		290, -- 843
		ox + 446, -- 844
		ox + 642, -- 844
		0, -- 844
		24, -- 845
		rgba(218, 226, 218, 255), -- 846
		0.13, -- 847
		0.04 -- 848
	) -- 848
	scene:addContactShadow( -- 852
		p.player.x, -- 852
		p.player.y, -- 852
		14, -- 852
		10, -- 852
		0.8, -- 852
		{bucket = LP_BUCKET.PROP, sortBias = 0.4} -- 852
	) -- 852
	if p.room.scavenger ~= nil then -- 853
		scene:addContactShadow( -- 854
			p.scavX, -- 854
			p.room.scavenger.y, -- 854
			19, -- 854
			13, -- 854
			0.84, -- 854
			{bucket = LP_BUCKET.PROP, sortBias = 0.42} -- 854
		) -- 854
	end -- 854
	scene:flush(fgDraw, fgGlow) -- 857
	self:drawSurfaceReadabilityDetails( -- 860
		fgDraw, -- 860
		fgGlow, -- 860
		p, -- 860
		cam, -- 860
		softX, -- 860
		culvertX, -- 860
		basinX, -- 860
		brickX -- 860
	) -- 860
	return true -- 862
end -- 627
function VillageUndertableScene.prototype.buildCulvertEntrance(self, scene, cx) -- 865
	scene:addBox({ -- 867
		x0 = cx - 18, -- 868
		x1 = cx + 18, -- 869
		y0 = -12, -- 870
		y1 = 2, -- 871
		z0 = -6, -- 872
		z1 = 42, -- 873
		material = MAT_CULVERT_STONE, -- 874
		bucket = LP_BUCKET.WALK_DECK, -- 875
		highlightTopEdge = false, -- 876
		edgeWidth = 0.45 -- 877
	}) -- 877
	scene:addQuad3D( -- 880
		vec3(cx - 12, 1, 22), -- 881
		vec3(cx + 12, 1, 22), -- 882
		vec3(cx + 10, 24, 22), -- 883
		vec3(cx - 10, 24, 22), -- 884
		{base = rgba(8, 11, 16, 248)}, -- 885
		{ -- 886
			bucket = LP_BUCKET.MIDGROUND, -- 886
			unlit = true, -- 886
			sortBias = 0.35, -- 886
			edgeColor = rgba(112, 128, 146, 78), -- 886
			edgeWidth = 0.65 -- 886
		} -- 886
	) -- 886
	scene:addBox({ -- 889
		x0 = cx - 15, -- 890
		x1 = cx - 11, -- 891
		y0 = 2, -- 892
		y1 = 22, -- 893
		z0 = 14, -- 894
		z1 = 22, -- 895
		material = MING_MATERIALS.mingTimber, -- 896
		bucket = LP_BUCKET.PROP, -- 897
		highlightTopEdge = false, -- 898
		edgeWidth = 0.4 -- 899
	}) -- 899
	local gi = 0 -- 901
	do -- 901
		gi = 0 -- 902
		while gi < 3 do -- 902
			local gx = cx - 6 + gi * 6 -- 903
			scene:addBox({ -- 904
				x0 = gx - 1, -- 905
				x1 = gx + 1, -- 906
				y0 = 2, -- 907
				y1 = 24, -- 908
				z0 = 18, -- 909
				z1 = 21, -- 910
				material = MING_MATERIALS.mingIron, -- 911
				bucket = LP_BUCKET.PROP, -- 912
				sortBias = 0.1 -- 913
			}) -- 913
			gi = gi + 1 -- 902
		end -- 902
	end -- 902
end -- 865
function VillageUndertableScene.prototype.buildSoftDirtPatch(self, scene, softX) -- 918
	scene:addBox({ -- 919
		x0 = softX - 24, -- 920
		x1 = softX + 24, -- 921
		y0 = -4, -- 922
		y1 = 1.5, -- 923
		z0 = -16, -- 924
		z1 = 28, -- 925
		material = MAT_SOFT_EARTH, -- 926
		bucket = LP_BUCKET.WALK_DECK, -- 927
		sortBias = 0.15, -- 928
		edgeWidth = 0.4 -- 929
	}) -- 929
end -- 918
function VillageUndertableScene.prototype.buildHardBrickPatch(self, scene, brickX) -- 933
	local col = 0 -- 935
	do -- 935
		col = 0 -- 936
		while col < 3 do -- 936
			local bx0 = brickX - 24 + col * 16 -- 937
			local bx1 = bx0 + 14.5 -- 938
			scene:addBox({ -- 939
				x0 = bx0, -- 940
				x1 = bx1, -- 941
				y0 = -4, -- 942
				y1 = 3.2, -- 943
				z0 = -14, -- 944
				z1 = 6, -- 945
				material = MAT_HARD_BRICK, -- 946
				bucket = LP_BUCKET.WALK_DECK, -- 947
				sortBias = 0.2 + col * 0.01, -- 948
				highlightTopEdge = true, -- 949
				edgeWidth = 1 -- 950
			}) -- 950
			scene:addBox({ -- 952
				x0 = bx0 + 4, -- 953
				x1 = bx1 + 4, -- 954
				y0 = -4, -- 955
				y1 = 2.8, -- 956
				z0 = 8, -- 957
				z1 = 26, -- 958
				material = MAT_HARD_BRICK, -- 959
				bucket = LP_BUCKET.WALK_DECK, -- 960
				sortBias = 0.18 + col * 0.01, -- 961
				highlightTopEdge = true, -- 962
				edgeWidth = 0.9 -- 963
			}) -- 963
			col = col + 1 -- 936
		end -- 936
	end -- 936
end -- 933
function VillageUndertableScene.prototype.buildIronBasin(self, scene, basinX) -- 968
	scene:addBox({ -- 970
		x0 = basinX - 14, -- 971
		x1 = basinX + 14, -- 972
		y0 = -2, -- 973
		y1 = 3, -- 974
		z0 = -10, -- 975
		z1 = 14, -- 976
		material = MING_MATERIALS.mingBrickDark, -- 977
		bucket = LP_BUCKET.PROP, -- 978
		sortBias = 0.02 -- 979
	}) -- 979
	local tilt = self.basinShakeAngle -- 982
	local liftL = math.sin(tilt) * 14 -- 983
	local liftR = -liftL -- 984
	local shiftX = math.sin(tilt * 1.4) * 2.5 -- 985
	local baseY = 3 -- 986
	local topY = 14.5 -- 987
	local bx = basinX + shiftX -- 988
	scene:addQuad3D( -- 991
		vec3( -- 992
			bx - 11, -- 992
			baseY + math.max(0, liftL * 0.4), -- 992
			-8 -- 992
		), -- 992
		vec3( -- 993
			bx + 11, -- 993
			baseY + math.max(0, liftR * 0.4), -- 993
			-8 -- 993
		), -- 993
		vec3(bx + 16, topY + liftR, -12), -- 994
		vec3(bx - 16, topY + liftL, -12), -- 995
		MAT_IRON_BASIN, -- 996
		{bucket = LP_BUCKET.PROP, sortBias = 0.25, edgeWidth = 1.2} -- 997
	) -- 997
	scene:addQuad3D( -- 1000
		vec3( -- 1001
			bx - 11, -- 1001
			baseY + math.max(0, liftL * 0.4), -- 1001
			10 -- 1001
		), -- 1001
		vec3( -- 1002
			bx - 11, -- 1002
			baseY + math.max(0, liftL * 0.4), -- 1002
			-8 -- 1002
		), -- 1002
		vec3(bx - 16, topY + liftL, -12), -- 1003
		vec3(bx - 16, topY + liftL, 14), -- 1004
		MAT_IRON_BASIN, -- 1005
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1006
	) -- 1006
	scene:addQuad3D( -- 1008
		vec3( -- 1009
			bx + 11, -- 1009
			baseY + math.max(0, liftR * 0.4), -- 1009
			-8 -- 1009
		), -- 1009
		vec3( -- 1010
			bx + 11, -- 1010
			baseY + math.max(0, liftR * 0.4), -- 1010
			10 -- 1010
		), -- 1010
		vec3(bx + 16, topY + liftR, 14), -- 1011
		vec3(bx + 16, topY + liftR, -12), -- 1012
		MAT_IRON_BASIN, -- 1013
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1014
	) -- 1014
	scene:addQuad3D( -- 1017
		vec3(bx - 14, topY - 1 + liftL, -10), -- 1018
		vec3(bx + 14, topY - 1 + liftR, -10), -- 1019
		vec3(bx + 14, topY - 1 + liftR, 12), -- 1020
		vec3(bx - 14, topY - 1 + liftL, 12), -- 1021
		{ -- 1022
			base = rgba(24, 30, 40, 255), -- 1022
			edge = rgba(232, 238, 246, 235) -- 1022
		}, -- 1022
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 1.5} -- 1023
	) -- 1023
end -- 968
function VillageUndertableScene.prototype.drawSurfaceReadabilityDetails(self, fgDraw, fgGlow, p, cam, softX, culvertX, basinX, brickX) -- 1027
	local y0 = cam:sy(0) -- 1037
	local sx0 = cam:sx(softX - 20) -- 1040
	local sx1 = cam:sx(softX + 20) -- 1041
	local d = 0 -- 1042
	do -- 1042
		d = 0 -- 1043
		while d < 9 do -- 1043
			local dx = sx0 + (sx1 - sx0) * (d + 0.5) / 9 -- 1044
			local dy = y0 - 2.5 + (d % 3 - 1) * 1.8 -- 1045
			fgDraw:drawDot( -- 1046
				Vec2(dx, dy), -- 1046
				1.3, -- 1046
				Color(116, 98, 78, 175) -- 1046
			) -- 1046
			d = d + 1 -- 1043
		end -- 1043
	end -- 1043
	fgDraw:drawEllipse( -- 1048
		Vec2( -- 1048
			cam:sx(softX - 7), -- 1048
			y0 - 1.5 -- 1048
		), -- 1048
		cam:len(4.2), -- 1048
		1.6, -- 1048
		Color(38, 30, 24, 185) -- 1048
	) -- 1048
	fgDraw:drawEllipse( -- 1049
		Vec2( -- 1049
			cam:sx(softX + 8), -- 1049
			y0 - 2 -- 1049
		), -- 1049
		cam:len(4.2), -- 1049
		1.6, -- 1049
		Color(38, 30, 24, 185) -- 1049
	) -- 1049
	local cL = cam:sx(culvertX - 11) -- 1052
	local cR = cam:sx(culvertX + 11) -- 1053
	local cTop = cam:sy(25) -- 1054
	fgDraw:drawSegment( -- 1055
		Vec2(cL, cTop), -- 1055
		Vec2(cR, cTop), -- 1055
		1.6, -- 1055
		Color(196, 210, 224, 210) -- 1055
	) -- 1055
	local rippleShift = math.sin(self.animTime * 2.3) * 3 -- 1056
	fgGlow:drawSegment( -- 1057
		Vec2(cL + 3 + rippleShift, y0 + 2), -- 1057
		Vec2(cR - 4 + rippleShift, y0 + 2), -- 1057
		1.1, -- 1057
		Color(164, 192, 214, 105) -- 1057
	) -- 1057
	local bPtL = projectWorld3D( -- 1060
		basinX - 16, -- 1060
		14.5 + math.sin(self.basinShakeAngle) * 14, -- 1060
		-12, -- 1060
		cam, -- 1060
		self.proj -- 1060
	) -- 1060
	local bPtR = projectWorld3D( -- 1061
		basinX + 16, -- 1061
		14.5 - math.sin(self.basinShakeAngle) * 14, -- 1061
		-12, -- 1061
		cam, -- 1061
		self.proj -- 1061
	) -- 1061
	local shakeBoost = self.basinShakeTimer > 0 and clamp01(self.basinShakeTimer / self.basinShakeMax) or 0 -- 1062
	local rimAlpha = math.floor(205 + 48 * shakeBoost + 0.5) -- 1063
	fgDraw:drawSegment( -- 1064
		Vec2(bPtL.x, bPtL.y), -- 1064
		Vec2(bPtR.x, bPtR.y), -- 1064
		2.1 + shakeBoost * 1.1, -- 1064
		Color(230, 236, 242, rimAlpha) -- 1064
	) -- 1064
	fillRadialGlow( -- 1065
		fgGlow, -- 1066
		(bPtL.x + bPtR.x) * 0.5, -- 1067
		(bPtL.y + bPtR.y) * 0.5, -- 1068
		cam:len(22 + shakeBoost * 18), -- 1069
		cam:len(10 + shakeBoost * 8), -- 1070
		Color( -- 1071
			216, -- 1071
			226, -- 1071
			236, -- 1071
			math.floor(48 + 95 * shakeBoost + 0.5) -- 1071
		), -- 1071
		Color(186, 202, 220, 0), -- 1072
		14 -- 1073
	) -- 1073
	local brL = cam:sx(brickX - 24) -- 1077
	local brR = cam:sx(brickX + 24) -- 1078
	local brTop = cam:sy(3.2) -- 1079
	fgDraw:drawSegment( -- 1080
		Vec2(brL, brTop), -- 1080
		Vec2(brR, brTop), -- 1080
		1.8, -- 1080
		Color(224, 228, 234, 225) -- 1080
	) -- 1080
	local k = 1 -- 1081
	do -- 1081
		k = 1 -- 1082
		while k <= 2 do -- 1082
			local seamX = brL + (brR - brL) * k / 3 -- 1083
			fgDraw:drawSegment( -- 1084
				Vec2(seamX, y0 - 3), -- 1084
				Vec2(seamX, brTop + 1), -- 1084
				1.5, -- 1084
				Color(20, 24, 32, 240) -- 1084
			) -- 1084
			fgDraw:drawSegment( -- 1085
				Vec2(seamX + 1.8, y0 - 2), -- 1085
				Vec2(seamX + 1.8, brTop), -- 1085
				0.9, -- 1085
				Color(214, 218, 224, 175) -- 1085
			) -- 1085
			k = k + 1 -- 1082
		end -- 1082
	end -- 1082
	local i = 0 -- 1089
	do -- 1089
		i = 0 -- 1090
		while i < #self.rings do -- 1090
			do -- 1090
				local rg = self.rings[i + 1] -- 1091
				if rg.age < 0 then -- 1092
					goto __continue80 -- 1093
				end -- 1093
				local t = clamp01(rg.age / rg.duration) -- 1095
				local r = math.max( -- 1096
					4, -- 1096
					cam:len(rg.maxRadius) * (0.14 + 0.86 * t) -- 1096
				) -- 1096
				local alpha = (1 - t) * (rg.kind == "iron" and 0.88 or (rg.kind == "brick" and 0.82 or 0.4)) -- 1097
				local rx = cam:sx(rg.x) -- 1098
				local ry = cam:sy(rg.y) -- 1099
				local ringCol = rg.kind == "iron" and Color( -- 1100
					220, -- 1101
					234, -- 1101
					246, -- 1101
					math.floor(235 * alpha + 0.5) -- 1101
				) or (rg.kind == "brick" and Color( -- 1102
					236, -- 1103
					216, -- 1103
					178, -- 1103
					math.floor(225 * alpha + 0.5) -- 1103
				) or Color( -- 1104
					148, -- 1104
					134, -- 1104
					114, -- 1104
					math.floor(165 * alpha + 0.5) -- 1104
				)) -- 1104
				drawEllipseRing( -- 1105
					fgGlow, -- 1105
					rx, -- 1105
					ry, -- 1105
					r, -- 1105
					r * 0.34, -- 1105
					rg.kind == "iron" and 1.8 or 1.4, -- 1105
					ringCol, -- 1105
					22 -- 1105
				) -- 1105
				if rg.kind == "iron" then -- 1106
					drawEllipseRing( -- 1107
						fgDraw, -- 1107
						rx, -- 1107
						ry, -- 1107
						r * 0.96, -- 1107
						r * 0.32, -- 1107
						1.1, -- 1107
						Color( -- 1107
							214, -- 1107
							224, -- 1107
							236, -- 1107
							math.floor(150 * alpha + 0.5) -- 1107
						), -- 1107
						22 -- 1107
					) -- 1107
				end -- 1107
			end -- 1107
			::__continue80:: -- 1107
			i = i + 1 -- 1090
		end -- 1090
	end -- 1090
	do -- 1090
		i = 0 -- 1110
		while i < #self.shards do -- 1110
			local sp = self.shards[i + 1] -- 1111
			local a = clamp01(sp.life / sp.maxLife) -- 1112
			local col = sp.kind == "soft" and Color( -- 1113
				138, -- 1114
				120, -- 1114
				98, -- 1114
				math.floor(170 * a + 0.5) -- 1114
			) or (sp.kind == "iron" and Color( -- 1115
				224, -- 1116
				232, -- 1116
				242, -- 1116
				math.floor(225 * a + 0.5) -- 1116
			) or Color( -- 1117
				216, -- 1117
				198, -- 1117
				174, -- 1117
				math.floor(220 * a + 0.5) -- 1117
			)) -- 1117
			fgDraw:drawDot( -- 1118
				Vec2( -- 1118
					cam:sx(sp.x), -- 1118
					cam:sy(sp.y) -- 1118
				), -- 1118
				sp.size, -- 1118
				col -- 1118
			) -- 1118
			i = i + 1 -- 1110
		end -- 1110
	end -- 1110
	if p.bottleLandT > 0 and p.bottleLandX >= 0 and #self.rings == 0 then -- 1122
		local rx = cam:sx(p.bottleLandX) -- 1123
		local ry = cam:sy(math.max(1, p.bottleLandY)) -- 1124
		fgDraw:drawDot( -- 1125
			Vec2(rx, ry), -- 1125
			2.5, -- 1125
			Color(216, 206, 186, 150) -- 1125
		) -- 1125
	end -- 1125
end -- 1027
function VillageUndertableScene.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1130
	local p = ctx.p -- 1136
	local cam = ctx.cam -- 1137
	local bottle = p.room.bottle -- 1140
	if bottle ~= nil and not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 1141
		self:drawCeramicBottle( -- 1142
			fgDraw, -- 1142
			fgGlow, -- 1142
			worldArt, -- 1142
			"fe04_bottle_shelf", -- 1142
			cam:sx(bottle.x), -- 1142
			cam:sy(56), -- 1142
			cam.ppu, -- 1142
			0, -- 1142
			true -- 1142
		) -- 1142
	end -- 1142
	if p.hasBottle and p.aimHold <= 0 then -- 1146
		local pl = p.player -- 1147
		self:drawCeramicBottle( -- 1148
			fgDraw, -- 1149
			fgGlow, -- 1150
			worldArt, -- 1151
			"fe04_bottle_held", -- 1152
			cam:sx(pl.x + pl.facing * 10), -- 1153
			cam:sy(pl.y + pl.h * 0.52), -- 1154
			cam.ppu, -- 1155
			pl.facing * 0.22, -- 1156
			false -- 1157
		) -- 1157
	end -- 1157
	if p.bottleFly ~= nil then -- 1160
		self:drawCeramicBottle( -- 1161
			fgDraw, -- 1162
			fgGlow, -- 1163
			worldArt, -- 1164
			"fe04_bottle_air", -- 1165
			cam:sx(p.bottleFly.x), -- 1166
			cam:sy(p.bottleFly.y), -- 1167
			cam.ppu, -- 1168
			self.animTime * 13.5, -- 1169
			false -- 1170
		) -- 1170
	end -- 1170
	if p.hasBottle and p.aimHold > 0 then -- 1175
		local pl = p.player -- 1176
		local endX = p.bottleAimX -- 1177
		local endY = p.bottleAimY -- 1178
		if endX < 0 then -- 1179
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 1180
			endX = wAim.x -- 1181
			endY = 0 -- 1182
		end -- 1182
		local dir = endX >= pl.x and 1 or -1 -- 1184
		local x0 = pl.x + dir * 10 -- 1185
		local y0 = pl.y + pl.h * 0.7 -- 1186
		local vx = (endX - x0) / BOTTLE_FLY_T -- 1187
		local vy = (endY - y0 + 0.5 * GRAVITY * BOTTLE_FLY_T * BOTTLE_FLY_T) / BOTTLE_FLY_T -- 1188
		local previewSurface = self:classifyLandingSurface(p, endX) -- 1190
		local arcRgb = previewSurface == "iron" and rgba(214, 228, 242, 255) or (previewSurface == "brick" and rgba(232, 206, 152, 255) or rgba(154, 142, 126, 255)) -- 1191
		local steps = 18 -- 1197
		local k = 1 -- 1198
		do -- 1198
			k = 1 -- 1199
			while k <= steps do -- 1199
				local tt = k / steps * BOTTLE_FLY_T -- 1200
				local wx = x0 + vx * tt -- 1201
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 1202
				local alpha = 195 * (0.4 + 0.6 * (k / steps)) -- 1203
				fgDraw:drawDot( -- 1204
					Vec2( -- 1204
						cam:sx(wx), -- 1204
						cam:sy(wy) -- 1204
					), -- 1204
					2.5, -- 1204
					toColor(arcRgb, alpha) -- 1204
				) -- 1204
				fgGlow:drawDot( -- 1205
					Vec2( -- 1205
						cam:sx(wx), -- 1205
						cam:sy(wy) -- 1205
					), -- 1205
					3.2, -- 1205
					toColor(arcRgb, alpha * 0.55) -- 1205
				) -- 1205
				k = k + 1 -- 1199
			end -- 1199
		end -- 1199
		local lx = cam:sx(endX) -- 1208
		local ly = cam:sy(endY + 2) -- 1209
		local pulse = 0.88 + 0.12 * math.sin(self.animTime * 5.2) -- 1210
		drawEllipseRing( -- 1211
			fgDraw, -- 1211
			lx, -- 1211
			ly, -- 1211
			11 * pulse, -- 1211
			4.2 * pulse, -- 1211
			1.6, -- 1211
			toColor(arcRgb, 235), -- 1211
			20 -- 1211
		) -- 1211
		if previewSurface == "iron" then -- 1212
			drawEllipseRing( -- 1213
				fgGlow, -- 1213
				lx, -- 1213
				ly, -- 1213
				24 * pulse, -- 1213
				9.2 * pulse, -- 1213
				1.3, -- 1213
				toColor(arcRgb, 195), -- 1213
				22 -- 1213
			) -- 1213
		elseif previewSurface == "brick" then -- 1214
			drawEllipseRing( -- 1215
				fgGlow, -- 1215
				lx, -- 1215
				ly, -- 1215
				18 * pulse, -- 1215
				7 * pulse, -- 1215
				1.2, -- 1215
				toColor(arcRgb, 165), -- 1215
				20 -- 1215
			) -- 1215
		end -- 1215
	end -- 1215
	return true -- 1219
end -- 1130
function VillageUndertableScene.prototype.drawCeramicBottle(self, fgDraw, fgGlow, worldArt, id, cx, cy, ppu, tilt, shelfGlint) -- 1222
	local size = math.max(10, ppu * 10.5) -- 1233
	if not worldArt:tryPlace( -- 1234
		"prop_bottle", -- 1234
		id, -- 1234
		cx, -- 1234
		cy, -- 1234
		size, -- 1234
		size, -- 1234
		{angle = tilt * 180 / math.pi, layer = 8} -- 1234
	) then -- 1234
		fgDraw:drawCircle( -- 1238
			Vec2(cx, cy), -- 1238
			size * 0.36, -- 1238
			Color(172, 138, 102, 245) -- 1238
		) -- 1238
	end -- 1238
	if shelfGlint then -- 1240
		local p = 0.72 + 0.28 * math.sin(self.animTime * 3) -- 1241
		fillRadialGlow( -- 1242
			fgGlow, -- 1242
			cx, -- 1242
			cy + 2, -- 1242
			14 * p, -- 1242
			14 * p, -- 1242
			Color( -- 1242
				224, -- 1242
				214, -- 1242
				190, -- 1242
				math.floor(62 * p + 0.5) -- 1242
			), -- 1242
			Color(224, 214, 190, 0), -- 1242
			12 -- 1242
		) -- 1242
	end -- 1242
end -- 1222
function VillageUndertableScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1247
	local p = ctx.p -- 1253
	local cam = ctx.cam -- 1254
	if p.room.scavenger ~= nil then -- 1255
		self:drawScavengerShoeOverlay(fgDraw, fgGlow, p, cam) -- 1256
	end -- 1256
	if ctx.paused then -- 1260
		local arch = p.room.arch -- 1261
		local pTopBL = projectWorld3D( -- 1262
			arch.x0 - 8, -- 1262
			arch.h, -- 1262
			-15, -- 1262
			cam, -- 1262
			self.proj -- 1262
		) -- 1262
		local pTopTR = projectWorld3D( -- 1263
			arch.x1 + 8, -- 1263
			arch.h + 8, -- 1263
			-15, -- 1263
			cam, -- 1263
			self.proj -- 1263
		) -- 1263
		worldArt:tryPlace( -- 1264
			"cover_wood", -- 1265
			"fe04_pause_table_top", -- 1266
			(pTopBL.x + pTopTR.x) * 0.5, -- 1267
			pTopBL.y, -- 1268
			math.max( -- 1269
				20, -- 1269
				math.abs(pTopTR.x - pTopBL.x) -- 1269
			), -- 1269
			math.max( -- 1270
				8, -- 1270
				math.abs(pTopTR.y - pTopBL.y) -- 1270
			), -- 1270
			{ -- 1271
				color = Color(46, 35, 27, 255), -- 1271
				opacity = 0.96, -- 1271
				layer = 5300 -- 1271
			} -- 1271
		) -- 1271
		local legBL = projectWorld3D( -- 1273
			arch.x1 - 6, -- 1273
			0, -- 1273
			-15, -- 1273
			cam, -- 1273
			self.proj -- 1273
		) -- 1273
		local legTR = projectWorld3D( -- 1274
			arch.x1 + 1, -- 1274
			arch.h, -- 1274
			-15, -- 1274
			cam, -- 1274
			self.proj -- 1274
		) -- 1274
		worldArt:tryPlace( -- 1275
			"cover_wood", -- 1276
			"fe04_pause_table_leg", -- 1277
			(legBL.x + legTR.x) * 0.5, -- 1278
			legBL.y, -- 1279
			math.max( -- 1280
				6, -- 1280
				math.abs(legTR.x - legBL.x) -- 1280
			), -- 1280
			math.max( -- 1281
				16, -- 1281
				math.abs(legTR.y - legBL.y) -- 1281
			), -- 1281
			{ -- 1282
				color = Color(34, 25, 19, 255), -- 1282
				opacity = 0.96, -- 1282
				layer = 5310 -- 1282
			} -- 1282
		) -- 1282
	end -- 1282
end -- 1247
function VillageUndertableScene.prototype.drawScavengerShoeOverlay(self, fgDraw, fgGlow, p, cam) -- 1287
	local cx = cam:sx(p.scavX) -- 1293
	local by = cam:sy(p.room.scavenger ~= nil and p.room.scavenger.y or 0) -- 1294
	local f = self.shoeFacing >= 0 and 1 or -1 -- 1295
	local moving = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 1296
	local stride = moving and math.sin(self.scavStridePhase) * cam:len(7.2) or 0 -- 1297
	local pausedToe = self.shoeToePauseTimer > 0 -- 1298
	fillRadialGlow( -- 1301
		fgGlow, -- 1301
		cx + f * cam:len(4), -- 1301
		by + 2, -- 1301
		cam:len(32), -- 1301
		cam:len(8), -- 1301
		Color(196, 208, 220, 48), -- 1301
		Color(156, 172, 190, 0), -- 1301
		14 -- 1301
	) -- 1301
	fgDraw:drawEllipse( -- 1302
		Vec2( -- 1302
			cx + f * cam:len(2), -- 1302
			by + 1 -- 1302
		), -- 1302
		cam:len(19), -- 1302
		cam:len(3.4), -- 1302
		Color(92, 102, 114, 72) -- 1302
	) -- 1302
	local function drawSingleShoe(footX, liftY, isFront) -- 1305
		local heelX = footX - f * cam:len(4.8) -- 1306
		local midX = footX + f * cam:len(1.8) -- 1307
		local toeX = footX + f * cam:len(7.6) -- 1308
		local soleY = by + 0.8 + liftY -- 1309
		local shoeH = cam:len(4.4) -- 1310
		fgDraw:drawPolygon( -- 1312
			{ -- 1312
				Vec2(heelX, soleY), -- 1313
				Vec2(toeX, soleY), -- 1314
				Vec2( -- 1315
					toeX - f * cam:len(1), -- 1315
					soleY + shoeH * 0.56 -- 1315
				), -- 1315
				Vec2(midX, soleY + shoeH * 0.96), -- 1316
				Vec2( -- 1317
					heelX + f * cam:len(0.6), -- 1317
					soleY + shoeH * 0.86 -- 1317
				) -- 1317
			}, -- 1317
			isFront and Color(68, 58, 48, 250) or Color(46, 40, 34, 240) -- 1318
		) -- 1318
		local soleCol = isFront and Color(198, 192, 178, 232) or Color(148, 144, 134, 195) -- 1320
		fgDraw:drawSegment( -- 1321
			Vec2(heelX, soleY + 0.6), -- 1321
			Vec2(toeX, soleY + 0.6), -- 1321
			1.5, -- 1321
			soleCol -- 1321
		) -- 1321
		fgDraw:drawSegment( -- 1323
			Vec2( -- 1323
				toeX - f * cam:len(1.2), -- 1323
				soleY + 0.8 -- 1323
			), -- 1323
			Vec2( -- 1323
				toeX - f * cam:len(1.4), -- 1323
				soleY + shoeH * 0.56 -- 1323
			), -- 1323
			1.3, -- 1323
			Color(214, 210, 198, isFront and 220 or 165) -- 1323
		) -- 1323
		if isFront and pausedToe then -- 1325
			fgGlow:drawDot( -- 1326
				Vec2(toeX, soleY + 1.5), -- 1326
				3, -- 1326
				Color(236, 218, 178, 155) -- 1326
			) -- 1326
		end -- 1326
	end -- 1305
	local backLift = moving and math.max( -- 1330
		0, -- 1330
		-math.sin(self.scavStridePhase) -- 1330
	) * cam:len(2.4) or 0 -- 1330
	local frontLift = moving and math.max( -- 1331
		0, -- 1331
		math.sin(self.scavStridePhase) -- 1331
	) * cam:len(2.8) or 0 -- 1331
	drawSingleShoe( -- 1332
		cx - stride - f * cam:len(3.5), -- 1332
		backLift, -- 1332
		false -- 1332
	) -- 1332
	drawSingleShoe( -- 1333
		cx + stride + f * cam:len(4), -- 1333
		frontLift, -- 1333
		true -- 1333
	) -- 1333
end -- 1287
function VillageUndertableScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 1343
	local p = ctx.p -- 1350
	local cam = ctx.cam -- 1351
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1352
	local arch = p.room.arch -- 1353
	local xLeft = arch.x0 - 8 -- 1355
	local xRight = arch.x1 + 8 -- 1356
	local tableBotY = arch.h -- 1357
	local tableTopY = arch.h + 8 -- 1358
	local zFront = -15 -- 1359
	local zMid = 4 -- 1360
	local function drawFrontLeg(lx0, lx1) -- 1363
		local mBL = projectWorld3D( -- 1364
			lx0, -- 1364
			0, -- 1364
			zFront, -- 1364
			cam, -- 1364
			self.proj -- 1364
		) -- 1364
		local mBR = projectWorld3D( -- 1365
			lx1, -- 1365
			0, -- 1365
			zFront, -- 1365
			cam, -- 1365
			self.proj -- 1365
		) -- 1365
		local mTR = projectWorld3D( -- 1366
			lx1, -- 1366
			tableBotY, -- 1366
			zFront, -- 1366
			cam, -- 1366
			self.proj -- 1366
		) -- 1366
		local mTL = projectWorld3D( -- 1367
			lx0, -- 1367
			tableBotY, -- 1367
			zFront, -- 1367
			cam, -- 1367
			self.proj -- 1367
		) -- 1367
		drawUiQuad( -- 1368
			uiDraw, -- 1368
			mBL, -- 1368
			mBR, -- 1368
			mTR, -- 1368
			mTL, -- 1368
			Color(26, 20, 15, 250), -- 1368
			Color(38, 29, 22, 252), -- 1368
			inv, -- 1368
			Color(88, 70, 54, 145), -- 1368
			0.9 -- 1368
		) -- 1368
		local sBR = projectWorld3D( -- 1370
			lx1, -- 1370
			0, -- 1370
			zFront + 7, -- 1370
			cam, -- 1370
			self.proj -- 1370
		) -- 1370
		local sTR = projectWorld3D( -- 1371
			lx1, -- 1371
			tableBotY, -- 1371
			zFront + 7, -- 1371
			cam, -- 1371
			self.proj -- 1371
		) -- 1371
		drawUiQuad( -- 1372
			uiDraw, -- 1372
			mBR, -- 1372
			sBR, -- 1372
			sTR, -- 1372
			mTR, -- 1372
			Color(44, 34, 26, 248), -- 1372
			Color(66, 52, 40, 250), -- 1372
			inv, -- 1372
			Color(138, 120, 102, 155), -- 1372
			0.8 -- 1372
		) -- 1372
	end -- 1363
	drawFrontLeg(arch.x0 - 1, arch.x0 + 6) -- 1374
	drawFrontLeg(arch.x1 - 6, arch.x1 + 1) -- 1375
	local bFarL = projectWorld3D( -- 1378
		xLeft, -- 1378
		tableBotY, -- 1378
		zMid, -- 1378
		cam, -- 1378
		self.proj -- 1378
	) -- 1378
	local bFarR = projectWorld3D( -- 1379
		xRight, -- 1379
		tableBotY, -- 1379
		zMid, -- 1379
		cam, -- 1379
		self.proj -- 1379
	) -- 1379
	local bNearR = projectWorld3D( -- 1380
		xRight, -- 1380
		tableBotY, -- 1380
		zFront, -- 1380
		cam, -- 1380
		self.proj -- 1380
	) -- 1380
	local bNearL = projectWorld3D( -- 1381
		xLeft, -- 1381
		tableBotY, -- 1381
		zFront, -- 1381
		cam, -- 1381
		self.proj -- 1381
	) -- 1381
	drawUiQuad( -- 1382
		uiDraw, -- 1382
		bFarL, -- 1382
		bFarR, -- 1382
		bNearR, -- 1382
		bNearL, -- 1382
		Color(18, 14, 11, 236), -- 1382
		Color(28, 21, 16, 242), -- 1382
		inv, -- 1382
		Color(76, 58, 44, 115), -- 1382
		0.8 -- 1382
	) -- 1382
	local fTopR = projectWorld3D( -- 1385
		xRight, -- 1385
		tableTopY, -- 1385
		zFront, -- 1385
		cam, -- 1385
		self.proj -- 1385
	) -- 1385
	local fTopL = projectWorld3D( -- 1386
		xLeft, -- 1386
		tableTopY, -- 1386
		zFront, -- 1386
		cam, -- 1386
		self.proj -- 1386
	) -- 1386
	drawUiQuad( -- 1387
		uiDraw, -- 1387
		bNearL, -- 1387
		bNearR, -- 1387
		fTopR, -- 1387
		fTopL, -- 1387
		Color(38, 28, 21, 252), -- 1387
		Color(56, 42, 32, 254), -- 1387
		inv, -- 1387
		Color(124, 98, 76, 155), -- 1387
		1 -- 1387
	) -- 1387
	uiDraw:drawSegment( -- 1389
		Vec2(bNearL.x * inv, bNearL.y * inv), -- 1389
		Vec2(bNearR.x * inv, bNearR.y * inv), -- 1389
		1.2, -- 1389
		Color(142, 122, 100, 175) -- 1389
	) -- 1389
	local topBackL = projectWorld3D( -- 1392
		xLeft, -- 1392
		tableTopY, -- 1392
		zMid, -- 1392
		cam, -- 1392
		self.proj -- 1392
	) -- 1392
	local topBackR = projectWorld3D( -- 1393
		xRight, -- 1393
		tableTopY, -- 1393
		zMid, -- 1393
		cam, -- 1393
		self.proj -- 1393
	) -- 1393
	drawUiQuad( -- 1394
		uiDraw, -- 1394
		fTopL, -- 1394
		fTopR, -- 1394
		topBackR, -- 1394
		topBackL, -- 1394
		Color(52, 40, 30, 244), -- 1394
		Color(32, 24, 19, 236), -- 1394
		inv, -- 1394
		Color(132, 110, 88, 130), -- 1394
		0.8 -- 1394
	) -- 1394
	local bowlBL = projectWorld3D( -- 1397
		arch.x0 + 24, -- 1397
		tableTopY + 0.5, -- 1397
		-5, -- 1397
		cam, -- 1397
		self.proj -- 1397
	) -- 1397
	local bowlBR = projectWorld3D( -- 1398
		arch.x0 + 38, -- 1398
		tableTopY + 0.5, -- 1398
		-5, -- 1398
		cam, -- 1398
		self.proj -- 1398
	) -- 1398
	local bowlTR = projectWorld3D( -- 1399
		arch.x0 + 40, -- 1399
		tableTopY + 6.5, -- 1399
		-5, -- 1399
		cam, -- 1399
		self.proj -- 1399
	) -- 1399
	local bowlTL = projectWorld3D( -- 1400
		arch.x0 + 22, -- 1400
		tableTopY + 6.5, -- 1400
		-5, -- 1400
		cam, -- 1400
		self.proj -- 1400
	) -- 1400
	drawUiQuad( -- 1401
		uiDraw, -- 1401
		bowlBL, -- 1401
		bowlBR, -- 1401
		bowlTR, -- 1401
		bowlTL, -- 1401
		Color(72, 68, 62, 244), -- 1401
		Color(118, 114, 106, 246), -- 1401
		inv, -- 1401
		Color(172, 166, 156, 175), -- 1401
		0.8 -- 1401
	) -- 1401
	local scavNear = p.room.scavenger ~= nil and clamp01(1 - math.abs(p.scavX - (arch.x0 + 56)) / 220) or 0 -- 1404
	local clothSway = math.sin(self.scavStridePhase * 1.4 + self.animTime * 1.8) * (1.2 + scavNear * 2.8) -- 1405
	local clothL = projectWorld3D( -- 1406
		xLeft + 2 + clothSway, -- 1406
		tableBotY - 9, -- 1406
		zFront, -- 1406
		cam, -- 1406
		self.proj -- 1406
	) -- 1406
	local clothR = projectWorld3D( -- 1407
		xLeft + 28 + clothSway * 0.4, -- 1407
		tableBotY - 1, -- 1407
		zFront, -- 1407
		cam, -- 1407
		self.proj -- 1407
	) -- 1407
	uiDraw:drawVertices({ -- 1408
		{ -- 1409
			Vec2(bNearL.x * inv, bNearL.y * inv), -- 1409
			Color(32, 25, 21, 228) -- 1409
		}, -- 1409
		{ -- 1410
			Vec2(clothL.x * inv, clothL.y * inv), -- 1410
			Color(44, 35, 29, 218) -- 1410
		}, -- 1410
		{ -- 1411
			Vec2(clothR.x * inv, clothR.y * inv), -- 1411
			Color(28, 22, 19, 204) -- 1411
		} -- 1411
	}) -- 1411
	do -- 1411
		local g = 1 -- 1414
		while g <= 3 do -- 1414
			local frac = g / 4 -- 1415
			local gx0 = bNearL.x * inv + (fTopL.x - bNearL.x) * inv * frac -- 1416
			local gy0 = bNearL.y * inv + (fTopL.y - bNearL.y) * inv * frac -- 1417
			local gx1 = bNearR.x * inv + (fTopR.x - bNearR.x) * inv * frac -- 1418
			local gy1 = bNearR.y * inv + (fTopR.y - bNearR.y) * inv * frac -- 1419
			uiDraw:drawSegment( -- 1420
				Vec2(gx0, gy0), -- 1420
				Vec2(gx1, gy1), -- 1420
				0.7, -- 1420
				Color(24, 17, 13, 128) -- 1420
			) -- 1420
			g = g + 1 -- 1414
		end -- 1414
	end -- 1414
	if p.player.crouch and p.player.x >= arch.x0 - 16 and p.player.x <= arch.x1 + 16 then -- 1424
		local topBandH = ctx.uiH * 0.14 -- 1425
		fillVGradRect( -- 1426
			uiDraw, -- 1427
			0, -- 1428
			ctx.uiH - topBandH, -- 1429
			ctx.uiW, -- 1430
			topBandH, -- 1431
			Color(12, 10, 9, 0), -- 1432
			Color(12, 10, 9, 138) -- 1433
		) -- 1433
	end -- 1433
	return false -- 1438
end -- 1343
return ____exports -- 1343
