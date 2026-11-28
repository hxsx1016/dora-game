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
	caption = "走到红布车右侧，按住 E+D 拉车入窝。回左边下石阶，按住 Ctrl 蹲过矮拱，再沿墙根去找塔灯。", -- 329
	originX = 0, -- 331
	minX = 0, -- 332
	maxX = 1240, -- 333
	height = 230, -- 334
	depth = LANE_ROAD, -- 335
	floors = {{y = 0, x0 = 0, x1 = 1240}, {y = 96, x0 = 128, x1 = 512}, {y = 64, x0 = 820, x1 = 940}}, -- 336
	solids = {{ -- 341
		x = 512, -- 343
		w = 88, -- 343
		h = 134, -- 343
		y = 96, -- 343
		depth = LANE_ROAD, -- 343
		label = "台面右端城墙 · 下层可通" -- 343
	}, { -- 343
		x = 0, -- 344
		w = 40, -- 344
		h = 96, -- 344
		y = 0, -- 344
		depth = LANE_ROAD, -- 344
		label = "街口" -- 344
	}, { -- 344
		x = 1200, -- 345
		w = 40, -- 345
		h = 140, -- 345
		y = 0, -- 345
		depth = LANE_ROAD, -- 345
		label = "墙根尽头" -- 345
	}}, -- 345
	zones = {}, -- 347
	arch = { -- 348
		x0 = 280, -- 348
		x1 = 360, -- 348
		y = 0, -- 348
		h = 44, -- 348
		label = "拱 280–360 · 净高 44" -- 348
	}, -- 348
	stairs = {{ -- 349
		x0 = 56, -- 350
		x1 = 128, -- 350
		y0 = 0, -- 350
		y1 = 96, -- 350
		steps = 5, -- 350
		depth = LANE_ROAD, -- 350
		label = "石阶 0–96（每级 19.2 可直走）" -- 350
	}, { -- 350
		x0 = 700, -- 351
		x1 = 820, -- 351
		y0 = 0, -- 351
		y1 = 64, -- 351
		steps = 3, -- 351
		depth = LANE_ROAD, -- 351
		label = "墙根石阶 0 / 16 / 32 / 48 / 64" -- 351
	}}, -- 351
	cart = { -- 353
		startX = 304, -- 354
		endX = 432, -- 355
		baseY = 96, -- 356
		bodyW = 48, -- 357
		bodyH = 26, -- 358
		wheelR = 12, -- 359
		handleOffset = 40, -- 360
		clothSide = -1 -- 361
	}, -- 361
	spawns = {{x = 160, y = 96, h = 56, label = "小满 160"}}, -- 363
	marks = { -- 364
		{x = 432, y = 96, kind = 1, label = "空窝 432"}, -- 365
		{x = 380, y = 0, kind = 0, label = "洞后检查点 380"}, -- 366
		{x = 520, y = 96, kind = 3, label = "石阶光 · 回首红布"}, -- 367
		{x = 820, y = 64, kind = 3, label = "墙根石阶顶 820"}, -- 368
		{x = 1120, y = 64, kind = 6, label = "塔灯 1120"} -- 369
	}, -- 369
	dims = {{x0 = 304, x1 = 432, text = "红布车入窝 · 右柄 E+D"}, {x0 = 128, x1 = 512, text = "台面 384"}, {x0 = 280, x1 = 360, text = "拱 80"}, {x0 = 600, x1 = 1240, text = "墙根 640"}} -- 371
} -- 371
--- 村口：瓶架 112、观察位 160、桌下 304–416（净高 44）、第一院通行线 440、
-- 软土 272（D5 完整）、砖地 608、拾荒者巡逻 464–512。
-- 小满脚底中心 290 起必须蹲，超过 430 才站起；160→440 约 2.63 秒。
____exports.VILLAGE_ROOM = { -- 384
	key = "village", -- 385
	originX = 0, -- 386
	name = "村口 · 架、桌、砖地", -- 387
	caption = "点 E 拾瓶，按住 F 瞄，松手投；砖地一响，拾荒者转身，趁他走开钻过桌下", -- 388
	minX = 0, -- 389
	maxX = 720, -- 390
	height = 200, -- 391
	depth = LANE_ROAD, -- 392
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 393
	solids = {{ -- 394
		x = 96, -- 395
		w = 32, -- 395
		h = 52, -- 395
		y = 0, -- 395
		depth = LANE_ROAD, -- 395
		label = "瓶架", -- 395
		art = "cover_wood" -- 395
	}, { -- 395
		x = 672, -- 397
		w = 48, -- 397
		h = 96, -- 397
		y = 0, -- 397
		depth = LANE_ROAD, -- 397
		label = "院墙" -- 397
	}}, -- 397
	zones = { -- 399
		{ -- 400
			x0 = 256, -- 400
			x1 = 288, -- 400
			y = 0, -- 400
			h = 6, -- 400
			tint = 2, -- 400
			label = "软土 272" -- 400
		}, -- 400
		{ -- 401
			x0 = 440, -- 401
			x1 = 448, -- 401
			y = 0, -- 401
			h = 120, -- 401
			tint = 4, -- 401
			label = "通行线 440" -- 401
		}, -- 401
		{ -- 402
			x0 = 532, -- 402
			x1 = 564, -- 402
			y = 0, -- 402
			h = 6, -- 402
			tint = 4, -- 402
			label = "铁盆 548" -- 402
		}, -- 402
		{ -- 403
			x0 = 592, -- 403
			x1 = 624, -- 403
			y = 0, -- 403
			h = 6, -- 403
			tint = 3, -- 403
			label = "砖地 608" -- 403
		}, -- 403
		{ -- 404
			x0 = 560, -- 404
			x1 = 640, -- 404
			y = 0, -- 404
			h = 6, -- 404
			tint = 1, -- 404
			label = "暗渠口 560–640 · 蹲下钻" -- 404
		} -- 404
	}, -- 404
	arch = { -- 406
		x0 = 304, -- 406
		x1 = 416, -- 406
		y = 0, -- 406
		h = 44, -- 406
		label = "桌下 304–416 · 净高 44" -- 406
	}, -- 406
	stairs = {}, -- 407
	cart = { -- 408
		startX = 0, -- 408
		endX = 0, -- 408
		baseY = 0, -- 408
		bodyW = 0, -- 408
		bodyH = 0, -- 408
		wheelR = 0, -- 408
		handleOffset = 0, -- 408
		clothSide = 1 -- 408
	}, -- 408
	spawns = {{x = 160, y = 0, h = 56, label = "小满 160"}}, -- 409
	marks = {{x = 548, y = 0, kind = 5, label = "铁盆落点 548"}, {x = 608, y = 0, kind = 5, label = "砖地落点 608"}, {x = 440, y = 0, kind = 4, label = "通行线 440"}, {x = 600, y = 0, kind = 1, label = "暗渠口 600"}}, -- 410
	dims = {{x0 = 96, x1 = 128, text = "瓶架"}, {x0 = 304, x1 = 416, text = "桌下 112"}, {x0 = 464, x1 = 512, text = "巡逻 48"}, {x0 = 560, x1 = 640, text = "暗渠 80"}}, -- 416
	scavenger = { -- 422
		x0 = 464, -- 423
		x1 = 512, -- 424
		y = 0, -- 425
		h = 82, -- 426
		patrolSpeed = 40, -- 427
		approachSpeed = 64, -- 428
		hearTicks = 18, -- 429
		stallTicks = 120, -- 430
		range = 480 -- 431
	}, -- 431
	bottle = {x = 112, y = 48}, -- 433
	brickX = 608, -- 434
	basinX = 548, -- 435
	softX = 272, -- 436
	passLine = 440 -- 437
} -- 437
--- 剧本锚点跟着 originX 一起搬，判定仍读世界坐标。
local function shiftStory(story, ox) -- 441
	if story == nil then -- 441
		return nil -- 443
	end -- 443
	if ox == 0 then -- 443
		return story -- 446
	end -- 446
	local out = {} -- 448
	if story.prologue ~= nil then -- 448
		out.prologue = {giveReach = story.prologue.giveReach} -- 450
	end -- 450
	if story.gate ~= nil then -- 450
		out.gate = { -- 453
			winchX = story.gate.winchX + ox, -- 454
			waitX = story.gate.waitX + ox, -- 455
			doorX = story.gate.doorX + ox, -- 456
			exitX = story.gate.exitX + ox, -- 457
			holdTicks = story.gate.holdTicks -- 458
		} -- 458
	end -- 458
	if story.gatepath ~= nil then -- 458
		out.gatepath = {carryX = story.gatepath.carryX + ox, exitX = story.gatepath.exitX + ox, next = story.gatepath.next} -- 462
	end -- 462
	if story.dog ~= nil then -- 462
		out.dog = {x0 = story.dog.x0 + ox, x1 = story.dog.x1 + ox, speed = story.dog.speed, range = story.dog.range} -- 469
	end -- 469
	if story.museum ~= nil then -- 469
		out.museum = {cabinetX = story.museum.cabinetX + ox, hallX = story.museum.hallX + ox, lampX = story.museum.lampX + ox, exitX = story.museum.exitX + ox} -- 472
	end -- 472
	if story.tower ~= nil then -- 472
		out.tower = {doorX = story.tower.doorX + ox, knockTicks = story.tower.knockTicks} -- 480
	end -- 480
	return out -- 482
end -- 441
--- 序章：周戍在废墟里找到藏在倒柜后的小满，走近点 E 递出指南针（纸条夹在针套里）。
-- 递完她开始跟随，两人一起走进街道。
____exports.PROLOGUE_ROOM = { -- 489
	key = "prologue", -- 490
	originX = 0, -- 491
	name = "序章 · 倒柜后", -- 492
	caption = "周戍持针套，小满藏在倒柜后；走近点 E 递过去，纸条塞进针套，她开始跟随", -- 493
	minX = 0, -- 494
	maxX = 720, -- 495
	height = 200, -- 496
	depth = LANE_ROAD, -- 497
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 498
	solids = { -- 499
		{ -- 500
			x = 152, -- 500
			w = 98, -- 500
			h = 32, -- 500
			y = 0, -- 500
			label = "倒柜 152–250 · 高 32", -- 500
			lanes = {"lower", "middle"}, -- 500
			art = "cover_wood" -- 500
		}, -- 500
		{ -- 501
			x = 648, -- 501
			w = 30, -- 501
			h = 118, -- 501
			y = 0, -- 501
			label = "出口门柱", -- 501
			lanes = {"lower", "upper"}, -- 501
			art = "gate_post" -- 501
		}, -- 501
		{ -- 502
			x = 344, -- 502
			w = 32, -- 502
			h = 78, -- 502
			y = 0, -- 502
			label = "石柱", -- 502
			lanes = {"lower", "middle"}, -- 502
			art = "wall" -- 502
		}, -- 502
		{ -- 503
			x = 56, -- 503
			w = 44, -- 503
			h = 18, -- 503
			y = 0, -- 503
			label = "侧灶 56–100 · 高 18", -- 503
			decorative = true, -- 503
			art = "stove_hearth" -- 503
		}, -- 503
		{ -- 504
			x = 396, -- 504
			w = 34, -- 504
			h = 12, -- 504
			y = 0, -- 504
			label = "井沿 396–430 · 高 12", -- 504
			decorative = true, -- 504
			art = "well" -- 504
		}, -- 504
		{ -- 505
			x = 470, -- 505
			w = 40, -- 505
			h = 26, -- 505
			y = 0, -- 505
			label = "后院矮墙 470–510 · 高 26", -- 505
			lanes = {"lower"}, -- 505
			art = "cover_stone" -- 505
		} -- 505
	}, -- 505
	zones = {{ -- 507
		x0 = 380, -- 508
		x1 = 470, -- 508
		y = 0, -- 508
		h = 6, -- 508
		tint = 2, -- 508
		label = "后院旧井 380–470" -- 508
	}}, -- 508
	arch = { -- 510
		x0 = 0, -- 510
		x1 = 0, -- 510
		y = 0, -- 510
		h = 0, -- 510
		label = "" -- 510
	}, -- 510
	stairs = {}, -- 511
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
	spawns = {{x = 80, y = 0, h = 88, label = "周戍 80"}, {x = 300, y = 0, h = 56, label = "小满 300 · 柜子后面"}}, -- 513
	marks = {{x = 300, y = 0, kind = 1, label = "柜后 300"}, {x = 430, y = 0, kind = 7, label = "旧井 430"}, {x = 660, y = 0, kind = 0, label = "门口中路 660"}}, -- 517
	dims = {{x0 = 152, x1 = 250, text = "倒柜 98"}, {x0 = 648, x1 = 678, text = "门柱 30"}}, -- 522
	story = {prologue = {giveReach = 46}} -- 526
} -- 526
--- 街道：两人已经同行，第一次交火在街心柜台后，打完把柜台敲两下算解除。
-- 一路走到检查站入口，提交进度后进入检查站。
____exports.STREET_ROOM = { -- 533
	key = "street", -- 534
	originX = 0, -- 535
	name = "街道 · 柜台与交火", -- 536
	caption = "小满跟着走；街心柜台后有两名敌兵，点鼠标射击，清掉后一起走到检查站入口", -- 537
	minX = 0, -- 538
	maxX = 1000, -- 539
	height = 210, -- 540
	depth = LANE_ROAD, -- 541
	floors = {{y = 0, x0 = 0, x1 = 1000}}, -- 542
	solids = {{ -- 543
		x = 300, -- 544
		w = 100, -- 544
		h = 44, -- 544
		y = 0, -- 544
		label = "街心柜台 300–400 · 高 44", -- 544
		lanes = {"lower", "middle"}, -- 544
		art = "cover_wood" -- 544
	}, { -- 544
		x = 620, -- 545
		w = 60, -- 545
		h = 36, -- 545
		y = 0, -- 545
		label = "街边矮墙 620", -- 545
		lanes = {"upper"}, -- 545
		art = "cover_stone" -- 545
	}, { -- 545
		x = 892, -- 546
		w = 40, -- 546
		h = 120, -- 546
		y = 0, -- 546
		label = "检查站门柱", -- 546
		lanes = {"lower", "upper"}, -- 546
		art = "gate_post" -- 546
	}}, -- 546
	zones = {}, -- 548
	arch = { -- 549
		x0 = 0, -- 549
		x1 = 0, -- 549
		y = 0, -- 549
		h = 0, -- 549
		label = "" -- 549
	}, -- 549
	stairs = {}, -- 550
	cart = { -- 551
		startX = 0, -- 551
		endX = 0, -- 551
		baseY = 0, -- 551
		bodyW = 0, -- 551
		bodyH = 0, -- 551
		wheelR = 0, -- 551
		handleOffset = 0, -- 551
		clothSide = 1 -- 551
	}, -- 551
	spawns = {{x = 100, y = 0, h = 88, label = "周戍 100"}, {x = 60, y = 0, h = 56, label = "小满 60"}}, -- 552
	marks = {{x = 900, y = 0, kind = 0, label = "检查站入口 900"}, {x = 520, y = 0, kind = 3, label = "街心 520"}}, -- 556
	dims = {{x0 = 300, x1 = 400, text = "柜台 100"}, {x0 = 900, x1 = 1000, text = "入口 100"}} -- 560
} -- 560
--- 城门：周戍把小满送到门洞等待点，自己回到绞盘；两人就位后开始 45 秒守点。
-- 守满后玩家走到门边按 E 送别，接着是数到二十与交权。
____exports.GATE_ROOM = { -- 570
	key = "gate", -- 571
	originX = 0, -- 572
	name = "城门 · 45 秒守点", -- 573
	caption = "小满到门洞 960、周戍贴住绞盘 118，两人就位开始 45 秒；守满走到门边按 E 送她", -- 574
	minX = 0, -- 575
	maxX = 1200, -- 576
	height = 240, -- 577
	depth = LANE_ROAD, -- 578
	floors = {{y = 0, x0 = 0, x1 = 1200}}, -- 579
	solids = { -- 580
		{ -- 581
			x = 40, -- 581
			w = 60, -- 581
			h = 60, -- 581
			y = 0, -- 581
			label = "绞盘 40–100 · 高 60", -- 581
			lanes = {"middle"}, -- 581
			art = "winch" -- 581
		}, -- 581
		{ -- 582
			x = 520, -- 582
			w = 80, -- 582
			h = 44, -- 582
			y = 0, -- 582
			label = "街垒 520 · 高 44", -- 582
			lanes = {"middle", "upper"}, -- 582
			art = "cover_stone" -- 582
		}, -- 582
		{ -- 583
			x = 840, -- 583
			w = 24, -- 583
			h = 160, -- 583
			y = 0, -- 583
			label = "城门左门柱", -- 583
			lanes = {"lower", "upper"}, -- 583
			art = "gate_post" -- 583
		}, -- 583
		{ -- 584
			x = 1016, -- 584
			w = 24, -- 584
			h = 160, -- 584
			y = 0, -- 584
			label = "城门右门柱", -- 584
			lanes = {"lower", "upper"}, -- 584
			art = "gate_post" -- 584
		}, -- 584
		{ -- 585
			x = 1040, -- 585
			w = 160, -- 585
			h = 180, -- 585
			y = 0, -- 585
			label = "门洞右墙 1040", -- 585
			depth = LANE_ROAD, -- 585
			art = "wall" -- 585
		}, -- 585
		{ -- 586
			x = 840, -- 586
			w = 200, -- 586
			h = 56, -- 586
			y = 160, -- 586
			label = "门楣 840–1040", -- 586
			depth = LANE_ROAD, -- 586
			art = "wall" -- 586
		} -- 586
	}, -- 586
	zones = {{ -- 588
		x0 = 860, -- 589
		x1 = 1000, -- 589
		y = 0, -- 589
		h = 8, -- 589
		tint = 4, -- 589
		label = "门洞 860–1000" -- 589
	}}, -- 589
	arch = { -- 591
		x0 = 0, -- 591
		x1 = 0, -- 591
		y = 0, -- 591
		h = 0, -- 591
		label = "" -- 591
	}, -- 591
	stairs = {}, -- 592
	cart = { -- 593
		startX = 0, -- 593
		endX = 0, -- 593
		baseY = 0, -- 593
		bodyW = 0, -- 593
		bodyH = 0, -- 593
		wheelR = 0, -- 593
		handleOffset = 0, -- 593
		clothSide = 1 -- 593
	}, -- 593
	spawns = {{x = 130, y = 0, h = 88, label = "周戍 130"}, {x = 150, y = 0, h = 56, label = "小满 150"}}, -- 594
	marks = {{x = 118, y = 0, kind = 1, label = "绞盘站位 118"}, {x = 960, y = 0, kind = 1, label = "门洞等待点 960"}, {x = 860, y = 0, kind = 0, label = "门边 860"}, {x = 1020, y = 0, kind = 0, label = "出门 1020"}}, -- 598
	dims = {{x0 = 40, x1 = 100, text = "绞盘 60"}, {x0 = 840, x1 = 1040, text = "门洞 200"}}, -- 604
	story = {gate = { -- 609
		winchX = 118, -- 609
		waitX = 960, -- 609
		doorX = 860, -- 609
		exitX = 1020, -- 609
		holdTicks = 2700 -- 609
	}} -- 609
} -- 609
--- 城外巷路：男主线牵手成功后的可操控起步段。
-- 
-- 侧向跟拍，两人先牵着手过一段平路（0–780），到高石阶 780–860 抬 48 后
-- 进入下一段入口（860 平台）。上背与护送试炼发生在后续段，本房只交付
-- 「交回移动」之后的同行控制。
____exports.GATE_PATH_ROOM = { -- 619
	key = "gatepath", -- 620
	originX = 0, -- 621
	name = "城外巷路 · 兄妹同行", -- 622
	caption = "牵着手沿平路往北；到高石阶前停住，下一段从这里接背上她", -- 623
	minX = 0, -- 624
	maxX = 1040, -- 625
	height = 220, -- 626
	depth = {min = -28, max = 28}, -- 627
	floors = {{y = 0, x0 = 0, x1 = 1040}, {y = 48, x0 = 860, x1 = 1040}}, -- 628
	solids = {{ -- 632
		x = 0, -- 633
		w = 60, -- 633
		h = 180, -- 633
		y = 0, -- 633
		label = "城门内墙背影 0–60", -- 633
		depth = {min = -28, max = 28}, -- 633
		art = "wall" -- 633
	}, { -- 633
		x = 560, -- 634
		w = 44, -- 634
		h = 28, -- 634
		y = 0, -- 634
		label = "倒石 560 · 高 28", -- 634
		depth = {min = -28, max = -4}, -- 634
		art = "cover_stone" -- 634
	}, { -- 634
		x = 1000, -- 635
		w = 40, -- 635
		h = 200, -- 635
		y = 0, -- 635
		label = "巷尾石壁 1000", -- 635
		depth = {min = -28, max = 28}, -- 635
		art = "wall" -- 635
	}}, -- 635
	zones = {{ -- 637
		x0 = 860, -- 638
		x1 = 1000, -- 638
		y = 48, -- 638
		h = 6, -- 638
		tint = 4, -- 638
		label = "高石阶平台 860–1000" -- 638
	}}, -- 638
	arch = { -- 640
		x0 = 0, -- 640
		x1 = 0, -- 640
		y = 0, -- 640
		h = 0, -- 640
		label = "" -- 640
	}, -- 640
	stairs = {{ -- 641
		x0 = 780, -- 642
		x1 = 860, -- 642
		y0 = 0, -- 642
		y1 = 48, -- 642
		steps = 3, -- 642
		label = "高石阶 0 / 16 / 32 / 48", -- 642
		depth = {min = -28, max = 28} -- 642
	}}, -- 642
	cart = { -- 644
		startX = 0, -- 644
		endX = 0, -- 644
		baseY = 0, -- 644
		bodyW = 0, -- 644
		bodyH = 0, -- 644
		wheelR = 0, -- 644
		handleOffset = 0, -- 644
		clothSide = 1 -- 644
	}, -- 644
	spawns = {{x = 120, y = 0, h = 88, label = "周戍 120"}, {x = 150, y = 0, h = 56, label = "小满 150"}}, -- 645
	marks = {{x = 120, y = 0, kind = 1, label = "牵头起步 120"}, {x = 520, y = 0, kind = 3, label = "袖口红布 520"}, {x = 840, y = 0, kind = 0, label = "高石阶前 840"}, {x = 980, y = 48, kind = 0, label = "下一段入口 980"}}, -- 649
	dims = {{x0 = 0, x1 = 560, text = "平路 560"}, {x0 = 780, x1 = 860, text = "高石阶 80 · 抬 48"}, {x0 = 860, x1 = 1000, text = "平台 140"}}, -- 655
	story = {gatepath = {carryX = 840, exitX = 980, next = "escort1"}} -- 660
} -- 660
--- 北塔森林：小满独自走。草后可以等，狗听见脚步会转耳朵、赶来、停一会儿再回线。
-- 最后一段从林缘自己选时机走到灯下门廊。
____exports.FOREST_ROOM = { -- 667
	key = "forest", -- 668
	originX = 0, -- 669
	name = "北塔森林 · 草与狗", -- 670
	caption = "狗对动静比人快：草后等、Shift 慢走、蹲着过；林缘 1450 走到灯下门廊", -- 671
	minX = 0, -- 672
	maxX = 1600, -- 673
	height = 200, -- 674
	depth = LANE_ROAD, -- 675
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 676
	solids = {{ -- 677
		x = 300, -- 678
		w = 80, -- 678
		h = 24, -- 678
		y = 0, -- 678
		depth = LANE_ROAD, -- 678
		label = "草丛 300–380 · 高 24", -- 678
		passable = true -- 678
	}, { -- 678
		x = 700, -- 679
		w = 90, -- 679
		h = 24, -- 679
		y = 0, -- 679
		depth = LANE_ROAD, -- 679
		label = "草丛 700–790 · 高 24", -- 679
		passable = true -- 679
	}, { -- 679
		x = 1150, -- 680
		w = 90, -- 680
		h = 24, -- 680
		y = 0, -- 680
		depth = LANE_ROAD, -- 680
		label = "草丛 1150–1240 · 高 24", -- 680
		passable = true -- 680
	}, { -- 680
		x = 1560, -- 681
		w = 40, -- 681
		h = 160, -- 681
		y = 0, -- 681
		depth = LANE_ROAD, -- 681
		label = "林缘 1560" -- 681
	}}, -- 681
	zones = {{ -- 683
		x0 = 300, -- 684
		x1 = 380, -- 684
		y = 0, -- 684
		h = 6, -- 684
		tint = 2, -- 684
		label = "树根窄洞 300–380 · 蹲行" -- 684
	}, { -- 684
		x0 = 700, -- 685
		x1 = 790, -- 685
		y = 0, -- 685
		h = 6, -- 685
		tint = 3, -- 685
		label = "旧渠 700–790 · 可跑" -- 685
	}, { -- 685
		x0 = 1180, -- 686
		x1 = 1260, -- 686
		y = 0, -- 686
		h = 6, -- 686
		tint = 1, -- 686
		label = "溪湾 1180–1260 · 水里灯" -- 686
	}, { -- 686
		x0 = 1400, -- 687
		x1 = 1470, -- 687
		y = 0, -- 687
		h = 6, -- 687
		tint = 4, -- 687
		label = "林边 1400–1470" -- 687
	}}, -- 687
	arch = { -- 689
		x0 = 0, -- 689
		x1 = 0, -- 689
		y = 0, -- 689
		h = 0, -- 689
		label = "" -- 689
	}, -- 689
	stairs = {{ -- 690
		x0 = 520, -- 691
		x1 = 640, -- 691
		y0 = 22, -- 691
		y1 = 22, -- 691
		steps = 1, -- 691
		depth = LANE_ROAD, -- 691
		label = "矮台 520–640 · 高 22" -- 691
	}, { -- 691
		x0 = 980, -- 692
		x1 = 1100, -- 692
		y0 = 22, -- 692
		y1 = 22, -- 692
		steps = 1, -- 692
		depth = LANE_ROAD, -- 692
		label = "矮台 980–1100 · 高 22" -- 692
	}}, -- 692
	cart = { -- 694
		startX = 0, -- 694
		endX = 0, -- 694
		baseY = 0, -- 694
		bodyW = 0, -- 694
		bodyH = 0, -- 694
		wheelR = 0, -- 694
		handleOffset = 0, -- 694
		clothSide = 1 -- 694
	}, -- 694
	spawns = {{x = 120, y = 0, h = 56, label = "小满 120"}}, -- 695
	marks = {{x = 1450, y = 0, kind = 0, label = "林边安全点 1450"}, {x = 620, y = 0, kind = 3, label = "矮台 620"}, {x = 1220, y = 0, kind = 6, label = "溪湾水里灯 1220"}}, -- 696
	dims = {{x0 = 300, x1 = 380, text = "窄洞 80 · 蹲"}, {x0 = 700, x1 = 790, text = "旧渠 90 · 跑"}, {x0 = 1180, x1 = 1260, text = "溪湾 80"}, {x0 = 1400, x1 = 1470, text = "林边 70"}}, -- 701
	story = {dog = {x0 = 620, x1 = 780, speed = 56, range = 300}} -- 707
} -- 707
--- 塔门与尾声：小满走到门前，按一次 E 敲两下；守卫开门接过针套和纸条，
-- 在登记簿里给下一个人留出一行空白。片尾可以再玩。
____exports.TOWER_ROOM = { -- 714
	key = "tower", -- 715
	originX = 0, -- 716
	name = "北塔塔门与值夜室 · 尾声", -- 717
	caption = "门前点 E 叩两下；守卒回叩开门后跨过门槛，到桌前长按 E 交针套、指南针和纸条", -- 718
	minX = 0, -- 719
	maxX = 720, -- 720
	height = 220, -- 721
	depth = LANE_ROAD, -- 722
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 723
	solids = { -- 724
		{ -- 725
			x = 180, -- 725
			w = 220, -- 725
			h = 200, -- 725
			y = 0, -- 725
			depth = LANE_ROAD, -- 725
			label = "塔身左 180–400" -- 725
		}, -- 725
		{ -- 726
			x = 430, -- 726
			w = 40, -- 726
			h = 120, -- 726
			y = 0, -- 726
			depth = LANE_ROAD, -- 726
			id = "tower_door", -- 726
			label = "塔门 430–470 · E 叩两下" -- 726
		}, -- 726
		{ -- 727
			x = 700, -- 727
			w = 20, -- 727
			h = 220, -- 727
			y = 0, -- 727
			depth = LANE_ROAD, -- 727
			label = "塔身右墙 700–720" -- 727
		}, -- 727
		{ -- 728
			x = 400, -- 728
			w = 90, -- 728
			h = 30, -- 728
			y = 110, -- 728
			depth = LANE_ROAD, -- 728
			label = "门楣 400–490" -- 728
		}, -- 728
		{ -- 729
			x = 560, -- 729
			w = 90, -- 729
			h = 32, -- 729
			y = 0, -- 729
			depth = LANE_ROAD, -- 729
			id = "tower_desk", -- 729
			art = "cover_wood", -- 729
			label = "值夜桌 560–650 · 长按 E 交物" -- 729
		}, -- 729
		{ -- 730
			x = 660, -- 730
			w = 40, -- 730
			h = 8, -- 730
			y = 120, -- 730
			decorative = true, -- 730
			label = "西窗 660–700" -- 730
		} -- 730
	}, -- 730
	zones = {{ -- 732
		x0 = 400, -- 733
		x1 = 490, -- 733
		y = 0, -- 733
		h = 8, -- 733
		tint = 4, -- 733
		label = "门廊 400–490" -- 733
	}, { -- 733
		x0 = 490, -- 734
		x1 = 700, -- 734
		y = 0, -- 734
		h = 8, -- 734
		tint = 3, -- 734
		label = "值夜室 490–700" -- 734
	}}, -- 734
	arch = { -- 736
		x0 = 0, -- 736
		x1 = 0, -- 736
		y = 0, -- 736
		h = 0, -- 736
		label = "" -- 736
	}, -- 736
	stairs = {}, -- 737
	cart = { -- 738
		startX = 0, -- 738
		endX = 0, -- 738
		baseY = 0, -- 738
		bodyW = 0, -- 738
		bodyH = 0, -- 738
		wheelR = 0, -- 738
		handleOffset = 0, -- 738
		clothSide = 1 -- 738
	}, -- 738
	spawns = {{x = 400, y = 0, h = 56, label = "小满 400 · 门廊里"}}, -- 739
	marks = {{x = 445, y = 0, kind = 1, label = "门前 445"}, {x = 520, y = 0, kind = 3, label = "门槛 520"}, {x = 605, y = 0, kind = 3, label = "值夜桌 605"}, {x = 680, y = 0, kind = 6, label = "西窗 680"}}, -- 740
	dims = {{x0 = 400, x1 = 490, text = "门 90"}, {x0 = 560, x1 = 650, text = "桌 90"}}, -- 746
	story = {tower = {doorX = 445, knockTicks = 36}} -- 750
} -- 750
local NO_CART = { -- 753
	startX = 0, -- 754
	endX = 0, -- 754
	baseY = 0, -- 754
	bodyW = 0, -- 754
	bodyH = 0, -- 754
	wheelR = 0, -- 754
	handleOffset = 0, -- 754
	clothSide = -1 -- 754
} -- 754
--- C2 博物馆返场：一次「时间穿梭器」的虚构现代纪念厅。
-- 玩家单人（周戍）走完柜前、走廊、末厅、回柜边四步，每步一个输入边沿。
____exports.MUSEUM_ROOM = { -- 762
	key = "museum", -- 763
	name = "博物馆 · 西厅", -- 764
	caption = "虚构 · 现代纪念厅", -- 765
	originX = 0, -- 766
	minX = 0, -- 766
	maxX = 1400, -- 766
	height = 240, -- 766
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 767
	solids = { -- 768
		{ -- 769
			x = 180, -- 769
			w = 80, -- 769
			h = 64, -- 769
			y = 0, -- 769
			label = "玻璃柜 180–260 · 高 64", -- 769
			decorative = true, -- 769
			id = "museum_case" -- 769
		}, -- 769
		{ -- 770
			x = 540, -- 770
			w = 60, -- 770
			h = 140, -- 770
			y = 0, -- 770
			label = "展墙 540–600 · 高 140", -- 770
			decorative = true -- 770
		}, -- 770
		{ -- 771
			x = 1180, -- 771
			w = 40, -- 771
			h = 160, -- 771
			y = 0, -- 771
			label = "末厅门柱 1180–1220 · 高 160", -- 771
			decorative = true -- 771
		}, -- 771
		{ -- 772
			x = 1300, -- 772
			w = 60, -- 772
			h = 8, -- 772
			y = 120, -- 772
			label = "西窗 1300–1360 · 高 8", -- 772
			decorative = true -- 772
		}, -- 772
		{ -- 773
			x = 1360, -- 773
			w = 40, -- 773
			h = 200, -- 773
			y = 0, -- 773
			label = "馆尾 1360–1400 · 高 200" -- 773
		} -- 773
	}, -- 773
	zones = {{ -- 775
		x0 = 160, -- 776
		x1 = 300, -- 776
		y = 0, -- 776
		h = 16, -- 776
		tint = 1, -- 776
		label = "玻璃柜前" -- 776
	}, { -- 776
		x0 = 860, -- 777
		x1 = 980, -- 777
		y = 0, -- 777
		h = 16, -- 777
		tint = 2, -- 777
		label = "走廊 · 孩子脚步" -- 777
	}, { -- 777
		x0 = 1210, -- 778
		x1 = 1320, -- 778
		y = 0, -- 778
		h = 16, -- 778
		tint = 3, -- 778
		label = "末厅 · 西窗" -- 778
	}}, -- 778
	arch = { -- 780
		x0 = 0, -- 780
		x1 = 0, -- 780
		y = 0, -- 780
		h = 0, -- 780
		label = "" -- 780
	}, -- 780
	stairs = {}, -- 781
	cart = NO_CART, -- 782
	spawns = {{x = 80, y = 0, h = 88, label = "周戍 80 · 展厅入口"}}, -- 783
	marks = {{x = 200, y = 0, kind = 4, label = "玻璃柜 200"}, {x = 900, y = 0, kind = 4, label = "走廊 900"}, {x = 1250, y = 0, kind = 6, label = "末厅 1250"}, {x = 1360, y = 0, kind = 0, label = "出口 1360"}}, -- 784
	dims = {{x0 = 160, x1 = 300, text = "柜 80"}, {x0 = 1180, x1 = 1220, text = "门 40"}}, -- 790
	story = {museum = {cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}} -- 794
} -- 794
--- 男主首场护送战：背着受伤的小满穿过城外巷路。
-- 巷底两名火器手与一名破障手压过来，玩家边观察边完成一次慢时连线换弹，走到巷尾脱身。
____exports.ESCORT1_ROOM = { -- 801
	key = "escort1", -- 802
	originX = 0, -- 803
	name = "城外巷路 · 第一段护送", -- 804
	caption = "背上的小满贴着肩；巷底两名火器手与一名破障手压过来，走到巷尾就算脱身", -- 805
	minX = 0, -- 806
	maxX = 1600, -- 807
	height = 220, -- 808
	depth = LANE_ROAD, -- 809
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 810
	solids = { -- 811
		{ -- 812
			x = 0, -- 812
			w = 50, -- 812
			h = 150, -- 812
			y = 0, -- 812
			label = "巷口背影 0–50", -- 812
			depth = LANE_ROAD, -- 812
			art = "wall" -- 812
		}, -- 812
		{ -- 813
			x = 380, -- 813
			w = 96, -- 813
			h = 44, -- 813
			y = 0, -- 813
			label = "塌墙 380–476 · 高 44", -- 813
			lanes = {"lower", "middle"}, -- 813
			art = "cover_stone", -- 813
			id = "e1_wall" -- 813
		}, -- 813
		{ -- 814
			x = 620, -- 814
			w = 24, -- 814
			h = 50, -- 814
			y = 0, -- 814
			label = "薄木护板 620 · 高 50", -- 814
			lanes = {"upper"}, -- 814
			art = "cover_wood", -- 814
			id = "e1_wood", -- 814
			breakable = {hp = 2, kind = "thin_wood", wedgeable = true} -- 814
		}, -- 814
		{ -- 815
			x = 700, -- 815
			w = 40, -- 815
			h = 28, -- 815
			y = 0, -- 815
			label = "倒石 700 · 高 28", -- 815
			lanes = {"lower"}, -- 815
			art = "cover_stone" -- 815
		}, -- 815
		{ -- 816
			x = 980, -- 816
			w = 160, -- 816
			h = 36, -- 816
			y = 0, -- 816
			label = "石台 980–1140 · 高 36（可跳）", -- 816
			lanes = {"lower"}, -- 816
			art = "cover_wood" -- 816
		}, -- 816
		{ -- 817
			x = 1300, -- 817
			w = 40, -- 817
			h = 140, -- 817
			y = 0, -- 817
			label = "巷尾门柱 1300", -- 817
			lanes = {"lower", "upper"}, -- 817
			art = "gate_post" -- 817
		}, -- 817
		{ -- 818
			x = 1560, -- 818
			w = 40, -- 818
			h = 180, -- 818
			y = 0, -- 818
			label = "巷尾断墙 1560–1600 · 高 180", -- 818
			depth = LANE_ROAD, -- 818
			art = "wall" -- 818
		} -- 818
	}, -- 818
	zones = {{ -- 820
		x0 = 560, -- 820
		x1 = 900, -- 820
		y = 0, -- 820
		h = 150, -- 820
		tint = 1, -- 820
		label = "交火 560–900" -- 820
	}}, -- 820
	arch = { -- 821
		x0 = 0, -- 821
		x1 = 0, -- 821
		y = 0, -- 821
		h = 0, -- 821
		label = "" -- 821
	}, -- 821
	stairs = {{ -- 822
		x0 = 1140, -- 822
		x1 = 1300, -- 822
		y0 = 0, -- 822
		y1 = 40, -- 822
		steps = 3, -- 822
		label = "石台斜走 1140–1300", -- 822
		lanes = {"lower", "middle"} -- 822
	}}, -- 822
	cart = NO_CART, -- 823
	spawns = {{ -- 824
		x = 820, -- 825
		y = 0, -- 825
		h = 84, -- 825
		depth = 32, -- 825
		label = "火器手 820 · 中档", -- 825
		kind = "gunner", -- 825
		drop = "ammo" -- 825
	}, { -- 825
		x = 1020, -- 826
		y = 0, -- 826
		h = 84, -- 826
		depth = -28, -- 826
		label = "火器手 1020 · 浅档", -- 826
		kind = "gunner", -- 826
		drop = "ammo" -- 826
	}, { -- 826
		x = 1120, -- 827
		y = 0, -- 827
		h = 84, -- 827
		depth = -28, -- 827
		label = "破障手 1120", -- 827
		kind = "breaker", -- 827
		drop = "wedge" -- 827
	}}, -- 827
	marks = {{x = 200, y = 0, kind = 3, label = "背负起点 200"}, {x = 476, y = 0, kind = 3, label = "塌墙后 476"}, {x = 900, y = 0, kind = 0, label = "交火尽头 900"}, {x = 1500, y = 0, kind = 0, label = "安全出口 1500"}}, -- 829
	dims = {{x0 = 380, x1 = 476, text = "塌墙 96"}, {x0 = 980, x1 = 1140, text = "石台 160"}, {x0 = 1300, x1 = 1600, text = "巷尾 300"}}, -- 835
	campaign = { -- 840
		chapter = "O", -- 840
		act = 1, -- 840
		budget = 240, -- 840
		goal = "reach_exit", -- 840
		exitX = 1500, -- 840
		next = "escort2", -- 840
		checkpoint = 1, -- 840
		reloadPuzzle = true -- 840
	} -- 840
} -- 840
--- 第二段粮棚：从第一段巷尾转进粮棚，高低两条通路各放材料。
-- 上层棚架两枚木纹筹，地面一枚木纹筹与一枚铃纹筹——走齐两条通路才能凑够两种配方。
____exports.ESCORT2_ROOM = { -- 848
	key = "escort2", -- 849
	originX = 0, -- 850
	name = "粮棚 · 第二段取材", -- 851
	caption = "棚架与地面沿途收集：木纹筹两枚、铃纹筹一枚，够在工台二选一", -- 852
	minX = 0, -- 853
	maxX = 1500, -- 854
	height = 220, -- 855
	depth = LANE_ROAD, -- 856
	floors = {{y = 0, x0 = 0, x1 = 1500}}, -- 857
	solids = { -- 858
		{ -- 859
			x = 0, -- 859
			w = 50, -- 859
			h = 160, -- 859
			y = 0, -- 859
			label = "棚口背影 0–50", -- 859
			depth = LANE_ROAD, -- 859
			art = "wall" -- 859
		}, -- 859
		{ -- 860
			x = 300, -- 860
			w = 24, -- 860
			h = 64, -- 860
			y = 0, -- 860
			label = "棚架柱 300", -- 860
			lanes = {"lower"}, -- 860
			art = "cover_wood" -- 860
		}, -- 860
		{ -- 861
			x = 300, -- 861
			w = 600, -- 861
			h = 8, -- 861
			y = 64, -- 861
			label = "棚架梁 300–900 · 高 64", -- 861
			depth = {min = -44, max = -20}, -- 861
			passable = true, -- 861
			art = "cover_wood" -- 861
		}, -- 861
		{ -- 862
			x = 640, -- 862
			w = 60, -- 862
			h = 32, -- 862
			y = 0, -- 862
			label = "倒粮袋 640 · 高 32", -- 862
			lanes = {"lower"}, -- 862
			art = "grain_sack", -- 862
			id = "e2_grain_sacks" -- 862
		}, -- 862
		{ -- 863
			x = 980, -- 863
			w = 140, -- 863
			h = 48, -- 863
			y = 0, -- 863
			label = "粮台 980–1120 · 高 48", -- 863
			lanes = {"lower", "middle"}, -- 863
			art = "cover_wood" -- 863
		}, -- 863
		{ -- 864
			x = 1460, -- 864
			w = 40, -- 864
			h = 180, -- 864
			y = 0, -- 864
			label = "棚尾断墙 1460–1500 · 高 180", -- 864
			depth = LANE_ROAD, -- 864
			art = "wall" -- 864
		} -- 864
	}, -- 864
	zones = {{ -- 866
		x0 = 520, -- 866
		x1 = 900, -- 866
		y = 0, -- 866
		h = 150, -- 866
		tint = 1, -- 866
		label = "取材 520–900" -- 866
	}}, -- 866
	arch = { -- 867
		x0 = 0, -- 867
		x1 = 0, -- 867
		y = 0, -- 867
		h = 0, -- 867
		label = "" -- 867
	}, -- 867
	stairs = {{ -- 868
		x0 = 780, -- 868
		x1 = 900, -- 868
		y0 = 0, -- 868
		y1 = 64, -- 868
		steps = 3, -- 868
		label = "棚架斜梯 780–900", -- 868
		lanes = {"lower", "middle"} -- 868
	}}, -- 868
	cart = NO_CART, -- 869
	spawns = {{ -- 870
		x = 700, -- 871
		y = 0, -- 871
		h = 84, -- 871
		depth = 32, -- 871
		label = "火器手 700 · 中档", -- 871
		kind = "gunner", -- 871
		drop = "ammo" -- 871
	}, { -- 871
		x = 1080, -- 872
		y = 0, -- 872
		h = 84, -- 872
		depth = -28, -- 872
		label = "火器手 1080 · 浅档", -- 872
		kind = "gunner", -- 872
		drop = "ammo" -- 872
	}, { -- 872
		x = 1200, -- 873
		y = 0, -- 873
		h = 84, -- 873
		depth = 24, -- 873
		label = "破障手 1200", -- 873
		kind = "breaker", -- 873
		drop = "wedge" -- 873
	}}, -- 873
	marks = {{x = 200, y = 0, kind = 3, label = "进棚 200"}, {x = 476, y = 0, kind = 3, label = "棚架下 476"}, {x = 900, y = 0, kind = 0, label = "棚架尽头 900"}, {x = 1400, y = 0, kind = 0, label = "粮棚出口 1400"}}, -- 875
	dims = {{x0 = 300, x1 = 900, text = "棚架 600"}, {x0 = 980, x1 = 1120, text = "粮台 140"}}, -- 881
	pickups = {{ -- 885
		id = "e2_wood_a", -- 886
		kind = "wood", -- 886
		x = 380, -- 886
		y = 0, -- 886
		label = "木纹筹 · 棚下" -- 886
	}, { -- 886
		id = "e2_bell", -- 887
		kind = "bell", -- 887
		x = 560, -- 887
		y = 0, -- 887
		label = "铃纹筹 · 粮袋后" -- 887
	}, { -- 887
		id = "e2_wood_b", -- 888
		kind = "wood", -- 888
		x = 820, -- 888
		y = 0, -- 888
		label = "木纹筹 · 棚架后" -- 888
	}}, -- 888
	campaign = { -- 890
		chapter = "O", -- 890
		act = 2, -- 890
		budget = 240, -- 890
		goal = "reach_exit", -- 890
		exitX = 1400, -- 890
		next = "escort3", -- 890
		checkpoint = 1, -- 890
		reloadPuzzle = true -- 890
	} -- 890
} -- 890
--- 第三段安全工台：放下小满，看材料与两张配方，改制、装备、离站再背起。
-- 工台前的薄掩体与两个靶位用于当场试射：灯纹穿掩体、铃纹同时惊起两个声源。
____exports.ESCORT3_ROOM = { -- 897
	key = "escort3", -- 898
	originX = 0, -- 899
	name = "山腰工台 · 第三段改制", -- 900
	caption = "放下小满 → 工台按 E 看配方 → 选一件改制装备 → 试射一枪 → 离站重新背起", -- 901
	minX = 0, -- 902
	maxX = 1200, -- 903
	height = 220, -- 904
	depth = LANE_ROAD, -- 905
	floors = {{y = 0, x0 = 0, x1 = 1200}}, -- 906
	solids = { -- 907
		{ -- 908
			x = 0, -- 908
			w = 50, -- 908
			h = 160, -- 908
			y = 0, -- 908
			label = "工台口背影 0–50", -- 908
			depth = LANE_ROAD, -- 908
			art = "wall" -- 908
		}, -- 908
		{ -- 909
			x = 560, -- 909
			w = 120, -- 909
			h = 44, -- 909
			y = 0, -- 909
			label = "工台 560–680 · 高 44", -- 909
			lanes = {"middle", "upper"}, -- 909
			art = "cover_wood", -- 909
			id = "e3_bench" -- 909
		}, -- 909
		{ -- 910
			x = 720, -- 910
			w = 48, -- 910
			h = 52, -- 910
			y = 0, -- 910
			label = "试射薄掩体 720–768 · 高 52", -- 910
			lanes = {"lower", "middle"}, -- 910
			art = "cover_stone", -- 910
			id = "e3_cover" -- 910
		}, -- 910
		{ -- 911
			x = 1050, -- 911
			w = 40, -- 911
			h = 140, -- 911
			y = 0, -- 911
			label = "出站门柱 1050", -- 911
			lanes = {"lower", "upper"}, -- 911
			art = "gate_post" -- 911
		}, -- 911
		{ -- 912
			x = 1170, -- 912
			w = 30, -- 912
			h = 180, -- 912
			y = 0, -- 912
			label = "出站断墙 1170–1200 · 高 180", -- 912
			depth = LANE_ROAD, -- 912
			art = "wall" -- 912
		} -- 912
	}, -- 912
	zones = {{ -- 914
		x0 = 560, -- 914
		x1 = 960, -- 914
		y = 0, -- 914
		h = 120, -- 914
		tint = 3, -- 914
		label = "工台安全区 560–960" -- 914
	}}, -- 914
	arch = { -- 915
		x0 = 0, -- 915
		x1 = 0, -- 915
		y = 0, -- 915
		h = 0, -- 915
		label = "" -- 915
	}, -- 915
	stairs = {}, -- 916
	cart = NO_CART, -- 917
	spawns = {{ -- 918
		x = 820, -- 919
		y = 0, -- 919
		h = 84, -- 919
		depth = 16, -- 919
		label = "试射靶一 820", -- 919
		kind = "target" -- 919
	}, { -- 919
		x = 940, -- 920
		y = 0, -- 920
		h = 84, -- 920
		depth = -16, -- 920
		label = "试射靶二 940", -- 920
		kind = "target" -- 920
	}}, -- 920
	marks = {{x = 300, y = 0, kind = 0, label = "制前检查点 300"}, {x = 640, y = 0, kind = 3, label = "工台 640"}, {x = 960, y = 0, kind = 0, label = "制后检查点 960"}, {x = 1150, y = 0, kind = 0, label = "出站 1150"}}, -- 922
	dims = {{x0 = 560, x1 = 680, text = "工台 120"}, {x0 = 720, x1 = 768, text = "掩体 48"}}, -- 928
	campaign = { -- 932
		chapter = "O", -- 932
		act = 3, -- 932
		budget = 240, -- 932
		goal = "reach_exit", -- 932
		exitX = 1150, -- 932
		next = "escort4", -- 932
		checkpoint = 1, -- 932
		reloadPuzzle = true -- 932
	} -- 932
} -- 932
--- 第四段山道：边走边换弹的窄道，塌方与追兵逼玩家在换弹与脱身之间选。
____exports.ESCORT4_ROOM = { -- 938
	key = "escort4", -- 939
	originX = 0, -- 940
	name = "山道 · 第四段脱身", -- 941
	caption = "窄道上两个火器手与一个破障手；换弹时世界会慢下来，也可以滚身脱出", -- 942
	minX = 0, -- 943
	maxX = 1400, -- 944
	height = 240, -- 945
	depth = LANE_ROAD, -- 946
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 947
	solids = { -- 948
		{ -- 949
			x = 0, -- 949
			w = 50, -- 949
			h = 170, -- 949
			y = 0, -- 949
			label = "山道口 0–50", -- 949
			depth = LANE_ROAD, -- 949
			art = "wall" -- 949
		}, -- 949
		{ -- 950
			x = 380, -- 950
			w = 80, -- 950
			h = 40, -- 950
			y = 0, -- 950
			label = "塌方 380–460 · 高 40", -- 950
			lanes = {"lower", "middle"}, -- 950
			art = "cover_stone", -- 950
			id = "e4_fall" -- 950
		}, -- 950
		{ -- 951
			x = 680, -- 951
			w = 24, -- 951
			h = 50, -- 951
			y = 0, -- 951
			label = "薄木护板 680 · 高 50", -- 951
			lanes = {"upper"}, -- 951
			art = "cover_wood", -- 951
			id = "e4_wood", -- 951
			breakable = {hp = 2, kind = "thin_wood", wedgeable = true} -- 951
		}, -- 951
		{ -- 952
			x = 900, -- 952
			w = 60, -- 952
			h = 36, -- 952
			y = 0, -- 952
			label = "断口 900–960 · 高 36（可跳）", -- 952
			lanes = {"lower", "middle"}, -- 952
			art = "cover_stone" -- 952
		}, -- 952
		{ -- 953
			x = 1120, -- 953
			w = 40, -- 953
			h = 32, -- 953
			y = 0, -- 953
			label = "倒石 1120 · 高 32", -- 953
			lanes = {"lower"}, -- 953
			art = "cover_stone" -- 953
		}, -- 953
		{ -- 954
			x = 1350, -- 954
			w = 50, -- 954
			h = 200, -- 954
			y = 0, -- 954
			label = "山道尾壁 1350–1400 · 高 200", -- 954
			depth = LANE_ROAD, -- 954
			art = "wall" -- 954
		} -- 954
	}, -- 954
	zones = {{ -- 956
		x0 = 500, -- 956
		x1 = 900, -- 956
		y = 0, -- 956
		h = 160, -- 956
		tint = 2, -- 956
		label = "窄道 500–900" -- 956
	}}, -- 956
	arch = { -- 957
		x0 = 0, -- 957
		x1 = 0, -- 957
		y = 0, -- 957
		h = 0, -- 957
		label = "" -- 957
	}, -- 957
	stairs = {}, -- 958
	cart = NO_CART, -- 959
	spawns = {{ -- 960
		x = 620, -- 961
		y = 0, -- 961
		h = 84, -- 961
		depth = 32, -- 961
		label = "火器手 620 · 中档", -- 961
		kind = "gunner", -- 961
		drop = "ammo" -- 961
	}, { -- 961
		x = 840, -- 962
		y = 0, -- 962
		h = 84, -- 962
		depth = -28, -- 962
		label = "火器手 840 · 浅档", -- 962
		kind = "gunner", -- 962
		drop = "ammo" -- 962
	}, { -- 962
		x = 1060, -- 963
		y = 0, -- 963
		h = 84, -- 963
		depth = 24, -- 963
		label = "破障手 1060", -- 963
		kind = "breaker", -- 963
		drop = "wedge" -- 963
	}}, -- 963
	marks = {{x = 200, y = 0, kind = 3, label = "进山道 200"}, {x = 476, y = 0, kind = 3, label = "塌方后 476"}, {x = 960, y = 0, kind = 0, label = "断口 960"}, {x = 1300, y = 0, kind = 0, label = "山道出口 1300"}}, -- 965
	dims = {{x0 = 380, x1 = 460, text = "塌方 80"}, {x0 = 900, x1 = 960, text = "断口 60"}}, -- 971
	campaign = { -- 975
		chapter = "O", -- 975
		act = 4, -- 975
		budget = 240, -- 975
		goal = "reach_exit", -- 975
		exitX = 1300, -- 975
		next = "escort5", -- 975
		checkpoint = 1, -- 975
		reloadPuzzle = true -- 975
	} -- 975
} -- 975
--- 第五段山道：带着自己改制的武器走到塔门；出口直接接北塔。
____exports.ESCORT5_ROOM = { -- 981
	key = "escort5", -- 982
	originX = 0, -- 983
	name = "塔前山道 · 第五段", -- 984
	caption = "最后一段：带自己的武器走到塔门，走到 1320 就进北塔", -- 985
	minX = 0, -- 986
	maxX = 1400, -- 987
	height = 240, -- 988
	depth = LANE_ROAD, -- 989
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 990
	solids = { -- 991
		{ -- 992
			x = 0, -- 992
			w = 50, -- 992
			h = 170, -- 992
			y = 0, -- 992
			label = "山道口 0–50", -- 992
			depth = LANE_ROAD, -- 992
			art = "wall" -- 992
		}, -- 992
		{ -- 993
			x = 320, -- 993
			w = 96, -- 993
			h = 44, -- 993
			y = 0, -- 993
			label = "石阶塌墙 320–416 · 高 44", -- 993
			lanes = {"lower", "middle"}, -- 993
			art = "cover_stone", -- 993
			id = "e5_wall" -- 993
		}, -- 993
		{ -- 994
			x = 700, -- 994
			w = 160, -- 994
			h = 36, -- 994
			y = 0, -- 994
			label = "石台 700–860 · 高 36（可跳）", -- 994
			lanes = {"lower"}, -- 994
			art = "cover_wood" -- 994
		}, -- 994
		{ -- 995
			x = 1050, -- 995
			w = 40, -- 995
			h = 140, -- 995
			y = 0, -- 995
			label = "塔前门柱 1050", -- 995
			lanes = {"lower", "upper"}, -- 995
			art = "gate_post" -- 995
		}, -- 995
		{ -- 996
			x = 1370, -- 996
			w = 30, -- 996
			h = 200, -- 996
			y = 0, -- 996
			label = "塔前壁 1370–1400 · 高 200", -- 996
			depth = LANE_ROAD, -- 996
			art = "wall" -- 996
		} -- 996
	}, -- 996
	zones = {{ -- 998
		x0 = 600, -- 998
		x1 = 960, -- 998
		y = 0, -- 998
		h = 160, -- 998
		tint = 4, -- 998
		label = "塔前 600–960" -- 998
	}}, -- 998
	arch = { -- 999
		x0 = 0, -- 999
		x1 = 0, -- 999
		y = 0, -- 999
		h = 0, -- 999
		label = "" -- 999
	}, -- 999
	stairs = {{ -- 1000
		x0 = 860, -- 1000
		x1 = 980, -- 1000
		y0 = 0, -- 1000
		y1 = 40, -- 1000
		steps = 3, -- 1000
		label = "石台斜走 860–980", -- 1000
		lanes = {"lower", "middle"} -- 1000
	}}, -- 1000
	cart = NO_CART, -- 1001
	spawns = {{ -- 1002
		x = 560, -- 1003
		y = 0, -- 1003
		h = 84, -- 1003
		depth = 32, -- 1003
		label = "火器手 560 · 中档", -- 1003
		kind = "gunner", -- 1003
		drop = "ammo" -- 1003
	}, { -- 1003
		x = 780, -- 1004
		y = 0, -- 1004
		h = 84, -- 1004
		depth = -28, -- 1004
		label = "火器手 780 · 浅档", -- 1004
		kind = "gunner", -- 1004
		drop = "ammo" -- 1004
	}, { -- 1004
		x = 980, -- 1005
		y = 0, -- 1005
		h = 84, -- 1005
		depth = 24, -- 1005
		label = "持盾手 980", -- 1005
		kind = "shield", -- 1005
		drop = "shield" -- 1005
	}}, -- 1005
	marks = {{x = 200, y = 0, kind = 3, label = "进塔前 200"}, {x = 476, y = 0, kind = 3, label = "塌墙后 476"}, {x = 960, y = 0, kind = 0, label = "塔前 960"}, {x = 1320, y = 0, kind = 0, label = "塔门 1320"}}, -- 1007
	dims = {{x0 = 320, x1 = 416, text = "塌墙 96"}, {x0 = 700, x1 = 860, text = "石台 160"}}, -- 1013
	campaign = { -- 1017
		chapter = "O", -- 1017
		act = 5, -- 1017
		budget = 240, -- 1017
		goal = "reach_exit", -- 1017
		exitX = 1320, -- 1017
		next = "tower", -- 1017
		checkpoint = 1, -- 1017
		reloadPuzzle = true -- 1017
	} -- 1017
} -- 1017
--- 男主线五段护送（escort1 / escort2 / escort4 / escort5）的种子驱动遭遇变体池：
-- - 变体 0 与房间默认 spawns 完全一致（兼容基准回放与调试夹具）；
-- - 变体 1 / 变体 2 在正式与章节男主线按 (seed, attempt, roomKey) 确定性切换敌兵编组与掉落，
--   让每轮护送与倒地重开具备真正的局内战术变化。
____exports.ESCORT_VARIANTS = {escort1 = {____exports.ESCORT1_ROOM.spawns, {{ -- 1026
	x = 760, -- 1030
	y = 0, -- 1030
	h = 84, -- 1030
	depth = 28, -- 1030
	label = "火器手 760 · 上档", -- 1030
	kind = "gunner", -- 1030
	drop = "ammo" -- 1030
}, { -- 1030
	x = 940, -- 1031
	y = 0, -- 1031
	h = 84, -- 1031
	depth = 0, -- 1031
	label = "破障手 940 · 中档", -- 1031
	kind = "breaker", -- 1031
	drop = "wedge" -- 1031
}, { -- 1031
	x = 1140, -- 1032
	y = 0, -- 1032
	h = 84, -- 1032
	depth = -24, -- 1032
	label = "火器手 1140 · 浅档", -- 1032
	kind = "gunner", -- 1032
	drop = "ammo" -- 1032
}, { -- 1032
	x = 1260, -- 1033
	y = 0, -- 1033
	h = 84, -- 1033
	depth = 24, -- 1033
	label = "破障手 1260 · 上档", -- 1033
	kind = "breaker", -- 1033
	drop = "wedge" -- 1033
}}, {{ -- 1033
	x = 800, -- 1036
	y = 0, -- 1036
	h = 84, -- 1036
	depth = 0, -- 1036
	label = "持盾手 800 · 中档", -- 1036
	kind = "shield", -- 1036
	drop = "shield" -- 1036
}, { -- 1036
	x = 1020, -- 1037
	y = 0, -- 1037
	h = 84, -- 1037
	depth = 32, -- 1037
	label = "火器手 1020 · 上档", -- 1037
	kind = "gunner", -- 1037
	drop = "ammo" -- 1037
}, { -- 1037
	x = 1180, -- 1038
	y = 0, -- 1038
	h = 84, -- 1038
	depth = -28, -- 1038
	label = "火器手 1180 · 浅档", -- 1038
	kind = "gunner", -- 1038
	drop = "ammo" -- 1038
}}}, escort2 = {____exports.ESCORT2_ROOM.spawns, {{ -- 1038
	x = 680, -- 1044
	y = 0, -- 1044
	h = 84, -- 1044
	depth = -24, -- 1044
	label = "破障手 680 · 浅档", -- 1044
	kind = "breaker", -- 1044
	drop = "wedge" -- 1044
}, { -- 1044
	x = 920, -- 1045
	y = 0, -- 1045
	h = 84, -- 1045
	depth = 32, -- 1045
	label = "火器手 920 · 上档", -- 1045
	kind = "gunner", -- 1045
	drop = "ammo" -- 1045
}, { -- 1045
	x = 1140, -- 1046
	y = 0, -- 1046
	h = 84, -- 1046
	depth = 20, -- 1046
	label = "破障手 1140 · 上档", -- 1046
	kind = "breaker", -- 1046
	drop = "wedge" -- 1046
}, { -- 1046
	x = 1260, -- 1047
	y = 0, -- 1047
	h = 84, -- 1047
	depth = -20, -- 1047
	label = "火器手 1260 · 浅档", -- 1047
	kind = "gunner", -- 1047
	drop = "ammo" -- 1047
}}, {{ -- 1047
	x = 640, -- 1050
	y = 0, -- 1050
	h = 84, -- 1050
	depth = 32, -- 1050
	label = "火器手 640 · 上档", -- 1050
	kind = "gunner", -- 1050
	drop = "ammo" -- 1050
}, { -- 1050
	x = 880, -- 1051
	y = 0, -- 1051
	h = 84, -- 1051
	depth = 0, -- 1051
	label = "持盾手 880 · 中档", -- 1051
	kind = "shield", -- 1051
	drop = "shield" -- 1051
}, { -- 1051
	x = 1140, -- 1052
	y = 0, -- 1052
	h = 84, -- 1052
	depth = -28, -- 1052
	label = "火器手 1140 · 浅档", -- 1052
	kind = "gunner", -- 1052
	drop = "ammo" -- 1052
}}}, escort4 = {____exports.ESCORT4_ROOM.spawns, {{ -- 1052
	x = 580, -- 1058
	y = 0, -- 1058
	h = 84, -- 1058
	depth = -24, -- 1058
	label = "火器手 580 · 浅档", -- 1058
	kind = "gunner", -- 1058
	drop = "ammo" -- 1058
}, { -- 1058
	x = 780, -- 1059
	y = 0, -- 1059
	h = 84, -- 1059
	depth = 16, -- 1059
	label = "破障手 780 · 中档", -- 1059
	kind = "breaker", -- 1059
	drop = "wedge" -- 1059
}, { -- 1059
	x = 980, -- 1060
	y = 0, -- 1060
	h = 84, -- 1060
	depth = -16, -- 1060
	label = "持盾手 980 · 浅档", -- 1060
	kind = "shield", -- 1060
	drop = "shield" -- 1060
}, { -- 1060
	x = 1140, -- 1061
	y = 0, -- 1061
	h = 84, -- 1061
	depth = 28, -- 1061
	label = "火器手 1140 · 上档", -- 1061
	kind = "gunner", -- 1061
	drop = "ammo" -- 1061
}}, {{ -- 1061
	x = 640, -- 1064
	y = 0, -- 1064
	h = 84, -- 1064
	depth = 16, -- 1064
	label = "持盾手 640 · 中档", -- 1064
	kind = "shield", -- 1064
	drop = "shield" -- 1064
}, { -- 1064
	x = 820, -- 1065
	y = 0, -- 1065
	h = 84, -- 1065
	depth = -28, -- 1065
	label = "火器手 820 · 浅档", -- 1065
	kind = "gunner", -- 1065
	drop = "ammo" -- 1065
}, { -- 1065
	x = 1020, -- 1066
	y = 0, -- 1066
	h = 84, -- 1066
	depth = 0, -- 1066
	label = "破障手 1020 · 中档", -- 1066
	kind = "breaker", -- 1066
	drop = "wedge" -- 1066
}, { -- 1066
	x = 1180, -- 1067
	y = 0, -- 1067
	h = 84, -- 1067
	depth = 28, -- 1067
	label = "火器手 1180 · 上档", -- 1067
	kind = "gunner", -- 1067
	drop = "ammo" -- 1067
}}}, escort5 = {____exports.ESCORT5_ROOM.spawns, {{ -- 1067
	x = 520, -- 1073
	y = 0, -- 1073
	h = 84, -- 1073
	depth = -24, -- 1073
	label = "火器手 520 · 浅档", -- 1073
	kind = "gunner", -- 1073
	drop = "ammo" -- 1073
}, { -- 1073
	x = 740, -- 1074
	y = 0, -- 1074
	h = 84, -- 1074
	depth = 16, -- 1074
	label = "持盾手 740 · 中档", -- 1074
	kind = "shield", -- 1074
	drop = "shield" -- 1074
}, { -- 1074
	x = 920, -- 1075
	y = 0, -- 1075
	h = 84, -- 1075
	depth = -20, -- 1075
	label = "破障手 920 · 浅档", -- 1075
	kind = "breaker", -- 1075
	drop = "wedge" -- 1075
}, { -- 1075
	x = 1100, -- 1076
	y = 0, -- 1076
	h = 84, -- 1076
	depth = 28, -- 1076
	label = "火器手 1100 · 上档", -- 1076
	kind = "gunner", -- 1076
	drop = "ammo" -- 1076
}}, {{ -- 1076
	x = 580, -- 1079
	y = 0, -- 1079
	h = 84, -- 1079
	depth = 0, -- 1079
	label = "持盾手 580 · 中档", -- 1079
	kind = "shield", -- 1079
	drop = "shield" -- 1079
}, { -- 1079
	x = 760, -- 1080
	y = 0, -- 1080
	h = 84, -- 1080
	depth = 32, -- 1080
	label = "火器手 760 · 上档", -- 1080
	kind = "gunner", -- 1080
	drop = "ammo" -- 1080
}, { -- 1080
	x = 940, -- 1081
	y = 0, -- 1081
	h = 84, -- 1081
	depth = -28, -- 1081
	label = "火器手 940 · 浅档", -- 1081
	kind = "gunner", -- 1081
	drop = "ammo" -- 1081
}, { -- 1081
	x = 1100, -- 1082
	y = 0, -- 1082
	h = 84, -- 1082
	depth = 16, -- 1082
	label = "持盾手 1100 · 中档", -- 1082
	kind = "shield", -- 1082
	drop = "shield" -- 1082
}}}} -- 1082
--- S1 十字街：同一个街口先教单方向火器，再让破障手从街角压近。
-- 外檐线与布行线都从这里的出口分叉；井背是退回点，窗台是可选的翻窗捷径。
____exports.S1_CROSSROAD = { -- 1091
	key = "s1-crossroad", -- 1092
	name = "S1 · 十字街", -- 1093
	caption = "井背 → 摊后窄道 → 观察转角 → 街角压近者。薄木挡与窗台分别通向 S2 的两条线。", -- 1094
	originX = 0, -- 1095
	minX = 0, -- 1096
	maxX = 1600, -- 1097
	height = 220, -- 1098
	depth = LANE_ROAD, -- 1099
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 1100
	solids = { -- 1101
		{ -- 1102
			x = 180, -- 1102
			w = 88, -- 1102
			h = 56, -- 1102
			y = 0, -- 1102
			label = "井背 180–268 · 高 56", -- 1102
			lanes = {"lower"}, -- 1102
			art = "cover_stone", -- 1102
			id = "s1_well" -- 1102
		}, -- 1102
		{ -- 1103
			x = 360, -- 1103
			w = 160, -- 1103
			h = 44, -- 1103
			y = 0, -- 1103
			label = "摊后柜台 360–520 · 高 44", -- 1103
			lanes = {"lower", "middle"}, -- 1103
			art = "cover_wood" -- 1103
		}, -- 1103
		{ -- 1104
			x = 620, -- 1104
			w = 44, -- 1104
			h = 24, -- 1104
			y = 0, -- 1104
			label = "观察转角石基 620–664 · 高 24", -- 1104
			lanes = {"lower"}, -- 1104
			art = "cover_stone" -- 1104
		}, -- 1104
		{ -- 1105
			x = 1130, -- 1105
			w = 20, -- 1105
			h = 120, -- 1105
			y = 0, -- 1105
			label = "窗柱左", -- 1105
			lanes = {"upper"}, -- 1105
			art = "wall" -- 1105
		}, -- 1105
		{ -- 1106
			x = 1150, -- 1106
			w = 80, -- 1106
			h = 44, -- 1106
			y = 0, -- 1106
			label = "窗台 1150–1230 · 高 44", -- 1106
			lanes = {"upper"}, -- 1106
			art = "cover_wood" -- 1106
		}, -- 1106
		{ -- 1107
			x = 1230, -- 1107
			w = 20, -- 1107
			h = 120, -- 1107
			y = 0, -- 1107
			label = "窗柱右", -- 1107
			lanes = {"upper"}, -- 1107
			art = "wall" -- 1107
		}, -- 1107
		{ -- 1108
			x = 1460, -- 1108
			w = 40, -- 1108
			h = 140, -- 1108
			y = 0, -- 1108
			label = "街尾门柱", -- 1108
			lanes = {"lower", "upper"}, -- 1108
			art = "gate_post" -- 1108
		} -- 1108
	}, -- 1108
	zones = {{ -- 1110
		x0 = 700, -- 1110
		x1 = 960, -- 1110
		y = 0, -- 1110
		h = 150, -- 1110
		tint = 1, -- 1110
		label = "街角交火 700–960" -- 1110
	}}, -- 1110
	arch = { -- 1111
		x0 = 0, -- 1111
		x1 = 0, -- 1111
		y = 0, -- 1111
		h = 0, -- 1111
		label = "" -- 1111
	}, -- 1111
	stairs = {{ -- 1112
		x0 = 900, -- 1112
		x1 = 1040, -- 1112
		y0 = 0, -- 1112
		y1 = 40, -- 1112
		steps = 4, -- 1112
		label = "石基斜走 900–1040 · 高 40", -- 1112
		lanes = {"lower", "middle"} -- 1112
	}}, -- 1112
	cart = NO_CART, -- 1113
	spawns = {{ -- 1114
		x = 760, -- 1115
		y = 0, -- 1115
		h = 84, -- 1115
		depth = 32, -- 1115
		label = "单方向火器手 760", -- 1115
		kind = "gunner", -- 1115
		drop = "ammo" -- 1115
	}, { -- 1115
		x = 880, -- 1116
		y = 0, -- 1116
		h = 84, -- 1116
		label = "街角压近者 880", -- 1116
		kind = "breaker", -- 1116
		drop = "wedge" -- 1116
	}}, -- 1116
	marks = {{x = 220, y = 0, kind = 1, label = "井背安全点 220"}, {x = 640, y = 0, kind = 0, label = "观察转角 640"}, {x = 1190, y = 0, kind = 0, label = "窗台捷径 1190"}, {x = 1500, y = 0, kind = 0, label = "出口 1500"}}, -- 1118
	dims = {{x0 = 180, x1 = 268, text = "井 88"}, {x0 = 360, x1 = 520, text = "柜台 160"}, {x0 = 900, x1 = 1040, text = "石基 140"}}, -- 1124
	companion = {waitX = 220, waitDepth = -32, joinX = 900}, -- 1129
	campaign = { -- 1130
		chapter = "S", -- 1130
		act = 1, -- 1130
		budget = 210, -- 1130
		goal = "reach_exit", -- 1130
		next = "s2-drygoods", -- 1130
		exitX = 1500, -- 1130
		checkpoint = 1 -- 1130
	} -- 1130
} -- 1130
--- S2 布行与外檐：近檐柱下短跨、可碎摊挡与转角装卸面是一条线；
-- 从染布架侧面进布行、绕柜到窗板背后放板、后仓折回是另一条线。两条线同通牌楼。
____exports.S2_DRYGOODS = { -- 1137
	key = "s2-drygoods", -- 1138
	name = "S2 · 布行与外檐", -- 1139
	caption = "近檐：檐柱短跨、薄木摊挡、装卸面。远帘：染布架入内、绕柜、放窗板、后仓折回。两路同通牌楼。", -- 1140
	originX = 1600, -- 1141
	minX = 0, -- 1142
	maxX = 1800, -- 1143
	height = 230, -- 1144
	depth = LANE_ROAD, -- 1145
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 1146
	pickups = {{ -- 1147
		id = "s2_scrap_1", -- 1148
		kind = "scrap", -- 1148
		x = 520, -- 1148
		y = 0, -- 1148
		depth = 0, -- 1148
		label = "废木料 · 薄木摊挡脚下" -- 1148
	}, { -- 1148
		id = "s2_scrap_2", -- 1149
		kind = "scrap", -- 1149
		x = 760, -- 1149
		y = 0, -- 1149
		depth = 0, -- 1149
		label = "废木料 · 装卸面旁" -- 1149
	}}, -- 1149
	solids = { -- 1151
		{ -- 1152
			x = 100, -- 1152
			w = 24, -- 1152
			h = 130, -- 1152
			y = 0, -- 1152
			label = "檐柱 100", -- 1152
			lanes = {"middle"}, -- 1152
			art = "cover_wood" -- 1152
		}, -- 1152
		{ -- 1153
			x = 240, -- 1153
			w = 24, -- 1153
			h = 130, -- 1153
			y = 0, -- 1153
			label = "檐柱 240", -- 1153
			lanes = {"middle"}, -- 1153
			art = "cover_wood" -- 1153
		}, -- 1153
		{ -- 1154
			x = 460, -- 1155
			w = 100, -- 1155
			h = 48, -- 1155
			y = 0, -- 1155
			label = "薄木摊挡 460–560 · 高 48", -- 1155
			lanes = {"middle", "upper"}, -- 1155
			art = "thin_wood", -- 1156
			id = "s2_wood", -- 1156
			breakable = {kind = "thin_wood", hp = 2, wedgeHp = 1} -- 1156
		}, -- 1156
		{ -- 1158
			x = 560, -- 1158
			w = 36, -- 1158
			h = 130, -- 1158
			y = 0, -- 1158
			label = "永久石柱 560–596", -- 1158
			lanes = {"upper"}, -- 1158
			art = "cover_stone" -- 1158
		}, -- 1158
		{ -- 1159
			x = 700, -- 1159
			w = 120, -- 1159
			h = 32, -- 1159
			y = 0, -- 1159
			label = "转角装卸面 700–820 · 高 32", -- 1159
			lanes = {"middle"}, -- 1159
			art = "cover_stone" -- 1159
		}, -- 1159
		{ -- 1160
			x = 340, -- 1160
			w = 120, -- 1160
			h = 44, -- 1160
			y = 0, -- 1160
			label = "布行柜台 340–460 · 高 44", -- 1160
			lanes = {"upper"}, -- 1160
			art = "cover_wood" -- 1160
		}, -- 1160
		{ -- 1161
			x = 600, -- 1162
			w = 80, -- 1162
			h = 72, -- 1162
			y = 0, -- 1162
			label = "窗板背后 600–680", -- 1162
			lanes = {"upper"}, -- 1162
			art = "board", -- 1163
			id = "s2_board", -- 1163
			interact = {kind = "open_board", reach = 46} -- 1163
		}, -- 1163
		{ -- 1165
			x = 600, -- 1166
			w = 80, -- 1166
			h = 40, -- 1166
			y = 0, -- 1166
			label = "放下的窗板 600–680", -- 1166
			lanes = {"lower"}, -- 1166
			art = "board", -- 1167
			id = "s2_board_cover", -- 1167
			soft = true, -- 1167
			hidden = true -- 1167
		}, -- 1167
		{ -- 1169
			x = 1560, -- 1169
			w = 30, -- 1169
			h = 150, -- 1169
			y = 0, -- 1169
			label = "牌楼左柱", -- 1169
			lanes = {"lower", "upper"}, -- 1169
			art = "gate_post" -- 1169
		}, -- 1169
		{ -- 1170
			x = 1700, -- 1170
			w = 30, -- 1170
			h = 150, -- 1170
			y = 0, -- 1170
			label = "牌楼右柱", -- 1170
			lanes = {"lower", "upper"}, -- 1170
			art = "gate_post" -- 1170
		} -- 1170
	}, -- 1170
	zones = {{ -- 1172
		x0 = 640, -- 1172
		x1 = 1300, -- 1172
		y = 0, -- 1172
		h = 150, -- 1172
		tint = 1, -- 1172
		label = "转角装卸面交火 700–1200" -- 1172
	}}, -- 1172
	arch = { -- 1173
		x0 = 0, -- 1173
		x1 = 0, -- 1173
		y = 0, -- 1173
		h = 0, -- 1173
		label = "" -- 1173
	}, -- 1173
	stairs = {}, -- 1174
	cart = NO_CART, -- 1175
	spawns = {{ -- 1176
		x = 940, -- 1177
		y = 0, -- 1177
		h = 84, -- 1177
		depth = 0, -- 1177
		label = "持盾手 940", -- 1177
		kind = "shield", -- 1177
		shieldHp = 2, -- 1177
		drop = "shield" -- 1177
	}, { -- 1177
		x = 1060, -- 1178
		y = 0, -- 1178
		h = 84, -- 1178
		depth = 32, -- 1178
		label = "远侧火器手 1060", -- 1178
		kind = "gunner", -- 1178
		drop = "ammo" -- 1178
	}, { -- 1178
		x = 1140, -- 1179
		y = 0, -- 1179
		h = 84, -- 1179
		depth = 0, -- 1179
		label = "破障手 1140", -- 1179
		kind = "breaker", -- 1179
		drop = "wedge" -- 1179
	}}, -- 1179
	marks = {{x = 640, y = 0, kind = 1, label = "窗板后等待位 640"}, {x = 900, y = 0, kind = 0, label = "后仓汇合口 900"}, {x = 1740, y = 0, kind = 0, label = "牌楼出口 1740"}}, -- 1181
	dims = {{x0 = 100, x1 = 124, text = "檐柱 24"}, {x0 = 460, x1 = 560, text = "摊挡 100"}, {x0 = 700, x1 = 820, text = "装卸面 120"}}, -- 1186
	companion = {waitX = 640, waitDepth = 32, joinX = 900, followAfter = "open_board"}, -- 1191
	campaign = { -- 1192
		chapter = "S", -- 1192
		act = 2, -- 1192
		budget = 390, -- 1192
		goal = "reach_exit", -- 1192
		next = "s3-archway", -- 1192
		exitX = 1740, -- 1192
		checkpoint = 2 -- 1192
	} -- 1192
} -- 1192
--- S3 牌楼后巷：外檐线从低处进、布行线从高处进，两条入口在墙脚汇合。
-- 装卸坡可先上去看同一堆粮袋的敌位，再退半层接小满；也可以沿墙脚直接绕。
____exports.S3_ARCHWAY = { -- 1199
	key = "s3-archway", -- 1200
	name = "S3 · 牌楼后巷", -- 1201
	caption = "两高度入口看同一粮袋。登装卸坡看敌位再退半层接人，或沿墙脚绕走；候检门前两人停。", -- 1202
	originX = 3400, -- 1203
	minX = 0, -- 1204
	maxX = 1400, -- 1205
	height = 230, -- 1206
	depth = LANE_ROAD, -- 1207
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 1208
	solids = { -- 1209
		{ -- 1210
			x = 0, -- 1210
			w = 180, -- 1210
			h = 32, -- 1210
			y = 0, -- 1210
			label = "高处进口台 0–180 · 高 32", -- 1210
			lanes = {"upper"}, -- 1210
			art = "cover_stone" -- 1210
		}, -- 1210
		{ -- 1211
			x = 380, -- 1211
			w = 140, -- 1211
			h = 64, -- 1211
			y = 0, -- 1211
			label = "装卸高台 380–520 · 高 64", -- 1211
			lanes = {"upper"}, -- 1211
			art = "cover_wood" -- 1211
		}, -- 1211
		{ -- 1212
			x = 560, -- 1212
			w = 160, -- 1212
			h = 48, -- 1212
			y = 0, -- 1212
			label = "粮袋堆 560–720 · 高 48", -- 1212
			lanes = {"lower", "middle"}, -- 1212
			art = "grain_sack" -- 1212
		}, -- 1212
		{ -- 1213
			x = 1260, -- 1213
			w = 30, -- 1213
			h = 140, -- 1213
			y = 0, -- 1213
			label = "候检门左柱", -- 1213
			lanes = {"lower", "upper"}, -- 1213
			art = "gate_post" -- 1213
		}, -- 1213
		{ -- 1214
			x = 1330, -- 1214
			w = 30, -- 1214
			h = 140, -- 1214
			y = 0, -- 1214
			label = "候检门右柱", -- 1214
			lanes = {"lower", "upper"}, -- 1214
			art = "gate_post" -- 1214
		} -- 1214
	}, -- 1214
	zones = {{ -- 1216
		x0 = 780, -- 1216
		x1 = 1060, -- 1216
		y = 0, -- 1216
		h = 150, -- 1216
		tint = 1, -- 1216
		label = "后巷交火 780–1060" -- 1216
	}}, -- 1216
	arch = { -- 1217
		x0 = 0, -- 1217
		x1 = 0, -- 1217
		y = 0, -- 1217
		h = 0, -- 1217
		label = "" -- 1217
	}, -- 1217
	stairs = {{ -- 1218
		x0 = 140, -- 1219
		x1 = 200, -- 1219
		y0 = 0, -- 1219
		y1 = 32, -- 1219
		steps = 3, -- 1219
		label = "进口台阶", -- 1219
		lanes = {"upper"} -- 1219
	}, { -- 1219
		x0 = 260, -- 1220
		x1 = 380, -- 1220
		y0 = 0, -- 1220
		y1 = 64, -- 1220
		steps = 4, -- 1220
		label = "装卸坡 260–380 · 高 64", -- 1220
		lanes = {"upper"} -- 1220
	}}, -- 1220
	cart = NO_CART, -- 1222
	spawns = {{ -- 1223
		x = 860, -- 1224
		y = 0, -- 1224
		h = 84, -- 1224
		depth = 32, -- 1224
		label = "高处火器手 860", -- 1224
		kind = "gunner", -- 1224
		drop = "ammo" -- 1224
	}, { -- 1224
		x = 980, -- 1225
		y = 0, -- 1225
		h = 84, -- 1225
		depth = 0, -- 1225
		label = "墙脚火器手 980", -- 1225
		kind = "gunner", -- 1225
		drop = "ammo" -- 1225
	}}, -- 1225
	marks = {{x = 440, y = 0, kind = 0, label = "装卸坡观察位 440"}, {x = 620, y = 0, kind = 1, label = "粮袋后安全点 620"}, {x = 1300, y = 0, kind = 0, label = "候检门前 1300"}}, -- 1227
	dims = {{x0 = 260, x1 = 380, text = "装卸坡 120"}, {x0 = 560, x1 = 720, text = "粮袋 160"}}, -- 1232
	companion = {waitX = 620, waitDepth = 0, joinX = 1240}, -- 1233
	campaign = { -- 1234
		chapter = "S", -- 1234
		act = 3, -- 1234
		budget = 180, -- 1234
		goal = "reach_exit", -- 1234
		next = "c1-yard", -- 1234
		exitX = 1320, -- 1234
		checkpoint = 3 -- 1234
	} -- 1234
} -- 1234
--- C1 候检院：侧门横闩在门背，粮棚可见但被队栏、查验台与棚柱交错挡住。
-- 绕缺口进栏，截断压近者或穿查验台后到棚口；正面看门，转到背面才抬得动闩。
____exports.C1_YARD = { -- 1241
	key = "c1-yard", -- 1242
	name = "C1 · 候检院", -- 1243
	caption = "队栏与查验台把粮棚切成几段。绕缺口进栏，压近者会截断通路；侧门横闩要转到门背才抬得动。", -- 1244
	originX = 4800, -- 1245
	minX = 0, -- 1246
	maxX = 1900, -- 1247
	height = 240, -- 1248
	depth = LANE_ROAD, -- 1249
	floors = {{y = 0, x0 = 0, x1 = 1900}}, -- 1250
	solids = { -- 1251
		{ -- 1252
			x = 280, -- 1252
			w = 340, -- 1252
			h = 28, -- 1252
			y = 0, -- 1252
			label = "候检队栏 280–620 · 高 28", -- 1252
			lanes = {"lower", "middle"}, -- 1252
			art = "fence" -- 1252
		}, -- 1252
		{ -- 1253
			x = 820, -- 1253
			w = 180, -- 1253
			h = 44, -- 1253
			y = 0, -- 1253
			label = "查验台 820–1000 · 高 44", -- 1253
			lanes = {"lower", "middle"}, -- 1253
			art = "cover_wood" -- 1253
		}, -- 1253
		{ -- 1254
			x = 1100, -- 1254
			w = 40, -- 1254
			h = 150, -- 1254
			y = 0, -- 1254
			label = "棚柱 1100–1140", -- 1254
			lanes = {"lower", "middle"}, -- 1254
			art = "cover_wood" -- 1254
		}, -- 1254
		{ -- 1255
			x = 1240, -- 1255
			w = 40, -- 1255
			h = 150, -- 1255
			y = 0, -- 1255
			label = "棚柱 1240–1280", -- 1255
			lanes = {"lower", "middle"}, -- 1255
			art = "cover_wood" -- 1255
		}, -- 1255
		{ -- 1256
			x = 1600, -- 1256
			w = 160, -- 1256
			h = 48, -- 1256
			y = 0, -- 1256
			label = "粮棚袋堆 1600–1760 · 高 48", -- 1256
			lanes = {"lower", "middle"}, -- 1256
			art = "grain_sack" -- 1256
		}, -- 1256
		{ -- 1257
			x = 1780, -- 1257
			w = 50, -- 1257
			h = 150, -- 1257
			y = 0, -- 1257
			label = "侧门 1780–1830", -- 1257
			depth = LANE_ROAD, -- 1257
			art = "wall", -- 1257
			id = "c1_door" -- 1257
		}, -- 1257
		{ -- 1258
			x = 1755, -- 1259
			w = 30, -- 1259
			h = 24, -- 1259
			y = 40, -- 1259
			label = "侧门横闩（门框上侧）", -- 1259
			lanes = {"upper"}, -- 1259
			art = "latch", -- 1260
			id = "c1_latch", -- 1260
			interact = {kind = "raise_latch", reach = 56} -- 1260
		} -- 1260
	}, -- 1260
	zones = {{ -- 1263
		x0 = 760, -- 1263
		x1 = 1080, -- 1263
		y = 0, -- 1263
		h = 150, -- 1263
		tint = 1, -- 1263
		label = "查验台截断 820–1000" -- 1263
	}}, -- 1263
	arch = { -- 1264
		x0 = 0, -- 1264
		x1 = 0, -- 1264
		y = 0, -- 1264
		h = 0, -- 1264
		label = "" -- 1264
	}, -- 1264
	stairs = {}, -- 1265
	cart = NO_CART, -- 1266
	spawns = {{ -- 1267
		x = 900, -- 1268
		y = 0, -- 1268
		h = 84, -- 1268
		depth = 0, -- 1268
		label = "截断压近者 900", -- 1268
		kind = "breaker", -- 1268
		drop = "wedge" -- 1268
	}, { -- 1268
		x = 1200, -- 1269
		y = 0, -- 1269
		h = 84, -- 1269
		depth = 32, -- 1269
		label = "棚柱后火器手 1200", -- 1269
		kind = "gunner", -- 1269
		drop = "ammo" -- 1269
	}}, -- 1269
	marks = {{x = 1000, y = 0, kind = 1, label = "查验台后等待位 1000"}, {x = 1700, y = 0, kind = 0, label = "侧门正面 1700"}, {x = 1860, y = 0, kind = 0, label = "门背出口 1860"}}, -- 1271
	dims = {{x0 = 820, x1 = 1000, text = "查验台 180"}, {x0 = 1780, x1 = 1830, text = "侧门 50"}}, -- 1276
	companion = {waitX = 1000, waitDepth = 0, joinX = 1700, followAfter = "raise_latch"}, -- 1277
	campaign = { -- 1278
		chapter = "C", -- 1278
		act = 1, -- 1278
		budget = 270, -- 1278
		goal = "raise_latch", -- 1278
		next = "c2-granary", -- 1278
		exitX = 1860, -- 1278
		checkpoint = 4 -- 1278
	} -- 1278
} -- 1278
--- C2 军粮棚：粮袋安全区居中，远柱木帘与近侧车轨分列。
-- 有残盾可以在暴露轨段架起来挡一发；空手路线先绕上远柱放帘，再回来握车柄。
____exports.C2_GRANARY = { -- 1285
	key = "c2-granary", -- 1286
	name = "C2 · 军粮棚", -- 1287
	caption = "空筐围挡、暴露轨段与远柱木帘。先绕上远柱放帘，或架残盾，再握车柄把车推入轮窝并抬连杆闩。", -- 1288
	originX = 6700, -- 1289
	minX = 0, -- 1290
	maxX = 1800, -- 1291
	height = 240, -- 1292
	depth = LANE_ROAD, -- 1293
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 1294
	solids = { -- 1295
		{ -- 1296
			x = 900, -- 1297
			w = 76, -- 1297
			h = 44, -- 1297
			y = 0, -- 1297
			label = "空筐围挡 900–976 · 高 44", -- 1297
			lanes = {"lower", "middle"}, -- 1297
			art = "basket_wall", -- 1298
			id = "c2_basket", -- 1298
			breakable = {kind = "basket_wall", hp = 2, wedgeable = false} -- 1298
		}, -- 1298
		{ -- 1300
			x = 600, -- 1300
			w = 300, -- 1300
			h = 48, -- 1300
			y = 0, -- 1300
			label = "粮袋安全区 600–900 · 高 48", -- 1300
			lanes = {"lower", "middle"}, -- 1300
			art = "grain_sack" -- 1300
		}, -- 1300
		{ -- 1301
			x = 980, -- 1301
			w = 40, -- 1301
			h = 24, -- 1301
			y = 0, -- 1301
			label = "棚口下轨台 980–1020 · 高 24", -- 1301
			lanes = {"lower", "middle"}, -- 1301
			art = "cover_stone" -- 1301
		}, -- 1301
		{ -- 1302
			x = 1200, -- 1303
			w = 40, -- 1303
			h = 150, -- 1303
			y = 0, -- 1303
			label = "远柱 1200–1240 · 高 150", -- 1303
			lanes = {"upper"}, -- 1303
			art = "cover_wood", -- 1304
			id = "c2_post", -- 1304
			interact = {kind = "lower_curtain", reach = 46} -- 1304
		}, -- 1304
		{ -- 1306
			x = 1240, -- 1307
			w = 120, -- 1307
			h = 120, -- 1307
			y = 24, -- 1307
			label = "木帘落点 1240–1360", -- 1307
			lanes = {"lower", "middle"}, -- 1307
			art = "curtain", -- 1308
			soft = true, -- 1308
			id = "c2_curtain", -- 1308
			hidden = true -- 1308
		}, -- 1308
		{ -- 1310
			x = 1560, -- 1311
			w = 30, -- 1311
			h = 24, -- 1311
			y = 40, -- 1311
			label = "连杆抬闩 1560–1590", -- 1311
			lanes = {"middle"}, -- 1311
			art = "latch", -- 1312
			id = "c2_latch", -- 1312
			interact = {kind = "raise_latch", reach = 50} -- 1312
		}, -- 1312
		{ -- 1314
			x = 1720, -- 1314
			w = 30, -- 1314
			h = 150, -- 1314
			y = 0, -- 1314
			label = "棚尾门柱", -- 1314
			lanes = {"lower", "upper"}, -- 1314
			art = "gate_post" -- 1314
		} -- 1314
	}, -- 1314
	zones = {{ -- 1316
		x0 = 1000, -- 1316
		x1 = 1200, -- 1316
		y = 0, -- 1316
		h = 150, -- 1316
		tint = 1, -- 1316
		label = "暴露轨段 1000–1200" -- 1316
	}}, -- 1316
	arch = { -- 1317
		x0 = 0, -- 1317
		x1 = 0, -- 1317
		y = 0, -- 1317
		h = 0, -- 1317
		label = "" -- 1317
	}, -- 1317
	stairs = {}, -- 1318
	cart = { -- 1319
		startX = 1150, -- 1320
		endX = 1500, -- 1320
		baseY = 0, -- 1320
		depth = 0, -- 1320
		bodyW = 48, -- 1320
		bodyH = 26, -- 1320
		wheelR = 12, -- 1320
		handleOffset = -50, -- 1320
		clothSide = -1 -- 1320
	}, -- 1320
	spawns = {{ -- 1322
		x = 1580, -- 1323
		y = 0, -- 1323
		h = 84, -- 1323
		depth = 0, -- 1323
		label = "棚尾火器手 1580", -- 1323
		kind = "gunner", -- 1323
		drop = "ammo" -- 1323
	}, { -- 1323
		x = 1340, -- 1324
		y = 0, -- 1324
		h = 84, -- 1324
		depth = 32, -- 1324
		label = "远侧持盾手 1340", -- 1324
		kind = "shield", -- 1324
		shieldHp = 2, -- 1324
		drop = "shield" -- 1324
	}}, -- 1324
	marks = {{x = 760, y = 0, kind = 1, label = "袋堆后等待位 760"}, {x = 1100, y = 0, kind = 0, label = "车柄 1100"}, {x = 1500, y = 0, kind = 0, label = "轮窝 1500"}, {x = 1700, y = 0, kind = 0, label = "棚尾出口 1700"}}, -- 1326
	dims = {{x0 = 1150, x1 = 1500, text = "推车 350"}, {x0 = 1240, x1 = 1360, text = "木帘 120"}}, -- 1332
	companion = {waitX = 760, waitDepth = 0, joinX = 1700}, -- 1333
	campaign = { -- 1334
		chapter = "C", -- 1334
		act = 2, -- 1334
		budget = 360, -- 1334
		goal = "dock_cart", -- 1334
		exitX = 1700, -- 1334
		checkpoint = 5 -- 1334
	} -- 1334
} -- 1334
____exports.CAMPAIGN_ROOMS = { -- 1337
	____exports.S1_CROSSROAD, -- 1337
	____exports.S2_DRYGOODS, -- 1337
	____exports.S3_ARCHWAY, -- 1337
	____exports.C1_YARD, -- 1337
	____exports.C2_GRANARY -- 1337
} -- 1337
____exports.ROOMS = { -- 1345
	____exports.PROLOGUE_ROOM, -- 1345
	____exports.STREET_ROOM, -- 1345
	____exports.S1_CROSSROAD, -- 1345
	____exports.S2_DRYGOODS, -- 1345
	____exports.S3_ARCHWAY, -- 1345
	____exports.C1_YARD, -- 1345
	____exports.C2_GRANARY, -- 1345
	____exports.CHECKPOINT_ROOM, -- 1345
	____exports.GATE_ROOM, -- 1345
	____exports.GATE_PATH_ROOM, -- 1345
	____exports.ESCORT1_ROOM, -- 1345
	____exports.ESCORT2_ROOM, -- 1345
	____exports.ESCORT3_ROOM, -- 1345
	____exports.ESCORT4_ROOM, -- 1345
	____exports.ESCORT5_ROOM, -- 1345
	____exports.OUTSIDE_ROOM, -- 1345
	____exports.VILLAGE_ROOM, -- 1345
	____exports.FOREST_ROOM, -- 1345
	____exports.TOWER_ROOM, -- 1345
	____exports.MUSEUM_ROOM -- 1345
} -- 1345
local function placeSolids(room) -- 1368
	local blocks = {} -- 1369
	for ____, solid in ipairs(room.solids) do -- 1370
		local x = solid.x + room.originX -- 1371
		if room.depth ~= nil and solid.lanes ~= nil then -- 1371
			for ____, depth in ipairs(laneFootprints(solid.lanes)) do -- 1373
				blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x, depth = depth, lanes = nil}) -- 1374
			end -- 1374
		else -- 1374
			blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x}) -- 1377
		end -- 1377
	end -- 1377
	return blocks -- 1380
end -- 1368
local function placeStairs(room) -- 1383
	local out = {} -- 1384
	for ____, stair in ipairs(room.stairs) do -- 1385
		local x0 = stair.x0 + room.originX -- 1386
		local x1 = stair.x1 + room.originX -- 1387
		if room.depth ~= nil and stair.lanes ~= nil then -- 1387
			for ____, depth in ipairs(laneFootprints(stair.lanes)) do -- 1389
				out[#out + 1] = __TS__ObjectAssign({}, stair, {x0 = x0, x1 = x1, depth = depth, lanes = nil}) -- 1390
			end -- 1390
		else -- 1390
			out[#out + 1] = __TS__ObjectAssign({}, stair, {x0 = x0, x1 = x1}) -- 1393
		end -- 1393
	end -- 1393
	return out -- 1396
end -- 1383
--- 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
-- 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
function ____exports.withOrigin(room) -- 1403
	local ox = room.originX -- 1404
	if ox == 0 then -- 1404
		return room.depth == nil and room or __TS__ObjectAssign( -- 1406
			{}, -- 1406
			room, -- 1406
			{ -- 1406
				solids = placeSolids(room), -- 1406
				stairs = placeStairs(room) -- 1406
			} -- 1406
		) -- 1406
	end -- 1406
	local function shift(x) -- 1408
		return x + ox -- 1408
	end -- 1408
	local ____room_key_12 = room.key -- 1410
	local ____room_name_13 = room.name -- 1411
	local ____room_caption_14 = room.caption -- 1412
	local ____shift_result_15 = shift(room.minX) -- 1414
	local ____shift_result_16 = shift(room.maxX) -- 1415
	local ____room_height_17 = room.height -- 1416
	local ____room_depth_18 = room.depth -- 1417
	local ____TS__ArrayMap_result_19 = __TS__ArrayMap( -- 1418
		room.floors, -- 1418
		function(____, f) return { -- 1418
			y = f.y, -- 1418
			x0 = shift(f.x0), -- 1418
			x1 = shift(f.x1) -- 1418
		} end -- 1418
	) -- 1418
	local ____placeSolids_result_20 = placeSolids(room) -- 1419
	local ____TS__ArrayMap_result_21 = __TS__ArrayMap( -- 1420
		room.zones, -- 1420
		function(____, z) return { -- 1420
			x0 = shift(z.x0), -- 1420
			x1 = shift(z.x1), -- 1420
			y = z.y, -- 1420
			h = z.h, -- 1420
			tint = z.tint, -- 1420
			label = z.label -- 1420
		} end -- 1420
	) -- 1420
	local ____temp_22 = { -- 1421
		x0 = shift(room.arch.x0), -- 1421
		x1 = shift(room.arch.x1), -- 1421
		y = room.arch.y, -- 1421
		h = room.arch.h, -- 1421
		label = room.arch.label -- 1421
	} -- 1421
	local ____placeStairs_result_23 = placeStairs(room) -- 1422
	local ____TS__ObjectAssign_result_24 = __TS__ObjectAssign( -- 1423
		{}, -- 1423
		room.cart, -- 1424
		{ -- 1423
			startX = shift(room.cart.startX), -- 1425
			endX = shift(room.cart.endX) -- 1426
		} -- 1426
	) -- 1426
	local ____TS__ArrayMap_result_25 = __TS__ArrayMap( -- 1428
		room.spawns, -- 1428
		function(____, s) return __TS__ObjectAssign( -- 1428
			{}, -- 1428
			s, -- 1428
			{x = shift(s.x)} -- 1428
		) end -- 1428
	) -- 1428
	local ____TS__ArrayMap_result_26 = __TS__ArrayMap( -- 1429
		room.marks, -- 1429
		function(____, m) return { -- 1429
			x = shift(m.x), -- 1429
			y = m.y, -- 1429
			kind = m.kind, -- 1429
			label = m.label -- 1429
		} end -- 1429
	) -- 1429
	local ____TS__ArrayMap_result_27 = __TS__ArrayMap( -- 1430
		room.dims, -- 1430
		function(____, d) return { -- 1430
			x0 = shift(d.x0), -- 1430
			x1 = shift(d.x1), -- 1430
			text = d.text -- 1430
		} end -- 1430
	) -- 1430
	local ____temp_0 -- 1431
	if room.scavenger == nil then -- 1431
		____temp_0 = nil -- 1431
	else -- 1431
		____temp_0 = { -- 1431
			x0 = shift(room.scavenger.x0), -- 1432
			x1 = shift(room.scavenger.x1), -- 1432
			y = room.scavenger.y, -- 1432
			h = room.scavenger.h, -- 1432
			patrolSpeed = room.scavenger.patrolSpeed, -- 1433
			approachSpeed = room.scavenger.approachSpeed, -- 1433
			hearTicks = room.scavenger.hearTicks, -- 1434
			stallTicks = room.scavenger.stallTicks, -- 1434
			range = room.scavenger.range -- 1434
		} -- 1434
	end -- 1434
	local ____temp_1 -- 1436
	if room.bottle == nil then -- 1436
		____temp_1 = nil -- 1436
	else -- 1436
		____temp_1 = { -- 1436
			x = shift(room.bottle.x), -- 1436
			y = room.bottle.y -- 1436
		} -- 1436
	end -- 1436
	local ____temp_2 -- 1437
	if room.brickX == nil then -- 1437
		____temp_2 = nil -- 1437
	else -- 1437
		____temp_2 = shift(room.brickX) -- 1437
	end -- 1437
	local ____temp_3 -- 1438
	if room.basinX == nil then -- 1438
		____temp_3 = nil -- 1438
	else -- 1438
		____temp_3 = shift(room.basinX) -- 1438
	end -- 1438
	local ____temp_4 -- 1439
	if room.softX == nil then -- 1439
		____temp_4 = nil -- 1439
	else -- 1439
		____temp_4 = shift(room.softX) -- 1439
	end -- 1439
	local ____temp_5 -- 1440
	if room.passLine == nil then -- 1440
		____temp_5 = nil -- 1440
	else -- 1440
		____temp_5 = shift(room.passLine) -- 1440
	end -- 1440
	local ____temp_6 -- 1441
	if room.campaign == nil then -- 1441
		____temp_6 = nil -- 1441
	else -- 1441
		____temp_6 = __TS__ObjectAssign( -- 1441
			{}, -- 1441
			room.campaign, -- 1441
			{exitX = shift(room.campaign.exitX)} -- 1441
		) -- 1441
	end -- 1441
	local ____temp_7 -- 1442
	if room.pickups == nil then -- 1442
		____temp_7 = nil -- 1442
	else -- 1442
		____temp_7 = __TS__ArrayMap( -- 1442
			room.pickups, -- 1442
			function(____, p) return __TS__ObjectAssign( -- 1442
				{}, -- 1442
				p, -- 1442
				{x = shift(p.x)} -- 1442
			) end -- 1442
		) -- 1442
	end -- 1442
	local ____temp_11 -- 1443
	if room.companion == nil then -- 1443
		____temp_11 = nil -- 1443
	else -- 1443
		local ____room_companion_10 = room.companion -- 1444
		local ____temp_8 -- 1445
		if room.companion.waitX == nil then -- 1445
			____temp_8 = nil -- 1445
		else -- 1445
			____temp_8 = shift(room.companion.waitX) -- 1445
		end -- 1445
		local ____temp_9 -- 1446
		if room.companion.joinX == nil then -- 1446
			____temp_9 = nil -- 1446
		else -- 1446
			____temp_9 = shift(room.companion.joinX) -- 1446
		end -- 1446
		____temp_11 = __TS__ObjectAssign({}, ____room_companion_10, {waitX = ____temp_8, joinX = ____temp_9}) -- 1443
	end -- 1443
	return { -- 1409
		key = ____room_key_12, -- 1410
		name = ____room_name_13, -- 1411
		caption = ____room_caption_14, -- 1412
		originX = 0, -- 1413
		minX = ____shift_result_15, -- 1414
		maxX = ____shift_result_16, -- 1415
		height = ____room_height_17, -- 1416
		depth = ____room_depth_18, -- 1417
		floors = ____TS__ArrayMap_result_19, -- 1418
		solids = ____placeSolids_result_20, -- 1419
		zones = ____TS__ArrayMap_result_21, -- 1420
		arch = ____temp_22, -- 1421
		stairs = ____placeStairs_result_23, -- 1422
		cart = ____TS__ObjectAssign_result_24, -- 1423
		spawns = ____TS__ArrayMap_result_25, -- 1428
		marks = ____TS__ArrayMap_result_26, -- 1429
		dims = ____TS__ArrayMap_result_27, -- 1430
		scavenger = ____temp_0, -- 1431
		bottle = ____temp_1, -- 1436
		brickX = ____temp_2, -- 1437
		basinX = ____temp_3, -- 1438
		softX = ____temp_4, -- 1439
		passLine = ____temp_5, -- 1440
		campaign = ____temp_6, -- 1441
		pickups = ____temp_7, -- 1442
		companion = ____temp_11, -- 1443
		story = shiftStory(room.story, ox) -- 1448
	} -- 1448
end -- 1403
return ____exports -- 1403