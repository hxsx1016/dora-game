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
--- 章节直达后半段时按目标房间预置独立预览路线（不改正式档、不污染通关档案）。
function ____exports.applyChapterPreviewRoute(run, targetKey) -- 674
	if targetKey == "outside" or targetKey == "village" or targetKey == "forest" or targetKey == "tower" then -- 674
		run.story.route = "child" -- 676
		run.story.settled = true -- 677
	elseif targetKey == "gatepath" or (string.find(targetKey, "escort", nil, true) or 0) - 1 == 0 then -- 677
		run.story.route = "soldier" -- 679
		run.story.settled = true -- 680
		run.joined = true -- 681
		if (string.find(targetKey, "escort", nil, true) or 0) - 1 == 0 then -- 681
			run.story.carry = true -- 683
		end -- 683
	end -- 683
end -- 674
function enterPlayRoom(idx, source, fresh) -- 688
	if source == nil then -- 688
		source = "debug" -- 688
	end -- 688
	if fresh == nil then -- 688
		fresh = false -- 688
	end -- 688
	current = idx -- 689
	setMode(1) -- 690
	if fe ~= nil then -- 690
		fe.screen = "play" -- 692
	end -- 692
	play = nil -- 694
	if fresh or source == "chapter" or storyRun == nil then -- 694
		storyRun = createRun(20261124, source, profile) -- 697
		if source == "chapter" then -- 697
			local targetKey = ROOMS[current + 1] ~= nil and ROOMS[current + 1].key or "" -- 699
			____exports.applyChapterPreviewRoute(storyRun, targetKey) -- 700
		end -- 700
	else -- 700
		storyRun.source = source -- 703
	end -- 703
	ensurePlay() -- 705
	local firstPlay = play -- 707
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 707
		firstPlay.phase = "prologue-wake" -- 709
	end -- 709
	flushProfile() -- 711
end -- 711
function applySize() -- 744
	if root == nil then -- 744
		return -- 746
	end -- 746
	root.size = Size(viewW, viewH) -- 748
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 749
	stageVp = computeStageViewport(viewW, viewH) -- 750
	if input ~= nil then -- 750
		input:setStageViewport(stageVp) -- 752
	end -- 752
	if fe ~= nil then -- 752
		fe:setStagePlacement(stageVp) -- 755
	end -- 755
	if campaignLayer ~= nil then -- 755
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 758
	end -- 758
end -- 758
function syncFrameAdapters(frameDt) -- 762
	if input == nil then -- 762
		return -- 764
	end -- 764
	local p = play -- 766
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 767
	local isTrialMode = mode == 2 and p ~= nil -- 768
	local gameplayActive = isPlayMode or isTrialMode -- 769
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 771
		p, -- 773
		stageVp.stageW, -- 773
		stageVp.stageH, -- 773
		input:isTouchMode() -- 773
	) or ({}) -- 773
	if touchControls ~= nil and touchRouter ~= nil then -- 773
		local isFs = false -- 777
		if canToggleFullscreen() then -- 777
			do -- 777
				local function ____catch() -- 777
					isFs = false -- 782
				end -- 782
				local ____try = pcall(function() -- 782
					isFs = App.fullScreen -- 780
				end) -- 780
				if not ____try then -- 780
					____catch() -- 780
				end -- 780
			end -- 780
		end -- 780
		local ____touchControls_57 = touchControls -- 785
		local ____touchControls_syncContext_58 = touchControls.syncContext -- 785
		local ____stageVp_50 = stageVp -- 786
		local ____mode_51 = mode -- 787
		local ____temp_52 = fe ~= nil and fe.screen or "title" -- 788
		local ____run_53 = run -- 790
		local ____temp_54 = fe ~= nil and fe.cam or nil -- 791
		local ____input_55 = input -- 792
		local ____touchRouter_56 = touchRouter -- 793
		local ____temp_48 -- 794
		if fe ~= nil then -- 794
			____temp_48 = fe.contract:isAssistHintsEnabled() -- 794
		else -- 794
			____temp_48 = false -- 794
		end -- 794
		local ____temp_49 -- 795
		if fe ~= nil then -- 795
			____temp_49 = fe.audio:isAllMuted() -- 795
		else -- 795
			____temp_49 = false -- 795
		end -- 795
		____touchControls_syncContext_58(____touchControls_57, { -- 785
			viewport = ____stageVp_50, -- 786
			mode = ____mode_51, -- 787
			screen = ____temp_52, -- 788
			play = p, -- 789
			run = ____run_53, -- 790
			cam = ____temp_54, -- 791
			input = ____input_55, -- 792
			router = ____touchRouter_56, -- 793
			assistHintsEnabled = ____temp_48, -- 794
			isMuted = ____temp_49, -- 795
			isFullscreen = isFs, -- 796
			storyTalentBoxes = storyTalentBoxes, -- 797
			dt = frameDt -- 798
		}) -- 798
	end -- 798
	if gamepadRouter ~= nil then -- 798
		local trial = run and run.trial -- 803
		local trialEnded = isTrialMode and trial ~= nil and (trial.lost or (run and run.finished) == true) -- 804
		local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 805
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 806
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 809
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 810
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 811
		local ____temp_63 -- 814
		if isPlayMode and p ~= nil then -- 814
			____temp_63 = isCutsceneBlockingPlay(p) -- 814
		else -- 814
			____temp_63 = false -- 814
		end -- 814
		local cutsceneBlocking = ____temp_63 -- 814
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 815
		local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 817
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 818
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 820
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 822
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 825
		local playerScreenX = stageVp.stageW * 0.5 -- 827
		local playerScreenY = stageVp.stageH * 0.38 -- 828
		if p ~= nil then -- 828
			if isPlayMode and fe ~= nil then -- 828
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 831
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 832
			elseif fe ~= nil then -- 832
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 835
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 836
			else -- 836
				local vz = p.view.zoom > 0 and p.view.zoom or 1 -- 838
				playerScreenX = stageVp.stageW * 0.5 + (p.player.x + p.player.facing * 8 - p.cam.x) * vz -- 839
				playerScreenY = stageVp.stageH * 0.5 + (p.player.y + p.player.h * 0.72 + p.player.depth * DEPTH_Y_SCALE - p.cam.y) * vz -- 840
			end -- 840
		end -- 840
		local enemyTargets = canShoot and p ~= nil and (isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or (fe ~= nil and collectTrialAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or ({}))) or ({}) -- 844
		local gpCtx = { -- 852
			stageW = stageVp.stageW, -- 853
			stageH = stageVp.stageH, -- 854
			uiScale = stageVp.uiScale, -- 855
			modal = modal, -- 856
			gameplayActive = gameplayActive, -- 857
			reloadActive = reloadActive, -- 858
			craftActive = craftActive, -- 859
			talentOfferCount = talentOfferCount, -- 860
			childMode = p ~= nil and p.childMode, -- 861
			allowDepth = allowDepth, -- 862
			canShoot = canShoot, -- 863
			canBottleAim = canBottleAim, -- 864
			playerRolling = p ~= nil and p.player.rollT > 0, -- 865
			inLowArch = inLowArch, -- 866
			inTowerEnd = inTowerEnd, -- 867
			playerFacing = p ~= nil and p.player.facing or 1, -- 868
			playerScreenX = playerScreenX, -- 869
			playerScreenY = playerScreenY, -- 870
			enemyTargets = enemyTargets -- 871
		} -- 871
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 873
	end -- 873
end -- 873
function renderTouchOverlay() -- 877
	if touchControls ~= nil and touchRouter ~= nil then -- 877
		touchControls:render(touchRouter) -- 879
	end -- 879
end -- 879
function tick(frameDt) -- 883
	appClock = appClock + math.min( -- 884
		0.05, -- 884
		math.max(0, frameDt) -- 884
	) -- 884
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 885
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 886
	if w ~= viewW or h ~= viewH then -- 886
		viewW = w -- 888
		viewH = h -- 889
		applySize() -- 890
		dirty = true -- 891
	end -- 891
	if input == nil then -- 891
		return -- 894
	end -- 894
	syncFrameAdapters(frameDt) -- 896
	input:update() -- 897
	if input.userInteracted then -- 897
		onFirstUserGesture() -- 900
	end -- 900
	if input.muteTogglePressed and fe ~= nil then -- 900
		input.muteTogglePressed = false -- 903
		fe.audio:toggleAllMuted() -- 904
	end -- 904
	if input.fullscreenTogglePressed then -- 904
		input.fullscreenTogglePressed = false -- 907
		toggleFullscreen() -- 908
	end -- 908
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 908
		input.artifactTogglePressed = false -- 911
		play:toggleArtifactWeapon() -- 912
	end -- 912
	if input.bottleCanceled and play ~= nil then -- 912
		input.bottleCanceled = false -- 915
		play.aimHold = 0 -- 916
		play.bottleAimX = -1 -- 917
	end -- 917
	if mode == 2 and (run and run.trial) ~= nil then -- 917
		tickCampaign(frameDt) -- 921
		renderTouchOverlay() -- 922
		return -- 923
	end -- 923
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 923
		play:chooseTalent(input.pickRoom - 1) -- 929
		input.pickRoom = 0 -- 930
	end -- 930
	input.toggleView.pressed = false -- 934
	input.tab.pressed = false -- 935
	if mode == 2 then -- 935
		tickCampaign(frameDt) -- 938
	elseif mode == 1 then -- 938
		tickFrontend(frameDt) -- 940
	end -- 940
	renderTouchOverlay() -- 942
end -- 942
function registerPlay() -- 946
	local reg = _G.package.loaded -- 947
	reg["watch.play"] = play -- 948
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 949
	reg["watch.room"] = rooms[current + 1].key -- 950
end -- 950
function ensurePlay(resume) -- 954
	if mode == 2 then -- 954
		if run == nil then -- 954
			run = createRun() -- 957
		end -- 957
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 959
	else -- 959
		if storyRun == nil then -- 959
			storyRun = createRun(20261124, "debug", profile) -- 964
		end -- 964
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 966
	end -- 966
	registerPlay() -- 968
	clock:reset() -- 969
	if fe ~= nil then -- 969
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 972
		if mode == 2 then -- 972
			fe:resetTrialAudio(play) -- 974
		end -- 974
	end -- 974
end -- 974
function startTrial() -- 979
	current = 0 -- 980
	trialTalentSelected = 0 -- 981
	run = createTrial(App.rand) -- 982
	setMode(2) -- 983
	ensurePlay() -- 984
end -- 984
function tickCampaign(frameDt) -- 987
	if input == nil then -- 987
		return -- 989
	end -- 989
	if play == nil then -- 989
		ensurePlay() -- 992
	end -- 992
	if play == nil then -- 992
		return -- 995
	end -- 995
	local p = play -- 997
	p.aimX = input.mx -- 998
	p.aimY = input.my -- 999
	local zoneTap = input.touchZoneTap -- 1001
	input.touchZoneTap = "" -- 1002
	local trial = run and run.trial -- 1004
	if trial ~= nil then -- 1004
		local ended = trial.lost or (run and run.finished) == true -- 1006
		local pick = input.pickRoom -- 1007
		input.pickRoom = 0 -- 1008
		if zoneTap == "trial:resume" and p.paused and not ended then -- 1008
			p.paused = false -- 1011
			clock:reset() -- 1012
			input:consumeEdges() -- 1013
			renderCampaign(frameDt, p) -- 1014
			return -- 1015
		end -- 1015
		if zoneTap == "trial:retry" then -- 1015
			input:consumeEdges() -- 1018
			startTrial() -- 1019
			return -- 1020
		end -- 1020
		if zoneTap == "trial:title" then -- 1020
			input:consumeEdges() -- 1023
			current = 0 -- 1024
			play = nil -- 1025
			run = nil -- 1026
			setMode(1) -- 1027
			if fe ~= nil then -- 1027
				fe.audio:stopRoomTransient() -- 1029
				fe.screen = "title" -- 1030
				fe.menus:resetInput() -- 1031
			end -- 1031
			return -- 1033
		end -- 1033
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1033
			input:consumeEdges() -- 1037
			current = 0 -- 1038
			play = nil -- 1039
			run = nil -- 1040
			setMode(1) -- 1041
			if fe ~= nil then -- 1041
				fe.audio:stopRoomTransient() -- 1043
				fe.screen = "title" -- 1044
				fe.menus:resetInput() -- 1045
			end -- 1045
			return -- 1047
		end -- 1047
		if ended or p.paused and input.retry.pressed then -- 1047
			local restart = input.retry.pressed or ended and input.navConfirm -- 1050
			input:consumeEdges() -- 1051
			if restart then -- 1051
				startTrial() -- 1052
			else -- 1052
				renderCampaign(frameDt, p) -- 1053
			end -- 1053
			return -- 1054
		end -- 1054
		input.retry.pressed = false -- 1056
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1056
			if trialTalentSelected >= #trial.offers then -- 1056
				trialTalentSelected = 0 -- 1059
			end -- 1059
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1059
				local idx = __TS__ParseInt( -- 1062
					string.sub(zoneTap, 8), -- 1062
					10 -- 1062
				) -- 1062
				if idx >= 0 and idx < #trial.offers then -- 1062
					p:chooseTalent(idx) -- 1064
				end -- 1064
			elseif pick > 0 then -- 1064
				p:chooseTalent(pick - 1) -- 1067
			else -- 1067
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1069
				if delta ~= 0 then -- 1069
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1073
				end -- 1073
				if input.talentConfirm or input.navConfirm then -- 1073
					p:chooseTalent(trialTalentSelected) -- 1076
				end -- 1076
			end -- 1076
			input:consumeEdges() -- 1079
			clock:reset() -- 1080
			renderCampaign(frameDt, p) -- 1081
			return -- 1082
		end -- 1082
	end -- 1082
	if input.retry.pressed then -- 1082
		input.retry.pressed = false -- 1087
		input:consumeEdges() -- 1088
		play = nil -- 1090
		ensurePlay() -- 1091
		return -- 1092
	end -- 1092
	if input.pause.pressed or p.paused and input.navBack then -- 1092
		input.pause.pressed = false -- 1095
		p.paused = not p.paused -- 1096
		if fe ~= nil then -- 1096
			fe.audio:playUi(p.paused and "ui:pause_open" or "ui:pause_close", p.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 1097
		end -- 1097
		clock:reset() -- 1098
		input:consumeEdges() -- 1099
	end -- 1099
	if p.paused then -- 1099
		renderCampaign(frameDt, p) -- 1102
		return -- 1103
	end -- 1103
	local steps = clock:advance(frameDt) -- 1106
	local i = 0 -- 1107
	do -- 1107
		i = 0 -- 1108
		while i < steps do -- 1108
			input:beginStep(i == 0) -- 1109
			p:update(STEP, input) -- 1110
			input:endStep() -- 1111
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1111
				break -- 1113
			end -- 1113
			i = i + 1 -- 1108
		end -- 1108
	end -- 1108
	if p.wantRoom ~= "" then -- 1108
		local key = p.wantRoom -- 1118
		p.wantRoom = "" -- 1119
		local idx = -1 -- 1120
		local j = 0 -- 1121
		do -- 1121
			j = 0 -- 1122
			while j < #CAMPAIGN_ROOMS do -- 1122
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1122
					idx = j -- 1124
				end -- 1124
				j = j + 1 -- 1122
			end -- 1122
		end -- 1122
		if idx >= 0 then -- 1122
			current = idx -- 1128
			play = nil -- 1129
			ensurePlay() -- 1130
		end -- 1130
		return -- 1132
	end -- 1132
	renderCampaign(frameDt, p) -- 1134
end -- 1134
function goalLabel(goal) -- 1137
	if goal == "dock_cart" then -- 1137
		return "推车入窝并抬闩" -- 1139
	end -- 1139
	if goal == "raise_latch" then -- 1139
		return "抬闩开侧门" -- 1142
	end -- 1142
	return "到段出口" -- 1144
end -- 1144
function renderCampaign(frameDt, p) -- 1148
	if fe ~= nil and input ~= nil then -- 1148
		local ____opt_76 = run and run.trial -- 1148
		local offers = ____opt_76 and #____opt_76.offers or 0 -- 1151
		local ____p_paused_80 -- 1152
		if p.paused then -- 1152
			____p_paused_80 = nil -- 1152
		else -- 1152
			____p_paused_80 = fe.adapter:sample(p) -- 1152
		end -- 1152
		local ev = ____p_paused_80 -- 1152
		fe:renderPlay( -- 1153
			frameDt, -- 1153
			p, -- 1153
			input, -- 1153
			stageVp.stageW, -- 1153
			stageVp.stageH, -- 1153
			true, -- 1153
			ev -- 1153
		) -- 1153
		fe:syncTrialAudio(frameDt, p, offers, ev) -- 1154
	end -- 1154
	drawCampaignHud(p) -- 1156
end -- 1156
function drawCampaignHud(p) -- 1160
	local h = stageVp.stageH -- 1161
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1162
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1163
	local room = CAMPAIGN_ROOMS[current + 1] -- 1164
	local c = room.campaign -- 1165
	local r = run -- 1166
	local trial = r and r.trial -- 1167
	local gpMode = input ~= nil and input:isGamepadMode() -- 1168
	local touchMode = input ~= nil and input:isTouchMode() -- 1169
	local line = room.name -- 1172
	if trial == nil then -- 1172
		if c ~= nil then -- 1172
			line = (((line .. "  · 目标 ") .. goalLabel(c.goal)) .. "  · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0)) -- 1175
		end -- 1175
		if p.paused then -- 1175
			line = line .. "  · 已暂停" -- 1177
		end -- 1177
	else -- 1177
		line = (((((("护送试炼 · " .. room.name) .. "  · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. "  · ") .. mmss(r == nil and 0 or r.ticks) -- 1179
		if p.paused then -- 1179
			line = line .. "  · 暂停" -- 1180
		elseif trial.lost then -- 1180
			line = line .. "  · 护送失败" -- 1181
		elseif r ~= nil and r.finished then -- 1181
			line = line .. "  · 护送完成" -- 1182
		elseif #trial.offers > 0 then -- 1182
			line = line .. "  · 选择本段本领" -- 1183
		elseif c ~= nil then -- 1183
			line = line .. "  · " .. goalLabel(c.goal) -- 1184
		end -- 1184
	end -- 1184
	if campaignHud ~= nil then -- 1184
		campaignHud.text = line -- 1187
		campaignHud.position = Vec2(stageVp.stageW * 0.5, h - 12 - safeT) -- 1188
		campaignHud.visible = true -- 1189
	end -- 1189
	if campaignSub == nil then -- 1189
		return -- 1193
	end -- 1193
	local sub = p.flash -- 1195
	if trial ~= nil then -- 1195
		if trial.lost or r ~= nil and r.finished then -- 1195
			sub = gpMode and "A 再开一局 · START 返回标题" or (touchMode and "点下方按钮再开或返回标题" or "R 再开一局 · Esc 返回标题") -- 1198
		elseif p.paused then -- 1198
			sub = gpMode and "START 继续 · 长按 BACK 重开 · Y 返回标题" or (touchMode and "点下方按钮继续 / 重开 / 返回标题" or "Esc 继续 · R 重新开局") -- 1200
		elseif #trial.offers > 0 then -- 1200
			sub = table.concat( -- 1202
				__TS__ArrayMap( -- 1202
					trial.offers, -- 1202
					function(____, talent, index) -- 1202
						local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1203
						return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1204
					end -- 1202
				), -- 1202
				"　" -- 1205
			) -- 1205
		elseif sub == "" and r ~= nil then -- 1205
			sub = r.joined and "小满跟随" or "小满等待" -- 1207
		end -- 1207
	end -- 1207
	campaignSub.text = sub -- 1210
	campaignSub.position = Vec2(stageVp.stageW * 0.5, 14 + stageVp.safeUi.bottom * stageVp.uiScale) -- 1211
	campaignSub.visible = sub ~= "" -- 1212
end -- 1212
function tickFrontend(frameDt) -- 1215
	if fe == nil or input == nil then -- 1215
		return -- 1217
	end -- 1217
	if fe.screen ~= "play" then -- 1217
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1222
		input:consumeEdges() -- 1223
		if act.type == "splashDone" then -- 1223
			fe.menus:resetInput() -- 1225
			fe.screen = "title" -- 1226
		elseif act.type == "trial" then -- 1226
			startTrial() -- 1228
		elseif act.type == "continue" then -- 1228
			if continueOfficialStory() == nil then -- 1228
				enterPlayRoom( -- 1231
					officialStartIndex(), -- 1231
					"official", -- 1231
					true -- 1231
				) -- 1231
			end -- 1231
		elseif act.type == "start" then -- 1231
			clearSession() -- 1235
			refreshTitleSessionFlag() -- 1236
			enterPlayRoom( -- 1237
				officialStartIndex(), -- 1237
				"official", -- 1237
				true -- 1237
			) -- 1237
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1237
			enterPlayRoom(act.roomIndex, "chapter") -- 1239
		elseif act.type == "openChapters" then -- 1239
			fe.menus:openChapters() -- 1241
			fe.screen = "chapters" -- 1242
		elseif act.type == "openControls" then -- 1242
			fe.menus:resetInput() -- 1244
			fe.screen = "controls" -- 1245
		elseif act.type == "openHistory" then -- 1245
			fe.menus:openHistory(true) -- 1247
			fe.screen = "history" -- 1248
		elseif act.type == "backEpilogue" then -- 1248
			fe.menus:resetInput() -- 1250
			fe.screen = "epilogue" -- 1251
		elseif act.type == "replayStory" then -- 1251
			clearSession() -- 1253
			refreshTitleSessionFlag() -- 1254
			enterPlayRoom( -- 1255
				officialStartIndex(), -- 1255
				"official", -- 1255
				true -- 1255
			) -- 1255
		elseif act.type == "backTitle" then -- 1255
			fe.menus:resetInput() -- 1257
			fe.screen = "title" -- 1258
		elseif act.type == "backPause" then -- 1258
			fe.menus:resetInput() -- 1260
			fe.screen = "play" -- 1261
		elseif act.type == "quit" then -- 1261
			quitGame() -- 1263
		end -- 1263
		return -- 1265
	end -- 1265
	if play == nil then -- 1265
		ensurePlay() -- 1270
	end -- 1270
	if play == nil then -- 1270
		return -- 1273
	end -- 1273
	local p = play -- 1275
	p.aimX = input.mx -- 1277
	p.aimY = input.my -- 1278
	local zoneTap = input.touchZoneTap -- 1280
	input.touchZoneTap = "" -- 1281
	local offers = p:getStoryTalentOffers() -- 1283
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1283
		if fe.hud.talentSelected >= #offers then -- 1283
			fe.hud.talentSelected = 0 -- 1286
		end -- 1286
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1286
			local idx = __TS__ParseInt( -- 1289
				string.sub(zoneTap, 8), -- 1289
				10 -- 1289
			) -- 1289
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1289
				input.fire.pressed = false -- 1291
			end -- 1291
		else -- 1291
			if input.talentDelta ~= 0 then -- 1291
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1295
				input.talentDelta = 0 -- 1296
			end -- 1296
			if input.talentConfirm then -- 1296
				p:chooseTalent(fe.hud.talentSelected) -- 1299
				input.talentConfirm = false -- 1300
				input.fire.pressed = false -- 1301
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1301
				input.fire.pressed = false -- 1304
			end -- 1304
		end -- 1304
	end -- 1304
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1304
		if input.navConfirm then -- 1304
			input.interact.pressed = true -- 1312
		end -- 1312
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1312
			flushProfile() -- 1315
			if p.run.source == "official" and hasSessionSave() then -- 1315
				clearSession() -- 1317
				refreshTitleSessionFlag() -- 1318
			end -- 1318
			fe.audio:stopRoomTransient() -- 1320
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1321
			fe.screen = "epilogue" -- 1325
			input:clearTransient(true) -- 1326
			input:consumeEdges() -- 1327
			return -- 1328
		end -- 1328
	end -- 1328
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1328
		p:closeCraftBench() -- 1333
		input:consumeEdges() -- 1334
		return -- 1335
	end -- 1335
	if not p.paused and input.pause.pressed then -- 1335
		p.paused = true -- 1338
		p.aimHold = 0 -- 1339
		p.bottleAimX = -1 -- 1340
		saveCurrentSession() -- 1341
		fe.menus:openPause() -- 1342
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1343
		input:clearTransient(true) -- 1344
		input:consumeEdges() -- 1345
	end -- 1345
	if p.paused then -- 1345
		clock:reset() -- 1350
		local pauseAct = fe:renderPlay( -- 1351
			frameDt, -- 1351
			p, -- 1351
			input, -- 1351
			stageVp.stageW, -- 1351
			stageVp.stageH -- 1351
		) -- 1351
		input:consumeEdges() -- 1352
		if pauseAct.type == "resume" then -- 1352
			p.paused = false -- 1354
		elseif pauseAct.type == "retry" then -- 1354
			ensurePlay({checkpoint = p.checkpoint}) -- 1356
		elseif pauseAct.type == "openChapters" then -- 1356
			fe.audio:stopRoomTransient() -- 1358
			fe.audio:setPaused(false) -- 1359
			fe.menus:openChapters(current) -- 1360
			fe.screen = "chapters" -- 1361
		elseif pauseAct.type == "toggleFullscreen" then -- 1361
			toggleFullscreen() -- 1363
		elseif pauseAct.type == "quit" then -- 1363
			quitGame() -- 1365
		elseif pauseAct.type == "toTitle" then -- 1365
			saveCurrentSession() -- 1367
			refreshTitleSessionFlag() -- 1368
			fe.menus:resetInput() -- 1369
			fe.screen = "title" -- 1370
		end -- 1370
		return -- 1372
	end -- 1372
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1375
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1376
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1376
		input:consumeEdges() -- 1379
		ensurePlay({checkpoint = p.checkpoint}) -- 1381
		return -- 1382
	end -- 1382
	local steps = clock:advance(frameDt) -- 1385
	local i = 0 -- 1386
	do -- 1386
		i = 0 -- 1387
		while i < steps do -- 1387
			input:beginStep(i == 0) -- 1388
			p:update(STEP, input) -- 1389
			input:endStep() -- 1390
			if p.wantRoom ~= "" then -- 1390
				break -- 1392
			end -- 1392
			i = i + 1 -- 1387
		end -- 1387
	end -- 1387
	if p.wantRoom ~= "" then -- 1387
		local key = p.wantRoom -- 1398
		p.wantRoom = "" -- 1399
		local idx = -1 -- 1400
		local j = 0 -- 1401
		do -- 1401
			j = 0 -- 1402
			while j < #ROOMS do -- 1402
				if ROOMS[j + 1].key == key then -- 1402
					idx = j -- 1404
				end -- 1404
				j = j + 1 -- 1402
			end -- 1402
		end -- 1402
		if idx >= 0 then -- 1402
			flushProfile() -- 1411
			local leaving = p:drainEvents() -- 1412
			if p.restartStory then -- 1412
				if storyRun ~= nil and storyRun.source == "official" then -- 1412
					clearSession() -- 1416
					refreshTitleSessionFlag() -- 1417
				end -- 1417
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1419
				storyRun = createRun(20261124, nextSource, profile) -- 1420
			end -- 1420
			current = idx -- 1422
			ensurePlay() -- 1423
			local fresh = play -- 1424
			if fresh ~= nil then -- 1424
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1424
					fresh.phase = "prologue-wake" -- 1427
				end -- 1427
				fresh:adoptEvents(leaving) -- 1429
			end -- 1429
			if not p.restartStory then -- 1429
				saveCurrentSession() -- 1432
			end -- 1432
			clock:reset() -- 1434
			dirty = true -- 1435
		end -- 1435
		return -- 1437
	end -- 1437
	flushProfile() -- 1441
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1441
		clearSession() -- 1443
		refreshTitleSessionFlag() -- 1444
	elseif p.sessionDirty then -- 1444
		saveCurrentSession() -- 1446
	end -- 1446
	fe:renderPlay( -- 1448
		frameDt, -- 1448
		p, -- 1448
		input, -- 1448
		stageVp.stageW, -- 1448
		stageVp.stageH -- 1448
	) -- 1448
end -- 1448
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
local function pickByIndex(idx, source) -- 714
	if source == nil then -- 714
		source = "debug" -- 714
	end -- 714
	if mode == 2 then -- 714
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 714
			return -- 717
		end -- 717
		current = idx -- 719
		play = nil -- 720
		clock:reset() -- 721
		ensurePlay() -- 722
		return -- 723
	end -- 723
	if idx < 0 or idx >= #ROOMS then -- 723
		return -- 726
	end -- 726
	flushProfile() -- 728
	if storyRun ~= nil then -- 728
		storyRun.source = source -- 730
	end -- 730
	current = idx -- 732
	dirty = true -- 733
	play = nil -- 734
	clock:reset() -- 735
	if mode == 1 then -- 735
		if fe ~= nil then -- 735
			fe.screen = "play" -- 738
		end -- 738
		ensurePlay() -- 740
	end -- 740
end -- 714
return ____exports -- 714