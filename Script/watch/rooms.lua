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
-- 守满后玩家走到门边按 E 送别，接着是数到一百与交权。
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
--- 北塔森林：小满独自走。草后可以等，狗听见脚步会转耳朵、赶来、停一会儿再回线。
-- 最后一段从林缘自己选时机走到灯下门廊。
____exports.FOREST_ROOM = { -- 563
	key = "forest", -- 564
	originX = 0, -- 565
	name = "北塔森林 · 草与狗", -- 566
	caption = "狗对动静比人快：草后等、Shift 慢走、蹲着过；林缘 1450 走到灯下门廊", -- 567
	minX = 0, -- 568
	maxX = 1600, -- 569
	height = 200, -- 570
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 571
	solids = {{ -- 572
		x = 300, -- 573
		w = 80, -- 573
		h = 24, -- 573
		y = 0, -- 573
		label = "草丛 300–380 · 高 24", -- 573
		passable = true -- 573
	}, { -- 573
		x = 700, -- 574
		w = 90, -- 574
		h = 24, -- 574
		y = 0, -- 574
		label = "草丛 700–790 · 高 24", -- 574
		passable = true -- 574
	}, { -- 574
		x = 1150, -- 575
		w = 90, -- 575
		h = 24, -- 575
		y = 0, -- 575
		label = "草丛 1150–1240 · 高 24", -- 575
		passable = true -- 575
	}, { -- 575
		x = 1560, -- 576
		w = 40, -- 576
		h = 160, -- 576
		y = 0, -- 576
		label = "林缘 1560" -- 576
	}}, -- 576
	zones = {{ -- 578
		x0 = 1400, -- 579
		x1 = 1470, -- 579
		y = 0, -- 579
		h = 6, -- 579
		tint = 4, -- 579
		label = "林边 1400–1470" -- 579
	}}, -- 579
	arch = { -- 581
		x0 = 0, -- 581
		x1 = 0, -- 581
		y = 0, -- 581
		h = 0, -- 581
		label = "" -- 581
	}, -- 581
	stairs = {{ -- 582
		x0 = 520, -- 583
		x1 = 640, -- 583
		y0 = 0, -- 583
		y1 = 22, -- 583
		steps = 1, -- 583
		label = "矮台 520–640 · 高 22" -- 583
	}, { -- 583
		x0 = 980, -- 584
		x1 = 1100, -- 584
		y0 = 0, -- 584
		y1 = 22, -- 584
		steps = 1, -- 584
		label = "矮台 980–1100 · 高 22" -- 584
	}}, -- 584
	cart = { -- 586
		startX = 0, -- 586
		endX = 0, -- 586
		baseY = 0, -- 586
		bodyW = 0, -- 586
		bodyH = 0, -- 586
		wheelR = 0, -- 586
		handleOffset = 0, -- 586
		clothSide = 1 -- 586
	}, -- 586
	spawns = {{x = 120, y = 0, h = 64, label = "小满 120"}}, -- 587
	marks = {{x = 1450, y = 0, kind = 0, label = "林边安全点 1450"}, {x = 620, y = 0, kind = 3, label = "矮台 620"}}, -- 588
	dims = {{x0 = 700, x1 = 790, text = "草 90"}, {x0 = 1400, x1 = 1470, text = "林边 70"}}, -- 592
	story = {dog = {x0 = 620, x1 = 780, speed = 56, range = 300}} -- 596
} -- 596
--- 塔门与尾声：小满走到门前，按一次 E 敲两下；守卫开门接过针套和纸条，
-- 在登记簿里给下一个人留出一行空白。片尾可以再玩。
____exports.TOWER_ROOM = { -- 603
	key = "tower", -- 604
	originX = 0, -- 605
	name = "北塔塔门 · 尾声", -- 606
	caption = "走到门前点一次 E 敲两下；递出针套和纸条，看登记簿空行，片尾可再玩", -- 607
	minX = 0, -- 608
	maxX = 720, -- 609
	height = 220, -- 610
	floors = {{y = 0, x0 = 0, x1 = 720}}, -- 611
	solids = {{ -- 612
		x = 180, -- 613
		w = 220, -- 613
		h = 200, -- 613
		y = 0, -- 613
		label = "塔身 180–400" -- 613
	}, { -- 613
		x = 490, -- 614
		w = 230, -- 614
		h = 200, -- 614
		y = 0, -- 614
		label = "塔身 490–720" -- 614
	}, { -- 614
		x = 400, -- 615
		w = 90, -- 615
		h = 30, -- 615
		y = 110, -- 615
		label = "门楣 400–490" -- 615
	}}, -- 615
	zones = {{ -- 617
		x0 = 400, -- 618
		x1 = 490, -- 618
		y = 0, -- 618
		h = 8, -- 618
		tint = 4, -- 618
		label = "门廊 400–490" -- 618
	}}, -- 618
	arch = { -- 620
		x0 = 0, -- 620
		x1 = 0, -- 620
		y = 0, -- 620
		h = 0, -- 620
		label = "" -- 620
	}, -- 620
	stairs = {}, -- 621
	cart = { -- 622
		startX = 0, -- 622
		endX = 0, -- 622
		baseY = 0, -- 622
		bodyW = 0, -- 622
		bodyH = 0, -- 622
		wheelR = 0, -- 622
		handleOffset = 0, -- 622
		clothSide = 1 -- 622
	}, -- 622
	spawns = {{x = 418, y = 0, h = 64, label = "小满 418 · 门廊里"}}, -- 623
	marks = {{x = 445, y = 0, kind = 1, label = "门前 445"}}, -- 624
	dims = {{x0 = 400, x1 = 490, text = "门 90"}}, -- 627
	story = {tower = {doorX = 445, knockTicks = 36}} -- 630
} -- 630
local NO_CART = { -- 633
	startX = 0, -- 634
	endX = 0, -- 634
	baseY = 0, -- 634
	bodyW = 0, -- 634
	bodyH = 0, -- 634
	wheelR = 0, -- 634
	handleOffset = 0, -- 634
	clothSide = -1 -- 634
} -- 634
--- S1 十字街：同一个街口先教单方向火器，再让破障手从街角压近。
-- 外檐线与布行线都从这里的出口分叉；井背是退回点，窗台是可选的翻窗捷径。
____exports.S1_CROSSROAD = { -- 641
	key = "s1-crossroad", -- 642
	name = "S1 · 十字街", -- 643
	caption = "井背 → 摊后窄道 → 观察转角 → 街角压近者。薄木挡与窗台分别通向 S2 的两条线。", -- 644
	originX = 0, -- 645
	minX = 0, -- 646
	maxX = 1600, -- 647
	height = 220, -- 648
	depth = LANE_ROAD, -- 649
	floors = {{y = 0, x0 = 0, x1 = 1600}}, -- 650
	solids = { -- 651
		{ -- 652
			x = 180, -- 652
			w = 88, -- 652
			h = 56, -- 652
			y = 0, -- 652
			label = "井背 180–268 · 高 56", -- 652
			lanes = {"lower"}, -- 652
			art = "cover_stone", -- 652
			id = "s1_well" -- 652
		}, -- 652
		{ -- 653
			x = 360, -- 653
			w = 160, -- 653
			h = 44, -- 653
			y = 0, -- 653
			label = "摊后柜台 360–520 · 高 44", -- 653
			lanes = {"lower", "middle"}, -- 653
			art = "cover_wood" -- 653
		}, -- 653
		{ -- 654
			x = 620, -- 654
			w = 44, -- 654
			h = 24, -- 654
			y = 0, -- 654
			label = "观察转角石基 620–664 · 高 24", -- 654
			lanes = {"lower"} -- 654
		}, -- 654
		{ -- 655
			x = 1130, -- 655
			w = 20, -- 655
			h = 120, -- 655
			y = 0, -- 655
			label = "窗柱左", -- 655
			lanes = {"lower"}, -- 655
			art = "wall" -- 655
		}, -- 655
		{ -- 656
			x = 1150, -- 656
			w = 80, -- 656
			h = 44, -- 656
			y = 0, -- 656
			label = "窗台 1150–1230 · 高 44", -- 656
			lanes = {"lower"} -- 656
		}, -- 656
		{ -- 657
			x = 1230, -- 657
			w = 20, -- 657
			h = 120, -- 657
			y = 0, -- 657
			label = "窗柱右", -- 657
			lanes = {"lower"}, -- 657
			art = "wall" -- 657
		}, -- 657
		{ -- 658
			x = 1460, -- 658
			w = 40, -- 658
			h = 140, -- 658
			y = 0, -- 658
			label = "街尾门柱", -- 658
			lanes = {"lower", "upper"}, -- 658
			art = "gate_post" -- 658
		} -- 658
	}, -- 658
	zones = {{ -- 660
		x0 = 700, -- 660
		x1 = 960, -- 660
		y = 0, -- 660
		h = 150, -- 660
		tint = 1, -- 660
		label = "街角交火 700–960" -- 660
	}}, -- 660
	arch = { -- 661
		x0 = 0, -- 661
		x1 = 0, -- 661
		y = 0, -- 661
		h = 0, -- 661
		label = "" -- 661
	}, -- 661
	stairs = {{ -- 662
		x0 = 900, -- 662
		x1 = 1040, -- 662
		y0 = 0, -- 662
		y1 = 40, -- 662
		steps = 4, -- 662
		label = "石基斜走 900–1040 · 高 40" -- 662
	}}, -- 662
	cart = NO_CART, -- 663
	spawns = {{ -- 664
		x = 760, -- 665
		y = 0, -- 665
		h = 84, -- 665
		depth = 32, -- 665
		label = "单方向火器手 760", -- 665
		kind = "gunner", -- 665
		drop = "ammo" -- 665
	}, { -- 665
		x = 880, -- 666
		y = 0, -- 666
		h = 84, -- 666
		label = "街角压近者 880", -- 666
		kind = "breaker", -- 666
		drop = "wedge" -- 666
	}}, -- 666
	marks = {{x = 220, y = 0, kind = 1, label = "井背安全点 220"}, {x = 640, y = 0, kind = 0, label = "观察转角 640"}, {x = 1190, y = 0, kind = 0, label = "窗台捷径 1190"}, {x = 1500, y = 0, kind = 0, label = "出口 1500"}}, -- 668
	dims = {{x0 = 180, x1 = 268, text = "井 88"}, {x0 = 360, x1 = 520, text = "柜台 160"}, {x0 = 900, x1 = 1040, text = "石基 140"}}, -- 674
	companion = {waitX = 220, waitDepth = -32, joinX = 900}, -- 679
	campaign = { -- 680
		chapter = "S", -- 680
		act = 1, -- 680
		budget = 210, -- 680
		goal = "reach_exit", -- 680
		next = "s2-drygoods", -- 680
		exitX = 1500, -- 680
		checkpoint = 1 -- 680
	} -- 680
} -- 680
--- S2 布行与外檐：近檐柱下短跨、可碎摊挡与转角装卸面是一条线；
-- 从染布架侧面进布行、绕柜到窗板背后放板、后仓折回是另一条线。两条线同通牌楼。
____exports.S2_DRYGOODS = { -- 687
	key = "s2-drygoods", -- 688
	name = "S2 · 布行与外檐", -- 689
	caption = "近檐：檐柱短跨、薄木摊挡、装卸面。远帘：染布架入内、绕柜、放窗板、后仓折回。两路同通牌楼。", -- 690
	originX = 1600, -- 691
	minX = 0, -- 692
	maxX = 1800, -- 693
	height = 230, -- 694
	depth = LANE_ROAD, -- 695
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 696
	pickups = {{ -- 697
		id = "s2_scrap_1", -- 698
		kind = "scrap", -- 698
		x = 520, -- 698
		y = 0, -- 698
		depth = 0, -- 698
		label = "废木料 · 薄木摊挡脚下" -- 698
	}, { -- 698
		id = "s2_scrap_2", -- 699
		kind = "scrap", -- 699
		x = 760, -- 699
		y = 0, -- 699
		depth = 0, -- 699
		label = "废木料 · 装卸面旁" -- 699
	}}, -- 699
	solids = { -- 701
		{ -- 702
			x = 100, -- 702
			w = 24, -- 702
			h = 130, -- 702
			y = 0, -- 702
			label = "檐柱 100", -- 702
			lanes = {"middle"}, -- 702
			art = "cover_wood" -- 702
		}, -- 702
		{ -- 703
			x = 240, -- 703
			w = 24, -- 703
			h = 130, -- 703
			y = 0, -- 703
			label = "檐柱 240", -- 703
			lanes = {"middle"}, -- 703
			art = "cover_wood" -- 703
		}, -- 703
		{ -- 704
			x = 460, -- 705
			w = 100, -- 705
			h = 48, -- 705
			y = 0, -- 705
			label = "薄木摊挡 460–560 · 高 48", -- 705
			lanes = {"middle", "upper"}, -- 705
			art = "thin_wood", -- 706
			id = "s2_wood", -- 706
			breakable = {kind = "thin_wood", hp = 2, wedgeHp = 1} -- 706
		}, -- 706
		{ -- 708
			x = 620, -- 708
			w = 40, -- 708
			h = 130, -- 708
			y = 0, -- 708
			label = "永久石柱 620–660", -- 708
			lanes = {"upper"}, -- 708
			art = "cover_stone" -- 708
		}, -- 708
		{ -- 709
			x = 700, -- 709
			w = 120, -- 709
			h = 32, -- 709
			y = 0, -- 709
			label = "转角装卸面 700–820 · 高 32", -- 709
			lanes = {"middle"} -- 709
		}, -- 709
		{ -- 710
			x = 340, -- 710
			w = 120, -- 710
			h = 44, -- 710
			y = 0, -- 710
			label = "布行柜台 340–460 · 高 44", -- 710
			lanes = {"upper"}, -- 710
			art = "cover_wood" -- 710
		}, -- 710
		{ -- 711
			x = 600, -- 712
			w = 80, -- 712
			h = 72, -- 712
			y = 0, -- 712
			label = "窗板背后 600–680", -- 712
			lanes = {"upper"}, -- 712
			art = "board", -- 713
			id = "s2_board", -- 713
			interact = {kind = "open_board", reach = 46} -- 713
		}, -- 713
		{ -- 715
			x = 600, -- 716
			w = 80, -- 716
			h = 40, -- 716
			y = 0, -- 716
			label = "放下的窗板 600–680", -- 716
			lanes = {"lower"}, -- 716
			art = "board", -- 717
			id = "s2_board_cover", -- 717
			soft = true -- 717
		}, -- 717
		{ -- 719
			x = 1560, -- 719
			w = 30, -- 719
			h = 150, -- 719
			y = 0, -- 719
			label = "牌楼左柱", -- 719
			lanes = {"lower", "upper"}, -- 719
			art = "gate_post" -- 719
		}, -- 719
		{ -- 720
			x = 1700, -- 720
			w = 30, -- 720
			h = 150, -- 720
			y = 0, -- 720
			label = "牌楼右柱", -- 720
			lanes = {"lower", "upper"}, -- 720
			art = "gate_post" -- 720
		} -- 720
	}, -- 720
	zones = {{ -- 722
		x0 = 640, -- 722
		x1 = 1300, -- 722
		y = 0, -- 722
		h = 150, -- 722
		tint = 1, -- 722
		label = "转角装卸面交火 700–1200" -- 722
	}}, -- 722
	arch = { -- 723
		x0 = 0, -- 723
		x1 = 0, -- 723
		y = 0, -- 723
		h = 0, -- 723
		label = "" -- 723
	}, -- 723
	stairs = {}, -- 724
	cart = NO_CART, -- 725
	spawns = {{ -- 726
		x = 940, -- 727
		y = 0, -- 727
		h = 84, -- 727
		depth = 0, -- 727
		label = "持盾手 940", -- 727
		kind = "shield", -- 727
		shieldHp = 2, -- 727
		drop = "shield" -- 727
	}, { -- 727
		x = 1060, -- 728
		y = 0, -- 728
		h = 84, -- 728
		depth = 32, -- 728
		label = "远侧火器手 1060", -- 728
		kind = "gunner", -- 728
		drop = "ammo" -- 728
	}, { -- 728
		x = 1140, -- 729
		y = 0, -- 729
		h = 84, -- 729
		depth = 0, -- 729
		label = "破障手 1140", -- 729
		kind = "breaker", -- 729
		drop = "wedge" -- 729
	}}, -- 729
	marks = {{x = 640, y = 0, kind = 1, label = "窗板后等待位 640"}, {x = 900, y = 0, kind = 0, label = "后仓汇合口 900"}, {x = 1740, y = 0, kind = 0, label = "牌楼出口 1740"}}, -- 731
	dims = {{x0 = 100, x1 = 124, text = "檐柱 24"}, {x0 = 460, x1 = 560, text = "摊挡 100"}, {x0 = 700, x1 = 820, text = "装卸面 120"}}, -- 736
	companion = {waitX = 640, waitDepth = 32, joinX = 900, followAfter = "open_board"}, -- 741
	campaign = { -- 742
		chapter = "S", -- 742
		act = 2, -- 742
		budget = 390, -- 742
		goal = "reach_exit", -- 742
		next = "s3-archway", -- 742
		exitX = 1740, -- 742
		checkpoint = 2 -- 742
	} -- 742
} -- 742
--- S3 牌楼后巷：外檐线从低处进、布行线从高处进，两条入口在墙脚汇合。
-- 装卸坡可先上去看同一堆粮袋的敌位，再退半层接小满；也可以沿墙脚直接绕。
____exports.S3_ARCHWAY = { -- 749
	key = "s3-archway", -- 750
	name = "S3 · 牌楼后巷", -- 751
	caption = "两高度入口看同一粮袋。登装卸坡看敌位再退半层接人，或沿墙脚绕走；候检门前两人停。", -- 752
	originX = 3400, -- 753
	minX = 0, -- 754
	maxX = 1400, -- 755
	height = 230, -- 756
	depth = LANE_ROAD, -- 757
	floors = {{y = 0, x0 = 0, x1 = 1400}}, -- 758
	solids = { -- 759
		{ -- 760
			x = 0, -- 760
			w = 180, -- 760
			h = 32, -- 760
			y = 0, -- 760
			label = "高处进口台 0–180 · 高 32", -- 760
			lanes = {"upper"} -- 760
		}, -- 760
		{ -- 761
			x = 380, -- 761
			w = 140, -- 761
			h = 64, -- 761
			y = 0, -- 761
			label = "装卸高台 380–520 · 高 64", -- 761
			lanes = {"upper"} -- 761
		}, -- 761
		{ -- 762
			x = 560, -- 762
			w = 160, -- 762
			h = 48, -- 762
			y = 0, -- 762
			label = "粮袋堆 560–720 · 高 48", -- 762
			lanes = {"lower", "middle"} -- 762
		}, -- 762
		{ -- 763
			x = 1260, -- 763
			w = 30, -- 763
			h = 140, -- 763
			y = 0, -- 763
			label = "候检门左柱", -- 763
			lanes = {"lower", "upper"}, -- 763
			art = "gate_post" -- 763
		}, -- 763
		{ -- 764
			x = 1330, -- 764
			w = 30, -- 764
			h = 140, -- 764
			y = 0, -- 764
			label = "候检门右柱", -- 764
			lanes = {"lower", "upper"}, -- 764
			art = "gate_post" -- 764
		} -- 764
	}, -- 764
	zones = {{ -- 766
		x0 = 780, -- 766
		x1 = 1060, -- 766
		y = 0, -- 766
		h = 150, -- 766
		tint = 1, -- 766
		label = "后巷交火 780–1060" -- 766
	}}, -- 766
	arch = { -- 767
		x0 = 0, -- 767
		x1 = 0, -- 767
		y = 0, -- 767
		h = 0, -- 767
		label = "" -- 767
	}, -- 767
	stairs = {{ -- 768
		x0 = 140, -- 769
		x1 = 200, -- 769
		y0 = 0, -- 769
		y1 = 32, -- 769
		steps = 3, -- 769
		label = "进口台阶" -- 769
	}, { -- 769
		x0 = 260, -- 770
		x1 = 380, -- 770
		y0 = 0, -- 770
		y1 = 64, -- 770
		steps = 4, -- 770
		label = "装卸坡 260–380 · 高 64" -- 770
	}}, -- 770
	cart = NO_CART, -- 772
	spawns = {{ -- 773
		x = 860, -- 774
		y = 0, -- 774
		h = 84, -- 774
		depth = 32, -- 774
		label = "高处火器手 860", -- 774
		kind = "gunner", -- 774
		drop = "ammo" -- 774
	}, { -- 774
		x = 980, -- 775
		y = 0, -- 775
		h = 84, -- 775
		depth = 0, -- 775
		label = "墙脚火器手 980", -- 775
		kind = "gunner", -- 775
		drop = "ammo" -- 775
	}}, -- 775
	marks = {{x = 440, y = 0, kind = 0, label = "装卸坡观察位 440"}, {x = 620, y = 0, kind = 1, label = "粮袋后安全点 620"}, {x = 1300, y = 0, kind = 0, label = "候检门前 1300"}}, -- 777
	dims = {{x0 = 260, x1 = 380, text = "装卸坡 120"}, {x0 = 560, x1 = 720, text = "粮袋 160"}}, -- 782
	companion = {waitX = 620, waitDepth = 0, joinX = 1240}, -- 783
	campaign = { -- 784
		chapter = "S", -- 784
		act = 3, -- 784
		budget = 180, -- 784
		goal = "reach_exit", -- 784
		next = "c1-yard", -- 784
		exitX = 1320, -- 784
		checkpoint = 3 -- 784
	} -- 784
} -- 784
--- C1 候检院：侧门横闩在门背，粮棚可见但被队栏、查验台与棚柱交错挡住。
-- 绕缺口进栏，截断压近者或穿查验台后到棚口；正面看门，转到背面才抬得动闩。
____exports.C1_YARD = { -- 791
	key = "c1-yard", -- 792
	name = "C1 · 候检院", -- 793
	caption = "队栏与查验台把粮棚切成几段。绕缺口进栏，压近者会截断通路；侧门横闩要转到门背才抬得动。", -- 794
	originX = 4800, -- 795
	minX = 0, -- 796
	maxX = 1900, -- 797
	height = 240, -- 798
	depth = LANE_ROAD, -- 799
	floors = {{y = 0, x0 = 0, x1 = 1900}}, -- 800
	solids = { -- 801
		{ -- 802
			x = 280, -- 802
			w = 340, -- 802
			h = 28, -- 802
			y = 0, -- 802
			label = "候检队栏 280–620 · 高 28", -- 802
			lanes = {"lower", "middle"}, -- 802
			art = "fence" -- 802
		}, -- 802
		{ -- 803
			x = 820, -- 803
			w = 180, -- 803
			h = 44, -- 803
			y = 0, -- 803
			label = "查验台 820–1000 · 高 44", -- 803
			lanes = {"lower", "middle"} -- 803
		}, -- 803
		{ -- 804
			x = 1100, -- 804
			w = 40, -- 804
			h = 150, -- 804
			y = 0, -- 804
			label = "棚柱 1100–1140", -- 804
			lanes = {"lower", "middle"}, -- 804
			art = "cover_wood" -- 804
		}, -- 804
		{ -- 805
			x = 1240, -- 805
			w = 40, -- 805
			h = 150, -- 805
			y = 0, -- 805
			label = "棚柱 1240–1280", -- 805
			lanes = {"lower", "middle"}, -- 805
			art = "cover_wood" -- 805
		}, -- 805
		{ -- 806
			x = 1600, -- 806
			w = 160, -- 806
			h = 48, -- 806
			y = 0, -- 806
			label = "粮棚袋堆 1600–1760 · 高 48", -- 806
			lanes = {"lower", "middle"} -- 806
		}, -- 806
		{ -- 807
			x = 1780, -- 807
			w = 50, -- 807
			h = 150, -- 807
			y = 0, -- 807
			label = "侧门 1780–1830", -- 807
			lanes = {"lower", "middle"}, -- 807
			art = "wall", -- 807
			id = "c1_door" -- 807
		}, -- 807
		{ -- 808
			x = 1810, -- 809
			w = 30, -- 809
			h = 24, -- 809
			y = 40, -- 809
			label = "侧门横闩（门背）", -- 809
			lanes = {"upper"}, -- 809
			art = "latch", -- 810
			id = "c1_latch", -- 810
			interact = {kind = "raise_latch", reach = 52} -- 810
		} -- 810
	}, -- 810
	zones = {{ -- 813
		x0 = 760, -- 813
		x1 = 1080, -- 813
		y = 0, -- 813
		h = 150, -- 813
		tint = 1, -- 813
		label = "查验台截断 820–1000" -- 813
	}}, -- 813
	arch = { -- 814
		x0 = 0, -- 814
		x1 = 0, -- 814
		y = 0, -- 814
		h = 0, -- 814
		label = "" -- 814
	}, -- 814
	stairs = {}, -- 815
	cart = NO_CART, -- 816
	spawns = {{ -- 817
		x = 900, -- 818
		y = 0, -- 818
		h = 84, -- 818
		depth = 0, -- 818
		label = "截断压近者 900", -- 818
		kind = "breaker", -- 818
		drop = "wedge" -- 818
	}, { -- 818
		x = 1200, -- 819
		y = 0, -- 819
		h = 84, -- 819
		depth = 32, -- 819
		label = "棚柱后火器手 1200", -- 819
		kind = "gunner", -- 819
		drop = "ammo" -- 819
	}}, -- 819
	marks = {{x = 1000, y = 0, kind = 1, label = "查验台后等待位 1000"}, {x = 1700, y = 0, kind = 0, label = "侧门正面 1700"}, {x = 1860, y = 0, kind = 0, label = "门背出口 1860"}}, -- 821
	dims = {{x0 = 820, x1 = 1000, text = "查验台 180"}, {x0 = 1780, x1 = 1830, text = "侧门 50"}}, -- 826
	companion = {waitX = 1000, waitDepth = 0, joinX = 1700, followAfter = "raise_latch"}, -- 827
	campaign = { -- 828
		chapter = "C", -- 828
		act = 1, -- 828
		budget = 270, -- 828
		goal = "raise_latch", -- 828
		next = "c2-granary", -- 828
		exitX = 1860, -- 828
		checkpoint = 4 -- 828
	} -- 828
} -- 828
--- C2 军粮棚：粮袋安全区居中，远柱木帘与近侧车轨分列。
-- 有残盾可以在暴露轨段架起来挡一发；空手路线先绕上远柱放帘，再回来握车柄。
____exports.C2_GRANARY = { -- 835
	key = "c2-granary", -- 836
	name = "C2 · 军粮棚", -- 837
	caption = "空筐围挡、暴露轨段与远柱木帘。先绕上远柱放帘，或架残盾，再握车柄把车推入轮窝并抬连杆闩。", -- 838
	originX = 6700, -- 839
	minX = 0, -- 840
	maxX = 1800, -- 841
	height = 240, -- 842
	depth = LANE_ROAD, -- 843
	floors = {{y = 0, x0 = 0, x1 = 1800}}, -- 844
	solids = { -- 845
		{ -- 846
			x = 900, -- 847
			w = 120, -- 847
			h = 44, -- 847
			y = 0, -- 847
			label = "空筐围挡 900–1020 · 高 44", -- 847
			lanes = {"lower", "middle"}, -- 847
			art = "basket_wall", -- 848
			id = "c2_basket", -- 848
			breakable = {kind = "basket_wall", hp = 2, wedgeable = false} -- 848
		}, -- 848
		{ -- 850
			x = 600, -- 850
			w = 300, -- 850
			h = 48, -- 850
			y = 0, -- 850
			label = "粮袋安全区 600–900 · 高 48", -- 850
			lanes = {"lower", "middle"} -- 850
		}, -- 850
		{ -- 851
			x = 980, -- 851
			w = 40, -- 851
			h = 24, -- 851
			y = 0, -- 851
			label = "棚口下轨台 980–1020 · 高 24", -- 851
			lanes = {"lower", "middle"} -- 851
		}, -- 851
		{ -- 852
			x = 1200, -- 853
			w = 40, -- 853
			h = 150, -- 853
			y = 0, -- 853
			label = "远柱 1200–1240 · 高 150", -- 853
			lanes = {"upper"}, -- 853
			art = "cover_wood", -- 854
			id = "c2_post", -- 854
			interact = {kind = "lower_curtain", reach = 46} -- 854
		}, -- 854
		{ -- 856
			x = 1240, -- 857
			w = 120, -- 857
			h = 120, -- 857
			y = 24, -- 857
			label = "木帘落点 1240–1360", -- 857
			lanes = {"lower", "middle"}, -- 857
			art = "curtain", -- 858
			soft = true, -- 858
			id = "c2_curtain", -- 858
			hidden = true -- 858
		}, -- 858
		{ -- 860
			x = 1560, -- 861
			w = 30, -- 861
			h = 24, -- 861
			y = 40, -- 861
			label = "连杆抬闩 1560–1590", -- 861
			lanes = {"middle"}, -- 861
			art = "latch", -- 862
			id = "c2_latch", -- 862
			interact = {kind = "raise_latch", reach = 50} -- 862
		}, -- 862
		{ -- 864
			x = 1720, -- 864
			w = 30, -- 864
			h = 150, -- 864
			y = 0, -- 864
			label = "棚尾门柱", -- 864
			lanes = {"lower", "upper"}, -- 864
			art = "gate_post" -- 864
		} -- 864
	}, -- 864
	zones = {{ -- 866
		x0 = 1000, -- 866
		x1 = 1200, -- 866
		y = 0, -- 866
		h = 150, -- 866
		tint = 1, -- 866
		label = "暴露轨段 1000–1200" -- 866
	}}, -- 866
	arch = { -- 867
		x0 = 0, -- 867
		x1 = 0, -- 867
		y = 0, -- 867
		h = 0, -- 867
		label = "" -- 867
	}, -- 867
	stairs = {}, -- 868
	cart = { -- 869
		startX = 1150, -- 870
		endX = 1500, -- 870
		baseY = 0, -- 870
		depth = 0, -- 870
		bodyW = 48, -- 870
		bodyH = 26, -- 870
		wheelR = 12, -- 870
		handleOffset = -50, -- 870
		clothSide = -1 -- 870
	}, -- 870
	spawns = {{ -- 872
		x = 1580, -- 873
		y = 0, -- 873
		h = 84, -- 873
		depth = 0, -- 873
		label = "棚尾火器手 1580", -- 873
		kind = "gunner", -- 873
		drop = "ammo" -- 873
	}, { -- 873
		x = 1340, -- 874
		y = 0, -- 874
		h = 84, -- 874
		depth = 32, -- 874
		label = "远侧持盾手 1340", -- 874
		kind = "shield", -- 874
		shieldHp = 2, -- 874
		drop = "shield" -- 874
	}}, -- 874
	marks = {{x = 760, y = 0, kind = 1, label = "袋堆后等待位 760"}, {x = 1100, y = 0, kind = 0, label = "车柄 1100"}, {x = 1500, y = 0, kind = 0, label = "轮窝 1500"}, {x = 1700, y = 0, kind = 0, label = "棚尾出口 1700"}}, -- 876
	dims = {{x0 = 1150, x1 = 1500, text = "推车 350"}, {x0 = 1240, x1 = 1360, text = "木帘 120"}}, -- 882
	companion = {waitX = 760, waitDepth = 0, joinX = 1700}, -- 883
	campaign = { -- 884
		chapter = "C", -- 884
		act = 2, -- 884
		budget = 360, -- 884
		goal = "dock_cart", -- 884
		exitX = 1700, -- 884
		checkpoint = 5 -- 884
	} -- 884
} -- 884
____exports.CAMPAIGN_ROOMS = { -- 887
	____exports.S1_CROSSROAD, -- 887
	____exports.S2_DRYGOODS, -- 887
	____exports.S3_ARCHWAY, -- 887
	____exports.C1_YARD, -- 887
	____exports.C2_GRANARY -- 887
} -- 887
____exports.ROOMS = { -- 895
	____exports.PROLOGUE_ROOM, -- 895
	____exports.STREET_ROOM, -- 895
	____exports.CHECKPOINT_ROOM, -- 895
	____exports.GATE_ROOM, -- 895
	____exports.OUTSIDE_ROOM, -- 895
	____exports.VILLAGE_ROOM, -- 895
	____exports.FOREST_ROOM, -- 895
	____exports.TOWER_ROOM -- 895
} -- 895
local function placeSolids(room) -- 906
	local blocks = {} -- 907
	for ____, solid in ipairs(room.solids) do -- 908
		local x = solid.x + room.originX -- 909
		if room.depth ~= nil and solid.lanes ~= nil then -- 909
			for ____, depth in ipairs(laneFootprints(solid.lanes)) do -- 911
				blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x, depth = depth, lanes = nil}) -- 912
			end -- 912
		else -- 912
			blocks[#blocks + 1] = __TS__ObjectAssign({}, solid, {x = x}) -- 915
		end -- 915
	end -- 915
	return blocks -- 918
end -- 906
--- 把段内坐标搬进世界坐标：只加 originX，段内锚点一律不改。
-- 返回新对象，`rooms.ts` 里的常量保持可读的段内读数。
function ____exports.withOrigin(room) -- 925
	local ox = room.originX -- 926
	if ox == 0 then -- 926
		return room.depth == nil and room or __TS__ObjectAssign( -- 928
			{}, -- 928
			room, -- 928
			{solids = placeSolids(room)} -- 928
		) -- 928
	end -- 928
	local function shift(x) -- 930
		return x + ox -- 930
	end -- 930
	local ____room_key_7 = room.key -- 932
	local ____room_name_8 = room.name -- 933
	local ____room_caption_9 = room.caption -- 934
	local ____shift_result_10 = shift(room.minX) -- 936
	local ____shift_result_11 = shift(room.maxX) -- 937
	local ____room_height_12 = room.height -- 938
	local ____room_depth_13 = room.depth -- 939
	local ____TS__ArrayMap_result_14 = __TS__ArrayMap( -- 940
		room.floors, -- 940
		function(____, f) return { -- 940
			y = f.y, -- 940
			x0 = shift(f.x0), -- 940
			x1 = shift(f.x1) -- 940
		} end -- 940
	) -- 940
	local ____placeSolids_result_15 = placeSolids(room) -- 941
	local ____TS__ArrayMap_result_16 = __TS__ArrayMap( -- 942
		room.zones, -- 942
		function(____, z) return { -- 942
			x0 = shift(z.x0), -- 942
			x1 = shift(z.x1), -- 942
			y = z.y, -- 942
			h = z.h, -- 942
			tint = z.tint, -- 942
			label = z.label -- 942
		} end -- 942
	) -- 942
	local ____temp_17 = { -- 943
		x0 = shift(room.arch.x0), -- 943
		x1 = shift(room.arch.x1), -- 943
		y = room.arch.y, -- 943
		h = room.arch.h, -- 943
		label = room.arch.label -- 943
	} -- 943
	local ____TS__ArrayMap_result_18 = __TS__ArrayMap( -- 944
		room.stairs, -- 944
		function(____, s) return { -- 944
			x0 = shift(s.x0), -- 944
			x1 = shift(s.x1), -- 944
			y0 = s.y0, -- 944
			y1 = s.y1, -- 944
			steps = s.steps, -- 944
			label = s.label -- 944
		} end -- 944
	) -- 944
	local ____TS__ObjectAssign_result_19 = __TS__ObjectAssign( -- 945
		{}, -- 945
		room.cart, -- 946
		{ -- 945
			startX = shift(room.cart.startX), -- 947
			endX = shift(room.cart.endX) -- 948
		} -- 948
	) -- 948
	local ____TS__ArrayMap_result_20 = __TS__ArrayMap( -- 950
		room.spawns, -- 950
		function(____, s) return __TS__ObjectAssign( -- 950
			{}, -- 950
			s, -- 950
			{x = shift(s.x)} -- 950
		) end -- 950
	) -- 950
	local ____TS__ArrayMap_result_21 = __TS__ArrayMap( -- 951
		room.marks, -- 951
		function(____, m) return { -- 951
			x = shift(m.x), -- 951
			y = m.y, -- 951
			kind = m.kind, -- 951
			label = m.label -- 951
		} end -- 951
	) -- 951
	local ____TS__ArrayMap_result_22 = __TS__ArrayMap( -- 952
		room.dims, -- 952
		function(____, d) return { -- 952
			x0 = shift(d.x0), -- 952
			x1 = shift(d.x1), -- 952
			text = d.text -- 952
		} end -- 952
	) -- 952
	local ____temp_0 -- 953
	if room.scavenger == nil then -- 953
		____temp_0 = nil -- 953
	else -- 953
		____temp_0 = { -- 953
			x0 = shift(room.scavenger.x0), -- 954
			x1 = shift(room.scavenger.x1), -- 954
			y = room.scavenger.y, -- 954
			h = room.scavenger.h, -- 954
			patrolSpeed = room.scavenger.patrolSpeed, -- 955
			approachSpeed = room.scavenger.approachSpeed, -- 955
			hearTicks = room.scavenger.hearTicks, -- 956
			stallTicks = room.scavenger.stallTicks, -- 956
			range = room.scavenger.range -- 956
		} -- 956
	end -- 956
	local ____temp_1 -- 958
	if room.bottle == nil then -- 958
		____temp_1 = nil -- 958
	else -- 958
		____temp_1 = { -- 958
			x = shift(room.bottle.x), -- 958
			y = room.bottle.y -- 958
		} -- 958
	end -- 958
	local ____temp_2 -- 959
	if room.brickX == nil then -- 959
		____temp_2 = nil -- 959
	else -- 959
		____temp_2 = shift(room.brickX) -- 959
	end -- 959
	local ____temp_3 -- 960
	if room.softX == nil then -- 960
		____temp_3 = nil -- 960
	else -- 960
		____temp_3 = shift(room.softX) -- 960
	end -- 960
	local ____temp_4 -- 961
	if room.passLine == nil then -- 961
		____temp_4 = nil -- 961
	else -- 961
		____temp_4 = shift(room.passLine) -- 961
	end -- 961
	local ____temp_5 -- 962
	if room.campaign == nil then -- 962
		____temp_5 = nil -- 962
	else -- 962
		____temp_5 = __TS__ObjectAssign( -- 962
			{}, -- 962
			room.campaign, -- 962
			{exitX = shift(room.campaign.exitX)} -- 962
		) -- 962
	end -- 962
	local ____temp_6 -- 963
	if room.pickups == nil then -- 963
		____temp_6 = nil -- 963
	else -- 963
		____temp_6 = __TS__ArrayMap( -- 963
			room.pickups, -- 963
			function(____, p) return __TS__ObjectAssign( -- 963
				{}, -- 963
				p, -- 963
				{x = shift(p.x)} -- 963
			) end -- 963
		) -- 963
	end -- 963
	return { -- 931
		key = ____room_key_7, -- 932
		name = ____room_name_8, -- 933
		caption = ____room_caption_9, -- 934
		originX = 0, -- 935
		minX = ____shift_result_10, -- 936
		maxX = ____shift_result_11, -- 937
		height = ____room_height_12, -- 938
		depth = ____room_depth_13, -- 939
		floors = ____TS__ArrayMap_result_14, -- 940
		solids = ____placeSolids_result_15, -- 941
		zones = ____TS__ArrayMap_result_16, -- 942
		arch = ____temp_17, -- 943
		stairs = ____TS__ArrayMap_result_18, -- 944
		cart = ____TS__ObjectAssign_result_19, -- 945
		spawns = ____TS__ArrayMap_result_20, -- 950
		marks = ____TS__ArrayMap_result_21, -- 951
		dims = ____TS__ArrayMap_result_22, -- 952
		scavenger = ____temp_0, -- 953
		bottle = ____temp_1, -- 958
		brickX = ____temp_2, -- 959
		softX = ____temp_3, -- 960
		passLine = ____temp_4, -- 961
		campaign = ____temp_5, -- 962
		pickups = ____temp_6, -- 963
		companion = room.companion, -- 964
		story = shiftStory(room.story, ox) -- 965
	} -- 965
end -- 925
return ____exports -- 925