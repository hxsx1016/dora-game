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
local vec3 = ____lowpoly.vec3 -- 35
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
	scene:addBox({ -- 615
		x0 = ox + 460, -- 616
		x1 = ox + 690, -- 617
		y0 = 0, -- 618
		y1 = 118, -- 619
		z0 = 210, -- 620
		z1 = 260, -- 621
		material = MING_MATERIALS.distantWall, -- 622
		bucket = LP_BUCKET.BACKDROP, -- 623
		edgeWidth = 0 -- 624
	}) -- 624
	scene:addTri3D( -- 626
		vec3(ox + 446, 118, 206), -- 627
		vec3(ox + 704, 118, 206), -- 628
		vec3(ox + 575, 162, 232), -- 629
		MING_MATERIALS.mingTile, -- 630
		{bucket = LP_BUCKET.BACKDROP, sortBias = 0.04} -- 631
	) -- 631
	scene:addBox({ -- 635
		x0 = ox - 60, -- 636
		x1 = ox + 436, -- 637
		y0 = 0, -- 638
		y1 = 196, -- 639
		z0 = 112, -- 640
		z1 = 152, -- 641
		material = MING_MATERIALS.mingBrickDark, -- 642
		bucket = LP_BUCKET.BACKDROP, -- 643
		edgeWidth = 0.6 -- 644
	}) -- 644
	scene:addBox({ -- 648
		x0 = ox + 150, -- 649
		x1 = ox + 258, -- 650
		y0 = 0, -- 651
		y1 = 42, -- 652
		z0 = 76, -- 653
		z1 = 112, -- 654
		material = MAT_CLAY_STOVE, -- 655
		bucket = LP_BUCKET.MIDGROUND, -- 656
		highlightTopEdge = true -- 657
	}) -- 657
	scene:addBox({ -- 659
		x0 = ox + 178, -- 660
		x1 = ox + 228, -- 661
		y0 = 42, -- 662
		y1 = 156, -- 663
		z0 = 94, -- 664
		z1 = 114, -- 665
		material = MAT_CLAY_STOVE, -- 666
		bucket = LP_BUCKET.MIDGROUND, -- 667
		edgeWidth = 0.5 -- 668
	}) -- 668
	scene:addBox({ -- 672
		x0 = ox + 486, -- 673
		x1 = ox + 536, -- 674
		y0 = 0, -- 675
		y1 = 34, -- 676
		z0 = 126, -- 677
		z1 = 162, -- 678
		material = MING_MATERIALS.mingStoneStep, -- 679
		bucket = LP_BUCKET.MIDGROUND, -- 680
		highlightTopEdge = true -- 681
	}) -- 681
	scene:addFogBand( -- 685
		ox - 120, -- 685
		ox + 840, -- 685
		-10, -- 685
		140, -- 685
		260, -- 685
		rgba(24, 30, 42, 255), -- 685
		0.62, -- 685
		0.05, -- 685
		{bucket = LP_BUCKET.BACKDROP} -- 685
	) -- 685
	scene:flush(bgDraw, bgGlow, ctx.dioramaBg) -- 689
	local mx = w * 0.8 -- 692
	local my = h * 0.84 -- 693
	fillRadialGlow( -- 694
		bgGlow, -- 694
		mx, -- 694
		my, -- 694
		96, -- 694
		96, -- 694
		Color(188, 206, 224, 24), -- 694
		Color(24, 32, 46, 0), -- 694
		16 -- 694
	) -- 694
	bgDraw:drawCircle( -- 695
		Vec2(mx, my), -- 695
		14, -- 695
		Color(214, 224, 236, 130) -- 695
	) -- 695
	local towerPt = projectWorld3D( -- 698
		ox + 668, -- 698
		152, -- 698
		410, -- 698
		cam, -- 698
		self.proj -- 698
	) -- 698
	fillRadialGlow( -- 699
		bgGlow, -- 699
		towerPt.x, -- 699
		towerPt.y, -- 699
		20, -- 699
		20, -- 699
		Color(238, 198, 132, 54), -- 699
		Color(238, 198, 132, 0), -- 699
		12 -- 699
	) -- 699
	bgGlow:drawDot( -- 700
		Vec2(towerPt.x, towerPt.y), -- 700
		2, -- 700
		Color(252, 232, 186, 185) -- 700
	) -- 700
	return true -- 702
end -- 580
function VillageUndertableScene.prototype.drawWorld(self, fgDraw, fgGlow, _worldArt, ctx) -- 705
	local p = ctx.p -- 711
	local cam = ctx.cam -- 712
	local ox = p.ox -- 713
	local scene = __TS__New(LowpolyScene, cam, self.proj, VILLAGE_UNDERTABLE_LIGHT) -- 714
	scene:addBox({ -- 717
		x0 = ox - 40, -- 718
		x1 = ox + 436, -- 719
		y0 = -52, -- 720
		y1 = 0, -- 721
		z0 = -32, -- 722
		z1 = 112, -- 723
		material = MING_MATERIALS.mingTimberDark, -- 724
		bucket = LP_BUCKET.MIDGROUND, -- 725
		highlightTopEdge = true, -- 726
		edgeWidth = 0.7 -- 727
	}) -- 727
	scene:addBox({ -- 729
		x0 = ox + 436, -- 730
		x1 = ox + 760, -- 731
		y0 = -52, -- 732
		y1 = 0, -- 733
		z0 = -32, -- 734
		z1 = 126, -- 735
		material = MING_MATERIALS.mingBrickDark, -- 736
		bucket = LP_BUCKET.MIDGROUND, -- 737
		highlightTopEdge = true, -- 738
		edgeWidth = 0.8 -- 739
	}) -- 739
	scene:addBeveledFrame( -- 743
		ox + 416, -- 743
		ox + 462, -- 743
		0, -- 743
		128, -- 743
		16, -- 743
		22, -- 743
		16, -- 743
		112, -- 743
		MING_MATERIALS.mingTimberDark, -- 743
		{ -- 743
			bucket = LP_BUCKET.MIDGROUND, -- 744
			innerRimLight = rgba(206, 214, 222, 255), -- 745
			innerRimStrength = 0.42 -- 746
		} -- 746
	) -- 746
	scene:addBox({ -- 750
		x0 = ox + 96, -- 751
		x1 = ox + 101, -- 752
		y0 = 0, -- 753
		y1 = 52, -- 754
		z0 = -6, -- 755
		z1 = 24, -- 756
		material = MAT_TABLE_WOOD, -- 757
		bucket = LP_BUCKET.WALK_DECK, -- 758
		edgeWidth = 0.8 -- 759
	}) -- 759
	scene:addBox({ -- 761
		x0 = ox + 123, -- 762
		x1 = ox + 128, -- 763
		y0 = 0, -- 764
		y1 = 52, -- 765
		z0 = -6, -- 766
		z1 = 24, -- 767
		material = MAT_TABLE_WOOD, -- 768
		bucket = LP_BUCKET.WALK_DECK, -- 769
		edgeWidth = 0.8 -- 770
	}) -- 770
	scene:addBox({ -- 772
		x0 = ox + 95, -- 773
		x1 = ox + 129, -- 774
		y0 = 24, -- 775
		y1 = 28, -- 776
		z0 = -8, -- 777
		z1 = 26, -- 778
		material = MING_MATERIALS.mingTimber, -- 779
		bucket = LP_BUCKET.WALK_DECK, -- 780
		sortBias = 0.05 -- 781
	}) -- 781
	scene:addBox({ -- 783
		x0 = ox + 94, -- 784
		x1 = ox + 130, -- 785
		y0 = 48, -- 786
		y1 = 52, -- 787
		z0 = -8, -- 788
		z1 = 26, -- 789
		material = MING_MATERIALS.mingTimber, -- 790
		bucket = LP_BUCKET.WALK_DECK, -- 791
		highlightTopEdge = true, -- 792
		sortBias = 0.06 -- 793
	}) -- 793
	scene:addBox({ -- 796
		x0 = ox + 672, -- 797
		x1 = ox + 720, -- 798
		y0 = 0, -- 799
		y1 = 96, -- 800
		z0 = -14, -- 801
		z1 = 96, -- 802
		material = MING_MATERIALS.mingBrick, -- 803
		bucket = LP_BUCKET.MIDGROUND, -- 804
		highlightTopEdge = true, -- 805
		edgeWidth = 0.9 -- 806
	}) -- 806
	scene:addBox({ -- 808
		x0 = ox + 666, -- 809
		x1 = ox + 726, -- 810
		y0 = 96, -- 811
		y1 = 106, -- 812
		z0 = -18, -- 813
		z1 = 100, -- 814
		material = MING_MATERIALS.mingTile, -- 815
		bucket = LP_BUCKET.MIDGROUND, -- 816
		sortBias = 0.08 -- 817
	}) -- 817
	local arch = p.room.arch -- 822
	scene:addBox({ -- 824
		x0 = arch.x0 - 1, -- 825
		x1 = arch.x0 + 7, -- 826
		y0 = 0, -- 827
		y1 = arch.h, -- 828
		z0 = 12, -- 829
		z1 = 22, -- 830
		material = MAT_TABLE_WOOD, -- 831
		bucket = LP_BUCKET.MIDGROUND, -- 832
		edgeWidth = 0.8 -- 833
	}) -- 833
	scene:addBox({ -- 835
		x0 = arch.x1 - 7, -- 836
		x1 = arch.x1 + 1, -- 837
		y0 = 0, -- 838
		y1 = arch.h, -- 839
		z0 = 12, -- 840
		z1 = 22, -- 841
		material = MAT_TABLE_WOOD, -- 842
		bucket = LP_BUCKET.MIDGROUND, -- 843
		edgeWidth = 0.8 -- 844
	}) -- 844
	scene:addBox({ -- 847
		x0 = arch.x0 + 7, -- 848
		x1 = arch.x1 - 7, -- 849
		y0 = arch.h - 5, -- 850
		y1 = arch.h, -- 851
		z0 = 14, -- 852
		z1 = 20, -- 853
		material = MAT_TABLE_WOOD, -- 854
		bucket = LP_BUCKET.MIDGROUND, -- 855
		edgeWidth = 0.6 -- 856
	}) -- 856
	scene:addBox({ -- 859
		x0 = arch.x0 - 8, -- 860
		x1 = arch.x1 + 8, -- 861
		y0 = arch.h, -- 862
		y1 = arch.h + 8, -- 863
		z0 = 4, -- 864
		z1 = 28, -- 865
		material = MAT_TABLE_WOOD, -- 866
		bucket = LP_BUCKET.WALK_DECK, -- 867
		highlightTopEdge = true, -- 868
		edgeWidth = 0.8 -- 869
	}) -- 869
	local culvertX = self:getCulvertWorldX(p) -- 873
	self:buildCulvertEntrance(scene, culvertX) -- 874
	local softX = self:getSoftWorldX(p) -- 878
	self:buildSoftDirtPatch(scene, softX) -- 879
	local brickX = self:getBrickWorldX(p) -- 882
	self:buildHardBrickPatch(scene, brickX) -- 883
	local basinX = self:getBasinWorldX(p) -- 886
	self:buildIronBasin(scene, basinX) -- 887
	scene:addLightShaft( -- 890
		ox + 570, -- 891
		ox + 710, -- 891
		290, -- 891
		ox + 446, -- 892
		ox + 642, -- 892
		0, -- 892
		24, -- 893
		rgba(218, 226, 218, 255), -- 894
		0.13, -- 895
		0.04 -- 896
	) -- 896
	scene:addContactShadow( -- 900
		p.player.x, -- 900
		p.player.y, -- 900
		14, -- 900
		10, -- 900
		0.8, -- 900
		{bucket = LP_BUCKET.PROP, sortBias = 0.4} -- 900
	) -- 900
	if p.room.scavenger ~= nil then -- 900
		scene:addContactShadow( -- 902
			p.scavX, -- 902
			p.room.scavenger.y, -- 902
			19, -- 902
			13, -- 902
			0.84, -- 902
			{bucket = LP_BUCKET.PROP, sortBias = 0.42} -- 902
		) -- 902
	end -- 902
	scene:flush(fgDraw, fgGlow, ctx.dioramaWorld) -- 905
	self:drawSurfaceReadabilityDetails( -- 908
		fgDraw, -- 908
		fgGlow, -- 908
		p, -- 908
		cam, -- 908
		softX, -- 908
		culvertX, -- 908
		basinX, -- 908
		brickX -- 908
	) -- 908
	return true -- 910
end -- 705
function VillageUndertableScene.prototype.buildCulvertEntrance(self, scene, cx) -- 913
	scene:addBox({ -- 915
		x0 = cx - 18, -- 916
		x1 = cx + 18, -- 917
		y0 = -12, -- 918
		y1 = 2, -- 919
		z0 = -6, -- 920
		z1 = 42, -- 921
		material = MAT_CULVERT_STONE, -- 922
		bucket = LP_BUCKET.WALK_DECK, -- 923
		highlightTopEdge = true, -- 924
		edgeWidth = 1 -- 925
	}) -- 925
	scene:addQuad3D( -- 928
		vec3(cx - 12, 1, 22), -- 929
		vec3(cx + 12, 1, 22), -- 930
		vec3(cx + 10, 26, 22), -- 931
		vec3(cx - 10, 26, 22), -- 932
		{base = rgba(6, 9, 14, 255)}, -- 933
		{ -- 934
			bucket = LP_BUCKET.MIDGROUND, -- 934
			unlit = true, -- 934
			sortBias = 0.35, -- 934
			edgeColor = rgba(186, 204, 222, 185), -- 934
			edgeWidth = 1.2 -- 934
		} -- 934
	) -- 934
	scene:addBox({ -- 937
		x0 = cx - 15, -- 938
		x1 = cx - 11, -- 939
		y0 = 2, -- 940
		y1 = 24, -- 941
		z0 = 14, -- 942
		z1 = 22, -- 943
		material = MING_MATERIALS.mingTimber, -- 944
		bucket = LP_BUCKET.PROP, -- 945
		highlightTopEdge = true -- 946
	}) -- 946
	local gi = 0 -- 948
	do -- 948
		gi = 0 -- 949
		while gi < 3 do -- 949
			local gx = cx - 6 + gi * 6 -- 950
			scene:addBox({ -- 951
				x0 = gx - 1, -- 952
				x1 = gx + 1, -- 953
				y0 = 2, -- 954
				y1 = 24, -- 955
				z0 = 18, -- 956
				z1 = 21, -- 957
				material = MING_MATERIALS.mingIron, -- 958
				bucket = LP_BUCKET.PROP, -- 959
				sortBias = 0.1 -- 960
			}) -- 960
			gi = gi + 1 -- 949
		end -- 949
	end -- 949
end -- 913
function VillageUndertableScene.prototype.buildSoftDirtPatch(self, scene, softX) -- 965
	scene:addBox({ -- 966
		x0 = softX - 24, -- 967
		x1 = softX + 24, -- 968
		y0 = -4, -- 969
		y1 = 1.5, -- 970
		z0 = -16, -- 971
		z1 = 28, -- 972
		material = MAT_SOFT_EARTH, -- 973
		bucket = LP_BUCKET.WALK_DECK, -- 974
		sortBias = 0.15, -- 975
		edgeWidth = 0.4 -- 976
	}) -- 976
end -- 965
function VillageUndertableScene.prototype.buildHardBrickPatch(self, scene, brickX) -- 980
	local col = 0 -- 982
	do -- 982
		col = 0 -- 983
		while col < 3 do -- 983
			local bx0 = brickX - 24 + col * 16 -- 984
			local bx1 = bx0 + 14.5 -- 985
			scene:addBox({ -- 986
				x0 = bx0, -- 987
				x1 = bx1, -- 988
				y0 = -4, -- 989
				y1 = 3.2, -- 990
				z0 = -14, -- 991
				z1 = 6, -- 992
				material = MAT_HARD_BRICK, -- 993
				bucket = LP_BUCKET.WALK_DECK, -- 994
				sortBias = 0.2 + col * 0.01, -- 995
				highlightTopEdge = true, -- 996
				edgeWidth = 1 -- 997
			}) -- 997
			scene:addBox({ -- 999
				x0 = bx0 + 4, -- 1000
				x1 = bx1 + 4, -- 1001
				y0 = -4, -- 1002
				y1 = 2.8, -- 1003
				z0 = 8, -- 1004
				z1 = 26, -- 1005
				material = MAT_HARD_BRICK, -- 1006
				bucket = LP_BUCKET.WALK_DECK, -- 1007
				sortBias = 0.18 + col * 0.01, -- 1008
				highlightTopEdge = true, -- 1009
				edgeWidth = 0.9 -- 1010
			}) -- 1010
			col = col + 1 -- 983
		end -- 983
	end -- 983
end -- 980
function VillageUndertableScene.prototype.buildIronBasin(self, scene, basinX) -- 1015
	scene:addBox({ -- 1017
		x0 = basinX - 14, -- 1018
		x1 = basinX + 14, -- 1019
		y0 = -2, -- 1020
		y1 = 3, -- 1021
		z0 = -10, -- 1022
		z1 = 14, -- 1023
		material = MING_MATERIALS.mingBrickDark, -- 1024
		bucket = LP_BUCKET.PROP, -- 1025
		sortBias = 0.02 -- 1026
	}) -- 1026
	local tilt = self.basinShakeAngle -- 1029
	local liftL = math.sin(tilt) * 14 -- 1030
	local liftR = -liftL -- 1031
	local shiftX = math.sin(tilt * 1.4) * 2.5 -- 1032
	local baseY = 3 -- 1033
	local topY = 14.5 -- 1034
	local bx = basinX + shiftX -- 1035
	scene:addQuad3D( -- 1038
		vec3( -- 1039
			bx - 11, -- 1039
			baseY + math.max(0, liftL * 0.4), -- 1039
			-8 -- 1039
		), -- 1039
		vec3( -- 1040
			bx + 11, -- 1040
			baseY + math.max(0, liftR * 0.4), -- 1040
			-8 -- 1040
		), -- 1040
		vec3(bx + 16, topY + liftR, -12), -- 1041
		vec3(bx - 16, topY + liftL, -12), -- 1042
		MAT_IRON_BASIN, -- 1043
		{bucket = LP_BUCKET.PROP, sortBias = 0.25, edgeWidth = 1.2} -- 1044
	) -- 1044
	scene:addQuad3D( -- 1047
		vec3( -- 1048
			bx - 11, -- 1048
			baseY + math.max(0, liftL * 0.4), -- 1048
			10 -- 1048
		), -- 1048
		vec3( -- 1049
			bx - 11, -- 1049
			baseY + math.max(0, liftL * 0.4), -- 1049
			-8 -- 1049
		), -- 1049
		vec3(bx - 16, topY + liftL, -12), -- 1050
		vec3(bx - 16, topY + liftL, 14), -- 1051
		MAT_IRON_BASIN, -- 1052
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1053
	) -- 1053
	scene:addQuad3D( -- 1055
		vec3( -- 1056
			bx + 11, -- 1056
			baseY + math.max(0, liftR * 0.4), -- 1056
			-8 -- 1056
		), -- 1056
		vec3( -- 1057
			bx + 11, -- 1057
			baseY + math.max(0, liftR * 0.4), -- 1057
			10 -- 1057
		), -- 1057
		vec3(bx + 16, topY + liftR, 14), -- 1058
		vec3(bx + 16, topY + liftR, -12), -- 1059
		MAT_IRON_BASIN, -- 1060
		{bucket = LP_BUCKET.PROP, sortBias = 0.22, edgeWidth = 1} -- 1061
	) -- 1061
	scene:addQuad3D( -- 1064
		vec3(bx - 14, topY - 1 + liftL, -10), -- 1065
		vec3(bx + 14, topY - 1 + liftR, -10), -- 1066
		vec3(bx + 14, topY - 1 + liftR, 12), -- 1067
		vec3(bx - 14, topY - 1 + liftL, 12), -- 1068
		{ -- 1069
			base = rgba(24, 30, 40, 255), -- 1069
			edge = rgba(232, 238, 246, 235) -- 1069
		}, -- 1069
		{bucket = LP_BUCKET.PROP, sortBias = 0.28, edgeWidth = 1.5} -- 1070
	) -- 1070
end -- 1015
function VillageUndertableScene.prototype.drawSurfaceReadabilityDetails(self, fgDraw, fgGlow, p, cam, softX, culvertX, basinX, brickX) -- 1074
	local y0 = cam:sy(0) -- 1084
	local sx0 = cam:sx(softX - 20) -- 1087
	local sx1 = cam:sx(softX + 20) -- 1088
	local d = 0 -- 1089
	do -- 1089
		d = 0 -- 1090
		while d < 9 do -- 1090
			local dx = sx0 + (sx1 - sx0) * (d + 0.5) / 9 -- 1091
			local dy = y0 - 2.5 + (d % 3 - 1) * 1.8 -- 1092
			fgDraw:drawDot( -- 1093
				Vec2(dx, dy), -- 1093
				1.3, -- 1093
				Color(116, 98, 78, 175) -- 1093
			) -- 1093
			d = d + 1 -- 1090
		end -- 1090
	end -- 1090
	fgDraw:drawEllipse( -- 1095
		Vec2( -- 1095
			cam:sx(softX - 7), -- 1095
			y0 - 1.5 -- 1095
		), -- 1095
		cam:len(4.2), -- 1095
		1.6, -- 1095
		Color(38, 30, 24, 185) -- 1095
	) -- 1095
	fgDraw:drawEllipse( -- 1096
		Vec2( -- 1096
			cam:sx(softX + 8), -- 1096
			y0 - 2 -- 1096
		), -- 1096
		cam:len(4.2), -- 1096
		1.6, -- 1096
		Color(38, 30, 24, 185) -- 1096
	) -- 1096
	local cL = cam:sx(culvertX - 11) -- 1099
	local cR = cam:sx(culvertX + 11) -- 1100
	local cTop = cam:sy(25) -- 1101
	fgDraw:drawSegment( -- 1102
		Vec2(cL, cTop), -- 1102
		Vec2(cR, cTop), -- 1102
		1.6, -- 1102
		Color(196, 210, 224, 210) -- 1102
	) -- 1102
	local rippleShift = math.sin(self.animTime * 2.3) * 3 -- 1103
	fgGlow:drawSegment( -- 1104
		Vec2(cL + 3 + rippleShift, y0 + 2), -- 1104
		Vec2(cR - 4 + rippleShift, y0 + 2), -- 1104
		1.1, -- 1104
		Color(164, 192, 214, 105) -- 1104
	) -- 1104
	local bPtL = projectWorld3D( -- 1107
		basinX - 16, -- 1107
		14.5 + math.sin(self.basinShakeAngle) * 14, -- 1107
		-12, -- 1107
		cam, -- 1107
		self.proj -- 1107
	) -- 1107
	local bPtR = projectWorld3D( -- 1108
		basinX + 16, -- 1108
		14.5 - math.sin(self.basinShakeAngle) * 14, -- 1108
		-12, -- 1108
		cam, -- 1108
		self.proj -- 1108
	) -- 1108
	local shakeBoost = self.basinShakeTimer > 0 and clamp01(self.basinShakeTimer / self.basinShakeMax) or 0 -- 1109
	local rimAlpha = math.floor(205 + 48 * shakeBoost + 0.5) -- 1110
	fgDraw:drawSegment( -- 1111
		Vec2(bPtL.x, bPtL.y), -- 1111
		Vec2(bPtR.x, bPtR.y), -- 1111
		2.1 + shakeBoost * 1.1, -- 1111
		Color(230, 236, 242, rimAlpha) -- 1111
	) -- 1111
	fillRadialGlow( -- 1112
		fgGlow, -- 1113
		(bPtL.x + bPtR.x) * 0.5, -- 1114
		(bPtL.y + bPtR.y) * 0.5, -- 1115
		cam:len(22 + shakeBoost * 18), -- 1116
		cam:len(10 + shakeBoost * 8), -- 1117
		Color( -- 1118
			216, -- 1118
			226, -- 1118
			236, -- 1118
			math.floor(48 + 95 * shakeBoost + 0.5) -- 1118
		), -- 1118
		Color(186, 202, 220, 0), -- 1119
		14 -- 1120
	) -- 1120
	local brL = cam:sx(brickX - 24) -- 1124
	local brR = cam:sx(brickX + 24) -- 1125
	local brTop = cam:sy(3.2) -- 1126
	fgDraw:drawSegment( -- 1127
		Vec2(brL, brTop), -- 1127
		Vec2(brR, brTop), -- 1127
		1.8, -- 1127
		Color(224, 228, 234, 225) -- 1127
	) -- 1127
	local k = 1 -- 1128
	do -- 1128
		k = 1 -- 1129
		while k <= 2 do -- 1129
			local seamX = brL + (brR - brL) * k / 3 -- 1130
			fgDraw:drawSegment( -- 1131
				Vec2(seamX, y0 - 3), -- 1131
				Vec2(seamX, brTop + 1), -- 1131
				1.5, -- 1131
				Color(20, 24, 32, 240) -- 1131
			) -- 1131
			fgDraw:drawSegment( -- 1132
				Vec2(seamX + 1.8, y0 - 2), -- 1132
				Vec2(seamX + 1.8, brTop), -- 1132
				0.9, -- 1132
				Color(214, 218, 224, 175) -- 1132
			) -- 1132
			k = k + 1 -- 1129
		end -- 1129
	end -- 1129
	local i = 0 -- 1136
	do -- 1136
		i = 0 -- 1137
		while i < #self.rings do -- 1137
			do -- 1137
				local rg = self.rings[i + 1] -- 1138
				if rg.age < 0 then -- 1138
					goto __continue75 -- 1140
				end -- 1140
				local t = clamp01(rg.age / rg.duration) -- 1142
				local r = math.max( -- 1143
					4, -- 1143
					cam:len(rg.maxRadius) * (0.14 + 0.86 * t) -- 1143
				) -- 1143
				local alpha = (1 - t) * (rg.kind == "iron" and 0.88 or (rg.kind == "brick" and 0.82 or 0.4)) -- 1144
				local rx = cam:sx(rg.x) -- 1145
				local ry = cam:sy(rg.y) -- 1146
				local ringCol = rg.kind == "iron" and Color( -- 1147
					220, -- 1148
					234, -- 1148
					246, -- 1148
					math.floor(235 * alpha + 0.5) -- 1148
				) or (rg.kind == "brick" and Color( -- 1148
					236, -- 1150
					216, -- 1150
					178, -- 1150
					math.floor(225 * alpha + 0.5) -- 1150
				) or Color( -- 1150
					148, -- 1151
					134, -- 1151
					114, -- 1151
					math.floor(165 * alpha + 0.5) -- 1151
				)) -- 1151
				drawEllipseRing( -- 1152
					fgGlow, -- 1152
					rx, -- 1152
					ry, -- 1152
					r, -- 1152
					r * 0.34, -- 1152
					rg.kind == "iron" and 1.8 or 1.4, -- 1152
					ringCol, -- 1152
					22 -- 1152
				) -- 1152
				if rg.kind == "iron" then -- 1152
					drawEllipseRing( -- 1154
						fgDraw, -- 1154
						rx, -- 1154
						ry, -- 1154
						r * 0.96, -- 1154
						r * 0.32, -- 1154
						1.1, -- 1154
						Color( -- 1154
							214, -- 1154
							224, -- 1154
							236, -- 1154
							math.floor(150 * alpha + 0.5) -- 1154
						), -- 1154
						22 -- 1154
					) -- 1154
				end -- 1154
			end -- 1154
			::__continue75:: -- 1154
			i = i + 1 -- 1137
		end -- 1137
	end -- 1137
	do -- 1137
		i = 0 -- 1157
		while i < #self.shards do -- 1157
			local sp = self.shards[i + 1] -- 1158
			local a = clamp01(sp.life / sp.maxLife) -- 1159
			local col = sp.kind == "soft" and Color( -- 1160
				138, -- 1161
				120, -- 1161
				98, -- 1161
				math.floor(170 * a + 0.5) -- 1161
			) or (sp.kind == "iron" and Color( -- 1161
				224, -- 1163
				232, -- 1163
				242, -- 1163
				math.floor(225 * a + 0.5) -- 1163
			) or Color( -- 1163
				216, -- 1164
				198, -- 1164
				174, -- 1164
				math.floor(220 * a + 0.5) -- 1164
			)) -- 1164
			fgDraw:drawDot( -- 1165
				Vec2( -- 1165
					cam:sx(sp.x), -- 1165
					cam:sy(sp.y) -- 1165
				), -- 1165
				sp.size, -- 1165
				col -- 1165
			) -- 1165
			i = i + 1 -- 1157
		end -- 1157
	end -- 1157
	if p.bottleLandT > 0 and p.bottleLandX >= 0 and #self.rings == 0 then -- 1157
		local rx = cam:sx(p.bottleLandX) -- 1170
		local ry = cam:sy(math.max(1, p.bottleLandY)) -- 1171
		fgDraw:drawDot( -- 1172
			Vec2(rx, ry), -- 1172
			2.5, -- 1172
			Color(216, 206, 186, 150) -- 1172
		) -- 1172
	end -- 1172
end -- 1074
function VillageUndertableScene.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1177
	local p = ctx.p -- 1183
	local cam = ctx.cam -- 1184
	local bottle = p.room.bottle -- 1187
	if bottle ~= nil and not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 1187
		self:drawCeramicBottle( -- 1189
			fgDraw, -- 1189
			fgGlow, -- 1189
			worldArt, -- 1189
			"fe04_bottle_shelf", -- 1189
			cam:sx(bottle.x), -- 1189
			cam:sy(56), -- 1189
			cam.ppu, -- 1189
			0, -- 1189
			true -- 1189
		) -- 1189
	end -- 1189
	if p.hasBottle and p.aimHold <= 0 then -- 1189
		local pl = p.player -- 1194
		self:drawCeramicBottle( -- 1195
			fgDraw, -- 1196
			fgGlow, -- 1197
			worldArt, -- 1198
			"fe04_bottle_held", -- 1199
			cam:sx(pl.x + pl.facing * 10), -- 1200
			cam:sy(pl.y + pl.h * 0.52), -- 1201
			cam.ppu, -- 1202
			pl.facing * 0.22, -- 1203
			false -- 1204
		) -- 1204
	end -- 1204
	if p.bottleFly ~= nil then -- 1204
		self:drawCeramicBottle( -- 1208
			fgDraw, -- 1209
			fgGlow, -- 1210
			worldArt, -- 1211
			"fe04_bottle_air", -- 1212
			cam:sx(p.bottleFly.x), -- 1213
			cam:sy(p.bottleFly.y), -- 1214
			cam.ppu, -- 1215
			self.animTime * 13.5, -- 1216
			false -- 1217
		) -- 1217
	end -- 1217
	if p.hasBottle and p.aimHold > 0 then -- 1217
		local pl = p.player -- 1223
		local endX = p.bottleAimX -- 1224
		local endY = p.bottleAimY -- 1225
		if endX < 0 then -- 1225
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 1227
			endX = wAim.x -- 1228
			endY = 0 -- 1229
		end -- 1229
		local dir = endX >= pl.x and 1 or -1 -- 1231
		local x0 = pl.x + dir * 10 -- 1232
		local y0 = pl.y + pl.h * 0.7 -- 1233
		local vx = (endX - x0) / BOTTLE_FLY_T -- 1234
		local vy = (endY - y0 + 0.5 * GRAVITY * BOTTLE_FLY_T * BOTTLE_FLY_T) / BOTTLE_FLY_T -- 1235
		local previewSurface = self:classifyLandingSurface(p, endX) -- 1237
		local arcRgb = previewSurface == "iron" and rgba(214, 228, 242, 255) or (previewSurface == "brick" and rgba(232, 206, 152, 255) or rgba(154, 142, 126, 255)) -- 1238
		local steps = 18 -- 1244
		local k = 1 -- 1245
		do -- 1245
			k = 1 -- 1246
			while k <= steps do -- 1246
				local tt = k / steps * BOTTLE_FLY_T -- 1247
				local wx = x0 + vx * tt -- 1248
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 1249
				local alpha = 195 * (0.4 + 0.6 * (k / steps)) -- 1250
				fgDraw:drawDot( -- 1251
					Vec2( -- 1251
						cam:sx(wx), -- 1251
						cam:sy(wy) -- 1251
					), -- 1251
					2.5, -- 1251
					toColor(arcRgb, alpha) -- 1251
				) -- 1251
				fgGlow:drawDot( -- 1252
					Vec2( -- 1252
						cam:sx(wx), -- 1252
						cam:sy(wy) -- 1252
					), -- 1252
					3.2, -- 1252
					toColor(arcRgb, alpha * 0.55) -- 1252
				) -- 1252
				k = k + 1 -- 1246
			end -- 1246
		end -- 1246
		local lx = cam:sx(endX) -- 1255
		local ly = cam:sy(endY + 2) -- 1256
		local pulse = 0.88 + 0.12 * math.sin(self.animTime * 5.2) -- 1257
		drawEllipseRing( -- 1258
			fgDraw, -- 1258
			lx, -- 1258
			ly, -- 1258
			11 * pulse, -- 1258
			4.2 * pulse, -- 1258
			1.6, -- 1258
			toColor(arcRgb, 235), -- 1258
			20 -- 1258
		) -- 1258
		if previewSurface == "iron" then -- 1258
			drawEllipseRing( -- 1260
				fgGlow, -- 1260
				lx, -- 1260
				ly, -- 1260
				24 * pulse, -- 1260
				9.2 * pulse, -- 1260
				1.3, -- 1260
				toColor(arcRgb, 195), -- 1260
				22 -- 1260
			) -- 1260
		elseif previewSurface == "brick" then -- 1260
			drawEllipseRing( -- 1262
				fgGlow, -- 1262
				lx, -- 1262
				ly, -- 1262
				18 * pulse, -- 1262
				7 * pulse, -- 1262
				1.2, -- 1262
				toColor(arcRgb, 165), -- 1262
				20 -- 1262
			) -- 1262
		end -- 1262
	end -- 1262
	return true -- 1266
end -- 1177
function VillageUndertableScene.prototype.drawCeramicBottle(self, fgDraw, fgGlow, worldArt, id, cx, cy, ppu, tilt, shelfGlint) -- 1269
	local size = math.max(10, ppu * 10.5) -- 1280
	if not worldArt:tryPlace( -- 1280
		"prop_bottle", -- 1281
		id, -- 1281
		cx, -- 1281
		cy, -- 1281
		size, -- 1281
		size, -- 1281
		{angle = tilt * 180 / math.pi, layer = 8} -- 1281
	) then -- 1281
		fgDraw:drawCircle( -- 1285
			Vec2(cx, cy), -- 1285
			size * 0.36, -- 1285
			Color(172, 138, 102, 245) -- 1285
		) -- 1285
	end -- 1285
	if shelfGlint then -- 1285
		local p = 0.72 + 0.28 * math.sin(self.animTime * 3) -- 1288
		fillRadialGlow( -- 1289
			fgGlow, -- 1289
			cx, -- 1289
			cy + 2, -- 1289
			14 * p, -- 1289
			14 * p, -- 1289
			Color( -- 1289
				224, -- 1289
				214, -- 1289
				190, -- 1289
				math.floor(62 * p + 0.5) -- 1289
			), -- 1289
			Color(224, 214, 190, 0), -- 1289
			12 -- 1289
		) -- 1289
	end -- 1289
end -- 1269
function VillageUndertableScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 1294
	local p = ctx.p -- 1300
	local cam = ctx.cam -- 1301
	if p.room.scavenger ~= nil then -- 1301
		self:drawScavengerShoeOverlay(fgDraw, fgGlow, p, cam) -- 1303
	end -- 1303
	if ctx.paused then -- 1303
		local arch = p.room.arch -- 1308
		local pTopBL = projectWorld3D( -- 1309
			arch.x0 - 8, -- 1309
			arch.h, -- 1309
			-15, -- 1309
			cam, -- 1309
			self.proj -- 1309
		) -- 1309
		local pTopTR = projectWorld3D( -- 1310
			arch.x1 + 8, -- 1310
			arch.h + 8, -- 1310
			-15, -- 1310
			cam, -- 1310
			self.proj -- 1310
		) -- 1310
		worldArt:tryPlace( -- 1311
			"cover_wood", -- 1312
			"fe04_pause_table_top", -- 1313
			(pTopBL.x + pTopTR.x) * 0.5, -- 1314
			pTopBL.y, -- 1315
			math.max( -- 1316
				20, -- 1316
				math.abs(pTopTR.x - pTopBL.x) -- 1316
			), -- 1316
			math.max( -- 1317
				8, -- 1317
				math.abs(pTopTR.y - pTopBL.y) -- 1317
			), -- 1317
			{ -- 1318
				color = Color(46, 35, 27, 255), -- 1318
				opacity = 0.96, -- 1318
				layer = 5300 -- 1318
			} -- 1318
		) -- 1318
		local legBL = projectWorld3D( -- 1320
			arch.x1 - 6, -- 1320
			0, -- 1320
			-15, -- 1320
			cam, -- 1320
			self.proj -- 1320
		) -- 1320
		local legTR = projectWorld3D( -- 1321
			arch.x1 + 1, -- 1321
			arch.h, -- 1321
			-15, -- 1321
			cam, -- 1321
			self.proj -- 1321
		) -- 1321
		worldArt:tryPlace( -- 1322
			"cover_wood", -- 1323
			"fe04_pause_table_leg", -- 1324
			(legBL.x + legTR.x) * 0.5, -- 1325
			legBL.y, -- 1326
			math.max( -- 1327
				6, -- 1327
				math.abs(legTR.x - legBL.x) -- 1327
			), -- 1327
			math.max( -- 1328
				16, -- 1328
				math.abs(legTR.y - legBL.y) -- 1328
			), -- 1328
			{ -- 1329
				color = Color(34, 25, 19, 255), -- 1329
				opacity = 0.96, -- 1329
				layer = 5310 -- 1329
			} -- 1329
		) -- 1329
	end -- 1329
end -- 1294
function VillageUndertableScene.prototype.drawScavengerShoeOverlay(self, fgDraw, fgGlow, p, cam) -- 1334
	local cx = cam:sx(p.scavX) -- 1340
	local by = cam:sy(p.room.scavenger ~= nil and p.room.scavenger.y or 0) -- 1341
	local f = self.shoeFacing >= 0 and 1 or -1 -- 1342
	local moving = p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" -- 1343
	local stride = moving and math.sin(self.scavStridePhase) * cam:len(7.2) or 0 -- 1344
	local pausedToe = self.shoeToePauseTimer > 0 -- 1345
	fillRadialGlow( -- 1348
		fgGlow, -- 1348
		cx + f * cam:len(4), -- 1348
		by + 2, -- 1348
		cam:len(32), -- 1348
		cam:len(8), -- 1348
		Color(196, 208, 220, 48), -- 1348
		Color(156, 172, 190, 0), -- 1348
		14 -- 1348
	) -- 1348
	fgDraw:drawEllipse( -- 1349
		Vec2( -- 1349
			cx + f * cam:len(2), -- 1349
			by + 1 -- 1349
		), -- 1349
		cam:len(19), -- 1349
		cam:len(3.4), -- 1349
		Color(92, 102, 114, 72) -- 1349
	) -- 1349
	local function drawSingleShoe(footX, liftY, isFront) -- 1352
		local heelX = footX - f * cam:len(4.8) -- 1353
		local midX = footX + f * cam:len(1.8) -- 1354
		local toeX = footX + f * cam:len(7.6) -- 1355
		local soleY = by + 0.8 + liftY -- 1356
		local shoeH = cam:len(4.4) -- 1357
		fgDraw:drawPolygon( -- 1359
			{ -- 1359
				Vec2(heelX, soleY), -- 1360
				Vec2(toeX, soleY), -- 1361
				Vec2( -- 1362
					toeX - f * cam:len(1), -- 1362
					soleY + shoeH * 0.56 -- 1362
				), -- 1362
				Vec2(midX, soleY + shoeH * 0.96), -- 1363
				Vec2( -- 1364
					heelX + f * cam:len(0.6), -- 1364
					soleY + shoeH * 0.86 -- 1364
				) -- 1364
			}, -- 1364
			isFront and Color(68, 58, 48, 250) or Color(46, 40, 34, 240) -- 1365
		) -- 1365
		local soleCol = isFront and Color(198, 192, 178, 232) or Color(148, 144, 134, 195) -- 1367
		fgDraw:drawSegment( -- 1368
			Vec2(heelX, soleY + 0.6), -- 1368
			Vec2(toeX, soleY + 0.6), -- 1368
			1.5, -- 1368
			soleCol -- 1368
		) -- 1368
		fgDraw:drawSegment( -- 1370
			Vec2( -- 1370
				toeX - f * cam:len(1.2), -- 1370
				soleY + 0.8 -- 1370
			), -- 1370
			Vec2( -- 1370
				toeX - f * cam:len(1.4), -- 1370
				soleY + shoeH * 0.56 -- 1370
			), -- 1370
			1.3, -- 1370
			Color(214, 210, 198, isFront and 220 or 165) -- 1370
		) -- 1370
		if isFront and pausedToe then -- 1370
			fgGlow:drawDot( -- 1373
				Vec2(toeX, soleY + 1.5), -- 1373
				3, -- 1373
				Color(236, 218, 178, 155) -- 1373
			) -- 1373
		end -- 1373
	end -- 1352
	local backLift = moving and math.max( -- 1377
		0, -- 1377
		-math.sin(self.scavStridePhase) -- 1377
	) * cam:len(2.4) or 0 -- 1377
	local frontLift = moving and math.max( -- 1378
		0, -- 1378
		math.sin(self.scavStridePhase) -- 1378
	) * cam:len(2.8) or 0 -- 1378
	drawSingleShoe( -- 1379
		cx - stride - f * cam:len(3.5), -- 1379
		backLift, -- 1379
		false -- 1379
	) -- 1379
	drawSingleShoe( -- 1380
		cx + stride + f * cam:len(4), -- 1380
		frontLift, -- 1380
		true -- 1380
	) -- 1380
end -- 1334
function VillageUndertableScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, _uiArt, _uiGlow, ctx) -- 1390
	local p = ctx.p -- 1397
	local cam = ctx.cam -- 1398
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 1399
	local arch = p.room.arch -- 1400
	local xLeft = arch.x0 - 8 -- 1402
	local xRight = arch.x1 + 8 -- 1403
	local tableBotY = arch.h -- 1404
	local tableTopY = arch.h + 8 -- 1405
	local zFront = -15 -- 1406
	local zMid = 4 -- 1407
	local function drawFrontLeg(lx0, lx1) -- 1410
		local mBL = projectWorld3D( -- 1411
			lx0, -- 1411
			0, -- 1411
			zFront, -- 1411
			cam, -- 1411
			self.proj -- 1411
		) -- 1411
		local mBR = projectWorld3D( -- 1412
			lx1, -- 1412
			0, -- 1412
			zFront, -- 1412
			cam, -- 1412
			self.proj -- 1412
		) -- 1412
		local mTR = projectWorld3D( -- 1413
			lx1, -- 1413
			tableBotY, -- 1413
			zFront, -- 1413
			cam, -- 1413
			self.proj -- 1413
		) -- 1413
		local mTL = projectWorld3D( -- 1414
			lx0, -- 1414
			tableBotY, -- 1414
			zFront, -- 1414
			cam, -- 1414
			self.proj -- 1414
		) -- 1414
		drawUiQuad( -- 1415
			uiDraw, -- 1415
			mBL, -- 1415
			mBR, -- 1415
			mTR, -- 1415
			mTL, -- 1415
			Color(26, 20, 15, 250), -- 1415
			Color(38, 29, 22, 252), -- 1415
			inv, -- 1415
			Color(88, 70, 54, 145), -- 1415
			0.9 -- 1415
		) -- 1415
		local sBR = projectWorld3D( -- 1417
			lx1, -- 1417
			0, -- 1417
			zFront + 7, -- 1417
			cam, -- 1417
			self.proj -- 1417
		) -- 1417
		local sTR = projectWorld3D( -- 1418
			lx1, -- 1418
			tableBotY, -- 1418
			zFront + 7, -- 1418
			cam, -- 1418
			self.proj -- 1418
		) -- 1418
		drawUiQuad( -- 1419
			uiDraw, -- 1419
			mBR, -- 1419
			sBR, -- 1419
			sTR, -- 1419
			mTR, -- 1419
			Color(44, 34, 26, 248), -- 1419
			Color(66, 52, 40, 250), -- 1419
			inv, -- 1419
			Color(138, 120, 102, 155), -- 1419
			0.8 -- 1419
		) -- 1419
	end -- 1410
	drawFrontLeg(arch.x0 - 1, arch.x0 + 6) -- 1421
	drawFrontLeg(arch.x1 - 6, arch.x1 + 1) -- 1422
	local bFarL = projectWorld3D( -- 1425
		xLeft, -- 1425
		tableBotY, -- 1425
		zMid, -- 1425
		cam, -- 1425
		self.proj -- 1425
	) -- 1425
	local bFarR = projectWorld3D( -- 1426
		xRight, -- 1426
		tableBotY, -- 1426
		zMid, -- 1426
		cam, -- 1426
		self.proj -- 1426
	) -- 1426
	local bNearR = projectWorld3D( -- 1427
		xRight, -- 1427
		tableBotY, -- 1427
		zFront, -- 1427
		cam, -- 1427
		self.proj -- 1427
	) -- 1427
	local bNearL = projectWorld3D( -- 1428
		xLeft, -- 1428
		tableBotY, -- 1428
		zFront, -- 1428
		cam, -- 1428
		self.proj -- 1428
	) -- 1428
	drawUiQuad( -- 1429
		uiDraw, -- 1429
		bFarL, -- 1429
		bFarR, -- 1429
		bNearR, -- 1429
		bNearL, -- 1429
		Color(18, 14, 11, 236), -- 1429
		Color(28, 21, 16, 242), -- 1429
		inv, -- 1429
		Color(76, 58, 44, 115), -- 1429
		0.8 -- 1429
	) -- 1429
	local fTopR = projectWorld3D( -- 1432
		xRight, -- 1432
		tableTopY, -- 1432
		zFront, -- 1432
		cam, -- 1432
		self.proj -- 1432
	) -- 1432
	local fTopL = projectWorld3D( -- 1433
		xLeft, -- 1433
		tableTopY, -- 1433
		zFront, -- 1433
		cam, -- 1433
		self.proj -- 1433
	) -- 1433
	drawUiQuad( -- 1434
		uiDraw, -- 1434
		bNearL, -- 1434
		bNearR, -- 1434
		fTopR, -- 1434
		fTopL, -- 1434
		Color(38, 28, 21, 252), -- 1434
		Color(56, 42, 32, 254), -- 1434
		inv, -- 1434
		Color(124, 98, 76, 155), -- 1434
		1 -- 1434
	) -- 1434
	uiDraw:drawSegment( -- 1436
		Vec2(bNearL.x * inv, bNearL.y * inv), -- 1436
		Vec2(bNearR.x * inv, bNearR.y * inv), -- 1436
		1.2, -- 1436
		Color(142, 122, 100, 175) -- 1436
	) -- 1436
	local topBackL = projectWorld3D( -- 1439
		xLeft, -- 1439
		tableTopY, -- 1439
		zMid, -- 1439
		cam, -- 1439
		self.proj -- 1439
	) -- 1439
	local topBackR = projectWorld3D( -- 1440
		xRight, -- 1440
		tableTopY, -- 1440
		zMid, -- 1440
		cam, -- 1440
		self.proj -- 1440
	) -- 1440
	drawUiQuad( -- 1441
		uiDraw, -- 1441
		fTopL, -- 1441
		fTopR, -- 1441
		topBackR, -- 1441
		topBackL, -- 1441
		Color(52, 40, 30, 244), -- 1441
		Color(32, 24, 19, 236), -- 1441
		inv, -- 1441
		Color(132, 110, 88, 130), -- 1441
		0.8 -- 1441
	) -- 1441
	local bowlBL = projectWorld3D( -- 1444
		arch.x0 + 24, -- 1444
		tableTopY + 0.5, -- 1444
		-5, -- 1444
		cam, -- 1444
		self.proj -- 1444
	) -- 1444
	local bowlBR = projectWorld3D( -- 1445
		arch.x0 + 38, -- 1445
		tableTopY + 0.5, -- 1445
		-5, -- 1445
		cam, -- 1445
		self.proj -- 1445
	) -- 1445
	local bowlTR = projectWorld3D( -- 1446
		arch.x0 + 40, -- 1446
		tableTopY + 6.5, -- 1446
		-5, -- 1446
		cam, -- 1446
		self.proj -- 1446
	) -- 1446
	local bowlTL = projectWorld3D( -- 1447
		arch.x0 + 22, -- 1447
		tableTopY + 6.5, -- 1447
		-5, -- 1447
		cam, -- 1447
		self.proj -- 1447
	) -- 1447
	drawUiQuad( -- 1448
		uiDraw, -- 1448
		bowlBL, -- 1448
		bowlBR, -- 1448
		bowlTR, -- 1448
		bowlTL, -- 1448
		Color(72, 68, 62, 244), -- 1448
		Color(118, 114, 106, 246), -- 1448
		inv, -- 1448
		Color(172, 166, 156, 175), -- 1448
		0.8 -- 1448
	) -- 1448
	local clothL = projectWorld3D( -- 1451
		xLeft + 2, -- 1451
		tableBotY - 7, -- 1451
		zFront, -- 1451
		cam, -- 1451
		self.proj -- 1451
	) -- 1451
	local clothR = projectWorld3D( -- 1452
		xLeft + 26, -- 1452
		tableBotY - 1, -- 1452
		zFront, -- 1452
		cam, -- 1452
		self.proj -- 1452
	) -- 1452
	uiDraw:drawVertices({ -- 1453
		{ -- 1454
			Vec2(bNearL.x * inv, bNearL.y * inv), -- 1454
			Color(28, 22, 19, 224) -- 1454
		}, -- 1454
		{ -- 1455
			Vec2(clothL.x * inv, clothL.y * inv), -- 1455
			Color(36, 29, 25, 212) -- 1455
		}, -- 1455
		{ -- 1456
			Vec2(clothR.x * inv, clothR.y * inv), -- 1456
			Color(26, 21, 18, 198) -- 1456
		} -- 1456
	}) -- 1456
	if p.player.crouch and p.player.x >= arch.x0 - 16 and p.player.x <= arch.x1 + 16 then -- 1456
		local topBandH = ctx.uiH * 0.14 -- 1461
		fillVGradRect( -- 1462
			uiDraw, -- 1463
			0, -- 1464
			ctx.uiH - topBandH, -- 1465
			ctx.uiW, -- 1466
			topBandH, -- 1467
			Color(12, 10, 9, 0), -- 1468
			Color(12, 10, 9, 138) -- 1469
		) -- 1469
	end -- 1469
	return false -- 1474
end -- 1390
return ____exports -- 1390