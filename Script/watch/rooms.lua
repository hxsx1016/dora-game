-- [ts]: rooms.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
--- 检查站：周戍把车从 640 推到 768 落入 dock，再和小满一起走到出口。
____exports.CHECKPOINT_ROOM = { -- 137
	key = "checkpoint", -- 138
	name = "检查站 · 候检区 640 + 原段 1000", -- 139
	caption = "先翻过队栏进候检区，再带小满走到柜台与安全点；末段按住 E + D 推车 128 单位入窝", -- 140
	originX = 640, -- 142
	minX = -640, -- 143
	maxX = 1000, -- 144
	height = 210, -- 145
	floors = {{y = 0, x0 = -640, x1 = 1000}}, -- 146
	solids = {{ -- 147
		x = -430, -- 149
		w = 180, -- 149
		h = 28, -- 149
		y = 0, -- 149
		label = "队栏 -430–-250 · 高 28" -- 149
	}, { -- 149
		x = 240, -- 151
		w = 100, -- 151
		h = 44, -- 151
		y = 0, -- 151
		label = "柜台 240–340 · 高 44" -- 151
	}, { -- 151
		x = 950, -- 152
		w = 50, -- 152
		h = 150, -- 152
		y = 0, -- 152
		label = "城门内侧" -- 152
	}}, -- 152
	zones = {{ -- 154
		x0 = 380, -- 154
		x1 = 560, -- 154
		y = 0, -- 154
		h = 120, -- 154
		tint = 1, -- 154
		label = "危险段 380–560" -- 154
	}}, -- 154
	arch = { -- 155
		x0 = 0, -- 155
		x1 = 0, -- 155
		y = 0, -- 155
		h = 0, -- 155
		label = "" -- 155
	}, -- 155
	stairs = {}, -- 156
	cart = { -- 157
		startX = 640, -- 158
		endX = 768, -- 159
		baseY = 0, -- 160
		bodyW = 48, -- 161
		bodyH = 26, -- 162
		wheelR = 12, -- 163
		handleOffset = -40, -- 164
		clothSide = -1 -- 165
	}, -- 165
	spawns = {{x = -600, y = 0, h = 64, label = "小满 -600（世界 40）"}, {x = -560, y = 0, h = 88, label = "周戍 -560（世界 80）"}}, -- 167
	marks = {{x = 264, y = 0, kind = 1, label = "安全锚 264"}, {x = 768, y = 0, kind = 1, label = "dock 768"}, {x = 860, y = 0, kind = 2, label = "双人出口 792–928"}}, -- 171
	dims = {{x0 = 240, x1 = 340, text = "柜台 100"}, {x0 = 640, x1 = 768, text = "推车 128 · 左柄 E+D"}, {x0 = 792, x1 = 928, text = "出口 136"}} -- 176
} -- 176
--- 城外：同一剖面里同时看上层手柄与下层拱口，这是 D1 要交的那张图。
____exports.OUTSIDE_ROOM = { -- 184
	key = "outside", -- 185
	name = "城外 · 台面 y=96 / 墙根 1240", -- 186
	caption = "从右柄按住 E+D 朝空窝拉 128 单位，轮子落窝后沿台面回左端跳下，蹲过 44 高的拱；洞后墙根小路走到底可看见塔灯", -- 187
	originX = 0, -- 189
	minX = 0, -- 190
	maxX = 1240, -- 191
	height = 230, -- 192
	floors = {{y = 0, x0 = 0, x1 = 1240}, {y = 96, x0 = 128, x1 = 512}, {y = 64, x0 = 820, x1 = 940}}, -- 193
	solids = {{ -- 198
		x = 512, -- 200
		w = 88, -- 200
		h = 134, -- 200
		y = 96, -- 200
		label = "台面右端城墙 · 下层可通" -- 200
	}, { -- 200
		x = 0, -- 201
		w = 40, -- 201
		h = 96, -- 201
		y = 0, -- 201
		label = "街口" -- 201
	}, { -- 201
		x = 1200, -- 202
		w = 40, -- 202
		h = 140, -- 202
		y = 0, -- 202
		label = "墙根尽头" -- 202
	}}, -- 202
	zones = {}, -- 204
	arch = { -- 205
		x0 = 280, -- 205
		x1 = 360, -- 205
		y = 0, -- 205
		h = 44, -- 205
		label = "拱 280–360 · 净高 44" -- 205
	}, -- 205
	stairs = {{ -- 206
		x0 = 40, -- 207
		x1 = 128, -- 207
		y0 = 0, -- 207
		y1 = 96, -- 207
		steps = 2, -- 207
		label = "石阶 0 / 48 / 96" -- 207
	}, { -- 207
		x0 = 700, -- 208
		x1 = 820, -- 208
		y0 = 0, -- 208
		y1 = 64, -- 208
		steps = 3, -- 208
		label = "墙根石阶 0 / 16 / 32 / 48 / 64" -- 208
	}}, -- 208
	cart = { -- 210
		startX = 304, -- 211
		endX = 432, -- 212
		baseY = 96, -- 213
		bodyW = 48, -- 214
		bodyH = 26, -- 215
		wheelR = 12, -- 216
		handleOffset = 40, -- 217
		clothSide = -1 -- 218
	}, -- 218
	spawns = {{x = 160, y = 96, h = 64, label = "小满 160"}}, -- 220
	marks = { -- 221
		{x = 432, y = 96, kind = 1, label = "空窝 432"}, -- 222
		{x = 380, y = 0, kind = 0, label = "洞后检查点 380"}, -- 223
		{x = 520, y = 96, kind = 3, label = "石阶光 · 回首红布"}, -- 224
		{x = 820, y = 64, kind = 3, label = "墙根石阶顶 820"}, -- 225
		{x = 1120, y = 64, kind = 6, label = "塔灯 1120"} -- 226
	}, -- 226
	dims = {{x0 = 304, x1 = 432, text = "拉车 128 · 右柄 E+D"}, {x0 = 128, x1 = 512, text = "台面 384"}, {x0 = 280, x1 = 360, text = "拱 80"}, {x0 = 600, x1 = 1240, text = "墙根 640"}} -- 228
} -- 228
--- 村口：瓶架 112、观察位 160、桌下 304–416（净高 44）、第一院通行线 440、
-- 软土 272（D5 完整）、砖地 608、拾荒者巡逻 464–512。
-- 小满脚底中心 290 起必须蹲，超过 430 才站起；160→440 约 2.63 秒。
____exports.VILLAGE_ROOM = { -- 241
	key = "village", -- 242
	originX = 0, -- 243
	name = "村口 · 架、桌、砖地", -- 244
	caption = "点 E 拾瓶，按住 F 瞄，松手投；砖地一响，拾荒者转身，趁他走开钻过桌下", -- 245
	minX = 0, -- 246
	maxX = 720, -- 247
	height = 200, -- 248
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 249
	solids = {{ -- 250
		x = 96, -- 251
		w = 32, -- 251
		h = 64, -- 251
		y = 0, -- 251
		label = "瓶架" -- 251
	}, { -- 251
		x = 672, -- 253
		w = 48, -- 253
		h = 96, -- 253
		y = 0, -- 253
		label = "院墙" -- 253
	}}, -- 253
	zones = {{ -- 255
		x0 = 256, -- 256
		x1 = 288, -- 256
		y = 0, -- 256
		h = 6, -- 256
		tint = 2, -- 256
		label = "软土 272" -- 256
	}, { -- 256
		x0 = 440, -- 257
		x1 = 448, -- 257
		y = 0, -- 257
		h = 120, -- 257
		tint = 4, -- 257
		label = "通行线 440" -- 257
	}, { -- 257
		x0 = 592, -- 258
		x1 = 624, -- 258
		y = 0, -- 258
		h = 6, -- 258
		tint = 3, -- 258
		label = "砖地 608" -- 258
	}}, -- 258
	arch = { -- 260
		x0 = 304, -- 260
		x1 = 416, -- 260
		y = 0, -- 260
		h = 44, -- 260
		label = "桌下 304–416 · 净高 44" -- 260
	}, -- 260
	stairs = {}, -- 261
	cart = { -- 262
		startX = 0, -- 262
		endX = 0, -- 262
		baseY = 0, -- 262
		bodyW = 0, -- 262
		bodyH = 0, -- 262
		wheelR = 0, -- 262
		handleOffset = 0, -- 262
		clothSide = 1 -- 262
	}, -- 262
	spawns = {{x = 160, y = 0, h = 64, label = "小满 160"}}, -- 263
	marks = {{x = 608, y = 0, kind = 5, label = "砖地落点 608"}, {x = 440, y = 0, kind = 4, label = "通行线 440"}}, -- 264
	dims = {{x0 = 96, x1 = 128, text = "瓶架"}, {x0 = 304, x1 = 416, text = "桌下 112"}, {x0 = 464, x1 = 512, text = "巡逻 48"}}, -- 268
	scavenger = { -- 273
		x0 = 464, -- 274
		x1 = 512, -- 275
		y = 0, -- 276
		h = 56, -- 277
		patrolSpeed = 40, -- 278
		approachSpeed = 64, -- 279
		hearTicks = 18, -- 280
		stallTicks = 120, -- 281
		range = 480 -- 282
	}, -- 282
	bottle = {x = 112, y = 48}, -- 284
	brickX = 608, -- 285
	softX = 272, -- 286
	passLine = 440 -- 287
} -- 287
____exports.ROOMS = {____exports.CHECKPOINT_ROOM, ____exports.OUTSIDE_ROOM, ____exports.VILLAGE_ROOM} -- 290
--- 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
-- 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
function ____exports.withOrigin(room) -- 296
	local ox = room.originX -- 297
	if ox == 0 then -- 297
		return room -- 299
	end -- 299
	local function shift(x) -- 301
		return x + ox -- 301
	end -- 301
	local ____room_key_5 = room.key -- 303
	local ____room_name_6 = room.name -- 304
	local ____room_caption_7 = room.caption -- 305
	local ____shift_result_8 = shift(room.minX) -- 307
	local ____shift_result_9 = shift(room.maxX) -- 308
	local ____room_height_10 = room.height -- 309
	local ____TS__ArrayMap_result_11 = __TS__ArrayMap( -- 310
		room.floors, -- 310
		function(____, f) return { -- 310
			y = f.y, -- 310
			x0 = shift(f.x0), -- 310
			x1 = shift(f.x1) -- 310
		} end -- 310
	) -- 310
	local ____TS__ArrayMap_result_12 = __TS__ArrayMap( -- 311
		room.solids, -- 311
		function(____, s) return { -- 311
			x = shift(s.x), -- 311
			w = s.w, -- 311
			h = s.h, -- 311
			y = s.y, -- 311
			label = s.label -- 311
		} end -- 311
	) -- 311
	local ____TS__ArrayMap_result_13 = __TS__ArrayMap( -- 312
		room.zones, -- 312
		function(____, z) return { -- 312
			x0 = shift(z.x0), -- 312
			x1 = shift(z.x1), -- 312
			y = z.y, -- 312
			h = z.h, -- 312
			tint = z.tint, -- 312
			label = z.label -- 312
		} end -- 312
	) -- 312
	local ____temp_14 = { -- 313
		x0 = shift(room.arch.x0), -- 313
		x1 = shift(room.arch.x1), -- 313
		y = room.arch.y, -- 313
		h = room.arch.h, -- 313
		label = room.arch.label -- 313
	} -- 313
	local ____TS__ArrayMap_result_15 = __TS__ArrayMap( -- 314
		room.stairs, -- 314
		function(____, s) return { -- 314
			x0 = shift(s.x0), -- 314
			x1 = shift(s.x1), -- 314
			y0 = s.y0, -- 314
			y1 = s.y1, -- 314
			steps = s.steps, -- 314
			label = s.label -- 314
		} end -- 314
	) -- 314
	local ____temp_16 = { -- 315
		startX = shift(room.cart.startX), -- 316
		endX = shift(room.cart.endX), -- 317
		baseY = room.cart.baseY, -- 318
		bodyW = room.cart.bodyW, -- 319
		bodyH = room.cart.bodyH, -- 320
		wheelR = room.cart.wheelR, -- 321
		handleOffset = room.cart.handleOffset, -- 322
		clothSide = room.cart.clothSide -- 323
	} -- 323
	local ____TS__ArrayMap_result_17 = __TS__ArrayMap( -- 325
		room.spawns, -- 325
		function(____, s) return { -- 325
			x = shift(s.x), -- 325
			y = s.y, -- 325
			h = s.h, -- 325
			label = s.label -- 325
		} end -- 325
	) -- 325
	local ____TS__ArrayMap_result_18 = __TS__ArrayMap( -- 326
		room.marks, -- 326
		function(____, m) return { -- 326
			x = shift(m.x), -- 326
			y = m.y, -- 326
			kind = m.kind, -- 326
			label = m.label -- 326
		} end -- 326
	) -- 326
	local ____TS__ArrayMap_result_19 = __TS__ArrayMap( -- 327
		room.dims, -- 327
		function(____, d) return { -- 327
			x0 = shift(d.x0), -- 327
			x1 = shift(d.x1), -- 327
			text = d.text -- 327
		} end -- 327
	) -- 327
	local ____temp_0 -- 328
	if room.scavenger == nil then -- 328
		____temp_0 = nil -- 328
	else -- 328
		____temp_0 = { -- 328
			x0 = shift(room.scavenger.x0), -- 329
			x1 = shift(room.scavenger.x1), -- 329
			y = room.scavenger.y, -- 329
			h = room.scavenger.h, -- 329
			patrolSpeed = room.scavenger.patrolSpeed, -- 330
			approachSpeed = room.scavenger.approachSpeed, -- 330
			hearTicks = room.scavenger.hearTicks, -- 331
			stallTicks = room.scavenger.stallTicks, -- 331
			range = room.scavenger.range -- 331
		} -- 331
	end -- 331
	local ____temp_1 -- 333
	if room.bottle == nil then -- 333
		____temp_1 = nil -- 333
	else -- 333
		____temp_1 = { -- 333
			x = shift(room.bottle.x), -- 333
			y = room.bottle.y -- 333
		} -- 333
	end -- 333
	local ____temp_2 -- 334
	if room.brickX == nil then -- 334
		____temp_2 = nil -- 334
	else -- 334
		____temp_2 = shift(room.brickX) -- 334
	end -- 334
	local ____temp_3 -- 335
	if room.softX == nil then -- 335
		____temp_3 = nil -- 335
	else -- 335
		____temp_3 = shift(room.softX) -- 335
	end -- 335
	local ____temp_4 -- 336
	if room.passLine == nil then -- 336
		____temp_4 = nil -- 336
	else -- 336
		____temp_4 = shift(room.passLine) -- 336
	end -- 336
	return { -- 302
		key = ____room_key_5, -- 303
		name = ____room_name_6, -- 304
		caption = ____room_caption_7, -- 305
		originX = 0, -- 306
		minX = ____shift_result_8, -- 307
		maxX = ____shift_result_9, -- 308
		height = ____room_height_10, -- 309
		floors = ____TS__ArrayMap_result_11, -- 310
		solids = ____TS__ArrayMap_result_12, -- 311
		zones = ____TS__ArrayMap_result_13, -- 312
		arch = ____temp_14, -- 313
		stairs = ____TS__ArrayMap_result_15, -- 314
		cart = ____temp_16, -- 315
		spawns = ____TS__ArrayMap_result_17, -- 325
		marks = ____TS__ArrayMap_result_18, -- 326
		dims = ____TS__ArrayMap_result_19, -- 327
		scavenger = ____temp_0, -- 328
		bottle = ____temp_1, -- 333
		brickX = ____temp_2, -- 334
		softX = ____temp_3, -- 335
		passLine = ____temp_4 -- 336
	} -- 336
end -- 296
return ____exports -- 296