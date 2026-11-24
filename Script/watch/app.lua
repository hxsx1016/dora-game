-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local place, setMode, enterPlayRoom, pickByIndex, applySize, tick, registerPlay, ensurePlay, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock -- 1
local ____Dora = require("Dora") -- 8
local Color = ____Dora.Color -- 8
local DrawNode = ____Dora.DrawNode -- 8
local Label = ____Dora.Label -- 8
local Node = ____Dora.Node -- 8
local Rect = ____Dora.Rect -- 8
local Size = ____Dora.Size -- 8
local Vec2 = ____Dora.Vec2 -- 8
local View = ____Dora.View -- 8
local ____graybox = require("Script.watch.graybox") -- 9
local collectLabels = ____graybox.collectLabels -- 9
local computeView = ____graybox.computeView -- 9
local drawScaleRuler = ____graybox.drawScaleRuler -- 9
local renderWorld = ____graybox.renderWorld -- 9
local ____keys = require("Script.watch.keys") -- 10
local CART_NOTE = ____keys.CART_NOTE -- 10
local HINTS = ____keys.HINTS -- 10
local RULER_TEXT = ____keys.RULER_TEXT -- 10
local STAND_NOTE = ____keys.STAND_NOTE -- 10
local SWITCH_HINT = ____keys.SWITCH_HINT -- 10
local TITLE = ____keys.TITLE -- 10
local ____rooms = require("Script.watch.rooms") -- 11
local CAMPAIGN_ROOMS = ____rooms.CAMPAIGN_ROOMS -- 11
local ROOMS = ____rooms.ROOMS -- 11
local ____input = require("Script.watch.input") -- 12
local Input = ____input.Input -- 12
local ____play = require("Script.watch.play") -- 13
local Play = ____play.Play -- 13
local ____clock = require("Script.watch.clock") -- 14
local STEP = ____clock.STEP -- 14
local StepClock = ____clock.StepClock -- 14
local ____frontend = require("Script.watch.fe.frontend") -- 15
local WatchFrontend = ____frontend.WatchFrontend -- 15
local ____run = require("Script.watch.run") -- 16
local createRun = ____run.createRun -- 16
local mmss = ____run.mmss -- 16
function place(lb, x, y, ax, ay) -- 80
	if lb == nil then -- 80
		return -- 82
	end -- 82
	lb.position = Vec2(x, y) -- 84
	lb.anchor = Vec2(ax, ay) -- 85
	lb.visible = true -- 86
end -- 86
function setMode(nextMode) -- 254
	mode = nextMode -- 255
	if grayboxLayer ~= nil then -- 255
		grayboxLayer.visible = mode == 0 -- 257
	end -- 257
	if fe ~= nil then -- 257
		fe:setVisible(mode == 1) -- 260
	end -- 260
	if campaignLayer ~= nil then -- 260
		campaignLayer.visible = mode == 2 -- 263
	end -- 263
	dirty = true -- 265
	clock:reset() -- 266
end -- 266
function enterPlayRoom(idx) -- 269
	current = idx -- 270
	setMode(1) -- 271
	if fe ~= nil then -- 271
		fe.screen = "play" -- 273
	end -- 273
	play = nil -- 275
	ensurePlay() -- 276
end -- 276
function pickByIndex(idx) -- 279
	if mode == 2 then -- 279
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 279
			return -- 282
		end -- 282
		current = idx -- 284
		play = nil -- 285
		clock:reset() -- 286
		ensurePlay() -- 287
		return -- 288
	end -- 288
	if idx < 0 or idx >= #ROOMS then -- 288
		return -- 291
	end -- 291
	current = idx -- 293
	dirty = true -- 294
	play = nil -- 295
	clock:reset() -- 296
	if mode == 1 then -- 296
		if fe ~= nil then -- 296
			fe.screen = "play" -- 299
		end -- 299
		ensurePlay() -- 301
	end -- 301
end -- 301
function applySize() -- 305
	if root == nil then -- 305
		return -- 307
	end -- 307
	root.size = Size(viewW, viewH) -- 309
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 310
end -- 310
function tick(frameDt) -- 313
	local w = View.size.width -- 314
	local h = View.size.height -- 315
	if w ~= viewW or h ~= viewH then -- 315
		viewW = w -- 317
		viewH = h -- 318
		applySize() -- 319
		dirty = true -- 320
	end -- 320
	if input == nil then -- 320
		return -- 323
	end -- 323
	input:update() -- 325
	if input.toggleView.pressed then -- 325
		input.toggleView.pressed = false -- 329
		setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 330
		if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 330
			ensurePlay() -- 332
		end -- 332
	end -- 332
	if input.pickRoom ~= 0 then -- 332
		local idx = input.pickRoom - 1 -- 338
		input.pickRoom = 0 -- 339
		pickByIndex(idx) -- 340
	elseif input.tab.pressed then -- 340
		input.tab.pressed = false -- 342
		if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 342
			pickByIndex((current + 1) % #ROOMS) -- 344
		end -- 344
	end -- 344
	if mode == 2 then -- 344
		tickCampaign(frameDt) -- 349
		return -- 350
	end -- 350
	if mode == 1 then -- 350
		tickFrontend(frameDt) -- 353
		return -- 354
	end -- 354
	if dirty then -- 354
		redrawGraybox() -- 357
		dirty = false -- 358
	end -- 358
end -- 358
function registerPlay() -- 363
	local reg = _G.package.loaded -- 364
	reg["watch.play"] = play -- 365
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 366
	reg["watch.room"] = rooms[current + 1].key -- 367
end -- 367
function ensurePlay(resume) -- 371
	if mode == 2 then -- 371
		if run == nil then -- 371
			run = createRun() -- 374
		end -- 374
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 376
	else -- 376
		play = __TS__New(Play, ROOMS[current + 1], resume) -- 378
	end -- 378
	registerPlay() -- 380
	clock:reset() -- 381
	if fe ~= nil and mode == 1 then -- 381
		fe:bindPlay(play, viewW, viewH) -- 383
	end -- 383
end -- 383
function tickCampaign(frameDt) -- 388
	if input == nil then -- 388
		return -- 390
	end -- 390
	if play == nil then -- 390
		ensurePlay() -- 393
	end -- 393
	if play == nil then -- 393
		return -- 396
	end -- 396
	local p = play -- 398
	p.aimX = input.mx -- 399
	p.aimY = input.my -- 400
	if input.retry.pressed then -- 400
		input.retry.pressed = false -- 403
		input:consumeEdges() -- 404
		play = nil -- 406
		ensurePlay() -- 407
		return -- 408
	end -- 408
	if input.pause.pressed then -- 408
		input.pause.pressed = false -- 411
		p.paused = not p.paused -- 412
		clock:reset() -- 413
		input:consumeEdges() -- 414
	end -- 414
	if p.paused then -- 414
		drawCampaign(p) -- 417
		return -- 418
	end -- 418
	local steps = clock:advance(frameDt) -- 421
	local i = 0 -- 422
	do -- 422
		i = 0 -- 423
		while i < steps do -- 423
			input:beginStep(i == 0) -- 424
			p:update(STEP, input) -- 425
			input:endStep() -- 426
			if p.wantRoom ~= "" then -- 426
				break -- 428
			end -- 428
			i = i + 1 -- 423
		end -- 423
	end -- 423
	if p.wantRoom ~= "" then -- 423
		local key = p.wantRoom -- 433
		p.wantRoom = "" -- 434
		local idx = -1 -- 435
		local j = 0 -- 436
		do -- 436
			j = 0 -- 437
			while j < #CAMPAIGN_ROOMS do -- 437
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 437
					idx = j -- 439
				end -- 439
				j = j + 1 -- 437
			end -- 437
		end -- 437
		if idx >= 0 then -- 437
			current = idx -- 443
			play = nil -- 444
			ensurePlay() -- 445
		end -- 445
		return -- 447
	end -- 447
	drawCampaign(p) -- 449
end -- 449
function goalLabel(goal) -- 452
	if goal == "dock_cart" then -- 452
		return "推车入窝并抬闩" -- 454
	end -- 454
	if goal == "raise_latch" then -- 454
		return "抬闩开侧门" -- 457
	end -- 457
	return "到段出口" -- 459
end -- 459
function drawCampaign(p) -- 462
	if campaignDraw == nil then -- 462
		return -- 464
	end -- 464
	local w = viewW -- 466
	local h = viewH -- 467
	p:draw(campaignDraw, w, h) -- 468
	local room = CAMPAIGN_ROOMS[current + 1] -- 469
	local c = room.campaign -- 470
	local r = run -- 471
	local line = room.name -- 472
	if c ~= nil then -- 472
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 474
	end -- 474
	if p.paused then -- 474
		line = line .. "  · 已暂停 Esc 继续" -- 478
	end -- 478
	if campaignHud ~= nil then -- 478
		campaignHud.text = line -- 481
		campaignHud.position = Vec2(24, h - 14) -- 482
		campaignHud.visible = true -- 483
	end -- 483
	if campaignSub ~= nil then -- 483
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 486
		if r ~= nil then -- 486
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 488
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 489
		end -- 489
		if p.flash ~= "" then -- 489
			sub = (sub .. " · ") .. p.flash -- 495
		end -- 495
		campaignSub.text = sub -- 497
		campaignSub.position = Vec2(24, h - 44) -- 498
		campaignSub.visible = true -- 499
	end -- 499
end -- 499
function tickFrontend(frameDt) -- 503
	if fe == nil or input == nil then -- 503
		return -- 505
	end -- 505
	if fe.screen ~= "play" then -- 505
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 510
		input:consumeEdges() -- 511
		if act.type == "start" then -- 511
			enterPlayRoom(0) -- 513
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 513
			enterPlayRoom(act.roomIndex) -- 515
		elseif act.type == "openChapters" then -- 515
			fe.menus:openChapters() -- 517
			fe.screen = "chapters" -- 518
		elseif act.type == "openControls" then -- 518
			fe.menus:resetInput() -- 520
			fe.screen = "controls" -- 521
		elseif act.type == "backTitle" then -- 521
			fe.menus:resetInput() -- 523
			fe.screen = "title" -- 524
		elseif act.type == "backPause" then -- 524
			fe.menus:resetInput() -- 526
			fe.screen = "play" -- 527
		end -- 527
		return -- 529
	end -- 529
	if play == nil then -- 529
		ensurePlay() -- 534
	end -- 534
	if play == nil then -- 534
		return -- 537
	end -- 537
	local p = play -- 539
	if input.retry.pressed then -- 539
		input:consumeEdges() -- 542
		ensurePlay({checkpoint = p.checkpoint}) -- 544
		return -- 545
	end -- 545
	p.aimX = input.mx -- 548
	p.aimY = input.my -- 549
	if not p.paused and input.pause.pressed then -- 549
		p.paused = true -- 552
		p.aimHold = 0 -- 553
		p.bottleAimX = -1 -- 554
		fe.menus:openPause() -- 555
		input:consumeEdges() -- 556
	end -- 556
	if p.paused then -- 556
		clock:reset() -- 561
		local pauseAct = fe:renderPlay( -- 562
			frameDt, -- 562
			p, -- 562
			input, -- 562
			viewW, -- 562
			viewH -- 562
		) -- 562
		input:consumeEdges() -- 563
		if pauseAct.type == "resume" then -- 563
			p.paused = false -- 565
		elseif pauseAct.type == "retry" then -- 565
			ensurePlay({checkpoint = p.checkpoint}) -- 567
		elseif pauseAct.type == "openChapters" then -- 567
			fe.menus:openChapters(current) -- 569
			fe.screen = "chapters" -- 570
		elseif pauseAct.type == "toTitle" then -- 570
			fe.menus:resetInput() -- 572
			fe.screen = "title" -- 573
		end -- 573
		return -- 575
	end -- 575
	local steps = clock:advance(frameDt) -- 578
	local i = 0 -- 579
	do -- 579
		i = 0 -- 580
		while i < steps do -- 580
			input:beginStep(i == 0) -- 581
			p:update(STEP, input) -- 582
			input:endStep() -- 583
			if p.wantRoom ~= "" then -- 583
				break -- 585
			end -- 585
			i = i + 1 -- 580
		end -- 580
	end -- 580
	if p.wantRoom ~= "" then -- 580
		local key = p.wantRoom -- 591
		p.wantRoom = "" -- 592
		local idx = -1 -- 593
		local j = 0 -- 594
		do -- 594
			j = 0 -- 595
			while j < #ROOMS do -- 595
				if ROOMS[j + 1].key == key then -- 595
					idx = j -- 597
				end -- 597
				j = j + 1 -- 595
			end -- 595
		end -- 595
		if idx >= 0 then -- 595
			local leaving = p:drainEvents() -- 603
			current = idx -- 604
			ensurePlay() -- 605
			local fresh = play -- 606
			if fresh ~= nil then -- 606
				fresh:adoptEvents(leaving) -- 608
			end -- 608
			clock:reset() -- 610
			dirty = true -- 611
		end -- 611
		return -- 613
	end -- 613
	fe:renderPlay( -- 616
		frameDt, -- 616
		p, -- 616
		input, -- 616
		viewW, -- 616
		viewH -- 616
	) -- 616
end -- 616
function redrawGraybox() -- 620
	if draw == nil then -- 620
		return -- 622
	end -- 622
	local w = viewW -- 624
	local h = viewH -- 625
	local room = ROOMS[current + 1] -- 626
	draw:clear() -- 628
	draw:drawRect( -- 629
		Rect(0, h - TOP_H, w, TOP_H), -- 629
		C_BG -- 629
	) -- 629
	draw:drawRect( -- 630
		Rect(0, 0, w, BOTTOM_H), -- 630
		C_BG -- 630
	) -- 630
	draw:drawSegment( -- 631
		Vec2(0, h - TOP_H), -- 631
		Vec2(w, h - TOP_H), -- 631
		1, -- 631
		Color(52, 54, 54, 255) -- 631
	) -- 631
	draw:drawSegment( -- 632
		Vec2(0, BOTTOM_H), -- 632
		Vec2(w, BOTTOM_H), -- 632
		1, -- 632
		Color(52, 54, 54, 255) -- 632
	) -- 632
	local v = computeView(room, w, h) -- 634
	renderWorld( -- 635
		draw, -- 635
		room, -- 635
		v, -- 635
		w, -- 635
		h -- 635
	) -- 635
	local roomTop = v.groundPx + room.height * v.scale -- 637
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 638
	place( -- 640
		titleLabel, -- 640
		48, -- 640
		h - 40, -- 640
		0, -- 640
		1 -- 640
	) -- 640
	place( -- 641
		roomLabel, -- 641
		48, -- 641
		h - 96, -- 641
		0, -- 641
		1 -- 641
	) -- 641
	place( -- 642
		captionLabel, -- 642
		48, -- 642
		h - 140, -- 642
		0, -- 642
		1 -- 642
	) -- 642
	place( -- 644
		switchLabel, -- 644
		48, -- 644
		40, -- 644
		0, -- 644
		0 -- 644
	) -- 644
	place( -- 645
		hintLabel, -- 645
		48, -- 645
		84, -- 645
		0, -- 645
		0 -- 645
	) -- 645
	place( -- 646
		rulerLabel, -- 646
		w - 216, -- 646
		roomTop + 36 + v.scale * 0.5 - 14, -- 646
		1, -- 646
		0 -- 646
	) -- 646
	place( -- 647
		standLabel, -- 647
		48, -- 647
		roomTop + 40, -- 647
		0, -- 647
		0 -- 647
	) -- 647
	place( -- 648
		cartLabel, -- 648
		48, -- 648
		roomTop + 92, -- 648
		0, -- 648
		0 -- 648
	) -- 648
	if roomLabel ~= nil then -- 648
		roomLabel.text = room.name -- 651
	end -- 651
	if captionLabel ~= nil then -- 651
		captionLabel.text = room.caption -- 654
	end -- 654
	if hintLabel ~= nil then -- 654
		local hintIdx = math.min(current, #HINTS - 1) -- 657
		local lines = HINTS[hintIdx + 1] -- 658
		local merged = lines[1] -- 659
		do -- 659
			local i = 1 -- 660
			while i < #lines do -- 660
				merged = (merged .. "    ") .. lines[i + 1] -- 661
				i = i + 1 -- 660
			end -- 660
		end -- 660
		hintLabel.text = merged -- 663
	end -- 663
	local specs = collectLabels(room, v, w) -- 666
	local body = {} -- 667
	local small = {} -- 668
	do -- 668
		local i = 0 -- 669
		while i < #specs do -- 669
			local s = specs[i + 1] -- 670
			if s.size >= 24 then -- 670
				body[#body + 1] = s -- 672
			else -- 672
				small[#small + 1] = s -- 674
			end -- 674
			i = i + 1 -- 669
		end -- 669
	end -- 669
	applyPool(body, poolBody) -- 677
	applyPool(small, poolSmall) -- 678
	if LAYOUT_AUDIT then -- 678
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 681
	end -- 681
end -- 681
function applyPool(specs, pool) -- 685
	do -- 685
		local i = 0 -- 686
		while i < #pool do -- 686
			local lb = pool[i + 1] -- 687
			if i < #specs then -- 687
				local s = specs[i + 1] -- 689
				lb.text = s.text -- 690
				lb.position = Vec2(s.x, s.y) -- 691
				lb.anchor = Vec2(s.ax, s.ay) -- 692
				lb.color = s.color -- 693
				lb.visible = true -- 694
			else -- 694
				lb.visible = false -- 696
			end -- 696
			i = i + 1 -- 686
		end -- 686
	end -- 686
end -- 686
local FONT = "sarasa-mono-sc-regular" -- 21
LAYOUT_AUDIT = false -- 22
local C_TEXT = Color(236, 236, 232, 255) -- 24
local C_DIM = Color(150, 154, 152, 255) -- 25
local C_ACCENT = Color(226, 186, 84, 255) -- 26
C_BG = Color(17, 18, 19, 255) -- 27
local POOL_BODY = 30 -- 29
local POOL_SMALL = 44 -- 30
TOP_H = 208 -- 31
BOTTOM_H = 216 -- 32
poolBody = {} -- 51
poolSmall = {} -- 52
current = 0 -- 54
viewW = 0 -- 55
viewH = 0 -- 56
dirty = true -- 57
mode = 1 -- 59
clock = __TS__New(StepClock) -- 63
local function makeGrayboxLabel(text, size, color) -- 65
	if grayboxLayer == nil then -- 65
		return nil -- 67
	end -- 67
	local lb = Label(FONT, size) -- 69
	if lb == nil then -- 69
		return nil -- 71
	end -- 71
	lb.text = text -- 73
	lb.color = color -- 74
	lb:addTo(grayboxLayer) -- 75
	lb.visible = true -- 76
	return lb -- 77
end -- 65
function ____exports.start(parent, initialMode, startScreen) -- 89
	if initialMode == nil then -- 89
		initialMode = 1 -- 89
	end -- 89
	if startScreen == nil then -- 89
		startScreen = "title" -- 89
	end -- 89
	root = parent -- 90
	mode = initialMode -- 91
	grayboxLayer = Node() -- 94
	grayboxLayer.order = 2 -- 95
	grayboxLayer:addTo(parent) -- 96
	draw = DrawNode() -- 98
	draw:addTo(grayboxLayer) -- 99
	campaignLayer = Node() -- 102
	campaignLayer.order = 3 -- 103
	campaignLayer:addTo(parent) -- 104
	campaignDraw = DrawNode() -- 105
	campaignDraw:addTo(campaignLayer) -- 106
	campaignHud = Label(FONT, 24) -- 107
	if campaignHud ~= nil then -- 107
		campaignHud.color = C_TEXT -- 109
		campaignHud.anchor = Vec2(0, 1) -- 110
		campaignHud:addTo(campaignLayer) -- 111
		campaignHud.visible = true -- 112
	end -- 112
	campaignSub = Label(FONT, 20) -- 114
	if campaignSub ~= nil then -- 114
		campaignSub.color = C_ACCENT -- 116
		campaignSub.anchor = Vec2(0, 1) -- 117
		campaignSub:addTo(campaignLayer) -- 118
		campaignSub.visible = true -- 119
	end -- 119
	campaignLayer.visible = mode == 2 -- 121
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 123
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 124
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 125
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 126
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 127
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 128
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 129
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 130
	do -- 130
		local i = 0 -- 132
		while i < POOL_BODY do -- 132
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 133
			if lb ~= nil then -- 133
				poolBody[#poolBody + 1] = lb -- 135
			end -- 135
			i = i + 1 -- 132
		end -- 132
	end -- 132
	do -- 132
		local i = 0 -- 138
		while i < POOL_SMALL do -- 138
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 139
			if lb ~= nil then -- 139
				poolSmall[#poolSmall + 1] = lb -- 141
			end -- 141
			i = i + 1 -- 138
		end -- 138
	end -- 138
	fe = __TS__New(WatchFrontend, parent) -- 146
	fe.screen = startScreen -- 147
	grayboxLayer.visible = mode == 0 -- 148
	fe:setVisible(mode == 1) -- 149
	if campaignLayer ~= nil then -- 149
		campaignLayer.visible = mode == 2 -- 151
	end -- 151
	input = __TS__New(Input) -- 154
	parent:onKeyDown(function(key) -- 157
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or play ~= nil and play.paused) then -- 157
			fe.menus:onKeyEvent(key) -- 159
		end -- 159
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" or mode == 2) then -- 159
			if key == "E" then -- 159
				input.interact.pressed = true -- 163
			elseif key == "Space" then -- 163
				input.jump.pressed = true -- 165
			elseif key == "Escape" then -- 165
				input.pause.pressed = true -- 167
			elseif key == "R" then -- 167
				input.retry.pressed = true -- 169
			end -- 169
		end -- 169
		if key == "F1" then -- 169
			if mode == 2 then -- 169
				current = 0 -- 174
				play = nil -- 175
				ensurePlay() -- 176
			else -- 176
				enterPlayRoom(current) -- 178
			end -- 178
		elseif key == "F2" then -- 178
			setMode(0) -- 181
		elseif key == "1" then -- 181
			pickByIndex(0) -- 183
		elseif key == "2" then -- 183
			pickByIndex(1) -- 185
		elseif key == "3" then -- 185
			pickByIndex(2) -- 187
		elseif key == "4" then -- 187
			pickByIndex(3) -- 189
		elseif key == "5" then -- 189
			pickByIndex(4) -- 191
		elseif key == "6" then -- 191
			pickByIndex(5) -- 193
		elseif key == "7" then -- 193
			pickByIndex(6) -- 195
		elseif key == "8" then -- 195
			pickByIndex(7) -- 197
		end -- 197
	end) -- 157
	viewW = View.size.width -- 201
	viewH = View.size.height -- 202
	applySize() -- 203
	local reg = _G.package.loaded -- 206
	reg["watch.input"] = input -- 207
	reg["watch.fe"] = { -- 208
		setScreen = function(sc) -- 209
			if fe == nil then -- 209
				return -- 211
			end -- 211
			setMode(1) -- 213
			fe.screen = sc -- 214
			if sc == "chapters" then -- 214
				fe.menus:openChapters() -- 216
			else -- 216
				fe.menus:resetInput() -- 218
			end -- 218
			if sc == "play" then -- 218
				ensurePlay() -- 221
			end -- 221
		end, -- 209
		jumpRoom = function(keyOrIdx) -- 224
			local idx = -1 -- 225
			if type(keyOrIdx) == "number" then -- 225
				idx = keyOrIdx -- 227
			else -- 227
				local k = 0 -- 229
				do -- 229
					k = 0 -- 230
					while k < #ROOMS do -- 230
						if ROOMS[k + 1].key == keyOrIdx then -- 230
							idx = k -- 232
						end -- 232
						k = k + 1 -- 230
					end -- 230
				end -- 230
			end -- 230
			if idx >= 0 and idx < #ROOMS then -- 230
				enterPlayRoom(idx) -- 237
			end -- 237
		end, -- 224
		getPlay = function() return play end, -- 240
		getFrontend = function() return fe end -- 241
	} -- 241
	if mode == 1 and startScreen == "play" then -- 241
		ensurePlay() -- 245
	end -- 245
	parent:schedule(function(frameDt) -- 248
		tick(frameDt) -- 249
		return false -- 250
	end) -- 248
end -- 89
return ____exports -- 89