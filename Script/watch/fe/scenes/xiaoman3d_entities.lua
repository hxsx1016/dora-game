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
function Xiaoman3DEntities.prototype.____constructor(self, root) -- 158
	self.container = Node3D() -- 100
	self.moonLight = DirectionalLight3D() -- 103
	self.fillLight = DirectionalLight3D() -- 104
	self.roomLightA = PointLight3D() -- 105
	self.roomLightB = PointLight3D() -- 106
	self.cartAnim = "" -- 115
	self.prevCartAxle = 0 -- 116
	self.scavAnim = "" -- 123
	self.scavYaw = -80 -- 124
	self.prevScavX = 0 -- 125
	self.basinShakeTimer = 0 -- 126
	self.prevBottleLandT = 0 -- 127
	self.dogAnim = "" -- 131
	self.dogYaw = -84 -- 132
	self.prevDogX = 0 -- 133
	self.grasses = {} -- 135
	self.twigs = {} -- 136
	self.creekReveal = 0 -- 139
	self.lastSnappedTwig = -1 -- 140
	self.guardAnim = "" -- 148
	self.doorOpenFrac = 0 -- 149
	self.lastRoom = "" -- 152
	self.time = 0 -- 153
	self.rings = {} -- 154
	self.shards = {} -- 155
	self.animatedModels = {} -- 156
	root:addChild(self.container) -- 159
	self.moonLight.color = Color3(135, 168, 214) -- 162
	self.moonLight.intensity = 1.35 -- 163
	self.moonLight.angles = Vec3(-44, -28, 0) -- 164
	self.moonLight.castShadow = true -- 165
	self.moonLight.shadowBias = 0.0018 -- 166
	self.moonLight.shadowNormalBias = 0.028 -- 167
	self.moonLight.shadowSoftness = 1.6 -- 168
	self.container:addChild(self.moonLight) -- 169
	self.fillLight.color = Color3(62, 82, 112) -- 172
	self.fillLight.intensity = 0.42 -- 173
	self.fillLight.angles = Vec3(28, 146, 0) -- 174
	self.fillLight.castShadow = false -- 175
	self.container:addChild(self.fillLight) -- 176
	self.roomLightA.color = Color3(255, 198, 112) -- 179
	self.roomLightA.intensity = 0 -- 180
	self.roomLightA.range = 4 -- 181
	self.container:addChild(self.roomLightA) -- 182
	self.roomLightB.color = Color3(156, 186, 224) -- 184
	self.roomLightB.intensity = 0 -- 185
	self.roomLightB.range = 3 -- 186
	self.container:addChild(self.roomLightB) -- 187
end -- 158
function Xiaoman3DEntities.prototype.registerAnimated(self, m) -- 190
	local ____self_animatedModels_0 = self.animatedModels -- 190
	____self_animatedModels_0[#____self_animatedModels_0 + 1] = m -- 191
	return m -- 192
end -- 190
function Xiaoman3DEntities.prototype.hideAllEntities(self) -- 195
	if self.cart ~= nil then -- 195
		self.cart.visible = false -- 196
	end -- 196
	if self.latch ~= nil then -- 196
		self.latch.visible = false -- 197
	end -- 197
	if self.outsideLantern ~= nil then -- 197
		self.outsideLantern.visible = false -- 198
	end -- 198
	if self.scav ~= nil then -- 198
		self.scav.visible = false -- 200
	end -- 200
	if self.shelfBottle ~= nil then -- 200
		self.shelfBottle.visible = false -- 201
	end -- 201
	if self.airBottle ~= nil then -- 201
		self.airBottle.visible = false -- 202
	end -- 202
	if self.basin ~= nil then -- 202
		self.basin.visible = false -- 203
	end -- 203
	if self.dog ~= nil then -- 203
		self.dog.visible = false -- 205
	end -- 205
	if self.creekLantern ~= nil then -- 205
		self.creekLantern.visible = false -- 206
	end -- 206
	local i = 0 -- 207
	do -- 207
		i = 0 -- 208
		while i < #self.grasses do -- 208
			self.grasses[i + 1].visible = false -- 208
			i = i + 1 -- 208
		end -- 208
	end -- 208
	do -- 208
		i = 0 -- 209
		while i < #self.twigs do -- 209
			self.twigs[i + 1].visible = false -- 209
			i = i + 1 -- 209
		end -- 209
	end -- 209
	if self.boughL ~= nil then -- 209
		self.boughL.visible = false -- 210
	end -- 210
	if self.boughR ~= nil then -- 210
		self.boughR.visible = false -- 211
	end -- 211
	if self.door ~= nil then -- 211
		self.door.visible = false -- 213
	end -- 213
	if self.guard ~= nil then -- 213
		self.guard.visible = false -- 214
	end -- 214
	if self.towerLantern ~= nil then -- 214
		self.towerLantern.visible = false -- 215
	end -- 215
	if self.ledger ~= nil then -- 215
		self.ledger.visible = false -- 216
	end -- 216
	if self.pouch ~= nil then -- 216
		self.pouch.visible = false -- 217
	end -- 217
end -- 195
function Xiaoman3DEntities.prototype.hide(self) -- 220
	self:setPaused(true) -- 221
end -- 220
function Xiaoman3DEntities.prototype.setPaused(self, paused) -- 224
	local i = 0 -- 225
	do -- 225
		i = 0 -- 226
		while i < #self.animatedModels do -- 226
			local m = self.animatedModels[i + 1] -- 227
			if paused then -- 227
				if not m.paused then -- 227
					m:pause() -- 229
				end -- 229
			elseif m.paused then -- 229
				m:resume() -- 231
			end -- 231
			i = i + 1 -- 226
		end -- 226
	end -- 226
end -- 224
function Xiaoman3DEntities.prototype.update(self, p, dt, camX, glow, groundFx) -- 236
	local paused = p.paused or dt <= 0 -- 237
	local safeDt = paused and 0 or math.min(0.05, dt) -- 238
	self:setPaused(paused) -- 239
	if not paused then -- 239
		self.time = self.time + safeDt -- 241
	end -- 241
	if self.lastRoom ~= p.room.key then -- 241
		self.lastRoom = p.room.key -- 245
		self:hideAllEntities() -- 246
		self.rings = {} -- 247
		self.shards = {} -- 248
		self.basinShakeTimer = 0 -- 249
		self.prevBottleLandT = 0 -- 250
		self.prevCartAxle = p.cartAxle -- 251
		self.prevScavX = p.scavX -- 252
		self.prevDogX = p.dogX -- 253
		self.doorOpenFrac = p.towerDoorOpen and 1 or 0 -- 254
		self.creekReveal = 0 -- 255
		self.lastSnappedTwig = -1 -- 256
	end -- 256
	if self.sky == nil then -- 256
		self.sky = mountModel(self.container, PATH_SKY) -- 261
	end -- 261
	self.sky.visible = true -- 263
	self.sky.position = Vec3(camX / 100, -0.3, -4.5) -- 264
	self.sky.scale = Vec3(1.15, 1, 1) -- 265
	if p.room.key == "outside" then -- 265
		self:updateOutside(p, safeDt) -- 269
	elseif p.room.key == "village" then -- 269
		self:updateVillage(p, safeDt, groundFx) -- 271
	elseif p.room.key == "forest" then -- 271
		self:updateForest(p, safeDt, glow, groundFx) -- 273
	elseif p.room.key == "tower" then -- 273
		self:updateTower(p, safeDt) -- 275
	end -- 275
	self:stepAndDrawFx(safeDt, glow, groundFx) -- 279
end -- 236
function Xiaoman3DEntities.prototype.updateOutside(self, p, dt) -- 284
	local ox = p.ox / 100 -- 285
	self.moonLight.color = Color3(144, 178, 224) -- 288
	self.moonLight.intensity = 1.68 -- 289
	self.moonLight.angles = Vec3(-44, -26, 0) -- 290
	self.fillLight.color = Color3(68, 92, 126) -- 291
	self.fillLight.intensity = 0.54 -- 292
	local pulse = 0.92 + math.sin(self.time * 2.4) * 0.08 -- 295
	self.roomLightA.color = Color3(255, 196, 108) -- 296
	self.roomLightA.intensity = 2.6 * pulse -- 297
	self.roomLightA.range = 5.2 -- 298
	self.roomLightA.position = Vec3(ox + 11.2, 1.55, -0.75) -- 299
	self.roomLightB.color = Color3(166, 192, 224) -- 302
	self.roomLightB.intensity = 1.05 -- 303
	self.roomLightB.range = 3.2 -- 304
	self.roomLightB.position = Vec3(p.cartAxle / 100, 1.65, 0.85) -- 305
	local c = p.room.cart -- 308
	if c.bodyW > 0 then -- 308
		if self.cart == nil then -- 308
			self.cart = self:registerAnimated(mountModel(self.container, PATH_CART)) -- 311
		end -- 311
		self.cart.visible = true -- 313
		self.cart.position = Vec3(p.cartAxle / 100, c.baseY / 100, -(c.depth or 0) / 100) -- 314
		self.cart.angles = Vec3(0, 0, 0) -- 315
		local rolling = math.abs(p.cartAxle - self.prevCartAxle) > 0.04 -- 317
		self.prevCartAxle = p.cartAxle -- 318
		local nextAnim = rolling and "roll" or "idle" -- 319
		if self.cartAnim ~= nextAnim then -- 319
			self.cartAnim = nextAnim -- 321
			self.cart:play(nextAnim, true) -- 322
		end -- 322
		self.cart.speed = rolling and 1.15 or 0.75 -- 324
	end -- 324
	local latchBounds = p:cartLatchBounds() -- 328
	if latchBounds ~= nil then -- 328
		if self.latch == nil then -- 328
			self.latch = mountModel(self.container, PATH_LATCH) -- 331
		end -- 331
		self.latch.visible = true -- 333
		self.latch.position = Vec3((latchBounds.x + latchBounds.width * 0.5) / 100, latchBounds.y / 100, -0.52) -- 334
		self.latch.scale = Vec3( -- 335
			math.max(0.7, latchBounds.width / 48), -- 335
			1, -- 335
			1 -- 335
		) -- 335
	elseif self.latch ~= nil then -- 335
		self.latch.visible = false -- 337
	end -- 337
	if self.outsideLantern == nil then -- 337
		self.outsideLantern = mountModel(self.container, PATH_LANTERN) -- 342
	end -- 342
	self.outsideLantern.visible = true -- 344
	self.outsideLantern.position = Vec3(ox + 11.2, 1.48, -0.95) -- 345
	self.outsideLantern.angles = Vec3( -- 346
		0, -- 346
		0, -- 346
		math.sin(self.time * 1.9) * 3.5 -- 346
	) -- 346
end -- 284
function Xiaoman3DEntities.prototype.updateVillage(self, p, dt, groundFx) -- 351
	local ox = p.ox / 100 -- 352
	self.moonLight.color = Color3(132, 166, 214) -- 355
	self.moonLight.intensity = 1.48 -- 356
	self.moonLight.angles = Vec3(-52, -32, 0) -- 357
	self.fillLight.color = Color3(62, 80, 110) -- 358
	self.fillLight.intensity = 0.5 -- 359
	self.roomLightA.color = Color3(162, 194, 232) -- 362
	self.roomLightA.intensity = 1.95 -- 363
	self.roomLightA.range = 4 -- 364
	self.roomLightA.position = Vec3(ox + 5.75, 1.38, 0.45) -- 365
	self.roomLightB.color = Color3(212, 178, 134) -- 368
	self.roomLightB.intensity = 1.05 -- 369
	self.roomLightB.range = 2.5 -- 370
	self.roomLightB.position = Vec3(ox + 1.12, 0.85, 0.36) -- 371
	if self.shelfBottle == nil then -- 371
		self.shelfBottle = mountModel(self.container, PATH_BOTTLE) -- 375
	end -- 375
	local showShelfBottle = not p.hasBottle and p.bottleFly == nil and p.bottleLandT <= 0 and p.room.bottle ~= nil -- 377
	self.shelfBottle.visible = showShelfBottle -- 378
	if showShelfBottle and p.room.bottle ~= nil then -- 378
		local bx = math.min(p.room.bottle.x, p.ox + 108) / 100 -- 380
		self.shelfBottle.position = Vec3(bx, 0.46, 0.06) -- 381
	end -- 381
	if self.airBottle == nil then -- 381
		self.airBottle = mountModel(self.container, PATH_BOTTLE) -- 386
	end -- 386
	if p.bottleFly ~= nil then -- 386
		self.airBottle.visible = true -- 389
		local prog = clamp01(p.bottleFly.t / 0.62) -- 390
		local z = -p.player.depth / 100 * (1 - prog) -- 391
		self.airBottle.position = Vec3(p.bottleFly.x / 100, p.bottleFly.y / 100, z) -- 392
		self.airBottle.angles = Vec3(self.time * 240, 0, -self.time * 540) -- 393
	else -- 393
		self.airBottle.visible = false -- 395
	end -- 395
	if p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 then -- 395
		local lx = p.bottleLandX -- 400
		local isSoft = p.room.softX ~= nil and math.abs(lx - p.room.softX) <= 34 -- 401
		local isIron = p.room.basinX ~= nil and math.abs(lx - p.room.basinX) <= 24 -- 402
		local kind = isSoft and "soft" or (isIron and "iron" or "brick") -- 403
		self:spawnBottleImpactFx(lx, p.bottleLandY, kind) -- 404
		if kind == "iron" then -- 404
			self.basinShakeTimer = 1.15 -- 406
		end -- 406
	end -- 406
	self.prevBottleLandT = p.bottleLandT -- 409
	if self.basin == nil then -- 409
		self.basin = mountModel(self.container, PATH_BASIN) -- 413
	end -- 413
	local basinX = (p.room.basinX ~= nil and p.room.basinX or p.ox + 548) / 100 -- 415
	self.basin.visible = true -- 416
	self.basin.position = Vec3(basinX, 0.095, -0.18) -- 417
	if self.basinShakeTimer > 0 then -- 417
		self.basinShakeTimer = math.max(0, self.basinShakeTimer - dt) -- 419
		local amp = self.basinShakeTimer / 1.15 -- 420
		local wobble = amp * amp -- 421
		self.basin.angles = Vec3( -- 422
			math.sin(self.time * 48) * 14 * wobble, -- 423
			math.sin(self.time * 24) * 6 * wobble, -- 424
			math.cos(self.time * 42) * 16 * wobble -- 425
		) -- 425
	else -- 425
		self.basin.angles = Vec3(0, 0, 0) -- 428
	end -- 428
	if p.room.scavenger ~= nil then -- 428
		if self.scav == nil then -- 428
			self.scav = self:registerAnimated(mountModel(self.container, PATH_SCAV)) -- 434
		end -- 434
		self.scav.visible = true -- 436
		self.scav.position = Vec3(p.scavX / 100, p.room.scavenger.y / 100, 0.02) -- 437
		local dx = p.scavX - self.prevScavX -- 439
		self.prevScavX = p.scavX -- 440
		local desiredDir = p.scavDir -- 442
		if p.scavState == "turn" or p.scavState == "walk" then -- 442
			desiredDir = p.scavTargetX >= p.scavX and 1 or -1 -- 444
		elseif p.scavState == "chase" then -- 444
			desiredDir = p.player.x >= p.scavX and 1 or -1 -- 446
		elseif math.abs(dx) > 0.02 then -- 446
			desiredDir = dx > 0 and 1 or -1 -- 448
		end -- 448
		local targetYaw = desiredDir >= 0 and 80 or -80 -- 450
		self.scavYaw = self.scavYaw + (targetYaw - self.scavYaw) * math.min(1, dt * 10) -- 451
		self.scav.angles = Vec3(0, self.scavYaw, 0) -- 452
		local nextAnim = "idle" -- 454
		if p.scavState == "chase" then -- 454
			nextAnim = "chase" -- 456
		elseif p.scavState == "turn" then -- 456
			nextAnim = "turn" -- 458
		elseif p.scavState == "walk" or p.scavState == "back" or p.scavState == "patrol" and math.abs(dx) > 0.01 then -- 458
			nextAnim = "walk" -- 460
		else -- 460
			nextAnim = "idle" -- 462
		end -- 462
		if self.scavAnim ~= nextAnim then -- 462
			self.scavAnim = nextAnim -- 465
			self.scav:play(nextAnim, true) -- 466
		end -- 466
		local lookDir = self.scavYaw >= 0 and 1 or -1 -- 470
		local alert = p.scavState == "chase" or p.scavState == "turn" -- 471
		local coneCol = alert and Color(188, 72, 54, 48) or Color(128, 152, 184, 28) -- 472
		local edgeCol = alert and Color(214, 96, 68, 86) or Color(156, 182, 212, 52) -- 473
		local sx = p.scavX -- 474
		local coneLen = alert and 115 or 88 -- 475
		groundFx:drawPolygon( -- 476
			{ -- 476
				Vec2(sx, 0), -- 477
				Vec2(sx + lookDir * coneLen, -34), -- 478
				Vec2(sx + lookDir * coneLen, 34) -- 479
			}, -- 479
			coneCol, -- 480
			0.8, -- 480
			edgeCol -- 480
		) -- 480
	end -- 480
	if p.passed then -- 480
		local pulse = 0.65 + 0.35 * math.sin(self.time * 2.2) -- 485
		groundFx:drawPolygon( -- 486
			{ -- 486
				Vec2(p.ox + 566, -34), -- 487
				Vec2(p.ox + 634, -34), -- 488
				Vec2(p.ox + 634, -18), -- 489
				Vec2(p.ox + 566, -18) -- 490
			}, -- 490
			Color( -- 491
				92, -- 491
				134, -- 491
				154, -- 491
				math.floor(42 * pulse + 0.5) -- 491
			), -- 491
			1, -- 491
			Color( -- 491
				164, -- 491
				206, -- 491
				224, -- 491
				math.floor(96 * pulse + 0.5) -- 491
			) -- 491
		) -- 491
	end -- 491
end -- 351
function Xiaoman3DEntities.prototype.spawnBottleImpactFx(self, x, y, kind) -- 495
	if kind == "iron" then -- 495
		local ____self_rings_1 = self.rings -- 495
		____self_rings_1[#____self_rings_1 + 1] = { -- 497
			x = x, -- 497
			z = 0, -- 497
			age = 0, -- 497
			duration = 1.05, -- 497
			maxRadius = 96, -- 497
			kind = kind -- 497
		} -- 497
		local ____self_rings_2 = self.rings -- 497
		____self_rings_2[#____self_rings_2 + 1] = { -- 498
			x = x, -- 498
			z = 0, -- 498
			age = -0.22, -- 498
			duration = 1.15, -- 498
			maxRadius = 122, -- 498
			kind = kind -- 498
		} -- 498
	elseif kind == "brick" then -- 498
		local ____self_rings_3 = self.rings -- 498
		____self_rings_3[#____self_rings_3 + 1] = { -- 500
			x = x, -- 500
			z = 0, -- 500
			age = 0, -- 500
			duration = 0.62, -- 500
			maxRadius = 68, -- 500
			kind = kind -- 500
		} -- 500
	else -- 500
		local ____self_rings_4 = self.rings -- 500
		____self_rings_4[#____self_rings_4 + 1] = { -- 502
			x = x, -- 502
			z = 0, -- 502
			age = 0, -- 502
			duration = 0.45, -- 502
			maxRadius = 26, -- 502
			kind = kind -- 502
		} -- 502
	end -- 502
	local count = kind == "soft" and 5 or 9 -- 505
	local col = kind == "iron" and Color(224, 232, 244, 220) or (kind == "brick" and Color(204, 154, 108, 220) or Color(118, 98, 76, 170)) -- 506
	local i = 0 -- 509
	do -- 509
		i = 0 -- 510
		while i < count do -- 510
			local frac = i / count - 0.5 -- 511
			local ____self_shards_5 = self.shards -- 511
			____self_shards_5[#____self_shards_5 + 1] = { -- 512
				x = x + frac * 10, -- 513
				y = y + 4, -- 514
				vx = frac * (kind == "soft" and 45 or 135), -- 515
				vy = (kind == "soft" and 48 or 115) + i % 3 * 28, -- 516
				life = 0, -- 517
				maxLife = kind == "soft" and 0.35 or 0.48, -- 518
				color = col -- 519
			} -- 519
			i = i + 1 -- 510
		end -- 510
	end -- 510
end -- 495
function Xiaoman3DEntities.prototype.updateForest(self, p, dt, glow, groundFx) -- 526
	local ox = p.ox / 100 -- 527
	self.moonLight.color = Color3(126, 168, 198) -- 530
	self.moonLight.intensity = 1.52 -- 531
	self.moonLight.angles = Vec3(-46, -24, 0) -- 532
	self.fillLight.color = Color3(56, 84, 98) -- 533
	self.fillLight.intensity = 0.52 -- 534
	local flick = 0.9 + math.sin(self.time * 3.6) * 0.06 + math.cos(self.time * 6.1) * 0.04 -- 537
	self.roomLightA.color = Color3(255, 198, 112) -- 538
	self.roomLightA.intensity = 2.9 * flick -- 539
	self.roomLightA.range = 5.4 -- 540
	self.roomLightA.position = Vec3(ox + 12.24, 0.72, -0.62) -- 541
	self.roomLightB.color = Color3(144, 184, 214) -- 544
	self.roomLightB.intensity = 1.15 -- 545
	self.roomLightB.range = 4.6 -- 546
	self.roomLightB.position = Vec3(ox + 7.45, 1.85, 0.65) -- 547
	if self.dog == nil then -- 547
		self.dog = self:registerAnimated(mountModel(self.container, PATH_DOG)) -- 551
	end -- 551
	self.dog.visible = true -- 553
	self.dog.position = Vec3(p.dogX / 100, 0, -0.06) -- 554
	local ddx = p.dogX - self.prevDogX -- 556
	self.prevDogX = p.dogX -- 557
	local dogDir = self.dogYaw >= 0 and 1 or -1 -- 558
	if p.dogState == "chase" or p.dogState == "ear" then -- 558
		dogDir = p.player.x >= p.dogX and 1 or -1 -- 560
	elseif math.abs(ddx) > 0.02 then -- 560
		dogDir = ddx > 0 and 1 or -1 -- 562
	end -- 562
	local targetDogYaw = dogDir >= 0 and 84 or -84 -- 564
	self.dogYaw = self.dogYaw + (targetDogYaw - self.dogYaw) * math.min(1, dt * 12) -- 565
	self.dog.angles = Vec3(0, self.dogYaw, 0) -- 566
	local nextDogAnim = "walk" -- 568
	if p.dogState == "ear" then -- 568
		nextDogAnim = "ear" -- 570
	elseif p.dogState == "chase" then -- 570
		nextDogAnim = "chase" -- 572
	elseif p.dogState == "sniff" then -- 572
		nextDogAnim = "sniff" -- 574
	elseif math.abs(ddx) > 0.01 then -- 574
		nextDogAnim = "walk" -- 576
	else -- 576
		nextDogAnim = "idle" -- 578
	end -- 578
	if self.dogAnim ~= nextDogAnim then -- 578
		self.dogAnim = nextDogAnim -- 581
		self.dog:play(nextDogAnim, true) -- 582
	end -- 582
	if #self.grasses == 0 then -- 582
		local gIdx = 0 -- 587
		do -- 587
			gIdx = 0 -- 588
			while gIdx < #GRASS_CENTERS * 2 do -- 588
				local ____self_grasses_6 = self.grasses -- 588
				____self_grasses_6[#____self_grasses_6 + 1] = mountModel(self.container, PATH_GRASS) -- 589
				gIdx = gIdx + 1 -- 588
			end -- 588
		end -- 588
	end -- 588
	local gi = 0 -- 592
	do -- 592
		gi = 0 -- 593
		while gi < #GRASS_CENTERS do -- 593
			local gx = ox + GRASS_CENTERS[gi + 1] / 100 -- 594
			local sway = math.sin(self.time * 1.8 + gi * 1.4) * 2.5 -- 595
			local fgGrass = self.grasses[gi * 2 + 1] -- 596
			fgGrass.visible = true -- 597
			fgGrass.position = Vec3(gx, 0, 0.36) -- 598
			fgGrass.angles = Vec3(0, 0, sway) -- 599
			fgGrass.scale = Vec3(1.12, 1, 1) -- 600
			local bgGrass = self.grasses[gi * 2 + 1 + 1] -- 602
			bgGrass.visible = true -- 603
			bgGrass.position = Vec3(gx + 0.08, 0, -0.48) -- 604
			bgGrass.angles = Vec3(0, 180, -sway * 0.7) -- 605
			bgGrass.scale = Vec3(1.18, 1.15, 1) -- 606
			gi = gi + 1 -- 593
		end -- 593
	end -- 593
	if #self.twigs == 0 then -- 593
		local ti = 0 -- 611
		do -- 611
			ti = 0 -- 612
			while ti < #TWIG_OFFSETS do -- 612
				local ____self_twigs_7 = self.twigs -- 612
				____self_twigs_7[#____self_twigs_7 + 1] = mountModel(self.container, PATH_TWIG) -- 613
				ti = ti + 1 -- 612
			end -- 612
		end -- 612
	end -- 612
	local curTwig = -1 -- 616
	local ti = 0 -- 617
	do -- 617
		ti = 0 -- 618
		while ti < #TWIG_OFFSETS do -- 618
			local tx = p.ox + TWIG_OFFSETS[ti + 1] -- 619
			local m = self.twigs[ti + 1] -- 620
			m.visible = true -- 621
			m.position = Vec3(tx / 100, 0.005, 0.06) -- 622
			m.angles = Vec3(0, ti * 35, 0) -- 623
			if not p.player.crouch and p.player.y <= 8 and math.abs(p.player.x - tx) <= 18 and (math.abs(p.player.vx) > 10 or math.abs(p.player.depthSpeed) > 10) then -- 623
				curTwig = ti -- 626
			end -- 626
			ti = ti + 1 -- 618
		end -- 618
	end -- 618
	if curTwig >= 0 and curTwig ~= self.lastSnappedTwig then -- 618
		local tx = p.ox + TWIG_OFFSETS[curTwig + 1] -- 630
		local k = 0 -- 631
		do -- 631
			k = 0 -- 632
			while k < 6 do -- 632
				local f = k / 6 - 0.5 -- 633
				local ____self_shards_8 = self.shards -- 633
				____self_shards_8[#____self_shards_8 + 1] = { -- 634
					x = tx + f * 12, -- 635
					y = 4, -- 636
					vx = f * 92, -- 637
					vy = 68 + k % 3 * 24, -- 638
					life = 0, -- 639
					maxLife = 0.42, -- 640
					color = Color(162, 134, 98, 220) -- 641
				} -- 641
				k = k + 1 -- 632
			end -- 632
		end -- 632
	end -- 632
	self.lastSnappedTwig = curTwig -- 645
	if self.creekLantern == nil then -- 645
		self.creekLantern = mountModel(self.container, PATH_LANTERN) -- 649
	end -- 649
	self.creekLantern.visible = true -- 651
	self.creekLantern.position = Vec3(ox + 12.24, 0.48, -0.74) -- 652
	self.creekLantern.angles = Vec3( -- 653
		0, -- 653
		0, -- 653
		math.sin(self.time * 1.6) * 2.8 -- 653
	) -- 653
	local lampX = p.ox + 1224 -- 655
	local ri = 0 -- 656
	do -- 656
		ri = 0 -- 657
		while ri < 4 do -- 657
			local phase = self.time * 2.1 + ri * 1.3 -- 658
			local sx = math.sin(phase) * (4 + ri * 2.5) -- 659
			local w = 22 - ri * 3.5 -- 660
			local a = math.floor(135 - ri * 26 + 0.5) -- 661
			groundFx:drawEllipse( -- 662
				Vec2(lampX + sx, -26 + ri * 14), -- 662
				w, -- 662
				2.2, -- 662
				Color(246, 214, 146, a) -- 662
			) -- 662
			ri = ri + 1 -- 657
		end -- 657
	end -- 657
	glow:drawEllipse( -- 664
		Vec2( -- 664
			lampX + math.sin(self.time * 1.7) * 3, -- 664
			2 -- 664
		), -- 664
		20, -- 664
		2.6, -- 664
		Color(242, 214, 148, 128) -- 664
	) -- 664
	if self.boughL == nil then -- 664
		self.boughL = mountModel(self.container, PATH_BOUGH) -- 668
		self.boughR = mountModel(self.container, PATH_BOUGH) -- 669
	end -- 669
	local targetReveal = smoothstep(p.ox + 1310, p.ox + 1435, p.player.x) -- 671
	self.creekReveal = self.creekReveal + (targetReveal - self.creekReveal) * math.min(1, dt * 4.5 + (dt == 0 and 0 or 0)) -- 672
	local swayB = math.sin(self.time * 1.4) * 2.2 -- 673
	self.boughL.visible = true -- 674
	self.boughL.position = Vec3(ox + 13.15 - self.creekReveal * 1.15, 1.56 + self.creekReveal * 0.36, 1.15) -- 675
	self.boughL.angles = Vec3(0, 8, -8 + self.creekReveal * 16 + swayB) -- 676
	if self.boughR ~= nil then -- 676
		self.boughR.visible = true -- 679
		self.boughR.position = Vec3(ox + 14.35 + self.creekReveal * 1.15, 1.48 + self.creekReveal * 0.4, 1.08) -- 680
		self.boughR.angles = Vec3(0, 172, 10 - self.creekReveal * 18 - swayB) -- 681
	end -- 681
end -- 526
function Xiaoman3DEntities.prototype.updateTower(self, p, dt) -- 687
	local ox = p.ox / 100 -- 688
	local ____opt_11 = p.room.story -- 688
	local ____opt_9 = ____opt_11 and ____opt_11.tower -- 688
	local doorX = (____opt_9 and ____opt_9.doorX or p.ox + 445) / 100 -- 689
	self.moonLight.color = Color3(126, 158, 208) -- 692
	self.moonLight.intensity = 1.32 -- 693
	self.moonLight.angles = Vec3(-42, -34, 0) -- 694
	self.fillLight.color = Color3(62, 80, 108) -- 695
	self.fillLight.intensity = 0.48 -- 696
	local targetOpen = p.towerDoorOpen and 1 or 0 -- 698
	self.doorOpenFrac = self.doorOpenFrac + (targetOpen - self.doorOpenFrac) * math.min(1, dt * 4.8) -- 699
	if math.abs(targetOpen - self.doorOpenFrac) < 0.005 then -- 699
		self.doorOpenFrac = targetOpen -- 701
	end -- 701
	local lampPulse = 0.94 + math.sin(self.time * 2.8) * 0.06 -- 704
	self.roomLightA.color = Color3(255, 196, 106) -- 706
	self.roomLightA.intensity = (1.55 + self.doorOpenFrac * 2.15) * lampPulse -- 707
	self.roomLightA.range = 5.4 -- 708
	self.roomLightA.position = Vec3(ox + 6.26, 0.72, -0.05) -- 709
	self.roomLightB.color = Color3(255, 204, 122) -- 712
	self.roomLightB.intensity = (1.35 + self.doorOpenFrac * 0.65) * lampPulse -- 713
	self.roomLightB.range = 3 -- 714
	self.roomLightB.position = Vec3(doorX, 1.05, 0.55) -- 715
	if self.door == nil then -- 715
		self.door = mountModel(self.container, PATH_DOOR) -- 719
	end -- 719
	self.door.visible = true -- 721
	self.door.position = Vec3(doorX - 0.1, 0, 0.12) -- 722
	self.door.scale = Vec3(0.9, 1, 1) -- 723
	local knockJitter = p.phase == "tower-knock" and math.sin(self.time * 36) * 2.2 or 0 -- 724
	self.door.angles = Vec3(0, -self.doorOpenFrac * 96 + knockJitter, 0) -- 725
	if self.towerLantern == nil then -- 725
		self.towerLantern = mountModel(self.container, PATH_LANTERN) -- 729
	end -- 729
	self.towerLantern.visible = true -- 731
	self.towerLantern.position = Vec3(ox + 6.38, 0.32, -0.18) -- 732
	if self.ledger == nil then -- 732
		self.ledger = mountModel(self.container, PATH_LEDGER) -- 735
	end -- 735
	self.ledger.visible = true -- 737
	self.ledger.position = Vec3(ox + 6.06, 0.32, -0.04) -- 738
	self.ledger.angles = Vec3(0, -10, 0) -- 739
	if self.pouch == nil then -- 739
		self.pouch = mountModel(self.container, PATH_POUCH) -- 742
	end -- 742
	self.pouch.visible = p.deskHold >= 12 or p.towerHanded -- 744
	self.pouch.position = Vec3(ox + 5.78, 0.32, 0.08) -- 745
	self.pouch.angles = Vec3(0, 14, 0) -- 746
	if self.guard == nil then -- 746
		self.guard = self:registerAnimated(mountModel(self.container, PATH_GUARD)) -- 749
	end -- 749
	self.guard.visible = self.doorOpenFrac > 0.08 or p.towerDoorOpen -- 751
	self.guard.position = Vec3(ox + 6.5, 0, -0.16) -- 752
	self.guard.angles = Vec3(0, -72, 0) -- 753
	local writing = p.deskHold >= 24 or p.towerHanded -- 755
	local nextGuardAnim = writing and "write" or "lantern" -- 756
	if self.guardAnim ~= nextGuardAnim then -- 756
		self.guardAnim = nextGuardAnim -- 758
		self.guard:play(nextGuardAnim, true) -- 759
	end -- 759
end -- 687
function Xiaoman3DEntities.prototype.stepAndDrawFx(self, dt, glow, groundFx) -- 765
	local aliveRings = {} -- 766
	local i = 0 -- 767
	do -- 767
		i = 0 -- 768
		while i < #self.rings do -- 768
			local r = self.rings[i + 1] -- 769
			r.age = r.age + dt -- 770
			if r.age < r.duration then -- 770
				aliveRings[#aliveRings + 1] = r -- 772
				if r.age >= 0 then -- 772
					local prog = clamp01(r.age / r.duration) -- 774
					local rad = 8 + prog * r.maxRadius -- 775
					local alpha = math.floor((1 - prog) * (r.kind == "iron" and 210 or (r.kind == "brick" and 170 or 95)) + 0.5) -- 776
					local col = r.kind == "iron" and Color(216, 232, 248, alpha) or (r.kind == "brick" and Color(224, 198, 152, alpha) or Color(138, 122, 100, alpha)) -- 777
					drawGroundRing( -- 780
						groundFx, -- 780
						r.x, -- 780
						r.z, -- 780
						rad, -- 780
						col, -- 780
						28 -- 780
					) -- 780
				end -- 780
			end -- 780
			i = i + 1 -- 768
		end -- 768
	end -- 768
	self.rings = aliveRings -- 784
	local aliveShards = {} -- 786
	do -- 786
		i = 0 -- 787
		while i < #self.shards do -- 787
			local s = self.shards[i + 1] -- 788
			s.life = s.life + dt -- 789
			if s.life < s.maxLife then -- 789
				s.x = s.x + s.vx * dt -- 791
				s.y = math.max(0, s.y + s.vy * dt) -- 792
				s.vy = s.vy - 480 * dt -- 793
				aliveShards[#aliveShards + 1] = s -- 794
				local sz = 2.2 * (1 - s.life / s.maxLife) -- 795
				glow:drawDot( -- 796
					Vec2(s.x, s.y), -- 796
					math.max(0.8, sz), -- 796
					s.color -- 796
				) -- 796
			end -- 796
			i = i + 1 -- 787
		end -- 787
	end -- 787
	self.shards = aliveShards -- 799
end -- 765
function Xiaoman3DEntities.prototype.getDebugState(self) -- 802
	return { -- 803
		room = self.lastRoom, -- 804
		doorOpenFrac = self.doorOpenFrac, -- 805
		basinShakeTimer = self.basinShakeTimer, -- 806
		creekReveal = self.creekReveal, -- 807
		scavAnim = self.scavAnim, -- 808
		dogAnim = self.dogAnim, -- 809
		guardAnim = self.guardAnim, -- 810
		cartAnim = self.cartAnim, -- 811
		activeRings = #self.rings -- 812
	} -- 812
end -- 802
return ____exports -- 802