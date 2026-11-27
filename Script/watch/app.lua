-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local getReleaseConfig, isReleaseBuild, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, place, setMode, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, pickByIndex, applySize, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock -- 1
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
local loadSession = ____save.loadSession -- 19
local saveSession = ____save.saveSession -- 19
local clearSession = ____save.clearSession -- 19
local hasSessionSave = ____save.hasSessionSave -- 19
local setSessionFile = ____save.setSessionFile -- 19
local getSessionFile = ____save.getSessionFile -- 19
function getReleaseConfig() -- 80
	local ____opt_0 = _G.package -- 80
	local reg = ____opt_0 and ____opt_0.loaded -- 81
	local ____temp_2 -- 82
	if reg ~= nil then -- 82
		____temp_2 = reg["watch.release"] -- 82
	else -- 82
		____temp_2 = nil -- 82
	end -- 82
	local cfg = ____temp_2 -- 82
	if cfg ~= nil and type(cfg) == "table" then -- 82
		return cfg -- 84
	end -- 84
	return nil -- 86
end -- 86
function isReleaseBuild() -- 89
	local ____opt_3 = getReleaseConfig() -- 89
	return (____opt_3 and ____opt_3.isRelease) == true -- 90
end -- 90
function toggleFullscreen() -- 93
	local plat = App.platform -- 94
	if plat ~= "Windows" and plat ~= "macOS" and plat ~= "Linux" then -- 94
		return false -- 96
	end -- 96
	local next = not App.fullScreen -- 98
	App.fullScreen = next -- 99
	return next -- 100
end -- 100
function quitGame() -- 103
	flushProfile() -- 104
	saveCurrentSession() -- 105
	if fe ~= nil then -- 105
		fe.audio:stopRoomTransient() -- 107
	end -- 107
	App:shutdown() -- 109
end -- 109
function canSaveSession() -- 112
	if mode ~= 1 or play == nil or storyRun == nil then -- 112
		return false -- 114
	end -- 114
	if storyRun.source ~= "official" or play.run.finished then -- 114
		return false -- 117
	end -- 117
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 117
		return false -- 120
	end -- 120
	return true -- 122
end -- 122
function refreshTitleSessionFlag() -- 125
	if fe ~= nil then -- 125
		fe.menus.hasSession = hasSessionSave() -- 127
	end -- 127
end -- 127
function saveCurrentSession() -- 131
	if not canSaveSession() or play == nil then -- 131
		return false -- 133
	end -- 133
	play.sessionDirty = false -- 135
	local ok = saveSession(play:exportSession()) -- 136
	refreshTitleSessionFlag() -- 137
	return ok -- 138
end -- 138
function continueOfficialStory() -- 141
	local res = loadSession() -- 142
	if res.status ~= "ok" or res.state == nil then -- 142
		refreshTitleSessionFlag() -- 144
		return nil -- 145
	end -- 145
	local s = res.state -- 147
	local idx = roomIndexByKey(s.roomKey) -- 148
	if ROOMS[idx + 1].key ~= s.roomKey then -- 148
		return nil -- 150
	end -- 150
	storyRun = createRun(s.seed, "official", profile) -- 152
	storyRun.checkpoint = s.checkpoint -- 153
	storyRun.story.route = s.route -- 154
	storyRun.story.hp = s.hp -- 155
	storyRun.story.maxHp = s.maxHp -- 156
	storyRun.story.hpAtGate = s.hpAtGate -- 157
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 158
	storyRun.story.settled = s.settled -- 159
	storyRun.story.phase = s.phase -- 160
	storyRun.story.countTick = s.countTick -- 161
	storyRun.story.phaseTick = s.phaseTick -- 162
	storyRun.story.handTicks = s.handTicks -- 163
	storyRun.story.handDone = s.handDone -- 164
	storyRun.story.lineSaid = s.lineSaid -- 165
	storyRun.story.tied = s.tied -- 166
	storyRun.story.carry = s.carry -- 167
	storyRun.story.escortDone = s.escortDone -- 168
	storyRun.story.craftedWeapon = s.craftedWeapon -- 169
	storyRun.story.equippedWeapon = s.equippedWeapon -- 170
	storyRun.inventory.wood = s.wood -- 171
	storyRun.inventory.bell = s.bell -- 172
	storyRun.inventory.scrap = s.scrap -- 173
	storyRun.inventory.wedge = s.wedge -- 174
	storyRun.inventory.ammo = s.ammo -- 175
	storyRun.inventory.shield = s.shield -- 176
	storyRun.inventory.pass = s.pass -- 177
	storyRun.inventory.quickbelt = s.quickbelt -- 178
	local k = 0 -- 179
	do -- 179
		k = 0 -- 180
		while k < #s.taken do -- 180
			storyRun.taken[s.taken[k + 1]] = true -- 181
			k = k + 1 -- 180
		end -- 180
	end -- 180
	do -- 180
		k = 0 -- 183
		while k < #s.segments do -- 183
			storyRun.story.segments[s.segments[k + 1]] = true -- 184
			k = k + 1 -- 183
		end -- 183
	end -- 183
	current = idx -- 186
	setMode(1) -- 187
	if fe ~= nil then -- 187
		fe.screen = "play" -- 189
	end -- 189
	play = nil -- 191
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 192
	local cur = play -- 193
	if cur ~= nil and s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 193
		cur.cartAxle = s.cartAxle -- 195
		cur.cartDocked = s.cartDocked -- 196
	end -- 196
	return play -- 198
end -- 198
function place(lb, x, y, ax, ay) -- 216
	if lb == nil then -- 216
		return -- 218
	end -- 218
	lb.position = Vec2(x, y) -- 220
	lb.anchor = Vec2(ax, ay) -- 221
	lb.visible = true -- 222
end -- 222
function setMode(nextMode) -- 463
	mode = nextMode -- 464
	if grayboxLayer ~= nil then -- 464
		grayboxLayer.visible = mode == 0 -- 466
	end -- 466
	if fe ~= nil then -- 466
		fe:setVisible(mode == 1) -- 469
	end -- 469
	if campaignLayer ~= nil then -- 469
		campaignLayer.visible = mode == 2 -- 472
	end -- 472
	dirty = true -- 474
	clock:reset() -- 475
end -- 475
function flushProfile() -- 482
	local cur = play -- 483
	if cur ~= nil and cur.archiveDirty then -- 483
		cur.archiveDirty = false -- 485
		markProfilePending(profile) -- 486
	end -- 486
	local ok = flushSaveProfile() -- 488
	if not ok and cur ~= nil then -- 488
		cur.archiveDirty = true -- 490
	end -- 490
	return ok -- 492
end -- 492
function officialStartIndex() -- 496
	local mp = profile.museumPhase -- 497
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 498
	return inMuseum and roomIndexByKey("museum") or 0 -- 499
end -- 499
function roomIndexByKey(key) -- 502
	local i = 0 -- 503
	do -- 503
		i = 0 -- 504
		while i < #ROOMS do -- 504
			if ROOMS[i + 1].key == key then -- 504
				return i -- 506
			end -- 506
			i = i + 1 -- 504
		end -- 504
	end -- 504
	return 0 -- 509
end -- 509
function enterPlayRoom(idx, source, fresh) -- 512
	if source == nil then -- 512
		source = "debug" -- 512
	end -- 512
	if fresh == nil then -- 512
		fresh = false -- 512
	end -- 512
	current = idx -- 513
	setMode(1) -- 514
	if fe ~= nil then -- 514
		fe.screen = "play" -- 516
	end -- 516
	play = nil -- 518
	if fresh or storyRun == nil then -- 518
		storyRun = createRun(20261124, source, profile) -- 521
	else -- 521
		storyRun.source = source -- 523
	end -- 523
	ensurePlay() -- 525
	local firstPlay = play -- 527
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 527
		firstPlay.phase = "prologue-wake" -- 529
	end -- 529
	flushProfile() -- 531
end -- 531
function pickByIndex(idx, source) -- 534
	if source == nil then -- 534
		source = "debug" -- 534
	end -- 534
	if mode == 2 then -- 534
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 534
			return -- 537
		end -- 537
		current = idx -- 539
		play = nil -- 540
		clock:reset() -- 541
		ensurePlay() -- 542
		return -- 543
	end -- 543
	if idx < 0 or idx >= #ROOMS then -- 543
		return -- 546
	end -- 546
	flushProfile() -- 548
	if storyRun ~= nil then -- 548
		storyRun.source = source -- 550
	end -- 550
	current = idx -- 552
	dirty = true -- 553
	play = nil -- 554
	clock:reset() -- 555
	if mode == 1 then -- 555
		if fe ~= nil then -- 555
			fe.screen = "play" -- 558
		end -- 558
		ensurePlay() -- 560
	end -- 560
end -- 560
function applySize() -- 564
	if root == nil then -- 564
		return -- 566
	end -- 566
	root.size = Size(viewW, viewH) -- 568
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 569
end -- 569
function tick(frameDt) -- 572
	local w = View.size.width -- 573
	local h = View.size.height -- 574
	if w ~= viewW or h ~= viewH then -- 574
		viewW = w -- 576
		viewH = h -- 577
		applySize() -- 578
		dirty = true -- 579
	end -- 579
	if input == nil then -- 579
		return -- 582
	end -- 582
	input:update() -- 584
	if mode == 2 and (run and run.trial) ~= nil then -- 584
		tickCampaign(frameDt) -- 586
		return -- 587
	end -- 587
	if isReleaseBuild() then -- 587
		input.toggleView.pressed = false -- 591
		input.pickRoom = 0 -- 592
		input.tab.pressed = false -- 593
	else -- 593
		if input.toggleView.pressed then -- 593
			input.toggleView.pressed = false -- 597
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 598
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 598
				ensurePlay() -- 600
			end -- 600
		end -- 600
		if input.pickRoom ~= 0 then -- 600
			local idx = input.pickRoom - 1 -- 606
			input.pickRoom = 0 -- 607
			pickByIndex(idx) -- 608
		elseif input.tab.pressed then -- 608
			input.tab.pressed = false -- 610
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 610
				pickByIndex((current + 1) % #ROOMS) -- 612
			end -- 612
		end -- 612
	end -- 612
	if mode == 2 then -- 612
		tickCampaign(frameDt) -- 618
		return -- 619
	end -- 619
	if mode == 1 then -- 619
		tickFrontend(frameDt) -- 622
		return -- 623
	end -- 623
	if dirty then -- 623
		redrawGraybox() -- 626
		dirty = false -- 627
	end -- 627
end -- 627
function registerPlay() -- 632
	local reg = _G.package.loaded -- 633
	reg["watch.play"] = play -- 634
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 635
	reg["watch.room"] = rooms[current + 1].key -- 636
end -- 636
function ensurePlay(resume) -- 640
	if mode == 2 then -- 640
		if run == nil then -- 640
			run = createRun() -- 643
		end -- 643
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 645
	else -- 645
		if storyRun == nil then -- 645
			storyRun = createRun(20261124, "debug", profile) -- 650
		end -- 650
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 652
	end -- 652
	registerPlay() -- 654
	clock:reset() -- 655
	if fe ~= nil and mode == 1 then -- 655
		fe:bindPlay(play, viewW, viewH) -- 657
	end -- 657
end -- 657
function startTrial() -- 661
	current = 0 -- 662
	run = createTrial(App.rand) -- 663
	setMode(2) -- 664
	ensurePlay() -- 665
end -- 665
function tickCampaign(frameDt) -- 668
	if input == nil then -- 668
		return -- 670
	end -- 670
	if play == nil then -- 670
		ensurePlay() -- 673
	end -- 673
	if play == nil then -- 673
		return -- 676
	end -- 676
	local p = play -- 678
	p.aimX = input.mx -- 679
	p.aimY = input.my -- 680
	local trial = run and run.trial -- 682
	if trial ~= nil then -- 682
		local ended = trial.lost or (run and run.finished) == true -- 684
		local pick = input.pickRoom -- 685
		input.pickRoom = 0 -- 686
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 686
			input:consumeEdges() -- 688
			current = 0 -- 689
			play = nil -- 690
			run = nil -- 691
			setMode(1) -- 692
			if fe ~= nil then -- 692
				fe.screen = "title" -- 694
				fe.menus:resetInput() -- 695
			end -- 695
			return -- 697
		end -- 697
		if ended or p.paused and input.retry.pressed then -- 697
			local restart = input.retry.pressed -- 700
			input:consumeEdges() -- 701
			if restart then -- 701
				startTrial() -- 702
			else -- 702
				drawCampaign(p) -- 703
			end -- 703
			return -- 704
		end -- 704
		input.retry.pressed = false -- 706
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 706
			if pick > 0 then -- 706
				p:chooseTalent(pick - 1) -- 708
			end -- 708
			input:consumeEdges() -- 709
			clock:reset() -- 710
			drawCampaign(p) -- 711
			return -- 712
		end -- 712
	end -- 712
	if input.retry.pressed then -- 712
		input.retry.pressed = false -- 717
		input:consumeEdges() -- 718
		play = nil -- 720
		ensurePlay() -- 721
		return -- 722
	end -- 722
	if input.pause.pressed then -- 722
		input.pause.pressed = false -- 725
		p.paused = not p.paused -- 726
		clock:reset() -- 727
		input:consumeEdges() -- 728
	end -- 728
	if p.paused then -- 728
		drawCampaign(p) -- 731
		return -- 732
	end -- 732
	local steps = clock:advance(frameDt) -- 735
	local i = 0 -- 736
	do -- 736
		i = 0 -- 737
		while i < steps do -- 737
			input:beginStep(i == 0) -- 738
			p:update(STEP, input) -- 739
			input:endStep() -- 740
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 740
				break -- 742
			end -- 742
			i = i + 1 -- 737
		end -- 737
	end -- 737
	if p.wantRoom ~= "" then -- 737
		local key = p.wantRoom -- 747
		p.wantRoom = "" -- 748
		local idx = -1 -- 749
		local j = 0 -- 750
		do -- 750
			j = 0 -- 751
			while j < #CAMPAIGN_ROOMS do -- 751
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 751
					idx = j -- 753
				end -- 753
				j = j + 1 -- 751
			end -- 751
		end -- 751
		if idx >= 0 then -- 751
			current = idx -- 757
			play = nil -- 758
			ensurePlay() -- 759
		end -- 759
		return -- 761
	end -- 761
	drawCampaign(p) -- 763
end -- 763
function goalLabel(goal) -- 766
	if goal == "dock_cart" then -- 766
		return "推车入窝并抬闩" -- 768
	end -- 768
	if goal == "raise_latch" then -- 768
		return "抬闩开侧门" -- 771
	end -- 771
	return "到段出口" -- 773
end -- 773
function drawCampaign(p) -- 776
	if campaignDraw == nil then -- 776
		return -- 778
	end -- 778
	local w = viewW -- 780
	local h = viewH -- 781
	p:draw(campaignDraw, w, h) -- 782
	local room = CAMPAIGN_ROOMS[current + 1] -- 783
	local c = room.campaign -- 784
	local r = run -- 785
	local line = room.name -- 786
	if c ~= nil then -- 786
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 788
	end -- 788
	if p.paused then -- 788
		line = line .. "  · 已暂停 Esc 继续" -- 792
	end -- 792
	local trial = r and r.trial -- 794
	if trial ~= nil and r ~= nil then -- 794
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 796
		if p.paused then -- 796
			line = line .. " · 暂停" -- 797
		elseif trial.lost then -- 797
			line = line .. " · 护送失败" -- 798
		elseif r.finished then -- 798
			line = line .. " · 护送完成" -- 799
		elseif #trial.offers > 0 then -- 799
			line = line .. " · 选择本段本领" -- 800
		elseif c ~= nil then -- 800
			line = line .. " · " .. goalLabel(c.goal) -- 801
		end -- 801
	end -- 801
	if campaignHud ~= nil then -- 801
		campaignHud.text = line -- 804
		campaignHud.position = Vec2(24, h - 14) -- 805
		campaignHud.visible = true -- 806
	end -- 806
	if campaignSub ~= nil then -- 806
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 809
		if r ~= nil then -- 809
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 811
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 812
		end -- 812
		if p.flash ~= "" then -- 812
			sub = (sub .. " · ") .. p.flash -- 818
		end -- 818
		if trial ~= nil and r ~= nil then -- 818
			if trial.lost or r.finished then -- 818
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 821
			elseif p.paused then -- 821
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 822
			elseif #trial.offers > 0 then -- 822
				sub = table.concat( -- 823
					__TS__ArrayMap( -- 823
						trial.offers, -- 823
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 823
					), -- 823
					"　" -- 823
				) -- 823
			else -- 823
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 824
			end -- 824
		end -- 824
		campaignSub.text = sub -- 826
		campaignSub.position = Vec2(24, h - 44) -- 827
		campaignSub.visible = true -- 828
	end -- 828
end -- 828
function tickFrontend(frameDt) -- 832
	if fe == nil or input == nil then -- 832
		return -- 834
	end -- 834
	if fe.screen ~= "play" then -- 834
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 839
		input:consumeEdges() -- 840
		if act.type == "trial" then -- 840
			startTrial() -- 842
		elseif act.type == "continue" then -- 842
			if continueOfficialStory() == nil then -- 842
				enterPlayRoom( -- 845
					officialStartIndex(), -- 845
					"official", -- 845
					true -- 845
				) -- 845
			end -- 845
		elseif act.type == "start" then -- 845
			clearSession() -- 849
			refreshTitleSessionFlag() -- 850
			enterPlayRoom( -- 851
				officialStartIndex(), -- 851
				"official", -- 851
				true -- 851
			) -- 851
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 851
			enterPlayRoom(act.roomIndex, "chapter") -- 853
		elseif act.type == "openChapters" then -- 853
			fe.menus:openChapters() -- 855
			fe.screen = "chapters" -- 856
		elseif act.type == "openControls" then -- 856
			fe.menus:resetInput() -- 858
			fe.screen = "controls" -- 859
		elseif act.type == "backTitle" then -- 859
			fe.menus:resetInput() -- 861
			fe.screen = "title" -- 862
		elseif act.type == "backPause" then -- 862
			fe.menus:resetInput() -- 864
			fe.screen = "play" -- 865
		elseif act.type == "quit" then -- 865
			quitGame() -- 867
		end -- 867
		return -- 869
	end -- 869
	if play == nil then -- 869
		ensurePlay() -- 874
	end -- 874
	if play == nil then -- 874
		return -- 877
	end -- 877
	local p = play -- 879
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 881
	if input.retry.pressed and not inTowerEnding then -- 881
		input:consumeEdges() -- 883
		ensurePlay({checkpoint = p.checkpoint}) -- 885
		return -- 886
	end -- 886
	p.aimX = input.mx -- 889
	p.aimY = input.my -- 890
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 890
		p:closeCraftBench() -- 893
		input:consumeEdges() -- 894
		return -- 895
	end -- 895
	if not p.paused and input.pause.pressed then -- 895
		p.paused = true -- 898
		p.aimHold = 0 -- 899
		p.bottleAimX = -1 -- 900
		saveCurrentSession() -- 901
		fe.menus:openPause() -- 902
		input:consumeEdges() -- 903
	end -- 903
	if p.paused then -- 903
		clock:reset() -- 908
		local pauseAct = fe:renderPlay( -- 909
			frameDt, -- 909
			p, -- 909
			input, -- 909
			viewW, -- 909
			viewH -- 909
		) -- 909
		input:consumeEdges() -- 910
		if pauseAct.type == "resume" then -- 910
			p.paused = false -- 912
		elseif pauseAct.type == "retry" then -- 912
			ensurePlay({checkpoint = p.checkpoint}) -- 914
		elseif pauseAct.type == "openChapters" then -- 914
			fe.menus:openChapters(current) -- 916
			fe.screen = "chapters" -- 917
		elseif pauseAct.type == "toggleFullscreen" then -- 917
			toggleFullscreen() -- 919
		elseif pauseAct.type == "quit" then -- 919
			quitGame() -- 921
		elseif pauseAct.type == "toTitle" then -- 921
			saveCurrentSession() -- 923
			refreshTitleSessionFlag() -- 924
			fe.menus:resetInput() -- 925
			fe.screen = "title" -- 926
		end -- 926
		return -- 928
	end -- 928
	local steps = clock:advance(frameDt) -- 931
	local i = 0 -- 932
	do -- 932
		i = 0 -- 933
		while i < steps do -- 933
			input:beginStep(i == 0) -- 934
			p:update(STEP, input) -- 935
			input:endStep() -- 936
			if p.wantRoom ~= "" then -- 936
				break -- 938
			end -- 938
			i = i + 1 -- 933
		end -- 933
	end -- 933
	if p.wantRoom ~= "" then -- 933
		local key = p.wantRoom -- 944
		p.wantRoom = "" -- 945
		local idx = -1 -- 946
		local j = 0 -- 947
		do -- 947
			j = 0 -- 948
			while j < #ROOMS do -- 948
				if ROOMS[j + 1].key == key then -- 948
					idx = j -- 950
				end -- 950
				j = j + 1 -- 948
			end -- 948
		end -- 948
		if idx >= 0 then -- 948
			flushProfile() -- 957
			local leaving = p:drainEvents() -- 958
			if p.restartStory then -- 958
				if storyRun ~= nil and storyRun.source == "official" then -- 958
					clearSession() -- 962
					refreshTitleSessionFlag() -- 963
				end -- 963
				storyRun = createRun(20261124, storyRun == nil and "official" or storyRun.source, profile) -- 965
			end -- 965
			current = idx -- 967
			ensurePlay() -- 968
			local fresh = play -- 969
			if fresh ~= nil then -- 969
				fresh:adoptEvents(leaving) -- 971
			end -- 971
			if not p.restartStory then -- 971
				saveCurrentSession() -- 974
			end -- 974
			clock:reset() -- 976
			dirty = true -- 977
		end -- 977
		return -- 979
	end -- 979
	flushProfile() -- 983
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 983
		clearSession() -- 985
		refreshTitleSessionFlag() -- 986
	elseif p.sessionDirty then -- 986
		saveCurrentSession() -- 988
	end -- 988
	fe:renderPlay( -- 990
		frameDt, -- 990
		p, -- 990
		input, -- 990
		viewW, -- 990
		viewH -- 990
	) -- 990
end -- 990
function redrawGraybox() -- 994
	if draw == nil then -- 994
		return -- 996
	end -- 996
	local w = viewW -- 998
	local h = viewH -- 999
	local room = ROOMS[current + 1] -- 1000
	draw:clear() -- 1002
	draw:drawRect( -- 1003
		Rect(0, h - TOP_H, w, TOP_H), -- 1003
		C_BG -- 1003
	) -- 1003
	draw:drawRect( -- 1004
		Rect(0, 0, w, BOTTOM_H), -- 1004
		C_BG -- 1004
	) -- 1004
	draw:drawSegment( -- 1005
		Vec2(0, h - TOP_H), -- 1005
		Vec2(w, h - TOP_H), -- 1005
		1, -- 1005
		Color(52, 54, 54, 255) -- 1005
	) -- 1005
	draw:drawSegment( -- 1006
		Vec2(0, BOTTOM_H), -- 1006
		Vec2(w, BOTTOM_H), -- 1006
		1, -- 1006
		Color(52, 54, 54, 255) -- 1006
	) -- 1006
	local v = computeView(room, w, h) -- 1008
	renderWorld( -- 1009
		draw, -- 1009
		room, -- 1009
		v, -- 1009
		w, -- 1009
		h -- 1009
	) -- 1009
	local roomTop = v.groundPx + room.height * v.scale -- 1011
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1012
	place( -- 1014
		titleLabel, -- 1014
		48, -- 1014
		h - 40, -- 1014
		0, -- 1014
		1 -- 1014
	) -- 1014
	place( -- 1015
		roomLabel, -- 1015
		48, -- 1015
		h - 96, -- 1015
		0, -- 1015
		1 -- 1015
	) -- 1015
	place( -- 1016
		captionLabel, -- 1016
		48, -- 1016
		h - 140, -- 1016
		0, -- 1016
		1 -- 1016
	) -- 1016
	place( -- 1018
		switchLabel, -- 1018
		48, -- 1018
		40, -- 1018
		0, -- 1018
		0 -- 1018
	) -- 1018
	place( -- 1019
		hintLabel, -- 1019
		48, -- 1019
		84, -- 1019
		0, -- 1019
		0 -- 1019
	) -- 1019
	place( -- 1020
		rulerLabel, -- 1020
		w - 216, -- 1020
		roomTop + 36 + v.scale * 0.5 - 14, -- 1020
		1, -- 1020
		0 -- 1020
	) -- 1020
	place( -- 1021
		standLabel, -- 1021
		48, -- 1021
		roomTop + 40, -- 1021
		0, -- 1021
		0 -- 1021
	) -- 1021
	place( -- 1022
		cartLabel, -- 1022
		48, -- 1022
		roomTop + 92, -- 1022
		0, -- 1022
		0 -- 1022
	) -- 1022
	if roomLabel ~= nil then -- 1022
		roomLabel.text = room.name -- 1025
	end -- 1025
	if captionLabel ~= nil then -- 1025
		captionLabel.text = room.caption -- 1028
	end -- 1028
	if hintLabel ~= nil then -- 1028
		local hintIdx = math.min(current, #HINTS - 1) -- 1031
		local lines = HINTS[hintIdx + 1] -- 1032
		local merged = lines[1] -- 1033
		do -- 1033
			local i = 1 -- 1034
			while i < #lines do -- 1034
				merged = (merged .. "    ") .. lines[i + 1] -- 1035
				i = i + 1 -- 1034
			end -- 1034
		end -- 1034
		hintLabel.text = merged -- 1037
	end -- 1037
	local specs = collectLabels(room, v, w) -- 1040
	local body = {} -- 1041
	local small = {} -- 1042
	do -- 1042
		local i = 0 -- 1043
		while i < #specs do -- 1043
			local s = specs[i + 1] -- 1044
			if s.size >= 24 then -- 1044
				body[#body + 1] = s -- 1046
			else -- 1046
				small[#small + 1] = s -- 1048
			end -- 1048
			i = i + 1 -- 1043
		end -- 1043
	end -- 1043
	applyPool(body, poolBody) -- 1051
	applyPool(small, poolSmall) -- 1052
	if LAYOUT_AUDIT then -- 1052
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1055
	end -- 1055
end -- 1055
function applyPool(specs, pool) -- 1059
	do -- 1059
		local i = 0 -- 1060
		while i < #pool do -- 1060
			local lb = pool[i + 1] -- 1061
			if i < #specs then -- 1061
				local s = specs[i + 1] -- 1063
				lb.text = s.text -- 1064
				lb.position = Vec2(s.x, s.y) -- 1065
				lb.anchor = Vec2(s.ax, s.ay) -- 1066
				lb.color = s.color -- 1067
				lb.visible = true -- 1068
			else -- 1068
				lb.visible = false -- 1070
			end -- 1070
			i = i + 1 -- 1060
		end -- 1060
	end -- 1060
end -- 1060
local FONT = "sarasa-mono-sc-regular" -- 24
LAYOUT_AUDIT = false -- 25
local C_TEXT = Color(236, 236, 232, 255) -- 27
local C_DIM = Color(150, 154, 152, 255) -- 28
local C_ACCENT = Color(226, 186, 84, 255) -- 29
C_BG = Color(17, 18, 19, 255) -- 30
local POOL_BODY = 30 -- 32
local POOL_SMALL = 44 -- 33
TOP_H = 208 -- 34
BOTTOM_H = 216 -- 35
profile = emptySave() -- 53
local profileStatus = "missing" -- 54
local profileDetail = "" -- 55
poolBody = {} -- 60
poolSmall = {} -- 61
current = 0 -- 63
viewW = 0 -- 64
viewH = 0 -- 65
dirty = true -- 66
mode = 1 -- 68
clock = __TS__New(StepClock) -- 72
local function makeGrayboxLabel(text, size, color) -- 201
	if grayboxLayer == nil then -- 201
		return nil -- 203
	end -- 203
	local lb = Label(FONT, size) -- 205
	if lb == nil then -- 205
		return nil -- 207
	end -- 207
	lb.text = text -- 209
	lb.color = color -- 210
	lb:addTo(grayboxLayer) -- 211
	lb.visible = true -- 212
	return lb -- 213
end -- 201
function ____exports.start(parent, initialMode, startScreen) -- 225
	if initialMode == nil then -- 225
		initialMode = 1 -- 225
	end -- 225
	if startScreen == nil then -- 225
		startScreen = "title" -- 225
	end -- 225
	root = parent -- 226
	mode = initialMode -- 227
	grayboxLayer = Node() -- 230
	grayboxLayer.order = 2 -- 231
	grayboxLayer:addTo(parent) -- 232
	draw = DrawNode() -- 234
	draw:addTo(grayboxLayer) -- 235
	campaignLayer = Node() -- 238
	campaignLayer.order = 3 -- 239
	campaignLayer:addTo(parent) -- 240
	campaignDraw = DrawNode() -- 241
	campaignDraw:addTo(campaignLayer) -- 242
	campaignHud = Label(FONT, 24) -- 243
	if campaignHud ~= nil then -- 243
		campaignHud.color = C_TEXT -- 245
		campaignHud.anchor = Vec2(0, 1) -- 246
		campaignHud:addTo(campaignLayer) -- 247
		campaignHud.visible = true -- 248
	end -- 248
	campaignSub = Label(FONT, 20) -- 250
	if campaignSub ~= nil then -- 250
		campaignSub.color = C_ACCENT -- 252
		campaignSub.anchor = Vec2(0, 1) -- 253
		campaignSub:addTo(campaignLayer) -- 254
		campaignSub.visible = true -- 255
	end -- 255
	campaignLayer.visible = mode == 2 -- 257
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 259
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 260
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 261
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 262
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 263
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 264
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 265
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 266
	do -- 266
		local i = 0 -- 268
		while i < POOL_BODY do -- 268
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 269
			if lb ~= nil then -- 269
				poolBody[#poolBody + 1] = lb -- 271
			end -- 271
			i = i + 1 -- 268
		end -- 268
	end -- 268
	do -- 268
		local i = 0 -- 274
		while i < POOL_SMALL do -- 274
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 275
			if lb ~= nil then -- 275
				poolSmall[#poolSmall + 1] = lb -- 277
			end -- 277
			i = i + 1 -- 274
		end -- 274
	end -- 274
	if mode == 1 then -- 274
		local loaded = loadSave() -- 284
		profile = loaded.state -- 285
		profileStatus = loaded.status -- 286
		profileDetail = loaded.detail -- 287
	end -- 287
	fe = __TS__New(WatchFrontend, parent) -- 289
	fe.screen = startScreen -- 290
	refreshTitleSessionFlag() -- 291
	grayboxLayer.visible = mode == 0 -- 292
	fe:setVisible(mode == 1) -- 293
	if campaignLayer ~= nil then -- 293
		campaignLayer.visible = mode == 2 -- 295
	end -- 295
	input = __TS__New(Input) -- 298
	parent:gslot( -- 301
		"AppEvent", -- 301
		function(eventType) -- 301
			if eventType == "Quit" or eventType == "Shutdown" or eventType == "WillEnterBackground" then -- 301
				flushProfile() -- 303
				saveCurrentSession() -- 304
			end -- 304
		end -- 301
	) -- 301
	parent:onKeyDown(function(key) -- 309
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 309
			toggleFullscreen() -- 312
			return -- 313
		end -- 313
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 313
			play:toggleArtifactWeapon() -- 316
			return -- 317
		end -- 317
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or play ~= nil and play.paused) then -- 317
			fe.menus:onKeyEvent(key) -- 320
		end -- 320
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" or mode == 2) then -- 320
			if key == "E" then -- 320
				input.interact.pressed = true -- 324
			elseif key == "Space" then -- 324
				input.jump.pressed = true -- 326
			elseif key == "Escape" then -- 326
				input.pause.pressed = true -- 328
			elseif key == "R" then -- 328
				input.retry.pressed = true -- 330
			end -- 330
		end -- 330
		if mode == 2 and (run and run.trial) ~= nil then -- 330
			return -- 333
		end -- 333
		if isReleaseBuild() then -- 333
			return -- 334
		end -- 334
		if key == "F1" then -- 334
			if mode == 2 then -- 334
				current = 0 -- 337
				play = nil -- 338
				ensurePlay() -- 339
			else -- 339
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 341
			end -- 341
		elseif key == "F2" then -- 341
			setMode(0) -- 344
		elseif key == "1" then -- 344
			pickByIndex(0) -- 346
		elseif key == "2" then -- 346
			pickByIndex(1) -- 348
		elseif key == "3" then -- 348
			pickByIndex(2) -- 350
		elseif key == "4" then -- 350
			pickByIndex(3) -- 352
		elseif key == "5" then -- 352
			pickByIndex(4) -- 354
		elseif key == "6" then -- 354
			pickByIndex(5) -- 356
		elseif key == "7" then -- 356
			pickByIndex(6) -- 358
		elseif key == "8" then -- 358
			pickByIndex(7) -- 360
		end -- 360
	end) -- 309
	viewW = View.size.width -- 364
	viewH = View.size.height -- 365
	applySize() -- 366
	local reg = _G.package.loaded -- 369
	reg["watch.input"] = input -- 370
	reg["watch.fe"] = { -- 371
		setScreen = function(sc) -- 372
			if fe == nil then -- 372
				return -- 374
			end -- 374
			setMode(1) -- 376
			fe.screen = sc -- 377
			if sc == "chapters" then -- 377
				fe.menus:openChapters() -- 379
			else -- 379
				fe.menus:resetInput() -- 381
			end -- 381
			if sc == "play" then -- 381
				ensurePlay() -- 384
			end -- 384
		end, -- 372
		jumpRoom = function(keyOrIdx) -- 387
			local idx = -1 -- 388
			if type(keyOrIdx) == "number" then -- 388
				idx = keyOrIdx -- 390
			else -- 390
				local k = 0 -- 392
				do -- 392
					k = 0 -- 393
					while k < #ROOMS do -- 393
						if ROOMS[k + 1].key == keyOrIdx then -- 393
							idx = k -- 395
						end -- 395
						k = k + 1 -- 393
					end -- 393
				end -- 393
			end -- 393
			if idx >= 0 and idx < #ROOMS then -- 393
				enterPlayRoom(idx, "debug") -- 400
			end -- 400
		end, -- 387
		getPlay = function() return play end, -- 403
		getFrontend = function() return fe end, -- 404
		startStory = function() -- 406
			enterPlayRoom( -- 407
				officialStartIndex(), -- 407
				"official", -- 407
				true -- 407
			) -- 407
			return play -- 408
		end, -- 406
		previewChapter = function(idx) -- 411
			enterPlayRoom(idx, "chapter") -- 412
			return play -- 413
		end, -- 411
		getStoryRun = function() return storyRun end, -- 415
		getProfilePending = function() return profilePending() end, -- 416
		flushProfileNow = function() return flushProfile() end, -- 417
		getProfile = function() return profile end, -- 419
		getProfileStatus = function() return profileStatus end, -- 420
		getProfileDetail = function() return profileDetail end, -- 421
		useTestSave = function(name) -- 422
			setSaveFile(name) -- 423
			setSessionFile(name == "" and "" or name .. ".session") -- 424
			clearProfilePending() -- 425
			local loaded = loadSave() -- 426
			profile = loaded.state -- 427
			profileStatus = loaded.status -- 428
			profileDetail = loaded.detail -- 429
			refreshTitleSessionFlag() -- 430
		end, -- 422
		useTestSession = function(name) -- 432
			setSessionFile(name) -- 433
			refreshTitleSessionFlag() -- 434
		end, -- 432
		getSessionFile = getSessionFile, -- 436
		hasSessionSave = hasSessionSave, -- 437
		saveSessionNow = function() return saveCurrentSession() end, -- 438
		clearSessionNow = function() -- 439
			local ok = clearSession() -- 440
			refreshTitleSessionFlag() -- 441
			return ok -- 442
		end, -- 439
		continueStory = function() return continueOfficialStory() end, -- 444
		saveNow = function() return saveSave(profile) end, -- 445
		getSaveFile = getSaveFile, -- 446
		isRelease = function() return isReleaseBuild() end, -- 447
		getReleaseVersion = function() -- 448
			local ____opt_7 = getReleaseConfig() -- 448
			return ____opt_7 and ____opt_7.version or "dev" -- 448
		end, -- 448
		toggleFullscreen = function() return toggleFullscreen() end, -- 449
		quitGame = function() return quitGame() end -- 450
	} -- 450
	if mode == 1 and startScreen == "play" then -- 450
		ensurePlay() -- 454
	end -- 454
	parent:schedule(function(frameDt) -- 457
		tick(frameDt) -- 458
		return false -- 459
	end) -- 457
end -- 225
return ____exports -- 225