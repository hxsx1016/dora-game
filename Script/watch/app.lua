-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
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
local ____depth = require("Script.watch.depth") -- 13
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 13
local ____play = require("Script.watch.play") -- 14
local Play = ____play.Play -- 14
local ____clock = require("Script.watch.clock") -- 15
local STEP = ____clock.STEP -- 15
local StepClock = ____clock.StepClock -- 15
local ____aim_assist = require("Script.watch.aim_assist") -- 16
local collectPlayAimTargets = ____aim_assist.collectPlayAimTargets -- 16
local collectTrialAimTargets = ____aim_assist.collectTrialAimTargets -- 16
local ____gamepad = require("Script.watch.gamepad") -- 18
local GamepadRouter = ____gamepad.GamepadRouter -- 18
local ____platform = require("Script.watch.platform") -- 19
local canQuitApp = ____platform.canQuitApp -- 21
local canToggleFullscreen = ____platform.canToggleFullscreen -- 22
local computeStageViewport = ____platform.computeStageViewport -- 23
local getReleaseConfig = ____platform.getReleaseConfig -- 24
local isReleaseMode = ____platform.isReleaseMode -- 25
local ____touch = require("Script.watch.touch") -- 27
local TouchRouter = ____touch.TouchRouter -- 27
local ____frontend = require("Script.watch.fe.frontend") -- 28
local WatchFrontend = ____frontend.WatchFrontend -- 28
local ____run = require("Script.watch.run") -- 29
local createRun = ____run.createRun -- 29
local createStoryTalents = ____run.createStoryTalents -- 29
local createTrial = ____run.createTrial -- 29
local mmss = ____run.mmss -- 29
local talentNames = ____run.talentNames -- 29
local ____save = require("Script.watch.save") -- 30
local emptySave = ____save.emptySave -- 30
local loadSave = ____save.loadSave -- 30
local saveSave = ____save.saveSave -- 30
local setSaveFile = ____save.setSaveFile -- 30
local getSaveFile = ____save.getSaveFile -- 30
local markProfilePending = ____save.markProfilePending -- 31
local flushSaveProfile = ____save.flushProfile -- 31
local clearProfilePending = ____save.clearProfilePending -- 31
local profilePending = ____save.profilePending -- 31
local loadSession = ____save.loadSession -- 32
local saveSession = ____save.saveSession -- 32
local clearSession = ____save.clearSession -- 32
local hasSessionSave = ____save.hasSessionSave -- 32
local setSessionFile = ____save.setSessionFile -- 32
local getSessionFile = ____save.getSessionFile -- 32
local ____touch_controls = require("Script.watch.fe.ui.touch_controls") -- 34
local TouchControls = ____touch_controls.TouchControls -- 34
local ____control_prompts = require("Script.watch.fe.ui.control_prompts") -- 35
local isCutsceneBlockingPlay = ____control_prompts.isCutsceneBlockingPlay -- 35
function isReleaseBuild() -- 98
	return isReleaseMode() -- 99
end -- 99
function onFirstUserGesture() -- 102
	if audioUnlocked or fe == nil then -- 102
		return -- 104
	end -- 104
	audioUnlocked = true -- 106
	fe.audio:unlockAndResyncAfterGesture() -- 107
end -- 107
function toggleFullscreen() -- 110
	if not canToggleFullscreen() then -- 110
		return false -- 112
	end -- 112
	do -- 112
		local function ____catch() -- 112
			return true, false -- 119
		end -- 119
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 119
			local next = not App.fullScreen -- 115
			App.fullScreen = next -- 116
			return true, next -- 117
		end) -- 117
		if not ____try then -- 117
			____hasReturned, ____returnValue = ____catch() -- 117
		end -- 117
		if ____hasReturned then -- 117
			return ____returnValue -- 114
		end -- 114
	end -- 114
end -- 114
function quitGame() -- 123
	flushProfile() -- 124
	saveCurrentSession() -- 125
	if input ~= nil then -- 125
		input:clearTransient(false) -- 126
	end -- 126
	if fe ~= nil then -- 126
		fe.audio:stopRoomTransient() -- 128
	end -- 128
	if not canQuitApp() then -- 128
		current = 0 -- 132
		play = nil -- 133
		run = nil -- 134
		setMode(1) -- 135
		if fe ~= nil then -- 135
			fe.audio:stopRoomTransient() -- 137
			fe.screen = "title" -- 138
			fe.menus:resetInput() -- 139
		end -- 139
		return -- 141
	end -- 141
	App:shutdown() -- 143
end -- 143
function canSaveSession() -- 215
	if mode ~= 1 or play == nil or storyRun == nil then -- 215
		return false -- 217
	end -- 217
	if storyRun.source ~= "official" or play.run.finished then -- 217
		return false -- 220
	end -- 220
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 220
		return false -- 223
	end -- 223
	return true -- 225
end -- 225
function refreshTitleSessionFlag() -- 228
	if fe ~= nil then -- 228
		fe.menus.hasSession = hasSessionSave() -- 230
	end -- 230
end -- 230
function saveCurrentSession() -- 234
	if not canSaveSession() or play == nil then -- 234
		return false -- 236
	end -- 236
	play.sessionDirty = false -- 238
	local ok = saveSession(play:exportSession()) -- 239
	refreshTitleSessionFlag() -- 240
	return ok -- 241
end -- 241
function continueOfficialStory() -- 244
	local res = loadSession() -- 245
	if res.status ~= "ok" or res.state == nil then -- 245
		refreshTitleSessionFlag() -- 247
		return nil -- 248
	end -- 248
	local s = res.state -- 250
	local idx = roomIndexByKey(s.roomKey) -- 251
	if ROOMS[idx + 1].key ~= s.roomKey then -- 251
		return nil -- 253
	end -- 253
	storyRun = createRun(s.seed, "official", profile) -- 255
	storyRun.checkpoint = s.checkpoint -- 256
	storyRun.story.route = s.route -- 257
	storyRun.story.hp = s.hp -- 258
	storyRun.story.maxHp = s.maxHp -- 259
	storyRun.story.hpAtGate = s.hpAtGate -- 260
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 261
	storyRun.story.settled = s.settled -- 262
	storyRun.story.phase = s.phase -- 263
	storyRun.story.countTick = s.countTick -- 264
	storyRun.story.phaseTick = s.phaseTick -- 265
	storyRun.story.handTicks = s.handTicks -- 266
	storyRun.story.handDone = s.handDone -- 267
	storyRun.story.lineSaid = s.lineSaid -- 268
	storyRun.story.tied = s.tied -- 269
	storyRun.story.carry = s.carry -- 270
	storyRun.story.escortDone = s.escortDone -- 271
	storyRun.story.craftedWeapon = s.craftedWeapon -- 272
	storyRun.story.equippedWeapon = s.equippedWeapon -- 273
	storyRun.inventory.wood = s.wood -- 274
	storyRun.inventory.bell = s.bell -- 275
	storyRun.inventory.scrap = s.scrap -- 276
	storyRun.inventory.wedge = s.wedge -- 277
	storyRun.inventory.ammo = s.ammo -- 278
	storyRun.inventory.shield = s.shield -- 279
	storyRun.inventory.pass = s.pass -- 280
	storyRun.inventory.quickbelt = s.quickbelt -- 281
	local k = 0 -- 282
	do -- 282
		k = 0 -- 283
		while k < #s.taken do -- 283
			storyRun.taken[s.taken[k + 1]] = true -- 284
			k = k + 1 -- 283
		end -- 283
	end -- 283
	do -- 283
		k = 0 -- 286
		while k < #s.segments do -- 286
			storyRun.story.segments[s.segments[k + 1]] = true -- 287
			k = k + 1 -- 286
		end -- 286
	end -- 286
	if s.campaignRoute ~= nil then -- 286
		storyRun.route = s.campaignRoute -- 290
	end -- 290
	if s.joined ~= nil then -- 290
		storyRun.joined = s.joined -- 293
	end -- 293
	if s.c1Latch ~= nil then -- 293
		storyRun.c1Latch = s.c1Latch -- 296
	end -- 296
	if s.c2Latch ~= nil then -- 296
		storyRun.c2Latch = s.c2Latch -- 299
	end -- 299
	if s.props ~= nil then -- 299
		do -- 299
			k = 0 -- 302
			while k < #s.props do -- 302
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 303
				local pid = parts[1] -- 304
				if pid ~= nil and pid ~= "" then -- 304
					local ____storyRun_props_16 = storyRun.props -- 306
					local ____temp_12 -- 307
					if parts[2] == nil then -- 307
						____temp_12 = true -- 307
					else -- 307
						____temp_12 = parts[2] == "1" -- 307
					end -- 307
					local ____temp_14 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 308
					local ____temp_15 = parts[4] == "1" -- 309
					local ____temp_13 -- 310
					if parts[5] == "1" then -- 310
						____temp_13 = true -- 310
					else -- 310
						____temp_13 = nil -- 310
					end -- 310
					____storyRun_props_16[pid] = {broken = ____temp_12, hp = ____temp_14, wedge = ____temp_15, revealed = ____temp_13} -- 306
				end -- 306
				k = k + 1 -- 302
			end -- 302
		end -- 302
	end -- 302
	local stTalents = createStoryTalents(s.seed) -- 315
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 315
		stTalents.randomState = s.talentSeed -- 317
	end -- 317
	stTalents.room = s.talentRoom or "" -- 319
	stTalents.ranks.vitality = s.talentVitality or 0 -- 320
	stTalents.ranks.reload = s.talentReload or 0 -- 321
	stTalents.ranks.guard = s.talentGuard or 0 -- 322
	stTalents.ranks.craft = s.talentCraft or 0 -- 323
	if s.talentOffers ~= nil then -- 323
		do -- 323
			k = 0 -- 325
			while k < #s.talentOffers do -- 325
				local t = s.talentOffers[k + 1] -- 326
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 326
					local ____stTalents_offers_17 = stTalents.offers -- 326
					____stTalents_offers_17[#____stTalents_offers_17 + 1] = t -- 328
				end -- 328
				k = k + 1 -- 325
			end -- 325
		end -- 325
	end -- 325
	storyRun.story.talents = stTalents -- 332
	current = idx -- 333
	setMode(1) -- 334
	if fe ~= nil then -- 334
		fe.screen = "play" -- 336
	end -- 336
	play = nil -- 338
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 339
	local cur = play -- 340
	if cur ~= nil then -- 340
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 340
			cur.cartAxle = s.cartAxle -- 343
			cur.cartDocked = s.cartDocked -- 344
		end -- 344
		if s.playerX ~= nil and s.playerX >= 0 then -- 344
			cur.player.x = math.max( -- 347
				cur.room.minX + 16, -- 347
				math.min(cur.room.maxX - 16, s.playerX) -- 347
			) -- 347
			cur.player.y = math.max(0, s.playerY or 0) -- 348
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 348
				cur.player.depth = math.max( -- 350
					cur.room.depth.min, -- 350
					math.min(cur.room.depth.max, s.playerDepth) -- 350
				) -- 350
			end -- 350
		end -- 350
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 350
			cur.gateTick = s.gateTick -- 354
		end -- 354
		if cur.room.key == "village" then -- 354
			if s.hasBottle == true then -- 354
				cur.hasBottle = true -- 357
			end -- 357
			if s.villagePassed == true then -- 357
				cur.passed = true -- 358
			end -- 358
		end -- 358
	end -- 358
	return play -- 361
end -- 361
function place(lb, x, y, ax, ay) -- 379
	if lb == nil then -- 379
		return -- 381
	end -- 381
	lb.position = Vec2(x, y) -- 383
	lb.anchor = Vec2(ax, ay) -- 384
	lb.visible = true -- 385
end -- 385
function setMode(nextMode) -- 727
	mode = nextMode -- 728
	if grayboxLayer ~= nil then -- 728
		grayboxLayer.visible = mode == 0 -- 730
	end -- 730
	if fe ~= nil then -- 730
		fe:setVisible(mode == 1) -- 733
	end -- 733
	if campaignLayer ~= nil then -- 733
		campaignLayer.visible = mode == 2 -- 736
	end -- 736
	dirty = true -- 738
	clock:reset() -- 739
end -- 739
function flushProfile() -- 746
	local cur = play -- 747
	if cur ~= nil and cur.archiveDirty then -- 747
		cur.archiveDirty = false -- 749
		markProfilePending(profile) -- 750
	end -- 750
	local ok = flushSaveProfile() -- 752
	if not ok and cur ~= nil then -- 752
		cur.archiveDirty = true -- 754
	end -- 754
	return ok -- 756
end -- 756
function officialStartIndex() -- 760
	local mp = profile.museumPhase -- 761
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 762
	return inMuseum and roomIndexByKey("museum") or 0 -- 763
end -- 763
function roomIndexByKey(key) -- 766
	local i = 0 -- 767
	do -- 767
		i = 0 -- 768
		while i < #ROOMS do -- 768
			if ROOMS[i + 1].key == key then -- 768
				return i -- 770
			end -- 770
			i = i + 1 -- 768
		end -- 768
	end -- 768
	return 0 -- 773
end -- 773
function enterPlayRoom(idx, source, fresh) -- 776
	if source == nil then -- 776
		source = "debug" -- 776
	end -- 776
	if fresh == nil then -- 776
		fresh = false -- 776
	end -- 776
	current = idx -- 777
	setMode(1) -- 778
	if fe ~= nil then -- 778
		fe.screen = "play" -- 780
	end -- 780
	play = nil -- 782
	if fresh or source == "chapter" or storyRun == nil then -- 782
		storyRun = createRun(20261124, source, profile) -- 785
	else -- 785
		storyRun.source = source -- 787
	end -- 787
	ensurePlay() -- 789
	local firstPlay = play -- 791
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 791
		firstPlay.phase = "prologue-wake" -- 793
	end -- 793
	flushProfile() -- 795
end -- 795
function pickByIndex(idx, source) -- 798
	if source == nil then -- 798
		source = "debug" -- 798
	end -- 798
	if mode == 2 then -- 798
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 798
			return -- 801
		end -- 801
		current = idx -- 803
		play = nil -- 804
		clock:reset() -- 805
		ensurePlay() -- 806
		return -- 807
	end -- 807
	if idx < 0 or idx >= #ROOMS then -- 807
		return -- 810
	end -- 810
	flushProfile() -- 812
	if storyRun ~= nil then -- 812
		storyRun.source = source -- 814
	end -- 814
	current = idx -- 816
	dirty = true -- 817
	play = nil -- 818
	clock:reset() -- 819
	if mode == 1 then -- 819
		if fe ~= nil then -- 819
			fe.screen = "play" -- 822
		end -- 822
		ensurePlay() -- 824
	end -- 824
end -- 824
function applySize() -- 828
	if root == nil then -- 828
		return -- 830
	end -- 830
	root.size = Size(viewW, viewH) -- 832
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 833
	stageVp = computeStageViewport(viewW, viewH) -- 834
	if input ~= nil then -- 834
		input:setStageViewport(stageVp) -- 836
	end -- 836
	if fe ~= nil then -- 836
		fe:setStagePlacement(stageVp) -- 839
	end -- 839
	if campaignLayer ~= nil then -- 839
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 842
	end -- 842
	if grayboxLayer ~= nil then -- 842
		grayboxLayer.position = Vec2(0, 0) -- 845
	end -- 845
end -- 845
function syncFrameAdapters(frameDt) -- 849
	if input == nil then -- 849
		return -- 851
	end -- 851
	local p = play -- 853
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 854
	local isTrialMode = mode == 2 and p ~= nil -- 855
	local gameplayActive = isPlayMode or isTrialMode -- 856
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 858
		p, -- 860
		stageVp.stageW, -- 860
		stageVp.stageH, -- 860
		input:isTouchMode() -- 860
	) or ({}) -- 860
	if touchControls ~= nil and touchRouter ~= nil then -- 860
		local isFs = false -- 864
		if canToggleFullscreen() then -- 864
			do -- 864
				local function ____catch() -- 864
					isFs = false -- 869
				end -- 869
				local ____try = pcall(function() -- 869
					isFs = App.fullScreen -- 867
				end) -- 867
				if not ____try then -- 867
					____catch() -- 867
				end -- 867
			end -- 867
		end -- 867
		local ____touchControls_51 = touchControls -- 872
		local ____touchControls_syncContext_52 = touchControls.syncContext -- 872
		local ____stageVp_44 = stageVp -- 873
		local ____mode_45 = mode -- 874
		local ____temp_46 = fe ~= nil and fe.screen or "title" -- 875
		local ____run_47 = run -- 877
		local ____temp_48 = fe ~= nil and fe.cam or nil -- 878
		local ____input_49 = input -- 879
		local ____touchRouter_50 = touchRouter -- 880
		local ____temp_42 -- 881
		if fe ~= nil then -- 881
			____temp_42 = fe.contract:isAssistHintsEnabled() -- 881
		else -- 881
			____temp_42 = false -- 881
		end -- 881
		local ____temp_43 -- 882
		if fe ~= nil then -- 882
			____temp_43 = fe.audio:isAllMuted() -- 882
		else -- 882
			____temp_43 = false -- 882
		end -- 882
		____touchControls_syncContext_52(____touchControls_51, { -- 872
			viewport = ____stageVp_44, -- 873
			mode = ____mode_45, -- 874
			screen = ____temp_46, -- 875
			play = p, -- 876
			run = ____run_47, -- 877
			cam = ____temp_48, -- 878
			input = ____input_49, -- 879
			router = ____touchRouter_50, -- 880
			assistHintsEnabled = ____temp_42, -- 881
			isMuted = ____temp_43, -- 882
			isFullscreen = isFs, -- 883
			storyTalentBoxes = storyTalentBoxes, -- 884
			dt = frameDt -- 885
		}) -- 885
	end -- 885
	if gamepadRouter ~= nil then -- 885
		local trial = run and run.trial -- 890
		local trialEnded = isTrialMode and trial ~= nil and (trial.lost or (run and run.finished) == true) -- 891
		local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 892
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 893
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 896
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 897
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #storyTalentBoxes or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 898
		local ____temp_57 -- 901
		if isPlayMode and p ~= nil then -- 901
			____temp_57 = isCutsceneBlockingPlay(p) -- 901
		else -- 901
			____temp_57 = false -- 901
		end -- 901
		local cutsceneBlocking = ____temp_57 -- 901
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 902
		local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 904
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 905
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 907
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 909
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 912
		local playerScreenX = stageVp.stageW * 0.5 -- 914
		local playerScreenY = stageVp.stageH * 0.38 -- 915
		if p ~= nil then -- 915
			if isPlayMode and fe ~= nil then -- 915
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 918
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 919
			else -- 919
				local vz = p.view.zoom > 0 and p.view.zoom or 1 -- 922
				playerScreenX = stageVp.stageW * 0.5 + (p.player.x + p.player.facing * 8 - p.cam.x) * vz -- 923
				playerScreenY = stageVp.stageH * 0.5 + (p.player.y + p.player.h * 0.72 + p.player.depth * DEPTH_Y_SCALE - p.cam.y) * vz -- 924
			end -- 924
		end -- 924
		local enemyTargets = canShoot and p ~= nil and (isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or collectTrialAimTargets(p, stageVp.stageW, stageVp.stageH)) or ({}) -- 928
		local gpCtx = { -- 934
			stageW = stageVp.stageW, -- 935
			stageH = stageVp.stageH, -- 936
			uiScale = stageVp.uiScale, -- 937
			modal = modal, -- 938
			gameplayActive = gameplayActive, -- 939
			reloadActive = reloadActive, -- 940
			craftActive = craftActive, -- 941
			talentOfferCount = talentOfferCount, -- 942
			childMode = p ~= nil and p.childMode, -- 943
			allowDepth = allowDepth, -- 944
			canShoot = canShoot, -- 945
			canBottleAim = canBottleAim, -- 946
			playerRolling = p ~= nil and p.player.rollT > 0, -- 947
			inLowArch = inLowArch, -- 948
			inTowerEnd = inTowerEnd, -- 949
			playerFacing = p ~= nil and p.player.facing or 1, -- 950
			playerScreenX = playerScreenX, -- 951
			playerScreenY = playerScreenY, -- 952
			enemyTargets = enemyTargets -- 953
		} -- 953
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 955
	end -- 955
end -- 955
function renderTouchOverlay() -- 959
	if touchControls ~= nil and touchRouter ~= nil then -- 959
		touchControls:render(touchRouter) -- 961
	end -- 961
end -- 961
function tick(frameDt) -- 965
	appClock = appClock + math.min( -- 966
		0.05, -- 966
		math.max(0, frameDt) -- 966
	) -- 966
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 967
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 968
	if w ~= viewW or h ~= viewH then -- 968
		viewW = w -- 970
		viewH = h -- 971
		applySize() -- 972
		dirty = true -- 973
	end -- 973
	if input == nil then -- 973
		return -- 976
	end -- 976
	syncFrameAdapters(frameDt) -- 978
	input:update() -- 979
	if input.userInteracted then -- 979
		onFirstUserGesture() -- 982
	end -- 982
	if input.muteTogglePressed and fe ~= nil then -- 982
		input.muteTogglePressed = false -- 985
		fe.audio:toggleAllMuted() -- 986
	end -- 986
	if input.fullscreenTogglePressed then -- 986
		input.fullscreenTogglePressed = false -- 989
		toggleFullscreen() -- 990
	end -- 990
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 990
		input.artifactTogglePressed = false -- 993
		play:toggleArtifactWeapon() -- 994
	end -- 994
	if input.bottleCanceled and play ~= nil then -- 994
		input.bottleCanceled = false -- 997
		play.aimHold = 0 -- 998
		play.bottleAimX = -1 -- 999
	end -- 999
	if mode == 2 and (run and run.trial) ~= nil then -- 999
		tickCampaign(frameDt) -- 1003
		renderTouchOverlay() -- 1004
		return -- 1005
	end -- 1005
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 1005
		if fe:canPickStoryTalent(play) then -- 1005
			play:chooseTalent(input.pickRoom - 1) -- 1012
		end -- 1012
		input.pickRoom = 0 -- 1014
	end -- 1014
	if isReleaseBuild() then -- 1014
		input.toggleView.pressed = false -- 1018
		input.pickRoom = 0 -- 1019
		input.tab.pressed = false -- 1020
	else -- 1020
		if input.toggleView.pressed then -- 1020
			input.toggleView.pressed = false -- 1024
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 1025
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 1025
				ensurePlay() -- 1027
			end -- 1027
		end -- 1027
		if input.pickRoom ~= 0 then -- 1027
			local idx = input.pickRoom - 1 -- 1033
			input.pickRoom = 0 -- 1034
			pickByIndex(idx) -- 1035
		elseif input.tab.pressed then -- 1035
			input.tab.pressed = false -- 1037
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 1037
				pickByIndex((current + 1) % #ROOMS) -- 1039
			end -- 1039
		end -- 1039
	end -- 1039
	if mode == 2 then -- 1039
		tickCampaign(frameDt) -- 1045
	elseif mode == 1 then -- 1045
		tickFrontend(frameDt) -- 1047
	elseif dirty then -- 1047
		redrawGraybox() -- 1049
		dirty = false -- 1050
	end -- 1050
	renderTouchOverlay() -- 1052
end -- 1052
function registerPlay() -- 1056
	local reg = _G.package.loaded -- 1057
	reg["watch.play"] = play -- 1058
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 1059
	reg["watch.room"] = rooms[current + 1].key -- 1060
end -- 1060
function ensurePlay(resume) -- 1064
	if mode == 2 then -- 1064
		if run == nil then -- 1064
			run = createRun() -- 1067
		end -- 1067
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 1069
	else -- 1069
		if storyRun == nil then -- 1069
			storyRun = createRun(20261124, "debug", profile) -- 1074
		end -- 1074
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1076
	end -- 1076
	registerPlay() -- 1078
	clock:reset() -- 1079
	if fe ~= nil and mode == 1 then -- 1079
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1081
	elseif fe ~= nil and mode == 2 then -- 1081
		fe:resetTrialAudio(play) -- 1083
	end -- 1083
end -- 1083
function startTrial() -- 1087
	current = 0 -- 1088
	trialTalentSelected = 0 -- 1089
	run = createTrial(App.rand) -- 1090
	setMode(2) -- 1091
	ensurePlay() -- 1092
end -- 1092
function tickCampaign(frameDt) -- 1095
	if input == nil then -- 1095
		return -- 1097
	end -- 1097
	if play == nil then -- 1097
		ensurePlay() -- 1100
	end -- 1100
	if play == nil then -- 1100
		return -- 1103
	end -- 1103
	local p = play -- 1105
	p.aimX = input.mx -- 1106
	p.aimY = input.my -- 1107
	local zoneTap = input.touchZoneTap -- 1109
	input.touchZoneTap = "" -- 1110
	local trial = run and run.trial -- 1112
	if trial ~= nil then -- 1112
		local ended = trial.lost or (run and run.finished) == true -- 1114
		local pick = input.pickRoom -- 1115
		input.pickRoom = 0 -- 1116
		if zoneTap == "trial:resume" and p.paused and not ended then -- 1116
			p.paused = false -- 1119
			clock:reset() -- 1120
			input:consumeEdges() -- 1121
			drawCampaign(p) -- 1122
			return -- 1123
		end -- 1123
		if zoneTap == "trial:retry" then -- 1123
			input:consumeEdges() -- 1126
			startTrial() -- 1127
			return -- 1128
		end -- 1128
		if zoneTap == "trial:title" then -- 1128
			input:consumeEdges() -- 1131
			current = 0 -- 1132
			play = nil -- 1133
			run = nil -- 1134
			setMode(1) -- 1135
			if fe ~= nil then -- 1135
				fe.audio:stopRoomTransient() -- 1137
				fe.screen = "title" -- 1138
				fe.menus:resetInput() -- 1139
			end -- 1139
			return -- 1141
		end -- 1141
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1141
			input:consumeEdges() -- 1145
			current = 0 -- 1146
			play = nil -- 1147
			run = nil -- 1148
			setMode(1) -- 1149
			if fe ~= nil then -- 1149
				fe.audio:stopRoomTransient() -- 1151
				fe.screen = "title" -- 1152
				fe.menus:resetInput() -- 1153
			end -- 1153
			return -- 1155
		end -- 1155
		if ended or p.paused and input.retry.pressed then -- 1155
			local restart = input.retry.pressed or ended and input.navConfirm -- 1158
			input:consumeEdges() -- 1159
			if restart then -- 1159
				startTrial() -- 1160
			else -- 1160
				drawCampaign(p) -- 1161
			end -- 1161
			return -- 1162
		end -- 1162
		input.retry.pressed = false -- 1164
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1164
			if trialTalentSelected >= #trial.offers then -- 1164
				trialTalentSelected = 0 -- 1167
			end -- 1167
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1167
				local idx = __TS__ParseInt( -- 1170
					string.sub(zoneTap, 8), -- 1170
					10 -- 1170
				) -- 1170
				if idx >= 0 and idx < #trial.offers then -- 1170
					p:chooseTalent(idx) -- 1172
				end -- 1172
			elseif pick > 0 then -- 1172
				p:chooseTalent(pick - 1) -- 1175
			else -- 1175
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1177
				if delta ~= 0 then -- 1177
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1181
				end -- 1181
				if input.talentConfirm or input.navConfirm then -- 1181
					p:chooseTalent(trialTalentSelected) -- 1184
				end -- 1184
			end -- 1184
			input:consumeEdges() -- 1187
			clock:reset() -- 1188
			if fe ~= nil then -- 1188
				fe:syncTrialAudio(frameDt, p, #trial.offers) -- 1189
			end -- 1189
			drawCampaign(p) -- 1190
			return -- 1191
		end -- 1191
	end -- 1191
	if input.retry.pressed then -- 1191
		input.retry.pressed = false -- 1196
		input:consumeEdges() -- 1197
		play = nil -- 1199
		ensurePlay() -- 1200
		return -- 1201
	end -- 1201
	if input.pause.pressed or p.paused and input.navBack then -- 1201
		input.pause.pressed = false -- 1204
		p.paused = not p.paused -- 1205
		if fe ~= nil then -- 1205
			fe.audio:playUi(p.paused and "ui:pause_open" or "ui:pause_close", p.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 1206
		end -- 1206
		clock:reset() -- 1207
		input:consumeEdges() -- 1208
	end -- 1208
	if p.paused then -- 1208
		if fe ~= nil then -- 1208
			fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1211
		end -- 1211
		drawCampaign(p) -- 1212
		return -- 1213
	end -- 1213
	local steps = clock:advance(frameDt) -- 1216
	local i = 0 -- 1217
	do -- 1217
		i = 0 -- 1218
		while i < steps do -- 1218
			input:beginStep(i == 0) -- 1219
			p:update(STEP, input) -- 1220
			input:endStep() -- 1221
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1221
				break -- 1223
			end -- 1223
			i = i + 1 -- 1218
		end -- 1218
	end -- 1218
	if fe ~= nil then -- 1218
		fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1226
	end -- 1226
	if p.wantRoom ~= "" then -- 1226
		local key = p.wantRoom -- 1229
		p.wantRoom = "" -- 1230
		local idx = -1 -- 1231
		local j = 0 -- 1232
		do -- 1232
			j = 0 -- 1233
			while j < #CAMPAIGN_ROOMS do -- 1233
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1233
					idx = j -- 1235
				end -- 1235
				j = j + 1 -- 1233
			end -- 1233
		end -- 1233
		if idx >= 0 then -- 1233
			current = idx -- 1239
			play = nil -- 1240
			ensurePlay() -- 1241
		end -- 1241
		return -- 1243
	end -- 1243
	drawCampaign(p) -- 1245
end -- 1245
function goalLabel(goal) -- 1248
	if goal == "dock_cart" then -- 1248
		return "推车入窝并抬闩" -- 1250
	end -- 1250
	if goal == "raise_latch" then -- 1250
		return "抬闩开侧门" -- 1253
	end -- 1253
	return "到段出口" -- 1255
end -- 1255
function drawCampaign(p) -- 1258
	if campaignDraw == nil then -- 1258
		return -- 1260
	end -- 1260
	local w = stageVp.stageW -- 1262
	local h = stageVp.stageH -- 1263
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1264
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1265
	p:draw(campaignDraw, w, h) -- 1266
	local room = CAMPAIGN_ROOMS[current + 1] -- 1267
	local c = room.campaign -- 1268
	local r = run -- 1269
	local line = room.name -- 1270
	if c ~= nil then -- 1270
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget * 60) -- 1272
	end -- 1272
	if p.paused then -- 1272
		line = line .. "  · 已暂停 Esc 继续" -- 1276
	end -- 1276
	local trial = r and r.trial -- 1278
	if trial ~= nil and r ~= nil then -- 1278
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 1280
		if p.paused then -- 1280
			line = line .. " · 暂停" -- 1281
		elseif trial.lost then -- 1281
			line = line .. " · 护送失败" -- 1282
		elseif r.finished then -- 1282
			line = line .. " · 护送完成" -- 1283
		elseif #trial.offers > 0 then -- 1283
			line = line .. " · 选择本段本领" -- 1284
		elseif c ~= nil then -- 1284
			line = line .. " · " .. goalLabel(c.goal) -- 1285
		end -- 1285
	end -- 1285
	if campaignHud ~= nil then -- 1285
		campaignHud.text = line -- 1288
		campaignHud.position = Vec2(24 + safeL, h - 14 - safeT) -- 1289
		campaignHud.visible = true -- 1290
	end -- 1290
	if campaignSub ~= nil then -- 1290
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 1293
		if r ~= nil then -- 1293
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 1295
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 1296
		end -- 1296
		if p.flash ~= "" then -- 1296
			sub = (sub .. " · ") .. p.flash -- 1302
		end -- 1302
		if trial ~= nil and r ~= nil then -- 1302
			local gpMode = input ~= nil and input:isGamepadMode() -- 1305
			local touchMode = input ~= nil and input:isTouchMode() -- 1306
			if trial.lost or r.finished then -- 1306
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · A 再开一局 · START 返回标题" or (touchMode and " · 点下方按钮再开或返回标题" or " · R 再开一局 · Esc 返回标题")) -- 1308
			elseif p.paused then -- 1308
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · START 继续 · 长按BACK 重开 · Y 返回标题" or (touchMode and " · 点下方按钮继续/重开/返回标题" or " · Esc 继续 · R 重新开局 · E 返回标题")) -- 1310
			elseif #trial.offers > 0 then -- 1310
				sub = table.concat( -- 1312
					__TS__ArrayMap( -- 1312
						trial.offers, -- 1312
						function(____, talent, index) -- 1312
							local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1313
							return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1314
						end -- 1312
					), -- 1312
					"　" -- 1315
				) -- 1315
			else -- 1315
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 1317
			end -- 1317
		end -- 1317
		campaignSub.text = sub -- 1320
		campaignSub.position = Vec2(24 + safeL, h - 44 - safeT) -- 1321
		campaignSub.visible = true -- 1322
	end -- 1322
end -- 1322
function tickFrontend(frameDt) -- 1326
	if fe == nil or input == nil then -- 1326
		return -- 1328
	end -- 1328
	if fe.screen ~= "play" then -- 1328
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1333
		input:consumeEdges() -- 1334
		if act.type == "splashDone" then -- 1334
			fe.menus:resetInput() -- 1336
			fe.screen = "title" -- 1337
		elseif act.type == "trial" then -- 1337
			startTrial() -- 1339
		elseif act.type == "continue" then -- 1339
			if continueOfficialStory() == nil then -- 1339
				enterPlayRoom( -- 1342
					officialStartIndex(), -- 1342
					"official", -- 1342
					true -- 1342
				) -- 1342
			end -- 1342
		elseif act.type == "start" then -- 1342
			clearSession() -- 1346
			refreshTitleSessionFlag() -- 1347
			enterPlayRoom( -- 1348
				officialStartIndex(), -- 1348
				"official", -- 1348
				true -- 1348
			) -- 1348
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1348
			enterPlayRoom(act.roomIndex, "chapter") -- 1350
		elseif act.type == "openChapters" then -- 1350
			fe.menus:openChapters() -- 1352
			fe.screen = "chapters" -- 1353
		elseif act.type == "openControls" then -- 1353
			fe.menus:resetInput() -- 1355
			fe.screen = "controls" -- 1356
		elseif act.type == "openHistory" then -- 1356
			fe.menus:openHistory(true) -- 1358
			fe.screen = "history" -- 1359
		elseif act.type == "backEpilogue" then -- 1359
			fe.menus:resetInput() -- 1361
			fe.screen = "epilogue" -- 1362
		elseif act.type == "replayStory" then -- 1362
			clearSession() -- 1364
			refreshTitleSessionFlag() -- 1365
			enterPlayRoom( -- 1366
				officialStartIndex(), -- 1366
				"official", -- 1366
				true -- 1366
			) -- 1366
		elseif act.type == "backTitle" then -- 1366
			fe.menus:resetInput() -- 1368
			fe.screen = "title" -- 1369
		elseif act.type == "backPause" then -- 1369
			fe.menus:resetInput() -- 1371
			fe.screen = "play" -- 1372
		elseif act.type == "quit" then -- 1372
			quitGame() -- 1374
		end -- 1374
		return -- 1376
	end -- 1376
	if play == nil then -- 1376
		ensurePlay() -- 1381
	end -- 1381
	if play == nil then -- 1381
		return -- 1384
	end -- 1384
	local p = play -- 1386
	p.aimX = input.mx -- 1388
	p.aimY = input.my -- 1389
	local zoneTap = input.touchZoneTap -- 1391
	if zoneTap ~= "ledger:toggle" then -- 1391
		input.touchZoneTap = "" -- 1392
	end -- 1392
	local offers = p:getStoryTalentOffers() -- 1394
	if fe:canPickStoryTalent(p) and #offers > 0 then -- 1394
		if fe.hud.talentSelected >= #offers then -- 1394
			fe.hud.talentSelected = 0 -- 1397
		end -- 1397
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1397
			local idx = __TS__ParseInt( -- 1400
				string.sub(zoneTap, 8), -- 1400
				10 -- 1400
			) -- 1400
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1400
				input.fire.pressed = false -- 1402
			end -- 1402
		else -- 1402
			if input.talentDelta ~= 0 then -- 1402
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1406
				input.talentDelta = 0 -- 1407
			end -- 1407
			if input.talentConfirm then -- 1407
				p:chooseTalent(fe.hud.talentSelected) -- 1410
				input.talentConfirm = false -- 1411
				input.fire.pressed = false -- 1412
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1412
				input.fire.pressed = false -- 1415
			end -- 1415
		end -- 1415
	end -- 1415
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1415
		if input.navConfirm then -- 1415
			input.interact.pressed = true -- 1423
		end -- 1423
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1423
			flushProfile() -- 1426
			if p.run.source == "official" and hasSessionSave() then -- 1426
				clearSession() -- 1428
				refreshTitleSessionFlag() -- 1429
			end -- 1429
			fe.audio:stopRoomTransient() -- 1431
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1432
			fe.screen = "epilogue" -- 1436
			input:clearTransient(true) -- 1437
			input:consumeEdges() -- 1438
			return -- 1439
		end -- 1439
	end -- 1439
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1439
		p:closeCraftBench() -- 1444
		input:consumeEdges() -- 1445
		return -- 1446
	end -- 1446
	if not p.paused and input.pause.pressed then -- 1446
		p.paused = true -- 1449
		p.aimHold = 0 -- 1450
		p.bottleAimX = -1 -- 1451
		saveCurrentSession() -- 1452
		fe.menus:openPause() -- 1453
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1454
		input:clearTransient(true) -- 1455
		input:consumeEdges() -- 1456
	end -- 1456
	if p.paused then -- 1456
		clock:reset() -- 1461
		local pauseAct = fe:renderPlay( -- 1462
			frameDt, -- 1462
			p, -- 1462
			input, -- 1462
			stageVp.stageW, -- 1462
			stageVp.stageH -- 1462
		) -- 1462
		input:consumeEdges() -- 1463
		if pauseAct.type == "resume" then -- 1463
			p.paused = false -- 1465
		elseif pauseAct.type == "retry" then -- 1465
			ensurePlay({checkpoint = p.checkpoint}) -- 1467
		elseif pauseAct.type == "openChapters" then -- 1467
			fe.audio:stopRoomTransient() -- 1469
			fe.audio:setPaused(false) -- 1470
			fe.menus:openChapters(current) -- 1471
			fe.screen = "chapters" -- 1472
		elseif pauseAct.type == "toggleFullscreen" then -- 1472
			toggleFullscreen() -- 1474
		elseif pauseAct.type == "quit" then -- 1474
			quitGame() -- 1476
		elseif pauseAct.type == "toTitle" then -- 1476
			saveCurrentSession() -- 1478
			refreshTitleSessionFlag() -- 1479
			fe.menus:resetInput() -- 1480
			fe.screen = "title" -- 1481
		end -- 1481
		return -- 1483
	end -- 1483
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1486
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1487
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1487
		input:consumeEdges() -- 1490
		ensurePlay({checkpoint = p.checkpoint}) -- 1492
		return -- 1493
	end -- 1493
	local steps = clock:advance(frameDt) -- 1496
	local i = 0 -- 1497
	do -- 1497
		i = 0 -- 1498
		while i < steps do -- 1498
			input:beginStep(i == 0) -- 1499
			p:update(STEP, input) -- 1500
			input:endStep() -- 1501
			if p.wantRoom ~= "" then -- 1501
				break -- 1503
			end -- 1503
			i = i + 1 -- 1498
		end -- 1498
	end -- 1498
	if p.wantRoom ~= "" then -- 1498
		local key = p.wantRoom -- 1509
		p.wantRoom = "" -- 1510
		local idx = -1 -- 1511
		local j = 0 -- 1512
		do -- 1512
			j = 0 -- 1513
			while j < #ROOMS do -- 1513
				if ROOMS[j + 1].key == key then -- 1513
					idx = j -- 1515
				end -- 1515
				j = j + 1 -- 1513
			end -- 1513
		end -- 1513
		if idx >= 0 then -- 1513
			flushProfile() -- 1522
			local leaving = p:drainEvents() -- 1523
			if p.restartStory then -- 1523
				if storyRun ~= nil and storyRun.source == "official" then -- 1523
					clearSession() -- 1527
					refreshTitleSessionFlag() -- 1528
				end -- 1528
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1530
				storyRun = createRun(20261124, nextSource, profile) -- 1531
			end -- 1531
			current = idx -- 1533
			ensurePlay() -- 1534
			local fresh = play -- 1535
			if fresh ~= nil then -- 1535
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1535
					fresh.phase = "prologue-wake" -- 1538
				end -- 1538
				fresh:adoptEvents(leaving) -- 1540
			end -- 1540
			if not p.restartStory then -- 1540
				saveCurrentSession() -- 1543
			end -- 1543
			clock:reset() -- 1545
			dirty = true -- 1546
		end -- 1546
		return -- 1548
	end -- 1548
	flushProfile() -- 1552
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1552
		clearSession() -- 1554
		refreshTitleSessionFlag() -- 1555
	elseif p.sessionDirty then -- 1555
		saveCurrentSession() -- 1557
	end -- 1557
	fe:renderPlay( -- 1559
		frameDt, -- 1559
		p, -- 1559
		input, -- 1559
		stageVp.stageW, -- 1559
		stageVp.stageH -- 1559
	) -- 1559
end -- 1559
function redrawGraybox() -- 1563
	if draw == nil then -- 1563
		return -- 1565
	end -- 1565
	local w = viewW -- 1567
	local h = viewH -- 1568
	local room = ROOMS[current + 1] -- 1569
	draw:clear() -- 1571
	draw:drawRect( -- 1572
		Rect(0, h - TOP_H, w, TOP_H), -- 1572
		C_BG -- 1572
	) -- 1572
	draw:drawRect( -- 1573
		Rect(0, 0, w, BOTTOM_H), -- 1573
		C_BG -- 1573
	) -- 1573
	draw:drawSegment( -- 1574
		Vec2(0, h - TOP_H), -- 1574
		Vec2(w, h - TOP_H), -- 1574
		1, -- 1574
		Color(52, 54, 54, 255) -- 1574
	) -- 1574
	draw:drawSegment( -- 1575
		Vec2(0, BOTTOM_H), -- 1575
		Vec2(w, BOTTOM_H), -- 1575
		1, -- 1575
		Color(52, 54, 54, 255) -- 1575
	) -- 1575
	local v = computeView(room, w, h) -- 1577
	renderWorld( -- 1578
		draw, -- 1578
		room, -- 1578
		v, -- 1578
		w, -- 1578
		h -- 1578
	) -- 1578
	local roomTop = v.groundPx + room.height * v.scale -- 1580
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1581
	place( -- 1583
		titleLabel, -- 1583
		48, -- 1583
		h - 40, -- 1583
		0, -- 1583
		1 -- 1583
	) -- 1583
	place( -- 1584
		roomLabel, -- 1584
		48, -- 1584
		h - 96, -- 1584
		0, -- 1584
		1 -- 1584
	) -- 1584
	place( -- 1585
		captionLabel, -- 1585
		48, -- 1585
		h - 140, -- 1585
		0, -- 1585
		1 -- 1585
	) -- 1585
	place( -- 1587
		switchLabel, -- 1587
		48, -- 1587
		40, -- 1587
		0, -- 1587
		0 -- 1587
	) -- 1587
	place( -- 1588
		hintLabel, -- 1588
		48, -- 1588
		84, -- 1588
		0, -- 1588
		0 -- 1588
	) -- 1588
	place( -- 1589
		rulerLabel, -- 1589
		w - 216, -- 1589
		roomTop + 36 + v.scale * 0.5 - 14, -- 1589
		1, -- 1589
		0 -- 1589
	) -- 1589
	place( -- 1590
		standLabel, -- 1590
		48, -- 1590
		roomTop + 40, -- 1590
		0, -- 1590
		0 -- 1590
	) -- 1590
	place( -- 1591
		cartLabel, -- 1591
		48, -- 1591
		roomTop + 92, -- 1591
		0, -- 1591
		0 -- 1591
	) -- 1591
	if roomLabel ~= nil then -- 1591
		roomLabel.text = room.name -- 1594
	end -- 1594
	if captionLabel ~= nil then -- 1594
		captionLabel.text = room.caption -- 1597
	end -- 1597
	if hintLabel ~= nil then -- 1597
		local hintIdx = math.min(current, #HINTS - 1) -- 1600
		local lines = HINTS[hintIdx + 1] -- 1601
		local merged = lines[1] -- 1602
		do -- 1602
			local i = 1 -- 1603
			while i < #lines do -- 1603
				merged = (merged .. "    ") .. lines[i + 1] -- 1604
				i = i + 1 -- 1603
			end -- 1603
		end -- 1603
		hintLabel.text = merged -- 1606
	end -- 1606
	local specs = collectLabels(room, v, w) -- 1609
	local body = {} -- 1610
	local small = {} -- 1611
	do -- 1611
		local i = 0 -- 1612
		while i < #specs do -- 1612
			local s = specs[i + 1] -- 1613
			if s.size >= 24 then -- 1613
				body[#body + 1] = s -- 1615
			else -- 1615
				small[#small + 1] = s -- 1617
			end -- 1617
			i = i + 1 -- 1612
		end -- 1612
	end -- 1612
	applyPool(body, poolBody) -- 1620
	applyPool(small, poolSmall) -- 1621
	if LAYOUT_AUDIT then -- 1621
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1624
	end -- 1624
end -- 1624
function applyPool(specs, pool) -- 1628
	do -- 1628
		local i = 0 -- 1629
		while i < #pool do -- 1629
			local lb = pool[i + 1] -- 1630
			if i < #specs then -- 1630
				local s = specs[i + 1] -- 1632
				lb.text = s.text -- 1633
				lb.position = Vec2(s.x, s.y) -- 1634
				lb.anchor = Vec2(s.ax, s.ay) -- 1635
				lb.color = s.color -- 1636
				lb.visible = true -- 1637
			else -- 1637
				lb.visible = false -- 1639
			end -- 1639
			i = i + 1 -- 1629
		end -- 1629
	end -- 1629
end -- 1629
local FONT = "sarasa-mono-sc-regular" -- 39
LAYOUT_AUDIT = false -- 40
local C_TEXT = Color(236, 236, 232, 255) -- 42
local C_DIM = Color(150, 154, 152, 255) -- 43
local C_ACCENT = Color(226, 186, 84, 255) -- 44
C_BG = Color(17, 18, 19, 255) -- 45
local POOL_BODY = 30 -- 47
local POOL_SMALL = 44 -- 48
TOP_H = 208 -- 49
BOTTOM_H = 216 -- 50
profile = emptySave() -- 68
local profileStatus = "missing" -- 69
local profileDetail = "" -- 70
poolBody = {} -- 75
poolSmall = {} -- 76
current = 0 -- 78
viewW = 0 -- 79
viewH = 0 -- 80
dirty = true -- 81
mode = 1 -- 83
clock = __TS__New(StepClock) -- 90
stageVp = computeStageViewport(1280, 720) -- 91
audioUnlocked = false -- 93
appClock = 0 -- 94
local lastBackPressClock = -10 -- 95
trialTalentSelected = 0 -- 96
local function handleBackButton() -- 146
	if mode == 0 then -- 146
		setMode(1) -- 148
		return -- 149
	end -- 149
	if mode == 2 and play ~= nil then -- 149
		local trial = run and run.trial -- 152
		if trial ~= nil and (trial.lost or (run and run.finished) == true) then -- 152
			current = 0 -- 154
			play = nil -- 155
			run = nil -- 156
			setMode(1) -- 157
			if fe ~= nil then -- 157
				fe.audio:stopRoomTransient() -- 159
				fe.screen = "title" -- 160
				fe.menus:resetInput() -- 161
			end -- 161
			return -- 163
		end -- 163
		play.paused = not play.paused -- 165
		if fe ~= nil then -- 165
			fe.audio:playUi(play.paused and "ui:pause_open" or "ui:pause_close", play.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 166
		end -- 166
		clock:reset() -- 167
		if input ~= nil then -- 167
			input:clearTransient(true) -- 168
		end -- 168
		return -- 169
	end -- 169
	if fe == nil then -- 169
		return -- 172
	end -- 172
	if fe.screen == "splash" then -- 172
		fe.menus:resetSplash() -- 175
		fe.screen = "title" -- 176
		fe.menus:resetInput() -- 177
		return -- 178
	end -- 178
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "epilogue" or fe.screen == "history" then -- 178
		fe.menus:triggerBack() -- 181
		return -- 182
	end -- 182
	if fe.screen == "title" then -- 182
		if not canQuitApp() then -- 182
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 186
			return -- 187
		end -- 187
		if appClock - lastBackPressClock <= 2 then -- 187
			quitGame() -- 190
		else -- 190
			lastBackPressClock = appClock -- 192
			fe:showToast("再按一次返回退出游戏", 2) -- 193
		end -- 193
		return -- 195
	end -- 195
	if fe.screen == "play" and play ~= nil then -- 195
		if play.paused then -- 195
			fe.menus:triggerBack() -- 199
			return -- 200
		end -- 200
		if play.craftBench.active then -- 200
			play:closeCraftBench() -- 203
			return -- 204
		end -- 204
		play.paused = true -- 206
		play.aimHold = 0 -- 207
		play.bottleAimX = -1 -- 208
		saveCurrentSession() -- 209
		fe.menus:openPause() -- 210
		if input ~= nil then -- 210
			input:clearTransient(true) -- 211
		end -- 211
	end -- 211
end -- 146
local function makeGrayboxLabel(text, size, color) -- 364
	if grayboxLayer == nil then -- 364
		return nil -- 366
	end -- 366
	local lb = Label(FONT, size) -- 368
	if lb == nil then -- 368
		return nil -- 370
	end -- 370
	lb.text = text -- 372
	lb.color = color -- 373
	lb:addTo(grayboxLayer) -- 374
	lb.visible = true -- 375
	return lb -- 376
end -- 364
function ____exports.start(parent, initialMode, startScreen) -- 388
	if initialMode == nil then -- 388
		initialMode = 1 -- 388
	end -- 388
	if startScreen == nil then -- 388
		startScreen = "title" -- 388
	end -- 388
	root = parent -- 389
	mode = initialMode -- 390
	grayboxLayer = Node() -- 393
	grayboxLayer.order = 2 -- 394
	grayboxLayer:addTo(parent) -- 395
	draw = DrawNode() -- 397
	draw:addTo(grayboxLayer) -- 398
	campaignLayer = Node() -- 401
	campaignLayer.order = 3 -- 402
	campaignLayer:addTo(parent) -- 403
	campaignDraw = DrawNode() -- 404
	campaignDraw:addTo(campaignLayer) -- 405
	campaignHud = Label(FONT, 24) -- 406
	if campaignHud ~= nil then -- 406
		campaignHud.color = C_TEXT -- 408
		campaignHud.anchor = Vec2(0, 1) -- 409
		campaignHud:addTo(campaignLayer) -- 410
		campaignHud.visible = true -- 411
	end -- 411
	campaignSub = Label(FONT, 20) -- 413
	if campaignSub ~= nil then -- 413
		campaignSub.color = C_ACCENT -- 415
		campaignSub.anchor = Vec2(0, 1) -- 416
		campaignSub:addTo(campaignLayer) -- 417
		campaignSub.visible = true -- 418
	end -- 418
	campaignLayer.visible = mode == 2 -- 420
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 422
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 423
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 424
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 425
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 426
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 427
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 428
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 429
	do -- 429
		local i = 0 -- 431
		while i < POOL_BODY do -- 431
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 432
			if lb ~= nil then -- 432
				poolBody[#poolBody + 1] = lb -- 434
			end -- 434
			i = i + 1 -- 431
		end -- 431
	end -- 431
	do -- 431
		local i = 0 -- 437
		while i < POOL_SMALL do -- 437
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 438
			if lb ~= nil then -- 438
				poolSmall[#poolSmall + 1] = lb -- 440
			end -- 440
			i = i + 1 -- 437
		end -- 437
	end -- 437
	if mode == 1 then -- 437
		local loaded = loadSave() -- 447
		profile = loaded.state -- 448
		profileStatus = loaded.status -- 449
		profileDetail = loaded.detail -- 450
	end -- 450
	fe = __TS__New(WatchFrontend, parent) -- 452
	fe.screen = startScreen -- 453
	if startScreen == "splash" then -- 453
		fe.menus:resetSplash() -- 455
	end -- 455
	refreshTitleSessionFlag() -- 457
	grayboxLayer.visible = mode == 0 -- 458
	fe:setVisible(mode == 1) -- 459
	if campaignLayer ~= nil then -- 459
		campaignLayer.visible = mode == 2 -- 461
	end -- 461
	input = __TS__New(Input) -- 464
	fe.audio:applyUserVolumes(input.settings) -- 465
	touchRouter = __TS__New(TouchRouter, input.settings) -- 466
	touchRouter:attach(parent) -- 467
	input:bindTouch(touchRouter) -- 468
	gamepadRouter = __TS__New(GamepadRouter, input.settings) -- 470
	gamepadRouter:attach(parent) -- 471
	input:bindGamepad(gamepadRouter) -- 472
	touchControls = __TS__New(TouchControls, parent) -- 474
	parent:gslot( -- 477
		"AppEvent", -- 477
		function(eventType) -- 477
			if eventType == "BackButton" then -- 477
				handleBackButton() -- 479
				return -- 480
			end -- 480
			if eventType == "Quit" or eventType == "Shutdown" then -- 480
				flushProfile() -- 483
				saveCurrentSession() -- 484
				if input ~= nil then -- 484
					input:clearTransient(false) -- 485
				end -- 485
				return -- 486
			end -- 486
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 486
				flushProfile() -- 489
				saveCurrentSession() -- 490
				if input ~= nil then -- 490
					input:clearTransient(true) -- 491
				end -- 491
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 491
					play.paused = true -- 493
					play.aimHold = 0 -- 494
					play.bottleAimX = -1 -- 495
					fe.menus:openPause() -- 496
				elseif mode == 2 and play ~= nil and not play.paused then -- 496
					play.paused = true -- 498
				end -- 498
				if fe ~= nil then -- 498
					fe.audio:setPaused(true) -- 501
				end -- 501
				return -- 503
			end -- 503
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 503
				if fe ~= nil then -- 503
					local paused = play ~= nil and play.paused and (mode == 1 and fe.screen == "play" or mode == 2) -- 507
					fe.audio:setPaused(paused) -- 509
				end -- 509
			end -- 509
		end -- 477
	) -- 477
	parent:onKeyDown(function(key) -- 515
		onFirstUserGesture() -- 516
		if input ~= nil then -- 516
			input:markKeyboardActivity() -- 517
		end -- 517
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 517
			toggleFullscreen() -- 520
			return -- 521
		end -- 521
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 521
			play:toggleArtifactWeapon() -- 524
			return -- 525
		end -- 525
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and #play:getStoryTalentOffers() > 0 then -- 525
			if key == "1" or key == "2" or key == "3" then -- 525
				if fe:canPickStoryTalent(play) then -- 525
					play:chooseTalent(key == "1" and 0 or (key == "2" and 1 or 2)) -- 531
				end -- 531
				if input ~= nil then -- 531
					input:consumePickRoom() -- 533
				end -- 533
				return -- 534
			end -- 534
		end -- 534
		local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 537
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 537
			fe.menus:onKeyEvent(key) -- 539
		end -- 539
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay or mode == 2) then -- 539
			if key == "E" then -- 539
				input.interact.pressed = true -- 543
			elseif key == "Space" then -- 543
				input.jump.pressed = true -- 545
			elseif key == "Escape" then -- 545
				input.pause.pressed = true -- 547
			elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 547
				input.retry.pressed = true -- 549
			end -- 549
		end -- 549
		if mode == 2 and (run and run.trial) ~= nil then -- 549
			return -- 552
		end -- 552
		if isReleaseBuild() then -- 552
			return -- 553
		end -- 553
		if key == "F1" then -- 553
			if mode == 2 then -- 553
				current = 0 -- 556
				play = nil -- 557
				ensurePlay() -- 558
			else -- 558
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 560
			end -- 560
		elseif key == "F2" then -- 560
			setMode(0) -- 563
		elseif key == "1" then -- 563
			pickByIndex(0) -- 565
		elseif key == "2" then -- 565
			pickByIndex(1) -- 567
		elseif key == "3" then -- 567
			pickByIndex(2) -- 569
		elseif key == "4" then -- 569
			pickByIndex(3) -- 571
		elseif key == "5" then -- 571
			pickByIndex(4) -- 573
		elseif key == "6" then -- 573
			pickByIndex(5) -- 575
		elseif key == "7" then -- 575
			pickByIndex(6) -- 577
		elseif key == "8" then -- 577
			pickByIndex(7) -- 579
		end -- 579
	end) -- 515
	viewW = View.size.width -- 583
	viewH = View.size.height -- 584
	applySize() -- 585
	local reg = _G.package.loaded -- 588
	reg["watch.input"] = input -- 589
	reg["watch.touch"] = touchRouter -- 590
	reg["watch.gamepad"] = gamepadRouter -- 591
	reg["watch.fe"] = { -- 592
		setScreen = function(sc) -- 593
			if fe == nil then -- 593
				return -- 595
			end -- 595
			setMode(1) -- 597
			fe.screen = sc -- 598
			if sc == "splash" then -- 598
				fe.menus:resetSplash() -- 600
			elseif sc == "chapters" then -- 600
				fe.menus:openChapters() -- 602
			elseif sc == "epilogue" then -- 602
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 604
			elseif sc == "history" then -- 604
				fe.menus:openHistory(false) -- 609
			else -- 609
				fe.menus:resetInput() -- 611
			end -- 611
			if sc == "play" then -- 611
				ensurePlay() -- 614
			end -- 614
		end, -- 593
		jumpRoom = function(keyOrIdx) -- 617
			local idx = -1 -- 618
			if type(keyOrIdx) == "number" then -- 618
				idx = keyOrIdx -- 620
			else -- 620
				local k = 0 -- 622
				do -- 622
					k = 0 -- 623
					while k < #ROOMS do -- 623
						if ROOMS[k + 1].key == keyOrIdx then -- 623
							idx = k -- 625
						end -- 625
						k = k + 1 -- 623
					end -- 623
				end -- 623
			end -- 623
			if idx >= 0 and idx < #ROOMS then -- 623
				enterPlayRoom(idx, "debug") -- 630
			end -- 630
		end, -- 617
		getPlay = function() return play end, -- 633
		getFrontend = function() return fe end, -- 634
		startStory = function() -- 636
			enterPlayRoom( -- 637
				officialStartIndex(), -- 637
				"official", -- 637
				true -- 637
			) -- 637
			return play -- 638
		end, -- 636
		previewChapter = function(idx) -- 641
			enterPlayRoom(idx, "chapter") -- 642
			return play -- 643
		end, -- 641
		getStoryRun = function() return storyRun end, -- 645
		getProfilePending = function() return profilePending() end, -- 646
		flushProfileNow = function() return flushProfile() end, -- 647
		getProfile = function() return profile end, -- 649
		getProfileStatus = function() return profileStatus end, -- 650
		getProfileDetail = function() return profileDetail end, -- 651
		useTestSave = function(name) -- 652
			setSaveFile(name) -- 653
			setSessionFile(name == "" and "" or name .. ".session") -- 654
			clearProfilePending() -- 655
			local loaded = loadSave() -- 656
			profile = loaded.state -- 657
			profileStatus = loaded.status -- 658
			profileDetail = loaded.detail -- 659
			refreshTitleSessionFlag() -- 660
		end, -- 652
		useTestSession = function(name) -- 662
			setSessionFile(name) -- 663
			refreshTitleSessionFlag() -- 664
		end, -- 662
		getSessionFile = getSessionFile, -- 666
		hasSessionSave = hasSessionSave, -- 667
		saveSessionNow = function() return saveCurrentSession() end, -- 668
		clearSessionNow = function() -- 669
			local ok = clearSession() -- 670
			refreshTitleSessionFlag() -- 671
			return ok -- 672
		end, -- 669
		continueStory = function() return continueOfficialStory() end, -- 674
		saveNow = function() return saveSave(profile) end, -- 675
		getSaveFile = getSaveFile, -- 676
		isRelease = function() return isReleaseBuild() end, -- 677
		getReleaseVersion = function() -- 678
			local ____opt_28 = getReleaseConfig() -- 678
			return ____opt_28 and ____opt_28.version or "dev" -- 678
		end, -- 678
		toggleFullscreen = function() return toggleFullscreen() end, -- 679
		quitGame = function() return quitGame() end, -- 680
		startTrial = function() return startTrial() end, -- 681
		handleBackButton = function() return handleBackButton() end, -- 682
		getViewport = function() return stageVp end, -- 683
		getTouchController = function() return touchControls end, -- 684
		getTouchRouter = function() return touchRouter end, -- 685
		getGamepad = function() return gamepadRouter end, -- 686
		setGamepadSim = function(state) -- 687
			if gamepadRouter ~= nil then -- 687
				gamepadRouter:setSimulatedState(state) -- 688
			end -- 688
		end, -- 687
		injectTouch = function(phase, id, x, y, fromMouse) -- 690
			if touchRouter ~= nil then -- 690
				touchRouter:injectTouch( -- 691
					phase, -- 691
					id, -- 691
					x, -- 691
					y, -- 691
					fromMouse -- 691
				) -- 691
			end -- 691
		end, -- 690
		getInputMode = function() return input and input.inputMode or "kbm" end, -- 693
		setInputMode = function(m) -- 694
			if input ~= nil then -- 694
				input:setInputMode(m) -- 695
			end -- 695
		end, -- 694
		setModePref = function(pref) -- 697
			if input ~= nil then -- 697
				input:setModePref(pref) -- 698
			end -- 698
		end, -- 697
		applyViewportForTest = function(w, h) -- 700
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 700
				testViewportOverride = {w = w, h = h} -- 702
				viewW = w -- 703
				viewH = h -- 704
			else -- 704
				testViewportOverride = nil -- 706
				viewW = View.size.width -- 707
				viewH = View.size.height -- 708
			end -- 708
			applySize() -- 710
			dirty = true -- 711
			return stageVp -- 712
		end, -- 700
		getToast = function() return fe and fe:getToastText() or "" end -- 714
	} -- 714
	if mode == 1 and startScreen == "play" then -- 714
		ensurePlay() -- 718
	end -- 718
	parent:schedule(function(frameDt) -- 721
		tick(frameDt) -- 722
		return false -- 723
	end) -- 721
end -- 388
return ____exports -- 388