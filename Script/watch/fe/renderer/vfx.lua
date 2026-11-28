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
local ____occlusion = require("Script.watch.fe.occlusion") -- 16
local depthOrder = ____occlusion.depthOrder -- 16
local ____theme = require("Script.watch.fe.theme") -- 18
local PALETTE = ____theme.PALETTE -- 20
local fillHGradRect = ____theme.fillHGradRect -- 22
local fillRadialGlow = ____theme.fillRadialGlow -- 23
local fillVGradRect = ____theme.fillVGradRect -- 24
local themeOf = ____theme.themeOf -- 25
local toColor = ____theme.toColor -- 26
local AMBIENT_COUNT = 34 -- 95
local MUZZLE_CLIPS = {"assets/art/vfx_ming_fx.clip|muzzle_0", "assets/art/vfx_ming_fx.clip|muzzle_1", "assets/art/vfx_ming_fx.clip|muzzle_2", "assets/art/vfx_ming_fx.clip|muzzle_3"} -- 97
local SMOKE_CLIPS = {"assets/art/vfx_ming_fx.clip|smoke_0", "assets/art/vfx_ming_fx.clip|smoke_1", "assets/art/vfx_ming_fx.clip|smoke_2", "assets/art/vfx_ming_fx.clip|smoke_3"} -- 103
local HIT_SPARK_CLIP = "assets/art/vfx_ming_fx.clip|hit_spark_0" -- 109
local DEBRIS_CLIP = "assets/art/vfx_ming_fx.clip|debris_0" -- 110
local STEP_DUST_CLIPS = {"assets/art/vfx_ming_fx.clip|dust_0", "assets/art/vfx_ming_fx.clip|dust_1"} -- 111
____exports.VfxSystem = __TS__Class() -- 116
local VfxSystem = ____exports.VfxSystem -- 116
VfxSystem.name = "VfxSystem" -- 116
function VfxSystem.prototype.____constructor(self) -- 137
	self.sparks = {} -- 117
	self.rings = {} -- 118
	self.tracers = {} -- 119
	self.plumes = {} -- 120
	self.bursts = {} -- 121
	self.stepDusts = {} -- 122
	self.motes = {} -- 123
	self.hitVignette = 0 -- 126
	self.deflectFlash = 0 -- 128
	self.deflectX = 0 -- 129
	self.deflectY = 0 -- 130
	self.visualHitstop = 0 -- 132
	self.crosshairKick = 0 -- 134
	self.rngState = 1337 -- 135
	self:initAmbient() -- 138
end -- 137
function VfxSystem.prototype.rand(self) -- 141
	self.rngState = (self.rngState * 1664525 + 1013904223) % 4294967296 -- 142
	return self.rngState / 4294967296 -- 143
end -- 141
function VfxSystem.prototype.initAmbient(self) -- 146
	self.motes = {} -- 147
	local i = 0 -- 148
	do -- 148
		i = 0 -- 149
		while i < AMBIENT_COUNT do -- 149
			local ____self_motes_0 = self.motes -- 150
			____self_motes_0[#____self_motes_0 + 1] = { -- 150
				fx = self:rand(), -- 151
				fy = self:rand(), -- 152
				vx = (self:rand() - 0.5) * 0.04, -- 153
				vy = 0.02 + self:rand() * 0.05, -- 154
				size = 1.2 + self:rand() * 2.2, -- 155
				phase = self:rand() * math.pi * 2 -- 156
			} -- 156
			i = i + 1 -- 149
		end -- 149
	end -- 149
end -- 146
function VfxSystem.prototype.reset(self) -- 161
	self.sparks = {} -- 162
	self.rings = {} -- 163
	self.tracers = {} -- 164
	self.plumes = {} -- 165
	self.bursts = {} -- 166
	self.stepDusts = {} -- 167
	self.hitVignette = 0 -- 168
	self.deflectFlash = 0 -- 169
	self.visualHitstop = 0 -- 170
	self.crosshairKick = 0 -- 171
end -- 161
function VfxSystem.prototype.ingestFootsteps(self, cues) -- 175
	do -- 175
		local i = 0 -- 176
		while i < #cues do -- 176
			local c = cues[i + 1] -- 177
			if #self.stepDusts >= 26 then -- 178
				table.remove(self.stepDusts, 1) -- 179
			end -- 179
			local wide = c.kind == "land" or c.kind == "brake" -- 181
			local maxLife = c.kind == "land" and 0.34 or (c.kind == "brake" and 0.28 or 0.22) -- 182
			local ____self_stepDusts_1 = self.stepDusts -- 183
			____self_stepDusts_1[#____self_stepDusts_1 + 1] = { -- 183
				x = c.x, -- 184
				y = c.y, -- 185
				depth = c.depth, -- 186
				facing = c.facing, -- 187
				life = maxLife, -- 188
				maxLife = maxLife, -- 189
				scale = (wide and 1.15 or 0.78) * math.max(0.6, c.strength), -- 190
				wide = wide -- 191
			} -- 191
			if c.kind == "land" then -- 193
				local ____self_stepDusts_2 = self.stepDusts -- 194
				____self_stepDusts_2[#____self_stepDusts_2 + 1] = { -- 194
					x = c.x + c.facing * 8, -- 195
					y = c.y, -- 196
					depth = c.depth, -- 197
					facing = -c.facing, -- 198
					life = maxLife * 0.9, -- 199
					maxLife = maxLife * 0.9, -- 200
					scale = 0.92 * math.max(0.6, c.strength), -- 201
					wide = true -- 202
				} -- 202
			end -- 202
			i = i + 1 -- 176
		end -- 176
	end -- 176
end -- 175
function VfxSystem.prototype.ingest(self, ev, p, cam) -- 209
	if ev.roomChanged then -- 210
		self:reset() -- 211
	end -- 211
	if ev.shotFired and ev.shotTrace ~= nil then -- 214
		self:spawnShot(ev.shotTrace) -- 215
		self.crosshairKick = 12 -- 216
		cam:addShake(ev.shotHit and 6.5 or 3.2) -- 217
		if ev.shotHit then -- 218
			self.visualHitstop = 0.045 -- 219
		end -- 219
	end -- 219
	if ev.enemyKilledX > -5000 then -- 223
		self:spawnBurst( -- 224
			ev.enemyKilledX, -- 224
			ev.enemyKilledY, -- 224
			14, -- 224
			PALETTE.sealRedBright, -- 224
			175 -- 224
		) -- 224
		self:spawnBurst( -- 225
			ev.enemyKilledX, -- 225
			ev.enemyKilledY, -- 225
			7, -- 225
			PALETTE.amberDim, -- 225
			130 -- 225
		) -- 225
		local ____self_rings_3 = self.rings -- 226
		____self_rings_3[#____self_rings_3 + 1] = { -- 226
			x = ev.enemyKilledX, -- 226
			y = ev.enemyKilledY, -- 226
			maxR = 40, -- 226
			life = 0.34, -- 226
			maxLife = 0.34, -- 226
			color = PALETTE.sealRed -- 226
		} -- 226
	end -- 226
	if ev.coverDeflect then -- 229
		self.deflectFlash = 1 -- 230
		self.deflectX = p.player.x + p.player.facing * 16 -- 231
		self.deflectY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.48 -- 232
		local nearest = 48 -- 233
		for ____, solid in ipairs(p.room.solids) do -- 234
			local edge = p.player.x < solid.x and solid.x or solid.x + solid.w -- 235
			local gap = math.abs(p.player.x - edge) -- 236
			if not solid.passable and not solid.decorative and solid.y <= p.player.y + 2 and solid.h <= 64 and gap < nearest and overlapsDepth(p.player.depth, solid.depth, ACTOR_DEPTH_HALF) then -- 237
				nearest = gap -- 239
				self.deflectX = edge -- 240
				local ____solid_y_6 = solid.y -- 241
				local ____opt_4 = solid.depth -- 241
				self.deflectY = ____solid_y_6 + (____opt_4 and ____opt_4.min or 0) * DEPTH_Y_SCALE + solid.h * 0.86 -- 241
			end -- 241
		end -- 241
		self:spawnBurst( -- 244
			self.deflectX, -- 244
			self.deflectY, -- 244
			8, -- 244
			PALETTE.amberDim, -- 244
			115 -- 244
		) -- 244
		cam:addShake(2.6) -- 245
	end -- 245
	if ev.playerHit then -- 248
		self.hitVignette = 1 -- 249
		self:spawnBurst( -- 250
			p.player.x, -- 250
			p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.55, -- 250
			14, -- 250
			PALETTE.sealRedBright, -- 250
			185 -- 250
		) -- 250
		cam:addShake(10) -- 251
		self.visualHitstop = 0.055 -- 252
	end -- 252
	if ev.rollStarted then -- 255
		self:spawnBurst( -- 256
			p.player.x, -- 256
			p.player.y + p.player.depth * DEPTH_Y_SCALE + 4, -- 256
			7, -- 256
			PALETTE.textDim, -- 256
			82 -- 256
		) -- 256
	end -- 256
	if ev.knockPulse then -- 259
		local ____self_rings_7 = self.rings -- 260
		____self_rings_7[#____self_rings_7 + 1] = { -- 260
			x = ev.knockX, -- 260
			y = ev.knockY, -- 260
			maxR = 52, -- 260
			life = 0.55, -- 260
			maxLife = 0.55, -- 260
			color = PALETTE.amber -- 260
		} -- 260
		local ____self_rings_8 = self.rings -- 261
		____self_rings_8[#____self_rings_8 + 1] = { -- 261
			x = ev.knockX, -- 261
			y = ev.knockY, -- 261
			maxR = 32, -- 261
			life = 0.38, -- 261
			maxLife = 0.38, -- 261
			color = PALETTE.xuanWarm -- 261
		} -- 261
	end -- 261
	if ev.bottleLanded then -- 264
		local ly = ev.bottleLandY -- 265
		local isBrick = p.room.brickX ~= nil and math.abs(ev.bottleLandX - p.room.brickX) <= 36 -- 266
		local ringCol = isBrick and PALETTE.amber or PALETTE.emerald -- 267
		local ____self_rings_9 = self.rings -- 268
		____self_rings_9[#____self_rings_9 + 1] = { -- 268
			x = ev.bottleLandX, -- 268
			y = ly + 4, -- 268
			maxR = isBrick and 96 or 38, -- 268
			life = 0.85, -- 268
			maxLife = 0.85, -- 268
			color = ringCol -- 268
		} -- 268
		local ____self_rings_10 = self.rings -- 269
		____self_rings_10[#____self_rings_10 + 1] = { -- 269
			x = ev.bottleLandX, -- 269
			y = ly + 4, -- 269
			maxR = isBrick and 62 or 22, -- 269
			life = 0.52, -- 269
			maxLife = 0.52, -- 269
			color = PALETTE.xuanWarm -- 269
		} -- 269
		self:spawnBurst( -- 270
			ev.bottleLandX, -- 270
			ly + 6, -- 270
			10, -- 270
			PALETTE.amberDim, -- 270
			120 -- 270
		) -- 270
		cam:addShake(isBrick and 3.5 or 1.5) -- 271
	end -- 271
	if ev.cartJustDocked then -- 274
		local cx = p.cartAxle -- 275
		local cy = p.room.cart.baseY + (p.room.cart.depth or 0) * DEPTH_Y_SCALE + 8 -- 276
		local ____self_rings_11 = self.rings -- 277
		____self_rings_11[#____self_rings_11 + 1] = { -- 277
			x = cx, -- 277
			y = cy, -- 277
			maxR = 58, -- 277
			life = 0.55, -- 277
			maxLife = 0.55, -- 277
			color = PALETTE.emerald -- 277
		} -- 277
		self:spawnBurst( -- 278
			cx, -- 278
			cy, -- 278
			12, -- 278
			PALETTE.amber, -- 278
			115 -- 278
		) -- 278
		cam:addShake(4.8) -- 279
	end -- 279
	if ev.caughtTriggered then -- 282
		self.hitVignette = 0.9 -- 283
		cam:addShake(9) -- 284
	end -- 284
end -- 209
function VfxSystem.prototype.spawnShot(self, t) -- 288
	local ____self_tracers_12 = self.tracers -- 289
	____self_tracers_12[#____self_tracers_12 + 1] = { -- 289
		x0 = t.x0, -- 290
		y0 = t.y0, -- 290
		x1 = t.x1, -- 290
		y1 = t.y1, -- 290
		hit = t.hit, -- 291
		life = 0.16, -- 291
		maxLife = 0.16 -- 291
	} -- 291
	local ____self_plumes_13 = self.plumes -- 293
	____self_plumes_13[#____self_plumes_13 + 1] = { -- 293
		x = t.x0, -- 294
		y = t.y0, -- 294
		dir = t.x1 >= t.x0 and 1 or -1, -- 294
		life = 0.44, -- 295
		maxLife = 0.44 -- 295
	} -- 295
	local ____self_bursts_14 = self.bursts -- 297
	____self_bursts_14[#____self_bursts_14 + 1] = { -- 297
		x = t.x1, -- 298
		y = t.y1, -- 298
		hit = t.hit, -- 298
		life = 0.28, -- 299
		maxLife = 0.28 -- 299
	} -- 299
	self:spawnBurst( -- 302
		t.x0, -- 302
		t.y0, -- 302
		5, -- 302
		PALETTE.amberCore, -- 302
		105 -- 302
	) -- 302
	self:spawnBurst( -- 303
		t.x1, -- 303
		t.y1, -- 303
		t.hit and 9 or 6, -- 303
		t.hit and PALETTE.sealRedBright or PALETTE.amberDim, -- 303
		130 -- 303
	) -- 303
end -- 288
function VfxSystem.prototype.spawnBurst(self, wx, wy, count, color, speed) -- 306
	local i = 0 -- 307
	do -- 307
		i = 0 -- 308
		while i < count do -- 308
			local a = self:rand() * math.pi * 2 -- 309
			local s = speed * (0.35 + self:rand() * 0.85) -- 310
			local life = 0.22 + self:rand() * 0.26 -- 311
			local ____self_sparks_15 = self.sparks -- 312
			____self_sparks_15[#____self_sparks_15 + 1] = { -- 312
				x = wx, -- 313
				y = wy, -- 313
				vx = math.cos(a) * s, -- 314
				vy = math.sin(a) * s + 35, -- 315
				life = life, -- 316
				maxLife = life, -- 316
				size = 1.8 + self:rand() * 2.4, -- 317
				color = color -- 318
			} -- 318
			i = i + 1 -- 308
		end -- 308
	end -- 308
end -- 306
function VfxSystem.prototype.update(self, dt, ambient) -- 323
	if self.visualHitstop > 0 then -- 324
		self.visualHitstop = math.max(0, self.visualHitstop - dt) -- 325
		return -- 326
	end -- 326
	self.hitVignette = math.max(0, self.hitVignette - dt * 2.2) -- 328
	self.deflectFlash = math.max(0, self.deflectFlash - dt * 3.2) -- 329
	self.crosshairKick = math.max(0, self.crosshairKick - dt * 48) -- 330
	local w = 0 -- 333
	local i = 0 -- 334
	do -- 334
		i = 0 -- 335
		while i < #self.tracers do -- 335
			local tr = self.tracers[i + 1] -- 336
			tr.life = tr.life - dt -- 337
			if tr.life > 0 then -- 338
				self.tracers[w + 1] = tr -- 339
				w = w + 1 -- 340
			end -- 340
			i = i + 1 -- 335
		end -- 335
	end -- 335
	__TS__ArraySetLength(self.tracers, w) -- 343
	w = 0 -- 346
	do -- 346
		i = 0 -- 347
		while i < #self.plumes do -- 347
			local pl = self.plumes[i + 1] -- 348
			pl.life = pl.life - dt -- 349
			if pl.life > 0 then -- 350
				pl.x = pl.x + pl.dir * 24 * dt * (pl.life / pl.maxLife) -- 351
				pl.y = pl.y + 18 * dt -- 352
				self.plumes[w + 1] = pl -- 353
				w = w + 1 -- 354
			end -- 354
			i = i + 1 -- 347
		end -- 347
	end -- 347
	__TS__ArraySetLength(self.plumes, w) -- 357
	w = 0 -- 360
	do -- 360
		i = 0 -- 361
		while i < #self.bursts do -- 361
			local bu = self.bursts[i + 1] -- 362
			bu.life = bu.life - dt -- 363
			if bu.life > 0 then -- 364
				self.bursts[w + 1] = bu -- 365
				w = w + 1 -- 366
			end -- 366
			i = i + 1 -- 361
		end -- 361
	end -- 361
	__TS__ArraySetLength(self.bursts, w) -- 369
	w = 0 -- 372
	do -- 372
		i = 0 -- 373
		while i < #self.sparks do -- 373
			local sp = self.sparks[i + 1] -- 374
			sp.life = sp.life - dt -- 375
			if sp.life > 0 then -- 376
				sp.vy = sp.vy - 420 * dt -- 377
				sp.x = sp.x + sp.vx * dt -- 378
				sp.y = sp.y + sp.vy * dt -- 379
				if sp.y < 0 then -- 380
					sp.y = 0 -- 381
					sp.vy = -sp.vy * 0.35 -- 382
					sp.vx = sp.vx * 0.7 -- 383
				end -- 383
				self.sparks[w + 1] = sp -- 385
				w = w + 1 -- 386
			end -- 386
			i = i + 1 -- 373
		end -- 373
	end -- 373
	__TS__ArraySetLength(self.sparks, w) -- 389
	w = 0 -- 392
	do -- 392
		i = 0 -- 393
		while i < #self.rings do -- 393
			local rg = self.rings[i + 1] -- 394
			rg.life = rg.life - dt -- 395
			if rg.life > 0 then -- 396
				self.rings[w + 1] = rg -- 397
				w = w + 1 -- 398
			end -- 398
			i = i + 1 -- 393
		end -- 393
	end -- 393
	__TS__ArraySetLength(self.rings, w) -- 401
	w = 0 -- 404
	do -- 404
		i = 0 -- 405
		while i < #self.stepDusts do -- 405
			local sd = self.stepDusts[i + 1] -- 406
			sd.life = sd.life - dt -- 407
			if sd.life > 0 then -- 408
				self.stepDusts[w + 1] = sd -- 409
				w = w + 1 -- 410
			end -- 410
			i = i + 1 -- 405
		end -- 405
	end -- 405
	__TS__ArraySetLength(self.stepDusts, w) -- 413
	do -- 413
		i = 0 -- 416
		while i < #self.motes do -- 416
			local m = self.motes[i + 1] -- 417
			m.phase = m.phase + dt * 2 -- 418
			if ambient == "drizzle" then -- 419
				m.fx = m.fx - dt * 0.14 -- 420
				m.fy = m.fy - dt * 0.72 -- 421
			elseif ambient == "ash" then -- 422
				m.fx = m.fx + (m.vx - 0.035) * dt -- 423
				m.fy = m.fy + m.vy * 0.55 * dt -- 424
			elseif ambient == "spores" then -- 425
				m.fx = m.fx + math.sin(m.phase) * 0.015 * dt -- 426
				m.fy = m.fy + math.cos(m.phase * 0.7) * 0.018 * dt -- 427
			else -- 427
				m.fx = m.fx + math.sin(m.phase * 0.6) * 0.01 * dt -- 429
				m.fy = m.fy + 0.018 * dt -- 430
			end -- 430
			if m.fx < 0 then -- 432
				m.fx = m.fx + 1 -- 432
			end -- 432
			if m.fx > 1 then -- 433
				m.fx = m.fx - 1 -- 433
			end -- 433
			if m.fy < 0 then -- 434
				m.fy = m.fy + 1 -- 434
			end -- 434
			if m.fy > 1 then -- 435
				m.fy = m.fy - 1 -- 435
			end -- 435
			i = i + 1 -- 416
		end -- 416
	end -- 416
end -- 323
function VfxSystem.prototype.drawWorldVfx(self, fgGlow, assets, cam, depthEnabled) -- 440
	if depthEnabled == nil then -- 444
		depthEnabled = false -- 444
	end -- 444
	local muzzleLayer = depthEnabled and 5100 or 9 -- 446
	local smokeLayer = depthEnabled and 5090 or 8 -- 447
	local impactLayer = depthEnabled and 5100 or 9 -- 448
	local deflectLayer = depthEnabled and 5090 or 8 -- 449
	local ringLayer = depthEnabled and 5085 or 7 -- 450
	local i = 0 -- 453
	do -- 453
		i = 0 -- 454
		while i < #self.tracers do -- 454
			local tr = self.tracers[i + 1] -- 455
			local k = tr.life / tr.maxLife -- 456
			local x0 = cam:sx(tr.x0) -- 457
			local y0 = cam:sy(tr.y0) -- 458
			local x1 = cam:sx(tr.x1) -- 459
			local y1 = cam:sy(tr.y1) -- 460
			local outerCol = tr.hit and PALETTE.sealRedBright or PALETTE.amber -- 461
			fgGlow:drawSegment( -- 464
				Vec2(x0, y0), -- 464
				Vec2(x1, y1), -- 464
				3.2 * k, -- 464
				toColor(outerCol, 88 * k) -- 464
			) -- 464
			fgGlow:drawSegment( -- 465
				Vec2(x0, y0), -- 465
				Vec2(x1, y1), -- 465
				1.3 * k, -- 465
				toColor(PALETTE.amberCore, 195 * k) -- 465
			) -- 465
			if k > 0.4 then -- 468
				local mk = (k - 0.4) / 0.6 -- 469
				local mIdx = math.min( -- 470
					3, -- 470
					math.floor((1 - mk) * 4) -- 470
				) -- 470
				local shotAngle = -math.atan(y1 - y0, x1 - x0) * 180 / math.pi -- 471
				local blastH = math.max( -- 472
					20, -- 472
					cam:len(26 * (0.82 + 0.34 * mk)) -- 472
				) -- 472
				fillRadialGlow( -- 473
					fgGlow, -- 473
					x0, -- 473
					y0, -- 473
					22 * mk, -- 473
					18 * mk, -- 473
					toColor(PALETTE.amberCore, 136 * mk), -- 473
					Color(186, 126, 62, 0), -- 473
					12 -- 473
				) -- 473
				if not assets:tryPlacePath( -- 474
					MUZZLE_CLIPS[mIdx + 1], -- 474
					"vfx_muzzle_" .. tostring(i), -- 474
					x0, -- 474
					y0, -- 474
					blastH * 1.6, -- 474
					blastH, -- 474
					{ -- 474
						anchorX = 0.14, -- 475
						anchorY = 0.48, -- 476
						preserveAspect = true, -- 477
						angle = shotAngle, -- 478
						opacity = math.min(1, mk * 1.2), -- 479
						layer = muzzleLayer -- 480
					} -- 480
				) and not assets:tryPlacePath( -- 481
					"assets/art/vfx_craft_art.clip|vfx_muzzle_blast", -- 481
					"vfx_muzzle_" .. tostring(i), -- 481
					x0, -- 481
					y0, -- 481
					blastH * 1.7, -- 481
					blastH, -- 481
					{ -- 481
						anchorX = 0.14, -- 482
						anchorY = 0.42, -- 483
						preserveAspect = true, -- 484
						angle = shotAngle, -- 485
						opacity = math.min(1, mk * 1.15), -- 486
						smooth = true, -- 487
						layer = muzzleLayer -- 488
					} -- 488
				) then -- 488
					fgGlow:drawSegment( -- 490
						Vec2(x0 - 10 * mk, y0), -- 490
						Vec2(x0 + 10 * mk, y0), -- 490
						1.2, -- 490
						toColor(PALETTE.amberCore, 165 * mk) -- 490
					) -- 490
					fgGlow:drawSegment( -- 491
						Vec2(x0, y0 - 7 * mk), -- 491
						Vec2(x0, y0 + 7 * mk), -- 491
						1, -- 491
						toColor(PALETTE.amber, 145 * mk) -- 491
					) -- 491
				end -- 491
			end -- 491
			if tr.hit then -- 495
				local s = 16 * (1.15 - k * 0.45) -- 496
				fillRadialGlow( -- 497
					fgGlow, -- 497
					x1, -- 497
					y1, -- 497
					s * 1.15, -- 497
					s * 0.9, -- 497
					toColor(PALETTE.sealRedBright, 130 * k), -- 497
					Color(168, 46, 44, 0), -- 497
					12 -- 497
				) -- 497
				fgGlow:drawSegment( -- 498
					Vec2(x1 - s, y1 - s * 0.55), -- 498
					Vec2(x1 + s, y1 + s * 0.55), -- 498
					1.6 * k, -- 498
					toColor(PALETTE.crimsonCore, 185 * k) -- 498
				) -- 498
				fgGlow:drawSegment( -- 499
					Vec2(x1 - s * 0.45, y1 + s * 0.7), -- 499
					Vec2(x1 + s * 0.45, y1 - s * 0.7), -- 499
					1.2 * k, -- 499
					toColor(PALETTE.sealRedBright, 160 * k) -- 499
				) -- 499
			end -- 499
			i = i + 1 -- 454
		end -- 454
	end -- 454
	do -- 454
		i = 0 -- 504
		while i < #self.plumes do -- 504
			local pl = self.plumes[i + 1] -- 505
			local k = pl.life / pl.maxLife -- 506
			local grow = 1 - k -- 507
			local sIdx = math.min( -- 508
				3, -- 508
				math.floor(grow * 4) -- 508
			) -- 508
			local size = cam:len(18 + grow * 30) -- 509
			if not assets:tryPlacePath( -- 510
				SMOKE_CLIPS[sIdx + 1], -- 510
				"vfx_smoke_" .. tostring(i), -- 510
				cam:sx(pl.x), -- 510
				cam:sy(pl.y), -- 510
				size, -- 510
				size, -- 510
				{ -- 510
					anchorX = 0.5, -- 511
					anchorY = 0.5, -- 512
					preserveAspect = true, -- 513
					facing = pl.dir, -- 514
					opacity = k * 0.72, -- 515
					layer = smokeLayer -- 516
				} -- 516
			) then -- 516
				assets:tryPlacePath( -- 518
					"assets/art/vfx_craft_art.clip|vfx_smoke_plume", -- 518
					"vfx_smoke_" .. tostring(i), -- 518
					cam:sx(pl.x), -- 518
					cam:sy(pl.y), -- 518
					size, -- 518
					size, -- 518
					{ -- 518
						anchorX = 0.5, -- 519
						anchorY = 0.5, -- 520
						preserveAspect = true, -- 521
						facing = pl.dir, -- 522
						opacity = k * 0.68, -- 523
						smooth = true, -- 524
						layer = smokeLayer -- 525
					} -- 525
				) -- 525
			end -- 525
			i = i + 1 -- 504
		end -- 504
	end -- 504
	do -- 504
		i = 0 -- 531
		while i < #self.bursts do -- 531
			local bu = self.bursts[i + 1] -- 532
			local k = bu.life / bu.maxLife -- 533
			local size = cam:len(18 + (1 - k) * 22) -- 534
			local clip = bu.hit and HIT_SPARK_CLIP or DEBRIS_CLIP -- 535
			if not assets:tryPlacePath( -- 536
				clip, -- 536
				"vfx_impact_" .. tostring(i), -- 536
				cam:sx(bu.x), -- 536
				cam:sy(bu.y), -- 536
				size, -- 536
				size, -- 536
				{ -- 536
					anchorX = 0.5, -- 537
					anchorY = 0.5, -- 538
					preserveAspect = true, -- 539
					opacity = k * 0.92, -- 540
					layer = impactLayer -- 541
				} -- 541
			) then -- 541
				assets:tryPlacePath( -- 543
					"assets/art/vfx_craft_art.clip|vfx_debris_burst", -- 543
					"vfx_impact_" .. tostring(i), -- 543
					cam:sx(bu.x), -- 543
					cam:sy(bu.y), -- 543
					size, -- 543
					size, -- 543
					{ -- 543
						anchorX = 0.5, -- 544
						anchorY = 0.5, -- 545
						preserveAspect = true, -- 546
						color = bu.hit and Color(246, 174, 152, 255) or Color(235, 224, 206, 255), -- 547
						opacity = k * 0.88, -- 548
						smooth = true, -- 549
						layer = impactLayer -- 550
					} -- 550
				) -- 550
			end -- 550
			i = i + 1 -- 531
		end -- 531
	end -- 531
	if self.deflectFlash > 0 then -- 555
		local k = self.deflectFlash -- 556
		local dy = cam:sy(self.deflectY + (1 - k) * 11) -- 557
		local height = cam:len(22 + (1 - k) * 18) -- 558
		if not assets:tryPlacePath( -- 559
			DEBRIS_CLIP, -- 559
			"blocked", -- 559
			cam:sx(self.deflectX), -- 559
			dy, -- 559
			height, -- 559
			height, -- 559
			{ -- 559
				anchorX = 0.5, -- 560
				anchorY = 0.5, -- 561
				preserveAspect = true, -- 562
				opacity = k * 0.94, -- 563
				layer = deflectLayer -- 564
			} -- 564
		) then -- 564
			assets:tryPlace( -- 566
				"stone_chips", -- 566
				"blocked", -- 566
				cam:sx(self.deflectX), -- 566
				dy, -- 566
				height, -- 566
				height, -- 566
				{opacity = k, layer = deflectLayer} -- 566
			) -- 566
		end -- 566
	end -- 566
	do -- 566
		i = 0 -- 573
		while i < #self.stepDusts do -- 573
			local sd = self.stepDusts[i + 1] -- 574
			local k = sd.life / sd.maxLife -- 575
			local prog = 1 - k -- 576
			local dScale = cam:depthScale(sd.depth, depthEnabled) -- 577
			local sx = cam:sx(sd.x - sd.facing * prog * 9) -- 578
			local sy = cam:sy(sd.y + prog * 1.5, sd.depth) -- 579
			local size = cam:len((11 + prog * 14) * sd.scale) * dScale -- 580
			local clip = STEP_DUST_CLIPS[((sd.wide or prog > 0.45) and 1 or 0) + 1] -- 581
			if not assets:tryPlacePath( -- 582
				clip, -- 582
				"vfx_step_dust_" .. tostring(i), -- 582
				sx, -- 582
				sy, -- 582
				size * 1.3, -- 582
				size, -- 582
				{ -- 582
					anchorX = 0.5, -- 583
					anchorY = 0, -- 584
					preserveAspect = true, -- 585
					facing = sd.facing, -- 586
					opacity = k * 0.72, -- 587
					layer = depthEnabled and depthOrder(sd.depth, 5) or 6 -- 588
				} -- 588
			) then -- 588
				fgGlow:drawEllipse( -- 590
					Vec2(sx, sy + 1), -- 590
					size * 0.42, -- 590
					size * 0.14, -- 590
					Color( -- 590
						166, -- 590
						154, -- 590
						138, -- 590
						math.floor(110 * k + 0.5) -- 590
					) -- 590
				) -- 590
			end -- 590
			i = i + 1 -- 573
		end -- 573
	end -- 573
	do -- 573
		i = 0 -- 595
		while i < #self.rings do -- 595
			local rg = self.rings[i + 1] -- 596
			local prog = 1 - rg.life / rg.maxLife -- 597
			local r = math.max( -- 598
				4, -- 598
				cam:len(rg.maxR) * prog -- 598
			) -- 598
			local alpha = (1 - prog) * 0.8 -- 599
			local rx = cam:sx(rg.x) -- 600
			local ry = cam:sy(rg.y) -- 601
			if not assets:tryPlace( -- 602
				"ink_enso_fine", -- 602
				"vfx_ring_" .. tostring(i), -- 602
				rx, -- 602
				ry, -- 602
				r * 2.35, -- 602
				r * 2.35, -- 602
				{ -- 602
					color = toColor(rg.color), -- 603
					opacity = alpha, -- 603
					angle = prog * 24, -- 603
					layer = ringLayer -- 603
				} -- 603
			) then -- 603
				fgGlow:drawRing( -- 605
					Vec2(rx, ry), -- 605
					math.max(1, r - 1.8), -- 605
					r, -- 605
					Color(0, 0, 0, 0), -- 605
					1.2, -- 605
					toColor(rg.color, alpha * 230) -- 605
				) -- 605
			end -- 605
			i = i + 1 -- 595
		end -- 595
	end -- 595
	do -- 595
		i = 0 -- 610
		while i < #self.sparks do -- 610
			local sp = self.sparks[i + 1] -- 611
			local k = sp.life / sp.maxLife -- 612
			local sx = cam:sx(sp.x) -- 613
			local sy = cam:sy(sp.y) -- 614
			local tx = sx - sp.vx * 0.02 * cam.ppu -- 615
			local ty = sy - sp.vy * 0.02 * cam.ppu -- 616
			fgGlow:drawSegment( -- 617
				Vec2(tx, ty), -- 617
				Vec2(sx, sy), -- 617
				sp.size * k * 0.9, -- 617
				toColor(sp.color, 210 * k) -- 617
			) -- 617
			i = i + 1 -- 610
		end -- 610
	end -- 610
end -- 440
function VfxSystem.prototype.drawScreenVfx(self, fgGlow, w, h, roomKey, drawAmbient) -- 622
	if drawAmbient == nil then -- 622
		drawAmbient = true -- 622
	end -- 622
	if drawAmbient then -- 623
		local theme = themeOf(roomKey) -- 624
		local kind = theme.ambient -- 625
		local i = 0 -- 626
		do -- 626
			i = 0 -- 627
			while i < #self.motes do -- 627
				local m = self.motes[i + 1] -- 628
				local x = m.fx * w -- 629
				local y = m.fy * h -- 630
				local tw = 0.55 + 0.45 * math.sin(m.phase) -- 631
				if kind == "drizzle" then -- 632
					fgGlow:drawSegment( -- 633
						Vec2(x, y), -- 633
						Vec2(x + 4, y + 18), -- 633
						0.85, -- 633
						Color( -- 633
							156, -- 633
							174, -- 633
							188, -- 633
							math.floor(44 * tw + 0.5) -- 633
						) -- 633
					) -- 633
				elseif kind == "ash" then -- 634
					local c = roomKey == "gate" and PALETTE.sealRedBright or PALETTE.amberDim -- 635
					fgGlow:drawDot( -- 636
						Vec2(x, y), -- 636
						m.size * 0.82, -- 636
						toColor(c, 78 * tw) -- 636
					) -- 636
				elseif kind == "spores" then -- 637
					fgGlow:drawDot( -- 638
						Vec2(x, y), -- 638
						m.size * 0.9, -- 638
						toColor(PALETTE.emerald, 82 * tw) -- 638
					) -- 638
				else -- 638
					fgGlow:drawDot( -- 640
						Vec2(x, y), -- 640
						m.size * 0.95, -- 640
						toColor(PALETTE.amberCore, 94 * tw) -- 640
					) -- 640
				end -- 640
				i = i + 1 -- 627
			end -- 627
		end -- 627
	end -- 627
	if self.hitVignette > 0.01 then -- 646
		local a = math.floor(120 * self.hitVignette + 0.5) -- 647
		local edge = 72 -- 648
		fillHGradRect( -- 649
			fgGlow, -- 649
			0, -- 649
			0, -- 649
			edge, -- 649
			h, -- 649
			Color(148, 36, 32, a), -- 649
			Color(148, 36, 32, 0) -- 649
		) -- 649
		fillHGradRect( -- 650
			fgGlow, -- 650
			w - edge, -- 650
			0, -- 650
			edge, -- 650
			h, -- 650
			Color(148, 36, 32, 0), -- 650
			Color(148, 36, 32, a) -- 650
		) -- 650
		fillVGradRect( -- 651
			fgGlow, -- 651
			0, -- 651
			0, -- 651
			w, -- 651
			edge * 0.8, -- 651
			Color(148, 36, 32, a), -- 651
			Color(148, 36, 32, 0) -- 651
		) -- 651
		fillVGradRect( -- 652
			fgGlow, -- 652
			0, -- 652
			h - edge * 0.8, -- 652
			w, -- 652
			edge * 0.8, -- 652
			Color(148, 36, 32, 0), -- 652
			Color(148, 36, 32, a) -- 652
		) -- 652
	end -- 652
end -- 622
return ____exports -- 622
