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
		local audioKey = ((((((("r" .. tostring(ctx.events.roomSessionId)) .. ":cp") .. tostring(ctx.events.checkpoint)) .. ":t") .. tostring(ev.tick)) .. ":s") .. tostring(ev.seq)) .. ":bottleLanded" -- 508
		if not ctx.audio:hasPlayed(audioKey) then -- 508
			local key = (((("fe04:village:soft_thud:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(ev.tick)) .. ":") .. tostring(ev.seq) -- 510
			ctx.audio:playOnce( -- 511
				key, -- 512
				"sfx", -- 513
				CHILD_AUDIO_ROOT .. "bottle_soft.wav", -- 514
				0.76, -- 515
				"fe04:bottle:soft_thud", -- 516
				ev.tick, -- 517
				ev.seq -- 518
			) -- 518
		end -- 518
	end -- 518
end -- 461
function VillageUndertableScene.prototype.spawnShards(self, x, y, kind, count) -- 524
	local i = 0 -- 525
	do -- 525
		i = 0 -- 526
		while i < count do -- 526
			local ang = (0.18 + self:rand() * 0.64) * math.pi -- 527
			local spd = (kind == "soft" and 28 or 65) + self:rand() * (kind == "soft" and 36 or 95) -- 528
			local ____self_shards_5 = self.shards -- 528
			____self_shards_5[#____self_shards_5 + 1] = { -- 529
				x = x + (self:rand() - 0.5) * 10, -- 530
				y = y + 2, -- 531
				vx = math.cos(ang) * spd * (self:rand() > 0.5 and 1 or -1), -- 532
				vy = math.sin(ang) * spd, -- 533
				size = kind == "soft" and 2.2 + self:rand() * 2.4 or 1.8 + self:rand() * 2.2, -- 534
				life = (kind == "soft" and 0.34 or 0.48) + self:rand() * 0.22, -- 535
				maxLife = 0.65, -- 536
				kind = kind -- 537
			} -- 537
			i = i + 1 -- 526
		end -- 526
	end -- 526
end -- 524
function VillageUndertableScene.prototype.triggerRehearsalImpact(self, ctx, surface) -- 543
	local p = ctx.p -- 544
	local x = surface == "iron" and self:getBasinWorldX(p) or (surface == "soft" and self:getSoftWorldX(p) or self:getBrickWorldX(p)) -- 545
	self:onBottleLanded(ctx, {seq = 9000 + self.brickHits + self.ironHits + self.softHits, tick = p.ticks, name = "bottleLanded", data = {x = x, y = 0, surface = surface, heard = true}}) -- 548
end -- 543
function VillageUndertableScene.prototype.drawBackdrop(self, bgDraw, bgGlow, _backdropArt, ctx) -- 556
	local p = ctx.p -- 562
	local cam = ctx.cam -- 563
	local w = cam.viewW -- 564
	local h = cam.viewH -- 565
	local splitY = h * 0.5 -- 568
	fillVGradRect( -- 569
		bgDraw, -- 569
		0, -- 569
		splitY, -- 569
		w, -- 569
		h - splitY, -- 569
		Color(14, 18, 26, 255), -- 569
		Color(7, 9, 15, 255) -- 569
	) -- 569
	fillVGradRect( -- 570
		bgDraw, -- 570
		0, -- 570
		0, -- 570
		w, -- 570
		splitY, -- 570
		Color(24, 28, 38, 255), -- 570
		Color(14, 18, 26, 255) -- 570
	) -- 570
	local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 572
	local ox = p.ox -- 573
	scene:addDistantRidge( -- 576
		{ -- 577
			{x = ox - 140, y = 120}, -- 578
			{x = ox + 120, y = 162}, -- 579
			{x = ox + 360, y = 138}, -- 580
			{x = ox + 590, y = 176}, -- 581
			{x = ox + 860, y = 132} -- 582
		}, -- 582
		-20, -- 582
		420, -- 585
		MING_MATERIALS.distantHill, -- 586
		{bucket = LP_BUCKET.BACKDROP} -- 587
	) -- 587
	scene:addBox({ -- 591
		x0 = ox + 460, -- 592
		x1 = ox + 690, -- 593
		y0 = 0, -- 594
		y1 = 118, -- 595
		z0 = 210, -- 596
		z1 = 260, -- 597
		material = MING_MATERIALS.distantWall, -- 598
		bucket = LP_BUCKET.BACKDROP, -- 599
		edgeWidth = 0 -- 600
	}) -- 600
	scene:addTri3D( -- 602
		vec3(ox + 446, 118, 206), -- 603
		vec3(ox + 704, 118, 206), -- 604
		vec3(ox + 575, 162, 232), -- 605
		MING_MATERIALS.mingTile, -- 606
		{bucket = LP_BUCKET.BACKDROP, sortBias = 0.04} -- 607
	) -- 607
	scene:addBox({ -- 611
		x0 = ox - 60, -- 612
		x1 = ox + 436, -- 613
		y0 = 0, -- 614
		y1 = 196, -- 615
		z0 = 112, -- 616
		z1 = 152, -- 617
		material = MING_MATERIALS.mingBrickDark, -- 618
		bucket = LP_BUCKET.BACKDROP, -- 619
		edgeWidth = 0.6 -- 620
	}) -- 620
	scene:addBox({ -- 624
		x0 = ox + 150, -- 625
		x1 = ox + 258, -- 626
		y0 = 0, -- 627
		y1 = 42, -- 628
		z0 = 76, -- 629
		z1 = 112, -- 630
		material = MAT_CLAY_STOVE, -- 631
		bucket = LP_BUCKET.MIDGROUND, -- 632
		highlightTopEdge = true -- 633
	}) -- 633
	scene:addBox({ -- 635
		x0 = ox + 178, -- 636
		x1 = ox + 228, -- 637
		y0 = 42, -- 638
		y1 = 156, -- 639
		z0 = 94, -- 640
		z1 = 114, -- 641
		material = MAT_CLAY_STOVE, -- 642
		bucket = LP_BUCKET.MIDGROUND, -- 643
		edgeWidth = 0.5 -- 644
	}) -- 644
	scene:addBox({ -- 648
		x0 = ox + 486, -- 649
		x1 = ox + 536, -- 650
		y0 = 0, -- 651
		y1 = 34, -- 652
		z0 = 126, -- 653
		z1 = 162, -- 654
		material = MING_MATERIALS.mingStoneStep, -- 655
		bucket = LP_BUCKET.MIDGROUND, -- 656
		highlightTopEdge = true -- 657
	}) -- 657
	scene:addFogBand( -- 661
		ox - 120, -- 661
		ox + 840, -- 661
		-10, -- 661
		140, -- 661
		260, -- 661
		rgba(24, 30, 42, 255), -- 661
		0.62, -- 661
		0.05, -- 661
		{bucket = LP_BUCKET.BACKDROP} -- 661
	) -- 661
	scene:flush(bgDraw, bgGlow) -- 665
	local mx = w * 0.8 -- 668
	local my = h * 0.84 -- 669
	fillRadialGlow( -- 670
		bgGlow, -- 670
		mx, -- 670
		my, -- 670
		96, -- 670
		96, -- 670
		Color(188, 206, 224, 24), -- 670
		Color(24, 32, 46, 0), -- 670
		16 -- 670
	) -- 670
	bgDraw:drawCircle( -- 671
		Vec2(mx, my), -- 671
		14, -- 671
		Color(214, 224, 236, 130) -- 671
	) -- 671
	local towerPt = projectWorld3D( -- 674
		ox + 668, -- 674
		152, -- 674
		410, -- 674
		cam, -- 674
		self.proj -- 674
	) -- 674
	fillRadialGlow( -- 675
		bgGlow, -- 675
		towerPt.x, -- 675
		towerPt.y, -- 675
		20, -- 675
		20, -- 675
		Color(238, 198, 132, 54), -- 675
		Color(238, 198, 132, 0), -- 675
		12 -- 675
	) -- 675
	bgGlow:drawDot( -- 676
		Vec2(towerPt.x, towerPt.y), -- 676
		2, -- 676
		Color(252, 232, 186, 185) -- 676
	) -- 676
	return true -- 678
end -- 556
function VillageUndertableScene.prototype.drawWorld(self, fgDraw, fgGlow, _worldArt, ctx) -- 681
	local p = ctx.p -- 687
	local cam = ctx.cam -- 688
	local ox = p.ox -- 689
	local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 690
	scene:addBox({ -- 693
		x0 = ox - 40, -- 694
		x1 = ox + 436, -- 695
		y0 = -52, -- 696
		y1 = 0, -- 697
		z0 = -32, -- 698
		z1 = 112, -- 699
		material = MING_MATERIALS.mingTimberDark, -- 700
		bucket = LP_BUCKET.MIDGROUND, -- 701
		highlightTopEdge = true, -- 702
		edgeWidth = 0.7 -- 703
	}) -- 703
	scene:addBox({ -- 705
		x0 = ox + 436, -- 706
		x1 = ox + 760, -- 707
		y0 = -52, -- 708
		y1 = 0, -- 709
		z0 = -32, -- 710
		z1 = 126, -- 711
		material = MING_MATERIALS.mingBrickDark, -- 712
		bucket = LP_BUCKET.MIDGROUND, -- 713
		highlightTopEdge = true, -- 714
		edgeWidth = 0.8 -- 715
	}) -- 715
	scene:addBeveledFrame( -- 719
		ox + 416, -- 719
		ox + 462, -- 719
		0, -- 719
		128, -- 719
		16, -- 719
		22, -- 719
		16, -- 719
		112, -- 719
		MING_MATERIALS.mingTimberDark, -- 719
		{ -- 719
			bucket = LP_BUCKET.MIDGROUND, -- 720
			innerRimLight = rgba(206, 214, 222, 255), -- 721
			innerRimStrength = 0.42 -- 722
		} -- 722
	) -- 722
	scene:addBox({ -- 726
		x0 = ox + 96, -- 727
		x1 = ox + 128, -- 728
		y0 = 0, -- 729
		y1 = 64, -- 730
		z0 = -8, -- 731
		z1 = 36, -- 732
		material = MAT_TABLE_WOOD, -- 733
		bucket = LP_BUCKET.WALK_DECK, -- 734
		highlightTopEdge = true, -- 735
		edgeWidth = 0.9 -- 736
	}) -- 736
	scene:addBox({ -- 739
		x0 = ox + 94, -- 740
		x1 = ox + 130, -- 741
		y0 = 32, -- 742
		y1 = 36, -- 743
		z0 = -10, -- 744
		z1 = 34, -- 745
		material = MING_MATERIALS.mingTimber, -- 746
		bucket = LP_BUCKET.WALK_DECK, -- 747
		sortBias = 0.05 -- 748
	}) -- 748
	scene:addBox({ -- 751
		x0 = ox + 672, -- 752
		x1 = ox + 720, -- 753
		y0 = 0, -- 754
		y1 = 96, -- 755
		z0 = -14, -- 756
		z1 = 96, -- 757
		material = MING_MATERIALS.mingBrick, -- 758
		bucket = LP_BUCKET.MIDGROUND, -- 759
		highlightTopEdge = true, -- 760
		edgeWidth = 0.9 -- 761
	}) -- 761
	scene:addBox({ -- 763
		x0 = ox + 666, -- 764
		x1 = ox + 726, -- 765
		y0 = 96, -- 766
		y1 = 106, -- 767
		z0 = -18, -- 768
		z1 = 100, -- 769
		material = MING_MATERIALS.mingTile, -- 770
		bucket = LP_BUCKET.MIDGROUND, -- 771
		sortBias = 0.08 -- 772
	}) -- 772
	local arch = p.room.arch -- 776
	scene:addBox({ -- 778
		x0 = arch.x0 - 2, -- 779
		x1 = arch.x0 + 10, -- 780
		y0 = 0, -- 781
		y1 = arch.h, -- 782
		z0 = 14, -- 783
		z1 = 28, -- 784
		material = MAT_TABLE_WOOD, -- 785
		bucket = LP_BUCKET.MIDGROUND, -- 786
		edgeWidth = 0.8 -- 787
	}) -- 787
	scene:addBox({ -- 789
		x0 = arch.x1 - 10, -- 790
		x1 = arch.x1 + 2, -- 791
		y0 = 0, -- 792
		y1 = arch.h, -- 793
		z0 = 14, -- 794
		z1 = 28, -- 795
		material = MAT_TABLE_WOOD, -- 796
		bucket = LP_BUCKET.MIDGROUND, -- 797
		edgeWidth = 0.8 -- 798
	}) -- 798
	scene:addBox({ -- 801
		x0 = arch.x0 - 12, -- 802
		x1 = arch.x1 + 12, -- 803
		y0 = arch.h, -- 804
		y1 = arch.h + 11, -- 805
		z0 = -16, -- 806
		z1 = 36, -- 807
		material = MAT_TABLE_WOOD, -- 808
		bucket = LP_BUCKET.WALK_DECK, -- 809
		highlightTopEdge = true, -- 810
		edgeWidth = 0.9 -- 811
	}) -- 811
	scene:addBox({ -- 814
		x0 = arch.x0 + 28, -- 815
		x1 = arch.x0 + 44, -- 816
		y0 = arch.h + 11, -- 817
		y1 = arch.h + 18, -- 818
		z0 = 4, -- 819
		z1 = 18, -- 820
		material = MING_MATERIALS.mingStoneStep, -- 821
		bucket = LP_BUCKET.PROP, -- 822
		highlightTopEdge = true -- 823
	}) -- 823
	local culvertX = self:getCulvertWorldX(p) -- 827
	self:buildCulvertEntrance(scene, culvertX) -- 828
	local softX = self:getSoftWorldX(p) -- 832
	self:buildSoftDirtPatch(scene, softX) -- 833
	local brickX = self:getBrickWorldX(p) -- 836
	self:buildHardBrickPatch(scene, brickX) -- 837
	local basinX = self:getBasinWorldX(p) -- 840
	self:buildIronBasin(scene, basinX) -- 841
	scene:addLightShaft( -- 844
		ox + 570, -- 845
		ox + 710, -- 845
		290, -- 845
		ox + 446, -- 846
		ox + 642, -- 846
		0, -- 846
		24, -- 847
		rgba(218, 226, 218, 255), -- 848
		0.13, -- 849
		0.04 -- 850
	) -- 850
	scene:addContactShadow( -- 854
		p.player.x, -- 854
		p.player.y, -- 854
		14, -- 854
		10, -- 854
		0.8, -- 854
		{bucket = LP_BUCKET.PROP, sortBias = 0.4} -- 854
	) -- 854
	if p.room.scavenger ~= nil then -- 854
		scene:addContactShadow( -- 856
			p.scavX, -- 856
			p.room.scavenger.y, -- 856
			19, -- 856
			13, -- 856
			0.84, -- 856
			{bucket = LP_BUCKET.PROP, sortBias = 0.42} -- 856
		) -- 856
	end -- 856
	scene:flush(fgDraw, fgGlow) -- 859
	self:drawSurfaceReadabilityDetails( -- 862
		fgDraw, -- 862
		fgGlow, -- 862
		p, -- 862
		cam, -- 862
		softX, -- 862
		culvertX, -- 862
		basinX, -- 862
		brickX -- 862
	) -- 862
	return true -- 864
end -- 681
function VillageUndertableScene.prototype.buildCulvertEntrance(self, scene, cx) -- 867
	scene:addBox({ -- 869
		x0 = cx - 18, -- 870
		x1 = cx + 18, -- 871
		y0 = -12, -- 872
		y1 = 2, -- 873
		z0 = -6, -- 874
		z1 = 42, -- 875
		material = MAT_CULVERT_STONE, -- 876
		bucket = LP_BUCKET.WALK_DECK, -- 877
		highlightTopEdge = true, -- 878
		edgeWidth = 1 -- 879
	}) -- 879
	scene:addQuad3D( -- 882
		vec3(cx - 12, 1, 22), -- 883
		vec3(cx + 12, 1, 22), -- 884
		vec3(cx + 10, 26, 22), -- 885
		vec3(cx - 10, 26, 22), -- 886
		{base = rgba(6, 9, 14, 255)}, -- 887
		{ -- 888
			bucket = LP_BUCKET.MIDGROUND, -- 888
			unlit = true, -- 888
			sortBias = 0.35, -- 888
			edgeColor = rgba(186, 204, 222, 185), -- 888
			edgeWidth = 1.2 -- 888
		} -- 888
	) -- 888
	scene:addBox({ -- 891
		x0 = cx - 15, -- 892
		x1 = cx - 11, -- 893
		y0 = 2, -- 894
		y1 = 24, -- 895
		z0 = 14, -- 896
		z1 = 22, -- 897
		material = MING_MATERIALS.mingTimber, -- 898
		bucket = LP_BUCKET.PROP, -- 899
		highlightTopEdge = true -- 900
	}) -- 900
	local gi = 0 -- 902
	do -- 902
		gi = 0 -- 903
		while gi < 3 do -- 903
			local gx = cx - 6 + gi * 6 -- 904
			scene:addBox({ -- 905
				x0 = gx - 1, -- 906
				x1 = gx + 1, -- 907
				y0 = 2, -- 908
				y1 = 24, -- 909
				z0 = 18, -- 910
				z1 = 21, -- 911
				material = MING_MATERIALS.mingIron, -- 912
				bucket = LP_BUCKET.PROP, -- 913
				sortBias = 0.1 -- 914
			}) -- 914
			gi = gi + 1 -- 903
		end -- 903
	end -- 903
end -- 867
function VillageUndertableScene.prototype.buildSoftDirtPatch(self, scene, softX) -- 919
	scene:addBox({ -- 920
		x0 = softX - 24, -- 921
		x1 = softX + 24, -- 922
		y0 = -4, -- 923
		y1 = 1.5, -- 924
		z0 = -16, -- 925
		z1 = 28, -- 926
		material = MAT_SOFT_EARTH, -- 927
		bucket = LP_BUCKET.WALK_DECK, -- 928
		sortBias = 0.15, -- 929
		edgeWidth = 0.4 -- 930
	}) -- 930
end -- 919
function VillageUndertableScene.prototype.buildHardBrickPatch(self, scene, brickX) -- 934
	local col = 0 -- 936
	do -- 936
		col = 0 -- 937
		while col < 3 do -- 937
			local bx0 = brickX - 24 + col * 16 -- 938
			local bx1 = bx0 + 14.5 -- 939
			scene:addBox({ -- 940
				x0 = bx0, -- 941
				x1 = bx1, -- 942
				y0 = -4, -- 943
				y1 = 3.2, -- 944
				z0 = -14, -- 945
				z1 = 6, -- 946
				material = MAT_HARD_BRICK, -- 947
				bucket = LP_BUCKET.WALK_DECK, -- 948
				sortBias = 0.2 + col * 0.01, -- 949
				highlightTopEdge = true, -- 950
				edgeWidth = 1 -- 951
			}) -- 951
			scene:addBox({ -- 953
				x0 = bx0 + 4, -- 954
				x1 = bx1 + 4, -- 955
				y0 = -4, -- 956
				y1 = 2.8, -- 957
				z0 = 8, -- 958
				z1 = 26, -- 959
				material = MAT_HARD_BRICK, -- 960
				bucket = LP_BUCKET.WALK_DECK, -- 961
				sortBias = 0.18 + col * 0.01, -- 962
				highlightTopEdge = true, -- 963
				edgeWidth = 0.9 -- 964
			}) -- 964
			col = col + 1 -- 937
		end -- 937
	end -- 937
end -- 934
function VillageUndertableScene.prototype.buildIronBasin(self, scene, basinX) -- 969
	scene:addBox({ -- 971
		x0 = basinX - 14, -- 972
		x1 = basinX + 14, -- 973
		y0 = -2, -- 974
		y1 = 3, -- 975
		z0 = -10, -- 976
		z1 = 14, -- 977
		material = MING_MATERIALS.mingBrickDark, -- 978
		bucket = LP_BUCKET.PROP, -- 979
		sortBias = 0.02 -- 980
	}) -- 980
	local tilt = self.basinShakeAngle -- 983
	local liftL = math.sin(tilt) * 14 -- 984
	local liftR = -liftL -- 985
	local shiftX = math.sin(tilt * 1.4) * 2.5 -- 986
	local baseY = 3 -- 987
	local topY = 14.5 -- 988
	local bx = basinX + shiftX -- 989
	scene:addQuad3D( -- 992
		vec3( -- 993
			bx - 11, -- 993
			baseY + math.max(0, liftL * 0.4), -- 993
			-8 -- 993
		), -- 993
		vec3( -- 994
			bx + 11, -- 994
			baseY + math.max(0, liftR * 0.4), -- 994
			-8 -- 994
		), -- 994
		vec3(bx + 16, topY + liftR, -12), -- 995
		vec3(bx - 16, topY + liftL, -12), -- 996
		MAT_IRON_BASIN, -- 997
		{bucket = LP_BUCKET.PROP, sortBias = 0.25, edgeWidth = 1.2} -- 998
	) -- 998
	scene:addQuad3D( -- 1001
		vec3( -- 1002
			bx - 11, -- 1002
			baseY + math.max(0, liftL * 0.4), -- 1002
			10 -- 1002
		), -- 1002
		vec3( -- 1003
			bx - 11, -- 1003
			baseY + math.max(0, liftL * 0.4), -- 1003
			-8 -- 1003
		), -- 1003
		vec3(bx - 16, topY + liftL, -12), -- 1004
		vec3(bx - 16, topY + liftL, 14), -- 1005
		MAT_IRON_BASIN, -- 1006
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1007
	) -- 1007
	scene:addQuad3D( -- 1009
		vec3( -- 1010
			bx + 11, -- 1010
			baseY + math.max(0, liftR * 0.4), -- 1010
			-8 -- 1010
		), -- 1010
		vec3( -- 1011
			bx + 11, -- 1011
			baseY + math.max(0, liftR * 0.4), -- 1011
			10 -- 1011
		), -- 1011
		vec3(bx + 16, topY + liftR, 14), -- 1012
		vec3(bx + 16, topY + liftR, -12), -- 1013
		MAT_IRON_BASIN, -- 1014
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1015
	) -- 1015
	scene:addQuad3D( -- 1018
		vec3(bx - 14, topY - 1 + liftL, -10), -- 1019
		vec3(bx + 14, topY - 1 + liftR, -10), -- 1020
		vec3(bx + 14, topY - 1 + liftR, 12), -- 1021
		vec3(bx - 14, topY - 1 + liftL, 12), -- 1022
		{ -- 1023
			base = rgba(24, 30, 40, 255), -- 1023
			edge = rgba(232, 238, 246, 235) -- 1023
		}, -- 1023
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 1.5} -- 1024
	) -- 1024
end -- 969
function VillageUndertableScene.prototype.drawSurfaceReadabilityDetails(self, fgDraw, fgGlow, p, cam, softX, culvertX, basinX, brickX) -- 1028
	local y0 = cam:sy(0) -- 1038
	local sx0 = cam:sx(softX - 20) -- 1041
	local sx1 = cam:sx(softX + 20) -- 1042
	local d = 0 -- 1043
	do -- 1043
		d = 0 -- 1044
		while d < 9 do -- 1044
			local dx = sx0 + (sx1 - sx0) * (d + 0.5) / 9 -- 1045
			local dy = y0 - 2.5 + (d % 3 - 1) * 1.8 -- 1046
			fgDraw:drawDot( -- 1047
				Vec2(dx, dy), -- 1047
				1.3, -- 1047
				Color(116, 98, 78, 175) -- 1047
			) -- 1047
			d = d + 1 -- 1044
		end -- 1044
	end -- 1044
	fgDraw:drawEllipse( -- 1049
		Vec2( -- 1049
			cam:sx(softX - 7), -- 1049
			y0 - 1.5 -- 1049
		), -- 1049
		cam:len(4.2), -- 1049
		1.6, -- 1049
		Color(38, 30, 24, 185) -- 1049
	) -- 1049
	fgDraw:drawEllipse( -- 1050
		Vec2( -- 1050
			cam:sx(softX + 8), -- 1050
			y0 - 2 -- 1050
		), -- 1050
		cam:len(4.2), -- 1050
		1.6, -- 1050
		Color(38, 30, 24, 185) -- 1050
	) -- 1050
	local cL = cam:sx(culvertX - 11) -- 1053
	local cR = cam:sx(culvertX + 11) -- 1054
	local cTop = cam:sy(25) -- 1055
	fgDraw:drawSegment( -- 1056
		Vec2(cL, cTop), -- 1056
		Vec2(cR, cTop), -- 1056
		1.6, -- 1056
		Color(196, 210, 224, 210) -- 1056
	) -- 1056
	local rippleShift = math.sin(self.animTime * 2.3) * 3 -- 1057
	fgGlow:drawSegment( -- 1058
		Vec2(cL + 3 + rippleShift, y0 + 2), -- 1058
		Vec2(cR - 4 + rippleShift, y0 + 2), -- 1058
		1.1, -- 1058
		Color(164, 192, 214, 105) -- 1058
	) -- 1058
	local bPtL = projectWorld3D( -- 1061
		basinX - 16, -- 1061
		14.5 + math.sin(self.basinShakeAngle) * 14, -- 1061
		-12, -- 1061
		cam, -- 1061
		self.proj -- 1061
	) -- 1061
	local bPtR = projectWorld3D( -- 1062
		basinX + 16, -- 1062
		14.5 - math.sin(self.basinShakeAngle) * 14, -- 1062
		-12, -- 1062
		cam, -- 1062
		self.proj -- 1062
	) -- 1062
	local shakeBoost = self.basinShakeTimer > 0 and clamp01(self.basinShakeTimer / self.basinShakeMax) or 0 -- 1063
	local rimAlpha = math.floor(205 + 48 * shakeBoost + 0.5) -- 1064
	fgDraw:drawSegment( -- 1065
		Vec2(bPtL.x, bPtL.y), -- 1065
		Vec2(bPtR.x, bPtR.y), -- 1065
		2.1 + shakeBoost * 1.1, -- 1065
		Color(230, 236, 242, rimAlpha) -- 1065
	) -- 1065
	fillRadialGlow( -- 1066
		fgGlow, -- 1067
		(bPtL.x + bPtR.x) * 0.5, -- 1068
		(bPtL.y + bPtR.y) * 0.5, -- 1069
		cam:len(22 + shakeBoost * 18), -- 1070
		cam:len(10 + shakeBoost * 8), -- 1071
		Color( -- 1072
			216, -- 1072
			226, -- 1072
			236, -- 1072
			math.floor(48 + 95 * shakeBoost + 0.5) -- 1072
		), -- 1072
		Color(186, 202, 220, 0), -- 1073
		14 -- 1074
	) -- 1074
	local brL = cam:sx(brickX - 24) -- 1078
	local brR = cam:sx(brickX + 24) -- 1079
	local brTop = cam:sy(3.2) -- 1080
	fgDraw:drawSegment( -- 1081
		Vec2(brL, brTop), -- 1081
		Vec2(brR, brTop), -- 1081
		1.8, -- 1081
		Color(224, 228, 234, 225) -- 1081
	) -- 1081
	local k = 1 -- 1082
	do -- 1082
		k = 1 -- 1083
		while k <= 2 do -- 1083
			local seamX = brL + (brR - brL) * k / 3 -- 1084
			fgDraw:drawSegment( -- 1085
				Vec2(seamX, y0 - 3), -- 1085
				Vec2(seamX, brTop + 1), -- 1085
				1.5, -- 1085
				Color(20, 24, 32, 240) -- 1085
			) -- 1085
			fgDraw:drawSegment( -- 1086
				Vec2(seamX + 1.8, y0 - 2), -- 1086
				Vec2(seamX + 1.8, brTop), -- 1086
				0.9, -- 1086
				Color(214, 218, 224, 175) -- 1086
			) -- 1086
			k = k + 1 -- 1083
		end -- 1083
	end -- 1083
	local i = 0 -- 1090
	do -- 1090
		i = 0 -- 1091
		while i < #self.rings do -- 1091
			do -- 1091
				local rg = self.rings[i + 1] -- 1092
				if rg.age < 0 then -- 1092
					goto __continue76 -- 1094
				end -- 1094
				local t = clamp01(rg.age / rg.duration) -- 1096
				local r = math.max( -- 1097
					4, -- 1097
					cam:len(rg.maxRadius) * (0.14 + 0.86 * t) -- 1097
				) -- 1097
				local alpha = (1 - t) * (rg.kind == "iron" and 0.88 or (rg.kind == "brick" and 0.82 or 0.4)) -- 1098
				local rx = cam:sx(rg.x) -- 1099
				local ry = cam:sy(rg.y) -- 1100
				local ringCol = rg.kind == "iron" and Color( -- 1101
					220, -- 1102
					234, -- 1102
					246, -- 1102
					math.floor(235 * alpha + 0.5) -- 1102
				) or (rg.kind == "brick" and Color( -- 1102
					236, -- 1104
					216, -- 1104
					178, -- 1104
					math.floor(225 * alpha + 0.5) -- 1104
				) or Color( -- 1104
					148, -- 1105
					134, -- 1105
					114, -- 1105
					math.floor(165 * alpha + 0.5) -- 1105
				)) -- 1105
				drawEllipseRing( -- 1106
					fgGlow, -- 1106
					rx, -- 1106
					ry, -- 1106
					r, -- 1106
					r * 0.34, -- 1106
					rg.kind == "iron" and 1.8 or 1.4, -- 1106
					ringCol, -- 1106
					22 -- 1106
				) -- 1106
				if rg.kind == "iron" then -- 1106
					drawEllipseRing( -- 1108
						fgDraw, -- 1108
						rx, -- 1108
						ry, -- 1108
						r * 0.96, -- 1108
						r * 0.32, -- 1108
						1.1, -- 1108
						Color( -- 1108
							214, -- 1108
							224, -- 1108
							236, -- 1108
							math.floor(150 * alpha + 0.5) -- 1108
						), -- 1108
						22 -- 1108
					) -- 1108
				end -- 1108
			end -- 1108
			::__continue76:: -- 1108
			i = i + 1 -- 1091
		end -- 1091
	end -- 1091
	do -- 1091
		i = 0 -- 1111
		while i < #self.shards do -- 1111
			local sp = self.shards[i + 1] -- 1112
			local a = clamp01(sp.life / sp.maxLife) -- 1113
			local col = sp.kind == "soft" and Color( -- 1114
				138, -- 1115
				120, -- 1115
				98, -- 1115
				math.floor(170 * a + 0.5) -- 1115
			) or (sp.kind == "iron" and Color( -- 1115
				224, -- 1117
				232, -- 1117
				242, -- 1117
				math.floor(225 * a + 0.5) -- 1117
			) or Color( -- 1117
				216, -- 1118
				198, -- 1118
				174, -- 1118
				math.floor(220 * a + 0.5) -- 1118
			)) -- 1118
			fgDraw:drawDot( -- 1119
				Vec2( -- 1119
					cam:sx(sp.x), -- 1119
					cam:sy(sp.y) -- 1119
				), -- 1119
				sp.size, -- 1119
				col -- 1119
			) -- 1119
			i = i + 1 -- 1111
		end -- 1111
	end -- 1111
	if p.bottleLandT > 0 and p.bottleLandX >= 0 and #self.rings == 0 then -- 1111
		local rx = cam:sx(p.bottleLandX) -- 1124
		local ry = cam:sy(math.max(1, p.bottleLandY)) -- 1125
		fgDraw:drawDot( -- 1126
			Vec2(rx, ry), -- 1126
			2.5, -- 1126
			Color(216, 206, 186, 150) -- 1126
		) -- 1126
	end -- 1126
end -- 1028
function VillageUndertableScene.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1131
	local p = ctx.p -- 1137
	local cam = ctx.cam -- 1138
	local bottle = p.room.bottle -- 1141
	if bottle ~= nil and not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 1141
		self:drawCeramicBottle( -- 1143
			fgDraw, -- 1143
			fgGlow, -- 1143
			worldArt, -- 1143
			"fe04_bottle_shelf", -- 1143
			cam:sx(bottle.x), -- 1143
			cam:sy(67), -- 1143
			cam.ppu, -- 1143
			0, -- 1143
			true -- 1143
		) -- 1143
	end -- 1143
	if p.hasBottle then -- 1143
		local pl = p.player -- 1148
		self:drawCeramicBottle( -- 1149
			fgDraw, -- 1150
			fgGlow, -- 1151
			worldArt, -- 1152
			"fe04_bottle_held", -- 1153
			cam:sx(pl.x + pl.facing * 11), -- 1154
			cam:sy(pl.y + pl.h * 0.56), -- 1155
			cam.ppu, -- 1156
			pl.facing * 0.22, -- 1157
			false -- 1158
		) -- 1158
	end -- 1158
	if p.bottleFly ~= nil then -- 1158
		self:drawCeramicBottle( -- 1162
			fgDraw, -- 1163
			fgGlow, -- 1164
			worldArt, -- 1165
			"fe04_bottle_air", -- 1166
			cam:sx(p.bottleFly.x), -- 1167
			cam:sy(p.bottleFly.y), -- 1168
			cam.ppu, -- 1169
			self.animTime * 13.5, -- 1170
			false -- 1171
		) -- 1171
	end -- 1171
	if p.hasBottle and p.aimHold > 0 then -- 1171
		local pl = p.player -- 1177
		local endX = p.bottleAimX -- 1178
		local endY = p.bottleAimY -- 1179
		if endX < 0 then -- 1179
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 1181
			endX = wAim.x -- 1182
			endY = 0 -- 1183
		end -- 1183
		local dir = endX >= pl.x and 1 or -1 -- 1185
		local x0 = pl.x + dir * 10 -- 1186
		local y0 = pl.y + pl.h * 0.7 -- 1187
		local vx = (endX - x0) / BOTTLE_FLY_T -- 1188
		local vy = (endY - y0 + 0.5 * GRAVITY * BOTTLE_FLY_T * BOTTLE_FLY_T) / BOTTLE_FLY_T -- 1189
		local previewSurface = self:classifyLandingSurface(p, endX) -- 1191
		local arcRgb = previewSurface == "iron" and rgba(214, 228, 242, 255) or (previewSurface == "brick" and rgba(232, 206, 152, 255) or rgba(154, 142, 126, 255)) -- 1192
		local steps = 18 -- 1198
		local k = 1 -- 1199
		do -- 1199
			k = 1 -- 1200
			while k <= steps do -- 1200
				local tt = k / steps * BOTTLE_FLY_T -- 1201
				local wx = x0 + vx * tt -- 1202
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 1203
				local alpha = 195 * (0.4 + 0.6 * (k / steps)) -- 1204
				fgDraw:drawDot( -- 1205
					Vec2( -- 1205
						cam:sx(wx), -- 1205
						cam:sy(wy) -- 1205
					), -- 1205
					2.5, -- 1205
					toColor(arcRgb, alpha) -- 1205
				) -- 1205
				fgGlow:drawDot( -- 1206
					Vec2( -- 1206
						cam:sx(wx), -- 1206
						cam:sy(wy) -- 1206
					), -- 1206
					3.2, -- 1206
					toColor(arcRgb, alpha * 0.55) -- 1206
				) -- 1206
				k = k + 1 -- 1200
			end -- 1200
		end -- 1200
		local lx = cam:sx(endX) -- 1209
		local ly = cam:sy(endY + 2) -- 1210
		local pulse = 0.88 + 0.12 * math.sin(self.animTime * 5.2) -- 1211
		drawEllipseRing( -- 1212
			fgDraw, -- 1212
			lx, -- 1212
			ly, -- 1212
			11 * pulse, -- 1212
			4.2 * pulse, -- 1212
			1.6, -- 1212
			toColor(arcRgb, 235), -- 1212
			20 -- 1212
		) -- 1212
		if previewSurface == "iron" then -- 1212
			drawEllipseRing( -- 1214
				fgGlow, -- 1214
				lx, -- 1214
				ly, -- 1214
				24 * pulse, -- 1214
				9.2 * pulse, -- 1214
				1.3, -- 1214
				toColor(arcRgb, 195), -- 1214
				22 -- 1214
			) -- 1214
		elseif previewSurface == "brick" then -- 1214
			drawEllipseRing( -- 1216
				fgGlow, -- 1216
				lx, -- 1216
				ly, -- 1216
				18 * pulse, -- 1216
				7 * pulse, -- 1216
				1.2, -- 1216
				toColor(arcRgb, 165), -- 1216
				20 -- 1216
			) -- 1216
		end -- 1216
	end -- 1216
	return true -- 1220
end -- 1131
function VillageUndertableScene.prototype.drawCeramicBottle(self, fgDraw, fgGlow, worldArt, id, cx, cy, ppu, tilt, shelfGlint) -- 1223
	local size = math.max(12, ppu * 13) -- 1234
	if not worldArt:tryPlace( -- 1234
		"prop_bottle", -- 1235
		id, -- 1235
		cx, -- 1235
		cy, -- 1235
		size, -- 1235
		size, -- 1235
		{angle = tilt * 180 / math.pi, layer = 8} -- 1235
	) then -- 1235
		fgDraw:drawCircle( -- 1239
			Vec2(cx, cy), -- 1239
			size * 0.36, -- 1239
			Color(172, 138, 102, 245) -- 1239
		) -- 1239
	end -- 1239
	if shelfGlint then -- 1239
		local p = 0.72 + 0.28 * math.sin(self.animTime * 3) -- 1242
		fillRadialGlow( -- 1243
			fgGlow, -- 1243
			cx, -- 1243
			cy + 2, -- 1243
			14 * p, -- 1243
			14 * p, -- 1243
			Color( -- 1243
				224, -- 1243
				214, -- 1243
				190, -- 1243
				math.floor(62 * p + 0.5) -- 1243
			), -- 1243
			Color(224, 214, 190, 0), -- 1243
			12 -- 1243
		) -- 1243
	end -- 1243
end -- 1223
function VillageUndertableScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1248
	local p = ctx.p -- 1254
	local cam = ctx.cam -- 1255
	if p.room.scavenger ~= nil then -- 1255
		self:drawScavengerShoeOverlay(fgDraw, fgGlow, p, cam) -- 1257
	end -- 1257
	if ctx.paused then -- 1257
		local arch = p.room.arch -- 1262
		local pTopL = projectWorld3D( -- 1263
			arch.x0 - 160, -- 1263
			arch.h + 18, -- 1263
			-68, -- 1263
			cam, -- 1263
			self.proj -- 1263
		) -- 1263
		local pTopR = projectWorld3D( -- 1264
			arch.x1 + 95, -- 1264
			arch.h + 18, -- 1264
			-68, -- 1264
			cam, -- 1264
			self.proj -- 1264
		) -- 1264
		worldArt:tryPlace( -- 1265
			"cover_wood", -- 1266
			"fe04_pause_table_top", -- 1267
			(pTopL.x + pTopR.x) * 0.5, -- 1268
			pTopL.y, -- 1269
			math.max( -- 1270
				20, -- 1270
				math.abs(pTopR.x - pTopL.x) -- 1270
			), -- 1270
			math.max(40, cam.viewH - pTopL.y + 40), -- 1271
			{ -- 1272
				color = Color(24, 18, 15, 255), -- 1272
				opacity = 0.96, -- 1272
				layer = 5300 -- 1272
			} -- 1272
		) -- 1272
		local legBL = projectWorld3D( -- 1274
			arch.x1 - 8, -- 1274
			-28, -- 1274
			-66, -- 1274
			cam, -- 1274
			self.proj -- 1274
		) -- 1274
		local legTR = projectWorld3D( -- 1275
			arch.x1 + 14, -- 1275
			arch.h + 24, -- 1275
			-66, -- 1275
			cam, -- 1275
			self.proj -- 1275
		) -- 1275
		worldArt:tryPlace( -- 1276
			"cover_wood", -- 1277
			"fe04_pause_table_leg", -- 1278
			(legBL.x + legTR.x) * 0.5, -- 1279
			legBL.y, -- 1280
			math.max( -- 1281
				12, -- 1281
				math.abs(legTR.x - legBL.x) -- 1281
			), -- 1281
			math.max( -- 1282
				40, -- 1282
				math.abs(legTR.y - legBL.y) -- 1282
			), -- 1282
			{ -- 1283
				color = Color(22, 16, 13, 255), -- 1283
				opacity = 0.96, -- 1283
				layer = 5310 -- 1283
			} -- 1283
		) -- 1283
	end -- 1283
end -- 1248
function VillageUndertableScene.prototype.drawScavengerShoeOverlay(self, fgDraw, fgGlow, p, cam) -- 1288
	local cx = cam:sx(p.scavX) -- 1294
	local by = cam:sy(p.room.scavenger ~= nil and p.room.scavenger.y or 0) -- 1295
	local f = self.shoeFacing >= 0 and 1 or -1 -- 1296
	local moving = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 1297
	local stride = moving and math.sin(self.scavStridePhase) * cam:len(7.2) or 0 -- 1298
	local pausedToe = self.shoeToePauseTimer > 0 -- 1299
	fillRadialGlow( -- 1302
		fgGlow, -- 1302
		cx + f * cam:len(4), -- 1302
		by + 2, -- 1302
		cam:len(32), -- 1302
		cam:len(8), -- 1302
		Color(196, 208, 220, 48), -- 1302
		Color(156, 172, 190, 0), -- 1302
		14 -- 1302
	) -- 1302
	fgDraw:drawEllipse( -- 1303
		Vec2( -- 1303
			cx + f * cam:len(2), -- 1303
			by + 1 -- 1303
		), -- 1303
		cam:len(19), -- 1303
		cam:len(3.4), -- 1303
		Color(92, 102, 114, 72) -- 1303
	) -- 1303
	local function drawSingleShoe(footX, liftY, isFront) -- 1306
		local heelX = footX - f * cam:len(4.8) -- 1307
		local midX = footX + f * cam:len(1.8) -- 1308
		local toeX = footX + f * cam:len(7.6) -- 1309
		local soleY = by + 0.8 + liftY -- 1310
		local shoeH = cam:len(4.4) -- 1311
		fgDraw:drawPolygon( -- 1313
			{ -- 1313
				Vec2(heelX, soleY), -- 1314
				Vec2(toeX, soleY), -- 1315
				Vec2( -- 1316
					toeX - f * cam:len(1), -- 1316
					soleY + shoeH * 0.56 -- 1316
				), -- 1316
				Vec2(midX, soleY + shoeH * 0.96), -- 1317
				Vec2( -- 1318
					heelX + f * cam:len(0.6), -- 1318
					soleY + shoeH * 0.86 -- 1318
				) -- 1318
			}, -- 1318
			isFront and Color(68, 58, 48, 250) or Color(46, 40, 34, 240) -- 1319
		) -- 1319
		local soleCol = isFront and Color(198, 192, 178, 232) or Color(148, 144, 134, 195) -- 1321
		fgDraw:drawSegment( -- 1322
			Vec2(heelX, soleY + 0.6), -- 1322
			Vec2(toeX, soleY + 0.6), -- 1322
			1.5, -- 1322
			soleCol -- 1322
		) -- 1322
		fgDraw:drawSegment( -- 1324
			Vec2( -- 1324
				toeX - f * cam:len(1.2), -- 1324
				soleY + 0.8 -- 1324
			), -- 1324
			Vec2( -- 1324
				toeX - f * cam:len(1.4), -- 1324
				soleY + shoeH * 0.56 -- 1324
			), -- 1324
			1.3, -- 1324
			Color(214, 210, 198, isFront and 220 or 165) -- 1324
		) -- 1324
		if isFront and pausedToe then -- 1324
			fgGlow:drawDot( -- 1327
				Vec2(toeX, soleY + 1.5), -- 1327
				3, -- 1327
				Color(236, 218, 178, 155) -- 1327
			) -- 1327
		end -- 1327
	end -- 1306
	local backLift = moving and math.max( -- 1331
		0, -- 1331
		-math.sin(self.scavStridePhase) -- 1331
	) * cam:len(2.4) or 0 -- 1331
	local frontLift = moving and math.max( -- 1332
		0, -- 1332
		math.sin(self.scavStridePhase) -- 1332
	) * cam:len(2.8) or 0 -- 1332
	drawSingleShoe( -- 1333
		cx - stride - f * cam:len(3.5), -- 1333
		backLift, -- 1333
		false -- 1333
	) -- 1333
	drawSingleShoe( -- 1334
		cx + stride + f * cam:len(4), -- 1334
		frontLift, -- 1334
		true -- 1334
	) -- 1334
end -- 1288
function VillageUndertableScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 1343
	local p = ctx.p -- 1350
	local cam = ctx.cam -- 1351
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1352
	local arch = p.room.arch -- 1353
	local tableBottomY = arch.h + 18 + (1 - self.underTableFocus) * 12 -- 1357
	local slabThick = 24 -- 1358
	local apronTopY = tableBottomY + slabThick -- 1359
	local xLeft = p.ox - 80 -- 1360
	local xRight = arch.x1 + 52 -- 1361
	local bFarL = projectWorld3D( -- 1364
		xLeft, -- 1364
		tableBottomY - 4, -- 1364
		-18, -- 1364
		cam, -- 1364
		self.proj -- 1364
	) -- 1364
	local bFarR = projectWorld3D( -- 1365
		xRight, -- 1365
		tableBottomY - 4, -- 1365
		-18, -- 1365
		cam, -- 1365
		self.proj -- 1365
	) -- 1365
	local bNearR = projectWorld3D( -- 1366
		xRight, -- 1366
		tableBottomY + 4, -- 1366
		-74, -- 1366
		cam, -- 1366
		self.proj -- 1366
	) -- 1366
	local bNearL = projectWorld3D( -- 1367
		xLeft, -- 1367
		tableBottomY + 4, -- 1367
		-74, -- 1367
		cam, -- 1367
		self.proj -- 1367
	) -- 1367
	drawUiQuad( -- 1368
		uiDraw, -- 1368
		bFarL, -- 1368
		bFarR, -- 1368
		bNearR, -- 1368
		bNearL, -- 1368
		Color(16, 12, 10, 242), -- 1368
		Color(32, 24, 19, 248), -- 1368
		inv, -- 1368
		Color(88, 68, 52, 125), -- 1368
		1 -- 1368
	) -- 1368
	local beamIdx = 0 -- 1370
	do -- 1370
		beamIdx = 0 -- 1371
		while beamIdx < 4 do -- 1371
			local bx = xLeft + 110 + beamIdx * 105 -- 1372
			local p0 = projectWorld3D( -- 1373
				bx, -- 1373
				tableBottomY - 3, -- 1373
				-18, -- 1373
				cam, -- 1373
				self.proj -- 1373
			) -- 1373
			local p1 = projectWorld3D( -- 1374
				bx, -- 1374
				tableBottomY + 3, -- 1374
				-74, -- 1374
				cam, -- 1374
				self.proj -- 1374
			) -- 1374
			uiDraw:drawSegment( -- 1375
				Vec2(p0.x * inv, p0.y * inv), -- 1375
				Vec2(p1.x * inv, p1.y * inv), -- 1375
				1.2, -- 1375
				Color(56, 42, 32, 155) -- 1375
			) -- 1375
			beamIdx = beamIdx + 1 -- 1371
		end -- 1371
	end -- 1371
	local fBotL = bNearL -- 1379
	local fBotR = bNearR -- 1380
	local fTopR = projectWorld3D( -- 1381
		xRight, -- 1381
		apronTopY, -- 1381
		-74, -- 1381
		cam, -- 1381
		self.proj -- 1381
	) -- 1381
	local fTopL = projectWorld3D( -- 1382
		xLeft, -- 1382
		apronTopY, -- 1382
		-74, -- 1382
		cam, -- 1382
		self.proj -- 1382
	) -- 1382
	drawUiQuad( -- 1383
		uiDraw, -- 1383
		fBotL, -- 1383
		fBotR, -- 1383
		fTopR, -- 1383
		fTopL, -- 1383
		Color(34, 25, 19, 252), -- 1383
		Color(54, 40, 30, 254), -- 1383
		inv, -- 1383
		Color(118, 94, 72, 145), -- 1383
		1.1 -- 1383
	) -- 1383
	local fMidL = projectWorld3D( -- 1384
		xLeft, -- 1384
		tableBottomY + slabThick * 0.52, -- 1384
		-74, -- 1384
		cam, -- 1384
		self.proj -- 1384
	) -- 1384
	local fMidR = projectWorld3D( -- 1385
		xRight, -- 1385
		tableBottomY + slabThick * 0.52, -- 1385
		-74, -- 1385
		cam, -- 1385
		self.proj -- 1385
	) -- 1385
	uiDraw:drawSegment( -- 1386
		Vec2(fMidL.x * inv, fMidL.y * inv), -- 1386
		Vec2(fMidR.x * inv, fMidR.y * inv), -- 1386
		0.9, -- 1386
		Color(18, 13, 10, 195) -- 1386
	) -- 1386
	uiDraw:drawSegment( -- 1388
		Vec2(fBotL.x * inv, fBotL.y * inv), -- 1389
		Vec2(fBotR.x * inv, fBotR.y * inv), -- 1390
		1.6, -- 1391
		Color(148, 126, 104, 185) -- 1392
	) -- 1392
	local roofBotY = apronTopY + 56 -- 1396
	local roofTopY = apronTopY + 150 -- 1397
	local rBL = projectWorld3D( -- 1398
		xLeft, -- 1398
		roofBotY, -- 1398
		-74, -- 1398
		cam, -- 1398
		self.proj -- 1398
	) -- 1398
	local rBR = projectWorld3D( -- 1399
		xRight, -- 1399
		roofBotY, -- 1399
		-74, -- 1399
		cam, -- 1399
		self.proj -- 1399
	) -- 1399
	local rTR = projectWorld3D( -- 1400
		xRight, -- 1400
		roofTopY, -- 1400
		-74, -- 1400
		cam, -- 1400
		self.proj -- 1400
	) -- 1400
	local rTL = projectWorld3D( -- 1401
		xLeft, -- 1401
		roofTopY, -- 1401
		-74, -- 1401
		cam, -- 1401
		self.proj -- 1401
	) -- 1401
	drawUiQuad( -- 1402
		uiDraw, -- 1402
		rBL, -- 1402
		rBR, -- 1402
		rTR, -- 1402
		rTL, -- 1402
		Color(10, 9, 12, 165), -- 1402
		Color(7, 7, 10, 248), -- 1402
		inv -- 1402
	) -- 1402
	local topBackL = projectWorld3D( -- 1404
		xLeft, -- 1404
		apronTopY + 12, -- 1404
		-24, -- 1404
		cam, -- 1404
		self.proj -- 1404
	) -- 1404
	local topBackR = projectWorld3D( -- 1405
		xRight, -- 1405
		apronTopY + 12, -- 1405
		-24, -- 1405
		cam, -- 1405
		self.proj -- 1405
	) -- 1405
	drawUiQuad( -- 1406
		uiDraw, -- 1406
		fTopL, -- 1406
		fTopR, -- 1406
		topBackR, -- 1406
		topBackL, -- 1406
		Color(44, 34, 26, 238), -- 1406
		Color(22, 18, 16, 224), -- 1406
		inv, -- 1406
		Color(128, 108, 88, 130), -- 1406
		0.9 -- 1406
	) -- 1406
	local bowlBL = projectWorld3D( -- 1408
		arch.x0 + 4, -- 1408
		apronTopY + 2, -- 1408
		-56, -- 1408
		cam, -- 1408
		self.proj -- 1408
	) -- 1408
	local bowlBR = projectWorld3D( -- 1409
		arch.x0 + 34, -- 1409
		apronTopY + 2, -- 1409
		-56, -- 1409
		cam, -- 1409
		self.proj -- 1409
	) -- 1409
	local bowlTR = projectWorld3D( -- 1410
		arch.x0 + 38, -- 1410
		apronTopY + 16, -- 1410
		-56, -- 1410
		cam, -- 1410
		self.proj -- 1410
	) -- 1410
	local bowlTL = projectWorld3D( -- 1411
		arch.x0, -- 1411
		apronTopY + 16, -- 1411
		-56, -- 1411
		cam, -- 1411
		self.proj -- 1411
	) -- 1411
	drawUiQuad( -- 1412
		uiDraw, -- 1412
		bowlBL, -- 1412
		bowlBR, -- 1412
		bowlTR, -- 1412
		bowlTL, -- 1412
		Color(62, 58, 54, 242), -- 1412
		Color(108, 104, 98, 244), -- 1412
		inv, -- 1412
		Color(168, 162, 152, 170), -- 1412
		0.9 -- 1412
	) -- 1412
	local clothDropL = projectWorld3D( -- 1415
		arch.x0 - 20, -- 1415
		tableBottomY - 12, -- 1415
		-70, -- 1415
		cam, -- 1415
		self.proj -- 1415
	) -- 1415
	local clothDropMid = projectWorld3D( -- 1416
		arch.x0 + 48, -- 1416
		tableBottomY - 4, -- 1416
		-70, -- 1416
		cam, -- 1416
		self.proj -- 1416
	) -- 1416
	uiDraw:drawVertices({ -- 1417
		{ -- 1418
			Vec2(bNearL.x * inv, bNearL.y * inv), -- 1418
			Color(22, 18, 17, 228) -- 1418
		}, -- 1418
		{ -- 1419
			Vec2(clothDropL.x * inv, clothDropL.y * inv), -- 1419
			Color(32, 26, 24, 214) -- 1419
		}, -- 1419
		{ -- 1420
			Vec2(clothDropMid.x * inv, clothDropMid.y * inv), -- 1420
			Color(24, 20, 18, 205) -- 1420
		} -- 1420
	}) -- 1420
	local legX0 = arch.x1 - 2 -- 1424
	local legX1 = arch.x1 + 12 -- 1425
	local legBotY = -36 -- 1426
	local legTopY = apronTopY -- 1427
	local sBL = projectWorld3D( -- 1430
		legX1, -- 1430
		legBotY, -- 1430
		-72, -- 1430
		cam, -- 1430
		self.proj -- 1430
	) -- 1430
	local sBR = projectWorld3D( -- 1431
		legX1, -- 1431
		legBotY, -- 1431
		-50, -- 1431
		cam, -- 1431
		self.proj -- 1431
	) -- 1431
	local sTR = projectWorld3D( -- 1432
		legX1, -- 1432
		legTopY, -- 1432
		-50, -- 1432
		cam, -- 1432
		self.proj -- 1432
	) -- 1432
	local sTL = projectWorld3D( -- 1433
		legX1, -- 1433
		legTopY, -- 1433
		-72, -- 1433
		cam, -- 1433
		self.proj -- 1433
	) -- 1433
	drawUiQuad( -- 1434
		uiDraw, -- 1434
		sBL, -- 1434
		sBR, -- 1434
		sTR, -- 1434
		sTL, -- 1434
		Color(42, 32, 24, 250), -- 1434
		Color(68, 52, 38, 252), -- 1434
		inv, -- 1434
		Color(142, 122, 102, 165), -- 1434
		1 -- 1434
	) -- 1434
	local mBL = projectWorld3D( -- 1437
		legX0, -- 1437
		legBotY, -- 1437
		-72, -- 1437
		cam, -- 1437
		self.proj -- 1437
	) -- 1437
	local mBR = sBL -- 1438
	local mTR = sTL -- 1439
	local mTL = projectWorld3D( -- 1440
		legX0, -- 1440
		legTopY, -- 1440
		-72, -- 1440
		cam, -- 1440
		self.proj -- 1440
	) -- 1440
	drawUiQuad( -- 1441
		uiDraw, -- 1441
		mBL, -- 1441
		mBR, -- 1441
		mTR, -- 1441
		mTL, -- 1441
		Color(18, 14, 11, 254), -- 1441
		Color(30, 23, 18, 254), -- 1441
		inv, -- 1441
		Color(76, 58, 44, 125), -- 1441
		0.9 -- 1441
	) -- 1441
	local grainB = projectWorld3D( -- 1442
		(legX0 + legX1) * 0.5, -- 1442
		legBotY, -- 1442
		-72, -- 1442
		cam, -- 1442
		self.proj -- 1442
	) -- 1442
	local grainT = projectWorld3D( -- 1443
		(legX0 + legX1) * 0.5, -- 1443
		legTopY, -- 1443
		-72, -- 1443
		cam, -- 1443
		self.proj -- 1443
	) -- 1443
	uiDraw:drawSegment( -- 1444
		Vec2(grainB.x * inv, grainB.y * inv), -- 1444
		Vec2(grainT.x * inv, grainT.y * inv), -- 1444
		0.8, -- 1444
		Color(46, 35, 26, 130) -- 1444
	) -- 1444
	uiDraw:drawSegment( -- 1447
		Vec2(sBR.x * inv, sBR.y * inv), -- 1448
		Vec2(sTR.x * inv, sTR.y * inv), -- 1449
		1.1, -- 1450
		Color(172, 166, 158, 165) -- 1451
	) -- 1451
	local lLegBL = projectWorld3D( -- 1455
		p.ox + 64, -- 1455
		-36, -- 1455
		-82, -- 1455
		cam, -- 1455
		self.proj -- 1455
	) -- 1455
	local lLegBR = projectWorld3D( -- 1456
		p.ox + 78, -- 1456
		-36, -- 1456
		-82, -- 1456
		cam, -- 1456
		self.proj -- 1456
	) -- 1456
	local lLegTR = projectWorld3D( -- 1457
		p.ox + 78, -- 1457
		apronTopY, -- 1457
		-82, -- 1457
		cam, -- 1457
		self.proj -- 1457
	) -- 1457
	local lLegTL = projectWorld3D( -- 1458
		p.ox + 64, -- 1458
		apronTopY, -- 1458
		-82, -- 1458
		cam, -- 1458
		self.proj -- 1458
	) -- 1458
	drawUiQuad( -- 1459
		uiDraw, -- 1459
		lLegBL, -- 1459
		lLegBR, -- 1459
		lLegTR, -- 1459
		lLegTL, -- 1459
		Color(12, 10, 10, 232), -- 1459
		Color(20, 16, 14, 238), -- 1459
		inv -- 1459
	) -- 1459
	return false -- 1462
end -- 1343
return ____exports -- 1343