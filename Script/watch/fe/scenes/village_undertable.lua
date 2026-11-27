-- [ts]: village_undertable.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 19
local Color = ____Dora.Color -- 19
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
function VillageUndertableScene.prototype.drawBackdrop(self, bgDraw, bgGlow, _backdropArt, ctx) -- 555
	local p = ctx.p -- 561
	local cam = ctx.cam -- 562
	local w = cam.viewW -- 563
	local h = cam.viewH -- 564
	local splitY = h * 0.5 -- 567
	fillVGradRect( -- 568
		bgDraw, -- 568
		0, -- 568
		splitY, -- 568
		w, -- 568
		h - splitY, -- 568
		Color(14, 18, 26, 255), -- 568
		Color(7, 9, 15, 255) -- 568
	) -- 568
	fillVGradRect( -- 569
		bgDraw, -- 569
		0, -- 569
		0, -- 569
		w, -- 569
		splitY, -- 569
		Color(24, 28, 38, 255), -- 569
		Color(14, 18, 26, 255) -- 569
	) -- 569
	local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 571
	local ox = p.ox -- 572
	scene:addDistantRidge( -- 575
		{ -- 576
			{x = ox - 140, y = 120}, -- 577
			{x = ox + 120, y = 162}, -- 578
			{x = ox + 360, y = 138}, -- 579
			{x = ox + 590, y = 176}, -- 580
			{x = ox + 860, y = 132} -- 581
		}, -- 581
		-20, -- 583
		420, -- 584
		MING_MATERIALS.distantHill, -- 585
		{bucket = LP_BUCKET.BACKDROP} -- 586
	) -- 586
	scene:addBox({ -- 590
		x0 = ox + 460, -- 591
		x1 = ox + 690, -- 592
		y0 = 0, -- 593
		y1 = 118, -- 594
		z0 = 210, -- 595
		z1 = 260, -- 596
		material = MING_MATERIALS.distantWall, -- 597
		bucket = LP_BUCKET.BACKDROP, -- 598
		edgeWidth = 0 -- 599
	}) -- 599
	scene:addTri3D( -- 601
		vec3(ox + 446, 118, 206), -- 602
		vec3(ox + 704, 118, 206), -- 603
		vec3(ox + 575, 162, 232), -- 604
		MING_MATERIALS.mingTile, -- 605
		{bucket = LP_BUCKET.BACKDROP, sortBias = 0.04} -- 606
	) -- 606
	scene:addBox({ -- 610
		x0 = ox - 60, -- 611
		x1 = ox + 436, -- 612
		y0 = 0, -- 613
		y1 = 196, -- 614
		z0 = 112, -- 615
		z1 = 152, -- 616
		material = MING_MATERIALS.mingBrickDark, -- 617
		bucket = LP_BUCKET.BACKDROP, -- 618
		edgeWidth = 0.6 -- 619
	}) -- 619
	scene:addBox({ -- 623
		x0 = ox + 150, -- 624
		x1 = ox + 258, -- 625
		y0 = 0, -- 626
		y1 = 42, -- 627
		z0 = 76, -- 628
		z1 = 112, -- 629
		material = MAT_CLAY_STOVE, -- 630
		bucket = LP_BUCKET.MIDGROUND, -- 631
		highlightTopEdge = true -- 632
	}) -- 632
	scene:addBox({ -- 634
		x0 = ox + 178, -- 635
		x1 = ox + 228, -- 636
		y0 = 42, -- 637
		y1 = 156, -- 638
		z0 = 94, -- 639
		z1 = 114, -- 640
		material = MAT_CLAY_STOVE, -- 641
		bucket = LP_BUCKET.MIDGROUND, -- 642
		edgeWidth = 0.5 -- 643
	}) -- 643
	scene:addBox({ -- 647
		x0 = ox + 486, -- 648
		x1 = ox + 536, -- 649
		y0 = 0, -- 650
		y1 = 34, -- 651
		z0 = 126, -- 652
		z1 = 162, -- 653
		material = MING_MATERIALS.mingStoneStep, -- 654
		bucket = LP_BUCKET.MIDGROUND, -- 655
		highlightTopEdge = true -- 656
	}) -- 656
	scene:addFogBand( -- 660
		ox - 120, -- 660
		ox + 840, -- 660
		-10, -- 660
		140, -- 660
		260, -- 660
		rgba(24, 30, 42, 255), -- 660
		0.62, -- 660
		0.05, -- 660
		{bucket = LP_BUCKET.BACKDROP} -- 660
	) -- 660
	scene:flush(bgDraw, bgGlow) -- 664
	local mx = w * 0.8 -- 667
	local my = h * 0.84 -- 668
	fillRadialGlow( -- 669
		bgGlow, -- 669
		mx, -- 669
		my, -- 669
		96, -- 669
		96, -- 669
		Color(188, 206, 224, 24), -- 669
		Color(24, 32, 46, 0), -- 669
		16 -- 669
	) -- 669
	bgDraw:drawCircle( -- 670
		Vec2(mx, my), -- 670
		14, -- 670
		Color(214, 224, 236, 130) -- 670
	) -- 670
	local towerPt = projectWorld3D( -- 673
		ox + 668, -- 673
		152, -- 673
		410, -- 673
		cam, -- 673
		self.proj -- 673
	) -- 673
	fillRadialGlow( -- 674
		bgGlow, -- 674
		towerPt.x, -- 674
		towerPt.y, -- 674
		20, -- 674
		20, -- 674
		Color(238, 198, 132, 54), -- 674
		Color(238, 198, 132, 0), -- 674
		12 -- 674
	) -- 674
	bgGlow:drawDot( -- 675
		Vec2(towerPt.x, towerPt.y), -- 675
		2, -- 675
		Color(252, 232, 186, 185) -- 675
	) -- 675
	return true -- 677
end -- 555
function VillageUndertableScene.prototype.drawWorld(self, fgDraw, fgGlow, _worldArt, ctx) -- 680
	local p = ctx.p -- 686
	local cam = ctx.cam -- 687
	local ox = p.ox -- 688
	local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 689
	scene:addBox({ -- 692
		x0 = ox - 40, -- 693
		x1 = ox + 436, -- 694
		y0 = -52, -- 695
		y1 = 0, -- 696
		z0 = -32, -- 697
		z1 = 112, -- 698
		material = MING_MATERIALS.mingTimberDark, -- 699
		bucket = LP_BUCKET.MIDGROUND, -- 700
		highlightTopEdge = true, -- 701
		edgeWidth = 0.7 -- 702
	}) -- 702
	scene:addBox({ -- 704
		x0 = ox + 436, -- 705
		x1 = ox + 760, -- 706
		y0 = -52, -- 707
		y1 = 0, -- 708
		z0 = -32, -- 709
		z1 = 126, -- 710
		material = MING_MATERIALS.mingBrickDark, -- 711
		bucket = LP_BUCKET.MIDGROUND, -- 712
		highlightTopEdge = true, -- 713
		edgeWidth = 0.8 -- 714
	}) -- 714
	scene:addBeveledFrame( -- 718
		ox + 416, -- 718
		ox + 462, -- 718
		0, -- 718
		128, -- 718
		16, -- 718
		22, -- 718
		16, -- 718
		112, -- 718
		MING_MATERIALS.mingTimberDark, -- 718
		{ -- 718
			bucket = LP_BUCKET.MIDGROUND, -- 719
			innerRimLight = rgba(206, 214, 222, 255), -- 720
			innerRimStrength = 0.42 -- 721
		} -- 721
	) -- 721
	scene:addBox({ -- 725
		x0 = ox + 96, -- 726
		x1 = ox + 101, -- 727
		y0 = 0, -- 728
		y1 = 52, -- 729
		z0 = -6, -- 730
		z1 = 24, -- 731
		material = MAT_TABLE_WOOD, -- 732
		bucket = LP_BUCKET.WALK_DECK, -- 733
		edgeWidth = 0.8 -- 734
	}) -- 734
	scene:addBox({ -- 736
		x0 = ox + 123, -- 737
		x1 = ox + 128, -- 738
		y0 = 0, -- 739
		y1 = 52, -- 740
		z0 = -6, -- 741
		z1 = 24, -- 742
		material = MAT_TABLE_WOOD, -- 743
		bucket = LP_BUCKET.WALK_DECK, -- 744
		edgeWidth = 0.8 -- 745
	}) -- 745
	scene:addBox({ -- 747
		x0 = ox + 95, -- 748
		x1 = ox + 129, -- 749
		y0 = 24, -- 750
		y1 = 28, -- 751
		z0 = -8, -- 752
		z1 = 26, -- 753
		material = MING_MATERIALS.mingTimber, -- 754
		bucket = LP_BUCKET.WALK_DECK, -- 755
		sortBias = 0.05 -- 756
	}) -- 756
	scene:addBox({ -- 758
		x0 = ox + 94, -- 759
		x1 = ox + 130, -- 760
		y0 = 48, -- 761
		y1 = 52, -- 762
		z0 = -8, -- 763
		z1 = 26, -- 764
		material = MING_MATERIALS.mingTimber, -- 765
		bucket = LP_BUCKET.WALK_DECK, -- 766
		highlightTopEdge = true, -- 767
		sortBias = 0.06 -- 768
	}) -- 768
	scene:addBox({ -- 771
		x0 = ox + 672, -- 772
		x1 = ox + 720, -- 773
		y0 = 0, -- 774
		y1 = 96, -- 775
		z0 = -14, -- 776
		z1 = 96, -- 777
		material = MING_MATERIALS.mingBrick, -- 778
		bucket = LP_BUCKET.MIDGROUND, -- 779
		highlightTopEdge = true, -- 780
		edgeWidth = 0.9 -- 781
	}) -- 781
	scene:addBox({ -- 783
		x0 = ox + 666, -- 784
		x1 = ox + 726, -- 785
		y0 = 96, -- 786
		y1 = 106, -- 787
		z0 = -18, -- 788
		z1 = 100, -- 789
		material = MING_MATERIALS.mingTile, -- 790
		bucket = LP_BUCKET.MIDGROUND, -- 791
		sortBias = 0.08 -- 792
	}) -- 792
	local arch = p.room.arch -- 797
	scene:addBox({ -- 799
		x0 = arch.x0 - 1, -- 800
		x1 = arch.x0 + 7, -- 801
		y0 = 0, -- 802
		y1 = arch.h, -- 803
		z0 = 12, -- 804
		z1 = 22, -- 805
		material = MAT_TABLE_WOOD, -- 806
		bucket = LP_BUCKET.MIDGROUND, -- 807
		edgeWidth = 0.8 -- 808
	}) -- 808
	scene:addBox({ -- 810
		x0 = arch.x1 - 7, -- 811
		x1 = arch.x1 + 1, -- 812
		y0 = 0, -- 813
		y1 = arch.h, -- 814
		z0 = 12, -- 815
		z1 = 22, -- 816
		material = MAT_TABLE_WOOD, -- 817
		bucket = LP_BUCKET.MIDGROUND, -- 818
		edgeWidth = 0.8 -- 819
	}) -- 819
	scene:addBox({ -- 822
		x0 = arch.x0 + 7, -- 823
		x1 = arch.x1 - 7, -- 824
		y0 = arch.h - 5, -- 825
		y1 = arch.h, -- 826
		z0 = 14, -- 827
		z1 = 20, -- 828
		material = MAT_TABLE_WOOD, -- 829
		bucket = LP_BUCKET.MIDGROUND, -- 830
		edgeWidth = 0.6 -- 831
	}) -- 831
	scene:addBox({ -- 834
		x0 = arch.x0 - 8, -- 835
		x1 = arch.x1 + 8, -- 836
		y0 = arch.h, -- 837
		y1 = arch.h + 8, -- 838
		z0 = 4, -- 839
		z1 = 28, -- 840
		material = MAT_TABLE_WOOD, -- 841
		bucket = LP_BUCKET.WALK_DECK, -- 842
		highlightTopEdge = true, -- 843
		edgeWidth = 0.8 -- 844
	}) -- 844
	local culvertX = self:getCulvertWorldX(p) -- 848
	self:buildCulvertEntrance(scene, culvertX) -- 849
	local softX = self:getSoftWorldX(p) -- 853
	self:buildSoftDirtPatch(scene, softX) -- 854
	local brickX = self:getBrickWorldX(p) -- 857
	self:buildHardBrickPatch(scene, brickX) -- 858
	local basinX = self:getBasinWorldX(p) -- 861
	self:buildIronBasin(scene, basinX) -- 862
	scene:addLightShaft( -- 865
		ox + 570, -- 866
		ox + 710, -- 866
		290, -- 866
		ox + 446, -- 867
		ox + 642, -- 867
		0, -- 867
		24, -- 868
		rgba(218, 226, 218, 255), -- 869
		0.13, -- 870
		0.04 -- 871
	) -- 871
	scene:addContactShadow( -- 875
		p.player.x, -- 875
		p.player.y, -- 875
		14, -- 875
		10, -- 875
		0.8, -- 875
		{bucket = LP_BUCKET.PROP, sortBias = 0.4} -- 875
	) -- 875
	if p.room.scavenger ~= nil then -- 876
		scene:addContactShadow( -- 877
			p.scavX, -- 877
			p.room.scavenger.y, -- 877
			19, -- 877
			13, -- 877
			0.84, -- 877
			{bucket = LP_BUCKET.PROP, sortBias = 0.42} -- 877
		) -- 877
	end -- 877
	scene:flush(fgDraw, fgGlow) -- 880
	self:drawSurfaceReadabilityDetails( -- 883
		fgDraw, -- 883
		fgGlow, -- 883
		p, -- 883
		cam, -- 883
		softX, -- 883
		culvertX, -- 883
		basinX, -- 883
		brickX -- 883
	) -- 883
	return true -- 885
end -- 680
function VillageUndertableScene.prototype.buildCulvertEntrance(self, scene, cx) -- 888
	scene:addBox({ -- 890
		x0 = cx - 18, -- 891
		x1 = cx + 18, -- 892
		y0 = -12, -- 893
		y1 = 2, -- 894
		z0 = -6, -- 895
		z1 = 42, -- 896
		material = MAT_CULVERT_STONE, -- 897
		bucket = LP_BUCKET.WALK_DECK, -- 898
		highlightTopEdge = true, -- 899
		edgeWidth = 1 -- 900
	}) -- 900
	scene:addQuad3D( -- 903
		vec3(cx - 12, 1, 22), -- 904
		vec3(cx + 12, 1, 22), -- 905
		vec3(cx + 10, 26, 22), -- 906
		vec3(cx - 10, 26, 22), -- 907
		{base = rgba(6, 9, 14, 255)}, -- 908
		{ -- 909
			bucket = LP_BUCKET.MIDGROUND, -- 909
			unlit = true, -- 909
			sortBias = 0.35, -- 909
			edgeColor = rgba(186, 204, 222, 185), -- 909
			edgeWidth = 1.2 -- 909
		} -- 909
	) -- 909
	scene:addBox({ -- 912
		x0 = cx - 15, -- 913
		x1 = cx - 11, -- 914
		y0 = 2, -- 915
		y1 = 24, -- 916
		z0 = 14, -- 917
		z1 = 22, -- 918
		material = MING_MATERIALS.mingTimber, -- 919
		bucket = LP_BUCKET.PROP, -- 920
		highlightTopEdge = true -- 921
	}) -- 921
	local gi = 0 -- 923
	do -- 923
		gi = 0 -- 924
		while gi < 3 do -- 924
			local gx = cx - 6 + gi * 6 -- 925
			scene:addBox({ -- 926
				x0 = gx - 1, -- 927
				x1 = gx + 1, -- 928
				y0 = 2, -- 929
				y1 = 24, -- 930
				z0 = 18, -- 931
				z1 = 21, -- 932
				material = MING_MATERIALS.mingIron, -- 933
				bucket = LP_BUCKET.PROP, -- 934
				sortBias = 0.1 -- 935
			}) -- 935
			gi = gi + 1 -- 924
		end -- 924
	end -- 924
end -- 888
function VillageUndertableScene.prototype.buildSoftDirtPatch(self, scene, softX) -- 940
	scene:addBox({ -- 941
		x0 = softX - 24, -- 942
		x1 = softX + 24, -- 943
		y0 = -4, -- 944
		y1 = 1.5, -- 945
		z0 = -16, -- 946
		z1 = 28, -- 947
		material = MAT_SOFT_EARTH, -- 948
		bucket = LP_BUCKET.WALK_DECK, -- 949
		sortBias = 0.15, -- 950
		edgeWidth = 0.4 -- 951
	}) -- 951
end -- 940
function VillageUndertableScene.prototype.buildHardBrickPatch(self, scene, brickX) -- 955
	local col = 0 -- 957
	do -- 957
		col = 0 -- 958
		while col < 3 do -- 958
			local bx0 = brickX - 24 + col * 16 -- 959
			local bx1 = bx0 + 14.5 -- 960
			scene:addBox({ -- 961
				x0 = bx0, -- 962
				x1 = bx1, -- 963
				y0 = -4, -- 964
				y1 = 3.2, -- 965
				z0 = -14, -- 966
				z1 = 6, -- 967
				material = MAT_HARD_BRICK, -- 968
				bucket = LP_BUCKET.WALK_DECK, -- 969
				sortBias = 0.2 + col * 0.01, -- 970
				highlightTopEdge = true, -- 971
				edgeWidth = 1 -- 972
			}) -- 972
			scene:addBox({ -- 974
				x0 = bx0 + 4, -- 975
				x1 = bx1 + 4, -- 976
				y0 = -4, -- 977
				y1 = 2.8, -- 978
				z0 = 8, -- 979
				z1 = 26, -- 980
				material = MAT_HARD_BRICK, -- 981
				bucket = LP_BUCKET.WALK_DECK, -- 982
				sortBias = 0.18 + col * 0.01, -- 983
				highlightTopEdge = true, -- 984
				edgeWidth = 0.9 -- 985
			}) -- 985
			col = col + 1 -- 958
		end -- 958
	end -- 958
end -- 955
function VillageUndertableScene.prototype.buildIronBasin(self, scene, basinX) -- 990
	scene:addBox({ -- 992
		x0 = basinX - 14, -- 993
		x1 = basinX + 14, -- 994
		y0 = -2, -- 995
		y1 = 3, -- 996
		z0 = -10, -- 997
		z1 = 14, -- 998
		material = MING_MATERIALS.mingBrickDark, -- 999
		bucket = LP_BUCKET.PROP, -- 1000
		sortBias = 0.02 -- 1001
	}) -- 1001
	local tilt = self.basinShakeAngle -- 1004
	local liftL = math.sin(tilt) * 14 -- 1005
	local liftR = -liftL -- 1006
	local shiftX = math.sin(tilt * 1.4) * 2.5 -- 1007
	local baseY = 3 -- 1008
	local topY = 14.5 -- 1009
	local bx = basinX + shiftX -- 1010
	scene:addQuad3D( -- 1013
		vec3( -- 1014
			bx - 11, -- 1014
			baseY + math.max(0, liftL * 0.4), -- 1014
			-8 -- 1014
		), -- 1014
		vec3( -- 1015
			bx + 11, -- 1015
			baseY + math.max(0, liftR * 0.4), -- 1015
			-8 -- 1015
		), -- 1015
		vec3(bx + 16, topY + liftR, -12), -- 1016
		vec3(bx - 16, topY + liftL, -12), -- 1017
		MAT_IRON_BASIN, -- 1018
		{bucket = LP_BUCKET.PROP, sortBias = 0.25, edgeWidth = 1.2} -- 1019
	) -- 1019
	scene:addQuad3D( -- 1022
		vec3( -- 1023
			bx - 11, -- 1023
			baseY + math.max(0, liftL * 0.4), -- 1023
			10 -- 1023
		), -- 1023
		vec3( -- 1024
			bx - 11, -- 1024
			baseY + math.max(0, liftL * 0.4), -- 1024
			-8 -- 1024
		), -- 1024
		vec3(bx - 16, topY + liftL, -12), -- 1025
		vec3(bx - 16, topY + liftL, 14), -- 1026
		MAT_IRON_BASIN, -- 1027
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1028
	) -- 1028
	scene:addQuad3D( -- 1030
		vec3( -- 1031
			bx + 11, -- 1031
			baseY + math.max(0, liftR * 0.4), -- 1031
			-8 -- 1031
		), -- 1031
		vec3( -- 1032
			bx + 11, -- 1032
			baseY + math.max(0, liftR * 0.4), -- 1032
			10 -- 1032
		), -- 1032
		vec3(bx + 16, topY + liftR, 14), -- 1033
		vec3(bx + 16, topY + liftR, -12), -- 1034
		MAT_IRON_BASIN, -- 1035
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1036
	) -- 1036
	scene:addQuad3D( -- 1039
		vec3(bx - 14, topY - 1 + liftL, -10), -- 1040
		vec3(bx + 14, topY - 1 + liftR, -10), -- 1041
		vec3(bx + 14, topY - 1 + liftR, 12), -- 1042
		vec3(bx - 14, topY - 1 + liftL, 12), -- 1043
		{ -- 1044
			base = rgba(24, 30, 40, 255), -- 1044
			edge = rgba(232, 238, 246, 235) -- 1044
		}, -- 1044
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 1.5} -- 1045
	) -- 1045
end -- 990
function VillageUndertableScene.prototype.drawSurfaceReadabilityDetails(self, fgDraw, fgGlow, p, cam, softX, culvertX, basinX, brickX) -- 1049
	local y0 = cam:sy(0) -- 1059
	local sx0 = cam:sx(softX - 20) -- 1062
	local sx1 = cam:sx(softX + 20) -- 1063
	local d = 0 -- 1064
	do -- 1064
		d = 0 -- 1065
		while d < 9 do -- 1065
			local dx = sx0 + (sx1 - sx0) * (d + 0.5) / 9 -- 1066
			local dy = y0 - 2.5 + (d % 3 - 1) * 1.8 -- 1067
			fgDraw:drawDot( -- 1068
				Vec2(dx, dy), -- 1068
				1.3, -- 1068
				Color(116, 98, 78, 175) -- 1068
			) -- 1068
			d = d + 1 -- 1065
		end -- 1065
	end -- 1065
	fgDraw:drawEllipse( -- 1070
		Vec2( -- 1070
			cam:sx(softX - 7), -- 1070
			y0 - 1.5 -- 1070
		), -- 1070
		cam:len(4.2), -- 1070
		1.6, -- 1070
		Color(38, 30, 24, 185) -- 1070
	) -- 1070
	fgDraw:drawEllipse( -- 1071
		Vec2( -- 1071
			cam:sx(softX + 8), -- 1071
			y0 - 2 -- 1071
		), -- 1071
		cam:len(4.2), -- 1071
		1.6, -- 1071
		Color(38, 30, 24, 185) -- 1071
	) -- 1071
	local cL = cam:sx(culvertX - 11) -- 1074
	local cR = cam:sx(culvertX + 11) -- 1075
	local cTop = cam:sy(25) -- 1076
	fgDraw:drawSegment( -- 1077
		Vec2(cL, cTop), -- 1077
		Vec2(cR, cTop), -- 1077
		1.6, -- 1077
		Color(196, 210, 224, 210) -- 1077
	) -- 1077
	local rippleShift = math.sin(self.animTime * 2.3) * 3 -- 1078
	fgGlow:drawSegment( -- 1079
		Vec2(cL + 3 + rippleShift, y0 + 2), -- 1079
		Vec2(cR - 4 + rippleShift, y0 + 2), -- 1079
		1.1, -- 1079
		Color(164, 192, 214, 105) -- 1079
	) -- 1079
	local bPtL = projectWorld3D( -- 1082
		basinX - 16, -- 1082
		14.5 + math.sin(self.basinShakeAngle) * 14, -- 1082
		-12, -- 1082
		cam, -- 1082
		self.proj -- 1082
	) -- 1082
	local bPtR = projectWorld3D( -- 1083
		basinX + 16, -- 1083
		14.5 - math.sin(self.basinShakeAngle) * 14, -- 1083
		-12, -- 1083
		cam, -- 1083
		self.proj -- 1083
	) -- 1083
	local shakeBoost = self.basinShakeTimer > 0 and clamp01(self.basinShakeTimer / self.basinShakeMax) or 0 -- 1084
	local rimAlpha = math.floor(205 + 48 * shakeBoost + 0.5) -- 1085
	fgDraw:drawSegment( -- 1086
		Vec2(bPtL.x, bPtL.y), -- 1086
		Vec2(bPtR.x, bPtR.y), -- 1086
		2.1 + shakeBoost * 1.1, -- 1086
		Color(230, 236, 242, rimAlpha) -- 1086
	) -- 1086
	fillRadialGlow( -- 1087
		fgGlow, -- 1088
		(bPtL.x + bPtR.x) * 0.5, -- 1089
		(bPtL.y + bPtR.y) * 0.5, -- 1090
		cam:len(22 + shakeBoost * 18), -- 1091
		cam:len(10 + shakeBoost * 8), -- 1092
		Color( -- 1093
			216, -- 1093
			226, -- 1093
			236, -- 1093
			math.floor(48 + 95 * shakeBoost + 0.5) -- 1093
		), -- 1093
		Color(186, 202, 220, 0), -- 1094
		14 -- 1095
	) -- 1095
	local brL = cam:sx(brickX - 24) -- 1099
	local brR = cam:sx(brickX + 24) -- 1100
	local brTop = cam:sy(3.2) -- 1101
	fgDraw:drawSegment( -- 1102
		Vec2(brL, brTop), -- 1102
		Vec2(brR, brTop), -- 1102
		1.8, -- 1102
		Color(224, 228, 234, 225) -- 1102
	) -- 1102
	local k = 1 -- 1103
	do -- 1103
		k = 1 -- 1104
		while k <= 2 do -- 1104
			local seamX = brL + (brR - brL) * k / 3 -- 1105
			fgDraw:drawSegment( -- 1106
				Vec2(seamX, y0 - 3), -- 1106
				Vec2(seamX, brTop + 1), -- 1106
				1.5, -- 1106
				Color(20, 24, 32, 240) -- 1106
			) -- 1106
			fgDraw:drawSegment( -- 1107
				Vec2(seamX + 1.8, y0 - 2), -- 1107
				Vec2(seamX + 1.8, brTop), -- 1107
				0.9, -- 1107
				Color(214, 218, 224, 175) -- 1107
			) -- 1107
			k = k + 1 -- 1104
		end -- 1104
	end -- 1104
	local i = 0 -- 1111
	do -- 1111
		i = 0 -- 1112
		while i < #self.rings do -- 1112
			do -- 1112
				local rg = self.rings[i + 1] -- 1113
				if rg.age < 0 then -- 1114
					goto __continue75 -- 1115
				end -- 1115
				local t = clamp01(rg.age / rg.duration) -- 1117
				local r = math.max( -- 1118
					4, -- 1118
					cam:len(rg.maxRadius) * (0.14 + 0.86 * t) -- 1118
				) -- 1118
				local alpha = (1 - t) * (rg.kind == "iron" and 0.88 or (rg.kind == "brick" and 0.82 or 0.4)) -- 1119
				local rx = cam:sx(rg.x) -- 1120
				local ry = cam:sy(rg.y) -- 1121
				local ringCol = rg.kind == "iron" and Color( -- 1122
					220, -- 1123
					234, -- 1123
					246, -- 1123
					math.floor(235 * alpha + 0.5) -- 1123
				) or (rg.kind == "brick" and Color( -- 1124
					236, -- 1125
					216, -- 1125
					178, -- 1125
					math.floor(225 * alpha + 0.5) -- 1125
				) or Color( -- 1126
					148, -- 1126
					134, -- 1126
					114, -- 1126
					math.floor(165 * alpha + 0.5) -- 1126
				)) -- 1126
				drawEllipseRing( -- 1127
					fgGlow, -- 1127
					rx, -- 1127
					ry, -- 1127
					r, -- 1127
					r * 0.34, -- 1127
					rg.kind == "iron" and 1.8 or 1.4, -- 1127
					ringCol, -- 1127
					22 -- 1127
				) -- 1127
				if rg.kind == "iron" then -- 1128
					drawEllipseRing( -- 1129
						fgDraw, -- 1129
						rx, -- 1129
						ry, -- 1129
						r * 0.96, -- 1129
						r * 0.32, -- 1129
						1.1, -- 1129
						Color( -- 1129
							214, -- 1129
							224, -- 1129
							236, -- 1129
							math.floor(150 * alpha + 0.5) -- 1129
						), -- 1129
						22 -- 1129
					) -- 1129
				end -- 1129
			end -- 1129
			::__continue75:: -- 1129
			i = i + 1 -- 1112
		end -- 1112
	end -- 1112
	do -- 1112
		i = 0 -- 1132
		while i < #self.shards do -- 1132
			local sp = self.shards[i + 1] -- 1133
			local a = clamp01(sp.life / sp.maxLife) -- 1134
			local col = sp.kind == "soft" and Color( -- 1135
				138, -- 1136
				120, -- 1136
				98, -- 1136
				math.floor(170 * a + 0.5) -- 1136
			) or (sp.kind == "iron" and Color( -- 1137
				224, -- 1138
				232, -- 1138
				242, -- 1138
				math.floor(225 * a + 0.5) -- 1138
			) or Color( -- 1139
				216, -- 1139
				198, -- 1139
				174, -- 1139
				math.floor(220 * a + 0.5) -- 1139
			)) -- 1139
			fgDraw:drawDot( -- 1140
				Vec2( -- 1140
					cam:sx(sp.x), -- 1140
					cam:sy(sp.y) -- 1140
				), -- 1140
				sp.size, -- 1140
				col -- 1140
			) -- 1140
			i = i + 1 -- 1132
		end -- 1132
	end -- 1132
	if p.bottleLandT > 0 and p.bottleLandX >= 0 and #self.rings == 0 then -- 1144
		local rx = cam:sx(p.bottleLandX) -- 1145
		local ry = cam:sy(math.max(1, p.bottleLandY)) -- 1146
		fgDraw:drawDot( -- 1147
			Vec2(rx, ry), -- 1147
			2.5, -- 1147
			Color(216, 206, 186, 150) -- 1147
		) -- 1147
	end -- 1147
end -- 1049
function VillageUndertableScene.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1152
	local p = ctx.p -- 1158
	local cam = ctx.cam -- 1159
	local bottle = p.room.bottle -- 1162
	if bottle ~= nil and not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 1163
		self:drawCeramicBottle( -- 1164
			fgDraw, -- 1164
			fgGlow, -- 1164
			worldArt, -- 1164
			"fe04_bottle_shelf", -- 1164
			cam:sx(bottle.x), -- 1164
			cam:sy(56), -- 1164
			cam.ppu, -- 1164
			0, -- 1164
			true -- 1164
		) -- 1164
	end -- 1164
	if p.hasBottle and p.aimHold <= 0 then -- 1168
		local pl = p.player -- 1169
		self:drawCeramicBottle( -- 1170
			fgDraw, -- 1171
			fgGlow, -- 1172
			worldArt, -- 1173
			"fe04_bottle_held", -- 1174
			cam:sx(pl.x + pl.facing * 10), -- 1175
			cam:sy(pl.y + pl.h * 0.52), -- 1176
			cam.ppu, -- 1177
			pl.facing * 0.22, -- 1178
			false -- 1179
		) -- 1179
	end -- 1179
	if p.bottleFly ~= nil then -- 1182
		self:drawCeramicBottle( -- 1183
			fgDraw, -- 1184
			fgGlow, -- 1185
			worldArt, -- 1186
			"fe04_bottle_air", -- 1187
			cam:sx(p.bottleFly.x), -- 1188
			cam:sy(p.bottleFly.y), -- 1189
			cam.ppu, -- 1190
			self.animTime * 13.5, -- 1191
			false -- 1192
		) -- 1192
	end -- 1192
	if p.hasBottle and p.aimHold > 0 then -- 1197
		local pl = p.player -- 1198
		local endX = p.bottleAimX -- 1199
		local endY = p.bottleAimY -- 1200
		if endX < 0 then -- 1201
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 1202
			endX = wAim.x -- 1203
			endY = 0 -- 1204
		end -- 1204
		local dir = endX >= pl.x and 1 or -1 -- 1206
		local x0 = pl.x + dir * 10 -- 1207
		local y0 = pl.y + pl.h * 0.7 -- 1208
		local vx = (endX - x0) / BOTTLE_FLY_T -- 1209
		local vy = (endY - y0 + 0.5 * GRAVITY * BOTTLE_FLY_T * BOTTLE_FLY_T) / BOTTLE_FLY_T -- 1210
		local previewSurface = self:classifyLandingSurface(p, endX) -- 1212
		local arcRgb = previewSurface == "iron" and rgba(214, 228, 242, 255) or (previewSurface == "brick" and rgba(232, 206, 152, 255) or rgba(154, 142, 126, 255)) -- 1213
		local steps = 18 -- 1219
		local k = 1 -- 1220
		do -- 1220
			k = 1 -- 1221
			while k <= steps do -- 1221
				local tt = k / steps * BOTTLE_FLY_T -- 1222
				local wx = x0 + vx * tt -- 1223
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 1224
				local alpha = 195 * (0.4 + 0.6 * (k / steps)) -- 1225
				fgDraw:drawDot( -- 1226
					Vec2( -- 1226
						cam:sx(wx), -- 1226
						cam:sy(wy) -- 1226
					), -- 1226
					2.5, -- 1226
					toColor(arcRgb, alpha) -- 1226
				) -- 1226
				fgGlow:drawDot( -- 1227
					Vec2( -- 1227
						cam:sx(wx), -- 1227
						cam:sy(wy) -- 1227
					), -- 1227
					3.2, -- 1227
					toColor(arcRgb, alpha * 0.55) -- 1227
				) -- 1227
				k = k + 1 -- 1221
			end -- 1221
		end -- 1221
		local lx = cam:sx(endX) -- 1230
		local ly = cam:sy(endY + 2) -- 1231
		local pulse = 0.88 + 0.12 * math.sin(self.animTime * 5.2) -- 1232
		drawEllipseRing( -- 1233
			fgDraw, -- 1233
			lx, -- 1233
			ly, -- 1233
			11 * pulse, -- 1233
			4.2 * pulse, -- 1233
			1.6, -- 1233
			toColor(arcRgb, 235), -- 1233
			20 -- 1233
		) -- 1233
		if previewSurface == "iron" then -- 1234
			drawEllipseRing( -- 1235
				fgGlow, -- 1235
				lx, -- 1235
				ly, -- 1235
				24 * pulse, -- 1235
				9.2 * pulse, -- 1235
				1.3, -- 1235
				toColor(arcRgb, 195), -- 1235
				22 -- 1235
			) -- 1235
		elseif previewSurface == "brick" then -- 1236
			drawEllipseRing( -- 1237
				fgGlow, -- 1237
				lx, -- 1237
				ly, -- 1237
				18 * pulse, -- 1237
				7 * pulse, -- 1237
				1.2, -- 1237
				toColor(arcRgb, 165), -- 1237
				20 -- 1237
			) -- 1237
		end -- 1237
	end -- 1237
	return true -- 1241
end -- 1152
function VillageUndertableScene.prototype.drawCeramicBottle(self, fgDraw, fgGlow, worldArt, id, cx, cy, ppu, tilt, shelfGlint) -- 1244
	local size = math.max(10, ppu * 10.5) -- 1255
	if not worldArt:tryPlace( -- 1256
		"prop_bottle", -- 1256
		id, -- 1256
		cx, -- 1256
		cy, -- 1256
		size, -- 1256
		size, -- 1256
		{angle = tilt * 180 / math.pi, layer = 8} -- 1256
	) then -- 1256
		fgDraw:drawCircle( -- 1260
			Vec2(cx, cy), -- 1260
			size * 0.36, -- 1260
			Color(172, 138, 102, 245) -- 1260
		) -- 1260
	end -- 1260
	if shelfGlint then -- 1262
		local p = 0.72 + 0.28 * math.sin(self.animTime * 3) -- 1263
		fillRadialGlow( -- 1264
			fgGlow, -- 1264
			cx, -- 1264
			cy + 2, -- 1264
			14 * p, -- 1264
			14 * p, -- 1264
			Color( -- 1264
				224, -- 1264
				214, -- 1264
				190, -- 1264
				math.floor(62 * p + 0.5) -- 1264
			), -- 1264
			Color(224, 214, 190, 0), -- 1264
			12 -- 1264
		) -- 1264
	end -- 1264
end -- 1244
function VillageUndertableScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1269
	local p = ctx.p -- 1275
	local cam = ctx.cam -- 1276
	if p.room.scavenger ~= nil then -- 1277
		self:drawScavengerShoeOverlay(fgDraw, fgGlow, p, cam) -- 1278
	end -- 1278
	if ctx.paused then -- 1282
		local arch = p.room.arch -- 1283
		local pTopBL = projectWorld3D( -- 1284
			arch.x0 - 8, -- 1284
			arch.h, -- 1284
			-15, -- 1284
			cam, -- 1284
			self.proj -- 1284
		) -- 1284
		local pTopTR = projectWorld3D( -- 1285
			arch.x1 + 8, -- 1285
			arch.h + 8, -- 1285
			-15, -- 1285
			cam, -- 1285
			self.proj -- 1285
		) -- 1285
		worldArt:tryPlace( -- 1286
			"cover_wood", -- 1287
			"fe04_pause_table_top", -- 1288
			(pTopBL.x + pTopTR.x) * 0.5, -- 1289
			pTopBL.y, -- 1290
			math.max( -- 1291
				20, -- 1291
				math.abs(pTopTR.x - pTopBL.x) -- 1291
			), -- 1291
			math.max( -- 1292
				8, -- 1292
				math.abs(pTopTR.y - pTopBL.y) -- 1292
			), -- 1292
			{ -- 1293
				color = Color(46, 35, 27, 255), -- 1293
				opacity = 0.96, -- 1293
				layer = 5300 -- 1293
			} -- 1293
		) -- 1293
		local legBL = projectWorld3D( -- 1295
			arch.x1 - 6, -- 1295
			0, -- 1295
			-15, -- 1295
			cam, -- 1295
			self.proj -- 1295
		) -- 1295
		local legTR = projectWorld3D( -- 1296
			arch.x1 + 1, -- 1296
			arch.h, -- 1296
			-15, -- 1296
			cam, -- 1296
			self.proj -- 1296
		) -- 1296
		worldArt:tryPlace( -- 1297
			"cover_wood", -- 1298
			"fe04_pause_table_leg", -- 1299
			(legBL.x + legTR.x) * 0.5, -- 1300
			legBL.y, -- 1301
			math.max( -- 1302
				6, -- 1302
				math.abs(legTR.x - legBL.x) -- 1302
			), -- 1302
			math.max( -- 1303
				16, -- 1303
				math.abs(legTR.y - legBL.y) -- 1303
			), -- 1303
			{ -- 1304
				color = Color(34, 25, 19, 255), -- 1304
				opacity = 0.96, -- 1304
				layer = 5310 -- 1304
			} -- 1304
		) -- 1304
	end -- 1304
end -- 1269
function VillageUndertableScene.prototype.drawScavengerShoeOverlay(self, fgDraw, fgGlow, p, cam) -- 1309
	local cx = cam:sx(p.scavX) -- 1315
	local by = cam:sy(p.room.scavenger ~= nil and p.room.scavenger.y or 0) -- 1316
	local f = self.shoeFacing >= 0 and 1 or -1 -- 1317
	local moving = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 1318
	local stride = moving and math.sin(self.scavStridePhase) * cam:len(7.2) or 0 -- 1319
	local pausedToe = self.shoeToePauseTimer > 0 -- 1320
	fillRadialGlow( -- 1323
		fgGlow, -- 1323
		cx + f * cam:len(4), -- 1323
		by + 2, -- 1323
		cam:len(32), -- 1323
		cam:len(8), -- 1323
		Color(196, 208, 220, 48), -- 1323
		Color(156, 172, 190, 0), -- 1323
		14 -- 1323
	) -- 1323
	fgDraw:drawEllipse( -- 1324
		Vec2( -- 1324
			cx + f * cam:len(2), -- 1324
			by + 1 -- 1324
		), -- 1324
		cam:len(19), -- 1324
		cam:len(3.4), -- 1324
		Color(92, 102, 114, 72) -- 1324
	) -- 1324
	local function drawSingleShoe(footX, liftY, isFront) -- 1327
		local heelX = footX - f * cam:len(4.8) -- 1328
		local midX = footX + f * cam:len(1.8) -- 1329
		local toeX = footX + f * cam:len(7.6) -- 1330
		local soleY = by + 0.8 + liftY -- 1331
		local shoeH = cam:len(4.4) -- 1332
		fgDraw:drawPolygon( -- 1334
			{ -- 1334
				Vec2(heelX, soleY), -- 1335
				Vec2(toeX, soleY), -- 1336
				Vec2( -- 1337
					toeX - f * cam:len(1), -- 1337
					soleY + shoeH * 0.56 -- 1337
				), -- 1337
				Vec2(midX, soleY + shoeH * 0.96), -- 1338
				Vec2( -- 1339
					heelX + f * cam:len(0.6), -- 1339
					soleY + shoeH * 0.86 -- 1339
				) -- 1339
			}, -- 1339
			isFront and Color(68, 58, 48, 250) or Color(46, 40, 34, 240) -- 1340
		) -- 1340
		local soleCol = isFront and Color(198, 192, 178, 232) or Color(148, 144, 134, 195) -- 1342
		fgDraw:drawSegment( -- 1343
			Vec2(heelX, soleY + 0.6), -- 1343
			Vec2(toeX, soleY + 0.6), -- 1343
			1.5, -- 1343
			soleCol -- 1343
		) -- 1343
		fgDraw:drawSegment( -- 1345
			Vec2( -- 1345
				toeX - f * cam:len(1.2), -- 1345
				soleY + 0.8 -- 1345
			), -- 1345
			Vec2( -- 1345
				toeX - f * cam:len(1.4), -- 1345
				soleY + shoeH * 0.56 -- 1345
			), -- 1345
			1.3, -- 1345
			Color(214, 210, 198, isFront and 220 or 165) -- 1345
		) -- 1345
		if isFront and pausedToe then -- 1347
			fgGlow:drawDot( -- 1348
				Vec2(toeX, soleY + 1.5), -- 1348
				3, -- 1348
				Color(236, 218, 178, 155) -- 1348
			) -- 1348
		end -- 1348
	end -- 1327
	local backLift = moving and math.max( -- 1352
		0, -- 1352
		-math.sin(self.scavStridePhase) -- 1352
	) * cam:len(2.4) or 0 -- 1352
	local frontLift = moving and math.max( -- 1353
		0, -- 1353
		math.sin(self.scavStridePhase) -- 1353
	) * cam:len(2.8) or 0 -- 1353
	drawSingleShoe( -- 1354
		cx - stride - f * cam:len(3.5), -- 1354
		backLift, -- 1354
		false -- 1354
	) -- 1354
	drawSingleShoe( -- 1355
		cx + stride + f * cam:len(4), -- 1355
		frontLift, -- 1355
		true -- 1355
	) -- 1355
end -- 1309
function VillageUndertableScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 1365
	local p = ctx.p -- 1372
	local cam = ctx.cam -- 1373
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1374
	local arch = p.room.arch -- 1375
	local xLeft = arch.x0 - 8 -- 1377
	local xRight = arch.x1 + 8 -- 1378
	local tableBotY = arch.h -- 1379
	local tableTopY = arch.h + 8 -- 1380
	local zFront = -15 -- 1381
	local zMid = 4 -- 1382
	local function drawFrontLeg(lx0, lx1) -- 1385
		local mBL = projectWorld3D( -- 1386
			lx0, -- 1386
			0, -- 1386
			zFront, -- 1386
			cam, -- 1386
			self.proj -- 1386
		) -- 1386
		local mBR = projectWorld3D( -- 1387
			lx1, -- 1387
			0, -- 1387
			zFront, -- 1387
			cam, -- 1387
			self.proj -- 1387
		) -- 1387
		local mTR = projectWorld3D( -- 1388
			lx1, -- 1388
			tableBotY, -- 1388
			zFront, -- 1388
			cam, -- 1388
			self.proj -- 1388
		) -- 1388
		local mTL = projectWorld3D( -- 1389
			lx0, -- 1389
			tableBotY, -- 1389
			zFront, -- 1389
			cam, -- 1389
			self.proj -- 1389
		) -- 1389
		drawUiQuad( -- 1390
			uiDraw, -- 1390
			mBL, -- 1390
			mBR, -- 1390
			mTR, -- 1390
			mTL, -- 1390
			Color(26, 20, 15, 250), -- 1390
			Color(38, 29, 22, 252), -- 1390
			inv, -- 1390
			Color(88, 70, 54, 145), -- 1390
			0.9 -- 1390
		) -- 1390
		local sBR = projectWorld3D( -- 1392
			lx1, -- 1392
			0, -- 1392
			zFront + 7, -- 1392
			cam, -- 1392
			self.proj -- 1392
		) -- 1392
		local sTR = projectWorld3D( -- 1393
			lx1, -- 1393
			tableBotY, -- 1393
			zFront + 7, -- 1393
			cam, -- 1393
			self.proj -- 1393
		) -- 1393
		drawUiQuad( -- 1394
			uiDraw, -- 1394
			mBR, -- 1394
			sBR, -- 1394
			sTR, -- 1394
			mTR, -- 1394
			Color(44, 34, 26, 248), -- 1394
			Color(66, 52, 40, 250), -- 1394
			inv, -- 1394
			Color(138, 120, 102, 155), -- 1394
			0.8 -- 1394
		) -- 1394
	end -- 1385
	drawFrontLeg(arch.x0 - 1, arch.x0 + 6) -- 1396
	drawFrontLeg(arch.x1 - 6, arch.x1 + 1) -- 1397
	local bFarL = projectWorld3D( -- 1400
		xLeft, -- 1400
		tableBotY, -- 1400
		zMid, -- 1400
		cam, -- 1400
		self.proj -- 1400
	) -- 1400
	local bFarR = projectWorld3D( -- 1401
		xRight, -- 1401
		tableBotY, -- 1401
		zMid, -- 1401
		cam, -- 1401
		self.proj -- 1401
	) -- 1401
	local bNearR = projectWorld3D( -- 1402
		xRight, -- 1402
		tableBotY, -- 1402
		zFront, -- 1402
		cam, -- 1402
		self.proj -- 1402
	) -- 1402
	local bNearL = projectWorld3D( -- 1403
		xLeft, -- 1403
		tableBotY, -- 1403
		zFront, -- 1403
		cam, -- 1403
		self.proj -- 1403
	) -- 1403
	drawUiQuad( -- 1404
		uiDraw, -- 1404
		bFarL, -- 1404
		bFarR, -- 1404
		bNearR, -- 1404
		bNearL, -- 1404
		Color(18, 14, 11, 236), -- 1404
		Color(28, 21, 16, 242), -- 1404
		inv, -- 1404
		Color(76, 58, 44, 115), -- 1404
		0.8 -- 1404
	) -- 1404
	local fTopR = projectWorld3D( -- 1407
		xRight, -- 1407
		tableTopY, -- 1407
		zFront, -- 1407
		cam, -- 1407
		self.proj -- 1407
	) -- 1407
	local fTopL = projectWorld3D( -- 1408
		xLeft, -- 1408
		tableTopY, -- 1408
		zFront, -- 1408
		cam, -- 1408
		self.proj -- 1408
	) -- 1408
	drawUiQuad( -- 1409
		uiDraw, -- 1409
		bNearL, -- 1409
		bNearR, -- 1409
		fTopR, -- 1409
		fTopL, -- 1409
		Color(38, 28, 21, 252), -- 1409
		Color(56, 42, 32, 254), -- 1409
		inv, -- 1409
		Color(124, 98, 76, 155), -- 1409
		1 -- 1409
	) -- 1409
	uiDraw:drawSegment( -- 1411
		Vec2(bNearL.x * inv, bNearL.y * inv), -- 1411
		Vec2(bNearR.x * inv, bNearR.y * inv), -- 1411
		1.2, -- 1411
		Color(142, 122, 100, 175) -- 1411
	) -- 1411
	local topBackL = projectWorld3D( -- 1414
		xLeft, -- 1414
		tableTopY, -- 1414
		zMid, -- 1414
		cam, -- 1414
		self.proj -- 1414
	) -- 1414
	local topBackR = projectWorld3D( -- 1415
		xRight, -- 1415
		tableTopY, -- 1415
		zMid, -- 1415
		cam, -- 1415
		self.proj -- 1415
	) -- 1415
	drawUiQuad( -- 1416
		uiDraw, -- 1416
		fTopL, -- 1416
		fTopR, -- 1416
		topBackR, -- 1416
		topBackL, -- 1416
		Color(52, 40, 30, 244), -- 1416
		Color(32, 24, 19, 236), -- 1416
		inv, -- 1416
		Color(132, 110, 88, 130), -- 1416
		0.8 -- 1416
	) -- 1416
	local bowlBL = projectWorld3D( -- 1419
		arch.x0 + 24, -- 1419
		tableTopY + 0.5, -- 1419
		-5, -- 1419
		cam, -- 1419
		self.proj -- 1419
	) -- 1419
	local bowlBR = projectWorld3D( -- 1420
		arch.x0 + 38, -- 1420
		tableTopY + 0.5, -- 1420
		-5, -- 1420
		cam, -- 1420
		self.proj -- 1420
	) -- 1420
	local bowlTR = projectWorld3D( -- 1421
		arch.x0 + 40, -- 1421
		tableTopY + 6.5, -- 1421
		-5, -- 1421
		cam, -- 1421
		self.proj -- 1421
	) -- 1421
	local bowlTL = projectWorld3D( -- 1422
		arch.x0 + 22, -- 1422
		tableTopY + 6.5, -- 1422
		-5, -- 1422
		cam, -- 1422
		self.proj -- 1422
	) -- 1422
	drawUiQuad( -- 1423
		uiDraw, -- 1423
		bowlBL, -- 1423
		bowlBR, -- 1423
		bowlTR, -- 1423
		bowlTL, -- 1423
		Color(72, 68, 62, 244), -- 1423
		Color(118, 114, 106, 246), -- 1423
		inv, -- 1423
		Color(172, 166, 156, 175), -- 1423
		0.8 -- 1423
	) -- 1423
	local clothL = projectWorld3D( -- 1426
		xLeft + 2, -- 1426
		tableBotY - 7, -- 1426
		zFront, -- 1426
		cam, -- 1426
		self.proj -- 1426
	) -- 1426
	local clothR = projectWorld3D( -- 1427
		xLeft + 26, -- 1427
		tableBotY - 1, -- 1427
		zFront, -- 1427
		cam, -- 1427
		self.proj -- 1427
	) -- 1427
	uiDraw:drawVertices({ -- 1428
		{ -- 1429
			Vec2(bNearL.x * inv, bNearL.y * inv), -- 1429
			Color(28, 22, 19, 224) -- 1429
		}, -- 1429
		{ -- 1430
			Vec2(clothL.x * inv, clothL.y * inv), -- 1430
			Color(36, 29, 25, 212) -- 1430
		}, -- 1430
		{ -- 1431
			Vec2(clothR.x * inv, clothR.y * inv), -- 1431
			Color(26, 21, 18, 198) -- 1431
		} -- 1431
	}) -- 1431
	if p.player.crouch and p.player.x >= arch.x0 - 16 and p.player.x <= arch.x1 + 16 then -- 1435
		local topBandH = ctx.uiH * 0.14 -- 1436
		fillVGradRect( -- 1437
			uiDraw, -- 1438
			0, -- 1439
			ctx.uiH - topBandH, -- 1440
			ctx.uiW, -- 1441
			topBandH, -- 1442
			Color(12, 10, 9, 0), -- 1443
			Color(12, 10, 9, 138) -- 1444
		) -- 1444
	end -- 1444
	return false -- 1449
end -- 1365
return ____exports -- 1365
