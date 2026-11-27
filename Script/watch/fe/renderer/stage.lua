-- [ts]: stage.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Color = ____Dora.Color -- 3
local Rect = ____Dora.Rect -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____depth = require("Script.watch.depth") -- 5
local LANE_DEPTH = ____depth.LANE_DEPTH -- 5
local ____occlusion = require("Script.watch.fe.occlusion") -- 9
local depthOrder = ____occlusion.depthOrder -- 9
local occlusionTint = ____occlusion.occlusionTint -- 9
local ____theme = require("Script.watch.fe.theme") -- 10
local PALETTE = ____theme.PALETTE -- 11
local fillRadialGlow = ____theme.fillRadialGlow -- 15
local fillVGradRect = ____theme.fillVGradRect -- 16
local lerpRGBA = ____theme.lerpRGBA -- 17
local themeOf = ____theme.themeOf -- 18
local toColor = ____theme.toColor -- 19
--- 确定性伪随机（避免跨帧闪烁）
local function hash01(seed) -- 23
	local x = math.sin(seed * 127.1 + 311.7) * 43758.5453 -- 24
	return x - math.floor(x) -- 25
end -- 23
--- 根据房间名取一个稳定数值种子
local function roomSeed(key) -- 29
	local h = 17 -- 30
	local i = 0 -- 31
	do -- 31
		i = 0 -- 32
		while i < #key do -- 32
			h = (h * 31 + __TS__StringCharCodeAt(key, i)) % 9973 -- 33
			i = i + 1 -- 32
		end -- 32
	end -- 32
	return h -- 35
end -- 29
--- 将特定明代场景道具（空筐墙/粮袋堆/木帘/窗板/石井栏）映射至专属 props_ming.clip 手绘精灵，避免退化为通用砖木块
local function dedicatedSolidProp(solid) -- 46
	if solid.art == "basket_wall" then -- 46
		return {clip = "basket_wall", natAR = 144 / 90, heightMul = 1.08, tileable = true} -- 48
	end -- 48
	if solid.art == "curtain" then -- 48
		return {clip = "curtain", natAR = 144 / 126, heightMul = 1.06, tileable = false} -- 51
	end -- 51
	if solid.art == "board" then -- 51
		return {clip = "window_board", natAR = 88 / 144, heightMul = 1.04, tileable = false} -- 54
	end -- 54
	if solid.id == "s1_well" or solid.art == "well" or (string.find(solid.label, "井背", nil, true) or 0) - 1 >= 0 then -- 54
		return {clip = "well_curb", natAR = 144 / 120, heightMul = 1.12, tileable = false} -- 57
	end -- 57
	if solid.art == "grain_sack" or (string.find(solid.label, "粮台", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "粮袋", nil, true) or 0) - 1 >= 0 then -- 57
		return {clip = "grain_sack", natAR = 144 / 74, heightMul = 1.12, tileable = true} -- 60
	end -- 60
	return nil -- 62
end -- 46
local function coverArt(solid) -- 65
	if solid.art == "gate_post" or solid.art == "wall" or solid.art == "latch" then -- 65
		return "wall" -- 67
	end -- 67
	if solid.art == "thin_wood" or solid.art == "board" or solid.art == "cover_wood" then -- 67
		return "cover_wood" -- 70
	end -- 70
	if solid.art == "fence" then -- 70
		return "fence" -- 73
	end -- 73
	return ((string.find(solid.label, "柜", nil, true) or 0) - 1 >= 0 or (string.find(solid.label, "货", nil, true) or 0) - 1 >= 0) and "cover_wood" or "cover_stone" -- 75
end -- 65
local GUARD_LANTERN_CLIPS = {"assets/art/actors_enemies_anim.clip|guard_lantern_0", "assets/art/actors_enemies_anim.clip|guard_lantern_1", "assets/art/actors_enemies_anim.clip|guard_lantern_2", "assets/art/actors_enemies_anim.clip|guard_lantern_3"} -- 78
local GUARD_WRITE_CLIPS = {"assets/art/actors_enemies_anim.clip|guard_write_0", "assets/art/actors_enemies_anim.clip|guard_write_1", "assets/art/actors_enemies_anim.clip|guard_write_2", "assets/art/actors_enemies_anim.clip|guard_write_3"} -- 84
____exports.StageRenderer = __TS__Class() -- 91
local StageRenderer = ____exports.StageRenderer -- 91
StageRenderer.name = "StageRenderer" -- 91
function StageRenderer.prototype.____constructor(self) -- 91
end -- 91
function StageRenderer.prototype.drawBackdrop(self, bgDraw, bgGlow, assets, p, cam, time) -- 93
	local w = cam.viewW -- 101
	local h = cam.viewH -- 102
	local theme = themeOf(p.room.key) -- 103
	local seed = roomSeed(p.room.key) -- 104
	local span = math.max(1, p.room.maxX - p.room.minX) -- 106
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 107
	local backdropKey = theme.backdropKey or p.room.key -- 108
	local farSlot = "bgFar_" .. backdropKey -- 109
	local artW = math.max(w, h * 16 / 9) * 1.24 -- 112
	local artH = artW * 9 / 16 -- 113
	local artY = math.min( -- 114
		0, -- 114
		math.max(h - artH, cam.groundScreenY - artH * 0.24) -- 114
	) -- 114
	if assets:tryPlace( -- 114
		farSlot, -- 115
		"scene", -- 115
		w * (0.5 - progress * 0.08), -- 115
		artY, -- 115
		artW, -- 115
		artH -- 115
	) then -- 115
		self:drawDressing(assets, backdropKey, cam, progress) -- 116
		local y = cam.groundScreenY -- 117
		fillVGradRect( -- 118
			bgDraw, -- 118
			0, -- 118
			0, -- 118
			w, -- 118
			h, -- 118
			toColor(PALETTE.voidDark), -- 118
			toColor(theme.skyMid) -- 118
		) -- 118
		fillVGradRect( -- 119
			bgGlow, -- 119
			0, -- 119
			y - 1, -- 119
			w, -- 119
			h * 0.14, -- 119
			Color(43, 49, 63, 15), -- 119
			Color(43, 49, 63, 0) -- 119
		) -- 119
		return -- 120
	end -- 120
	local splitY = h * 0.46 -- 124
	fillVGradRect( -- 125
		bgDraw, -- 125
		0, -- 125
		splitY, -- 125
		w, -- 125
		h - splitY, -- 125
		toColor(theme.skyMid), -- 125
		toColor(theme.skyTop) -- 125
	) -- 125
	fillVGradRect( -- 126
		bgDraw, -- 126
		0, -- 126
		0, -- 126
		w, -- 126
		splitY, -- 126
		toColor(theme.skyHorizon), -- 126
		toColor(theme.skyMid) -- 126
	) -- 126
	if theme.showMoon then -- 126
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 130
		local my = h * theme.moonYFrac -- 131
		local mr = math.max(18, h * 0.044) -- 132
		fillRadialGlow( -- 133
			bgGlow, -- 133
			mx, -- 133
			my, -- 133
			mr * 5.2, -- 133
			mr * 5.2, -- 133
			Color(156, 186, 212, 26), -- 133
			Color(20, 32, 52, 0), -- 133
			20 -- 133
		) -- 133
		fillRadialGlow( -- 134
			bgGlow, -- 134
			mx, -- 134
			my, -- 134
			mr * 2.2, -- 134
			mr * 2.2, -- 134
			Color(210, 226, 238, 56), -- 134
			Color(64, 96, 134, 0), -- 134
			18 -- 134
		) -- 134
		bgDraw:drawCircle( -- 135
			Vec2(mx, my), -- 135
			mr, -- 135
			Color(224, 236, 244, 220) -- 135
		) -- 135
		bgDraw:drawCircle( -- 136
			Vec2(mx + mr * 0.28, my + mr * 0.16), -- 136
			mr * 0.84, -- 136
			toColor(theme.skyTop, 118) -- 136
		) -- 136
	end -- 136
	if p.room.key == "forest" then -- 136
		self:drawFarForest( -- 140
			bgDraw, -- 140
			w, -- 140
			h, -- 140
			cam, -- 140
			theme, -- 140
			seed -- 140
		) -- 140
		self:drawMidForest( -- 141
			bgDraw, -- 141
			bgGlow, -- 141
			w, -- 141
			h, -- 141
			cam, -- 141
			theme, -- 141
			time, -- 141
			seed -- 141
		) -- 141
	else -- 141
		self:drawFarMingTown( -- 143
			bgDraw, -- 143
			w, -- 143
			h, -- 143
			cam, -- 143
			theme, -- 143
			seed -- 143
		) -- 143
	end -- 143
	if theme.showTowerBeacon then -- 143
		self:drawDistantNorthTower( -- 146
			bgDraw, -- 146
			bgGlow, -- 146
			w, -- 146
			h, -- 146
			cam, -- 146
			p, -- 146
			time -- 146
		) -- 146
	end -- 146
	local fogH = h * 0.34 -- 150
	fillVGradRect( -- 151
		bgGlow, -- 152
		0, -- 153
		cam.groundScreenY - 10, -- 154
		w, -- 155
		fogH, -- 156
		toColor(theme.fogBottom), -- 157
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 158
	) -- 158
end -- 93
function StageRenderer.prototype.drawDressing(self, assets, backdropKey, cam, progress) -- 162
	local w = cam.viewW -- 163
	local ground = cam.groundScreenY -- 164
	local x = w * (0.76 - progress * 0.22) -- 165
	if backdropKey == "forest" or backdropKey == "outside" or backdropKey == "tower" then -- 165
		assets:tryPlace( -- 168
			"pine", -- 168
			"mid_pine", -- 168
			x, -- 168
			ground - cam:len(6), -- 168
			cam:len(122), -- 168
			cam:len(107), -- 168
			{layer = 1, opacity = 0.5} -- 169
		) -- 169
	elseif backdropKey == "prologue" or backdropKey == "village" or backdropKey == "checkpoint" then -- 169
		assets:tryPlace( -- 171
			"eaves", -- 171
			"mid_eaves", -- 171
			x, -- 171
			ground - cam:len(4), -- 171
			cam:len(176), -- 171
			cam:len(96), -- 171
			{layer = 1, opacity = 0.44} -- 172
		) -- 172
	else -- 172
		assets:tryPlace( -- 174
			"cover_stone", -- 174
			"mid_ruin", -- 174
			x, -- 174
			ground - cam:len(4), -- 174
			cam:len(114), -- 174
			cam:len(50), -- 174
			{layer = 1, opacity = 0.44} -- 175
		) -- 175
	end -- 175
	if backdropKey == "street" or backdropKey == "checkpoint" or backdropKey == "prologue" then -- 175
		local lanternSway = math.sin(progress * 6 + cam.x * 0.004) * 2.5 -- 178
		assets:tryPlace( -- 179
			"prop_lantern", -- 179
			"mid_lantern", -- 179
			w * (0.27 - progress * 0.18), -- 179
			ground + cam:len(96), -- 180
			cam:len(20), -- 180
			cam:len(28), -- 180
			{layer = 2, opacity = 0.82, angle = lanternSway} -- 180
		) -- 180
	end -- 180
end -- 162
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 185
	local theme = themeOf("checkpoint") -- 192
	local splitY = h * 0.44 -- 193
	fillVGradRect( -- 194
		bgDraw, -- 194
		0, -- 194
		splitY, -- 194
		w, -- 194
		h - splitY, -- 194
		toColor(theme.skyMid), -- 194
		toColor(theme.skyTop) -- 194
	) -- 194
	fillVGradRect( -- 195
		bgDraw, -- 195
		0, -- 195
		0, -- 195
		w, -- 195
		splitY, -- 195
		toColor(theme.skyHorizon), -- 195
		toColor(theme.skyMid) -- 195
	) -- 195
	local mx = w * 0.61 -- 198
	local my = h * 0.74 -- 199
	local mr = h * 0.072 -- 200
	fillRadialGlow( -- 201
		bgGlow, -- 201
		mx, -- 201
		my, -- 201
		mr * 4.4, -- 201
		mr * 4.4, -- 201
		Color(164, 184, 198, 28), -- 201
		Color(16, 22, 34, 0), -- 201
		22 -- 201
	) -- 201
	fillRadialGlow( -- 202
		bgGlow, -- 202
		mx, -- 202
		my, -- 202
		mr * 1.9, -- 202
		mr * 1.9, -- 202
		Color(214, 224, 232, 62), -- 202
		Color(36, 48, 64, 0), -- 202
		18 -- 202
	) -- 202
	bgDraw:drawCircle( -- 203
		Vec2(mx, my), -- 203
		mr, -- 203
		Color(234, 238, 236, 225) -- 203
	) -- 203
	bgDraw:drawCircle( -- 204
		Vec2(mx + mr * 0.24, my + mr * 0.14), -- 204
		mr * 0.85, -- 204
		Color(14, 18, 28, 118) -- 204
	) -- 204
	local groundY = h * 0.19 -- 207
	local i = 0 -- 208
	do -- 208
		i = 0 -- 209
		while i < 14 do -- 209
			local bx = i * (w / 12) - 24 + math.sin(time * 0.06) * 4 -- 210
			local bw = 58 + hash01(i * 13 + 3) * 82 -- 211
			local bh = h * (0.14 + hash01(i * 29 + 7) * 0.22) -- 212
			local ridgeH = 14 + hash01(i * 19) * 18 -- 213
			bgDraw:drawPolygon( -- 214
				{ -- 214
					Vec2(bx, groundY), -- 215
					Vec2(bx + bw, groundY), -- 216
					Vec2(bx + bw, groundY + bh), -- 217
					Vec2(bx + bw * 0.5, groundY + bh + ridgeH), -- 218
					Vec2(bx, groundY + bh) -- 219
				}, -- 219
				Color(14, 18, 26, 255) -- 220
			) -- 220
			i = i + 1 -- 209
		end -- 209
	end -- 209
	local tx = w * 0.83 -- 224
	local ty0 = groundY -- 225
	local ty1 = h * 0.58 -- 226
	bgDraw:drawPolygon( -- 227
		{ -- 227
			Vec2(tx - 24, ty0), -- 228
			Vec2(tx + 24, ty0), -- 229
			Vec2(tx + 15, ty1), -- 230
			Vec2(tx - 15, ty1) -- 231
		}, -- 231
		Color(18, 23, 34, 255), -- 232
		1.1, -- 232
		Color(72, 84, 98, 130) -- 232
	) -- 232
	bgDraw:drawPolygon( -- 233
		{ -- 233
			Vec2(tx - 32, ty1), -- 234
			Vec2(tx + 32, ty1), -- 235
			Vec2(tx, ty1 + 26) -- 236
		}, -- 236
		Color(24, 30, 42, 255) -- 237
	) -- 237
	local pulse = 0.82 + 0.18 * math.sin(time * 2.2) -- 238
	local lampY = ty1 - 14 -- 239
	fillRadialGlow( -- 240
		bgGlow, -- 240
		tx, -- 240
		lampY, -- 240
		64 * pulse, -- 240
		64 * pulse, -- 240
		Color(238, 198, 128, 118), -- 240
		Color(214, 162, 86, 0), -- 240
		18 -- 240
	) -- 240
	bgGlow:drawDot( -- 241
		Vec2(tx, lampY), -- 241
		4.2, -- 241
		Color(252, 240, 206, 245) -- 241
	) -- 241
	fillVGradRect( -- 244
		bgDraw, -- 244
		0, -- 244
		0, -- 244
		w, -- 244
		groundY, -- 244
		Color(9, 11, 17, 255), -- 244
		Color(20, 24, 34, 255) -- 244
	) -- 244
	bgDraw:drawSegment( -- 245
		Vec2(0, groundY), -- 245
		Vec2(w, groundY), -- 245
		1.4, -- 245
		toColor(PALETTE.silkDim, 145) -- 245
	) -- 245
	fillVGradRect( -- 246
		bgGlow, -- 246
		0, -- 246
		groundY, -- 246
		w, -- 246
		h * 0.18, -- 246
		Color(46, 56, 72, 42), -- 246
		Color(20, 26, 38, 0) -- 246
	) -- 246
	local sx = w * 0.64 -- 249
	bgDraw:drawPolygon( -- 250
		{ -- 250
			Vec2(sx - 24, groundY + 14), -- 251
			Vec2(sx + 14, groundY + 18), -- 252
			Vec2(sx + 16, groundY + 116), -- 253
			Vec2(sx - 16, groundY + 116) -- 254
		}, -- 254
		Color(14, 18, 26, 255), -- 255
		1.1, -- 255
		Color(118, 132, 144, 125) -- 255
	) -- 255
	bgDraw:drawSegment( -- 256
		Vec2(sx - 5, groundY + 46), -- 256
		Vec2(sx - 10, groundY + 2), -- 256
		5.5, -- 256
		Color(12, 16, 24, 255) -- 256
	) -- 256
	bgDraw:drawSegment( -- 257
		Vec2(sx + 6, groundY + 46), -- 257
		Vec2(sx + 12, groundY + 2), -- 257
		5.5, -- 257
		Color(16, 20, 30, 255) -- 257
	) -- 257
	bgDraw:drawCircle( -- 258
		Vec2(sx + 1, groundY + 132), -- 258
		11, -- 258
		Color(18, 22, 32, 255) -- 258
	) -- 258
	bgDraw:drawPolygon( -- 259
		{ -- 259
			Vec2(sx - 18, groundY + 135), -- 260
			Vec2(sx + 20, groundY + 135), -- 261
			Vec2(sx + 1, groundY + 148) -- 262
		}, -- 262
		Color(44, 50, 58, 250) -- 263
	) -- 263
	bgDraw:drawSegment( -- 264
		Vec2(sx + 4, groundY + 96), -- 264
		Vec2(sx + 46, groundY + 88), -- 264
		3, -- 264
		Color(78, 56, 40, 255) -- 264
	) -- 264
	local cx = w * 0.725 -- 266
	bgDraw:drawPolygon( -- 267
		{ -- 267
			Vec2(cx - 18, groundY + 14), -- 268
			Vec2(cx + 16, groundY + 14), -- 269
			Vec2(cx + 11, groundY + 78), -- 270
			Vec2(cx - 11, groundY + 78) -- 271
		}, -- 271
		Color(148, 108, 66, 236), -- 272
		1.2, -- 272
		Color(214, 186, 146, 195) -- 272
	) -- 272
	bgDraw:drawSegment( -- 273
		Vec2(cx - 4, groundY + 22), -- 273
		Vec2(cx - 5, groundY + 2), -- 273
		3.8, -- 273
		Color(24, 20, 24, 255) -- 273
	) -- 273
	bgDraw:drawSegment( -- 274
		Vec2(cx + 4, groundY + 22), -- 274
		Vec2(cx + 5, groundY + 2), -- 274
		3.8, -- 274
		Color(30, 26, 30, 255) -- 274
	) -- 274
	bgDraw:drawCircle( -- 275
		Vec2(cx + 1, groundY + 88), -- 275
		10, -- 275
		Color(212, 192, 168, 240) -- 275
	) -- 275
	fillRadialGlow( -- 276
		bgGlow, -- 276
		cx + 10, -- 276
		groundY + 52, -- 276
		26, -- 276
		26, -- 276
		Color(238, 198, 128, 96), -- 276
		Color(214, 162, 86, 0), -- 276
		14 -- 276
	) -- 276
	bgGlow:drawDot( -- 277
		Vec2(cx + 10, groundY + 52), -- 277
		2.8, -- 277
		Color(252, 238, 202, 240) -- 277
	) -- 277
end -- 185
function StageRenderer.prototype.drawPlayableWorld(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 281
	local theme = themeOf(p.room.key) -- 291
	self:drawFloors( -- 292
		fgDraw, -- 292
		assets, -- 292
		p, -- 292
		cam, -- 292
		theme -- 292
	) -- 292
	self:drawStairs( -- 293
		fgDraw, -- 293
		fgGlow, -- 293
		assets, -- 293
		p, -- 293
		cam, -- 293
		theme -- 293
	) -- 293
	self:drawSolids( -- 294
		fgDraw, -- 294
		fgGlow, -- 294
		assets, -- 294
		p, -- 294
		cam, -- 294
		theme, -- 294
		time, -- 294
		occlusion, -- 294
		fadeDt -- 294
	) -- 294
	if p.room.key == "gate" then -- 294
		self:drawGateShutter( -- 296
			fgDraw, -- 296
			fgGlow, -- 296
			assets, -- 296
			p, -- 296
			cam, -- 296
			time -- 296
		) -- 296
	end -- 296
	self:drawArch(fgDraw, assets, p, cam) -- 298
end -- 281
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, _p, _cam) -- 302
	fillVGradRect( -- 310
		fgDraw, -- 310
		0, -- 310
		h - h * 0.15, -- 310
		w, -- 310
		h * 0.15, -- 310
		Color(4, 6, 12, 0), -- 310
		Color(4, 6, 12, 126) -- 310
	) -- 310
	fillVGradRect( -- 311
		fgDraw, -- 311
		0, -- 311
		0, -- 311
		w, -- 311
		h * 0.12, -- 311
		Color(4, 6, 12, 165), -- 311
		Color(4, 6, 12, 0) -- 311
	) -- 311
end -- 302
function StageRenderer.prototype.drawFarMingTown(self, bgDraw, w, h, cam, theme, seed) -- 315
	local baseY = cam.groundScreenY - 8 -- 323
	local shift = -cam.x * 0.2 * cam.ppu -- 324
	local colW = 112 -- 325
	local first = math.floor((-shift - colW) / colW) -- 326
	local count = math.ceil(w / colW) + 3 -- 327
	local i = 0 -- 328
	do -- 328
		i = 0 -- 329
		while i < count do -- 329
			local idx = first + i -- 330
			local r1 = hash01(seed + idx * 13.7) -- 331
			local r2 = hash01(seed + idx * 29.3) -- 332
			local x = idx * colW + shift -- 333
			local bw = colW * (0.72 + r1 * 0.42) -- 334
			local bh = h * (0.14 + r2 * 0.24) -- 335
			local ridgeH = 14 + r1 * 18 -- 336
			bgDraw:drawPolygon( -- 337
				{ -- 337
					Vec2(x, baseY), -- 338
					Vec2(x + bw, baseY), -- 339
					Vec2(x + bw, baseY + bh), -- 340
					Vec2(x + bw * 0.5, baseY + bh + ridgeH), -- 341
					Vec2(x, baseY + bh) -- 342
				}, -- 342
				toColor(theme.farBuilding) -- 343
			) -- 343
			i = i + 1 -- 329
		end -- 329
	end -- 329
end -- 315
function StageRenderer.prototype.drawFarForest(self, bgDraw, w, h, cam, theme, seed) -- 347
	local baseY = cam.groundScreenY - 8 -- 355
	local shift = -cam.x * 0.22 * cam.ppu -- 356
	local step = 76 -- 357
	local first = math.floor((-shift - step) / step) -- 358
	local count = math.ceil(w / step) + 4 -- 359
	local i = 0 -- 360
	do -- 360
		i = 0 -- 361
		while i < count do -- 361
			local idx = first + i -- 362
			local r1 = hash01(seed + idx * 11.3) -- 363
			local r2 = hash01(seed + idx * 23.9) -- 364
			local cx = idx * step + shift -- 365
			local tw = 34 + r1 * 38 -- 366
			local th = h * (0.24 + r2 * 0.34) -- 367
			bgDraw:drawPolygon( -- 368
				{ -- 368
					Vec2(cx - tw, baseY), -- 369
					Vec2(cx + tw, baseY), -- 370
					Vec2(cx, baseY + th) -- 371
				}, -- 371
				toColor(theme.farBuilding) -- 372
			) -- 372
			bgDraw:drawPolygon( -- 373
				{ -- 373
					Vec2(cx - tw * 0.72, baseY + th * 0.32), -- 374
					Vec2(cx + tw * 0.72, baseY + th * 0.32), -- 375
					Vec2(cx, baseY + th * 1.12) -- 376
				}, -- 376
				toColor(theme.farBuilding) -- 377
			) -- 377
			i = i + 1 -- 361
		end -- 361
	end -- 361
end -- 347
function StageRenderer.prototype.drawMidForest(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 381
	local baseY = cam.groundScreenY - 4 -- 391
	local shift = -cam.x * 0.52 * cam.ppu -- 392
	local span = 156 -- 393
	local first = math.floor((-shift - span) / span) -- 394
	local count = math.ceil(w / span) + 3 -- 395
	local col = toColor(theme.midBuilding) -- 396
	local i = 0 -- 398
	do -- 398
		i = 0 -- 399
		while i < count do -- 399
			local idx = first + i -- 400
			local r = hash01(seed + idx * 19.7) -- 401
			local x = idx * span + shift -- 402
			local trunkW = 14 + r * 14 -- 403
			local sway = math.sin(time * 0.9 + idx) * 4 -- 404
			bgDraw:drawPolygon( -- 405
				{ -- 405
					Vec2(x - trunkW * 0.5, baseY), -- 406
					Vec2(x + trunkW * 0.5, baseY), -- 407
					Vec2(x + trunkW * 0.25 + sway, h), -- 408
					Vec2(x - trunkW * 0.3 + sway, h) -- 409
				}, -- 409
				col -- 410
			) -- 410
			if idx % 3 == 0 then -- 410
				bgGlow:drawVertices({ -- 413
					{ -- 414
						Vec2(x + 40, h), -- 414
						Color(110, 232, 200, 26) -- 414
					}, -- 414
					{ -- 415
						Vec2(x + 115, h), -- 415
						Color(110, 232, 200, 0) -- 415
					}, -- 415
					{ -- 416
						Vec2(x - 60, baseY), -- 416
						Color(110, 232, 200, 0) -- 416
					} -- 416
				}) -- 416
			end -- 416
			i = i + 1 -- 399
		end -- 399
	end -- 399
end -- 381
function StageRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, cam, p, time) -- 422
	local scale = 0.55 -- 432
	if p.room.key == "village" then -- 432
		scale = 0.72 -- 434
	elseif p.room.key == "forest" then -- 434
		scale = 0.92 -- 436
	elseif p.room.key == "tower" then -- 436
		scale = 1.15 -- 438
	end -- 438
	local tx = w * 0.84 - (cam.x - p.room.minX) * 0.04 -- 440
	local baseY = cam.groundScreenY - 8 -- 441
	local towerH = h * 0.42 * scale -- 442
	local bw = 20 * scale -- 443
	bgDraw:drawPolygon( -- 444
		{ -- 444
			Vec2(tx - bw, baseY), -- 445
			Vec2(tx + bw, baseY), -- 446
			Vec2(tx + bw * 0.45, baseY + towerH), -- 447
			Vec2(tx - bw * 0.45, baseY + towerH) -- 448
		}, -- 448
		Color(14, 24, 38, 240) -- 449
	) -- 449
	bgDraw:drawSegment( -- 450
		Vec2(tx, baseY + towerH), -- 450
		Vec2(tx, baseY + towerH + 28 * scale), -- 450
		1.8, -- 450
		Color(180, 210, 238, 200) -- 450
	) -- 450
	local topY = baseY + towerH + 24 * scale -- 452
	local pulse = 0.78 + 0.22 * math.sin(time * 2.2) -- 453
	fillRadialGlow( -- 454
		bgGlow, -- 454
		tx, -- 454
		topY, -- 454
		56 * scale * pulse, -- 454
		56 * scale * pulse, -- 454
		Color(255, 224, 152, 118), -- 454
		Color(255, 190, 96, 0), -- 454
		18 -- 454
	) -- 454
	bgGlow:drawDot( -- 455
		Vec2(tx, topY), -- 455
		3.6 * scale, -- 455
		Color(255, 246, 220, 255) -- 455
	) -- 455
end -- 422
function StageRenderer.prototype.drawFloors(self, fgDraw, assets, p, cam, theme) -- 458
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 465
	do -- 465
		local i = 0 -- 466
		while i < #p.room.floors do -- 466
			local floor = p.room.floors[i + 1] -- 467
			local left = cam:sx(floor.x0) -- 468
			local right = cam:sx(floor.x1) -- 469
			local isMain = floor.y <= 0.1 -- 470
			local ____isMain_0 -- 471
			if isMain then -- 471
				____isMain_0 = p.room.depth -- 471
			else -- 471
				____isMain_0 = nil -- 471
			end -- 471
			local road = ____isMain_0 -- 471
			local top = cam:sy(floor.y, road and road.min or 0) -- 472
			if road ~= nil then -- 472
				self:drawRoad( -- 474
					fgDraw, -- 474
					assets, -- 474
					i, -- 474
					left, -- 474
					right, -- 474
					top, -- 474
					cam:sy(floor.y, road.max), -- 474
					cam, -- 474
					theme -- 474
				) -- 474
			end -- 474
			local height = cam:len(isMain and 22 or 12) -- 476
			local bottom = top - height -- 477
			if isMain and bottom > 0 then -- 477
				fillVGradRect( -- 479
					fgDraw, -- 479
					left, -- 479
					0, -- 479
					right - left, -- 479
					bottom + 1, -- 479
					toColor(PALETTE.voidDark), -- 480
					toColor(theme.groundBody) -- 480
				) -- 480
			end -- 480
			fgDraw:drawRect( -- 482
				Rect(left, bottom, right - left, height), -- 482
				toColor(PALETTE.steelDark) -- 482
			) -- 482
			local step = cam:len(96) -- 483
			local start = math.max( -- 484
				0, -- 484
				math.floor(-left / step) -- 484
			) -- 484
			do -- 484
				local j = start -- 485
				while left + j * step < math.min(right, cam.viewW) do -- 485
					local x = left + j * step -- 486
					local width = math.min(step, right - x) -- 487
					assets:tryPlace( -- 488
						"slab", -- 488
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 488
						x + width * 0.5, -- 488
						bottom, -- 488
						width, -- 488
						height -- 488
					) -- 488
					if grass and isMain and j % 3 == 1 then -- 488
						assets:tryPlace( -- 490
							"grass_low", -- 490
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 490
							x + width * 0.5, -- 490
							top - cam:len(3), -- 491
							width * 0.74, -- 491
							cam:len(13), -- 491
							{opacity = 0.83, layer = 1} -- 491
						) -- 491
					end -- 491
					j = j + 1 -- 485
				end -- 485
			end -- 485
			fgDraw:drawSegment( -- 494
				Vec2(left, top), -- 494
				Vec2(right, top), -- 494
				1, -- 494
				toColor(theme.groundRim, 140) -- 494
			) -- 494
			i = i + 1 -- 466
		end -- 466
	end -- 466
end -- 458
function StageRenderer.prototype.drawRoad(self, draw, _assets, _floor, left, right, front, back, cam, theme) -- 498
	local width = right - left -- 503
	local height = back - front -- 504
	if width <= 1 or height <= 1 then -- 504
		return -- 506
	end -- 506
	local nearCol = lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.42) -- 509
	local farCol = lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.42) -- 510
	fillVGradRect( -- 511
		draw, -- 511
		left, -- 511
		front, -- 511
		width, -- 511
		height, -- 511
		toColor(nearCol), -- 511
		toColor(farCol) -- 511
	) -- 511
	local bands = { -- 513
		0, -- 513
		0.3, -- 513
		0.58, -- 513
		0.81, -- 513
		1 -- 513
	} -- 513
	local jointDark = Color(14, 17, 22, 115) -- 514
	local jointHi = toColor(theme.groundRim, 36) -- 515
	local visLeft = math.max(left, -40) -- 516
	local visRight = math.min(right, cam.viewW + 40) -- 517
	do -- 517
		local row = 0 -- 518
		while row < #bands - 1 do -- 518
			local y0 = front + bands[row + 1] * height -- 519
			local y1 = front + bands[row + 1 + 1] * height -- 520
			local rowH = y1 - y0 -- 521
			local slabWidth = math.max( -- 522
				24, -- 522
				cam:len(84 - row * 10) -- 522
			) -- 522
			local offset = left - row % 2 * slabWidth * 0.5 -- 523
			local start = math.max( -- 524
				0, -- 524
				math.floor((visLeft - offset) / slabWidth) -- 524
			) -- 524
			do -- 524
				local col = start -- 525
				while offset + col * slabWidth < visRight do -- 525
					do -- 525
						local sx0 = math.max(left, offset + col * slabWidth) -- 526
						local sx1 = math.min(right, offset + (col + 1) * slabWidth) -- 527
						local sw = sx1 - sx0 -- 528
						if sw <= 2 then -- 528
							goto __continue61 -- 530
						end -- 530
						local shade = (col * 7 + row * 13) % 3 * 0.04 -- 532
						local stoneCol = lerpRGBA(nearCol, farCol, bands[row + 1] * 0.85 + shade) -- 533
						draw:drawRect( -- 534
							Rect( -- 534
								sx0 + 0.5, -- 534
								y0 + 0.5, -- 534
								sw - 1, -- 534
								math.max(1, rowH - 1) -- 534
							), -- 534
							toColor(stoneCol, 195) -- 534
						) -- 534
						draw:drawSegment( -- 535
							Vec2(sx0, y0), -- 535
							Vec2(sx0, y1), -- 535
							0.8, -- 535
							jointDark -- 535
						) -- 535
					end -- 535
					::__continue61:: -- 535
					col = col + 1 -- 525
				end -- 525
			end -- 525
			draw:drawSegment( -- 537
				Vec2(left, y0), -- 537
				Vec2(right, y0), -- 537
				0.9, -- 537
				jointDark -- 537
			) -- 537
			draw:drawSegment( -- 538
				Vec2(left, y0 + 1), -- 538
				Vec2(right, y0 + 1), -- 538
				0.6, -- 538
				jointHi -- 538
			) -- 538
			row = row + 1 -- 518
		end -- 518
	end -- 518
	draw:drawSegment( -- 541
		Vec2(left, front), -- 541
		Vec2(right, front), -- 541
		1.4, -- 541
		toColor(theme.groundRim, 135) -- 541
	) -- 541
	draw:drawSegment( -- 542
		Vec2(left, back), -- 542
		Vec2(right, back), -- 542
		1.3, -- 542
		toColor(theme.groundRim, 92) -- 542
	) -- 542
	local texTileW = math.max( -- 545
		88, -- 545
		cam:len(128) -- 545
	) -- 545
	local texStart = math.max( -- 546
		0, -- 546
		math.floor((visLeft - left) / texTileW) -- 546
	) -- 546
	local stoneTint = toColor( -- 547
		lerpRGBA(theme.groundTop, PALETTE.rimSilver, 0.25), -- 547
		255 -- 547
	) -- 547
	do -- 547
		local tcol = texStart -- 548
		while left + tcol * texTileW < visRight do -- 548
			do -- 548
				local tx0 = left + tcol * texTileW -- 549
				local tw = math.min(texTileW, right - tx0) -- 550
				if tw <= 4 then -- 550
					goto __continue64 -- 552
				end -- 552
				_assets:tryPlacePath( -- 554
					"assets/art/tex_diorama_ming.clip|ming_stone", -- 555
					(("road_stone_" .. tostring(_floor)) .. "_") .. tostring(tcol), -- 556
					tx0 + tw * 0.5, -- 557
					front, -- 558
					tw + 0.5, -- 559
					height, -- 560
					{ -- 561
						anchorX = 0.5, -- 562
						anchorY = 0, -- 563
						opacity = 0.14, -- 564
						color = stoneTint, -- 565
						smooth = true, -- 566
						layer = -18 -- 567
					} -- 567
				) -- 567
			end -- 567
			::__continue64:: -- 567
			tcol = tcol + 1 -- 548
		end -- 548
	end -- 548
end -- 498
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 573
	local i = 0 -- 581
	do -- 581
		i = 0 -- 582
		while i < #p.room.stairs do -- 582
			local st = p.room.stairs[i + 1] -- 583
			local n = st.steps + 1 -- 584
			local stepW = (st.x1 - st.x0) / n -- 585
			local dMin = p.room.depth ~= nil and (st.depth ~= nil and st.depth.min or p.room.depth.min) or 0 -- 586
			local dMax = p.room.depth ~= nil and (st.depth ~= nil and st.depth.max or p.room.depth.max) or 0 -- 589
			local flatTop = math.abs(st.y1 - st.y0) < 0.01 -- 592
			local baseWorldY = flatTop and 0 or math.max(0, st.y0) -- 593
			local stairLayer = p.room.depth ~= nil and depthOrder(dMin, 0) or 0 -- 594
			local k = 0 -- 595
			do -- 595
				k = 0 -- 596
				while k < n do -- 596
					do -- 596
						local wy = n <= 1 and st.y1 or st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 597
						local wx0 = st.x0 + stepW * k -- 598
						local wx1 = wx0 + stepW -- 599
						local x0 = cam:sx(wx0) -- 600
						local x1 = cam:sx(wx1) -- 601
						if x1 < 0 or x0 > cam.viewW then -- 601
							goto __continue70 -- 603
						end -- 603
						local y1 = cam:sy(wy, dMin) -- 605
						local y0 = cam:sy(baseWorldY, dMin) -- 606
						local yRear = cam:sy(wy, dMax) -- 607
						if yRear > y1 + 1 then -- 607
							fgDraw:drawRect( -- 609
								Rect(x0, y1, x1 - x0, yRear - y1), -- 609
								toColor( -- 609
									lerpRGBA(theme.groundTop, PALETTE.steelMid, 0.35), -- 609
									235 -- 609
								), -- 609
								0.7, -- 609
								toColor(theme.groundRim, 95) -- 609
							) -- 609
						end -- 609
						if y1 > y0 + 2 then -- 609
							fgDraw:drawRect( -- 612
								Rect(x0, y0, x1 - x0, y1 - y0), -- 612
								toColor(PALETTE.steelDark, 235) -- 612
							) -- 612
							fgDraw:drawRect( -- 613
								Rect(x0, y1 - 4, x1 - x0, 4), -- 613
								toColor(theme.groundTop) -- 613
							) -- 613
							assets:tryPlace( -- 614
								"wall", -- 614
								(("stairs_" .. tostring(i)) .. "_") .. tostring(k), -- 614
								(x0 + x1) * 0.5, -- 614
								y0, -- 614
								x1 - x0, -- 615
								y1 - y0, -- 615
								{opacity = 0.76, layer = stairLayer} -- 615
							) -- 615
							assets:tryPlace( -- 616
								"slab", -- 616
								(("step_top_" .. tostring(i)) .. "_") .. tostring(k), -- 616
								(x0 + x1) * 0.5, -- 616
								y1 - cam:len(4), -- 616
								x1 - x0, -- 617
								cam:len(4), -- 617
								{layer = stairLayer + 1} -- 617
							) -- 617
						end -- 617
						fgDraw:drawSegment( -- 619
							Vec2(x0, y1), -- 619
							Vec2(x1, y1), -- 619
							1.6, -- 619
							toColor(theme.groundRim) -- 619
						) -- 619
						fgGlow:drawSegment( -- 620
							Vec2(x0, y1 + 1), -- 620
							Vec2(x1, y1 + 1), -- 620
							0.9, -- 620
							toColor(theme.accent, 50) -- 620
						) -- 620
					end -- 620
					::__continue70:: -- 620
					k = k + 1 -- 596
				end -- 596
			end -- 596
			i = i + 1 -- 582
		end -- 582
	end -- 582
end -- 573
function StageRenderer.prototype.isSolidActive(self, p, s) -- 626
	local matched = false -- 627
	local anyVisible = false -- 628
	local i = 0 -- 629
	do -- 629
		i = 0 -- 630
		while i < #p.boxes do -- 630
			local b = p.boxes[i + 1] -- 631
			local sameId = s.id ~= nil and b.id == s.id -- 632
			local sameGeom = math.abs(b.x0 - s.x) < 0.5 and math.abs(b.y0 - s.y) < 0.5 and math.abs(b.x1 - b.x0 - s.w) < 0.5 and math.abs(b.y1 - b.y0 - s.h) < 0.5 and (s.depth == nil or b.depth ~= nil and math.abs(b.depth.min - s.depth.min) < 0.5) -- 633
			if sameId or sameGeom then -- 633
				matched = true -- 637
				if b.broken ~= true and b.hidden ~= true then -- 637
					anyVisible = true -- 639
				end -- 639
			end -- 639
			i = i + 1 -- 630
		end -- 630
	end -- 630
	return not matched or anyVisible -- 643
end -- 626
function StageRenderer.prototype.drawSolids(self, fgDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt) -- 646
	local i = 0 -- 657
	do -- 657
		i = 0 -- 658
		while i < #p.room.solids do -- 658
			do -- 658
				local s = p.room.solids[i + 1] -- 659
				if s.decorative == true or s.id == "e3_bench" or s.id == "tower_desk" then -- 659
					goto __continue81 -- 662
				end -- 662
				if not self:isSolidActive(p, s) then -- 662
					goto __continue81 -- 666
				end -- 666
				if p.room.key == "village" and (string.find(s.label, "瓶架", nil, true) or 0) - 1 >= 0 then -- 666
					goto __continue81 -- 670
				end -- 670
				local x0 = cam:sx(s.x) -- 672
				local x1 = cam:sx(s.x + s.w) -- 673
				if p.room.depth ~= nil and s.depth ~= nil then -- 673
					local opacity = occlusion:update( -- 675
						"solid_" .. tostring(i), -- 675
						{ -- 675
							x0 = s.x, -- 676
							x1 = s.x + s.w, -- 676
							y0 = s.y, -- 676
							y1 = s.y + s.h, -- 676
							depth = s.depth, -- 677
							passThrough = s.passable == true or s.soft == true -- 677
						}, -- 677
						p, -- 678
						fadeDt -- 678
					) -- 678
					if x1 > 0 and x0 < cam.viewW then -- 678
						self:drawDepthSolid( -- 680
							fgDraw, -- 680
							assets, -- 680
							s, -- 680
							s.depth, -- 680
							x0, -- 680
							x1, -- 680
							cam, -- 680
							theme, -- 680
							opacity, -- 680
							p -- 680
						) -- 680
					end -- 680
					goto __continue81 -- 682
				end -- 682
				local y0 = cam:sy(s.y) -- 684
				local y1 = cam:sy(s.y + s.h) -- 685
				local sw = x1 - x0 -- 686
				local sh = y1 - y0 -- 687
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 687
					goto __continue81 -- 689
				end -- 689
				if p.room.key == "outside" and s.y > 10 and s.id ~= "outside_red_cart" then -- 689
					local groundY = cam:sy(0) -- 694
					local pierW = cam:len(16) -- 695
					fgDraw:drawRect( -- 696
						Rect(x0, groundY, pierW, y0 - groundY), -- 696
						Color(32, 37, 46, 215), -- 696
						0.9, -- 696
						Color(68, 76, 88, 140) -- 696
					) -- 696
					fgDraw:drawRect( -- 697
						Rect(x1 - pierW, groundY, pierW, y0 - groundY), -- 697
						Color(32, 37, 46, 215), -- 697
						0.9, -- 697
						Color(68, 76, 88, 140) -- 697
					) -- 697
				end -- 697
				if s.passable == true then -- 697
					if not assets:tryPlace( -- 697
						"grass", -- 702
						"hide_grass_" .. tostring(i), -- 702
						(x0 + x1) * 0.5, -- 702
						y0, -- 702
						sw, -- 702
						sh * 1.55, -- 702
						{opacity = 0.79, layer = 7} -- 703
					) then -- 703
						self:drawGrassCluster( -- 704
							fgDraw, -- 704
							fgGlow, -- 704
							x0, -- 704
							y0, -- 704
							sw, -- 704
							sh, -- 704
							p.player.x, -- 704
							s.x + s.w * 0.5, -- 704
							time -- 704
						) -- 704
					end -- 704
					goto __continue81 -- 706
				end -- 706
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 706
					self:drawWinch( -- 711
						fgDraw, -- 711
						assets, -- 711
						x0, -- 711
						y0, -- 711
						sw, -- 711
						sh, -- 711
						p, -- 711
						2 -- 711
					) -- 711
					goto __continue81 -- 712
				end -- 712
				if p.room.key == "tower" then -- 712
					self:drawTowerStructure( -- 717
						fgDraw, -- 717
						fgGlow, -- 717
						assets, -- 717
						x0, -- 717
						y0, -- 717
						sw, -- 717
						sh, -- 717
						s, -- 717
						p, -- 717
						cam, -- 717
						time -- 717
					) -- 717
					goto __continue81 -- 718
				end -- 718
				if s.art == "red_cart" then -- 718
					self:drawRedCartPixel( -- 723
						fgDraw, -- 723
						x0, -- 723
						y0, -- 723
						sw, -- 723
						sh, -- 723
						cam -- 723
					) -- 723
					goto __continue81 -- 724
				end -- 724
				if s.h <= 64 and s.y <= 2 then -- 724
					self:drawCoverBlock( -- 729
						fgDraw, -- 729
						fgGlow, -- 729
						assets, -- 729
						x0, -- 729
						y0, -- 729
						sw, -- 729
						sh, -- 729
						s, -- 729
						p, -- 729
						theme -- 729
					) -- 729
					goto __continue81 -- 730
				end -- 730
				fillVGradRect( -- 733
					fgDraw, -- 733
					x0, -- 733
					y0, -- 733
					sw, -- 733
					sh, -- 733
					toColor(PALETTE.steelDark), -- 733
					toColor(PALETTE.steelMid) -- 733
				) -- 733
				self:tileMasonry( -- 734
					assets, -- 734
					s, -- 734
					x0, -- 734
					y0, -- 734
					sw, -- 734
					sh -- 734
				) -- 734
			end -- 734
			::__continue81:: -- 734
			i = i + 1 -- 658
		end -- 658
	end -- 658
end -- 646
function StageRenderer.prototype.drawDepthSolid(self, draw, assets, solid, depth, left, right, cam, theme, opacity, p) -- 738
	local width = right - left -- 742
	local base = cam:sy(solid.y, depth.min) -- 743
	local rearBase = cam:sy(solid.y, depth.max) -- 744
	local top = cam:sy(solid.y + solid.h, depth.min) -- 745
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 746
	local frontH = top - base -- 747
	local slot = coverArt(solid) -- 748
	local layer = depthOrder(depth.min, 1) -- 749
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 750
	local capHeight = rear - top -- 751
	local center = (left + right) * 0.5 -- 752
	if (string.find(solid.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 752
		self:drawWinch( -- 756
			draw, -- 756
			assets, -- 756
			left, -- 756
			base, -- 756
			width, -- 756
			frontH, -- 756
			p, -- 756
			layer -- 756
		) -- 756
		return -- 757
	end -- 757
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 757
		assets:tryPlace( -- 761
			"slab", -- 761
			"gate_sill_" .. tostring(solid.x), -- 761
			center, -- 761
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 761
			width + cam:len(34), -- 762
			cam:len(12), -- 762
			{ -- 762
				layer = 1, -- 762
				color = Color(180, 169, 150, 255) -- 762
			} -- 762
		) -- 762
	end -- 762
	draw:drawEllipse( -- 764
		Vec2( -- 764
			center, -- 764
			base + cam:len(2) -- 764
		), -- 764
		width * 0.5, -- 764
		math.max( -- 765
			2, -- 765
			cam:len(2.5) -- 765
		), -- 765
		Color(10, 10, 14, 128 * opacity) -- 765
	) -- 765
	local propArt = dedicatedSolidProp(solid) -- 768
	if propArt ~= nil then -- 768
		local propPath = "assets/art/props_ming.clip|" .. propArt.clip -- 770
		local drawH = frontH * propArt.heightMul -- 771
		local cols = propArt.tileable and math.max( -- 772
			1, -- 773
			math.min( -- 773
				6, -- 773
				math.floor(solid.w / math.max(1, solid.h) / propArt.natAR + 0.5) -- 773
			) -- 773
		) or 1 -- 773
		local colW = width / cols -- 775
		local tint = occlusionTint(opacity) -- 776
		local placedProp = false -- 777
		do -- 777
			local col = 0 -- 778
			while col < cols do -- 778
				local tileKey = col == 0 and key or (key .. "_c") .. tostring(col) -- 779
				if assets:tryPlacePath( -- 779
					propPath, -- 780
					tileKey, -- 780
					left + (col + 0.5) * colW, -- 780
					base, -- 780
					colW + 1, -- 780
					drawH, -- 780
					{ -- 780
						anchorX = 0.5, -- 781
						anchorY = 0, -- 782
						preserveAspect = not propArt.tileable and cols == 1 and solid.art == "board", -- 783
						opacity = opacity, -- 784
						color = tint, -- 785
						layer = layer -- 786
					} -- 786
				) then -- 786
					placedProp = true -- 788
				end -- 788
				col = col + 1 -- 778
			end -- 778
		end -- 778
		if placedProp then -- 778
			return -- 792
		end -- 792
	end -- 792
	local timber = slot == "cover_wood" or solid.art == "thin_wood" or solid.art == "board" or solid.art == "curtain" -- 796
	if slot ~= "fence" and capHeight > 1 then -- 796
		local capTop = top + capHeight -- 800
		if not assets:tryPlace( -- 800
			slot, -- 801
			"cap_" .. tostring(solid.x), -- 801
			center, -- 801
			top, -- 801
			width, -- 801
			capHeight, -- 801
			{ -- 802
				opacity = math.min(1, opacity), -- 802
				layer = layer -- 802
			} -- 802
		) then -- 802
			local capFill = occlusionTint( -- 803
				opacity, -- 803
				timber and Color( -- 803
					74, -- 804
					56, -- 804
					42, -- 804
					math.floor(232 * opacity + 0.5) -- 804
				) or Color( -- 804
					74, -- 805
					78, -- 805
					86, -- 805
					math.floor(232 * opacity + 0.5) -- 805
				) -- 805
			) -- 805
			fillVGradRect( -- 806
				draw, -- 806
				left, -- 806
				top, -- 806
				width, -- 806
				capHeight, -- 806
				capFill, -- 807
				occlusionTint( -- 807
					opacity, -- 807
					Color( -- 807
						44, -- 807
						46, -- 807
						52, -- 807
						math.floor(220 * opacity + 0.5) -- 807
					) -- 807
				) -- 807
			) -- 807
		end -- 807
		draw:drawSegment( -- 809
			Vec2(left + width * 0.04, capTop - 0.5), -- 809
			Vec2(right - width * 0.04, capTop - 0.5), -- 809
			0.9, -- 810
			occlusionTint( -- 810
				opacity, -- 810
				timber and Color( -- 810
					122, -- 811
					96, -- 811
					72, -- 811
					math.floor(150 * opacity + 0.5) -- 811
				) or Color( -- 811
					118, -- 812
					124, -- 812
					132, -- 812
					math.floor(140 * opacity + 0.5) -- 812
				) -- 812
			) -- 812
		) -- 812
	end -- 812
	if timber and solid.h > solid.w * 1.6 then -- 812
		local segs = math.max( -- 817
			1, -- 817
			math.min( -- 817
				6, -- 817
				math.floor(solid.h / math.max(24, solid.w * 3.5) + 0.5) -- 817
			) -- 817
		) -- 817
		local segH = frontH / segs -- 818
		local colTint = occlusionTint(opacity) -- 819
		do -- 819
			local pi = 0 -- 820
			while pi < segs do -- 820
				local tk = pi == 0 and key or (key .. "_p") .. tostring(pi) -- 821
				assets:tryPlace( -- 822
					"fe_pillar_wood", -- 822
					tk, -- 822
					center, -- 822
					base + pi * segH, -- 822
					width + 0.5, -- 822
					segH + 0.5, -- 822
					{layer = layer, opacity = opacity, color = colTint} -- 822
				) -- 822
				pi = pi + 1 -- 820
			end -- 820
		end -- 820
		return -- 826
	end -- 826
	if solid.w > solid.h * 5 then -- 826
		local segs = math.max( -- 831
			2, -- 831
			math.min( -- 831
				12, -- 831
				math.floor(solid.w / 64 + 0.5) -- 831
			) -- 831
		) -- 831
		local segW = width / segs -- 832
		local beamH = math.max(5, frontH) -- 833
		local beamTint = occlusionTint(opacity) -- 834
		do -- 834
			local bi = 0 -- 835
			while bi < segs do -- 835
				local tk = bi == 0 and key or (key .. "_b") .. tostring(bi) -- 836
				assets:tryPlace( -- 837
					"fe_beam_wood", -- 837
					tk, -- 837
					left + (bi + 0.5) * segW, -- 837
					base, -- 837
					segW + 0.5, -- 837
					beamH, -- 837
					{layer = layer, opacity = opacity, color = beamTint} -- 837
				) -- 837
				bi = bi + 1 -- 835
			end -- 835
		end -- 835
		return -- 841
	end -- 841
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 845
	local cols = slot == "wall" and math.max( -- 846
		1, -- 847
		math.min( -- 847
			10, -- 847
			math.floor(solid.w / 72 + 0.5) -- 847
		) -- 847
	) or math.max( -- 847
		1, -- 848
		math.min( -- 848
			10, -- 848
			math.floor(solid.w / math.max(1, solid.h) / natAR + 0.5) -- 848
		) -- 848
	) -- 848
	local colW = width / cols -- 849
	local rows = slot == "wall" and math.max( -- 850
		1, -- 851
		math.min( -- 851
			10, -- 851
			math.ceil(solid.h * 1.25 / math.max(1, solid.w / cols)) -- 851
		) -- 851
	) or math.max( -- 851
		1, -- 852
		math.min( -- 852
			6, -- 852
			math.floor(solid.h / math.max(1, solid.w / cols) * natAR + 0.5) -- 852
		) -- 852
	) -- 852
	local rowHeight = frontH / rows -- 853
	local masonryColor = slot == "wall" and Color(181, 176, 167, 255) or nil -- 854
	local color = occlusionTint(opacity, masonryColor) -- 855
	local placedAny = false -- 856
	do -- 856
		local row = 0 -- 857
		while row < rows do -- 857
			do -- 857
				local col = 0 -- 858
				while col < cols do -- 858
					local tileKey = row == 0 and col == 0 and key or (((key .. "_r") .. tostring(row)) .. "_c") .. tostring(col) -- 859
					if assets:tryPlace( -- 859
						slot, -- 860
						tileKey, -- 860
						left + (col + 0.5) * colW, -- 860
						base + row * rowHeight, -- 860
						colW + 0.5, -- 860
						rowHeight + 0.5, -- 860
						{layer = layer, opacity = opacity, color = color, facing = (row + col) % 2 == 0 and 1 or -1} -- 860
					) then -- 860
						placedAny = true -- 863
					end -- 863
					col = col + 1 -- 858
				end -- 858
			end -- 858
			row = row + 1 -- 857
		end -- 857
	end -- 857
	if not placedAny then -- 857
		draw:drawRect( -- 868
			Rect(left, base, width, frontH), -- 868
			occlusionTint( -- 869
				opacity, -- 869
				toColor(PALETTE.steelMid, 255 * opacity) -- 869
			), -- 869
			1, -- 870
			toColor(theme.groundRim, 150 * opacity) -- 870
		) -- 870
	end -- 870
end -- 738
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 874
	local columns = math.max( -- 879
		1, -- 879
		math.min( -- 879
			10, -- 879
			math.floor(s.w / 58 + 0.5) -- 879
		) -- 879
	) -- 879
	local cellWorldW = s.w / columns -- 880
	local targetCellH = math.max( -- 881
		24, -- 881
		math.min(48, cellWorldW / 1.52) -- 881
	) -- 881
	local rows = math.max( -- 882
		1, -- 882
		math.min( -- 882
			12, -- 882
			math.floor(s.h / targetCellH + 0.5) -- 882
		) -- 882
	) -- 882
	local tileW = width / columns -- 883
	local tileH = height / rows -- 884
	do -- 884
		local row = 0 -- 885
		while row < rows do -- 885
			do -- 885
				local column = 0 -- 886
				while column < columns do -- 886
					assets:tryPlace( -- 887
						"wall", -- 887
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 887
						x + (column + 0.5) * tileW, -- 888
						y + row * tileH, -- 888
						tileW + 0.5, -- 888
						tileH + 0.5, -- 888
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 889
					) -- 889
					column = column + 1 -- 886
				end -- 886
			end -- 886
			row = row + 1 -- 885
		end -- 885
	end -- 885
end -- 874
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 894
	local slot = coverArt(s) -- 901
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 902
	local cols = math.max( -- 903
		1, -- 903
		math.min( -- 903
			8, -- 903
			math.floor(s.w / math.max(1, s.h) / natAR + 0.5) -- 903
		) -- 903
	) -- 903
	local tileW = sw / cols -- 904
	local placed = false -- 905
	do -- 905
		local c = 0 -- 906
		while c < cols do -- 906
			local k = c == 0 and "cover_" .. tostring(s.x) or (("cover_" .. tostring(s.x)) .. "_") .. tostring(c) -- 907
			if assets:tryPlace( -- 907
				slot, -- 908
				k, -- 908
				x0 + (c + 0.5) * tileW, -- 908
				y0, -- 908
				tileW + 0.5, -- 908
				sh, -- 908
				{layer = 1} -- 908
			) then -- 908
				placed = true -- 909
			end -- 909
			c = c + 1 -- 906
		end -- 906
	end -- 906
	if not placed then -- 906
		fillVGradRect( -- 913
			fgDraw, -- 913
			x0, -- 913
			y0, -- 913
			sw, -- 913
			sh, -- 913
			toColor(PALETTE.steelDark), -- 913
			toColor(PALETTE.steelMid) -- 913
		) -- 913
		fgDraw:drawSegment( -- 914
			Vec2(x0, y0 + sh), -- 914
			Vec2(x0 + sw, y0 + sh), -- 914
			1.4, -- 914
			toColor(theme.groundRim) -- 914
		) -- 914
	end -- 914
	if not p.childMode and (p.coverHug or p.coverNear) then -- 914
		local plx = p.player.x -- 919
		local nearLeft = math.abs(plx - s.x) < 42 -- 920
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 921
		if nearLeft or nearRight then -- 921
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 923
			local isWood = slot == "cover_wood" -- 924
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 925
			fgDraw:drawSegment( -- 926
				Vec2(edgeX, y0 + 4), -- 926
				Vec2(edgeX, y0 + sh + 2), -- 926
				p.coverHug and 2 or 1.2, -- 926
				toColor(col, p.coverHug and 205 or 120) -- 926
			) -- 926
		end -- 926
	end -- 926
end -- 894
function StageRenderer.prototype.drawRedCartPixel(self, draw, x0, y0, sw, sh, cam) -- 935
	local bodyH = math.max(6, sh * 0.62) -- 938
	local bodyY = y0 + sh - bodyH -- 939
	draw:drawRect( -- 940
		Rect(x0, bodyY, sw, bodyH), -- 940
		Color(92, 70, 52, 248), -- 940
		1, -- 940
		Color(150, 118, 86, 215) -- 940
	) -- 940
	draw:drawRect( -- 941
		Rect( -- 941
			x0 - cam:len(3), -- 941
			bodyY + cam:len(1), -- 941
			sw + cam:len(8), -- 941
			bodyH * 0.92 -- 941
		), -- 941
		toColor(PALETTE.clothRed), -- 942
		1, -- 942
		toColor(PALETTE.clothRedHighlight) -- 942
	) -- 942
	draw:drawRect( -- 943
		Rect(x0 + sw * 0.16, bodyY + bodyH * 0.36, sw * 0.24, bodyH * 0.32), -- 943
		Color(214, 206, 188, 215) -- 944
	) -- 944
	draw:drawRect( -- 945
		Rect(x0 + sw * 0.58, bodyY + bodyH * 0.52, sw * 0.18, bodyH * 0.22), -- 945
		Color(196, 188, 172, 200) -- 946
	) -- 946
	draw:drawSegment( -- 947
		Vec2( -- 947
			x0 + sw - cam:len(2), -- 947
			bodyY + bodyH * 0.72 -- 947
		), -- 947
		Vec2( -- 948
			x0 + sw + cam:len(26), -- 948
			bodyY + bodyH * 1.36 -- 948
		), -- 948
		math.max( -- 949
			2, -- 949
			cam:len(2.6) -- 949
		), -- 949
		Color(126, 98, 68, 240) -- 949
	) -- 949
	draw:drawEllipse( -- 950
		Vec2( -- 950
			x0 + sw * 0.26, -- 950
			y0 + sh - cam:len(1) -- 950
		), -- 950
		cam:len(5.2), -- 950
		cam:len(5.2), -- 950
		Color(40, 34, 30, 235) -- 951
	) -- 951
	draw:drawEllipse( -- 952
		Vec2( -- 952
			x0 + sw * 0.26, -- 952
			y0 + sh - cam:len(1) -- 952
		), -- 952
		cam:len(2.1), -- 952
		cam:len(2.1), -- 952
		Color(150, 126, 92, 220) -- 953
	) -- 953
end -- 935
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p, layer) -- 956
	if layer == nil then -- 956
		layer = 2 -- 961
	end -- 961
	local cx = x0 + sw * 0.5 -- 963
	local cy = y0 + sh * 0.55 -- 964
	local ropeWidth = math.max(1, sw * 0.023) -- 965
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 966
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 967
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 968
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 969
	draw:drawEllipse( -- 970
		Vec2(cx, y0), -- 970
		sw * 0.53, -- 970
		sh * 0.07, -- 970
		Color(10, 8, 9, 150) -- 970
	) -- 970
	draw:drawSegment( -- 971
		drum, -- 971
		bend, -- 971
		ropeWidth, -- 971
		Color(111, 86, 57, 239) -- 971
	) -- 971
	draw:drawSegment( -- 972
		bend, -- 972
		ropeTop, -- 972
		ropeWidth, -- 972
		Color(111, 86, 57, 239) -- 972
	) -- 972
	if assets:tryPlace( -- 972
		"prop_winch", -- 973
		"gate_winch", -- 973
		cx, -- 973
		y0 + sh * 0.5, -- 973
		sw, -- 973
		sh, -- 973
		{layer = layer} -- 973
	) then -- 973
		return -- 974
	end -- 974
	local timber = Color(75, 51, 34, 255) -- 976
	draw:drawSegment( -- 977
		Vec2(x0 + sw * 0.15, y0 + sh * 0.07), -- 977
		Vec2(cx, y0 + sh * 0.86), -- 977
		sw * 0.06, -- 977
		timber -- 977
	) -- 977
	draw:drawSegment( -- 978
		Vec2(x0 + sw * 0.85, y0 + sh * 0.07), -- 978
		Vec2(cx, y0 + sh * 0.86), -- 978
		sw * 0.06, -- 978
		timber -- 978
	) -- 978
	draw:drawRect( -- 979
		Rect(x0, y0, sw, sh * 0.12), -- 979
		timber -- 979
	) -- 979
	local radius = math.min(sw, sh) * 0.21 -- 980
	draw:drawCircle( -- 981
		Vec2(cx, cy), -- 981
		radius, -- 981
		Color(48, 41, 37, 255) -- 981
	) -- 981
	do -- 981
		local i = -2 -- 982
		while i <= 2 do -- 982
			local x = cx + i * radius * 0.28 -- 983
			draw:drawSegment( -- 984
				Vec2(x, cy - radius * 0.62), -- 984
				Vec2(x, cy + radius * 0.62), -- 984
				ropeWidth, -- 984
				Color(135, 103, 68, 240) -- 985
			) -- 985
			i = i + 1 -- 982
		end -- 982
	end -- 982
end -- 956
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 989
	local ____temp_3 -- 997
	if p.room.story ~= nil then -- 997
		____temp_3 = p.room.story.gate -- 997
	else -- 997
		____temp_3 = nil -- 997
	end -- 997
	local g = ____temp_3 -- 997
	if g == nil then -- 997
		return -- 999
	end -- 999
	local closeFrac = 0.08 -- 1002
	if p.phase == "gate-hold" then -- 1002
		closeFrac = 0.08 + 0.36 * math.min( -- 1004
			1, -- 1004
			p.gateTick / math.max(1, g.holdTicks) -- 1004
		) -- 1004
	elseif p.phase == "gate-send" then -- 1004
		closeFrac = 0.44 -- 1006
	elseif p.phase == "gate-count" then -- 1006
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 1008
	elseif p.phase == "gate-walk" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 1008
		closeFrac = 1 -- 1010
	end -- 1010
	local gx0 = cam:sx(848) -- 1012
	local gx1 = cam:sx(1032) -- 1013
	local topY = cam:sy(160) -- 1014
	local botY = cam:sy(160 * (1 - closeFrac)) -- 1015
	local shutterW = gx1 - gx0 -- 1016
	local shutterH = topY - botY -- 1017
	if shutterH > 2 then -- 1017
		fillVGradRect( -- 1019
			fgDraw, -- 1019
			gx0, -- 1019
			botY, -- 1019
			shutterW, -- 1019
			shutterH, -- 1019
			toColor(PALETTE.steelDark), -- 1019
			toColor(PALETTE.steelMid) -- 1019
		) -- 1019
		local rows = math.max( -- 1021
			1, -- 1021
			math.min( -- 1021
				6, -- 1021
				math.ceil(shutterH / math.max(18, shutterW / 2.6)) -- 1021
			) -- 1021
		) -- 1021
		local rowH = shutterH / rows -- 1022
		do -- 1022
			local r = 0 -- 1023
			while r < rows do -- 1023
				assets:tryPlace( -- 1024
					"cover_wood", -- 1024
					"gate_shutter_" .. tostring(r), -- 1024
					(gx0 + gx1) * 0.5, -- 1024
					botY + r * rowH, -- 1024
					shutterW, -- 1025
					rowH + 0.5, -- 1025
					{layer = 6} -- 1025
				) -- 1025
				r = r + 1 -- 1023
			end -- 1023
		end -- 1023
	end -- 1023
	if closeFrac < 0.98 then -- 1023
		local gapH = math.max( -- 1030
			8, -- 1030
			botY - cam:sy(0) -- 1030
		) -- 1030
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 1031
		fillVGradRect( -- 1032
			fgGlow, -- 1032
			gx0, -- 1032
			cam:sy(0), -- 1032
			gx1 - gx0, -- 1032
			gapH, -- 1032
			Color( -- 1032
				140, -- 1032
				210, -- 1032
				255, -- 1032
				math.floor(52 * pulse + 0.5) -- 1032
			), -- 1032
			Color(80, 160, 230, 0) -- 1032
		) -- 1032
	end -- 1032
end -- 989
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, cam, time) -- 1036
	fillVGradRect( -- 1043
		fgDraw, -- 1043
		x0, -- 1043
		y0, -- 1043
		sw, -- 1043
		sh, -- 1043
		Color(15, 21, 34, 255), -- 1043
		Color(32, 44, 66, 255) -- 1043
	) -- 1043
	fgDraw:drawRect( -- 1044
		Rect(x0, y0, sw, sh), -- 1044
		Color(0, 0, 0, 0), -- 1044
		1.4, -- 1044
		toColor(PALETTE.rimSilver, 165) -- 1044
	) -- 1044
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 1044
		self:tileMasonry( -- 1047
			assets, -- 1047
			s, -- 1047
			x0, -- 1047
			y0, -- 1047
			sw, -- 1047
			sh -- 1047
		) -- 1047
		local ribs = 4 -- 1049
		local r = 1 -- 1050
		do -- 1050
			r = 1 -- 1051
			while r < ribs do -- 1051
				local rx = x0 + sw * r / ribs -- 1052
				fgDraw:drawSegment( -- 1053
					Vec2(rx, y0), -- 1053
					Vec2(rx, y0 + sh), -- 1053
					2, -- 1053
					Color(10, 15, 24, 210) -- 1053
				) -- 1053
				fgDraw:drawSegment( -- 1054
					Vec2(rx + 2, y0), -- 1054
					Vec2(rx + 2, y0 + sh), -- 1054
					1, -- 1054
					Color(68, 86, 114, 130) -- 1054
				) -- 1054
				r = r + 1 -- 1051
			end -- 1051
		end -- 1051
		local bands = 4 -- 1057
		local b = 1 -- 1058
		do -- 1058
			b = 1 -- 1059
			while b < bands do -- 1059
				local by = y0 + sh * b / bands -- 1060
				fgDraw:drawSegment( -- 1061
					Vec2(x0 + 4, by), -- 1061
					Vec2(x0 + sw - 4, by), -- 1061
					1.2, -- 1061
					Color(52, 68, 92, 135) -- 1061
				) -- 1061
				b = b + 1 -- 1059
			end -- 1059
		end -- 1059
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 1064
		local slitY = y0 + sh * 0.56 -- 1065
		local slitH = sh * 0.22 -- 1066
		fgDraw:drawRect( -- 1067
			Rect(slitX - 5, slitY, 10, slitH), -- 1067
			Color(8, 12, 20, 245), -- 1067
			1.2, -- 1067
			toColor(PALETTE.amberDim, 190) -- 1067
		) -- 1067
		fgGlow:drawRect( -- 1068
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 1068
			toColor(PALETTE.amber, 190) -- 1068
		) -- 1068
		fillRadialGlow( -- 1069
			fgGlow, -- 1069
			slitX, -- 1069
			slitY + slitH * 0.5, -- 1069
			44, -- 1069
			slitH * 0.7, -- 1069
			Color(255, 206, 128, 52), -- 1069
			Color(255, 180, 86, 0), -- 1069
			14 -- 1069
		) -- 1069
	end -- 1069
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 1069
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 1074
		local cx = x0 + sw * 0.5 -- 1079
		local lampY = y0 - 8 -- 1080
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 1081
		if not opened then -- 1081
			assets:tryPlace( -- 1083
				"prop_tower_door", -- 1083
				"tower_door", -- 1083
				cx, -- 1083
				y0 - doorHeight, -- 1083
				sw, -- 1083
				doorHeight, -- 1083
				{layer = 2} -- 1083
			) -- 1083
		end -- 1083
		assets:tryPlace( -- 1085
			"prop_lantern", -- 1085
			"tower_lantern", -- 1085
			cx + sw * 0.43, -- 1085
			lampY - sh * 0.36, -- 1085
			sw * 0.17, -- 1086
			sh * 0.84, -- 1086
			{layer = 3} -- 1086
		) -- 1086
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 1087
		local alpha = opened and 58 or 42 -- 1088
		fgDraw:drawSegment( -- 1090
			Vec2(x0 + 4, y0), -- 1090
			Vec2(x0 + 4, y0 - sh * 3.8), -- 1090
			4, -- 1090
			Color(42, 52, 70, 255) -- 1090
		) -- 1090
		fgDraw:drawSegment( -- 1091
			Vec2(x0 + sw - 4, y0), -- 1091
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 1091
			4, -- 1091
			Color(42, 52, 70, 255) -- 1091
		) -- 1091
		fgDraw:drawSegment( -- 1092
			Vec2(x0, y0), -- 1092
			Vec2(x0 + sw, y0), -- 1092
			2.5, -- 1092
			toColor(PALETTE.amber, 210) -- 1092
		) -- 1092
		fillVGradRect( -- 1094
			fgGlow, -- 1095
			x0 + 6, -- 1096
			y0 - sh * 3.8, -- 1097
			sw - 12, -- 1098
			sh * 3.8, -- 1099
			Color( -- 1100
				246, -- 1100
				196, -- 1100
				118, -- 1100
				math.floor((opened and alpha or alpha * 0.35) * pulse + 0.5) -- 1100
			), -- 1100
			Color(246, 206, 142, opened and 74 or 38) -- 1101
		) -- 1101
		fillRadialGlow( -- 1103
			fgGlow, -- 1103
			cx, -- 1103
			lampY, -- 1103
			opened and 78 or 54, -- 1103
			opened and 72 or 52, -- 1103
			Color( -- 1103
				252, -- 1103
				218, -- 1103
				152, -- 1103
				math.floor(92 * pulse + 0.5) -- 1103
			), -- 1103
			Color(255, 180, 86, 0), -- 1103
			18 -- 1103
		) -- 1103
		fgDraw:drawCircle( -- 1104
			Vec2(cx, lampY), -- 1104
			4.5, -- 1104
			toColor(PALETTE.amberCore) -- 1104
		) -- 1104
		if opened then -- 1104
			local deskCx = cam:sx(p.ox + 605) -- 1108
			local groundY = cam:sy(0) -- 1109
			local deskW = cam:len(84) -- 1110
			local deskH = cam:len(34) -- 1111
			local deskTop = groundY + deskH -- 1112
			local writing = p.deskHold >= 24 or p.towerHanded -- 1113
			fillRadialGlow( -- 1115
				fgGlow, -- 1115
				deskCx, -- 1115
				deskTop + cam:len(26), -- 1115
				cam:len(96), -- 1115
				cam:len(74), -- 1115
				Color( -- 1116
					255, -- 1116
					198, -- 1116
					114, -- 1116
					math.floor(52 * pulse + 0.5) -- 1116
				), -- 1116
				Color(255, 168, 72, 0), -- 1116
				16 -- 1116
			) -- 1116
			local guardX = deskCx + cam:len(26) -- 1118
			local guardFrame = math.floor(time * (writing and 3.2 or 3.8)) % 4 -- 1119
			local guardClip = writing and GUARD_WRITE_CLIPS[guardFrame + 1] or GUARD_LANTERN_CLIPS[guardFrame + 1] -- 1120
			if not assets:tryPlacePath( -- 1120
				guardClip, -- 1123
				"tower_guard_npc", -- 1123
				guardX, -- 1123
				groundY, -- 1123
				cam:len(54), -- 1123
				cam:len(86), -- 1123
				{ -- 1123
					anchorX = 0.5, -- 1124
					anchorY = 0, -- 1125
					preserveAspect = true, -- 1126
					facing = -1, -- 1127
					opacity = 0.96, -- 1128
					layer = 3 -- 1129
				} -- 1129
			) then -- 1129
				fgDraw:drawRect( -- 1131
					Rect( -- 1131
						guardX - cam:len(11), -- 1131
						groundY, -- 1131
						cam:len(22), -- 1131
						cam:len(68) -- 1131
					), -- 1131
					Color(34, 42, 54, 240) -- 1131
				) -- 1131
				fgDraw:drawCircle( -- 1132
					Vec2( -- 1132
						guardX, -- 1132
						groundY + cam:len(76) -- 1132
					), -- 1132
					cam:len(9.5), -- 1132
					Color(42, 50, 62, 245) -- 1132
				) -- 1132
			end -- 1132
			if not assets:tryPlace( -- 1132
				"prop_table", -- 1135
				"tower_guard_desk", -- 1135
				deskCx, -- 1135
				groundY, -- 1135
				deskW * 1.06, -- 1135
				deskH * 1.04, -- 1135
				{ -- 1135
					color = Color(214, 188, 158, 255), -- 1136
					opacity = 0.98, -- 1137
					layer = 4 -- 1138
				} -- 1138
			) then -- 1138
				fgDraw:drawRect( -- 1140
					Rect( -- 1140
						deskCx - deskW * 0.5, -- 1140
						groundY, -- 1140
						cam:len(6), -- 1140
						deskH -- 1140
					), -- 1140
					Color(78, 52, 34, 255) -- 1140
				) -- 1140
				fgDraw:drawRect( -- 1141
					Rect( -- 1141
						deskCx + deskW * 0.5 - cam:len(6), -- 1141
						groundY, -- 1141
						cam:len(6), -- 1141
						deskH -- 1141
					), -- 1141
					Color(78, 52, 34, 255) -- 1141
				) -- 1141
				fgDraw:drawRect( -- 1142
					Rect( -- 1142
						deskCx - deskW * 0.52, -- 1142
						deskTop - cam:len(6), -- 1142
						deskW * 1.04, -- 1142
						cam:len(8) -- 1142
					), -- 1142
					Color(108, 74, 46, 255), -- 1142
					1, -- 1142
					Color(148, 108, 68, 220) -- 1142
				) -- 1142
			end -- 1142
			fgDraw:drawRect( -- 1145
				Rect( -- 1145
					deskCx + cam:len(4), -- 1145
					deskTop + cam:len(1), -- 1145
					cam:len(22), -- 1145
					cam:len(4.5) -- 1145
				), -- 1145
				Color(232, 222, 198, 245) -- 1145
			) -- 1145
			if writing then -- 1145
				assets:tryPlace( -- 1147
					"prop_lantern", -- 1147
					"tower_desk_lamp", -- 1147
					deskCx + cam:len(34), -- 1147
					deskTop + cam:len(10), -- 1147
					cam:len(14), -- 1147
					cam:len(20), -- 1147
					{layer = 5} -- 1147
				) -- 1147
				fillRadialGlow( -- 1148
					fgGlow, -- 1148
					deskCx + cam:len(34), -- 1148
					deskTop + cam:len(12), -- 1148
					cam:len(24), -- 1148
					cam:len(22), -- 1148
					Color( -- 1148
						255, -- 1148
						214, -- 1148
						134, -- 1148
						math.floor(88 * pulse + 0.5) -- 1148
					), -- 1148
					Color(255, 180, 86, 0), -- 1148
					12 -- 1148
				) -- 1148
			else -- 1148
				fillRadialGlow( -- 1150
					fgGlow, -- 1150
					deskCx + cam:len(3), -- 1150
					deskTop + cam:len(18), -- 1150
					cam:len(30), -- 1150
					cam:len(28), -- 1150
					Color( -- 1150
						255, -- 1150
						214, -- 1150
						134, -- 1150
						math.floor(78 * pulse + 0.5) -- 1150
					), -- 1150
					Color(255, 180, 86, 0), -- 1150
					12 -- 1150
				) -- 1150
			end -- 1150
			if p.deskHold >= 12 or p.towerHanded then -- 1150
				if not assets:tryPlacePath( -- 1150
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 1154
					"tower_desk_pouch", -- 1154
					deskCx - cam:len(22), -- 1154
					deskTop + cam:len(8), -- 1154
					cam:len(18), -- 1154
					cam:len(18), -- 1154
					{anchorX = 0.5, anchorY = 0.5, smooth = true, layer = 5} -- 1154
				) then -- 1154
					fgDraw:drawRect( -- 1160
						Rect( -- 1160
							deskCx - cam:len(28), -- 1160
							deskTop + cam:len(2), -- 1160
							cam:len(14), -- 1160
							cam:len(6) -- 1160
						), -- 1160
						Color(156, 62, 48, 245) -- 1160
					) -- 1160
				end -- 1160
			end -- 1160
			if writing then -- 1160
				fgDraw:drawRect( -- 1164
					Rect( -- 1164
						deskCx - cam:len(6), -- 1164
						deskTop + cam:len(2), -- 1164
						cam:len(10), -- 1164
						cam:len(3) -- 1164
					), -- 1164
					Color(236, 228, 206, 240) -- 1164
				) -- 1164
			end -- 1164
		end -- 1164
	end -- 1164
end -- 1036
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 1170
	local blades = math.max( -- 1177
		12, -- 1177
		math.floor(sw / 8) -- 1177
	) -- 1177
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1178
	local k = 0 -- 1179
	do -- 1179
		k = 0 -- 1180
		while k < blades do -- 1180
			local t = (k + 0.5) / blades -- 1181
			local bx = x0 + sw * t -- 1182
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1183
			local bh = sh * hRatio * 1.95 -- 1184
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1185
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1186
			fgDraw:drawPolygon( -- 1187
				{ -- 1187
					Vec2(bx - 7, y0), -- 1188
					Vec2(bx + 7, y0), -- 1189
					Vec2(bx + sway, y0 + bh) -- 1190
				}, -- 1190
				col -- 1191
			) -- 1191
			k = k + 1 -- 1180
		end -- 1180
	end -- 1180
	if nearPlayer then -- 1180
		fgGlow:drawSegment( -- 1194
			Vec2(x0, y0 + 2), -- 1194
			Vec2(x0 + sw, y0 + 2), -- 1194
			2, -- 1194
			toColor(PALETTE.emerald, 145) -- 1194
		) -- 1194
	end -- 1194
end -- 1170
function StageRenderer.prototype.drawArch(self, draw, assets, p, cam) -- 1198
	local a = p.room.arch -- 1204
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1204
		return -- 1206
	end -- 1206
	local x0 = cam:sx(a.x0) -- 1208
	local x1 = cam:sx(a.x1) -- 1209
	local y0 = cam:sy(a.y) -- 1210
	local y1 = cam:sy(a.y + a.h) -- 1211
	local cx = (x0 + x1) * 0.5 -- 1212
	local aw = x1 - x0 -- 1213
	local ah = y1 - y0 -- 1214
	draw:drawRect( -- 1215
		Rect( -- 1215
			x0, -- 1215
			y0, -- 1215
			aw, -- 1215
			ah + cam:len(8) -- 1215
		), -- 1215
		Color(13, 15, 20, 242) -- 1215
	) -- 1215
	if not assets:tryPlace( -- 1215
		"fe_outside_arch", -- 1216
		"outside_arch_vault", -- 1216
		cx, -- 1216
		y0, -- 1216
		aw + cam:len(24), -- 1216
		ah + cam:len(22), -- 1216
		{layer = 2} -- 1216
	) then -- 1216
		draw:drawRect( -- 1217
			Rect( -- 1217
				x0 - cam:len(7), -- 1217
				y0, -- 1217
				cam:len(7), -- 1217
				ah -- 1217
			), -- 1217
			Color(62, 63, 67, 255) -- 1217
		) -- 1217
		draw:drawRect( -- 1218
			Rect( -- 1218
				x1, -- 1218
				y0, -- 1218
				cam:len(7), -- 1218
				ah -- 1218
			), -- 1218
			Color(72, 72, 74, 255) -- 1218
		) -- 1218
	end -- 1218
	if not p.cartDocked then -- 1218
		local bx0 = cam:sx(math.max(a.x0 + 4, p.cartAxle - 18)) -- 1222
		local bx1 = cam:sx(math.min(a.x1 - 4, p.cartAxle + 18)) -- 1223
		if bx1 > bx0 + 4 then -- 1223
			local deckY = cam:sy(p.room.cart.baseY) -- 1225
			assets:tryPlace( -- 1226
				"fe_pillar_wood", -- 1226
				"outside_arch_bolt", -- 1226
				(bx0 + bx1) * 0.5, -- 1226
				y0 + 2, -- 1226
				bx1 - bx0, -- 1226
				ah - 2, -- 1226
				{layer = 3} -- 1226
			) -- 1226
			draw:drawSegment( -- 1227
				Vec2((bx0 + bx1) * 0.5, y1), -- 1227
				Vec2((bx0 + bx1) * 0.5, deckY), -- 1227
				2.4, -- 1227
				Color(96, 102, 110, 220) -- 1227
			) -- 1227
		end -- 1227
	end -- 1227
end -- 1198
return ____exports -- 1198