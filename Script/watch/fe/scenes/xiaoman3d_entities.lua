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
local PATH_SKY = "assets/xiaoman3d/sky_backdrop.glb" -- 18
local PATH_SCAV = "assets/xiaoman3d/scavenger.glb" -- 19
local PATH_DOG = "assets/xiaoman3d/dog.glb" -- 20
local PATH_GUARD = "assets/xiaoman3d/guard.glb" -- 21
local PATH_CART = "assets/xiaoman3d/cart.glb" -- 22
local PATH_BOTTLE = "assets/xiaoman3d/bottle.glb" -- 23
local PATH_BASIN = "assets/xiaoman3d/basin.glb" -- 24
local PATH_DOOR = "assets/xiaoman3d/door.glb" -- 25
local PATH_LANTERN = "assets/xiaoman3d/lantern.glb" -- 26
local PATH_LEDGER = "assets/xiaoman3d/ledger.glb" -- 27
local PATH_POUCH = "assets/xiaoman3d/pouch.glb" -- 28
local PATH_LATCH = "assets/xiaoman3d/latch.glb" -- 29
local PATH_GRASS = "assets/xiaoman3d/grass.glb" -- 30
local PATH_TWIG = "assets/xiaoman3d/twig.glb" -- 31
local PATH_BOUGH = "assets/xiaoman3d/bough.glb" -- 32
local TWIG_OFFSETS = {235, 455, 865, 1115} -- 34
local GRASS_CENTERS = {340, 745, 1195} -- 35
local function mountModel(parent, path) -- 68
	local m = Model3D(path) -- 69
	if m.parent ~= nil then -- 69
		m:removeFromParent(false) -- 71
	end -- 71
	parent:addChild(m) -- 73
	m.visible = false -- 74
	return m -- 75
end -- 68
local function clamp01(v) -- 78
	if v <= 0 then -- 78
		return 0 -- 79
	end -- 79
	if v >= 1 then -- 79
		return 1 -- 80
	end -- 80
	return v -- 81
end -- 78
local function smoothstep(e0, e1, x) -- 84
	local t = clamp01((x - e0) / math.max(0.0001, e1 - e0)) -- 85
	return t * t * (3 - 2 * t) -- 86
end -- 84
local function drawGroundRing(draw, cx, cy, radius, col, segs) -- 89
	if segs == nil then -- 89
		segs = 28 -- 89
	end -- 89
	local pts = {} -- 90
	local i = 0 -- 91
	do -- 91
		i = 0 -- 92
		while i < segs do -- 92
			local a = i / segs * math.pi * 2 -- 93
			pts[#pts + 1] = Vec2( -- 94
				cx + math.cos(a) * radius, -- 94
				cy + math.sin(a) * radius -- 94
			) -- 94
			i = i + 1 -- 92
		end -- 92
	end -- 92
	draw:drawPolygon( -- 96
		pts, -- 96
		Color(0, 0, 0, 0), -- 96
		1.4, -- 96
		col -- 96
	) -- 96
end -- 89
____exports.Xiaoman3DEntities = __TS__Class() -- 99
local Xiaoman3DEntities = ____exports.Xiaoman3DEntities -- 99
Xiaoman3DEntities.name = "Xiaoman3DEntities" -- 99
function Xiaoman3DEntities.prototype.____constructor(self, root) -- 159
	self.container = Node3D() -- 100
	self.moonLight = DirectionalLight3D() -- 103
	self.fillLight = DirectionalLight3D() -- 104
	self.roomLightA = PointLight3D() -- 105
	self.roomLightB = PointLight3D() -- 106
	self.cartAnim = "" -- 116
	self.prevCartAxle = 0 -- 117
	self.scavAnim = "" -- 124
	self.scavYaw = -80 -- 125
	self.prevScavX = 0 -- 126
	self.basinShakeTimer = 0 -- 127
	self.prevBottleLandT = 0 -- 128
	self.dogAnim = "" -- 132
	self.dogYaw = -84 -- 133
	self.prevDogX = 0 -- 134
	self.grasses = {} -- 136
	self.twigs = {} -- 137
	self.creekReveal = 0 -- 140
	self.lastSnappedTwig = -1 -- 141
	self.guardAnim = "" -- 149
	self.doorOpenFrac = 0 -- 150
	self.lastRoom = "" -- 153
	self.time = 0 -- 154
	self.rings = {} -- 155
	self.shards = {} -- 156
	self.animatedModels = {} -- 157
	root:addChild(self.container) -- 160
	self.moonLight.color = Color3(135, 168, 214) -- 163
	self.moonLight.intensity = 1.35 -- 164
	self.moonLight.angles = Vec3(-44, -28, 0) -- 165
	self.moonLight.castShadow = true -- 166
	self.moonLight.shadowBias = 0.0018 -- 167
	self.moonLight.shadowNormalBias = 0.028 -- 168
	self.moonLight.shadowSoftness = 1.6 -- 169
	self.container:addChild(self.moonLight) -- 170
	self.fillLight.color = Color3(62, 82, 112) -- 173
	self.fillLight.intensity = 0.42 -- 174
	self.fillLight.angles = Vec3(28, 146, 0) -- 175
	self.fillLight.castShadow = false -- 176
	self.container:addChild(self.fillLight) -- 177
	self.roomLightA.color = Color3(255, 198, 112) -- 180
	self.roomLightA.intensity = 0 -- 181
	self.roomLightA.range = 4 -- 182
	self.container:addChild(self.roomLightA) -- 183
	self.roomLightB.color = Color3(156, 186, 224) -- 185
	self.roomLightB.intensity = 0 -- 186
	self.roomLightB.range = 3 -- 187
	self.container:addChild(self.roomLightB) -- 188
end -- 159
function Xiaoman3DEntities.prototype.registerAnimated(self, m) -- 191
	local ____self_animatedModels_0 = self.animatedModels -- 191
	____self_animatedModels_0[#____self_animatedModels_0 + 1] = m -- 192
	return m -- 193
end -- 191
function Xiaoman3DEntities.prototype.hideAllEntities(self) -- 196
	if self.cart ~= nil then -- 196
		self.cart.visible = false -- 197
	end -- 197
	if self.blockingCart ~= nil then -- 197
		self.blockingCart.visible = false -- 198
	end -- 198
	if self.latch ~= nil then -- 198
		self.latch.visible = false -- 199
	end -- 199
	if self.outsideLantern ~= nil then -- 199
		self.outsideLantern.visible = false -- 200
	end -- 200
	if self.scav ~= nil then -- 200
		self.scav.visible = false -- 202
	end -- 202
	if self.shelfBottle ~= nil then -- 202
		self.shelfBottle.visible = false -- 203
	end -- 203
	if self.airBottle ~= nil then -- 203
		self.airBottle.visible = false -- 204
	end -- 204
	if self.basin ~= nil then -- 204
		self.basin.visible = false -- 205
	end -- 205
	if self.dog ~= nil then -- 205
		self.dog.visible = false -- 207
	end -- 207
	if self.creekLantern ~= nil then -- 207
		self.creekLantern.visible = false -- 208
	end -- 208
	local i = 0 -- 209
	do -- 209
		i = 0 -- 210
		while i < #self.grasses do -- 210
			self.grasses[i + 1].visible = false -- 210
			i = i + 1 -- 210
		end -- 210
	end -- 210
	do -- 210
		i = 0 -- 211
		while i < #self.twigs do -- 211
			self.twigs[i + 1].visible = false -- 211
			i = i + 1 -- 211
		end -- 211
	end -- 211
	if self.boughL ~= nil then -- 211
		self.boughL.visible = false -- 212
	end -- 212
	if self.boughR ~= nil then -- 212
		self.boughR.visible = false -- 213
	end -- 213
	if self.door ~= nil then -- 213
		self.door.visible = false -- 215
	end -- 215
	if self.guard ~= nil then -- 215
		self.guard.visible = false -- 216
	end -- 216
	if self.towerLantern ~= nil then -- 216
		self.towerLantern.visible = false -- 217
	end -- 217
	if self.ledger ~= nil then -- 217
		self.ledger.visible = false -- 218
	end -- 218
	if self.pouch ~= nil then -- 218
		self.pouch.visible = false -- 219
	end -- 219
end -- 196
function Xiaoman3DEntities.prototype.hide(self) -- 222
	self:setPaused(true) -- 223
end -- 222
function Xiaoman3DEntities.prototype.setPaused(self, paused) -- 226
	local i = 0 -- 227
	do -- 227
		i = 0 -- 228
		while i < #self.animatedModels do -- 228
			local m = self.animatedModels[i + 1] -- 229
			if paused then -- 229
				if not m.paused then -- 229
					m:pause() -- 231
				end -- 231
			elseif m.paused then -- 231
				m:resume() -- 233
			end -- 233
			i = i + 1 -- 228
		end -- 228
	end -- 228
end -- 226
function Xiaoman3DEntities.prototype.update(self, p, dt, camX, glow, groundFx) -- 238
	local paused = p.paused or dt <= 0 -- 239
	local safeDt = paused and 0 or math.min(0.05, dt) -- 240
	self:setPaused(paused) -- 241
	if not paused then -- 241
		self.time = self.time + safeDt -- 243
	end -- 243
	if self.lastRoom ~= p.room.key then -- 243
		self.lastRoom = p.room.key -- 247
		self:hideAllEntities() -- 248
		self.rings = {} -- 249
		self.shards = {} -- 250
		self.basinShakeTimer = 0 -- 251
		self.prevBottleLandT = 0 -- 252
		self.prevCartAxle = p.cartAxle -- 253
		self.prevScavX = p.scavX -- 254
		self.prevDogX = p.dogX -- 255
		self.doorOpenFrac = p.towerDoorOpen and 1 or 0 -- 256
		self.creekReveal = 0 -- 257
		self.lastSnappedTwig = -1 -- 258
	end -- 258
	if self.sky == nil then -- 258
		self.sky = mountModel(self.container, PATH_SKY) -- 263
	end -- 263
	self.sky.visible = true -- 265
	self.sky.position = Vec3(camX / 100, -0.3, -4.5) -- 266
	self.sky.scale = Vec3(1.15, 1, 1) -- 267
	if p.room.key == "outside" then -- 267
		self:updateOutside(p, safeDt) -- 271
	elseif p.room.key == "village" then -- 271
		self:updateVillage(p, safeDt, groundFx) -- 273
	elseif p.room.key == "forest" then -- 273
		self:updateForest(p, safeDt, glow, groundFx) -- 275
	elseif p.room.key == "tower" then -- 275
		self:updateTower(p, safeDt) -- 277
	end -- 277
	self:stepAndDrawFx(safeDt, glow, groundFx) -- 281
end -- 238
function Xiaoman3DEntities.prototype.updateOutside(self, p, dt) -- 286
	local ox = p.ox / 100 -- 287
	self.moonLight.color = Color3(144, 178, 224) -- 290
	self.moonLight.intensity = 1.68 -- 291
	self.moonLight.angles = Vec3(-44, -26, 0) -- 292
	self.fillLight.color = Color3(68, 92, 126) -- 293
	self.fillLight.intensity = 0.54 -- 294
	local pulse = 0.92 + math.sin(self.time * 2.4) * 0.08 -- 297
	self.roomLightA.color = Color3(255, 196, 108) -- 298
	self.roomLightA.intensity = 2.6 * pulse -- 299
	self.roomLightA.range = 5.2 -- 300
	self.roomLightA.position = Vec3(ox + 11.2, 1.55, -0.75) -- 301
	self.roomLightB.color = Color3(166, 192, 224) -- 304
	self.roomLightB.intensity = 1.05 -- 305
	self.roomLightB.range = 3.2 -- 306
	self.roomLightB.position = Vec3(p.cartAxle / 100, 1.65, 0.85) -- 307
	local c = p.room.cart -- 310
	if c.bodyW > 0 then -- 310
		if self.cart == nil then -- 310
			self.cart = self:registerAnimated(mountModel(self.container, PATH_CART)) -- 313
		end -- 313
		self.cart.visible = true -- 315
		self.cart.position = Vec3(p.cartAxle / 100, c.baseY / 100, -(c.depth or 0) / 100) -- 316
		self.cart.angles = Vec3(0, 0, 0) -- 317
		local rolling = math.abs(p.cartAxle - self.prevCartAxle) > 0.04 -- 319
		self.prevCartAxle = p.cartAxle -- 320
		local nextAnim = rolling and "roll" or "idle" -- 321
		if self.cartAnim ~= nextAnim then -- 321
			self.cartAnim = nextAnim -- 323
			self.cart:play(nextAnim, true) -- 324
		end -- 324
		self.cart.speed = rolling and 1.15 or 0.75 -- 326
	end -- 326
	local blockingBox -- 330
	if not p.cartDocked then -- 330
		local i = 0 -- 332
		do -- 332
			i = 0 -- 333
			while i < #p.boxes do -- 333
				local b = p.boxes[i + 1] -- 334
				if b.id == "outside_red_cart" and not b.broken and b.x0 < 250 then -- 334
					blockingBox = b -- 336
					break -- 337
				end -- 337
				i = i + 1 -- 333
			end -- 333
		end -- 333
	end -- 333
	if blockingBox ~= nil then -- 333
		if self.blockingCart == nil then -- 333
			self.blockingCart = self:registerAnimated(mountModel(self.container, PATH_CART)) -- 343
			self.blockingCart:play("idle", true) -- 344
		end -- 344
		self.blockingCart.visible = true -- 346
		self.blockingCart.position = Vec3((blockingBox.x0 + blockingBox.x1) * 0.005, blockingBox.y0 / 100, 0.02) -- 347
		self.blockingCart.angles = Vec3(0, 14, 0) -- 348
		self.blockingCart.scale = Vec3(0.84, 0.9, 0.9) -- 349
	elseif self.blockingCart ~= nil then -- 349
		self.blockingCart.visible = false -- 351
	end -- 351
	local latchBounds = p:cartLatchBounds() -- 355
	if latchBounds ~= nil then -- 355
		if self.latch == nil then -- 355
			self.latch = mountModel(self.container, PATH_LATCH) -- 358
		end -- 358
		self.latch.visible = true -- 360
		self.latch.position = Vec3((latchBounds.x + latchBounds.width * 0.5) / 100, latchBounds.y / 100, -0.52) -- 361
		self.latch.scale = Vec3( -- 362
			math.max(0.7, latchBounds.width / 48), -- 362
			1, -- 362
			1 -- 362
		) -- 362
	elseif self.latch ~= nil then -- 362
		self.latch.visible = false -- 364
	end -- 364
	if self.outsideLantern == nil then -- 364
		self.outsideLantern = mountModel(self.container, PATH_LANTERN) -- 369
	end -- 369
	self.outsideLantern.visible = true -- 371
	self.outsideLantern.position = Vec3(ox + 11.2, 1.48, -0.95) -- 372
	self.outsideLantern.angles = Vec3( -- 373
		0, -- 373
		0, -- 373
		math.sin(self.time * 1.9) * 3.5 -- 373
	) -- 373
end -- 286
function Xiaoman3DEntities.prototype.updateVillage(self, p, dt, groundFx) -- 378
	local ox = p.ox / 100 -- 379
	self.moonLight.color = Color3(132, 166, 214) -- 382
	self.moonLight.intensity = 1.48 -- 383
	self.moonLight.angles = Vec3(-52, -32, 0) -- 384
	self.fillLight.color = Color3(62, 80, 110) -- 385
	self.fillLight.intensity = 0.5 -- 386
	self.roomLightA.color = Color3(162, 194, 232) -- 389
	self.roomLightA.intensity = 1.95 -- 390
	self.roomLightA.range = 4 -- 391
	self.roomLightA.position = Vec3(ox + 5.75, 1.38, 0.45) -- 392
	self.roomLightB.color = Color3(212, 178, 134) -- 395
	self.roomLightB.intensity = 1.05 -- 396
	self.roomLightB.range = 2.5 -- 397
	self.roomLightB.position = Vec3(ox + 1.12, 0.85, 0.36) -- 398
	if self.shelfBottle == nil then -- 398
		self.shelfBottle = mountModel(self.container, PATH_BOTTLE) -- 402
	end -- 402
	local showShelfBottle = not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 and p.room.bottle ~= nil -- 404
	self.shelfBottle.visible = showShelfBottle -- 405
	if showShelfBottle and p.room.bottle ~= nil then -- 405
		local bx = math.min(p.room.bottle.x, p.ox + 108) / 100 -- 407
		self.shelfBottle.position = Vec3(bx, 0.46, 0.06) -- 408
	end -- 408
	if self.airBottle == nil then -- 408
		self.airBottle = mountModel(self.container, PATH_BOTTLE) -- 413
	end -- 413
	if p.bottleFly ~= nil then -- 413
		self.airBottle.visible = true -- 416
		local prog = clamp01(p.bottleFly.t / 0.62) -- 417
		local z = -p.player.depth / 100 * (1 - prog) -- 418
		self.airBottle.position = Vec3(p.bottleFly.x / 100, p.bottleFly.y / 100, z) -- 419
		self.airBottle.angles = Vec3(self.time * 240, 0, -self.time * 540) -- 420
	else -- 420
		self.airBottle.visible = false -- 422
	end -- 422
	if p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 then -- 422
		local lx = p.bottleLandX -- 427
		local isSoft = p.room.softX ~= nil and math.abs(lx - p.room.softX) <= 34 -- 428
		local isIron = p.room.basinX ~= nil and math.abs(lx - p.room.basinX) <= 24 -- 429
		local kind = isSoft and "soft" or (isIron and "iron" or "brick") -- 430
		self:spawnBottleImpactFx(lx, p.bottleLandY, kind) -- 431
		if kind == "iron" then -- 431
			self.basinShakeTimer = 1.15 -- 433
		end -- 433
	end -- 433
	self.prevBottleLandT = p.bottleLandT -- 436
	if self.basin == nil then -- 436
		self.basin = mountModel(self.container, PATH_BASIN) -- 440
	end -- 440
	local basinX = (p.room.basinX ~= nil and p.room.basinX or p.ox + 548) / 100 -- 442
	self.basin.visible = true -- 443
	self.basin.position = Vec3(basinX, 0.095, -0.18) -- 444
	if self.basinShakeTimer > 0 then -- 444
		self.basinShakeTimer = math.max(0, self.basinShakeTimer - dt) -- 446
		local amp = self.basinShakeTimer / 1.15 -- 447
		local wobble = amp * amp -- 448
		self.basin.angles = Vec3( -- 449
			math.sin(self.time * 48) * 14 * wobble, -- 450
			math.sin(self.time * 24) * 6 * wobble, -- 451
			math.cos(self.time * 42) * 16 * wobble -- 452
		) -- 452
	else -- 452
		self.basin.angles = Vec3(0, 0, 0) -- 455
	end -- 455
	if p.room.scavenger ~= nil then -- 455
		if self.scav == nil then -- 455
			self.scav = self:registerAnimated(mountModel(self.container, PATH_SCAV)) -- 461
		end -- 461
		self.scav.visible = true -- 463
		self.scav.position = Vec3(p.scavX / 100, p.room.scavenger.y / 100, 0.02) -- 464
		local dx = p.scavX - self.prevScavX -- 466
		self.prevScavX = p.scavX -- 467
		local desiredDir = p.scavDir -- 469
		if p.scavState == "turn" or p.scavState == "walk" then -- 469
			desiredDir = p.scavTargetX >= p.scavX and 1 or -1 -- 471
		elseif p.scavState == "chase" then -- 471
			desiredDir = p.player.x >= p.scavX and 1 or -1 -- 473
		elseif math.abs(dx) > 0.02 then -- 473
			desiredDir = dx > 0 and 1 or -1 -- 475
		end -- 475
		local targetYaw = desiredDir >= 0 and 80 or -80 -- 477
		self.scavYaw = self.scavYaw + (targetYaw - self.scavYaw) * math.min(1, dt * 10) -- 478
		self.scav.angles = Vec3(0, self.scavYaw, 0) -- 479
		local nextAnim = "idle" -- 481
		if p.scavState == "chase" then -- 481
			nextAnim = "chase" -- 483
		elseif p.scavState == "turn" then -- 483
			nextAnim = "turn" -- 485
		elseif p.scavState == "walk" or p.scavState == "back" or p.scavState == "patrol" and math.abs(dx) > 0.01 then -- 485
			nextAnim = "walk" -- 487
		else -- 487
			nextAnim = "idle" -- 489
		end -- 489
		if self.scavAnim ~= nextAnim then -- 489
			self.scavAnim = nextAnim -- 492
			self.scav:play(nextAnim, true) -- 493
		end -- 493
		local lookDir = self.scavYaw >= 0 and 1 or -1 -- 497
		local alert = p.scavState == "chase" or p.scavState == "turn" -- 498
		local coneCol = alert and Color(188, 72, 54, 48) or Color(128, 152, 184, 28) -- 499
		local edgeCol = alert and Color(214, 96, 68, 86) or Color(156, 182, 212, 52) -- 500
		local sx = p.scavX -- 501
		local coneLen = alert and 115 or 88 -- 502
		groundFx:drawPolygon( -- 503
			{ -- 503
				Vec2(sx, 0), -- 504
				Vec2(sx + lookDir * coneLen, -34), -- 505
				Vec2(sx + lookDir * coneLen, 34) -- 506
			}, -- 506
			coneCol, -- 507
			0.8, -- 507
			edgeCol -- 507
		) -- 507
	end -- 507
	if p.passed then -- 507
		local pulse = 0.65 + 0.35 * math.sin(self.time * 2.2) -- 512
		groundFx:drawPolygon( -- 513
			{ -- 513
				Vec2(p.ox + 566, -34), -- 514
				Vec2(p.ox + 634, -34), -- 515
				Vec2(p.ox + 634, -18), -- 516
				Vec2(p.ox + 566, -18) -- 517
			}, -- 517
			Color( -- 518
				92, -- 518
				134, -- 518
				154, -- 518
				math.floor(42 * pulse + 0.5) -- 518
			), -- 518
			1, -- 518
			Color( -- 518
				164, -- 518
				206, -- 518
				224, -- 518
				math.floor(96 * pulse + 0.5) -- 518
			) -- 518
		) -- 518
	end -- 518
end -- 378
function Xiaoman3DEntities.prototype.spawnBottleImpactFx(self, x, y, kind) -- 522
	if kind == "iron" then -- 522
		local ____self_rings_1 = self.rings -- 522
		____self_rings_1[#____self_rings_1 + 1] = { -- 524
			x = x, -- 524
			z = 0, -- 524
			age = 0, -- 524
			duration = 1.05, -- 524
			maxRadius = 96, -- 524
			kind = kind -- 524
		} -- 524
		local ____self_rings_2 = self.rings -- 524
		____self_rings_2[#____self_rings_2 + 1] = { -- 525
			x = x, -- 525
			z = 0, -- 525
			age = -0.22, -- 525
			duration = 1.15, -- 525
			maxRadius = 122, -- 525
			kind = kind -- 525
		} -- 525
	elseif kind == "brick" then -- 525
		local ____self_rings_3 = self.rings -- 525
		____self_rings_3[#____self_rings_3 + 1] = { -- 527
			x = x, -- 527
			z = 0, -- 527
			age = 0, -- 527
			duration = 0.62, -- 527
			maxRadius = 68, -- 527
			kind = kind -- 527
		} -- 527
	else -- 527
		local ____self_rings_4 = self.rings -- 527
		____self_rings_4[#____self_rings_4 + 1] = { -- 529
			x = x, -- 529
			z = 0, -- 529
			age = 0, -- 529
			duration = 0.45, -- 529
			maxRadius = 26, -- 529
			kind = kind -- 529
		} -- 529
	end -- 529
	local count = kind == "soft" and 5 or 9 -- 532
	local col = kind == "iron" and Color(224, 232, 244, 220) or (kind == "brick" and Color(204, 154, 108, 220) or Color(118, 98, 76, 170)) -- 533
	local i = 0 -- 536
	do -- 536
		i = 0 -- 537
		while i < count do -- 537
			local frac = i / count - 0.5 -- 538
			local ____self_shards_5 = self.shards -- 538
			____self_shards_5[#____self_shards_5 + 1] = { -- 539
				x = x + frac * 10, -- 540
				y = y + 4, -- 541
				vx = frac * (kind == "soft" and 45 or 135), -- 542
				vy = (kind == "soft" and 48 or 115) + i % 3 * 28, -- 543
				life = 0, -- 544
				maxLife = kind == "soft" and 0.35 or 0.48, -- 545
				color = col -- 546
			} -- 546
			i = i + 1 -- 537
		end -- 537
	end -- 537
end -- 522
function Xiaoman3DEntities.prototype.updateForest(self, p, dt, glow, groundFx) -- 553
	local ox = p.ox / 100 -- 554
	self.moonLight.color = Color3(126, 168, 198) -- 557
	self.moonLight.intensity = 1.52 -- 558
	self.moonLight.angles = Vec3(-46, -24, 0) -- 559
	self.fillLight.color = Color3(56, 84, 98) -- 560
	self.fillLight.intensity = 0.52 -- 561
	local flick = 0.9 + math.sin(self.time * 3.6) * 0.06 + math.cos(self.time * 6.1) * 0.04 -- 564
	self.roomLightA.color = Color3(255, 198, 112) -- 565
	self.roomLightA.intensity = 2.9 * flick -- 566
	self.roomLightA.range = 5.4 -- 567
	self.roomLightA.position = Vec3(ox + 12.24, 0.72, -0.62) -- 568
	self.roomLightB.color = Color3(144, 184, 214) -- 571
	self.roomLightB.intensity = 1.15 -- 572
	self.roomLightB.range = 4.6 -- 573
	self.roomLightB.position = Vec3(ox + 7.45, 1.85, 0.65) -- 574
	if self.dog == nil then -- 574
		self.dog = self:registerAnimated(mountModel(self.container, PATH_DOG)) -- 578
	end -- 578
	self.dog.visible = true -- 580
	self.dog.position = Vec3(p.dogX / 100, 0, -0.06) -- 581
	local ddx = p.dogX - self.prevDogX -- 583
	self.prevDogX = p.dogX -- 584
	local dogDir = self.dogYaw >= 0 and 1 or -1 -- 585
	if p.dogState == "chase" or p.dogState == "ear" then -- 585
		dogDir = p.player.x >= p.dogX and 1 or -1 -- 587
	elseif math.abs(ddx) > 0.02 then -- 587
		dogDir = ddx > 0 and 1 or -1 -- 589
	end -- 589
	local targetDogYaw = dogDir >= 0 and 84 or -84 -- 591
	self.dogYaw = self.dogYaw + (targetDogYaw - self.dogYaw) * math.min(1, dt * 12) -- 592
	self.dog.angles = Vec3(0, self.dogYaw, 0) -- 593
	local nextDogAnim = "walk" -- 595
	if p.dogState == "ear" then -- 595
		nextDogAnim = "ear" -- 597
	elseif p.dogState == "chase" then -- 597
		nextDogAnim = "chase" -- 599
	elseif p.dogState == "sniff" then -- 599
		nextDogAnim = "sniff" -- 601
	elseif math.abs(ddx) > 0.01 then -- 601
		nextDogAnim = "walk" -- 603
	else -- 603
		nextDogAnim = "idle" -- 605
	end -- 605
	if self.dogAnim ~= nextDogAnim then -- 605
		self.dogAnim = nextDogAnim -- 608
		self.dog:play(nextDogAnim, true) -- 609
	end -- 609
	if #self.grasses == 0 then -- 609
		local gIdx = 0 -- 614
		do -- 614
			gIdx = 0 -- 615
			while gIdx < #GRASS_CENTERS * 2 do -- 615
				local ____self_grasses_6 = self.grasses -- 615
				____self_grasses_6[#____self_grasses_6 + 1] = mountModel(self.container, PATH_GRASS) -- 616
				gIdx = gIdx + 1 -- 615
			end -- 615
		end -- 615
	end -- 615
	local gi = 0 -- 619
	do -- 619
		gi = 0 -- 620
		while gi < #GRASS_CENTERS do -- 620
			local gx = ox + GRASS_CENTERS[gi + 1] / 100 -- 621
			local sway = math.sin(self.time * 1.8 + gi * 1.4) * 2.5 -- 622
			local fgGrass = self.grasses[gi * 2 + 1] -- 623
			fgGrass.visible = true -- 624
			fgGrass.position = Vec3(gx, 0, 0.36) -- 625
			fgGrass.angles = Vec3(0, 0, sway) -- 626
			fgGrass.scale = Vec3(1.12, 1, 1) -- 627
			local bgGrass = self.grasses[gi * 2 + 1 + 1] -- 629
			bgGrass.visible = true -- 630
			bgGrass.position = Vec3(gx + 0.08, 0, -0.48) -- 631
			bgGrass.angles = Vec3(0, 180, -sway * 0.7) -- 632
			bgGrass.scale = Vec3(1.18, 1.15, 1) -- 633
			gi = gi + 1 -- 620
		end -- 620
	end -- 620
	if #self.twigs == 0 then -- 620
		local ti = 0 -- 638
		do -- 638
			ti = 0 -- 639
			while ti < #TWIG_OFFSETS do -- 639
				local ____self_twigs_7 = self.twigs -- 639
				____self_twigs_7[#____self_twigs_7 + 1] = mountModel(self.container, PATH_TWIG) -- 640
				ti = ti + 1 -- 639
			end -- 639
		end -- 639
	end -- 639
	local curTwig = -1 -- 643
	local ti = 0 -- 644
	do -- 644
		ti = 0 -- 645
		while ti < #TWIG_OFFSETS do -- 645
			local tx = p.ox + TWIG_OFFSETS[ti + 1] -- 646
			local m = self.twigs[ti + 1] -- 647
			m.visible = true -- 648
			m.position = Vec3(tx / 100, 0.005, 0.06) -- 649
			m.angles = Vec3(0, ti * 35, 0) -- 650
			if not p.player.crouch and p.player.y <= 8 and math.abs(p.player.x - tx) <= 18 and (math.abs(p.player.vx) > 10 or math.abs(p.player.depthSpeed) > 10) then -- 650
				curTwig = ti -- 653
			end -- 653
			ti = ti + 1 -- 645
		end -- 645
	end -- 645
	if curTwig >= 0 and curTwig ~= self.lastSnappedTwig then -- 645
		local tx = p.ox + TWIG_OFFSETS[curTwig + 1] -- 657
		local k = 0 -- 658
		do -- 658
			k = 0 -- 659
			while k < 6 do -- 659
				local f = k / 6 - 0.5 -- 660
				local ____self_shards_8 = self.shards -- 660
				____self_shards_8[#____self_shards_8 + 1] = { -- 661
					x = tx + f * 12, -- 662
					y = 4, -- 663
					vx = f * 92, -- 664
					vy = 68 + k % 3 * 24, -- 665
					life = 0, -- 666
					maxLife = 0.42, -- 667
					color = Color(162, 134, 98, 220) -- 668
				} -- 668
				k = k + 1 -- 659
			end -- 659
		end -- 659
	end -- 659
	self.lastSnappedTwig = curTwig -- 672
	if self.creekLantern == nil then -- 672
		self.creekLantern = mountModel(self.container, PATH_LANTERN) -- 676
	end -- 676
	self.creekLantern.visible = true -- 678
	self.creekLantern.position = Vec3(ox + 12.24, 0.48, -0.74) -- 679
	self.creekLantern.angles = Vec3( -- 680
		0, -- 680
		0, -- 680
		math.sin(self.time * 1.6) * 2.8 -- 680
	) -- 680
	local lampX = p.ox + 1224 -- 682
	local ri = 0 -- 683
	do -- 683
		ri = 0 -- 684
		while ri < 4 do -- 684
			local phase = self.time * 2.1 + ri * 1.3 -- 685
			local sx = math.sin(phase) * (4 + ri * 2.5) -- 686
			local w = 22 - ri * 3.5 -- 687
			local a = math.floor(135 - ri * 26 + 0.5) -- 688
			groundFx:drawEllipse( -- 689
				Vec2(lampX + sx, -26 + ri * 14), -- 689
				w, -- 689
				2.2, -- 689
				Color(246, 214, 146, a) -- 689
			) -- 689
			ri = ri + 1 -- 684
		end -- 684
	end -- 684
	glow:drawEllipse( -- 691
		Vec2( -- 691
			lampX + math.sin(self.time * 1.7) * 3, -- 691
			2 -- 691
		), -- 691
		20, -- 691
		2.6, -- 691
		Color(242, 214, 148, 128) -- 691
	) -- 691
	if self.boughL == nil then -- 691
		self.boughL = mountModel(self.container, PATH_BOUGH) -- 695
		self.boughR = mountModel(self.container, PATH_BOUGH) -- 696
	end -- 696
	local targetReveal = smoothstep(p.ox + 1310, p.ox + 1435, p.player.x) -- 698
	self.creekReveal = self.creekReveal + (targetReveal - self.creekReveal) * math.min(1, dt * 4.5 + (dt == 0 and 0 or 0)) -- 699
	local swayB = math.sin(self.time * 1.4) * 2.2 -- 700
	self.boughL.visible = true -- 701
	self.boughL.position = Vec3(ox + 13.15 - self.creekReveal * 1.15, 1.56 + self.creekReveal * 0.36, 1.15) -- 702
	self.boughL.angles = Vec3(0, 8, -8 + self.creekReveal * 16 + swayB) -- 703
	if self.boughR ~= nil then -- 703
		self.boughR.visible = true -- 706
		self.boughR.position = Vec3(ox + 14.35 + self.creekReveal * 1.15, 1.48 + self.creekReveal * 0.4, 1.08) -- 707
		self.boughR.angles = Vec3(0, 172, 10 - self.creekReveal * 18 - swayB) -- 708
	end -- 708
end -- 553
function Xiaoman3DEntities.prototype.updateTower(self, p, dt) -- 714
	local ox = p.ox / 100 -- 715
	self.moonLight.color = Color3(126, 158, 208) -- 718
	self.moonLight.intensity = 1.32 -- 719
	self.moonLight.angles = Vec3(-42, -34, 0) -- 720
	self.fillLight.color = Color3(62, 80, 108) -- 721
	self.fillLight.intensity = 0.48 -- 722
	local targetOpen = p.towerDoorOpen and 1 or 0 -- 724
	self.doorOpenFrac = self.doorOpenFrac + (targetOpen - self.doorOpenFrac) * math.min(1, dt * 4.8) -- 725
	if math.abs(targetOpen - self.doorOpenFrac) < 0.005 then -- 725
		self.doorOpenFrac = targetOpen -- 727
	end -- 727
	local lampPulse = 0.94 + math.sin(self.time * 2.8) * 0.06 -- 730
	self.roomLightA.color = Color3(255, 196, 106) -- 732
	self.roomLightA.intensity = (1.55 + self.doorOpenFrac * 2.15) * lampPulse -- 733
	self.roomLightA.range = 5.4 -- 734
	self.roomLightA.position = Vec3(ox + 6.26, 0.72, -0.05) -- 735
	self.roomLightB.color = Color3(255, 204, 122) -- 738
	self.roomLightB.intensity = (0.45 + self.doorOpenFrac * 1.35) * lampPulse -- 739
	self.roomLightB.range = 3 -- 740
	self.roomLightB.position = Vec3(ox + 4.5, 0.72, 0.18) -- 741
	if self.door == nil then -- 741
		self.door = mountModel(self.container, PATH_DOOR) -- 745
	end -- 745
	self.door.visible = true -- 747
	self.door.position = Vec3(ox + 4.35, 0, -0.58) -- 748
	self.door.scale = Vec3(0.9, 1, 1) -- 749
	local knockJitter = p.phase == "tower-knock" and math.sin(self.time * 36) * 2.2 or 0 -- 750
	self.door.angles = Vec3(0, -self.doorOpenFrac * 96 + knockJitter, 0) -- 751
	if self.towerLantern == nil then -- 751
		self.towerLantern = mountModel(self.container, PATH_LANTERN) -- 755
	end -- 755
	self.towerLantern.visible = true -- 757
	self.towerLantern.position = Vec3(ox + 6.38, 0.32, -0.18) -- 758
	if self.ledger == nil then -- 758
		self.ledger = mountModel(self.container, PATH_LEDGER) -- 761
	end -- 761
	self.ledger.visible = true -- 763
	self.ledger.position = Vec3(ox + 6.06, 0.32, -0.04) -- 764
	self.ledger.angles = Vec3(0, -10, 0) -- 765
	if self.pouch == nil then -- 765
		self.pouch = mountModel(self.container, PATH_POUCH) -- 768
	end -- 768
	self.pouch.visible = p.deskHold >= 12 or p.towerHanded -- 770
	self.pouch.position = Vec3(ox + 5.78, 0.32, 0.08) -- 771
	self.pouch.angles = Vec3(0, 14, 0) -- 772
	if self.guard == nil then -- 772
		self.guard = self:registerAnimated(mountModel(self.container, PATH_GUARD)) -- 775
	end -- 775
	self.guard.visible = self.doorOpenFrac > 0.08 or p.towerDoorOpen -- 777
	self.guard.position = Vec3(ox + 6.5, 0, -0.16) -- 778
	self.guard.angles = Vec3(0, -72, 0) -- 779
	local writing = p.deskHold >= 24 or p.towerHanded -- 781
	local nextGuardAnim = writing and "write" or "lantern" -- 782
	if self.guardAnim ~= nextGuardAnim then -- 782
		self.guardAnim = nextGuardAnim -- 784
		self.guard:play(nextGuardAnim, true) -- 785
	end -- 785
end -- 714
function Xiaoman3DEntities.prototype.stepAndDrawFx(self, dt, glow, groundFx) -- 791
	local aliveRings = {} -- 792
	local i = 0 -- 793
	do -- 793
		i = 0 -- 794
		while i < #self.rings do -- 794
			local r = self.rings[i + 1] -- 795
			r.age = r.age + dt -- 796
			if r.age < r.duration then -- 796
				aliveRings[#aliveRings + 1] = r -- 798
				if r.age >= 0 then -- 798
					local prog = clamp01(r.age / r.duration) -- 800
					local rad = 8 + prog * r.maxRadius -- 801
					local alpha = math.floor((1 - prog) * (r.kind == "iron" and 210 or (r.kind == "brick" and 170 or 95)) + 0.5) -- 802
					local col = r.kind == "iron" and Color(216, 232, 248, alpha) or (r.kind == "brick" and Color(224, 198, 152, alpha) or Color(138, 122, 100, alpha)) -- 803
					drawGroundRing( -- 806
						groundFx, -- 806
						r.x, -- 806
						r.z, -- 806
						rad, -- 806
						col, -- 806
						28 -- 806
					) -- 806
				end -- 806
			end -- 806
			i = i + 1 -- 794
		end -- 794
	end -- 794
	self.rings = aliveRings -- 810
	local aliveShards = {} -- 812
	do -- 812
		i = 0 -- 813
		while i < #self.shards do -- 813
			local s = self.shards[i + 1] -- 814
			s.life = s.life + dt -- 815
			if s.life < s.maxLife then -- 815
				s.x = s.x + s.vx * dt -- 817
				s.y = math.max(0, s.y + s.vy * dt) -- 818
				s.vy = s.vy - 480 * dt -- 819
				aliveShards[#aliveShards + 1] = s -- 820
				local sz = 2.2 * (1 - s.life / s.maxLife) -- 821
				glow:drawDot( -- 822
					Vec2(s.x, s.y), -- 822
					math.max(0.8, sz), -- 822
					s.color -- 822
				) -- 822
			end -- 822
			i = i + 1 -- 813
		end -- 813
	end -- 813
	self.shards = aliveShards -- 825
end -- 791
function Xiaoman3DEntities.prototype.getDebugState(self) -- 828
	return { -- 829
		room = self.lastRoom, -- 830
		doorOpenFrac = self.doorOpenFrac, -- 831
		basinShakeTimer = self.basinShakeTimer, -- 832
		creekReveal = self.creekReveal, -- 833
		scavAnim = self.scavAnim, -- 834
		dogAnim = self.dogAnim, -- 835
		guardAnim = self.guardAnim, -- 836
		cartAnim = self.cartAnim, -- 837
		activeRings = #self.rings -- 838
	} -- 838
end -- 828
return ____exports -- 828