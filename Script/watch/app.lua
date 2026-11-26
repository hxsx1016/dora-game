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
	flushProfile() -- 414
end -- 414
function pickByIndex(idx, source) -- 417
	if source == nil then -- 417
		source = "debug" -- 417
	end -- 417
	if mode == 2 then -- 417
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 417
			return -- 420
		end -- 420
		current = idx -- 422
		play = nil -- 423
		clock:reset() -- 424
		ensurePlay() -- 425
		return -- 426
	end -- 426
	if idx < 0 or idx >= #ROOMS then -- 426
		return -- 429
	end -- 429
	current = idx -- 431
	dirty = true -- 432
	play = nil -- 433
	clock:reset() -- 434
	if mode == 1 then -- 434
		if fe ~= nil then -- 434
			fe.screen = "play" -- 437
		end -- 437
		ensurePlay() -- 439
	end -- 439
end -- 439
function applySize() -- 443
	if root == nil then -- 443
		return -- 445
	end -- 445
	root.size = Size(viewW, viewH) -- 447
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 448
end -- 448
function tick(frameDt) -- 451
	local w = View.size.width -- 452
	local h = View.size.height -- 453
	if w ~= viewW or h ~= viewH then -- 453
		viewW = w -- 455
		viewH = h -- 456
		applySize() -- 457
		dirty = true -- 458
	end -- 458
	if input == nil then -- 458
		return -- 461
	end -- 461
	input:update() -- 463
	if mode == 2 and (run and run.trial) ~= nil then -- 463
		tickCampaign(frameDt) -- 465
		return -- 466
	end -- 466
	if isReleaseBuild() then -- 466
		input.toggleView.pressed = false -- 470
		input.pickRoom = 0 -- 471
		input.tab.pressed = false -- 472
	else -- 472
		if input.toggleView.pressed then -- 472
			input.toggleView.pressed = false -- 476
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 477
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 477
				ensurePlay() -- 479
			end -- 479
		end -- 479
		if input.pickRoom ~= 0 then -- 479
			local idx = input.pickRoom - 1 -- 485
			input.pickRoom = 0 -- 486
			pickByIndex(idx) -- 487
		elseif input.tab.pressed then -- 487
			input.tab.pressed = false -- 489
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 489
				pickByIndex((current + 1) % #ROOMS) -- 491
			end -- 491
		end -- 491
	end -- 491
	if mode == 2 then -- 491
		tickCampaign(frameDt) -- 497
		return -- 498
	end -- 498
	if mode == 1 then -- 498
		tickFrontend(frameDt) -- 501
		return -- 502
	end -- 502
	if dirty then -- 502
		redrawGraybox() -- 505
		dirty = false -- 506
	end -- 506
end -- 506
function registerPlay() -- 511
	local reg = _G.package.loaded -- 512
	reg["watch.play"] = play -- 513
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 514
	reg["watch.room"] = rooms[current + 1].key -- 515
end -- 515
function ensurePlay(resume) -- 519
	if mode == 2 then -- 519
		if run == nil then -- 519
			run = createRun() -- 522
		end -- 522
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 524
	else -- 524
		if storyRun == nil then -- 524
			storyRun = createRun(20261124, "debug", profile) -- 529
		end -- 529
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 531
	end -- 531
	registerPlay() -- 533
	clock:reset() -- 534
	if fe ~= nil and mode == 1 then -- 534
		fe:bindPlay(play, viewW, viewH) -- 536
	end -- 536
end -- 536
function startTrial() -- 540
	current = 0 -- 541
	run = createTrial(App.rand) -- 542
	setMode(2) -- 543
	ensurePlay() -- 544
end -- 544
function tickCampaign(frameDt) -- 547
	if input == nil then -- 547
		return -- 549
	end -- 549
	if play == nil then -- 549
		ensurePlay() -- 552
	end -- 552
	if play == nil then -- 552
		return -- 555
	end -- 555
	local p = play -- 557
	p.aimX = input.mx -- 558
	p.aimY = input.my -- 559
	local trial = run and run.trial -- 561
	if trial ~= nil then -- 561
		local ended = trial.lost or (run and run.finished) == true -- 563
		local pick = input.pickRoom -- 564
		input.pickRoom = 0 -- 565
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 565
			input:consumeEdges() -- 567
			current = 0 -- 568
			play = nil -- 569
			run = nil -- 570
			setMode(1) -- 571
			if fe ~= nil then -- 571
				fe.screen = "title" -- 573
				fe.menus:resetInput() -- 574
			end -- 574
			return -- 576
		end -- 576
		if ended or p.paused and input.retry.pressed then -- 576
			local restart = input.retry.pressed -- 579
			input:consumeEdges() -- 580
			if restart then -- 580
				startTrial() -- 581
			else -- 581
				drawCampaign(p) -- 582
			end -- 582
			return -- 583
		end -- 583
		input.retry.pressed = false -- 585
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 585
			if pick > 0 then -- 585
				p:chooseTalent(pick - 1) -- 587
			end -- 587
			input:consumeEdges() -- 588
			clock:reset() -- 589
			drawCampaign(p) -- 590
			return -- 591
		end -- 591
	end -- 591
	if input.retry.pressed then -- 591
		input.retry.pressed = false -- 596
		input:consumeEdges() -- 597
		play = nil -- 599
		ensurePlay() -- 600
		return -- 601
	end -- 601
	if input.pause.pressed then -- 601
		input.pause.pressed = false -- 604
		p.paused = not p.paused -- 605
		clock:reset() -- 606
		input:consumeEdges() -- 607
	end -- 607
	if p.paused then -- 607
		drawCampaign(p) -- 610
		return -- 611
	end -- 611
	local steps = clock:advance(frameDt) -- 614
	local i = 0 -- 615
	do -- 615
		i = 0 -- 616
		while i < steps do -- 616
			input:beginStep(i == 0) -- 617
			p:update(STEP, input) -- 618
			input:endStep() -- 619
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 619
				break -- 621
			end -- 621
			i = i + 1 -- 616
		end -- 616
	end -- 616
	if p.wantRoom ~= "" then -- 616
		local key = p.wantRoom -- 626
		p.wantRoom = "" -- 627
		local idx = -1 -- 628
		local j = 0 -- 629
		do -- 629
			j = 0 -- 630
			while j < #CAMPAIGN_ROOMS do -- 630
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 630
					idx = j -- 632
				end -- 632
				j = j + 1 -- 630
			end -- 630
		end -- 630
		if idx >= 0 then -- 630
			current = idx -- 636
			play = nil -- 637
			ensurePlay() -- 638
		end -- 638
		return -- 640
	end -- 640
	drawCampaign(p) -- 642
end -- 642
function goalLabel(goal) -- 645
	if goal == "dock_cart" then -- 645
		return "推车入窝并抬闩" -- 647
	end -- 647
	if goal == "raise_latch" then -- 647
		return "抬闩开侧门" -- 650
	end -- 650
	return "到段出口" -- 652
end -- 652
function drawCampaign(p) -- 655
	if campaignDraw == nil then -- 655
		return -- 657
	end -- 657
	local w = viewW -- 659
	local h = viewH -- 660
	p:draw(campaignDraw, w, h) -- 661
	local room = CAMPAIGN_ROOMS[current + 1] -- 662
	local c = room.campaign -- 663
	local r = run -- 664
	local line = room.name -- 665
	if c ~= nil then -- 665
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 667
	end -- 667
	if p.paused then -- 667
		line = line .. "  · 已暂停 Esc 继续" -- 671
	end -- 671
	local trial = r and r.trial -- 673
	if trial ~= nil and r ~= nil then -- 673
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 675
		if p.paused then -- 675
			line = line .. " · 暂停" -- 676
		elseif trial.lost then -- 676
			line = line .. " · 护送失败" -- 677
		elseif r.finished then -- 677
			line = line .. " · 护送完成" -- 678
		elseif #trial.offers > 0 then -- 678
			line = line .. " · 选择本段本领" -- 679
		elseif c ~= nil then -- 679
			line = line .. " · " .. goalLabel(c.goal) -- 680
		end -- 680
	end -- 680
	if campaignHud ~= nil then -- 680
		campaignHud.text = line -- 683
		campaignHud.position = Vec2(24, h - 14) -- 684
		campaignHud.visible = true -- 685
	end -- 685
	if campaignSub ~= nil then -- 685
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 688
		if r ~= nil then -- 688
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 690
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 691
		end -- 691
		if p.flash ~= "" then -- 691
			sub = (sub .. " · ") .. p.flash -- 697
		end -- 697
		if trial ~= nil and r ~= nil then -- 697
			if trial.lost or r.finished then -- 697
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 700
			elseif p.paused then -- 700
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 701
			elseif #trial.offers > 0 then -- 701
				sub = table.concat( -- 702
					__TS__ArrayMap( -- 702
						trial.offers, -- 702
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 702
					), -- 702
					"　" -- 702
				) -- 702
			else -- 702
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 703
			end -- 703
		end -- 703
		campaignSub.text = sub -- 705
		campaignSub.position = Vec2(24, h - 44) -- 706
		campaignSub.visible = true -- 707
	end -- 707
end -- 707
function tickFrontend(frameDt) -- 711
	if fe == nil or input == nil then -- 711
		return -- 713
	end -- 713
	if fe.screen ~= "play" then -- 713
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 718
		input:consumeEdges() -- 719
		if act.type == "trial" then -- 719
			startTrial() -- 721
		elseif act.type == "start" then -- 721
			enterPlayRoom( -- 724
				officialStartIndex(), -- 724
				"official", -- 724
				true -- 724
			) -- 724
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 724
			enterPlayRoom(act.roomIndex, "chapter") -- 726
		elseif act.type == "openChapters" then -- 726
			fe.menus:openChapters() -- 728
			fe.screen = "chapters" -- 729
		elseif act.type == "openControls" then -- 729
			fe.menus:resetInput() -- 731
			fe.screen = "controls" -- 732
		elseif act.type == "backTitle" then -- 732
			fe.menus:resetInput() -- 734
			fe.screen = "title" -- 735
		elseif act.type == "backPause" then -- 735
			fe.menus:resetInput() -- 737
			fe.screen = "play" -- 738
		elseif act.type == "quit" then -- 738
			quitGame() -- 740
		end -- 740
		return -- 742
	end -- 742
	if play == nil then -- 742
		ensurePlay() -- 747
	end -- 747
	if play == nil then -- 747
		return -- 750
	end -- 750
	local p = play -- 752
	if input.retry.pressed then -- 752
		input:consumeEdges() -- 755
		ensurePlay({checkpoint = p.checkpoint}) -- 757
		return -- 758
	end -- 758
	p.aimX = input.mx -- 761
	p.aimY = input.my -- 762
	if not p.paused and input.pause.pressed then -- 762
		p.paused = true -- 765
		p.aimHold = 0 -- 766
		p.bottleAimX = -1 -- 767
		fe.menus:openPause() -- 768
		input:consumeEdges() -- 769
	end -- 769
	if p.paused then -- 769
		clock:reset() -- 774
		local pauseAct = fe:renderPlay( -- 775
			frameDt, -- 775
			p, -- 775
			input, -- 775
			viewW, -- 775
			viewH -- 775
		) -- 775
		input:consumeEdges() -- 776
		if pauseAct.type == "resume" then -- 776
			p.paused = false -- 778
		elseif pauseAct.type == "retry" then -- 778
			ensurePlay({checkpoint = p.checkpoint}) -- 780
		elseif pauseAct.type == "openChapters" then -- 780
			fe.menus:openChapters(current) -- 782
			fe.screen = "chapters" -- 783
		elseif pauseAct.type == "toggleFullscreen" then -- 783
			toggleFullscreen() -- 785
		elseif pauseAct.type == "quit" then -- 785
			quitGame() -- 787
		elseif pauseAct.type == "toTitle" then -- 787
			fe.menus:resetInput() -- 789
			fe.screen = "title" -- 790
		end -- 790
		return -- 792
	end -- 792
	local steps = clock:advance(frameDt) -- 795
	local i = 0 -- 796
	do -- 796
		i = 0 -- 797
		while i < steps do -- 797
			input:beginStep(i == 0) -- 798
			p:update(STEP, input) -- 799
			input:endStep() -- 800
			if p.wantRoom ~= "" then -- 800
				break -- 802
			end -- 802
			i = i + 1 -- 797
		end -- 797
	end -- 797
	if p.wantRoom ~= "" then -- 797
		local key = p.wantRoom -- 808
		p.wantRoom = "" -- 809
		local idx = -1 -- 810
		local j = 0 -- 811
		do -- 811
			j = 0 -- 812
			while j < #ROOMS do -- 812
				if ROOMS[j + 1].key == key then -- 812
					idx = j -- 814
				end -- 814
				j = j + 1 -- 812
			end -- 812
		end -- 812
		if idx >= 0 then -- 812
			flushProfile() -- 821
			local leaving = p:drainEvents() -- 822
			if p.restartStory then -- 822
				storyRun = createRun(20261124, storyRun == nil and "official" or storyRun.source, profile) -- 825
			end -- 825
			current = idx -- 827
			ensurePlay() -- 828
			local fresh = play -- 829
			if fresh ~= nil then -- 829
				fresh:adoptEvents(leaving) -- 831
			end -- 831
			clock:reset() -- 833
			dirty = true -- 834
		end -- 834
		return -- 836
	end -- 836
	flushProfile() -- 840
	fe:renderPlay( -- 841
		frameDt, -- 841
		p, -- 841
		input, -- 841
		viewW, -- 841
		viewH -- 841
	) -- 841
end -- 841
function redrawGraybox() -- 845
	if draw == nil then -- 845
		return -- 847
	end -- 847
	local w = viewW -- 849
	local h = viewH -- 850
	local room = ROOMS[current + 1] -- 851
	draw:clear() -- 853
	draw:drawRect( -- 854
		Rect(0, h - TOP_H, w, TOP_H), -- 854
		C_BG -- 854
	) -- 854
	draw:drawRect( -- 855
		Rect(0, 0, w, BOTTOM_H), -- 855
		C_BG -- 855
	) -- 855
	draw:drawSegment( -- 856
		Vec2(0, h - TOP_H), -- 856
		Vec2(w, h - TOP_H), -- 856
		1, -- 856
		Color(52, 54, 54, 255) -- 856
	) -- 856
	draw:drawSegment( -- 857
		Vec2(0, BOTTOM_H), -- 857
		Vec2(w, BOTTOM_H), -- 857
		1, -- 857
		Color(52, 54, 54, 255) -- 857
	) -- 857
	local v = computeView(room, w, h) -- 859
	renderWorld( -- 860
		draw, -- 860
		room, -- 860
		v, -- 860
		w, -- 860
		h -- 860
	) -- 860
	local roomTop = v.groundPx + room.height * v.scale -- 862
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 863
	place( -- 865
		titleLabel, -- 865
		48, -- 865
		h - 40, -- 865
		0, -- 865
		1 -- 865
	) -- 865
	place( -- 866
		roomLabel, -- 866
		48, -- 866
		h - 96, -- 866
		0, -- 866
		1 -- 866
	) -- 866
	place( -- 867
		captionLabel, -- 867
		48, -- 867
		h - 140, -- 867
		0, -- 867
		1 -- 867
	) -- 867
	place( -- 869
		switchLabel, -- 869
		48, -- 869
		40, -- 869
		0, -- 869
		0 -- 869
	) -- 869
	place( -- 870
		hintLabel, -- 870
		48, -- 870
		84, -- 870
		0, -- 870
		0 -- 870
	) -- 870
	place( -- 871
		rulerLabel, -- 871
		w - 216, -- 871
		roomTop + 36 + v.scale * 0.5 - 14, -- 871
		1, -- 871
		0 -- 871
	) -- 871
	place( -- 872
		standLabel, -- 872
		48, -- 872
		roomTop + 40, -- 872
		0, -- 872
		0 -- 872
	) -- 872
	place( -- 873
		cartLabel, -- 873
		48, -- 873
		roomTop + 92, -- 873
		0, -- 873
		0 -- 873
	) -- 873
	if roomLabel ~= nil then -- 873
		roomLabel.text = room.name -- 876
	end -- 876
	if captionLabel ~= nil then -- 876
		captionLabel.text = room.caption -- 879
	end -- 879
	if hintLabel ~= nil then -- 879
		local hintIdx = math.min(current, #HINTS - 1) -- 882
		local lines = HINTS[hintIdx + 1] -- 883
		local merged = lines[1] -- 884
		do -- 884
			local i = 1 -- 885
			while i < #lines do -- 885
				merged = (merged .. "    ") .. lines[i + 1] -- 886
				i = i + 1 -- 885
			end -- 885
		end -- 885
		hintLabel.text = merged -- 888
	end -- 888
	local specs = collectLabels(room, v, w) -- 891
	local body = {} -- 892
	local small = {} -- 893
	do -- 893
		local i = 0 -- 894
		while i < #specs do -- 894
			local s = specs[i + 1] -- 895
			if s.size >= 24 then -- 895
				body[#body + 1] = s -- 897
			else -- 897
				small[#small + 1] = s -- 899
			end -- 899
			i = i + 1 -- 894
		end -- 894
	end -- 894
	applyPool(body, poolBody) -- 902
	applyPool(small, poolSmall) -- 903
	if LAYOUT_AUDIT then -- 903
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 906
	end -- 906
end -- 906
function applyPool(specs, pool) -- 910
	do -- 910
		local i = 0 -- 911
		while i < #pool do -- 911
			local lb = pool[i + 1] -- 912
			if i < #specs then -- 912
				local s = specs[i + 1] -- 914
				lb.text = s.text -- 915
				lb.position = Vec2(s.x, s.y) -- 916
				lb.anchor = Vec2(s.ax, s.ay) -- 917
				lb.color = s.color -- 918
				lb.visible = true -- 919
			else -- 919
				lb.visible = false -- 921
			end -- 921
			i = i + 1 -- 911
		end -- 911
	end -- 911
end -- 911
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