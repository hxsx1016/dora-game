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
local createStoryTalents = ____run.createStoryTalents -- 16
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
	if s.campaignRoute ~= nil then -- 183
		storyRun.route = s.campaignRoute -- 187
	end -- 187
	if s.joined ~= nil then -- 187
		storyRun.joined = s.joined -- 190
	end -- 190
	if s.c1Latch ~= nil then -- 190
		storyRun.c1Latch = s.c1Latch -- 193
	end -- 193
	if s.c2Latch ~= nil then -- 193
		storyRun.c2Latch = s.c2Latch -- 196
	end -- 196
	local stTalents = createStoryTalents(s.seed) -- 198
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 198
		stTalents.randomState = s.talentSeed -- 200
	end -- 200
	stTalents.room = s.talentRoom or "" -- 202
	stTalents.ranks.vitality = s.talentVitality or 0 -- 203
	stTalents.ranks.reload = s.talentReload or 0 -- 204
	stTalents.ranks.guard = s.talentGuard or 0 -- 205
	stTalents.ranks.craft = s.talentCraft or 0 -- 206
	if s.talentOffers ~= nil then -- 206
		do -- 206
			k = 0 -- 208
			while k < #s.talentOffers do -- 208
				local t = s.talentOffers[k + 1] -- 209
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 209
					local ____stTalents_offers_5 = stTalents.offers -- 209
					____stTalents_offers_5[#____stTalents_offers_5 + 1] = t -- 211
				end -- 211
				k = k + 1 -- 208
			end -- 208
		end -- 208
	end -- 208
	storyRun.story.talents = stTalents -- 215
	current = idx -- 216
	setMode(1) -- 217
	if fe ~= nil then -- 217
		fe.screen = "play" -- 219
	end -- 219
	play = nil -- 221
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 222
	local cur = play -- 223
	if cur ~= nil and s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 223
		cur.cartAxle = s.cartAxle -- 225
		cur.cartDocked = s.cartDocked -- 226
	end -- 226
	return play -- 228
end -- 228
function place(lb, x, y, ax, ay) -- 246
	if lb == nil then -- 246
		return -- 248
	end -- 248
	lb.position = Vec2(x, y) -- 250
	lb.anchor = Vec2(ax, ay) -- 251
	lb.visible = true -- 252
end -- 252
function setMode(nextMode) -- 508
	mode = nextMode -- 509
	if grayboxLayer ~= nil then -- 509
		grayboxLayer.visible = mode == 0 -- 511
	end -- 511
	if fe ~= nil then -- 511
		fe:setVisible(mode == 1) -- 514
	end -- 514
	if campaignLayer ~= nil then -- 514
		campaignLayer.visible = mode == 2 -- 517
	end -- 517
	dirty = true -- 519
	clock:reset() -- 520
end -- 520
function flushProfile() -- 527
	local cur = play -- 528
	if cur ~= nil and cur.archiveDirty then -- 528
		cur.archiveDirty = false -- 530
		markProfilePending(profile) -- 531
	end -- 531
	local ok = flushSaveProfile() -- 533
	if not ok and cur ~= nil then -- 533
		cur.archiveDirty = true -- 535
	end -- 535
	return ok -- 537
end -- 537
function officialStartIndex() -- 541
	local mp = profile.museumPhase -- 542
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 543
	return inMuseum and roomIndexByKey("museum") or 0 -- 544
end -- 544
function roomIndexByKey(key) -- 547
	local i = 0 -- 548
	do -- 548
		i = 0 -- 549
		while i < #ROOMS do -- 549
			if ROOMS[i + 1].key == key then -- 549
				return i -- 551
			end -- 551
			i = i + 1 -- 549
		end -- 549
	end -- 549
	return 0 -- 554
end -- 554
function enterPlayRoom(idx, source, fresh) -- 557
	if source == nil then -- 557
		source = "debug" -- 557
	end -- 557
	if fresh == nil then -- 557
		fresh = false -- 557
	end -- 557
	current = idx -- 558
	setMode(1) -- 559
	if fe ~= nil then -- 559
		fe.screen = "play" -- 561
	end -- 561
	play = nil -- 563
	if fresh or storyRun == nil then -- 563
		storyRun = createRun(20261124, source, profile) -- 566
	else -- 566
		storyRun.source = source -- 568
	end -- 568
	ensurePlay() -- 570
	local firstPlay = play -- 572
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 572
		firstPlay.phase = "prologue-wake" -- 574
	end -- 574
	flushProfile() -- 576
end -- 576
function pickByIndex(idx, source) -- 579
	if source == nil then -- 579
		source = "debug" -- 579
	end -- 579
	if mode == 2 then -- 579
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 579
			return -- 582
		end -- 582
		current = idx -- 584
		play = nil -- 585
		clock:reset() -- 586
		ensurePlay() -- 587
		return -- 588
	end -- 588
	if idx < 0 or idx >= #ROOMS then -- 588
		return -- 591
	end -- 591
	flushProfile() -- 593
	if storyRun ~= nil then -- 593
		storyRun.source = source -- 595
	end -- 595
	current = idx -- 597
	dirty = true -- 598
	play = nil -- 599
	clock:reset() -- 600
	if mode == 1 then -- 600
		if fe ~= nil then -- 600
			fe.screen = "play" -- 603
		end -- 603
		ensurePlay() -- 605
	end -- 605
end -- 605
function applySize() -- 609
	if root == nil then -- 609
		return -- 611
	end -- 611
	root.size = Size(viewW, viewH) -- 613
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 614
end -- 614
function tick(frameDt) -- 617
	local w = View.size.width -- 618
	local h = View.size.height -- 619
	if w ~= viewW or h ~= viewH then -- 619
		viewW = w -- 621
		viewH = h -- 622
		applySize() -- 623
		dirty = true -- 624
	end -- 624
	if input == nil then -- 624
		return -- 627
	end -- 627
	input:update() -- 629
	if mode == 2 and (run and run.trial) ~= nil then -- 629
		tickCampaign(frameDt) -- 631
		return -- 632
	end -- 632
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 632
		play:chooseTalent(input.pickRoom - 1) -- 638
		input.pickRoom = 0 -- 639
	end -- 639
	if isReleaseBuild() then -- 639
		input.toggleView.pressed = false -- 643
		input.pickRoom = 0 -- 644
		input.tab.pressed = false -- 645
	else -- 645
		if input.toggleView.pressed then -- 645
			input.toggleView.pressed = false -- 649
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 650
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 650
				ensurePlay() -- 652
			end -- 652
		end -- 652
		if input.pickRoom ~= 0 then -- 652
			local idx = input.pickRoom - 1 -- 658
			input.pickRoom = 0 -- 659
			pickByIndex(idx) -- 660
		elseif input.tab.pressed then -- 660
			input.tab.pressed = false -- 662
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 662
				pickByIndex((current + 1) % #ROOMS) -- 664
			end -- 664
		end -- 664
	end -- 664
	if mode == 2 then -- 664
		tickCampaign(frameDt) -- 670
		return -- 671
	end -- 671
	if mode == 1 then -- 671
		tickFrontend(frameDt) -- 674
		return -- 675
	end -- 675
	if dirty then -- 675
		redrawGraybox() -- 678
		dirty = false -- 679
	end -- 679
end -- 679
function registerPlay() -- 684
	local reg = _G.package.loaded -- 685
	reg["watch.play"] = play -- 686
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 687
	reg["watch.room"] = rooms[current + 1].key -- 688
end -- 688
function ensurePlay(resume) -- 692
	if mode == 2 then -- 692
		if run == nil then -- 692
			run = createRun() -- 695
		end -- 695
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 697
	else -- 697
		if storyRun == nil then -- 697
			storyRun = createRun(20261124, "debug", profile) -- 702
		end -- 702
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 704
	end -- 704
	registerPlay() -- 706
	clock:reset() -- 707
	if fe ~= nil and mode == 1 then -- 707
		fe:bindPlay(play, viewW, viewH) -- 709
	end -- 709
end -- 709
function startTrial() -- 713
	current = 0 -- 714
	run = createTrial(App.rand) -- 715
	setMode(2) -- 716
	ensurePlay() -- 717
end -- 717
function tickCampaign(frameDt) -- 720
	if input == nil then -- 720
		return -- 722
	end -- 722
	if play == nil then -- 722
		ensurePlay() -- 725
	end -- 725
	if play == nil then -- 725
		return -- 728
	end -- 728
	local p = play -- 730
	p.aimX = input.mx -- 731
	p.aimY = input.my -- 732
	local trial = run and run.trial -- 734
	if trial ~= nil then -- 734
		local ended = trial.lost or (run and run.finished) == true -- 736
		local pick = input.pickRoom -- 737
		input.pickRoom = 0 -- 738
		if ended and input.pause.pressed or p.paused and input.interact.pressed then -- 738
			input:consumeEdges() -- 740
			current = 0 -- 741
			play = nil -- 742
			run = nil -- 743
			setMode(1) -- 744
			if fe ~= nil then -- 744
				fe.screen = "title" -- 746
				fe.menus:resetInput() -- 747
			end -- 747
			return -- 749
		end -- 749
		if ended or p.paused and input.retry.pressed then -- 749
			local restart = input.retry.pressed -- 752
			input:consumeEdges() -- 753
			if restart then -- 753
				startTrial() -- 754
			else -- 754
				drawCampaign(p) -- 755
			end -- 755
			return -- 756
		end -- 756
		input.retry.pressed = false -- 758
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 758
			if pick > 0 then -- 758
				p:chooseTalent(pick - 1) -- 760
			end -- 760
			input:consumeEdges() -- 761
			clock:reset() -- 762
			drawCampaign(p) -- 763
			return -- 764
		end -- 764
	end -- 764
	if input.retry.pressed then -- 764
		input.retry.pressed = false -- 769
		input:consumeEdges() -- 770
		play = nil -- 772
		ensurePlay() -- 773
		return -- 774
	end -- 774
	if input.pause.pressed then -- 774
		input.pause.pressed = false -- 777
		p.paused = not p.paused -- 778
		clock:reset() -- 779
		input:consumeEdges() -- 780
	end -- 780
	if p.paused then -- 780
		drawCampaign(p) -- 783
		return -- 784
	end -- 784
	local steps = clock:advance(frameDt) -- 787
	local i = 0 -- 788
	do -- 788
		i = 0 -- 789
		while i < steps do -- 789
			input:beginStep(i == 0) -- 790
			p:update(STEP, input) -- 791
			input:endStep() -- 792
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 792
				break -- 794
			end -- 794
			i = i + 1 -- 789
		end -- 789
	end -- 789
	if p.wantRoom ~= "" then -- 789
		local key = p.wantRoom -- 799
		p.wantRoom = "" -- 800
		local idx = -1 -- 801
		local j = 0 -- 802
		do -- 802
			j = 0 -- 803
			while j < #CAMPAIGN_ROOMS do -- 803
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 803
					idx = j -- 805
				end -- 805
				j = j + 1 -- 803
			end -- 803
		end -- 803
		if idx >= 0 then -- 803
			current = idx -- 809
			play = nil -- 810
			ensurePlay() -- 811
		end -- 811
		return -- 813
	end -- 813
	drawCampaign(p) -- 815
end -- 815
function goalLabel(goal) -- 818
	if goal == "dock_cart" then -- 818
		return "推车入窝并抬闩" -- 820
	end -- 820
	if goal == "raise_latch" then -- 820
		return "抬闩开侧门" -- 823
	end -- 823
	return "到段出口" -- 825
end -- 825
function drawCampaign(p) -- 828
	if campaignDraw == nil then -- 828
		return -- 830
	end -- 830
	local w = viewW -- 832
	local h = viewH -- 833
	p:draw(campaignDraw, w, h) -- 834
	local room = CAMPAIGN_ROOMS[current + 1] -- 835
	local c = room.campaign -- 836
	local r = run -- 837
	local line = room.name -- 838
	if c ~= nil then -- 838
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 840
	end -- 840
	if p.paused then -- 840
		line = line .. "  · 已暂停 Esc 继续" -- 844
	end -- 844
	local trial = r and r.trial -- 846
	if trial ~= nil and r ~= nil then -- 846
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 848
		if p.paused then -- 848
			line = line .. " · 暂停" -- 849
		elseif trial.lost then -- 849
			line = line .. " · 护送失败" -- 850
		elseif r.finished then -- 850
			line = line .. " · 护送完成" -- 851
		elseif #trial.offers > 0 then -- 851
			line = line .. " · 选择本段本领" -- 852
		elseif c ~= nil then -- 852
			line = line .. " · " .. goalLabel(c.goal) -- 853
		end -- 853
	end -- 853
	if campaignHud ~= nil then -- 853
		campaignHud.text = line -- 856
		campaignHud.position = Vec2(24, h - 14) -- 857
		campaignHud.visible = true -- 858
	end -- 858
	if campaignSub ~= nil then -- 858
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 861
		if r ~= nil then -- 861
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 863
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 864
		end -- 864
		if p.flash ~= "" then -- 864
			sub = (sub .. " · ") .. p.flash -- 870
		end -- 870
		if trial ~= nil and r ~= nil then -- 870
			if trial.lost or r.finished then -- 870
				sub = ("种子 " .. tostring(r.seed)) .. " · R 再开一局 · Esc 返回标题" -- 873
			elseif p.paused then -- 873
				sub = ("种子 " .. tostring(r.seed)) .. " · Esc 继续 · R 重新开局 · E 返回标题" -- 874
			elseif #trial.offers > 0 then -- 874
				sub = table.concat( -- 875
					__TS__ArrayMap( -- 875
						trial.offers, -- 875
						function(____, talent, index) return (tostring(index + 1) .. " ") .. talentNames[talent] end -- 875
					), -- 875
					"　" -- 875
				) -- 875
			else -- 875
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 876
			end -- 876
		end -- 876
		campaignSub.text = sub -- 878
		campaignSub.position = Vec2(24, h - 44) -- 879
		campaignSub.visible = true -- 880
	end -- 880
end -- 880
function tickFrontend(frameDt) -- 884
	if fe == nil or input == nil then -- 884
		return -- 886
	end -- 886
	if fe.screen ~= "play" then -- 886
		local act = fe:renderMenu(frameDt, input, viewW, viewH) -- 891
		input:consumeEdges() -- 892
		if act.type == "trial" then -- 892
			startTrial() -- 894
		elseif act.type == "continue" then -- 894
			if continueOfficialStory() == nil then -- 894
				enterPlayRoom( -- 897
					officialStartIndex(), -- 897
					"official", -- 897
					true -- 897
				) -- 897
			end -- 897
		elseif act.type == "start" then -- 897
			clearSession() -- 901
			refreshTitleSessionFlag() -- 902
			enterPlayRoom( -- 903
				officialStartIndex(), -- 903
				"official", -- 903
				true -- 903
			) -- 903
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 903
			enterPlayRoom(act.roomIndex, "chapter") -- 905
		elseif act.type == "openChapters" then -- 905
			fe.menus:openChapters() -- 907
			fe.screen = "chapters" -- 908
		elseif act.type == "openControls" then -- 908
			fe.menus:resetInput() -- 910
			fe.screen = "controls" -- 911
		elseif act.type == "backTitle" then -- 911
			fe.menus:resetInput() -- 913
			fe.screen = "title" -- 914
		elseif act.type == "backPause" then -- 914
			fe.menus:resetInput() -- 916
			fe.screen = "play" -- 917
		elseif act.type == "quit" then -- 917
			quitGame() -- 919
		end -- 919
		return -- 921
	end -- 921
	if play == nil then -- 921
		ensurePlay() -- 926
	end -- 926
	if play == nil then -- 926
		return -- 929
	end -- 929
	local p = play -- 931
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 933
	if input.retry.pressed and not inTowerEnding then -- 933
		input:consumeEdges() -- 935
		ensurePlay({checkpoint = p.checkpoint}) -- 937
		return -- 938
	end -- 938
	p.aimX = input.mx -- 941
	p.aimY = input.my -- 942
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() > 0 and input.inside and input.fire.pressed and fe:tryPickTalentAtPointer(p, input, viewW, viewH) then -- 942
		input.fire.pressed = false -- 946
	end -- 946
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 946
		p:closeCraftBench() -- 950
		input:consumeEdges() -- 951
		return -- 952
	end -- 952
	if not p.paused and input.pause.pressed then -- 952
		p.paused = true -- 955
		p.aimHold = 0 -- 956
		p.bottleAimX = -1 -- 957
		saveCurrentSession() -- 958
		fe.menus:openPause() -- 959
		input:consumeEdges() -- 960
	end -- 960
	if p.paused then -- 960
		clock:reset() -- 965
		local pauseAct = fe:renderPlay( -- 966
			frameDt, -- 966
			p, -- 966
			input, -- 966
			viewW, -- 966
			viewH -- 966
		) -- 966
		input:consumeEdges() -- 967
		if pauseAct.type == "resume" then -- 967
			p.paused = false -- 969
		elseif pauseAct.type == "retry" then -- 969
			ensurePlay({checkpoint = p.checkpoint}) -- 971
		elseif pauseAct.type == "openChapters" then -- 971
			fe.menus:openChapters(current) -- 973
			fe.screen = "chapters" -- 974
		elseif pauseAct.type == "toggleFullscreen" then -- 974
			toggleFullscreen() -- 976
		elseif pauseAct.type == "quit" then -- 976
			quitGame() -- 978
		elseif pauseAct.type == "toTitle" then -- 978
			saveCurrentSession() -- 980
			refreshTitleSessionFlag() -- 981
			fe.menus:resetInput() -- 982
			fe.screen = "title" -- 983
		end -- 983
		return -- 985
	end -- 985
	local steps = clock:advance(frameDt) -- 988
	local i = 0 -- 989
	do -- 989
		i = 0 -- 990
		while i < steps do -- 990
			input:beginStep(i == 0) -- 991
			p:update(STEP, input) -- 992
			input:endStep() -- 993
			if p.wantRoom ~= "" then -- 993
				break -- 995
			end -- 995
			i = i + 1 -- 990
		end -- 990
	end -- 990
	if p.wantRoom ~= "" then -- 990
		local key = p.wantRoom -- 1001
		p.wantRoom = "" -- 1002
		local idx = -1 -- 1003
		local j = 0 -- 1004
		do -- 1004
			j = 0 -- 1005
			while j < #ROOMS do -- 1005
				if ROOMS[j + 1].key == key then -- 1005
					idx = j -- 1007
				end -- 1007
				j = j + 1 -- 1005
			end -- 1005
		end -- 1005
		if idx >= 0 then -- 1005
			flushProfile() -- 1014
			local leaving = p:drainEvents() -- 1015
			if p.restartStory then -- 1015
				if storyRun ~= nil and storyRun.source == "official" then -- 1015
					clearSession() -- 1019
					refreshTitleSessionFlag() -- 1020
				end -- 1020
				storyRun = createRun(20261124, storyRun == nil and "official" or storyRun.source, profile) -- 1022
			end -- 1022
			current = idx -- 1024
			ensurePlay() -- 1025
			local fresh = play -- 1026
			if fresh ~= nil then -- 1026
				fresh:adoptEvents(leaving) -- 1028
			end -- 1028
			if not p.restartStory then -- 1028
				saveCurrentSession() -- 1031
			end -- 1031
			clock:reset() -- 1033
			dirty = true -- 1034
		end -- 1034
		return -- 1036
	end -- 1036
	flushProfile() -- 1040
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1040
		clearSession() -- 1042
		refreshTitleSessionFlag() -- 1043
	elseif p.sessionDirty then -- 1043
		saveCurrentSession() -- 1045
	end -- 1045
	fe:renderPlay( -- 1047
		frameDt, -- 1047
		p, -- 1047
		input, -- 1047
		viewW, -- 1047
		viewH -- 1047
	) -- 1047
end -- 1047
function redrawGraybox() -- 1051
	if draw == nil then -- 1051
		return -- 1053
	end -- 1053
	local w = viewW -- 1055
	local h = viewH -- 1056
	local room = ROOMS[current + 1] -- 1057
	draw:clear() -- 1059
	draw:drawRect( -- 1060
		Rect(0, h - TOP_H, w, TOP_H), -- 1060
		C_BG -- 1060
	) -- 1060
	draw:drawRect( -- 1061
		Rect(0, 0, w, BOTTOM_H), -- 1061
		C_BG -- 1061
	) -- 1061
	draw:drawSegment( -- 1062
		Vec2(0, h - TOP_H), -- 1062
		Vec2(w, h - TOP_H), -- 1062
		1, -- 1062
		Color(52, 54, 54, 255) -- 1062
	) -- 1062
	draw:drawSegment( -- 1063
		Vec2(0, BOTTOM_H), -- 1063
		Vec2(w, BOTTOM_H), -- 1063
		1, -- 1063
		Color(52, 54, 54, 255) -- 1063
	) -- 1063
	local v = computeView(room, w, h) -- 1065
	renderWorld( -- 1066
		draw, -- 1066
		room, -- 1066
		v, -- 1066
		w, -- 1066
		h -- 1066
	) -- 1066
	local roomTop = v.groundPx + room.height * v.scale -- 1068
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1069
	place( -- 1071
		titleLabel, -- 1071
		48, -- 1071
		h - 40, -- 1071
		0, -- 1071
		1 -- 1071
	) -- 1071
	place( -- 1072
		roomLabel, -- 1072
		48, -- 1072
		h - 96, -- 1072
		0, -- 1072
		1 -- 1072
	) -- 1072
	place( -- 1073
		captionLabel, -- 1073
		48, -- 1073
		h - 140, -- 1073
		0, -- 1073
		1 -- 1073
	) -- 1073
	place( -- 1075
		switchLabel, -- 1075
		48, -- 1075
		40, -- 1075
		0, -- 1075
		0 -- 1075
	) -- 1075
	place( -- 1076
		hintLabel, -- 1076
		48, -- 1076
		84, -- 1076
		0, -- 1076
		0 -- 1076
	) -- 1076
	place( -- 1077
		rulerLabel, -- 1077
		w - 216, -- 1077
		roomTop + 36 + v.scale * 0.5 - 14, -- 1077
		1, -- 1077
		0 -- 1077
	) -- 1077
	place( -- 1078
		standLabel, -- 1078
		48, -- 1078
		roomTop + 40, -- 1078
		0, -- 1078
		0 -- 1078
	) -- 1078
	place( -- 1079
		cartLabel, -- 1079
		48, -- 1079
		roomTop + 92, -- 1079
		0, -- 1079
		0 -- 1079
	) -- 1079
	if roomLabel ~= nil then -- 1079
		roomLabel.text = room.name -- 1082
	end -- 1082
	if captionLabel ~= nil then -- 1082
		captionLabel.text = room.caption -- 1085
	end -- 1085
	if hintLabel ~= nil then -- 1085
		local hintIdx = math.min(current, #HINTS - 1) -- 1088
		local lines = HINTS[hintIdx + 1] -- 1089
		local merged = lines[1] -- 1090
		do -- 1090
			local i = 1 -- 1091
			while i < #lines do -- 1091
				merged = (merged .. "    ") .. lines[i + 1] -- 1092
				i = i + 1 -- 1091
			end -- 1091
		end -- 1091
		hintLabel.text = merged -- 1094
	end -- 1094
	local specs = collectLabels(room, v, w) -- 1097
	local body = {} -- 1098
	local small = {} -- 1099
	do -- 1099
		local i = 0 -- 1100
		while i < #specs do -- 1100
			local s = specs[i + 1] -- 1101
			if s.size >= 24 then -- 1101
				body[#body + 1] = s -- 1103
			else -- 1103
				small[#small + 1] = s -- 1105
			end -- 1105
			i = i + 1 -- 1100
		end -- 1100
	end -- 1100
	applyPool(body, poolBody) -- 1108
	applyPool(small, poolSmall) -- 1109
	if LAYOUT_AUDIT then -- 1109
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1112
	end -- 1112
end -- 1112
function applyPool(specs, pool) -- 1116
	do -- 1116
		local i = 0 -- 1117
		while i < #pool do -- 1117
			local lb = pool[i + 1] -- 1118
			if i < #specs then -- 1118
				local s = specs[i + 1] -- 1120
				lb.text = s.text -- 1121
				lb.position = Vec2(s.x, s.y) -- 1122
				lb.anchor = Vec2(s.ax, s.ay) -- 1123
				lb.color = s.color -- 1124
				lb.visible = true -- 1125
			else -- 1125
				lb.visible = false -- 1127
			end -- 1127
			i = i + 1 -- 1117
		end -- 1117
	end -- 1117
end -- 1117
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
local function makeGrayboxLabel(text, size, color) -- 231
	if grayboxLayer == nil then -- 231
		return nil -- 233
	end -- 233
	local lb = Label(FONT, size) -- 235
	if lb == nil then -- 235
		return nil -- 237
	end -- 237
	lb.text = text -- 239
	lb.color = color -- 240
	lb:addTo(grayboxLayer) -- 241
	lb.visible = true -- 242
	return lb -- 243
end -- 231
function ____exports.start(parent, initialMode, startScreen) -- 255
	if initialMode == nil then -- 255
		initialMode = 1 -- 255
	end -- 255
	if startScreen == nil then -- 255
		startScreen = "title" -- 255
	end -- 255
	root = parent -- 256
	mode = initialMode -- 257
	grayboxLayer = Node() -- 260
	grayboxLayer.order = 2 -- 261
	grayboxLayer:addTo(parent) -- 262
	draw = DrawNode() -- 264
	draw:addTo(grayboxLayer) -- 265
	campaignLayer = Node() -- 268
	campaignLayer.order = 3 -- 269
	campaignLayer:addTo(parent) -- 270
	campaignDraw = DrawNode() -- 271
	campaignDraw:addTo(campaignLayer) -- 272
	campaignHud = Label(FONT, 24) -- 273
	if campaignHud ~= nil then -- 273
		campaignHud.color = C_TEXT -- 275
		campaignHud.anchor = Vec2(0, 1) -- 276
		campaignHud:addTo(campaignLayer) -- 277
		campaignHud.visible = true -- 278
	end -- 278
	campaignSub = Label(FONT, 20) -- 280
	if campaignSub ~= nil then -- 280
		campaignSub.color = C_ACCENT -- 282
		campaignSub.anchor = Vec2(0, 1) -- 283
		campaignSub:addTo(campaignLayer) -- 284
		campaignSub.visible = true -- 285
	end -- 285
	campaignLayer.visible = mode == 2 -- 287
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 289
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 290
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 291
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 292
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 293
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 294
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 295
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 296
	do -- 296
		local i = 0 -- 298
		while i < POOL_BODY do -- 298
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 299
			if lb ~= nil then -- 299
				poolBody[#poolBody + 1] = lb -- 301
			end -- 301
			i = i + 1 -- 298
		end -- 298
	end -- 298
	do -- 298
		local i = 0 -- 304
		while i < POOL_SMALL do -- 304
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 305
			if lb ~= nil then -- 305
				poolSmall[#poolSmall + 1] = lb -- 307
			end -- 307
			i = i + 1 -- 304
		end -- 304
	end -- 304
	if mode == 1 then -- 304
		local loaded = loadSave() -- 314
		profile = loaded.state -- 315
		profileStatus = loaded.status -- 316
		profileDetail = loaded.detail -- 317
	end -- 317
	fe = __TS__New(WatchFrontend, parent) -- 319
	fe.screen = startScreen -- 320
	refreshTitleSessionFlag() -- 321
	grayboxLayer.visible = mode == 0 -- 322
	fe:setVisible(mode == 1) -- 323
	if campaignLayer ~= nil then -- 323
		campaignLayer.visible = mode == 2 -- 325
	end -- 325
	input = __TS__New(Input) -- 328
	parent:gslot( -- 331
		"AppEvent", -- 331
		function(eventType) -- 331
			if eventType == "Quit" or eventType == "Shutdown" or eventType == "WillEnterBackground" then -- 331
				flushProfile() -- 333
				saveCurrentSession() -- 334
			end -- 334
		end -- 331
	) -- 331
	parent:onKeyDown(function(key) -- 339
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 339
			toggleFullscreen() -- 342
			return -- 343
		end -- 343
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 343
			play:toggleArtifactWeapon() -- 346
			return -- 347
		end -- 347
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 then -- 347
			if key == "1" then -- 347
				play:chooseTalent(0) -- 352
				return -- 353
			end -- 353
			if key == "2" then -- 353
				play:chooseTalent(1) -- 356
				return -- 357
			end -- 357
			if key == "3" then -- 357
				play:chooseTalent(2) -- 360
				return -- 361
			end -- 361
		end -- 361
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or play ~= nil and play.paused) then -- 361
			fe.menus:onKeyEvent(key) -- 365
		end -- 365
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" or mode == 2) then -- 365
			if key == "E" then -- 365
				input.interact.pressed = true -- 369
			elseif key == "Space" then -- 369
				input.jump.pressed = true -- 371
			elseif key == "Escape" then -- 371
				input.pause.pressed = true -- 373
			elseif key == "R" then -- 373
				input.retry.pressed = true -- 375
			end -- 375
		end -- 375
		if mode == 2 and (run and run.trial) ~= nil then -- 375
			return -- 378
		end -- 378
		if isReleaseBuild() then -- 378
			return -- 379
		end -- 379
		if key == "F1" then -- 379
			if mode == 2 then -- 379
				current = 0 -- 382
				play = nil -- 383
				ensurePlay() -- 384
			else -- 384
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 386
			end -- 386
		elseif key == "F2" then -- 386
			setMode(0) -- 389
		elseif key == "1" then -- 389
			pickByIndex(0) -- 391
		elseif key == "2" then -- 391
			pickByIndex(1) -- 393
		elseif key == "3" then -- 393
			pickByIndex(2) -- 395
		elseif key == "4" then -- 395
			pickByIndex(3) -- 397
		elseif key == "5" then -- 397
			pickByIndex(4) -- 399
		elseif key == "6" then -- 399
			pickByIndex(5) -- 401
		elseif key == "7" then -- 401
			pickByIndex(6) -- 403
		elseif key == "8" then -- 403
			pickByIndex(7) -- 405
		end -- 405
	end) -- 339
	viewW = View.size.width -- 409
	viewH = View.size.height -- 410
	applySize() -- 411
	local reg = _G.package.loaded -- 414
	reg["watch.input"] = input -- 415
	reg["watch.fe"] = { -- 416
		setScreen = function(sc) -- 417
			if fe == nil then -- 417
				return -- 419
			end -- 419
			setMode(1) -- 421
			fe.screen = sc -- 422
			if sc == "chapters" then -- 422
				fe.menus:openChapters() -- 424
			else -- 424
				fe.menus:resetInput() -- 426
			end -- 426
			if sc == "play" then -- 426
				ensurePlay() -- 429
			end -- 429
		end, -- 417
		jumpRoom = function(keyOrIdx) -- 432
			local idx = -1 -- 433
			if type(keyOrIdx) == "number" then -- 433
				idx = keyOrIdx -- 435
			else -- 435
				local k = 0 -- 437
				do -- 437
					k = 0 -- 438
					while k < #ROOMS do -- 438
						if ROOMS[k + 1].key == keyOrIdx then -- 438
							idx = k -- 440
						end -- 440
						k = k + 1 -- 438
					end -- 438
				end -- 438
			end -- 438
			if idx >= 0 and idx < #ROOMS then -- 438
				enterPlayRoom(idx, "debug") -- 445
			end -- 445
		end, -- 432
		getPlay = function() return play end, -- 448
		getFrontend = function() return fe end, -- 449
		startStory = function() -- 451
			enterPlayRoom( -- 452
				officialStartIndex(), -- 452
				"official", -- 452
				true -- 452
			) -- 452
			return play -- 453
		end, -- 451
		previewChapter = function(idx) -- 456
			enterPlayRoom(idx, "chapter") -- 457
			return play -- 458
		end, -- 456
		getStoryRun = function() return storyRun end, -- 460
		getProfilePending = function() return profilePending() end, -- 461
		flushProfileNow = function() return flushProfile() end, -- 462
		getProfile = function() return profile end, -- 464
		getProfileStatus = function() return profileStatus end, -- 465
		getProfileDetail = function() return profileDetail end, -- 466
		useTestSave = function(name) -- 467
			setSaveFile(name) -- 468
			setSessionFile(name == "" and "" or name .. ".session") -- 469
			clearProfilePending() -- 470
			local loaded = loadSave() -- 471
			profile = loaded.state -- 472
			profileStatus = loaded.status -- 473
			profileDetail = loaded.detail -- 474
			refreshTitleSessionFlag() -- 475
		end, -- 467
		useTestSession = function(name) -- 477
			setSessionFile(name) -- 478
			refreshTitleSessionFlag() -- 479
		end, -- 477
		getSessionFile = getSessionFile, -- 481
		hasSessionSave = hasSessionSave, -- 482
		saveSessionNow = function() return saveCurrentSession() end, -- 483
		clearSessionNow = function() -- 484
			local ok = clearSession() -- 485
			refreshTitleSessionFlag() -- 486
			return ok -- 487
		end, -- 484
		continueStory = function() return continueOfficialStory() end, -- 489
		saveNow = function() return saveSave(profile) end, -- 490
		getSaveFile = getSaveFile, -- 491
		isRelease = function() return isReleaseBuild() end, -- 492
		getReleaseVersion = function() -- 493
			local ____opt_8 = getReleaseConfig() -- 493
			return ____opt_8 and ____opt_8.version or "dev" -- 493
		end, -- 493
		toggleFullscreen = function() return toggleFullscreen() end, -- 494
		quitGame = function() return quitGame() end -- 495
	} -- 495
	if mode == 1 and startScreen == "play" then -- 495
		ensurePlay() -- 499
	end -- 499
	parent:schedule(function(frameDt) -- 502
		tick(frameDt) -- 503
		return false -- 504
	end) -- 502
end -- 255
return ____exports -- 255