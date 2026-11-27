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
local DIORAMA_TEX_CLIP = ____lowpoly.DIORAMA_TEX_CLIP -- 25
local LP_BUCKET = ____lowpoly.LP_BUCKET -- 26
local LowpolyScene = ____lowpoly.LowpolyScene -- 29
local MING_MATERIALS = ____lowpoly.MING_MATERIALS -- 30
local VILLAGE_UNDERTABLE_LIGHT = ____lowpoly.VILLAGE_UNDERTABLE_LIGHT -- 31
local clamp01 = ____lowpoly.clamp01 -- 32
local projectWorld3D = ____lowpoly.projectWorld3D -- 33
local ____theme = require("Script.watch.fe.theme") -- 37
local fillRadialGlow = ____theme.fillRadialGlow -- 40
local fillVGradRect = ____theme.fillVGradRect -- 41
local rgba = ____theme.rgba -- 42
local toColor = ____theme.toColor -- 43
local GRAVITY = 1000 -- 46
local BOTTLE_FLY_T = 0.62 -- 47
local CHILD_AUDIO_ROOT = "assets/audio/child/" -- 48
--- 空村铁盆世界坐标（位于拾荒者巡逻右侧、与硬砖 brickX=608 ± 34 清晰分离、完全在听觉半径 480 内）
____exports.VILLAGE_BASIN_OFFSET_X = 548 -- 51
____exports.VILLAGE_BASIN_HIT_RADIUS = 24 -- 52
____exports.VILLAGE_SURFACE_HIT_RADIUS = 34 -- 53
local MAT_CLAY_STOVE = { -- 96
	base = rgba(74, 68, 62, 255), -- 97
	edge = rgba(128, 120, 110, 110), -- 98
	minShade = 0.26, -- 99
	rimBoost = 0.16, -- 100
	bottomAo = 0.34, -- 101
	texture = DIORAMA_TEX_CLIP .. "ming_plaster", -- 102
	textureTint = rgba(168, 160, 148, 255), -- 103
	subdivX = 2, -- 104
	subdivY = 2 -- 105
} -- 105
local MAT_SOFT_EARTH = { -- 108
	base = rgba(66, 54, 43, 255), -- 109
	edge = rgba(96, 80, 64, 85), -- 110
	minShade = 0.32, -- 111
	rimBoost = 0.08, -- 112
	bottomAo = 0.24, -- 113
	texture = DIORAMA_TEX_CLIP .. "ming_plaster", -- 114
	textureTint = rgba(132, 112, 92, 255), -- 115
	subdivX = 2, -- 116
	subdivY = 2 -- 117
} -- 117
local MAT_HARD_BRICK = { -- 120
	base = rgba(126, 132, 142, 255), -- 121
	edge = rgba(220, 226, 234, 165), -- 122
	minShade = 0.36, -- 123
	rimBoost = 0.3, -- 124
	bottomAo = 0.22, -- 125
	texture = DIORAMA_TEX_CLIP .. "ming_brick", -- 126
	textureTint = rgba(228, 234, 242, 255), -- 127
	subdivX = 2, -- 128
	subdivY = 2 -- 129
} -- 129
local MAT_IRON_BASIN = { -- 132
	base = rgba(58, 66, 78, 255), -- 133
	edge = rgba(214, 224, 238, 185), -- 134
	minShade = 0.28, -- 135
	rimBoost = 0.38, -- 136
	bottomAo = 0.26, -- 137
	texture = DIORAMA_TEX_CLIP .. "ming_iron", -- 138
	textureTint = rgba(188, 198, 212, 255), -- 139
	subdivX = 2, -- 140
	subdivY = 2 -- 141
} -- 141
local MAT_TABLE_WOOD = { -- 144
	base = rgba(78, 56, 40, 255), -- 145
	edge = rgba(142, 110, 82, 120), -- 146
	minShade = 0.24, -- 147
	rimBoost = 0.18, -- 148
	bottomAo = 0.38, -- 149
	texture = DIORAMA_TEX_CLIP .. "ming_timber", -- 150
	textureTint = rgba(164, 140, 120, 255), -- 151
	subdivX = 3, -- 152
	subdivY = 2 -- 153
} -- 153
local MAT_CULVERT_STONE = { -- 156
	base = rgba(76, 84, 96, 255), -- 157
	edge = rgba(178, 194, 210, 155), -- 158
	minShade = 0.3, -- 159
	rimBoost = 0.28, -- 160
	bottomAo = 0.3, -- 161
	texture = DIORAMA_TEX_CLIP .. "ming_stone", -- 162
	textureTint = rgba(188, 198, 212, 255), -- 163
	subdivX = 2, -- 164
	subdivY = 2 -- 165
} -- 165
local function drawEllipseRing(draw, cx, cy, rx, ry, lineW, col, segs) -- 168
	if segs == nil then -- 168
		segs = 22 -- 176
	end -- 176
	local pts = {} -- 178
	local i = 0 -- 179
	do -- 179
		i = 0 -- 180
		while i < segs do -- 180
			local a = i / segs * math.pi * 2 -- 181
			pts[#pts + 1] = Vec2( -- 182
				cx + math.cos(a) * rx, -- 182
				cy + math.sin(a) * ry -- 182
			) -- 182
			i = i + 1 -- 180
		end -- 180
	end -- 180
	draw:drawPolygon( -- 184
		pts, -- 184
		Color(0, 0, 0, 0), -- 184
		lineW, -- 184
		col -- 184
	) -- 184
end -- 168
local function drawUiQuad(uiDraw, p0, p1, p2, p3, cBot, cTop, invScale, edgeCol, edgeW) -- 187
	if edgeW == nil then -- 187
		edgeW = 0 -- 197
	end -- 197
	local v0 = Vec2(p0.x * invScale, p0.y * invScale) -- 199
	local v1 = Vec2(p1.x * invScale, p1.y * invScale) -- 200
	local v2 = Vec2(p2.x * invScale, p2.y * invScale) -- 201
	local v3 = Vec2(p3.x * invScale, p3.y * invScale) -- 202
	uiDraw:drawVertices({{v0, cBot}, {v1, cBot}, {v2, cTop}}) -- 203
	uiDraw:drawVertices({{v0, cBot}, {v2, cTop}, {v3, cTop}}) -- 208
	if edgeCol ~= nil and edgeW > 0 then -- 208
		local half = edgeW * 0.5 -- 214
		uiDraw:drawSegment(v0, v1, half, edgeCol) -- 215
		uiDraw:drawSegment(v1, v2, half, edgeCol) -- 216
		uiDraw:drawSegment(v2, v3, half, edgeCol) -- 217
		uiDraw:drawSegment(v3, v0, half, edgeCol) -- 218
	end -- 218
end -- 187
____exports.VillageUndertableScene = __TS__Class() -- 222
local VillageUndertableScene = ____exports.VillageUndertableScene -- 222
VillageUndertableScene.name = "VillageUndertableScene" -- 222
function VillageUndertableScene.prototype.____constructor(self) -- 222
	self.animTime = 0 -- 223
	self.active = false -- 224
	self.underTableFocus = 0 -- 225
	self.lastSurface = "" -- 226
	self.lastLandX = -1 -- 227
	self.brickHits = 0 -- 228
	self.ironHits = 0 -- 229
	self.softHits = 0 -- 230
	self.basinShakeTimer = 0 -- 233
	self.basinShakeMax = 1.15 -- 234
	self.basinShakeAngle = 0 -- 235
	self.shoeToePauseTimer = 0 -- 238
	self.shoeTurnBlend = 1 -- 239
	self.shoeFacing = -1 -- 240
	self.prevScavState = "patrol" -- 241
	self.prevScavX = 0 -- 242
	self.scavStridePhase = 0 -- 243
	self.shards = {} -- 245
	self.rings = {} -- 246
	self.rng = 7321 -- 247
	self.proj = { -- 249
		morph = 1, -- 250
		focal = 390, -- 251
		vpFracX = 0.54, -- 252
		vpFracY = 0.44, -- 253
		vpOffsetX = 0, -- 254
		vpOffsetY = 0, -- 255
		baseDepth = 0 -- 256
	} -- 256
end -- 222
function VillageUndertableScene.prototype.reset(self) -- 259
	self.animTime = 0 -- 260
	self.active = false -- 261
	self.underTableFocus = 0 -- 262
	self.lastSurface = "" -- 263
	self.lastLandX = -1 -- 264
	self.brickHits = 0 -- 265
	self.ironHits = 0 -- 266
	self.softHits = 0 -- 267
	self.basinShakeTimer = 0 -- 268
	self.basinShakeAngle = 0 -- 269
	self.shoeToePauseTimer = 0 -- 270
	self.shoeTurnBlend = 1 -- 271
	self.shoeFacing = -1 -- 272
	self.prevScavState = "patrol" -- 273
	self.prevScavX = 0 -- 274
	self.scavStridePhase = 0 -- 275
	self.shards = {} -- 276
	self.rings = {} -- 277
end -- 259
function VillageUndertableScene.prototype.rand(self) -- 280
	self.rng = (self.rng * 1664525 + 1013904223) % 4294967296 -- 281
	return self.rng / 4294967296 -- 282
end -- 280
function VillageUndertableScene.prototype.getProjection(self) -- 285
	return self.proj -- 286
end -- 285
function VillageUndertableScene.prototype.getBasinWorldX(self, p) -- 289
	return p.ox + ____exports.VILLAGE_BASIN_OFFSET_X -- 290
end -- 289
function VillageUndertableScene.prototype.getBrickWorldX(self, p) -- 293
	return p.room.brickX or p.ox + 608 -- 294
end -- 293
function VillageUndertableScene.prototype.getSoftWorldX(self, p) -- 297
	return p.room.softX or p.ox + 272 -- 298
end -- 297
function VillageUndertableScene.prototype.getCulvertWorldX(self, p) -- 301
	return p.ox + 600 -- 303
end -- 301
function VillageUndertableScene.prototype.classifyLandingSurface(self, p, x, explicitSurface) -- 307
	if explicitSurface == "iron" or explicitSurface == "basin" then -- 307
		return "iron" -- 309
	end -- 309
	if explicitSurface == "soft" or explicitSurface == "dirt" then -- 309
		return "soft" -- 312
	end -- 312
	if explicitSurface == "brick" then -- 312
		return "brick" -- 315
	end -- 315
	local basinX = self:getBasinWorldX(p) -- 317
	if math.abs(x - basinX) <= ____exports.VILLAGE_BASIN_HIT_RADIUS then -- 317
		return "iron" -- 319
	end -- 319
	local softX = self:getSoftWorldX(p) -- 321
	if math.abs(x - softX) <= ____exports.VILLAGE_SURFACE_HIT_RADIUS then -- 321
		return "soft" -- 323
	end -- 323
	return "brick" -- 325
end -- 307
function VillageUndertableScene.prototype.getDebugState(self, p) -- 328
	return { -- 329
		active = self.active, -- 330
		basinWorldX = p ~= nil and self:getBasinWorldX(p) or ____exports.VILLAGE_BASIN_OFFSET_X, -- 331
		brickWorldX = p ~= nil and self:getBrickWorldX(p) or 608, -- 332
		softWorldX = p ~= nil and self:getSoftWorldX(p) or 272, -- 333
		culvertWorldX = p ~= nil and self:getCulvertWorldX(p) or 440, -- 334
		lastSurface = self.lastSurface, -- 335
		brickHits = self.brickHits, -- 336
		ironHits = self.ironHits, -- 337
		softHits = self.softHits, -- 338
		basinShakeTimer = self.basinShakeTimer, -- 339
		basinShakeAngle = self.basinShakeAngle, -- 340
		shoeToePauseTimer = self.shoeToePauseTimer, -- 341
		shoeFacing = self.shoeFacing, -- 342
		scavTargetX = p ~= nil and p.scavTargetX or 0, -- 343
		underTableFocus = self.underTableFocus, -- 344
		lastLandX = self.lastLandX -- 345
	} -- 345
end -- 328
function VillageUndertableScene.prototype.update(self, ctx) -- 349
	local p = ctx.p -- 350
	self.active = true -- 351
	local arch = p.room.arch -- 354
	local nearTable = p.player.x >= arch.x0 - 80 and p.player.x <= arch.x1 + 30 -- 355
	local targetFocus = (p.player.crouch or nearTable) and 1 or 0.72 -- 356
	if not ctx.paused and ctx.worldDt > 0 then -- 356
		local dt = ctx.worldDt -- 358
		self.animTime = self.animTime + dt -- 359
		self.underTableFocus = self.underTableFocus + (targetFocus - self.underTableFocus) * math.min(1, dt * 4.5) -- 360
		if self.basinShakeTimer > 0 then -- 360
			self.basinShakeTimer = math.max(0, self.basinShakeTimer - dt) -- 364
			local elapsed = self.basinShakeMax - self.basinShakeTimer -- 365
			self.basinShakeAngle = math.sin(elapsed * 38) * math.exp(-elapsed * 3.1) * 0.24 -- 366
		else -- 366
			self.basinShakeAngle = 0 -- 368
		end -- 368
		if self.shoeToePauseTimer > 0 then -- 368
			self.shoeToePauseTimer = math.max(0, self.shoeToePauseTimer - dt) -- 373
		end -- 373
		local scavDx = p.scavX - self.prevScavX -- 375
		if math.abs(scavDx) > 0.02 then -- 375
			self.scavStridePhase = self.scavStridePhase + math.abs(scavDx) * 0.16 -- 377
		elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" then -- 377
			self.scavStridePhase = self.scavStridePhase + dt * (p.scavState == "chase" and 11.5 or 6.2) -- 379
		end -- 379
		self.prevScavX = p.scavX -- 381
		local desiredFacing = self:computeDesiredShoeFacing(p) -- 384
		if self.shoeToePauseTimer <= 0 then -- 384
			self.shoeFacing = desiredFacing -- 386
			self.shoeTurnBlend = math.min(1, self.shoeTurnBlend + dt * 6) -- 387
		end -- 387
		local i = 0 -- 391
		do -- 391
			i = 0 -- 392
			while i < #ctx.events.rawEvents do -- 392
				local ev = ctx.events.rawEvents[i + 1] -- 393
				if ev.name == "bottleLanded" then -- 393
					self:onBottleLanded(ctx, ev) -- 395
				end -- 395
				i = i + 1 -- 392
			end -- 392
		end -- 392
		if p.scavState == "turn" and self.prevScavState ~= "turn" then -- 392
			if self.lastSurface == "brick" and self.shoeToePauseTimer <= 0 then -- 392
				self.shoeToePauseTimer = 0.14 -- 402
			end -- 402
		end -- 402
		self.prevScavState = p.scavState -- 405
		local w = 0 -- 408
		do -- 408
			i = 0 -- 409
			while i < #self.shards do -- 409
				local sp = self.shards[i + 1] -- 410
				sp.life = sp.life - dt -- 411
				if sp.life > 0 then -- 411
					sp.vy = sp.vy - (sp.kind == "soft" and 180 or 420) * dt -- 413
					sp.x = sp.x + sp.vx * dt -- 414
					sp.y = sp.y + sp.vy * dt -- 415
					if sp.y < 0 then -- 415
						sp.y = 0 -- 417
						sp.vy = -sp.vy * 0.28 -- 418
						sp.vx = sp.vx * 0.62 -- 419
					end -- 419
					self.shards[w + 1] = sp -- 421
					w = w + 1 -- 422
				end -- 422
				i = i + 1 -- 409
			end -- 409
		end -- 409
		__TS__ArraySetLength(self.shards, w) -- 409
		w = 0 -- 428
		do -- 428
			i = 0 -- 429
			while i < #self.rings do -- 429
				local rg = self.rings[i + 1] -- 430
				rg.age = rg.age + dt -- 431
				if rg.age < rg.duration then -- 431
					self.rings[w + 1] = rg -- 433
					w = w + 1 -- 434
				end -- 434
				i = i + 1 -- 429
			end -- 429
		end -- 429
		__TS__ArraySetLength(self.rings, w) -- 429
		ctx.audio:playLoop( -- 440
			"fe04_village_night", -- 440
			"ambience", -- 440
			CHILD_AUDIO_ROOT .. "village_night_loop.wav", -- 440
			0.24, -- 440
			p.ticks -- 440
		) -- 440
	elseif self.underTableFocus == 0 then -- 440
		self.underTableFocus = targetFocus -- 442
	end -- 442
	local focusAnchorX = math.max( -- 446
		p.ox + 305, -- 446
		math.min(p.ox + 455, p.ox + 355 + (p.player.x - (p.ox + 320)) * 0.28) -- 446
	) -- 446
	local zoom = 1.04 + (1 - self.underTableFocus) * 0.04 -- 447
	ctx.cam:setAnchorLock({ -- 448
		footWorldX = focusAnchorX, -- 449
		footWorldY = 0, -- 450
		footDepth = 0, -- 451
		thresholdWorldX = p.ox + 440, -- 452
		screenFootFracX = 0.5, -- 453
		screenFootFracY = 0.235, -- 454
		zoomOverride = zoom -- 455
	}) -- 455
	self.proj = { -- 458
		morph = 1, -- 459
		focal = 390, -- 460
		vpFracX = 0.54, -- 461
		vpFracY = 0.43 - self.underTableFocus * 0.03, -- 462
		vpOffsetX = math.sin(self.animTime * 0.65) * 1.4, -- 463
		vpOffsetY = math.cos(self.animTime * 0.85) * 1, -- 464
		baseDepth = 0 -- 465
	} -- 465
end -- 349
function VillageUndertableScene.prototype.computeDesiredShoeFacing(self, p) -- 469
	if p.scavState == "chase" then -- 469
		return p.player.x >= p.scavX and 1 or -1 -- 471
	end -- 471
	if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 471
		if math.abs(p.scavTargetX - p.scavX) > 2 then -- 471
			return p.scavTargetX >= p.scavX and 1 or -1 -- 475
		end -- 475
	end -- 475
	if p.scavState == "back" and p.room.scavenger ~= nil then -- 475
		local home = math.max( -- 479
			p.room.scavenger.x0, -- 479
			math.min(p.room.scavenger.x1, p.scavX) -- 479
		) -- 479
		if math.abs(home - p.scavX) > 2 then -- 479
			return home > p.scavX and 1 or -1 -- 481
		end -- 481
	end -- 481
	return p.scavDir >= 0 and 1 or -1 -- 484
end -- 469
function VillageUndertableScene.prototype.onBottleLanded(self, ctx, ev) -- 487
	local p = ctx.p -- 488
	local x = type(ev.data.x) == "number" and ev.data.x or p.bottleLandX -- 489
	local y = type(ev.data.y) == "number" and ev.data.y or math.max(0, p.bottleLandY) -- 490
	local explicitSurface = type(ev.data.surface) == "string" and ev.data.surface or nil -- 491
	local surface = self:classifyLandingSurface(p, x, explicitSurface) -- 492
	self.lastSurface = surface -- 494
	self.lastLandX = x -- 495
	if surface == "iron" then -- 495
		self.ironHits = self.ironHits + 1 -- 498
		self.basinShakeTimer = self.basinShakeMax -- 499
		self.shoeToePauseTimer = 0 -- 500
		self.shoeTurnBlend = 0.25 -- 501
		local bx = self:getBasinWorldX(p) -- 502
		local ____self_rings_0 = self.rings -- 502
		____self_rings_0[#____self_rings_0 + 1] = { -- 504
			x = bx, -- 504
			y = 12, -- 504
			age = 0, -- 504
			duration = 1.05, -- 504
			maxRadius = 84, -- 504
			kind = "iron" -- 504
		} -- 504
		local ____self_rings_1 = self.rings -- 504
		____self_rings_1[#____self_rings_1 + 1] = { -- 505
			x = bx, -- 505
			y = 12, -- 505
			age = -0.14, -- 505
			duration = 1.2, -- 505
			maxRadius = 112, -- 505
			kind = "iron" -- 505
		} -- 505
		local ____self_rings_2 = self.rings -- 505
		____self_rings_2[#____self_rings_2 + 1] = { -- 506
			x = bx, -- 506
			y = 12, -- 506
			age = -0.28, -- 506
			duration = 1.32, -- 506
			maxRadius = 136, -- 506
			kind = "iron" -- 506
		} -- 506
		self:spawnShards(bx, 12, "iron", 7) -- 507
		local key = (((("fe04:village:iron_ring:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(ev.tick)) .. ":") .. tostring(ev.seq) -- 510
		ctx.audio:playOnce( -- 511
			key, -- 512
			"sfx", -- 513
			CHILD_AUDIO_ROOT .. "bottle_iron_ring.wav", -- 514
			0.82, -- 515
			"fe04:bottle:iron_ring", -- 516
			ev.tick, -- 517
			ev.seq -- 518
		) -- 518
	elseif surface == "brick" then -- 518
		self.brickHits = self.brickHits + 1 -- 521
		self.shoeToePauseTimer = 0.14 -- 523
		local ____self_rings_3 = self.rings -- 523
		____self_rings_3[#____self_rings_3 + 1] = { -- 524
			x = x, -- 524
			y = math.max(2, y), -- 524
			age = 0, -- 524
			duration = 0.44, -- 524
			maxRadius = 58, -- 524
			kind = "brick" -- 524
		} -- 524
		self:spawnShards( -- 525
			x, -- 525
			math.max(2, y), -- 525
			"brick", -- 525
			9 -- 525
		) -- 525
	else -- 525
		self.softHits = self.softHits + 1 -- 527
		local ____self_rings_4 = self.rings -- 527
		____self_rings_4[#____self_rings_4 + 1] = { -- 528
			x = x, -- 528
			y = math.max(2, y), -- 528
			age = 0, -- 528
			duration = 0.36, -- 528
			maxRadius = 24, -- 528
			kind = "soft" -- 528
		} -- 528
		self:spawnShards( -- 529
			x, -- 529
			math.max(2, y), -- 529
			"soft", -- 529
			6 -- 529
		) -- 529
		local audioKey = ((((((("r" .. tostring(ctx.events.roomSessionId)) .. ":cp") .. tostring(ctx.events.checkpoint)) .. ":t") .. tostring(ev.tick)) .. ":s") .. tostring(ev.seq)) .. ":bottleLanded" -- 532
		if not ctx.audio:hasPlayed(audioKey) then -- 532
			local key = (((("fe04:village:soft_thud:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(ev.tick)) .. ":") .. tostring(ev.seq) -- 534
			ctx.audio:playOnce( -- 535
				key, -- 536
				"sfx", -- 537
				CHILD_AUDIO_ROOT .. "bottle_soft.wav", -- 538
				0.76, -- 539
				"fe04:bottle:soft_thud", -- 540
				ev.tick, -- 541
				ev.seq -- 542
			) -- 542
		end -- 542
	end -- 542
end -- 487
function VillageUndertableScene.prototype.spawnShards(self, x, y, kind, count) -- 548
	local i = 0 -- 549
	do -- 549
		i = 0 -- 550
		while i < count do -- 550
			local ang = (0.18 + self:rand() * 0.64) * math.pi -- 551
			local spd = (kind == "soft" and 28 or 65) + self:rand() * (kind == "soft" and 36 or 95) -- 552
			local ____self_shards_5 = self.shards -- 552
			____self_shards_5[#____self_shards_5 + 1] = { -- 553
				x = x + (self:rand() - 0.5) * 10, -- 554
				y = y + 2, -- 555
				vx = math.cos(ang) * spd * (self:rand() > 0.5 and 1 or -1), -- 556
				vy = math.sin(ang) * spd, -- 557
				size = kind == "soft" and 2.2 + self:rand() * 2.4 or 1.8 + self:rand() * 2.2, -- 558
				life = (kind == "soft" and 0.34 or 0.48) + self:rand() * 0.22, -- 559
				maxLife = 0.65, -- 560
				kind = kind -- 561
			} -- 561
			i = i + 1 -- 550
		end -- 550
	end -- 550
end -- 548
function VillageUndertableScene.prototype.triggerRehearsalImpact(self, ctx, surface) -- 567
	local p = ctx.p -- 568
	local x = surface == "iron" and self:getBasinWorldX(p) or (surface == "soft" and self:getSoftWorldX(p) or self:getBrickWorldX(p)) -- 569
	self:onBottleLanded(ctx, {seq = 9000 + self.brickHits + self.ironHits + self.softHits, tick = p.ticks, name = "bottleLanded", data = {x = x, y = 0, surface = surface, heard = true}}) -- 572
end -- 567
function VillageUndertableScene.prototype.drawBackdrop(self, bgDraw, bgGlow, _backdropArt, ctx) -- 580
	local p = ctx.p -- 586
	local cam = ctx.cam -- 587
	local w = cam.viewW -- 588
	local h = cam.viewH -- 589
	local splitY = h * 0.5 -- 592
	fillVGradRect( -- 593
		bgDraw, -- 593
		0, -- 593
		splitY, -- 593
		w, -- 593
		h - splitY, -- 593
		Color(14, 18, 26, 255), -- 593
		Color(7, 9, 15, 255) -- 593
	) -- 593
	fillVGradRect( -- 594
		bgDraw, -- 594
		0, -- 594
		0, -- 594
		w, -- 594
		splitY, -- 594
		Color(24, 28, 38, 255), -- 594
		Color(14, 18, 26, 255) -- 594
	) -- 594
	local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 596
	local ox = p.ox -- 597
	scene:addDistantRidge( -- 600
		{ -- 601
			{x = ox - 140, y = 120}, -- 602
			{x = ox + 120, y = 162}, -- 603
			{x = ox + 360, y = 138}, -- 604
			{x = ox + 590, y = 176}, -- 605
			{x = ox + 860, y = 132} -- 606
		}, -- 606
		-20, -- 606
		420, -- 609
		MING_MATERIALS.distantHill, -- 610
		{bucket = LP_BUCKET.BACKDROP} -- 611
	) -- 611
	scene:addCutout3D( -- 615
		"assets/art/diorama_cutouts.clip|ming_eave_ruin", -- 616
		ox + 575, -- 617
		18, -- 618
		218, -- 619
		238, -- 620
		156, -- 621
		{ -- 622
			bucket = LP_BUCKET.BACKDROP, -- 623
			anchorX = 0.5, -- 624
			anchorY = 0, -- 625
			color = rgba(112, 126, 144, 255), -- 626
			opacity = 0.9, -- 627
			sortBias = 0.04 -- 628
		} -- 628
	) -- 628
	scene:addCutout3D( -- 631
		"assets/art/diorama_cutouts.clip|north_tower_distant", -- 632
		ox + 668, -- 633
		46, -- 634
		405, -- 635
		108, -- 636
		138, -- 637
		{ -- 638
			bucket = LP_BUCKET.BACKDROP, -- 639
			anchorX = 0.5, -- 640
			anchorY = 0, -- 641
			color = rgba(132, 146, 168, 255), -- 642
			opacity = 0.88, -- 643
			sortBias = 0.06 -- 644
		} -- 644
	) -- 644
	scene:addBox({ -- 649
		x0 = ox - 60, -- 650
		x1 = ox + 436, -- 651
		y0 = 0, -- 652
		y1 = 196, -- 653
		z0 = 112, -- 654
		z1 = 152, -- 655
		material = MING_MATERIALS.mingBrickDark, -- 656
		bucket = LP_BUCKET.BACKDROP, -- 657
		edgeWidth = 0.6 -- 658
	}) -- 658
	scene:addBox({ -- 662
		x0 = ox + 150, -- 663
		x1 = ox + 258, -- 664
		y0 = 0, -- 665
		y1 = 42, -- 666
		z0 = 76, -- 667
		z1 = 112, -- 668
		material = MAT_CLAY_STOVE, -- 669
		bucket = LP_BUCKET.MIDGROUND, -- 670
		highlightTopEdge = true -- 671
	}) -- 671
	scene:addBox({ -- 673
		x0 = ox + 178, -- 674
		x1 = ox + 228, -- 675
		y0 = 42, -- 676
		y1 = 156, -- 677
		z0 = 94, -- 678
		z1 = 114, -- 679
		material = MAT_CLAY_STOVE, -- 680
		bucket = LP_BUCKET.MIDGROUND, -- 681
		edgeWidth = 0.5 -- 682
	}) -- 682
	scene:addBox({ -- 686
		x0 = ox + 486, -- 687
		x1 = ox + 536, -- 688
		y0 = 0, -- 689
		y1 = 34, -- 690
		z0 = 126, -- 691
		z1 = 162, -- 692
		material = MING_MATERIALS.mingStoneStep, -- 693
		bucket = LP_BUCKET.MIDGROUND, -- 694
		highlightTopEdge = true -- 695
	}) -- 695
	scene:addFogBand( -- 699
		ox - 120, -- 699
		ox + 840, -- 699
		-10, -- 699
		140, -- 699
		260, -- 699
		rgba(24, 30, 42, 255), -- 699
		0.62, -- 699
		0.05, -- 699
		{bucket = LP_BUCKET.BACKDROP} -- 699
	) -- 699
	scene:flush(bgDraw, bgGlow, ctx.dioramaBg) -- 703
	local mx = w * 0.8 -- 706
	local my = h * 0.84 -- 707
	fillRadialGlow( -- 708
		bgGlow, -- 708
		mx, -- 708
		my, -- 708
		96, -- 708
		96, -- 708
		Color(188, 206, 224, 24), -- 708
		Color(24, 32, 46, 0), -- 708
		16 -- 708
	) -- 708
	bgDraw:drawCircle( -- 709
		Vec2(mx, my), -- 709
		14, -- 709
		Color(214, 224, 236, 130) -- 709
	) -- 709
	local towerPt = projectWorld3D( -- 712
		ox + 668, -- 712
		152, -- 712
		410, -- 712
		cam, -- 712
		self.proj -- 712
	) -- 712
	fillRadialGlow( -- 713
		bgGlow, -- 713
		towerPt.x, -- 713
		towerPt.y, -- 713
		20, -- 713
		20, -- 713
		Color(238, 198, 132, 54), -- 713
		Color(238, 198, 132, 0), -- 713
		12 -- 713
	) -- 713
	bgGlow:drawDot( -- 714
		Vec2(towerPt.x, towerPt.y), -- 714
		2, -- 714
		Color(252, 232, 186, 185) -- 714
	) -- 714
	return true -- 716
end -- 580
function VillageUndertableScene.prototype.drawWorld(self, fgDraw, fgGlow, _worldArt, ctx) -- 719
	local p = ctx.p -- 725
	local cam = ctx.cam -- 726
	local ox = p.ox -- 727
	local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 728
	scene:addBox({ -- 731
		x0 = ox - 40, -- 732
		x1 = ox + 436, -- 733
		y0 = -52, -- 734
		y1 = 0, -- 735
		z0 = -32, -- 736
		z1 = 112, -- 737
		material = MING_MATERIALS.mingTimberDark, -- 738
		bucket = LP_BUCKET.MIDGROUND, -- 739
		highlightTopEdge = true, -- 740
		edgeWidth = 0.7 -- 741
	}) -- 741
	scene:addBox({ -- 743
		x0 = ox + 436, -- 744
		x1 = ox + 760, -- 745
		y0 = -52, -- 746
		y1 = 0, -- 747
		z0 = -32, -- 748
		z1 = 126, -- 749
		material = MING_MATERIALS.mingBrickDark, -- 750
		bucket = LP_BUCKET.MIDGROUND, -- 751
		highlightTopEdge = true, -- 752
		edgeWidth = 0.8 -- 753
	}) -- 753
	scene:addBeveledFrame( -- 757
		ox + 416, -- 757
		ox + 462, -- 757
		0, -- 757
		128, -- 757
		16, -- 757
		22, -- 757
		16, -- 757
		112, -- 757
		MING_MATERIALS.mingTimberDark, -- 757
		{ -- 757
			bucket = LP_BUCKET.MIDGROUND, -- 758
			innerRimLight = rgba(206, 214, 222, 255), -- 759
			innerRimStrength = 0.42 -- 760
		} -- 760
	) -- 760
	scene:addBox({ -- 764
		x0 = ox + 96, -- 765
		x1 = ox + 101, -- 766
		y0 = 0, -- 767
		y1 = 52, -- 768
		z0 = -6, -- 769
		z1 = 24, -- 770
		material = MAT_TABLE_WOOD, -- 771
		bucket = LP_BUCKET.WALK_DECK, -- 772
		edgeWidth = 0.8 -- 773
	}) -- 773
	scene:addBox({ -- 775
		x0 = ox + 123, -- 776
		x1 = ox + 128, -- 777
		y0 = 0, -- 778
		y1 = 52, -- 779
		z0 = -6, -- 780
		z1 = 24, -- 781
		material = MAT_TABLE_WOOD, -- 782
		bucket = LP_BUCKET.WALK_DECK, -- 783
		edgeWidth = 0.8 -- 784
	}) -- 784
	scene:addBox({ -- 786
		x0 = ox + 95, -- 787
		x1 = ox + 129, -- 788
		y0 = 24, -- 789
		y1 = 28, -- 790
		z0 = -8, -- 791
		z1 = 26, -- 792
		material = MING_MATERIALS.mingTimber, -- 793
		bucket = LP_BUCKET.WALK_DECK, -- 794
		sortBias = 0.05 -- 795
	}) -- 795
	scene:addBox({ -- 797
		x0 = ox + 94, -- 798
		x1 = ox + 130, -- 799
		y0 = 48, -- 800
		y1 = 52, -- 801
		z0 = -8, -- 802
		z1 = 26, -- 803
		material = MING_MATERIALS.mingTimber, -- 804
		bucket = LP_BUCKET.WALK_DECK, -- 805
		highlightTopEdge = true, -- 806
		sortBias = 0.06 -- 807
	}) -- 807
	scene:addBox({ -- 810
		x0 = ox + 672, -- 811
		x1 = ox + 720, -- 812
		y0 = 0, -- 813
		y1 = 96, -- 814
		z0 = -14, -- 815
		z1 = 96, -- 816
		material = MING_MATERIALS.mingBrick, -- 817
		bucket = LP_BUCKET.MIDGROUND, -- 818
		highlightTopEdge = true, -- 819
		edgeWidth = 0.9 -- 820
	}) -- 820
	scene:addBox({ -- 822
		x0 = ox + 666, -- 823
		x1 = ox + 726, -- 824
		y0 = 96, -- 825
		y1 = 106, -- 826
		z0 = -18, -- 827
		z1 = 100, -- 828
		material = MING_MATERIALS.mingTile, -- 829
		bucket = LP_BUCKET.MIDGROUND, -- 830
		sortBias = 0.08 -- 831
	}) -- 831
	local arch = p.room.arch -- 836
	scene:addBox({ -- 838
		x0 = arch.x0 - 1, -- 839
		x1 = arch.x0 + 7, -- 840
		y0 = 0, -- 841
		y1 = arch.h, -- 842
		z0 = 12, -- 843
		z1 = 22, -- 844
		material = MAT_TABLE_WOOD, -- 845
		bucket = LP_BUCKET.MIDGROUND, -- 846
		edgeWidth = 0.8 -- 847
	}) -- 847
	scene:addBox({ -- 849
		x0 = arch.x1 - 7, -- 850
		x1 = arch.x1 + 1, -- 851
		y0 = 0, -- 852
		y1 = arch.h, -- 853
		z0 = 12, -- 854
		z1 = 22, -- 855
		material = MAT_TABLE_WOOD, -- 856
		bucket = LP_BUCKET.MIDGROUND, -- 857
		edgeWidth = 0.8 -- 858
	}) -- 858
	scene:addBox({ -- 861
		x0 = arch.x0 + 7, -- 862
		x1 = arch.x1 - 7, -- 863
		y0 = arch.h - 5, -- 864
		y1 = arch.h, -- 865
		z0 = 14, -- 866
		z1 = 20, -- 867
		material = MAT_TABLE_WOOD, -- 868
		bucket = LP_BUCKET.MIDGROUND, -- 869
		edgeWidth = 0.6 -- 870
	}) -- 870
	scene:addBox({ -- 873
		x0 = arch.x0 - 8, -- 874
		x1 = arch.x1 + 8, -- 875
		y0 = arch.h, -- 876
		y1 = arch.h + 8, -- 877
		z0 = 4, -- 878
		z1 = 28, -- 879
		material = MAT_TABLE_WOOD, -- 880
		bucket = LP_BUCKET.WALK_DECK, -- 881
		highlightTopEdge = true, -- 882
		edgeWidth = 0.8 -- 883
	}) -- 883
	local culvertX = self:getCulvertWorldX(p) -- 887
	self:buildCulvertEntrance(scene, culvertX) -- 888
	local softX = self:getSoftWorldX(p) -- 892
	self:buildSoftDirtPatch(scene, softX) -- 893
	local brickX = self:getBrickWorldX(p) -- 896
	self:buildHardBrickPatch(scene, brickX) -- 897
	local basinX = self:getBasinWorldX(p) -- 900
	self:buildIronBasin(scene, basinX) -- 901
	scene:addLightShaft( -- 904
		ox + 570, -- 905
		ox + 710, -- 905
		290, -- 905
		ox + 446, -- 906
		ox + 642, -- 906
		0, -- 906
		24, -- 907
		rgba(218, 226, 218, 255), -- 908
		0.13, -- 909
		0.04 -- 910
	) -- 910
	scene:addContactShadow( -- 914
		p.player.x, -- 914
		p.player.y, -- 914
		14, -- 914
		10, -- 914
		0.8, -- 914
		{bucket = LP_BUCKET.PROP, sortBias = 0.4} -- 914
	) -- 914
	if p.room.scavenger ~= nil then -- 914
		scene:addContactShadow( -- 916
			p.scavX, -- 916
			p.room.scavenger.y, -- 916
			19, -- 916
			13, -- 916
			0.84, -- 916
			{bucket = LP_BUCKET.PROP, sortBias = 0.42} -- 916
		) -- 916
	end -- 916
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 919
	self:drawSurfaceReadabilityDetails( -- 922
		fgDraw, -- 922
		fgGlow, -- 922
		p, -- 922
		cam, -- 922
		softX, -- 922
		culvertX, -- 922
		basinX, -- 922
		brickX -- 922
	) -- 922
	return true -- 924
end -- 719
function VillageUndertableScene.prototype.buildCulvertEntrance(self, scene, cx) -- 927
	scene:addBox({ -- 929
		x0 = cx - 18, -- 930
		x1 = cx + 18, -- 931
		y0 = -12, -- 932
		y1 = 2, -- 933
		z0 = -6, -- 934
		z1 = 42, -- 935
		material = MAT_CULVERT_STONE, -- 936
		bucket = LP_BUCKET.WALK_DECK, -- 937
		highlightTopEdge = true, -- 938
		edgeWidth = 0.8 -- 939
	}) -- 939
	scene:addCutout3D( -- 942
		"assets/art/diorama_cutouts.clip|culvert_arch", -- 943
		cx, -- 944
		0, -- 945
		20, -- 946
		46, -- 947
		33, -- 948
		{ -- 949
			bucket = LP_BUCKET.MIDGROUND, -- 950
			anchorX = 0.5, -- 951
			anchorY = 0, -- 952
			color = rgba(182, 198, 214, 255), -- 953
			opacity = 0.98, -- 954
			sortBias = 0.32 -- 955
		} -- 955
	) -- 955
end -- 927
function VillageUndertableScene.prototype.buildSoftDirtPatch(self, scene, softX) -- 960
	scene:addBox({ -- 961
		x0 = softX - 24, -- 962
		x1 = softX + 24, -- 963
		y0 = -4, -- 964
		y1 = 1.5, -- 965
		z0 = -16, -- 966
		z1 = 28, -- 967
		material = MAT_SOFT_EARTH, -- 968
		bucket = LP_BUCKET.WALK_DECK, -- 969
		sortBias = 0.15, -- 970
		edgeWidth = 0.4 -- 971
	}) -- 971
end -- 960
function VillageUndertableScene.prototype.buildHardBrickPatch(self, scene, brickX) -- 975
	local col = 0 -- 977
	do -- 977
		col = 0 -- 978
		while col < 3 do -- 978
			local bx0 = brickX - 24 + col * 16 -- 979
			local bx1 = bx0 + 14.5 -- 980
			scene:addBox({ -- 981
				x0 = bx0, -- 982
				x1 = bx1, -- 983
				y0 = -4, -- 984
				y1 = 3.2, -- 985
				z0 = -14, -- 986
				z1 = 6, -- 987
				material = MAT_HARD_BRICK, -- 988
				bucket = LP_BUCKET.WALK_DECK, -- 989
				sortBias = 0.2 + col * 0.01, -- 990
				highlightTopEdge = true, -- 991
				edgeWidth = 1 -- 992
			}) -- 992
			scene:addBox({ -- 994
				x0 = bx0 + 4, -- 995
				x1 = bx1 + 4, -- 996
				y0 = -4, -- 997
				y1 = 2.8, -- 998
				z0 = 8, -- 999
				z1 = 26, -- 1000
				material = MAT_HARD_BRICK, -- 1001
				bucket = LP_BUCKET.WALK_DECK, -- 1002
				sortBias = 0.18 + col * 0.01, -- 1003
				highlightTopEdge = true, -- 1004
				edgeWidth = 0.9 -- 1005
			}) -- 1005
			col = col + 1 -- 978
		end -- 978
	end -- 978
end -- 975
function VillageUndertableScene.prototype.buildIronBasin(self, scene, basinX) -- 1010
	scene:addBox({ -- 1012
		x0 = basinX - 14, -- 1013
		x1 = basinX + 14, -- 1014
		y0 = -2, -- 1015
		y1 = 3, -- 1016
		z0 = -10, -- 1017
		z1 = 14, -- 1018
		material = MING_MATERIALS.mingBrickDark, -- 1019
		bucket = LP_BUCKET.PROP, -- 1020
		sortBias = 0.02 -- 1021
	}) -- 1021
	local tilt = self.basinShakeAngle -- 1024
	local shiftX = math.sin(tilt * 1.4) * 2.5 -- 1025
	local bx = basinX + shiftX -- 1026
	scene:addCutout3D( -- 1027
		"assets/art/diorama_cutouts.clip|iron_basin", -- 1028
		bx, -- 1029
		2, -- 1030
		-8, -- 1030
		38, -- 1032
		17.5, -- 1033
		{ -- 1034
			bucket = LP_BUCKET.PROP, -- 1035
			anchorX = 0.5, -- 1036
			anchorY = 0, -- 1037
			angle = -(tilt * 180) / math.pi, -- 1038
			color = rgba(214, 224, 236, 255), -- 1039
			opacity = 0.99, -- 1040
			sortBias = 0.28 -- 1041
		} -- 1041
	) -- 1041
end -- 1010
function VillageUndertableScene.prototype.drawSurfaceReadabilityDetails(self, fgDraw, fgGlow, p, cam, softX, culvertX, basinX, brickX) -- 1046
	local y0 = cam:sy(0) -- 1056
	local sx0 = cam:sx(softX - 20) -- 1059
	local sx1 = cam:sx(softX + 20) -- 1060
	local d = 0 -- 1061
	do -- 1061
		d = 0 -- 1062
		while d < 9 do -- 1062
			local dx = sx0 + (sx1 - sx0) * (d + 0.5) / 9 -- 1063
			local dy = y0 - 2.5 + (d % 3 - 1) * 1.8 -- 1064
			fgDraw:drawDot( -- 1065
				Vec2(dx, dy), -- 1065
				1.3, -- 1065
				Color(116, 98, 78, 175) -- 1065
			) -- 1065
			d = d + 1 -- 1062
		end -- 1062
	end -- 1062
	fgDraw:drawEllipse( -- 1067
		Vec2( -- 1067
			cam:sx(softX - 7), -- 1067
			y0 - 1.5 -- 1067
		), -- 1067
		cam:len(4.2), -- 1067
		1.6, -- 1067
		Color(38, 30, 24, 185) -- 1067
	) -- 1067
	fgDraw:drawEllipse( -- 1068
		Vec2( -- 1068
			cam:sx(softX + 8), -- 1068
			y0 - 2 -- 1068
		), -- 1068
		cam:len(4.2), -- 1068
		1.6, -- 1068
		Color(38, 30, 24, 185) -- 1068
	) -- 1068
	local cL = cam:sx(culvertX - 11) -- 1071
	local cR = cam:sx(culvertX + 11) -- 1072
	local cTop = cam:sy(25) -- 1073
	fgDraw:drawSegment( -- 1074
		Vec2(cL, cTop), -- 1074
		Vec2(cR, cTop), -- 1074
		1.6, -- 1074
		Color(196, 210, 224, 210) -- 1074
	) -- 1074
	local rippleShift = math.sin(self.animTime * 2.3) * 3 -- 1075
	fgGlow:drawSegment( -- 1076
		Vec2(cL + 3 + rippleShift, y0 + 2), -- 1076
		Vec2(cR - 4 + rippleShift, y0 + 2), -- 1076
		1.1, -- 1076
		Color(164, 192, 214, 105) -- 1076
	) -- 1076
	local bPtL = projectWorld3D( -- 1079
		basinX - 16, -- 1079
		14.5 + math.sin(self.basinShakeAngle) * 14, -- 1079
		-12, -- 1079
		cam, -- 1079
		self.proj -- 1079
	) -- 1079
	local bPtR = projectWorld3D( -- 1080
		basinX + 16, -- 1080
		14.5 - math.sin(self.basinShakeAngle) * 14, -- 1080
		-12, -- 1080
		cam, -- 1080
		self.proj -- 1080
	) -- 1080
	local shakeBoost = self.basinShakeTimer > 0 and clamp01(self.basinShakeTimer / self.basinShakeMax) or 0 -- 1081
	local rimAlpha = math.floor(205 + 48 * shakeBoost + 0.5) -- 1082
	fgDraw:drawSegment( -- 1083
		Vec2(bPtL.x, bPtL.y), -- 1083
		Vec2(bPtR.x, bPtR.y), -- 1083
		2.1 + shakeBoost * 1.1, -- 1083
		Color(230, 236, 242, rimAlpha) -- 1083
	) -- 1083
	fillRadialGlow( -- 1084
		fgGlow, -- 1085
		(bPtL.x + bPtR.x) * 0.5, -- 1086
		(bPtL.y + bPtR.y) * 0.5, -- 1087
		cam:len(22 + shakeBoost * 18), -- 1088
		cam:len(10 + shakeBoost * 8), -- 1089
		Color( -- 1090
			216, -- 1090
			226, -- 1090
			236, -- 1090
			math.floor(48 + 95 * shakeBoost + 0.5) -- 1090
		), -- 1090
		Color(186, 202, 220, 0), -- 1091
		14 -- 1092
	) -- 1092
	local brL = cam:sx(brickX - 24) -- 1096
	local brR = cam:sx(brickX + 24) -- 1097
	local brTop = cam:sy(3.2) -- 1098
	fgDraw:drawSegment( -- 1099
		Vec2(brL, brTop), -- 1099
		Vec2(brR, brTop), -- 1099
		1.8, -- 1099
		Color(224, 228, 234, 225) -- 1099
	) -- 1099
	local k = 1 -- 1100
	do -- 1100
		k = 1 -- 1101
		while k <= 2 do -- 1101
			local seamX = brL + (brR - brL) * k / 3 -- 1102
			fgDraw:drawSegment( -- 1103
				Vec2(seamX, y0 - 3), -- 1103
				Vec2(seamX, brTop + 1), -- 1103
				1.5, -- 1103
				Color(20, 24, 32, 240) -- 1103
			) -- 1103
			fgDraw:drawSegment( -- 1104
				Vec2(seamX + 1.8, y0 - 2), -- 1104
				Vec2(seamX + 1.8, brTop), -- 1104
				0.9, -- 1104
				Color(214, 218, 224, 175) -- 1104
			) -- 1104
			k = k + 1 -- 1101
		end -- 1101
	end -- 1101
	local i = 0 -- 1108
	do -- 1108
		i = 0 -- 1109
		while i < #self.rings do -- 1109
			do -- 1109
				local rg = self.rings[i + 1] -- 1110
				if rg.age < 0 then -- 1110
					goto __continue73 -- 1112
				end -- 1112
				local t = clamp01(rg.age / rg.duration) -- 1114
				local r = math.max( -- 1115
					4, -- 1115
					cam:len(rg.maxRadius) * (0.14 + 0.86 * t) -- 1115
				) -- 1115
				local alpha = (1 - t) * (rg.kind == "iron" and 0.88 or (rg.kind == "brick" and 0.82 or 0.4)) -- 1116
				local rx = cam:sx(rg.x) -- 1117
				local ry = cam:sy(rg.y) -- 1118
				local ringCol = rg.kind == "iron" and Color( -- 1119
					220, -- 1120
					234, -- 1120
					246, -- 1120
					math.floor(235 * alpha + 0.5) -- 1120
				) or (rg.kind == "brick" and Color( -- 1120
					236, -- 1122
					216, -- 1122
					178, -- 1122
					math.floor(225 * alpha + 0.5) -- 1122
				) or Color( -- 1122
					148, -- 1123
					134, -- 1123
					114, -- 1123
					math.floor(165 * alpha + 0.5) -- 1123
				)) -- 1123
				drawEllipseRing( -- 1124
					fgGlow, -- 1124
					rx, -- 1124
					ry, -- 1124
					r, -- 1124
					r * 0.34, -- 1124
					rg.kind == "iron" and 1.8 or 1.4, -- 1124
					ringCol, -- 1124
					22 -- 1124
				) -- 1124
				if rg.kind == "iron" then -- 1124
					drawEllipseRing( -- 1126
						fgDraw, -- 1126
						rx, -- 1126
						ry, -- 1126
						r * 0.96, -- 1126
						r * 0.32, -- 1126
						1.1, -- 1126
						Color( -- 1126
							214, -- 1126
							224, -- 1126
							236, -- 1126
							math.floor(150 * alpha + 0.5) -- 1126
						), -- 1126
						22 -- 1126
					) -- 1126
				end -- 1126
			end -- 1126
			::__continue73:: -- 1126
			i = i + 1 -- 1109
		end -- 1109
	end -- 1109
	do -- 1109
		i = 0 -- 1129
		while i < #self.shards do -- 1129
			local sp = self.shards[i + 1] -- 1130
			local a = clamp01(sp.life / sp.maxLife) -- 1131
			local col = sp.kind == "soft" and Color( -- 1132
				138, -- 1133
				120, -- 1133
				98, -- 1133
				math.floor(170 * a + 0.5) -- 1133
			) or (sp.kind == "iron" and Color( -- 1133
				224, -- 1135
				232, -- 1135
				242, -- 1135
				math.floor(225 * a + 0.5) -- 1135
			) or Color( -- 1135
				216, -- 1136
				198, -- 1136
				174, -- 1136
				math.floor(220 * a + 0.5) -- 1136
			)) -- 1136
			fgDraw:drawDot( -- 1137
				Vec2( -- 1137
					cam:sx(sp.x), -- 1137
					cam:sy(sp.y) -- 1137
				), -- 1137
				sp.size, -- 1137
				col -- 1137
			) -- 1137
			i = i + 1 -- 1129
		end -- 1129
	end -- 1129
	if p.bottleLandT > 0 and p.bottleLandX >= 0 and #self.rings == 0 then -- 1129
		local rx = cam:sx(p.bottleLandX) -- 1142
		local ry = cam:sy(math.max(1, p.bottleLandY)) -- 1143
		fgDraw:drawDot( -- 1144
			Vec2(rx, ry), -- 1144
			2.5, -- 1144
			Color(216, 206, 186, 150) -- 1144
		) -- 1144
	end -- 1144
end -- 1046
function VillageUndertableScene.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1149
	local p = ctx.p -- 1155
	local cam = ctx.cam -- 1156
	local bottle = p.room.bottle -- 1159
	if bottle ~= nil and not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 1159
		self:drawCeramicBottle( -- 1161
			fgDraw, -- 1161
			fgGlow, -- 1161
			worldArt, -- 1161
			"fe04_bottle_shelf", -- 1161
			cam:sx(bottle.x), -- 1161
			cam:sy(56), -- 1161
			cam.ppu, -- 1161
			0, -- 1161
			true -- 1161
		) -- 1161
	end -- 1161
	if p.hasBottle and p.aimHold <= 0 then -- 1161
		local pl = p.player -- 1166
		self:drawCeramicBottle( -- 1167
			fgDraw, -- 1168
			fgGlow, -- 1169
			worldArt, -- 1170
			"fe04_bottle_held", -- 1171
			cam:sx(pl.x + pl.facing * 10), -- 1172
			cam:sy(pl.y + pl.h * 0.52), -- 1173
			cam.ppu, -- 1174
			pl.facing * 0.22, -- 1175
			false -- 1176
		) -- 1176
	end -- 1176
	if p.bottleFly ~= nil then -- 1176
		self:drawCeramicBottle( -- 1180
			fgDraw, -- 1181
			fgGlow, -- 1182
			worldArt, -- 1183
			"fe04_bottle_air", -- 1184
			cam:sx(p.bottleFly.x), -- 1185
			cam:sy(p.bottleFly.y), -- 1186
			cam.ppu, -- 1187
			self.animTime * 13.5, -- 1188
			false -- 1189
		) -- 1189
	end -- 1189
	if p.hasBottle and p.aimHold > 0 then -- 1189
		local pl = p.player -- 1195
		local endX = p.bottleAimX -- 1196
		local endY = p.bottleAimY -- 1197
		if endX < 0 then -- 1197
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 1199
			endX = wAim.x -- 1200
			endY = 0 -- 1201
		end -- 1201
		local dir = endX >= pl.x and 1 or -1 -- 1203
		local x0 = pl.x + dir * 10 -- 1204
		local y0 = pl.y + pl.h * 0.7 -- 1205
		local vx = (endX - x0) / BOTTLE_FLY_T -- 1206
		local vy = (endY - y0 + 0.5 * GRAVITY * BOTTLE_FLY_T * BOTTLE_FLY_T) / BOTTLE_FLY_T -- 1207
		local previewSurface = self:classifyLandingSurface(p, endX) -- 1209
		local arcRgb = previewSurface == "iron" and rgba(214, 228, 242, 255) or (previewSurface == "brick" and rgba(232, 206, 152, 255) or rgba(154, 142, 126, 255)) -- 1210
		local steps = 18 -- 1216
		local k = 1 -- 1217
		do -- 1217
			k = 1 -- 1218
			while k <= steps do -- 1218
				local tt = k / steps * BOTTLE_FLY_T -- 1219
				local wx = x0 + vx * tt -- 1220
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 1221
				local alpha = 195 * (0.4 + 0.6 * (k / steps)) -- 1222
				fgDraw:drawDot( -- 1223
					Vec2( -- 1223
						cam:sx(wx), -- 1223
						cam:sy(wy) -- 1223
					), -- 1223
					2.5, -- 1223
					toColor(arcRgb, alpha) -- 1223
				) -- 1223
				fgGlow:drawDot( -- 1224
					Vec2( -- 1224
						cam:sx(wx), -- 1224
						cam:sy(wy) -- 1224
					), -- 1224
					3.2, -- 1224
					toColor(arcRgb, alpha * 0.55) -- 1224
				) -- 1224
				k = k + 1 -- 1218
			end -- 1218
		end -- 1218
		local lx = cam:sx(endX) -- 1227
		local ly = cam:sy(endY + 2) -- 1228
		local pulse = 0.88 + 0.12 * math.sin(self.animTime * 5.2) -- 1229
		drawEllipseRing( -- 1230
			fgDraw, -- 1230
			lx, -- 1230
			ly, -- 1230
			11 * pulse, -- 1230
			4.2 * pulse, -- 1230
			1.6, -- 1230
			toColor(arcRgb, 235), -- 1230
			20 -- 1230
		) -- 1230
		if previewSurface == "iron" then -- 1230
			drawEllipseRing( -- 1232
				fgGlow, -- 1232
				lx, -- 1232
				ly, -- 1232
				24 * pulse, -- 1232
				9.2 * pulse, -- 1232
				1.3, -- 1232
				toColor(arcRgb, 195), -- 1232
				22 -- 1232
			) -- 1232
		elseif previewSurface == "brick" then -- 1232
			drawEllipseRing( -- 1234
				fgGlow, -- 1234
				lx, -- 1234
				ly, -- 1234
				18 * pulse, -- 1234
				7 * pulse, -- 1234
				1.2, -- 1234
				toColor(arcRgb, 165), -- 1234
				20 -- 1234
			) -- 1234
		end -- 1234
	end -- 1234
	return true -- 1238
end -- 1149
function VillageUndertableScene.prototype.drawCeramicBottle(self, fgDraw, fgGlow, worldArt, id, cx, cy, ppu, tilt, shelfGlint) -- 1241
	local size = math.max(10, ppu * 10.5) -- 1252
	if not worldArt:tryPlace( -- 1252
		"prop_bottle", -- 1253
		id, -- 1253
		cx, -- 1253
		cy, -- 1253
		size, -- 1253
		size, -- 1253
		{angle = tilt * 180 / math.pi, layer = 8} -- 1253
	) then -- 1253
		fgDraw:drawCircle( -- 1257
			Vec2(cx, cy), -- 1257
			size * 0.36, -- 1257
			Color(172, 138, 102, 245) -- 1257
		) -- 1257
	end -- 1257
	if shelfGlint then -- 1257
		local p = 0.72 + 0.28 * math.sin(self.animTime * 3) -- 1260
		fillRadialGlow( -- 1261
			fgGlow, -- 1261
			cx, -- 1261
			cy + 2, -- 1261
			14 * p, -- 1261
			14 * p, -- 1261
			Color( -- 1261
				224, -- 1261
				214, -- 1261
				190, -- 1261
				math.floor(62 * p + 0.5) -- 1261
			), -- 1261
			Color(224, 214, 190, 0), -- 1261
			12 -- 1261
		) -- 1261
	end -- 1261
end -- 1241
function VillageUndertableScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1266
	local p = ctx.p -- 1272
	local cam = ctx.cam -- 1273
	if p.room.scavenger ~= nil then -- 1273
		self:drawScavengerShoeOverlay( -- 1275
			fgDraw, -- 1275
			fgGlow, -- 1275
			worldArt, -- 1275
			p, -- 1275
			cam -- 1275
		) -- 1275
	end -- 1275
	if ctx.paused then -- 1275
		local arch = p.room.arch -- 1280
		local pTopBL = projectWorld3D( -- 1281
			arch.x0 - 8, -- 1281
			arch.h, -- 1281
			-15, -- 1281
			cam, -- 1281
			self.proj -- 1281
		) -- 1281
		local pTopTR = projectWorld3D( -- 1282
			arch.x1 + 8, -- 1282
			arch.h + 8, -- 1282
			-15, -- 1282
			cam, -- 1282
			self.proj -- 1282
		) -- 1282
		worldArt:tryPlace( -- 1283
			"cover_wood", -- 1284
			"fe04_pause_table_top", -- 1285
			(pTopBL.x + pTopTR.x) * 0.5, -- 1286
			pTopBL.y, -- 1287
			math.max( -- 1288
				20, -- 1288
				math.abs(pTopTR.x - pTopBL.x) -- 1288
			), -- 1288
			math.max( -- 1289
				8, -- 1289
				math.abs(pTopTR.y - pTopBL.y) -- 1289
			), -- 1289
			{ -- 1290
				color = Color(46, 35, 27, 255), -- 1290
				opacity = 0.96, -- 1290
				layer = 5300 -- 1290
			} -- 1290
		) -- 1290
		local legBL = projectWorld3D( -- 1292
			arch.x1 - 6, -- 1292
			0, -- 1292
			-15, -- 1292
			cam, -- 1292
			self.proj -- 1292
		) -- 1292
		local legTR = projectWorld3D( -- 1293
			arch.x1 + 1, -- 1293
			arch.h, -- 1293
			-15, -- 1293
			cam, -- 1293
			self.proj -- 1293
		) -- 1293
		worldArt:tryPlace( -- 1294
			"cover_wood", -- 1295
			"fe04_pause_table_leg", -- 1296
			(legBL.x + legTR.x) * 0.5, -- 1297
			legBL.y, -- 1298
			math.max( -- 1299
				6, -- 1299
				math.abs(legTR.x - legBL.x) -- 1299
			), -- 1299
			math.max( -- 1300
				16, -- 1300
				math.abs(legTR.y - legBL.y) -- 1300
			), -- 1300
			{ -- 1301
				color = Color(34, 25, 19, 255), -- 1301
				opacity = 0.96, -- 1301
				layer = 5310 -- 1301
			} -- 1301
		) -- 1301
	end -- 1301
end -- 1266
function VillageUndertableScene.prototype.drawScavengerShoeOverlay(self, fgDraw, fgGlow, worldArt, p, cam) -- 1306
	local cx = cam:sx(p.scavX) -- 1313
	local by = cam:sy(p.room.scavenger ~= nil and p.room.scavenger.y or 0) -- 1314
	local f = self.shoeFacing >= 0 and 1 or -1 -- 1315
	local moving = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 1316
	local pausedToe = self.shoeToePauseTimer > 0 -- 1317
	fillRadialGlow( -- 1320
		fgGlow, -- 1320
		cx + f * cam:len(4), -- 1320
		by + 2, -- 1320
		cam:len(34), -- 1320
		cam:len(9), -- 1320
		Color(196, 208, 220, 52), -- 1320
		Color(156, 172, 190, 0), -- 1320
		14 -- 1320
	) -- 1320
	fgDraw:drawEllipse( -- 1321
		Vec2( -- 1321
			cx + f * cam:len(2), -- 1321
			by + 1 -- 1321
		), -- 1321
		cam:len(19), -- 1321
		cam:len(3.4), -- 1321
		Color(74, 82, 92, 68) -- 1321
	) -- 1321
	local stepB = moving and math.sin(self.scavStridePhase) < 0 -- 1324
	local framePath = stepB and "assets/art/diorama_cutouts.clip|scav_legs_b" or "assets/art/diorama_cutouts.clip|scav_legs_a" -- 1325
	local bobY = moving and math.abs(math.sin(self.scavStridePhase)) * cam:len(1.8) or 0 -- 1328
	local tiltDeg = moving and math.sin(self.scavStridePhase) * 3.5 * f or 0 -- 1329
	local legsH = cam:len(23) -- 1330
	local legsW = legsH * (394 / 342) -- 1331
	worldArt:tryPlacePath( -- 1332
		framePath, -- 1332
		"fe04_scav_painted_legs", -- 1332
		cx, -- 1332
		by - 1 + bobY, -- 1332
		legsW, -- 1332
		legsH, -- 1332
		{ -- 1332
			anchorX = 0.5, -- 1333
			anchorY = 0, -- 1334
			facing = f, -- 1335
			angle = tiltDeg, -- 1336
			color = Color(204, 212, 224, 255), -- 1337
			opacity = 0.94, -- 1338
			smooth = true, -- 1339
			layer = 4650 -- 1340
		} -- 1340
	) -- 1340
	if pausedToe then -- 1340
		fgGlow:drawDot( -- 1343
			Vec2( -- 1343
				cx + f * cam:len(10), -- 1343
				by + 2 -- 1343
			), -- 1343
			3.4, -- 1343
			Color(236, 218, 178, 165) -- 1343
		) -- 1343
	end -- 1343
end -- 1306
function VillageUndertableScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, uiArt, _uiGlow, ctx) -- 1354
	local p = ctx.p -- 1361
	local cam = ctx.cam -- 1362
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1363
	local arch = p.room.arch -- 1364
	local xLeft = arch.x0 - 8 -- 1366
	local xRight = arch.x1 + 8 -- 1367
	local tableBotY = arch.h -- 1368
	local tableTopY = arch.h + 8 -- 1369
	local zFront = -15 -- 1370
	local zMid = 4 -- 1371
	local fTopL = projectWorld3D( -- 1374
		xLeft, -- 1374
		tableTopY, -- 1374
		zFront, -- 1374
		cam, -- 1374
		self.proj -- 1374
	) -- 1374
	local fTopR = projectWorld3D( -- 1375
		xRight, -- 1375
		tableTopY, -- 1375
		zFront, -- 1375
		cam, -- 1375
		self.proj -- 1375
	) -- 1375
	local topBackL = projectWorld3D( -- 1376
		xLeft, -- 1376
		tableTopY, -- 1376
		zMid, -- 1376
		cam, -- 1376
		self.proj -- 1376
	) -- 1376
	local topBackR = projectWorld3D( -- 1377
		xRight, -- 1377
		tableTopY, -- 1377
		zMid, -- 1377
		cam, -- 1377
		self.proj -- 1377
	) -- 1377
	drawUiQuad( -- 1378
		uiDraw, -- 1378
		fTopL, -- 1378
		fTopR, -- 1378
		topBackR, -- 1378
		topBackL, -- 1378
		Color(46, 35, 26, 240), -- 1378
		Color(28, 21, 16, 232), -- 1378
		inv, -- 1378
		Color(118, 98, 78, 115), -- 1378
		0.7 -- 1378
	) -- 1378
	local pBL = projectWorld3D( -- 1381
		xLeft, -- 1381
		0, -- 1381
		zFront, -- 1381
		cam, -- 1381
		self.proj -- 1381
	) -- 1381
	local pBR = projectWorld3D( -- 1382
		xRight, -- 1382
		0, -- 1382
		zFront, -- 1382
		cam, -- 1382
		self.proj -- 1382
	) -- 1382
	local tblW = math.max(24, (pBR.x - pBL.x) * inv) -- 1383
	local tblH = math.max(18, (fTopL.y - pBL.y) * inv) -- 1384
	local tblCx = (pBL.x + pBR.x) * 0.5 * inv -- 1385
	local tblBot = pBL.y * inv -- 1386
	local placedTable = uiArt:tryPlacePath( -- 1387
		"assets/art/diorama_cutouts.clip|table_apron_frame", -- 1388
		"fe04_village_fg_table_frame", -- 1389
		tblCx, -- 1390
		tblBot, -- 1391
		tblW * 1.03, -- 1392
		tblH * 1.04, -- 1393
		{ -- 1394
			anchorX = 0.5, -- 1395
			anchorY = 0, -- 1396
			color = Color(172, 158, 146, 255), -- 1397
			opacity = 0.98, -- 1398
			smooth = true, -- 1399
			layer = 1 -- 1400
		} -- 1400
	) -- 1400
	if not placedTable then -- 1400
		local bNearL = projectWorld3D( -- 1404
			xLeft, -- 1404
			tableBotY, -- 1404
			zFront, -- 1404
			cam, -- 1404
			self.proj -- 1404
		) -- 1404
		local bNearR = projectWorld3D( -- 1405
			xRight, -- 1405
			tableBotY, -- 1405
			zFront, -- 1405
			cam, -- 1405
			self.proj -- 1405
		) -- 1405
		drawUiQuad( -- 1406
			uiDraw, -- 1406
			bNearL, -- 1406
			bNearR, -- 1406
			fTopR, -- 1406
			fTopL, -- 1406
			Color(38, 28, 21, 252), -- 1406
			Color(56, 42, 32, 254), -- 1406
			inv -- 1406
		) -- 1406
	end -- 1406
	uiArt:tryPlacePath( -- 1410
		"assets/art/diorama_cutouts.clip|hemp_tablecloth", -- 1411
		"fe04_village_fg_tablecloth", -- 1412
		pBL.x * inv + tblW * 0.08, -- 1413
		fTopL.y * inv + 2, -- 1414
		tblW * 0.24, -- 1415
		tblH * 0.42, -- 1416
		{ -- 1417
			anchorX = 0.5, -- 1418
			anchorY = 1, -- 1419
			color = Color(136, 132, 126, 255), -- 1420
			opacity = 0.9, -- 1421
			smooth = true, -- 1422
			layer = 2 -- 1423
		} -- 1423
	) -- 1423
	local bowlPt = projectWorld3D( -- 1428
		arch.x0 + 31, -- 1428
		tableTopY, -- 1428
		-5, -- 1428
		cam, -- 1428
		self.proj -- 1428
	) -- 1428
	local bowlW = cam:len(17) * inv -- 1429
	local bowlH = bowlW * (248 / 326) -- 1430
	uiArt:tryPlacePath( -- 1431
		"assets/art/cutscene_story_parts.clip|porridge_bowl", -- 1432
		"fe04_village_table_bowl", -- 1433
		bowlPt.x * inv, -- 1434
		bowlPt.y * inv - 2, -- 1435
		bowlW, -- 1436
		bowlH, -- 1437
		{ -- 1438
			anchorX = 0.5, -- 1439
			anchorY = 0, -- 1440
			color = Color(152, 158, 166, 255), -- 1441
			opacity = 0.94, -- 1442
			smooth = true, -- 1443
			layer = 2 -- 1444
		} -- 1444
	) -- 1444
	if p.player.crouch and p.player.x >= arch.x0 - 16 and p.player.x <= arch.x1 + 16 then -- 1444
		local topBandH = ctx.uiH * 0.14 -- 1450
		fillVGradRect( -- 1451
			uiDraw, -- 1452
			0, -- 1453
			ctx.uiH - topBandH, -- 1454
			ctx.uiW, -- 1455
			topBandH, -- 1456
			Color(12, 10, 9, 0), -- 1457
			Color(12, 10, 9, 138) -- 1458
		) -- 1458
	end -- 1458
	return false -- 1463
end -- 1354
return ____exports -- 1354