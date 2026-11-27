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
function EscortWorldRenderer.prototype.drawBackdropOverlay(self, bgDraw, bgGlow, backdropArt, p, cam, time, towerDraw) -- 114
	if towerDraw == nil then -- 121
		towerDraw = bgDraw -- 121
	end -- 121
	local key = p.room.key -- 123
	if not ____exports.isEscortWorldRoom(key) then -- 124
		return -- 125
	end -- 125
	local w = cam.viewW -- 127
	local h = cam.viewH -- 128
	local spec = TOWER_PROGRESSION[key] or TOWER_PROGRESSION.escort1 -- 129
	local dynamicDawn = spec.dawnWarmth -- 132
	if key == "escort5" and #p.enemies > 0 then -- 133
		local dead = 0 -- 134
		do -- 134
			local i = 0 -- 135
			while i < #p.enemies do -- 135
				if not p.enemies[i + 1].alive then -- 136
					dead = dead + 1 -- 137
				end -- 137
				i = i + 1 -- 135
			end -- 135
		end -- 135
		local progress = clamp01(dead / #p.enemies) -- 140
		dynamicDawn = 0.34 + progress * 0.62 -- 141
	end -- 141
	if key == "gatepath" or key == "escort1" then -- 144
		local emberPulse = 0.84 + 0.16 * math.sin(time * 2.4) -- 146
		fillRadialGlow( -- 147
			bgGlow, -- 147
			w * 0.14, -- 147
			h * 0.34, -- 147
			w * 0.34, -- 147
			h * 0.38, -- 147
			Color( -- 148
				168, -- 148
				62, -- 148
				34, -- 148
				math.floor(38 * emberPulse + 0.5) -- 148
			), -- 148
			Color(168, 62, 34, 0), -- 148
			16 -- 148
		) -- 148
	end -- 148
	if dynamicDawn > 0.1 then -- 151
		local dawnA = math.floor(62 * dynamicDawn + 0.5) -- 153
		fillVGradRect( -- 154
			bgGlow, -- 154
			0, -- 154
			h * 0.44, -- 154
			w, -- 154
			h * 0.32, -- 154
			Color( -- 155
				186, -- 155
				152, -- 155
				112, -- 155
				math.floor(dawnA * 0.85 + 0.5) -- 155
			), -- 155
			Color(74, 92, 124, 0) -- 156
		) -- 156
		fillRadialGlow( -- 157
			bgGlow, -- 157
			w * spec.screenXFrac, -- 157
			h * (spec.screenYFrac - 0.04), -- 157
			w * 0.34, -- 158
			h * 0.24, -- 158
			Color( -- 159
				232, -- 159
				186, -- 159
				126, -- 159
				math.floor(52 * dynamicDawn + 0.5) -- 159
			), -- 159
			Color(232, 186, 126, 0), -- 160
			18 -- 160
		) -- 160
	end -- 160
	local hasPaintedTower = key == "gatepath" or key == "escort1" or key == "escort4" -- 166
	self:drawDistantNorthTower( -- 167
		key == "escort1" and towerDraw or bgDraw, -- 168
		bgGlow, -- 169
		w, -- 170
		h, -- 171
		cam.x, -- 172
		time, -- 173
		spec, -- 174
		dynamicDawn, -- 175
		key == "escort2", -- 176
		hasPaintedTower -- 177
	) -- 177
	local mistShift = (time * 12 + cam.x * 0.16) % (w + 460) - 230 -- 181
	local mistCol = key == "escort3" and PALETTE.amberDim or PALETTE.jadeMist -- 182
	local mistOp = key == "escort4" and 0.24 or 0.17 -- 183
	backdropArt:tryPlace( -- 184
		"ink_mist_curve", -- 184
		"escort_mist_a", -- 184
		mistShift, -- 184
		h * 0.34, -- 184
		620, -- 184
		120, -- 184
		{ -- 184
			color = toColor(mistCol), -- 185
			opacity = mistOp, -- 185
			layer = 5 -- 185
		} -- 185
	) -- 185
	backdropArt:tryPlace( -- 187
		"ink_mist_curve", -- 187
		"escort_mist_b", -- 187
		(mistShift + w * 0.55) % (w + 460) - 230, -- 187
		h * 0.46, -- 187
		540, -- 187
		100, -- 187
		{ -- 187
			color = toColor(PALETTE.inkMist), -- 188
			opacity = mistOp * 0.85, -- 188
			layer = 5, -- 188
			facing = -1 -- 188
		} -- 188
	) -- 188
	if key == "escort1" then -- 192
		self:drawEscort1AlleySilhouettes(bgDraw, w, h, cam.x) -- 193
	elseif key == "escort2" then -- 194
		self:drawEscort2GranaryRafters( -- 195
			bgDraw, -- 195
			bgGlow, -- 195
			w, -- 195
			h, -- 195
			cam.x, -- 195
			time -- 195
		) -- 195
	elseif key == "escort3" then -- 196
		self:drawEscort3MountainShelterBg( -- 197
			bgDraw, -- 197
			bgGlow, -- 197
			w, -- 197
			h, -- 197
			cam.x, -- 197
			time -- 197
		) -- 197
	elseif key == "escort4" then -- 198
		self:drawEscort4CliffGorge( -- 199
			bgDraw, -- 199
			bgGlow, -- 199
			w, -- 199
			h, -- 199
			cam.x, -- 199
			time -- 199
		) -- 199
	elseif key == "escort5" then -- 200
		self:drawEscort5TowerApproachBg( -- 201
			bgDraw, -- 201
			bgGlow, -- 201
			w, -- 201
			h, -- 201
			cam.x, -- 201
			time, -- 201
			dynamicDawn -- 201
		) -- 201
	end -- 201
end -- 114
function EscortWorldRenderer.prototype.drawWorldSetpieces(self, fgDraw, fgGlow, worldArt, p, view, cam, time) -- 206
	local key = p.room.key -- 215
	if not ____exports.isEscortWorldRoom(key) then -- 216
		return -- 217
	end -- 217
	local ox = p.ox -- 219
	if key == "gatepath" then -- 221
		self:drawGatepathSetpieces( -- 222
			fgDraw, -- 222
			fgGlow, -- 222
			worldArt, -- 222
			p, -- 222
			view, -- 222
			cam, -- 222
			time, -- 222
			ox -- 222
		) -- 222
		return -- 223
	end -- 223
	if key == "escort1" then -- 225
		self:drawEscort1Setpieces( -- 226
			fgDraw, -- 226
			fgGlow, -- 226
			worldArt, -- 226
			p, -- 226
			cam, -- 226
			time, -- 226
			ox -- 226
		) -- 226
		return -- 227
	end -- 227
	if key == "escort2" then -- 229
		self:drawEscort2Setpieces( -- 230
			fgDraw, -- 230
			fgGlow, -- 230
			worldArt, -- 230
			p, -- 230
			cam, -- 230
			time, -- 230
			ox -- 230
		) -- 230
		return -- 231
	end -- 231
	if key == "escort3" then -- 233
		self:drawEscort3WorkbenchSanctuary( -- 234
			fgDraw, -- 234
			fgGlow, -- 234
			worldArt, -- 234
			p, -- 234
			view, -- 234
			cam, -- 234
			time, -- 234
			ox -- 234
		) -- 234
		return -- 235
	end -- 235
	if key == "escort4" then -- 237
		self:drawEscort4Setpieces( -- 238
			fgDraw, -- 238
			fgGlow, -- 238
			worldArt, -- 238
			p, -- 238
			cam, -- 238
			time, -- 238
			ox -- 238
		) -- 238
		return -- 239
	end -- 239
	if key == "escort5" then -- 241
		self:drawEscort5Setpieces( -- 242
			fgDraw, -- 242
			fgGlow, -- 242
			worldArt, -- 242
			p, -- 242
			cam, -- 242
			time, -- 242
			ox -- 242
		) -- 242
	end -- 242
end -- 206
function EscortWorldRenderer.prototype.drawForegroundFraming(self, fgDraw, _fgGlow, worldArt, p, cam, time) -- 247
	local key = p.room.key -- 255
	if not ____exports.isEscortWorldRoom(key) then -- 256
		return -- 257
	end -- 257
	local w = cam.viewW -- 259
	local h = cam.viewH -- 260
	local parallaxX = cam.x * 1.26 -- 261
	local sway = math.sin(time * 1.6) * 4 -- 262
	if key == "escort2" then -- 265
		fgDraw:drawRect( -- 267
			Rect(0, h - 34, w, 34), -- 267
			Color(10, 12, 16, 205) -- 267
		) -- 267
		fgDraw:drawSegment( -- 268
			Vec2(0, h - 34), -- 268
			Vec2(w, h - 34), -- 268
			1.6, -- 268
			Color(58, 46, 36, 155) -- 268
		) -- 268
		do -- 268
			local rx = -40 -- 269
			while rx < w + 80 do -- 269
				local bx = rx - parallaxX * 0.18 % 160 -- 270
				fgDraw:drawRect( -- 271
					Rect(bx, h - 46, 14, 46), -- 271
					Color(14, 12, 11, 190) -- 271
				) -- 271
				rx = rx + 160 -- 269
			end -- 269
		end -- 269
	elseif key == "escort3" or key == "escort4" or key == "escort5" then -- 273
		worldArt:tryPlace( -- 275
			"grass_low", -- 275
			"escort_fg_bush_l", -- 275
			78 + sway * 0.4, -- 275
			-4, -- 275
			190, -- 275
			48, -- 275
			{ -- 275
				color = Color(10, 14, 18, 255), -- 276
				opacity = 0.78, -- 276
				layer = 5200 -- 276
			} -- 276
		) -- 276
		worldArt:tryPlace( -- 278
			"grass_low", -- 278
			"escort_fg_bush_r", -- 278
			w - 82 - sway * 0.35, -- 278
			-4, -- 278
			198, -- 278
			52, -- 278
			{ -- 278
				color = Color(10, 14, 18, 255), -- 279
				opacity = 0.78, -- 279
				layer = 5200, -- 279
				facing = -1 -- 279
			} -- 279
		) -- 279
	end -- 279
	local stride = 260 -- 284
	local startSlot = math.floor((parallaxX - 200) / stride) -- 285
	do -- 285
		local s = startSlot -- 286
		while s <= startSlot + 6 do -- 286
			do -- 286
				local sx = s * stride - parallaxX + w * 0.5 -- 287
				if sx < -140 or sx > w + 140 then -- 288
					goto __continue43 -- 289
				end -- 289
				local hSeed = math.abs(math.sin(s * 12.9898) * 43758.5453) % 1 -- 291
				local rockH = 16 + hSeed * 18 -- 292
				local rockW = 46 + hSeed * 42 -- 293
				fgDraw:drawPolygon( -- 294
					{ -- 294
						Vec2(sx - rockW * 0.5, 0), -- 295
						Vec2(sx + rockW * 0.5, 0), -- 296
						Vec2(sx + rockW * 0.25 + sway * 0.2, rockH), -- 297
						Vec2(sx - rockW * 0.3 + sway * 0.2, rockH * 0.82) -- 298
					}, -- 298
					Color(8, 10, 14, 196) -- 299
				) -- 299
			end -- 299
			::__continue43:: -- 299
			s = s + 1 -- 286
		end -- 286
	end -- 286
end -- 247
function EscortWorldRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, camX, time, spec, dawnWarmth, behindWindow, skipSilhouette) -- 305
	if skipSilhouette == nil then -- 315
		skipSilhouette = false -- 315
	end -- 315
	local s = spec.scale -- 317
	local tx = w * spec.screenXFrac - camX * 0.045 -- 318
	local ty = h * spec.screenYFrac -- 319
	local pulse = 0.86 + 0.14 * math.sin(time * 2.5) -- 320
	local alphaMul = behindWindow and 0.62 or 1 -- 321
	local baseW = 44 * s -- 323
	local topW = 34 * s -- 324
	local bodyH = 62 * s -- 325
	if not skipSilhouette then -- 327
		local ridgeW = 190 * s + 95 -- 329
		local ridgeH = 44 * s + 22 -- 330
		local ridgeCol = Color( -- 331
			math.floor(20 + dawnWarmth * 16 + 0.5), -- 332
			math.floor(26 + dawnWarmth * 14 + 0.5), -- 333
			math.floor(38 + dawnWarmth * 8 + 0.5), -- 334
			math.floor(188 * alphaMul + 0.5) -- 335
		) -- 335
		bgDraw:drawPolygon( -- 337
			{ -- 337
				Vec2(tx - ridgeW, ty - ridgeH), -- 338
				Vec2(tx + ridgeW * 0.72, ty - ridgeH), -- 339
				Vec2(tx + ridgeW * 0.16, ty + 6 * s), -- 340
				Vec2(tx - ridgeW * 0.32, ty + 2 * s) -- 341
			}, -- 341
			ridgeCol -- 342
		) -- 342
		local towerCol = Color( -- 345
			math.floor(24 + dawnWarmth * 14 + 0.5), -- 346
			math.floor(30 + dawnWarmth * 12 + 0.5), -- 347
			math.floor(42 + dawnWarmth * 8 + 0.5), -- 348
			math.floor(225 * alphaMul + 0.5) -- 349
		) -- 349
		local rimCol = Color( -- 351
			138, -- 351
			148, -- 351
			166, -- 351
			math.floor(68 * alphaMul + 0.5) -- 351
		) -- 351
		bgDraw:drawPolygon( -- 352
			{ -- 352
				Vec2(tx - baseW * 0.5, ty - 4 * s), -- 353
				Vec2(tx + baseW * 0.5, ty - 4 * s), -- 354
				Vec2(tx + topW * 0.5, ty + bodyH), -- 355
				Vec2(tx - topW * 0.5, ty + bodyH) -- 356
			}, -- 356
			towerCol, -- 357
			0.8, -- 357
			rimCol -- 357
		) -- 357
		local pavH = 18 * s -- 360
		local eaveY = ty + bodyH + pavH -- 361
		local eaveW = 54 * s -- 362
		bgDraw:drawRect( -- 363
			Rect(tx - topW * 0.38, ty + bodyH, 3 * s, pavH), -- 363
			towerCol -- 363
		) -- 363
		bgDraw:drawRect( -- 364
			Rect(tx + topW * 0.38 - 3 * s, ty + bodyH, 3 * s, pavH), -- 364
			towerCol -- 364
		) -- 364
		bgDraw:drawPolygon( -- 365
			{ -- 365
				Vec2(tx - eaveW * 0.54, eaveY - 2 * s), -- 366
				Vec2(tx + eaveW * 0.54, eaveY - 2 * s), -- 367
				Vec2(tx + eaveW * 0.24, eaveY + 13 * s), -- 368
				Vec2(tx - eaveW * 0.24, eaveY + 13 * s) -- 369
			}, -- 369
			Color( -- 370
				18, -- 370
				22, -- 370
				32, -- 370
				math.floor(238 * alphaMul + 0.5) -- 370
			), -- 370
			0.8, -- 370
			rimCol -- 370
		) -- 370
	end -- 370
	local lampX = tx - topW * 0.14 -- 374
	local lampY = ty + bodyH * 0.64 -- 375
	local glowR = spec.beaconR * pulse -- 376
	fillRadialGlow( -- 377
		bgGlow, -- 377
		lampX, -- 377
		lampY, -- 377
		glowR * 1.35, -- 377
		glowR, -- 377
		Color( -- 378
			255, -- 378
			206, -- 378
			122, -- 378
			math.floor(92 * pulse * alphaMul + 0.5) -- 378
		), -- 378
		Color(255, 178, 86, 0), -- 379
		16 -- 379
	) -- 379
	fillRadialGlow( -- 380
		bgGlow, -- 380
		lampX, -- 380
		lampY, -- 380
		glowR * 0.48, -- 380
		glowR * 0.42, -- 380
		Color( -- 381
			255, -- 381
			238, -- 381
			184, -- 381
			math.floor(176 * pulse * alphaMul + 0.5) -- 381
		), -- 381
		Color(255, 204, 118, 0), -- 382
		12 -- 382
	) -- 382
	bgGlow:drawDot( -- 383
		Vec2(lampX, lampY), -- 383
		math.max(1.8, 3.6 * s), -- 383
		Color( -- 383
			255, -- 383
			246, -- 383
			212, -- 383
			math.floor(248 * alphaMul + 0.5) -- 383
		) -- 383
	) -- 383
end -- 305
function EscortWorldRenderer.prototype.drawEscort1AlleySilhouettes(self, bgDraw, w, h, camX) -- 388
	local shift = camX * 0.38 -- 389
	local houses = {{x = 140, bw = 165, bh = 165, roof = 36}, {x = 430, bw = 190, bh = 195, roof = 42}, {x = 760, bw = 145, bh = 150, roof = 30}, {x = 1080, bw = 210, bh = 185, roof = 40}} -- 390
	for ____, hs in ipairs(houses) do -- 396
		local sx = ((hs.x - shift) % (w + 340) + (w + 340)) % (w + 340) - 170 -- 397
		local base = h * 0.25 -- 398
		bgDraw:drawRect( -- 399
			Rect(sx, base, hs.bw, hs.bh), -- 399
			Color(16, 20, 29, 175) -- 399
		) -- 399
		bgDraw:drawPolygon( -- 400
			{ -- 400
				Vec2(sx - 16, base + hs.bh), -- 401
				Vec2(sx + hs.bw + 16, base + hs.bh), -- 402
				Vec2(sx + hs.bw * 0.78, base + hs.bh + hs.roof), -- 403
				Vec2(sx + hs.bw * 0.22, base + hs.bh + hs.roof) -- 404
			}, -- 404
			Color(12, 15, 22, 195) -- 405
		) -- 405
	end -- 405
end -- 388
function EscortWorldRenderer.prototype.drawEscort2GranaryRafters(self, bgDraw, bgGlow, w, h, camX, time) -- 409
	local shift = camX * 0.42 -- 417
	bgDraw:drawRect( -- 419
		Rect(0, h * 0.8, w, h * 0.2), -- 419
		Color(12, 14, 20, 192) -- 419
	) -- 419
	local span = 290 -- 420
	local first = math.floor((shift - 180) / span) -- 421
	do -- 421
		local k = first -- 422
		while k <= first + 6 do -- 422
			local bx = k * span - shift -- 423
			bgDraw:drawRect( -- 425
				Rect(bx - 9, h * 0.2, 18, h * 0.62), -- 425
				Color(22, 19, 17, 165) -- 425
			) -- 425
			bgDraw:drawSegment( -- 427
				Vec2(bx, h * 0.82), -- 427
				Vec2(bx + span * 0.5, h * 0.96), -- 427
				7, -- 427
				Color(26, 21, 18, 185) -- 427
			) -- 427
			bgDraw:drawSegment( -- 428
				Vec2(bx + span, h * 0.82), -- 428
				Vec2(bx + span * 0.5, h * 0.96), -- 428
				7, -- 428
				Color(26, 21, 18, 185) -- 428
			) -- 428
			if math.abs(k) % 2 == 0 then -- 430
				local topX = bx + span * 0.44 -- 431
				local pulse = 0.86 + 0.14 * math.sin(time * 1.1 + k) -- 432
				local midA = math.floor(30 * pulse + 0.5) -- 433
				local topA = math.floor(14 * pulse + 0.5) -- 434
				fillGradQuad( -- 435
					bgGlow, -- 436
					topX - 20, -- 437
					h + 10, -- 437
					Color(168, 194, 224, topA), -- 437
					topX + 36, -- 438
					h + 10, -- 438
					Color(168, 194, 224, topA), -- 438
					topX + 94, -- 439
					h * 0.48, -- 439
					Color(176, 202, 232, midA), -- 439
					topX + 8, -- 440
					h * 0.48, -- 440
					Color(176, 202, 232, midA) -- 440
				) -- 440
				fillGradQuad( -- 442
					bgGlow, -- 443
					topX + 8, -- 444
					h * 0.48, -- 444
					Color(176, 202, 232, midA), -- 444
					topX + 94, -- 445
					h * 0.48, -- 445
					Color(176, 202, 232, midA), -- 445
					topX + 136, -- 446
					h * 0.14, -- 446
					Color(168, 194, 224, 0), -- 446
					topX + 30, -- 447
					h * 0.14, -- 447
					Color(168, 194, 224, 0) -- 447
				) -- 447
				do -- 447
					local d = 0 -- 450
					while d < 4 do -- 450
						local phase = (time * 0.18 + d * 0.27 + k * 0.31) % 1 -- 451
						local dx = topX + 12 + phase * 76 + math.sin(time * 1.4 + d) * 8 -- 452
						local dy = h * (0.9 - phase * 0.68) -- 453
						bgGlow:drawDot( -- 454
							Vec2(dx, dy), -- 454
							1.6, -- 454
							Color( -- 454
								214, -- 454
								222, -- 454
								232, -- 454
								math.floor(62 * math.sin(phase * math.pi) + 0.5) -- 454
							) -- 454
						) -- 454
						d = d + 1 -- 450
					end -- 450
				end -- 450
			end -- 450
			k = k + 1 -- 422
		end -- 422
	end -- 422
end -- 409
function EscortWorldRenderer.prototype.drawEscort3MountainShelterBg(self, bgDraw, bgGlow, w, h, camX, time) -- 460
	local cliffX = 120 - camX * 0.28 -- 469
	bgDraw:drawPolygon( -- 470
		{ -- 470
			Vec2(cliffX - 240, h * 0.18), -- 471
			Vec2(cliffX + 260, h * 0.18), -- 472
			Vec2(cliffX + 165, h * 0.68), -- 473
			Vec2(cliffX - 180, h * 0.86) -- 474
		}, -- 474
		Color(14, 18, 25, 165) -- 475
	) -- 475
	local warmPulse = 0.9 + 0.1 * math.sin(time * 2.1) -- 477
	fillRadialGlow( -- 478
		bgGlow, -- 478
		w * 0.5, -- 478
		h * 0.36, -- 478
		w * 0.26, -- 478
		h * 0.26, -- 478
		Color( -- 479
			224, -- 479
			164, -- 479
			88, -- 479
			math.floor(32 * warmPulse + 0.5) -- 479
		), -- 479
		Color(224, 164, 88, 0), -- 479
		16 -- 479
	) -- 479
end -- 460
function EscortWorldRenderer.prototype.drawEscort4CliffGorge(self, bgDraw, bgGlow, w, h, camX, time) -- 482
	local shift = camX * 0.32 -- 491
	do -- 491
		local i = 0 -- 492
		while i < 4 do -- 492
			local px = ((i * 380 - shift) % (w + 420) + (w + 420)) % (w + 420) - 210 -- 493
			bgDraw:drawPolygon( -- 494
				{ -- 494
					Vec2(px - 120, h * 0.2), -- 495
					Vec2(px + 145, h * 0.2), -- 496
					Vec2(px + 48, h * (0.58 + i % 2 * 0.12)), -- 497
					Vec2(px - 58, h * (0.5 + i % 2 * 0.08)) -- 498
				}, -- 498
				Color(16, 22, 33, 152) -- 499
			) -- 499
			i = i + 1 -- 492
		end -- 492
	end -- 492
	local cloudX = time * 24 % (w + 400) - 200 -- 502
	bgGlow:drawPolygon( -- 503
		{ -- 503
			Vec2(cloudX, h * 0.78), -- 504
			Vec2(cloudX + 240, h * 0.82), -- 505
			Vec2(cloudX + 210, h * 0.87), -- 506
			Vec2(cloudX - 20, h * 0.83) -- 507
		}, -- 507
		Color(142, 164, 192, 24) -- 508
	) -- 508
end -- 482
function EscortWorldRenderer.prototype.drawEscort5TowerApproachBg(self, bgDraw, bgGlow, w, h, camX, time, dawnWarmth) -- 511
	local glowPulse = 0.88 + 0.12 * math.sin(time * 1.8) -- 521
	fillRadialGlow( -- 522
		bgGlow, -- 522
		w * 0.78, -- 522
		h * 0.48, -- 522
		w * 0.42, -- 522
		h * 0.3, -- 522
		Color( -- 523
			228, -- 523
			184, -- 523
			132, -- 523
			math.floor(44 * dawnWarmth * glowPulse + 0.5) -- 523
		), -- 523
		Color(228, 184, 132, 0), -- 524
		18 -- 524
	) -- 524
	local shift = camX * 0.3 -- 526
	bgDraw:drawPolygon( -- 527
		{ -- 527
			Vec2(0, h * 0.2), -- 528
			Vec2(w, h * 0.2), -- 529
			Vec2(w, h * 0.34), -- 530
			Vec2(w * 0.55 - shift % 120 * 0.2, h * 0.29), -- 531
			Vec2(0, h * 0.36) -- 532
		}, -- 532
		Color(18, 22, 32, 140) -- 533
	) -- 533
end -- 511
function EscortWorldRenderer.prototype.drawGatepathSetpieces(self, fgDraw, fgGlow, worldArt, p, view, cam, time, ox) -- 538
	local groundY = cam:sy(0) -- 548
	worldArt:tryPlace( -- 550
		"sh_stele_banner", -- 550
		"gp_banner_start", -- 550
		cam:sx(ox + 96), -- 550
		groundY, -- 550
		cam:len(68), -- 550
		cam:len(74), -- 550
		{layer = 1, opacity = 0.92} -- 550
	) -- 550
	worldArt:tryPlace( -- 553
		"sh_stele_banner", -- 553
		"gp_stele_mid", -- 553
		cam:sx(ox + 520), -- 553
		groundY, -- 553
		cam:len(54), -- 553
		cam:len(60), -- 553
		{layer = 1, opacity = 0.86, facing = -1} -- 553
	) -- 553
	local stepTopY = cam:sy(48) -- 557
	local lampX = cam:sx(ox + 912) -- 558
	local poleH = cam:len(58) -- 559
	fgDraw:drawSegment( -- 560
		Vec2(lampX, stepTopY), -- 560
		Vec2(lampX, stepTopY + poleH), -- 560
		math.max( -- 560
			1.8, -- 560
			cam:len(2.4) -- 560
		), -- 560
		Color(74, 54, 38, 240) -- 560
	) -- 560
	fgDraw:drawSegment( -- 561
		Vec2(lampX, stepTopY + poleH), -- 561
		Vec2( -- 561
			lampX - cam:len(14), -- 561
			stepTopY + poleH -- 561
		), -- 561
		math.max( -- 561
			1.5, -- 561
			cam:len(2) -- 561
		), -- 561
		Color(74, 54, 38, 240) -- 561
	) -- 561
	worldArt:tryPlace( -- 562
		"prop_lantern", -- 562
		"gp_top_lantern", -- 562
		lampX - cam:len(14), -- 562
		stepTopY + poleH - cam:len(14), -- 562
		cam:len(18), -- 562
		cam:len(22), -- 562
		{layer = 4} -- 562
	) -- 562
	local flame = 0.88 + 0.12 * math.sin(time * 3.1) -- 563
	fillRadialGlow( -- 564
		fgGlow, -- 564
		lampX - cam:len(14), -- 564
		stepTopY + poleH - cam:len(14), -- 564
		cam:len(54), -- 564
		cam:len(48), -- 564
		Color( -- 565
			246, -- 565
			192, -- 565
			114, -- 565
			math.floor(72 * flame + 0.5) -- 565
		), -- 565
		Color(246, 192, 114, 0), -- 565
		16 -- 565
	) -- 565
	if p.phase == "gatepath-start" and p.partner.alive then -- 568
		local sx1 = cam:sx(p.player.x) -- 569
		local sx2 = cam:sx(p.partner.x) -- 570
		fgDraw:drawPolygon( -- 571
			{ -- 571
				Vec2( -- 572
					sx1 - cam:len(10), -- 572
					groundY + 1 -- 572
				), -- 572
				Vec2( -- 573
					sx1 + cam:len(10), -- 573
					groundY + 1 -- 573
				), -- 573
				Vec2( -- 574
					sx1 - cam:len(24), -- 574
					groundY - cam:len(10) -- 574
				), -- 574
				Vec2( -- 575
					sx1 - cam:len(40), -- 575
					groundY - cam:len(10) -- 575
				) -- 575
			}, -- 575
			Color(8, 10, 16, 86) -- 576
		) -- 576
		fgDraw:drawPolygon( -- 577
			{ -- 577
				Vec2( -- 578
					sx2 - cam:len(7), -- 578
					groundY + 1 -- 578
				), -- 578
				Vec2( -- 579
					sx2 + cam:len(7), -- 579
					groundY + 1 -- 579
				), -- 579
				Vec2( -- 580
					sx2 - cam:len(15), -- 580
					groundY - cam:len(7) -- 580
				), -- 580
				Vec2( -- 581
					sx2 - cam:len(26), -- 581
					groundY - cam:len(7) -- 581
				) -- 581
			}, -- 581
			Color(8, 10, 16, 78) -- 582
		) -- 582
	end -- 582
	if self.carryBloomT > 0 or view.backCarry.mounting then -- 586
		local k = self.carryBloomT > 0 and clamp01(self.carryBloomT / 1.15) or 0.72 -- 587
		local bx = cam:sx(p.player.x) -- 588
		local by = cam:sy(p.player.y + 42) -- 589
		fillRadialGlow( -- 590
			fgGlow, -- 590
			bx, -- 590
			by, -- 590
			cam:len(96), -- 590
			cam:len(72), -- 590
			Color( -- 591
				244, -- 591
				206, -- 591
				142, -- 591
				math.floor(62 * k + 0.5) -- 591
			), -- 591
			Color(244, 206, 142, 0), -- 591
			18 -- 591
		) -- 591
	end -- 591
end -- 538
function EscortWorldRenderer.prototype.drawEscort1Setpieces(self, fgDraw, fgGlow, worldArt, _p, cam, time, ox) -- 595
	local backDepth = LANE_DEPTH.upper + 16 -- 604
	local backY = cam:sy(0, backDepth) -- 605
	local backLayer = depthOrder(backDepth, -2) -- 606
	worldArt:tryPlace( -- 608
		"sh_stele_banner", -- 608
		"e1_banner_a", -- 608
		cam:sx(ox + 150), -- 608
		backY, -- 608
		cam:len(68), -- 608
		cam:len(76), -- 608
		{layer = backLayer, opacity = 0.9} -- 608
	) -- 608
	worldArt:tryPlace( -- 611
		"sh_stele_banner", -- 611
		"e1_banner_b", -- 611
		cam:sx(ox + 1245), -- 611
		backY, -- 611
		cam:len(64), -- 611
		cam:len(70), -- 611
		{layer = backLayer, opacity = 0.88, facing = -1} -- 611
	) -- 611
	local emberSpots = {285, 860} -- 615
	do -- 615
		local i = 0 -- 616
		while i < #emberSpots do -- 616
			local bx = cam:sx(ox + emberSpots[i + 1]) -- 617
			local pulse = 0.82 + 0.18 * math.sin(time * 4.2 + i * 1.9) -- 618
			fgDraw:drawPolygon( -- 619
				{ -- 619
					Vec2( -- 620
						bx - cam:len(12), -- 620
						backY + cam:len(14) -- 620
					), -- 620
					Vec2( -- 621
						bx + cam:len(12), -- 621
						backY + cam:len(14) -- 621
					), -- 621
					Vec2( -- 622
						bx + cam:len(8), -- 622
						backY + cam:len(4) -- 622
					), -- 622
					Vec2( -- 623
						bx - cam:len(8), -- 623
						backY + cam:len(4) -- 623
					) -- 623
				}, -- 623
				Color(38, 34, 34, 240), -- 624
				1, -- 624
				Color(88, 72, 62, 180) -- 624
			) -- 624
			fgDraw:drawSegment( -- 625
				Vec2( -- 625
					bx - cam:len(9), -- 625
					backY -- 625
				), -- 625
				Vec2( -- 625
					bx - cam:len(6), -- 625
					backY + cam:len(6) -- 625
				), -- 625
				2, -- 625
				Color(34, 30, 30, 235) -- 625
			) -- 625
			fgDraw:drawSegment( -- 626
				Vec2( -- 626
					bx + cam:len(9), -- 626
					backY -- 626
				), -- 626
				Vec2( -- 626
					bx + cam:len(6), -- 626
					backY + cam:len(6) -- 626
				), -- 626
				2, -- 626
				Color(34, 30, 30, 235) -- 626
			) -- 626
			fgGlow:drawEllipse( -- 627
				Vec2( -- 627
					bx, -- 627
					backY + cam:len(14) -- 627
				), -- 627
				cam:len(9), -- 627
				cam:len(3.5), -- 627
				Color( -- 627
					236, -- 627
					114, -- 627
					48, -- 627
					math.floor(185 * pulse + 0.5) -- 627
				) -- 627
			) -- 627
			fillRadialGlow( -- 628
				fgGlow, -- 628
				bx, -- 628
				backY + cam:len(18), -- 628
				cam:len(48), -- 628
				cam:len(36), -- 628
				Color( -- 629
					226, -- 629
					116, -- 629
					52, -- 629
					math.floor(62 * pulse + 0.5) -- 629
				), -- 629
				Color(226, 116, 52, 0), -- 629
				14 -- 629
			) -- 629
			i = i + 1 -- 616
		end -- 616
	end -- 616
end -- 595
function EscortWorldRenderer.prototype.drawEscort2Setpieces(self, fgDraw, fgGlow, worldArt, p, cam, time, ox) -- 633
	local backDepth = LANE_DEPTH.upper + 16 -- 642
	local backY = cam:sy(0, backDepth) -- 643
	local backLayer = depthOrder(backDepth, -2) -- 644
	local sackSpots = {195, 480, 1020, 1310} -- 646
	do -- 646
		local i = 0 -- 647
		while i < #sackSpots do -- 647
			local sx = cam:sx(ox + sackSpots[i + 1]) -- 648
			worldArt:tryPlace( -- 649
				"sh_grain_sacks", -- 649
				"e2_bg_sack_" .. tostring(i), -- 649
				sx, -- 649
				backY, -- 649
				cam:len(72), -- 649
				cam:len(44), -- 649
				{ -- 649
					layer = backLayer, -- 650
					opacity = 0.78, -- 651
					facing = i % 2 == 0 and 1 or -1, -- 652
					color = Color(172, 168, 162, 255) -- 653
				} -- 653
			) -- 653
			i = i + 1 -- 647
		end -- 647
	end -- 647
	local beamY = cam:sy(64, -24) -- 657
	local drapeX = cam:sx(ox + 440) -- 658
	local sway = math.sin(time * 1.9) * 3 -- 659
	fgDraw:drawPolygon( -- 660
		{ -- 660
			Vec2( -- 661
				drapeX - cam:len(22), -- 661
				beamY -- 661
			), -- 661
			Vec2( -- 662
				drapeX + cam:len(22), -- 662
				beamY -- 662
			), -- 662
			Vec2( -- 663
				drapeX + cam:len(18) + sway, -- 663
				beamY - cam:len(24) -- 663
			), -- 663
			Vec2( -- 664
				drapeX - cam:len(14) + sway * 0.7, -- 664
				beamY - cam:len(19) -- 664
			) -- 664
		}, -- 664
		Color(72, 58, 46, 160) -- 665
	) -- 665
	for ____, pk in ipairs(p.pickups) do -- 668
		do -- 668
			if pk.id == "" or p.run.taken[pk.id] then -- 669
				goto __continue70 -- 670
			end -- 670
			local px = cam:sx(pk.x) -- 672
			local py = cam:sy(pk.y + 10, pk.depth or 0) -- 673
			local pulse = 0.78 + 0.22 * math.sin(time * 3 + pk.x * 0.02) -- 674
			local col = pk.kind == "bell" and Color( -- 675
				238, -- 675
				204, -- 675
				136, -- 675
				math.floor(78 * pulse + 0.5) -- 675
			) or Color( -- 675
				224, -- 675
				168, -- 675
				92, -- 675
				math.floor(72 * pulse + 0.5) -- 675
			) -- 675
			fillRadialGlow( -- 676
				fgGlow, -- 676
				px, -- 676
				py, -- 676
				cam:len(22), -- 676
				cam:len(18), -- 676
				col, -- 676
				Color(224, 168, 92, 0), -- 676
				12 -- 676
			) -- 676
		end -- 676
		::__continue70:: -- 676
	end -- 676
end -- 633
function EscortWorldRenderer.prototype.drawEscort3WorkbenchSanctuary(self, fgDraw, fgGlow, worldArt, p, view, cam, time, ox) -- 680
	local pulse = 0.88 + 0.12 * math.sin(time * 2.6) -- 690
	local benchCx = cam:sx(ox + 620) -- 691
	local benchDepth = LANE_DEPTH.middle + 10 -- 692
	local benchBaseY = cam:sy(0, benchDepth) -- 693
	local benchLayer = depthOrder(benchDepth, 2) -- 694
	fillRadialGlow( -- 697
		fgGlow, -- 697
		benchCx, -- 697
		benchBaseY + cam:len(42), -- 697
		cam:len(168), -- 697
		cam:len(112), -- 697
		Color( -- 698
			246, -- 698
			184, -- 698
			96, -- 698
			math.floor(76 * pulse + 0.5) -- 698
		), -- 698
		Color(246, 168, 74, 0), -- 698
		20 -- 698
	) -- 698
	fillRadialGlow( -- 699
		fgGlow, -- 699
		benchCx - cam:len(22), -- 699
		benchBaseY + cam:len(68), -- 699
		cam:len(58), -- 699
		cam:len(48), -- 699
		Color( -- 700
			255, -- 700
			224, -- 700
			152, -- 700
			math.floor(115 * pulse + 0.5) -- 700
		), -- 700
		Color(255, 198, 108, 0), -- 700
		14 -- 700
	) -- 700
	worldArt:tryPlace( -- 703
		"sh_craft_workbench", -- 703
		"e3_sanctuary_bench", -- 703
		benchCx, -- 703
		benchBaseY - cam:len(4), -- 703
		cam:len(142), -- 703
		cam:len(112), -- 703
		{layer = benchLayer} -- 703
	) -- 703
	local matX = cam:sx(ox + 516) -- 708
	local matDepth = LANE_DEPTH.middle + 4 -- 709
	local matY = cam:sy(0, matDepth) -- 710
	worldArt:tryPlace( -- 711
		"sh_straw_mat", -- 711
		"e3_xiaoman_mat", -- 711
		matX, -- 711
		matY - cam:len(2), -- 711
		cam:len(66), -- 711
		cam:len(28), -- 711
		{layer = depthOrder(matDepth, 0)} -- 711
	) -- 711
	if view.backCarry.atBench or view.craftBench.active then -- 715
		fillRadialGlow( -- 716
			fgGlow, -- 716
			matX, -- 716
			matY + cam:len(22), -- 716
			cam:len(42), -- 716
			cam:len(34), -- 716
			Color( -- 717
				252, -- 717
				212, -- 717
				138, -- 717
				math.floor(68 * pulse + 0.5) -- 717
			), -- 717
			Color(252, 212, 138, 0), -- 717
			14 -- 717
		) -- 717
	end -- 717
	worldArt:tryPlace( -- 721
		"sh_stele_banner", -- 721
		"e3_entry_stele", -- 721
		cam:sx(ox + 235), -- 721
		cam:sy(0, LANE_DEPTH.upper + 16), -- 721
		cam:len(58), -- 721
		cam:len(66), -- 721
		{ -- 721
			layer = depthOrder(LANE_DEPTH.upper + 16, -1), -- 722
			opacity = 0.86 -- 722
		} -- 722
	) -- 722
	do -- 722
		local i = 0 -- 726
		while i < #p.enemies do -- 726
			do -- 726
				local en = p.enemies[i + 1] -- 727
				if en.kind ~= "target" then -- 728
					goto __continue76 -- 729
				end -- 729
				local tx = cam:sx(en.x) -- 731
				local ty = cam:sy(en.y, en.depth or 0) -- 732
				local swayK = self.gongSway[i] or 0 -- 733
				local swayAng = math.sin(time * 24 + i) * 7.5 * swayK -- 734
				worldArt:tryPlace( -- 735
					"sh_gong_target", -- 735
					"e3_gong_target_" .. tostring(i), -- 735
					tx, -- 735
					ty - cam:len(2), -- 735
					cam:len(68), -- 735
					cam:len(62), -- 735
					{ -- 735
						layer = depthOrder(en.depth or 0, 2), -- 736
						angle = swayAng, -- 737
						opacity = en.alive and 1 or 0.55 -- 738
					} -- 738
				) -- 738
				if swayK > 0.05 then -- 740
					local ringR = cam:len(18 + (1 - swayK) * 44) -- 741
					fgGlow:drawRing( -- 742
						Vec2( -- 742
							tx, -- 742
							ty + cam:len(32) -- 742
						), -- 742
						math.max(1, ringR - 1.5), -- 742
						ringR, -- 742
						Color(0, 0, 0, 0), -- 743
						1.4, -- 743
						toColor( -- 743
							PALETTE.amber, -- 743
							math.floor(190 * swayK + 0.5) -- 743
						) -- 743
					) -- 743
				end -- 743
			end -- 743
			::__continue76:: -- 743
			i = i + 1 -- 726
		end -- 726
	end -- 726
end -- 680
function EscortWorldRenderer.prototype.drawEscort4Setpieces(self, fgDraw, fgGlow, worldArt, p, cam, time, ox) -- 748
	local backDepth = LANE_DEPTH.upper + 16 -- 757
	local backY = cam:sy(0, backDepth) -- 758
	local backLayer = depthOrder(backDepth, -2) -- 759
	worldArt:tryPlace( -- 761
		"sh_stele_banner", -- 761
		"e4_stele_a", -- 761
		cam:sx(ox + 210), -- 761
		backY, -- 761
		cam:len(58), -- 761
		cam:len(66), -- 761
		{layer = backLayer, opacity = 0.9} -- 761
	) -- 761
	worldArt:tryPlace( -- 764
		"sh_stele_banner", -- 764
		"e4_stele_b", -- 764
		cam:sx(ox + 990), -- 764
		backY, -- 764
		cam:len(56), -- 764
		cam:len(64), -- 764
		{layer = backLayer, opacity = 0.88, facing = -1} -- 764
	) -- 764
	local pineXs = {310, 740, 1210} -- 768
	do -- 768
		local i = 0 -- 769
		while i < #pineXs do -- 769
			worldArt:tryPlace( -- 770
				"pine", -- 770
				"e4_cliff_pine_" .. tostring(i), -- 770
				cam:sx(ox + pineXs[i + 1]), -- 770
				backY - cam:len(4), -- 770
				cam:len(112), -- 770
				cam:len(98), -- 770
				{ -- 770
					layer = backLayer - 1, -- 771
					opacity = 0.72, -- 771
					facing = i % 2 == 0 and 1 or -1, -- 771
					color = Color(138, 152, 168, 255) -- 771
				} -- 771
			) -- 771
			i = i + 1 -- 769
		end -- 769
	end -- 769
	do -- 769
		local i = 0 -- 775
		while i < #p.enemies do -- 775
			do -- 775
				local en = p.enemies[i + 1] -- 776
				if not en.alive or en.kind ~= "gunner" then -- 777
					goto __continue83 -- 778
				end -- 778
				local gx = cam:sx(en.x - 10) -- 780
				local gy = cam:sy(en.y + en.h * 0.62, en.depth or 0) -- 781
				local ember = 0.72 + 0.28 * math.sin(time * 7.5 + i * 2.1) -- 782
				fgGlow:drawDot( -- 783
					Vec2(gx, gy), -- 783
					2.3, -- 783
					Color( -- 783
						255, -- 783
						134, -- 783
						62, -- 783
						math.floor(215 * ember + 0.5) -- 783
					) -- 783
				) -- 783
				fillRadialGlow( -- 784
					fgGlow, -- 784
					gx, -- 784
					gy, -- 784
					14, -- 784
					14, -- 784
					Color( -- 784
						242, -- 784
						108, -- 784
						46, -- 784
						math.floor(64 * ember + 0.5) -- 784
					), -- 784
					Color(242, 108, 46, 0), -- 784
					10 -- 784
				) -- 784
			end -- 784
			::__continue83:: -- 784
			i = i + 1 -- 775
		end -- 775
	end -- 775
	fgDraw:drawSegment( -- 787
		Vec2( -- 787
			cam:sx(ox + 500), -- 787
			backY + cam:len(4) -- 787
		), -- 787
		Vec2( -- 787
			cam:sx(ox + 900), -- 787
			backY + cam:len(4) -- 787
		), -- 787
		1, -- 787
		Color(110, 124, 142, 48) -- 787
	) -- 787
end -- 748
function EscortWorldRenderer.prototype.drawEscort5Setpieces(self, fgDraw, fgGlow, worldArt, _p, cam, time, ox) -- 790
	local backDepth = LANE_DEPTH.upper + 16 -- 799
	local backY = cam:sy(0, backDepth) -- 800
	local backLayer = depthOrder(backDepth, -2) -- 801
	worldArt:tryPlace( -- 803
		"sh_stele_banner", -- 803
		"e5_stele_a", -- 803
		cam:sx(ox + 215), -- 803
		backY, -- 803
		cam:len(62), -- 803
		cam:len(70), -- 803
		{layer = backLayer, opacity = 0.92} -- 803
	) -- 803
	worldArt:tryPlace( -- 806
		"pine", -- 806
		"e5_pine_a", -- 806
		cam:sx(ox + 640), -- 806
		backY - cam:len(4), -- 806
		cam:len(118), -- 806
		cam:len(102), -- 806
		{ -- 806
			layer = backLayer - 1, -- 807
			opacity = 0.78, -- 807
			color = Color(156, 168, 182, 255) -- 807
		} -- 807
	) -- 807
	local lx = cam:sx(ox + 1315) -- 810
	local poleTop = backY + cam:len(68) -- 811
	local flame = 0.88 + 0.12 * math.sin(time * 2.9) -- 812
	fgDraw:drawSegment( -- 813
		Vec2(lx, backY), -- 813
		Vec2(lx, poleTop), -- 813
		math.max( -- 813
			1.8, -- 813
			cam:len(2.4) -- 813
		), -- 813
		Color(76, 56, 40, 240) -- 813
	) -- 813
	fgDraw:drawSegment( -- 814
		Vec2(lx, poleTop), -- 814
		Vec2( -- 814
			lx - cam:len(15), -- 814
			poleTop -- 814
		), -- 814
		math.max( -- 814
			1.6, -- 814
			cam:len(2) -- 814
		), -- 814
		Color(76, 56, 40, 240) -- 814
	) -- 814
	worldArt:tryPlace( -- 815
		"prop_lantern", -- 815
		"e5_approach_lamp", -- 815
		lx - cam:len(15), -- 815
		poleTop - cam:len(14), -- 815
		cam:len(20), -- 815
		cam:len(24), -- 815
		{layer = backLayer + 2} -- 815
	) -- 815
	fillRadialGlow( -- 818
		fgGlow, -- 818
		lx - cam:len(15), -- 818
		poleTop - cam:len(14), -- 818
		cam:len(74), -- 818
		cam:len(62), -- 818
		Color( -- 819
			255, -- 819
			206, -- 819
			128, -- 819
			math.floor(92 * flame + 0.5) -- 819
		), -- 819
		Color(255, 182, 88, 0), -- 819
		16 -- 819
	) -- 819
end -- 790
return ____exports -- 790
