-- [ts]: vfx.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 10
local Color = ____Dora.Color -- 10
local Vec2 = ____Dora.Vec2 -- 10
local ____depth = require("Script.watch.depth") -- 12
local ACTOR_DEPTH_HALF = ____depth.ACTOR_DEPTH_HALF -- 12
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 12
local overlapsDepth = ____depth.overlapsDepth -- 12
local ____theme = require("Script.watch.fe.theme") -- 16
local PALETTE = ____theme.PALETTE -- 18
local fillHGradRect = ____theme.fillHGradRect -- 20
local fillRadialGlow = ____theme.fillRadialGlow -- 21
local fillVGradRect = ____theme.fillVGradRect -- 22
local themeOf = ____theme.themeOf -- 23
local toColor = ____theme.toColor -- 24
local AMBIENT_COUNT = 34 -- 82
____exports.VfxSystem = __TS__Class() -- 84
local VfxSystem = ____exports.VfxSystem -- 84
VfxSystem.name = "VfxSystem" -- 84
function VfxSystem.prototype.____constructor(self) -- 104
	self.sparks = {} -- 85
	self.rings = {} -- 86
	self.tracers = {} -- 87
	self.plumes = {} -- 88
	self.bursts = {} -- 89
	self.motes = {} -- 90
	self.hitVignette = 0 -- 93
	self.deflectFlash = 0 -- 95
	self.deflectX = 0 -- 96
	self.deflectY = 0 -- 97
	self.visualHitstop = 0 -- 99
	self.crosshairKick = 0 -- 101
	self.rngState = 1337 -- 102
	self:initAmbient() -- 105
end -- 104
function VfxSystem.prototype.rand(self) -- 108
	self.rngState = (self.rngState * 1664525 + 1013904223) % 4294967296 -- 109
	return self.rngState / 4294967296 -- 110
end -- 108
function VfxSystem.prototype.initAmbient(self) -- 113
	self.motes = {} -- 114
	local i = 0 -- 115
	do -- 115
		i = 0 -- 116
		while i < AMBIENT_COUNT do -- 116
			local ____self_motes_0 = self.motes -- 116
			____self_motes_0[#____self_motes_0 + 1] = { -- 117
				fx = self:rand(), -- 118
				fy = self:rand(), -- 119
				vx = (self:rand() - 0.5) * 0.04, -- 120
				vy = 0.02 + self:rand() * 0.05, -- 121
				size = 1.2 + self:rand() * 2.2, -- 122
				phase = self:rand() * math.pi * 2 -- 123
			} -- 123
			i = i + 1 -- 116
		end -- 116
	end -- 116
end -- 113
function VfxSystem.prototype.reset(self) -- 128
	self.sparks = {} -- 129
	self.rings = {} -- 130
	self.tracers = {} -- 131
	self.plumes = {} -- 132
	self.bursts = {} -- 133
	self.hitVignette = 0 -- 134
	self.deflectFlash = 0 -- 135
	self.visualHitstop = 0 -- 136
	self.crosshairKick = 0 -- 137
end -- 128
function VfxSystem.prototype.ingest(self, ev, p, cam) -- 141
	if ev.roomChanged then -- 141
		self:reset() -- 143
	end -- 143
	if ev.shotFired and ev.shotTrace ~= nil then -- 143
		self:spawnShot(ev.shotTrace) -- 147
		self.crosshairKick = 12 -- 148
		cam:addShake(ev.shotHit and 6.5 or 3.2) -- 149
		if ev.shotHit then -- 149
			self.visualHitstop = 0.045 -- 151
		end -- 151
	end -- 151
	if ev.enemyKilledX > -5000 then -- 151
		self:spawnBurst( -- 156
			ev.enemyKilledX, -- 156
			ev.enemyKilledY, -- 156
			14, -- 156
			PALETTE.sealRedBright, -- 156
			175 -- 156
		) -- 156
		self:spawnBurst( -- 157
			ev.enemyKilledX, -- 157
			ev.enemyKilledY, -- 157
			7, -- 157
			PALETTE.amberDim, -- 157
			130 -- 157
		) -- 157
		local ____self_rings_1 = self.rings -- 157
		____self_rings_1[#____self_rings_1 + 1] = { -- 158
			x = ev.enemyKilledX, -- 158
			y = ev.enemyKilledY, -- 158
			maxR = 40, -- 158
			life = 0.34, -- 158
			maxLife = 0.34, -- 158
			color = PALETTE.sealRed -- 158
		} -- 158
	end -- 158
	if ev.coverDeflect then -- 158
		self.deflectFlash = 1 -- 162
		self.deflectX = p.player.x + p.player.facing * 16 -- 163
		self.deflectY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.48 -- 164
		local nearest = 48 -- 165
		for ____, solid in ipairs(p.room.solids) do -- 166
			local edge = p.player.x < solid.x and solid.x or solid.x + solid.w -- 167
			local gap = math.abs(p.player.x - edge) -- 168
			if not solid.passable and not solid.decorative and solid.y <= p.player.y + 2 and solid.h <= 64 and gap < nearest and overlapsDepth(p.player.depth, solid.depth, ACTOR_DEPTH_HALF) then -- 168
				nearest = gap -- 171
				self.deflectX = edge -- 172
				local ____solid_y_4 = solid.y -- 173
				local ____opt_2 = solid.depth -- 173
				self.deflectY = ____solid_y_4 + (____opt_2 and ____opt_2.min or 0) * DEPTH_Y_SCALE + solid.h * 0.86 -- 173
			end -- 173
		end -- 173
		self:spawnBurst( -- 176
			self.deflectX, -- 176
			self.deflectY, -- 176
			8, -- 176
			PALETTE.amberDim, -- 176
			115 -- 176
		) -- 176
		cam:addShake(2.6) -- 177
	end -- 177
	if ev.playerHit then -- 177
		self.hitVignette = 1 -- 181
		self:spawnBurst( -- 182
			p.player.x, -- 182
			p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.55, -- 182
			14, -- 182
			PALETTE.sealRedBright, -- 182
			185 -- 182
		) -- 182
		cam:addShake(10) -- 183
		self.visualHitstop = 0.055 -- 184
	end -- 184
	if ev.rollStarted then -- 184
		self:spawnBurst( -- 188
			p.player.x, -- 188
			p.player.y + p.player.depth * DEPTH_Y_SCALE + 4, -- 188
			7, -- 188
			PALETTE.textDim, -- 188
			82 -- 188
		) -- 188
	end -- 188
	if ev.knockPulse then -- 188
		local ____self_rings_5 = self.rings -- 188
		____self_rings_5[#____self_rings_5 + 1] = { -- 192
			x = ev.knockX, -- 192
			y = ev.knockY, -- 192
			maxR = 52, -- 192
			life = 0.55, -- 192
			maxLife = 0.55, -- 192
			color = PALETTE.amber -- 192
		} -- 192
		local ____self_rings_6 = self.rings -- 192
		____self_rings_6[#____self_rings_6 + 1] = { -- 193
			x = ev.knockX, -- 193
			y = ev.knockY, -- 193
			maxR = 32, -- 193
			life = 0.38, -- 193
			maxLife = 0.38, -- 193
			color = PALETTE.xuanWarm -- 193
		} -- 193
	end -- 193
	if ev.bottleLanded then -- 193
		local ly = ev.bottleLandY -- 197
		local isBrick = p.room.brickX ~= nil and math.abs(ev.bottleLandX - p.room.brickX) <= 36 -- 198
		local ringCol = isBrick and PALETTE.amber or PALETTE.emerald -- 199
		local ____self_rings_7 = self.rings -- 199
		____self_rings_7[#____self_rings_7 + 1] = { -- 200
			x = ev.bottleLandX, -- 200
			y = ly + 4, -- 200
			maxR = isBrick and 96 or 38, -- 200
			life = 0.85, -- 200
			maxLife = 0.85, -- 200
			color = ringCol -- 200
		} -- 200
		local ____self_rings_8 = self.rings -- 200
		____self_rings_8[#____self_rings_8 + 1] = { -- 201
			x = ev.bottleLandX, -- 201
			y = ly + 4, -- 201
			maxR = isBrick and 62 or 22, -- 201
			life = 0.52, -- 201
			maxLife = 0.52, -- 201
			color = PALETTE.xuanWarm -- 201
		} -- 201
		self:spawnBurst( -- 202
			ev.bottleLandX, -- 202
			ly + 6, -- 202
			10, -- 202
			PALETTE.amberDim, -- 202
			120 -- 202
		) -- 202
		cam:addShake(isBrick and 3.5 or 1.5) -- 203
	end -- 203
	if ev.cartJustDocked then -- 203
		local cx = p.cartAxle -- 207
		local cy = p.room.cart.baseY + (p.room.cart.depth or 0) * DEPTH_Y_SCALE + 8 -- 208
		local ____self_rings_9 = self.rings -- 208
		____self_rings_9[#____self_rings_9 + 1] = { -- 209
			x = cx, -- 209
			y = cy, -- 209
			maxR = 58, -- 209
			life = 0.55, -- 209
			maxLife = 0.55, -- 209
			color = PALETTE.emerald -- 209
		} -- 209
		self:spawnBurst( -- 210
			cx, -- 210
			cy, -- 210
			12, -- 210
			PALETTE.amber, -- 210
			115 -- 210
		) -- 210
		cam:addShake(4.8) -- 211
	end -- 211
	if ev.caughtTriggered then -- 211
		self.hitVignette = 0.9 -- 215
		cam:addShake(9) -- 216
	end -- 216
end -- 141
function VfxSystem.prototype.spawnShot(self, t) -- 220
	local ____self_tracers_10 = self.tracers -- 220
	____self_tracers_10[#____self_tracers_10 + 1] = { -- 221
		x0 = t.x0, -- 222
		y0 = t.y0, -- 222
		x1 = t.x1, -- 222
		y1 = t.y1, -- 222
		hit = t.hit, -- 223
		life = 0.16, -- 223
		maxLife = 0.16 -- 223
	} -- 223
	local ____self_plumes_11 = self.plumes -- 223
	____self_plumes_11[#____self_plumes_11 + 1] = { -- 225
		x = t.x0, -- 226
		y = t.y0, -- 226
		dir = t.x1 >= t.x0 and 1 or -1, -- 226
		life = 0.44, -- 227
		maxLife = 0.44 -- 227
	} -- 227
	local ____self_bursts_12 = self.bursts -- 227
	____self_bursts_12[#____self_bursts_12 + 1] = { -- 229
		x = t.x1, -- 230
		y = t.y1, -- 230
		hit = t.hit, -- 230
		life = 0.28, -- 231
		maxLife = 0.28 -- 231
	} -- 231
	self:spawnBurst( -- 234
		t.x0, -- 234
		t.y0, -- 234
		5, -- 234
		PALETTE.amberCore, -- 234
		105 -- 234
	) -- 234
	self:spawnBurst( -- 235
		t.x1, -- 235
		t.y1, -- 235
		t.hit and 9 or 6, -- 235
		t.hit and PALETTE.sealRedBright or PALETTE.amberDim, -- 235
		130 -- 235
	) -- 235
end -- 220
function VfxSystem.prototype.spawnBurst(self, wx, wy, count, color, speed) -- 238
	local i = 0 -- 239
	do -- 239
		i = 0 -- 240
		while i < count do -- 240
			local a = self:rand() * math.pi * 2 -- 241
			local s = speed * (0.35 + self:rand() * 0.85) -- 242
			local life = 0.22 + self:rand() * 0.26 -- 243
			local ____self_sparks_13 = self.sparks -- 243
			____self_sparks_13[#____self_sparks_13 + 1] = { -- 244
				x = wx, -- 245
				y = wy, -- 245
				vx = math.cos(a) * s, -- 246
				vy = math.sin(a) * s + 35, -- 247
				life = life, -- 248
				maxLife = life, -- 248
				size = 1.8 + self:rand() * 2.4, -- 249
				color = color -- 250
			} -- 250
			i = i + 1 -- 240
		end -- 240
	end -- 240
end -- 238
function VfxSystem.prototype.update(self, dt, ambient) -- 255
	if self.visualHitstop > 0 then -- 255
		self.visualHitstop = math.max(0, self.visualHitstop - dt) -- 257
		return -- 258
	end -- 258
	self.hitVignette = math.max(0, self.hitVignette - dt * 2.2) -- 260
	self.deflectFlash = math.max(0, self.deflectFlash - dt * 3.2) -- 261
	self.crosshairKick = math.max(0, self.crosshairKick - dt * 48) -- 262
	local w = 0 -- 265
	local i = 0 -- 266
	do -- 266
		i = 0 -- 267
		while i < #self.tracers do -- 267
			local tr = self.tracers[i + 1] -- 268
			tr.life = tr.life - dt -- 269
			if tr.life > 0 then -- 269
				self.tracers[w + 1] = tr -- 271
				w = w + 1 -- 272
			end -- 272
			i = i + 1 -- 267
		end -- 267
	end -- 267
	__TS__ArraySetLength(self.tracers, w) -- 267
	w = 0 -- 278
	do -- 278
		i = 0 -- 279
		while i < #self.plumes do -- 279
			local pl = self.plumes[i + 1] -- 280
			pl.life = pl.life - dt -- 281
			if pl.life > 0 then -- 281
				pl.x = pl.x + pl.dir * 24 * dt * (pl.life / pl.maxLife) -- 283
				pl.y = pl.y + 18 * dt -- 284
				self.plumes[w + 1] = pl -- 285
				w = w + 1 -- 286
			end -- 286
			i = i + 1 -- 279
		end -- 279
	end -- 279
	__TS__ArraySetLength(self.plumes, w) -- 279
	w = 0 -- 292
	do -- 292
		i = 0 -- 293
		while i < #self.bursts do -- 293
			local bu = self.bursts[i + 1] -- 294
			bu.life = bu.life - dt -- 295
			if bu.life > 0 then -- 295
				self.bursts[w + 1] = bu -- 297
				w = w + 1 -- 298
			end -- 298
			i = i + 1 -- 293
		end -- 293
	end -- 293
	__TS__ArraySetLength(self.bursts, w) -- 293
	w = 0 -- 304
	do -- 304
		i = 0 -- 305
		while i < #self.sparks do -- 305
			local sp = self.sparks[i + 1] -- 306
			sp.life = sp.life - dt -- 307
			if sp.life > 0 then -- 307
				sp.vy = sp.vy - 420 * dt -- 309
				sp.x = sp.x + sp.vx * dt -- 310
				sp.y = sp.y + sp.vy * dt -- 311
				if sp.y < 0 then -- 311
					sp.y = 0 -- 313
					sp.vy = -sp.vy * 0.35 -- 314
					sp.vx = sp.vx * 0.7 -- 315
				end -- 315
				self.sparks[w + 1] = sp -- 317
				w = w + 1 -- 318
			end -- 318
			i = i + 1 -- 305
		end -- 305
	end -- 305
	__TS__ArraySetLength(self.sparks, w) -- 305
	w = 0 -- 324
	do -- 324
		i = 0 -- 325
		while i < #self.rings do -- 325
			local rg = self.rings[i + 1] -- 326
			rg.life = rg.life - dt -- 327
			if rg.life > 0 then -- 327
				self.rings[w + 1] = rg -- 329
				w = w + 1 -- 330
			end -- 330
			i = i + 1 -- 325
		end -- 325
	end -- 325
	__TS__ArraySetLength(self.rings, w) -- 325
	do -- 325
		i = 0 -- 336
		while i < #self.motes do -- 336
			local m = self.motes[i + 1] -- 337
			m.phase = m.phase + dt * 2 -- 338
			if ambient == "drizzle" then -- 338
				m.fx = m.fx - dt * 0.14 -- 340
				m.fy = m.fy - dt * 0.72 -- 341
			elseif ambient == "ash" then -- 341
				m.fx = m.fx + (m.vx - 0.035) * dt -- 343
				m.fy = m.fy + m.vy * 0.55 * dt -- 344
			elseif ambient == "spores" then -- 344
				m.fx = m.fx + math.sin(m.phase) * 0.015 * dt -- 346
				m.fy = m.fy + math.cos(m.phase * 0.7) * 0.018 * dt -- 347
			else -- 347
				m.fx = m.fx + math.sin(m.phase * 0.6) * 0.01 * dt -- 349
				m.fy = m.fy + 0.018 * dt -- 350
			end -- 350
			if m.fx < 0 then -- 350
				m.fx = m.fx + 1 -- 352
			end -- 352
			if m.fx > 1 then -- 352
				m.fx = m.fx - 1 -- 353
			end -- 353
			if m.fy < 0 then -- 353
				m.fy = m.fy + 1 -- 354
			end -- 354
			if m.fy > 1 then -- 354
				m.fy = m.fy - 1 -- 355
			end -- 355
			i = i + 1 -- 336
		end -- 336
	end -- 336
end -- 255
function VfxSystem.prototype.drawWorldVfx(self, fgGlow, assets, cam) -- 360
	local i = 0 -- 362
	do -- 362
		i = 0 -- 363
		while i < #self.tracers do -- 363
			local tr = self.tracers[i + 1] -- 364
			local k = tr.life / tr.maxLife -- 365
			local x0 = cam:sx(tr.x0) -- 366
			local y0 = cam:sy(tr.y0) -- 367
			local x1 = cam:sx(tr.x1) -- 368
			local y1 = cam:sy(tr.y1) -- 369
			local outerCol = tr.hit and PALETTE.sealRedBright or PALETTE.amber -- 370
			fgGlow:drawSegment( -- 373
				Vec2(x0, y0), -- 373
				Vec2(x1, y1), -- 373
				3.2 * k, -- 373
				toColor(outerCol, 88 * k) -- 373
			) -- 373
			fgGlow:drawSegment( -- 374
				Vec2(x0, y0), -- 374
				Vec2(x1, y1), -- 374
				1.3 * k, -- 374
				toColor(PALETTE.amberCore, 195 * k) -- 374
			) -- 374
			if k > 0.45 then -- 374
				local mk = (k - 0.45) / 0.55 -- 378
				local shotAngle = -math.atan(y1 - y0, x1 - x0) * 180 / math.pi -- 379
				local blastH = math.max( -- 380
					18, -- 380
					cam:len(22 * (0.78 + 0.32 * mk)) -- 380
				) -- 380
				fillRadialGlow( -- 381
					fgGlow, -- 381
					x0, -- 381
					y0, -- 381
					20 * mk, -- 381
					16 * mk, -- 381
					toColor(PALETTE.amberCore, 128 * mk), -- 381
					Color(186, 126, 62, 0), -- 381
					12 -- 381
				) -- 381
				if not assets:tryPlacePath( -- 381
					"assets/art/vfx_craft_art.clip|vfx_muzzle_blast", -- 382
					"vfx_muzzle_" .. tostring(i), -- 382
					x0, -- 382
					y0, -- 382
					blastH * 1.7, -- 382
					blastH, -- 382
					{ -- 382
						anchorX = 0.14, -- 383
						anchorY = 0.42, -- 384
						preserveAspect = true, -- 385
						angle = shotAngle, -- 386
						opacity = math.min(1, mk * 1.15), -- 387
						smooth = true, -- 388
						layer = 9 -- 389
					} -- 389
				) then -- 389
					fgGlow:drawSegment( -- 391
						Vec2(x0 - 10 * mk, y0), -- 391
						Vec2(x0 + 10 * mk, y0), -- 391
						1.2, -- 391
						toColor(PALETTE.amberCore, 165 * mk) -- 391
					) -- 391
					fgGlow:drawSegment( -- 392
						Vec2(x0, y0 - 7 * mk), -- 392
						Vec2(x0, y0 + 7 * mk), -- 392
						1, -- 392
						toColor(PALETTE.amber, 145 * mk) -- 392
					) -- 392
				end -- 392
			end -- 392
			if tr.hit then -- 392
				local s = 16 * (1.15 - k * 0.45) -- 397
				fillRadialGlow( -- 398
					fgGlow, -- 398
					x1, -- 398
					y1, -- 398
					s * 1.15, -- 398
					s * 0.9, -- 398
					toColor(PALETTE.sealRedBright, 130 * k), -- 398
					Color(168, 46, 44, 0), -- 398
					12 -- 398
				) -- 398
				fgGlow:drawSegment( -- 399
					Vec2(x1 - s, y1 - s * 0.55), -- 399
					Vec2(x1 + s, y1 + s * 0.55), -- 399
					1.6 * k, -- 399
					toColor(PALETTE.crimsonCore, 185 * k) -- 399
				) -- 399
				fgGlow:drawSegment( -- 400
					Vec2(x1 - s * 0.45, y1 + s * 0.7), -- 400
					Vec2(x1 + s * 0.45, y1 - s * 0.7), -- 400
					1.2 * k, -- 400
					toColor(PALETTE.sealRedBright, 160 * k) -- 400
				) -- 400
			end -- 400
			i = i + 1 -- 363
		end -- 363
	end -- 363
	do -- 363
		i = 0 -- 405
		while i < #self.plumes do -- 405
			local pl = self.plumes[i + 1] -- 406
			local k = pl.life / pl.maxLife -- 407
			local grow = 1 - k -- 408
			local size = cam:len(18 + grow * 28) -- 409
			assets:tryPlacePath( -- 410
				"assets/art/vfx_craft_art.clip|vfx_smoke_plume", -- 410
				"vfx_smoke_" .. tostring(i), -- 410
				cam:sx(pl.x), -- 410
				cam:sy(pl.y), -- 410
				size, -- 410
				size, -- 410
				{ -- 410
					anchorX = 0.5, -- 411
					anchorY = 0.5, -- 412
					preserveAspect = true, -- 413
					facing = pl.dir, -- 414
					opacity = k * 0.68, -- 415
					smooth = true, -- 416
					layer = 8 -- 417
				} -- 417
			) -- 417
			i = i + 1 -- 405
		end -- 405
	end -- 405
	do -- 405
		i = 0 -- 422
		while i < #self.bursts do -- 422
			local bu = self.bursts[i + 1] -- 423
			local k = bu.life / bu.maxLife -- 424
			local size = cam:len(16 + (1 - k) * 20) -- 425
			assets:tryPlacePath( -- 426
				"assets/art/vfx_craft_art.clip|vfx_debris_burst", -- 426
				"vfx_impact_" .. tostring(i), -- 426
				cam:sx(bu.x), -- 426
				cam:sy(bu.y), -- 426
				size, -- 426
				size, -- 426
				{ -- 426
					anchorX = 0.5, -- 427
					anchorY = 0.5, -- 428
					preserveAspect = true, -- 429
					color = bu.hit and Color(246, 174, 152, 255) or Color(235, 224, 206, 255), -- 430
					opacity = k * 0.88, -- 431
					smooth = true, -- 432
					layer = 9 -- 433
				} -- 433
			) -- 433
			i = i + 1 -- 422
		end -- 422
	end -- 422
	if self.deflectFlash > 0 then -- 422
		local k = self.deflectFlash -- 438
		local dy = cam:sy(self.deflectY + (1 - k) * 11) -- 439
		local height = cam:len(22 + (1 - k) * 16) -- 440
		if not assets:tryPlacePath( -- 440
			"assets/art/vfx_craft_art.clip|vfx_debris_burst", -- 441
			"blocked", -- 441
			cam:sx(self.deflectX), -- 441
			dy, -- 441
			height, -- 441
			height, -- 441
			{ -- 441
				anchorX = 0.5, -- 442
				anchorY = 0.5, -- 443
				preserveAspect = true, -- 444
				opacity = k * 0.92, -- 445
				smooth = true, -- 446
				layer = 8 -- 447
			} -- 447
		) then -- 447
			assets:tryPlace( -- 449
				"stone_chips", -- 449
				"blocked", -- 449
				cam:sx(self.deflectX), -- 449
				dy, -- 449
				height, -- 449
				height, -- 449
				{opacity = k, layer = 8} -- 449
			) -- 449
		end -- 449
	end -- 449
	do -- 449
		i = 0 -- 456
		while i < #self.rings do -- 456
			local rg = self.rings[i + 1] -- 457
			local prog = 1 - rg.life / rg.maxLife -- 458
			local r = math.max( -- 459
				4, -- 459
				cam:len(rg.maxR) * prog -- 459
			) -- 459
			local alpha = (1 - prog) * 0.8 -- 460
			local rx = cam:sx(rg.x) -- 461
			local ry = cam:sy(rg.y) -- 462
			if not assets:tryPlace( -- 462
				"ink_enso_fine", -- 463
				"vfx_ring_" .. tostring(i), -- 463
				rx, -- 463
				ry, -- 463
				r * 2.35, -- 463
				r * 2.35, -- 463
				{ -- 463
					color = toColor(rg.color), -- 464
					opacity = alpha, -- 464
					angle = prog * 24, -- 464
					layer = 7 -- 464
				} -- 464
			) then -- 464
				fgGlow:drawRing( -- 466
					Vec2(rx, ry), -- 466
					math.max(1, r - 1.8), -- 466
					r, -- 466
					Color(0, 0, 0, 0), -- 466
					1.2, -- 466
					toColor(rg.color, alpha * 230) -- 466
				) -- 466
			end -- 466
			i = i + 1 -- 456
		end -- 456
	end -- 456
	do -- 456
		i = 0 -- 471
		while i < #self.sparks do -- 471
			local sp = self.sparks[i + 1] -- 472
			local k = sp.life / sp.maxLife -- 473
			local sx = cam:sx(sp.x) -- 474
			local sy = cam:sy(sp.y) -- 475
			local tx = sx - sp.vx * 0.02 * cam.ppu -- 476
			local ty = sy - sp.vy * 0.02 * cam.ppu -- 477
			fgGlow:drawSegment( -- 478
				Vec2(tx, ty), -- 478
				Vec2(sx, sy), -- 478
				sp.size * k * 0.9, -- 478
				toColor(sp.color, 210 * k) -- 478
			) -- 478
			i = i + 1 -- 471
		end -- 471
	end -- 471
end -- 360
function VfxSystem.prototype.drawScreenVfx(self, fgGlow, w, h, roomKey) -- 483
	local theme = themeOf(roomKey) -- 484
	local kind = theme.ambient -- 485
	local i = 0 -- 486
	do -- 486
		i = 0 -- 487
		while i < #self.motes do -- 487
			local m = self.motes[i + 1] -- 488
			local x = m.fx * w -- 489
			local y = m.fy * h -- 490
			local tw = 0.55 + 0.45 * math.sin(m.phase) -- 491
			if kind == "drizzle" then -- 491
				fgGlow:drawSegment( -- 493
					Vec2(x, y), -- 493
					Vec2(x + 4, y + 18), -- 493
					0.85, -- 493
					Color( -- 493
						156, -- 493
						174, -- 493
						188, -- 493
						math.floor(44 * tw + 0.5) -- 493
					) -- 493
				) -- 493
			elseif kind == "ash" then -- 493
				local c = roomKey == "gate" and PALETTE.sealRedBright or PALETTE.amberDim -- 495
				fgGlow:drawDot( -- 496
					Vec2(x, y), -- 496
					m.size * 0.82, -- 496
					toColor(c, 78 * tw) -- 496
				) -- 496
			elseif kind == "spores" then -- 496
				fgGlow:drawDot( -- 498
					Vec2(x, y), -- 498
					m.size * 0.9, -- 498
					toColor(PALETTE.emerald, 82 * tw) -- 498
				) -- 498
			else -- 498
				fgGlow:drawDot( -- 500
					Vec2(x, y), -- 500
					m.size * 0.95, -- 500
					toColor(PALETTE.amberCore, 94 * tw) -- 500
				) -- 500
			end -- 500
			i = i + 1 -- 487
		end -- 487
	end -- 487
	if self.hitVignette > 0.01 then -- 487
		local a = math.floor(120 * self.hitVignette + 0.5) -- 506
		local edge = 72 -- 507
		fillHGradRect( -- 508
			fgGlow, -- 508
			0, -- 508
			0, -- 508
			edge, -- 508
			h, -- 508
			Color(148, 36, 32, a), -- 508
			Color(148, 36, 32, 0) -- 508
		) -- 508
		fillHGradRect( -- 509
			fgGlow, -- 509
			w - edge, -- 509
			0, -- 509
			edge, -- 509
			h, -- 509
			Color(148, 36, 32, 0), -- 509
			Color(148, 36, 32, a) -- 509
		) -- 509
		fillVGradRect( -- 510
			fgGlow, -- 510
			0, -- 510
			0, -- 510
			w, -- 510
			edge * 0.8, -- 510
			Color(148, 36, 32, a), -- 510
			Color(148, 36, 32, 0) -- 510
		) -- 510
		fillVGradRect( -- 511
			fgGlow, -- 511
			0, -- 511
			h - edge * 0.8, -- 511
			w, -- 511
			edge * 0.8, -- 511
			Color(148, 36, 32, 0), -- 511
			Color(148, 36, 32, a) -- 511
		) -- 511
	end -- 511
end -- 483
return ____exports -- 483