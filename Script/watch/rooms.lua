-- [ts]: rooms.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local CITY_DEPTH = {min = -28, max = 60} -- 177
--- 检查站：周戍把车从 640 推到 768 落入 dock，再和小满一起走到出口。
____exports.CHECKPOINT_ROOM = { -- 180
	key = "checkpoint", -- 181
	name = "检查站 · 候检区 640 + 原段 1000", -- 182
	caption = "先翻过队栏进候检区，再带小满走到柜台与安全点；末段按住 E + D 推车 128 单位入窝", -- 183
	originX = 640, -- 185
	minX = -640, -- 186
	maxX = 1000, -- 187
	height = 210, -- 188
	depth = CITY_DEPTH, -- 189
	floors = {{y = 0, x0 = -640, x1 = 1000}}, -- 190
	solids = {{ -- 191
		x = -430, -- 193
		w = 180, -- 193
		h = 28, -- 193
		y = 0, -- 193
		label = "队栏 -430–-250 · 高 28", -- 193
		depth = {min = -10, max = 12} -- 193
	}, { -- 193
		x = 240, -- 195
		w = 100, -- 195
		h = 44, -- 195
		y = 0, -- 195
		label = "柜台 240–340 · 高 44", -- 195
		depth = {min = -10, max = 20} -- 195
	}, { -- 195
		x = 950, -- 196
		w = 50, -- 196
		h = 150, -- 196
		y = 0, -- 196
		label = "城门内侧" -- 196
	}}, -- 196
	zones = {{ -- 198
		x0 = 380, -- 198
		x1 = 560, -- 198
		y = 0, -- 198
		h = 120, -- 198
		tint = 1, -- 198
		label = "危险段 380–560" -- 198
	}}, -- 198
	arch = { -- 199
		x0 = 0, -- 199
		x1 = 0, -- 199
		y = 0, -- 199
		h = 0, -- 199
		label = "" -- 199
	}, -- 199
	stairs = {}, -- 200
	cart = { -- 201
		startX = 640, -- 202
		endX = 768, -- 203
		baseY = 0, -- 204
		depth = 10, -- 205
		bodyW = 48, -- 206
		bodyH = 26, -- 207
		wheelR = 12, -- 208
		handleOffset = -40, -- 209
		clothSide = -1 -- 210
	}, -- 210
	spawns = {{x = -600, y = 0, h = 64, label = "小满 -600（世界 40）"}, {x = -560, y = 0, h = 88, label = "周戍 -560（世界 80）"}}, -- 212
	marks = {{x = 264, y = 0, kind = 1, label = "安全锚 264"}, {x = 768, y = 0, kind = 1, label = "dock 768"}, {x = 860, y = 0, kind = 2, label = "双人出口 792–928"}}, -- 216
	dims = {{x0 = 240, x1 = 340, text = "柜台 100"}, {x0 = 640, x1 = 768, text = "推车 128 · 左柄 E+D"}, {x0 = 792, x1 = 928, text = "出口 136"}} -- 221
} -- 221
--- 城外：同一剖面里同时看上层手柄与下层拱口，这是 D1 要交的那张图。
____exports.OUTSIDE_ROOM = { -- 229
	key = "outside", -- 230
	name = "城外 · 台面 y=96 / 墙根 1240", -- 231
	caption = "从右柄按住 E+D 朝空窝拉 128 单位，轮子落窝后沿台面回左端跳下，蹲过 44 高的拱；洞后墙根小路走到底可看见塔灯", -- 232
	originX = 0, -- 234
	minX = 0, -- 235
	maxX = 1240, -- 236
	height = 230, -- 237
	floors = {{y = 0, x0 = 0, x1 = 1240}, {y = 96, x0 = 128, x1 = 512}, {y = 64, x0 = 820, x1 = 940}}, -- 238
	solids = {{ -- 243
		x = 512, -- 245
		w = 88, -- 245
		h = 134, -- 245
		y = 96, -- 245
		label = "台面右端城墙 · 下层可通" -- 245
	}, { -- 245
		x = 0, -- 246
		w = 40, -- 246
		h = 96, -- 246
		y = 0, -- 246
		label = "街口" -- 246
	}, { -- 246
		x = 1200, -- 247
		w = 40, -- 247
		h = 140, -- 247
		y = 0, -- 247
		label = "墙根尽头" -- 247
	}}, -- 247
	zones = {}, -- 249
	arch = { -- 250
		x0 = 280, -- 250
		x1 = 360, -- 250
		y = 0, -- 250
		h = 44, -- 250
		label = "拱 280–360 · 净高 44" -- 250
	}, -- 250
	stairs = {{ -- 251
		x0 = 40, -- 252
		x1 = 128, -- 252
		y0 = 0, -- 252
		y1 = 96, -- 252
		steps = 2, -- 252
		label = "石阶 0 / 48 / 96" -- 252
	}, { -- 252
		x0 = 700, -- 253
		x1 = 820, -- 253
		y0 = 0, -- 253
		y1 = 64, -- 253
		steps = 3, -- 253
		label = "墙根石阶 0 / 16 / 32 / 48 / 64" -- 253
	}}, -- 253
	cart = { -- 255
		startX = 304, -- 256
		endX = 432, -- 257
		baseY = 96, -- 258
		bodyW = 48, -- 259
		bodyH = 26, -- 260
		wheelR = 12, -- 261
		handleOffset = 40, -- 262
		clothSide = -1 -- 263
	}, -- 263
	spawns = {{x = 160, y = 96, h = 64, label = "小满 160"}}, -- 265
	marks = { -- 266
		{x = 432, y = 96, kind = 1, label = "空窝 432"}, -- 267
		{x = 380, y = 0, kind = 0, label = "洞后检查点 380"}, -- 268
		{x = 520, y = 96, kind = 3, label = "石阶光 · 回首红布"}, -- 269
		{x = 820, y = 64, kind = 3, label = "墙根石阶顶 820"}, -- 270
		{x = 1120, y = 64, kind = 6, label = "塔灯 1120"} -- 271
	}, -- 271
	dims = {{x0 = 304, x1 = 432, text = "拉车 128 · 右柄 E+D"}, {x0 = 128, x1 = 512, text = "台面 384"}, {x0 = 280, x1 = 360, text = "拱 80"}, {x0 = 600, x1 = 1240, text = "墙根 640"}} -- 273
} -- 273
--- 村口：瓶架 112、观察位 160、桌下 304–416（净高 44）、第一院通行线 440、
-- 软土 272（D5 完整）、砖地 608、拾荒者巡逻 464–512。
-- 小满脚底中心 290 起必须蹲，超过 430 才站起；160→440 约 2.63 秒。
____exports.VILLAGE_ROOM = { -- 286
	key = "village", -- 287
	originX = 0, -- 288
	name = "村口 · 架、桌、砖地", -- 289
	caption = "点 E 拾瓶，按住 F 瞄，松手投；砖地一响，拾荒者转身，趁他走开钻过桌下", -- 290
	minX = 0, -- 291
	maxX = 720, -- 292
	height = 200, -- 293
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 294
	solids = {{ -- 295
		x = 96, -- 296
		w = 32, -- 296
		h = 64, -- 296
		y = 0, -- 296
		label = "瓶架" -- 296
	}, { -- 296
		x = 672, -- 298
		w = 48, -- 298
		h = 96, -- 298
		y = 0, -- 298
		label = "院墙" -- 298
	}}, -- 298
	zones = {{ -- 300
		x0 = 256, -- 301
		x1 = 288, -- 301
		y = 0, -- 301
		h = 6, -- 301
		tint = 2, -- 301
		label = "软土 272" -- 301
	}, { -- 301
		x0 = 440, -- 302
		x1 = 448, -- 302
		y = 0, -- 302
		h = 120, -- 302
		tint = 4, -- 302
		label = "通行线 440" -- 302
	}, { -- 302
		x0 = 592, -- 303
		x1 = 624, -- 303
		y = 0, -- 303
		h = 6, -- 303
		tint = 3, -- 303
		label = "砖地 608" -- 303
	}}, -- 303
	arch = { -- 305
		x0 = 304, -- 305
		x1 = 416, -- 305
		y = 0, -- 305
		h = 44, -- 305
		label = "桌下 304–416 · 净高 44" -- 305
	}, -- 305
	stairs = {}, -- 306
	cart = { -- 307
		startX = 0, -- 307
		endX = 0, -- 307
		baseY = 0, -- 307
		bodyW = 0, -- 307
		bodyH = 0, -- 307
		wheelR = 0, -- 307
		handleOffset = 0, -- 307
		clothSide = 1 -- 307
	}, -- 307
	spawns = {{x = 160, y = 0, h = 64, label = "小满 160"}}, -- 308
	marks = {{x = 608, y = 0, kind = 5, label = "砖地落点 608"}, {x = 440, y = 0, kind = 4, label = "通行线 440"}}, -- 309
	dims = {{x0 = 96, x1 = 128, text = "瓶架"}, {x0 = 304, x1 = 416, text = "桌下 112"}, {x0 = 464, x1 = 512, text = "巡逻 48"}}, -- 313
	scavenger = { -- 318
		x0 = 464, -- 319
		x1 = 512, -- 320
		y = 0, -- 321
		h = 56, -- 322
		patrolSpeed = 40, -- 323
		approachSpeed = 64, -- 324
		hearTicks = 18, -- 325
		stallTicks = 120, -- 326
		range = 480 -- 327
	}, -- 327
	bottle = {x = 112, y = 48}, -- 329
	brickX = 608, -- 330
	softX = 272, -- 331
	passLine = 440 -- 332
} -- 332
--- 剧本锚点跟着 originX 一起搬，判定仍读世界坐标。
local function shiftStory(story, ox) -- 336
	if story == nil then -- 336
		return nil -- 338
	end -- 338
	if ox == 0 then -- 338
		return story -- 341
	end -- 341
	local out = {} -- 343
	if story.prologue ~= nil then -- 343
		out.prologue = {giveReach = story.prologue.giveReach} -- 345
	end -- 345
	if story.gate ~= nil then -- 345
		out.gate = { -- 348
			winchX = story.gate.winchX + ox, -- 349
			waitX = story.gate.waitX + ox, -- 350
			doorX = story.gate.doorX + ox, -- 351
			exitX = story.gate.exitX + ox, -- 352
			holdTicks = story.gate.holdTicks -- 353
		} -- 353
	end -- 353
	if story.dog ~= nil then -- 353
		out.dog = {x0 = story.dog.x0 + ox, x1 = story.dog.x1 + ox, speed = story.dog.speed, range = story.dog.range} -- 357
	end -- 357
	if story.tower ~= nil then -- 357
		out.tower = {doorX = story.tower.doorX + ox, knockTicks = story.tower.knockTicks} -- 360
	end -- 360
	return out -- 362
end -- 336
--- 序章：周戍在废墟里找到藏在倒柜后的小满，走近点 E 递出指南针（纸条夹在针套里）。
-- 递完她开始跟随，两人一起走进街道。
____exports.PROLOGUE_ROOM = { -- 369
	key = "prologue", -- 370
	originX = 0, -- 371
	name = "序章 · 倒柜后", -- 372
	caption = "周戍持针套，小满藏在倒柜后；走近点 E 递过去，纸条塞进针套，她开始跟随", -- 373
	minX = 0, -- 374
	maxX = 720, -- 375
	height = 200, -- 376
	depth = CITY_DEPTH, -- 377
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 378
	solids = {{ -- 379
		x = 150, -- 380
		w = 100, -- 380
		h = 32, -- 380
		y = 0, -- 380
		label = "倒柜 150–250 · 高 32", -- 380
		depth = {min = -9, max = 12} -- 380
	}, { -- 380
		x = 700, -- 381
		w = 20, -- 381
		h = 120, -- 381
		y = 0, -- 381
		label = "门框 700" -- 381
	}, { -- 381
		x = 110, -- 382
		w = 44, -- 382
		h = 62, -- 382
		y = 0, -- 382
		label = "近景石堆", -- 382
		depth = {min = -25, max = -15}, -- 382
		decorative = true, -- 383
		art = "cover_stone" -- 383
	}}, -- 383
	zones = {}, -- 385
	arch = { -- 386
		x0 = 0, -- 386
		x1 = 0, -- 386
		y = 0, -- 386
		h = 0, -- 386
		label = "" -- 386
	}, -- 386
	stairs = {}, -- 387
	cart = { -- 388
		startX = 0, -- 388
		endX = 0, -- 388
		baseY = 0, -- 388
		bodyW = 0, -- 388
		bodyH = 0, -- 388
		wheelR = 0, -- 388
		handleOffset = 0, -- 388
		clothSide = 1 -- 388
	}, -- 388
	spawns = {{x = 80, y = 0, h = 88, label = "周戍 80"}, {x = 300, y = 0, h = 64, label = "小满 300 · 柜子后面"}}, -- 389
	marks = {{x = 300, y = 0, kind = 1, label = "柜后 300"}, {x = 700, y = 0, kind = 0, label = "门口 700"}}, -- 393
	dims = {{x0 = 150, x1 = 250, text = "倒柜 100"}, {x0 = 700, x1 = 720, text = "门 20"}}, -- 397
	story = {prologue = {giveReach = 46}} -- 401
} -- 401
--- 街道：两人已经同行，第一次交火在街心柜台后，打完把柜台敲两下算解除。
-- 一路走到检查站入口，提交进度后进入检查站。
____exports.STREET_ROOM = { -- 408
	key = "street", -- 409
	originX = 0, -- 410
	name = "街道 · 柜台与交火", -- 411
	caption = "小满跟着走；街心柜台后有两名敌兵，点鼠标射击，清掉后一起走到检查站入口", -- 412
	minX = 0, -- 413
	maxX = 1000, -- 414
	height = 210, -- 415
	depth = CITY_DEPTH, -- 416
	floors = {{y = 0, x0 = 0, x1 = 1000}}, -- 417
	solids = {{ -- 418
		x = 300, -- 419
		w = 100, -- 419
		h = 44, -- 419
		y = 0, -- 419
		label = "街心柜台 300–400 · 高 44", -- 419
		depth = {min = -11, max = 16} -- 419
	}, { -- 419
		x = 620, -- 420
		w = 60, -- 420
		h = 36, -- 420
		y = 0, -- 420
		label = "街边矮墙 620", -- 420
		depth = {min = 22, max = 43} -- 420
	}, { -- 420
		x = 960, -- 421
		w = 40, -- 421
		h = 120, -- 421
		y = 0, -- 421
		label = "检查站门 960" -- 421
	}}, -- 421
	zones = {}, -- 423
	arch = { -- 424
		x0 = 0, -- 424
		x1 = 0, -- 424
		y = 0, -- 424
		h = 0, -- 424
		label = "" -- 424
	}, -- 424
	stairs = {}, -- 425
	cart = { -- 426
		startX = 0, -- 426
		endX = 0, -- 426
		baseY = 0, -- 426
		bodyW = 0, -- 426
		bodyH = 0, -- 426
		wheelR = 0, -- 426
		handleOffset = 0, -- 426
		clothSide = 1 -- 426
	}, -- 426
	spawns = {{x = 100, y = 0, h = 88, label = "周戍 100"}, {x = 60, y = 0, h = 64, label = "小满 60"}}, -- 427
	marks = {{x = 900, y = 0, kind = 0, label = "检查站入口 900"}, {x = 520, y = 0, kind = 3, label = "街心 520"}}, -- 431
	dims = {{x0 = 300, x1 = 400, text = "柜台 100"}, {x0 = 900, x1 = 1000, text = "入口 100"}} -- 435
} -- 435
--- 城门：周戍把小满送到门洞等待点，自己回到绞盘；两人就位后开始 45 秒守点。
-- 守满后玩家走到门边按 E 送别，接着是数到一百与交权。
____exports.GATE_ROOM = { -- 445
	key = "gate", -- 446
	originX = 0, -- 447
	name = "城门 · 45 秒守点", -- 448
	caption = "小满到门洞 960、周戍贴住绞盘 118，两人就位开始 45 秒；守满走到门边按 E 送她", -- 449
	minX = 0, -- 450
	maxX = 1200, -- 451
	height = 240, -- 452
	depth = CITY_DEPTH, -- 453
	floors = {{y = 0, x0 = 0, x1 = 1200}}, -- 454
	solids = {{ -- 455
		x = 40, -- 456
		w = 60, -- 456
		h = 60, -- 456
		y = 0, -- 456
		label = "绞盘 40–100 · 高 60" -- 456
	}, { -- 456
		x = 520, -- 457
		w = 80, -- 457
		h = 44, -- 457
		y = 0, -- 457
		label = "街垒 520 · 高 44", -- 457
		depth = {min = -12, max = 24} -- 457
	}, { -- 457
		x = 1040, -- 458
		w = 160, -- 458
		h = 180, -- 458
		y = 0, -- 458
		label = "门洞右墙 1040" -- 458
	}, { -- 458
		x = 840, -- 459
		w = 200, -- 459
		h = 56, -- 459
		y = 160, -- 459
		label = "门楣 840–1040" -- 459
	}}, -- 459
	zones = {{ -- 461
		x0 = 860, -- 462
		x1 = 1000, -- 462
		y = 0, -- 462
		h = 8, -- 462
		tint = 4, -- 462
		label = "门洞 860–1000" -- 462
	}}, -- 462
	arch = { -- 464
		x0 = 0, -- 464
		x1 = 0, -- 464
		y = 0, -- 464
		h = 0, -- 464
		label = "" -- 464
	}, -- 464
	stairs = {}, -- 465
	cart = { -- 466
		startX = 0, -- 466
		endX = 0, -- 466
		baseY = 0, -- 466
		bodyW = 0, -- 466
		bodyH = 0, -- 466
		wheelR = 0, -- 466
		handleOffset = 0, -- 466
		clothSide = 1 -- 466
	}, -- 466
	spawns = {{x = 130, y = 0, h = 88, label = "周戍 130"}, {x = 150, y = 0, h = 64, label = "小满 150"}}, -- 467
	marks = {{x = 118, y = 0, kind = 1, label = "绞盘站位 118"}, {x = 960, y = 0, kind = 1, label = "门洞等待点 960"}, {x = 860, y = 0, kind = 0, label = "门边 860"}, {x = 1020, y = 0, kind = 0, label = "出门 1020"}}, -- 471
	dims = {{x0 = 40, x1 = 100, text = "绞盘 60"}, {x0 = 840, x1 = 1040, text = "门洞 200"}}, -- 477
	story = {gate = { -- 482
		winchX = 118, -- 482
		waitX = 960, -- 482
		doorX = 860, -- 482
		exitX = 1020, -- 482
		holdTicks = 2700 -- 482
	}} -- 482
} -- 482
--- 北塔森林：小满独自走。草后可以等，狗听见脚步会转耳朵、赶来、停一会儿再回线。
-- 最后一段从林缘自己选时机走到灯下门廊。
____exports.FOREST_ROOM = { -- 489
	key = "forest", -- 490
	originX = 0, -- 491
	name = "北塔森林 · 草与狗", -- 492
	caption = "狗对动静比人快：草后等、Shift 慢走、蹲着过；林缘 1450 走到灯下门廊", -- 493
	minX = 0, -- 494
	maxX = 1600, -- 495
	height = 200, -- 496
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 497
	solids = {{ -- 498
		x = 300, -- 499
		w = 80, -- 499
		h = 24, -- 499
		y = 0, -- 499
		label = "草丛 300–380 · 高 24", -- 499
		passable = true -- 499
	}, { -- 499
		x = 700, -- 500
		w = 90, -- 500
		h = 24, -- 500
		y = 0, -- 500
		label = "草丛 700–790 · 高 24", -- 500
		passable = true -- 500
	}, { -- 500
		x = 1150, -- 501
		w = 90, -- 501
		h = 24, -- 501
		y = 0, -- 501
		label = "草丛 1150–1240 · 高 24", -- 501
		passable = true -- 501
	}, { -- 501
		x = 1560, -- 502
		w = 40, -- 502
		h = 160, -- 502
		y = 0, -- 502
		label = "林缘 1560" -- 502
	}}, -- 502
	zones = {{ -- 504
		x0 = 1400, -- 505
		x1 = 1470, -- 505
		y = 0, -- 505
		h = 6, -- 505
		tint = 4, -- 505
		label = "林边 1400–1470" -- 505
	}}, -- 505
	arch = { -- 507
		x0 = 0, -- 507
		x1 = 0, -- 507
		y = 0, -- 507
		h = 0, -- 507
		label = "" -- 507
	}, -- 507
	stairs = {{ -- 508
		x0 = 520, -- 509
		x1 = 640, -- 509
		y0 = 0, -- 509
		y1 = 22, -- 509
		steps = 1, -- 509
		label = "矮台 520–640 · 高 22" -- 509
	}, { -- 509
		x0 = 980, -- 510
		x1 = 1100, -- 510
		y0 = 0, -- 510
		y1 = 22, -- 510
		steps = 1, -- 510
		label = "矮台 980–1100 · 高 22" -- 510
	}}, -- 510
	cart = { -- 512
		startX = 0, -- 512
		endX = 0, -- 512
		baseY = 0, -- 512
		bodyW = 0, -- 512
		bodyH = 0, -- 512
		wheelR = 0, -- 512
		handleOffset = 0, -- 512
		clothSide = 1 -- 512
	}, -- 512
	spawns = {{x = 120, y = 0, h = 64, label = "小满 120"}}, -- 513
	marks = {{x = 1450, y = 0, kind = 0, label = "林边安全点 1450"}, {x = 620, y = 0, kind = 3, label = "矮台 620"}}, -- 514
	dims = {{x0 = 700, x1 = 790, text = "草 90"}, {x0 = 1400, x1 = 1470, text = "林边 70"}}, -- 518
	story = {dog = {x0 = 620, x1 = 780, speed = 56, range = 300}} -- 522
} -- 522
--- 塔门与尾声：小满走到门前，按一次 E 敲两下；守卫开门接过针套和纸条，
-- 在登记簿里给下一个人留出一行空白。片尾可以再玩。
____exports.TOWER_ROOM = { -- 529
	key = "tower", -- 530
	originX = 0, -- 531
	name = "北塔塔门 · 尾声", -- 532
	caption = "走到门前点一次 E 敲两下；递出针套和纸条，看登记簿空行，片尾可再玩", -- 533
	minX = 0, -- 534
	maxX = 720, -- 535
	height = 220, -- 536
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 537
	solids = {{ -- 538
		x = 180, -- 539
		w = 220, -- 539
		h = 200, -- 539
		y = 0, -- 539
		label = "塔身 180–400" -- 539
	}, { -- 539
		x = 490, -- 540
		w = 230, -- 540
		h = 200, -- 540
		y = 0, -- 540
		label = "塔身 490–720" -- 540
	}, { -- 540
		x = 400, -- 541
		w = 90, -- 541
		h = 30, -- 541
		y = 110, -- 541
		label = "门楣 400–490" -- 541
	}}, -- 541
	zones = {{ -- 543
		x0 = 400, -- 544
		x1 = 490, -- 544
		y = 0, -- 544
		h = 8, -- 544
		tint = 4, -- 544
		label = "门廊 400–490" -- 544
	}}, -- 544
	arch = { -- 546
		x0 = 0, -- 546
		x1 = 0, -- 546
		y = 0, -- 546
		h = 0, -- 546
		label = "" -- 546
	}, -- 546
	stairs = {}, -- 547
	cart = { -- 548
		startX = 0, -- 548
		endX = 0, -- 548
		baseY = 0, -- 548
		bodyW = 0, -- 548
		bodyH = 0, -- 548
		wheelR = 0, -- 548
		handleOffset = 0, -- 548
		clothSide = 1 -- 548
	}, -- 548
	spawns = {{x = 418, y = 0, h = 64, label = "小满 418 · 门廊里"}}, -- 549
	marks = {{x = 445, y = 0, kind = 1, label = "门前 445"}}, -- 550
	dims = {{x0 = 400, x1 = 490, text = "门 90"}}, -- 553
	story = {tower = {doorX = 445, knockTicks = 36}} -- 556
} -- 556
____exports.ROOMS = { -- 559
	____exports.PROLOGUE_ROOM, -- 559
	____exports.STREET_ROOM, -- 559
	____exports.CHECKPOINT_ROOM, -- 559
	____exports.GATE_ROOM, -- 559
	____exports.OUTSIDE_ROOM, -- 559
	____exports.VILLAGE_ROOM, -- 559
	____exports.FOREST_ROOM, -- 559
	____exports.TOWER_ROOM -- 559
} -- 559
--- 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
-- 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
function ____exports.withOrigin(room) -- 574
	local ox = room.originX -- 575
	if ox == 0 then -- 575
		return room -- 577
	end -- 577
	local function shift(x) -- 579
		return x + ox -- 579
	end -- 579
	local ____room_key_5 = room.key -- 581
	local ____room_name_6 = room.name -- 582
	local ____room_caption_7 = room.caption -- 583
	local ____shift_result_8 = shift(room.minX) -- 585
	local ____shift_result_9 = shift(room.maxX) -- 586
	local ____room_height_10 = room.height -- 587
	local ____room_depth_11 = room.depth -- 588
	local ____TS__ArrayMap_result_12 = __TS__ArrayMap( -- 589
		room.floors, -- 589
		function(____, f) return { -- 589
			y = f.y, -- 589
			x0 = shift(f.x0), -- 589
			x1 = shift(f.x1) -- 589
		} end -- 589
	) -- 589
	local ____TS__ArrayMap_result_13 = __TS__ArrayMap( -- 590
		room.solids, -- 590
		function(____, s) return __TS__ObjectAssign( -- 590
			{}, -- 590
			s, -- 590
			{x = shift(s.x)} -- 590
		) end -- 590
	) -- 590
	local ____TS__ArrayMap_result_14 = __TS__ArrayMap( -- 591
		room.zones, -- 591
		function(____, z) return { -- 591
			x0 = shift(z.x0), -- 591
			x1 = shift(z.x1), -- 591
			y = z.y, -- 591
			h = z.h, -- 591
			tint = z.tint, -- 591
			label = z.label -- 591
		} end -- 591
	) -- 591
	local ____temp_15 = { -- 592
		x0 = shift(room.arch.x0), -- 592
		x1 = shift(room.arch.x1), -- 592
		y = room.arch.y, -- 592
		h = room.arch.h, -- 592
		label = room.arch.label -- 592
	} -- 592
	local ____TS__ArrayMap_result_16 = __TS__ArrayMap( -- 593
		room.stairs, -- 593
		function(____, s) return { -- 593
			x0 = shift(s.x0), -- 593
			x1 = shift(s.x1), -- 593
			y0 = s.y0, -- 593
			y1 = s.y1, -- 593
			steps = s.steps, -- 593
			label = s.label -- 593
		} end -- 593
	) -- 593
	local ____TS__ObjectAssign_result_17 = __TS__ObjectAssign( -- 594
		{}, -- 594
		room.cart, -- 595
		{ -- 594
			startX = shift(room.cart.startX), -- 596
			endX = shift(room.cart.endX) -- 597
		} -- 597
	) -- 597
	local ____TS__ArrayMap_result_18 = __TS__ArrayMap( -- 599
		room.spawns, -- 599
		function(____, s) return __TS__ObjectAssign( -- 599
			{}, -- 599
			s, -- 599
			{x = shift(s.x)} -- 599
		) end -- 599
	) -- 599
	local ____TS__ArrayMap_result_19 = __TS__ArrayMap( -- 600
		room.marks, -- 600
		function(____, m) return { -- 600
			x = shift(m.x), -- 600
			y = m.y, -- 600
			kind = m.kind, -- 600
			label = m.label -- 600
		} end -- 600
	) -- 600
	local ____TS__ArrayMap_result_20 = __TS__ArrayMap( -- 601
		room.dims, -- 601
		function(____, d) return { -- 601
			x0 = shift(d.x0), -- 601
			x1 = shift(d.x1), -- 601
			text = d.text -- 601
		} end -- 601
	) -- 601
	local ____temp_0 -- 602
	if room.scavenger == nil then -- 602
		____temp_0 = nil -- 602
	else -- 602
		____temp_0 = { -- 602
			x0 = shift(room.scavenger.x0), -- 603
			x1 = shift(room.scavenger.x1), -- 603
			y = room.scavenger.y, -- 603
			h = room.scavenger.h, -- 603
			patrolSpeed = room.scavenger.patrolSpeed, -- 604
			approachSpeed = room.scavenger.approachSpeed, -- 604
			hearTicks = room.scavenger.hearTicks, -- 605
			stallTicks = room.scavenger.stallTicks, -- 605
			range = room.scavenger.range -- 605
		} -- 605
	end -- 605
	local ____temp_1 -- 607
	if room.bottle == nil then -- 607
		____temp_1 = nil -- 607
	else -- 607
		____temp_1 = { -- 607
			x = shift(room.bottle.x), -- 607
			y = room.bottle.y -- 607
		} -- 607
	end -- 607
	local ____temp_2 -- 608
	if room.brickX == nil then -- 608
		____temp_2 = nil -- 608
	else -- 608
		____temp_2 = shift(room.brickX) -- 608
	end -- 608
	local ____temp_3 -- 609
	if room.softX == nil then -- 609
		____temp_3 = nil -- 609
	else -- 609
		____temp_3 = shift(room.softX) -- 609
	end -- 609
	local ____temp_4 -- 610
	if room.passLine == nil then -- 610
		____temp_4 = nil -- 610
	else -- 610
		____temp_4 = shift(room.passLine) -- 610
	end -- 610
	return { -- 580
		key = ____room_key_5, -- 581
		name = ____room_name_6, -- 582
		caption = ____room_caption_7, -- 583
		originX = 0, -- 584
		minX = ____shift_result_8, -- 585
		maxX = ____shift_result_9, -- 586
		height = ____room_height_10, -- 587
		depth = ____room_depth_11, -- 588
		floors = ____TS__ArrayMap_result_12, -- 589
		solids = ____TS__ArrayMap_result_13, -- 590
		zones = ____TS__ArrayMap_result_14, -- 591
		arch = ____temp_15, -- 592
		stairs = ____TS__ArrayMap_result_16, -- 593
		cart = ____TS__ObjectAssign_result_17, -- 594
		spawns = ____TS__ArrayMap_result_18, -- 599
		marks = ____TS__ArrayMap_result_19, -- 600
		dims = ____TS__ArrayMap_result_20, -- 601
		scavenger = ____temp_0, -- 602
		bottle = ____temp_1, -- 607
		brickX = ____temp_2, -- 608
		softX = ____temp_3, -- 609
		passLine = ____temp_4, -- 610
		story = shiftStory(room.story, ox) -- 611
	} -- 611
end -- 574
return ____exports -- 574