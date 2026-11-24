-- [ts]: vfx.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 10
local Color = ____Dora.Color -- 10
local Vec2 = ____Dora.Vec2 -- 10
local ____theme = require("Script.watch.fe.theme") -- 15
local PALETTE = ____theme.PALETTE -- 17
local fillHGradRect = ____theme.fillHGradRect -- 19
local fillRadialGlow = ____theme.fillRadialGlow -- 20
local fillVGradRect = ____theme.fillVGradRect -- 21
local themeOf = ____theme.themeOf -- 22
local toColor = ____theme.toColor -- 23
local AMBIENT_COUNT = 34 -- 65
____exports.VfxSystem = __TS__Class() -- 67
local VfxSystem = ____exports.VfxSystem -- 67
VfxSystem.name = "VfxSystem" -- 67
function VfxSystem.prototype.____constructor(self) -- 85
	self.sparks = {} -- 68
	self.rings = {} -- 69
	self.tracers = {} -- 70
	self.motes = {} -- 71
	self.hitVignette = 0 -- 74
	self.deflectFlash = 0 -- 76
	self.deflectX = 0 -- 77
	self.deflectY = 0 -- 78
	self.visualHitstop = 0 -- 80
	self.crosshairKick = 0 -- 82
	self.rngState = 1337 -- 83
	self:initAmbient() -- 86
end -- 85
function VfxSystem.prototype.rand(self) -- 89
	self.rngState = (self.rngState * 1664525 + 1013904223) % 4294967296 -- 90
	return self.rngState / 4294967296 -- 91
end -- 89
function VfxSystem.prototype.initAmbient(self) -- 94
	self.motes = {} -- 95
	local i = 0 -- 96
	do -- 96
		i = 0 -- 97
		while i < AMBIENT_COUNT do -- 97
			local ____self_motes_0 = self.motes -- 97
			____self_motes_0[#____self_motes_0 + 1] = { -- 98
				fx = self:rand(), -- 99
				fy = self:rand(), -- 100
				vx = (self:rand() - 0.5) * 0.04, -- 101
				vy = 0.02 + self:rand() * 0.05, -- 102
				size = 1.2 + self:rand() * 2.2, -- 103
				phase = self:rand() * math.pi * 2 -- 104
			} -- 104
			i = i + 1 -- 97
		end -- 97
	end -- 97
end -- 94
function VfxSystem.prototype.reset(self) -- 109
	self.sparks = {} -- 110
	self.rings = {} -- 111
	self.tracers = {} -- 112
	self.hitVignette = 0 -- 113
	self.deflectFlash = 0 -- 114
	self.visualHitstop = 0 -- 115
	self.crosshairKick = 0 -- 116
end -- 109
function VfxSystem.prototype.ingest(self, ev, p, cam) -- 120
	if ev.roomChanged then -- 120
		self:reset() -- 122
	end -- 122
	if ev.shotFired and ev.shotTrace ~= nil then -- 122
		self:spawnShot(ev.shotTrace) -- 126
		self.crosshairKick = 12 -- 127
		cam:addShake(ev.shotHit and 6.5 or 3.2) -- 128
		if ev.shotHit then -- 128
			self.visualHitstop = 0.045 -- 130
		end -- 130
	end -- 130
	if ev.enemyKilledX > -5000 then -- 130
		self:spawnBurst( -- 135
			ev.enemyKilledX, -- 135
			ev.enemyKilledY, -- 135
			14, -- 135
			PALETTE.sealRedBright, -- 135
			175 -- 135
		) -- 135
		self:spawnBurst( -- 136
			ev.enemyKilledX, -- 136
			ev.enemyKilledY, -- 136
			7, -- 136
			PALETTE.amberDim, -- 136
			130 -- 136
		) -- 136
		local ____self_rings_1 = self.rings -- 136
		____self_rings_1[#____self_rings_1 + 1] = { -- 137
			x = ev.enemyKilledX, -- 137
			y = ev.enemyKilledY, -- 137
			maxR = 40, -- 137
			life = 0.34, -- 137
			maxLife = 0.34, -- 137
			color = PALETTE.sealRed -- 137
		} -- 137
	end -- 137
	if ev.coverDeflect then -- 137
		self.deflectFlash = 1 -- 141
		self.deflectX = p.player.x + p.player.facing * 16 -- 142
		self.deflectY = p.player.y + p.player.h * 0.48 -- 143
		local nearest = 48 -- 144
		for ____, solid in ipairs(p.room.solids) do -- 145
			local edge = p.player.x < solid.x and solid.x or solid.x + solid.w -- 146
			local gap = math.abs(p.player.x - edge) -- 147
			if not solid.passable and solid.y <= p.player.y + 2 and solid.h <= 64 and gap < nearest then -- 147
				nearest = gap -- 149
				self.deflectX = edge -- 150
				self.deflectY = solid.y + solid.h * 0.86 -- 151
			end -- 151
		end -- 151
		self:spawnBurst( -- 154
			self.deflectX, -- 154
			self.deflectY, -- 154
			8, -- 154
			PALETTE.amberDim, -- 154
			115 -- 154
		) -- 154
		cam:addShake(2.6) -- 155
	end -- 155
	if ev.playerHit then -- 155
		self.hitVignette = 1 -- 159
		self:spawnBurst( -- 160
			p.player.x, -- 160
			p.player.y + p.player.h * 0.55, -- 160
			14, -- 160
			PALETTE.sealRedBright, -- 160
			185 -- 160
		) -- 160
		cam:addShake(10) -- 161
		self.visualHitstop = 0.055 -- 162
	end -- 162
	if ev.rollStarted then -- 162
		self:spawnBurst( -- 166
			p.player.x, -- 166
			p.player.y + 4, -- 166
			7, -- 166
			PALETTE.textDim, -- 166
			82 -- 166
		) -- 166
	end -- 166
	if ev.knockPulse then -- 166
		local ____self_rings_2 = self.rings -- 166
		____self_rings_2[#____self_rings_2 + 1] = { -- 170
			x = ev.knockX, -- 170
			y = ev.knockY, -- 170
			maxR = 52, -- 170
			life = 0.55, -- 170
			maxLife = 0.55, -- 170
			color = PALETTE.amber -- 170
		} -- 170
		local ____self_rings_3 = self.rings -- 170
		____self_rings_3[#____self_rings_3 + 1] = { -- 171
			x = ev.knockX, -- 171
			y = ev.knockY, -- 171
			maxR = 32, -- 171
			life = 0.38, -- 171
			maxLife = 0.38, -- 171
			color = PALETTE.xuanWarm -- 171
		} -- 171
	end -- 171
	if ev.bottleLanded then -- 171
		local ly = ev.bottleLandY -- 175
		local isBrick = p.room.brickX ~= nil and math.abs(ev.bottleLandX - p.room.brickX) <= 36 -- 176
		local ringCol = isBrick and PALETTE.amber or PALETTE.emerald -- 177
		local ____self_rings_4 = self.rings -- 177
		____self_rings_4[#____self_rings_4 + 1] = { -- 178
			x = ev.bottleLandX, -- 178
			y = ly + 4, -- 178
			maxR = isBrick and 96 or 38, -- 178
			life = 0.85, -- 178
			maxLife = 0.85, -- 178
			color = ringCol -- 178
		} -- 178
		local ____self_rings_5 = self.rings -- 178
		____self_rings_5[#____self_rings_5 + 1] = { -- 179
			x = ev.bottleLandX, -- 179
			y = ly + 4, -- 179
			maxR = isBrick and 62 or 22, -- 179
			life = 0.52, -- 179
			maxLife = 0.52, -- 179
			color = PALETTE.xuanWarm -- 179
		} -- 179
		self:spawnBurst( -- 180
			ev.bottleLandX, -- 180
			ly + 6, -- 180
			10, -- 180
			PALETTE.amberDim, -- 180
			120 -- 180
		) -- 180
		cam:addShake(isBrick and 3.5 or 1.5) -- 181
	end -- 181
	if ev.cartJustDocked then -- 181
		local cx = p.cartAxle -- 185
		local cy = p.room.cart.baseY + 8 -- 186
		local ____self_rings_6 = self.rings -- 186
		____self_rings_6[#____self_rings_6 + 1] = { -- 187
			x = cx, -- 187
			y = cy, -- 187
			maxR = 58, -- 187
			life = 0.55, -- 187
			maxLife = 0.55, -- 187
			color = PALETTE.emerald -- 187
		} -- 187
		self:spawnBurst( -- 188
			cx, -- 188
			cy, -- 188
			12, -- 188
			PALETTE.amber, -- 188
			115 -- 188
		) -- 188
		cam:addShake(4.8) -- 189
	end -- 189
	if ev.caughtTriggered then -- 189
		self.hitVignette = 0.9 -- 193
		cam:addShake(9) -- 194
	end -- 194
end -- 120
function VfxSystem.prototype.spawnShot(self, t) -- 198
	local ____self_tracers_7 = self.tracers -- 198
	____self_tracers_7[#____self_tracers_7 + 1] = { -- 199
		x0 = t.x0, -- 200
		y0 = t.y0, -- 200
		x1 = t.x1, -- 200
		y1 = t.y1, -- 200
		hit = t.hit, -- 201
		life = 0.16, -- 201
		maxLife = 0.16 -- 201
	} -- 201
	self:spawnBurst( -- 204
		t.x0, -- 204
		t.y0, -- 204
		5, -- 204
		PALETTE.amberCore, -- 204
		105 -- 204
	) -- 204
	self:spawnBurst( -- 205
		t.x1, -- 205
		t.y1, -- 205
		t.hit and 9 or 6, -- 205
		t.hit and PALETTE.sealRedBright or PALETTE.amberDim, -- 205
		130 -- 205
	) -- 205
end -- 198
function VfxSystem.prototype.spawnBurst(self, wx, wy, count, color, speed) -- 208
	local i = 0 -- 209
	do -- 209
		i = 0 -- 210
		while i < count do -- 210
			local a = self:rand() * math.pi * 2 -- 211
			local s = speed * (0.35 + self:rand() * 0.85) -- 212
			local life = 0.22 + self:rand() * 0.26 -- 213
			local ____self_sparks_8 = self.sparks -- 213
			____self_sparks_8[#____self_sparks_8 + 1] = { -- 214
				x = wx, -- 215
				y = wy, -- 215
				vx = math.cos(a) * s, -- 216
				vy = math.sin(a) * s + 35, -- 217
				life = life, -- 218
				maxLife = life, -- 218
				size = 1.8 + self:rand() * 2.4, -- 219
				color = color -- 220
			} -- 220
			i = i + 1 -- 210
		end -- 210
	end -- 210
end -- 208
function VfxSystem.prototype.update(self, dt, ambient) -- 225
	if self.visualHitstop > 0 then -- 225
		self.visualHitstop = math.max(0, self.visualHitstop - dt) -- 227
		return -- 228
	end -- 228
	self.hitVignette = math.max(0, self.hitVignette - dt * 2.2) -- 230
	self.deflectFlash = math.max(0, self.deflectFlash - dt * 3.2) -- 231
	self.crosshairKick = math.max(0, self.crosshairKick - dt * 48) -- 232
	local w = 0 -- 235
	local i = 0 -- 236
	do -- 236
		i = 0 -- 237
		while i < #self.tracers do -- 237
			local tr = self.tracers[i + 1] -- 238
			tr.life = tr.life - dt -- 239
			if tr.life > 0 then -- 239
				self.tracers[w + 1] = tr -- 241
				w = w + 1 -- 242
			end -- 242
			i = i + 1 -- 237
		end -- 237
	end -- 237
	__TS__ArraySetLength(self.tracers, w) -- 237
	w = 0 -- 248
	do -- 248
		i = 0 -- 249
		while i < #self.sparks do -- 249
			local sp = self.sparks[i + 1] -- 250
			sp.life = sp.life - dt -- 251
			if sp.life > 0 then -- 251
				sp.vy = sp.vy - 420 * dt -- 253
				sp.x = sp.x + sp.vx * dt -- 254
				sp.y = sp.y + sp.vy * dt -- 255
				if sp.y < 0 then -- 255
					sp.y = 0 -- 257
					sp.vy = -sp.vy * 0.35 -- 258
					sp.vx = sp.vx * 0.7 -- 259
				end -- 259
				self.sparks[w + 1] = sp -- 261
				w = w + 1 -- 262
			end -- 262
			i = i + 1 -- 249
		end -- 249
	end -- 249
	__TS__ArraySetLength(self.sparks, w) -- 249
	w = 0 -- 268
	do -- 268
		i = 0 -- 269
		while i < #self.rings do -- 269
			local rg = self.rings[i + 1] -- 270
			rg.life = rg.life - dt -- 271
			if rg.life > 0 then -- 271
				self.rings[w + 1] = rg -- 273
				w = w + 1 -- 274
			end -- 274
			i = i + 1 -- 269
		end -- 269
	end -- 269
	__TS__ArraySetLength(self.rings, w) -- 269
	do -- 269
		i = 0 -- 280
		while i < #self.motes do -- 280
			local m = self.motes[i + 1] -- 281
			m.phase = m.phase + dt * 2 -- 282
			if ambient == "drizzle" then -- 282
				m.fx = m.fx - dt * 0.14 -- 284
				m.fy = m.fy - dt * 0.72 -- 285
			elseif ambient == "ash" then -- 285
				m.fx = m.fx + (m.vx - 0.035) * dt -- 287
				m.fy = m.fy + m.vy * 0.55 * dt -- 288
			elseif ambient == "spores" then -- 288
				m.fx = m.fx + math.sin(m.phase) * 0.015 * dt -- 290
				m.fy = m.fy + math.cos(m.phase * 0.7) * 0.018 * dt -- 291
			else -- 291
				m.fx = m.fx + math.sin(m.phase * 0.6) * 0.01 * dt -- 293
				m.fy = m.fy + 0.018 * dt -- 294
			end -- 294
			if m.fx < 0 then -- 294
				m.fx = m.fx + 1 -- 296
			end -- 296
			if m.fx > 1 then -- 296
				m.fx = m.fx - 1 -- 297
			end -- 297
			if m.fy < 0 then -- 297
				m.fy = m.fy + 1 -- 298
			end -- 298
			if m.fy > 1 then -- 298
				m.fy = m.fy - 1 -- 299
			end -- 299
			i = i + 1 -- 280
		end -- 280
	end -- 280
end -- 225
function VfxSystem.prototype.drawWorldVfx(self, fgGlow, assets, cam) -- 304
	local i = 0 -- 306
	do -- 306
		i = 0 -- 307
		while i < #self.tracers do -- 307
			local tr = self.tracers[i + 1] -- 308
			local k = tr.life / tr.maxLife -- 309
			local x0 = cam:sx(tr.x0) -- 310
			local y0 = cam:sy(tr.y0) -- 311
			local x1 = cam:sx(tr.x1) -- 312
			local y1 = cam:sy(tr.y1) -- 313
			local outerCol = tr.hit and PALETTE.sealRedBright or PALETTE.amber -- 314
			fgGlow:drawSegment( -- 317
				Vec2(x0, y0), -- 317
				Vec2(x1, y1), -- 317
				3.2 * k, -- 317
				toColor(outerCol, 88 * k) -- 317
			) -- 317
			fgGlow:drawSegment( -- 318
				Vec2(x0, y0), -- 318
				Vec2(x1, y1), -- 318
				1.3 * k, -- 318
				toColor(PALETTE.amberCore, 195 * k) -- 318
			) -- 318
			if k > 0.55 then -- 318
				local mk = (k - 0.55) / 0.45 -- 322
				fillRadialGlow( -- 323
					fgGlow, -- 323
					x0, -- 323
					y0, -- 323
					18 * mk, -- 323
					14 * mk, -- 323
					toColor(PALETTE.amberCore, 138 * mk), -- 323
					Color(186, 126, 62, 0), -- 323
					12 -- 323
				) -- 323
				fgGlow:drawSegment( -- 324
					Vec2(x0 - 10 * mk, y0), -- 324
					Vec2(x0 + 10 * mk, y0), -- 324
					1.2, -- 324
					toColor(PALETTE.amberCore, 165 * mk) -- 324
				) -- 324
				fgGlow:drawSegment( -- 325
					Vec2(x0, y0 - 7 * mk), -- 325
					Vec2(x0, y0 + 7 * mk), -- 325
					1, -- 325
					toColor(PALETTE.amber, 145 * mk) -- 325
				) -- 325
			end -- 325
			if tr.hit then -- 325
				local s = 16 * (1.15 - k * 0.45) -- 329
				fillRadialGlow( -- 330
					fgGlow, -- 330
					x1, -- 330
					y1, -- 330
					s * 1.15, -- 330
					s * 0.9, -- 330
					toColor(PALETTE.sealRedBright, 130 * k), -- 330
					Color(168, 46, 44, 0), -- 330
					12 -- 330
				) -- 330
				fgGlow:drawSegment( -- 331
					Vec2(x1 - s, y1 - s * 0.55), -- 331
					Vec2(x1 + s, y1 + s * 0.55), -- 331
					1.6 * k, -- 331
					toColor(PALETTE.crimsonCore, 185 * k) -- 331
				) -- 331
				fgGlow:drawSegment( -- 332
					Vec2(x1 - s * 0.45, y1 + s * 0.7), -- 332
					Vec2(x1 + s * 0.45, y1 - s * 0.7), -- 332
					1.2 * k, -- 332
					toColor(PALETTE.sealRedBright, 160 * k) -- 332
				) -- 332
			end -- 332
			i = i + 1 -- 307
		end -- 307
	end -- 307
	if self.deflectFlash > 0 then -- 307
		local k = self.deflectFlash -- 337
		local dy = cam:sy(self.deflectY + (1 - k) * 11) -- 338
		local height = cam:len(18 + (1 - k) * 12) -- 339
		assets:tryPlace( -- 340
			"stone_chips", -- 340
			"blocked", -- 340
			cam:sx(self.deflectX), -- 340
			dy, -- 340
			height, -- 340
			height, -- 340
			{opacity = k, layer = 8} -- 340
		) -- 340
	end -- 340
	do -- 340
		i = 0 -- 346
		while i < #self.rings do -- 346
			local rg = self.rings[i + 1] -- 347
			local prog = 1 - rg.life / rg.maxLife -- 348
			local r = math.max( -- 349
				4, -- 349
				cam:len(rg.maxR) * prog -- 349
			) -- 349
			local alpha = (1 - prog) * 0.8 -- 350
			local rx = cam:sx(rg.x) -- 351
			local ry = cam:sy(rg.y) -- 352
			if not assets:tryPlace( -- 352
				"ink_enso_fine", -- 353
				"vfx_ring_" .. tostring(i), -- 353
				rx, -- 353
				ry, -- 353
				r * 2.35, -- 353
				r * 2.35, -- 353
				{ -- 353
					color = toColor(rg.color), -- 354
					opacity = alpha, -- 354
					angle = prog * 24, -- 354
					layer = 7 -- 354
				} -- 354
			) then -- 354
				fgGlow:drawRing( -- 356
					Vec2(rx, ry), -- 356
					math.max(1, r - 1.8), -- 356
					r, -- 356
					Color(0, 0, 0, 0), -- 356
					1.2, -- 356
					toColor(rg.color, alpha * 230) -- 356
				) -- 356
			end -- 356
			i = i + 1 -- 346
		end -- 346
	end -- 346
	do -- 346
		i = 0 -- 361
		while i < #self.sparks do -- 361
			local sp = self.sparks[i + 1] -- 362
			local k = sp.life / sp.maxLife -- 363
			local sx = cam:sx(sp.x) -- 364
			local sy = cam:sy(sp.y) -- 365
			local tx = sx - sp.vx * 0.02 * cam.ppu -- 366
			local ty = sy - sp.vy * 0.02 * cam.ppu -- 367
			fgGlow:drawSegment( -- 368
				Vec2(tx, ty), -- 368
				Vec2(sx, sy), -- 368
				sp.size * k * 0.9, -- 368
				toColor(sp.color, 210 * k) -- 368
			) -- 368
			i = i + 1 -- 361
		end -- 361
	end -- 361
end -- 304
function VfxSystem.prototype.drawScreenVfx(self, fgGlow, w, h, roomKey) -- 373
	local theme = themeOf(roomKey) -- 374
	local kind = theme.ambient -- 375
	local i = 0 -- 376
	do -- 376
		i = 0 -- 377
		while i < #self.motes do -- 377
			local m = self.motes[i + 1] -- 378
			local x = m.fx * w -- 379
			local y = m.fy * h -- 380
			local tw = 0.55 + 0.45 * math.sin(m.phase) -- 381
			if kind == "drizzle" then -- 381
				fgGlow:drawSegment( -- 383
					Vec2(x, y), -- 383
					Vec2(x + 4, y + 18), -- 383
					0.85, -- 383
					Color( -- 383
						156, -- 383
						174, -- 383
						188, -- 383
						math.floor(44 * tw + 0.5) -- 383
					) -- 383
				) -- 383
			elseif kind == "ash" then -- 383
				local c = roomKey == "gate" and PALETTE.sealRedBright or PALETTE.amberDim -- 385
				fgGlow:drawDot( -- 386
					Vec2(x, y), -- 386
					m.size * 0.82, -- 386
					toColor(c, 78 * tw) -- 386
				) -- 386
			elseif kind == "spores" then -- 386
				fgGlow:drawDot( -- 388
					Vec2(x, y), -- 388
					m.size * 0.9, -- 388
					toColor(PALETTE.emerald, 82 * tw) -- 388
				) -- 388
			else -- 388
				fgGlow:drawDot( -- 390
					Vec2(x, y), -- 390
					m.size * 0.95, -- 390
					toColor(PALETTE.amberCore, 94 * tw) -- 390
				) -- 390
			end -- 390
			i = i + 1 -- 377
		end -- 377
	end -- 377
	if self.hitVignette > 0.01 then -- 377
		local a = math.floor(120 * self.hitVignette + 0.5) -- 396
		local edge = 72 -- 397
		fillHGradRect( -- 398
			fgGlow, -- 398
			0, -- 398
			0, -- 398
			edge, -- 398
			h, -- 398
			Color(148, 36, 32, a), -- 398
			Color(148, 36, 32, 0) -- 398
		) -- 398
		fillHGradRect( -- 399
			fgGlow, -- 399
			w - edge, -- 399
			0, -- 399
			edge, -- 399
			h, -- 399
			Color(148, 36, 32, 0), -- 399
			Color(148, 36, 32, a) -- 399
		) -- 399
		fillVGradRect( -- 400
			fgGlow, -- 400
			0, -- 400
			0, -- 400
			w, -- 400
			edge * 0.8, -- 400
			Color(148, 36, 32, a), -- 400
			Color(148, 36, 32, 0) -- 400
		) -- 400
		fillVGradRect( -- 401
			fgGlow, -- 401
			0, -- 401
			h - edge * 0.8, -- 401
			w, -- 401
			edge * 0.8, -- 401
			Color(148, 36, 32, 0), -- 401
			Color(148, 36, 32, a) -- 401
		) -- 401
	end -- 401
end -- 373
return ____exports -- 373