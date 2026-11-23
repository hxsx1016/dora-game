-- [ts]: vfx.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 10
local Color = ____Dora.Color -- 10
local Vec2 = ____Dora.Vec2 -- 10
local ____theme = require("Script.watch.fe.theme") -- 14
local PALETTE = ____theme.PALETTE -- 16
local drawDiamond = ____theme.drawDiamond -- 18
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
			18, -- 135
			PALETTE.crimson, -- 135
			210 -- 135
		) -- 135
		self:spawnBurst( -- 136
			ev.enemyKilledX, -- 136
			ev.enemyKilledY, -- 136
			8, -- 136
			PALETTE.cyanCore, -- 136
			150 -- 136
		) -- 136
		local ____self_rings_1 = self.rings -- 136
		____self_rings_1[#____self_rings_1 + 1] = { -- 137
			x = ev.enemyKilledX, -- 137
			y = ev.enemyKilledY, -- 137
			maxR = 46, -- 137
			life = 0.34, -- 137
			maxLife = 0.34, -- 137
			color = PALETTE.crimson -- 137
		} -- 137
	end -- 137
	if ev.coverDeflect then -- 137
		self.deflectFlash = 1 -- 141
		self.deflectX = p.player.x + p.player.facing * 20 -- 142
		self.deflectY = p.player.y + p.player.h * 0.58 -- 143
		self:spawnBurst( -- 144
			self.deflectX, -- 144
			self.deflectY, -- 144
			14, -- 144
			PALETTE.cyan, -- 144
			180 -- 144
		) -- 144
		local ____self_rings_2 = self.rings -- 144
		____self_rings_2[#____self_rings_2 + 1] = { -- 145
			x = self.deflectX, -- 145
			y = self.deflectY, -- 145
			maxR = 42, -- 145
			life = 0.32, -- 145
			maxLife = 0.32, -- 145
			color = PALETTE.cyan -- 145
		} -- 145
		cam:addShake(4.2) -- 146
	end -- 146
	if ev.playerHit then -- 146
		self.hitVignette = 1 -- 150
		self:spawnBurst( -- 151
			p.player.x, -- 151
			p.player.y + p.player.h * 0.55, -- 151
			16, -- 151
			PALETTE.crimson, -- 151
			220 -- 151
		) -- 151
		cam:addShake(11) -- 152
		self.visualHitstop = 0.06 -- 153
	end -- 153
	if ev.rollStarted then -- 153
		self:spawnBurst( -- 157
			p.player.x, -- 157
			p.player.y + 4, -- 157
			8, -- 157
			PALETTE.cyan, -- 157
			95 -- 157
		) -- 157
	end -- 157
	if ev.knockPulse then -- 157
		local ____self_rings_3 = self.rings -- 157
		____self_rings_3[#____self_rings_3 + 1] = { -- 161
			x = ev.knockX, -- 161
			y = ev.knockY, -- 161
			maxR = 54, -- 161
			life = 0.55, -- 161
			maxLife = 0.55, -- 161
			color = PALETTE.amber -- 161
		} -- 161
		local ____self_rings_4 = self.rings -- 161
		____self_rings_4[#____self_rings_4 + 1] = { -- 162
			x = ev.knockX, -- 162
			y = ev.knockY, -- 162
			maxR = 34, -- 162
			life = 0.38, -- 162
			maxLife = 0.38, -- 162
			color = PALETTE.cyanCore -- 162
		} -- 162
	end -- 162
	if ev.bottleLanded then -- 162
		local isBrick = p.room.brickX ~= nil and math.abs(ev.bottleLandX - p.room.brickX) <= 36 -- 166
		local ringCol = isBrick and PALETTE.amber or PALETTE.emerald -- 167
		local ____self_rings_5 = self.rings -- 167
		____self_rings_5[#____self_rings_5 + 1] = { -- 168
			x = ev.bottleLandX, -- 168
			y = 4, -- 168
			maxR = isBrick and 96 or 38, -- 168
			life = 0.85, -- 168
			maxLife = 0.85, -- 168
			color = ringCol -- 168
		} -- 168
		local ____self_rings_6 = self.rings -- 168
		____self_rings_6[#____self_rings_6 + 1] = { -- 169
			x = ev.bottleLandX, -- 169
			y = 4, -- 169
			maxR = isBrick and 62 or 22, -- 169
			life = 0.52, -- 169
			maxLife = 0.52, -- 169
			color = PALETTE.cyanCore -- 169
		} -- 169
		self:spawnBurst( -- 170
			ev.bottleLandX, -- 170
			6, -- 170
			12, -- 170
			PALETTE.emerald, -- 170
			140 -- 170
		) -- 170
		cam:addShake(isBrick and 3.5 or 1.5) -- 171
	end -- 171
	if ev.cartJustDocked then -- 171
		local cx = p.cartAxle -- 175
		local cy = p.room.cart.baseY + 8 -- 176
		local ____self_rings_7 = self.rings -- 176
		____self_rings_7[#____self_rings_7 + 1] = { -- 177
			x = cx, -- 177
			y = cy, -- 177
			maxR = 60, -- 177
			life = 0.55, -- 177
			maxLife = 0.55, -- 177
			color = PALETTE.emerald -- 177
		} -- 177
		self:spawnBurst( -- 178
			cx, -- 178
			cy, -- 178
			14, -- 178
			PALETTE.amber, -- 178
			130 -- 178
		) -- 178
		cam:addShake(5) -- 179
	end -- 179
	if ev.caughtTriggered then -- 179
		self.hitVignette = 0.9 -- 183
		cam:addShake(9) -- 184
	end -- 184
end -- 120
function VfxSystem.prototype.spawnShot(self, t) -- 188
	local ____self_tracers_8 = self.tracers -- 188
	____self_tracers_8[#____self_tracers_8 + 1] = { -- 189
		x0 = t.x0, -- 190
		y0 = t.y0, -- 190
		x1 = t.x1, -- 190
		y1 = t.y1, -- 190
		hit = t.hit, -- 191
		life = 0.18, -- 191
		maxLife = 0.18 -- 191
	} -- 191
	self:spawnBurst( -- 194
		t.x0, -- 194
		t.y0, -- 194
		5, -- 194
		PALETTE.cyanCore, -- 194
		120 -- 194
	) -- 194
	self:spawnBurst( -- 195
		t.x1, -- 195
		t.y1, -- 195
		t.hit and 10 or 6, -- 195
		t.hit and PALETTE.crimson or PALETTE.cyan, -- 195
		145 -- 195
	) -- 195
end -- 188
function VfxSystem.prototype.spawnBurst(self, wx, wy, count, color, speed) -- 198
	local i = 0 -- 199
	do -- 199
		i = 0 -- 200
		while i < count do -- 200
			local a = self:rand() * math.pi * 2 -- 201
			local s = speed * (0.35 + self:rand() * 0.85) -- 202
			local life = 0.22 + self:rand() * 0.26 -- 203
			local ____self_sparks_9 = self.sparks -- 203
			____self_sparks_9[#____self_sparks_9 + 1] = { -- 204
				x = wx, -- 205
				y = wy, -- 205
				vx = math.cos(a) * s, -- 206
				vy = math.sin(a) * s + 35, -- 207
				life = life, -- 208
				maxLife = life, -- 208
				size = 1.8 + self:rand() * 2.4, -- 209
				color = color -- 210
			} -- 210
			i = i + 1 -- 200
		end -- 200
	end -- 200
end -- 198
function VfxSystem.prototype.update(self, dt, ambient) -- 215
	if self.visualHitstop > 0 then -- 215
		self.visualHitstop = math.max(0, self.visualHitstop - dt) -- 217
		return -- 218
	end -- 218
	self.hitVignette = math.max(0, self.hitVignette - dt * 2.2) -- 220
	self.deflectFlash = math.max(0, self.deflectFlash - dt * 3.2) -- 221
	self.crosshairKick = math.max(0, self.crosshairKick - dt * 48) -- 222
	local w = 0 -- 225
	local i = 0 -- 226
	do -- 226
		i = 0 -- 227
		while i < #self.tracers do -- 227
			local tr = self.tracers[i + 1] -- 228
			tr.life = tr.life - dt -- 229
			if tr.life > 0 then -- 229
				self.tracers[w + 1] = tr -- 231
				w = w + 1 -- 232
			end -- 232
			i = i + 1 -- 227
		end -- 227
	end -- 227
	__TS__ArraySetLength(self.tracers, w) -- 227
	w = 0 -- 238
	do -- 238
		i = 0 -- 239
		while i < #self.sparks do -- 239
			local sp = self.sparks[i + 1] -- 240
			sp.life = sp.life - dt -- 241
			if sp.life > 0 then -- 241
				sp.vy = sp.vy - 420 * dt -- 243
				sp.x = sp.x + sp.vx * dt -- 244
				sp.y = sp.y + sp.vy * dt -- 245
				if sp.y < 0 then -- 245
					sp.y = 0 -- 247
					sp.vy = -sp.vy * 0.35 -- 248
					sp.vx = sp.vx * 0.7 -- 249
				end -- 249
				self.sparks[w + 1] = sp -- 251
				w = w + 1 -- 252
			end -- 252
			i = i + 1 -- 239
		end -- 239
	end -- 239
	__TS__ArraySetLength(self.sparks, w) -- 239
	w = 0 -- 258
	do -- 258
		i = 0 -- 259
		while i < #self.rings do -- 259
			local rg = self.rings[i + 1] -- 260
			rg.life = rg.life - dt -- 261
			if rg.life > 0 then -- 261
				self.rings[w + 1] = rg -- 263
				w = w + 1 -- 264
			end -- 264
			i = i + 1 -- 259
		end -- 259
	end -- 259
	__TS__ArraySetLength(self.rings, w) -- 259
	do -- 259
		i = 0 -- 270
		while i < #self.motes do -- 270
			local m = self.motes[i + 1] -- 271
			m.phase = m.phase + dt * 2 -- 272
			if ambient == "drizzle" then -- 272
				m.fx = m.fx - dt * 0.14 -- 274
				m.fy = m.fy - dt * 0.72 -- 275
			elseif ambient == "ash" then -- 275
				m.fx = m.fx + (m.vx - 0.035) * dt -- 277
				m.fy = m.fy + m.vy * 0.55 * dt -- 278
			elseif ambient == "spores" then -- 278
				m.fx = m.fx + math.sin(m.phase) * 0.015 * dt -- 280
				m.fy = m.fy + math.cos(m.phase * 0.7) * 0.018 * dt -- 281
			else -- 281
				m.fx = m.fx + math.sin(m.phase * 0.6) * 0.01 * dt -- 283
				m.fy = m.fy + 0.018 * dt -- 284
			end -- 284
			if m.fx < 0 then -- 284
				m.fx = m.fx + 1 -- 286
			end -- 286
			if m.fx > 1 then -- 286
				m.fx = m.fx - 1 -- 287
			end -- 287
			if m.fy < 0 then -- 287
				m.fy = m.fy + 1 -- 288
			end -- 288
			if m.fy > 1 then -- 288
				m.fy = m.fy - 1 -- 289
			end -- 289
			i = i + 1 -- 270
		end -- 270
	end -- 270
end -- 215
function VfxSystem.prototype.drawWorldVfx(self, fgGlow, cam) -- 294
	local i = 0 -- 296
	do -- 296
		i = 0 -- 297
		while i < #self.tracers do -- 297
			local tr = self.tracers[i + 1] -- 298
			local k = tr.life / tr.maxLife -- 299
			local x0 = cam:sx(tr.x0) -- 300
			local y0 = cam:sy(tr.y0) -- 301
			local x1 = cam:sx(tr.x1) -- 302
			local y1 = cam:sy(tr.y1) -- 303
			local outerCol = tr.hit and PALETTE.crimson or PALETTE.cyan -- 304
			fgGlow:drawSegment( -- 307
				Vec2(x0, y0), -- 307
				Vec2(x1, y1), -- 307
				5.5 * k, -- 307
				toColor(outerCol, 130 * k) -- 307
			) -- 307
			fgGlow:drawSegment( -- 308
				Vec2(x0, y0), -- 308
				Vec2(x1, y1), -- 308
				1.8 * k, -- 308
				toColor(PALETTE.cyanCore, 255 * k) -- 308
			) -- 308
			if k > 0.55 then -- 308
				local mk = (k - 0.55) / 0.45 -- 312
				fillRadialGlow( -- 313
					fgGlow, -- 313
					x0, -- 313
					y0, -- 313
					26 * mk, -- 313
					26 * mk, -- 313
					toColor(PALETTE.cyanCore, 180 * mk), -- 313
					Color(72, 224, 255, 0), -- 313
					12 -- 313
				) -- 313
				fgGlow:drawSegment( -- 314
					Vec2(x0 - 16 * mk, y0), -- 314
					Vec2(x0 + 16 * mk, y0), -- 314
					1.6, -- 314
					toColor(PALETTE.cyanCore, 220 * mk) -- 314
				) -- 314
				fgGlow:drawSegment( -- 315
					Vec2(x0, y0 - 14 * mk), -- 315
					Vec2(x0, y0 + 14 * mk), -- 315
					1.6, -- 315
					toColor(PALETTE.cyanCore, 220 * mk) -- 315
				) -- 315
			end -- 315
			if tr.hit then -- 315
				local s = 26 * (1.2 - k * 0.5) -- 319
				fgGlow:drawSegment( -- 320
					Vec2(x1 - s, y1 - s * 0.65), -- 320
					Vec2(x1 + s, y1 + s * 0.65), -- 320
					2.4 * k, -- 320
					toColor(PALETTE.crimsonCore, 240 * k) -- 320
				) -- 320
				fgGlow:drawSegment( -- 321
					Vec2(x1 - s * 0.55, y1 + s * 0.7), -- 321
					Vec2(x1 + s * 0.55, y1 - s * 0.7), -- 321
					1.8 * k, -- 321
					toColor(PALETTE.crimson, 210 * k) -- 321
				) -- 321
			end -- 321
			i = i + 1 -- 297
		end -- 297
	end -- 297
	if self.deflectFlash > 0 then -- 297
		local k = self.deflectFlash -- 327
		local dx = cam:sx(self.deflectX) -- 328
		local dy = cam:sy(self.deflectY) -- 329
		local r = 18 + (1 - k) * 32 -- 330
		drawDiamond( -- 331
			fgGlow, -- 331
			dx, -- 331
			dy, -- 331
			r * 0.65, -- 331
			r * 1.15, -- 331
			toColor(PALETTE.cyan, 65 * k), -- 331
			2.2, -- 331
			toColor(PALETTE.cyanCore, 235 * k) -- 331
		) -- 331
		fillRadialGlow( -- 332
			fgGlow, -- 332
			dx, -- 332
			dy, -- 332
			r * 1.6, -- 332
			r * 1.6, -- 332
			toColor(PALETTE.cyan, 120 * k), -- 332
			Color(72, 224, 255, 0), -- 332
			14 -- 332
		) -- 332
	end -- 332
	do -- 332
		i = 0 -- 336
		while i < #self.rings do -- 336
			local rg = self.rings[i + 1] -- 337
			local prog = 1 - rg.life / rg.maxLife -- 338
			local r = math.max( -- 339
				4, -- 339
				cam:len(rg.maxR) * prog -- 339
			) -- 339
			local alpha = (1 - prog) * 215 -- 340
			local rx = cam:sx(rg.x) -- 341
			local ry = cam:sy(rg.y) -- 342
			fgGlow:drawRing( -- 343
				Vec2(rx, ry), -- 343
				math.max(1, r - 2.2), -- 343
				r, -- 343
				Color(0, 0, 0, 0), -- 343
				1.5, -- 343
				toColor(rg.color, alpha) -- 343
			) -- 343
			i = i + 1 -- 336
		end -- 336
	end -- 336
	do -- 336
		i = 0 -- 347
		while i < #self.sparks do -- 347
			local sp = self.sparks[i + 1] -- 348
			local k = sp.life / sp.maxLife -- 349
			local sx = cam:sx(sp.x) -- 350
			local sy = cam:sy(sp.y) -- 351
			local tx = sx - sp.vx * 0.022 * cam.ppu -- 352
			local ty = sy - sp.vy * 0.022 * cam.ppu -- 353
			fgGlow:drawSegment( -- 354
				Vec2(tx, ty), -- 354
				Vec2(sx, sy), -- 354
				sp.size * k, -- 354
				toColor(sp.color, 235 * k) -- 354
			) -- 354
			i = i + 1 -- 347
		end -- 347
	end -- 347
end -- 294
function VfxSystem.prototype.drawScreenVfx(self, fgGlow, w, h, roomKey) -- 359
	local theme = themeOf(roomKey) -- 360
	local kind = theme.ambient -- 361
	local i = 0 -- 362
	do -- 362
		i = 0 -- 363
		while i < #self.motes do -- 363
			local m = self.motes[i + 1] -- 364
			local x = m.fx * w -- 365
			local y = m.fy * h -- 366
			local tw = 0.55 + 0.45 * math.sin(m.phase) -- 367
			if kind == "drizzle" then -- 367
				fgGlow:drawSegment( -- 369
					Vec2(x, y), -- 369
					Vec2(x + 4, y + 18), -- 369
					0.9, -- 369
					Color( -- 369
						156, -- 369
						206, -- 369
						240, -- 369
						math.floor(52 * tw + 0.5) -- 369
					) -- 369
				) -- 369
			elseif kind == "ash" then -- 369
				local c = roomKey == "gate" and PALETTE.crimson or PALETTE.amber -- 371
				fgGlow:drawDot( -- 372
					Vec2(x, y), -- 372
					m.size * 0.85, -- 372
					toColor(c, 92 * tw) -- 372
				) -- 372
			elseif kind == "spores" then -- 372
				fgGlow:drawDot( -- 374
					Vec2(x, y), -- 374
					m.size, -- 374
					toColor(PALETTE.emerald, 108 * tw) -- 374
				) -- 374
			else -- 374
				fgGlow:drawDot( -- 376
					Vec2(x, y), -- 376
					m.size * 1.05, -- 376
					toColor(PALETTE.amberCore, 118 * tw) -- 376
				) -- 376
			end -- 376
			i = i + 1 -- 363
		end -- 363
	end -- 363
	if self.hitVignette > 0.01 then -- 363
		local a = math.floor(135 * self.hitVignette + 0.5) -- 382
		local edge = 68 -- 383
		fillHGradRect( -- 384
			fgGlow, -- 384
			0, -- 384
			0, -- 384
			edge, -- 384
			h, -- 384
			Color(255, 32, 68, a), -- 384
			Color(255, 32, 68, 0) -- 384
		) -- 384
		fillHGradRect( -- 385
			fgGlow, -- 385
			w - edge, -- 385
			0, -- 385
			edge, -- 385
			h, -- 385
			Color(255, 32, 68, 0), -- 385
			Color(255, 32, 68, a) -- 385
		) -- 385
		fillVGradRect( -- 386
			fgGlow, -- 386
			0, -- 386
			0, -- 386
			w, -- 386
			edge * 0.8, -- 386
			Color(255, 32, 68, a), -- 386
			Color(255, 32, 68, 0) -- 386
		) -- 386
		fillVGradRect( -- 387
			fgGlow, -- 387
			0, -- 387
			h - edge * 0.8, -- 387
			w, -- 387
			edge * 0.8, -- 387
			Color(255, 32, 68, 0), -- 387
			Color(255, 32, 68, a) -- 387
		) -- 387
	end -- 387
end -- 359
return ____exports -- 359