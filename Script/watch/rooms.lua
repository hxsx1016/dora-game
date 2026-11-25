-- [ts]: rooms.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____depth = require("Script.watch.depth") -- 8
local LANE_DEPTH = ____depth.LANE_DEPTH -- 8
local LANE_ROAD = ____depth.LANE_ROAD -- 8
local laneFootprints = ____depth.laneFootprints -- 8
--- 检查站：周戍把车从 640 推到 768 落入 dock，再和小满一起走到出口。
____exports.CHECKPOINT_ROOM = { -- 181
	key = "checkpoint", -- 182
	name = "检查站 · 候检区 640 + 原段 1000", -- 183
	caption = "先翻过队栏进候检区，再带小满走到柜台与安全点；末段按住 E + D 推车 128 单位入窝", -- 184
	originX = 640, -- 186
	minX = -640, -- 187
	maxX = 1000, -- 188
	height = 210, -- 189
	depth = LANE_ROAD, -- 190
	floors = {{y = 0, x0 = -640, x1 = 1000}}, -- 191
	solids = {{ -- 192
		x = -430, -- 194
		w = 180, -- 194
		h = 28, -- 194
		y = 0, -- 194
		label = "队栏 -430–-250 · 高 28", -- 194
		lanes = {"lower", "middle"} -- 194
	}, { -- 194
		x = 240, -- 196
		w = 100, -- 196
		h = 44, -- 196
		y = 0, -- 196
		label = "柜台 240–340 · 高 44", -- 196
		lanes = {"lower", "middle"} -- 196
	}, { -- 196
		x = 890, -- 197
		w = 36, -- 197
		h = 122, -- 197
		y = 0, -- 197
		label = "检查站出口门柱", -- 197
		lanes = {"lower", "upper"}, -- 197
		art = "gate_post" -- 197
	}}, -- 197
	zones = {{ -- 199
		x0 = 380, -- 199
		x1 = 560, -- 199
		y = 0, -- 199
		h = 120, -- 199
		tint = 1, -- 199
		label = "危险段 380–560" -- 199
	}}, -- 199
	arch = { -- 200
		x0 = 0, -- 200
		x1 = 0, -- 200
		y = 0, -- 200
		h = 0, -- 200
		label = "" -- 200
	}, -- 200
	stairs = {}, -- 201
	cart = { -- 202
		startX = 640, -- 203
		endX = 768, -- 204
		baseY = 0, -- 205
		depth = LANE_DEPTH.middle, -- 206
		bodyW = 48, -- 207
		bodyH = 26, -- 208
		wheelR = 12, -- 209
		handleOffset = -40, -- 210
		clothSide = -1 -- 211
	}, -- 211
	spawns = {{x = -600, y = 0, h = 64, label = "小满 -600（世界 40）"}, {x = -560, y = 0, h = 88, label = "周戍 -560（世界 80）"}}, -- 213
	marks = {{x = 264, y = 0, kind = 1, label = "安全锚 264"}, {x = 768, y = 0, kind = 1, label = "dock 768"}, {x = 860, y = 0, kind = 2, label = "双人出口 792–928"}}, -- 217
	dims = {{x0 = 240, x1 = 340, text = "柜台 100"}, {x0 = 640, x1 = 768, text = "推车 128 · 左柄 E+D"}, {x0 = 792, x1 = 928, text = "出口 136"}} -- 222
} -- 222
--- 城外：同一剖面里同时看上层手柄与下层拱口，这是 D1 要交的那张图。
____exports.OUTSIDE_ROOM = { -- 230
	key = "outside", -- 231
	name = "城外 · 台面 y=96 / 墙根 1240", -- 232
	caption = "从右柄按住 E+D 朝空窝拉 128 单位，轮子落窝后沿台面回左端跳下，蹲过 44 高的拱；洞后墙根小路走到底可看见塔灯", -- 233
	originX = 0, -- 235
	minX = 0, -- 236
	maxX = 1240, -- 237
	height = 230, -- 238
	floors = {{y = 0, x0 = 0, x1 = 1240}, {y = 96, x0 = 128, x1 = 512}, {y = 64, x0 = 820, x1 = 940}}, -- 239
	solids = {{ -- 244
		x = 512, -- 246
		w = 88, -- 246
		h = 134, -- 246
		y = 96, -- 246
		label = "台面右端城墙 · 下层可通" -- 246
	}, { -- 246
		x = 0, -- 247
		w = 40, -- 247
		h = 96, -- 247
		y = 0, -- 247
		label = "街口" -- 247
	}, { -- 247
		x = 1200, -- 248
		w = 40, -- 248
		h = 140, -- 248
		y = 0, -- 248
		label = "墙根尽头" -- 248
	}}, -- 248
	zones = {}, -- 250
	arch = { -- 251
		x0 = 280, -- 251
		x1 = 360, -- 251
		y = 0, -- 251
		h = 44, -- 251
		label = "拱 280–360 · 净高 44" -- 251
	}, -- 251
	stairs = {{ -- 252
		x0 = 40, -- 253
		x1 = 128, -- 253
		y0 = 0, -- 253
		y1 = 96, -- 253
		steps = 2, -- 253
		label = "石阶 0 / 48 / 96" -- 253
	}, { -- 253
		x0 = 700, -- 254
		x1 = 820, -- 254
		y0 = 0, -- 254
		y1 = 64, -- 254
		steps = 3, -- 254
		label = "墙根石阶 0 / 16 / 32 / 48 / 64" -- 254
	}}, -- 254
	cart = { -- 256
		startX = 304, -- 257
		endX = 432, -- 258
		baseY = 96, -- 259
		bodyW = 48, -- 260
		bodyH = 26, -- 261
		wheelR = 12, -- 262
		handleOffset = 40, -- 263
		clothSide = -1 -- 264
	}, -- 264
	spawns = {{x = 160, y = 96, h = 64, label = "小满 160"}}, -- 266
	marks = { -- 267
		{x = 432, y = 96, kind = 1, label = "空窝 432"}, -- 268
		{x = 380, y = 0, kind = 0, label = "洞后检查点 380"}, -- 269
		{x = 520, y = 96, kind = 3, label = "石阶光 · 回首红布"}, -- 270
		{x = 820, y = 64, kind = 3, label = "墙根石阶顶 820"}, -- 271
		{x = 1120, y = 64, kind = 6, label = "塔灯 1120"} -- 272
	}, -- 272
	dims = {{x0 = 304, x1 = 432, text = "拉车 128 · 右柄 E+D"}, {x0 = 128, x1 = 512, text = "台面 384"}, {x0 = 280, x1 = 360, text = "拱 80"}, {x0 = 600, x1 = 1240, text = "墙根 640"}} -- 274
} -- 274
--- 村口：瓶架 112、观察位 160、桌下 304–416（净高 44）、第一院通行线 440、
-- 软土 272（D5 完整）、砖地 608、拾荒者巡逻 464–512。
-- 小满脚底中心 290 起必须蹲，超过 430 才站起；160→440 约 2.63 秒。
____exports.VILLAGE_ROOM = { -- 287
	key = "village", -- 288
	originX = 0, -- 289
	name = "村口 · 架、桌、砖地", -- 290
	caption = "点 E 拾瓶，按住 F 瞄，松手投；砖地一响，拾荒者转身，趁他走开钻过桌下", -- 291
	minX = 0, -- 292
	maxX = 720, -- 293
	height = 200, -- 294
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 295
	solids = {{ -- 296
		x = 96, -- 297
		w = 32, -- 297
		h = 64, -- 297
		y = 0, -- 297
		label = "瓶架" -- 297
	}, { -- 297
		x = 672, -- 299
		w = 48, -- 299
		h = 96, -- 299
		y = 0, -- 299
		label = "院墙" -- 299
	}}, -- 299
	zones = {{ -- 301
		x0 = 256, -- 302
		x1 = 288, -- 302
		y = 0, -- 302
		h = 6, -- 302
		tint = 2, -- 302
		label = "软土 272" -- 302
	}, { -- 302
		x0 = 440, -- 303
		x1 = 448, -- 303
		y = 0, -- 303
		h = 120, -- 303
		tint = 4, -- 303
		label = "通行线 440" -- 303
	}, { -- 303
		x0 = 592, -- 304
		x1 = 624, -- 304
		y = 0, -- 304
		h = 6, -- 304
		tint = 3, -- 304
		label = "砖地 608" -- 304
	}}, -- 304
	arch = { -- 306
		x0 = 304, -- 306
		x1 = 416, -- 306
		y = 0, -- 306
		h = 44, -- 306
		label = "桌下 304–416 · 净高 44" -- 306
	}, -- 306
	stairs = {}, -- 307
	cart = { -- 308
		startX = 0, -- 308
		endX = 0, -- 308
		baseY = 0, -- 308
		bodyW = 0, -- 308
		bodyH = 0, -- 308
		wheelR = 0, -- 308
		handleOffset = 0, -- 308
		clothSide = 1 -- 308
	}, -- 308
	spawns = {{x = 160, y = 0, h = 64, label = "小满 160"}}, -- 309
	marks = {{x = 608, y = 0, kind = 5, label = "砖地落点 608"}, {x = 440, y = 0, kind = 4, label = "通行线 440"}}, -- 310
	dims = {{x0 = 96, x1 = 128, text = "瓶架"}, {x0 = 304, x1 = 416, text = "桌下 112"}, {x0 = 464, x1 = 512, text = "巡逻 48"}}, -- 314
	scavenger = { -- 319
		x0 = 464, -- 320
		x1 = 512, -- 321
		y = 0, -- 322
		h = 56, -- 323
		patrolSpeed = 40, -- 324
		approachSpeed = 64, -- 325
		hearTicks = 18, -- 326
		stallTicks = 120, -- 327
		range = 480 -- 328
	}, -- 328
	bottle = {x = 112, y = 48}, -- 330
	brickX = 608, -- 331
	softX = 272, -- 332
	passLine = 440 -- 333
} -- 333
--- 剧本锚点跟着 originX 一起搬，判定仍读世界坐标。
local function shiftStory(story, ox) -- 337
	if story == nil then -- 337
		return nil -- 339
	end -- 339
	if ox == 0 then -- 339
		return story -- 342
	end -- 342
	local out = {} -- 344
	if story.prologue ~= nil then -- 344
		out.prologue = {giveReach = story.prologue.giveReach} -- 346
	end -- 346
	if story.gate ~= nil then -- 346
		out.gate = { -- 349
			winchX = story.gate.winchX + ox, -- 350
			waitX = story.gate.waitX + ox, -- 351
			doorX = story.gate.doorX + ox, -- 352
			exitX = story.gate.exitX + ox, -- 353
			holdTicks = story.gate.holdTicks -- 354
		} -- 354
	end -- 354
	if story.dog ~= nil then -- 354
		out.dog = {x0 = story.dog.x0 + ox, x1 = story.dog.x1 + ox, speed = story.dog.speed, range = story.dog.range} -- 358
	end -- 358
	if story.tower ~= nil then -- 358
		out.tower = {doorX = story.tower.doorX + ox, knockTicks = story.tower.knockTicks} -- 361
	end -- 361
	return out -- 363
end -- 337
--- 序章：周戍在废墟里找到藏在倒柜后的小满，走近点 E 递出指南针（纸条夹在针套里）。
-- 递完她开始跟随，两人一起走进街道。
____exports.PROLOGUE_ROOM = { -- 370
	key = "prologue", -- 371
	originX = 0, -- 372
	name = "序章 · 倒柜后", -- 373
	caption = "周戍持针套，小满藏在倒柜后；走近点 E 递过去，纸条塞进针套，她开始跟随", -- 374
	minX = 0, -- 375
	maxX = 720, -- 376
	height = 200, -- 377
	depth = LANE_ROAD, -- 378
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 379
	solids = {{ -- 380
		x = 152, -- 381
		w = 98, -- 381
		h = 32, -- 381
		y = 0, -- 381
		label = "倒柜 152–250 · 高 32", -- 381
		lanes = {"lower", "middle"} -- 381
	}, { -- 381
		x = 648, -- 382
		w = 30, -- 382
		h = 118, -- 382
		y = 0, -- 382
		label = "出口门柱", -- 382
		lanes = {"lower", "upper"}, -- 382
		art = "gate_post" -- 382
	}, { -- 382
		x = 110, -- 383
		w = 38, -- 383
		h = 84, -- 383
		y = 0, -- 383
		label = "石柱", -- 383
		lanes = {"lower", "middle"}, -- 383
		art = "wall" -- 383
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
	marks = {{x = 300, y = 0, kind = 1, label = "柜后 300"}, {x = 660, y = 0, kind = 0, label = "门口中路 660"}}, -- 393
	dims = {{x0 = 152, x1 = 250, text = "倒柜 98"}, {x0 = 648, x1 = 678, text = "门柱 30"}}, -- 397
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
	depth = LANE_ROAD, -- 416
	floors = {{y = 0, x0 = 0, x1 = 1000}}, -- 417
	solids = {{ -- 418
		x = 300, -- 419
		w = 100, -- 419
		h = 44, -- 419
		y = 0, -- 419
		label = "街心柜台 300–400 · 高 44", -- 419
		lanes = {"lower", "middle"} -- 419
	}, { -- 419
		x = 620, -- 420
		w = 60, -- 420
		h = 36, -- 420
		y = 0, -- 420
		label = "街边矮墙 620", -- 420
		lanes = {"upper"} -- 420
	}, { -- 420
		x = 892, -- 421
		w = 40, -- 421
		h = 120, -- 421
		y = 0, -- 421
		label = "检查站门柱", -- 421
		lanes = {"lower", "upper"}, -- 421
		art = "gate_post" -- 421
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
	depth = LANE_ROAD, -- 453
	floors = {{y = 0, x0 = 0, x1 = 1200}}, -- 454
	solids = { -- 455
		{ -- 456
			x = 40, -- 456
			w = 60, -- 456
			h = 60, -- 456
			y = 0, -- 456
			label = "绞盘 40–100 · 高 60" -- 456
		}, -- 456
		{ -- 457
			x = 520, -- 457
			w = 80, -- 457
			h = 44, -- 457
			y = 0, -- 457
			label = "街垒 520 · 高 44", -- 457
			lanes = {"middle", "upper"} -- 457
		}, -- 457
		{ -- 458
			x = 970, -- 458
			w = 34, -- 458
			h = 100, -- 458
			y = 0, -- 458
			label = "城门门柱", -- 458
			lanes = {"lower", "upper"}, -- 458
			art = "gate_post" -- 458
		}, -- 458
		{ -- 459
			x = 1040, -- 459
			w = 160, -- 459
			h = 180, -- 459
			y = 0, -- 459
			label = "门洞右墙 1040" -- 459
		}, -- 459
		{ -- 460
			x = 840, -- 460
			w = 200, -- 460
			h = 56, -- 460
			y = 160, -- 460
			label = "门楣 840–1040" -- 460
		} -- 460
	}, -- 460
	zones = {{ -- 462
		x0 = 860, -- 463
		x1 = 1000, -- 463
		y = 0, -- 463
		h = 8, -- 463
		tint = 4, -- 463
		label = "门洞 860–1000" -- 463
	}}, -- 463
	arch = { -- 465
		x0 = 0, -- 465
		x1 = 0, -- 465
		y = 0, -- 465
		h = 0, -- 465
		label = "" -- 465
	}, -- 465
	stairs = {}, -- 466
	cart = { -- 467
		startX = 0, -- 467
		endX = 0, -- 467
		baseY = 0, -- 467
		bodyW = 0, -- 467
		bodyH = 0, -- 467
		wheelR = 0, -- 467
		handleOffset = 0, -- 467
		clothSide = 1 -- 467
	}, -- 467
	spawns = {{x = 130, y = 0, h = 88, label = "周戍 130"}, {x = 150, y = 0, h = 64, label = "小满 150"}}, -- 468
	marks = {{x = 118, y = 0, kind = 1, label = "绞盘站位 118"}, {x = 960, y = 0, kind = 1, label = "门洞等待点 960"}, {x = 860, y = 0, kind = 0, label = "门边 860"}, {x = 1020, y = 0, kind = 0, label = "出门 1020"}}, -- 472
	dims = {{x0 = 40, x1 = 100, text = "绞盘 60"}, {x0 = 840, x1 = 1040, text = "门洞 200"}}, -- 478
	story = {gate = { -- 483
		winchX = 118, -- 483
		waitX = 960, -- 483
		doorX = 860, -- 483
		exitX = 1020, -- 483
		holdTicks = 2700 -- 483
	}} -- 483
} -- 483
--- 北塔森林：小满独自走。草后可以等，狗听见脚步会转耳朵、赶来、停一会儿再回线。
-- 最后一段从林缘自己选时机走到灯下门廊。
____exports.FOREST_ROOM = { -- 490
	key = "forest", -- 491
	originX = 0, -- 492
	name = "北塔森林 · 草与狗", -- 493
	caption = "狗对动静比人快：草后等、Shift 慢走、蹲着过；林缘 1450 走到灯下门廊", -- 494
	minX = 0, -- 495
	maxX = 1600, -- 496
	height = 200, -- 497
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 498
	solids = {{ -- 499
		x = 300, -- 500
		w = 80, -- 500
		h = 24, -- 500
		y = 0, -- 500
		label = "草丛 300–380 · 高 24", -- 500
		passable = true -- 500
	}, { -- 500
		x = 700, -- 501
		w = 90, -- 501
		h = 24, -- 501
		y = 0, -- 501
		label = "草丛 700–790 · 高 24", -- 501
		passable = true -- 501
	}, { -- 501
		x = 1150, -- 502
		w = 90, -- 502
		h = 24, -- 502
		y = 0, -- 502
		label = "草丛 1150–1240 · 高 24", -- 502
		passable = true -- 502
	}, { -- 502
		x = 1560, -- 503
		w = 40, -- 503
		h = 160, -- 503
		y = 0, -- 503
		label = "林缘 1560" -- 503
	}}, -- 503
	zones = {{ -- 505
		x0 = 1400, -- 506
		x1 = 1470, -- 506
		y = 0, -- 506
		h = 6, -- 506
		tint = 4, -- 506
		label = "林边 1400–1470" -- 506
	}}, -- 506
	arch = { -- 508
		x0 = 0, -- 508
		x1 = 0, -- 508
		y = 0, -- 508
		h = 0, -- 508
		label = "" -- 508
	}, -- 508
	stairs = {{ -- 509
		x0 = 520, -- 510
		x1 = 640, -- 510
		y0 = 0, -- 510
		y1 = 22, -- 510
		steps = 1, -- 510
		label = "矮台 520–640 · 高 22" -- 510
	}, { -- 510
		x0 = 980, -- 511
		x1 = 1100, -- 511
		y0 = 0, -- 511
		y1 = 22, -- 511
		steps = 1, -- 511
		label = "矮台 980–1100 · 高 22" -- 511
	}}, -- 511
	cart = { -- 513
		startX = 0, -- 513
		endX = 0, -- 513
		baseY = 0, -- 513
		bodyW = 0, -- 513
		bodyH = 0, -- 513
		wheelR = 0, -- 513
		handleOffset = 0, -- 513
		clothSide = 1 -- 513
	}, -- 513
	spawns = {{x = 120, y = 0, h = 64, label = "小满 120"}}, -- 514
	marks = {{x = 1450, y = 0, kind = 0, label = "林边安全点 1450"}, {x = 620, y = 0, kind = 3, label = "矮台 620"}}, -- 515
	dims = {{x0 = 700, x1 = 790, text = "草 90"}, {x0 = 1400, x1 = 1470, text = "林边 70"}}, -- 519
	story = {dog = {x0 = 620, x1 = 780, speed = 56, range = 300}} -- 523
} -- 523
--- 塔门与尾声：小满走到门前，按一次 E 敲两下；守卫开门接过针套和纸条，
-- 在登记簿里给下一个人留出一行空白。片尾可以再玩。
____exports.TOWER_ROOM = { -- 530
	key = "tower", -- 531
	originX = 0, -- 532
	name = "北塔塔门 · 尾声", -- 533
	caption = "走到门前点一次 E 敲两下；递出针套和纸条，看登记簿空行，片尾可再玩", -- 534
	minX = 0, -- 535
	maxX = 720, -- 536
	height = 220, -- 537
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 538
	solids = {{ -- 539
		x = 180, -- 540
		w = 220, -- 540
		h = 200, -- 540
		y = 0, -- 540
		label = "塔身 180–400" -- 540
	}, { -- 540
		x = 490, -- 541
		w = 230, -- 541
		h = 200, -- 541
		y = 0, -- 541
		label = "塔身 490–720" -- 541
	}, { -- 541
		x = 400, -- 542
		w = 90, -- 542
		h = 30, -- 542
		y = 110, -- 542
		label = "门楣 400–490" -- 542
	}}, -- 542
	zones = {{ -- 544
		x0 = 400, -- 545
		x1 = 490, -- 545
		y = 0, -- 545
		h = 8, -- 545
		tint = 4, -- 545
		label = "门廊 400–490" -- 545
	}}, -- 545
	arch = { -- 547
		x0 = 0, -- 547
		x1 = 0, -- 547
		y = 0, -- 547
		h = 0, -- 547
		label = "" -- 547
	}, -- 547
	stairs = {}, -- 548
	cart = { -- 549
		startX = 0, -- 549
		endX = 0, -- 549
		baseY = 0, -- 549
		bodyW = 0, -- 549
		bodyH = 0, -- 549
		wheelR = 0, -- 549
		handleOffset = 0, -- 549
		clothSide = 1 -- 549
	}, -- 549
	spawns = {{x = 418, y = 0, h = 64, label = "小满 418 · 门廊里"}}, -- 550
	marks = {{x = 445, y = 0, kind = 1, label = "门前 445"}}, -- 551
	dims = {{x0 = 400, x1 = 490, text = "门 90"}}, -- 554
	story = {tower = {doorX = 445, knockTicks = 36}} -- 557
} -- 557
____exports.ROOMS = { -- 560
	____exports.PROLOGUE_ROOM, -- 560
	____exports.STREET_ROOM, -- 560
	____exports.CHECKPOINT_ROOM, -- 560
	____exports.GATE_ROOM, -- 560
	____exports.OUTSIDE_ROOM, -- 560
	____exports.VILLAGE_ROOM, -- 560
	____exports.FOREST_ROOM, -- 560
	____exports.TOWER_ROOM -- 560
} -- 560
local function placeSolids(room) -- 571
	local blocks = {} -- 572
	for ____, solid in ipairs(room.solids) do -- 573
		local x = solid.x + room.originX -- 574
		if room.depth ~= nil and solid.lanes ~= nil then -- 574
			for ____, depth in ipairs(laneFootprints(solid.lanes)) do -- 576
				blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x, depth = depth, lanes = nil}) -- 577
			end -- 577
		else -- 577
			blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x}) -- 580
		end -- 580
	end -- 580
	return blocks -- 583
end -- 571
--- 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
-- 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
function ____exports.withOrigin(room) -- 590
	local ox = room.originX -- 591
	if ox == 0 then -- 591
		return room.depth == nil and room or __TS__ObjectAssign( -- 593
			{}, -- 593
			room, -- 593
			{solids = placeSolids(room)} -- 593
		) -- 593
	end -- 593
	local function shift(x) -- 595
		return x + ox -- 595
	end -- 595
	local ____room_key_5 = room.key -- 597
	local ____room_name_6 = room.name -- 598
	local ____room_caption_7 = room.caption -- 599
	local ____shift_result_8 = shift(room.minX) -- 601
	local ____shift_result_9 = shift(room.maxX) -- 602
	local ____room_height_10 = room.height -- 603
	local ____room_depth_11 = room.depth -- 604
	local ____TS__ArrayMap_result_12 = __TS__ArrayMap( -- 605
		room.floors, -- 605
		function(____, f) return { -- 605
			y = f.y, -- 605
			x0 = shift(f.x0), -- 605
			x1 = shift(f.x1) -- 605
		} end -- 605
	) -- 605
	local ____placeSolids_result_13 = placeSolids(room) -- 606
	local ____TS__ArrayMap_result_14 = __TS__ArrayMap( -- 607
		room.zones, -- 607
		function(____, z) return { -- 607
			x0 = shift(z.x0), -- 607
			x1 = shift(z.x1), -- 607
			y = z.y, -- 607
			h = z.h, -- 607
			tint = z.tint, -- 607
			label = z.label -- 607
		} end -- 607
	) -- 607
	local ____temp_15 = { -- 608
		x0 = shift(room.arch.x0), -- 608
		x1 = shift(room.arch.x1), -- 608
		y = room.arch.y, -- 608
		h = room.arch.h, -- 608
		label = room.arch.label -- 608
	} -- 608
	local ____TS__ArrayMap_result_16 = __TS__ArrayMap( -- 609
		room.stairs, -- 609
		function(____, s) return { -- 609
			x0 = shift(s.x0), -- 609
			x1 = shift(s.x1), -- 609
			y0 = s.y0, -- 609
			y1 = s.y1, -- 609
			steps = s.steps, -- 609
			label = s.label -- 609
		} end -- 609
	) -- 609
	local ____TS__ObjectAssign_result_17 = __TS__ObjectAssign( -- 610
		{}, -- 610
		room.cart, -- 611
		{ -- 610
			startX = shift(room.cart.startX), -- 612
			endX = shift(room.cart.endX) -- 613
		} -- 613
	) -- 613
	local ____TS__ArrayMap_result_18 = __TS__ArrayMap( -- 615
		room.spawns, -- 615
		function(____, s) return __TS__ObjectAssign( -- 615
			{}, -- 615
			s, -- 615
			{x = shift(s.x)} -- 615
		) end -- 615
	) -- 615
	local ____TS__ArrayMap_result_19 = __TS__ArrayMap( -- 616
		room.marks, -- 616
		function(____, m) return { -- 616
			x = shift(m.x), -- 616
			y = m.y, -- 616
			kind = m.kind, -- 616
			label = m.label -- 616
		} end -- 616
	) -- 616
	local ____TS__ArrayMap_result_20 = __TS__ArrayMap( -- 617
		room.dims, -- 617
		function(____, d) return { -- 617
			x0 = shift(d.x0), -- 617
			x1 = shift(d.x1), -- 617
			text = d.text -- 617
		} end -- 617
	) -- 617
	local ____temp_0 -- 618
	if room.scavenger == nil then -- 618
		____temp_0 = nil -- 618
	else -- 618
		____temp_0 = { -- 618
			x0 = shift(room.scavenger.x0), -- 619
			x1 = shift(room.scavenger.x1), -- 619
			y = room.scavenger.y, -- 619
			h = room.scavenger.h, -- 619
			patrolSpeed = room.scavenger.patrolSpeed, -- 620
			approachSpeed = room.scavenger.approachSpeed, -- 620
			hearTicks = room.scavenger.hearTicks, -- 621
			stallTicks = room.scavenger.stallTicks, -- 621
			range = room.scavenger.range -- 621
		} -- 621
	end -- 621
	local ____temp_1 -- 623
	if room.bottle == nil then -- 623
		____temp_1 = nil -- 623
	else -- 623
		____temp_1 = { -- 623
			x = shift(room.bottle.x), -- 623
			y = room.bottle.y -- 623
		} -- 623
	end -- 623
	local ____temp_2 -- 624
	if room.brickX == nil then -- 624
		____temp_2 = nil -- 624
	else -- 624
		____temp_2 = shift(room.brickX) -- 624
	end -- 624
	local ____temp_3 -- 625
	if room.softX == nil then -- 625
		____temp_3 = nil -- 625
	else -- 625
		____temp_3 = shift(room.softX) -- 625
	end -- 625
	local ____temp_4 -- 626
	if room.passLine == nil then -- 626
		____temp_4 = nil -- 626
	else -- 626
		____temp_4 = shift(room.passLine) -- 626
	end -- 626
	return { -- 596
		key = ____room_key_5, -- 597
		name = ____room_name_6, -- 598
		caption = ____room_caption_7, -- 599
		originX = 0, -- 600
		minX = ____shift_result_8, -- 601
		maxX = ____shift_result_9, -- 602
		height = ____room_height_10, -- 603
		depth = ____room_depth_11, -- 604
		floors = ____TS__ArrayMap_result_12, -- 605
		solids = ____placeSolids_result_13, -- 606
		zones = ____TS__ArrayMap_result_14, -- 607
		arch = ____temp_15, -- 608
		stairs = ____TS__ArrayMap_result_16, -- 609
		cart = ____TS__ObjectAssign_result_17, -- 610
		spawns = ____TS__ArrayMap_result_18, -- 615
		marks = ____TS__ArrayMap_result_19, -- 616
		dims = ____TS__ArrayMap_result_20, -- 617
		scavenger = ____temp_0, -- 618
		bottle = ____temp_1, -- 623
		brickX = ____temp_2, -- 624
		softX = ____temp_3, -- 625
		passLine = ____temp_4, -- 626
		story = shiftStory(room.story, ox) -- 627
	} -- 627
end -- 590
return ____exports -- 590