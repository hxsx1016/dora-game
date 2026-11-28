-- [ts]: scene_fx.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 13
local Color = ____Dora.Color -- 13
local Vec2 = ____Dora.Vec2 -- 13
local ____depth = require("Script.watch.depth") -- 15
local LANE_DEPTH = ____depth.LANE_DEPTH -- 15
local LANE_ROAD = ____depth.LANE_ROAD -- 15
local ____occlusion = require("Script.watch.fe.occlusion") -- 18
local depthOrder = ____occlusion.depthOrder -- 18
local ____escort_world = require("Script.watch.fe.scenes.escort_world") -- 19
local isEscortWorldRoom = ____escort_world.isEscortWorldRoom -- 19
local ____theme = require("Script.watch.fe.theme") -- 20
local PALETTE = ____theme.PALETTE -- 20
local fillGradQuad = ____theme.fillGradQuad -- 20
local fillRadialGlow = ____theme.fillRadialGlow -- 20
local themeOf = ____theme.themeOf -- 20
local toColor = ____theme.toColor -- 20
local PARTICLE_COUNT = 92 -- 84
local MAX_SPLASHES = 24 -- 85
local MAX_LEAVES = 32 -- 86
local MAX_BRAZIER_EMBERS = 36 -- 87
local SFX_FLAME_CLIPS = {"assets/art/vfx_ming_fx.clip|flame_0", "assets/art/vfx_ming_fx.clip|flame_1", "assets/art/vfx_ming_fx.clip|flame_2", "assets/art/vfx_ming_fx.clip|flame_3"} -- 89
local SFX_FLAG_CLIPS = {"assets/art/vfx_ming_fx.clip|flag_red_0", "assets/art/vfx_ming_fx.clip|flag_red_1", "assets/art/vfx_ming_fx.clip|flag_red_2", "assets/art/vfx_ming_fx.clip|flag_red_3"} -- 95
local SFX_LANTERN_FLAME_CLIPS = {"assets/art/vfx_ming_fx.clip|lantern_flame_0", "assets/art/vfx_ming_fx.clip|lantern_flame_1"} -- 101
local SFX_LEAF_CLIPS = {"assets/art/vfx_ming_fx.clip|leaf_0", "assets/art/vfx_ming_fx.clip|leaf_1"} -- 105
local SFX_RAIN_SPLASH_CLIPS = {"assets/art/vfx_ming_fx.clip|rain_splash_0", "assets/art/vfx_ming_fx.clip|rain_splash_1"} -- 109
local function clamp01(v) -- 114
	return v <= 0 and 0 or (v >= 1 and 1 or v) -- 115
end -- 114
local function hash01(seed) -- 118
	local x = math.sin(seed * 127.1 + 311.7) * 43758.5453 -- 119
	return x - math.floor(x) -- 120
end -- 118
local function weatherOfRoom(roomKey) -- 123
	if roomKey == "gate" then -- 124
		return "siege" -- 125
	end -- 125
	if roomKey == "outside" or roomKey == "village" or roomKey == "escort4" then -- 127
		return "rain" -- 128
	end -- 128
	if roomKey == "forest" or roomKey == "escort3" then -- 130
		return "forest" -- 131
	end -- 131
	if roomKey == "tower" or roomKey == "museum" or roomKey == "escort5" then -- 133
		return "sanctuary" -- 134
	end -- 134
	return "embers" -- 136
end -- 123
local function roomWindScale(roomKey) -- 139
	if roomKey == "prologue" or roomKey == "escort2" or roomKey == "c2-granary" or roomKey == "museum" then -- 140
		return 0.25 -- 141
	end -- 141
	if roomKey == "tower" or roomKey == "escort3" then -- 143
		return 0.45 -- 144
	end -- 144
	if roomKey == "gate" or roomKey == "outside" or roomKey == "escort4" then -- 146
		return 1.25 -- 147
	end -- 147
	return 0.85 -- 149
end -- 139
local function isOutdoorRoom(roomKey) -- 152
	return roomKey ~= "prologue" and roomKey ~= "c2-granary" and roomKey ~= "escort2" and roomKey ~= "museum" -- 153
end -- 152
local function hasWarHorizon(roomKey) -- 159
	return roomKey == "prologue" or roomKey == "street" or roomKey == "s1-crossroad" or roomKey == "s2-drygoods" or roomKey == "s3-archway" or roomKey == "checkpoint" or roomKey == "c1-yard" or roomKey == "gate" or roomKey == "gatepath" or roomKey == "escort1" -- 160
end -- 159
local function lightShaftsForRoom(roomKey) -- 172
	if roomKey == "prologue" then -- 173
		return {{ -- 174
			x0 = 190, -- 175
			topW = 54, -- 175
			botShift = -82, -- 175
			botW = 118, -- 175
			color = PALETTE.jadeMist, -- 175
			alpha = 0.14 -- 175
		}, { -- 176
			x0 = 540, -- 176
			topW = 40, -- 176
			botShift = -68, -- 176
			botW = 96, -- 176
			color = PALETTE.jadeMist, -- 176
			alpha = 0.11 -- 176
		}} -- 176
	end -- 176
	if roomKey == "s2-drygoods" or roomKey == "s1-crossroad" or roomKey == "street" then -- 179
		return {{ -- 180
			x0 = 260, -- 181
			topW = 48, -- 181
			botShift = -75, -- 181
			botW = 112, -- 181
			color = PALETTE.jadeMist, -- 181
			alpha = 0.1 -- 181
		}, { -- 182
			x0 = 760, -- 182
			topW = 56, -- 182
			botShift = -84, -- 182
			botW = 128, -- 182
			color = PALETTE.jadeMist, -- 182
			alpha = 0.1 -- 182
		}} -- 182
	end -- 182
	if roomKey == "c2-granary" then -- 185
		return {{ -- 186
			x0 = 280, -- 187
			topW = 46, -- 187
			botShift = -72, -- 187
			botW = 108, -- 187
			color = PALETTE.jadeMist, -- 187
			alpha = 0.16 -- 187
		}, { -- 188
			x0 = 660, -- 188
			topW = 52, -- 188
			botShift = -80, -- 188
			botW = 120, -- 188
			color = PALETTE.jadeMist, -- 188
			alpha = 0.15 -- 188
		}, { -- 189
			x0 = 1040, -- 189
			topW = 42, -- 189
			botShift = -68, -- 189
			botW = 98, -- 189
			color = PALETTE.jadeMist, -- 189
			alpha = 0.13 -- 189
		}} -- 189
	end -- 189
	if roomKey == "gate" then -- 192
		return {{ -- 193
			x0 = 910, -- 194
			topW = 72, -- 194
			botShift = -64, -- 194
			botW = 146, -- 194
			color = PALETTE.jadeMist, -- 194
			alpha = 0.16 -- 194
		}} -- 194
	end -- 194
	if roomKey == "forest" or roomKey == "escort3" then -- 197
		return {{ -- 198
			x0 = 340, -- 199
			topW = 44, -- 199
			botShift = -86, -- 199
			botW = 112, -- 199
			color = PALETTE.emerald, -- 199
			alpha = 0.1 -- 199
		}, { -- 200
			x0 = 880, -- 200
			topW = 52, -- 200
			botShift = -92, -- 200
			botW = 126, -- 200
			color = PALETTE.emerald, -- 200
			alpha = 0.11 -- 200
		}, { -- 201
			x0 = 1320, -- 201
			topW = 48, -- 201
			botShift = -76, -- 201
			botW = 118, -- 201
			color = PALETTE.amber, -- 201
			alpha = 0.09 -- 201
		}} -- 201
	end -- 201
	if roomKey == "tower" or roomKey == "escort5" then -- 204
		return {{ -- 205
			x0 = 445, -- 206
			topW = 58, -- 206
			botShift = -56, -- 206
			botW = 132, -- 206
			color = PALETTE.amber, -- 206
			alpha = 0.14 -- 206
		}} -- 206
	end -- 206
	if roomKey == "museum" then -- 209
		return {{ -- 210
			x0 = 240, -- 211
			topW = 68, -- 211
			botShift = 92, -- 211
			botW = 150, -- 211
			color = PALETTE.amberCore, -- 211
			alpha = 0.15 -- 211
		}, { -- 212
			x0 = 640, -- 212
			topW = 72, -- 212
			botShift = 96, -- 212
			botW = 158, -- 212
			color = PALETTE.amberCore, -- 212
			alpha = 0.13 -- 212
		}} -- 212
	end -- 212
	return {} -- 215
end -- 172
local function roomAnchors(roomKey) -- 218
	local roadBack = LANE_ROAD.max -- 219
	local escortBack = LANE_DEPTH.upper + 14 -- 220
	if roomKey == "street" or roomKey == "s1-crossroad" or roomKey == "s2-drygoods" then -- 221
		return {{offsetX = 168, y = 0, depth = roadBack, kind = "brazier"}, { -- 222
			offsetX = 465, -- 224
			y = 92, -- 224
			depth = roadBack, -- 224
			kind = "banner", -- 224
			facing = 1 -- 224
		}, {offsetX = 790, y = 0, depth = roadBack, kind = "brazier"}, { -- 225
			offsetX = 1030, -- 226
			y = 90, -- 226
			depth = roadBack, -- 226
			kind = "banner", -- 226
			facing = 1 -- 226
		}} -- 226
	end -- 226
	if roomKey == "s3-archway" or roomKey == "checkpoint" or roomKey == "c1-yard" then -- 229
		return {{offsetX = 210, y = 0, depth = roadBack, kind = "brazier"}, { -- 230
			offsetX = 540, -- 232
			y = 94, -- 232
			depth = roadBack, -- 232
			kind = "banner", -- 232
			facing = 1 -- 232
		}, {offsetX = 880, y = 0, depth = roadBack, kind = "brazier"}} -- 233
	end -- 233
	if roomKey == "gate" then -- 236
		return { -- 237
			{offsetX = 170, y = 0, depth = roadBack, kind = "brazier"}, -- 238
			{offsetX = 468, y = 0, depth = roadBack, kind = "brazier"}, -- 239
			{offsetX = 785, y = 0, depth = roadBack, kind = "brazier"}, -- 240
			{ -- 241
				offsetX = 340, -- 241
				y = 76, -- 241
				depth = roadBack, -- 241
				kind = "banner", -- 241
				facing = 1 -- 241
			}, -- 241
			{ -- 242
				offsetX = 715, -- 242
				y = 80, -- 242
				depth = roadBack, -- 242
				kind = "banner", -- 242
				facing = 1 -- 242
			} -- 242
		} -- 242
	end -- 242
	if roomKey == "gatepath" then -- 245
		return {{ -- 247
			offsetX = 164, -- 248
			y = 62, -- 248
			depth = 28, -- 248
			kind = "banner", -- 248
			facing = 1 -- 248
		}, { -- 249
			offsetX = 576, -- 249
			y = 56, -- 249
			depth = 28, -- 249
			kind = "banner", -- 249
			facing = 1 -- 249
		}} -- 249
	end -- 249
	if roomKey == "escort1" then -- 252
		return {{offsetX = 285, y = 0, depth = escortBack, kind = "brazier"}, {offsetX = 860, y = 0, depth = escortBack, kind = "brazier"}, { -- 254
			offsetX = 615, -- 257
			y = 74, -- 257
			depth = escortBack, -- 257
			kind = "banner", -- 257
			facing = 1 -- 257
		}} -- 257
	end -- 257
	if roomKey == "escort5" then -- 260
		return {{ -- 262
			offsetX = 268, -- 263
			y = 68, -- 263
			depth = escortBack, -- 263
			kind = "banner", -- 263
			facing = 1 -- 263
		}, {offsetX = 920, y = 0, depth = escortBack, kind = "brazier"}} -- 264
	end -- 264
	return {} -- 267
end -- 218
____exports.SceneFxSystem = __TS__Class() -- 270
local SceneFxSystem = ____exports.SceneFxSystem -- 270
SceneFxSystem.name = "SceneFxSystem" -- 270
function SceneFxSystem.prototype.____constructor(self) -- 286
	self.particles = {} -- 271
	self.splashes = {} -- 272
	self.leaves = {} -- 273
	self.brazierEmbers = {} -- 274
	self.time = 0 -- 276
	self.splashCooldown = 0 -- 277
	self.emberCooldown = 0 -- 278
	self.farFlash = 0 -- 279
	self.farFlashCooldown = 4.2 -- 280
	self.prevPlayerInGrass = false -- 281
	self.prevPlayerX = 0 -- 282
	self.lastRoomKey = "" -- 283
	self.rng = 20261127 -- 284
	self:initParticles() -- 287
end -- 286
function SceneFxSystem.prototype.rand(self) -- 290
	self.rng = (self.rng * 1664525 + 1013904223) % 4294967296 -- 291
	return self.rng / 4294967296 -- 292
end -- 290
function SceneFxSystem.prototype.initParticles(self) -- 295
	self.particles = {} -- 296
	do -- 296
		local i = 0 -- 297
		while i < PARTICLE_COUNT do -- 297
			local layer = i < 30 and 0 or (i < 66 and 1 or 2) -- 298
			local ____self_particles_0 = self.particles -- 299
			____self_particles_0[#____self_particles_0 + 1] = { -- 299
				fx = self:rand(), -- 300
				fy = self:rand(), -- 301
				layer = layer, -- 302
				speedMul = (layer == 0 and 0.52 or (layer == 1 and 0.96 or 1.48)) * (0.8 + self:rand() * 0.45), -- 303
				size = layer == 0 and 1 + self:rand() * 0.8 or (layer == 1 and 1.5 + self:rand() * 1.1 or 2.1 + self:rand() * 1.5), -- 304
				phase = self:rand() * math.pi * 2, -- 305
				drift = (self:rand() - 0.5) * 0.08, -- 306
				bright = self:rand() > 0.42 -- 307
			} -- 307
			i = i + 1 -- 297
		end -- 297
	end -- 297
end -- 295
function SceneFxSystem.prototype.reset(self, roomKey) -- 312
	if roomKey == nil then -- 312
		roomKey = "" -- 312
	end -- 312
	self.splashes = {} -- 313
	self.leaves = {} -- 314
	self.brazierEmbers = {} -- 315
	self.splashCooldown = 0 -- 316
	self.emberCooldown = 0 -- 317
	self.farFlash = 0 -- 318
	self.farFlashCooldown = 3.2 + self:rand() * 4.5 -- 319
	self.prevPlayerInGrass = false -- 320
	self.lastRoomKey = roomKey -- 321
end -- 312
function SceneFxSystem.prototype.windAt(self, time, roomKey) -- 325
	local base = roomWindScale(roomKey) -- 326
	local swell = 0.65 + 0.35 * math.sin(time * 0.47) -- 327
	local gustRaw = math.sin(time * 1.19 + 0.8) * math.sin(time * 0.31) -- 328
	local gust = gustRaw > 0 and gustRaw * gustRaw * 0.95 or 0 -- 329
	return base * (swell + gust) -- 330
end -- 325
function SceneFxSystem.prototype.update(self, dt, p, cam) -- 334
	if self.lastRoomKey ~= p.room.key then -- 335
		self:reset(p.room.key) -- 336
		self.prevPlayerX = p.player.x -- 337
	end -- 337
	if dt <= 0 then -- 339
		return -- 340
	end -- 340
	self.time = self.time + dt -- 343
	local key = p.room.key -- 344
	local weather = weatherOfRoom(key) -- 345
	local wind = self:windAt(self.time, key) -- 346
	if self.farFlash > 0 then -- 349
		self.farFlash = math.max(0, self.farFlash - dt * 3.8) -- 350
	end -- 350
	if key == "gate" or key == "street" or key == "s1-crossroad" or key == "escort1" then -- 352
		self.farFlashCooldown = self.farFlashCooldown - dt -- 353
		if self.farFlashCooldown <= 0 then -- 354
			self.farFlash = key == "gate" and 0.65 or 0.35 -- 355
			self.farFlashCooldown = (key == "gate" and 2.6 or 5.5) + self:rand() * 5.2 -- 356
		end -- 356
	end -- 356
	local siegeBoost = key == "gate" and p.phase == "gate-hold" and 1 + 0.7 * clamp01(p.gateTick / 2700) or 1 -- 361
	do -- 361
		local i = 0 -- 364
		while i < #self.particles do -- 364
			local pt = self.particles[i + 1] -- 365
			pt.phase = pt.phase + dt * (1.7 + pt.layer * 0.45) -- 366
			if weather == "rain" then -- 367
				pt.fx = pt.fx - dt * (0.13 + wind * 0.16) * pt.speedMul -- 368
				pt.fy = pt.fy - dt * (0.72 + pt.layer * 0.22) * pt.speedMul -- 369
			elseif weather == "siege" or weather == "embers" then -- 370
				local vx = (-0.055 - wind * 0.085) * siegeBoost + math.sin(pt.phase * 1.3) * 0.028 -- 371
				local vy = (0.045 + (pt.bright and 0.065 or -0.022)) * siegeBoost -- 372
				pt.fx = pt.fx + (vx + pt.drift * 0.4) * dt * pt.speedMul -- 373
				pt.fy = pt.fy + vy * dt * pt.speedMul -- 374
			elseif weather == "forest" then -- 375
				pt.fx = pt.fx + (-0.018 * wind + math.sin(pt.phase) * 0.022) * dt * pt.speedMul -- 376
				pt.fy = pt.fy + (pt.bright and math.cos(pt.phase * 0.8) * 0.024 or -0.042) * dt * pt.speedMul -- 377
			else -- 377
				pt.fx = pt.fx + math.sin(pt.phase * 0.7) * 0.012 * dt * pt.speedMul -- 380
				pt.fy = pt.fy + (0.016 + math.cos(pt.phase * 0.5) * 0.008) * dt * pt.speedMul -- 381
			end -- 381
			if pt.fx < -0.04 then -- 383
				pt.fx = pt.fx + 1.08 -- 383
			end -- 383
			if pt.fx > 1.04 then -- 384
				pt.fx = pt.fx - 1.08 -- 384
			end -- 384
			if pt.fy < -0.04 then -- 385
				pt.fy = pt.fy + 1.08 -- 385
			end -- 385
			if pt.fy > 1.04 then -- 386
				pt.fy = pt.fy - 1.08 -- 386
			end -- 386
			i = i + 1 -- 364
		end -- 364
	end -- 364
	if weather == "rain" then -- 390
		self.splashCooldown = self.splashCooldown - dt -- 391
		local halfSpan = cam.viewW * 0.55 / math.max(0.4, cam.ppu) -- 392
		if self.splashCooldown <= 0 and #self.splashes < MAX_SPLASHES then -- 393
			local wx = cam.x + (self:rand() - 0.5) * 2 * halfSpan -- 394
			local wy = 0 -- 395
			do -- 395
				local f = 0 -- 396
				while f < #p.room.floors do -- 396
					local fl = p.room.floors[f + 1] -- 397
					if wx >= fl.x0 and wx <= fl.x1 and fl.y > wy and self:rand() > 0.45 then -- 398
						wy = fl.y -- 399
					end -- 399
					f = f + 1 -- 396
				end -- 396
			end -- 396
			local depthRange = p.room.depth -- 402
			local depth = depthRange ~= nil and depthRange.min + self:rand() * (depthRange.max - depthRange.min) or 0 -- 403
			local ____self_splashes_1 = self.splashes -- 406
			____self_splashes_1[#____self_splashes_1 + 1] = { -- 406
				wx = wx, -- 407
				wy = wy, -- 408
				depth = depth, -- 409
				age = 0, -- 410
				maxAge = 0.22 + self:rand() * 0.12, -- 411
				scale = 0.75 + self:rand() * 0.5 -- 412
			} -- 412
			self.splashCooldown = 0.032 + self:rand() * 0.038 -- 414
		end -- 414
	end -- 414
	local w = 0 -- 417
	do -- 417
		local i = 0 -- 418
		while i < #self.splashes do -- 418
			local sp = self.splashes[i + 1] -- 419
			sp.age = sp.age + dt -- 420
			if sp.age < sp.maxAge then -- 421
				self.splashes[w + 1] = sp -- 422
				w = w + 1 -- 423
			end -- 423
			i = i + 1 -- 418
		end -- 418
	end -- 418
	__TS__ArraySetLength(self.splashes, w) -- 426
	local inGrass = false -- 429
	do -- 429
		local i = 0 -- 430
		while i < #p.room.solids do -- 430
			local s = p.room.solids[i + 1] -- 431
			if s.passable == true and p.player.x >= s.x - 8 and p.player.x <= s.x + s.w + 8 and p.player.y <= s.y + s.h + 6 then -- 432
				inGrass = true -- 433
				break -- 434
			end -- 434
			i = i + 1 -- 430
		end -- 430
	end -- 430
	local playerMove = math.abs(p.player.x - self.prevPlayerX) -- 437
	self.prevPlayerX = p.player.x -- 438
	if inGrass and (not self.prevPlayerInGrass or playerMove > 2.2 and self:rand() < dt * 7.5) then -- 439
		self:spawnGrassLeaves( -- 440
			p.player.x, -- 440
			p.player.y + 8, -- 440
			p.player.depth, -- 440
			p.player.facing, -- 440
			self.prevPlayerInGrass and 2 or 5 -- 440
		) -- 440
	end -- 440
	self.prevPlayerInGrass = inGrass -- 442
	if (key == "forest" or key == "escort3" or key == "escort4" or key == "escort5") and #self.leaves < MAX_LEAVES and self:rand() < dt * (1.8 + wind) then -- 445
		local halfSpan = cam.viewW * 0.55 / math.max(0.4, cam.ppu) -- 446
		local ____self_leaves_2 = self.leaves -- 447
		____self_leaves_2[#____self_leaves_2 + 1] = { -- 447
			wx = cam.x + (self:rand() - 0.35) * 2 * halfSpan, -- 448
			wy = 170 + self:rand() * 65, -- 449
			depth = 0, -- 450
			vx = -18 - wind * 24 - self:rand() * 14, -- 451
			vy = -20 - self:rand() * 18, -- 452
			age = 0, -- 453
			maxAge = 2.8 + self:rand() * 1.8, -- 454
			spin = self:rand() * math.pi * 2, -- 455
			frame = math.floor(self:rand() * 4) -- 456
		} -- 456
	end -- 456
	w = 0 -- 460
	do -- 460
		local i = 0 -- 461
		while i < #self.leaves do -- 461
			local lf = self.leaves[i + 1] -- 462
			lf.age = lf.age + dt -- 463
			if lf.age < lf.maxAge and lf.wy >= -4 then -- 464
				lf.spin = lf.spin + dt * 4.2 -- 465
				lf.wx = lf.wx + (lf.vx + math.sin(lf.spin) * 16) * dt -- 466
				lf.wy = lf.wy + (lf.vy + math.cos(lf.spin * 0.8) * 6) * dt -- 467
				self.leaves[w + 1] = lf -- 468
				w = w + 1 -- 469
			end -- 469
			i = i + 1 -- 461
		end -- 461
	end -- 461
	__TS__ArraySetLength(self.leaves, w) -- 472
	local anchors = roomAnchors(key) -- 475
	self.emberCooldown = self.emberCooldown - dt -- 476
	if self.emberCooldown <= 0 and #anchors > 0 and #self.brazierEmbers < MAX_BRAZIER_EMBERS then -- 477
		do -- 477
			local i = 0 -- 478
			while i < #anchors do -- 478
				do -- 478
					local an = anchors[i + 1] -- 479
					if an.kind ~= "brazier" then -- 480
						goto __continue71 -- 481
					end -- 481
					local wx = p.ox + an.offsetX -- 483
					if math.abs(wx - cam.x) > 520 then -- 484
						goto __continue71 -- 485
					end -- 485
					local ____self_brazierEmbers_3 = self.brazierEmbers -- 487
					____self_brazierEmbers_3[#____self_brazierEmbers_3 + 1] = { -- 487
						wx = wx + (self:rand() - 0.5) * 12, -- 488
						wy = an.y + 24, -- 489
						depth = an.depth, -- 490
						vx = -wind * 18 + (self:rand() - 0.5) * 18, -- 491
						vy = 28 + self:rand() * 34, -- 492
						age = 0, -- 493
						maxAge = 0.9 + self:rand() * 0.9, -- 494
						size = 1.4 + self:rand() * 1.4 -- 495
					} -- 495
				end -- 495
				::__continue71:: -- 495
				i = i + 1 -- 478
			end -- 478
		end -- 478
		self.emberCooldown = 0.14 -- 498
	end -- 498
	w = 0 -- 500
	do -- 500
		local i = 0 -- 501
		while i < #self.brazierEmbers do -- 501
			local em = self.brazierEmbers[i + 1] -- 502
			em.age = em.age + dt -- 503
			if em.age < em.maxAge then -- 504
				em.wx = em.wx + (em.vx + math.sin(self.time * 5 + i) * 12) * dt -- 505
				em.wy = em.wy + em.vy * dt -- 506
				self.brazierEmbers[w + 1] = em -- 507
				w = w + 1 -- 508
			end -- 508
			i = i + 1 -- 501
		end -- 501
	end -- 501
	__TS__ArraySetLength(self.brazierEmbers, w) -- 511
end -- 334
function SceneFxSystem.prototype.spawnGrassLeaves(self, wx, wy, depth, facing, count) -- 514
	do -- 514
		local i = 0 -- 515
		while i < count and #self.leaves < MAX_LEAVES do -- 515
			local ____self_leaves_4 = self.leaves -- 516
			____self_leaves_4[#____self_leaves_4 + 1] = { -- 516
				wx = wx + (self:rand() - 0.5) * 18, -- 517
				wy = wy + self:rand() * 10, -- 518
				depth = depth, -- 519
				vx = -facing * (16 + self:rand() * 28) + (self:rand() - 0.5) * 26, -- 520
				vy = 36 + self:rand() * 38, -- 521
				age = 0, -- 522
				maxAge = 0.65 + self:rand() * 0.45, -- 523
				spin = self:rand() * math.pi * 2, -- 524
				frame = math.floor(self:rand() * 4) -- 525
			} -- 525
			i = i + 1 -- 515
		end -- 515
	end -- 515
end -- 514
function SceneFxSystem.prototype.drawBackdropFx(self, bgDraw, bgGlow, backdropArt, p, cam) -- 531
	local key = p.room.key -- 538
	local w = cam.viewW -- 539
	local h = cam.viewH -- 540
	local t = self.time -- 541
	local wind = self:windAt(t, key) -- 542
	local theme = themeOf(key) -- 543
	if isOutdoorRoom(key) and theme.showMoon then -- 546
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 547
		local my = h * theme.moonYFrac -- 548
		local pulse = 0.88 + 0.12 * math.sin(t * 1.15) -- 549
		fillRadialGlow( -- 550
			bgGlow, -- 550
			mx, -- 550
			my, -- 550
			h * 0.24 * pulse, -- 550
			h * 0.2 * pulse, -- 550
			Color( -- 551
				138, -- 551
				174, -- 551
				206, -- 551
				math.floor(28 * pulse + 0.5) -- 551
			), -- 551
			Color(18, 28, 46, 0), -- 551
			18 -- 551
		) -- 551
		local cloudA = (t * (7 + wind * 5) + cam.x * 0.05) % (w + 520) - 260 -- 554
		local cloudB = (t * (12 + wind * 8) + cam.x * 0.09 + w * 0.48) % (w + 520) - 260 -- 555
		backdropArt:tryPlace( -- 556
			"ink_mist_curve", -- 556
			"sfx_cloud_a", -- 556
			w - cloudA, -- 556
			h * 0.82, -- 556
			540, -- 556
			84, -- 556
			{ -- 556
				color = Color(76, 98, 128, 255), -- 557
				opacity = 0.14, -- 557
				layer = 6 -- 557
			} -- 557
		) -- 557
		backdropArt:tryPlace( -- 559
			"ink_mist_curve", -- 559
			"sfx_cloud_b", -- 559
			w - cloudB, -- 559
			h * 0.72, -- 559
			460, -- 559
			72, -- 559
			{ -- 559
				color = Color(58, 76, 104, 255), -- 560
				opacity = 0.11, -- 560
				layer = 6, -- 560
				facing = -1 -- 560
			} -- 560
		) -- 560
	end -- 560
	local backRoadY = cam:sy(0, p.room.depth ~= nil and p.room.depth.max or 0) -- 565
	if hasWarHorizon(key) then -- 566
		if key ~= "gatepath" and key ~= "escort1" then -- 567
			local firePulse = 0.78 + 0.22 * math.sin(t * 2.6 + math.sin(t * 1.1)) -- 568
			local glowA = key == "gate" and 48 or 30 -- 569
			fillRadialGlow( -- 570
				bgGlow, -- 570
				w * 0.16, -- 570
				h * 0.28, -- 570
				w * 0.38, -- 570
				h * 0.34, -- 570
				Color( -- 571
					186, -- 571
					62, -- 571
					34, -- 571
					math.floor(glowA * firePulse + 0.5) -- 571
				), -- 571
				Color(160, 44, 24, 0), -- 571
				16 -- 571
			) -- 571
		end -- 571
		if self.farFlash > 0.02 then -- 573
			local fa = math.floor(36 * self.farFlash + 0.5) -- 574
			fillRadialGlow( -- 575
				bgGlow, -- 575
				w * 0.24, -- 575
				h * 0.46, -- 575
				w * 0.48, -- 575
				h * 0.42, -- 575
				Color(242, 168, 114, fa), -- 576
				Color(186, 72, 44, 0), -- 576
				16 -- 576
			) -- 576
		end -- 576
	end -- 576
	if not isEscortWorldRoom(key) then -- 581
		local mistSpeed = 10 + wind * 12 -- 582
		local m1 = (t * mistSpeed + cam.x * 0.14) % (w + 640) - 320 -- 583
		local m2 = (t * mistSpeed * 0.65 + cam.x * 0.08 + w * 0.52) % (w + 640) - 320 -- 584
		local mistTint = key == "gate" and Color(94, 52, 54, 255) or (key == "forest" and Color(68, 108, 102, 255) or (key == "tower" and Color(148, 126, 98, 255) or Color(66, 86, 112, 255))) -- 585
		local mistOp = (key == "forest" or key == "outside" or key == "village") and 0.2 or 0.14 -- 588
		backdropArt:tryPlace( -- 589
			"ink_mist_curve", -- 589
			"sfx_ground_mist_1", -- 589
			w - m1, -- 589
			backRoadY + h * 0.06, -- 589
			660, -- 589
			124, -- 589
			{color = mistTint, opacity = mistOp, layer = 7} -- 589
		) -- 589
		backdropArt:tryPlace( -- 592
			"ink_mist_curve", -- 592
			"sfx_ground_mist_2", -- 592
			w - m2, -- 592
			backRoadY + h * 0.12, -- 592
			580, -- 592
			108, -- 592
			{color = mistTint, opacity = mistOp * 0.8, layer = 7, facing = -1} -- 592
		) -- 592
	end -- 592
	local shafts = lightShaftsForRoom(key) -- 598
	do -- 598
		local i = 0 -- 599
		while i < #shafts do -- 599
			do -- 599
				local sh = shafts[i + 1] -- 600
				local topX = cam:sx(p.ox + sh.x0) -- 601
				local botX = topX + cam:len(sh.botShift) -- 602
				if topX + cam:len(sh.topW + sh.botW) < -80 or botX - cam:len(sh.botW) > w + 80 then -- 603
					goto __continue87 -- 604
				end -- 604
				local pulse = 0.84 + 0.16 * math.sin(t * 0.95 + i * 1.7) -- 606
				local tw = cam:len(sh.topW) * 0.5 -- 607
				local bw = cam:len(sh.botW) * 0.5 -- 608
				local yTop = h + 16 -- 609
				local yMid = h * 0.54 -- 610
				local yBot = backRoadY - 4 -- 611
				local midX = (topX + botX) * 0.5 -- 612
				local mw = (tw + bw) * 0.5 -- 613
				local col = sh.color -- 614
				local aMid = math.floor(255 * sh.alpha * pulse + 0.5) -- 615
				local aTop = math.floor(aMid * 0.45 + 0.5) -- 616
				fillGradQuad( -- 617
					bgGlow, -- 618
					topX - tw, -- 619
					yTop, -- 619
					Color(col.r, col.g, col.b, aTop), -- 619
					topX + tw, -- 620
					yTop, -- 620
					Color(col.r, col.g, col.b, aTop), -- 620
					midX + mw, -- 621
					yMid, -- 621
					Color(col.r, col.g, col.b, aMid), -- 621
					midX - mw, -- 622
					yMid, -- 622
					Color(col.r, col.g, col.b, aMid) -- 622
				) -- 622
				fillGradQuad( -- 624
					bgGlow, -- 625
					midX - mw, -- 626
					yMid, -- 626
					Color(col.r, col.g, col.b, aMid), -- 626
					midX + mw, -- 627
					yMid, -- 627
					Color(col.r, col.g, col.b, aMid), -- 627
					botX + bw, -- 628
					yBot, -- 628
					Color(col.r, col.g, col.b, 0), -- 628
					botX - bw, -- 629
					yBot, -- 629
					Color(col.r, col.g, col.b, 0) -- 629
				) -- 629
				do -- 629
					local d = 0 -- 633
					while d < 6 do -- 633
						local u = (t * 0.08 + d * 0.167 + i * 0.23) % 1 -- 634
						local px = topX + (botX - topX) * u + math.sin(t * 1.2 + d * 2.1) * (tw + (bw - tw) * u) * 0.55 -- 635
						local py = yTop + (yBot - yTop) * u -- 636
						local fade = math.sin(u * math.pi) -- 637
						bgGlow:drawDot( -- 638
							Vec2(px, py), -- 638
							1.4 + d % 2 * 0.7, -- 638
							Color( -- 638
								col.r, -- 638
								col.g, -- 638
								col.b, -- 638
								math.floor(135 * fade * pulse + 0.5) -- 638
							) -- 638
						) -- 638
						d = d + 1 -- 633
					end -- 633
				end -- 633
			end -- 633
			::__continue87:: -- 633
			i = i + 1 -- 599
		end -- 599
	end -- 599
end -- 531
function SceneFxSystem.prototype.drawWorldFx(self, fgDraw, fgGlow, worldArt, p, cam) -- 644
	local key = p.room.key -- 651
	local t = self.time -- 652
	local wind = self:windAt(t, key) -- 653
	local w = cam.viewW -- 654
	local depthEnabled = p.room.depth ~= nil -- 655
	local anchors = roomAnchors(key) -- 658
	local flameFrame = math.floor(t * 11) % 4 -- 659
	local flagFrame = math.floor(t * (5.5 + wind * 3.5)) % 4 -- 660
	do -- 660
		local i = 0 -- 662
		while i < #anchors do -- 662
			do -- 662
				local an = anchors[i + 1] -- 663
				local wx = p.ox + an.offsetX -- 664
				local sx = cam:sx(wx) -- 665
				if sx < -120 or sx > w + 120 then -- 666
					goto __continue93 -- 667
				end -- 667
				local depth = depthEnabled and an.depth or 0 -- 669
				local dScale = cam:depthScale(depth, depthEnabled) -- 670
				local sy = cam:sy(an.y, depth) -- 671
				if an.kind == "brazier" then -- 673
					local pulse = 0.84 + 0.16 * math.sin(t * 8.4 + i * 2.1) -- 674
					local potLayer = depthEnabled and depthOrder(depth, -1) or 2 -- 675
					local potW = cam:len(26) * dScale -- 676
					local potH = cam:len(30) * dScale -- 677
					local fSize = cam:len(24) * dScale -- 678
					worldArt:tryPlace( -- 681
						"dp_shadow_contact", -- 681
						"sfx_brazier_sh_" .. tostring(i), -- 681
						sx, -- 681
						sy + 1, -- 681
						potW, -- 681
						cam:len(7) * dScale, -- 681
						{layer = potLayer - 1, opacity = 0.76} -- 681
					) -- 681
					if not worldArt:tryPlace( -- 684
						"dp_brazier", -- 684
						"sfx_brazier_pot_" .. tostring(i), -- 684
						sx, -- 684
						sy, -- 684
						potW, -- 684
						potH, -- 684
						{layer = potLayer} -- 684
					) then -- 684
						fgDraw:drawPolygon( -- 687
							{ -- 687
								Vec2( -- 688
									sx - cam:len(11) * dScale, -- 688
									sy + cam:len(13) * dScale -- 688
								), -- 688
								Vec2( -- 689
									sx + cam:len(11) * dScale, -- 689
									sy + cam:len(13) * dScale -- 689
								), -- 689
								Vec2( -- 690
									sx + cam:len(7) * dScale, -- 690
									sy + cam:len(4) * dScale -- 690
								), -- 690
								Vec2( -- 691
									sx - cam:len(7) * dScale, -- 691
									sy + cam:len(4) * dScale -- 691
								) -- 691
							}, -- 691
							Color(26, 22, 24, 245), -- 692
							1, -- 692
							Color(84, 58, 46, 175) -- 692
						) -- 692
					end -- 692
					if not worldArt:tryPlacePath( -- 696
						SFX_FLAME_CLIPS[(flameFrame + i) % 4 + 1], -- 697
						"sfx_brazier_flame_" .. tostring(i), -- 698
						sx, -- 699
						sy + cam:len(16) * dScale, -- 700
						fSize, -- 701
						fSize * 1.15, -- 702
						{anchorX = 0.5, anchorY = 0, preserveAspect = true, layer = potLayer + 1} -- 703
					) then -- 703
						fgGlow:drawEllipse( -- 705
							Vec2( -- 705
								sx, -- 705
								sy + cam:len(22) * dScale -- 705
							), -- 705
							cam:len(6) * dScale, -- 705
							cam:len(10 * pulse) * dScale, -- 705
							Color(246, 132, 46, 195) -- 705
						) -- 705
					end -- 705
					fillRadialGlow( -- 709
						fgGlow, -- 709
						sx, -- 709
						sy + cam:len(24) * dScale, -- 709
						cam:len(64 * pulse), -- 709
						cam:len(48 * pulse), -- 709
						Color( -- 710
							238, -- 710
							126, -- 710
							48, -- 710
							math.floor(70 * pulse + 0.5) -- 710
						), -- 710
						Color(210, 76, 26, 0), -- 710
						16 -- 710
					) -- 710
					fillRadialGlow( -- 711
						fgGlow, -- 711
						sx, -- 711
						sy + cam:len(2), -- 711
						cam:len(44 * pulse), -- 711
						cam:len(11 * pulse), -- 711
						Color( -- 712
							246, -- 712
							152, -- 712
							72, -- 712
							math.floor(44 * pulse + 0.5) -- 712
						), -- 712
						Color(220, 96, 36, 0), -- 712
						14 -- 712
					) -- 712
				elseif an.kind == "banner" then -- 713
					local poleBot = cam:sy(0, depth) -- 715
					local poleTop = sy + cam:len(16) * dScale -- 716
					local bannerLayer = depthEnabled and depthOrder(depth, 0) or 2 -- 717
					worldArt:tryPlace( -- 718
						"dp_shadow_contact", -- 718
						"sfx_banner_sh_" .. tostring(i), -- 718
						sx, -- 718
						poleBot + 1, -- 718
						cam:len(14) * dScale, -- 718
						cam:len(5) * dScale, -- 718
						{layer = bannerLayer - 1, opacity = 0.68} -- 718
					) -- 718
					fgDraw:drawSegment( -- 721
						Vec2(sx, poleBot), -- 721
						Vec2(sx, poleTop), -- 721
						math.max( -- 721
							1.5, -- 721
							cam:len(2) * dScale -- 721
						), -- 721
						Color(48, 38, 32, 230) -- 721
					) -- 721
					fgDraw:drawPolygon( -- 722
						{ -- 722
							Vec2( -- 723
								sx - cam:len(1.8) * dScale, -- 723
								poleTop -- 723
							), -- 723
							Vec2( -- 724
								sx + cam:len(1.8) * dScale, -- 724
								poleTop -- 724
							), -- 724
							Vec2( -- 725
								sx, -- 725
								poleTop + cam:len(6) * dScale -- 725
							) -- 725
						}, -- 725
						Color(136, 146, 158, 225) -- 726
					) -- 726
					worldArt:tryPlacePath( -- 727
						SFX_FLAG_CLIPS[(flagFrame + i) % 4 + 1], -- 728
						"sfx_banner_" .. tostring(i), -- 729
						sx + cam:len(0.8) * dScale, -- 730
						sy + cam:len(9) * dScale, -- 731
						cam:len(34) * dScale, -- 732
						cam:len(22) * dScale, -- 733
						{ -- 734
							anchorX = 0.08, -- 735
							anchorY = 0.5, -- 736
							preserveAspect = true, -- 737
							facing = an.facing or 1, -- 738
							angle = math.sin(t * 2.8 + i) * wind * 2.8, -- 739
							opacity = 0.9, -- 740
							layer = bannerLayer -- 741
						} -- 741
					) -- 741
				end -- 741
			end -- 741
			::__continue93:: -- 741
			i = i + 1 -- 662
		end -- 662
	end -- 662
	local lanternFrame = math.floor(t * 7.5) % 2 -- 748
	local markLayer = depthEnabled and depthOrder(0, 6) or 6 -- 749
	do -- 749
		local i = 0 -- 750
		while i < #p.room.marks do -- 750
			do -- 750
				local m = p.room.marks[i + 1] -- 751
				if m.kind ~= 6 then -- 752
					goto __continue100 -- 753
				end -- 753
				local mx = cam:sx(m.x + 13) -- 755
				if mx < -80 or mx > w + 80 then -- 756
					goto __continue100 -- 757
				end -- 757
				local my = cam:sy(m.y + 40) -- 759
				local swayX = math.sin(t * 2.3 + m.x * 0.02) * wind * cam:len(2.4) -- 760
				local flicker = 0.86 + 0.14 * math.sin(t * 9.2 + i * 3.1) -- 761
				worldArt:tryPlacePath( -- 762
					SFX_LANTERN_FLAME_CLIPS[lanternFrame + 1], -- 763
					"sfx_mark_flame_" .. tostring(i), -- 764
					mx + swayX, -- 765
					my, -- 766
					cam:len(16), -- 767
					cam:len(18), -- 768
					{ -- 769
						anchorX = 0.5, -- 769
						anchorY = 0.5, -- 769
						preserveAspect = true, -- 769
						opacity = 0.88 * flicker, -- 769
						layer = markLayer -- 769
					} -- 769
				) -- 769
				local gy = cam:sy(m.y) -- 772
				fillRadialGlow( -- 773
					fgGlow, -- 773
					mx + swayX * 0.4, -- 773
					gy + cam:len(2), -- 773
					cam:len(38 * flicker), -- 773
					cam:len(10 * flicker), -- 773
					Color( -- 774
						246, -- 774
						186, -- 774
						104, -- 774
						math.floor(42 * flicker + 0.5) -- 774
					), -- 774
					Color(224, 152, 74, 0), -- 774
					14 -- 774
				) -- 774
			end -- 774
			::__continue100:: -- 774
			i = i + 1 -- 750
		end -- 750
	end -- 750
	do -- 750
		local i = 0 -- 778
		while i < #self.brazierEmbers do -- 778
			local em = self.brazierEmbers[i + 1] -- 779
			local k = 1 - em.age / em.maxAge -- 780
			local ex = cam:sx(em.wx) -- 781
			local ey = cam:sy(em.wy, depthEnabled and em.depth or 0) -- 782
			fgGlow:drawDot( -- 783
				Vec2(ex, ey), -- 783
				em.size * k, -- 783
				Color( -- 783
					255, -- 783
					168, -- 783
					76, -- 783
					math.floor(230 * k + 0.5) -- 783
				) -- 783
			) -- 783
			fgGlow:drawDot( -- 784
				Vec2(ex, ey), -- 784
				em.size * 2.4 * k, -- 784
				Color( -- 784
					228, -- 784
					92, -- 784
					36, -- 784
					math.floor(72 * k + 0.5) -- 784
				) -- 784
			) -- 784
			i = i + 1 -- 778
		end -- 778
	end -- 778
	do -- 778
		local i = 0 -- 788
		while i < #p.room.solids do -- 788
			do -- 788
				local s = p.room.solids[i + 1] -- 789
				if s.passable ~= true then -- 790
					goto __continue106 -- 791
				end -- 791
				local x0 = cam:sx(s.x) -- 793
				local x1 = cam:sx(s.x + s.w) -- 794
				if x1 < -30 or x0 > w + 30 then -- 795
					goto __continue106 -- 796
				end -- 796
				local y0 = cam:sy(s.y) -- 798
				local sw = x1 - x0 -- 799
				local sh = cam:len(s.h) -- 800
				local blades = math.max( -- 801
					7, -- 801
					math.min( -- 801
						20, -- 801
						math.floor(s.w / 9) -- 801
					) -- 801
				) -- 801
				do -- 801
					local b = 0 -- 802
					while b < blades do -- 802
						local u = (b + 0.5) / blades -- 803
						local bwx = s.x + s.w * u -- 804
						local bx = x0 + sw * u -- 805
						local dxPlayer = bwx - p.player.x -- 806
						local near = math.abs(dxPlayer) < 26 and p.player.y < s.y + s.h + 10 -- 807
						local partPush = near and (dxPlayer >= 0 and 1 or -1) * (1 - math.abs(dxPlayer) / 26) * cam:len(10) or 0 -- 808
						local wave = math.sin(t * (2.6 + wind) + bwx * 0.08) * cam:len(3.4 * wind) + partPush -- 809
						local bh = sh * (0.95 + 0.45 * hash01(b * 13.7 + s.x)) -- 810
						local col = b % 2 == 0 and Color(28, 66, 56, 175) or Color(46, 94, 78, 165) -- 811
						fgDraw:drawSegment( -- 812
							Vec2(bx, y0), -- 812
							Vec2(bx + wave, y0 + bh), -- 812
							math.max( -- 812
								1.2, -- 812
								cam:len(1.6) -- 812
							), -- 812
							col -- 812
						) -- 812
						b = b + 1 -- 802
					end -- 802
				end -- 802
			end -- 802
			::__continue106:: -- 802
			i = i + 1 -- 788
		end -- 788
	end -- 788
	do -- 788
		local i = 0 -- 817
		while i < #self.leaves do -- 817
			local lf = self.leaves[i + 1] -- 818
			local k = 1 - lf.age / lf.maxAge -- 819
			local lx = cam:sx(lf.wx) -- 820
			local ly = cam:sy(lf.wy, depthEnabled and lf.depth or 0) -- 821
			local sz = cam:len(9) * cam:depthScale(lf.depth, depthEnabled) -- 822
			local leafLayer = depthEnabled and depthOrder(lf.depth, 5) or 7 -- 823
			if not worldArt:tryPlacePath( -- 824
				SFX_LEAF_CLIPS[lf.frame % 2 + 1], -- 825
				"sfx_leaf_" .. tostring(i), -- 826
				lx, -- 827
				ly, -- 828
				sz, -- 829
				sz, -- 830
				{ -- 831
					anchorX = 0.5, -- 831
					anchorY = 0.5, -- 831
					angle = lf.spin * 45, -- 831
					opacity = math.min(1, k * 1.8) * 0.85, -- 831
					layer = leafLayer -- 831
				} -- 831
			) then -- 831
				fgDraw:drawEllipse( -- 833
					Vec2(lx, ly), -- 833
					2.8, -- 833
					1.3, -- 833
					Color( -- 833
						76, -- 833
						118, -- 833
						92, -- 833
						math.floor(185 * k + 0.5) -- 833
					) -- 833
				) -- 833
			end -- 833
			i = i + 1 -- 817
		end -- 817
	end -- 817
	do -- 817
		local i = 0 -- 838
		while i < #self.splashes do -- 838
			do -- 838
				local sp = self.splashes[i + 1] -- 839
				local prog = clamp01(sp.age / sp.maxAge) -- 840
				local sx = cam:sx(sp.wx) -- 841
				if sx < -20 or sx > w + 20 then -- 842
					goto __continue115 -- 843
				end -- 843
				local sy = cam:sy(sp.wy + 1, depthEnabled and sp.depth or 0) -- 845
				local sz = cam:len(10 * sp.scale) * cam:depthScale(sp.depth, depthEnabled) -- 846
				local frame = math.min( -- 847
					1, -- 847
					math.floor(prog * 2) -- 847
				) -- 847
				local splashLayer = depthEnabled and depthOrder(sp.depth, 1) or 7 -- 848
				if not worldArt:tryPlacePath( -- 849
					SFX_RAIN_SPLASH_CLIPS[frame + 1], -- 850
					"sfx_rain_splash_" .. tostring(i), -- 851
					sx, -- 852
					sy, -- 853
					sz, -- 854
					sz * 0.65, -- 855
					{ -- 856
						anchorX = 0.5, -- 856
						anchorY = 0, -- 856
						preserveAspect = true, -- 856
						opacity = (1 - prog) * 0.62, -- 856
						layer = splashLayer -- 856
					} -- 856
				) then -- 856
					local r = cam:len(3 + prog * 5) * sp.scale -- 858
					fgGlow:drawEllipse( -- 859
						Vec2(sx, sy), -- 859
						r, -- 859
						r * 0.28, -- 859
						Color( -- 859
							168, -- 859
							196, -- 859
							218, -- 859
							math.floor(110 * (1 - prog) + 0.5) -- 859
						) -- 859
					) -- 859
				end -- 859
			end -- 859
			::__continue115:: -- 859
			i = i + 1 -- 838
		end -- 838
	end -- 838
end -- 644
function SceneFxSystem.prototype.drawForegroundWeather(self, fgGlow, p, cam, w, h) -- 865
	local key = p.room.key -- 872
	local weather = weatherOfRoom(key) -- 873
	local wind = self:windAt(self.time, key) -- 874
	local camParallaxBase = cam.x * 0.00045 -- 875
	do -- 875
		local i = 0 -- 877
		while i < #self.particles do -- 877
			local pt = self.particles[i + 1] -- 878
			local parallax = pt.layer == 0 and 0.35 or (pt.layer == 1 and 0.85 or 1.55) -- 879
			local nx = (pt.fx - camParallaxBase * parallax) % 1 -- 880
			if nx < 0 then -- 881
				nx = nx + 1 -- 882
			end -- 882
			local x = nx * w -- 884
			local y = pt.fy * h -- 885
			local tw = 0.55 + 0.45 * math.sin(pt.phase) -- 886
			local layerAlpha = pt.layer == 0 and 0.45 or (pt.layer == 1 and 0.78 or 1) -- 887
			if weather == "rain" then -- 889
				local len = (11 + pt.layer * 8) * pt.speedMul * 0.75 -- 890
				local tilt = (3.5 + wind * 5.2) * (0.7 + pt.layer * 0.25) -- 891
				local alpha = math.floor((46 + pt.layer * 24) * tw * layerAlpha + 0.5) -- 892
				fgGlow:drawSegment( -- 893
					Vec2(x, y), -- 894
					Vec2(x + tilt, y + len), -- 895
					pt.layer == 2 and 1.15 or 0.8, -- 896
					Color(168, 194, 216, alpha) -- 897
				) -- 897
			elseif weather == "siege" or weather == "embers" then -- 899
				if pt.bright then -- 900
					local col = weather == "siege" and Color( -- 901
						255, -- 901
						134, -- 901
						62, -- 901
						math.floor(168 * tw * layerAlpha + 0.5) -- 901
					) or Color( -- 902
						242, -- 902
						160, -- 902
						82, -- 902
						math.floor(132 * tw * layerAlpha + 0.5) -- 902
					) -- 902
					local tailX = x + (2.5 + wind * 4.2) * (0.5 + pt.layer * 0.3) -- 903
					local tailY = y - 2.8 * (0.6 + pt.layer * 0.25) -- 904
					fgGlow:drawSegment( -- 905
						Vec2(tailX, tailY), -- 905
						Vec2(x, y), -- 905
						pt.size * 0.38, -- 905
						col -- 905
					) -- 905
					fgGlow:drawDot( -- 906
						Vec2(x, y), -- 906
						pt.size * 0.54, -- 906
						Color( -- 906
							255, -- 906
							214, -- 906
							138, -- 906
							math.floor(145 * tw * layerAlpha + 0.5) -- 906
						) -- 906
					) -- 906
				else -- 906
					fgGlow:drawDot( -- 909
						Vec2(x, y), -- 909
						pt.size * 0.68, -- 909
						Color( -- 909
							142, -- 909
							148, -- 909
							162, -- 909
							math.floor(52 * tw * layerAlpha + 0.5) -- 909
						) -- 909
					) -- 909
				end -- 909
			elseif weather == "forest" then -- 911
				if pt.bright and pt.layer >= 1 then -- 912
					local col = i % 3 == 0 and PALETTE.amberCore or PALETTE.emerald -- 914
					local r = pt.size * (0.85 + 0.35 * tw) -- 915
					fgGlow:drawDot( -- 916
						Vec2(x, y), -- 916
						r, -- 916
						toColor(col, 155 * tw * layerAlpha) -- 916
					) -- 916
					fgGlow:drawDot( -- 917
						Vec2(x, y), -- 917
						r * 2.8, -- 917
						toColor(col, 32 * tw * layerAlpha) -- 917
					) -- 917
				else -- 917
					fgGlow:drawDot( -- 919
						Vec2(x, y), -- 919
						pt.size * 0.72, -- 919
						Color( -- 919
							128, -- 919
							164, -- 919
							152, -- 919
							math.floor(62 * tw * layerAlpha + 0.5) -- 919
						) -- 919
					) -- 919
				end -- 919
			else -- 919
				local col = pt.bright and PALETTE.amberCore or PALETTE.amber -- 923
				fgGlow:drawDot( -- 924
					Vec2(x, y), -- 924
					pt.size * 0.85, -- 924
					toColor(col, 128 * tw * layerAlpha) -- 924
				) -- 924
				if pt.layer == 2 and pt.bright then -- 925
					fgGlow:drawDot( -- 926
						Vec2(x, y), -- 926
						pt.size * 2.4, -- 926
						toColor(PALETTE.amber, 26 * tw) -- 926
					) -- 926
				end -- 926
			end -- 926
			i = i + 1 -- 877
		end -- 877
	end -- 877
end -- 865
function SceneFxSystem.prototype.drawTitleAtmosphere(self, bgGlow, fgGlow, backdropArt, worldArt, w, h, time) -- 933
	local artW = math.max(w, h * 16 / 9) -- 943
	local artH = artW * 9 / 16 -- 944
	local ox = (w - artW) * 0.5 -- 945
	local oy = (h - artH) * 0.5 -- 946
	local wind = self:windAt(time, "outside") -- 947
	local moonX = ox + artW * 0.833 -- 950
	local moonY = oy + artH * 0.915 -- 951
	local moonPulse = 0.88 + 0.12 * math.sin(time * 0.9) -- 952
	fillRadialGlow( -- 953
		bgGlow, -- 953
		moonX, -- 953
		moonY, -- 953
		artH * 0.22 * moonPulse, -- 953
		artH * 0.22 * moonPulse, -- 953
		Color( -- 954
			176, -- 954
			206, -- 954
			232, -- 954
			math.floor(42 * moonPulse + 0.5) -- 954
		), -- 954
		Color(24, 38, 60, 0), -- 954
		20 -- 954
	) -- 954
	local cloudX = time * 9 % (w + 540) - 270 -- 957
	backdropArt:tryPlace( -- 958
		"ink_mist_curve", -- 958
		"title_cloud_a", -- 958
		w - cloudX, -- 958
		oy + artH * 0.84, -- 958
		540, -- 958
		82, -- 958
		{ -- 958
			color = Color(86, 108, 138, 255), -- 959
			opacity = 0.16, -- 959
			layer = 4 -- 959
		} -- 959
	) -- 959
	local mist1 = time * 13 % (w + 680) - 340 -- 961
	local mist2 = (time * 8 + w * 0.45) % (w + 680) - 340 -- 962
	backdropArt:tryPlace( -- 963
		"ink_mist_curve", -- 963
		"title_valley_mist_1", -- 963
		w - mist1, -- 963
		oy + artH * 0.42, -- 963
		680, -- 963
		136, -- 963
		{ -- 963
			color = Color(74, 96, 126, 255), -- 964
			opacity = 0.22, -- 964
			layer = 4 -- 964
		} -- 964
	) -- 964
	backdropArt:tryPlace( -- 966
		"ink_mist_curve", -- 966
		"title_valley_mist_2", -- 966
		w - mist2, -- 966
		oy + artH * 0.52, -- 966
		600, -- 966
		116, -- 966
		{ -- 966
			color = Color(62, 82, 110, 255), -- 967
			opacity = 0.16, -- 967
			layer = 4, -- 967
			facing = -1 -- 967
		} -- 967
	) -- 967
	local doorX = ox + artW * 0.902 -- 971
	local doorY = oy + artH * 0.684 -- 972
	local lampPulse = 0.84 + 0.16 * math.sin(time * 2.7 + math.sin(time * 1.1)) -- 973
	fillRadialGlow( -- 974
		bgGlow, -- 974
		doorX, -- 974
		doorY, -- 974
		artH * 0.14 * lampPulse, -- 974
		artH * 0.13 * lampPulse, -- 974
		Color( -- 975
			255, -- 975
			202, -- 975
			114, -- 975
			math.floor(108 * lampPulse + 0.5) -- 975
		), -- 975
		Color(236, 152, 62, 0), -- 975
		18 -- 975
	) -- 975
	fillRadialGlow( -- 976
		bgGlow, -- 976
		doorX, -- 976
		doorY, -- 976
		artH * 0.045 * lampPulse, -- 976
		artH * 0.045 * lampPulse, -- 976
		Color( -- 977
			255, -- 977
			240, -- 977
			192, -- 977
			math.floor(168 * lampPulse + 0.5) -- 977
		), -- 977
		Color(255, 196, 102, 0), -- 977
		12 -- 977
	) -- 977
	local winX = ox + artW * 0.893 -- 979
	local winY = oy + artH * 0.778 -- 980
	fillRadialGlow( -- 981
		bgGlow, -- 981
		winX, -- 981
		winY, -- 981
		artH * 0.045 * lampPulse, -- 981
		artH * 0.045 * lampPulse, -- 981
		Color( -- 982
			255, -- 982
			212, -- 982
			128, -- 982
			math.floor(92 * lampPulse + 0.5) -- 982
		), -- 982
		Color(238, 168, 72, 0), -- 982
		12 -- 982
	) -- 982
	do -- 982
		local i = 0 -- 985
		while i < 42 do -- 985
			local speed = 0.014 + i % 5 * 0.005 -- 986
			local px = (1 - (hash01(i * 17.3) + time * speed * (0.7 + wind * 0.5)) % 1) * w -- 987
			local py = (hash01(i * 31.1) + time * (0.012 + i % 3 * 0.006)) % 1 * h -- 988
			local tw = 0.45 + 0.55 * math.sin(time * 2.1 + i * 1.4) -- 989
			local isWarm = i % 3 == 0 and px > w * 0.45 -- 990
			local col = isWarm and PALETTE.amberCore or PALETTE.jadeMist -- 991
			local r = 1 + i % 3 * 0.55 -- 992
			fgGlow:drawDot( -- 993
				Vec2(px, py), -- 993
				r, -- 993
				toColor(col, (isWarm and 132 or 76) * tw) -- 993
			) -- 993
			i = i + 1 -- 985
		end -- 985
	end -- 985
end -- 933
return ____exports -- 933
