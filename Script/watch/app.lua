-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, setMode, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, renderCampaign, drawCampaignHud, tickFrontend, root, campaignLayer, campaignHud, campaignSub, run, storyRun, profile, current, viewW, viewH, dirty, mode, input, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock, trialTalentSelected -- 70
local ____Dora = require("Dora") -- 8
local App = ____Dora.App -- 8
local Color = ____Dora.Color -- 8
local Label = ____Dora.Label -- 8
local Node = ____Dora.Node -- 8
local Size = ____Dora.Size -- 8
local Vec2 = ____Dora.Vec2 -- 8
local View = ____Dora.View -- 8
local ____rooms = require("Script.watch.rooms") -- 9
local CAMPAIGN_ROOMS = ____rooms.CAMPAIGN_ROOMS -- 9
local ROOMS = ____rooms.ROOMS -- 9
local ____input = require("Script.watch.input") -- 10
local Input = ____input.Input -- 10
local ____play = require("Script.watch.play") -- 11
local Play = ____play.Play -- 11
local ____clock = require("Script.watch.clock") -- 12
local STEP = ____clock.STEP -- 12
local StepClock = ____clock.StepClock -- 12
local ____platform = require("Script.watch.platform") -- 14
local canQuitApp = ____platform.canQuitApp -- 16
local canToggleFullscreen = ____platform.canToggleFullscreen -- 17
local computeStageViewport = ____platform.computeStageViewport -- 18
local getReleaseConfig = ____platform.getReleaseConfig -- 19
local isReleaseMode = ____platform.isReleaseMode -- 20
local ____target = require("Script.watch.target") -- 22
local getActiveTarget = ____target.getActiveTarget -- 22
local ____frontend = require("Script.watch.fe.frontend") -- 23
local WatchFrontend = ____frontend.WatchFrontend -- 23
local ____run = require("Script.watch.run") -- 24
local createRun = ____run.createRun -- 24
local createStoryTalents = ____run.createStoryTalents -- 24
local createTrial = ____run.createTrial -- 24
local mmss = ____run.mmss -- 24
local talentNames = ____run.talentNames -- 24
local ____save = require("Script.watch.save") -- 25
local emptySave = ____save.emptySave -- 25
local loadSave = ____save.loadSave -- 25
local saveSave = ____save.saveSave -- 25
local setSaveFile = ____save.setSaveFile -- 25
local getSaveFile = ____save.getSaveFile -- 25
local markProfilePending = ____save.markProfilePending -- 26
local flushSaveProfile = ____save.flushProfile -- 26
local clearProfilePending = ____save.clearProfilePending -- 26
local profilePending = ____save.profilePending -- 26
local loadSession = ____save.loadSession -- 27
local saveSession = ____save.saveSession -- 27
local clearSession = ____save.clearSession -- 27
local hasSessionSave = ____save.hasSessionSave -- 27
local setSessionFile = ____save.setSessionFile -- 27
local getSessionFile = ____save.getSessionFile -- 27
function onFirstUserGesture() -- 70
	if audioUnlocked or fe == nil then -- 71
		return -- 72
	end -- 72
	audioUnlocked = true -- 74
	fe.audio:unlockAndResyncAfterGesture() -- 75
end -- 75
function toggleFullscreen() -- 78
	if not canToggleFullscreen() then -- 79
		return false -- 80
	end -- 80
	do -- 80
		local function ____catch() -- 80
			return true, false -- 87
		end -- 87
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 87
			local next = not App.fullScreen -- 83
			App.fullScreen = next -- 84
			return true, next -- 85
		end) -- 85
		if not ____try then -- 85
			____hasReturned, ____returnValue = ____catch() -- 85
		end -- 85
		if ____hasReturned then -- 85
			return ____returnValue -- 82
		end -- 82
	end -- 82
end -- 82
function quitGame() -- 91
	flushProfile() -- 92
	saveCurrentSession() -- 93
	if input ~= nil then -- 94
		input:clearTransient(false) -- 94
	end -- 94
	if fe ~= nil then -- 95
		fe.audio:stopRoomTransient() -- 96
	end -- 96
	if not canQuitApp() then -- 98
		current = 0 -- 100
		play = nil -- 101
		run = nil -- 102
		setMode(1) -- 103
		if fe ~= nil then -- 104
			fe.audio:stopRoomTransient() -- 105
			fe.screen = "title" -- 106
			fe.menus:resetInput() -- 107
		end -- 107
		return -- 109
	end -- 109
	App:shutdown() -- 111
end -- 111
function canSaveSession() -- 179
	if mode ~= 1 or play == nil or storyRun == nil then -- 180
		return false -- 181
	end -- 181
	if storyRun.source ~= "official" or play.run.finished then -- 183
		return false -- 184
	end -- 184
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 186
		return false -- 187
	end -- 187
	return true -- 189
end -- 189
function refreshTitleSessionFlag() -- 192
	if fe ~= nil then -- 193
		fe.menus.hasSession = hasSessionSave() -- 194
	end -- 194
end -- 194
function saveCurrentSession() -- 198
	if not canSaveSession() or play == nil then -- 199
		return false -- 200
	end -- 200
	play.sessionDirty = false -- 202
	local ok = saveSession(play:exportSession()) -- 203
	refreshTitleSessionFlag() -- 204
	return ok -- 205
end -- 205
function continueOfficialStory() -- 208
	local res = loadSession() -- 209
	if res.status ~= "ok" or res.state == nil then -- 210
		refreshTitleSessionFlag() -- 211
		return nil -- 212
	end -- 212
	local s = res.state -- 214
	local idx = roomIndexByKey(s.roomKey) -- 215
	if ROOMS[idx + 1].key ~= s.roomKey then -- 216
		return nil -- 217
	end -- 217
	storyRun = createRun(s.seed, "official", profile) -- 219
	storyRun.checkpoint = s.checkpoint -- 220
	storyRun.story.route = s.route -- 221
	storyRun.story.hp = s.hp -- 222
	storyRun.story.maxHp = s.maxHp -- 223
	storyRun.story.hpAtGate = s.hpAtGate -- 224
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 225
	storyRun.story.settled = s.settled -- 226
	storyRun.story.phase = s.phase -- 227
	storyRun.story.countTick = s.countTick -- 228
	storyRun.story.phaseTick = s.phaseTick -- 229
	storyRun.story.handTicks = s.handTicks -- 230
	storyRun.story.handDone = s.handDone -- 231
	storyRun.story.lineSaid = s.lineSaid -- 232
	storyRun.story.tied = s.tied -- 233
	storyRun.story.carry = s.carry -- 234
	storyRun.story.escortDone = s.escortDone -- 235
	storyRun.story.craftedWeapon = s.craftedWeapon -- 236
	storyRun.story.equippedWeapon = s.equippedWeapon -- 237
	storyRun.inventory.wood = s.wood -- 238
	storyRun.inventory.bell = s.bell -- 239
	storyRun.inventory.scrap = s.scrap -- 240
	storyRun.inventory.wedge = s.wedge -- 241
	storyRun.inventory.ammo = s.ammo -- 242
	storyRun.inventory.shield = s.shield -- 243
	storyRun.inventory.pass = s.pass -- 244
	storyRun.inventory.quickbelt = s.quickbelt -- 245
	local k = 0 -- 246
	do -- 246
		k = 0 -- 247
		while k < #s.taken do -- 247
			storyRun.taken[s.taken[k + 1]] = true -- 248
			k = k + 1 -- 247
		end -- 247
	end -- 247
	do -- 247
		k = 0 -- 250
		while k < #s.segments do -- 250
			storyRun.story.segments[s.segments[k + 1]] = true -- 251
			k = k + 1 -- 250
		end -- 250
	end -- 250
	if s.campaignRoute ~= nil then -- 253
		storyRun.route = s.campaignRoute -- 254
	end -- 254
	if s.joined ~= nil then -- 256
		storyRun.joined = s.joined -- 257
	end -- 257
	if s.c1Latch ~= nil then -- 259
		storyRun.c1Latch = s.c1Latch -- 260
	end -- 260
	if s.c2Latch ~= nil then -- 262
		storyRun.c2Latch = s.c2Latch -- 263
	end -- 263
	if s.props ~= nil then -- 265
		do -- 265
			k = 0 -- 266
			while k < #s.props do -- 266
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 267
				local pid = parts[1] -- 268
				if pid ~= nil and pid ~= "" then -- 269
					local ____storyRun_props_16 = storyRun.props -- 270
					local ____temp_12 -- 271
					if parts[2] == nil then -- 271
						____temp_12 = true -- 271
					else -- 271
						____temp_12 = parts[2] == "1" -- 271
					end -- 271
					local ____temp_14 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 272
					local ____temp_15 = parts[4] == "1" -- 273
					local ____temp_13 -- 274
					if parts[5] == "1" then -- 274
						____temp_13 = true -- 274
					else -- 274
						____temp_13 = nil -- 274
					end -- 274
					____storyRun_props_16[pid] = {broken = ____temp_12, hp = ____temp_14, wedge = ____temp_15, revealed = ____temp_13} -- 270
				end -- 270
				k = k + 1 -- 266
			end -- 266
		end -- 266
	end -- 266
	local stTalents = createStoryTalents(s.seed) -- 279
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 280
		stTalents.randomState = s.talentSeed -- 281
	end -- 281
	stTalents.room = s.talentRoom or "" -- 283
	stTalents.ranks.vitality = s.talentVitality or 0 -- 284
	stTalents.ranks.reload = s.talentReload or 0 -- 285
	stTalents.ranks.guard = s.talentGuard or 0 -- 286
	stTalents.ranks.craft = s.talentCraft or 0 -- 287
	if s.talentOffers ~= nil then -- 288
		do -- 288
			k = 0 -- 289
			while k < #s.talentOffers do -- 289
				local t = s.talentOffers[k + 1] -- 290
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 291
					local ____stTalents_offers_17 = stTalents.offers -- 292
					____stTalents_offers_17[#____stTalents_offers_17 + 1] = t -- 292
				end -- 292
				k = k + 1 -- 289
			end -- 289
		end -- 289
	end -- 289
	storyRun.story.talents = stTalents -- 296
	current = idx -- 297
	setMode(1) -- 298
	if fe ~= nil then -- 299
		fe.screen = "play" -- 300
	end -- 300
	play = nil -- 302
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 303
	local cur = play -- 304
	if cur ~= nil then -- 305
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 306
			cur.cartAxle = s.cartAxle -- 307
			cur.cartDocked = s.cartDocked -- 308
		end -- 308
		if s.playerX ~= nil and s.playerX >= 0 then -- 310
			cur.player.x = math.max( -- 311
				cur.room.minX + 16, -- 311
				math.min(cur.room.maxX - 16, s.playerX) -- 311
			) -- 311
			cur.player.y = math.max(0, s.playerY or 0) -- 312
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 313
				cur.player.depth = math.max( -- 314
					cur.room.depth.min, -- 314
					math.min(cur.room.depth.max, s.playerDepth) -- 314
				) -- 314
			end -- 314
		end -- 314
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 317
			cur.gateTick = s.gateTick -- 318
		end -- 318
		if cur.room.key == "village" then -- 320
			if s.hasBottle == true then -- 321
				cur.hasBottle = true -- 321
			end -- 321
			if s.villagePassed == true then -- 322
				cur.passed = true -- 322
			end -- 322
		end -- 322
	end -- 322
	return play -- 325
end -- 325
function setMode(nextMode) -- 605
	mode = nextMode -- 606
	if fe ~= nil then -- 607
		fe:setVisible(mode == 1) -- 608
	end -- 608
	if campaignLayer ~= nil then -- 610
		campaignLayer.visible = mode == 2 -- 611
	end -- 611
	dirty = true -- 613
	clock:reset() -- 614
end -- 614
function flushProfile() -- 621
	local cur = play -- 622
	if cur ~= nil and cur.archiveDirty then -- 623
		cur.archiveDirty = false -- 624
		markProfilePending(profile) -- 625
	end -- 625
	local ok = flushSaveProfile() -- 627
	if not ok and cur ~= nil then -- 628
		cur.archiveDirty = true -- 629
	end -- 629
	return ok -- 631
end -- 631
function officialStartIndex() -- 635
	local mp = profile.museumPhase -- 636
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 637
	return inMuseum and roomIndexByKey("museum") or 0 -- 638
end -- 638
function roomIndexByKey(key) -- 641
	local i = 0 -- 642
	do -- 642
		i = 0 -- 643
		while i < #ROOMS do -- 643
			if ROOMS[i + 1].key == key then -- 644
				return i -- 645
			end -- 645
			i = i + 1 -- 643
		end -- 643
	end -- 643
	return 0 -- 648
end -- 648
function enterPlayRoom(idx, source, fresh) -- 651
	if source == nil then -- 651
		source = "debug" -- 651
	end -- 651
	if fresh == nil then -- 651
		fresh = false -- 651
	end -- 651
	current = idx -- 652
	setMode(1) -- 653
	if fe ~= nil then -- 654
		fe.screen = "play" -- 655
	end -- 655
	play = nil -- 657
	if fresh or source == "chapter" or storyRun == nil then -- 659
		storyRun = createRun(20261124, source, profile) -- 660
	else -- 660
		storyRun.source = source -- 662
	end -- 662
	ensurePlay() -- 664
	local firstPlay = play -- 666
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 667
		firstPlay.phase = "prologue-wake" -- 668
	end -- 668
	flushProfile() -- 670
end -- 670
function applySize() -- 703
	if root == nil then -- 704
		return -- 705
	end -- 705
	root.size = Size(viewW, viewH) -- 707
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 708
	stageVp = computeStageViewport(viewW, viewH) -- 709
	if input ~= nil then -- 710
		input:setStageViewport(stageVp) -- 711
	end -- 711
	if fe ~= nil then -- 713
		fe:setStagePlacement(stageVp) -- 714
	end -- 714
	if campaignLayer ~= nil then -- 716
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 717
	end -- 717
end -- 717
function syncFrameAdapters(frameDt) -- 721
	if input == nil then -- 722
		return -- 723
	end -- 723
	local target = input.target -- 725
	if not target.supportsTouch and not target.supportsGamepad then -- 726
		return -- 727
	end -- 727
	local p = play -- 729
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 730
	local storyTalentBoxes = target.supportsTouch and isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 731
		p, -- 733
		stageVp.stageW, -- 733
		stageVp.stageH, -- 733
		input:isTouchMode() -- 733
	) or ({}) -- 734
	local isFs = false -- 736
	if target:canToggleFullscreen() then -- 737
		do -- 737
			local function ____catch() -- 737
				isFs = false -- 741
			end -- 741
			local ____try = pcall(function() -- 741
				isFs = App.fullScreen -- 739
			end) -- 739
			if not ____try then -- 739
				____catch() -- 739
			end -- 739
		end -- 739
	end -- 739
	local ____input_60 = input -- 744
	local ____input_syncFrame_61 = input.syncFrame -- 744
	local ____stageVp_54 = stageVp -- 745
	local ____mode_55 = mode -- 746
	local ____temp_56 = fe ~= nil and fe.screen or "title" -- 747
	local ____run_57 = run -- 749
	local ____temp_58 = fe and fe.cam -- 751
	local ____input_59 = input -- 752
	local ____temp_52 -- 753
	if fe ~= nil then -- 753
		____temp_52 = fe.contract:isAssistHintsEnabled() -- 753
	else -- 753
		____temp_52 = false -- 753
	end -- 753
	local ____temp_53 -- 754
	if fe ~= nil then -- 754
		____temp_53 = fe.audio:isAllMuted() -- 754
	else -- 754
		____temp_53 = false -- 754
	end -- 754
	____input_syncFrame_61(____input_60, { -- 744
		viewport = ____stageVp_54, -- 745
		mode = ____mode_55, -- 746
		screen = ____temp_56, -- 747
		play = p, -- 748
		run = ____run_57, -- 749
		cam = ____temp_58, -- 751
		input = ____input_59, -- 752
		assistHintsEnabled = ____temp_52, -- 753
		isMuted = ____temp_53, -- 754
		isFullscreen = isFs, -- 755
		storyTalentBoxes = storyTalentBoxes, -- 756
		dt = frameDt -- 757
	}) -- 757
end -- 757
function renderTouchOverlay() -- 761
	if input ~= nil then -- 762
		input:renderOverlay() -- 762
	end -- 762
end -- 762
function tick(frameDt) -- 765
	appClock = appClock + math.min( -- 766
		0.05, -- 766
		math.max(0, frameDt) -- 766
	) -- 766
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 767
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 768
	if w ~= viewW or h ~= viewH then -- 769
		viewW = w -- 770
		viewH = h -- 771
		applySize() -- 772
		dirty = true -- 773
	end -- 773
	if input == nil then -- 775
		return -- 776
	end -- 776
	syncFrameAdapters(frameDt) -- 778
	input:update() -- 779
	if input.userInteracted then -- 781
		onFirstUserGesture() -- 782
	end -- 782
	if input.muteTogglePressed and fe ~= nil then -- 784
		input.muteTogglePressed = false -- 785
		fe.audio:toggleAllMuted() -- 786
	end -- 786
	if input.fullscreenTogglePressed then -- 788
		input.fullscreenTogglePressed = false -- 789
		toggleFullscreen() -- 790
	end -- 790
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 792
		input.artifactTogglePressed = false -- 793
		play:toggleArtifactWeapon() -- 794
	end -- 794
	if input.bottleCanceled and play ~= nil then -- 796
		input.bottleCanceled = false -- 797
		play.aimHold = 0 -- 798
		play.bottleAimX = -1 -- 799
	end -- 799
	if mode == 2 and (run and run.trial) ~= nil then -- 802
		tickCampaign(frameDt) -- 803
		renderTouchOverlay() -- 804
		return -- 805
	end -- 805
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 808
		play:chooseTalent(input.pickRoom - 1) -- 811
		input.pickRoom = 0 -- 812
	end -- 812
	input.toggleView.pressed = false -- 816
	input.pickRoom = 0 -- 817
	input.tab.pressed = false -- 818
	if mode == 2 then -- 820
		tickCampaign(frameDt) -- 821
	elseif mode == 1 then -- 822
		tickFrontend(frameDt) -- 823
	end -- 823
	renderTouchOverlay() -- 825
end -- 825
function registerPlay() -- 829
	local reg = _G.package.loaded -- 830
	reg["watch.play"] = play -- 831
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 832
	reg["watch.room"] = rooms[current + 1].key -- 833
end -- 833
function ensurePlay(resume) -- 837
	if mode == 2 then -- 838
		if run == nil then -- 839
			run = createRun() -- 840
		end -- 840
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 842
	else -- 842
		if storyRun == nil then -- 846
			storyRun = createRun(20261124, "debug", profile) -- 847
		end -- 847
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 849
	end -- 849
	registerPlay() -- 851
	clock:reset() -- 852
	if fe ~= nil then -- 853
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 855
		if mode == 2 then -- 856
			fe:resetTrialAudio(play) -- 857
		end -- 857
	end -- 857
end -- 857
function startTrial() -- 862
	current = 0 -- 863
	trialTalentSelected = 0 -- 864
	run = createTrial(App.rand) -- 865
	setMode(2) -- 866
	ensurePlay() -- 867
end -- 867
function tickCampaign(frameDt) -- 870
	if input == nil then -- 871
		return -- 872
	end -- 872
	if play == nil then -- 874
		ensurePlay() -- 875
	end -- 875
	if play == nil then -- 877
		return -- 878
	end -- 878
	local p = play -- 880
	p.aimX = input.mx -- 881
	p.aimY = input.my -- 882
	local zoneTap = input.touchZoneTap -- 884
	input.touchZoneTap = "" -- 885
	local trial = run and run.trial -- 887
	if trial ~= nil then -- 888
		local ended = trial.lost or (run and run.finished) == true -- 889
		local pick = input.pickRoom -- 890
		input.pickRoom = 0 -- 891
		if zoneTap == "trial:resume" and p.paused and not ended then -- 893
			p.paused = false -- 894
			clock:reset() -- 895
			input:consumeEdges() -- 896
			renderCampaign(frameDt, p) -- 897
			return -- 898
		end -- 898
		if zoneTap == "trial:retry" then -- 900
			input:consumeEdges() -- 901
			startTrial() -- 902
			return -- 903
		end -- 903
		if zoneTap == "trial:title" then -- 905
			input:consumeEdges() -- 906
			current = 0 -- 907
			play = nil -- 908
			run = nil -- 909
			setMode(1) -- 910
			if fe ~= nil then -- 911
				fe.audio:stopRoomTransient() -- 912
				fe.screen = "title" -- 913
				fe.menus:resetInput() -- 914
			end -- 914
			return -- 916
		end -- 916
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 919
			input:consumeEdges() -- 920
			current = 0 -- 921
			play = nil -- 922
			run = nil -- 923
			setMode(1) -- 924
			if fe ~= nil then -- 925
				fe.audio:stopRoomTransient() -- 926
				fe.screen = "title" -- 927
				fe.menus:resetInput() -- 928
			end -- 928
			return -- 930
		end -- 930
		if ended or p.paused and input.retry.pressed then -- 932
			local restart = input.retry.pressed or ended and input.navConfirm -- 933
			input:consumeEdges() -- 934
			if restart then -- 935
				startTrial() -- 935
			else -- 935
				renderCampaign(frameDt, p) -- 936
			end -- 936
			return -- 937
		end -- 937
		input.retry.pressed = false -- 939
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 940
			if trialTalentSelected >= #trial.offers then -- 941
				trialTalentSelected = 0 -- 942
			end -- 942
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 944
				local idx = __TS__ParseInt( -- 945
					string.sub(zoneTap, 8), -- 945
					10 -- 945
				) -- 945
				if idx >= 0 and idx < #trial.offers then -- 946
					p:chooseTalent(idx) -- 947
				end -- 947
			elseif pick > 0 then -- 949
				p:chooseTalent(pick - 1) -- 950
			else -- 950
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 952
				if delta ~= 0 then -- 955
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 956
				end -- 956
				if input.talentConfirm or input.navConfirm then -- 958
					p:chooseTalent(trialTalentSelected) -- 959
				end -- 959
			end -- 959
			input:consumeEdges() -- 962
			clock:reset() -- 963
			renderCampaign(frameDt, p) -- 964
			return -- 965
		end -- 965
	end -- 965
	if input.retry.pressed then -- 969
		input.retry.pressed = false -- 970
		input:consumeEdges() -- 971
		play = nil -- 973
		ensurePlay() -- 974
		return -- 975
	end -- 975
	if input.pause.pressed or p.paused and input.navBack then -- 977
		input.pause.pressed = false -- 978
		p.paused = not p.paused -- 979
		if fe ~= nil then -- 980
			fe.audio:playUi(p.paused and "ui:pause_open" or "ui:pause_close", p.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 980
		end -- 980
		clock:reset() -- 981
		input:consumeEdges() -- 982
	end -- 982
	if p.paused then -- 984
		renderCampaign(frameDt, p) -- 985
		return -- 986
	end -- 986
	local steps = clock:advance(frameDt) -- 989
	local i = 0 -- 990
	do -- 990
		i = 0 -- 991
		while i < steps do -- 991
			input:beginStep(i == 0) -- 992
			p:update(STEP, input) -- 993
			input:endStep() -- 994
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 995
				break -- 996
			end -- 996
			i = i + 1 -- 991
		end -- 991
	end -- 991
	if p.wantRoom ~= "" then -- 1000
		local key = p.wantRoom -- 1001
		p.wantRoom = "" -- 1002
		local idx = -1 -- 1003
		local j = 0 -- 1004
		do -- 1004
			j = 0 -- 1005
			while j < #CAMPAIGN_ROOMS do -- 1005
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1006
					idx = j -- 1007
				end -- 1007
				j = j + 1 -- 1005
			end -- 1005
		end -- 1005
		if idx >= 0 then -- 1010
			current = idx -- 1011
			play = nil -- 1012
			ensurePlay() -- 1013
		end -- 1013
		return -- 1015
	end -- 1015
	renderCampaign(frameDt, p) -- 1017
end -- 1017
function goalLabel(goal) -- 1020
	if goal == "dock_cart" then -- 1021
		return "推车入窝并抬闩" -- 1022
	end -- 1022
	if goal == "raise_latch" then -- 1024
		return "抬闩开侧门" -- 1025
	end -- 1025
	return "到段出口" -- 1027
end -- 1027
function renderCampaign(frameDt, p) -- 1031
	if fe ~= nil and input ~= nil then -- 1032
		local ____opt_76 = run and run.trial -- 1034
		local offers = ____opt_76 and #____opt_76.offers or 0 -- 1034
		local ____p_paused_80 -- 1035
		if p.paused then -- 1035
			____p_paused_80 = nil -- 1035
		else -- 1035
			____p_paused_80 = fe.adapter:sample(p) -- 1035
		end -- 1035
		local ev = ____p_paused_80 -- 1035
		fe:renderPlay( -- 1036
			frameDt, -- 1036
			p, -- 1036
			input, -- 1036
			stageVp.stageW, -- 1036
			stageVp.stageH, -- 1036
			true, -- 1036
			ev -- 1036
		) -- 1036
		fe:syncTrialAudio(frameDt, p, offers, ev) -- 1037
	end -- 1037
	drawCampaignHud(p) -- 1039
end -- 1039
function drawCampaignHud(p) -- 1043
	local h = stageVp.stageH -- 1044
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1045
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1046
	local room = CAMPAIGN_ROOMS[current + 1] -- 1047
	local c = room.campaign -- 1048
	local r = run -- 1049
	local trial = r and r.trial -- 1050
	local gpMode = input ~= nil and input:isGamepadMode() -- 1051
	local touchMode = input ~= nil and input:isTouchMode() -- 1052
	local line = room.name -- 1055
	if trial == nil then -- 1056
		if c ~= nil then -- 1057
			line = (((line .. "  · 目标 ") .. goalLabel(c.goal)) .. "  · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0)) -- 1058
		end -- 1058
		if p.paused then -- 1060
			line = line .. "  · 已暂停" -- 1060
		end -- 1060
	else -- 1060
		line = (((((("护送试炼 · " .. room.name) .. "  · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. "  · ") .. mmss(r == nil and 0 or r.ticks) -- 1062
		if p.paused then -- 1063
			line = line .. "  · 暂停" -- 1063
		elseif trial.lost then -- 1064
			line = line .. "  · 护送失败" -- 1064
		elseif r ~= nil and r.finished then -- 1065
			line = line .. "  · 护送完成" -- 1065
		elseif #trial.offers > 0 then -- 1066
			line = line .. "  · 选择本段本领" -- 1066
		elseif c ~= nil then -- 1067
			line = line .. "  · " .. goalLabel(c.goal) -- 1067
		end -- 1067
	end -- 1067
	if campaignHud ~= nil then -- 1069
		campaignHud.text = line -- 1070
		campaignHud.position = Vec2(stageVp.stageW * 0.5, h - 12 - safeT) -- 1071
		campaignHud.visible = true -- 1072
	end -- 1072
	if campaignSub == nil then -- 1074
		return -- 1075
	end -- 1075
	local sub = p.flash -- 1077
	if trial ~= nil and r ~= nil then -- 1078
		local curMode = input ~= nil and input.inputMode or getActiveTarget().defaultInputMode -- 1079
		if trial.lost or r.finished then -- 1080
			sub = getActiveTarget():trialSubHint(curMode, true, r.seed) -- 1081
		elseif p.paused then -- 1082
			sub = getActiveTarget():trialSubHint(curMode, false, r.seed) -- 1083
		elseif #trial.offers > 0 then -- 1084
			sub = table.concat( -- 1085
				__TS__ArrayMap( -- 1085
					trial.offers, -- 1085
					function(____, talent, index) -- 1085
						local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1086
						return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1087
					end -- 1085
				), -- 1085
				"　" -- 1088
			) -- 1088
		elseif sub == "" then -- 1089
			sub = r.joined and "小满跟随" or "小满等待" -- 1090
		end -- 1090
	end -- 1090
	campaignSub.text = sub -- 1093
	campaignSub.position = Vec2(stageVp.stageW * 0.5, 14 + stageVp.safeUi.bottom * stageVp.uiScale) -- 1094
	campaignSub.visible = sub ~= "" -- 1095
end -- 1095
function tickFrontend(frameDt) -- 1098
	if fe == nil or input == nil then -- 1099
		return -- 1100
	end -- 1100
	if fe.screen ~= "play" then -- 1104
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1105
		input:consumeEdges() -- 1106
		if act.type == "splashDone" then -- 1107
			fe.menus:resetInput() -- 1108
			fe.screen = "title" -- 1109
		elseif act.type == "trial" then -- 1110
			startTrial() -- 1111
		elseif act.type == "continue" then -- 1112
			if continueOfficialStory() == nil then -- 1113
				enterPlayRoom( -- 1114
					officialStartIndex(), -- 1114
					"official", -- 1114
					true -- 1114
				) -- 1114
			end -- 1114
		elseif act.type == "start" then -- 1116
			clearSession() -- 1118
			refreshTitleSessionFlag() -- 1119
			enterPlayRoom( -- 1120
				officialStartIndex(), -- 1120
				"official", -- 1120
				true -- 1120
			) -- 1120
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1121
			enterPlayRoom(act.roomIndex, "chapter") -- 1122
		elseif act.type == "openChapters" then -- 1123
			fe.menus:openChapters() -- 1124
			fe.screen = "chapters" -- 1125
		elseif act.type == "openControls" then -- 1126
			fe.menus:resetInput() -- 1127
			fe.screen = "controls" -- 1128
		elseif act.type == "openHistory" then -- 1129
			fe.menus:openHistory(true) -- 1130
			fe.screen = "history" -- 1131
		elseif act.type == "backEpilogue" then -- 1132
			fe.menus:resetInput() -- 1133
			fe.screen = "epilogue" -- 1134
		elseif act.type == "replayStory" then -- 1135
			clearSession() -- 1136
			refreshTitleSessionFlag() -- 1137
			enterPlayRoom( -- 1138
				officialStartIndex(), -- 1138
				"official", -- 1138
				true -- 1138
			) -- 1138
		elseif act.type == "backTitle" then -- 1139
			fe.menus:resetInput() -- 1140
			fe.screen = "title" -- 1141
		elseif act.type == "backPause" then -- 1142
			fe.menus:resetInput() -- 1143
			fe.screen = "play" -- 1144
		elseif act.type == "quit" then -- 1145
			quitGame() -- 1146
		end -- 1146
		return -- 1148
	end -- 1148
	if play == nil then -- 1152
		ensurePlay() -- 1153
	end -- 1153
	if play == nil then -- 1155
		return -- 1156
	end -- 1156
	local p = play -- 1158
	p.aimX = input.mx -- 1160
	p.aimY = input.my -- 1161
	local zoneTap = input.touchZoneTap -- 1163
	input.touchZoneTap = "" -- 1164
	local offers = p:getStoryTalentOffers() -- 1166
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1167
		if fe.hud.talentSelected >= #offers then -- 1168
			fe.hud.talentSelected = 0 -- 1169
		end -- 1169
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1171
			local idx = __TS__ParseInt( -- 1172
				string.sub(zoneTap, 8), -- 1172
				10 -- 1172
			) -- 1172
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1173
				input.fire.pressed = false -- 1174
			end -- 1174
		else -- 1174
			if input.talentDelta ~= 0 then -- 1177
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1178
				input.talentDelta = 0 -- 1179
			end -- 1179
			if input.talentConfirm then -- 1181
				p:chooseTalent(fe.hud.talentSelected) -- 1182
				input.talentConfirm = false -- 1183
				input.fire.pressed = false -- 1184
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1185
				input.fire.pressed = false -- 1187
			end -- 1187
		end -- 1187
	end -- 1187
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1193
		if input.navConfirm then -- 1194
			input.interact.pressed = true -- 1195
		end -- 1195
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1197
			flushProfile() -- 1198
			if p.run.source == "official" and hasSessionSave() then -- 1199
				clearSession() -- 1200
				refreshTitleSessionFlag() -- 1201
			end -- 1201
			fe.audio:stopRoomTransient() -- 1203
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1204
			fe.screen = "epilogue" -- 1208
			input:clearTransient(true) -- 1209
			input:consumeEdges() -- 1210
			return -- 1211
		end -- 1211
	end -- 1211
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1215
		p:closeCraftBench() -- 1216
		input:consumeEdges() -- 1217
		return -- 1218
	end -- 1218
	if not p.paused and input.pause.pressed then -- 1220
		p.paused = true -- 1221
		p.aimHold = 0 -- 1222
		p.bottleAimX = -1 -- 1223
		saveCurrentSession() -- 1224
		fe.menus:openPause() -- 1225
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1226
		input:clearTransient(true) -- 1227
		input:consumeEdges() -- 1228
	end -- 1228
	if p.paused then -- 1231
		clock:reset() -- 1233
		local pauseAct = fe:renderPlay( -- 1234
			frameDt, -- 1234
			p, -- 1234
			input, -- 1234
			stageVp.stageW, -- 1234
			stageVp.stageH -- 1234
		) -- 1234
		input:consumeEdges() -- 1235
		if pauseAct.type == "resume" then -- 1236
			p.paused = false -- 1237
		elseif pauseAct.type == "retry" then -- 1238
			ensurePlay({checkpoint = p.checkpoint}) -- 1239
		elseif pauseAct.type == "openChapters" then -- 1240
			fe.audio:stopRoomTransient() -- 1241
			fe.audio:setPaused(false) -- 1242
			fe.menus:openChapters(current) -- 1243
			fe.screen = "chapters" -- 1244
		elseif pauseAct.type == "toggleFullscreen" then -- 1245
			toggleFullscreen() -- 1246
		elseif pauseAct.type == "quit" then -- 1247
			quitGame() -- 1248
		elseif pauseAct.type == "toTitle" then -- 1249
			saveCurrentSession() -- 1250
			refreshTitleSessionFlag() -- 1251
			fe.menus:resetInput() -- 1252
			fe.screen = "title" -- 1253
		end -- 1253
		return -- 1255
	end -- 1255
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1258
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1259
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1261
		input:consumeEdges() -- 1262
		ensurePlay({checkpoint = p.checkpoint}) -- 1264
		return -- 1265
	end -- 1265
	local steps = clock:advance(frameDt) -- 1268
	local i = 0 -- 1269
	do -- 1269
		i = 0 -- 1270
		while i < steps do -- 1270
			input:beginStep(i == 0) -- 1271
			p:update(STEP, input) -- 1272
			input:endStep() -- 1273
			if p.wantRoom ~= "" then -- 1274
				break -- 1275
			end -- 1275
			i = i + 1 -- 1270
		end -- 1270
	end -- 1270
	if p.wantRoom ~= "" then -- 1280
		local key = p.wantRoom -- 1281
		p.wantRoom = "" -- 1282
		local idx = -1 -- 1283
		local j = 0 -- 1284
		do -- 1284
			j = 0 -- 1285
			while j < #ROOMS do -- 1285
				if ROOMS[j + 1].key == key then -- 1286
					idx = j -- 1287
				end -- 1287
				j = j + 1 -- 1285
			end -- 1285
		end -- 1285
		if idx >= 0 then -- 1290
			flushProfile() -- 1294
			local leaving = p:drainEvents() -- 1295
			if p.restartStory then -- 1297
				if storyRun ~= nil and storyRun.source == "official" then -- 1298
					clearSession() -- 1299
					refreshTitleSessionFlag() -- 1300
				end -- 1300
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1302
				storyRun = createRun(20261124, nextSource, profile) -- 1303
			end -- 1303
			current = idx -- 1305
			ensurePlay() -- 1306
			local fresh = play -- 1307
			if fresh ~= nil then -- 1308
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1309
					fresh.phase = "prologue-wake" -- 1310
				end -- 1310
				fresh:adoptEvents(leaving) -- 1312
			end -- 1312
			if not p.restartStory then -- 1314
				saveCurrentSession() -- 1315
			end -- 1315
			clock:reset() -- 1317
			dirty = true -- 1318
		end -- 1318
		return -- 1320
	end -- 1320
	flushProfile() -- 1324
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1325
		clearSession() -- 1326
		refreshTitleSessionFlag() -- 1327
	elseif p.sessionDirty then -- 1328
		saveCurrentSession() -- 1329
	end -- 1329
	fe:renderPlay( -- 1331
		frameDt, -- 1331
		p, -- 1331
		input, -- 1331
		stageVp.stageW, -- 1331
		stageVp.stageH -- 1331
	) -- 1331
end -- 1331
local FONT = "sarasa-mono-sc-regular" -- 32
local C_TEXT = Color(236, 236, 232, 255) -- 34
local C_ACCENT = Color(226, 186, 84, 255) -- 35
profile = emptySave() -- 45
local profileStatus = "missing" -- 46
local profileDetail = "" -- 47
current = 0 -- 49
viewW = 0 -- 50
viewH = 0 -- 51
dirty = true -- 52
mode = 1 -- 54
clock = __TS__New(StepClock) -- 58
stageVp = computeStageViewport(1280, 720) -- 59
audioUnlocked = false -- 61
appClock = 0 -- 62
local lastBackPressClock = -10 -- 63
trialTalentSelected = 0 -- 64
local function isReleaseBuild() -- 66
	return isReleaseMode() -- 67
end -- 66
local function handleBackButton() -- 114
	if mode == 2 and play ~= nil then -- 115
		local trial = run and run.trial -- 116
		if trial ~= nil and (trial.lost or (run and run.finished) == true) then -- 117
			current = 0 -- 118
			play = nil -- 119
			run = nil -- 120
			setMode(1) -- 121
			if fe ~= nil then -- 122
				fe.audio:stopRoomTransient() -- 123
				fe.screen = "title" -- 124
				fe.menus:resetInput() -- 125
			end -- 125
			return -- 127
		end -- 127
		play.paused = not play.paused -- 129
		if fe ~= nil then -- 130
			fe.audio:playUi(play.paused and "ui:pause_open" or "ui:pause_close", play.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 130
		end -- 130
		clock:reset() -- 131
		if input ~= nil then -- 132
			input:clearTransient(true) -- 132
		end -- 132
		return -- 133
	end -- 133
	if fe == nil then -- 135
		return -- 136
	end -- 136
	if fe.screen == "splash" then -- 138
		fe.menus:resetSplash() -- 139
		fe.screen = "title" -- 140
		fe.menus:resetInput() -- 141
		return -- 142
	end -- 142
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "epilogue" or fe.screen == "history" then -- 144
		fe.menus:triggerBack() -- 145
		return -- 146
	end -- 146
	if fe.screen == "title" then -- 148
		if not canQuitApp() then -- 149
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 150
			return -- 151
		end -- 151
		if appClock - lastBackPressClock <= 2 then -- 153
			quitGame() -- 154
		else -- 154
			lastBackPressClock = appClock -- 156
			fe:showToast("再按一次返回退出游戏", 2) -- 157
		end -- 157
		return -- 159
	end -- 159
	if fe.screen == "play" and play ~= nil then -- 161
		if play.paused then -- 162
			fe.menus:triggerBack() -- 163
			return -- 164
		end -- 164
		if play.craftBench.active then -- 166
			play:closeCraftBench() -- 167
			return -- 168
		end -- 168
		play.paused = true -- 170
		play.aimHold = 0 -- 171
		play.bottleAimX = -1 -- 172
		saveCurrentSession() -- 173
		fe.menus:openPause() -- 174
		if input ~= nil then -- 175
			input:clearTransient(true) -- 175
		end -- 175
	end -- 175
end -- 114
function ____exports.start(parent, initialMode, startScreen) -- 328
	if initialMode == nil then -- 328
		initialMode = 1 -- 328
	end -- 328
	if startScreen == nil then -- 328
		startScreen = "title" -- 328
	end -- 328
	root = parent -- 329
	mode = initialMode -- 330
	campaignLayer = Node() -- 333
	campaignLayer.order = 6 -- 334
	campaignLayer:addTo(parent) -- 335
	campaignHud = Label(FONT, 24) -- 336
	if campaignHud ~= nil then -- 337
		campaignHud.color = C_TEXT -- 338
		campaignHud.anchor = Vec2(0.5, 1) -- 339
		campaignHud:addTo(campaignLayer) -- 340
		campaignHud.visible = true -- 341
	end -- 341
	campaignSub = Label(FONT, 20) -- 343
	if campaignSub ~= nil then -- 344
		campaignSub.color = C_ACCENT -- 345
		campaignSub.anchor = Vec2(0.5, 0) -- 346
		campaignSub:addTo(campaignLayer) -- 347
		campaignSub.visible = true -- 348
	end -- 348
	campaignLayer.visible = mode == 2 -- 350
	if mode == 1 then -- 354
		local loaded = loadSave() -- 355
		profile = loaded.state -- 356
		profileStatus = loaded.status -- 357
		profileDetail = loaded.detail -- 358
	end -- 358
	fe = __TS__New(WatchFrontend, parent) -- 360
	fe.screen = startScreen -- 361
	if startScreen == "splash" then -- 362
		fe.menus:resetSplash() -- 363
	end -- 363
	refreshTitleSessionFlag() -- 365
	fe:setVisible(mode == 1) -- 366
	if campaignLayer ~= nil then -- 367
		campaignLayer.visible = mode == 2 -- 368
	end -- 368
	input = __TS__New(Input) -- 371
	fe.audio:applyUserVolumes(input.settings) -- 372
	input:attach( -- 373
		parent, -- 373
		{ -- 373
			onFirstUserGesture = function() -- 374
				onFirstUserGesture() -- 375
				if input ~= nil then -- 376
					input:markKeyboardActivity() -- 376
				end -- 376
			end, -- 374
			onToggleFullscreen = function() -- 378
				toggleFullscreen() -- 379
			end, -- 378
			onKeyDownEvent = function(____, key) -- 381
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 382
					play:toggleArtifactWeapon() -- 383
					return -- 384
				end -- 384
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and #play:getStoryTalentOffers() > 0 then -- 386
					if key == "1" then -- 388
						play:chooseTalent(0) -- 389
						if input ~= nil then -- 390
							input:consumePickRoom() -- 390
						end -- 390
						return -- 391
					end -- 391
					if key == "2" then -- 393
						play:chooseTalent(1) -- 394
						if input ~= nil then -- 395
							input:consumePickRoom() -- 395
						end -- 395
						return -- 396
					end -- 396
					if key == "3" then -- 398
						play:chooseTalent(2) -- 399
						if input ~= nil then -- 400
							input:consumePickRoom() -- 400
						end -- 400
						return -- 401
					end -- 401
				end -- 401
				local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 404
				if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 405
					fe.menus:onKeyEvent(key) -- 406
				end -- 406
				if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay or mode == 2) then -- 408
					if key == "E" then -- 409
						input.interact.pressed = true -- 410
					elseif key == "Space" then -- 411
						input.jump.pressed = true -- 412
					elseif key == "Escape" then -- 413
						input.pause.pressed = true -- 414
					elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 415
						input.retry.pressed = true -- 416
					end -- 416
				end -- 416
			end -- 381
		} -- 381
	) -- 381
	parent:gslot( -- 423
		"AppEvent", -- 423
		function(eventType) -- 423
			if eventType == "BackButton" then -- 424
				handleBackButton() -- 425
				return -- 426
			end -- 426
			if eventType == "Quit" or eventType == "Shutdown" then -- 428
				flushProfile() -- 429
				saveCurrentSession() -- 430
				if input ~= nil then -- 431
					input:clearTransient(false) -- 431
				end -- 431
				return -- 432
			end -- 432
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 434
				flushProfile() -- 435
				saveCurrentSession() -- 436
				if input ~= nil then -- 437
					input:clearTransient(true) -- 437
				end -- 437
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 438
					play.paused = true -- 439
					play.aimHold = 0 -- 440
					play.bottleAimX = -1 -- 441
					fe.menus:openPause() -- 442
				elseif mode == 2 and play ~= nil and not play.paused then -- 443
					play.paused = true -- 444
				end -- 444
				if fe ~= nil then -- 446
					fe.audio:setPaused(true) -- 447
				end -- 447
				return -- 449
			end -- 449
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 451
				if fe ~= nil then -- 452
					local paused = play ~= nil and play.paused and (mode == 1 and fe.screen == "play" or mode == 2) -- 453
					fe.audio:setPaused(paused) -- 455
				end -- 455
			end -- 455
		end -- 423
	) -- 423
	viewW = View.size.width -- 460
	viewH = View.size.height -- 461
	applySize() -- 462
	local reg = _G.package.loaded -- 465
	reg["watch.input"] = input -- 466
	reg["watch.touch"] = input:getTouchRouter() -- 467
	reg["watch.gamepad"] = input:getGamepadRouter() -- 468
	reg["watch.fe"] = { -- 469
		setScreen = function(sc) -- 470
			if fe == nil then -- 471
				return -- 472
			end -- 472
			setMode(1) -- 474
			fe.screen = sc -- 475
			if sc == "splash" then -- 476
				fe.menus:resetSplash() -- 477
			elseif sc == "chapters" then -- 478
				fe.menus:openChapters() -- 479
			elseif sc == "epilogue" then -- 480
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 481
			elseif sc == "history" then -- 485
				fe.menus:openHistory(false) -- 486
			else -- 486
				fe.menus:resetInput() -- 488
			end -- 488
			if sc == "play" then -- 490
				ensurePlay() -- 491
			end -- 491
		end, -- 470
		jumpRoom = function(keyOrIdx) -- 494
			local idx = -1 -- 495
			if type(keyOrIdx) == "number" then -- 496
				idx = keyOrIdx -- 497
			else -- 497
				local k = 0 -- 499
				do -- 499
					k = 0 -- 500
					while k < #ROOMS do -- 500
						if ROOMS[k + 1].key == keyOrIdx then -- 501
							idx = k -- 502
						end -- 502
						k = k + 1 -- 500
					end -- 500
				end -- 500
			end -- 500
			if idx >= 0 and idx < #ROOMS then -- 506
				enterPlayRoom(idx, "debug") -- 507
			end -- 507
		end, -- 494
		getPlay = function() return play end, -- 510
		getFrontend = function() return fe end, -- 511
		startStory = function() -- 513
			enterPlayRoom( -- 514
				officialStartIndex(), -- 514
				"official", -- 514
				true -- 514
			) -- 514
			return play -- 515
		end, -- 513
		previewChapter = function(idx) -- 518
			enterPlayRoom(idx, "chapter") -- 519
			return play -- 520
		end, -- 518
		getStoryRun = function() return storyRun end, -- 522
		getProfilePending = function() return profilePending() end, -- 523
		flushProfileNow = function() return flushProfile() end, -- 524
		getProfile = function() return profile end, -- 526
		getProfileStatus = function() return profileStatus end, -- 527
		getProfileDetail = function() return profileDetail end, -- 528
		useTestSave = function(name) -- 529
			setSaveFile(name) -- 530
			setSessionFile(name == "" and "" or name .. ".session") -- 531
			clearProfilePending() -- 532
			local loaded = loadSave() -- 533
			profile = loaded.state -- 534
			profileStatus = loaded.status -- 535
			profileDetail = loaded.detail -- 536
			refreshTitleSessionFlag() -- 537
		end, -- 529
		useTestSession = function(name) -- 539
			setSessionFile(name) -- 540
			refreshTitleSessionFlag() -- 541
		end, -- 539
		getSessionFile = getSessionFile, -- 543
		hasSessionSave = hasSessionSave, -- 544
		saveSessionNow = function() return saveCurrentSession() end, -- 545
		clearSessionNow = function() -- 546
			local ok = clearSession() -- 547
			refreshTitleSessionFlag() -- 548
			return ok -- 549
		end, -- 546
		continueStory = function() return continueOfficialStory() end, -- 551
		saveNow = function() return saveSave(profile) end, -- 552
		getSaveFile = getSaveFile, -- 553
		isRelease = function() return isReleaseBuild() end, -- 554
		getReleaseVersion = function() -- 555
			local ____opt_30 = getReleaseConfig() -- 555
			return ____opt_30 and ____opt_30.version or "dev" -- 555
		end, -- 555
		toggleFullscreen = function() return toggleFullscreen() end, -- 556
		quitGame = function() return quitGame() end, -- 557
		startTrial = function() return startTrial() end, -- 558
		handleBackButton = function() return handleBackButton() end, -- 559
		getViewport = function() return stageVp end, -- 560
		getTargetId = function() return getActiveTarget().id end, -- 561
		getTouchController = function() return input and input:getTouchControls() end, -- 562
		getTouchRouter = function() return input and input:getTouchRouter() end, -- 563
		getGamepad = function() return input and input:getGamepadRouter() end, -- 564
		setGamepadSim = function(state) -- 565
			if input ~= nil then -- 566
				input:setGamepadSim(state) -- 566
			end -- 566
		end, -- 565
		injectTouch = function(phase, id, x, y, fromMouse) -- 568
			if input ~= nil then -- 569
				input:injectTouch( -- 569
					phase, -- 569
					id, -- 569
					x, -- 569
					y, -- 569
					fromMouse -- 569
				) -- 569
			end -- 569
		end, -- 568
		getInputMode = function() return input and input.inputMode or getActiveTarget().defaultInputMode end, -- 571
		setInputMode = function(m) -- 572
			if input ~= nil then -- 573
				input:setInputMode(m) -- 573
			end -- 573
		end, -- 572
		setModePref = function(pref) -- 575
			if input ~= nil then -- 576
				input:setModePref(pref) -- 576
			end -- 576
		end, -- 575
		applyViewportForTest = function(w, h) -- 578
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 579
				testViewportOverride = {w = w, h = h} -- 580
				viewW = w -- 581
				viewH = h -- 582
			else -- 582
				testViewportOverride = nil -- 584
				viewW = View.size.width -- 585
				viewH = View.size.height -- 586
			end -- 586
			applySize() -- 588
			dirty = true -- 589
			return stageVp -- 590
		end, -- 578
		getToast = function() return fe and fe:getToastText() or "" end -- 592
	} -- 592
	if mode == 1 and startScreen == "play" then -- 595
		ensurePlay() -- 596
	end -- 596
	parent:schedule(function(frameDt) -- 599
		tick(frameDt) -- 600
		return false -- 601
	end) -- 599
end -- 328
local function pickByIndex(idx, source) -- 673
	if source == nil then -- 673
		source = "debug" -- 673
	end -- 673
	if mode == 2 then -- 674
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 675
			return -- 676
		end -- 676
		current = idx -- 678
		play = nil -- 679
		clock:reset() -- 680
		ensurePlay() -- 681
		return -- 682
	end -- 682
	if idx < 0 or idx >= #ROOMS then -- 684
		return -- 685
	end -- 685
	flushProfile() -- 687
	if storyRun ~= nil then -- 688
		storyRun.source = source -- 689
	end -- 689
	current = idx -- 691
	dirty = true -- 692
	play = nil -- 693
	clock:reset() -- 694
	if mode == 1 then -- 695
		if fe ~= nil then -- 696
			fe.screen = "play" -- 697
		end -- 697
		ensurePlay() -- 699
	end -- 699
end -- 673
return ____exports -- 673
