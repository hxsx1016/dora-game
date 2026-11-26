-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local getReleaseConfig, isReleaseBuild, toggleFullscreen, quitGame, place, setMode, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, pickByIndex, applySize, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock -- 1
local ____Dora = require("Dora") -- 8
local App = ____Dora.App -- 8
local Color = ____Dora.Color -- 8
local DrawNode = ____Dora.DrawNode -- 8
local Keyboard = ____Dora.Keyboard -- 8
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
function getReleaseConfig() -- 79
	local ____opt_0 = _G.package -- 79
	local reg = ____opt_0 and ____opt_0.loaded -- 80
	local ____temp_2 -- 81
	if reg ~= nil then -- 81
		____temp_2 = reg["watch.release"] -- 81
	else -- 81
		____temp_2 = nil -- 81
	end -- 81
	local cfg = ____temp_2 -- 81
	if cfg ~= nil and type(cfg) == "table" then -- 81
		return cfg -- 83
	end -- 83
	return nil -- 85
end -- 85
function isReleaseBuild() -- 88
	local ____opt_3 = getReleaseConfig() -- 88
	return (____opt_3 and ____opt_3.isRelease) == true -- 89
end -- 89
function toggleFullscreen() -- 92
	local plat = App.platform -- 93
	if plat ~= "Windows" and plat ~= "macOS" and plat ~= "Linux" then -- 93
		return false -- 95
	end -- 95
	local next = not App.fullScreen -- 97
	App.fullScreen = next -- 98
	return next -- 99
end -- 99
function quitGame() -- 102
	flushProfile() -- 103
	if fe ~= nil then -- 103
		fe.audio:stopRoomTransient() -- 105
	end -- 105
	App:shutdown() -- 107
end -- 107
function place(lb, x, y, ax, ay) -- 125
	if lb == nil then -- 125
		return -- 127
	end -- 127
	lb.position = Vec2(x, y) -- 129
	lb.anchor = Vec2(ax, ay) -- 130
	lb.visible = true -- 131
end -- 131
function setMode(nextMode) -- 351
	mode = nextMode -- 352
	if grayboxLayer ~= nil then -- 352
		grayboxLayer.visible = mode == 0 -- 354
	end -- 354
	if fe ~= nil then -- 354
		fe:setVisible(mode == 1) -- 357
	end -- 357
	if campaignLayer ~= nil then -- 357
		campaignLayer.visible = mode == 2 -- 360
	end -- 360
	dirty = true -- 362
	clock:reset() -- 363
end -- 363
function flushProfile() -- 370
	local cur = play -- 371
	if cur ~= nil and cur.archiveDirty then -- 371
		cur.archiveDirty = false -- 373
		markProfilePending(profile) -- 374
	end -- 374
	local ok = flushSaveProfile() -- 376
	if not ok and cur ~= nil then -- 376
		cur.archiveDirty = true -- 378
	end -- 378
	return ok -- 380
end -- 380
function officialStartIndex() -- 384
	local mp = profile.museumPhase -- 385
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 386
	return inMuseum and roomIndexByKey("museum") or 0 -- 387
end -- 387
function roomIndexByKey(key) -- 390
	local i = 0 -- 391
	do -- 391
		i = 0 -- 392
		while i < #ROOMS do -- 392
			if ROOMS[i + 1].key == key then -- 392
				return i -- 394
			end -- 394
			i = i + 1 -- 392
		end -- 392
	end -- 392
	return 0 -- 397
end -- 397
function enterPlayRoom(idx, source, fresh) -- 400
	if source == nil then -- 400
		source = "debug" -- 400
	end -- 400
	if fresh == nil then -- 400
		fresh = false -- 400
	end -- 400
	current = idx -- 401
	setMode(1) -- 402
	if fe ~= nil then -- 402
		fe.screen = "play" -- 404
	end -- 404
	play = nil -- 406
	if fresh or storyRun == nil then -- 406
		storyRun = createRun(20261124, source, profile) -- 409
	else -- 409
		storyRun.source = source -- 411
	end -- 411
	ensurePlay() -- 413
	local firstPlay = play -- 415
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 415
		firstPlay.phase = "prologue-wake" -- 417
	end -- 417
	flushProfile() -- 419
end -- 419
function pickByIndex(idx, source) -- 422
	if source == nil then -- 422
		source = "debug" -- 422
	end -- 422
	if mode == 2 then -- 422
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 422
			return -- 425
		end -- 425
		current = idx -- 427
		play = nil -- 428
		clock:reset() -- 429
		ensurePlay() -- 430
		return -- 431
	end -- 431
	if idx < 0 or idx >= #ROOMS then -- 431
		return -- 434
	end -- 434
	flushProfile() -- 436
	if storyRun ~= nil then -- 436
		storyRun.source = source -- 438
	end -- 438
	current = idx -- 440
	dirty = true -- 441
	play = nil -- 442
	clock:reset() -- 443
	if mode == 1 then -- 443
		if fe ~= nil then -- 443
			fe.screen = "play" -- 446
		end -- 446
		ensurePlay() -- 448
	end -- 448
end -- 448
function applySize() -- 452
	if root == nil then -- 452
		return -- 454
	end -- 454
	root.size = Size(viewW, viewH) -- 456
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 457
end -- 457
function tick(frameDt) -- 460
	local w = View.size.width -- 461
	local h = View.size.height -- 462
	if w ~= viewW or h ~= viewH then -- 462
		viewW = w -- 464
		viewH = h -- 465
		applySize() -- 466
		dirty = true -- 467
	end -- 467
	if input == nil then -- 467
		return -- 470
	end -- 470
	input:update() -- 472
	if mode == 2 and (run and run.trial) ~= nil then -- 472
		tickCampaign(frameDt) -- 474
		return -- 475
	end -- 475
	if isReleaseBuild() then -- 475
		input.toggleView.pressed = false -- 479
		input.pickRoom = 0 -- 480
		input.tab.pressed = false -- 481
	else -- 481
		if input.toggleView.pressed then -- 481
			input.toggleView.pressed = false -- 485
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 486
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 486
				ensurePlay() -- 488
			end -- 488
		end -- 488
		if input.pickRoom ~= 0 then -- 488
			local idx = input.pickRoom - 1 -- 494
			input.pickRoom = 0 -- 495
			pickByIndex(idx) -- 496
		elseif input.tab.pressed then -- 496
			input.tab.pressed = false -- 498
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 498
				pickByIndex((current + 1) % #ROOMS) -- 500
			end -- 500
		end -- 500
	end -- 500
	if mode == 2 then -- 500
		tickCampaign(frameDt) -- 506
		return -- 507
	end -- 507
	if mode == 1 then -- 507
		tickFrontend(frameDt) -- 510
		return -- 511
	end -- 511
	if dirty then -- 511
		redrawGraybox() -- 514
		dirty = false -- 515
	end -- 515
end -- 515
function registerPlay() -- 520
	local reg = _G.package.loaded -- 521
	reg["watch.play"] = play -- 522
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 523
	reg["watch.room"] = rooms[current + 1].key -- 524
end -- 524
function ensurePlay(resume) -- 528
	if mode == 2 then -- 528
		if run == nil then -- 528
			run = createRun() -- 531
		end -- 531
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 533
	else -- 533
		if storyRun == nil then -- 533
			storyRun = createRun(20261124, "debug", profile) -- 538
		end -- 538
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 540
	end -- 540
	registerPlay() -- 542
	clock:reset() -- 543
	if fe ~= nil and mode == 1 then -- 543
		fe:bindPlay(play, viewW, viewH) -- 545
	end -- 545
end -- 545
function startTrial() -- 549
	current = 0 -- 550
	run = createTrial(App.rand) -- 551
	setMode(2) -- 552
	ensurePlay() -- 553
end -- 553
function tickCampaign(frameDt) -- 556
	if input == nil then -- 556
		return -- 558
	end -- 558
	if play == nil then -- 558
		ensurePlay() -- 561
	end -- 561
	if play == nil then -- 561
		return -- 564
	end -- 564
	local p = play -- 566
	p.aimX = input.mx -- 567
	p.aimY = input.my -- 568
	local trial = run and run.trial -- 570
	if trial ~= nil then -- 570
		local ended = trial.lost or (run and run.finished) == true -- 572
		local pick = input.pickRoom -- 573
		input.pickRoom = 0 -- 574
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 574
			input:consumeEdges() -- 576
			current = 0 -- 577
			play = nil -- 578
			run = nil -- 579
			setMode(1) -- 580
			if fe ~= nil then -- 580
				fe.screen = "title" -- 582
				fe.menus:resetInput() -- 583
			end -- 583
			return -- 585
		end -- 585
		if ended or p.paused and input.retry.pressed then -- 585
			local restart = input.retry.pressed -- 588
			input:consumeEdges() -- 589
			if restart then -- 589
				startTrial() -- 590
			else -- 590
				drawCampaign(p) -- 591
			end -- 591
			return -- 592
		end -- 592
		input.retry.pressed = false -- 594
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 594
			if pick > 0 then -- 594
				p:chooseTalent(pick - 1) -- 596
			end -- 596
			input:consumeEdges() -- 597
			clock:reset() -- 598
			drawCampaign(p) -- 599
			return -- 600
		end -- 600
	end -- 600
	if input.retry.pressed then -- 600
		input.retry.pressed = false -- 605
		input:consumeEdges() -- 606
		play = nil -- 608
		ensurePlay() -- 609
		return -- 610
	end -- 610
	if input.pause.pressed then -- 610
		input.pause.pressed = false -- 613
		p.paused = not p.paused -- 614
		clock:reset() -- 615
		input:consumeEdges() -- 616
	end -- 616
	if p.paused then -- 616
		drawCampaign(p) -- 619
		return -- 620
	end -- 620
	local steps = clock:advance(frameDt) -- 623
	local i = 0 -- 624
	do -- 624
		i = 0 -- 625
		while i < steps do -- 625
			input:beginStep(i == 0) -- 626
			p:update(STEP, input) -- 627
			input:endStep() -- 628
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 628
				break -- 630
			end -- 630
			i = i + 1 -- 625
		end -- 625
	end -- 625
	if p.wantRoom ~= "" then -- 625
		local key = p.wantRoom -- 635
		p.wantRoom = "" -- 636
		local idx = -1 -- 637
		local j = 0 -- 638
		do -- 638
			j = 0 -- 639
			while j < #CAMPAIGN_ROOMS do -- 639
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 639
					idx = j -- 641
				end -- 641
				j = j + 1 -- 639
			end -- 639
		end -- 639
		if idx >= 0 then -- 639
			current = idx -- 645
			play = nil -- 646
			ensurePlay() -- 647
		end -- 647
		return -- 649
	end -- 649
	drawCampaign(p) -- 651
end -- 651
function goalLabel(goal) -- 654
	if goal == "dock_cart" then -- 654
		return "推车入窝并抬闩" -- 656
	end -- 656
	if goal == "raise_latch" then -- 656
		return "抬闩开侧门" -- 659
	end -- 659
	return "到段出口" -- 661
end -- 661
function drawCampaign(p) -- 664
	if campaignDraw == nil then -- 664
		return -- 666
	end -- 666
	local w = viewW -- 668
	local h = viewH -- 669
	p:draw(campaignDraw, w, h) -- 670
	local room = CAMPAIGN_ROOMS[current + 1] -- 671
	local c = room.campaign -- 672
	local r = run -- 673
	local line = room.name -- 674
	if c ~= nil then -- 674
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 676
	end -- 676
	if p.paused then -- 676
		line = line .. "  · 已暂停 Esc 继续" -- 680
	end -- 680
	local trial = r and r.trial -- 682
	if trial ~= nil and r ~= nil then -- 682
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 684
		if p.paused then -- 684
			line = line .. " · 暂停" -- 685
		elseif trial.lost then -- 685
			line = line .. " · 护送失败" -- 686
		elseif r.finished then -- 686
			line = line .. " · 护送完成" -- 687
		elseif #trial.offers > 0 then -- 687
			line = line .. " · 选择本段本领" -- 688
		elseif c ~= nil then -- 688
			line = line .. " · " .. goalLabel(c.goal) -- 689
		end -- 689
	end -- 689
	if campaignHud ~= nil then -- 689
		campaignHud.text = line -- 692
		campaignHud.position = Vec2(24, h - 14) -- 693
		campaignHud.visible = true -- 694
	end -- 694
	if campaignSub ~= nil then -- 694
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 697
		if r ~= nil then -- 697
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 699
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 700
		end -- 700
		if p.flash ~= "" then -- 700
			sub = (sub .. " · ") .. p.flash -- 706
		end -- 706
		if trial ~= nil and r ~= nil then -- 706
			if trial.lost or r.finished then -- 706
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 709
			elseif p.paused then -- 709
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 710
			elseif #trial.offers > 0 then -- 710
				sub = table.concat( -- 711
					__TS__ArrayMap( -- 711
						trial.offers, -- 711
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 711
					), -- 711
					"　" -- 711
				) -- 711
			else -- 711
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 712
			end -- 712
		end -- 712
		campaignSub.text = sub -- 714
		campaignSub.position = Vec2(24, h - 44) -- 715
		campaignSub.visible = true -- 716
	end -- 716
end -- 716
function tickFrontend(frameDt) -- 720
	if fe == nil or input == nil then -- 720
		return -- 722
	end -- 722
	if fe.screen ~= "play" then -- 722
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 727
		input:consumeEdges() -- 728
		if act.type == "trial" then -- 728
			startTrial() -- 730
		elseif act.type == "start" then -- 730
			enterPlayRoom( -- 733
				officialStartIndex(), -- 733
				"official", -- 733
				true -- 733
			) -- 733
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 733
			enterPlayRoom(act.roomIndex, "chapter") -- 735
		elseif act.type == "openChapters" then -- 735
			fe.menus:openChapters() -- 737
			fe.screen = "chapters" -- 738
		elseif act.type == "openControls" then -- 738
			fe.menus:resetInput() -- 740
			fe.screen = "controls" -- 741
		elseif act.type == "backTitle" then -- 741
			fe.menus:resetInput() -- 743
			fe.screen = "title" -- 744
		elseif act.type == "backPause" then -- 744
			fe.menus:resetInput() -- 746
			fe.screen = "play" -- 747
		elseif act.type == "quit" then -- 747
			quitGame() -- 749
		end -- 749
		return -- 751
	end -- 751
	if play == nil then -- 751
		ensurePlay() -- 756
	end -- 756
	if play == nil then -- 756
		return -- 759
	end -- 759
	local p = play -- 761
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 763
	if input.retry.pressed and not inTowerEnding then -- 763
		input:consumeEdges() -- 765
		ensurePlay({checkpoint = p.checkpoint}) -- 767
		return -- 768
	end -- 768
	p.aimX = input.mx -- 771
	p.aimY = input.my -- 772
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 772
		p:closeCraftBench() -- 775
		input:consumeEdges() -- 776
		return -- 777
	end -- 777
	if not p.paused and input.pause.pressed then -- 777
		p.paused = true -- 780
		p.aimHold = 0 -- 781
		p.bottleAimX = -1 -- 782
		fe.menus:openPause() -- 783
		input:consumeEdges() -- 784
	end -- 784
	if p.paused then -- 784
		clock:reset() -- 789
		local pauseAct = fe:renderPlay( -- 790
			frameDt, -- 790
			p, -- 790
			input, -- 790
			viewW, -- 790
			viewH -- 790
		) -- 790
		input:consumeEdges() -- 791
		if pauseAct.type == "resume" then -- 791
			p.paused = false -- 793
		elseif pauseAct.type == "retry" then -- 793
			ensurePlay({checkpoint = p.checkpoint}) -- 795
		elseif pauseAct.type == "openChapters" then -- 795
			fe.menus:openChapters(current) -- 797
			fe.screen = "chapters" -- 798
		elseif pauseAct.type == "toggleFullscreen" then -- 798
			toggleFullscreen() -- 800
		elseif pauseAct.type == "quit" then -- 800
			quitGame() -- 802
		elseif pauseAct.type == "toTitle" then -- 802
			fe.menus:resetInput() -- 804
			fe.screen = "title" -- 805
		end -- 805
		return -- 807
	end -- 807
	local steps = clock:advance(frameDt) -- 810
	local i = 0 -- 811
	do -- 811
		i = 0 -- 812
		while i < steps do -- 812
			input:beginStep(i == 0) -- 813
			p:update(STEP, input) -- 814
			input:endStep() -- 815
			if p.wantRoom ~= "" then -- 815
				break -- 817
			end -- 817
			i = i + 1 -- 812
		end -- 812
	end -- 812
	if p.wantRoom ~= "" then -- 812
		local key = p.wantRoom -- 823
		p.wantRoom = "" -- 824
		local idx = -1 -- 825
		local j = 0 -- 826
		do -- 826
			j = 0 -- 827
			while j < #ROOMS do -- 827
				if ROOMS[j + 1].key == key then -- 827
					idx = j -- 829
				end -- 829
				j = j + 1 -- 827
			end -- 827
		end -- 827
		if idx >= 0 then -- 827
			flushProfile() -- 836
			local leaving = p:drainEvents() -- 837
			if p.restartStory then -- 837
				storyRun = createRun(20261124, storyRun == nil and "official" or storyRun.source, profile) -- 840
			end -- 840
			current = idx -- 842
			ensurePlay() -- 843
			local fresh = play -- 844
			if fresh ~= nil then -- 844
				fresh:adoptEvents(leaving) -- 846
			end -- 846
			clock:reset() -- 848
			dirty = true -- 849
		end -- 849
		return -- 851
	end -- 851
	flushProfile() -- 855
	fe:renderPlay( -- 856
		frameDt, -- 856
		p, -- 856
		input, -- 856
		viewW, -- 856
		viewH -- 856
	) -- 856
end -- 856
function redrawGraybox() -- 860
	if draw == nil then -- 860
		return -- 862
	end -- 862
	local w = viewW -- 864
	local h = viewH -- 865
	local room = ROOMS[current + 1] -- 866
	draw:clear() -- 868
	draw:drawRect( -- 869
		Rect(0, h - TOP_H, w, TOP_H), -- 869
		C_BG -- 869
	) -- 869
	draw:drawRect( -- 870
		Rect(0, 0, w, BOTTOM_H), -- 870
		C_BG -- 870
	) -- 870
	draw:drawSegment( -- 871
		Vec2(0, h - TOP_H), -- 871
		Vec2(w, h - TOP_H), -- 871
		1, -- 871
		Color(52, 54, 54, 255) -- 871
	) -- 871
	draw:drawSegment( -- 872
		Vec2(0, BOTTOM_H), -- 872
		Vec2(w, BOTTOM_H), -- 872
		1, -- 872
		Color(52, 54, 54, 255) -- 872
	) -- 872
	local v = computeView(room, w, h) -- 874
	renderWorld( -- 875
		draw, -- 875
		room, -- 875
		v, -- 875
		w, -- 875
		h -- 875
	) -- 875
	local roomTop = v.groundPx + room.height * v.scale -- 877
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 878
	place( -- 880
		titleLabel, -- 880
		48, -- 880
		h - 40, -- 880
		0, -- 880
		1 -- 880
	) -- 880
	place( -- 881
		roomLabel, -- 881
		48, -- 881
		h - 96, -- 881
		0, -- 881
		1 -- 881
	) -- 881
	place( -- 882
		captionLabel, -- 882
		48, -- 882
		h - 140, -- 882
		0, -- 882
		1 -- 882
	) -- 882
	place( -- 884
		switchLabel, -- 884
		48, -- 884
		40, -- 884
		0, -- 884
		0 -- 884
	) -- 884
	place( -- 885
		hintLabel, -- 885
		48, -- 885
		84, -- 885
		0, -- 885
		0 -- 885
	) -- 885
	place( -- 886
		rulerLabel, -- 886
		w - 216, -- 886
		roomTop + 36 + v.scale * 0.5 - 14, -- 886
		1, -- 886
		0 -- 886
	) -- 886
	place( -- 887
		standLabel, -- 887
		48, -- 887
		roomTop + 40, -- 887
		0, -- 887
		0 -- 887
	) -- 887
	place( -- 888
		cartLabel, -- 888
		48, -- 888
		roomTop + 92, -- 888
		0, -- 888
		0 -- 888
	) -- 888
	if roomLabel ~= nil then -- 888
		roomLabel.text = room.name -- 891
	end -- 891
	if captionLabel ~= nil then -- 891
		captionLabel.text = room.caption -- 894
	end -- 894
	if hintLabel ~= nil then -- 894
		local hintIdx = math.min(current, #HINTS - 1) -- 897
		local lines = HINTS[hintIdx + 1] -- 898
		local merged = lines[1] -- 899
		do -- 899
			local i = 1 -- 900
			while i < #lines do -- 900
				merged = (merged .. "    ") .. lines[i + 1] -- 901
				i = i + 1 -- 900
			end -- 900
		end -- 900
		hintLabel.text = merged -- 903
	end -- 903
	local specs = collectLabels(room, v, w) -- 906
	local body = {} -- 907
	local small = {} -- 908
	do -- 908
		local i = 0 -- 909
		while i < #specs do -- 909
			local s = specs[i + 1] -- 910
			if s.size >= 24 then -- 910
				body[#body + 1] = s -- 912
			else -- 912
				small[#small + 1] = s -- 914
			end -- 914
			i = i + 1 -- 909
		end -- 909
	end -- 909
	applyPool(body, poolBody) -- 917
	applyPool(small, poolSmall) -- 918
	if LAYOUT_AUDIT then -- 918
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 921
	end -- 921
end -- 921
function applyPool(specs, pool) -- 925
	do -- 925
		local i = 0 -- 926
		while i < #pool do -- 926
			local lb = pool[i + 1] -- 927
			if i < #specs then -- 927
				local s = specs[i + 1] -- 929
				lb.text = s.text -- 930
				lb.position = Vec2(s.x, s.y) -- 931
				lb.anchor = Vec2(s.ax, s.ay) -- 932
				lb.color = s.color -- 933
				lb.visible = true -- 934
			else -- 934
				lb.visible = false -- 936
			end -- 936
			i = i + 1 -- 926
		end -- 926
	end -- 926
end -- 926
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
local function makeGrayboxLabel(text, size, color) -- 110
	if grayboxLayer == nil then -- 110
		return nil -- 112
	end -- 112
	local lb = Label(FONT, size) -- 114
	if lb == nil then -- 114
		return nil -- 116
	end -- 116
	lb.text = text -- 118
	lb.color = color -- 119
	lb:addTo(grayboxLayer) -- 120
	lb.visible = true -- 121
	return lb -- 122
end -- 110
function ____exports.start(parent, initialMode, startScreen) -- 134
	if initialMode == nil then -- 134
		initialMode = 1 -- 134
	end -- 134
	if startScreen == nil then -- 134
		startScreen = "title" -- 134
	end -- 134
	root = parent -- 135
	mode = initialMode -- 136
	grayboxLayer = Node() -- 139
	grayboxLayer.order = 2 -- 140
	grayboxLayer:addTo(parent) -- 141
	draw = DrawNode() -- 143
	draw:addTo(grayboxLayer) -- 144
	campaignLayer = Node() -- 147
	campaignLayer.order = 3 -- 148
	campaignLayer:addTo(parent) -- 149
	campaignDraw = DrawNode() -- 150
	campaignDraw:addTo(campaignLayer) -- 151
	campaignHud = Label(FONT, 24) -- 152
	if campaignHud ~= nil then -- 152
		campaignHud.color = C_TEXT -- 154
		campaignHud.anchor = Vec2(0, 1) -- 155
		campaignHud:addTo(campaignLayer) -- 156
		campaignHud.visible = true -- 157
	end -- 157
	campaignSub = Label(FONT, 20) -- 159
	if campaignSub ~= nil then -- 159
		campaignSub.color = C_ACCENT -- 161
		campaignSub.anchor = Vec2(0, 1) -- 162
		campaignSub:addTo(campaignLayer) -- 163
		campaignSub.visible = true -- 164
	end -- 164
	campaignLayer.visible = mode == 2 -- 166
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 168
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 169
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 170
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 171
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 172
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 173
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 174
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 175
	do -- 175
		local i = 0 -- 177
		while i < POOL_BODY do -- 177
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 178
			if lb ~= nil then -- 178
				poolBody[#poolBody + 1] = lb -- 180
			end -- 180
			i = i + 1 -- 177
		end -- 177
	end -- 177
	do -- 177
		local i = 0 -- 183
		while i < POOL_SMALL do -- 183
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 184
			if lb ~= nil then -- 184
				poolSmall[#poolSmall + 1] = lb -- 186
			end -- 186
			i = i + 1 -- 183
		end -- 183
	end -- 183
	if mode == 1 then -- 183
		local loaded = loadSave() -- 193
		profile = loaded.state -- 194
		profileStatus = loaded.status -- 195
		profileDetail = loaded.detail -- 196
	end -- 196
	fe = __TS__New(WatchFrontend, parent) -- 198
	fe.screen = startScreen -- 199
	grayboxLayer.visible = mode == 0 -- 200
	fe:setVisible(mode == 1) -- 201
	if campaignLayer ~= nil then -- 201
		campaignLayer.visible = mode == 2 -- 203
	end -- 203
	input = __TS__New(Input) -- 206
	parent:gslot( -- 209
		"AppEvent", -- 209
		function(eventType) -- 209
			if eventType == "Quit" or eventType == "Shutdown" or eventType == "WillEnterBackground" then -- 209
				flushProfile() -- 211
			end -- 211
		end -- 209
	) -- 209
	parent:onKeyDown(function(key) -- 216
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 216
			toggleFullscreen() -- 219
			return -- 220
		end -- 220
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or play ~= nil and play.paused) then -- 220
			fe.menus:onKeyEvent(key) -- 223
		end -- 223
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" or mode == 2) then -- 223
			if key == "E" then -- 223
				input.interact.pressed = true -- 227
			elseif key == "Space" then -- 227
				input.jump.pressed = true -- 229
			elseif key == "Escape" then -- 229
				input.pause.pressed = true -- 231
			elseif key == "R" then -- 231
				input.retry.pressed = true -- 233
			end -- 233
		end -- 233
		if mode == 2 and (run and run.trial) ~= nil then -- 233
			return -- 236
		end -- 236
		if isReleaseBuild() then -- 236
			return -- 237
		end -- 237
		if key == "F1" then -- 237
			if mode == 2 then -- 237
				current = 0 -- 240
				play = nil -- 241
				ensurePlay() -- 242
			else -- 242
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 244
			end -- 244
		elseif key == "F2" then -- 244
			setMode(0) -- 247
		elseif key == "1" then -- 247
			pickByIndex(0) -- 249
		elseif key == "2" then -- 249
			pickByIndex(1) -- 251
		elseif key == "3" then -- 251
			pickByIndex(2) -- 253
		elseif key == "4" then -- 253
			pickByIndex(3) -- 255
		elseif key == "5" then -- 255
			pickByIndex(4) -- 257
		elseif key == "6" then -- 257
			pickByIndex(5) -- 259
		elseif key == "7" then -- 259
			pickByIndex(6) -- 261
		elseif key == "8" then -- 261
			pickByIndex(7) -- 263
		end -- 263
	end) -- 216
	viewW = View.size.width -- 267
	viewH = View.size.height -- 268
	applySize() -- 269
	local reg = _G.package.loaded -- 272
	reg["watch.input"] = input -- 273
	reg["watch.fe"] = { -- 274
		setScreen = function(sc) -- 275
			if fe == nil then -- 275
				return -- 277
			end -- 277
			setMode(1) -- 279
			fe.screen = sc -- 280
			if sc == "chapters" then -- 280
				fe.menus:openChapters() -- 282
			else -- 282
				fe.menus:resetInput() -- 284
			end -- 284
			if sc == "play" then -- 284
				ensurePlay() -- 287
			end -- 287
		end, -- 275
		jumpRoom = function(keyOrIdx) -- 290
			local idx = -1 -- 291
			if type(keyOrIdx) == "number" then -- 291
				idx = keyOrIdx -- 293
			else -- 293
				local k = 0 -- 295
				do -- 295
					k = 0 -- 296
					while k < #ROOMS do -- 296
						if ROOMS[k + 1].key == keyOrIdx then -- 296
							idx = k -- 298
						end -- 298
						k = k + 1 -- 296
					end -- 296
				end -- 296
			end -- 296
			if idx >= 0 and idx < #ROOMS then -- 296
				enterPlayRoom(idx, "debug") -- 303
			end -- 303
		end, -- 290
		getPlay = function() return play end, -- 306
		getFrontend = function() return fe end, -- 307
		startStory = function() -- 309
			enterPlayRoom( -- 310
				officialStartIndex(), -- 310
				"official", -- 310
				true -- 310
			) -- 310
			return play -- 311
		end, -- 309
		previewChapter = function(idx) -- 314
			enterPlayRoom(idx, "chapter") -- 315
			return play -- 316
		end, -- 314
		getStoryRun = function() return storyRun end, -- 318
		getProfilePending = function() return profilePending() end, -- 319
		flushProfileNow = function() return flushProfile() end, -- 320
		getProfile = function() return profile end, -- 322
		getProfileStatus = function() return profileStatus end, -- 323
		getProfileDetail = function() return profileDetail end, -- 324
		useTestSave = function(name) -- 325
			setSaveFile(name) -- 326
			clearProfilePending() -- 327
			local loaded = loadSave() -- 328
			profile = loaded.state -- 329
			profileStatus = loaded.status -- 330
			profileDetail = loaded.detail -- 331
		end, -- 325
		saveNow = function() return saveSave(profile) end, -- 333
		getSaveFile = getSaveFile, -- 334
		isRelease = function() return isReleaseBuild() end, -- 335
		getReleaseVersion = function() -- 336
			local ____opt_7 = getReleaseConfig() -- 336
			return ____opt_7 and ____opt_7.version or "dev" -- 336
		end, -- 336
		toggleFullscreen = function() return toggleFullscreen() end, -- 337
		quitGame = function() return quitGame() end -- 338
	} -- 338
	if mode == 1 and startScreen == "play" then -- 338
		ensurePlay() -- 342
	end -- 342
	parent:schedule(function(frameDt) -- 345
		tick(frameDt) -- 346
		return false -- 347
	end) -- 345
end -- 134
return ____exports -- 134