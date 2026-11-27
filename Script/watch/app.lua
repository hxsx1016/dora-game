-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local isReleaseBuild, onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, place, setMode, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, pickByIndex, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock, trialTalentSelected -- 90
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
local ____platform = require("Script.watch.platform") -- 16
local canQuitApp = ____platform.canQuitApp -- 18
local canToggleFullscreen = ____platform.canToggleFullscreen -- 19
local computeStageViewport = ____platform.computeStageViewport -- 20
local getReleaseConfig = ____platform.getReleaseConfig -- 21
local isReleaseMode = ____platform.isReleaseMode -- 22
local ____target = require("Script.watch.target") -- 24
local getActiveTarget = ____target.getActiveTarget -- 24
local ____frontend = require("Script.watch.fe.frontend") -- 25
local WatchFrontend = ____frontend.WatchFrontend -- 25
local ____run = require("Script.watch.run") -- 26
local createRun = ____run.createRun -- 26
local createStoryTalents = ____run.createStoryTalents -- 26
local createTrial = ____run.createTrial -- 26
local mmss = ____run.mmss -- 26
local talentNames = ____run.talentNames -- 26
local ____save = require("Script.watch.save") -- 27
local emptySave = ____save.emptySave -- 27
local loadSave = ____save.loadSave -- 27
local saveSave = ____save.saveSave -- 27
local setSaveFile = ____save.setSaveFile -- 27
local getSaveFile = ____save.getSaveFile -- 27
local markProfilePending = ____save.markProfilePending -- 28
local flushSaveProfile = ____save.flushProfile -- 28
local clearProfilePending = ____save.clearProfilePending -- 28
local profilePending = ____save.profilePending -- 28
local loadSession = ____save.loadSession -- 29
local saveSession = ____save.saveSession -- 29
local clearSession = ____save.clearSession -- 29
local hasSessionSave = ____save.hasSessionSave -- 29
local setSessionFile = ____save.setSessionFile -- 29
local getSessionFile = ____save.getSessionFile -- 29
function isReleaseBuild() -- 90
	return isReleaseMode() -- 91
end -- 91
function onFirstUserGesture() -- 94
	if audioUnlocked or fe == nil then -- 95
		return -- 96
	end -- 96
	audioUnlocked = true -- 98
	fe.audio:unlockAndResyncAfterGesture() -- 99
end -- 99
function toggleFullscreen() -- 102
	if not canToggleFullscreen() then -- 103
		return false -- 104
	end -- 104
	do -- 104
		local function ____catch() -- 104
			return true, false -- 111
		end -- 111
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 111
			local next = not App.fullScreen -- 107
			App.fullScreen = next -- 108
			return true, next -- 109
		end) -- 109
		if not ____try then -- 109
			____hasReturned, ____returnValue = ____catch() -- 109
		end -- 109
		if ____hasReturned then -- 109
			return ____returnValue -- 106
		end -- 106
	end -- 106
end -- 106
function quitGame() -- 115
	flushProfile() -- 116
	saveCurrentSession() -- 117
	if input ~= nil then -- 118
		input:clearTransient(false) -- 118
	end -- 118
	if fe ~= nil then -- 119
		fe.audio:stopRoomTransient() -- 120
	end -- 120
	if not canQuitApp() then -- 122
		current = 0 -- 124
		play = nil -- 125
		run = nil -- 126
		setMode(1) -- 127
		if fe ~= nil then -- 128
			fe.audio:stopRoomTransient() -- 129
			fe.screen = "title" -- 130
			fe.menus:resetInput() -- 131
		end -- 131
		return -- 133
	end -- 133
	App:shutdown() -- 135
end -- 135
function canSaveSession() -- 207
	if mode ~= 1 or play == nil or storyRun == nil then -- 208
		return false -- 209
	end -- 209
	if storyRun.source ~= "official" or play.run.finished then -- 211
		return false -- 212
	end -- 212
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 214
		return false -- 215
	end -- 215
	return true -- 217
end -- 217
function refreshTitleSessionFlag() -- 220
	if fe ~= nil then -- 221
		fe.menus.hasSession = hasSessionSave() -- 222
	end -- 222
end -- 222
function saveCurrentSession() -- 226
	if not canSaveSession() or play == nil then -- 227
		return false -- 228
	end -- 228
	play.sessionDirty = false -- 230
	local ok = saveSession(play:exportSession()) -- 231
	refreshTitleSessionFlag() -- 232
	return ok -- 233
end -- 233
function continueOfficialStory() -- 236
	local res = loadSession() -- 237
	if res.status ~= "ok" or res.state == nil then -- 238
		refreshTitleSessionFlag() -- 239
		return nil -- 240
	end -- 240
	local s = res.state -- 242
	local idx = roomIndexByKey(s.roomKey) -- 243
	if ROOMS[idx + 1].key ~= s.roomKey then -- 244
		return nil -- 245
	end -- 245
	storyRun = createRun(s.seed, "official", profile) -- 247
	storyRun.checkpoint = s.checkpoint -- 248
	storyRun.story.route = s.route -- 249
	storyRun.story.hp = s.hp -- 250
	storyRun.story.maxHp = s.maxHp -- 251
	storyRun.story.hpAtGate = s.hpAtGate -- 252
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 253
	storyRun.story.settled = s.settled -- 254
	storyRun.story.phase = s.phase -- 255
	storyRun.story.countTick = s.countTick -- 256
	storyRun.story.phaseTick = s.phaseTick -- 257
	storyRun.story.handTicks = s.handTicks -- 258
	storyRun.story.handDone = s.handDone -- 259
	storyRun.story.lineSaid = s.lineSaid -- 260
	storyRun.story.tied = s.tied -- 261
	storyRun.story.carry = s.carry -- 262
	storyRun.story.escortDone = s.escortDone -- 263
	storyRun.story.craftedWeapon = s.craftedWeapon -- 264
	storyRun.story.equippedWeapon = s.equippedWeapon -- 265
	storyRun.inventory.wood = s.wood -- 266
	storyRun.inventory.bell = s.bell -- 267
	storyRun.inventory.scrap = s.scrap -- 268
	storyRun.inventory.wedge = s.wedge -- 269
	storyRun.inventory.ammo = s.ammo -- 270
	storyRun.inventory.shield = s.shield -- 271
	storyRun.inventory.pass = s.pass -- 272
	storyRun.inventory.quickbelt = s.quickbelt -- 273
	local k = 0 -- 274
	do -- 274
		k = 0 -- 275
		while k < #s.taken do -- 275
			storyRun.taken[s.taken[k + 1]] = true -- 276
			k = k + 1 -- 275
		end -- 275
	end -- 275
	do -- 275
		k = 0 -- 278
		while k < #s.segments do -- 278
			storyRun.story.segments[s.segments[k + 1]] = true -- 279
			k = k + 1 -- 278
		end -- 278
	end -- 278
	if s.campaignRoute ~= nil then -- 281
		storyRun.route = s.campaignRoute -- 282
	end -- 282
	if s.joined ~= nil then -- 284
		storyRun.joined = s.joined -- 285
	end -- 285
	if s.c1Latch ~= nil then -- 287
		storyRun.c1Latch = s.c1Latch -- 288
	end -- 288
	if s.c2Latch ~= nil then -- 290
		storyRun.c2Latch = s.c2Latch -- 291
	end -- 291
	if s.props ~= nil then -- 293
		do -- 293
			k = 0 -- 294
			while k < #s.props do -- 294
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 295
				local pid = parts[1] -- 296
				if pid ~= nil and pid ~= "" then -- 297
					local ____storyRun_props_16 = storyRun.props -- 298
					local ____temp_12 -- 299
					if parts[2] == nil then -- 299
						____temp_12 = true -- 299
					else -- 299
						____temp_12 = parts[2] == "1" -- 299
					end -- 299
					local ____temp_14 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 300
					local ____temp_15 = parts[4] == "1" -- 301
					local ____temp_13 -- 302
					if parts[5] == "1" then -- 302
						____temp_13 = true -- 302
					else -- 302
						____temp_13 = nil -- 302
					end -- 302
					____storyRun_props_16[pid] = {broken = ____temp_12, hp = ____temp_14, wedge = ____temp_15, revealed = ____temp_13} -- 298
				end -- 298
				k = k + 1 -- 294
			end -- 294
		end -- 294
	end -- 294
	local stTalents = createStoryTalents(s.seed) -- 307
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 308
		stTalents.randomState = s.talentSeed -- 309
	end -- 309
	stTalents.room = s.talentRoom or "" -- 311
	stTalents.ranks.vitality = s.talentVitality or 0 -- 312
	stTalents.ranks.reload = s.talentReload or 0 -- 313
	stTalents.ranks.guard = s.talentGuard or 0 -- 314
	stTalents.ranks.craft = s.talentCraft or 0 -- 315
	if s.talentOffers ~= nil then -- 316
		do -- 316
			k = 0 -- 317
			while k < #s.talentOffers do -- 317
				local t = s.talentOffers[k + 1] -- 318
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 319
					local ____stTalents_offers_17 = stTalents.offers -- 320
					____stTalents_offers_17[#____stTalents_offers_17 + 1] = t -- 320
				end -- 320
				k = k + 1 -- 317
			end -- 317
		end -- 317
	end -- 317
	storyRun.story.talents = stTalents -- 324
	current = idx -- 325
	setMode(1) -- 326
	if fe ~= nil then -- 327
		fe.screen = "play" -- 328
	end -- 328
	play = nil -- 330
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 331
	local cur = play -- 332
	if cur ~= nil then -- 333
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 334
			cur.cartAxle = s.cartAxle -- 335
			cur.cartDocked = s.cartDocked -- 336
		end -- 336
		if s.playerX ~= nil and s.playerX >= 0 then -- 338
			cur.player.x = math.max( -- 339
				cur.room.minX + 16, -- 339
				math.min(cur.room.maxX - 16, s.playerX) -- 339
			) -- 339
			cur.player.y = math.max(0, s.playerY or 0) -- 340
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 341
				cur.player.depth = math.max( -- 342
					cur.room.depth.min, -- 342
					math.min(cur.room.depth.max, s.playerDepth) -- 342
				) -- 342
			end -- 342
		end -- 342
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 345
			cur.gateTick = s.gateTick -- 346
		end -- 346
		if cur.room.key == "village" then -- 348
			if s.hasBottle == true then -- 349
				cur.hasBottle = true -- 349
			end -- 349
			if s.villagePassed == true then -- 350
				cur.passed = true -- 350
			end -- 350
		end -- 350
	end -- 350
	return play -- 353
end -- 353
function place(lb, x, y, ax, ay) -- 371
	if lb == nil then -- 372
		return -- 373
	end -- 373
	lb.position = Vec2(x, y) -- 375
	lb.anchor = Vec2(ax, ay) -- 376
	lb.visible = true -- 377
end -- 377
function setMode(nextMode) -- 719
	mode = nextMode -- 720
	if grayboxLayer ~= nil then -- 721
		grayboxLayer.visible = mode == 0 -- 722
	end -- 722
	if fe ~= nil then -- 724
		fe:setVisible(mode == 1) -- 725
	end -- 725
	if campaignLayer ~= nil then -- 727
		campaignLayer.visible = mode == 2 -- 728
	end -- 728
	dirty = true -- 730
	clock:reset() -- 731
end -- 731
function flushProfile() -- 738
	local cur = play -- 739
	if cur ~= nil and cur.archiveDirty then -- 740
		cur.archiveDirty = false -- 741
		markProfilePending(profile) -- 742
	end -- 742
	local ok = flushSaveProfile() -- 744
	if not ok and cur ~= nil then -- 745
		cur.archiveDirty = true -- 746
	end -- 746
	return ok -- 748
end -- 748
function officialStartIndex() -- 752
	local mp = profile.museumPhase -- 753
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 754
	return inMuseum and roomIndexByKey("museum") or 0 -- 755
end -- 755
function roomIndexByKey(key) -- 758
	local i = 0 -- 759
	do -- 759
		i = 0 -- 760
		while i < #ROOMS do -- 760
			if ROOMS[i + 1].key == key then -- 761
				return i -- 762
			end -- 762
			i = i + 1 -- 760
		end -- 760
	end -- 760
	return 0 -- 765
end -- 765
function enterPlayRoom(idx, source, fresh) -- 768
	if source == nil then -- 768
		source = "debug" -- 768
	end -- 768
	if fresh == nil then -- 768
		fresh = false -- 768
	end -- 768
	current = idx -- 769
	setMode(1) -- 770
	if fe ~= nil then -- 771
		fe.screen = "play" -- 772
	end -- 772
	play = nil -- 774
	if fresh or source == "chapter" or storyRun == nil then -- 776
		storyRun = createRun(20261124, source, profile) -- 777
	else -- 777
		storyRun.source = source -- 779
	end -- 779
	ensurePlay() -- 781
	local firstPlay = play -- 783
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 784
		firstPlay.phase = "prologue-wake" -- 785
	end -- 785
	flushProfile() -- 787
end -- 787
function pickByIndex(idx, source) -- 790
	if source == nil then -- 790
		source = "debug" -- 790
	end -- 790
	if mode == 2 then -- 791
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 792
			return -- 793
		end -- 793
		current = idx -- 795
		play = nil -- 796
		clock:reset() -- 797
		ensurePlay() -- 798
		return -- 799
	end -- 799
	if idx < 0 or idx >= #ROOMS then -- 801
		return -- 802
	end -- 802
	flushProfile() -- 804
	if storyRun ~= nil then -- 805
		storyRun.source = source -- 806
	end -- 806
	current = idx -- 808
	dirty = true -- 809
	play = nil -- 810
	clock:reset() -- 811
	if mode == 1 then -- 812
		if fe ~= nil then -- 813
			fe.screen = "play" -- 814
		end -- 814
		ensurePlay() -- 816
	end -- 816
end -- 816
function applySize() -- 820
	if root == nil then -- 821
		return -- 822
	end -- 822
	root.size = Size(viewW, viewH) -- 824
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 825
	stageVp = computeStageViewport(viewW, viewH) -- 826
	if input ~= nil then -- 827
		input:setStageViewport(stageVp) -- 828
	end -- 828
	if fe ~= nil then -- 830
		fe:setStagePlacement(stageVp) -- 831
	end -- 831
	if campaignLayer ~= nil then -- 833
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 834
	end -- 834
	if grayboxLayer ~= nil then -- 836
		grayboxLayer.position = Vec2(0, 0) -- 837
	end -- 837
end -- 837
function syncFrameAdapters(frameDt) -- 841
	if input == nil then -- 842
		return -- 843
	end -- 843
	local target = input.target -- 845
	if not target.supportsTouch and not target.supportsGamepad then -- 846
		return -- 847
	end -- 847
	local p = play -- 849
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 850
	local storyTalentBoxes = target.supportsTouch and isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 851
		p, -- 853
		stageVp.stageW, -- 853
		stageVp.stageH, -- 853
		input:isTouchMode() -- 853
	) or ({}) -- 854
	local isFs = false -- 856
	if target:canToggleFullscreen() then -- 857
		do -- 857
			local function ____catch() -- 857
				isFs = false -- 861
			end -- 861
			local ____try = pcall(function() -- 861
				isFs = App.fullScreen -- 859
			end) -- 859
			if not ____try then -- 859
				____catch() -- 859
			end -- 859
		end -- 859
	end -- 859
	local ____input_60 = input -- 864
	local ____input_syncFrame_61 = input.syncFrame -- 864
	local ____stageVp_54 = stageVp -- 865
	local ____mode_55 = mode -- 866
	local ____temp_56 = fe ~= nil and fe.screen or "title" -- 867
	local ____run_57 = run -- 869
	local ____temp_58 = fe ~= nil and fe.cam or nil -- 870
	local ____input_59 = input -- 871
	local ____temp_52 -- 872
	if fe ~= nil then -- 872
		____temp_52 = fe.contract:isAssistHintsEnabled() -- 872
	else -- 872
		____temp_52 = false -- 872
	end -- 872
	local ____temp_53 -- 873
	if fe ~= nil then -- 873
		____temp_53 = fe.audio:isAllMuted() -- 873
	else -- 873
		____temp_53 = false -- 873
	end -- 873
	____input_syncFrame_61(____input_60, { -- 864
		viewport = ____stageVp_54, -- 865
		mode = ____mode_55, -- 866
		screen = ____temp_56, -- 867
		play = p, -- 868
		run = ____run_57, -- 869
		cam = ____temp_58, -- 870
		input = ____input_59, -- 871
		assistHintsEnabled = ____temp_52, -- 872
		isMuted = ____temp_53, -- 873
		isFullscreen = isFs, -- 874
		storyTalentBoxes = storyTalentBoxes, -- 875
		dt = frameDt -- 876
	}) -- 876
end -- 876
function renderTouchOverlay() -- 880
	if input ~= nil then -- 881
		input:renderOverlay() -- 881
	end -- 881
end -- 881
function tick(frameDt) -- 884
	appClock = appClock + math.min( -- 885
		0.05, -- 885
		math.max(0, frameDt) -- 885
	) -- 885
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 886
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 887
	if w ~= viewW or h ~= viewH then -- 888
		viewW = w -- 889
		viewH = h -- 890
		applySize() -- 891
		dirty = true -- 892
	end -- 892
	if input == nil then -- 894
		return -- 895
	end -- 895
	syncFrameAdapters(frameDt) -- 897
	input:update() -- 898
	if input.userInteracted then -- 900
		onFirstUserGesture() -- 901
	end -- 901
	if input.muteTogglePressed and fe ~= nil then -- 903
		input.muteTogglePressed = false -- 904
		fe.audio:toggleAllMuted() -- 905
	end -- 905
	if input.fullscreenTogglePressed then -- 907
		input.fullscreenTogglePressed = false -- 908
		toggleFullscreen() -- 909
	end -- 909
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 911
		input.artifactTogglePressed = false -- 912
		play:toggleArtifactWeapon() -- 913
	end -- 913
	if input.bottleCanceled and play ~= nil then -- 915
		input.bottleCanceled = false -- 916
		play.aimHold = 0 -- 917
		play.bottleAimX = -1 -- 918
	end -- 918
	if mode == 2 and (run and run.trial) ~= nil then -- 921
		tickCampaign(frameDt) -- 922
		renderTouchOverlay() -- 923
		return -- 924
	end -- 924
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 927
		play:chooseTalent(input.pickRoom - 1) -- 930
		input.pickRoom = 0 -- 931
	end -- 931
	if isReleaseBuild() then -- 934
		input.toggleView.pressed = false -- 935
		input.pickRoom = 0 -- 936
		input.tab.pressed = false -- 937
	else -- 937
		if input.toggleView.pressed then -- 940
			input.toggleView.pressed = false -- 941
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 942
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 943
				ensurePlay() -- 944
			end -- 944
		end -- 944
		if input.pickRoom ~= 0 then -- 949
			local idx = input.pickRoom - 1 -- 950
			input.pickRoom = 0 -- 951
			pickByIndex(idx) -- 952
		elseif input.tab.pressed then -- 953
			input.tab.pressed = false -- 954
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 955
				pickByIndex((current + 1) % #ROOMS) -- 956
			end -- 956
		end -- 956
	end -- 956
	if mode == 2 then -- 961
		tickCampaign(frameDt) -- 962
	elseif mode == 1 then -- 963
		tickFrontend(frameDt) -- 964
	elseif dirty then -- 965
		redrawGraybox() -- 966
		dirty = false -- 967
	end -- 967
	renderTouchOverlay() -- 969
end -- 969
function registerPlay() -- 973
	local reg = _G.package.loaded -- 974
	reg["watch.play"] = play -- 975
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 976
	reg["watch.room"] = rooms[current + 1].key -- 977
end -- 977
function ensurePlay(resume) -- 981
	if mode == 2 then -- 982
		if run == nil then -- 983
			run = createRun() -- 984
		end -- 984
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 986
	else -- 986
		if storyRun == nil then -- 990
			storyRun = createRun(20261124, "debug", profile) -- 991
		end -- 991
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 993
	end -- 993
	registerPlay() -- 995
	clock:reset() -- 996
	if fe ~= nil and mode == 1 then -- 997
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 998
	elseif fe ~= nil and mode == 2 then -- 999
		fe:resetTrialAudio(play) -- 1000
	end -- 1000
end -- 1000
function startTrial() -- 1004
	current = 0 -- 1005
	trialTalentSelected = 0 -- 1006
	run = createTrial(App.rand) -- 1007
	setMode(2) -- 1008
	ensurePlay() -- 1009
end -- 1009
function tickCampaign(frameDt) -- 1012
	if input == nil then -- 1013
		return -- 1014
	end -- 1014
	if play == nil then -- 1016
		ensurePlay() -- 1017
	end -- 1017
	if play == nil then -- 1019
		return -- 1020
	end -- 1020
	local p = play -- 1022
	p.aimX = input.mx -- 1023
	p.aimY = input.my -- 1024
	local zoneTap = input.touchZoneTap -- 1026
	input.touchZoneTap = "" -- 1027
	local trial = run and run.trial -- 1029
	if trial ~= nil then -- 1030
		local ended = trial.lost or (run and run.finished) == true -- 1031
		local pick = input.pickRoom -- 1032
		input.pickRoom = 0 -- 1033
		if zoneTap == "trial:resume" and p.paused and not ended then -- 1035
			p.paused = false -- 1036
			clock:reset() -- 1037
			input:consumeEdges() -- 1038
			drawCampaign(p) -- 1039
			return -- 1040
		end -- 1040
		if zoneTap == "trial:retry" then -- 1042
			input:consumeEdges() -- 1043
			startTrial() -- 1044
			return -- 1045
		end -- 1045
		if zoneTap == "trial:title" then -- 1047
			input:consumeEdges() -- 1048
			current = 0 -- 1049
			play = nil -- 1050
			run = nil -- 1051
			setMode(1) -- 1052
			if fe ~= nil then -- 1053
				fe.audio:stopRoomTransient() -- 1054
				fe.screen = "title" -- 1055
				fe.menus:resetInput() -- 1056
			end -- 1056
			return -- 1058
		end -- 1058
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1061
			input:consumeEdges() -- 1062
			current = 0 -- 1063
			play = nil -- 1064
			run = nil -- 1065
			setMode(1) -- 1066
			if fe ~= nil then -- 1067
				fe.audio:stopRoomTransient() -- 1068
				fe.screen = "title" -- 1069
				fe.menus:resetInput() -- 1070
			end -- 1070
			return -- 1072
		end -- 1072
		if ended or p.paused and input.retry.pressed then -- 1074
			local restart = input.retry.pressed or ended and input.navConfirm -- 1075
			input:consumeEdges() -- 1076
			if restart then -- 1077
				startTrial() -- 1077
			else -- 1077
				drawCampaign(p) -- 1078
			end -- 1078
			return -- 1079
		end -- 1079
		input.retry.pressed = false -- 1081
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1082
			if trialTalentSelected >= #trial.offers then -- 1083
				trialTalentSelected = 0 -- 1084
			end -- 1084
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1086
				local idx = __TS__ParseInt( -- 1087
					string.sub(zoneTap, 8), -- 1087
					10 -- 1087
				) -- 1087
				if idx >= 0 and idx < #trial.offers then -- 1088
					p:chooseTalent(idx) -- 1089
				end -- 1089
			elseif pick > 0 then -- 1091
				p:chooseTalent(pick - 1) -- 1092
			else -- 1092
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1094
				if delta ~= 0 then -- 1097
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1098
				end -- 1098
				if input.talentConfirm or input.navConfirm then -- 1100
					p:chooseTalent(trialTalentSelected) -- 1101
				end -- 1101
			end -- 1101
			input:consumeEdges() -- 1104
			clock:reset() -- 1105
			if fe ~= nil then -- 1106
				fe:syncTrialAudio(frameDt, p, #trial.offers) -- 1106
			end -- 1106
			drawCampaign(p) -- 1107
			return -- 1108
		end -- 1108
	end -- 1108
	if input.retry.pressed then -- 1112
		input.retry.pressed = false -- 1113
		input:consumeEdges() -- 1114
		play = nil -- 1116
		ensurePlay() -- 1117
		return -- 1118
	end -- 1118
	if input.pause.pressed or p.paused and input.navBack then -- 1120
		input.pause.pressed = false -- 1121
		p.paused = not p.paused -- 1122
		if fe ~= nil then -- 1123
			fe.audio:playUi(p.paused and "ui:pause_open" or "ui:pause_close", p.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 1123
		end -- 1123
		clock:reset() -- 1124
		input:consumeEdges() -- 1125
	end -- 1125
	if p.paused then -- 1127
		if fe ~= nil then -- 1128
			fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1128
		end -- 1128
		drawCampaign(p) -- 1129
		return -- 1130
	end -- 1130
	local steps = clock:advance(frameDt) -- 1133
	local i = 0 -- 1134
	do -- 1134
		i = 0 -- 1135
		while i < steps do -- 1135
			input:beginStep(i == 0) -- 1136
			p:update(STEP, input) -- 1137
			input:endStep() -- 1138
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1139
				break -- 1140
			end -- 1140
			i = i + 1 -- 1135
		end -- 1135
	end -- 1135
	if fe ~= nil then -- 1143
		fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1143
	end -- 1143
	if p.wantRoom ~= "" then -- 1145
		local key = p.wantRoom -- 1146
		p.wantRoom = "" -- 1147
		local idx = -1 -- 1148
		local j = 0 -- 1149
		do -- 1149
			j = 0 -- 1150
			while j < #CAMPAIGN_ROOMS do -- 1150
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1151
					idx = j -- 1152
				end -- 1152
				j = j + 1 -- 1150
			end -- 1150
		end -- 1150
		if idx >= 0 then -- 1155
			current = idx -- 1156
			play = nil -- 1157
			ensurePlay() -- 1158
		end -- 1158
		return -- 1160
	end -- 1160
	drawCampaign(p) -- 1162
end -- 1162
function goalLabel(goal) -- 1165
	if goal == "dock_cart" then -- 1166
		return "推车入窝并抬闩" -- 1167
	end -- 1167
	if goal == "raise_latch" then -- 1169
		return "抬闩开侧门" -- 1170
	end -- 1170
	return "到段出口" -- 1172
end -- 1172
function drawCampaign(p) -- 1175
	if campaignDraw == nil then -- 1176
		return -- 1177
	end -- 1177
	local w = stageVp.stageW -- 1179
	local h = stageVp.stageH -- 1180
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1181
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1182
	p:draw(campaignDraw, w, h) -- 1183
	local room = CAMPAIGN_ROOMS[current + 1] -- 1184
	local c = room.campaign -- 1185
	local r = run -- 1186
	local line = room.name -- 1187
	if c ~= nil then -- 1188
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget * 60) -- 1189
	end -- 1189
	if p.paused then -- 1192
		line = line .. "  · 已暂停 Esc 继续" -- 1193
	end -- 1193
	local trial = r and r.trial -- 1195
	if trial ~= nil and r ~= nil then -- 1196
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 1197
		if p.paused then -- 1198
			line = line .. " · 暂停" -- 1198
		elseif trial.lost then -- 1199
			line = line .. " · 护送失败" -- 1199
		elseif r.finished then -- 1200
			line = line .. " · 护送完成" -- 1200
		elseif #trial.offers > 0 then -- 1201
			line = line .. " · 选择本段本领" -- 1201
		elseif c ~= nil then -- 1202
			line = line .. " · " .. goalLabel(c.goal) -- 1202
		end -- 1202
	end -- 1202
	if campaignHud ~= nil then -- 1204
		campaignHud.text = line -- 1205
		campaignHud.position = Vec2(24 + safeL, h - 14 - safeT) -- 1206
		campaignHud.visible = true -- 1207
	end -- 1207
	if campaignSub ~= nil then -- 1209
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 1210
		if r ~= nil then -- 1211
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 1212
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 1213
		end -- 1213
		if p.flash ~= "" then -- 1218
			sub = (sub .. " · ") .. p.flash -- 1219
		end -- 1219
		if trial ~= nil and r ~= nil then -- 1221
			local gpMode = input ~= nil and input:isGamepadMode() -- 1222
			local curMode = input ~= nil and input.inputMode or getActiveTarget().defaultInputMode -- 1223
			if trial.lost or r.finished then -- 1224
				sub = getActiveTarget():trialSubHint(curMode, true, r.seed) -- 1225
			elseif p.paused then -- 1226
				sub = getActiveTarget():trialSubHint(curMode, false, r.seed) -- 1227
			elseif #trial.offers > 0 then -- 1228
				sub = table.concat( -- 1229
					__TS__ArrayMap( -- 1229
						trial.offers, -- 1229
						function(____, talent, index) -- 1229
							local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1230
							return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1231
						end -- 1229
					), -- 1229
					"　" -- 1232
				) -- 1232
			else -- 1232
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 1234
			end -- 1234
		end -- 1234
		campaignSub.text = sub -- 1237
		campaignSub.position = Vec2(24 + safeL, h - 44 - safeT) -- 1238
		campaignSub.visible = true -- 1239
	end -- 1239
end -- 1239
function tickFrontend(frameDt) -- 1243
	if fe == nil or input == nil then -- 1244
		return -- 1245
	end -- 1245
	if fe.screen ~= "play" then -- 1249
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1250
		input:consumeEdges() -- 1251
		if act.type == "splashDone" then -- 1252
			fe.menus:resetInput() -- 1253
			fe.screen = "title" -- 1254
		elseif act.type == "trial" then -- 1255
			startTrial() -- 1256
		elseif act.type == "continue" then -- 1257
			if continueOfficialStory() == nil then -- 1258
				enterPlayRoom( -- 1259
					officialStartIndex(), -- 1259
					"official", -- 1259
					true -- 1259
				) -- 1259
			end -- 1259
		elseif act.type == "start" then -- 1261
			clearSession() -- 1263
			refreshTitleSessionFlag() -- 1264
			enterPlayRoom( -- 1265
				officialStartIndex(), -- 1265
				"official", -- 1265
				true -- 1265
			) -- 1265
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1266
			enterPlayRoom(act.roomIndex, "chapter") -- 1267
		elseif act.type == "openChapters" then -- 1268
			fe.menus:openChapters() -- 1269
			fe.screen = "chapters" -- 1270
		elseif act.type == "openControls" then -- 1271
			fe.menus:resetInput() -- 1272
			fe.screen = "controls" -- 1273
		elseif act.type == "openHistory" then -- 1274
			fe.menus:openHistory(true) -- 1275
			fe.screen = "history" -- 1276
		elseif act.type == "backEpilogue" then -- 1277
			fe.menus:resetInput() -- 1278
			fe.screen = "epilogue" -- 1279
		elseif act.type == "replayStory" then -- 1280
			clearSession() -- 1281
			refreshTitleSessionFlag() -- 1282
			enterPlayRoom( -- 1283
				officialStartIndex(), -- 1283
				"official", -- 1283
				true -- 1283
			) -- 1283
		elseif act.type == "backTitle" then -- 1284
			fe.menus:resetInput() -- 1285
			fe.screen = "title" -- 1286
		elseif act.type == "backPause" then -- 1287
			fe.menus:resetInput() -- 1288
			fe.screen = "play" -- 1289
		elseif act.type == "quit" then -- 1290
			quitGame() -- 1291
		end -- 1291
		return -- 1293
	end -- 1293
	if play == nil then -- 1297
		ensurePlay() -- 1298
	end -- 1298
	if play == nil then -- 1300
		return -- 1301
	end -- 1301
	local p = play -- 1303
	p.aimX = input.mx -- 1305
	p.aimY = input.my -- 1306
	local zoneTap = input.touchZoneTap -- 1308
	input.touchZoneTap = "" -- 1309
	local offers = p:getStoryTalentOffers() -- 1311
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1312
		if fe.hud.talentSelected >= #offers then -- 1313
			fe.hud.talentSelected = 0 -- 1314
		end -- 1314
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1316
			local idx = __TS__ParseInt( -- 1317
				string.sub(zoneTap, 8), -- 1317
				10 -- 1317
			) -- 1317
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1318
				input.fire.pressed = false -- 1319
			end -- 1319
		else -- 1319
			if input.talentDelta ~= 0 then -- 1322
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1323
				input.talentDelta = 0 -- 1324
			end -- 1324
			if input.talentConfirm then -- 1326
				p:chooseTalent(fe.hud.talentSelected) -- 1327
				input.talentConfirm = false -- 1328
				input.fire.pressed = false -- 1329
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1330
				input.fire.pressed = false -- 1332
			end -- 1332
		end -- 1332
	end -- 1332
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1338
		if input.navConfirm then -- 1339
			input.interact.pressed = true -- 1340
		end -- 1340
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1342
			flushProfile() -- 1343
			if p.run.source == "official" and hasSessionSave() then -- 1344
				clearSession() -- 1345
				refreshTitleSessionFlag() -- 1346
			end -- 1346
			fe.audio:stopRoomTransient() -- 1348
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1349
			fe.screen = "epilogue" -- 1353
			input:clearTransient(true) -- 1354
			input:consumeEdges() -- 1355
			return -- 1356
		end -- 1356
	end -- 1356
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1360
		p:closeCraftBench() -- 1361
		input:consumeEdges() -- 1362
		return -- 1363
	end -- 1363
	if not p.paused and input.pause.pressed then -- 1365
		p.paused = true -- 1366
		p.aimHold = 0 -- 1367
		p.bottleAimX = -1 -- 1368
		saveCurrentSession() -- 1369
		fe.menus:openPause() -- 1370
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1371
		input:clearTransient(true) -- 1372
		input:consumeEdges() -- 1373
	end -- 1373
	if p.paused then -- 1376
		clock:reset() -- 1378
		local pauseAct = fe:renderPlay( -- 1379
			frameDt, -- 1379
			p, -- 1379
			input, -- 1379
			stageVp.stageW, -- 1379
			stageVp.stageH -- 1379
		) -- 1379
		input:consumeEdges() -- 1380
		if pauseAct.type == "resume" then -- 1381
			p.paused = false -- 1382
		elseif pauseAct.type == "retry" then -- 1383
			ensurePlay({checkpoint = p.checkpoint}) -- 1384
		elseif pauseAct.type == "openChapters" then -- 1385
			fe.audio:stopRoomTransient() -- 1386
			fe.audio:setPaused(false) -- 1387
			fe.menus:openChapters(current) -- 1388
			fe.screen = "chapters" -- 1389
		elseif pauseAct.type == "toggleFullscreen" then -- 1390
			toggleFullscreen() -- 1391
		elseif pauseAct.type == "quit" then -- 1392
			quitGame() -- 1393
		elseif pauseAct.type == "toTitle" then -- 1394
			saveCurrentSession() -- 1395
			refreshTitleSessionFlag() -- 1396
			fe.menus:resetInput() -- 1397
			fe.screen = "title" -- 1398
		end -- 1398
		return -- 1400
	end -- 1400
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1403
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1404
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1406
		input:consumeEdges() -- 1407
		ensurePlay({checkpoint = p.checkpoint}) -- 1409
		return -- 1410
	end -- 1410
	local steps = clock:advance(frameDt) -- 1413
	local i = 0 -- 1414
	do -- 1414
		i = 0 -- 1415
		while i < steps do -- 1415
			input:beginStep(i == 0) -- 1416
			p:update(STEP, input) -- 1417
			input:endStep() -- 1418
			if p.wantRoom ~= "" then -- 1419
				break -- 1420
			end -- 1420
			i = i + 1 -- 1415
		end -- 1415
	end -- 1415
	if p.wantRoom ~= "" then -- 1425
		local key = p.wantRoom -- 1426
		p.wantRoom = "" -- 1427
		local idx = -1 -- 1428
		local j = 0 -- 1429
		do -- 1429
			j = 0 -- 1430
			while j < #ROOMS do -- 1430
				if ROOMS[j + 1].key == key then -- 1431
					idx = j -- 1432
				end -- 1432
				j = j + 1 -- 1430
			end -- 1430
		end -- 1430
		if idx >= 0 then -- 1435
			flushProfile() -- 1439
			local leaving = p:drainEvents() -- 1440
			if p.restartStory then -- 1442
				if storyRun ~= nil and storyRun.source == "official" then -- 1443
					clearSession() -- 1444
					refreshTitleSessionFlag() -- 1445
				end -- 1445
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1447
				storyRun = createRun(20261124, nextSource, profile) -- 1448
			end -- 1448
			current = idx -- 1450
			ensurePlay() -- 1451
			local fresh = play -- 1452
			if fresh ~= nil then -- 1453
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1454
					fresh.phase = "prologue-wake" -- 1455
				end -- 1455
				fresh:adoptEvents(leaving) -- 1457
			end -- 1457
			if not p.restartStory then -- 1459
				saveCurrentSession() -- 1460
			end -- 1460
			clock:reset() -- 1462
			dirty = true -- 1463
		end -- 1463
		return -- 1465
	end -- 1465
	flushProfile() -- 1469
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1470
		clearSession() -- 1471
		refreshTitleSessionFlag() -- 1472
	elseif p.sessionDirty then -- 1473
		saveCurrentSession() -- 1474
	end -- 1474
	fe:renderPlay( -- 1476
		frameDt, -- 1476
		p, -- 1476
		input, -- 1476
		stageVp.stageW, -- 1476
		stageVp.stageH -- 1476
	) -- 1476
end -- 1476
function redrawGraybox() -- 1480
	if draw == nil then -- 1481
		return -- 1482
	end -- 1482
	local w = viewW -- 1484
	local h = viewH -- 1485
	local room = ROOMS[current + 1] -- 1486
	draw:clear() -- 1488
	draw:drawRect( -- 1489
		Rect(0, h - TOP_H, w, TOP_H), -- 1489
		C_BG -- 1489
	) -- 1489
	draw:drawRect( -- 1490
		Rect(0, 0, w, BOTTOM_H), -- 1490
		C_BG -- 1490
	) -- 1490
	draw:drawSegment( -- 1491
		Vec2(0, h - TOP_H), -- 1491
		Vec2(w, h - TOP_H), -- 1491
		1, -- 1491
		Color(52, 54, 54, 255) -- 1491
	) -- 1491
	draw:drawSegment( -- 1492
		Vec2(0, BOTTOM_H), -- 1492
		Vec2(w, BOTTOM_H), -- 1492
		1, -- 1492
		Color(52, 54, 54, 255) -- 1492
	) -- 1492
	local v = computeView(room, w, h) -- 1494
	renderWorld( -- 1495
		draw, -- 1495
		room, -- 1495
		v, -- 1495
		w, -- 1495
		h -- 1495
	) -- 1495
	local roomTop = v.groundPx + room.height * v.scale -- 1497
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1498
	place( -- 1500
		titleLabel, -- 1500
		48, -- 1500
		h - 40, -- 1500
		0, -- 1500
		1 -- 1500
	) -- 1500
	place( -- 1501
		roomLabel, -- 1501
		48, -- 1501
		h - 96, -- 1501
		0, -- 1501
		1 -- 1501
	) -- 1501
	place( -- 1502
		captionLabel, -- 1502
		48, -- 1502
		h - 140, -- 1502
		0, -- 1502
		1 -- 1502
	) -- 1502
	place( -- 1504
		switchLabel, -- 1504
		48, -- 1504
		40, -- 1504
		0, -- 1504
		0 -- 1504
	) -- 1504
	place( -- 1505
		hintLabel, -- 1505
		48, -- 1505
		84, -- 1505
		0, -- 1505
		0 -- 1505
	) -- 1505
	place( -- 1506
		rulerLabel, -- 1506
		w - 216, -- 1506
		roomTop + 36 + v.scale * 0.5 - 14, -- 1506
		1, -- 1506
		0 -- 1506
	) -- 1506
	place( -- 1507
		standLabel, -- 1507
		48, -- 1507
		roomTop + 40, -- 1507
		0, -- 1507
		0 -- 1507
	) -- 1507
	place( -- 1508
		cartLabel, -- 1508
		48, -- 1508
		roomTop + 92, -- 1508
		0, -- 1508
		0 -- 1508
	) -- 1508
	if roomLabel ~= nil then -- 1510
		roomLabel.text = room.name -- 1511
	end -- 1511
	if captionLabel ~= nil then -- 1513
		captionLabel.text = room.caption -- 1514
	end -- 1514
	if hintLabel ~= nil then -- 1516
		local hintIdx = math.min(current, #HINTS - 1) -- 1517
		local lines = HINTS[hintIdx + 1] -- 1518
		local merged = lines[1] -- 1519
		do -- 1519
			local i = 1 -- 1520
			while i < #lines do -- 1520
				merged = (merged .. "    ") .. lines[i + 1] -- 1521
				i = i + 1 -- 1520
			end -- 1520
		end -- 1520
		hintLabel.text = merged -- 1523
	end -- 1523
	local specs = collectLabels(room, v, w) -- 1526
	local body = {} -- 1527
	local small = {} -- 1528
	do -- 1528
		local i = 0 -- 1529
		while i < #specs do -- 1529
			local s = specs[i + 1] -- 1530
			if s.size >= 24 then -- 1531
				body[#body + 1] = s -- 1532
			else -- 1532
				small[#small + 1] = s -- 1534
			end -- 1534
			i = i + 1 -- 1529
		end -- 1529
	end -- 1529
	applyPool(body, poolBody) -- 1537
	applyPool(small, poolSmall) -- 1538
	if LAYOUT_AUDIT then -- 1540
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1541
	end -- 1541
end -- 1541
function applyPool(specs, pool) -- 1545
	do -- 1545
		local i = 0 -- 1546
		while i < #pool do -- 1546
			local lb = pool[i + 1] -- 1547
			if i < #specs then -- 1548
				local s = specs[i + 1] -- 1549
				lb.text = s.text -- 1550
				lb.position = Vec2(s.x, s.y) -- 1551
				lb.anchor = Vec2(s.ax, s.ay) -- 1552
				lb.color = s.color -- 1553
				lb.visible = true -- 1554
			else -- 1554
				lb.visible = false -- 1556
			end -- 1556
			i = i + 1 -- 1546
		end -- 1546
	end -- 1546
end -- 1546
local FONT = "sarasa-mono-sc-regular" -- 34
LAYOUT_AUDIT = false -- 35
local C_TEXT = Color(236, 236, 232, 255) -- 37
local C_DIM = Color(150, 154, 152, 255) -- 38
local C_ACCENT = Color(226, 186, 84, 255) -- 39
C_BG = Color(17, 18, 19, 255) -- 40
local POOL_BODY = 30 -- 42
local POOL_SMALL = 44 -- 43
TOP_H = 208 -- 44
BOTTOM_H = 216 -- 45
profile = emptySave() -- 63
local profileStatus = "missing" -- 64
local profileDetail = "" -- 65
poolBody = {} -- 70
poolSmall = {} -- 71
current = 0 -- 73
viewW = 0 -- 74
viewH = 0 -- 75
dirty = true -- 76
mode = 1 -- 78
clock = __TS__New(StepClock) -- 82
stageVp = computeStageViewport(1280, 720) -- 83
audioUnlocked = false -- 85
appClock = 0 -- 86
local lastBackPressClock = -10 -- 87
trialTalentSelected = 0 -- 88
local function handleBackButton() -- 138
	if mode == 0 then -- 139
		setMode(1) -- 140
		return -- 141
	end -- 141
	if mode == 2 and play ~= nil then -- 143
		local trial = run and run.trial -- 144
		if trial ~= nil and (trial.lost or (run and run.finished) == true) then -- 145
			current = 0 -- 146
			play = nil -- 147
			run = nil -- 148
			setMode(1) -- 149
			if fe ~= nil then -- 150
				fe.audio:stopRoomTransient() -- 151
				fe.screen = "title" -- 152
				fe.menus:resetInput() -- 153
			end -- 153
			return -- 155
		end -- 155
		play.paused = not play.paused -- 157
		if fe ~= nil then -- 158
			fe.audio:playUi(play.paused and "ui:pause_open" or "ui:pause_close", play.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 158
		end -- 158
		clock:reset() -- 159
		if input ~= nil then -- 160
			input:clearTransient(true) -- 160
		end -- 160
		return -- 161
	end -- 161
	if fe == nil then -- 163
		return -- 164
	end -- 164
	if fe.screen == "splash" then -- 166
		fe.menus:resetSplash() -- 167
		fe.screen = "title" -- 168
		fe.menus:resetInput() -- 169
		return -- 170
	end -- 170
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "epilogue" or fe.screen == "history" then -- 172
		fe.menus:triggerBack() -- 173
		return -- 174
	end -- 174
	if fe.screen == "title" then -- 176
		if not canQuitApp() then -- 177
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 178
			return -- 179
		end -- 179
		if appClock - lastBackPressClock <= 2 then -- 181
			quitGame() -- 182
		else -- 182
			lastBackPressClock = appClock -- 184
			fe:showToast("再按一次返回退出游戏", 2) -- 185
		end -- 185
		return -- 187
	end -- 187
	if fe.screen == "play" and play ~= nil then -- 189
		if play.paused then -- 190
			fe.menus:triggerBack() -- 191
			return -- 192
		end -- 192
		if play.craftBench.active then -- 194
			play:closeCraftBench() -- 195
			return -- 196
		end -- 196
		play.paused = true -- 198
		play.aimHold = 0 -- 199
		play.bottleAimX = -1 -- 200
		saveCurrentSession() -- 201
		fe.menus:openPause() -- 202
		if input ~= nil then -- 203
			input:clearTransient(true) -- 203
		end -- 203
	end -- 203
end -- 138
local function makeGrayboxLabel(text, size, color) -- 356
	if grayboxLayer == nil then -- 357
		return nil -- 358
	end -- 358
	local lb = Label(FONT, size) -- 360
	if lb == nil then -- 361
		return nil -- 362
	end -- 362
	lb.text = text -- 364
	lb.color = color -- 365
	lb:addTo(grayboxLayer) -- 366
	lb.visible = true -- 367
	return lb -- 368
end -- 356
function ____exports.start(parent, initialMode, startScreen) -- 380
	if initialMode == nil then -- 380
		initialMode = 1 -- 380
	end -- 380
	if startScreen == nil then -- 380
		startScreen = "title" -- 380
	end -- 380
	root = parent -- 381
	mode = initialMode -- 382
	grayboxLayer = Node() -- 385
	grayboxLayer.order = 2 -- 386
	grayboxLayer:addTo(parent) -- 387
	draw = DrawNode() -- 389
	draw:addTo(grayboxLayer) -- 390
	campaignLayer = Node() -- 393
	campaignLayer.order = 3 -- 394
	campaignLayer:addTo(parent) -- 395
	campaignDraw = DrawNode() -- 396
	campaignDraw:addTo(campaignLayer) -- 397
	campaignHud = Label(FONT, 24) -- 398
	if campaignHud ~= nil then -- 399
		campaignHud.color = C_TEXT -- 400
		campaignHud.anchor = Vec2(0, 1) -- 401
		campaignHud:addTo(campaignLayer) -- 402
		campaignHud.visible = true -- 403
	end -- 403
	campaignSub = Label(FONT, 20) -- 405
	if campaignSub ~= nil then -- 406
		campaignSub.color = C_ACCENT -- 407
		campaignSub.anchor = Vec2(0, 1) -- 408
		campaignSub:addTo(campaignLayer) -- 409
		campaignSub.visible = true -- 410
	end -- 410
	campaignLayer.visible = mode == 2 -- 412
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 414
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 415
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 416
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 417
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 418
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 419
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 420
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 421
	do -- 421
		local i = 0 -- 423
		while i < POOL_BODY do -- 423
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 424
			if lb ~= nil then -- 425
				poolBody[#poolBody + 1] = lb -- 426
			end -- 426
			i = i + 1 -- 423
		end -- 423
	end -- 423
	do -- 423
		local i = 0 -- 429
		while i < POOL_SMALL do -- 429
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 430
			if lb ~= nil then -- 431
				poolSmall[#poolSmall + 1] = lb -- 432
			end -- 432
			i = i + 1 -- 429
		end -- 429
	end -- 429
	if mode == 1 then -- 438
		local loaded = loadSave() -- 439
		profile = loaded.state -- 440
		profileStatus = loaded.status -- 441
		profileDetail = loaded.detail -- 442
	end -- 442
	fe = __TS__New(WatchFrontend, parent) -- 444
	fe.screen = startScreen -- 445
	if startScreen == "splash" then -- 446
		fe.menus:resetSplash() -- 447
	end -- 447
	refreshTitleSessionFlag() -- 449
	grayboxLayer.visible = mode == 0 -- 450
	fe:setVisible(mode == 1) -- 451
	if campaignLayer ~= nil then -- 452
		campaignLayer.visible = mode == 2 -- 453
	end -- 453
	input = __TS__New(Input) -- 456
	fe.audio:applyUserVolumes(input.settings) -- 457
	input:attach( -- 458
		parent, -- 458
		{ -- 458
			onFirstUserGesture = function() -- 459
				onFirstUserGesture() -- 460
				if input ~= nil then -- 461
					input:markKeyboardActivity() -- 461
				end -- 461
			end, -- 459
			onToggleFullscreen = function() -- 463
				toggleFullscreen() -- 464
			end, -- 463
			onKeyDownEvent = function(____, key) -- 466
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 467
					play:toggleArtifactWeapon() -- 468
					return -- 469
				end -- 469
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and #play:getStoryTalentOffers() > 0 then -- 471
					if key == "1" then -- 473
						play:chooseTalent(0) -- 474
						if input ~= nil then -- 475
							input:consumePickRoom() -- 475
						end -- 475
						return -- 476
					end -- 476
					if key == "2" then -- 478
						play:chooseTalent(1) -- 479
						if input ~= nil then -- 480
							input:consumePickRoom() -- 480
						end -- 480
						return -- 481
					end -- 481
					if key == "3" then -- 483
						play:chooseTalent(2) -- 484
						if input ~= nil then -- 485
							input:consumePickRoom() -- 485
						end -- 485
						return -- 486
					end -- 486
				end -- 486
				local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 489
				if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 490
					fe.menus:onKeyEvent(key) -- 491
				end -- 491
				if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay or mode == 2) then -- 493
					if key == "E" then -- 494
						input.interact.pressed = true -- 495
					elseif key == "Space" then -- 496
						input.jump.pressed = true -- 497
					elseif key == "Escape" then -- 498
						input.pause.pressed = true -- 499
					elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 500
						input.retry.pressed = true -- 501
					end -- 501
				end -- 501
				if mode == 2 and (run and run.trial) ~= nil then -- 504
					return -- 504
				end -- 504
				if isReleaseBuild() then -- 505
					return -- 505
				end -- 505
				if key == "F1" then -- 506
					if mode == 2 then -- 507
						current = 0 -- 508
						play = nil -- 509
						ensurePlay() -- 510
					else -- 510
						enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 512
					end -- 512
				elseif key == "F2" then -- 514
					setMode(0) -- 515
				elseif key == "1" then -- 516
					pickByIndex(0) -- 517
				elseif key == "2" then -- 518
					pickByIndex(1) -- 519
				elseif key == "3" then -- 520
					pickByIndex(2) -- 521
				elseif key == "4" then -- 522
					pickByIndex(3) -- 523
				elseif key == "5" then -- 524
					pickByIndex(4) -- 525
				elseif key == "6" then -- 526
					pickByIndex(5) -- 527
				elseif key == "7" then -- 528
					pickByIndex(6) -- 529
				elseif key == "8" then -- 530
					pickByIndex(7) -- 531
				end -- 531
			end -- 466
		} -- 466
	) -- 466
	parent:gslot( -- 537
		"AppEvent", -- 537
		function(eventType) -- 537
			if eventType == "BackButton" then -- 538
				handleBackButton() -- 539
				return -- 540
			end -- 540
			if eventType == "Quit" or eventType == "Shutdown" then -- 542
				flushProfile() -- 543
				saveCurrentSession() -- 544
				if input ~= nil then -- 545
					input:clearTransient(false) -- 545
				end -- 545
				return -- 546
			end -- 546
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 548
				flushProfile() -- 549
				saveCurrentSession() -- 550
				if input ~= nil then -- 551
					input:clearTransient(true) -- 551
				end -- 551
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 552
					play.paused = true -- 553
					play.aimHold = 0 -- 554
					play.bottleAimX = -1 -- 555
					fe.menus:openPause() -- 556
				elseif mode == 2 and play ~= nil and not play.paused then -- 557
					play.paused = true -- 558
				end -- 558
				if fe ~= nil then -- 560
					fe.audio:setPaused(true) -- 561
				end -- 561
				return -- 563
			end -- 563
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 565
				if fe ~= nil then -- 566
					local paused = play ~= nil and play.paused and (mode == 1 and fe.screen == "play" or mode == 2) -- 567
					fe.audio:setPaused(paused) -- 569
				end -- 569
			end -- 569
		end -- 537
	) -- 537
	viewW = View.size.width -- 574
	viewH = View.size.height -- 575
	applySize() -- 576
	local reg = _G.package.loaded -- 579
	reg["watch.input"] = input -- 580
	reg["watch.touch"] = input:getTouchRouter() -- 581
	reg["watch.gamepad"] = input:getGamepadRouter() -- 582
	reg["watch.fe"] = { -- 583
		setScreen = function(sc) -- 584
			if fe == nil then -- 585
				return -- 586
			end -- 586
			setMode(1) -- 588
			fe.screen = sc -- 589
			if sc == "splash" then -- 590
				fe.menus:resetSplash() -- 591
			elseif sc == "chapters" then -- 592
				fe.menus:openChapters() -- 593
			elseif sc == "epilogue" then -- 594
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 595
			elseif sc == "history" then -- 599
				fe.menus:openHistory(false) -- 600
			else -- 600
				fe.menus:resetInput() -- 602
			end -- 602
			if sc == "play" then -- 604
				ensurePlay() -- 605
			end -- 605
		end, -- 584
		jumpRoom = function(keyOrIdx) -- 608
			local idx = -1 -- 609
			if type(keyOrIdx) == "number" then -- 610
				idx = keyOrIdx -- 611
			else -- 611
				local k = 0 -- 613
				do -- 613
					k = 0 -- 614
					while k < #ROOMS do -- 614
						if ROOMS[k + 1].key == keyOrIdx then -- 615
							idx = k -- 616
						end -- 616
						k = k + 1 -- 614
					end -- 614
				end -- 614
			end -- 614
			if idx >= 0 and idx < #ROOMS then -- 620
				enterPlayRoom(idx, "debug") -- 621
			end -- 621
		end, -- 608
		getPlay = function() return play end, -- 624
		getFrontend = function() return fe end, -- 625
		startStory = function() -- 627
			enterPlayRoom( -- 628
				officialStartIndex(), -- 628
				"official", -- 628
				true -- 628
			) -- 628
			return play -- 629
		end, -- 627
		previewChapter = function(idx) -- 632
			enterPlayRoom(idx, "chapter") -- 633
			return play -- 634
		end, -- 632
		getStoryRun = function() return storyRun end, -- 636
		getProfilePending = function() return profilePending() end, -- 637
		flushProfileNow = function() return flushProfile() end, -- 638
		getProfile = function() return profile end, -- 640
		getProfileStatus = function() return profileStatus end, -- 641
		getProfileDetail = function() return profileDetail end, -- 642
		useTestSave = function(name) -- 643
			setSaveFile(name) -- 644
			setSessionFile(name == "" and "" or name .. ".session") -- 645
			clearProfilePending() -- 646
			local loaded = loadSave() -- 647
			profile = loaded.state -- 648
			profileStatus = loaded.status -- 649
			profileDetail = loaded.detail -- 650
			refreshTitleSessionFlag() -- 651
		end, -- 643
		useTestSession = function(name) -- 653
			setSessionFile(name) -- 654
			refreshTitleSessionFlag() -- 655
		end, -- 653
		getSessionFile = getSessionFile, -- 657
		hasSessionSave = hasSessionSave, -- 658
		saveSessionNow = function() return saveCurrentSession() end, -- 659
		clearSessionNow = function() -- 660
			local ok = clearSession() -- 661
			refreshTitleSessionFlag() -- 662
			return ok -- 663
		end, -- 660
		continueStory = function() return continueOfficialStory() end, -- 665
		saveNow = function() return saveSave(profile) end, -- 666
		getSaveFile = getSaveFile, -- 667
		isRelease = function() return isReleaseBuild() end, -- 668
		getReleaseVersion = function() -- 669
			local ____opt_32 = getReleaseConfig() -- 669
			return ____opt_32 and ____opt_32.version or "dev" -- 669
		end, -- 669
		toggleFullscreen = function() return toggleFullscreen() end, -- 670
		quitGame = function() return quitGame() end, -- 671
		startTrial = function() return startTrial() end, -- 672
		handleBackButton = function() return handleBackButton() end, -- 673
		getViewport = function() return stageVp end, -- 674
		getTargetId = function() return getActiveTarget().id end, -- 675
		getTouchController = function() return input and input:getTouchControls() end, -- 676
		getTouchRouter = function() return input and input:getTouchRouter() end, -- 677
		getGamepad = function() return input and input:getGamepadRouter() end, -- 678
		setGamepadSim = function(state) -- 679
			if input ~= nil then -- 680
				input:setGamepadSim(state) -- 680
			end -- 680
		end, -- 679
		injectTouch = function(phase, id, x, y, fromMouse) -- 682
			if input ~= nil then -- 683
				input:injectTouch( -- 683
					phase, -- 683
					id, -- 683
					x, -- 683
					y, -- 683
					fromMouse -- 683
				) -- 683
			end -- 683
		end, -- 682
		getInputMode = function() return input and input.inputMode or getActiveTarget().defaultInputMode end, -- 685
		setInputMode = function(m) -- 686
			if input ~= nil then -- 687
				input:setInputMode(m) -- 687
			end -- 687
		end, -- 686
		setModePref = function(pref) -- 689
			if input ~= nil then -- 690
				input:setModePref(pref) -- 690
			end -- 690
		end, -- 689
		applyViewportForTest = function(w, h) -- 692
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 693
				testViewportOverride = {w = w, h = h} -- 694
				viewW = w -- 695
				viewH = h -- 696
			else -- 696
				testViewportOverride = nil -- 698
				viewW = View.size.width -- 699
				viewH = View.size.height -- 700
			end -- 700
			applySize() -- 702
			dirty = true -- 703
			return stageVp -- 704
		end, -- 692
		getToast = function() return fe and fe:getToastText() or "" end -- 706
	} -- 706
	if mode == 1 and startScreen == "play" then -- 709
		ensurePlay() -- 710
	end -- 710
	parent:schedule(function(frameDt) -- 713
		tick(frameDt) -- 714
		return false -- 715
	end) -- 713
end -- 380
return ____exports -- 380
