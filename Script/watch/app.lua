-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local place, setMode, enterPlayRoom, pickByIndex, applySize, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock -- 1
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
local ____save = require("Script.watch.save") -- 17
local emptySave = ____save.emptySave -- 17
local loadSave = ____save.loadSave -- 17
local saveSave = ____save.saveSave -- 17
local setSaveFile = ____save.setSaveFile -- 17
local getSaveFile = ____save.getSaveFile -- 17
function place(lb, x, y, ax, ay) -- 87
	if lb == nil then -- 87
		return -- 89
	end -- 89
	lb.position = Vec2(x, y) -- 91
	lb.anchor = Vec2(ax, ay) -- 92
	lb.visible = true -- 93
end -- 93
function setMode(nextMode) -- 293
	mode = nextMode -- 294
	if grayboxLayer ~= nil then -- 294
		grayboxLayer.visible = mode == 0 -- 296
	end -- 296
	if fe ~= nil then -- 296
		fe:setVisible(mode == 1) -- 299
	end -- 299
	if campaignLayer ~= nil then -- 299
		campaignLayer.visible = mode == 2 -- 302
	end -- 302
	dirty = true -- 304
	clock:reset() -- 305
end -- 305
function enterPlayRoom(idx, source, fresh) -- 308
	if source == nil then -- 308
		source = "debug" -- 308
	end -- 308
	if fresh == nil then -- 308
		fresh = false -- 308
	end -- 308
	current = idx -- 309
	setMode(1) -- 310
	if fe ~= nil then -- 310
		fe.screen = "play" -- 312
	end -- 312
	play = nil -- 314
	if fresh or storyRun == nil then -- 314
		storyRun = createRun(20261124, source, profile) -- 317
	else -- 317
		storyRun.source = source -- 319
	end -- 319
	ensurePlay() -- 321
end -- 321
function pickByIndex(idx, source) -- 324
	if source == nil then -- 324
		source = "debug" -- 324
	end -- 324
	if mode == 2 then -- 324
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 324
			return -- 327
		end -- 327
		current = idx -- 329
		play = nil -- 330
		clock:reset() -- 331
		ensurePlay() -- 332
		return -- 333
	end -- 333
	if idx < 0 or idx >= #ROOMS then -- 333
		return -- 336
	end -- 336
	current = idx -- 338
	dirty = true -- 339
	play = nil -- 340
	clock:reset() -- 341
	if mode == 1 then -- 341
		if fe ~= nil then -- 341
			fe.screen = "play" -- 344
		end -- 344
		ensurePlay() -- 346
	end -- 346
end -- 346
function applySize() -- 350
	if root == nil then -- 350
		return -- 352
	end -- 352
	root.size = Size(viewW, viewH) -- 354
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 355
end -- 355
function tick(frameDt) -- 358
	local w = View.size.width -- 359
	local h = View.size.height -- 360
	if w ~= viewW or h ~= viewH then -- 360
		viewW = w -- 362
		viewH = h -- 363
		applySize() -- 364
		dirty = true -- 365
	end -- 365
	if input == nil then -- 365
		return -- 368
	end -- 368
	input:update() -- 370
	if mode == 2 and (run and run.trial) ~= nil then -- 370
		tickCampaign(frameDt) -- 372
		return -- 373
	end -- 373
	if input.toggleView.pressed then -- 373
		input.toggleView.pressed = false -- 378
		setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 379
		if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 379
			ensurePlay() -- 381
		end -- 381
	end -- 381
	if input.pickRoom ~= 0 then -- 381
		local idx = input.pickRoom - 1 -- 387
		input.pickRoom = 0 -- 388
		pickByIndex(idx) -- 389
	elseif input.tab.pressed then -- 389
		input.tab.pressed = false -- 391
		if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 391
			pickByIndex((current + 1) % #ROOMS) -- 393
		end -- 393
	end -- 393
	if mode == 2 then -- 393
		tickCampaign(frameDt) -- 398
		return -- 399
	end -- 399
	if mode == 1 then -- 399
		tickFrontend(frameDt) -- 402
		return -- 403
	end -- 403
	if dirty then -- 403
		redrawGraybox() -- 406
		dirty = false -- 407
	end -- 407
end -- 407
function registerPlay() -- 412
	local reg = _G.package.loaded -- 413
	reg["watch.play"] = play -- 414
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 415
	reg["watch.room"] = rooms[current + 1].key -- 416
end -- 416
function ensurePlay(resume) -- 420
	if mode == 2 then -- 420
		if run == nil then -- 420
			run = createRun() -- 423
		end -- 423
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 425
	else -- 425
		if storyRun == nil then -- 425
			storyRun = createRun(20261124, "debug", profile) -- 430
		end -- 430
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 432
	end -- 432
	registerPlay() -- 434
	clock:reset() -- 435
	if fe ~= nil and mode == 1 then -- 435
		fe:bindPlay(play, viewW, viewH) -- 437
	end -- 437
end -- 437
function startTrial() -- 441
	current = 0 -- 442
	run = createTrial(App.rand) -- 443
	setMode(2) -- 444
	ensurePlay() -- 445
end -- 445
function tickCampaign(frameDt) -- 448
	if input == nil then -- 448
		return -- 450
	end -- 450
	if play == nil then -- 450
		ensurePlay() -- 453
	end -- 453
	if play == nil then -- 453
		return -- 456
	end -- 456
	local p = play -- 458
	p.aimX = input.mx -- 459
	p.aimY = input.my -- 460
	local trial = run and run.trial -- 462
	if trial ~= nil then -- 462
		local ended = trial.lost or (run and run.finished) == true -- 464
		local pick = input.pickRoom -- 465
		input.pickRoom = 0 -- 466
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 466
			input:consumeEdges() -- 468
			current = 0 -- 469
			play = nil -- 470
			run = nil -- 471
			setMode(1) -- 472
			if fe ~= nil then -- 472
				fe.screen = "title" -- 474
				fe.menus:resetInput() -- 475
			end -- 475
			return -- 477
		end -- 477
		if ended or p.paused and input.retry.pressed then -- 477
			local restart = input.retry.pressed -- 480
			input:consumeEdges() -- 481
			if restart then -- 481
				startTrial() -- 482
			else -- 482
				drawCampaign(p) -- 483
			end -- 483
			return -- 484
		end -- 484
		input.retry.pressed = false -- 486
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 486
			if pick > 0 then -- 486
				p:chooseTalent(pick - 1) -- 488
			end -- 488
			input:consumeEdges() -- 489
			clock:reset() -- 490
			drawCampaign(p) -- 491
			return -- 492
		end -- 492
	end -- 492
	if input.retry.pressed then -- 492
		input.retry.pressed = false -- 497
		input:consumeEdges() -- 498
		play = nil -- 500
		ensurePlay() -- 501
		return -- 502
	end -- 502
	if input.pause.pressed then -- 502
		input.pause.pressed = false -- 505
		p.paused = not p.paused -- 506
		clock:reset() -- 507
		input:consumeEdges() -- 508
	end -- 508
	if p.paused then -- 508
		drawCampaign(p) -- 511
		return -- 512
	end -- 512
	local steps = clock:advance(frameDt) -- 515
	local i = 0 -- 516
	do -- 516
		i = 0 -- 517
		while i < steps do -- 517
			input:beginStep(i == 0) -- 518
			p:update(STEP, input) -- 519
			input:endStep() -- 520
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 520
				break -- 522
			end -- 522
			i = i + 1 -- 517
		end -- 517
	end -- 517
	if p.wantRoom ~= "" then -- 517
		local key = p.wantRoom -- 527
		p.wantRoom = "" -- 528
		local idx = -1 -- 529
		local j = 0 -- 530
		do -- 530
			j = 0 -- 531
			while j < #CAMPAIGN_ROOMS do -- 531
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 531
					idx = j -- 533
				end -- 533
				j = j + 1 -- 531
			end -- 531
		end -- 531
		if idx >= 0 then -- 531
			current = idx -- 537
			play = nil -- 538
			ensurePlay() -- 539
		end -- 539
		return -- 541
	end -- 541
	drawCampaign(p) -- 543
end -- 543
function goalLabel(goal) -- 546
	if goal == "dock_cart" then -- 546
		return "推车入窝并抬闩" -- 548
	end -- 548
	if goal == "raise_latch" then -- 548
		return "抬闩开侧门" -- 551
	end -- 551
	return "到段出口" -- 553
end -- 553
function drawCampaign(p) -- 556
	if campaignDraw == nil then -- 556
		return -- 558
	end -- 558
	local w = viewW -- 560
	local h = viewH -- 561
	p:draw(campaignDraw, w, h) -- 562
	local room = CAMPAIGN_ROOMS[current + 1] -- 563
	local c = room.campaign -- 564
	local r = run -- 565
	local line = room.name -- 566
	if c ~= nil then -- 566
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 568
	end -- 568
	if p.paused then -- 568
		line = line .. "  · 已暂停 Esc 继续" -- 572
	end -- 572
	local trial = r and r.trial -- 574
	if trial ~= nil and r ~= nil then -- 574
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 576
		if p.paused then -- 576
			line = line .. " · 暂停" -- 577
		elseif trial.lost then -- 577
			line = line .. " · 护送失败" -- 578
		elseif r.finished then -- 578
			line = line .. " · 护送完成" -- 579
		elseif #trial.offers > 0 then -- 579
			line = line .. " · 选择本段本领" -- 580
		elseif c ~= nil then -- 580
			line = line .. " · " .. goalLabel(c.goal) -- 581
		end -- 581
	end -- 581
	if campaignHud ~= nil then -- 581
		campaignHud.text = line -- 584
		campaignHud.position = Vec2(24, h - 14) -- 585
		campaignHud.visible = true -- 586
	end -- 586
	if campaignSub ~= nil then -- 586
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 589
		if r ~= nil then -- 589
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 591
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 592
		end -- 592
		if p.flash ~= "" then -- 592
			sub = (sub .. " · ") .. p.flash -- 598
		end -- 598
		if trial ~= nil and r ~= nil then -- 598
			if trial.lost or r.finished then -- 598
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 601
			elseif p.paused then -- 601
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 602
			elseif #trial.offers > 0 then -- 602
				sub = table.concat( -- 603
					__TS__ArrayMap( -- 603
						trial.offers, -- 603
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 603
					), -- 603
					"　" -- 603
				) -- 603
			else -- 603
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 604
			end -- 604
		end -- 604
		campaignSub.text = sub -- 606
		campaignSub.position = Vec2(24, h - 44) -- 607
		campaignSub.visible = true -- 608
	end -- 608
end -- 608
function tickFrontend(frameDt) -- 612
	if fe == nil or input == nil then -- 612
		return -- 614
	end -- 614
	if fe.screen ~= "play" then -- 614
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 619
		input:consumeEdges() -- 620
		if act.type == "trial" then -- 620
			startTrial() -- 622
		elseif act.type == "start" then -- 622
			enterPlayRoom(0, "official", true) -- 624
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 624
			enterPlayRoom(act.roomIndex, "chapter") -- 626
		elseif act.type == "openChapters" then -- 626
			fe.menus:openChapters() -- 628
			fe.screen = "chapters" -- 629
		elseif act.type == "openControls" then -- 629
			fe.menus:resetInput() -- 631
			fe.screen = "controls" -- 632
		elseif act.type == "backTitle" then -- 632
			fe.menus:resetInput() -- 634
			fe.screen = "title" -- 635
		elseif act.type == "backPause" then -- 635
			fe.menus:resetInput() -- 637
			fe.screen = "play" -- 638
		end -- 638
		return -- 640
	end -- 640
	if play == nil then -- 640
		ensurePlay() -- 645
	end -- 645
	if play == nil then -- 645
		return -- 648
	end -- 648
	local p = play -- 650
	if input.retry.pressed then -- 650
		input:consumeEdges() -- 653
		ensurePlay({checkpoint = p.checkpoint}) -- 655
		return -- 656
	end -- 656
	p.aimX = input.mx -- 659
	p.aimY = input.my -- 660
	if not p.paused and input.pause.pressed then -- 660
		p.paused = true -- 663
		p.aimHold = 0 -- 664
		p.bottleAimX = -1 -- 665
		fe.menus:openPause() -- 666
		input:consumeEdges() -- 667
	end -- 667
	if p.paused then -- 667
		clock:reset() -- 672
		local pauseAct = fe:renderPlay( -- 673
			frameDt, -- 673
			p, -- 673
			input, -- 673
			viewW, -- 673
			viewH -- 673
		) -- 673
		input:consumeEdges() -- 674
		if pauseAct.type == "resume" then -- 674
			p.paused = false -- 676
		elseif pauseAct.type == "retry" then -- 676
			ensurePlay({checkpoint = p.checkpoint}) -- 678
		elseif pauseAct.type == "openChapters" then -- 678
			fe.menus:openChapters(current) -- 680
			fe.screen = "chapters" -- 681
		elseif pauseAct.type == "toTitle" then -- 681
			fe.menus:resetInput() -- 683
			fe.screen = "title" -- 684
		end -- 684
		return -- 686
	end -- 686
	local steps = clock:advance(frameDt) -- 689
	local i = 0 -- 690
	do -- 690
		i = 0 -- 691
		while i < steps do -- 691
			input:beginStep(i == 0) -- 692
			p:update(STEP, input) -- 693
			input:endStep() -- 694
			if p.wantRoom ~= "" then -- 694
				break -- 696
			end -- 696
			i = i + 1 -- 691
		end -- 691
	end -- 691
	if p.wantRoom ~= "" then -- 691
		local key = p.wantRoom -- 702
		p.wantRoom = "" -- 703
		local idx = -1 -- 704
		local j = 0 -- 705
		do -- 705
			j = 0 -- 706
			while j < #ROOMS do -- 706
				if ROOMS[j + 1].key == key then -- 706
					idx = j -- 708
				end -- 708
				j = j + 1 -- 706
			end -- 706
		end -- 706
		if idx >= 0 then -- 706
			local leaving = p:drainEvents() -- 714
			if p.restartStory then -- 714
				storyRun = createRun(20261124, storyRun == nil and "official" or storyRun.source, profile) -- 717
			end -- 717
			current = idx -- 719
			ensurePlay() -- 720
			local fresh = play -- 721
			if fresh ~= nil then -- 721
				fresh:adoptEvents(leaving) -- 723
			end -- 723
			clock:reset() -- 725
			dirty = true -- 726
		end -- 726
		return -- 728
	end -- 728
	if p.archiveDirty then -- 728
		p.archiveDirty = false -- 733
		if not saveSave(profile) then -- 733
			p.archiveDirty = true -- 735
		end -- 735
	end -- 735
	fe:renderPlay( -- 738
		frameDt, -- 738
		p, -- 738
		input, -- 738
		viewW, -- 738
		viewH -- 738
	) -- 738
end -- 738
function redrawGraybox() -- 742
	if draw == nil then -- 742
		return -- 744
	end -- 744
	local w = viewW -- 746
	local h = viewH -- 747
	local room = ROOMS[current + 1] -- 748
	draw:clear() -- 750
	draw:drawRect( -- 751
		Rect(0, h - TOP_H, w, TOP_H), -- 751
		C_BG -- 751
	) -- 751
	draw:drawRect( -- 752
		Rect(0, 0, w, BOTTOM_H), -- 752
		C_BG -- 752
	) -- 752
	draw:drawSegment( -- 753
		Vec2(0, h - TOP_H), -- 753
		Vec2(w, h - TOP_H), -- 753
		1, -- 753
		Color(52, 54, 54, 255) -- 753
	) -- 753
	draw:drawSegment( -- 754
		Vec2(0, BOTTOM_H), -- 754
		Vec2(w, BOTTOM_H), -- 754
		1, -- 754
		Color(52, 54, 54, 255) -- 754
	) -- 754
	local v = computeView(room, w, h) -- 756
	renderWorld( -- 757
		draw, -- 757
		room, -- 757
		v, -- 757
		w, -- 757
		h -- 757
	) -- 757
	local roomTop = v.groundPx + room.height * v.scale -- 759
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 760
	place( -- 762
		titleLabel, -- 762
		48, -- 762
		h - 40, -- 762
		0, -- 762
		1 -- 762
	) -- 762
	place( -- 763
		roomLabel, -- 763
		48, -- 763
		h - 96, -- 763
		0, -- 763
		1 -- 763
	) -- 763
	place( -- 764
		captionLabel, -- 764
		48, -- 764
		h - 140, -- 764
		0, -- 764
		1 -- 764
	) -- 764
	place( -- 766
		switchLabel, -- 766
		48, -- 766
		40, -- 766
		0, -- 766
		0 -- 766
	) -- 766
	place( -- 767
		hintLabel, -- 767
		48, -- 767
		84, -- 767
		0, -- 767
		0 -- 767
	) -- 767
	place( -- 768
		rulerLabel, -- 768
		w - 216, -- 768
		roomTop + 36 + v.scale * 0.5 - 14, -- 768
		1, -- 768
		0 -- 768
	) -- 768
	place( -- 769
		standLabel, -- 769
		48, -- 769
		roomTop + 40, -- 769
		0, -- 769
		0 -- 769
	) -- 769
	place( -- 770
		cartLabel, -- 770
		48, -- 770
		roomTop + 92, -- 770
		0, -- 770
		0 -- 770
	) -- 770
	if roomLabel ~= nil then -- 770
		roomLabel.text = room.name -- 773
	end -- 773
	if captionLabel ~= nil then -- 773
		captionLabel.text = room.caption -- 776
	end -- 776
	if hintLabel ~= nil then -- 776
		local hintIdx = math.min(current, #HINTS - 1) -- 779
		local lines = HINTS[hintIdx + 1] -- 780
		local merged = lines[1] -- 781
		do -- 781
			local i = 1 -- 782
			while i < #lines do -- 782
				merged = (merged .. "    ") .. lines[i + 1] -- 783
				i = i + 1 -- 782
			end -- 782
		end -- 782
		hintLabel.text = merged -- 785
	end -- 785
	local specs = collectLabels(room, v, w) -- 788
	local body = {} -- 789
	local small = {} -- 790
	do -- 790
		local i = 0 -- 791
		while i < #specs do -- 791
			local s = specs[i + 1] -- 792
			if s.size >= 24 then -- 792
				body[#body + 1] = s -- 794
			else -- 794
				small[#small + 1] = s -- 796
			end -- 796
			i = i + 1 -- 791
		end -- 791
	end -- 791
	applyPool(body, poolBody) -- 799
	applyPool(small, poolSmall) -- 800
	if LAYOUT_AUDIT then -- 800
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 803
	end -- 803
end -- 803
function applyPool(specs, pool) -- 807
	do -- 807
		local i = 0 -- 808
		while i < #pool do -- 808
			local lb = pool[i + 1] -- 809
			if i < #specs then -- 809
				local s = specs[i + 1] -- 811
				lb.text = s.text -- 812
				lb.position = Vec2(s.x, s.y) -- 813
				lb.anchor = Vec2(s.ax, s.ay) -- 814
				lb.color = s.color -- 815
				lb.visible = true -- 816
			else -- 816
				lb.visible = false -- 818
			end -- 818
			i = i + 1 -- 808
		end -- 808
	end -- 808
end -- 808
local FONT = "sarasa-mono-sc-regular" -- 22
LAYOUT_AUDIT = false -- 23
local C_TEXT = Color(236, 236, 232, 255) -- 25
local C_DIM = Color(150, 154, 152, 255) -- 26
local C_ACCENT = Color(226, 186, 84, 255) -- 27
C_BG = Color(17, 18, 19, 255) -- 28
local POOL_BODY = 30 -- 30
local POOL_SMALL = 44 -- 31
TOP_H = 208 -- 32
BOTTOM_H = 216 -- 33
profile = emptySave() -- 51
local profileStatus = "missing" -- 52
local profileDetail = "" -- 53
poolBody = {} -- 58
poolSmall = {} -- 59
current = 0 -- 61
viewW = 0 -- 62
viewH = 0 -- 63
dirty = true -- 64
mode = 1 -- 66
clock = __TS__New(StepClock) -- 70
local function makeGrayboxLabel(text, size, color) -- 72
	if grayboxLayer == nil then -- 72
		return nil -- 74
	end -- 74
	local lb = Label(FONT, size) -- 76
	if lb == nil then -- 76
		return nil -- 78
	end -- 78
	lb.text = text -- 80
	lb.color = color -- 81
	lb:addTo(grayboxLayer) -- 82
	lb.visible = true -- 83
	return lb -- 84
end -- 72
function ____exports.start(parent, initialMode, startScreen) -- 96
	if initialMode == nil then -- 96
		initialMode = 1 -- 96
	end -- 96
	if startScreen == nil then -- 96
		startScreen = "title" -- 96
	end -- 96
	root = parent -- 97
	mode = initialMode -- 98
	grayboxLayer = Node() -- 101
	grayboxLayer.order = 2 -- 102
	grayboxLayer:addTo(parent) -- 103
	draw = DrawNode() -- 105
	draw:addTo(grayboxLayer) -- 106
	campaignLayer = Node() -- 109
	campaignLayer.order = 3 -- 110
	campaignLayer:addTo(parent) -- 111
	campaignDraw = DrawNode() -- 112
	campaignDraw:addTo(campaignLayer) -- 113
	campaignHud = Label(FONT, 24) -- 114
	if campaignHud ~= nil then -- 114
		campaignHud.color = C_TEXT -- 116
		campaignHud.anchor = Vec2(0, 1) -- 117
		campaignHud:addTo(campaignLayer) -- 118
		campaignHud.visible = true -- 119
	end -- 119
	campaignSub = Label(FONT, 20) -- 121
	if campaignSub ~= nil then -- 121
		campaignSub.color = C_ACCENT -- 123
		campaignSub.anchor = Vec2(0, 1) -- 124
		campaignSub:addTo(campaignLayer) -- 125
		campaignSub.visible = true -- 126
	end -- 126
	campaignLayer.visible = mode == 2 -- 128
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 130
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 131
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 132
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 133
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 134
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 135
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 136
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 137
	do -- 137
		local i = 0 -- 139
		while i < POOL_BODY do -- 139
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 140
			if lb ~= nil then -- 140
				poolBody[#poolBody + 1] = lb -- 142
			end -- 142
			i = i + 1 -- 139
		end -- 139
	end -- 139
	do -- 139
		local i = 0 -- 145
		while i < POOL_SMALL do -- 145
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 146
			if lb ~= nil then -- 146
				poolSmall[#poolSmall + 1] = lb -- 148
			end -- 148
			i = i + 1 -- 145
		end -- 145
	end -- 145
	if mode == 1 then -- 145
		local loaded = loadSave() -- 155
		profile = loaded.state -- 156
		profileStatus = loaded.status -- 157
		profileDetail = loaded.detail -- 158
	end -- 158
	fe = __TS__New(WatchFrontend, parent) -- 160
	fe.screen = startScreen -- 161
	grayboxLayer.visible = mode == 0 -- 162
	fe:setVisible(mode == 1) -- 163
	if campaignLayer ~= nil then -- 163
		campaignLayer.visible = mode == 2 -- 165
	end -- 165
	input = __TS__New(Input) -- 168
	parent:onKeyDown(function(key) -- 171
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or play ~= nil and play.paused) then -- 171
			fe.menus:onKeyEvent(key) -- 173
		end -- 173
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" or mode == 2) then -- 173
			if key == "E" then -- 173
				input.interact.pressed = true -- 177
			elseif key == "Space" then -- 177
				input.jump.pressed = true -- 179
			elseif key == "Escape" then -- 179
				input.pause.pressed = true -- 181
			elseif key == "R" then -- 181
				input.retry.pressed = true -- 183
			end -- 183
		end -- 183
		if mode == 2 and (run and run.trial) ~= nil then -- 183
			return -- 186
		end -- 186
		if key == "F1" then -- 186
			if mode == 2 then -- 186
				current = 0 -- 189
				play = nil -- 190
				ensurePlay() -- 191
			else -- 191
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 193
			end -- 193
		elseif key == "F2" then -- 193
			setMode(0) -- 196
		elseif key == "1" then -- 196
			pickByIndex(0) -- 198
		elseif key == "2" then -- 198
			pickByIndex(1) -- 200
		elseif key == "3" then -- 200
			pickByIndex(2) -- 202
		elseif key == "4" then -- 202
			pickByIndex(3) -- 204
		elseif key == "5" then -- 204
			pickByIndex(4) -- 206
		elseif key == "6" then -- 206
			pickByIndex(5) -- 208
		elseif key == "7" then -- 208
			pickByIndex(6) -- 210
		elseif key == "8" then -- 210
			pickByIndex(7) -- 212
		end -- 212
	end) -- 171
	viewW = View.size.width -- 216
	viewH = View.size.height -- 217
	applySize() -- 218
	local reg = _G.package.loaded -- 221
	reg["watch.input"] = input -- 222
	reg["watch.fe"] = { -- 223
		setScreen = function(sc) -- 224
			if fe == nil then -- 224
				return -- 226
			end -- 226
			setMode(1) -- 228
			fe.screen = sc -- 229
			if sc == "chapters" then -- 229
				fe.menus:openChapters() -- 231
			else -- 231
				fe.menus:resetInput() -- 233
			end -- 233
			if sc == "play" then -- 233
				ensurePlay() -- 236
			end -- 236
		end, -- 224
		jumpRoom = function(keyOrIdx) -- 239
			local idx = -1 -- 240
			if type(keyOrIdx) == "number" then -- 240
				idx = keyOrIdx -- 242
			else -- 242
				local k = 0 -- 244
				do -- 244
					k = 0 -- 245
					while k < #ROOMS do -- 245
						if ROOMS[k + 1].key == keyOrIdx then -- 245
							idx = k -- 247
						end -- 247
						k = k + 1 -- 245
					end -- 245
				end -- 245
			end -- 245
			if idx >= 0 and idx < #ROOMS then -- 245
				enterPlayRoom(idx, "debug") -- 252
			end -- 252
		end, -- 239
		getPlay = function() return play end, -- 255
		getFrontend = function() return fe end, -- 256
		startStory = function() -- 258
			enterPlayRoom(0, "official", true) -- 259
			return play -- 260
		end, -- 258
		previewChapter = function(idx) -- 263
			enterPlayRoom(idx, "chapter") -- 264
			return play -- 265
		end, -- 263
		getStoryRun = function() return storyRun end, -- 267
		getProfile = function() return profile end, -- 269
		getProfileStatus = function() return profileStatus end, -- 270
		getProfileDetail = function() return profileDetail end, -- 271
		useTestSave = function(name) -- 272
			setSaveFile(name) -- 273
			local loaded = loadSave() -- 274
			profile = loaded.state -- 275
			profileStatus = loaded.status -- 276
			profileDetail = loaded.detail -- 277
		end, -- 272
		saveNow = function() return saveSave(profile) end, -- 279
		getSaveFile = getSaveFile -- 280
	} -- 280
	if mode == 1 and startScreen == "play" then -- 280
		ensurePlay() -- 284
	end -- 284
	parent:schedule(function(frameDt) -- 287
		tick(frameDt) -- 288
		return false -- 289
	end) -- 287
end -- 96
return ____exports -- 96