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
		x1 = ox + 101, -- 728
		y0 = 0, -- 729
		y1 = 52, -- 730
		z0 = -6, -- 731
		z1 = 24, -- 732
		material = MAT_TABLE_WOOD, -- 733
		bucket = LP_BUCKET.WALK_DECK, -- 734
		edgeWidth = 0.8 -- 735
	}) -- 735
	scene:addBox({ -- 737
		x0 = ox + 123, -- 738
		x1 = ox + 128, -- 739
		y0 = 0, -- 740
		y1 = 52, -- 741
		z0 = -6, -- 742
		z1 = 24, -- 743
		material = MAT_TABLE_WOOD, -- 744
		bucket = LP_BUCKET.WALK_DECK, -- 745
		edgeWidth = 0.8 -- 746
	}) -- 746
	scene:addBox({ -- 748
		x0 = ox + 95, -- 749
		x1 = ox + 129, -- 750
		y0 = 24, -- 751
		y1 = 28, -- 752
		z0 = -8, -- 753
		z1 = 26, -- 754
		material = MING_MATERIALS.mingTimber, -- 755
		bucket = LP_BUCKET.WALK_DECK, -- 756
		sortBias = 0.05 -- 757
	}) -- 757
	scene:addBox({ -- 759
		x0 = ox + 94, -- 760
		x1 = ox + 130, -- 761
		y0 = 48, -- 762
		y1 = 52, -- 763
		z0 = -8, -- 764
		z1 = 26, -- 765
		material = MING_MATERIALS.mingTimber, -- 766
		bucket = LP_BUCKET.WALK_DECK, -- 767
		highlightTopEdge = true, -- 768
		sortBias = 0.06 -- 769
	}) -- 769
	scene:addBox({ -- 772
		x0 = ox + 672, -- 773
		x1 = ox + 720, -- 774
		y0 = 0, -- 775
		y1 = 96, -- 776
		z0 = -14, -- 777
		z1 = 96, -- 778
		material = MING_MATERIALS.mingBrick, -- 779
		bucket = LP_BUCKET.MIDGROUND, -- 780
		highlightTopEdge = true, -- 781
		edgeWidth = 0.9 -- 782
	}) -- 782
	scene:addBox({ -- 784
		x0 = ox + 666, -- 785
		x1 = ox + 726, -- 786
		y0 = 96, -- 787
		y1 = 106, -- 788
		z0 = -18, -- 789
		z1 = 100, -- 790
		material = MING_MATERIALS.mingTile, -- 791
		bucket = LP_BUCKET.MIDGROUND, -- 792
		sortBias = 0.08 -- 793
	}) -- 793
	local arch = p.room.arch -- 798
	scene:addBox({ -- 800
		x0 = arch.x0 - 1, -- 801
		x1 = arch.x0 + 7, -- 802
		y0 = 0, -- 803
		y1 = arch.h, -- 804
		z0 = 12, -- 805
		z1 = 22, -- 806
		material = MAT_TABLE_WOOD, -- 807
		bucket = LP_BUCKET.MIDGROUND, -- 808
		edgeWidth = 0.8 -- 809
	}) -- 809
	scene:addBox({ -- 811
		x0 = arch.x1 - 7, -- 812
		x1 = arch.x1 + 1, -- 813
		y0 = 0, -- 814
		y1 = arch.h, -- 815
		z0 = 12, -- 816
		z1 = 22, -- 817
		material = MAT_TABLE_WOOD, -- 818
		bucket = LP_BUCKET.MIDGROUND, -- 819
		edgeWidth = 0.8 -- 820
	}) -- 820
	scene:addBox({ -- 823
		x0 = arch.x0 + 7, -- 824
		x1 = arch.x1 - 7, -- 825
		y0 = arch.h - 5, -- 826
		y1 = arch.h, -- 827
		z0 = 14, -- 828
		z1 = 20, -- 829
		material = MAT_TABLE_WOOD, -- 830
		bucket = LP_BUCKET.MIDGROUND, -- 831
		edgeWidth = 0.6 -- 832
	}) -- 832
	scene:addBox({ -- 835
		x0 = arch.x0 - 8, -- 836
		x1 = arch.x1 + 8, -- 837
		y0 = arch.h, -- 838
		y1 = arch.h + 8, -- 839
		z0 = 4, -- 840
		z1 = 28, -- 841
		material = MAT_TABLE_WOOD, -- 842
		bucket = LP_BUCKET.WALK_DECK, -- 843
		highlightTopEdge = true, -- 844
		edgeWidth = 0.8 -- 845
	}) -- 845
	local culvertX = self:getCulvertWorldX(p) -- 849
	self:buildCulvertEntrance(scene, culvertX) -- 850
	local softX = self:getSoftWorldX(p) -- 854
	self:buildSoftDirtPatch(scene, softX) -- 855
	local brickX = self:getBrickWorldX(p) -- 858
	self:buildHardBrickPatch(scene, brickX) -- 859
	local basinX = self:getBasinWorldX(p) -- 862
	self:buildIronBasin(scene, basinX) -- 863
	scene:addLightShaft( -- 866
		ox + 570, -- 867
		ox + 710, -- 867
		290, -- 867
		ox + 446, -- 868
		ox + 642, -- 868
		0, -- 868
		24, -- 869
		rgba(218, 226, 218, 255), -- 870
		0.13, -- 871
		0.04 -- 872
	) -- 872
	scene:addContactShadow( -- 876
		p.player.x, -- 876
		p.player.y, -- 876
		14, -- 876
		10, -- 876
		0.8, -- 876
		{bucket = LP_BUCKET.PROP, sortBias = 0.4} -- 876
	) -- 876
	if p.room.scavenger ~= nil then -- 876
		scene:addContactShadow( -- 878
			p.scavX, -- 878
			p.room.scavenger.y, -- 878
			19, -- 878
			13, -- 878
			0.84, -- 878
			{bucket = LP_BUCKET.PROP, sortBias = 0.42} -- 878
		) -- 878
	end -- 878
	scene:flush(fgDraw, fgGlow) -- 881
	self:drawSurfaceReadabilityDetails( -- 884
		fgDraw, -- 884
		fgGlow, -- 884
		p, -- 884
		cam, -- 884
		softX, -- 884
		culvertX, -- 884
		basinX, -- 884
		brickX -- 884
	) -- 884
	return true -- 886
end -- 681
function VillageUndertableScene.prototype.buildCulvertEntrance(self, scene, cx) -- 889
	scene:addBox({ -- 891
		x0 = cx - 18, -- 892
		x1 = cx + 18, -- 893
		y0 = -12, -- 894
		y1 = 2, -- 895
		z0 = -6, -- 896
		z1 = 42, -- 897
		material = MAT_CULVERT_STONE, -- 898
		bucket = LP_BUCKET.WALK_DECK, -- 899
		highlightTopEdge = true, -- 900
		edgeWidth = 1 -- 901
	}) -- 901
	scene:addQuad3D( -- 904
		vec3(cx - 12, 1, 22), -- 905
		vec3(cx + 12, 1, 22), -- 906
		vec3(cx + 10, 26, 22), -- 907
		vec3(cx - 10, 26, 22), -- 908
		{base = rgba(6, 9, 14, 255)}, -- 909
		{ -- 910
			bucket = LP_BUCKET.MIDGROUND, -- 910
			unlit = true, -- 910
			sortBias = 0.35, -- 910
			edgeColor = rgba(186, 204, 222, 185), -- 910
			edgeWidth = 1.2 -- 910
		} -- 910
	) -- 910
	scene:addBox({ -- 913
		x0 = cx - 15, -- 914
		x1 = cx - 11, -- 915
		y0 = 2, -- 916
		y1 = 24, -- 917
		z0 = 14, -- 918
		z1 = 22, -- 919
		material = MING_MATERIALS.mingTimber, -- 920
		bucket = LP_BUCKET.PROP, -- 921
		highlightTopEdge = true -- 922
	}) -- 922
	local gi = 0 -- 924
	do -- 924
		gi = 0 -- 925
		while gi < 3 do -- 925
			local gx = cx - 6 + gi * 6 -- 926
			scene:addBox({ -- 927
				x0 = gx - 1, -- 928
				x1 = gx + 1, -- 929
				y0 = 2, -- 930
				y1 = 24, -- 931
				z0 = 18, -- 932
				z1 = 21, -- 933
				material = MING_MATERIALS.mingIron, -- 934
				bucket = LP_BUCKET.PROP, -- 935
				sortBias = 0.1 -- 936
			}) -- 936
			gi = gi + 1 -- 925
		end -- 925
	end -- 925
end -- 889
function VillageUndertableScene.prototype.buildSoftDirtPatch(self, scene, softX) -- 941
	scene:addBox({ -- 942
		x0 = softX - 24, -- 943
		x1 = softX + 24, -- 944
		y0 = -4, -- 945
		y1 = 1.5, -- 946
		z0 = -16, -- 947
		z1 = 28, -- 948
		material = MAT_SOFT_EARTH, -- 949
		bucket = LP_BUCKET.WALK_DECK, -- 950
		sortBias = 0.15, -- 951
		edgeWidth = 0.4 -- 952
	}) -- 952
end -- 941
function VillageUndertableScene.prototype.buildHardBrickPatch(self, scene, brickX) -- 956
	local col = 0 -- 958
	do -- 958
		col = 0 -- 959
		while col < 3 do -- 959
			local bx0 = brickX - 24 + col * 16 -- 960
			local bx1 = bx0 + 14.5 -- 961
			scene:addBox({ -- 962
				x0 = bx0, -- 963
				x1 = bx1, -- 964
				y0 = -4, -- 965
				y1 = 3.2, -- 966
				z0 = -14, -- 967
				z1 = 6, -- 968
				material = MAT_HARD_BRICK, -- 969
				bucket = LP_BUCKET.WALK_DECK, -- 970
				sortBias = 0.2 + col * 0.01, -- 971
				highlightTopEdge = true, -- 972
				edgeWidth = 1 -- 973
			}) -- 973
			scene:addBox({ -- 975
				x0 = bx0 + 4, -- 976
				x1 = bx1 + 4, -- 977
				y0 = -4, -- 978
				y1 = 2.8, -- 979
				z0 = 8, -- 980
				z1 = 26, -- 981
				material = MAT_HARD_BRICK, -- 982
				bucket = LP_BUCKET.WALK_DECK, -- 983
				sortBias = 0.18 + col * 0.01, -- 984
				highlightTopEdge = true, -- 985
				edgeWidth = 0.9 -- 986
			}) -- 986
			col = col + 1 -- 959
		end -- 959
	end -- 959
end -- 956
function VillageUndertableScene.prototype.buildIronBasin(self, scene, basinX) -- 991
	scene:addBox({ -- 993
		x0 = basinX - 14, -- 994
		x1 = basinX + 14, -- 995
		y0 = -2, -- 996
		y1 = 3, -- 997
		z0 = -10, -- 998
		z1 = 14, -- 999
		material = MING_MATERIALS.mingBrickDark, -- 1000
		bucket = LP_BUCKET.PROP, -- 1001
		sortBias = 0.02 -- 1002
	}) -- 1002
	local tilt = self.basinShakeAngle -- 1005
	local liftL = math.sin(tilt) * 14 -- 1006
	local liftR = -liftL -- 1007
	local shiftX = math.sin(tilt * 1.4) * 2.5 -- 1008
	local baseY = 3 -- 1009
	local topY = 14.5 -- 1010
	local bx = basinX + shiftX -- 1011
	scene:addQuad3D( -- 1014
		vec3( -- 1015
			bx - 11, -- 1015
			baseY + math.max(0, liftL * 0.4), -- 1015
			-8 -- 1015
		), -- 1015
		vec3( -- 1016
			bx + 11, -- 1016
			baseY + math.max(0, liftR * 0.4), -- 1016
			-8 -- 1016
		), -- 1016
		vec3(bx + 16, topY + liftR, -12), -- 1017
		vec3(bx - 16, topY + liftL, -12), -- 1018
		MAT_IRON_BASIN, -- 1019
		{bucket = LP_BUCKET.PROP, sortBias = 0.25, edgeWidth = 1.2} -- 1020
	) -- 1020
	scene:addQuad3D( -- 1023
		vec3( -- 1024
			bx - 11, -- 1024
			baseY + math.max(0, liftL * 0.4), -- 1024
			10 -- 1024
		), -- 1024
		vec3( -- 1025
			bx - 11, -- 1025
			baseY + math.max(0, liftL * 0.4), -- 1025
			-8 -- 1025
		), -- 1025
		vec3(bx - 16, topY + liftL, -12), -- 1026
		vec3(bx - 16, topY + liftL, 14), -- 1027
		MAT_IRON_BASIN, -- 1028
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1029
	) -- 1029
	scene:addQuad3D( -- 1031
		vec3( -- 1032
			bx + 11, -- 1032
			baseY + math.max(0, liftR * 0.4), -- 1032
			-8 -- 1032
		), -- 1032
		vec3( -- 1033
			bx + 11, -- 1033
			baseY + math.max(0, liftR * 0.4), -- 1033
			10 -- 1033
		), -- 1033
		vec3(bx + 16, topY + liftR, 14), -- 1034
		vec3(bx + 16, topY + liftR, -12), -- 1035
		MAT_IRON_BASIN, -- 1036
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1037
	) -- 1037
	scene:addQuad3D( -- 1040
		vec3(bx - 14, topY - 1 + liftL, -10), -- 1041
		vec3(bx + 14, topY - 1 + liftR, -10), -- 1042
		vec3(bx + 14, topY - 1 + liftR, 12), -- 1043
		vec3(bx - 14, topY - 1 + liftL, 12), -- 1044
		{ -- 1045
			base = rgba(24, 30, 40, 255), -- 1045
			edge = rgba(232, 238, 246, 235) -- 1045
		}, -- 1045
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 1.5} -- 1046
	) -- 1046
end -- 991
function VillageUndertableScene.prototype.drawSurfaceReadabilityDetails(self, fgDraw, fgGlow, p, cam, softX, culvertX, basinX, brickX) -- 1050
	local y0 = cam:sy(0) -- 1060
	local sx0 = cam:sx(softX - 20) -- 1063
	local sx1 = cam:sx(softX + 20) -- 1064
	local d = 0 -- 1065
	do -- 1065
		d = 0 -- 1066
		while d < 9 do -- 1066
			local dx = sx0 + (sx1 - sx0) * (d + 0.5) / 9 -- 1067
			local dy = y0 - 2.5 + (d % 3 - 1) * 1.8 -- 1068
			fgDraw:drawDot( -- 1069
				Vec2(dx, dy), -- 1069
				1.3, -- 1069
				Color(116, 98, 78, 175) -- 1069
			) -- 1069
			d = d + 1 -- 1066
		end -- 1066
	end -- 1066
	fgDraw:drawEllipse( -- 1071
		Vec2( -- 1071
			cam:sx(softX - 7), -- 1071
			y0 - 1.5 -- 1071
		), -- 1071
		cam:len(4.2), -- 1071
		1.6, -- 1071
		Color(38, 30, 24, 185) -- 1071
	) -- 1071
	fgDraw:drawEllipse( -- 1072
		Vec2( -- 1072
			cam:sx(softX + 8), -- 1072
			y0 - 2 -- 1072
		), -- 1072
		cam:len(4.2), -- 1072
		1.6, -- 1072
		Color(38, 30, 24, 185) -- 1072
	) -- 1072
	local cL = cam:sx(culvertX - 11) -- 1075
	local cR = cam:sx(culvertX + 11) -- 1076
	local cTop = cam:sy(25) -- 1077
	fgDraw:drawSegment( -- 1078
		Vec2(cL, cTop), -- 1078
		Vec2(cR, cTop), -- 1078
		1.6, -- 1078
		Color(196, 210, 224, 210) -- 1078
	) -- 1078
	local rippleShift = math.sin(self.animTime * 2.3) * 3 -- 1079
	fgGlow:drawSegment( -- 1080
		Vec2(cL + 3 + rippleShift, y0 + 2), -- 1080
		Vec2(cR - 4 + rippleShift, y0 + 2), -- 1080
		1.1, -- 1080
		Color(164, 192, 214, 105) -- 1080
	) -- 1080
	local bPtL = projectWorld3D( -- 1083
		basinX - 16, -- 1083
		14.5 + math.sin(self.basinShakeAngle) * 14, -- 1083
		-12, -- 1083
		cam, -- 1083
		self.proj -- 1083
	) -- 1083
	local bPtR = projectWorld3D( -- 1084
		basinX + 16, -- 1084
		14.5 - math.sin(self.basinShakeAngle) * 14, -- 1084
		-12, -- 1084
		cam, -- 1084
		self.proj -- 1084
	) -- 1084
	local shakeBoost = self.basinShakeTimer > 0 and clamp01(self.basinShakeTimer / self.basinShakeMax) or 0 -- 1085
	local rimAlpha = math.floor(205 + 48 * shakeBoost + 0.5) -- 1086
	fgDraw:drawSegment( -- 1087
		Vec2(bPtL.x, bPtL.y), -- 1087
		Vec2(bPtR.x, bPtR.y), -- 1087
		2.1 + shakeBoost * 1.1, -- 1087
		Color(230, 236, 242, rimAlpha) -- 1087
	) -- 1087
	fillRadialGlow( -- 1088
		fgGlow, -- 1089
		(bPtL.x + bPtR.x) * 0.5, -- 1090
		(bPtL.y + bPtR.y) * 0.5, -- 1091
		cam:len(22 + shakeBoost * 18), -- 1092
		cam:len(10 + shakeBoost * 8), -- 1093
		Color( -- 1094
			216, -- 1094
			226, -- 1094
			236, -- 1094
			math.floor(48 + 95 * shakeBoost + 0.5) -- 1094
		), -- 1094
		Color(186, 202, 220, 0), -- 1095
		14 -- 1096
	) -- 1096
	local brL = cam:sx(brickX - 24) -- 1100
	local brR = cam:sx(brickX + 24) -- 1101
	local brTop = cam:sy(3.2) -- 1102
	fgDraw:drawSegment( -- 1103
		Vec2(brL, brTop), -- 1103
		Vec2(brR, brTop), -- 1103
		1.8, -- 1103
		Color(224, 228, 234, 225) -- 1103
	) -- 1103
	local k = 1 -- 1104
	do -- 1104
		k = 1 -- 1105
		while k <= 2 do -- 1105
			local seamX = brL + (brR - brL) * k / 3 -- 1106
			fgDraw:drawSegment( -- 1107
				Vec2(seamX, y0 - 3), -- 1107
				Vec2(seamX, brTop + 1), -- 1107
				1.5, -- 1107
				Color(20, 24, 32, 240) -- 1107
			) -- 1107
			fgDraw:drawSegment( -- 1108
				Vec2(seamX + 1.8, y0 - 2), -- 1108
				Vec2(seamX + 1.8, brTop), -- 1108
				0.9, -- 1108
				Color(214, 218, 224, 175) -- 1108
			) -- 1108
			k = k + 1 -- 1105
		end -- 1105
	end -- 1105
	local i = 0 -- 1112
	do -- 1112
		i = 0 -- 1113
		while i < #self.rings do -- 1113
			do -- 1113
				local rg = self.rings[i + 1] -- 1114
				if rg.age < 0 then -- 1114
					goto __continue76 -- 1116
				end -- 1116
				local t = clamp01(rg.age / rg.duration) -- 1118
				local r = math.max( -- 1119
					4, -- 1119
					cam:len(rg.maxRadius) * (0.14 + 0.86 * t) -- 1119
				) -- 1119
				local alpha = (1 - t) * (rg.kind == "iron" and 0.88 or (rg.kind == "brick" and 0.82 or 0.4)) -- 1120
				local rx = cam:sx(rg.x) -- 1121
				local ry = cam:sy(rg.y) -- 1122
				local ringCol = rg.kind == "iron" and Color( -- 1123
					220, -- 1124
					234, -- 1124
					246, -- 1124
					math.floor(235 * alpha + 0.5) -- 1124
				) or (rg.kind == "brick" and Color( -- 1124
					236, -- 1126
					216, -- 1126
					178, -- 1126
					math.floor(225 * alpha + 0.5) -- 1126
				) or Color( -- 1126
					148, -- 1127
					134, -- 1127
					114, -- 1127
					math.floor(165 * alpha + 0.5) -- 1127
				)) -- 1127
				drawEllipseRing( -- 1128
					fgGlow, -- 1128
					rx, -- 1128
					ry, -- 1128
					r, -- 1128
					r * 0.34, -- 1128
					rg.kind == "iron" and 1.8 or 1.4, -- 1128
					ringCol, -- 1128
					22 -- 1128
				) -- 1128
				if rg.kind == "iron" then -- 1128
					drawEllipseRing( -- 1130
						fgDraw, -- 1130
						rx, -- 1130
						ry, -- 1130
						r * 0.96, -- 1130
						r * 0.32, -- 1130
						1.1, -- 1130
						Color( -- 1130
							214, -- 1130
							224, -- 1130
							236, -- 1130
							math.floor(150 * alpha + 0.5) -- 1130
						), -- 1130
						22 -- 1130
					) -- 1130
				end -- 1130
			end -- 1130
			::__continue76:: -- 1130
			i = i + 1 -- 1113
		end -- 1113
	end -- 1113
	do -- 1113
		i = 0 -- 1133
		while i < #self.shards do -- 1133
			local sp = self.shards[i + 1] -- 1134
			local a = clamp01(sp.life / sp.maxLife) -- 1135
			local col = sp.kind == "soft" and Color( -- 1136
				138, -- 1137
				120, -- 1137
				98, -- 1137
				math.floor(170 * a + 0.5) -- 1137
			) or (sp.kind == "iron" and Color( -- 1137
				224, -- 1139
				232, -- 1139
				242, -- 1139
				math.floor(225 * a + 0.5) -- 1139
			) or Color( -- 1139
				216, -- 1140
				198, -- 1140
				174, -- 1140
				math.floor(220 * a + 0.5) -- 1140
			)) -- 1140
			fgDraw:drawDot( -- 1141
				Vec2( -- 1141
					cam:sx(sp.x), -- 1141
					cam:sy(sp.y) -- 1141
				), -- 1141
				sp.size, -- 1141
				col -- 1141
			) -- 1141
			i = i + 1 -- 1133
		end -- 1133
	end -- 1133
	if p.bottleLandT > 0 and p.bottleLandX >= 0 and #self.rings == 0 then -- 1133
		local rx = cam:sx(p.bottleLandX) -- 1146
		local ry = cam:sy(math.max(1, p.bottleLandY)) -- 1147
		fgDraw:drawDot( -- 1148
			Vec2(rx, ry), -- 1148
			2.5, -- 1148
			Color(216, 206, 186, 150) -- 1148
		) -- 1148
	end -- 1148
end -- 1050
function VillageUndertableScene.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1153
	local p = ctx.p -- 1159
	local cam = ctx.cam -- 1160
	local bottle = p.room.bottle -- 1163
	if bottle ~= nil and not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 1163
		self:drawCeramicBottle( -- 1165
			fgDraw, -- 1165
			fgGlow, -- 1165
			worldArt, -- 1165
			"fe04_bottle_shelf", -- 1165
			cam:sx(bottle.x), -- 1165
			cam:sy(56), -- 1165
			cam.ppu, -- 1165
			0, -- 1165
			true -- 1165
		) -- 1165
	end -- 1165
	if p.hasBottle and p.aimHold <= 0 then -- 1165
		local pl = p.player -- 1170
		self:drawCeramicBottle( -- 1171
			fgDraw, -- 1172
			fgGlow, -- 1173
			worldArt, -- 1174
			"fe04_bottle_held", -- 1175
			cam:sx(pl.x + pl.facing * 10), -- 1176
			cam:sy(pl.y + pl.h * 0.52), -- 1177
			cam.ppu, -- 1178
			pl.facing * 0.22, -- 1179
			false -- 1180
		) -- 1180
	end -- 1180
	if p.bottleFly ~= nil then -- 1180
		self:drawCeramicBottle( -- 1184
			fgDraw, -- 1185
			fgGlow, -- 1186
			worldArt, -- 1187
			"fe04_bottle_air", -- 1188
			cam:sx(p.bottleFly.x), -- 1189
			cam:sy(p.bottleFly.y), -- 1190
			cam.ppu, -- 1191
			self.animTime * 13.5, -- 1192
			false -- 1193
		) -- 1193
	end -- 1193
	if p.hasBottle and p.aimHold > 0 then -- 1193
		local pl = p.player -- 1199
		local endX = p.bottleAimX -- 1200
		local endY = p.bottleAimY -- 1201
		if endX < 0 then -- 1201
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 1203
			endX = wAim.x -- 1204
			endY = 0 -- 1205
		end -- 1205
		local dir = endX >= pl.x and 1 or -1 -- 1207
		local x0 = pl.x + dir * 10 -- 1208
		local y0 = pl.y + pl.h * 0.7 -- 1209
		local vx = (endX - x0) / BOTTLE_FLY_T -- 1210
		local vy = (endY - y0 + 0.5 * GRAVITY * BOTTLE_FLY_T * BOTTLE_FLY_T) / BOTTLE_FLY_T -- 1211
		local previewSurface = self:classifyLandingSurface(p, endX) -- 1213
		local arcRgb = previewSurface == "iron" and rgba(214, 228, 242, 255) or (previewSurface == "brick" and rgba(232, 206, 152, 255) or rgba(154, 142, 126, 255)) -- 1214
		local steps = 18 -- 1220
		local k = 1 -- 1221
		do -- 1221
			k = 1 -- 1222
			while k <= steps do -- 1222
				local tt = k / steps * BOTTLE_FLY_T -- 1223
				local wx = x0 + vx * tt -- 1224
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 1225
				local alpha = 195 * (0.4 + 0.6 * (k / steps)) -- 1226
				fgDraw:drawDot( -- 1227
					Vec2( -- 1227
						cam:sx(wx), -- 1227
						cam:sy(wy) -- 1227
					), -- 1227
					2.5, -- 1227
					toColor(arcRgb, alpha) -- 1227
				) -- 1227
				fgGlow:drawDot( -- 1228
					Vec2( -- 1228
						cam:sx(wx), -- 1228
						cam:sy(wy) -- 1228
					), -- 1228
					3.2, -- 1228
					toColor(arcRgb, alpha * 0.55) -- 1228
				) -- 1228
				k = k + 1 -- 1222
			end -- 1222
		end -- 1222
		local lx = cam:sx(endX) -- 1231
		local ly = cam:sy(endY + 2) -- 1232
		local pulse = 0.88 + 0.12 * math.sin(self.animTime * 5.2) -- 1233
		drawEllipseRing( -- 1234
			fgDraw, -- 1234
			lx, -- 1234
			ly, -- 1234
			11 * pulse, -- 1234
			4.2 * pulse, -- 1234
			1.6, -- 1234
			toColor(arcRgb, 235), -- 1234
			20 -- 1234
		) -- 1234
		if previewSurface == "iron" then -- 1234
			drawEllipseRing( -- 1236
				fgGlow, -- 1236
				lx, -- 1236
				ly, -- 1236
				24 * pulse, -- 1236
				9.2 * pulse, -- 1236
				1.3, -- 1236
				toColor(arcRgb, 195), -- 1236
				22 -- 1236
			) -- 1236
		elseif previewSurface == "brick" then -- 1236
			drawEllipseRing( -- 1238
				fgGlow, -- 1238
				lx, -- 1238
				ly, -- 1238
				18 * pulse, -- 1238
				7 * pulse, -- 1238
				1.2, -- 1238
				toColor(arcRgb, 165), -- 1238
				20 -- 1238
			) -- 1238
		end -- 1238
	end -- 1238
	return true -- 1242
end -- 1153
function VillageUndertableScene.prototype.drawCeramicBottle(self, fgDraw, fgGlow, worldArt, id, cx, cy, ppu, tilt, shelfGlint) -- 1245
	local size = math.max(10, ppu * 10.5) -- 1256
	if not worldArt:tryPlace( -- 1256
		"prop_bottle", -- 1257
		id, -- 1257
		cx, -- 1257
		cy, -- 1257
		size, -- 1257
		size, -- 1257
		{angle = tilt * 180 / math.pi, layer = 8} -- 1257
	) then -- 1257
		fgDraw:drawCircle( -- 1261
			Vec2(cx, cy), -- 1261
			size * 0.36, -- 1261
			Color(172, 138, 102, 245) -- 1261
		) -- 1261
	end -- 1261
	if shelfGlint then -- 1261
		local p = 0.72 + 0.28 * math.sin(self.animTime * 3) -- 1264
		fillRadialGlow( -- 1265
			fgGlow, -- 1265
			cx, -- 1265
			cy + 2, -- 1265
			14 * p, -- 1265
			14 * p, -- 1265
			Color( -- 1265
				224, -- 1265
				214, -- 1265
				190, -- 1265
				math.floor(62 * p + 0.5) -- 1265
			), -- 1265
			Color(224, 214, 190, 0), -- 1265
			12 -- 1265
		) -- 1265
	end -- 1265
end -- 1245
function VillageUndertableScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1270
	local p = ctx.p -- 1276
	local cam = ctx.cam -- 1277
	if p.room.scavenger ~= nil then -- 1277
		self:drawScavengerShoeOverlay(fgDraw, fgGlow, p, cam) -- 1279
	end -- 1279
	if ctx.paused then -- 1279
		local arch = p.room.arch -- 1284
		local pTopBL = projectWorld3D( -- 1285
			arch.x0 - 8, -- 1285
			arch.h, -- 1285
			-15, -- 1285
			cam, -- 1285
			self.proj -- 1285
		) -- 1285
		local pTopTR = projectWorld3D( -- 1286
			arch.x1 + 8, -- 1286
			arch.h + 8, -- 1286
			-15, -- 1286
			cam, -- 1286
			self.proj -- 1286
		) -- 1286
		worldArt:tryPlace( -- 1287
			"cover_wood", -- 1288
			"fe04_pause_table_top", -- 1289
			(pTopBL.x + pTopTR.x) * 0.5, -- 1290
			pTopBL.y, -- 1291
			math.max( -- 1292
				20, -- 1292
				math.abs(pTopTR.x - pTopBL.x) -- 1292
			), -- 1292
			math.max( -- 1293
				8, -- 1293
				math.abs(pTopTR.y - pTopBL.y) -- 1293
			), -- 1293
			{ -- 1294
				color = Color(46, 35, 27, 255), -- 1294
				opacity = 0.96, -- 1294
				layer = 5300 -- 1294
			} -- 1294
		) -- 1294
		local legBL = projectWorld3D( -- 1296
			arch.x1 - 6, -- 1296
			0, -- 1296
			-15, -- 1296
			cam, -- 1296
			self.proj -- 1296
		) -- 1296
		local legTR = projectWorld3D( -- 1297
			arch.x1 + 1, -- 1297
			arch.h, -- 1297
			-15, -- 1297
			cam, -- 1297
			self.proj -- 1297
		) -- 1297
		worldArt:tryPlace( -- 1298
			"cover_wood", -- 1299
			"fe04_pause_table_leg", -- 1300
			(legBL.x + legTR.x) * 0.5, -- 1301
			legBL.y, -- 1302
			math.max( -- 1303
				6, -- 1303
				math.abs(legTR.x - legBL.x) -- 1303
			), -- 1303
			math.max( -- 1304
				16, -- 1304
				math.abs(legTR.y - legBL.y) -- 1304
			), -- 1304
			{ -- 1305
				color = Color(34, 25, 19, 255), -- 1305
				opacity = 0.96, -- 1305
				layer = 5310 -- 1305
			} -- 1305
		) -- 1305
	end -- 1305
end -- 1270
function VillageUndertableScene.prototype.drawScavengerShoeOverlay(self, fgDraw, fgGlow, p, cam) -- 1310
	local cx = cam:sx(p.scavX) -- 1316
	local by = cam:sy(p.room.scavenger ~= nil and p.room.scavenger.y or 0) -- 1317
	local f = self.shoeFacing >= 0 and 1 or -1 -- 1318
	local moving = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 1319
	local stride = moving and math.sin(self.scavStridePhase) * cam:len(7.2) or 0 -- 1320
	local pausedToe = self.shoeToePauseTimer > 0 -- 1321
	fillRadialGlow( -- 1324
		fgGlow, -- 1324
		cx + f * cam:len(4), -- 1324
		by + 2, -- 1324
		cam:len(32), -- 1324
		cam:len(8), -- 1324
		Color(196, 208, 220, 48), -- 1324
		Color(156, 172, 190, 0), -- 1324
		14 -- 1324
	) -- 1324
	fgDraw:drawEllipse( -- 1325
		Vec2( -- 1325
			cx + f * cam:len(2), -- 1325
			by + 1 -- 1325
		), -- 1325
		cam:len(19), -- 1325
		cam:len(3.4), -- 1325
		Color(92, 102, 114, 72) -- 1325
	) -- 1325
	local function drawSingleShoe(footX, liftY, isFront) -- 1328
		local heelX = footX - f * cam:len(4.8) -- 1329
		local midX = footX + f * cam:len(1.8) -- 1330
		local toeX = footX + f * cam:len(7.6) -- 1331
		local soleY = by + 0.8 + liftY -- 1332
		local shoeH = cam:len(4.4) -- 1333
		fgDraw:drawPolygon( -- 1335
			{ -- 1335
				Vec2(heelX, soleY), -- 1336
				Vec2(toeX, soleY), -- 1337
				Vec2( -- 1338
					toeX - f * cam:len(1), -- 1338
					soleY + shoeH * 0.56 -- 1338
				), -- 1338
				Vec2(midX, soleY + shoeH * 0.96), -- 1339
				Vec2( -- 1340
					heelX + f * cam:len(0.6), -- 1340
					soleY + shoeH * 0.86 -- 1340
				) -- 1340
			}, -- 1340
			isFront and Color(68, 58, 48, 250) or Color(46, 40, 34, 240) -- 1341
		) -- 1341
		local soleCol = isFront and Color(198, 192, 178, 232) or Color(148, 144, 134, 195) -- 1343
		fgDraw:drawSegment( -- 1344
			Vec2(heelX, soleY + 0.6), -- 1344
			Vec2(toeX, soleY + 0.6), -- 1344
			1.5, -- 1344
			soleCol -- 1344
		) -- 1344
		fgDraw:drawSegment( -- 1346
			Vec2( -- 1346
				toeX - f * cam:len(1.2), -- 1346
				soleY + 0.8 -- 1346
			), -- 1346
			Vec2( -- 1346
				toeX - f * cam:len(1.4), -- 1346
				soleY + shoeH * 0.56 -- 1346
			), -- 1346
			1.3, -- 1346
			Color(214, 210, 198, isFront and 220 or 165) -- 1346
		) -- 1346
		if isFront and pausedToe then -- 1346
			fgGlow:drawDot( -- 1349
				Vec2(toeX, soleY + 1.5), -- 1349
				3, -- 1349
				Color(236, 218, 178, 155) -- 1349
			) -- 1349
		end -- 1349
	end -- 1328
	local backLift = moving and math.max( -- 1353
		0, -- 1353
		-math.sin(self.scavStridePhase) -- 1353
	) * cam:len(2.4) or 0 -- 1353
	local frontLift = moving and math.max( -- 1354
		0, -- 1354
		math.sin(self.scavStridePhase) -- 1354
	) * cam:len(2.8) or 0 -- 1354
	drawSingleShoe( -- 1355
		cx - stride - f * cam:len(3.5), -- 1355
		backLift, -- 1355
		false -- 1355
	) -- 1355
	drawSingleShoe( -- 1356
		cx + stride + f * cam:len(4), -- 1356
		frontLift, -- 1356
		true -- 1356
	) -- 1356
end -- 1310
function VillageUndertableScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 1366
	local p = ctx.p -- 1373
	local cam = ctx.cam -- 1374
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1375
	local arch = p.room.arch -- 1376
	local xLeft = arch.x0 - 8 -- 1378
	local xRight = arch.x1 + 8 -- 1379
	local tableBotY = arch.h -- 1380
	local tableTopY = arch.h + 8 -- 1381
	local zFront = -15 -- 1382
	local zMid = 4 -- 1383
	local function drawFrontLeg(lx0, lx1) -- 1386
		local mBL = projectWorld3D( -- 1387
			lx0, -- 1387
			0, -- 1387
			zFront, -- 1387
			cam, -- 1387
			self.proj -- 1387
		) -- 1387
		local mBR = projectWorld3D( -- 1388
			lx1, -- 1388
			0, -- 1388
			zFront, -- 1388
			cam, -- 1388
			self.proj -- 1388
		) -- 1388
		local mTR = projectWorld3D( -- 1389
			lx1, -- 1389
			tableBotY, -- 1389
			zFront, -- 1389
			cam, -- 1389
			self.proj -- 1389
		) -- 1389
		local mTL = projectWorld3D( -- 1390
			lx0, -- 1390
			tableBotY, -- 1390
			zFront, -- 1390
			cam, -- 1390
			self.proj -- 1390
		) -- 1390
		drawUiQuad( -- 1391
			uiDraw, -- 1391
			mBL, -- 1391
			mBR, -- 1391
			mTR, -- 1391
			mTL, -- 1391
			Color(26, 20, 15, 250), -- 1391
			Color(38, 29, 22, 252), -- 1391
			inv, -- 1391
			Color(88, 70, 54, 145), -- 1391
			0.9 -- 1391
		) -- 1391
		local sBR = projectWorld3D( -- 1393
			lx1, -- 1393
			0, -- 1393
			zFront + 7, -- 1393
			cam, -- 1393
			self.proj -- 1393
		) -- 1393
		local sTR = projectWorld3D( -- 1394
			lx1, -- 1394
			tableBotY, -- 1394
			zFront + 7, -- 1394
			cam, -- 1394
			self.proj -- 1394
		) -- 1394
		drawUiQuad( -- 1395
			uiDraw, -- 1395
			mBR, -- 1395
			sBR, -- 1395
			sTR, -- 1395
			mTR, -- 1395
			Color(44, 34, 26, 248), -- 1395
			Color(66, 52, 40, 250), -- 1395
			inv, -- 1395
			Color(138, 120, 102, 155), -- 1395
			0.8 -- 1395
		) -- 1395
	end -- 1386
	drawFrontLeg(arch.x0 - 1, arch.x0 + 6) -- 1397
	drawFrontLeg(arch.x1 - 6, arch.x1 + 1) -- 1398
	local bFarL = projectWorld3D( -- 1401
		xLeft, -- 1401
		tableBotY, -- 1401
		zMid, -- 1401
		cam, -- 1401
		self.proj -- 1401
	) -- 1401
	local bFarR = projectWorld3D( -- 1402
		xRight, -- 1402
		tableBotY, -- 1402
		zMid, -- 1402
		cam, -- 1402
		self.proj -- 1402
	) -- 1402
	local bNearR = projectWorld3D( -- 1403
		xRight, -- 1403
		tableBotY, -- 1403
		zFront, -- 1403
		cam, -- 1403
		self.proj -- 1403
	) -- 1403
	local bNearL = projectWorld3D( -- 1404
		xLeft, -- 1404
		tableBotY, -- 1404
		zFront, -- 1404
		cam, -- 1404
		self.proj -- 1404
	) -- 1404
	drawUiQuad( -- 1405
		uiDraw, -- 1405
		bFarL, -- 1405
		bFarR, -- 1405
		bNearR, -- 1405
		bNearL, -- 1405
		Color(18, 14, 11, 236), -- 1405
		Color(28, 21, 16, 242), -- 1405
		inv, -- 1405
		Color(76, 58, 44, 115), -- 1405
		0.8 -- 1405
	) -- 1405
	local fTopR = projectWorld3D( -- 1408
		xRight, -- 1408
		tableTopY, -- 1408
		zFront, -- 1408
		cam, -- 1408
		self.proj -- 1408
	) -- 1408
	local fTopL = projectWorld3D( -- 1409
		xLeft, -- 1409
		tableTopY, -- 1409
		zFront, -- 1409
		cam, -- 1409
		self.proj -- 1409
	) -- 1409
	drawUiQuad( -- 1410
		uiDraw, -- 1410
		bNearL, -- 1410
		bNearR, -- 1410
		fTopR, -- 1410
		fTopL, -- 1410
		Color(38, 28, 21, 252), -- 1410
		Color(56, 42, 32, 254), -- 1410
		inv, -- 1410
		Color(124, 98, 76, 155), -- 1410
		1 -- 1410
	) -- 1410
	uiDraw:drawSegment( -- 1412
		Vec2(bNearL.x * inv, bNearL.y * inv), -- 1412
		Vec2(bNearR.x * inv, bNearR.y * inv), -- 1412
		1.2, -- 1412
		Color(142, 122, 100, 175) -- 1412
	) -- 1412
	local topBackL = projectWorld3D( -- 1415
		xLeft, -- 1415
		tableTopY, -- 1415
		zMid, -- 1415
		cam, -- 1415
		self.proj -- 1415
	) -- 1415
	local topBackR = projectWorld3D( -- 1416
		xRight, -- 1416
		tableTopY, -- 1416
		zMid, -- 1416
		cam, -- 1416
		self.proj -- 1416
	) -- 1416
	drawUiQuad( -- 1417
		uiDraw, -- 1417
		fTopL, -- 1417
		fTopR, -- 1417
		topBackR, -- 1417
		topBackL, -- 1417
		Color(52, 40, 30, 244), -- 1417
		Color(32, 24, 19, 236), -- 1417
		inv, -- 1417
		Color(132, 110, 88, 130), -- 1417
		0.8 -- 1417
	) -- 1417
	local bowlBL = projectWorld3D( -- 1420
		arch.x0 + 24, -- 1420
		tableTopY + 0.5, -- 1420
		-5, -- 1420
		cam, -- 1420
		self.proj -- 1420
	) -- 1420
	local bowlBR = projectWorld3D( -- 1421
		arch.x0 + 38, -- 1421
		tableTopY + 0.5, -- 1421
		-5, -- 1421
		cam, -- 1421
		self.proj -- 1421
	) -- 1421
	local bowlTR = projectWorld3D( -- 1422
		arch.x0 + 40, -- 1422
		tableTopY + 6.5, -- 1422
		-5, -- 1422
		cam, -- 1422
		self.proj -- 1422
	) -- 1422
	local bowlTL = projectWorld3D( -- 1423
		arch.x0 + 22, -- 1423
		tableTopY + 6.5, -- 1423
		-5, -- 1423
		cam, -- 1423
		self.proj -- 1423
	) -- 1423
	drawUiQuad( -- 1424
		uiDraw, -- 1424
		bowlBL, -- 1424
		bowlBR, -- 1424
		bowlTR, -- 1424
		bowlTL, -- 1424
		Color(72, 68, 62, 244), -- 1424
		Color(118, 114, 106, 246), -- 1424
		inv, -- 1424
		Color(172, 166, 156, 175), -- 1424
		0.8 -- 1424
	) -- 1424
	local clothL = projectWorld3D( -- 1427
		xLeft + 2, -- 1427
		tableBotY - 7, -- 1427
		zFront, -- 1427
		cam, -- 1427
		self.proj -- 1427
	) -- 1427
	local clothR = projectWorld3D( -- 1428
		xLeft + 26, -- 1428
		tableBotY - 1, -- 1428
		zFront, -- 1428
		cam, -- 1428
		self.proj -- 1428
	) -- 1428
	uiDraw:drawVertices({ -- 1429
		{ -- 1430
			Vec2(bNearL.x * inv, bNearL.y * inv), -- 1430
			Color(28, 22, 19, 224) -- 1430
		}, -- 1430
		{ -- 1431
			Vec2(clothL.x * inv, clothL.y * inv), -- 1431
			Color(36, 29, 25, 212) -- 1431
		}, -- 1431
		{ -- 1432
			Vec2(clothR.x * inv, clothR.y * inv), -- 1432
			Color(26, 21, 18, 198) -- 1432
		} -- 1432
	}) -- 1432
	return false -- 1436
end -- 1366
return ____exports -- 1366