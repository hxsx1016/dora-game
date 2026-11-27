-- [ts]: escort_world.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 20
local Color = ____Dora.Color -- 20
local Rect = ____Dora.Rect -- 20
local Vec2 = ____Dora.Vec2 -- 20
local ____depth = require("Script.watch.depth") -- 22
local LANE_DEPTH = ____depth.LANE_DEPTH -- 22
local ____occlusion = require("Script.watch.fe.occlusion") -- 25
local depthOrder = ____occlusion.depthOrder -- 25
local ____second_half_assets = require("Script.watch.fe.scenes.second_half_assets") -- 27
local ensureSecondHalfAssetsRegistered = ____second_half_assets.ensureSecondHalfAssetsRegistered -- 27
local ____theme = require("Script.watch.fe.theme") -- 28
local PALETTE = ____theme.PALETTE -- 29
local fillGradQuad = ____theme.fillGradQuad -- 30
local fillRadialGlow = ____theme.fillRadialGlow -- 31
local fillVGradRect = ____theme.fillVGradRect -- 32
local toColor = ____theme.toColor -- 33
local function clamp01(v) -- 36
	return math.max( -- 37
		0, -- 37
		math.min(1, v) -- 37
	) -- 37
end -- 36
function ____exports.isEscortWorldRoom(key) -- 40
	return key == "gatepath" or key == "escort1" or key == "escort2" or key == "escort3" or key == "escort4" or key == "escort5" -- 41
end -- 40
local TOWER_PROGRESSION = { -- 62
	gatepath = { -- 63
		scale = 0.24, -- 63
		screenXFrac = 0.85, -- 63
		screenYFrac = 0.72, -- 63
		beaconR = 18, -- 63
		dawnWarmth = 0.04 -- 63
	}, -- 63
	escort1 = { -- 64
		scale = 0.34, -- 64
		screenXFrac = 0.84, -- 64
		screenYFrac = 0.71, -- 64
		beaconR = 24, -- 64
		dawnWarmth = 0.08 -- 64
	}, -- 64
	escort2 = { -- 65
		scale = 0.44, -- 65
		screenXFrac = 0.82, -- 65
		screenYFrac = 0.74, -- 65
		beaconR = 28, -- 65
		dawnWarmth = 0.14 -- 65
	}, -- 65
	escort3 = { -- 66
		scale = 0.56, -- 66
		screenXFrac = 0.83, -- 66
		screenYFrac = 0.7, -- 66
		beaconR = 38, -- 66
		dawnWarmth = 0.24 -- 66
	}, -- 66
	escort4 = { -- 67
		scale = 0.72, -- 67
		screenXFrac = 0.84, -- 67
		screenYFrac = 0.68, -- 67
		beaconR = 48, -- 67
		dawnWarmth = 0.38 -- 67
	}, -- 67
	escort5 = { -- 68
		scale = 0.92, -- 68
		screenXFrac = 0.86, -- 68
		screenYFrac = 0.64, -- 68
		beaconR = 64, -- 68
		dawnWarmth = 0.62 -- 68
	} -- 68
} -- 68
____exports.EscortWorldRenderer = __TS__Class() -- 71
local EscortWorldRenderer = ____exports.EscortWorldRenderer -- 71
EscortWorldRenderer.name = "EscortWorldRenderer" -- 71
function EscortWorldRenderer.prototype.____constructor(self) -- 77
	self.carryBloomT = 0 -- 72
	self.gongSway = {} -- 73
	self.lastEnemyHitT = {} -- 74
	self.lastRoomKey = "" -- 75
	ensureSecondHalfAssetsRegistered() -- 78
end -- 77
function EscortWorldRenderer.prototype.reset(self) -- 81
	self.carryBloomT = 0 -- 82
	self.gongSway = {} -- 83
	self.lastEnemyHitT = {} -- 84
end -- 81
function EscortWorldRenderer.prototype.update(self, dt, p, carryStarted) -- 87
	if self.lastRoomKey ~= p.room.key then -- 88
		self.lastRoomKey = p.room.key -- 89
		self:reset() -- 90
	end -- 90
	if carryStarted then -- 92
		self.carryBloomT = 1.15 -- 93
	elseif self.carryBloomT > 0 then -- 94
		self.carryBloomT = math.max(0, self.carryBloomT - dt) -- 95
	end -- 95
	if p.room.key == "escort3" then -- 97
		do -- 97
			local i = 0 -- 98
			while i < #p.enemies do -- 98
				local en = p.enemies[i + 1] -- 99
				local prevHit = self.lastEnemyHitT[i] or 0 -- 100
				if en.hitT > prevHit + 0.05 then -- 101
					self.gongSway[i] = 1 -- 102
				end -- 102
				self.lastEnemyHitT[i] = en.hitT -- 104
				local cur = self.gongSway[i] or 0 -- 105
				if cur > 0 then -- 106
					self.gongSway[i] = math.max(0, cur - dt * 1.4) -- 107
				end -- 107
				i = i + 1 -- 98
			end -- 98
		end -- 98
	end -- 98
end -- 87
function EscortWorldRenderer.prototype.drawBackdropOverlay(self, bgDraw, bgGlow, backdropArt, p, cam, time) -- 114
	local key = p.room.key -- 122
	if not ____exports.isEscortWorldRoom(key) then -- 123
		return -- 124
	end -- 124
	local w = cam.viewW -- 126
	local h = cam.viewH -- 127
	local spec = TOWER_PROGRESSION[key] or TOWER_PROGRESSION.escort1 -- 128
	local dynamicDawn = spec.dawnWarmth -- 131
	if key == "escort5" and #p.enemies > 0 then -- 132
		local dead = 0 -- 133
		do -- 133
			local i = 0 -- 134
			while i < #p.enemies do -- 134
				if not p.enemies[i + 1].alive then -- 135
					dead = dead + 1 -- 136
				end -- 136
				i = i + 1 -- 134
			end -- 134
		end -- 134
		local progress = clamp01(dead / #p.enemies) -- 139
		dynamicDawn = 0.34 + progress * 0.62 -- 140
	end -- 140
	if key == "gatepath" or key == "escort1" then -- 143
		local emberPulse = 0.84 + 0.16 * math.sin(time * 2.4) -- 145
		fillRadialGlow( -- 146
			bgGlow, -- 146
			w * 0.14, -- 146
			h * 0.34, -- 146
			w * 0.34, -- 146
			h * 0.38, -- 146
			Color( -- 147
				168, -- 147
				62, -- 147
				34, -- 147
				math.floor(38 * emberPulse + 0.5) -- 147
			), -- 147
			Color(168, 62, 34, 0), -- 147
			16 -- 147
		) -- 147
	end -- 147
	if dynamicDawn > 0.1 then -- 150
		local dawnA = math.floor(62 * dynamicDawn + 0.5) -- 152
		fillVGradRect( -- 153
			bgGlow, -- 153
			0, -- 153
			h * 0.44, -- 153
			w, -- 153
			h * 0.32, -- 153
			Color( -- 154
				186, -- 154
				152, -- 154
				112, -- 154
				math.floor(dawnA * 0.85 + 0.5) -- 154
			), -- 154
			Color(74, 92, 124, 0) -- 155
		) -- 155
		fillRadialGlow( -- 156
			bgGlow, -- 156
			w * spec.screenXFrac, -- 156
			h * (spec.screenYFrac - 0.04), -- 156
			w * 0.34, -- 157
			h * 0.24, -- 157
			Color( -- 158
				232, -- 158
				186, -- 158
				126, -- 158
				math.floor(52 * dynamicDawn + 0.5) -- 158
			), -- 158
			Color(232, 186, 126, 0), -- 159
			18 -- 159
		) -- 159
	end -- 159
	self:drawDistantNorthTower( -- 163
		bgDraw, -- 163
		bgGlow, -- 163
		w, -- 163
		h, -- 163
		cam.x, -- 163
		time, -- 163
		spec, -- 163
		dynamicDawn, -- 163
		key == "escort2" -- 163
	) -- 163
	local mistShift = (time * 12 + cam.x * 0.16) % (w + 460) - 230 -- 166
	local mistCol = key == "escort3" and PALETTE.amberDim or PALETTE.jadeMist -- 167
	local mistOp = key == "escort4" and 0.24 or 0.17 -- 168
	backdropArt:tryPlace( -- 169
		"ink_mist_curve", -- 169
		"escort_mist_a", -- 169
		mistShift, -- 169
		h * 0.34, -- 169
		620, -- 169
		120, -- 169
		{ -- 169
			color = toColor(mistCol), -- 170
			opacity = mistOp, -- 170
			layer = 5 -- 170
		} -- 170
	) -- 170
	backdropArt:tryPlace( -- 172
		"ink_mist_curve", -- 172
		"escort_mist_b", -- 172
		(mistShift + w * 0.55) % (w + 460) - 230, -- 172
		h * 0.46, -- 172
		540, -- 172
		100, -- 172
		{ -- 172
			color = toColor(PALETTE.inkMist), -- 173
			opacity = mistOp * 0.85, -- 173
			layer = 5, -- 173
			facing = -1 -- 173
		} -- 173
	) -- 173
	if key == "escort1" then -- 177
		self:drawEscort1AlleySilhouettes(bgDraw, w, h, cam.x) -- 178
	elseif key == "escort2" then -- 179
		self:drawEscort2GranaryRafters( -- 180
			bgDraw, -- 180
			bgGlow, -- 180
			w, -- 180
			h, -- 180
			cam.x, -- 180
			time -- 180
		) -- 180
	elseif key == "escort3" then -- 181
		self:drawEscort3MountainShelterBg( -- 182
			bgDraw, -- 182
			bgGlow, -- 182
			w, -- 182
			h, -- 182
			cam.x, -- 182
			time -- 182
		) -- 182
	elseif key == "escort4" then -- 183
		self:drawEscort4CliffGorge( -- 184
			bgDraw, -- 184
			bgGlow, -- 184
			w, -- 184
			h, -- 184
			cam.x, -- 184
			time -- 184
		) -- 184
	elseif key == "escort5" then -- 185
		self:drawEscort5TowerApproachBg( -- 186
			bgDraw, -- 186
			bgGlow, -- 186
			w, -- 186
			h, -- 186
			cam.x, -- 186
			time, -- 186
			dynamicDawn -- 186
		) -- 186
	end -- 186
end -- 114
function EscortWorldRenderer.prototype.drawWorldSetpieces(self, fgDraw, fgGlow, worldArt, p, view, cam, time) -- 191
	local key = p.room.key -- 200
	if not ____exports.isEscortWorldRoom(key) then -- 201
		return -- 202
	end -- 202
	local ox = p.ox -- 204
	if key == "gatepath" then -- 206
		self:drawGatepathSetpieces( -- 207
			fgDraw, -- 207
			fgGlow, -- 207
			worldArt, -- 207
			p, -- 207
			view, -- 207
			cam, -- 207
			time, -- 207
			ox -- 207
		) -- 207
		return -- 208
	end -- 208
	if key == "escort1" then -- 210
		self:drawEscort1Setpieces( -- 211
			fgDraw, -- 211
			fgGlow, -- 211
			worldArt, -- 211
			p, -- 211
			cam, -- 211
			time, -- 211
			ox -- 211
		) -- 211
		return -- 212
	end -- 212
	if key == "escort2" then -- 214
		self:drawEscort2Setpieces( -- 215
			fgDraw, -- 215
			fgGlow, -- 215
			worldArt, -- 215
			p, -- 215
			cam, -- 215
			time, -- 215
			ox -- 215
		) -- 215
		return -- 216
	end -- 216
	if key == "escort3" then -- 218
		self:drawEscort3WorkbenchSanctuary( -- 219
			fgDraw, -- 219
			fgGlow, -- 219
			worldArt, -- 219
			p, -- 219
			view, -- 219
			cam, -- 219
			time, -- 219
			ox -- 219
		) -- 219
		return -- 220
	end -- 220
	if key == "escort4" then -- 222
		self:drawEscort4Setpieces( -- 223
			fgDraw, -- 223
			fgGlow, -- 223
			worldArt, -- 223
			p, -- 223
			cam, -- 223
			time, -- 223
			ox -- 223
		) -- 223
		return -- 224
	end -- 224
	if key == "escort5" then -- 226
		self:drawEscort5Setpieces( -- 227
			fgDraw, -- 227
			fgGlow, -- 227
			worldArt, -- 227
			p, -- 227
			cam, -- 227
			time, -- 227
			ox -- 227
		) -- 227
	end -- 227
end -- 191
function EscortWorldRenderer.prototype.drawForegroundFraming(self, fgDraw, _fgGlow, worldArt, p, cam, time) -- 232
	local key = p.room.key -- 240
	if not ____exports.isEscortWorldRoom(key) then -- 241
		return -- 242
	end -- 242
	local w = cam.viewW -- 244
	local h = cam.viewH -- 245
	local parallaxX = cam.x * 1.26 -- 246
	local sway = math.sin(time * 1.6) * 4 -- 247
	if key == "escort2" then -- 250
		fgDraw:drawRect( -- 252
			Rect(0, h - 34, w, 34), -- 252
			Color(10, 12, 16, 205) -- 252
		) -- 252
		fgDraw:drawSegment( -- 253
			Vec2(0, h - 34), -- 253
			Vec2(w, h - 34), -- 253
			1.6, -- 253
			Color(58, 46, 36, 155) -- 253
		) -- 253
		do -- 253
			local rx = -40 -- 254
			while rx < w + 80 do -- 254
				local bx = rx - parallaxX * 0.18 % 160 -- 255
				fgDraw:drawRect( -- 256
					Rect(bx, h - 46, 14, 46), -- 256
					Color(14, 12, 11, 190) -- 256
				) -- 256
				rx = rx + 160 -- 254
			end -- 254
		end -- 254
	elseif key == "escort3" or key == "escort4" or key == "escort5" then -- 258
		worldArt:tryPlace( -- 260
			"grass_low", -- 260
			"escort_fg_bush_l", -- 260
			78 + sway * 0.4, -- 260
			-4, -- 260
			190, -- 260
			48, -- 260
			{ -- 260
				color = Color(10, 14, 18, 255), -- 261
				opacity = 0.78, -- 261
				layer = 5200 -- 261
			} -- 261
		) -- 261
		worldArt:tryPlace( -- 263
			"grass_low", -- 263
			"escort_fg_bush_r", -- 263
			w - 82 - sway * 0.35, -- 263
			-4, -- 263
			198, -- 263
			52, -- 263
			{ -- 263
				color = Color(10, 14, 18, 255), -- 264
				opacity = 0.78, -- 264
				layer = 5200, -- 264
				facing = -1 -- 264
			} -- 264
		) -- 264
	end -- 264
	local stride = 260 -- 269
	local startSlot = math.floor((parallaxX - 200) / stride) -- 270
	do -- 270
		local s = startSlot -- 271
		while s <= startSlot + 6 do -- 271
			do -- 271
				local sx = s * stride - parallaxX + w * 0.5 -- 272
				if sx < -140 or sx > w + 140 then -- 273
					goto __continue43 -- 274
				end -- 274
				local hSeed = math.abs(math.sin(s * 12.9898) * 43758.5453) % 1 -- 276
				local rockH = 16 + hSeed * 18 -- 277
				local rockW = 46 + hSeed * 42 -- 278
				fgDraw:drawPolygon( -- 279
					{ -- 279
						Vec2(sx - rockW * 0.5, 0), -- 280
						Vec2(sx + rockW * 0.5, 0), -- 281
						Vec2(sx + rockW * 0.25 + sway * 0.2, rockH), -- 282
						Vec2(sx - rockW * 0.3 + sway * 0.2, rockH * 0.82) -- 283
					}, -- 283
					Color(8, 10, 14, 196) -- 284
				) -- 284
			end -- 284
			::__continue43:: -- 284
			s = s + 1 -- 271
		end -- 271
	end -- 271
end -- 232
function EscortWorldRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, camX, time, spec, dawnWarmth, behindWindow) -- 290
	local s = spec.scale -- 301
	local tx = w * spec.screenXFrac - camX * 0.045 -- 302
	local ty = h * spec.screenYFrac -- 303
	local pulse = 0.86 + 0.14 * math.sin(time * 2.5) -- 304
	local alphaMul = behindWindow and 0.62 or 1 -- 305
	local ridgeW = 190 * s + 95 -- 308
	local ridgeH = 44 * s + 22 -- 309
	local ridgeCol = Color( -- 310
		math.floor(20 + dawnWarmth * 16 + 0.5), -- 311
		math.floor(26 + dawnWarmth * 14 + 0.5), -- 312
		math.floor(38 + dawnWarmth * 8 + 0.5), -- 313
		math.floor(188 * alphaMul + 0.5) -- 314
	) -- 314
	bgDraw:drawPolygon( -- 316
		{ -- 316
			Vec2(tx - ridgeW, ty - ridgeH), -- 317
			Vec2(tx + ridgeW * 0.72, ty - ridgeH), -- 318
			Vec2(tx + ridgeW * 0.16, ty + 6 * s), -- 319
			Vec2(tx - ridgeW * 0.32, ty + 2 * s) -- 320
		}, -- 320
		ridgeCol -- 321
	) -- 321
	local baseW = 44 * s -- 324
	local topW = 34 * s -- 325
	local bodyH = 62 * s -- 326
	local towerCol = Color( -- 327
		math.floor(24 + dawnWarmth * 14 + 0.5), -- 328
		math.floor(30 + dawnWarmth * 12 + 0.5), -- 329
		math.floor(42 + dawnWarmth * 8 + 0.5), -- 330
		math.floor(225 * alphaMul + 0.5) -- 331
	) -- 331
	local rimCol = Color( -- 333
		138, -- 333
		148, -- 333
		166, -- 333
		math.floor(68 * alphaMul + 0.5) -- 333
	) -- 333
	bgDraw:drawPolygon( -- 334
		{ -- 334
			Vec2(tx - baseW * 0.5, ty - 4 * s), -- 335
			Vec2(tx + baseW * 0.5, ty - 4 * s), -- 336
			Vec2(tx + topW * 0.5, ty + bodyH), -- 337
			Vec2(tx - topW * 0.5, ty + bodyH) -- 338
		}, -- 338
		towerCol, -- 339
		0.8, -- 339
		rimCol -- 339
	) -- 339
	local pavH = 18 * s -- 342
	local eaveY = ty + bodyH + pavH -- 343
	local eaveW = 54 * s -- 344
	bgDraw:drawRect( -- 345
		Rect(tx - topW * 0.38, ty + bodyH, 3 * s, pavH), -- 345
		towerCol -- 345
	) -- 345
	bgDraw:drawRect( -- 346
		Rect(tx + topW * 0.38 - 3 * s, ty + bodyH, 3 * s, pavH), -- 346
		towerCol -- 346
	) -- 346
	bgDraw:drawPolygon( -- 347
		{ -- 347
			Vec2(tx - eaveW * 0.54, eaveY - 2 * s), -- 348
			Vec2(tx + eaveW * 0.54, eaveY - 2 * s), -- 349
			Vec2(tx + eaveW * 0.24, eaveY + 13 * s), -- 350
			Vec2(tx - eaveW * 0.24, eaveY + 13 * s) -- 351
		}, -- 351
		Color( -- 352
			18, -- 352
			22, -- 352
			32, -- 352
			math.floor(238 * alphaMul + 0.5) -- 352
		), -- 352
		0.8, -- 352
		rimCol -- 352
	) -- 352
	local lampX = tx - topW * 0.14 -- 355
	local lampY = ty + bodyH * 0.64 -- 356
	local glowR = spec.beaconR * pulse -- 357
	fillRadialGlow( -- 358
		bgGlow, -- 358
		lampX, -- 358
		lampY, -- 358
		glowR * 1.35, -- 358
		glowR, -- 358
		Color( -- 359
			255, -- 359
			206, -- 359
			122, -- 359
			math.floor(92 * pulse * alphaMul + 0.5) -- 359
		), -- 359
		Color(255, 178, 86, 0), -- 360
		16 -- 360
	) -- 360
	fillRadialGlow( -- 361
		bgGlow, -- 361
		lampX, -- 361
		lampY, -- 361
		glowR * 0.48, -- 361
		glowR * 0.42, -- 361
		Color( -- 362
			255, -- 362
			238, -- 362
			184, -- 362
			math.floor(176 * pulse * alphaMul + 0.5) -- 362
		), -- 362
		Color(255, 204, 118, 0), -- 363
		12 -- 363
	) -- 363
	bgGlow:drawDot( -- 364
		Vec2(lampX, lampY), -- 364
		math.max(1.8, 3.6 * s), -- 364
		Color( -- 364
			255, -- 364
			246, -- 364
			212, -- 364
			math.floor(248 * alphaMul + 0.5) -- 364
		) -- 364
	) -- 364
end -- 290
function EscortWorldRenderer.prototype.drawEscort1AlleySilhouettes(self, bgDraw, w, h, camX) -- 369
	local shift = camX * 0.38 -- 370
	local houses = {{x = 140, bw = 165, bh = 165, roof = 36}, {x = 430, bw = 190, bh = 195, roof = 42}, {x = 760, bw = 145, bh = 150, roof = 30}, {x = 1080, bw = 210, bh = 185, roof = 40}} -- 371
	for ____, hs in ipairs(houses) do -- 377
		local sx = ((hs.x - shift) % (w + 340) + (w + 340)) % (w + 340) - 170 -- 378
		local base = h * 0.25 -- 379
		bgDraw:drawRect( -- 380
			Rect(sx, base, hs.bw, hs.bh), -- 380
			Color(16, 20, 29, 175) -- 380
		) -- 380
		bgDraw:drawPolygon( -- 381
			{ -- 381
				Vec2(sx - 16, base + hs.bh), -- 382
				Vec2(sx + hs.bw + 16, base + hs.bh), -- 383
				Vec2(sx + hs.bw * 0.78, base + hs.bh + hs.roof), -- 384
				Vec2(sx + hs.bw * 0.22, base + hs.bh + hs.roof) -- 385
			}, -- 385
			Color(12, 15, 22, 195) -- 386
		) -- 386
	end -- 386
end -- 369
function EscortWorldRenderer.prototype.drawEscort2GranaryRafters(self, bgDraw, bgGlow, w, h, camX, time) -- 390
	local shift = camX * 0.42 -- 398
	bgDraw:drawRect( -- 400
		Rect(0, h * 0.8, w, h * 0.2), -- 400
		Color(12, 14, 20, 192) -- 400
	) -- 400
	local span = 290 -- 401
	local first = math.floor((shift - 180) / span) -- 402
	do -- 402
		local k = first -- 403
		while k <= first + 6 do -- 403
			local bx = k * span - shift -- 404
			bgDraw:drawRect( -- 406
				Rect(bx - 9, h * 0.2, 18, h * 0.62), -- 406
				Color(22, 19, 17, 165) -- 406
			) -- 406
			bgDraw:drawSegment( -- 408
				Vec2(bx, h * 0.82), -- 408
				Vec2(bx + span * 0.5, h * 0.96), -- 408
				7, -- 408
				Color(26, 21, 18, 185) -- 408
			) -- 408
			bgDraw:drawSegment( -- 409
				Vec2(bx + span, h * 0.82), -- 409
				Vec2(bx + span * 0.5, h * 0.96), -- 409
				7, -- 409
				Color(26, 21, 18, 185) -- 409
			) -- 409
			if math.abs(k) % 2 == 0 then -- 411
				local topX = bx + span * 0.44 -- 412
				local pulse = 0.86 + 0.14 * math.sin(time * 1.1 + k) -- 413
				local midA = math.floor(30 * pulse + 0.5) -- 414
				local topA = math.floor(14 * pulse + 0.5) -- 415
				fillGradQuad( -- 416
					bgGlow, -- 417
					topX - 20, -- 418
					h + 10, -- 418
					Color(168, 194, 224, topA), -- 418
					topX + 36, -- 419
					h + 10, -- 419
					Color(168, 194, 224, topA), -- 419
					topX + 94, -- 420
					h * 0.48, -- 420
					Color(176, 202, 232, midA), -- 420
					topX + 8, -- 421
					h * 0.48, -- 421
					Color(176, 202, 232, midA) -- 421
				) -- 421
				fillGradQuad( -- 423
					bgGlow, -- 424
					topX + 8, -- 425
					h * 0.48, -- 425
					Color(176, 202, 232, midA), -- 425
					topX + 94, -- 426
					h * 0.48, -- 426
					Color(176, 202, 232, midA), -- 426
					topX + 136, -- 427
					h * 0.14, -- 427
					Color(168, 194, 224, 0), -- 427
					topX + 30, -- 428
					h * 0.14, -- 428
					Color(168, 194, 224, 0) -- 428
				) -- 428
				do -- 428
					local d = 0 -- 431
					while d < 4 do -- 431
						local phase = (time * 0.18 + d * 0.27 + k * 0.31) % 1 -- 432
						local dx = topX + 12 + phase * 76 + math.sin(time * 1.4 + d) * 8 -- 433
						local dy = h * (0.9 - phase * 0.68) -- 434
						bgGlow:drawDot( -- 435
							Vec2(dx, dy), -- 435
							1.6, -- 435
							Color( -- 435
								214, -- 435
								222, -- 435
								232, -- 435
								math.floor(62 * math.sin(phase * math.pi) + 0.5) -- 435
							) -- 435
						) -- 435
						d = d + 1 -- 431
					end -- 431
				end -- 431
			end -- 431
			k = k + 1 -- 403
		end -- 403
	end -- 403
end -- 390
function EscortWorldRenderer.prototype.drawEscort3MountainShelterBg(self, bgDraw, bgGlow, w, h, camX, time) -- 441
	local cliffX = 120 - camX * 0.28 -- 450
	bgDraw:drawPolygon( -- 451
		{ -- 451
			Vec2(cliffX - 240, h * 0.18), -- 452
			Vec2(cliffX + 260, h * 0.18), -- 453
			Vec2(cliffX + 165, h * 0.68), -- 454
			Vec2(cliffX - 180, h * 0.86) -- 455
		}, -- 455
		Color(14, 18, 25, 165) -- 456
	) -- 456
	local warmPulse = 0.9 + 0.1 * math.sin(time * 2.1) -- 458
	fillRadialGlow( -- 459
		bgGlow, -- 459
		w * 0.5, -- 459
		h * 0.36, -- 459
		w * 0.26, -- 459
		h * 0.26, -- 459
		Color( -- 460
			224, -- 460
			164, -- 460
			88, -- 460
			math.floor(32 * warmPulse + 0.5) -- 460
		), -- 460
		Color(224, 164, 88, 0), -- 460
		16 -- 460
	) -- 460
end -- 441
function EscortWorldRenderer.prototype.drawEscort4CliffGorge(self, bgDraw, bgGlow, w, h, camX, time) -- 463
	local shift = camX * 0.32 -- 472
	do -- 472
		local i = 0 -- 473
		while i < 4 do -- 473
			local px = ((i * 380 - shift) % (w + 420) + (w + 420)) % (w + 420) - 210 -- 474
			bgDraw:drawPolygon( -- 475
				{ -- 475
					Vec2(px - 120, h * 0.2), -- 476
					Vec2(px + 145, h * 0.2), -- 477
					Vec2(px + 48, h * (0.58 + i % 2 * 0.12)), -- 478
					Vec2(px - 58, h * (0.5 + i % 2 * 0.08)) -- 479
				}, -- 479
				Color(16, 22, 33, 152) -- 480
			) -- 480
			i = i + 1 -- 473
		end -- 473
	end -- 473
	local cloudX = time * 24 % (w + 400) - 200 -- 483
	bgGlow:drawPolygon( -- 484
		{ -- 484
			Vec2(cloudX, h * 0.78), -- 485
			Vec2(cloudX + 240, h * 0.82), -- 486
			Vec2(cloudX + 210, h * 0.87), -- 487
			Vec2(cloudX - 20, h * 0.83) -- 488
		}, -- 488
		Color(142, 164, 192, 24) -- 489
	) -- 489
end -- 463
function EscortWorldRenderer.prototype.drawEscort5TowerApproachBg(self, bgDraw, bgGlow, w, h, camX, time, dawnWarmth) -- 492
	local glowPulse = 0.88 + 0.12 * math.sin(time * 1.8) -- 502
	fillRadialGlow( -- 503
		bgGlow, -- 503
		w * 0.78, -- 503
		h * 0.48, -- 503
		w * 0.42, -- 503
		h * 0.3, -- 503
		Color( -- 504
			228, -- 504
			184, -- 504
			132, -- 504
			math.floor(44 * dawnWarmth * glowPulse + 0.5) -- 504
		), -- 504
		Color(228, 184, 132, 0), -- 505
		18 -- 505
	) -- 505
	local shift = camX * 0.3 -- 507
	bgDraw:drawPolygon( -- 508
		{ -- 508
			Vec2(0, h * 0.2), -- 509
			Vec2(w, h * 0.2), -- 510
			Vec2(w, h * 0.34), -- 511
			Vec2(w * 0.55 - shift % 120 * 0.2, h * 0.29), -- 512
			Vec2(0, h * 0.36) -- 513
		}, -- 513
		Color(18, 22, 32, 140) -- 514
	) -- 514
end -- 492
function EscortWorldRenderer.prototype.drawGatepathSetpieces(self, fgDraw, fgGlow, worldArt, p, view, cam, time, ox) -- 519
	local groundY = cam:sy(0) -- 529
	worldArt:tryPlace( -- 531
		"sh_stele_banner", -- 531
		"gp_banner_start", -- 531
		cam:sx(ox + 96), -- 531
		groundY, -- 531
		cam:len(68), -- 531
		cam:len(74), -- 531
		{layer = 1, opacity = 0.92} -- 531
	) -- 531
	worldArt:tryPlace( -- 534
		"sh_stele_banner", -- 534
		"gp_stele_mid", -- 534
		cam:sx(ox + 520), -- 534
		groundY, -- 534
		cam:len(54), -- 534
		cam:len(60), -- 534
		{layer = 1, opacity = 0.86, facing = -1} -- 534
	) -- 534
	local stepTopY = cam:sy(48) -- 538
	local lampX = cam:sx(ox + 912) -- 539
	local poleH = cam:len(58) -- 540
	fgDraw:drawSegment( -- 541
		Vec2(lampX, stepTopY), -- 541
		Vec2(lampX, stepTopY + poleH), -- 541
		math.max( -- 541
			1.8, -- 541
			cam:len(2.4) -- 541
		), -- 541
		Color(74, 54, 38, 240) -- 541
	) -- 541
	fgDraw:drawSegment( -- 542
		Vec2(lampX, stepTopY + poleH), -- 542
		Vec2( -- 542
			lampX - cam:len(14), -- 542
			stepTopY + poleH -- 542
		), -- 542
		math.max( -- 542
			1.5, -- 542
			cam:len(2) -- 542
		), -- 542
		Color(74, 54, 38, 240) -- 542
	) -- 542
	worldArt:tryPlace( -- 543
		"prop_lantern", -- 543
		"gp_top_lantern", -- 543
		lampX - cam:len(14), -- 543
		stepTopY + poleH - cam:len(14), -- 543
		cam:len(18), -- 543
		cam:len(22), -- 543
		{layer = 4} -- 543
	) -- 543
	local flame = 0.88 + 0.12 * math.sin(time * 3.1) -- 544
	fillRadialGlow( -- 545
		fgGlow, -- 545
		lampX - cam:len(14), -- 545
		stepTopY + poleH - cam:len(14), -- 545
		cam:len(54), -- 545
		cam:len(48), -- 545
		Color( -- 546
			246, -- 546
			192, -- 546
			114, -- 546
			math.floor(72 * flame + 0.5) -- 546
		), -- 546
		Color(246, 192, 114, 0), -- 546
		16 -- 546
	) -- 546
	if p.phase == "gatepath-start" and p.partner.alive then -- 549
		local sx1 = cam:sx(p.player.x) -- 550
		local sx2 = cam:sx(p.partner.x) -- 551
		fgDraw:drawPolygon( -- 552
			{ -- 552
				Vec2( -- 553
					sx1 - cam:len(10), -- 553
					groundY + 1 -- 553
				), -- 553
				Vec2( -- 554
					sx1 + cam:len(10), -- 554
					groundY + 1 -- 554
				), -- 554
				Vec2( -- 555
					sx1 - cam:len(24), -- 555
					groundY - cam:len(10) -- 555
				), -- 555
				Vec2( -- 556
					sx1 - cam:len(40), -- 556
					groundY - cam:len(10) -- 556
				) -- 556
			}, -- 556
			Color(8, 10, 16, 86) -- 557
		) -- 557
		fgDraw:drawPolygon( -- 558
			{ -- 558
				Vec2( -- 559
					sx2 - cam:len(7), -- 559
					groundY + 1 -- 559
				), -- 559
				Vec2( -- 560
					sx2 + cam:len(7), -- 560
					groundY + 1 -- 560
				), -- 560
				Vec2( -- 561
					sx2 - cam:len(15), -- 561
					groundY - cam:len(7) -- 561
				), -- 561
				Vec2( -- 562
					sx2 - cam:len(26), -- 562
					groundY - cam:len(7) -- 562
				) -- 562
			}, -- 562
			Color(8, 10, 16, 78) -- 563
		) -- 563
	end -- 563
	if self.carryBloomT > 0 or view.backCarry.mounting then -- 567
		local k = self.carryBloomT > 0 and clamp01(self.carryBloomT / 1.15) or 0.72 -- 568
		local bx = cam:sx(p.player.x) -- 569
		local by = cam:sy(p.player.y + 42) -- 570
		fillRadialGlow( -- 571
			fgGlow, -- 571
			bx, -- 571
			by, -- 571
			cam:len(96), -- 571
			cam:len(72), -- 571
			Color( -- 572
				244, -- 572
				206, -- 572
				142, -- 572
				math.floor(62 * k + 0.5) -- 572
			), -- 572
			Color(244, 206, 142, 0), -- 572
			18 -- 572
		) -- 572
	end -- 572
end -- 519
function EscortWorldRenderer.prototype.drawEscort1Setpieces(self, fgDraw, fgGlow, worldArt, _p, cam, time, ox) -- 576
	local backDepth = LANE_DEPTH.upper + 16 -- 585
	local backY = cam:sy(0, backDepth) -- 586
	local backLayer = depthOrder(backDepth, -2) -- 587
	worldArt:tryPlace( -- 589
		"sh_stele_banner", -- 589
		"e1_banner_a", -- 589
		cam:sx(ox + 150), -- 589
		backY, -- 589
		cam:len(68), -- 589
		cam:len(76), -- 589
		{layer = backLayer, opacity = 0.9} -- 589
	) -- 589
	worldArt:tryPlace( -- 592
		"sh_stele_banner", -- 592
		"e1_banner_b", -- 592
		cam:sx(ox + 1245), -- 592
		backY, -- 592
		cam:len(64), -- 592
		cam:len(70), -- 592
		{layer = backLayer, opacity = 0.88, facing = -1} -- 592
	) -- 592
	local emberSpots = {285, 860} -- 596
	do -- 596
		local i = 0 -- 597
		while i < #emberSpots do -- 597
			local bx = cam:sx(ox + emberSpots[i + 1]) -- 598
			local pulse = 0.82 + 0.18 * math.sin(time * 4.2 + i * 1.9) -- 599
			fgDraw:drawPolygon( -- 600
				{ -- 600
					Vec2( -- 601
						bx - cam:len(12), -- 601
						backY + cam:len(14) -- 601
					), -- 601
					Vec2( -- 602
						bx + cam:len(12), -- 602
						backY + cam:len(14) -- 602
					), -- 602
					Vec2( -- 603
						bx + cam:len(8), -- 603
						backY + cam:len(4) -- 603
					), -- 603
					Vec2( -- 604
						bx - cam:len(8), -- 604
						backY + cam:len(4) -- 604
					) -- 604
				}, -- 604
				Color(38, 34, 34, 240), -- 605
				1, -- 605
				Color(88, 72, 62, 180) -- 605
			) -- 605
			fgDraw:drawSegment( -- 606
				Vec2( -- 606
					bx - cam:len(9), -- 606
					backY -- 606
				), -- 606
				Vec2( -- 606
					bx - cam:len(6), -- 606
					backY + cam:len(6) -- 606
				), -- 606
				2, -- 606
				Color(34, 30, 30, 235) -- 606
			) -- 606
			fgDraw:drawSegment( -- 607
				Vec2( -- 607
					bx + cam:len(9), -- 607
					backY -- 607
				), -- 607
				Vec2( -- 607
					bx + cam:len(6), -- 607
					backY + cam:len(6) -- 607
				), -- 607
				2, -- 607
				Color(34, 30, 30, 235) -- 607
			) -- 607
			fgGlow:drawEllipse( -- 608
				Vec2( -- 608
					bx, -- 608
					backY + cam:len(14) -- 608
				), -- 608
				cam:len(9), -- 608
				cam:len(3.5), -- 608
				Color( -- 608
					236, -- 608
					114, -- 608
					48, -- 608
					math.floor(185 * pulse + 0.5) -- 608
				) -- 608
			) -- 608
			fillRadialGlow( -- 609
				fgGlow, -- 609
				bx, -- 609
				backY + cam:len(18), -- 609
				cam:len(48), -- 609
				cam:len(36), -- 609
				Color( -- 610
					226, -- 610
					116, -- 610
					52, -- 610
					math.floor(62 * pulse + 0.5) -- 610
				), -- 610
				Color(226, 116, 52, 0), -- 610
				14 -- 610
			) -- 610
			i = i + 1 -- 597
		end -- 597
	end -- 597
end -- 576
function EscortWorldRenderer.prototype.drawEscort2Setpieces(self, fgDraw, fgGlow, worldArt, p, cam, time, ox) -- 614
	local backDepth = LANE_DEPTH.upper + 16 -- 623
	local backY = cam:sy(0, backDepth) -- 624
	local backLayer = depthOrder(backDepth, -2) -- 625
	local sackSpots = {195, 480, 1020, 1310} -- 627
	do -- 627
		local i = 0 -- 628
		while i < #sackSpots do -- 628
			local sx = cam:sx(ox + sackSpots[i + 1]) -- 629
			worldArt:tryPlace( -- 630
				"sh_grain_sacks", -- 630
				"e2_bg_sack_" .. tostring(i), -- 630
				sx, -- 630
				backY, -- 630
				cam:len(72), -- 630
				cam:len(44), -- 630
				{ -- 630
					layer = backLayer, -- 631
					opacity = 0.78, -- 632
					facing = i % 2 == 0 and 1 or -1, -- 633
					color = Color(172, 168, 162, 255) -- 634
				} -- 634
			) -- 634
			i = i + 1 -- 628
		end -- 628
	end -- 628
	local beamY = cam:sy(64, -24) -- 638
	local drapeX = cam:sx(ox + 440) -- 639
	local sway = math.sin(time * 1.9) * 3 -- 640
	fgDraw:drawPolygon( -- 641
		{ -- 641
			Vec2( -- 642
				drapeX - cam:len(22), -- 642
				beamY -- 642
			), -- 642
			Vec2( -- 643
				drapeX + cam:len(22), -- 643
				beamY -- 643
			), -- 643
			Vec2( -- 644
				drapeX + cam:len(18) + sway, -- 644
				beamY - cam:len(24) -- 644
			), -- 644
			Vec2( -- 645
				drapeX - cam:len(14) + sway * 0.7, -- 645
				beamY - cam:len(19) -- 645
			) -- 645
		}, -- 645
		Color(72, 58, 46, 160) -- 646
	) -- 646
	for ____, pk in ipairs(p.pickups) do -- 649
		do -- 649
			if pk.id == "" or p.run.taken[pk.id] then -- 650
				goto __continue69 -- 651
			end -- 651
			local px = cam:sx(pk.x) -- 653
			local py = cam:sy(pk.y + 10, pk.depth or 0) -- 654
			local pulse = 0.78 + 0.22 * math.sin(time * 3 + pk.x * 0.02) -- 655
			local col = pk.kind == "bell" and Color( -- 656
				238, -- 656
				204, -- 656
				136, -- 656
				math.floor(78 * pulse + 0.5) -- 656
			) or Color( -- 656
				224, -- 656
				168, -- 656
				92, -- 656
				math.floor(72 * pulse + 0.5) -- 656
			) -- 656
			fillRadialGlow( -- 657
				fgGlow, -- 657
				px, -- 657
				py, -- 657
				cam:len(22), -- 657
				cam:len(18), -- 657
				col, -- 657
				Color(224, 168, 92, 0), -- 657
				12 -- 657
			) -- 657
		end -- 657
		::__continue69:: -- 657
	end -- 657
end -- 614
function EscortWorldRenderer.prototype.drawEscort3WorkbenchSanctuary(self, fgDraw, fgGlow, worldArt, p, view, cam, time, ox) -- 661
	local pulse = 0.88 + 0.12 * math.sin(time * 2.6) -- 671
	local benchCx = cam:sx(ox + 620) -- 672
	local benchDepth = LANE_DEPTH.middle + 10 -- 673
	local benchBaseY = cam:sy(0, benchDepth) -- 674
	local benchLayer = depthOrder(benchDepth, 2) -- 675
	fillRadialGlow( -- 678
		fgGlow, -- 678
		benchCx, -- 678
		benchBaseY + cam:len(42), -- 678
		cam:len(168), -- 678
		cam:len(112), -- 678
		Color( -- 679
			246, -- 679
			184, -- 679
			96, -- 679
			math.floor(76 * pulse + 0.5) -- 679
		), -- 679
		Color(246, 168, 74, 0), -- 679
		20 -- 679
	) -- 679
	fillRadialGlow( -- 680
		fgGlow, -- 680
		benchCx - cam:len(22), -- 680
		benchBaseY + cam:len(68), -- 680
		cam:len(58), -- 680
		cam:len(48), -- 680
		Color( -- 681
			255, -- 681
			224, -- 681
			152, -- 681
			math.floor(115 * pulse + 0.5) -- 681
		), -- 681
		Color(255, 198, 108, 0), -- 681
		14 -- 681
	) -- 681
	worldArt:tryPlace( -- 684
		"sh_craft_workbench", -- 684
		"e3_sanctuary_bench", -- 684
		benchCx, -- 684
		benchBaseY - cam:len(4), -- 684
		cam:len(142), -- 684
		cam:len(112), -- 684
		{layer = benchLayer} -- 684
	) -- 684
	local matX = cam:sx(ox + 516) -- 689
	local matDepth = LANE_DEPTH.middle + 4 -- 690
	local matY = cam:sy(0, matDepth) -- 691
	worldArt:tryPlace( -- 692
		"sh_straw_mat", -- 692
		"e3_xiaoman_mat", -- 692
		matX, -- 692
		matY - cam:len(2), -- 692
		cam:len(66), -- 692
		cam:len(28), -- 692
		{layer = depthOrder(matDepth, 0)} -- 692
	) -- 692
	if view.backCarry.atBench or view.craftBench.active then -- 696
		fillRadialGlow( -- 697
			fgGlow, -- 697
			matX, -- 697
			matY + cam:len(22), -- 697
			cam:len(42), -- 697
			cam:len(34), -- 697
			Color( -- 698
				252, -- 698
				212, -- 698
				138, -- 698
				math.floor(68 * pulse + 0.5) -- 698
			), -- 698
			Color(252, 212, 138, 0), -- 698
			14 -- 698
		) -- 698
	end -- 698
	worldArt:tryPlace( -- 702
		"sh_stele_banner", -- 702
		"e3_entry_stele", -- 702
		cam:sx(ox + 235), -- 702
		cam:sy(0, LANE_DEPTH.upper + 16), -- 702
		cam:len(58), -- 702
		cam:len(66), -- 702
		{ -- 702
			layer = depthOrder(LANE_DEPTH.upper + 16, -1), -- 703
			opacity = 0.86 -- 703
		} -- 703
	) -- 703
	do -- 703
		local i = 0 -- 707
		while i < #p.enemies do -- 707
			do -- 707
				local en = p.enemies[i + 1] -- 708
				if en.kind ~= "target" then -- 709
					goto __continue75 -- 710
				end -- 710
				local tx = cam:sx(en.x) -- 712
				local ty = cam:sy(en.y, en.depth or 0) -- 713
				local swayK = self.gongSway[i] or 0 -- 714
				local swayAng = math.sin(time * 24 + i) * 7.5 * swayK -- 715
				worldArt:tryPlace( -- 716
					"sh_gong_target", -- 716
					"e3_gong_target_" .. tostring(i), -- 716
					tx, -- 716
					ty - cam:len(2), -- 716
					cam:len(68), -- 716
					cam:len(62), -- 716
					{ -- 716
						layer = depthOrder(en.depth or 0, 2), -- 717
						angle = swayAng, -- 718
						opacity = en.alive and 1 or 0.55 -- 719
					} -- 719
				) -- 719
				if swayK > 0.05 then -- 721
					local ringR = cam:len(18 + (1 - swayK) * 44) -- 722
					fgGlow:drawRing( -- 723
						Vec2( -- 723
							tx, -- 723
							ty + cam:len(32) -- 723
						), -- 723
						math.max(1, ringR - 1.5), -- 723
						ringR, -- 723
						Color(0, 0, 0, 0), -- 724
						1.4, -- 724
						toColor( -- 724
							PALETTE.amber, -- 724
							math.floor(190 * swayK + 0.5) -- 724
						) -- 724
					) -- 724
				end -- 724
			end -- 724
			::__continue75:: -- 724
			i = i + 1 -- 707
		end -- 707
	end -- 707
end -- 661
function EscortWorldRenderer.prototype.drawEscort4Setpieces(self, fgDraw, fgGlow, worldArt, p, cam, time, ox) -- 729
	local backDepth = LANE_DEPTH.upper + 16 -- 738
	local backY = cam:sy(0, backDepth) -- 739
	local backLayer = depthOrder(backDepth, -2) -- 740
	worldArt:tryPlace( -- 742
		"sh_stele_banner", -- 742
		"e4_stele_a", -- 742
		cam:sx(ox + 210), -- 742
		backY, -- 742
		cam:len(58), -- 742
		cam:len(66), -- 742
		{layer = backLayer, opacity = 0.9} -- 742
	) -- 742
	worldArt:tryPlace( -- 745
		"sh_stele_banner", -- 745
		"e4_stele_b", -- 745
		cam:sx(ox + 990), -- 745
		backY, -- 745
		cam:len(56), -- 745
		cam:len(64), -- 745
		{layer = backLayer, opacity = 0.88, facing = -1} -- 745
	) -- 745
	local pineXs = {310, 740, 1210} -- 749
	do -- 749
		local i = 0 -- 750
		while i < #pineXs do -- 750
			worldArt:tryPlace( -- 751
				"pine", -- 751
				"e4_cliff_pine_" .. tostring(i), -- 751
				cam:sx(ox + pineXs[i + 1]), -- 751
				backY - cam:len(4), -- 751
				cam:len(112), -- 751
				cam:len(98), -- 751
				{ -- 751
					layer = backLayer - 1, -- 752
					opacity = 0.72, -- 752
					facing = i % 2 == 0 and 1 or -1, -- 752
					color = Color(138, 152, 168, 255) -- 752
				} -- 752
			) -- 752
			i = i + 1 -- 750
		end -- 750
	end -- 750
	do -- 750
		local i = 0 -- 756
		while i < #p.enemies do -- 756
			do -- 756
				local en = p.enemies[i + 1] -- 757
				if not en.alive or en.kind ~= "gunner" then -- 758
					goto __continue82 -- 759
				end -- 759
				local gx = cam:sx(en.x - 10) -- 761
				local gy = cam:sy(en.y + en.h * 0.62, en.depth or 0) -- 762
				local ember = 0.72 + 0.28 * math.sin(time * 7.5 + i * 2.1) -- 763
				fgGlow:drawDot( -- 764
					Vec2(gx, gy), -- 764
					2.3, -- 764
					Color( -- 764
						255, -- 764
						134, -- 764
						62, -- 764
						math.floor(215 * ember + 0.5) -- 764
					) -- 764
				) -- 764
				fillRadialGlow( -- 765
					fgGlow, -- 765
					gx, -- 765
					gy, -- 765
					14, -- 765
					14, -- 765
					Color( -- 765
						242, -- 765
						108, -- 765
						46, -- 765
						math.floor(64 * ember + 0.5) -- 765
					), -- 765
					Color(242, 108, 46, 0), -- 765
					10 -- 765
				) -- 765
			end -- 765
			::__continue82:: -- 765
			i = i + 1 -- 756
		end -- 756
	end -- 756
	fgDraw:drawSegment( -- 768
		Vec2( -- 768
			cam:sx(ox + 500), -- 768
			backY + cam:len(4) -- 768
		), -- 768
		Vec2( -- 768
			cam:sx(ox + 900), -- 768
			backY + cam:len(4) -- 768
		), -- 768
		1, -- 768
		Color(110, 124, 142, 48) -- 768
	) -- 768
end -- 729
function EscortWorldRenderer.prototype.drawEscort5Setpieces(self, fgDraw, fgGlow, worldArt, _p, cam, time, ox) -- 771
	local backDepth = LANE_DEPTH.upper + 16 -- 780
	local backY = cam:sy(0, backDepth) -- 781
	local backLayer = depthOrder(backDepth, -2) -- 782
	worldArt:tryPlace( -- 784
		"sh_stele_banner", -- 784
		"e5_stele_a", -- 784
		cam:sx(ox + 215), -- 784
		backY, -- 784
		cam:len(62), -- 784
		cam:len(70), -- 784
		{layer = backLayer, opacity = 0.92} -- 784
	) -- 784
	worldArt:tryPlace( -- 787
		"pine", -- 787
		"e5_pine_a", -- 787
		cam:sx(ox + 640), -- 787
		backY - cam:len(4), -- 787
		cam:len(118), -- 787
		cam:len(102), -- 787
		{ -- 787
			layer = backLayer - 1, -- 788
			opacity = 0.78, -- 788
			color = Color(156, 168, 182, 255) -- 788
		} -- 788
	) -- 788
	local lx = cam:sx(ox + 1315) -- 791
	local poleTop = backY + cam:len(68) -- 792
	local flame = 0.88 + 0.12 * math.sin(time * 2.9) -- 793
	fgDraw:drawSegment( -- 794
		Vec2(lx, backY), -- 794
		Vec2(lx, poleTop), -- 794
		math.max( -- 794
			1.8, -- 794
			cam:len(2.4) -- 794
		), -- 794
		Color(76, 56, 40, 240) -- 794
	) -- 794
	fgDraw:drawSegment( -- 795
		Vec2(lx, poleTop), -- 795
		Vec2( -- 795
			lx - cam:len(15), -- 795
			poleTop -- 795
		), -- 795
		math.max( -- 795
			1.6, -- 795
			cam:len(2) -- 795
		), -- 795
		Color(76, 56, 40, 240) -- 795
	) -- 795
	worldArt:tryPlace( -- 796
		"prop_lantern", -- 796
		"e5_approach_lamp", -- 796
		lx - cam:len(15), -- 796
		poleTop - cam:len(14), -- 796
		cam:len(20), -- 796
		cam:len(24), -- 796
		{layer = backLayer + 2} -- 796
	) -- 796
	fillRadialGlow( -- 799
		fgGlow, -- 799
		lx - cam:len(15), -- 799
		poleTop - cam:len(14), -- 799
		cam:len(74), -- 799
		cam:len(62), -- 799
		Color( -- 800
			255, -- 800
			206, -- 800
			128, -- 800
			math.floor(92 * flame + 0.5) -- 800
		), -- 800
		Color(255, 182, 88, 0), -- 800
		16 -- 800
	) -- 800
end -- 771
return ____exports -- 771
