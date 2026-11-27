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
function setMode(nextMode) -- 627
	mode = nextMode -- 628
	if fe ~= nil then -- 628
		fe:setVisible(mode == 1) -- 630
	end -- 630
	if campaignLayer ~= nil then -- 630
		campaignLayer.visible = mode == 2 -- 633
	end -- 633
	dirty = true -- 635
	clock:reset() -- 636
end -- 636
function flushProfile() -- 643
	local cur = play -- 644
	if cur ~= nil and cur.archiveDirty then -- 644
		cur.archiveDirty = false -- 646
		markProfilePending(profile) -- 647
	end -- 647
	local ok = flushSaveProfile() -- 649
	if not ok and cur ~= nil then -- 649
		cur.archiveDirty = true -- 651
	end -- 651
	return ok -- 653
end -- 653
function officialStartIndex() -- 657
	local mp = profile.museumPhase -- 658
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 659
	return inMuseum and roomIndexByKey("museum") or 0 -- 660
end -- 660
function roomIndexByKey(key) -- 663
	local i = 0 -- 664
	do -- 664
		i = 0 -- 665
		while i < #ROOMS do -- 665
			if ROOMS[i + 1].key == key then -- 665
				return i -- 667
			end -- 667
			i = i + 1 -- 665
		end -- 665
	end -- 665
	return 0 -- 670
end -- 670
function enterPlayRoom(idx, source, fresh) -- 673
	if source == nil then -- 673
		source = "debug" -- 673
	end -- 673
	if fresh == nil then -- 673
		fresh = false -- 673
	end -- 673
	current = idx -- 674
	setMode(1) -- 675
	if fe ~= nil then -- 675
		fe.screen = "play" -- 677
	end -- 677
	play = nil -- 679
	if fresh or source == "chapter" or storyRun == nil then -- 679
		storyRun = createRun(20261124, source, profile) -- 682
	else -- 682
		storyRun.source = source -- 684
	end -- 684
	ensurePlay() -- 686
	local firstPlay = play -- 688
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 688
		firstPlay.phase = "prologue-wake" -- 690
	end -- 690
	flushProfile() -- 692
end -- 692
function applySize() -- 725
	if root == nil then -- 725
		return -- 727
	end -- 727
	root.size = Size(viewW, viewH) -- 729
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 730
	stageVp = computeStageViewport(viewW, viewH) -- 731
	if input ~= nil then -- 731
		input:setStageViewport(stageVp) -- 733
	end -- 733
	if fe ~= nil then -- 733
		fe:setStagePlacement(stageVp) -- 736
	end -- 736
	if campaignLayer ~= nil then -- 736
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 739
	end -- 739
end -- 739
function syncFrameAdapters(frameDt) -- 743
	if input == nil then -- 743
		return -- 745
	end -- 745
	local p = play -- 747
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 748
	local isTrialMode = mode == 2 and p ~= nil -- 749
	local gameplayActive = isPlayMode or isTrialMode -- 750
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 752
		p, -- 754
		stageVp.stageW, -- 754
		stageVp.stageH, -- 754
		input:isTouchMode() -- 754
	) or ({}) -- 754
	if touchControls ~= nil and touchRouter ~= nil then -- 754
		local isFs = false -- 758
		if canToggleFullscreen() then -- 758
			do -- 758
				local function ____catch() -- 758
					isFs = false -- 763
				end -- 763
				local ____try = pcall(function() -- 763
					isFs = App.fullScreen -- 761
				end) -- 761
				if not ____try then -- 761
					____catch() -- 761
				end -- 761
			end -- 761
		end -- 761
		local ____touchControls_57 = touchControls -- 766
		local ____touchControls_syncContext_58 = touchControls.syncContext -- 766
		local ____stageVp_50 = stageVp -- 767
		local ____mode_51 = mode -- 768
		local ____temp_52 = fe ~= nil and fe.screen or "title" -- 769
		local ____run_53 = run -- 771
		local ____temp_54 = fe ~= nil and fe.cam or nil -- 772
		local ____input_55 = input -- 773
		local ____touchRouter_56 = touchRouter -- 774
		local ____temp_48 -- 775
		if fe ~= nil then -- 775
			____temp_48 = fe.contract:isAssistHintsEnabled() -- 775
		else -- 775
			____temp_48 = false -- 775
		end -- 775
		local ____temp_49 -- 776
		if fe ~= nil then -- 776
			____temp_49 = fe.audio:isAllMuted() -- 776
		else -- 776
			____temp_49 = false -- 776
		end -- 776
		____touchControls_syncContext_58(____touchControls_57, { -- 766
			viewport = ____stageVp_50, -- 767
			mode = ____mode_51, -- 768
			screen = ____temp_52, -- 769
			play = p, -- 770
			run = ____run_53, -- 771
			cam = ____temp_54, -- 772
			input = ____input_55, -- 773
			router = ____touchRouter_56, -- 774
			assistHintsEnabled = ____temp_48, -- 775
			isMuted = ____temp_49, -- 776
			isFullscreen = isFs, -- 777
			storyTalentBoxes = storyTalentBoxes, -- 778
			dt = frameDt -- 779
		}) -- 779
	end -- 779
	if gamepadRouter ~= nil then -- 779
		local trial = run and run.trial -- 784
		local trialEnded = isTrialMode and trial ~= nil and (trial.lost or (run and run.finished) == true) -- 785
		local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 786
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 787
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 790
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 791
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 792
		local ____temp_63 -- 795
		if isPlayMode and p ~= nil then -- 795
			____temp_63 = isCutsceneBlockingPlay(p) -- 795
		else -- 795
			____temp_63 = false -- 795
		end -- 795
		local cutsceneBlocking = ____temp_63 -- 795
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 796
		local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 798
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 799
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 801
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 803
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 806
		local playerScreenX = stageVp.stageW * 0.5 -- 808
		local playerScreenY = stageVp.stageH * 0.38 -- 809
		if p ~= nil then -- 809
			if isPlayMode and fe ~= nil then -- 809
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 812
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 813
			elseif fe ~= nil then -- 813
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 816
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 817
			else -- 817
				local vz = p.view.zoom > 0 and p.view.zoom or 1 -- 819
				playerScreenX = stageVp.stageW * 0.5 + (p.player.x + p.player.facing * 8 - p.cam.x) * vz -- 820
				playerScreenY = stageVp.stageH * 0.5 + (p.player.y + p.player.h * 0.72 + p.player.depth * DEPTH_Y_SCALE - p.cam.y) * vz -- 821
			end -- 821
		end -- 821
		local enemyTargets = canShoot and p ~= nil and (isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or (fe ~= nil and collectTrialAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or ({}))) or ({}) -- 825
		local gpCtx = { -- 833
			stageW = stageVp.stageW, -- 834
			stageH = stageVp.stageH, -- 835
			uiScale = stageVp.uiScale, -- 836
			modal = modal, -- 837
			gameplayActive = gameplayActive, -- 838
			reloadActive = reloadActive, -- 839
			craftActive = craftActive, -- 840
			talentOfferCount = talentOfferCount, -- 841
			childMode = p ~= nil and p.childMode, -- 842
			allowDepth = allowDepth, -- 843
			canShoot = canShoot, -- 844
			canBottleAim = canBottleAim, -- 845
			playerRolling = p ~= nil and p.player.rollT > 0, -- 846
			inLowArch = inLowArch, -- 847
			inTowerEnd = inTowerEnd, -- 848
			playerFacing = p ~= nil and p.player.facing or 1, -- 849
			playerScreenX = playerScreenX, -- 850
			playerScreenY = playerScreenY, -- 851
			enemyTargets = enemyTargets -- 852
		} -- 852
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 854
	end -- 854
end -- 854
function renderTouchOverlay() -- 858
	if touchControls ~= nil and touchRouter ~= nil then -- 858
		touchControls:render(touchRouter) -- 860
	end -- 860
end -- 860
function tick(frameDt) -- 864
	appClock = appClock + math.min( -- 865
		0.05, -- 865
		math.max(0, frameDt) -- 865
	) -- 865
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 866
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 867
	if w ~= viewW or h ~= viewH then -- 867
		viewW = w -- 869
		viewH = h -- 870
		applySize() -- 871
		dirty = true -- 872
	end -- 872
	if input == nil then -- 872
		return -- 875
	end -- 875
	syncFrameAdapters(frameDt) -- 877
	input:update() -- 878
	if input.userInteracted then -- 878
		onFirstUserGesture() -- 881
	end -- 881
	if input.muteTogglePressed and fe ~= nil then -- 881
		input.muteTogglePressed = false -- 884
		fe.audio:toggleAllMuted() -- 885
	end -- 885
	if input.fullscreenTogglePressed then -- 885
		input.fullscreenTogglePressed = false -- 888
		toggleFullscreen() -- 889
	end -- 889
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 889
		input.artifactTogglePressed = false -- 892
		play:toggleArtifactWeapon() -- 893
	end -- 893
	if input.bottleCanceled and play ~= nil then -- 893
		input.bottleCanceled = false -- 896
		play.aimHold = 0 -- 897
		play.bottleAimX = -1 -- 898
	end -- 898
	if mode == 2 and (run and run.trial) ~= nil then -- 898
		tickCampaign(frameDt) -- 902
		renderTouchOverlay() -- 903
		return -- 904
	end -- 904
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 904
		play:chooseTalent(input.pickRoom - 1) -- 910
		input.pickRoom = 0 -- 911
	end -- 911
	input.toggleView.pressed = false -- 915
	input.tab.pressed = false -- 916
	if mode == 2 then -- 916
		tickCampaign(frameDt) -- 919
	elseif mode == 1 then -- 919
		tickFrontend(frameDt) -- 921
	end -- 921
	renderTouchOverlay() -- 923
end -- 923
function registerPlay() -- 927
	local reg = _G.package.loaded -- 928
	reg["watch.play"] = play -- 929
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 930
	reg["watch.room"] = rooms[current + 1].key -- 931
end -- 931
function ensurePlay(resume) -- 935
	if mode == 2 then -- 935
		if run == nil then -- 935
			run = createRun() -- 938
		end -- 938
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 940
	else -- 940
		if storyRun == nil then -- 940
			storyRun = createRun(20261124, "debug", profile) -- 945
		end -- 945
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 947
	end -- 947
	registerPlay() -- 949
	clock:reset() -- 950
	if fe ~= nil then -- 950
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 953
		if mode == 2 then -- 953
			fe:resetTrialAudio(play) -- 955
		end -- 955
	end -- 955
end -- 955
function startTrial() -- 960
	current = 0 -- 961
	trialTalentSelected = 0 -- 962
	run = createTrial(App.rand) -- 963
	setMode(2) -- 964
	ensurePlay() -- 965
end -- 965
function tickCampaign(frameDt) -- 968
	if input == nil then -- 968
		return -- 970
	end -- 970
	if play == nil then -- 970
		ensurePlay() -- 973
	end -- 973
	if play == nil then -- 973
		return -- 976
	end -- 976
	local p = play -- 978
	p.aimX = input.mx -- 979
	p.aimY = input.my -- 980
	local zoneTap = input.touchZoneTap -- 982
	input.touchZoneTap = "" -- 983
	local trial = run and run.trial -- 985
	if trial ~= nil then -- 985
		local ended = trial.lost or (run and run.finished) == true -- 987
		local pick = input.pickRoom -- 988
		input.pickRoom = 0 -- 989
		if zoneTap == "trial:resume" and p.paused and not ended then -- 989
			p.paused = false -- 992
			clock:reset() -- 993
			input:consumeEdges() -- 994
			renderCampaign(frameDt, p) -- 995
			return -- 996
		end -- 996
		if zoneTap == "trial:retry" then -- 996
			input:consumeEdges() -- 999
			startTrial() -- 1000
			return -- 1001
		end -- 1001
		if zoneTap == "trial:title" then -- 1001
			input:consumeEdges() -- 1004
			current = 0 -- 1005
			play = nil -- 1006
			run = nil -- 1007
			setMode(1) -- 1008
			if fe ~= nil then -- 1008
				fe.audio:stopRoomTransient() -- 1010
				fe.screen = "title" -- 1011
				fe.menus:resetInput() -- 1012
			end -- 1012
			return -- 1014
		end -- 1014
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1014
			input:consumeEdges() -- 1018
			current = 0 -- 1019
			play = nil -- 1020
			run = nil -- 1021
			setMode(1) -- 1022
			if fe ~= nil then -- 1022
				fe.audio:stopRoomTransient() -- 1024
				fe.screen = "title" -- 1025
				fe.menus:resetInput() -- 1026
			end -- 1026
			return -- 1028
		end -- 1028
		if ended or p.paused and input.retry.pressed then -- 1028
			local restart = input.retry.pressed or ended and input.navConfirm -- 1031
			input:consumeEdges() -- 1032
			if restart then -- 1032
				startTrial() -- 1033
			else -- 1033
				renderCampaign(frameDt, p) -- 1034
			end -- 1034
			return -- 1035
		end -- 1035
		input.retry.pressed = false -- 1037
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1037
			if trialTalentSelected >= #trial.offers then -- 1037
				trialTalentSelected = 0 -- 1040
			end -- 1040
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1040
				local idx = __TS__ParseInt( -- 1043
					string.sub(zoneTap, 8), -- 1043
					10 -- 1043
				) -- 1043
				if idx >= 0 and idx < #trial.offers then -- 1043
					p:chooseTalent(idx) -- 1045
				end -- 1045
			elseif pick > 0 then -- 1045
				p:chooseTalent(pick - 1) -- 1048
			else -- 1048
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1050
				if delta ~= 0 then -- 1050
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1054
				end -- 1054
				if input.talentConfirm or input.navConfirm then -- 1054
					p:chooseTalent(trialTalentSelected) -- 1057
				end -- 1057
			end -- 1057
			input:consumeEdges() -- 1060
			clock:reset() -- 1061
			renderCampaign(frameDt, p) -- 1062
			return -- 1063
		end -- 1063
	end -- 1063
	if input.retry.pressed then -- 1063
		input.retry.pressed = false -- 1068
		input:consumeEdges() -- 1069
		play = nil -- 1071
		ensurePlay() -- 1072
		return -- 1073
	end -- 1073
	if input.pause.pressed or p.paused and input.navBack then -- 1073
		input.pause.pressed = false -- 1076
		p.paused = not p.paused -- 1077
		if fe ~= nil then -- 1077
			fe.audio:playUi(p.paused and "ui:pause_open" or "ui:pause_close", p.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 1078
		end -- 1078
		clock:reset() -- 1079
		input:consumeEdges() -- 1080
	end -- 1080
	if p.paused then -- 1080
		renderCampaign(frameDt, p) -- 1083
		return -- 1084
	end -- 1084
	local steps = clock:advance(frameDt) -- 1087
	local i = 0 -- 1088
	do -- 1088
		i = 0 -- 1089
		while i < steps do -- 1089
			input:beginStep(i == 0) -- 1090
			p:update(STEP, input) -- 1091
			input:endStep() -- 1092
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1092
				break -- 1094
			end -- 1094
			i = i + 1 -- 1089
		end -- 1089
	end -- 1089
	if p.wantRoom ~= "" then -- 1089
		local key = p.wantRoom -- 1099
		p.wantRoom = "" -- 1100
		local idx = -1 -- 1101
		local j = 0 -- 1102
		do -- 1102
			j = 0 -- 1103
			while j < #CAMPAIGN_ROOMS do -- 1103
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1103
					idx = j -- 1105
				end -- 1105
				j = j + 1 -- 1103
			end -- 1103
		end -- 1103
		if idx >= 0 then -- 1103
			current = idx -- 1109
			play = nil -- 1110
			ensurePlay() -- 1111
		end -- 1111
		return -- 1113
	end -- 1113
	renderCampaign(frameDt, p) -- 1115
end -- 1115
function goalLabel(goal) -- 1118
	if goal == "dock_cart" then -- 1118
		return "推车入窝并抬闩" -- 1120
	end -- 1120
	if goal == "raise_latch" then -- 1120
		return "抬闩开侧门" -- 1123
	end -- 1123
	return "到段出口" -- 1125
end -- 1125
function renderCampaign(frameDt, p) -- 1129
	if fe ~= nil and input ~= nil then -- 1129
		local ____opt_76 = run and run.trial -- 1129
		local offers = ____opt_76 and #____opt_76.offers or 0 -- 1132
		local ____p_paused_80 -- 1133
		if p.paused then -- 1133
			____p_paused_80 = nil -- 1133
		else -- 1133
			____p_paused_80 = fe.adapter:sample(p) -- 1133
		end -- 1133
		local ev = ____p_paused_80 -- 1133
		fe:renderPlay( -- 1134
			frameDt, -- 1134
			p, -- 1134
			input, -- 1134
			stageVp.stageW, -- 1134
			stageVp.stageH, -- 1134
			true, -- 1134
			ev -- 1134
		) -- 1134
		fe:syncTrialAudio(frameDt, p, offers, ev) -- 1135
	end -- 1135
	drawCampaignHud(p) -- 1137
end -- 1137
function drawCampaignHud(p) -- 1141
	local h = stageVp.stageH -- 1142
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1143
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1144
	local room = CAMPAIGN_ROOMS[current + 1] -- 1145
	local c = room.campaign -- 1146
	local r = run -- 1147
	local trial = r and r.trial -- 1148
	local gpMode = input ~= nil and input:isGamepadMode() -- 1149
	local touchMode = input ~= nil and input:isTouchMode() -- 1150
	local line = room.name -- 1153
	if trial == nil then -- 1153
		if c ~= nil then -- 1153
			line = (((line .. "  · 目标 ") .. goalLabel(c.goal)) .. "  · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0)) -- 1156
		end -- 1156
		if p.paused then -- 1156
			line = line .. "  · 已暂停" -- 1158
		end -- 1158
	else -- 1158
		line = (((((("护送试炼 · " .. room.name) .. "  · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. "  · ") .. mmss(r == nil and 0 or r.ticks) -- 1160
		if p.paused then -- 1160
			line = line .. "  · 暂停" -- 1161
		elseif trial.lost then -- 1161
			line = line .. "  · 护送失败" -- 1162
		elseif r ~= nil and r.finished then -- 1162
			line = line .. "  · 护送完成" -- 1163
		elseif #trial.offers > 0 then -- 1163
			line = line .. "  · 选择本段本领" -- 1164
		elseif c ~= nil then -- 1164
			line = line .. "  · " .. goalLabel(c.goal) -- 1165
		end -- 1165
	end -- 1165
	if campaignHud ~= nil then -- 1165
		campaignHud.text = line -- 1168
		campaignHud.position = Vec2(stageVp.stageW * 0.5, h - 12 - safeT) -- 1169
		campaignHud.visible = true -- 1170
	end -- 1170
	if campaignSub == nil then -- 1170
		return -- 1174
	end -- 1174
	local sub = p.flash -- 1176
	if trial ~= nil then -- 1176
		if trial.lost or r ~= nil and r.finished then -- 1176
			sub = gpMode and "A 再开一局 · START 返回标题" or (touchMode and "点下方按钮再开或返回标题" or "R 再开一局 · Esc 返回标题") -- 1179
		elseif p.paused then -- 1179
			sub = gpMode and "START 继续 · 长按 BACK 重开 · Y 返回标题" or (touchMode and "点下方按钮继续 / 重开 / 返回标题" or "Esc 继续 · R 重新开局") -- 1181
		elseif #trial.offers > 0 then -- 1181
			sub = table.concat( -- 1183
				__TS__ArrayMap( -- 1183
					trial.offers, -- 1183
					function(____, talent, index) -- 1183
						local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1184
						return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1185
					end -- 1183
				), -- 1183
				"　" -- 1186
			) -- 1186
		elseif sub == "" and r ~= nil then -- 1186
			sub = r.joined and "小满跟随" or "小满等待" -- 1188
		end -- 1188
	end -- 1188
	campaignSub.text = sub -- 1191
	campaignSub.position = Vec2(stageVp.stageW * 0.5, 14 + stageVp.safeUi.bottom * stageVp.uiScale) -- 1192
	campaignSub.visible = sub ~= "" -- 1193
end -- 1193
function tickFrontend(frameDt) -- 1196
	if fe == nil or input == nil then -- 1196
		return -- 1198
	end -- 1198
	if fe.screen ~= "play" then -- 1198
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1203
		input:consumeEdges() -- 1204
		if act.type == "splashDone" then -- 1204
			fe.menus:resetInput() -- 1206
			fe.screen = "title" -- 1207
		elseif act.type == "trial" then -- 1207
			startTrial() -- 1209
		elseif act.type == "continue" then -- 1209
			if continueOfficialStory() == nil then -- 1209
				enterPlayRoom( -- 1212
					officialStartIndex(), -- 1212
					"official", -- 1212
					true -- 1212
				) -- 1212
			end -- 1212
		elseif act.type == "start" then -- 1212
			clearSession() -- 1216
			refreshTitleSessionFlag() -- 1217
			enterPlayRoom( -- 1218
				officialStartIndex(), -- 1218
				"official", -- 1218
				true -- 1218
			) -- 1218
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1218
			enterPlayRoom(act.roomIndex, "chapter") -- 1220
		elseif act.type == "openChapters" then -- 1220
			fe.menus:openChapters() -- 1222
			fe.screen = "chapters" -- 1223
		elseif act.type == "openControls" then -- 1223
			fe.menus:resetInput() -- 1225
			fe.screen = "controls" -- 1226
		elseif act.type == "openHistory" then -- 1226
			fe.menus:openHistory(true) -- 1228
			fe.screen = "history" -- 1229
		elseif act.type == "backEpilogue" then -- 1229
			fe.menus:resetInput() -- 1231
			fe.screen = "epilogue" -- 1232
		elseif act.type == "replayStory" then -- 1232
			clearSession() -- 1234
			refreshTitleSessionFlag() -- 1235
			enterPlayRoom( -- 1236
				officialStartIndex(), -- 1236
				"official", -- 1236
				true -- 1236
			) -- 1236
		elseif act.type == "backTitle" then -- 1236
			fe.menus:resetInput() -- 1238
			fe.screen = "title" -- 1239
		elseif act.type == "backPause" then -- 1239
			fe.menus:resetInput() -- 1241
			fe.screen = "play" -- 1242
		elseif act.type == "quit" then -- 1242
			quitGame() -- 1244
		end -- 1244
		return -- 1246
	end -- 1246
	if play == nil then -- 1246
		ensurePlay() -- 1251
	end -- 1251
	if play == nil then -- 1251
		return -- 1254
	end -- 1254
	local p = play -- 1256
	p.aimX = input.mx -- 1258
	p.aimY = input.my -- 1259
	local zoneTap = input.touchZoneTap -- 1261
	input.touchZoneTap = "" -- 1262
	local offers = p:getStoryTalentOffers() -- 1264
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1264
		if fe.hud.talentSelected >= #offers then -- 1264
			fe.hud.talentSelected = 0 -- 1267
		end -- 1267
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1267
			local idx = __TS__ParseInt( -- 1270
				string.sub(zoneTap, 8), -- 1270
				10 -- 1270
			) -- 1270
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1270
				input.fire.pressed = false -- 1272
			end -- 1272
		else -- 1272
			if input.talentDelta ~= 0 then -- 1272
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1276
				input.talentDelta = 0 -- 1277
			end -- 1277
			if input.talentConfirm then -- 1277
				p:chooseTalent(fe.hud.talentSelected) -- 1280
				input.talentConfirm = false -- 1281
				input.fire.pressed = false -- 1282
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1282
				input.fire.pressed = false -- 1285
			end -- 1285
		end -- 1285
	end -- 1285
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1285
		if input.navConfirm then -- 1285
			input.interact.pressed = true -- 1293
		end -- 1293
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1293
			flushProfile() -- 1296
			if p.run.source == "official" and hasSessionSave() then -- 1296
				clearSession() -- 1298
				refreshTitleSessionFlag() -- 1299
			end -- 1299
			fe.audio:stopRoomTransient() -- 1301
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1302
			fe.screen = "epilogue" -- 1306
			input:clearTransient(true) -- 1307
			input:consumeEdges() -- 1308
			return -- 1309
		end -- 1309
	end -- 1309
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1309
		p:closeCraftBench() -- 1314
		input:consumeEdges() -- 1315
		return -- 1316
	end -- 1316
	if not p.paused and input.pause.pressed then -- 1316
		p.paused = true -- 1319
		p.aimHold = 0 -- 1320
		p.bottleAimX = -1 -- 1321
		saveCurrentSession() -- 1322
		fe.menus:openPause() -- 1323
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1324
		input:clearTransient(true) -- 1325
		input:consumeEdges() -- 1326
	end -- 1326
	if p.paused then -- 1326
		clock:reset() -- 1331
		local pauseAct = fe:renderPlay( -- 1332
			frameDt, -- 1332
			p, -- 1332
			input, -- 1332
			stageVp.stageW, -- 1332
			stageVp.stageH -- 1332
		) -- 1332
		input:consumeEdges() -- 1333
		if pauseAct.type == "resume" then -- 1333
			p.paused = false -- 1335
		elseif pauseAct.type == "retry" then -- 1335
			ensurePlay({checkpoint = p.checkpoint}) -- 1337
		elseif pauseAct.type == "openChapters" then -- 1337
			fe.audio:stopRoomTransient() -- 1339
			fe.audio:setPaused(false) -- 1340
			fe.menus:openChapters(current) -- 1341
			fe.screen = "chapters" -- 1342
		elseif pauseAct.type == "toggleFullscreen" then -- 1342
			toggleFullscreen() -- 1344
		elseif pauseAct.type == "quit" then -- 1344
			quitGame() -- 1346
		elseif pauseAct.type == "toTitle" then -- 1346
			saveCurrentSession() -- 1348
			refreshTitleSessionFlag() -- 1349
			fe.menus:resetInput() -- 1350
			fe.screen = "title" -- 1351
		end -- 1351
		return -- 1353
	end -- 1353
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1356
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1357
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1357
		input:consumeEdges() -- 1360
		ensurePlay({checkpoint = p.checkpoint}) -- 1362
		return -- 1363
	end -- 1363
	local steps = clock:advance(frameDt) -- 1366
	local i = 0 -- 1367
	do -- 1367
		i = 0 -- 1368
		while i < steps do -- 1368
			input:beginStep(i == 0) -- 1369
			p:update(STEP, input) -- 1370
			input:endStep() -- 1371
			if p.wantRoom ~= "" then -- 1371
				break -- 1373
			end -- 1373
			i = i + 1 -- 1368
		end -- 1368
	end -- 1368
	if p.wantRoom ~= "" then -- 1368
		local key = p.wantRoom -- 1379
		p.wantRoom = "" -- 1380
		local idx = -1 -- 1381
		local j = 0 -- 1382
		do -- 1382
			j = 0 -- 1383
			while j < #ROOMS do -- 1383
				if ROOMS[j + 1].key == key then -- 1383
					idx = j -- 1385
				end -- 1385
				j = j + 1 -- 1383
			end -- 1383
		end -- 1383
		if idx >= 0 then -- 1383
			flushProfile() -- 1392
			local leaving = p:drainEvents() -- 1393
			if p.restartStory then -- 1393
				if storyRun ~= nil and storyRun.source == "official" then -- 1393
					clearSession() -- 1397
					refreshTitleSessionFlag() -- 1398
				end -- 1398
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1400
				storyRun = createRun(20261124, nextSource, profile) -- 1401
			end -- 1401
			current = idx -- 1403
			ensurePlay() -- 1404
			local fresh = play -- 1405
			if fresh ~= nil then -- 1405
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1405
					fresh.phase = "prologue-wake" -- 1408
				end -- 1408
				fresh:adoptEvents(leaving) -- 1410
			end -- 1410
			if not p.restartStory then -- 1410
				saveCurrentSession() -- 1413
			end -- 1413
			clock:reset() -- 1415
			dirty = true -- 1416
		end -- 1416
		return -- 1418
	end -- 1418
	flushProfile() -- 1422
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1422
		clearSession() -- 1424
		refreshTitleSessionFlag() -- 1425
	elseif p.sessionDirty then -- 1425
		saveCurrentSession() -- 1427
	end -- 1427
	fe:renderPlay( -- 1429
		frameDt, -- 1429
		p, -- 1429
		input, -- 1429
		stageVp.stageW, -- 1429
		stageVp.stageH -- 1429
	) -- 1429
end -- 1429
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
	campaignLayer.order = 6 -- 342
	campaignLayer:addTo(parent) -- 343
	campaignHud = Label(FONT, 24) -- 344
	if campaignHud ~= nil then -- 344
		campaignHud.color = C_TEXT -- 346
		campaignHud.anchor = Vec2(0.5, 1) -- 347
		campaignHud:addTo(campaignLayer) -- 348
		campaignHud.visible = true -- 349
	end -- 349
	campaignSub = Label(FONT, 20) -- 351
	if campaignSub ~= nil then -- 351
		campaignSub.color = C_ACCENT -- 353
		campaignSub.anchor = Vec2(0.5, 0) -- 354
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
		if mode == 2 and (run and run.trial) ~= nil then -- 457
			if key == "1" or key == "2" or key == "3" then -- 457
				if input ~= nil then -- 457
					input:requestPickRoom(key == "1" and 1 or (key == "2" and 2 or 3)) -- 462
				end -- 462
				return -- 463
			end -- 463
		end -- 463
		local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 466
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 466
			fe.menus:onKeyEvent(key) -- 468
		end -- 468
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay or mode == 2) then -- 468
			if key == "E" then -- 468
				input.interact.pressed = true -- 472
			elseif key == "Space" then -- 472
				input.jump.pressed = true -- 474
			elseif key == "Escape" then -- 474
				input.pause.pressed = true -- 476
			elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 476
				input.retry.pressed = true -- 478
			end -- 478
		end -- 478
	end) -- 430
	viewW = View.size.width -- 483
	viewH = View.size.height -- 484
	applySize() -- 485
	local reg = _G.package.loaded -- 488
	reg["watch.input"] = input -- 489
	reg["watch.touch"] = touchRouter -- 490
	reg["watch.gamepad"] = gamepadRouter -- 491
	reg["watch.fe"] = { -- 492
		setScreen = function(sc) -- 493
			if fe == nil then -- 493
				return -- 495
			end -- 495
			setMode(1) -- 497
			fe.screen = sc -- 498
			if sc == "splash" then -- 498
				fe.menus:resetSplash() -- 500
			elseif sc == "chapters" then -- 500
				fe.menus:openChapters() -- 502
			elseif sc == "epilogue" then -- 502
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 504
			elseif sc == "history" then -- 504
				fe.menus:openHistory(false) -- 509
			else -- 509
				fe.menus:resetInput() -- 511
			end -- 511
			if sc == "play" then -- 511
				ensurePlay() -- 514
			end -- 514
		end, -- 493
		jumpRoom = function(keyOrIdx) -- 517
			local idx = -1 -- 518
			if type(keyOrIdx) == "number" then -- 518
				idx = keyOrIdx -- 520
			else -- 520
				local k = 0 -- 522
				do -- 522
					k = 0 -- 523
					while k < #ROOMS do -- 523
						if ROOMS[k + 1].key == keyOrIdx then -- 523
							idx = k -- 525
						end -- 525
						k = k + 1 -- 523
					end -- 523
				end -- 523
			end -- 523
			if idx >= 0 and idx < #ROOMS then -- 523
				enterPlayRoom(idx, "debug") -- 530
			end -- 530
		end, -- 517
		getPlay = function() return play end, -- 533
		getFrontend = function() return fe end, -- 534
		startStory = function() -- 536
			enterPlayRoom( -- 537
				officialStartIndex(), -- 537
				"official", -- 537
				true -- 537
			) -- 537
			return play -- 538
		end, -- 536
		previewChapter = function(idx) -- 541
			enterPlayRoom(idx, "chapter") -- 542
			return play -- 543
		end, -- 541
		getStoryRun = function() return storyRun end, -- 545
		getProfilePending = function() return profilePending() end, -- 546
		flushProfileNow = function() return flushProfile() end, -- 547
		getProfile = function() return profile end, -- 549
		getProfileStatus = function() return profileStatus end, -- 550
		getProfileDetail = function() return profileDetail end, -- 551
		useTestSave = function(name) -- 552
			setSaveFile(name) -- 553
			setSessionFile(name == "" and "" or name .. ".session") -- 554
			clearProfilePending() -- 555
			local loaded = loadSave() -- 556
			profile = loaded.state -- 557
			profileStatus = loaded.status -- 558
			profileDetail = loaded.detail -- 559
			refreshTitleSessionFlag() -- 560
		end, -- 552
		useTestSession = function(name) -- 562
			setSessionFile(name) -- 563
			refreshTitleSessionFlag() -- 564
		end, -- 562
		getSessionFile = getSessionFile, -- 566
		hasSessionSave = hasSessionSave, -- 567
		saveSessionNow = function() return saveCurrentSession() end, -- 568
		clearSessionNow = function() -- 569
			local ok = clearSession() -- 570
			refreshTitleSessionFlag() -- 571
			return ok -- 572
		end, -- 569
		continueStory = function() return continueOfficialStory() end, -- 574
		saveNow = function() return saveSave(profile) end, -- 575
		getSaveFile = getSaveFile, -- 576
		isRelease = function() return isReleaseBuild() end, -- 577
		getReleaseVersion = function() -- 578
			local ____opt_34 = getReleaseConfig() -- 578
			return ____opt_34 and ____opt_34.version or "dev" -- 578
		end, -- 578
		toggleFullscreen = function() return toggleFullscreen() end, -- 579
		quitGame = function() return quitGame() end, -- 580
		startTrial = function() return startTrial() end, -- 581
		handleBackButton = function() return handleBackButton() end, -- 582
		getViewport = function() return stageVp end, -- 583
		getTouchController = function() return touchControls end, -- 584
		getTouchRouter = function() return touchRouter end, -- 585
		getGamepad = function() return gamepadRouter end, -- 586
		setGamepadSim = function(state) -- 587
			if gamepadRouter ~= nil then -- 587
				gamepadRouter:setSimulatedState(state) -- 588
			end -- 588
		end, -- 587
		injectTouch = function(phase, id, x, y, fromMouse) -- 590
			if touchRouter ~= nil then -- 590
				touchRouter:injectTouch( -- 591
					phase, -- 591
					id, -- 591
					x, -- 591
					y, -- 591
					fromMouse -- 591
				) -- 591
			end -- 591
		end, -- 590
		getInputMode = function() return input and input.inputMode or "kbm" end, -- 593
		setInputMode = function(m) -- 594
			if input ~= nil then -- 594
				input:setInputMode(m) -- 595
			end -- 595
		end, -- 594
		setModePref = function(pref) -- 597
			if input ~= nil then -- 597
				input:setModePref(pref) -- 598
			end -- 598
		end, -- 597
		applyViewportForTest = function(w, h) -- 600
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 600
				testViewportOverride = {w = w, h = h} -- 602
				viewW = w -- 603
				viewH = h -- 604
			else -- 604
				testViewportOverride = nil -- 606
				viewW = View.size.width -- 607
				viewH = View.size.height -- 608
			end -- 608
			applySize() -- 610
			dirty = true -- 611
			return stageVp -- 612
		end, -- 600
		getToast = function() return fe and fe:getToastText() or "" end -- 614
	} -- 614
	if mode == 1 and startScreen == "play" then -- 614
		ensurePlay() -- 618
	end -- 618
	parent:schedule(function(frameDt) -- 621
		tick(frameDt) -- 622
		return false -- 623
	end) -- 621
end -- 336
local function pickByIndex(idx, source) -- 695
	if source == nil then -- 695
		source = "debug" -- 695
	end -- 695
	if mode == 2 then -- 695
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 695
			return -- 698
		end -- 698
		current = idx -- 700
		play = nil -- 701
		clock:reset() -- 702
		ensurePlay() -- 703
		return -- 704
	end -- 704
	if idx < 0 or idx >= #ROOMS then -- 704
		return -- 707
	end -- 707
	flushProfile() -- 709
	if storyRun ~= nil then -- 709
		storyRun.source = source -- 711
	end -- 711
	current = idx -- 713
	dirty = true -- 714
	play = nil -- 715
	clock:reset() -- 716
	if mode == 1 then -- 716
		if fe ~= nil then -- 716
			fe.screen = "play" -- 719
		end -- 719
		ensurePlay() -- 721
	end -- 721
end -- 695
return ____exports -- 695