-- [ts]: graybox.ts
local ____exports = {} -- 1
local rectOf, markColor, drawStairs, drawCart, drawFigure, PX, INK, CART_FILL, CLOTH, CHECK, STAND, EXIT, LAND -- 1
local ____Dora = require("Dora") -- 10
local Color = ____Dora.Color -- 10
local Rect = ____Dora.Rect -- 10
local Vec2 = ____Dora.Vec2 -- 10
function ____exports.pxX(v, m, room) -- 70
	return v.padX + (m - room.minX) * v.scale -- 71
end -- 70
function ____exports.pxY(v, m) -- 74
	return v.groundPx + m * v.scale -- 75
end -- 74
function rectOf(v, room, x0, x1, y0, y1) -- 78
	return Rect( -- 79
		____exports.pxX(v, x0, room), -- 79
		____exports.pxY(v, y0), -- 79
		(x1 - x0) * v.scale, -- 79
		(y1 - y0) * v.scale -- 79
	) -- 79
end -- 79
function markColor(kind) -- 203
	if kind == 0 then -- 203
		return CHECK -- 205
	end -- 205
	if kind == 1 then -- 205
		return STAND -- 208
	end -- 208
	if kind == 2 then -- 208
		return EXIT -- 211
	end -- 211
	return LAND -- 213
end -- 213
function drawStairs(draw, room, v, s) -- 216
	local prevX = ____exports.pxX(v, s.x1, room) -- 218
	local prevY = ____exports.pxY(v, s.y1) -- 219
	do -- 219
		local i = 1 -- 220
		while i <= s.steps do -- 220
			local t = i / s.steps -- 221
			local nx = ____exports.pxX(v, s.x1 - (s.x1 - s.x0) * t, room) -- 222
			local ny = ____exports.pxY(v, s.y1 - (s.y1 - s.y0) * t) -- 223
			draw:drawSegment( -- 224
				Vec2(prevX, prevY), -- 224
				Vec2(nx, prevY), -- 224
				2 * PX, -- 224
				INK -- 224
			) -- 224
			draw:drawSegment( -- 225
				Vec2(nx, prevY), -- 225
				Vec2(nx, ny), -- 225
				2 * PX, -- 225
				INK -- 225
			) -- 225
			prevX = nx -- 226
			prevY = ny -- 227
			i = i + 1 -- 220
		end -- 220
	end -- 220
end -- 220
function drawCart(draw, room, v, cx, ghost) -- 231
	local c = room.cart -- 232
	local half = c.bodyW / 2 -- 233
	local y0 = c.baseY -- 234
	local yBody = y0 + c.wheelR * 1.2 -- 235
	local yTop = yBody + c.bodyH -- 236
	local fill = ghost and Color(90, 62, 48, 90) or CART_FILL -- 237
	local edge = ghost and Color(150, 110, 96, 150) or Color(196, 152, 124, 255) -- 238
	draw:drawRect( -- 241
		rectOf( -- 241
			v, -- 241
			room, -- 241
			cx - half, -- 241
			cx + half, -- 241
			yBody, -- 241
			yTop -- 241
		), -- 241
		fill -- 241
	) -- 241
	draw:drawRect( -- 242
		rectOf( -- 242
			v, -- 242
			room, -- 242
			cx - half, -- 242
			cx + half, -- 242
			yBody, -- 242
			yTop -- 242
		), -- 242
		Color(0, 0, 0, 0), -- 242
		1.5 * PX, -- 242
		edge -- 242
	) -- 242
	draw:drawCircle( -- 245
		Vec2( -- 245
			____exports.pxX(v, cx, room), -- 245
			____exports.pxY(v, y0 + c.wheelR) -- 245
		), -- 245
		c.wheelR * v.scale, -- 245
		fill -- 245
	) -- 245
	draw:drawRing( -- 246
		Vec2( -- 247
			____exports.pxX(v, cx, room), -- 247
			____exports.pxY(v, y0 + c.wheelR) -- 247
		), -- 247
		c.wheelR * v.scale * 0.5, -- 248
		c.wheelR * v.scale + 1 * PX, -- 249
		Color(0, 0, 0, 0), -- 250
		1.5 * PX, -- 251
		edge -- 252
	) -- 252
	draw:drawDot( -- 254
		Vec2( -- 254
			____exports.pxX(v, cx, room), -- 254
			____exports.pxY(v, y0 + c.wheelR) -- 254
		), -- 254
		2.5 * PX, -- 254
		edge -- 254
	) -- 254
	local hx = cx + c.handleOffset -- 257
	draw:drawSegment( -- 258
		Vec2( -- 258
			____exports.pxX(v, hx, room), -- 258
			____exports.pxY(v, y0) -- 258
		), -- 258
		Vec2( -- 258
			____exports.pxX(v, hx, room), -- 258
			____exports.pxY(v, yTop + c.bodyH * 0.5) -- 258
		), -- 258
		2 * PX, -- 258
		edge -- 258
	) -- 258
	draw:drawDot( -- 259
		Vec2( -- 259
			____exports.pxX(v, hx, room), -- 259
			____exports.pxY(v, yTop + c.bodyH * 0.5) -- 259
		), -- 259
		3 * PX, -- 259
		edge -- 259
	) -- 259
	local clothX = cx + half * c.clothSide -- 262
	draw:drawPolygon( -- 263
		{ -- 263
			Vec2( -- 264
				____exports.pxX(v, clothX, room), -- 264
				____exports.pxY(v, yTop) -- 264
			), -- 264
			Vec2( -- 265
				____exports.pxX(v, clothX - 10 * c.clothSide, room), -- 265
				____exports.pxY(v, yTop - 3) -- 265
			), -- 265
			Vec2( -- 266
				____exports.pxX(v, clothX - 14 * c.clothSide, room), -- 266
				____exports.pxY(v, yTop - 34) -- 266
			), -- 266
			Vec2( -- 267
				____exports.pxX(v, clothX + 2 * c.clothSide, room), -- 267
				____exports.pxY(v, yTop - 30) -- 267
			) -- 267
		}, -- 267
		ghost and Color(120, 46, 42, 120) or CLOTH -- 268
	) -- 268
end -- 268
function drawFigure(draw, v, room, x, y, bodyH, color) -- 271
	local headR = bodyH * 0.075 -- 272
	local cx = ____exports.pxX(v, x, room) -- 273
	local foot = ____exports.pxY(v, y + 2) -- 274
	local shoulder = ____exports.pxY(v, y + bodyH * 0.86) -- 275
	local headC = ____exports.pxY(v, y + bodyH - headR) -- 276
	draw:drawRect( -- 277
		Rect( -- 277
			cx - 0.11 * bodyH * v.scale, -- 277
			____exports.pxY(v, y + bodyH * 0.42), -- 277
			0.22 * bodyH * v.scale, -- 277
			bodyH * 0.44 * v.scale -- 277
		), -- 277
		color -- 277
	) -- 277
	draw:drawSegment( -- 278
		Vec2( -- 278
			cx - 0.06 * bodyH * v.scale, -- 278
			____exports.pxY(v, y + bodyH * 0.42) -- 278
		), -- 278
		Vec2(cx - 0.08 * bodyH * v.scale, foot), -- 278
		2 * PX, -- 278
		color -- 278
	) -- 278
	draw:drawSegment( -- 279
		Vec2( -- 279
			cx + 0.06 * bodyH * v.scale, -- 279
			____exports.pxY(v, y + bodyH * 0.42) -- 279
		), -- 279
		Vec2(cx + 0.08 * bodyH * v.scale, foot), -- 279
		2 * PX, -- 279
		color -- 279
	) -- 279
	draw:drawSegment( -- 280
		Vec2(cx - 0.11 * bodyH * v.scale, shoulder), -- 280
		Vec2( -- 280
			cx - 0.2 * bodyH * v.scale, -- 280
			____exports.pxY(v, y + bodyH * 0.5) -- 280
		), -- 280
		2 * PX, -- 280
		color -- 280
	) -- 280
	draw:drawSegment( -- 281
		Vec2(cx + 0.11 * bodyH * v.scale, shoulder), -- 281
		Vec2( -- 281
			cx + 0.2 * bodyH * v.scale, -- 281
			____exports.pxY(v, y + bodyH * 0.5) -- 281
		), -- 281
		2 * PX, -- 281
		color -- 281
	) -- 281
	draw:drawCircle( -- 282
		Vec2(cx, headC), -- 282
		headR * v.scale, -- 282
		color -- 282
	) -- 282
end -- 282
PX = 2 -- 30
local PAD_X = 72 * PX -- 32
local PAD_TOP = 104 * PX -- 33
local PAD_BOTTOM = 108 * PX -- 34
INK = Color(232, 232, 228, 255) -- 36
local INK_DIM = Color(150, 152, 150, 255) -- 37
local BG_FAR = Color(24, 26, 28, 255) -- 38
local BG_MID = Color(31, 34, 37, 255) -- 39
local BG_NEAR = Color(38, 41, 44, 255) -- 40
local GROUND = Color(112, 114, 112, 255) -- 41
local FLOOR_DECK = Color(66, 70, 72, 255) -- 42
local SOLID_FILL = Color(84, 86, 84, 255) -- 43
CART_FILL = Color(122, 78, 56, 255) -- 44
CLOTH = Color(178, 52, 46, 255) -- 45
local HOLE_FILL = Color(10, 11, 12, 255) -- 46
local DANGER = Color(150, 54, 48, 70) -- 47
local DANGER_LINE = Color(178, 78, 64, 220) -- 48
local DIM_LINE = Color(126, 132, 140, 255) -- 49
CHECK = Color(96, 186, 122, 255) -- 50
STAND = Color(226, 186, 84, 255) -- 51
EXIT = Color(96, 166, 226, 255) -- 52
LAND = Color(206, 196, 122, 255) -- 53
function ____exports.computeView(room, w, h) -- 55
	local usableW = math.max(240 * PX, w - PAD_X * 2) -- 56
	local drawH = math.max(160 * PX, h - PAD_TOP - PAD_BOTTOM) -- 57
	local spanX = math.max(1, room.maxX - room.minX) -- 58
	local scale = math.min(usableW / spanX, drawH / room.height) -- 59
	local groundPx = PAD_BOTTOM + (drawH - room.height * scale) / 2 -- 61
	return {scale = scale, padX = PAD_X, groundPx = groundPx} -- 62
end -- 55
--- 尺寸线在地面下的像素位置：i=0 最靠地面。
local function dimPxY(v, i) -- 66
	return v.groundPx - 30 * PX - i * 22 * PX -- 67
end -- 66
--- 画背景、地面、台面、实体、拱、台阶、板车、标记点。
function ____exports.renderWorld(draw, room, v, w, h) -- 83
	local ground = ____exports.pxY(v, 0) -- 84
	local top = ____exports.pxY(v, room.height) -- 85
	draw:drawRect( -- 88
		Rect(0, 0, w, h), -- 88
		BG_FAR -- 88
	) -- 88
	draw:drawRect( -- 89
		Rect(0, ground, w, top - ground), -- 89
		BG_MID -- 89
	) -- 89
	do -- 89
		local i = 0 -- 92
		while i < #room.floors do -- 92
			local f = room.floors[i + 1] -- 93
			local y = ____exports.pxY(v, f.y) -- 94
			local x0 = ____exports.pxX(v, f.x0, room) -- 95
			local x1 = ____exports.pxX(v, f.x1, room) -- 96
			draw:drawRect( -- 97
				Rect(x0, y, x1 - x0, top - y), -- 97
				BG_NEAR -- 97
			) -- 97
			draw:drawSegment( -- 98
				Vec2(x0, y), -- 98
				Vec2(x1, y), -- 98
				3 * PX, -- 98
				GROUND -- 98
			) -- 98
			if f.y > 0 then -- 98
				draw:drawRect( -- 101
					Rect(x0, y - 10 * PX, x1 - x0, 10 * PX), -- 101
					FLOOR_DECK -- 101
				) -- 101
			end -- 101
			i = i + 1 -- 92
		end -- 92
	end -- 92
	do -- 92
		local i = 0 -- 106
		while i < #room.zones do -- 106
			do -- 106
				local z = room.zones[i + 1] -- 107
				if z.tint ~= 1 then -- 107
					goto __continue12 -- 109
				end -- 109
				draw:drawRect( -- 111
					rectOf( -- 111
						v, -- 111
						room, -- 111
						z.x0, -- 111
						z.x1, -- 111
						z.y, -- 111
						z.y + z.h -- 111
					), -- 111
					DANGER -- 111
				) -- 111
				draw:drawSegment( -- 112
					Vec2( -- 113
						____exports.pxX(v, z.x0, room), -- 113
						____exports.pxY(v, z.y + z.h) -- 113
					), -- 113
					Vec2( -- 114
						____exports.pxX(v, z.x1, room), -- 114
						____exports.pxY(v, z.y + z.h) -- 114
					), -- 114
					1 * PX, -- 115
					DANGER_LINE -- 116
				) -- 116
			end -- 116
			::__continue12:: -- 116
			i = i + 1 -- 106
		end -- 106
	end -- 106
	do -- 106
		local i = 0 -- 121
		while i < #room.solids do -- 121
			local s = room.solids[i + 1] -- 122
			draw:drawRect( -- 123
				rectOf( -- 123
					v, -- 123
					room, -- 123
					s.x, -- 123
					s.x + s.w, -- 123
					s.y, -- 123
					s.y + s.h -- 123
				), -- 123
				SOLID_FILL -- 123
			) -- 123
			draw:drawRect( -- 124
				rectOf( -- 124
					v, -- 124
					room, -- 124
					s.x, -- 124
					s.x + s.w, -- 124
					s.y, -- 124
					s.y + s.h -- 124
				), -- 124
				Color(0, 0, 0, 0), -- 124
				1.5 * PX, -- 124
				INK_DIM -- 124
			) -- 124
			i = i + 1 -- 121
		end -- 121
	end -- 121
	if room.arch.x1 > room.arch.x0 then -- 121
		local a = room.arch -- 129
		draw:drawRect( -- 130
			rectOf( -- 130
				v, -- 130
				room, -- 130
				a.x0, -- 130
				a.x1, -- 130
				a.y, -- 130
				a.y + a.h -- 130
			), -- 130
			HOLE_FILL -- 130
		) -- 130
		draw:drawSegment( -- 131
			Vec2( -- 131
				____exports.pxX(v, a.x0, room), -- 131
				____exports.pxY(v, a.y) -- 131
			), -- 131
			Vec2( -- 131
				____exports.pxX(v, a.x0, room), -- 131
				____exports.pxY(v, a.y + a.h) -- 131
			), -- 131
			2 * PX, -- 131
			INK -- 131
		) -- 131
		draw:drawSegment( -- 132
			Vec2( -- 132
				____exports.pxX(v, a.x1, room), -- 132
				____exports.pxY(v, a.y) -- 132
			), -- 132
			Vec2( -- 132
				____exports.pxX(v, a.x1, room), -- 132
				____exports.pxY(v, a.y + a.h) -- 132
			), -- 132
			2 * PX, -- 132
			INK -- 132
		) -- 132
		draw:drawArc( -- 133
			Vec2( -- 134
				____exports.pxX(v, (a.x0 + a.x1) / 2, room), -- 134
				____exports.pxY(v, a.y + a.h * 0.55) -- 134
			), -- 134
			(a.x1 - a.x0) / 2 * v.scale, -- 135
			0, -- 136
			180, -- 137
			2 * PX, -- 138
			INK -- 139
		) -- 139
	end -- 139
	do -- 139
		local i = 0 -- 144
		while i < #room.stairs do -- 144
			drawStairs(draw, room, v, room.stairs[i + 1]) -- 145
			i = i + 1 -- 144
		end -- 144
	end -- 144
	local cart = room.cart -- 149
	local lo = math.min(cart.startX, cart.endX) -- 150
	local hi = math.max(cart.startX, cart.endX) -- 151
	if hi - lo > 4 then -- 151
		local yBase = cart.baseY -- 153
		draw:drawSegment( -- 154
			Vec2( -- 154
				____exports.pxX(v, lo, room), -- 154
				____exports.pxY(v, yBase + 3) -- 154
			), -- 154
			Vec2( -- 154
				____exports.pxX(v, hi, room), -- 154
				____exports.pxY(v, yBase + 3) -- 154
			), -- 154
			1 * PX, -- 154
			INK_DIM -- 154
		) -- 154
		draw:drawSegment( -- 155
			Vec2( -- 155
				____exports.pxX(v, lo, room), -- 155
				____exports.pxY(v, yBase + 9) -- 155
			), -- 155
			Vec2( -- 155
				____exports.pxX(v, hi, room), -- 155
				____exports.pxY(v, yBase + 9) -- 155
			), -- 155
			1 * PX, -- 155
			INK_DIM -- 155
		) -- 155
		draw:drawSegment( -- 156
			Vec2( -- 156
				____exports.pxX(v, lo, room), -- 156
				____exports.pxY(v, yBase + 1) -- 156
			), -- 156
			Vec2( -- 156
				____exports.pxX(v, lo, room), -- 156
				____exports.pxY(v, yBase + 11) -- 156
			), -- 156
			1 * PX, -- 156
			INK_DIM -- 156
		) -- 156
		draw:drawSegment( -- 157
			Vec2( -- 157
				____exports.pxX(v, hi, room), -- 157
				____exports.pxY(v, yBase + 1) -- 157
			), -- 157
			Vec2( -- 157
				____exports.pxX(v, hi, room), -- 157
				____exports.pxY(v, yBase + 11) -- 157
			), -- 157
			1 * PX, -- 157
			INK_DIM -- 157
		) -- 157
	end -- 157
	drawCart( -- 161
		draw, -- 161
		room, -- 161
		v, -- 161
		cart.startX, -- 161
		true -- 161
	) -- 161
	drawCart( -- 162
		draw, -- 162
		room, -- 162
		v, -- 162
		cart.endX, -- 162
		false -- 162
	) -- 162
	if math.abs(cart.startX - cart.endX) > 4 then -- 162
		local wx = ____exports.pxX(v, cart.endX, room) -- 166
		local wy = ____exports.pxY(v, cart.baseY) -- 167
		draw:drawSegment( -- 168
			Vec2(wx - 0.9 * cart.wheelR * v.scale, wy), -- 168
			Vec2(wx + 0.9 * cart.wheelR * v.scale, wy), -- 168
			2 * PX, -- 168
			INK -- 168
		) -- 168
		draw:drawSegment( -- 169
			Vec2(wx - 0.7 * cart.wheelR * v.scale, wy - 6 * PX), -- 169
			Vec2(wx - 0.7 * cart.wheelR * v.scale, wy + 3 * PX), -- 169
			1 * PX, -- 169
			INK -- 169
		) -- 169
		draw:drawSegment( -- 170
			Vec2(wx + 0.7 * cart.wheelR * v.scale, wy - 6 * PX), -- 170
			Vec2(wx + 0.7 * cart.wheelR * v.scale, wy + 3 * PX), -- 170
			1 * PX, -- 170
			INK -- 170
		) -- 170
	end -- 170
	do -- 170
		local i = 0 -- 174
		while i < #room.marks do -- 174
			local m = room.marks[i + 1] -- 175
			local mx = ____exports.pxX(v, m.x, room) -- 176
			local my = ____exports.pxY(v, m.y) -- 177
			local c = markColor(m.kind) -- 178
			draw:drawSegment( -- 179
				Vec2(mx, my), -- 179
				Vec2( -- 179
					mx, -- 179
					____exports.pxY(v, room.height - 26) -- 179
				), -- 179
				1 * PX, -- 179
				c -- 179
			) -- 179
			draw:drawDot( -- 180
				Vec2(mx, my), -- 180
				4.5 * PX, -- 180
				c -- 180
			) -- 180
			draw:drawRing( -- 181
				Vec2(mx, my), -- 181
				8 * PX, -- 181
				10 * PX, -- 181
				Color(0, 0, 0, 0), -- 181
				1 * PX, -- 181
				c -- 181
			) -- 181
			draw:drawDot( -- 182
				Vec2( -- 182
					mx, -- 182
					____exports.pxY(v, room.height - 26) -- 182
				), -- 182
				4 * PX, -- 182
				c -- 182
			) -- 182
			i = i + 1 -- 174
		end -- 174
	end -- 174
	do -- 174
		local i = 0 -- 186
		while i < #room.spawns do -- 186
			local s = room.spawns[i + 1] -- 187
			drawFigure( -- 188
				draw, -- 188
				v, -- 188
				room, -- 188
				s.x, -- 188
				s.y, -- 188
				s.h, -- 188
				i == 0 and Color(198, 176, 132, 210) or Color(168, 180, 198, 210) -- 188
			) -- 188
			i = i + 1 -- 186
		end -- 186
	end -- 186
	do -- 186
		local i = 0 -- 192
		while i < #room.dims do -- 192
			local d = room.dims[i + 1] -- 193
			local y = dimPxY(v, i) -- 194
			local xa = ____exports.pxX( -- 195
				v, -- 195
				math.min(d.x0, d.x1), -- 195
				room -- 195
			) -- 195
			local xb = ____exports.pxX( -- 196
				v, -- 196
				math.max(d.x0, d.x1), -- 196
				room -- 196
			) -- 196
			draw:drawSegment( -- 197
				Vec2(xa, y), -- 197
				Vec2(xb, y), -- 197
				1 * PX, -- 197
				DIM_LINE -- 197
			) -- 197
			draw:drawSegment( -- 198
				Vec2(xa, y - 6 * PX), -- 198
				Vec2(xa, y + 6 * PX), -- 198
				1 * PX, -- 198
				DIM_LINE -- 198
			) -- 198
			draw:drawSegment( -- 199
				Vec2(xb, y - 6 * PX), -- 199
				Vec2(xb, y + 6 * PX), -- 199
				1 * PX, -- 199
				DIM_LINE -- 199
			) -- 199
			i = i + 1 -- 192
		end -- 192
	end -- 192
end -- 83
--- 收集当前房间的文字标签（屏幕坐标，root 左下原点）。
function ____exports.collectLabels(room, v, w) -- 286
	local out = {} -- 287
	do -- 287
		local i = 0 -- 290
		while i < #room.spawns do -- 290
			local s = room.spawns[i + 1] -- 291
			out[#out + 1] = { -- 292
				x = ____exports.pxX(v, s.x, room), -- 293
				y = ____exports.pxY(v, s.y + s.h) + (8 + i * 26) * PX, -- 294
				text = s.label, -- 295
				ax = 0.5, -- 296
				ay = 0, -- 297
				color = INK, -- 298
				size = 12 * PX -- 299
			} -- 299
			i = i + 1 -- 290
		end -- 290
	end -- 290
	do -- 290
		local i = 0 -- 303
		while i < #room.solids do -- 303
			local s = room.solids[i + 1] -- 304
			out[#out + 1] = { -- 305
				x = ____exports.pxX(v, s.x + s.w / 2, room), -- 306
				y = ____exports.pxY(v, s.y + s.h) + 8 * PX, -- 307
				text = s.label, -- 308
				ax = 0.5, -- 309
				ay = 0, -- 310
				color = INK, -- 311
				size = 12 * PX -- 312
			} -- 312
			i = i + 1 -- 303
		end -- 303
	end -- 303
	do -- 303
		local i = 0 -- 316
		while i < #room.zones do -- 316
			do -- 316
				local z = room.zones[i + 1] -- 317
				if #z.label == 0 then -- 317
					goto __continue42 -- 319
				end -- 319
				out[#out + 1] = { -- 321
					x = ____exports.pxX(v, (z.x0 + z.x1) / 2, room), -- 322
					y = ____exports.pxY(v, z.y + z.h) + 8 * PX, -- 323
					text = z.label, -- 324
					ax = 0.5, -- 325
					ay = 0, -- 326
					color = DANGER_LINE, -- 327
					size = 12 * PX -- 328
				} -- 328
			end -- 328
			::__continue42:: -- 328
			i = i + 1 -- 316
		end -- 316
	end -- 316
	if room.arch.x1 > room.arch.x0 then -- 316
		out[#out + 1] = { -- 333
			x = ____exports.pxX(v, (room.arch.x0 + room.arch.x1) / 2, room), -- 334
			y = ____exports.pxY(v, room.arch.y + room.arch.h) + 10 * PX, -- 335
			text = room.arch.label, -- 336
			ax = 0.5, -- 337
			ay = 0, -- 338
			color = INK, -- 339
			size = 12 * PX -- 340
		} -- 340
	end -- 340
	do -- 340
		local i = 0 -- 344
		while i < #room.stairs do -- 344
			local s = room.stairs[i + 1] -- 345
			out[#out + 1] = { -- 346
				x = ____exports.pxX(v, (s.x0 + s.x1) / 2, room), -- 347
				y = ____exports.pxY(v, s.y1) + 8 * PX, -- 348
				text = s.label, -- 349
				ax = 0.5, -- 350
				ay = 0, -- 351
				color = INK_DIM, -- 352
				size = 11 * PX -- 353
			} -- 353
			i = i + 1 -- 344
		end -- 344
	end -- 344
	do -- 344
		local i = 0 -- 357
		while i < #room.marks do -- 357
			local m = room.marks[i + 1] -- 358
			out[#out + 1] = { -- 359
				x = ____exports.pxX(v, m.x, room), -- 360
				y = ____exports.pxY(v, room.height - 26) + 6 * PX, -- 361
				text = m.label, -- 362
				ax = 0.5, -- 363
				ay = 0, -- 364
				color = markColor(m.kind), -- 365
				size = 11 * PX -- 366
			} -- 366
			i = i + 1 -- 357
		end -- 357
	end -- 357
	do -- 357
		local i = 0 -- 370
		while i < #room.dims do -- 370
			local d = room.dims[i + 1] -- 371
			local mid = (____exports.pxX(v, d.x0, room) + ____exports.pxX(v, d.x1, room)) / 2 -- 372
			out[#out + 1] = { -- 373
				x = mid, -- 373
				y = dimPxY(v, i) - 3 * PX, -- 373
				text = d.text, -- 373
				ax = 0.5, -- 373
				ay = 0, -- 373
				color = DIM_LINE, -- 373
				size = 11 * PX -- 373
			} -- 373
			i = i + 1 -- 370
		end -- 370
	end -- 370
	out[#out + 1] = { -- 376
		x = ____exports.pxX(v, room.cart.startX, room), -- 377
		y = ____exports.pxY(v, room.cart.baseY + room.cart.wheelR * 1.2 + room.cart.bodyH) + 8 * PX, -- 378
		text = "车 · 起点", -- 379
		ax = 0.5, -- 380
		ay = 0, -- 381
		color = INK_DIM, -- 382
		size = 11 * PX -- 383
	} -- 383
	out[#out + 1] = { -- 385
		x = ____exports.pxX(v, room.cart.endX, room), -- 386
		y = ____exports.pxY(v, room.cart.baseY + room.cart.wheelR * 1.2 + room.cart.bodyH) + 34 * PX, -- 387
		text = "车 · 停靠位", -- 388
		ax = 0.5, -- 389
		ay = 0, -- 390
		color = INK_DIM, -- 391
		size = 11 * PX -- 392
	} -- 392
	return out -- 395
end -- 286
--- 1 米比例尺：画在灰盒顶部上方。世界单位 1 米 ≈ 54.3 单位，这里按 64 单位画一段，标注约 1.18 m。
function ____exports.drawScaleRuler(draw, x, yBase, unitPx) -- 399
	local yTop = yBase + unitPx -- 400
	draw:drawSegment( -- 401
		Vec2(x, yBase), -- 401
		Vec2(x, yTop), -- 401
		1.5 * PX, -- 401
		INK_DIM -- 401
	) -- 401
	draw:drawSegment( -- 402
		Vec2(x - 8 * PX, yBase), -- 402
		Vec2(x + 8 * PX, yBase), -- 402
		1.5 * PX, -- 402
		INK_DIM -- 402
	) -- 402
	draw:drawSegment( -- 403
		Vec2(x - 8 * PX, yTop), -- 403
		Vec2(x + 8 * PX, yTop), -- 403
		1.5 * PX, -- 403
		INK_DIM -- 403
	) -- 403
	draw:drawSegment( -- 404
		Vec2(x - 5 * PX, yBase + unitPx / 2), -- 404
		Vec2(x + 5 * PX, yBase + unitPx / 2), -- 404
		1 * PX, -- 404
		INK_DIM -- 404
	) -- 404
end -- 399
return ____exports -- 399