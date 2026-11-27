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
	local backRoadY = cam:sy(0, p.room.depth ~= nil and p.room.depth.max or 0) -- 187
	if key == "escort1" then -- 187
		self:drawEscort1AlleySilhouettes(backdropArt, w, backRoadY, cam) -- 189
	elseif key == "escort2" then -- 189
		self:drawEscort2GranaryRafters( -- 191
			backdropArt, -- 191
			bgGlow, -- 191
			w, -- 191
			h, -- 191
			backRoadY, -- 191
			cam, -- 191
			time -- 191
		) -- 191
	elseif key == "escort3" then -- 191
		self:drawEscort3MountainShelterBg( -- 193
			backdropArt, -- 193
			bgGlow, -- 193
			w, -- 193
			h, -- 193
			backRoadY, -- 193
			cam, -- 193
			time -- 193
		) -- 193
	elseif key == "escort4" then -- 193
		self:drawEscort4CliffGorge( -- 195
			backdropArt, -- 195
			bgGlow, -- 195
			w, -- 195
			h, -- 195
			backRoadY, -- 195
			cam, -- 195
			time -- 195
		) -- 195
	elseif key == "escort5" then -- 195
		self:drawEscort5TowerApproachBg( -- 197
			backdropArt, -- 197
			bgGlow, -- 197
			w, -- 197
			h, -- 197
			backRoadY, -- 197
			cam, -- 197
			time, -- 197
			dynamicDawn -- 197
		) -- 197
	end -- 197
end -- 114
function EscortWorldRenderer.prototype.drawWorldSetpieces(self, fgDraw, fgGlow, worldArt, p, view, cam, time) -- 202
	local key = p.room.key -- 211
	if not ____exports.isEscortWorldRoom(key) then -- 211
		return -- 213
	end -- 213
	local ox = p.ox -- 215
	if key == "gatepath" then -- 215
		self:drawGatepathSetpieces( -- 218
			fgDraw, -- 218
			fgGlow, -- 218
			worldArt, -- 218
			p, -- 218
			view, -- 218
			cam, -- 218
			time, -- 218
			ox -- 218
		) -- 218
		return -- 219
	end -- 219
	if key == "escort1" then -- 219
		self:drawEscort1Setpieces( -- 222
			fgDraw, -- 222
			fgGlow, -- 222
			worldArt, -- 222
			p, -- 222
			cam, -- 222
			time, -- 222
			ox -- 222
		) -- 222
		return -- 223
	end -- 223
	if key == "escort2" then -- 223
		self:drawEscort2Setpieces( -- 226
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
	if key == "escort3" then -- 227
		self:drawEscort3WorkbenchSanctuary( -- 230
			fgDraw, -- 230
			fgGlow, -- 230
			worldArt, -- 230
			p, -- 230
			view, -- 230
			cam, -- 230
			time, -- 230
			ox -- 230
		) -- 230
		return -- 231
	end -- 231
	if key == "escort4" then -- 231
		self:drawEscort4Setpieces( -- 234
			fgDraw, -- 234
			fgGlow, -- 234
			worldArt, -- 234
			p, -- 234
			cam, -- 234
			time, -- 234
			ox -- 234
		) -- 234
		return -- 235
	end -- 235
	if key == "escort5" then -- 235
		self:drawEscort5Setpieces( -- 238
			fgDraw, -- 238
			fgGlow, -- 238
			worldArt, -- 238
			p, -- 238
			cam, -- 238
			time, -- 238
			ox -- 238
		) -- 238
	end -- 238
end -- 202
function EscortWorldRenderer.prototype.drawForegroundFraming(self, fgDraw, _fgGlow, worldArt, p, cam, time) -- 243
	local key = p.room.key -- 251
	if not ____exports.isEscortWorldRoom(key) then -- 251
		return -- 253
	end -- 253
	local w = cam.viewW -- 255
	local h = cam.viewH -- 256
	local parallaxX = cam.x * 1.26 -- 257
	local sway = math.sin(time * 1.6) * 4 -- 258
	if key == "escort2" then -- 258
		local tileW = 140 -- 262
		local cols = math.ceil(w / tileW) + 2 -- 263
		local offset = parallaxX * 0.18 % tileW -- 264
		do -- 264
			local c = 0 -- 265
			while c < cols do -- 265
				worldArt:tryPlace( -- 266
					"fe_beam_wood", -- 266
					"escort2_fg_top_" .. tostring(c), -- 266
					c * tileW - offset, -- 266
					h - 24, -- 266
					tileW + 2, -- 266
					26, -- 266
					{ -- 266
						layer = 5200, -- 267
						color = Color(96, 86, 80, 255), -- 267
						opacity = 0.92 -- 267
					} -- 267
				) -- 267
				c = c + 1 -- 265
			end -- 265
		end -- 265
	elseif key == "escort3" or key == "escort4" or key == "escort5" then -- 265
		worldArt:tryPlace( -- 272
			"grass_low", -- 272
			"escort_fg_bush_l", -- 272
			78 + sway * 0.4, -- 272
			-4, -- 272
			190, -- 272
			48, -- 272
			{ -- 272
				color = Color(24, 34, 42, 255), -- 273
				opacity = 0.82, -- 273
				layer = 5200 -- 273
			} -- 273
		) -- 273
		worldArt:tryPlace( -- 275
			"grass_low", -- 275
			"escort_fg_bush_r", -- 275
			w - 82 - sway * 0.35, -- 275
			-4, -- 275
			198, -- 275
			52, -- 275
			{ -- 275
				color = Color(24, 34, 42, 255), -- 276
				opacity = 0.82, -- 276
				layer = 5200, -- 276
				facing = -1 -- 276
			} -- 276
		) -- 276
	end -- 276
	local stride = 280 -- 281
	local startSlot = math.floor((parallaxX - 200) / stride) -- 282
	do -- 282
		local s = startSlot -- 283
		while s <= startSlot + 6 do -- 283
			do -- 283
				local sx = s * stride - parallaxX + w * 0.5 -- 284
				if sx < -140 or sx > w + 140 then -- 284
					goto __continue45 -- 286
				end -- 286
				local hSeed = math.abs(math.sin(s * 12.9898) * 43758.5453) % 1 -- 288
				local rockH = 18 + hSeed * 14 -- 289
				local rockW = 68 + hSeed * 36 -- 290
				worldArt:tryPlace( -- 291
					"dp_fg_rock", -- 291
					"escort_fg_rock_" .. tostring(s - startSlot), -- 291
					sx, -- 291
					-2, -- 291
					rockW, -- 291
					rockH, -- 291
					{layer = 5190, opacity = 0.88, facing = s % 2 == 0 and 1 or -1} -- 291
				) -- 291
			end -- 291
			::__continue45:: -- 291
			s = s + 1 -- 283
		end -- 283
	end -- 283
end -- 243
function EscortWorldRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, camX, time, spec, dawnWarmth, behindWindow, paintedWindow) -- 301
	local s = spec.scale -- 313
	local tx = w * spec.screenXFrac - camX * 0.045 -- 314
	local ty = h * spec.screenYFrac -- 315
	local pulse = 0.86 + 0.14 * math.sin(time * 2.5) -- 316
	local alphaMul = behindWindow and 0.62 or 1 -- 317
	local topW = 34 * s -- 319
	local bodyH = 62 * s -- 320
	if paintedWindow == nil then -- 320
		local ridgeW = 190 * s + 95 -- 323
		local ridgeH = 44 * s + 22 -- 324
		local ridgeCol = Color( -- 325
			math.floor(20 + dawnWarmth * 16 + 0.5), -- 326
			math.floor(26 + dawnWarmth * 14 + 0.5), -- 327
			math.floor(38 + dawnWarmth * 8 + 0.5), -- 328
			math.floor(188 * alphaMul + 0.5) -- 329
		) -- 329
		bgDraw:drawPolygon( -- 331
			{ -- 331
				Vec2(tx - ridgeW, ty - ridgeH), -- 332
				Vec2(tx + ridgeW * 0.72, ty - ridgeH), -- 333
				Vec2(tx + ridgeW * 0.16, ty + 6 * s), -- 334
				Vec2(tx - ridgeW * 0.32, ty + 2 * s) -- 335
			}, -- 335
			ridgeCol -- 336
		) -- 336
		local baseW = 44 * s -- 339
		local towerCol = Color( -- 340
			math.floor(24 + dawnWarmth * 14 + 0.5), -- 341
			math.floor(30 + dawnWarmth * 12 + 0.5), -- 342
			math.floor(42 + dawnWarmth * 8 + 0.5), -- 343
			math.floor(225 * alphaMul + 0.5) -- 344
		) -- 344
		local rimCol = Color( -- 346
			138, -- 346
			148, -- 346
			166, -- 346
			math.floor(68 * alphaMul + 0.5) -- 346
		) -- 346
		bgDraw:drawPolygon( -- 347
			{ -- 347
				Vec2(tx - baseW * 0.5, ty - 4 * s), -- 348
				Vec2(tx + baseW * 0.5, ty - 4 * s), -- 349
				Vec2(tx + topW * 0.5, ty + bodyH), -- 350
				Vec2(tx - topW * 0.5, ty + bodyH) -- 351
			}, -- 351
			towerCol, -- 352
			0.8, -- 352
			rimCol -- 352
		) -- 352
		local pavH = 18 * s -- 355
		local eaveY = ty + bodyH + pavH -- 356
		local eaveW = 54 * s -- 357
		bgDraw:drawRect( -- 358
			Rect(tx - topW * 0.38, ty + bodyH, 3 * s, pavH), -- 358
			towerCol -- 358
		) -- 358
		bgDraw:drawRect( -- 359
			Rect(tx + topW * 0.38 - 3 * s, ty + bodyH, 3 * s, pavH), -- 359
			towerCol -- 359
		) -- 359
		bgDraw:drawPolygon( -- 360
			{ -- 360
				Vec2(tx - eaveW * 0.54, eaveY - 2 * s), -- 361
				Vec2(tx + eaveW * 0.54, eaveY - 2 * s), -- 362
				Vec2(tx + eaveW * 0.24, eaveY + 13 * s), -- 363
				Vec2(tx - eaveW * 0.24, eaveY + 13 * s) -- 364
			}, -- 364
			Color( -- 365
				18, -- 365
				22, -- 365
				32, -- 365
				math.floor(238 * alphaMul + 0.5) -- 365
			), -- 365
			0.8, -- 365
			rimCol -- 365
		) -- 365
	end -- 365
	local lampX = paintedWindow and paintedWindow.x or tx - topW * 0.14 -- 369
	local lampY = paintedWindow and paintedWindow.y or ty + bodyH * 0.64 -- 370
	local glowR = spec.beaconR * pulse -- 371
	fillRadialGlow( -- 372
		bgGlow, -- 372
		lampX, -- 372
		lampY, -- 372
		glowR * 1.35, -- 372
		glowR, -- 372
		Color( -- 373
			255, -- 373
			206, -- 373
			122, -- 373
			math.floor(92 * pulse * alphaMul + 0.5) -- 373
		), -- 373
		Color(255, 178, 86, 0), -- 374
		16 -- 374
	) -- 374
	fillRadialGlow( -- 375
		bgGlow, -- 375
		lampX, -- 375
		lampY, -- 375
		glowR * 0.48, -- 375
		glowR * 0.42, -- 375
		Color( -- 376
			255, -- 376
			238, -- 376
			184, -- 376
			math.floor(176 * pulse * alphaMul + 0.5) -- 376
		), -- 376
		Color(255, 204, 118, 0), -- 377
		12 -- 377
	) -- 377
	bgGlow:drawDot( -- 378
		Vec2(lampX, lampY), -- 378
		math.max(1.8, 3.6 * s), -- 378
		Color( -- 378
			255, -- 378
			246, -- 378
			212, -- 378
			math.floor(248 * alphaMul + 0.5) -- 378
		) -- 378
	) -- 378
end -- 301
function EscortWorldRenderer.prototype.drawEscort1AlleySilhouettes(self, backdropArt, w, backRoadY, cam) -- 383
	local shift = cam.x * 0.34 -- 384
	local houses = {{x = 160, w = 158, h = 140, slot = "dp_ruin_house_a"}, {x = 470, w = 146, h = 132, slot = "dp_ruin_house_b"}, {x = 800, w = 154, h = 136, slot = "dp_ruin_house_a"}, {x = 1120, w = 142, h = 128, slot = "dp_ruin_house_b"}} -- 385
	do -- 385
		local i = 0 -- 391
		while i < #houses do -- 391
			local hs = houses[i + 1] -- 392
			local sx = ((hs.x - shift) % (w + 340) + (w + 340)) % (w + 340) - 170 -- 393
			backdropArt:tryPlace( -- 394
				hs.slot, -- 394
				"e1_mid_house_" .. tostring(i), -- 394
				sx, -- 394
				backRoadY - cam:len(4), -- 394
				cam:len(hs.w * 0.82), -- 394
				cam:len(hs.h * 0.82), -- 394
				{layer = 3, opacity = 0.72, facing = i % 2 == 0 and 1 or -1} -- 394
			) -- 394
			i = i + 1 -- 391
		end -- 391
	end -- 391
end -- 383
function EscortWorldRenderer.prototype.drawEscort2GranaryRafters(self, backdropArt, bgGlow, w, h, backRoadY, cam, time) -- 400
	local shift = cam.x * 0.38 -- 409
	local span = 290 -- 410
	local first = math.floor((shift - 180) / span) -- 411
	local pillarH = math.max(120, h - backRoadY + 12) -- 412
	do -- 412
		local k = first -- 413
		while k <= first + 6 do -- 413
			local bx = k * span - shift -- 414
			backdropArt:tryPlace( -- 416
				"dp_granary_pillar", -- 416
				"e2_mid_pillar_" .. tostring(k - first), -- 416
				bx, -- 416
				backRoadY - cam:len(2), -- 416
				cam:len(26), -- 416
				pillarH, -- 416
				{layer = 3, opacity = 0.76} -- 416
			) -- 416
			if math.abs(k) % 2 == 0 then -- 416
				local topX = bx + span * 0.44 -- 421
				local pulse = 0.86 + 0.14 * math.sin(time * 1.1 + k) -- 422
				local midA = math.floor(28 * pulse + 0.5) -- 423
				local topA = math.floor(12 * pulse + 0.5) -- 424
				fillGradQuad( -- 425
					bgGlow, -- 426
					topX - 20, -- 427
					h + 10, -- 427
					Color(168, 194, 224, topA), -- 427
					topX + 36, -- 428
					h + 10, -- 428
					Color(168, 194, 224, topA), -- 428
					topX + 94, -- 429
					h * 0.48, -- 429
					Color(176, 202, 232, midA), -- 429
					topX + 8, -- 430
					h * 0.48, -- 430
					Color(176, 202, 232, midA) -- 430
				) -- 430
				fillGradQuad( -- 432
					bgGlow, -- 433
					topX + 8, -- 434
					h * 0.48, -- 434
					Color(176, 202, 232, midA), -- 434
					topX + 94, -- 435
					h * 0.48, -- 435
					Color(176, 202, 232, midA), -- 435
					topX + 136, -- 436
					backRoadY, -- 436
					Color(168, 194, 224, 0), -- 436
					topX + 30, -- 437
					backRoadY, -- 437
					Color(168, 194, 224, 0) -- 437
				) -- 437
				do -- 437
					local d = 0 -- 439
					while d < 4 do -- 439
						local phase = (time * 0.18 + d * 0.27 + k * 0.31) % 1 -- 440
						local dx = topX + 12 + phase * 76 + math.sin(time * 1.4 + d) * 8 -- 441
						local dy = h * (0.9 - phase * 0.64) -- 442
						bgGlow:drawDot( -- 443
							Vec2(dx, dy), -- 443
							1.5, -- 443
							Color( -- 443
								214, -- 443
								222, -- 443
								232, -- 443
								math.floor(58 * math.sin(phase * math.pi) + 0.5) -- 443
							) -- 443
						) -- 443
						d = d + 1 -- 439
					end -- 439
				end -- 439
			end -- 439
			k = k + 1 -- 413
		end -- 413
	end -- 413
end -- 400
function EscortWorldRenderer.prototype.drawEscort3MountainShelterBg(self, backdropArt, bgGlow, w, h, backRoadY, cam, time) -- 449
	local cliffX = 240 - cam.x * 0.26 -- 458
	backdropArt:tryPlace( -- 459
		"dp_cliff_rock", -- 459
		"e3_mid_cliff", -- 459
		cliffX, -- 459
		backRoadY - cam:len(6), -- 459
		cam:len(220), -- 459
		cam:len(165), -- 459
		{layer = 3, opacity = 0.72} -- 459
	) -- 459
	local warmPulse = 0.9 + 0.1 * math.sin(time * 2.1) -- 462
	fillRadialGlow( -- 463
		bgGlow, -- 463
		w * 0.5, -- 463
		backRoadY + cam:len(54), -- 463
		w * 0.26, -- 463
		h * 0.24, -- 463
		Color( -- 464
			224, -- 464
			164, -- 464
			88, -- 464
			math.floor(30 * warmPulse + 0.5) -- 464
		), -- 464
		Color(224, 164, 88, 0), -- 464
		16 -- 464
	) -- 464
end -- 449
function EscortWorldRenderer.prototype.drawEscort4CliffGorge(self, backdropArt, bgGlow, w, h, backRoadY, cam, time) -- 467
	local shift = cam.x * 0.3 -- 476
	do -- 476
		local i = 0 -- 477
		while i < 4 do -- 477
			local px = ((i * 380 - shift) % (w + 420) + (w + 420)) % (w + 420) - 210 -- 478
			backdropArt:tryPlace( -- 479
				"dp_cliff_rock", -- 479
				"e4_mid_cliff_" .. tostring(i), -- 479
				px, -- 479
				backRoadY - cam:len(6), -- 479
				cam:len(176), -- 479
				cam:len(132 + i % 2 * 26), -- 479
				{layer = 3, opacity = 0.68, facing = i % 2 == 0 and 1 or -1} -- 479
			) -- 479
			i = i + 1 -- 477
		end -- 477
	end -- 477
	local cloudX = time * 22 % (w + 420) - 210 -- 483
	backdropArt:tryPlace( -- 484
		"ink_mist_curve", -- 484
		"e4_wind_cloud", -- 484
		cloudX, -- 484
		h * 0.8, -- 484
		320, -- 484
		52, -- 484
		{ -- 484
			color = Color(142, 164, 192, 255), -- 485
			opacity = 0.18, -- 485
			layer = 4 -- 485
		} -- 485
	) -- 485
end -- 467
function EscortWorldRenderer.prototype.drawEscort5TowerApproachBg(self, backdropArt, bgGlow, w, h, backRoadY, cam, time, dawnWarmth) -- 489
	local glowPulse = 0.88 + 0.12 * math.sin(time * 1.8) -- 499
	fillRadialGlow( -- 500
		bgGlow, -- 500
		w * 0.78, -- 500
		h * 0.48, -- 500
		w * 0.42, -- 500
		h * 0.3, -- 500
		Color( -- 501
			228, -- 501
			184, -- 501
			132, -- 501
			math.floor(44 * dawnWarmth * glowPulse + 0.5) -- 501
		), -- 501
		Color(228, 184, 132, 0), -- 502
		18 -- 502
	) -- 502
	local shift = cam.x * 0.26 -- 503
	backdropArt:tryPlace( -- 504
		"dp_cliff_rock", -- 504
		"e5_mid_ridge_l", -- 504
		180 - shift % 140, -- 504
		backRoadY - cam:len(6), -- 504
		cam:len(185), -- 504
		cam:len(118), -- 504
		{layer = 3, opacity = 0.64} -- 504
	) -- 504
	backdropArt:tryPlace( -- 507
		"pine", -- 507
		"e5_mid_pine_r", -- 507
		w * 0.62 - shift % 180 * 0.3, -- 507
		backRoadY - cam:len(4), -- 507
		cam:len(108), -- 507
		cam:len(96), -- 507
		{layer = 3, opacity = 0.56} -- 507
	) -- 507
end -- 489
function EscortWorldRenderer.prototype.drawGatepathSetpieces(self, fgDraw, fgGlow, worldArt, p, view, cam, time, ox) -- 514
	local backDepth = p.room.depth ~= nil and p.room.depth.max or 0 -- 524
	local backY = cam:sy(0, backDepth) -- 525
	local backLayer = p.room.depth ~= nil and depthOrder(backDepth, -2) or 1 -- 526
	worldArt:tryPlace( -- 528
		"sh_stele_banner", -- 528
		"gp_banner_start", -- 528
		cam:sx(ox + 108), -- 528
		backY, -- 528
		cam:len(64), -- 528
		cam:len(70), -- 528
		{layer = backLayer, opacity = 0.9} -- 528
	) -- 528
	worldArt:tryPlace( -- 531
		"sh_stele_banner", -- 531
		"gp_stele_mid", -- 531
		cam:sx(ox + 520), -- 531
		backY, -- 531
		cam:len(52), -- 531
		cam:len(58), -- 531
		{layer = backLayer, opacity = 0.84, facing = -1} -- 531
	) -- 531
	local stepTopY = cam:sy(48, backDepth) -- 535
	local lampX = cam:sx(ox + 912) -- 536
	local poleH = cam:len(56) -- 537
	fgDraw:drawSegment( -- 538
		Vec2(lampX, stepTopY), -- 538
		Vec2(lampX, stepTopY + poleH), -- 538
		math.max( -- 538
			1.8, -- 538
			cam:len(2.4) -- 538
		), -- 538
		Color(74, 54, 38, 240) -- 538
	) -- 538
	fgDraw:drawSegment( -- 539
		Vec2(lampX, stepTopY + poleH), -- 539
		Vec2( -- 539
			lampX - cam:len(14), -- 539
			stepTopY + poleH -- 539
		), -- 539
		math.max( -- 539
			1.5, -- 539
			cam:len(2) -- 539
		), -- 539
		Color(74, 54, 38, 240) -- 539
	) -- 539
	worldArt:tryPlace( -- 540
		"prop_lantern", -- 540
		"gp_top_lantern", -- 540
		lampX - cam:len(14), -- 540
		stepTopY + poleH - cam:len(14), -- 540
		cam:len(18), -- 540
		cam:len(22), -- 540
		{layer = backLayer + 2} -- 540
	) -- 540
	local flame = 0.88 + 0.12 * math.sin(time * 3.1) -- 543
	fillRadialGlow( -- 544
		fgGlow, -- 544
		lampX - cam:len(14), -- 544
		stepTopY + poleH - cam:len(14), -- 544
		cam:len(54), -- 544
		cam:len(48), -- 544
		Color( -- 545
			246, -- 545
			192, -- 545
			114, -- 545
			math.floor(72 * flame + 0.5) -- 545
		), -- 545
		Color(246, 192, 114, 0), -- 545
		16 -- 545
	) -- 545
	if self.carryBloomT > 0 or view.backCarry.mounting then -- 545
		local k = self.carryBloomT > 0 and clamp01(self.carryBloomT / 1.15) or 0.72 -- 549
		local bx = cam:sx(p.player.x) -- 550
		local by = cam:sy(p.player.y + 42, p.player.depth) -- 551
		fillRadialGlow( -- 552
			fgGlow, -- 552
			bx, -- 552
			by, -- 552
			cam:len(96), -- 552
			cam:len(72), -- 552
			Color( -- 553
				244, -- 553
				206, -- 553
				142, -- 553
				math.floor(62 * k + 0.5) -- 553
			), -- 553
			Color(244, 206, 142, 0), -- 553
			18 -- 553
		) -- 553
	end -- 553
end -- 514
function EscortWorldRenderer.prototype.drawEscort1Setpieces(self, _fgDraw, fgGlow, worldArt, _p, cam, time, ox) -- 557
	local backDepth = LANE_DEPTH.upper + 14 -- 566
	local backY = cam:sy(0, backDepth) -- 567
	local backLayer = depthOrder(backDepth, -2) -- 568
	worldArt:tryPlace( -- 570
		"sh_stele_banner", -- 570
		"e1_banner_a", -- 570
		cam:sx(ox + 150), -- 570
		backY, -- 570
		cam:len(64), -- 570
		cam:len(72), -- 570
		{layer = backLayer, opacity = 0.9} -- 570
	) -- 570
	worldArt:tryPlace( -- 573
		"sh_stele_banner", -- 573
		"e1_banner_b", -- 573
		cam:sx(ox + 1245), -- 573
		backY, -- 573
		cam:len(60), -- 573
		cam:len(66), -- 573
		{layer = backLayer, opacity = 0.88, facing = -1} -- 573
	) -- 573
	local emberSpots = {285, 860} -- 577
	do -- 577
		local i = 0 -- 578
		while i < #emberSpots do -- 578
			local bx = cam:sx(ox + emberSpots[i + 1]) -- 579
			local pulse = 0.82 + 0.18 * math.sin(time * 4.2 + i * 1.9) -- 580
			worldArt:tryPlace( -- 581
				"dp_shadow_contact", -- 581
				"e1_brazier_sh_" .. tostring(i), -- 581
				bx, -- 581
				backY + 1, -- 581
				cam:len(26), -- 581
				cam:len(7), -- 581
				{layer = backLayer - 1, opacity = 0.76} -- 581
			) -- 581
			worldArt:tryPlace( -- 584
				"dp_brazier", -- 584
				"e1_brazier_" .. tostring(i), -- 584
				bx, -- 584
				backY, -- 584
				cam:len(26), -- 584
				cam:len(30), -- 584
				{layer = backLayer + 1} -- 584
			) -- 584
			fillRadialGlow( -- 587
				fgGlow, -- 587
				bx, -- 587
				backY + cam:len(22), -- 587
				cam:len(52), -- 587
				cam:len(40), -- 587
				Color( -- 588
					226, -- 588
					116, -- 588
					52, -- 588
					math.floor(68 * pulse + 0.5) -- 588
				), -- 588
				Color(226, 116, 52, 0), -- 588
				14 -- 588
			) -- 588
			i = i + 1 -- 578
		end -- 578
	end -- 578
end -- 557
function EscortWorldRenderer.prototype.drawEscort2Setpieces(self, _fgDraw, fgGlow, worldArt, p, cam, time, ox) -- 592
	local backDepth = LANE_DEPTH.upper + 14 -- 601
	local backY = cam:sy(0, backDepth) -- 602
	local backLayer = depthOrder(backDepth, -2) -- 603
	local sackSpots = {195, 480, 1020, 1310} -- 605
	do -- 605
		local i = 0 -- 606
		while i < #sackSpots do -- 606
			local sx = cam:sx(ox + sackSpots[i + 1]) -- 607
			worldArt:tryPlace( -- 608
				"sh_grain_sacks", -- 608
				"e2_bg_sack_" .. tostring(i), -- 608
				sx, -- 608
				backY, -- 608
				cam:len(72), -- 608
				cam:len(44), -- 608
				{ -- 608
					layer = backLayer, -- 609
					opacity = 0.78, -- 610
					facing = i % 2 == 0 and 1 or -1, -- 611
					color = Color(172, 168, 162, 255) -- 612
				} -- 612
			) -- 612
			i = i + 1 -- 606
		end -- 606
	end -- 606
	local postX = cam:sx(ox + 888) -- 616
	local postBaseY = cam:sy(0, -44) -- 617
	local postLayer = depthOrder(-44, 0) -- 618
	worldArt:tryPlace( -- 619
		"dp_shadow_contact", -- 619
		"e2_right_post_sh", -- 619
		postX, -- 619
		postBaseY + 1, -- 619
		cam:len(28), -- 619
		cam:len(9), -- 619
		{layer = postLayer - 1, opacity = 0.75} -- 619
	) -- 619
	worldArt:tryPlace( -- 622
		"fe_pillar_wood", -- 622
		"e2_right_post", -- 622
		postX, -- 622
		postBaseY, -- 622
		cam:len(22), -- 622
		cam:len(64), -- 622
		{layer = postLayer} -- 622
	) -- 622
	for ____, pk in ipairs(p.pickups) do -- 627
		do -- 627
			if pk.id == "" or p.run.taken[pk.id] then -- 627
				goto __continue71 -- 629
			end -- 629
			local px = cam:sx(pk.x) -- 631
			local py = cam:sy(pk.y + 10, pk.depth or 0) -- 632
			local pulse = 0.78 + 0.22 * math.sin(time * 3 + pk.x * 0.02) -- 633
			local col = pk.kind == "bell" and Color( -- 634
				238, -- 634
				204, -- 634
				136, -- 634
				math.floor(78 * pulse + 0.5) -- 634
			) or Color( -- 634
				224, -- 634
				168, -- 634
				92, -- 634
				math.floor(72 * pulse + 0.5) -- 634
			) -- 634
			fillRadialGlow( -- 635
				fgGlow, -- 635
				px, -- 635
				py, -- 635
				cam:len(22), -- 635
				cam:len(18), -- 635
				col, -- 635
				Color(224, 168, 92, 0), -- 635
				12 -- 635
			) -- 635
		end -- 635
		::__continue71:: -- 635
	end -- 635
end -- 592
function EscortWorldRenderer.prototype.drawEscort3WorkbenchSanctuary(self, _fgDraw, fgGlow, worldArt, p, view, cam, time, ox) -- 639
	local pulse = 0.88 + 0.12 * math.sin(time * 2.6) -- 649
	local benchCx = cam:sx(ox + 620) -- 651
	local benchDepth = -12 -- 652
	local benchBaseY = cam:sy(0, benchDepth) -- 653
	local benchLayer = depthOrder(benchDepth, 2) -- 654
	fillRadialGlow( -- 657
		fgGlow, -- 657
		benchCx, -- 657
		benchBaseY + cam:len(42), -- 657
		cam:len(168), -- 657
		cam:len(112), -- 657
		Color( -- 658
			246, -- 658
			184, -- 658
			96, -- 658
			math.floor(76 * pulse + 0.5) -- 658
		), -- 658
		Color(246, 168, 74, 0), -- 658
		20 -- 658
	) -- 658
	fillRadialGlow( -- 659
		fgGlow, -- 659
		benchCx - cam:len(22), -- 659
		benchBaseY + cam:len(68), -- 659
		cam:len(58), -- 659
		cam:len(48), -- 659
		Color( -- 660
			255, -- 660
			224, -- 660
			152, -- 660
			math.floor(115 * pulse + 0.5) -- 660
		), -- 660
		Color(255, 198, 108, 0), -- 660
		14 -- 660
	) -- 660
	worldArt:tryPlace( -- 663
		"dp_shadow_contact", -- 663
		"e3_sanctuary_bench_sh", -- 663
		benchCx, -- 663
		benchBaseY + cam:len(6), -- 663
		cam:len(136), -- 663
		cam:len(26), -- 663
		{layer = benchLayer - 1, opacity = 0.84} -- 663
	) -- 663
	worldArt:tryPlace( -- 666
		"sh_craft_workbench", -- 666
		"e3_sanctuary_bench", -- 666
		benchCx, -- 666
		benchBaseY - cam:len(2), -- 666
		cam:len(136), -- 666
		cam:len(110), -- 666
		{layer = benchLayer} -- 666
	) -- 666
	local matX = cam:sx(ox + 516) -- 671
	local matDepth = LANE_DEPTH.upper -- 672
	local matY = cam:sy(0, matDepth) -- 673
	worldArt:tryPlace( -- 674
		"sh_straw_mat", -- 674
		"e3_xiaoman_mat", -- 674
		matX, -- 674
		matY - cam:len(2), -- 674
		cam:len(64), -- 674
		cam:len(26), -- 674
		{layer = depthOrder(matDepth, 0)} -- 674
	) -- 674
	if view.backCarry.atBench or view.craftBench.active then -- 674
		fillRadialGlow( -- 678
			fgGlow, -- 678
			matX, -- 678
			matY + cam:len(22), -- 678
			cam:len(42), -- 678
			cam:len(34), -- 678
			Color( -- 679
				252, -- 679
				212, -- 679
				138, -- 679
				math.floor(68 * pulse + 0.5) -- 679
			), -- 679
			Color(252, 212, 138, 0), -- 679
			14 -- 679
		) -- 679
	end -- 679
	worldArt:tryPlace( -- 683
		"sh_stele_banner", -- 683
		"e3_entry_stele", -- 683
		cam:sx(ox + 235), -- 683
		cam:sy(0, LANE_DEPTH.upper + 14), -- 683
		cam:len(58), -- 683
		cam:len(66), -- 683
		{ -- 683
			layer = depthOrder(LANE_DEPTH.upper + 14, -1), -- 684
			opacity = 0.86 -- 684
		} -- 684
	) -- 684
	do -- 684
		local i = 0 -- 688
		while i < #p.enemies do -- 688
			do -- 688
				local en = p.enemies[i + 1] -- 689
				if en.kind ~= "target" then -- 689
					goto __continue77 -- 691
				end -- 691
				local tx = cam:sx(en.x) -- 693
				local ty = cam:sy(en.y, en.depth or 0) -- 694
				local swayK = self.gongSway[i] or 0 -- 695
				if swayK > 0.05 then -- 695
					local ringR = cam:len(18 + (1 - swayK) * 44) -- 697
					fgGlow:drawRing( -- 698
						Vec2( -- 698
							tx, -- 698
							ty + cam:len(32) -- 698
						), -- 698
						math.max(1, ringR - 1.5), -- 698
						ringR, -- 698
						Color(0, 0, 0, 0), -- 699
						1.4, -- 699
						toColor( -- 699
							PALETTE.amber, -- 699
							math.floor(190 * swayK + 0.5) -- 699
						) -- 699
					) -- 699
				end -- 699
			end -- 699
			::__continue77:: -- 699
			i = i + 1 -- 688
		end -- 688
	end -- 688
end -- 639
function EscortWorldRenderer.prototype.drawEscort4Setpieces(self, fgDraw, fgGlow, worldArt, p, cam, time, ox) -- 704
	local backDepth = LANE_DEPTH.upper + 16 -- 713
	local backY = cam:sy(0, backDepth) -- 714
	local backLayer = depthOrder(backDepth, -2) -- 715
	worldArt:tryPlace( -- 717
		"sh_stele_banner", -- 717
		"e4_stele_a", -- 717
		cam:sx(ox + 210), -- 717
		backY, -- 717
		cam:len(58), -- 717
		cam:len(66), -- 717
		{layer = backLayer, opacity = 0.9} -- 717
	) -- 717
	worldArt:tryPlace( -- 720
		"sh_stele_banner", -- 720
		"e4_stele_b", -- 720
		cam:sx(ox + 990), -- 720
		backY, -- 720
		cam:len(56), -- 720
		cam:len(64), -- 720
		{layer = backLayer, opacity = 0.88, facing = -1} -- 720
	) -- 720
	local pineXs = {310, 740, 1210} -- 724
	do -- 724
		local i = 0 -- 725
		while i < #pineXs do -- 725
			worldArt:tryPlace( -- 726
				"pine", -- 726
				"e4_cliff_pine_" .. tostring(i), -- 726
				cam:sx(ox + pineXs[i + 1]), -- 726
				backY - cam:len(4), -- 726
				cam:len(112), -- 726
				cam:len(98), -- 726
				{ -- 726
					layer = backLayer - 1, -- 727
					opacity = 0.72, -- 727
					facing = i % 2 == 0 and 1 or -1, -- 727
					color = Color(138, 152, 168, 255) -- 727
				} -- 727
			) -- 727
			i = i + 1 -- 725
		end -- 725
	end -- 725
	do -- 725
		local i = 0 -- 731
		while i < #p.enemies do -- 731
			do -- 731
				local en = p.enemies[i + 1] -- 732
				if not en.alive or en.kind ~= "gunner" then -- 732
					goto __continue84 -- 734
				end -- 734
				local gx = cam:sx(en.x - 10) -- 736
				local gy = cam:sy(en.y + en.h * 0.62, en.depth or 0) -- 737
				local ember = 0.72 + 0.28 * math.sin(time * 7.5 + i * 2.1) -- 738
				fgGlow:drawDot( -- 739
					Vec2(gx, gy), -- 739
					2.3, -- 739
					Color( -- 739
						255, -- 739
						134, -- 739
						62, -- 739
						math.floor(215 * ember + 0.5) -- 739
					) -- 739
				) -- 739
				fillRadialGlow( -- 740
					fgGlow, -- 740
					gx, -- 740
					gy, -- 740
					14, -- 740
					14, -- 740
					Color( -- 740
						242, -- 740
						108, -- 740
						46, -- 740
						math.floor(64 * ember + 0.5) -- 740
					), -- 740
					Color(242, 108, 46, 0), -- 740
					10 -- 740
				) -- 740
			end -- 740
			::__continue84:: -- 740
			i = i + 1 -- 731
		end -- 731
	end -- 731
	fgDraw:drawSegment( -- 743
		Vec2( -- 743
			cam:sx(ox + 500), -- 743
			backY + cam:len(4) -- 743
		), -- 743
		Vec2( -- 743
			cam:sx(ox + 900), -- 743
			backY + cam:len(4) -- 743
		), -- 743
		1, -- 743
		Color(110, 124, 142, 48) -- 743
	) -- 743
end -- 704
function EscortWorldRenderer.prototype.drawEscort5Setpieces(self, fgDraw, fgGlow, worldArt, _p, cam, time, ox) -- 746
	local backDepth = LANE_DEPTH.upper + 16 -- 755
	local backY = cam:sy(0, backDepth) -- 756
	local backLayer = depthOrder(backDepth, -2) -- 757
	worldArt:tryPlace( -- 759
		"sh_stele_banner", -- 759
		"e5_stele_a", -- 759
		cam:sx(ox + 215), -- 759
		backY, -- 759
		cam:len(62), -- 759
		cam:len(70), -- 759
		{layer = backLayer, opacity = 0.92} -- 759
	) -- 759
	worldArt:tryPlace( -- 762
		"pine", -- 762
		"e5_pine_a", -- 762
		cam:sx(ox + 640), -- 762
		backY - cam:len(4), -- 762
		cam:len(118), -- 762
		cam:len(102), -- 762
		{ -- 762
			layer = backLayer - 1, -- 763
			opacity = 0.78, -- 763
			color = Color(156, 168, 182, 255) -- 763
		} -- 763
	) -- 763
	local lx = cam:sx(ox + 1315) -- 766
	local poleTop = backY + cam:len(68) -- 767
	local flame = 0.88 + 0.12 * math.sin(time * 2.9) -- 768
	fgDraw:drawSegment( -- 769
		Vec2(lx, backY), -- 769
		Vec2(lx, poleTop), -- 769
		math.max( -- 769
			1.8, -- 769
			cam:len(2.4) -- 769
		), -- 769
		Color(76, 56, 40, 240) -- 769
	) -- 769
	fgDraw:drawSegment( -- 770
		Vec2(lx, poleTop), -- 770
		Vec2( -- 770
			lx - cam:len(15), -- 770
			poleTop -- 770
		), -- 770
		math.max( -- 770
			1.6, -- 770
			cam:len(2) -- 770
		), -- 770
		Color(76, 56, 40, 240) -- 770
	) -- 770
	worldArt:tryPlace( -- 771
		"prop_lantern", -- 771
		"e5_approach_lamp", -- 771
		lx - cam:len(15), -- 771
		poleTop - cam:len(14), -- 771
		cam:len(20), -- 771
		cam:len(24), -- 771
		{layer = backLayer + 2} -- 771
	) -- 771
	fillRadialGlow( -- 774
		fgGlow, -- 774
		lx - cam:len(15), -- 774
		poleTop - cam:len(14), -- 774
		cam:len(74), -- 774
		cam:len(62), -- 774
		Color( -- 775
			255, -- 775
			206, -- 775
			128, -- 775
			math.floor(92 * flame + 0.5) -- 775
		), -- 775
		Color(255, 182, 88, 0), -- 775
		16 -- 775
	) -- 775
end -- 746
return ____exports -- 746