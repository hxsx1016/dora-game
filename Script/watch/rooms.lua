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
____exports.CHECKPOINT_ROOM = { -- 252
	key = "checkpoint", -- 253
	name = "检查站 · 候检区 640 + 原段 1000", -- 254
	caption = "先翻过队栏进候检区，再带小满走到柜台与安全点；末段按住 E + D 推车 128 单位入窝", -- 255
	originX = 640, -- 257
	minX = -640, -- 258
	maxX = 1000, -- 259
	height = 210, -- 260
	depth = LANE_ROAD, -- 261
	floors = {{y = 0, x0 = -640, x1 = 1000}}, -- 262
	solids = {{ -- 263
		x = -430, -- 265
		w = 180, -- 265
		h = 28, -- 265
		y = 0, -- 265
		label = "队栏 -430–-250 · 高 28", -- 265
		lanes = {"lower", "middle"} -- 265
	}, { -- 265
		x = 240, -- 267
		w = 100, -- 267
		h = 44, -- 267
		y = 0, -- 267
		label = "柜台 240–340 · 高 44", -- 267
		lanes = {"lower", "middle"} -- 267
	}, { -- 267
		x = 890, -- 268
		w = 36, -- 268
		h = 122, -- 268
		y = 0, -- 268
		label = "检查站出口门柱", -- 268
		lanes = {"lower", "upper"}, -- 268
		art = "gate_post" -- 268
	}}, -- 268
	zones = {{ -- 270
		x0 = 380, -- 270
		x1 = 560, -- 270
		y = 0, -- 270
		h = 120, -- 270
		tint = 1, -- 270
		label = "危险段 380–560" -- 270
	}}, -- 270
	arch = { -- 271
		x0 = 0, -- 271
		x1 = 0, -- 271
		y = 0, -- 271
		h = 0, -- 271
		label = "" -- 271
	}, -- 271
	stairs = {}, -- 272
	cart = { -- 273
		startX = 640, -- 274
		endX = 768, -- 275
		baseY = 0, -- 276
		depth = LANE_DEPTH.middle, -- 277
		bodyW = 48, -- 278
		bodyH = 26, -- 279
		wheelR = 12, -- 280
		handleOffset = -40, -- 281
		clothSide = -1 -- 282
	}, -- 282
	spawns = {{x = -600, y = 0, h = 64, label = "小满 -600（世界 40）"}, {x = -560, y = 0, h = 88, label = "周戍 -560（世界 80）"}}, -- 284
	marks = {{x = 264, y = 0, kind = 1, label = "安全锚 264"}, {x = 768, y = 0, kind = 1, label = "dock 768"}, {x = 860, y = 0, kind = 2, label = "双人出口 792–928"}}, -- 288
	dims = {{x0 = 240, x1 = 340, text = "柜台 100"}, {x0 = 640, x1 = 768, text = "推车 128 · 左柄 E+D"}, {x0 = 792, x1 = 928, text = "出口 136"}} -- 293
} -- 293
--- 城外：同一剖面里同时看上层手柄与下层拱口，这是 D1 要交的那张图。
____exports.OUTSIDE_ROOM = { -- 301
	key = "outside", -- 302
	name = "城外 · 台面 y=96 / 墙根 1240", -- 303
	caption = "从右柄按住 E+D 朝空窝拉 128 单位，轮子落窝后沿台面回左端跳下，蹲过 44 高的拱；洞后墙根小路走到底可看见塔灯", -- 304
	originX = 0, -- 306
	minX = 0, -- 307
	maxX = 1240, -- 308
	height = 230, -- 309
	floors = {{y = 0, x0 = 0, x1 = 1240}, {y = 96, x0 = 128, x1 = 512}, {y = 64, x0 = 820, x1 = 940}}, -- 310
	solids = {{ -- 315
		x = 512, -- 317
		w = 88, -- 317
		h = 134, -- 317
		y = 96, -- 317
		label = "台面右端城墙 · 下层可通" -- 317
	}, { -- 317
		x = 0, -- 318
		w = 40, -- 318
		h = 96, -- 318
		y = 0, -- 318
		label = "街口" -- 318
	}, { -- 318
		x = 1200, -- 319
		w = 40, -- 319
		h = 140, -- 319
		y = 0, -- 319
		label = "墙根尽头" -- 319
	}}, -- 319
	zones = {}, -- 321
	arch = { -- 322
		x0 = 280, -- 322
		x1 = 360, -- 322
		y = 0, -- 322
		h = 44, -- 322
		label = "拱 280–360 · 净高 44" -- 322
	}, -- 322
	stairs = {{ -- 323
		x0 = 40, -- 324
		x1 = 128, -- 324
		y0 = 0, -- 324
		y1 = 96, -- 324
		steps = 2, -- 324
		label = "石阶 0 / 48 / 96" -- 324
	}, { -- 324
		x0 = 700, -- 325
		x1 = 820, -- 325
		y0 = 0, -- 325
		y1 = 64, -- 325
		steps = 3, -- 325
		label = "墙根石阶 0 / 16 / 32 / 48 / 64" -- 325
	}}, -- 325
	cart = { -- 327
		startX = 304, -- 328
		endX = 432, -- 329
		baseY = 96, -- 330
		bodyW = 48, -- 331
		bodyH = 26, -- 332
		wheelR = 12, -- 333
		handleOffset = 40, -- 334
		clothSide = -1 -- 335
	}, -- 335
	spawns = {{x = 160, y = 96, h = 64, label = "小满 160"}}, -- 337
	marks = { -- 338
		{x = 432, y = 96, kind = 1, label = "空窝 432"}, -- 339
		{x = 380, y = 0, kind = 0, label = "洞后检查点 380"}, -- 340
		{x = 520, y = 96, kind = 3, label = "石阶光 · 回首红布"}, -- 341
		{x = 820, y = 64, kind = 3, label = "墙根石阶顶 820"}, -- 342
		{x = 1120, y = 64, kind = 6, label = "塔灯 1120"} -- 343
	}, -- 343
	dims = {{x0 = 304, x1 = 432, text = "拉车 128 · 右柄 E+D"}, {x0 = 128, x1 = 512, text = "台面 384"}, {x0 = 280, x1 = 360, text = "拱 80"}, {x0 = 600, x1 = 1240, text = "墙根 640"}} -- 345
} -- 345
--- 村口：瓶架 112、观察位 160、桌下 304–416（净高 44）、第一院通行线 440、
-- 软土 272（D5 完整）、砖地 608、拾荒者巡逻 464–512。
-- 小满脚底中心 290 起必须蹲，超过 430 才站起；160→440 约 2.63 秒。
____exports.VILLAGE_ROOM = { -- 358
	key = "village", -- 359
	originX = 0, -- 360
	name = "村口 · 架、桌、砖地", -- 361
	caption = "点 E 拾瓶，按住 F 瞄，松手投；砖地一响，拾荒者转身，趁他走开钻过桌下", -- 362
	minX = 0, -- 363
	maxX = 720, -- 364
	height = 200, -- 365
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 366
	solids = {{ -- 367
		x = 96, -- 368
		w = 32, -- 368
		h = 64, -- 368
		y = 0, -- 368
		label = "瓶架" -- 368
	}, { -- 368
		x = 672, -- 370
		w = 48, -- 370
		h = 96, -- 370
		y = 0, -- 370
		label = "院墙" -- 370
	}}, -- 370
	zones = {{ -- 372
		x0 = 256, -- 373
		x1 = 288, -- 373
		y = 0, -- 373
		h = 6, -- 373
		tint = 2, -- 373
		label = "软土 272" -- 373
	}, { -- 373
		x0 = 440, -- 374
		x1 = 448, -- 374
		y = 0, -- 374
		h = 120, -- 374
		tint = 4, -- 374
		label = "通行线 440" -- 374
	}, { -- 374
		x0 = 592, -- 375
		x1 = 624, -- 375
		y = 0, -- 375
		h = 6, -- 375
		tint = 3, -- 375
		label = "砖地 608" -- 375
	}}, -- 375
	arch = { -- 377
		x0 = 304, -- 377
		x1 = 416, -- 377
		y = 0, -- 377
		h = 44, -- 377
		label = "桌下 304–416 · 净高 44" -- 377
	}, -- 377
	stairs = {}, -- 378
	cart = { -- 379
		startX = 0, -- 379
		endX = 0, -- 379
		baseY = 0, -- 379
		bodyW = 0, -- 379
		bodyH = 0, -- 379
		wheelR = 0, -- 379
		handleOffset = 0, -- 379
		clothSide = 1 -- 379
	}, -- 379
	spawns = {{x = 160, y = 0, h = 64, label = "小满 160"}}, -- 380
	marks = {{x = 608, y = 0, kind = 5, label = "砖地落点 608"}, {x = 440, y = 0, kind = 4, label = "通行线 440"}}, -- 381
	dims = {{x0 = 96, x1 = 128, text = "瓶架"}, {x0 = 304, x1 = 416, text = "桌下 112"}, {x0 = 464, x1 = 512, text = "巡逻 48"}}, -- 385
	scavenger = { -- 390
		x0 = 464, -- 391
		x1 = 512, -- 392
		y = 0, -- 393
		h = 56, -- 394
		patrolSpeed = 40, -- 395
		approachSpeed = 64, -- 396
		hearTicks = 18, -- 397
		stallTicks = 120, -- 398
		range = 480 -- 399
	}, -- 399
	bottle = {x = 112, y = 48}, -- 401
	brickX = 608, -- 402
	softX = 272, -- 403
	passLine = 440 -- 404
} -- 404
--- 剧本锚点跟着 originX 一起搬，判定仍读世界坐标。
local function shiftStory(story, ox) -- 408
	if story == nil then -- 408
		return nil -- 410
	end -- 410
	if ox == 0 then -- 410
		return story -- 413
	end -- 413
	local out = {} -- 415
	if story.prologue ~= nil then -- 415
		out.prologue = {giveReach = story.prologue.giveReach} -- 417
	end -- 417
	if story.gate ~= nil then -- 417
		out.gate = { -- 420
			winchX = story.gate.winchX + ox, -- 421
			waitX = story.gate.waitX + ox, -- 422
			doorX = story.gate.doorX + ox, -- 423
			exitX = story.gate.exitX + ox, -- 424
			holdTicks = story.gate.holdTicks -- 425
		} -- 425
	end -- 425
	if story.dog ~= nil then -- 425
		out.dog = {x0 = story.dog.x0 + ox, x1 = story.dog.x1 + ox, speed = story.dog.speed, range = story.dog.range} -- 429
	end -- 429
	if story.tower ~= nil then -- 429
		out.tower = {doorX = story.tower.doorX + ox, knockTicks = story.tower.knockTicks} -- 432
	end -- 432
	return out -- 434
end -- 408
--- 序章：周戍在废墟里找到藏在倒柜后的小满，走近点 E 递出指南针（纸条夹在针套里）。
-- 递完她开始跟随，两人一起走进街道。
____exports.PROLOGUE_ROOM = { -- 441
	key = "prologue", -- 442
	originX = 0, -- 443
	name = "序章 · 倒柜后", -- 444
	caption = "周戍持针套，小满藏在倒柜后；走近点 E 递过去，纸条塞进针套，她开始跟随", -- 445
	minX = 0, -- 446
	maxX = 720, -- 447
	height = 200, -- 448
	depth = LANE_ROAD, -- 449
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 450
	solids = {{ -- 451
		x = 152, -- 452
		w = 98, -- 452
		h = 32, -- 452
		y = 0, -- 452
		label = "倒柜 152–250 · 高 32", -- 452
		lanes = {"lower", "middle"} -- 452
	}, { -- 452
		x = 648, -- 453
		w = 30, -- 453
		h = 118, -- 453
		y = 0, -- 453
		label = "出口门柱", -- 453
		lanes = {"lower", "upper"}, -- 453
		art = "gate_post" -- 453
	}, { -- 453
		x = 110, -- 454
		w = 38, -- 454
		h = 84, -- 454
		y = 0, -- 454
		label = "石柱", -- 454
		lanes = {"lower", "middle"}, -- 454
		art = "wall" -- 454
	}}, -- 454
	zones = {}, -- 456
	arch = { -- 457
		x0 = 0, -- 457
		x1 = 0, -- 457
		y = 0, -- 457
		h = 0, -- 457
		label = "" -- 457
	}, -- 457
	stairs = {}, -- 458
	cart = { -- 459
		startX = 0, -- 459
		endX = 0, -- 459
		baseY = 0, -- 459
		bodyW = 0, -- 459
		bodyH = 0, -- 459
		wheelR = 0, -- 459
		handleOffset = 0, -- 459
		clothSide = 1 -- 459
	}, -- 459
	spawns = {{x = 80, y = 0, h = 88, label = "周戍 80"}, {x = 300, y = 0, h = 64, label = "小满 300 · 柜子后面"}}, -- 460
	marks = {{x = 300, y = 0, kind = 1, label = "柜后 300"}, {x = 660, y = 0, kind = 0, label = "门口中路 660"}}, -- 464
	dims = {{x0 = 152, x1 = 250, text = "倒柜 98"}, {x0 = 648, x1 = 678, text = "门柱 30"}}, -- 468
	story = {prologue = {giveReach = 46}} -- 472
} -- 472
--- 街道：两人已经同行，第一次交火在街心柜台后，打完把柜台敲两下算解除。
-- 一路走到检查站入口，提交进度后进入检查站。
____exports.STREET_ROOM = { -- 479
	key = "street", -- 480
	originX = 0, -- 481
	name = "街道 · 柜台与交火", -- 482
	caption = "小满跟着走；街心柜台后有两名敌兵，点鼠标射击，清掉后一起走到检查站入口", -- 483
	minX = 0, -- 484
	maxX = 1000, -- 485
	height = 210, -- 486
	depth = LANE_ROAD, -- 487
	floors = {{y = 0, x0 = 0, x1 = 1000}}, -- 488
	solids = {{ -- 489
		x = 300, -- 490
		w = 100, -- 490
		h = 44, -- 490
		y = 0, -- 490
		label = "街心柜台 300–400 · 高 44", -- 490
		lanes = {"lower", "middle"} -- 490
	}, { -- 490
		x = 620, -- 491
		w = 60, -- 491
		h = 36, -- 491
		y = 0, -- 491
		label = "街边矮墙 620", -- 491
		lanes = {"upper"} -- 491
	}, { -- 491
		x = 892, -- 492
		w = 40, -- 492
		h = 120, -- 492
		y = 0, -- 492
		label = "检查站门柱", -- 492
		lanes = {"lower", "upper"}, -- 492
		art = "gate_post" -- 492
	}}, -- 492
	zones = {}, -- 494
	arch = { -- 495
		x0 = 0, -- 495
		x1 = 0, -- 495
		y = 0, -- 495
		h = 0, -- 495
		label = "" -- 495
	}, -- 495
	stairs = {}, -- 496
	cart = { -- 497
		startX = 0, -- 497
		endX = 0, -- 497
		baseY = 0, -- 497
		bodyW = 0, -- 497
		bodyH = 0, -- 497
		wheelR = 0, -- 497
		handleOffset = 0, -- 497
		clothSide = 1 -- 497
	}, -- 497
	spawns = {{x = 100, y = 0, h = 88, label = "周戍 100"}, {x = 60, y = 0, h = 64, label = "小满 60"}}, -- 498
	marks = {{x = 900, y = 0, kind = 0, label = "检查站入口 900"}, {x = 520, y = 0, kind = 3, label = "街心 520"}}, -- 502
	dims = {{x0 = 300, x1 = 400, text = "柜台 100"}, {x0 = 900, x1 = 1000, text = "入口 100"}} -- 506
} -- 506
--- 城门：周戍把小满送到门洞等待点，自己回到绞盘；两人就位后开始 45 秒守点。
-- 守满后玩家走到门边按 E 送别，接着是数到一百与交权。
____exports.GATE_ROOM = { -- 516
	key = "gate", -- 517
	originX = 0, -- 518
	name = "城门 · 45 秒守点", -- 519
	caption = "小满到门洞 960、周戍贴住绞盘 118，两人就位开始 45 秒；守满走到门边按 E 送她", -- 520
	minX = 0, -- 521
	maxX = 1200, -- 522
	height = 240, -- 523
	depth = LANE_ROAD, -- 524
	floors = {{y = 0, x0 = 0, x1 = 1200}}, -- 525
	solids = { -- 526
		{ -- 527
			x = 40, -- 527
			w = 60, -- 527
			h = 60, -- 527
			y = 0, -- 527
			label = "绞盘 40–100 · 高 60" -- 527
		}, -- 527
		{ -- 528
			x = 520, -- 528
			w = 80, -- 528
			h = 44, -- 528
			y = 0, -- 528
			label = "街垒 520 · 高 44", -- 528
			lanes = {"middle", "upper"} -- 528
		}, -- 528
		{ -- 529
			x = 970, -- 529
			w = 34, -- 529
			h = 100, -- 529
			y = 0, -- 529
			label = "城门门柱", -- 529
			lanes = {"lower", "upper"}, -- 529
			art = "gate_post" -- 529
		}, -- 529
		{ -- 530
			x = 1040, -- 530
			w = 160, -- 530
			h = 180, -- 530
			y = 0, -- 530
			label = "门洞右墙 1040" -- 530
		}, -- 530
		{ -- 531
			x = 840, -- 531
			w = 200, -- 531
			h = 56, -- 531
			y = 160, -- 531
			label = "门楣 840–1040" -- 531
		} -- 531
	}, -- 531
	zones = {{ -- 533
		x0 = 860, -- 534
		x1 = 1000, -- 534
		y = 0, -- 534
		h = 8, -- 534
		tint = 4, -- 534
		label = "门洞 860–1000" -- 534
	}}, -- 534
	arch = { -- 536
		x0 = 0, -- 536
		x1 = 0, -- 536
		y = 0, -- 536
		h = 0, -- 536
		label = "" -- 536
	}, -- 536
	stairs = {}, -- 537
	cart = { -- 538
		startX = 0, -- 538
		endX = 0, -- 538
		baseY = 0, -- 538
		bodyW = 0, -- 538
		bodyH = 0, -- 538
		wheelR = 0, -- 538
		handleOffset = 0, -- 538
		clothSide = 1 -- 538
	}, -- 538
	spawns = {{x = 130, y = 0, h = 88, label = "周戍 130"}, {x = 150, y = 0, h = 64, label = "小满 150"}}, -- 539
	marks = {{x = 118, y = 0, kind = 1, label = "绞盘站位 118"}, {x = 960, y = 0, kind = 1, label = "门洞等待点 960"}, {x = 860, y = 0, kind = 0, label = "门边 860"}, {x = 1020, y = 0, kind = 0, label = "出门 1020"}}, -- 543
	dims = {{x0 = 40, x1 = 100, text = "绞盘 60"}, {x0 = 840, x1 = 1040, text = "门洞 200"}}, -- 549
	story = {gate = { -- 554
		winchX = 118, -- 554
		waitX = 960, -- 554
		doorX = 860, -- 554
		exitX = 1020, -- 554
		holdTicks = 2700 -- 554
	}} -- 554
} -- 554
--- 北塔森林：小满独自走。草后可以等，狗听见脚步会转耳朵、赶来、停一会儿再回线。
-- 最后一段从林缘自己选时机走到灯下门廊。
____exports.FOREST_ROOM = { -- 561
	key = "forest", -- 562
	originX = 0, -- 563
	name = "北塔森林 · 草与狗", -- 564
	caption = "狗对动静比人快：草后等、Shift 慢走、蹲着过；林缘 1450 走到灯下门廊", -- 565
	minX = 0, -- 566
	maxX = 1600, -- 567
	height = 200, -- 568
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 569
	solids = {{ -- 570
		x = 300, -- 571
		w = 80, -- 571
		h = 24, -- 571
		y = 0, -- 571
		label = "草丛 300–380 · 高 24", -- 571
		passable = true -- 571
	}, { -- 571
		x = 700, -- 572
		w = 90, -- 572
		h = 24, -- 572
		y = 0, -- 572
		label = "草丛 700–790 · 高 24", -- 572
		passable = true -- 572
	}, { -- 572
		x = 1150, -- 573
		w = 90, -- 573
		h = 24, -- 573
		y = 0, -- 573
		label = "草丛 1150–1240 · 高 24", -- 573
		passable = true -- 573
	}, { -- 573
		x = 1560, -- 574
		w = 40, -- 574
		h = 160, -- 574
		y = 0, -- 574
		label = "林缘 1560" -- 574
	}}, -- 574
	zones = {{ -- 576
		x0 = 1400, -- 577
		x1 = 1470, -- 577
		y = 0, -- 577
		h = 6, -- 577
		tint = 4, -- 577
		label = "林边 1400–1470" -- 577
	}}, -- 577
	arch = { -- 579
		x0 = 0, -- 579
		x1 = 0, -- 579
		y = 0, -- 579
		h = 0, -- 579
		label = "" -- 579
	}, -- 579
	stairs = {{ -- 580
		x0 = 520, -- 581
		x1 = 640, -- 581
		y0 = 0, -- 581
		y1 = 22, -- 581
		steps = 1, -- 581
		label = "矮台 520–640 · 高 22" -- 581
	}, { -- 581
		x0 = 980, -- 582
		x1 = 1100, -- 582
		y0 = 0, -- 582
		y1 = 22, -- 582
		steps = 1, -- 582
		label = "矮台 980–1100 · 高 22" -- 582
	}}, -- 582
	cart = { -- 584
		startX = 0, -- 584
		endX = 0, -- 584
		baseY = 0, -- 584
		bodyW = 0, -- 584
		bodyH = 0, -- 584
		wheelR = 0, -- 584
		handleOffset = 0, -- 584
		clothSide = 1 -- 584
	}, -- 584
	spawns = {{x = 120, y = 0, h = 64, label = "小满 120"}}, -- 585
	marks = {{x = 1450, y = 0, kind = 0, label = "林边安全点 1450"}, {x = 620, y = 0, kind = 3, label = "矮台 620"}}, -- 586
	dims = {{x0 = 700, x1 = 790, text = "草 90"}, {x0 = 1400, x1 = 1470, text = "林边 70"}}, -- 590
	story = {dog = {x0 = 620, x1 = 780, speed = 56, range = 300}} -- 594
} -- 594
--- 塔门与尾声：小满走到门前，按一次 E 敲两下；守卫开门接过针套和纸条，
-- 在登记簿里给下一个人留出一行空白。片尾可以再玩。
____exports.TOWER_ROOM = { -- 601
	key = "tower", -- 602
	originX = 0, -- 603
	name = "北塔塔门 · 尾声", -- 604
	caption = "走到门前点一次 E 敲两下；递出针套和纸条，看登记簿空行，片尾可再玩", -- 605
	minX = 0, -- 606
	maxX = 720, -- 607
	height = 220, -- 608
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 609
	solids = {{ -- 610
		x = 180, -- 611
		w = 220, -- 611
		h = 200, -- 611
		y = 0, -- 611
		label = "塔身 180–400" -- 611
	}, { -- 611
		x = 490, -- 612
		w = 230, -- 612
		h = 200, -- 612
		y = 0, -- 612
		label = "塔身 490–720" -- 612
	}, { -- 612
		x = 400, -- 613
		w = 90, -- 613
		h = 30, -- 613
		y = 110, -- 613
		label = "门楣 400–490" -- 613
	}}, -- 613
	zones = {{ -- 615
		x0 = 400, -- 616
		x1 = 490, -- 616
		y = 0, -- 616
		h = 8, -- 616
		tint = 4, -- 616
		label = "门廊 400–490" -- 616
	}}, -- 616
	arch = { -- 618
		x0 = 0, -- 618
		x1 = 0, -- 618
		y = 0, -- 618
		h = 0, -- 618
		label = "" -- 618
	}, -- 618
	stairs = {}, -- 619
	cart = { -- 620
		startX = 0, -- 620
		endX = 0, -- 620
		baseY = 0, -- 620
		bodyW = 0, -- 620
		bodyH = 0, -- 620
		wheelR = 0, -- 620
		handleOffset = 0, -- 620
		clothSide = 1 -- 620
	}, -- 620
	spawns = {{x = 418, y = 0, h = 64, label = "小满 418 · 门廊里"}}, -- 621
	marks = {{x = 445, y = 0, kind = 1, label = "门前 445"}}, -- 622
	dims = {{x0 = 400, x1 = 490, text = "门 90"}}, -- 625
	story = {tower = {doorX = 445, knockTicks = 36}} -- 628
} -- 628
local NO_CART = { -- 631
	startX = 0, -- 632
	endX = 0, -- 632
	baseY = 0, -- 632
	bodyW = 0, -- 632
	bodyH = 0, -- 632
	wheelR = 0, -- 632
	handleOffset = 0, -- 632
	clothSide = -1 -- 632
} -- 632
--- S1 十字街：同一个街口先教单方向火器，再让破障手从街角压近。
-- 外檐线与布行线都从这里的出口分叉；井背是退回点，窗台是可选的翻窗捷径。
____exports.S1_CROSSROAD = { -- 639
	key = "s1-crossroad", -- 640
	name = "S1 · 十字街", -- 641
	caption = "井背 → 摊后窄道 → 观察转角 → 街角压近者。薄木挡与窗台分别通向 S2 的两条线。", -- 642
	originX = 0, -- 643
	minX = 0, -- 644
	maxX = 1600, -- 645
	height = 220, -- 646
	depth = LANE_ROAD, -- 647
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 648
	solids = { -- 649
		{ -- 650
			x = 180, -- 650
			w = 88, -- 650
			h = 56, -- 650
			y = 0, -- 650
			label = "井背 180–268 · 高 56", -- 650
			lanes = {"lower"}, -- 650
			art = "cover_stone", -- 650
			id = "s1_well" -- 650
		}, -- 650
		{ -- 651
			x = 360, -- 651
			w = 160, -- 651
			h = 44, -- 651
			y = 0, -- 651
			label = "摊后柜台 360–520 · 高 44", -- 651
			lanes = {"lower", "middle"}, -- 651
			art = "cover_wood" -- 651
		}, -- 651
		{ -- 652
			x = 620, -- 652
			w = 44, -- 652
			h = 24, -- 652
			y = 0, -- 652
			label = "观察转角石基 620–664 · 高 24", -- 652
			lanes = {"lower"} -- 652
		}, -- 652
		{ -- 653
			x = 1130, -- 653
			w = 20, -- 653
			h = 120, -- 653
			y = 0, -- 653
			label = "窗柱左", -- 653
			lanes = {"lower"}, -- 653
			art = "wall" -- 653
		}, -- 653
		{ -- 654
			x = 1150, -- 654
			w = 80, -- 654
			h = 44, -- 654
			y = 0, -- 654
			label = "窗台 1150–1230 · 高 44", -- 654
			lanes = {"lower"} -- 654
		}, -- 654
		{ -- 655
			x = 1230, -- 655
			w = 20, -- 655
			h = 120, -- 655
			y = 0, -- 655
			label = "窗柱右", -- 655
			lanes = {"lower"}, -- 655
			art = "wall" -- 655
		}, -- 655
		{ -- 656
			x = 1460, -- 656
			w = 40, -- 656
			h = 140, -- 656
			y = 0, -- 656
			label = "街尾门柱", -- 656
			lanes = {"lower", "upper"}, -- 656
			art = "gate_post" -- 656
		} -- 656
	}, -- 656
	zones = {{ -- 658
		x0 = 700, -- 658
		x1 = 960, -- 658
		y = 0, -- 658
		h = 150, -- 658
		tint = 1, -- 658
		label = "街角交火 700–960" -- 658
	}}, -- 658
	arch = { -- 659
		x0 = 0, -- 659
		x1 = 0, -- 659
		y = 0, -- 659
		h = 0, -- 659
		label = "" -- 659
	}, -- 659
	stairs = {{ -- 660
		x0 = 900, -- 660
		x1 = 1040, -- 660
		y0 = 0, -- 660
		y1 = 40, -- 660
		steps = 4, -- 660
		label = "石基斜走 900–1040 · 高 40" -- 660
	}}, -- 660
	cart = NO_CART, -- 661
	spawns = {{ -- 662
		x = 760, -- 663
		y = 0, -- 663
		h = 84, -- 663
		depth = 32, -- 663
		label = "单方向火器手 760", -- 663
		kind = "gunner", -- 663
		drop = "ammo" -- 663
	}, { -- 663
		x = 880, -- 664
		y = 0, -- 664
		h = 84, -- 664
		label = "街角压近者 880", -- 664
		kind = "breaker", -- 664
		drop = "wedge" -- 664
	}}, -- 664
	marks = {{x = 220, y = 0, kind = 1, label = "井背安全点 220"}, {x = 640, y = 0, kind = 0, label = "观察转角 640"}, {x = 1190, y = 0, kind = 0, label = "窗台捷径 1190"}, {x = 1500, y = 0, kind = 0, label = "出口 1500"}}, -- 666
	dims = {{x0 = 180, x1 = 268, text = "井 88"}, {x0 = 360, x1 = 520, text = "柜台 160"}, {x0 = 900, x1 = 1040, text = "石基 140"}}, -- 672
	companion = {waitX = 220, waitDepth = -32, joinX = 900}, -- 677
	campaign = { -- 678
		chapter = "S", -- 678
		act = 1, -- 678
		budget = 210, -- 678
		goal = "reach_exit", -- 678
		next = "s2-drygoods", -- 678
		exitX = 1500, -- 678
		checkpoint = 1 -- 678
	} -- 678
} -- 678
--- S2 布行与外檐：近檐柱下短跨、可碎摊挡与转角装卸面是一条线；
-- 从染布架侧面进布行、绕柜到窗板背后放板、后仓折回是另一条线。两条线同通牌楼。
____exports.S2_DRYGOODS = { -- 685
	key = "s2-drygoods", -- 686
	name = "S2 · 布行与外檐", -- 687
	caption = "近檐：檐柱短跨、薄木摊挡、装卸面。远帘：染布架入内、绕柜、放窗板、后仓折回。两路同通牌楼。", -- 688
	originX = 1600, -- 689
	minX = 0, -- 690
	maxX = 1800, -- 691
	height = 230, -- 692
	depth = LANE_ROAD, -- 693
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 694
	solids = { -- 695
		{ -- 696
			x = 100, -- 696
			w = 24, -- 696
			h = 130, -- 696
			y = 0, -- 696
			label = "檐柱 100", -- 696
			lanes = {"middle"}, -- 696
			art = "cover_wood" -- 696
		}, -- 696
		{ -- 697
			x = 240, -- 697
			w = 24, -- 697
			h = 130, -- 697
			y = 0, -- 697
			label = "檐柱 240", -- 697
			lanes = {"middle"}, -- 697
			art = "cover_wood" -- 697
		}, -- 697
		{ -- 698
			x = 460, -- 699
			w = 100, -- 699
			h = 52, -- 699
			y = 0, -- 699
			label = "薄木摊挡 460–560 · 高 52", -- 699
			lanes = {"middle", "upper"}, -- 699
			art = "thin_wood", -- 700
			id = "s2_wood", -- 700
			breakable = {kind = "thin_wood", hp = 2, wedgeHp = 1} -- 700
		}, -- 700
		{ -- 702
			x = 620, -- 702
			w = 40, -- 702
			h = 130, -- 702
			y = 0, -- 702
			label = "永久石柱 620–660", -- 702
			lanes = {"upper"}, -- 702
			art = "cover_stone" -- 702
		}, -- 702
		{ -- 703
			x = 700, -- 703
			w = 120, -- 703
			h = 32, -- 703
			y = 0, -- 703
			label = "转角装卸面 700–820 · 高 32", -- 703
			lanes = {"middle"} -- 703
		}, -- 703
		{ -- 704
			x = 340, -- 704
			w = 120, -- 704
			h = 44, -- 704
			y = 0, -- 704
			label = "布行柜台 340–460 · 高 44", -- 704
			lanes = {"upper"}, -- 704
			art = "cover_wood" -- 704
		}, -- 704
		{ -- 705
			x = 600, -- 706
			w = 80, -- 706
			h = 72, -- 706
			y = 0, -- 706
			label = "窗板背后 600–680", -- 706
			lanes = {"upper"}, -- 706
			art = "board", -- 707
			id = "s2_board", -- 707
			interact = {kind = "open_board", reach = 46} -- 707
		}, -- 707
		{ -- 709
			x = 600, -- 710
			w = 80, -- 710
			h = 40, -- 710
			y = 0, -- 710
			label = "放下的窗板 600–680", -- 710
			lanes = {"lower"}, -- 710
			art = "board", -- 711
			id = "s2_board_cover", -- 711
			soft = true -- 711
		}, -- 711
		{ -- 713
			x = 1560, -- 713
			w = 30, -- 713
			h = 150, -- 713
			y = 0, -- 713
			label = "牌楼左柱", -- 713
			lanes = {"lower", "upper"}, -- 713
			art = "gate_post" -- 713
		}, -- 713
		{ -- 714
			x = 1700, -- 714
			w = 30, -- 714
			h = 150, -- 714
			y = 0, -- 714
			label = "牌楼右柱", -- 714
			lanes = {"lower", "upper"}, -- 714
			art = "gate_post" -- 714
		} -- 714
	}, -- 714
	zones = {{ -- 716
		x0 = 640, -- 716
		x1 = 1300, -- 716
		y = 0, -- 716
		h = 150, -- 716
		tint = 1, -- 716
		label = "转角装卸面交火 700–1200" -- 716
	}}, -- 716
	arch = { -- 717
		x0 = 0, -- 717
		x1 = 0, -- 717
		y = 0, -- 717
		h = 0, -- 717
		label = "" -- 717
	}, -- 717
	stairs = {}, -- 718
	cart = NO_CART, -- 719
	spawns = {{ -- 720
		x = 940, -- 721
		y = 0, -- 721
		h = 84, -- 721
		depth = 0, -- 721
		label = "持盾手 940", -- 721
		kind = "shield", -- 721
		shieldHp = 2, -- 721
		drop = "shield" -- 721
	}, { -- 721
		x = 1060, -- 722
		y = 0, -- 722
		h = 84, -- 722
		depth = 32, -- 722
		label = "远侧火器手 1060", -- 722
		kind = "gunner", -- 722
		drop = "ammo" -- 722
	}, { -- 722
		x = 1140, -- 723
		y = 0, -- 723
		h = 84, -- 723
		depth = 0, -- 723
		label = "破障手 1140", -- 723
		kind = "breaker", -- 723
		drop = "wedge" -- 723
	}}, -- 723
	marks = {{x = 640, y = 0, kind = 1, label = "窗板后等待位 640"}, {x = 900, y = 0, kind = 0, label = "后仓汇合口 900"}, {x = 1740, y = 0, kind = 0, label = "牌楼出口 1740"}}, -- 725
	dims = {{x0 = 100, x1 = 124, text = "檐柱 24"}, {x0 = 460, x1 = 560, text = "摊挡 100"}, {x0 = 700, x1 = 820, text = "装卸面 120"}}, -- 730
	companion = {waitX = 640, waitDepth = 32, joinX = 900, followAfter = "open_board"}, -- 735
	campaign = { -- 736
		chapter = "S", -- 736
		act = 2, -- 736
		budget = 390, -- 736
		goal = "reach_exit", -- 736
		next = "s3-archway", -- 736
		exitX = 1740, -- 736
		checkpoint = 2 -- 736
	} -- 736
} -- 736
--- S3 牌楼后巷：外檐线从低处进、布行线从高处进，两条入口在墙脚汇合。
-- 装卸坡可先上去看同一堆粮袋的敌位，再退半层接小满；也可以沿墙脚直接绕。
____exports.S3_ARCHWAY = { -- 743
	key = "s3-archway", -- 744
	name = "S3 · 牌楼后巷", -- 745
	caption = "两高度入口看同一粮袋。登装卸坡看敌位再退半层接人，或沿墙脚绕走；候检门前两人停。", -- 746
	originX = 3400, -- 747
	minX = 0, -- 748
	maxX = 1400, -- 749
	height = 230, -- 750
	depth = LANE_ROAD, -- 751
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 752
	solids = { -- 753
		{ -- 754
			x = 0, -- 754
			w = 180, -- 754
			h = 32, -- 754
			y = 0, -- 754
			label = "高处进口台 0–180 · 高 32", -- 754
			lanes = {"upper"} -- 754
		}, -- 754
		{ -- 755
			x = 380, -- 755
			w = 140, -- 755
			h = 64, -- 755
			y = 0, -- 755
			label = "装卸高台 380–520 · 高 64", -- 755
			lanes = {"upper"} -- 755
		}, -- 755
		{ -- 756
			x = 560, -- 756
			w = 160, -- 756
			h = 48, -- 756
			y = 0, -- 756
			label = "粮袋堆 560–720 · 高 48", -- 756
			lanes = {"lower", "middle"} -- 756
		}, -- 756
		{ -- 757
			x = 1260, -- 757
			w = 30, -- 757
			h = 140, -- 757
			y = 0, -- 757
			label = "候检门左柱", -- 757
			lanes = {"lower", "upper"}, -- 757
			art = "gate_post" -- 757
		}, -- 757
		{ -- 758
			x = 1330, -- 758
			w = 30, -- 758
			h = 140, -- 758
			y = 0, -- 758
			label = "候检门右柱", -- 758
			lanes = {"lower", "upper"}, -- 758
			art = "gate_post" -- 758
		} -- 758
	}, -- 758
	zones = {{ -- 760
		x0 = 780, -- 760
		x1 = 1060, -- 760
		y = 0, -- 760
		h = 150, -- 760
		tint = 1, -- 760
		label = "后巷交火 780–1060" -- 760
	}}, -- 760
	arch = { -- 761
		x0 = 0, -- 761
		x1 = 0, -- 761
		y = 0, -- 761
		h = 0, -- 761
		label = "" -- 761
	}, -- 761
	stairs = {{ -- 762
		x0 = 140, -- 763
		x1 = 200, -- 763
		y0 = 0, -- 763
		y1 = 32, -- 763
		steps = 3, -- 763
		label = "进口台阶" -- 763
	}, { -- 763
		x0 = 260, -- 764
		x1 = 380, -- 764
		y0 = 0, -- 764
		y1 = 64, -- 764
		steps = 4, -- 764
		label = "装卸坡 260–380 · 高 64" -- 764
	}}, -- 764
	cart = NO_CART, -- 766
	spawns = {{ -- 767
		x = 860, -- 768
		y = 0, -- 768
		h = 84, -- 768
		depth = 32, -- 768
		label = "高处火器手 860", -- 768
		kind = "gunner", -- 768
		drop = "ammo" -- 768
	}, { -- 768
		x = 980, -- 769
		y = 0, -- 769
		h = 84, -- 769
		depth = 0, -- 769
		label = "墙脚火器手 980", -- 769
		kind = "gunner", -- 769
		drop = "ammo" -- 769
	}}, -- 769
	marks = {{x = 440, y = 0, kind = 0, label = "装卸坡观察位 440"}, {x = 620, y = 0, kind = 1, label = "粮袋后安全点 620"}, {x = 1300, y = 0, kind = 0, label = "候检门前 1300"}}, -- 771
	dims = {{x0 = 260, x1 = 380, text = "装卸坡 120"}, {x0 = 560, x1 = 720, text = "粮袋 160"}}, -- 776
	companion = {waitX = 620, waitDepth = 0, joinX = 1240}, -- 777
	campaign = { -- 778
		chapter = "S", -- 778
		act = 3, -- 778
		budget = 180, -- 778
		goal = "reach_exit", -- 778
		next = "c1-yard", -- 778
		exitX = 1320, -- 778
		checkpoint = 3 -- 778
	} -- 778
} -- 778
--- C1 候检院：侧门横闩在门背，粮棚可见但被队栏、查验台与棚柱交错挡住。
-- 绕缺口进栏，截断压近者或穿查验台后到棚口；正面看门，转到背面才抬得动闩。
____exports.C1_YARD = { -- 785
	key = "c1-yard", -- 786
	name = "C1 · 候检院", -- 787
	caption = "队栏与查验台把粮棚切成几段。绕缺口进栏，压近者会截断通路；侧门横闩要转到门背才抬得动。", -- 788
	originX = 4800, -- 789
	minX = 0, -- 790
	maxX = 1900, -- 791
	height = 240, -- 792
	depth = LANE_ROAD, -- 793
	floors = {{y = 0, x0 = 0, x1 = 1900}}, -- 794
	solids = { -- 795
		{ -- 796
			x = 280, -- 796
			w = 340, -- 796
			h = 28, -- 796
			y = 0, -- 796
			label = "候检队栏 280–620 · 高 28", -- 796
			lanes = {"lower", "middle"}, -- 796
			art = "fence" -- 796
		}, -- 796
		{ -- 797
			x = 820, -- 797
			w = 180, -- 797
			h = 44, -- 797
			y = 0, -- 797
			label = "查验台 820–1000 · 高 44", -- 797
			lanes = {"lower", "middle"} -- 797
		}, -- 797
		{ -- 798
			x = 1100, -- 798
			w = 40, -- 798
			h = 150, -- 798
			y = 0, -- 798
			label = "棚柱 1100–1140", -- 798
			lanes = {"lower", "middle"}, -- 798
			art = "cover_wood" -- 798
		}, -- 798
		{ -- 799
			x = 1240, -- 799
			w = 40, -- 799
			h = 150, -- 799
			y = 0, -- 799
			label = "棚柱 1240–1280", -- 799
			lanes = {"lower", "middle"}, -- 799
			art = "cover_wood" -- 799
		}, -- 799
		{ -- 800
			x = 1600, -- 800
			w = 160, -- 800
			h = 48, -- 800
			y = 0, -- 800
			label = "粮棚袋堆 1600–1760 · 高 48", -- 800
			lanes = {"lower", "middle"} -- 800
		}, -- 800
		{ -- 801
			x = 1780, -- 801
			w = 50, -- 801
			h = 150, -- 801
			y = 0, -- 801
			label = "侧门 1780–1830", -- 801
			lanes = {"lower", "middle"}, -- 801
			art = "wall", -- 801
			id = "c1_door" -- 801
		}, -- 801
		{ -- 802
			x = 1810, -- 803
			w = 30, -- 803
			h = 24, -- 803
			y = 40, -- 803
			label = "侧门横闩（门背）", -- 803
			lanes = {"upper"}, -- 803
			art = "latch", -- 804
			id = "c1_latch", -- 804
			interact = {kind = "raise_latch", reach = 52} -- 804
		} -- 804
	}, -- 804
	zones = {{ -- 807
		x0 = 760, -- 807
		x1 = 1080, -- 807
		y = 0, -- 807
		h = 150, -- 807
		tint = 1, -- 807
		label = "查验台截断 820–1000" -- 807
	}}, -- 807
	arch = { -- 808
		x0 = 0, -- 808
		x1 = 0, -- 808
		y = 0, -- 808
		h = 0, -- 808
		label = "" -- 808
	}, -- 808
	stairs = {}, -- 809
	cart = NO_CART, -- 810
	spawns = {{ -- 811
		x = 900, -- 812
		y = 0, -- 812
		h = 84, -- 812
		depth = 0, -- 812
		label = "截断压近者 900", -- 812
		kind = "breaker", -- 812
		drop = "wedge" -- 812
	}, { -- 812
		x = 1200, -- 813
		y = 0, -- 813
		h = 84, -- 813
		depth = 32, -- 813
		label = "棚柱后火器手 1200", -- 813
		kind = "gunner", -- 813
		drop = "ammo" -- 813
	}}, -- 813
	marks = {{x = 1000, y = 0, kind = 1, label = "查验台后等待位 1000"}, {x = 1700, y = 0, kind = 0, label = "侧门正面 1700"}, {x = 1860, y = 0, kind = 0, label = "门背出口 1860"}}, -- 815
	dims = {{x0 = 820, x1 = 1000, text = "查验台 180"}, {x0 = 1780, x1 = 1830, text = "侧门 50"}}, -- 820
	companion = {waitX = 1000, waitDepth = 0, joinX = 1700, followAfter = "raise_latch"}, -- 821
	campaign = { -- 822
		chapter = "C", -- 822
		act = 1, -- 822
		budget = 270, -- 822
		goal = "raise_latch", -- 822
		next = "c2-granary", -- 822
		exitX = 1860, -- 822
		checkpoint = 4 -- 822
	} -- 822
} -- 822
--- C2 军粮棚：粮袋安全区居中，远柱木帘与近侧车轨分列。
-- 有残盾可以在暴露轨段架起来挡一发；空手路线先绕上远柱放帘，再回来握车柄。
____exports.C2_GRANARY = { -- 829
	key = "c2-granary", -- 830
	name = "C2 · 军粮棚", -- 831
	caption = "空筐围挡、暴露轨段与远柱木帘。先绕上远柱放帘，或架残盾，再握车柄把车推入轮窝并抬连杆闩。", -- 832
	originX = 6700, -- 833
	minX = 0, -- 834
	maxX = 1800, -- 835
	height = 240, -- 836
	depth = LANE_ROAD, -- 837
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 838
	solids = { -- 839
		{ -- 840
			x = 900, -- 841
			w = 120, -- 841
			h = 44, -- 841
			y = 0, -- 841
			label = "空筐围挡 900–1020 · 高 44", -- 841
			lanes = {"lower", "middle"}, -- 841
			art = "basket_wall", -- 842
			id = "c2_basket", -- 842
			breakable = {kind = "basket_wall", hp = 2} -- 842
		}, -- 842
		{ -- 844
			x = 600, -- 844
			w = 300, -- 844
			h = 48, -- 844
			y = 0, -- 844
			label = "粮袋安全区 600–900 · 高 48", -- 844
			lanes = {"lower", "middle"} -- 844
		}, -- 844
		{ -- 845
			x = 980, -- 845
			w = 40, -- 845
			h = 24, -- 845
			y = 0, -- 845
			label = "棚口下轨台 980–1020 · 高 24", -- 845
			lanes = {"lower", "middle"} -- 845
		}, -- 845
		{ -- 846
			x = 1200, -- 847
			w = 40, -- 847
			h = 150, -- 847
			y = 0, -- 847
			label = "远柱 1200–1240 · 高 150", -- 847
			lanes = {"upper"}, -- 847
			art = "cover_wood", -- 848
			id = "c2_post", -- 848
			interact = {kind = "lower_curtain", reach = 46} -- 848
		}, -- 848
		{ -- 850
			x = 1240, -- 851
			w = 120, -- 851
			h = 120, -- 851
			y = 24, -- 851
			label = "木帘落点 1240–1360", -- 851
			lanes = {"lower", "middle"}, -- 851
			art = "curtain", -- 852
			soft = true, -- 852
			id = "c2_curtain", -- 852
			hidden = true -- 852
		}, -- 852
		{ -- 854
			x = 1560, -- 855
			w = 30, -- 855
			h = 24, -- 855
			y = 40, -- 855
			label = "连杆抬闩 1560–1590", -- 855
			lanes = {"middle"}, -- 855
			art = "latch", -- 856
			id = "c2_latch", -- 856
			interact = {kind = "raise_latch", reach = 50} -- 856
		}, -- 856
		{ -- 858
			x = 1720, -- 858
			w = 30, -- 858
			h = 150, -- 858
			y = 0, -- 858
			label = "棚尾门柱", -- 858
			lanes = {"lower", "upper"}, -- 858
			art = "gate_post" -- 858
		} -- 858
	}, -- 858
	zones = {{ -- 860
		x0 = 1000, -- 860
		x1 = 1200, -- 860
		y = 0, -- 860
		h = 150, -- 860
		tint = 1, -- 860
		label = "暴露轨段 1000–1200" -- 860
	}}, -- 860
	arch = { -- 861
		x0 = 0, -- 861
		x1 = 0, -- 861
		y = 0, -- 861
		h = 0, -- 861
		label = "" -- 861
	}, -- 861
	stairs = {}, -- 862
	cart = { -- 863
		startX = 1150, -- 864
		endX = 1500, -- 864
		baseY = 0, -- 864
		depth = 0, -- 864
		bodyW = 48, -- 864
		bodyH = 26, -- 864
		wheelR = 12, -- 864
		handleOffset = -50, -- 864
		clothSide = -1 -- 864
	}, -- 864
	spawns = {{ -- 866
		x = 1580, -- 867
		y = 0, -- 867
		h = 84, -- 867
		depth = 32, -- 867
		label = "棚尾火器手 1580", -- 867
		kind = "gunner", -- 867
		drop = "ammo" -- 867
	}, { -- 867
		x = 1340, -- 868
		y = 0, -- 868
		h = 84, -- 868
		depth = 32, -- 868
		label = "远侧持盾手 1340", -- 868
		kind = "shield", -- 868
		shieldHp = 2, -- 868
		drop = "shield" -- 868
	}}, -- 868
	marks = {{x = 760, y = 0, kind = 1, label = "袋堆后等待位 760"}, {x = 1100, y = 0, kind = 0, label = "车柄 1100"}, {x = 1500, y = 0, kind = 0, label = "轮窝 1500"}, {x = 1700, y = 0, kind = 0, label = "棚尾出口 1700"}}, -- 870
	dims = {{x0 = 1150, x1 = 1500, text = "推车 350"}, {x0 = 1240, x1 = 1360, text = "木帘 120"}}, -- 876
	companion = {waitX = 760, waitDepth = 0, joinX = 1700}, -- 877
	campaign = { -- 878
		chapter = "C", -- 878
		act = 2, -- 878
		budget = 360, -- 878
		goal = "dock_cart", -- 878
		exitX = 1700, -- 878
		checkpoint = 5 -- 878
	} -- 878
} -- 878
____exports.CAMPAIGN_ROOMS = { -- 881
	____exports.S1_CROSSROAD, -- 881
	____exports.S2_DRYGOODS, -- 881
	____exports.S3_ARCHWAY, -- 881
	____exports.C1_YARD, -- 881
	____exports.C2_GRANARY -- 881
} -- 881
____exports.ROOMS = { -- 889
	____exports.PROLOGUE_ROOM, -- 889
	____exports.STREET_ROOM, -- 889
	____exports.CHECKPOINT_ROOM, -- 889
	____exports.GATE_ROOM, -- 889
	____exports.OUTSIDE_ROOM, -- 889
	____exports.VILLAGE_ROOM, -- 889
	____exports.FOREST_ROOM, -- 889
	____exports.TOWER_ROOM -- 889
} -- 889
local function placeSolids(room) -- 900
	local blocks = {} -- 901
	for ____, solid in ipairs(room.solids) do -- 902
		local x = solid.x + room.originX -- 903
		if room.depth ~= nil and solid.lanes ~= nil then -- 903
			for ____, depth in ipairs(laneFootprints(solid.lanes)) do -- 905
				blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x, depth = depth, lanes = nil}) -- 906
			end -- 906
		else -- 906
			blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x}) -- 909
		end -- 909
	end -- 909
	return blocks -- 912
end -- 900
--- 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
-- 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
function ____exports.withOrigin(room) -- 919
	local ox = room.originX -- 920
	if ox == 0 then -- 920
		return room.depth == nil and room or __TS__ObjectAssign( -- 922
			{}, -- 922
			room, -- 922
			{solids = placeSolids(room)} -- 922
		) -- 922
	end -- 922
	local function shift(x) -- 924
		return x + ox -- 924
	end -- 924
	local ____room_key_7 = room.key -- 926
	local ____room_name_8 = room.name -- 927
	local ____room_caption_9 = room.caption -- 928
	local ____shift_result_10 = shift(room.minX) -- 930
	local ____shift_result_11 = shift(room.maxX) -- 931
	local ____room_height_12 = room.height -- 932
	local ____room_depth_13 = room.depth -- 933
	local ____TS__ArrayMap_result_14 = __TS__ArrayMap( -- 934
		room.floors, -- 934
		function(____, f) return { -- 934
			y = f.y, -- 934
			x0 = shift(f.x0), -- 934
			x1 = shift(f.x1) -- 934
		} end -- 934
	) -- 934
	local ____placeSolids_result_15 = placeSolids(room) -- 935
	local ____TS__ArrayMap_result_16 = __TS__ArrayMap( -- 936
		room.zones, -- 936
		function(____, z) return { -- 936
			x0 = shift(z.x0), -- 936
			x1 = shift(z.x1), -- 936
			y = z.y, -- 936
			h = z.h, -- 936
			tint = z.tint, -- 936
			label = z.label -- 936
		} end -- 936
	) -- 936
	local ____temp_17 = { -- 937
		x0 = shift(room.arch.x0), -- 937
		x1 = shift(room.arch.x1), -- 937
		y = room.arch.y, -- 937
		h = room.arch.h, -- 937
		label = room.arch.label -- 937
	} -- 937
	local ____TS__ArrayMap_result_18 = __TS__ArrayMap( -- 938
		room.stairs, -- 938
		function(____, s) return { -- 938
			x0 = shift(s.x0), -- 938
			x1 = shift(s.x1), -- 938
			y0 = s.y0, -- 938
			y1 = s.y1, -- 938
			steps = s.steps, -- 938
			label = s.label -- 938
		} end -- 938
	) -- 938
	local ____TS__ObjectAssign_result_19 = __TS__ObjectAssign( -- 939
		{}, -- 939
		room.cart, -- 940
		{ -- 939
			startX = shift(room.cart.startX), -- 941
			endX = shift(room.cart.endX) -- 942
		} -- 942
	) -- 942
	local ____TS__ArrayMap_result_20 = __TS__ArrayMap( -- 944
		room.spawns, -- 944
		function(____, s) return __TS__ObjectAssign( -- 944
			{}, -- 944
			s, -- 944
			{x = shift(s.x)} -- 944
		) end -- 944
	) -- 944
	local ____TS__ArrayMap_result_21 = __TS__ArrayMap( -- 945
		room.marks, -- 945
		function(____, m) return { -- 945
			x = shift(m.x), -- 945
			y = m.y, -- 945
			kind = m.kind, -- 945
			label = m.label -- 945
		} end -- 945
	) -- 945
	local ____TS__ArrayMap_result_22 = __TS__ArrayMap( -- 946
		room.dims, -- 946
		function(____, d) return { -- 946
			x0 = shift(d.x0), -- 946
			x1 = shift(d.x1), -- 946
			text = d.text -- 946
		} end -- 946
	) -- 946
	local ____temp_0 -- 947
	if room.scavenger == nil then -- 947
		____temp_0 = nil -- 947
	else -- 947
		____temp_0 = { -- 947
			x0 = shift(room.scavenger.x0), -- 948
			x1 = shift(room.scavenger.x1), -- 948
			y = room.scavenger.y, -- 948
			h = room.scavenger.h, -- 948
			patrolSpeed = room.scavenger.patrolSpeed, -- 949
			approachSpeed = room.scavenger.approachSpeed, -- 949
			hearTicks = room.scavenger.hearTicks, -- 950
			stallTicks = room.scavenger.stallTicks, -- 950
			range = room.scavenger.range -- 950
		} -- 950
	end -- 950
	local ____temp_1 -- 952
	if room.bottle == nil then -- 952
		____temp_1 = nil -- 952
	else -- 952
		____temp_1 = { -- 952
			x = shift(room.bottle.x), -- 952
			y = room.bottle.y -- 952
		} -- 952
	end -- 952
	local ____temp_2 -- 953
	if room.brickX == nil then -- 953
		____temp_2 = nil -- 953
	else -- 953
		____temp_2 = shift(room.brickX) -- 953
	end -- 953
	local ____temp_3 -- 954
	if room.softX == nil then -- 954
		____temp_3 = nil -- 954
	else -- 954
		____temp_3 = shift(room.softX) -- 954
	end -- 954
	local ____temp_4 -- 955
	if room.passLine == nil then -- 955
		____temp_4 = nil -- 955
	else -- 955
		____temp_4 = shift(room.passLine) -- 955
	end -- 955
	local ____temp_5 -- 956
	if room.campaign == nil then -- 956
		____temp_5 = nil -- 956
	else -- 956
		____temp_5 = __TS__ObjectAssign( -- 956
			{}, -- 956
			room.campaign, -- 956
			{exitX = shift(room.campaign.exitX)} -- 956
		) -- 956
	end -- 956
	local ____temp_6 -- 957
	if room.pickups == nil then -- 957
		____temp_6 = nil -- 957
	else -- 957
		____temp_6 = __TS__ArrayMap( -- 957
			room.pickups, -- 957
			function(____, p) return __TS__ObjectAssign( -- 957
				{}, -- 957
				p, -- 957
				{x = shift(p.x)} -- 957
			) end -- 957
		) -- 957
	end -- 957
	return { -- 925
		key = ____room_key_7, -- 926
		name = ____room_name_8, -- 927
		caption = ____room_caption_9, -- 928
		originX = 0, -- 929
		minX = ____shift_result_10, -- 930
		maxX = ____shift_result_11, -- 931
		height = ____room_height_12, -- 932
		depth = ____room_depth_13, -- 933
		floors = ____TS__ArrayMap_result_14, -- 934
		solids = ____placeSolids_result_15, -- 935
		zones = ____TS__ArrayMap_result_16, -- 936
		arch = ____temp_17, -- 937
		stairs = ____TS__ArrayMap_result_18, -- 938
		cart = ____TS__ObjectAssign_result_19, -- 939
		spawns = ____TS__ArrayMap_result_20, -- 944
		marks = ____TS__ArrayMap_result_21, -- 945
		dims = ____TS__ArrayMap_result_22, -- 946
		scavenger = ____temp_0, -- 947
		bottle = ____temp_1, -- 952
		brickX = ____temp_2, -- 953
		softX = ____temp_3, -- 954
		passLine = ____temp_4, -- 955
		campaign = ____temp_5, -- 956
		pickups = ____temp_6, -- 957
		companion = room.companion, -- 958
		story = shiftStory(room.story, ox) -- 959
	} -- 959
end -- 919
return ____exports -- 919