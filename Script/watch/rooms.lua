-- [ts]: rooms.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
--- 检查站：周戍把车从 640 推到 768 落入 dock，再和小满一起走到出口。
____exports.CHECKPOINT_ROOM = { -- 163
	key = "checkpoint", -- 164
	name = "检查站 · 候检区 640 + 原段 1000", -- 165
	caption = "先翻过队栏进候检区，再带小满走到柜台与安全点；末段按住 E + D 推车 128 单位入窝", -- 166
	originX = 640, -- 168
	minX = -640, -- 169
	maxX = 1000, -- 170
	height = 210, -- 171
	floors = {{y = 0, x0 = -640, x1 = 1000}}, -- 172
	solids = {{ -- 173
		x = -430, -- 175
		w = 180, -- 175
		h = 28, -- 175
		y = 0, -- 175
		label = "队栏 -430–-250 · 高 28" -- 175
	}, { -- 175
		x = 240, -- 177
		w = 100, -- 177
		h = 44, -- 177
		y = 0, -- 177
		label = "柜台 240–340 · 高 44" -- 177
	}, { -- 177
		x = 950, -- 178
		w = 50, -- 178
		h = 150, -- 178
		y = 0, -- 178
		label = "城门内侧" -- 178
	}}, -- 178
	zones = {{ -- 180
		x0 = 380, -- 180
		x1 = 560, -- 180
		y = 0, -- 180
		h = 120, -- 180
		tint = 1, -- 180
		label = "危险段 380–560" -- 180
	}}, -- 180
	arch = { -- 181
		x0 = 0, -- 181
		x1 = 0, -- 181
		y = 0, -- 181
		h = 0, -- 181
		label = "" -- 181
	}, -- 181
	stairs = {}, -- 182
	cart = { -- 183
		startX = 640, -- 184
		endX = 768, -- 185
		baseY = 0, -- 186
		bodyW = 48, -- 187
		bodyH = 26, -- 188
		wheelR = 12, -- 189
		handleOffset = -40, -- 190
		clothSide = -1 -- 191
	}, -- 191
	spawns = {{x = -600, y = 0, h = 64, label = "小满 -600（世界 40）"}, {x = -560, y = 0, h = 88, label = "周戍 -560（世界 80）"}}, -- 193
	marks = {{x = 264, y = 0, kind = 1, label = "安全锚 264"}, {x = 768, y = 0, kind = 1, label = "dock 768"}, {x = 860, y = 0, kind = 2, label = "双人出口 792–928"}}, -- 197
	dims = {{x0 = 240, x1 = 340, text = "柜台 100"}, {x0 = 640, x1 = 768, text = "推车 128 · 左柄 E+D"}, {x0 = 792, x1 = 928, text = "出口 136"}} -- 202
} -- 202
--- 城外：同一剖面里同时看上层手柄与下层拱口，这是 D1 要交的那张图。
____exports.OUTSIDE_ROOM = { -- 210
	key = "outside", -- 211
	name = "城外 · 台面 y=96 / 墙根 1240", -- 212
	caption = "从右柄按住 E+D 朝空窝拉 128 单位，轮子落窝后沿台面回左端跳下，蹲过 44 高的拱；洞后墙根小路走到底可看见塔灯", -- 213
	originX = 0, -- 215
	minX = 0, -- 216
	maxX = 1240, -- 217
	height = 230, -- 218
	floors = {{y = 0, x0 = 0, x1 = 1240}, {y = 96, x0 = 128, x1 = 512}, {y = 64, x0 = 820, x1 = 940}}, -- 219
	solids = {{ -- 224
		x = 512, -- 226
		w = 88, -- 226
		h = 134, -- 226
		y = 96, -- 226
		label = "台面右端城墙 · 下层可通" -- 226
	}, { -- 226
		x = 0, -- 227
		w = 40, -- 227
		h = 96, -- 227
		y = 0, -- 227
		label = "街口" -- 227
	}, { -- 227
		x = 1200, -- 228
		w = 40, -- 228
		h = 140, -- 228
		y = 0, -- 228
		label = "墙根尽头" -- 228
	}}, -- 228
	zones = {}, -- 230
	arch = { -- 231
		x0 = 280, -- 231
		x1 = 360, -- 231
		y = 0, -- 231
		h = 44, -- 231
		label = "拱 280–360 · 净高 44" -- 231
	}, -- 231
	stairs = {{ -- 232
		x0 = 40, -- 233
		x1 = 128, -- 233
		y0 = 0, -- 233
		y1 = 96, -- 233
		steps = 2, -- 233
		label = "石阶 0 / 48 / 96" -- 233
	}, { -- 233
		x0 = 700, -- 234
		x1 = 820, -- 234
		y0 = 0, -- 234
		y1 = 64, -- 234
		steps = 3, -- 234
		label = "墙根石阶 0 / 16 / 32 / 48 / 64" -- 234
	}}, -- 234
	cart = { -- 236
		startX = 304, -- 237
		endX = 432, -- 238
		baseY = 96, -- 239
		bodyW = 48, -- 240
		bodyH = 26, -- 241
		wheelR = 12, -- 242
		handleOffset = 40, -- 243
		clothSide = -1 -- 244
	}, -- 244
	spawns = {{x = 160, y = 96, h = 64, label = "小满 160"}}, -- 246
	marks = { -- 247
		{x = 432, y = 96, kind = 1, label = "空窝 432"}, -- 248
		{x = 380, y = 0, kind = 0, label = "洞后检查点 380"}, -- 249
		{x = 520, y = 96, kind = 3, label = "石阶光 · 回首红布"}, -- 250
		{x = 820, y = 64, kind = 3, label = "墙根石阶顶 820"}, -- 251
		{x = 1120, y = 64, kind = 6, label = "塔灯 1120"} -- 252
	}, -- 252
	dims = {{x0 = 304, x1 = 432, text = "拉车 128 · 右柄 E+D"}, {x0 = 128, x1 = 512, text = "台面 384"}, {x0 = 280, x1 = 360, text = "拱 80"}, {x0 = 600, x1 = 1240, text = "墙根 640"}} -- 254
} -- 254
--- 村口：瓶架 112、观察位 160、桌下 304–416（净高 44）、第一院通行线 440、
-- 软土 272（D5 完整）、砖地 608、拾荒者巡逻 464–512。
-- 小满脚底中心 290 起必须蹲，超过 430 才站起；160→440 约 2.63 秒。
____exports.VILLAGE_ROOM = { -- 267
	key = "village", -- 268
	originX = 0, -- 269
	name = "村口 · 架、桌、砖地", -- 270
	caption = "点 E 拾瓶，按住 F 瞄，松手投；砖地一响，拾荒者转身，趁他走开钻过桌下", -- 271
	minX = 0, -- 272
	maxX = 720, -- 273
	height = 200, -- 274
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 275
	solids = {{ -- 276
		x = 96, -- 277
		w = 32, -- 277
		h = 64, -- 277
		y = 0, -- 277
		label = "瓶架" -- 277
	}, { -- 277
		x = 672, -- 279
		w = 48, -- 279
		h = 96, -- 279
		y = 0, -- 279
		label = "院墙" -- 279
	}}, -- 279
	zones = {{ -- 281
		x0 = 256, -- 282
		x1 = 288, -- 282
		y = 0, -- 282
		h = 6, -- 282
		tint = 2, -- 282
		label = "软土 272" -- 282
	}, { -- 282
		x0 = 440, -- 283
		x1 = 448, -- 283
		y = 0, -- 283
		h = 120, -- 283
		tint = 4, -- 283
		label = "通行线 440" -- 283
	}, { -- 283
		x0 = 592, -- 284
		x1 = 624, -- 284
		y = 0, -- 284
		h = 6, -- 284
		tint = 3, -- 284
		label = "砖地 608" -- 284
	}}, -- 284
	arch = { -- 286
		x0 = 304, -- 286
		x1 = 416, -- 286
		y = 0, -- 286
		h = 44, -- 286
		label = "桌下 304–416 · 净高 44" -- 286
	}, -- 286
	stairs = {}, -- 287
	cart = { -- 288
		startX = 0, -- 288
		endX = 0, -- 288
		baseY = 0, -- 288
		bodyW = 0, -- 288
		bodyH = 0, -- 288
		wheelR = 0, -- 288
		handleOffset = 0, -- 288
		clothSide = 1 -- 288
	}, -- 288
	spawns = {{x = 160, y = 0, h = 64, label = "小满 160"}}, -- 289
	marks = {{x = 608, y = 0, kind = 5, label = "砖地落点 608"}, {x = 440, y = 0, kind = 4, label = "通行线 440"}}, -- 290
	dims = {{x0 = 96, x1 = 128, text = "瓶架"}, {x0 = 304, x1 = 416, text = "桌下 112"}, {x0 = 464, x1 = 512, text = "巡逻 48"}}, -- 294
	scavenger = { -- 299
		x0 = 464, -- 300
		x1 = 512, -- 301
		y = 0, -- 302
		h = 56, -- 303
		patrolSpeed = 40, -- 304
		approachSpeed = 64, -- 305
		hearTicks = 18, -- 306
		stallTicks = 120, -- 307
		range = 480 -- 308
	}, -- 308
	bottle = {x = 112, y = 48}, -- 310
	brickX = 608, -- 311
	softX = 272, -- 312
	passLine = 440 -- 313
} -- 313
--- 剧本锚点跟着 originX 一起搬，判定仍读世界坐标。
local function shiftStory(story, ox) -- 317
	if story == nil then -- 317
		return nil -- 319
	end -- 319
	if ox == 0 then -- 319
		return story -- 322
	end -- 322
	local out = {} -- 324
	if story.prologue ~= nil then -- 324
		out.prologue = {giveReach = story.prologue.giveReach} -- 326
	end -- 326
	if story.gate ~= nil then -- 326
		out.gate = { -- 329
			winchX = story.gate.winchX + ox, -- 330
			waitX = story.gate.waitX + ox, -- 331
			doorX = story.gate.doorX + ox, -- 332
			exitX = story.gate.exitX + ox, -- 333
			holdTicks = story.gate.holdTicks -- 334
		} -- 334
	end -- 334
	if story.dog ~= nil then -- 334
		out.dog = {x0 = story.dog.x0 + ox, x1 = story.dog.x1 + ox, speed = story.dog.speed, range = story.dog.range} -- 338
	end -- 338
	if story.tower ~= nil then -- 338
		out.tower = {doorX = story.tower.doorX + ox, knockTicks = story.tower.knockTicks} -- 341
	end -- 341
	return out -- 343
end -- 317
--- 序章：周戍在废墟里找到藏在倒柜后的小满，走近点 E 递出指南针（纸条夹在针套里）。
-- 递完她开始跟随，两人一起走进街道。
____exports.PROLOGUE_ROOM = { -- 350
	key = "prologue", -- 351
	originX = 0, -- 352
	name = "序章 · 倒柜后", -- 353
	caption = "周戍持针套，小满藏在倒柜后；走近点 E 递过去，纸条塞进针套，她开始跟随", -- 354
	minX = 0, -- 355
	maxX = 720, -- 356
	height = 200, -- 357
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 358
	solids = {{ -- 359
		x = 150, -- 360
		w = 100, -- 360
		h = 32, -- 360
		y = 0, -- 360
		label = "倒柜 150–250 · 高 32" -- 360
	}, { -- 360
		x = 700, -- 361
		w = 20, -- 361
		h = 120, -- 361
		y = 0, -- 361
		label = "门框 700" -- 361
	}}, -- 361
	zones = {}, -- 363
	arch = { -- 364
		x0 = 0, -- 364
		x1 = 0, -- 364
		y = 0, -- 364
		h = 0, -- 364
		label = "" -- 364
	}, -- 364
	stairs = {}, -- 365
	cart = { -- 366
		startX = 0, -- 366
		endX = 0, -- 366
		baseY = 0, -- 366
		bodyW = 0, -- 366
		bodyH = 0, -- 366
		wheelR = 0, -- 366
		handleOffset = 0, -- 366
		clothSide = 1 -- 366
	}, -- 366
	spawns = {{x = 80, y = 0, h = 88, label = "周戍 80"}, {x = 300, y = 0, h = 64, label = "小满 300 · 柜子后面"}}, -- 367
	marks = {{x = 300, y = 0, kind = 1, label = "柜后 300"}, {x = 700, y = 0, kind = 0, label = "门口 700"}}, -- 371
	dims = {{x0 = 150, x1 = 250, text = "倒柜 100"}, {x0 = 700, x1 = 720, text = "门 20"}}, -- 375
	story = {prologue = {giveReach = 46}} -- 379
} -- 379
--- 街道：两人已经同行，第一次交火在街心柜台后，打完把柜台敲两下算解除。
-- 一路走到检查站入口，提交进度后进入检查站。
____exports.STREET_ROOM = { -- 386
	key = "street", -- 387
	originX = 0, -- 388
	name = "街道 · 柜台与交火", -- 389
	caption = "小满跟着走；街心柜台后有两名敌兵，点鼠标射击，清掉后一起走到检查站入口", -- 390
	minX = 0, -- 391
	maxX = 1000, -- 392
	height = 210, -- 393
	floors = {{y = 0, x0 = 0, x1 = 1000}}, -- 394
	solids = {{ -- 395
		x = 300, -- 396
		w = 100, -- 396
		h = 44, -- 396
		y = 0, -- 396
		label = "街心柜台 300–400 · 高 44" -- 396
	}, { -- 396
		x = 620, -- 397
		w = 60, -- 397
		h = 36, -- 397
		y = 0, -- 397
		label = "街边矮墙 620" -- 397
	}, { -- 397
		x = 960, -- 398
		w = 40, -- 398
		h = 120, -- 398
		y = 0, -- 398
		label = "检查站门 960" -- 398
	}}, -- 398
	zones = {}, -- 400
	arch = { -- 401
		x0 = 0, -- 401
		x1 = 0, -- 401
		y = 0, -- 401
		h = 0, -- 401
		label = "" -- 401
	}, -- 401
	stairs = {}, -- 402
	cart = { -- 403
		startX = 0, -- 403
		endX = 0, -- 403
		baseY = 0, -- 403
		bodyW = 0, -- 403
		bodyH = 0, -- 403
		wheelR = 0, -- 403
		handleOffset = 0, -- 403
		clothSide = 1 -- 403
	}, -- 403
	spawns = {{x = 100, y = 0, h = 88, label = "周戍 100"}, {x = 60, y = 0, h = 64, label = "小满 60"}}, -- 404
	marks = {{x = 900, y = 0, kind = 0, label = "检查站入口 900"}, {x = 520, y = 0, kind = 3, label = "街心 520"}}, -- 408
	dims = {{x0 = 300, x1 = 400, text = "柜台 100"}, {x0 = 900, x1 = 1000, text = "入口 100"}} -- 412
} -- 412
--- 城门：周戍把小满送到门洞等待点，自己回到绞盘；两人就位后开始 45 秒守点。
-- 守满后玩家走到门边按 E 送别，接着是数到一百与交权。
____exports.GATE_ROOM = { -- 422
	key = "gate", -- 423
	originX = 0, -- 424
	name = "城门 · 45 秒守点", -- 425
	caption = "小满到门洞 960、周戍回绞盘 195，两人就位开始 45 秒；守满走到门边按 E 送她", -- 426
	minX = 0, -- 427
	maxX = 1200, -- 428
	height = 240, -- 429
	floors = {{y = 0, x0 = 0, x1 = 1200}}, -- 430
	solids = {{ -- 431
		x = 40, -- 432
		w = 60, -- 432
		h = 60, -- 432
		y = 0, -- 432
		label = "绞盘 40–100 · 高 60" -- 432
	}, { -- 432
		x = 520, -- 433
		w = 80, -- 433
		h = 44, -- 433
		y = 0, -- 433
		label = "街垒 520 · 高 44" -- 433
	}, { -- 433
		x = 1040, -- 434
		w = 160, -- 434
		h = 180, -- 434
		y = 0, -- 434
		label = "门洞右墙 1040" -- 434
	}, { -- 434
		x = 840, -- 435
		w = 200, -- 435
		h = 56, -- 435
		y = 160, -- 435
		label = "门楣 840–1040" -- 435
	}}, -- 435
	zones = {{ -- 437
		x0 = 860, -- 438
		x1 = 1000, -- 438
		y = 0, -- 438
		h = 8, -- 438
		tint = 4, -- 438
		label = "门洞 860–1000" -- 438
	}}, -- 438
	arch = { -- 440
		x0 = 0, -- 440
		x1 = 0, -- 440
		y = 0, -- 440
		h = 0, -- 440
		label = "" -- 440
	}, -- 440
	stairs = {}, -- 441
	cart = { -- 442
		startX = 0, -- 442
		endX = 0, -- 442
		baseY = 0, -- 442
		bodyW = 0, -- 442
		bodyH = 0, -- 442
		wheelR = 0, -- 442
		handleOffset = 0, -- 442
		clothSide = 1 -- 442
	}, -- 442
	spawns = {{x = 130, y = 0, h = 88, label = "周戍 130"}, {x = 150, y = 0, h = 64, label = "小满 150"}}, -- 443
	marks = {{x = 70, y = 0, kind = 1, label = "绞盘 70"}, {x = 960, y = 0, kind = 1, label = "门洞等待点 960"}, {x = 860, y = 0, kind = 0, label = "门边 860"}, {x = 1020, y = 0, kind = 0, label = "出门 1020"}}, -- 447
	dims = {{x0 = 40, x1 = 100, text = "绞盘 60"}, {x0 = 840, x1 = 1040, text = "门洞 200"}}, -- 453
	story = {gate = { -- 457
		winchX = 70, -- 457
		waitX = 960, -- 457
		doorX = 860, -- 457
		exitX = 1020, -- 457
		holdTicks = 2700 -- 457
	}} -- 457
} -- 457
--- 北塔森林：小满独自走。草后可以等，狗听见脚步会转耳朵、赶来、停一会儿再回线。
-- 最后一段从林缘自己选时机走到灯下门廊。
____exports.FOREST_ROOM = { -- 464
	key = "forest", -- 465
	originX = 0, -- 466
	name = "北塔森林 · 草与狗", -- 467
	caption = "狗对动静比人快：草后等、Shift 慢走、蹲着过；林缘 1450 走到灯下门廊", -- 468
	minX = 0, -- 469
	maxX = 1600, -- 470
	height = 200, -- 471
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 472
	solids = {{ -- 473
		x = 300, -- 474
		w = 80, -- 474
		h = 24, -- 474
		y = 0, -- 474
		label = "草丛 300–380 · 高 24", -- 474
		passable = true -- 474
	}, { -- 474
		x = 700, -- 475
		w = 90, -- 475
		h = 24, -- 475
		y = 0, -- 475
		label = "草丛 700–790 · 高 24", -- 475
		passable = true -- 475
	}, { -- 475
		x = 1150, -- 476
		w = 90, -- 476
		h = 24, -- 476
		y = 0, -- 476
		label = "草丛 1150–1240 · 高 24", -- 476
		passable = true -- 476
	}, { -- 476
		x = 1560, -- 477
		w = 40, -- 477
		h = 160, -- 477
		y = 0, -- 477
		label = "林缘 1560" -- 477
	}}, -- 477
	zones = {{ -- 479
		x0 = 1400, -- 480
		x1 = 1470, -- 480
		y = 0, -- 480
		h = 6, -- 480
		tint = 4, -- 480
		label = "林边 1400–1470" -- 480
	}}, -- 480
	arch = { -- 482
		x0 = 0, -- 482
		x1 = 0, -- 482
		y = 0, -- 482
		h = 0, -- 482
		label = "" -- 482
	}, -- 482
	stairs = {{ -- 483
		x0 = 520, -- 484
		x1 = 640, -- 484
		y0 = 0, -- 484
		y1 = 22, -- 484
		steps = 1, -- 484
		label = "矮台 520–640 · 高 22" -- 484
	}, { -- 484
		x0 = 980, -- 485
		x1 = 1100, -- 485
		y0 = 0, -- 485
		y1 = 22, -- 485
		steps = 1, -- 485
		label = "矮台 980–1100 · 高 22" -- 485
	}}, -- 485
	cart = { -- 487
		startX = 0, -- 487
		endX = 0, -- 487
		baseY = 0, -- 487
		bodyW = 0, -- 487
		bodyH = 0, -- 487
		wheelR = 0, -- 487
		handleOffset = 0, -- 487
		clothSide = 1 -- 487
	}, -- 487
	spawns = {{x = 120, y = 0, h = 64, label = "小满 120"}}, -- 488
	marks = {{x = 1450, y = 0, kind = 0, label = "林边安全点 1450"}, {x = 620, y = 0, kind = 3, label = "矮台 620"}}, -- 489
	dims = {{x0 = 700, x1 = 790, text = "草 90"}, {x0 = 1400, x1 = 1470, text = "林边 70"}}, -- 493
	story = {dog = {x0 = 620, x1 = 780, speed = 56, range = 300}} -- 497
} -- 497
--- 塔门与尾声：小满走到门前，按一次 E 敲两下；守卫开门接过针套和纸条，
-- 在登记簿里给下一个人留出一行空白。片尾可以再玩。
____exports.TOWER_ROOM = { -- 504
	key = "tower", -- 505
	originX = 0, -- 506
	name = "北塔塔门 · 尾声", -- 507
	caption = "走到门前点一次 E 敲两下；递出针套和纸条，看登记簿空行，片尾可再玩", -- 508
	minX = 0, -- 509
	maxX = 720, -- 510
	height = 220, -- 511
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 512
	solids = {{ -- 513
		x = 180, -- 514
		w = 220, -- 514
		h = 200, -- 514
		y = 0, -- 514
		label = "塔身 180–400" -- 514
	}, { -- 514
		x = 490, -- 515
		w = 230, -- 515
		h = 200, -- 515
		y = 0, -- 515
		label = "塔身 490–720" -- 515
	}, { -- 515
		x = 400, -- 516
		w = 90, -- 516
		h = 30, -- 516
		y = 110, -- 516
		label = "门楣 400–490" -- 516
	}}, -- 516
	zones = {{ -- 518
		x0 = 400, -- 519
		x1 = 490, -- 519
		y = 0, -- 519
		h = 8, -- 519
		tint = 4, -- 519
		label = "门廊 400–490" -- 519
	}}, -- 519
	arch = { -- 521
		x0 = 0, -- 521
		x1 = 0, -- 521
		y = 0, -- 521
		h = 0, -- 521
		label = "" -- 521
	}, -- 521
	stairs = {}, -- 522
	cart = { -- 523
		startX = 0, -- 523
		endX = 0, -- 523
		baseY = 0, -- 523
		bodyW = 0, -- 523
		bodyH = 0, -- 523
		wheelR = 0, -- 523
		handleOffset = 0, -- 523
		clothSide = 1 -- 523
	}, -- 523
	spawns = {{x = 418, y = 0, h = 64, label = "小满 418 · 门廊里"}}, -- 524
	marks = {{x = 445, y = 0, kind = 1, label = "门前 445"}}, -- 525
	dims = {{x0 = 400, x1 = 490, text = "门 90"}}, -- 528
	story = {tower = {doorX = 445, knockTicks = 36}} -- 531
} -- 531
____exports.ROOMS = { -- 534
	____exports.PROLOGUE_ROOM, -- 534
	____exports.STREET_ROOM, -- 534
	____exports.CHECKPOINT_ROOM, -- 534
	____exports.GATE_ROOM, -- 534
	____exports.OUTSIDE_ROOM, -- 534
	____exports.VILLAGE_ROOM, -- 534
	____exports.FOREST_ROOM, -- 534
	____exports.TOWER_ROOM -- 534
} -- 534
--- 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
-- 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
function ____exports.withOrigin(room) -- 549
	local ox = room.originX -- 550
	if ox == 0 then -- 550
		return room -- 552
	end -- 552
	local function shift(x) -- 554
		return x + ox -- 554
	end -- 554
	local ____room_key_5 = room.key -- 556
	local ____room_name_6 = room.name -- 557
	local ____room_caption_7 = room.caption -- 558
	local ____shift_result_8 = shift(room.minX) -- 560
	local ____shift_result_9 = shift(room.maxX) -- 561
	local ____room_height_10 = room.height -- 562
	local ____TS__ArrayMap_result_11 = __TS__ArrayMap( -- 563
		room.floors, -- 563
		function(____, f) return { -- 563
			y = f.y, -- 563
			x0 = shift(f.x0), -- 563
			x1 = shift(f.x1) -- 563
		} end -- 563
	) -- 563
	local ____TS__ArrayMap_result_12 = __TS__ArrayMap( -- 564
		room.solids, -- 564
		function(____, s) return { -- 564
			x = shift(s.x), -- 564
			w = s.w, -- 564
			h = s.h, -- 564
			y = s.y, -- 564
			label = s.label -- 564
		} end -- 564
	) -- 564
	local ____TS__ArrayMap_result_13 = __TS__ArrayMap( -- 565
		room.zones, -- 565
		function(____, z) return { -- 565
			x0 = shift(z.x0), -- 565
			x1 = shift(z.x1), -- 565
			y = z.y, -- 565
			h = z.h, -- 565
			tint = z.tint, -- 565
			label = z.label -- 565
		} end -- 565
	) -- 565
	local ____temp_14 = { -- 566
		x0 = shift(room.arch.x0), -- 566
		x1 = shift(room.arch.x1), -- 566
		y = room.arch.y, -- 566
		h = room.arch.h, -- 566
		label = room.arch.label -- 566
	} -- 566
	local ____TS__ArrayMap_result_15 = __TS__ArrayMap( -- 567
		room.stairs, -- 567
		function(____, s) return { -- 567
			x0 = shift(s.x0), -- 567
			x1 = shift(s.x1), -- 567
			y0 = s.y0, -- 567
			y1 = s.y1, -- 567
			steps = s.steps, -- 567
			label = s.label -- 567
		} end -- 567
	) -- 567
	local ____temp_16 = { -- 568
		startX = shift(room.cart.startX), -- 569
		endX = shift(room.cart.endX), -- 570
		baseY = room.cart.baseY, -- 571
		bodyW = room.cart.bodyW, -- 572
		bodyH = room.cart.bodyH, -- 573
		wheelR = room.cart.wheelR, -- 574
		handleOffset = room.cart.handleOffset, -- 575
		clothSide = room.cart.clothSide -- 576
	} -- 576
	local ____TS__ArrayMap_result_17 = __TS__ArrayMap( -- 578
		room.spawns, -- 578
		function(____, s) return { -- 578
			x = shift(s.x), -- 578
			y = s.y, -- 578
			h = s.h, -- 578
			label = s.label -- 578
		} end -- 578
	) -- 578
	local ____TS__ArrayMap_result_18 = __TS__ArrayMap( -- 579
		room.marks, -- 579
		function(____, m) return { -- 579
			x = shift(m.x), -- 579
			y = m.y, -- 579
			kind = m.kind, -- 579
			label = m.label -- 579
		} end -- 579
	) -- 579
	local ____TS__ArrayMap_result_19 = __TS__ArrayMap( -- 580
		room.dims, -- 580
		function(____, d) return { -- 580
			x0 = shift(d.x0), -- 580
			x1 = shift(d.x1), -- 580
			text = d.text -- 580
		} end -- 580
	) -- 580
	local ____temp_0 -- 581
	if room.scavenger == nil then -- 581
		____temp_0 = nil -- 581
	else -- 581
		____temp_0 = { -- 581
			x0 = shift(room.scavenger.x0), -- 582
			x1 = shift(room.scavenger.x1), -- 582
			y = room.scavenger.y, -- 582
			h = room.scavenger.h, -- 582
			patrolSpeed = room.scavenger.patrolSpeed, -- 583
			approachSpeed = room.scavenger.approachSpeed, -- 583
			hearTicks = room.scavenger.hearTicks, -- 584
			stallTicks = room.scavenger.stallTicks, -- 584
			range = room.scavenger.range -- 584
		} -- 584
	end -- 584
	local ____temp_1 -- 586
	if room.bottle == nil then -- 586
		____temp_1 = nil -- 586
	else -- 586
		____temp_1 = { -- 586
			x = shift(room.bottle.x), -- 586
			y = room.bottle.y -- 586
		} -- 586
	end -- 586
	local ____temp_2 -- 587
	if room.brickX == nil then -- 587
		____temp_2 = nil -- 587
	else -- 587
		____temp_2 = shift(room.brickX) -- 587
	end -- 587
	local ____temp_3 -- 588
	if room.softX == nil then -- 588
		____temp_3 = nil -- 588
	else -- 588
		____temp_3 = shift(room.softX) -- 588
	end -- 588
	local ____temp_4 -- 589
	if room.passLine == nil then -- 589
		____temp_4 = nil -- 589
	else -- 589
		____temp_4 = shift(room.passLine) -- 589
	end -- 589
	return { -- 555
		key = ____room_key_5, -- 556
		name = ____room_name_6, -- 557
		caption = ____room_caption_7, -- 558
		originX = 0, -- 559
		minX = ____shift_result_8, -- 560
		maxX = ____shift_result_9, -- 561
		height = ____room_height_10, -- 562
		floors = ____TS__ArrayMap_result_11, -- 563
		solids = ____TS__ArrayMap_result_12, -- 564
		zones = ____TS__ArrayMap_result_13, -- 565
		arch = ____temp_14, -- 566
		stairs = ____TS__ArrayMap_result_15, -- 567
		cart = ____temp_16, -- 568
		spawns = ____TS__ArrayMap_result_17, -- 578
		marks = ____TS__ArrayMap_result_18, -- 579
		dims = ____TS__ArrayMap_result_19, -- 580
		scavenger = ____temp_0, -- 581
		bottle = ____temp_1, -- 586
		brickX = ____temp_2, -- 587
		softX = ____temp_3, -- 588
		passLine = ____temp_4, -- 589
		story = shiftStory(room.story, ox) -- 590
	} -- 590
end -- 549
return ____exports -- 549