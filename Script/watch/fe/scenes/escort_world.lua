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
	local paintedTowerSources = {{path = "assets/art/bg_escort_ridge.png", px = 568, py = 51}, {path = "assets/art/forest.png", px = 538, py = 99}, {path = "assets/art/tower.png", px = 433, py = 132}} -- 164
	local paintedWindow -- 169
	do -- 169
		local si = 0 -- 170
		while si < #paintedTowerSources do -- 170
			local src = paintedTowerSources[si + 1] -- 171
			local sp = backdropArt:currentSprite("ming_fallback_scene", src.path) or backdropArt:currentSprite("scene", src.path) -- 172
			if sp ~= nil and sp.visible and sp.opacity > 0 then -- 174
				local x = sp.x + (src.px / 640 - sp.anchor.x) * sp.width * sp.scaleX -- 176
				local y = sp.y + (1 - src.py / 360 - sp.anchor.y) * sp.height * sp.scaleY -- 177
				if x >= 0 and x <= w and y >= 0 and y <= h then -- 178
					paintedWindow = Vec2(x, y) -- 179
					break -- 180
				end -- 180
			end -- 180
			si = si + 1 -- 170
		end -- 170
	end -- 170
	self:drawDistantNorthTower( -- 184
		towerDraw, -- 184
		bgGlow, -- 184
		w, -- 184
		h, -- 184
		cam.x, -- 184
		time, -- 184
		spec, -- 184
		dynamicDawn, -- 184
		key == "escort2", -- 184
		paintedWindow -- 184
	) -- 184
	local mistShift = (time * 12 + cam.x * 0.16) % (w + 460) - 230 -- 187
	local mistCol = key == "escort3" and PALETTE.amberDim or PALETTE.jadeMist -- 188
	local mistOp = key == "escort4" and 0.24 or 0.17 -- 189
	backdropArt:tryPlace( -- 190
		"ink_mist_curve", -- 190
		"escort_mist_a", -- 190
		mistShift, -- 190
		h * 0.34, -- 190
		620, -- 190
		120, -- 190
		{ -- 190
			color = toColor(mistCol), -- 191
			opacity = mistOp, -- 191
			layer = 5 -- 191
		} -- 191
	) -- 191
	backdropArt:tryPlace( -- 193
		"ink_mist_curve", -- 193
		"escort_mist_b", -- 193
		(mistShift + w * 0.55) % (w + 460) - 230, -- 193
		h * 0.46, -- 193
		540, -- 193
		100, -- 193
		{ -- 193
			color = toColor(PALETTE.inkMist), -- 194
			opacity = mistOp * 0.85, -- 194
			layer = 5, -- 194
			facing = -1 -- 194
		} -- 194
	) -- 194
	local backRoadY = cam:sy(0, p.room.depth ~= nil and p.room.depth.max or 0) -- 198
	if key == "escort1" then -- 199
		self:drawEscort1AlleySilhouettes(backdropArt, w, backRoadY, cam) -- 200
	elseif key == "escort2" then -- 201
		self:drawEscort2GranaryRafters( -- 202
			backdropArt, -- 202
			bgGlow, -- 202
			w, -- 202
			h, -- 202
			backRoadY, -- 202
			cam, -- 202
			time -- 202
		) -- 202
	elseif key == "escort3" then -- 203
		self:drawEscort3MountainShelterBg( -- 204
			backdropArt, -- 204
			bgGlow, -- 204
			w, -- 204
			h, -- 204
			backRoadY, -- 204
			cam, -- 204
			time -- 204
		) -- 204
	elseif key == "escort4" then -- 205
		self:drawEscort4CliffGorge( -- 206
			backdropArt, -- 206
			bgGlow, -- 206
			w, -- 206
			h, -- 206
			backRoadY, -- 206
			cam, -- 206
			time -- 206
		) -- 206
	elseif key == "escort5" then -- 207
		self:drawEscort5TowerApproachBg( -- 208
			backdropArt, -- 208
			bgGlow, -- 208
			w, -- 208
			h, -- 208
			backRoadY, -- 208
			cam, -- 208
			time, -- 208
			dynamicDawn -- 208
		) -- 208
	end -- 208
end -- 114
function EscortWorldRenderer.prototype.drawWorldSetpieces(self, fgDraw, fgGlow, worldArt, p, view, cam, time) -- 213
	local key = p.room.key -- 222
	if not ____exports.isEscortWorldRoom(key) then -- 223
		return -- 224
	end -- 224
	local ox = p.ox -- 226
	if key == "gatepath" then -- 228
		self:drawGatepathSetpieces( -- 229
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
	if key == "escort1" then -- 232
		self:drawEscort1Setpieces( -- 233
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
	if key == "escort2" then -- 236
		self:drawEscort2Setpieces( -- 237
			fgDraw, -- 237
			fgGlow, -- 237
			worldArt, -- 237
			p, -- 237
			cam, -- 237
			time, -- 237
			ox -- 237
		) -- 237
		return -- 238
	end -- 238
	if key == "escort3" then -- 240
		self:drawEscort3WorkbenchSanctuary( -- 241
			fgDraw, -- 241
			fgGlow, -- 241
			worldArt, -- 241
			p, -- 241
			view, -- 241
			cam, -- 241
			time, -- 241
			ox -- 241
		) -- 241
		return -- 242
	end -- 242
	if key == "escort4" then -- 244
		self:drawEscort4Setpieces( -- 245
			fgDraw, -- 245
			fgGlow, -- 245
			worldArt, -- 245
			p, -- 245
			cam, -- 245
			time, -- 245
			ox -- 245
		) -- 245
		return -- 246
	end -- 246
	if key == "escort5" then -- 248
		self:drawEscort5Setpieces( -- 249
			fgDraw, -- 249
			fgGlow, -- 249
			worldArt, -- 249
			p, -- 249
			cam, -- 249
			time, -- 249
			ox -- 249
		) -- 249
	end -- 249
end -- 213
function EscortWorldRenderer.prototype.drawForegroundFraming(self, fgDraw, _fgGlow, worldArt, p, cam, time) -- 254
	local key = p.room.key -- 262
	if not ____exports.isEscortWorldRoom(key) then -- 263
		return -- 264
	end -- 264
	local w = cam.viewW -- 266
	local h = cam.viewH -- 267
	local parallaxX = cam.x * 1.26 -- 268
	local sway = math.sin(time * 1.6) * 4 -- 269
	if key == "escort2" then -- 272
		local tileW = 140 -- 273
		local cols = math.ceil(w / tileW) + 2 -- 274
		local offset = parallaxX * 0.18 % tileW -- 275
		do -- 275
			local c = 0 -- 276
			while c < cols do -- 276
				worldArt:tryPlace( -- 277
					"fe_beam_wood", -- 277
					"escort2_fg_top_" .. tostring(c), -- 277
					c * tileW - offset, -- 277
					h - 24, -- 277
					tileW + 2, -- 277
					26, -- 277
					{ -- 277
						layer = 5200, -- 278
						color = Color(96, 86, 80, 255), -- 278
						opacity = 0.92 -- 278
					} -- 278
				) -- 278
				c = c + 1 -- 276
			end -- 276
		end -- 276
	elseif key == "escort3" or key == "escort4" or key == "escort5" then -- 281
		worldArt:tryPlace( -- 283
			"grass_low", -- 283
			"escort_fg_bush_l", -- 283
			78 + sway * 0.4, -- 283
			-4, -- 283
			190, -- 283
			48, -- 283
			{ -- 283
				color = Color(24, 34, 42, 255), -- 284
				opacity = 0.82, -- 284
				layer = 5200 -- 284
			} -- 284
		) -- 284
		worldArt:tryPlace( -- 286
			"grass_low", -- 286
			"escort_fg_bush_r", -- 286
			w - 82 - sway * 0.35, -- 286
			-4, -- 286
			198, -- 286
			52, -- 286
			{ -- 286
				color = Color(24, 34, 42, 255), -- 287
				opacity = 0.82, -- 287
				layer = 5200, -- 287
				facing = -1 -- 287
			} -- 287
		) -- 287
	end -- 287
	local stride = 280 -- 292
	local startSlot = math.floor((parallaxX - 200) / stride) -- 293
	do -- 293
		local s = startSlot -- 294
		while s <= startSlot + 6 do -- 294
			do -- 294
				local sx = s * stride - parallaxX + w * 0.5 -- 295
				if sx < -140 or sx > w + 140 then -- 296
					goto __continue47 -- 297
				end -- 297
				local hSeed = math.abs(math.sin(s * 12.9898) * 43758.5453) % 1 -- 299
				local rockH = 18 + hSeed * 14 -- 300
				local rockW = 68 + hSeed * 36 -- 301
				worldArt:tryPlace( -- 302
					"dp_fg_rock", -- 302
					"escort_fg_rock_" .. tostring(s - startSlot), -- 302
					sx, -- 302
					-2, -- 302
					rockW, -- 302
					rockH, -- 302
					{layer = 5190, opacity = 0.88, facing = s % 2 == 0 and 1 or -1} -- 302
				) -- 302
			end -- 302
			::__continue47:: -- 302
			s = s + 1 -- 294
		end -- 294
	end -- 294
end -- 254
function EscortWorldRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, camX, time, spec, dawnWarmth, behindWindow, paintedWindow) -- 312
	local s = spec.scale -- 324
	local tx = w * spec.screenXFrac - camX * 0.045 -- 325
	local ty = h * spec.screenYFrac -- 326
	local pulse = 0.86 + 0.14 * math.sin(time * 2.5) -- 327
	local alphaMul = behindWindow and 0.62 or 1 -- 328
	local topW = 34 * s -- 330
	local bodyH = 62 * s -- 331
	if paintedWindow == nil then -- 332
		local ridgeW = 190 * s + 95 -- 334
		local ridgeH = 44 * s + 22 -- 335
		local ridgeCol = Color( -- 336
			math.floor(20 + dawnWarmth * 16 + 0.5), -- 337
			math.floor(26 + dawnWarmth * 14 + 0.5), -- 338
			math.floor(38 + dawnWarmth * 8 + 0.5), -- 339
			math.floor(188 * alphaMul + 0.5) -- 340
		) -- 340
		bgDraw:drawPolygon( -- 342
			{ -- 342
				Vec2(tx - ridgeW, ty - ridgeH), -- 343
				Vec2(tx + ridgeW * 0.72, ty - ridgeH), -- 344
				Vec2(tx + ridgeW * 0.16, ty + 6 * s), -- 345
				Vec2(tx - ridgeW * 0.32, ty + 2 * s) -- 346
			}, -- 346
			ridgeCol -- 347
		) -- 347
		local baseW = 44 * s -- 350
		local towerCol = Color( -- 351
			math.floor(24 + dawnWarmth * 14 + 0.5), -- 352
			math.floor(30 + dawnWarmth * 12 + 0.5), -- 353
			math.floor(42 + dawnWarmth * 8 + 0.5), -- 354
			math.floor(225 * alphaMul + 0.5) -- 355
		) -- 355
		local rimCol = Color( -- 357
			138, -- 357
			148, -- 357
			166, -- 357
			math.floor(68 * alphaMul + 0.5) -- 357
		) -- 357
		bgDraw:drawPolygon( -- 358
			{ -- 358
				Vec2(tx - baseW * 0.5, ty - 4 * s), -- 359
				Vec2(tx + baseW * 0.5, ty - 4 * s), -- 360
				Vec2(tx + topW * 0.5, ty + bodyH), -- 361
				Vec2(tx - topW * 0.5, ty + bodyH) -- 362
			}, -- 362
			towerCol, -- 363
			0.8, -- 363
			rimCol -- 363
		) -- 363
		local pavH = 18 * s -- 366
		local eaveY = ty + bodyH + pavH -- 367
		local eaveW = 54 * s -- 368
		bgDraw:drawRect( -- 369
			Rect(tx - topW * 0.38, ty + bodyH, 3 * s, pavH), -- 369
			towerCol -- 369
		) -- 369
		bgDraw:drawRect( -- 370
			Rect(tx + topW * 0.38 - 3 * s, ty + bodyH, 3 * s, pavH), -- 370
			towerCol -- 370
		) -- 370
		bgDraw:drawPolygon( -- 371
			{ -- 371
				Vec2(tx - eaveW * 0.54, eaveY - 2 * s), -- 372
				Vec2(tx + eaveW * 0.54, eaveY - 2 * s), -- 373
				Vec2(tx + eaveW * 0.24, eaveY + 13 * s), -- 374
				Vec2(tx - eaveW * 0.24, eaveY + 13 * s) -- 375
			}, -- 375
			Color( -- 376
				18, -- 376
				22, -- 376
				32, -- 376
				math.floor(238 * alphaMul + 0.5) -- 376
			), -- 376
			0.8, -- 376
			rimCol -- 376
		) -- 376
	end -- 376
	local lampX = paintedWindow and paintedWindow.x or tx - topW * 0.14 -- 380
	local lampY = paintedWindow and paintedWindow.y or ty + bodyH * 0.64 -- 381
	local glowR = spec.beaconR * pulse -- 382
	fillRadialGlow( -- 383
		bgGlow, -- 383
		lampX, -- 383
		lampY, -- 383
		glowR * 1.35, -- 383
		glowR, -- 383
		Color( -- 384
			255, -- 384
			206, -- 384
			122, -- 384
			math.floor(92 * pulse * alphaMul + 0.5) -- 384
		), -- 384
		Color(255, 178, 86, 0), -- 385
		16 -- 385
	) -- 385
	fillRadialGlow( -- 386
		bgGlow, -- 386
		lampX, -- 386
		lampY, -- 386
		glowR * 0.48, -- 386
		glowR * 0.42, -- 386
		Color( -- 387
			255, -- 387
			238, -- 387
			184, -- 387
			math.floor(176 * pulse * alphaMul + 0.5) -- 387
		), -- 387
		Color(255, 204, 118, 0), -- 388
		12 -- 388
	) -- 388
	bgGlow:drawDot( -- 389
		Vec2(lampX, lampY), -- 389
		math.max(1.8, 3.6 * s), -- 389
		Color( -- 389
			255, -- 389
			246, -- 389
			212, -- 389
			math.floor(248 * alphaMul + 0.5) -- 389
		) -- 389
	) -- 389
end -- 312
function EscortWorldRenderer.prototype.drawEscort1AlleySilhouettes(self, backdropArt, w, backRoadY, cam) -- 394
	local shift = cam.x * 0.34 -- 395
	local houses = {{x = 160, w = 158, h = 140, slot = "dp_ruin_house_a"}, {x = 470, w = 146, h = 132, slot = "dp_ruin_house_b"}, {x = 800, w = 154, h = 136, slot = "dp_ruin_house_a"}, {x = 1120, w = 142, h = 128, slot = "dp_ruin_house_b"}} -- 396
	do -- 396
		local i = 0 -- 402
		while i < #houses do -- 402
			local hs = houses[i + 1] -- 403
			local sx = ((hs.x - shift) % (w + 340) + (w + 340)) % (w + 340) - 170 -- 404
			backdropArt:tryPlace( -- 405
				hs.slot, -- 405
				"e1_mid_house_" .. tostring(i), -- 405
				sx, -- 405
				backRoadY - cam:len(4), -- 405
				cam:len(hs.w * 0.82), -- 405
				cam:len(hs.h * 0.82), -- 405
				{layer = 3, opacity = 0.72, facing = i % 2 == 0 and 1 or -1} -- 405
			) -- 405
			i = i + 1 -- 402
		end -- 402
	end -- 402
end -- 394
function EscortWorldRenderer.prototype.drawEscort2GranaryRafters(self, backdropArt, bgGlow, w, h, backRoadY, cam, time) -- 411
	local shift = cam.x * 0.38 -- 420
	local span = 290 -- 421
	local first = math.floor((shift - 180) / span) -- 422
	local pillarH = math.max(120, h - backRoadY + 12) -- 423
	do -- 423
		local k = first -- 424
		while k <= first + 6 do -- 424
			local bx = k * span - shift -- 425
			backdropArt:tryPlace( -- 427
				"dp_granary_pillar", -- 427
				"e2_mid_pillar_" .. tostring(k - first), -- 427
				bx, -- 427
				backRoadY - cam:len(2), -- 427
				cam:len(26), -- 427
				pillarH, -- 427
				{layer = 3, opacity = 0.76} -- 427
			) -- 427
			if math.abs(k) % 2 == 0 then -- 431
				local topX = bx + span * 0.44 -- 432
				local pulse = 0.86 + 0.14 * math.sin(time * 1.1 + k) -- 433
				local midA = math.floor(28 * pulse + 0.5) -- 434
				local topA = math.floor(12 * pulse + 0.5) -- 435
				fillGradQuad( -- 436
					bgGlow, -- 437
					topX - 20, -- 438
					h + 10, -- 438
					Color(168, 194, 224, topA), -- 438
					topX + 36, -- 439
					h + 10, -- 439
					Color(168, 194, 224, topA), -- 439
					topX + 94, -- 440
					h * 0.48, -- 440
					Color(176, 202, 232, midA), -- 440
					topX + 8, -- 441
					h * 0.48, -- 441
					Color(176, 202, 232, midA) -- 441
				) -- 441
				fillGradQuad( -- 443
					bgGlow, -- 444
					topX + 8, -- 445
					h * 0.48, -- 445
					Color(176, 202, 232, midA), -- 445
					topX + 94, -- 446
					h * 0.48, -- 446
					Color(176, 202, 232, midA), -- 446
					topX + 136, -- 447
					backRoadY, -- 447
					Color(168, 194, 224, 0), -- 447
					topX + 30, -- 448
					backRoadY, -- 448
					Color(168, 194, 224, 0) -- 448
				) -- 448
				do -- 448
					local d = 0 -- 450
					while d < 4 do -- 450
						local phase = (time * 0.18 + d * 0.27 + k * 0.31) % 1 -- 451
						local dx = topX + 12 + phase * 76 + math.sin(time * 1.4 + d) * 8 -- 452
						local dy = h * (0.9 - phase * 0.64) -- 453
						bgGlow:drawDot( -- 454
							Vec2(dx, dy), -- 454
							1.5, -- 454
							Color( -- 454
								214, -- 454
								222, -- 454
								232, -- 454
								math.floor(58 * math.sin(phase * math.pi) + 0.5) -- 454
							) -- 454
						) -- 454
						d = d + 1 -- 450
					end -- 450
				end -- 450
			end -- 450
			k = k + 1 -- 424
		end -- 424
	end -- 424
end -- 411
function EscortWorldRenderer.prototype.drawEscort3MountainShelterBg(self, backdropArt, bgGlow, w, h, backRoadY, cam, time) -- 460
	local cliffX = 240 - cam.x * 0.26 -- 469
	backdropArt:tryPlace( -- 470
		"dp_cliff_rock", -- 470
		"e3_mid_cliff", -- 470
		cliffX, -- 470
		backRoadY - cam:len(6), -- 470
		cam:len(220), -- 470
		cam:len(165), -- 470
		{layer = 3, opacity = 0.72} -- 470
	) -- 470
	local warmPulse = 0.9 + 0.1 * math.sin(time * 2.1) -- 473
	fillRadialGlow( -- 474
		bgGlow, -- 474
		w * 0.5, -- 474
		backRoadY + cam:len(54), -- 474
		w * 0.26, -- 474
		h * 0.24, -- 474
		Color( -- 475
			224, -- 475
			164, -- 475
			88, -- 475
			math.floor(30 * warmPulse + 0.5) -- 475
		), -- 475
		Color(224, 164, 88, 0), -- 475
		16 -- 475
	) -- 475
end -- 460
function EscortWorldRenderer.prototype.drawEscort4CliffGorge(self, backdropArt, bgGlow, w, h, backRoadY, cam, time) -- 478
	local shift = cam.x * 0.3 -- 487
	do -- 487
		local i = 0 -- 488
		while i < 4 do -- 488
			local px = ((i * 380 - shift) % (w + 420) + (w + 420)) % (w + 420) - 210 -- 489
			backdropArt:tryPlace( -- 490
				"dp_cliff_rock", -- 490
				"e4_mid_cliff_" .. tostring(i), -- 490
				px, -- 490
				backRoadY - cam:len(6), -- 490
				cam:len(176), -- 490
				cam:len(132 + i % 2 * 26), -- 490
				{layer = 3, opacity = 0.68, facing = i % 2 == 0 and 1 or -1} -- 490
			) -- 490
			i = i + 1 -- 488
		end -- 488
	end -- 488
	local cloudX = time * 22 % (w + 420) - 210 -- 494
	backdropArt:tryPlace( -- 495
		"ink_mist_curve", -- 495
		"e4_wind_cloud", -- 495
		cloudX, -- 495
		h * 0.8, -- 495
		320, -- 495
		52, -- 495
		{ -- 495
			color = Color(142, 164, 192, 255), -- 496
			opacity = 0.18, -- 496
			layer = 4 -- 496
		} -- 496
	) -- 496
end -- 478
function EscortWorldRenderer.prototype.drawEscort5TowerApproachBg(self, backdropArt, bgGlow, w, h, backRoadY, cam, time, dawnWarmth) -- 500
	local glowPulse = 0.88 + 0.12 * math.sin(time * 1.8) -- 510
	fillRadialGlow( -- 511
		bgGlow, -- 511
		w * 0.78, -- 511
		h * 0.48, -- 511
		w * 0.42, -- 511
		h * 0.3, -- 511
		Color( -- 512
			228, -- 512
			184, -- 512
			132, -- 512
			math.floor(44 * dawnWarmth * glowPulse + 0.5) -- 512
		), -- 512
		Color(228, 184, 132, 0), -- 513
		18 -- 513
	) -- 513
	local shift = cam.x * 0.26 -- 514
	backdropArt:tryPlace( -- 515
		"dp_cliff_rock", -- 515
		"e5_mid_ridge_l", -- 515
		180 - shift % 140, -- 515
		backRoadY - cam:len(6), -- 515
		cam:len(185), -- 515
		cam:len(118), -- 515
		{layer = 3, opacity = 0.64} -- 515
	) -- 515
	backdropArt:tryPlace( -- 518
		"pine", -- 518
		"e5_mid_pine_r", -- 518
		w * 0.62 - shift % 180 * 0.3, -- 518
		backRoadY - cam:len(4), -- 518
		cam:len(108), -- 518
		cam:len(96), -- 518
		{layer = 3, opacity = 0.56} -- 518
	) -- 518
end -- 500
function EscortWorldRenderer.prototype.drawGatepathSetpieces(self, fgDraw, fgGlow, worldArt, p, view, cam, time, ox) -- 525
	local backDepth = p.room.depth ~= nil and p.room.depth.max or 0 -- 535
	local backY = cam:sy(0, backDepth) -- 536
	local backLayer = p.room.depth ~= nil and depthOrder(backDepth, -2) or 1 -- 537
	worldArt:tryPlace( -- 539
		"sh_stele_banner", -- 539
		"gp_banner_start", -- 539
		cam:sx(ox + 108), -- 539
		backY, -- 539
		cam:len(64), -- 539
		cam:len(70), -- 539
		{layer = backLayer, opacity = 0.9} -- 539
	) -- 539
	worldArt:tryPlace( -- 542
		"sh_stele_banner", -- 542
		"gp_stele_mid", -- 542
		cam:sx(ox + 520), -- 542
		backY, -- 542
		cam:len(52), -- 542
		cam:len(58), -- 542
		{layer = backLayer, opacity = 0.84, facing = -1} -- 542
	) -- 542
	local stepTopY = cam:sy(48, backDepth) -- 546
	local lampX = cam:sx(ox + 912) -- 547
	local poleH = cam:len(56) -- 548
	fgDraw:drawSegment( -- 549
		Vec2(lampX, stepTopY), -- 549
		Vec2(lampX, stepTopY + poleH), -- 549
		math.max( -- 549
			1.8, -- 549
			cam:len(2.4) -- 549
		), -- 549
		Color(74, 54, 38, 240) -- 549
	) -- 549
	fgDraw:drawSegment( -- 550
		Vec2(lampX, stepTopY + poleH), -- 550
		Vec2( -- 550
			lampX - cam:len(14), -- 550
			stepTopY + poleH -- 550
		), -- 550
		math.max( -- 550
			1.5, -- 550
			cam:len(2) -- 550
		), -- 550
		Color(74, 54, 38, 240) -- 550
	) -- 550
	worldArt:tryPlace( -- 551
		"prop_lantern", -- 551
		"gp_top_lantern", -- 551
		lampX - cam:len(14), -- 551
		stepTopY + poleH - cam:len(14), -- 551
		cam:len(18), -- 551
		cam:len(22), -- 551
		{layer = backLayer + 2} -- 551
	) -- 551
	local flame = 0.88 + 0.12 * math.sin(time * 3.1) -- 554
	fillRadialGlow( -- 555
		fgGlow, -- 555
		lampX - cam:len(14), -- 555
		stepTopY + poleH - cam:len(14), -- 555
		cam:len(54), -- 555
		cam:len(48), -- 555
		Color( -- 556
			246, -- 556
			192, -- 556
			114, -- 556
			math.floor(72 * flame + 0.5) -- 556
		), -- 556
		Color(246, 192, 114, 0), -- 556
		16 -- 556
	) -- 556
	if self.carryBloomT > 0 or view.backCarry.mounting then -- 559
		local k = self.carryBloomT > 0 and clamp01(self.carryBloomT / 1.15) or 0.72 -- 560
		local bx = cam:sx(p.player.x) -- 561
		local by = cam:sy(p.player.y + 42, p.player.depth) -- 562
		fillRadialGlow( -- 563
			fgGlow, -- 563
			bx, -- 563
			by, -- 563
			cam:len(96), -- 563
			cam:len(72), -- 563
			Color( -- 564
				244, -- 564
				206, -- 564
				142, -- 564
				math.floor(62 * k + 0.5) -- 564
			), -- 564
			Color(244, 206, 142, 0), -- 564
			18 -- 564
		) -- 564
	end -- 564
end -- 525
function EscortWorldRenderer.prototype.drawEscort1Setpieces(self, _fgDraw, fgGlow, worldArt, _p, cam, time, ox) -- 568
	local backDepth = LANE_DEPTH.upper + 14 -- 577
	local backY = cam:sy(0, backDepth) -- 578
	local backLayer = depthOrder(backDepth, -2) -- 579
	worldArt:tryPlace( -- 581
		"sh_stele_banner", -- 581
		"e1_banner_a", -- 581
		cam:sx(ox + 150), -- 581
		backY, -- 581
		cam:len(64), -- 581
		cam:len(72), -- 581
		{layer = backLayer, opacity = 0.9} -- 581
	) -- 581
	worldArt:tryPlace( -- 584
		"sh_stele_banner", -- 584
		"e1_banner_b", -- 584
		cam:sx(ox + 1245), -- 584
		backY, -- 584
		cam:len(60), -- 584
		cam:len(66), -- 584
		{layer = backLayer, opacity = 0.88, facing = -1} -- 584
	) -- 584
end -- 568
function EscortWorldRenderer.prototype.drawEscort2Setpieces(self, _fgDraw, fgGlow, worldArt, p, cam, time, ox) -- 590
	local backDepth = LANE_DEPTH.upper + 14 -- 599
	local backY = cam:sy(0, backDepth) -- 600
	local backLayer = depthOrder(backDepth, -2) -- 601
	local sackSpots = {195, 480, 1020, 1310} -- 603
	do -- 603
		local i = 0 -- 604
		while i < #sackSpots do -- 604
			local sx = cam:sx(ox + sackSpots[i + 1]) -- 605
			worldArt:tryPlace( -- 606
				"sh_grain_sacks", -- 606
				"e2_bg_sack_" .. tostring(i), -- 606
				sx, -- 606
				backY, -- 606
				cam:len(72), -- 606
				cam:len(44), -- 606
				{ -- 606
					layer = backLayer, -- 607
					opacity = 0.78, -- 608
					facing = i % 2 == 0 and 1 or -1, -- 609
					color = Color(172, 168, 162, 255) -- 610
				} -- 610
			) -- 610
			i = i + 1 -- 604
		end -- 604
	end -- 604
	local postX = cam:sx(ox + 888) -- 614
	local postBaseY = cam:sy(0, -44) -- 615
	local postLayer = depthOrder(-44, 0) -- 616
	worldArt:tryPlace( -- 617
		"dp_shadow_contact", -- 617
		"e2_right_post_sh", -- 617
		postX, -- 617
		postBaseY + 1, -- 617
		cam:len(28), -- 617
		cam:len(9), -- 617
		{layer = postLayer - 1, opacity = 0.75} -- 617
	) -- 617
	worldArt:tryPlace( -- 620
		"fe_pillar_wood", -- 620
		"e2_right_post", -- 620
		postX, -- 620
		postBaseY, -- 620
		cam:len(22), -- 620
		cam:len(64), -- 620
		{layer = postLayer} -- 620
	) -- 620
	for ____, pk in ipairs(p.pickups) do -- 625
		do -- 625
			if pk.id == "" or p.run.taken[pk.id] then -- 626
				goto __continue71 -- 627
			end -- 627
			local px = cam:sx(pk.x) -- 629
			local py = cam:sy(pk.y + 10, pk.depth or 0) -- 630
			local pulse = 0.78 + 0.22 * math.sin(time * 3 + pk.x * 0.02) -- 631
			local col = pk.kind == "bell" and Color( -- 632
				238, -- 632
				204, -- 632
				136, -- 632
				math.floor(78 * pulse + 0.5) -- 632
			) or Color( -- 632
				224, -- 632
				168, -- 632
				92, -- 632
				math.floor(72 * pulse + 0.5) -- 632
			) -- 632
			fillRadialGlow( -- 633
				fgGlow, -- 633
				px, -- 633
				py, -- 633
				cam:len(22), -- 633
				cam:len(18), -- 633
				col, -- 633
				Color(224, 168, 92, 0), -- 633
				12 -- 633
			) -- 633
		end -- 633
		::__continue71:: -- 633
	end -- 633
end -- 590
function EscortWorldRenderer.prototype.drawEscort3WorkbenchSanctuary(self, _fgDraw, fgGlow, worldArt, p, view, cam, time, ox) -- 637
	local pulse = 0.88 + 0.12 * math.sin(time * 2.6) -- 647
	local benchCx = cam:sx(ox + 620) -- 649
	local benchDepth = -12 -- 650
	local benchBaseY = cam:sy(0, benchDepth) -- 651
	local benchLayer = depthOrder(benchDepth, 2) -- 652
	fillRadialGlow( -- 655
		fgGlow, -- 655
		benchCx, -- 655
		benchBaseY + cam:len(42), -- 655
		cam:len(168), -- 655
		cam:len(112), -- 655
		Color( -- 656
			246, -- 656
			184, -- 656
			96, -- 656
			math.floor(76 * pulse + 0.5) -- 656
		), -- 656
		Color(246, 168, 74, 0), -- 656
		20 -- 656
	) -- 656
	fillRadialGlow( -- 657
		fgGlow, -- 657
		benchCx - cam:len(22), -- 657
		benchBaseY + cam:len(68), -- 657
		cam:len(58), -- 657
		cam:len(48), -- 657
		Color( -- 658
			255, -- 658
			224, -- 658
			152, -- 658
			math.floor(115 * pulse + 0.5) -- 658
		), -- 658
		Color(255, 198, 108, 0), -- 658
		14 -- 658
	) -- 658
	worldArt:tryPlace( -- 661
		"dp_shadow_contact", -- 661
		"e3_sanctuary_bench_sh", -- 661
		benchCx, -- 661
		benchBaseY + cam:len(6), -- 661
		cam:len(136), -- 661
		cam:len(26), -- 661
		{layer = benchLayer - 1, opacity = 0.84} -- 661
	) -- 661
	worldArt:tryPlace( -- 664
		"sh_craft_workbench", -- 664
		"e3_sanctuary_bench", -- 664
		benchCx, -- 664
		benchBaseY - cam:len(2), -- 664
		cam:len(136), -- 664
		cam:len(110), -- 664
		{layer = benchLayer} -- 664
	) -- 664
	local matX = cam:sx(ox + 516) -- 669
	local matDepth = LANE_DEPTH.upper -- 670
	local matY = cam:sy(0, matDepth) -- 671
	worldArt:tryPlace( -- 672
		"sh_straw_mat", -- 672
		"e3_xiaoman_mat", -- 672
		matX, -- 672
		matY - cam:len(2), -- 672
		cam:len(64), -- 672
		cam:len(26), -- 672
		{layer = depthOrder(matDepth, 0)} -- 672
	) -- 672
	if view.backCarry.atBench or view.craftBench.active then -- 675
		fillRadialGlow( -- 676
			fgGlow, -- 676
			matX, -- 676
			matY + cam:len(22), -- 676
			cam:len(42), -- 676
			cam:len(34), -- 676
			Color( -- 677
				252, -- 677
				212, -- 677
				138, -- 677
				math.floor(68 * pulse + 0.5) -- 677
			), -- 677
			Color(252, 212, 138, 0), -- 677
			14 -- 677
		) -- 677
	end -- 677
	worldArt:tryPlace( -- 681
		"sh_stele_banner", -- 681
		"e3_entry_stele", -- 681
		cam:sx(ox + 235), -- 681
		cam:sy(0, LANE_DEPTH.upper + 14), -- 681
		cam:len(58), -- 681
		cam:len(66), -- 681
		{ -- 681
			layer = depthOrder(LANE_DEPTH.upper + 14, -1), -- 682
			opacity = 0.86 -- 682
		} -- 682
	) -- 682
	do -- 682
		local i = 0 -- 686
		while i < #p.enemies do -- 686
			do -- 686
				local en = p.enemies[i + 1] -- 687
				if en.kind ~= "target" then -- 688
					goto __continue77 -- 689
				end -- 689
				local tx = cam:sx(en.x) -- 691
				local ty = cam:sy(en.y, en.depth or 0) -- 692
				local swayK = self.gongSway[i] or 0 -- 693
				if swayK > 0.05 then -- 694
					local ringR = cam:len(18 + (1 - swayK) * 44) -- 695
					fgGlow:drawRing( -- 696
						Vec2( -- 696
							tx, -- 696
							ty + cam:len(32) -- 696
						), -- 696
						math.max(1, ringR - 1.5), -- 696
						ringR, -- 696
						Color(0, 0, 0, 0), -- 697
						1.4, -- 697
						toColor( -- 697
							PALETTE.amber, -- 697
							math.floor(190 * swayK + 0.5) -- 697
						) -- 697
					) -- 697
				end -- 697
			end -- 697
			::__continue77:: -- 697
			i = i + 1 -- 686
		end -- 686
	end -- 686
end -- 637
function EscortWorldRenderer.prototype.drawEscort4Setpieces(self, fgDraw, fgGlow, worldArt, p, cam, time, ox) -- 702
	local backDepth = LANE_DEPTH.upper + 16 -- 711
	local backY = cam:sy(0, backDepth) -- 712
	local backLayer = depthOrder(backDepth, -2) -- 713
	worldArt:tryPlace( -- 715
		"sh_stele_banner", -- 715
		"e4_stele_a", -- 715
		cam:sx(ox + 210), -- 715
		backY, -- 715
		cam:len(58), -- 715
		cam:len(66), -- 715
		{layer = backLayer, opacity = 0.9} -- 715
	) -- 715
	worldArt:tryPlace( -- 718
		"sh_stele_banner", -- 718
		"e4_stele_b", -- 718
		cam:sx(ox + 990), -- 718
		backY, -- 718
		cam:len(56), -- 718
		cam:len(64), -- 718
		{layer = backLayer, opacity = 0.88, facing = -1} -- 718
	) -- 718
	local pineXs = {310, 740, 1210} -- 722
	do -- 722
		local i = 0 -- 723
		while i < #pineXs do -- 723
			worldArt:tryPlace( -- 724
				"pine", -- 724
				"e4_cliff_pine_" .. tostring(i), -- 724
				cam:sx(ox + pineXs[i + 1]), -- 724
				backY - cam:len(4), -- 724
				cam:len(112), -- 724
				cam:len(98), -- 724
				{ -- 724
					layer = backLayer - 1, -- 725
					opacity = 0.72, -- 725
					facing = i % 2 == 0 and 1 or -1, -- 725
					color = Color(138, 152, 168, 255) -- 725
				} -- 725
			) -- 725
			i = i + 1 -- 723
		end -- 723
	end -- 723
	do -- 723
		local i = 0 -- 729
		while i < #p.enemies do -- 729
			do -- 729
				local en = p.enemies[i + 1] -- 730
				if not en.alive or en.kind ~= "gunner" then -- 731
					goto __continue84 -- 732
				end -- 732
				local gx = cam:sx(en.x - 10) -- 734
				local gy = cam:sy(en.y + en.h * 0.62, en.depth or 0) -- 735
				local ember = 0.72 + 0.28 * math.sin(time * 7.5 + i * 2.1) -- 736
				fgGlow:drawDot( -- 737
					Vec2(gx, gy), -- 737
					2.3, -- 737
					Color( -- 737
						255, -- 737
						134, -- 737
						62, -- 737
						math.floor(215 * ember + 0.5) -- 737
					) -- 737
				) -- 737
				fillRadialGlow( -- 738
					fgGlow, -- 738
					gx, -- 738
					gy, -- 738
					14, -- 738
					14, -- 738
					Color( -- 738
						242, -- 738
						108, -- 738
						46, -- 738
						math.floor(64 * ember + 0.5) -- 738
					), -- 738
					Color(242, 108, 46, 0), -- 738
					10 -- 738
				) -- 738
			end -- 738
			::__continue84:: -- 738
			i = i + 1 -- 729
		end -- 729
	end -- 729
	fgDraw:drawSegment( -- 741
		Vec2( -- 741
			cam:sx(ox + 500), -- 741
			backY + cam:len(4) -- 741
		), -- 741
		Vec2( -- 741
			cam:sx(ox + 900), -- 741
			backY + cam:len(4) -- 741
		), -- 741
		1, -- 741
		Color(110, 124, 142, 48) -- 741
	) -- 741
end -- 702
function EscortWorldRenderer.prototype.drawEscort5Setpieces(self, fgDraw, fgGlow, worldArt, _p, cam, time, ox) -- 744
	local backDepth = LANE_DEPTH.upper + 16 -- 753
	local backY = cam:sy(0, backDepth) -- 754
	local backLayer = depthOrder(backDepth, -2) -- 755
	worldArt:tryPlace( -- 757
		"sh_stele_banner", -- 757
		"e5_stele_a", -- 757
		cam:sx(ox + 215), -- 757
		backY, -- 757
		cam:len(62), -- 757
		cam:len(70), -- 757
		{layer = backLayer, opacity = 0.92} -- 757
	) -- 757
	worldArt:tryPlace( -- 760
		"pine", -- 760
		"e5_pine_a", -- 760
		cam:sx(ox + 640), -- 760
		backY - cam:len(4), -- 760
		cam:len(118), -- 760
		cam:len(102), -- 760
		{ -- 760
			layer = backLayer - 1, -- 761
			opacity = 0.78, -- 761
			color = Color(156, 168, 182, 255) -- 761
		} -- 761
	) -- 761
	local lx = cam:sx(ox + 1315) -- 764
	local poleTop = backY + cam:len(68) -- 765
	local flame = 0.88 + 0.12 * math.sin(time * 2.9) -- 766
	fgDraw:drawSegment( -- 767
		Vec2(lx, backY), -- 767
		Vec2(lx, poleTop), -- 767
		math.max( -- 767
			1.8, -- 767
			cam:len(2.4) -- 767
		), -- 767
		Color(76, 56, 40, 240) -- 767
	) -- 767
	fgDraw:drawSegment( -- 768
		Vec2(lx, poleTop), -- 768
		Vec2( -- 768
			lx - cam:len(15), -- 768
			poleTop -- 768
		), -- 768
		math.max( -- 768
			1.6, -- 768
			cam:len(2) -- 768
		), -- 768
		Color(76, 56, 40, 240) -- 768
	) -- 768
	worldArt:tryPlace( -- 769
		"prop_lantern", -- 769
		"e5_approach_lamp", -- 769
		lx - cam:len(15), -- 769
		poleTop - cam:len(14), -- 769
		cam:len(20), -- 769
		cam:len(24), -- 769
		{layer = backLayer + 2} -- 769
	) -- 769
	fillRadialGlow( -- 772
		fgGlow, -- 772
		lx - cam:len(15), -- 772
		poleTop - cam:len(14), -- 772
		cam:len(74), -- 772
		cam:len(62), -- 772
		Color( -- 773
			255, -- 773
			206, -- 773
			128, -- 773
			math.floor(92 * flame + 0.5) -- 773
		), -- 773
		Color(255, 182, 88, 0), -- 773
		16 -- 773
	) -- 773
end -- 744
return ____exports -- 744
