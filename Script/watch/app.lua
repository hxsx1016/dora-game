-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local place, setMode, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, pickByIndex, applySize, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock -- 1
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
local markProfilePending = ____save.markProfilePending -- 18
local flushSaveProfile = ____save.flushProfile -- 18
local clearProfilePending = ____save.clearProfilePending -- 18
local profilePending = ____save.profilePending -- 18
function place(lb, x, y, ax, ay) -- 88
	if lb == nil then -- 88
		return -- 90
	end -- 90
	lb.position = Vec2(x, y) -- 92
	lb.anchor = Vec2(ax, ay) -- 93
	lb.visible = true -- 94
end -- 94
function setMode(nextMode) -- 297
	mode = nextMode -- 298
	if grayboxLayer ~= nil then -- 298
		grayboxLayer.visible = mode == 0 -- 300
	end -- 300
	if fe ~= nil then -- 300
		fe:setVisible(mode == 1) -- 303
	end -- 303
	if campaignLayer ~= nil then -- 303
		campaignLayer.visible = mode == 2 -- 306
	end -- 306
	dirty = true -- 308
	clock:reset() -- 309
end -- 309
function flushProfile() -- 316
	local cur = play -- 317
	if cur ~= nil and cur.archiveDirty then -- 317
		cur.archiveDirty = false -- 319
		markProfilePending(profile) -- 320
	end -- 320
	local ok = flushSaveProfile() -- 322
	if not ok and cur ~= nil then -- 322
		cur.archiveDirty = true -- 324
	end -- 324
	return ok -- 326
end -- 326
function officialStartIndex() -- 330
	local mp = profile.museumPhase -- 331
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 332
	return inMuseum and roomIndexByKey("museum") or 0 -- 333
end -- 333
function roomIndexByKey(key) -- 336
	local i = 0 -- 337
	do -- 337
		i = 0 -- 338
		while i < #ROOMS do -- 338
			if ROOMS[i + 1].key == key then -- 338
				return i -- 340
			end -- 340
			i = i + 1 -- 338
		end -- 338
	end -- 338
	return 0 -- 343
end -- 343
function enterPlayRoom(idx, source, fresh) -- 346
	if source == nil then -- 346
		source = "debug" -- 346
	end -- 346
	if fresh == nil then -- 346
		fresh = false -- 346
	end -- 346
	current = idx -- 347
	setMode(1) -- 348
	if fe ~= nil then -- 348
		fe.screen = "play" -- 350
	end -- 350
	play = nil -- 352
	if fresh or storyRun == nil then -- 352
		storyRun = createRun(20261124, source, profile) -- 355
	else -- 355
		storyRun.source = source -- 357
	end -- 357
	ensurePlay() -- 359
	local firstPlay = play -- 361
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 361
		firstPlay.phase = "prologue-wake" -- 363
	end -- 363
	flushProfile() -- 365
end -- 365
function pickByIndex(idx, source) -- 368
	if source == nil then -- 368
		source = "debug" -- 368
	end -- 368
	if mode == 2 then -- 368
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 368
			return -- 371
		end -- 371
		current = idx -- 373
		play = nil -- 374
		clock:reset() -- 375
		ensurePlay() -- 376
		return -- 377
	end -- 377
	if idx < 0 or idx >= #ROOMS then -- 377
		return -- 380
	end -- 380
	flushProfile() -- 382
	if storyRun ~= nil then -- 382
		storyRun.source = source -- 384
	end -- 384
	current = idx -- 386
	dirty = true -- 387
	play = nil -- 388
	clock:reset() -- 389
	if mode == 1 then -- 389
		if fe ~= nil then -- 389
			fe.screen = "play" -- 392
		end -- 392
		ensurePlay() -- 394
	end -- 394
end -- 394
function applySize() -- 398
	if root == nil then -- 398
		return -- 400
	end -- 400
	root.size = Size(viewW, viewH) -- 402
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 403
end -- 403
function tick(frameDt) -- 406
	local w = View.size.width -- 407
	local h = View.size.height -- 408
	if w ~= viewW or h ~= viewH then -- 408
		viewW = w -- 410
		viewH = h -- 411
		applySize() -- 412
		dirty = true -- 413
	end -- 413
	if input == nil then -- 413
		return -- 416
	end -- 416
	input:update() -- 418
	if mode == 2 and (run and run.trial) ~= nil then -- 418
		tickCampaign(frameDt) -- 420
		return -- 421
	end -- 421
	if input.toggleView.pressed then -- 421
		input.toggleView.pressed = false -- 426
		setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 427
		if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 427
			ensurePlay() -- 429
		end -- 429
	end -- 429
	if input.pickRoom ~= 0 then -- 429
		local idx = input.pickRoom - 1 -- 435
		input.pickRoom = 0 -- 436
		pickByIndex(idx) -- 437
	elseif input.tab.pressed then -- 437
		input.tab.pressed = false -- 439
		if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 439
			pickByIndex((current + 1) % #ROOMS) -- 441
		end -- 441
	end -- 441
	if mode == 2 then -- 441
		tickCampaign(frameDt) -- 446
		return -- 447
	end -- 447
	if mode == 1 then -- 447
		tickFrontend(frameDt) -- 450
		return -- 451
	end -- 451
	if dirty then -- 451
		redrawGraybox() -- 454
		dirty = false -- 455
	end -- 455
end -- 455
function registerPlay() -- 460
	local reg = _G.package.loaded -- 461
	reg["watch.play"] = play -- 462
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 463
	reg["watch.room"] = rooms[current + 1].key -- 464
end -- 464
function ensurePlay(resume) -- 468
	if mode == 2 then -- 468
		if run == nil then -- 468
			run = createRun() -- 471
		end -- 471
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 473
	else -- 473
		if storyRun == nil then -- 473
			storyRun = createRun(20261124, "debug", profile) -- 478
		end -- 478
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 480
	end -- 480
	registerPlay() -- 482
	clock:reset() -- 483
	if fe ~= nil and mode == 1 then -- 483
		fe:bindPlay(play, viewW, viewH) -- 485
	end -- 485
end -- 485
function startTrial() -- 489
	current = 0 -- 490
	run = createTrial(App.rand) -- 491
	setMode(2) -- 492
	ensurePlay() -- 493
end -- 493
function tickCampaign(frameDt) -- 496
	if input == nil then -- 496
		return -- 498
	end -- 498
	if play == nil then -- 498
		ensurePlay() -- 501
	end -- 501
	if play == nil then -- 501
		return -- 504
	end -- 504
	local p = play -- 506
	p.aimX = input.mx -- 507
	p.aimY = input.my -- 508
	local trial = run and run.trial -- 510
	if trial ~= nil then -- 510
		local ended = trial.lost or (run and run.finished) == true -- 512
		local pick = input.pickRoom -- 513
		input.pickRoom = 0 -- 514
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 514
			input:consumeEdges() -- 516
			current = 0 -- 517
			play = nil -- 518
			run = nil -- 519
			setMode(1) -- 520
			if fe ~= nil then -- 520
				fe.screen = "title" -- 522
				fe.menus:resetInput() -- 523
			end -- 523
			return -- 525
		end -- 525
		if ended or p.paused and input.retry.pressed then -- 525
			local restart = input.retry.pressed -- 528
			input:consumeEdges() -- 529
			if restart then -- 529
				startTrial() -- 530
			else -- 530
				drawCampaign(p) -- 531
			end -- 531
			return -- 532
		end -- 532
		input.retry.pressed = false -- 534
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 534
			if pick > 0 then -- 534
				p:chooseTalent(pick - 1) -- 536
			end -- 536
			input:consumeEdges() -- 537
			clock:reset() -- 538
			drawCampaign(p) -- 539
			return -- 540
		end -- 540
	end -- 540
	if input.retry.pressed then -- 540
		input.retry.pressed = false -- 545
		input:consumeEdges() -- 546
		play = nil -- 548
		ensurePlay() -- 549
		return -- 550
	end -- 550
	if input.pause.pressed then -- 550
		input.pause.pressed = false -- 553
		p.paused = not p.paused -- 554
		clock:reset() -- 555
		input:consumeEdges() -- 556
	end -- 556
	if p.paused then -- 556
		drawCampaign(p) -- 559
		return -- 560
	end -- 560
	local steps = clock:advance(frameDt) -- 563
	local i = 0 -- 564
	do -- 564
		i = 0 -- 565
		while i < steps do -- 565
			input:beginStep(i == 0) -- 566
			p:update(STEP, input) -- 567
			input:endStep() -- 568
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 568
				break -- 570
			end -- 570
			i = i + 1 -- 565
		end -- 565
	end -- 565
	if p.wantRoom ~= "" then -- 565
		local key = p.wantRoom -- 575
		p.wantRoom = "" -- 576
		local idx = -1 -- 577
		local j = 0 -- 578
		do -- 578
			j = 0 -- 579
			while j < #CAMPAIGN_ROOMS do -- 579
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 579
					idx = j -- 581
				end -- 581
				j = j + 1 -- 579
			end -- 579
		end -- 579
		if idx >= 0 then -- 579
			current = idx -- 585
			play = nil -- 586
			ensurePlay() -- 587
		end -- 587
		return -- 589
	end -- 589
	drawCampaign(p) -- 591
end -- 591
function goalLabel(goal) -- 594
	if goal == "dock_cart" then -- 594
		return "推车入窝并抬闩" -- 596
	end -- 596
	if goal == "raise_latch" then -- 596
		return "抬闩开侧门" -- 599
	end -- 599
	return "到段出口" -- 601
end -- 601
function drawCampaign(p) -- 604
	if campaignDraw == nil then -- 604
		return -- 606
	end -- 606
	local w = viewW -- 608
	local h = viewH -- 609
	p:draw(campaignDraw, w, h) -- 610
	local room = CAMPAIGN_ROOMS[current + 1] -- 611
	local c = room.campaign -- 612
	local r = run -- 613
	local line = room.name -- 614
	if c ~= nil then -- 614
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 616
	end -- 616
	if p.paused then -- 616
		line = line .. "  · 已暂停 Esc 继续" -- 620
	end -- 620
	local trial = r and r.trial -- 622
	if trial ~= nil and r ~= nil then -- 622
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 624
		if p.paused then -- 624
			line = line .. " · 暂停" -- 625
		elseif trial.lost then -- 625
			line = line .. " · 护送失败" -- 626
		elseif r.finished then -- 626
			line = line .. " · 护送完成" -- 627
		elseif #trial.offers > 0 then -- 627
			line = line .. " · 选择本段本领" -- 628
		elseif c ~= nil then -- 628
			line = line .. " · " .. goalLabel(c.goal) -- 629
		end -- 629
	end -- 629
	if campaignHud ~= nil then -- 629
		campaignHud.text = line -- 632
		campaignHud.position = Vec2(24, h - 14) -- 633
		campaignHud.visible = true -- 634
	end -- 634
	if campaignSub ~= nil then -- 634
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 637
		if r ~= nil then -- 637
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 639
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 640
		end -- 640
		if p.flash ~= "" then -- 640
			sub = (sub .. " · ") .. p.flash -- 646
		end -- 646
		if trial ~= nil and r ~= nil then -- 646
			if trial.lost or r.finished then -- 646
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 649
			elseif p.paused then -- 649
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 650
			elseif #trial.offers > 0 then -- 650
				sub = table.concat( -- 651
					__TS__ArrayMap( -- 651
						trial.offers, -- 651
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 651
					), -- 651
					"　" -- 651
				) -- 651
			else -- 651
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 652
			end -- 652
		end -- 652
		campaignSub.text = sub -- 654
		campaignSub.position = Vec2(24, h - 44) -- 655
		campaignSub.visible = true -- 656
	end -- 656
end -- 656
function tickFrontend(frameDt) -- 660
	if fe == nil or input == nil then -- 660
		return -- 662
	end -- 662
	if fe.screen ~= "play" then -- 662
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 667
		input:consumeEdges() -- 668
		if act.type == "trial" then -- 668
			startTrial() -- 670
		elseif act.type == "start" then -- 670
			enterPlayRoom( -- 673
				officialStartIndex(), -- 673
				"official", -- 673
				true -- 673
			) -- 673
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 673
			enterPlayRoom(act.roomIndex, "chapter") -- 675
		elseif act.type == "openChapters" then -- 675
			fe.menus:openChapters() -- 677
			fe.screen = "chapters" -- 678
		elseif act.type == "openControls" then -- 678
			fe.menus:resetInput() -- 680
			fe.screen = "controls" -- 681
		elseif act.type == "backTitle" then -- 681
			fe.menus:resetInput() -- 683
			fe.screen = "title" -- 684
		elseif act.type == "backPause" then -- 684
			fe.menus:resetInput() -- 686
			fe.screen = "play" -- 687
		end -- 687
		return -- 689
	end -- 689
	if play == nil then -- 689
		ensurePlay() -- 694
	end -- 694
	if play == nil then -- 694
		return -- 697
	end -- 697
	local p = play -- 699
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 701
	if input.retry.pressed and not inTowerEnding then -- 701
		input:consumeEdges() -- 703
		ensurePlay({checkpoint = p.checkpoint}) -- 705
		return -- 706
	end -- 706
	p.aimX = input.mx -- 709
	p.aimY = input.my -- 710
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 710
		p:closeCraftBench() -- 713
		input:consumeEdges() -- 714
		return -- 715
	end -- 715
	if not p.paused and input.pause.pressed then -- 715
		p.paused = true -- 718
		p.aimHold = 0 -- 719
		p.bottleAimX = -1 -- 720
		fe.menus:openPause() -- 721
		input:consumeEdges() -- 722
	end -- 722
	if p.paused then -- 722
		clock:reset() -- 727
		local pauseAct = fe:renderPlay( -- 728
			frameDt, -- 728
			p, -- 728
			input, -- 728
			viewW, -- 728
			viewH -- 728
		) -- 728
		input:consumeEdges() -- 729
		if pauseAct.type == "resume" then -- 729
			p.paused = false -- 731
		elseif pauseAct.type == "retry" then -- 731
			ensurePlay({checkpoint = p.checkpoint}) -- 733
		elseif pauseAct.type == "openChapters" then -- 733
			fe.menus:openChapters(current) -- 735
			fe.screen = "chapters" -- 736
		elseif pauseAct.type == "toTitle" then -- 736
			fe.menus:resetInput() -- 738
			fe.screen = "title" -- 739
		end -- 739
		return -- 741
	end -- 741
	local steps = clock:advance(frameDt) -- 744
	local i = 0 -- 745
	do -- 745
		i = 0 -- 746
		while i < steps do -- 746
			input:beginStep(i == 0) -- 747
			p:update(STEP, input) -- 748
			input:endStep() -- 749
			if p.wantRoom ~= "" then -- 749
				break -- 751
			end -- 751
			i = i + 1 -- 746
		end -- 746
	end -- 746
	if p.wantRoom ~= "" then -- 746
		local key = p.wantRoom -- 757
		p.wantRoom = "" -- 758
		local idx = -1 -- 759
		local j = 0 -- 760
		do -- 760
			j = 0 -- 761
			while j < #ROOMS do -- 761
				if ROOMS[j + 1].key == key then -- 761
					idx = j -- 763
				end -- 763
				j = j + 1 -- 761
			end -- 761
		end -- 761
		if idx >= 0 then -- 761
			flushProfile() -- 770
			local leaving = p:drainEvents() -- 771
			if p.restartStory then -- 771
				storyRun = createRun(20261124, storyRun == nil and "official" or storyRun.source, profile) -- 774
			end -- 774
			current = idx -- 776
			ensurePlay() -- 777
			local fresh = play -- 778
			if fresh ~= nil then -- 778
				fresh:adoptEvents(leaving) -- 780
			end -- 780
			clock:reset() -- 782
			dirty = true -- 783
		end -- 783
		return -- 785
	end -- 785
	flushProfile() -- 789
	fe:renderPlay( -- 790
		frameDt, -- 790
		p, -- 790
		input, -- 790
		viewW, -- 790
		viewH -- 790
	) -- 790
end -- 790
function redrawGraybox() -- 794
	if draw == nil then -- 794
		return -- 796
	end -- 796
	local w = viewW -- 798
	local h = viewH -- 799
	local room = ROOMS[current + 1] -- 800
	draw:clear() -- 802
	draw:drawRect( -- 803
		Rect(0, h - TOP_H, w, TOP_H), -- 803
		C_BG -- 803
	) -- 803
	draw:drawRect( -- 804
		Rect(0, 0, w, BOTTOM_H), -- 804
		C_BG -- 804
	) -- 804
	draw:drawSegment( -- 805
		Vec2(0, h - TOP_H), -- 805
		Vec2(w, h - TOP_H), -- 805
		1, -- 805
		Color(52, 54, 54, 255) -- 805
	) -- 805
	draw:drawSegment( -- 806
		Vec2(0, BOTTOM_H), -- 806
		Vec2(w, BOTTOM_H), -- 806
		1, -- 806
		Color(52, 54, 54, 255) -- 806
	) -- 806
	local v = computeView(room, w, h) -- 808
	renderWorld( -- 809
		draw, -- 809
		room, -- 809
		v, -- 809
		w, -- 809
		h -- 809
	) -- 809
	local roomTop = v.groundPx + room.height * v.scale -- 811
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 812
	place( -- 814
		titleLabel, -- 814
		48, -- 814
		h - 40, -- 814
		0, -- 814
		1 -- 814
	) -- 814
	place( -- 815
		roomLabel, -- 815
		48, -- 815
		h - 96, -- 815
		0, -- 815
		1 -- 815
	) -- 815
	place( -- 816
		captionLabel, -- 816
		48, -- 816
		h - 140, -- 816
		0, -- 816
		1 -- 816
	) -- 816
	place( -- 818
		switchLabel, -- 818
		48, -- 818
		40, -- 818
		0, -- 818
		0 -- 818
	) -- 818
	place( -- 819
		hintLabel, -- 819
		48, -- 819
		84, -- 819
		0, -- 819
		0 -- 819
	) -- 819
	place( -- 820
		rulerLabel, -- 820
		w - 216, -- 820
		roomTop + 36 + v.scale * 0.5 - 14, -- 820
		1, -- 820
		0 -- 820
	) -- 820
	place( -- 821
		standLabel, -- 821
		48, -- 821
		roomTop + 40, -- 821
		0, -- 821
		0 -- 821
	) -- 821
	place( -- 822
		cartLabel, -- 822
		48, -- 822
		roomTop + 92, -- 822
		0, -- 822
		0 -- 822
	) -- 822
	if roomLabel ~= nil then -- 822
		roomLabel.text = room.name -- 825
	end -- 825
	if captionLabel ~= nil then -- 825
		captionLabel.text = room.caption -- 828
	end -- 828
	if hintLabel ~= nil then -- 828
		local hintIdx = math.min(current, #HINTS - 1) -- 831
		local lines = HINTS[hintIdx + 1] -- 832
		local merged = lines[1] -- 833
		do -- 833
			local i = 1 -- 834
			while i < #lines do -- 834
				merged = (merged .. "    ") .. lines[i + 1] -- 835
				i = i + 1 -- 834
			end -- 834
		end -- 834
		hintLabel.text = merged -- 837
	end -- 837
	local specs = collectLabels(room, v, w) -- 840
	local body = {} -- 841
	local small = {} -- 842
	do -- 842
		local i = 0 -- 843
		while i < #specs do -- 843
			local s = specs[i + 1] -- 844
			if s.size >= 24 then -- 844
				body[#body + 1] = s -- 846
			else -- 846
				small[#small + 1] = s -- 848
			end -- 848
			i = i + 1 -- 843
		end -- 843
	end -- 843
	applyPool(body, poolBody) -- 851
	applyPool(small, poolSmall) -- 852
	if LAYOUT_AUDIT then -- 852
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 855
	end -- 855
end -- 855
function applyPool(specs, pool) -- 859
	do -- 859
		local i = 0 -- 860
		while i < #pool do -- 860
			local lb = pool[i + 1] -- 861
			if i < #specs then -- 861
				local s = specs[i + 1] -- 863
				lb.text = s.text -- 864
				lb.position = Vec2(s.x, s.y) -- 865
				lb.anchor = Vec2(s.ax, s.ay) -- 866
				lb.color = s.color -- 867
				lb.visible = true -- 868
			else -- 868
				lb.visible = false -- 870
			end -- 870
			i = i + 1 -- 860
		end -- 860
	end -- 860
end -- 860
local FONT = "sarasa-mono-sc-regular" -- 23
LAYOUT_AUDIT = false -- 24
local C_TEXT = Color(236, 236, 232, 255) -- 26
local C_DIM = Color(150, 154, 152, 255) -- 27
local C_ACCENT = Color(226, 186, 84, 255) -- 28
C_BG = Color(17, 18, 19, 255) -- 29
local POOL_BODY = 30 -- 31
local POOL_SMALL = 44 -- 32
TOP_H = 208 -- 33
BOTTOM_H = 216 -- 34
profile = emptySave() -- 52
local profileStatus = "missing" -- 53
local profileDetail = "" -- 54
poolBody = {} -- 59
poolSmall = {} -- 60
current = 0 -- 62
viewW = 0 -- 63
viewH = 0 -- 64
dirty = true -- 65
mode = 1 -- 67
clock = __TS__New(StepClock) -- 71
local function makeGrayboxLabel(text, size, color) -- 73
	if grayboxLayer == nil then -- 73
		return nil -- 75
	end -- 75
	local lb = Label(FONT, size) -- 77
	if lb == nil then -- 77
		return nil -- 79
	end -- 79
	lb.text = text -- 81
	lb.color = color -- 82
	lb:addTo(grayboxLayer) -- 83
	lb.visible = true -- 84
	return lb -- 85
end -- 73
function ____exports.start(parent, initialMode, startScreen) -- 97
	if initialMode == nil then -- 97
		initialMode = 1 -- 97
	end -- 97
	if startScreen == nil then -- 97
		startScreen = "title" -- 97
	end -- 97
	root = parent -- 98
	mode = initialMode -- 99
	grayboxLayer = Node() -- 102
	grayboxLayer.order = 2 -- 103
	grayboxLayer:addTo(parent) -- 104
	draw = DrawNode() -- 106
	draw:addTo(grayboxLayer) -- 107
	campaignLayer = Node() -- 110
	campaignLayer.order = 3 -- 111
	campaignLayer:addTo(parent) -- 112
	campaignDraw = DrawNode() -- 113
	campaignDraw:addTo(campaignLayer) -- 114
	campaignHud = Label(FONT, 24) -- 115
	if campaignHud ~= nil then -- 115
		campaignHud.color = C_TEXT -- 117
		campaignHud.anchor = Vec2(0, 1) -- 118
		campaignHud:addTo(campaignLayer) -- 119
		campaignHud.visible = true -- 120
	end -- 120
	campaignSub = Label(FONT, 20) -- 122
	if campaignSub ~= nil then -- 122
		campaignSub.color = C_ACCENT -- 124
		campaignSub.anchor = Vec2(0, 1) -- 125
		campaignSub:addTo(campaignLayer) -- 126
		campaignSub.visible = true -- 127
	end -- 127
	campaignLayer.visible = mode == 2 -- 129
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 131
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 132
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 133
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 134
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 135
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 136
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 137
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 138
	do -- 138
		local i = 0 -- 140
		while i < POOL_BODY do -- 140
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 141
			if lb ~= nil then -- 141
				poolBody[#poolBody + 1] = lb -- 143
			end -- 143
			i = i + 1 -- 140
		end -- 140
	end -- 140
	do -- 140
		local i = 0 -- 146
		while i < POOL_SMALL do -- 146
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 147
			if lb ~= nil then -- 147
				poolSmall[#poolSmall + 1] = lb -- 149
			end -- 149
			i = i + 1 -- 146
		end -- 146
	end -- 146
	if mode == 1 then -- 146
		local loaded = loadSave() -- 156
		profile = loaded.state -- 157
		profileStatus = loaded.status -- 158
		profileDetail = loaded.detail -- 159
	end -- 159
	fe = __TS__New(WatchFrontend, parent) -- 161
	fe.screen = startScreen -- 162
	grayboxLayer.visible = mode == 0 -- 163
	fe:setVisible(mode == 1) -- 164
	if campaignLayer ~= nil then -- 164
		campaignLayer.visible = mode == 2 -- 166
	end -- 166
	input = __TS__New(Input) -- 169
	parent:onKeyDown(function(key) -- 172
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or play ~= nil and play.paused) then -- 172
			fe.menus:onKeyEvent(key) -- 174
		end -- 174
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" or mode == 2) then -- 174
			if key == "E" then -- 174
				input.interact.pressed = true -- 178
			elseif key == "Space" then -- 178
				input.jump.pressed = true -- 180
			elseif key == "Escape" then -- 180
				input.pause.pressed = true -- 182
			elseif key == "R" then -- 182
				input.retry.pressed = true -- 184
			end -- 184
		end -- 184
		if mode == 2 and (run and run.trial) ~= nil then -- 184
			return -- 187
		end -- 187
		if key == "F1" then -- 187
			if mode == 2 then -- 187
				current = 0 -- 190
				play = nil -- 191
				ensurePlay() -- 192
			else -- 192
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 194
			end -- 194
		elseif key == "F2" then -- 194
			setMode(0) -- 197
		elseif key == "1" then -- 197
			pickByIndex(0) -- 199
		elseif key == "2" then -- 199
			pickByIndex(1) -- 201
		elseif key == "3" then -- 201
			pickByIndex(2) -- 203
		elseif key == "4" then -- 203
			pickByIndex(3) -- 205
		elseif key == "5" then -- 205
			pickByIndex(4) -- 207
		elseif key == "6" then -- 207
			pickByIndex(5) -- 209
		elseif key == "7" then -- 209
			pickByIndex(6) -- 211
		elseif key == "8" then -- 211
			pickByIndex(7) -- 213
		end -- 213
	end) -- 172
	viewW = View.size.width -- 217
	viewH = View.size.height -- 218
	applySize() -- 219
	local reg = _G.package.loaded -- 222
	reg["watch.input"] = input -- 223
	reg["watch.fe"] = { -- 224
		setScreen = function(sc) -- 225
			if fe == nil then -- 225
				return -- 227
			end -- 227
			setMode(1) -- 229
			fe.screen = sc -- 230
			if sc == "chapters" then -- 230
				fe.menus:openChapters() -- 232
			else -- 232
				fe.menus:resetInput() -- 234
			end -- 234
			if sc == "play" then -- 234
				ensurePlay() -- 237
			end -- 237
		end, -- 225
		jumpRoom = function(keyOrIdx) -- 240
			local idx = -1 -- 241
			if type(keyOrIdx) == "number" then -- 241
				idx = keyOrIdx -- 243
			else -- 243
				local k = 0 -- 245
				do -- 245
					k = 0 -- 246
					while k < #ROOMS do -- 246
						if ROOMS[k + 1].key == keyOrIdx then -- 246
							idx = k -- 248
						end -- 248
						k = k + 1 -- 246
					end -- 246
				end -- 246
			end -- 246
			if idx >= 0 and idx < #ROOMS then -- 246
				enterPlayRoom(idx, "debug") -- 253
			end -- 253
		end, -- 240
		getPlay = function() return play end, -- 256
		getFrontend = function() return fe end, -- 257
		startStory = function() -- 259
			enterPlayRoom( -- 260
				officialStartIndex(), -- 260
				"official", -- 260
				true -- 260
			) -- 260
			return play -- 261
		end, -- 259
		previewChapter = function(idx) -- 264
			enterPlayRoom(idx, "chapter") -- 265
			return play -- 266
		end, -- 264
		getStoryRun = function() return storyRun end, -- 268
		getProfilePending = function() return profilePending() end, -- 269
		flushProfileNow = function() return flushProfile() end, -- 270
		getProfile = function() return profile end, -- 272
		getProfileStatus = function() return profileStatus end, -- 273
		getProfileDetail = function() return profileDetail end, -- 274
		useTestSave = function(name) -- 275
			setSaveFile(name) -- 276
			clearProfilePending() -- 277
			local loaded = loadSave() -- 278
			profile = loaded.state -- 279
			profileStatus = loaded.status -- 280
			profileDetail = loaded.detail -- 281
		end, -- 275
		saveNow = function() return saveSave(profile) end, -- 283
		getSaveFile = getSaveFile -- 284
	} -- 284
	if mode == 1 and startScreen == "play" then -- 284
		ensurePlay() -- 288
	end -- 288
	parent:schedule(function(frameDt) -- 291
		tick(frameDt) -- 292
		return false -- 293
	end) -- 291
end -- 97
return ____exports -- 97