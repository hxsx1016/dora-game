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
local AMBIENT_COUNT = 34 -- 66
____exports.VfxSystem = __TS__Class() -- 68
local VfxSystem = ____exports.VfxSystem -- 68
VfxSystem.name = "VfxSystem" -- 68
function VfxSystem.prototype.____constructor(self) -- 86
	self.sparks = {} -- 69
	self.rings = {} -- 70
	self.tracers = {} -- 71
	self.motes = {} -- 72
	self.hitVignette = 0 -- 75
	self.deflectFlash = 0 -- 77
	self.deflectX = 0 -- 78
	self.deflectY = 0 -- 79
	self.visualHitstop = 0 -- 81
	self.crosshairKick = 0 -- 83
	self.rngState = 1337 -- 84
	self:initAmbient() -- 87
end -- 86
function VfxSystem.prototype.rand(self) -- 90
	self.rngState = (self.rngState * 1664525 + 1013904223) % 4294967296 -- 91
	return self.rngState / 4294967296 -- 92
end -- 90
function VfxSystem.prototype.initAmbient(self) -- 95
	self.motes = {} -- 96
	local i = 0 -- 97
	do -- 97
		i = 0 -- 98
		while i < AMBIENT_COUNT do -- 98
			local ____self_motes_0 = self.motes -- 98
			____self_motes_0[#____self_motes_0 + 1] = { -- 99
				fx = self:rand(), -- 100
				fy = self:rand(), -- 101
				vx = (self:rand() - 0.5) * 0.04, -- 102
				vy = 0.02 + self:rand() * 0.05, -- 103
				size = 1.2 + self:rand() * 2.2, -- 104
				phase = self:rand() * math.pi * 2 -- 105
			} -- 105
			i = i + 1 -- 98
		end -- 98
	end -- 98
end -- 95
function VfxSystem.prototype.reset(self) -- 110
	self.sparks = {} -- 111
	self.rings = {} -- 112
	self.tracers = {} -- 113
	self.hitVignette = 0 -- 114
	self.deflectFlash = 0 -- 115
	self.visualHitstop = 0 -- 116
	self.crosshairKick = 0 -- 117
end -- 110
function VfxSystem.prototype.ingest(self, ev, p, cam) -- 121
	if ev.roomChanged then -- 121
		self:reset() -- 123
	end -- 123
	if ev.shotFired and ev.shotTrace ~= nil then -- 123
		self:spawnShot(ev.shotTrace) -- 127
		self.crosshairKick = 12 -- 128
		cam:addShake(ev.shotHit and 6.5 or 3.2) -- 129
		if ev.shotHit then -- 129
			self.visualHitstop = 0.045 -- 131
		end -- 131
	end -- 131
	if ev.enemyKilledX > -5000 then -- 131
		self:spawnBurst( -- 136
			ev.enemyKilledX, -- 136
			ev.enemyKilledY, -- 136
			14, -- 136
			PALETTE.sealRedBright, -- 136
			175 -- 136
		) -- 136
		self:spawnBurst( -- 137
			ev.enemyKilledX, -- 137
			ev.enemyKilledY, -- 137
			7, -- 137
			PALETTE.amberDim, -- 137
			130 -- 137
		) -- 137
		local ____self_rings_1 = self.rings -- 137
		____self_rings_1[#____self_rings_1 + 1] = { -- 138
			x = ev.enemyKilledX, -- 138
			y = ev.enemyKilledY, -- 138
			maxR = 40, -- 138
			life = 0.34, -- 138
			maxLife = 0.34, -- 138
			color = PALETTE.sealRed -- 138
		} -- 138
	end -- 138
	if ev.coverDeflect then -- 138
		self.deflectFlash = 1 -- 142
		self.deflectX = p.player.x + p.player.facing * 16 -- 143
		self.deflectY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.48 -- 144
		local nearest = 48 -- 145
		for ____, solid in ipairs(p.room.solids) do -- 146
			local edge = p.player.x < solid.x and solid.x or solid.x + solid.w -- 147
			local gap = math.abs(p.player.x - edge) -- 148
			if not solid.passable and not solid.decorative and solid.y <= p.player.y + 2 and solid.h <= 64 and gap < nearest and overlapsDepth(p.player.depth, solid.depth, ACTOR_DEPTH_HALF) then -- 148
				nearest = gap -- 151
				self.deflectX = edge -- 152
				local ____solid_y_4 = solid.y -- 153
				local ____opt_2 = solid.depth -- 153
				self.deflectY = ____solid_y_4 + (____opt_2 and ____opt_2.min or 0) * DEPTH_Y_SCALE + solid.h * 0.86 -- 153
			end -- 153
		end -- 153
		self:spawnBurst( -- 156
			self.deflectX, -- 156
			self.deflectY, -- 156
			8, -- 156
			PALETTE.amberDim, -- 156
			115 -- 156
		) -- 156
		cam:addShake(2.6) -- 157
	end -- 157
	if ev.playerHit then -- 157
		self.hitVignette = 1 -- 161
		self:spawnBurst( -- 162
			p.player.x, -- 162
			p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.55, -- 162
			14, -- 162
			PALETTE.sealRedBright, -- 162
			185 -- 162
		) -- 162
		cam:addShake(10) -- 163
		self.visualHitstop = 0.055 -- 164
	end -- 164
	if ev.rollStarted then -- 164
		self:spawnBurst( -- 168
			p.player.x, -- 168
			p.player.y + p.player.depth * DEPTH_Y_SCALE + 4, -- 168
			7, -- 168
			PALETTE.textDim, -- 168
			82 -- 168
		) -- 168
	end -- 168
	if ev.knockPulse then -- 168
		local ____self_rings_5 = self.rings -- 168
		____self_rings_5[#____self_rings_5 + 1] = { -- 172
			x = ev.knockX, -- 172
			y = ev.knockY, -- 172
			maxR = 52, -- 172
			life = 0.55, -- 172
			maxLife = 0.55, -- 172
			color = PALETTE.amber -- 172
		} -- 172
		local ____self_rings_6 = self.rings -- 172
		____self_rings_6[#____self_rings_6 + 1] = { -- 173
			x = ev.knockX, -- 173
			y = ev.knockY, -- 173
			maxR = 32, -- 173
			life = 0.38, -- 173
			maxLife = 0.38, -- 173
			color = PALETTE.xuanWarm -- 173
		} -- 173
	end -- 173
	if ev.bottleLanded then -- 173
		local ly = ev.bottleLandY -- 177
		local isBrick = p.room.brickX ~= nil and math.abs(ev.bottleLandX - p.room.brickX) <= 36 -- 178
		local ringCol = isBrick and PALETTE.amber or PALETTE.emerald -- 179
		local ____self_rings_7 = self.rings -- 179
		____self_rings_7[#____self_rings_7 + 1] = { -- 180
			x = ev.bottleLandX, -- 180
			y = ly + 4, -- 180
			maxR = isBrick and 96 or 38, -- 180
			life = 0.85, -- 180
			maxLife = 0.85, -- 180
			color = ringCol -- 180
		} -- 180
		local ____self_rings_8 = self.rings -- 180
		____self_rings_8[#____self_rings_8 + 1] = { -- 181
			x = ev.bottleLandX, -- 181
			y = ly + 4, -- 181
			maxR = isBrick and 62 or 22, -- 181
			life = 0.52, -- 181
			maxLife = 0.52, -- 181
			color = PALETTE.xuanWarm -- 181
		} -- 181
		self:spawnBurst( -- 182
			ev.bottleLandX, -- 182
			ly + 6, -- 182
			10, -- 182
			PALETTE.amberDim, -- 182
			120 -- 182
		) -- 182
		cam:addShake(isBrick and 3.5 or 1.5) -- 183
	end -- 183
	if ev.cartJustDocked then -- 183
		local cx = p.cartAxle -- 187
		local cy = p.room.cart.baseY + (p.room.cart.depth or 0) * DEPTH_Y_SCALE + 8 -- 188
		local ____self_rings_9 = self.rings -- 188
		____self_rings_9[#____self_rings_9 + 1] = { -- 189
			x = cx, -- 189
			y = cy, -- 189
			maxR = 58, -- 189
			life = 0.55, -- 189
			maxLife = 0.55, -- 189
			color = PALETTE.emerald -- 189
		} -- 189
		self:spawnBurst( -- 190
			cx, -- 190
			cy, -- 190
			12, -- 190
			PALETTE.amber, -- 190
			115 -- 190
		) -- 190
		cam:addShake(4.8) -- 191
	end -- 191
	if ev.caughtTriggered then -- 191
		self.hitVignette = 0.9 -- 195
		cam:addShake(9) -- 196
	end -- 196
end -- 121
function VfxSystem.prototype.spawnShot(self, t) -- 200
	local ____self_tracers_10 = self.tracers -- 200
	____self_tracers_10[#____self_tracers_10 + 1] = { -- 201
		x0 = t.x0, -- 202
		y0 = t.y0, -- 202
		x1 = t.x1, -- 202
		y1 = t.y1, -- 202
		hit = t.hit, -- 203
		life = 0.16, -- 203
		maxLife = 0.16 -- 203
	} -- 203
	self:spawnBurst( -- 206
		t.x0, -- 206
		t.y0, -- 206
		5, -- 206
		PALETTE.amberCore, -- 206
		105 -- 206
	) -- 206
	self:spawnBurst( -- 207
		t.x1, -- 207
		t.y1, -- 207
		t.hit and 9 or 6, -- 207
		t.hit and PALETTE.sealRedBright or PALETTE.amberDim, -- 207
		130 -- 207
	) -- 207
end -- 200
function VfxSystem.prototype.spawnBurst(self, wx, wy, count, color, speed) -- 210
	local i = 0 -- 211
	do -- 211
		i = 0 -- 212
		while i < count do -- 212
			local a = self:rand() * math.pi * 2 -- 213
			local s = speed * (0.35 + self:rand() * 0.85) -- 214
			local life = 0.22 + self:rand() * 0.26 -- 215
			local ____self_sparks_11 = self.sparks -- 215
			____self_sparks_11[#____self_sparks_11 + 1] = { -- 216
				x = wx, -- 217
				y = wy, -- 217
				vx = math.cos(a) * s, -- 218
				vy = math.sin(a) * s + 35, -- 219
				life = life, -- 220
				maxLife = life, -- 220
				size = 1.8 + self:rand() * 2.4, -- 221
				color = color -- 222
			} -- 222
			i = i + 1 -- 212
		end -- 212
	end -- 212
end -- 210
function VfxSystem.prototype.update(self, dt, ambient) -- 227
	if self.visualHitstop > 0 then -- 227
		self.visualHitstop = math.max(0, self.visualHitstop - dt) -- 229
		return -- 230
	end -- 230
	self.hitVignette = math.max(0, self.hitVignette - dt * 2.2) -- 232
	self.deflectFlash = math.max(0, self.deflectFlash - dt * 3.2) -- 233
	self.crosshairKick = math.max(0, self.crosshairKick - dt * 48) -- 234
	local w = 0 -- 237
	local i = 0 -- 238
	do -- 238
		i = 0 -- 239
		while i < #self.tracers do -- 239
			local tr = self.tracers[i + 1] -- 240
			tr.life = tr.life - dt -- 241
			if tr.life > 0 then -- 241
				self.tracers[w + 1] = tr -- 243
				w = w + 1 -- 244
			end -- 244
			i = i + 1 -- 239
		end -- 239
	end -- 239
	__TS__ArraySetLength(self.tracers, w) -- 239
	w = 0 -- 250
	do -- 250
		i = 0 -- 251
		while i < #self.sparks do -- 251
			local sp = self.sparks[i + 1] -- 252
			sp.life = sp.life - dt -- 253
			if sp.life > 0 then -- 253
				sp.vy = sp.vy - 420 * dt -- 255
				sp.x = sp.x + sp.vx * dt -- 256
				sp.y = sp.y + sp.vy * dt -- 257
				if sp.y < 0 then -- 257
					sp.y = 0 -- 259
					sp.vy = -sp.vy * 0.35 -- 260
					sp.vx = sp.vx * 0.7 -- 261
				end -- 261
				self.sparks[w + 1] = sp -- 263
				w = w + 1 -- 264
			end -- 264
			i = i + 1 -- 251
		end -- 251
	end -- 251
	__TS__ArraySetLength(self.sparks, w) -- 251
	w = 0 -- 270
	do -- 270
		i = 0 -- 271
		while i < #self.rings do -- 271
			local rg = self.rings[i + 1] -- 272
			rg.life = rg.life - dt -- 273
			if rg.life > 0 then -- 273
				self.rings[w + 1] = rg -- 275
				w = w + 1 -- 276
			end -- 276
			i = i + 1 -- 271
		end -- 271
	end -- 271
	__TS__ArraySetLength(self.rings, w) -- 271
	do -- 271
		i = 0 -- 282
		while i < #self.motes do -- 282
			local m = self.motes[i + 1] -- 283
			m.phase = m.phase + dt * 2 -- 284
			if ambient == "drizzle" then -- 284
				m.fx = m.fx - dt * 0.14 -- 286
				m.fy = m.fy - dt * 0.72 -- 287
			elseif ambient == "ash" then -- 287
				m.fx = m.fx + (m.vx - 0.035) * dt -- 289
				m.fy = m.fy + m.vy * 0.55 * dt -- 290
			elseif ambient == "spores" then -- 290
				m.fx = m.fx + math.sin(m.phase) * 0.015 * dt -- 292
				m.fy = m.fy + math.cos(m.phase * 0.7) * 0.018 * dt -- 293
			else -- 293
				m.fx = m.fx + math.sin(m.phase * 0.6) * 0.01 * dt -- 295
				m.fy = m.fy + 0.018 * dt -- 296
			end -- 296
			if m.fx < 0 then -- 296
				m.fx = m.fx + 1 -- 298
			end -- 298
			if m.fx > 1 then -- 298
				m.fx = m.fx - 1 -- 299
			end -- 299
			if m.fy < 0 then -- 299
				m.fy = m.fy + 1 -- 300
			end -- 300
			if m.fy > 1 then -- 300
				m.fy = m.fy - 1 -- 301
			end -- 301
			i = i + 1 -- 282
		end -- 282
	end -- 282
end -- 227
function VfxSystem.prototype.drawWorldVfx(self, fgGlow, assets, cam) -- 306
	local i = 0 -- 308
	do -- 308
		i = 0 -- 309
		while i < #self.tracers do -- 309
			local tr = self.tracers[i + 1] -- 310
			local k = tr.life / tr.maxLife -- 311
			local x0 = cam:sx(tr.x0) -- 312
			local y0 = cam:sy(tr.y0) -- 313
			local x1 = cam:sx(tr.x1) -- 314
			local y1 = cam:sy(tr.y1) -- 315
			local outerCol = tr.hit and PALETTE.sealRedBright or PALETTE.amber -- 316
			fgGlow:drawSegment( -- 319
				Vec2(x0, y0), -- 319
				Vec2(x1, y1), -- 319
				3.2 * k, -- 319
				toColor(outerCol, 88 * k) -- 319
			) -- 319
			fgGlow:drawSegment( -- 320
				Vec2(x0, y0), -- 320
				Vec2(x1, y1), -- 320
				1.3 * k, -- 320
				toColor(PALETTE.amberCore, 195 * k) -- 320
			) -- 320
			if k > 0.55 then -- 320
				local mk = (k - 0.55) / 0.45 -- 324
				fillRadialGlow( -- 325
					fgGlow, -- 325
					x0, -- 325
					y0, -- 325
					18 * mk, -- 325
					14 * mk, -- 325
					toColor(PALETTE.amberCore, 128 * mk), -- 325
					Color(186, 126, 62, 0), -- 325
					12 -- 325
				) -- 325
				local mSz = math.max( -- 326
					14, -- 326
					cam:len(20 + (1 - mk) * 8) -- 326
				) -- 326
				assets:tryPlace( -- 327
					"fe_vfx_muzzle", -- 327
					"vfx_muzzle_" .. tostring(i), -- 327
					x0, -- 327
					y0, -- 327
					mSz, -- 327
					mSz * 0.78, -- 327
					{ -- 327
						frame = math.min( -- 328
							2, -- 328
							math.floor((1 - mk) * 3) -- 328
						), -- 328
						facing = x1 >= x0 and 1 or -1, -- 329
						opacity = mk, -- 330
						layer = 9 -- 331
					} -- 331
				) -- 331
			end -- 331
			if tr.hit then -- 331
				local s = 16 * (1.15 - k * 0.45) -- 336
				fillRadialGlow( -- 337
					fgGlow, -- 337
					x1, -- 337
					y1, -- 337
					s * 1.1, -- 337
					s * 0.85, -- 337
					toColor(PALETTE.sealRedBright, 118 * k), -- 337
					Color(168, 46, 44, 0), -- 337
					12 -- 337
				) -- 337
				local hSz = math.max( -- 338
					14, -- 338
					cam:len(22 + (1 - k) * 10) -- 338
				) -- 338
				assets:tryPlace( -- 339
					"fe_vfx_hit_spark", -- 339
					"vfx_hit_" .. tostring(i), -- 339
					x1, -- 339
					y1, -- 339
					hSz, -- 339
					hSz, -- 339
					{ -- 339
						frame = math.min( -- 340
							2, -- 340
							math.floor((1 - k) * 3) -- 340
						), -- 340
						opacity = k, -- 341
						layer = 9 -- 342
					} -- 342
				) -- 342
			end -- 342
			i = i + 1 -- 309
		end -- 309
	end -- 309
	if self.deflectFlash > 0 then -- 309
		local k = self.deflectFlash -- 348
		local dy = cam:sy(self.deflectY + (1 - k) * 11) -- 349
		local height = cam:len(18 + (1 - k) * 12) -- 350
		assets:tryPlace( -- 351
			"stone_chips", -- 351
			"blocked", -- 351
			cam:sx(self.deflectX), -- 351
			dy, -- 351
			height, -- 351
			height, -- 351
			{opacity = k, layer = 8} -- 351
		) -- 351
	end -- 351
	do -- 351
		i = 0 -- 357
		while i < #self.rings do -- 357
			local rg = self.rings[i + 1] -- 358
			local prog = 1 - rg.life / rg.maxLife -- 359
			local r = math.max( -- 360
				4, -- 360
				cam:len(rg.maxR) * prog -- 360
			) -- 360
			local alpha = (1 - prog) * 0.8 -- 361
			local rx = cam:sx(rg.x) -- 362
			local ry = cam:sy(rg.y) -- 363
			if not assets:tryPlace( -- 363
				"ink_enso_fine", -- 364
				"vfx_ring_" .. tostring(i), -- 364
				rx, -- 364
				ry, -- 364
				r * 2.35, -- 364
				r * 2.35, -- 364
				{ -- 364
					color = toColor(rg.color), -- 365
					opacity = alpha, -- 365
					angle = prog * 24, -- 365
					layer = 7 -- 365
				} -- 365
			) then -- 365
				fgGlow:drawRing( -- 367
					Vec2(rx, ry), -- 367
					math.max(1, r - 1.8), -- 367
					r, -- 367
					Color(0, 0, 0, 0), -- 367
					1.2, -- 367
					toColor(rg.color, alpha * 230) -- 367
				) -- 367
			end -- 367
			i = i + 1 -- 357
		end -- 357
	end -- 357
	do -- 357
		i = 0 -- 372
		while i < #self.sparks do -- 372
			local sp = self.sparks[i + 1] -- 373
			local k = sp.life / sp.maxLife -- 374
			local sx = cam:sx(sp.x) -- 375
			local sy = cam:sy(sp.y) -- 376
			local tx = sx - sp.vx * 0.02 * cam.ppu -- 377
			local ty = sy - sp.vy * 0.02 * cam.ppu -- 378
			fgGlow:drawSegment( -- 379
				Vec2(tx, ty), -- 379
				Vec2(sx, sy), -- 379
				sp.size * k * 0.9, -- 379
				toColor(sp.color, 210 * k) -- 379
			) -- 379
			i = i + 1 -- 372
		end -- 372
	end -- 372
end -- 306
function VfxSystem.prototype.drawScreenVfx(self, fgGlow, w, h, roomKey) -- 384
	local theme = themeOf(roomKey) -- 385
	local kind = theme.ambient -- 386
	local i = 0 -- 387
	do -- 387
		i = 0 -- 388
		while i < #self.motes do -- 388
			local m = self.motes[i + 1] -- 389
			local x = m.fx * w -- 390
			local y = m.fy * h -- 391
			local tw = 0.55 + 0.45 * math.sin(m.phase) -- 392
			if kind == "drizzle" then -- 392
				fgGlow:drawSegment( -- 394
					Vec2(x, y), -- 394
					Vec2(x + 4, y + 18), -- 394
					0.85, -- 394
					Color( -- 394
						156, -- 394
						174, -- 394
						188, -- 394
						math.floor(44 * tw + 0.5) -- 394
					) -- 394
				) -- 394
			elseif kind == "ash" then -- 394
				local c = roomKey == "gate" and PALETTE.sealRedBright or PALETTE.amberDim -- 396
				fgGlow:drawDot( -- 397
					Vec2(x, y), -- 397
					m.size * 0.82, -- 397
					toColor(c, 78 * tw) -- 397
				) -- 397
			elseif kind == "spores" then -- 397
				fgGlow:drawDot( -- 399
					Vec2(x, y), -- 399
					m.size * 0.9, -- 399
					toColor(PALETTE.emerald, 82 * tw) -- 399
				) -- 399
			else -- 399
				fgGlow:drawDot( -- 401
					Vec2(x, y), -- 401
					m.size * 0.95, -- 401
					toColor(PALETTE.amberCore, 94 * tw) -- 401
				) -- 401
			end -- 401
			i = i + 1 -- 388
		end -- 388
	end -- 388
	if self.hitVignette > 0.01 then -- 388
		local a = math.floor(120 * self.hitVignette + 0.5) -- 407
		local edge = 72 -- 408
		fillHGradRect( -- 409
			fgGlow, -- 409
			0, -- 409
			0, -- 409
			edge, -- 409
			h, -- 409
			Color(148, 36, 32, a), -- 409
			Color(148, 36, 32, 0) -- 409
		) -- 409
		fillHGradRect( -- 410
			fgGlow, -- 410
			w - edge, -- 410
			0, -- 410
			edge, -- 410
			h, -- 410
			Color(148, 36, 32, 0), -- 410
			Color(148, 36, 32, a) -- 410
		) -- 410
		fillVGradRect( -- 411
			fgGlow, -- 411
			0, -- 411
			0, -- 411
			w, -- 411
			edge * 0.8, -- 411
			Color(148, 36, 32, a), -- 411
			Color(148, 36, 32, 0) -- 411
		) -- 411
		fillVGradRect( -- 412
			fgGlow, -- 412
			0, -- 412
			h - edge * 0.8, -- 412
			w, -- 412
			edge * 0.8, -- 412
			Color(148, 36, 32, 0), -- 412
			Color(148, 36, 32, a) -- 412
		) -- 412
	end -- 412
end -- 384
return ____exports -- 384