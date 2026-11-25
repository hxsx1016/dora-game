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
	flushProfile() -- 360
end -- 360
function pickByIndex(idx, source) -- 363
	if source == nil then -- 363
		source = "debug" -- 363
	end -- 363
	if mode == 2 then -- 363
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 363
			return -- 366
		end -- 366
		current = idx -- 368
		play = nil -- 369
		clock:reset() -- 370
		ensurePlay() -- 371
		return -- 372
	end -- 372
	if idx < 0 or idx >= #ROOMS then -- 372
		return -- 375
	end -- 375
	current = idx -- 377
	dirty = true -- 378
	play = nil -- 379
	clock:reset() -- 380
	if mode == 1 then -- 380
		if fe ~= nil then -- 380
			fe.screen = "play" -- 383
		end -- 383
		ensurePlay() -- 385
	end -- 385
end -- 385
function applySize() -- 389
	if root == nil then -- 389
		return -- 391
	end -- 391
	root.size = Size(viewW, viewH) -- 393
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 394
end -- 394
function tick(frameDt) -- 397
	local w = View.size.width -- 398
	local h = View.size.height -- 399
	if w ~= viewW or h ~= viewH then -- 399
		viewW = w -- 401
		viewH = h -- 402
		applySize() -- 403
		dirty = true -- 404
	end -- 404
	if input == nil then -- 404
		return -- 407
	end -- 407
	input:update() -- 409
	if mode == 2 and (run and run.trial) ~= nil then -- 409
		tickCampaign(frameDt) -- 411
		return -- 412
	end -- 412
	if input.toggleView.pressed then -- 412
		input.toggleView.pressed = false -- 417
		setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 418
		if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 418
			ensurePlay() -- 420
		end -- 420
	end -- 420
	if input.pickRoom ~= 0 then -- 420
		local idx = input.pickRoom - 1 -- 426
		input.pickRoom = 0 -- 427
		pickByIndex(idx) -- 428
	elseif input.tab.pressed then -- 428
		input.tab.pressed = false -- 430
		if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 430
			pickByIndex((current + 1) % #ROOMS) -- 432
		end -- 432
	end -- 432
	if mode == 2 then -- 432
		tickCampaign(frameDt) -- 437
		return -- 438
	end -- 438
	if mode == 1 then -- 438
		tickFrontend(frameDt) -- 441
		return -- 442
	end -- 442
	if dirty then -- 442
		redrawGraybox() -- 445
		dirty = false -- 446
	end -- 446
end -- 446
function registerPlay() -- 451
	local reg = _G.package.loaded -- 452
	reg["watch.play"] = play -- 453
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 454
	reg["watch.room"] = rooms[current + 1].key -- 455
end -- 455
function ensurePlay(resume) -- 459
	if mode == 2 then -- 459
		if run == nil then -- 459
			run = createRun() -- 462
		end -- 462
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 464
	else -- 464
		if storyRun == nil then -- 464
			storyRun = createRun(20261124, "debug", profile) -- 469
		end -- 469
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 471
	end -- 471
	registerPlay() -- 473
	clock:reset() -- 474
	if fe ~= nil and mode == 1 then -- 474
		fe:bindPlay(play, viewW, viewH) -- 476
	end -- 476
end -- 476
function startTrial() -- 480
	current = 0 -- 481
	run = createTrial(App.rand) -- 482
	setMode(2) -- 483
	ensurePlay() -- 484
end -- 484
function tickCampaign(frameDt) -- 487
	if input == nil then -- 487
		return -- 489
	end -- 489
	if play == nil then -- 489
		ensurePlay() -- 492
	end -- 492
	if play == nil then -- 492
		return -- 495
	end -- 495
	local p = play -- 497
	p.aimX = input.mx -- 498
	p.aimY = input.my -- 499
	local trial = run and run.trial -- 501
	if trial ~= nil then -- 501
		local ended = trial.lost or (run and run.finished) == true -- 503
		local pick = input.pickRoom -- 504
		input.pickRoom = 0 -- 505
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 505
			input:consumeEdges() -- 507
			current = 0 -- 508
			play = nil -- 509
			run = nil -- 510
			setMode(1) -- 511
			if fe ~= nil then -- 511
				fe.screen = "title" -- 513
				fe.menus:resetInput() -- 514
			end -- 514
			return -- 516
		end -- 516
		if ended or p.paused and input.retry.pressed then -- 516
			local restart = input.retry.pressed -- 519
			input:consumeEdges() -- 520
			if restart then -- 520
				startTrial() -- 521
			else -- 521
				drawCampaign(p) -- 522
			end -- 522
			return -- 523
		end -- 523
		input.retry.pressed = false -- 525
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 525
			if pick > 0 then -- 525
				p:chooseTalent(pick - 1) -- 527
			end -- 527
			input:consumeEdges() -- 528
			clock:reset() -- 529
			drawCampaign(p) -- 530
			return -- 531
		end -- 531
	end -- 531
	if input.retry.pressed then -- 531
		input.retry.pressed = false -- 536
		input:consumeEdges() -- 537
		play = nil -- 539
		ensurePlay() -- 540
		return -- 541
	end -- 541
	if input.pause.pressed then -- 541
		input.pause.pressed = false -- 544
		p.paused = not p.paused -- 545
		clock:reset() -- 546
		input:consumeEdges() -- 547
	end -- 547
	if p.paused then -- 547
		drawCampaign(p) -- 550
		return -- 551
	end -- 551
	local steps = clock:advance(frameDt) -- 554
	local i = 0 -- 555
	do -- 555
		i = 0 -- 556
		while i < steps do -- 556
			input:beginStep(i == 0) -- 557
			p:update(STEP, input) -- 558
			input:endStep() -- 559
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 559
				break -- 561
			end -- 561
			i = i + 1 -- 556
		end -- 556
	end -- 556
	if p.wantRoom ~= "" then -- 556
		local key = p.wantRoom -- 566
		p.wantRoom = "" -- 567
		local idx = -1 -- 568
		local j = 0 -- 569
		do -- 569
			j = 0 -- 570
			while j < #CAMPAIGN_ROOMS do -- 570
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 570
					idx = j -- 572
				end -- 572
				j = j + 1 -- 570
			end -- 570
		end -- 570
		if idx >= 0 then -- 570
			current = idx -- 576
			play = nil -- 577
			ensurePlay() -- 578
		end -- 578
		return -- 580
	end -- 580
	drawCampaign(p) -- 582
end -- 582
function goalLabel(goal) -- 585
	if goal == "dock_cart" then -- 585
		return "推车入窝并抬闩" -- 587
	end -- 587
	if goal == "raise_latch" then -- 587
		return "抬闩开侧门" -- 590
	end -- 590
	return "到段出口" -- 592
end -- 592
function drawCampaign(p) -- 595
	if campaignDraw == nil then -- 595
		return -- 597
	end -- 597
	local w = viewW -- 599
	local h = viewH -- 600
	p:draw(campaignDraw, w, h) -- 601
	local room = CAMPAIGN_ROOMS[current + 1] -- 602
	local c = room.campaign -- 603
	local r = run -- 604
	local line = room.name -- 605
	if c ~= nil then -- 605
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 607
	end -- 607
	if p.paused then -- 607
		line = line .. "  · 已暂停 Esc 继续" -- 611
	end -- 611
	local trial = r and r.trial -- 613
	if trial ~= nil and r ~= nil then -- 613
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 615
		if p.paused then -- 615
			line = line .. " · 暂停" -- 616
		elseif trial.lost then -- 616
			line = line .. " · 护送失败" -- 617
		elseif r.finished then -- 617
			line = line .. " · 护送完成" -- 618
		elseif #trial.offers > 0 then -- 618
			line = line .. " · 选择本段本领" -- 619
		elseif c ~= nil then -- 619
			line = line .. " · " .. goalLabel(c.goal) -- 620
		end -- 620
	end -- 620
	if campaignHud ~= nil then -- 620
		campaignHud.text = line -- 623
		campaignHud.position = Vec2(24, h - 14) -- 624
		campaignHud.visible = true -- 625
	end -- 625
	if campaignSub ~= nil then -- 625
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 628
		if r ~= nil then -- 628
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 630
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 631
		end -- 631
		if p.flash ~= "" then -- 631
			sub = (sub .. " · ") .. p.flash -- 637
		end -- 637
		if trial ~= nil and r ~= nil then -- 637
			if trial.lost or r.finished then -- 637
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 640
			elseif p.paused then -- 640
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 641
			elseif #trial.offers > 0 then -- 641
				sub = table.concat( -- 642
					__TS__ArrayMap( -- 642
						trial.offers, -- 642
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 642
					), -- 642
					"　" -- 642
				) -- 642
			else -- 642
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 643
			end -- 643
		end -- 643
		campaignSub.text = sub -- 645
		campaignSub.position = Vec2(24, h - 44) -- 646
		campaignSub.visible = true -- 647
	end -- 647
end -- 647
function tickFrontend(frameDt) -- 651
	if fe == nil or input == nil then -- 651
		return -- 653
	end -- 653
	if fe.screen ~= "play" then -- 653
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 658
		input:consumeEdges() -- 659
		if act.type == "trial" then -- 659
			startTrial() -- 661
		elseif act.type == "start" then -- 661
			enterPlayRoom( -- 664
				officialStartIndex(), -- 664
				"official", -- 664
				true -- 664
			) -- 664
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 664
			enterPlayRoom(act.roomIndex, "chapter") -- 666
		elseif act.type == "openChapters" then -- 666
			fe.menus:openChapters() -- 668
			fe.screen = "chapters" -- 669
		elseif act.type == "openControls" then -- 669
			fe.menus:resetInput() -- 671
			fe.screen = "controls" -- 672
		elseif act.type == "backTitle" then -- 672
			fe.menus:resetInput() -- 674
			fe.screen = "title" -- 675
		elseif act.type == "backPause" then -- 675
			fe.menus:resetInput() -- 677
			fe.screen = "play" -- 678
		end -- 678
		return -- 680
	end -- 680
	if play == nil then -- 680
		ensurePlay() -- 685
	end -- 685
	if play == nil then -- 685
		return -- 688
	end -- 688
	local p = play -- 690
	if input.retry.pressed then -- 690
		input:consumeEdges() -- 693
		ensurePlay({checkpoint = p.checkpoint}) -- 695
		return -- 696
	end -- 696
	p.aimX = input.mx -- 699
	p.aimY = input.my -- 700
	if not p.paused and input.pause.pressed then -- 700
		p.paused = true -- 703
		p.aimHold = 0 -- 704
		p.bottleAimX = -1 -- 705
		fe.menus:openPause() -- 706
		input:consumeEdges() -- 707
	end -- 707
	if p.paused then -- 707
		clock:reset() -- 712
		local pauseAct = fe:renderPlay( -- 713
			frameDt, -- 713
			p, -- 713
			input, -- 713
			viewW, -- 713
			viewH -- 713
		) -- 713
		input:consumeEdges() -- 714
		if pauseAct.type == "resume" then -- 714
			p.paused = false -- 716
		elseif pauseAct.type == "retry" then -- 716
			ensurePlay({checkpoint = p.checkpoint}) -- 718
		elseif pauseAct.type == "openChapters" then -- 718
			fe.menus:openChapters(current) -- 720
			fe.screen = "chapters" -- 721
		elseif pauseAct.type == "toTitle" then -- 721
			fe.menus:resetInput() -- 723
			fe.screen = "title" -- 724
		end -- 724
		return -- 726
	end -- 726
	local steps = clock:advance(frameDt) -- 729
	local i = 0 -- 730
	do -- 730
		i = 0 -- 731
		while i < steps do -- 731
			input:beginStep(i == 0) -- 732
			p:update(STEP, input) -- 733
			input:endStep() -- 734
			if p.wantRoom ~= "" then -- 734
				break -- 736
			end -- 736
			i = i + 1 -- 731
		end -- 731
	end -- 731
	if p.wantRoom ~= "" then -- 731
		local key = p.wantRoom -- 742
		p.wantRoom = "" -- 743
		local idx = -1 -- 744
		local j = 0 -- 745
		do -- 745
			j = 0 -- 746
			while j < #ROOMS do -- 746
				if ROOMS[j + 1].key == key then -- 746
					idx = j -- 748
				end -- 748
				j = j + 1 -- 746
			end -- 746
		end -- 746
		if idx >= 0 then -- 746
			flushProfile() -- 755
			local leaving = p:drainEvents() -- 756
			if p.restartStory then -- 756
				storyRun = createRun(20261124, storyRun == nil and "official" or storyRun.source, profile) -- 759
			end -- 759
			current = idx -- 761
			ensurePlay() -- 762
			local fresh = play -- 763
			if fresh ~= nil then -- 763
				fresh:adoptEvents(leaving) -- 765
			end -- 765
			clock:reset() -- 767
			dirty = true -- 768
		end -- 768
		return -- 770
	end -- 770
	flushProfile() -- 774
	fe:renderPlay( -- 775
		frameDt, -- 775
		p, -- 775
		input, -- 775
		viewW, -- 775
		viewH -- 775
	) -- 775
end -- 775
function redrawGraybox() -- 779
	if draw == nil then -- 779
		return -- 781
	end -- 781
	local w = viewW -- 783
	local h = viewH -- 784
	local room = ROOMS[current + 1] -- 785
	draw:clear() -- 787
	draw:drawRect( -- 788
		Rect(0, h - TOP_H, w, TOP_H), -- 788
		C_BG -- 788
	) -- 788
	draw:drawRect( -- 789
		Rect(0, 0, w, BOTTOM_H), -- 789
		C_BG -- 789
	) -- 789
	draw:drawSegment( -- 790
		Vec2(0, h - TOP_H), -- 790
		Vec2(w, h - TOP_H), -- 790
		1, -- 790
		Color(52, 54, 54, 255) -- 790
	) -- 790
	draw:drawSegment( -- 791
		Vec2(0, BOTTOM_H), -- 791
		Vec2(w, BOTTOM_H), -- 791
		1, -- 791
		Color(52, 54, 54, 255) -- 791
	) -- 791
	local v = computeView(room, w, h) -- 793
	renderWorld( -- 794
		draw, -- 794
		room, -- 794
		v, -- 794
		w, -- 794
		h -- 794
	) -- 794
	local roomTop = v.groundPx + room.height * v.scale -- 796
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 797
	place( -- 799
		titleLabel, -- 799
		48, -- 799
		h - 40, -- 799
		0, -- 799
		1 -- 799
	) -- 799
	place( -- 800
		roomLabel, -- 800
		48, -- 800
		h - 96, -- 800
		0, -- 800
		1 -- 800
	) -- 800
	place( -- 801
		captionLabel, -- 801
		48, -- 801
		h - 140, -- 801
		0, -- 801
		1 -- 801
	) -- 801
	place( -- 803
		switchLabel, -- 803
		48, -- 803
		40, -- 803
		0, -- 803
		0 -- 803
	) -- 803
	place( -- 804
		hintLabel, -- 804
		48, -- 804
		84, -- 804
		0, -- 804
		0 -- 804
	) -- 804
	place( -- 805
		rulerLabel, -- 805
		w - 216, -- 805
		roomTop + 36 + v.scale * 0.5 - 14, -- 805
		1, -- 805
		0 -- 805
	) -- 805
	place( -- 806
		standLabel, -- 806
		48, -- 806
		roomTop + 40, -- 806
		0, -- 806
		0 -- 806
	) -- 806
	place( -- 807
		cartLabel, -- 807
		48, -- 807
		roomTop + 92, -- 807
		0, -- 807
		0 -- 807
	) -- 807
	if roomLabel ~= nil then -- 807
		roomLabel.text = room.name -- 810
	end -- 810
	if captionLabel ~= nil then -- 810
		captionLabel.text = room.caption -- 813
	end -- 813
	if hintLabel ~= nil then -- 813
		local hintIdx = math.min(current, #HINTS - 1) -- 816
		local lines = HINTS[hintIdx + 1] -- 817
		local merged = lines[1] -- 818
		do -- 818
			local i = 1 -- 819
			while i < #lines do -- 819
				merged = (merged .. "    ") .. lines[i + 1] -- 820
				i = i + 1 -- 819
			end -- 819
		end -- 819
		hintLabel.text = merged -- 822
	end -- 822
	local specs = collectLabels(room, v, w) -- 825
	local body = {} -- 826
	local small = {} -- 827
	do -- 827
		local i = 0 -- 828
		while i < #specs do -- 828
			local s = specs[i + 1] -- 829
			if s.size >= 24 then -- 829
				body[#body + 1] = s -- 831
			else -- 831
				small[#small + 1] = s -- 833
			end -- 833
			i = i + 1 -- 828
		end -- 828
	end -- 828
	applyPool(body, poolBody) -- 836
	applyPool(small, poolSmall) -- 837
	if LAYOUT_AUDIT then -- 837
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 840
	end -- 840
end -- 840
function applyPool(specs, pool) -- 844
	do -- 844
		local i = 0 -- 845
		while i < #pool do -- 845
			local lb = pool[i + 1] -- 846
			if i < #specs then -- 846
				local s = specs[i + 1] -- 848
				lb.text = s.text -- 849
				lb.position = Vec2(s.x, s.y) -- 850
				lb.anchor = Vec2(s.ax, s.ay) -- 851
				lb.color = s.color -- 852
				lb.visible = true -- 853
			else -- 853
				lb.visible = false -- 855
			end -- 855
			i = i + 1 -- 845
		end -- 845
	end -- 845
end -- 845
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