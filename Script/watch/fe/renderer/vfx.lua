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
local ____theme = require("Script.watch.fe.theme") -- 17
local PALETTE = ____theme.PALETTE -- 19
local fillHGradRect = ____theme.fillHGradRect -- 21
local fillRadialGlow = ____theme.fillRadialGlow -- 22
local fillVGradRect = ____theme.fillVGradRect -- 23
local themeOf = ____theme.themeOf -- 24
local toColor = ____theme.toColor -- 25
local AMBIENT_COUNT = 34 -- 94
local MUZZLE_CLIPS = {"assets/art/vfx_ming_fx.clip|muzzle_0", "assets/art/vfx_ming_fx.clip|muzzle_1", "assets/art/vfx_ming_fx.clip|muzzle_2", "assets/art/vfx_ming_fx.clip|muzzle_3"} -- 96
local SMOKE_CLIPS = {"assets/art/vfx_ming_fx.clip|smoke_0", "assets/art/vfx_ming_fx.clip|smoke_1", "assets/art/vfx_ming_fx.clip|smoke_2", "assets/art/vfx_ming_fx.clip|smoke_3"} -- 102
local HIT_SPARK_CLIP = "assets/art/vfx_ming_fx.clip|hit_spark_0" -- 108
local DEBRIS_CLIP = "assets/art/vfx_ming_fx.clip|debris_0" -- 109
local STEP_DUST_CLIPS = {"assets/art/vfx_ming_fx.clip|dust_0", "assets/art/vfx_ming_fx.clip|dust_1"} -- 110
____exports.VfxSystem = __TS__Class() -- 115
local VfxSystem = ____exports.VfxSystem -- 115
VfxSystem.name = "VfxSystem" -- 115
function VfxSystem.prototype.____constructor(self) -- 136
	self.sparks = {} -- 116
	self.rings = {} -- 117
	self.tracers = {} -- 118
	self.plumes = {} -- 119
	self.bursts = {} -- 120
	self.stepDusts = {} -- 121
	self.motes = {} -- 122
	self.hitVignette = 0 -- 125
	self.deflectFlash = 0 -- 127
	self.deflectX = 0 -- 128
	self.deflectY = 0 -- 129
	self.visualHitstop = 0 -- 131
	self.crosshairKick = 0 -- 133
	self.rngState = 1337 -- 134
	self:initAmbient() -- 137
end -- 136
function VfxSystem.prototype.rand(self) -- 140
	self.rngState = (self.rngState * 1664525 + 1013904223) % 4294967296 -- 141
	return self.rngState / 4294967296 -- 142
end -- 140
function VfxSystem.prototype.initAmbient(self) -- 145
	self.motes = {} -- 146
	local i = 0 -- 147
	do -- 147
		i = 0 -- 148
		while i < AMBIENT_COUNT do -- 148
			local ____self_motes_0 = self.motes -- 148
			____self_motes_0[#____self_motes_0 + 1] = { -- 149
				fx = self:rand(), -- 150
				fy = self:rand(), -- 151
				vx = (self:rand() - 0.5) * 0.04, -- 152
				vy = 0.02 + self:rand() * 0.05, -- 153
				size = 1.2 + self:rand() * 2.2, -- 154
				phase = self:rand() * math.pi * 2 -- 155
			} -- 155
			i = i + 1 -- 148
		end -- 148
	end -- 148
end -- 145
function VfxSystem.prototype.reset(self) -- 160
	self.sparks = {} -- 161
	self.rings = {} -- 162
	self.tracers = {} -- 163
	self.plumes = {} -- 164
	self.bursts = {} -- 165
	self.stepDusts = {} -- 166
	self.hitVignette = 0 -- 167
	self.deflectFlash = 0 -- 168
	self.visualHitstop = 0 -- 169
	self.crosshairKick = 0 -- 170
end -- 160
function VfxSystem.prototype.ingestFootsteps(self, cues) -- 174
	do -- 174
		local i = 0 -- 175
		while i < #cues do -- 175
			local c = cues[i + 1] -- 176
			if #self.stepDusts >= 26 then -- 176
				table.remove(self.stepDusts, 1) -- 178
			end -- 178
			local wide = c.kind == "land" or c.kind == "brake" -- 180
			local maxLife = c.kind == "land" and 0.34 or (c.kind == "brake" and 0.28 or 0.22) -- 181
			local ____self_stepDusts_1 = self.stepDusts -- 181
			____self_stepDusts_1[#____self_stepDusts_1 + 1] = { -- 182
				x = c.x, -- 183
				y = c.y, -- 184
				depth = c.depth, -- 185
				facing = c.facing, -- 186
				life = maxLife, -- 187
				maxLife = maxLife, -- 188
				scale = (wide and 1.15 or 0.78) * math.max(0.6, c.strength), -- 189
				wide = wide -- 190
			} -- 190
			if c.kind == "land" then -- 190
				local ____self_stepDusts_2 = self.stepDusts -- 190
				____self_stepDusts_2[#____self_stepDusts_2 + 1] = { -- 193
					x = c.x + c.facing * 8, -- 194
					y = c.y, -- 195
					depth = c.depth, -- 196
					facing = -c.facing, -- 197
					life = maxLife * 0.9, -- 198
					maxLife = maxLife * 0.9, -- 199
					scale = 0.92 * math.max(0.6, c.strength), -- 200
					wide = true -- 201
				} -- 201
			end -- 201
			i = i + 1 -- 175
		end -- 175
	end -- 175
end -- 174
function VfxSystem.prototype.ingest(self, ev, p, cam) -- 208
	if ev.roomChanged then -- 208
		self:reset() -- 210
	end -- 210
	if ev.shotFired and ev.shotTrace ~= nil then -- 210
		self:spawnShot(ev.shotTrace) -- 214
		self.crosshairKick = 12 -- 215
		cam:addShake(ev.shotHit and 6.5 or 3.2) -- 216
		if ev.shotHit then -- 216
			self.visualHitstop = 0.045 -- 218
		end -- 218
	end -- 218
	if ev.enemyKilledX > -5000 then -- 218
		self:spawnBurst( -- 223
			ev.enemyKilledX, -- 223
			ev.enemyKilledY, -- 223
			14, -- 223
			PALETTE.sealRedBright, -- 223
			175 -- 223
		) -- 223
		self:spawnBurst( -- 224
			ev.enemyKilledX, -- 224
			ev.enemyKilledY, -- 224
			7, -- 224
			PALETTE.amberDim, -- 224
			130 -- 224
		) -- 224
		local ____self_rings_3 = self.rings -- 224
		____self_rings_3[#____self_rings_3 + 1] = { -- 225
			x = ev.enemyKilledX, -- 225
			y = ev.enemyKilledY, -- 225
			maxR = 40, -- 225
			life = 0.34, -- 225
			maxLife = 0.34, -- 225
			color = PALETTE.sealRed -- 225
		} -- 225
	end -- 225
	if ev.coverDeflect then -- 225
		self.deflectFlash = 1 -- 229
		self.deflectX = p.player.x + p.player.facing * 16 -- 230
		self.deflectY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.48 -- 231
		local nearest = 48 -- 232
		for ____, solid in ipairs(p.room.solids) do -- 233
			local edge = p.player.x < solid.x and solid.x or solid.x + solid.w -- 234
			local gap = math.abs(p.player.x - edge) -- 235
			if not solid.passable and not solid.decorative and solid.y <= p.player.y + 2 and solid.h <= 64 and gap < nearest and overlapsDepth(p.player.depth, solid.depth, ACTOR_DEPTH_HALF) then -- 235
				nearest = gap -- 238
				self.deflectX = edge -- 239
				local ____solid_y_6 = solid.y -- 240
				local ____opt_4 = solid.depth -- 240
				self.deflectY = ____solid_y_6 + (____opt_4 and ____opt_4.min or 0) * DEPTH_Y_SCALE + solid.h * 0.86 -- 240
			end -- 240
		end -- 240
		self:spawnBurst( -- 243
			self.deflectX, -- 243
			self.deflectY, -- 243
			8, -- 243
			PALETTE.amberDim, -- 243
			115 -- 243
		) -- 243
		cam:addShake(2.6) -- 244
	end -- 244
	if ev.playerHit then -- 244
		self.hitVignette = 1 -- 248
		self:spawnBurst( -- 249
			p.player.x, -- 249
			p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.55, -- 249
			14, -- 249
			PALETTE.sealRedBright, -- 249
			185 -- 249
		) -- 249
		cam:addShake(10) -- 250
		self.visualHitstop = 0.055 -- 251
	end -- 251
	if ev.rollStarted then -- 251
		self:spawnBurst( -- 255
			p.player.x, -- 255
			p.player.y + p.player.depth * DEPTH_Y_SCALE + 4, -- 255
			7, -- 255
			PALETTE.textDim, -- 255
			82 -- 255
		) -- 255
	end -- 255
	if ev.knockPulse then -- 255
		local ____self_rings_7 = self.rings -- 255
		____self_rings_7[#____self_rings_7 + 1] = { -- 259
			x = ev.knockX, -- 259
			y = ev.knockY, -- 259
			maxR = 52, -- 259
			life = 0.55, -- 259
			maxLife = 0.55, -- 259
			color = PALETTE.amber -- 259
		} -- 259
		local ____self_rings_8 = self.rings -- 259
		____self_rings_8[#____self_rings_8 + 1] = { -- 260
			x = ev.knockX, -- 260
			y = ev.knockY, -- 260
			maxR = 32, -- 260
			life = 0.38, -- 260
			maxLife = 0.38, -- 260
			color = PALETTE.xuanWarm -- 260
		} -- 260
	end -- 260
	if ev.bottleLanded then -- 260
		local ly = ev.bottleLandY -- 264
		local isBrick = p.room.brickX ~= nil and math.abs(ev.bottleLandX - p.room.brickX) <= 36 -- 265
		local ringCol = isBrick and PALETTE.amber or PALETTE.emerald -- 266
		local ____self_rings_9 = self.rings -- 266
		____self_rings_9[#____self_rings_9 + 1] = { -- 267
			x = ev.bottleLandX, -- 267
			y = ly + 4, -- 267
			maxR = isBrick and 96 or 38, -- 267
			life = 0.85, -- 267
			maxLife = 0.85, -- 267
			color = ringCol -- 267
		} -- 267
		local ____self_rings_10 = self.rings -- 267
		____self_rings_10[#____self_rings_10 + 1] = { -- 268
			x = ev.bottleLandX, -- 268
			y = ly + 4, -- 268
			maxR = isBrick and 62 or 22, -- 268
			life = 0.52, -- 268
			maxLife = 0.52, -- 268
			color = PALETTE.xuanWarm -- 268
		} -- 268
		self:spawnBurst( -- 269
			ev.bottleLandX, -- 269
			ly + 6, -- 269
			10, -- 269
			PALETTE.amberDim, -- 269
			120 -- 269
		) -- 269
		cam:addShake(isBrick and 3.5 or 1.5) -- 270
	end -- 270
	if ev.cartJustDocked then -- 270
		local cx = p.cartAxle -- 274
		local cy = p.room.cart.baseY + (p.room.cart.depth or 0) * DEPTH_Y_SCALE + 8 -- 275
		local ____self_rings_11 = self.rings -- 275
		____self_rings_11[#____self_rings_11 + 1] = { -- 276
			x = cx, -- 276
			y = cy, -- 276
			maxR = 58, -- 276
			life = 0.55, -- 276
			maxLife = 0.55, -- 276
			color = PALETTE.emerald -- 276
		} -- 276
		self:spawnBurst( -- 277
			cx, -- 277
			cy, -- 277
			12, -- 277
			PALETTE.amber, -- 277
			115 -- 277
		) -- 277
		cam:addShake(4.8) -- 278
	end -- 278
	if ev.caughtTriggered then -- 278
		self.hitVignette = 0.9 -- 282
		cam:addShake(9) -- 283
	end -- 283
end -- 208
function VfxSystem.prototype.spawnShot(self, t) -- 287
	local ____self_tracers_12 = self.tracers -- 287
	____self_tracers_12[#____self_tracers_12 + 1] = { -- 288
		x0 = t.x0, -- 289
		y0 = t.y0, -- 289
		x1 = t.x1, -- 289
		y1 = t.y1, -- 289
		hit = t.hit, -- 290
		life = 0.16, -- 290
		maxLife = 0.16 -- 290
	} -- 290
	local ____self_plumes_13 = self.plumes -- 290
	____self_plumes_13[#____self_plumes_13 + 1] = { -- 292
		x = t.x0, -- 293
		y = t.y0, -- 293
		dir = t.x1 >= t.x0 and 1 or -1, -- 293
		life = 0.44, -- 294
		maxLife = 0.44 -- 294
	} -- 294
	local ____self_bursts_14 = self.bursts -- 294
	____self_bursts_14[#____self_bursts_14 + 1] = { -- 296
		x = t.x1, -- 297
		y = t.y1, -- 297
		hit = t.hit, -- 297
		life = 0.28, -- 298
		maxLife = 0.28 -- 298
	} -- 298
	self:spawnBurst( -- 301
		t.x0, -- 301
		t.y0, -- 301
		5, -- 301
		PALETTE.amberCore, -- 301
		105 -- 301
	) -- 301
	self:spawnBurst( -- 302
		t.x1, -- 302
		t.y1, -- 302
		t.hit and 9 or 6, -- 302
		t.hit and PALETTE.sealRedBright or PALETTE.amberDim, -- 302
		130 -- 302
	) -- 302
end -- 287
function VfxSystem.prototype.spawnBurst(self, wx, wy, count, color, speed) -- 305
	local i = 0 -- 306
	do -- 306
		i = 0 -- 307
		while i < count do -- 307
			local a = self:rand() * math.pi * 2 -- 308
			local s = speed * (0.35 + self:rand() * 0.85) -- 309
			local life = 0.22 + self:rand() * 0.26 -- 310
			local ____self_sparks_15 = self.sparks -- 310
			____self_sparks_15[#____self_sparks_15 + 1] = { -- 311
				x = wx, -- 312
				y = wy, -- 312
				vx = math.cos(a) * s, -- 313
				vy = math.sin(a) * s + 35, -- 314
				life = life, -- 315
				maxLife = life, -- 315
				size = 1.8 + self:rand() * 2.4, -- 316
				color = color -- 317
			} -- 317
			i = i + 1 -- 307
		end -- 307
	end -- 307
end -- 305
function VfxSystem.prototype.update(self, dt, ambient) -- 322
	if self.visualHitstop > 0 then -- 322
		self.visualHitstop = math.max(0, self.visualHitstop - dt) -- 324
		return -- 325
	end -- 325
	self.hitVignette = math.max(0, self.hitVignette - dt * 2.2) -- 327
	self.deflectFlash = math.max(0, self.deflectFlash - dt * 3.2) -- 328
	self.crosshairKick = math.max(0, self.crosshairKick - dt * 48) -- 329
	local w = 0 -- 332
	local i = 0 -- 333
	do -- 333
		i = 0 -- 334
		while i < #self.tracers do -- 334
			local tr = self.tracers[i + 1] -- 335
			tr.life = tr.life - dt -- 336
			if tr.life > 0 then -- 336
				self.tracers[w + 1] = tr -- 338
				w = w + 1 -- 339
			end -- 339
			i = i + 1 -- 334
		end -- 334
	end -- 334
	__TS__ArraySetLength(self.tracers, w) -- 334
	w = 0 -- 345
	do -- 345
		i = 0 -- 346
		while i < #self.plumes do -- 346
			local pl = self.plumes[i + 1] -- 347
			pl.life = pl.life - dt -- 348
			if pl.life > 0 then -- 348
				pl.x = pl.x + pl.dir * 24 * dt * (pl.life / pl.maxLife) -- 350
				pl.y = pl.y + 18 * dt -- 351
				self.plumes[w + 1] = pl -- 352
				w = w + 1 -- 353
			end -- 353
			i = i + 1 -- 346
		end -- 346
	end -- 346
	__TS__ArraySetLength(self.plumes, w) -- 346
	w = 0 -- 359
	do -- 359
		i = 0 -- 360
		while i < #self.bursts do -- 360
			local bu = self.bursts[i + 1] -- 361
			bu.life = bu.life - dt -- 362
			if bu.life > 0 then -- 362
				self.bursts[w + 1] = bu -- 364
				w = w + 1 -- 365
			end -- 365
			i = i + 1 -- 360
		end -- 360
	end -- 360
	__TS__ArraySetLength(self.bursts, w) -- 360
	w = 0 -- 371
	do -- 371
		i = 0 -- 372
		while i < #self.sparks do -- 372
			local sp = self.sparks[i + 1] -- 373
			sp.life = sp.life - dt -- 374
			if sp.life > 0 then -- 374
				sp.vy = sp.vy - 420 * dt -- 376
				sp.x = sp.x + sp.vx * dt -- 377
				sp.y = sp.y + sp.vy * dt -- 378
				if sp.y < 0 then -- 378
					sp.y = 0 -- 380
					sp.vy = -sp.vy * 0.35 -- 381
					sp.vx = sp.vx * 0.7 -- 382
				end -- 382
				self.sparks[w + 1] = sp -- 384
				w = w + 1 -- 385
			end -- 385
			i = i + 1 -- 372
		end -- 372
	end -- 372
	__TS__ArraySetLength(self.sparks, w) -- 372
	w = 0 -- 391
	do -- 391
		i = 0 -- 392
		while i < #self.rings do -- 392
			local rg = self.rings[i + 1] -- 393
			rg.life = rg.life - dt -- 394
			if rg.life > 0 then -- 394
				self.rings[w + 1] = rg -- 396
				w = w + 1 -- 397
			end -- 397
			i = i + 1 -- 392
		end -- 392
	end -- 392
	__TS__ArraySetLength(self.rings, w) -- 392
	w = 0 -- 403
	do -- 403
		i = 0 -- 404
		while i < #self.stepDusts do -- 404
			local sd = self.stepDusts[i + 1] -- 405
			sd.life = sd.life - dt -- 406
			if sd.life > 0 then -- 406
				self.stepDusts[w + 1] = sd -- 408
				w = w + 1 -- 409
			end -- 409
			i = i + 1 -- 404
		end -- 404
	end -- 404
	__TS__ArraySetLength(self.stepDusts, w) -- 404
	do -- 404
		i = 0 -- 415
		while i < #self.motes do -- 415
			local m = self.motes[i + 1] -- 416
			m.phase = m.phase + dt * 2 -- 417
			if ambient == "drizzle" then -- 417
				m.fx = m.fx - dt * 0.14 -- 419
				m.fy = m.fy - dt * 0.72 -- 420
			elseif ambient == "ash" then -- 420
				m.fx = m.fx + (m.vx - 0.035) * dt -- 422
				m.fy = m.fy + m.vy * 0.55 * dt -- 423
			elseif ambient == "spores" then -- 423
				m.fx = m.fx + math.sin(m.phase) * 0.015 * dt -- 425
				m.fy = m.fy + math.cos(m.phase * 0.7) * 0.018 * dt -- 426
			else -- 426
				m.fx = m.fx + math.sin(m.phase * 0.6) * 0.01 * dt -- 428
				m.fy = m.fy + 0.018 * dt -- 429
			end -- 429
			if m.fx < 0 then -- 429
				m.fx = m.fx + 1 -- 431
			end -- 431
			if m.fx > 1 then -- 431
				m.fx = m.fx - 1 -- 432
			end -- 432
			if m.fy < 0 then -- 432
				m.fy = m.fy + 1 -- 433
			end -- 433
			if m.fy > 1 then -- 433
				m.fy = m.fy - 1 -- 434
			end -- 434
			i = i + 1 -- 415
		end -- 415
	end -- 415
end -- 322
function VfxSystem.prototype.drawWorldVfx(self, fgGlow, assets, cam) -- 439
	local i = 0 -- 441
	do -- 441
		i = 0 -- 442
		while i < #self.tracers do -- 442
			local tr = self.tracers[i + 1] -- 443
			local k = tr.life / tr.maxLife -- 444
			local x0 = cam:sx(tr.x0) -- 445
			local y0 = cam:sy(tr.y0) -- 446
			local x1 = cam:sx(tr.x1) -- 447
			local y1 = cam:sy(tr.y1) -- 448
			local outerCol = tr.hit and PALETTE.sealRedBright or PALETTE.amber -- 449
			fgGlow:drawSegment( -- 452
				Vec2(x0, y0), -- 452
				Vec2(x1, y1), -- 452
				3.2 * k, -- 452
				toColor(outerCol, 88 * k) -- 452
			) -- 452
			fgGlow:drawSegment( -- 453
				Vec2(x0, y0), -- 453
				Vec2(x1, y1), -- 453
				1.3 * k, -- 453
				toColor(PALETTE.amberCore, 195 * k) -- 453
			) -- 453
			if k > 0.4 then -- 453
				local mk = (k - 0.4) / 0.6 -- 457
				local mIdx = math.min( -- 458
					3, -- 458
					math.floor((1 - mk) * 4) -- 458
				) -- 458
				local shotAngle = -math.atan(y1 - y0, x1 - x0) * 180 / math.pi -- 459
				local blastH = math.max( -- 460
					20, -- 460
					cam:len(26 * (0.82 + 0.34 * mk)) -- 460
				) -- 460
				fillRadialGlow( -- 461
					fgGlow, -- 461
					x0, -- 461
					y0, -- 461
					22 * mk, -- 461
					18 * mk, -- 461
					toColor(PALETTE.amberCore, 136 * mk), -- 461
					Color(186, 126, 62, 0), -- 461
					12 -- 461
				) -- 461
				if not assets:tryPlacePath( -- 461
					MUZZLE_CLIPS[mIdx + 1], -- 462
					"vfx_muzzle_" .. tostring(i), -- 462
					x0, -- 462
					y0, -- 462
					blastH * 1.6, -- 462
					blastH, -- 462
					{ -- 462
						anchorX = 0.14, -- 463
						anchorY = 0.48, -- 464
						preserveAspect = true, -- 465
						angle = shotAngle, -- 466
						opacity = math.min(1, mk * 1.2), -- 467
						layer = 9 -- 468
					} -- 468
				) and not assets:tryPlacePath( -- 468
					"assets/art/vfx_craft_art.clip|vfx_muzzle_blast", -- 469
					"vfx_muzzle_" .. tostring(i), -- 469
					x0, -- 469
					y0, -- 469
					blastH * 1.7, -- 469
					blastH, -- 469
					{ -- 469
						anchorX = 0.14, -- 470
						anchorY = 0.42, -- 471
						preserveAspect = true, -- 472
						angle = shotAngle, -- 473
						opacity = math.min(1, mk * 1.15), -- 474
						smooth = true, -- 475
						layer = 9 -- 476
					} -- 476
				) then -- 476
					fgGlow:drawSegment( -- 478
						Vec2(x0 - 10 * mk, y0), -- 478
						Vec2(x0 + 10 * mk, y0), -- 478
						1.2, -- 478
						toColor(PALETTE.amberCore, 165 * mk) -- 478
					) -- 478
					fgGlow:drawSegment( -- 479
						Vec2(x0, y0 - 7 * mk), -- 479
						Vec2(x0, y0 + 7 * mk), -- 479
						1, -- 479
						toColor(PALETTE.amber, 145 * mk) -- 479
					) -- 479
				end -- 479
			end -- 479
			if tr.hit then -- 479
				local s = 16 * (1.15 - k * 0.45) -- 484
				fillRadialGlow( -- 485
					fgGlow, -- 485
					x1, -- 485
					y1, -- 485
					s * 1.15, -- 485
					s * 0.9, -- 485
					toColor(PALETTE.sealRedBright, 130 * k), -- 485
					Color(168, 46, 44, 0), -- 485
					12 -- 485
				) -- 485
				fgGlow:drawSegment( -- 486
					Vec2(x1 - s, y1 - s * 0.55), -- 486
					Vec2(x1 + s, y1 + s * 0.55), -- 486
					1.6 * k, -- 486
					toColor(PALETTE.crimsonCore, 185 * k) -- 486
				) -- 486
				fgGlow:drawSegment( -- 487
					Vec2(x1 - s * 0.45, y1 + s * 0.7), -- 487
					Vec2(x1 + s * 0.45, y1 - s * 0.7), -- 487
					1.2 * k, -- 487
					toColor(PALETTE.sealRedBright, 160 * k) -- 487
				) -- 487
			end -- 487
			i = i + 1 -- 442
		end -- 442
	end -- 442
	do -- 442
		i = 0 -- 492
		while i < #self.plumes do -- 492
			local pl = self.plumes[i + 1] -- 493
			local k = pl.life / pl.maxLife -- 494
			local grow = 1 - k -- 495
			local sIdx = math.min( -- 496
				3, -- 496
				math.floor(grow * 4) -- 496
			) -- 496
			local size = cam:len(18 + grow * 30) -- 497
			if not assets:tryPlacePath( -- 497
				SMOKE_CLIPS[sIdx + 1], -- 498
				"vfx_smoke_" .. tostring(i), -- 498
				cam:sx(pl.x), -- 498
				cam:sy(pl.y), -- 498
				size, -- 498
				size, -- 498
				{ -- 498
					anchorX = 0.5, -- 499
					anchorY = 0.5, -- 500
					preserveAspect = true, -- 501
					facing = pl.dir, -- 502
					opacity = k * 0.72, -- 503
					layer = 8 -- 504
				} -- 504
			) then -- 504
				assets:tryPlacePath( -- 506
					"assets/art/vfx_craft_art.clip|vfx_smoke_plume", -- 506
					"vfx_smoke_" .. tostring(i), -- 506
					cam:sx(pl.x), -- 506
					cam:sy(pl.y), -- 506
					size, -- 506
					size, -- 506
					{ -- 506
						anchorX = 0.5, -- 507
						anchorY = 0.5, -- 508
						preserveAspect = true, -- 509
						facing = pl.dir, -- 510
						opacity = k * 0.68, -- 511
						smooth = true, -- 512
						layer = 8 -- 513
					} -- 513
				) -- 513
			end -- 513
			i = i + 1 -- 492
		end -- 492
	end -- 492
	do -- 492
		i = 0 -- 519
		while i < #self.bursts do -- 519
			local bu = self.bursts[i + 1] -- 520
			local k = bu.life / bu.maxLife -- 521
			local size = cam:len(18 + (1 - k) * 22) -- 522
			local clip = bu.hit and HIT_SPARK_CLIP or DEBRIS_CLIP -- 523
			if not assets:tryPlacePath( -- 523
				clip, -- 524
				"vfx_impact_" .. tostring(i), -- 524
				cam:sx(bu.x), -- 524
				cam:sy(bu.y), -- 524
				size, -- 524
				size, -- 524
				{ -- 524
					anchorX = 0.5, -- 525
					anchorY = 0.5, -- 526
					preserveAspect = true, -- 527
					opacity = k * 0.92, -- 528
					layer = 9 -- 529
				} -- 529
			) then -- 529
				assets:tryPlacePath( -- 531
					"assets/art/vfx_craft_art.clip|vfx_debris_burst", -- 531
					"vfx_impact_" .. tostring(i), -- 531
					cam:sx(bu.x), -- 531
					cam:sy(bu.y), -- 531
					size, -- 531
					size, -- 531
					{ -- 531
						anchorX = 0.5, -- 532
						anchorY = 0.5, -- 533
						preserveAspect = true, -- 534
						color = bu.hit and Color(246, 174, 152, 255) or Color(235, 224, 206, 255), -- 535
						opacity = k * 0.88, -- 536
						smooth = true, -- 537
						layer = 9 -- 538
					} -- 538
				) -- 538
			end -- 538
			i = i + 1 -- 519
		end -- 519
	end -- 519
	if self.deflectFlash > 0 then -- 519
		local k = self.deflectFlash -- 544
		local dy = cam:sy(self.deflectY + (1 - k) * 11) -- 545
		local height = cam:len(22 + (1 - k) * 18) -- 546
		if not assets:tryPlacePath( -- 546
			DEBRIS_CLIP, -- 547
			"blocked", -- 547
			cam:sx(self.deflectX), -- 547
			dy, -- 547
			height, -- 547
			height, -- 547
			{ -- 547
				anchorX = 0.5, -- 548
				anchorY = 0.5, -- 549
				preserveAspect = true, -- 550
				opacity = k * 0.94, -- 551
				layer = 8 -- 552
			} -- 552
		) then -- 552
			assets:tryPlace( -- 554
				"stone_chips", -- 554
				"blocked", -- 554
				cam:sx(self.deflectX), -- 554
				dy, -- 554
				height, -- 554
				height, -- 554
				{opacity = k, layer = 8} -- 554
			) -- 554
		end -- 554
	end -- 554
	do -- 554
		i = 0 -- 561
		while i < #self.stepDusts do -- 561
			local sd = self.stepDusts[i + 1] -- 562
			local k = sd.life / sd.maxLife -- 563
			local prog = 1 - k -- 564
			local sx = cam:sx(sd.x - sd.facing * prog * 9) -- 565
			local sy = cam:sy(sd.y + prog * 1.5, sd.depth) -- 566
			local size = cam:len((11 + prog * 14) * sd.scale) -- 567
			local clip = STEP_DUST_CLIPS[((sd.wide or prog > 0.45) and 1 or 0) + 1] -- 568
			if not assets:tryPlacePath( -- 568
				clip, -- 569
				"vfx_step_dust_" .. tostring(i), -- 569
				sx, -- 569
				sy, -- 569
				size * 1.3, -- 569
				size, -- 569
				{ -- 569
					anchorX = 0.5, -- 570
					anchorY = 0, -- 571
					preserveAspect = true, -- 572
					facing = sd.facing, -- 573
					opacity = k * 0.72, -- 574
					layer = 6 -- 575
				} -- 575
			) then -- 575
				fgGlow:drawEllipse( -- 577
					Vec2(sx, sy + 1), -- 577
					size * 0.42, -- 577
					size * 0.14, -- 577
					Color( -- 577
						166, -- 577
						154, -- 577
						138, -- 577
						math.floor(110 * k + 0.5) -- 577
					) -- 577
				) -- 577
			end -- 577
			i = i + 1 -- 561
		end -- 561
	end -- 561
	do -- 561
		i = 0 -- 582
		while i < #self.rings do -- 582
			local rg = self.rings[i + 1] -- 583
			local prog = 1 - rg.life / rg.maxLife -- 584
			local r = math.max( -- 585
				4, -- 585
				cam:len(rg.maxR) * prog -- 585
			) -- 585
			local alpha = (1 - prog) * 0.8 -- 586
			local rx = cam:sx(rg.x) -- 587
			local ry = cam:sy(rg.y) -- 588
			if not assets:tryPlace( -- 588
				"ink_enso_fine", -- 589
				"vfx_ring_" .. tostring(i), -- 589
				rx, -- 589
				ry, -- 589
				r * 2.35, -- 589
				r * 2.35, -- 589
				{ -- 589
					color = toColor(rg.color), -- 590
					opacity = alpha, -- 590
					angle = prog * 24, -- 590
					layer = 7 -- 590
				} -- 590
			) then -- 590
				fgGlow:drawRing( -- 592
					Vec2(rx, ry), -- 592
					math.max(1, r - 1.8), -- 592
					r, -- 592
					Color(0, 0, 0, 0), -- 592
					1.2, -- 592
					toColor(rg.color, alpha * 230) -- 592
				) -- 592
			end -- 592
			i = i + 1 -- 582
		end -- 582
	end -- 582
	do -- 582
		i = 0 -- 597
		while i < #self.sparks do -- 597
			local sp = self.sparks[i + 1] -- 598
			local k = sp.life / sp.maxLife -- 599
			local sx = cam:sx(sp.x) -- 600
			local sy = cam:sy(sp.y) -- 601
			local tx = sx - sp.vx * 0.02 * cam.ppu -- 602
			local ty = sy - sp.vy * 0.02 * cam.ppu -- 603
			fgGlow:drawSegment( -- 604
				Vec2(tx, ty), -- 604
				Vec2(sx, sy), -- 604
				sp.size * k * 0.9, -- 604
				toColor(sp.color, 210 * k) -- 604
			) -- 604
			i = i + 1 -- 597
		end -- 597
	end -- 597
end -- 439
function VfxSystem.prototype.drawScreenVfx(self, fgGlow, w, h, roomKey, drawAmbient) -- 609
	if drawAmbient == nil then -- 609
		drawAmbient = true -- 609
	end -- 609
	if drawAmbient then -- 609
		local theme = themeOf(roomKey) -- 611
		local kind = theme.ambient -- 612
		local i = 0 -- 613
		do -- 613
			i = 0 -- 614
			while i < #self.motes do -- 614
				local m = self.motes[i + 1] -- 615
				local x = m.fx * w -- 616
				local y = m.fy * h -- 617
				local tw = 0.55 + 0.45 * math.sin(m.phase) -- 618
				if kind == "drizzle" then -- 618
					fgGlow:drawSegment( -- 620
						Vec2(x, y), -- 620
						Vec2(x + 4, y + 18), -- 620
						0.85, -- 620
						Color( -- 620
							156, -- 620
							174, -- 620
							188, -- 620
							math.floor(44 * tw + 0.5) -- 620
						) -- 620
					) -- 620
				elseif kind == "ash" then -- 620
					local c = roomKey == "gate" and PALETTE.sealRedBright or PALETTE.amberDim -- 622
					fgGlow:drawDot( -- 623
						Vec2(x, y), -- 623
						m.size * 0.82, -- 623
						toColor(c, 78 * tw) -- 623
					) -- 623
				elseif kind == "spores" then -- 623
					fgGlow:drawDot( -- 625
						Vec2(x, y), -- 625
						m.size * 0.9, -- 625
						toColor(PALETTE.emerald, 82 * tw) -- 625
					) -- 625
				else -- 625
					fgGlow:drawDot( -- 627
						Vec2(x, y), -- 627
						m.size * 0.95, -- 627
						toColor(PALETTE.amberCore, 94 * tw) -- 627
					) -- 627
				end -- 627
				i = i + 1 -- 614
			end -- 614
		end -- 614
	end -- 614
	if self.hitVignette > 0.01 then -- 614
		local a = math.floor(120 * self.hitVignette + 0.5) -- 634
		local edge = 72 -- 635
		fillHGradRect( -- 636
			fgGlow, -- 636
			0, -- 636
			0, -- 636
			edge, -- 636
			h, -- 636
			Color(148, 36, 32, a), -- 636
			Color(148, 36, 32, 0) -- 636
		) -- 636
		fillHGradRect( -- 637
			fgGlow, -- 637
			w - edge, -- 637
			0, -- 637
			edge, -- 637
			h, -- 637
			Color(148, 36, 32, 0), -- 637
			Color(148, 36, 32, a) -- 637
		) -- 637
		fillVGradRect( -- 638
			fgGlow, -- 638
			0, -- 638
			0, -- 638
			w, -- 638
			edge * 0.8, -- 638
			Color(148, 36, 32, a), -- 638
			Color(148, 36, 32, 0) -- 638
		) -- 638
		fillVGradRect( -- 639
			fgGlow, -- 639
			0, -- 639
			h - edge * 0.8, -- 639
			w, -- 639
			edge * 0.8, -- 639
			Color(148, 36, 32, 0), -- 639
			Color(148, 36, 32, a) -- 639
		) -- 639
	end -- 639
end -- 609
return ____exports -- 609