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
____exports.CHECKPOINT_ROOM = { -- 254
	key = "checkpoint", -- 255
	name = "检查站 · 候检区 640 + 原段 1000", -- 256
	caption = "先翻过队栏进候检区，再带小满走到柜台与安全点；末段按住 E + D 推车 128 单位入窝", -- 257
	originX = 640, -- 259
	minX = -640, -- 260
	maxX = 1000, -- 261
	height = 210, -- 262
	depth = LANE_ROAD, -- 263
	floors = {{y = 0, x0 = -640, x1 = 1000}}, -- 264
	solids = {{ -- 265
		x = -430, -- 267
		w = 180, -- 267
		h = 28, -- 267
		y = 0, -- 267
		label = "队栏 -430–-250 · 高 28", -- 267
		lanes = {"lower", "middle"} -- 267
	}, { -- 267
		x = 240, -- 269
		w = 100, -- 269
		h = 44, -- 269
		y = 0, -- 269
		label = "柜台 240–340 · 高 44", -- 269
		lanes = {"lower", "middle"} -- 269
	}, { -- 269
		x = 890, -- 270
		w = 36, -- 270
		h = 122, -- 270
		y = 0, -- 270
		label = "检查站出口门柱", -- 270
		lanes = {"lower", "upper"}, -- 270
		art = "gate_post" -- 270
	}}, -- 270
	zones = {{ -- 272
		x0 = 380, -- 272
		x1 = 560, -- 272
		y = 0, -- 272
		h = 120, -- 272
		tint = 1, -- 272
		label = "危险段 380–560" -- 272
	}}, -- 272
	arch = { -- 273
		x0 = 0, -- 273
		x1 = 0, -- 273
		y = 0, -- 273
		h = 0, -- 273
		label = "" -- 273
	}, -- 273
	stairs = {}, -- 274
	cart = { -- 275
		startX = 640, -- 276
		endX = 768, -- 277
		baseY = 0, -- 278
		depth = LANE_DEPTH.middle, -- 279
		bodyW = 48, -- 280
		bodyH = 26, -- 281
		wheelR = 12, -- 282
		handleOffset = -40, -- 283
		clothSide = -1 -- 284
	}, -- 284
	spawns = {{x = -600, y = 0, h = 64, label = "小满 -600（世界 40）"}, {x = -560, y = 0, h = 88, label = "周戍 -560（世界 80）"}}, -- 286
	marks = {{x = 264, y = 0, kind = 1, label = "安全锚 264"}, {x = 768, y = 0, kind = 1, label = "dock 768"}, {x = 860, y = 0, kind = 2, label = "双人出口 792–928"}}, -- 290
	dims = {{x0 = 240, x1 = 340, text = "柜台 100"}, {x0 = 640, x1 = 768, text = "推车 128 · 左柄 E+D"}, {x0 = 792, x1 = 928, text = "出口 136"}} -- 295
} -- 295
--- 城外：同一剖面里同时看上层手柄与下层拱口，这是 D1 要交的那张图。
____exports.OUTSIDE_ROOM = { -- 303
	key = "outside", -- 304
	name = "城外 · 台面 y=96 / 墙根 1240", -- 305
	caption = "从右柄按住 E+D 朝空窝拉 128 单位，轮子落窝后沿台面回左端跳下，蹲过 44 高的拱；洞后墙根小路走到底可看见塔灯", -- 306
	originX = 0, -- 308
	minX = 0, -- 309
	maxX = 1240, -- 310
	height = 230, -- 311
	floors = {{y = 0, x0 = 0, x1 = 1240}, {y = 96, x0 = 128, x1 = 512}, {y = 64, x0 = 820, x1 = 940}}, -- 312
	solids = {{ -- 317
		x = 512, -- 319
		w = 88, -- 319
		h = 134, -- 319
		y = 96, -- 319
		label = "台面右端城墙 · 下层可通" -- 319
	}, { -- 319
		x = 0, -- 320
		w = 40, -- 320
		h = 96, -- 320
		y = 0, -- 320
		label = "街口" -- 320
	}, { -- 320
		x = 1200, -- 321
		w = 40, -- 321
		h = 140, -- 321
		y = 0, -- 321
		label = "墙根尽头" -- 321
	}}, -- 321
	zones = {}, -- 323
	arch = { -- 324
		x0 = 280, -- 324
		x1 = 360, -- 324
		y = 0, -- 324
		h = 44, -- 324
		label = "拱 280–360 · 净高 44" -- 324
	}, -- 324
	stairs = {{ -- 325
		x0 = 40, -- 326
		x1 = 128, -- 326
		y0 = 0, -- 326
		y1 = 96, -- 326
		steps = 2, -- 326
		label = "石阶 0 / 48 / 96" -- 326
	}, { -- 326
		x0 = 700, -- 327
		x1 = 820, -- 327
		y0 = 0, -- 327
		y1 = 64, -- 327
		steps = 3, -- 327
		label = "墙根石阶 0 / 16 / 32 / 48 / 64" -- 327
	}}, -- 327
	cart = { -- 329
		startX = 304, -- 330
		endX = 432, -- 331
		baseY = 96, -- 332
		bodyW = 48, -- 333
		bodyH = 26, -- 334
		wheelR = 12, -- 335
		handleOffset = 40, -- 336
		clothSide = -1 -- 337
	}, -- 337
	spawns = {{x = 160, y = 96, h = 64, label = "小满 160"}}, -- 339
	marks = { -- 340
		{x = 432, y = 96, kind = 1, label = "空窝 432"}, -- 341
		{x = 380, y = 0, kind = 0, label = "洞后检查点 380"}, -- 342
		{x = 520, y = 96, kind = 3, label = "石阶光 · 回首红布"}, -- 343
		{x = 820, y = 64, kind = 3, label = "墙根石阶顶 820"}, -- 344
		{x = 1120, y = 64, kind = 6, label = "塔灯 1120"} -- 345
	}, -- 345
	dims = {{x0 = 304, x1 = 432, text = "拉车 128 · 右柄 E+D"}, {x0 = 128, x1 = 512, text = "台面 384"}, {x0 = 280, x1 = 360, text = "拱 80"}, {x0 = 600, x1 = 1240, text = "墙根 640"}} -- 347
} -- 347
--- 村口：瓶架 112、观察位 160、桌下 304–416（净高 44）、第一院通行线 440、
-- 软土 272（D5 完整）、砖地 608、拾荒者巡逻 464–512。
-- 小满脚底中心 290 起必须蹲，超过 430 才站起；160→440 约 2.63 秒。
____exports.VILLAGE_ROOM = { -- 360
	key = "village", -- 361
	originX = 0, -- 362
	name = "村口 · 架、桌、砖地", -- 363
	caption = "点 E 拾瓶，按住 F 瞄，松手投；砖地一响，拾荒者转身，趁他走开钻过桌下", -- 364
	minX = 0, -- 365
	maxX = 720, -- 366
	height = 200, -- 367
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 368
	solids = {{ -- 369
		x = 96, -- 370
		w = 32, -- 370
		h = 64, -- 370
		y = 0, -- 370
		label = "瓶架" -- 370
	}, { -- 370
		x = 672, -- 372
		w = 48, -- 372
		h = 96, -- 372
		y = 0, -- 372
		label = "院墙" -- 372
	}}, -- 372
	zones = {{ -- 374
		x0 = 256, -- 375
		x1 = 288, -- 375
		y = 0, -- 375
		h = 6, -- 375
		tint = 2, -- 375
		label = "软土 272" -- 375
	}, { -- 375
		x0 = 440, -- 376
		x1 = 448, -- 376
		y = 0, -- 376
		h = 120, -- 376
		tint = 4, -- 376
		label = "通行线 440" -- 376
	}, { -- 376
		x0 = 592, -- 377
		x1 = 624, -- 377
		y = 0, -- 377
		h = 6, -- 377
		tint = 3, -- 377
		label = "砖地 608" -- 377
	}}, -- 377
	arch = { -- 379
		x0 = 304, -- 379
		x1 = 416, -- 379
		y = 0, -- 379
		h = 44, -- 379
		label = "桌下 304–416 · 净高 44" -- 379
	}, -- 379
	stairs = {}, -- 380
	cart = { -- 381
		startX = 0, -- 381
		endX = 0, -- 381
		baseY = 0, -- 381
		bodyW = 0, -- 381
		bodyH = 0, -- 381
		wheelR = 0, -- 381
		handleOffset = 0, -- 381
		clothSide = 1 -- 381
	}, -- 381
	spawns = {{x = 160, y = 0, h = 64, label = "小满 160"}}, -- 382
	marks = {{x = 608, y = 0, kind = 5, label = "砖地落点 608"}, {x = 440, y = 0, kind = 4, label = "通行线 440"}}, -- 383
	dims = {{x0 = 96, x1 = 128, text = "瓶架"}, {x0 = 304, x1 = 416, text = "桌下 112"}, {x0 = 464, x1 = 512, text = "巡逻 48"}}, -- 387
	scavenger = { -- 392
		x0 = 464, -- 393
		x1 = 512, -- 394
		y = 0, -- 395
		h = 56, -- 396
		patrolSpeed = 40, -- 397
		approachSpeed = 64, -- 398
		hearTicks = 18, -- 399
		stallTicks = 120, -- 400
		range = 480 -- 401
	}, -- 401
	bottle = {x = 112, y = 48}, -- 403
	brickX = 608, -- 404
	softX = 272, -- 405
	passLine = 440 -- 406
} -- 406
--- 剧本锚点跟着 originX 一起搬，判定仍读世界坐标。
local function shiftStory(story, ox) -- 410
	if story == nil then -- 410
		return nil -- 412
	end -- 412
	if ox == 0 then -- 412
		return story -- 415
	end -- 415
	local out = {} -- 417
	if story.prologue ~= nil then -- 417
		out.prologue = {giveReach = story.prologue.giveReach} -- 419
	end -- 419
	if story.gate ~= nil then -- 419
		out.gate = { -- 422
			winchX = story.gate.winchX + ox, -- 423
			waitX = story.gate.waitX + ox, -- 424
			doorX = story.gate.doorX + ox, -- 425
			exitX = story.gate.exitX + ox, -- 426
			holdTicks = story.gate.holdTicks -- 427
		} -- 427
	end -- 427
	if story.dog ~= nil then -- 427
		out.dog = {x0 = story.dog.x0 + ox, x1 = story.dog.x1 + ox, speed = story.dog.speed, range = story.dog.range} -- 431
	end -- 431
	if story.tower ~= nil then -- 431
		out.tower = {doorX = story.tower.doorX + ox, knockTicks = story.tower.knockTicks} -- 434
	end -- 434
	return out -- 436
end -- 410
--- 序章：周戍在废墟里找到藏在倒柜后的小满，走近点 E 递出指南针（纸条夹在针套里）。
-- 递完她开始跟随，两人一起走进街道。
____exports.PROLOGUE_ROOM = { -- 443
	key = "prologue", -- 444
	originX = 0, -- 445
	name = "序章 · 倒柜后", -- 446
	caption = "周戍持针套，小满藏在倒柜后；走近点 E 递过去，纸条塞进针套，她开始跟随", -- 447
	minX = 0, -- 448
	maxX = 720, -- 449
	height = 200, -- 450
	depth = LANE_ROAD, -- 451
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 452
	solids = {{ -- 453
		x = 152, -- 454
		w = 98, -- 454
		h = 32, -- 454
		y = 0, -- 454
		label = "倒柜 152–250 · 高 32", -- 454
		lanes = {"lower", "middle"} -- 454
	}, { -- 454
		x = 648, -- 455
		w = 30, -- 455
		h = 118, -- 455
		y = 0, -- 455
		label = "出口门柱", -- 455
		lanes = {"lower", "upper"}, -- 455
		art = "gate_post" -- 455
	}, { -- 455
		x = 110, -- 456
		w = 38, -- 456
		h = 84, -- 456
		y = 0, -- 456
		label = "石柱", -- 456
		lanes = {"lower", "middle"}, -- 456
		art = "wall" -- 456
	}}, -- 456
	zones = {}, -- 458
	arch = { -- 459
		x0 = 0, -- 459
		x1 = 0, -- 459
		y = 0, -- 459
		h = 0, -- 459
		label = "" -- 459
	}, -- 459
	stairs = {}, -- 460
	cart = { -- 461
		startX = 0, -- 461
		endX = 0, -- 461
		baseY = 0, -- 461
		bodyW = 0, -- 461
		bodyH = 0, -- 461
		wheelR = 0, -- 461
		handleOffset = 0, -- 461
		clothSide = 1 -- 461
	}, -- 461
	spawns = {{x = 80, y = 0, h = 88, label = "周戍 80"}, {x = 300, y = 0, h = 64, label = "小满 300 · 柜子后面"}}, -- 462
	marks = {{x = 300, y = 0, kind = 1, label = "柜后 300"}, {x = 660, y = 0, kind = 0, label = "门口中路 660"}}, -- 466
	dims = {{x0 = 152, x1 = 250, text = "倒柜 98"}, {x0 = 648, x1 = 678, text = "门柱 30"}}, -- 470
	story = {prologue = {giveReach = 46}} -- 474
} -- 474
--- 街道：两人已经同行，第一次交火在街心柜台后，打完把柜台敲两下算解除。
-- 一路走到检查站入口，提交进度后进入检查站。
____exports.STREET_ROOM = { -- 481
	key = "street", -- 482
	originX = 0, -- 483
	name = "街道 · 柜台与交火", -- 484
	caption = "小满跟着走；街心柜台后有两名敌兵，点鼠标射击，清掉后一起走到检查站入口", -- 485
	minX = 0, -- 486
	maxX = 1000, -- 487
	height = 210, -- 488
	depth = LANE_ROAD, -- 489
	floors = {{y = 0, x0 = 0, x1 = 1000}}, -- 490
	solids = {{ -- 491
		x = 300, -- 492
		w = 100, -- 492
		h = 44, -- 492
		y = 0, -- 492
		label = "街心柜台 300–400 · 高 44", -- 492
		lanes = {"lower", "middle"} -- 492
	}, { -- 492
		x = 620, -- 493
		w = 60, -- 493
		h = 36, -- 493
		y = 0, -- 493
		label = "街边矮墙 620", -- 493
		lanes = {"upper"} -- 493
	}, { -- 493
		x = 892, -- 494
		w = 40, -- 494
		h = 120, -- 494
		y = 0, -- 494
		label = "检查站门柱", -- 494
		lanes = {"lower", "upper"}, -- 494
		art = "gate_post" -- 494
	}}, -- 494
	zones = {}, -- 496
	arch = { -- 497
		x0 = 0, -- 497
		x1 = 0, -- 497
		y = 0, -- 497
		h = 0, -- 497
		label = "" -- 497
	}, -- 497
	stairs = {}, -- 498
	cart = { -- 499
		startX = 0, -- 499
		endX = 0, -- 499
		baseY = 0, -- 499
		bodyW = 0, -- 499
		bodyH = 0, -- 499
		wheelR = 0, -- 499
		handleOffset = 0, -- 499
		clothSide = 1 -- 499
	}, -- 499
	spawns = {{x = 100, y = 0, h = 88, label = "周戍 100"}, {x = 60, y = 0, h = 64, label = "小满 60"}}, -- 500
	marks = {{x = 900, y = 0, kind = 0, label = "检查站入口 900"}, {x = 520, y = 0, kind = 3, label = "街心 520"}}, -- 504
	dims = {{x0 = 300, x1 = 400, text = "柜台 100"}, {x0 = 900, x1 = 1000, text = "入口 100"}} -- 508
} -- 508
--- 城门：周戍把小满送到门洞等待点，自己回到绞盘；两人就位后开始 45 秒守点。
-- 守满后玩家走到门边按 E 送别，接着是数到二十与交权。
____exports.GATE_ROOM = { -- 518
	key = "gate", -- 519
	originX = 0, -- 520
	name = "城门 · 45 秒守点", -- 521
	caption = "小满到门洞 960、周戍贴住绞盘 118，两人就位开始 45 秒；守满走到门边按 E 送她", -- 522
	minX = 0, -- 523
	maxX = 1200, -- 524
	height = 240, -- 525
	depth = LANE_ROAD, -- 526
	floors = {{y = 0, x0 = 0, x1 = 1200}}, -- 527
	solids = { -- 528
		{ -- 529
			x = 40, -- 529
			w = 60, -- 529
			h = 60, -- 529
			y = 0, -- 529
			label = "绞盘 40–100 · 高 60" -- 529
		}, -- 529
		{ -- 530
			x = 520, -- 530
			w = 80, -- 530
			h = 44, -- 530
			y = 0, -- 530
			label = "街垒 520 · 高 44", -- 530
			lanes = {"middle", "upper"} -- 530
		}, -- 530
		{ -- 531
			x = 970, -- 531
			w = 34, -- 531
			h = 100, -- 531
			y = 0, -- 531
			label = "城门门柱", -- 531
			lanes = {"lower", "upper"}, -- 531
			art = "gate_post" -- 531
		}, -- 531
		{ -- 532
			x = 1040, -- 532
			w = 160, -- 532
			h = 180, -- 532
			y = 0, -- 532
			label = "门洞右墙 1040" -- 532
		}, -- 532
		{ -- 533
			x = 840, -- 533
			w = 200, -- 533
			h = 56, -- 533
			y = 160, -- 533
			label = "门楣 840–1040" -- 533
		} -- 533
	}, -- 533
	zones = {{ -- 535
		x0 = 860, -- 536
		x1 = 1000, -- 536
		y = 0, -- 536
		h = 8, -- 536
		tint = 4, -- 536
		label = "门洞 860–1000" -- 536
	}}, -- 536
	arch = { -- 538
		x0 = 0, -- 538
		x1 = 0, -- 538
		y = 0, -- 538
		h = 0, -- 538
		label = "" -- 538
	}, -- 538
	stairs = {}, -- 539
	cart = { -- 540
		startX = 0, -- 540
		endX = 0, -- 540
		baseY = 0, -- 540
		bodyW = 0, -- 540
		bodyH = 0, -- 540
		wheelR = 0, -- 540
		handleOffset = 0, -- 540
		clothSide = 1 -- 540
	}, -- 540
	spawns = {{x = 130, y = 0, h = 88, label = "周戍 130"}, {x = 150, y = 0, h = 64, label = "小满 150"}}, -- 541
	marks = {{x = 118, y = 0, kind = 1, label = "绞盘站位 118"}, {x = 960, y = 0, kind = 1, label = "门洞等待点 960"}, {x = 860, y = 0, kind = 0, label = "门边 860"}, {x = 1020, y = 0, kind = 0, label = "出门 1020"}}, -- 545
	dims = {{x0 = 40, x1 = 100, text = "绞盘 60"}, {x0 = 840, x1 = 1040, text = "门洞 200"}}, -- 551
	story = {gate = { -- 556
		winchX = 118, -- 556
		waitX = 960, -- 556
		doorX = 860, -- 556
		exitX = 1020, -- 556
		holdTicks = 2700 -- 556
	}} -- 556
} -- 556
--- 城外巷路：男主线牵手成功后的可操控起步段。
-- 
-- 侧向跟拍，两人先牵着手过一段平路（0–780），到高石阶 780–860 抬 48 后
-- 进入下一段入口（860 平台）。上背与护送试炼发生在后续段，本房只交付
-- 「交回移动」之后的同行控制。
____exports.GATE_PATH_ROOM = { -- 566
	key = "gatepath", -- 567
	originX = 0, -- 568
	name = "城外巷路 · 兄妹同行", -- 569
	caption = "牵着手沿平路往北；到高石阶前停住，下一段从这里接背上她", -- 570
	minX = 0, -- 571
	maxX = 1040, -- 572
	height = 220, -- 573
	floors = {{y = 0, x0 = 0, x1 = 1040}, {y = 48, x0 = 860, x1 = 1040}}, -- 574
	solids = {{ -- 578
		x = 0, -- 579
		w = 60, -- 579
		h = 180, -- 579
		y = 0, -- 579
		label = "城门内墙背影 0–60" -- 579
	}, { -- 579
		x = 560, -- 580
		w = 44, -- 580
		h = 28, -- 580
		y = 0, -- 580
		label = "倒石 560 · 高 28" -- 580
	}, { -- 580
		x = 1000, -- 581
		w = 40, -- 581
		h = 200, -- 581
		y = 0, -- 581
		label = "巷尾石壁 1000" -- 581
	}}, -- 581
	zones = {{ -- 583
		x0 = 860, -- 584
		x1 = 1000, -- 584
		y = 48, -- 584
		h = 6, -- 584
		tint = 4, -- 584
		label = "高石阶平台 860–1000" -- 584
	}}, -- 584
	arch = { -- 586
		x0 = 0, -- 586
		x1 = 0, -- 586
		y = 0, -- 586
		h = 0, -- 586
		label = "" -- 586
	}, -- 586
	stairs = {{ -- 587
		x0 = 780, -- 588
		x1 = 860, -- 588
		y0 = 0, -- 588
		y1 = 48, -- 588
		steps = 3, -- 588
		label = "高石阶 0 / 16 / 32 / 48" -- 588
	}}, -- 588
	cart = { -- 590
		startX = 0, -- 590
		endX = 0, -- 590
		baseY = 0, -- 590
		bodyW = 0, -- 590
		bodyH = 0, -- 590
		wheelR = 0, -- 590
		handleOffset = 0, -- 590
		clothSide = 1 -- 590
	}, -- 590
	spawns = {{x = 120, y = 0, h = 88, label = "周戍 120"}, {x = 150, y = 0, h = 64, label = "小满 150"}}, -- 591
	marks = {{x = 120, y = 0, kind = 1, label = "牵头起步 120"}, {x = 520, y = 0, kind = 3, label = "袖口红布 520"}, {x = 840, y = 0, kind = 0, label = "高石阶前 840"}, {x = 980, y = 48, kind = 0, label = "下一段入口 980"}}, -- 595
	dims = {{x0 = 0, x1 = 560, text = "平路 560"}, {x0 = 780, x1 = 860, text = "高石阶 80 · 抬 48"}, {x0 = 860, x1 = 1000, text = "平台 140"}} -- 601
} -- 601
--- 北塔森林：小满独自走。草后可以等，狗听见脚步会转耳朵、赶来、停一会儿再回线。
-- 最后一段从林缘自己选时机走到灯下门廊。
____exports.FOREST_ROOM = { -- 612
	key = "forest", -- 613
	originX = 0, -- 614
	name = "北塔森林 · 草与狗", -- 615
	caption = "狗对动静比人快：草后等、Shift 慢走、蹲着过；林缘 1450 走到灯下门廊", -- 616
	minX = 0, -- 617
	maxX = 1600, -- 618
	height = 200, -- 619
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 620
	solids = {{ -- 621
		x = 300, -- 622
		w = 80, -- 622
		h = 24, -- 622
		y = 0, -- 622
		label = "草丛 300–380 · 高 24", -- 622
		passable = true -- 622
	}, { -- 622
		x = 700, -- 623
		w = 90, -- 623
		h = 24, -- 623
		y = 0, -- 623
		label = "草丛 700–790 · 高 24", -- 623
		passable = true -- 623
	}, { -- 623
		x = 1150, -- 624
		w = 90, -- 624
		h = 24, -- 624
		y = 0, -- 624
		label = "草丛 1150–1240 · 高 24", -- 624
		passable = true -- 624
	}, { -- 624
		x = 1560, -- 625
		w = 40, -- 625
		h = 160, -- 625
		y = 0, -- 625
		label = "林缘 1560" -- 625
	}}, -- 625
	zones = {{ -- 627
		x0 = 1400, -- 628
		x1 = 1470, -- 628
		y = 0, -- 628
		h = 6, -- 628
		tint = 4, -- 628
		label = "林边 1400–1470" -- 628
	}}, -- 628
	arch = { -- 630
		x0 = 0, -- 630
		x1 = 0, -- 630
		y = 0, -- 630
		h = 0, -- 630
		label = "" -- 630
	}, -- 630
	stairs = {{ -- 631
		x0 = 520, -- 632
		x1 = 640, -- 632
		y0 = 0, -- 632
		y1 = 22, -- 632
		steps = 1, -- 632
		label = "矮台 520–640 · 高 22" -- 632
	}, { -- 632
		x0 = 980, -- 633
		x1 = 1100, -- 633
		y0 = 0, -- 633
		y1 = 22, -- 633
		steps = 1, -- 633
		label = "矮台 980–1100 · 高 22" -- 633
	}}, -- 633
	cart = { -- 635
		startX = 0, -- 635
		endX = 0, -- 635
		baseY = 0, -- 635
		bodyW = 0, -- 635
		bodyH = 0, -- 635
		wheelR = 0, -- 635
		handleOffset = 0, -- 635
		clothSide = 1 -- 635
	}, -- 635
	spawns = {{x = 120, y = 0, h = 64, label = "小满 120"}}, -- 636
	marks = {{x = 1450, y = 0, kind = 0, label = "林边安全点 1450"}, {x = 620, y = 0, kind = 3, label = "矮台 620"}}, -- 637
	dims = {{x0 = 700, x1 = 790, text = "草 90"}, {x0 = 1400, x1 = 1470, text = "林边 70"}}, -- 641
	story = {dog = {x0 = 620, x1 = 780, speed = 56, range = 300}} -- 645
} -- 645
--- 塔门与尾声：小满走到门前，按一次 E 敲两下；守卫开门接过针套和纸条，
-- 在登记簿里给下一个人留出一行空白。片尾可以再玩。
____exports.TOWER_ROOM = { -- 652
	key = "tower", -- 653
	originX = 0, -- 654
	name = "北塔塔门 · 尾声", -- 655
	caption = "走到门前点一次 E 敲两下；递出针套和纸条，看登记簿空行，片尾可再玩", -- 656
	minX = 0, -- 657
	maxX = 720, -- 658
	height = 220, -- 659
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 660
	solids = {{ -- 661
		x = 180, -- 662
		w = 220, -- 662
		h = 200, -- 662
		y = 0, -- 662
		label = "塔身 180–400" -- 662
	}, { -- 662
		x = 490, -- 663
		w = 230, -- 663
		h = 200, -- 663
		y = 0, -- 663
		label = "塔身 490–720" -- 663
	}, { -- 663
		x = 400, -- 664
		w = 90, -- 664
		h = 30, -- 664
		y = 110, -- 664
		label = "门楣 400–490" -- 664
	}}, -- 664
	zones = {{ -- 666
		x0 = 400, -- 667
		x1 = 490, -- 667
		y = 0, -- 667
		h = 8, -- 667
		tint = 4, -- 667
		label = "门廊 400–490" -- 667
	}}, -- 667
	arch = { -- 669
		x0 = 0, -- 669
		x1 = 0, -- 669
		y = 0, -- 669
		h = 0, -- 669
		label = "" -- 669
	}, -- 669
	stairs = {}, -- 670
	cart = { -- 671
		startX = 0, -- 671
		endX = 0, -- 671
		baseY = 0, -- 671
		bodyW = 0, -- 671
		bodyH = 0, -- 671
		wheelR = 0, -- 671
		handleOffset = 0, -- 671
		clothSide = 1 -- 671
	}, -- 671
	spawns = {{x = 418, y = 0, h = 64, label = "小满 418 · 门廊里"}}, -- 672
	marks = {{x = 445, y = 0, kind = 1, label = "门前 445"}}, -- 673
	dims = {{x0 = 400, x1 = 490, text = "门 90"}}, -- 676
	story = {tower = {doorX = 445, knockTicks = 36}} -- 679
} -- 679
local NO_CART = { -- 682
	startX = 0, -- 683
	endX = 0, -- 683
	baseY = 0, -- 683
	bodyW = 0, -- 683
	bodyH = 0, -- 683
	wheelR = 0, -- 683
	handleOffset = 0, -- 683
	clothSide = -1 -- 683
} -- 683
--- S1 十字街：同一个街口先教单方向火器，再让破障手从街角压近。
-- 外檐线与布行线都从这里的出口分叉；井背是退回点，窗台是可选的翻窗捷径。
____exports.S1_CROSSROAD = { -- 690
	key = "s1-crossroad", -- 691
	name = "S1 · 十字街", -- 692
	caption = "井背 → 摊后窄道 → 观察转角 → 街角压近者。薄木挡与窗台分别通向 S2 的两条线。", -- 693
	originX = 0, -- 694
	minX = 0, -- 695
	maxX = 1600, -- 696
	height = 220, -- 697
	depth = LANE_ROAD, -- 698
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 699
	solids = { -- 700
		{ -- 701
			x = 180, -- 701
			w = 88, -- 701
			h = 56, -- 701
			y = 0, -- 701
			label = "井背 180–268 · 高 56", -- 701
			lanes = {"lower"}, -- 701
			art = "cover_stone", -- 701
			id = "s1_well" -- 701
		}, -- 701
		{ -- 702
			x = 360, -- 702
			w = 160, -- 702
			h = 44, -- 702
			y = 0, -- 702
			label = "摊后柜台 360–520 · 高 44", -- 702
			lanes = {"lower", "middle"}, -- 702
			art = "cover_wood" -- 702
		}, -- 702
		{ -- 703
			x = 620, -- 703
			w = 44, -- 703
			h = 24, -- 703
			y = 0, -- 703
			label = "观察转角石基 620–664 · 高 24", -- 703
			lanes = {"lower"} -- 703
		}, -- 703
		{ -- 704
			x = 1130, -- 704
			w = 20, -- 704
			h = 120, -- 704
			y = 0, -- 704
			label = "窗柱左", -- 704
			lanes = {"lower"}, -- 704
			art = "wall" -- 704
		}, -- 704
		{ -- 705
			x = 1150, -- 705
			w = 80, -- 705
			h = 44, -- 705
			y = 0, -- 705
			label = "窗台 1150–1230 · 高 44", -- 705
			lanes = {"lower"} -- 705
		}, -- 705
		{ -- 706
			x = 1230, -- 706
			w = 20, -- 706
			h = 120, -- 706
			y = 0, -- 706
			label = "窗柱右", -- 706
			lanes = {"lower"}, -- 706
			art = "wall" -- 706
		}, -- 706
		{ -- 707
			x = 1460, -- 707
			w = 40, -- 707
			h = 140, -- 707
			y = 0, -- 707
			label = "街尾门柱", -- 707
			lanes = {"lower", "upper"}, -- 707
			art = "gate_post" -- 707
		} -- 707
	}, -- 707
	zones = {{ -- 709
		x0 = 700, -- 709
		x1 = 960, -- 709
		y = 0, -- 709
		h = 150, -- 709
		tint = 1, -- 709
		label = "街角交火 700–960" -- 709
	}}, -- 709
	arch = { -- 710
		x0 = 0, -- 710
		x1 = 0, -- 710
		y = 0, -- 710
		h = 0, -- 710
		label = "" -- 710
	}, -- 710
	stairs = {{ -- 711
		x0 = 900, -- 711
		x1 = 1040, -- 711
		y0 = 0, -- 711
		y1 = 40, -- 711
		steps = 4, -- 711
		label = "石基斜走 900–1040 · 高 40" -- 711
	}}, -- 711
	cart = NO_CART, -- 712
	spawns = {{ -- 713
		x = 760, -- 714
		y = 0, -- 714
		h = 84, -- 714
		depth = 32, -- 714
		label = "单方向火器手 760", -- 714
		kind = "gunner", -- 714
		drop = "ammo" -- 714
	}, { -- 714
		x = 880, -- 715
		y = 0, -- 715
		h = 84, -- 715
		label = "街角压近者 880", -- 715
		kind = "breaker", -- 715
		drop = "wedge" -- 715
	}}, -- 715
	marks = {{x = 220, y = 0, kind = 1, label = "井背安全点 220"}, {x = 640, y = 0, kind = 0, label = "观察转角 640"}, {x = 1190, y = 0, kind = 0, label = "窗台捷径 1190"}, {x = 1500, y = 0, kind = 0, label = "出口 1500"}}, -- 717
	dims = {{x0 = 180, x1 = 268, text = "井 88"}, {x0 = 360, x1 = 520, text = "柜台 160"}, {x0 = 900, x1 = 1040, text = "石基 140"}}, -- 723
	companion = {waitX = 220, waitDepth = -32, joinX = 900}, -- 728
	campaign = { -- 729
		chapter = "S", -- 729
		act = 1, -- 729
		budget = 210, -- 729
		goal = "reach_exit", -- 729
		next = "s2-drygoods", -- 729
		exitX = 1500, -- 729
		checkpoint = 1 -- 729
	} -- 729
} -- 729
--- S2 布行与外檐：近檐柱下短跨、可碎摊挡与转角装卸面是一条线；
-- 从染布架侧面进布行、绕柜到窗板背后放板、后仓折回是另一条线。两条线同通牌楼。
____exports.S2_DRYGOODS = { -- 736
	key = "s2-drygoods", -- 737
	name = "S2 · 布行与外檐", -- 738
	caption = "近檐：檐柱短跨、薄木摊挡、装卸面。远帘：染布架入内、绕柜、放窗板、后仓折回。两路同通牌楼。", -- 739
	originX = 1600, -- 740
	minX = 0, -- 741
	maxX = 1800, -- 742
	height = 230, -- 743
	depth = LANE_ROAD, -- 744
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 745
	pickups = {{ -- 746
		id = "s2_scrap_1", -- 747
		kind = "scrap", -- 747
		x = 520, -- 747
		y = 0, -- 747
		depth = 0, -- 747
		label = "废木料 · 薄木摊挡脚下" -- 747
	}, { -- 747
		id = "s2_scrap_2", -- 748
		kind = "scrap", -- 748
		x = 760, -- 748
		y = 0, -- 748
		depth = 0, -- 748
		label = "废木料 · 装卸面旁" -- 748
	}}, -- 748
	solids = { -- 750
		{ -- 751
			x = 100, -- 751
			w = 24, -- 751
			h = 130, -- 751
			y = 0, -- 751
			label = "檐柱 100", -- 751
			lanes = {"middle"}, -- 751
			art = "cover_wood" -- 751
		}, -- 751
		{ -- 752
			x = 240, -- 752
			w = 24, -- 752
			h = 130, -- 752
			y = 0, -- 752
			label = "檐柱 240", -- 752
			lanes = {"middle"}, -- 752
			art = "cover_wood" -- 752
		}, -- 752
		{ -- 753
			x = 460, -- 754
			w = 100, -- 754
			h = 48, -- 754
			y = 0, -- 754
			label = "薄木摊挡 460–560 · 高 48", -- 754
			lanes = {"middle", "upper"}, -- 754
			art = "thin_wood", -- 755
			id = "s2_wood", -- 755
			breakable = {kind = "thin_wood", hp = 2, wedgeHp = 1} -- 755
		}, -- 755
		{ -- 757
			x = 620, -- 757
			w = 40, -- 757
			h = 130, -- 757
			y = 0, -- 757
			label = "永久石柱 620–660", -- 757
			lanes = {"upper"}, -- 757
			art = "cover_stone" -- 757
		}, -- 757
		{ -- 758
			x = 700, -- 758
			w = 120, -- 758
			h = 32, -- 758
			y = 0, -- 758
			label = "转角装卸面 700–820 · 高 32", -- 758
			lanes = {"middle"} -- 758
		}, -- 758
		{ -- 759
			x = 340, -- 759
			w = 120, -- 759
			h = 44, -- 759
			y = 0, -- 759
			label = "布行柜台 340–460 · 高 44", -- 759
			lanes = {"upper"}, -- 759
			art = "cover_wood" -- 759
		}, -- 759
		{ -- 760
			x = 600, -- 761
			w = 80, -- 761
			h = 72, -- 761
			y = 0, -- 761
			label = "窗板背后 600–680", -- 761
			lanes = {"upper"}, -- 761
			art = "board", -- 762
			id = "s2_board", -- 762
			interact = {kind = "open_board", reach = 46} -- 762
		}, -- 762
		{ -- 764
			x = 600, -- 765
			w = 80, -- 765
			h = 40, -- 765
			y = 0, -- 765
			label = "放下的窗板 600–680", -- 765
			lanes = {"lower"}, -- 765
			art = "board", -- 766
			id = "s2_board_cover", -- 766
			soft = true -- 766
		}, -- 766
		{ -- 768
			x = 1560, -- 768
			w = 30, -- 768
			h = 150, -- 768
			y = 0, -- 768
			label = "牌楼左柱", -- 768
			lanes = {"lower", "upper"}, -- 768
			art = "gate_post" -- 768
		}, -- 768
		{ -- 769
			x = 1700, -- 769
			w = 30, -- 769
			h = 150, -- 769
			y = 0, -- 769
			label = "牌楼右柱", -- 769
			lanes = {"lower", "upper"}, -- 769
			art = "gate_post" -- 769
		} -- 769
	}, -- 769
	zones = {{ -- 771
		x0 = 640, -- 771
		x1 = 1300, -- 771
		y = 0, -- 771
		h = 150, -- 771
		tint = 1, -- 771
		label = "转角装卸面交火 700–1200" -- 771
	}}, -- 771
	arch = { -- 772
		x0 = 0, -- 772
		x1 = 0, -- 772
		y = 0, -- 772
		h = 0, -- 772
		label = "" -- 772
	}, -- 772
	stairs = {}, -- 773
	cart = NO_CART, -- 774
	spawns = {{ -- 775
		x = 940, -- 776
		y = 0, -- 776
		h = 84, -- 776
		depth = 0, -- 776
		label = "持盾手 940", -- 776
		kind = "shield", -- 776
		shieldHp = 2, -- 776
		drop = "shield" -- 776
	}, { -- 776
		x = 1060, -- 777
		y = 0, -- 777
		h = 84, -- 777
		depth = 32, -- 777
		label = "远侧火器手 1060", -- 777
		kind = "gunner", -- 777
		drop = "ammo" -- 777
	}, { -- 777
		x = 1140, -- 778
		y = 0, -- 778
		h = 84, -- 778
		depth = 0, -- 778
		label = "破障手 1140", -- 778
		kind = "breaker", -- 778
		drop = "wedge" -- 778
	}}, -- 778
	marks = {{x = 640, y = 0, kind = 1, label = "窗板后等待位 640"}, {x = 900, y = 0, kind = 0, label = "后仓汇合口 900"}, {x = 1740, y = 0, kind = 0, label = "牌楼出口 1740"}}, -- 780
	dims = {{x0 = 100, x1 = 124, text = "檐柱 24"}, {x0 = 460, x1 = 560, text = "摊挡 100"}, {x0 = 700, x1 = 820, text = "装卸面 120"}}, -- 785
	companion = {waitX = 640, waitDepth = 32, joinX = 900, followAfter = "open_board"}, -- 790
	campaign = { -- 791
		chapter = "S", -- 791
		act = 2, -- 791
		budget = 390, -- 791
		goal = "reach_exit", -- 791
		next = "s3-archway", -- 791
		exitX = 1740, -- 791
		checkpoint = 2 -- 791
	} -- 791
} -- 791
--- S3 牌楼后巷：外檐线从低处进、布行线从高处进，两条入口在墙脚汇合。
-- 装卸坡可先上去看同一堆粮袋的敌位，再退半层接小满；也可以沿墙脚直接绕。
____exports.S3_ARCHWAY = { -- 798
	key = "s3-archway", -- 799
	name = "S3 · 牌楼后巷", -- 800
	caption = "两高度入口看同一粮袋。登装卸坡看敌位再退半层接人，或沿墙脚绕走；候检门前两人停。", -- 801
	originX = 3400, -- 802
	minX = 0, -- 803
	maxX = 1400, -- 804
	height = 230, -- 805
	depth = LANE_ROAD, -- 806
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 807
	solids = { -- 808
		{ -- 809
			x = 0, -- 809
			w = 180, -- 809
			h = 32, -- 809
			y = 0, -- 809
			label = "高处进口台 0–180 · 高 32", -- 809
			lanes = {"upper"} -- 809
		}, -- 809
		{ -- 810
			x = 380, -- 810
			w = 140, -- 810
			h = 64, -- 810
			y = 0, -- 810
			label = "装卸高台 380–520 · 高 64", -- 810
			lanes = {"upper"} -- 810
		}, -- 810
		{ -- 811
			x = 560, -- 811
			w = 160, -- 811
			h = 48, -- 811
			y = 0, -- 811
			label = "粮袋堆 560–720 · 高 48", -- 811
			lanes = {"lower", "middle"} -- 811
		}, -- 811
		{ -- 812
			x = 1260, -- 812
			w = 30, -- 812
			h = 140, -- 812
			y = 0, -- 812
			label = "候检门左柱", -- 812
			lanes = {"lower", "upper"}, -- 812
			art = "gate_post" -- 812
		}, -- 812
		{ -- 813
			x = 1330, -- 813
			w = 30, -- 813
			h = 140, -- 813
			y = 0, -- 813
			label = "候检门右柱", -- 813
			lanes = {"lower", "upper"}, -- 813
			art = "gate_post" -- 813
		} -- 813
	}, -- 813
	zones = {{ -- 815
		x0 = 780, -- 815
		x1 = 1060, -- 815
		y = 0, -- 815
		h = 150, -- 815
		tint = 1, -- 815
		label = "后巷交火 780–1060" -- 815
	}}, -- 815
	arch = { -- 816
		x0 = 0, -- 816
		x1 = 0, -- 816
		y = 0, -- 816
		h = 0, -- 816
		label = "" -- 816
	}, -- 816
	stairs = {{ -- 817
		x0 = 140, -- 818
		x1 = 200, -- 818
		y0 = 0, -- 818
		y1 = 32, -- 818
		steps = 3, -- 818
		label = "进口台阶" -- 818
	}, { -- 818
		x0 = 260, -- 819
		x1 = 380, -- 819
		y0 = 0, -- 819
		y1 = 64, -- 819
		steps = 4, -- 819
		label = "装卸坡 260–380 · 高 64" -- 819
	}}, -- 819
	cart = NO_CART, -- 821
	spawns = {{ -- 822
		x = 860, -- 823
		y = 0, -- 823
		h = 84, -- 823
		depth = 32, -- 823
		label = "高处火器手 860", -- 823
		kind = "gunner", -- 823
		drop = "ammo" -- 823
	}, { -- 823
		x = 980, -- 824
		y = 0, -- 824
		h = 84, -- 824
		depth = 0, -- 824
		label = "墙脚火器手 980", -- 824
		kind = "gunner", -- 824
		drop = "ammo" -- 824
	}}, -- 824
	marks = {{x = 440, y = 0, kind = 0, label = "装卸坡观察位 440"}, {x = 620, y = 0, kind = 1, label = "粮袋后安全点 620"}, {x = 1300, y = 0, kind = 0, label = "候检门前 1300"}}, -- 826
	dims = {{x0 = 260, x1 = 380, text = "装卸坡 120"}, {x0 = 560, x1 = 720, text = "粮袋 160"}}, -- 831
	companion = {waitX = 620, waitDepth = 0, joinX = 1240}, -- 832
	campaign = { -- 833
		chapter = "S", -- 833
		act = 3, -- 833
		budget = 180, -- 833
		goal = "reach_exit", -- 833
		next = "c1-yard", -- 833
		exitX = 1320, -- 833
		checkpoint = 3 -- 833
	} -- 833
} -- 833
--- C1 候检院：侧门横闩在门背，粮棚可见但被队栏、查验台与棚柱交错挡住。
-- 绕缺口进栏，截断压近者或穿查验台后到棚口；正面看门，转到背面才抬得动闩。
____exports.C1_YARD = { -- 840
	key = "c1-yard", -- 841
	name = "C1 · 候检院", -- 842
	caption = "队栏与查验台把粮棚切成几段。绕缺口进栏，压近者会截断通路；侧门横闩要转到门背才抬得动。", -- 843
	originX = 4800, -- 844
	minX = 0, -- 845
	maxX = 1900, -- 846
	height = 240, -- 847
	depth = LANE_ROAD, -- 848
	floors = {{y = 0, x0 = 0, x1 = 1900}}, -- 849
	solids = { -- 850
		{ -- 851
			x = 280, -- 851
			w = 340, -- 851
			h = 28, -- 851
			y = 0, -- 851
			label = "候检队栏 280–620 · 高 28", -- 851
			lanes = {"lower", "middle"}, -- 851
			art = "fence" -- 851
		}, -- 851
		{ -- 852
			x = 820, -- 852
			w = 180, -- 852
			h = 44, -- 852
			y = 0, -- 852
			label = "查验台 820–1000 · 高 44", -- 852
			lanes = {"lower", "middle"} -- 852
		}, -- 852
		{ -- 853
			x = 1100, -- 853
			w = 40, -- 853
			h = 150, -- 853
			y = 0, -- 853
			label = "棚柱 1100–1140", -- 853
			lanes = {"lower", "middle"}, -- 853
			art = "cover_wood" -- 853
		}, -- 853
		{ -- 854
			x = 1240, -- 854
			w = 40, -- 854
			h = 150, -- 854
			y = 0, -- 854
			label = "棚柱 1240–1280", -- 854
			lanes = {"lower", "middle"}, -- 854
			art = "cover_wood" -- 854
		}, -- 854
		{ -- 855
			x = 1600, -- 855
			w = 160, -- 855
			h = 48, -- 855
			y = 0, -- 855
			label = "粮棚袋堆 1600–1760 · 高 48", -- 855
			lanes = {"lower", "middle"} -- 855
		}, -- 855
		{ -- 856
			x = 1780, -- 856
			w = 50, -- 856
			h = 150, -- 856
			y = 0, -- 856
			label = "侧门 1780–1830", -- 856
			lanes = {"lower", "middle"}, -- 856
			art = "wall", -- 856
			id = "c1_door" -- 856
		}, -- 856
		{ -- 857
			x = 1810, -- 858
			w = 30, -- 858
			h = 24, -- 858
			y = 40, -- 858
			label = "侧门横闩（门背）", -- 858
			lanes = {"upper"}, -- 858
			art = "latch", -- 859
			id = "c1_latch", -- 859
			interact = {kind = "raise_latch", reach = 52} -- 859
		} -- 859
	}, -- 859
	zones = {{ -- 862
		x0 = 760, -- 862
		x1 = 1080, -- 862
		y = 0, -- 862
		h = 150, -- 862
		tint = 1, -- 862
		label = "查验台截断 820–1000" -- 862
	}}, -- 862
	arch = { -- 863
		x0 = 0, -- 863
		x1 = 0, -- 863
		y = 0, -- 863
		h = 0, -- 863
		label = "" -- 863
	}, -- 863
	stairs = {}, -- 864
	cart = NO_CART, -- 865
	spawns = {{ -- 866
		x = 900, -- 867
		y = 0, -- 867
		h = 84, -- 867
		depth = 0, -- 867
		label = "截断压近者 900", -- 867
		kind = "breaker", -- 867
		drop = "wedge" -- 867
	}, { -- 867
		x = 1200, -- 868
		y = 0, -- 868
		h = 84, -- 868
		depth = 32, -- 868
		label = "棚柱后火器手 1200", -- 868
		kind = "gunner", -- 868
		drop = "ammo" -- 868
	}}, -- 868
	marks = {{x = 1000, y = 0, kind = 1, label = "查验台后等待位 1000"}, {x = 1700, y = 0, kind = 0, label = "侧门正面 1700"}, {x = 1860, y = 0, kind = 0, label = "门背出口 1860"}}, -- 870
	dims = {{x0 = 820, x1 = 1000, text = "查验台 180"}, {x0 = 1780, x1 = 1830, text = "侧门 50"}}, -- 875
	companion = {waitX = 1000, waitDepth = 0, joinX = 1700, followAfter = "raise_latch"}, -- 876
	campaign = { -- 877
		chapter = "C", -- 877
		act = 1, -- 877
		budget = 270, -- 877
		goal = "raise_latch", -- 877
		next = "c2-granary", -- 877
		exitX = 1860, -- 877
		checkpoint = 4 -- 877
	} -- 877
} -- 877
--- C2 军粮棚：粮袋安全区居中，远柱木帘与近侧车轨分列。
-- 有残盾可以在暴露轨段架起来挡一发；空手路线先绕上远柱放帘，再回来握车柄。
____exports.C2_GRANARY = { -- 884
	key = "c2-granary", -- 885
	name = "C2 · 军粮棚", -- 886
	caption = "空筐围挡、暴露轨段与远柱木帘。先绕上远柱放帘，或架残盾，再握车柄把车推入轮窝并抬连杆闩。", -- 887
	originX = 6700, -- 888
	minX = 0, -- 889
	maxX = 1800, -- 890
	height = 240, -- 891
	depth = LANE_ROAD, -- 892
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 893
	solids = { -- 894
		{ -- 895
			x = 900, -- 896
			w = 120, -- 896
			h = 44, -- 896
			y = 0, -- 896
			label = "空筐围挡 900–1020 · 高 44", -- 896
			lanes = {"lower", "middle"}, -- 896
			art = "basket_wall", -- 897
			id = "c2_basket", -- 897
			breakable = {kind = "basket_wall", hp = 2, wedgeable = false} -- 897
		}, -- 897
		{ -- 899
			x = 600, -- 899
			w = 300, -- 899
			h = 48, -- 899
			y = 0, -- 899
			label = "粮袋安全区 600–900 · 高 48", -- 899
			lanes = {"lower", "middle"} -- 899
		}, -- 899
		{ -- 900
			x = 980, -- 900
			w = 40, -- 900
			h = 24, -- 900
			y = 0, -- 900
			label = "棚口下轨台 980–1020 · 高 24", -- 900
			lanes = {"lower", "middle"} -- 900
		}, -- 900
		{ -- 901
			x = 1200, -- 902
			w = 40, -- 902
			h = 150, -- 902
			y = 0, -- 902
			label = "远柱 1200–1240 · 高 150", -- 902
			lanes = {"upper"}, -- 902
			art = "cover_wood", -- 903
			id = "c2_post", -- 903
			interact = {kind = "lower_curtain", reach = 46} -- 903
		}, -- 903
		{ -- 905
			x = 1240, -- 906
			w = 120, -- 906
			h = 120, -- 906
			y = 24, -- 906
			label = "木帘落点 1240–1360", -- 906
			lanes = {"lower", "middle"}, -- 906
			art = "curtain", -- 907
			soft = true, -- 907
			id = "c2_curtain", -- 907
			hidden = true -- 907
		}, -- 907
		{ -- 909
			x = 1560, -- 910
			w = 30, -- 910
			h = 24, -- 910
			y = 40, -- 910
			label = "连杆抬闩 1560–1590", -- 910
			lanes = {"middle"}, -- 910
			art = "latch", -- 911
			id = "c2_latch", -- 911
			interact = {kind = "raise_latch", reach = 50} -- 911
		}, -- 911
		{ -- 913
			x = 1720, -- 913
			w = 30, -- 913
			h = 150, -- 913
			y = 0, -- 913
			label = "棚尾门柱", -- 913
			lanes = {"lower", "upper"}, -- 913
			art = "gate_post" -- 913
		} -- 913
	}, -- 913
	zones = {{ -- 915
		x0 = 1000, -- 915
		x1 = 1200, -- 915
		y = 0, -- 915
		h = 150, -- 915
		tint = 1, -- 915
		label = "暴露轨段 1000–1200" -- 915
	}}, -- 915
	arch = { -- 916
		x0 = 0, -- 916
		x1 = 0, -- 916
		y = 0, -- 916
		h = 0, -- 916
		label = "" -- 916
	}, -- 916
	stairs = {}, -- 917
	cart = { -- 918
		startX = 1150, -- 919
		endX = 1500, -- 919
		baseY = 0, -- 919
		depth = 0, -- 919
		bodyW = 48, -- 919
		bodyH = 26, -- 919
		wheelR = 12, -- 919
		handleOffset = -50, -- 919
		clothSide = -1 -- 919
	}, -- 919
	spawns = {{ -- 921
		x = 1580, -- 922
		y = 0, -- 922
		h = 84, -- 922
		depth = 0, -- 922
		label = "棚尾火器手 1580", -- 922
		kind = "gunner", -- 922
		drop = "ammo" -- 922
	}, { -- 922
		x = 1340, -- 923
		y = 0, -- 923
		h = 84, -- 923
		depth = 32, -- 923
		label = "远侧持盾手 1340", -- 923
		kind = "shield", -- 923
		shieldHp = 2, -- 923
		drop = "shield" -- 923
	}}, -- 923
	marks = {{x = 760, y = 0, kind = 1, label = "袋堆后等待位 760"}, {x = 1100, y = 0, kind = 0, label = "车柄 1100"}, {x = 1500, y = 0, kind = 0, label = "轮窝 1500"}, {x = 1700, y = 0, kind = 0, label = "棚尾出口 1700"}}, -- 925
	dims = {{x0 = 1150, x1 = 1500, text = "推车 350"}, {x0 = 1240, x1 = 1360, text = "木帘 120"}}, -- 931
	companion = {waitX = 760, waitDepth = 0, joinX = 1700}, -- 932
	campaign = { -- 933
		chapter = "C", -- 933
		act = 2, -- 933
		budget = 360, -- 933
		goal = "dock_cart", -- 933
		exitX = 1700, -- 933
		checkpoint = 5 -- 933
	} -- 933
} -- 933
____exports.CAMPAIGN_ROOMS = { -- 936
	____exports.S1_CROSSROAD, -- 936
	____exports.S2_DRYGOODS, -- 936
	____exports.S3_ARCHWAY, -- 936
	____exports.C1_YARD, -- 936
	____exports.C2_GRANARY -- 936
} -- 936
____exports.ROOMS = { -- 944
	____exports.PROLOGUE_ROOM, -- 944
	____exports.STREET_ROOM, -- 944
	____exports.CHECKPOINT_ROOM, -- 944
	____exports.GATE_ROOM, -- 944
	____exports.GATE_PATH_ROOM, -- 944
	____exports.OUTSIDE_ROOM, -- 944
	____exports.VILLAGE_ROOM, -- 944
	____exports.FOREST_ROOM, -- 944
	____exports.TOWER_ROOM -- 944
} -- 944
local function placeSolids(room) -- 956
	local blocks = {} -- 957
	for ____, solid in ipairs(room.solids) do -- 958
		local x = solid.x + room.originX -- 959
		if room.depth ~= nil and solid.lanes ~= nil then -- 959
			for ____, depth in ipairs(laneFootprints(solid.lanes)) do -- 961
				blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x, depth = depth, lanes = nil}) -- 962
			end -- 962
		else -- 962
			blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x}) -- 965
		end -- 965
	end -- 965
	return blocks -- 968
end -- 956
--- 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
-- 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
function ____exports.withOrigin(room) -- 975
	local ox = room.originX -- 976
	if ox == 0 then -- 976
		return room.depth == nil and room or __TS__ObjectAssign( -- 978
			{}, -- 978
			room, -- 978
			{solids = placeSolids(room)} -- 978
		) -- 978
	end -- 978
	local function shift(x) -- 980
		return x + ox -- 980
	end -- 980
	local ____room_key_7 = room.key -- 982
	local ____room_name_8 = room.name -- 983
	local ____room_caption_9 = room.caption -- 984
	local ____shift_result_10 = shift(room.minX) -- 986
	local ____shift_result_11 = shift(room.maxX) -- 987
	local ____room_height_12 = room.height -- 988
	local ____room_depth_13 = room.depth -- 989
	local ____TS__ArrayMap_result_14 = __TS__ArrayMap( -- 990
		room.floors, -- 990
		function(____, f) return { -- 990
			y = f.y, -- 990
			x0 = shift(f.x0), -- 990
			x1 = shift(f.x1) -- 990
		} end -- 990
	) -- 990
	local ____placeSolids_result_15 = placeSolids(room) -- 991
	local ____TS__ArrayMap_result_16 = __TS__ArrayMap( -- 992
		room.zones, -- 992
		function(____, z) return { -- 992
			x0 = shift(z.x0), -- 992
			x1 = shift(z.x1), -- 992
			y = z.y, -- 992
			h = z.h, -- 992
			tint = z.tint, -- 992
			label = z.label -- 992
		} end -- 992
	) -- 992
	local ____temp_17 = { -- 993
		x0 = shift(room.arch.x0), -- 993
		x1 = shift(room.arch.x1), -- 993
		y = room.arch.y, -- 993
		h = room.arch.h, -- 993
		label = room.arch.label -- 993
	} -- 993
	local ____TS__ArrayMap_result_18 = __TS__ArrayMap( -- 994
		room.stairs, -- 994
		function(____, s) return { -- 994
			x0 = shift(s.x0), -- 994
			x1 = shift(s.x1), -- 994
			y0 = s.y0, -- 994
			y1 = s.y1, -- 994
			steps = s.steps, -- 994
			label = s.label -- 994
		} end -- 994
	) -- 994
	local ____TS__ObjectAssign_result_19 = __TS__ObjectAssign( -- 995
		{}, -- 995
		room.cart, -- 996
		{ -- 995
			startX = shift(room.cart.startX), -- 997
			endX = shift(room.cart.endX) -- 998
		} -- 998
	) -- 998
	local ____TS__ArrayMap_result_20 = __TS__ArrayMap( -- 1000
		room.spawns, -- 1000
		function(____, s) return __TS__ObjectAssign( -- 1000
			{}, -- 1000
			s, -- 1000
			{x = shift(s.x)} -- 1000
		) end -- 1000
	) -- 1000
	local ____TS__ArrayMap_result_21 = __TS__ArrayMap( -- 1001
		room.marks, -- 1001
		function(____, m) return { -- 1001
			x = shift(m.x), -- 1001
			y = m.y, -- 1001
			kind = m.kind, -- 1001
			label = m.label -- 1001
		} end -- 1001
	) -- 1001
	local ____TS__ArrayMap_result_22 = __TS__ArrayMap( -- 1002
		room.dims, -- 1002
		function(____, d) return { -- 1002
			x0 = shift(d.x0), -- 1002
			x1 = shift(d.x1), -- 1002
			text = d.text -- 1002
		} end -- 1002
	) -- 1002
	local ____temp_0 -- 1003
	if room.scavenger == nil then -- 1003
		____temp_0 = nil -- 1003
	else -- 1003
		____temp_0 = { -- 1003
			x0 = shift(room.scavenger.x0), -- 1004
			x1 = shift(room.scavenger.x1), -- 1004
			y = room.scavenger.y, -- 1004
			h = room.scavenger.h, -- 1004
			patrolSpeed = room.scavenger.patrolSpeed, -- 1005
			approachSpeed = room.scavenger.approachSpeed, -- 1005
			hearTicks = room.scavenger.hearTicks, -- 1006
			stallTicks = room.scavenger.stallTicks, -- 1006
			range = room.scavenger.range -- 1006
		} -- 1006
	end -- 1006
	local ____temp_1 -- 1008
	if room.bottle == nil then -- 1008
		____temp_1 = nil -- 1008
	else -- 1008
		____temp_1 = { -- 1008
			x = shift(room.bottle.x), -- 1008
			y = room.bottle.y -- 1008
		} -- 1008
	end -- 1008
	local ____temp_2 -- 1009
	if room.brickX == nil then -- 1009
		____temp_2 = nil -- 1009
	else -- 1009
		____temp_2 = shift(room.brickX) -- 1009
	end -- 1009
	local ____temp_3 -- 1010
	if room.softX == nil then -- 1010
		____temp_3 = nil -- 1010
	else -- 1010
		____temp_3 = shift(room.softX) -- 1010
	end -- 1010
	local ____temp_4 -- 1011
	if room.passLine == nil then -- 1011
		____temp_4 = nil -- 1011
	else -- 1011
		____temp_4 = shift(room.passLine) -- 1011
	end -- 1011
	local ____temp_5 -- 1012
	if room.campaign == nil then -- 1012
		____temp_5 = nil -- 1012
	else -- 1012
		____temp_5 = __TS__ObjectAssign( -- 1012
			{}, -- 1012
			room.campaign, -- 1012
			{exitX = shift(room.campaign.exitX)} -- 1012
		) -- 1012
	end -- 1012
	local ____temp_6 -- 1013
	if room.pickups == nil then -- 1013
		____temp_6 = nil -- 1013
	else -- 1013
		____temp_6 = __TS__ArrayMap( -- 1013
			room.pickups, -- 1013
			function(____, p) return __TS__ObjectAssign( -- 1013
				{}, -- 1013
				p, -- 1013
				{x = shift(p.x)} -- 1013
			) end -- 1013
		) -- 1013
	end -- 1013
	return { -- 981
		key = ____room_key_7, -- 982
		name = ____room_name_8, -- 983
		caption = ____room_caption_9, -- 984
		originX = 0, -- 985
		minX = ____shift_result_10, -- 986
		maxX = ____shift_result_11, -- 987
		height = ____room_height_12, -- 988
		depth = ____room_depth_13, -- 989
		floors = ____TS__ArrayMap_result_14, -- 990
		solids = ____placeSolids_result_15, -- 991
		zones = ____TS__ArrayMap_result_16, -- 992
		arch = ____temp_17, -- 993
		stairs = ____TS__ArrayMap_result_18, -- 994
		cart = ____TS__ObjectAssign_result_19, -- 995
		spawns = ____TS__ArrayMap_result_20, -- 1000
		marks = ____TS__ArrayMap_result_21, -- 1001
		dims = ____TS__ArrayMap_result_22, -- 1002
		scavenger = ____temp_0, -- 1003
		bottle = ____temp_1, -- 1008
		brickX = ____temp_2, -- 1009
		softX = ____temp_3, -- 1010
		passLine = ____temp_4, -- 1011
		campaign = ____temp_5, -- 1012
		pickups = ____temp_6, -- 1013
		companion = room.companion, -- 1014
		story = shiftStory(room.story, ox) -- 1015
	} -- 1015
end -- 975
return ____exports -- 975