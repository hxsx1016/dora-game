-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, setMode, flushProfile, officialStartIndex, roomIndexByKey, applyChapterPreviewContext, enterPlayRoom, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, renderCampaign, drawCampaignHud, tickFrontend, root, campaignLayer, campaignHud, campaignSub, run, storyRun, profile, current, viewW, viewH, dirty, mode, input, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock, trialTalentSelected -- 70
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
		local has = hasSessionSave() -- 194
		fe.menus.hasSession = has -- 195
		if has then -- 196
			local loaded = loadSession() -- 197
			fe.menus:setSessionRoomKey(loaded.status == "ok" and loaded.state ~= nil and loaded.state.roomKey or "") -- 198
		else -- 198
			fe.menus:setSessionRoomKey("") -- 200
		end -- 200
	end -- 200
end -- 200
function saveCurrentSession() -- 205
	if not canSaveSession() or play == nil then -- 206
		return false -- 207
	end -- 207
	play.sessionDirty = false -- 209
	local ok = saveSession(play:exportSession()) -- 210
	refreshTitleSessionFlag() -- 211
	return ok -- 212
end -- 212
function continueOfficialStory() -- 215
	local res = loadSession() -- 216
	if res.status ~= "ok" or res.state == nil then -- 217
		refreshTitleSessionFlag() -- 218
		return nil -- 219
	end -- 219
	local s = res.state -- 221
	local idx = roomIndexByKey(s.roomKey) -- 222
	if ROOMS[idx + 1].key ~= s.roomKey then -- 223
		return nil -- 224
	end -- 224
	storyRun = createRun(s.seed, "official", profile) -- 226
	storyRun.checkpoint = s.checkpoint -- 227
	storyRun.story.route = s.route -- 228
	storyRun.story.hp = s.hp -- 229
	storyRun.story.maxHp = s.maxHp -- 230
	storyRun.story.hpAtGate = s.hpAtGate -- 231
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 232
	storyRun.story.settled = s.settled -- 233
	storyRun.story.phase = s.phase -- 234
	storyRun.story.countTick = s.countTick -- 235
	storyRun.story.phaseTick = s.phaseTick -- 236
	storyRun.story.handTicks = s.handTicks -- 237
	storyRun.story.handDone = s.handDone -- 238
	storyRun.story.lineSaid = s.lineSaid -- 239
	storyRun.story.tied = s.tied -- 240
	storyRun.story.carry = s.carry -- 241
	storyRun.story.escortDone = s.escortDone -- 242
	storyRun.story.craftedWeapon = s.craftedWeapon -- 243
	storyRun.story.equippedWeapon = s.equippedWeapon -- 244
	storyRun.inventory.wood = s.wood -- 245
	storyRun.inventory.bell = s.bell -- 246
	storyRun.inventory.scrap = s.scrap -- 247
	storyRun.inventory.wedge = s.wedge -- 248
	storyRun.inventory.ammo = s.ammo -- 249
	storyRun.inventory.shield = s.shield -- 250
	storyRun.inventory.pass = s.pass -- 251
	storyRun.inventory.quickbelt = s.quickbelt -- 252
	local k = 0 -- 253
	do -- 253
		k = 0 -- 254
		while k < #s.taken do -- 254
			storyRun.taken[s.taken[k + 1]] = true -- 255
			k = k + 1 -- 254
		end -- 254
	end -- 254
	do -- 254
		k = 0 -- 257
		while k < #s.segments do -- 257
			storyRun.story.segments[s.segments[k + 1]] = true -- 258
			k = k + 1 -- 257
		end -- 257
	end -- 257
	if s.campaignRoute ~= nil then -- 260
		storyRun.route = s.campaignRoute -- 261
	end -- 261
	if s.joined ~= nil then -- 263
		storyRun.joined = s.joined -- 264
	end -- 264
	if s.c1Latch ~= nil then -- 266
		storyRun.c1Latch = s.c1Latch -- 267
	end -- 267
	if s.c2Latch ~= nil then -- 269
		storyRun.c2Latch = s.c2Latch -- 270
	end -- 270
	if s.props ~= nil then -- 272
		do -- 272
			k = 0 -- 273
			while k < #s.props do -- 273
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 274
				local pid = parts[1] -- 275
				if pid ~= nil and pid ~= "" then -- 276
					local ____storyRun_props_16 = storyRun.props -- 277
					local ____temp_12 -- 278
					if parts[2] == nil then -- 278
						____temp_12 = true -- 278
					else -- 278
						____temp_12 = parts[2] == "1" -- 278
					end -- 278
					local ____temp_14 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 279
					local ____temp_15 = parts[4] == "1" -- 280
					local ____temp_13 -- 281
					if parts[5] == "1" then -- 281
						____temp_13 = true -- 281
					else -- 281
						____temp_13 = nil -- 281
					end -- 281
					____storyRun_props_16[pid] = {broken = ____temp_12, hp = ____temp_14, wedge = ____temp_15, revealed = ____temp_13} -- 277
				end -- 277
				k = k + 1 -- 273
			end -- 273
		end -- 273
	end -- 273
	local stTalents = createStoryTalents(s.seed) -- 286
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 287
		stTalents.randomState = s.talentSeed -- 288
	end -- 288
	stTalents.room = s.talentRoom or "" -- 290
	stTalents.ranks.vitality = s.talentVitality or 0 -- 291
	stTalents.ranks.reload = s.talentReload or 0 -- 292
	stTalents.ranks.guard = s.talentGuard or 0 -- 293
	stTalents.ranks.craft = s.talentCraft or 0 -- 294
	if s.talentOffers ~= nil then -- 295
		do -- 295
			k = 0 -- 296
			while k < #s.talentOffers do -- 296
				local t = s.talentOffers[k + 1] -- 297
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 298
					local ____stTalents_offers_17 = stTalents.offers -- 299
					____stTalents_offers_17[#____stTalents_offers_17 + 1] = t -- 299
				end -- 299
				k = k + 1 -- 296
			end -- 296
		end -- 296
	end -- 296
	storyRun.story.talents = stTalents -- 303
	current = idx -- 304
	setMode(1) -- 305
	if fe ~= nil then -- 306
		fe.screen = "play" -- 307
	end -- 307
	play = nil -- 309
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 310
	local cur = play -- 311
	if cur ~= nil then -- 312
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 313
			cur.cartAxle = s.cartAxle -- 314
			cur.cartDocked = s.cartDocked -- 315
		end -- 315
		if s.playerX ~= nil and s.playerX >= 0 then -- 317
			cur.player.x = math.max( -- 318
				cur.room.minX + 16, -- 318
				math.min(cur.room.maxX - 16, s.playerX) -- 318
			) -- 318
			cur.player.y = math.max(0, s.playerY or 0) -- 319
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 320
				cur.player.depth = math.max( -- 321
					cur.room.depth.min, -- 321
					math.min(cur.room.depth.max, s.playerDepth) -- 321
				) -- 321
			end -- 321
		end -- 321
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 324
			cur.gateTick = s.gateTick -- 325
		end -- 325
		if cur.room.key == "village" then -- 327
			if s.hasBottle == true then -- 328
				cur.hasBottle = true -- 328
			end -- 328
			if s.villagePassed == true then -- 329
				cur.passed = true -- 329
			end -- 329
		end -- 329
		if cur.room.key == "prologue" and (s.phase == "" or s.phase == "prologue-wake" or s.phase == "prologue-shadow" or s.phase == "prologue-escape" or s.phase == "prologue-hide") then -- 332
			cur.phase = "prologue-wake" -- 338
		end -- 338
		if (string.find(cur.room.key, "escort", nil, true) or 0) - 1 == 0 and s.route == "soldier" and not cur.craftBench.active and not cur.carryOn then -- 341
			cur.carryOn = true -- 342
			storyRun.story.carry = true -- 343
		end -- 343
	end -- 343
	return play -- 346
end -- 346
function setMode(nextMode) -- 626
	mode = nextMode -- 627
	if fe ~= nil then -- 628
		fe:setVisible(mode == 1) -- 629
	end -- 629
	if campaignLayer ~= nil then -- 631
		campaignLayer.visible = mode == 2 -- 632
	end -- 632
	dirty = true -- 634
	clock:reset() -- 635
end -- 635
function flushProfile() -- 642
	local cur = play -- 643
	if cur ~= nil and cur.archiveDirty then -- 644
		cur.archiveDirty = false -- 645
		markProfilePending(profile) -- 646
	end -- 646
	local ok = flushSaveProfile() -- 648
	if not ok and cur ~= nil then -- 649
		cur.archiveDirty = true -- 650
	end -- 650
	return ok -- 652
end -- 652
function officialStartIndex() -- 656
	local mp = profile.museumPhase -- 657
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 658
	return inMuseum and roomIndexByKey("museum") or 0 -- 659
end -- 659
function roomIndexByKey(key) -- 662
	local i = 0 -- 663
	do -- 663
		i = 0 -- 664
		while i < #ROOMS do -- 664
			if ROOMS[i + 1].key == key then -- 665
				return i -- 666
			end -- 666
			i = i + 1 -- 664
		end -- 664
	end -- 664
	return 0 -- 669
end -- 669
function applyChapterPreviewContext(targetRun, roomKey, routeOverride) -- 672
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" and routeOverride ~= "soldier" then -- 675
		targetRun.story.route = "child" -- 677
		targetRun.story.settled = true -- 678
		targetRun.story.countTick = 1440 -- 679
	elseif roomKey == "gatepath" or (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 or roomKey == "tower" and routeOverride == "soldier" then -- 680
		targetRun.story.route = "soldier" -- 682
		targetRun.story.settled = true -- 683
		targetRun.joined = true -- 684
		if (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 then -- 685
			targetRun.story.carry = true -- 686
		end -- 686
		if roomKey == "escort3" then -- 688
			targetRun.inventory.wood = math.max(targetRun.inventory.wood, 2) -- 689
			targetRun.inventory.scrap = math.max(targetRun.inventory.scrap, 2) -- 690
			targetRun.inventory.bell = math.max(targetRun.inventory.bell, 1) -- 691
			targetRun.inventory.wedge = math.max(targetRun.inventory.wedge, 1) -- 692
		end -- 692
	end -- 692
end -- 692
function enterPlayRoom(idx, source, fresh, chapterRoute) -- 697
	if source == nil then -- 697
		source = "debug" -- 697
	end -- 697
	if fresh == nil then -- 697
		fresh = false -- 697
	end -- 697
	current = idx -- 698
	setMode(1) -- 699
	if fe ~= nil then -- 700
		fe.screen = "play" -- 701
	end -- 701
	play = nil -- 703
	if fresh or source == "chapter" or storyRun == nil then -- 705
		storyRun = createRun(20261124, source, profile) -- 706
		if source == "chapter" then -- 707
			local targetKey = ROOMS[current + 1] ~= nil and ROOMS[current + 1].key or "" -- 708
			applyChapterPreviewContext(storyRun, targetKey, chapterRoute) -- 709
		end -- 709
	else -- 709
		storyRun.source = source -- 712
	end -- 712
	ensurePlay() -- 714
	local firstPlay = play -- 716
	if firstPlay ~= nil and ROOMS[current + 1].key == "prologue" and (fresh and source == "official" or source == "chapter") then -- 717
		firstPlay.phase = "prologue-wake" -- 719
	end -- 719
	flushProfile() -- 721
end -- 721
function applySize() -- 754
	if root == nil then -- 755
		return -- 756
	end -- 756
	root.size = Size(viewW, viewH) -- 758
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 759
	stageVp = computeStageViewport(viewW, viewH) -- 760
	if input ~= nil then -- 761
		input:setStageViewport(stageVp) -- 762
	end -- 762
	if fe ~= nil then -- 764
		fe:setStagePlacement(stageVp) -- 765
	end -- 765
	if campaignLayer ~= nil then -- 767
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 768
	end -- 768
end -- 768
function syncFrameAdapters(frameDt) -- 772
	if input == nil then -- 773
		return -- 774
	end -- 774
	local target = input.target -- 776
	if not target.supportsTouch and not target.supportsGamepad then -- 777
		return -- 778
	end -- 778
	local p = play -- 780
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 781
	local storyTalentBoxes = target.supportsTouch and isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 782
		p, -- 784
		stageVp.stageW, -- 784
		stageVp.stageH, -- 784
		input:isTouchMode() -- 784
	) or ({}) -- 785
	local isFs = false -- 787
	if target:canToggleFullscreen() then -- 788
		do -- 788
			local function ____catch() -- 788
				isFs = false -- 792
			end -- 792
			local ____try = pcall(function() -- 792
				isFs = App.fullScreen -- 790
			end) -- 790
			if not ____try then -- 790
				____catch() -- 790
			end -- 790
		end -- 790
	end -- 790
	local ____input_60 = input -- 795
	local ____input_syncFrame_61 = input.syncFrame -- 795
	local ____stageVp_54 = stageVp -- 796
	local ____mode_55 = mode -- 797
	local ____temp_56 = fe ~= nil and fe.screen or "title" -- 798
	local ____run_57 = run -- 800
	local ____temp_58 = fe and fe.cam -- 802
	local ____input_59 = input -- 803
	local ____temp_52 -- 804
	if fe ~= nil then -- 804
		____temp_52 = fe.contract:isAssistHintsEnabled() -- 804
	else -- 804
		____temp_52 = false -- 804
	end -- 804
	local ____temp_53 -- 805
	if fe ~= nil then -- 805
		____temp_53 = fe.audio:isAllMuted() -- 805
	else -- 805
		____temp_53 = false -- 805
	end -- 805
	____input_syncFrame_61(____input_60, { -- 795
		viewport = ____stageVp_54, -- 796
		mode = ____mode_55, -- 797
		screen = ____temp_56, -- 798
		play = p, -- 799
		run = ____run_57, -- 800
		cam = ____temp_58, -- 802
		input = ____input_59, -- 803
		assistHintsEnabled = ____temp_52, -- 804
		isMuted = ____temp_53, -- 805
		isFullscreen = isFs, -- 806
		storyTalentBoxes = storyTalentBoxes, -- 807
		dt = frameDt -- 808
	}) -- 808
end -- 808
function renderTouchOverlay() -- 812
	if input ~= nil then -- 813
		input:renderOverlay() -- 813
	end -- 813
end -- 813
function tick(frameDt) -- 816
	appClock = appClock + math.min( -- 817
		0.05, -- 817
		math.max(0, frameDt) -- 817
	) -- 817
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 818
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 819
	if w ~= viewW or h ~= viewH then -- 820
		viewW = w -- 821
		viewH = h -- 822
		applySize() -- 823
		dirty = true -- 824
	end -- 824
	if input == nil then -- 826
		return -- 827
	end -- 827
	syncFrameAdapters(frameDt) -- 829
	input:update() -- 830
	if input.userInteracted then -- 832
		onFirstUserGesture() -- 833
	end -- 833
	if input.muteTogglePressed and fe ~= nil then -- 835
		input.muteTogglePressed = false -- 836
		fe.audio:toggleAllMuted() -- 837
	end -- 837
	if input.fullscreenTogglePressed then -- 839
		input.fullscreenTogglePressed = false -- 840
		toggleFullscreen() -- 841
	end -- 841
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 843
		input.artifactTogglePressed = false -- 844
		play:toggleArtifactWeapon() -- 845
	end -- 845
	if input.bottleCanceled and play ~= nil then -- 847
		input.bottleCanceled = false -- 848
		play.aimHold = 0 -- 849
		play.bottleAimX = -1 -- 850
	end -- 850
	if mode == 2 and (run and run.trial) ~= nil then -- 853
		tickCampaign(frameDt) -- 854
		renderTouchOverlay() -- 855
		return -- 856
	end -- 856
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 859
		play:chooseTalent(input.pickRoom - 1) -- 862
		input.pickRoom = 0 -- 863
	end -- 863
	input.toggleView.pressed = false -- 867
	input.pickRoom = 0 -- 868
	input.tab.pressed = false -- 869
	if mode == 2 then -- 871
		tickCampaign(frameDt) -- 872
	elseif mode == 1 then -- 873
		tickFrontend(frameDt) -- 874
	end -- 874
	renderTouchOverlay() -- 876
end -- 876
function registerPlay() -- 880
	local reg = _G.package.loaded -- 881
	reg["watch.play"] = play -- 882
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 883
	reg["watch.room"] = rooms[current + 1].key -- 884
end -- 884
function ensurePlay(resume) -- 888
	if mode == 2 then -- 889
		if run == nil then -- 890
			run = createRun() -- 891
		end -- 891
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 893
	else -- 893
		if storyRun == nil then -- 897
			storyRun = createRun(20261124, "debug", profile) -- 898
		end -- 898
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 900
	end -- 900
	registerPlay() -- 902
	clock:reset() -- 903
	if fe ~= nil then -- 904
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 906
		if mode == 2 then -- 907
			fe:resetTrialAudio(play) -- 908
		end -- 908
	end -- 908
end -- 908
function startTrial() -- 913
	current = 0 -- 914
	trialTalentSelected = 0 -- 915
	run = createTrial(App.rand) -- 916
	setMode(2) -- 917
	ensurePlay() -- 918
end -- 918
function tickCampaign(frameDt) -- 921
	if input == nil then -- 922
		return -- 923
	end -- 923
	if play == nil then -- 925
		ensurePlay() -- 926
	end -- 926
	if play == nil then -- 928
		return -- 929
	end -- 929
	local p = play -- 931
	p.aimX = input.mx -- 932
	p.aimY = input.my -- 933
	local zoneTap = input.touchZoneTap -- 935
	input.touchZoneTap = "" -- 936
	local trial = run and run.trial -- 938
	if trial ~= nil then -- 939
		local ended = trial.lost or (run and run.finished) == true -- 940
		local pick = input.pickRoom -- 941
		input.pickRoom = 0 -- 942
		if zoneTap == "trial:resume" and p.paused and not ended then -- 944
			p.paused = false -- 945
			clock:reset() -- 946
			input:consumeEdges() -- 947
			renderCampaign(frameDt, p) -- 948
			return -- 949
		end -- 949
		if zoneTap == "trial:retry" then -- 951
			input:consumeEdges() -- 952
			startTrial() -- 953
			return -- 954
		end -- 954
		if zoneTap == "trial:title" then -- 956
			input:consumeEdges() -- 957
			current = 0 -- 958
			play = nil -- 959
			run = nil -- 960
			setMode(1) -- 961
			if fe ~= nil then -- 962
				fe.audio:stopRoomTransient() -- 963
				fe.screen = "title" -- 964
				fe.menus:resetInput() -- 965
			end -- 965
			return -- 967
		end -- 967
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 970
			input:consumeEdges() -- 971
			current = 0 -- 972
			play = nil -- 973
			run = nil -- 974
			setMode(1) -- 975
			if fe ~= nil then -- 976
				fe.audio:stopRoomTransient() -- 977
				fe.screen = "title" -- 978
				fe.menus:resetInput() -- 979
			end -- 979
			return -- 981
		end -- 981
		if ended or p.paused and input.retry.pressed then -- 983
			local restart = input.retry.pressed or ended and input.navConfirm -- 984
			input:consumeEdges() -- 985
			if restart then -- 986
				startTrial() -- 986
			else -- 986
				renderCampaign(frameDt, p) -- 987
			end -- 987
			return -- 988
		end -- 988
		input.retry.pressed = false -- 990
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 991
			if trialTalentSelected >= #trial.offers then -- 992
				trialTalentSelected = 0 -- 993
			end -- 993
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 995
				local idx = __TS__ParseInt( -- 996
					string.sub(zoneTap, 8), -- 996
					10 -- 996
				) -- 996
				if idx >= 0 and idx < #trial.offers then -- 997
					p:chooseTalent(idx) -- 998
				end -- 998
			elseif pick > 0 then -- 1000
				p:chooseTalent(pick - 1) -- 1001
			else -- 1001
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1003
				if delta ~= 0 then -- 1006
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1007
				end -- 1007
				if input.talentConfirm or input.navConfirm then -- 1009
					p:chooseTalent(trialTalentSelected) -- 1010
				end -- 1010
			end -- 1010
			input:consumeEdges() -- 1013
			clock:reset() -- 1014
			renderCampaign(frameDt, p) -- 1015
			return -- 1016
		end -- 1016
	end -- 1016
	if input.retry.pressed then -- 1020
		input.retry.pressed = false -- 1021
		input:consumeEdges() -- 1022
		play = nil -- 1024
		ensurePlay() -- 1025
		return -- 1026
	end -- 1026
	if input.pause.pressed or p.paused and input.navBack then -- 1028
		input.pause.pressed = false -- 1029
		p.paused = not p.paused -- 1030
		if fe ~= nil then -- 1031
			fe.audio:playUi(p.paused and "ui:pause_open" or "ui:pause_close", p.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 1031
		end -- 1031
		clock:reset() -- 1032
		input:consumeEdges() -- 1033
	end -- 1033
	if p.paused then -- 1035
		renderCampaign(frameDt, p) -- 1036
		return -- 1037
	end -- 1037
	local steps = clock:advance(frameDt) -- 1040
	local i = 0 -- 1041
	do -- 1041
		i = 0 -- 1042
		while i < steps do -- 1042
			input:beginStep(i == 0) -- 1043
			p:update(STEP, input) -- 1044
			input:endStep() -- 1045
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1046
				break -- 1047
			end -- 1047
			i = i + 1 -- 1042
		end -- 1042
	end -- 1042
	if p.wantRoom ~= "" then -- 1051
		local key = p.wantRoom -- 1052
		p.wantRoom = "" -- 1053
		local idx = -1 -- 1054
		local j = 0 -- 1055
		do -- 1055
			j = 0 -- 1056
			while j < #CAMPAIGN_ROOMS do -- 1056
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1057
					idx = j -- 1058
				end -- 1058
				j = j + 1 -- 1056
			end -- 1056
		end -- 1056
		if idx >= 0 then -- 1061
			current = idx -- 1062
			play = nil -- 1063
			ensurePlay() -- 1064
		end -- 1064
		return -- 1066
	end -- 1066
	renderCampaign(frameDt, p) -- 1068
end -- 1068
function goalLabel(goal) -- 1071
	if goal == "dock_cart" then -- 1072
		return "推车入窝并抬闩" -- 1073
	end -- 1073
	if goal == "raise_latch" then -- 1075
		return "抬闩开侧门" -- 1076
	end -- 1076
	return "到段出口" -- 1078
end -- 1078
function renderCampaign(frameDt, p) -- 1082
	if fe ~= nil and input ~= nil then -- 1083
		local ____opt_76 = run and run.trial -- 1085
		local offers = ____opt_76 and #____opt_76.offers or 0 -- 1085
		local ____p_paused_80 -- 1086
		if p.paused then -- 1086
			____p_paused_80 = nil -- 1086
		else -- 1086
			____p_paused_80 = fe.adapter:sample(p) -- 1086
		end -- 1086
		local ev = ____p_paused_80 -- 1086
		fe:renderPlay( -- 1087
			frameDt, -- 1087
			p, -- 1087
			input, -- 1087
			stageVp.stageW, -- 1087
			stageVp.stageH, -- 1087
			true, -- 1087
			ev -- 1087
		) -- 1087
		fe:syncTrialAudio(frameDt, p, offers, ev) -- 1088
	end -- 1088
	drawCampaignHud(p) -- 1090
end -- 1090
function drawCampaignHud(p) -- 1094
	local h = stageVp.stageH -- 1095
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1096
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1097
	local room = CAMPAIGN_ROOMS[current + 1] -- 1098
	local c = room.campaign -- 1099
	local r = run -- 1100
	local trial = r and r.trial -- 1101
	local gpMode = input ~= nil and input:isGamepadMode() -- 1102
	local touchMode = input ~= nil and input:isTouchMode() -- 1103
	local line = room.name -- 1106
	if trial == nil then -- 1107
		if c ~= nil then -- 1108
			line = (((line .. "  · 目标 ") .. goalLabel(c.goal)) .. "  · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0)) -- 1109
		end -- 1109
		if p.paused then -- 1111
			line = line .. "  · 已暂停" -- 1111
		end -- 1111
	else -- 1111
		line = (((((("护送试炼 · " .. room.name) .. "  · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. "  · ") .. mmss(r == nil and 0 or r.ticks) -- 1113
		if p.paused then -- 1114
			line = line .. "  · 暂停" -- 1114
		elseif trial.lost then -- 1115
			line = line .. "  · 护送失败" -- 1115
		elseif r ~= nil and r.finished then -- 1116
			line = line .. "  · 护送完成" -- 1116
		elseif #trial.offers > 0 then -- 1117
			line = line .. "  · 选择本段本领" -- 1117
		elseif c ~= nil then -- 1118
			line = line .. "  · " .. goalLabel(c.goal) -- 1118
		end -- 1118
	end -- 1118
	if campaignHud ~= nil then -- 1120
		campaignHud.text = line -- 1121
		campaignHud.position = Vec2(stageVp.stageW * 0.5, h - 12 - safeT) -- 1122
		campaignHud.visible = true -- 1123
	end -- 1123
	if campaignSub == nil then -- 1125
		return -- 1126
	end -- 1126
	local sub = p.flash -- 1128
	if trial ~= nil and r ~= nil then -- 1129
		local curMode = input ~= nil and input.inputMode or getActiveTarget().defaultInputMode -- 1130
		if trial.lost or r.finished then -- 1131
			sub = getActiveTarget():trialSubHint(curMode, true, r.seed) -- 1132
		elseif p.paused then -- 1133
			sub = getActiveTarget():trialSubHint(curMode, false, r.seed) -- 1134
		elseif #trial.offers > 0 then -- 1135
			sub = table.concat( -- 1136
				__TS__ArrayMap( -- 1136
					trial.offers, -- 1136
					function(____, talent, index) -- 1136
						local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1137
						return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1138
					end -- 1136
				), -- 1136
				"　" -- 1139
			) -- 1139
		elseif sub == "" then -- 1140
			sub = r.joined and "小满跟随" or "小满等待" -- 1141
		end -- 1141
	end -- 1141
	campaignSub.text = sub -- 1144
	campaignSub.position = Vec2(stageVp.stageW * 0.5, 14 + stageVp.safeUi.bottom * stageVp.uiScale) -- 1145
	campaignSub.visible = sub ~= "" -- 1146
end -- 1146
function tickFrontend(frameDt) -- 1149
	if fe == nil or input == nil then -- 1150
		return -- 1151
	end -- 1151
	if fe.screen ~= "play" then -- 1155
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1156
		input:consumeEdges() -- 1157
		if act.type == "splashDone" then -- 1158
			fe.menus:resetInput() -- 1159
			fe.screen = "title" -- 1160
		elseif act.type == "trial" then -- 1161
			startTrial() -- 1162
		elseif act.type == "continue" then -- 1163
			if continueOfficialStory() == nil then -- 1164
				enterPlayRoom( -- 1165
					officialStartIndex(), -- 1165
					"official", -- 1165
					true -- 1165
				) -- 1165
			end -- 1165
		elseif act.type == "start" then -- 1167
			clearSession() -- 1169
			refreshTitleSessionFlag() -- 1170
			enterPlayRoom( -- 1171
				officialStartIndex(), -- 1171
				"official", -- 1171
				true -- 1171
			) -- 1171
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1172
			enterPlayRoom(act.roomIndex, "chapter", false, act.route) -- 1173
		elseif act.type == "openChapters" then -- 1174
			fe.menus:openChapters() -- 1175
			fe.screen = "chapters" -- 1176
		elseif act.type == "openControls" then -- 1177
			fe.menus:resetInput() -- 1178
			fe.screen = "controls" -- 1179
		elseif act.type == "openHistory" then -- 1180
			fe.menus:openHistory(true) -- 1181
			fe.screen = "history" -- 1182
		elseif act.type == "backEpilogue" then -- 1183
			fe.menus:resetInput() -- 1184
			fe.screen = "epilogue" -- 1185
		elseif act.type == "replayStory" then -- 1186
			clearSession() -- 1187
			refreshTitleSessionFlag() -- 1188
			enterPlayRoom( -- 1189
				officialStartIndex(), -- 1189
				"official", -- 1189
				true -- 1189
			) -- 1189
		elseif act.type == "backTitle" then -- 1190
			fe.menus:resetInput() -- 1191
			fe.screen = "title" -- 1192
		elseif act.type == "backPause" then -- 1193
			fe.menus:resetInput() -- 1194
			fe.screen = "play" -- 1195
		elseif act.type == "quit" then -- 1196
			quitGame() -- 1197
		end -- 1197
		return -- 1199
	end -- 1199
	if play == nil then -- 1203
		ensurePlay() -- 1204
	end -- 1204
	if play == nil then -- 1206
		return -- 1207
	end -- 1207
	local p = play -- 1209
	p.aimX = input.mx -- 1211
	p.aimY = input.my -- 1212
	local zoneTap = input.touchZoneTap -- 1214
	input.touchZoneTap = "" -- 1215
	local offers = p:getStoryTalentOffers() -- 1217
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1218
		if fe.hud.talentSelected >= #offers then -- 1219
			fe.hud.talentSelected = 0 -- 1220
		end -- 1220
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1222
			local idx = __TS__ParseInt( -- 1223
				string.sub(zoneTap, 8), -- 1223
				10 -- 1223
			) -- 1223
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1224
				input.fire.pressed = false -- 1225
			end -- 1225
		else -- 1225
			if input.talentDelta ~= 0 then -- 1228
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1229
				input.talentDelta = 0 -- 1230
			end -- 1230
			if input.talentConfirm then -- 1232
				p:chooseTalent(fe.hud.talentSelected) -- 1233
				input.talentConfirm = false -- 1234
				input.fire.pressed = false -- 1235
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1236
				input.fire.pressed = false -- 1238
			end -- 1238
		end -- 1238
	end -- 1238
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1244
		if input.navConfirm then -- 1245
			input.interact.pressed = true -- 1246
		end -- 1246
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1248
			flushProfile() -- 1249
			if p.run.source == "official" and hasSessionSave() then -- 1250
				clearSession() -- 1251
				refreshTitleSessionFlag() -- 1252
			end -- 1252
			fe.audio:stopRoomTransient() -- 1254
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1255
			fe.screen = "epilogue" -- 1259
			input:clearTransient(true) -- 1260
			input:consumeEdges() -- 1261
			return -- 1262
		end -- 1262
	end -- 1262
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1266
		p:closeCraftBench() -- 1267
		input:consumeEdges() -- 1268
		return -- 1269
	end -- 1269
	if not p.paused and input.pause.pressed then -- 1271
		p.paused = true -- 1272
		p.aimHold = 0 -- 1273
		p.bottleAimX = -1 -- 1274
		saveCurrentSession() -- 1275
		fe.menus:openPause() -- 1276
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1277
		input:clearTransient(true) -- 1278
		input:consumeEdges() -- 1279
	end -- 1279
	if p.paused then -- 1282
		clock:reset() -- 1284
		local pauseAct = fe:renderPlay( -- 1285
			frameDt, -- 1285
			p, -- 1285
			input, -- 1285
			stageVp.stageW, -- 1285
			stageVp.stageH -- 1285
		) -- 1285
		input:consumeEdges() -- 1286
		if pauseAct.type == "resume" then -- 1287
			p.paused = false -- 1288
		elseif pauseAct.type == "retry" then -- 1289
			ensurePlay({checkpoint = p.checkpoint}) -- 1290
		elseif pauseAct.type == "openChapters" then -- 1291
			fe.audio:stopRoomTransient() -- 1292
			fe.audio:setPaused(false) -- 1293
			fe.menus:openChapters(current) -- 1294
			fe.screen = "chapters" -- 1295
		elseif pauseAct.type == "toggleFullscreen" then -- 1296
			toggleFullscreen() -- 1297
		elseif pauseAct.type == "quit" then -- 1298
			quitGame() -- 1299
		elseif pauseAct.type == "toTitle" then -- 1300
			saveCurrentSession() -- 1301
			refreshTitleSessionFlag() -- 1302
			fe.menus:resetInput() -- 1303
			fe.screen = "title" -- 1304
		end -- 1304
		return -- 1306
	end -- 1306
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1309
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1310
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1312
		input:consumeEdges() -- 1313
		ensurePlay({checkpoint = p.checkpoint}) -- 1315
		return -- 1316
	end -- 1316
	local steps = clock:advance(frameDt) -- 1319
	local i = 0 -- 1320
	do -- 1320
		i = 0 -- 1321
		while i < steps do -- 1321
			input:beginStep(i == 0) -- 1322
			p:update(STEP, input) -- 1323
			input:endStep() -- 1324
			if p.wantRoom ~= "" then -- 1325
				break -- 1326
			end -- 1326
			i = i + 1 -- 1321
		end -- 1321
	end -- 1321
	if p.wantRoom ~= "" then -- 1331
		local key = p.wantRoom -- 1332
		p.wantRoom = "" -- 1333
		local idx = -1 -- 1334
		local j = 0 -- 1335
		do -- 1335
			j = 0 -- 1336
			while j < #ROOMS do -- 1336
				if ROOMS[j + 1].key == key then -- 1337
					idx = j -- 1338
				end -- 1338
				j = j + 1 -- 1336
			end -- 1336
		end -- 1336
		if idx >= 0 then -- 1341
			flushProfile() -- 1345
			local leaving = p:drainEvents() -- 1346
			if p.restartStory then -- 1348
				if storyRun ~= nil and storyRun.source == "official" then -- 1349
					clearSession() -- 1350
					refreshTitleSessionFlag() -- 1351
				end -- 1351
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1353
				storyRun = createRun(20261124, nextSource, profile) -- 1354
			end -- 1354
			current = idx -- 1356
			ensurePlay() -- 1357
			local fresh = play -- 1358
			if fresh ~= nil then -- 1359
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1360
					fresh.phase = "prologue-wake" -- 1361
				end -- 1361
				fresh:adoptEvents(leaving) -- 1363
			end -- 1363
			if not p.restartStory then -- 1365
				saveCurrentSession() -- 1366
			end -- 1366
			clock:reset() -- 1368
			dirty = true -- 1369
		end -- 1369
		return -- 1371
	end -- 1371
	flushProfile() -- 1375
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1376
		clearSession() -- 1377
		refreshTitleSessionFlag() -- 1378
	elseif p.sessionDirty then -- 1379
		saveCurrentSession() -- 1380
	end -- 1380
	fe:renderPlay( -- 1382
		frameDt, -- 1382
		p, -- 1382
		input, -- 1382
		stageVp.stageW, -- 1382
		stageVp.stageH -- 1382
	) -- 1382
end -- 1382
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
function ____exports.start(parent, initialMode, startScreen) -- 349
	if initialMode == nil then -- 349
		initialMode = 1 -- 349
	end -- 349
	if startScreen == nil then -- 349
		startScreen = "title" -- 349
	end -- 349
	root = parent -- 350
	mode = initialMode -- 351
	campaignLayer = Node() -- 354
	campaignLayer.order = 6 -- 355
	campaignLayer:addTo(parent) -- 356
	campaignHud = Label(FONT, 24) -- 357
	if campaignHud ~= nil then -- 358
		campaignHud.color = C_TEXT -- 359
		campaignHud.anchor = Vec2(0.5, 1) -- 360
		campaignHud:addTo(campaignLayer) -- 361
		campaignHud.visible = true -- 362
	end -- 362
	campaignSub = Label(FONT, 20) -- 364
	if campaignSub ~= nil then -- 365
		campaignSub.color = C_ACCENT -- 366
		campaignSub.anchor = Vec2(0.5, 0) -- 367
		campaignSub:addTo(campaignLayer) -- 368
		campaignSub.visible = true -- 369
	end -- 369
	campaignLayer.visible = mode == 2 -- 371
	if mode == 1 then -- 375
		local loaded = loadSave() -- 376
		profile = loaded.state -- 377
		profileStatus = loaded.status -- 378
		profileDetail = loaded.detail -- 379
	end -- 379
	fe = __TS__New(WatchFrontend, parent) -- 381
	fe.screen = startScreen -- 382
	if startScreen == "splash" then -- 383
		fe.menus:resetSplash() -- 384
	end -- 384
	refreshTitleSessionFlag() -- 386
	fe:setVisible(mode == 1) -- 387
	if campaignLayer ~= nil then -- 388
		campaignLayer.visible = mode == 2 -- 389
	end -- 389
	input = __TS__New(Input) -- 392
	fe.audio:applyUserVolumes(input.settings) -- 393
	input:attach( -- 394
		parent, -- 394
		{ -- 394
			onFirstUserGesture = function() -- 395
				onFirstUserGesture() -- 396
				if input ~= nil then -- 397
					input:markKeyboardActivity() -- 397
				end -- 397
			end, -- 395
			onToggleFullscreen = function() -- 399
				toggleFullscreen() -- 400
			end, -- 399
			onKeyDownEvent = function(____, key) -- 402
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 403
					play:toggleArtifactWeapon() -- 404
					return -- 405
				end -- 405
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and #play:getStoryTalentOffers() > 0 then -- 407
					if key == "1" then -- 409
						play:chooseTalent(0) -- 410
						if input ~= nil then -- 411
							input:consumePickRoom() -- 411
						end -- 411
						return -- 412
					end -- 412
					if key == "2" then -- 414
						play:chooseTalent(1) -- 415
						if input ~= nil then -- 416
							input:consumePickRoom() -- 416
						end -- 416
						return -- 417
					end -- 417
					if key == "3" then -- 419
						play:chooseTalent(2) -- 420
						if input ~= nil then -- 421
							input:consumePickRoom() -- 421
						end -- 421
						return -- 422
					end -- 422
				end -- 422
				local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 425
				if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 426
					fe.menus:onKeyEvent(key) -- 427
				end -- 427
				if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay or mode == 2) then -- 429
					if key == "E" then -- 430
						input.interact.pressed = true -- 431
					elseif key == "Space" then -- 432
						input.jump.pressed = true -- 433
					elseif key == "Escape" then -- 434
						input.pause.pressed = true -- 435
					elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 436
						input.retry.pressed = true -- 437
					end -- 437
				end -- 437
			end -- 402
		} -- 402
	) -- 402
	parent:gslot( -- 444
		"AppEvent", -- 444
		function(eventType) -- 444
			if eventType == "BackButton" then -- 445
				handleBackButton() -- 446
				return -- 447
			end -- 447
			if eventType == "Quit" or eventType == "Shutdown" then -- 449
				flushProfile() -- 450
				saveCurrentSession() -- 451
				if input ~= nil then -- 452
					input:clearTransient(false) -- 452
				end -- 452
				return -- 453
			end -- 453
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 455
				flushProfile() -- 456
				saveCurrentSession() -- 457
				if input ~= nil then -- 458
					input:clearTransient(true) -- 458
				end -- 458
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 459
					play.paused = true -- 460
					play.aimHold = 0 -- 461
					play.bottleAimX = -1 -- 462
					fe.menus:openPause() -- 463
				elseif mode == 2 and play ~= nil and not play.paused then -- 464
					play.paused = true -- 465
				end -- 465
				if fe ~= nil then -- 467
					fe.audio:setPaused(true) -- 468
				end -- 468
				return -- 470
			end -- 470
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 472
				if fe ~= nil then -- 473
					local paused = play ~= nil and play.paused and (mode == 1 and fe.screen == "play" or mode == 2) -- 474
					fe.audio:setPaused(paused) -- 476
				end -- 476
			end -- 476
		end -- 444
	) -- 444
	viewW = View.size.width -- 481
	viewH = View.size.height -- 482
	applySize() -- 483
	local reg = _G.package.loaded -- 486
	reg["watch.input"] = input -- 487
	reg["watch.touch"] = input:getTouchRouter() -- 488
	reg["watch.gamepad"] = input:getGamepadRouter() -- 489
	reg["watch.fe"] = { -- 490
		setScreen = function(sc) -- 491
			if fe == nil then -- 492
				return -- 493
			end -- 493
			setMode(1) -- 495
			fe.screen = sc -- 496
			if sc == "splash" then -- 497
				fe.menus:resetSplash() -- 498
			elseif sc == "chapters" then -- 499
				fe.menus:openChapters() -- 500
			elseif sc == "epilogue" then -- 501
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 502
			elseif sc == "history" then -- 506
				fe.menus:openHistory(false) -- 507
			else -- 507
				fe.menus:resetInput() -- 509
			end -- 509
			if sc == "play" then -- 511
				ensurePlay() -- 512
			end -- 512
		end, -- 491
		jumpRoom = function(keyOrIdx) -- 515
			local idx = -1 -- 516
			if type(keyOrIdx) == "number" then -- 517
				idx = keyOrIdx -- 518
			else -- 518
				local k = 0 -- 520
				do -- 520
					k = 0 -- 521
					while k < #ROOMS do -- 521
						if ROOMS[k + 1].key == keyOrIdx then -- 522
							idx = k -- 523
						end -- 523
						k = k + 1 -- 521
					end -- 521
				end -- 521
			end -- 521
			if idx >= 0 and idx < #ROOMS then -- 527
				enterPlayRoom(idx, "debug") -- 528
			end -- 528
		end, -- 515
		getPlay = function() return play end, -- 531
		getFrontend = function() return fe end, -- 532
		startStory = function() -- 534
			enterPlayRoom( -- 535
				officialStartIndex(), -- 535
				"official", -- 535
				true -- 535
			) -- 535
			return play -- 536
		end, -- 534
		previewChapter = function(idx, route) -- 539
			enterPlayRoom(idx, "chapter", false, route) -- 540
			return play -- 541
		end, -- 539
		getStoryRun = function() return storyRun end, -- 543
		getProfilePending = function() return profilePending() end, -- 544
		flushProfileNow = function() return flushProfile() end, -- 545
		getProfile = function() return profile end, -- 547
		getProfileStatus = function() return profileStatus end, -- 548
		getProfileDetail = function() return profileDetail end, -- 549
		useTestSave = function(name) -- 550
			setSaveFile(name) -- 551
			setSessionFile(name == "" and "" or name .. ".session") -- 552
			clearProfilePending() -- 553
			local loaded = loadSave() -- 554
			profile = loaded.state -- 555
			profileStatus = loaded.status -- 556
			profileDetail = loaded.detail -- 557
			refreshTitleSessionFlag() -- 558
		end, -- 550
		useTestSession = function(name) -- 560
			setSessionFile(name) -- 561
			refreshTitleSessionFlag() -- 562
		end, -- 560
		getSessionFile = getSessionFile, -- 564
		hasSessionSave = hasSessionSave, -- 565
		saveSessionNow = function() return saveCurrentSession() end, -- 566
		clearSessionNow = function() -- 567
			local ok = clearSession() -- 568
			refreshTitleSessionFlag() -- 569
			return ok -- 570
		end, -- 567
		continueStory = function() return continueOfficialStory() end, -- 572
		saveNow = function() return saveSave(profile) end, -- 573
		getSaveFile = getSaveFile, -- 574
		isRelease = function() return isReleaseBuild() end, -- 575
		getReleaseVersion = function() -- 576
			local ____opt_30 = getReleaseConfig() -- 576
			return ____opt_30 and ____opt_30.version or "dev" -- 576
		end, -- 576
		toggleFullscreen = function() return toggleFullscreen() end, -- 577
		quitGame = function() return quitGame() end, -- 578
		startTrial = function() return startTrial() end, -- 579
		handleBackButton = function() return handleBackButton() end, -- 580
		getViewport = function() return stageVp end, -- 581
		getTargetId = function() return getActiveTarget().id end, -- 582
		getTouchController = function() return input and input:getTouchControls() end, -- 583
		getTouchRouter = function() return input and input:getTouchRouter() end, -- 584
		getGamepad = function() return input and input:getGamepadRouter() end, -- 585
		setGamepadSim = function(state) -- 586
			if input ~= nil then -- 587
				input:setGamepadSim(state) -- 587
			end -- 587
		end, -- 586
		injectTouch = function(phase, id, x, y, fromMouse) -- 589
			if input ~= nil then -- 590
				input:injectTouch( -- 590
					phase, -- 590
					id, -- 590
					x, -- 590
					y, -- 590
					fromMouse -- 590
				) -- 590
			end -- 590
		end, -- 589
		getInputMode = function() return input and input.inputMode or getActiveTarget().defaultInputMode end, -- 592
		setInputMode = function(m) -- 593
			if input ~= nil then -- 594
				input:setInputMode(m) -- 594
			end -- 594
		end, -- 593
		setModePref = function(pref) -- 596
			if input ~= nil then -- 597
				input:setModePref(pref) -- 597
			end -- 597
		end, -- 596
		applyViewportForTest = function(w, h) -- 599
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 600
				testViewportOverride = {w = w, h = h} -- 601
				viewW = w -- 602
				viewH = h -- 603
			else -- 603
				testViewportOverride = nil -- 605
				viewW = View.size.width -- 606
				viewH = View.size.height -- 607
			end -- 607
			applySize() -- 609
			dirty = true -- 610
			return stageVp -- 611
		end, -- 599
		getToast = function() return fe and fe:getToastText() or "" end -- 613
	} -- 613
	if mode == 1 and startScreen == "play" then -- 616
		ensurePlay() -- 617
	end -- 617
	parent:schedule(function(frameDt) -- 620
		tick(frameDt) -- 621
		return false -- 622
	end) -- 620
end -- 349
local function pickByIndex(idx, source) -- 724
	if source == nil then -- 724
		source = "debug" -- 724
	end -- 724
	if mode == 2 then -- 725
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 726
			return -- 727
		end -- 727
		current = idx -- 729
		play = nil -- 730
		clock:reset() -- 731
		ensurePlay() -- 732
		return -- 733
	end -- 733
	if idx < 0 or idx >= #ROOMS then -- 735
		return -- 736
	end -- 736
	flushProfile() -- 738
	if storyRun ~= nil then -- 739
		storyRun.source = source -- 740
	end -- 740
	current = idx -- 742
	dirty = true -- 743
	play = nil -- 744
	clock:reset() -- 745
	if mode == 1 then -- 746
		if fe ~= nil then -- 747
			fe.screen = "play" -- 748
		end -- 748
		ensurePlay() -- 750
	end -- 750
end -- 724
return ____exports -- 724
