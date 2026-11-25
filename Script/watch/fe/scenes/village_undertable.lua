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
		p.ox + 344, -- 420
		math.min(p.ox + 408, p.ox + 362 + (p.player.x - (p.ox + 320)) * 0.14) -- 420
	) -- 420
	local zoom = 0.9 + (1 - self.underTableFocus) * 0.04 -- 421
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
		if explicitSurface ~= "iron" then -- 481
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
		end -- 493
	elseif surface == "brick" then -- 493
		self.brickHits = self.brickHits + 1 -- 497
		self.shoeToePauseTimer = 0.14 -- 499
		local ____self_rings_3 = self.rings -- 499
		____self_rings_3[#____self_rings_3 + 1] = { -- 500
			x = x, -- 500
			y = math.max(2, y), -- 500
			age = 0, -- 500
			duration = 0.44, -- 500
			maxRadius = 58, -- 500
			kind = "brick" -- 500
		} -- 500
		self:spawnShards( -- 501
			x, -- 501
			math.max(2, y), -- 501
			"brick", -- 501
			9 -- 501
		) -- 501
	else -- 501
		self.softHits = self.softHits + 1 -- 503
		local ____self_rings_4 = self.rings -- 503
		____self_rings_4[#____self_rings_4 + 1] = { -- 504
			x = x, -- 504
			y = math.max(2, y), -- 504
			age = 0, -- 504
			duration = 0.36, -- 504
			maxRadius = 24, -- 504
			kind = "soft" -- 504
		} -- 504
		self:spawnShards( -- 505
			x, -- 505
			math.max(2, y), -- 505
			"soft", -- 505
			6 -- 505
		) -- 505
		if explicitSurface ~= "soft" then -- 505
			local key = (((("fe04:village:soft_thud:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(ev.tick)) .. ":") .. tostring(ev.seq) -- 507
			ctx.audio:playOnce( -- 508
				key, -- 509
				"sfx", -- 510
				CHILD_AUDIO_ROOT .. "bottle_soft.wav", -- 511
				0.76, -- 512
				"fe04:bottle:soft_thud", -- 513
				ev.tick, -- 514
				ev.seq -- 515
			) -- 515
		end -- 515
	end -- 515
end -- 461
function VillageUndertableScene.prototype.spawnShards(self, x, y, kind, count) -- 521
	local i = 0 -- 522
	do -- 522
		i = 0 -- 523
		while i < count do -- 523
			local ang = (0.18 + self:rand() * 0.64) * math.pi -- 524
			local spd = (kind == "soft" and 28 or 65) + self:rand() * (kind == "soft" and 36 or 95) -- 525
			local ____self_shards_5 = self.shards -- 525
			____self_shards_5[#____self_shards_5 + 1] = { -- 526
				x = x + (self:rand() - 0.5) * 10, -- 527
				y = y + 2, -- 528
				vx = math.cos(ang) * spd * (self:rand() > 0.5 and 1 or -1), -- 529
				vy = math.sin(ang) * spd, -- 530
				size = kind == "soft" and 2.2 + self:rand() * 2.4 or 1.8 + self:rand() * 2.2, -- 531
				life = (kind == "soft" and 0.34 or 0.48) + self:rand() * 0.22, -- 532
				maxLife = 0.65, -- 533
				kind = kind -- 534
			} -- 534
			i = i + 1 -- 523
		end -- 523
	end -- 523
end -- 521
function VillageUndertableScene.prototype.triggerRehearsalImpact(self, ctx, surface) -- 540
	local p = ctx.p -- 541
	local x = surface == "iron" and self:getBasinWorldX(p) or (surface == "soft" and self:getSoftWorldX(p) or self:getBrickWorldX(p)) -- 542
	self:onBottleLanded(ctx, {seq = 9000 + self.brickHits + self.ironHits + self.softHits, tick = p.ticks, name = "bottleLanded", data = {x = x, y = 0, surface = surface, heard = true}}) -- 545
end -- 540
function VillageUndertableScene.prototype.drawBackdrop(self, bgDraw, bgGlow, _backdropArt, ctx) -- 553
	local p = ctx.p -- 559
	local cam = ctx.cam -- 560
	local w = cam.viewW -- 561
	local h = cam.viewH -- 562
	local splitY = h * 0.5 -- 565
	fillVGradRect( -- 566
		bgDraw, -- 566
		0, -- 566
		splitY, -- 566
		w, -- 566
		h - splitY, -- 566
		Color(14, 18, 26, 255), -- 566
		Color(7, 9, 15, 255) -- 566
	) -- 566
	fillVGradRect( -- 567
		bgDraw, -- 567
		0, -- 567
		0, -- 567
		w, -- 567
		splitY, -- 567
		Color(24, 28, 38, 255), -- 567
		Color(14, 18, 26, 255) -- 567
	) -- 567
	local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 569
	local ox = p.ox -- 570
	scene:addDistantRidge( -- 573
		{ -- 574
			{x = ox - 140, y = 120}, -- 575
			{x = ox + 120, y = 162}, -- 576
			{x = ox + 360, y = 138}, -- 577
			{x = ox + 590, y = 176}, -- 578
			{x = ox + 860, y = 132} -- 579
		}, -- 579
		-20, -- 579
		420, -- 582
		MING_MATERIALS.distantHill, -- 583
		{bucket = LP_BUCKET.BACKDROP} -- 584
	) -- 584
	scene:addBox({ -- 588
		x0 = ox + 460, -- 589
		x1 = ox + 690, -- 590
		y0 = 0, -- 591
		y1 = 118, -- 592
		z0 = 210, -- 593
		z1 = 260, -- 594
		material = MING_MATERIALS.distantWall, -- 595
		bucket = LP_BUCKET.BACKDROP, -- 596
		edgeWidth = 0 -- 597
	}) -- 597
	scene:addTri3D( -- 599
		vec3(ox + 446, 118, 206), -- 600
		vec3(ox + 704, 118, 206), -- 601
		vec3(ox + 575, 162, 232), -- 602
		MING_MATERIALS.mingTile, -- 603
		{bucket = LP_BUCKET.BACKDROP, sortBias = 0.04} -- 604
	) -- 604
	scene:addBox({ -- 608
		x0 = ox - 60, -- 609
		x1 = ox + 436, -- 610
		y0 = 0, -- 611
		y1 = 196, -- 612
		z0 = 112, -- 613
		z1 = 152, -- 614
		material = MING_MATERIALS.mingBrickDark, -- 615
		bucket = LP_BUCKET.BACKDROP, -- 616
		edgeWidth = 0.6 -- 617
	}) -- 617
	scene:addBox({ -- 621
		x0 = ox + 150, -- 622
		x1 = ox + 258, -- 623
		y0 = 0, -- 624
		y1 = 42, -- 625
		z0 = 76, -- 626
		z1 = 112, -- 627
		material = MAT_CLAY_STOVE, -- 628
		bucket = LP_BUCKET.MIDGROUND, -- 629
		highlightTopEdge = true -- 630
	}) -- 630
	scene:addBox({ -- 632
		x0 = ox + 178, -- 633
		x1 = ox + 228, -- 634
		y0 = 42, -- 635
		y1 = 156, -- 636
		z0 = 94, -- 637
		z1 = 114, -- 638
		material = MAT_CLAY_STOVE, -- 639
		bucket = LP_BUCKET.MIDGROUND, -- 640
		edgeWidth = 0.5 -- 641
	}) -- 641
	scene:addBox({ -- 645
		x0 = ox + 486, -- 646
		x1 = ox + 536, -- 647
		y0 = 0, -- 648
		y1 = 34, -- 649
		z0 = 126, -- 650
		z1 = 162, -- 651
		material = MING_MATERIALS.mingStoneStep, -- 652
		bucket = LP_BUCKET.MIDGROUND, -- 653
		highlightTopEdge = true -- 654
	}) -- 654
	scene:addFogBand( -- 658
		ox - 120, -- 658
		ox + 840, -- 658
		-10, -- 658
		140, -- 658
		260, -- 658
		rgba(24, 30, 42, 255), -- 658
		0.62, -- 658
		0.05, -- 658
		{bucket = LP_BUCKET.BACKDROP} -- 658
	) -- 658
	scene:flush(bgDraw, bgGlow) -- 662
	local mx = w * 0.8 -- 665
	local my = h * 0.84 -- 666
	fillRadialGlow( -- 667
		bgGlow, -- 667
		mx, -- 667
		my, -- 667
		96, -- 667
		96, -- 667
		Color(188, 206, 224, 24), -- 667
		Color(24, 32, 46, 0), -- 667
		16 -- 667
	) -- 667
	bgDraw:drawCircle( -- 668
		Vec2(mx, my), -- 668
		14, -- 668
		Color(214, 224, 236, 130) -- 668
	) -- 668
	local towerPt = projectWorld3D( -- 671
		ox + 668, -- 671
		152, -- 671
		410, -- 671
		cam, -- 671
		self.proj -- 671
	) -- 671
	fillRadialGlow( -- 672
		bgGlow, -- 672
		towerPt.x, -- 672
		towerPt.y, -- 672
		20, -- 672
		20, -- 672
		Color(238, 198, 132, 54), -- 672
		Color(238, 198, 132, 0), -- 672
		12 -- 672
	) -- 672
	bgGlow:drawDot( -- 673
		Vec2(towerPt.x, towerPt.y), -- 673
		2, -- 673
		Color(252, 232, 186, 185) -- 673
	) -- 673
	return true -- 675
end -- 553
function VillageUndertableScene.prototype.drawWorld(self, fgDraw, fgGlow, _worldArt, ctx) -- 678
	local p = ctx.p -- 684
	local cam = ctx.cam -- 685
	local ox = p.ox -- 686
	local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 687
	scene:addBox({ -- 690
		x0 = ox - 40, -- 691
		x1 = ox + 436, -- 692
		y0 = -52, -- 693
		y1 = 0, -- 694
		z0 = -32, -- 695
		z1 = 112, -- 696
		material = MING_MATERIALS.mingTimberDark, -- 697
		bucket = LP_BUCKET.MIDGROUND, -- 698
		highlightTopEdge = true, -- 699
		edgeWidth = 0.7 -- 700
	}) -- 700
	scene:addBox({ -- 702
		x0 = ox + 436, -- 703
		x1 = ox + 760, -- 704
		y0 = -52, -- 705
		y1 = 0, -- 706
		z0 = -32, -- 707
		z1 = 126, -- 708
		material = MING_MATERIALS.mingBrickDark, -- 709
		bucket = LP_BUCKET.MIDGROUND, -- 710
		highlightTopEdge = true, -- 711
		edgeWidth = 0.8 -- 712
	}) -- 712
	scene:addBeveledFrame( -- 716
		ox + 416, -- 716
		ox + 462, -- 716
		0, -- 716
		128, -- 716
		16, -- 716
		22, -- 716
		16, -- 716
		112, -- 716
		MING_MATERIALS.mingTimberDark, -- 716
		{ -- 716
			bucket = LP_BUCKET.MIDGROUND, -- 717
			innerRimLight = rgba(206, 214, 222, 255), -- 718
			innerRimStrength = 0.42 -- 719
		} -- 719
	) -- 719
	scene:addBox({ -- 723
		x0 = ox + 96, -- 724
		x1 = ox + 128, -- 725
		y0 = 0, -- 726
		y1 = 64, -- 727
		z0 = -8, -- 728
		z1 = 36, -- 729
		material = MAT_TABLE_WOOD, -- 730
		bucket = LP_BUCKET.WALK_DECK, -- 731
		highlightTopEdge = true, -- 732
		edgeWidth = 0.9 -- 733
	}) -- 733
	scene:addBox({ -- 736
		x0 = ox + 94, -- 737
		x1 = ox + 130, -- 738
		y0 = 32, -- 739
		y1 = 36, -- 740
		z0 = -10, -- 741
		z1 = 34, -- 742
		material = MING_MATERIALS.mingTimber, -- 743
		bucket = LP_BUCKET.WALK_DECK, -- 744
		sortBias = 0.05 -- 745
	}) -- 745
	scene:addBox({ -- 748
		x0 = ox + 672, -- 749
		x1 = ox + 720, -- 750
		y0 = 0, -- 751
		y1 = 96, -- 752
		z0 = -14, -- 753
		z1 = 96, -- 754
		material = MING_MATERIALS.mingBrick, -- 755
		bucket = LP_BUCKET.MIDGROUND, -- 756
		highlightTopEdge = true, -- 757
		edgeWidth = 0.9 -- 758
	}) -- 758
	scene:addBox({ -- 760
		x0 = ox + 666, -- 761
		x1 = ox + 726, -- 762
		y0 = 96, -- 763
		y1 = 106, -- 764
		z0 = -18, -- 765
		z1 = 100, -- 766
		material = MING_MATERIALS.mingTile, -- 767
		bucket = LP_BUCKET.MIDGROUND, -- 768
		sortBias = 0.08 -- 769
	}) -- 769
	local arch = p.room.arch -- 773
	scene:addBox({ -- 775
		x0 = arch.x0 - 2, -- 776
		x1 = arch.x0 + 10, -- 777
		y0 = 0, -- 778
		y1 = arch.h, -- 779
		z0 = 14, -- 780
		z1 = 28, -- 781
		material = MAT_TABLE_WOOD, -- 782
		bucket = LP_BUCKET.MIDGROUND, -- 783
		edgeWidth = 0.8 -- 784
	}) -- 784
	scene:addBox({ -- 786
		x0 = arch.x1 - 10, -- 787
		x1 = arch.x1 + 2, -- 788
		y0 = 0, -- 789
		y1 = arch.h, -- 790
		z0 = 14, -- 791
		z1 = 28, -- 792
		material = MAT_TABLE_WOOD, -- 793
		bucket = LP_BUCKET.MIDGROUND, -- 794
		edgeWidth = 0.8 -- 795
	}) -- 795
	scene:addBox({ -- 798
		x0 = arch.x0 - 12, -- 799
		x1 = arch.x1 + 12, -- 800
		y0 = arch.h, -- 801
		y1 = arch.h + 11, -- 802
		z0 = -16, -- 803
		z1 = 36, -- 804
		material = MAT_TABLE_WOOD, -- 805
		bucket = LP_BUCKET.WALK_DECK, -- 806
		highlightTopEdge = true, -- 807
		edgeWidth = 0.9 -- 808
	}) -- 808
	scene:addBox({ -- 811
		x0 = arch.x0 + 28, -- 812
		x1 = arch.x0 + 44, -- 813
		y0 = arch.h + 11, -- 814
		y1 = arch.h + 18, -- 815
		z0 = 4, -- 816
		z1 = 18, -- 817
		material = MING_MATERIALS.mingStoneStep, -- 818
		bucket = LP_BUCKET.PROP, -- 819
		highlightTopEdge = true -- 820
	}) -- 820
	local culvertX = self:getCulvertWorldX(p) -- 824
	self:buildCulvertEntrance(scene, culvertX) -- 825
	local softX = self:getSoftWorldX(p) -- 829
	self:buildSoftDirtPatch(scene, softX) -- 830
	local brickX = self:getBrickWorldX(p) -- 833
	self:buildHardBrickPatch(scene, brickX) -- 834
	local basinX = self:getBasinWorldX(p) -- 837
	self:buildIronBasin(scene, basinX) -- 838
	scene:addLightShaft( -- 841
		ox + 570, -- 842
		ox + 710, -- 842
		290, -- 842
		ox + 446, -- 843
		ox + 642, -- 843
		0, -- 843
		24, -- 844
		rgba(218, 226, 218, 255), -- 845
		0.13, -- 846
		0.04 -- 847
	) -- 847
	scene:addContactShadow( -- 851
		p.player.x, -- 851
		p.player.y, -- 851
		14, -- 851
		10, -- 851
		0.8, -- 851
		{bucket = LP_BUCKET.PROP, sortBias = 0.4} -- 851
	) -- 851
	if p.room.scavenger ~= nil then -- 851
		scene:addContactShadow( -- 853
			p.scavX, -- 853
			p.room.scavenger.y, -- 853
			19, -- 853
			13, -- 853
			0.84, -- 853
			{bucket = LP_BUCKET.PROP, sortBias = 0.42} -- 853
		) -- 853
	end -- 853
	scene:flush(fgDraw, fgGlow) -- 856
	self:drawSurfaceReadabilityDetails( -- 859
		fgDraw, -- 859
		fgGlow, -- 859
		p, -- 859
		cam, -- 859
		softX, -- 859
		culvertX, -- 859
		basinX, -- 859
		brickX -- 859
	) -- 859
	return true -- 861
end -- 678
function VillageUndertableScene.prototype.buildCulvertEntrance(self, scene, cx) -- 864
	scene:addBox({ -- 866
		x0 = cx - 18, -- 867
		x1 = cx + 18, -- 868
		y0 = -12, -- 869
		y1 = 2, -- 870
		z0 = -6, -- 871
		z1 = 42, -- 872
		material = MAT_CULVERT_STONE, -- 873
		bucket = LP_BUCKET.WALK_DECK, -- 874
		highlightTopEdge = true, -- 875
		edgeWidth = 1 -- 876
	}) -- 876
	scene:addQuad3D( -- 879
		vec3(cx - 12, 1, 22), -- 880
		vec3(cx + 12, 1, 22), -- 881
		vec3(cx + 10, 26, 22), -- 882
		vec3(cx - 10, 26, 22), -- 883
		{base = rgba(6, 9, 14, 255)}, -- 884
		{ -- 885
			bucket = LP_BUCKET.MIDGROUND, -- 885
			unlit = true, -- 885
			sortBias = 0.35, -- 885
			edgeColor = rgba(186, 204, 222, 185), -- 885
			edgeWidth = 1.2 -- 885
		} -- 885
	) -- 885
	scene:addBox({ -- 888
		x0 = cx - 15, -- 889
		x1 = cx - 11, -- 890
		y0 = 2, -- 891
		y1 = 24, -- 892
		z0 = 14, -- 893
		z1 = 22, -- 894
		material = MING_MATERIALS.mingTimber, -- 895
		bucket = LP_BUCKET.PROP, -- 896
		highlightTopEdge = true -- 897
	}) -- 897
	local gi = 0 -- 899
	do -- 899
		gi = 0 -- 900
		while gi < 3 do -- 900
			local gx = cx - 6 + gi * 6 -- 901
			scene:addBox({ -- 902
				x0 = gx - 1, -- 903
				x1 = gx + 1, -- 904
				y0 = 2, -- 905
				y1 = 24, -- 906
				z0 = 18, -- 907
				z1 = 21, -- 908
				material = MING_MATERIALS.mingIron, -- 909
				bucket = LP_BUCKET.PROP, -- 910
				sortBias = 0.1 -- 911
			}) -- 911
			gi = gi + 1 -- 900
		end -- 900
	end -- 900
end -- 864
function VillageUndertableScene.prototype.buildSoftDirtPatch(self, scene, softX) -- 916
	scene:addBox({ -- 917
		x0 = softX - 24, -- 918
		x1 = softX + 24, -- 919
		y0 = -4, -- 920
		y1 = 1.5, -- 921
		z0 = -16, -- 922
		z1 = 28, -- 923
		material = MAT_SOFT_EARTH, -- 924
		bucket = LP_BUCKET.WALK_DECK, -- 925
		sortBias = 0.15, -- 926
		edgeWidth = 0.4 -- 927
	}) -- 927
end -- 916
function VillageUndertableScene.prototype.buildHardBrickPatch(self, scene, brickX) -- 931
	local col = 0 -- 933
	do -- 933
		col = 0 -- 934
		while col < 3 do -- 934
			local bx0 = brickX - 24 + col * 16 -- 935
			local bx1 = bx0 + 14.5 -- 936
			scene:addBox({ -- 937
				x0 = bx0, -- 938
				x1 = bx1, -- 939
				y0 = -4, -- 940
				y1 = 3.2, -- 941
				z0 = -14, -- 942
				z1 = 6, -- 943
				material = MAT_HARD_BRICK, -- 944
				bucket = LP_BUCKET.WALK_DECK, -- 945
				sortBias = 0.2 + col * 0.01, -- 946
				highlightTopEdge = true, -- 947
				edgeWidth = 1 -- 948
			}) -- 948
			scene:addBox({ -- 950
				x0 = bx0 + 4, -- 951
				x1 = bx1 + 4, -- 952
				y0 = -4, -- 953
				y1 = 2.8, -- 954
				z0 = 8, -- 955
				z1 = 26, -- 956
				material = MAT_HARD_BRICK, -- 957
				bucket = LP_BUCKET.WALK_DECK, -- 958
				sortBias = 0.18 + col * 0.01, -- 959
				highlightTopEdge = true, -- 960
				edgeWidth = 0.9 -- 961
			}) -- 961
			col = col + 1 -- 934
		end -- 934
	end -- 934
end -- 931
function VillageUndertableScene.prototype.buildIronBasin(self, scene, basinX) -- 966
	scene:addBox({ -- 968
		x0 = basinX - 14, -- 969
		x1 = basinX + 14, -- 970
		y0 = -2, -- 971
		y1 = 3, -- 972
		z0 = -10, -- 973
		z1 = 14, -- 974
		material = MING_MATERIALS.mingBrickDark, -- 975
		bucket = LP_BUCKET.PROP, -- 976
		sortBias = 0.02 -- 977
	}) -- 977
	local tilt = self.basinShakeAngle -- 980
	local liftL = math.sin(tilt) * 14 -- 981
	local liftR = -liftL -- 982
	local shiftX = math.sin(tilt * 1.4) * 2.5 -- 983
	local baseY = 3 -- 984
	local topY = 14.5 -- 985
	local bx = basinX + shiftX -- 986
	scene:addQuad3D( -- 989
		vec3( -- 990
			bx - 11, -- 990
			baseY + math.max(0, liftL * 0.4), -- 990
			-8 -- 990
		), -- 990
		vec3( -- 991
			bx + 11, -- 991
			baseY + math.max(0, liftR * 0.4), -- 991
			-8 -- 991
		), -- 991
		vec3(bx + 16, topY + liftR, -12), -- 992
		vec3(bx - 16, topY + liftL, -12), -- 993
		MAT_IRON_BASIN, -- 994
		{bucket = LP_BUCKET.PROP, sortBias = 0.25, edgeWidth = 1.2} -- 995
	) -- 995
	scene:addQuad3D( -- 998
		vec3( -- 999
			bx - 11, -- 999
			baseY + math.max(0, liftL * 0.4), -- 999
			10 -- 999
		), -- 999
		vec3( -- 1000
			bx - 11, -- 1000
			baseY + math.max(0, liftL * 0.4), -- 1000
			-8 -- 1000
		), -- 1000
		vec3(bx - 16, topY + liftL, -12), -- 1001
		vec3(bx - 16, topY + liftL, 14), -- 1002
		MAT_IRON_BASIN, -- 1003
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1004
	) -- 1004
	scene:addQuad3D( -- 1006
		vec3( -- 1007
			bx + 11, -- 1007
			baseY + math.max(0, liftR * 0.4), -- 1007
			-8 -- 1007
		), -- 1007
		vec3( -- 1008
			bx + 11, -- 1008
			baseY + math.max(0, liftR * 0.4), -- 1008
			10 -- 1008
		), -- 1008
		vec3(bx + 16, topY + liftR, 14), -- 1009
		vec3(bx + 16, topY + liftR, -12), -- 1010
		MAT_IRON_BASIN, -- 1011
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1012
	) -- 1012
	scene:addQuad3D( -- 1015
		vec3(bx - 14, topY - 1 + liftL, -10), -- 1016
		vec3(bx + 14, topY - 1 + liftR, -10), -- 1017
		vec3(bx + 14, topY - 1 + liftR, 12), -- 1018
		vec3(bx - 14, topY - 1 + liftL, 12), -- 1019
		{ -- 1020
			base = rgba(24, 30, 40, 255), -- 1020
			edge = rgba(232, 238, 246, 235) -- 1020
		}, -- 1020
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 1.5} -- 1021
	) -- 1021
end -- 966
function VillageUndertableScene.prototype.drawSurfaceReadabilityDetails(self, fgDraw, fgGlow, p, cam, softX, culvertX, basinX, brickX) -- 1025
	local y0 = cam:sy(0) -- 1035
	local sx0 = cam:sx(softX - 20) -- 1038
	local sx1 = cam:sx(softX + 20) -- 1039
	local d = 0 -- 1040
	do -- 1040
		d = 0 -- 1041
		while d < 9 do -- 1041
			local dx = sx0 + (sx1 - sx0) * (d + 0.5) / 9 -- 1042
			local dy = y0 - 2.5 + (d % 3 - 1) * 1.8 -- 1043
			fgDraw:drawDot( -- 1044
				Vec2(dx, dy), -- 1044
				1.3, -- 1044
				Color(116, 98, 78, 175) -- 1044
			) -- 1044
			d = d + 1 -- 1041
		end -- 1041
	end -- 1041
	fgDraw:drawEllipse( -- 1046
		Vec2( -- 1046
			cam:sx(softX - 7), -- 1046
			y0 - 1.5 -- 1046
		), -- 1046
		cam:len(4.2), -- 1046
		1.6, -- 1046
		Color(38, 30, 24, 185) -- 1046
	) -- 1046
	fgDraw:drawEllipse( -- 1047
		Vec2( -- 1047
			cam:sx(softX + 8), -- 1047
			y0 - 2 -- 1047
		), -- 1047
		cam:len(4.2), -- 1047
		1.6, -- 1047
		Color(38, 30, 24, 185) -- 1047
	) -- 1047
	local cL = cam:sx(culvertX - 11) -- 1050
	local cR = cam:sx(culvertX + 11) -- 1051
	local cTop = cam:sy(25) -- 1052
	fgDraw:drawSegment( -- 1053
		Vec2(cL, cTop), -- 1053
		Vec2(cR, cTop), -- 1053
		1.6, -- 1053
		Color(196, 210, 224, 210) -- 1053
	) -- 1053
	local rippleShift = math.sin(self.animTime * 2.3) * 3 -- 1054
	fgGlow:drawSegment( -- 1055
		Vec2(cL + 3 + rippleShift, y0 + 2), -- 1055
		Vec2(cR - 4 + rippleShift, y0 + 2), -- 1055
		1.1, -- 1055
		Color(164, 192, 214, 105) -- 1055
	) -- 1055
	local bPtL = projectWorld3D( -- 1058
		basinX - 16, -- 1058
		14.5 + math.sin(self.basinShakeAngle) * 14, -- 1058
		-12, -- 1058
		cam, -- 1058
		self.proj -- 1058
	) -- 1058
	local bPtR = projectWorld3D( -- 1059
		basinX + 16, -- 1059
		14.5 - math.sin(self.basinShakeAngle) * 14, -- 1059
		-12, -- 1059
		cam, -- 1059
		self.proj -- 1059
	) -- 1059
	local shakeBoost = self.basinShakeTimer > 0 and clamp01(self.basinShakeTimer / self.basinShakeMax) or 0 -- 1060
	local rimAlpha = math.floor(205 + 48 * shakeBoost + 0.5) -- 1061
	fgDraw:drawSegment( -- 1062
		Vec2(bPtL.x, bPtL.y), -- 1062
		Vec2(bPtR.x, bPtR.y), -- 1062
		2.1 + shakeBoost * 1.1, -- 1062
		Color(230, 236, 242, rimAlpha) -- 1062
	) -- 1062
	fillRadialGlow( -- 1063
		fgGlow, -- 1064
		(bPtL.x + bPtR.x) * 0.5, -- 1065
		(bPtL.y + bPtR.y) * 0.5, -- 1066
		cam:len(22 + shakeBoost * 18), -- 1067
		cam:len(10 + shakeBoost * 8), -- 1068
		Color( -- 1069
			216, -- 1069
			226, -- 1069
			236, -- 1069
			math.floor(48 + 95 * shakeBoost + 0.5) -- 1069
		), -- 1069
		Color(186, 202, 220, 0), -- 1070
		14 -- 1071
	) -- 1071
	local brL = cam:sx(brickX - 24) -- 1075
	local brR = cam:sx(brickX + 24) -- 1076
	local brTop = cam:sy(3.2) -- 1077
	fgDraw:drawSegment( -- 1078
		Vec2(brL, brTop), -- 1078
		Vec2(brR, brTop), -- 1078
		1.8, -- 1078
		Color(224, 228, 234, 225) -- 1078
	) -- 1078
	local k = 1 -- 1079
	do -- 1079
		k = 1 -- 1080
		while k <= 2 do -- 1080
			local seamX = brL + (brR - brL) * k / 3 -- 1081
			fgDraw:drawSegment( -- 1082
				Vec2(seamX, y0 - 3), -- 1082
				Vec2(seamX, brTop + 1), -- 1082
				1.5, -- 1082
				Color(20, 24, 32, 240) -- 1082
			) -- 1082
			fgDraw:drawSegment( -- 1083
				Vec2(seamX + 1.8, y0 - 2), -- 1083
				Vec2(seamX + 1.8, brTop), -- 1083
				0.9, -- 1083
				Color(214, 218, 224, 175) -- 1083
			) -- 1083
			k = k + 1 -- 1080
		end -- 1080
	end -- 1080
	local i = 0 -- 1087
	do -- 1087
		i = 0 -- 1088
		while i < #self.rings do -- 1088
			do -- 1088
				local rg = self.rings[i + 1] -- 1089
				if rg.age < 0 then -- 1089
					goto __continue76 -- 1091
				end -- 1091
				local t = clamp01(rg.age / rg.duration) -- 1093
				local r = math.max( -- 1094
					4, -- 1094
					cam:len(rg.maxRadius) * (0.14 + 0.86 * t) -- 1094
				) -- 1094
				local alpha = (1 - t) * (rg.kind == "iron" and 0.88 or (rg.kind == "brick" and 0.82 or 0.4)) -- 1095
				local rx = cam:sx(rg.x) -- 1096
				local ry = cam:sy(rg.y) -- 1097
				local ringCol = rg.kind == "iron" and Color( -- 1098
					220, -- 1099
					234, -- 1099
					246, -- 1099
					math.floor(235 * alpha + 0.5) -- 1099
				) or (rg.kind == "brick" and Color( -- 1099
					236, -- 1101
					216, -- 1101
					178, -- 1101
					math.floor(225 * alpha + 0.5) -- 1101
				) or Color( -- 1101
					148, -- 1102
					134, -- 1102
					114, -- 1102
					math.floor(165 * alpha + 0.5) -- 1102
				)) -- 1102
				drawEllipseRing( -- 1103
					fgGlow, -- 1103
					rx, -- 1103
					ry, -- 1103
					r, -- 1103
					r * 0.34, -- 1103
					rg.kind == "iron" and 1.8 or 1.4, -- 1103
					ringCol, -- 1103
					22 -- 1103
				) -- 1103
				if rg.kind == "iron" then -- 1103
					drawEllipseRing( -- 1105
						fgDraw, -- 1105
						rx, -- 1105
						ry, -- 1105
						r * 0.96, -- 1105
						r * 0.32, -- 1105
						1.1, -- 1105
						Color( -- 1105
							214, -- 1105
							224, -- 1105
							236, -- 1105
							math.floor(150 * alpha + 0.5) -- 1105
						), -- 1105
						22 -- 1105
					) -- 1105
				end -- 1105
			end -- 1105
			::__continue76:: -- 1105
			i = i + 1 -- 1088
		end -- 1088
	end -- 1088
	do -- 1088
		i = 0 -- 1108
		while i < #self.shards do -- 1108
			local sp = self.shards[i + 1] -- 1109
			local a = clamp01(sp.life / sp.maxLife) -- 1110
			local col = sp.kind == "soft" and Color( -- 1111
				138, -- 1112
				120, -- 1112
				98, -- 1112
				math.floor(170 * a + 0.5) -- 1112
			) or (sp.kind == "iron" and Color( -- 1112
				224, -- 1114
				232, -- 1114
				242, -- 1114
				math.floor(225 * a + 0.5) -- 1114
			) or Color( -- 1114
				216, -- 1115
				198, -- 1115
				174, -- 1115
				math.floor(220 * a + 0.5) -- 1115
			)) -- 1115
			fgDraw:drawDot( -- 1116
				Vec2( -- 1116
					cam:sx(sp.x), -- 1116
					cam:sy(sp.y) -- 1116
				), -- 1116
				sp.size, -- 1116
				col -- 1116
			) -- 1116
			i = i + 1 -- 1108
		end -- 1108
	end -- 1108
	if p.bottleLandT > 0 and p.bottleLandX >= 0 and #self.rings == 0 then -- 1108
		local rx = cam:sx(p.bottleLandX) -- 1121
		local ry = cam:sy(math.max(1, p.bottleLandY)) -- 1122
		fgDraw:drawDot( -- 1123
			Vec2(rx, ry), -- 1123
			2.5, -- 1123
			Color(216, 206, 186, 150) -- 1123
		) -- 1123
	end -- 1123
end -- 1025
function VillageUndertableScene.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1128
	local p = ctx.p -- 1134
	local cam = ctx.cam -- 1135
	local bottle = p.room.bottle -- 1138
	if bottle ~= nil and not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 1138
		self:drawCeramicBottle( -- 1140
			fgDraw, -- 1140
			fgGlow, -- 1140
			worldArt, -- 1140
			"fe04_bottle_shelf", -- 1140
			cam:sx(bottle.x), -- 1140
			cam:sy(67), -- 1140
			cam.ppu, -- 1140
			0, -- 1140
			true -- 1140
		) -- 1140
	end -- 1140
	if p.hasBottle then -- 1140
		local pl = p.player -- 1145
		self:drawCeramicBottle( -- 1146
			fgDraw, -- 1147
			fgGlow, -- 1148
			worldArt, -- 1149
			"fe04_bottle_held", -- 1150
			cam:sx(pl.x + pl.facing * 11), -- 1151
			cam:sy(pl.y + pl.h * 0.56), -- 1152
			cam.ppu, -- 1153
			pl.facing * 0.22, -- 1154
			false -- 1155
		) -- 1155
	end -- 1155
	if p.bottleFly ~= nil then -- 1155
		self:drawCeramicBottle( -- 1159
			fgDraw, -- 1160
			fgGlow, -- 1161
			worldArt, -- 1162
			"fe04_bottle_air", -- 1163
			cam:sx(p.bottleFly.x), -- 1164
			cam:sy(p.bottleFly.y), -- 1165
			cam.ppu, -- 1166
			self.animTime * 13.5, -- 1167
			false -- 1168
		) -- 1168
	end -- 1168
	if p.hasBottle and p.aimHold > 0 then -- 1168
		local pl = p.player -- 1174
		local endX = p.bottleAimX -- 1175
		local endY = p.bottleAimY -- 1176
		if endX < 0 then -- 1176
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 1178
			endX = wAim.x -- 1179
			endY = 0 -- 1180
		end -- 1180
		local dir = endX >= pl.x and 1 or -1 -- 1182
		local x0 = pl.x + dir * 10 -- 1183
		local y0 = pl.y + pl.h * 0.7 -- 1184
		local vx = (endX - x0) / BOTTLE_FLY_T -- 1185
		local vy = (endY - y0 + 0.5 * GRAVITY * BOTTLE_FLY_T * BOTTLE_FLY_T) / BOTTLE_FLY_T -- 1186
		local previewSurface = self:classifyLandingSurface(p, endX) -- 1188
		local arcRgb = previewSurface == "iron" and rgba(214, 228, 242, 255) or (previewSurface == "brick" and rgba(232, 206, 152, 255) or rgba(154, 142, 126, 255)) -- 1189
		local steps = 18 -- 1195
		local k = 1 -- 1196
		do -- 1196
			k = 1 -- 1197
			while k <= steps do -- 1197
				local tt = k / steps * BOTTLE_FLY_T -- 1198
				local wx = x0 + vx * tt -- 1199
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 1200
				local alpha = 195 * (0.4 + 0.6 * (k / steps)) -- 1201
				fgDraw:drawDot( -- 1202
					Vec2( -- 1202
						cam:sx(wx), -- 1202
						cam:sy(wy) -- 1202
					), -- 1202
					2.5, -- 1202
					toColor(arcRgb, alpha) -- 1202
				) -- 1202
				fgGlow:drawDot( -- 1203
					Vec2( -- 1203
						cam:sx(wx), -- 1203
						cam:sy(wy) -- 1203
					), -- 1203
					3.2, -- 1203
					toColor(arcRgb, alpha * 0.55) -- 1203
				) -- 1203
				k = k + 1 -- 1197
			end -- 1197
		end -- 1197
		local lx = cam:sx(endX) -- 1206
		local ly = cam:sy(endY + 2) -- 1207
		local pulse = 0.88 + 0.12 * math.sin(self.animTime * 5.2) -- 1208
		drawEllipseRing( -- 1209
			fgDraw, -- 1209
			lx, -- 1209
			ly, -- 1209
			11 * pulse, -- 1209
			4.2 * pulse, -- 1209
			1.6, -- 1209
			toColor(arcRgb, 235), -- 1209
			20 -- 1209
		) -- 1209
		if previewSurface == "iron" then -- 1209
			drawEllipseRing( -- 1211
				fgGlow, -- 1211
				lx, -- 1211
				ly, -- 1211
				24 * pulse, -- 1211
				9.2 * pulse, -- 1211
				1.3, -- 1211
				toColor(arcRgb, 195), -- 1211
				22 -- 1211
			) -- 1211
		elseif previewSurface == "brick" then -- 1211
			drawEllipseRing( -- 1213
				fgGlow, -- 1213
				lx, -- 1213
				ly, -- 1213
				18 * pulse, -- 1213
				7 * pulse, -- 1213
				1.2, -- 1213
				toColor(arcRgb, 165), -- 1213
				20 -- 1213
			) -- 1213
		end -- 1213
	end -- 1213
	return true -- 1217
end -- 1128
function VillageUndertableScene.prototype.drawCeramicBottle(self, fgDraw, fgGlow, worldArt, id, cx, cy, ppu, tilt, shelfGlint) -- 1220
	local size = math.max(12, ppu * 13) -- 1231
	if not worldArt:tryPlace( -- 1231
		"prop_bottle", -- 1232
		id, -- 1232
		cx, -- 1232
		cy, -- 1232
		size, -- 1232
		size, -- 1232
		{angle = tilt * 180 / math.pi, layer = 8} -- 1232
	) then -- 1232
		fgDraw:drawCircle( -- 1236
			Vec2(cx, cy), -- 1236
			size * 0.36, -- 1236
			Color(172, 138, 102, 245) -- 1236
		) -- 1236
	end -- 1236
	if shelfGlint then -- 1236
		local p = 0.72 + 0.28 * math.sin(self.animTime * 3) -- 1239
		fillRadialGlow( -- 1240
			fgGlow, -- 1240
			cx, -- 1240
			cy + 2, -- 1240
			14 * p, -- 1240
			14 * p, -- 1240
			Color( -- 1240
				224, -- 1240
				214, -- 1240
				190, -- 1240
				math.floor(62 * p + 0.5) -- 1240
			), -- 1240
			Color(224, 214, 190, 0), -- 1240
			12 -- 1240
		) -- 1240
	end -- 1240
end -- 1220
function VillageUndertableScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1245
	local p = ctx.p -- 1251
	local cam = ctx.cam -- 1252
	if p.room.scavenger ~= nil then -- 1252
		self:drawScavengerShoeOverlay(fgDraw, fgGlow, p, cam) -- 1254
	end -- 1254
	if ctx.paused then -- 1254
		local arch = p.room.arch -- 1259
		local pTopL = projectWorld3D( -- 1260
			arch.x0 - 160, -- 1260
			arch.h + 18, -- 1260
			-68, -- 1260
			cam, -- 1260
			self.proj -- 1260
		) -- 1260
		local pTopR = projectWorld3D( -- 1261
			arch.x1 + 95, -- 1261
			arch.h + 18, -- 1261
			-68, -- 1261
			cam, -- 1261
			self.proj -- 1261
		) -- 1261
		worldArt:tryPlace( -- 1262
			"cover_wood", -- 1263
			"fe04_pause_table_top", -- 1264
			(pTopL.x + pTopR.x) * 0.5, -- 1265
			pTopL.y, -- 1266
			math.max( -- 1267
				20, -- 1267
				math.abs(pTopR.x - pTopL.x) -- 1267
			), -- 1267
			math.max(40, cam.viewH - pTopL.y + 40), -- 1268
			{ -- 1269
				color = Color(24, 18, 15, 255), -- 1269
				opacity = 0.96, -- 1269
				layer = 5300 -- 1269
			} -- 1269
		) -- 1269
		local legBL = projectWorld3D( -- 1271
			arch.x1 - 8, -- 1271
			-28, -- 1271
			-66, -- 1271
			cam, -- 1271
			self.proj -- 1271
		) -- 1271
		local legTR = projectWorld3D( -- 1272
			arch.x1 + 14, -- 1272
			arch.h + 24, -- 1272
			-66, -- 1272
			cam, -- 1272
			self.proj -- 1272
		) -- 1272
		worldArt:tryPlace( -- 1273
			"cover_wood", -- 1274
			"fe04_pause_table_leg", -- 1275
			(legBL.x + legTR.x) * 0.5, -- 1276
			legBL.y, -- 1277
			math.max( -- 1278
				12, -- 1278
				math.abs(legTR.x - legBL.x) -- 1278
			), -- 1278
			math.max( -- 1279
				40, -- 1279
				math.abs(legTR.y - legBL.y) -- 1279
			), -- 1279
			{ -- 1280
				color = Color(22, 16, 13, 255), -- 1280
				opacity = 0.96, -- 1280
				layer = 5310 -- 1280
			} -- 1280
		) -- 1280
	end -- 1280
end -- 1245
function VillageUndertableScene.prototype.drawScavengerShoeOverlay(self, fgDraw, fgGlow, p, cam) -- 1285
	local cx = cam:sx(p.scavX) -- 1291
	local by = cam:sy(p.room.scavenger ~= nil and p.room.scavenger.y or 0) -- 1292
	local f = self.shoeFacing >= 0 and 1 or -1 -- 1293
	local moving = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 1294
	local stride = moving and math.sin(self.scavStridePhase) * cam:len(7.2) or 0 -- 1295
	local pausedToe = self.shoeToePauseTimer > 0 -- 1296
	fillRadialGlow( -- 1299
		fgGlow, -- 1299
		cx + f * cam:len(4), -- 1299
		by + 2, -- 1299
		cam:len(32), -- 1299
		cam:len(8), -- 1299
		Color(196, 208, 220, 48), -- 1299
		Color(156, 172, 190, 0), -- 1299
		14 -- 1299
	) -- 1299
	fgDraw:drawEllipse( -- 1300
		Vec2( -- 1300
			cx + f * cam:len(2), -- 1300
			by + 1 -- 1300
		), -- 1300
		cam:len(19), -- 1300
		cam:len(3.4), -- 1300
		Color(92, 102, 114, 72) -- 1300
	) -- 1300
	local function drawSingleShoe(footX, liftY, isFront) -- 1303
		local heelX = footX - f * cam:len(4.8) -- 1304
		local midX = footX + f * cam:len(1.8) -- 1305
		local toeX = footX + f * cam:len(7.6) -- 1306
		local soleY = by + 0.8 + liftY -- 1307
		local shoeH = cam:len(4.4) -- 1308
		fgDraw:drawPolygon( -- 1310
			{ -- 1310
				Vec2(heelX, soleY), -- 1311
				Vec2(toeX, soleY), -- 1312
				Vec2( -- 1313
					toeX - f * cam:len(1), -- 1313
					soleY + shoeH * 0.56 -- 1313
				), -- 1313
				Vec2(midX, soleY + shoeH * 0.96), -- 1314
				Vec2( -- 1315
					heelX + f * cam:len(0.6), -- 1315
					soleY + shoeH * 0.86 -- 1315
				) -- 1315
			}, -- 1315
			isFront and Color(68, 58, 48, 250) or Color(46, 40, 34, 240) -- 1316
		) -- 1316
		local soleCol = isFront and Color(198, 192, 178, 232) or Color(148, 144, 134, 195) -- 1318
		fgDraw:drawSegment( -- 1319
			Vec2(heelX, soleY + 0.6), -- 1319
			Vec2(toeX, soleY + 0.6), -- 1319
			1.5, -- 1319
			soleCol -- 1319
		) -- 1319
		fgDraw:drawSegment( -- 1321
			Vec2( -- 1321
				toeX - f * cam:len(1.2), -- 1321
				soleY + 0.8 -- 1321
			), -- 1321
			Vec2( -- 1321
				toeX - f * cam:len(1.4), -- 1321
				soleY + shoeH * 0.56 -- 1321
			), -- 1321
			1.3, -- 1321
			Color(214, 210, 198, isFront and 220 or 165) -- 1321
		) -- 1321
		if isFront and pausedToe then -- 1321
			fgGlow:drawDot( -- 1324
				Vec2(toeX, soleY + 1.5), -- 1324
				3, -- 1324
				Color(236, 218, 178, 155) -- 1324
			) -- 1324
		end -- 1324
	end -- 1303
	local backLift = moving and math.max( -- 1328
		0, -- 1328
		-math.sin(self.scavStridePhase) -- 1328
	) * cam:len(2.4) or 0 -- 1328
	local frontLift = moving and math.max( -- 1329
		0, -- 1329
		math.sin(self.scavStridePhase) -- 1329
	) * cam:len(2.8) or 0 -- 1329
	drawSingleShoe( -- 1330
		cx - stride - f * cam:len(3.5), -- 1330
		backLift, -- 1330
		false -- 1330
	) -- 1330
	drawSingleShoe( -- 1331
		cx + stride + f * cam:len(4), -- 1331
		frontLift, -- 1331
		true -- 1331
	) -- 1331
end -- 1285
function VillageUndertableScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 1340
	local p = ctx.p -- 1347
	local cam = ctx.cam -- 1348
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1349
	local arch = p.room.arch -- 1350
	local tableBottomY = arch.h + 18 + (1 - self.underTableFocus) * 12 -- 1354
	local slabThick = 24 -- 1355
	local apronTopY = tableBottomY + slabThick -- 1356
	local xLeft = p.ox - 80 -- 1357
	local xRight = arch.x1 + 52 -- 1358
	local bFarL = projectWorld3D( -- 1361
		xLeft, -- 1361
		tableBottomY - 4, -- 1361
		-18, -- 1361
		cam, -- 1361
		self.proj -- 1361
	) -- 1361
	local bFarR = projectWorld3D( -- 1362
		xRight, -- 1362
		tableBottomY - 4, -- 1362
		-18, -- 1362
		cam, -- 1362
		self.proj -- 1362
	) -- 1362
	local bNearR = projectWorld3D( -- 1363
		xRight, -- 1363
		tableBottomY + 4, -- 1363
		-74, -- 1363
		cam, -- 1363
		self.proj -- 1363
	) -- 1363
	local bNearL = projectWorld3D( -- 1364
		xLeft, -- 1364
		tableBottomY + 4, -- 1364
		-74, -- 1364
		cam, -- 1364
		self.proj -- 1364
	) -- 1364
	drawUiQuad( -- 1365
		uiDraw, -- 1365
		bFarL, -- 1365
		bFarR, -- 1365
		bNearR, -- 1365
		bNearL, -- 1365
		Color(16, 12, 10, 242), -- 1365
		Color(32, 24, 19, 248), -- 1365
		inv, -- 1365
		Color(88, 68, 52, 125), -- 1365
		1 -- 1365
	) -- 1365
	local beamIdx = 0 -- 1367
	do -- 1367
		beamIdx = 0 -- 1368
		while beamIdx < 4 do -- 1368
			local bx = xLeft + 110 + beamIdx * 105 -- 1369
			local p0 = projectWorld3D( -- 1370
				bx, -- 1370
				tableBottomY - 3, -- 1370
				-18, -- 1370
				cam, -- 1370
				self.proj -- 1370
			) -- 1370
			local p1 = projectWorld3D( -- 1371
				bx, -- 1371
				tableBottomY + 3, -- 1371
				-74, -- 1371
				cam, -- 1371
				self.proj -- 1371
			) -- 1371
			uiDraw:drawSegment( -- 1372
				Vec2(p0.x * inv, p0.y * inv), -- 1372
				Vec2(p1.x * inv, p1.y * inv), -- 1372
				1.2, -- 1372
				Color(56, 42, 32, 155) -- 1372
			) -- 1372
			beamIdx = beamIdx + 1 -- 1368
		end -- 1368
	end -- 1368
	local fBotL = bNearL -- 1376
	local fBotR = bNearR -- 1377
	local fTopR = projectWorld3D( -- 1378
		xRight, -- 1378
		apronTopY, -- 1378
		-74, -- 1378
		cam, -- 1378
		self.proj -- 1378
	) -- 1378
	local fTopL = projectWorld3D( -- 1379
		xLeft, -- 1379
		apronTopY, -- 1379
		-74, -- 1379
		cam, -- 1379
		self.proj -- 1379
	) -- 1379
	drawUiQuad( -- 1380
		uiDraw, -- 1380
		fBotL, -- 1380
		fBotR, -- 1380
		fTopR, -- 1380
		fTopL, -- 1380
		Color(34, 25, 19, 252), -- 1380
		Color(54, 40, 30, 254), -- 1380
		inv, -- 1380
		Color(118, 94, 72, 145), -- 1380
		1.1 -- 1380
	) -- 1380
	local fMidL = projectWorld3D( -- 1381
		xLeft, -- 1381
		tableBottomY + slabThick * 0.52, -- 1381
		-74, -- 1381
		cam, -- 1381
		self.proj -- 1381
	) -- 1381
	local fMidR = projectWorld3D( -- 1382
		xRight, -- 1382
		tableBottomY + slabThick * 0.52, -- 1382
		-74, -- 1382
		cam, -- 1382
		self.proj -- 1382
	) -- 1382
	uiDraw:drawSegment( -- 1383
		Vec2(fMidL.x * inv, fMidL.y * inv), -- 1383
		Vec2(fMidR.x * inv, fMidR.y * inv), -- 1383
		0.9, -- 1383
		Color(18, 13, 10, 195) -- 1383
	) -- 1383
	uiDraw:drawSegment( -- 1385
		Vec2(fBotL.x * inv, fBotL.y * inv), -- 1386
		Vec2(fBotR.x * inv, fBotR.y * inv), -- 1387
		1.6, -- 1388
		Color(148, 126, 104, 185) -- 1389
	) -- 1389
	local roofBotY = apronTopY + 56 -- 1393
	local roofTopY = apronTopY + 150 -- 1394
	local rBL = projectWorld3D( -- 1395
		xLeft, -- 1395
		roofBotY, -- 1395
		-74, -- 1395
		cam, -- 1395
		self.proj -- 1395
	) -- 1395
	local rBR = projectWorld3D( -- 1396
		xRight, -- 1396
		roofBotY, -- 1396
		-74, -- 1396
		cam, -- 1396
		self.proj -- 1396
	) -- 1396
	local rTR = projectWorld3D( -- 1397
		xRight, -- 1397
		roofTopY, -- 1397
		-74, -- 1397
		cam, -- 1397
		self.proj -- 1397
	) -- 1397
	local rTL = projectWorld3D( -- 1398
		xLeft, -- 1398
		roofTopY, -- 1398
		-74, -- 1398
		cam, -- 1398
		self.proj -- 1398
	) -- 1398
	drawUiQuad( -- 1399
		uiDraw, -- 1399
		rBL, -- 1399
		rBR, -- 1399
		rTR, -- 1399
		rTL, -- 1399
		Color(10, 9, 12, 165), -- 1399
		Color(7, 7, 10, 248), -- 1399
		inv -- 1399
	) -- 1399
	local topBackL = projectWorld3D( -- 1401
		xLeft, -- 1401
		apronTopY + 12, -- 1401
		-24, -- 1401
		cam, -- 1401
		self.proj -- 1401
	) -- 1401
	local topBackR = projectWorld3D( -- 1402
		xRight, -- 1402
		apronTopY + 12, -- 1402
		-24, -- 1402
		cam, -- 1402
		self.proj -- 1402
	) -- 1402
	drawUiQuad( -- 1403
		uiDraw, -- 1403
		fTopL, -- 1403
		fTopR, -- 1403
		topBackR, -- 1403
		topBackL, -- 1403
		Color(44, 34, 26, 238), -- 1403
		Color(22, 18, 16, 224), -- 1403
		inv, -- 1403
		Color(128, 108, 88, 130), -- 1403
		0.9 -- 1403
	) -- 1403
	local bowlBL = projectWorld3D( -- 1405
		arch.x0 + 4, -- 1405
		apronTopY + 2, -- 1405
		-56, -- 1405
		cam, -- 1405
		self.proj -- 1405
	) -- 1405
	local bowlBR = projectWorld3D( -- 1406
		arch.x0 + 34, -- 1406
		apronTopY + 2, -- 1406
		-56, -- 1406
		cam, -- 1406
		self.proj -- 1406
	) -- 1406
	local bowlTR = projectWorld3D( -- 1407
		arch.x0 + 38, -- 1407
		apronTopY + 16, -- 1407
		-56, -- 1407
		cam, -- 1407
		self.proj -- 1407
	) -- 1407
	local bowlTL = projectWorld3D( -- 1408
		arch.x0, -- 1408
		apronTopY + 16, -- 1408
		-56, -- 1408
		cam, -- 1408
		self.proj -- 1408
	) -- 1408
	drawUiQuad( -- 1409
		uiDraw, -- 1409
		bowlBL, -- 1409
		bowlBR, -- 1409
		bowlTR, -- 1409
		bowlTL, -- 1409
		Color(62, 58, 54, 242), -- 1409
		Color(108, 104, 98, 244), -- 1409
		inv, -- 1409
		Color(168, 162, 152, 170), -- 1409
		0.9 -- 1409
	) -- 1409
	local clothDropL = projectWorld3D( -- 1412
		arch.x0 - 20, -- 1412
		tableBottomY - 12, -- 1412
		-70, -- 1412
		cam, -- 1412
		self.proj -- 1412
	) -- 1412
	local clothDropMid = projectWorld3D( -- 1413
		arch.x0 + 48, -- 1413
		tableBottomY - 4, -- 1413
		-70, -- 1413
		cam, -- 1413
		self.proj -- 1413
	) -- 1413
	uiDraw:drawVertices({ -- 1414
		{ -- 1415
			Vec2(bNearL.x * inv, bNearL.y * inv), -- 1415
			Color(22, 18, 17, 228) -- 1415
		}, -- 1415
		{ -- 1416
			Vec2(clothDropL.x * inv, clothDropL.y * inv), -- 1416
			Color(32, 26, 24, 214) -- 1416
		}, -- 1416
		{ -- 1417
			Vec2(clothDropMid.x * inv, clothDropMid.y * inv), -- 1417
			Color(24, 20, 18, 205) -- 1417
		} -- 1417
	}) -- 1417
	local legX0 = arch.x1 - 2 -- 1421
	local legX1 = arch.x1 + 12 -- 1422
	local legBotY = -36 -- 1423
	local legTopY = apronTopY -- 1424
	local sBL = projectWorld3D( -- 1427
		legX1, -- 1427
		legBotY, -- 1427
		-72, -- 1427
		cam, -- 1427
		self.proj -- 1427
	) -- 1427
	local sBR = projectWorld3D( -- 1428
		legX1, -- 1428
		legBotY, -- 1428
		-50, -- 1428
		cam, -- 1428
		self.proj -- 1428
	) -- 1428
	local sTR = projectWorld3D( -- 1429
		legX1, -- 1429
		legTopY, -- 1429
		-50, -- 1429
		cam, -- 1429
		self.proj -- 1429
	) -- 1429
	local sTL = projectWorld3D( -- 1430
		legX1, -- 1430
		legTopY, -- 1430
		-72, -- 1430
		cam, -- 1430
		self.proj -- 1430
	) -- 1430
	drawUiQuad( -- 1431
		uiDraw, -- 1431
		sBL, -- 1431
		sBR, -- 1431
		sTR, -- 1431
		sTL, -- 1431
		Color(42, 32, 24, 250), -- 1431
		Color(68, 52, 38, 252), -- 1431
		inv, -- 1431
		Color(142, 122, 102, 165), -- 1431
		1 -- 1431
	) -- 1431
	local mBL = projectWorld3D( -- 1434
		legX0, -- 1434
		legBotY, -- 1434
		-72, -- 1434
		cam, -- 1434
		self.proj -- 1434
	) -- 1434
	local mBR = sBL -- 1435
	local mTR = sTL -- 1436
	local mTL = projectWorld3D( -- 1437
		legX0, -- 1437
		legTopY, -- 1437
		-72, -- 1437
		cam, -- 1437
		self.proj -- 1437
	) -- 1437
	drawUiQuad( -- 1438
		uiDraw, -- 1438
		mBL, -- 1438
		mBR, -- 1438
		mTR, -- 1438
		mTL, -- 1438
		Color(18, 14, 11, 254), -- 1438
		Color(30, 23, 18, 254), -- 1438
		inv, -- 1438
		Color(76, 58, 44, 125), -- 1438
		0.9 -- 1438
	) -- 1438
	local grainB = projectWorld3D( -- 1439
		(legX0 + legX1) * 0.5, -- 1439
		legBotY, -- 1439
		-72, -- 1439
		cam, -- 1439
		self.proj -- 1439
	) -- 1439
	local grainT = projectWorld3D( -- 1440
		(legX0 + legX1) * 0.5, -- 1440
		legTopY, -- 1440
		-72, -- 1440
		cam, -- 1440
		self.proj -- 1440
	) -- 1440
	uiDraw:drawSegment( -- 1441
		Vec2(grainB.x * inv, grainB.y * inv), -- 1441
		Vec2(grainT.x * inv, grainT.y * inv), -- 1441
		0.8, -- 1441
		Color(46, 35, 26, 130) -- 1441
	) -- 1441
	uiDraw:drawSegment( -- 1444
		Vec2(sBR.x * inv, sBR.y * inv), -- 1445
		Vec2(sTR.x * inv, sTR.y * inv), -- 1446
		1.1, -- 1447
		Color(172, 166, 158, 165) -- 1448
	) -- 1448
	local lLegBL = projectWorld3D( -- 1452
		p.ox + 64, -- 1452
		-36, -- 1452
		-82, -- 1452
		cam, -- 1452
		self.proj -- 1452
	) -- 1452
	local lLegBR = projectWorld3D( -- 1453
		p.ox + 78, -- 1453
		-36, -- 1453
		-82, -- 1453
		cam, -- 1453
		self.proj -- 1453
	) -- 1453
	local lLegTR = projectWorld3D( -- 1454
		p.ox + 78, -- 1454
		apronTopY, -- 1454
		-82, -- 1454
		cam, -- 1454
		self.proj -- 1454
	) -- 1454
	local lLegTL = projectWorld3D( -- 1455
		p.ox + 64, -- 1455
		apronTopY, -- 1455
		-82, -- 1455
		cam, -- 1455
		self.proj -- 1455
	) -- 1455
	drawUiQuad( -- 1456
		uiDraw, -- 1456
		lLegBL, -- 1456
		lLegBR, -- 1456
		lLegTR, -- 1456
		lLegTL, -- 1456
		Color(12, 10, 10, 232), -- 1456
		Color(20, 16, 14, 238), -- 1456
		inv -- 1456
	) -- 1456
	return false -- 1459
end -- 1340
return ____exports -- 1340