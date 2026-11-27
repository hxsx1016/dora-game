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
	if segs == nil then -- 143
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
	if edgeW == nil then -- 162
		edgeW = 0 -- 172
	end -- 172
	local v0 = Vec2(p0.x * invScale, p0.y * invScale) -- 174
	local v1 = Vec2(p1.x * invScale, p1.y * invScale) -- 175
	local v2 = Vec2(p2.x * invScale, p2.y * invScale) -- 176
	local v3 = Vec2(p3.x * invScale, p3.y * invScale) -- 177
	uiDraw:drawVertices({{v0, cBot}, {v1, cBot}, {v2, cTop}}) -- 178
	uiDraw:drawVertices({{v0, cBot}, {v2, cTop}, {v3, cTop}}) -- 183
	if edgeCol ~= nil and edgeW > 0 then -- 183
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
	return p.room.passLine or p.ox + 440 -- 277
end -- 276
function VillageUndertableScene.prototype.classifyLandingSurface(self, p, x, explicitSurface) -- 281
	if explicitSurface == "iron" or explicitSurface == "basin" then -- 281
		return "iron" -- 283
	end -- 283
	if explicitSurface == "soft" or explicitSurface == "dirt" then -- 283
		return "soft" -- 286
	end -- 286
	if explicitSurface == "brick" then -- 286
		return "brick" -- 289
	end -- 289
	local basinX = self:getBasinWorldX(p) -- 291
	if math.abs(x - basinX) <= ____exports.VILLAGE_BASIN_HIT_RADIUS then -- 291
		return "iron" -- 293
	end -- 293
	local softX = self:getSoftWorldX(p) -- 295
	if math.abs(x - softX) <= ____exports.VILLAGE_SURFACE_HIT_RADIUS then -- 295
		return "soft" -- 297
	end -- 297
	return "brick" -- 299
end -- 281
function VillageUndertableScene.prototype.getDebugState(self, p) -- 302
	return { -- 303
		active = self.active, -- 304
		basinWorldX = p ~= nil and self:getBasinWorldX(p) or ____exports.VILLAGE_BASIN_OFFSET_X, -- 305
		brickWorldX = p ~= nil and self:getBrickWorldX(p) or 608, -- 306
		softWorldX = p ~= nil and self:getSoftWorldX(p) or 272, -- 307
		culvertWorldX = p ~= nil and self:getCulvertWorldX(p) or 440, -- 308
		lastSurface = self.lastSurface, -- 309
		brickHits = self.brickHits, -- 310
		ironHits = self.ironHits, -- 311
		softHits = self.softHits, -- 312
		basinShakeTimer = self.basinShakeTimer, -- 313
		basinShakeAngle = self.basinShakeAngle, -- 314
		shoeToePauseTimer = self.shoeToePauseTimer, -- 315
		shoeFacing = self.shoeFacing, -- 316
		scavTargetX = p ~= nil and p.scavTargetX or 0, -- 317
		underTableFocus = self.underTableFocus, -- 318
		lastLandX = self.lastLandX -- 319
	} -- 319
end -- 302
function VillageUndertableScene.prototype.update(self, ctx) -- 323
	local p = ctx.p -- 324
	self.active = true -- 325
	local arch = p.room.arch -- 328
	local nearTable = p.player.x >= arch.x0 - 80 and p.player.x <= arch.x1 + 30 -- 329
	local targetFocus = (p.player.crouch or nearTable) and 1 or 0.72 -- 330
	if not ctx.paused and ctx.worldDt > 0 then -- 330
		local dt = ctx.worldDt -- 332
		self.animTime = self.animTime + dt -- 333
		self.underTableFocus = self.underTableFocus + (targetFocus - self.underTableFocus) * math.min(1, dt * 4.5) -- 334
		if self.basinShakeTimer > 0 then -- 334
			self.basinShakeTimer = math.max(0, self.basinShakeTimer - dt) -- 338
			local elapsed = self.basinShakeMax - self.basinShakeTimer -- 339
			self.basinShakeAngle = math.sin(elapsed * 38) * math.exp(-elapsed * 3.1) * 0.24 -- 340
		else -- 340
			self.basinShakeAngle = 0 -- 342
		end -- 342
		if self.shoeToePauseTimer > 0 then -- 342
			self.shoeToePauseTimer = math.max(0, self.shoeToePauseTimer - dt) -- 347
		end -- 347
		local scavDx = p.scavX - self.prevScavX -- 349
		if math.abs(scavDx) > 0.02 then -- 349
			self.scavStridePhase = self.scavStridePhase + math.abs(scavDx) * 0.16 -- 351
		elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" then -- 351
			self.scavStridePhase = self.scavStridePhase + dt * (p.scavState == "chase" and 11.5 or 6.2) -- 353
		end -- 353
		self.prevScavX = p.scavX -- 355
		local desiredFacing = self:computeDesiredShoeFacing(p) -- 358
		if self.shoeToePauseTimer <= 0 then -- 358
			self.shoeFacing = desiredFacing -- 360
			self.shoeTurnBlend = math.min(1, self.shoeTurnBlend + dt * 6) -- 361
		end -- 361
		local i = 0 -- 365
		do -- 365
			i = 0 -- 366
			while i < #ctx.events.rawEvents do -- 366
				local ev = ctx.events.rawEvents[i + 1] -- 367
				if ev.name == "bottleLanded" then -- 367
					self:onBottleLanded(ctx, ev) -- 369
				end -- 369
				i = i + 1 -- 366
			end -- 366
		end -- 366
		if p.scavState == "turn" and self.prevScavState ~= "turn" then -- 366
			if self.lastSurface == "brick" and self.shoeToePauseTimer <= 0 then -- 366
				self.shoeToePauseTimer = 0.14 -- 376
			end -- 376
		end -- 376
		self.prevScavState = p.scavState -- 379
		local w = 0 -- 382
		do -- 382
			i = 0 -- 383
			while i < #self.shards do -- 383
				local sp = self.shards[i + 1] -- 384
				sp.life = sp.life - dt -- 385
				if sp.life > 0 then -- 385
					sp.vy = sp.vy - (sp.kind == "soft" and 180 or 420) * dt -- 387
					sp.x = sp.x + sp.vx * dt -- 388
					sp.y = sp.y + sp.vy * dt -- 389
					if sp.y < 0 then -- 389
						sp.y = 0 -- 391
						sp.vy = -sp.vy * 0.28 -- 392
						sp.vx = sp.vx * 0.62 -- 393
					end -- 393
					self.shards[w + 1] = sp -- 395
					w = w + 1 -- 396
				end -- 396
				i = i + 1 -- 383
			end -- 383
		end -- 383
		__TS__ArraySetLength(self.shards, w) -- 383
		w = 0 -- 402
		do -- 402
			i = 0 -- 403
			while i < #self.rings do -- 403
				local rg = self.rings[i + 1] -- 404
				rg.age = rg.age + dt -- 405
				if rg.age < rg.duration then -- 405
					self.rings[w + 1] = rg -- 407
					w = w + 1 -- 408
				end -- 408
				i = i + 1 -- 403
			end -- 403
		end -- 403
		__TS__ArraySetLength(self.rings, w) -- 403
		ctx.audio:playLoop( -- 414
			"fe04_village_night", -- 414
			"ambience", -- 414
			CHILD_AUDIO_ROOT .. "village_night_loop.wav", -- 414
			0.24, -- 414
			p.ticks -- 414
		) -- 414
	elseif self.underTableFocus == 0 then -- 414
		self.underTableFocus = targetFocus -- 416
	end -- 416
	local focusAnchorX = math.max( -- 420
		p.ox + 305, -- 420
		math.min(p.ox + 455, p.ox + 355 + (p.player.x - (p.ox + 320)) * 0.28) -- 420
	) -- 420
	local zoom = 1.04 + (1 - self.underTableFocus) * 0.04 -- 421
	ctx.cam:setAnchorLock({ -- 422
		footWorldX = focusAnchorX, -- 423
		footWorldY = 0, -- 424
		footDepth = 0, -- 425
		thresholdWorldX = p.ox + 440, -- 426
		screenFootFracX = 0.5, -- 427
		screenFootFracY = 0.235, -- 428
		zoomOverride = zoom -- 429
	}) -- 429
	self.proj = { -- 432
		morph = 1, -- 433
		focal = 390, -- 434
		vpFracX = 0.54, -- 435
		vpFracY = 0.43 - self.underTableFocus * 0.03, -- 436
		vpOffsetX = math.sin(self.animTime * 0.65) * 1.4, -- 437
		vpOffsetY = math.cos(self.animTime * 0.85) * 1, -- 438
		baseDepth = 0 -- 439
	} -- 439
end -- 323
function VillageUndertableScene.prototype.computeDesiredShoeFacing(self, p) -- 443
	if p.scavState == "chase" then -- 443
		return p.player.x >= p.scavX and 1 or -1 -- 445
	end -- 445
	if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 445
		if math.abs(p.scavTargetX - p.scavX) > 2 then -- 445
			return p.scavTargetX >= p.scavX and 1 or -1 -- 449
		end -- 449
	end -- 449
	if p.scavState == "back" and p.room.scavenger ~= nil then -- 449
		local home = math.max( -- 453
			p.room.scavenger.x0, -- 453
			math.min(p.room.scavenger.x1, p.scavX) -- 453
		) -- 453
		if math.abs(home - p.scavX) > 2 then -- 453
			return home > p.scavX and 1 or -1 -- 455
		end -- 455
	end -- 455
	return p.scavDir >= 0 and 1 or -1 -- 458
end -- 443
function VillageUndertableScene.prototype.onBottleLanded(self, ctx, ev) -- 461
	local p = ctx.p -- 462
	local x = type(ev.data.x) == "number" and ev.data.x or p.bottleLandX -- 463
	local y = type(ev.data.y) == "number" and ev.data.y or math.max(0, p.bottleLandY) -- 464
	local explicitSurface = type(ev.data.surface) == "string" and ev.data.surface or nil -- 465
	local surface = self:classifyLandingSurface(p, x, explicitSurface) -- 466
	self.lastSurface = surface -- 468
	self.lastLandX = x -- 469
	if surface == "iron" then -- 469
		self.ironHits = self.ironHits + 1 -- 472
		self.basinShakeTimer = self.basinShakeMax -- 473
		self.shoeToePauseTimer = 0 -- 474
		self.shoeTurnBlend = 0.25 -- 475
		local bx = self:getBasinWorldX(p) -- 476
		local ____self_rings_0 = self.rings -- 476
		____self_rings_0[#____self_rings_0 + 1] = { -- 478
			x = bx, -- 478
			y = 12, -- 478
			age = 0, -- 478
			duration = 1.05, -- 478
			maxRadius = 84, -- 478
			kind = "iron" -- 478
		} -- 478
		local ____self_rings_1 = self.rings -- 478
		____self_rings_1[#____self_rings_1 + 1] = { -- 479
			x = bx, -- 479
			y = 12, -- 479
			age = -0.14, -- 479
			duration = 1.2, -- 479
			maxRadius = 112, -- 479
			kind = "iron" -- 479
		} -- 479
		local ____self_rings_2 = self.rings -- 479
		____self_rings_2[#____self_rings_2 + 1] = { -- 480
			x = bx, -- 480
			y = 12, -- 480
			age = -0.28, -- 480
			duration = 1.32, -- 480
			maxRadius = 136, -- 480
			kind = "iron" -- 480
		} -- 480
		self:spawnShards(bx, 12, "iron", 7) -- 481
		local key = (((("fe04:village:iron_ring:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(ev.tick)) .. ":") .. tostring(ev.seq) -- 484
		ctx.audio:playOnce( -- 485
			key, -- 486
			"sfx", -- 487
			CHILD_AUDIO_ROOT .. "bottle_iron_ring.wav", -- 488
			0.82, -- 489
			"fe04:bottle:iron_ring", -- 490
			ev.tick, -- 491
			ev.seq -- 492
		) -- 492
	elseif surface == "brick" then -- 492
		self.brickHits = self.brickHits + 1 -- 495
		self.shoeToePauseTimer = 0.14 -- 497
		local ____self_rings_3 = self.rings -- 497
		____self_rings_3[#____self_rings_3 + 1] = { -- 498
			x = x, -- 498
			y = math.max(2, y), -- 498
			age = 0, -- 498
			duration = 0.44, -- 498
			maxRadius = 58, -- 498
			kind = "brick" -- 498
		} -- 498
		self:spawnShards( -- 499
			x, -- 499
			math.max(2, y), -- 499
			"brick", -- 499
			9 -- 499
		) -- 499
	else -- 499
		self.softHits = self.softHits + 1 -- 501
		local ____self_rings_4 = self.rings -- 501
		____self_rings_4[#____self_rings_4 + 1] = { -- 502
			x = x, -- 502
			y = math.max(2, y), -- 502
			age = 0, -- 502
			duration = 0.36, -- 502
			maxRadius = 24, -- 502
			kind = "soft" -- 502
		} -- 502
		self:spawnShards( -- 503
			x, -- 503
			math.max(2, y), -- 503
			"soft", -- 503
			6 -- 503
		) -- 503
		local audioKey = ((((((("r" .. tostring(ctx.events.roomSessionId)) .. ":cp") .. tostring(ctx.events.checkpoint)) .. ":t") .. tostring(ev.tick)) .. ":s") .. tostring(ev.seq)) .. ":bottleLanded" -- 506
		if not ctx.audio:hasPlayed(audioKey) then -- 506
			local key = (((("fe04:village:soft_thud:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(ev.tick)) .. ":") .. tostring(ev.seq) -- 508
			ctx.audio:playOnce( -- 509
				key, -- 510
				"sfx", -- 511
				CHILD_AUDIO_ROOT .. "bottle_soft.wav", -- 512
				0.76, -- 513
				"fe04:bottle:soft_thud", -- 514
				ev.tick, -- 515
				ev.seq -- 516
			) -- 516
		end -- 516
	end -- 516
end -- 461
function VillageUndertableScene.prototype.spawnShards(self, x, y, kind, count) -- 522
	local i = 0 -- 523
	do -- 523
		i = 0 -- 524
		while i < count do -- 524
			local ang = (0.18 + self:rand() * 0.64) * math.pi -- 525
			local spd = (kind == "soft" and 28 or 65) + self:rand() * (kind == "soft" and 36 or 95) -- 526
			local ____self_shards_5 = self.shards -- 526
			____self_shards_5[#____self_shards_5 + 1] = { -- 527
				x = x + (self:rand() - 0.5) * 10, -- 528
				y = y + 2, -- 529
				vx = math.cos(ang) * spd * (self:rand() > 0.5 and 1 or -1), -- 530
				vy = math.sin(ang) * spd, -- 531
				size = kind == "soft" and 2.2 + self:rand() * 2.4 or 1.8 + self:rand() * 2.2, -- 532
				life = (kind == "soft" and 0.34 or 0.48) + self:rand() * 0.22, -- 533
				maxLife = 0.65, -- 534
				kind = kind -- 535
			} -- 535
			i = i + 1 -- 524
		end -- 524
	end -- 524
end -- 522
function VillageUndertableScene.prototype.triggerRehearsalImpact(self, ctx, surface) -- 541
	local p = ctx.p -- 542
	local x = surface == "iron" and self:getBasinWorldX(p) or (surface == "soft" and self:getSoftWorldX(p) or self:getBrickWorldX(p)) -- 543
	self:onBottleLanded(ctx, {seq = 9000 + self.brickHits + self.ironHits + self.softHits, tick = p.ticks, name = "bottleLanded", data = {x = x, y = 0, surface = surface, heard = true}}) -- 546
end -- 541
function VillageUndertableScene.prototype.drawBackdrop(self, bgDraw, bgGlow, _backdropArt, ctx) -- 554
	local p = ctx.p -- 560
	local cam = ctx.cam -- 561
	local w = cam.viewW -- 562
	local h = cam.viewH -- 563
	local splitY = h * 0.5 -- 566
	fillVGradRect( -- 567
		bgDraw, -- 567
		0, -- 567
		splitY, -- 567
		w, -- 567
		h - splitY, -- 567
		Color(14, 18, 26, 255), -- 567
		Color(7, 9, 15, 255) -- 567
	) -- 567
	fillVGradRect( -- 568
		bgDraw, -- 568
		0, -- 568
		0, -- 568
		w, -- 568
		splitY, -- 568
		Color(24, 28, 38, 255), -- 568
		Color(14, 18, 26, 255) -- 568
	) -- 568
	local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 570
	local ox = p.ox -- 571
	scene:addDistantRidge( -- 574
		{ -- 575
			{x = ox - 140, y = 120}, -- 576
			{x = ox + 120, y = 162}, -- 577
			{x = ox + 360, y = 138}, -- 578
			{x = ox + 590, y = 176}, -- 579
			{x = ox + 860, y = 132} -- 580
		}, -- 580
		-20, -- 580
		420, -- 583
		MING_MATERIALS.distantHill, -- 584
		{bucket = LP_BUCKET.BACKDROP} -- 585
	) -- 585
	scene:addBox({ -- 589
		x0 = ox + 460, -- 590
		x1 = ox + 690, -- 591
		y0 = 0, -- 592
		y1 = 118, -- 593
		z0 = 210, -- 594
		z1 = 260, -- 595
		material = MING_MATERIALS.distantWall, -- 596
		bucket = LP_BUCKET.BACKDROP, -- 597
		edgeWidth = 0 -- 598
	}) -- 598
	scene:addTri3D( -- 600
		vec3(ox + 446, 118, 206), -- 601
		vec3(ox + 704, 118, 206), -- 602
		vec3(ox + 575, 162, 232), -- 603
		MING_MATERIALS.mingTile, -- 604
		{bucket = LP_BUCKET.BACKDROP, sortBias = 0.04} -- 605
	) -- 605
	scene:addBox({ -- 609
		x0 = ox - 60, -- 610
		x1 = ox + 436, -- 611
		y0 = 0, -- 612
		y1 = 196, -- 613
		z0 = 112, -- 614
		z1 = 152, -- 615
		material = MING_MATERIALS.mingBrickDark, -- 616
		bucket = LP_BUCKET.BACKDROP, -- 617
		edgeWidth = 0.6 -- 618
	}) -- 618
	scene:addBox({ -- 622
		x0 = ox + 150, -- 623
		x1 = ox + 258, -- 624
		y0 = 0, -- 625
		y1 = 42, -- 626
		z0 = 76, -- 627
		z1 = 112, -- 628
		material = MAT_CLAY_STOVE, -- 629
		bucket = LP_BUCKET.MIDGROUND, -- 630
		highlightTopEdge = true -- 631
	}) -- 631
	scene:addBox({ -- 633
		x0 = ox + 178, -- 634
		x1 = ox + 228, -- 635
		y0 = 42, -- 636
		y1 = 156, -- 637
		z0 = 94, -- 638
		z1 = 114, -- 639
		material = MAT_CLAY_STOVE, -- 640
		bucket = LP_BUCKET.MIDGROUND, -- 641
		edgeWidth = 0.5 -- 642
	}) -- 642
	scene:addBox({ -- 646
		x0 = ox + 486, -- 647
		x1 = ox + 536, -- 648
		y0 = 0, -- 649
		y1 = 34, -- 650
		z0 = 126, -- 651
		z1 = 162, -- 652
		material = MING_MATERIALS.mingStoneStep, -- 653
		bucket = LP_BUCKET.MIDGROUND, -- 654
		highlightTopEdge = true -- 655
	}) -- 655
	scene:addFogBand( -- 659
		ox - 120, -- 659
		ox + 840, -- 659
		-10, -- 659
		140, -- 659
		260, -- 659
		rgba(24, 30, 42, 255), -- 659
		0.62, -- 659
		0.05, -- 659
		{bucket = LP_BUCKET.BACKDROP} -- 659
	) -- 659
	scene:flush(bgDraw, bgGlow) -- 663
	local mx = w * 0.8 -- 666
	local my = h * 0.84 -- 667
	fillRadialGlow( -- 668
		bgGlow, -- 668
		mx, -- 668
		my, -- 668
		96, -- 668
		96, -- 668
		Color(188, 206, 224, 24), -- 668
		Color(24, 32, 46, 0), -- 668
		16 -- 668
	) -- 668
	bgDraw:drawCircle( -- 669
		Vec2(mx, my), -- 669
		14, -- 669
		Color(214, 224, 236, 130) -- 669
	) -- 669
	local towerPt = projectWorld3D( -- 672
		ox + 668, -- 672
		152, -- 672
		410, -- 672
		cam, -- 672
		self.proj -- 672
	) -- 672
	fillRadialGlow( -- 673
		bgGlow, -- 673
		towerPt.x, -- 673
		towerPt.y, -- 673
		20, -- 673
		20, -- 673
		Color(238, 198, 132, 54), -- 673
		Color(238, 198, 132, 0), -- 673
		12 -- 673
	) -- 673
	bgGlow:drawDot( -- 674
		Vec2(towerPt.x, towerPt.y), -- 674
		2, -- 674
		Color(252, 232, 186, 185) -- 674
	) -- 674
	return true -- 676
end -- 554
function VillageUndertableScene.prototype.drawWorld(self, fgDraw, fgGlow, _worldArt, ctx) -- 679
	local p = ctx.p -- 685
	local cam = ctx.cam -- 686
	local ox = p.ox -- 687
	local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 688
	scene:addBox({ -- 691
		x0 = ox - 40, -- 692
		x1 = ox + 436, -- 693
		y0 = -52, -- 694
		y1 = 0, -- 695
		z0 = -32, -- 696
		z1 = 112, -- 697
		material = MING_MATERIALS.mingTimberDark, -- 698
		bucket = LP_BUCKET.MIDGROUND, -- 699
		highlightTopEdge = true, -- 700
		edgeWidth = 0.7 -- 701
	}) -- 701
	scene:addBox({ -- 703
		x0 = ox + 436, -- 704
		x1 = ox + 760, -- 705
		y0 = -52, -- 706
		y1 = 0, -- 707
		z0 = -32, -- 708
		z1 = 126, -- 709
		material = MING_MATERIALS.mingBrickDark, -- 710
		bucket = LP_BUCKET.MIDGROUND, -- 711
		highlightTopEdge = true, -- 712
		edgeWidth = 0.8 -- 713
	}) -- 713
	scene:addBeveledFrame( -- 717
		ox + 416, -- 717
		ox + 462, -- 717
		0, -- 717
		128, -- 717
		16, -- 717
		22, -- 717
		16, -- 717
		112, -- 717
		MING_MATERIALS.mingTimberDark, -- 717
		{ -- 717
			bucket = LP_BUCKET.MIDGROUND, -- 718
			innerRimLight = rgba(206, 214, 222, 255), -- 719
			innerRimStrength = 0.42 -- 720
		} -- 720
	) -- 720
	scene:addBox({ -- 724
		x0 = ox + 96, -- 725
		x1 = ox + 101, -- 726
		y0 = 0, -- 727
		y1 = 52, -- 728
		z0 = -6, -- 729
		z1 = 24, -- 730
		material = MAT_TABLE_WOOD, -- 731
		bucket = LP_BUCKET.WALK_DECK, -- 732
		edgeWidth = 0.8 -- 733
	}) -- 733
	scene:addBox({ -- 735
		x0 = ox + 123, -- 736
		x1 = ox + 128, -- 737
		y0 = 0, -- 738
		y1 = 52, -- 739
		z0 = -6, -- 740
		z1 = 24, -- 741
		material = MAT_TABLE_WOOD, -- 742
		bucket = LP_BUCKET.WALK_DECK, -- 743
		edgeWidth = 0.8 -- 744
	}) -- 744
	scene:addBox({ -- 746
		x0 = ox + 95, -- 747
		x1 = ox + 129, -- 748
		y0 = 24, -- 749
		y1 = 28, -- 750
		z0 = -8, -- 751
		z1 = 26, -- 752
		material = MING_MATERIALS.mingTimber, -- 753
		bucket = LP_BUCKET.WALK_DECK, -- 754
		sortBias = 0.05 -- 755
	}) -- 755
	scene:addBox({ -- 757
		x0 = ox + 94, -- 758
		x1 = ox + 130, -- 759
		y0 = 48, -- 760
		y1 = 52, -- 761
		z0 = -8, -- 762
		z1 = 26, -- 763
		material = MING_MATERIALS.mingTimber, -- 764
		bucket = LP_BUCKET.WALK_DECK, -- 765
		highlightTopEdge = true, -- 766
		sortBias = 0.06 -- 767
	}) -- 767
	scene:addBox({ -- 770
		x0 = ox + 672, -- 771
		x1 = ox + 720, -- 772
		y0 = 0, -- 773
		y1 = 96, -- 774
		z0 = -14, -- 775
		z1 = 96, -- 776
		material = MING_MATERIALS.mingBrick, -- 777
		bucket = LP_BUCKET.MIDGROUND, -- 778
		highlightTopEdge = true, -- 779
		edgeWidth = 0.9 -- 780
	}) -- 780
	scene:addBox({ -- 782
		x0 = ox + 666, -- 783
		x1 = ox + 726, -- 784
		y0 = 96, -- 785
		y1 = 106, -- 786
		z0 = -18, -- 787
		z1 = 100, -- 788
		material = MING_MATERIALS.mingTile, -- 789
		bucket = LP_BUCKET.MIDGROUND, -- 790
		sortBias = 0.08 -- 791
	}) -- 791
	local arch = p.room.arch -- 796
	scene:addBox({ -- 798
		x0 = arch.x0 - 1, -- 799
		x1 = arch.x0 + 7, -- 800
		y0 = 0, -- 801
		y1 = arch.h, -- 802
		z0 = 12, -- 803
		z1 = 22, -- 804
		material = MAT_TABLE_WOOD, -- 805
		bucket = LP_BUCKET.MIDGROUND, -- 806
		edgeWidth = 0.8 -- 807
	}) -- 807
	scene:addBox({ -- 809
		x0 = arch.x1 - 7, -- 810
		x1 = arch.x1 + 1, -- 811
		y0 = 0, -- 812
		y1 = arch.h, -- 813
		z0 = 12, -- 814
		z1 = 22, -- 815
		material = MAT_TABLE_WOOD, -- 816
		bucket = LP_BUCKET.MIDGROUND, -- 817
		edgeWidth = 0.8 -- 818
	}) -- 818
	scene:addBox({ -- 821
		x0 = arch.x0 + 7, -- 822
		x1 = arch.x1 - 7, -- 823
		y0 = arch.h - 5, -- 824
		y1 = arch.h, -- 825
		z0 = 14, -- 826
		z1 = 20, -- 827
		material = MAT_TABLE_WOOD, -- 828
		bucket = LP_BUCKET.MIDGROUND, -- 829
		edgeWidth = 0.6 -- 830
	}) -- 830
	scene:addBox({ -- 833
		x0 = arch.x0 - 8, -- 834
		x1 = arch.x1 + 8, -- 835
		y0 = arch.h, -- 836
		y1 = arch.h + 8, -- 837
		z0 = 4, -- 838
		z1 = 28, -- 839
		material = MAT_TABLE_WOOD, -- 840
		bucket = LP_BUCKET.WALK_DECK, -- 841
		highlightTopEdge = true, -- 842
		edgeWidth = 0.8 -- 843
	}) -- 843
	local culvertX = self:getCulvertWorldX(p) -- 847
	self:buildCulvertEntrance(scene, culvertX) -- 848
	local softX = self:getSoftWorldX(p) -- 852
	self:buildSoftDirtPatch(scene, softX) -- 853
	local brickX = self:getBrickWorldX(p) -- 856
	self:buildHardBrickPatch(scene, brickX) -- 857
	local basinX = self:getBasinWorldX(p) -- 860
	self:buildIronBasin(scene, basinX) -- 861
	scene:addLightShaft( -- 864
		ox + 570, -- 865
		ox + 710, -- 865
		290, -- 865
		ox + 446, -- 866
		ox + 642, -- 866
		0, -- 866
		24, -- 867
		rgba(218, 226, 218, 255), -- 868
		0.13, -- 869
		0.04 -- 870
	) -- 870
	scene:addContactShadow( -- 874
		p.player.x, -- 874
		p.player.y, -- 874
		14, -- 874
		10, -- 874
		0.8, -- 874
		{bucket = LP_BUCKET.PROP, sortBias = 0.4} -- 874
	) -- 874
	if p.room.scavenger ~= nil then -- 874
		scene:addContactShadow( -- 876
			p.scavX, -- 876
			p.room.scavenger.y, -- 876
			19, -- 876
			13, -- 876
			0.84, -- 876
			{bucket = LP_BUCKET.PROP, sortBias = 0.42} -- 876
		) -- 876
	end -- 876
	scene:flush(fgDraw, fgGlow) -- 879
	self:drawSurfaceReadabilityDetails( -- 882
		fgDraw, -- 882
		fgGlow, -- 882
		p, -- 882
		cam, -- 882
		softX, -- 882
		culvertX, -- 882
		basinX, -- 882
		brickX -- 882
	) -- 882
	return true -- 884
end -- 679
function VillageUndertableScene.prototype.buildCulvertEntrance(self, scene, cx) -- 887
	scene:addBox({ -- 889
		x0 = cx - 18, -- 890
		x1 = cx + 18, -- 891
		y0 = -12, -- 892
		y1 = 2, -- 893
		z0 = -6, -- 894
		z1 = 42, -- 895
		material = MAT_CULVERT_STONE, -- 896
		bucket = LP_BUCKET.WALK_DECK, -- 897
		highlightTopEdge = true, -- 898
		edgeWidth = 1 -- 899
	}) -- 899
	scene:addQuad3D( -- 902
		vec3(cx - 12, 1, 22), -- 903
		vec3(cx + 12, 1, 22), -- 904
		vec3(cx + 10, 26, 22), -- 905
		vec3(cx - 10, 26, 22), -- 906
		{base = rgba(6, 9, 14, 255)}, -- 907
		{ -- 908
			bucket = LP_BUCKET.MIDGROUND, -- 908
			unlit = true, -- 908
			sortBias = 0.35, -- 908
			edgeColor = rgba(186, 204, 222, 185), -- 908
			edgeWidth = 1.2 -- 908
		} -- 908
	) -- 908
	scene:addBox({ -- 911
		x0 = cx - 15, -- 912
		x1 = cx - 11, -- 913
		y0 = 2, -- 914
		y1 = 24, -- 915
		z0 = 14, -- 916
		z1 = 22, -- 917
		material = MING_MATERIALS.mingTimber, -- 918
		bucket = LP_BUCKET.PROP, -- 919
		highlightTopEdge = true -- 920
	}) -- 920
	local gi = 0 -- 922
	do -- 922
		gi = 0 -- 923
		while gi < 3 do -- 923
			local gx = cx - 6 + gi * 6 -- 924
			scene:addBox({ -- 925
				x0 = gx - 1, -- 926
				x1 = gx + 1, -- 927
				y0 = 2, -- 928
				y1 = 24, -- 929
				z0 = 18, -- 930
				z1 = 21, -- 931
				material = MING_MATERIALS.mingIron, -- 932
				bucket = LP_BUCKET.PROP, -- 933
				sortBias = 0.1 -- 934
			}) -- 934
			gi = gi + 1 -- 923
		end -- 923
	end -- 923
end -- 887
function VillageUndertableScene.prototype.buildSoftDirtPatch(self, scene, softX) -- 939
	scene:addBox({ -- 940
		x0 = softX - 24, -- 941
		x1 = softX + 24, -- 942
		y0 = -4, -- 943
		y1 = 1.5, -- 944
		z0 = -16, -- 945
		z1 = 28, -- 946
		material = MAT_SOFT_EARTH, -- 947
		bucket = LP_BUCKET.WALK_DECK, -- 948
		sortBias = 0.15, -- 949
		edgeWidth = 0.4 -- 950
	}) -- 950
end -- 939
function VillageUndertableScene.prototype.buildHardBrickPatch(self, scene, brickX) -- 954
	local col = 0 -- 956
	do -- 956
		col = 0 -- 957
		while col < 3 do -- 957
			local bx0 = brickX - 24 + col * 16 -- 958
			local bx1 = bx0 + 14.5 -- 959
			scene:addBox({ -- 960
				x0 = bx0, -- 961
				x1 = bx1, -- 962
				y0 = -4, -- 963
				y1 = 3.2, -- 964
				z0 = -14, -- 965
				z1 = 6, -- 966
				material = MAT_HARD_BRICK, -- 967
				bucket = LP_BUCKET.WALK_DECK, -- 968
				sortBias = 0.2 + col * 0.01, -- 969
				highlightTopEdge = true, -- 970
				edgeWidth = 1 -- 971
			}) -- 971
			scene:addBox({ -- 973
				x0 = bx0 + 4, -- 974
				x1 = bx1 + 4, -- 975
				y0 = -4, -- 976
				y1 = 2.8, -- 977
				z0 = 8, -- 978
				z1 = 26, -- 979
				material = MAT_HARD_BRICK, -- 980
				bucket = LP_BUCKET.WALK_DECK, -- 981
				sortBias = 0.18 + col * 0.01, -- 982
				highlightTopEdge = true, -- 983
				edgeWidth = 0.9 -- 984
			}) -- 984
			col = col + 1 -- 957
		end -- 957
	end -- 957
end -- 954
function VillageUndertableScene.prototype.buildIronBasin(self, scene, basinX) -- 989
	scene:addBox({ -- 991
		x0 = basinX - 14, -- 992
		x1 = basinX + 14, -- 993
		y0 = -2, -- 994
		y1 = 3, -- 995
		z0 = -10, -- 996
		z1 = 14, -- 997
		material = MING_MATERIALS.mingBrickDark, -- 998
		bucket = LP_BUCKET.PROP, -- 999
		sortBias = 0.02 -- 1000
	}) -- 1000
	local tilt = self.basinShakeAngle -- 1003
	local liftL = math.sin(tilt) * 14 -- 1004
	local liftR = -liftL -- 1005
	local shiftX = math.sin(tilt * 1.4) * 2.5 -- 1006
	local baseY = 3 -- 1007
	local topY = 14.5 -- 1008
	local bx = basinX + shiftX -- 1009
	scene:addQuad3D( -- 1012
		vec3( -- 1013
			bx - 11, -- 1013
			baseY + math.max(0, liftL * 0.4), -- 1013
			-8 -- 1013
		), -- 1013
		vec3( -- 1014
			bx + 11, -- 1014
			baseY + math.max(0, liftR * 0.4), -- 1014
			-8 -- 1014
		), -- 1014
		vec3(bx + 16, topY + liftR, -12), -- 1015
		vec3(bx - 16, topY + liftL, -12), -- 1016
		MAT_IRON_BASIN, -- 1017
		{bucket = LP_BUCKET.PROP, sortBias = 0.25, edgeWidth = 1.2} -- 1018
	) -- 1018
	scene:addQuad3D( -- 1021
		vec3( -- 1022
			bx - 11, -- 1022
			baseY + math.max(0, liftL * 0.4), -- 1022
			10 -- 1022
		), -- 1022
		vec3( -- 1023
			bx - 11, -- 1023
			baseY + math.max(0, liftL * 0.4), -- 1023
			-8 -- 1023
		), -- 1023
		vec3(bx - 16, topY + liftL, -12), -- 1024
		vec3(bx - 16, topY + liftL, 14), -- 1025
		MAT_IRON_BASIN, -- 1026
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1027
	) -- 1027
	scene:addQuad3D( -- 1029
		vec3( -- 1030
			bx + 11, -- 1030
			baseY + math.max(0, liftR * 0.4), -- 1030
			-8 -- 1030
		), -- 1030
		vec3( -- 1031
			bx + 11, -- 1031
			baseY + math.max(0, liftR * 0.4), -- 1031
			10 -- 1031
		), -- 1031
		vec3(bx + 16, topY + liftR, 14), -- 1032
		vec3(bx + 16, topY + liftR, -12), -- 1033
		MAT_IRON_BASIN, -- 1034
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1035
	) -- 1035
	scene:addQuad3D( -- 1038
		vec3(bx - 14, topY - 1 + liftL, -10), -- 1039
		vec3(bx + 14, topY - 1 + liftR, -10), -- 1040
		vec3(bx + 14, topY - 1 + liftR, 12), -- 1041
		vec3(bx - 14, topY - 1 + liftL, 12), -- 1042
		{ -- 1043
			base = rgba(24, 30, 40, 255), -- 1043
			edge = rgba(232, 238, 246, 235) -- 1043
		}, -- 1043
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 1.5} -- 1044
	) -- 1044
end -- 989
function VillageUndertableScene.prototype.drawSurfaceReadabilityDetails(self, fgDraw, fgGlow, p, cam, softX, culvertX, basinX, brickX) -- 1048
	local y0 = cam:sy(0) -- 1058
	local sx0 = cam:sx(softX - 20) -- 1061
	local sx1 = cam:sx(softX + 20) -- 1062
	local d = 0 -- 1063
	do -- 1063
		d = 0 -- 1064
		while d < 9 do -- 1064
			local dx = sx0 + (sx1 - sx0) * (d + 0.5) / 9 -- 1065
			local dy = y0 - 2.5 + (d % 3 - 1) * 1.8 -- 1066
			fgDraw:drawDot( -- 1067
				Vec2(dx, dy), -- 1067
				1.3, -- 1067
				Color(116, 98, 78, 175) -- 1067
			) -- 1067
			d = d + 1 -- 1064
		end -- 1064
	end -- 1064
	fgDraw:drawEllipse( -- 1069
		Vec2( -- 1069
			cam:sx(softX - 7), -- 1069
			y0 - 1.5 -- 1069
		), -- 1069
		cam:len(4.2), -- 1069
		1.6, -- 1069
		Color(38, 30, 24, 185) -- 1069
	) -- 1069
	fgDraw:drawEllipse( -- 1070
		Vec2( -- 1070
			cam:sx(softX + 8), -- 1070
			y0 - 2 -- 1070
		), -- 1070
		cam:len(4.2), -- 1070
		1.6, -- 1070
		Color(38, 30, 24, 185) -- 1070
	) -- 1070
	local cL = cam:sx(culvertX - 11) -- 1073
	local cR = cam:sx(culvertX + 11) -- 1074
	local cTop = cam:sy(25) -- 1075
	fgDraw:drawSegment( -- 1076
		Vec2(cL, cTop), -- 1076
		Vec2(cR, cTop), -- 1076
		1.6, -- 1076
		Color(196, 210, 224, 210) -- 1076
	) -- 1076
	local rippleShift = math.sin(self.animTime * 2.3) * 3 -- 1077
	fgGlow:drawSegment( -- 1078
		Vec2(cL + 3 + rippleShift, y0 + 2), -- 1078
		Vec2(cR - 4 + rippleShift, y0 + 2), -- 1078
		1.1, -- 1078
		Color(164, 192, 214, 105) -- 1078
	) -- 1078
	local bPtL = projectWorld3D( -- 1081
		basinX - 16, -- 1081
		14.5 + math.sin(self.basinShakeAngle) * 14, -- 1081
		-12, -- 1081
		cam, -- 1081
		self.proj -- 1081
	) -- 1081
	local bPtR = projectWorld3D( -- 1082
		basinX + 16, -- 1082
		14.5 - math.sin(self.basinShakeAngle) * 14, -- 1082
		-12, -- 1082
		cam, -- 1082
		self.proj -- 1082
	) -- 1082
	local shakeBoost = self.basinShakeTimer > 0 and clamp01(self.basinShakeTimer / self.basinShakeMax) or 0 -- 1083
	local rimAlpha = math.floor(205 + 48 * shakeBoost + 0.5) -- 1084
	fgDraw:drawSegment( -- 1085
		Vec2(bPtL.x, bPtL.y), -- 1085
		Vec2(bPtR.x, bPtR.y), -- 1085
		2.1 + shakeBoost * 1.1, -- 1085
		Color(230, 236, 242, rimAlpha) -- 1085
	) -- 1085
	fillRadialGlow( -- 1086
		fgGlow, -- 1087
		(bPtL.x + bPtR.x) * 0.5, -- 1088
		(bPtL.y + bPtR.y) * 0.5, -- 1089
		cam:len(22 + shakeBoost * 18), -- 1090
		cam:len(10 + shakeBoost * 8), -- 1091
		Color( -- 1092
			216, -- 1092
			226, -- 1092
			236, -- 1092
			math.floor(48 + 95 * shakeBoost + 0.5) -- 1092
		), -- 1092
		Color(186, 202, 220, 0), -- 1093
		14 -- 1094
	) -- 1094
	local brL = cam:sx(brickX - 24) -- 1098
	local brR = cam:sx(brickX + 24) -- 1099
	local brTop = cam:sy(3.2) -- 1100
	fgDraw:drawSegment( -- 1101
		Vec2(brL, brTop), -- 1101
		Vec2(brR, brTop), -- 1101
		1.8, -- 1101
		Color(224, 228, 234, 225) -- 1101
	) -- 1101
	local k = 1 -- 1102
	do -- 1102
		k = 1 -- 1103
		while k <= 2 do -- 1103
			local seamX = brL + (brR - brL) * k / 3 -- 1104
			fgDraw:drawSegment( -- 1105
				Vec2(seamX, y0 - 3), -- 1105
				Vec2(seamX, brTop + 1), -- 1105
				1.5, -- 1105
				Color(20, 24, 32, 240) -- 1105
			) -- 1105
			fgDraw:drawSegment( -- 1106
				Vec2(seamX + 1.8, y0 - 2), -- 1106
				Vec2(seamX + 1.8, brTop), -- 1106
				0.9, -- 1106
				Color(214, 218, 224, 175) -- 1106
			) -- 1106
			k = k + 1 -- 1103
		end -- 1103
	end -- 1103
	local i = 0 -- 1110
	do -- 1110
		i = 0 -- 1111
		while i < #self.rings do -- 1111
			do -- 1111
				local rg = self.rings[i + 1] -- 1112
				if rg.age < 0 then -- 1112
					goto __continue75 -- 1114
				end -- 1114
				local t = clamp01(rg.age / rg.duration) -- 1116
				local r = math.max( -- 1117
					4, -- 1117
					cam:len(rg.maxRadius) * (0.14 + 0.86 * t) -- 1117
				) -- 1117
				local alpha = (1 - t) * (rg.kind == "iron" and 0.88 or (rg.kind == "brick" and 0.82 or 0.4)) -- 1118
				local rx = cam:sx(rg.x) -- 1119
				local ry = cam:sy(rg.y) -- 1120
				local ringCol = rg.kind == "iron" and Color( -- 1121
					220, -- 1122
					234, -- 1122
					246, -- 1122
					math.floor(235 * alpha + 0.5) -- 1122
				) or (rg.kind == "brick" and Color( -- 1122
					236, -- 1124
					216, -- 1124
					178, -- 1124
					math.floor(225 * alpha + 0.5) -- 1124
				) or Color( -- 1124
					148, -- 1125
					134, -- 1125
					114, -- 1125
					math.floor(165 * alpha + 0.5) -- 1125
				)) -- 1125
				drawEllipseRing( -- 1126
					fgGlow, -- 1126
					rx, -- 1126
					ry, -- 1126
					r, -- 1126
					r * 0.34, -- 1126
					rg.kind == "iron" and 1.8 or 1.4, -- 1126
					ringCol, -- 1126
					22 -- 1126
				) -- 1126
				if rg.kind == "iron" then -- 1126
					drawEllipseRing( -- 1128
						fgDraw, -- 1128
						rx, -- 1128
						ry, -- 1128
						r * 0.96, -- 1128
						r * 0.32, -- 1128
						1.1, -- 1128
						Color( -- 1128
							214, -- 1128
							224, -- 1128
							236, -- 1128
							math.floor(150 * alpha + 0.5) -- 1128
						), -- 1128
						22 -- 1128
					) -- 1128
				end -- 1128
			end -- 1128
			::__continue75:: -- 1128
			i = i + 1 -- 1111
		end -- 1111
	end -- 1111
	do -- 1111
		i = 0 -- 1131
		while i < #self.shards do -- 1131
			local sp = self.shards[i + 1] -- 1132
			local a = clamp01(sp.life / sp.maxLife) -- 1133
			local col = sp.kind == "soft" and Color( -- 1134
				138, -- 1135
				120, -- 1135
				98, -- 1135
				math.floor(170 * a + 0.5) -- 1135
			) or (sp.kind == "iron" and Color( -- 1135
				224, -- 1137
				232, -- 1137
				242, -- 1137
				math.floor(225 * a + 0.5) -- 1137
			) or Color( -- 1137
				216, -- 1138
				198, -- 1138
				174, -- 1138
				math.floor(220 * a + 0.5) -- 1138
			)) -- 1138
			fgDraw:drawDot( -- 1139
				Vec2( -- 1139
					cam:sx(sp.x), -- 1139
					cam:sy(sp.y) -- 1139
				), -- 1139
				sp.size, -- 1139
				col -- 1139
			) -- 1139
			i = i + 1 -- 1131
		end -- 1131
	end -- 1131
	if p.bottleLandT > 0 and p.bottleLandX >= 0 and #self.rings == 0 then -- 1131
		local rx = cam:sx(p.bottleLandX) -- 1144
		local ry = cam:sy(math.max(1, p.bottleLandY)) -- 1145
		fgDraw:drawDot( -- 1146
			Vec2(rx, ry), -- 1146
			2.5, -- 1146
			Color(216, 206, 186, 150) -- 1146
		) -- 1146
	end -- 1146
end -- 1048
function VillageUndertableScene.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1151
	local p = ctx.p -- 1157
	local cam = ctx.cam -- 1158
	local bottle = p.room.bottle -- 1161
	if bottle ~= nil and not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 1161
		self:drawCeramicBottle( -- 1163
			fgDraw, -- 1163
			fgGlow, -- 1163
			worldArt, -- 1163
			"fe04_bottle_shelf", -- 1163
			cam:sx(bottle.x), -- 1163
			cam:sy(56), -- 1163
			cam.ppu, -- 1163
			0, -- 1163
			true -- 1163
		) -- 1163
	end -- 1163
	if p.hasBottle and p.aimHold <= 0 then -- 1163
		local pl = p.player -- 1168
		self:drawCeramicBottle( -- 1169
			fgDraw, -- 1170
			fgGlow, -- 1171
			worldArt, -- 1172
			"fe04_bottle_held", -- 1173
			cam:sx(pl.x + pl.facing * 10), -- 1174
			cam:sy(pl.y + pl.h * 0.52), -- 1175
			cam.ppu, -- 1176
			pl.facing * 0.22, -- 1177
			false -- 1178
		) -- 1178
	end -- 1178
	if p.bottleFly ~= nil then -- 1178
		self:drawCeramicBottle( -- 1182
			fgDraw, -- 1183
			fgGlow, -- 1184
			worldArt, -- 1185
			"fe04_bottle_air", -- 1186
			cam:sx(p.bottleFly.x), -- 1187
			cam:sy(p.bottleFly.y), -- 1188
			cam.ppu, -- 1189
			self.animTime * 13.5, -- 1190
			false -- 1191
		) -- 1191
	end -- 1191
	if p.hasBottle and p.aimHold > 0 then -- 1191
		local pl = p.player -- 1197
		local endX = p.bottleAimX -- 1198
		local endY = p.bottleAimY -- 1199
		if endX < 0 then -- 1199
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 1201
			endX = wAim.x -- 1202
			endY = 0 -- 1203
		end -- 1203
		local dir = endX >= pl.x and 1 or -1 -- 1205
		local x0 = pl.x + dir * 10 -- 1206
		local y0 = pl.y + pl.h * 0.7 -- 1207
		local vx = (endX - x0) / BOTTLE_FLY_T -- 1208
		local vy = (endY - y0 + 0.5 * GRAVITY * BOTTLE_FLY_T * BOTTLE_FLY_T) / BOTTLE_FLY_T -- 1209
		local previewSurface = self:classifyLandingSurface(p, endX) -- 1211
		local arcRgb = previewSurface == "iron" and rgba(214, 228, 242, 255) or (previewSurface == "brick" and rgba(232, 206, 152, 255) or rgba(154, 142, 126, 255)) -- 1212
		local steps = 18 -- 1218
		local k = 1 -- 1219
		do -- 1219
			k = 1 -- 1220
			while k <= steps do -- 1220
				local tt = k / steps * BOTTLE_FLY_T -- 1221
				local wx = x0 + vx * tt -- 1222
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 1223
				local alpha = 195 * (0.4 + 0.6 * (k / steps)) -- 1224
				fgDraw:drawDot( -- 1225
					Vec2( -- 1225
						cam:sx(wx), -- 1225
						cam:sy(wy) -- 1225
					), -- 1225
					2.5, -- 1225
					toColor(arcRgb, alpha) -- 1225
				) -- 1225
				fgGlow:drawDot( -- 1226
					Vec2( -- 1226
						cam:sx(wx), -- 1226
						cam:sy(wy) -- 1226
					), -- 1226
					3.2, -- 1226
					toColor(arcRgb, alpha * 0.55) -- 1226
				) -- 1226
				k = k + 1 -- 1220
			end -- 1220
		end -- 1220
		local lx = cam:sx(endX) -- 1229
		local ly = cam:sy(endY + 2) -- 1230
		local pulse = 0.88 + 0.12 * math.sin(self.animTime * 5.2) -- 1231
		drawEllipseRing( -- 1232
			fgDraw, -- 1232
			lx, -- 1232
			ly, -- 1232
			11 * pulse, -- 1232
			4.2 * pulse, -- 1232
			1.6, -- 1232
			toColor(arcRgb, 235), -- 1232
			20 -- 1232
		) -- 1232
		if previewSurface == "iron" then -- 1232
			drawEllipseRing( -- 1234
				fgGlow, -- 1234
				lx, -- 1234
				ly, -- 1234
				24 * pulse, -- 1234
				9.2 * pulse, -- 1234
				1.3, -- 1234
				toColor(arcRgb, 195), -- 1234
				22 -- 1234
			) -- 1234
		elseif previewSurface == "brick" then -- 1234
			drawEllipseRing( -- 1236
				fgGlow, -- 1236
				lx, -- 1236
				ly, -- 1236
				18 * pulse, -- 1236
				7 * pulse, -- 1236
				1.2, -- 1236
				toColor(arcRgb, 165), -- 1236
				20 -- 1236
			) -- 1236
		end -- 1236
	end -- 1236
	return true -- 1240
end -- 1151
function VillageUndertableScene.prototype.drawCeramicBottle(self, fgDraw, fgGlow, worldArt, id, cx, cy, ppu, tilt, shelfGlint) -- 1243
	local size = math.max(10, ppu * 10.5) -- 1254
	if not worldArt:tryPlace( -- 1254
		"prop_bottle", -- 1255
		id, -- 1255
		cx, -- 1255
		cy, -- 1255
		size, -- 1255
		size, -- 1255
		{angle = tilt * 180 / math.pi, layer = 8} -- 1255
	) then -- 1255
		fgDraw:drawCircle( -- 1259
			Vec2(cx, cy), -- 1259
			size * 0.36, -- 1259
			Color(172, 138, 102, 245) -- 1259
		) -- 1259
	end -- 1259
	if shelfGlint then -- 1259
		local p = 0.72 + 0.28 * math.sin(self.animTime * 3) -- 1262
		fillRadialGlow( -- 1263
			fgGlow, -- 1263
			cx, -- 1263
			cy + 2, -- 1263
			14 * p, -- 1263
			14 * p, -- 1263
			Color( -- 1263
				224, -- 1263
				214, -- 1263
				190, -- 1263
				math.floor(62 * p + 0.5) -- 1263
			), -- 1263
			Color(224, 214, 190, 0), -- 1263
			12 -- 1263
		) -- 1263
	end -- 1263
end -- 1243
function VillageUndertableScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1268
	local p = ctx.p -- 1274
	local cam = ctx.cam -- 1275
	if p.room.scavenger ~= nil then -- 1275
		self:drawScavengerShoeOverlay(fgDraw, fgGlow, p, cam) -- 1277
	end -- 1277
	if ctx.paused then -- 1277
		local arch = p.room.arch -- 1282
		local pTopBL = projectWorld3D( -- 1283
			arch.x0 - 8, -- 1283
			arch.h, -- 1283
			-15, -- 1283
			cam, -- 1283
			self.proj -- 1283
		) -- 1283
		local pTopTR = projectWorld3D( -- 1284
			arch.x1 + 8, -- 1284
			arch.h + 8, -- 1284
			-15, -- 1284
			cam, -- 1284
			self.proj -- 1284
		) -- 1284
		worldArt:tryPlace( -- 1285
			"cover_wood", -- 1286
			"fe04_pause_table_top", -- 1287
			(pTopBL.x + pTopTR.x) * 0.5, -- 1288
			pTopBL.y, -- 1289
			math.max( -- 1290
				20, -- 1290
				math.abs(pTopTR.x - pTopBL.x) -- 1290
			), -- 1290
			math.max( -- 1291
				8, -- 1291
				math.abs(pTopTR.y - pTopBL.y) -- 1291
			), -- 1291
			{ -- 1292
				color = Color(46, 35, 27, 255), -- 1292
				opacity = 0.96, -- 1292
				layer = 5300 -- 1292
			} -- 1292
		) -- 1292
		local legBL = projectWorld3D( -- 1294
			arch.x1 - 6, -- 1294
			0, -- 1294
			-15, -- 1294
			cam, -- 1294
			self.proj -- 1294
		) -- 1294
		local legTR = projectWorld3D( -- 1295
			arch.x1 + 1, -- 1295
			arch.h, -- 1295
			-15, -- 1295
			cam, -- 1295
			self.proj -- 1295
		) -- 1295
		worldArt:tryPlace( -- 1296
			"cover_wood", -- 1297
			"fe04_pause_table_leg", -- 1298
			(legBL.x + legTR.x) * 0.5, -- 1299
			legBL.y, -- 1300
			math.max( -- 1301
				6, -- 1301
				math.abs(legTR.x - legBL.x) -- 1301
			), -- 1301
			math.max( -- 1302
				16, -- 1302
				math.abs(legTR.y - legBL.y) -- 1302
			), -- 1302
			{ -- 1303
				color = Color(34, 25, 19, 255), -- 1303
				opacity = 0.96, -- 1303
				layer = 5310 -- 1303
			} -- 1303
		) -- 1303
	end -- 1303
end -- 1268
function VillageUndertableScene.prototype.drawScavengerShoeOverlay(self, fgDraw, fgGlow, p, cam) -- 1308
	local cx = cam:sx(p.scavX) -- 1314
	local by = cam:sy(p.room.scavenger ~= nil and p.room.scavenger.y or 0) -- 1315
	local f = self.shoeFacing >= 0 and 1 or -1 -- 1316
	local moving = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 1317
	local stride = moving and math.sin(self.scavStridePhase) * cam:len(7.2) or 0 -- 1318
	local pausedToe = self.shoeToePauseTimer > 0 -- 1319
	fillRadialGlow( -- 1322
		fgGlow, -- 1322
		cx + f * cam:len(4), -- 1322
		by + 2, -- 1322
		cam:len(32), -- 1322
		cam:len(8), -- 1322
		Color(196, 208, 220, 48), -- 1322
		Color(156, 172, 190, 0), -- 1322
		14 -- 1322
	) -- 1322
	fgDraw:drawEllipse( -- 1323
		Vec2( -- 1323
			cx + f * cam:len(2), -- 1323
			by + 1 -- 1323
		), -- 1323
		cam:len(19), -- 1323
		cam:len(3.4), -- 1323
		Color(92, 102, 114, 72) -- 1323
	) -- 1323
	local function drawSingleShoe(footX, liftY, isFront) -- 1326
		local heelX = footX - f * cam:len(4.8) -- 1327
		local midX = footX + f * cam:len(1.8) -- 1328
		local toeX = footX + f * cam:len(7.6) -- 1329
		local soleY = by + 0.8 + liftY -- 1330
		local shoeH = cam:len(4.4) -- 1331
		fgDraw:drawPolygon( -- 1333
			{ -- 1333
				Vec2(heelX, soleY), -- 1334
				Vec2(toeX, soleY), -- 1335
				Vec2( -- 1336
					toeX - f * cam:len(1), -- 1336
					soleY + shoeH * 0.56 -- 1336
				), -- 1336
				Vec2(midX, soleY + shoeH * 0.96), -- 1337
				Vec2( -- 1338
					heelX + f * cam:len(0.6), -- 1338
					soleY + shoeH * 0.86 -- 1338
				) -- 1338
			}, -- 1338
			isFront and Color(68, 58, 48, 250) or Color(46, 40, 34, 240) -- 1339
		) -- 1339
		local soleCol = isFront and Color(198, 192, 178, 232) or Color(148, 144, 134, 195) -- 1341
		fgDraw:drawSegment( -- 1342
			Vec2(heelX, soleY + 0.6), -- 1342
			Vec2(toeX, soleY + 0.6), -- 1342
			1.5, -- 1342
			soleCol -- 1342
		) -- 1342
		fgDraw:drawSegment( -- 1344
			Vec2( -- 1344
				toeX - f * cam:len(1.2), -- 1344
				soleY + 0.8 -- 1344
			), -- 1344
			Vec2( -- 1344
				toeX - f * cam:len(1.4), -- 1344
				soleY + shoeH * 0.56 -- 1344
			), -- 1344
			1.3, -- 1344
			Color(214, 210, 198, isFront and 220 or 165) -- 1344
		) -- 1344
		if isFront and pausedToe then -- 1344
			fgGlow:drawDot( -- 1347
				Vec2(toeX, soleY + 1.5), -- 1347
				3, -- 1347
				Color(236, 218, 178, 155) -- 1347
			) -- 1347
		end -- 1347
	end -- 1326
	local backLift = moving and math.max( -- 1351
		0, -- 1351
		-math.sin(self.scavStridePhase) -- 1351
	) * cam:len(2.4) or 0 -- 1351
	local frontLift = moving and math.max( -- 1352
		0, -- 1352
		math.sin(self.scavStridePhase) -- 1352
	) * cam:len(2.8) or 0 -- 1352
	drawSingleShoe( -- 1353
		cx - stride - f * cam:len(3.5), -- 1353
		backLift, -- 1353
		false -- 1353
	) -- 1353
	drawSingleShoe( -- 1354
		cx + stride + f * cam:len(4), -- 1354
		frontLift, -- 1354
		true -- 1354
	) -- 1354
end -- 1308
function VillageUndertableScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 1364
	local p = ctx.p -- 1371
	local cam = ctx.cam -- 1372
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1373
	local arch = p.room.arch -- 1374
	local xLeft = arch.x0 - 8 -- 1376
	local xRight = arch.x1 + 8 -- 1377
	local tableBotY = arch.h -- 1378
	local tableTopY = arch.h + 8 -- 1379
	local zFront = -15 -- 1380
	local zMid = 4 -- 1381
	local function drawFrontLeg(lx0, lx1) -- 1384
		local mBL = projectWorld3D( -- 1385
			lx0, -- 1385
			0, -- 1385
			zFront, -- 1385
			cam, -- 1385
			self.proj -- 1385
		) -- 1385
		local mBR = projectWorld3D( -- 1386
			lx1, -- 1386
			0, -- 1386
			zFront, -- 1386
			cam, -- 1386
			self.proj -- 1386
		) -- 1386
		local mTR = projectWorld3D( -- 1387
			lx1, -- 1387
			tableBotY, -- 1387
			zFront, -- 1387
			cam, -- 1387
			self.proj -- 1387
		) -- 1387
		local mTL = projectWorld3D( -- 1388
			lx0, -- 1388
			tableBotY, -- 1388
			zFront, -- 1388
			cam, -- 1388
			self.proj -- 1388
		) -- 1388
		drawUiQuad( -- 1389
			uiDraw, -- 1389
			mBL, -- 1389
			mBR, -- 1389
			mTR, -- 1389
			mTL, -- 1389
			Color(26, 20, 15, 250), -- 1389
			Color(38, 29, 22, 252), -- 1389
			inv, -- 1389
			Color(88, 70, 54, 145), -- 1389
			0.9 -- 1389
		) -- 1389
		local sBR = projectWorld3D( -- 1391
			lx1, -- 1391
			0, -- 1391
			zFront + 7, -- 1391
			cam, -- 1391
			self.proj -- 1391
		) -- 1391
		local sTR = projectWorld3D( -- 1392
			lx1, -- 1392
			tableBotY, -- 1392
			zFront + 7, -- 1392
			cam, -- 1392
			self.proj -- 1392
		) -- 1392
		drawUiQuad( -- 1393
			uiDraw, -- 1393
			mBR, -- 1393
			sBR, -- 1393
			sTR, -- 1393
			mTR, -- 1393
			Color(44, 34, 26, 248), -- 1393
			Color(66, 52, 40, 250), -- 1393
			inv, -- 1393
			Color(138, 120, 102, 155), -- 1393
			0.8 -- 1393
		) -- 1393
	end -- 1384
	drawFrontLeg(arch.x0 - 1, arch.x0 + 6) -- 1395
	drawFrontLeg(arch.x1 - 6, arch.x1 + 1) -- 1396
	local bFarL = projectWorld3D( -- 1399
		xLeft, -- 1399
		tableBotY, -- 1399
		zMid, -- 1399
		cam, -- 1399
		self.proj -- 1399
	) -- 1399
	local bFarR = projectWorld3D( -- 1400
		xRight, -- 1400
		tableBotY, -- 1400
		zMid, -- 1400
		cam, -- 1400
		self.proj -- 1400
	) -- 1400
	local bNearR = projectWorld3D( -- 1401
		xRight, -- 1401
		tableBotY, -- 1401
		zFront, -- 1401
		cam, -- 1401
		self.proj -- 1401
	) -- 1401
	local bNearL = projectWorld3D( -- 1402
		xLeft, -- 1402
		tableBotY, -- 1402
		zFront, -- 1402
		cam, -- 1402
		self.proj -- 1402
	) -- 1402
	drawUiQuad( -- 1403
		uiDraw, -- 1403
		bFarL, -- 1403
		bFarR, -- 1403
		bNearR, -- 1403
		bNearL, -- 1403
		Color(18, 14, 11, 236), -- 1403
		Color(28, 21, 16, 242), -- 1403
		inv, -- 1403
		Color(76, 58, 44, 115), -- 1403
		0.8 -- 1403
	) -- 1403
	local fTopR = projectWorld3D( -- 1406
		xRight, -- 1406
		tableTopY, -- 1406
		zFront, -- 1406
		cam, -- 1406
		self.proj -- 1406
	) -- 1406
	local fTopL = projectWorld3D( -- 1407
		xLeft, -- 1407
		tableTopY, -- 1407
		zFront, -- 1407
		cam, -- 1407
		self.proj -- 1407
	) -- 1407
	drawUiQuad( -- 1408
		uiDraw, -- 1408
		bNearL, -- 1408
		bNearR, -- 1408
		fTopR, -- 1408
		fTopL, -- 1408
		Color(38, 28, 21, 252), -- 1408
		Color(56, 42, 32, 254), -- 1408
		inv, -- 1408
		Color(124, 98, 76, 155), -- 1408
		1 -- 1408
	) -- 1408
	uiDraw:drawSegment( -- 1410
		Vec2(bNearL.x * inv, bNearL.y * inv), -- 1410
		Vec2(bNearR.x * inv, bNearR.y * inv), -- 1410
		1.2, -- 1410
		Color(142, 122, 100, 175) -- 1410
	) -- 1410
	local topBackL = projectWorld3D( -- 1413
		xLeft, -- 1413
		tableTopY, -- 1413
		zMid, -- 1413
		cam, -- 1413
		self.proj -- 1413
	) -- 1413
	local topBackR = projectWorld3D( -- 1414
		xRight, -- 1414
		tableTopY, -- 1414
		zMid, -- 1414
		cam, -- 1414
		self.proj -- 1414
	) -- 1414
	drawUiQuad( -- 1415
		uiDraw, -- 1415
		fTopL, -- 1415
		fTopR, -- 1415
		topBackR, -- 1415
		topBackL, -- 1415
		Color(52, 40, 30, 244), -- 1415
		Color(32, 24, 19, 236), -- 1415
		inv, -- 1415
		Color(132, 110, 88, 130), -- 1415
		0.8 -- 1415
	) -- 1415
	local bowlBL = projectWorld3D( -- 1418
		arch.x0 + 24, -- 1418
		tableTopY + 0.5, -- 1418
		-5, -- 1418
		cam, -- 1418
		self.proj -- 1418
	) -- 1418
	local bowlBR = projectWorld3D( -- 1419
		arch.x0 + 38, -- 1419
		tableTopY + 0.5, -- 1419
		-5, -- 1419
		cam, -- 1419
		self.proj -- 1419
	) -- 1419
	local bowlTR = projectWorld3D( -- 1420
		arch.x0 + 40, -- 1420
		tableTopY + 6.5, -- 1420
		-5, -- 1420
		cam, -- 1420
		self.proj -- 1420
	) -- 1420
	local bowlTL = projectWorld3D( -- 1421
		arch.x0 + 22, -- 1421
		tableTopY + 6.5, -- 1421
		-5, -- 1421
		cam, -- 1421
		self.proj -- 1421
	) -- 1421
	drawUiQuad( -- 1422
		uiDraw, -- 1422
		bowlBL, -- 1422
		bowlBR, -- 1422
		bowlTR, -- 1422
		bowlTL, -- 1422
		Color(72, 68, 62, 244), -- 1422
		Color(118, 114, 106, 246), -- 1422
		inv, -- 1422
		Color(172, 166, 156, 175), -- 1422
		0.8 -- 1422
	) -- 1422
	local clothL = projectWorld3D( -- 1425
		xLeft + 2, -- 1425
		tableBotY - 7, -- 1425
		zFront, -- 1425
		cam, -- 1425
		self.proj -- 1425
	) -- 1425
	local clothR = projectWorld3D( -- 1426
		xLeft + 26, -- 1426
		tableBotY - 1, -- 1426
		zFront, -- 1426
		cam, -- 1426
		self.proj -- 1426
	) -- 1426
	uiDraw:drawVertices({ -- 1427
		{ -- 1428
			Vec2(bNearL.x * inv, bNearL.y * inv), -- 1428
			Color(28, 22, 19, 224) -- 1428
		}, -- 1428
		{ -- 1429
			Vec2(clothL.x * inv, clothL.y * inv), -- 1429
			Color(36, 29, 25, 212) -- 1429
		}, -- 1429
		{ -- 1430
			Vec2(clothR.x * inv, clothR.y * inv), -- 1430
			Color(26, 21, 18, 198) -- 1430
		} -- 1430
	}) -- 1430
	return false -- 1434
end -- 1364
return ____exports -- 1364