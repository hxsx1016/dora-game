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
			fe.screen = "title" -- 136
			fe.menus:resetInput() -- 137
		end -- 137
		return -- 139
	end -- 139
	App:shutdown() -- 141
end -- 141
function canSaveSession() -- 211
	if mode ~= 1 or play == nil or storyRun == nil then -- 211
		return false -- 213
	end -- 213
	if storyRun.source ~= "official" or play.run.finished then -- 213
		return false -- 216
	end -- 216
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 216
		return false -- 219
	end -- 219
	return true -- 221
end -- 221
function refreshTitleSessionFlag() -- 224
	if fe ~= nil then -- 224
		fe.menus.hasSession = hasSessionSave() -- 226
	end -- 226
end -- 226
function saveCurrentSession() -- 230
	if not canSaveSession() or play == nil then -- 230
		return false -- 232
	end -- 232
	play.sessionDirty = false -- 234
	local ok = saveSession(play:exportSession()) -- 235
	refreshTitleSessionFlag() -- 236
	return ok -- 237
end -- 237
function continueOfficialStory() -- 240
	local res = loadSession() -- 241
	if res.status ~= "ok" or res.state == nil then -- 241
		refreshTitleSessionFlag() -- 243
		return nil -- 244
	end -- 244
	local s = res.state -- 246
	local idx = roomIndexByKey(s.roomKey) -- 247
	if ROOMS[idx + 1].key ~= s.roomKey then -- 247
		return nil -- 249
	end -- 249
	storyRun = createRun(s.seed, "official", profile) -- 251
	storyRun.checkpoint = s.checkpoint -- 252
	storyRun.story.route = s.route -- 253
	storyRun.story.hp = s.hp -- 254
	storyRun.story.maxHp = s.maxHp -- 255
	storyRun.story.hpAtGate = s.hpAtGate -- 256
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 257
	storyRun.story.settled = s.settled -- 258
	storyRun.story.phase = s.phase -- 259
	storyRun.story.countTick = s.countTick -- 260
	storyRun.story.phaseTick = s.phaseTick -- 261
	storyRun.story.handTicks = s.handTicks -- 262
	storyRun.story.handDone = s.handDone -- 263
	storyRun.story.lineSaid = s.lineSaid -- 264
	storyRun.story.tied = s.tied -- 265
	storyRun.story.carry = s.carry -- 266
	storyRun.story.escortDone = s.escortDone -- 267
	storyRun.story.craftedWeapon = s.craftedWeapon -- 268
	storyRun.story.equippedWeapon = s.equippedWeapon -- 269
	storyRun.inventory.wood = s.wood -- 270
	storyRun.inventory.bell = s.bell -- 271
	storyRun.inventory.scrap = s.scrap -- 272
	storyRun.inventory.wedge = s.wedge -- 273
	storyRun.inventory.ammo = s.ammo -- 274
	storyRun.inventory.shield = s.shield -- 275
	storyRun.inventory.pass = s.pass -- 276
	storyRun.inventory.quickbelt = s.quickbelt -- 277
	local k = 0 -- 278
	do -- 278
		k = 0 -- 279
		while k < #s.taken do -- 279
			storyRun.taken[s.taken[k + 1]] = true -- 280
			k = k + 1 -- 279
		end -- 279
	end -- 279
	do -- 279
		k = 0 -- 282
		while k < #s.segments do -- 282
			storyRun.story.segments[s.segments[k + 1]] = true -- 283
			k = k + 1 -- 282
		end -- 282
	end -- 282
	if s.campaignRoute ~= nil then -- 282
		storyRun.route = s.campaignRoute -- 286
	end -- 286
	if s.joined ~= nil then -- 286
		storyRun.joined = s.joined -- 289
	end -- 289
	if s.c1Latch ~= nil then -- 289
		storyRun.c1Latch = s.c1Latch -- 292
	end -- 292
	if s.c2Latch ~= nil then -- 292
		storyRun.c2Latch = s.c2Latch -- 295
	end -- 295
	local stTalents = createStoryTalents(s.seed) -- 297
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 297
		stTalents.randomState = s.talentSeed -- 299
	end -- 299
	stTalents.room = s.talentRoom or "" -- 301
	stTalents.ranks.vitality = s.talentVitality or 0 -- 302
	stTalents.ranks.reload = s.talentReload or 0 -- 303
	stTalents.ranks.guard = s.talentGuard or 0 -- 304
	stTalents.ranks.craft = s.talentCraft or 0 -- 305
	if s.talentOffers ~= nil then -- 305
		do -- 305
			k = 0 -- 307
			while k < #s.talentOffers do -- 307
				local t = s.talentOffers[k + 1] -- 308
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 308
					local ____stTalents_offers_10 = stTalents.offers -- 308
					____stTalents_offers_10[#____stTalents_offers_10 + 1] = t -- 310
				end -- 310
				k = k + 1 -- 307
			end -- 307
		end -- 307
	end -- 307
	storyRun.story.talents = stTalents -- 314
	current = idx -- 315
	setMode(1) -- 316
	if fe ~= nil then -- 316
		fe.screen = "play" -- 318
	end -- 318
	play = nil -- 320
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 321
	local cur = play -- 322
	if cur ~= nil and s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 322
		cur.cartAxle = s.cartAxle -- 324
		cur.cartDocked = s.cartDocked -- 325
	end -- 325
	return play -- 327
end -- 327
function place(lb, x, y, ax, ay) -- 345
	if lb == nil then -- 345
		return -- 347
	end -- 347
	lb.position = Vec2(x, y) -- 349
	lb.anchor = Vec2(ax, ay) -- 350
	lb.visible = true -- 351
end -- 351
function setMode(nextMode) -- 686
	mode = nextMode -- 687
	if grayboxLayer ~= nil then -- 687
		grayboxLayer.visible = mode == 0 -- 689
	end -- 689
	if fe ~= nil then -- 689
		fe:setVisible(mode == 1) -- 692
	end -- 692
	if campaignLayer ~= nil then -- 692
		campaignLayer.visible = mode == 2 -- 695
	end -- 695
	dirty = true -- 697
	clock:reset() -- 698
end -- 698
function flushProfile() -- 705
	local cur = play -- 706
	if cur ~= nil and cur.archiveDirty then -- 706
		cur.archiveDirty = false -- 708
		markProfilePending(profile) -- 709
	end -- 709
	local ok = flushSaveProfile() -- 711
	if not ok and cur ~= nil then -- 711
		cur.archiveDirty = true -- 713
	end -- 713
	return ok -- 715
end -- 715
function officialStartIndex() -- 719
	local mp = profile.museumPhase -- 720
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 721
	return inMuseum and roomIndexByKey("museum") or 0 -- 722
end -- 722
function roomIndexByKey(key) -- 725
	local i = 0 -- 726
	do -- 726
		i = 0 -- 727
		while i < #ROOMS do -- 727
			if ROOMS[i + 1].key == key then -- 727
				return i -- 729
			end -- 729
			i = i + 1 -- 727
		end -- 727
	end -- 727
	return 0 -- 732
end -- 732
function enterPlayRoom(idx, source, fresh) -- 735
	if source == nil then -- 735
		source = "debug" -- 735
	end -- 735
	if fresh == nil then -- 735
		fresh = false -- 735
	end -- 735
	current = idx -- 736
	setMode(1) -- 737
	if fe ~= nil then -- 737
		fe.screen = "play" -- 739
	end -- 739
	play = nil -- 741
	if fresh or storyRun == nil then -- 741
		storyRun = createRun(20261124, source, profile) -- 744
	else -- 744
		storyRun.source = source -- 746
	end -- 746
	ensurePlay() -- 748
	local firstPlay = play -- 750
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 750
		firstPlay.phase = "prologue-wake" -- 752
	end -- 752
	flushProfile() -- 754
end -- 754
function pickByIndex(idx, source) -- 757
	if source == nil then -- 757
		source = "debug" -- 757
	end -- 757
	if mode == 2 then -- 757
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 757
			return -- 760
		end -- 760
		current = idx -- 762
		play = nil -- 763
		clock:reset() -- 764
		ensurePlay() -- 765
		return -- 766
	end -- 766
	if idx < 0 or idx >= #ROOMS then -- 766
		return -- 769
	end -- 769
	flushProfile() -- 771
	if storyRun ~= nil then -- 771
		storyRun.source = source -- 773
	end -- 773
	current = idx -- 775
	dirty = true -- 776
	play = nil -- 777
	clock:reset() -- 778
	if mode == 1 then -- 778
		if fe ~= nil then -- 778
			fe.screen = "play" -- 781
		end -- 781
		ensurePlay() -- 783
	end -- 783
end -- 783
function applySize() -- 787
	if root == nil then -- 787
		return -- 789
	end -- 789
	root.size = Size(viewW, viewH) -- 791
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 792
	stageVp = computeStageViewport(viewW, viewH) -- 793
	if input ~= nil then -- 793
		input:setStageViewport(stageVp) -- 795
	end -- 795
	if fe ~= nil then -- 795
		fe:setStagePlacement(stageVp) -- 798
	end -- 798
	if campaignLayer ~= nil then -- 798
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 801
	end -- 801
	if grayboxLayer ~= nil then -- 801
		grayboxLayer.position = Vec2(0, 0) -- 804
	end -- 804
end -- 804
function syncFrameAdapters(frameDt) -- 808
	if input == nil then -- 808
		return -- 810
	end -- 810
	local p = play -- 812
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 813
	local isTrialMode = mode == 2 and p ~= nil -- 814
	local gameplayActive = isPlayMode or isTrialMode -- 815
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 817
		p, -- 819
		stageVp.stageW, -- 819
		stageVp.stageH, -- 819
		input:isTouchMode() -- 819
	) or ({}) -- 819
	if touchControls ~= nil and touchRouter ~= nil then -- 819
		local isFs = false -- 823
		if canToggleFullscreen() then -- 823
			do -- 823
				local function ____catch() -- 823
					isFs = false -- 828
				end -- 828
				local ____try = pcall(function() -- 828
					isFs = App.fullScreen -- 826
				end) -- 826
				if not ____try then -- 826
					____catch() -- 826
				end -- 826
			end -- 826
		end -- 826
		local ____touchControls_42 = touchControls -- 831
		local ____touchControls_syncContext_43 = touchControls.syncContext -- 831
		local ____stageVp_35 = stageVp -- 832
		local ____mode_36 = mode -- 833
		local ____temp_37 = fe ~= nil and fe.screen or "title" -- 834
		local ____run_38 = run -- 836
		local ____temp_39 = fe ~= nil and fe.cam or nil -- 837
		local ____input_40 = input -- 838
		local ____touchRouter_41 = touchRouter -- 839
		local ____temp_33 -- 840
		if fe ~= nil then -- 840
			____temp_33 = fe.contract:isAssistHintsEnabled() -- 840
		else -- 840
			____temp_33 = false -- 840
		end -- 840
		local ____temp_34 -- 841
		if fe ~= nil then -- 841
			____temp_34 = fe.audio:isAllMuted() -- 841
		else -- 841
			____temp_34 = false -- 841
		end -- 841
		____touchControls_syncContext_43(____touchControls_42, { -- 831
			viewport = ____stageVp_35, -- 832
			mode = ____mode_36, -- 833
			screen = ____temp_37, -- 834
			play = p, -- 835
			run = ____run_38, -- 836
			cam = ____temp_39, -- 837
			input = ____input_40, -- 838
			router = ____touchRouter_41, -- 839
			assistHintsEnabled = ____temp_33, -- 840
			isMuted = ____temp_34, -- 841
			isFullscreen = isFs, -- 842
			storyTalentBoxes = storyTalentBoxes, -- 843
			dt = frameDt -- 844
		}) -- 844
	end -- 844
	if gamepadRouter ~= nil then -- 844
		local trial = run and run.trial -- 849
		local trialEnded = isTrialMode and trial ~= nil and (trial.lost or (run and run.finished) == true) -- 850
		local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 851
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 852
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 855
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 856
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 857
		local ____temp_48 -- 860
		if isPlayMode and p ~= nil then -- 860
			____temp_48 = isCutsceneBlockingPlay(p) -- 860
		else -- 860
			____temp_48 = false -- 860
		end -- 860
		local cutsceneBlocking = ____temp_48 -- 860
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 861
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 863
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 865
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 867
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 870
		local playerScreenX = stageVp.stageW * 0.5 -- 872
		local playerScreenY = stageVp.stageH * 0.38 -- 873
		if p ~= nil then -- 873
			if isPlayMode and fe ~= nil then -- 873
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 876
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 877
			else -- 877
				playerScreenX = stageVp.stageW * 0.45 -- 879
				playerScreenY = stageVp.stageH * 0.36 -- 880
			end -- 880
		end -- 880
		local enemyTargets = canShoot and p ~= nil and (isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or collectTrialAimTargets(p, stageVp.stageW, stageVp.stageH)) or ({}) -- 884
		local gpCtx = { -- 890
			stageW = stageVp.stageW, -- 891
			stageH = stageVp.stageH, -- 892
			uiScale = stageVp.uiScale, -- 893
			modal = modal, -- 894
			gameplayActive = gameplayActive, -- 895
			reloadActive = reloadActive, -- 896
			craftActive = craftActive, -- 897
			talentOfferCount = talentOfferCount, -- 898
			childMode = p ~= nil and p.childMode, -- 899
			allowDepth = allowDepth, -- 900
			canShoot = canShoot, -- 901
			canBottleAim = canBottleAim, -- 902
			playerRolling = p ~= nil and p.player.rollT > 0, -- 903
			inLowArch = inLowArch, -- 904
			inTowerEnd = inTowerEnd, -- 905
			playerFacing = p ~= nil and p.player.facing or 1, -- 906
			playerScreenX = playerScreenX, -- 907
			playerScreenY = playerScreenY, -- 908
			enemyTargets = enemyTargets -- 909
		} -- 909
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 911
	end -- 911
end -- 911
function renderTouchOverlay() -- 915
	if touchControls ~= nil and touchRouter ~= nil then -- 915
		touchControls:render(touchRouter) -- 917
	end -- 917
end -- 917
function tick(frameDt) -- 921
	appClock = appClock + math.min( -- 922
		0.05, -- 922
		math.max(0, frameDt) -- 922
	) -- 922
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 923
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 924
	if w ~= viewW or h ~= viewH then -- 924
		viewW = w -- 926
		viewH = h -- 927
		applySize() -- 928
		dirty = true -- 929
	end -- 929
	if input == nil then -- 929
		return -- 932
	end -- 932
	syncFrameAdapters(frameDt) -- 934
	input:update() -- 935
	if input.userInteracted then -- 935
		onFirstUserGesture() -- 938
	end -- 938
	if input.muteTogglePressed and fe ~= nil then -- 938
		input.muteTogglePressed = false -- 941
		fe.audio:toggleAllMuted() -- 942
	end -- 942
	if input.fullscreenTogglePressed then -- 942
		input.fullscreenTogglePressed = false -- 945
		toggleFullscreen() -- 946
	end -- 946
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 946
		input.artifactTogglePressed = false -- 949
		play:toggleArtifactWeapon() -- 950
	end -- 950
	if input.bottleCanceled and play ~= nil then -- 950
		input.bottleCanceled = false -- 953
		play.aimHold = 0 -- 954
		play.bottleAimX = -1 -- 955
	end -- 955
	if mode == 2 and (run and run.trial) ~= nil then -- 955
		tickCampaign(frameDt) -- 959
		renderTouchOverlay() -- 960
		return -- 961
	end -- 961
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 961
		play:chooseTalent(input.pickRoom - 1) -- 967
		input.pickRoom = 0 -- 968
	end -- 968
	if isReleaseBuild() then -- 968
		input.toggleView.pressed = false -- 972
		input.pickRoom = 0 -- 973
		input.tab.pressed = false -- 974
	else -- 974
		if input.toggleView.pressed then -- 974
			input.toggleView.pressed = false -- 978
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 979
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 979
				ensurePlay() -- 981
			end -- 981
		end -- 981
		if input.pickRoom ~= 0 then -- 981
			local idx = input.pickRoom - 1 -- 987
			input.pickRoom = 0 -- 988
			pickByIndex(idx) -- 989
		elseif input.tab.pressed then -- 989
			input.tab.pressed = false -- 991
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 991
				pickByIndex((current + 1) % #ROOMS) -- 993
			end -- 993
		end -- 993
	end -- 993
	if mode == 2 then -- 993
		tickCampaign(frameDt) -- 999
	elseif mode == 1 then -- 999
		tickFrontend(frameDt) -- 1001
	elseif dirty then -- 1001
		redrawGraybox() -- 1003
		dirty = false -- 1004
	end -- 1004
	renderTouchOverlay() -- 1006
end -- 1006
function registerPlay() -- 1010
	local reg = _G.package.loaded -- 1011
	reg["watch.play"] = play -- 1012
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 1013
	reg["watch.room"] = rooms[current + 1].key -- 1014
end -- 1014
function ensurePlay(resume) -- 1018
	if mode == 2 then -- 1018
		if run == nil then -- 1018
			run = createRun() -- 1021
		end -- 1021
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 1023
	else -- 1023
		if storyRun == nil then -- 1023
			storyRun = createRun(20261124, "debug", profile) -- 1028
		end -- 1028
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1030
	end -- 1030
	registerPlay() -- 1032
	clock:reset() -- 1033
	if fe ~= nil and mode == 1 then -- 1033
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1035
	end -- 1035
end -- 1035
function startTrial() -- 1039
	current = 0 -- 1040
	trialTalentSelected = 0 -- 1041
	run = createTrial(App.rand) -- 1042
	setMode(2) -- 1043
	ensurePlay() -- 1044
end -- 1044
function tickCampaign(frameDt) -- 1047
	if input == nil then -- 1047
		return -- 1049
	end -- 1049
	if play == nil then -- 1049
		ensurePlay() -- 1052
	end -- 1052
	if play == nil then -- 1052
		return -- 1055
	end -- 1055
	local p = play -- 1057
	p.aimX = input.mx -- 1058
	p.aimY = input.my -- 1059
	local zoneTap = input.touchZoneTap -- 1061
	input.touchZoneTap = "" -- 1062
	local trial = run and run.trial -- 1064
	if trial ~= nil then -- 1064
		local ended = trial.lost or (run and run.finished) == true -- 1066
		local pick = input.pickRoom -- 1067
		input.pickRoom = 0 -- 1068
		if zoneTap == "trial:resume" and p.paused and not ended then -- 1068
			p.paused = false -- 1071
			clock:reset() -- 1072
			input:consumeEdges() -- 1073
			drawCampaign(p) -- 1074
			return -- 1075
		end -- 1075
		if zoneTap == "trial:retry" then -- 1075
			input:consumeEdges() -- 1078
			startTrial() -- 1079
			return -- 1080
		end -- 1080
		if zoneTap == "trial:title" then -- 1080
			input:consumeEdges() -- 1083
			current = 0 -- 1084
			play = nil -- 1085
			run = nil -- 1086
			setMode(1) -- 1087
			if fe ~= nil then -- 1087
				fe.screen = "title" -- 1089
				fe.menus:resetInput() -- 1090
			end -- 1090
			return -- 1092
		end -- 1092
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1092
			input:consumeEdges() -- 1096
			current = 0 -- 1097
			play = nil -- 1098
			run = nil -- 1099
			setMode(1) -- 1100
			if fe ~= nil then -- 1100
				fe.screen = "title" -- 1102
				fe.menus:resetInput() -- 1103
			end -- 1103
			return -- 1105
		end -- 1105
		if ended or p.paused and input.retry.pressed then -- 1105
			local restart = input.retry.pressed or ended and input.navConfirm -- 1108
			input:consumeEdges() -- 1109
			if restart then -- 1109
				startTrial() -- 1110
			else -- 1110
				drawCampaign(p) -- 1111
			end -- 1111
			return -- 1112
		end -- 1112
		input.retry.pressed = false -- 1114
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1114
			if trialTalentSelected >= #trial.offers then -- 1114
				trialTalentSelected = 0 -- 1117
			end -- 1117
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1117
				local idx = __TS__ParseInt( -- 1120
					string.sub(zoneTap, 8), -- 1120
					10 -- 1120
				) -- 1120
				if idx >= 0 and idx < #trial.offers then -- 1120
					p:chooseTalent(idx) -- 1122
				end -- 1122
			elseif pick > 0 then -- 1122
				p:chooseTalent(pick - 1) -- 1125
			else -- 1125
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1127
				if delta ~= 0 then -- 1127
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1131
				end -- 1131
				if input.talentConfirm or input.navConfirm then -- 1131
					p:chooseTalent(trialTalentSelected) -- 1134
				end -- 1134
			end -- 1134
			input:consumeEdges() -- 1137
			clock:reset() -- 1138
			drawCampaign(p) -- 1139
			return -- 1140
		end -- 1140
	end -- 1140
	if input.retry.pressed then -- 1140
		input.retry.pressed = false -- 1145
		input:consumeEdges() -- 1146
		play = nil -- 1148
		ensurePlay() -- 1149
		return -- 1150
	end -- 1150
	if input.pause.pressed or p.paused and input.navBack then -- 1150
		input.pause.pressed = false -- 1153
		p.paused = not p.paused -- 1154
		clock:reset() -- 1155
		input:consumeEdges() -- 1156
	end -- 1156
	if p.paused then -- 1156
		drawCampaign(p) -- 1159
		return -- 1160
	end -- 1160
	local steps = clock:advance(frameDt) -- 1163
	local i = 0 -- 1164
	do -- 1164
		i = 0 -- 1165
		while i < steps do -- 1165
			input:beginStep(i == 0) -- 1166
			p:update(STEP, input) -- 1167
			input:endStep() -- 1168
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1168
				break -- 1170
			end -- 1170
			i = i + 1 -- 1165
		end -- 1165
	end -- 1165
	if p.wantRoom ~= "" then -- 1165
		local key = p.wantRoom -- 1175
		p.wantRoom = "" -- 1176
		local idx = -1 -- 1177
		local j = 0 -- 1178
		do -- 1178
			j = 0 -- 1179
			while j < #CAMPAIGN_ROOMS do -- 1179
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1179
					idx = j -- 1181
				end -- 1181
				j = j + 1 -- 1179
			end -- 1179
		end -- 1179
		if idx >= 0 then -- 1179
			current = idx -- 1185
			play = nil -- 1186
			ensurePlay() -- 1187
		end -- 1187
		return -- 1189
	end -- 1189
	drawCampaign(p) -- 1191
end -- 1191
function goalLabel(goal) -- 1194
	if goal == "dock_cart" then -- 1194
		return "推车入窝并抬闩" -- 1196
	end -- 1196
	if goal == "raise_latch" then -- 1196
		return "抬闩开侧门" -- 1199
	end -- 1199
	return "到段出口" -- 1201
end -- 1201
function drawCampaign(p) -- 1204
	if campaignDraw == nil then -- 1204
		return -- 1206
	end -- 1206
	local w = stageVp.stageW -- 1208
	local h = stageVp.stageH -- 1209
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1210
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1211
	p:draw(campaignDraw, w, h) -- 1212
	local room = CAMPAIGN_ROOMS[current + 1] -- 1213
	local c = room.campaign -- 1214
	local r = run -- 1215
	local line = room.name -- 1216
	if c ~= nil then -- 1216
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 1218
	end -- 1218
	if p.paused then -- 1218
		line = line .. "  · 已暂停 Esc 继续" -- 1222
	end -- 1222
	local trial = r and r.trial -- 1224
	if trial ~= nil and r ~= nil then -- 1224
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 1226
		if p.paused then -- 1226
			line = line .. " · 暂停" -- 1227
		elseif trial.lost then -- 1227
			line = line .. " · 护送失败" -- 1228
		elseif r.finished then -- 1228
			line = line .. " · 护送完成" -- 1229
		elseif #trial.offers > 0 then -- 1229
			line = line .. " · 选择本段本领" -- 1230
		elseif c ~= nil then -- 1230
			line = line .. " · " .. goalLabel(c.goal) -- 1231
		end -- 1231
	end -- 1231
	if campaignHud ~= nil then -- 1231
		campaignHud.text = line -- 1234
		campaignHud.position = Vec2(24 + safeL, h - 14 - safeT) -- 1235
		campaignHud.visible = true -- 1236
	end -- 1236
	if campaignSub ~= nil then -- 1236
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 1239
		if r ~= nil then -- 1239
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 1241
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 1242
		end -- 1242
		if p.flash ~= "" then -- 1242
			sub = (sub .. " · ") .. p.flash -- 1248
		end -- 1248
		if trial ~= nil and r ~= nil then -- 1248
			local gpMode = input ~= nil and input:isGamepadMode() -- 1251
			local touchMode = input ~= nil and input:isTouchMode() -- 1252
			if trial.lost or r.finished then -- 1252
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · A 再开一局 · START 返回标题" or (touchMode and " · 点下方按钮再开或返回标题" or " · R 再开一局 · Esc 返回标题")) -- 1254
			elseif p.paused then -- 1254
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · START 继续 · 长按BACK 重开 · Y 返回标题" or (touchMode and " · 点下方按钮继续/重开/返回标题" or " · Esc 继续 · R 重新开局 · E 返回标题")) -- 1256
			elseif #trial.offers > 0 then -- 1256
				sub = table.concat( -- 1258
					__TS__ArrayMap( -- 1258
						trial.offers, -- 1258
						function(____, talent, index) -- 1258
							local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1259
							return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1260
						end -- 1258
					), -- 1258
					"　" -- 1261
				) -- 1261
			else -- 1261
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 1263
			end -- 1263
		end -- 1263
		campaignSub.text = sub -- 1266
		campaignSub.position = Vec2(24 + safeL, h - 44 - safeT) -- 1267
		campaignSub.visible = true -- 1268
	end -- 1268
end -- 1268
function tickFrontend(frameDt) -- 1272
	if fe == nil or input == nil then -- 1272
		return -- 1274
	end -- 1274
	if fe.screen ~= "play" then -- 1274
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1279
		input:consumeEdges() -- 1280
		if act.type == "splashDone" then -- 1280
			fe.menus:resetInput() -- 1282
			fe.screen = "title" -- 1283
		elseif act.type == "trial" then -- 1283
			startTrial() -- 1285
		elseif act.type == "continue" then -- 1285
			if continueOfficialStory() == nil then -- 1285
				enterPlayRoom( -- 1288
					officialStartIndex(), -- 1288
					"official", -- 1288
					true -- 1288
				) -- 1288
			end -- 1288
		elseif act.type == "start" then -- 1288
			clearSession() -- 1292
			refreshTitleSessionFlag() -- 1293
			enterPlayRoom( -- 1294
				officialStartIndex(), -- 1294
				"official", -- 1294
				true -- 1294
			) -- 1294
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1294
			enterPlayRoom(act.roomIndex, "chapter") -- 1296
		elseif act.type == "openChapters" then -- 1296
			fe.menus:openChapters() -- 1298
			fe.screen = "chapters" -- 1299
		elseif act.type == "openControls" then -- 1299
			fe.menus:resetInput() -- 1301
			fe.screen = "controls" -- 1302
		elseif act.type == "backTitle" then -- 1302
			fe.menus:resetInput() -- 1304
			fe.screen = "title" -- 1305
		elseif act.type == "backPause" then -- 1305
			fe.menus:resetInput() -- 1307
			fe.screen = "play" -- 1308
		elseif act.type == "quit" then -- 1308
			quitGame() -- 1310
		end -- 1310
		return -- 1312
	end -- 1312
	if play == nil then -- 1312
		ensurePlay() -- 1317
	end -- 1317
	if play == nil then -- 1317
		return -- 1320
	end -- 1320
	local p = play -- 1322
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1324
	if input.retry.pressed and not inTowerEnding then -- 1324
		input:consumeEdges() -- 1326
		ensurePlay({checkpoint = p.checkpoint}) -- 1328
		return -- 1329
	end -- 1329
	p.aimX = input.mx -- 1332
	p.aimY = input.my -- 1333
	local zoneTap = input.touchZoneTap -- 1335
	input.touchZoneTap = "" -- 1336
	local offers = p:getStoryTalentOffers() -- 1338
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1338
		if fe.hud.talentSelected >= #offers then -- 1338
			fe.hud.talentSelected = 0 -- 1341
		end -- 1341
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1341
			local idx = __TS__ParseInt( -- 1344
				string.sub(zoneTap, 8), -- 1344
				10 -- 1344
			) -- 1344
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1344
				input.fire.pressed = false -- 1346
			end -- 1346
		else -- 1346
			if input.talentDelta ~= 0 then -- 1346
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1350
				input.talentDelta = 0 -- 1351
			end -- 1351
			if input.talentConfirm then -- 1351
				p:chooseTalent(fe.hud.talentSelected) -- 1354
				input.talentConfirm = false -- 1355
				input.fire.pressed = false -- 1356
			elseif (input.uiPressed or input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1356
				input.fire.pressed = false -- 1359
			end -- 1359
		end -- 1359
	end -- 1359
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" and input.navConfirm then -- 1359
		input.interact.pressed = true -- 1366
	end -- 1366
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1366
		p:closeCraftBench() -- 1370
		input:consumeEdges() -- 1371
		return -- 1372
	end -- 1372
	if not p.paused and input.pause.pressed then -- 1372
		p.paused = true -- 1375
		p.aimHold = 0 -- 1376
		p.bottleAimX = -1 -- 1377
		saveCurrentSession() -- 1378
		fe.menus:openPause() -- 1379
		input:clearTransient(true) -- 1380
		input:consumeEdges() -- 1381
	end -- 1381
	if p.paused then -- 1381
		clock:reset() -- 1386
		local pauseAct = fe:renderPlay( -- 1387
			frameDt, -- 1387
			p, -- 1387
			input, -- 1387
			stageVp.stageW, -- 1387
			stageVp.stageH -- 1387
		) -- 1387
		input:consumeEdges() -- 1388
		if pauseAct.type == "resume" then -- 1388
			p.paused = false -- 1390
		elseif pauseAct.type == "retry" then -- 1390
			ensurePlay({checkpoint = p.checkpoint}) -- 1392
		elseif pauseAct.type == "openChapters" then -- 1392
			fe.menus:openChapters(current) -- 1394
			fe.screen = "chapters" -- 1395
		elseif pauseAct.type == "toggleFullscreen" then -- 1395
			toggleFullscreen() -- 1397
		elseif pauseAct.type == "quit" then -- 1397
			quitGame() -- 1399
		elseif pauseAct.type == "toTitle" then -- 1399
			saveCurrentSession() -- 1401
			refreshTitleSessionFlag() -- 1402
			fe.menus:resetInput() -- 1403
			fe.screen = "title" -- 1404
		end -- 1404
		return -- 1406
	end -- 1406
	local steps = clock:advance(frameDt) -- 1409
	local i = 0 -- 1410
	do -- 1410
		i = 0 -- 1411
		while i < steps do -- 1411
			input:beginStep(i == 0) -- 1412
			p:update(STEP, input) -- 1413
			input:endStep() -- 1414
			if p.wantRoom ~= "" then -- 1414
				break -- 1416
			end -- 1416
			i = i + 1 -- 1411
		end -- 1411
	end -- 1411
	if p.wantRoom ~= "" then -- 1411
		local key = p.wantRoom -- 1422
		p.wantRoom = "" -- 1423
		local idx = -1 -- 1424
		local j = 0 -- 1425
		do -- 1425
			j = 0 -- 1426
			while j < #ROOMS do -- 1426
				if ROOMS[j + 1].key == key then -- 1426
					idx = j -- 1428
				end -- 1428
				j = j + 1 -- 1426
			end -- 1426
		end -- 1426
		if idx >= 0 then -- 1426
			flushProfile() -- 1435
			local leaving = p:drainEvents() -- 1436
			if p.restartStory then -- 1436
				if storyRun ~= nil and storyRun.source == "official" then -- 1436
					clearSession() -- 1440
					refreshTitleSessionFlag() -- 1441
				end -- 1441
				storyRun = createRun(20261124, storyRun == nil and "official" or storyRun.source, profile) -- 1443
			end -- 1443
			current = idx -- 1445
			ensurePlay() -- 1446
			local fresh = play -- 1447
			if fresh ~= nil then -- 1447
				fresh:adoptEvents(leaving) -- 1449
			end -- 1449
			if not p.restartStory then -- 1449
				saveCurrentSession() -- 1452
			end -- 1452
			clock:reset() -- 1454
			dirty = true -- 1455
		end -- 1455
		return -- 1457
	end -- 1457
	flushProfile() -- 1461
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1461
		clearSession() -- 1463
		refreshTitleSessionFlag() -- 1464
	elseif p.sessionDirty then -- 1464
		saveCurrentSession() -- 1466
	end -- 1466
	fe:renderPlay( -- 1468
		frameDt, -- 1468
		p, -- 1468
		input, -- 1468
		stageVp.stageW, -- 1468
		stageVp.stageH -- 1468
	) -- 1468
end -- 1468
function redrawGraybox() -- 1472
	if draw == nil then -- 1472
		return -- 1474
	end -- 1474
	local w = viewW -- 1476
	local h = viewH -- 1477
	local room = ROOMS[current + 1] -- 1478
	draw:clear() -- 1480
	draw:drawRect( -- 1481
		Rect(0, h - TOP_H, w, TOP_H), -- 1481
		C_BG -- 1481
	) -- 1481
	draw:drawRect( -- 1482
		Rect(0, 0, w, BOTTOM_H), -- 1482
		C_BG -- 1482
	) -- 1482
	draw:drawSegment( -- 1483
		Vec2(0, h - TOP_H), -- 1483
		Vec2(w, h - TOP_H), -- 1483
		1, -- 1483
		Color(52, 54, 54, 255) -- 1483
	) -- 1483
	draw:drawSegment( -- 1484
		Vec2(0, BOTTOM_H), -- 1484
		Vec2(w, BOTTOM_H), -- 1484
		1, -- 1484
		Color(52, 54, 54, 255) -- 1484
	) -- 1484
	local v = computeView(room, w, h) -- 1486
	renderWorld( -- 1487
		draw, -- 1487
		room, -- 1487
		v, -- 1487
		w, -- 1487
		h -- 1487
	) -- 1487
	local roomTop = v.groundPx + room.height * v.scale -- 1489
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1490
	place( -- 1492
		titleLabel, -- 1492
		48, -- 1492
		h - 40, -- 1492
		0, -- 1492
		1 -- 1492
	) -- 1492
	place( -- 1493
		roomLabel, -- 1493
		48, -- 1493
		h - 96, -- 1493
		0, -- 1493
		1 -- 1493
	) -- 1493
	place( -- 1494
		captionLabel, -- 1494
		48, -- 1494
		h - 140, -- 1494
		0, -- 1494
		1 -- 1494
	) -- 1494
	place( -- 1496
		switchLabel, -- 1496
		48, -- 1496
		40, -- 1496
		0, -- 1496
		0 -- 1496
	) -- 1496
	place( -- 1497
		hintLabel, -- 1497
		48, -- 1497
		84, -- 1497
		0, -- 1497
		0 -- 1497
	) -- 1497
	place( -- 1498
		rulerLabel, -- 1498
		w - 216, -- 1498
		roomTop + 36 + v.scale * 0.5 - 14, -- 1498
		1, -- 1498
		0 -- 1498
	) -- 1498
	place( -- 1499
		standLabel, -- 1499
		48, -- 1499
		roomTop + 40, -- 1499
		0, -- 1499
		0 -- 1499
	) -- 1499
	place( -- 1500
		cartLabel, -- 1500
		48, -- 1500
		roomTop + 92, -- 1500
		0, -- 1500
		0 -- 1500
	) -- 1500
	if roomLabel ~= nil then -- 1500
		roomLabel.text = room.name -- 1503
	end -- 1503
	if captionLabel ~= nil then -- 1503
		captionLabel.text = room.caption -- 1506
	end -- 1506
	if hintLabel ~= nil then -- 1506
		local hintIdx = math.min(current, #HINTS - 1) -- 1509
		local lines = HINTS[hintIdx + 1] -- 1510
		local merged = lines[1] -- 1511
		do -- 1511
			local i = 1 -- 1512
			while i < #lines do -- 1512
				merged = (merged .. "    ") .. lines[i + 1] -- 1513
				i = i + 1 -- 1512
			end -- 1512
		end -- 1512
		hintLabel.text = merged -- 1515
	end -- 1515
	local specs = collectLabels(room, v, w) -- 1518
	local body = {} -- 1519
	local small = {} -- 1520
	do -- 1520
		local i = 0 -- 1521
		while i < #specs do -- 1521
			local s = specs[i + 1] -- 1522
			if s.size >= 24 then -- 1522
				body[#body + 1] = s -- 1524
			else -- 1524
				small[#small + 1] = s -- 1526
			end -- 1526
			i = i + 1 -- 1521
		end -- 1521
	end -- 1521
	applyPool(body, poolBody) -- 1529
	applyPool(small, poolSmall) -- 1530
	if LAYOUT_AUDIT then -- 1530
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1533
	end -- 1533
end -- 1533
function applyPool(specs, pool) -- 1537
	do -- 1537
		local i = 0 -- 1538
		while i < #pool do -- 1538
			local lb = pool[i + 1] -- 1539
			if i < #specs then -- 1539
				local s = specs[i + 1] -- 1541
				lb.text = s.text -- 1542
				lb.position = Vec2(s.x, s.y) -- 1543
				lb.anchor = Vec2(s.ax, s.ay) -- 1544
				lb.color = s.color -- 1545
				lb.visible = true -- 1546
			else -- 1546
				lb.visible = false -- 1548
			end -- 1548
			i = i + 1 -- 1538
		end -- 1538
	end -- 1538
end -- 1538
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
local function handleBackButton() -- 144
	if mode == 0 then -- 144
		setMode(1) -- 146
		return -- 147
	end -- 147
	if mode == 2 and play ~= nil then -- 147
		local trial = run and run.trial -- 150
		if trial ~= nil and (trial.lost or (run and run.finished) == true) then -- 150
			current = 0 -- 152
			play = nil -- 153
			run = nil -- 154
			setMode(1) -- 155
			if fe ~= nil then -- 155
				fe.screen = "title" -- 157
				fe.menus:resetInput() -- 158
			end -- 158
			return -- 160
		end -- 160
		play.paused = not play.paused -- 162
		clock:reset() -- 163
		if input ~= nil then -- 163
			input:clearTransient(true) -- 164
		end -- 164
		return -- 165
	end -- 165
	if fe == nil then -- 165
		return -- 168
	end -- 168
	if fe.screen == "splash" then -- 168
		fe.menus:resetSplash() -- 171
		fe.screen = "title" -- 172
		fe.menus:resetInput() -- 173
		return -- 174
	end -- 174
	if fe.screen == "chapters" or fe.screen == "controls" then -- 174
		fe.menus:triggerBack() -- 177
		return -- 178
	end -- 178
	if fe.screen == "title" then -- 178
		if not canQuitApp() then -- 178
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 182
			return -- 183
		end -- 183
		if appClock - lastBackPressClock <= 2 then -- 183
			quitGame() -- 186
		else -- 186
			lastBackPressClock = appClock -- 188
			fe:showToast("再按一次返回退出游戏", 2) -- 189
		end -- 189
		return -- 191
	end -- 191
	if fe.screen == "play" and play ~= nil then -- 191
		if play.paused then -- 191
			fe.menus:triggerBack() -- 195
			return -- 196
		end -- 196
		if play.craftBench.active then -- 196
			play:closeCraftBench() -- 199
			return -- 200
		end -- 200
		play.paused = true -- 202
		play.aimHold = 0 -- 203
		play.bottleAimX = -1 -- 204
		saveCurrentSession() -- 205
		fe.menus:openPause() -- 206
		if input ~= nil then -- 206
			input:clearTransient(true) -- 207
		end -- 207
	end -- 207
end -- 144
local function makeGrayboxLabel(text, size, color) -- 330
	if grayboxLayer == nil then -- 330
		return nil -- 332
	end -- 332
	local lb = Label(FONT, size) -- 334
	if lb == nil then -- 334
		return nil -- 336
	end -- 336
	lb.text = text -- 338
	lb.color = color -- 339
	lb:addTo(grayboxLayer) -- 340
	lb.visible = true -- 341
	return lb -- 342
end -- 330
function ____exports.start(parent, initialMode, startScreen) -- 354
	if initialMode == nil then -- 354
		initialMode = 1 -- 354
	end -- 354
	if startScreen == nil then -- 354
		startScreen = "title" -- 354
	end -- 354
	root = parent -- 355
	mode = initialMode -- 356
	grayboxLayer = Node() -- 359
	grayboxLayer.order = 2 -- 360
	grayboxLayer:addTo(parent) -- 361
	draw = DrawNode() -- 363
	draw:addTo(grayboxLayer) -- 364
	campaignLayer = Node() -- 367
	campaignLayer.order = 3 -- 368
	campaignLayer:addTo(parent) -- 369
	campaignDraw = DrawNode() -- 370
	campaignDraw:addTo(campaignLayer) -- 371
	campaignHud = Label(FONT, 24) -- 372
	if campaignHud ~= nil then -- 372
		campaignHud.color = C_TEXT -- 374
		campaignHud.anchor = Vec2(0, 1) -- 375
		campaignHud:addTo(campaignLayer) -- 376
		campaignHud.visible = true -- 377
	end -- 377
	campaignSub = Label(FONT, 20) -- 379
	if campaignSub ~= nil then -- 379
		campaignSub.color = C_ACCENT -- 381
		campaignSub.anchor = Vec2(0, 1) -- 382
		campaignSub:addTo(campaignLayer) -- 383
		campaignSub.visible = true -- 384
	end -- 384
	campaignLayer.visible = mode == 2 -- 386
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 388
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 389
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 390
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 391
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 392
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 393
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 394
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 395
	do -- 395
		local i = 0 -- 397
		while i < POOL_BODY do -- 397
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 398
			if lb ~= nil then -- 398
				poolBody[#poolBody + 1] = lb -- 400
			end -- 400
			i = i + 1 -- 397
		end -- 397
	end -- 397
	do -- 397
		local i = 0 -- 403
		while i < POOL_SMALL do -- 403
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 404
			if lb ~= nil then -- 404
				poolSmall[#poolSmall + 1] = lb -- 406
			end -- 406
			i = i + 1 -- 403
		end -- 403
	end -- 403
	if mode == 1 then -- 403
		local loaded = loadSave() -- 413
		profile = loaded.state -- 414
		profileStatus = loaded.status -- 415
		profileDetail = loaded.detail -- 416
	end -- 416
	fe = __TS__New(WatchFrontend, parent) -- 418
	fe.screen = startScreen -- 419
	if startScreen == "splash" then -- 419
		fe.menus:resetSplash() -- 421
	end -- 421
	refreshTitleSessionFlag() -- 423
	grayboxLayer.visible = mode == 0 -- 424
	fe:setVisible(mode == 1) -- 425
	if campaignLayer ~= nil then -- 425
		campaignLayer.visible = mode == 2 -- 427
	end -- 427
	input = __TS__New(Input) -- 430
	touchRouter = __TS__New(TouchRouter, input.settings) -- 431
	touchRouter:attach(parent) -- 432
	input:bindTouch(touchRouter) -- 433
	gamepadRouter = __TS__New(GamepadRouter, input.settings) -- 435
	gamepadRouter:attach(parent) -- 436
	input:bindGamepad(gamepadRouter) -- 437
	touchControls = __TS__New(TouchControls, parent) -- 439
	parent:gslot( -- 442
		"AppEvent", -- 442
		function(eventType) -- 442
			if eventType == "BackButton" then -- 442
				handleBackButton() -- 444
				return -- 445
			end -- 445
			if eventType == "Quit" or eventType == "Shutdown" then -- 445
				flushProfile() -- 448
				saveCurrentSession() -- 449
				if input ~= nil then -- 449
					input:clearTransient(false) -- 450
				end -- 450
				return -- 451
			end -- 451
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 451
				flushProfile() -- 454
				saveCurrentSession() -- 455
				if input ~= nil then -- 455
					input:clearTransient(true) -- 456
				end -- 456
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 456
					play.paused = true -- 458
					play.aimHold = 0 -- 459
					play.bottleAimX = -1 -- 460
					fe.menus:openPause() -- 461
				end -- 461
				if fe ~= nil then -- 461
					fe.audio:setPaused(true) -- 464
				end -- 464
				return -- 466
			end -- 466
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 466
				if fe ~= nil then -- 466
					local paused = mode == 1 and fe.screen == "play" and play ~= nil and play.paused -- 470
					fe.audio:setPaused(paused) -- 471
				end -- 471
			end -- 471
		end -- 442
	) -- 442
	parent:onKeyDown(function(key) -- 477
		onFirstUserGesture() -- 478
		if input ~= nil then -- 478
			input:markKeyboardActivity() -- 479
		end -- 479
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 479
			toggleFullscreen() -- 482
			return -- 483
		end -- 483
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 483
			play:toggleArtifactWeapon() -- 486
			return -- 487
		end -- 487
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 then -- 487
			if key == "1" then -- 487
				play:chooseTalent(0) -- 492
				return -- 493
			end -- 493
			if key == "2" then -- 493
				play:chooseTalent(1) -- 496
				return -- 497
			end -- 497
			if key == "3" then -- 497
				play:chooseTalent(2) -- 500
				return -- 501
			end -- 501
		end -- 501
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or play ~= nil and play.paused) then -- 501
			fe.menus:onKeyEvent(key) -- 505
		end -- 505
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" or mode == 2) then -- 505
			if key == "E" then -- 505
				input.interact.pressed = true -- 509
			elseif key == "Space" then -- 509
				input.jump.pressed = true -- 511
			elseif key == "Escape" then -- 511
				input.pause.pressed = true -- 513
			elseif key == "R" then -- 513
				input.retry.pressed = true -- 515
			end -- 515
		end -- 515
		if mode == 2 and (run and run.trial) ~= nil then -- 515
			return -- 518
		end -- 518
		if isReleaseBuild() then -- 518
			return -- 519
		end -- 519
		if key == "F1" then -- 519
			if mode == 2 then -- 519
				current = 0 -- 522
				play = nil -- 523
				ensurePlay() -- 524
			else -- 524
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 526
			end -- 526
		elseif key == "F2" then -- 526
			setMode(0) -- 529
		elseif key == "1" then -- 529
			pickByIndex(0) -- 531
		elseif key == "2" then -- 531
			pickByIndex(1) -- 533
		elseif key == "3" then -- 533
			pickByIndex(2) -- 535
		elseif key == "4" then -- 535
			pickByIndex(3) -- 537
		elseif key == "5" then -- 537
			pickByIndex(4) -- 539
		elseif key == "6" then -- 539
			pickByIndex(5) -- 541
		elseif key == "7" then -- 541
			pickByIndex(6) -- 543
		elseif key == "8" then -- 543
			pickByIndex(7) -- 545
		end -- 545
	end) -- 477
	viewW = View.size.width -- 549
	viewH = View.size.height -- 550
	applySize() -- 551
	local reg = _G.package.loaded -- 554
	reg["watch.input"] = input -- 555
	reg["watch.touch"] = touchRouter -- 556
	reg["watch.gamepad"] = gamepadRouter -- 557
	reg["watch.fe"] = { -- 558
		setScreen = function(sc) -- 559
			if fe == nil then -- 559
				return -- 561
			end -- 561
			setMode(1) -- 563
			fe.screen = sc -- 564
			if sc == "splash" then -- 564
				fe.menus:resetSplash() -- 566
			elseif sc == "chapters" then -- 566
				fe.menus:openChapters() -- 568
			else -- 568
				fe.menus:resetInput() -- 570
			end -- 570
			if sc == "play" then -- 570
				ensurePlay() -- 573
			end -- 573
		end, -- 559
		jumpRoom = function(keyOrIdx) -- 576
			local idx = -1 -- 577
			if type(keyOrIdx) == "number" then -- 577
				idx = keyOrIdx -- 579
			else -- 579
				local k = 0 -- 581
				do -- 581
					k = 0 -- 582
					while k < #ROOMS do -- 582
						if ROOMS[k + 1].key == keyOrIdx then -- 582
							idx = k -- 584
						end -- 584
						k = k + 1 -- 582
					end -- 582
				end -- 582
			end -- 582
			if idx >= 0 and idx < #ROOMS then -- 582
				enterPlayRoom(idx, "debug") -- 589
			end -- 589
		end, -- 576
		getPlay = function() return play end, -- 592
		getFrontend = function() return fe end, -- 593
		startStory = function() -- 595
			enterPlayRoom( -- 596
				officialStartIndex(), -- 596
				"official", -- 596
				true -- 596
			) -- 596
			return play -- 597
		end, -- 595
		previewChapter = function(idx) -- 600
			enterPlayRoom(idx, "chapter") -- 601
			return play -- 602
		end, -- 600
		getStoryRun = function() return storyRun end, -- 604
		getProfilePending = function() return profilePending() end, -- 605
		flushProfileNow = function() return flushProfile() end, -- 606
		getProfile = function() return profile end, -- 608
		getProfileStatus = function() return profileStatus end, -- 609
		getProfileDetail = function() return profileDetail end, -- 610
		useTestSave = function(name) -- 611
			setSaveFile(name) -- 612
			setSessionFile(name == "" and "" or name .. ".session") -- 613
			clearProfilePending() -- 614
			local loaded = loadSave() -- 615
			profile = loaded.state -- 616
			profileStatus = loaded.status -- 617
			profileDetail = loaded.detail -- 618
			refreshTitleSessionFlag() -- 619
		end, -- 611
		useTestSession = function(name) -- 621
			setSessionFile(name) -- 622
			refreshTitleSessionFlag() -- 623
		end, -- 621
		getSessionFile = getSessionFile, -- 625
		hasSessionSave = hasSessionSave, -- 626
		saveSessionNow = function() return saveCurrentSession() end, -- 627
		clearSessionNow = function() -- 628
			local ok = clearSession() -- 629
			refreshTitleSessionFlag() -- 630
			return ok -- 631
		end, -- 628
		continueStory = function() return continueOfficialStory() end, -- 633
		saveNow = function() return saveSave(profile) end, -- 634
		getSaveFile = getSaveFile, -- 635
		isRelease = function() return isReleaseBuild() end, -- 636
		getReleaseVersion = function() -- 637
			local ____opt_19 = getReleaseConfig() -- 637
			return ____opt_19 and ____opt_19.version or "dev" -- 637
		end, -- 637
		toggleFullscreen = function() return toggleFullscreen() end, -- 638
		quitGame = function() return quitGame() end, -- 639
		startTrial = function() return startTrial() end, -- 640
		handleBackButton = function() return handleBackButton() end, -- 641
		getViewport = function() return stageVp end, -- 642
		getTouchController = function() return touchControls end, -- 643
		getTouchRouter = function() return touchRouter end, -- 644
		getGamepad = function() return gamepadRouter end, -- 645
		setGamepadSim = function(state) -- 646
			if gamepadRouter ~= nil then -- 646
				gamepadRouter:setSimulatedState(state) -- 647
			end -- 647
		end, -- 646
		injectTouch = function(phase, id, x, y, fromMouse) -- 649
			if touchRouter ~= nil then -- 649
				touchRouter:injectTouch( -- 650
					phase, -- 650
					id, -- 650
					x, -- 650
					y, -- 650
					fromMouse -- 650
				) -- 650
			end -- 650
		end, -- 649
		getInputMode = function() return input and input.inputMode or "kbm" end, -- 652
		setInputMode = function(m) -- 653
			if input ~= nil then -- 653
				input:setInputMode(m) -- 654
			end -- 654
		end, -- 653
		setModePref = function(pref) -- 656
			if input ~= nil then -- 656
				input:setModePref(pref) -- 657
			end -- 657
		end, -- 656
		applyViewportForTest = function(w, h) -- 659
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 659
				testViewportOverride = {w = w, h = h} -- 661
				viewW = w -- 662
				viewH = h -- 663
			else -- 663
				testViewportOverride = nil -- 665
				viewW = View.size.width -- 666
				viewH = View.size.height -- 667
			end -- 667
			applySize() -- 669
			dirty = true -- 670
			return stageVp -- 671
		end, -- 659
		getToast = function() return fe and fe:getToastText() or "" end -- 673
	} -- 673
	if mode == 1 and startScreen == "play" then -- 673
		ensurePlay() -- 677
	end -- 677
	parent:schedule(function(frameDt) -- 680
		tick(frameDt) -- 681
		return false -- 682
	end) -- 680
end -- 354
return ____exports -- 354