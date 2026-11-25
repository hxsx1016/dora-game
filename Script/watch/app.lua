-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local place, setMode, enterPlayRoom, pickByIndex, applySize, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock -- 1
local ____Dora = require("Dora") -- 8
local App = ____Dora.App -- 8
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
local createTrial = ____run.createTrial -- 16
local mmss = ____run.mmss -- 16
local talentNames = ____run.talentNames -- 16
function place(lb, x, y, ax, ay) -- 82
	if lb == nil then -- 82
		return -- 84
	end -- 84
	lb.position = Vec2(x, y) -- 86
	lb.anchor = Vec2(ax, ay) -- 87
	lb.visible = true -- 88
end -- 88
function setMode(nextMode) -- 257
	mode = nextMode -- 258
	if grayboxLayer ~= nil then -- 258
		grayboxLayer.visible = mode == 0 -- 260
	end -- 260
	if fe ~= nil then -- 260
		fe:setVisible(mode == 1) -- 263
	end -- 263
	if campaignLayer ~= nil then -- 263
		campaignLayer.visible = mode == 2 -- 266
	end -- 266
	dirty = true -- 268
	clock:reset() -- 269
end -- 269
function enterPlayRoom(idx) -- 272
	current = idx -- 273
	setMode(1) -- 274
	if fe ~= nil then -- 274
		fe.screen = "play" -- 276
	end -- 276
	play = nil -- 278
	if idx == 0 then -- 278
		storyRun = createRun() -- 281
	end -- 281
	ensurePlay() -- 283
end -- 283
function pickByIndex(idx) -- 286
	if mode == 2 then -- 286
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 286
			return -- 289
		end -- 289
		current = idx -- 291
		play = nil -- 292
		clock:reset() -- 293
		ensurePlay() -- 294
		return -- 295
	end -- 295
	if idx < 0 or idx >= #ROOMS then -- 295
		return -- 298
	end -- 298
	current = idx -- 300
	dirty = true -- 301
	play = nil -- 302
	clock:reset() -- 303
	if mode == 1 then -- 303
		if fe ~= nil then -- 303
			fe.screen = "play" -- 306
		end -- 306
		ensurePlay() -- 308
	end -- 308
end -- 308
function applySize() -- 312
	if root == nil then -- 312
		return -- 314
	end -- 314
	root.size = Size(viewW, viewH) -- 316
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 317
end -- 317
function tick(frameDt) -- 320
	local w = View.size.width -- 321
	local h = View.size.height -- 322
	if w ~= viewW or h ~= viewH then -- 322
		viewW = w -- 324
		viewH = h -- 325
		applySize() -- 326
		dirty = true -- 327
	end -- 327
	if input == nil then -- 327
		return -- 330
	end -- 330
	input:update() -- 332
	if mode == 2 and (run and run.trial) ~= nil then -- 332
		tickCampaign(frameDt) -- 334
		return -- 335
	end -- 335
	if input.toggleView.pressed then -- 335
		input.toggleView.pressed = false -- 340
		setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 341
		if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 341
			ensurePlay() -- 343
		end -- 343
	end -- 343
	if input.pickRoom ~= 0 then -- 343
		local idx = input.pickRoom - 1 -- 349
		input.pickRoom = 0 -- 350
		pickByIndex(idx) -- 351
	elseif input.tab.pressed then -- 351
		input.tab.pressed = false -- 353
		if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 353
			pickByIndex((current + 1) % #ROOMS) -- 355
		end -- 355
	end -- 355
	if mode == 2 then -- 355
		tickCampaign(frameDt) -- 360
		return -- 361
	end -- 361
	if mode == 1 then -- 361
		tickFrontend(frameDt) -- 364
		return -- 365
	end -- 365
	if dirty then -- 365
		redrawGraybox() -- 368
		dirty = false -- 369
	end -- 369
end -- 369
function registerPlay() -- 374
	local reg = _G.package.loaded -- 375
	reg["watch.play"] = play -- 376
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 377
	reg["watch.room"] = rooms[current + 1].key -- 378
end -- 378
function ensurePlay(resume) -- 382
	if mode == 2 then -- 382
		if run == nil then -- 382
			run = createRun() -- 385
		end -- 385
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 387
	else -- 387
		if storyRun == nil then -- 387
			storyRun = createRun() -- 392
		end -- 392
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 394
	end -- 394
	registerPlay() -- 396
	clock:reset() -- 397
	if fe ~= nil and mode == 1 then -- 397
		fe:bindPlay(play, viewW, viewH) -- 399
	end -- 399
end -- 399
function startTrial() -- 403
	current = 0 -- 404
	run = createTrial(App.rand) -- 405
	setMode(2) -- 406
	ensurePlay() -- 407
end -- 407
function tickCampaign(frameDt) -- 410
	if input == nil then -- 410
		return -- 412
	end -- 412
	if play == nil then -- 412
		ensurePlay() -- 415
	end -- 415
	if play == nil then -- 415
		return -- 418
	end -- 418
	local p = play -- 420
	p.aimX = input.mx -- 421
	p.aimY = input.my -- 422
	local trial = run and run.trial -- 424
	if trial ~= nil then -- 424
		local ended = trial.lost or (run and run.finished) == true -- 426
		local pick = input.pickRoom -- 427
		input.pickRoom = 0 -- 428
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 428
			input:consumeEdges() -- 430
			current = 0 -- 431
			play = nil -- 432
			run = nil -- 433
			setMode(1) -- 434
			if fe ~= nil then -- 434
				fe.screen = "title" -- 436
				fe.menus:resetInput() -- 437
			end -- 437
			return -- 439
		end -- 439
		if ended or p.paused and input.retry.pressed then -- 439
			local restart = input.retry.pressed -- 442
			input:consumeEdges() -- 443
			if restart then -- 443
				startTrial() -- 444
			else -- 444
				drawCampaign(p) -- 445
			end -- 445
			return -- 446
		end -- 446
		input.retry.pressed = false -- 448
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 448
			if pick > 0 then -- 448
				p:chooseTalent(pick - 1) -- 450
			end -- 450
			input:consumeEdges() -- 451
			clock:reset() -- 452
			drawCampaign(p) -- 453
			return -- 454
		end -- 454
	end -- 454
	if input.retry.pressed then -- 454
		input.retry.pressed = false -- 459
		input:consumeEdges() -- 460
		play = nil -- 462
		ensurePlay() -- 463
		return -- 464
	end -- 464
	if input.pause.pressed then -- 464
		input.pause.pressed = false -- 467
		p.paused = not p.paused -- 468
		clock:reset() -- 469
		input:consumeEdges() -- 470
	end -- 470
	if p.paused then -- 470
		drawCampaign(p) -- 473
		return -- 474
	end -- 474
	local steps = clock:advance(frameDt) -- 477
	local i = 0 -- 478
	do -- 478
		i = 0 -- 479
		while i < steps do -- 479
			input:beginStep(i == 0) -- 480
			p:update(STEP, input) -- 481
			input:endStep() -- 482
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 482
				break -- 484
			end -- 484
			i = i + 1 -- 479
		end -- 479
	end -- 479
	if p.wantRoom ~= "" then -- 479
		local key = p.wantRoom -- 489
		p.wantRoom = "" -- 490
		local idx = -1 -- 491
		local j = 0 -- 492
		do -- 492
			j = 0 -- 493
			while j < #CAMPAIGN_ROOMS do -- 493
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 493
					idx = j -- 495
				end -- 495
				j = j + 1 -- 493
			end -- 493
		end -- 493
		if idx >= 0 then -- 493
			current = idx -- 499
			play = nil -- 500
			ensurePlay() -- 501
		end -- 501
		return -- 503
	end -- 503
	drawCampaign(p) -- 505
end -- 505
function goalLabel(goal) -- 508
	if goal == "dock_cart" then -- 508
		return "推车入窝并抬闩" -- 510
	end -- 510
	if goal == "raise_latch" then -- 510
		return "抬闩开侧门" -- 513
	end -- 513
	return "到段出口" -- 515
end -- 515
function drawCampaign(p) -- 518
	if campaignDraw == nil then -- 518
		return -- 520
	end -- 520
	local w = viewW -- 522
	local h = viewH -- 523
	p:draw(campaignDraw, w, h) -- 524
	local room = CAMPAIGN_ROOMS[current + 1] -- 525
	local c = room.campaign -- 526
	local r = run -- 527
	local line = room.name -- 528
	if c ~= nil then -- 528
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 530
	end -- 530
	if p.paused then -- 530
		line = line .. "  · 已暂停 Esc 继续" -- 534
	end -- 534
	local trial = r and r.trial -- 536
	if trial ~= nil and r ~= nil then -- 536
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 538
		if p.paused then -- 538
			line = line .. " · 暂停" -- 539
		elseif trial.lost then -- 539
			line = line .. " · 护送失败" -- 540
		elseif r.finished then -- 540
			line = line .. " · 护送完成" -- 541
		elseif #trial.offers > 0 then -- 541
			line = line .. " · 选择本段本领" -- 542
		elseif c ~= nil then -- 542
			line = line .. " · " .. goalLabel(c.goal) -- 543
		end -- 543
	end -- 543
	if campaignHud ~= nil then -- 543
		campaignHud.text = line -- 546
		campaignHud.position = Vec2(24, h - 14) -- 547
		campaignHud.visible = true -- 548
	end -- 548
	if campaignSub ~= nil then -- 548
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 551
		if r ~= nil then -- 551
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 553
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 554
		end -- 554
		if p.flash ~= "" then -- 554
			sub = (sub .. " · ") .. p.flash -- 560
		end -- 560
		if trial ~= nil and r ~= nil then -- 560
			if trial.lost or r.finished then -- 560
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 563
			elseif p.paused then -- 563
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 564
			elseif #trial.offers > 0 then -- 564
				sub = table.concat( -- 565
					__TS__ArrayMap( -- 565
						trial.offers, -- 565
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 565
					), -- 565
					"　" -- 565
				) -- 565
			else -- 565
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 566
			end -- 566
		end -- 566
		campaignSub.text = sub -- 568
		campaignSub.position = Vec2(24, h - 44) -- 569
		campaignSub.visible = true -- 570
	end -- 570
end -- 570
function tickFrontend(frameDt) -- 574
	if fe == nil or input == nil then -- 574
		return -- 576
	end -- 576
	if fe.screen ~= "play" then -- 576
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 581
		input:consumeEdges() -- 582
		if act.type == "trial" then -- 582
			startTrial() -- 584
		elseif act.type == "start" then -- 584
			enterPlayRoom(0) -- 586
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 586
			enterPlayRoom(act.roomIndex) -- 588
		elseif act.type == "openChapters" then -- 588
			fe.menus:openChapters() -- 590
			fe.screen = "chapters" -- 591
		elseif act.type == "openControls" then -- 591
			fe.menus:resetInput() -- 593
			fe.screen = "controls" -- 594
		elseif act.type == "backTitle" then -- 594
			fe.menus:resetInput() -- 596
			fe.screen = "title" -- 597
		elseif act.type == "backPause" then -- 597
			fe.menus:resetInput() -- 599
			fe.screen = "play" -- 600
		end -- 600
		return -- 602
	end -- 602
	if play == nil then -- 602
		ensurePlay() -- 607
	end -- 607
	if play == nil then -- 607
		return -- 610
	end -- 610
	local p = play -- 612
	if input.retry.pressed then -- 612
		input:consumeEdges() -- 615
		ensurePlay({checkpoint = p.checkpoint}) -- 617
		return -- 618
	end -- 618
	p.aimX = input.mx -- 621
	p.aimY = input.my -- 622
	if not p.paused and input.pause.pressed then -- 622
		p.paused = true -- 625
		p.aimHold = 0 -- 626
		p.bottleAimX = -1 -- 627
		fe.menus:openPause() -- 628
		input:consumeEdges() -- 629
	end -- 629
	if p.paused then -- 629
		clock:reset() -- 634
		local pauseAct = fe:renderPlay( -- 635
			frameDt, -- 635
			p, -- 635
			input, -- 635
			viewW, -- 635
			viewH -- 635
		) -- 635
		input:consumeEdges() -- 636
		if pauseAct.type == "resume" then -- 636
			p.paused = false -- 638
		elseif pauseAct.type == "retry" then -- 638
			ensurePlay({checkpoint = p.checkpoint}) -- 640
		elseif pauseAct.type == "openChapters" then -- 640
			fe.menus:openChapters(current) -- 642
			fe.screen = "chapters" -- 643
		elseif pauseAct.type == "toTitle" then -- 643
			fe.menus:resetInput() -- 645
			fe.screen = "title" -- 646
		end -- 646
		return -- 648
	end -- 648
	local steps = clock:advance(frameDt) -- 651
	local i = 0 -- 652
	do -- 652
		i = 0 -- 653
		while i < steps do -- 653
			input:beginStep(i == 0) -- 654
			p:update(STEP, input) -- 655
			input:endStep() -- 656
			if p.wantRoom ~= "" then -- 656
				break -- 658
			end -- 658
			i = i + 1 -- 653
		end -- 653
	end -- 653
	if p.wantRoom ~= "" then -- 653
		local key = p.wantRoom -- 664
		p.wantRoom = "" -- 665
		local idx = -1 -- 666
		local j = 0 -- 667
		do -- 667
			j = 0 -- 668
			while j < #ROOMS do -- 668
				if ROOMS[j + 1].key == key then -- 668
					idx = j -- 670
				end -- 670
				j = j + 1 -- 668
			end -- 668
		end -- 668
		if idx >= 0 then -- 668
			local leaving = p:drainEvents() -- 676
			current = idx -- 677
			ensurePlay() -- 678
			local fresh = play -- 679
			if fresh ~= nil then -- 679
				fresh:adoptEvents(leaving) -- 681
			end -- 681
			clock:reset() -- 683
			dirty = true -- 684
		end -- 684
		return -- 686
	end -- 686
	fe:renderPlay( -- 689
		frameDt, -- 689
		p, -- 689
		input, -- 689
		viewW, -- 689
		viewH -- 689
	) -- 689
end -- 689
function redrawGraybox() -- 693
	if draw == nil then -- 693
		return -- 695
	end -- 695
	local w = viewW -- 697
	local h = viewH -- 698
	local room = ROOMS[current + 1] -- 699
	draw:clear() -- 701
	draw:drawRect( -- 702
		Rect(0, h - TOP_H, w, TOP_H), -- 702
		C_BG -- 702
	) -- 702
	draw:drawRect( -- 703
		Rect(0, 0, w, BOTTOM_H), -- 703
		C_BG -- 703
	) -- 703
	draw:drawSegment( -- 704
		Vec2(0, h - TOP_H), -- 704
		Vec2(w, h - TOP_H), -- 704
		1, -- 704
		Color(52, 54, 54, 255) -- 704
	) -- 704
	draw:drawSegment( -- 705
		Vec2(0, BOTTOM_H), -- 705
		Vec2(w, BOTTOM_H), -- 705
		1, -- 705
		Color(52, 54, 54, 255) -- 705
	) -- 705
	local v = computeView(room, w, h) -- 707
	renderWorld( -- 708
		draw, -- 708
		room, -- 708
		v, -- 708
		w, -- 708
		h -- 708
	) -- 708
	local roomTop = v.groundPx + room.height * v.scale -- 710
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 711
	place( -- 713
		titleLabel, -- 713
		48, -- 713
		h - 40, -- 713
		0, -- 713
		1 -- 713
	) -- 713
	place( -- 714
		roomLabel, -- 714
		48, -- 714
		h - 96, -- 714
		0, -- 714
		1 -- 714
	) -- 714
	place( -- 715
		captionLabel, -- 715
		48, -- 715
		h - 140, -- 715
		0, -- 715
		1 -- 715
	) -- 715
	place( -- 717
		switchLabel, -- 717
		48, -- 717
		40, -- 717
		0, -- 717
		0 -- 717
	) -- 717
	place( -- 718
		hintLabel, -- 718
		48, -- 718
		84, -- 718
		0, -- 718
		0 -- 718
	) -- 718
	place( -- 719
		rulerLabel, -- 719
		w - 216, -- 719
		roomTop + 36 + v.scale * 0.5 - 14, -- 719
		1, -- 719
		0 -- 719
	) -- 719
	place( -- 720
		standLabel, -- 720
		48, -- 720
		roomTop + 40, -- 720
		0, -- 720
		0 -- 720
	) -- 720
	place( -- 721
		cartLabel, -- 721
		48, -- 721
		roomTop + 92, -- 721
		0, -- 721
		0 -- 721
	) -- 721
	if roomLabel ~= nil then -- 721
		roomLabel.text = room.name -- 724
	end -- 724
	if captionLabel ~= nil then -- 724
		captionLabel.text = room.caption -- 727
	end -- 727
	if hintLabel ~= nil then -- 727
		local hintIdx = math.min(current, #HINTS - 1) -- 730
		local lines = HINTS[hintIdx + 1] -- 731
		local merged = lines[1] -- 732
		do -- 732
			local i = 1 -- 733
			while i < #lines do -- 733
				merged = (merged .. "    ") .. lines[i + 1] -- 734
				i = i + 1 -- 733
			end -- 733
		end -- 733
		hintLabel.text = merged -- 736
	end -- 736
	local specs = collectLabels(room, v, w) -- 739
	local body = {} -- 740
	local small = {} -- 741
	do -- 741
		local i = 0 -- 742
		while i < #specs do -- 742
			local s = specs[i + 1] -- 743
			if s.size >= 24 then -- 743
				body[#body + 1] = s -- 745
			else -- 745
				small[#small + 1] = s -- 747
			end -- 747
			i = i + 1 -- 742
		end -- 742
	end -- 742
	applyPool(body, poolBody) -- 750
	applyPool(small, poolSmall) -- 751
	if LAYOUT_AUDIT then -- 751
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 754
	end -- 754
end -- 754
function applyPool(specs, pool) -- 758
	do -- 758
		local i = 0 -- 759
		while i < #pool do -- 759
			local lb = pool[i + 1] -- 760
			if i < #specs then -- 760
				local s = specs[i + 1] -- 762
				lb.text = s.text -- 763
				lb.position = Vec2(s.x, s.y) -- 764
				lb.anchor = Vec2(s.ax, s.ay) -- 765
				lb.color = s.color -- 766
				lb.visible = true -- 767
			else -- 767
				lb.visible = false -- 769
			end -- 769
			i = i + 1 -- 759
		end -- 759
	end -- 759
end -- 759
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
poolBody = {} -- 53
poolSmall = {} -- 54
current = 0 -- 56
viewW = 0 -- 57
viewH = 0 -- 58
dirty = true -- 59
mode = 1 -- 61
clock = __TS__New(StepClock) -- 65
local function makeGrayboxLabel(text, size, color) -- 67
	if grayboxLayer == nil then -- 67
		return nil -- 69
	end -- 69
	local lb = Label(FONT, size) -- 71
	if lb == nil then -- 71
		return nil -- 73
	end -- 73
	lb.text = text -- 75
	lb.color = color -- 76
	lb:addTo(grayboxLayer) -- 77
	lb.visible = true -- 78
	return lb -- 79
end -- 67
function ____exports.start(parent, initialMode, startScreen) -- 91
	if initialMode == nil then -- 91
		initialMode = 1 -- 91
	end -- 91
	if startScreen == nil then -- 91
		startScreen = "title" -- 91
	end -- 91
	root = parent -- 92
	mode = initialMode -- 93
	grayboxLayer = Node() -- 96
	grayboxLayer.order = 2 -- 97
	grayboxLayer:addTo(parent) -- 98
	draw = DrawNode() -- 100
	draw:addTo(grayboxLayer) -- 101
	campaignLayer = Node() -- 104
	campaignLayer.order = 3 -- 105
	campaignLayer:addTo(parent) -- 106
	campaignDraw = DrawNode() -- 107
	campaignDraw:addTo(campaignLayer) -- 108
	campaignHud = Label(FONT, 24) -- 109
	if campaignHud ~= nil then -- 109
		campaignHud.color = C_TEXT -- 111
		campaignHud.anchor = Vec2(0, 1) -- 112
		campaignHud:addTo(campaignLayer) -- 113
		campaignHud.visible = true -- 114
	end -- 114
	campaignSub = Label(FONT, 20) -- 116
	if campaignSub ~= nil then -- 116
		campaignSub.color = C_ACCENT -- 118
		campaignSub.anchor = Vec2(0, 1) -- 119
		campaignSub:addTo(campaignLayer) -- 120
		campaignSub.visible = true -- 121
	end -- 121
	campaignLayer.visible = mode == 2 -- 123
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 125
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 126
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 127
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 128
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 129
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 130
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 131
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 132
	do -- 132
		local i = 0 -- 134
		while i < POOL_BODY do -- 134
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 135
			if lb ~= nil then -- 135
				poolBody[#poolBody + 1] = lb -- 137
			end -- 137
			i = i + 1 -- 134
		end -- 134
	end -- 134
	do -- 134
		local i = 0 -- 140
		while i < POOL_SMALL do -- 140
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 141
			if lb ~= nil then -- 141
				poolSmall[#poolSmall + 1] = lb -- 143
			end -- 143
			i = i + 1 -- 140
		end -- 140
	end -- 140
	fe = __TS__New(WatchFrontend, parent) -- 148
	fe.screen = startScreen -- 149
	grayboxLayer.visible = mode == 0 -- 150
	fe:setVisible(mode == 1) -- 151
	if campaignLayer ~= nil then -- 151
		campaignLayer.visible = mode == 2 -- 153
	end -- 153
	input = __TS__New(Input) -- 156
	parent:onKeyDown(function(key) -- 159
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or play ~= nil and play.paused) then -- 159
			fe.menus:onKeyEvent(key) -- 161
		end -- 161
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" or mode == 2) then -- 161
			if key == "E" then -- 161
				input.interact.pressed = true -- 165
			elseif key == "Space" then -- 165
				input.jump.pressed = true -- 167
			elseif key == "Escape" then -- 167
				input.pause.pressed = true -- 169
			elseif key == "R" then -- 169
				input.retry.pressed = true -- 171
			end -- 171
		end -- 171
		if mode == 2 and (run and run.trial) ~= nil then -- 171
			return -- 174
		end -- 174
		if key == "F1" then -- 174
			if mode == 2 then -- 174
				current = 0 -- 177
				play = nil -- 178
				ensurePlay() -- 179
			else -- 179
				enterPlayRoom(current) -- 181
			end -- 181
		elseif key == "F2" then -- 181
			setMode(0) -- 184
		elseif key == "1" then -- 184
			pickByIndex(0) -- 186
		elseif key == "2" then -- 186
			pickByIndex(1) -- 188
		elseif key == "3" then -- 188
			pickByIndex(2) -- 190
		elseif key == "4" then -- 190
			pickByIndex(3) -- 192
		elseif key == "5" then -- 192
			pickByIndex(4) -- 194
		elseif key == "6" then -- 194
			pickByIndex(5) -- 196
		elseif key == "7" then -- 196
			pickByIndex(6) -- 198
		elseif key == "8" then -- 198
			pickByIndex(7) -- 200
		end -- 200
	end) -- 159
	viewW = View.size.width -- 204
	viewH = View.size.height -- 205
	applySize() -- 206
	local reg = _G.package.loaded -- 209
	reg["watch.input"] = input -- 210
	reg["watch.fe"] = { -- 211
		setScreen = function(sc) -- 212
			if fe == nil then -- 212
				return -- 214
			end -- 214
			setMode(1) -- 216
			fe.screen = sc -- 217
			if sc == "chapters" then -- 217
				fe.menus:openChapters() -- 219
			else -- 219
				fe.menus:resetInput() -- 221
			end -- 221
			if sc == "play" then -- 221
				ensurePlay() -- 224
			end -- 224
		end, -- 212
		jumpRoom = function(keyOrIdx) -- 227
			local idx = -1 -- 228
			if type(keyOrIdx) == "number" then -- 228
				idx = keyOrIdx -- 230
			else -- 230
				local k = 0 -- 232
				do -- 232
					k = 0 -- 233
					while k < #ROOMS do -- 233
						if ROOMS[k + 1].key == keyOrIdx then -- 233
							idx = k -- 235
						end -- 235
						k = k + 1 -- 233
					end -- 233
				end -- 233
			end -- 233
			if idx >= 0 and idx < #ROOMS then -- 233
				enterPlayRoom(idx) -- 240
			end -- 240
		end, -- 227
		getPlay = function() return play end, -- 243
		getFrontend = function() return fe end -- 244
	} -- 244
	if mode == 1 and startScreen == "play" then -- 244
		ensurePlay() -- 248
	end -- 248
	parent:schedule(function(frameDt) -- 251
		tick(frameDt) -- 252
		return false -- 253
	end) -- 251
end -- 91
return ____exports -- 91