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
____exports.CHECKPOINT_ROOM = { -- 279
	key = "checkpoint", -- 280
	name = "检查站 · 候检区 640 + 原段 1000", -- 281
	caption = "先翻过队栏进候检区，再带小满走到柜台与安全点；末段按住 E + D 推车 128 单位入窝", -- 282
	originX = 640, -- 284
	minX = -640, -- 285
	maxX = 1000, -- 286
	height = 210, -- 287
	depth = LANE_ROAD, -- 288
	floors = {{y = 0, x0 = -640, x1 = 1000}}, -- 289
	solids = {{ -- 290
		x = -430, -- 292
		w = 180, -- 292
		h = 28, -- 292
		y = 0, -- 292
		label = "队栏 -430–-250 · 高 28", -- 292
		lanes = {"lower", "middle"}, -- 292
		art = "fence" -- 292
	}, { -- 292
		x = 240, -- 294
		w = 100, -- 294
		h = 44, -- 294
		y = 0, -- 294
		label = "柜台 240–340 · 高 44", -- 294
		lanes = {"lower", "middle"}, -- 294
		art = "cover_wood" -- 294
	}, { -- 294
		x = 890, -- 295
		w = 36, -- 295
		h = 122, -- 295
		y = 0, -- 295
		label = "检查站出口门柱", -- 295
		lanes = {"lower", "upper"}, -- 295
		art = "gate_post" -- 295
	}}, -- 295
	zones = {{ -- 297
		x0 = 380, -- 297
		x1 = 560, -- 297
		y = 0, -- 297
		h = 120, -- 297
		tint = 1, -- 297
		label = "危险段 380–560" -- 297
	}}, -- 297
	arch = { -- 298
		x0 = 0, -- 298
		x1 = 0, -- 298
		y = 0, -- 298
		h = 0, -- 298
		label = "" -- 298
	}, -- 298
	stairs = {}, -- 299
	cart = { -- 300
		startX = 640, -- 301
		endX = 768, -- 302
		baseY = 0, -- 303
		depth = LANE_DEPTH.middle, -- 304
		bodyW = 48, -- 305
		bodyH = 26, -- 306
		wheelR = 12, -- 307
		handleOffset = -40, -- 308
		clothSide = -1 -- 309
	}, -- 309
	spawns = {{x = -600, y = 0, h = 56, label = "小满 -600（世界 40）"}, {x = -560, y = 0, h = 88, label = "周戍 -560（世界 80）"}}, -- 311
	marks = {{x = 264, y = 0, kind = 1, label = "安全锚 264"}, {x = 768, y = 0, kind = 1, label = "dock 768"}, {x = 860, y = 0, kind = 2, label = "双人出口 792–928"}}, -- 315
	dims = {{x0 = 240, x1 = 340, text = "柜台 100"}, {x0 = 640, x1 = 768, text = "推车 128 · 左柄 E+D"}, {x0 = 792, x1 = 928, text = "出口 136"}} -- 320
} -- 320
--- 城外：同一剖面里同时看上层手柄与下层拱口，这是 D1 要交的那张图。
____exports.OUTSIDE_ROOM = { -- 328
	key = "outside", -- 329
	name = "城外 · 台面 y=96 / 墙根 1240", -- 330
	caption = "走到红布车右侧，按住 E+D 拉车入窝。回左边下石阶，按住 Ctrl 蹲过矮拱，再沿墙根去找塔灯。", -- 331
	originX = 0, -- 333
	minX = 0, -- 334
	maxX = 1240, -- 335
	height = 230, -- 336
	depth = LANE_ROAD, -- 337
	floors = {{y = 0, x0 = 0, x1 = 1240}, {y = 96, x0 = 128, x1 = 512}, {y = 64, x0 = 820, x1 = 940}}, -- 338
	solids = {{ -- 343
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
	dims = {{x0 = 304, x1 = 432, text = "红布车入窝 · 右柄 E+D"}, {x0 = 128, x1 = 512, text = "台面 384"}, {x0 = 280, x1 = 360, text = "拱 80"}, {x0 = 600, x1 = 1240, text = "墙根 640"}} -- 373
} -- 373
--- 村口：瓶架 112、观察位 160、桌下 304–416（净高 44）、第一院通行线 440、
-- 软土 272（D5 完整）、砖地 608、拾荒者巡逻 464–512。
-- 小满脚底中心 290 起必须蹲，超过 430 才站起；160→440 约 2.63 秒。
____exports.VILLAGE_ROOM = { -- 386
	key = "village", -- 387
	originX = 0, -- 388
	name = "村口 · 架、桌、砖地", -- 389
	caption = "点 E 拾瓶，按住 F 瞄，松手投；砖地一响，拾荒者转身，趁他走开钻过桌下", -- 390
	minX = 0, -- 391
	maxX = 720, -- 392
	height = 200, -- 393
	depth = LANE_ROAD, -- 394
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 395
	solids = {{ -- 396
		x = 96, -- 397
		w = 32, -- 397
		h = 52, -- 397
		y = 0, -- 397
		depth = LANE_ROAD, -- 397
		label = "瓶架", -- 397
		art = "cover_wood" -- 397
	}, { -- 397
		x = 672, -- 399
		w = 48, -- 399
		h = 96, -- 399
		y = 0, -- 399
		depth = LANE_ROAD, -- 399
		label = "院墙" -- 399
	}}, -- 399
	zones = { -- 401
		{ -- 402
			x0 = 256, -- 402
			x1 = 288, -- 402
			y = 0, -- 402
			h = 6, -- 402
			tint = 2, -- 402
			label = "软土 272" -- 402
		}, -- 402
		{ -- 403
			x0 = 440, -- 403
			x1 = 448, -- 403
			y = 0, -- 403
			h = 120, -- 403
			tint = 4, -- 403
			label = "通行线 440" -- 403
		}, -- 403
		{ -- 404
			x0 = 532, -- 404
			x1 = 564, -- 404
			y = 0, -- 404
			h = 6, -- 404
			tint = 4, -- 404
			label = "铁盆 548" -- 404
		}, -- 404
		{ -- 405
			x0 = 592, -- 405
			x1 = 624, -- 405
			y = 0, -- 405
			h = 6, -- 405
			tint = 3, -- 405
			label = "砖地 608" -- 405
		}, -- 405
		{ -- 406
			x0 = 560, -- 406
			x1 = 640, -- 406
			y = 0, -- 406
			h = 6, -- 406
			tint = 1, -- 406
			label = "暗渠口 560–640 · 蹲下钻" -- 406
		} -- 406
	}, -- 406
	arch = { -- 408
		x0 = 304, -- 408
		x1 = 416, -- 408
		y = 0, -- 408
		h = 44, -- 408
		label = "桌下 304–416 · 净高 44" -- 408
	}, -- 408
	stairs = {}, -- 409
	cart = { -- 410
		startX = 0, -- 410
		endX = 0, -- 410
		baseY = 0, -- 410
		bodyW = 0, -- 410
		bodyH = 0, -- 410
		wheelR = 0, -- 410
		handleOffset = 0, -- 410
		clothSide = 1 -- 410
	}, -- 410
	spawns = {{x = 160, y = 0, h = 56, label = "小满 160"}}, -- 411
	marks = {{x = 548, y = 0, kind = 5, label = "铁盆落点 548"}, {x = 608, y = 0, kind = 5, label = "砖地落点 608"}, {x = 440, y = 0, kind = 4, label = "通行线 440"}, {x = 600, y = 0, kind = 1, label = "暗渠口 600"}}, -- 412
	dims = {{x0 = 96, x1 = 128, text = "瓶架"}, {x0 = 304, x1 = 416, text = "桌下 112"}, {x0 = 464, x1 = 512, text = "巡逻 48"}, {x0 = 560, x1 = 640, text = "暗渠 80"}}, -- 418
	scavenger = { -- 424
		x0 = 464, -- 425
		x1 = 512, -- 426
		y = 0, -- 427
		h = 82, -- 428
		patrolSpeed = 40, -- 429
		approachSpeed = 64, -- 430
		hearTicks = 18, -- 431
		stallTicks = 120, -- 432
		range = 480 -- 433
	}, -- 433
	bottle = {x = 112, y = 48}, -- 435
	brickX = 608, -- 436
	basinX = 548, -- 437
	softX = 272, -- 438
	passLine = 440 -- 439
} -- 439
--- 剧本锚点跟着 originX 一起搬，判定仍读世界坐标。
local function shiftStory(story, ox) -- 443
	if story == nil then -- 443
		return nil -- 445
	end -- 445
	if ox == 0 then -- 445
		return story -- 448
	end -- 448
	local out = {} -- 450
	if story.prologue ~= nil then -- 450
		out.prologue = {giveReach = story.prologue.giveReach} -- 452
	end -- 452
	if story.gate ~= nil then -- 452
		out.gate = { -- 455
			winchX = story.gate.winchX + ox, -- 456
			waitX = story.gate.waitX + ox, -- 457
			doorX = story.gate.doorX + ox, -- 458
			exitX = story.gate.exitX + ox, -- 459
			holdTicks = story.gate.holdTicks -- 460
		} -- 460
	end -- 460
	if story.gatepath ~= nil then -- 460
		out.gatepath = {carryX = story.gatepath.carryX + ox, exitX = story.gatepath.exitX + ox, next = story.gatepath.next} -- 464
	end -- 464
	if story.dog ~= nil then -- 464
		out.dog = {x0 = story.dog.x0 + ox, x1 = story.dog.x1 + ox, speed = story.dog.speed, range = story.dog.range} -- 471
	end -- 471
	if story.museum ~= nil then -- 471
		out.museum = {cabinetX = story.museum.cabinetX + ox, hallX = story.museum.hallX + ox, lampX = story.museum.lampX + ox, exitX = story.museum.exitX + ox} -- 474
	end -- 474
	if story.tower ~= nil then -- 474
		out.tower = {doorX = story.tower.doorX + ox, knockTicks = story.tower.knockTicks} -- 482
	end -- 482
	return out -- 484
end -- 443
--- 序章：周戍在废墟里找到藏在倒柜后的小满，走近点 E 递出指南针（纸条夹在针套里）。
-- 递完她开始跟随，两人一起走进街道。
____exports.PROLOGUE_ROOM = { -- 491
	key = "prologue", -- 492
	originX = 0, -- 493
	name = "序章 · 倒柜后", -- 494
	caption = "周戍持针套，小满藏在倒柜后；走近点 E 递过去，纸条塞进针套，她开始跟随", -- 495
	minX = 0, -- 496
	maxX = 720, -- 497
	height = 200, -- 498
	depth = LANE_ROAD, -- 499
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 500
	solids = { -- 501
		{ -- 502
			x = 152, -- 502
			w = 98, -- 502
			h = 32, -- 502
			y = 0, -- 502
			label = "倒柜 152–250 · 高 32", -- 502
			lanes = {"lower", "middle"}, -- 502
			art = "cover_wood" -- 502
		}, -- 502
		{ -- 503
			x = 648, -- 503
			w = 30, -- 503
			h = 118, -- 503
			y = 0, -- 503
			label = "出口门柱", -- 503
			lanes = {"lower", "upper"}, -- 503
			art = "gate_post" -- 503
		}, -- 503
		{ -- 504
			x = 344, -- 504
			w = 32, -- 504
			h = 78, -- 504
			y = 0, -- 504
			label = "石柱", -- 504
			lanes = {"lower", "middle"}, -- 504
			art = "wall" -- 504
		}, -- 504
		{ -- 505
			x = 56, -- 505
			w = 44, -- 505
			h = 18, -- 505
			y = 0, -- 505
			label = "侧灶 56–100 · 高 18", -- 505
			decorative = true, -- 505
			art = "stove_hearth" -- 505
		}, -- 505
		{ -- 506
			x = 396, -- 506
			w = 34, -- 506
			h = 12, -- 506
			y = 0, -- 506
			label = "井沿 396–430 · 高 12", -- 506
			decorative = true, -- 506
			art = "well" -- 506
		}, -- 506
		{ -- 507
			x = 470, -- 507
			w = 40, -- 507
			h = 26, -- 507
			y = 0, -- 507
			label = "后院矮墙 470–510 · 高 26", -- 507
			lanes = {"lower"}, -- 507
			art = "cover_stone" -- 507
		} -- 507
	}, -- 507
	zones = {{ -- 509
		x0 = 380, -- 510
		x1 = 470, -- 510
		y = 0, -- 510
		h = 6, -- 510
		tint = 2, -- 510
		label = "后院旧井 380–470" -- 510
	}}, -- 510
	arch = { -- 512
		x0 = 0, -- 512
		x1 = 0, -- 512
		y = 0, -- 512
		h = 0, -- 512
		label = "" -- 512
	}, -- 512
	stairs = {}, -- 513
	cart = { -- 514
		startX = 0, -- 514
		endX = 0, -- 514
		baseY = 0, -- 514
		bodyW = 0, -- 514
		bodyH = 0, -- 514
		wheelR = 0, -- 514
		handleOffset = 0, -- 514
		clothSide = 1 -- 514
	}, -- 514
	spawns = {{x = 80, y = 0, h = 88, label = "周戍 80"}, {x = 300, y = 0, h = 56, label = "小满 300 · 柜子后面"}}, -- 515
	marks = {{x = 300, y = 0, kind = 1, label = "柜后 300"}, {x = 430, y = 0, kind = 7, label = "旧井 430"}, {x = 660, y = 0, kind = 0, label = "门口中路 660"}}, -- 519
	dims = {{x0 = 152, x1 = 250, text = "倒柜 98"}, {x0 = 648, x1 = 678, text = "门柱 30"}}, -- 524
	story = {prologue = {giveReach = 46}} -- 528
} -- 528
--- 街道：两人已经同行，第一次交火在街心柜台后，打完把柜台敲两下算解除。
-- 一路走到检查站入口，提交进度后进入检查站。
____exports.STREET_ROOM = { -- 535
	key = "street", -- 536
	originX = 0, -- 537
	name = "街道 · 柜台与交火", -- 538
	caption = "小满跟着走；街心柜台后有两名敌兵，点鼠标射击，清掉后一起走到检查站入口", -- 539
	minX = 0, -- 540
	maxX = 1000, -- 541
	height = 210, -- 542
	depth = LANE_ROAD, -- 543
	floors = {{y = 0, x0 = 0, x1 = 1000}}, -- 544
	solids = {{ -- 545
		x = 300, -- 546
		w = 100, -- 546
		h = 44, -- 546
		y = 0, -- 546
		label = "街心柜台 300–400 · 高 44", -- 546
		lanes = {"lower", "middle"}, -- 546
		art = "cover_wood" -- 546
	}, { -- 546
		x = 620, -- 547
		w = 60, -- 547
		h = 36, -- 547
		y = 0, -- 547
		label = "街边矮墙 620", -- 547
		lanes = {"upper"}, -- 547
		art = "cover_stone" -- 547
	}, { -- 547
		x = 892, -- 548
		w = 40, -- 548
		h = 120, -- 548
		y = 0, -- 548
		label = "检查站门柱", -- 548
		lanes = {"lower", "upper"}, -- 548
		art = "gate_post" -- 548
	}}, -- 548
	zones = {}, -- 550
	arch = { -- 551
		x0 = 0, -- 551
		x1 = 0, -- 551
		y = 0, -- 551
		h = 0, -- 551
		label = "" -- 551
	}, -- 551
	stairs = {}, -- 552
	cart = { -- 553
		startX = 0, -- 553
		endX = 0, -- 553
		baseY = 0, -- 553
		bodyW = 0, -- 553
		bodyH = 0, -- 553
		wheelR = 0, -- 553
		handleOffset = 0, -- 553
		clothSide = 1 -- 553
	}, -- 553
	spawns = {{x = 100, y = 0, h = 88, label = "周戍 100"}, {x = 60, y = 0, h = 56, label = "小满 60"}}, -- 554
	marks = {{x = 900, y = 0, kind = 0, label = "检查站入口 900"}, {x = 520, y = 0, kind = 3, label = "街心 520"}}, -- 558
	dims = {{x0 = 300, x1 = 400, text = "柜台 100"}, {x0 = 900, x1 = 1000, text = "入口 100"}} -- 562
} -- 562
--- 城门：周戍把小满送到门洞等待点，自己回到绞盘；两人就位后开始 45 秒守点。
-- 守满后玩家走到门边按 E 送别，接着是数到二十与交权。
____exports.GATE_ROOM = { -- 572
	key = "gate", -- 573
	originX = 0, -- 574
	name = "城门 · 45 秒守点", -- 575
	caption = "小满到门洞 960、周戍贴住绞盘 118，两人就位开始 45 秒；守满走到门边按 E 送她", -- 576
	minX = 0, -- 577
	maxX = 1200, -- 578
	height = 240, -- 579
	depth = LANE_ROAD, -- 580
	floors = {{y = 0, x0 = 0, x1 = 1200}}, -- 581
	solids = { -- 582
		{ -- 583
			x = 40, -- 583
			w = 60, -- 583
			h = 60, -- 583
			y = 0, -- 583
			label = "绞盘 40–100 · 高 60", -- 583
			lanes = {"middle"}, -- 583
			art = "winch" -- 583
		}, -- 583
		{ -- 584
			x = 520, -- 584
			w = 80, -- 584
			h = 44, -- 584
			y = 0, -- 584
			label = "街垒 520 · 高 44", -- 584
			lanes = {"middle", "upper"}, -- 584
			art = "cover_stone" -- 584
		}, -- 584
		{ -- 585
			x = 840, -- 585
			w = 24, -- 585
			h = 160, -- 585
			y = 0, -- 585
			label = "城门左门柱", -- 585
			lanes = {"lower", "upper"}, -- 585
			art = "gate_post" -- 585
		}, -- 585
		{ -- 586
			x = 1016, -- 586
			w = 24, -- 586
			h = 160, -- 586
			y = 0, -- 586
			label = "城门右门柱", -- 586
			lanes = {"lower", "upper"}, -- 586
			art = "gate_post" -- 586
		}, -- 586
		{ -- 587
			x = 1040, -- 587
			w = 160, -- 587
			h = 180, -- 587
			y = 0, -- 587
			label = "门洞右墙 1040", -- 587
			depth = LANE_ROAD, -- 587
			art = "wall" -- 587
		}, -- 587
		{ -- 588
			x = 840, -- 588
			w = 200, -- 588
			h = 56, -- 588
			y = 160, -- 588
			label = "门楣 840–1040", -- 588
			depth = LANE_ROAD, -- 588
			art = "wall" -- 588
		} -- 588
	}, -- 588
	zones = {{ -- 590
		x0 = 860, -- 591
		x1 = 1000, -- 591
		y = 0, -- 591
		h = 8, -- 591
		tint = 4, -- 591
		label = "门洞 860–1000" -- 591
	}}, -- 591
	arch = { -- 593
		x0 = 0, -- 593
		x1 = 0, -- 593
		y = 0, -- 593
		h = 0, -- 593
		label = "" -- 593
	}, -- 593
	stairs = {}, -- 594
	cart = { -- 595
		startX = 0, -- 595
		endX = 0, -- 595
		baseY = 0, -- 595
		bodyW = 0, -- 595
		bodyH = 0, -- 595
		wheelR = 0, -- 595
		handleOffset = 0, -- 595
		clothSide = 1 -- 595
	}, -- 595
	spawns = {{x = 130, y = 0, h = 88, label = "周戍 130"}, {x = 150, y = 0, h = 56, label = "小满 150"}}, -- 596
	marks = {{x = 118, y = 0, kind = 1, label = "绞盘站位 118"}, {x = 960, y = 0, kind = 1, label = "门洞等待点 960"}, {x = 860, y = 0, kind = 0, label = "门边 860"}, {x = 1020, y = 0, kind = 0, label = "出门 1020"}}, -- 600
	dims = {{x0 = 40, x1 = 100, text = "绞盘 60"}, {x0 = 840, x1 = 1040, text = "门洞 200"}}, -- 606
	story = {gate = { -- 611
		winchX = 118, -- 611
		waitX = 960, -- 611
		doorX = 860, -- 611
		exitX = 1020, -- 611
		holdTicks = 2700 -- 611
	}} -- 611
} -- 611
--- 城外巷路：男主线牵手成功后的可操控起步段。
-- 
-- 侧向跟拍，两人先牵着手过一段平路（0–780），到高石阶 780–860 抬 48 后
-- 进入下一段入口（860 平台）。上背与护送试炼发生在后续段，本房只交付
-- 「交回移动」之后的同行控制。
____exports.GATE_PATH_ROOM = { -- 621
	key = "gatepath", -- 622
	originX = 0, -- 623
	name = "城外巷路 · 兄妹同行", -- 624
	caption = "牵着手沿平路往北；到高石阶前停住，下一段从这里接背上她", -- 625
	minX = 0, -- 626
	maxX = 1040, -- 627
	height = 220, -- 628
	depth = {min = -28, max = 28}, -- 629
	floors = {{y = 0, x0 = 0, x1 = 1040}, {y = 48, x0 = 860, x1 = 1040}}, -- 630
	solids = {{ -- 634
		x = 0, -- 635
		w = 60, -- 635
		h = 180, -- 635
		y = 0, -- 635
		label = "城门内墙背影 0–60", -- 635
		depth = {min = -28, max = 28}, -- 635
		art = "wall" -- 635
	}, { -- 635
		x = 560, -- 636
		w = 44, -- 636
		h = 28, -- 636
		y = 0, -- 636
		label = "倒石 560 · 高 28", -- 636
		depth = {min = -28, max = -4}, -- 636
		art = "cover_stone" -- 636
	}, { -- 636
		x = 1000, -- 637
		w = 40, -- 637
		h = 200, -- 637
		y = 0, -- 637
		label = "巷尾石壁 1000", -- 637
		depth = {min = -28, max = 28}, -- 637
		art = "wall" -- 637
	}}, -- 637
	zones = {{ -- 639
		x0 = 860, -- 640
		x1 = 1000, -- 640
		y = 48, -- 640
		h = 6, -- 640
		tint = 4, -- 640
		label = "高石阶平台 860–1000" -- 640
	}}, -- 640
	arch = { -- 642
		x0 = 0, -- 642
		x1 = 0, -- 642
		y = 0, -- 642
		h = 0, -- 642
		label = "" -- 642
	}, -- 642
	stairs = {{ -- 643
		x0 = 780, -- 644
		x1 = 860, -- 644
		y0 = 0, -- 644
		y1 = 48, -- 644
		steps = 3, -- 644
		label = "高石阶 0 / 16 / 32 / 48", -- 644
		depth = {min = -28, max = 28} -- 644
	}}, -- 644
	cart = { -- 646
		startX = 0, -- 646
		endX = 0, -- 646
		baseY = 0, -- 646
		bodyW = 0, -- 646
		bodyH = 0, -- 646
		wheelR = 0, -- 646
		handleOffset = 0, -- 646
		clothSide = 1 -- 646
	}, -- 646
	spawns = {{x = 120, y = 0, h = 88, label = "周戍 120"}, {x = 150, y = 0, h = 56, label = "小满 150"}}, -- 647
	marks = {{x = 120, y = 0, kind = 1, label = "牵头起步 120"}, {x = 520, y = 0, kind = 3, label = "袖口红布 520"}, {x = 840, y = 0, kind = 0, label = "高石阶前 840"}, {x = 980, y = 48, kind = 0, label = "下一段入口 980"}}, -- 651
	dims = {{x0 = 0, x1 = 560, text = "平路 560"}, {x0 = 780, x1 = 860, text = "高石阶 80 · 抬 48"}, {x0 = 860, x1 = 1000, text = "平台 140"}}, -- 657
	story = {gatepath = {carryX = 840, exitX = 980, next = "escort1"}} -- 662
} -- 662
--- 北塔森林：小满独自走。草后可以等，狗听见脚步会转耳朵、赶来、停一会儿再回线。
-- 最后一段从林缘自己选时机走到灯下门廊。
____exports.FOREST_ROOM = { -- 669
	key = "forest", -- 670
	originX = 0, -- 671
	name = "北塔森林 · 草与狗", -- 672
	caption = "狗对动静比人快：草后等、Shift 慢走、蹲着过；林缘 1450 走到灯下门廊", -- 673
	minX = 0, -- 674
	maxX = 1600, -- 675
	height = 200, -- 676
	depth = LANE_ROAD, -- 677
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 678
	solids = {{ -- 679
		x = 300, -- 680
		w = 80, -- 680
		h = 24, -- 680
		y = 0, -- 680
		depth = LANE_ROAD, -- 680
		label = "草丛 300–380 · 高 24", -- 680
		passable = true -- 680
	}, { -- 680
		x = 700, -- 681
		w = 90, -- 681
		h = 24, -- 681
		y = 0, -- 681
		depth = LANE_ROAD, -- 681
		label = "草丛 700–790 · 高 24", -- 681
		passable = true -- 681
	}, { -- 681
		x = 1150, -- 682
		w = 90, -- 682
		h = 24, -- 682
		y = 0, -- 682
		depth = LANE_ROAD, -- 682
		label = "草丛 1150–1240 · 高 24", -- 682
		passable = true -- 682
	}, { -- 682
		x = 1560, -- 683
		w = 40, -- 683
		h = 160, -- 683
		y = 0, -- 683
		depth = LANE_ROAD, -- 683
		label = "林缘 1560" -- 683
	}}, -- 683
	zones = {{ -- 685
		x0 = 300, -- 686
		x1 = 380, -- 686
		y = 0, -- 686
		h = 6, -- 686
		tint = 2, -- 686
		label = "树根窄洞 300–380 · 蹲行" -- 686
	}, { -- 686
		x0 = 700, -- 687
		x1 = 790, -- 687
		y = 0, -- 687
		h = 6, -- 687
		tint = 3, -- 687
		label = "旧渠 700–790 · 可跑" -- 687
	}, { -- 687
		x0 = 1180, -- 688
		x1 = 1260, -- 688
		y = 0, -- 688
		h = 6, -- 688
		tint = 1, -- 688
		label = "溪湾 1180–1260 · 水里灯" -- 688
	}, { -- 688
		x0 = 1400, -- 689
		x1 = 1470, -- 689
		y = 0, -- 689
		h = 6, -- 689
		tint = 4, -- 689
		label = "林边 1400–1470" -- 689
	}}, -- 689
	arch = { -- 691
		x0 = 0, -- 691
		x1 = 0, -- 691
		y = 0, -- 691
		h = 0, -- 691
		label = "" -- 691
	}, -- 691
	stairs = {{ -- 692
		x0 = 520, -- 693
		x1 = 640, -- 693
		y0 = 22, -- 693
		y1 = 22, -- 693
		steps = 1, -- 693
		depth = LANE_ROAD, -- 693
		label = "矮台 520–640 · 高 22" -- 693
	}, { -- 693
		x0 = 980, -- 694
		x1 = 1100, -- 694
		y0 = 22, -- 694
		y1 = 22, -- 694
		steps = 1, -- 694
		depth = LANE_ROAD, -- 694
		label = "矮台 980–1100 · 高 22" -- 694
	}}, -- 694
	cart = { -- 696
		startX = 0, -- 696
		endX = 0, -- 696
		baseY = 0, -- 696
		bodyW = 0, -- 696
		bodyH = 0, -- 696
		wheelR = 0, -- 696
		handleOffset = 0, -- 696
		clothSide = 1 -- 696
	}, -- 696
	spawns = {{x = 120, y = 0, h = 56, label = "小满 120"}}, -- 697
	marks = {{x = 1450, y = 0, kind = 0, label = "林边安全点 1450"}, {x = 620, y = 0, kind = 3, label = "矮台 620"}, {x = 1220, y = 0, kind = 6, label = "溪湾水里灯 1220"}}, -- 698
	dims = {{x0 = 300, x1 = 380, text = "窄洞 80 · 蹲"}, {x0 = 700, x1 = 790, text = "旧渠 90 · 跑"}, {x0 = 1180, x1 = 1260, text = "溪湾 80"}, {x0 = 1400, x1 = 1470, text = "林边 70"}}, -- 703
	story = {dog = {x0 = 620, x1 = 780, speed = 56, range = 300}} -- 709
} -- 709
--- 塔门与尾声：小满走到门前，按一次 E 敲两下；守卫开门接过针套和纸条，
-- 在登记簿里给下一个人留出一行空白。片尾可以再玩。
____exports.TOWER_ROOM = { -- 716
	key = "tower", -- 717
	originX = 0, -- 718
	name = "北塔塔门与值夜室 · 尾声", -- 719
	caption = "门前点 E 叩两下；守卒回叩开门后跨过门槛，到桌前长按 E 交针套、指南针和纸条", -- 720
	minX = 0, -- 721
	maxX = 720, -- 722
	height = 220, -- 723
	depth = LANE_ROAD, -- 724
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 725
	solids = { -- 726
		{ -- 727
			x = 180, -- 727
			w = 220, -- 727
			h = 200, -- 727
			y = 0, -- 727
			depth = LANE_ROAD, -- 727
			label = "塔身左 180–400" -- 727
		}, -- 727
		{ -- 728
			x = 430, -- 728
			w = 40, -- 728
			h = 120, -- 728
			y = 0, -- 728
			depth = LANE_ROAD, -- 728
			id = "tower_door", -- 728
			label = "塔门 430–470 · E 叩两下" -- 728
		}, -- 728
		{ -- 729
			x = 700, -- 729
			w = 20, -- 729
			h = 220, -- 729
			y = 0, -- 729
			depth = LANE_ROAD, -- 729
			label = "塔身右墙 700–720" -- 729
		}, -- 729
		{ -- 730
			x = 400, -- 730
			w = 90, -- 730
			h = 30, -- 730
			y = 110, -- 730
			depth = LANE_ROAD, -- 730
			label = "门楣 400–490" -- 730
		}, -- 730
		{ -- 731
			x = 560, -- 731
			w = 90, -- 731
			h = 32, -- 731
			y = 0, -- 731
			depth = LANE_ROAD, -- 731
			id = "tower_desk", -- 731
			art = "cover_wood", -- 731
			label = "值夜桌 560–650 · 长按 E 交物" -- 731
		}, -- 731
		{ -- 732
			x = 660, -- 732
			w = 40, -- 732
			h = 8, -- 732
			y = 120, -- 732
			decorative = true, -- 732
			label = "西窗 660–700" -- 732
		} -- 732
	}, -- 732
	zones = {{ -- 734
		x0 = 400, -- 735
		x1 = 490, -- 735
		y = 0, -- 735
		h = 8, -- 735
		tint = 4, -- 735
		label = "门廊 400–490" -- 735
	}, { -- 735
		x0 = 490, -- 736
		x1 = 700, -- 736
		y = 0, -- 736
		h = 8, -- 736
		tint = 3, -- 736
		label = "值夜室 490–700" -- 736
	}}, -- 736
	arch = { -- 738
		x0 = 0, -- 738
		x1 = 0, -- 738
		y = 0, -- 738
		h = 0, -- 738
		label = "" -- 738
	}, -- 738
	stairs = {}, -- 739
	cart = { -- 740
		startX = 0, -- 740
		endX = 0, -- 740
		baseY = 0, -- 740
		bodyW = 0, -- 740
		bodyH = 0, -- 740
		wheelR = 0, -- 740
		handleOffset = 0, -- 740
		clothSide = 1 -- 740
	}, -- 740
	spawns = {{x = 400, y = 0, h = 56, label = "小满 400 · 门廊里"}}, -- 741
	marks = {{x = 445, y = 0, kind = 1, label = "门前 445"}, {x = 520, y = 0, kind = 3, label = "门槛 520"}, {x = 605, y = 0, kind = 3, label = "值夜桌 605"}, {x = 680, y = 0, kind = 6, label = "西窗 680"}}, -- 742
	dims = {{x0 = 400, x1 = 490, text = "门 90"}, {x0 = 560, x1 = 650, text = "桌 90"}}, -- 748
	story = {tower = {doorX = 445, knockTicks = 36}} -- 752
} -- 752
local NO_CART = { -- 755
	startX = 0, -- 756
	endX = 0, -- 756
	baseY = 0, -- 756
	bodyW = 0, -- 756
	bodyH = 0, -- 756
	wheelR = 0, -- 756
	handleOffset = 0, -- 756
	clothSide = -1 -- 756
} -- 756
--- C2 博物馆返场：一次「时间穿梭器」的虚构现代纪念厅。
-- 玩家单人（周戍）走完柜前、走廊、末厅、回柜边四步，每步一个输入边沿。
____exports.MUSEUM_ROOM = { -- 764
	key = "museum", -- 765
	name = "博物馆 · 西厅", -- 766
	caption = "虚构 · 现代纪念厅", -- 767
	originX = 0, -- 768
	minX = 0, -- 768
	maxX = 1400, -- 768
	height = 240, -- 768
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 769
	solids = { -- 770
		{ -- 771
			x = 180, -- 771
			w = 80, -- 771
			h = 64, -- 771
			y = 0, -- 771
			label = "玻璃柜 180–260 · 高 64", -- 771
			decorative = true, -- 771
			id = "museum_case" -- 771
		}, -- 771
		{ -- 772
			x = 540, -- 772
			w = 60, -- 772
			h = 140, -- 772
			y = 0, -- 772
			label = "展墙 540–600 · 高 140", -- 772
			decorative = true -- 772
		}, -- 772
		{ -- 773
			x = 1180, -- 773
			w = 40, -- 773
			h = 160, -- 773
			y = 0, -- 773
			label = "末厅门柱 1180–1220 · 高 160", -- 773
			decorative = true -- 773
		}, -- 773
		{ -- 774
			x = 1300, -- 774
			w = 60, -- 774
			h = 8, -- 774
			y = 120, -- 774
			label = "西窗 1300–1360 · 高 8", -- 774
			decorative = true -- 774
		}, -- 774
		{ -- 775
			x = 1360, -- 775
			w = 40, -- 775
			h = 200, -- 775
			y = 0, -- 775
			label = "馆尾 1360–1400 · 高 200" -- 775
		} -- 775
	}, -- 775
	zones = {{ -- 777
		x0 = 160, -- 778
		x1 = 300, -- 778
		y = 0, -- 778
		h = 16, -- 778
		tint = 1, -- 778
		label = "玻璃柜前" -- 778
	}, { -- 778
		x0 = 860, -- 779
		x1 = 980, -- 779
		y = 0, -- 779
		h = 16, -- 779
		tint = 2, -- 779
		label = "走廊 · 孩子脚步" -- 779
	}, { -- 779
		x0 = 1210, -- 780
		x1 = 1320, -- 780
		y = 0, -- 780
		h = 16, -- 780
		tint = 3, -- 780
		label = "末厅 · 西窗" -- 780
	}}, -- 780
	arch = { -- 782
		x0 = 0, -- 782
		x1 = 0, -- 782
		y = 0, -- 782
		h = 0, -- 782
		label = "" -- 782
	}, -- 782
	stairs = {}, -- 783
	cart = NO_CART, -- 784
	spawns = {{x = 80, y = 0, h = 88, label = "周戍 80 · 展厅入口"}}, -- 785
	marks = {{x = 200, y = 0, kind = 4, label = "玻璃柜 200"}, {x = 900, y = 0, kind = 4, label = "走廊 900"}, {x = 1250, y = 0, kind = 6, label = "末厅 1250"}, {x = 1360, y = 0, kind = 0, label = "出口 1360"}}, -- 786
	dims = {{x0 = 160, x1 = 300, text = "柜 80"}, {x0 = 1180, x1 = 1220, text = "门 40"}}, -- 792
	story = {museum = {cabinetX = 200, hallX = 900, lampX = 1250, exitX = 1360}} -- 796
} -- 796
--- 男主首场护送战：背着受伤的小满穿过城外巷路。
-- 巷底两名火器手与一名破障手压过来，玩家边观察边完成一次慢时连线换弹，走到巷尾脱身。
____exports.ESCORT1_ROOM = { -- 803
	key = "escort1", -- 804
	originX = 0, -- 805
	name = "城外巷路 · 第一段护送", -- 806
	caption = "背上的小满贴着肩；巷底两名火器手与一名破障手压过来，走到巷尾就算脱身", -- 807
	minX = 0, -- 808
	maxX = 1600, -- 809
	height = 220, -- 810
	depth = LANE_ROAD, -- 811
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 812
	solids = { -- 813
		{ -- 814
			x = 0, -- 814
			w = 50, -- 814
			h = 150, -- 814
			y = 0, -- 814
			label = "巷口背影 0–50", -- 814
			depth = LANE_ROAD, -- 814
			art = "wall" -- 814
		}, -- 814
		{ -- 815
			x = 380, -- 815
			w = 96, -- 815
			h = 44, -- 815
			y = 0, -- 815
			label = "塌墙 380–476 · 高 44", -- 815
			lanes = {"lower", "middle"}, -- 815
			art = "cover_stone", -- 815
			id = "e1_wall" -- 815
		}, -- 815
		{ -- 816
			x = 620, -- 816
			w = 24, -- 816
			h = 50, -- 816
			y = 0, -- 816
			label = "薄木护板 620 · 高 50", -- 816
			lanes = {"upper"}, -- 816
			art = "cover_wood", -- 816
			id = "e1_wood", -- 816
			breakable = {hp = 2, kind = "thin_wood", wedgeable = true} -- 816
		}, -- 816
		{ -- 817
			x = 700, -- 817
			w = 40, -- 817
			h = 28, -- 817
			y = 0, -- 817
			label = "倒石 700 · 高 28", -- 817
			lanes = {"lower"}, -- 817
			art = "cover_stone" -- 817
		}, -- 817
		{ -- 818
			x = 980, -- 818
			w = 160, -- 818
			h = 36, -- 818
			y = 0, -- 818
			label = "石台 980–1140 · 高 36（可跳）", -- 818
			lanes = {"lower"}, -- 818
			art = "cover_wood" -- 818
		}, -- 818
		{ -- 819
			x = 1300, -- 819
			w = 40, -- 819
			h = 140, -- 819
			y = 0, -- 819
			label = "巷尾门柱 1300", -- 819
			lanes = {"lower", "upper"}, -- 819
			art = "gate_post" -- 819
		}, -- 819
		{ -- 820
			x = 1560, -- 820
			w = 40, -- 820
			h = 180, -- 820
			y = 0, -- 820
			label = "巷尾断墙 1560–1600 · 高 180", -- 820
			depth = LANE_ROAD, -- 820
			art = "wall" -- 820
		} -- 820
	}, -- 820
	zones = {{ -- 822
		x0 = 560, -- 822
		x1 = 900, -- 822
		y = 0, -- 822
		h = 150, -- 822
		tint = 1, -- 822
		label = "交火 560–900" -- 822
	}}, -- 822
	arch = { -- 823
		x0 = 0, -- 823
		x1 = 0, -- 823
		y = 0, -- 823
		h = 0, -- 823
		label = "" -- 823
	}, -- 823
	stairs = {{ -- 824
		x0 = 1140, -- 824
		x1 = 1300, -- 824
		y0 = 0, -- 824
		y1 = 40, -- 824
		steps = 3, -- 824
		label = "石台斜走 1140–1300", -- 824
		lanes = {"lower", "middle"} -- 824
	}}, -- 824
	cart = NO_CART, -- 825
	spawns = {{ -- 826
		x = 820, -- 827
		y = 0, -- 827
		h = 84, -- 827
		depth = 32, -- 827
		label = "火器手 820 · 中档", -- 827
		kind = "gunner", -- 827
		drop = "ammo" -- 827
	}, { -- 827
		x = 1020, -- 828
		y = 0, -- 828
		h = 84, -- 828
		depth = -28, -- 828
		label = "火器手 1020 · 浅档", -- 828
		kind = "gunner", -- 828
		drop = "ammo" -- 828
	}, { -- 828
		x = 1120, -- 829
		y = 0, -- 829
		h = 84, -- 829
		depth = -28, -- 829
		label = "破障手 1120", -- 829
		kind = "breaker", -- 829
		drop = "wedge" -- 829
	}}, -- 829
	marks = {{x = 200, y = 0, kind = 3, label = "背负起点 200"}, {x = 476, y = 0, kind = 3, label = "塌墙后 476"}, {x = 900, y = 0, kind = 0, label = "交火尽头 900"}, {x = 1500, y = 0, kind = 0, label = "安全出口 1500"}}, -- 831
	dims = {{x0 = 380, x1 = 476, text = "塌墙 96"}, {x0 = 980, x1 = 1140, text = "石台 160"}, {x0 = 1300, x1 = 1600, text = "巷尾 300"}}, -- 837
	campaign = { -- 842
		chapter = "O", -- 842
		act = 1, -- 842
		budget = 240, -- 842
		goal = "reach_exit", -- 842
		exitX = 1500, -- 842
		next = "escort2", -- 842
		checkpoint = 1, -- 842
		reloadPuzzle = true -- 842
	} -- 842
} -- 842
--- 第二段粮棚：从第一段巷尾转进粮棚，高低两条通路各放材料。
-- 上层棚架两枚木纹筹，地面一枚木纹筹与一枚铃纹筹——走齐两条通路才能凑够两种配方。
____exports.ESCORT2_ROOM = { -- 850
	key = "escort2", -- 851
	originX = 0, -- 852
	name = "粮棚 · 第二段取材", -- 853
	caption = "棚架与地面沿途收集：木纹筹两枚、铃纹筹一枚，够在工台二选一", -- 854
	minX = 0, -- 855
	maxX = 1500, -- 856
	height = 220, -- 857
	depth = LANE_ROAD, -- 858
	floors = {{y = 0, x0 = 0, x1 = 1500}}, -- 859
	solids = { -- 860
		{ -- 861
			x = 0, -- 861
			w = 50, -- 861
			h = 160, -- 861
			y = 0, -- 861
			label = "棚口背影 0–50", -- 861
			depth = LANE_ROAD, -- 861
			art = "wall" -- 861
		}, -- 861
		{ -- 862
			x = 300, -- 862
			w = 24, -- 862
			h = 64, -- 862
			y = 0, -- 862
			label = "棚架柱 300", -- 862
			lanes = {"lower"}, -- 862
			art = "cover_wood" -- 862
		}, -- 862
		{ -- 863
			x = 300, -- 863
			w = 600, -- 863
			h = 8, -- 863
			y = 64, -- 863
			label = "棚架梁 300–900 · 高 64", -- 863
			depth = {min = -44, max = -20}, -- 863
			passable = true, -- 863
			art = "cover_wood" -- 863
		}, -- 863
		{ -- 864
			x = 640, -- 864
			w = 60, -- 864
			h = 32, -- 864
			y = 0, -- 864
			label = "倒粮袋 640 · 高 32", -- 864
			lanes = {"lower"}, -- 864
			art = "grain_sack", -- 864
			id = "e2_grain_sacks" -- 864
		}, -- 864
		{ -- 865
			x = 980, -- 865
			w = 140, -- 865
			h = 48, -- 865
			y = 0, -- 865
			label = "粮台 980–1120 · 高 48", -- 865
			lanes = {"lower", "middle"}, -- 865
			art = "cover_wood" -- 865
		}, -- 865
		{ -- 866
			x = 1460, -- 866
			w = 40, -- 866
			h = 180, -- 866
			y = 0, -- 866
			label = "棚尾断墙 1460–1500 · 高 180", -- 866
			depth = LANE_ROAD, -- 866
			art = "wall" -- 866
		} -- 866
	}, -- 866
	zones = {{ -- 868
		x0 = 520, -- 868
		x1 = 900, -- 868
		y = 0, -- 868
		h = 150, -- 868
		tint = 1, -- 868
		label = "取材 520–900" -- 868
	}}, -- 868
	arch = { -- 869
		x0 = 0, -- 869
		x1 = 0, -- 869
		y = 0, -- 869
		h = 0, -- 869
		label = "" -- 869
	}, -- 869
	stairs = {{ -- 870
		x0 = 780, -- 870
		x1 = 900, -- 870
		y0 = 0, -- 870
		y1 = 64, -- 870
		steps = 3, -- 870
		label = "棚架斜梯 780–900", -- 870
		lanes = {"lower", "middle"} -- 870
	}}, -- 870
	cart = NO_CART, -- 871
	spawns = {{ -- 872
		x = 700, -- 873
		y = 0, -- 873
		h = 84, -- 873
		depth = 32, -- 873
		label = "火器手 700 · 中档", -- 873
		kind = "gunner", -- 873
		drop = "ammo" -- 873
	}, { -- 873
		x = 1080, -- 874
		y = 0, -- 874
		h = 84, -- 874
		depth = -28, -- 874
		label = "火器手 1080 · 浅档", -- 874
		kind = "gunner", -- 874
		drop = "ammo" -- 874
	}, { -- 874
		x = 1200, -- 875
		y = 0, -- 875
		h = 84, -- 875
		depth = 24, -- 875
		label = "破障手 1200", -- 875
		kind = "breaker", -- 875
		drop = "wedge" -- 875
	}}, -- 875
	marks = {{x = 200, y = 0, kind = 3, label = "进棚 200"}, {x = 476, y = 0, kind = 3, label = "棚架下 476"}, {x = 900, y = 0, kind = 0, label = "棚架尽头 900"}, {x = 1400, y = 0, kind = 0, label = "粮棚出口 1400"}}, -- 877
	dims = {{x0 = 300, x1 = 900, text = "棚架 600"}, {x0 = 980, x1 = 1120, text = "粮台 140"}}, -- 883
	pickups = {{ -- 887
		id = "e2_wood_a", -- 888
		kind = "wood", -- 888
		x = 380, -- 888
		y = 0, -- 888
		label = "木纹筹 · 棚下" -- 888
	}, { -- 888
		id = "e2_bell", -- 889
		kind = "bell", -- 889
		x = 560, -- 889
		y = 0, -- 889
		label = "铃纹筹 · 粮袋后" -- 889
	}, { -- 889
		id = "e2_wood_b", -- 890
		kind = "wood", -- 890
		x = 820, -- 890
		y = 0, -- 890
		label = "木纹筹 · 棚架后" -- 890
	}}, -- 890
	campaign = { -- 892
		chapter = "O", -- 892
		act = 2, -- 892
		budget = 240, -- 892
		goal = "reach_exit", -- 892
		exitX = 1400, -- 892
		next = "escort3", -- 892
		checkpoint = 1, -- 892
		reloadPuzzle = true -- 892
	} -- 892
} -- 892
--- 第三段安全工台：放下小满，看材料与两张配方，改制、装备、离站再背起。
-- 工台前的薄掩体与两个靶位用于当场试射：灯纹穿掩体、铃纹同时惊起两个声源。
____exports.ESCORT3_ROOM = { -- 899
	key = "escort3", -- 900
	originX = 0, -- 901
	name = "山腰工台 · 第三段改制", -- 902
	caption = "放下小满 → 工台按 E 看配方 → 选一件改制装备 → 试射一枪 → 离站重新背起", -- 903
	minX = 0, -- 904
	maxX = 1200, -- 905
	height = 220, -- 906
	depth = LANE_ROAD, -- 907
	floors = {{y = 0, x0 = 0, x1 = 1200}}, -- 908
	solids = { -- 909
		{ -- 910
			x = 0, -- 910
			w = 50, -- 910
			h = 160, -- 910
			y = 0, -- 910
			label = "工台口背影 0–50", -- 910
			depth = LANE_ROAD, -- 910
			art = "wall" -- 910
		}, -- 910
		{ -- 911
			x = 560, -- 911
			w = 120, -- 911
			h = 44, -- 911
			y = 0, -- 911
			label = "工台 560–680 · 高 44", -- 911
			lanes = {"middle", "upper"}, -- 911
			art = "cover_wood", -- 911
			id = "e3_bench" -- 911
		}, -- 911
		{ -- 912
			x = 720, -- 912
			w = 48, -- 912
			h = 52, -- 912
			y = 0, -- 912
			label = "试射薄掩体 720–768 · 高 52", -- 912
			lanes = {"lower", "middle"}, -- 912
			art = "cover_stone", -- 912
			id = "e3_cover" -- 912
		}, -- 912
		{ -- 913
			x = 1050, -- 913
			w = 40, -- 913
			h = 140, -- 913
			y = 0, -- 913
			label = "出站门柱 1050", -- 913
			lanes = {"lower", "upper"}, -- 913
			art = "gate_post" -- 913
		}, -- 913
		{ -- 914
			x = 1170, -- 914
			w = 30, -- 914
			h = 180, -- 914
			y = 0, -- 914
			label = "出站断墙 1170–1200 · 高 180", -- 914
			depth = LANE_ROAD, -- 914
			art = "wall" -- 914
		} -- 914
	}, -- 914
	zones = {{ -- 916
		x0 = 560, -- 916
		x1 = 960, -- 916
		y = 0, -- 916
		h = 120, -- 916
		tint = 3, -- 916
		label = "工台安全区 560–960" -- 916
	}}, -- 916
	arch = { -- 917
		x0 = 0, -- 917
		x1 = 0, -- 917
		y = 0, -- 917
		h = 0, -- 917
		label = "" -- 917
	}, -- 917
	stairs = {}, -- 918
	cart = NO_CART, -- 919
	spawns = {{ -- 920
		x = 820, -- 921
		y = 0, -- 921
		h = 84, -- 921
		depth = 16, -- 921
		label = "试射靶一 820", -- 921
		kind = "target" -- 921
	}, { -- 921
		x = 940, -- 922
		y = 0, -- 922
		h = 84, -- 922
		depth = -16, -- 922
		label = "试射靶二 940", -- 922
		kind = "target" -- 922
	}}, -- 922
	marks = {{x = 300, y = 0, kind = 0, label = "制前检查点 300"}, {x = 640, y = 0, kind = 3, label = "工台 640"}, {x = 960, y = 0, kind = 0, label = "制后检查点 960"}, {x = 1150, y = 0, kind = 0, label = "出站 1150"}}, -- 924
	dims = {{x0 = 560, x1 = 680, text = "工台 120"}, {x0 = 720, x1 = 768, text = "掩体 48"}}, -- 930
	campaign = { -- 934
		chapter = "O", -- 934
		act = 3, -- 934
		budget = 240, -- 934
		goal = "reach_exit", -- 934
		exitX = 1150, -- 934
		next = "escort4", -- 934
		checkpoint = 1, -- 934
		reloadPuzzle = true -- 934
	} -- 934
} -- 934
--- 第四段山道：边走边换弹的窄道，塌方与追兵逼玩家在换弹与脱身之间选。
____exports.ESCORT4_ROOM = { -- 940
	key = "escort4", -- 941
	originX = 0, -- 942
	name = "山道 · 第四段脱身", -- 943
	caption = "窄道上两个火器手与一个破障手；换弹时世界会慢下来，也可以滚身脱出", -- 944
	minX = 0, -- 945
	maxX = 1400, -- 946
	height = 240, -- 947
	depth = LANE_ROAD, -- 948
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 949
	solids = { -- 950
		{ -- 951
			x = 0, -- 951
			w = 50, -- 951
			h = 170, -- 951
			y = 0, -- 951
			label = "山道口 0–50", -- 951
			depth = LANE_ROAD, -- 951
			art = "wall" -- 951
		}, -- 951
		{ -- 952
			x = 380, -- 952
			w = 80, -- 952
			h = 40, -- 952
			y = 0, -- 952
			label = "塌方 380–460 · 高 40", -- 952
			lanes = {"lower", "middle"}, -- 952
			art = "cover_stone", -- 952
			id = "e4_fall" -- 952
		}, -- 952
		{ -- 953
			x = 680, -- 953
			w = 24, -- 953
			h = 50, -- 953
			y = 0, -- 953
			label = "薄木护板 680 · 高 50", -- 953
			lanes = {"upper"}, -- 953
			art = "cover_wood", -- 953
			id = "e4_wood", -- 953
			breakable = {hp = 2, kind = "thin_wood", wedgeable = true} -- 953
		}, -- 953
		{ -- 954
			x = 900, -- 954
			w = 60, -- 954
			h = 36, -- 954
			y = 0, -- 954
			label = "断口 900–960 · 高 36（可跳）", -- 954
			lanes = {"lower", "middle"}, -- 954
			art = "cover_stone" -- 954
		}, -- 954
		{ -- 955
			x = 1120, -- 955
			w = 40, -- 955
			h = 32, -- 955
			y = 0, -- 955
			label = "倒石 1120 · 高 32", -- 955
			lanes = {"lower"}, -- 955
			art = "cover_stone" -- 955
		}, -- 955
		{ -- 956
			x = 1350, -- 956
			w = 50, -- 956
			h = 200, -- 956
			y = 0, -- 956
			label = "山道尾壁 1350–1400 · 高 200", -- 956
			depth = LANE_ROAD, -- 956
			art = "wall" -- 956
		} -- 956
	}, -- 956
	zones = {{ -- 958
		x0 = 500, -- 958
		x1 = 900, -- 958
		y = 0, -- 958
		h = 160, -- 958
		tint = 2, -- 958
		label = "窄道 500–900" -- 958
	}}, -- 958
	arch = { -- 959
		x0 = 0, -- 959
		x1 = 0, -- 959
		y = 0, -- 959
		h = 0, -- 959
		label = "" -- 959
	}, -- 959
	stairs = {}, -- 960
	cart = NO_CART, -- 961
	spawns = {{ -- 962
		x = 620, -- 963
		y = 0, -- 963
		h = 84, -- 963
		depth = 32, -- 963
		label = "火器手 620 · 中档", -- 963
		kind = "gunner", -- 963
		drop = "ammo" -- 963
	}, { -- 963
		x = 840, -- 964
		y = 0, -- 964
		h = 84, -- 964
		depth = -28, -- 964
		label = "火器手 840 · 浅档", -- 964
		kind = "gunner", -- 964
		drop = "ammo" -- 964
	}, { -- 964
		x = 1060, -- 965
		y = 0, -- 965
		h = 84, -- 965
		depth = 24, -- 965
		label = "破障手 1060", -- 965
		kind = "breaker", -- 965
		drop = "wedge" -- 965
	}}, -- 965
	marks = {{x = 200, y = 0, kind = 3, label = "进山道 200"}, {x = 476, y = 0, kind = 3, label = "塌方后 476"}, {x = 960, y = 0, kind = 0, label = "断口 960"}, {x = 1300, y = 0, kind = 0, label = "山道出口 1300"}}, -- 967
	dims = {{x0 = 380, x1 = 460, text = "塌方 80"}, {x0 = 900, x1 = 960, text = "断口 60"}}, -- 973
	campaign = { -- 977
		chapter = "O", -- 977
		act = 4, -- 977
		budget = 240, -- 977
		goal = "reach_exit", -- 977
		exitX = 1300, -- 977
		next = "escort5", -- 977
		checkpoint = 1, -- 977
		reloadPuzzle = true -- 977
	} -- 977
} -- 977
--- 第五段山道：带着自己改制的武器走到塔门；出口直接接北塔。
____exports.ESCORT5_ROOM = { -- 983
	key = "escort5", -- 984
	originX = 0, -- 985
	name = "塔前山道 · 第五段", -- 986
	caption = "最后一段：带自己的武器走到塔门，走到 1320 就进北塔", -- 987
	minX = 0, -- 988
	maxX = 1400, -- 989
	height = 240, -- 990
	depth = LANE_ROAD, -- 991
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 992
	solids = { -- 993
		{ -- 994
			x = 0, -- 994
			w = 50, -- 994
			h = 170, -- 994
			y = 0, -- 994
			label = "山道口 0–50", -- 994
			depth = LANE_ROAD, -- 994
			art = "wall" -- 994
		}, -- 994
		{ -- 995
			x = 320, -- 995
			w = 96, -- 995
			h = 44, -- 995
			y = 0, -- 995
			label = "石阶塌墙 320–416 · 高 44", -- 995
			lanes = {"lower", "middle"}, -- 995
			art = "cover_stone", -- 995
			id = "e5_wall" -- 995
		}, -- 995
		{ -- 996
			x = 700, -- 996
			w = 160, -- 996
			h = 36, -- 996
			y = 0, -- 996
			label = "石台 700–860 · 高 36（可跳）", -- 996
			lanes = {"lower"}, -- 996
			art = "cover_wood" -- 996
		}, -- 996
		{ -- 997
			x = 1050, -- 997
			w = 40, -- 997
			h = 140, -- 997
			y = 0, -- 997
			label = "塔前门柱 1050", -- 997
			lanes = {"lower", "upper"}, -- 997
			art = "gate_post" -- 997
		}, -- 997
		{ -- 998
			x = 1370, -- 998
			w = 30, -- 998
			h = 200, -- 998
			y = 0, -- 998
			label = "塔前壁 1370–1400 · 高 200", -- 998
			depth = LANE_ROAD, -- 998
			art = "wall" -- 998
		} -- 998
	}, -- 998
	zones = {{ -- 1000
		x0 = 600, -- 1000
		x1 = 960, -- 1000
		y = 0, -- 1000
		h = 160, -- 1000
		tint = 4, -- 1000
		label = "塔前 600–960" -- 1000
	}}, -- 1000
	arch = { -- 1001
		x0 = 0, -- 1001
		x1 = 0, -- 1001
		y = 0, -- 1001
		h = 0, -- 1001
		label = "" -- 1001
	}, -- 1001
	stairs = {{ -- 1002
		x0 = 860, -- 1002
		x1 = 980, -- 1002
		y0 = 0, -- 1002
		y1 = 40, -- 1002
		steps = 3, -- 1002
		label = "石台斜走 860–980", -- 1002
		lanes = {"lower", "middle"} -- 1002
	}}, -- 1002
	cart = NO_CART, -- 1003
	spawns = {{ -- 1004
		x = 560, -- 1005
		y = 0, -- 1005
		h = 84, -- 1005
		depth = 32, -- 1005
		label = "火器手 560 · 中档", -- 1005
		kind = "gunner", -- 1005
		drop = "ammo" -- 1005
	}, { -- 1005
		x = 780, -- 1006
		y = 0, -- 1006
		h = 84, -- 1006
		depth = -28, -- 1006
		label = "火器手 780 · 浅档", -- 1006
		kind = "gunner", -- 1006
		drop = "ammo" -- 1006
	}, { -- 1006
		x = 980, -- 1007
		y = 0, -- 1007
		h = 84, -- 1007
		depth = 24, -- 1007
		label = "持盾手 980", -- 1007
		kind = "shield", -- 1007
		drop = "shield" -- 1007
	}}, -- 1007
	marks = {{x = 200, y = 0, kind = 3, label = "进塔前 200"}, {x = 476, y = 0, kind = 3, label = "塌墙后 476"}, {x = 960, y = 0, kind = 0, label = "塔前 960"}, {x = 1320, y = 0, kind = 0, label = "塔门 1320"}}, -- 1009
	dims = {{x0 = 320, x1 = 416, text = "塌墙 96"}, {x0 = 700, x1 = 860, text = "石台 160"}}, -- 1015
	campaign = { -- 1019
		chapter = "O", -- 1019
		act = 5, -- 1019
		budget = 240, -- 1019
		goal = "reach_exit", -- 1019
		exitX = 1320, -- 1019
		next = "tower", -- 1019
		checkpoint = 1, -- 1019
		reloadPuzzle = true -- 1019
	} -- 1019
} -- 1019
--- 男主线五段护送（escort1 / escort2 / escort4 / escort5）的种子驱动遭遇变体池：
-- - 变体 0 与房间默认 spawns 完全一致（兼容基准回放与调试夹具）；
-- - 变体 1 / 变体 2 在正式与章节男主线按 (seed, attempt, roomKey) 确定性切换敌兵编组与掉落，
--   让每轮护送与倒地重开具备真正的局内战术变化。
____exports.ESCORT_VARIANTS = {escort1 = {____exports.ESCORT1_ROOM.spawns, {{ -- 1028
	x = 760, -- 1032
	y = 0, -- 1032
	h = 84, -- 1032
	depth = 28, -- 1032
	label = "火器手 760 · 上档", -- 1032
	kind = "gunner", -- 1032
	drop = "ammo" -- 1032
}, { -- 1032
	x = 940, -- 1033
	y = 0, -- 1033
	h = 84, -- 1033
	depth = 0, -- 1033
	label = "破障手 940 · 中档", -- 1033
	kind = "breaker", -- 1033
	drop = "wedge" -- 1033
}, { -- 1033
	x = 1140, -- 1034
	y = 0, -- 1034
	h = 84, -- 1034
	depth = -24, -- 1034
	label = "火器手 1140 · 浅档", -- 1034
	kind = "gunner", -- 1034
	drop = "ammo" -- 1034
}, { -- 1034
	x = 1260, -- 1035
	y = 0, -- 1035
	h = 84, -- 1035
	depth = 24, -- 1035
	label = "破障手 1260 · 上档", -- 1035
	kind = "breaker", -- 1035
	drop = "wedge" -- 1035
}}, {{ -- 1035
	x = 800, -- 1038
	y = 0, -- 1038
	h = 84, -- 1038
	depth = 0, -- 1038
	label = "持盾手 800 · 中档", -- 1038
	kind = "shield", -- 1038
	drop = "shield" -- 1038
}, { -- 1038
	x = 1020, -- 1039
	y = 0, -- 1039
	h = 84, -- 1039
	depth = 32, -- 1039
	label = "火器手 1020 · 上档", -- 1039
	kind = "gunner", -- 1039
	drop = "ammo" -- 1039
}, { -- 1039
	x = 1180, -- 1040
	y = 0, -- 1040
	h = 84, -- 1040
	depth = -28, -- 1040
	label = "火器手 1180 · 浅档", -- 1040
	kind = "gunner", -- 1040
	drop = "ammo" -- 1040
}}}, escort2 = {____exports.ESCORT2_ROOM.spawns, {{ -- 1040
	x = 680, -- 1046
	y = 0, -- 1046
	h = 84, -- 1046
	depth = -24, -- 1046
	label = "破障手 680 · 浅档", -- 1046
	kind = "breaker", -- 1046
	drop = "wedge" -- 1046
}, { -- 1046
	x = 920, -- 1047
	y = 0, -- 1047
	h = 84, -- 1047
	depth = 32, -- 1047
	label = "火器手 920 · 上档", -- 1047
	kind = "gunner", -- 1047
	drop = "ammo" -- 1047
}, { -- 1047
	x = 1140, -- 1048
	y = 0, -- 1048
	h = 84, -- 1048
	depth = 20, -- 1048
	label = "破障手 1140 · 上档", -- 1048
	kind = "breaker", -- 1048
	drop = "wedge" -- 1048
}, { -- 1048
	x = 1260, -- 1049
	y = 0, -- 1049
	h = 84, -- 1049
	depth = -20, -- 1049
	label = "火器手 1260 · 浅档", -- 1049
	kind = "gunner", -- 1049
	drop = "ammo" -- 1049
}}, {{ -- 1049
	x = 640, -- 1052
	y = 0, -- 1052
	h = 84, -- 1052
	depth = 32, -- 1052
	label = "火器手 640 · 上档", -- 1052
	kind = "gunner", -- 1052
	drop = "ammo" -- 1052
}, { -- 1052
	x = 880, -- 1053
	y = 0, -- 1053
	h = 84, -- 1053
	depth = 0, -- 1053
	label = "持盾手 880 · 中档", -- 1053
	kind = "shield", -- 1053
	drop = "shield" -- 1053
}, { -- 1053
	x = 1140, -- 1054
	y = 0, -- 1054
	h = 84, -- 1054
	depth = -28, -- 1054
	label = "火器手 1140 · 浅档", -- 1054
	kind = "gunner", -- 1054
	drop = "ammo" -- 1054
}}}, escort4 = {____exports.ESCORT4_ROOM.spawns, {{ -- 1054
	x = 580, -- 1060
	y = 0, -- 1060
	h = 84, -- 1060
	depth = -24, -- 1060
	label = "火器手 580 · 浅档", -- 1060
	kind = "gunner", -- 1060
	drop = "ammo" -- 1060
}, { -- 1060
	x = 780, -- 1061
	y = 0, -- 1061
	h = 84, -- 1061
	depth = 16, -- 1061
	label = "破障手 780 · 中档", -- 1061
	kind = "breaker", -- 1061
	drop = "wedge" -- 1061
}, { -- 1061
	x = 980, -- 1062
	y = 0, -- 1062
	h = 84, -- 1062
	depth = -16, -- 1062
	label = "持盾手 980 · 浅档", -- 1062
	kind = "shield", -- 1062
	drop = "shield" -- 1062
}, { -- 1062
	x = 1140, -- 1063
	y = 0, -- 1063
	h = 84, -- 1063
	depth = 28, -- 1063
	label = "火器手 1140 · 上档", -- 1063
	kind = "gunner", -- 1063
	drop = "ammo" -- 1063
}}, {{ -- 1063
	x = 640, -- 1066
	y = 0, -- 1066
	h = 84, -- 1066
	depth = 16, -- 1066
	label = "持盾手 640 · 中档", -- 1066
	kind = "shield", -- 1066
	drop = "shield" -- 1066
}, { -- 1066
	x = 820, -- 1067
	y = 0, -- 1067
	h = 84, -- 1067
	depth = -28, -- 1067
	label = "火器手 820 · 浅档", -- 1067
	kind = "gunner", -- 1067
	drop = "ammo" -- 1067
}, { -- 1067
	x = 1020, -- 1068
	y = 0, -- 1068
	h = 84, -- 1068
	depth = 0, -- 1068
	label = "破障手 1020 · 中档", -- 1068
	kind = "breaker", -- 1068
	drop = "wedge" -- 1068
}, { -- 1068
	x = 1180, -- 1069
	y = 0, -- 1069
	h = 84, -- 1069
	depth = 28, -- 1069
	label = "火器手 1180 · 上档", -- 1069
	kind = "gunner", -- 1069
	drop = "ammo" -- 1069
}}}, escort5 = {____exports.ESCORT5_ROOM.spawns, {{ -- 1069
	x = 520, -- 1075
	y = 0, -- 1075
	h = 84, -- 1075
	depth = -24, -- 1075
	label = "火器手 520 · 浅档", -- 1075
	kind = "gunner", -- 1075
	drop = "ammo" -- 1075
}, { -- 1075
	x = 740, -- 1076
	y = 0, -- 1076
	h = 84, -- 1076
	depth = 16, -- 1076
	label = "持盾手 740 · 中档", -- 1076
	kind = "shield", -- 1076
	drop = "shield" -- 1076
}, { -- 1076
	x = 920, -- 1077
	y = 0, -- 1077
	h = 84, -- 1077
	depth = -20, -- 1077
	label = "破障手 920 · 浅档", -- 1077
	kind = "breaker", -- 1077
	drop = "wedge" -- 1077
}, { -- 1077
	x = 1100, -- 1078
	y = 0, -- 1078
	h = 84, -- 1078
	depth = 28, -- 1078
	label = "火器手 1100 · 上档", -- 1078
	kind = "gunner", -- 1078
	drop = "ammo" -- 1078
}}, {{ -- 1078
	x = 580, -- 1081
	y = 0, -- 1081
	h = 84, -- 1081
	depth = 0, -- 1081
	label = "持盾手 580 · 中档", -- 1081
	kind = "shield", -- 1081
	drop = "shield" -- 1081
}, { -- 1081
	x = 760, -- 1082
	y = 0, -- 1082
	h = 84, -- 1082
	depth = 32, -- 1082
	label = "火器手 760 · 上档", -- 1082
	kind = "gunner", -- 1082
	drop = "ammo" -- 1082
}, { -- 1082
	x = 940, -- 1083
	y = 0, -- 1083
	h = 84, -- 1083
	depth = -28, -- 1083
	label = "火器手 940 · 浅档", -- 1083
	kind = "gunner", -- 1083
	drop = "ammo" -- 1083
}, { -- 1083
	x = 1100, -- 1084
	y = 0, -- 1084
	h = 84, -- 1084
	depth = 16, -- 1084
	label = "持盾手 1100 · 中档", -- 1084
	kind = "shield", -- 1084
	drop = "shield" -- 1084
}}}} -- 1084
--- S1 十字街：同一个街口先教单方向火器，再让破障手从街角压近。
-- 外檐线与布行线都从这里的出口分叉；井背是退回点，窗台是可选的翻窗捷径。
____exports.S1_CROSSROAD = { -- 1093
	key = "s1-crossroad", -- 1094
	name = "S1 · 十字街", -- 1095
	caption = "井背 → 摊后窄道 → 观察转角 → 街角压近者。薄木挡与窗台分别通向 S2 的两条线。", -- 1096
	originX = 0, -- 1097
	minX = 0, -- 1098
	maxX = 1600, -- 1099
	height = 220, -- 1100
	depth = LANE_ROAD, -- 1101
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 1102
	solids = { -- 1103
		{ -- 1104
			x = 180, -- 1104
			w = 88, -- 1104
			h = 56, -- 1104
			y = 0, -- 1104
			label = "井背 180–268 · 高 56", -- 1104
			lanes = {"lower"}, -- 1104
			art = "cover_stone", -- 1104
			id = "s1_well" -- 1104
		}, -- 1104
		{ -- 1105
			x = 360, -- 1105
			w = 160, -- 1105
			h = 44, -- 1105
			y = 0, -- 1105
			label = "摊后柜台 360–520 · 高 44", -- 1105
			lanes = {"lower", "middle"}, -- 1105
			art = "cover_wood" -- 1105
		}, -- 1105
		{ -- 1106
			x = 620, -- 1106
			w = 44, -- 1106
			h = 24, -- 1106
			y = 0, -- 1106
			label = "观察转角石基 620–664 · 高 24", -- 1106
			lanes = {"lower"}, -- 1106
			art = "cover_stone" -- 1106
		}, -- 1106
		{ -- 1107
			x = 1130, -- 1107
			w = 20, -- 1107
			h = 120, -- 1107
			y = 0, -- 1107
			label = "窗柱左", -- 1107
			lanes = {"upper"}, -- 1107
			art = "wall" -- 1107
		}, -- 1107
		{ -- 1108
			x = 1150, -- 1108
			w = 80, -- 1108
			h = 44, -- 1108
			y = 0, -- 1108
			label = "窗台 1150–1230 · 高 44", -- 1108
			lanes = {"upper"}, -- 1108
			art = "cover_wood" -- 1108
		}, -- 1108
		{ -- 1109
			x = 1230, -- 1109
			w = 20, -- 1109
			h = 120, -- 1109
			y = 0, -- 1109
			label = "窗柱右", -- 1109
			lanes = {"upper"}, -- 1109
			art = "wall" -- 1109
		}, -- 1109
		{ -- 1110
			x = 1460, -- 1110
			w = 40, -- 1110
			h = 140, -- 1110
			y = 0, -- 1110
			label = "街尾门柱", -- 1110
			lanes = {"lower", "upper"}, -- 1110
			art = "gate_post" -- 1110
		} -- 1110
	}, -- 1110
	zones = {{ -- 1112
		x0 = 700, -- 1112
		x1 = 960, -- 1112
		y = 0, -- 1112
		h = 150, -- 1112
		tint = 1, -- 1112
		label = "街角交火 700–960" -- 1112
	}}, -- 1112
	arch = { -- 1113
		x0 = 0, -- 1113
		x1 = 0, -- 1113
		y = 0, -- 1113
		h = 0, -- 1113
		label = "" -- 1113
	}, -- 1113
	stairs = {{ -- 1114
		x0 = 900, -- 1114
		x1 = 1040, -- 1114
		y0 = 0, -- 1114
		y1 = 40, -- 1114
		steps = 4, -- 1114
		label = "石基斜走 900–1040 · 高 40", -- 1114
		lanes = {"lower", "middle"} -- 1114
	}}, -- 1114
	cart = NO_CART, -- 1115
	spawns = {{ -- 1116
		x = 760, -- 1117
		y = 0, -- 1117
		h = 84, -- 1117
		depth = 32, -- 1117
		label = "单方向火器手 760", -- 1117
		kind = "gunner", -- 1117
		drop = "ammo" -- 1117
	}, { -- 1117
		x = 880, -- 1118
		y = 0, -- 1118
		h = 84, -- 1118
		label = "街角压近者 880", -- 1118
		kind = "breaker", -- 1118
		drop = "wedge" -- 1118
	}}, -- 1118
	marks = {{x = 220, y = 0, kind = 1, label = "井背安全点 220"}, {x = 640, y = 0, kind = 0, label = "观察转角 640"}, {x = 1190, y = 0, kind = 0, label = "窗台捷径 1190"}, {x = 1500, y = 0, kind = 0, label = "出口 1500"}}, -- 1120
	dims = {{x0 = 180, x1 = 268, text = "井 88"}, {x0 = 360, x1 = 520, text = "柜台 160"}, {x0 = 900, x1 = 1040, text = "石基 140"}}, -- 1126
	companion = {waitX = 220, waitDepth = -32, joinX = 900}, -- 1131
	campaign = { -- 1132
		chapter = "S", -- 1132
		act = 1, -- 1132
		budget = 210, -- 1132
		goal = "reach_exit", -- 1132
		next = "s2-drygoods", -- 1132
		exitX = 1500, -- 1132
		checkpoint = 1 -- 1132
	} -- 1132
} -- 1132
--- S2 布行与外檐：近檐柱下短跨、可碎摊挡与转角装卸面是一条线；
-- 从染布架侧面进布行、绕柜到窗板背后放板、后仓折回是另一条线。两条线同通牌楼。
____exports.S2_DRYGOODS = { -- 1139
	key = "s2-drygoods", -- 1140
	name = "S2 · 布行与外檐", -- 1141
	caption = "近檐：檐柱短跨、薄木摊挡、装卸面。远帘：染布架入内、绕柜、放窗板、后仓折回。两路同通牌楼。", -- 1142
	originX = 1600, -- 1143
	minX = 0, -- 1144
	maxX = 1800, -- 1145
	height = 230, -- 1146
	depth = LANE_ROAD, -- 1147
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 1148
	pickups = {{ -- 1149
		id = "s2_scrap_1", -- 1150
		kind = "scrap", -- 1150
		x = 520, -- 1150
		y = 0, -- 1150
		depth = 0, -- 1150
		label = "废木料 · 薄木摊挡脚下" -- 1150
	}, { -- 1150
		id = "s2_scrap_2", -- 1151
		kind = "scrap", -- 1151
		x = 760, -- 1151
		y = 0, -- 1151
		depth = 0, -- 1151
		label = "废木料 · 装卸面旁" -- 1151
	}}, -- 1151
	solids = { -- 1153
		{ -- 1154
			x = 100, -- 1154
			w = 24, -- 1154
			h = 130, -- 1154
			y = 0, -- 1154
			label = "檐柱 100", -- 1154
			lanes = {"middle"}, -- 1154
			art = "cover_wood" -- 1154
		}, -- 1154
		{ -- 1155
			x = 240, -- 1155
			w = 24, -- 1155
			h = 130, -- 1155
			y = 0, -- 1155
			label = "檐柱 240", -- 1155
			lanes = {"middle"}, -- 1155
			art = "cover_wood" -- 1155
		}, -- 1155
		{ -- 1156
			x = 460, -- 1157
			w = 100, -- 1157
			h = 48, -- 1157
			y = 0, -- 1157
			label = "薄木摊挡 460–560 · 高 48", -- 1157
			lanes = {"middle", "upper"}, -- 1157
			art = "thin_wood", -- 1158
			id = "s2_wood", -- 1158
			breakable = {kind = "thin_wood", hp = 2, wedgeHp = 1} -- 1158
		}, -- 1158
		{ -- 1160
			x = 560, -- 1160
			w = 36, -- 1160
			h = 130, -- 1160
			y = 0, -- 1160
			label = "永久石柱 560–596", -- 1160
			lanes = {"upper"}, -- 1160
			art = "cover_stone" -- 1160
		}, -- 1160
		{ -- 1161
			x = 700, -- 1161
			w = 120, -- 1161
			h = 32, -- 1161
			y = 0, -- 1161
			label = "转角装卸面 700–820 · 高 32", -- 1161
			lanes = {"middle"}, -- 1161
			art = "cover_stone" -- 1161
		}, -- 1161
		{ -- 1162
			x = 340, -- 1162
			w = 120, -- 1162
			h = 44, -- 1162
			y = 0, -- 1162
			label = "布行柜台 340–460 · 高 44", -- 1162
			lanes = {"upper"}, -- 1162
			art = "cover_wood" -- 1162
		}, -- 1162
		{ -- 1163
			x = 600, -- 1164
			w = 80, -- 1164
			h = 72, -- 1164
			y = 0, -- 1164
			label = "窗板背后 600–680", -- 1164
			lanes = {"upper"}, -- 1164
			art = "board", -- 1165
			id = "s2_board", -- 1165
			interact = {kind = "open_board", reach = 46} -- 1165
		}, -- 1165
		{ -- 1167
			x = 600, -- 1168
			w = 80, -- 1168
			h = 40, -- 1168
			y = 0, -- 1168
			label = "放下的窗板 600–680", -- 1168
			lanes = {"lower"}, -- 1168
			art = "board", -- 1169
			id = "s2_board_cover", -- 1169
			soft = true, -- 1169
			hidden = true -- 1169
		}, -- 1169
		{ -- 1171
			x = 1560, -- 1171
			w = 30, -- 1171
			h = 150, -- 1171
			y = 0, -- 1171
			label = "牌楼左柱", -- 1171
			lanes = {"lower", "upper"}, -- 1171
			art = "gate_post" -- 1171
		}, -- 1171
		{ -- 1172
			x = 1700, -- 1172
			w = 30, -- 1172
			h = 150, -- 1172
			y = 0, -- 1172
			label = "牌楼右柱", -- 1172
			lanes = {"lower", "upper"}, -- 1172
			art = "gate_post" -- 1172
		} -- 1172
	}, -- 1172
	zones = {{ -- 1174
		x0 = 640, -- 1174
		x1 = 1300, -- 1174
		y = 0, -- 1174
		h = 150, -- 1174
		tint = 1, -- 1174
		label = "转角装卸面交火 700–1200" -- 1174
	}}, -- 1174
	arch = { -- 1175
		x0 = 0, -- 1175
		x1 = 0, -- 1175
		y = 0, -- 1175
		h = 0, -- 1175
		label = "" -- 1175
	}, -- 1175
	stairs = {}, -- 1176
	cart = NO_CART, -- 1177
	spawns = {{ -- 1178
		x = 940, -- 1179
		y = 0, -- 1179
		h = 84, -- 1179
		depth = 0, -- 1179
		label = "持盾手 940", -- 1179
		kind = "shield", -- 1179
		shieldHp = 2, -- 1179
		drop = "shield" -- 1179
	}, { -- 1179
		x = 1060, -- 1180
		y = 0, -- 1180
		h = 84, -- 1180
		depth = 32, -- 1180
		label = "远侧火器手 1060", -- 1180
		kind = "gunner", -- 1180
		drop = "ammo" -- 1180
	}, { -- 1180
		x = 1140, -- 1181
		y = 0, -- 1181
		h = 84, -- 1181
		depth = 0, -- 1181
		label = "破障手 1140", -- 1181
		kind = "breaker", -- 1181
		drop = "wedge" -- 1181
	}}, -- 1181
	marks = {{x = 640, y = 0, kind = 1, label = "窗板后等待位 640"}, {x = 900, y = 0, kind = 0, label = "后仓汇合口 900"}, {x = 1740, y = 0, kind = 0, label = "牌楼出口 1740"}}, -- 1183
	dims = {{x0 = 100, x1 = 124, text = "檐柱 24"}, {x0 = 460, x1 = 560, text = "摊挡 100"}, {x0 = 700, x1 = 820, text = "装卸面 120"}}, -- 1188
	companion = {waitX = 640, waitDepth = 32, joinX = 900, followAfter = "open_board"}, -- 1193
	campaign = { -- 1194
		chapter = "S", -- 1194
		act = 2, -- 1194
		budget = 390, -- 1194
		goal = "reach_exit", -- 1194
		next = "s3-archway", -- 1194
		exitX = 1740, -- 1194
		checkpoint = 2 -- 1194
	} -- 1194
} -- 1194
--- S3 牌楼后巷：外檐线从低处进、布行线从高处进，两条入口在墙脚汇合。
-- 装卸坡可先上去看同一堆粮袋的敌位，再退半层接小满；也可以沿墙脚直接绕。
____exports.S3_ARCHWAY = { -- 1201
	key = "s3-archway", -- 1202
	name = "S3 · 牌楼后巷", -- 1203
	caption = "两高度入口看同一粮袋。登装卸坡看敌位再退半层接人，或沿墙脚绕走；候检门前两人停。", -- 1204
	originX = 3400, -- 1205
	minX = 0, -- 1206
	maxX = 1400, -- 1207
	height = 230, -- 1208
	depth = LANE_ROAD, -- 1209
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 1210
	solids = { -- 1211
		{ -- 1212
			x = 0, -- 1212
			w = 180, -- 1212
			h = 32, -- 1212
			y = 0, -- 1212
			label = "高处进口台 0–180 · 高 32", -- 1212
			lanes = {"upper"}, -- 1212
			art = "cover_stone" -- 1212
		}, -- 1212
		{ -- 1213
			x = 380, -- 1213
			w = 140, -- 1213
			h = 64, -- 1213
			y = 0, -- 1213
			label = "装卸石台 380–520 · 高 64", -- 1213
			lanes = {"upper"}, -- 1213
			art = "cover_stone" -- 1213
		}, -- 1213
		{ -- 1214
			x = 560, -- 1214
			w = 160, -- 1214
			h = 48, -- 1214
			y = 0, -- 1214
			label = "粮袋堆 560–720 · 高 48", -- 1214
			lanes = {"lower", "middle"}, -- 1214
			art = "grain_sack" -- 1214
		}, -- 1214
		{ -- 1215
			x = 1260, -- 1215
			w = 30, -- 1215
			h = 140, -- 1215
			y = 0, -- 1215
			label = "候检门左柱", -- 1215
			lanes = {"lower", "upper"}, -- 1215
			art = "gate_post" -- 1215
		}, -- 1215
		{ -- 1216
			x = 1330, -- 1216
			w = 30, -- 1216
			h = 140, -- 1216
			y = 0, -- 1216
			label = "候检门右柱", -- 1216
			lanes = {"lower", "upper"}, -- 1216
			art = "gate_post" -- 1216
		} -- 1216
	}, -- 1216
	zones = {{ -- 1218
		x0 = 780, -- 1218
		x1 = 1060, -- 1218
		y = 0, -- 1218
		h = 150, -- 1218
		tint = 1, -- 1218
		label = "后巷交火 780–1060" -- 1218
	}}, -- 1218
	arch = { -- 1219
		x0 = 0, -- 1219
		x1 = 0, -- 1219
		y = 0, -- 1219
		h = 0, -- 1219
		label = "" -- 1219
	}, -- 1219
	stairs = {{ -- 1220
		x0 = 140, -- 1221
		x1 = 200, -- 1221
		y0 = 0, -- 1221
		y1 = 32, -- 1221
		steps = 3, -- 1221
		label = "进口台阶", -- 1221
		lanes = {"upper"} -- 1221
	}, { -- 1221
		x0 = 260, -- 1222
		x1 = 380, -- 1222
		y0 = 0, -- 1222
		y1 = 64, -- 1222
		steps = 4, -- 1222
		label = "装卸坡 260–380 · 高 64", -- 1222
		lanes = {"upper"} -- 1222
	}}, -- 1222
	cart = NO_CART, -- 1224
	spawns = {{ -- 1225
		x = 860, -- 1226
		y = 0, -- 1226
		h = 84, -- 1226
		depth = 32, -- 1226
		label = "高处火器手 860", -- 1226
		kind = "gunner", -- 1226
		drop = "ammo" -- 1226
	}, { -- 1226
		x = 980, -- 1227
		y = 0, -- 1227
		h = 84, -- 1227
		depth = 0, -- 1227
		label = "墙脚火器手 980", -- 1227
		kind = "gunner", -- 1227
		drop = "ammo" -- 1227
	}}, -- 1227
	marks = {{x = 440, y = 0, kind = 0, label = "装卸坡观察位 440"}, {x = 620, y = 0, kind = 1, label = "粮袋后安全点 620"}, {x = 1300, y = 0, kind = 0, label = "候检门前 1300"}}, -- 1229
	dims = {{x0 = 260, x1 = 380, text = "装卸坡 120"}, {x0 = 560, x1 = 720, text = "粮袋 160"}}, -- 1234
	companion = {waitX = 620, waitDepth = 0, joinX = 1240}, -- 1235
	campaign = { -- 1236
		chapter = "S", -- 1236
		act = 3, -- 1236
		budget = 180, -- 1236
		goal = "reach_exit", -- 1236
		next = "c1-yard", -- 1236
		exitX = 1320, -- 1236
		checkpoint = 3 -- 1236
	} -- 1236
} -- 1236
--- C1 候检院：侧门横闩在门背，粮棚可见但被队栏、查验台与棚柱交错挡住。
-- 绕缺口进栏，截断压近者或穿查验台后到棚口；正面看门，转到背面才抬得动闩。
____exports.C1_YARD = { -- 1243
	key = "c1-yard", -- 1244
	name = "C1 · 候检院", -- 1245
	caption = "队栏与查验台把粮棚切成几段。绕缺口进栏，压近者会截断通路；侧门横闩要转到门背才抬得动。", -- 1246
	originX = 4800, -- 1247
	minX = 0, -- 1248
	maxX = 1900, -- 1249
	height = 240, -- 1250
	depth = LANE_ROAD, -- 1251
	floors = {{y = 0, x0 = 0, x1 = 1900}}, -- 1252
	solids = { -- 1253
		{ -- 1254
			x = 280, -- 1254
			w = 340, -- 1254
			h = 28, -- 1254
			y = 0, -- 1254
			label = "候检队栏 280–620 · 高 28", -- 1254
			lanes = {"lower", "middle"}, -- 1254
			art = "fence" -- 1254
		}, -- 1254
		{ -- 1255
			x = 820, -- 1255
			w = 180, -- 1255
			h = 44, -- 1255
			y = 0, -- 1255
			label = "查验台 820–1000 · 高 44", -- 1255
			lanes = {"lower", "middle"}, -- 1255
			art = "cover_wood" -- 1255
		}, -- 1255
		{ -- 1256
			x = 1100, -- 1256
			w = 40, -- 1256
			h = 150, -- 1256
			y = 0, -- 1256
			label = "棚柱 1100–1140", -- 1256
			lanes = {"lower", "middle"}, -- 1256
			art = "cover_wood" -- 1256
		}, -- 1256
		{ -- 1257
			x = 1240, -- 1257
			w = 40, -- 1257
			h = 150, -- 1257
			y = 0, -- 1257
			label = "棚柱 1240–1280", -- 1257
			lanes = {"lower", "middle"}, -- 1257
			art = "cover_wood" -- 1257
		}, -- 1257
		{ -- 1258
			x = 1600, -- 1258
			w = 160, -- 1258
			h = 48, -- 1258
			y = 0, -- 1258
			label = "粮棚袋堆 1600–1760 · 高 48", -- 1258
			lanes = {"lower", "middle"}, -- 1258
			art = "grain_sack" -- 1258
		}, -- 1258
		{ -- 1259
			x = 1780, -- 1259
			w = 50, -- 1259
			h = 150, -- 1259
			y = 0, -- 1259
			label = "侧门 1780–1830", -- 1259
			depth = LANE_ROAD, -- 1259
			art = "wall", -- 1259
			id = "c1_door" -- 1259
		}, -- 1259
		{ -- 1260
			x = 1755, -- 1261
			w = 30, -- 1261
			h = 24, -- 1261
			y = 40, -- 1261
			label = "侧门横闩（门框上侧）", -- 1261
			lanes = {"upper"}, -- 1261
			art = "latch", -- 1262
			id = "c1_latch", -- 1262
			interact = {kind = "raise_latch", reach = 56} -- 1262
		} -- 1262
	}, -- 1262
	zones = {{ -- 1265
		x0 = 760, -- 1265
		x1 = 1080, -- 1265
		y = 0, -- 1265
		h = 150, -- 1265
		tint = 1, -- 1265
		label = "查验台截断 820–1000" -- 1265
	}}, -- 1265
	arch = { -- 1266
		x0 = 0, -- 1266
		x1 = 0, -- 1266
		y = 0, -- 1266
		h = 0, -- 1266
		label = "" -- 1266
	}, -- 1266
	stairs = {}, -- 1267
	cart = NO_CART, -- 1268
	spawns = {{ -- 1269
		x = 900, -- 1270
		y = 0, -- 1270
		h = 84, -- 1270
		depth = 0, -- 1270
		label = "截断压近者 900", -- 1270
		kind = "breaker", -- 1270
		drop = "wedge" -- 1270
	}, { -- 1270
		x = 1200, -- 1271
		y = 0, -- 1271
		h = 84, -- 1271
		depth = 32, -- 1271
		label = "棚柱后火器手 1200", -- 1271
		kind = "gunner", -- 1271
		drop = "ammo" -- 1271
	}}, -- 1271
	marks = {{x = 1000, y = 0, kind = 1, label = "查验台后等待位 1000"}, {x = 1700, y = 0, kind = 0, label = "侧门正面 1700"}, {x = 1860, y = 0, kind = 0, label = "门背出口 1860"}}, -- 1273
	dims = {{x0 = 820, x1 = 1000, text = "查验台 180"}, {x0 = 1780, x1 = 1830, text = "侧门 50"}}, -- 1278
	companion = {waitX = 1000, waitDepth = 0, joinX = 1700, followAfter = "raise_latch"}, -- 1279
	campaign = { -- 1280
		chapter = "C", -- 1280
		act = 1, -- 1280
		budget = 270, -- 1280
		goal = "raise_latch", -- 1280
		next = "c2-granary", -- 1280
		exitX = 1860, -- 1280
		checkpoint = 4 -- 1280
	} -- 1280
} -- 1280
--- C2 军粮棚：粮袋安全区居中，远柱木帘与近侧车轨分列。
-- 有残盾可以在暴露轨段架起来挡一发；空手路线先绕上远柱放帘，再回来握车柄。
____exports.C2_GRANARY = { -- 1287
	key = "c2-granary", -- 1288
	name = "C2 · 军粮棚", -- 1289
	caption = "空筐围挡、暴露轨段与远柱木帘。先绕上远柱放帘，或架残盾，再握车柄把车推入轮窝并抬连杆闩。", -- 1290
	originX = 6700, -- 1291
	minX = 0, -- 1292
	maxX = 1800, -- 1293
	height = 240, -- 1294
	depth = LANE_ROAD, -- 1295
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 1296
	solids = { -- 1297
		{ -- 1298
			x = 900, -- 1299
			w = 76, -- 1299
			h = 44, -- 1299
			y = 0, -- 1299
			label = "空筐围挡 900–976 · 高 44", -- 1299
			lanes = {"lower", "middle"}, -- 1299
			art = "basket_wall", -- 1300
			id = "c2_basket", -- 1300
			breakable = {kind = "basket_wall", hp = 2, wedgeable = false} -- 1300
		}, -- 1300
		{ -- 1302
			x = 600, -- 1302
			w = 300, -- 1302
			h = 48, -- 1302
			y = 0, -- 1302
			label = "粮袋安全区 600–900 · 高 48", -- 1302
			lanes = {"lower", "middle"}, -- 1302
			art = "grain_sack" -- 1302
		}, -- 1302
		{ -- 1303
			x = 980, -- 1303
			w = 40, -- 1303
			h = 24, -- 1303
			y = 0, -- 1303
			label = "棚口下轨台 980–1020 · 高 24", -- 1303
			lanes = {"lower", "middle"}, -- 1303
			art = "cover_stone" -- 1303
		}, -- 1303
		{ -- 1304
			x = 1200, -- 1305
			w = 40, -- 1305
			h = 150, -- 1305
			y = 0, -- 1305
			label = "远柱 1200–1240 · 高 150", -- 1305
			lanes = {"upper"}, -- 1305
			art = "cover_wood", -- 1306
			id = "c2_post", -- 1306
			interact = {kind = "lower_curtain", reach = 46} -- 1306
		}, -- 1306
		{ -- 1308
			x = 1240, -- 1309
			w = 120, -- 1309
			h = 120, -- 1309
			y = 24, -- 1309
			label = "木帘落点 1240–1360", -- 1309
			lanes = {"lower", "middle"}, -- 1309
			art = "curtain", -- 1310
			soft = true, -- 1310
			id = "c2_curtain", -- 1310
			hidden = true -- 1310
		}, -- 1310
		{ -- 1312
			x = 1560, -- 1313
			w = 30, -- 1313
			h = 24, -- 1313
			y = 40, -- 1313
			label = "连杆抬闩 1560–1590", -- 1313
			lanes = {"middle"}, -- 1313
			art = "latch", -- 1314
			id = "c2_latch", -- 1314
			interact = {kind = "raise_latch", reach = 50} -- 1314
		}, -- 1314
		{ -- 1316
			x = 1720, -- 1316
			w = 30, -- 1316
			h = 150, -- 1316
			y = 0, -- 1316
			label = "棚尾门柱", -- 1316
			lanes = {"lower", "upper"}, -- 1316
			art = "gate_post" -- 1316
		} -- 1316
	}, -- 1316
	zones = {{ -- 1318
		x0 = 1000, -- 1318
		x1 = 1200, -- 1318
		y = 0, -- 1318
		h = 150, -- 1318
		tint = 1, -- 1318
		label = "暴露轨段 1000–1200" -- 1318
	}}, -- 1318
	arch = { -- 1319
		x0 = 0, -- 1319
		x1 = 0, -- 1319
		y = 0, -- 1319
		h = 0, -- 1319
		label = "" -- 1319
	}, -- 1319
	stairs = {}, -- 1320
	cart = { -- 1321
		startX = 1150, -- 1322
		endX = 1500, -- 1322
		baseY = 0, -- 1322
		depth = 0, -- 1322
		bodyW = 48, -- 1322
		bodyH = 26, -- 1322
		wheelR = 12, -- 1322
		handleOffset = -50, -- 1322
		clothSide = -1 -- 1322
	}, -- 1322
	spawns = {{ -- 1324
		x = 1580, -- 1325
		y = 0, -- 1325
		h = 84, -- 1325
		depth = 0, -- 1325
		label = "棚尾火器手 1580", -- 1325
		kind = "gunner", -- 1325
		drop = "ammo" -- 1325
	}, { -- 1325
		x = 1340, -- 1326
		y = 0, -- 1326
		h = 84, -- 1326
		depth = 32, -- 1326
		label = "远侧持盾手 1340", -- 1326
		kind = "shield", -- 1326
		shieldHp = 2, -- 1326
		drop = "shield" -- 1326
	}}, -- 1326
	marks = {{x = 760, y = 0, kind = 1, label = "袋堆后等待位 760"}, {x = 1100, y = 0, kind = 0, label = "车柄 1100"}, {x = 1500, y = 0, kind = 0, label = "轮窝 1500"}, {x = 1700, y = 0, kind = 0, label = "棚尾出口 1700"}}, -- 1328
	dims = {{x0 = 1150, x1 = 1500, text = "推车 350"}, {x0 = 1240, x1 = 1360, text = "木帘 120"}}, -- 1334
	companion = {waitX = 760, waitDepth = LANE_DEPTH.upper, joinX = 1700, groundBypass = {x0 = 600, x1 = 1020}}, -- 1335
	campaign = { -- 1336
		chapter = "C", -- 1336
		act = 2, -- 1336
		budget = 360, -- 1336
		goal = "dock_cart", -- 1336
		exitX = 1700, -- 1336
		checkpoint = 5 -- 1336
	} -- 1336
} -- 1336
____exports.CAMPAIGN_ROOMS = { -- 1339
	____exports.S1_CROSSROAD, -- 1339
	____exports.S2_DRYGOODS, -- 1339
	____exports.S3_ARCHWAY, -- 1339
	____exports.C1_YARD, -- 1339
	____exports.C2_GRANARY -- 1339
} -- 1339
____exports.ROOMS = { -- 1347
	____exports.PROLOGUE_ROOM, -- 1347
	____exports.STREET_ROOM, -- 1347
	____exports.S1_CROSSROAD, -- 1347
	____exports.S2_DRYGOODS, -- 1347
	____exports.S3_ARCHWAY, -- 1347
	____exports.C1_YARD, -- 1347
	____exports.C2_GRANARY, -- 1347
	____exports.CHECKPOINT_ROOM, -- 1347
	____exports.GATE_ROOM, -- 1347
	____exports.GATE_PATH_ROOM, -- 1347
	____exports.ESCORT1_ROOM, -- 1347
	____exports.ESCORT2_ROOM, -- 1347
	____exports.ESCORT3_ROOM, -- 1347
	____exports.ESCORT4_ROOM, -- 1347
	____exports.ESCORT5_ROOM, -- 1347
	____exports.OUTSIDE_ROOM, -- 1347
	____exports.VILLAGE_ROOM, -- 1347
	____exports.FOREST_ROOM, -- 1347
	____exports.TOWER_ROOM, -- 1347
	____exports.MUSEUM_ROOM -- 1347
} -- 1347
local function placeSolids(room) -- 1370
	local blocks = {} -- 1371
	for ____, solid in ipairs(room.solids) do -- 1372
		local x = solid.x + room.originX -- 1373
		if room.depth ~= nil and solid.lanes ~= nil then -- 1373
			for ____, depth in ipairs(laneFootprints(solid.lanes)) do -- 1375
				blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x, depth = depth, lanes = nil}) -- 1376
			end -- 1376
		else -- 1376
			blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x}) -- 1379
		end -- 1379
	end -- 1379
	return blocks -- 1382
end -- 1370
local function placeStairs(room) -- 1385
	local out = {} -- 1386
	for ____, stair in ipairs(room.stairs) do -- 1387
		local x0 = stair.x0 + room.originX -- 1388
		local x1 = stair.x1 + room.originX -- 1389
		if room.depth ~= nil and stair.lanes ~= nil then -- 1389
			for ____, depth in ipairs(laneFootprints(stair.lanes)) do -- 1391
				out[#out + 1] = __TS__ObjectAssign({}, stair, {x0 = x0, x1 = x1, depth = depth, lanes = nil}) -- 1392
			end -- 1392
		else -- 1392
			out[#out + 1] = __TS__ObjectAssign({}, stair, {x0 = x0, x1 = x1}) -- 1395
		end -- 1395
	end -- 1395
	return out -- 1398
end -- 1385
--- 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
-- 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
function ____exports.withOrigin(room) -- 1405
	local ox = room.originX -- 1406
	if ox == 0 then -- 1406
		return room.depth == nil and room or __TS__ObjectAssign( -- 1408
			{}, -- 1408
			room, -- 1408
			{ -- 1408
				solids = placeSolids(room), -- 1408
				stairs = placeStairs(room) -- 1408
			} -- 1408
		) -- 1408
	end -- 1408
	local function shift(x) -- 1410
		return x + ox -- 1410
	end -- 1410
	local ____room_key_13 = room.key -- 1412
	local ____room_name_14 = room.name -- 1413
	local ____room_caption_15 = room.caption -- 1414
	local ____shift_result_16 = shift(room.minX) -- 1416
	local ____shift_result_17 = shift(room.maxX) -- 1417
	local ____room_height_18 = room.height -- 1418
	local ____room_depth_19 = room.depth -- 1419
	local ____TS__ArrayMap_result_20 = __TS__ArrayMap( -- 1420
		room.floors, -- 1420
		function(____, f) return { -- 1420
			y = f.y, -- 1420
			x0 = shift(f.x0), -- 1420
			x1 = shift(f.x1) -- 1420
		} end -- 1420
	) -- 1420
	local ____placeSolids_result_21 = placeSolids(room) -- 1421
	local ____TS__ArrayMap_result_22 = __TS__ArrayMap( -- 1422
		room.zones, -- 1422
		function(____, z) return { -- 1422
			x0 = shift(z.x0), -- 1422
			x1 = shift(z.x1), -- 1422
			y = z.y, -- 1422
			h = z.h, -- 1422
			tint = z.tint, -- 1422
			label = z.label -- 1422
		} end -- 1422
	) -- 1422
	local ____temp_23 = { -- 1423
		x0 = shift(room.arch.x0), -- 1423
		x1 = shift(room.arch.x1), -- 1423
		y = room.arch.y, -- 1423
		h = room.arch.h, -- 1423
		label = room.arch.label -- 1423
	} -- 1423
	local ____placeStairs_result_24 = placeStairs(room) -- 1424
	local ____TS__ObjectAssign_result_25 = __TS__ObjectAssign( -- 1425
		{}, -- 1425
		room.cart, -- 1426
		{ -- 1425
			startX = shift(room.cart.startX), -- 1427
			endX = shift(room.cart.endX) -- 1428
		} -- 1428
	) -- 1428
	local ____TS__ArrayMap_result_26 = __TS__ArrayMap( -- 1430
		room.spawns, -- 1430
		function(____, s) return __TS__ObjectAssign( -- 1430
			{}, -- 1430
			s, -- 1430
			{x = shift(s.x)} -- 1430
		) end -- 1430
	) -- 1430
	local ____TS__ArrayMap_result_27 = __TS__ArrayMap( -- 1431
		room.marks, -- 1431
		function(____, m) return { -- 1431
			x = shift(m.x), -- 1431
			y = m.y, -- 1431
			kind = m.kind, -- 1431
			label = m.label -- 1431
		} end -- 1431
	) -- 1431
	local ____TS__ArrayMap_result_28 = __TS__ArrayMap( -- 1432
		room.dims, -- 1432
		function(____, d) return { -- 1432
			x0 = shift(d.x0), -- 1432
			x1 = shift(d.x1), -- 1432
			text = d.text -- 1432
		} end -- 1432
	) -- 1432
	local ____temp_0 -- 1433
	if room.scavenger == nil then -- 1433
		____temp_0 = nil -- 1433
	else -- 1433
		____temp_0 = { -- 1433
			x0 = shift(room.scavenger.x0), -- 1434
			x1 = shift(room.scavenger.x1), -- 1434
			y = room.scavenger.y, -- 1434
			h = room.scavenger.h, -- 1434
			patrolSpeed = room.scavenger.patrolSpeed, -- 1435
			approachSpeed = room.scavenger.approachSpeed, -- 1435
			hearTicks = room.scavenger.hearTicks, -- 1436
			stallTicks = room.scavenger.stallTicks, -- 1436
			range = room.scavenger.range -- 1436
		} -- 1436
	end -- 1436
	local ____temp_1 -- 1438
	if room.bottle == nil then -- 1438
		____temp_1 = nil -- 1438
	else -- 1438
		____temp_1 = { -- 1438
			x = shift(room.bottle.x), -- 1438
			y = room.bottle.y -- 1438
		} -- 1438
	end -- 1438
	local ____temp_2 -- 1439
	if room.brickX == nil then -- 1439
		____temp_2 = nil -- 1439
	else -- 1439
		____temp_2 = shift(room.brickX) -- 1439
	end -- 1439
	local ____temp_3 -- 1440
	if room.basinX == nil then -- 1440
		____temp_3 = nil -- 1440
	else -- 1440
		____temp_3 = shift(room.basinX) -- 1440
	end -- 1440
	local ____temp_4 -- 1441
	if room.softX == nil then -- 1441
		____temp_4 = nil -- 1441
	else -- 1441
		____temp_4 = shift(room.softX) -- 1441
	end -- 1441
	local ____temp_5 -- 1442
	if room.passLine == nil then -- 1442
		____temp_5 = nil -- 1442
	else -- 1442
		____temp_5 = shift(room.passLine) -- 1442
	end -- 1442
	local ____temp_6 -- 1443
	if room.campaign == nil then -- 1443
		____temp_6 = nil -- 1443
	else -- 1443
		____temp_6 = __TS__ObjectAssign( -- 1443
			{}, -- 1443
			room.campaign, -- 1443
			{exitX = shift(room.campaign.exitX)} -- 1443
		) -- 1443
	end -- 1443
	local ____temp_7 -- 1444
	if room.pickups == nil then -- 1444
		____temp_7 = nil -- 1444
	else -- 1444
		____temp_7 = __TS__ArrayMap( -- 1444
			room.pickups, -- 1444
			function(____, p) return __TS__ObjectAssign( -- 1444
				{}, -- 1444
				p, -- 1444
				{x = shift(p.x)} -- 1444
			) end -- 1444
		) -- 1444
	end -- 1444
	local ____temp_12 -- 1445
	if room.companion == nil then -- 1445
		____temp_12 = nil -- 1445
	else -- 1445
		local ____room_companion_11 = room.companion -- 1446
		local ____temp_8 -- 1447
		if room.companion.waitX == nil then -- 1447
			____temp_8 = nil -- 1447
		else -- 1447
			____temp_8 = shift(room.companion.waitX) -- 1447
		end -- 1447
		local ____temp_9 -- 1448
		if room.companion.joinX == nil then -- 1448
			____temp_9 = nil -- 1448
		else -- 1448
			____temp_9 = shift(room.companion.joinX) -- 1448
		end -- 1448
		local ____temp_10 -- 1449
		if room.companion.groundBypass == nil then -- 1449
			____temp_10 = nil -- 1449
		else -- 1449
			____temp_10 = { -- 1449
				x0 = shift(room.companion.groundBypass.x0), -- 1450
				x1 = shift(room.companion.groundBypass.x1) -- 1450
			} -- 1450
		end -- 1450
		____temp_12 = __TS__ObjectAssign({}, ____room_companion_11, {waitX = ____temp_8, joinX = ____temp_9, groundBypass = ____temp_10}) -- 1445
	end -- 1445
	return { -- 1411
		key = ____room_key_13, -- 1412
		name = ____room_name_14, -- 1413
		caption = ____room_caption_15, -- 1414
		originX = 0, -- 1415
		minX = ____shift_result_16, -- 1416
		maxX = ____shift_result_17, -- 1417
		height = ____room_height_18, -- 1418
		depth = ____room_depth_19, -- 1419
		floors = ____TS__ArrayMap_result_20, -- 1420
		solids = ____placeSolids_result_21, -- 1421
		zones = ____TS__ArrayMap_result_22, -- 1422
		arch = ____temp_23, -- 1423
		stairs = ____placeStairs_result_24, -- 1424
		cart = ____TS__ObjectAssign_result_25, -- 1425
		spawns = ____TS__ArrayMap_result_26, -- 1430
		marks = ____TS__ArrayMap_result_27, -- 1431
		dims = ____TS__ArrayMap_result_28, -- 1432
		scavenger = ____temp_0, -- 1433
		bottle = ____temp_1, -- 1438
		brickX = ____temp_2, -- 1439
		basinX = ____temp_3, -- 1440
		softX = ____temp_4, -- 1441
		passLine = ____temp_5, -- 1442
		campaign = ____temp_6, -- 1443
		pickups = ____temp_7, -- 1444
		companion = ____temp_12, -- 1445
		story = shiftStory(room.story, ox) -- 1453
	} -- 1453
end -- 1405
return ____exports -- 1405