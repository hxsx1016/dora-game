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
		local isBrick = p.room.brickX ~= nil and math.abs(ev.bottleLandX - p.room.brickX) <= 36 -- 175
		local ringCol = isBrick and PALETTE.amber or PALETTE.emerald -- 176
		local ____self_rings_4 = self.rings -- 176
		____self_rings_4[#____self_rings_4 + 1] = { -- 177
			x = ev.bottleLandX, -- 177
			y = 4, -- 177
			maxR = isBrick and 96 or 38, -- 177
			life = 0.85, -- 177
			maxLife = 0.85, -- 177
			color = ringCol -- 177
		} -- 177
		local ____self_rings_5 = self.rings -- 177
		____self_rings_5[#____self_rings_5 + 1] = { -- 178
			x = ev.bottleLandX, -- 178
			y = 4, -- 178
			maxR = isBrick and 62 or 22, -- 178
			life = 0.52, -- 178
			maxLife = 0.52, -- 178
			color = PALETTE.xuanWarm -- 178
		} -- 178
		self:spawnBurst( -- 179
			ev.bottleLandX, -- 179
			6, -- 179
			10, -- 179
			PALETTE.amberDim, -- 179
			120 -- 179
		) -- 179
		cam:addShake(isBrick and 3.5 or 1.5) -- 180
	end -- 180
	if ev.cartJustDocked then -- 180
		local cx = p.cartAxle -- 184
		local cy = p.room.cart.baseY + 8 -- 185
		local ____self_rings_6 = self.rings -- 185
		____self_rings_6[#____self_rings_6 + 1] = { -- 186
			x = cx, -- 186
			y = cy, -- 186
			maxR = 58, -- 186
			life = 0.55, -- 186
			maxLife = 0.55, -- 186
			color = PALETTE.emerald -- 186
		} -- 186
		self:spawnBurst( -- 187
			cx, -- 187
			cy, -- 187
			12, -- 187
			PALETTE.amber, -- 187
			115 -- 187
		) -- 187
		cam:addShake(4.8) -- 188
	end -- 188
	if ev.caughtTriggered then -- 188
		self.hitVignette = 0.9 -- 192
		cam:addShake(9) -- 193
	end -- 193
end -- 120
function VfxSystem.prototype.spawnShot(self, t) -- 197
	local ____self_tracers_7 = self.tracers -- 197
	____self_tracers_7[#____self_tracers_7 + 1] = { -- 198
		x0 = t.x0, -- 199
		y0 = t.y0, -- 199
		x1 = t.x1, -- 199
		y1 = t.y1, -- 199
		hit = t.hit, -- 200
		life = 0.16, -- 200
		maxLife = 0.16 -- 200
	} -- 200
	self:spawnBurst( -- 203
		t.x0, -- 203
		t.y0, -- 203
		5, -- 203
		PALETTE.amberCore, -- 203
		105 -- 203
	) -- 203
	self:spawnBurst( -- 204
		t.x1, -- 204
		t.y1, -- 204
		t.hit and 9 or 6, -- 204
		t.hit and PALETTE.sealRedBright or PALETTE.amberDim, -- 204
		130 -- 204
	) -- 204
end -- 197
function VfxSystem.prototype.spawnBurst(self, wx, wy, count, color, speed) -- 207
	local i = 0 -- 208
	do -- 208
		i = 0 -- 209
		while i < count do -- 209
			local a = self:rand() * math.pi * 2 -- 210
			local s = speed * (0.35 + self:rand() * 0.85) -- 211
			local life = 0.22 + self:rand() * 0.26 -- 212
			local ____self_sparks_8 = self.sparks -- 212
			____self_sparks_8[#____self_sparks_8 + 1] = { -- 213
				x = wx, -- 214
				y = wy, -- 214
				vx = math.cos(a) * s, -- 215
				vy = math.sin(a) * s + 35, -- 216
				life = life, -- 217
				maxLife = life, -- 217
				size = 1.8 + self:rand() * 2.4, -- 218
				color = color -- 219
			} -- 219
			i = i + 1 -- 209
		end -- 209
	end -- 209
end -- 207
function VfxSystem.prototype.update(self, dt, ambient) -- 224
	if self.visualHitstop > 0 then -- 224
		self.visualHitstop = math.max(0, self.visualHitstop - dt) -- 226
		return -- 227
	end -- 227
	self.hitVignette = math.max(0, self.hitVignette - dt * 2.2) -- 229
	self.deflectFlash = math.max(0, self.deflectFlash - dt * 3.2) -- 230
	self.crosshairKick = math.max(0, self.crosshairKick - dt * 48) -- 231
	local w = 0 -- 234
	local i = 0 -- 235
	do -- 235
		i = 0 -- 236
		while i < #self.tracers do -- 236
			local tr = self.tracers[i + 1] -- 237
			tr.life = tr.life - dt -- 238
			if tr.life > 0 then -- 238
				self.tracers[w + 1] = tr -- 240
				w = w + 1 -- 241
			end -- 241
			i = i + 1 -- 236
		end -- 236
	end -- 236
	__TS__ArraySetLength(self.tracers, w) -- 236
	w = 0 -- 247
	do -- 247
		i = 0 -- 248
		while i < #self.sparks do -- 248
			local sp = self.sparks[i + 1] -- 249
			sp.life = sp.life - dt -- 250
			if sp.life > 0 then -- 250
				sp.vy = sp.vy - 420 * dt -- 252
				sp.x = sp.x + sp.vx * dt -- 253
				sp.y = sp.y + sp.vy * dt -- 254
				if sp.y < 0 then -- 254
					sp.y = 0 -- 256
					sp.vy = -sp.vy * 0.35 -- 257
					sp.vx = sp.vx * 0.7 -- 258
				end -- 258
				self.sparks[w + 1] = sp -- 260
				w = w + 1 -- 261
			end -- 261
			i = i + 1 -- 248
		end -- 248
	end -- 248
	__TS__ArraySetLength(self.sparks, w) -- 248
	w = 0 -- 267
	do -- 267
		i = 0 -- 268
		while i < #self.rings do -- 268
			local rg = self.rings[i + 1] -- 269
			rg.life = rg.life - dt -- 270
			if rg.life > 0 then -- 270
				self.rings[w + 1] = rg -- 272
				w = w + 1 -- 273
			end -- 273
			i = i + 1 -- 268
		end -- 268
	end -- 268
	__TS__ArraySetLength(self.rings, w) -- 268
	do -- 268
		i = 0 -- 279
		while i < #self.motes do -- 279
			local m = self.motes[i + 1] -- 280
			m.phase = m.phase + dt * 2 -- 281
			if ambient == "drizzle" then -- 281
				m.fx = m.fx - dt * 0.14 -- 283
				m.fy = m.fy - dt * 0.72 -- 284
			elseif ambient == "ash" then -- 284
				m.fx = m.fx + (m.vx - 0.035) * dt -- 286
				m.fy = m.fy + m.vy * 0.55 * dt -- 287
			elseif ambient == "spores" then -- 287
				m.fx = m.fx + math.sin(m.phase) * 0.015 * dt -- 289
				m.fy = m.fy + math.cos(m.phase * 0.7) * 0.018 * dt -- 290
			else -- 290
				m.fx = m.fx + math.sin(m.phase * 0.6) * 0.01 * dt -- 292
				m.fy = m.fy + 0.018 * dt -- 293
			end -- 293
			if m.fx < 0 then -- 293
				m.fx = m.fx + 1 -- 295
			end -- 295
			if m.fx > 1 then -- 295
				m.fx = m.fx - 1 -- 296
			end -- 296
			if m.fy < 0 then -- 296
				m.fy = m.fy + 1 -- 297
			end -- 297
			if m.fy > 1 then -- 297
				m.fy = m.fy - 1 -- 298
			end -- 298
			i = i + 1 -- 279
		end -- 279
	end -- 279
end -- 224
function VfxSystem.prototype.drawWorldVfx(self, fgGlow, assets, cam) -- 303
	local i = 0 -- 305
	do -- 305
		i = 0 -- 306
		while i < #self.tracers do -- 306
			local tr = self.tracers[i + 1] -- 307
			local k = tr.life / tr.maxLife -- 308
			local x0 = cam:sx(tr.x0) -- 309
			local y0 = cam:sy(tr.y0) -- 310
			local x1 = cam:sx(tr.x1) -- 311
			local y1 = cam:sy(tr.y1) -- 312
			local outerCol = tr.hit and PALETTE.sealRedBright or PALETTE.amber -- 313
			fgGlow:drawSegment( -- 316
				Vec2(x0, y0), -- 316
				Vec2(x1, y1), -- 316
				3.2 * k, -- 316
				toColor(outerCol, 88 * k) -- 316
			) -- 316
			fgGlow:drawSegment( -- 317
				Vec2(x0, y0), -- 317
				Vec2(x1, y1), -- 317
				1.3 * k, -- 317
				toColor(PALETTE.amberCore, 195 * k) -- 317
			) -- 317
			if k > 0.55 then -- 317
				local mk = (k - 0.55) / 0.45 -- 321
				fillRadialGlow( -- 322
					fgGlow, -- 322
					x0, -- 322
					y0, -- 322
					18 * mk, -- 322
					14 * mk, -- 322
					toColor(PALETTE.amberCore, 138 * mk), -- 322
					Color(186, 126, 62, 0), -- 322
					12 -- 322
				) -- 322
				fgGlow:drawSegment( -- 323
					Vec2(x0 - 10 * mk, y0), -- 323
					Vec2(x0 + 10 * mk, y0), -- 323
					1.2, -- 323
					toColor(PALETTE.amberCore, 165 * mk) -- 323
				) -- 323
				fgGlow:drawSegment( -- 324
					Vec2(x0, y0 - 7 * mk), -- 324
					Vec2(x0, y0 + 7 * mk), -- 324
					1, -- 324
					toColor(PALETTE.amber, 145 * mk) -- 324
				) -- 324
			end -- 324
			if tr.hit then -- 324
				local s = 16 * (1.15 - k * 0.45) -- 328
				fillRadialGlow( -- 329
					fgGlow, -- 329
					x1, -- 329
					y1, -- 329
					s * 1.15, -- 329
					s * 0.9, -- 329
					toColor(PALETTE.sealRedBright, 130 * k), -- 329
					Color(168, 46, 44, 0), -- 329
					12 -- 329
				) -- 329
				fgGlow:drawSegment( -- 330
					Vec2(x1 - s, y1 - s * 0.55), -- 330
					Vec2(x1 + s, y1 + s * 0.55), -- 330
					1.6 * k, -- 330
					toColor(PALETTE.crimsonCore, 185 * k) -- 330
				) -- 330
				fgGlow:drawSegment( -- 331
					Vec2(x1 - s * 0.45, y1 + s * 0.7), -- 331
					Vec2(x1 + s * 0.45, y1 - s * 0.7), -- 331
					1.2 * k, -- 331
					toColor(PALETTE.sealRedBright, 160 * k) -- 331
				) -- 331
			end -- 331
			i = i + 1 -- 306
		end -- 306
	end -- 306
	if self.deflectFlash > 0 then -- 306
		local k = self.deflectFlash -- 336
		local dy = cam:sy(self.deflectY + (1 - k) * 11) -- 337
		local height = cam:len(18 + (1 - k) * 12) -- 338
		assets:tryPlace( -- 339
			"stone_chips", -- 339
			"blocked", -- 339
			cam:sx(self.deflectX), -- 339
			dy, -- 339
			height, -- 339
			height, -- 339
			{opacity = k, layer = 8} -- 339
		) -- 339
	end -- 339
	do -- 339
		i = 0 -- 345
		while i < #self.rings do -- 345
			local rg = self.rings[i + 1] -- 346
			local prog = 1 - rg.life / rg.maxLife -- 347
			local r = math.max( -- 348
				4, -- 348
				cam:len(rg.maxR) * prog -- 348
			) -- 348
			local alpha = (1 - prog) * 0.8 -- 349
			local rx = cam:sx(rg.x) -- 350
			local ry = cam:sy(rg.y) -- 351
			if not assets:tryPlace( -- 351
				"ink_enso_fine", -- 352
				"vfx_ring_" .. tostring(i), -- 352
				rx, -- 352
				ry, -- 352
				r * 2.35, -- 352
				r * 2.35, -- 352
				{ -- 352
					color = toColor(rg.color), -- 353
					opacity = alpha, -- 353
					angle = prog * 24, -- 353
					layer = 7 -- 353
				} -- 353
			) then -- 353
				fgGlow:drawRing( -- 355
					Vec2(rx, ry), -- 355
					math.max(1, r - 1.8), -- 355
					r, -- 355
					Color(0, 0, 0, 0), -- 355
					1.2, -- 355
					toColor(rg.color, alpha * 230) -- 355
				) -- 355
			end -- 355
			i = i + 1 -- 345
		end -- 345
	end -- 345
	do -- 345
		i = 0 -- 360
		while i < #self.sparks do -- 360
			local sp = self.sparks[i + 1] -- 361
			local k = sp.life / sp.maxLife -- 362
			local sx = cam:sx(sp.x) -- 363
			local sy = cam:sy(sp.y) -- 364
			local tx = sx - sp.vx * 0.02 * cam.ppu -- 365
			local ty = sy - sp.vy * 0.02 * cam.ppu -- 366
			fgGlow:drawSegment( -- 367
				Vec2(tx, ty), -- 367
				Vec2(sx, sy), -- 367
				sp.size * k * 0.9, -- 367
				toColor(sp.color, 210 * k) -- 367
			) -- 367
			i = i + 1 -- 360
		end -- 360
	end -- 360
end -- 303
function VfxSystem.prototype.drawScreenVfx(self, fgGlow, w, h, roomKey) -- 372
	local theme = themeOf(roomKey) -- 373
	local kind = theme.ambient -- 374
	local i = 0 -- 375
	do -- 375
		i = 0 -- 376
		while i < #self.motes do -- 376
			local m = self.motes[i + 1] -- 377
			local x = m.fx * w -- 378
			local y = m.fy * h -- 379
			local tw = 0.55 + 0.45 * math.sin(m.phase) -- 380
			if kind == "drizzle" then -- 380
				fgGlow:drawSegment( -- 382
					Vec2(x, y), -- 382
					Vec2(x + 4, y + 18), -- 382
					0.85, -- 382
					Color( -- 382
						156, -- 382
						174, -- 382
						188, -- 382
						math.floor(44 * tw + 0.5) -- 382
					) -- 382
				) -- 382
			elseif kind == "ash" then -- 382
				local c = roomKey == "gate" and PALETTE.sealRedBright or PALETTE.amberDim -- 384
				fgGlow:drawDot( -- 385
					Vec2(x, y), -- 385
					m.size * 0.82, -- 385
					toColor(c, 78 * tw) -- 385
				) -- 385
			elseif kind == "spores" then -- 385
				fgGlow:drawDot( -- 387
					Vec2(x, y), -- 387
					m.size * 0.9, -- 387
					toColor(PALETTE.emerald, 82 * tw) -- 387
				) -- 387
			else -- 387
				fgGlow:drawDot( -- 389
					Vec2(x, y), -- 389
					m.size * 0.95, -- 389
					toColor(PALETTE.amberCore, 94 * tw) -- 389
				) -- 389
			end -- 389
			i = i + 1 -- 376
		end -- 376
	end -- 376
	if self.hitVignette > 0.01 then -- 376
		local a = math.floor(120 * self.hitVignette + 0.5) -- 395
		local edge = 72 -- 396
		fillHGradRect( -- 397
			fgGlow, -- 397
			0, -- 397
			0, -- 397
			edge, -- 397
			h, -- 397
			Color(148, 36, 32, a), -- 397
			Color(148, 36, 32, 0) -- 397
		) -- 397
		fillHGradRect( -- 398
			fgGlow, -- 398
			w - edge, -- 398
			0, -- 398
			edge, -- 398
			h, -- 398
			Color(148, 36, 32, 0), -- 398
			Color(148, 36, 32, a) -- 398
		) -- 398
		fillVGradRect( -- 399
			fgGlow, -- 399
			0, -- 399
			0, -- 399
			w, -- 399
			edge * 0.8, -- 399
			Color(148, 36, 32, a), -- 399
			Color(148, 36, 32, 0) -- 399
		) -- 399
		fillVGradRect( -- 400
			fgGlow, -- 400
			0, -- 400
			h - edge * 0.8, -- 400
			w, -- 400
			edge * 0.8, -- 400
			Color(148, 36, 32, 0), -- 400
			Color(148, 36, 32, a) -- 400
		) -- 400
	end -- 400
end -- 372
return ____exports -- 372