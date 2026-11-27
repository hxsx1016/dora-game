-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, setMode, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, renderCampaign, drawCampaignHud, tickFrontend, root, campaignLayer, campaignHud, campaignSub, run, storyRun, profile, current, viewW, viewH, dirty, mode, input, touchRouter, gamepadRouter, touchControls, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock, trialTalentSelected -- 1
local ____Dora = require("Dora") -- 8
local App = ____Dora.App -- 8
local Color = ____Dora.Color -- 8
local Keyboard = ____Dora.Keyboard -- 8
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
local ____depth = require("Script.watch.depth") -- 11
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 11
local ____play = require("Script.watch.play") -- 12
local Play = ____play.Play -- 12
local ____clock = require("Script.watch.clock") -- 13
local STEP = ____clock.STEP -- 13
local StepClock = ____clock.StepClock -- 13
local ____aim_assist = require("Script.watch.aim_assist") -- 14
local collectPlayAimTargets = ____aim_assist.collectPlayAimTargets -- 14
local collectTrialAimTargets = ____aim_assist.collectTrialAimTargets -- 14
local ____gamepad = require("Script.watch.gamepad") -- 16
local GamepadRouter = ____gamepad.GamepadRouter -- 16
local ____platform = require("Script.watch.platform") -- 17
local canQuitApp = ____platform.canQuitApp -- 19
local canToggleFullscreen = ____platform.canToggleFullscreen -- 20
local computeStageViewport = ____platform.computeStageViewport -- 21
local getReleaseConfig = ____platform.getReleaseConfig -- 22
local isReleaseMode = ____platform.isReleaseMode -- 23
local ____touch = require("Script.watch.touch") -- 25
local TouchRouter = ____touch.TouchRouter -- 25
local ____frontend = require("Script.watch.fe.frontend") -- 26
local WatchFrontend = ____frontend.WatchFrontend -- 26
local ____run = require("Script.watch.run") -- 27
local createRun = ____run.createRun -- 27
local createStoryTalents = ____run.createStoryTalents -- 27
local createTrial = ____run.createTrial -- 27
local mmss = ____run.mmss -- 27
local talentNames = ____run.talentNames -- 27
local ____save = require("Script.watch.save") -- 28
local emptySave = ____save.emptySave -- 28
local loadSave = ____save.loadSave -- 28
local saveSave = ____save.saveSave -- 28
local setSaveFile = ____save.setSaveFile -- 28
local getSaveFile = ____save.getSaveFile -- 28
local markProfilePending = ____save.markProfilePending -- 29
local flushSaveProfile = ____save.flushProfile -- 29
local clearProfilePending = ____save.clearProfilePending -- 29
local profilePending = ____save.profilePending -- 29
local loadSession = ____save.loadSession -- 30
local saveSession = ____save.saveSession -- 30
local clearSession = ____save.clearSession -- 30
local hasSessionSave = ____save.hasSessionSave -- 30
local setSessionFile = ____save.setSessionFile -- 30
local getSessionFile = ____save.getSessionFile -- 30
local ____touch_controls = require("Script.watch.fe.ui.touch_controls") -- 32
local TouchControls = ____touch_controls.TouchControls -- 32
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 33
local isCutsceneBlockingPlay = ____control_prompts.isCutsceneBlockingPlay -- 33
function onFirstUserGesture() -- 78
	if audioUnlocked or fe == nil then -- 78
		return -- 80
	end -- 80
	audioUnlocked = true -- 82
	fe.audio:unlockAndResyncAfterGesture() -- 83
end -- 83
function toggleFullscreen() -- 86
	if not canToggleFullscreen() then -- 86
		return false -- 88
	end -- 88
	do -- 88
		local function ____catch() -- 88
			return true, false -- 95
		end -- 95
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 95
			local next = not App.fullScreen -- 91
			App.fullScreen = next -- 92
			return true, next -- 93
		end) -- 93
		if not ____try then -- 93
			____hasReturned, ____returnValue = ____catch() -- 93
		end -- 93
		if ____hasReturned then -- 93
			return ____returnValue -- 90
		end -- 90
	end -- 90
end -- 90
function quitGame() -- 99
	flushProfile() -- 100
	saveCurrentSession() -- 101
	if input ~= nil then -- 101
		input:clearTransient(false) -- 102
	end -- 102
	if fe ~= nil then -- 102
		fe.audio:stopRoomTransient() -- 104
	end -- 104
	if not canQuitApp() then -- 104
		current = 0 -- 108
		play = nil -- 109
		run = nil -- 110
		setMode(1) -- 111
		if fe ~= nil then -- 111
			fe.audio:stopRoomTransient() -- 113
			fe.screen = "title" -- 114
			fe.menus:resetInput() -- 115
		end -- 115
		return -- 117
	end -- 117
	App:shutdown() -- 119
end -- 119
function canSaveSession() -- 187
	if mode ~= 1 or play == nil or storyRun == nil then -- 187
		return false -- 189
	end -- 189
	if storyRun.source ~= "official" or play.run.finished then -- 189
		return false -- 192
	end -- 192
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 192
		return false -- 195
	end -- 195
	return true -- 197
end -- 197
function refreshTitleSessionFlag() -- 200
	if fe ~= nil then -- 200
		fe.menus.hasSession = hasSessionSave() -- 202
	end -- 202
end -- 202
function saveCurrentSession() -- 206
	if not canSaveSession() or play == nil then -- 206
		return false -- 208
	end -- 208
	play.sessionDirty = false -- 210
	local ok = saveSession(play:exportSession()) -- 211
	refreshTitleSessionFlag() -- 212
	return ok -- 213
end -- 213
function continueOfficialStory() -- 216
	local res = loadSession() -- 217
	if res.status ~= "ok" or res.state == nil then -- 217
		refreshTitleSessionFlag() -- 219
		return nil -- 220
	end -- 220
	local s = res.state -- 222
	local idx = roomIndexByKey(s.roomKey) -- 223
	if ROOMS[idx + 1].key ~= s.roomKey then -- 223
		return nil -- 225
	end -- 225
	storyRun = createRun(s.seed, "official", profile) -- 227
	storyRun.checkpoint = s.checkpoint -- 228
	storyRun.story.route = s.route -- 229
	storyRun.story.hp = s.hp -- 230
	storyRun.story.maxHp = s.maxHp -- 231
	storyRun.story.hpAtGate = s.hpAtGate -- 232
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 233
	storyRun.story.settled = s.settled -- 234
	storyRun.story.phase = s.phase -- 235
	storyRun.story.countTick = s.countTick -- 236
	storyRun.story.phaseTick = s.phaseTick -- 237
	storyRun.story.handTicks = s.handTicks -- 238
	storyRun.story.handDone = s.handDone -- 239
	storyRun.story.lineSaid = s.lineSaid -- 240
	storyRun.story.tied = s.tied -- 241
	storyRun.story.carry = s.carry -- 242
	storyRun.story.escortDone = s.escortDone -- 243
	storyRun.story.craftedWeapon = s.craftedWeapon -- 244
	storyRun.story.equippedWeapon = s.equippedWeapon -- 245
	storyRun.inventory.wood = s.wood -- 246
	storyRun.inventory.bell = s.bell -- 247
	storyRun.inventory.scrap = s.scrap -- 248
	storyRun.inventory.wedge = s.wedge -- 249
	storyRun.inventory.ammo = s.ammo -- 250
	storyRun.inventory.shield = s.shield -- 251
	storyRun.inventory.pass = s.pass -- 252
	storyRun.inventory.quickbelt = s.quickbelt -- 253
	local k = 0 -- 254
	do -- 254
		k = 0 -- 255
		while k < #s.taken do -- 255
			storyRun.taken[s.taken[k + 1]] = true -- 256
			k = k + 1 -- 255
		end -- 255
	end -- 255
	do -- 255
		k = 0 -- 258
		while k < #s.segments do -- 258
			storyRun.story.segments[s.segments[k + 1]] = true -- 259
			k = k + 1 -- 258
		end -- 258
	end -- 258
	if s.campaignRoute ~= nil then -- 258
		storyRun.route = s.campaignRoute -- 262
	end -- 262
	if s.joined ~= nil then -- 262
		storyRun.joined = s.joined -- 265
	end -- 265
	if s.c1Latch ~= nil then -- 265
		storyRun.c1Latch = s.c1Latch -- 268
	end -- 268
	if s.c2Latch ~= nil then -- 268
		storyRun.c2Latch = s.c2Latch -- 271
	end -- 271
	if s.props ~= nil then -- 271
		do -- 271
			k = 0 -- 274
			while k < #s.props do -- 274
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 275
				local pid = parts[1] -- 276
				if pid ~= nil and pid ~= "" then -- 276
					local ____storyRun_props_16 = storyRun.props -- 278
					local ____temp_12 -- 279
					if parts[2] == nil then -- 279
						____temp_12 = true -- 279
					else -- 279
						____temp_12 = parts[2] == "1" -- 279
					end -- 279
					local ____temp_14 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 280
					local ____temp_15 = parts[4] == "1" -- 281
					local ____temp_13 -- 282
					if parts[5] == "1" then -- 282
						____temp_13 = true -- 282
					else -- 282
						____temp_13 = nil -- 282
					end -- 282
					____storyRun_props_16[pid] = {broken = ____temp_12, hp = ____temp_14, wedge = ____temp_15, revealed = ____temp_13} -- 278
				end -- 278
				k = k + 1 -- 274
			end -- 274
		end -- 274
	end -- 274
	local stTalents = createStoryTalents(s.seed) -- 287
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 287
		stTalents.randomState = s.talentSeed -- 289
	end -- 289
	stTalents.room = s.talentRoom or "" -- 291
	stTalents.ranks.vitality = s.talentVitality or 0 -- 292
	stTalents.ranks.reload = s.talentReload or 0 -- 293
	stTalents.ranks.guard = s.talentGuard or 0 -- 294
	stTalents.ranks.craft = s.talentCraft or 0 -- 295
	if s.talentOffers ~= nil then -- 295
		do -- 295
			k = 0 -- 297
			while k < #s.talentOffers do -- 297
				local t = s.talentOffers[k + 1] -- 298
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 298
					local ____stTalents_offers_17 = stTalents.offers -- 298
					____stTalents_offers_17[#____stTalents_offers_17 + 1] = t -- 300
				end -- 300
				k = k + 1 -- 297
			end -- 297
		end -- 297
	end -- 297
	storyRun.story.talents = stTalents -- 304
	current = idx -- 305
	setMode(1) -- 306
	if fe ~= nil then -- 306
		fe.screen = "play" -- 308
	end -- 308
	play = nil -- 310
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 311
	local cur = play -- 312
	if cur ~= nil then -- 312
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 312
			cur.cartAxle = s.cartAxle -- 315
			cur.cartDocked = s.cartDocked -- 316
		end -- 316
		if s.playerX ~= nil and s.playerX >= 0 then -- 316
			cur.player.x = math.max( -- 319
				cur.room.minX + 16, -- 319
				math.min(cur.room.maxX - 16, s.playerX) -- 319
			) -- 319
			cur.player.y = math.max(0, s.playerY or 0) -- 320
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 320
				cur.player.depth = math.max( -- 322
					cur.room.depth.min, -- 322
					math.min(cur.room.depth.max, s.playerDepth) -- 322
				) -- 322
			end -- 322
		end -- 322
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 322
			cur.gateTick = s.gateTick -- 326
		end -- 326
		if cur.room.key == "village" then -- 326
			if s.hasBottle == true then -- 326
				cur.hasBottle = true -- 329
			end -- 329
			if s.villagePassed == true then -- 329
				cur.passed = true -- 330
			end -- 330
		end -- 330
	end -- 330
	return play -- 333
end -- 333
function setMode(nextMode) -- 621
	mode = nextMode -- 622
	if fe ~= nil then -- 622
		fe:setVisible(mode == 1) -- 624
	end -- 624
	if campaignLayer ~= nil then -- 624
		campaignLayer.visible = mode == 2 -- 627
	end -- 627
	dirty = true -- 629
	clock:reset() -- 630
end -- 630
function flushProfile() -- 637
	local cur = play -- 638
	if cur ~= nil and cur.archiveDirty then -- 638
		cur.archiveDirty = false -- 640
		markProfilePending(profile) -- 641
	end -- 641
	local ok = flushSaveProfile() -- 643
	if not ok and cur ~= nil then -- 643
		cur.archiveDirty = true -- 645
	end -- 645
	return ok -- 647
end -- 647
function officialStartIndex() -- 651
	local mp = profile.museumPhase -- 652
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 653
	return inMuseum and roomIndexByKey("museum") or 0 -- 654
end -- 654
function roomIndexByKey(key) -- 657
	local i = 0 -- 658
	do -- 658
		i = 0 -- 659
		while i < #ROOMS do -- 659
			if ROOMS[i + 1].key == key then -- 659
				return i -- 661
			end -- 661
			i = i + 1 -- 659
		end -- 659
	end -- 659
	return 0 -- 664
end -- 664
function enterPlayRoom(idx, source, fresh) -- 667
	if source == nil then -- 667
		source = "debug" -- 667
	end -- 667
	if fresh == nil then -- 667
		fresh = false -- 667
	end -- 667
	current = idx -- 668
	setMode(1) -- 669
	if fe ~= nil then -- 669
		fe.screen = "play" -- 671
	end -- 671
	play = nil -- 673
	if fresh or source == "chapter" or storyRun == nil then -- 673
		storyRun = createRun(20261124, source, profile) -- 676
	else -- 676
		storyRun.source = source -- 678
	end -- 678
	ensurePlay() -- 680
	local firstPlay = play -- 682
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 682
		firstPlay.phase = "prologue-wake" -- 684
	end -- 684
	flushProfile() -- 686
end -- 686
function applySize() -- 719
	if root == nil then -- 719
		return -- 721
	end -- 721
	root.size = Size(viewW, viewH) -- 723
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 724
	stageVp = computeStageViewport(viewW, viewH) -- 725
	if input ~= nil then -- 725
		input:setStageViewport(stageVp) -- 727
	end -- 727
	if fe ~= nil then -- 727
		fe:setStagePlacement(stageVp) -- 730
	end -- 730
	if campaignLayer ~= nil then -- 730
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 733
	end -- 733
end -- 733
function syncFrameAdapters(frameDt) -- 737
	if input == nil then -- 737
		return -- 739
	end -- 739
	local p = play -- 741
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 742
	local isTrialMode = mode == 2 and p ~= nil -- 743
	local gameplayActive = isPlayMode or isTrialMode -- 744
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 746
		p, -- 748
		stageVp.stageW, -- 748
		stageVp.stageH, -- 748
		input:isTouchMode() -- 748
	) or ({}) -- 748
	if touchControls ~= nil and touchRouter ~= nil then -- 748
		local isFs = false -- 752
		if canToggleFullscreen() then -- 752
			do -- 752
				local function ____catch() -- 752
					isFs = false -- 757
				end -- 757
				local ____try = pcall(function() -- 757
					isFs = App.fullScreen -- 755
				end) -- 755
				if not ____try then -- 755
					____catch() -- 755
				end -- 755
			end -- 755
		end -- 755
		local ____touchControls_53 = touchControls -- 760
		local ____touchControls_syncContext_54 = touchControls.syncContext -- 760
		local ____stageVp_46 = stageVp -- 761
		local ____mode_47 = mode -- 762
		local ____temp_48 = fe ~= nil and fe.screen or "title" -- 763
		local ____run_49 = run -- 765
		local ____temp_50 = fe ~= nil and fe.cam or nil -- 766
		local ____input_51 = input -- 767
		local ____touchRouter_52 = touchRouter -- 768
		local ____temp_44 -- 769
		if fe ~= nil then -- 769
			____temp_44 = fe.contract:isAssistHintsEnabled() -- 769
		else -- 769
			____temp_44 = false -- 769
		end -- 769
		local ____temp_45 -- 770
		if fe ~= nil then -- 770
			____temp_45 = fe.audio:isAllMuted() -- 770
		else -- 770
			____temp_45 = false -- 770
		end -- 770
		____touchControls_syncContext_54(____touchControls_53, { -- 760
			viewport = ____stageVp_46, -- 761
			mode = ____mode_47, -- 762
			screen = ____temp_48, -- 763
			play = p, -- 764
			run = ____run_49, -- 765
			cam = ____temp_50, -- 766
			input = ____input_51, -- 767
			router = ____touchRouter_52, -- 768
			assistHintsEnabled = ____temp_44, -- 769
			isMuted = ____temp_45, -- 770
			isFullscreen = isFs, -- 771
			storyTalentBoxes = storyTalentBoxes, -- 772
			dt = frameDt -- 773
		}) -- 773
	end -- 773
	if gamepadRouter ~= nil then -- 773
		local trial = run and run.trial -- 778
		local trialEnded = isTrialMode and trial ~= nil and (trial.lost or (run and run.finished) == true) -- 779
		local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 780
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 781
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 784
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 785
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 786
		local ____temp_59 -- 789
		if isPlayMode and p ~= nil then -- 789
			____temp_59 = isCutsceneBlockingPlay(p) -- 789
		else -- 789
			____temp_59 = false -- 789
		end -- 789
		local cutsceneBlocking = ____temp_59 -- 789
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 790
		local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 792
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 793
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 795
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 797
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 800
		local playerScreenX = stageVp.stageW * 0.5 -- 802
		local playerScreenY = stageVp.stageH * 0.38 -- 803
		if p ~= nil then -- 803
			if isPlayMode and fe ~= nil then -- 803
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 806
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 807
			else -- 807
				local vz = p.view.zoom > 0 and p.view.zoom or 1 -- 810
				playerScreenX = stageVp.stageW * 0.5 + (p.player.x + p.player.facing * 8 - p.cam.x) * vz -- 811
				playerScreenY = stageVp.stageH * 0.5 + (p.player.y + p.player.h * 0.72 + p.player.depth * DEPTH_Y_SCALE - p.cam.y) * vz -- 812
			end -- 812
		end -- 812
		local enemyTargets = canShoot and p ~= nil and (isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or collectTrialAimTargets(p, stageVp.stageW, stageVp.stageH)) or ({}) -- 816
		local gpCtx = { -- 822
			stageW = stageVp.stageW, -- 823
			stageH = stageVp.stageH, -- 824
			uiScale = stageVp.uiScale, -- 825
			modal = modal, -- 826
			gameplayActive = gameplayActive, -- 827
			reloadActive = reloadActive, -- 828
			craftActive = craftActive, -- 829
			talentOfferCount = talentOfferCount, -- 830
			childMode = p ~= nil and p.childMode, -- 831
			allowDepth = allowDepth, -- 832
			canShoot = canShoot, -- 833
			canBottleAim = canBottleAim, -- 834
			playerRolling = p ~= nil and p.player.rollT > 0, -- 835
			inLowArch = inLowArch, -- 836
			inTowerEnd = inTowerEnd, -- 837
			playerFacing = p ~= nil and p.player.facing or 1, -- 838
			playerScreenX = playerScreenX, -- 839
			playerScreenY = playerScreenY, -- 840
			enemyTargets = enemyTargets -- 841
		} -- 841
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 843
	end -- 843
end -- 843
function renderTouchOverlay() -- 847
	if touchControls ~= nil and touchRouter ~= nil then -- 847
		touchControls:render(touchRouter) -- 849
	end -- 849
end -- 849
function tick(frameDt) -- 853
	appClock = appClock + math.min( -- 854
		0.05, -- 854
		math.max(0, frameDt) -- 854
	) -- 854
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 855
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 856
	if w ~= viewW or h ~= viewH then -- 856
		viewW = w -- 858
		viewH = h -- 859
		applySize() -- 860
		dirty = true -- 861
	end -- 861
	if input == nil then -- 861
		return -- 864
	end -- 864
	syncFrameAdapters(frameDt) -- 866
	input:update() -- 867
	if input.userInteracted then -- 867
		onFirstUserGesture() -- 870
	end -- 870
	if input.muteTogglePressed and fe ~= nil then -- 870
		input.muteTogglePressed = false -- 873
		fe.audio:toggleAllMuted() -- 874
	end -- 874
	if input.fullscreenTogglePressed then -- 874
		input.fullscreenTogglePressed = false -- 877
		toggleFullscreen() -- 878
	end -- 878
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 878
		input.artifactTogglePressed = false -- 881
		play:toggleArtifactWeapon() -- 882
	end -- 882
	if input.bottleCanceled and play ~= nil then -- 882
		input.bottleCanceled = false -- 885
		play.aimHold = 0 -- 886
		play.bottleAimX = -1 -- 887
	end -- 887
	if mode == 2 and (run and run.trial) ~= nil then -- 887
		tickCampaign(frameDt) -- 891
		renderTouchOverlay() -- 892
		return -- 893
	end -- 893
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 893
		play:chooseTalent(input.pickRoom - 1) -- 899
		input.pickRoom = 0 -- 900
	end -- 900
	input.toggleView.pressed = false -- 904
	input.pickRoom = 0 -- 905
	input.tab.pressed = false -- 906
	if mode == 2 then -- 906
		tickCampaign(frameDt) -- 909
	elseif mode == 1 then -- 909
		tickFrontend(frameDt) -- 911
	end -- 911
	renderTouchOverlay() -- 913
end -- 913
function registerPlay() -- 917
	local reg = _G.package.loaded -- 918
	reg["watch.play"] = play -- 919
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 920
	reg["watch.room"] = rooms[current + 1].key -- 921
end -- 921
function ensurePlay(resume) -- 925
	if mode == 2 then -- 925
		if run == nil then -- 925
			run = createRun() -- 928
		end -- 928
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 930
	else -- 930
		if storyRun == nil then -- 930
			storyRun = createRun(20261124, "debug", profile) -- 935
		end -- 935
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 937
	end -- 937
	registerPlay() -- 939
	clock:reset() -- 940
	if fe ~= nil then -- 940
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 943
		if mode == 2 then -- 943
			fe:resetTrialAudio(play) -- 945
		end -- 945
	end -- 945
end -- 945
function startTrial() -- 950
	current = 0 -- 951
	trialTalentSelected = 0 -- 952
	run = createTrial(App.rand) -- 953
	setMode(2) -- 954
	ensurePlay() -- 955
end -- 955
function tickCampaign(frameDt) -- 958
	if input == nil then -- 958
		return -- 960
	end -- 960
	if play == nil then -- 960
		ensurePlay() -- 963
	end -- 963
	if play == nil then -- 963
		return -- 966
	end -- 966
	local p = play -- 968
	p.aimX = input.mx -- 969
	p.aimY = input.my -- 970
	local zoneTap = input.touchZoneTap -- 972
	input.touchZoneTap = "" -- 973
	local trial = run and run.trial -- 975
	if trial ~= nil then -- 975
		local ended = trial.lost or (run and run.finished) == true -- 977
		local pick = input.pickRoom -- 978
		input.pickRoom = 0 -- 979
		if zoneTap == "trial:resume" and p.paused and not ended then -- 979
			p.paused = false -- 982
			clock:reset() -- 983
			input:consumeEdges() -- 984
			renderCampaign(frameDt, p) -- 985
			return -- 986
		end -- 986
		if zoneTap == "trial:retry" then -- 986
			input:consumeEdges() -- 989
			startTrial() -- 990
			return -- 991
		end -- 991
		if zoneTap == "trial:title" then -- 991
			input:consumeEdges() -- 994
			current = 0 -- 995
			play = nil -- 996
			run = nil -- 997
			setMode(1) -- 998
			if fe ~= nil then -- 998
				fe.audio:stopRoomTransient() -- 1000
				fe.screen = "title" -- 1001
				fe.menus:resetInput() -- 1002
			end -- 1002
			return -- 1004
		end -- 1004
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1004
			input:consumeEdges() -- 1008
			current = 0 -- 1009
			play = nil -- 1010
			run = nil -- 1011
			setMode(1) -- 1012
			if fe ~= nil then -- 1012
				fe.audio:stopRoomTransient() -- 1014
				fe.screen = "title" -- 1015
				fe.menus:resetInput() -- 1016
			end -- 1016
			return -- 1018
		end -- 1018
		if ended or p.paused and input.retry.pressed then -- 1018
			local restart = input.retry.pressed or ended and input.navConfirm -- 1021
			input:consumeEdges() -- 1022
			if restart then -- 1022
				startTrial() -- 1023
			else -- 1023
				renderCampaign(frameDt, p) -- 1024
			end -- 1024
			return -- 1025
		end -- 1025
		input.retry.pressed = false -- 1027
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1027
			if trialTalentSelected >= #trial.offers then -- 1027
				trialTalentSelected = 0 -- 1030
			end -- 1030
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1030
				local idx = __TS__ParseInt( -- 1033
					string.sub(zoneTap, 8), -- 1033
					10 -- 1033
				) -- 1033
				if idx >= 0 and idx < #trial.offers then -- 1033
					p:chooseTalent(idx) -- 1035
				end -- 1035
			elseif pick > 0 then -- 1035
				p:chooseTalent(pick - 1) -- 1038
			else -- 1038
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1040
				if delta ~= 0 then -- 1040
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1044
				end -- 1044
				if input.talentConfirm or input.navConfirm then -- 1044
					p:chooseTalent(trialTalentSelected) -- 1047
				end -- 1047
			end -- 1047
			input:consumeEdges() -- 1050
			clock:reset() -- 1051
			renderCampaign(frameDt, p) -- 1052
			return -- 1053
		end -- 1053
	end -- 1053
	if input.retry.pressed then -- 1053
		input.retry.pressed = false -- 1058
		input:consumeEdges() -- 1059
		play = nil -- 1061
		ensurePlay() -- 1062
		return -- 1063
	end -- 1063
	if input.pause.pressed or p.paused and input.navBack then -- 1063
		input.pause.pressed = false -- 1066
		p.paused = not p.paused -- 1067
		if fe ~= nil then -- 1067
			fe.audio:playUi(p.paused and "ui:pause_open" or "ui:pause_close", p.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 1068
		end -- 1068
		clock:reset() -- 1069
		input:consumeEdges() -- 1070
	end -- 1070
	if p.paused then -- 1070
		renderCampaign(frameDt, p) -- 1073
		return -- 1074
	end -- 1074
	local steps = clock:advance(frameDt) -- 1077
	local i = 0 -- 1078
	do -- 1078
		i = 0 -- 1079
		while i < steps do -- 1079
			input:beginStep(i == 0) -- 1080
			p:update(STEP, input) -- 1081
			input:endStep() -- 1082
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1082
				break -- 1084
			end -- 1084
			i = i + 1 -- 1079
		end -- 1079
	end -- 1079
	if p.wantRoom ~= "" then -- 1079
		local key = p.wantRoom -- 1089
		p.wantRoom = "" -- 1090
		local idx = -1 -- 1091
		local j = 0 -- 1092
		do -- 1092
			j = 0 -- 1093
			while j < #CAMPAIGN_ROOMS do -- 1093
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1093
					idx = j -- 1095
				end -- 1095
				j = j + 1 -- 1093
			end -- 1093
		end -- 1093
		if idx >= 0 then -- 1093
			current = idx -- 1099
			play = nil -- 1100
			ensurePlay() -- 1101
		end -- 1101
		return -- 1103
	end -- 1103
	renderCampaign(frameDt, p) -- 1105
end -- 1105
function goalLabel(goal) -- 1108
	if goal == "dock_cart" then -- 1108
		return "推车入窝并抬闩" -- 1110
	end -- 1110
	if goal == "raise_latch" then -- 1110
		return "抬闩开侧门" -- 1113
	end -- 1113
	return "到段出口" -- 1115
end -- 1115
function renderCampaign(frameDt, p) -- 1119
	if fe ~= nil and input ~= nil then -- 1119
		local ____opt_72 = run and run.trial -- 1119
		local offers = ____opt_72 and #____opt_72.offers or 0 -- 1122
		local ____p_paused_76 -- 1123
		if p.paused then -- 1123
			____p_paused_76 = nil -- 1123
		else -- 1123
			____p_paused_76 = fe.adapter:sample(p) -- 1123
		end -- 1123
		local ev = ____p_paused_76 -- 1123
		fe:renderPlay( -- 1124
			frameDt, -- 1124
			p, -- 1124
			input, -- 1124
			stageVp.stageW, -- 1124
			stageVp.stageH, -- 1124
			true, -- 1124
			ev -- 1124
		) -- 1124
		fe:syncTrialAudio(frameDt, p, offers, ev) -- 1125
	end -- 1125
	drawCampaignHud(p) -- 1127
end -- 1127
function drawCampaignHud(p) -- 1131
	local h = stageVp.stageH -- 1132
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1133
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1134
	local room = CAMPAIGN_ROOMS[current + 1] -- 1135
	local c = room.campaign -- 1136
	local r = run -- 1137
	local trial = r and r.trial -- 1138
	local gpMode = input ~= nil and input:isGamepadMode() -- 1139
	local touchMode = input ~= nil and input:isTouchMode() -- 1140
	local line = room.name -- 1143
	if trial == nil then -- 1143
		if c ~= nil then -- 1143
			line = (((line .. "  · 目标 ") .. goalLabel(c.goal)) .. "  · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0)) -- 1146
		end -- 1146
		if p.paused then -- 1146
			line = line .. "  · 已暂停" -- 1148
		end -- 1148
	else -- 1148
		line = (((((("护送试炼 · " .. room.name) .. "  · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. "  · ") .. mmss(r == nil and 0 or r.ticks) -- 1150
		if p.paused then -- 1150
			line = line .. "  · 暂停" -- 1151
		elseif trial.lost then -- 1151
			line = line .. "  · 护送失败" -- 1152
		elseif r ~= nil and r.finished then -- 1152
			line = line .. "  · 护送完成" -- 1153
		elseif #trial.offers > 0 then -- 1153
			line = line .. "  · 选择本段本领" -- 1154
		elseif c ~= nil then -- 1154
			line = line .. "  · " .. goalLabel(c.goal) -- 1155
		end -- 1155
	end -- 1155
	if campaignHud ~= nil then -- 1155
		campaignHud.text = line -- 1158
		campaignHud.position = Vec2(24 + safeL, h - 14 - safeT) -- 1159
		campaignHud.visible = true -- 1160
	end -- 1160
	if campaignSub == nil then -- 1160
		return -- 1164
	end -- 1164
	local sub = p.flash -- 1166
	if trial ~= nil then -- 1166
		if trial.lost or r ~= nil and r.finished then -- 1166
			sub = gpMode and "A 再开一局 · START 返回标题" or (touchMode and "点下方按钮再开或返回标题" or "R 再开一局 · Esc 返回标题") -- 1169
		elseif p.paused then -- 1169
			sub = gpMode and "START 继续 · 长按 BACK 重开 · Y 返回标题" or (touchMode and "点下方按钮继续 / 重开 / 返回标题" or "Esc 继续 · R 重新开局") -- 1171
		elseif #trial.offers > 0 then -- 1171
			sub = table.concat( -- 1173
				__TS__ArrayMap( -- 1173
					trial.offers, -- 1173
					function(____, talent, index) -- 1173
						local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1174
						return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1175
					end -- 1173
				), -- 1173
				"　" -- 1176
			) -- 1176
		elseif sub == "" and r ~= nil then -- 1176
			sub = r.joined and "小满跟随" or "小满等待" -- 1178
		end -- 1178
	end -- 1178
	campaignSub.text = sub -- 1181
	campaignSub.position = Vec2(24 + safeL, h - 44 - safeT) -- 1182
	campaignSub.visible = sub ~= "" -- 1183
end -- 1183
function tickFrontend(frameDt) -- 1186
	if fe == nil or input == nil then -- 1186
		return -- 1188
	end -- 1188
	if fe.screen ~= "play" then -- 1188
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1193
		input:consumeEdges() -- 1194
		if act.type == "splashDone" then -- 1194
			fe.menus:resetInput() -- 1196
			fe.screen = "title" -- 1197
		elseif act.type == "trial" then -- 1197
			startTrial() -- 1199
		elseif act.type == "continue" then -- 1199
			if continueOfficialStory() == nil then -- 1199
				enterPlayRoom( -- 1202
					officialStartIndex(), -- 1202
					"official", -- 1202
					true -- 1202
				) -- 1202
			end -- 1202
		elseif act.type == "start" then -- 1202
			clearSession() -- 1206
			refreshTitleSessionFlag() -- 1207
			enterPlayRoom( -- 1208
				officialStartIndex(), -- 1208
				"official", -- 1208
				true -- 1208
			) -- 1208
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1208
			enterPlayRoom(act.roomIndex, "chapter") -- 1210
		elseif act.type == "openChapters" then -- 1210
			fe.menus:openChapters() -- 1212
			fe.screen = "chapters" -- 1213
		elseif act.type == "openControls" then -- 1213
			fe.menus:resetInput() -- 1215
			fe.screen = "controls" -- 1216
		elseif act.type == "openHistory" then -- 1216
			fe.menus:openHistory(true) -- 1218
			fe.screen = "history" -- 1219
		elseif act.type == "backEpilogue" then -- 1219
			fe.menus:resetInput() -- 1221
			fe.screen = "epilogue" -- 1222
		elseif act.type == "replayStory" then -- 1222
			clearSession() -- 1224
			refreshTitleSessionFlag() -- 1225
			enterPlayRoom( -- 1226
				officialStartIndex(), -- 1226
				"official", -- 1226
				true -- 1226
			) -- 1226
		elseif act.type == "backTitle" then -- 1226
			fe.menus:resetInput() -- 1228
			fe.screen = "title" -- 1229
		elseif act.type == "backPause" then -- 1229
			fe.menus:resetInput() -- 1231
			fe.screen = "play" -- 1232
		elseif act.type == "quit" then -- 1232
			quitGame() -- 1234
		end -- 1234
		return -- 1236
	end -- 1236
	if play == nil then -- 1236
		ensurePlay() -- 1241
	end -- 1241
	if play == nil then -- 1241
		return -- 1244
	end -- 1244
	local p = play -- 1246
	p.aimX = input.mx -- 1248
	p.aimY = input.my -- 1249
	local zoneTap = input.touchZoneTap -- 1251
	input.touchZoneTap = "" -- 1252
	local offers = p:getStoryTalentOffers() -- 1254
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1254
		if fe.hud.talentSelected >= #offers then -- 1254
			fe.hud.talentSelected = 0 -- 1257
		end -- 1257
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1257
			local idx = __TS__ParseInt( -- 1260
				string.sub(zoneTap, 8), -- 1260
				10 -- 1260
			) -- 1260
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1260
				input.fire.pressed = false -- 1262
			end -- 1262
		else -- 1262
			if input.talentDelta ~= 0 then -- 1262
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1266
				input.talentDelta = 0 -- 1267
			end -- 1267
			if input.talentConfirm then -- 1267
				p:chooseTalent(fe.hud.talentSelected) -- 1270
				input.talentConfirm = false -- 1271
				input.fire.pressed = false -- 1272
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1272
				input.fire.pressed = false -- 1275
			end -- 1275
		end -- 1275
	end -- 1275
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1275
		if input.navConfirm then -- 1275
			input.interact.pressed = true -- 1283
		end -- 1283
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1283
			flushProfile() -- 1286
			if p.run.source == "official" and hasSessionSave() then -- 1286
				clearSession() -- 1288
				refreshTitleSessionFlag() -- 1289
			end -- 1289
			fe.audio:stopRoomTransient() -- 1291
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1292
			fe.screen = "epilogue" -- 1296
			input:clearTransient(true) -- 1297
			input:consumeEdges() -- 1298
			return -- 1299
		end -- 1299
	end -- 1299
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1299
		p:closeCraftBench() -- 1304
		input:consumeEdges() -- 1305
		return -- 1306
	end -- 1306
	if not p.paused and input.pause.pressed then -- 1306
		p.paused = true -- 1309
		p.aimHold = 0 -- 1310
		p.bottleAimX = -1 -- 1311
		saveCurrentSession() -- 1312
		fe.menus:openPause() -- 1313
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1314
		input:clearTransient(true) -- 1315
		input:consumeEdges() -- 1316
	end -- 1316
	if p.paused then -- 1316
		clock:reset() -- 1321
		local pauseAct = fe:renderPlay( -- 1322
			frameDt, -- 1322
			p, -- 1322
			input, -- 1322
			stageVp.stageW, -- 1322
			stageVp.stageH -- 1322
		) -- 1322
		input:consumeEdges() -- 1323
		if pauseAct.type == "resume" then -- 1323
			p.paused = false -- 1325
		elseif pauseAct.type == "retry" then -- 1325
			ensurePlay({checkpoint = p.checkpoint}) -- 1327
		elseif pauseAct.type == "openChapters" then -- 1327
			fe.audio:stopRoomTransient() -- 1329
			fe.audio:setPaused(false) -- 1330
			fe.menus:openChapters(current) -- 1331
			fe.screen = "chapters" -- 1332
		elseif pauseAct.type == "toggleFullscreen" then -- 1332
			toggleFullscreen() -- 1334
		elseif pauseAct.type == "quit" then -- 1334
			quitGame() -- 1336
		elseif pauseAct.type == "toTitle" then -- 1336
			saveCurrentSession() -- 1338
			refreshTitleSessionFlag() -- 1339
			fe.menus:resetInput() -- 1340
			fe.screen = "title" -- 1341
		end -- 1341
		return -- 1343
	end -- 1343
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1346
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1347
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1347
		input:consumeEdges() -- 1350
		ensurePlay({checkpoint = p.checkpoint}) -- 1352
		return -- 1353
	end -- 1353
	local steps = clock:advance(frameDt) -- 1356
	local i = 0 -- 1357
	do -- 1357
		i = 0 -- 1358
		while i < steps do -- 1358
			input:beginStep(i == 0) -- 1359
			p:update(STEP, input) -- 1360
			input:endStep() -- 1361
			if p.wantRoom ~= "" then -- 1361
				break -- 1363
			end -- 1363
			i = i + 1 -- 1358
		end -- 1358
	end -- 1358
	if p.wantRoom ~= "" then -- 1358
		local key = p.wantRoom -- 1369
		p.wantRoom = "" -- 1370
		local idx = -1 -- 1371
		local j = 0 -- 1372
		do -- 1372
			j = 0 -- 1373
			while j < #ROOMS do -- 1373
				if ROOMS[j + 1].key == key then -- 1373
					idx = j -- 1375
				end -- 1375
				j = j + 1 -- 1373
			end -- 1373
		end -- 1373
		if idx >= 0 then -- 1373
			flushProfile() -- 1382
			local leaving = p:drainEvents() -- 1383
			if p.restartStory then -- 1383
				if storyRun ~= nil and storyRun.source == "official" then -- 1383
					clearSession() -- 1387
					refreshTitleSessionFlag() -- 1388
				end -- 1388
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1390
				storyRun = createRun(20261124, nextSource, profile) -- 1391
			end -- 1391
			current = idx -- 1393
			ensurePlay() -- 1394
			local fresh = play -- 1395
			if fresh ~= nil then -- 1395
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1395
					fresh.phase = "prologue-wake" -- 1398
				end -- 1398
				fresh:adoptEvents(leaving) -- 1400
			end -- 1400
			if not p.restartStory then -- 1400
				saveCurrentSession() -- 1403
			end -- 1403
			clock:reset() -- 1405
			dirty = true -- 1406
		end -- 1406
		return -- 1408
	end -- 1408
	flushProfile() -- 1412
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1412
		clearSession() -- 1414
		refreshTitleSessionFlag() -- 1415
	elseif p.sessionDirty then -- 1415
		saveCurrentSession() -- 1417
	end -- 1417
	fe:renderPlay( -- 1419
		frameDt, -- 1419
		p, -- 1419
		input, -- 1419
		stageVp.stageW, -- 1419
		stageVp.stageH -- 1419
	) -- 1419
end -- 1419
local FONT = "sarasa-mono-sc-regular" -- 37
local C_TEXT = Color(236, 236, 232, 255) -- 39
local C_ACCENT = Color(226, 186, 84, 255) -- 40
profile = emptySave() -- 50
local profileStatus = "missing" -- 51
local profileDetail = "" -- 52
current = 0 -- 54
viewW = 0 -- 55
viewH = 0 -- 56
dirty = true -- 57
mode = 1 -- 59
clock = __TS__New(StepClock) -- 66
stageVp = computeStageViewport(1280, 720) -- 67
audioUnlocked = false -- 69
appClock = 0 -- 70
local lastBackPressClock = -10 -- 71
trialTalentSelected = 0 -- 72
local function isReleaseBuild() -- 74
	return isReleaseMode() -- 75
end -- 74
local function handleBackButton() -- 122
	if mode == 2 and play ~= nil then -- 122
		local trial = run and run.trial -- 124
		if trial ~= nil and (trial.lost or (run and run.finished) == true) then -- 124
			current = 0 -- 126
			play = nil -- 127
			run = nil -- 128
			setMode(1) -- 129
			if fe ~= nil then -- 129
				fe.audio:stopRoomTransient() -- 131
				fe.screen = "title" -- 132
				fe.menus:resetInput() -- 133
			end -- 133
			return -- 135
		end -- 135
		play.paused = not play.paused -- 137
		if fe ~= nil then -- 137
			fe.audio:playUi(play.paused and "ui:pause_open" or "ui:pause_close", play.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 138
		end -- 138
		clock:reset() -- 139
		if input ~= nil then -- 139
			input:clearTransient(true) -- 140
		end -- 140
		return -- 141
	end -- 141
	if fe == nil then -- 141
		return -- 144
	end -- 144
	if fe.screen == "splash" then -- 144
		fe.menus:resetSplash() -- 147
		fe.screen = "title" -- 148
		fe.menus:resetInput() -- 149
		return -- 150
	end -- 150
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "epilogue" or fe.screen == "history" then -- 150
		fe.menus:triggerBack() -- 153
		return -- 154
	end -- 154
	if fe.screen == "title" then -- 154
		if not canQuitApp() then -- 154
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 158
			return -- 159
		end -- 159
		if appClock - lastBackPressClock <= 2 then -- 159
			quitGame() -- 162
		else -- 162
			lastBackPressClock = appClock -- 164
			fe:showToast("再按一次返回退出游戏", 2) -- 165
		end -- 165
		return -- 167
	end -- 167
	if fe.screen == "play" and play ~= nil then -- 167
		if play.paused then -- 167
			fe.menus:triggerBack() -- 171
			return -- 172
		end -- 172
		if play.craftBench.active then -- 172
			play:closeCraftBench() -- 175
			return -- 176
		end -- 176
		play.paused = true -- 178
		play.aimHold = 0 -- 179
		play.bottleAimX = -1 -- 180
		saveCurrentSession() -- 181
		fe.menus:openPause() -- 182
		if input ~= nil then -- 182
			input:clearTransient(true) -- 183
		end -- 183
	end -- 183
end -- 122
function ____exports.start(parent, initialMode, startScreen) -- 336
	if initialMode == nil then -- 336
		initialMode = 1 -- 336
	end -- 336
	if startScreen == nil then -- 336
		startScreen = "title" -- 336
	end -- 336
	root = parent -- 337
	mode = initialMode -- 338
	campaignLayer = Node() -- 341
	campaignLayer.order = 3 -- 342
	campaignLayer:addTo(parent) -- 343
	campaignHud = Label(FONT, 24) -- 344
	if campaignHud ~= nil then -- 344
		campaignHud.color = C_TEXT -- 346
		campaignHud.anchor = Vec2(0, 1) -- 347
		campaignHud:addTo(campaignLayer) -- 348
		campaignHud.visible = true -- 349
	end -- 349
	campaignSub = Label(FONT, 20) -- 351
	if campaignSub ~= nil then -- 351
		campaignSub.color = C_ACCENT -- 353
		campaignSub.anchor = Vec2(0, 1) -- 354
		campaignSub:addTo(campaignLayer) -- 355
		campaignSub.visible = true -- 356
	end -- 356
	campaignLayer.visible = mode == 2 -- 358
	if mode == 1 then -- 358
		local loaded = loadSave() -- 363
		profile = loaded.state -- 364
		profileStatus = loaded.status -- 365
		profileDetail = loaded.detail -- 366
	end -- 366
	fe = __TS__New(WatchFrontend, parent) -- 368
	fe.screen = startScreen -- 369
	if startScreen == "splash" then -- 369
		fe.menus:resetSplash() -- 371
	end -- 371
	refreshTitleSessionFlag() -- 373
	fe:setVisible(mode == 1) -- 374
	if campaignLayer ~= nil then -- 374
		campaignLayer.visible = mode == 2 -- 376
	end -- 376
	input = __TS__New(Input) -- 379
	fe.audio:applyUserVolumes(input.settings) -- 380
	touchRouter = __TS__New(TouchRouter, input.settings) -- 381
	touchRouter:attach(parent) -- 382
	input:bindTouch(touchRouter) -- 383
	gamepadRouter = __TS__New(GamepadRouter, input.settings) -- 385
	gamepadRouter:attach(parent) -- 386
	input:bindGamepad(gamepadRouter) -- 387
	touchControls = __TS__New(TouchControls, parent) -- 389
	parent:gslot( -- 392
		"AppEvent", -- 392
		function(eventType) -- 392
			if eventType == "BackButton" then -- 392
				handleBackButton() -- 394
				return -- 395
			end -- 395
			if eventType == "Quit" or eventType == "Shutdown" then -- 395
				flushProfile() -- 398
				saveCurrentSession() -- 399
				if input ~= nil then -- 399
					input:clearTransient(false) -- 400
				end -- 400
				return -- 401
			end -- 401
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 401
				flushProfile() -- 404
				saveCurrentSession() -- 405
				if input ~= nil then -- 405
					input:clearTransient(true) -- 406
				end -- 406
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 406
					play.paused = true -- 408
					play.aimHold = 0 -- 409
					play.bottleAimX = -1 -- 410
					fe.menus:openPause() -- 411
				elseif mode == 2 and play ~= nil and not play.paused then -- 411
					play.paused = true -- 413
				end -- 413
				if fe ~= nil then -- 413
					fe.audio:setPaused(true) -- 416
				end -- 416
				return -- 418
			end -- 418
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 418
				if fe ~= nil then -- 418
					local paused = play ~= nil and play.paused and (mode == 1 and fe.screen == "play" or mode == 2) -- 422
					fe.audio:setPaused(paused) -- 424
				end -- 424
			end -- 424
		end -- 392
	) -- 392
	parent:onKeyDown(function(key) -- 430
		onFirstUserGesture() -- 431
		if input ~= nil then -- 431
			input:markKeyboardActivity() -- 432
		end -- 432
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 432
			toggleFullscreen() -- 435
			return -- 436
		end -- 436
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 436
			play:toggleArtifactWeapon() -- 439
			return -- 440
		end -- 440
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and #play:getStoryTalentOffers() > 0 then -- 440
			if key == "1" then -- 440
				play:chooseTalent(0) -- 445
				if input ~= nil then -- 445
					input:consumePickRoom() -- 446
				end -- 446
				return -- 447
			end -- 447
			if key == "2" then -- 447
				play:chooseTalent(1) -- 450
				if input ~= nil then -- 450
					input:consumePickRoom() -- 451
				end -- 451
				return -- 452
			end -- 452
			if key == "3" then -- 452
				play:chooseTalent(2) -- 455
				if input ~= nil then -- 455
					input:consumePickRoom() -- 456
				end -- 456
				return -- 457
			end -- 457
		end -- 457
		local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 460
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 460
			fe.menus:onKeyEvent(key) -- 462
		end -- 462
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay or mode == 2) then -- 462
			if key == "E" then -- 462
				input.interact.pressed = true -- 466
			elseif key == "Space" then -- 466
				input.jump.pressed = true -- 468
			elseif key == "Escape" then -- 468
				input.pause.pressed = true -- 470
			elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 470
				input.retry.pressed = true -- 472
			end -- 472
		end -- 472
	end) -- 430
	viewW = View.size.width -- 477
	viewH = View.size.height -- 478
	applySize() -- 479
	local reg = _G.package.loaded -- 482
	reg["watch.input"] = input -- 483
	reg["watch.touch"] = touchRouter -- 484
	reg["watch.gamepad"] = gamepadRouter -- 485
	reg["watch.fe"] = { -- 486
		setScreen = function(sc) -- 487
			if fe == nil then -- 487
				return -- 489
			end -- 489
			setMode(1) -- 491
			fe.screen = sc -- 492
			if sc == "splash" then -- 492
				fe.menus:resetSplash() -- 494
			elseif sc == "chapters" then -- 494
				fe.menus:openChapters() -- 496
			elseif sc == "epilogue" then -- 496
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 498
			elseif sc == "history" then -- 498
				fe.menus:openHistory(false) -- 503
			else -- 503
				fe.menus:resetInput() -- 505
			end -- 505
			if sc == "play" then -- 505
				ensurePlay() -- 508
			end -- 508
		end, -- 487
		jumpRoom = function(keyOrIdx) -- 511
			local idx = -1 -- 512
			if type(keyOrIdx) == "number" then -- 512
				idx = keyOrIdx -- 514
			else -- 514
				local k = 0 -- 516
				do -- 516
					k = 0 -- 517
					while k < #ROOMS do -- 517
						if ROOMS[k + 1].key == keyOrIdx then -- 517
							idx = k -- 519
						end -- 519
						k = k + 1 -- 517
					end -- 517
				end -- 517
			end -- 517
			if idx >= 0 and idx < #ROOMS then -- 517
				enterPlayRoom(idx, "debug") -- 524
			end -- 524
		end, -- 511
		getPlay = function() return play end, -- 527
		getFrontend = function() return fe end, -- 528
		startStory = function() -- 530
			enterPlayRoom( -- 531
				officialStartIndex(), -- 531
				"official", -- 531
				true -- 531
			) -- 531
			return play -- 532
		end, -- 530
		previewChapter = function(idx) -- 535
			enterPlayRoom(idx, "chapter") -- 536
			return play -- 537
		end, -- 535
		getStoryRun = function() return storyRun end, -- 539
		getProfilePending = function() return profilePending() end, -- 540
		flushProfileNow = function() return flushProfile() end, -- 541
		getProfile = function() return profile end, -- 543
		getProfileStatus = function() return profileStatus end, -- 544
		getProfileDetail = function() return profileDetail end, -- 545
		useTestSave = function(name) -- 546
			setSaveFile(name) -- 547
			setSessionFile(name == "" and "" or name .. ".session") -- 548
			clearProfilePending() -- 549
			local loaded = loadSave() -- 550
			profile = loaded.state -- 551
			profileStatus = loaded.status -- 552
			profileDetail = loaded.detail -- 553
			refreshTitleSessionFlag() -- 554
		end, -- 546
		useTestSession = function(name) -- 556
			setSessionFile(name) -- 557
			refreshTitleSessionFlag() -- 558
		end, -- 556
		getSessionFile = getSessionFile, -- 560
		hasSessionSave = hasSessionSave, -- 561
		saveSessionNow = function() return saveCurrentSession() end, -- 562
		clearSessionNow = function() -- 563
			local ok = clearSession() -- 564
			refreshTitleSessionFlag() -- 565
			return ok -- 566
		end, -- 563
		continueStory = function() return continueOfficialStory() end, -- 568
		saveNow = function() return saveSave(profile) end, -- 569
		getSaveFile = getSaveFile, -- 570
		isRelease = function() return isReleaseBuild() end, -- 571
		getReleaseVersion = function() -- 572
			local ____opt_30 = getReleaseConfig() -- 572
			return ____opt_30 and ____opt_30.version or "dev" -- 572
		end, -- 572
		toggleFullscreen = function() return toggleFullscreen() end, -- 573
		quitGame = function() return quitGame() end, -- 574
		startTrial = function() return startTrial() end, -- 575
		handleBackButton = function() return handleBackButton() end, -- 576
		getViewport = function() return stageVp end, -- 577
		getTouchController = function() return touchControls end, -- 578
		getTouchRouter = function() return touchRouter end, -- 579
		getGamepad = function() return gamepadRouter end, -- 580
		setGamepadSim = function(state) -- 581
			if gamepadRouter ~= nil then -- 581
				gamepadRouter:setSimulatedState(state) -- 582
			end -- 582
		end, -- 581
		injectTouch = function(phase, id, x, y, fromMouse) -- 584
			if touchRouter ~= nil then -- 584
				touchRouter:injectTouch( -- 585
					phase, -- 585
					id, -- 585
					x, -- 585
					y, -- 585
					fromMouse -- 585
				) -- 585
			end -- 585
		end, -- 584
		getInputMode = function() return input and input.inputMode or "kbm" end, -- 587
		setInputMode = function(m) -- 588
			if input ~= nil then -- 588
				input:setInputMode(m) -- 589
			end -- 589
		end, -- 588
		setModePref = function(pref) -- 591
			if input ~= nil then -- 591
				input:setModePref(pref) -- 592
			end -- 592
		end, -- 591
		applyViewportForTest = function(w, h) -- 594
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 594
				testViewportOverride = {w = w, h = h} -- 596
				viewW = w -- 597
				viewH = h -- 598
			else -- 598
				testViewportOverride = nil -- 600
				viewW = View.size.width -- 601
				viewH = View.size.height -- 602
			end -- 602
			applySize() -- 604
			dirty = true -- 605
			return stageVp -- 606
		end, -- 594
		getToast = function() return fe and fe:getToastText() or "" end -- 608
	} -- 608
	if mode == 1 and startScreen == "play" then -- 608
		ensurePlay() -- 612
	end -- 612
	parent:schedule(function(frameDt) -- 615
		tick(frameDt) -- 616
		return false -- 617
	end) -- 615
end -- 336
local function pickByIndex(idx, source) -- 689
	if source == nil then -- 689
		source = "debug" -- 689
	end -- 689
	if mode == 2 then -- 689
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 689
			return -- 692
		end -- 692
		current = idx -- 694
		play = nil -- 695
		clock:reset() -- 696
		ensurePlay() -- 697
		return -- 698
	end -- 698
	if idx < 0 or idx >= #ROOMS then -- 698
		return -- 701
	end -- 701
	flushProfile() -- 703
	if storyRun ~= nil then -- 703
		storyRun.source = source -- 705
	end -- 705
	current = idx -- 707
	dirty = true -- 708
	play = nil -- 709
	clock:reset() -- 710
	if mode == 1 then -- 710
		if fe ~= nil then -- 710
			fe.screen = "play" -- 713
		end -- 713
		ensurePlay() -- 715
	end -- 715
end -- 689
return ____exports -- 689