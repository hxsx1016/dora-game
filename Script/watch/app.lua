-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local place, setMode, flushProfile, roomIndexByKey, enterPlayRoom, pickByIndex, applySize, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock -- 1
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
function roomIndexByKey(key) -- 329
	local i = 0 -- 330
	do -- 330
		i = 0 -- 331
		while i < #ROOMS do -- 331
			if ROOMS[i + 1].key == key then -- 331
				return i -- 333
			end -- 333
			i = i + 1 -- 331
		end -- 331
	end -- 331
	return 0 -- 336
end -- 336
function enterPlayRoom(idx, source, fresh) -- 339
	if source == nil then -- 339
		source = "debug" -- 339
	end -- 339
	if fresh == nil then -- 339
		fresh = false -- 339
	end -- 339
	current = idx -- 340
	setMode(1) -- 341
	if fe ~= nil then -- 341
		fe.screen = "play" -- 343
	end -- 343
	play = nil -- 345
	if fresh or storyRun == nil then -- 345
		storyRun = createRun(20261124, source, profile) -- 348
	else -- 348
		storyRun.source = source -- 350
	end -- 350
	ensurePlay() -- 352
	flushProfile() -- 353
end -- 353
function pickByIndex(idx, source) -- 356
	if source == nil then -- 356
		source = "debug" -- 356
	end -- 356
	if mode == 2 then -- 356
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 356
			return -- 359
		end -- 359
		current = idx -- 361
		play = nil -- 362
		clock:reset() -- 363
		ensurePlay() -- 364
		return -- 365
	end -- 365
	if idx < 0 or idx >= #ROOMS then -- 365
		return -- 368
	end -- 368
	current = idx -- 370
	dirty = true -- 371
	play = nil -- 372
	clock:reset() -- 373
	if mode == 1 then -- 373
		if fe ~= nil then -- 373
			fe.screen = "play" -- 376
		end -- 376
		ensurePlay() -- 378
	end -- 378
end -- 378
function applySize() -- 382
	if root == nil then -- 382
		return -- 384
	end -- 384
	root.size = Size(viewW, viewH) -- 386
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 387
end -- 387
function tick(frameDt) -- 390
	local w = View.size.width -- 391
	local h = View.size.height -- 392
	if w ~= viewW or h ~= viewH then -- 392
		viewW = w -- 394
		viewH = h -- 395
		applySize() -- 396
		dirty = true -- 397
	end -- 397
	if input == nil then -- 397
		return -- 400
	end -- 400
	input:update() -- 402
	if mode == 2 and (run and run.trial) ~= nil then -- 402
		tickCampaign(frameDt) -- 404
		return -- 405
	end -- 405
	if input.toggleView.pressed then -- 405
		input.toggleView.pressed = false -- 410
		setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 411
		if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 411
			ensurePlay() -- 413
		end -- 413
	end -- 413
	if input.pickRoom ~= 0 then -- 413
		local idx = input.pickRoom - 1 -- 419
		input.pickRoom = 0 -- 420
		pickByIndex(idx) -- 421
	elseif input.tab.pressed then -- 421
		input.tab.pressed = false -- 423
		if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 423
			pickByIndex((current + 1) % #ROOMS) -- 425
		end -- 425
	end -- 425
	if mode == 2 then -- 425
		tickCampaign(frameDt) -- 430
		return -- 431
	end -- 431
	if mode == 1 then -- 431
		tickFrontend(frameDt) -- 434
		return -- 435
	end -- 435
	if dirty then -- 435
		redrawGraybox() -- 438
		dirty = false -- 439
	end -- 439
end -- 439
function registerPlay() -- 444
	local reg = _G.package.loaded -- 445
	reg["watch.play"] = play -- 446
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 447
	reg["watch.room"] = rooms[current + 1].key -- 448
end -- 448
function ensurePlay(resume) -- 452
	if mode == 2 then -- 452
		if run == nil then -- 452
			run = createRun() -- 455
		end -- 455
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 457
	else -- 457
		if storyRun == nil then -- 457
			storyRun = createRun(20261124, "debug", profile) -- 462
		end -- 462
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 464
	end -- 464
	registerPlay() -- 466
	clock:reset() -- 467
	if fe ~= nil and mode == 1 then -- 467
		fe:bindPlay(play, viewW, viewH) -- 469
	end -- 469
end -- 469
function startTrial() -- 473
	current = 0 -- 474
	run = createTrial(App.rand) -- 475
	setMode(2) -- 476
	ensurePlay() -- 477
end -- 477
function tickCampaign(frameDt) -- 480
	if input == nil then -- 480
		return -- 482
	end -- 482
	if play == nil then -- 482
		ensurePlay() -- 485
	end -- 485
	if play == nil then -- 485
		return -- 488
	end -- 488
	local p = play -- 490
	p.aimX = input.mx -- 491
	p.aimY = input.my -- 492
	local trial = run and run.trial -- 494
	if trial ~= nil then -- 494
		local ended = trial.lost or (run and run.finished) == true -- 496
		local pick = input.pickRoom -- 497
		input.pickRoom = 0 -- 498
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 498
			input:consumeEdges() -- 500
			current = 0 -- 501
			play = nil -- 502
			run = nil -- 503
			setMode(1) -- 504
			if fe ~= nil then -- 504
				fe.screen = "title" -- 506
				fe.menus:resetInput() -- 507
			end -- 507
			return -- 509
		end -- 509
		if ended or p.paused and input.retry.pressed then -- 509
			local restart = input.retry.pressed -- 512
			input:consumeEdges() -- 513
			if restart then -- 513
				startTrial() -- 514
			else -- 514
				drawCampaign(p) -- 515
			end -- 515
			return -- 516
		end -- 516
		input.retry.pressed = false -- 518
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 518
			if pick > 0 then -- 518
				p:chooseTalent(pick - 1) -- 520
			end -- 520
			input:consumeEdges() -- 521
			clock:reset() -- 522
			drawCampaign(p) -- 523
			return -- 524
		end -- 524
	end -- 524
	if input.retry.pressed then -- 524
		input.retry.pressed = false -- 529
		input:consumeEdges() -- 530
		play = nil -- 532
		ensurePlay() -- 533
		return -- 534
	end -- 534
	if input.pause.pressed then -- 534
		input.pause.pressed = false -- 537
		p.paused = not p.paused -- 538
		clock:reset() -- 539
		input:consumeEdges() -- 540
	end -- 540
	if p.paused then -- 540
		drawCampaign(p) -- 543
		return -- 544
	end -- 544
	local steps = clock:advance(frameDt) -- 547
	local i = 0 -- 548
	do -- 548
		i = 0 -- 549
		while i < steps do -- 549
			input:beginStep(i == 0) -- 550
			p:update(STEP, input) -- 551
			input:endStep() -- 552
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 552
				break -- 554
			end -- 554
			i = i + 1 -- 549
		end -- 549
	end -- 549
	if p.wantRoom ~= "" then -- 549
		local key = p.wantRoom -- 559
		p.wantRoom = "" -- 560
		local idx = -1 -- 561
		local j = 0 -- 562
		do -- 562
			j = 0 -- 563
			while j < #CAMPAIGN_ROOMS do -- 563
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 563
					idx = j -- 565
				end -- 565
				j = j + 1 -- 563
			end -- 563
		end -- 563
		if idx >= 0 then -- 563
			current = idx -- 569
			play = nil -- 570
			ensurePlay() -- 571
		end -- 571
		return -- 573
	end -- 573
	drawCampaign(p) -- 575
end -- 575
function goalLabel(goal) -- 578
	if goal == "dock_cart" then -- 578
		return "推车入窝并抬闩" -- 580
	end -- 580
	if goal == "raise_latch" then -- 580
		return "抬闩开侧门" -- 583
	end -- 583
	return "到段出口" -- 585
end -- 585
function drawCampaign(p) -- 588
	if campaignDraw == nil then -- 588
		return -- 590
	end -- 590
	local w = viewW -- 592
	local h = viewH -- 593
	p:draw(campaignDraw, w, h) -- 594
	local room = CAMPAIGN_ROOMS[current + 1] -- 595
	local c = room.campaign -- 596
	local r = run -- 597
	local line = room.name -- 598
	if c ~= nil then -- 598
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 600
	end -- 600
	if p.paused then -- 600
		line = line .. "  · 已暂停 Esc 继续" -- 604
	end -- 604
	local trial = r and r.trial -- 606
	if trial ~= nil and r ~= nil then -- 606
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 608
		if p.paused then -- 608
			line = line .. " · 暂停" -- 609
		elseif trial.lost then -- 609
			line = line .. " · 护送失败" -- 610
		elseif r.finished then -- 610
			line = line .. " · 护送完成" -- 611
		elseif #trial.offers > 0 then -- 611
			line = line .. " · 选择本段本领" -- 612
		elseif c ~= nil then -- 612
			line = line .. " · " .. goalLabel(c.goal) -- 613
		end -- 613
	end -- 613
	if campaignHud ~= nil then -- 613
		campaignHud.text = line -- 616
		campaignHud.position = Vec2(24, h - 14) -- 617
		campaignHud.visible = true -- 618
	end -- 618
	if campaignSub ~= nil then -- 618
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 621
		if r ~= nil then -- 621
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 623
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 624
		end -- 624
		if p.flash ~= "" then -- 624
			sub = (sub .. " · ") .. p.flash -- 630
		end -- 630
		if trial ~= nil and r ~= nil then -- 630
			if trial.lost or r.finished then -- 630
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 633
			elseif p.paused then -- 633
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 634
			elseif #trial.offers > 0 then -- 634
				sub = table.concat( -- 635
					__TS__ArrayMap( -- 635
						trial.offers, -- 635
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 635
					), -- 635
					"　" -- 635
				) -- 635
			else -- 635
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 636
			end -- 636
		end -- 636
		campaignSub.text = sub -- 638
		campaignSub.position = Vec2(24, h - 44) -- 639
		campaignSub.visible = true -- 640
	end -- 640
end -- 640
function tickFrontend(frameDt) -- 644
	if fe == nil or input == nil then -- 644
		return -- 646
	end -- 646
	if fe.screen ~= "play" then -- 646
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 651
		input:consumeEdges() -- 652
		if act.type == "trial" then -- 652
			startTrial() -- 654
		elseif act.type == "start" then -- 654
			local mp = profile.museumPhase -- 657
			local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 658
			enterPlayRoom( -- 659
				inMuseum and roomIndexByKey("museum") or 0, -- 659
				"official", -- 659
				true -- 659
			) -- 659
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 659
			enterPlayRoom(act.roomIndex, "chapter") -- 661
		elseif act.type == "openChapters" then -- 661
			fe.menus:openChapters() -- 663
			fe.screen = "chapters" -- 664
		elseif act.type == "openControls" then -- 664
			fe.menus:resetInput() -- 666
			fe.screen = "controls" -- 667
		elseif act.type == "backTitle" then -- 667
			fe.menus:resetInput() -- 669
			fe.screen = "title" -- 670
		elseif act.type == "backPause" then -- 670
			fe.menus:resetInput() -- 672
			fe.screen = "play" -- 673
		end -- 673
		return -- 675
	end -- 675
	if play == nil then -- 675
		ensurePlay() -- 680
	end -- 680
	if play == nil then -- 680
		return -- 683
	end -- 683
	local p = play -- 685
	if input.retry.pressed then -- 685
		input:consumeEdges() -- 688
		ensurePlay({checkpoint = p.checkpoint}) -- 690
		return -- 691
	end -- 691
	p.aimX = input.mx -- 694
	p.aimY = input.my -- 695
	if not p.paused and input.pause.pressed then -- 695
		p.paused = true -- 698
		p.aimHold = 0 -- 699
		p.bottleAimX = -1 -- 700
		fe.menus:openPause() -- 701
		input:consumeEdges() -- 702
	end -- 702
	if p.paused then -- 702
		clock:reset() -- 707
		local pauseAct = fe:renderPlay( -- 708
			frameDt, -- 708
			p, -- 708
			input, -- 708
			viewW, -- 708
			viewH -- 708
		) -- 708
		input:consumeEdges() -- 709
		if pauseAct.type == "resume" then -- 709
			p.paused = false -- 711
		elseif pauseAct.type == "retry" then -- 711
			ensurePlay({checkpoint = p.checkpoint}) -- 713
		elseif pauseAct.type == "openChapters" then -- 713
			fe.menus:openChapters(current) -- 715
			fe.screen = "chapters" -- 716
		elseif pauseAct.type == "toTitle" then -- 716
			fe.menus:resetInput() -- 718
			fe.screen = "title" -- 719
		end -- 719
		return -- 721
	end -- 721
	local steps = clock:advance(frameDt) -- 724
	local i = 0 -- 725
	do -- 725
		i = 0 -- 726
		while i < steps do -- 726
			input:beginStep(i == 0) -- 727
			p:update(STEP, input) -- 728
			input:endStep() -- 729
			if p.wantRoom ~= "" then -- 729
				break -- 731
			end -- 731
			i = i + 1 -- 726
		end -- 726
	end -- 726
	if p.wantRoom ~= "" then -- 726
		local key = p.wantRoom -- 737
		p.wantRoom = "" -- 738
		local idx = -1 -- 739
		local j = 0 -- 740
		do -- 740
			j = 0 -- 741
			while j < #ROOMS do -- 741
				if ROOMS[j + 1].key == key then -- 741
					idx = j -- 743
				end -- 743
				j = j + 1 -- 741
			end -- 741
		end -- 741
		if idx >= 0 then -- 741
			flushProfile() -- 750
			local leaving = p:drainEvents() -- 751
			if p.restartStory then -- 751
				storyRun = createRun(20261124, storyRun == nil and "official" or storyRun.source, profile) -- 754
			end -- 754
			current = idx -- 756
			ensurePlay() -- 757
			local fresh = play -- 758
			if fresh ~= nil then -- 758
				fresh:adoptEvents(leaving) -- 760
			end -- 760
			clock:reset() -- 762
			dirty = true -- 763
		end -- 763
		return -- 765
	end -- 765
	flushProfile() -- 769
	fe:renderPlay( -- 770
		frameDt, -- 770
		p, -- 770
		input, -- 770
		viewW, -- 770
		viewH -- 770
	) -- 770
end -- 770
function redrawGraybox() -- 774
	if draw == nil then -- 774
		return -- 776
	end -- 776
	local w = viewW -- 778
	local h = viewH -- 779
	local room = ROOMS[current + 1] -- 780
	draw:clear() -- 782
	draw:drawRect( -- 783
		Rect(0, h - TOP_H, w, TOP_H), -- 783
		C_BG -- 783
	) -- 783
	draw:drawRect( -- 784
		Rect(0, 0, w, BOTTOM_H), -- 784
		C_BG -- 784
	) -- 784
	draw:drawSegment( -- 785
		Vec2(0, h - TOP_H), -- 785
		Vec2(w, h - TOP_H), -- 785
		1, -- 785
		Color(52, 54, 54, 255) -- 785
	) -- 785
	draw:drawSegment( -- 786
		Vec2(0, BOTTOM_H), -- 786
		Vec2(w, BOTTOM_H), -- 786
		1, -- 786
		Color(52, 54, 54, 255) -- 786
	) -- 786
	local v = computeView(room, w, h) -- 788
	renderWorld( -- 789
		draw, -- 789
		room, -- 789
		v, -- 789
		w, -- 789
		h -- 789
	) -- 789
	local roomTop = v.groundPx + room.height * v.scale -- 791
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 792
	place( -- 794
		titleLabel, -- 794
		48, -- 794
		h - 40, -- 794
		0, -- 794
		1 -- 794
	) -- 794
	place( -- 795
		roomLabel, -- 795
		48, -- 795
		h - 96, -- 795
		0, -- 795
		1 -- 795
	) -- 795
	place( -- 796
		captionLabel, -- 796
		48, -- 796
		h - 140, -- 796
		0, -- 796
		1 -- 796
	) -- 796
	place( -- 798
		switchLabel, -- 798
		48, -- 798
		40, -- 798
		0, -- 798
		0 -- 798
	) -- 798
	place( -- 799
		hintLabel, -- 799
		48, -- 799
		84, -- 799
		0, -- 799
		0 -- 799
	) -- 799
	place( -- 800
		rulerLabel, -- 800
		w - 216, -- 800
		roomTop + 36 + v.scale * 0.5 - 14, -- 800
		1, -- 800
		0 -- 800
	) -- 800
	place( -- 801
		standLabel, -- 801
		48, -- 801
		roomTop + 40, -- 801
		0, -- 801
		0 -- 801
	) -- 801
	place( -- 802
		cartLabel, -- 802
		48, -- 802
		roomTop + 92, -- 802
		0, -- 802
		0 -- 802
	) -- 802
	if roomLabel ~= nil then -- 802
		roomLabel.text = room.name -- 805
	end -- 805
	if captionLabel ~= nil then -- 805
		captionLabel.text = room.caption -- 808
	end -- 808
	if hintLabel ~= nil then -- 808
		local hintIdx = math.min(current, #HINTS - 1) -- 811
		local lines = HINTS[hintIdx + 1] -- 812
		local merged = lines[1] -- 813
		do -- 813
			local i = 1 -- 814
			while i < #lines do -- 814
				merged = (merged .. "    ") .. lines[i + 1] -- 815
				i = i + 1 -- 814
			end -- 814
		end -- 814
		hintLabel.text = merged -- 817
	end -- 817
	local specs = collectLabels(room, v, w) -- 820
	local body = {} -- 821
	local small = {} -- 822
	do -- 822
		local i = 0 -- 823
		while i < #specs do -- 823
			local s = specs[i + 1] -- 824
			if s.size >= 24 then -- 824
				body[#body + 1] = s -- 826
			else -- 826
				small[#small + 1] = s -- 828
			end -- 828
			i = i + 1 -- 823
		end -- 823
	end -- 823
	applyPool(body, poolBody) -- 831
	applyPool(small, poolSmall) -- 832
	if LAYOUT_AUDIT then -- 832
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 835
	end -- 835
end -- 835
function applyPool(specs, pool) -- 839
	do -- 839
		local i = 0 -- 840
		while i < #pool do -- 840
			local lb = pool[i + 1] -- 841
			if i < #specs then -- 841
				local s = specs[i + 1] -- 843
				lb.text = s.text -- 844
				lb.position = Vec2(s.x, s.y) -- 845
				lb.anchor = Vec2(s.ax, s.ay) -- 846
				lb.color = s.color -- 847
				lb.visible = true -- 848
			else -- 848
				lb.visible = false -- 850
			end -- 850
			i = i + 1 -- 840
		end -- 840
	end -- 840
end -- 840
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
			enterPlayRoom(0, "official", true) -- 260
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