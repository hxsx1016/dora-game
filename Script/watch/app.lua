-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local place, setMode, roomIndexByKey, enterPlayRoom, pickByIndex, applySize, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock -- 1
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
function roomIndexByKey(key) -- 308
	local i = 0 -- 309
	do -- 309
		i = 0 -- 310
		while i < #ROOMS do -- 310
			if ROOMS[i + 1].key == key then -- 310
				return i -- 312
			end -- 312
			i = i + 1 -- 310
		end -- 310
	end -- 310
	return 0 -- 315
end -- 315
function enterPlayRoom(idx, source, fresh) -- 318
	if source == nil then -- 318
		source = "debug" -- 318
	end -- 318
	if fresh == nil then -- 318
		fresh = false -- 318
	end -- 318
	current = idx -- 319
	setMode(1) -- 320
	if fe ~= nil then -- 320
		fe.screen = "play" -- 322
	end -- 322
	play = nil -- 324
	if fresh or storyRun == nil then -- 324
		storyRun = createRun(20261124, source, profile) -- 327
	else -- 327
		storyRun.source = source -- 329
	end -- 329
	ensurePlay() -- 331
end -- 331
function pickByIndex(idx, source) -- 334
	if source == nil then -- 334
		source = "debug" -- 334
	end -- 334
	if mode == 2 then -- 334
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 334
			return -- 337
		end -- 337
		current = idx -- 339
		play = nil -- 340
		clock:reset() -- 341
		ensurePlay() -- 342
		return -- 343
	end -- 343
	if idx < 0 or idx >= #ROOMS then -- 343
		return -- 346
	end -- 346
	current = idx -- 348
	dirty = true -- 349
	play = nil -- 350
	clock:reset() -- 351
	if mode == 1 then -- 351
		if fe ~= nil then -- 351
			fe.screen = "play" -- 354
		end -- 354
		ensurePlay() -- 356
	end -- 356
end -- 356
function applySize() -- 360
	if root == nil then -- 360
		return -- 362
	end -- 362
	root.size = Size(viewW, viewH) -- 364
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 365
end -- 365
function tick(frameDt) -- 368
	local w = View.size.width -- 369
	local h = View.size.height -- 370
	if w ~= viewW or h ~= viewH then -- 370
		viewW = w -- 372
		viewH = h -- 373
		applySize() -- 374
		dirty = true -- 375
	end -- 375
	if input == nil then -- 375
		return -- 378
	end -- 378
	input:update() -- 380
	if mode == 2 and (run and run.trial) ~= nil then -- 380
		tickCampaign(frameDt) -- 382
		return -- 383
	end -- 383
	if input.toggleView.pressed then -- 383
		input.toggleView.pressed = false -- 388
		setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 389
		if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 389
			ensurePlay() -- 391
		end -- 391
	end -- 391
	if input.pickRoom ~= 0 then -- 391
		local idx = input.pickRoom - 1 -- 397
		input.pickRoom = 0 -- 398
		pickByIndex(idx) -- 399
	elseif input.tab.pressed then -- 399
		input.tab.pressed = false -- 401
		if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 401
			pickByIndex((current + 1) % #ROOMS) -- 403
		end -- 403
	end -- 403
	if mode == 2 then -- 403
		tickCampaign(frameDt) -- 408
		return -- 409
	end -- 409
	if mode == 1 then -- 409
		tickFrontend(frameDt) -- 412
		return -- 413
	end -- 413
	if dirty then -- 413
		redrawGraybox() -- 416
		dirty = false -- 417
	end -- 417
end -- 417
function registerPlay() -- 422
	local reg = _G.package.loaded -- 423
	reg["watch.play"] = play -- 424
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 425
	reg["watch.room"] = rooms[current + 1].key -- 426
end -- 426
function ensurePlay(resume) -- 430
	if mode == 2 then -- 430
		if run == nil then -- 430
			run = createRun() -- 433
		end -- 433
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 435
	else -- 435
		if storyRun == nil then -- 435
			storyRun = createRun(20261124, "debug", profile) -- 440
		end -- 440
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 442
	end -- 442
	registerPlay() -- 444
	clock:reset() -- 445
	if fe ~= nil and mode == 1 then -- 445
		fe:bindPlay(play, viewW, viewH) -- 447
	end -- 447
end -- 447
function startTrial() -- 451
	current = 0 -- 452
	run = createTrial(App.rand) -- 453
	setMode(2) -- 454
	ensurePlay() -- 455
end -- 455
function tickCampaign(frameDt) -- 458
	if input == nil then -- 458
		return -- 460
	end -- 460
	if play == nil then -- 460
		ensurePlay() -- 463
	end -- 463
	if play == nil then -- 463
		return -- 466
	end -- 466
	local p = play -- 468
	p.aimX = input.mx -- 469
	p.aimY = input.my -- 470
	local trial = run and run.trial -- 472
	if trial ~= nil then -- 472
		local ended = trial.lost or (run and run.finished) == true -- 474
		local pick = input.pickRoom -- 475
		input.pickRoom = 0 -- 476
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 476
			input:consumeEdges() -- 478
			current = 0 -- 479
			play = nil -- 480
			run = nil -- 481
			setMode(1) -- 482
			if fe ~= nil then -- 482
				fe.screen = "title" -- 484
				fe.menus:resetInput() -- 485
			end -- 485
			return -- 487
		end -- 487
		if ended or p.paused and input.retry.pressed then -- 487
			local restart = input.retry.pressed -- 490
			input:consumeEdges() -- 491
			if restart then -- 491
				startTrial() -- 492
			else -- 492
				drawCampaign(p) -- 493
			end -- 493
			return -- 494
		end -- 494
		input.retry.pressed = false -- 496
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 496
			if pick > 0 then -- 496
				p:chooseTalent(pick - 1) -- 498
			end -- 498
			input:consumeEdges() -- 499
			clock:reset() -- 500
			drawCampaign(p) -- 501
			return -- 502
		end -- 502
	end -- 502
	if input.retry.pressed then -- 502
		input.retry.pressed = false -- 507
		input:consumeEdges() -- 508
		play = nil -- 510
		ensurePlay() -- 511
		return -- 512
	end -- 512
	if input.pause.pressed then -- 512
		input.pause.pressed = false -- 515
		p.paused = not p.paused -- 516
		clock:reset() -- 517
		input:consumeEdges() -- 518
	end -- 518
	if p.paused then -- 518
		drawCampaign(p) -- 521
		return -- 522
	end -- 522
	local steps = clock:advance(frameDt) -- 525
	local i = 0 -- 526
	do -- 526
		i = 0 -- 527
		while i < steps do -- 527
			input:beginStep(i == 0) -- 528
			p:update(STEP, input) -- 529
			input:endStep() -- 530
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 530
				break -- 532
			end -- 532
			i = i + 1 -- 527
		end -- 527
	end -- 527
	if p.wantRoom ~= "" then -- 527
		local key = p.wantRoom -- 537
		p.wantRoom = "" -- 538
		local idx = -1 -- 539
		local j = 0 -- 540
		do -- 540
			j = 0 -- 541
			while j < #CAMPAIGN_ROOMS do -- 541
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 541
					idx = j -- 543
				end -- 543
				j = j + 1 -- 541
			end -- 541
		end -- 541
		if idx >= 0 then -- 541
			current = idx -- 547
			play = nil -- 548
			ensurePlay() -- 549
		end -- 549
		return -- 551
	end -- 551
	drawCampaign(p) -- 553
end -- 553
function goalLabel(goal) -- 556
	if goal == "dock_cart" then -- 556
		return "推车入窝并抬闩" -- 558
	end -- 558
	if goal == "raise_latch" then -- 558
		return "抬闩开侧门" -- 561
	end -- 561
	return "到段出口" -- 563
end -- 563
function drawCampaign(p) -- 566
	if campaignDraw == nil then -- 566
		return -- 568
	end -- 568
	local w = viewW -- 570
	local h = viewH -- 571
	p:draw(campaignDraw, w, h) -- 572
	local room = CAMPAIGN_ROOMS[current + 1] -- 573
	local c = room.campaign -- 574
	local r = run -- 575
	local line = room.name -- 576
	if c ~= nil then -- 576
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 578
	end -- 578
	if p.paused then -- 578
		line = line .. "  · 已暂停 Esc 继续" -- 582
	end -- 582
	local trial = r and r.trial -- 584
	if trial ~= nil and r ~= nil then -- 584
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 586
		if p.paused then -- 586
			line = line .. " · 暂停" -- 587
		elseif trial.lost then -- 587
			line = line .. " · 护送失败" -- 588
		elseif r.finished then -- 588
			line = line .. " · 护送完成" -- 589
		elseif #trial.offers > 0 then -- 589
			line = line .. " · 选择本段本领" -- 590
		elseif c ~= nil then -- 590
			line = line .. " · " .. goalLabel(c.goal) -- 591
		end -- 591
	end -- 591
	if campaignHud ~= nil then -- 591
		campaignHud.text = line -- 594
		campaignHud.position = Vec2(24, h - 14) -- 595
		campaignHud.visible = true -- 596
	end -- 596
	if campaignSub ~= nil then -- 596
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 599
		if r ~= nil then -- 599
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 601
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 602
		end -- 602
		if p.flash ~= "" then -- 602
			sub = (sub .. " · ") .. p.flash -- 608
		end -- 608
		if trial ~= nil and r ~= nil then -- 608
			if trial.lost or r.finished then -- 608
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 611
			elseif p.paused then -- 611
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 612
			elseif #trial.offers > 0 then -- 612
				sub = table.concat( -- 613
					__TS__ArrayMap( -- 613
						trial.offers, -- 613
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 613
					), -- 613
					"　" -- 613
				) -- 613
			else -- 613
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 614
			end -- 614
		end -- 614
		campaignSub.text = sub -- 616
		campaignSub.position = Vec2(24, h - 44) -- 617
		campaignSub.visible = true -- 618
	end -- 618
end -- 618
function tickFrontend(frameDt) -- 622
	if fe == nil or input == nil then -- 622
		return -- 624
	end -- 624
	if fe.screen ~= "play" then -- 624
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 629
		input:consumeEdges() -- 630
		if act.type == "trial" then -- 630
			startTrial() -- 632
		elseif act.type == "start" then -- 632
			local mp = profile.museumPhase -- 635
			local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 636
			enterPlayRoom( -- 637
				inMuseum and roomIndexByKey("museum") or 0, -- 637
				"official", -- 637
				true -- 637
			) -- 637
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 637
			enterPlayRoom(act.roomIndex, "chapter") -- 639
		elseif act.type == "openChapters" then -- 639
			fe.menus:openChapters() -- 641
			fe.screen = "chapters" -- 642
		elseif act.type == "openControls" then -- 642
			fe.menus:resetInput() -- 644
			fe.screen = "controls" -- 645
		elseif act.type == "backTitle" then -- 645
			fe.menus:resetInput() -- 647
			fe.screen = "title" -- 648
		elseif act.type == "backPause" then -- 648
			fe.menus:resetInput() -- 650
			fe.screen = "play" -- 651
		end -- 651
		return -- 653
	end -- 653
	if play == nil then -- 653
		ensurePlay() -- 658
	end -- 658
	if play == nil then -- 658
		return -- 661
	end -- 661
	local p = play -- 663
	if input.retry.pressed then -- 663
		input:consumeEdges() -- 666
		ensurePlay({checkpoint = p.checkpoint}) -- 668
		return -- 669
	end -- 669
	p.aimX = input.mx -- 672
	p.aimY = input.my -- 673
	if not p.paused and input.pause.pressed then -- 673
		p.paused = true -- 676
		p.aimHold = 0 -- 677
		p.bottleAimX = -1 -- 678
		fe.menus:openPause() -- 679
		input:consumeEdges() -- 680
	end -- 680
	if p.paused then -- 680
		clock:reset() -- 685
		local pauseAct = fe:renderPlay( -- 686
			frameDt, -- 686
			p, -- 686
			input, -- 686
			viewW, -- 686
			viewH -- 686
		) -- 686
		input:consumeEdges() -- 687
		if pauseAct.type == "resume" then -- 687
			p.paused = false -- 689
		elseif pauseAct.type == "retry" then -- 689
			ensurePlay({checkpoint = p.checkpoint}) -- 691
		elseif pauseAct.type == "openChapters" then -- 691
			fe.menus:openChapters(current) -- 693
			fe.screen = "chapters" -- 694
		elseif pauseAct.type == "toTitle" then -- 694
			fe.menus:resetInput() -- 696
			fe.screen = "title" -- 697
		end -- 697
		return -- 699
	end -- 699
	local steps = clock:advance(frameDt) -- 702
	local i = 0 -- 703
	do -- 703
		i = 0 -- 704
		while i < steps do -- 704
			input:beginStep(i == 0) -- 705
			p:update(STEP, input) -- 706
			input:endStep() -- 707
			if p.wantRoom ~= "" then -- 707
				break -- 709
			end -- 709
			i = i + 1 -- 704
		end -- 704
	end -- 704
	if p.wantRoom ~= "" then -- 704
		local key = p.wantRoom -- 715
		p.wantRoom = "" -- 716
		local idx = -1 -- 717
		local j = 0 -- 718
		do -- 718
			j = 0 -- 719
			while j < #ROOMS do -- 719
				if ROOMS[j + 1].key == key then -- 719
					idx = j -- 721
				end -- 721
				j = j + 1 -- 719
			end -- 719
		end -- 719
		if idx >= 0 then -- 719
			local leaving = p:drainEvents() -- 727
			if p.restartStory then -- 727
				storyRun = createRun(20261124, storyRun == nil and "official" or storyRun.source, profile) -- 730
			end -- 730
			current = idx -- 732
			ensurePlay() -- 733
			local fresh = play -- 734
			if fresh ~= nil then -- 734
				fresh:adoptEvents(leaving) -- 736
			end -- 736
			clock:reset() -- 738
			dirty = true -- 739
		end -- 739
		return -- 741
	end -- 741
	if p.archiveDirty then -- 741
		p.archiveDirty = false -- 746
		if not saveSave(profile) then -- 746
			p.archiveDirty = true -- 748
		end -- 748
	end -- 748
	fe:renderPlay( -- 751
		frameDt, -- 751
		p, -- 751
		input, -- 751
		viewW, -- 751
		viewH -- 751
	) -- 751
end -- 751
function redrawGraybox() -- 755
	if draw == nil then -- 755
		return -- 757
	end -- 757
	local w = viewW -- 759
	local h = viewH -- 760
	local room = ROOMS[current + 1] -- 761
	draw:clear() -- 763
	draw:drawRect( -- 764
		Rect(0, h - TOP_H, w, TOP_H), -- 764
		C_BG -- 764
	) -- 764
	draw:drawRect( -- 765
		Rect(0, 0, w, BOTTOM_H), -- 765
		C_BG -- 765
	) -- 765
	draw:drawSegment( -- 766
		Vec2(0, h - TOP_H), -- 766
		Vec2(w, h - TOP_H), -- 766
		1, -- 766
		Color(52, 54, 54, 255) -- 766
	) -- 766
	draw:drawSegment( -- 767
		Vec2(0, BOTTOM_H), -- 767
		Vec2(w, BOTTOM_H), -- 767
		1, -- 767
		Color(52, 54, 54, 255) -- 767
	) -- 767
	local v = computeView(room, w, h) -- 769
	renderWorld( -- 770
		draw, -- 770
		room, -- 770
		v, -- 770
		w, -- 770
		h -- 770
	) -- 770
	local roomTop = v.groundPx + room.height * v.scale -- 772
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 773
	place( -- 775
		titleLabel, -- 775
		48, -- 775
		h - 40, -- 775
		0, -- 775
		1 -- 775
	) -- 775
	place( -- 776
		roomLabel, -- 776
		48, -- 776
		h - 96, -- 776
		0, -- 776
		1 -- 776
	) -- 776
	place( -- 777
		captionLabel, -- 777
		48, -- 777
		h - 140, -- 777
		0, -- 777
		1 -- 777
	) -- 777
	place( -- 779
		switchLabel, -- 779
		48, -- 779
		40, -- 779
		0, -- 779
		0 -- 779
	) -- 779
	place( -- 780
		hintLabel, -- 780
		48, -- 780
		84, -- 780
		0, -- 780
		0 -- 780
	) -- 780
	place( -- 781
		rulerLabel, -- 781
		w - 216, -- 781
		roomTop + 36 + v.scale * 0.5 - 14, -- 781
		1, -- 781
		0 -- 781
	) -- 781
	place( -- 782
		standLabel, -- 782
		48, -- 782
		roomTop + 40, -- 782
		0, -- 782
		0 -- 782
	) -- 782
	place( -- 783
		cartLabel, -- 783
		48, -- 783
		roomTop + 92, -- 783
		0, -- 783
		0 -- 783
	) -- 783
	if roomLabel ~= nil then -- 783
		roomLabel.text = room.name -- 786
	end -- 786
	if captionLabel ~= nil then -- 786
		captionLabel.text = room.caption -- 789
	end -- 789
	if hintLabel ~= nil then -- 789
		local hintIdx = math.min(current, #HINTS - 1) -- 792
		local lines = HINTS[hintIdx + 1] -- 793
		local merged = lines[1] -- 794
		do -- 794
			local i = 1 -- 795
			while i < #lines do -- 795
				merged = (merged .. "    ") .. lines[i + 1] -- 796
				i = i + 1 -- 795
			end -- 795
		end -- 795
		hintLabel.text = merged -- 798
	end -- 798
	local specs = collectLabels(room, v, w) -- 801
	local body = {} -- 802
	local small = {} -- 803
	do -- 803
		local i = 0 -- 804
		while i < #specs do -- 804
			local s = specs[i + 1] -- 805
			if s.size >= 24 then -- 805
				body[#body + 1] = s -- 807
			else -- 807
				small[#small + 1] = s -- 809
			end -- 809
			i = i + 1 -- 804
		end -- 804
	end -- 804
	applyPool(body, poolBody) -- 812
	applyPool(small, poolSmall) -- 813
	if LAYOUT_AUDIT then -- 813
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 816
	end -- 816
end -- 816
function applyPool(specs, pool) -- 820
	do -- 820
		local i = 0 -- 821
		while i < #pool do -- 821
			local lb = pool[i + 1] -- 822
			if i < #specs then -- 822
				local s = specs[i + 1] -- 824
				lb.text = s.text -- 825
				lb.position = Vec2(s.x, s.y) -- 826
				lb.anchor = Vec2(s.ax, s.ay) -- 827
				lb.color = s.color -- 828
				lb.visible = true -- 829
			else -- 829
				lb.visible = false -- 831
			end -- 831
			i = i + 1 -- 821
		end -- 821
	end -- 821
end -- 821
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