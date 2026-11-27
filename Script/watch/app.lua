-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local isReleaseBuild, onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, place, setMode, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, pickByIndex, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, touchRouter, gamepadRouter, touchControls, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock, trialTalentSelected -- 1
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
local ____aim_assist = require("Script.watch.aim_assist") -- 15
local collectPlayAimTargets = ____aim_assist.collectPlayAimTargets -- 15
local collectTrialAimTargets = ____aim_assist.collectTrialAimTargets -- 15
local ____gamepad = require("Script.watch.gamepad") -- 17
local GamepadRouter = ____gamepad.GamepadRouter -- 17
local ____platform = require("Script.watch.platform") -- 18
local canQuitApp = ____platform.canQuitApp -- 20
local canToggleFullscreen = ____platform.canToggleFullscreen -- 21
local computeStageViewport = ____platform.computeStageViewport -- 22
local getReleaseConfig = ____platform.getReleaseConfig -- 23
local isReleaseMode = ____platform.isReleaseMode -- 24
local ____touch = require("Script.watch.touch") -- 26
local TouchRouter = ____touch.TouchRouter -- 26
local ____frontend = require("Script.watch.fe.frontend") -- 27
local WatchFrontend = ____frontend.WatchFrontend -- 27
local ____run = require("Script.watch.run") -- 28
local createRun = ____run.createRun -- 28
local createStoryTalents = ____run.createStoryTalents -- 28
local createTrial = ____run.createTrial -- 28
local mmss = ____run.mmss -- 28
local talentNames = ____run.talentNames -- 28
local ____save = require("Script.watch.save") -- 29
local emptySave = ____save.emptySave -- 29
local loadSave = ____save.loadSave -- 29
local saveSave = ____save.saveSave -- 29
local setSaveFile = ____save.setSaveFile -- 29
local getSaveFile = ____save.getSaveFile -- 29
local markProfilePending = ____save.markProfilePending -- 30
local flushSaveProfile = ____save.flushProfile -- 30
local clearProfilePending = ____save.clearProfilePending -- 30
local profilePending = ____save.profilePending -- 30
local loadSession = ____save.loadSession -- 31
local saveSession = ____save.saveSession -- 31
local clearSession = ____save.clearSession -- 31
local hasSessionSave = ____save.hasSessionSave -- 31
local setSessionFile = ____save.setSessionFile -- 31
local getSessionFile = ____save.getSessionFile -- 31
local ____touch_controls = require("Script.watch.fe.ui.touch_controls") -- 33
local TouchControls = ____touch_controls.TouchControls -- 33
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 34
local isCutsceneBlockingPlay = ____control_prompts.isCutsceneBlockingPlay -- 34
function isReleaseBuild() -- 97
	return isReleaseMode() -- 98
end -- 98
function onFirstUserGesture() -- 101
	if audioUnlocked or fe == nil then -- 101
		return -- 103
	end -- 103
	audioUnlocked = true -- 105
	fe.audio:unlockAndResyncAfterGesture() -- 106
end -- 106
function toggleFullscreen() -- 109
	if not canToggleFullscreen() then -- 109
		return false -- 111
	end -- 111
	do -- 111
		local function ____catch() -- 111
			return true, false -- 118
		end -- 118
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 118
			local next = not App.fullScreen -- 114
			App.fullScreen = next -- 115
			return true, next -- 116
		end) -- 116
		if not ____try then -- 116
			____hasReturned, ____returnValue = ____catch() -- 116
		end -- 116
		if ____hasReturned then -- 116
			return ____returnValue -- 113
		end -- 113
	end -- 113
end -- 113
function quitGame() -- 122
	flushProfile() -- 123
	saveCurrentSession() -- 124
	if input ~= nil then -- 124
		input:clearTransient(false) -- 125
	end -- 125
	if fe ~= nil then -- 125
		fe.audio:stopRoomTransient() -- 127
	end -- 127
	if not canQuitApp() then -- 127
		current = 0 -- 131
		play = nil -- 132
		run = nil -- 133
		setMode(1) -- 134
		if fe ~= nil then -- 134
			fe.audio:stopRoomTransient() -- 136
			fe.screen = "title" -- 137
			fe.menus:resetInput() -- 138
		end -- 138
		return -- 140
	end -- 140
	App:shutdown() -- 142
end -- 142
function canSaveSession() -- 214
	if mode ~= 1 or play == nil or storyRun == nil then -- 214
		return false -- 216
	end -- 216
	if storyRun.source ~= "official" or play.run.finished then -- 216
		return false -- 219
	end -- 219
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 219
		return false -- 222
	end -- 222
	return true -- 224
end -- 224
function refreshTitleSessionFlag() -- 227
	if fe ~= nil then -- 227
		fe.menus.hasSession = hasSessionSave() -- 229
	end -- 229
end -- 229
function saveCurrentSession() -- 233
	if not canSaveSession() or play == nil then -- 233
		return false -- 235
	end -- 235
	play.sessionDirty = false -- 237
	local ok = saveSession(play:exportSession()) -- 238
	refreshTitleSessionFlag() -- 239
	return ok -- 240
end -- 240
function continueOfficialStory() -- 243
	local res = loadSession() -- 244
	if res.status ~= "ok" or res.state == nil then -- 244
		refreshTitleSessionFlag() -- 246
		return nil -- 247
	end -- 247
	local s = res.state -- 249
	local idx = roomIndexByKey(s.roomKey) -- 250
	if ROOMS[idx + 1].key ~= s.roomKey then -- 250
		return nil -- 252
	end -- 252
	storyRun = createRun(s.seed, "official", profile) -- 254
	storyRun.checkpoint = s.checkpoint -- 255
	storyRun.story.route = s.route -- 256
	storyRun.story.hp = s.hp -- 257
	storyRun.story.maxHp = s.maxHp -- 258
	storyRun.story.hpAtGate = s.hpAtGate -- 259
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 260
	storyRun.story.settled = s.settled -- 261
	storyRun.story.phase = s.phase -- 262
	storyRun.story.countTick = s.countTick -- 263
	storyRun.story.phaseTick = s.phaseTick -- 264
	storyRun.story.handTicks = s.handTicks -- 265
	storyRun.story.handDone = s.handDone -- 266
	storyRun.story.lineSaid = s.lineSaid -- 267
	storyRun.story.tied = s.tied -- 268
	storyRun.story.carry = s.carry -- 269
	storyRun.story.escortDone = s.escortDone -- 270
	storyRun.story.craftedWeapon = s.craftedWeapon -- 271
	storyRun.story.equippedWeapon = s.equippedWeapon -- 272
	storyRun.inventory.wood = s.wood -- 273
	storyRun.inventory.bell = s.bell -- 274
	storyRun.inventory.scrap = s.scrap -- 275
	storyRun.inventory.wedge = s.wedge -- 276
	storyRun.inventory.ammo = s.ammo -- 277
	storyRun.inventory.shield = s.shield -- 278
	storyRun.inventory.pass = s.pass -- 279
	storyRun.inventory.quickbelt = s.quickbelt -- 280
	local k = 0 -- 281
	do -- 281
		k = 0 -- 282
		while k < #s.taken do -- 282
			storyRun.taken[s.taken[k + 1]] = true -- 283
			k = k + 1 -- 282
		end -- 282
	end -- 282
	do -- 282
		k = 0 -- 285
		while k < #s.segments do -- 285
			storyRun.story.segments[s.segments[k + 1]] = true -- 286
			k = k + 1 -- 285
		end -- 285
	end -- 285
	if s.campaignRoute ~= nil then -- 285
		storyRun.route = s.campaignRoute -- 289
	end -- 289
	if s.joined ~= nil then -- 289
		storyRun.joined = s.joined -- 292
	end -- 292
	if s.c1Latch ~= nil then -- 292
		storyRun.c1Latch = s.c1Latch -- 295
	end -- 295
	if s.c2Latch ~= nil then -- 295
		storyRun.c2Latch = s.c2Latch -- 298
	end -- 298
	local stTalents = createStoryTalents(s.seed) -- 300
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 300
		stTalents.randomState = s.talentSeed -- 302
	end -- 302
	stTalents.room = s.talentRoom or "" -- 304
	stTalents.ranks.vitality = s.talentVitality or 0 -- 305
	stTalents.ranks.reload = s.talentReload or 0 -- 306
	stTalents.ranks.guard = s.talentGuard or 0 -- 307
	stTalents.ranks.craft = s.talentCraft or 0 -- 308
	if s.talentOffers ~= nil then -- 308
		do -- 308
			k = 0 -- 310
			while k < #s.talentOffers do -- 310
				local t = s.talentOffers[k + 1] -- 311
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 311
					local ____stTalents_offers_12 = stTalents.offers -- 311
					____stTalents_offers_12[#____stTalents_offers_12 + 1] = t -- 313
				end -- 313
				k = k + 1 -- 310
			end -- 310
		end -- 310
	end -- 310
	storyRun.story.talents = stTalents -- 317
	current = idx -- 318
	setMode(1) -- 319
	if fe ~= nil then -- 319
		fe.screen = "play" -- 321
	end -- 321
	play = nil -- 323
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 324
	local cur = play -- 325
	if cur ~= nil and s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 325
		cur.cartAxle = s.cartAxle -- 327
		cur.cartDocked = s.cartDocked -- 328
	end -- 328
	return play -- 330
end -- 330
function place(lb, x, y, ax, ay) -- 348
	if lb == nil then -- 348
		return -- 350
	end -- 350
	lb.position = Vec2(x, y) -- 352
	lb.anchor = Vec2(ax, ay) -- 353
	lb.visible = true -- 354
end -- 354
function setMode(nextMode) -- 690
	mode = nextMode -- 691
	if grayboxLayer ~= nil then -- 691
		grayboxLayer.visible = mode == 0 -- 693
	end -- 693
	if fe ~= nil then -- 693
		fe:setVisible(mode == 1) -- 696
	end -- 696
	if campaignLayer ~= nil then -- 696
		campaignLayer.visible = mode == 2 -- 699
	end -- 699
	dirty = true -- 701
	clock:reset() -- 702
end -- 702
function flushProfile() -- 709
	local cur = play -- 710
	if cur ~= nil and cur.archiveDirty then -- 710
		cur.archiveDirty = false -- 712
		markProfilePending(profile) -- 713
	end -- 713
	local ok = flushSaveProfile() -- 715
	if not ok and cur ~= nil then -- 715
		cur.archiveDirty = true -- 717
	end -- 717
	return ok -- 719
end -- 719
function officialStartIndex() -- 723
	local mp = profile.museumPhase -- 724
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 725
	return inMuseum and roomIndexByKey("museum") or 0 -- 726
end -- 726
function roomIndexByKey(key) -- 729
	local i = 0 -- 730
	do -- 730
		i = 0 -- 731
		while i < #ROOMS do -- 731
			if ROOMS[i + 1].key == key then -- 731
				return i -- 733
			end -- 733
			i = i + 1 -- 731
		end -- 731
	end -- 731
	return 0 -- 736
end -- 736
function enterPlayRoom(idx, source, fresh) -- 739
	if source == nil then -- 739
		source = "debug" -- 739
	end -- 739
	if fresh == nil then -- 739
		fresh = false -- 739
	end -- 739
	current = idx -- 740
	setMode(1) -- 741
	if fe ~= nil then -- 741
		fe.screen = "play" -- 743
	end -- 743
	play = nil -- 745
	if fresh or storyRun == nil then -- 745
		storyRun = createRun(20261124, source, profile) -- 748
	else -- 748
		storyRun.source = source -- 750
	end -- 750
	ensurePlay() -- 752
	local firstPlay = play -- 754
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 754
		firstPlay.phase = "prologue-wake" -- 756
	end -- 756
	flushProfile() -- 758
end -- 758
function pickByIndex(idx, source) -- 761
	if source == nil then -- 761
		source = "debug" -- 761
	end -- 761
	if mode == 2 then -- 761
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 761
			return -- 764
		end -- 764
		current = idx -- 766
		play = nil -- 767
		clock:reset() -- 768
		ensurePlay() -- 769
		return -- 770
	end -- 770
	if idx < 0 or idx >= #ROOMS then -- 770
		return -- 773
	end -- 773
	flushProfile() -- 775
	if storyRun ~= nil then -- 775
		storyRun.source = source -- 777
	end -- 777
	current = idx -- 779
	dirty = true -- 780
	play = nil -- 781
	clock:reset() -- 782
	if mode == 1 then -- 782
		if fe ~= nil then -- 782
			fe.screen = "play" -- 785
		end -- 785
		ensurePlay() -- 787
	end -- 787
end -- 787
function applySize() -- 791
	if root == nil then -- 791
		return -- 793
	end -- 793
	root.size = Size(viewW, viewH) -- 795
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 796
	stageVp = computeStageViewport(viewW, viewH) -- 797
	if input ~= nil then -- 797
		input:setStageViewport(stageVp) -- 799
	end -- 799
	if fe ~= nil then -- 799
		fe:setStagePlacement(stageVp) -- 802
	end -- 802
	if campaignLayer ~= nil then -- 802
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 805
	end -- 805
	if grayboxLayer ~= nil then -- 805
		grayboxLayer.position = Vec2(0, 0) -- 808
	end -- 808
end -- 808
function syncFrameAdapters(frameDt) -- 812
	if input == nil then -- 812
		return -- 814
	end -- 814
	local p = play -- 816
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 817
	local isTrialMode = mode == 2 and p ~= nil -- 818
	local gameplayActive = isPlayMode or isTrialMode -- 819
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 821
		p, -- 823
		stageVp.stageW, -- 823
		stageVp.stageH, -- 823
		input:isTouchMode() -- 823
	) or ({}) -- 823
	if touchControls ~= nil and touchRouter ~= nil then -- 823
		local isFs = false -- 827
		if canToggleFullscreen() then -- 827
			do -- 827
				local function ____catch() -- 827
					isFs = false -- 832
				end -- 832
				local ____try = pcall(function() -- 832
					isFs = App.fullScreen -- 830
				end) -- 830
				if not ____try then -- 830
					____catch() -- 830
				end -- 830
			end -- 830
		end -- 830
		local ____touchControls_44 = touchControls -- 835
		local ____touchControls_syncContext_45 = touchControls.syncContext -- 835
		local ____stageVp_37 = stageVp -- 836
		local ____mode_38 = mode -- 837
		local ____temp_39 = fe ~= nil and fe.screen or "title" -- 838
		local ____run_40 = run -- 840
		local ____temp_41 = fe ~= nil and fe.cam or nil -- 841
		local ____input_42 = input -- 842
		local ____touchRouter_43 = touchRouter -- 843
		local ____temp_35 -- 844
		if fe ~= nil then -- 844
			____temp_35 = fe.contract:isAssistHintsEnabled() -- 844
		else -- 844
			____temp_35 = false -- 844
		end -- 844
		local ____temp_36 -- 845
		if fe ~= nil then -- 845
			____temp_36 = fe.audio:isAllMuted() -- 845
		else -- 845
			____temp_36 = false -- 845
		end -- 845
		____touchControls_syncContext_45(____touchControls_44, { -- 835
			viewport = ____stageVp_37, -- 836
			mode = ____mode_38, -- 837
			screen = ____temp_39, -- 838
			play = p, -- 839
			run = ____run_40, -- 840
			cam = ____temp_41, -- 841
			input = ____input_42, -- 842
			router = ____touchRouter_43, -- 843
			assistHintsEnabled = ____temp_35, -- 844
			isMuted = ____temp_36, -- 845
			isFullscreen = isFs, -- 846
			storyTalentBoxes = storyTalentBoxes, -- 847
			dt = frameDt -- 848
		}) -- 848
	end -- 848
	if gamepadRouter ~= nil then -- 848
		local trial = run and run.trial -- 853
		local trialEnded = isTrialMode and trial ~= nil and (trial.lost or (run and run.finished) == true) -- 854
		local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 855
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 856
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 859
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 860
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 861
		local ____temp_50 -- 864
		if isPlayMode and p ~= nil then -- 864
			____temp_50 = isCutsceneBlockingPlay(p) -- 864
		else -- 864
			____temp_50 = false -- 864
		end -- 864
		local cutsceneBlocking = ____temp_50 -- 864
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 865
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 867
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 869
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 871
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 874
		local playerScreenX = stageVp.stageW * 0.5 -- 876
		local playerScreenY = stageVp.stageH * 0.38 -- 877
		if p ~= nil then -- 877
			if isPlayMode and fe ~= nil then -- 877
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 880
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 881
			else -- 881
				playerScreenX = stageVp.stageW * 0.45 -- 883
				playerScreenY = stageVp.stageH * 0.36 -- 884
			end -- 884
		end -- 884
		local enemyTargets = canShoot and p ~= nil and (isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or collectTrialAimTargets(p, stageVp.stageW, stageVp.stageH)) or ({}) -- 888
		local gpCtx = { -- 894
			stageW = stageVp.stageW, -- 895
			stageH = stageVp.stageH, -- 896
			uiScale = stageVp.uiScale, -- 897
			modal = modal, -- 898
			gameplayActive = gameplayActive, -- 899
			reloadActive = reloadActive, -- 900
			craftActive = craftActive, -- 901
			talentOfferCount = talentOfferCount, -- 902
			childMode = p ~= nil and p.childMode, -- 903
			allowDepth = allowDepth, -- 904
			canShoot = canShoot, -- 905
			canBottleAim = canBottleAim, -- 906
			playerRolling = p ~= nil and p.player.rollT > 0, -- 907
			inLowArch = inLowArch, -- 908
			inTowerEnd = inTowerEnd, -- 909
			playerFacing = p ~= nil and p.player.facing or 1, -- 910
			playerScreenX = playerScreenX, -- 911
			playerScreenY = playerScreenY, -- 912
			enemyTargets = enemyTargets -- 913
		} -- 913
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 915
	end -- 915
end -- 915
function renderTouchOverlay() -- 919
	if touchControls ~= nil and touchRouter ~= nil then -- 919
		touchControls:render(touchRouter) -- 921
	end -- 921
end -- 921
function tick(frameDt) -- 925
	appClock = appClock + math.min( -- 926
		0.05, -- 926
		math.max(0, frameDt) -- 926
	) -- 926
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 927
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 928
	if w ~= viewW or h ~= viewH then -- 928
		viewW = w -- 930
		viewH = h -- 931
		applySize() -- 932
		dirty = true -- 933
	end -- 933
	if input == nil then -- 933
		return -- 936
	end -- 936
	syncFrameAdapters(frameDt) -- 938
	input:update() -- 939
	if input.userInteracted then -- 939
		onFirstUserGesture() -- 942
	end -- 942
	if input.muteTogglePressed and fe ~= nil then -- 942
		input.muteTogglePressed = false -- 945
		fe.audio:toggleAllMuted() -- 946
	end -- 946
	if input.fullscreenTogglePressed then -- 946
		input.fullscreenTogglePressed = false -- 949
		toggleFullscreen() -- 950
	end -- 950
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 950
		input.artifactTogglePressed = false -- 953
		play:toggleArtifactWeapon() -- 954
	end -- 954
	if input.bottleCanceled and play ~= nil then -- 954
		input.bottleCanceled = false -- 957
		play.aimHold = 0 -- 958
		play.bottleAimX = -1 -- 959
	end -- 959
	if mode == 2 and (run and run.trial) ~= nil then -- 959
		tickCampaign(frameDt) -- 963
		renderTouchOverlay() -- 964
		return -- 965
	end -- 965
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 965
		play:chooseTalent(input.pickRoom - 1) -- 971
		input.pickRoom = 0 -- 972
	end -- 972
	if isReleaseBuild() then -- 972
		input.toggleView.pressed = false -- 976
		input.pickRoom = 0 -- 977
		input.tab.pressed = false -- 978
	else -- 978
		if input.toggleView.pressed then -- 978
			input.toggleView.pressed = false -- 982
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 983
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 983
				ensurePlay() -- 985
			end -- 985
		end -- 985
		if input.pickRoom ~= 0 then -- 985
			local idx = input.pickRoom - 1 -- 991
			input.pickRoom = 0 -- 992
			pickByIndex(idx) -- 993
		elseif input.tab.pressed then -- 993
			input.tab.pressed = false -- 995
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 995
				pickByIndex((current + 1) % #ROOMS) -- 997
			end -- 997
		end -- 997
	end -- 997
	if mode == 2 then -- 997
		tickCampaign(frameDt) -- 1003
	elseif mode == 1 then -- 1003
		tickFrontend(frameDt) -- 1005
	elseif dirty then -- 1005
		redrawGraybox() -- 1007
		dirty = false -- 1008
	end -- 1008
	renderTouchOverlay() -- 1010
end -- 1010
function registerPlay() -- 1014
	local reg = _G.package.loaded -- 1015
	reg["watch.play"] = play -- 1016
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 1017
	reg["watch.room"] = rooms[current + 1].key -- 1018
end -- 1018
function ensurePlay(resume) -- 1022
	if mode == 2 then -- 1022
		if run == nil then -- 1022
			run = createRun() -- 1025
		end -- 1025
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 1027
	else -- 1027
		if storyRun == nil then -- 1027
			storyRun = createRun(20261124, "debug", profile) -- 1032
		end -- 1032
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1034
	end -- 1034
	registerPlay() -- 1036
	clock:reset() -- 1037
	if fe ~= nil and mode == 1 then -- 1037
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1039
	elseif fe ~= nil and mode == 2 then -- 1039
		fe:resetTrialAudio(play) -- 1041
	end -- 1041
end -- 1041
function startTrial() -- 1045
	current = 0 -- 1046
	trialTalentSelected = 0 -- 1047
	run = createTrial(App.rand) -- 1048
	setMode(2) -- 1049
	ensurePlay() -- 1050
end -- 1050
function tickCampaign(frameDt) -- 1053
	if input == nil then -- 1053
		return -- 1055
	end -- 1055
	if play == nil then -- 1055
		ensurePlay() -- 1058
	end -- 1058
	if play == nil then -- 1058
		return -- 1061
	end -- 1061
	local p = play -- 1063
	p.aimX = input.mx -- 1064
	p.aimY = input.my -- 1065
	local zoneTap = input.touchZoneTap -- 1067
	input.touchZoneTap = "" -- 1068
	local trial = run and run.trial -- 1070
	if trial ~= nil then -- 1070
		local ended = trial.lost or (run and run.finished) == true -- 1072
		local pick = input.pickRoom -- 1073
		input.pickRoom = 0 -- 1074
		if zoneTap == "trial:resume" and p.paused and not ended then -- 1074
			p.paused = false -- 1077
			clock:reset() -- 1078
			input:consumeEdges() -- 1079
			drawCampaign(p) -- 1080
			return -- 1081
		end -- 1081
		if zoneTap == "trial:retry" then -- 1081
			input:consumeEdges() -- 1084
			startTrial() -- 1085
			return -- 1086
		end -- 1086
		if zoneTap == "trial:title" then -- 1086
			input:consumeEdges() -- 1089
			current = 0 -- 1090
			play = nil -- 1091
			run = nil -- 1092
			setMode(1) -- 1093
			if fe ~= nil then -- 1093
				fe.audio:stopRoomTransient() -- 1095
				fe.screen = "title" -- 1096
				fe.menus:resetInput() -- 1097
			end -- 1097
			return -- 1099
		end -- 1099
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1099
			input:consumeEdges() -- 1103
			current = 0 -- 1104
			play = nil -- 1105
			run = nil -- 1106
			setMode(1) -- 1107
			if fe ~= nil then -- 1107
				fe.audio:stopRoomTransient() -- 1109
				fe.screen = "title" -- 1110
				fe.menus:resetInput() -- 1111
			end -- 1111
			return -- 1113
		end -- 1113
		if ended or p.paused and input.retry.pressed then -- 1113
			local restart = input.retry.pressed or ended and input.navConfirm -- 1116
			input:consumeEdges() -- 1117
			if restart then -- 1117
				startTrial() -- 1118
			else -- 1118
				drawCampaign(p) -- 1119
			end -- 1119
			return -- 1120
		end -- 1120
		input.retry.pressed = false -- 1122
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1122
			if trialTalentSelected >= #trial.offers then -- 1122
				trialTalentSelected = 0 -- 1125
			end -- 1125
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1125
				local idx = __TS__ParseInt( -- 1128
					string.sub(zoneTap, 8), -- 1128
					10 -- 1128
				) -- 1128
				if idx >= 0 and idx < #trial.offers then -- 1128
					p:chooseTalent(idx) -- 1130
				end -- 1130
			elseif pick > 0 then -- 1130
				p:chooseTalent(pick - 1) -- 1133
			else -- 1133
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1135
				if delta ~= 0 then -- 1135
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1139
				end -- 1139
				if input.talentConfirm or input.navConfirm then -- 1139
					p:chooseTalent(trialTalentSelected) -- 1142
				end -- 1142
			end -- 1142
			input:consumeEdges() -- 1145
			clock:reset() -- 1146
			if fe ~= nil then -- 1146
				fe:syncTrialAudio(frameDt, p, #trial.offers) -- 1147
			end -- 1147
			drawCampaign(p) -- 1148
			return -- 1149
		end -- 1149
	end -- 1149
	if input.retry.pressed then -- 1149
		input.retry.pressed = false -- 1154
		input:consumeEdges() -- 1155
		play = nil -- 1157
		ensurePlay() -- 1158
		return -- 1159
	end -- 1159
	if input.pause.pressed or p.paused and input.navBack then -- 1159
		input.pause.pressed = false -- 1162
		p.paused = not p.paused -- 1163
		if fe ~= nil then -- 1163
			fe.audio:playUi(p.paused and "ui:pause_open" or "ui:pause_close", p.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 1164
		end -- 1164
		clock:reset() -- 1165
		input:consumeEdges() -- 1166
	end -- 1166
	if p.paused then -- 1166
		if fe ~= nil then -- 1166
			fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1169
		end -- 1169
		drawCampaign(p) -- 1170
		return -- 1171
	end -- 1171
	local steps = clock:advance(frameDt) -- 1174
	local i = 0 -- 1175
	do -- 1175
		i = 0 -- 1176
		while i < steps do -- 1176
			input:beginStep(i == 0) -- 1177
			p:update(STEP, input) -- 1178
			input:endStep() -- 1179
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1179
				break -- 1181
			end -- 1181
			i = i + 1 -- 1176
		end -- 1176
	end -- 1176
	if fe ~= nil then -- 1176
		fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1184
	end -- 1184
	if p.wantRoom ~= "" then -- 1184
		local key = p.wantRoom -- 1187
		p.wantRoom = "" -- 1188
		local idx = -1 -- 1189
		local j = 0 -- 1190
		do -- 1190
			j = 0 -- 1191
			while j < #CAMPAIGN_ROOMS do -- 1191
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1191
					idx = j -- 1193
				end -- 1193
				j = j + 1 -- 1191
			end -- 1191
		end -- 1191
		if idx >= 0 then -- 1191
			current = idx -- 1197
			play = nil -- 1198
			ensurePlay() -- 1199
		end -- 1199
		return -- 1201
	end -- 1201
	drawCampaign(p) -- 1203
end -- 1203
function goalLabel(goal) -- 1206
	if goal == "dock_cart" then -- 1206
		return "推车入窝并抬闩" -- 1208
	end -- 1208
	if goal == "raise_latch" then -- 1208
		return "抬闩开侧门" -- 1211
	end -- 1211
	return "到段出口" -- 1213
end -- 1213
function drawCampaign(p) -- 1216
	if campaignDraw == nil then -- 1216
		return -- 1218
	end -- 1218
	local w = stageVp.stageW -- 1220
	local h = stageVp.stageH -- 1221
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1222
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1223
	p:draw(campaignDraw, w, h) -- 1224
	local room = CAMPAIGN_ROOMS[current + 1] -- 1225
	local c = room.campaign -- 1226
	local r = run -- 1227
	local line = room.name -- 1228
	if c ~= nil then -- 1228
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 1230
	end -- 1230
	if p.paused then -- 1230
		line = line .. "  · 已暂停 Esc 继续" -- 1234
	end -- 1234
	local trial = r and r.trial -- 1236
	if trial ~= nil and r ~= nil then -- 1236
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 1238
		if p.paused then -- 1238
			line = line .. " · 暂停" -- 1239
		elseif trial.lost then -- 1239
			line = line .. " · 护送失败" -- 1240
		elseif r.finished then -- 1240
			line = line .. " · 护送完成" -- 1241
		elseif #trial.offers > 0 then -- 1241
			line = line .. " · 选择本段本领" -- 1242
		elseif c ~= nil then -- 1242
			line = line .. " · " .. goalLabel(c.goal) -- 1243
		end -- 1243
	end -- 1243
	if campaignHud ~= nil then -- 1243
		campaignHud.text = line -- 1246
		campaignHud.position = Vec2(24 + safeL, h - 14 - safeT) -- 1247
		campaignHud.visible = true -- 1248
	end -- 1248
	if campaignSub ~= nil then -- 1248
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 1251
		if r ~= nil then -- 1251
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 1253
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 1254
		end -- 1254
		if p.flash ~= "" then -- 1254
			sub = (sub .. " · ") .. p.flash -- 1260
		end -- 1260
		if trial ~= nil and r ~= nil then -- 1260
			local gpMode = input ~= nil and input:isGamepadMode() -- 1263
			local touchMode = input ~= nil and input:isTouchMode() -- 1264
			if trial.lost or r.finished then -- 1264
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · A 再开一局 · START 返回标题" or (touchMode and " · 点下方按钮再开或返回标题" or " · R 再开一局 · Esc 返回标题")) -- 1266
			elseif p.paused then -- 1266
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · START 继续 · 长按BACK 重开 · Y 返回标题" or (touchMode and " · 点下方按钮继续/重开/返回标题" or " · Esc 继续 · R 重新开局 · E 返回标题")) -- 1268
			elseif #trial.offers > 0 then -- 1268
				sub = table.concat( -- 1270
					__TS__ArrayMap( -- 1270
						trial.offers, -- 1270
						function(____, talent, index) -- 1270
							local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1271
							return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1272
						end -- 1270
					), -- 1270
					"　" -- 1273
				) -- 1273
			else -- 1273
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 1275
			end -- 1275
		end -- 1275
		campaignSub.text = sub -- 1278
		campaignSub.position = Vec2(24 + safeL, h - 44 - safeT) -- 1279
		campaignSub.visible = true -- 1280
	end -- 1280
end -- 1280
function tickFrontend(frameDt) -- 1284
	if fe == nil or input == nil then -- 1284
		return -- 1286
	end -- 1286
	if fe.screen ~= "play" then -- 1286
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1291
		input:consumeEdges() -- 1292
		if act.type == "splashDone" then -- 1292
			fe.menus:resetInput() -- 1294
			fe.screen = "title" -- 1295
		elseif act.type == "trial" then -- 1295
			startTrial() -- 1297
		elseif act.type == "continue" then -- 1297
			if continueOfficialStory() == nil then -- 1297
				enterPlayRoom( -- 1300
					officialStartIndex(), -- 1300
					"official", -- 1300
					true -- 1300
				) -- 1300
			end -- 1300
		elseif act.type == "start" then -- 1300
			clearSession() -- 1304
			refreshTitleSessionFlag() -- 1305
			enterPlayRoom( -- 1306
				officialStartIndex(), -- 1306
				"official", -- 1306
				true -- 1306
			) -- 1306
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1306
			enterPlayRoom(act.roomIndex, "chapter") -- 1308
		elseif act.type == "openChapters" then -- 1308
			fe.menus:openChapters() -- 1310
			fe.screen = "chapters" -- 1311
		elseif act.type == "openControls" then -- 1311
			fe.menus:resetInput() -- 1313
			fe.screen = "controls" -- 1314
		elseif act.type == "backTitle" then -- 1314
			fe.menus:resetInput() -- 1316
			fe.screen = "title" -- 1317
		elseif act.type == "backPause" then -- 1317
			fe.menus:resetInput() -- 1319
			fe.screen = "play" -- 1320
		elseif act.type == "quit" then -- 1320
			quitGame() -- 1322
		end -- 1322
		return -- 1324
	end -- 1324
	if play == nil then -- 1324
		ensurePlay() -- 1329
	end -- 1329
	if play == nil then -- 1329
		return -- 1332
	end -- 1332
	local p = play -- 1334
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1336
	if input.retry.pressed and not inTowerEnding then -- 1336
		input:consumeEdges() -- 1338
		ensurePlay({checkpoint = p.checkpoint}) -- 1340
		return -- 1341
	end -- 1341
	p.aimX = input.mx -- 1344
	p.aimY = input.my -- 1345
	local zoneTap = input.touchZoneTap -- 1347
	input.touchZoneTap = "" -- 1348
	local offers = p:getStoryTalentOffers() -- 1350
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1350
		if fe.hud.talentSelected >= #offers then -- 1350
			fe.hud.talentSelected = 0 -- 1353
		end -- 1353
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1353
			local idx = __TS__ParseInt( -- 1356
				string.sub(zoneTap, 8), -- 1356
				10 -- 1356
			) -- 1356
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1356
				input.fire.pressed = false -- 1358
			end -- 1358
		else -- 1358
			if input.talentDelta ~= 0 then -- 1358
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1362
				input.talentDelta = 0 -- 1363
			end -- 1363
			if input.talentConfirm then -- 1363
				p:chooseTalent(fe.hud.talentSelected) -- 1366
				input.talentConfirm = false -- 1367
				input.fire.pressed = false -- 1368
			elseif (input.uiPressed or input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1368
				input.fire.pressed = false -- 1371
			end -- 1371
		end -- 1371
	end -- 1371
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" and input.navConfirm then -- 1371
		input.interact.pressed = true -- 1378
	end -- 1378
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1378
		p:closeCraftBench() -- 1382
		input:consumeEdges() -- 1383
		return -- 1384
	end -- 1384
	if not p.paused and input.pause.pressed then -- 1384
		p.paused = true -- 1387
		p.aimHold = 0 -- 1388
		p.bottleAimX = -1 -- 1389
		saveCurrentSession() -- 1390
		fe.menus:openPause() -- 1391
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1392
		input:clearTransient(true) -- 1393
		input:consumeEdges() -- 1394
	end -- 1394
	if p.paused then -- 1394
		clock:reset() -- 1399
		local pauseAct = fe:renderPlay( -- 1400
			frameDt, -- 1400
			p, -- 1400
			input, -- 1400
			stageVp.stageW, -- 1400
			stageVp.stageH -- 1400
		) -- 1400
		input:consumeEdges() -- 1401
		if pauseAct.type == "resume" then -- 1401
			p.paused = false -- 1403
		elseif pauseAct.type == "retry" then -- 1403
			ensurePlay({checkpoint = p.checkpoint}) -- 1405
		elseif pauseAct.type == "openChapters" then -- 1405
			fe.menus:openChapters(current) -- 1407
			fe.screen = "chapters" -- 1408
		elseif pauseAct.type == "toggleFullscreen" then -- 1408
			toggleFullscreen() -- 1410
		elseif pauseAct.type == "quit" then -- 1410
			quitGame() -- 1412
		elseif pauseAct.type == "toTitle" then -- 1412
			saveCurrentSession() -- 1414
			refreshTitleSessionFlag() -- 1415
			fe.menus:resetInput() -- 1416
			fe.screen = "title" -- 1417
		end -- 1417
		return -- 1419
	end -- 1419
	local steps = clock:advance(frameDt) -- 1422
	local i = 0 -- 1423
	do -- 1423
		i = 0 -- 1424
		while i < steps do -- 1424
			input:beginStep(i == 0) -- 1425
			p:update(STEP, input) -- 1426
			input:endStep() -- 1427
			if p.wantRoom ~= "" then -- 1427
				break -- 1429
			end -- 1429
			i = i + 1 -- 1424
		end -- 1424
	end -- 1424
	if p.wantRoom ~= "" then -- 1424
		local key = p.wantRoom -- 1435
		p.wantRoom = "" -- 1436
		local idx = -1 -- 1437
		local j = 0 -- 1438
		do -- 1438
			j = 0 -- 1439
			while j < #ROOMS do -- 1439
				if ROOMS[j + 1].key == key then -- 1439
					idx = j -- 1441
				end -- 1441
				j = j + 1 -- 1439
			end -- 1439
		end -- 1439
		if idx >= 0 then -- 1439
			flushProfile() -- 1448
			local leaving = p:drainEvents() -- 1449
			if p.restartStory then -- 1449
				if storyRun ~= nil and storyRun.source == "official" then -- 1449
					clearSession() -- 1453
					refreshTitleSessionFlag() -- 1454
				end -- 1454
				storyRun = createRun(20261124, storyRun == nil and "official" or storyRun.source, profile) -- 1456
			end -- 1456
			current = idx -- 1458
			ensurePlay() -- 1459
			local fresh = play -- 1460
			if fresh ~= nil then -- 1460
				fresh:adoptEvents(leaving) -- 1462
			end -- 1462
			if not p.restartStory then -- 1462
				saveCurrentSession() -- 1465
			end -- 1465
			clock:reset() -- 1467
			dirty = true -- 1468
		end -- 1468
		return -- 1470
	end -- 1470
	flushProfile() -- 1474
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1474
		clearSession() -- 1476
		refreshTitleSessionFlag() -- 1477
	elseif p.sessionDirty then -- 1477
		saveCurrentSession() -- 1479
	end -- 1479
	fe:renderPlay( -- 1481
		frameDt, -- 1481
		p, -- 1481
		input, -- 1481
		stageVp.stageW, -- 1481
		stageVp.stageH -- 1481
	) -- 1481
end -- 1481
function redrawGraybox() -- 1485
	if draw == nil then -- 1485
		return -- 1487
	end -- 1487
	local w = viewW -- 1489
	local h = viewH -- 1490
	local room = ROOMS[current + 1] -- 1491
	draw:clear() -- 1493
	draw:drawRect( -- 1494
		Rect(0, h - TOP_H, w, TOP_H), -- 1494
		C_BG -- 1494
	) -- 1494
	draw:drawRect( -- 1495
		Rect(0, 0, w, BOTTOM_H), -- 1495
		C_BG -- 1495
	) -- 1495
	draw:drawSegment( -- 1496
		Vec2(0, h - TOP_H), -- 1496
		Vec2(w, h - TOP_H), -- 1496
		1, -- 1496
		Color(52, 54, 54, 255) -- 1496
	) -- 1496
	draw:drawSegment( -- 1497
		Vec2(0, BOTTOM_H), -- 1497
		Vec2(w, BOTTOM_H), -- 1497
		1, -- 1497
		Color(52, 54, 54, 255) -- 1497
	) -- 1497
	local v = computeView(room, w, h) -- 1499
	renderWorld( -- 1500
		draw, -- 1500
		room, -- 1500
		v, -- 1500
		w, -- 1500
		h -- 1500
	) -- 1500
	local roomTop = v.groundPx + room.height * v.scale -- 1502
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1503
	place( -- 1505
		titleLabel, -- 1505
		48, -- 1505
		h - 40, -- 1505
		0, -- 1505
		1 -- 1505
	) -- 1505
	place( -- 1506
		roomLabel, -- 1506
		48, -- 1506
		h - 96, -- 1506
		0, -- 1506
		1 -- 1506
	) -- 1506
	place( -- 1507
		captionLabel, -- 1507
		48, -- 1507
		h - 140, -- 1507
		0, -- 1507
		1 -- 1507
	) -- 1507
	place( -- 1509
		switchLabel, -- 1509
		48, -- 1509
		40, -- 1509
		0, -- 1509
		0 -- 1509
	) -- 1509
	place( -- 1510
		hintLabel, -- 1510
		48, -- 1510
		84, -- 1510
		0, -- 1510
		0 -- 1510
	) -- 1510
	place( -- 1511
		rulerLabel, -- 1511
		w - 216, -- 1511
		roomTop + 36 + v.scale * 0.5 - 14, -- 1511
		1, -- 1511
		0 -- 1511
	) -- 1511
	place( -- 1512
		standLabel, -- 1512
		48, -- 1512
		roomTop + 40, -- 1512
		0, -- 1512
		0 -- 1512
	) -- 1512
	place( -- 1513
		cartLabel, -- 1513
		48, -- 1513
		roomTop + 92, -- 1513
		0, -- 1513
		0 -- 1513
	) -- 1513
	if roomLabel ~= nil then -- 1513
		roomLabel.text = room.name -- 1516
	end -- 1516
	if captionLabel ~= nil then -- 1516
		captionLabel.text = room.caption -- 1519
	end -- 1519
	if hintLabel ~= nil then -- 1519
		local hintIdx = math.min(current, #HINTS - 1) -- 1522
		local lines = HINTS[hintIdx + 1] -- 1523
		local merged = lines[1] -- 1524
		do -- 1524
			local i = 1 -- 1525
			while i < #lines do -- 1525
				merged = (merged .. "    ") .. lines[i + 1] -- 1526
				i = i + 1 -- 1525
			end -- 1525
		end -- 1525
		hintLabel.text = merged -- 1528
	end -- 1528
	local specs = collectLabels(room, v, w) -- 1531
	local body = {} -- 1532
	local small = {} -- 1533
	do -- 1533
		local i = 0 -- 1534
		while i < #specs do -- 1534
			local s = specs[i + 1] -- 1535
			if s.size >= 24 then -- 1535
				body[#body + 1] = s -- 1537
			else -- 1537
				small[#small + 1] = s -- 1539
			end -- 1539
			i = i + 1 -- 1534
		end -- 1534
	end -- 1534
	applyPool(body, poolBody) -- 1542
	applyPool(small, poolSmall) -- 1543
	if LAYOUT_AUDIT then -- 1543
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1546
	end -- 1546
end -- 1546
function applyPool(specs, pool) -- 1550
	do -- 1550
		local i = 0 -- 1551
		while i < #pool do -- 1551
			local lb = pool[i + 1] -- 1552
			if i < #specs then -- 1552
				local s = specs[i + 1] -- 1554
				lb.text = s.text -- 1555
				lb.position = Vec2(s.x, s.y) -- 1556
				lb.anchor = Vec2(s.ax, s.ay) -- 1557
				lb.color = s.color -- 1558
				lb.visible = true -- 1559
			else -- 1559
				lb.visible = false -- 1561
			end -- 1561
			i = i + 1 -- 1551
		end -- 1551
	end -- 1551
end -- 1551
local FONT = "sarasa-mono-sc-regular" -- 38
LAYOUT_AUDIT = false -- 39
local C_TEXT = Color(236, 236, 232, 255) -- 41
local C_DIM = Color(150, 154, 152, 255) -- 42
local C_ACCENT = Color(226, 186, 84, 255) -- 43
C_BG = Color(17, 18, 19, 255) -- 44
local POOL_BODY = 30 -- 46
local POOL_SMALL = 44 -- 47
TOP_H = 208 -- 48
BOTTOM_H = 216 -- 49
profile = emptySave() -- 67
local profileStatus = "missing" -- 68
local profileDetail = "" -- 69
poolBody = {} -- 74
poolSmall = {} -- 75
current = 0 -- 77
viewW = 0 -- 78
viewH = 0 -- 79
dirty = true -- 80
mode = 1 -- 82
clock = __TS__New(StepClock) -- 89
stageVp = computeStageViewport(1280, 720) -- 90
audioUnlocked = false -- 92
appClock = 0 -- 93
local lastBackPressClock = -10 -- 94
trialTalentSelected = 0 -- 95
local function handleBackButton() -- 145
	if mode == 0 then -- 145
		setMode(1) -- 147
		return -- 148
	end -- 148
	if mode == 2 and play ~= nil then -- 148
		local trial = run and run.trial -- 151
		if trial ~= nil and (trial.lost or (run and run.finished) == true) then -- 151
			current = 0 -- 153
			play = nil -- 154
			run = nil -- 155
			setMode(1) -- 156
			if fe ~= nil then -- 156
				fe.audio:stopRoomTransient() -- 158
				fe.screen = "title" -- 159
				fe.menus:resetInput() -- 160
			end -- 160
			return -- 162
		end -- 162
		play.paused = not play.paused -- 164
		if fe ~= nil then -- 164
			fe.audio:playUi(play.paused and "ui:pause_open" or "ui:pause_close", play.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 165
		end -- 165
		clock:reset() -- 166
		if input ~= nil then -- 166
			input:clearTransient(true) -- 167
		end -- 167
		return -- 168
	end -- 168
	if fe == nil then -- 168
		return -- 171
	end -- 171
	if fe.screen == "splash" then -- 171
		fe.menus:resetSplash() -- 174
		fe.screen = "title" -- 175
		fe.menus:resetInput() -- 176
		return -- 177
	end -- 177
	if fe.screen == "chapters" or fe.screen == "controls" then -- 177
		fe.menus:triggerBack() -- 180
		return -- 181
	end -- 181
	if fe.screen == "title" then -- 181
		if not canQuitApp() then -- 181
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 185
			return -- 186
		end -- 186
		if appClock - lastBackPressClock <= 2 then -- 186
			quitGame() -- 189
		else -- 189
			lastBackPressClock = appClock -- 191
			fe:showToast("再按一次返回退出游戏", 2) -- 192
		end -- 192
		return -- 194
	end -- 194
	if fe.screen == "play" and play ~= nil then -- 194
		if play.paused then -- 194
			fe.menus:triggerBack() -- 198
			return -- 199
		end -- 199
		if play.craftBench.active then -- 199
			play:closeCraftBench() -- 202
			return -- 203
		end -- 203
		play.paused = true -- 205
		play.aimHold = 0 -- 206
		play.bottleAimX = -1 -- 207
		saveCurrentSession() -- 208
		fe.menus:openPause() -- 209
		if input ~= nil then -- 209
			input:clearTransient(true) -- 210
		end -- 210
	end -- 210
end -- 145
local function makeGrayboxLabel(text, size, color) -- 333
	if grayboxLayer == nil then -- 333
		return nil -- 335
	end -- 335
	local lb = Label(FONT, size) -- 337
	if lb == nil then -- 337
		return nil -- 339
	end -- 339
	lb.text = text -- 341
	lb.color = color -- 342
	lb:addTo(grayboxLayer) -- 343
	lb.visible = true -- 344
	return lb -- 345
end -- 333
function ____exports.start(parent, initialMode, startScreen) -- 357
	if initialMode == nil then -- 357
		initialMode = 1 -- 357
	end -- 357
	if startScreen == nil then -- 357
		startScreen = "title" -- 357
	end -- 357
	root = parent -- 358
	mode = initialMode -- 359
	grayboxLayer = Node() -- 362
	grayboxLayer.order = 2 -- 363
	grayboxLayer:addTo(parent) -- 364
	draw = DrawNode() -- 366
	draw:addTo(grayboxLayer) -- 367
	campaignLayer = Node() -- 370
	campaignLayer.order = 3 -- 371
	campaignLayer:addTo(parent) -- 372
	campaignDraw = DrawNode() -- 373
	campaignDraw:addTo(campaignLayer) -- 374
	campaignHud = Label(FONT, 24) -- 375
	if campaignHud ~= nil then -- 375
		campaignHud.color = C_TEXT -- 377
		campaignHud.anchor = Vec2(0, 1) -- 378
		campaignHud:addTo(campaignLayer) -- 379
		campaignHud.visible = true -- 380
	end -- 380
	campaignSub = Label(FONT, 20) -- 382
	if campaignSub ~= nil then -- 382
		campaignSub.color = C_ACCENT -- 384
		campaignSub.anchor = Vec2(0, 1) -- 385
		campaignSub:addTo(campaignLayer) -- 386
		campaignSub.visible = true -- 387
	end -- 387
	campaignLayer.visible = mode == 2 -- 389
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 391
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 392
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 393
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 394
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 395
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 396
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 397
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 398
	do -- 398
		local i = 0 -- 400
		while i < POOL_BODY do -- 400
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 401
			if lb ~= nil then -- 401
				poolBody[#poolBody + 1] = lb -- 403
			end -- 403
			i = i + 1 -- 400
		end -- 400
	end -- 400
	do -- 400
		local i = 0 -- 406
		while i < POOL_SMALL do -- 406
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 407
			if lb ~= nil then -- 407
				poolSmall[#poolSmall + 1] = lb -- 409
			end -- 409
			i = i + 1 -- 406
		end -- 406
	end -- 406
	if mode == 1 then -- 406
		local loaded = loadSave() -- 416
		profile = loaded.state -- 417
		profileStatus = loaded.status -- 418
		profileDetail = loaded.detail -- 419
	end -- 419
	fe = __TS__New(WatchFrontend, parent) -- 421
	fe.screen = startScreen -- 422
	if startScreen == "splash" then -- 422
		fe.menus:resetSplash() -- 424
	end -- 424
	refreshTitleSessionFlag() -- 426
	grayboxLayer.visible = mode == 0 -- 427
	fe:setVisible(mode == 1) -- 428
	if campaignLayer ~= nil then -- 428
		campaignLayer.visible = mode == 2 -- 430
	end -- 430
	input = __TS__New(Input) -- 433
	fe.audio:applyUserVolumes(input.settings) -- 434
	touchRouter = __TS__New(TouchRouter, input.settings) -- 435
	touchRouter:attach(parent) -- 436
	input:bindTouch(touchRouter) -- 437
	gamepadRouter = __TS__New(GamepadRouter, input.settings) -- 439
	gamepadRouter:attach(parent) -- 440
	input:bindGamepad(gamepadRouter) -- 441
	touchControls = __TS__New(TouchControls, parent) -- 443
	parent:gslot( -- 446
		"AppEvent", -- 446
		function(eventType) -- 446
			if eventType == "BackButton" then -- 446
				handleBackButton() -- 448
				return -- 449
			end -- 449
			if eventType == "Quit" or eventType == "Shutdown" then -- 449
				flushProfile() -- 452
				saveCurrentSession() -- 453
				if input ~= nil then -- 453
					input:clearTransient(false) -- 454
				end -- 454
				return -- 455
			end -- 455
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 455
				flushProfile() -- 458
				saveCurrentSession() -- 459
				if input ~= nil then -- 459
					input:clearTransient(true) -- 460
				end -- 460
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 460
					play.paused = true -- 462
					play.aimHold = 0 -- 463
					play.bottleAimX = -1 -- 464
					fe.menus:openPause() -- 465
				end -- 465
				if fe ~= nil then -- 465
					fe.audio:setPaused(true) -- 468
				end -- 468
				return -- 470
			end -- 470
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 470
				if fe ~= nil then -- 470
					local paused = mode == 1 and fe.screen == "play" and play ~= nil and play.paused -- 474
					fe.audio:setPaused(paused) -- 475
				end -- 475
			end -- 475
		end -- 446
	) -- 446
	parent:onKeyDown(function(key) -- 481
		onFirstUserGesture() -- 482
		if input ~= nil then -- 482
			input:markKeyboardActivity() -- 483
		end -- 483
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 483
			toggleFullscreen() -- 486
			return -- 487
		end -- 487
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 487
			play:toggleArtifactWeapon() -- 490
			return -- 491
		end -- 491
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 then -- 491
			if key == "1" then -- 491
				play:chooseTalent(0) -- 496
				return -- 497
			end -- 497
			if key == "2" then -- 497
				play:chooseTalent(1) -- 500
				return -- 501
			end -- 501
			if key == "3" then -- 501
				play:chooseTalent(2) -- 504
				return -- 505
			end -- 505
		end -- 505
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or play ~= nil and play.paused) then -- 505
			fe.menus:onKeyEvent(key) -- 509
		end -- 509
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" or mode == 2) then -- 509
			if key == "E" then -- 509
				input.interact.pressed = true -- 513
			elseif key == "Space" then -- 513
				input.jump.pressed = true -- 515
			elseif key == "Escape" then -- 515
				input.pause.pressed = true -- 517
			elseif key == "R" then -- 517
				input.retry.pressed = true -- 519
			end -- 519
		end -- 519
		if mode == 2 and (run and run.trial) ~= nil then -- 519
			return -- 522
		end -- 522
		if isReleaseBuild() then -- 522
			return -- 523
		end -- 523
		if key == "F1" then -- 523
			if mode == 2 then -- 523
				current = 0 -- 526
				play = nil -- 527
				ensurePlay() -- 528
			else -- 528
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 530
			end -- 530
		elseif key == "F2" then -- 530
			setMode(0) -- 533
		elseif key == "1" then -- 533
			pickByIndex(0) -- 535
		elseif key == "2" then -- 535
			pickByIndex(1) -- 537
		elseif key == "3" then -- 537
			pickByIndex(2) -- 539
		elseif key == "4" then -- 539
			pickByIndex(3) -- 541
		elseif key == "5" then -- 541
			pickByIndex(4) -- 543
		elseif key == "6" then -- 543
			pickByIndex(5) -- 545
		elseif key == "7" then -- 545
			pickByIndex(6) -- 547
		elseif key == "8" then -- 547
			pickByIndex(7) -- 549
		end -- 549
	end) -- 481
	viewW = View.size.width -- 553
	viewH = View.size.height -- 554
	applySize() -- 555
	local reg = _G.package.loaded -- 558
	reg["watch.input"] = input -- 559
	reg["watch.touch"] = touchRouter -- 560
	reg["watch.gamepad"] = gamepadRouter -- 561
	reg["watch.fe"] = { -- 562
		setScreen = function(sc) -- 563
			if fe == nil then -- 563
				return -- 565
			end -- 565
			setMode(1) -- 567
			fe.screen = sc -- 568
			if sc == "splash" then -- 568
				fe.menus:resetSplash() -- 570
			elseif sc == "chapters" then -- 570
				fe.menus:openChapters() -- 572
			else -- 572
				fe.menus:resetInput() -- 574
			end -- 574
			if sc == "play" then -- 574
				ensurePlay() -- 577
			end -- 577
		end, -- 563
		jumpRoom = function(keyOrIdx) -- 580
			local idx = -1 -- 581
			if type(keyOrIdx) == "number" then -- 581
				idx = keyOrIdx -- 583
			else -- 583
				local k = 0 -- 585
				do -- 585
					k = 0 -- 586
					while k < #ROOMS do -- 586
						if ROOMS[k + 1].key == keyOrIdx then -- 586
							idx = k -- 588
						end -- 588
						k = k + 1 -- 586
					end -- 586
				end -- 586
			end -- 586
			if idx >= 0 and idx < #ROOMS then -- 586
				enterPlayRoom(idx, "debug") -- 593
			end -- 593
		end, -- 580
		getPlay = function() return play end, -- 596
		getFrontend = function() return fe end, -- 597
		startStory = function() -- 599
			enterPlayRoom( -- 600
				officialStartIndex(), -- 600
				"official", -- 600
				true -- 600
			) -- 600
			return play -- 601
		end, -- 599
		previewChapter = function(idx) -- 604
			enterPlayRoom(idx, "chapter") -- 605
			return play -- 606
		end, -- 604
		getStoryRun = function() return storyRun end, -- 608
		getProfilePending = function() return profilePending() end, -- 609
		flushProfileNow = function() return flushProfile() end, -- 610
		getProfile = function() return profile end, -- 612
		getProfileStatus = function() return profileStatus end, -- 613
		getProfileDetail = function() return profileDetail end, -- 614
		useTestSave = function(name) -- 615
			setSaveFile(name) -- 616
			setSessionFile(name == "" and "" or name .. ".session") -- 617
			clearProfilePending() -- 618
			local loaded = loadSave() -- 619
			profile = loaded.state -- 620
			profileStatus = loaded.status -- 621
			profileDetail = loaded.detail -- 622
			refreshTitleSessionFlag() -- 623
		end, -- 615
		useTestSession = function(name) -- 625
			setSessionFile(name) -- 626
			refreshTitleSessionFlag() -- 627
		end, -- 625
		getSessionFile = getSessionFile, -- 629
		hasSessionSave = hasSessionSave, -- 630
		saveSessionNow = function() return saveCurrentSession() end, -- 631
		clearSessionNow = function() -- 632
			local ok = clearSession() -- 633
			refreshTitleSessionFlag() -- 634
			return ok -- 635
		end, -- 632
		continueStory = function() return continueOfficialStory() end, -- 637
		saveNow = function() return saveSave(profile) end, -- 638
		getSaveFile = getSaveFile, -- 639
		isRelease = function() return isReleaseBuild() end, -- 640
		getReleaseVersion = function() -- 641
			local ____opt_21 = getReleaseConfig() -- 641
			return ____opt_21 and ____opt_21.version or "dev" -- 641
		end, -- 641
		toggleFullscreen = function() return toggleFullscreen() end, -- 642
		quitGame = function() return quitGame() end, -- 643
		startTrial = function() return startTrial() end, -- 644
		handleBackButton = function() return handleBackButton() end, -- 645
		getViewport = function() return stageVp end, -- 646
		getTouchController = function() return touchControls end, -- 647
		getTouchRouter = function() return touchRouter end, -- 648
		getGamepad = function() return gamepadRouter end, -- 649
		setGamepadSim = function(state) -- 650
			if gamepadRouter ~= nil then -- 650
				gamepadRouter:setSimulatedState(state) -- 651
			end -- 651
		end, -- 650
		injectTouch = function(phase, id, x, y, fromMouse) -- 653
			if touchRouter ~= nil then -- 653
				touchRouter:injectTouch( -- 654
					phase, -- 654
					id, -- 654
					x, -- 654
					y, -- 654
					fromMouse -- 654
				) -- 654
			end -- 654
		end, -- 653
		getInputMode = function() return input and input.inputMode or "kbm" end, -- 656
		setInputMode = function(m) -- 657
			if input ~= nil then -- 657
				input:setInputMode(m) -- 658
			end -- 658
		end, -- 657
		setModePref = function(pref) -- 660
			if input ~= nil then -- 660
				input:setModePref(pref) -- 661
			end -- 661
		end, -- 660
		applyViewportForTest = function(w, h) -- 663
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 663
				testViewportOverride = {w = w, h = h} -- 665
				viewW = w -- 666
				viewH = h -- 667
			else -- 667
				testViewportOverride = nil -- 669
				viewW = View.size.width -- 670
				viewH = View.size.height -- 671
			end -- 671
			applySize() -- 673
			dirty = true -- 674
			return stageVp -- 675
		end, -- 663
		getToast = function() return fe and fe:getToastText() or "" end -- 677
	} -- 677
	if mode == 1 and startScreen == "play" then -- 677
		ensurePlay() -- 681
	end -- 681
	parent:schedule(function(frameDt) -- 684
		tick(frameDt) -- 685
		return false -- 686
	end) -- 684
end -- 357
return ____exports -- 357