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
____exports.StageRenderer = __TS__Class() -- 78
local StageRenderer = ____exports.StageRenderer -- 78
StageRenderer.name = "StageRenderer" -- 78
function StageRenderer.prototype.____constructor(self) -- 78
end -- 78
function StageRenderer.prototype.drawBackdrop(self, bgDraw, bgGlow, assets, p, cam, time) -- 80
	local w = cam.viewW -- 88
	local h = cam.viewH -- 89
	local theme = themeOf(p.room.key) -- 90
	local seed = roomSeed(p.room.key) -- 91
	local span = math.max(1, p.room.maxX - p.room.minX) -- 93
	local progress = (cam.x - p.room.minX) / span - 0.5 -- 94
	local backdropKey = theme.backdropKey or p.room.key -- 95
	local farSlot = "bgFar_" .. backdropKey -- 96
	local artW = math.max(w, h * 16 / 9) * 1.24 -- 99
	local artH = artW * 9 / 16 -- 100
	local artY = math.min( -- 101
		0, -- 101
		math.max(h - artH, cam.groundScreenY - artH * 0.24) -- 101
	) -- 101
	if assets:tryPlace( -- 101
		farSlot, -- 102
		"scene", -- 102
		w * (0.5 - progress * 0.08), -- 102
		artY, -- 102
		artW, -- 102
		artH -- 102
	) then -- 102
		self:drawDressing(assets, backdropKey, cam, progress) -- 103
		local y = cam.groundScreenY -- 104
		fillVGradRect( -- 105
			bgDraw, -- 105
			0, -- 105
			0, -- 105
			w, -- 105
			h, -- 105
			toColor(PALETTE.voidDark), -- 105
			toColor(theme.skyMid) -- 105
		) -- 105
		fillVGradRect( -- 106
			bgGlow, -- 106
			0, -- 106
			y - 1, -- 106
			w, -- 106
			h * 0.14, -- 106
			Color(43, 49, 63, 15), -- 106
			Color(43, 49, 63, 0) -- 106
		) -- 106
		return -- 107
	end -- 107
	local splitY = h * 0.46 -- 111
	fillVGradRect( -- 112
		bgDraw, -- 112
		0, -- 112
		splitY, -- 112
		w, -- 112
		h - splitY, -- 112
		toColor(theme.skyMid), -- 112
		toColor(theme.skyTop) -- 112
	) -- 112
	fillVGradRect( -- 113
		bgDraw, -- 113
		0, -- 113
		0, -- 113
		w, -- 113
		splitY, -- 113
		toColor(theme.skyHorizon), -- 113
		toColor(theme.skyMid) -- 113
	) -- 113
	if theme.showMoon then -- 113
		local mx = w * theme.moonXFrac - (cam.x - p.room.minX) * 0.015 -- 117
		local my = h * theme.moonYFrac -- 118
		local mr = math.max(18, h * 0.044) -- 119
		fillRadialGlow( -- 120
			bgGlow, -- 120
			mx, -- 120
			my, -- 120
			mr * 5.2, -- 120
			mr * 5.2, -- 120
			Color(156, 186, 212, 26), -- 120
			Color(20, 32, 52, 0), -- 120
			20 -- 120
		) -- 120
		fillRadialGlow( -- 121
			bgGlow, -- 121
			mx, -- 121
			my, -- 121
			mr * 2.2, -- 121
			mr * 2.2, -- 121
			Color(210, 226, 238, 56), -- 121
			Color(64, 96, 134, 0), -- 121
			18 -- 121
		) -- 121
		bgDraw:drawCircle( -- 122
			Vec2(mx, my), -- 122
			mr, -- 122
			Color(224, 236, 244, 220) -- 122
		) -- 122
		bgDraw:drawCircle( -- 123
			Vec2(mx + mr * 0.28, my + mr * 0.16), -- 123
			mr * 0.84, -- 123
			toColor(theme.skyTop, 118) -- 123
		) -- 123
	end -- 123
	if p.room.key == "forest" then -- 123
		self:drawFarForest( -- 127
			bgDraw, -- 127
			w, -- 127
			h, -- 127
			cam, -- 127
			theme, -- 127
			seed -- 127
		) -- 127
		self:drawMidForest( -- 128
			bgDraw, -- 128
			bgGlow, -- 128
			w, -- 128
			h, -- 128
			cam, -- 128
			theme, -- 128
			time, -- 128
			seed -- 128
		) -- 128
	else -- 128
		self:drawFarMingTown( -- 130
			bgDraw, -- 130
			w, -- 130
			h, -- 130
			cam, -- 130
			theme, -- 130
			seed -- 130
		) -- 130
	end -- 130
	if theme.showTowerBeacon then -- 130
		self:drawDistantNorthTower( -- 133
			bgDraw, -- 133
			bgGlow, -- 133
			w, -- 133
			h, -- 133
			cam, -- 133
			p, -- 133
			time -- 133
		) -- 133
	end -- 133
	local fogH = h * 0.34 -- 137
	fillVGradRect( -- 138
		bgGlow, -- 139
		0, -- 140
		cam.groundScreenY - 10, -- 141
		w, -- 142
		fogH, -- 143
		toColor(theme.fogBottom), -- 144
		Color(theme.fogBottom.r, theme.fogBottom.g, theme.fogBottom.b, 0) -- 145
	) -- 145
end -- 80
function StageRenderer.prototype.drawDressing(self, assets, backdropKey, cam, progress) -- 149
	local w = cam.viewW -- 150
	local ground = cam.groundScreenY -- 151
	local x = w * (0.76 - progress * 0.22) -- 152
	if backdropKey == "forest" or backdropKey == "outside" or backdropKey == "tower" then -- 152
		assets:tryPlace( -- 155
			"pine", -- 155
			"mid_pine", -- 155
			x, -- 155
			ground - cam:len(6), -- 155
			cam:len(122), -- 155
			cam:len(107), -- 155
			{layer = 1, opacity = 0.5} -- 156
		) -- 156
	elseif backdropKey == "prologue" or backdropKey == "village" or backdropKey == "checkpoint" then -- 156
		assets:tryPlace( -- 158
			"eaves", -- 158
			"mid_eaves", -- 158
			x, -- 158
			ground - cam:len(4), -- 158
			cam:len(176), -- 158
			cam:len(96), -- 158
			{layer = 1, opacity = 0.44} -- 159
		) -- 159
	else -- 159
		assets:tryPlace( -- 161
			"cover_stone", -- 161
			"mid_ruin", -- 161
			x, -- 161
			ground - cam:len(4), -- 161
			cam:len(114), -- 161
			cam:len(50), -- 161
			{layer = 1, opacity = 0.44} -- 162
		) -- 162
	end -- 162
	if backdropKey == "street" or backdropKey == "checkpoint" or backdropKey == "prologue" then -- 162
		assets:tryPlace( -- 165
			"prop_lantern", -- 165
			"mid_lantern", -- 165
			w * (0.27 - progress * 0.18), -- 165
			ground + cam:len(96), -- 166
			cam:len(20), -- 166
			cam:len(28), -- 166
			{layer = 2, opacity = 0.82} -- 166
		) -- 166
	end -- 166
end -- 149
function StageRenderer.prototype.drawMenuBackdrop(self, bgDraw, bgGlow, w, h, time) -- 171
	local theme = themeOf("checkpoint") -- 178
	local splitY = h * 0.44 -- 179
	fillVGradRect( -- 180
		bgDraw, -- 180
		0, -- 180
		splitY, -- 180
		w, -- 180
		h - splitY, -- 180
		toColor(theme.skyMid), -- 180
		toColor(theme.skyTop) -- 180
	) -- 180
	fillVGradRect( -- 181
		bgDraw, -- 181
		0, -- 181
		0, -- 181
		w, -- 181
		splitY, -- 181
		toColor(theme.skyHorizon), -- 181
		toColor(theme.skyMid) -- 181
	) -- 181
	local mx = w * 0.61 -- 184
	local my = h * 0.74 -- 185
	local mr = h * 0.072 -- 186
	fillRadialGlow( -- 187
		bgGlow, -- 187
		mx, -- 187
		my, -- 187
		mr * 4.4, -- 187
		mr * 4.4, -- 187
		Color(164, 184, 198, 28), -- 187
		Color(16, 22, 34, 0), -- 187
		22 -- 187
	) -- 187
	fillRadialGlow( -- 188
		bgGlow, -- 188
		mx, -- 188
		my, -- 188
		mr * 1.9, -- 188
		mr * 1.9, -- 188
		Color(214, 224, 232, 62), -- 188
		Color(36, 48, 64, 0), -- 188
		18 -- 188
	) -- 188
	bgDraw:drawCircle( -- 189
		Vec2(mx, my), -- 189
		mr, -- 189
		Color(234, 238, 236, 225) -- 189
	) -- 189
	bgDraw:drawCircle( -- 190
		Vec2(mx + mr * 0.24, my + mr * 0.14), -- 190
		mr * 0.85, -- 190
		Color(14, 18, 28, 118) -- 190
	) -- 190
	local groundY = h * 0.19 -- 193
	local i = 0 -- 194
	do -- 194
		i = 0 -- 195
		while i < 14 do -- 195
			local bx = i * (w / 12) - 24 + math.sin(time * 0.06) * 4 -- 196
			local bw = 58 + hash01(i * 13 + 3) * 82 -- 197
			local bh = h * (0.14 + hash01(i * 29 + 7) * 0.22) -- 198
			local ridgeH = 14 + hash01(i * 19) * 18 -- 199
			bgDraw:drawPolygon( -- 200
				{ -- 200
					Vec2(bx, groundY), -- 201
					Vec2(bx + bw, groundY), -- 202
					Vec2(bx + bw, groundY + bh), -- 203
					Vec2(bx + bw * 0.5, groundY + bh + ridgeH), -- 204
					Vec2(bx, groundY + bh) -- 205
				}, -- 205
				Color(14, 18, 26, 255) -- 206
			) -- 206
			i = i + 1 -- 195
		end -- 195
	end -- 195
	local tx = w * 0.83 -- 210
	local ty0 = groundY -- 211
	local ty1 = h * 0.58 -- 212
	bgDraw:drawPolygon( -- 213
		{ -- 213
			Vec2(tx - 24, ty0), -- 214
			Vec2(tx + 24, ty0), -- 215
			Vec2(tx + 15, ty1), -- 216
			Vec2(tx - 15, ty1) -- 217
		}, -- 217
		Color(18, 23, 34, 255), -- 218
		1.1, -- 218
		Color(72, 84, 98, 130) -- 218
	) -- 218
	bgDraw:drawPolygon( -- 219
		{ -- 219
			Vec2(tx - 32, ty1), -- 220
			Vec2(tx + 32, ty1), -- 221
			Vec2(tx, ty1 + 26) -- 222
		}, -- 222
		Color(24, 30, 42, 255) -- 223
	) -- 223
	local pulse = 0.82 + 0.18 * math.sin(time * 2.2) -- 224
	local lampY = ty1 - 14 -- 225
	fillRadialGlow( -- 226
		bgGlow, -- 226
		tx, -- 226
		lampY, -- 226
		64 * pulse, -- 226
		64 * pulse, -- 226
		Color(238, 198, 128, 118), -- 226
		Color(214, 162, 86, 0), -- 226
		18 -- 226
	) -- 226
	bgGlow:drawDot( -- 227
		Vec2(tx, lampY), -- 227
		4.2, -- 227
		Color(252, 240, 206, 245) -- 227
	) -- 227
	fillVGradRect( -- 230
		bgDraw, -- 230
		0, -- 230
		0, -- 230
		w, -- 230
		groundY, -- 230
		Color(9, 11, 17, 255), -- 230
		Color(20, 24, 34, 255) -- 230
	) -- 230
	bgDraw:drawSegment( -- 231
		Vec2(0, groundY), -- 231
		Vec2(w, groundY), -- 231
		1.4, -- 231
		toColor(PALETTE.silkDim, 145) -- 231
	) -- 231
	fillVGradRect( -- 232
		bgGlow, -- 232
		0, -- 232
		groundY, -- 232
		w, -- 232
		h * 0.18, -- 232
		Color(46, 56, 72, 42), -- 232
		Color(20, 26, 38, 0) -- 232
	) -- 232
	local sx = w * 0.64 -- 235
	bgDraw:drawPolygon( -- 236
		{ -- 236
			Vec2(sx - 24, groundY + 14), -- 237
			Vec2(sx + 14, groundY + 18), -- 238
			Vec2(sx + 16, groundY + 116), -- 239
			Vec2(sx - 16, groundY + 116) -- 240
		}, -- 240
		Color(14, 18, 26, 255), -- 241
		1.1, -- 241
		Color(118, 132, 144, 125) -- 241
	) -- 241
	bgDraw:drawSegment( -- 242
		Vec2(sx - 5, groundY + 46), -- 242
		Vec2(sx - 10, groundY + 2), -- 242
		5.5, -- 242
		Color(12, 16, 24, 255) -- 242
	) -- 242
	bgDraw:drawSegment( -- 243
		Vec2(sx + 6, groundY + 46), -- 243
		Vec2(sx + 12, groundY + 2), -- 243
		5.5, -- 243
		Color(16, 20, 30, 255) -- 243
	) -- 243
	bgDraw:drawCircle( -- 244
		Vec2(sx + 1, groundY + 132), -- 244
		11, -- 244
		Color(18, 22, 32, 255) -- 244
	) -- 244
	bgDraw:drawPolygon( -- 245
		{ -- 245
			Vec2(sx - 18, groundY + 135), -- 246
			Vec2(sx + 20, groundY + 135), -- 247
			Vec2(sx + 1, groundY + 148) -- 248
		}, -- 248
		Color(44, 50, 58, 250) -- 249
	) -- 249
	bgDraw:drawSegment( -- 250
		Vec2(sx + 4, groundY + 96), -- 250
		Vec2(sx + 46, groundY + 88), -- 250
		3, -- 250
		Color(78, 56, 40, 255) -- 250
	) -- 250
	local cx = w * 0.725 -- 252
	bgDraw:drawPolygon( -- 253
		{ -- 253
			Vec2(cx - 18, groundY + 14), -- 254
			Vec2(cx + 16, groundY + 14), -- 255
			Vec2(cx + 11, groundY + 78), -- 256
			Vec2(cx - 11, groundY + 78) -- 257
		}, -- 257
		Color(148, 108, 66, 236), -- 258
		1.2, -- 258
		Color(214, 186, 146, 195) -- 258
	) -- 258
	bgDraw:drawSegment( -- 259
		Vec2(cx - 4, groundY + 22), -- 259
		Vec2(cx - 5, groundY + 2), -- 259
		3.8, -- 259
		Color(24, 20, 24, 255) -- 259
	) -- 259
	bgDraw:drawSegment( -- 260
		Vec2(cx + 4, groundY + 22), -- 260
		Vec2(cx + 5, groundY + 2), -- 260
		3.8, -- 260
		Color(30, 26, 30, 255) -- 260
	) -- 260
	bgDraw:drawCircle( -- 261
		Vec2(cx + 1, groundY + 88), -- 261
		10, -- 261
		Color(212, 192, 168, 240) -- 261
	) -- 261
	fillRadialGlow( -- 262
		bgGlow, -- 262
		cx + 10, -- 262
		groundY + 52, -- 262
		26, -- 262
		26, -- 262
		Color(238, 198, 128, 96), -- 262
		Color(214, 162, 86, 0), -- 262
		14 -- 262
	) -- 262
	bgGlow:drawDot( -- 263
		Vec2(cx + 10, groundY + 52), -- 263
		2.8, -- 263
		Color(252, 238, 202, 240) -- 263
	) -- 263
end -- 171
function StageRenderer.prototype.drawPlayableWorld(self, fgDraw, fgGlow, assets, p, cam, time, occlusion, fadeDt) -- 267
	local theme = themeOf(p.room.key) -- 277
	self:drawFloors( -- 278
		fgDraw, -- 278
		assets, -- 278
		p, -- 278
		cam, -- 278
		theme -- 278
	) -- 278
	self:drawStairs( -- 279
		fgDraw, -- 279
		fgGlow, -- 279
		assets, -- 279
		p, -- 279
		cam, -- 279
		theme -- 279
	) -- 279
	self:drawSolids( -- 280
		fgDraw, -- 280
		fgGlow, -- 280
		assets, -- 280
		p, -- 280
		cam, -- 280
		theme, -- 280
		time, -- 280
		occlusion, -- 280
		fadeDt -- 280
	) -- 280
	if p.room.key == "gate" then -- 280
		self:drawGateShutter( -- 282
			fgDraw, -- 282
			fgGlow, -- 282
			assets, -- 282
			p, -- 282
			cam, -- 282
			time -- 282
		) -- 282
	end -- 282
	self:drawArch(fgDraw, assets, p, cam) -- 284
end -- 267
function StageRenderer.prototype.drawForegroundFraming(self, fgDraw, w, h, _p, _cam) -- 288
	fillVGradRect( -- 296
		fgDraw, -- 296
		0, -- 296
		h - h * 0.15, -- 296
		w, -- 296
		h * 0.15, -- 296
		Color(4, 6, 12, 0), -- 296
		Color(4, 6, 12, 126) -- 296
	) -- 296
	fillVGradRect( -- 297
		fgDraw, -- 297
		0, -- 297
		0, -- 297
		w, -- 297
		h * 0.12, -- 297
		Color(4, 6, 12, 165), -- 297
		Color(4, 6, 12, 0) -- 297
	) -- 297
end -- 288
function StageRenderer.prototype.drawFarMingTown(self, bgDraw, w, h, cam, theme, seed) -- 301
	local baseY = cam.groundScreenY - 8 -- 309
	local shift = -cam.x * 0.2 * cam.ppu -- 310
	local colW = 112 -- 311
	local first = math.floor((-shift - colW) / colW) -- 312
	local count = math.ceil(w / colW) + 3 -- 313
	local i = 0 -- 314
	do -- 314
		i = 0 -- 315
		while i < count do -- 315
			local idx = first + i -- 316
			local r1 = hash01(seed + idx * 13.7) -- 317
			local r2 = hash01(seed + idx * 29.3) -- 318
			local x = idx * colW + shift -- 319
			local bw = colW * (0.72 + r1 * 0.42) -- 320
			local bh = h * (0.14 + r2 * 0.24) -- 321
			local ridgeH = 14 + r1 * 18 -- 322
			bgDraw:drawPolygon( -- 323
				{ -- 323
					Vec2(x, baseY), -- 324
					Vec2(x + bw, baseY), -- 325
					Vec2(x + bw, baseY + bh), -- 326
					Vec2(x + bw * 0.5, baseY + bh + ridgeH), -- 327
					Vec2(x, baseY + bh) -- 328
				}, -- 328
				toColor(theme.farBuilding) -- 329
			) -- 329
			i = i + 1 -- 315
		end -- 315
	end -- 315
end -- 301
function StageRenderer.prototype.drawFarForest(self, bgDraw, w, h, cam, theme, seed) -- 333
	local baseY = cam.groundScreenY - 8 -- 341
	local shift = -cam.x * 0.22 * cam.ppu -- 342
	local step = 76 -- 343
	local first = math.floor((-shift - step) / step) -- 344
	local count = math.ceil(w / step) + 4 -- 345
	local i = 0 -- 346
	do -- 346
		i = 0 -- 347
		while i < count do -- 347
			local idx = first + i -- 348
			local r1 = hash01(seed + idx * 11.3) -- 349
			local r2 = hash01(seed + idx * 23.9) -- 350
			local cx = idx * step + shift -- 351
			local tw = 34 + r1 * 38 -- 352
			local th = h * (0.24 + r2 * 0.34) -- 353
			bgDraw:drawPolygon( -- 354
				{ -- 354
					Vec2(cx - tw, baseY), -- 355
					Vec2(cx + tw, baseY), -- 356
					Vec2(cx, baseY + th) -- 357
				}, -- 357
				toColor(theme.farBuilding) -- 358
			) -- 358
			bgDraw:drawPolygon( -- 359
				{ -- 359
					Vec2(cx - tw * 0.72, baseY + th * 0.32), -- 360
					Vec2(cx + tw * 0.72, baseY + th * 0.32), -- 361
					Vec2(cx, baseY + th * 1.12) -- 362
				}, -- 362
				toColor(theme.farBuilding) -- 363
			) -- 363
			i = i + 1 -- 347
		end -- 347
	end -- 347
end -- 333
function StageRenderer.prototype.drawMidForest(self, bgDraw, bgGlow, w, h, cam, theme, time, seed) -- 367
	local baseY = cam.groundScreenY - 4 -- 377
	local shift = -cam.x * 0.52 * cam.ppu -- 378
	local span = 156 -- 379
	local first = math.floor((-shift - span) / span) -- 380
	local count = math.ceil(w / span) + 3 -- 381
	local col = toColor(theme.midBuilding) -- 382
	local i = 0 -- 384
	do -- 384
		i = 0 -- 385
		while i < count do -- 385
			local idx = first + i -- 386
			local r = hash01(seed + idx * 19.7) -- 387
			local x = idx * span + shift -- 388
			local trunkW = 14 + r * 14 -- 389
			local sway = math.sin(time * 0.9 + idx) * 4 -- 390
			bgDraw:drawPolygon( -- 391
				{ -- 391
					Vec2(x - trunkW * 0.5, baseY), -- 392
					Vec2(x + trunkW * 0.5, baseY), -- 393
					Vec2(x + trunkW * 0.25 + sway, h), -- 394
					Vec2(x - trunkW * 0.3 + sway, h) -- 395
				}, -- 395
				col -- 396
			) -- 396
			if idx % 3 == 0 then -- 396
				bgGlow:drawVertices({ -- 399
					{ -- 400
						Vec2(x + 40, h), -- 400
						Color(110, 232, 200, 26) -- 400
					}, -- 400
					{ -- 401
						Vec2(x + 115, h), -- 401
						Color(110, 232, 200, 0) -- 401
					}, -- 401
					{ -- 402
						Vec2(x - 60, baseY), -- 402
						Color(110, 232, 200, 0) -- 402
					} -- 402
				}) -- 402
			end -- 402
			i = i + 1 -- 385
		end -- 385
	end -- 385
end -- 367
function StageRenderer.prototype.drawDistantNorthTower(self, bgDraw, bgGlow, w, h, cam, p, time) -- 408
	local scale = 0.55 -- 418
	if p.room.key == "village" then -- 418
		scale = 0.72 -- 420
	elseif p.room.key == "forest" then -- 420
		scale = 0.92 -- 422
	elseif p.room.key == "tower" then -- 422
		scale = 1.15 -- 424
	end -- 424
	local tx = w * 0.84 - (cam.x - p.room.minX) * 0.04 -- 426
	local baseY = cam.groundScreenY - 8 -- 427
	local towerH = h * 0.42 * scale -- 428
	local bw = 20 * scale -- 429
	bgDraw:drawPolygon( -- 430
		{ -- 430
			Vec2(tx - bw, baseY), -- 431
			Vec2(tx + bw, baseY), -- 432
			Vec2(tx + bw * 0.45, baseY + towerH), -- 433
			Vec2(tx - bw * 0.45, baseY + towerH) -- 434
		}, -- 434
		Color(14, 24, 38, 240) -- 435
	) -- 435
	bgDraw:drawSegment( -- 436
		Vec2(tx, baseY + towerH), -- 436
		Vec2(tx, baseY + towerH + 28 * scale), -- 436
		1.8, -- 436
		Color(180, 210, 238, 200) -- 436
	) -- 436
	local topY = baseY + towerH + 24 * scale -- 438
	local pulse = 0.78 + 0.22 * math.sin(time * 2.2) -- 439
	fillRadialGlow( -- 440
		bgGlow, -- 440
		tx, -- 440
		topY, -- 440
		56 * scale * pulse, -- 440
		56 * scale * pulse, -- 440
		Color(255, 224, 152, 118), -- 440
		Color(255, 190, 96, 0), -- 440
		18 -- 440
	) -- 440
	bgGlow:drawDot( -- 441
		Vec2(tx, topY), -- 441
		3.6 * scale, -- 441
		Color(255, 246, 220, 255) -- 441
	) -- 441
end -- 408
function StageRenderer.prototype.drawFloors(self, fgDraw, assets, p, cam, theme) -- 444
	local grass = p.room.key == "forest" or p.room.key == "outside" -- 451
	do -- 451
		local i = 0 -- 452
		while i < #p.room.floors do -- 452
			local floor = p.room.floors[i + 1] -- 453
			local left = cam:sx(floor.x0) -- 454
			local right = cam:sx(floor.x1) -- 455
			local isMain = floor.y <= 0.1 -- 456
			local ____isMain_0 -- 457
			if isMain then -- 457
				____isMain_0 = p.room.depth -- 457
			else -- 457
				____isMain_0 = nil -- 457
			end -- 457
			local road = ____isMain_0 -- 457
			local top = cam:sy(floor.y, road and road.min or 0) -- 458
			if road ~= nil then -- 458
				self:drawRoad( -- 460
					fgDraw, -- 460
					assets, -- 460
					i, -- 460
					left, -- 460
					right, -- 460
					top, -- 460
					cam:sy(floor.y, road.max), -- 460
					cam, -- 460
					theme -- 460
				) -- 460
			end -- 460
			local height = cam:len(isMain and 22 or 12) -- 462
			local bottom = top - height -- 463
			if isMain and bottom > 0 then -- 463
				fillVGradRect( -- 465
					fgDraw, -- 465
					left, -- 465
					0, -- 465
					right - left, -- 465
					bottom + 1, -- 465
					toColor(PALETTE.voidDark), -- 466
					toColor(theme.groundBody) -- 466
				) -- 466
			end -- 466
			fgDraw:drawRect( -- 468
				Rect(left, bottom, right - left, height), -- 468
				toColor(PALETTE.steelDark) -- 468
			) -- 468
			local step = cam:len(96) -- 469
			local start = math.max( -- 470
				0, -- 470
				math.floor(-left / step) -- 470
			) -- 470
			do -- 470
				local j = start -- 471
				while left + j * step < math.min(right, cam.viewW) do -- 471
					local x = left + j * step -- 472
					local width = math.min(step, right - x) -- 473
					assets:tryPlace( -- 474
						"slab", -- 474
						(("deck_" .. tostring(i)) .. "_") .. tostring(j), -- 474
						x + width * 0.5, -- 474
						bottom, -- 474
						width, -- 474
						height -- 474
					) -- 474
					if grass and isMain and j % 3 == 1 then -- 474
						assets:tryPlace( -- 476
							"grass_low", -- 476
							(("edge_" .. tostring(i)) .. "_") .. tostring(j), -- 476
							x + width * 0.5, -- 476
							top - cam:len(3), -- 477
							width * 0.74, -- 477
							cam:len(13), -- 477
							{opacity = 0.83, layer = 1} -- 477
						) -- 477
					end -- 477
					j = j + 1 -- 471
				end -- 471
			end -- 471
			fgDraw:drawSegment( -- 480
				Vec2(left, top), -- 480
				Vec2(right, top), -- 480
				1, -- 480
				toColor(theme.groundRim, 140) -- 480
			) -- 480
			i = i + 1 -- 452
		end -- 452
	end -- 452
end -- 444
function StageRenderer.prototype.drawRoad(self, draw, _assets, _floor, left, right, front, back, cam, theme) -- 484
	local width = right - left -- 489
	local height = back - front -- 490
	if width <= 1 or height <= 1 then -- 490
		return -- 492
	end -- 492
	local nearCol = lerpRGBA(theme.groundBody, PALETTE.steelMid, 0.42) -- 495
	local farCol = lerpRGBA(theme.groundBody, PALETTE.voidDark, 0.42) -- 496
	fillVGradRect( -- 497
		draw, -- 497
		left, -- 497
		front, -- 497
		width, -- 497
		height, -- 497
		toColor(nearCol), -- 497
		toColor(farCol) -- 497
	) -- 497
	local bands = { -- 499
		0, -- 499
		0.3, -- 499
		0.58, -- 499
		0.81, -- 499
		1 -- 499
	} -- 499
	local jointDark = Color(14, 17, 22, 115) -- 500
	local jointHi = toColor(theme.groundRim, 36) -- 501
	local visLeft = math.max(left, -40) -- 502
	local visRight = math.min(right, cam.viewW + 40) -- 503
	do -- 503
		local row = 0 -- 504
		while row < #bands - 1 do -- 504
			local y0 = front + bands[row + 1] * height -- 505
			local y1 = front + bands[row + 1 + 1] * height -- 506
			local rowH = y1 - y0 -- 507
			local slabWidth = math.max( -- 508
				24, -- 508
				cam:len(84 - row * 10) -- 508
			) -- 508
			local offset = left - row % 2 * slabWidth * 0.5 -- 509
			local start = math.max( -- 510
				0, -- 510
				math.floor((visLeft - offset) / slabWidth) -- 510
			) -- 510
			do -- 510
				local col = start -- 511
				while offset + col * slabWidth < visRight do -- 511
					do -- 511
						local sx0 = math.max(left, offset + col * slabWidth) -- 512
						local sx1 = math.min(right, offset + (col + 1) * slabWidth) -- 513
						local sw = sx1 - sx0 -- 514
						if sw <= 2 then -- 514
							goto __continue61 -- 516
						end -- 516
						local shade = (col * 7 + row * 13) % 3 * 0.04 -- 518
						local stoneCol = lerpRGBA(nearCol, farCol, bands[row + 1] * 0.85 + shade) -- 519
						draw:drawRect( -- 520
							Rect( -- 520
								sx0 + 0.5, -- 520
								y0 + 0.5, -- 520
								sw - 1, -- 520
								math.max(1, rowH - 1) -- 520
							), -- 520
							toColor(stoneCol, 195) -- 520
						) -- 520
						draw:drawSegment( -- 521
							Vec2(sx0, y0), -- 521
							Vec2(sx0, y1), -- 521
							0.8, -- 521
							jointDark -- 521
						) -- 521
					end -- 521
					::__continue61:: -- 521
					col = col + 1 -- 511
				end -- 511
			end -- 511
			draw:drawSegment( -- 523
				Vec2(left, y0), -- 523
				Vec2(right, y0), -- 523
				0.9, -- 523
				jointDark -- 523
			) -- 523
			draw:drawSegment( -- 524
				Vec2(left, y0 + 1), -- 524
				Vec2(right, y0 + 1), -- 524
				0.6, -- 524
				jointHi -- 524
			) -- 524
			row = row + 1 -- 504
		end -- 504
	end -- 504
	draw:drawSegment( -- 527
		Vec2(left, front), -- 527
		Vec2(right, front), -- 527
		1.4, -- 527
		toColor(theme.groundRim, 135) -- 527
	) -- 527
	draw:drawSegment( -- 528
		Vec2(left, back), -- 528
		Vec2(right, back), -- 528
		1.3, -- 528
		toColor(theme.groundRim, 92) -- 528
	) -- 528
	local texTileW = math.max( -- 531
		88, -- 531
		cam:len(128) -- 531
	) -- 531
	local texStart = math.max( -- 532
		0, -- 532
		math.floor((visLeft - left) / texTileW) -- 532
	) -- 532
	local stoneTint = toColor( -- 533
		lerpRGBA(theme.groundTop, PALETTE.rimSilver, 0.25), -- 533
		255 -- 533
	) -- 533
	do -- 533
		local tcol = texStart -- 534
		while left + tcol * texTileW < visRight do -- 534
			do -- 534
				local tx0 = left + tcol * texTileW -- 535
				local tw = math.min(texTileW, right - tx0) -- 536
				if tw <= 4 then -- 536
					goto __continue64 -- 538
				end -- 538
				_assets:tryPlacePath( -- 540
					"assets/art/tex_diorama_ming.clip|ming_stone", -- 541
					(("road_stone_" .. tostring(_floor)) .. "_") .. tostring(tcol), -- 542
					tx0 + tw * 0.5, -- 543
					front, -- 544
					tw + 0.5, -- 545
					height, -- 546
					{ -- 547
						anchorX = 0.5, -- 548
						anchorY = 0, -- 549
						opacity = 0.14, -- 550
						color = stoneTint, -- 551
						smooth = true, -- 552
						layer = -18 -- 553
					} -- 553
				) -- 553
			end -- 553
			::__continue64:: -- 553
			tcol = tcol + 1 -- 534
		end -- 534
	end -- 534
end -- 484
function StageRenderer.prototype.drawStairs(self, fgDraw, fgGlow, assets, p, cam, theme) -- 559
	local i = 0 -- 567
	do -- 567
		i = 0 -- 568
		while i < #p.room.stairs do -- 568
			local st = p.room.stairs[i + 1] -- 569
			local n = st.steps + 1 -- 570
			local stepW = (st.x1 - st.x0) / n -- 571
			local dMin = p.room.depth ~= nil and (st.depth ~= nil and st.depth.min or p.room.depth.min) or 0 -- 572
			local dMax = p.room.depth ~= nil and (st.depth ~= nil and st.depth.max or p.room.depth.max) or 0 -- 575
			local flatTop = math.abs(st.y1 - st.y0) < 0.01 -- 578
			local baseWorldY = flatTop and 0 or math.max(0, st.y0) -- 579
			local stairLayer = p.room.depth ~= nil and depthOrder(dMin, 0) or 0 -- 580
			local k = 0 -- 581
			do -- 581
				k = 0 -- 582
				while k < n do -- 582
					do -- 582
						local wy = n <= 1 and st.y1 or st.y0 + (st.y1 - st.y0) * k / (n - 1) -- 583
						local wx0 = st.x0 + stepW * k -- 584
						local wx1 = wx0 + stepW -- 585
						local x0 = cam:sx(wx0) -- 586
						local x1 = cam:sx(wx1) -- 587
						if x1 < 0 or x0 > cam.viewW then -- 587
							goto __continue70 -- 589
						end -- 589
						local y1 = cam:sy(wy, dMin) -- 591
						local y0 = cam:sy(baseWorldY, dMin) -- 592
						local yRear = cam:sy(wy, dMax) -- 593
						if yRear > y1 + 1 then -- 593
							fgDraw:drawRect( -- 595
								Rect(x0, y1, x1 - x0, yRear - y1), -- 595
								toColor( -- 595
									lerpRGBA(theme.groundTop, PALETTE.steelMid, 0.35), -- 595
									235 -- 595
								), -- 595
								0.7, -- 595
								toColor(theme.groundRim, 95) -- 595
							) -- 595
						end -- 595
						if y1 > y0 + 2 then -- 595
							fgDraw:drawRect( -- 598
								Rect(x0, y0, x1 - x0, y1 - y0), -- 598
								toColor(PALETTE.steelDark, 235) -- 598
							) -- 598
							fgDraw:drawRect( -- 599
								Rect(x0, y1 - 4, x1 - x0, 4), -- 599
								toColor(theme.groundTop) -- 599
							) -- 599
							assets:tryPlace( -- 600
								"wall", -- 600
								(("stairs_" .. tostring(i)) .. "_") .. tostring(k), -- 600
								(x0 + x1) * 0.5, -- 600
								y0, -- 600
								x1 - x0, -- 601
								y1 - y0, -- 601
								{opacity = 0.76, layer = stairLayer} -- 601
							) -- 601
							assets:tryPlace( -- 602
								"slab", -- 602
								(("step_top_" .. tostring(i)) .. "_") .. tostring(k), -- 602
								(x0 + x1) * 0.5, -- 602
								y1 - cam:len(4), -- 602
								x1 - x0, -- 603
								cam:len(4), -- 603
								{layer = stairLayer + 1} -- 603
							) -- 603
						end -- 603
						fgDraw:drawSegment( -- 605
							Vec2(x0, y1), -- 605
							Vec2(x1, y1), -- 605
							1.6, -- 605
							toColor(theme.groundRim) -- 605
						) -- 605
						fgGlow:drawSegment( -- 606
							Vec2(x0, y1 + 1), -- 606
							Vec2(x1, y1 + 1), -- 606
							0.9, -- 606
							toColor(theme.accent, 50) -- 606
						) -- 606
					end -- 606
					::__continue70:: -- 606
					k = k + 1 -- 582
				end -- 582
			end -- 582
			i = i + 1 -- 568
		end -- 568
	end -- 568
end -- 559
function StageRenderer.prototype.isSolidActive(self, p, s) -- 612
	local matched = false -- 613
	local anyVisible = false -- 614
	local i = 0 -- 615
	do -- 615
		i = 0 -- 616
		while i < #p.boxes do -- 616
			local b = p.boxes[i + 1] -- 617
			local sameId = s.id ~= nil and b.id == s.id -- 618
			local sameGeom = math.abs(b.x0 - s.x) < 0.5 and math.abs(b.y0 - s.y) < 0.5 and math.abs(b.x1 - b.x0 - s.w) < 0.5 and math.abs(b.y1 - b.y0 - s.h) < 0.5 and (s.depth == nil or b.depth ~= nil and math.abs(b.depth.min - s.depth.min) < 0.5) -- 619
			if sameId or sameGeom then -- 619
				matched = true -- 623
				if b.broken ~= true and b.hidden ~= true then -- 623
					anyVisible = true -- 625
				end -- 625
			end -- 625
			i = i + 1 -- 616
		end -- 616
	end -- 616
	return not matched or anyVisible -- 629
end -- 612
function StageRenderer.prototype.drawSolids(self, fgDraw, fgGlow, assets, p, cam, theme, time, occlusion, fadeDt) -- 632
	local i = 0 -- 643
	do -- 643
		i = 0 -- 644
		while i < #p.room.solids do -- 644
			do -- 644
				local s = p.room.solids[i + 1] -- 645
				if s.decorative == true or s.id == "e3_bench" or s.id == "tower_desk" then -- 645
					goto __continue81 -- 648
				end -- 648
				if not self:isSolidActive(p, s) then -- 648
					goto __continue81 -- 652
				end -- 652
				if p.room.key == "village" and (string.find(s.label, "瓶架", nil, true) or 0) - 1 >= 0 then -- 652
					goto __continue81 -- 656
				end -- 656
				local x0 = cam:sx(s.x) -- 658
				local x1 = cam:sx(s.x + s.w) -- 659
				if p.room.depth ~= nil and s.depth ~= nil then -- 659
					local opacity = occlusion:update( -- 661
						"solid_" .. tostring(i), -- 661
						{ -- 661
							x0 = s.x, -- 662
							x1 = s.x + s.w, -- 662
							y0 = s.y, -- 662
							y1 = s.y + s.h, -- 662
							depth = s.depth, -- 663
							passThrough = s.passable == true or s.soft == true -- 663
						}, -- 663
						p, -- 664
						fadeDt -- 664
					) -- 664
					if x1 > 0 and x0 < cam.viewW then -- 664
						self:drawDepthSolid( -- 666
							fgDraw, -- 666
							assets, -- 666
							s, -- 666
							s.depth, -- 666
							x0, -- 666
							x1, -- 666
							cam, -- 666
							theme, -- 666
							opacity, -- 666
							p -- 666
						) -- 666
					end -- 666
					goto __continue81 -- 668
				end -- 668
				local y0 = cam:sy(s.y) -- 670
				local y1 = cam:sy(s.y + s.h) -- 671
				local sw = x1 - x0 -- 672
				local sh = y1 - y0 -- 673
				if sw <= 1 or sh <= 1 or x1 < 0 or x0 > cam.viewW then -- 673
					goto __continue81 -- 675
				end -- 675
				if p.room.key == "outside" and s.y > 10 and s.id ~= "outside_red_cart" then -- 675
					local groundY = cam:sy(0) -- 680
					local pierW = cam:len(16) -- 681
					fgDraw:drawRect( -- 682
						Rect(x0, groundY, pierW, y0 - groundY), -- 682
						Color(32, 37, 46, 215), -- 682
						0.9, -- 682
						Color(68, 76, 88, 140) -- 682
					) -- 682
					fgDraw:drawRect( -- 683
						Rect(x1 - pierW, groundY, pierW, y0 - groundY), -- 683
						Color(32, 37, 46, 215), -- 683
						0.9, -- 683
						Color(68, 76, 88, 140) -- 683
					) -- 683
				end -- 683
				if s.passable == true then -- 683
					if not assets:tryPlace( -- 683
						"grass", -- 688
						"hide_grass_" .. tostring(i), -- 688
						(x0 + x1) * 0.5, -- 688
						y0, -- 688
						sw, -- 688
						sh * 1.55, -- 688
						{opacity = 0.79, layer = 7} -- 689
					) then -- 689
						self:drawGrassCluster( -- 690
							fgDraw, -- 690
							fgGlow, -- 690
							x0, -- 690
							y0, -- 690
							sw, -- 690
							sh, -- 690
							p.player.x, -- 690
							s.x + s.w * 0.5, -- 690
							time -- 690
						) -- 690
					end -- 690
					goto __continue81 -- 692
				end -- 692
				if (string.find(s.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 692
					self:drawWinch( -- 697
						fgDraw, -- 697
						assets, -- 697
						x0, -- 697
						y0, -- 697
						sw, -- 697
						sh, -- 697
						p, -- 697
						2 -- 697
					) -- 697
					goto __continue81 -- 698
				end -- 698
				if p.room.key == "tower" then -- 698
					self:drawTowerStructure( -- 703
						fgDraw, -- 703
						fgGlow, -- 703
						assets, -- 703
						x0, -- 703
						y0, -- 703
						sw, -- 703
						sh, -- 703
						s, -- 703
						p, -- 703
						cam, -- 703
						time -- 703
					) -- 703
					goto __continue81 -- 704
				end -- 704
				if s.h <= 64 and s.y <= 2 then -- 704
					self:drawCoverBlock( -- 709
						fgDraw, -- 709
						fgGlow, -- 709
						assets, -- 709
						x0, -- 709
						y0, -- 709
						sw, -- 709
						sh, -- 709
						s, -- 709
						p, -- 709
						theme -- 709
					) -- 709
					goto __continue81 -- 710
				end -- 710
				fillVGradRect( -- 713
					fgDraw, -- 713
					x0, -- 713
					y0, -- 713
					sw, -- 713
					sh, -- 713
					toColor(PALETTE.steelDark), -- 713
					toColor(PALETTE.steelMid) -- 713
				) -- 713
				self:tileMasonry( -- 714
					assets, -- 714
					s, -- 714
					x0, -- 714
					y0, -- 714
					sw, -- 714
					sh -- 714
				) -- 714
			end -- 714
			::__continue81:: -- 714
			i = i + 1 -- 644
		end -- 644
	end -- 644
end -- 632
function StageRenderer.prototype.drawDepthSolid(self, draw, assets, solid, depth, left, right, cam, theme, opacity, p) -- 718
	local width = right - left -- 722
	local base = cam:sy(solid.y, depth.min) -- 723
	local rearBase = cam:sy(solid.y, depth.max) -- 724
	local top = cam:sy(solid.y + solid.h, depth.min) -- 725
	local rear = cam:sy(solid.y + solid.h, depth.max) -- 726
	local frontH = top - base -- 727
	local slot = coverArt(solid) -- 728
	local layer = depthOrder(depth.min, 1) -- 729
	local key = (("depth_solid_" .. tostring(solid.x)) .. "_") .. tostring(depth.min) -- 730
	local capHeight = rear - top -- 731
	local center = (left + right) * 0.5 -- 732
	if solid.y <= 2 and rearBase > base + 1 then -- 732
		draw:drawRect( -- 736
			Rect(left, base, width, rearBase - base), -- 737
			Color( -- 738
				9, -- 738
				10, -- 738
				14, -- 738
				math.floor(86 * opacity + 0.5) -- 738
			), -- 738
			0.8, -- 739
			toColor( -- 740
				theme.groundRim, -- 740
				math.floor(58 * opacity + 0.5) -- 740
			) -- 740
		) -- 740
	end -- 740
	if (string.find(solid.label, "绞盘", nil, true) or 0) - 1 >= 0 then -- 740
		self:drawWinch( -- 746
			draw, -- 746
			assets, -- 746
			left, -- 746
			base, -- 746
			width, -- 746
			frontH, -- 746
			p, -- 746
			layer -- 746
		) -- 746
		return -- 747
	end -- 747
	if solid.art == "gate_post" and depth.min > LANE_DEPTH.middle then -- 747
		assets:tryPlace( -- 751
			"slab", -- 751
			"gate_sill_" .. tostring(solid.x), -- 751
			center, -- 751
			cam:sy(solid.y, LANE_DEPTH.middle - 6), -- 751
			width + cam:len(34), -- 752
			cam:len(12), -- 752
			{ -- 752
				layer = 1, -- 752
				color = Color(180, 169, 150, 255) -- 752
			} -- 752
		) -- 752
	end -- 752
	draw:drawEllipse( -- 754
		Vec2( -- 754
			center, -- 754
			base + cam:len(2) -- 754
		), -- 754
		width * 0.5, -- 754
		math.max( -- 755
			2, -- 755
			cam:len(2.5) -- 755
		), -- 755
		Color(10, 10, 14, 128 * opacity) -- 755
	) -- 755
	local propArt = dedicatedSolidProp(solid) -- 758
	if propArt ~= nil then -- 758
		local propPath = "assets/art/props_ming.clip|" .. propArt.clip -- 760
		local drawH = frontH * propArt.heightMul -- 761
		local cols = propArt.tileable and math.max( -- 762
			1, -- 763
			math.min( -- 763
				6, -- 763
				math.floor(solid.w / math.max(1, solid.h) / propArt.natAR + 0.5) -- 763
			) -- 763
		) or 1 -- 763
		local colW = width / cols -- 765
		local tint = occlusionTint(opacity) -- 766
		local placedProp = false -- 767
		do -- 767
			local col = 0 -- 768
			while col < cols do -- 768
				local tileKey = col == 0 and key or (key .. "_c") .. tostring(col) -- 769
				if assets:tryPlacePath( -- 769
					propPath, -- 770
					tileKey, -- 770
					left + (col + 0.5) * colW, -- 770
					base, -- 770
					colW + 1, -- 770
					drawH, -- 770
					{ -- 770
						anchorX = 0.5, -- 771
						anchorY = 0, -- 772
						preserveAspect = not propArt.tileable and cols == 1 and solid.art == "board", -- 773
						opacity = opacity, -- 774
						color = tint, -- 775
						layer = layer -- 776
					} -- 776
				) then -- 776
					placedProp = true -- 778
				end -- 778
				col = col + 1 -- 768
			end -- 768
		end -- 768
		if placedProp then -- 768
			return -- 782
		end -- 782
	end -- 782
	local timber = slot == "cover_wood" or solid.art == "thin_wood" or solid.art == "board" or solid.art == "curtain" -- 786
	if slot ~= "fence" and capHeight > 1 then -- 786
		local capFill = occlusionTint( -- 790
			opacity, -- 790
			timber and Color( -- 790
				88, -- 791
				68, -- 791
				52, -- 791
				math.floor(240 * opacity + 0.5) -- 791
			) or Color( -- 791
				86, -- 792
				90, -- 792
				98, -- 792
				math.floor(240 * opacity + 0.5) -- 792
			) -- 792
		) -- 792
		local capEdge = occlusionTint( -- 793
			opacity, -- 793
			timber and Color( -- 793
				148, -- 794
				118, -- 794
				90, -- 794
				math.floor(185 * opacity + 0.5) -- 794
			) or Color( -- 794
				146, -- 795
				152, -- 795
				160, -- 795
				math.floor(175 * opacity + 0.5) -- 795
			) -- 795
		) -- 795
		draw:drawRect( -- 796
			Rect(left, top, width, capHeight), -- 796
			capFill, -- 796
			0.9, -- 796
			capEdge -- 796
		) -- 796
		draw:drawSegment( -- 797
			Vec2(left + 1, top + 0.5), -- 797
			Vec2(right - 1, top + 0.5), -- 797
			1.1, -- 797
			capEdge -- 797
		) -- 797
		if capHeight > 8 then -- 797
			local midY = top + capHeight * 0.5 -- 799
			draw:drawSegment( -- 800
				Vec2(left + 2, midY), -- 800
				Vec2(right - 2, midY), -- 800
				0.7, -- 800
				Color( -- 800
					24, -- 800
					22, -- 800
					22, -- 800
					math.floor(90 * opacity + 0.5) -- 800
				) -- 800
			) -- 800
		end -- 800
	end -- 800
	if timber and solid.h > solid.w * 1.6 then -- 800
		local segs = math.max( -- 806
			1, -- 806
			math.min( -- 806
				6, -- 806
				math.floor(solid.h / math.max(24, solid.w * 3.5) + 0.5) -- 806
			) -- 806
		) -- 806
		local segH = frontH / segs -- 807
		local colTint = occlusionTint(opacity) -- 808
		do -- 808
			local pi = 0 -- 809
			while pi < segs do -- 809
				local tk = pi == 0 and key or (key .. "_p") .. tostring(pi) -- 810
				assets:tryPlace( -- 811
					"fe_pillar_wood", -- 811
					tk, -- 811
					center, -- 811
					base + pi * segH, -- 811
					width + 0.5, -- 811
					segH + 0.5, -- 811
					{layer = layer, opacity = opacity, color = colTint} -- 811
				) -- 811
				pi = pi + 1 -- 809
			end -- 809
		end -- 809
		return -- 815
	end -- 815
	if solid.w > solid.h * 5 then -- 815
		local segs = math.max( -- 820
			2, -- 820
			math.min( -- 820
				12, -- 820
				math.floor(solid.w / 64 + 0.5) -- 820
			) -- 820
		) -- 820
		local segW = width / segs -- 821
		local beamH = math.max(5, frontH) -- 822
		local beamTint = occlusionTint(opacity) -- 823
		do -- 823
			local bi = 0 -- 824
			while bi < segs do -- 824
				local tk = bi == 0 and key or (key .. "_b") .. tostring(bi) -- 825
				assets:tryPlace( -- 826
					"fe_beam_wood", -- 826
					tk, -- 826
					left + (bi + 0.5) * segW, -- 826
					base, -- 826
					segW + 0.5, -- 826
					beamH, -- 826
					{layer = layer, opacity = opacity, color = beamTint} -- 826
				) -- 826
				bi = bi + 1 -- 824
			end -- 824
		end -- 824
		return -- 830
	end -- 830
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 834
	local cols = slot == "wall" and math.max( -- 835
		1, -- 836
		math.min( -- 836
			10, -- 836
			math.floor(solid.w / 72 + 0.5) -- 836
		) -- 836
	) or math.max( -- 836
		1, -- 837
		math.min( -- 837
			10, -- 837
			math.floor(solid.w / math.max(1, solid.h) / natAR + 0.5) -- 837
		) -- 837
	) -- 837
	local colW = width / cols -- 838
	local rows = slot == "wall" and math.max( -- 839
		1, -- 840
		math.min( -- 840
			10, -- 840
			math.ceil(solid.h * 1.25 / math.max(1, solid.w / cols)) -- 840
		) -- 840
	) or math.max( -- 840
		1, -- 841
		math.min( -- 841
			6, -- 841
			math.floor(solid.h / math.max(1, solid.w / cols) * natAR + 0.5) -- 841
		) -- 841
	) -- 841
	local rowHeight = frontH / rows -- 842
	local masonryColor = slot == "wall" and Color(181, 176, 167, 255) or nil -- 843
	local color = occlusionTint(opacity, masonryColor) -- 844
	local placedAny = false -- 845
	do -- 845
		local row = 0 -- 846
		while row < rows do -- 846
			do -- 846
				local col = 0 -- 847
				while col < cols do -- 847
					local tileKey = row == 0 and col == 0 and key or (((key .. "_r") .. tostring(row)) .. "_c") .. tostring(col) -- 848
					if assets:tryPlace( -- 848
						slot, -- 849
						tileKey, -- 849
						left + (col + 0.5) * colW, -- 849
						base + row * rowHeight, -- 849
						colW + 0.5, -- 849
						rowHeight + 0.5, -- 849
						{layer = layer, opacity = opacity, color = color, facing = (row + col) % 2 == 0 and 1 or -1} -- 849
					) then -- 849
						placedAny = true -- 852
					end -- 852
					col = col + 1 -- 847
				end -- 847
			end -- 847
			row = row + 1 -- 846
		end -- 846
	end -- 846
	if not placedAny then -- 846
		draw:drawRect( -- 857
			Rect(left, base, width, frontH), -- 857
			occlusionTint( -- 858
				opacity, -- 858
				toColor(PALETTE.steelMid, 255 * opacity) -- 858
			), -- 858
			1, -- 859
			toColor(theme.groundRim, 150 * opacity) -- 859
		) -- 859
	end -- 859
end -- 718
function StageRenderer.prototype.tileMasonry(self, assets, s, x, y, width, height) -- 863
	local columns = math.max( -- 868
		1, -- 868
		math.min( -- 868
			10, -- 868
			math.floor(s.w / 58 + 0.5) -- 868
		) -- 868
	) -- 868
	local cellWorldW = s.w / columns -- 869
	local targetCellH = math.max( -- 870
		24, -- 870
		math.min(48, cellWorldW / 1.52) -- 870
	) -- 870
	local rows = math.max( -- 871
		1, -- 871
		math.min( -- 871
			12, -- 871
			math.floor(s.h / targetCellH + 0.5) -- 871
		) -- 871
	) -- 871
	local tileW = width / columns -- 872
	local tileH = height / rows -- 873
	do -- 873
		local row = 0 -- 874
		while row < rows do -- 874
			do -- 874
				local column = 0 -- 875
				while column < columns do -- 875
					assets:tryPlace( -- 876
						"wall", -- 876
						(((((("masonry_" .. tostring(s.x)) .. "_") .. tostring(s.y)) .. "_") .. tostring(row)) .. "_") .. tostring(column), -- 876
						x + (column + 0.5) * tileW, -- 877
						y + row * tileH, -- 877
						tileW + 0.5, -- 877
						tileH + 0.5, -- 877
						{opacity = 0.86, facing = (row + column) % 2 == 0 and 1 or -1} -- 878
					) -- 878
					column = column + 1 -- 875
				end -- 875
			end -- 875
			row = row + 1 -- 874
		end -- 874
	end -- 874
end -- 863
function StageRenderer.prototype.drawCoverBlock(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, theme) -- 883
	local slot = coverArt(s) -- 890
	local natAR = slot == "fence" and 3.53 or (slot == "cover_wood" and 2.52 or (slot == "cover_stone" and 2.29 or 1.52)) -- 891
	local cols = math.max( -- 892
		1, -- 892
		math.min( -- 892
			8, -- 892
			math.floor(s.w / math.max(1, s.h) / natAR + 0.5) -- 892
		) -- 892
	) -- 892
	local tileW = sw / cols -- 893
	local placed = false -- 894
	do -- 894
		local c = 0 -- 895
		while c < cols do -- 895
			local k = c == 0 and "cover_" .. tostring(s.x) or (("cover_" .. tostring(s.x)) .. "_") .. tostring(c) -- 896
			if assets:tryPlace( -- 896
				slot, -- 897
				k, -- 897
				x0 + (c + 0.5) * tileW, -- 897
				y0, -- 897
				tileW + 0.5, -- 897
				sh, -- 897
				{layer = 1} -- 897
			) then -- 897
				placed = true -- 898
			end -- 898
			c = c + 1 -- 895
		end -- 895
	end -- 895
	if not placed then -- 895
		fillVGradRect( -- 902
			fgDraw, -- 902
			x0, -- 902
			y0, -- 902
			sw, -- 902
			sh, -- 902
			toColor(PALETTE.steelDark), -- 902
			toColor(PALETTE.steelMid) -- 902
		) -- 902
		fgDraw:drawSegment( -- 903
			Vec2(x0, y0 + sh), -- 903
			Vec2(x0 + sw, y0 + sh), -- 903
			1.4, -- 903
			toColor(theme.groundRim) -- 903
		) -- 903
	end -- 903
	if not p.childMode and (p.coverHug or p.coverNear) then -- 903
		local plx = p.player.x -- 908
		local nearLeft = math.abs(plx - s.x) < 42 -- 909
		local nearRight = math.abs(plx - (s.x + s.w)) < 42 -- 910
		if nearLeft or nearRight then -- 910
			local edgeX = nearLeft and x0 - 1.5 or x0 + sw + 1.5 -- 912
			local isWood = slot == "cover_wood" -- 913
			local col = p.coverHug and (isWood and PALETTE.amberCore or PALETTE.moonPale) or PALETTE.silkDim -- 914
			fgDraw:drawSegment( -- 915
				Vec2(edgeX, y0 + 4), -- 915
				Vec2(edgeX, y0 + sh + 2), -- 915
				p.coverHug and 2 or 1.2, -- 915
				toColor(col, p.coverHug and 205 or 120) -- 915
			) -- 915
		end -- 915
	end -- 915
end -- 883
function StageRenderer.prototype.drawWinch(self, draw, assets, x0, y0, sw, sh, p, layer) -- 920
	if layer == nil then -- 920
		layer = 2 -- 925
	end -- 925
	local cx = x0 + sw * 0.5 -- 927
	local cy = y0 + sh * 0.55 -- 928
	local ropeWidth = math.max(1, sw * 0.023) -- 929
	local ropeTop = Vec2(cx + sw * 0.16, y0 + sh * 2.45) -- 930
	local drum = Vec2(cx + sw * 0.12, cy + sh * 0.18) -- 931
	local slack = p.phase == "gate-idle" and sw * 0.09 or 0 -- 932
	local bend = Vec2((drum.x + ropeTop.x) * 0.5 + slack, (drum.y + ropeTop.y) * 0.5) -- 933
	draw:drawEllipse( -- 934
		Vec2(cx, y0), -- 934
		sw * 0.53, -- 934
		sh * 0.07, -- 934
		Color(10, 8, 9, 150) -- 934
	) -- 934
	draw:drawSegment( -- 935
		drum, -- 935
		bend, -- 935
		ropeWidth, -- 935
		Color(111, 86, 57, 239) -- 935
	) -- 935
	draw:drawSegment( -- 936
		bend, -- 936
		ropeTop, -- 936
		ropeWidth, -- 936
		Color(111, 86, 57, 239) -- 936
	) -- 936
	if assets:tryPlace( -- 936
		"prop_winch", -- 937
		"gate_winch", -- 937
		cx, -- 937
		y0 + sh * 0.5, -- 937
		sw, -- 937
		sh, -- 937
		{layer = layer} -- 937
	) then -- 937
		return -- 938
	end -- 938
	local timber = Color(75, 51, 34, 255) -- 940
	draw:drawSegment( -- 941
		Vec2(x0 + sw * 0.15, y0 + sh * 0.07), -- 941
		Vec2(cx, y0 + sh * 0.86), -- 941
		sw * 0.06, -- 941
		timber -- 941
	) -- 941
	draw:drawSegment( -- 942
		Vec2(x0 + sw * 0.85, y0 + sh * 0.07), -- 942
		Vec2(cx, y0 + sh * 0.86), -- 942
		sw * 0.06, -- 942
		timber -- 942
	) -- 942
	draw:drawRect( -- 943
		Rect(x0, y0, sw, sh * 0.12), -- 943
		timber -- 943
	) -- 943
	local radius = math.min(sw, sh) * 0.21 -- 944
	draw:drawCircle( -- 945
		Vec2(cx, cy), -- 945
		radius, -- 945
		Color(48, 41, 37, 255) -- 945
	) -- 945
	do -- 945
		local i = -2 -- 946
		while i <= 2 do -- 946
			local x = cx + i * radius * 0.28 -- 947
			draw:drawSegment( -- 948
				Vec2(x, cy - radius * 0.62), -- 948
				Vec2(x, cy + radius * 0.62), -- 948
				ropeWidth, -- 948
				Color(135, 103, 68, 240) -- 949
			) -- 949
			i = i + 1 -- 946
		end -- 946
	end -- 946
end -- 920
function StageRenderer.prototype.drawGateShutter(self, fgDraw, fgGlow, assets, p, cam, time) -- 953
	local ____temp_3 -- 961
	if p.room.story ~= nil then -- 961
		____temp_3 = p.room.story.gate -- 961
	else -- 961
		____temp_3 = nil -- 961
	end -- 961
	local g = ____temp_3 -- 961
	if g == nil then -- 961
		return -- 963
	end -- 963
	local closeFrac = 0.08 -- 966
	if p.phase == "gate-hold" then -- 966
		closeFrac = 0.08 + 0.36 * math.min( -- 968
			1, -- 968
			p.gateTick / math.max(1, g.holdTicks) -- 968
		) -- 968
	elseif p.phase == "gate-send" then -- 968
		closeFrac = 0.44 -- 970
	elseif p.phase == "gate-count" then -- 970
		closeFrac = 0.44 + 0.56 * math.min(1, p.countTick / 360) -- 972
	elseif p.phase == "gate-walk" or p.phase == "gate-wait" or p.phase == "gate-hand" then -- 972
		closeFrac = 1 -- 974
	end -- 974
	local gx0 = cam:sx(848) -- 976
	local gx1 = cam:sx(1032) -- 977
	local topY = cam:sy(160) -- 978
	local botY = cam:sy(160 * (1 - closeFrac)) -- 979
	local shutterW = gx1 - gx0 -- 980
	local shutterH = topY - botY -- 981
	if shutterH > 2 then -- 981
		fillVGradRect( -- 983
			fgDraw, -- 983
			gx0, -- 983
			botY, -- 983
			shutterW, -- 983
			shutterH, -- 983
			toColor(PALETTE.steelDark), -- 983
			toColor(PALETTE.steelMid) -- 983
		) -- 983
		local rows = math.max( -- 985
			1, -- 985
			math.min( -- 985
				6, -- 985
				math.ceil(shutterH / math.max(18, shutterW / 2.6)) -- 985
			) -- 985
		) -- 985
		local rowH = shutterH / rows -- 986
		do -- 986
			local r = 0 -- 987
			while r < rows do -- 987
				assets:tryPlace( -- 988
					"cover_wood", -- 988
					"gate_shutter_" .. tostring(r), -- 988
					(gx0 + gx1) * 0.5, -- 988
					botY + r * rowH, -- 988
					shutterW, -- 989
					rowH + 0.5, -- 989
					{layer = 6} -- 989
				) -- 989
				r = r + 1 -- 987
			end -- 987
		end -- 987
	end -- 987
	if closeFrac < 0.98 then -- 987
		local gapH = math.max( -- 994
			8, -- 994
			botY - cam:sy(0) -- 994
		) -- 994
		local pulse = 0.8 + 0.2 * math.sin(time * 2.5) -- 995
		fillVGradRect( -- 996
			fgGlow, -- 996
			gx0, -- 996
			cam:sy(0), -- 996
			gx1 - gx0, -- 996
			gapH, -- 996
			Color( -- 996
				140, -- 996
				210, -- 996
				255, -- 996
				math.floor(52 * pulse + 0.5) -- 996
			), -- 996
			Color(80, 160, 230, 0) -- 996
		) -- 996
	end -- 996
end -- 953
function StageRenderer.prototype.drawTowerStructure(self, fgDraw, fgGlow, assets, x0, y0, sw, sh, s, p, cam, time) -- 1000
	fillVGradRect( -- 1007
		fgDraw, -- 1007
		x0, -- 1007
		y0, -- 1007
		sw, -- 1007
		sh, -- 1007
		Color(15, 21, 34, 255), -- 1007
		Color(32, 44, 66, 255) -- 1007
	) -- 1007
	fgDraw:drawRect( -- 1008
		Rect(x0, y0, sw, sh), -- 1008
		Color(0, 0, 0, 0), -- 1008
		1.4, -- 1008
		toColor(PALETTE.rimSilver, 165) -- 1008
	) -- 1008
	if (string.find(s.label, "塔身", nil, true) or 0) - 1 >= 0 then -- 1008
		self:tileMasonry( -- 1011
			assets, -- 1011
			s, -- 1011
			x0, -- 1011
			y0, -- 1011
			sw, -- 1011
			sh -- 1011
		) -- 1011
		local ribs = 4 -- 1013
		local r = 1 -- 1014
		do -- 1014
			r = 1 -- 1015
			while r < ribs do -- 1015
				local rx = x0 + sw * r / ribs -- 1016
				fgDraw:drawSegment( -- 1017
					Vec2(rx, y0), -- 1017
					Vec2(rx, y0 + sh), -- 1017
					2, -- 1017
					Color(10, 15, 24, 210) -- 1017
				) -- 1017
				fgDraw:drawSegment( -- 1018
					Vec2(rx + 2, y0), -- 1018
					Vec2(rx + 2, y0 + sh), -- 1018
					1, -- 1018
					Color(68, 86, 114, 130) -- 1018
				) -- 1018
				r = r + 1 -- 1015
			end -- 1015
		end -- 1015
		local bands = 4 -- 1021
		local b = 1 -- 1022
		do -- 1022
			b = 1 -- 1023
			while b < bands do -- 1023
				local by = y0 + sh * b / bands -- 1024
				fgDraw:drawSegment( -- 1025
					Vec2(x0 + 4, by), -- 1025
					Vec2(x0 + sw - 4, by), -- 1025
					1.2, -- 1025
					Color(52, 68, 92, 135) -- 1025
				) -- 1025
				b = b + 1 -- 1023
			end -- 1023
		end -- 1023
		local slitX = s.x < 400 and x0 + sw * 0.62 or x0 + sw * 0.34 -- 1028
		local slitY = y0 + sh * 0.56 -- 1029
		local slitH = sh * 0.22 -- 1030
		fgDraw:drawRect( -- 1031
			Rect(slitX - 5, slitY, 10, slitH), -- 1031
			Color(8, 12, 20, 245), -- 1031
			1.2, -- 1031
			toColor(PALETTE.amberDim, 190) -- 1031
		) -- 1031
		fgGlow:drawRect( -- 1032
			Rect(slitX - 2, slitY + 4, 4, slitH - 8), -- 1032
			toColor(PALETTE.amber, 190) -- 1032
		) -- 1032
		fillRadialGlow( -- 1033
			fgGlow, -- 1033
			slitX, -- 1033
			slitY + slitH * 0.5, -- 1033
			44, -- 1033
			slitH * 0.7, -- 1033
			Color(255, 206, 128, 52), -- 1033
			Color(255, 180, 86, 0), -- 1033
			14 -- 1033
		) -- 1033
	end -- 1033
	if (string.find(s.label, "门楣", nil, true) or 0) - 1 >= 0 then -- 1033
		local opened = p.towerDoorOpen or p.phase == "tower-enter" or p.phase == "tower-desk" or p.phase == "tower-given" or p.phase == "tower-end" -- 1038
		local cx = x0 + sw * 0.5 -- 1043
		local lampY = y0 - 8 -- 1044
		local doorHeight = y0 - math.max(0, y0 - sh * 3.8) -- 1045
		if not opened then -- 1045
			assets:tryPlace( -- 1047
				"prop_tower_door", -- 1047
				"tower_door", -- 1047
				cx, -- 1047
				y0 - doorHeight, -- 1047
				sw, -- 1047
				doorHeight, -- 1047
				{layer = 2} -- 1047
			) -- 1047
		end -- 1047
		assets:tryPlace( -- 1049
			"prop_lantern", -- 1049
			"tower_lantern", -- 1049
			cx + sw * 0.43, -- 1049
			lampY - sh * 0.36, -- 1049
			sw * 0.17, -- 1050
			sh * 0.84, -- 1050
			{layer = 3} -- 1050
		) -- 1050
		local pulse = 0.85 + 0.15 * math.sin(time * 3) -- 1051
		local alpha = opened and 58 or 42 -- 1052
		fgDraw:drawSegment( -- 1054
			Vec2(x0 + 4, y0), -- 1054
			Vec2(x0 + 4, y0 - sh * 3.8), -- 1054
			4, -- 1054
			Color(42, 52, 70, 255) -- 1054
		) -- 1054
		fgDraw:drawSegment( -- 1055
			Vec2(x0 + sw - 4, y0), -- 1055
			Vec2(x0 + sw - 4, y0 - sh * 3.8), -- 1055
			4, -- 1055
			Color(42, 52, 70, 255) -- 1055
		) -- 1055
		fgDraw:drawSegment( -- 1056
			Vec2(x0, y0), -- 1056
			Vec2(x0 + sw, y0), -- 1056
			2.5, -- 1056
			toColor(PALETTE.amber, 210) -- 1056
		) -- 1056
		fillVGradRect( -- 1058
			fgGlow, -- 1059
			x0 + 6, -- 1060
			y0 - sh * 3.8, -- 1061
			sw - 12, -- 1062
			sh * 3.8, -- 1063
			Color( -- 1064
				246, -- 1064
				196, -- 1064
				118, -- 1064
				math.floor((opened and alpha or alpha * 0.35) * pulse + 0.5) -- 1064
			), -- 1064
			Color(246, 206, 142, opened and 74 or 38) -- 1065
		) -- 1065
		fillRadialGlow( -- 1067
			fgGlow, -- 1067
			cx, -- 1067
			lampY, -- 1067
			opened and 78 or 54, -- 1067
			opened and 72 or 52, -- 1067
			Color( -- 1067
				252, -- 1067
				218, -- 1067
				152, -- 1067
				math.floor(92 * pulse + 0.5) -- 1067
			), -- 1067
			Color(255, 180, 86, 0), -- 1067
			18 -- 1067
		) -- 1067
		fgDraw:drawCircle( -- 1068
			Vec2(cx, lampY), -- 1068
			4.5, -- 1068
			toColor(PALETTE.amberCore) -- 1068
		) -- 1068
		if opened then -- 1068
			local deskCx = cam:sx(p.ox + 605) -- 1072
			local groundY = cam:sy(0) -- 1073
			local deskW = cam:len(84) -- 1074
			local deskH = cam:len(34) -- 1075
			local deskTop = groundY + deskH -- 1076
			local writing = p.deskHold >= 24 or p.towerHanded -- 1077
			fillRadialGlow( -- 1079
				fgGlow, -- 1079
				deskCx, -- 1079
				deskTop + cam:len(26), -- 1079
				cam:len(96), -- 1079
				cam:len(74), -- 1079
				Color( -- 1080
					255, -- 1080
					198, -- 1080
					114, -- 1080
					math.floor(52 * pulse + 0.5) -- 1080
				), -- 1080
				Color(255, 168, 72, 0), -- 1080
				16 -- 1080
			) -- 1080
			local guardX = deskCx + cam:len(26) -- 1082
			local guardClip = writing and "assets/art/actors_extra.clip|tower_guard_write" or "assets/art/actors_extra.clip|tower_guard_lantern" -- 1083
			if not assets:tryPlacePath( -- 1083
				guardClip, -- 1086
				"tower_guard_npc", -- 1086
				guardX, -- 1086
				groundY, -- 1086
				cam:len(54), -- 1086
				cam:len(84), -- 1086
				{ -- 1086
					anchorX = 0.44, -- 1087
					anchorY = 0, -- 1088
					preserveAspect = true, -- 1089
					facing = -1, -- 1090
					opacity = 0.96, -- 1091
					layer = 3 -- 1092
				} -- 1092
			) then -- 1092
				fgDraw:drawRect( -- 1094
					Rect( -- 1094
						guardX - cam:len(11), -- 1094
						groundY, -- 1094
						cam:len(22), -- 1094
						cam:len(68) -- 1094
					), -- 1094
					Color(34, 42, 54, 240) -- 1094
				) -- 1094
				fgDraw:drawCircle( -- 1095
					Vec2( -- 1095
						guardX, -- 1095
						groundY + cam:len(76) -- 1095
					), -- 1095
					cam:len(9.5), -- 1095
					Color(42, 50, 62, 245) -- 1095
				) -- 1095
			end -- 1095
			if not assets:tryPlace( -- 1095
				"prop_table", -- 1098
				"tower_guard_desk", -- 1098
				deskCx, -- 1098
				groundY, -- 1098
				deskW * 1.06, -- 1098
				deskH * 1.04, -- 1098
				{ -- 1098
					color = Color(214, 188, 158, 255), -- 1099
					opacity = 0.98, -- 1100
					layer = 4 -- 1101
				} -- 1101
			) then -- 1101
				fgDraw:drawRect( -- 1103
					Rect( -- 1103
						deskCx - deskW * 0.5, -- 1103
						groundY, -- 1103
						cam:len(6), -- 1103
						deskH -- 1103
					), -- 1103
					Color(78, 52, 34, 255) -- 1103
				) -- 1103
				fgDraw:drawRect( -- 1104
					Rect( -- 1104
						deskCx + deskW * 0.5 - cam:len(6), -- 1104
						groundY, -- 1104
						cam:len(6), -- 1104
						deskH -- 1104
					), -- 1104
					Color(78, 52, 34, 255) -- 1104
				) -- 1104
				fgDraw:drawRect( -- 1105
					Rect( -- 1105
						deskCx - deskW * 0.52, -- 1105
						deskTop - cam:len(6), -- 1105
						deskW * 1.04, -- 1105
						cam:len(8) -- 1105
					), -- 1105
					Color(108, 74, 46, 255), -- 1105
					1, -- 1105
					Color(148, 108, 68, 220) -- 1105
				) -- 1105
			end -- 1105
			fgDraw:drawRect( -- 1108
				Rect( -- 1108
					deskCx + cam:len(4), -- 1108
					deskTop + cam:len(1), -- 1108
					cam:len(22), -- 1108
					cam:len(4.5) -- 1108
				), -- 1108
				Color(232, 222, 198, 245) -- 1108
			) -- 1108
			if writing then -- 1108
				assets:tryPlace( -- 1110
					"prop_lantern", -- 1110
					"tower_desk_lamp", -- 1110
					deskCx + cam:len(34), -- 1110
					deskTop + cam:len(10), -- 1110
					cam:len(14), -- 1110
					cam:len(20), -- 1110
					{layer = 5} -- 1110
				) -- 1110
				fillRadialGlow( -- 1111
					fgGlow, -- 1111
					deskCx + cam:len(34), -- 1111
					deskTop + cam:len(12), -- 1111
					cam:len(24), -- 1111
					cam:len(22), -- 1111
					Color( -- 1111
						255, -- 1111
						214, -- 1111
						134, -- 1111
						math.floor(88 * pulse + 0.5) -- 1111
					), -- 1111
					Color(255, 180, 86, 0), -- 1111
					12 -- 1111
				) -- 1111
			else -- 1111
				fillRadialGlow( -- 1113
					fgGlow, -- 1113
					deskCx + cam:len(3), -- 1113
					deskTop + cam:len(18), -- 1113
					cam:len(30), -- 1113
					cam:len(28), -- 1113
					Color( -- 1113
						255, -- 1113
						214, -- 1113
						134, -- 1113
						math.floor(78 * pulse + 0.5) -- 1113
					), -- 1113
					Color(255, 180, 86, 0), -- 1113
					12 -- 1113
				) -- 1113
			end -- 1113
			if p.deskHold >= 12 or p.towerHanded then -- 1113
				if not assets:tryPlacePath( -- 1113
					"assets/art/cutscene_cuff_rig.clip|needle_pouch_compass", -- 1117
					"tower_desk_pouch", -- 1117
					deskCx - cam:len(22), -- 1117
					deskTop + cam:len(8), -- 1117
					cam:len(18), -- 1117
					cam:len(18), -- 1117
					{anchorX = 0.5, anchorY = 0.5, smooth = true, layer = 5} -- 1117
				) then -- 1117
					fgDraw:drawRect( -- 1123
						Rect( -- 1123
							deskCx - cam:len(28), -- 1123
							deskTop + cam:len(2), -- 1123
							cam:len(14), -- 1123
							cam:len(6) -- 1123
						), -- 1123
						Color(156, 62, 48, 245) -- 1123
					) -- 1123
				end -- 1123
			end -- 1123
			if writing then -- 1123
				fgDraw:drawRect( -- 1127
					Rect( -- 1127
						deskCx - cam:len(6), -- 1127
						deskTop + cam:len(2), -- 1127
						cam:len(10), -- 1127
						cam:len(3) -- 1127
					), -- 1127
					Color(236, 228, 206, 240) -- 1127
				) -- 1127
			end -- 1127
		end -- 1127
	end -- 1127
end -- 1000
function StageRenderer.prototype.drawGrassCluster(self, fgDraw, fgGlow, x0, y0, sw, sh, playerX, centerWorldX, time) -- 1133
	local blades = math.max( -- 1140
		12, -- 1140
		math.floor(sw / 8) -- 1140
	) -- 1140
	local nearPlayer = math.abs(playerX - centerWorldX) < 62 -- 1141
	local k = 0 -- 1142
	do -- 1142
		k = 0 -- 1143
		while k < blades do -- 1143
			local t = (k + 0.5) / blades -- 1144
			local bx = x0 + sw * t -- 1145
			local hRatio = 0.78 + 0.52 * hash01(k * 17.3 + x0 * 0.01) -- 1146
			local bh = sh * hRatio * 1.95 -- 1147
			local sway = math.sin(time * 2.1 + k * 0.8) * 6 + (nearPlayer and (t < 0.5 and -9 or 9) or 0) -- 1148
			local col = k & 1 == 0 and Color(20, 58, 54, 235) or Color(34, 88, 76, 240) -- 1149
			fgDraw:drawPolygon( -- 1150
				{ -- 1150
					Vec2(bx - 7, y0), -- 1151
					Vec2(bx + 7, y0), -- 1152
					Vec2(bx + sway, y0 + bh) -- 1153
				}, -- 1153
				col -- 1154
			) -- 1154
			k = k + 1 -- 1143
		end -- 1143
	end -- 1143
	if nearPlayer then -- 1143
		fgGlow:drawSegment( -- 1157
			Vec2(x0, y0 + 2), -- 1157
			Vec2(x0 + sw, y0 + 2), -- 1157
			2, -- 1157
			toColor(PALETTE.emerald, 145) -- 1157
		) -- 1157
	end -- 1157
end -- 1133
function StageRenderer.prototype.drawArch(self, draw, assets, p, cam) -- 1161
	local a = p.room.arch -- 1167
	if p.room.key ~= "outside" or a.h <= 0 or a.x1 <= a.x0 then -- 1167
		return -- 1169
	end -- 1169
	local x0 = cam:sx(a.x0) -- 1171
	local x1 = cam:sx(a.x1) -- 1172
	local y0 = cam:sy(a.y) -- 1173
	local y1 = cam:sy(a.y + a.h) -- 1174
	local cx = (x0 + x1) * 0.5 -- 1175
	local aw = x1 - x0 -- 1176
	local ah = y1 - y0 -- 1177
	draw:drawRect( -- 1178
		Rect( -- 1178
			x0, -- 1178
			y0, -- 1178
			aw, -- 1178
			ah + cam:len(8) -- 1178
		), -- 1178
		Color(13, 15, 20, 242) -- 1178
	) -- 1178
	if not assets:tryPlace( -- 1178
		"fe_outside_arch", -- 1179
		"outside_arch_vault", -- 1179
		cx, -- 1179
		y0, -- 1179
		aw + cam:len(24), -- 1179
		ah + cam:len(22), -- 1179
		{layer = 2} -- 1179
	) then -- 1179
		draw:drawRect( -- 1180
			Rect( -- 1180
				x0 - cam:len(7), -- 1180
				y0, -- 1180
				cam:len(7), -- 1180
				ah -- 1180
			), -- 1180
			Color(62, 63, 67, 255) -- 1180
		) -- 1180
		draw:drawRect( -- 1181
			Rect( -- 1181
				x1, -- 1181
				y0, -- 1181
				cam:len(7), -- 1181
				ah -- 1181
			), -- 1181
			Color(72, 72, 74, 255) -- 1181
		) -- 1181
	end -- 1181
	if not p.cartDocked then -- 1181
		local bx0 = cam:sx(math.max(a.x0 + 4, p.cartAxle - 18)) -- 1185
		local bx1 = cam:sx(math.min(a.x1 - 4, p.cartAxle + 18)) -- 1186
		if bx1 > bx0 + 4 then -- 1186
			local deckY = cam:sy(p.room.cart.baseY) -- 1188
			assets:tryPlace( -- 1189
				"fe_pillar_wood", -- 1189
				"outside_arch_bolt", -- 1189
				(bx0 + bx1) * 0.5, -- 1189
				y0 + 2, -- 1189
				bx1 - bx0, -- 1189
				ah - 2, -- 1189
				{layer = 3} -- 1189
			) -- 1189
			draw:drawSegment( -- 1190
				Vec2((bx0 + bx1) * 0.5, y1), -- 1190
				Vec2((bx0 + bx1) * 0.5, deckY), -- 1190
				2.4, -- 1190
				Color(96, 102, 110, 220) -- 1190
			) -- 1190
		end -- 1190
	end -- 1190
end -- 1161
return ____exports -- 1161