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
function setMode(nextMode) -- 268
	mode = nextMode -- 269
	if grayboxLayer ~= nil then -- 269
		grayboxLayer.visible = mode == 0 -- 271
	end -- 271
	if fe ~= nil then -- 271
		fe:setVisible(mode == 1) -- 274
	end -- 274
	if campaignLayer ~= nil then -- 274
		campaignLayer.visible = mode == 2 -- 277
	end -- 277
	dirty = true -- 279
	clock:reset() -- 280
end -- 280
function enterPlayRoom(idx, source, fresh) -- 283
	if source == nil then -- 283
		source = "debug" -- 283
	end -- 283
	if fresh == nil then -- 283
		fresh = false -- 283
	end -- 283
	current = idx -- 284
	setMode(1) -- 285
	if fe ~= nil then -- 285
		fe.screen = "play" -- 287
	end -- 287
	play = nil -- 289
	if fresh or storyRun == nil then -- 289
		storyRun = createRun(20261124, source) -- 292
	else -- 292
		storyRun.source = source -- 294
	end -- 294
	ensurePlay() -- 296
end -- 296
function pickByIndex(idx, source) -- 299
	if source == nil then -- 299
		source = "debug" -- 299
	end -- 299
	if mode == 2 then -- 299
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 299
			return -- 302
		end -- 302
		current = idx -- 304
		play = nil -- 305
		clock:reset() -- 306
		ensurePlay() -- 307
		return -- 308
	end -- 308
	if idx < 0 or idx >= #ROOMS then -- 308
		return -- 311
	end -- 311
	current = idx -- 313
	dirty = true -- 314
	play = nil -- 315
	clock:reset() -- 316
	if mode == 1 then -- 316
		if fe ~= nil then -- 316
			fe.screen = "play" -- 319
		end -- 319
		ensurePlay() -- 321
	end -- 321
end -- 321
function applySize() -- 325
	if root == nil then -- 325
		return -- 327
	end -- 327
	root.size = Size(viewW, viewH) -- 329
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 330
end -- 330
function tick(frameDt) -- 333
	local w = View.size.width -- 334
	local h = View.size.height -- 335
	if w ~= viewW or h ~= viewH then -- 335
		viewW = w -- 337
		viewH = h -- 338
		applySize() -- 339
		dirty = true -- 340
	end -- 340
	if input == nil then -- 340
		return -- 343
	end -- 343
	input:update() -- 345
	if mode == 2 and (run and run.trial) ~= nil then -- 345
		tickCampaign(frameDt) -- 347
		return -- 348
	end -- 348
	if input.toggleView.pressed then -- 348
		input.toggleView.pressed = false -- 353
		setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 354
		if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 354
			ensurePlay() -- 356
		end -- 356
	end -- 356
	if input.pickRoom ~= 0 then -- 356
		local idx = input.pickRoom - 1 -- 362
		input.pickRoom = 0 -- 363
		pickByIndex(idx) -- 364
	elseif input.tab.pressed then -- 364
		input.tab.pressed = false -- 366
		if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 366
			pickByIndex((current + 1) % #ROOMS) -- 368
		end -- 368
	end -- 368
	if mode == 2 then -- 368
		tickCampaign(frameDt) -- 373
		return -- 374
	end -- 374
	if mode == 1 then -- 374
		tickFrontend(frameDt) -- 377
		return -- 378
	end -- 378
	if dirty then -- 378
		redrawGraybox() -- 381
		dirty = false -- 382
	end -- 382
end -- 382
function registerPlay() -- 387
	local reg = _G.package.loaded -- 388
	reg["watch.play"] = play -- 389
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 390
	reg["watch.room"] = rooms[current + 1].key -- 391
end -- 391
function ensurePlay(resume) -- 395
	if mode == 2 then -- 395
		if run == nil then -- 395
			run = createRun() -- 398
		end -- 398
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 400
	else -- 400
		if storyRun == nil then -- 400
			storyRun = createRun() -- 405
		end -- 405
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 407
	end -- 407
	registerPlay() -- 409
	clock:reset() -- 410
	if fe ~= nil and mode == 1 then -- 410
		fe:bindPlay(play, viewW, viewH) -- 412
	end -- 412
end -- 412
function startTrial() -- 416
	current = 0 -- 417
	run = createTrial(App.rand) -- 418
	setMode(2) -- 419
	ensurePlay() -- 420
end -- 420
function tickCampaign(frameDt) -- 423
	if input == nil then -- 423
		return -- 425
	end -- 425
	if play == nil then -- 425
		ensurePlay() -- 428
	end -- 428
	if play == nil then -- 428
		return -- 431
	end -- 431
	local p = play -- 433
	p.aimX = input.mx -- 434
	p.aimY = input.my -- 435
	local trial = run and run.trial -- 437
	if trial ~= nil then -- 437
		local ended = trial.lost or (run and run.finished) == true -- 439
		local pick = input.pickRoom -- 440
		input.pickRoom = 0 -- 441
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 441
			input:consumeEdges() -- 443
			current = 0 -- 444
			play = nil -- 445
			run = nil -- 446
			setMode(1) -- 447
			if fe ~= nil then -- 447
				fe.screen = "title" -- 449
				fe.menus:resetInput() -- 450
			end -- 450
			return -- 452
		end -- 452
		if ended or p.paused and input.retry.pressed then -- 452
			local restart = input.retry.pressed -- 455
			input:consumeEdges() -- 456
			if restart then -- 456
				startTrial() -- 457
			else -- 457
				drawCampaign(p) -- 458
			end -- 458
			return -- 459
		end -- 459
		input.retry.pressed = false -- 461
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 461
			if pick > 0 then -- 461
				p:chooseTalent(pick - 1) -- 463
			end -- 463
			input:consumeEdges() -- 464
			clock:reset() -- 465
			drawCampaign(p) -- 466
			return -- 467
		end -- 467
	end -- 467
	if input.retry.pressed then -- 467
		input.retry.pressed = false -- 472
		input:consumeEdges() -- 473
		play = nil -- 475
		ensurePlay() -- 476
		return -- 477
	end -- 477
	if input.pause.pressed then -- 477
		input.pause.pressed = false -- 480
		p.paused = not p.paused -- 481
		clock:reset() -- 482
		input:consumeEdges() -- 483
	end -- 483
	if p.paused then -- 483
		drawCampaign(p) -- 486
		return -- 487
	end -- 487
	local steps = clock:advance(frameDt) -- 490
	local i = 0 -- 491
	do -- 491
		i = 0 -- 492
		while i < steps do -- 492
			input:beginStep(i == 0) -- 493
			p:update(STEP, input) -- 494
			input:endStep() -- 495
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 495
				break -- 497
			end -- 497
			i = i + 1 -- 492
		end -- 492
	end -- 492
	if p.wantRoom ~= "" then -- 492
		local key = p.wantRoom -- 502
		p.wantRoom = "" -- 503
		local idx = -1 -- 504
		local j = 0 -- 505
		do -- 505
			j = 0 -- 506
			while j < #CAMPAIGN_ROOMS do -- 506
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 506
					idx = j -- 508
				end -- 508
				j = j + 1 -- 506
			end -- 506
		end -- 506
		if idx >= 0 then -- 506
			current = idx -- 512
			play = nil -- 513
			ensurePlay() -- 514
		end -- 514
		return -- 516
	end -- 516
	drawCampaign(p) -- 518
end -- 518
function goalLabel(goal) -- 521
	if goal == "dock_cart" then -- 521
		return "推车入窝并抬闩" -- 523
	end -- 523
	if goal == "raise_latch" then -- 523
		return "抬闩开侧门" -- 526
	end -- 526
	return "到段出口" -- 528
end -- 528
function drawCampaign(p) -- 531
	if campaignDraw == nil then -- 531
		return -- 533
	end -- 533
	local w = viewW -- 535
	local h = viewH -- 536
	p:draw(campaignDraw, w, h) -- 537
	local room = CAMPAIGN_ROOMS[current + 1] -- 538
	local c = room.campaign -- 539
	local r = run -- 540
	local line = room.name -- 541
	if c ~= nil then -- 541
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 543
	end -- 543
	if p.paused then -- 543
		line = line .. "  · 已暂停 Esc 继续" -- 547
	end -- 547
	local trial = r and r.trial -- 549
	if trial ~= nil and r ~= nil then -- 549
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 551
		if p.paused then -- 551
			line = line .. " · 暂停" -- 552
		elseif trial.lost then -- 552
			line = line .. " · 护送失败" -- 553
		elseif r.finished then -- 553
			line = line .. " · 护送完成" -- 554
		elseif #trial.offers > 0 then -- 554
			line = line .. " · 选择本段本领" -- 555
		elseif c ~= nil then -- 555
			line = line .. " · " .. goalLabel(c.goal) -- 556
		end -- 556
	end -- 556
	if campaignHud ~= nil then -- 556
		campaignHud.text = line -- 559
		campaignHud.position = Vec2(24, h - 14) -- 560
		campaignHud.visible = true -- 561
	end -- 561
	if campaignSub ~= nil then -- 561
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 564
		if r ~= nil then -- 564
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 566
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 567
		end -- 567
		if p.flash ~= "" then -- 567
			sub = (sub .. " · ") .. p.flash -- 573
		end -- 573
		if trial ~= nil and r ~= nil then -- 573
			if trial.lost or r.finished then -- 573
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 576
			elseif p.paused then -- 576
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 577
			elseif #trial.offers > 0 then -- 577
				sub = table.concat( -- 578
					__TS__ArrayMap( -- 578
						trial.offers, -- 578
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 578
					), -- 578
					"　" -- 578
				) -- 578
			else -- 578
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 579
			end -- 579
		end -- 579
		campaignSub.text = sub -- 581
		campaignSub.position = Vec2(24, h - 44) -- 582
		campaignSub.visible = true -- 583
	end -- 583
end -- 583
function tickFrontend(frameDt) -- 587
	if fe == nil or input == nil then -- 587
		return -- 589
	end -- 589
	if fe.screen ~= "play" then -- 589
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 594
		input:consumeEdges() -- 595
		if act.type == "trial" then -- 595
			startTrial() -- 597
		elseif act.type == "start" then -- 597
			enterPlayRoom(0, "official", true) -- 599
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 599
			enterPlayRoom(act.roomIndex, "chapter") -- 601
		elseif act.type == "openChapters" then -- 601
			fe.menus:openChapters() -- 603
			fe.screen = "chapters" -- 604
		elseif act.type == "openControls" then -- 604
			fe.menus:resetInput() -- 606
			fe.screen = "controls" -- 607
		elseif act.type == "backTitle" then -- 607
			fe.menus:resetInput() -- 609
			fe.screen = "title" -- 610
		elseif act.type == "backPause" then -- 610
			fe.menus:resetInput() -- 612
			fe.screen = "play" -- 613
		end -- 613
		return -- 615
	end -- 615
	if play == nil then -- 615
		ensurePlay() -- 620
	end -- 620
	if play == nil then -- 620
		return -- 623
	end -- 623
	local p = play -- 625
	if input.retry.pressed then -- 625
		input:consumeEdges() -- 628
		ensurePlay({checkpoint = p.checkpoint}) -- 630
		return -- 631
	end -- 631
	p.aimX = input.mx -- 634
	p.aimY = input.my -- 635
	if not p.paused and input.pause.pressed then -- 635
		p.paused = true -- 638
		p.aimHold = 0 -- 639
		p.bottleAimX = -1 -- 640
		fe.menus:openPause() -- 641
		input:consumeEdges() -- 642
	end -- 642
	if p.paused then -- 642
		clock:reset() -- 647
		local pauseAct = fe:renderPlay( -- 648
			frameDt, -- 648
			p, -- 648
			input, -- 648
			viewW, -- 648
			viewH -- 648
		) -- 648
		input:consumeEdges() -- 649
		if pauseAct.type == "resume" then -- 649
			p.paused = false -- 651
		elseif pauseAct.type == "retry" then -- 651
			ensurePlay({checkpoint = p.checkpoint}) -- 653
		elseif pauseAct.type == "openChapters" then -- 653
			fe.menus:openChapters(current) -- 655
			fe.screen = "chapters" -- 656
		elseif pauseAct.type == "toTitle" then -- 656
			fe.menus:resetInput() -- 658
			fe.screen = "title" -- 659
		end -- 659
		return -- 661
	end -- 661
	local steps = clock:advance(frameDt) -- 664
	local i = 0 -- 665
	do -- 665
		i = 0 -- 666
		while i < steps do -- 666
			input:beginStep(i == 0) -- 667
			p:update(STEP, input) -- 668
			input:endStep() -- 669
			if p.wantRoom ~= "" then -- 669
				break -- 671
			end -- 671
			i = i + 1 -- 666
		end -- 666
	end -- 666
	if p.wantRoom ~= "" then -- 666
		local key = p.wantRoom -- 677
		p.wantRoom = "" -- 678
		local idx = -1 -- 679
		local j = 0 -- 680
		do -- 680
			j = 0 -- 681
			while j < #ROOMS do -- 681
				if ROOMS[j + 1].key == key then -- 681
					idx = j -- 683
				end -- 683
				j = j + 1 -- 681
			end -- 681
		end -- 681
		if idx >= 0 then -- 681
			local leaving = p:drainEvents() -- 689
			current = idx -- 690
			ensurePlay() -- 691
			local fresh = play -- 692
			if fresh ~= nil then -- 692
				fresh:adoptEvents(leaving) -- 694
			end -- 694
			clock:reset() -- 696
			dirty = true -- 697
		end -- 697
		return -- 699
	end -- 699
	fe:renderPlay( -- 702
		frameDt, -- 702
		p, -- 702
		input, -- 702
		viewW, -- 702
		viewH -- 702
	) -- 702
end -- 702
function redrawGraybox() -- 706
	if draw == nil then -- 706
		return -- 708
	end -- 708
	local w = viewW -- 710
	local h = viewH -- 711
	local room = ROOMS[current + 1] -- 712
	draw:clear() -- 714
	draw:drawRect( -- 715
		Rect(0, h - TOP_H, w, TOP_H), -- 715
		C_BG -- 715
	) -- 715
	draw:drawRect( -- 716
		Rect(0, 0, w, BOTTOM_H), -- 716
		C_BG -- 716
	) -- 716
	draw:drawSegment( -- 717
		Vec2(0, h - TOP_H), -- 717
		Vec2(w, h - TOP_H), -- 717
		1, -- 717
		Color(52, 54, 54, 255) -- 717
	) -- 717
	draw:drawSegment( -- 718
		Vec2(0, BOTTOM_H), -- 718
		Vec2(w, BOTTOM_H), -- 718
		1, -- 718
		Color(52, 54, 54, 255) -- 718
	) -- 718
	local v = computeView(room, w, h) -- 720
	renderWorld( -- 721
		draw, -- 721
		room, -- 721
		v, -- 721
		w, -- 721
		h -- 721
	) -- 721
	local roomTop = v.groundPx + room.height * v.scale -- 723
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 724
	place( -- 726
		titleLabel, -- 726
		48, -- 726
		h - 40, -- 726
		0, -- 726
		1 -- 726
	) -- 726
	place( -- 727
		roomLabel, -- 727
		48, -- 727
		h - 96, -- 727
		0, -- 727
		1 -- 727
	) -- 727
	place( -- 728
		captionLabel, -- 728
		48, -- 728
		h - 140, -- 728
		0, -- 728
		1 -- 728
	) -- 728
	place( -- 730
		switchLabel, -- 730
		48, -- 730
		40, -- 730
		0, -- 730
		0 -- 730
	) -- 730
	place( -- 731
		hintLabel, -- 731
		48, -- 731
		84, -- 731
		0, -- 731
		0 -- 731
	) -- 731
	place( -- 732
		rulerLabel, -- 732
		w - 216, -- 732
		roomTop + 36 + v.scale * 0.5 - 14, -- 732
		1, -- 732
		0 -- 732
	) -- 732
	place( -- 733
		standLabel, -- 733
		48, -- 733
		roomTop + 40, -- 733
		0, -- 733
		0 -- 733
	) -- 733
	place( -- 734
		cartLabel, -- 734
		48, -- 734
		roomTop + 92, -- 734
		0, -- 734
		0 -- 734
	) -- 734
	if roomLabel ~= nil then -- 734
		roomLabel.text = room.name -- 737
	end -- 737
	if captionLabel ~= nil then -- 737
		captionLabel.text = room.caption -- 740
	end -- 740
	if hintLabel ~= nil then -- 740
		local hintIdx = math.min(current, #HINTS - 1) -- 743
		local lines = HINTS[hintIdx + 1] -- 744
		local merged = lines[1] -- 745
		do -- 745
			local i = 1 -- 746
			while i < #lines do -- 746
				merged = (merged .. "    ") .. lines[i + 1] -- 747
				i = i + 1 -- 746
			end -- 746
		end -- 746
		hintLabel.text = merged -- 749
	end -- 749
	local specs = collectLabels(room, v, w) -- 752
	local body = {} -- 753
	local small = {} -- 754
	do -- 754
		local i = 0 -- 755
		while i < #specs do -- 755
			local s = specs[i + 1] -- 756
			if s.size >= 24 then -- 756
				body[#body + 1] = s -- 758
			else -- 758
				small[#small + 1] = s -- 760
			end -- 760
			i = i + 1 -- 755
		end -- 755
	end -- 755
	applyPool(body, poolBody) -- 763
	applyPool(small, poolSmall) -- 764
	if LAYOUT_AUDIT then -- 764
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 767
	end -- 767
end -- 767
function applyPool(specs, pool) -- 771
	do -- 771
		local i = 0 -- 772
		while i < #pool do -- 772
			local lb = pool[i + 1] -- 773
			if i < #specs then -- 773
				local s = specs[i + 1] -- 775
				lb.text = s.text -- 776
				lb.position = Vec2(s.x, s.y) -- 777
				lb.anchor = Vec2(s.ax, s.ay) -- 778
				lb.color = s.color -- 779
				lb.visible = true -- 780
			else -- 780
				lb.visible = false -- 782
			end -- 782
			i = i + 1 -- 772
		end -- 772
	end -- 772
end -- 772
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
		getFrontend = function() return fe end, -- 244
		startStory = function() -- 246
			enterPlayRoom(0, "official", true) -- 247
			return play -- 248
		end, -- 246
		previewChapter = function(idx) -- 251
			enterPlayRoom(idx, "chapter") -- 252
			return play -- 253
		end, -- 251
		getStoryRun = function() return storyRun end -- 255
	} -- 255
	if mode == 1 and startScreen == "play" then -- 255
		ensurePlay() -- 259
	end -- 259
	parent:schedule(function(frameDt) -- 262
		tick(frameDt) -- 263
		return false -- 264
	end) -- 262
end -- 91
return ____exports -- 91