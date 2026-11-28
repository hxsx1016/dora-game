-- [ts]: xiaoman3d_entities.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 15
local Color = ____Dora.Color -- 15
local Color3 = ____Dora.Color3 -- 15
local DirectionalLight3D = ____Dora.DirectionalLight3D -- 15
local Model3D = ____Dora.Model3D -- 15
local Node3D = ____Dora.Node3D -- 15
local PointLight3D = ____Dora.PointLight3D -- 15
local Vec2 = ____Dora.Vec2 -- 15
local Vec3 = ____Dora.Vec3 -- 15
local ____play = require("Script.watch.play") -- 17
local BOTTLE_FLY_TIME = ____play.BOTTLE_FLY_TIME -- 17
local PATH_SKY = "assets/xiaoman3d/sky_backdrop.glb" -- 19
local PATH_SCAV = "assets/xiaoman3d/scavenger.glb" -- 20
local PATH_DOG = "assets/xiaoman3d/dog.glb" -- 21
local PATH_GUARD = "assets/xiaoman3d/guard.glb" -- 22
local PATH_CART = "assets/xiaoman3d/cart.glb" -- 23
local PATH_BOTTLE = "assets/xiaoman3d/bottle.glb" -- 24
local PATH_BASIN = "assets/xiaoman3d/basin.glb" -- 25
local PATH_DOOR = "assets/xiaoman3d/door.glb" -- 26
local PATH_LANTERN = "assets/xiaoman3d/lantern.glb" -- 27
local PATH_LEDGER = "assets/xiaoman3d/ledger.glb" -- 28
local PATH_POUCH = "assets/xiaoman3d/pouch.glb" -- 29
local PATH_LATCH = "assets/xiaoman3d/latch.glb" -- 30
local PATH_GRASS = "assets/xiaoman3d/grass.glb" -- 31
local PATH_TWIG = "assets/xiaoman3d/twig.glb" -- 32
local PATH_BOUGH = "assets/xiaoman3d/bough.glb" -- 33
____exports.BASIN_DEPTH = 18 -- 35
____exports.BASIN_BASE_HEIGHT = 9.5 -- 36
local TWIG_OFFSETS = {235, 455, 865, 1115} -- 38
local GRASS_CENTERS = {340, 745, 1195} -- 39
local function mountModel(parent, path) -- 74
	local m = Model3D(path) -- 75
	if m.parent ~= nil then -- 75
		m:removeFromParent(false) -- 77
	end -- 77
	parent:addChild(m) -- 79
	m.visible = false -- 80
	return m -- 81
end -- 74
local function clamp01(v) -- 84
	if v <= 0 then -- 84
		return 0 -- 85
	end -- 85
	if v >= 1 then -- 85
		return 1 -- 86
	end -- 86
	return v -- 87
end -- 84
local function smoothstep(e0, e1, x) -- 90
	local t = clamp01((x - e0) / math.max(0.0001, e1 - e0)) -- 91
	return t * t * (3 - 2 * t) -- 92
end -- 90
local function drawGroundRing(draw, cam, ring, radius, col, segs) -- 95
	if segs == nil then -- 95
		segs = 28 -- 95
	end -- 95
	local pts = {} -- 96
	local i = 0 -- 97
	do -- 97
		i = 0 -- 98
		while i < segs do -- 98
			local a = i / segs * math.pi * 2 -- 99
			local pt = cam:worldToScreen( -- 100
				ring.x + math.cos(a) * radius, -- 100
				ring.y, -- 100
				ring.depth + math.sin(a) * radius -- 100
			) -- 100
			pts[#pts + 1] = Vec2(pt.x, pt.y) -- 101
			i = i + 1 -- 98
		end -- 98
	end -- 98
	draw:drawPolygon( -- 103
		pts, -- 103
		Color(0, 0, 0, 0), -- 103
		1.4, -- 103
		col -- 103
	) -- 103
end -- 95
____exports.Xiaoman3DEntities = __TS__Class() -- 106
local Xiaoman3DEntities = ____exports.Xiaoman3DEntities -- 106
Xiaoman3DEntities.name = "Xiaoman3DEntities" -- 106
function Xiaoman3DEntities.prototype.____constructor(self, root) -- 165
	self.container = Node3D() -- 107
	self.moonLight = DirectionalLight3D() -- 110
	self.fillLight = DirectionalLight3D() -- 111
	self.roomLightA = PointLight3D() -- 112
	self.roomLightB = PointLight3D() -- 113
	self.cartAnim = "" -- 122
	self.prevCartAxle = 0 -- 123
	self.scavAnim = "" -- 130
	self.scavYaw = -80 -- 131
	self.prevScavX = 0 -- 132
	self.basinShakeTimer = 0 -- 133
	self.prevBottleLandT = 0 -- 134
	self.dogAnim = "" -- 138
	self.dogYaw = -84 -- 139
	self.prevDogX = 0 -- 140
	self.grasses = {} -- 142
	self.twigs = {} -- 143
	self.creekReveal = 0 -- 146
	self.lastSnappedTwig = -1 -- 147
	self.guardAnim = "" -- 155
	self.doorOpenFrac = 0 -- 156
	self.lastRoom = "" -- 159
	self.time = 0 -- 160
	self.rings = {} -- 161
	self.shards = {} -- 162
	self.animatedModels = {} -- 163
	root:addChild(self.container) -- 166
	self.moonLight.color = Color3(135, 168, 214) -- 169
	self.moonLight.intensity = 1.35 -- 170
	self.moonLight.angles = Vec3(-44, -28, 0) -- 171
	self.moonLight.castShadow = true -- 172
	self.moonLight.shadowBias = 0.0018 -- 173
	self.moonLight.shadowNormalBias = 0.028 -- 174
	self.moonLight.shadowSoftness = 1.6 -- 175
	self.container:addChild(self.moonLight) -- 176
	self.fillLight.color = Color3(62, 82, 112) -- 179
	self.fillLight.intensity = 0.42 -- 180
	self.fillLight.angles = Vec3(28, 146, 0) -- 181
	self.fillLight.castShadow = false -- 182
	self.container:addChild(self.fillLight) -- 183
	self.roomLightA.color = Color3(255, 198, 112) -- 186
	self.roomLightA.intensity = 0 -- 187
	self.roomLightA.range = 4 -- 188
	self.container:addChild(self.roomLightA) -- 189
	self.roomLightB.color = Color3(156, 186, 224) -- 191
	self.roomLightB.intensity = 0 -- 192
	self.roomLightB.range = 3 -- 193
	self.container:addChild(self.roomLightB) -- 194
end -- 165
function Xiaoman3DEntities.prototype.registerAnimated(self, m) -- 197
	local ____self_animatedModels_0 = self.animatedModels -- 197
	____self_animatedModels_0[#____self_animatedModels_0 + 1] = m -- 198
	return m -- 199
end -- 197
function Xiaoman3DEntities.prototype.hideAllEntities(self) -- 202
	if self.cart ~= nil then -- 202
		self.cart.visible = false -- 203
	end -- 203
	if self.latch ~= nil then -- 203
		self.latch.visible = false -- 204
	end -- 204
	if self.outsideLantern ~= nil then -- 204
		self.outsideLantern.visible = false -- 205
	end -- 205
	if self.scav ~= nil then -- 205
		self.scav.visible = false -- 207
	end -- 207
	if self.shelfBottle ~= nil then -- 207
		self.shelfBottle.visible = false -- 208
	end -- 208
	if self.airBottle ~= nil then -- 208
		self.airBottle.visible = false -- 209
	end -- 209
	if self.basin ~= nil then -- 209
		self.basin.visible = false -- 210
	end -- 210
	if self.dog ~= nil then -- 210
		self.dog.visible = false -- 212
	end -- 212
	if self.creekLantern ~= nil then -- 212
		self.creekLantern.visible = false -- 213
	end -- 213
	local i = 0 -- 214
	do -- 214
		i = 0 -- 215
		while i < #self.grasses do -- 215
			self.grasses[i + 1].visible = false -- 215
			i = i + 1 -- 215
		end -- 215
	end -- 215
	do -- 215
		i = 0 -- 216
		while i < #self.twigs do -- 216
			self.twigs[i + 1].visible = false -- 216
			i = i + 1 -- 216
		end -- 216
	end -- 216
	if self.boughL ~= nil then -- 216
		self.boughL.visible = false -- 217
	end -- 217
	if self.boughR ~= nil then -- 217
		self.boughR.visible = false -- 218
	end -- 218
	if self.door ~= nil then -- 218
		self.door.visible = false -- 220
	end -- 220
	if self.guard ~= nil then -- 220
		self.guard.visible = false -- 221
	end -- 221
	if self.towerLantern ~= nil then -- 221
		self.towerLantern.visible = false -- 222
	end -- 222
	if self.ledger ~= nil then -- 222
		self.ledger.visible = false -- 223
	end -- 223
	if self.pouch ~= nil then -- 223
		self.pouch.visible = false -- 224
	end -- 224
end -- 202
function Xiaoman3DEntities.prototype.hide(self) -- 227
	self:setPaused(true) -- 228
end -- 227
function Xiaoman3DEntities.prototype.setPaused(self, paused) -- 231
	local i = 0 -- 232
	do -- 232
		i = 0 -- 233
		while i < #self.animatedModels do -- 233
			local m = self.animatedModels[i + 1] -- 234
			if paused then -- 234
				if not m.paused then -- 234
					m:pause() -- 236
				end -- 236
			elseif m.paused then -- 236
				m:resume() -- 238
			end -- 238
			i = i + 1 -- 233
		end -- 233
	end -- 233
end -- 231
function Xiaoman3DEntities.prototype.update(self, p, dt, camX, glow, groundFx, overlay, cam) -- 243
	local paused = p.paused or dt <= 0 -- 244
	local safeDt = paused and 0 or math.min(0.05, dt) -- 245
	self:setPaused(paused) -- 246
	if not paused then -- 246
		self.time = self.time + safeDt -- 248
	end -- 248
	if self.lastRoom ~= p.room.key then -- 248
		self.lastRoom = p.room.key -- 252
		self:hideAllEntities() -- 253
		self.rings = {} -- 254
		self.shards = {} -- 255
		self.basinShakeTimer = 0 -- 256
		self.prevBottleLandT = 0 -- 257
		self.prevCartAxle = p.cartAxle -- 258
		self.prevScavX = p.scavX -- 259
		self.prevDogX = p.dogX -- 260
		self.doorOpenFrac = p.towerDoorOpen and 1 or 0 -- 261
		self.creekReveal = 0 -- 262
		self.lastSnappedTwig = -1 -- 263
	end -- 263
	if self.sky == nil then -- 263
		self.sky = mountModel(self.container, PATH_SKY) -- 268
	end -- 268
	self.sky.visible = true -- 270
	self.sky.position = Vec3(camX / 100, -0.3, -4.5) -- 271
	self.sky.scale = Vec3(1.15, 1, 1) -- 272
	if p.room.key == "outside" then -- 272
		self:updateOutside(p, safeDt) -- 276
	elseif p.room.key == "village" then -- 276
		self:updateVillage(p, safeDt, groundFx) -- 278
	elseif p.room.key == "forest" then -- 278
		self:updateForest(p, safeDt, glow, groundFx) -- 280
	elseif p.room.key == "tower" then -- 280
		self:updateTower(p, safeDt) -- 282
	end -- 282
	self:stepAndDrawFx(safeDt, glow, overlay, cam) -- 286
end -- 243
function Xiaoman3DEntities.prototype.updateOutside(self, p, dt) -- 291
	local ox = p.ox / 100 -- 292
	self.moonLight.color = Color3(144, 178, 224) -- 295
	self.moonLight.intensity = 1.68 -- 296
	self.moonLight.angles = Vec3(-44, -26, 0) -- 297
	self.fillLight.color = Color3(68, 92, 126) -- 298
	self.fillLight.intensity = 0.54 -- 299
	local pulse = 0.92 + math.sin(self.time * 2.4) * 0.08 -- 302
	self.roomLightA.color = Color3(255, 196, 108) -- 303
	self.roomLightA.intensity = 2.6 * pulse -- 304
	self.roomLightA.range = 5.2 -- 305
	self.roomLightA.position = Vec3(ox + 11.2, 1.55, -0.75) -- 306
	self.roomLightB.color = Color3(166, 192, 224) -- 309
	self.roomLightB.intensity = 1.05 -- 310
	self.roomLightB.range = 3.2 -- 311
	self.roomLightB.position = Vec3(p.cartAxle / 100, 1.65, 0.85) -- 312
	local c = p.room.cart -- 315
	if c.bodyW > 0 then -- 315
		if self.cart == nil then -- 315
			self.cart = self:registerAnimated(mountModel(self.container, PATH_CART)) -- 318
		end -- 318
		self.cart.visible = true -- 320
		self.cart.position = Vec3(p.cartAxle / 100, c.baseY / 100, -(c.depth or 0) / 100) -- 321
		self.cart.angles = Vec3(0, 0, 0) -- 322
		local rolling = math.abs(p.cartAxle - self.prevCartAxle) > 0.04 -- 324
		self.prevCartAxle = p.cartAxle -- 325
		local nextAnim = rolling and "roll" or "idle" -- 326
		if self.cartAnim ~= nextAnim then -- 326
			self.cartAnim = nextAnim -- 328
			self.cart:play(nextAnim, true) -- 329
		end -- 329
		self.cart.speed = rolling and 1.15 or 0.75 -- 331
	end -- 331
	local latchBounds = p:cartLatchBounds() -- 335
	if latchBounds ~= nil then -- 335
		if self.latch == nil then -- 335
			self.latch = mountModel(self.container, PATH_LATCH) -- 338
		end -- 338
		self.latch.visible = true -- 340
		self.latch.position = Vec3((latchBounds.x + latchBounds.width * 0.5) / 100, latchBounds.y / 100, -0.52) -- 341
		self.latch.scale = Vec3( -- 342
			math.max(0.7, latchBounds.width / 48), -- 342
			1, -- 342
			1 -- 342
		) -- 342
	elseif self.latch ~= nil then -- 342
		self.latch.visible = false -- 344
	end -- 344
	if self.outsideLantern == nil then -- 344
		self.outsideLantern = mountModel(self.container, PATH_LANTERN) -- 349
	end -- 349
	self.outsideLantern.visible = true -- 351
	self.outsideLantern.position = Vec3(ox + 11.2, 1.48, -0.95) -- 352
	self.outsideLantern.angles = Vec3( -- 353
		0, -- 353
		0, -- 353
		math.sin(self.time * 1.9) * 3.5 -- 353
	) -- 353
end -- 291
function Xiaoman3DEntities.prototype.updateVillage(self, p, dt, groundFx) -- 358
	local ox = p.ox / 100 -- 359
	self.moonLight.color = Color3(132, 166, 214) -- 362
	self.moonLight.intensity = 1.48 -- 363
	self.moonLight.angles = Vec3(-52, -32, 0) -- 364
	self.fillLight.color = Color3(62, 80, 110) -- 365
	self.fillLight.intensity = 0.5 -- 366
	self.roomLightA.color = Color3(162, 194, 232) -- 369
	self.roomLightA.intensity = 1.95 -- 370
	self.roomLightA.range = 4 -- 371
	self.roomLightA.position = Vec3(ox + 5.75, 1.38, 0.45) -- 372
	self.roomLightB.color = Color3(212, 178, 134) -- 375
	self.roomLightB.intensity = 1.05 -- 376
	self.roomLightB.range = 2.5 -- 377
	self.roomLightB.position = Vec3(ox + 1.12, 0.85, 0.36) -- 378
	if self.shelfBottle == nil then -- 378
		self.shelfBottle = mountModel(self.container, PATH_BOTTLE) -- 382
	end -- 382
	local showShelfBottle = not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 and p.room.bottle ~= nil -- 384
	self.shelfBottle.visible = showShelfBottle -- 385
	if showShelfBottle and p.room.bottle ~= nil then -- 385
		local bx = math.min(p.room.bottle.x, p.ox + 108) / 100 -- 387
		self.shelfBottle.position = Vec3(bx, 0.46, 0.06) -- 388
	end -- 388
	if self.airBottle == nil then -- 388
		self.airBottle = mountModel(self.container, PATH_BOTTLE) -- 393
	end -- 393
	if p.bottleFly ~= nil then -- 393
		self.airBottle.visible = true -- 396
		local prog = clamp01(p.bottleFly.t / BOTTLE_FLY_TIME) -- 397
		local z = -(p.bottleFly.startDepth + (p.bottleFly.target.depth - p.bottleFly.startDepth) * prog) / 100 -- 398
		self.airBottle.position = Vec3(p.bottleFly.x / 100, p.bottleFly.y / 100, z) -- 399
		self.airBottle.angles = Vec3(self.time * 240, 0, -self.time * 540) -- 400
	else -- 400
		self.airBottle.visible = false -- 402
	end -- 402
	if p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 then -- 402
		local lx = p.bottleLandX -- 407
		local kind = p.bottleLandSurface -- 408
		self:spawnBottleImpactFx(lx, p.bottleLandY, p.bottleLandDepth, kind) -- 409
		if kind == "iron" then -- 409
			self.basinShakeTimer = 1.15 -- 411
		end -- 411
	end -- 411
	self.prevBottleLandT = p.bottleLandT -- 414
	if self.basin == nil then -- 414
		self.basin = mountModel(self.container, PATH_BASIN) -- 418
	end -- 418
	local basinX = (p.room.basinX ~= nil and p.room.basinX or p.ox + 548) / 100 -- 420
	self.basin.visible = true -- 421
	self.basin.position = Vec3(basinX, ____exports.BASIN_BASE_HEIGHT / 100, -____exports.BASIN_DEPTH / 100) -- 422
	if self.basinShakeTimer > 0 then -- 422
		self.basinShakeTimer = math.max(0, self.basinShakeTimer - dt) -- 424
		local amp = self.basinShakeTimer / 1.15 -- 425
		local wobble = amp * amp -- 426
		self.basin.angles = Vec3( -- 427
			math.sin(self.time * 48) * 14 * wobble, -- 428
			math.sin(self.time * 24) * 6 * wobble, -- 429
			math.cos(self.time * 42) * 16 * wobble -- 430
		) -- 430
	else -- 430
		self.basin.angles = Vec3(0, 0, 0) -- 433
	end -- 433
	if p.room.scavenger ~= nil then -- 433
		if self.scav == nil then -- 433
			self.scav = self:registerAnimated(mountModel(self.container, PATH_SCAV)) -- 439
		end -- 439
		self.scav.visible = true -- 441
		self.scav.position = Vec3(p.scavX / 100, p.room.scavenger.y / 100, 0.02) -- 442
		local dx = p.scavX - self.prevScavX -- 444
		self.prevScavX = p.scavX -- 445
		local desiredDir = p.scavDir -- 447
		if p.scavState == "turn" or p.scavState == "walk" then -- 447
			desiredDir = p.scavTargetX >= p.scavX and 1 or -1 -- 449
		elseif p.scavState == "chase" then -- 449
			desiredDir = p.player.x >= p.scavX and 1 or -1 -- 451
		elseif math.abs(dx) > 0.02 then -- 451
			desiredDir = dx > 0 and 1 or -1 -- 453
		end -- 453
		local targetYaw = desiredDir >= 0 and 80 or -80 -- 455
		self.scavYaw = self.scavYaw + (targetYaw - self.scavYaw) * math.min(1, dt * 10) -- 456
		self.scav.angles = Vec3(0, self.scavYaw, 0) -- 457
		local nextAnim = "idle" -- 459
		if p.scavState == "chase" then -- 459
			nextAnim = "chase" -- 461
		elseif p.scavState == "turn" then -- 461
			nextAnim = "turn" -- 463
		elseif p.scavState == "walk" or p.scavState == "back" or p.scavState == "patrol" and math.abs(dx) > 0.01 then -- 463
			nextAnim = "walk" -- 465
		else -- 465
			nextAnim = "idle" -- 467
		end -- 467
		if self.scavAnim ~= nextAnim then -- 467
			self.scavAnim = nextAnim -- 470
			self.scav:play(nextAnim, true) -- 471
		end -- 471
		local lookDir = self.scavYaw >= 0 and 1 or -1 -- 475
		local alert = p.scavState == "chase" or p.scavState == "turn" -- 476
		local coneCol = alert and Color(188, 72, 54, 48) or Color(128, 152, 184, 28) -- 477
		local edgeCol = alert and Color(214, 96, 68, 86) or Color(156, 182, 212, 52) -- 478
		local sx = p.scavX -- 479
		local coneLen = alert and 115 or 88 -- 480
		groundFx:drawPolygon( -- 481
			{ -- 481
				Vec2(sx, 0), -- 482
				Vec2(sx + lookDir * coneLen, -34), -- 483
				Vec2(sx + lookDir * coneLen, 34) -- 484
			}, -- 484
			coneCol, -- 485
			0.8, -- 485
			edgeCol -- 485
		) -- 485
	end -- 485
	if p.passed then -- 485
		local pulse = 0.65 + 0.35 * math.sin(self.time * 2.2) -- 490
		groundFx:drawPolygon( -- 491
			{ -- 491
				Vec2(p.ox + 566, -34), -- 492
				Vec2(p.ox + 634, -34), -- 493
				Vec2(p.ox + 634, -18), -- 494
				Vec2(p.ox + 566, -18) -- 495
			}, -- 495
			Color( -- 496
				92, -- 496
				134, -- 496
				154, -- 496
				math.floor(42 * pulse + 0.5) -- 496
			), -- 496
			1, -- 496
			Color( -- 496
				164, -- 496
				206, -- 496
				224, -- 496
				math.floor(96 * pulse + 0.5) -- 496
			) -- 496
		) -- 496
	end -- 496
end -- 358
function Xiaoman3DEntities.prototype.spawnBottleImpactFx(self, x, y, depth, kind) -- 500
	if kind == "iron" then -- 500
		local ____self_rings_1 = self.rings -- 500
		____self_rings_1[#____self_rings_1 + 1] = { -- 502
			x = x, -- 502
			y = y, -- 502
			depth = depth, -- 502
			age = 0, -- 502
			duration = 1.05, -- 502
			maxRadius = 96, -- 502
			kind = kind -- 502
		} -- 502
		local ____self_rings_2 = self.rings -- 502
		____self_rings_2[#____self_rings_2 + 1] = { -- 503
			x = x, -- 503
			y = y, -- 503
			depth = depth, -- 503
			age = -0.22, -- 503
			duration = 1.15, -- 503
			maxRadius = 122, -- 503
			kind = kind -- 503
		} -- 503
	elseif kind == "brick" then -- 503
		local ____self_rings_3 = self.rings -- 503
		____self_rings_3[#____self_rings_3 + 1] = { -- 505
			x = x, -- 505
			y = y, -- 505
			depth = depth, -- 505
			age = 0, -- 505
			duration = 0.62, -- 505
			maxRadius = 68, -- 505
			kind = kind -- 505
		} -- 505
	else -- 505
		local ____self_rings_4 = self.rings -- 505
		____self_rings_4[#____self_rings_4 + 1] = { -- 507
			x = x, -- 507
			y = y, -- 507
			depth = depth, -- 507
			age = 0, -- 507
			duration = 0.45, -- 507
			maxRadius = 26, -- 507
			kind = kind -- 507
		} -- 507
	end -- 507
	local count = kind == "soft" and 5 or 9 -- 510
	local col = kind == "iron" and Color(224, 232, 244, 220) or (kind == "brick" and Color(204, 154, 108, 220) or Color(118, 98, 76, 170)) -- 511
	local i = 0 -- 514
	do -- 514
		i = 0 -- 515
		while i < count do -- 515
			local frac = i / count - 0.5 -- 516
			local ____self_shards_5 = self.shards -- 516
			____self_shards_5[#____self_shards_5 + 1] = { -- 517
				x = x + frac * 10, -- 518
				depth = depth, -- 519
				y = y + 4, -- 520
				vx = frac * (kind == "soft" and 45 or 135), -- 521
				vy = (kind == "soft" and 48 or 115) + i % 3 * 28, -- 522
				life = 0, -- 523
				maxLife = kind == "soft" and 0.35 or 0.48, -- 524
				color = col -- 525
			} -- 525
			i = i + 1 -- 515
		end -- 515
	end -- 515
end -- 500
function Xiaoman3DEntities.prototype.updateForest(self, p, dt, glow, groundFx) -- 532
	local ox = p.ox / 100 -- 533
	self.moonLight.color = Color3(126, 168, 198) -- 536
	self.moonLight.intensity = 1.52 -- 537
	self.moonLight.angles = Vec3(-46, -24, 0) -- 538
	self.fillLight.color = Color3(56, 84, 98) -- 539
	self.fillLight.intensity = 0.52 -- 540
	local flick = 0.9 + math.sin(self.time * 3.6) * 0.06 + math.cos(self.time * 6.1) * 0.04 -- 543
	self.roomLightA.color = Color3(255, 198, 112) -- 544
	self.roomLightA.intensity = 2.9 * flick -- 545
	self.roomLightA.range = 5.4 -- 546
	self.roomLightA.position = Vec3(ox + 12.24, 0.72, -0.62) -- 547
	self.roomLightB.color = Color3(144, 184, 214) -- 550
	self.roomLightB.intensity = 1.15 -- 551
	self.roomLightB.range = 4.6 -- 552
	self.roomLightB.position = Vec3(ox + 7.45, 1.85, 0.65) -- 553
	if self.dog == nil then -- 553
		self.dog = self:registerAnimated(mountModel(self.container, PATH_DOG)) -- 557
	end -- 557
	self.dog.visible = true -- 559
	self.dog.position = Vec3(p.dogX / 100, 0, -0.06) -- 560
	local ddx = p.dogX - self.prevDogX -- 562
	self.prevDogX = p.dogX -- 563
	local dogDir = self.dogYaw >= 0 and 1 or -1 -- 564
	if p.dogState == "chase" or p.dogState == "ear" then -- 564
		dogDir = p.player.x >= p.dogX and 1 or -1 -- 566
	elseif math.abs(ddx) > 0.02 then -- 566
		dogDir = ddx > 0 and 1 or -1 -- 568
	end -- 568
	local targetDogYaw = dogDir >= 0 and 84 or -84 -- 570
	self.dogYaw = self.dogYaw + (targetDogYaw - self.dogYaw) * math.min(1, dt * 12) -- 571
	self.dog.angles = Vec3(0, self.dogYaw, 0) -- 572
	local nextDogAnim = "walk" -- 574
	if p.dogState == "ear" then -- 574
		nextDogAnim = "ear" -- 576
	elseif p.dogState == "chase" then -- 576
		nextDogAnim = "chase" -- 578
	elseif p.dogState == "sniff" then -- 578
		nextDogAnim = "sniff" -- 580
	elseif math.abs(ddx) > 0.01 then -- 580
		nextDogAnim = "walk" -- 582
	else -- 582
		nextDogAnim = "idle" -- 584
	end -- 584
	if self.dogAnim ~= nextDogAnim then -- 584
		self.dogAnim = nextDogAnim -- 587
		self.dog:play(nextDogAnim, true) -- 588
	end -- 588
	if #self.grasses == 0 then -- 588
		local gIdx = 0 -- 593
		do -- 593
			gIdx = 0 -- 594
			while gIdx < #GRASS_CENTERS * 2 do -- 594
				local ____self_grasses_6 = self.grasses -- 594
				____self_grasses_6[#____self_grasses_6 + 1] = mountModel(self.container, PATH_GRASS) -- 595
				gIdx = gIdx + 1 -- 594
			end -- 594
		end -- 594
	end -- 594
	local gi = 0 -- 598
	do -- 598
		gi = 0 -- 599
		while gi < #GRASS_CENTERS do -- 599
			local gx = ox + GRASS_CENTERS[gi + 1] / 100 -- 600
			local sway = math.sin(self.time * 1.8 + gi * 1.4) * 2.5 -- 601
			local fgGrass = self.grasses[gi * 2 + 1] -- 602
			fgGrass.visible = true -- 603
			fgGrass.position = Vec3(gx, 0, 0.36) -- 604
			fgGrass.angles = Vec3(0, 0, sway) -- 605
			fgGrass.scale = Vec3(1.12, 1, 1) -- 606
			local bgGrass = self.grasses[gi * 2 + 1 + 1] -- 608
			bgGrass.visible = true -- 609
			bgGrass.position = Vec3(gx + 0.08, 0, -0.48) -- 610
			bgGrass.angles = Vec3(0, 180, -sway * 0.7) -- 611
			bgGrass.scale = Vec3(1.18, 1.15, 1) -- 612
			gi = gi + 1 -- 599
		end -- 599
	end -- 599
	if #self.twigs == 0 then -- 599
		local ti = 0 -- 617
		do -- 617
			ti = 0 -- 618
			while ti < #TWIG_OFFSETS do -- 618
				local ____self_twigs_7 = self.twigs -- 618
				____self_twigs_7[#____self_twigs_7 + 1] = mountModel(self.container, PATH_TWIG) -- 619
				ti = ti + 1 -- 618
			end -- 618
		end -- 618
	end -- 618
	local curTwig = -1 -- 622
	local ti = 0 -- 623
	do -- 623
		ti = 0 -- 624
		while ti < #TWIG_OFFSETS do -- 624
			local tx = p.ox + TWIG_OFFSETS[ti + 1] -- 625
			local m = self.twigs[ti + 1] -- 626
			m.visible = true -- 627
			m.position = Vec3(tx / 100, 0.005, 0.06) -- 628
			m.angles = Vec3(0, ti * 35, 0) -- 629
			if not p.player.crouch and p.player.y <= 8 and math.abs(p.player.x - tx) <= 18 and (math.abs(p.player.vx) > 10 or math.abs(p.player.depthSpeed) > 10) then -- 629
				curTwig = ti -- 632
			end -- 632
			ti = ti + 1 -- 624
		end -- 624
	end -- 624
	if curTwig >= 0 and curTwig ~= self.lastSnappedTwig then -- 624
		local tx = p.ox + TWIG_OFFSETS[curTwig + 1] -- 636
		local k = 0 -- 637
		do -- 637
			k = 0 -- 638
			while k < 6 do -- 638
				local f = k / 6 - 0.5 -- 639
				local ____self_shards_8 = self.shards -- 639
				____self_shards_8[#____self_shards_8 + 1] = { -- 640
					x = tx + f * 12, -- 641
					y = 4, -- 642
					vx = f * 92, -- 643
					vy = 68 + k % 3 * 24, -- 644
					life = 0, -- 645
					maxLife = 0.42, -- 646
					color = Color(162, 134, 98, 220) -- 647
				} -- 647
				k = k + 1 -- 638
			end -- 638
		end -- 638
	end -- 638
	self.lastSnappedTwig = curTwig -- 651
	if self.creekLantern == nil then -- 651
		self.creekLantern = mountModel(self.container, PATH_LANTERN) -- 655
	end -- 655
	self.creekLantern.visible = true -- 657
	self.creekLantern.position = Vec3(ox + 12.24, 0.48, -0.74) -- 658
	self.creekLantern.angles = Vec3( -- 659
		0, -- 659
		0, -- 659
		math.sin(self.time * 1.6) * 2.8 -- 659
	) -- 659
	local lampX = p.ox + 1224 -- 661
	local ri = 0 -- 662
	do -- 662
		ri = 0 -- 663
		while ri < 4 do -- 663
			local phase = self.time * 2.1 + ri * 1.3 -- 664
			local sx = math.sin(phase) * (4 + ri * 2.5) -- 665
			local w = 22 - ri * 3.5 -- 666
			local a = math.floor(135 - ri * 26 + 0.5) -- 667
			groundFx:drawEllipse( -- 668
				Vec2(lampX + sx, -26 + ri * 14), -- 668
				w, -- 668
				2.2, -- 668
				Color(246, 214, 146, a) -- 668
			) -- 668
			ri = ri + 1 -- 663
		end -- 663
	end -- 663
	glow:drawEllipse( -- 670
		Vec2( -- 670
			lampX + math.sin(self.time * 1.7) * 3, -- 670
			2 -- 670
		), -- 670
		20, -- 670
		2.6, -- 670
		Color(242, 214, 148, 128) -- 670
	) -- 670
	if self.boughL == nil then -- 670
		self.boughL = mountModel(self.container, PATH_BOUGH) -- 674
		self.boughR = mountModel(self.container, PATH_BOUGH) -- 675
	end -- 675
	local targetReveal = smoothstep(p.ox + 1310, p.ox + 1435, p.player.x) -- 677
	self.creekReveal = self.creekReveal + (targetReveal - self.creekReveal) * math.min(1, dt * 4.5 + (dt == 0 and 0 or 0)) -- 678
	local swayB = math.sin(self.time * 1.4) * 2.2 -- 679
	self.boughL.visible = true -- 680
	self.boughL.position = Vec3(ox + 13.15 - self.creekReveal * 1.15, 1.56 + self.creekReveal * 0.36, 1.15) -- 681
	self.boughL.angles = Vec3(0, 8, -8 + self.creekReveal * 16 + swayB) -- 682
	if self.boughR ~= nil then -- 682
		self.boughR.visible = true -- 685
		self.boughR.position = Vec3(ox + 14.35 + self.creekReveal * 1.15, 1.48 + self.creekReveal * 0.4, 1.08) -- 686
		self.boughR.angles = Vec3(0, 172, 10 - self.creekReveal * 18 - swayB) -- 687
	end -- 687
end -- 532
function Xiaoman3DEntities.prototype.updateTower(self, p, dt) -- 693
	local ox = p.ox / 100 -- 694
	local ____opt_11 = p.room.story -- 694
	local ____opt_9 = ____opt_11 and ____opt_11.tower -- 694
	local doorX = (____opt_9 and ____opt_9.doorX or p.ox + 445) / 100 -- 695
	self.moonLight.color = Color3(126, 158, 208) -- 698
	self.moonLight.intensity = 1.32 -- 699
	self.moonLight.angles = Vec3(-42, -34, 0) -- 700
	self.fillLight.color = Color3(62, 80, 108) -- 701
	self.fillLight.intensity = 0.48 -- 702
	local targetOpen = p.towerDoorOpen and 1 or 0 -- 704
	self.doorOpenFrac = self.doorOpenFrac + (targetOpen - self.doorOpenFrac) * math.min(1, dt * 4.8) -- 705
	if math.abs(targetOpen - self.doorOpenFrac) < 0.005 then -- 705
		self.doorOpenFrac = targetOpen -- 707
	end -- 707
	local lampPulse = 0.94 + math.sin(self.time * 2.8) * 0.06 -- 710
	self.roomLightA.color = Color3(255, 196, 106) -- 712
	self.roomLightA.intensity = (1.55 + self.doorOpenFrac * 2.15) * lampPulse -- 713
	self.roomLightA.range = 5.4 -- 714
	self.roomLightA.position = Vec3(ox + 6.26, 0.72, -0.05) -- 715
	self.roomLightB.color = Color3(255, 204, 122) -- 718
	self.roomLightB.intensity = (1.35 + self.doorOpenFrac * 0.65) * lampPulse -- 719
	self.roomLightB.range = 3 -- 720
	self.roomLightB.position = Vec3(doorX, 1.05, 0.55) -- 721
	if self.door == nil then -- 721
		self.door = mountModel(self.container, PATH_DOOR) -- 725
	end -- 725
	self.door.visible = true -- 727
	self.door.position = Vec3(doorX - 0.1, 0, 0.12) -- 728
	self.door.scale = Vec3(0.9, 1, 1) -- 729
	local knockJitter = p.phase == "tower-knock" and math.sin(self.time * 36) * 2.2 or 0 -- 730
	self.door.angles = Vec3(0, -self.doorOpenFrac * 96 + knockJitter, 0) -- 731
	if self.towerLantern == nil then -- 731
		self.towerLantern = mountModel(self.container, PATH_LANTERN) -- 735
	end -- 735
	self.towerLantern.visible = true -- 737
	self.towerLantern.position = Vec3(ox + 6.38, 0.32, -0.18) -- 738
	if self.ledger == nil then -- 738
		self.ledger = mountModel(self.container, PATH_LEDGER) -- 741
	end -- 741
	self.ledger.visible = true -- 743
	self.ledger.position = Vec3(ox + 6.06, 0.32, -0.04) -- 744
	self.ledger.angles = Vec3(0, -10, 0) -- 745
	if self.pouch == nil then -- 745
		self.pouch = mountModel(self.container, PATH_POUCH) -- 748
	end -- 748
	self.pouch.visible = p.deskHold >= 12 or p.towerHanded -- 750
	self.pouch.position = Vec3(ox + 5.78, 0.32, 0.08) -- 751
	self.pouch.angles = Vec3(0, 14, 0) -- 752
	if self.guard == nil then -- 752
		self.guard = self:registerAnimated(mountModel(self.container, PATH_GUARD)) -- 755
	end -- 755
	self.guard.visible = self.doorOpenFrac > 0.08 or p.towerDoorOpen -- 757
	self.guard.position = Vec3(ox + 6.5, 0, -0.16) -- 758
	self.guard.angles = Vec3(0, -72, 0) -- 759
	local writing = p.deskHold >= 24 or p.towerHanded -- 761
	local nextGuardAnim = writing and "write" or "lantern" -- 762
	if self.guardAnim ~= nextGuardAnim then -- 762
		self.guardAnim = nextGuardAnim -- 764
		self.guard:play(nextGuardAnim, true) -- 765
	end -- 765
end -- 693
function Xiaoman3DEntities.prototype.stepAndDrawFx(self, dt, glow, overlay, cam) -- 771
	local aliveRings = {} -- 772
	local i = 0 -- 773
	do -- 773
		i = 0 -- 774
		while i < #self.rings do -- 774
			local r = self.rings[i + 1] -- 775
			r.age = r.age + dt -- 776
			if r.age < r.duration then -- 776
				aliveRings[#aliveRings + 1] = r -- 778
				if r.age >= 0 then -- 778
					local prog = clamp01(r.age / r.duration) -- 780
					local rad = 8 + prog * r.maxRadius -- 781
					local alpha = math.floor((1 - prog) * (r.kind == "iron" and 210 or (r.kind == "brick" and 170 or 95)) + 0.5) -- 782
					local col = r.kind == "iron" and Color(216, 232, 248, alpha) or (r.kind == "brick" and Color(224, 198, 152, alpha) or Color(138, 122, 100, alpha)) -- 783
					drawGroundRing( -- 786
						overlay, -- 786
						cam, -- 786
						r, -- 786
						rad, -- 786
						col, -- 786
						28 -- 786
					) -- 786
				end -- 786
			end -- 786
			i = i + 1 -- 774
		end -- 774
	end -- 774
	self.rings = aliveRings -- 790
	local aliveShards = {} -- 792
	do -- 792
		i = 0 -- 793
		while i < #self.shards do -- 793
			local s = self.shards[i + 1] -- 794
			s.life = s.life + dt -- 795
			if s.life < s.maxLife then -- 795
				s.x = s.x + s.vx * dt -- 797
				s.y = math.max(0, s.y + s.vy * dt) -- 798
				s.vy = s.vy - 480 * dt -- 799
				aliveShards[#aliveShards + 1] = s -- 800
				local sz = 2.2 * (1 - s.life / s.maxLife) -- 801
				if s.depth == nil then -- 801
					glow:drawDot( -- 803
						Vec2(s.x, s.y), -- 803
						math.max(0.8, sz), -- 803
						s.color -- 803
					) -- 803
				else -- 803
					local pt = cam:worldToScreen(s.x, s.y, s.depth) -- 805
					local edge = cam:worldToScreen( -- 806
						s.x + math.max(0.8, sz), -- 806
						s.y, -- 806
						s.depth -- 806
					) -- 806
					overlay:drawDot( -- 807
						Vec2(pt.x, pt.y), -- 807
						edge.x - pt.x, -- 807
						s.color -- 807
					) -- 807
				end -- 807
			end -- 807
			i = i + 1 -- 793
		end -- 793
	end -- 793
	self.shards = aliveShards -- 811
end -- 771
function Xiaoman3DEntities.prototype.getDebugState(self) -- 814
	return { -- 815
		room = self.lastRoom, -- 816
		doorOpenFrac = self.doorOpenFrac, -- 817
		basinShakeTimer = self.basinShakeTimer, -- 818
		creekReveal = self.creekReveal, -- 819
		scavAnim = self.scavAnim, -- 820
		dogAnim = self.dogAnim, -- 821
		guardAnim = self.guardAnim, -- 822
		cartAnim = self.cartAnim, -- 823
		activeRings = #self.rings -- 824
	} -- 824
end -- 814
return ____exports -- 814