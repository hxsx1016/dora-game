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
	if self.lastRoomKey ~= p.room.key then -- 87
		self.lastRoomKey = p.room.key -- 89
		self:reset() -- 90
	end -- 90
	if carryStarted then -- 90
		self.carryBloomT = 1.15 -- 93
	elseif self.carryBloomT > 0 then -- 93
		self.carryBloomT = math.max(0, self.carryBloomT - dt) -- 95
	end -- 95
	if p.room.key == "escort3" then -- 95
		do -- 95
			local i = 0 -- 98
			while i < #p.enemies do -- 98
				local en = p.enemies[i + 1] -- 99
				local prevHit = self.lastEnemyHitT[i] or 0 -- 100
				if en.hitT > prevHit + 0.05 then -- 100
					self.gongSway[i] = 1 -- 102
				end -- 102
				self.lastEnemyHitT[i] = en.hitT -- 104
				local cur = self.gongSway[i] or 0 -- 105
				if cur > 0 then -- 105
					self.gongSway[i] = math.max(0, cur - dt * 1.4) -- 107
				end -- 107
				i = i + 1 -- 98
			end -- 98
		end -- 98
	end -- 98
end -- 87
function EscortWorldRenderer.prototype.drawBackdropOverlay(self, bgDraw, bgGlow, backdropArt, p, cam, time, towerDraw) -- 114
	if towerDraw == nil then -- 114
		towerDraw = bgDraw -- 121
	end -- 121
	local key = p.room.key -- 123
	if not ____exports.isEscortWorldRoom(key) then -- 123
		return -- 125
	end -- 125
	local w = cam.viewW -- 127
	local h = cam.viewH -- 128
	local spec = TOWER_PROGRESSION[key] or TOWER_PROGRESSION.escort1 -- 129
	local dynamicDawn = spec.dawnWarmth -- 132
	if key == "escort5" and #p.enemies > 0 then -- 132
		local dead = 0 -- 134
		do -- 134
			local i = 0 -- 135
			while i < #p.enemies do -- 135
				if not p.enemies[i + 1].alive then -- 135
					dead = dead + 1 -- 137
				end -- 137
				i = i + 1 -- 135
			end -- 135
		end -- 135
		local progress = clamp01(dead / #p.enemies) -- 140
		dynamicDawn = 0.34 + progress * 0.62 -- 141
	end -- 141
	if key == "gatepath" or key == "escort1" then -- 141
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
	if dynamicDawn > 0.1 then -- 148
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
	self:drawDistantNorthTower( -- 164
		towerDraw, -- 164
		bgGlow, -- 164
		w, -- 164
		h, -- 164
		cam.x, -- 164
		time, -- 164
		spec, -- 164
		dynamicDawn, -- 164
		key == "escort2" -- 164
	) -- 164
	local mistShift = (time * 12 + cam.x * 0.16) % (w + 460) - 230 -- 167
	local mistCol = key == "escort3" and PALETTE.amberDim or PALETTE.jadeMist -- 168
	local mistOp = key == "escort4" and 0.24 or 0.17 -- 169
	backdropArt:tryPlace( -- 170
		"ink_mist_curve", -- 170
		"escort_mist_a", -- 170
		mistShift, -- 170
		h * 0.34, -- 170
		620, -- 170
		120, -- 170
		{ -- 170
			color = toColor(mistCol), -- 171
			opacity = mistOp, -- 171
			layer = 5 -- 171
		} -- 171
	) -- 171
	backdropArt:tryPlace( -- 173
		"ink_mist_curve", -- 173
		"escort_mist_b", -- 173
		(mistShift + w * 0.55) % (w + 460) - 230, -- 173
		h * 0.46, -- 173
		540, -- 173
		100, -- 173
		{ -- 173
			color = toColor(PALETTE.inkMist), -- 174
			opacity = mistOp * 0.85, -- 174
			layer = 5, -- 174
			facing = -1 -- 174
		} -- 174
	) -- 174
	if key == "escort1" then -- 174
		self:drawEscort1AlleySilhouettes(bgDraw, w, h, cam.x) -- 179
	elseif key == "escort2" then -- 179
		self:drawEscort2GranaryRafters( -- 181
			bgDraw, -- 181
			bgGlow, -- 181
			w, -- 181
			h, -- 181
			cam.x, -- 181
			time -- 181
		) -- 181
	elseif key == "escort3" then -- 181
		self:drawEscort3MountainShelterBg( -- 183
			bgDraw, -- 183
			bgGlow, -- 183
			w, -- 183
			h, -- 183
			cam.x, -- 183
			time -- 183
		) -- 183
	elseif key == "escort4" then -- 183
		self:drawEscort4CliffGorge( -- 185
			bgDraw, -- 185
			bgGlow, -- 185
			w, -- 185
			h, -- 185
			cam.x, -- 185
			time -- 185
		) -- 185
	elseif key == "escort5" then -- 185
		self:drawEscort5TowerApproachBg( -- 187
			bgDraw, -- 187
			bgGlow, -- 187
			w, -- 187
			h, -- 187
			cam.x, -- 187
			time, -- 187
			dynamicDawn -- 187
		) -- 187
	end -- 187
end -- 114
function EscortWorldRenderer.prototype.drawWorldSetpieces(self, fgDraw, fgGlow, worldArt, p, view, cam, time) -- 192
	local key = p.room.key -- 201
	if not ____exports.isEscortWorldRoom(key) then -- 201
		return -- 203
	end -- 203
	local ox = p.ox -- 205
	if key == "gatepath" then -- 205
		self:drawGatepathSetpieces( -- 208
			fgDraw, -- 208
			fgGlow, -- 208
			worldArt, -- 208
			p, -- 208
			view, -- 208
			cam, -- 208
			time, -- 208
			ox -- 208
		) -- 208
		return -- 209
	end -- 209
	if key == "escort1" then -- 209
		self:drawEscort1Setpieces( -- 212
			fgDraw, -- 212
			fgGlow, -- 212
			worldArt, -- 212
			p, -- 212
			cam, -- 212
			time, -- 212
			ox -- 212
		) -- 212
		return -- 213
	end -- 213
	if key == "escort2" then -- 213
		self:drawEscort2Setpieces( -- 216
			fgDraw, -- 216
			fgGlow, -- 216
			worldArt, -- 216
			p, -- 216
			cam, -- 216
			time, -- 216
			ox -- 216
		) -- 216
		return -- 217
	end -- 217
	if key == "escort3" then -- 217
		self:drawEscort3WorkbenchSanctuary( -- 220
			fgDraw, -- 220
			fgGlow, -- 220
			worldArt, -- 220
			p, -- 220
			view, -- 220
			cam, -- 220
			time, -- 220
			ox -- 220
		) -- 220
		return -- 221
	end -- 221
	if key == "escort4" then -- 221
		self:drawEscort4Setpieces( -- 224
			fgDraw, -- 224
			fgGlow, -- 224
			worldArt, -- 224
			p, -- 224
			cam, -- 224
			time, -- 224
			ox -- 224
		) -- 224
		return -- 225
	end -- 225
	if key == "escort5" then -- 225
		self:drawEscort5Setpieces( -- 228
			fgDraw, -- 228
			fgGlow, -- 228
			worldArt, -- 228
			p, -- 228
			cam, -- 228
			time, -- 228
			ox -- 228
		) -- 228
	end -- 228
end -- 192
function EscortWorldRenderer.prototype.drawForegroundFraming(self, fgDraw, _fgGlow, worldArt, p, cam, time) -- 233
	local key = p.room.key -- 241
	if not ____exports.isEscortWorldRoom(key) then -- 241
		return -- 243
	end -- 243
	local w = cam.viewW -- 245
	local h = cam.viewH -- 246
	local parallaxX = cam.x * 1.26 -- 247
	local sway = math.sin(time * 1.6) * 4 -- 248
	if key == "escort2" then -- 248
		fgDraw:drawRect( -- 253
			Rect(0, h - 34, w, 34), -- 253
			Color(10, 12, 16, 205) -- 253
		) -- 253
		fgDraw:drawSegment( -- 254
			Vec2(0, h - 34), -- 254
			Vec2(w, h - 34), -- 254
			1.6, -- 254
			Color(58, 46, 36, 155) -- 254
		) -- 254
		do -- 254
			local rx = -40 -- 255
			while rx < w + 80 do -- 255
				local bx = rx - parallaxX * 0.18 % 160 -- 256
				fgDraw:drawRect( -- 257
					Rect(bx, h - 46, 14, 46), -- 257
					Color(14, 12, 11, 190) -- 257
				) -- 257
				rx = rx + 160 -- 255
			end -- 255
		end -- 255
	elseif key == "escort3" or key == "escort4" or key == "escort5" then -- 255
		worldArt:tryPlace( -- 261
			"grass_low", -- 261
			"escort_fg_bush_l", -- 261
			78 + sway * 0.4, -- 261
			-4, -- 261
			190, -- 261
			48, -- 261
			{ -- 261
				color = Color(10, 14, 18, 255), -- 262
				opacity = 0.78, -- 262
				layer = 5200 -- 262
			} -- 262
		) -- 262
		worldArt:tryPlace( -- 264
			"grass_low", -- 264
			"escort_fg_bush_r", -- 264
			w - 82 - sway * 0.35, -- 264
			-4, -- 264
			198, -- 264
			52, -- 264
			{ -- 264
				color = Color(10, 14, 18, 255), -- 265
				opacity = 0.78, -- 265
				layer = 5200, -- 265
				facing = -1 -- 265
			} -- 265
		) -- 265
	end -- 265
	local stride = 260 -- 270
	local startSlot = math.floor((parallaxX - 200) / stride) -- 271
	do -- 271
		local s = startSlot -- 272
		while s <= startSlot + 6 do -- 272
			do -- 272
				local sx = s * stride - parallaxX + w * 0.5 -- 273
				if sx < -140 or sx > w + 140 then -- 273
					goto __continue43 -- 275
				end -- 275
				local hSeed = math.abs(math.sin(s * 12.9898) * 43758.5453) % 1 -- 277
				local rockH = 16 + hSeed * 18 -- 278
				local rockW = 46 + hSeed * 42 -- 279
				fgDraw:drawPolygon( -- 280
					{ -- 280
						Vec2(sx - rockW * 0.5, 0), -- 281
						Vec2(sx + rockW * 0.5, 0), -- 282
						Vec2(sx + rockW * 0.25 + sway * 0.2, rockH), -- 283
						Vec2(sx - rockW * 0.3 + sway * 0.2, rockH * 0.82) -- 284
					}, -- 284
					Color(8, 10, 14, 196) -- 285
				) -- 285
			end -- 285
			::__continue43:: -- 285
			s = s + 1 -- 272
		end -- 272
	end -- 272
end -- 233
function EscortWorldRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, camX, time, spec, dawnWarmth, behindWindow) -- 291
	local s = spec.scale -- 302
	local tx = w * spec.screenXFrac - camX * 0.045 -- 303
	local ty = h * spec.screenYFrac -- 304
	local pulse = 0.86 + 0.14 * math.sin(time * 2.5) -- 305
	local alphaMul = behindWindow and 0.62 or 1 -- 306
	local ridgeW = 190 * s + 95 -- 309
	local ridgeH = 44 * s + 22 -- 310
	local ridgeCol = Color( -- 311
		math.floor(20 + dawnWarmth * 16 + 0.5), -- 312
		math.floor(26 + dawnWarmth * 14 + 0.5), -- 313
		math.floor(38 + dawnWarmth * 8 + 0.5), -- 314
		math.floor(188 * alphaMul + 0.5) -- 315
	) -- 315
	bgDraw:drawPolygon( -- 317
		{ -- 317
			Vec2(tx - ridgeW, ty - ridgeH), -- 318
			Vec2(tx + ridgeW * 0.72, ty - ridgeH), -- 319
			Vec2(tx + ridgeW * 0.16, ty + 6 * s), -- 320
			Vec2(tx - ridgeW * 0.32, ty + 2 * s) -- 321
		}, -- 321
		ridgeCol -- 322
	) -- 322
	local baseW = 44 * s -- 325
	local topW = 34 * s -- 326
	local bodyH = 62 * s -- 327
	local towerCol = Color( -- 328
		math.floor(24 + dawnWarmth * 14 + 0.5), -- 329
		math.floor(30 + dawnWarmth * 12 + 0.5), -- 330
		math.floor(42 + dawnWarmth * 8 + 0.5), -- 331
		math.floor(225 * alphaMul + 0.5) -- 332
	) -- 332
	local rimCol = Color( -- 334
		138, -- 334
		148, -- 334
		166, -- 334
		math.floor(68 * alphaMul + 0.5) -- 334
	) -- 334
	bgDraw:drawPolygon( -- 335
		{ -- 335
			Vec2(tx - baseW * 0.5, ty - 4 * s), -- 336
			Vec2(tx + baseW * 0.5, ty - 4 * s), -- 337
			Vec2(tx + topW * 0.5, ty + bodyH), -- 338
			Vec2(tx - topW * 0.5, ty + bodyH) -- 339
		}, -- 339
		towerCol, -- 340
		0.8, -- 340
		rimCol -- 340
	) -- 340
	local pavH = 18 * s -- 343
	local eaveY = ty + bodyH + pavH -- 344
	local eaveW = 54 * s -- 345
	bgDraw:drawRect( -- 346
		Rect(tx - topW * 0.38, ty + bodyH, 3 * s, pavH), -- 346
		towerCol -- 346
	) -- 346
	bgDraw:drawRect( -- 347
		Rect(tx + topW * 0.38 - 3 * s, ty + bodyH, 3 * s, pavH), -- 347
		towerCol -- 347
	) -- 347
	bgDraw:drawPolygon( -- 348
		{ -- 348
			Vec2(tx - eaveW * 0.54, eaveY - 2 * s), -- 349
			Vec2(tx + eaveW * 0.54, eaveY - 2 * s), -- 350
			Vec2(tx + eaveW * 0.24, eaveY + 13 * s), -- 351
			Vec2(tx - eaveW * 0.24, eaveY + 13 * s) -- 352
		}, -- 352
		Color( -- 353
			18, -- 353
			22, -- 353
			32, -- 353
			math.floor(238 * alphaMul + 0.5) -- 353
		), -- 353
		0.8, -- 353
		rimCol -- 353
	) -- 353
	local lampX = tx - topW * 0.14 -- 356
	local lampY = ty + bodyH * 0.64 -- 357
	local glowR = spec.beaconR * pulse -- 358
	fillRadialGlow( -- 359
		bgGlow, -- 359
		lampX, -- 359
		lampY, -- 359
		glowR * 1.35, -- 359
		glowR, -- 359
		Color( -- 360
			255, -- 360
			206, -- 360
			122, -- 360
			math.floor(92 * pulse * alphaMul + 0.5) -- 360
		), -- 360
		Color(255, 178, 86, 0), -- 361
		16 -- 361
	) -- 361
	fillRadialGlow( -- 362
		bgGlow, -- 362
		lampX, -- 362
		lampY, -- 362
		glowR * 0.48, -- 362
		glowR * 0.42, -- 362
		Color( -- 363
			255, -- 363
			238, -- 363
			184, -- 363
			math.floor(176 * pulse * alphaMul + 0.5) -- 363
		), -- 363
		Color(255, 204, 118, 0), -- 364
		12 -- 364
	) -- 364
	bgGlow:drawDot( -- 365
		Vec2(lampX, lampY), -- 365
		math.max(1.8, 3.6 * s), -- 365
		Color( -- 365
			255, -- 365
			246, -- 365
			212, -- 365
			math.floor(248 * alphaMul + 0.5) -- 365
		) -- 365
	) -- 365
end -- 291
function EscortWorldRenderer.prototype.drawEscort1AlleySilhouettes(self, bgDraw, w, h, camX) -- 370
	local shift = camX * 0.38 -- 371
	local houses = {{x = 140, bw = 165, bh = 165, roof = 36}, {x = 430, bw = 190, bh = 195, roof = 42}, {x = 760, bw = 145, bh = 150, roof = 30}, {x = 1080, bw = 210, bh = 185, roof = 40}} -- 372
	for ____, hs in ipairs(houses) do -- 378
		local sx = ((hs.x - shift) % (w + 340) + (w + 340)) % (w + 340) - 170 -- 379
		local base = h * 0.25 -- 380
		bgDraw:drawRect( -- 381
			Rect(sx, base, hs.bw, hs.bh), -- 381
			Color(16, 20, 29, 175) -- 381
		) -- 381
		bgDraw:drawPolygon( -- 382
			{ -- 382
				Vec2(sx - 16, base + hs.bh), -- 383
				Vec2(sx + hs.bw + 16, base + hs.bh), -- 384
				Vec2(sx + hs.bw * 0.78, base + hs.bh + hs.roof), -- 385
				Vec2(sx + hs.bw * 0.22, base + hs.bh + hs.roof) -- 386
			}, -- 386
			Color(12, 15, 22, 195) -- 387
		) -- 387
	end -- 387
end -- 370
function EscortWorldRenderer.prototype.drawEscort2GranaryRafters(self, bgDraw, bgGlow, w, h, camX, time) -- 391
	local shift = camX * 0.42 -- 399
	bgDraw:drawRect( -- 401
		Rect(0, h * 0.8, w, h * 0.2), -- 401
		Color(12, 14, 20, 192) -- 401
	) -- 401
	local span = 290 -- 402
	local first = math.floor((shift - 180) / span) -- 403
	do -- 403
		local k = first -- 404
		while k <= first + 6 do -- 404
			local bx = k * span - shift -- 405
			bgDraw:drawRect( -- 407
				Rect(bx - 9, h * 0.2, 18, h * 0.62), -- 407
				Color(22, 19, 17, 165) -- 407
			) -- 407
			bgDraw:drawSegment( -- 409
				Vec2(bx, h * 0.82), -- 409
				Vec2(bx + span * 0.5, h * 0.96), -- 409
				7, -- 409
				Color(26, 21, 18, 185) -- 409
			) -- 409
			bgDraw:drawSegment( -- 410
				Vec2(bx + span, h * 0.82), -- 410
				Vec2(bx + span * 0.5, h * 0.96), -- 410
				7, -- 410
				Color(26, 21, 18, 185) -- 410
			) -- 410
			if math.abs(k) % 2 == 0 then -- 410
				local topX = bx + span * 0.44 -- 413
				local pulse = 0.86 + 0.14 * math.sin(time * 1.1 + k) -- 414
				local midA = math.floor(30 * pulse + 0.5) -- 415
				local topA = math.floor(14 * pulse + 0.5) -- 416
				fillGradQuad( -- 417
					bgGlow, -- 418
					topX - 20, -- 419
					h + 10, -- 419
					Color(168, 194, 224, topA), -- 419
					topX + 36, -- 420
					h + 10, -- 420
					Color(168, 194, 224, topA), -- 420
					topX + 94, -- 421
					h * 0.48, -- 421
					Color(176, 202, 232, midA), -- 421
					topX + 8, -- 422
					h * 0.48, -- 422
					Color(176, 202, 232, midA) -- 422
				) -- 422
				fillGradQuad( -- 424
					bgGlow, -- 425
					topX + 8, -- 426
					h * 0.48, -- 426
					Color(176, 202, 232, midA), -- 426
					topX + 94, -- 427
					h * 0.48, -- 427
					Color(176, 202, 232, midA), -- 427
					topX + 136, -- 428
					h * 0.14, -- 428
					Color(168, 194, 224, 0), -- 428
					topX + 30, -- 429
					h * 0.14, -- 429
					Color(168, 194, 224, 0) -- 429
				) -- 429
				do -- 429
					local d = 0 -- 432
					while d < 4 do -- 432
						local phase = (time * 0.18 + d * 0.27 + k * 0.31) % 1 -- 433
						local dx = topX + 12 + phase * 76 + math.sin(time * 1.4 + d) * 8 -- 434
						local dy = h * (0.9 - phase * 0.68) -- 435
						bgGlow:drawDot( -- 436
							Vec2(dx, dy), -- 436
							1.6, -- 436
							Color( -- 436
								214, -- 436
								222, -- 436
								232, -- 436
								math.floor(62 * math.sin(phase * math.pi) + 0.5) -- 436
							) -- 436
						) -- 436
						d = d + 1 -- 432
					end -- 432
				end -- 432
			end -- 432
			k = k + 1 -- 404
		end -- 404
	end -- 404
end -- 391
function EscortWorldRenderer.prototype.drawEscort3MountainShelterBg(self, bgDraw, bgGlow, w, h, camX, time) -- 442
	local cliffX = 120 - camX * 0.28 -- 451
	bgDraw:drawPolygon( -- 452
		{ -- 452
			Vec2(cliffX - 240, h * 0.18), -- 453
			Vec2(cliffX + 260, h * 0.18), -- 454
			Vec2(cliffX + 165, h * 0.68), -- 455
			Vec2(cliffX - 180, h * 0.86) -- 456
		}, -- 456
		Color(14, 18, 25, 165) -- 457
	) -- 457
	local warmPulse = 0.9 + 0.1 * math.sin(time * 2.1) -- 459
	fillRadialGlow( -- 460
		bgGlow, -- 460
		w * 0.5, -- 460
		h * 0.36, -- 460
		w * 0.26, -- 460
		h * 0.26, -- 460
		Color( -- 461
			224, -- 461
			164, -- 461
			88, -- 461
			math.floor(32 * warmPulse + 0.5) -- 461
		), -- 461
		Color(224, 164, 88, 0), -- 461
		16 -- 461
	) -- 461
end -- 442
function EscortWorldRenderer.prototype.drawEscort4CliffGorge(self, bgDraw, bgGlow, w, h, camX, time) -- 464
	local shift = camX * 0.32 -- 473
	do -- 473
		local i = 0 -- 474
		while i < 4 do -- 474
			local px = ((i * 380 - shift) % (w + 420) + (w + 420)) % (w + 420) - 210 -- 475
			bgDraw:drawPolygon( -- 476
				{ -- 476
					Vec2(px - 120, h * 0.2), -- 477
					Vec2(px + 145, h * 0.2), -- 478
					Vec2(px + 48, h * (0.58 + i % 2 * 0.12)), -- 479
					Vec2(px - 58, h * (0.5 + i % 2 * 0.08)) -- 480
				}, -- 480
				Color(16, 22, 33, 152) -- 481
			) -- 481
			i = i + 1 -- 474
		end -- 474
	end -- 474
	local cloudX = time * 24 % (w + 400) - 200 -- 484
	bgGlow:drawPolygon( -- 485
		{ -- 485
			Vec2(cloudX, h * 0.78), -- 486
			Vec2(cloudX + 240, h * 0.82), -- 487
			Vec2(cloudX + 210, h * 0.87), -- 488
			Vec2(cloudX - 20, h * 0.83) -- 489
		}, -- 489
		Color(142, 164, 192, 24) -- 490
	) -- 490
end -- 464
function EscortWorldRenderer.prototype.drawEscort5TowerApproachBg(self, bgDraw, bgGlow, w, h, camX, time, dawnWarmth) -- 493
	local glowPulse = 0.88 + 0.12 * math.sin(time * 1.8) -- 503
	fillRadialGlow( -- 504
		bgGlow, -- 504
		w * 0.78, -- 504
		h * 0.48, -- 504
		w * 0.42, -- 504
		h * 0.3, -- 504
		Color( -- 505
			228, -- 505
			184, -- 505
			132, -- 505
			math.floor(44 * dawnWarmth * glowPulse + 0.5) -- 505
		), -- 505
		Color(228, 184, 132, 0), -- 506
		18 -- 506
	) -- 506
	local shift = camX * 0.3 -- 508
	bgDraw:drawPolygon( -- 509
		{ -- 509
			Vec2(0, h * 0.2), -- 510
			Vec2(w, h * 0.2), -- 511
			Vec2(w, h * 0.34), -- 512
			Vec2(w * 0.55 - shift % 120 * 0.2, h * 0.29), -- 513
			Vec2(0, h * 0.36) -- 514
		}, -- 514
		Color(18, 22, 32, 140) -- 515
	) -- 515
end -- 493
function EscortWorldRenderer.prototype.drawGatepathSetpieces(self, fgDraw, fgGlow, worldArt, p, view, cam, time, ox) -- 520
	local groundY = cam:sy(0) -- 530
	worldArt:tryPlace( -- 532
		"sh_stele_banner", -- 532
		"gp_banner_start", -- 532
		cam:sx(ox + 96), -- 532
		groundY, -- 532
		cam:len(68), -- 532
		cam:len(74), -- 532
		{layer = 1, opacity = 0.92} -- 532
	) -- 532
	worldArt:tryPlace( -- 535
		"sh_stele_banner", -- 535
		"gp_stele_mid", -- 535
		cam:sx(ox + 520), -- 535
		groundY, -- 535
		cam:len(54), -- 535
		cam:len(60), -- 535
		{layer = 1, opacity = 0.86, facing = -1} -- 535
	) -- 535
	local stepTopY = cam:sy(48) -- 539
	local lampX = cam:sx(ox + 912) -- 540
	local poleH = cam:len(58) -- 541
	fgDraw:drawSegment( -- 542
		Vec2(lampX, stepTopY), -- 542
		Vec2(lampX, stepTopY + poleH), -- 542
		math.max( -- 542
			1.8, -- 542
			cam:len(2.4) -- 542
		), -- 542
		Color(74, 54, 38, 240) -- 542
	) -- 542
	fgDraw:drawSegment( -- 543
		Vec2(lampX, stepTopY + poleH), -- 543
		Vec2( -- 543
			lampX - cam:len(14), -- 543
			stepTopY + poleH -- 543
		), -- 543
		math.max( -- 543
			1.5, -- 543
			cam:len(2) -- 543
		), -- 543
		Color(74, 54, 38, 240) -- 543
	) -- 543
	worldArt:tryPlace( -- 544
		"prop_lantern", -- 544
		"gp_top_lantern", -- 544
		lampX - cam:len(14), -- 544
		stepTopY + poleH - cam:len(14), -- 544
		cam:len(18), -- 544
		cam:len(22), -- 544
		{layer = 4} -- 544
	) -- 544
	local flame = 0.88 + 0.12 * math.sin(time * 3.1) -- 545
	fillRadialGlow( -- 546
		fgGlow, -- 546
		lampX - cam:len(14), -- 546
		stepTopY + poleH - cam:len(14), -- 546
		cam:len(54), -- 546
		cam:len(48), -- 546
		Color( -- 547
			246, -- 547
			192, -- 547
			114, -- 547
			math.floor(72 * flame + 0.5) -- 547
		), -- 547
		Color(246, 192, 114, 0), -- 547
		16 -- 547
	) -- 547
	if p.phase == "gatepath-start" and p.partner.alive then -- 547
		local sx1 = cam:sx(p.player.x) -- 551
		local sx2 = cam:sx(p.partner.x) -- 552
		fgDraw:drawPolygon( -- 553
			{ -- 553
				Vec2( -- 554
					sx1 - cam:len(10), -- 554
					groundY + 1 -- 554
				), -- 554
				Vec2( -- 555
					sx1 + cam:len(10), -- 555
					groundY + 1 -- 555
				), -- 555
				Vec2( -- 556
					sx1 - cam:len(24), -- 556
					groundY - cam:len(10) -- 556
				), -- 556
				Vec2( -- 557
					sx1 - cam:len(40), -- 557
					groundY - cam:len(10) -- 557
				) -- 557
			}, -- 557
			Color(8, 10, 16, 86) -- 558
		) -- 558
		fgDraw:drawPolygon( -- 559
			{ -- 559
				Vec2( -- 560
					sx2 - cam:len(7), -- 560
					groundY + 1 -- 560
				), -- 560
				Vec2( -- 561
					sx2 + cam:len(7), -- 561
					groundY + 1 -- 561
				), -- 561
				Vec2( -- 562
					sx2 - cam:len(15), -- 562
					groundY - cam:len(7) -- 562
				), -- 562
				Vec2( -- 563
					sx2 - cam:len(26), -- 563
					groundY - cam:len(7) -- 563
				) -- 563
			}, -- 563
			Color(8, 10, 16, 78) -- 564
		) -- 564
	end -- 564
	if self.carryBloomT > 0 or view.backCarry.mounting then -- 564
		local k = self.carryBloomT > 0 and clamp01(self.carryBloomT / 1.15) or 0.72 -- 569
		local bx = cam:sx(p.player.x) -- 570
		local by = cam:sy(p.player.y + 42) -- 571
		fillRadialGlow( -- 572
			fgGlow, -- 572
			bx, -- 572
			by, -- 572
			cam:len(96), -- 572
			cam:len(72), -- 572
			Color( -- 573
				244, -- 573
				206, -- 573
				142, -- 573
				math.floor(62 * k + 0.5) -- 573
			), -- 573
			Color(244, 206, 142, 0), -- 573
			18 -- 573
		) -- 573
	end -- 573
end -- 520
function EscortWorldRenderer.prototype.drawEscort1Setpieces(self, fgDraw, fgGlow, worldArt, _p, cam, time, ox) -- 577
	local backDepth = LANE_DEPTH.upper + 16 -- 586
	local backY = cam:sy(0, backDepth) -- 587
	local backLayer = depthOrder(backDepth, -2) -- 588
	worldArt:tryPlace( -- 590
		"sh_stele_banner", -- 590
		"e1_banner_a", -- 590
		cam:sx(ox + 150), -- 590
		backY, -- 590
		cam:len(68), -- 590
		cam:len(76), -- 590
		{layer = backLayer, opacity = 0.9} -- 590
	) -- 590
	worldArt:tryPlace( -- 593
		"sh_stele_banner", -- 593
		"e1_banner_b", -- 593
		cam:sx(ox + 1245), -- 593
		backY, -- 593
		cam:len(64), -- 593
		cam:len(70), -- 593
		{layer = backLayer, opacity = 0.88, facing = -1} -- 593
	) -- 593
	local emberSpots = {285, 860} -- 597
	do -- 597
		local i = 0 -- 598
		while i < #emberSpots do -- 598
			local bx = cam:sx(ox + emberSpots[i + 1]) -- 599
			local pulse = 0.82 + 0.18 * math.sin(time * 4.2 + i * 1.9) -- 600
			fgDraw:drawPolygon( -- 601
				{ -- 601
					Vec2( -- 602
						bx - cam:len(12), -- 602
						backY + cam:len(14) -- 602
					), -- 602
					Vec2( -- 603
						bx + cam:len(12), -- 603
						backY + cam:len(14) -- 603
					), -- 603
					Vec2( -- 604
						bx + cam:len(8), -- 604
						backY + cam:len(4) -- 604
					), -- 604
					Vec2( -- 605
						bx - cam:len(8), -- 605
						backY + cam:len(4) -- 605
					) -- 605
				}, -- 605
				Color(38, 34, 34, 240), -- 606
				1, -- 606
				Color(88, 72, 62, 180) -- 606
			) -- 606
			fgDraw:drawSegment( -- 607
				Vec2( -- 607
					bx - cam:len(9), -- 607
					backY -- 607
				), -- 607
				Vec2( -- 607
					bx - cam:len(6), -- 607
					backY + cam:len(6) -- 607
				), -- 607
				2, -- 607
				Color(34, 30, 30, 235) -- 607
			) -- 607
			fgDraw:drawSegment( -- 608
				Vec2( -- 608
					bx + cam:len(9), -- 608
					backY -- 608
				), -- 608
				Vec2( -- 608
					bx + cam:len(6), -- 608
					backY + cam:len(6) -- 608
				), -- 608
				2, -- 608
				Color(34, 30, 30, 235) -- 608
			) -- 608
			fgGlow:drawEllipse( -- 609
				Vec2( -- 609
					bx, -- 609
					backY + cam:len(14) -- 609
				), -- 609
				cam:len(9), -- 609
				cam:len(3.5), -- 609
				Color( -- 609
					236, -- 609
					114, -- 609
					48, -- 609
					math.floor(185 * pulse + 0.5) -- 609
				) -- 609
			) -- 609
			fillRadialGlow( -- 610
				fgGlow, -- 610
				bx, -- 610
				backY + cam:len(18), -- 610
				cam:len(48), -- 610
				cam:len(36), -- 610
				Color( -- 611
					226, -- 611
					116, -- 611
					52, -- 611
					math.floor(62 * pulse + 0.5) -- 611
				), -- 611
				Color(226, 116, 52, 0), -- 611
				14 -- 611
			) -- 611
			i = i + 1 -- 598
		end -- 598
	end -- 598
end -- 577
function EscortWorldRenderer.prototype.drawEscort2Setpieces(self, fgDraw, fgGlow, worldArt, p, cam, time, ox) -- 615
	local backDepth = LANE_DEPTH.upper + 16 -- 624
	local backY = cam:sy(0, backDepth) -- 625
	local backLayer = depthOrder(backDepth, -2) -- 626
	local sackSpots = {195, 480, 1020, 1310} -- 628
	do -- 628
		local i = 0 -- 629
		while i < #sackSpots do -- 629
			local sx = cam:sx(ox + sackSpots[i + 1]) -- 630
			worldArt:tryPlace( -- 631
				"sh_grain_sacks", -- 631
				"e2_bg_sack_" .. tostring(i), -- 631
				sx, -- 631
				backY, -- 631
				cam:len(72), -- 631
				cam:len(44), -- 631
				{ -- 631
					layer = backLayer, -- 632
					opacity = 0.78, -- 633
					facing = i % 2 == 0 and 1 or -1, -- 634
					color = Color(172, 168, 162, 255) -- 635
				} -- 635
			) -- 635
			i = i + 1 -- 629
		end -- 629
	end -- 629
	local beamY = cam:sy(64, -24) -- 639
	local drapeX = cam:sx(ox + 440) -- 640
	local sway = math.sin(time * 1.9) * 3 -- 641
	fgDraw:drawPolygon( -- 642
		{ -- 642
			Vec2( -- 643
				drapeX - cam:len(22), -- 643
				beamY -- 643
			), -- 643
			Vec2( -- 644
				drapeX + cam:len(22), -- 644
				beamY -- 644
			), -- 644
			Vec2( -- 645
				drapeX + cam:len(18) + sway, -- 645
				beamY - cam:len(24) -- 645
			), -- 645
			Vec2( -- 646
				drapeX - cam:len(14) + sway * 0.7, -- 646
				beamY - cam:len(19) -- 646
			) -- 646
		}, -- 646
		Color(72, 58, 46, 160) -- 647
	) -- 647
	for ____, pk in ipairs(p.pickups) do -- 650
		do -- 650
			if pk.id == "" or p.run.taken[pk.id] then -- 650
				goto __continue69 -- 652
			end -- 652
			local px = cam:sx(pk.x) -- 654
			local py = cam:sy(pk.y + 10, pk.depth or 0) -- 655
			local pulse = 0.78 + 0.22 * math.sin(time * 3 + pk.x * 0.02) -- 656
			local col = pk.kind == "bell" and Color( -- 657
				238, -- 657
				204, -- 657
				136, -- 657
				math.floor(78 * pulse + 0.5) -- 657
			) or Color( -- 657
				224, -- 657
				168, -- 657
				92, -- 657
				math.floor(72 * pulse + 0.5) -- 657
			) -- 657
			fillRadialGlow( -- 658
				fgGlow, -- 658
				px, -- 658
				py, -- 658
				cam:len(22), -- 658
				cam:len(18), -- 658
				col, -- 658
				Color(224, 168, 92, 0), -- 658
				12 -- 658
			) -- 658
		end -- 658
		::__continue69:: -- 658
	end -- 658
end -- 615
function EscortWorldRenderer.prototype.drawEscort3WorkbenchSanctuary(self, fgDraw, fgGlow, worldArt, p, view, cam, time, ox) -- 662
	local pulse = 0.88 + 0.12 * math.sin(time * 2.6) -- 672
	local benchCx = cam:sx(ox + 620) -- 673
	local benchDepth = LANE_DEPTH.middle + 10 -- 674
	local benchBaseY = cam:sy(0, benchDepth) -- 675
	local benchLayer = depthOrder(benchDepth, 2) -- 676
	fillRadialGlow( -- 679
		fgGlow, -- 679
		benchCx, -- 679
		benchBaseY + cam:len(42), -- 679
		cam:len(168), -- 679
		cam:len(112), -- 679
		Color( -- 680
			246, -- 680
			184, -- 680
			96, -- 680
			math.floor(76 * pulse + 0.5) -- 680
		), -- 680
		Color(246, 168, 74, 0), -- 680
		20 -- 680
	) -- 680
	fillRadialGlow( -- 681
		fgGlow, -- 681
		benchCx - cam:len(22), -- 681
		benchBaseY + cam:len(68), -- 681
		cam:len(58), -- 681
		cam:len(48), -- 681
		Color( -- 682
			255, -- 682
			224, -- 682
			152, -- 682
			math.floor(115 * pulse + 0.5) -- 682
		), -- 682
		Color(255, 198, 108, 0), -- 682
		14 -- 682
	) -- 682
	worldArt:tryPlace( -- 685
		"sh_craft_workbench", -- 685
		"e3_sanctuary_bench", -- 685
		benchCx, -- 685
		benchBaseY - cam:len(4), -- 685
		cam:len(142), -- 685
		cam:len(112), -- 685
		{layer = benchLayer} -- 685
	) -- 685
	local matX = cam:sx(ox + 516) -- 690
	local matDepth = LANE_DEPTH.middle + 4 -- 691
	local matY = cam:sy(0, matDepth) -- 692
	worldArt:tryPlace( -- 693
		"sh_straw_mat", -- 693
		"e3_xiaoman_mat", -- 693
		matX, -- 693
		matY - cam:len(2), -- 693
		cam:len(66), -- 693
		cam:len(28), -- 693
		{layer = depthOrder(matDepth, 0)} -- 693
	) -- 693
	if view.backCarry.atBench or view.craftBench.active then -- 693
		fillRadialGlow( -- 698
			fgGlow, -- 698
			matX, -- 698
			matY + cam:len(22), -- 698
			cam:len(42), -- 698
			cam:len(34), -- 698
			Color( -- 699
				252, -- 699
				212, -- 699
				138, -- 699
				math.floor(68 * pulse + 0.5) -- 699
			), -- 699
			Color(252, 212, 138, 0), -- 699
			14 -- 699
		) -- 699
	end -- 699
	worldArt:tryPlace( -- 703
		"sh_stele_banner", -- 703
		"e3_entry_stele", -- 703
		cam:sx(ox + 235), -- 703
		cam:sy(0, LANE_DEPTH.upper + 16), -- 703
		cam:len(58), -- 703
		cam:len(66), -- 703
		{ -- 703
			layer = depthOrder(LANE_DEPTH.upper + 16, -1), -- 704
			opacity = 0.86 -- 704
		} -- 704
	) -- 704
	do -- 704
		local i = 0 -- 708
		while i < #p.enemies do -- 708
			do -- 708
				local en = p.enemies[i + 1] -- 709
				if en.kind ~= "target" then -- 709
					goto __continue75 -- 711
				end -- 711
				local tx = cam:sx(en.x) -- 713
				local ty = cam:sy(en.y, en.depth or 0) -- 714
				local swayK = self.gongSway[i] or 0 -- 715
				if swayK > 0.05 then -- 715
					local ringR = cam:len(18 + (1 - swayK) * 44) -- 717
					fgGlow:drawRing( -- 718
						Vec2( -- 718
							tx, -- 718
							ty + cam:len(32) -- 718
						), -- 718
						math.max(1, ringR - 1.5), -- 718
						ringR, -- 718
						Color(0, 0, 0, 0), -- 719
						1.4, -- 719
						toColor( -- 719
							PALETTE.amber, -- 719
							math.floor(190 * swayK + 0.5) -- 719
						) -- 719
					) -- 719
				end -- 719
			end -- 719
			::__continue75:: -- 719
			i = i + 1 -- 708
		end -- 708
	end -- 708
end -- 662
function EscortWorldRenderer.prototype.drawEscort4Setpieces(self, fgDraw, fgGlow, worldArt, p, cam, time, ox) -- 724
	local backDepth = LANE_DEPTH.upper + 16 -- 733
	local backY = cam:sy(0, backDepth) -- 734
	local backLayer = depthOrder(backDepth, -2) -- 735
	worldArt:tryPlace( -- 737
		"sh_stele_banner", -- 737
		"e4_stele_a", -- 737
		cam:sx(ox + 210), -- 737
		backY, -- 737
		cam:len(58), -- 737
		cam:len(66), -- 737
		{layer = backLayer, opacity = 0.9} -- 737
	) -- 737
	worldArt:tryPlace( -- 740
		"sh_stele_banner", -- 740
		"e4_stele_b", -- 740
		cam:sx(ox + 990), -- 740
		backY, -- 740
		cam:len(56), -- 740
		cam:len(64), -- 740
		{layer = backLayer, opacity = 0.88, facing = -1} -- 740
	) -- 740
	local pineXs = {310, 740, 1210} -- 744
	do -- 744
		local i = 0 -- 745
		while i < #pineXs do -- 745
			worldArt:tryPlace( -- 746
				"pine", -- 746
				"e4_cliff_pine_" .. tostring(i), -- 746
				cam:sx(ox + pineXs[i + 1]), -- 746
				backY - cam:len(4), -- 746
				cam:len(112), -- 746
				cam:len(98), -- 746
				{ -- 746
					layer = backLayer - 1, -- 747
					opacity = 0.72, -- 747
					facing = i % 2 == 0 and 1 or -1, -- 747
					color = Color(138, 152, 168, 255) -- 747
				} -- 747
			) -- 747
			i = i + 1 -- 745
		end -- 745
	end -- 745
	do -- 745
		local i = 0 -- 751
		while i < #p.enemies do -- 751
			do -- 751
				local en = p.enemies[i + 1] -- 752
				if not en.alive or en.kind ~= "gunner" then -- 752
					goto __continue82 -- 754
				end -- 754
				local gx = cam:sx(en.x - 10) -- 756
				local gy = cam:sy(en.y + en.h * 0.62, en.depth or 0) -- 757
				local ember = 0.72 + 0.28 * math.sin(time * 7.5 + i * 2.1) -- 758
				fgGlow:drawDot( -- 759
					Vec2(gx, gy), -- 759
					2.3, -- 759
					Color( -- 759
						255, -- 759
						134, -- 759
						62, -- 759
						math.floor(215 * ember + 0.5) -- 759
					) -- 759
				) -- 759
				fillRadialGlow( -- 760
					fgGlow, -- 760
					gx, -- 760
					gy, -- 760
					14, -- 760
					14, -- 760
					Color( -- 760
						242, -- 760
						108, -- 760
						46, -- 760
						math.floor(64 * ember + 0.5) -- 760
					), -- 760
					Color(242, 108, 46, 0), -- 760
					10 -- 760
				) -- 760
			end -- 760
			::__continue82:: -- 760
			i = i + 1 -- 751
		end -- 751
	end -- 751
	fgDraw:drawSegment( -- 763
		Vec2( -- 763
			cam:sx(ox + 500), -- 763
			backY + cam:len(4) -- 763
		), -- 763
		Vec2( -- 763
			cam:sx(ox + 900), -- 763
			backY + cam:len(4) -- 763
		), -- 763
		1, -- 763
		Color(110, 124, 142, 48) -- 763
	) -- 763
end -- 724
function EscortWorldRenderer.prototype.drawEscort5Setpieces(self, fgDraw, fgGlow, worldArt, _p, cam, time, ox) -- 766
	local backDepth = LANE_DEPTH.upper + 16 -- 775
	local backY = cam:sy(0, backDepth) -- 776
	local backLayer = depthOrder(backDepth, -2) -- 777
	worldArt:tryPlace( -- 779
		"sh_stele_banner", -- 779
		"e5_stele_a", -- 779
		cam:sx(ox + 215), -- 779
		backY, -- 779
		cam:len(62), -- 779
		cam:len(70), -- 779
		{layer = backLayer, opacity = 0.92} -- 779
	) -- 779
	worldArt:tryPlace( -- 782
		"pine", -- 782
		"e5_pine_a", -- 782
		cam:sx(ox + 640), -- 782
		backY - cam:len(4), -- 782
		cam:len(118), -- 782
		cam:len(102), -- 782
		{ -- 782
			layer = backLayer - 1, -- 783
			opacity = 0.78, -- 783
			color = Color(156, 168, 182, 255) -- 783
		} -- 783
	) -- 783
	local lx = cam:sx(ox + 1315) -- 786
	local poleTop = backY + cam:len(68) -- 787
	local flame = 0.88 + 0.12 * math.sin(time * 2.9) -- 788
	fgDraw:drawSegment( -- 789
		Vec2(lx, backY), -- 789
		Vec2(lx, poleTop), -- 789
		math.max( -- 789
			1.8, -- 789
			cam:len(2.4) -- 789
		), -- 789
		Color(76, 56, 40, 240) -- 789
	) -- 789
	fgDraw:drawSegment( -- 790
		Vec2(lx, poleTop), -- 790
		Vec2( -- 790
			lx - cam:len(15), -- 790
			poleTop -- 790
		), -- 790
		math.max( -- 790
			1.6, -- 790
			cam:len(2) -- 790
		), -- 790
		Color(76, 56, 40, 240) -- 790
	) -- 790
	worldArt:tryPlace( -- 791
		"prop_lantern", -- 791
		"e5_approach_lamp", -- 791
		lx - cam:len(15), -- 791
		poleTop - cam:len(14), -- 791
		cam:len(20), -- 791
		cam:len(24), -- 791
		{layer = backLayer + 2} -- 791
	) -- 791
	fillRadialGlow( -- 794
		fgGlow, -- 794
		lx - cam:len(15), -- 794
		poleTop - cam:len(14), -- 794
		cam:len(74), -- 794
		cam:len(62), -- 794
		Color( -- 795
			255, -- 795
			206, -- 795
			128, -- 795
			math.floor(92 * flame + 0.5) -- 795
		), -- 795
		Color(255, 182, 88, 0), -- 795
		16 -- 795
	) -- 795
end -- 766
return ____exports -- 766