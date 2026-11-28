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
____exports.CHECKPOINT_ROOM = { -- 277
	key = "checkpoint", -- 278
	name = "检查站 · 候检区 640 + 原段 1000", -- 279
	caption = "先翻过队栏进候检区，再带小满走到柜台与安全点；末段按住 E + D 推车 128 单位入窝", -- 280
	originX = 640, -- 282
	minX = -640, -- 283
	maxX = 1000, -- 284
	height = 210, -- 285
	depth = LANE_ROAD, -- 286
	floors = {{y = 0, x0 = -640, x1 = 1000}}, -- 287
	solids = {{ -- 288
		x = -430, -- 290
		w = 180, -- 290
		h = 28, -- 290
		y = 0, -- 290
		label = "队栏 -430–-250 · 高 28", -- 290
		lanes = {"lower", "middle"}, -- 290
		art = "fence" -- 290
	}, { -- 290
		x = 240, -- 292
		w = 100, -- 292
		h = 44, -- 292
		y = 0, -- 292
		label = "柜台 240–340 · 高 44", -- 292
		lanes = {"lower", "middle"}, -- 292
		art = "cover_wood" -- 292
	}, { -- 292
		x = 890, -- 293
		w = 36, -- 293
		h = 122, -- 293
		y = 0, -- 293
		label = "检查站出口门柱", -- 293
		lanes = {"lower", "upper"}, -- 293
		art = "gate_post" -- 293
	}}, -- 293
	zones = {{ -- 295
		x0 = 380, -- 295
		x1 = 560, -- 295
		y = 0, -- 295
		h = 120, -- 295
		tint = 1, -- 295
		label = "危险段 380–560" -- 295
	}}, -- 295
	arch = { -- 296
		x0 = 0, -- 296
		x1 = 0, -- 296
		y = 0, -- 296
		h = 0, -- 296
		label = "" -- 296
	}, -- 296
	stairs = {}, -- 297
	cart = { -- 298
		startX = 640, -- 299
		endX = 768, -- 300
		baseY = 0, -- 301
		depth = LANE_DEPTH.middle, -- 302
		bodyW = 48, -- 303
		bodyH = 26, -- 304
		wheelR = 12, -- 305
		handleOffset = -40, -- 306
		clothSide = -1 -- 307
	}, -- 307
	spawns = {{x = -600, y = 0, h = 56, label = "小满 -600（世界 40）"}, {x = -560, y = 0, h = 88, label = "周戍 -560（世界 80）"}}, -- 309
	marks = {{x = 264, y = 0, kind = 1, label = "安全锚 264"}, {x = 768, y = 0, kind = 1, label = "dock 768"}, {x = 860, y = 0, kind = 2, label = "双人出口 792–928"}}, -- 313
	dims = {{x0 = 240, x1 = 340, text = "柜台 100"}, {x0 = 640, x1 = 768, text = "推车 128 · 左柄 E+D"}, {x0 = 792, x1 = 928, text = "出口 136"}} -- 318
} -- 318
--- 城外：同一剖面里同时看上层手柄与下层拱口，这是 D1 要交的那张图。
____exports.OUTSIDE_ROOM = { -- 326
	key = "outside", -- 327
	name = "城外 · 台面 y=96 / 墙根 1240", -- 328
	caption = "从右柄按住 E+D 朝空窝拉 128 单位，轮子落窝后沿台面回左端跳下，蹲过 44 高的拱；洞后墙根小路走到底可看见塔灯", -- 329
	originX = 0, -- 331
	minX = 0, -- 332
	maxX = 1240, -- 333
	height = 230, -- 334
	depth = LANE_ROAD, -- 335
	floors = {{y = 0, x0 = 0, x1 = 1240}, {y = 96, x0 = 128, x1 = 512}, {y = 64, x0 = 820, x1 = 940}}, -- 336
	solids = {{ -- 341
		x = 96, -- 343
		w = 44, -- 343
		h = 34, -- 343
		y = 96, -- 343
		depth = LANE_ROAD, -- 343
		id = "outside_red_cart", -- 343
		art = "red_cart", -- 343
		label = "补丁红布车 · 挡住石阶口" -- 343
	}, { -- 343
		x = 512, -- 345
		w = 88, -- 345
		h = 134, -- 345
		y = 96, -- 345
		depth = LANE_ROAD, -- 345
		label = "台面右端城墙 · 下层可通" -- 345
	}, { -- 345
		x = 0, -- 346
		w = 40, -- 346
		h = 96, -- 346
		y = 0, -- 346
		depth = LANE_ROAD, -- 346
		label = "街口" -- 346
	}, { -- 346
		x = 1200, -- 347
		w = 40, -- 347
		h = 140, -- 347
		y = 0, -- 347
		depth = LANE_ROAD, -- 347
		label = "墙根尽头" -- 347
	}}, -- 347
	zones = {}, -- 349
	arch = { -- 350
		x0 = 280, -- 350
		x1 = 360, -- 350
		y = 0, -- 350
		h = 44, -- 350
		label = "拱 280–360 · 净高 44" -- 350
	}, -- 350
	stairs = {{ -- 351
		x0 = 56, -- 352
		x1 = 128, -- 352
		y0 = 0, -- 352
		y1 = 96, -- 352
		steps = 5, -- 352
		depth = LANE_ROAD, -- 352
		label = "石阶 0–96（每级 19.2 可直走）" -- 352
	}, { -- 352
		x0 = 700, -- 353
		x1 = 820, -- 353
		y0 = 0, -- 353
		y1 = 64, -- 353
		steps = 3, -- 353
		depth = LANE_ROAD, -- 353
		label = "墙根石阶 0 / 16 / 32 / 48 / 64" -- 353
	}}, -- 353
	cart = { -- 355
		startX = 304, -- 356
		endX = 432, -- 357
		baseY = 96, -- 358
		bodyW = 48, -- 359
		bodyH = 26, -- 360
		wheelR = 12, -- 361
		handleOffset = 40, -- 362
		clothSide = -1 -- 363
	}, -- 363
	spawns = {{x = 160, y = 96, h = 56, label = "小满 160"}}, -- 365
	marks = { -- 366
		{x = 432, y = 96, kind = 1, label = "空窝 432"}, -- 367
		{x = 380, y = 0, kind = 0, label = "洞后检查点 380"}, -- 368
		{x = 520, y = 96, kind = 3, label = "石阶光 · 回首红布"}, -- 369
		{x = 820, y = 64, kind = 3, label = "墙根石阶顶 820"}, -- 370
		{x = 1120, y = 64, kind = 6, label = "塔灯 1120"} -- 371
	}, -- 371
	dims = { -- 373
		{x0 = 96, x1 = 140, text = "红布车 · E 拉开"}, -- 374
		{x0 = 304, x1 = 432, text = "空窝 128 · 右柄 E+D"}, -- 375
		{x0 = 128, x1 = 512, text = "台面 384"}, -- 376
		{x0 = 280, x1 = 360, text = "拱 80"}, -- 377
		{x0 = 600, x1 = 1240, text = "墙根 640"} -- 378
	} -- 378
} -- 378
--- 村口：瓶架 112、观察位 160、桌下 304–416（净高 44）、第一院通行线 440、
-- 软土 272（D5 完整）、砖地 608、拾荒者巡逻 464–512。
-- 小满脚底中心 290 起必须蹲，超过 430 才站起；160→440 约 2.63 秒。
____exports.VILLAGE_ROOM = { -- 387
	key = "village", -- 388
	originX = 0, -- 389
	name = "村口 · 架、桌、砖地", -- 390
	caption = "点 E 拾瓶，按住 F 瞄，松手投；砖地一响，拾荒者转身，趁他走开钻过桌下", -- 391
	minX = 0, -- 392
	maxX = 720, -- 393
	height = 200, -- 394
	depth = LANE_ROAD, -- 395
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 396
	solids = {{ -- 397
		x = 96, -- 398
		w = 32, -- 398
		h = 52, -- 398
		y = 0, -- 398
		depth = LANE_ROAD, -- 398
		label = "瓶架", -- 398
		art = "cover_wood" -- 398
	}, { -- 398
		x = 672, -- 400
		w = 48, -- 400
		h = 96, -- 400
		y = 0, -- 400
		depth = LANE_ROAD, -- 400
		label = "院墙" -- 400
	}}, -- 400
	zones = { -- 402
		{ -- 403
			x0 = 256, -- 403
			x1 = 288, -- 403
			y = 0, -- 403
			h = 6, -- 403
			tint = 2, -- 403
			label = "软土 272" -- 403
		}, -- 403
		{ -- 404
			x0 = 440, -- 404
			x1 = 448, -- 404
			y = 0, -- 404
			h = 120, -- 404
			tint = 4, -- 404
			label = "通行线 440" -- 404
		}, -- 404
		{ -- 405
			x0 = 532, -- 405
			x1 = 564, -- 405
			y = 0, -- 405
			h = 6, -- 405
			tint = 4, -- 405
			label = "铁盆 548" -- 405
		}, -- 405
		{ -- 406
			x0 = 592, -- 406
			x1 = 624, -- 406
			y = 0, -- 406
			h = 6, -- 406
			tint = 3, -- 406
			label = "砖地 608" -- 406
		}, -- 406
		{ -- 407
			x0 = 560, -- 407
			x1 = 640, -- 407
			y = 0, -- 407
			h = 6, -- 407
			tint = 1, -- 407
			label = "暗渠口 560–640 · 蹲下钻" -- 407
		} -- 407
	}, -- 407
	arch = { -- 409
		x0 = 304, -- 409
		x1 = 416, -- 409
		y = 0, -- 409
		h = 44, -- 409
		label = "桌下 304–416 · 净高 44" -- 409
	}, -- 409
	stairs = {}, -- 410
	cart = { -- 411
		startX = 0, -- 411
		endX = 0, -- 411
		baseY = 0, -- 411
		bodyW = 0, -- 411
		bodyH = 0, -- 411
		wheelR = 0, -- 411
		handleOffset = 0, -- 411
		clothSide = 1 -- 411
	}, -- 411
	spawns = {{x = 160, y = 0, h = 56, label = "小满 160"}}, -- 412
	marks = {{x = 548, y = 0, kind = 5, label = "铁盆落点 548"}, {x = 608, y = 0, kind = 5, label = "砖地落点 608"}, {x = 440, y = 0, kind = 4, label = "通行线 440"}, {x = 600, y = 0, kind = 1, label = "暗渠口 600"}}, -- 413
	dims = {{x0 = 96, x1 = 128, text = "瓶架"}, {x0 = 304, x1 = 416, text = "桌下 112"}, {x0 = 464, x1 = 512, text = "巡逻 48"}, {x0 = 560, x1 = 640, text = "暗渠 80"}}, -- 419
	scavenger = { -- 425
		x0 = 464, -- 426
		x1 = 512, -- 427
		y = 0, -- 428
		h = 82, -- 429
		patrolSpeed = 40, -- 430
		approachSpeed = 64, -- 431
		hearTicks = 18, -- 432
		stallTicks = 120, -- 433
		range = 480 -- 434
	}, -- 434
	bottle = {x = 112, y = 48}, -- 436
	brickX = 608, -- 437
	basinX = 548, -- 438
	softX = 272, -- 439
	passLine = 440 -- 440
} -- 440
--- 剧本锚点跟着 originX 一起搬，判定仍读世界坐标。
local function shiftStory(story, ox) -- 444
	if story == nil then -- 444
		return nil -- 446
	end -- 446
	if ox == 0 then -- 446
		return story -- 449
	end -- 449
	local out = {} -- 451
	if story.prologue ~= nil then -- 451
		out.prologue = {giveReach = story.prologue.giveReach} -- 453
	end -- 453
	if story.gate ~= nil then -- 453
		out.gate = { -- 456
			winchX = story.gate.winchX + ox, -- 457
			waitX = story.gate.waitX + ox, -- 458
			doorX = story.gate.doorX + ox, -- 459
			exitX = story.gate.exitX + ox, -- 460
			holdTicks = story.gate.holdTicks -- 461
		} -- 461
	end -- 461
	if story.gatepath ~= nil then -- 461
		out.gatepath = {carryX = story.gatepath.carryX + ox, exitX = story.gatepath.exitX + ox, next = story.gatepath.next} -- 465
	end -- 465
	if story.dog ~= nil then -- 465
		out.dog = {x0 = story.dog.x0 + ox, x1 = story.dog.x1 + ox, speed = story.dog.speed, range = story.dog.range} -- 472
	end -- 472
	if story.museum ~= nil then -- 472
		out.museum = {cabinetX = story.museum.cabinetX + ox, hallX = story.museum.hallX + ox, lampX = story.museum.lampX + ox, exitX = story.museum.exitX + ox} -- 475
	end -- 475
	if story.tower ~= nil then -- 475
		out.tower = {doorX = story.tower.doorX + ox, knockTicks = story.tower.knockTicks} -- 483
	end -- 483
	return out -- 485
end -- 444
--- 序章：周戍在废墟里找到藏在倒柜后的小满，走近点 E 递出指南针（纸条夹在针套里）。
-- 递完她开始跟随，两人一起走进街道。
____exports.PROLOGUE_ROOM = { -- 492
	key = "prologue", -- 493
	originX = 0, -- 494
	name = "序章 · 倒柜后", -- 495
	caption = "周戍持针套，小满藏在倒柜后；走近点 E 递过去，纸条塞进针套，她开始跟随", -- 496
	minX = 0, -- 497
	maxX = 720, -- 498
	height = 200, -- 499
	depth = LANE_ROAD, -- 500
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 501
	solids = { -- 502
		{ -- 503
			x = 152, -- 503
			w = 98, -- 503
			h = 32, -- 503
			y = 0, -- 503
			label = "倒柜 152–250 · 高 32", -- 503
			lanes = {"lower", "middle"}, -- 503
			art = "cover_wood" -- 503
		}, -- 503
		{ -- 504
			x = 648, -- 504
			w = 30, -- 504
			h = 118, -- 504
			y = 0, -- 504
			label = "出口门柱", -- 504
			lanes = {"lower", "upper"}, -- 504
			art = "gate_post" -- 504
		}, -- 504
		{ -- 505
			x = 344, -- 505
			w = 32, -- 505
			h = 78, -- 505
			y = 0, -- 505
			label = "石柱", -- 505
			lanes = {"lower", "middle"}, -- 505
			art = "wall" -- 505
		}, -- 505
		{ -- 506
			x = 56, -- 506
			w = 44, -- 506
			h = 18, -- 506
			y = 0, -- 506
			label = "侧灶 56–100 · 高 18", -- 506
			decorative = true, -- 506
			art = "stove_hearth" -- 506
		}, -- 506
		{ -- 507
			x = 396, -- 507
			w = 34, -- 507
			h = 12, -- 507
			y = 0, -- 507
			label = "井沿 396–430 · 高 12", -- 507
			decorative = true, -- 507
			art = "well" -- 507
		}, -- 507
		{ -- 508
			x = 470, -- 508
			w = 40, -- 508
			h = 26, -- 508
			y = 0, -- 508
			label = "后院矮墙 470–510 · 高 26", -- 508
			lanes = {"lower"}, -- 508
			art = "cover_stone" -- 508
		} -- 508
	}, -- 508
	zones = {{ -- 510
		x0 = 380, -- 511
		x1 = 470, -- 511
		y = 0, -- 511
		h = 6, -- 511
		tint = 2, -- 511
		label = "后院旧井 380–470" -- 511
	}}, -- 511
	arch = { -- 513
		x0 = 0, -- 513
		x1 = 0, -- 513
		y = 0, -- 513
		h = 0, -- 513
		label = "" -- 513
	}, -- 513
	stairs = {}, -- 514
	cart = { -- 515
		startX = 0, -- 515
		endX = 0, -- 515
		baseY = 0, -- 515
		bodyW = 0, -- 515
		bodyH = 0, -- 515
		wheelR = 0, -- 515
		handleOffset = 0, -- 515
		clothSide = 1 -- 515
	}, -- 515
	spawns = {{x = 80, y = 0, h = 88, label = "周戍 80"}, {x = 300, y = 0, h = 56, label = "小满 300 · 柜子后面"}}, -- 516
	marks = {{x = 300, y = 0, kind = 1, label = "柜后 300"}, {x = 430, y = 0, kind = 7, label = "旧井 430"}, {x = 660, y = 0, kind = 0, label = "门口中路 660"}}, -- 520
	dims = {{x0 = 152, x1 = 250, text = "倒柜 98"}, {x0 = 648, x1 = 678, text = "门柱 30"}}, -- 525
	story = {prologue = {giveReach = 46}} -- 529
} -- 529
--- 街道：两人已经同行，第一次交火在街心柜台后，打完把柜台敲两下算解除。
-- 一路走到检查站入口，提交进度后进入检查站。
____exports.STREET_ROOM = { -- 536
	key = "street", -- 537
	originX = 0, -- 538
	name = "街道 · 柜台与交火", -- 539
	caption = "小满跟着走；街心柜台后有两名敌兵，点鼠标射击，清掉后一起走到检查站入口", -- 540
	minX = 0, -- 541
	maxX = 1000, -- 542
	height = 210, -- 543
	depth = LANE_ROAD, -- 544
	floors = {{y = 0, x0 = 0, x1 = 1000}}, -- 545
	solids = {{ -- 546
		x = 300, -- 547
		w = 100, -- 547
		h = 44, -- 547
		y = 0, -- 547
		label = "街心柜台 300–400 · 高 44", -- 547
		lanes = {"lower", "middle"}, -- 547
		art = "cover_wood" -- 547
	}, { -- 547
		x = 620, -- 548
		w = 60, -- 548
		h = 36, -- 548
		y = 0, -- 548
		label = "街边矮墙 620", -- 548
		lanes = {"upper"}, -- 548
		art = "cover_stone" -- 548
	}, { -- 548
		x = 892, -- 549
		w = 40, -- 549
		h = 120, -- 549
		y = 0, -- 549
		label = "检查站门柱", -- 549
		lanes = {"lower", "upper"}, -- 549
		art = "gate_post" -- 549
	}}, -- 549
	zones = {}, -- 551
	arch = { -- 552
		x0 = 0, -- 552
		x1 = 0, -- 552
		y = 0, -- 552
		h = 0, -- 552
		label = "" -- 552
	}, -- 552
	stairs = {}, -- 553
	cart = { -- 554
		startX = 0, -- 554
		endX = 0, -- 554
		baseY = 0, -- 554
		bodyW = 0, -- 554
		bodyH = 0, -- 554
		wheelR = 0, -- 554
		handleOffset = 0, -- 554
		clothSide = 1 -- 554
	}, -- 554
	spawns = {{x = 100, y = 0, h = 88, label = "周戍 100"}, {x = 60, y = 0, h = 56, label = "小满 60"}}, -- 555
	marks = {{x = 900, y = 0, kind = 0, label = "检查站入口 900"}, {x = 520, y = 0, kind = 3, label = "街心 520"}}, -- 559
	dims = {{x0 = 300, x1 = 400, text = "柜台 100"}, {x0 = 900, x1 = 1000, text = "入口 100"}} -- 563
} -- 563
--- 城门：周戍把小满送到门洞等待点，自己回到绞盘；两人就位后开始 45 秒守点。
-- 守满后玩家走到门边按 E 送别，接着是数到二十与交权。
____exports.GATE_ROOM = { -- 573
	key = "gate", -- 574
	originX = 0, -- 575
	name = "城门 · 45 秒守点", -- 576
	caption = "小满到门洞 960、周戍贴住绞盘 118，两人就位开始 45 秒；守满走到门边按 E 送她", -- 577
	minX = 0, -- 578
	maxX = 1200, -- 579
	height = 240, -- 580
	depth = LANE_ROAD, -- 581
	floors = {{y = 0, x0 = 0, x1 = 1200}}, -- 582
	solids = { -- 583
		{ -- 584
			x = 40, -- 584
			w = 60, -- 584
			h = 60, -- 584
			y = 0, -- 584
			label = "绞盘 40–100 · 高 60", -- 584
			lanes = {"middle"}, -- 584
			art = "winch" -- 584
		}, -- 584
		{ -- 585
			x = 520, -- 585
			w = 80, -- 585
			h = 44, -- 585
			y = 0, -- 585
			label = "街垒 520 · 高 44", -- 585
			lanes = {"middle", "upper"}, -- 585
			art = "cover_stone" -- 585
		}, -- 585
		{ -- 586
			x = 840, -- 586
			w = 24, -- 586
			h = 160, -- 586
			y = 0, -- 586
			label = "城门左门柱", -- 586
			lanes = {"lower", "upper"}, -- 586
			art = "gate_post" -- 586
		}, -- 586
		{ -- 587
			x = 1016, -- 587
			w = 24, -- 587
			h = 160, -- 587
			y = 0, -- 587
			label = "城门右门柱", -- 587
			lanes = {"lower", "upper"}, -- 587
			art = "gate_post" -- 587
		}, -- 587
		{ -- 588
			x = 1040, -- 588
			w = 160, -- 588
			h = 180, -- 588
			y = 0, -- 588
			label = "门洞右墙 1040", -- 588
			depth = LANE_ROAD, -- 588
			art = "wall" -- 588
		}, -- 588
		{ -- 589
			x = 840, -- 589
			w = 200, -- 589
			h = 56, -- 589
			y = 160, -- 589
			label = "门楣 840–1040", -- 589
			depth = LANE_ROAD, -- 589
			art = "wall" -- 589
		} -- 589
	}, -- 589
	zones = {{ -- 591
		x0 = 860, -- 592
		x1 = 1000, -- 592
		y = 0, -- 592
		h = 8, -- 592
		tint = 4, -- 592
		label = "门洞 860–1000" -- 592
	}}, -- 592
	arch = { -- 594
		x0 = 0, -- 594
		x1 = 0, -- 594
		y = 0, -- 594
		h = 0, -- 594
		label = "" -- 594
	}, -- 594
	stairs = {}, -- 595
	cart = { -- 596
		startX = 0, -- 596
		endX = 0, -- 596
		baseY = 0, -- 596
		bodyW = 0, -- 596
		bodyH = 0, -- 596
		wheelR = 0, -- 596
		handleOffset = 0, -- 596
		clothSide = 1 -- 596
	}, -- 596
	spawns = {{x = 130, y = 0, h = 88, label = "周戍 130"}, {x = 150, y = 0, h = 56, label = "小满 150"}}, -- 597
	marks = {{x = 118, y = 0, kind = 1, label = "绞盘站位 118"}, {x = 960, y = 0, kind = 1, label = "门洞等待点 960"}, {x = 860, y = 0, kind = 0, label = "门边 860"}, {x = 1020, y = 0, kind = 0, label = "出门 1020"}}, -- 601
	dims = {{x0 = 40, x1 = 100, text = "绞盘 60"}, {x0 = 840, x1 = 1040, text = "门洞 200"}}, -- 607
	story = {gate = { -- 612
		winchX = 118, -- 612
		waitX = 960, -- 612
		doorX = 860, -- 612
		exitX = 1020, -- 612
		holdTicks = 2700 -- 612
	}} -- 612
} -- 612
--- 城外巷路：男主线牵手成功后的可操控起步段。
-- 
-- 侧向跟拍，两人先牵着手过一段平路（0–780），到高石阶 780–860 抬 48 后
-- 进入下一段入口（860 平台）。上背与护送试炼发生在后续段，本房只交付
-- 「交回移动」之后的同行控制。
____exports.GATE_PATH_ROOM = { -- 622
	key = "gatepath", -- 623
	originX = 0, -- 624
	name = "城外巷路 · 兄妹同行", -- 625
	caption = "牵着手沿平路往北；到高石阶前停住，下一段从这里接背上她", -- 626
	minX = 0, -- 627
	maxX = 1040, -- 628
	height = 220, -- 629
	depth = {min = -28, max = 28}, -- 630
	floors = {{y = 0, x0 = 0, x1 = 1040}, {y = 48, x0 = 860, x1 = 1040}}, -- 631
	solids = {{ -- 635
		x = 0, -- 636
		w = 60, -- 636
		h = 180, -- 636
		y = 0, -- 636
		label = "城门内墙背影 0–60", -- 636
		depth = {min = -28, max = 28}, -- 636
		art = "wall" -- 636
	}, { -- 636
		x = 560, -- 637
		w = 44, -- 637
		h = 28, -- 637
		y = 0, -- 637
		label = "倒石 560 · 高 28", -- 637
		depth = {min = -28, max = -4}, -- 637
		art = "cover_stone" -- 637
	}, { -- 637
		x = 1000, -- 638
		w = 40, -- 638
		h = 200, -- 638
		y = 0, -- 638
		label = "巷尾石壁 1000", -- 638
		depth = {min = -28, max = 28}, -- 638
		art = "wall" -- 638
	}}, -- 638
	zones = {{ -- 640
		x0 = 860, -- 641
		x1 = 1000, -- 641
		y = 48, -- 641
		h = 6, -- 641
		tint = 4, -- 641
		label = "高石阶平台 860–1000" -- 641
	}}, -- 641
	arch = { -- 643
		x0 = 0, -- 643
		x1 = 0, -- 643
		y = 0, -- 643
		h = 0, -- 643
		label = "" -- 643
	}, -- 643
	stairs = {{ -- 644
		x0 = 780, -- 645
		x1 = 860, -- 645
		y0 = 0, -- 645
		y1 = 48, -- 645
		steps = 3, -- 645
		label = "高石阶 0 / 16 / 32 / 48", -- 645
		depth = {min = -28, max = 28} -- 645
	}}, -- 645
	cart = { -- 647
		startX = 0, -- 647
		endX = 0, -- 647
		baseY = 0, -- 647
		bodyW = 0, -- 647
		bodyH = 0, -- 647
		wheelR = 0, -- 647
		handleOffset = 0, -- 647
		clothSide = 1 -- 647
	}, -- 647
	spawns = {{x = 120, y = 0, h = 88, label = "周戍 120"}, {x = 150, y = 0, h = 56, label = "小满 150"}}, -- 648
	marks = {{x = 120, y = 0, kind = 1, label = "牵头起步 120"}, {x = 520, y = 0, kind = 3, label = "袖口红布 520"}, {x = 840, y = 0, kind = 0, label = "高石阶前 840"}, {x = 980, y = 48, kind = 0, label = "下一段入口 980"}}, -- 652
	dims = {{x0 = 0, x1 = 560, text = "平路 560"}, {x0 = 780, x1 = 860, text = "高石阶 80 · 抬 48"}, {x0 = 860, x1 = 1000, text = "平台 140"}}, -- 658
	story = {gatepath = {carryX = 840, exitX = 980, next = "escort1"}} -- 663
} -- 663
--- 北塔森林：小满独自走。草后可以等，狗听见脚步会转耳朵、赶来、停一会儿再回线。
-- 最后一段从林缘自己选时机走到灯下门廊。
____exports.FOREST_ROOM = { -- 670
	key = "forest", -- 671
	originX = 0, -- 672
	name = "北塔森林 · 草与狗", -- 673
	caption = "狗对动静比人快：草后等、Shift 慢走、蹲着过；林缘 1450 走到灯下门廊", -- 674
	minX = 0, -- 675
	maxX = 1600, -- 676
	height = 200, -- 677
	depth = LANE_ROAD, -- 678
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 679
	solids = {{ -- 680
		x = 300, -- 681
		w = 80, -- 681
		h = 24, -- 681
		y = 0, -- 681
		depth = LANE_ROAD, -- 681
		label = "草丛 300–380 · 高 24", -- 681
		passable = true -- 681
	}, { -- 681
		x = 700, -- 682
		w = 90, -- 682
		h = 24, -- 682
		y = 0, -- 682
		depth = LANE_ROAD, -- 682
		label = "草丛 700–790 · 高 24", -- 682
		passable = true -- 682
	}, { -- 682
		x = 1150, -- 683
		w = 90, -- 683
		h = 24, -- 683
		y = 0, -- 683
		depth = LANE_ROAD, -- 683
		label = "草丛 1150–1240 · 高 24", -- 683
		passable = true -- 683
	}, { -- 683
		x = 1560, -- 684
		w = 40, -- 684
		h = 160, -- 684
		y = 0, -- 684
		depth = LANE_ROAD, -- 684
		label = "林缘 1560" -- 684
	}}, -- 684
	zones = {{ -- 686
		x0 = 300, -- 687
		x1 = 380, -- 687
		y = 0, -- 687
		h = 6, -- 687
		tint = 2, -- 687
		label = "树根窄洞 300–380 · 蹲行" -- 687
	}, { -- 687
		x0 = 700, -- 688
		x1 = 790, -- 688
		y = 0, -- 688
		h = 6, -- 688
		tint = 3, -- 688
		label = "旧渠 700–790 · 可跑" -- 688
	}, { -- 688
		x0 = 1180, -- 689
		x1 = 1260, -- 689
		y = 0, -- 689
		h = 6, -- 689
		tint = 1, -- 689
		label = "溪湾 1180–1260 · 水里灯" -- 689
	}, { -- 689
		x0 = 1400, -- 690
		x1 = 1470, -- 690
		y = 0, -- 690
		h = 6, -- 690
		tint = 4, -- 690
		label = "林边 1400–1470" -- 690
	}}, -- 690
	arch = { -- 692
		x0 = 0, -- 692
		x1 = 0, -- 692
		y = 0, -- 692
		h = 0, -- 692
		label = "" -- 692
	}, -- 692
	stairs = {{ -- 693
		x0 = 520, -- 694
		x1 = 640, -- 694
		y0 = 22, -- 694
		y1 = 22, -- 694
		steps = 1, -- 694
		depth = LANE_ROAD, -- 694
		label = "矮台 520–640 · 高 22" -- 694
	}, { -- 694
		x0 = 980, -- 695
		x1 = 1100, -- 695
		y0 = 22, -- 695
		y1 = 22, -- 695
		steps = 1, -- 695
		depth = LANE_ROAD, -- 695
		label = "矮台 980–1100 · 高 22" -- 695
	}}, -- 695
	cart = { -- 697
		startX = 0, -- 697
		endX = 0, -- 697
		baseY = 0, -- 697
		bodyW = 0, -- 697
		bodyH = 0, -- 697
		wheelR = 0, -- 697
		handleOffset = 0, -- 697
		clothSide = 1 -- 697
	}, -- 697
	spawns = {{x = 120, y = 0, h = 56, label = "小满 120"}}, -- 698
	marks = {{x = 1450, y = 0, kind = 0, label = "林边安全点 1450"}, {x = 620, y = 0, kind = 3, label = "矮台 620"}, {x = 1220, y = 0, kind = 6, label = "溪湾水里灯 1220"}}, -- 699
	dims = {{x0 = 300, x1 = 380, text = "窄洞 80 · 蹲"}, {x0 = 700, x1 = 790, text = "旧渠 90 · 跑"}, {x0 = 1180, x1 = 1260, text = "溪湾 80"}, {x0 = 1400, x1 = 1470, text = "林边 70"}}, -- 704
	story = {dog = {x0 = 620, x1 = 780, speed = 56, range = 300}} -- 710
} -- 710
--- 塔门与尾声：小满走到门前，按一次 E 敲两下；守卫开门接过针套和纸条，
-- 在登记簿里给下一个人留出一行空白。片尾可以再玩。
____exports.TOWER_ROOM = { -- 717
	key = "tower", -- 718
	originX = 0, -- 719
	name = "北塔塔门与值夜室 · 尾声", -- 720
	caption = "门前点 E 叩两下；守卒回叩开门后跨过门槛，到桌前长按 E 交针套、指南针和纸条", -- 721
	minX = 0, -- 722
	maxX = 720, -- 723
	height = 220, -- 724
	depth = LANE_ROAD, -- 725
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 726
	solids = { -- 727
		{ -- 728
			x = 180, -- 728
			w = 220, -- 728
			h = 200, -- 728
			y = 0, -- 728
			depth = LANE_ROAD, -- 728
			label = "塔身左 180–400" -- 728
		}, -- 728
		{ -- 729
			x = 430, -- 729
			w = 40, -- 729
			h = 120, -- 729
			y = 0, -- 729
			depth = LANE_ROAD, -- 729
			id = "tower_door", -- 729
			label = "塔门 430–470 · E 叩两下" -- 729
		}, -- 729
		{ -- 730
			x = 700, -- 730
			w = 20, -- 730
			h = 220, -- 730
			y = 0, -- 730
			depth = LANE_ROAD, -- 730
			label = "塔身右墙 700–720" -- 730
		}, -- 730
		{ -- 731
			x = 400, -- 731
			w = 90, -- 731
			h = 30, -- 731
			y = 110, -- 731
			depth = LANE_ROAD, -- 731
			label = "门楣 400–490" -- 731
		}, -- 731
		{ -- 732
			x = 560, -- 732
			w = 90, -- 732
			h = 32, -- 732
			y = 0, -- 732
			depth = LANE_ROAD, -- 732
			id = "tower_desk", -- 732
			art = "cover_wood", -- 732
			label = "值夜桌 560–650 · 长按 E 交物" -- 732
		}, -- 732
		{ -- 733
			x = 660, -- 733
			w = 40, -- 733
			h = 8, -- 733
			y = 120, -- 733
			decorative = true, -- 733
			label = "西窗 660–700" -- 733
		} -- 733
	}, -- 733
	zones = {{ -- 735
		x0 = 400, -- 736
		x1 = 490, -- 736
		y = 0, -- 736
		h = 8, -- 736
		tint = 4, -- 736
		label = "门廊 400–490" -- 736
	}, { -- 736
		x0 = 490, -- 737
		x1 = 700, -- 737
		y = 0, -- 737
		h = 8, -- 737
		tint = 3, -- 737
		label = "值夜室 490–700" -- 737
	}}, -- 737
	arch = { -- 739
		x0 = 0, -- 739
		x1 = 0, -- 739
		y = 0, -- 739
		h = 0, -- 739
		label = "" -- 739
	}, -- 739
	stairs = {}, -- 740
	cart = { -- 741
		startX = 0, -- 741
		endX = 0, -- 741
		baseY = 0, -- 741
		bodyW = 0, -- 741
		bodyH = 0, -- 741
		wheelR = 0, -- 741
		handleOffset = 0, -- 741
		clothSide = 1 -- 741
	}, -- 741
	spawns = {{x = 400, y = 0, h = 56, label = "小满 400 · 门廊里"}}, -- 742
	marks = {{x = 445, y = 0, kind = 1, label = "门前 445"}, {x = 520, y = 0, kind = 3, label = "门槛 520"}, {x = 605, y = 0, kind = 3, label = "值夜桌 605"}, {x = 680, y = 0, kind = 6, label = "西窗 680"}}, -- 743
	dims = {{x0 = 400, x1 = 490, text = "门 90"}, {x0 = 560, x1 = 650, text = "桌 90"}}, -- 749
	story = {tower = {doorX = 445, knockTicks = 36}} -- 753
} -- 753
local NO_CART = { -- 756
	startX = 0, -- 757
	endX = 0, -- 757
	baseY = 0, -- 757
	bodyW = 0, -- 757
	bodyH = 0, -- 757
	wheelR = 0, -- 757
	handleOffset = 0, -- 757
	clothSide = -1 -- 757
} -- 757
--- C2 博物馆返场：一次「时间穿梭器」的虚构现代纪念厅。
-- 玩家单人（周戍）走完柜前、走廊、末厅、回柜边四步，每步一个输入边沿。
____exports.MUSEUM_ROOM = { -- 765
	key = "museum", -- 766
	name = "博物馆 · 西厅", -- 767
	caption = "虚构 · 现代纪念厅", -- 768
	originX = 0, -- 769
	minX = 0, -- 769
	maxX = 1400, -- 769
	height = 240, -- 769
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 770
	solids = { -- 771
		{ -- 772
			x = 180, -- 772
			w = 80, -- 772
			h = 64, -- 772
			y = 0, -- 772
			label = "玻璃柜 180–260 · 高 64", -- 772
			decorative = true, -- 772
			id = "museum_case" -- 772
		}, -- 772
		{ -- 773
			x = 540, -- 773
			w = 60, -- 773
			h = 140, -- 773
			y = 0, -- 773
			label = "展墙 540–600 · 高 140", -- 773
			decorative = true -- 773
		}, -- 773
		{ -- 774
			x = 1180, -- 774
			w = 40, -- 774
			h = 160, -- 774
			y = 0, -- 774
			label = "末厅门柱 1180–1220 · 高 160", -- 774
			decorative = true -- 774
		}, -- 774
		{ -- 775
			x = 1300, -- 775
			w = 60, -- 775
			h = 8, -- 775
			y = 120, -- 775
			label = "西窗 1300–1360 · 高 8", -- 775
			decorative = true -- 775
		}, -- 775
		{ -- 776
			x = 1360, -- 776
			w = 40, -- 776
			h = 200, -- 776
			y = 0, -- 776
			label = "馆尾 1360–1400 · 高 200" -- 776
		} -- 776
	}, -- 776
	zones = {{ -- 778
		x0 = 160, -- 779
		x1 = 300, -- 779
		y = 0, -- 779
		h = 16, -- 779
		tint = 1, -- 779
		label = "玻璃柜前" -- 779
	}, { -- 779
		x0 = 860, -- 780
		x1 = 980, -- 780
		y = 0, -- 780
		h = 16, -- 780
		tint = 2, -- 780
		label = "走廊 · 孩子脚步" -- 780
	}, { -- 780
		x0 = 1210, -- 781
		x1 = 1320, -- 781
		y = 0, -- 781
		h = 16, -- 781
		tint = 3, -- 781
		label = "末厅 · 西窗" -- 781
	}}, -- 781
	arch = { -- 783
		x0 = 0, -- 783
		x1 = 0, -- 783
		y = 0, -- 783
		h = 0, -- 783
		label = "" -- 783
	}, -- 783
	stairs = {}, -- 784
	cart = NO_CART, -- 785
	spawns = {{x = 80, y = 0, h = 88, label = "周戍 80 · 展厅入口"}}, -- 786
	marks = {{x = 200, y = 0, kind = 4, label = "玻璃柜 200"}, {x = 900, y = 0, kind = 4, label = "走廊 900"}, {x = 1250, y = 0, kind = 6, label = "末厅 1250"}, {x = 1360, y = 0, kind = 0, label = "出口 1360"}}, -- 787
	dims = {{x0 = 160, x1 = 300, text = "柜 80"}, {x0 = 1180, x1 = 1220, text = "门 40"}}, -- 793
	story = {museum = {cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}} -- 797
} -- 797
--- 男主首场护送战：背着受伤的小满穿过城外巷路。
-- 巷底两名火器手与一名破障手压过来，玩家边观察边完成一次慢时连线换弹，走到巷尾脱身。
____exports.ESCORT1_ROOM = { -- 804
	key = "escort1", -- 805
	originX = 0, -- 806
	name = "城外巷路 · 第一段护送", -- 807
	caption = "背上的小满贴着肩；巷底两名火器手与一名破障手压过来，走到巷尾就算脱身", -- 808
	minX = 0, -- 809
	maxX = 1600, -- 810
	height = 220, -- 811
	depth = LANE_ROAD, -- 812
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 813
	solids = { -- 814
		{ -- 815
			x = 0, -- 815
			w = 50, -- 815
			h = 150, -- 815
			y = 0, -- 815
			label = "巷口背影 0–50", -- 815
			depth = LANE_ROAD, -- 815
			art = "wall" -- 815
		}, -- 815
		{ -- 816
			x = 380, -- 816
			w = 96, -- 816
			h = 44, -- 816
			y = 0, -- 816
			label = "塌墙 380–476 · 高 44", -- 816
			lanes = {"lower", "middle"}, -- 816
			art = "cover_stone", -- 816
			id = "e1_wall" -- 816
		}, -- 816
		{ -- 817
			x = 620, -- 817
			w = 24, -- 817
			h = 50, -- 817
			y = 0, -- 817
			label = "薄木护板 620 · 高 50", -- 817
			lanes = {"upper"}, -- 817
			art = "cover_wood", -- 817
			id = "e1_wood", -- 817
			breakable = {hp = 2, kind = "thin_wood", wedgeable = true} -- 817
		}, -- 817
		{ -- 818
			x = 700, -- 818
			w = 40, -- 818
			h = 28, -- 818
			y = 0, -- 818
			label = "倒石 700 · 高 28", -- 818
			lanes = {"lower"}, -- 818
			art = "cover_stone" -- 818
		}, -- 818
		{ -- 819
			x = 980, -- 819
			w = 160, -- 819
			h = 36, -- 819
			y = 0, -- 819
			label = "石台 980–1140 · 高 36（可跳）", -- 819
			lanes = {"lower"}, -- 819
			art = "cover_wood" -- 819
		}, -- 819
		{ -- 820
			x = 1300, -- 820
			w = 40, -- 820
			h = 140, -- 820
			y = 0, -- 820
			label = "巷尾门柱 1300", -- 820
			lanes = {"lower", "upper"}, -- 820
			art = "gate_post" -- 820
		}, -- 820
		{ -- 821
			x = 1560, -- 821
			w = 40, -- 821
			h = 180, -- 821
			y = 0, -- 821
			label = "巷尾断墙 1560–1600 · 高 180", -- 821
			depth = LANE_ROAD, -- 821
			art = "wall" -- 821
		} -- 821
	}, -- 821
	zones = {{ -- 823
		x0 = 560, -- 823
		x1 = 900, -- 823
		y = 0, -- 823
		h = 150, -- 823
		tint = 1, -- 823
		label = "交火 560–900" -- 823
	}}, -- 823
	arch = { -- 824
		x0 = 0, -- 824
		x1 = 0, -- 824
		y = 0, -- 824
		h = 0, -- 824
		label = "" -- 824
	}, -- 824
	stairs = {{ -- 825
		x0 = 1140, -- 825
		x1 = 1300, -- 825
		y0 = 0, -- 825
		y1 = 40, -- 825
		steps = 3, -- 825
		label = "石台斜走 1140–1300", -- 825
		lanes = {"lower", "middle"} -- 825
	}}, -- 825
	cart = NO_CART, -- 826
	spawns = {{ -- 827
		x = 820, -- 828
		y = 0, -- 828
		h = 84, -- 828
		depth = 32, -- 828
		label = "火器手 820 · 中档", -- 828
		kind = "gunner", -- 828
		drop = "ammo" -- 828
	}, { -- 828
		x = 1020, -- 829
		y = 0, -- 829
		h = 84, -- 829
		depth = -28, -- 829
		label = "火器手 1020 · 浅档", -- 829
		kind = "gunner", -- 829
		drop = "ammo" -- 829
	}, { -- 829
		x = 1120, -- 830
		y = 0, -- 830
		h = 84, -- 830
		depth = -28, -- 830
		label = "破障手 1120", -- 830
		kind = "breaker", -- 830
		drop = "wedge" -- 830
	}}, -- 830
	marks = {{x = 200, y = 0, kind = 3, label = "背负起点 200"}, {x = 476, y = 0, kind = 3, label = "塌墙后 476"}, {x = 900, y = 0, kind = 0, label = "交火尽头 900"}, {x = 1500, y = 0, kind = 0, label = "安全出口 1500"}}, -- 832
	dims = {{x0 = 380, x1 = 476, text = "塌墙 96"}, {x0 = 980, x1 = 1140, text = "石台 160"}, {x0 = 1300, x1 = 1600, text = "巷尾 300"}}, -- 838
	campaign = { -- 843
		chapter = "O", -- 843
		act = 1, -- 843
		budget = 240, -- 843
		goal = "reach_exit", -- 843
		exitX = 1500, -- 843
		next = "escort2", -- 843
		checkpoint = 1, -- 843
		reloadPuzzle = true -- 843
	} -- 843
} -- 843
--- 第二段粮棚：从第一段巷尾转进粮棚，高低两条通路各放材料。
-- 上层棚架两枚木纹筹，地面一枚木纹筹与一枚铃纹筹——走齐两条通路才能凑够两种配方。
____exports.ESCORT2_ROOM = { -- 851
	key = "escort2", -- 852
	originX = 0, -- 853
	name = "粮棚 · 第二段取材", -- 854
	caption = "棚架与地面沿途收集：木纹筹两枚、铃纹筹一枚，够在工台二选一", -- 855
	minX = 0, -- 856
	maxX = 1500, -- 857
	height = 220, -- 858
	depth = LANE_ROAD, -- 859
	floors = {{y = 0, x0 = 0, x1 = 1500}}, -- 860
	solids = { -- 861
		{ -- 862
			x = 0, -- 862
			w = 50, -- 862
			h = 160, -- 862
			y = 0, -- 862
			label = "棚口背影 0–50", -- 862
			depth = LANE_ROAD, -- 862
			art = "wall" -- 862
		}, -- 862
		{ -- 863
			x = 300, -- 863
			w = 24, -- 863
			h = 64, -- 863
			y = 0, -- 863
			label = "棚架柱 300", -- 863
			lanes = {"lower"}, -- 863
			art = "cover_wood" -- 863
		}, -- 863
		{ -- 864
			x = 300, -- 864
			w = 600, -- 864
			h = 8, -- 864
			y = 64, -- 864
			label = "棚架梁 300–900 · 高 64", -- 864
			depth = {min = -44, max = -20}, -- 864
			passable = true, -- 864
			art = "cover_wood" -- 864
		}, -- 864
		{ -- 865
			x = 640, -- 865
			w = 60, -- 865
			h = 32, -- 865
			y = 0, -- 865
			label = "倒粮袋 640 · 高 32", -- 865
			lanes = {"lower"}, -- 865
			art = "grain_sack", -- 865
			id = "e2_grain_sacks" -- 865
		}, -- 865
		{ -- 866
			x = 980, -- 866
			w = 140, -- 866
			h = 48, -- 866
			y = 0, -- 866
			label = "粮台 980–1120 · 高 48", -- 866
			lanes = {"lower", "middle"}, -- 866
			art = "cover_wood" -- 866
		}, -- 866
		{ -- 867
			x = 1460, -- 867
			w = 40, -- 867
			h = 180, -- 867
			y = 0, -- 867
			label = "棚尾断墙 1460–1500 · 高 180", -- 867
			depth = LANE_ROAD, -- 867
			art = "wall" -- 867
		} -- 867
	}, -- 867
	zones = {{ -- 869
		x0 = 520, -- 869
		x1 = 900, -- 869
		y = 0, -- 869
		h = 150, -- 869
		tint = 1, -- 869
		label = "取材 520–900" -- 869
	}}, -- 869
	arch = { -- 870
		x0 = 0, -- 870
		x1 = 0, -- 870
		y = 0, -- 870
		h = 0, -- 870
		label = "" -- 870
	}, -- 870
	stairs = {{ -- 871
		x0 = 780, -- 871
		x1 = 900, -- 871
		y0 = 0, -- 871
		y1 = 64, -- 871
		steps = 3, -- 871
		label = "棚架斜梯 780–900", -- 871
		lanes = {"lower", "middle"} -- 871
	}}, -- 871
	cart = NO_CART, -- 872
	spawns = {{ -- 873
		x = 700, -- 874
		y = 0, -- 874
		h = 84, -- 874
		depth = 32, -- 874
		label = "火器手 700 · 中档", -- 874
		kind = "gunner", -- 874
		drop = "ammo" -- 874
	}, { -- 874
		x = 1080, -- 875
		y = 0, -- 875
		h = 84, -- 875
		depth = -28, -- 875
		label = "火器手 1080 · 浅档", -- 875
		kind = "gunner", -- 875
		drop = "ammo" -- 875
	}, { -- 875
		x = 1200, -- 876
		y = 0, -- 876
		h = 84, -- 876
		depth = 24, -- 876
		label = "破障手 1200", -- 876
		kind = "breaker", -- 876
		drop = "wedge" -- 876
	}}, -- 876
	marks = {{x = 200, y = 0, kind = 3, label = "进棚 200"}, {x = 476, y = 0, kind = 3, label = "棚架下 476"}, {x = 900, y = 0, kind = 0, label = "棚架尽头 900"}, {x = 1400, y = 0, kind = 0, label = "粮棚出口 1400"}}, -- 878
	dims = {{x0 = 300, x1 = 900, text = "棚架 600"}, {x0 = 980, x1 = 1120, text = "粮台 140"}}, -- 884
	pickups = {{ -- 888
		id = "e2_wood_a", -- 889
		kind = "wood", -- 889
		x = 380, -- 889
		y = 0, -- 889
		label = "木纹筹 · 棚下" -- 889
	}, { -- 889
		id = "e2_bell", -- 890
		kind = "bell", -- 890
		x = 560, -- 890
		y = 0, -- 890
		label = "铃纹筹 · 粮袋后" -- 890
	}, { -- 890
		id = "e2_wood_b", -- 891
		kind = "wood", -- 891
		x = 820, -- 891
		y = 0, -- 891
		label = "木纹筹 · 棚架后" -- 891
	}}, -- 891
	campaign = { -- 893
		chapter = "O", -- 893
		act = 2, -- 893
		budget = 240, -- 893
		goal = "reach_exit", -- 893
		exitX = 1400, -- 893
		next = "escort3", -- 893
		checkpoint = 1, -- 893
		reloadPuzzle = true -- 893
	} -- 893
} -- 893
--- 第三段安全工台：放下小满，看材料与两张配方，改制、装备、离站再背起。
-- 工台前的薄掩体与两个靶位用于当场试射：灯纹穿掩体、铃纹同时惊起两个声源。
____exports.ESCORT3_ROOM = { -- 900
	key = "escort3", -- 901
	originX = 0, -- 902
	name = "山腰工台 · 第三段改制", -- 903
	caption = "放下小满 → 工台按 E 看配方 → 选一件改制装备 → 试射一枪 → 离站重新背起", -- 904
	minX = 0, -- 905
	maxX = 1200, -- 906
	height = 220, -- 907
	depth = LANE_ROAD, -- 908
	floors = {{y = 0, x0 = 0, x1 = 1200}}, -- 909
	solids = { -- 910
		{ -- 911
			x = 0, -- 911
			w = 50, -- 911
			h = 160, -- 911
			y = 0, -- 911
			label = "工台口背影 0–50", -- 911
			depth = LANE_ROAD, -- 911
			art = "wall" -- 911
		}, -- 911
		{ -- 912
			x = 560, -- 912
			w = 120, -- 912
			h = 44, -- 912
			y = 0, -- 912
			label = "工台 560–680 · 高 44", -- 912
			lanes = {"middle", "upper"}, -- 912
			art = "cover_wood", -- 912
			id = "e3_bench" -- 912
		}, -- 912
		{ -- 913
			x = 720, -- 913
			w = 48, -- 913
			h = 52, -- 913
			y = 0, -- 913
			label = "试射薄掩体 720–768 · 高 52", -- 913
			lanes = {"lower", "middle"}, -- 913
			art = "cover_stone", -- 913
			id = "e3_cover" -- 913
		}, -- 913
		{ -- 914
			x = 1050, -- 914
			w = 40, -- 914
			h = 140, -- 914
			y = 0, -- 914
			label = "出站门柱 1050", -- 914
			lanes = {"lower", "upper"}, -- 914
			art = "gate_post" -- 914
		}, -- 914
		{ -- 915
			x = 1170, -- 915
			w = 30, -- 915
			h = 180, -- 915
			y = 0, -- 915
			label = "出站断墙 1170–1200 · 高 180", -- 915
			depth = LANE_ROAD, -- 915
			art = "wall" -- 915
		} -- 915
	}, -- 915
	zones = {{ -- 917
		x0 = 560, -- 917
		x1 = 960, -- 917
		y = 0, -- 917
		h = 120, -- 917
		tint = 3, -- 917
		label = "工台安全区 560–960" -- 917
	}}, -- 917
	arch = { -- 918
		x0 = 0, -- 918
		x1 = 0, -- 918
		y = 0, -- 918
		h = 0, -- 918
		label = "" -- 918
	}, -- 918
	stairs = {}, -- 919
	cart = NO_CART, -- 920
	spawns = {{ -- 921
		x = 820, -- 922
		y = 0, -- 922
		h = 84, -- 922
		depth = 16, -- 922
		label = "试射靶一 820", -- 922
		kind = "target" -- 922
	}, { -- 922
		x = 940, -- 923
		y = 0, -- 923
		h = 84, -- 923
		depth = -16, -- 923
		label = "试射靶二 940", -- 923
		kind = "target" -- 923
	}}, -- 923
	marks = {{x = 300, y = 0, kind = 0, label = "制前检查点 300"}, {x = 640, y = 0, kind = 3, label = "工台 640"}, {x = 960, y = 0, kind = 0, label = "制后检查点 960"}, {x = 1150, y = 0, kind = 0, label = "出站 1150"}}, -- 925
	dims = {{x0 = 560, x1 = 680, text = "工台 120"}, {x0 = 720, x1 = 768, text = "掩体 48"}}, -- 931
	campaign = { -- 935
		chapter = "O", -- 935
		act = 3, -- 935
		budget = 240, -- 935
		goal = "reach_exit", -- 935
		exitX = 1150, -- 935
		next = "escort4", -- 935
		checkpoint = 1, -- 935
		reloadPuzzle = true -- 935
	} -- 935
} -- 935
--- 第四段山道：边走边换弹的窄道，塌方与追兵逼玩家在换弹与脱身之间选。
____exports.ESCORT4_ROOM = { -- 941
	key = "escort4", -- 942
	originX = 0, -- 943
	name = "山道 · 第四段脱身", -- 944
	caption = "窄道上两个火器手与一个破障手；换弹时世界会慢下来，也可以滚身脱出", -- 945
	minX = 0, -- 946
	maxX = 1400, -- 947
	height = 240, -- 948
	depth = LANE_ROAD, -- 949
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 950
	solids = { -- 951
		{ -- 952
			x = 0, -- 952
			w = 50, -- 952
			h = 170, -- 952
			y = 0, -- 952
			label = "山道口 0–50", -- 952
			depth = LANE_ROAD, -- 952
			art = "wall" -- 952
		}, -- 952
		{ -- 953
			x = 380, -- 953
			w = 80, -- 953
			h = 40, -- 953
			y = 0, -- 953
			label = "塌方 380–460 · 高 40", -- 953
			lanes = {"lower", "middle"}, -- 953
			art = "cover_stone", -- 953
			id = "e4_fall" -- 953
		}, -- 953
		{ -- 954
			x = 680, -- 954
			w = 24, -- 954
			h = 50, -- 954
			y = 0, -- 954
			label = "薄木护板 680 · 高 50", -- 954
			lanes = {"upper"}, -- 954
			art = "cover_wood", -- 954
			id = "e4_wood", -- 954
			breakable = {hp = 2, kind = "thin_wood", wedgeable = true} -- 954
		}, -- 954
		{ -- 955
			x = 900, -- 955
			w = 60, -- 955
			h = 36, -- 955
			y = 0, -- 955
			label = "断口 900–960 · 高 36（可跳）", -- 955
			lanes = {"lower", "middle"}, -- 955
			art = "cover_stone" -- 955
		}, -- 955
		{ -- 956
			x = 1120, -- 956
			w = 40, -- 956
			h = 32, -- 956
			y = 0, -- 956
			label = "倒石 1120 · 高 32", -- 956
			lanes = {"lower"}, -- 956
			art = "cover_stone" -- 956
		}, -- 956
		{ -- 957
			x = 1350, -- 957
			w = 50, -- 957
			h = 200, -- 957
			y = 0, -- 957
			label = "山道尾壁 1350–1400 · 高 200", -- 957
			depth = LANE_ROAD, -- 957
			art = "wall" -- 957
		} -- 957
	}, -- 957
	zones = {{ -- 959
		x0 = 500, -- 959
		x1 = 900, -- 959
		y = 0, -- 959
		h = 160, -- 959
		tint = 2, -- 959
		label = "窄道 500–900" -- 959
	}}, -- 959
	arch = { -- 960
		x0 = 0, -- 960
		x1 = 0, -- 960
		y = 0, -- 960
		h = 0, -- 960
		label = "" -- 960
	}, -- 960
	stairs = {}, -- 961
	cart = NO_CART, -- 962
	spawns = {{ -- 963
		x = 620, -- 964
		y = 0, -- 964
		h = 84, -- 964
		depth = 32, -- 964
		label = "火器手 620 · 中档", -- 964
		kind = "gunner", -- 964
		drop = "ammo" -- 964
	}, { -- 964
		x = 840, -- 965
		y = 0, -- 965
		h = 84, -- 965
		depth = -28, -- 965
		label = "火器手 840 · 浅档", -- 965
		kind = "gunner", -- 965
		drop = "ammo" -- 965
	}, { -- 965
		x = 1060, -- 966
		y = 0, -- 966
		h = 84, -- 966
		depth = 24, -- 966
		label = "破障手 1060", -- 966
		kind = "breaker", -- 966
		drop = "wedge" -- 966
	}}, -- 966
	marks = {{x = 200, y = 0, kind = 3, label = "进山道 200"}, {x = 476, y = 0, kind = 3, label = "塌方后 476"}, {x = 960, y = 0, kind = 0, label = "断口 960"}, {x = 1300, y = 0, kind = 0, label = "山道出口 1300"}}, -- 968
	dims = {{x0 = 380, x1 = 460, text = "塌方 80"}, {x0 = 900, x1 = 960, text = "断口 60"}}, -- 974
	campaign = { -- 978
		chapter = "O", -- 978
		act = 4, -- 978
		budget = 240, -- 978
		goal = "reach_exit", -- 978
		exitX = 1300, -- 978
		next = "escort5", -- 978
		checkpoint = 1, -- 978
		reloadPuzzle = true -- 978
	} -- 978
} -- 978
--- 第五段山道：带着自己改制的武器走到塔门；出口直接接北塔。
____exports.ESCORT5_ROOM = { -- 984
	key = "escort5", -- 985
	originX = 0, -- 986
	name = "塔前山道 · 第五段", -- 987
	caption = "最后一段：带自己的武器走到塔门，走到 1320 就进北塔", -- 988
	minX = 0, -- 989
	maxX = 1400, -- 990
	height = 240, -- 991
	depth = LANE_ROAD, -- 992
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 993
	solids = { -- 994
		{ -- 995
			x = 0, -- 995
			w = 50, -- 995
			h = 170, -- 995
			y = 0, -- 995
			label = "山道口 0–50", -- 995
			depth = LANE_ROAD, -- 995
			art = "wall" -- 995
		}, -- 995
		{ -- 996
			x = 320, -- 996
			w = 96, -- 996
			h = 44, -- 996
			y = 0, -- 996
			label = "石阶塌墙 320–416 · 高 44", -- 996
			lanes = {"lower", "middle"}, -- 996
			art = "cover_stone", -- 996
			id = "e5_wall" -- 996
		}, -- 996
		{ -- 997
			x = 700, -- 997
			w = 160, -- 997
			h = 36, -- 997
			y = 0, -- 997
			label = "石台 700–860 · 高 36（可跳）", -- 997
			lanes = {"lower"}, -- 997
			art = "cover_wood" -- 997
		}, -- 997
		{ -- 998
			x = 1050, -- 998
			w = 40, -- 998
			h = 140, -- 998
			y = 0, -- 998
			label = "塔前门柱 1050", -- 998
			lanes = {"lower", "upper"}, -- 998
			art = "gate_post" -- 998
		}, -- 998
		{ -- 999
			x = 1370, -- 999
			w = 30, -- 999
			h = 200, -- 999
			y = 0, -- 999
			label = "塔前壁 1370–1400 · 高 200", -- 999
			depth = LANE_ROAD, -- 999
			art = "wall" -- 999
		} -- 999
	}, -- 999
	zones = {{ -- 1001
		x0 = 600, -- 1001
		x1 = 960, -- 1001
		y = 0, -- 1001
		h = 160, -- 1001
		tint = 4, -- 1001
		label = "塔前 600–960" -- 1001
	}}, -- 1001
	arch = { -- 1002
		x0 = 0, -- 1002
		x1 = 0, -- 1002
		y = 0, -- 1002
		h = 0, -- 1002
		label = "" -- 1002
	}, -- 1002
	stairs = {{ -- 1003
		x0 = 860, -- 1003
		x1 = 980, -- 1003
		y0 = 0, -- 1003
		y1 = 40, -- 1003
		steps = 3, -- 1003
		label = "石台斜走 860–980", -- 1003
		lanes = {"lower", "middle"} -- 1003
	}}, -- 1003
	cart = NO_CART, -- 1004
	spawns = {{ -- 1005
		x = 560, -- 1006
		y = 0, -- 1006
		h = 84, -- 1006
		depth = 32, -- 1006
		label = "火器手 560 · 中档", -- 1006
		kind = "gunner", -- 1006
		drop = "ammo" -- 1006
	}, { -- 1006
		x = 780, -- 1007
		y = 0, -- 1007
		h = 84, -- 1007
		depth = -28, -- 1007
		label = "火器手 780 · 浅档", -- 1007
		kind = "gunner", -- 1007
		drop = "ammo" -- 1007
	}, { -- 1007
		x = 980, -- 1008
		y = 0, -- 1008
		h = 84, -- 1008
		depth = 24, -- 1008
		label = "持盾手 980", -- 1008
		kind = "shield", -- 1008
		drop = "shield" -- 1008
	}}, -- 1008
	marks = {{x = 200, y = 0, kind = 3, label = "进塔前 200"}, {x = 476, y = 0, kind = 3, label = "塌墙后 476"}, {x = 960, y = 0, kind = 0, label = "塔前 960"}, {x = 1320, y = 0, kind = 0, label = "塔门 1320"}}, -- 1010
	dims = {{x0 = 320, x1 = 416, text = "塌墙 96"}, {x0 = 700, x1 = 860, text = "石台 160"}}, -- 1016
	campaign = { -- 1020
		chapter = "O", -- 1020
		act = 5, -- 1020
		budget = 240, -- 1020
		goal = "reach_exit", -- 1020
		exitX = 1320, -- 1020
		next = "tower", -- 1020
		checkpoint = 1, -- 1020
		reloadPuzzle = true -- 1020
	} -- 1020
} -- 1020
--- 男主线五段护送（escort1 / escort2 / escort4 / escort5）的种子驱动遭遇变体池：
-- - 变体 0 与房间默认 spawns 完全一致（兼容基准回放与调试夹具）；
-- - 变体 1 / 变体 2 在正式与章节男主线按 (seed, attempt, roomKey) 确定性切换敌兵编组与掉落，
--   让每轮护送与倒地重开具备真正的局内战术变化。
____exports.ESCORT_VARIANTS = {escort1 = {____exports.ESCORT1_ROOM.spawns, {{ -- 1029
	x = 760, -- 1033
	y = 0, -- 1033
	h = 84, -- 1033
	depth = 28, -- 1033
	label = "火器手 760 · 上档", -- 1033
	kind = "gunner", -- 1033
	drop = "ammo" -- 1033
}, { -- 1033
	x = 940, -- 1034
	y = 0, -- 1034
	h = 84, -- 1034
	depth = 0, -- 1034
	label = "破障手 940 · 中档", -- 1034
	kind = "breaker", -- 1034
	drop = "wedge" -- 1034
}, { -- 1034
	x = 1140, -- 1035
	y = 0, -- 1035
	h = 84, -- 1035
	depth = -24, -- 1035
	label = "火器手 1140 · 浅档", -- 1035
	kind = "gunner", -- 1035
	drop = "ammo" -- 1035
}, { -- 1035
	x = 1260, -- 1036
	y = 0, -- 1036
	h = 84, -- 1036
	depth = 24, -- 1036
	label = "破障手 1260 · 上档", -- 1036
	kind = "breaker", -- 1036
	drop = "wedge" -- 1036
}}, {{ -- 1036
	x = 800, -- 1039
	y = 0, -- 1039
	h = 84, -- 1039
	depth = 0, -- 1039
	label = "持盾手 800 · 中档", -- 1039
	kind = "shield", -- 1039
	drop = "shield" -- 1039
}, { -- 1039
	x = 1020, -- 1040
	y = 0, -- 1040
	h = 84, -- 1040
	depth = 32, -- 1040
	label = "火器手 1020 · 上档", -- 1040
	kind = "gunner", -- 1040
	drop = "ammo" -- 1040
}, { -- 1040
	x = 1180, -- 1041
	y = 0, -- 1041
	h = 84, -- 1041
	depth = -28, -- 1041
	label = "火器手 1180 · 浅档", -- 1041
	kind = "gunner", -- 1041
	drop = "ammo" -- 1041
}}}, escort2 = {____exports.ESCORT2_ROOM.spawns, {{ -- 1041
	x = 680, -- 1047
	y = 0, -- 1047
	h = 84, -- 1047
	depth = -24, -- 1047
	label = "破障手 680 · 浅档", -- 1047
	kind = "breaker", -- 1047
	drop = "wedge" -- 1047
}, { -- 1047
	x = 920, -- 1048
	y = 0, -- 1048
	h = 84, -- 1048
	depth = 32, -- 1048
	label = "火器手 920 · 上档", -- 1048
	kind = "gunner", -- 1048
	drop = "ammo" -- 1048
}, { -- 1048
	x = 1140, -- 1049
	y = 0, -- 1049
	h = 84, -- 1049
	depth = 20, -- 1049
	label = "破障手 1140 · 上档", -- 1049
	kind = "breaker", -- 1049
	drop = "wedge" -- 1049
}, { -- 1049
	x = 1260, -- 1050
	y = 0, -- 1050
	h = 84, -- 1050
	depth = -20, -- 1050
	label = "火器手 1260 · 浅档", -- 1050
	kind = "gunner", -- 1050
	drop = "ammo" -- 1050
}}, {{ -- 1050
	x = 640, -- 1053
	y = 0, -- 1053
	h = 84, -- 1053
	depth = 32, -- 1053
	label = "火器手 640 · 上档", -- 1053
	kind = "gunner", -- 1053
	drop = "ammo" -- 1053
}, { -- 1053
	x = 880, -- 1054
	y = 0, -- 1054
	h = 84, -- 1054
	depth = 0, -- 1054
	label = "持盾手 880 · 中档", -- 1054
	kind = "shield", -- 1054
	drop = "shield" -- 1054
}, { -- 1054
	x = 1140, -- 1055
	y = 0, -- 1055
	h = 84, -- 1055
	depth = -28, -- 1055
	label = "火器手 1140 · 浅档", -- 1055
	kind = "gunner", -- 1055
	drop = "ammo" -- 1055
}}}, escort4 = {____exports.ESCORT4_ROOM.spawns, {{ -- 1055
	x = 580, -- 1061
	y = 0, -- 1061
	h = 84, -- 1061
	depth = -24, -- 1061
	label = "火器手 580 · 浅档", -- 1061
	kind = "gunner", -- 1061
	drop = "ammo" -- 1061
}, { -- 1061
	x = 780, -- 1062
	y = 0, -- 1062
	h = 84, -- 1062
	depth = 16, -- 1062
	label = "破障手 780 · 中档", -- 1062
	kind = "breaker", -- 1062
	drop = "wedge" -- 1062
}, { -- 1062
	x = 980, -- 1063
	y = 0, -- 1063
	h = 84, -- 1063
	depth = -16, -- 1063
	label = "持盾手 980 · 浅档", -- 1063
	kind = "shield", -- 1063
	drop = "shield" -- 1063
}, { -- 1063
	x = 1140, -- 1064
	y = 0, -- 1064
	h = 84, -- 1064
	depth = 28, -- 1064
	label = "火器手 1140 · 上档", -- 1064
	kind = "gunner", -- 1064
	drop = "ammo" -- 1064
}}, {{ -- 1064
	x = 640, -- 1067
	y = 0, -- 1067
	h = 84, -- 1067
	depth = 16, -- 1067
	label = "持盾手 640 · 中档", -- 1067
	kind = "shield", -- 1067
	drop = "shield" -- 1067
}, { -- 1067
	x = 820, -- 1068
	y = 0, -- 1068
	h = 84, -- 1068
	depth = -28, -- 1068
	label = "火器手 820 · 浅档", -- 1068
	kind = "gunner", -- 1068
	drop = "ammo" -- 1068
}, { -- 1068
	x = 1020, -- 1069
	y = 0, -- 1069
	h = 84, -- 1069
	depth = 0, -- 1069
	label = "破障手 1020 · 中档", -- 1069
	kind = "breaker", -- 1069
	drop = "wedge" -- 1069
}, { -- 1069
	x = 1180, -- 1070
	y = 0, -- 1070
	h = 84, -- 1070
	depth = 28, -- 1070
	label = "火器手 1180 · 上档", -- 1070
	kind = "gunner", -- 1070
	drop = "ammo" -- 1070
}}}, escort5 = {____exports.ESCORT5_ROOM.spawns, {{ -- 1070
	x = 520, -- 1076
	y = 0, -- 1076
	h = 84, -- 1076
	depth = -24, -- 1076
	label = "火器手 520 · 浅档", -- 1076
	kind = "gunner", -- 1076
	drop = "ammo" -- 1076
}, { -- 1076
	x = 740, -- 1077
	y = 0, -- 1077
	h = 84, -- 1077
	depth = 16, -- 1077
	label = "持盾手 740 · 中档", -- 1077
	kind = "shield", -- 1077
	drop = "shield" -- 1077
}, { -- 1077
	x = 920, -- 1078
	y = 0, -- 1078
	h = 84, -- 1078
	depth = -20, -- 1078
	label = "破障手 920 · 浅档", -- 1078
	kind = "breaker", -- 1078
	drop = "wedge" -- 1078
}, { -- 1078
	x = 1100, -- 1079
	y = 0, -- 1079
	h = 84, -- 1079
	depth = 28, -- 1079
	label = "火器手 1100 · 上档", -- 1079
	kind = "gunner", -- 1079
	drop = "ammo" -- 1079
}}, {{ -- 1079
	x = 580, -- 1082
	y = 0, -- 1082
	h = 84, -- 1082
	depth = 0, -- 1082
	label = "持盾手 580 · 中档", -- 1082
	kind = "shield", -- 1082
	drop = "shield" -- 1082
}, { -- 1082
	x = 760, -- 1083
	y = 0, -- 1083
	h = 84, -- 1083
	depth = 32, -- 1083
	label = "火器手 760 · 上档", -- 1083
	kind = "gunner", -- 1083
	drop = "ammo" -- 1083
}, { -- 1083
	x = 940, -- 1084
	y = 0, -- 1084
	h = 84, -- 1084
	depth = -28, -- 1084
	label = "火器手 940 · 浅档", -- 1084
	kind = "gunner", -- 1084
	drop = "ammo" -- 1084
}, { -- 1084
	x = 1100, -- 1085
	y = 0, -- 1085
	h = 84, -- 1085
	depth = 16, -- 1085
	label = "持盾手 1100 · 中档", -- 1085
	kind = "shield", -- 1085
	drop = "shield" -- 1085
}}}} -- 1085
--- S1 十字街：同一个街口先教单方向火器，再让破障手从街角压近。
-- 外檐线与布行线都从这里的出口分叉；井背是退回点，窗台是可选的翻窗捷径。
____exports.S1_CROSSROAD = { -- 1094
	key = "s1-crossroad", -- 1095
	name = "S1 · 十字街", -- 1096
	caption = "井背 → 摊后窄道 → 观察转角 → 街角压近者。薄木挡与窗台分别通向 S2 的两条线。", -- 1097
	originX = 0, -- 1098
	minX = 0, -- 1099
	maxX = 1600, -- 1100
	height = 220, -- 1101
	depth = LANE_ROAD, -- 1102
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 1103
	solids = { -- 1104
		{ -- 1105
			x = 180, -- 1105
			w = 88, -- 1105
			h = 56, -- 1105
			y = 0, -- 1105
			label = "井背 180–268 · 高 56", -- 1105
			lanes = {"lower"}, -- 1105
			art = "cover_stone", -- 1105
			id = "s1_well" -- 1105
		}, -- 1105
		{ -- 1106
			x = 360, -- 1106
			w = 160, -- 1106
			h = 44, -- 1106
			y = 0, -- 1106
			label = "摊后柜台 360–520 · 高 44", -- 1106
			lanes = {"lower", "middle"}, -- 1106
			art = "cover_wood" -- 1106
		}, -- 1106
		{ -- 1107
			x = 620, -- 1107
			w = 44, -- 1107
			h = 24, -- 1107
			y = 0, -- 1107
			label = "观察转角石基 620–664 · 高 24", -- 1107
			lanes = {"lower"}, -- 1107
			art = "cover_stone" -- 1107
		}, -- 1107
		{ -- 1108
			x = 1130, -- 1108
			w = 20, -- 1108
			h = 120, -- 1108
			y = 0, -- 1108
			label = "窗柱左", -- 1108
			lanes = {"upper"}, -- 1108
			art = "wall" -- 1108
		}, -- 1108
		{ -- 1109
			x = 1150, -- 1109
			w = 80, -- 1109
			h = 44, -- 1109
			y = 0, -- 1109
			label = "窗台 1150–1230 · 高 44", -- 1109
			lanes = {"upper"}, -- 1109
			art = "cover_wood" -- 1109
		}, -- 1109
		{ -- 1110
			x = 1230, -- 1110
			w = 20, -- 1110
			h = 120, -- 1110
			y = 0, -- 1110
			label = "窗柱右", -- 1110
			lanes = {"upper"}, -- 1110
			art = "wall" -- 1110
		}, -- 1110
		{ -- 1111
			x = 1460, -- 1111
			w = 40, -- 1111
			h = 140, -- 1111
			y = 0, -- 1111
			label = "街尾门柱", -- 1111
			lanes = {"lower", "upper"}, -- 1111
			art = "gate_post" -- 1111
		} -- 1111
	}, -- 1111
	zones = {{ -- 1113
		x0 = 700, -- 1113
		x1 = 960, -- 1113
		y = 0, -- 1113
		h = 150, -- 1113
		tint = 1, -- 1113
		label = "街角交火 700–960" -- 1113
	}}, -- 1113
	arch = { -- 1114
		x0 = 0, -- 1114
		x1 = 0, -- 1114
		y = 0, -- 1114
		h = 0, -- 1114
		label = "" -- 1114
	}, -- 1114
	stairs = {{ -- 1115
		x0 = 900, -- 1115
		x1 = 1040, -- 1115
		y0 = 0, -- 1115
		y1 = 40, -- 1115
		steps = 4, -- 1115
		label = "石基斜走 900–1040 · 高 40", -- 1115
		lanes = {"lower", "middle"} -- 1115
	}}, -- 1115
	cart = NO_CART, -- 1116
	spawns = {{ -- 1117
		x = 760, -- 1118
		y = 0, -- 1118
		h = 84, -- 1118
		depth = 32, -- 1118
		label = "单方向火器手 760", -- 1118
		kind = "gunner", -- 1118
		drop = "ammo" -- 1118
	}, { -- 1118
		x = 880, -- 1119
		y = 0, -- 1119
		h = 84, -- 1119
		label = "街角压近者 880", -- 1119
		kind = "breaker", -- 1119
		drop = "wedge" -- 1119
	}}, -- 1119
	marks = {{x = 220, y = 0, kind = 1, label = "井背安全点 220"}, {x = 640, y = 0, kind = 0, label = "观察转角 640"}, {x = 1190, y = 0, kind = 0, label = "窗台捷径 1190"}, {x = 1500, y = 0, kind = 0, label = "出口 1500"}}, -- 1121
	dims = {{x0 = 180, x1 = 268, text = "井 88"}, {x0 = 360, x1 = 520, text = "柜台 160"}, {x0 = 900, x1 = 1040, text = "石基 140"}}, -- 1127
	companion = {waitX = 220, waitDepth = -32, joinX = 900}, -- 1132
	campaign = { -- 1133
		chapter = "S", -- 1133
		act = 1, -- 1133
		budget = 210, -- 1133
		goal = "reach_exit", -- 1133
		next = "s2-drygoods", -- 1133
		exitX = 1500, -- 1133
		checkpoint = 1 -- 1133
	} -- 1133
} -- 1133
--- S2 布行与外檐：近檐柱下短跨、可碎摊挡与转角装卸面是一条线；
-- 从染布架侧面进布行、绕柜到窗板背后放板、后仓折回是另一条线。两条线同通牌楼。
____exports.S2_DRYGOODS = { -- 1140
	key = "s2-drygoods", -- 1141
	name = "S2 · 布行与外檐", -- 1142
	caption = "近檐：檐柱短跨、薄木摊挡、装卸面。远帘：染布架入内、绕柜、放窗板、后仓折回。两路同通牌楼。", -- 1143
	originX = 1600, -- 1144
	minX = 0, -- 1145
	maxX = 1800, -- 1146
	height = 230, -- 1147
	depth = LANE_ROAD, -- 1148
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 1149
	pickups = {{ -- 1150
		id = "s2_scrap_1", -- 1151
		kind = "scrap", -- 1151
		x = 520, -- 1151
		y = 0, -- 1151
		depth = 0, -- 1151
		label = "废木料 · 薄木摊挡脚下" -- 1151
	}, { -- 1151
		id = "s2_scrap_2", -- 1152
		kind = "scrap", -- 1152
		x = 760, -- 1152
		y = 0, -- 1152
		depth = 0, -- 1152
		label = "废木料 · 装卸面旁" -- 1152
	}}, -- 1152
	solids = { -- 1154
		{ -- 1155
			x = 100, -- 1155
			w = 24, -- 1155
			h = 130, -- 1155
			y = 0, -- 1155
			label = "檐柱 100", -- 1155
			lanes = {"middle"}, -- 1155
			art = "cover_wood" -- 1155
		}, -- 1155
		{ -- 1156
			x = 240, -- 1156
			w = 24, -- 1156
			h = 130, -- 1156
			y = 0, -- 1156
			label = "檐柱 240", -- 1156
			lanes = {"middle"}, -- 1156
			art = "cover_wood" -- 1156
		}, -- 1156
		{ -- 1157
			x = 460, -- 1158
			w = 100, -- 1158
			h = 48, -- 1158
			y = 0, -- 1158
			label = "薄木摊挡 460–560 · 高 48", -- 1158
			lanes = {"middle", "upper"}, -- 1158
			art = "thin_wood", -- 1159
			id = "s2_wood", -- 1159
			breakable = {kind = "thin_wood", hp = 2, wedgeHp = 1} -- 1159
		}, -- 1159
		{ -- 1161
			x = 560, -- 1161
			w = 36, -- 1161
			h = 130, -- 1161
			y = 0, -- 1161
			label = "永久石柱 560–596", -- 1161
			lanes = {"upper"}, -- 1161
			art = "cover_stone" -- 1161
		}, -- 1161
		{ -- 1162
			x = 700, -- 1162
			w = 120, -- 1162
			h = 32, -- 1162
			y = 0, -- 1162
			label = "转角装卸面 700–820 · 高 32", -- 1162
			lanes = {"middle"}, -- 1162
			art = "cover_stone" -- 1162
		}, -- 1162
		{ -- 1163
			x = 340, -- 1163
			w = 120, -- 1163
			h = 44, -- 1163
			y = 0, -- 1163
			label = "布行柜台 340–460 · 高 44", -- 1163
			lanes = {"upper"}, -- 1163
			art = "cover_wood" -- 1163
		}, -- 1163
		{ -- 1164
			x = 600, -- 1165
			w = 80, -- 1165
			h = 72, -- 1165
			y = 0, -- 1165
			label = "窗板背后 600–680", -- 1165
			lanes = {"upper"}, -- 1165
			art = "board", -- 1166
			id = "s2_board", -- 1166
			interact = {kind = "open_board", reach = 46} -- 1166
		}, -- 1166
		{ -- 1168
			x = 600, -- 1169
			w = 80, -- 1169
			h = 40, -- 1169
			y = 0, -- 1169
			label = "放下的窗板 600–680", -- 1169
			lanes = {"lower"}, -- 1169
			art = "board", -- 1170
			id = "s2_board_cover", -- 1170
			soft = true, -- 1170
			hidden = true -- 1170
		}, -- 1170
		{ -- 1172
			x = 1560, -- 1172
			w = 30, -- 1172
			h = 150, -- 1172
			y = 0, -- 1172
			label = "牌楼左柱", -- 1172
			lanes = {"lower", "upper"}, -- 1172
			art = "gate_post" -- 1172
		}, -- 1172
		{ -- 1173
			x = 1700, -- 1173
			w = 30, -- 1173
			h = 150, -- 1173
			y = 0, -- 1173
			label = "牌楼右柱", -- 1173
			lanes = {"lower", "upper"}, -- 1173
			art = "gate_post" -- 1173
		} -- 1173
	}, -- 1173
	zones = {{ -- 1175
		x0 = 640, -- 1175
		x1 = 1300, -- 1175
		y = 0, -- 1175
		h = 150, -- 1175
		tint = 1, -- 1175
		label = "转角装卸面交火 700–1200" -- 1175
	}}, -- 1175
	arch = { -- 1176
		x0 = 0, -- 1176
		x1 = 0, -- 1176
		y = 0, -- 1176
		h = 0, -- 1176
		label = "" -- 1176
	}, -- 1176
	stairs = {}, -- 1177
	cart = NO_CART, -- 1178
	spawns = {{ -- 1179
		x = 940, -- 1180
		y = 0, -- 1180
		h = 84, -- 1180
		depth = 0, -- 1180
		label = "持盾手 940", -- 1180
		kind = "shield", -- 1180
		shieldHp = 2, -- 1180
		drop = "shield" -- 1180
	}, { -- 1180
		x = 1060, -- 1181
		y = 0, -- 1181
		h = 84, -- 1181
		depth = 32, -- 1181
		label = "远侧火器手 1060", -- 1181
		kind = "gunner", -- 1181
		drop = "ammo" -- 1181
	}, { -- 1181
		x = 1140, -- 1182
		y = 0, -- 1182
		h = 84, -- 1182
		depth = 0, -- 1182
		label = "破障手 1140", -- 1182
		kind = "breaker", -- 1182
		drop = "wedge" -- 1182
	}}, -- 1182
	marks = {{x = 640, y = 0, kind = 1, label = "窗板后等待位 640"}, {x = 900, y = 0, kind = 0, label = "后仓汇合口 900"}, {x = 1740, y = 0, kind = 0, label = "牌楼出口 1740"}}, -- 1184
	dims = {{x0 = 100, x1 = 124, text = "檐柱 24"}, {x0 = 460, x1 = 560, text = "摊挡 100"}, {x0 = 700, x1 = 820, text = "装卸面 120"}}, -- 1189
	companion = {waitX = 640, waitDepth = 32, joinX = 900, followAfter = "open_board"}, -- 1194
	campaign = { -- 1195
		chapter = "S", -- 1195
		act = 2, -- 1195
		budget = 390, -- 1195
		goal = "reach_exit", -- 1195
		next = "s3-archway", -- 1195
		exitX = 1740, -- 1195
		checkpoint = 2 -- 1195
	} -- 1195
} -- 1195
--- S3 牌楼后巷：外檐线从低处进、布行线从高处进，两条入口在墙脚汇合。
-- 装卸坡可先上去看同一堆粮袋的敌位，再退半层接小满；也可以沿墙脚直接绕。
____exports.S3_ARCHWAY = { -- 1202
	key = "s3-archway", -- 1203
	name = "S3 · 牌楼后巷", -- 1204
	caption = "两高度入口看同一粮袋。登装卸坡看敌位再退半层接人，或沿墙脚绕走；候检门前两人停。", -- 1205
	originX = 3400, -- 1206
	minX = 0, -- 1207
	maxX = 1400, -- 1208
	height = 230, -- 1209
	depth = LANE_ROAD, -- 1210
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 1211
	solids = { -- 1212
		{ -- 1213
			x = 0, -- 1213
			w = 180, -- 1213
			h = 32, -- 1213
			y = 0, -- 1213
			label = "高处进口台 0–180 · 高 32", -- 1213
			lanes = {"upper"}, -- 1213
			art = "cover_stone" -- 1213
		}, -- 1213
		{ -- 1214
			x = 380, -- 1214
			w = 140, -- 1214
			h = 64, -- 1214
			y = 0, -- 1214
			label = "装卸高台 380–520 · 高 64", -- 1214
			lanes = {"upper"}, -- 1214
			art = "cover_wood" -- 1214
		}, -- 1214
		{ -- 1215
			x = 560, -- 1215
			w = 160, -- 1215
			h = 48, -- 1215
			y = 0, -- 1215
			label = "粮袋堆 560–720 · 高 48", -- 1215
			lanes = {"lower", "middle"}, -- 1215
			art = "grain_sack" -- 1215
		}, -- 1215
		{ -- 1216
			x = 1260, -- 1216
			w = 30, -- 1216
			h = 140, -- 1216
			y = 0, -- 1216
			label = "候检门左柱", -- 1216
			lanes = {"lower", "upper"}, -- 1216
			art = "gate_post" -- 1216
		}, -- 1216
		{ -- 1217
			x = 1330, -- 1217
			w = 30, -- 1217
			h = 140, -- 1217
			y = 0, -- 1217
			label = "候检门右柱", -- 1217
			lanes = {"lower", "upper"}, -- 1217
			art = "gate_post" -- 1217
		} -- 1217
	}, -- 1217
	zones = {{ -- 1219
		x0 = 780, -- 1219
		x1 = 1060, -- 1219
		y = 0, -- 1219
		h = 150, -- 1219
		tint = 1, -- 1219
		label = "后巷交火 780–1060" -- 1219
	}}, -- 1219
	arch = { -- 1220
		x0 = 0, -- 1220
		x1 = 0, -- 1220
		y = 0, -- 1220
		h = 0, -- 1220
		label = "" -- 1220
	}, -- 1220
	stairs = {{ -- 1221
		x0 = 140, -- 1222
		x1 = 200, -- 1222
		y0 = 0, -- 1222
		y1 = 32, -- 1222
		steps = 3, -- 1222
		label = "进口台阶", -- 1222
		lanes = {"upper"} -- 1222
	}, { -- 1222
		x0 = 260, -- 1223
		x1 = 380, -- 1223
		y0 = 0, -- 1223
		y1 = 64, -- 1223
		steps = 4, -- 1223
		label = "装卸坡 260–380 · 高 64", -- 1223
		lanes = {"upper"} -- 1223
	}}, -- 1223
	cart = NO_CART, -- 1225
	spawns = {{ -- 1226
		x = 860, -- 1227
		y = 0, -- 1227
		h = 84, -- 1227
		depth = 32, -- 1227
		label = "高处火器手 860", -- 1227
		kind = "gunner", -- 1227
		drop = "ammo" -- 1227
	}, { -- 1227
		x = 980, -- 1228
		y = 0, -- 1228
		h = 84, -- 1228
		depth = 0, -- 1228
		label = "墙脚火器手 980", -- 1228
		kind = "gunner", -- 1228
		drop = "ammo" -- 1228
	}}, -- 1228
	marks = {{x = 440, y = 0, kind = 0, label = "装卸坡观察位 440"}, {x = 620, y = 0, kind = 1, label = "粮袋后安全点 620"}, {x = 1300, y = 0, kind = 0, label = "候检门前 1300"}}, -- 1230
	dims = {{x0 = 260, x1 = 380, text = "装卸坡 120"}, {x0 = 560, x1 = 720, text = "粮袋 160"}}, -- 1235
	companion = {waitX = 620, waitDepth = 0, joinX = 1240}, -- 1236
	campaign = { -- 1237
		chapter = "S", -- 1237
		act = 3, -- 1237
		budget = 180, -- 1237
		goal = "reach_exit", -- 1237
		next = "c1-yard", -- 1237
		exitX = 1320, -- 1237
		checkpoint = 3 -- 1237
	} -- 1237
} -- 1237
--- C1 候检院：侧门横闩在门背，粮棚可见但被队栏、查验台与棚柱交错挡住。
-- 绕缺口进栏，截断压近者或穿查验台后到棚口；正面看门，转到背面才抬得动闩。
____exports.C1_YARD = { -- 1244
	key = "c1-yard", -- 1245
	name = "C1 · 候检院", -- 1246
	caption = "队栏与查验台把粮棚切成几段。绕缺口进栏，压近者会截断通路；侧门横闩要转到门背才抬得动。", -- 1247
	originX = 4800, -- 1248
	minX = 0, -- 1249
	maxX = 1900, -- 1250
	height = 240, -- 1251
	depth = LANE_ROAD, -- 1252
	floors = {{y = 0, x0 = 0, x1 = 1900}}, -- 1253
	solids = { -- 1254
		{ -- 1255
			x = 280, -- 1255
			w = 340, -- 1255
			h = 28, -- 1255
			y = 0, -- 1255
			label = "候检队栏 280–620 · 高 28", -- 1255
			lanes = {"lower", "middle"}, -- 1255
			art = "fence" -- 1255
		}, -- 1255
		{ -- 1256
			x = 820, -- 1256
			w = 180, -- 1256
			h = 44, -- 1256
			y = 0, -- 1256
			label = "查验台 820–1000 · 高 44", -- 1256
			lanes = {"lower", "middle"}, -- 1256
			art = "cover_wood" -- 1256
		}, -- 1256
		{ -- 1257
			x = 1100, -- 1257
			w = 40, -- 1257
			h = 150, -- 1257
			y = 0, -- 1257
			label = "棚柱 1100–1140", -- 1257
			lanes = {"lower", "middle"}, -- 1257
			art = "cover_wood" -- 1257
		}, -- 1257
		{ -- 1258
			x = 1240, -- 1258
			w = 40, -- 1258
			h = 150, -- 1258
			y = 0, -- 1258
			label = "棚柱 1240–1280", -- 1258
			lanes = {"lower", "middle"}, -- 1258
			art = "cover_wood" -- 1258
		}, -- 1258
		{ -- 1259
			x = 1600, -- 1259
			w = 160, -- 1259
			h = 48, -- 1259
			y = 0, -- 1259
			label = "粮棚袋堆 1600–1760 · 高 48", -- 1259
			lanes = {"lower", "middle"}, -- 1259
			art = "grain_sack" -- 1259
		}, -- 1259
		{ -- 1260
			x = 1780, -- 1260
			w = 50, -- 1260
			h = 150, -- 1260
			y = 0, -- 1260
			label = "侧门 1780–1830", -- 1260
			depth = LANE_ROAD, -- 1260
			art = "wall", -- 1260
			id = "c1_door" -- 1260
		}, -- 1260
		{ -- 1261
			x = 1755, -- 1262
			w = 30, -- 1262
			h = 24, -- 1262
			y = 40, -- 1262
			label = "侧门横闩（门框上侧）", -- 1262
			lanes = {"upper"}, -- 1262
			art = "latch", -- 1263
			id = "c1_latch", -- 1263
			interact = {kind = "raise_latch", reach = 56} -- 1263
		} -- 1263
	}, -- 1263
	zones = {{ -- 1266
		x0 = 760, -- 1266
		x1 = 1080, -- 1266
		y = 0, -- 1266
		h = 150, -- 1266
		tint = 1, -- 1266
		label = "查验台截断 820–1000" -- 1266
	}}, -- 1266
	arch = { -- 1267
		x0 = 0, -- 1267
		x1 = 0, -- 1267
		y = 0, -- 1267
		h = 0, -- 1267
		label = "" -- 1267
	}, -- 1267
	stairs = {}, -- 1268
	cart = NO_CART, -- 1269
	spawns = {{ -- 1270
		x = 900, -- 1271
		y = 0, -- 1271
		h = 84, -- 1271
		depth = 0, -- 1271
		label = "截断压近者 900", -- 1271
		kind = "breaker", -- 1271
		drop = "wedge" -- 1271
	}, { -- 1271
		x = 1200, -- 1272
		y = 0, -- 1272
		h = 84, -- 1272
		depth = 32, -- 1272
		label = "棚柱后火器手 1200", -- 1272
		kind = "gunner", -- 1272
		drop = "ammo" -- 1272
	}}, -- 1272
	marks = {{x = 1000, y = 0, kind = 1, label = "查验台后等待位 1000"}, {x = 1700, y = 0, kind = 0, label = "侧门正面 1700"}, {x = 1860, y = 0, kind = 0, label = "门背出口 1860"}}, -- 1274
	dims = {{x0 = 820, x1 = 1000, text = "查验台 180"}, {x0 = 1780, x1 = 1830, text = "侧门 50"}}, -- 1279
	companion = {waitX = 1000, waitDepth = 0, joinX = 1700, followAfter = "raise_latch"}, -- 1280
	campaign = { -- 1281
		chapter = "C", -- 1281
		act = 1, -- 1281
		budget = 270, -- 1281
		goal = "raise_latch", -- 1281
		next = "c2-granary", -- 1281
		exitX = 1860, -- 1281
		checkpoint = 4 -- 1281
	} -- 1281
} -- 1281
--- C2 军粮棚：粮袋安全区居中，远柱木帘与近侧车轨分列。
-- 有残盾可以在暴露轨段架起来挡一发；空手路线先绕上远柱放帘，再回来握车柄。
____exports.C2_GRANARY = { -- 1288
	key = "c2-granary", -- 1289
	name = "C2 · 军粮棚", -- 1290
	caption = "空筐围挡、暴露轨段与远柱木帘。先绕上远柱放帘，或架残盾，再握车柄把车推入轮窝并抬连杆闩。", -- 1291
	originX = 6700, -- 1292
	minX = 0, -- 1293
	maxX = 1800, -- 1294
	height = 240, -- 1295
	depth = LANE_ROAD, -- 1296
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 1297
	solids = { -- 1298
		{ -- 1299
			x = 900, -- 1300
			w = 76, -- 1300
			h = 44, -- 1300
			y = 0, -- 1300
			label = "空筐围挡 900–976 · 高 44", -- 1300
			lanes = {"lower", "middle"}, -- 1300
			art = "basket_wall", -- 1301
			id = "c2_basket", -- 1301
			breakable = {kind = "basket_wall", hp = 2, wedgeable = false} -- 1301
		}, -- 1301
		{ -- 1303
			x = 600, -- 1303
			w = 300, -- 1303
			h = 48, -- 1303
			y = 0, -- 1303
			label = "粮袋安全区 600–900 · 高 48", -- 1303
			lanes = {"lower", "middle"}, -- 1303
			art = "grain_sack" -- 1303
		}, -- 1303
		{ -- 1304
			x = 980, -- 1304
			w = 40, -- 1304
			h = 24, -- 1304
			y = 0, -- 1304
			label = "棚口下轨台 980–1020 · 高 24", -- 1304
			lanes = {"lower", "middle"}, -- 1304
			art = "cover_stone" -- 1304
		}, -- 1304
		{ -- 1305
			x = 1200, -- 1306
			w = 40, -- 1306
			h = 150, -- 1306
			y = 0, -- 1306
			label = "远柱 1200–1240 · 高 150", -- 1306
			lanes = {"upper"}, -- 1306
			art = "cover_wood", -- 1307
			id = "c2_post", -- 1307
			interact = {kind = "lower_curtain", reach = 46} -- 1307
		}, -- 1307
		{ -- 1309
			x = 1240, -- 1310
			w = 120, -- 1310
			h = 120, -- 1310
			y = 24, -- 1310
			label = "木帘落点 1240–1360", -- 1310
			lanes = {"lower", "middle"}, -- 1310
			art = "curtain", -- 1311
			soft = true, -- 1311
			id = "c2_curtain", -- 1311
			hidden = true -- 1311
		}, -- 1311
		{ -- 1313
			x = 1560, -- 1314
			w = 30, -- 1314
			h = 24, -- 1314
			y = 40, -- 1314
			label = "连杆抬闩 1560–1590", -- 1314
			lanes = {"middle"}, -- 1314
			art = "latch", -- 1315
			id = "c2_latch", -- 1315
			interact = {kind = "raise_latch", reach = 50} -- 1315
		}, -- 1315
		{ -- 1317
			x = 1720, -- 1317
			w = 30, -- 1317
			h = 150, -- 1317
			y = 0, -- 1317
			label = "棚尾门柱", -- 1317
			lanes = {"lower", "upper"}, -- 1317
			art = "gate_post" -- 1317
		} -- 1317
	}, -- 1317
	zones = {{ -- 1319
		x0 = 1000, -- 1319
		x1 = 1200, -- 1319
		y = 0, -- 1319
		h = 150, -- 1319
		tint = 1, -- 1319
		label = "暴露轨段 1000–1200" -- 1319
	}}, -- 1319
	arch = { -- 1320
		x0 = 0, -- 1320
		x1 = 0, -- 1320
		y = 0, -- 1320
		h = 0, -- 1320
		label = "" -- 1320
	}, -- 1320
	stairs = {}, -- 1321
	cart = { -- 1322
		startX = 1150, -- 1323
		endX = 1500, -- 1323
		baseY = 0, -- 1323
		depth = 0, -- 1323
		bodyW = 48, -- 1323
		bodyH = 26, -- 1323
		wheelR = 12, -- 1323
		handleOffset = -50, -- 1323
		clothSide = -1 -- 1323
	}, -- 1323
	spawns = {{ -- 1325
		x = 1580, -- 1326
		y = 0, -- 1326
		h = 84, -- 1326
		depth = 0, -- 1326
		label = "棚尾火器手 1580", -- 1326
		kind = "gunner", -- 1326
		drop = "ammo" -- 1326
	}, { -- 1326
		x = 1340, -- 1327
		y = 0, -- 1327
		h = 84, -- 1327
		depth = 32, -- 1327
		label = "远侧持盾手 1340", -- 1327
		kind = "shield", -- 1327
		shieldHp = 2, -- 1327
		drop = "shield" -- 1327
	}}, -- 1327
	marks = {{x = 760, y = 0, kind = 1, label = "袋堆后等待位 760"}, {x = 1100, y = 0, kind = 0, label = "车柄 1100"}, {x = 1500, y = 0, kind = 0, label = "轮窝 1500"}, {x = 1700, y = 0, kind = 0, label = "棚尾出口 1700"}}, -- 1329
	dims = {{x0 = 1150, x1 = 1500, text = "推车 350"}, {x0 = 1240, x1 = 1360, text = "木帘 120"}}, -- 1335
	companion = {waitX = 760, waitDepth = 0, joinX = 1700}, -- 1336
	campaign = { -- 1337
		chapter = "C", -- 1337
		act = 2, -- 1337
		budget = 360, -- 1337
		goal = "dock_cart", -- 1337
		exitX = 1700, -- 1337
		checkpoint = 5 -- 1337
	} -- 1337
} -- 1337
____exports.CAMPAIGN_ROOMS = { -- 1340
	____exports.S1_CROSSROAD, -- 1340
	____exports.S2_DRYGOODS, -- 1340
	____exports.S3_ARCHWAY, -- 1340
	____exports.C1_YARD, -- 1340
	____exports.C2_GRANARY -- 1340
} -- 1340
____exports.ROOMS = { -- 1348
	____exports.PROLOGUE_ROOM, -- 1348
	____exports.STREET_ROOM, -- 1348
	____exports.S1_CROSSROAD, -- 1348
	____exports.S2_DRYGOODS, -- 1348
	____exports.S3_ARCHWAY, -- 1348
	____exports.C1_YARD, -- 1348
	____exports.C2_GRANARY, -- 1348
	____exports.CHECKPOINT_ROOM, -- 1348
	____exports.GATE_ROOM, -- 1348
	____exports.GATE_PATH_ROOM, -- 1348
	____exports.ESCORT1_ROOM, -- 1348
	____exports.ESCORT2_ROOM, -- 1348
	____exports.ESCORT3_ROOM, -- 1348
	____exports.ESCORT4_ROOM, -- 1348
	____exports.ESCORT5_ROOM, -- 1348
	____exports.OUTSIDE_ROOM, -- 1348
	____exports.VILLAGE_ROOM, -- 1348
	____exports.FOREST_ROOM, -- 1348
	____exports.TOWER_ROOM, -- 1348
	____exports.MUSEUM_ROOM -- 1348
} -- 1348
local function placeSolids(room) -- 1371
	local blocks = {} -- 1372
	for ____, solid in ipairs(room.solids) do -- 1373
		local x = solid.x + room.originX -- 1374
		if room.depth ~= nil and solid.lanes ~= nil then -- 1374
			for ____, depth in ipairs(laneFootprints(solid.lanes)) do -- 1376
				blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x, depth = depth, lanes = nil}) -- 1377
			end -- 1377
		else -- 1377
			blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x}) -- 1380
		end -- 1380
	end -- 1380
	return blocks -- 1383
end -- 1371
local function placeStairs(room) -- 1386
	local out = {} -- 1387
	for ____, stair in ipairs(room.stairs) do -- 1388
		local x0 = stair.x0 + room.originX -- 1389
		local x1 = stair.x1 + room.originX -- 1390
		if room.depth ~= nil and stair.lanes ~= nil then -- 1390
			for ____, depth in ipairs(laneFootprints(stair.lanes)) do -- 1392
				out[#out + 1] = __TS__ObjectAssign({}, stair, {x0 = x0, x1 = x1, depth = depth, lanes = nil}) -- 1393
			end -- 1393
		else -- 1393
			out[#out + 1] = __TS__ObjectAssign({}, stair, {x0 = x0, x1 = x1}) -- 1396
		end -- 1396
	end -- 1396
	return out -- 1399
end -- 1386
--- 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
-- 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
function ____exports.withOrigin(room) -- 1406
	local ox = room.originX -- 1407
	if ox == 0 then -- 1407
		return room.depth == nil and room or __TS__ObjectAssign( -- 1409
			{}, -- 1409
			room, -- 1409
			{ -- 1409
				solids = placeSolids(room), -- 1409
				stairs = placeStairs(room) -- 1409
			} -- 1409
		) -- 1409
	end -- 1409
	local function shift(x) -- 1411
		return x + ox -- 1411
	end -- 1411
	local ____room_key_12 = room.key -- 1413
	local ____room_name_13 = room.name -- 1414
	local ____room_caption_14 = room.caption -- 1415
	local ____shift_result_15 = shift(room.minX) -- 1417
	local ____shift_result_16 = shift(room.maxX) -- 1418
	local ____room_height_17 = room.height -- 1419
	local ____room_depth_18 = room.depth -- 1420
	local ____TS__ArrayMap_result_19 = __TS__ArrayMap( -- 1421
		room.floors, -- 1421
		function(____, f) return { -- 1421
			y = f.y, -- 1421
			x0 = shift(f.x0), -- 1421
			x1 = shift(f.x1) -- 1421
		} end -- 1421
	) -- 1421
	local ____placeSolids_result_20 = placeSolids(room) -- 1422
	local ____TS__ArrayMap_result_21 = __TS__ArrayMap( -- 1423
		room.zones, -- 1423
		function(____, z) return { -- 1423
			x0 = shift(z.x0), -- 1423
			x1 = shift(z.x1), -- 1423
			y = z.y, -- 1423
			h = z.h, -- 1423
			tint = z.tint, -- 1423
			label = z.label -- 1423
		} end -- 1423
	) -- 1423
	local ____temp_22 = { -- 1424
		x0 = shift(room.arch.x0), -- 1424
		x1 = shift(room.arch.x1), -- 1424
		y = room.arch.y, -- 1424
		h = room.arch.h, -- 1424
		label = room.arch.label -- 1424
	} -- 1424
	local ____placeStairs_result_23 = placeStairs(room) -- 1425
	local ____TS__ObjectAssign_result_24 = __TS__ObjectAssign( -- 1426
		{}, -- 1426
		room.cart, -- 1427
		{ -- 1426
			startX = shift(room.cart.startX), -- 1428
			endX = shift(room.cart.endX) -- 1429
		} -- 1429
	) -- 1429
	local ____TS__ArrayMap_result_25 = __TS__ArrayMap( -- 1431
		room.spawns, -- 1431
		function(____, s) return __TS__ObjectAssign( -- 1431
			{}, -- 1431
			s, -- 1431
			{x = shift(s.x)} -- 1431
		) end -- 1431
	) -- 1431
	local ____TS__ArrayMap_result_26 = __TS__ArrayMap( -- 1432
		room.marks, -- 1432
		function(____, m) return { -- 1432
			x = shift(m.x), -- 1432
			y = m.y, -- 1432
			kind = m.kind, -- 1432
			label = m.label -- 1432
		} end -- 1432
	) -- 1432
	local ____TS__ArrayMap_result_27 = __TS__ArrayMap( -- 1433
		room.dims, -- 1433
		function(____, d) return { -- 1433
			x0 = shift(d.x0), -- 1433
			x1 = shift(d.x1), -- 1433
			text = d.text -- 1433
		} end -- 1433
	) -- 1433
	local ____temp_0 -- 1434
	if room.scavenger == nil then -- 1434
		____temp_0 = nil -- 1434
	else -- 1434
		____temp_0 = { -- 1434
			x0 = shift(room.scavenger.x0), -- 1435
			x1 = shift(room.scavenger.x1), -- 1435
			y = room.scavenger.y, -- 1435
			h = room.scavenger.h, -- 1435
			patrolSpeed = room.scavenger.patrolSpeed, -- 1436
			approachSpeed = room.scavenger.approachSpeed, -- 1436
			hearTicks = room.scavenger.hearTicks, -- 1437
			stallTicks = room.scavenger.stallTicks, -- 1437
			range = room.scavenger.range -- 1437
		} -- 1437
	end -- 1437
	local ____temp_1 -- 1439
	if room.bottle == nil then -- 1439
		____temp_1 = nil -- 1439
	else -- 1439
		____temp_1 = { -- 1439
			x = shift(room.bottle.x), -- 1439
			y = room.bottle.y -- 1439
		} -- 1439
	end -- 1439
	local ____temp_2 -- 1440
	if room.brickX == nil then -- 1440
		____temp_2 = nil -- 1440
	else -- 1440
		____temp_2 = shift(room.brickX) -- 1440
	end -- 1440
	local ____temp_3 -- 1441
	if room.basinX == nil then -- 1441
		____temp_3 = nil -- 1441
	else -- 1441
		____temp_3 = shift(room.basinX) -- 1441
	end -- 1441
	local ____temp_4 -- 1442
	if room.softX == nil then -- 1442
		____temp_4 = nil -- 1442
	else -- 1442
		____temp_4 = shift(room.softX) -- 1442
	end -- 1442
	local ____temp_5 -- 1443
	if room.passLine == nil then -- 1443
		____temp_5 = nil -- 1443
	else -- 1443
		____temp_5 = shift(room.passLine) -- 1443
	end -- 1443
	local ____temp_6 -- 1444
	if room.campaign == nil then -- 1444
		____temp_6 = nil -- 1444
	else -- 1444
		____temp_6 = __TS__ObjectAssign( -- 1444
			{}, -- 1444
			room.campaign, -- 1444
			{exitX = shift(room.campaign.exitX)} -- 1444
		) -- 1444
	end -- 1444
	local ____temp_7 -- 1445
	if room.pickups == nil then -- 1445
		____temp_7 = nil -- 1445
	else -- 1445
		____temp_7 = __TS__ArrayMap( -- 1445
			room.pickups, -- 1445
			function(____, p) return __TS__ObjectAssign( -- 1445
				{}, -- 1445
				p, -- 1445
				{x = shift(p.x)} -- 1445
			) end -- 1445
		) -- 1445
	end -- 1445
	local ____temp_11 -- 1446
	if room.companion == nil then -- 1446
		____temp_11 = nil -- 1446
	else -- 1446
		local ____room_companion_10 = room.companion -- 1447
		local ____temp_8 -- 1448
		if room.companion.waitX == nil then -- 1448
			____temp_8 = nil -- 1448
		else -- 1448
			____temp_8 = shift(room.companion.waitX) -- 1448
		end -- 1448
		local ____temp_9 -- 1449
		if room.companion.joinX == nil then -- 1449
			____temp_9 = nil -- 1449
		else -- 1449
			____temp_9 = shift(room.companion.joinX) -- 1449
		end -- 1449
		____temp_11 = __TS__ObjectAssign({}, ____room_companion_10, {waitX = ____temp_8, joinX = ____temp_9}) -- 1446
	end -- 1446
	return { -- 1412
		key = ____room_key_12, -- 1413
		name = ____room_name_13, -- 1414
		caption = ____room_caption_14, -- 1415
		originX = 0, -- 1416
		minX = ____shift_result_15, -- 1417
		maxX = ____shift_result_16, -- 1418
		height = ____room_height_17, -- 1419
		depth = ____room_depth_18, -- 1420
		floors = ____TS__ArrayMap_result_19, -- 1421
		solids = ____placeSolids_result_20, -- 1422
		zones = ____TS__ArrayMap_result_21, -- 1423
		arch = ____temp_22, -- 1424
		stairs = ____placeStairs_result_23, -- 1425
		cart = ____TS__ObjectAssign_result_24, -- 1426
		spawns = ____TS__ArrayMap_result_25, -- 1431
		marks = ____TS__ArrayMap_result_26, -- 1432
		dims = ____TS__ArrayMap_result_27, -- 1433
		scavenger = ____temp_0, -- 1434
		bottle = ____temp_1, -- 1439
		brickX = ____temp_2, -- 1440
		basinX = ____temp_3, -- 1441
		softX = ____temp_4, -- 1442
		passLine = ____temp_5, -- 1443
		campaign = ____temp_6, -- 1444
		pickups = ____temp_7, -- 1445
		companion = ____temp_11, -- 1446
		story = shiftStory(room.story, ox) -- 1451
	} -- 1451
end -- 1406
return ____exports -- 1406