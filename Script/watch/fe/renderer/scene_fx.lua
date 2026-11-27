-- [ts]: scene_fx.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 13
local Color = ____Dora.Color -- 13
local Vec2 = ____Dora.Vec2 -- 13
local ____theme = require("Script.watch.fe.theme") -- 18
local PALETTE = ____theme.PALETTE -- 18
local fillGradQuad = ____theme.fillGradQuad -- 18
local fillRadialGlow = ____theme.fillRadialGlow -- 18
local themeOf = ____theme.themeOf -- 18
local toColor = ____theme.toColor -- 18
local PARTICLE_COUNT = 92 -- 82
local MAX_SPLASHES = 24 -- 83
local MAX_LEAVES = 32 -- 84
local MAX_BRAZIER_EMBERS = 36 -- 85
local SFX_FLAME_CLIPS = {"assets/art/vfx_ming_fx.clip|flame_0", "assets/art/vfx_ming_fx.clip|flame_1", "assets/art/vfx_ming_fx.clip|flame_2", "assets/art/vfx_ming_fx.clip|flame_3"} -- 87
local SFX_FLAG_CLIPS = {"assets/art/vfx_ming_fx.clip|flag_red_0", "assets/art/vfx_ming_fx.clip|flag_red_1", "assets/art/vfx_ming_fx.clip|flag_red_2", "assets/art/vfx_ming_fx.clip|flag_red_3"} -- 93
local SFX_LANTERN_FLAME_CLIPS = {"assets/art/vfx_ming_fx.clip|lantern_flame_0", "assets/art/vfx_ming_fx.clip|lantern_flame_1"} -- 99
local SFX_LEAF_CLIPS = {"assets/art/vfx_ming_fx.clip|leaf_0", "assets/art/vfx_ming_fx.clip|leaf_1"} -- 103
local SFX_RAIN_SPLASH_CLIPS = {"assets/art/vfx_ming_fx.clip|rain_splash_0", "assets/art/vfx_ming_fx.clip|rain_splash_1"} -- 107
local function clamp01(v) -- 112
	return v <= 0 and 0 or (v >= 1 and 1 or v) -- 113
end -- 112
local function hash01(seed) -- 116
	local x = math.sin(seed * 127.1 + 311.7) * 43758.5453 -- 117
	return x - math.floor(x) -- 118
end -- 116
local function weatherOfRoom(roomKey) -- 121
	if roomKey == "gate" then -- 121
		return "siege" -- 123
	end -- 123
	if roomKey == "outside" or roomKey == "village" or roomKey == "escort4" then -- 123
		return "rain" -- 126
	end -- 126
	if roomKey == "forest" or roomKey == "escort3" then -- 126
		return "forest" -- 129
	end -- 129
	if roomKey == "tower" or roomKey == "museum" or roomKey == "escort5" then -- 129
		return "sanctuary" -- 132
	end -- 132
	return "embers" -- 134
end -- 121
local function roomWindScale(roomKey) -- 137
	if roomKey == "prologue" or roomKey == "escort2" or roomKey == "c2-granary" or roomKey == "museum" then -- 137
		return 0.25 -- 139
	end -- 139
	if roomKey == "tower" or roomKey == "escort3" then -- 139
		return 0.45 -- 142
	end -- 142
	if roomKey == "gate" or roomKey == "outside" or roomKey == "escort4" then -- 142
		return 1.25 -- 145
	end -- 145
	return 0.85 -- 147
end -- 137
local function isOutdoorRoom(roomKey) -- 150
	return roomKey ~= "prologue" and roomKey ~= "c2-granary" and roomKey ~= "escort2" and roomKey ~= "museum" -- 151
end -- 150
local function hasWarHorizon(roomKey) -- 157
	return roomKey == "prologue" or roomKey == "street" or roomKey == "s1-crossroad" or roomKey == "s2-drygoods" or roomKey == "s3-archway" or roomKey == "checkpoint" or roomKey == "c1-yard" or roomKey == "gate" or roomKey == "gatepath" or roomKey == "escort1" -- 158
end -- 157
local function lightShaftsForRoom(roomKey) -- 170
	if roomKey == "prologue" then -- 170
		return {{ -- 172
			x0 = 190, -- 173
			topW = 54, -- 173
			botShift = -82, -- 173
			botW = 118, -- 173
			color = PALETTE.jadeMist, -- 173
			alpha = 0.14 -- 173
		}, { -- 173
			x0 = 540, -- 174
			topW = 40, -- 174
			botShift = -68, -- 174
			botW = 96, -- 174
			color = PALETTE.jadeMist, -- 174
			alpha = 0.11 -- 174
		}} -- 174
	end -- 174
	if roomKey == "s2-drygoods" or roomKey == "s1-crossroad" or roomKey == "street" then -- 174
		return {{ -- 178
			x0 = 260, -- 179
			topW = 48, -- 179
			botShift = -75, -- 179
			botW = 112, -- 179
			color = PALETTE.jadeMist, -- 179
			alpha = 0.1 -- 179
		}, { -- 179
			x0 = 760, -- 180
			topW = 56, -- 180
			botShift = -84, -- 180
			botW = 128, -- 180
			color = PALETTE.jadeMist, -- 180
			alpha = 0.1 -- 180
		}} -- 180
	end -- 180
	if roomKey == "c2-granary" then -- 180
		return {{ -- 184
			x0 = 280, -- 185
			topW = 46, -- 185
			botShift = -72, -- 185
			botW = 108, -- 185
			color = PALETTE.jadeMist, -- 185
			alpha = 0.16 -- 185
		}, { -- 185
			x0 = 660, -- 186
			topW = 52, -- 186
			botShift = -80, -- 186
			botW = 120, -- 186
			color = PALETTE.jadeMist, -- 186
			alpha = 0.15 -- 186
		}, { -- 186
			x0 = 1040, -- 187
			topW = 42, -- 187
			botShift = -68, -- 187
			botW = 98, -- 187
			color = PALETTE.jadeMist, -- 187
			alpha = 0.13 -- 187
		}} -- 187
	end -- 187
	if roomKey == "gate" then -- 187
		return {{ -- 191
			x0 = 910, -- 192
			topW = 72, -- 192
			botShift = -64, -- 192
			botW = 146, -- 192
			color = PALETTE.jadeMist, -- 192
			alpha = 0.16 -- 192
		}} -- 192
	end -- 192
	if roomKey == "forest" or roomKey == "escort3" then -- 192
		return {{ -- 196
			x0 = 340, -- 197
			topW = 44, -- 197
			botShift = -86, -- 197
			botW = 112, -- 197
			color = PALETTE.emerald, -- 197
			alpha = 0.1 -- 197
		}, { -- 197
			x0 = 880, -- 198
			topW = 52, -- 198
			botShift = -92, -- 198
			botW = 126, -- 198
			color = PALETTE.emerald, -- 198
			alpha = 0.11 -- 198
		}, { -- 198
			x0 = 1320, -- 199
			topW = 48, -- 199
			botShift = -76, -- 199
			botW = 118, -- 199
			color = PALETTE.amber, -- 199
			alpha = 0.09 -- 199
		}} -- 199
	end -- 199
	if roomKey == "tower" or roomKey == "escort5" then -- 199
		return {{ -- 203
			x0 = 445, -- 204
			topW = 58, -- 204
			botShift = -56, -- 204
			botW = 132, -- 204
			color = PALETTE.amber, -- 204
			alpha = 0.14 -- 204
		}} -- 204
	end -- 204
	if roomKey == "museum" then -- 204
		return {{ -- 208
			x0 = 240, -- 209
			topW = 68, -- 209
			botShift = 92, -- 209
			botW = 150, -- 209
			color = PALETTE.amberCore, -- 209
			alpha = 0.15 -- 209
		}, { -- 209
			x0 = 640, -- 210
			topW = 72, -- 210
			botShift = 96, -- 210
			botW = 158, -- 210
			color = PALETTE.amberCore, -- 210
			alpha = 0.13 -- 210
		}} -- 210
	end -- 210
	return {} -- 213
end -- 170
local function roomAnchors(roomKey) -- 216
	if roomKey == "street" or roomKey == "s1-crossroad" or roomKey == "s2-drygoods" then -- 216
		return {{offsetX = 168, y = 0, depth = 24, kind = "brazier"}, { -- 218
			offsetX = 465, -- 220
			y = 92, -- 220
			depth = 26, -- 220
			kind = "banner", -- 220
			facing = 1 -- 220
		}, {offsetX = 790, y = 0, depth = 24, kind = "brazier"}, { -- 220
			offsetX = 1030, -- 222
			y = 90, -- 222
			depth = 26, -- 222
			kind = "banner", -- 222
			facing = 1 -- 222
		}} -- 222
	end -- 222
	if roomKey == "s3-archway" or roomKey == "checkpoint" or roomKey == "c1-yard" then -- 222
		return {{offsetX = 210, y = 0, depth = 24, kind = "brazier"}, { -- 226
			offsetX = 540, -- 228
			y = 94, -- 228
			depth = 26, -- 228
			kind = "banner", -- 228
			facing = 1 -- 228
		}, {offsetX = 880, y = 0, depth = 24, kind = "brazier"}} -- 228
	end -- 228
	if roomKey == "gate" then -- 228
		return { -- 233
			{offsetX = 170, y = 0, depth = 22, kind = "brazier"}, -- 234
			{offsetX = 468, y = 0, depth = 22, kind = "brazier"}, -- 235
			{offsetX = 785, y = 0, depth = 22, kind = "brazier"}, -- 236
			{ -- 237
				offsetX = 340, -- 237
				y = 76, -- 237
				depth = 24, -- 237
				kind = "banner", -- 237
				facing = 1 -- 237
			}, -- 237
			{ -- 238
				offsetX = 715, -- 238
				y = 80, -- 238
				depth = 24, -- 238
				kind = "banner", -- 238
				facing = 1 -- 238
			} -- 238
		} -- 238
	end -- 238
	if roomKey == "gatepath" then -- 238
		return {{ -- 242
			offsetX = 118, -- 243
			y = 62, -- 243
			depth = 18, -- 243
			kind = "banner", -- 243
			facing = 1 -- 243
		}, { -- 243
			offsetX = 542, -- 244
			y = 56, -- 244
			depth = 18, -- 244
			kind = "banner", -- 244
			facing = 1 -- 244
		}} -- 244
	end -- 244
	if roomKey == "escort1" then -- 244
		return {{offsetX = 285, y = 0, depth = 28, kind = "brazier"}, {offsetX = 860, y = 0, depth = 28, kind = "brazier"}, { -- 248
			offsetX = 615, -- 251
			y = 74, -- 251
			depth = 26, -- 251
			kind = "banner", -- 251
			facing = 1 -- 251
		}} -- 251
	end -- 251
	if roomKey == "escort5" then -- 251
		return {{ -- 255
			offsetX = 238, -- 256
			y = 68, -- 256
			depth = 26, -- 256
			kind = "banner", -- 256
			facing = 1 -- 256
		}, {offsetX = 920, y = 0, depth = 26, kind = "brazier"}} -- 256
	end -- 256
	return {} -- 260
end -- 216
____exports.SceneFxSystem = __TS__Class() -- 263
local SceneFxSystem = ____exports.SceneFxSystem -- 263
SceneFxSystem.name = "SceneFxSystem" -- 263
function SceneFxSystem.prototype.____constructor(self) -- 279
	self.particles = {} -- 264
	self.splashes = {} -- 265
	self.leaves = {} -- 266
	self.brazierEmbers = {} -- 267
	self.time = 0 -- 269
	self.splashCooldown = 0 -- 270
	self.emberCooldown = 0 -- 271
	self.farFlash = 0 -- 272
	self.farFlashCooldown = 4.2 -- 273
	self.prevPlayerInGrass = false -- 274
	self.prevPlayerX = 0 -- 275
	self.lastRoomKey = "" -- 276
	self.rng = 20261127 -- 277
	self:initParticles() -- 280
end -- 279
function SceneFxSystem.prototype.rand(self) -- 283
	self.rng = (self.rng * 1664525 + 1013904223) % 4294967296 -- 284
	return self.rng / 4294967296 -- 285
end -- 283
function SceneFxSystem.prototype.initParticles(self) -- 288
	self.particles = {} -- 289
	do -- 289
		local i = 0 -- 290
		while i < PARTICLE_COUNT do -- 290
			local layer = i < 30 and 0 or (i < 66 and 1 or 2) -- 291
			local ____self_particles_0 = self.particles -- 291
			____self_particles_0[#____self_particles_0 + 1] = { -- 292
				fx = self:rand(), -- 293
				fy = self:rand(), -- 294
				layer = layer, -- 295
				speedMul = (layer == 0 and 0.52 or (layer == 1 and 0.96 or 1.48)) * (0.8 + self:rand() * 0.45), -- 296
				size = layer == 0 and 1 + self:rand() * 0.8 or (layer == 1 and 1.5 + self:rand() * 1.1 or 2.1 + self:rand() * 1.5), -- 297
				phase = self:rand() * math.pi * 2, -- 298
				drift = (self:rand() - 0.5) * 0.08, -- 299
				bright = self:rand() > 0.42 -- 300
			} -- 300
			i = i + 1 -- 290
		end -- 290
	end -- 290
end -- 288
function SceneFxSystem.prototype.reset(self, roomKey) -- 305
	if roomKey == nil then -- 305
		roomKey = "" -- 305
	end -- 305
	self.splashes = {} -- 306
	self.leaves = {} -- 307
	self.brazierEmbers = {} -- 308
	self.splashCooldown = 0 -- 309
	self.emberCooldown = 0 -- 310
	self.farFlash = 0 -- 311
	self.farFlashCooldown = 3.2 + self:rand() * 4.5 -- 312
	self.prevPlayerInGrass = false -- 313
	self.lastRoomKey = roomKey -- 314
end -- 305
function SceneFxSystem.prototype.windAt(self, time, roomKey) -- 318
	local base = roomWindScale(roomKey) -- 319
	local swell = 0.65 + 0.35 * math.sin(time * 0.47) -- 320
	local gustRaw = math.sin(time * 1.19 + 0.8) * math.sin(time * 0.31) -- 321
	local gust = gustRaw > 0 and gustRaw * gustRaw * 0.95 or 0 -- 322
	return base * (swell + gust) -- 323
end -- 318
function SceneFxSystem.prototype.update(self, dt, p, cam) -- 327
	if self.lastRoomKey ~= p.room.key then -- 327
		self:reset(p.room.key) -- 329
		self.prevPlayerX = p.player.x -- 330
	end -- 330
	if dt <= 0 then -- 330
		return -- 333
	end -- 333
	self.time = self.time + dt -- 336
	local key = p.room.key -- 337
	local weather = weatherOfRoom(key) -- 338
	local wind = self:windAt(self.time, key) -- 339
	if self.farFlash > 0 then -- 339
		self.farFlash = math.max(0, self.farFlash - dt * 3.8) -- 343
	end -- 343
	if key == "gate" or key == "street" or key == "s1-crossroad" or key == "escort1" then -- 343
		self.farFlashCooldown = self.farFlashCooldown - dt -- 346
		if self.farFlashCooldown <= 0 then -- 346
			self.farFlash = key == "gate" and 0.65 or 0.35 -- 348
			self.farFlashCooldown = (key == "gate" and 2.6 or 5.5) + self:rand() * 5.2 -- 349
		end -- 349
	end -- 349
	local siegeBoost = key == "gate" and p.phase == "gate-hold" and 1 + 0.7 * clamp01(p.gateTick / 2700) or 1 -- 354
	do -- 354
		local i = 0 -- 357
		while i < #self.particles do -- 357
			local pt = self.particles[i + 1] -- 358
			pt.phase = pt.phase + dt * (1.7 + pt.layer * 0.45) -- 359
			if weather == "rain" then -- 359
				pt.fx = pt.fx - dt * (0.13 + wind * 0.16) * pt.speedMul -- 361
				pt.fy = pt.fy - dt * (0.72 + pt.layer * 0.22) * pt.speedMul -- 362
			elseif weather == "siege" or weather == "embers" then -- 362
				local vx = (-0.055 - wind * 0.085) * siegeBoost + math.sin(pt.phase * 1.3) * 0.028 -- 364
				local vy = (0.045 + (pt.bright and 0.065 or -0.022)) * siegeBoost -- 365
				pt.fx = pt.fx + (vx + pt.drift * 0.4) * dt * pt.speedMul -- 366
				pt.fy = pt.fy + vy * dt * pt.speedMul -- 367
			elseif weather == "forest" then -- 367
				pt.fx = pt.fx + (-0.018 * wind + math.sin(pt.phase) * 0.022) * dt * pt.speedMul -- 369
				pt.fy = pt.fy + (pt.bright and math.cos(pt.phase * 0.8) * 0.024 or -0.042) * dt * pt.speedMul -- 370
			else -- 370
				pt.fx = pt.fx + math.sin(pt.phase * 0.7) * 0.012 * dt * pt.speedMul -- 373
				pt.fy = pt.fy + (0.016 + math.cos(pt.phase * 0.5) * 0.008) * dt * pt.speedMul -- 374
			end -- 374
			if pt.fx < -0.04 then -- 374
				pt.fx = pt.fx + 1.08 -- 376
			end -- 376
			if pt.fx > 1.04 then -- 376
				pt.fx = pt.fx - 1.08 -- 377
			end -- 377
			if pt.fy < -0.04 then -- 377
				pt.fy = pt.fy + 1.08 -- 378
			end -- 378
			if pt.fy > 1.04 then -- 378
				pt.fy = pt.fy - 1.08 -- 379
			end -- 379
			i = i + 1 -- 357
		end -- 357
	end -- 357
	if weather == "rain" then -- 357
		self.splashCooldown = self.splashCooldown - dt -- 384
		local halfSpan = cam.viewW * 0.55 / math.max(0.4, cam.ppu) -- 385
		if self.splashCooldown <= 0 and #self.splashes < MAX_SPLASHES then -- 385
			local wx = cam.x + (self:rand() - 0.5) * 2 * halfSpan -- 387
			local wy = 0 -- 388
			do -- 388
				local f = 0 -- 389
				while f < #p.room.floors do -- 389
					local fl = p.room.floors[f + 1] -- 390
					if wx >= fl.x0 and wx <= fl.x1 and fl.y > wy and self:rand() > 0.45 then -- 390
						wy = fl.y -- 392
					end -- 392
					f = f + 1 -- 389
				end -- 389
			end -- 389
			local depthRange = p.room.depth -- 395
			local depth = depthRange ~= nil and depthRange.min + self:rand() * (depthRange.max - depthRange.min) or 0 -- 396
			local ____self_splashes_1 = self.splashes -- 396
			____self_splashes_1[#____self_splashes_1 + 1] = { -- 399
				wx = wx, -- 400
				wy = wy, -- 401
				depth = depth, -- 402
				age = 0, -- 403
				maxAge = 0.22 + self:rand() * 0.12, -- 404
				scale = 0.75 + self:rand() * 0.5 -- 405
			} -- 405
			self.splashCooldown = 0.032 + self:rand() * 0.038 -- 407
		end -- 407
	end -- 407
	local w = 0 -- 410
	do -- 410
		local i = 0 -- 411
		while i < #self.splashes do -- 411
			local sp = self.splashes[i + 1] -- 412
			sp.age = sp.age + dt -- 413
			if sp.age < sp.maxAge then -- 413
				self.splashes[w + 1] = sp -- 415
				w = w + 1 -- 416
			end -- 416
			i = i + 1 -- 411
		end -- 411
	end -- 411
	__TS__ArraySetLength(self.splashes, w) -- 411
	local inGrass = false -- 422
	do -- 422
		local i = 0 -- 423
		while i < #p.room.solids do -- 423
			local s = p.room.solids[i + 1] -- 424
			if s.passable == true and p.player.x >= s.x - 8 and p.player.x <= s.x + s.w + 8 and p.player.y <= s.y + s.h + 6 then -- 424
				inGrass = true -- 426
				break -- 427
			end -- 427
			i = i + 1 -- 423
		end -- 423
	end -- 423
	local playerMove = math.abs(p.player.x - self.prevPlayerX) -- 430
	self.prevPlayerX = p.player.x -- 431
	if inGrass and (not self.prevPlayerInGrass or playerMove > 2.2 and self:rand() < dt * 7.5) then -- 431
		self:spawnGrassLeaves( -- 433
			p.player.x, -- 433
			p.player.y + 8, -- 433
			p.player.depth, -- 433
			p.player.facing, -- 433
			self.prevPlayerInGrass and 2 or 5 -- 433
		) -- 433
	end -- 433
	self.prevPlayerInGrass = inGrass -- 435
	if (key == "forest" or key == "escort3" or key == "escort4" or key == "escort5") and #self.leaves < MAX_LEAVES and self:rand() < dt * (1.8 + wind) then -- 435
		local halfSpan = cam.viewW * 0.55 / math.max(0.4, cam.ppu) -- 439
		local ____self_leaves_2 = self.leaves -- 439
		____self_leaves_2[#____self_leaves_2 + 1] = { -- 440
			wx = cam.x + (self:rand() - 0.35) * 2 * halfSpan, -- 441
			wy = 170 + self:rand() * 65, -- 442
			depth = 0, -- 443
			vx = -18 - wind * 24 - self:rand() * 14, -- 444
			vy = -20 - self:rand() * 18, -- 445
			age = 0, -- 446
			maxAge = 2.8 + self:rand() * 1.8, -- 447
			spin = self:rand() * math.pi * 2, -- 448
			frame = math.floor(self:rand() * 4) -- 449
		} -- 449
	end -- 449
	w = 0 -- 453
	do -- 453
		local i = 0 -- 454
		while i < #self.leaves do -- 454
			local lf = self.leaves[i + 1] -- 455
			lf.age = lf.age + dt -- 456
			if lf.age < lf.maxAge and lf.wy >= -4 then -- 456
				lf.spin = lf.spin + dt * 4.2 -- 458
				lf.wx = lf.wx + (lf.vx + math.sin(lf.spin) * 16) * dt -- 459
				lf.wy = lf.wy + (lf.vy + math.cos(lf.spin * 0.8) * 6) * dt -- 460
				self.leaves[w + 1] = lf -- 461
				w = w + 1 -- 462
			end -- 462
			i = i + 1 -- 454
		end -- 454
	end -- 454
	__TS__ArraySetLength(self.leaves, w) -- 454
	local anchors = roomAnchors(key) -- 468
	self.emberCooldown = self.emberCooldown - dt -- 469
	if self.emberCooldown <= 0 and #anchors > 0 and #self.brazierEmbers < MAX_BRAZIER_EMBERS then -- 469
		do -- 469
			local i = 0 -- 471
			while i < #anchors do -- 471
				do -- 471
					local an = anchors[i + 1] -- 472
					if an.kind ~= "brazier" then -- 472
						goto __continue71 -- 474
					end -- 474
					local wx = p.ox + an.offsetX -- 476
					if math.abs(wx - cam.x) > 520 then -- 476
						goto __continue71 -- 478
					end -- 478
					local ____self_brazierEmbers_3 = self.brazierEmbers -- 478
					____self_brazierEmbers_3[#____self_brazierEmbers_3 + 1] = { -- 480
						wx = wx + (self:rand() - 0.5) * 12, -- 481
						wy = an.y + 18, -- 482
						depth = an.depth, -- 483
						vx = -wind * 18 + (self:rand() - 0.5) * 18, -- 484
						vy = 28 + self:rand() * 34, -- 485
						age = 0, -- 486
						maxAge = 0.9 + self:rand() * 0.9, -- 487
						size = 1.4 + self:rand() * 1.4 -- 488
					} -- 488
				end -- 488
				::__continue71:: -- 488
				i = i + 1 -- 471
			end -- 471
		end -- 471
		self.emberCooldown = 0.14 -- 491
	end -- 491
	w = 0 -- 493
	do -- 493
		local i = 0 -- 494
		while i < #self.brazierEmbers do -- 494
			local em = self.brazierEmbers[i + 1] -- 495
			em.age = em.age + dt -- 496
			if em.age < em.maxAge then -- 496
				em.wx = em.wx + (em.vx + math.sin(self.time * 5 + i) * 12) * dt -- 498
				em.wy = em.wy + em.vy * dt -- 499
				self.brazierEmbers[w + 1] = em -- 500
				w = w + 1 -- 501
			end -- 501
			i = i + 1 -- 494
		end -- 494
	end -- 494
	__TS__ArraySetLength(self.brazierEmbers, w) -- 494
end -- 327
function SceneFxSystem.prototype.spawnGrassLeaves(self, wx, wy, depth, facing, count) -- 507
	do -- 507
		local i = 0 -- 508
		while i < count and #self.leaves < MAX_LEAVES do -- 508
			local ____self_leaves_4 = self.leaves -- 508
			____self_leaves_4[#____self_leaves_4 + 1] = { -- 509
				wx = wx + (self:rand() - 0.5) * 18, -- 510
				wy = wy + self:rand() * 10, -- 511
				depth = depth, -- 512
				vx = -facing * (16 + self:rand() * 28) + (self:rand() - 0.5) * 26, -- 513
				vy = 36 + self:rand() * 38, -- 514
				age = 0, -- 515
				maxAge = 0.65 + self:rand() * 0.45, -- 516
				spin = self:rand() * math.pi * 2, -- 517
				frame = math.floor(self:rand() * 4) -- 518
			} -- 518
			i = i + 1 -- 508
		end -- 508
	end -- 508
end -- 507
function SceneFxSystem.prototype.drawBackdropFx(self, bgDraw, bgGlow, backdropArt, p, cam) -- 524
	local key = p.room.key -- 531
	local w = cam.viewW -- 532
	local h = cam.viewH -- 533
	local t = self.time -- 534
	local wind = self:windAt(t, key) -- 535
	local theme = themeOf(key) -- 536
	if isOutdoorRoom(key) and theme.showMoon then -- 536
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 540
		local my = h * theme.moonYFrac -- 541
		local pulse = 0.88 + 0.12 * math.sin(t * 1.15) -- 542
		fillRadialGlow( -- 543
			bgGlow, -- 543
			mx, -- 543
			my, -- 543
			h * 0.24 * pulse, -- 543
			h * 0.2 * pulse, -- 543
			Color( -- 544
				138, -- 544
				174, -- 544
				206, -- 544
				math.floor(28 * pulse + 0.5) -- 544
			), -- 544
			Color(18, 28, 46, 0), -- 544
			18 -- 544
		) -- 544
		local cloudA = (t * (7 + wind * 5) + cam.x * 0.05) % (w + 520) - 260 -- 547
		local cloudB = (t * (12 + wind * 8) + cam.x * 0.09 + w * 0.48) % (w + 520) - 260 -- 548
		backdropArt:tryPlace( -- 549
			"ink_mist_curve", -- 549
			"sfx_cloud_a", -- 549
			w - cloudA, -- 549
			h * 0.82, -- 549
			540, -- 549
			84, -- 549
			{ -- 549
				color = Color(76, 98, 128, 255), -- 550
				opacity = 0.14, -- 550
				layer = 6 -- 550
			} -- 550
		) -- 550
		backdropArt:tryPlace( -- 552
			"ink_mist_curve", -- 552
			"sfx_cloud_b", -- 552
			w - cloudB, -- 552
			h * 0.72, -- 552
			460, -- 552
			72, -- 552
			{ -- 552
				color = Color(58, 76, 104, 255), -- 553
				opacity = 0.11, -- 553
				layer = 6, -- 553
				facing = -1 -- 553
			} -- 553
		) -- 553
	end -- 553
	if hasWarHorizon(key) then -- 553
		local firePulse = 0.78 + 0.22 * math.sin(t * 2.6 + math.sin(t * 1.1)) -- 559
		local glowA = key == "gate" and 48 or 30 -- 560
		fillRadialGlow( -- 561
			bgGlow, -- 561
			w * 0.16, -- 561
			h * 0.28, -- 561
			w * 0.38, -- 561
			h * 0.34, -- 561
			Color( -- 562
				186, -- 562
				62, -- 562
				34, -- 562
				math.floor(glowA * firePulse + 0.5) -- 562
			), -- 562
			Color(160, 44, 24, 0), -- 562
			16 -- 562
		) -- 562
		if self.farFlash > 0.02 then -- 562
			local fa = math.floor(36 * self.farFlash + 0.5) -- 564
			fillRadialGlow( -- 565
				bgGlow, -- 565
				w * 0.24, -- 565
				h * 0.46, -- 565
				w * 0.48, -- 565
				h * 0.42, -- 565
				Color(242, 168, 114, fa), -- 566
				Color(186, 72, 44, 0), -- 566
				16 -- 566
			) -- 566
		end -- 566
	end -- 566
	local mistSpeed = 10 + wind * 12 -- 571
	local m1 = (t * mistSpeed + cam.x * 0.14) % (w + 640) - 320 -- 572
	local m2 = (t * mistSpeed * 0.65 + cam.x * 0.08 + w * 0.52) % (w + 640) - 320 -- 573
	local mistTint = key == "gate" and Color(94, 52, 54, 255) or (key == "forest" and Color(68, 108, 102, 255) or ((key == "tower" or key == "escort3") and Color(148, 126, 98, 255) or Color(66, 86, 112, 255))) -- 574
	local mistOp = (key == "forest" or key == "outside" or key == "village") and 0.2 or 0.14 -- 577
	backdropArt:tryPlace( -- 578
		"ink_mist_curve", -- 578
		"sfx_ground_mist_1", -- 578
		w - m1, -- 578
		cam.groundScreenY + h * 0.08, -- 578
		660, -- 578
		124, -- 578
		{color = mistTint, opacity = mistOp, layer = 7} -- 578
	) -- 578
	backdropArt:tryPlace( -- 581
		"ink_mist_curve", -- 581
		"sfx_ground_mist_2", -- 581
		w - m2, -- 581
		cam.groundScreenY + h * 0.14, -- 581
		580, -- 581
		108, -- 581
		{color = mistTint, opacity = mistOp * 0.8, layer = 7, facing = -1} -- 581
	) -- 581
	local shafts = lightShaftsForRoom(key) -- 586
	do -- 586
		local i = 0 -- 587
		while i < #shafts do -- 587
			do -- 587
				local sh = shafts[i + 1] -- 588
				local topX = cam:sx(p.ox + sh.x0) -- 589
				local botX = topX + cam:len(sh.botShift) -- 590
				if topX + cam:len(sh.topW + sh.botW) < -80 or botX - cam:len(sh.botW) > w + 80 then -- 590
					goto __continue85 -- 592
				end -- 592
				local pulse = 0.84 + 0.16 * math.sin(t * 0.95 + i * 1.7) -- 594
				local tw = cam:len(sh.topW) * 0.5 -- 595
				local bw = cam:len(sh.botW) * 0.5 -- 596
				local yTop = h + 16 -- 597
				local yMid = h * 0.54 -- 598
				local yBot = cam.groundScreenY - 4 -- 599
				local midX = (topX + botX) * 0.5 -- 600
				local mw = (tw + bw) * 0.5 -- 601
				local col = sh.color -- 602
				local aMid = math.floor(255 * sh.alpha * pulse + 0.5) -- 603
				local aTop = math.floor(aMid * 0.45 + 0.5) -- 604
				fillGradQuad( -- 605
					bgGlow, -- 606
					topX - tw, -- 607
					yTop, -- 607
					Color(col.r, col.g, col.b, aTop), -- 607
					topX + tw, -- 608
					yTop, -- 608
					Color(col.r, col.g, col.b, aTop), -- 608
					midX + mw, -- 609
					yMid, -- 609
					Color(col.r, col.g, col.b, aMid), -- 609
					midX - mw, -- 610
					yMid, -- 610
					Color(col.r, col.g, col.b, aMid) -- 610
				) -- 610
				fillGradQuad( -- 612
					bgGlow, -- 613
					midX - mw, -- 614
					yMid, -- 614
					Color(col.r, col.g, col.b, aMid), -- 614
					midX + mw, -- 615
					yMid, -- 615
					Color(col.r, col.g, col.b, aMid), -- 615
					botX + bw, -- 616
					yBot, -- 616
					Color(col.r, col.g, col.b, 0), -- 616
					botX - bw, -- 617
					yBot, -- 617
					Color(col.r, col.g, col.b, 0) -- 617
				) -- 617
				do -- 617
					local d = 0 -- 621
					while d < 6 do -- 621
						local u = (t * 0.08 + d * 0.167 + i * 0.23) % 1 -- 622
						local px = topX + (botX - topX) * u + math.sin(t * 1.2 + d * 2.1) * (tw + (bw - tw) * u) * 0.55 -- 623
						local py = yTop + (yBot - yTop) * u -- 624
						local fade = math.sin(u * math.pi) -- 625
						bgGlow:drawDot( -- 626
							Vec2(px, py), -- 626
							1.4 + d % 2 * 0.7, -- 626
							Color( -- 626
								col.r, -- 626
								col.g, -- 626
								col.b, -- 626
								math.floor(135 * fade * pulse + 0.5) -- 626
							) -- 626
						) -- 626
						d = d + 1 -- 621
					end -- 621
				end -- 621
			end -- 621
			::__continue85:: -- 621
			i = i + 1 -- 587
		end -- 587
	end -- 587
end -- 524
function SceneFxSystem.prototype.drawWorldFx(self, fgDraw, fgGlow, worldArt, p, cam) -- 632
	local key = p.room.key -- 639
	local t = self.time -- 640
	local wind = self:windAt(t, key) -- 641
	local w = cam.viewW -- 642
	local anchors = roomAnchors(key) -- 645
	local flameFrame = math.floor(t * 11) % 4 -- 646
	local flagFrame = math.floor(t * (5.5 + wind * 3.5)) % 4 -- 647
	do -- 647
		local i = 0 -- 649
		while i < #anchors do -- 649
			do -- 649
				local an = anchors[i + 1] -- 650
				local wx = p.ox + an.offsetX -- 651
				local sx = cam:sx(wx) -- 652
				if sx < -120 or sx > w + 120 then -- 652
					goto __continue91 -- 654
				end -- 654
				local depth = p.room.depth ~= nil and an.depth or 0 -- 656
				local sy = cam:sy(an.y, depth) -- 657
				if an.kind == "brazier" then -- 657
					local pulse = 0.84 + 0.16 * math.sin(t * 8.4 + i * 2.1) -- 660
					local fSize = cam:len(26) -- 661
					fgDraw:drawPolygon( -- 663
						{ -- 663
							Vec2( -- 664
								sx - cam:len(11), -- 664
								sy + cam:len(13) -- 664
							), -- 664
							Vec2( -- 665
								sx + cam:len(11), -- 665
								sy + cam:len(13) -- 665
							), -- 665
							Vec2( -- 666
								sx + cam:len(7), -- 666
								sy + cam:len(4) -- 666
							), -- 666
							Vec2( -- 667
								sx - cam:len(7), -- 667
								sy + cam:len(4) -- 667
							) -- 667
						}, -- 667
						Color(26, 22, 24, 245), -- 668
						1, -- 668
						Color(84, 58, 46, 175) -- 668
					) -- 668
					fgDraw:drawSegment( -- 669
						Vec2( -- 669
							sx - cam:len(8), -- 669
							sy -- 669
						), -- 669
						Vec2( -- 669
							sx - cam:len(5), -- 669
							sy + cam:len(5) -- 669
						), -- 669
						1.8, -- 669
						Color(24, 20, 22, 240) -- 669
					) -- 669
					fgDraw:drawSegment( -- 670
						Vec2( -- 670
							sx + cam:len(8), -- 670
							sy -- 670
						), -- 670
						Vec2( -- 670
							sx + cam:len(5), -- 670
							sy + cam:len(5) -- 670
						), -- 670
						1.8, -- 670
						Color(24, 20, 22, 240) -- 670
					) -- 670
					if not worldArt:tryPlacePath( -- 670
						SFX_FLAME_CLIPS[(flameFrame + i) % 4 + 1], -- 674
						"sfx_brazier_flame_" .. tostring(i), -- 675
						sx, -- 676
						sy + cam:len(10), -- 677
						fSize, -- 678
						fSize * 1.15, -- 679
						{anchorX = 0.5, anchorY = 0, preserveAspect = true, layer = 2} -- 680
					) then -- 680
						fgGlow:drawEllipse( -- 682
							Vec2( -- 682
								sx, -- 682
								sy + cam:len(16) -- 682
							), -- 682
							cam:len(6), -- 682
							cam:len(10 * pulse), -- 682
							Color(246, 132, 46, 195) -- 682
						) -- 682
					end -- 682
					fillRadialGlow( -- 686
						fgGlow, -- 686
						sx, -- 686
						sy + cam:len(22), -- 686
						cam:len(68 * pulse), -- 686
						cam:len(52 * pulse), -- 686
						Color( -- 687
							238, -- 687
							126, -- 687
							48, -- 687
							math.floor(74 * pulse + 0.5) -- 687
						), -- 687
						Color(210, 76, 26, 0), -- 687
						16 -- 687
					) -- 687
					fillRadialGlow( -- 688
						fgGlow, -- 688
						sx, -- 688
						sy + cam:len(2), -- 688
						cam:len(46 * pulse), -- 688
						cam:len(12 * pulse), -- 688
						Color( -- 689
							246, -- 689
							152, -- 689
							72, -- 689
							math.floor(48 * pulse + 0.5) -- 689
						), -- 689
						Color(220, 96, 36, 0), -- 689
						14 -- 689
					) -- 689
				elseif an.kind == "banner" then -- 689
					local poleBot = cam:sy(0, depth) -- 692
					local poleTop = sy + cam:len(16) -- 693
					fgDraw:drawEllipse( -- 694
						Vec2(sx, poleBot + 1), -- 694
						cam:len(6), -- 694
						2.2, -- 694
						Color(10, 10, 14, 120) -- 694
					) -- 694
					fgDraw:drawSegment( -- 695
						Vec2(sx, poleBot), -- 695
						Vec2(sx, poleTop), -- 695
						math.max( -- 695
							1.5, -- 695
							cam:len(2) -- 695
						), -- 695
						Color(48, 38, 32, 230) -- 695
					) -- 695
					fgDraw:drawPolygon( -- 696
						{ -- 696
							Vec2( -- 697
								sx - cam:len(1.8), -- 697
								poleTop -- 697
							), -- 697
							Vec2( -- 698
								sx + cam:len(1.8), -- 698
								poleTop -- 698
							), -- 698
							Vec2( -- 699
								sx, -- 699
								poleTop + cam:len(6) -- 699
							) -- 699
						}, -- 699
						Color(136, 146, 158, 225) -- 700
					) -- 700
					worldArt:tryPlacePath( -- 701
						SFX_FLAG_CLIPS[(flagFrame + i) % 4 + 1], -- 702
						"sfx_banner_" .. tostring(i), -- 703
						sx + cam:len(0.8), -- 704
						sy + cam:len(9), -- 705
						cam:len(34), -- 706
						cam:len(22), -- 707
						{ -- 708
							anchorX = 0.08, -- 709
							anchorY = 0.5, -- 710
							preserveAspect = true, -- 711
							facing = an.facing or 1, -- 712
							angle = math.sin(t * 2.8 + i) * wind * 2.8, -- 713
							opacity = 0.9, -- 714
							layer = 2 -- 715
						} -- 715
					) -- 715
				end -- 715
			end -- 715
			::__continue91:: -- 715
			i = i + 1 -- 649
		end -- 649
	end -- 649
	local lanternFrame = math.floor(t * 7.5) % 2 -- 722
	do -- 722
		local i = 0 -- 723
		while i < #p.room.marks do -- 723
			do -- 723
				local m = p.room.marks[i + 1] -- 724
				if m.kind ~= 6 then -- 724
					goto __continue97 -- 726
				end -- 726
				local mx = cam:sx(m.x + 13) -- 728
				if mx < -80 or mx > w + 80 then -- 728
					goto __continue97 -- 730
				end -- 730
				local my = cam:sy(m.y + 40) -- 732
				local swayX = math.sin(t * 2.3 + m.x * 0.02) * wind * cam:len(2.4) -- 733
				local flicker = 0.86 + 0.14 * math.sin(t * 9.2 + i * 3.1) -- 734
				worldArt:tryPlacePath( -- 735
					SFX_LANTERN_FLAME_CLIPS[lanternFrame + 1], -- 736
					"sfx_mark_flame_" .. tostring(i), -- 737
					mx + swayX, -- 738
					my, -- 739
					cam:len(16), -- 740
					cam:len(18), -- 741
					{ -- 742
						anchorX = 0.5, -- 742
						anchorY = 0.5, -- 742
						preserveAspect = true, -- 742
						opacity = 0.88 * flicker, -- 742
						layer = 6 -- 742
					} -- 742
				) -- 742
				local gy = cam:sy(m.y) -- 745
				fillRadialGlow( -- 746
					fgGlow, -- 746
					mx + swayX * 0.4, -- 746
					gy + cam:len(2), -- 746
					cam:len(38 * flicker), -- 746
					cam:len(10 * flicker), -- 746
					Color( -- 747
						246, -- 747
						186, -- 747
						104, -- 747
						math.floor(42 * flicker + 0.5) -- 747
					), -- 747
					Color(224, 152, 74, 0), -- 747
					14 -- 747
				) -- 747
			end -- 747
			::__continue97:: -- 747
			i = i + 1 -- 723
		end -- 723
	end -- 723
	do -- 723
		local i = 0 -- 751
		while i < #self.brazierEmbers do -- 751
			local em = self.brazierEmbers[i + 1] -- 752
			local k = 1 - em.age / em.maxAge -- 753
			local ex = cam:sx(em.wx) -- 754
			local ey = cam:sy(em.wy, p.room.depth ~= nil and em.depth or 0) -- 755
			fgGlow:drawDot( -- 756
				Vec2(ex, ey), -- 756
				em.size * k, -- 756
				Color( -- 756
					255, -- 756
					168, -- 756
					76, -- 756
					math.floor(230 * k + 0.5) -- 756
				) -- 756
			) -- 756
			fgGlow:drawDot( -- 757
				Vec2(ex, ey), -- 757
				em.size * 2.4 * k, -- 757
				Color( -- 757
					228, -- 757
					92, -- 757
					36, -- 757
					math.floor(72 * k + 0.5) -- 757
				) -- 757
			) -- 757
			i = i + 1 -- 751
		end -- 751
	end -- 751
	do -- 751
		local i = 0 -- 761
		while i < #p.room.solids do -- 761
			do -- 761
				local s = p.room.solids[i + 1] -- 762
				if s.passable ~= true then -- 762
					goto __continue103 -- 764
				end -- 764
				local x0 = cam:sx(s.x) -- 766
				local x1 = cam:sx(s.x + s.w) -- 767
				if x1 < -30 or x0 > w + 30 then -- 767
					goto __continue103 -- 769
				end -- 769
				local y0 = cam:sy(s.y) -- 771
				local sw = x1 - x0 -- 772
				local sh = cam:len(s.h) -- 773
				local blades = math.max( -- 774
					7, -- 774
					math.min( -- 774
						20, -- 774
						math.floor(s.w / 9) -- 774
					) -- 774
				) -- 774
				do -- 774
					local b = 0 -- 775
					while b < blades do -- 775
						local u = (b + 0.5) / blades -- 776
						local bwx = s.x + s.w * u -- 777
						local bx = x0 + sw * u -- 778
						local dxPlayer = bwx - p.player.x -- 779
						local near = math.abs(dxPlayer) < 26 and p.player.y < s.y + s.h + 10 -- 780
						local partPush = near and (dxPlayer >= 0 and 1 or -1) * (1 - math.abs(dxPlayer) / 26) * cam:len(10) or 0 -- 781
						local wave = math.sin(t * (2.6 + wind) + bwx * 0.08) * cam:len(3.4 * wind) + partPush -- 782
						local bh = sh * (0.95 + 0.45 * hash01(b * 13.7 + s.x)) -- 783
						local col = b % 2 == 0 and Color(28, 66, 56, 175) or Color(46, 94, 78, 165) -- 784
						fgDraw:drawSegment( -- 785
							Vec2(bx, y0), -- 785
							Vec2(bx + wave, y0 + bh), -- 785
							math.max( -- 785
								1.2, -- 785
								cam:len(1.6) -- 785
							), -- 785
							col -- 785
						) -- 785
						b = b + 1 -- 775
					end -- 775
				end -- 775
			end -- 775
			::__continue103:: -- 775
			i = i + 1 -- 761
		end -- 761
	end -- 761
	do -- 761
		local i = 0 -- 790
		while i < #self.leaves do -- 790
			local lf = self.leaves[i + 1] -- 791
			local k = 1 - lf.age / lf.maxAge -- 792
			local lx = cam:sx(lf.wx) -- 793
			local ly = cam:sy(lf.wy, p.room.depth ~= nil and lf.depth or 0) -- 794
			local sz = cam:len(9) -- 795
			if not worldArt:tryPlacePath( -- 795
				SFX_LEAF_CLIPS[lf.frame % 2 + 1], -- 797
				"sfx_leaf_" .. tostring(i), -- 798
				lx, -- 799
				ly, -- 800
				sz, -- 801
				sz, -- 802
				{ -- 803
					anchorX = 0.5, -- 803
					anchorY = 0.5, -- 803
					angle = lf.spin * 45, -- 803
					opacity = math.min(1, k * 1.8) * 0.85, -- 803
					layer = 7 -- 803
				} -- 803
			) then -- 803
				fgDraw:drawEllipse( -- 805
					Vec2(lx, ly), -- 805
					2.8, -- 805
					1.3, -- 805
					Color( -- 805
						76, -- 805
						118, -- 805
						92, -- 805
						math.floor(185 * k + 0.5) -- 805
					) -- 805
				) -- 805
			end -- 805
			i = i + 1 -- 790
		end -- 790
	end -- 790
	do -- 790
		local i = 0 -- 810
		while i < #self.splashes do -- 810
			do -- 810
				local sp = self.splashes[i + 1] -- 811
				local prog = clamp01(sp.age / sp.maxAge) -- 812
				local sx = cam:sx(sp.wx) -- 813
				if sx < -20 or sx > w + 20 then -- 813
					goto __continue112 -- 815
				end -- 815
				local sy = cam:sy(sp.wy + 1, p.room.depth ~= nil and sp.depth or 0) -- 817
				local sz = cam:len(10 * sp.scale) -- 818
				local frame = math.min( -- 819
					1, -- 819
					math.floor(prog * 2) -- 819
				) -- 819
				if not worldArt:tryPlacePath( -- 819
					SFX_RAIN_SPLASH_CLIPS[frame + 1], -- 821
					"sfx_rain_splash_" .. tostring(i), -- 822
					sx, -- 823
					sy, -- 824
					sz, -- 825
					sz * 0.65, -- 826
					{ -- 827
						anchorX = 0.5, -- 827
						anchorY = 0, -- 827
						preserveAspect = true, -- 827
						opacity = (1 - prog) * 0.62, -- 827
						layer = 7 -- 827
					} -- 827
				) then -- 827
					local r = cam:len(3 + prog * 5) * sp.scale -- 829
					fgGlow:drawEllipse( -- 830
						Vec2(sx, sy), -- 830
						r, -- 830
						r * 0.28, -- 830
						Color( -- 830
							168, -- 830
							196, -- 830
							218, -- 830
							math.floor(110 * (1 - prog) + 0.5) -- 830
						) -- 830
					) -- 830
				end -- 830
			end -- 830
			::__continue112:: -- 830
			i = i + 1 -- 810
		end -- 810
	end -- 810
end -- 632
function SceneFxSystem.prototype.drawForegroundWeather(self, fgGlow, p, cam, w, h) -- 836
	local key = p.room.key -- 843
	local weather = weatherOfRoom(key) -- 844
	local wind = self:windAt(self.time, key) -- 845
	local camParallaxBase = cam.x * 0.00045 -- 846
	do -- 846
		local i = 0 -- 848
		while i < #self.particles do -- 848
			local pt = self.particles[i + 1] -- 849
			local parallax = pt.layer == 0 and 0.35 or (pt.layer == 1 and 0.85 or 1.55) -- 850
			local nx = (pt.fx - camParallaxBase * parallax) % 1 -- 851
			if nx < 0 then -- 851
				nx = nx + 1 -- 853
			end -- 853
			local x = nx * w -- 855
			local y = pt.fy * h -- 856
			local tw = 0.55 + 0.45 * math.sin(pt.phase) -- 857
			local layerAlpha = pt.layer == 0 and 0.45 or (pt.layer == 1 and 0.78 or 1) -- 858
			if weather == "rain" then -- 858
				local len = (11 + pt.layer * 8) * pt.speedMul * 0.75 -- 861
				local tilt = (3.5 + wind * 5.2) * (0.7 + pt.layer * 0.25) -- 862
				local alpha = math.floor((46 + pt.layer * 24) * tw * layerAlpha + 0.5) -- 863
				fgGlow:drawSegment( -- 864
					Vec2(x, y), -- 865
					Vec2(x + tilt, y + len), -- 866
					pt.layer == 2 and 1.15 or 0.8, -- 867
					Color(168, 194, 216, alpha) -- 868
				) -- 868
			elseif weather == "siege" or weather == "embers" then -- 868
				if pt.bright then -- 868
					local col = weather == "siege" and Color( -- 872
						255, -- 872
						134, -- 872
						62, -- 872
						math.floor(168 * tw * layerAlpha + 0.5) -- 872
					) or Color( -- 872
						242, -- 873
						160, -- 873
						82, -- 873
						math.floor(132 * tw * layerAlpha + 0.5) -- 873
					) -- 873
					local tailX = x + (2.5 + wind * 4.2) * (0.5 + pt.layer * 0.3) -- 874
					local tailY = y - 2.8 * (0.6 + pt.layer * 0.25) -- 875
					fgGlow:drawSegment( -- 876
						Vec2(tailX, tailY), -- 876
						Vec2(x, y), -- 876
						pt.size * 0.38, -- 876
						col -- 876
					) -- 876
					fgGlow:drawDot( -- 877
						Vec2(x, y), -- 877
						pt.size * 0.54, -- 877
						Color( -- 877
							255, -- 877
							214, -- 877
							138, -- 877
							math.floor(145 * tw * layerAlpha + 0.5) -- 877
						) -- 877
					) -- 877
				else -- 877
					fgGlow:drawDot( -- 880
						Vec2(x, y), -- 880
						pt.size * 0.68, -- 880
						Color( -- 880
							142, -- 880
							148, -- 880
							162, -- 880
							math.floor(52 * tw * layerAlpha + 0.5) -- 880
						) -- 880
					) -- 880
				end -- 880
			elseif weather == "forest" then -- 880
				if pt.bright and pt.layer >= 1 then -- 880
					local col = i % 3 == 0 and PALETTE.amberCore or PALETTE.emerald -- 885
					local r = pt.size * (0.85 + 0.35 * tw) -- 886
					fgGlow:drawDot( -- 887
						Vec2(x, y), -- 887
						r, -- 887
						toColor(col, 155 * tw * layerAlpha) -- 887
					) -- 887
					fgGlow:drawDot( -- 888
						Vec2(x, y), -- 888
						r * 2.8, -- 888
						toColor(col, 32 * tw * layerAlpha) -- 888
					) -- 888
				else -- 888
					fgGlow:drawDot( -- 890
						Vec2(x, y), -- 890
						pt.size * 0.72, -- 890
						Color( -- 890
							128, -- 890
							164, -- 890
							152, -- 890
							math.floor(62 * tw * layerAlpha + 0.5) -- 890
						) -- 890
					) -- 890
				end -- 890
			else -- 890
				local col = pt.bright and PALETTE.amberCore or PALETTE.amber -- 894
				fgGlow:drawDot( -- 895
					Vec2(x, y), -- 895
					pt.size * 0.85, -- 895
					toColor(col, 128 * tw * layerAlpha) -- 895
				) -- 895
				if pt.layer == 2 and pt.bright then -- 895
					fgGlow:drawDot( -- 897
						Vec2(x, y), -- 897
						pt.size * 2.4, -- 897
						toColor(PALETTE.amber, 26 * tw) -- 897
					) -- 897
				end -- 897
			end -- 897
			i = i + 1 -- 848
		end -- 848
	end -- 848
end -- 836
function SceneFxSystem.prototype.drawTitleAtmosphere(self, bgGlow, fgGlow, backdropArt, worldArt, w, h, time) -- 904
	local artW = math.max(w, h * 16 / 9) -- 914
	local artH = artW * 9 / 16 -- 915
	local ox = (w - artW) * 0.5 -- 916
	local oy = (h - artH) * 0.5 -- 917
	local wind = self:windAt(time, "outside") -- 918
	local moonX = ox + artW * 0.833 -- 921
	local moonY = oy + artH * 0.915 -- 922
	local moonPulse = 0.88 + 0.12 * math.sin(time * 0.9) -- 923
	fillRadialGlow( -- 924
		bgGlow, -- 924
		moonX, -- 924
		moonY, -- 924
		artH * 0.22 * moonPulse, -- 924
		artH * 0.22 * moonPulse, -- 924
		Color( -- 925
			176, -- 925
			206, -- 925
			232, -- 925
			math.floor(42 * moonPulse + 0.5) -- 925
		), -- 925
		Color(24, 38, 60, 0), -- 925
		20 -- 925
	) -- 925
	local cloudX = time * 9 % (w + 540) - 270 -- 928
	backdropArt:tryPlace( -- 929
		"ink_mist_curve", -- 929
		"title_cloud_a", -- 929
		w - cloudX, -- 929
		oy + artH * 0.84, -- 929
		540, -- 929
		82, -- 929
		{ -- 929
			color = Color(86, 108, 138, 255), -- 930
			opacity = 0.16, -- 930
			layer = 4 -- 930
		} -- 930
	) -- 930
	local mist1 = time * 13 % (w + 680) - 340 -- 932
	local mist2 = (time * 8 + w * 0.45) % (w + 680) - 340 -- 933
	backdropArt:tryPlace( -- 934
		"ink_mist_curve", -- 934
		"title_valley_mist_1", -- 934
		w - mist1, -- 934
		oy + artH * 0.42, -- 934
		680, -- 934
		136, -- 934
		{ -- 934
			color = Color(74, 96, 126, 255), -- 935
			opacity = 0.22, -- 935
			layer = 4 -- 935
		} -- 935
	) -- 935
	backdropArt:tryPlace( -- 937
		"ink_mist_curve", -- 937
		"title_valley_mist_2", -- 937
		w - mist2, -- 937
		oy + artH * 0.52, -- 937
		600, -- 937
		116, -- 937
		{ -- 937
			color = Color(62, 82, 110, 255), -- 938
			opacity = 0.16, -- 938
			layer = 4, -- 938
			facing = -1 -- 938
		} -- 938
	) -- 938
	local doorX = ox + artW * 0.902 -- 942
	local doorY = oy + artH * 0.684 -- 943
	local lampPulse = 0.84 + 0.16 * math.sin(time * 2.7 + math.sin(time * 1.1)) -- 944
	fillRadialGlow( -- 945
		bgGlow, -- 945
		doorX, -- 945
		doorY, -- 945
		artH * 0.14 * lampPulse, -- 945
		artH * 0.13 * lampPulse, -- 945
		Color( -- 946
			255, -- 946
			202, -- 946
			114, -- 946
			math.floor(108 * lampPulse + 0.5) -- 946
		), -- 946
		Color(236, 152, 62, 0), -- 946
		18 -- 946
	) -- 946
	fillRadialGlow( -- 947
		bgGlow, -- 947
		doorX, -- 947
		doorY, -- 947
		artH * 0.045 * lampPulse, -- 947
		artH * 0.045 * lampPulse, -- 947
		Color( -- 948
			255, -- 948
			240, -- 948
			192, -- 948
			math.floor(168 * lampPulse + 0.5) -- 948
		), -- 948
		Color(255, 196, 102, 0), -- 948
		12 -- 948
	) -- 948
	local winX = ox + artW * 0.893 -- 950
	local winY = oy + artH * 0.778 -- 951
	fillRadialGlow( -- 952
		bgGlow, -- 952
		winX, -- 952
		winY, -- 952
		artH * 0.045 * lampPulse, -- 952
		artH * 0.045 * lampPulse, -- 952
		Color( -- 953
			255, -- 953
			212, -- 953
			128, -- 953
			math.floor(92 * lampPulse + 0.5) -- 953
		), -- 953
		Color(238, 168, 72, 0), -- 953
		12 -- 953
	) -- 953
	do -- 953
		local i = 0 -- 956
		while i < 42 do -- 956
			local speed = 0.014 + i % 5 * 0.005 -- 957
			local px = (1 - (hash01(i * 17.3) + time * speed * (0.7 + wind * 0.5)) % 1) * w -- 958
			local py = (hash01(i * 31.1) + time * (0.012 + i % 3 * 0.006)) % 1 * h -- 959
			local tw = 0.45 + 0.55 * math.sin(time * 2.1 + i * 1.4) -- 960
			local isWarm = i % 3 == 0 and px > w * 0.45 -- 961
			local col = isWarm and PALETTE.amberCore or PALETTE.jadeMist -- 962
			local r = 1 + i % 3 * 0.55 -- 963
			fgGlow:drawDot( -- 964
				Vec2(px, py), -- 964
				r, -- 964
				toColor(col, (isWarm and 132 or 76) * tw) -- 964
			) -- 964
			i = i + 1 -- 956
		end -- 956
	end -- 956
end -- 904
return ____exports -- 904