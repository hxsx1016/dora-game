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
____exports.CHECKPOINT_ROOM = { -- 266
	key = "checkpoint", -- 267
	name = "检查站 · 候检区 640 + 原段 1000", -- 268
	caption = "先翻过队栏进候检区，再带小满走到柜台与安全点；末段按住 E + D 推车 128 单位入窝", -- 269
	originX = 640, -- 271
	minX = -640, -- 272
	maxX = 1000, -- 273
	height = 210, -- 274
	depth = LANE_ROAD, -- 275
	floors = {{y = 0, x0 = -640, x1 = 1000}}, -- 276
	solids = {{ -- 277
		x = -430, -- 279
		w = 180, -- 279
		h = 28, -- 279
		y = 0, -- 279
		label = "队栏 -430–-250 · 高 28", -- 279
		lanes = {"lower", "middle"} -- 279
	}, { -- 279
		x = 240, -- 281
		w = 100, -- 281
		h = 44, -- 281
		y = 0, -- 281
		label = "柜台 240–340 · 高 44", -- 281
		lanes = {"lower", "middle"} -- 281
	}, { -- 281
		x = 890, -- 282
		w = 36, -- 282
		h = 122, -- 282
		y = 0, -- 282
		label = "检查站出口门柱", -- 282
		lanes = {"lower", "upper"}, -- 282
		art = "gate_post" -- 282
	}}, -- 282
	zones = {{ -- 284
		x0 = 380, -- 284
		x1 = 560, -- 284
		y = 0, -- 284
		h = 120, -- 284
		tint = 1, -- 284
		label = "危险段 380–560" -- 284
	}}, -- 284
	arch = { -- 285
		x0 = 0, -- 285
		x1 = 0, -- 285
		y = 0, -- 285
		h = 0, -- 285
		label = "" -- 285
	}, -- 285
	stairs = {}, -- 286
	cart = { -- 287
		startX = 640, -- 288
		endX = 768, -- 289
		baseY = 0, -- 290
		depth = LANE_DEPTH.middle, -- 291
		bodyW = 48, -- 292
		bodyH = 26, -- 293
		wheelR = 12, -- 294
		handleOffset = -40, -- 295
		clothSide = -1 -- 296
	}, -- 296
	spawns = {{x = -600, y = 0, h = 64, label = "小满 -600（世界 40）"}, {x = -560, y = 0, h = 88, label = "周戍 -560（世界 80）"}}, -- 298
	marks = {{x = 264, y = 0, kind = 1, label = "安全锚 264"}, {x = 768, y = 0, kind = 1, label = "dock 768"}, {x = 860, y = 0, kind = 2, label = "双人出口 792–928"}}, -- 302
	dims = {{x0 = 240, x1 = 340, text = "柜台 100"}, {x0 = 640, x1 = 768, text = "推车 128 · 左柄 E+D"}, {x0 = 792, x1 = 928, text = "出口 136"}} -- 307
} -- 307
--- 城外：同一剖面里同时看上层手柄与下层拱口，这是 D1 要交的那张图。
____exports.OUTSIDE_ROOM = { -- 315
	key = "outside", -- 316
	name = "城外 · 台面 y=96 / 墙根 1240", -- 317
	caption = "从右柄按住 E+D 朝空窝拉 128 单位，轮子落窝后沿台面回左端跳下，蹲过 44 高的拱；洞后墙根小路走到底可看见塔灯", -- 318
	originX = 0, -- 320
	minX = 0, -- 321
	maxX = 1240, -- 322
	height = 230, -- 323
	floors = {{y = 0, x0 = 0, x1 = 1240}, {y = 96, x0 = 128, x1 = 512}, {y = 64, x0 = 820, x1 = 940}}, -- 324
	solids = {{ -- 329
		x = 512, -- 331
		w = 88, -- 331
		h = 134, -- 331
		y = 96, -- 331
		label = "台面右端城墙 · 下层可通" -- 331
	}, { -- 331
		x = 0, -- 332
		w = 40, -- 332
		h = 96, -- 332
		y = 0, -- 332
		label = "街口" -- 332
	}, { -- 332
		x = 1200, -- 333
		w = 40, -- 333
		h = 140, -- 333
		y = 0, -- 333
		label = "墙根尽头" -- 333
	}}, -- 333
	zones = {}, -- 335
	arch = { -- 336
		x0 = 280, -- 336
		x1 = 360, -- 336
		y = 0, -- 336
		h = 44, -- 336
		label = "拱 280–360 · 净高 44" -- 336
	}, -- 336
	stairs = {{ -- 337
		x0 = 40, -- 338
		x1 = 128, -- 338
		y0 = 0, -- 338
		y1 = 96, -- 338
		steps = 2, -- 338
		label = "石阶 0 / 48 / 96" -- 338
	}, { -- 338
		x0 = 700, -- 339
		x1 = 820, -- 339
		y0 = 0, -- 339
		y1 = 64, -- 339
		steps = 3, -- 339
		label = "墙根石阶 0 / 16 / 32 / 48 / 64" -- 339
	}}, -- 339
	cart = { -- 341
		startX = 304, -- 342
		endX = 432, -- 343
		baseY = 96, -- 344
		bodyW = 48, -- 345
		bodyH = 26, -- 346
		wheelR = 12, -- 347
		handleOffset = 40, -- 348
		clothSide = -1 -- 349
	}, -- 349
	spawns = {{x = 160, y = 96, h = 64, label = "小满 160"}}, -- 351
	marks = { -- 352
		{x = 432, y = 96, kind = 1, label = "空窝 432"}, -- 353
		{x = 380, y = 0, kind = 0, label = "洞后检查点 380"}, -- 354
		{x = 520, y = 96, kind = 3, label = "石阶光 · 回首红布"}, -- 355
		{x = 820, y = 64, kind = 3, label = "墙根石阶顶 820"}, -- 356
		{x = 1120, y = 64, kind = 6, label = "塔灯 1120"} -- 357
	}, -- 357
	dims = {{x0 = 304, x1 = 432, text = "拉车 128 · 右柄 E+D"}, {x0 = 128, x1 = 512, text = "台面 384"}, {x0 = 280, x1 = 360, text = "拱 80"}, {x0 = 600, x1 = 1240, text = "墙根 640"}} -- 359
} -- 359
--- 村口：瓶架 112、观察位 160、桌下 304–416（净高 44）、第一院通行线 440、
-- 软土 272（D5 完整）、砖地 608、拾荒者巡逻 464–512。
-- 小满脚底中心 290 起必须蹲，超过 430 才站起；160→440 约 2.63 秒。
____exports.VILLAGE_ROOM = { -- 372
	key = "village", -- 373
	originX = 0, -- 374
	name = "村口 · 架、桌、砖地", -- 375
	caption = "点 E 拾瓶，按住 F 瞄，松手投；砖地一响，拾荒者转身，趁他走开钻过桌下", -- 376
	minX = 0, -- 377
	maxX = 720, -- 378
	height = 200, -- 379
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 380
	solids = {{ -- 381
		x = 96, -- 382
		w = 32, -- 382
		h = 64, -- 382
		y = 0, -- 382
		label = "瓶架" -- 382
	}, { -- 382
		x = 672, -- 384
		w = 48, -- 384
		h = 96, -- 384
		y = 0, -- 384
		label = "院墙" -- 384
	}}, -- 384
	zones = {{ -- 386
		x0 = 256, -- 387
		x1 = 288, -- 387
		y = 0, -- 387
		h = 6, -- 387
		tint = 2, -- 387
		label = "软土 272" -- 387
	}, { -- 387
		x0 = 440, -- 388
		x1 = 448, -- 388
		y = 0, -- 388
		h = 120, -- 388
		tint = 4, -- 388
		label = "通行线 440" -- 388
	}, { -- 388
		x0 = 592, -- 389
		x1 = 624, -- 389
		y = 0, -- 389
		h = 6, -- 389
		tint = 3, -- 389
		label = "砖地 608" -- 389
	}}, -- 389
	arch = { -- 391
		x0 = 304, -- 391
		x1 = 416, -- 391
		y = 0, -- 391
		h = 44, -- 391
		label = "桌下 304–416 · 净高 44" -- 391
	}, -- 391
	stairs = {}, -- 392
	cart = { -- 393
		startX = 0, -- 393
		endX = 0, -- 393
		baseY = 0, -- 393
		bodyW = 0, -- 393
		bodyH = 0, -- 393
		wheelR = 0, -- 393
		handleOffset = 0, -- 393
		clothSide = 1 -- 393
	}, -- 393
	spawns = {{x = 160, y = 0, h = 64, label = "小满 160"}}, -- 394
	marks = {{x = 608, y = 0, kind = 5, label = "砖地落点 608"}, {x = 440, y = 0, kind = 4, label = "通行线 440"}}, -- 395
	dims = {{x0 = 96, x1 = 128, text = "瓶架"}, {x0 = 304, x1 = 416, text = "桌下 112"}, {x0 = 464, x1 = 512, text = "巡逻 48"}}, -- 399
	scavenger = { -- 404
		x0 = 464, -- 405
		x1 = 512, -- 406
		y = 0, -- 407
		h = 56, -- 408
		patrolSpeed = 40, -- 409
		approachSpeed = 64, -- 410
		hearTicks = 18, -- 411
		stallTicks = 120, -- 412
		range = 480 -- 413
	}, -- 413
	bottle = {x = 112, y = 48}, -- 415
	brickX = 608, -- 416
	softX = 272, -- 417
	passLine = 440 -- 418
} -- 418
--- 剧本锚点跟着 originX 一起搬，判定仍读世界坐标。
local function shiftStory(story, ox) -- 422
	if story == nil then -- 422
		return nil -- 424
	end -- 424
	if ox == 0 then -- 424
		return story -- 427
	end -- 427
	local out = {} -- 429
	if story.prologue ~= nil then -- 429
		out.prologue = {giveReach = story.prologue.giveReach} -- 431
	end -- 431
	if story.gate ~= nil then -- 431
		out.gate = { -- 434
			winchX = story.gate.winchX + ox, -- 435
			waitX = story.gate.waitX + ox, -- 436
			doorX = story.gate.doorX + ox, -- 437
			exitX = story.gate.exitX + ox, -- 438
			holdTicks = story.gate.holdTicks -- 439
		} -- 439
	end -- 439
	if story.gatepath ~= nil then -- 439
		out.gatepath = {carryX = story.gatepath.carryX + ox, exitX = story.gatepath.exitX + ox, next = story.gatepath.next} -- 443
	end -- 443
	if story.dog ~= nil then -- 443
		out.dog = {x0 = story.dog.x0 + ox, x1 = story.dog.x1 + ox, speed = story.dog.speed, range = story.dog.range} -- 450
	end -- 450
	if story.tower ~= nil then -- 450
		out.tower = {doorX = story.tower.doorX + ox, knockTicks = story.tower.knockTicks} -- 453
	end -- 453
	return out -- 455
end -- 422
--- 序章：周戍在废墟里找到藏在倒柜后的小满，走近点 E 递出指南针（纸条夹在针套里）。
-- 递完她开始跟随，两人一起走进街道。
____exports.PROLOGUE_ROOM = { -- 462
	key = "prologue", -- 463
	originX = 0, -- 464
	name = "序章 · 倒柜后", -- 465
	caption = "周戍持针套，小满藏在倒柜后；走近点 E 递过去，纸条塞进针套，她开始跟随", -- 466
	minX = 0, -- 467
	maxX = 720, -- 468
	height = 200, -- 469
	depth = LANE_ROAD, -- 470
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 471
	solids = {{ -- 472
		x = 152, -- 473
		w = 98, -- 473
		h = 32, -- 473
		y = 0, -- 473
		label = "倒柜 152–250 · 高 32", -- 473
		lanes = {"lower", "middle"} -- 473
	}, { -- 473
		x = 648, -- 474
		w = 30, -- 474
		h = 118, -- 474
		y = 0, -- 474
		label = "出口门柱", -- 474
		lanes = {"lower", "upper"}, -- 474
		art = "gate_post" -- 474
	}, { -- 474
		x = 110, -- 475
		w = 38, -- 475
		h = 84, -- 475
		y = 0, -- 475
		label = "石柱", -- 475
		lanes = {"lower", "middle"}, -- 475
		art = "wall" -- 475
	}}, -- 475
	zones = {}, -- 477
	arch = { -- 478
		x0 = 0, -- 478
		x1 = 0, -- 478
		y = 0, -- 478
		h = 0, -- 478
		label = "" -- 478
	}, -- 478
	stairs = {}, -- 479
	cart = { -- 480
		startX = 0, -- 480
		endX = 0, -- 480
		baseY = 0, -- 480
		bodyW = 0, -- 480
		bodyH = 0, -- 480
		wheelR = 0, -- 480
		handleOffset = 0, -- 480
		clothSide = 1 -- 480
	}, -- 480
	spawns = {{x = 80, y = 0, h = 88, label = "周戍 80"}, {x = 300, y = 0, h = 64, label = "小满 300 · 柜子后面"}}, -- 481
	marks = {{x = 300, y = 0, kind = 1, label = "柜后 300"}, {x = 660, y = 0, kind = 0, label = "门口中路 660"}}, -- 485
	dims = {{x0 = 152, x1 = 250, text = "倒柜 98"}, {x0 = 648, x1 = 678, text = "门柱 30"}}, -- 489
	story = {prologue = {giveReach = 46}} -- 493
} -- 493
--- 街道：两人已经同行，第一次交火在街心柜台后，打完把柜台敲两下算解除。
-- 一路走到检查站入口，提交进度后进入检查站。
____exports.STREET_ROOM = { -- 500
	key = "street", -- 501
	originX = 0, -- 502
	name = "街道 · 柜台与交火", -- 503
	caption = "小满跟着走；街心柜台后有两名敌兵，点鼠标射击，清掉后一起走到检查站入口", -- 504
	minX = 0, -- 505
	maxX = 1000, -- 506
	height = 210, -- 507
	depth = LANE_ROAD, -- 508
	floors = {{y = 0, x0 = 0, x1 = 1000}}, -- 509
	solids = {{ -- 510
		x = 300, -- 511
		w = 100, -- 511
		h = 44, -- 511
		y = 0, -- 511
		label = "街心柜台 300–400 · 高 44", -- 511
		lanes = {"lower", "middle"} -- 511
	}, { -- 511
		x = 620, -- 512
		w = 60, -- 512
		h = 36, -- 512
		y = 0, -- 512
		label = "街边矮墙 620", -- 512
		lanes = {"upper"} -- 512
	}, { -- 512
		x = 892, -- 513
		w = 40, -- 513
		h = 120, -- 513
		y = 0, -- 513
		label = "检查站门柱", -- 513
		lanes = {"lower", "upper"}, -- 513
		art = "gate_post" -- 513
	}}, -- 513
	zones = {}, -- 515
	arch = { -- 516
		x0 = 0, -- 516
		x1 = 0, -- 516
		y = 0, -- 516
		h = 0, -- 516
		label = "" -- 516
	}, -- 516
	stairs = {}, -- 517
	cart = { -- 518
		startX = 0, -- 518
		endX = 0, -- 518
		baseY = 0, -- 518
		bodyW = 0, -- 518
		bodyH = 0, -- 518
		wheelR = 0, -- 518
		handleOffset = 0, -- 518
		clothSide = 1 -- 518
	}, -- 518
	spawns = {{x = 100, y = 0, h = 88, label = "周戍 100"}, {x = 60, y = 0, h = 64, label = "小满 60"}}, -- 519
	marks = {{x = 900, y = 0, kind = 0, label = "检查站入口 900"}, {x = 520, y = 0, kind = 3, label = "街心 520"}}, -- 523
	dims = {{x0 = 300, x1 = 400, text = "柜台 100"}, {x0 = 900, x1 = 1000, text = "入口 100"}} -- 527
} -- 527
--- 城门：周戍把小满送到门洞等待点，自己回到绞盘；两人就位后开始 45 秒守点。
-- 守满后玩家走到门边按 E 送别，接着是数到二十与交权。
____exports.GATE_ROOM = { -- 537
	key = "gate", -- 538
	originX = 0, -- 539
	name = "城门 · 45 秒守点", -- 540
	caption = "小满到门洞 960、周戍贴住绞盘 118，两人就位开始 45 秒；守满走到门边按 E 送她", -- 541
	minX = 0, -- 542
	maxX = 1200, -- 543
	height = 240, -- 544
	depth = LANE_ROAD, -- 545
	floors = {{y = 0, x0 = 0, x1 = 1200}}, -- 546
	solids = { -- 547
		{ -- 548
			x = 40, -- 548
			w = 60, -- 548
			h = 60, -- 548
			y = 0, -- 548
			label = "绞盘 40–100 · 高 60" -- 548
		}, -- 548
		{ -- 549
			x = 520, -- 549
			w = 80, -- 549
			h = 44, -- 549
			y = 0, -- 549
			label = "街垒 520 · 高 44", -- 549
			lanes = {"middle", "upper"} -- 549
		}, -- 549
		{ -- 550
			x = 970, -- 550
			w = 34, -- 550
			h = 100, -- 550
			y = 0, -- 550
			label = "城门门柱", -- 550
			lanes = {"lower", "upper"}, -- 550
			art = "gate_post" -- 550
		}, -- 550
		{ -- 551
			x = 1040, -- 551
			w = 160, -- 551
			h = 180, -- 551
			y = 0, -- 551
			label = "门洞右墙 1040" -- 551
		}, -- 551
		{ -- 552
			x = 840, -- 552
			w = 200, -- 552
			h = 56, -- 552
			y = 160, -- 552
			label = "门楣 840–1040" -- 552
		} -- 552
	}, -- 552
	zones = {{ -- 554
		x0 = 860, -- 555
		x1 = 1000, -- 555
		y = 0, -- 555
		h = 8, -- 555
		tint = 4, -- 555
		label = "门洞 860–1000" -- 555
	}}, -- 555
	arch = { -- 557
		x0 = 0, -- 557
		x1 = 0, -- 557
		y = 0, -- 557
		h = 0, -- 557
		label = "" -- 557
	}, -- 557
	stairs = {}, -- 558
	cart = { -- 559
		startX = 0, -- 559
		endX = 0, -- 559
		baseY = 0, -- 559
		bodyW = 0, -- 559
		bodyH = 0, -- 559
		wheelR = 0, -- 559
		handleOffset = 0, -- 559
		clothSide = 1 -- 559
	}, -- 559
	spawns = {{x = 130, y = 0, h = 88, label = "周戍 130"}, {x = 150, y = 0, h = 64, label = "小满 150"}}, -- 560
	marks = {{x = 118, y = 0, kind = 1, label = "绞盘站位 118"}, {x = 960, y = 0, kind = 1, label = "门洞等待点 960"}, {x = 860, y = 0, kind = 0, label = "门边 860"}, {x = 1020, y = 0, kind = 0, label = "出门 1020"}}, -- 564
	dims = {{x0 = 40, x1 = 100, text = "绞盘 60"}, {x0 = 840, x1 = 1040, text = "门洞 200"}}, -- 570
	story = {gate = { -- 575
		winchX = 118, -- 575
		waitX = 960, -- 575
		doorX = 860, -- 575
		exitX = 1020, -- 575
		holdTicks = 2700 -- 575
	}} -- 575
} -- 575
--- 城外巷路：男主线牵手成功后的可操控起步段。
-- 
-- 侧向跟拍，两人先牵着手过一段平路（0–780），到高石阶 780–860 抬 48 后
-- 进入下一段入口（860 平台）。上背与护送试炼发生在后续段，本房只交付
-- 「交回移动」之后的同行控制。
____exports.GATE_PATH_ROOM = { -- 585
	key = "gatepath", -- 586
	originX = 0, -- 587
	name = "城外巷路 · 兄妹同行", -- 588
	caption = "牵着手沿平路往北；到高石阶前停住，下一段从这里接背上她", -- 589
	minX = 0, -- 590
	maxX = 1040, -- 591
	height = 220, -- 592
	floors = {{y = 0, x0 = 0, x1 = 1040}, {y = 48, x0 = 860, x1 = 1040}}, -- 593
	solids = {{ -- 597
		x = 0, -- 598
		w = 60, -- 598
		h = 180, -- 598
		y = 0, -- 598
		label = "城门内墙背影 0–60" -- 598
	}, { -- 598
		x = 560, -- 599
		w = 44, -- 599
		h = 28, -- 599
		y = 0, -- 599
		label = "倒石 560 · 高 28" -- 599
	}, { -- 599
		x = 1000, -- 600
		w = 40, -- 600
		h = 200, -- 600
		y = 0, -- 600
		label = "巷尾石壁 1000" -- 600
	}}, -- 600
	zones = {{ -- 602
		x0 = 860, -- 603
		x1 = 1000, -- 603
		y = 48, -- 603
		h = 6, -- 603
		tint = 4, -- 603
		label = "高石阶平台 860–1000" -- 603
	}}, -- 603
	arch = { -- 605
		x0 = 0, -- 605
		x1 = 0, -- 605
		y = 0, -- 605
		h = 0, -- 605
		label = "" -- 605
	}, -- 605
	stairs = {{ -- 606
		x0 = 780, -- 607
		x1 = 860, -- 607
		y0 = 0, -- 607
		y1 = 48, -- 607
		steps = 3, -- 607
		label = "高石阶 0 / 16 / 32 / 48" -- 607
	}}, -- 607
	cart = { -- 609
		startX = 0, -- 609
		endX = 0, -- 609
		baseY = 0, -- 609
		bodyW = 0, -- 609
		bodyH = 0, -- 609
		wheelR = 0, -- 609
		handleOffset = 0, -- 609
		clothSide = 1 -- 609
	}, -- 609
	spawns = {{x = 120, y = 0, h = 88, label = "周戍 120"}, {x = 150, y = 0, h = 64, label = "小满 150"}}, -- 610
	marks = {{x = 120, y = 0, kind = 1, label = "牵头起步 120"}, {x = 520, y = 0, kind = 3, label = "袖口红布 520"}, {x = 840, y = 0, kind = 0, label = "高石阶前 840"}, {x = 980, y = 48, kind = 0, label = "下一段入口 980"}}, -- 614
	dims = {{x0 = 0, x1 = 560, text = "平路 560"}, {x0 = 780, x1 = 860, text = "高石阶 80 · 抬 48"}, {x0 = 860, x1 = 1000, text = "平台 140"}}, -- 620
	story = {gatepath = {carryX = 840, exitX = 1000, next = "escort1"}} -- 625
} -- 625
--- 北塔森林：小满独自走。草后可以等，狗听见脚步会转耳朵、赶来、停一会儿再回线。
-- 最后一段从林缘自己选时机走到灯下门廊。
____exports.FOREST_ROOM = { -- 632
	key = "forest", -- 633
	originX = 0, -- 634
	name = "北塔森林 · 草与狗", -- 635
	caption = "狗对动静比人快：草后等、Shift 慢走、蹲着过；林缘 1450 走到灯下门廊", -- 636
	minX = 0, -- 637
	maxX = 1600, -- 638
	height = 200, -- 639
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 640
	solids = {{ -- 641
		x = 300, -- 642
		w = 80, -- 642
		h = 24, -- 642
		y = 0, -- 642
		label = "草丛 300–380 · 高 24", -- 642
		passable = true -- 642
	}, { -- 642
		x = 700, -- 643
		w = 90, -- 643
		h = 24, -- 643
		y = 0, -- 643
		label = "草丛 700–790 · 高 24", -- 643
		passable = true -- 643
	}, { -- 643
		x = 1150, -- 644
		w = 90, -- 644
		h = 24, -- 644
		y = 0, -- 644
		label = "草丛 1150–1240 · 高 24", -- 644
		passable = true -- 644
	}, { -- 644
		x = 1560, -- 645
		w = 40, -- 645
		h = 160, -- 645
		y = 0, -- 645
		label = "林缘 1560" -- 645
	}}, -- 645
	zones = {{ -- 647
		x0 = 1400, -- 648
		x1 = 1470, -- 648
		y = 0, -- 648
		h = 6, -- 648
		tint = 4, -- 648
		label = "林边 1400–1470" -- 648
	}}, -- 648
	arch = { -- 650
		x0 = 0, -- 650
		x1 = 0, -- 650
		y = 0, -- 650
		h = 0, -- 650
		label = "" -- 650
	}, -- 650
	stairs = {{ -- 651
		x0 = 520, -- 652
		x1 = 640, -- 652
		y0 = 0, -- 652
		y1 = 22, -- 652
		steps = 1, -- 652
		label = "矮台 520–640 · 高 22" -- 652
	}, { -- 652
		x0 = 980, -- 653
		x1 = 1100, -- 653
		y0 = 0, -- 653
		y1 = 22, -- 653
		steps = 1, -- 653
		label = "矮台 980–1100 · 高 22" -- 653
	}}, -- 653
	cart = { -- 655
		startX = 0, -- 655
		endX = 0, -- 655
		baseY = 0, -- 655
		bodyW = 0, -- 655
		bodyH = 0, -- 655
		wheelR = 0, -- 655
		handleOffset = 0, -- 655
		clothSide = 1 -- 655
	}, -- 655
	spawns = {{x = 120, y = 0, h = 64, label = "小满 120"}}, -- 656
	marks = {{x = 1450, y = 0, kind = 0, label = "林边安全点 1450"}, {x = 620, y = 0, kind = 3, label = "矮台 620"}}, -- 657
	dims = {{x0 = 700, x1 = 790, text = "草 90"}, {x0 = 1400, x1 = 1470, text = "林边 70"}}, -- 661
	story = {dog = {x0 = 620, x1 = 780, speed = 56, range = 300}} -- 665
} -- 665
--- 塔门与尾声：小满走到门前，按一次 E 敲两下；守卫开门接过针套和纸条，
-- 在登记簿里给下一个人留出一行空白。片尾可以再玩。
____exports.TOWER_ROOM = { -- 672
	key = "tower", -- 673
	originX = 0, -- 674
	name = "北塔塔门 · 尾声", -- 675
	caption = "走到门前点一次 E 敲两下；递出针套和纸条，看登记簿空行，片尾可再玩", -- 676
	minX = 0, -- 677
	maxX = 720, -- 678
	height = 220, -- 679
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 680
	solids = {{ -- 681
		x = 180, -- 682
		w = 220, -- 682
		h = 200, -- 682
		y = 0, -- 682
		label = "塔身 180–400" -- 682
	}, { -- 682
		x = 490, -- 683
		w = 230, -- 683
		h = 200, -- 683
		y = 0, -- 683
		label = "塔身 490–720" -- 683
	}, { -- 683
		x = 400, -- 684
		w = 90, -- 684
		h = 30, -- 684
		y = 110, -- 684
		label = "门楣 400–490" -- 684
	}}, -- 684
	zones = {{ -- 686
		x0 = 400, -- 687
		x1 = 490, -- 687
		y = 0, -- 687
		h = 8, -- 687
		tint = 4, -- 687
		label = "门廊 400–490" -- 687
	}}, -- 687
	arch = { -- 689
		x0 = 0, -- 689
		x1 = 0, -- 689
		y = 0, -- 689
		h = 0, -- 689
		label = "" -- 689
	}, -- 689
	stairs = {}, -- 690
	cart = { -- 691
		startX = 0, -- 691
		endX = 0, -- 691
		baseY = 0, -- 691
		bodyW = 0, -- 691
		bodyH = 0, -- 691
		wheelR = 0, -- 691
		handleOffset = 0, -- 691
		clothSide = 1 -- 691
	}, -- 691
	spawns = {{x = 418, y = 0, h = 64, label = "小满 418 · 门廊里"}}, -- 692
	marks = {{x = 445, y = 0, kind = 1, label = "门前 445"}}, -- 693
	dims = {{x0 = 400, x1 = 490, text = "门 90"}}, -- 696
	story = {tower = {doorX = 445, knockTicks = 36}} -- 699
} -- 699
local NO_CART = { -- 702
	startX = 0, -- 703
	endX = 0, -- 703
	baseY = 0, -- 703
	bodyW = 0, -- 703
	bodyH = 0, -- 703
	wheelR = 0, -- 703
	handleOffset = 0, -- 703
	clothSide = -1 -- 703
} -- 703
--- 男主首场护送战：背着受伤的小满穿过城外巷路。
-- 巷底两名火器手与一名破障手压过来，玩家边观察边完成一次慢时连线换弹，走到巷尾脱身。
____exports.ESCORT1_ROOM = { -- 710
	key = "escort1", -- 711
	originX = 0, -- 712
	name = "城外巷路 · 第一段护送", -- 713
	caption = "背上的小满贴着肩；巷底两名火器手与一名破障手压过来，走到巷尾就算脱身", -- 714
	minX = 0, -- 715
	maxX = 1600, -- 716
	height = 220, -- 717
	depth = LANE_ROAD, -- 718
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 719
	solids = { -- 720
		{ -- 721
			x = 0, -- 721
			w = 50, -- 721
			h = 150, -- 721
			y = 0, -- 721
			label = "巷口背影 0–50" -- 721
		}, -- 721
		{ -- 722
			x = 380, -- 722
			w = 96, -- 722
			h = 44, -- 722
			y = 0, -- 722
			label = "塌墙 380–476 · 高 44", -- 722
			lanes = {"lower", "middle"}, -- 722
			art = "cover_stone", -- 722
			id = "e1_wall" -- 722
		}, -- 722
		{ -- 723
			x = 700, -- 723
			w = 40, -- 723
			h = 28, -- 723
			y = 0, -- 723
			label = "倒石 700 · 高 28", -- 723
			lanes = {"lower"} -- 723
		}, -- 723
		{ -- 724
			x = 980, -- 724
			w = 160, -- 724
			h = 52, -- 724
			y = 0, -- 724
			label = "石台 980–1140 · 高 52", -- 724
			lanes = {"lower"}, -- 724
			art = "cover_wood" -- 724
		}, -- 724
		{ -- 725
			x = 1300, -- 725
			w = 40, -- 725
			h = 140, -- 725
			y = 0, -- 725
			label = "巷尾门柱 1300", -- 725
			lanes = {"lower", "upper"}, -- 725
			art = "gate_post" -- 725
		}, -- 725
		{ -- 726
			x = 1340, -- 726
			w = 260, -- 726
			h = 180, -- 726
			y = 0, -- 726
			label = "巷尾断墙 1340–1600 · 高 180" -- 726
		} -- 726
	}, -- 726
	zones = {{ -- 728
		x0 = 560, -- 728
		x1 = 900, -- 728
		y = 0, -- 728
		h = 150, -- 728
		tint = 1, -- 728
		label = "交火 560–900" -- 728
	}}, -- 728
	arch = { -- 729
		x0 = 0, -- 729
		x1 = 0, -- 729
		y = 0, -- 729
		h = 0, -- 729
		label = "" -- 729
	}, -- 729
	stairs = {{ -- 730
		x0 = 1140, -- 730
		x1 = 1300, -- 730
		y0 = 0, -- 730
		y1 = 40, -- 730
		steps = 3, -- 730
		label = "石台斜走 1140–1300" -- 730
	}}, -- 730
	cart = NO_CART, -- 731
	spawns = {{ -- 732
		x = 820, -- 733
		y = 0, -- 733
		h = 84, -- 733
		depth = 32, -- 733
		label = "火器手 820 · 中档", -- 733
		kind = "gunner", -- 733
		drop = "ammo" -- 733
	}, { -- 733
		x = 1020, -- 734
		y = 0, -- 734
		h = 84, -- 734
		depth = -28, -- 734
		label = "火器手 1020 · 浅档", -- 734
		kind = "gunner", -- 734
		drop = "ammo" -- 734
	}, { -- 734
		x = 1120, -- 735
		y = 0, -- 735
		h = 84, -- 735
		depth = -28, -- 735
		label = "破障手 1120", -- 735
		kind = "breaker", -- 735
		drop = "wedge" -- 735
	}}, -- 735
	marks = {{x = 200, y = 0, kind = 3, label = "背负起点 200"}, {x = 476, y = 0, kind = 3, label = "塌墙后 476"}, {x = 900, y = 0, kind = 0, label = "交火尽头 900"}, {x = 1500, y = 0, kind = 0, label = "安全出口 1500"}}, -- 737
	dims = {{x0 = 380, x1 = 476, text = "塌墙 96"}, {x0 = 980, x1 = 1140, text = "石台 160"}, {x0 = 1300, x1 = 1600, text = "巷尾 300"}}, -- 743
	campaign = { -- 748
		chapter = "O", -- 748
		act = 1, -- 748
		budget = 240, -- 748
		goal = "reach_exit", -- 748
		exitX = 1500, -- 748
		next = "outside", -- 748
		checkpoint = 1 -- 748
	} -- 748
} -- 748
--- S1 十字街：同一个街口先教单方向火器，再让破障手从街角压近。
-- 外檐线与布行线都从这里的出口分叉；井背是退回点，窗台是可选的翻窗捷径。
____exports.S1_CROSSROAD = { -- 755
	key = "s1-crossroad", -- 756
	name = "S1 · 十字街", -- 757
	caption = "井背 → 摊后窄道 → 观察转角 → 街角压近者。薄木挡与窗台分别通向 S2 的两条线。", -- 758
	originX = 0, -- 759
	minX = 0, -- 760
	maxX = 1600, -- 761
	height = 220, -- 762
	depth = LANE_ROAD, -- 763
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 764
	solids = { -- 765
		{ -- 766
			x = 180, -- 766
			w = 88, -- 766
			h = 56, -- 766
			y = 0, -- 766
			label = "井背 180–268 · 高 56", -- 766
			lanes = {"lower"}, -- 766
			art = "cover_stone", -- 766
			id = "s1_well" -- 766
		}, -- 766
		{ -- 767
			x = 360, -- 767
			w = 160, -- 767
			h = 44, -- 767
			y = 0, -- 767
			label = "摊后柜台 360–520 · 高 44", -- 767
			lanes = {"lower", "middle"}, -- 767
			art = "cover_wood" -- 767
		}, -- 767
		{ -- 768
			x = 620, -- 768
			w = 44, -- 768
			h = 24, -- 768
			y = 0, -- 768
			label = "观察转角石基 620–664 · 高 24", -- 768
			lanes = {"lower"} -- 768
		}, -- 768
		{ -- 769
			x = 1130, -- 769
			w = 20, -- 769
			h = 120, -- 769
			y = 0, -- 769
			label = "窗柱左", -- 769
			lanes = {"lower"}, -- 769
			art = "wall" -- 769
		}, -- 769
		{ -- 770
			x = 1150, -- 770
			w = 80, -- 770
			h = 44, -- 770
			y = 0, -- 770
			label = "窗台 1150–1230 · 高 44", -- 770
			lanes = {"lower"} -- 770
		}, -- 770
		{ -- 771
			x = 1230, -- 771
			w = 20, -- 771
			h = 120, -- 771
			y = 0, -- 771
			label = "窗柱右", -- 771
			lanes = {"lower"}, -- 771
			art = "wall" -- 771
		}, -- 771
		{ -- 772
			x = 1460, -- 772
			w = 40, -- 772
			h = 140, -- 772
			y = 0, -- 772
			label = "街尾门柱", -- 772
			lanes = {"lower", "upper"}, -- 772
			art = "gate_post" -- 772
		} -- 772
	}, -- 772
	zones = {{ -- 774
		x0 = 700, -- 774
		x1 = 960, -- 774
		y = 0, -- 774
		h = 150, -- 774
		tint = 1, -- 774
		label = "街角交火 700–960" -- 774
	}}, -- 774
	arch = { -- 775
		x0 = 0, -- 775
		x1 = 0, -- 775
		y = 0, -- 775
		h = 0, -- 775
		label = "" -- 775
	}, -- 775
	stairs = {{ -- 776
		x0 = 900, -- 776
		x1 = 1040, -- 776
		y0 = 0, -- 776
		y1 = 40, -- 776
		steps = 4, -- 776
		label = "石基斜走 900–1040 · 高 40" -- 776
	}}, -- 776
	cart = NO_CART, -- 777
	spawns = {{ -- 778
		x = 760, -- 779
		y = 0, -- 779
		h = 84, -- 779
		depth = 32, -- 779
		label = "单方向火器手 760", -- 779
		kind = "gunner", -- 779
		drop = "ammo" -- 779
	}, { -- 779
		x = 880, -- 780
		y = 0, -- 780
		h = 84, -- 780
		label = "街角压近者 880", -- 780
		kind = "breaker", -- 780
		drop = "wedge" -- 780
	}}, -- 780
	marks = {{x = 220, y = 0, kind = 1, label = "井背安全点 220"}, {x = 640, y = 0, kind = 0, label = "观察转角 640"}, {x = 1190, y = 0, kind = 0, label = "窗台捷径 1190"}, {x = 1500, y = 0, kind = 0, label = "出口 1500"}}, -- 782
	dims = {{x0 = 180, x1 = 268, text = "井 88"}, {x0 = 360, x1 = 520, text = "柜台 160"}, {x0 = 900, x1 = 1040, text = "石基 140"}}, -- 788
	companion = {waitX = 220, waitDepth = -32, joinX = 900}, -- 793
	campaign = { -- 794
		chapter = "S", -- 794
		act = 1, -- 794
		budget = 210, -- 794
		goal = "reach_exit", -- 794
		next = "s2-drygoods", -- 794
		exitX = 1500, -- 794
		checkpoint = 1 -- 794
	} -- 794
} -- 794
--- S2 布行与外檐：近檐柱下短跨、可碎摊挡与转角装卸面是一条线；
-- 从染布架侧面进布行、绕柜到窗板背后放板、后仓折回是另一条线。两条线同通牌楼。
____exports.S2_DRYGOODS = { -- 801
	key = "s2-drygoods", -- 802
	name = "S2 · 布行与外檐", -- 803
	caption = "近檐：檐柱短跨、薄木摊挡、装卸面。远帘：染布架入内、绕柜、放窗板、后仓折回。两路同通牌楼。", -- 804
	originX = 1600, -- 805
	minX = 0, -- 806
	maxX = 1800, -- 807
	height = 230, -- 808
	depth = LANE_ROAD, -- 809
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 810
	pickups = {{ -- 811
		id = "s2_scrap_1", -- 812
		kind = "scrap", -- 812
		x = 520, -- 812
		y = 0, -- 812
		depth = 0, -- 812
		label = "废木料 · 薄木摊挡脚下" -- 812
	}, { -- 812
		id = "s2_scrap_2", -- 813
		kind = "scrap", -- 813
		x = 760, -- 813
		y = 0, -- 813
		depth = 0, -- 813
		label = "废木料 · 装卸面旁" -- 813
	}}, -- 813
	solids = { -- 815
		{ -- 816
			x = 100, -- 816
			w = 24, -- 816
			h = 130, -- 816
			y = 0, -- 816
			label = "檐柱 100", -- 816
			lanes = {"middle"}, -- 816
			art = "cover_wood" -- 816
		}, -- 816
		{ -- 817
			x = 240, -- 817
			w = 24, -- 817
			h = 130, -- 817
			y = 0, -- 817
			label = "檐柱 240", -- 817
			lanes = {"middle"}, -- 817
			art = "cover_wood" -- 817
		}, -- 817
		{ -- 818
			x = 460, -- 819
			w = 100, -- 819
			h = 48, -- 819
			y = 0, -- 819
			label = "薄木摊挡 460–560 · 高 48", -- 819
			lanes = {"middle", "upper"}, -- 819
			art = "thin_wood", -- 820
			id = "s2_wood", -- 820
			breakable = {kind = "thin_wood", hp = 2, wedgeHp = 1} -- 820
		}, -- 820
		{ -- 822
			x = 620, -- 822
			w = 40, -- 822
			h = 130, -- 822
			y = 0, -- 822
			label = "永久石柱 620–660", -- 822
			lanes = {"upper"}, -- 822
			art = "cover_stone" -- 822
		}, -- 822
		{ -- 823
			x = 700, -- 823
			w = 120, -- 823
			h = 32, -- 823
			y = 0, -- 823
			label = "转角装卸面 700–820 · 高 32", -- 823
			lanes = {"middle"} -- 823
		}, -- 823
		{ -- 824
			x = 340, -- 824
			w = 120, -- 824
			h = 44, -- 824
			y = 0, -- 824
			label = "布行柜台 340–460 · 高 44", -- 824
			lanes = {"upper"}, -- 824
			art = "cover_wood" -- 824
		}, -- 824
		{ -- 825
			x = 600, -- 826
			w = 80, -- 826
			h = 72, -- 826
			y = 0, -- 826
			label = "窗板背后 600–680", -- 826
			lanes = {"upper"}, -- 826
			art = "board", -- 827
			id = "s2_board", -- 827
			interact = {kind = "open_board", reach = 46} -- 827
		}, -- 827
		{ -- 829
			x = 600, -- 830
			w = 80, -- 830
			h = 40, -- 830
			y = 0, -- 830
			label = "放下的窗板 600–680", -- 830
			lanes = {"lower"}, -- 830
			art = "board", -- 831
			id = "s2_board_cover", -- 831
			soft = true -- 831
		}, -- 831
		{ -- 833
			x = 1560, -- 833
			w = 30, -- 833
			h = 150, -- 833
			y = 0, -- 833
			label = "牌楼左柱", -- 833
			lanes = {"lower", "upper"}, -- 833
			art = "gate_post" -- 833
		}, -- 833
		{ -- 834
			x = 1700, -- 834
			w = 30, -- 834
			h = 150, -- 834
			y = 0, -- 834
			label = "牌楼右柱", -- 834
			lanes = {"lower", "upper"}, -- 834
			art = "gate_post" -- 834
		} -- 834
	}, -- 834
	zones = {{ -- 836
		x0 = 640, -- 836
		x1 = 1300, -- 836
		y = 0, -- 836
		h = 150, -- 836
		tint = 1, -- 836
		label = "转角装卸面交火 700–1200" -- 836
	}}, -- 836
	arch = { -- 837
		x0 = 0, -- 837
		x1 = 0, -- 837
		y = 0, -- 837
		h = 0, -- 837
		label = "" -- 837
	}, -- 837
	stairs = {}, -- 838
	cart = NO_CART, -- 839
	spawns = {{ -- 840
		x = 940, -- 841
		y = 0, -- 841
		h = 84, -- 841
		depth = 0, -- 841
		label = "持盾手 940", -- 841
		kind = "shield", -- 841
		shieldHp = 2, -- 841
		drop = "shield" -- 841
	}, { -- 841
		x = 1060, -- 842
		y = 0, -- 842
		h = 84, -- 842
		depth = 32, -- 842
		label = "远侧火器手 1060", -- 842
		kind = "gunner", -- 842
		drop = "ammo" -- 842
	}, { -- 842
		x = 1140, -- 843
		y = 0, -- 843
		h = 84, -- 843
		depth = 0, -- 843
		label = "破障手 1140", -- 843
		kind = "breaker", -- 843
		drop = "wedge" -- 843
	}}, -- 843
	marks = {{x = 640, y = 0, kind = 1, label = "窗板后等待位 640"}, {x = 900, y = 0, kind = 0, label = "后仓汇合口 900"}, {x = 1740, y = 0, kind = 0, label = "牌楼出口 1740"}}, -- 845
	dims = {{x0 = 100, x1 = 124, text = "檐柱 24"}, {x0 = 460, x1 = 560, text = "摊挡 100"}, {x0 = 700, x1 = 820, text = "装卸面 120"}}, -- 850
	companion = {waitX = 640, waitDepth = 32, joinX = 900, followAfter = "open_board"}, -- 855
	campaign = { -- 856
		chapter = "S", -- 856
		act = 2, -- 856
		budget = 390, -- 856
		goal = "reach_exit", -- 856
		next = "s3-archway", -- 856
		exitX = 1740, -- 856
		checkpoint = 2 -- 856
	} -- 856
} -- 856
--- S3 牌楼后巷：外檐线从低处进、布行线从高处进，两条入口在墙脚汇合。
-- 装卸坡可先上去看同一堆粮袋的敌位，再退半层接小满；也可以沿墙脚直接绕。
____exports.S3_ARCHWAY = { -- 863
	key = "s3-archway", -- 864
	name = "S3 · 牌楼后巷", -- 865
	caption = "两高度入口看同一粮袋。登装卸坡看敌位再退半层接人，或沿墙脚绕走；候检门前两人停。", -- 866
	originX = 3400, -- 867
	minX = 0, -- 868
	maxX = 1400, -- 869
	height = 230, -- 870
	depth = LANE_ROAD, -- 871
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 872
	solids = { -- 873
		{ -- 874
			x = 0, -- 874
			w = 180, -- 874
			h = 32, -- 874
			y = 0, -- 874
			label = "高处进口台 0–180 · 高 32", -- 874
			lanes = {"upper"} -- 874
		}, -- 874
		{ -- 875
			x = 380, -- 875
			w = 140, -- 875
			h = 64, -- 875
			y = 0, -- 875
			label = "装卸高台 380–520 · 高 64", -- 875
			lanes = {"upper"} -- 875
		}, -- 875
		{ -- 876
			x = 560, -- 876
			w = 160, -- 876
			h = 48, -- 876
			y = 0, -- 876
			label = "粮袋堆 560–720 · 高 48", -- 876
			lanes = {"lower", "middle"} -- 876
		}, -- 876
		{ -- 877
			x = 1260, -- 877
			w = 30, -- 877
			h = 140, -- 877
			y = 0, -- 877
			label = "候检门左柱", -- 877
			lanes = {"lower", "upper"}, -- 877
			art = "gate_post" -- 877
		}, -- 877
		{ -- 878
			x = 1330, -- 878
			w = 30, -- 878
			h = 140, -- 878
			y = 0, -- 878
			label = "候检门右柱", -- 878
			lanes = {"lower", "upper"}, -- 878
			art = "gate_post" -- 878
		} -- 878
	}, -- 878
	zones = {{ -- 880
		x0 = 780, -- 880
		x1 = 1060, -- 880
		y = 0, -- 880
		h = 150, -- 880
		tint = 1, -- 880
		label = "后巷交火 780–1060" -- 880
	}}, -- 880
	arch = { -- 881
		x0 = 0, -- 881
		x1 = 0, -- 881
		y = 0, -- 881
		h = 0, -- 881
		label = "" -- 881
	}, -- 881
	stairs = {{ -- 882
		x0 = 140, -- 883
		x1 = 200, -- 883
		y0 = 0, -- 883
		y1 = 32, -- 883
		steps = 3, -- 883
		label = "进口台阶" -- 883
	}, { -- 883
		x0 = 260, -- 884
		x1 = 380, -- 884
		y0 = 0, -- 884
		y1 = 64, -- 884
		steps = 4, -- 884
		label = "装卸坡 260–380 · 高 64" -- 884
	}}, -- 884
	cart = NO_CART, -- 886
	spawns = {{ -- 887
		x = 860, -- 888
		y = 0, -- 888
		h = 84, -- 888
		depth = 32, -- 888
		label = "高处火器手 860", -- 888
		kind = "gunner", -- 888
		drop = "ammo" -- 888
	}, { -- 888
		x = 980, -- 889
		y = 0, -- 889
		h = 84, -- 889
		depth = 0, -- 889
		label = "墙脚火器手 980", -- 889
		kind = "gunner", -- 889
		drop = "ammo" -- 889
	}}, -- 889
	marks = {{x = 440, y = 0, kind = 0, label = "装卸坡观察位 440"}, {x = 620, y = 0, kind = 1, label = "粮袋后安全点 620"}, {x = 1300, y = 0, kind = 0, label = "候检门前 1300"}}, -- 891
	dims = {{x0 = 260, x1 = 380, text = "装卸坡 120"}, {x0 = 560, x1 = 720, text = "粮袋 160"}}, -- 896
	companion = {waitX = 620, waitDepth = 0, joinX = 1240}, -- 897
	campaign = { -- 898
		chapter = "S", -- 898
		act = 3, -- 898
		budget = 180, -- 898
		goal = "reach_exit", -- 898
		next = "c1-yard", -- 898
		exitX = 1320, -- 898
		checkpoint = 3 -- 898
	} -- 898
} -- 898
--- C1 候检院：侧门横闩在门背，粮棚可见但被队栏、查验台与棚柱交错挡住。
-- 绕缺口进栏，截断压近者或穿查验台后到棚口；正面看门，转到背面才抬得动闩。
____exports.C1_YARD = { -- 905
	key = "c1-yard", -- 906
	name = "C1 · 候检院", -- 907
	caption = "队栏与查验台把粮棚切成几段。绕缺口进栏，压近者会截断通路；侧门横闩要转到门背才抬得动。", -- 908
	originX = 4800, -- 909
	minX = 0, -- 910
	maxX = 1900, -- 911
	height = 240, -- 912
	depth = LANE_ROAD, -- 913
	floors = {{y = 0, x0 = 0, x1 = 1900}}, -- 914
	solids = { -- 915
		{ -- 916
			x = 280, -- 916
			w = 340, -- 916
			h = 28, -- 916
			y = 0, -- 916
			label = "候检队栏 280–620 · 高 28", -- 916
			lanes = {"lower", "middle"}, -- 916
			art = "fence" -- 916
		}, -- 916
		{ -- 917
			x = 820, -- 917
			w = 180, -- 917
			h = 44, -- 917
			y = 0, -- 917
			label = "查验台 820–1000 · 高 44", -- 917
			lanes = {"lower", "middle"} -- 917
		}, -- 917
		{ -- 918
			x = 1100, -- 918
			w = 40, -- 918
			h = 150, -- 918
			y = 0, -- 918
			label = "棚柱 1100–1140", -- 918
			lanes = {"lower", "middle"}, -- 918
			art = "cover_wood" -- 918
		}, -- 918
		{ -- 919
			x = 1240, -- 919
			w = 40, -- 919
			h = 150, -- 919
			y = 0, -- 919
			label = "棚柱 1240–1280", -- 919
			lanes = {"lower", "middle"}, -- 919
			art = "cover_wood" -- 919
		}, -- 919
		{ -- 920
			x = 1600, -- 920
			w = 160, -- 920
			h = 48, -- 920
			y = 0, -- 920
			label = "粮棚袋堆 1600–1760 · 高 48", -- 920
			lanes = {"lower", "middle"} -- 920
		}, -- 920
		{ -- 921
			x = 1780, -- 921
			w = 50, -- 921
			h = 150, -- 921
			y = 0, -- 921
			label = "侧门 1780–1830", -- 921
			lanes = {"lower", "middle"}, -- 921
			art = "wall", -- 921
			id = "c1_door" -- 921
		}, -- 921
		{ -- 922
			x = 1810, -- 923
			w = 30, -- 923
			h = 24, -- 923
			y = 40, -- 923
			label = "侧门横闩（门背）", -- 923
			lanes = {"upper"}, -- 923
			art = "latch", -- 924
			id = "c1_latch", -- 924
			interact = {kind = "raise_latch", reach = 52} -- 924
		} -- 924
	}, -- 924
	zones = {{ -- 927
		x0 = 760, -- 927
		x1 = 1080, -- 927
		y = 0, -- 927
		h = 150, -- 927
		tint = 1, -- 927
		label = "查验台截断 820–1000" -- 927
	}}, -- 927
	arch = { -- 928
		x0 = 0, -- 928
		x1 = 0, -- 928
		y = 0, -- 928
		h = 0, -- 928
		label = "" -- 928
	}, -- 928
	stairs = {}, -- 929
	cart = NO_CART, -- 930
	spawns = {{ -- 931
		x = 900, -- 932
		y = 0, -- 932
		h = 84, -- 932
		depth = 0, -- 932
		label = "截断压近者 900", -- 932
		kind = "breaker", -- 932
		drop = "wedge" -- 932
	}, { -- 932
		x = 1200, -- 933
		y = 0, -- 933
		h = 84, -- 933
		depth = 32, -- 933
		label = "棚柱后火器手 1200", -- 933
		kind = "gunner", -- 933
		drop = "ammo" -- 933
	}}, -- 933
	marks = {{x = 1000, y = 0, kind = 1, label = "查验台后等待位 1000"}, {x = 1700, y = 0, kind = 0, label = "侧门正面 1700"}, {x = 1860, y = 0, kind = 0, label = "门背出口 1860"}}, -- 935
	dims = {{x0 = 820, x1 = 1000, text = "查验台 180"}, {x0 = 1780, x1 = 1830, text = "侧门 50"}}, -- 940
	companion = {waitX = 1000, waitDepth = 0, joinX = 1700, followAfter = "raise_latch"}, -- 941
	campaign = { -- 942
		chapter = "C", -- 942
		act = 1, -- 942
		budget = 270, -- 942
		goal = "raise_latch", -- 942
		next = "c2-granary", -- 942
		exitX = 1860, -- 942
		checkpoint = 4 -- 942
	} -- 942
} -- 942
--- C2 军粮棚：粮袋安全区居中，远柱木帘与近侧车轨分列。
-- 有残盾可以在暴露轨段架起来挡一发；空手路线先绕上远柱放帘，再回来握车柄。
____exports.C2_GRANARY = { -- 949
	key = "c2-granary", -- 950
	name = "C2 · 军粮棚", -- 951
	caption = "空筐围挡、暴露轨段与远柱木帘。先绕上远柱放帘，或架残盾，再握车柄把车推入轮窝并抬连杆闩。", -- 952
	originX = 6700, -- 953
	minX = 0, -- 954
	maxX = 1800, -- 955
	height = 240, -- 956
	depth = LANE_ROAD, -- 957
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 958
	solids = { -- 959
		{ -- 960
			x = 900, -- 961
			w = 120, -- 961
			h = 44, -- 961
			y = 0, -- 961
			label = "空筐围挡 900–1020 · 高 44", -- 961
			lanes = {"lower", "middle"}, -- 961
			art = "basket_wall", -- 962
			id = "c2_basket", -- 962
			breakable = {kind = "basket_wall", hp = 2, wedgeable = false} -- 962
		}, -- 962
		{ -- 964
			x = 600, -- 964
			w = 300, -- 964
			h = 48, -- 964
			y = 0, -- 964
			label = "粮袋安全区 600–900 · 高 48", -- 964
			lanes = {"lower", "middle"} -- 964
		}, -- 964
		{ -- 965
			x = 980, -- 965
			w = 40, -- 965
			h = 24, -- 965
			y = 0, -- 965
			label = "棚口下轨台 980–1020 · 高 24", -- 965
			lanes = {"lower", "middle"} -- 965
		}, -- 965
		{ -- 966
			x = 1200, -- 967
			w = 40, -- 967
			h = 150, -- 967
			y = 0, -- 967
			label = "远柱 1200–1240 · 高 150", -- 967
			lanes = {"upper"}, -- 967
			art = "cover_wood", -- 968
			id = "c2_post", -- 968
			interact = {kind = "lower_curtain", reach = 46} -- 968
		}, -- 968
		{ -- 970
			x = 1240, -- 971
			w = 120, -- 971
			h = 120, -- 971
			y = 24, -- 971
			label = "木帘落点 1240–1360", -- 971
			lanes = {"lower", "middle"}, -- 971
			art = "curtain", -- 972
			soft = true, -- 972
			id = "c2_curtain", -- 972
			hidden = true -- 972
		}, -- 972
		{ -- 974
			x = 1560, -- 975
			w = 30, -- 975
			h = 24, -- 975
			y = 40, -- 975
			label = "连杆抬闩 1560–1590", -- 975
			lanes = {"middle"}, -- 975
			art = "latch", -- 976
			id = "c2_latch", -- 976
			interact = {kind = "raise_latch", reach = 50} -- 976
		}, -- 976
		{ -- 978
			x = 1720, -- 978
			w = 30, -- 978
			h = 150, -- 978
			y = 0, -- 978
			label = "棚尾门柱", -- 978
			lanes = {"lower", "upper"}, -- 978
			art = "gate_post" -- 978
		} -- 978
	}, -- 978
	zones = {{ -- 980
		x0 = 1000, -- 980
		x1 = 1200, -- 980
		y = 0, -- 980
		h = 150, -- 980
		tint = 1, -- 980
		label = "暴露轨段 1000–1200" -- 980
	}}, -- 980
	arch = { -- 981
		x0 = 0, -- 981
		x1 = 0, -- 981
		y = 0, -- 981
		h = 0, -- 981
		label = "" -- 981
	}, -- 981
	stairs = {}, -- 982
	cart = { -- 983
		startX = 1150, -- 984
		endX = 1500, -- 984
		baseY = 0, -- 984
		depth = 0, -- 984
		bodyW = 48, -- 984
		bodyH = 26, -- 984
		wheelR = 12, -- 984
		handleOffset = -50, -- 984
		clothSide = -1 -- 984
	}, -- 984
	spawns = {{ -- 986
		x = 1580, -- 987
		y = 0, -- 987
		h = 84, -- 987
		depth = 0, -- 987
		label = "棚尾火器手 1580", -- 987
		kind = "gunner", -- 987
		drop = "ammo" -- 987
	}, { -- 987
		x = 1340, -- 988
		y = 0, -- 988
		h = 84, -- 988
		depth = 32, -- 988
		label = "远侧持盾手 1340", -- 988
		kind = "shield", -- 988
		shieldHp = 2, -- 988
		drop = "shield" -- 988
	}}, -- 988
	marks = {{x = 760, y = 0, kind = 1, label = "袋堆后等待位 760"}, {x = 1100, y = 0, kind = 0, label = "车柄 1100"}, {x = 1500, y = 0, kind = 0, label = "轮窝 1500"}, {x = 1700, y = 0, kind = 0, label = "棚尾出口 1700"}}, -- 990
	dims = {{x0 = 1150, x1 = 1500, text = "推车 350"}, {x0 = 1240, x1 = 1360, text = "木帘 120"}}, -- 996
	companion = {waitX = 760, waitDepth = 0, joinX = 1700}, -- 997
	campaign = { -- 998
		chapter = "C", -- 998
		act = 2, -- 998
		budget = 360, -- 998
		goal = "dock_cart", -- 998
		exitX = 1700, -- 998
		checkpoint = 5 -- 998
	} -- 998
} -- 998
____exports.CAMPAIGN_ROOMS = { -- 1001
	____exports.S1_CROSSROAD, -- 1001
	____exports.S2_DRYGOODS, -- 1001
	____exports.S3_ARCHWAY, -- 1001
	____exports.C1_YARD, -- 1001
	____exports.C2_GRANARY -- 1001
} -- 1001
____exports.ROOMS = { -- 1009
	____exports.PROLOGUE_ROOM, -- 1009
	____exports.STREET_ROOM, -- 1009
	____exports.CHECKPOINT_ROOM, -- 1009
	____exports.GATE_ROOM, -- 1009
	____exports.GATE_PATH_ROOM, -- 1009
	____exports.ESCORT1_ROOM, -- 1009
	____exports.OUTSIDE_ROOM, -- 1009
	____exports.VILLAGE_ROOM, -- 1009
	____exports.FOREST_ROOM, -- 1009
	____exports.TOWER_ROOM -- 1009
} -- 1009
local function placeSolids(room) -- 1022
	local blocks = {} -- 1023
	for ____, solid in ipairs(room.solids) do -- 1024
		local x = solid.x + room.originX -- 1025
		if room.depth ~= nil and solid.lanes ~= nil then -- 1025
			for ____, depth in ipairs(laneFootprints(solid.lanes)) do -- 1027
				blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x, depth = depth, lanes = nil}) -- 1028
			end -- 1028
		else -- 1028
			blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x}) -- 1031
		end -- 1031
	end -- 1031
	return blocks -- 1034
end -- 1022
--- 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
-- 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
function ____exports.withOrigin(room) -- 1041
	local ox = room.originX -- 1042
	if ox == 0 then -- 1042
		return room.depth == nil and room or __TS__ObjectAssign( -- 1044
			{}, -- 1044
			room, -- 1044
			{solids = placeSolids(room)} -- 1044
		) -- 1044
	end -- 1044
	local function shift(x) -- 1046
		return x + ox -- 1046
	end -- 1046
	local ____room_key_7 = room.key -- 1048
	local ____room_name_8 = room.name -- 1049
	local ____room_caption_9 = room.caption -- 1050
	local ____shift_result_10 = shift(room.minX) -- 1052
	local ____shift_result_11 = shift(room.maxX) -- 1053
	local ____room_height_12 = room.height -- 1054
	local ____room_depth_13 = room.depth -- 1055
	local ____TS__ArrayMap_result_14 = __TS__ArrayMap( -- 1056
		room.floors, -- 1056
		function(____, f) return { -- 1056
			y = f.y, -- 1056
			x0 = shift(f.x0), -- 1056
			x1 = shift(f.x1) -- 1056
		} end -- 1056
	) -- 1056
	local ____placeSolids_result_15 = placeSolids(room) -- 1057
	local ____TS__ArrayMap_result_16 = __TS__ArrayMap( -- 1058
		room.zones, -- 1058
		function(____, z) return { -- 1058
			x0 = shift(z.x0), -- 1058
			x1 = shift(z.x1), -- 1058
			y = z.y, -- 1058
			h = z.h, -- 1058
			tint = z.tint, -- 1058
			label = z.label -- 1058
		} end -- 1058
	) -- 1058
	local ____temp_17 = { -- 1059
		x0 = shift(room.arch.x0), -- 1059
		x1 = shift(room.arch.x1), -- 1059
		y = room.arch.y, -- 1059
		h = room.arch.h, -- 1059
		label = room.arch.label -- 1059
	} -- 1059
	local ____TS__ArrayMap_result_18 = __TS__ArrayMap( -- 1060
		room.stairs, -- 1060
		function(____, s) return { -- 1060
			x0 = shift(s.x0), -- 1060
			x1 = shift(s.x1), -- 1060
			y0 = s.y0, -- 1060
			y1 = s.y1, -- 1060
			steps = s.steps, -- 1060
			label = s.label -- 1060
		} end -- 1060
	) -- 1060
	local ____TS__ObjectAssign_result_19 = __TS__ObjectAssign( -- 1061
		{}, -- 1061
		room.cart, -- 1062
		{ -- 1061
			startX = shift(room.cart.startX), -- 1063
			endX = shift(room.cart.endX) -- 1064
		} -- 1064
	) -- 1064
	local ____TS__ArrayMap_result_20 = __TS__ArrayMap( -- 1066
		room.spawns, -- 1066
		function(____, s) return __TS__ObjectAssign( -- 1066
			{}, -- 1066
			s, -- 1066
			{x = shift(s.x)} -- 1066
		) end -- 1066
	) -- 1066
	local ____TS__ArrayMap_result_21 = __TS__ArrayMap( -- 1067
		room.marks, -- 1067
		function(____, m) return { -- 1067
			x = shift(m.x), -- 1067
			y = m.y, -- 1067
			kind = m.kind, -- 1067
			label = m.label -- 1067
		} end -- 1067
	) -- 1067
	local ____TS__ArrayMap_result_22 = __TS__ArrayMap( -- 1068
		room.dims, -- 1068
		function(____, d) return { -- 1068
			x0 = shift(d.x0), -- 1068
			x1 = shift(d.x1), -- 1068
			text = d.text -- 1068
		} end -- 1068
	) -- 1068
	local ____temp_0 -- 1069
	if room.scavenger == nil then -- 1069
		____temp_0 = nil -- 1069
	else -- 1069
		____temp_0 = { -- 1069
			x0 = shift(room.scavenger.x0), -- 1070
			x1 = shift(room.scavenger.x1), -- 1070
			y = room.scavenger.y, -- 1070
			h = room.scavenger.h, -- 1070
			patrolSpeed = room.scavenger.patrolSpeed, -- 1071
			approachSpeed = room.scavenger.approachSpeed, -- 1071
			hearTicks = room.scavenger.hearTicks, -- 1072
			stallTicks = room.scavenger.stallTicks, -- 1072
			range = room.scavenger.range -- 1072
		} -- 1072
	end -- 1072
	local ____temp_1 -- 1074
	if room.bottle == nil then -- 1074
		____temp_1 = nil -- 1074
	else -- 1074
		____temp_1 = { -- 1074
			x = shift(room.bottle.x), -- 1074
			y = room.bottle.y -- 1074
		} -- 1074
	end -- 1074
	local ____temp_2 -- 1075
	if room.brickX == nil then -- 1075
		____temp_2 = nil -- 1075
	else -- 1075
		____temp_2 = shift(room.brickX) -- 1075
	end -- 1075
	local ____temp_3 -- 1076
	if room.softX == nil then -- 1076
		____temp_3 = nil -- 1076
	else -- 1076
		____temp_3 = shift(room.softX) -- 1076
	end -- 1076
	local ____temp_4 -- 1077
	if room.passLine == nil then -- 1077
		____temp_4 = nil -- 1077
	else -- 1077
		____temp_4 = shift(room.passLine) -- 1077
	end -- 1077
	local ____temp_5 -- 1078
	if room.campaign == nil then -- 1078
		____temp_5 = nil -- 1078
	else -- 1078
		____temp_5 = __TS__ObjectAssign( -- 1078
			{}, -- 1078
			room.campaign, -- 1078
			{exitX = shift(room.campaign.exitX)} -- 1078
		) -- 1078
	end -- 1078
	local ____temp_6 -- 1079
	if room.pickups == nil then -- 1079
		____temp_6 = nil -- 1079
	else -- 1079
		____temp_6 = __TS__ArrayMap( -- 1079
			room.pickups, -- 1079
			function(____, p) return __TS__ObjectAssign( -- 1079
				{}, -- 1079
				p, -- 1079
				{x = shift(p.x)} -- 1079
			) end -- 1079
		) -- 1079
	end -- 1079
	return { -- 1047
		key = ____room_key_7, -- 1048
		name = ____room_name_8, -- 1049
		caption = ____room_caption_9, -- 1050
		originX = 0, -- 1051
		minX = ____shift_result_10, -- 1052
		maxX = ____shift_result_11, -- 1053
		height = ____room_height_12, -- 1054
		depth = ____room_depth_13, -- 1055
		floors = ____TS__ArrayMap_result_14, -- 1056
		solids = ____placeSolids_result_15, -- 1057
		zones = ____TS__ArrayMap_result_16, -- 1058
		arch = ____temp_17, -- 1059
		stairs = ____TS__ArrayMap_result_18, -- 1060
		cart = ____TS__ObjectAssign_result_19, -- 1061
		spawns = ____TS__ArrayMap_result_20, -- 1066
		marks = ____TS__ArrayMap_result_21, -- 1067
		dims = ____TS__ArrayMap_result_22, -- 1068
		scavenger = ____temp_0, -- 1069
		bottle = ____temp_1, -- 1074
		brickX = ____temp_2, -- 1075
		softX = ____temp_3, -- 1076
		passLine = ____temp_4, -- 1077
		campaign = ____temp_5, -- 1078
		pickups = ____temp_6, -- 1079
		companion = room.companion, -- 1080
		story = shiftStory(room.story, ox) -- 1081
	} -- 1081
end -- 1041
return ____exports -- 1041