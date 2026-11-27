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
	local ridgePath = "assets/art/bg_escort_ridge.png" -- 164
	local ridge = backdropArt:currentSprite("ming_fallback_scene", ridgePath) or backdropArt:currentSprite("scene", ridgePath) -- 165
	local paintedWindow -- 166
	if ridge ~= nil and ridge.visible and ridge.opacity > 0 then -- 166
		local x = ridge.x + (568 / 640 - ridge.anchor.x) * ridge.width * ridge.scaleX -- 169
		local y = ridge.y + (1 - 51 / 360 - ridge.anchor.y) * ridge.height * ridge.scaleY -- 170
		if x >= 0 and x <= w and y >= 0 and y <= h then -- 170
			paintedWindow = Vec2(x, y) -- 171
		end -- 171
	end -- 171
	self:drawDistantNorthTower( -- 173
		towerDraw, -- 173
		bgGlow, -- 173
		w, -- 173
		h, -- 173
		cam.x, -- 173
		time, -- 173
		spec, -- 173
		dynamicDawn, -- 173
		key == "escort2", -- 173
		paintedWindow -- 173
	) -- 173
	local mistShift = (time * 12 + cam.x * 0.16) % (w + 460) - 230 -- 176
	local mistCol = key == "escort3" and PALETTE.amberDim or PALETTE.jadeMist -- 177
	local mistOp = key == "escort4" and 0.24 or 0.17 -- 178
	backdropArt:tryPlace( -- 179
		"ink_mist_curve", -- 179
		"escort_mist_a", -- 179
		mistShift, -- 179
		h * 0.34, -- 179
		620, -- 179
		120, -- 179
		{ -- 179
			color = toColor(mistCol), -- 180
			opacity = mistOp, -- 180
			layer = 5 -- 180
		} -- 180
	) -- 180
	backdropArt:tryPlace( -- 182
		"ink_mist_curve", -- 182
		"escort_mist_b", -- 182
		(mistShift + w * 0.55) % (w + 460) - 230, -- 182
		h * 0.46, -- 182
		540, -- 182
		100, -- 182
		{ -- 182
			color = toColor(PALETTE.inkMist), -- 183
			opacity = mistOp * 0.85, -- 183
			layer = 5, -- 183
			facing = -1 -- 183
		} -- 183
	) -- 183
	if key == "escort1" then -- 183
		self:drawEscort1AlleySilhouettes(bgDraw, w, h, cam.x) -- 188
	elseif key == "escort2" then -- 188
		self:drawEscort2GranaryRafters( -- 190
			bgDraw, -- 190
			bgGlow, -- 190
			w, -- 190
			h, -- 190
			cam.x, -- 190
			time -- 190
		) -- 190
	elseif key == "escort3" then -- 190
		self:drawEscort3MountainShelterBg( -- 192
			bgDraw, -- 192
			bgGlow, -- 192
			w, -- 192
			h, -- 192
			cam.x, -- 192
			time -- 192
		) -- 192
	elseif key == "escort4" then -- 192
		self:drawEscort4CliffGorge( -- 194
			bgDraw, -- 194
			bgGlow, -- 194
			w, -- 194
			h, -- 194
			cam.x, -- 194
			time -- 194
		) -- 194
	elseif key == "escort5" then -- 194
		self:drawEscort5TowerApproachBg( -- 196
			bgDraw, -- 196
			bgGlow, -- 196
			w, -- 196
			h, -- 196
			cam.x, -- 196
			time, -- 196
			dynamicDawn -- 196
		) -- 196
	end -- 196
end -- 114
function EscortWorldRenderer.prototype.drawWorldSetpieces(self, fgDraw, fgGlow, worldArt, p, view, cam, time) -- 201
	local key = p.room.key -- 210
	if not ____exports.isEscortWorldRoom(key) then -- 210
		return -- 212
	end -- 212
	local ox = p.ox -- 214
	if key == "gatepath" then -- 214
		self:drawGatepathSetpieces( -- 217
			fgDraw, -- 217
			fgGlow, -- 217
			worldArt, -- 217
			p, -- 217
			view, -- 217
			cam, -- 217
			time, -- 217
			ox -- 217
		) -- 217
		return -- 218
	end -- 218
	if key == "escort1" then -- 218
		self:drawEscort1Setpieces( -- 221
			fgDraw, -- 221
			fgGlow, -- 221
			worldArt, -- 221
			p, -- 221
			cam, -- 221
			time, -- 221
			ox -- 221
		) -- 221
		return -- 222
	end -- 222
	if key == "escort2" then -- 222
		self:drawEscort2Setpieces( -- 225
			fgDraw, -- 225
			fgGlow, -- 225
			worldArt, -- 225
			p, -- 225
			cam, -- 225
			time, -- 225
			ox -- 225
		) -- 225
		return -- 226
	end -- 226
	if key == "escort3" then -- 226
		self:drawEscort3WorkbenchSanctuary( -- 229
			fgDraw, -- 229
			fgGlow, -- 229
			worldArt, -- 229
			p, -- 229
			view, -- 229
			cam, -- 229
			time, -- 229
			ox -- 229
		) -- 229
		return -- 230
	end -- 230
	if key == "escort4" then -- 230
		self:drawEscort4Setpieces( -- 233
			fgDraw, -- 233
			fgGlow, -- 233
			worldArt, -- 233
			p, -- 233
			cam, -- 233
			time, -- 233
			ox -- 233
		) -- 233
		return -- 234
	end -- 234
	if key == "escort5" then -- 234
		self:drawEscort5Setpieces( -- 237
			fgDraw, -- 237
			fgGlow, -- 237
			worldArt, -- 237
			p, -- 237
			cam, -- 237
			time, -- 237
			ox -- 237
		) -- 237
	end -- 237
end -- 201
function EscortWorldRenderer.prototype.drawForegroundFraming(self, fgDraw, _fgGlow, worldArt, p, cam, time) -- 242
	local key = p.room.key -- 250
	if not ____exports.isEscortWorldRoom(key) then -- 250
		return -- 252
	end -- 252
	local w = cam.viewW -- 254
	local h = cam.viewH -- 255
	local parallaxX = cam.x * 1.26 -- 256
	local sway = math.sin(time * 1.6) * 4 -- 257
	if key == "escort2" then -- 257
		fgDraw:drawRect( -- 262
			Rect(0, h - 34, w, 34), -- 262
			Color(10, 12, 16, 205) -- 262
		) -- 262
		fgDraw:drawSegment( -- 263
			Vec2(0, h - 34), -- 263
			Vec2(w, h - 34), -- 263
			1.6, -- 263
			Color(58, 46, 36, 155) -- 263
		) -- 263
		do -- 263
			local rx = -40 -- 264
			while rx < w + 80 do -- 264
				local bx = rx - parallaxX * 0.18 % 160 -- 265
				fgDraw:drawRect( -- 266
					Rect(bx, h - 46, 14, 46), -- 266
					Color(14, 12, 11, 190) -- 266
				) -- 266
				rx = rx + 160 -- 264
			end -- 264
		end -- 264
	elseif key == "escort3" or key == "escort4" or key == "escort5" then -- 264
		worldArt:tryPlace( -- 270
			"grass_low", -- 270
			"escort_fg_bush_l", -- 270
			78 + sway * 0.4, -- 270
			-4, -- 270
			190, -- 270
			48, -- 270
			{ -- 270
				color = Color(10, 14, 18, 255), -- 271
				opacity = 0.78, -- 271
				layer = 5200 -- 271
			} -- 271
		) -- 271
		worldArt:tryPlace( -- 273
			"grass_low", -- 273
			"escort_fg_bush_r", -- 273
			w - 82 - sway * 0.35, -- 273
			-4, -- 273
			198, -- 273
			52, -- 273
			{ -- 273
				color = Color(10, 14, 18, 255), -- 274
				opacity = 0.78, -- 274
				layer = 5200, -- 274
				facing = -1 -- 274
			} -- 274
		) -- 274
	end -- 274
	local stride = 260 -- 279
	local startSlot = math.floor((parallaxX - 200) / stride) -- 280
	do -- 280
		local s = startSlot -- 281
		while s <= startSlot + 6 do -- 281
			do -- 281
				local sx = s * stride - parallaxX + w * 0.5 -- 282
				if sx < -140 or sx > w + 140 then -- 282
					goto __continue45 -- 284
				end -- 284
				local hSeed = math.abs(math.sin(s * 12.9898) * 43758.5453) % 1 -- 286
				local rockH = 16 + hSeed * 18 -- 287
				local rockW = 46 + hSeed * 42 -- 288
				fgDraw:drawPolygon( -- 289
					{ -- 289
						Vec2(sx - rockW * 0.5, 0), -- 290
						Vec2(sx + rockW * 0.5, 0), -- 291
						Vec2(sx + rockW * 0.25 + sway * 0.2, rockH), -- 292
						Vec2(sx - rockW * 0.3 + sway * 0.2, rockH * 0.82) -- 293
					}, -- 293
					Color(8, 10, 14, 196) -- 294
				) -- 294
			end -- 294
			::__continue45:: -- 294
			s = s + 1 -- 281
		end -- 281
	end -- 281
end -- 242
function EscortWorldRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, camX, time, spec, dawnWarmth, behindWindow, paintedWindow) -- 300
	local s = spec.scale -- 312
	local tx = w * spec.screenXFrac - camX * 0.045 -- 313
	local ty = h * spec.screenYFrac -- 314
	local pulse = 0.86 + 0.14 * math.sin(time * 2.5) -- 315
	local alphaMul = behindWindow and 0.62 or 1 -- 316
	local topW = 34 * s -- 318
	local bodyH = 62 * s -- 319
	if paintedWindow == nil then -- 319
		local ridgeW = 190 * s + 95 -- 322
		local ridgeH = 44 * s + 22 -- 323
		local ridgeCol = Color( -- 324
			math.floor(20 + dawnWarmth * 16 + 0.5), -- 325
			math.floor(26 + dawnWarmth * 14 + 0.5), -- 326
			math.floor(38 + dawnWarmth * 8 + 0.5), -- 327
			math.floor(188 * alphaMul + 0.5) -- 328
		) -- 328
		bgDraw:drawPolygon( -- 330
			{ -- 330
				Vec2(tx - ridgeW, ty - ridgeH), -- 331
				Vec2(tx + ridgeW * 0.72, ty - ridgeH), -- 332
				Vec2(tx + ridgeW * 0.16, ty + 6 * s), -- 333
				Vec2(tx - ridgeW * 0.32, ty + 2 * s) -- 334
			}, -- 334
			ridgeCol -- 335
		) -- 335
		local baseW = 44 * s -- 338
		local towerCol = Color( -- 339
			math.floor(24 + dawnWarmth * 14 + 0.5), -- 340
			math.floor(30 + dawnWarmth * 12 + 0.5), -- 341
			math.floor(42 + dawnWarmth * 8 + 0.5), -- 342
			math.floor(225 * alphaMul + 0.5) -- 343
		) -- 343
		local rimCol = Color( -- 345
			138, -- 345
			148, -- 345
			166, -- 345
			math.floor(68 * alphaMul + 0.5) -- 345
		) -- 345
		bgDraw:drawPolygon( -- 346
			{ -- 346
				Vec2(tx - baseW * 0.5, ty - 4 * s), -- 347
				Vec2(tx + baseW * 0.5, ty - 4 * s), -- 348
				Vec2(tx + topW * 0.5, ty + bodyH), -- 349
				Vec2(tx - topW * 0.5, ty + bodyH) -- 350
			}, -- 350
			towerCol, -- 351
			0.8, -- 351
			rimCol -- 351
		) -- 351
		local pavH = 18 * s -- 354
		local eaveY = ty + bodyH + pavH -- 355
		local eaveW = 54 * s -- 356
		bgDraw:drawRect( -- 357
			Rect(tx - topW * 0.38, ty + bodyH, 3 * s, pavH), -- 357
			towerCol -- 357
		) -- 357
		bgDraw:drawRect( -- 358
			Rect(tx + topW * 0.38 - 3 * s, ty + bodyH, 3 * s, pavH), -- 358
			towerCol -- 358
		) -- 358
		bgDraw:drawPolygon( -- 359
			{ -- 359
				Vec2(tx - eaveW * 0.54, eaveY - 2 * s), -- 360
				Vec2(tx + eaveW * 0.54, eaveY - 2 * s), -- 361
				Vec2(tx + eaveW * 0.24, eaveY + 13 * s), -- 362
				Vec2(tx - eaveW * 0.24, eaveY + 13 * s) -- 363
			}, -- 363
			Color( -- 364
				18, -- 364
				22, -- 364
				32, -- 364
				math.floor(238 * alphaMul + 0.5) -- 364
			), -- 364
			0.8, -- 364
			rimCol -- 364
		) -- 364
	end -- 364
	local lampX = paintedWindow and paintedWindow.x or tx - topW * 0.14 -- 368
	local lampY = paintedWindow and paintedWindow.y or ty + bodyH * 0.64 -- 369
	local glowR = spec.beaconR * pulse -- 370
	fillRadialGlow( -- 371
		bgGlow, -- 371
		lampX, -- 371
		lampY, -- 371
		glowR * 1.35, -- 371
		glowR, -- 371
		Color( -- 372
			255, -- 372
			206, -- 372
			122, -- 372
			math.floor(92 * pulse * alphaMul + 0.5) -- 372
		), -- 372
		Color(255, 178, 86, 0), -- 373
		16 -- 373
	) -- 373
	fillRadialGlow( -- 374
		bgGlow, -- 374
		lampX, -- 374
		lampY, -- 374
		glowR * 0.48, -- 374
		glowR * 0.42, -- 374
		Color( -- 375
			255, -- 375
			238, -- 375
			184, -- 375
			math.floor(176 * pulse * alphaMul + 0.5) -- 375
		), -- 375
		Color(255, 204, 118, 0), -- 376
		12 -- 376
	) -- 376
	bgGlow:drawDot( -- 377
		Vec2(lampX, lampY), -- 377
		math.max(1.8, 3.6 * s), -- 377
		Color( -- 377
			255, -- 377
			246, -- 377
			212, -- 377
			math.floor(248 * alphaMul + 0.5) -- 377
		) -- 377
	) -- 377
end -- 300
function EscortWorldRenderer.prototype.drawEscort1AlleySilhouettes(self, bgDraw, w, h, camX) -- 382
	local shift = camX * 0.38 -- 383
	local houses = {{x = 140, bw = 165, bh = 165, roof = 36}, {x = 430, bw = 190, bh = 195, roof = 42}, {x = 760, bw = 145, bh = 150, roof = 30}, {x = 1080, bw = 210, bh = 185, roof = 40}} -- 384
	for ____, hs in ipairs(houses) do -- 390
		local sx = ((hs.x - shift) % (w + 340) + (w + 340)) % (w + 340) - 170 -- 391
		local base = h * 0.25 -- 392
		bgDraw:drawRect( -- 393
			Rect(sx, base, hs.bw, hs.bh), -- 393
			Color(16, 20, 29, 175) -- 393
		) -- 393
		bgDraw:drawPolygon( -- 394
			{ -- 394
				Vec2(sx - 16, base + hs.bh), -- 395
				Vec2(sx + hs.bw + 16, base + hs.bh), -- 396
				Vec2(sx + hs.bw * 0.78, base + hs.bh + hs.roof), -- 397
				Vec2(sx + hs.bw * 0.22, base + hs.bh + hs.roof) -- 398
			}, -- 398
			Color(12, 15, 22, 195) -- 399
		) -- 399
	end -- 399
end -- 382
function EscortWorldRenderer.prototype.drawEscort2GranaryRafters(self, bgDraw, bgGlow, w, h, camX, time) -- 403
	local shift = camX * 0.42 -- 411
	bgDraw:drawRect( -- 413
		Rect(0, h * 0.8, w, h * 0.2), -- 413
		Color(12, 14, 20, 192) -- 413
	) -- 413
	local span = 290 -- 414
	local first = math.floor((shift - 180) / span) -- 415
	do -- 415
		local k = first -- 416
		while k <= first + 6 do -- 416
			local bx = k * span - shift -- 417
			bgDraw:drawRect( -- 419
				Rect(bx - 9, h * 0.2, 18, h * 0.62), -- 419
				Color(22, 19, 17, 165) -- 419
			) -- 419
			bgDraw:drawSegment( -- 421
				Vec2(bx, h * 0.82), -- 421
				Vec2(bx + span * 0.5, h * 0.96), -- 421
				7, -- 421
				Color(26, 21, 18, 185) -- 421
			) -- 421
			bgDraw:drawSegment( -- 422
				Vec2(bx + span, h * 0.82), -- 422
				Vec2(bx + span * 0.5, h * 0.96), -- 422
				7, -- 422
				Color(26, 21, 18, 185) -- 422
			) -- 422
			if math.abs(k) % 2 == 0 then -- 422
				local topX = bx + span * 0.44 -- 425
				local pulse = 0.86 + 0.14 * math.sin(time * 1.1 + k) -- 426
				local midA = math.floor(30 * pulse + 0.5) -- 427
				local topA = math.floor(14 * pulse + 0.5) -- 428
				fillGradQuad( -- 429
					bgGlow, -- 430
					topX - 20, -- 431
					h + 10, -- 431
					Color(168, 194, 224, topA), -- 431
					topX + 36, -- 432
					h + 10, -- 432
					Color(168, 194, 224, topA), -- 432
					topX + 94, -- 433
					h * 0.48, -- 433
					Color(176, 202, 232, midA), -- 433
					topX + 8, -- 434
					h * 0.48, -- 434
					Color(176, 202, 232, midA) -- 434
				) -- 434
				fillGradQuad( -- 436
					bgGlow, -- 437
					topX + 8, -- 438
					h * 0.48, -- 438
					Color(176, 202, 232, midA), -- 438
					topX + 94, -- 439
					h * 0.48, -- 439
					Color(176, 202, 232, midA), -- 439
					topX + 136, -- 440
					h * 0.14, -- 440
					Color(168, 194, 224, 0), -- 440
					topX + 30, -- 441
					h * 0.14, -- 441
					Color(168, 194, 224, 0) -- 441
				) -- 441
				do -- 441
					local d = 0 -- 444
					while d < 4 do -- 444
						local phase = (time * 0.18 + d * 0.27 + k * 0.31) % 1 -- 445
						local dx = topX + 12 + phase * 76 + math.sin(time * 1.4 + d) * 8 -- 446
						local dy = h * (0.9 - phase * 0.68) -- 447
						bgGlow:drawDot( -- 448
							Vec2(dx, dy), -- 448
							1.6, -- 448
							Color( -- 448
								214, -- 448
								222, -- 448
								232, -- 448
								math.floor(62 * math.sin(phase * math.pi) + 0.5) -- 448
							) -- 448
						) -- 448
						d = d + 1 -- 444
					end -- 444
				end -- 444
			end -- 444
			k = k + 1 -- 416
		end -- 416
	end -- 416
end -- 403
function EscortWorldRenderer.prototype.drawEscort3MountainShelterBg(self, bgDraw, bgGlow, w, h, camX, time) -- 454
	local cliffX = 120 - camX * 0.28 -- 463
	bgDraw:drawPolygon( -- 464
		{ -- 464
			Vec2(cliffX - 240, h * 0.18), -- 465
			Vec2(cliffX + 260, h * 0.18), -- 466
			Vec2(cliffX + 165, h * 0.68), -- 467
			Vec2(cliffX - 180, h * 0.86) -- 468
		}, -- 468
		Color(14, 18, 25, 165) -- 469
	) -- 469
	local warmPulse = 0.9 + 0.1 * math.sin(time * 2.1) -- 471
	fillRadialGlow( -- 472
		bgGlow, -- 472
		w * 0.5, -- 472
		h * 0.36, -- 472
		w * 0.26, -- 472
		h * 0.26, -- 472
		Color( -- 473
			224, -- 473
			164, -- 473
			88, -- 473
			math.floor(32 * warmPulse + 0.5) -- 473
		), -- 473
		Color(224, 164, 88, 0), -- 473
		16 -- 473
	) -- 473
end -- 454
function EscortWorldRenderer.prototype.drawEscort4CliffGorge(self, bgDraw, bgGlow, w, h, camX, time) -- 476
	local shift = camX * 0.32 -- 485
	do -- 485
		local i = 0 -- 486
		while i < 4 do -- 486
			local px = ((i * 380 - shift) % (w + 420) + (w + 420)) % (w + 420) - 210 -- 487
			bgDraw:drawPolygon( -- 488
				{ -- 488
					Vec2(px - 120, h * 0.2), -- 489
					Vec2(px + 145, h * 0.2), -- 490
					Vec2(px + 48, h * (0.58 + i % 2 * 0.12)), -- 491
					Vec2(px - 58, h * (0.5 + i % 2 * 0.08)) -- 492
				}, -- 492
				Color(16, 22, 33, 152) -- 493
			) -- 493
			i = i + 1 -- 486
		end -- 486
	end -- 486
	local cloudX = time * 24 % (w + 400) - 200 -- 496
	bgGlow:drawPolygon( -- 497
		{ -- 497
			Vec2(cloudX, h * 0.78), -- 498
			Vec2(cloudX + 240, h * 0.82), -- 499
			Vec2(cloudX + 210, h * 0.87), -- 500
			Vec2(cloudX - 20, h * 0.83) -- 501
		}, -- 501
		Color(142, 164, 192, 24) -- 502
	) -- 502
end -- 476
function EscortWorldRenderer.prototype.drawEscort5TowerApproachBg(self, bgDraw, bgGlow, w, h, camX, time, dawnWarmth) -- 505
	local glowPulse = 0.88 + 0.12 * math.sin(time * 1.8) -- 515
	fillRadialGlow( -- 516
		bgGlow, -- 516
		w * 0.78, -- 516
		h * 0.48, -- 516
		w * 0.42, -- 516
		h * 0.3, -- 516
		Color( -- 517
			228, -- 517
			184, -- 517
			132, -- 517
			math.floor(44 * dawnWarmth * glowPulse + 0.5) -- 517
		), -- 517
		Color(228, 184, 132, 0), -- 518
		18 -- 518
	) -- 518
	local shift = camX * 0.3 -- 520
	bgDraw:drawPolygon( -- 521
		{ -- 521
			Vec2(0, h * 0.2), -- 522
			Vec2(w, h * 0.2), -- 523
			Vec2(w, h * 0.34), -- 524
			Vec2(w * 0.55 - shift % 120 * 0.2, h * 0.29), -- 525
			Vec2(0, h * 0.36) -- 526
		}, -- 526
		Color(18, 22, 32, 140) -- 527
	) -- 527
end -- 505
function EscortWorldRenderer.prototype.drawGatepathSetpieces(self, fgDraw, fgGlow, worldArt, p, view, cam, time, ox) -- 532
	local groundY = cam:sy(0) -- 542
	worldArt:tryPlace( -- 544
		"sh_stele_banner", -- 544
		"gp_banner_start", -- 544
		cam:sx(ox + 96), -- 544
		groundY, -- 544
		cam:len(68), -- 544
		cam:len(74), -- 544
		{layer = 1, opacity = 0.92} -- 544
	) -- 544
	worldArt:tryPlace( -- 547
		"sh_stele_banner", -- 547
		"gp_stele_mid", -- 547
		cam:sx(ox + 520), -- 547
		groundY, -- 547
		cam:len(54), -- 547
		cam:len(60), -- 547
		{layer = 1, opacity = 0.86, facing = -1} -- 547
	) -- 547
	local stepTopY = cam:sy(48) -- 551
	local lampX = cam:sx(ox + 912) -- 552
	local poleH = cam:len(58) -- 553
	fgDraw:drawSegment( -- 554
		Vec2(lampX, stepTopY), -- 554
		Vec2(lampX, stepTopY + poleH), -- 554
		math.max( -- 554
			1.8, -- 554
			cam:len(2.4) -- 554
		), -- 554
		Color(74, 54, 38, 240) -- 554
	) -- 554
	fgDraw:drawSegment( -- 555
		Vec2(lampX, stepTopY + poleH), -- 555
		Vec2( -- 555
			lampX - cam:len(14), -- 555
			stepTopY + poleH -- 555
		), -- 555
		math.max( -- 555
			1.5, -- 555
			cam:len(2) -- 555
		), -- 555
		Color(74, 54, 38, 240) -- 555
	) -- 555
	worldArt:tryPlace( -- 556
		"prop_lantern", -- 556
		"gp_top_lantern", -- 556
		lampX - cam:len(14), -- 556
		stepTopY + poleH - cam:len(14), -- 556
		cam:len(18), -- 556
		cam:len(22), -- 556
		{layer = 4} -- 556
	) -- 556
	local flame = 0.88 + 0.12 * math.sin(time * 3.1) -- 557
	fillRadialGlow( -- 558
		fgGlow, -- 558
		lampX - cam:len(14), -- 558
		stepTopY + poleH - cam:len(14), -- 558
		cam:len(54), -- 558
		cam:len(48), -- 558
		Color( -- 559
			246, -- 559
			192, -- 559
			114, -- 559
			math.floor(72 * flame + 0.5) -- 559
		), -- 559
		Color(246, 192, 114, 0), -- 559
		16 -- 559
	) -- 559
	if p.phase == "gatepath-start" and p.partner.alive then -- 559
		local sx1 = cam:sx(p.player.x) -- 563
		local sx2 = cam:sx(p.partner.x) -- 564
		fgDraw:drawPolygon( -- 565
			{ -- 565
				Vec2( -- 566
					sx1 - cam:len(10), -- 566
					groundY + 1 -- 566
				), -- 566
				Vec2( -- 567
					sx1 + cam:len(10), -- 567
					groundY + 1 -- 567
				), -- 567
				Vec2( -- 568
					sx1 - cam:len(24), -- 568
					groundY - cam:len(10) -- 568
				), -- 568
				Vec2( -- 569
					sx1 - cam:len(40), -- 569
					groundY - cam:len(10) -- 569
				) -- 569
			}, -- 569
			Color(8, 10, 16, 86) -- 570
		) -- 570
		fgDraw:drawPolygon( -- 571
			{ -- 571
				Vec2( -- 572
					sx2 - cam:len(7), -- 572
					groundY + 1 -- 572
				), -- 572
				Vec2( -- 573
					sx2 + cam:len(7), -- 573
					groundY + 1 -- 573
				), -- 573
				Vec2( -- 574
					sx2 - cam:len(15), -- 574
					groundY - cam:len(7) -- 574
				), -- 574
				Vec2( -- 575
					sx2 - cam:len(26), -- 575
					groundY - cam:len(7) -- 575
				) -- 575
			}, -- 575
			Color(8, 10, 16, 78) -- 576
		) -- 576
	end -- 576
	if self.carryBloomT > 0 or view.backCarry.mounting then -- 576
		local k = self.carryBloomT > 0 and clamp01(self.carryBloomT / 1.15) or 0.72 -- 581
		local bx = cam:sx(p.player.x) -- 582
		local by = cam:sy(p.player.y + 42) -- 583
		fillRadialGlow( -- 584
			fgGlow, -- 584
			bx, -- 584
			by, -- 584
			cam:len(96), -- 584
			cam:len(72), -- 584
			Color( -- 585
				244, -- 585
				206, -- 585
				142, -- 585
				math.floor(62 * k + 0.5) -- 585
			), -- 585
			Color(244, 206, 142, 0), -- 585
			18 -- 585
		) -- 585
	end -- 585
end -- 532
function EscortWorldRenderer.prototype.drawEscort1Setpieces(self, fgDraw, fgGlow, worldArt, _p, cam, time, ox) -- 589
	local backDepth = LANE_DEPTH.upper + 16 -- 598
	local backY = cam:sy(0, backDepth) -- 599
	local backLayer = depthOrder(backDepth, -2) -- 600
	worldArt:tryPlace( -- 602
		"sh_stele_banner", -- 602
		"e1_banner_a", -- 602
		cam:sx(ox + 150), -- 602
		backY, -- 602
		cam:len(68), -- 602
		cam:len(76), -- 602
		{layer = backLayer, opacity = 0.9} -- 602
	) -- 602
	worldArt:tryPlace( -- 605
		"sh_stele_banner", -- 605
		"e1_banner_b", -- 605
		cam:sx(ox + 1245), -- 605
		backY, -- 605
		cam:len(64), -- 605
		cam:len(70), -- 605
		{layer = backLayer, opacity = 0.88, facing = -1} -- 605
	) -- 605
	local emberSpots = {285, 860} -- 609
	do -- 609
		local i = 0 -- 610
		while i < #emberSpots do -- 610
			local bx = cam:sx(ox + emberSpots[i + 1]) -- 611
			local pulse = 0.82 + 0.18 * math.sin(time * 4.2 + i * 1.9) -- 612
			fgDraw:drawPolygon( -- 613
				{ -- 613
					Vec2( -- 614
						bx - cam:len(12), -- 614
						backY + cam:len(14) -- 614
					), -- 614
					Vec2( -- 615
						bx + cam:len(12), -- 615
						backY + cam:len(14) -- 615
					), -- 615
					Vec2( -- 616
						bx + cam:len(8), -- 616
						backY + cam:len(4) -- 616
					), -- 616
					Vec2( -- 617
						bx - cam:len(8), -- 617
						backY + cam:len(4) -- 617
					) -- 617
				}, -- 617
				Color(38, 34, 34, 240), -- 618
				1, -- 618
				Color(88, 72, 62, 180) -- 618
			) -- 618
			fgDraw:drawSegment( -- 619
				Vec2( -- 619
					bx - cam:len(9), -- 619
					backY -- 619
				), -- 619
				Vec2( -- 619
					bx - cam:len(6), -- 619
					backY + cam:len(6) -- 619
				), -- 619
				2, -- 619
				Color(34, 30, 30, 235) -- 619
			) -- 619
			fgDraw:drawSegment( -- 620
				Vec2( -- 620
					bx + cam:len(9), -- 620
					backY -- 620
				), -- 620
				Vec2( -- 620
					bx + cam:len(6), -- 620
					backY + cam:len(6) -- 620
				), -- 620
				2, -- 620
				Color(34, 30, 30, 235) -- 620
			) -- 620
			fgGlow:drawEllipse( -- 621
				Vec2( -- 621
					bx, -- 621
					backY + cam:len(14) -- 621
				), -- 621
				cam:len(9), -- 621
				cam:len(3.5), -- 621
				Color( -- 621
					236, -- 621
					114, -- 621
					48, -- 621
					math.floor(185 * pulse + 0.5) -- 621
				) -- 621
			) -- 621
			fillRadialGlow( -- 622
				fgGlow, -- 622
				bx, -- 622
				backY + cam:len(18), -- 622
				cam:len(48), -- 622
				cam:len(36), -- 622
				Color( -- 623
					226, -- 623
					116, -- 623
					52, -- 623
					math.floor(62 * pulse + 0.5) -- 623
				), -- 623
				Color(226, 116, 52, 0), -- 623
				14 -- 623
			) -- 623
			i = i + 1 -- 610
		end -- 610
	end -- 610
end -- 589
function EscortWorldRenderer.prototype.drawEscort2Setpieces(self, fgDraw, fgGlow, worldArt, p, cam, time, ox) -- 627
	local backDepth = LANE_DEPTH.upper + 16 -- 636
	local backY = cam:sy(0, backDepth) -- 637
	local backLayer = depthOrder(backDepth, -2) -- 638
	local sackSpots = {195, 480, 1020, 1310} -- 640
	do -- 640
		local i = 0 -- 641
		while i < #sackSpots do -- 641
			local sx = cam:sx(ox + sackSpots[i + 1]) -- 642
			worldArt:tryPlace( -- 643
				"sh_grain_sacks", -- 643
				"e2_bg_sack_" .. tostring(i), -- 643
				sx, -- 643
				backY, -- 643
				cam:len(72), -- 643
				cam:len(44), -- 643
				{ -- 643
					layer = backLayer, -- 644
					opacity = 0.78, -- 645
					facing = i % 2 == 0 and 1 or -1, -- 646
					color = Color(172, 168, 162, 255) -- 647
				} -- 647
			) -- 647
			i = i + 1 -- 641
		end -- 641
	end -- 641
	local beamY = cam:sy(64, -24) -- 651
	local drapeX = cam:sx(ox + 440) -- 652
	local sway = math.sin(time * 1.9) * 3 -- 653
	fgDraw:drawPolygon( -- 654
		{ -- 654
			Vec2( -- 655
				drapeX - cam:len(22), -- 655
				beamY -- 655
			), -- 655
			Vec2( -- 656
				drapeX + cam:len(22), -- 656
				beamY -- 656
			), -- 656
			Vec2( -- 657
				drapeX + cam:len(18) + sway, -- 657
				beamY - cam:len(24) -- 657
			), -- 657
			Vec2( -- 658
				drapeX - cam:len(14) + sway * 0.7, -- 658
				beamY - cam:len(19) -- 658
			) -- 658
		}, -- 658
		Color(72, 58, 46, 160) -- 659
	) -- 659
	for ____, pk in ipairs(p.pickups) do -- 662
		do -- 662
			if pk.id == "" or p.run.taken[pk.id] then -- 662
				goto __continue72 -- 664
			end -- 664
			local px = cam:sx(pk.x) -- 666
			local py = cam:sy(pk.y + 10, pk.depth or 0) -- 667
			local pulse = 0.78 + 0.22 * math.sin(time * 3 + pk.x * 0.02) -- 668
			local col = pk.kind == "bell" and Color( -- 669
				238, -- 669
				204, -- 669
				136, -- 669
				math.floor(78 * pulse + 0.5) -- 669
			) or Color( -- 669
				224, -- 669
				168, -- 669
				92, -- 669
				math.floor(72 * pulse + 0.5) -- 669
			) -- 669
			fillRadialGlow( -- 670
				fgGlow, -- 670
				px, -- 670
				py, -- 670
				cam:len(22), -- 670
				cam:len(18), -- 670
				col, -- 670
				Color(224, 168, 92, 0), -- 670
				12 -- 670
			) -- 670
		end -- 670
		::__continue72:: -- 670
	end -- 670
end -- 627
function EscortWorldRenderer.prototype.drawEscort3WorkbenchSanctuary(self, fgDraw, fgGlow, worldArt, p, view, cam, time, ox) -- 674
	local pulse = 0.88 + 0.12 * math.sin(time * 2.6) -- 684
	local benchCx = cam:sx(ox + 620) -- 685
	local benchDepth = LANE_DEPTH.middle + 10 -- 686
	local benchBaseY = cam:sy(0, benchDepth) -- 687
	local benchLayer = depthOrder(benchDepth, 2) -- 688
	fillRadialGlow( -- 691
		fgGlow, -- 691
		benchCx, -- 691
		benchBaseY + cam:len(42), -- 691
		cam:len(168), -- 691
		cam:len(112), -- 691
		Color( -- 692
			246, -- 692
			184, -- 692
			96, -- 692
			math.floor(76 * pulse + 0.5) -- 692
		), -- 692
		Color(246, 168, 74, 0), -- 692
		20 -- 692
	) -- 692
	fillRadialGlow( -- 693
		fgGlow, -- 693
		benchCx - cam:len(22), -- 693
		benchBaseY + cam:len(68), -- 693
		cam:len(58), -- 693
		cam:len(48), -- 693
		Color( -- 694
			255, -- 694
			224, -- 694
			152, -- 694
			math.floor(115 * pulse + 0.5) -- 694
		), -- 694
		Color(255, 198, 108, 0), -- 694
		14 -- 694
	) -- 694
	worldArt:tryPlace( -- 697
		"sh_craft_workbench", -- 697
		"e3_sanctuary_bench", -- 697
		benchCx, -- 697
		benchBaseY - cam:len(4), -- 697
		cam:len(142), -- 697
		cam:len(112), -- 697
		{layer = benchLayer} -- 697
	) -- 697
	local matX = cam:sx(ox + 516) -- 702
	local matDepth = LANE_DEPTH.middle + 4 -- 703
	local matY = cam:sy(0, matDepth) -- 704
	worldArt:tryPlace( -- 705
		"sh_straw_mat", -- 705
		"e3_xiaoman_mat", -- 705
		matX, -- 705
		matY - cam:len(2), -- 705
		cam:len(66), -- 705
		cam:len(28), -- 705
		{layer = depthOrder(matDepth, 0)} -- 705
	) -- 705
	if view.backCarry.atBench or view.craftBench.active then -- 705
		fillRadialGlow( -- 710
			fgGlow, -- 710
			matX, -- 710
			matY + cam:len(22), -- 710
			cam:len(42), -- 710
			cam:len(34), -- 710
			Color( -- 711
				252, -- 711
				212, -- 711
				138, -- 711
				math.floor(68 * pulse + 0.5) -- 711
			), -- 711
			Color(252, 212, 138, 0), -- 711
			14 -- 711
		) -- 711
	end -- 711
	worldArt:tryPlace( -- 715
		"sh_stele_banner", -- 715
		"e3_entry_stele", -- 715
		cam:sx(ox + 235), -- 715
		cam:sy(0, LANE_DEPTH.upper + 16), -- 715
		cam:len(58), -- 715
		cam:len(66), -- 715
		{ -- 715
			layer = depthOrder(LANE_DEPTH.upper + 16, -1), -- 716
			opacity = 0.86 -- 716
		} -- 716
	) -- 716
	do -- 716
		local i = 0 -- 720
		while i < #p.enemies do -- 720
			do -- 720
				local en = p.enemies[i + 1] -- 721
				if en.kind ~= "target" then -- 721
					goto __continue78 -- 723
				end -- 723
				local tx = cam:sx(en.x) -- 725
				local ty = cam:sy(en.y, en.depth or 0) -- 726
				local swayK = self.gongSway[i] or 0 -- 727
				if swayK > 0.05 then -- 727
					local ringR = cam:len(18 + (1 - swayK) * 44) -- 729
					fgGlow:drawRing( -- 730
						Vec2( -- 730
							tx, -- 730
							ty + cam:len(32) -- 730
						), -- 730
						math.max(1, ringR - 1.5), -- 730
						ringR, -- 730
						Color(0, 0, 0, 0), -- 731
						1.4, -- 731
						toColor( -- 731
							PALETTE.amber, -- 731
							math.floor(190 * swayK + 0.5) -- 731
						) -- 731
					) -- 731
				end -- 731
			end -- 731
			::__continue78:: -- 731
			i = i + 1 -- 720
		end -- 720
	end -- 720
end -- 674
function EscortWorldRenderer.prototype.drawEscort4Setpieces(self, fgDraw, fgGlow, worldArt, p, cam, time, ox) -- 736
	local backDepth = LANE_DEPTH.upper + 16 -- 745
	local backY = cam:sy(0, backDepth) -- 746
	local backLayer = depthOrder(backDepth, -2) -- 747
	worldArt:tryPlace( -- 749
		"sh_stele_banner", -- 749
		"e4_stele_a", -- 749
		cam:sx(ox + 210), -- 749
		backY, -- 749
		cam:len(58), -- 749
		cam:len(66), -- 749
		{layer = backLayer, opacity = 0.9} -- 749
	) -- 749
	worldArt:tryPlace( -- 752
		"sh_stele_banner", -- 752
		"e4_stele_b", -- 752
		cam:sx(ox + 990), -- 752
		backY, -- 752
		cam:len(56), -- 752
		cam:len(64), -- 752
		{layer = backLayer, opacity = 0.88, facing = -1} -- 752
	) -- 752
	local pineXs = {310, 740, 1210} -- 756
	do -- 756
		local i = 0 -- 757
		while i < #pineXs do -- 757
			worldArt:tryPlace( -- 758
				"pine", -- 758
				"e4_cliff_pine_" .. tostring(i), -- 758
				cam:sx(ox + pineXs[i + 1]), -- 758
				backY - cam:len(4), -- 758
				cam:len(112), -- 758
				cam:len(98), -- 758
				{ -- 758
					layer = backLayer - 1, -- 759
					opacity = 0.72, -- 759
					facing = i % 2 == 0 and 1 or -1, -- 759
					color = Color(138, 152, 168, 255) -- 759
				} -- 759
			) -- 759
			i = i + 1 -- 757
		end -- 757
	end -- 757
	do -- 757
		local i = 0 -- 763
		while i < #p.enemies do -- 763
			do -- 763
				local en = p.enemies[i + 1] -- 764
				if not en.alive or en.kind ~= "gunner" then -- 764
					goto __continue85 -- 766
				end -- 766
				local gx = cam:sx(en.x - 10) -- 768
				local gy = cam:sy(en.y + en.h * 0.62, en.depth or 0) -- 769
				local ember = 0.72 + 0.28 * math.sin(time * 7.5 + i * 2.1) -- 770
				fgGlow:drawDot( -- 771
					Vec2(gx, gy), -- 771
					2.3, -- 771
					Color( -- 771
						255, -- 771
						134, -- 771
						62, -- 771
						math.floor(215 * ember + 0.5) -- 771
					) -- 771
				) -- 771
				fillRadialGlow( -- 772
					fgGlow, -- 772
					gx, -- 772
					gy, -- 772
					14, -- 772
					14, -- 772
					Color( -- 772
						242, -- 772
						108, -- 772
						46, -- 772
						math.floor(64 * ember + 0.5) -- 772
					), -- 772
					Color(242, 108, 46, 0), -- 772
					10 -- 772
				) -- 772
			end -- 772
			::__continue85:: -- 772
			i = i + 1 -- 763
		end -- 763
	end -- 763
	fgDraw:drawSegment( -- 775
		Vec2( -- 775
			cam:sx(ox + 500), -- 775
			backY + cam:len(4) -- 775
		), -- 775
		Vec2( -- 775
			cam:sx(ox + 900), -- 775
			backY + cam:len(4) -- 775
		), -- 775
		1, -- 775
		Color(110, 124, 142, 48) -- 775
	) -- 775
end -- 736
function EscortWorldRenderer.prototype.drawEscort5Setpieces(self, fgDraw, fgGlow, worldArt, _p, cam, time, ox) -- 778
	local backDepth = LANE_DEPTH.upper + 16 -- 787
	local backY = cam:sy(0, backDepth) -- 788
	local backLayer = depthOrder(backDepth, -2) -- 789
	worldArt:tryPlace( -- 791
		"sh_stele_banner", -- 791
		"e5_stele_a", -- 791
		cam:sx(ox + 215), -- 791
		backY, -- 791
		cam:len(62), -- 791
		cam:len(70), -- 791
		{layer = backLayer, opacity = 0.92} -- 791
	) -- 791
	worldArt:tryPlace( -- 794
		"pine", -- 794
		"e5_pine_a", -- 794
		cam:sx(ox + 640), -- 794
		backY - cam:len(4), -- 794
		cam:len(118), -- 794
		cam:len(102), -- 794
		{ -- 794
			layer = backLayer - 1, -- 795
			opacity = 0.78, -- 795
			color = Color(156, 168, 182, 255) -- 795
		} -- 795
	) -- 795
	local lx = cam:sx(ox + 1315) -- 798
	local poleTop = backY + cam:len(68) -- 799
	local flame = 0.88 + 0.12 * math.sin(time * 2.9) -- 800
	fgDraw:drawSegment( -- 801
		Vec2(lx, backY), -- 801
		Vec2(lx, poleTop), -- 801
		math.max( -- 801
			1.8, -- 801
			cam:len(2.4) -- 801
		), -- 801
		Color(76, 56, 40, 240) -- 801
	) -- 801
	fgDraw:drawSegment( -- 802
		Vec2(lx, poleTop), -- 802
		Vec2( -- 802
			lx - cam:len(15), -- 802
			poleTop -- 802
		), -- 802
		math.max( -- 802
			1.6, -- 802
			cam:len(2) -- 802
		), -- 802
		Color(76, 56, 40, 240) -- 802
	) -- 802
	worldArt:tryPlace( -- 803
		"prop_lantern", -- 803
		"e5_approach_lamp", -- 803
		lx - cam:len(15), -- 803
		poleTop - cam:len(14), -- 803
		cam:len(20), -- 803
		cam:len(24), -- 803
		{layer = backLayer + 2} -- 803
	) -- 803
	fillRadialGlow( -- 806
		fgGlow, -- 806
		lx - cam:len(15), -- 806
		poleTop - cam:len(14), -- 806
		cam:len(74), -- 806
		cam:len(62), -- 806
		Color( -- 807
			255, -- 807
			206, -- 807
			128, -- 807
			math.floor(92 * flame + 0.5) -- 807
		), -- 807
		Color(255, 182, 88, 0), -- 807
		16 -- 807
	) -- 807
end -- 778
return ____exports -- 778