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
function enterPlayRoom(idx, source, fresh) -- 272
	if source == nil then -- 272
		source = "debug" -- 272
	end -- 272
	if fresh == nil then -- 272
		fresh = false -- 272
	end -- 272
	current = idx -- 273
	setMode(1) -- 274
	if fe ~= nil then -- 274
		fe.screen = "play" -- 276
	end -- 276
	play = nil -- 278
	if fresh or storyRun == nil then -- 278
		storyRun = createRun(20261124, source) -- 281
	else -- 281
		storyRun.source = source -- 283
	end -- 283
	ensurePlay() -- 285
end -- 285
function pickByIndex(idx, source) -- 288
	if source == nil then -- 288
		source = "debug" -- 288
	end -- 288
	if mode == 2 then -- 288
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 288
			return -- 291
		end -- 291
		current = idx -- 293
		play = nil -- 294
		clock:reset() -- 295
		ensurePlay() -- 296
		return -- 297
	end -- 297
	if idx < 0 or idx >= #ROOMS then -- 297
		return -- 300
	end -- 300
	current = idx -- 302
	dirty = true -- 303
	play = nil -- 304
	clock:reset() -- 305
	if mode == 1 then -- 305
		if fe ~= nil then -- 305
			fe.screen = "play" -- 308
		end -- 308
		ensurePlay() -- 310
	end -- 310
end -- 310
function applySize() -- 314
	if root == nil then -- 314
		return -- 316
	end -- 316
	root.size = Size(viewW, viewH) -- 318
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 319
end -- 319
function tick(frameDt) -- 322
	local w = View.size.width -- 323
	local h = View.size.height -- 324
	if w ~= viewW or h ~= viewH then -- 324
		viewW = w -- 326
		viewH = h -- 327
		applySize() -- 328
		dirty = true -- 329
	end -- 329
	if input == nil then -- 329
		return -- 332
	end -- 332
	input:update() -- 334
	if mode == 2 and (run and run.trial) ~= nil then -- 334
		tickCampaign(frameDt) -- 336
		return -- 337
	end -- 337
	if input.toggleView.pressed then -- 337
		input.toggleView.pressed = false -- 342
		setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 343
		if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 343
			ensurePlay() -- 345
		end -- 345
	end -- 345
	if input.pickRoom ~= 0 then -- 345
		local idx = input.pickRoom - 1 -- 351
		input.pickRoom = 0 -- 352
		pickByIndex(idx) -- 353
	elseif input.tab.pressed then -- 353
		input.tab.pressed = false -- 355
		if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 355
			pickByIndex((current + 1) % #ROOMS) -- 357
		end -- 357
	end -- 357
	if mode == 2 then -- 357
		tickCampaign(frameDt) -- 362
		return -- 363
	end -- 363
	if mode == 1 then -- 363
		tickFrontend(frameDt) -- 366
		return -- 367
	end -- 367
	if dirty then -- 367
		redrawGraybox() -- 370
		dirty = false -- 371
	end -- 371
end -- 371
function registerPlay() -- 376
	local reg = _G.package.loaded -- 377
	reg["watch.play"] = play -- 378
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 379
	reg["watch.room"] = rooms[current + 1].key -- 380
end -- 380
function ensurePlay(resume) -- 384
	if mode == 2 then -- 384
		if run == nil then -- 384
			run = createRun() -- 387
		end -- 387
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 389
	else -- 389
		if storyRun == nil then -- 389
			storyRun = createRun() -- 394
		end -- 394
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 396
	end -- 396
	registerPlay() -- 398
	clock:reset() -- 399
	if fe ~= nil and mode == 1 then -- 399
		fe:bindPlay(play, viewW, viewH) -- 401
	end -- 401
end -- 401
function startTrial() -- 405
	current = 0 -- 406
	run = createTrial(App.rand) -- 407
	setMode(2) -- 408
	ensurePlay() -- 409
end -- 409
function tickCampaign(frameDt) -- 412
	if input == nil then -- 412
		return -- 414
	end -- 414
	if play == nil then -- 414
		ensurePlay() -- 417
	end -- 417
	if play == nil then -- 417
		return -- 420
	end -- 420
	local p = play -- 422
	p.aimX = input.mx -- 423
	p.aimY = input.my -- 424
	local trial = run and run.trial -- 426
	if trial ~= nil then -- 426
		local ended = trial.lost or (run and run.finished) == true -- 428
		local pick = input.pickRoom -- 429
		input.pickRoom = 0 -- 430
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 430
			input:consumeEdges() -- 432
			current = 0 -- 433
			play = nil -- 434
			run = nil -- 435
			setMode(1) -- 436
			if fe ~= nil then -- 436
				fe.screen = "title" -- 438
				fe.menus:resetInput() -- 439
			end -- 439
			return -- 441
		end -- 441
		if ended or p.paused and input.retry.pressed then -- 441
			local restart = input.retry.pressed -- 444
			input:consumeEdges() -- 445
			if restart then -- 445
				startTrial() -- 446
			else -- 446
				drawCampaign(p) -- 447
			end -- 447
			return -- 448
		end -- 448
		input.retry.pressed = false -- 450
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 450
			if pick > 0 then -- 450
				p:chooseTalent(pick - 1) -- 452
			end -- 452
			input:consumeEdges() -- 453
			clock:reset() -- 454
			drawCampaign(p) -- 455
			return -- 456
		end -- 456
	end -- 456
	if input.retry.pressed then -- 456
		input.retry.pressed = false -- 461
		input:consumeEdges() -- 462
		play = nil -- 464
		ensurePlay() -- 465
		return -- 466
	end -- 466
	if input.pause.pressed then -- 466
		input.pause.pressed = false -- 469
		p.paused = not p.paused -- 470
		clock:reset() -- 471
		input:consumeEdges() -- 472
	end -- 472
	if p.paused then -- 472
		drawCampaign(p) -- 475
		return -- 476
	end -- 476
	local steps = clock:advance(frameDt) -- 479
	local i = 0 -- 480
	do -- 480
		i = 0 -- 481
		while i < steps do -- 481
			input:beginStep(i == 0) -- 482
			p:update(STEP, input) -- 483
			input:endStep() -- 484
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 484
				break -- 486
			end -- 486
			i = i + 1 -- 481
		end -- 481
	end -- 481
	if p.wantRoom ~= "" then -- 481
		local key = p.wantRoom -- 491
		p.wantRoom = "" -- 492
		local idx = -1 -- 493
		local j = 0 -- 494
		do -- 494
			j = 0 -- 495
			while j < #CAMPAIGN_ROOMS do -- 495
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 495
					idx = j -- 497
				end -- 497
				j = j + 1 -- 495
			end -- 495
		end -- 495
		if idx >= 0 then -- 495
			current = idx -- 501
			play = nil -- 502
			ensurePlay() -- 503
		end -- 503
		return -- 505
	end -- 505
	drawCampaign(p) -- 507
end -- 507
function goalLabel(goal) -- 510
	if goal == "dock_cart" then -- 510
		return "推车入窝并抬闩" -- 512
	end -- 512
	if goal == "raise_latch" then -- 512
		return "抬闩开侧门" -- 515
	end -- 515
	return "到段出口" -- 517
end -- 517
function drawCampaign(p) -- 520
	if campaignDraw == nil then -- 520
		return -- 522
	end -- 522
	local w = viewW -- 524
	local h = viewH -- 525
	p:draw(campaignDraw, w, h) -- 526
	local room = CAMPAIGN_ROOMS[current + 1] -- 527
	local c = room.campaign -- 528
	local r = run -- 529
	local line = room.name -- 530
	if c ~= nil then -- 530
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 532
	end -- 532
	if p.paused then -- 532
		line = line .. "  · 已暂停 Esc 继续" -- 536
	end -- 536
	local trial = r and r.trial -- 538
	if trial ~= nil and r ~= nil then -- 538
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 540
		if p.paused then -- 540
			line = line .. " · 暂停" -- 541
		elseif trial.lost then -- 541
			line = line .. " · 护送失败" -- 542
		elseif r.finished then -- 542
			line = line .. " · 护送完成" -- 543
		elseif #trial.offers > 0 then -- 543
			line = line .. " · 选择本段本领" -- 544
		elseif c ~= nil then -- 544
			line = line .. " · " .. goalLabel(c.goal) -- 545
		end -- 545
	end -- 545
	if campaignHud ~= nil then -- 545
		campaignHud.text = line -- 548
		campaignHud.position = Vec2(24, h - 14) -- 549
		campaignHud.visible = true -- 550
	end -- 550
	if campaignSub ~= nil then -- 550
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 553
		if r ~= nil then -- 553
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 555
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 556
		end -- 556
		if p.flash ~= "" then -- 556
			sub = (sub .. " · ") .. p.flash -- 562
		end -- 562
		if trial ~= nil and r ~= nil then -- 562
			if trial.lost or r.finished then -- 562
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 565
			elseif p.paused then -- 565
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 566
			elseif #trial.offers > 0 then -- 566
				sub = table.concat( -- 567
					__TS__ArrayMap( -- 567
						trial.offers, -- 567
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 567
					), -- 567
					"　" -- 567
				) -- 567
			else -- 567
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 568
			end -- 568
		end -- 568
		campaignSub.text = sub -- 570
		campaignSub.position = Vec2(24, h - 44) -- 571
		campaignSub.visible = true -- 572
	end -- 572
end -- 572
function tickFrontend(frameDt) -- 576
	if fe == nil or input == nil then -- 576
		return -- 578
	end -- 578
	if fe.screen ~= "play" then -- 578
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 583
		input:consumeEdges() -- 584
		if act.type == "trial" then -- 584
			startTrial() -- 586
		elseif act.type == "start" then -- 586
			enterPlayRoom(0, "official", true) -- 588
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 588
			enterPlayRoom(act.roomIndex, "chapter") -- 590
		elseif act.type == "openChapters" then -- 590
			fe.menus:openChapters() -- 592
			fe.screen = "chapters" -- 593
		elseif act.type == "openControls" then -- 593
			fe.menus:resetInput() -- 595
			fe.screen = "controls" -- 596
		elseif act.type == "backTitle" then -- 596
			fe.menus:resetInput() -- 598
			fe.screen = "title" -- 599
		elseif act.type == "backPause" then -- 599
			fe.menus:resetInput() -- 601
			fe.screen = "play" -- 602
		end -- 602
		return -- 604
	end -- 604
	if play == nil then -- 604
		ensurePlay() -- 609
	end -- 609
	if play == nil then -- 609
		return -- 612
	end -- 612
	local p = play -- 614
	if input.retry.pressed then -- 614
		input:consumeEdges() -- 617
		ensurePlay({checkpoint = p.checkpoint}) -- 619
		return -- 620
	end -- 620
	p.aimX = input.mx -- 623
	p.aimY = input.my -- 624
	if not p.paused and input.pause.pressed then -- 624
		p.paused = true -- 627
		p.aimHold = 0 -- 628
		p.bottleAimX = -1 -- 629
		fe.menus:openPause() -- 630
		input:consumeEdges() -- 631
	end -- 631
	if p.paused then -- 631
		clock:reset() -- 636
		local pauseAct = fe:renderPlay( -- 637
			frameDt, -- 637
			p, -- 637
			input, -- 637
			viewW, -- 637
			viewH -- 637
		) -- 637
		input:consumeEdges() -- 638
		if pauseAct.type == "resume" then -- 638
			p.paused = false -- 640
		elseif pauseAct.type == "retry" then -- 640
			ensurePlay({checkpoint = p.checkpoint}) -- 642
		elseif pauseAct.type == "openChapters" then -- 642
			fe.menus:openChapters(current) -- 644
			fe.screen = "chapters" -- 645
		elseif pauseAct.type == "toTitle" then -- 645
			fe.menus:resetInput() -- 647
			fe.screen = "title" -- 648
		end -- 648
		return -- 650
	end -- 650
	local steps = clock:advance(frameDt) -- 653
	local i = 0 -- 654
	do -- 654
		i = 0 -- 655
		while i < steps do -- 655
			input:beginStep(i == 0) -- 656
			p:update(STEP, input) -- 657
			input:endStep() -- 658
			if p.wantRoom ~= "" then -- 658
				break -- 660
			end -- 660
			i = i + 1 -- 655
		end -- 655
	end -- 655
	if p.wantRoom ~= "" then -- 655
		local key = p.wantRoom -- 666
		p.wantRoom = "" -- 667
		local idx = -1 -- 668
		local j = 0 -- 669
		do -- 669
			j = 0 -- 670
			while j < #ROOMS do -- 670
				if ROOMS[j + 1].key == key then -- 670
					idx = j -- 672
				end -- 672
				j = j + 1 -- 670
			end -- 670
		end -- 670
		if idx >= 0 then -- 670
			local leaving = p:drainEvents() -- 678
			current = idx -- 679
			ensurePlay() -- 680
			local fresh = play -- 681
			if fresh ~= nil then -- 681
				fresh:adoptEvents(leaving) -- 683
			end -- 683
			clock:reset() -- 685
			dirty = true -- 686
		end -- 686
		return -- 688
	end -- 688
	fe:renderPlay( -- 691
		frameDt, -- 691
		p, -- 691
		input, -- 691
		viewW, -- 691
		viewH -- 691
	) -- 691
end -- 691
function redrawGraybox() -- 695
	if draw == nil then -- 695
		return -- 697
	end -- 697
	local w = viewW -- 699
	local h = viewH -- 700
	local room = ROOMS[current + 1] -- 701
	draw:clear() -- 703
	draw:drawRect( -- 704
		Rect(0, h - TOP_H, w, TOP_H), -- 704
		C_BG -- 704
	) -- 704
	draw:drawRect( -- 705
		Rect(0, 0, w, BOTTOM_H), -- 705
		C_BG -- 705
	) -- 705
	draw:drawSegment( -- 706
		Vec2(0, h - TOP_H), -- 706
		Vec2(w, h - TOP_H), -- 706
		1, -- 706
		Color(52, 54, 54, 255) -- 706
	) -- 706
	draw:drawSegment( -- 707
		Vec2(0, BOTTOM_H), -- 707
		Vec2(w, BOTTOM_H), -- 707
		1, -- 707
		Color(52, 54, 54, 255) -- 707
	) -- 707
	local v = computeView(room, w, h) -- 709
	renderWorld( -- 710
		draw, -- 710
		room, -- 710
		v, -- 710
		w, -- 710
		h -- 710
	) -- 710
	local roomTop = v.groundPx + room.height * v.scale -- 712
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 713
	place( -- 715
		titleLabel, -- 715
		48, -- 715
		h - 40, -- 715
		0, -- 715
		1 -- 715
	) -- 715
	place( -- 716
		roomLabel, -- 716
		48, -- 716
		h - 96, -- 716
		0, -- 716
		1 -- 716
	) -- 716
	place( -- 717
		captionLabel, -- 717
		48, -- 717
		h - 140, -- 717
		0, -- 717
		1 -- 717
	) -- 717
	place( -- 719
		switchLabel, -- 719
		48, -- 719
		40, -- 719
		0, -- 719
		0 -- 719
	) -- 719
	place( -- 720
		hintLabel, -- 720
		48, -- 720
		84, -- 720
		0, -- 720
		0 -- 720
	) -- 720
	place( -- 721
		rulerLabel, -- 721
		w - 216, -- 721
		roomTop + 36 + v.scale * 0.5 - 14, -- 721
		1, -- 721
		0 -- 721
	) -- 721
	place( -- 722
		standLabel, -- 722
		48, -- 722
		roomTop + 40, -- 722
		0, -- 722
		0 -- 722
	) -- 722
	place( -- 723
		cartLabel, -- 723
		48, -- 723
		roomTop + 92, -- 723
		0, -- 723
		0 -- 723
	) -- 723
	if roomLabel ~= nil then -- 723
		roomLabel.text = room.name -- 726
	end -- 726
	if captionLabel ~= nil then -- 726
		captionLabel.text = room.caption -- 729
	end -- 729
	if hintLabel ~= nil then -- 729
		local hintIdx = math.min(current, #HINTS - 1) -- 732
		local lines = HINTS[hintIdx + 1] -- 733
		local merged = lines[1] -- 734
		do -- 734
			local i = 1 -- 735
			while i < #lines do -- 735
				merged = (merged .. "    ") .. lines[i + 1] -- 736
				i = i + 1 -- 735
			end -- 735
		end -- 735
		hintLabel.text = merged -- 738
	end -- 738
	local specs = collectLabels(room, v, w) -- 741
	local body = {} -- 742
	local small = {} -- 743
	do -- 743
		local i = 0 -- 744
		while i < #specs do -- 744
			local s = specs[i + 1] -- 745
			if s.size >= 24 then -- 745
				body[#body + 1] = s -- 747
			else -- 747
				small[#small + 1] = s -- 749
			end -- 749
			i = i + 1 -- 744
		end -- 744
	end -- 744
	applyPool(body, poolBody) -- 752
	applyPool(small, poolSmall) -- 753
	if LAYOUT_AUDIT then -- 753
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 756
	end -- 756
end -- 756
function applyPool(specs, pool) -- 760
	do -- 760
		local i = 0 -- 761
		while i < #pool do -- 761
			local lb = pool[i + 1] -- 762
			if i < #specs then -- 762
				local s = specs[i + 1] -- 764
				lb.text = s.text -- 765
				lb.position = Vec2(s.x, s.y) -- 766
				lb.anchor = Vec2(s.ax, s.ay) -- 767
				lb.color = s.color -- 768
				lb.visible = true -- 769
			else -- 769
				lb.visible = false -- 771
			end -- 771
			i = i + 1 -- 761
		end -- 761
	end -- 761
end -- 761
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
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 181
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
				enterPlayRoom(idx, "debug") -- 240
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