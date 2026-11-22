-- [ts]: graybox.ts
local ____exports = {} -- 1
local rectOf, drawCart, drawFigure, PX, CART_FILL, CLOTH -- 1
local ____Dora = require("Dora") -- 9
local Color = ____Dora.Color -- 9
local Rect = ____Dora.Rect -- 9
local Vec2 = ____Dora.Vec2 -- 9
function ____exports.pxX(v, m, room) -- 69
	return v.padX + (m - room.minX) * v.scale -- 70
end -- 69
function ____exports.pxY(v, m) -- 73
	return v.groundPx + m * v.scale -- 74
end -- 73
function rectOf(v, room, x0, x1, y0, y1) -- 77
	return Rect( -- 78
		____exports.pxX(v, x0, room), -- 78
		____exports.pxY(v, y0), -- 78
		(x1 - x0) * v.scale, -- 78
		(y1 - y0) * v.scale -- 78
	) -- 78
end -- 78
function drawCart(draw, room, v, cx, ghost) -- 215
	local c = room.cart -- 216
	local x0 = cx - c.bodyW / 2 -- 217
	local x1 = cx + c.bodyW / 2 -- 218
	local fill = ghost and Color(90, 62, 48, 90) or CART_FILL -- 219
	local edge = ghost and Color(150, 110, 96, 150) or Color(196, 152, 124, 255) -- 220
	draw:drawRect( -- 223
		rectOf( -- 223
			v, -- 223
			room, -- 223
			x0, -- 223
			x1, -- 223
			c.wheelR * 0.6, -- 223
			c.bodyH -- 223
		), -- 223
		fill -- 223
	) -- 223
	draw:drawRect( -- 224
		rectOf( -- 224
			v, -- 224
			room, -- 224
			x0, -- 224
			x1, -- 224
			c.wheelR * 0.6, -- 224
			c.bodyH -- 224
		), -- 224
		Color(0, 0, 0, 0), -- 224
		1.5 * PX, -- 224
		edge -- 224
	) -- 224
	draw:drawCircle( -- 227
		Vec2( -- 227
			____exports.pxX(v, x1 - 0.32, room), -- 227
			____exports.pxY(v, c.wheelR) -- 227
		), -- 227
		c.wheelR * v.scale, -- 227
		fill -- 227
	) -- 227
	draw:drawRing( -- 228
		Vec2( -- 229
			____exports.pxX(v, x1 - 0.32, room), -- 229
			____exports.pxY(v, c.wheelR) -- 229
		), -- 229
		c.wheelR * v.scale * 0.55, -- 230
		c.wheelR * v.scale + 1 * PX, -- 231
		Color(0, 0, 0, 0), -- 232
		1.5 * PX, -- 233
		edge -- 234
	) -- 234
	draw:drawDot( -- 236
		Vec2( -- 236
			____exports.pxX(v, x1 - 0.32, room), -- 236
			____exports.pxY(v, c.wheelR) -- 236
		), -- 236
		2.5 * PX, -- 236
		edge -- 236
	) -- 236
	draw:drawSegment( -- 239
		Vec2( -- 239
			____exports.pxX(v, x0, room), -- 239
			____exports.pxY(v, c.bodyH) -- 239
		), -- 239
		Vec2( -- 239
			____exports.pxX(v, x0 - 0.42, room), -- 239
			____exports.pxY(v, c.handleH) -- 239
		), -- 239
		2 * PX, -- 239
		edge -- 239
	) -- 239
	draw:drawSegment( -- 240
		Vec2( -- 241
			____exports.pxX(v, x0, room), -- 241
			____exports.pxY(v, c.bodyH - 0.14) -- 241
		), -- 241
		Vec2( -- 242
			____exports.pxX(v, x0 - 0.42, room), -- 242
			____exports.pxY(v, c.handleH - 0.14) -- 242
		), -- 242
		2 * PX, -- 243
		edge -- 244
	) -- 244
	draw:drawPolygon( -- 248
		{ -- 248
			Vec2( -- 249
				____exports.pxX(v, x0 - 0.42, room), -- 249
				____exports.pxY(v, c.handleH) -- 249
			), -- 249
			Vec2( -- 250
				____exports.pxX(v, x0 - 0.08, room), -- 250
				____exports.pxY(v, c.handleH - 0.06) -- 250
			), -- 250
			Vec2( -- 251
				____exports.pxX(v, x0 - 0.04, room), -- 251
				____exports.pxY(v, c.handleH - 0.44) -- 251
			), -- 251
			Vec2( -- 252
				____exports.pxX(v, x0 - 0.46, room), -- 252
				____exports.pxY(v, c.handleH - 0.36) -- 252
			) -- 252
		}, -- 252
		ghost and Color(120, 46, 42, 120) or CLOTH -- 253
	) -- 253
end -- 253
function drawFigure(draw, v, room, x, bodyH, color) -- 256
	local headR = bodyH * 0.075 -- 257
	local cx = ____exports.pxX(v, x, room) -- 258
	local foot = ____exports.pxY(v, 0.06) -- 259
	local shoulder = ____exports.pxY(v, bodyH * 0.86) -- 260
	local headC = ____exports.pxY(v, bodyH - headR) -- 261
	draw:drawRect( -- 263
		Rect( -- 263
			cx - 0.13 * v.scale, -- 263
			____exports.pxY(v, bodyH * 0.42), -- 263
			0.26 * v.scale, -- 263
			bodyH * 0.44 * v.scale -- 263
		), -- 263
		color -- 263
	) -- 263
	draw:drawSegment( -- 265
		Vec2( -- 265
			cx - 0.07 * v.scale, -- 265
			____exports.pxY(v, bodyH * 0.42) -- 265
		), -- 265
		Vec2(cx - 0.09 * v.scale, foot), -- 265
		2 * PX, -- 265
		color -- 265
	) -- 265
	draw:drawSegment( -- 266
		Vec2( -- 266
			cx + 0.07 * v.scale, -- 266
			____exports.pxY(v, bodyH * 0.42) -- 266
		), -- 266
		Vec2(cx + 0.09 * v.scale, foot), -- 266
		2 * PX, -- 266
		color -- 266
	) -- 266
	draw:drawSegment( -- 268
		Vec2(cx - 0.13 * v.scale, shoulder), -- 268
		Vec2( -- 268
			cx - 0.24 * v.scale, -- 268
			____exports.pxY(v, bodyH * 0.5) -- 268
		), -- 268
		2 * PX, -- 268
		color -- 268
	) -- 268
	draw:drawSegment( -- 269
		Vec2(cx + 0.13 * v.scale, shoulder), -- 269
		Vec2( -- 269
			cx + 0.24 * v.scale, -- 269
			____exports.pxY(v, bodyH * 0.5) -- 269
		), -- 269
		2 * PX, -- 269
		color -- 269
	) -- 269
	draw:drawCircle( -- 271
		Vec2(cx, headC), -- 271
		headR * v.scale, -- 271
		color -- 271
	) -- 271
end -- 271
PX = 2 -- 29
local PAD_X = 72 * PX -- 31
local PAD_TOP = 104 * PX -- 32
local PAD_BOTTOM = 108 * PX -- 33
local INK = Color(232, 232, 228, 255) -- 35
local INK_DIM = Color(150, 152, 150, 255) -- 36
local BG_FAR = Color(24, 26, 28, 255) -- 37
local BG_MID = Color(31, 34, 37, 255) -- 38
local BG_NEAR = Color(40, 43, 46, 255) -- 39
local GROUND = Color(96, 98, 96, 255) -- 40
local SOLID_FILL = Color(84, 86, 84, 255) -- 41
CART_FILL = Color(122, 78, 56, 255) -- 42
CLOTH = Color(178, 52, 46, 255) -- 43
local HOLE_FILL = Color(12, 13, 14, 255) -- 44
local DANGER = Color(150, 54, 48, 70) -- 45
local DANGER_LINE = Color(178, 78, 64, 220) -- 46
local PLATFORM = Color(112, 116, 108, 80) -- 47
local DIM_LINE = Color(126, 132, 140, 255) -- 48
local CHECK = Color(96, 186, 122, 255) -- 49
local STAND = Color(226, 186, 84, 255) -- 50
local EXIT = Color(96, 166, 226, 255) -- 51
local LAND = Color(206, 196, 122, 255) -- 52
function ____exports.computeView(room, w, h) -- 54
	local usableW = math.max(240 * PX, w - PAD_X * 2) -- 55
	local drawH = math.max(160 * PX, h - PAD_TOP - PAD_BOTTOM) -- 56
	local spanX = math.max(1, room.maxX - room.minX) -- 57
	local scale = math.min(usableW / spanX, drawH / room.height) -- 58
	local groundPx = PAD_BOTTOM + (drawH - room.height * scale) / 2 -- 60
	return {scale = scale, padX = PAD_X, groundPx = groundPx} -- 61
end -- 54
--- 尺寸线在地面下的像素位置：i=0 最靠地面。
local function dimPxY(v, i) -- 65
	return v.groundPx - 30 * PX - i * 24 * PX -- 66
end -- 65
--- 画背景、地面、台面、实体、门洞、板车、低洞、车辙、标记点。
function ____exports.renderWorld(draw, room, v, w, h) -- 82
	local ground = ____exports.pxY(v, 0) -- 83
	local top = ____exports.pxY(v, room.height) -- 84
	draw:drawRect( -- 87
		Rect(0, 0, w, h), -- 87
		BG_FAR -- 87
	) -- 87
	draw:drawRect( -- 88
		Rect(0, ground, w, top - ground), -- 88
		BG_MID -- 88
	) -- 88
	draw:drawRect( -- 89
		Rect(0, ground, w, (top - ground) * 0.34), -- 89
		BG_NEAR -- 89
	) -- 89
	draw:drawSegment( -- 92
		Vec2(v.padX - 24 * PX, ground), -- 92
		Vec2(w - v.padX + 24 * PX, ground), -- 92
		3 * PX, -- 92
		GROUND -- 92
	) -- 92
	do -- 92
		local i = 0 -- 95
		while i < #room.zones do -- 95
			local z = room.zones[i + 1] -- 96
			if z.tint == 2 then -- 96
				draw:drawRect( -- 98
					rectOf( -- 98
						v, -- 98
						room, -- 98
						z.x0, -- 98
						z.x1, -- 98
						0, -- 98
						0.16 -- 98
					), -- 98
					PLATFORM -- 98
				) -- 98
			end -- 98
			i = i + 1 -- 95
		end -- 95
	end -- 95
	do -- 95
		local i = 0 -- 103
		while i < #room.zones do -- 103
			local z = room.zones[i + 1] -- 104
			if z.tint == 1 then -- 104
				draw:drawRect( -- 106
					rectOf( -- 106
						v, -- 106
						room, -- 106
						z.x0, -- 106
						z.x1, -- 106
						0, -- 106
						z.h -- 106
					), -- 106
					DANGER -- 106
				) -- 106
				draw:drawSegment( -- 107
					Vec2( -- 108
						____exports.pxX(v, z.x0, room), -- 108
						____exports.pxY(v, z.h) -- 108
					), -- 108
					Vec2( -- 109
						____exports.pxX(v, z.x1, room), -- 109
						____exports.pxY(v, z.h) -- 109
					), -- 109
					1 * PX, -- 110
					DANGER_LINE -- 111
				) -- 111
			end -- 111
			i = i + 1 -- 103
		end -- 103
	end -- 103
	do -- 103
		local i = 0 -- 117
		while i < #room.solids do -- 117
			local s = room.solids[i + 1] -- 118
			draw:drawRect( -- 119
				rectOf( -- 119
					v, -- 119
					room, -- 119
					s.x, -- 119
					s.x + s.w, -- 119
					0, -- 119
					s.h -- 119
				), -- 119
				SOLID_FILL -- 119
			) -- 119
			draw:drawRect( -- 120
				rectOf( -- 120
					v, -- 120
					room, -- 120
					s.x, -- 120
					s.x + s.w, -- 120
					0, -- 120
					s.h -- 120
				), -- 120
				Color(0, 0, 0, 0), -- 120
				1.5 * PX, -- 120
				INK_DIM -- 120
			) -- 120
			i = i + 1 -- 117
		end -- 117
	end -- 117
	do -- 117
		local i = 0 -- 124
		while i < #room.gates do -- 124
			local g = room.gates[i + 1] -- 125
			local x0 = g.x - g.w / 2 -- 126
			local x1 = g.x + g.w / 2 -- 127
			draw:drawRect( -- 128
				rectOf( -- 128
					v, -- 128
					room, -- 128
					x0, -- 128
					x1, -- 128
					0, -- 128
					g.h -- 128
				), -- 128
				Color(18, 19, 20, 255) -- 128
			) -- 128
			draw:drawRect( -- 129
				rectOf( -- 129
					v, -- 129
					room, -- 129
					x0, -- 129
					x1, -- 129
					0, -- 129
					g.h -- 129
				), -- 129
				Color(0, 0, 0, 0), -- 129
				2 * PX, -- 129
				INK -- 129
			) -- 129
			draw:drawSegment( -- 130
				Vec2( -- 130
					____exports.pxX(v, x0, room), -- 130
					____exports.pxY(v, g.h) -- 130
				), -- 130
				Vec2( -- 130
					____exports.pxX(v, x1, room), -- 130
					____exports.pxY(v, g.h) -- 130
				), -- 130
				2.5 * PX, -- 130
				INK -- 130
			) -- 130
			draw:drawRect( -- 132
				rectOf( -- 132
					v, -- 132
					room, -- 132
					x0 + 0.12, -- 132
					x1 - 0.12, -- 132
					0, -- 132
					g.h - 0.12 -- 132
				), -- 132
				Color(70, 72, 74, 210) -- 132
			) -- 132
			draw:drawSegment( -- 133
				Vec2( -- 134
					____exports.pxX(v, x0 + 0.12, room), -- 134
					____exports.pxY(v, 0) -- 134
				), -- 134
				Vec2( -- 135
					____exports.pxX(v, x0 + 0.12, room), -- 135
					____exports.pxY(v, g.h - 0.12) -- 135
				), -- 135
				1 * PX, -- 136
				INK_DIM -- 137
			) -- 137
			draw:drawSegment( -- 139
				Vec2( -- 140
					____exports.pxX(v, x1 - 0.12, room), -- 140
					____exports.pxY(v, 0) -- 140
				), -- 140
				Vec2( -- 141
					____exports.pxX(v, x1 - 0.12, room), -- 141
					____exports.pxY(v, g.h - 0.12) -- 141
				), -- 141
				1 * PX, -- 142
				INK_DIM -- 143
			) -- 143
			i = i + 1 -- 124
		end -- 124
	end -- 124
	if room.hole.w > 0 then -- 124
		local hl = room.hole -- 149
		draw:drawRect( -- 150
			rectOf( -- 150
				v, -- 150
				room, -- 150
				hl.x, -- 150
				hl.x + hl.w, -- 150
				0, -- 150
				hl.h -- 150
			), -- 150
			HOLE_FILL -- 150
		) -- 150
		draw:drawRect( -- 151
			rectOf( -- 151
				v, -- 151
				room, -- 151
				hl.x, -- 151
				hl.x + hl.w, -- 151
				0, -- 151
				hl.h -- 151
			), -- 151
			Color(0, 0, 0, 0), -- 151
			2 * PX, -- 151
			INK -- 151
		) -- 151
		draw:drawArc( -- 152
			Vec2( -- 153
				____exports.pxX(v, hl.x + hl.w / 2, room), -- 153
				____exports.pxY(v, hl.h * 0.62) -- 153
			), -- 153
			hl.w / 2 * v.scale, -- 154
			0, -- 155
			180, -- 156
			2 * PX, -- 157
			INK -- 158
		) -- 158
	end -- 158
	local cart = room.cart -- 163
	local lo = math.min(cart.startX, cart.endX) -- 164
	local hi = math.max(cart.startX, cart.endX) -- 165
	if hi - lo > 0.05 then -- 165
		draw:drawSegment( -- 167
			Vec2( -- 167
				____exports.pxX(v, lo, room), -- 167
				____exports.pxY(v, 0.04) -- 167
			), -- 167
			Vec2( -- 167
				____exports.pxX(v, hi, room), -- 167
				____exports.pxY(v, 0.04) -- 167
			), -- 167
			1 * PX, -- 167
			INK_DIM -- 167
		) -- 167
		draw:drawSegment( -- 168
			Vec2( -- 168
				____exports.pxX(v, lo, room), -- 168
				____exports.pxY(v, 0.12) -- 168
			), -- 168
			Vec2( -- 168
				____exports.pxX(v, hi, room), -- 168
				____exports.pxY(v, 0.12) -- 168
			), -- 168
			1 * PX, -- 168
			INK_DIM -- 168
		) -- 168
		draw:drawSegment( -- 169
			Vec2( -- 169
				____exports.pxX(v, lo, room), -- 169
				____exports.pxY(v, 0.02) -- 169
			), -- 169
			Vec2( -- 169
				____exports.pxX(v, lo, room), -- 169
				____exports.pxY(v, 0.14) -- 169
			), -- 169
			1 * PX, -- 169
			INK_DIM -- 169
		) -- 169
		draw:drawSegment( -- 170
			Vec2( -- 170
				____exports.pxX(v, hi, room), -- 170
				____exports.pxY(v, 0.02) -- 170
			), -- 170
			Vec2( -- 170
				____exports.pxX(v, hi, room), -- 170
				____exports.pxY(v, 0.14) -- 170
			), -- 170
			1 * PX, -- 170
			INK_DIM -- 170
		) -- 170
	end -- 170
	drawCart( -- 174
		draw, -- 174
		room, -- 174
		v, -- 174
		cart.startX, -- 174
		true -- 174
	) -- 174
	drawCart( -- 175
		draw, -- 175
		room, -- 175
		v, -- 175
		cart.endX, -- 175
		false -- 175
	) -- 175
	if math.abs(cart.startX - cart.endX) > 0.05 then -- 175
		local wx = ____exports.pxX(v, cart.endX, room) -- 179
		draw:drawSegment( -- 180
			Vec2( -- 180
				wx - 0.34 * v.scale, -- 180
				____exports.pxY(v, -0.02) -- 180
			), -- 180
			Vec2( -- 180
				wx + 0.34 * v.scale, -- 180
				____exports.pxY(v, -0.02) -- 180
			), -- 180
			2 * PX, -- 180
			INK -- 180
		) -- 180
		draw:drawSegment( -- 181
			Vec2( -- 181
				wx - 0.26 * v.scale, -- 181
				____exports.pxY(v, -0.1) -- 181
			), -- 181
			Vec2( -- 181
				wx - 0.26 * v.scale, -- 181
				____exports.pxY(v, 0.02) -- 181
			), -- 181
			1 * PX, -- 181
			INK -- 181
		) -- 181
		draw:drawSegment( -- 182
			Vec2( -- 182
				wx + 0.26 * v.scale, -- 182
				____exports.pxY(v, -0.1) -- 182
			), -- 182
			Vec2( -- 182
				wx + 0.26 * v.scale, -- 182
				____exports.pxY(v, 0.02) -- 182
			), -- 182
			1 * PX, -- 182
			INK -- 182
		) -- 182
	end -- 182
	do -- 182
		local i = 0 -- 186
		while i < #room.marks do -- 186
			local m = room.marks[i + 1] -- 187
			local mx = ____exports.pxX(v, m.x, room) -- 188
			local my = ____exports.pxY(v, 1.9) -- 189
			local c = m.kind == 0 and CHECK or (m.kind == 1 and STAND or (m.kind == 2 and EXIT or LAND)) -- 190
			draw:drawSegment( -- 191
				Vec2( -- 191
					mx, -- 191
					____exports.pxY(v, 0.05) -- 191
				), -- 191
				Vec2(mx, my - 12 * PX), -- 191
				1 * PX, -- 191
				c -- 191
			) -- 191
			draw:drawDot( -- 192
				Vec2(mx, my), -- 192
				4.5 * PX, -- 192
				c -- 192
			) -- 192
			draw:drawRing( -- 193
				Vec2(mx, my), -- 193
				8 * PX, -- 193
				10 * PX, -- 193
				Color(0, 0, 0, 0), -- 193
				1 * PX, -- 193
				c -- 193
			) -- 193
			i = i + 1 -- 186
		end -- 186
	end -- 186
	do -- 186
		local i = 0 -- 197
		while i < #room.spawns do -- 197
			local s = room.spawns[i + 1] -- 198
			local bodyH = i == 0 and 1.18 or 1.8 -- 199
			drawFigure( -- 200
				draw, -- 200
				v, -- 200
				room, -- 200
				s.x, -- 200
				bodyH, -- 200
				i == 0 and Color(198, 176, 132, 200) or Color(168, 180, 198, 200) -- 200
			) -- 200
			i = i + 1 -- 197
		end -- 197
	end -- 197
	do -- 197
		local i = 0 -- 204
		while i < #room.dims do -- 204
			local d = room.dims[i + 1] -- 205
			local y = dimPxY(v, i) -- 206
			local xa = ____exports.pxX( -- 207
				v, -- 207
				math.min(d.x0, d.x1), -- 207
				room -- 207
			) -- 207
			local xb = ____exports.pxX( -- 208
				v, -- 208
				math.max(d.x0, d.x1), -- 208
				room -- 208
			) -- 208
			draw:drawSegment( -- 209
				Vec2(xa, y), -- 209
				Vec2(xb, y), -- 209
				1 * PX, -- 209
				DIM_LINE -- 209
			) -- 209
			draw:drawSegment( -- 210
				Vec2(xa, y - 6 * PX), -- 210
				Vec2(xa, y + 6 * PX), -- 210
				1 * PX, -- 210
				DIM_LINE -- 210
			) -- 210
			draw:drawSegment( -- 211
				Vec2(xb, y - 6 * PX), -- 211
				Vec2(xb, y + 6 * PX), -- 211
				1 * PX, -- 211
				DIM_LINE -- 211
			) -- 211
			i = i + 1 -- 204
		end -- 204
	end -- 204
end -- 82
--- 收集当前房间的文字标签（屏幕坐标，root 左下原点）。
function ____exports.collectLabels(room, v, w) -- 275
	local out = {} -- 276
	do -- 276
		local i = 0 -- 278
		while i < #room.spawns do -- 278
			local s = room.spawns[i + 1] -- 279
			out[#out + 1] = { -- 280
				x = ____exports.pxX(v, s.x, room), -- 280
				y = ____exports.pxY(v, 1.94), -- 280
				text = s.label, -- 280
				ax = 0.5, -- 280
				ay = 0, -- 280
				color = INK, -- 280
				size = 12 * PX -- 280
			} -- 280
			i = i + 1 -- 278
		end -- 278
	end -- 278
	do -- 278
		local i = 0 -- 282
		while i < #room.solids do -- 282
			local s = room.solids[i + 1] -- 283
			out[#out + 1] = { -- 284
				x = ____exports.pxX(v, s.x + s.w / 2, room), -- 285
				y = ____exports.pxY(v, s.h) + 6 * PX, -- 286
				text = s.label, -- 287
				ax = 0.5, -- 288
				ay = 0, -- 289
				color = INK, -- 290
				size = 12 * PX -- 291
			} -- 291
			i = i + 1 -- 282
		end -- 282
	end -- 282
	do -- 282
		local i = 0 -- 294
		while i < #room.gates do -- 294
			local g = room.gates[i + 1] -- 295
			out[#out + 1] = { -- 296
				x = ____exports.pxX(v, g.x, room), -- 296
				y = ____exports.pxY(v, g.h) + 8 * PX, -- 296
				text = g.label, -- 296
				ax = 0.5, -- 296
				ay = 0, -- 296
				color = INK, -- 296
				size = 12 * PX -- 296
			} -- 296
			i = i + 1 -- 294
		end -- 294
	end -- 294
	do -- 294
		local i = 0 -- 298
		while i < #room.zones do -- 298
			do -- 298
				local z = room.zones[i + 1] -- 299
				if #z.label == 0 then -- 299
					goto __continue37 -- 301
				end -- 301
				if z.tint == 1 then -- 301
					out[#out + 1] = { -- 304
						x = ____exports.pxX(v, (z.x0 + z.x1) / 2, room), -- 305
						y = ____exports.pxY(v, z.h) + 6 * PX, -- 306
						text = z.label, -- 307
						ax = 0.5, -- 308
						ay = 0, -- 309
						color = DANGER_LINE, -- 310
						size = 12 * PX -- 311
					} -- 311
				else -- 311
					out[#out + 1] = { -- 314
						x = ____exports.pxX(v, z.x1, room), -- 315
						y = ____exports.pxY(v, 0.16) + 4 * PX, -- 316
						text = z.label, -- 317
						ax = 1, -- 318
						ay = 0, -- 319
						color = INK_DIM, -- 320
						size = 11 * PX -- 321
					} -- 321
				end -- 321
			end -- 321
			::__continue37:: -- 321
			i = i + 1 -- 298
		end -- 298
	end -- 298
	if room.hole.w > 0 then -- 298
		out[#out + 1] = { -- 326
			x = ____exports.pxX(v, room.hole.x + room.hole.w / 2, room), -- 327
			y = ____exports.pxY(v, room.hole.h) + 8 * PX, -- 328
			text = room.hole.label, -- 329
			ax = 0.5, -- 330
			ay = 0, -- 331
			color = INK, -- 332
			size = 12 * PX -- 333
		} -- 333
	end -- 333
	do -- 333
		local i = 0 -- 336
		while i < #room.marks do -- 336
			local m = room.marks[i + 1] -- 337
			local c = m.kind == 0 and CHECK or (m.kind == 1 and STAND or (m.kind == 2 and EXIT or LAND)) -- 338
			out[#out + 1] = { -- 339
				x = ____exports.pxX(v, m.x, room), -- 339
				y = ____exports.pxY(v, 1.9) + 10 * PX, -- 339
				text = m.label, -- 339
				ax = 0.5, -- 339
				ay = 0, -- 339
				color = c, -- 339
				size = 11 * PX -- 339
			} -- 339
			i = i + 1 -- 336
		end -- 336
	end -- 336
	do -- 336
		local i = 0 -- 341
		while i < #room.dims do -- 341
			local d = room.dims[i + 1] -- 342
			local mid = (____exports.pxX(v, d.x0, room) + ____exports.pxX(v, d.x1, room)) / 2 -- 343
			out[#out + 1] = { -- 344
				x = mid, -- 344
				y = dimPxY(v, i) - 3 * PX, -- 344
				text = d.text, -- 344
				ax = 0.5, -- 344
				ay = 0, -- 344
				color = DIM_LINE, -- 344
				size = 11 * PX -- 344
			} -- 344
			i = i + 1 -- 341
		end -- 341
	end -- 341
	out[#out + 1] = { -- 347
		x = ____exports.pxX(v, room.cart.startX, room), -- 348
		y = ____exports.pxY(v, room.cart.bodyH) + 46 * PX, -- 349
		text = "车 · 起点", -- 350
		ax = 0.5, -- 351
		ay = 0, -- 352
		color = INK_DIM, -- 353
		size = 11 * PX -- 354
	} -- 354
	out[#out + 1] = { -- 356
		x = ____exports.pxX(v, room.cart.endX, room), -- 357
		y = ____exports.pxY(v, room.cart.bodyH) + 8 * PX, -- 358
		text = "车 · 停靠位", -- 359
		ax = 0.5, -- 360
		ay = 0, -- 361
		color = INK_DIM, -- 362
		size = 11 * PX -- 363
	} -- 363
	return out -- 366
end -- 275
--- 1 米比例尺：画在灰盒顶部上方，用于直接读灰盒里的高度。
function ____exports.drawScaleRuler(draw, x, yBase, unitPx) -- 370
	local yTop = yBase + unitPx -- 371
	draw:drawSegment( -- 372
		Vec2(x, yBase), -- 372
		Vec2(x, yTop), -- 372
		1.5 * PX, -- 372
		INK_DIM -- 372
	) -- 372
	draw:drawSegment( -- 373
		Vec2(x - 8 * PX, yBase), -- 373
		Vec2(x + 8 * PX, yBase), -- 373
		1.5 * PX, -- 373
		INK_DIM -- 373
	) -- 373
	draw:drawSegment( -- 374
		Vec2(x - 8 * PX, yTop), -- 374
		Vec2(x + 8 * PX, yTop), -- 374
		1.5 * PX, -- 374
		INK_DIM -- 374
	) -- 374
	draw:drawSegment( -- 375
		Vec2(x - 5 * PX, yBase + unitPx / 2), -- 375
		Vec2(x + 5 * PX, yBase + unitPx / 2), -- 375
		1 * PX, -- 375
		INK_DIM -- 375
	) -- 375
end -- 370
return ____exports -- 370