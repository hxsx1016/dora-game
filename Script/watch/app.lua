-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local place, setMode, enterPlayRoom, pickByIndex, applySize, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock -- 1
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
function place(lb, x, y, ax, ay) -- 80
	if lb == nil then -- 80
		return -- 82
	end -- 82
	lb.position = Vec2(x, y) -- 84
	lb.anchor = Vec2(ax, ay) -- 85
	lb.visible = true -- 86
end -- 86
function setMode(nextMode) -- 255
	mode = nextMode -- 256
	if grayboxLayer ~= nil then -- 256
		grayboxLayer.visible = mode == 0 -- 258
	end -- 258
	if fe ~= nil then -- 258
		fe:setVisible(mode == 1) -- 261
	end -- 261
	if campaignLayer ~= nil then -- 261
		campaignLayer.visible = mode == 2 -- 264
	end -- 264
	dirty = true -- 266
	clock:reset() -- 267
end -- 267
function enterPlayRoom(idx) -- 270
	current = idx -- 271
	setMode(1) -- 272
	if fe ~= nil then -- 272
		fe.screen = "play" -- 274
	end -- 274
	play = nil -- 276
	ensurePlay() -- 277
end -- 277
function pickByIndex(idx) -- 280
	if mode == 2 then -- 280
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 280
			return -- 283
		end -- 283
		current = idx -- 285
		play = nil -- 286
		clock:reset() -- 287
		ensurePlay() -- 288
		return -- 289
	end -- 289
	if idx < 0 or idx >= #ROOMS then -- 289
		return -- 292
	end -- 292
	current = idx -- 294
	dirty = true -- 295
	play = nil -- 296
	clock:reset() -- 297
	if mode == 1 then -- 297
		if fe ~= nil then -- 297
			fe.screen = "play" -- 300
		end -- 300
		ensurePlay() -- 302
	end -- 302
end -- 302
function applySize() -- 306
	if root == nil then -- 306
		return -- 308
	end -- 308
	root.size = Size(viewW, viewH) -- 310
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 311
end -- 311
function tick(frameDt) -- 314
	local w = View.size.width -- 315
	local h = View.size.height -- 316
	if w ~= viewW or h ~= viewH then -- 316
		viewW = w -- 318
		viewH = h -- 319
		applySize() -- 320
		dirty = true -- 321
	end -- 321
	if input == nil then -- 321
		return -- 324
	end -- 324
	input:update() -- 326
	if mode == 2 and (run and run.trial) ~= nil then -- 326
		tickCampaign(frameDt) -- 328
		return -- 329
	end -- 329
	if input.toggleView.pressed then -- 329
		input.toggleView.pressed = false -- 334
		setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 335
		if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 335
			ensurePlay() -- 337
		end -- 337
	end -- 337
	if input.pickRoom ~= 0 then -- 337
		local idx = input.pickRoom - 1 -- 343
		input.pickRoom = 0 -- 344
		pickByIndex(idx) -- 345
	elseif input.tab.pressed then -- 345
		input.tab.pressed = false -- 347
		if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 347
			pickByIndex((current + 1) % #ROOMS) -- 349
		end -- 349
	end -- 349
	if mode == 2 then -- 349
		tickCampaign(frameDt) -- 354
		return -- 355
	end -- 355
	if mode == 1 then -- 355
		tickFrontend(frameDt) -- 358
		return -- 359
	end -- 359
	if dirty then -- 359
		redrawGraybox() -- 362
		dirty = false -- 363
	end -- 363
end -- 363
function registerPlay() -- 368
	local reg = _G.package.loaded -- 369
	reg["watch.play"] = play -- 370
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 371
	reg["watch.room"] = rooms[current + 1].key -- 372
end -- 372
function ensurePlay(resume) -- 376
	if mode == 2 then -- 376
		if run == nil then -- 376
			run = createRun() -- 379
		end -- 379
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 381
	else -- 381
		play = __TS__New(Play, ROOMS[current + 1], resume) -- 383
	end -- 383
	registerPlay() -- 385
	clock:reset() -- 386
	if fe ~= nil and mode == 1 then -- 386
		fe:bindPlay(play, viewW, viewH) -- 388
	end -- 388
end -- 388
function startTrial() -- 392
	current = 0 -- 393
	run = createTrial(App.rand) -- 394
	setMode(2) -- 395
	ensurePlay() -- 396
end -- 396
function tickCampaign(frameDt) -- 399
	if input == nil then -- 399
		return -- 401
	end -- 401
	if play == nil then -- 401
		ensurePlay() -- 404
	end -- 404
	if play == nil then -- 404
		return -- 407
	end -- 407
	local p = play -- 409
	p.aimX = input.mx -- 410
	p.aimY = input.my -- 411
	local trial = run and run.trial -- 413
	if trial ~= nil then -- 413
		local ended = trial.lost or (run and run.finished) == true -- 415
		local pick = input.pickRoom -- 416
		input.pickRoom = 0 -- 417
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 417
			input:consumeEdges() -- 419
			current = 0 -- 420
			play = nil -- 421
			run = nil -- 422
			setMode(1) -- 423
			if fe ~= nil then -- 423
				fe.screen = "title" -- 425
				fe.menus:resetInput() -- 426
			end -- 426
			return -- 428
		end -- 428
		if ended or p.paused and input.retry.pressed then -- 428
			local restart = input.retry.pressed -- 431
			input:consumeEdges() -- 432
			if restart then -- 432
				startTrial() -- 433
			else -- 433
				drawCampaign(p) -- 434
			end -- 434
			return -- 435
		end -- 435
		input.retry.pressed = false -- 437
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 437
			if pick > 0 then -- 437
				p:chooseTalent(pick - 1) -- 439
			end -- 439
			input:consumeEdges() -- 440
			clock:reset() -- 441
			drawCampaign(p) -- 442
			return -- 443
		end -- 443
	end -- 443
	if input.retry.pressed then -- 443
		input.retry.pressed = false -- 448
		input:consumeEdges() -- 449
		play = nil -- 451
		ensurePlay() -- 452
		return -- 453
	end -- 453
	if input.pause.pressed then -- 453
		input.pause.pressed = false -- 456
		p.paused = not p.paused -- 457
		clock:reset() -- 458
		input:consumeEdges() -- 459
	end -- 459
	if p.paused then -- 459
		drawCampaign(p) -- 462
		return -- 463
	end -- 463
	local steps = clock:advance(frameDt) -- 466
	local i = 0 -- 467
	do -- 467
		i = 0 -- 468
		while i < steps do -- 468
			input:beginStep(i == 0) -- 469
			p:update(STEP, input) -- 470
			input:endStep() -- 471
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 471
				break -- 473
			end -- 473
			i = i + 1 -- 468
		end -- 468
	end -- 468
	if p.wantRoom ~= "" then -- 468
		local key = p.wantRoom -- 478
		p.wantRoom = "" -- 479
		local idx = -1 -- 480
		local j = 0 -- 481
		do -- 481
			j = 0 -- 482
			while j < #CAMPAIGN_ROOMS do -- 482
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 482
					idx = j -- 484
				end -- 484
				j = j + 1 -- 482
			end -- 482
		end -- 482
		if idx >= 0 then -- 482
			current = idx -- 488
			play = nil -- 489
			ensurePlay() -- 490
		end -- 490
		return -- 492
	end -- 492
	drawCampaign(p) -- 494
end -- 494
function goalLabel(goal) -- 497
	if goal == "dock_cart" then -- 497
		return "推车入窝并抬闩" -- 499
	end -- 499
	if goal == "raise_latch" then -- 499
		return "抬闩开侧门" -- 502
	end -- 502
	return "到段出口" -- 504
end -- 504
function drawCampaign(p) -- 507
	if campaignDraw == nil then -- 507
		return -- 509
	end -- 509
	local w = viewW -- 511
	local h = viewH -- 512
	p:draw(campaignDraw, w, h) -- 513
	local room = CAMPAIGN_ROOMS[current + 1] -- 514
	local c = room.campaign -- 515
	local r = run -- 516
	local line = room.name -- 517
	if c ~= nil then -- 517
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 519
	end -- 519
	if p.paused then -- 519
		line = line .. "  · 已暂停 Esc 继续" -- 523
	end -- 523
	local trial = r and r.trial -- 525
	if trial ~= nil and r ~= nil then -- 525
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 527
		if p.paused then -- 527
			line = line .. " · 暂停" -- 528
		elseif trial.lost then -- 528
			line = line .. " · 护送失败" -- 529
		elseif r.finished then -- 529
			line = line .. " · 护送完成" -- 530
		elseif #trial.offers > 0 then -- 530
			line = line .. " · 选择本段本领" -- 531
		elseif c ~= nil then -- 531
			line = line .. " · " .. goalLabel(c.goal) -- 532
		end -- 532
	end -- 532
	if campaignHud ~= nil then -- 532
		campaignHud.text = line -- 535
		campaignHud.position = Vec2(24, h - 14) -- 536
		campaignHud.visible = true -- 537
	end -- 537
	if campaignSub ~= nil then -- 537
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 540
		if r ~= nil then -- 540
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 542
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 543
		end -- 543
		if p.flash ~= "" then -- 543
			sub = (sub .. " · ") .. p.flash -- 549
		end -- 549
		if trial ~= nil and r ~= nil then -- 549
			if trial.lost or r.finished then -- 549
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 552
			elseif p.paused then -- 552
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 553
			elseif #trial.offers > 0 then -- 553
				sub = table.concat( -- 554
					__TS__ArrayMap( -- 554
						trial.offers, -- 554
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 554
					), -- 554
					"　" -- 554
				) -- 554
			else -- 554
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 555
			end -- 555
		end -- 555
		campaignSub.text = sub -- 557
		campaignSub.position = Vec2(24, h - 44) -- 558
		campaignSub.visible = true -- 559
	end -- 559
end -- 559
function tickFrontend(frameDt) -- 563
	if fe == nil or input == nil then -- 563
		return -- 565
	end -- 565
	if fe.screen ~= "play" then -- 565
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 570
		input:consumeEdges() -- 571
		if act.type == "trial" then -- 571
			startTrial() -- 573
		elseif act.type == "start" then -- 573
			enterPlayRoom(0) -- 575
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 575
			enterPlayRoom(act.roomIndex) -- 577
		elseif act.type == "openChapters" then -- 577
			fe.menus:openChapters() -- 579
			fe.screen = "chapters" -- 580
		elseif act.type == "openControls" then -- 580
			fe.menus:resetInput() -- 582
			fe.screen = "controls" -- 583
		elseif act.type == "backTitle" then -- 583
			fe.menus:resetInput() -- 585
			fe.screen = "title" -- 586
		elseif act.type == "backPause" then -- 586
			fe.menus:resetInput() -- 588
			fe.screen = "play" -- 589
		end -- 589
		return -- 591
	end -- 591
	if play == nil then -- 591
		ensurePlay() -- 596
	end -- 596
	if play == nil then -- 596
		return -- 599
	end -- 599
	local p = play -- 601
	if input.retry.pressed then -- 601
		input:consumeEdges() -- 604
		ensurePlay({checkpoint = p.checkpoint}) -- 606
		return -- 607
	end -- 607
	p.aimX = input.mx -- 610
	p.aimY = input.my -- 611
	if not p.paused and input.pause.pressed then -- 611
		p.paused = true -- 614
		p.aimHold = 0 -- 615
		p.bottleAimX = -1 -- 616
		fe.menus:openPause() -- 617
		input:consumeEdges() -- 618
	end -- 618
	if p.paused then -- 618
		clock:reset() -- 623
		local pauseAct = fe:renderPlay( -- 624
			frameDt, -- 624
			p, -- 624
			input, -- 624
			viewW, -- 624
			viewH -- 624
		) -- 624
		input:consumeEdges() -- 625
		if pauseAct.type == "resume" then -- 625
			p.paused = false -- 627
		elseif pauseAct.type == "retry" then -- 627
			ensurePlay({checkpoint = p.checkpoint}) -- 629
		elseif pauseAct.type == "openChapters" then -- 629
			fe.menus:openChapters(current) -- 631
			fe.screen = "chapters" -- 632
		elseif pauseAct.type == "toTitle" then -- 632
			fe.menus:resetInput() -- 634
			fe.screen = "title" -- 635
		end -- 635
		return -- 637
	end -- 637
	local steps = clock:advance(frameDt) -- 640
	local i = 0 -- 641
	do -- 641
		i = 0 -- 642
		while i < steps do -- 642
			input:beginStep(i == 0) -- 643
			p:update(STEP, input) -- 644
			input:endStep() -- 645
			if p.wantRoom ~= "" then -- 645
				break -- 647
			end -- 647
			i = i + 1 -- 642
		end -- 642
	end -- 642
	if p.wantRoom ~= "" then -- 642
		local key = p.wantRoom -- 653
		p.wantRoom = "" -- 654
		local idx = -1 -- 655
		local j = 0 -- 656
		do -- 656
			j = 0 -- 657
			while j < #ROOMS do -- 657
				if ROOMS[j + 1].key == key then -- 657
					idx = j -- 659
				end -- 659
				j = j + 1 -- 657
			end -- 657
		end -- 657
		if idx >= 0 then -- 657
			local leaving = p:drainEvents() -- 665
			current = idx -- 666
			ensurePlay() -- 667
			local fresh = play -- 668
			if fresh ~= nil then -- 668
				fresh:adoptEvents(leaving) -- 670
			end -- 670
			clock:reset() -- 672
			dirty = true -- 673
		end -- 673
		return -- 675
	end -- 675
	fe:renderPlay( -- 678
		frameDt, -- 678
		p, -- 678
		input, -- 678
		viewW, -- 678
		viewH -- 678
	) -- 678
end -- 678
function redrawGraybox() -- 682
	if draw == nil then -- 682
		return -- 684
	end -- 684
	local w = viewW -- 686
	local h = viewH -- 687
	local room = ROOMS[current + 1] -- 688
	draw:clear() -- 690
	draw:drawRect( -- 691
		Rect(0, h - TOP_H, w, TOP_H), -- 691
		C_BG -- 691
	) -- 691
	draw:drawRect( -- 692
		Rect(0, 0, w, BOTTOM_H), -- 692
		C_BG -- 692
	) -- 692
	draw:drawSegment( -- 693
		Vec2(0, h - TOP_H), -- 693
		Vec2(w, h - TOP_H), -- 693
		1, -- 693
		Color(52, 54, 54, 255) -- 693
	) -- 693
	draw:drawSegment( -- 694
		Vec2(0, BOTTOM_H), -- 694
		Vec2(w, BOTTOM_H), -- 694
		1, -- 694
		Color(52, 54, 54, 255) -- 694
	) -- 694
	local v = computeView(room, w, h) -- 696
	renderWorld( -- 697
		draw, -- 697
		room, -- 697
		v, -- 697
		w, -- 697
		h -- 697
	) -- 697
	local roomTop = v.groundPx + room.height * v.scale -- 699
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 700
	place( -- 702
		titleLabel, -- 702
		48, -- 702
		h - 40, -- 702
		0, -- 702
		1 -- 702
	) -- 702
	place( -- 703
		roomLabel, -- 703
		48, -- 703
		h - 96, -- 703
		0, -- 703
		1 -- 703
	) -- 703
	place( -- 704
		captionLabel, -- 704
		48, -- 704
		h - 140, -- 704
		0, -- 704
		1 -- 704
	) -- 704
	place( -- 706
		switchLabel, -- 706
		48, -- 706
		40, -- 706
		0, -- 706
		0 -- 706
	) -- 706
	place( -- 707
		hintLabel, -- 707
		48, -- 707
		84, -- 707
		0, -- 707
		0 -- 707
	) -- 707
	place( -- 708
		rulerLabel, -- 708
		w - 216, -- 708
		roomTop + 36 + v.scale * 0.5 - 14, -- 708
		1, -- 708
		0 -- 708
	) -- 708
	place( -- 709
		standLabel, -- 709
		48, -- 709
		roomTop + 40, -- 709
		0, -- 709
		0 -- 709
	) -- 709
	place( -- 710
		cartLabel, -- 710
		48, -- 710
		roomTop + 92, -- 710
		0, -- 710
		0 -- 710
	) -- 710
	if roomLabel ~= nil then -- 710
		roomLabel.text = room.name -- 713
	end -- 713
	if captionLabel ~= nil then -- 713
		captionLabel.text = room.caption -- 716
	end -- 716
	if hintLabel ~= nil then -- 716
		local hintIdx = math.min(current, #HINTS - 1) -- 719
		local lines = HINTS[hintIdx + 1] -- 720
		local merged = lines[1] -- 721
		do -- 721
			local i = 1 -- 722
			while i < #lines do -- 722
				merged = (merged .. "    ") .. lines[i + 1] -- 723
				i = i + 1 -- 722
			end -- 722
		end -- 722
		hintLabel.text = merged -- 725
	end -- 725
	local specs = collectLabels(room, v, w) -- 728
	local body = {} -- 729
	local small = {} -- 730
	do -- 730
		local i = 0 -- 731
		while i < #specs do -- 731
			local s = specs[i + 1] -- 732
			if s.size >= 24 then -- 732
				body[#body + 1] = s -- 734
			else -- 734
				small[#small + 1] = s -- 736
			end -- 736
			i = i + 1 -- 731
		end -- 731
	end -- 731
	applyPool(body, poolBody) -- 739
	applyPool(small, poolSmall) -- 740
	if LAYOUT_AUDIT then -- 740
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 743
	end -- 743
end -- 743
function applyPool(specs, pool) -- 747
	do -- 747
		local i = 0 -- 748
		while i < #pool do -- 748
			local lb = pool[i + 1] -- 749
			if i < #specs then -- 749
				local s = specs[i + 1] -- 751
				lb.text = s.text -- 752
				lb.position = Vec2(s.x, s.y) -- 753
				lb.anchor = Vec2(s.ax, s.ay) -- 754
				lb.color = s.color -- 755
				lb.visible = true -- 756
			else -- 756
				lb.visible = false -- 758
			end -- 758
			i = i + 1 -- 748
		end -- 748
	end -- 748
end -- 748
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
poolBody = {} -- 51
poolSmall = {} -- 52
current = 0 -- 54
viewW = 0 -- 55
viewH = 0 -- 56
dirty = true -- 57
mode = 1 -- 59
clock = __TS__New(StepClock) -- 63
local function makeGrayboxLabel(text, size, color) -- 65
	if grayboxLayer == nil then -- 65
		return nil -- 67
	end -- 67
	local lb = Label(FONT, size) -- 69
	if lb == nil then -- 69
		return nil -- 71
	end -- 71
	lb.text = text -- 73
	lb.color = color -- 74
	lb:addTo(grayboxLayer) -- 75
	lb.visible = true -- 76
	return lb -- 77
end -- 65
function ____exports.start(parent, initialMode, startScreen) -- 89
	if initialMode == nil then -- 89
		initialMode = 1 -- 89
	end -- 89
	if startScreen == nil then -- 89
		startScreen = "title" -- 89
	end -- 89
	root = parent -- 90
	mode = initialMode -- 91
	grayboxLayer = Node() -- 94
	grayboxLayer.order = 2 -- 95
	grayboxLayer:addTo(parent) -- 96
	draw = DrawNode() -- 98
	draw:addTo(grayboxLayer) -- 99
	campaignLayer = Node() -- 102
	campaignLayer.order = 3 -- 103
	campaignLayer:addTo(parent) -- 104
	campaignDraw = DrawNode() -- 105
	campaignDraw:addTo(campaignLayer) -- 106
	campaignHud = Label(FONT, 24) -- 107
	if campaignHud ~= nil then -- 107
		campaignHud.color = C_TEXT -- 109
		campaignHud.anchor = Vec2(0, 1) -- 110
		campaignHud:addTo(campaignLayer) -- 111
		campaignHud.visible = true -- 112
	end -- 112
	campaignSub = Label(FONT, 20) -- 114
	if campaignSub ~= nil then -- 114
		campaignSub.color = C_ACCENT -- 116
		campaignSub.anchor = Vec2(0, 1) -- 117
		campaignSub:addTo(campaignLayer) -- 118
		campaignSub.visible = true -- 119
	end -- 119
	campaignLayer.visible = mode == 2 -- 121
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 123
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 124
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 125
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 126
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 127
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 128
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 129
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 130
	do -- 130
		local i = 0 -- 132
		while i < POOL_BODY do -- 132
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 133
			if lb ~= nil then -- 133
				poolBody[#poolBody + 1] = lb -- 135
			end -- 135
			i = i + 1 -- 132
		end -- 132
	end -- 132
	do -- 132
		local i = 0 -- 138
		while i < POOL_SMALL do -- 138
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 139
			if lb ~= nil then -- 139
				poolSmall[#poolSmall + 1] = lb -- 141
			end -- 141
			i = i + 1 -- 138
		end -- 138
	end -- 138
	fe = __TS__New(WatchFrontend, parent) -- 146
	fe.screen = startScreen -- 147
	grayboxLayer.visible = mode == 0 -- 148
	fe:setVisible(mode == 1) -- 149
	if campaignLayer ~= nil then -- 149
		campaignLayer.visible = mode == 2 -- 151
	end -- 151
	input = __TS__New(Input) -- 154
	parent:onKeyDown(function(key) -- 157
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or play ~= nil and play.paused) then -- 157
			fe.menus:onKeyEvent(key) -- 159
		end -- 159
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" or mode == 2) then -- 159
			if key == "E" then -- 159
				input.interact.pressed = true -- 163
			elseif key == "Space" then -- 163
				input.jump.pressed = true -- 165
			elseif key == "Escape" then -- 165
				input.pause.pressed = true -- 167
			elseif key == "R" then -- 167
				input.retry.pressed = true -- 169
			end -- 169
		end -- 169
		if mode == 2 and (run and run.trial) ~= nil then -- 169
			return -- 172
		end -- 172
		if key == "F1" then -- 172
			if mode == 2 then -- 172
				current = 0 -- 175
				play = nil -- 176
				ensurePlay() -- 177
			else -- 177
				enterPlayRoom(current) -- 179
			end -- 179
		elseif key == "F2" then -- 179
			setMode(0) -- 182
		elseif key == "1" then -- 182
			pickByIndex(0) -- 184
		elseif key == "2" then -- 184
			pickByIndex(1) -- 186
		elseif key == "3" then -- 186
			pickByIndex(2) -- 188
		elseif key == "4" then -- 188
			pickByIndex(3) -- 190
		elseif key == "5" then -- 190
			pickByIndex(4) -- 192
		elseif key == "6" then -- 192
			pickByIndex(5) -- 194
		elseif key == "7" then -- 194
			pickByIndex(6) -- 196
		elseif key == "8" then -- 196
			pickByIndex(7) -- 198
		end -- 198
	end) -- 157
	viewW = View.size.width -- 202
	viewH = View.size.height -- 203
	applySize() -- 204
	local reg = _G.package.loaded -- 207
	reg["watch.input"] = input -- 208
	reg["watch.fe"] = { -- 209
		setScreen = function(sc) -- 210
			if fe == nil then -- 210
				return -- 212
			end -- 212
			setMode(1) -- 214
			fe.screen = sc -- 215
			if sc == "chapters" then -- 215
				fe.menus:openChapters() -- 217
			else -- 217
				fe.menus:resetInput() -- 219
			end -- 219
			if sc == "play" then -- 219
				ensurePlay() -- 222
			end -- 222
		end, -- 210
		jumpRoom = function(keyOrIdx) -- 225
			local idx = -1 -- 226
			if type(keyOrIdx) == "number" then -- 226
				idx = keyOrIdx -- 228
			else -- 228
				local k = 0 -- 230
				do -- 230
					k = 0 -- 231
					while k < #ROOMS do -- 231
						if ROOMS[k + 1].key == keyOrIdx then -- 231
							idx = k -- 233
						end -- 233
						k = k + 1 -- 231
					end -- 231
				end -- 231
			end -- 231
			if idx >= 0 and idx < #ROOMS then -- 231
				enterPlayRoom(idx) -- 238
			end -- 238
		end, -- 225
		getPlay = function() return play end, -- 241
		getFrontend = function() return fe end -- 242
	} -- 242
	if mode == 1 and startScreen == "play" then -- 242
		ensurePlay() -- 246
	end -- 246
	parent:schedule(function(frameDt) -- 249
		tick(frameDt) -- 250
		return false -- 251
	end) -- 249
end -- 89
return ____exports -- 89