-- [ts]: village_undertable.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 19
local Color = ____Dora.Color -- 19
local Vec2 = ____Dora.Vec2 -- 19
local ____lowpoly = require("Script.watch.fe.renderer.lowpoly") -- 24
local clamp01 = ____lowpoly.clamp01 -- 26
local projectWorld3D = ____lowpoly.projectWorld3D -- 27
local ____slideshow = require("Script.watch.fe.renderer.slideshow") -- 30
local drawChildColdMoonGrade = ____slideshow.drawChildColdMoonGrade -- 30
local ____theme = require("Script.watch.fe.theme") -- 31
local fillRadialGlow = ____theme.fillRadialGlow -- 33
local fillVGradRect = ____theme.fillVGradRect -- 34
local rgba = ____theme.rgba -- 35
local toColor = ____theme.toColor -- 36
local GRAVITY = 1000 -- 39
local BOTTLE_FLY_T = 0.62 -- 40
local CHILD_AUDIO_ROOT = "assets/audio/child/" -- 41
--- 空村铁盆世界坐标（位于拾荒者巡逻右侧、与硬砖 brickX=608 ± 34 清晰分离、完全在听觉半径 480 内）
____exports.VILLAGE_BASIN_OFFSET_X = 548 -- 44
____exports.VILLAGE_BASIN_HIT_RADIUS = 24 -- 45
____exports.VILLAGE_SURFACE_HIT_RADIUS = 34 -- 46
local function drawEllipseRing(draw, cx, cy, rx, ry, lineW, col, segs) -- 89
	if segs == nil then -- 89
		segs = 22 -- 97
	end -- 97
	local pts = {} -- 99
	local i = 0 -- 100
	do -- 100
		i = 0 -- 101
		while i < segs do -- 101
			local a = i / segs * math.pi * 2 -- 102
			pts[#pts + 1] = Vec2( -- 103
				cx + math.cos(a) * rx, -- 103
				cy + math.sin(a) * ry -- 103
			) -- 103
			i = i + 1 -- 101
		end -- 101
	end -- 101
	draw:drawPolygon( -- 105
		pts, -- 105
		Color(0, 0, 0, 0), -- 105
		lineW, -- 105
		col -- 105
	) -- 105
end -- 89
____exports.VillageUndertableScene = __TS__Class() -- 108
local VillageUndertableScene = ____exports.VillageUndertableScene -- 108
VillageUndertableScene.name = "VillageUndertableScene" -- 108
function VillageUndertableScene.prototype.____constructor(self) -- 108
	self.animTime = 0 -- 109
	self.active = false -- 110
	self.underTableFocus = 0 -- 111
	self.lastSurface = "" -- 112
	self.lastLandX = -1 -- 113
	self.brickHits = 0 -- 114
	self.ironHits = 0 -- 115
	self.softHits = 0 -- 116
	self.basinShakeTimer = 0 -- 119
	self.basinShakeMax = 1.15 -- 120
	self.basinShakeAngle = 0 -- 121
	self.shoeToePauseTimer = 0 -- 124
	self.shoeTurnBlend = 1 -- 125
	self.shoeFacing = -1 -- 126
	self.prevScavState = "patrol" -- 127
	self.prevScavX = 0 -- 128
	self.scavStridePhase = 0 -- 129
	self.shards = {} -- 131
	self.rings = {} -- 132
	self.rng = 7321 -- 133
	self.proj = { -- 135
		morph = 1, -- 136
		focal = 390, -- 137
		vpFracX = 0.54, -- 138
		vpFracY = 0.44, -- 139
		vpOffsetX = 0, -- 140
		vpOffsetY = 0, -- 141
		baseDepth = 0 -- 142
	} -- 142
end -- 108
function VillageUndertableScene.prototype.reset(self) -- 145
	self.animTime = 0 -- 146
	self.active = false -- 147
	self.underTableFocus = 0 -- 148
	self.lastSurface = "" -- 149
	self.lastLandX = -1 -- 150
	self.brickHits = 0 -- 151
	self.ironHits = 0 -- 152
	self.softHits = 0 -- 153
	self.basinShakeTimer = 0 -- 154
	self.basinShakeAngle = 0 -- 155
	self.shoeToePauseTimer = 0 -- 156
	self.shoeTurnBlend = 1 -- 157
	self.shoeFacing = -1 -- 158
	self.prevScavState = "patrol" -- 159
	self.prevScavX = 0 -- 160
	self.scavStridePhase = 0 -- 161
	self.shards = {} -- 162
	self.rings = {} -- 163
end -- 145
function VillageUndertableScene.prototype.rand(self) -- 166
	self.rng = (self.rng * 1664525 + 1013904223) % 4294967296 -- 167
	return self.rng / 4294967296 -- 168
end -- 166
function VillageUndertableScene.prototype.getProjection(self) -- 171
	return self.proj -- 172
end -- 171
function VillageUndertableScene.prototype.getBasinWorldX(self, p) -- 175
	return p.ox + ____exports.VILLAGE_BASIN_OFFSET_X -- 176
end -- 175
function VillageUndertableScene.prototype.getBrickWorldX(self, p) -- 179
	return p.room.brickX or p.ox + 608 -- 180
end -- 179
function VillageUndertableScene.prototype.getSoftWorldX(self, p) -- 183
	return p.room.softX or p.ox + 272 -- 184
end -- 183
function VillageUndertableScene.prototype.getCulvertWorldX(self, p) -- 187
	return p.ox + 600 -- 189
end -- 187
function VillageUndertableScene.prototype.classifyLandingSurface(self, p, x, explicitSurface) -- 193
	if explicitSurface == "iron" or explicitSurface == "basin" then -- 193
		return "iron" -- 195
	end -- 195
	if explicitSurface == "soft" or explicitSurface == "dirt" then -- 195
		return "soft" -- 198
	end -- 198
	if explicitSurface == "brick" then -- 198
		return "brick" -- 201
	end -- 201
	local basinX = self:getBasinWorldX(p) -- 203
	if math.abs(x - basinX) <= ____exports.VILLAGE_BASIN_HIT_RADIUS then -- 203
		return "iron" -- 205
	end -- 205
	local softX = self:getSoftWorldX(p) -- 207
	if math.abs(x - softX) <= ____exports.VILLAGE_SURFACE_HIT_RADIUS then -- 207
		return "soft" -- 209
	end -- 209
	return "brick" -- 211
end -- 193
function VillageUndertableScene.prototype.getDebugState(self, p) -- 214
	return { -- 215
		active = self.active, -- 216
		basinWorldX = p ~= nil and self:getBasinWorldX(p) or ____exports.VILLAGE_BASIN_OFFSET_X, -- 217
		brickWorldX = p ~= nil and self:getBrickWorldX(p) or 608, -- 218
		softWorldX = p ~= nil and self:getSoftWorldX(p) or 272, -- 219
		culvertWorldX = p ~= nil and self:getCulvertWorldX(p) or 440, -- 220
		lastSurface = self.lastSurface, -- 221
		brickHits = self.brickHits, -- 222
		ironHits = self.ironHits, -- 223
		softHits = self.softHits, -- 224
		basinShakeTimer = self.basinShakeTimer, -- 225
		basinShakeAngle = self.basinShakeAngle, -- 226
		shoeToePauseTimer = self.shoeToePauseTimer, -- 227
		shoeFacing = self.shoeFacing, -- 228
		scavTargetX = p ~= nil and p.scavTargetX or 0, -- 229
		underTableFocus = self.underTableFocus, -- 230
		lastLandX = self.lastLandX -- 231
	} -- 231
end -- 214
function VillageUndertableScene.prototype.update(self, ctx) -- 235
	local p = ctx.p -- 236
	self.active = true -- 237
	local arch = p.room.arch -- 240
	local nearTable = p.player.x >= arch.x0 - 80 and p.player.x <= arch.x1 + 30 -- 241
	local targetFocus = (p.player.crouch or nearTable) and 1 or 0.72 -- 242
	if not ctx.paused and ctx.worldDt > 0 then -- 242
		local dt = ctx.worldDt -- 244
		self.animTime = self.animTime + dt -- 245
		self.underTableFocus = self.underTableFocus + (targetFocus - self.underTableFocus) * math.min(1, dt * 4.5) -- 246
		if self.basinShakeTimer > 0 then -- 246
			self.basinShakeTimer = math.max(0, self.basinShakeTimer - dt) -- 250
			local elapsed = self.basinShakeMax - self.basinShakeTimer -- 251
			self.basinShakeAngle = math.sin(elapsed * 38) * math.exp(-elapsed * 3.1) * 0.24 -- 252
		else -- 252
			self.basinShakeAngle = 0 -- 254
		end -- 254
		if self.shoeToePauseTimer > 0 then -- 254
			self.shoeToePauseTimer = math.max(0, self.shoeToePauseTimer - dt) -- 259
		end -- 259
		local scavDx = p.scavX - self.prevScavX -- 261
		if math.abs(scavDx) > 0.02 then -- 261
			self.scavStridePhase = self.scavStridePhase + math.abs(scavDx) * 0.16 -- 263
		elseif p.scavState == "patrol" or p.scavState == "walk" or p.scavState == "back" or p.scavState == "chase" then -- 263
			self.scavStridePhase = self.scavStridePhase + dt * (p.scavState == "chase" and 11.5 or 6.2) -- 265
		end -- 265
		self.prevScavX = p.scavX -- 267
		local desiredFacing = self:computeDesiredShoeFacing(p) -- 270
		if self.shoeToePauseTimer <= 0 then -- 270
			self.shoeFacing = desiredFacing -- 272
			self.shoeTurnBlend = math.min(1, self.shoeTurnBlend + dt * 6) -- 273
		end -- 273
		local i = 0 -- 277
		do -- 277
			i = 0 -- 278
			while i < #ctx.events.rawEvents do -- 278
				local ev = ctx.events.rawEvents[i + 1] -- 279
				if ev.name == "bottleLanded" then -- 279
					self:onBottleLanded(ctx, ev) -- 281
				end -- 281
				i = i + 1 -- 278
			end -- 278
		end -- 278
		if p.scavState == "turn" and self.prevScavState ~= "turn" then -- 278
			if self.lastSurface == "brick" and self.shoeToePauseTimer <= 0 then -- 278
				self.shoeToePauseTimer = 0.14 -- 288
			end -- 288
		end -- 288
		self.prevScavState = p.scavState -- 291
		local w = 0 -- 294
		do -- 294
			i = 0 -- 295
			while i < #self.shards do -- 295
				local sp = self.shards[i + 1] -- 296
				sp.life = sp.life - dt -- 297
				if sp.life > 0 then -- 297
					sp.vy = sp.vy - (sp.kind == "soft" and 180 or 420) * dt -- 299
					sp.x = sp.x + sp.vx * dt -- 300
					sp.y = sp.y + sp.vy * dt -- 301
					if sp.y < 0 then -- 301
						sp.y = 0 -- 303
						sp.vy = -sp.vy * 0.28 -- 304
						sp.vx = sp.vx * 0.62 -- 305
					end -- 305
					self.shards[w + 1] = sp -- 307
					w = w + 1 -- 308
				end -- 308
				i = i + 1 -- 295
			end -- 295
		end -- 295
		__TS__ArraySetLength(self.shards, w) -- 295
		w = 0 -- 314
		do -- 314
			i = 0 -- 315
			while i < #self.rings do -- 315
				local rg = self.rings[i + 1] -- 316
				rg.age = rg.age + dt -- 317
				if rg.age < rg.duration then -- 317
					self.rings[w + 1] = rg -- 319
					w = w + 1 -- 320
				end -- 320
				i = i + 1 -- 315
			end -- 315
		end -- 315
		__TS__ArraySetLength(self.rings, w) -- 315
		ctx.audio:playLoop( -- 326
			"fe04_village_night", -- 326
			"ambience", -- 326
			CHILD_AUDIO_ROOT .. "village_night_loop.wav", -- 326
			0.24, -- 326
			p.ticks -- 326
		) -- 326
	elseif self.underTableFocus == 0 then -- 326
		self.underTableFocus = targetFocus -- 328
	end -- 328
	local focusAnchorX = math.max( -- 332
		p.ox + 305, -- 332
		math.min(p.ox + 455, p.ox + 355 + (p.player.x - (p.ox + 320)) * 0.28) -- 332
	) -- 332
	local zoom = 1.04 + (1 - self.underTableFocus) * 0.04 -- 333
	ctx.cam:setAnchorLock({ -- 334
		footWorldX = focusAnchorX, -- 335
		footWorldY = 0, -- 336
		footDepth = 0, -- 337
		thresholdWorldX = p.ox + 440, -- 338
		screenFootFracX = 0.5, -- 339
		screenFootFracY = 0.235, -- 340
		zoomOverride = zoom -- 341
	}) -- 341
	self.proj = { -- 344
		morph = 1, -- 345
		focal = 390, -- 346
		vpFracX = 0.54, -- 347
		vpFracY = 0.43 - self.underTableFocus * 0.03, -- 348
		vpOffsetX = math.sin(self.animTime * 0.65) * 1.4, -- 349
		vpOffsetY = math.cos(self.animTime * 0.85) * 1, -- 350
		baseDepth = 0 -- 351
	} -- 351
end -- 235
function VillageUndertableScene.prototype.computeDesiredShoeFacing(self, p) -- 355
	if p.scavState == "chase" then -- 355
		return p.player.x >= p.scavX and 1 or -1 -- 357
	end -- 357
	if p.scavState == "turn" or p.scavState == "walk" or p.scavState == "stall" then -- 357
		if math.abs(p.scavTargetX - p.scavX) > 2 then -- 357
			return p.scavTargetX >= p.scavX and 1 or -1 -- 361
		end -- 361
	end -- 361
	if p.scavState == "back" and p.room.scavenger ~= nil then -- 361
		local home = math.max( -- 365
			p.room.scavenger.x0, -- 365
			math.min(p.room.scavenger.x1, p.scavX) -- 365
		) -- 365
		if math.abs(home - p.scavX) > 2 then -- 365
			return home > p.scavX and 1 or -1 -- 367
		end -- 367
	end -- 367
	return p.scavDir >= 0 and 1 or -1 -- 370
end -- 355
function VillageUndertableScene.prototype.onBottleLanded(self, ctx, ev) -- 373
	local p = ctx.p -- 374
	local x = type(ev.data.x) == "number" and ev.data.x or p.bottleLandX -- 375
	local y = type(ev.data.y) == "number" and ev.data.y or math.max(0, p.bottleLandY) -- 376
	local explicitSurface = type(ev.data.surface) == "string" and ev.data.surface or nil -- 377
	local surface = self:classifyLandingSurface(p, x, explicitSurface) -- 378
	self.lastSurface = surface -- 380
	self.lastLandX = x -- 381
	if surface == "iron" then -- 381
		self.ironHits = self.ironHits + 1 -- 384
		self.basinShakeTimer = self.basinShakeMax -- 385
		self.shoeToePauseTimer = 0 -- 386
		self.shoeTurnBlend = 0.25 -- 387
		local bx = self:getBasinWorldX(p) -- 388
		local ____self_rings_0 = self.rings -- 388
		____self_rings_0[#____self_rings_0 + 1] = { -- 390
			x = bx, -- 390
			y = 12, -- 390
			age = 0, -- 390
			duration = 1.05, -- 390
			maxRadius = 84, -- 390
			kind = "iron" -- 390
		} -- 390
		local ____self_rings_1 = self.rings -- 390
		____self_rings_1[#____self_rings_1 + 1] = { -- 391
			x = bx, -- 391
			y = 12, -- 391
			age = -0.14, -- 391
			duration = 1.2, -- 391
			maxRadius = 112, -- 391
			kind = "iron" -- 391
		} -- 391
		local ____self_rings_2 = self.rings -- 391
		____self_rings_2[#____self_rings_2 + 1] = { -- 392
			x = bx, -- 392
			y = 12, -- 392
			age = -0.28, -- 392
			duration = 1.32, -- 392
			maxRadius = 136, -- 392
			kind = "iron" -- 392
		} -- 392
		self:spawnShards(bx, 12, "iron", 7) -- 393
		local key = (((("fe04:village:iron_ring:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(ev.tick)) .. ":") .. tostring(ev.seq) -- 396
		ctx.audio:playOnce( -- 397
			key, -- 398
			"sfx", -- 399
			CHILD_AUDIO_ROOT .. "bottle_iron_ring.wav", -- 400
			0.82, -- 401
			"fe04:bottle:iron_ring", -- 402
			ev.tick, -- 403
			ev.seq -- 404
		) -- 404
	elseif surface == "brick" then -- 404
		self.brickHits = self.brickHits + 1 -- 407
		self.shoeToePauseTimer = 0.14 -- 409
		local ____self_rings_3 = self.rings -- 409
		____self_rings_3[#____self_rings_3 + 1] = { -- 410
			x = x, -- 410
			y = math.max(2, y), -- 410
			age = 0, -- 410
			duration = 0.44, -- 410
			maxRadius = 58, -- 410
			kind = "brick" -- 410
		} -- 410
		self:spawnShards( -- 411
			x, -- 411
			math.max(2, y), -- 411
			"brick", -- 411
			9 -- 411
		) -- 411
	else -- 411
		self.softHits = self.softHits + 1 -- 413
		local ____self_rings_4 = self.rings -- 413
		____self_rings_4[#____self_rings_4 + 1] = { -- 414
			x = x, -- 414
			y = math.max(2, y), -- 414
			age = 0, -- 414
			duration = 0.36, -- 414
			maxRadius = 24, -- 414
			kind = "soft" -- 414
		} -- 414
		self:spawnShards( -- 415
			x, -- 415
			math.max(2, y), -- 415
			"soft", -- 415
			6 -- 415
		) -- 415
		local audioKey = ((((((("r" .. tostring(ctx.events.roomSessionId)) .. ":cp") .. tostring(ctx.events.checkpoint)) .. ":t") .. tostring(ev.tick)) .. ":s") .. tostring(ev.seq)) .. ":bottleLanded" -- 418
		if not ctx.audio:hasPlayed(audioKey) then -- 418
			local key = (((("fe04:village:soft_thud:" .. tostring(ctx.events.roomSessionId)) .. ":") .. tostring(ev.tick)) .. ":") .. tostring(ev.seq) -- 420
			ctx.audio:playOnce( -- 421
				key, -- 422
				"sfx", -- 423
				CHILD_AUDIO_ROOT .. "bottle_soft.wav", -- 424
				0.76, -- 425
				"fe04:bottle:soft_thud", -- 426
				ev.tick, -- 427
				ev.seq -- 428
			) -- 428
		end -- 428
	end -- 428
end -- 373
function VillageUndertableScene.prototype.spawnShards(self, x, y, kind, count) -- 434
	local i = 0 -- 435
	do -- 435
		i = 0 -- 436
		while i < count do -- 436
			local ang = (0.18 + self:rand() * 0.64) * math.pi -- 437
			local spd = (kind == "soft" and 28 or 65) + self:rand() * (kind == "soft" and 36 or 95) -- 438
			local ____self_shards_5 = self.shards -- 438
			____self_shards_5[#____self_shards_5 + 1] = { -- 439
				x = x + (self:rand() - 0.5) * 10, -- 440
				y = y + 2, -- 441
				vx = math.cos(ang) * spd * (self:rand() > 0.5 and 1 or -1), -- 442
				vy = math.sin(ang) * spd, -- 443
				size = kind == "soft" and 2.2 + self:rand() * 2.4 or 1.8 + self:rand() * 2.2, -- 444
				life = (kind == "soft" and 0.34 or 0.48) + self:rand() * 0.22, -- 445
				maxLife = 0.65, -- 446
				kind = kind -- 447
			} -- 447
			i = i + 1 -- 436
		end -- 436
	end -- 436
end -- 434
function VillageUndertableScene.prototype.triggerRehearsalImpact(self, ctx, surface) -- 453
	local p = ctx.p -- 454
	local x = surface == "iron" and self:getBasinWorldX(p) or (surface == "soft" and self:getSoftWorldX(p) or self:getBrickWorldX(p)) -- 455
	self:onBottleLanded(ctx, {seq = 9000 + self.brickHits + self.ironHits + self.softHits, tick = p.ticks, name = "bottleLanded", data = {x = x, y = 0, surface = surface, heard = true}}) -- 458
end -- 453
function VillageUndertableScene.prototype.drawBackdrop(self, bgDraw, bgGlow, backdropArt, ctx) -- 466
	local p = ctx.p -- 472
	local cam = ctx.cam -- 473
	local w = cam.viewW -- 474
	local h = cam.viewH -- 475
	local ox = p.ox -- 476
	fillVGradRect( -- 479
		bgDraw, -- 479
		0, -- 479
		0, -- 479
		w, -- 479
		h, -- 479
		Color(20, 26, 38, 255), -- 479
		Color(7, 9, 15, 255) -- 479
	) -- 479
	local span = math.max(1, p.room.maxX - p.room.minX) -- 480
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 481
	local artW = math.max(w, h * 16 / 9) * 1.24 -- 482
	local artH = artW * 9 / 16 -- 483
	local artY = math.min( -- 484
		0, -- 484
		math.max(h - artH, cam.groundScreenY - artH * 0.24) -- 484
	) -- 484
	backdropArt:tryPlace( -- 485
		"bgFar_village", -- 485
		"fe04_bg_village", -- 485
		w * (0.5 - progress * 0.08), -- 485
		artY, -- 485
		artW, -- 485
		artH, -- 485
		{ -- 485
			color = Color(148, 168, 200, 255), -- 486
			layer = 0 -- 487
		} -- 487
	) -- 487
	fillVGradRect( -- 489
		bgGlow, -- 489
		0, -- 489
		cam.groundScreenY - 2, -- 489
		w, -- 489
		h * 0.16, -- 489
		Color(24, 34, 52, 24), -- 489
		Color(12, 18, 28, 0) -- 489
	) -- 489
	local towerPt = projectWorld3D( -- 492
		ox + 668, -- 492
		152, -- 492
		410, -- 492
		cam, -- 492
		self.proj -- 492
	) -- 492
	fillRadialGlow( -- 493
		bgGlow, -- 493
		towerPt.x, -- 493
		towerPt.y, -- 493
		20, -- 493
		20, -- 493
		Color(238, 198, 132, 54), -- 493
		Color(238, 198, 132, 0), -- 493
		12 -- 493
	) -- 493
	bgGlow:drawDot( -- 494
		Vec2(towerPt.x, towerPt.y), -- 494
		2, -- 494
		Color(252, 232, 186, 185) -- 494
	) -- 494
	return true -- 496
end -- 466
function VillageUndertableScene.prototype.drawWorld(self, fgDraw, fgGlow, worldArt, ctx) -- 499
	local p = ctx.p -- 505
	local cam = ctx.cam -- 506
	local ox = p.ox -- 507
	local groundY = cam:sy(0) -- 508
	local deckH = cam:len(26) -- 509
	local xMin = cam:sx(ox - 40) -- 512
	local xSplit = cam:sx(ox + 436) -- 513
	local xMax = cam:sx(ox + 760) -- 514
	if groundY - deckH > 0 then -- 514
		fillVGradRect( -- 516
			fgDraw, -- 516
			xMin, -- 516
			0, -- 516
			xMax - xMin, -- 516
			groundY - deckH + 1, -- 516
			Color(8, 10, 16, 255), -- 516
			Color(18, 22, 32, 255) -- 516
		) -- 516
	end -- 516
	local tileSpan = math.max( -- 518
		24, -- 518
		cam:len(74) -- 518
	) -- 518
	local j = 0 -- 519
	do -- 519
		j = 0 -- 520
		while xMin + j * tileSpan < xSplit do -- 520
			local tx = xMin + j * tileSpan -- 521
			local tw = math.min(tileSpan, xSplit - tx) -- 522
			worldArt:tryPlace( -- 523
				"fe_beam_wood", -- 523
				"fe04_vil_fl_in_" .. tostring(j), -- 523
				tx + tw * 0.5, -- 523
				groundY - deckH, -- 523
				tw + 0.5, -- 523
				deckH, -- 523
				{ -- 523
					color = Color(98, 86, 78, 255), -- 524
					layer = 1 -- 525
				} -- 525
			) -- 525
			j = j + 1 -- 520
		end -- 520
	end -- 520
	do -- 520
		j = 0 -- 528
		while xSplit + j * tileSpan < xMax do -- 528
			local tx = xSplit + j * tileSpan -- 529
			local tw = math.min(tileSpan, xMax - tx) -- 530
			worldArt:tryPlace( -- 531
				"fe_road_stone", -- 531
				"fe04_vil_fl_out_" .. tostring(j), -- 531
				tx + tw * 0.5, -- 531
				groundY - deckH, -- 531
				tw + 0.5, -- 531
				deckH, -- 531
				{ -- 531
					color = Color(162, 180, 206, 255), -- 532
					layer = 1 -- 533
				} -- 533
			) -- 533
			j = j + 1 -- 528
		end -- 528
	end -- 528
	fgDraw:drawSegment( -- 536
		Vec2(xMin, groundY), -- 536
		Vec2(xMax, groundY), -- 536
		1.1, -- 536
		Color(138, 158, 184, 115) -- 536
	) -- 536
	worldArt:tryPlace( -- 539
		"fe_pillar_wood", -- 539
		"fe04_vil_door_l", -- 539
		cam:sx(ox + 422), -- 539
		groundY, -- 539
		cam:len(12), -- 539
		cam:len(126), -- 539
		{ -- 539
			color = Color(116, 108, 104, 255), -- 540
			opacity = 0.78, -- 541
			layer = 2 -- 542
		} -- 542
	) -- 542
	worldArt:tryPlace( -- 544
		"fe_pillar_wood", -- 544
		"fe04_vil_door_r", -- 544
		cam:sx(ox + 458), -- 544
		groundY, -- 544
		cam:len(12), -- 544
		cam:len(126), -- 544
		{ -- 544
			color = Color(128, 122, 120, 255), -- 545
			opacity = 0.78, -- 546
			layer = 2 -- 547
		} -- 547
	) -- 547
	worldArt:tryPlace( -- 549
		"fe_beam_wood", -- 549
		"fe04_vil_door_top", -- 549
		cam:sx(ox + 440), -- 549
		cam:sy(120), -- 549
		cam:len(56), -- 549
		cam:len(14), -- 549
		{ -- 549
			color = Color(120, 112, 108, 255), -- 550
			opacity = 0.78, -- 551
			layer = 2 -- 552
		} -- 552
	) -- 552
	worldArt:tryPlace( -- 556
		"fe_bottle_rack", -- 556
		"fe04_vil_rack", -- 556
		cam:sx(ox + 112), -- 556
		groundY, -- 556
		cam:len(38), -- 556
		cam:len(54), -- 556
		{ -- 556
			color = Color(186, 194, 208, 255), -- 557
			layer = 3 -- 558
		} -- 558
	) -- 558
	local wallX0 = cam:sx(ox + 672) -- 560
	local wallX1 = cam:sx(ox + 720) -- 561
	local wallW = wallX1 - wallX0 -- 562
	local wallH = cam:len(96) -- 563
	worldArt:tryPlace( -- 564
		"wall", -- 564
		"fe04_vil_wall_lo", -- 564
		(wallX0 + wallX1) * 0.5, -- 564
		groundY, -- 564
		wallW, -- 564
		wallH * 0.52, -- 564
		{ -- 564
			color = Color(156, 174, 198, 255), -- 565
			layer = 2 -- 566
		} -- 566
	) -- 566
	worldArt:tryPlace( -- 568
		"wall", -- 568
		"fe04_vil_wall_hi", -- 568
		(wallX0 + wallX1) * 0.5, -- 568
		groundY + wallH * 0.5, -- 568
		wallW, -- 568
		wallH * 0.52, -- 568
		{ -- 568
			color = Color(164, 182, 206, 255), -- 569
			facing = -1, -- 570
			layer = 2 -- 571
		} -- 571
	) -- 571
	worldArt:tryPlace( -- 573
		"eaves", -- 573
		"fe04_vil_wall_eave", -- 573
		(wallX0 + wallX1) * 0.5, -- 573
		groundY + wallH - cam:len(2), -- 573
		wallW + cam:len(16), -- 573
		cam:len(18), -- 573
		{ -- 573
			color = Color(158, 174, 198, 255), -- 574
			layer = 3 -- 575
		} -- 575
	) -- 575
	local arch = p.room.arch -- 579
	worldArt:tryPlace( -- 580
		"prop_table", -- 580
		"fe04_vil_table_back", -- 580
		cam:sx((arch.x0 + arch.x1) * 0.5), -- 580
		groundY, -- 580
		cam:len(arch.x1 - arch.x0 + 18), -- 580
		cam:len(arch.h + 12), -- 580
		{ -- 580
			color = Color(108, 94, 84, 255), -- 581
			opacity = 0.92, -- 582
			layer = 2 -- 583
		} -- 583
	) -- 583
	local culvertX = self:getCulvertWorldX(p) -- 587
	local softX = self:getSoftWorldX(p) -- 588
	local brickX = self:getBrickWorldX(p) -- 589
	local basinX = self:getBasinWorldX(p) -- 590
	worldArt:tryPlace( -- 592
		"fe_culvert_grate", -- 592
		"fe04_vil_culvert", -- 592
		cam:sx(culvertX), -- 592
		groundY - cam:len(2), -- 592
		cam:len(42), -- 592
		cam:len(34), -- 592
		{ -- 592
			color = Color(188, 204, 224, 255), -- 593
			layer = 3 -- 594
		} -- 594
	) -- 594
	worldArt:tryPlace( -- 596
		"fe_ground_soft", -- 596
		"fe04_vil_soft", -- 596
		cam:sx(softX), -- 596
		groundY - cam:len(4), -- 596
		cam:len(54), -- 596
		cam:len(16), -- 596
		{ -- 596
			color = Color(154, 146, 138, 255), -- 597
			layer = 2 -- 598
		} -- 598
	) -- 598
	worldArt:tryPlace( -- 600
		"fe_ground_brick", -- 600
		"fe04_vil_brick", -- 600
		cam:sx(brickX), -- 600
		groundY - cam:len(4), -- 600
		cam:len(56), -- 600
		cam:len(16), -- 600
		{ -- 600
			color = Color(216, 226, 240, 255), -- 601
			layer = 2 -- 602
		} -- 602
	) -- 602
	local shaking = self.basinShakeTimer > 0 -- 605
	local shakeAngDeg = shaking and self.basinShakeAngle * 22 or 0 -- 606
	local shiftX = shaking and math.sin(self.basinShakeAngle * 2.2) * cam:len(2.4) or 0 -- 607
	worldArt:tryPlace( -- 608
		shaking and "fe_basin_tilt" or "fe_basin_flat", -- 608
		"fe04_vil_basin", -- 608
		cam:sx(basinX) + shiftX, -- 608
		groundY, -- 608
		cam:len(38), -- 608
		cam:len(22), -- 608
		{ -- 608
			angle = shakeAngDeg, -- 609
			color = Color(204, 218, 236, 255), -- 610
			layer = 4 -- 611
		} -- 611
	) -- 611
	fillRadialGlow( -- 615
		fgGlow, -- 615
		cam:sx(ox + 566), -- 615
		cam:sy(48), -- 615
		cam:len(128), -- 615
		cam:len(96), -- 615
		Color(188, 210, 232, 34), -- 615
		Color(150, 178, 208, 0), -- 615
		16 -- 615
	) -- 615
	fgDraw:drawEllipse( -- 618
		Vec2( -- 618
			cam:sx(p.player.x), -- 618
			cam:sy(p.player.y) + 1 -- 618
		), -- 618
		cam:len(14), -- 618
		3.4, -- 618
		Color(8, 10, 16, 155) -- 618
	) -- 618
	if p.room.scavenger ~= nil then -- 618
		fgDraw:drawEllipse( -- 620
			Vec2( -- 620
				cam:sx(p.scavX), -- 620
				cam:sy(p.room.scavenger.y) + 1 -- 620
			), -- 620
			cam:len(18), -- 620
			4, -- 620
			Color(8, 10, 16, 165) -- 620
		) -- 620
	end -- 620
	self:drawSurfaceReadabilityDetails( -- 624
		fgDraw, -- 624
		fgGlow, -- 624
		p, -- 624
		cam, -- 624
		softX, -- 624
		culvertX, -- 624
		basinX, -- 624
		brickX -- 624
	) -- 624
	return true -- 626
end -- 499
function VillageUndertableScene.prototype.drawSurfaceReadabilityDetails(self, fgDraw, fgGlow, p, cam, _softX, culvertX, basinX, brickX) -- 629
	local y0 = cam:sy(0) -- 639
	local cL = cam:sx(culvertX - 11) -- 642
	local cR = cam:sx(culvertX + 11) -- 643
	local rippleShift = math.sin(self.animTime * 2.3) * 3 -- 644
	fgGlow:drawSegment( -- 645
		Vec2(cL + 3 + rippleShift, y0 + 2), -- 645
		Vec2(cR - 4 + rippleShift, y0 + 2), -- 645
		1.1, -- 645
		Color(164, 192, 214, 105) -- 645
	) -- 645
	local shakeBoost = self.basinShakeTimer > 0 and clamp01(self.basinShakeTimer / self.basinShakeMax) or 0 -- 648
	local bx = cam:sx(basinX) -- 649
	local by = cam:sy(14) -- 650
	fillRadialGlow( -- 651
		fgGlow, -- 652
		bx, -- 653
		by, -- 654
		cam:len(22 + shakeBoost * 18), -- 655
		cam:len(10 + shakeBoost * 8), -- 656
		Color( -- 657
			216, -- 657
			226, -- 657
			236, -- 657
			math.floor(44 + 98 * shakeBoost + 0.5) -- 657
		), -- 657
		Color(186, 202, 220, 0), -- 658
		14 -- 659
	) -- 659
	fgDraw:drawSegment( -- 663
		Vec2( -- 663
			cam:sx(brickX - 24), -- 663
			cam:sy(3.2) -- 663
		), -- 663
		Vec2( -- 663
			cam:sx(brickX + 24), -- 663
			cam:sy(3.2) -- 663
		), -- 663
		1.4, -- 663
		Color(224, 230, 238, 185) -- 663
	) -- 663
	local i = 0 -- 666
	do -- 666
		i = 0 -- 667
		while i < #self.rings do -- 667
			do -- 667
				local rg = self.rings[i + 1] -- 668
				if rg.age < 0 then -- 668
					goto __continue66 -- 670
				end -- 670
				local t = clamp01(rg.age / rg.duration) -- 672
				local r = math.max( -- 673
					4, -- 673
					cam:len(rg.maxRadius) * (0.14 + 0.86 * t) -- 673
				) -- 673
				local alpha = (1 - t) * (rg.kind == "iron" and 0.88 or (rg.kind == "brick" and 0.82 or 0.4)) -- 674
				local rx = cam:sx(rg.x) -- 675
				local ry = cam:sy(rg.y) -- 676
				local ringCol = rg.kind == "iron" and Color( -- 677
					220, -- 678
					234, -- 678
					246, -- 678
					math.floor(235 * alpha + 0.5) -- 678
				) or (rg.kind == "brick" and Color( -- 678
					236, -- 680
					216, -- 680
					178, -- 680
					math.floor(225 * alpha + 0.5) -- 680
				) or Color( -- 680
					148, -- 681
					134, -- 681
					114, -- 681
					math.floor(165 * alpha + 0.5) -- 681
				)) -- 681
				drawEllipseRing( -- 682
					fgGlow, -- 682
					rx, -- 682
					ry, -- 682
					r, -- 682
					r * 0.34, -- 682
					rg.kind == "iron" and 1.8 or 1.4, -- 682
					ringCol, -- 682
					22 -- 682
				) -- 682
				if rg.kind == "iron" then -- 682
					drawEllipseRing( -- 684
						fgDraw, -- 684
						rx, -- 684
						ry, -- 684
						r * 0.96, -- 684
						r * 0.32, -- 684
						1.1, -- 684
						Color( -- 684
							214, -- 684
							224, -- 684
							236, -- 684
							math.floor(150 * alpha + 0.5) -- 684
						), -- 684
						22 -- 684
					) -- 684
				end -- 684
			end -- 684
			::__continue66:: -- 684
			i = i + 1 -- 667
		end -- 667
	end -- 667
	do -- 667
		i = 0 -- 687
		while i < #self.shards do -- 687
			local sp = self.shards[i + 1] -- 688
			local a = clamp01(sp.life / sp.maxLife) -- 689
			local col = sp.kind == "soft" and Color( -- 690
				138, -- 691
				120, -- 691
				98, -- 691
				math.floor(170 * a + 0.5) -- 691
			) or (sp.kind == "iron" and Color( -- 691
				224, -- 693
				232, -- 693
				242, -- 693
				math.floor(225 * a + 0.5) -- 693
			) or Color( -- 693
				216, -- 694
				198, -- 694
				174, -- 694
				math.floor(220 * a + 0.5) -- 694
			)) -- 694
			fgDraw:drawDot( -- 695
				Vec2( -- 695
					cam:sx(sp.x), -- 695
					cam:sy(sp.y) -- 695
				), -- 695
				sp.size, -- 695
				col -- 695
			) -- 695
			i = i + 1 -- 687
		end -- 687
	end -- 687
	if p.bottleLandT > 0 and p.bottleLandX >= 0 and #self.rings == 0 then -- 687
		local rx = cam:sx(p.bottleLandX) -- 699
		local ry = cam:sy(math.max(1, p.bottleLandY)) -- 700
		fgDraw:drawDot( -- 701
			Vec2(rx, ry), -- 701
			2.5, -- 701
			Color(216, 206, 186, 150) -- 701
		) -- 701
	end -- 701
end -- 629
function VillageUndertableScene.prototype.drawPropsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 706
	local p = ctx.p -- 712
	local cam = ctx.cam -- 713
	local bottle = p.room.bottle -- 716
	if bottle ~= nil and not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 then -- 716
		self:drawCeramicBottle( -- 718
			fgDraw, -- 718
			fgGlow, -- 718
			worldArt, -- 718
			"fe04_bottle_shelf", -- 718
			cam:sx(bottle.x), -- 718
			cam:sy(56), -- 718
			cam.ppu, -- 718
			0, -- 718
			true -- 718
		) -- 718
	end -- 718
	if p.hasBottle and p.aimHold <= 0 then -- 718
		local pl = p.player -- 723
		self:drawCeramicBottle( -- 724
			fgDraw, -- 725
			fgGlow, -- 726
			worldArt, -- 727
			"fe04_bottle_held", -- 728
			cam:sx(pl.x + pl.facing * 10), -- 729
			cam:sy(pl.y + pl.h * 0.52), -- 730
			cam.ppu, -- 731
			pl.facing * 0.22, -- 732
			false -- 733
		) -- 733
	end -- 733
	if p.bottleFly ~= nil then -- 733
		self:drawCeramicBottle( -- 737
			fgDraw, -- 738
			fgGlow, -- 739
			worldArt, -- 740
			"fe04_bottle_air", -- 741
			cam:sx(p.bottleFly.x), -- 742
			cam:sy(p.bottleFly.y), -- 743
			cam.ppu, -- 744
			self.animTime * 13.5, -- 745
			false -- 746
		) -- 746
	end -- 746
	if p.hasBottle and p.aimHold > 0 then -- 746
		local pl = p.player -- 752
		local endX = p.bottleAimX -- 753
		local endY = p.bottleAimY -- 754
		if endX < 0 then -- 754
			local wAim = cam:screenToWorld(p.aimX, p.aimY) -- 756
			endX = wAim.x -- 757
			endY = 0 -- 758
		end -- 758
		local dir = endX >= pl.x and 1 or -1 -- 760
		local x0 = pl.x + dir * 10 -- 761
		local y0 = pl.y + pl.h * 0.7 -- 762
		local vx = (endX - x0) / BOTTLE_FLY_T -- 763
		local vy = (endY - y0 + 0.5 * GRAVITY * BOTTLE_FLY_T * BOTTLE_FLY_T) / BOTTLE_FLY_T -- 764
		local previewSurface = self:classifyLandingSurface(p, endX) -- 766
		local arcRgb = previewSurface == "iron" and rgba(214, 228, 242, 255) or (previewSurface == "brick" and rgba(232, 206, 152, 255) or rgba(154, 142, 126, 255)) -- 767
		local steps = 18 -- 773
		local k = 1 -- 774
		do -- 774
			k = 1 -- 775
			while k <= steps do -- 775
				local tt = k / steps * BOTTLE_FLY_T -- 776
				local wx = x0 + vx * tt -- 777
				local wy = y0 + vy * tt - 0.5 * GRAVITY * tt * tt -- 778
				local alpha = 195 * (0.4 + 0.6 * (k / steps)) -- 779
				fgDraw:drawDot( -- 780
					Vec2( -- 780
						cam:sx(wx), -- 780
						cam:sy(wy) -- 780
					), -- 780
					2.5, -- 780
					toColor(arcRgb, alpha) -- 780
				) -- 780
				fgGlow:drawDot( -- 781
					Vec2( -- 781
						cam:sx(wx), -- 781
						cam:sy(wy) -- 781
					), -- 781
					3.2, -- 781
					toColor(arcRgb, alpha * 0.55) -- 781
				) -- 781
				k = k + 1 -- 775
			end -- 775
		end -- 775
		local lx = cam:sx(endX) -- 784
		local ly = cam:sy(endY + 2) -- 785
		local pulse = 0.88 + 0.12 * math.sin(self.animTime * 5.2) -- 786
		drawEllipseRing( -- 787
			fgDraw, -- 787
			lx, -- 787
			ly, -- 787
			11 * pulse, -- 787
			4.2 * pulse, -- 787
			1.6, -- 787
			toColor(arcRgb, 235), -- 787
			20 -- 787
		) -- 787
		if previewSurface == "iron" then -- 787
			drawEllipseRing( -- 789
				fgGlow, -- 789
				lx, -- 789
				ly, -- 789
				24 * pulse, -- 789
				9.2 * pulse, -- 789
				1.3, -- 789
				toColor(arcRgb, 195), -- 789
				22 -- 789
			) -- 789
		elseif previewSurface == "brick" then -- 789
			drawEllipseRing( -- 791
				fgGlow, -- 791
				lx, -- 791
				ly, -- 791
				18 * pulse, -- 791
				7 * pulse, -- 791
				1.2, -- 791
				toColor(arcRgb, 165), -- 791
				20 -- 791
			) -- 791
		end -- 791
	end -- 791
	return true -- 795
end -- 706
function VillageUndertableScene.prototype.drawCeramicBottle(self, fgDraw, fgGlow, worldArt, id, cx, cy, ppu, tilt, shelfGlint) -- 798
	local size = math.max(10, ppu * 10.5) -- 809
	if not worldArt:tryPlace( -- 809
		"prop_bottle", -- 810
		id, -- 810
		cx, -- 810
		cy, -- 810
		size, -- 810
		size, -- 810
		{angle = tilt * 180 / math.pi, layer = 8} -- 810
	) then -- 810
		fgDraw:drawCircle( -- 814
			Vec2(cx, cy), -- 814
			size * 0.36, -- 814
			Color(172, 138, 102, 245) -- 814
		) -- 814
	end -- 814
	if shelfGlint then -- 814
		local p = 0.72 + 0.28 * math.sin(self.animTime * 3) -- 817
		fillRadialGlow( -- 818
			fgGlow, -- 818
			cx, -- 818
			cy + 2, -- 818
			14 * p, -- 818
			14 * p, -- 818
			Color( -- 818
				224, -- 818
				214, -- 818
				190, -- 818
				math.floor(62 * p + 0.5) -- 818
			), -- 818
			Color(224, 214, 190, 0), -- 818
			12 -- 818
		) -- 818
	end -- 818
end -- 798
function VillageUndertableScene.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 823
	local p = ctx.p -- 829
	local cam = ctx.cam -- 830
	if p.room.scavenger ~= nil then -- 830
		self:drawScavengerShoeOverlay(fgDraw, fgGlow, p, cam) -- 832
	end -- 832
	if ctx.paused then -- 832
		local arch = p.room.arch -- 837
		local tableTopY = cam:sy(arch.h + 10) -- 838
		local tableX = cam:sx((arch.x0 + arch.x1) * 0.5) -- 839
		local tableW = cam:len(arch.x1 - arch.x0 + 24) -- 840
		worldArt:tryPlace( -- 841
			"fe_fg_table_top", -- 841
			"fe04_pause_table_top", -- 841
			tableX, -- 841
			tableTopY, -- 841
			tableW, -- 841
			cam:len(16), -- 841
			{opacity = 0.96, layer = 5300} -- 841
		) -- 841
		worldArt:tryPlace( -- 845
			"fe_fg_table_leg", -- 845
			"fe04_pause_table_leg", -- 845
			cam:sx(arch.x1 - 2), -- 845
			cam:sy(arch.h), -- 845
			cam:len(12), -- 845
			cam:len(arch.h), -- 845
			{opacity = 0.96, layer = 5310} -- 845
		) -- 845
	end -- 845
end -- 823
function VillageUndertableScene.prototype.drawScavengerShoeOverlay(self, fgDraw, fgGlow, p, cam) -- 852
	local cx = cam:sx(p.scavX) -- 858
	local by = cam:sy(p.room.scavenger ~= nil and p.room.scavenger.y or 0) -- 859
	local f = self.shoeFacing >= 0 and 1 or -1 -- 860
	local pausedToe = self.shoeToePauseTimer > 0 -- 861
	fillRadialGlow( -- 864
		fgGlow, -- 864
		cx + f * cam:len(5), -- 864
		by + 2, -- 864
		cam:len(34), -- 864
		cam:len(9), -- 864
		Color(196, 208, 224, 56), -- 864
		Color(156, 172, 190, 0), -- 864
		14 -- 864
	) -- 864
	fgDraw:drawEllipse( -- 865
		Vec2( -- 865
			cx + f * cam:len(3), -- 865
			by + 1 -- 865
		), -- 865
		cam:len(18), -- 865
		cam:len(3.2), -- 865
		Color(118, 130, 144, 62) -- 865
	) -- 865
	if pausedToe then -- 865
		fgGlow:drawDot( -- 869
			Vec2( -- 869
				cx + f * cam:len(9), -- 869
				by + 2 -- 869
			), -- 869
			3.4, -- 869
			Color(236, 218, 178, 175) -- 869
		) -- 869
	end -- 869
end -- 852
function VillageUndertableScene.prototype.drawForegroundOverlay(self, uiDraw, _uiInkDraw, uiArt, uiGlow, ctx) -- 877
	local p = ctx.p -- 884
	local cam = ctx.cam -- 885
	local inv = 1 / math.max(0.25, ctx.uiScale) -- 886
	local arch = p.room.arch -- 887
	local tableCx = cam:sx((arch.x0 + arch.x1) * 0.5) * inv -- 889
	local tableW = cam:len(arch.x1 - arch.x0 + 26) * inv -- 890
	local tableTopUiY = cam:sy(arch.h + 10) * inv -- 891
	local tableBotUiY = cam:sy(arch.h) * inv -- 892
	local legH = math.max( -- 893
		12, -- 893
		tableBotUiY - cam:sy(0) * inv -- 893
	) -- 893
	local legW = math.max( -- 894
		8, -- 894
		cam:len(11) * inv -- 894
	) -- 894
	uiArt:tryPlace( -- 897
		"fe_fg_table_leg", -- 897
		"fe04_fg_leg_l", -- 897
		cam:sx(arch.x0 + 2) * inv, -- 897
		tableBotUiY, -- 897
		legW, -- 897
		legH, -- 897
		{opacity = 0.96, layer = 2} -- 897
	) -- 897
	uiArt:tryPlace( -- 901
		"fe_fg_table_leg", -- 901
		"fe04_fg_leg_r", -- 901
		cam:sx(arch.x1 - 2) * inv, -- 901
		tableBotUiY, -- 901
		legW, -- 901
		legH, -- 901
		{opacity = 0.96, layer = 2} -- 901
	) -- 901
	uiArt:tryPlace( -- 905
		"fe_fg_table_top", -- 905
		"fe04_fg_top", -- 905
		tableCx, -- 905
		tableTopUiY, -- 905
		tableW, -- 905
		math.max( -- 905
			10, -- 905
			cam:len(14) * inv -- 905
		), -- 905
		{opacity = 0.98, layer = 3} -- 905
	) -- 905
	if p.player.crouch and p.player.x >= arch.x0 - 16 and p.player.x <= arch.x1 + 16 then -- 905
		local beamOffset = (cam.x - p.ox - 360) * 0.35 * inv -- 912
		uiArt:tryPlace( -- 913
			"fe_fg_table_top", -- 913
			"fe04_fg_crouch_beam", -- 913
			ctx.uiW * 0.5 - beamOffset * 0.25, -- 913
			ctx.uiH + 4, -- 913
			ctx.uiW * 1.12, -- 913
			ctx.uiH * 0.11, -- 913
			{ -- 913
				color = Color(24, 22, 26, 255), -- 914
				opacity = 0.72, -- 915
				layer = 4 -- 916
			} -- 916
		) -- 916
	end -- 916
	drawChildColdMoonGrade( -- 921
		uiDraw, -- 921
		uiGlow, -- 921
		ctx.uiW, -- 921
		ctx.uiH, -- 921
		0.84, -- 921
		0 -- 921
	) -- 921
	return false -- 923
end -- 877
return ____exports -- 877