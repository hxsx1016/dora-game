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
function setMode(nextMode) -- 735
	mode = nextMode -- 736
	if grayboxLayer ~= nil then -- 736
		grayboxLayer.visible = mode == 0 -- 738
	end -- 738
	if fe ~= nil then -- 738
		fe:setVisible(mode == 1) -- 741
	end -- 741
	if campaignLayer ~= nil then -- 741
		campaignLayer.visible = mode == 2 -- 744
	end -- 744
	dirty = true -- 746
	clock:reset() -- 747
end -- 747
function flushProfile() -- 754
	local cur = play -- 755
	if cur ~= nil and cur.archiveDirty then -- 755
		cur.archiveDirty = false -- 757
		markProfilePending(profile) -- 758
	end -- 758
	local ok = flushSaveProfile() -- 760
	if not ok and cur ~= nil then -- 760
		cur.archiveDirty = true -- 762
	end -- 762
	return ok -- 764
end -- 764
function officialStartIndex() -- 768
	local mp = profile.museumPhase -- 769
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 770
	return inMuseum and roomIndexByKey("museum") or 0 -- 771
end -- 771
function roomIndexByKey(key) -- 774
	local i = 0 -- 775
	do -- 775
		i = 0 -- 776
		while i < #ROOMS do -- 776
			if ROOMS[i + 1].key == key then -- 776
				return i -- 778
			end -- 778
			i = i + 1 -- 776
		end -- 776
	end -- 776
	return 0 -- 781
end -- 781
--- 章节直达后半段时按目标房间预置独立预览路线（不改正式档、不污染通关档案）。
function ____exports.applyChapterPreviewRoute(run, targetKey) -- 785
	if targetKey == "outside" or targetKey == "village" or targetKey == "forest" or targetKey == "tower" then -- 785
		run.story.route = "child" -- 787
		run.story.settled = true -- 788
	elseif targetKey == "gatepath" or (string.find(targetKey, "escort", nil, true) or 0) - 1 == 0 then -- 788
		run.story.route = "soldier" -- 790
		run.story.settled = true -- 791
		run.joined = true -- 792
		if (string.find(targetKey, "escort", nil, true) or 0) - 1 == 0 then -- 792
			run.story.carry = true -- 794
		end -- 794
	end -- 794
end -- 785
function enterPlayRoom(idx, source, fresh) -- 799
	if source == nil then -- 799
		source = "debug" -- 799
	end -- 799
	if fresh == nil then -- 799
		fresh = false -- 799
	end -- 799
	current = idx -- 800
	setMode(1) -- 801
	if fe ~= nil then -- 801
		fe.screen = "play" -- 803
	end -- 803
	play = nil -- 805
	if fresh or source == "chapter" or storyRun == nil then -- 805
		storyRun = createRun(20261124, source, profile) -- 808
		if source == "chapter" then -- 808
			local targetKey = ROOMS[current + 1] ~= nil and ROOMS[current + 1].key or "" -- 810
			____exports.applyChapterPreviewRoute(storyRun, targetKey) -- 811
		end -- 811
	else -- 811
		storyRun.source = source -- 814
	end -- 814
	ensurePlay() -- 816
	local firstPlay = play -- 818
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 818
		firstPlay.phase = "prologue-wake" -- 820
	end -- 820
	flushProfile() -- 822
end -- 822
function pickByIndex(idx, source) -- 825
	if source == nil then -- 825
		source = "debug" -- 825
	end -- 825
	if mode == 2 then -- 825
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 825
			return -- 828
		end -- 828
		current = idx -- 830
		play = nil -- 831
		clock:reset() -- 832
		ensurePlay() -- 833
		return -- 834
	end -- 834
	if idx < 0 or idx >= #ROOMS then -- 834
		return -- 837
	end -- 837
	flushProfile() -- 839
	if storyRun ~= nil then -- 839
		storyRun.source = source -- 841
	end -- 841
	current = idx -- 843
	dirty = true -- 844
	play = nil -- 845
	clock:reset() -- 846
	if mode == 1 then -- 846
		if fe ~= nil then -- 846
			fe.screen = "play" -- 849
		end -- 849
		ensurePlay() -- 851
	end -- 851
end -- 851
function applySize() -- 855
	if root == nil then -- 855
		return -- 857
	end -- 857
	root.size = Size(viewW, viewH) -- 859
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 860
	stageVp = computeStageViewport(viewW, viewH) -- 861
	if input ~= nil then -- 861
		input:setStageViewport(stageVp) -- 863
	end -- 863
	if fe ~= nil then -- 863
		fe:setStagePlacement(stageVp) -- 866
	end -- 866
	if campaignLayer ~= nil then -- 866
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 869
	end -- 869
	if grayboxLayer ~= nil then -- 869
		grayboxLayer.position = Vec2(0, 0) -- 872
	end -- 872
end -- 872
function syncFrameAdapters(frameDt) -- 876
	if input == nil then -- 876
		return -- 878
	end -- 878
	local p = play -- 880
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 881
	local isTrialMode = mode == 2 and p ~= nil -- 882
	local gameplayActive = isPlayMode or isTrialMode -- 883
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 885
		p, -- 887
		stageVp.stageW, -- 887
		stageVp.stageH, -- 887
		input:isTouchMode() -- 887
	) or ({}) -- 887
	if touchControls ~= nil and touchRouter ~= nil then -- 887
		local isFs = false -- 891
		if canToggleFullscreen() then -- 891
			do -- 891
				local function ____catch() -- 891
					isFs = false -- 896
				end -- 896
				local ____try = pcall(function() -- 896
					isFs = App.fullScreen -- 894
				end) -- 894
				if not ____try then -- 894
					____catch() -- 894
				end -- 894
			end -- 894
		end -- 894
		local ____touchControls_55 = touchControls -- 899
		local ____touchControls_syncContext_56 = touchControls.syncContext -- 899
		local ____stageVp_48 = stageVp -- 900
		local ____mode_49 = mode -- 901
		local ____temp_50 = fe ~= nil and fe.screen or "title" -- 902
		local ____run_51 = run -- 904
		local ____temp_52 = fe ~= nil and fe.cam or nil -- 905
		local ____input_53 = input -- 906
		local ____touchRouter_54 = touchRouter -- 907
		local ____temp_46 -- 908
		if fe ~= nil then -- 908
			____temp_46 = fe.contract:isAssistHintsEnabled() -- 908
		else -- 908
			____temp_46 = false -- 908
		end -- 908
		local ____temp_47 -- 909
		if fe ~= nil then -- 909
			____temp_47 = fe.audio:isAllMuted() -- 909
		else -- 909
			____temp_47 = false -- 909
		end -- 909
		____touchControls_syncContext_56(____touchControls_55, { -- 899
			viewport = ____stageVp_48, -- 900
			mode = ____mode_49, -- 901
			screen = ____temp_50, -- 902
			play = p, -- 903
			run = ____run_51, -- 904
			cam = ____temp_52, -- 905
			input = ____input_53, -- 906
			router = ____touchRouter_54, -- 907
			assistHintsEnabled = ____temp_46, -- 908
			isMuted = ____temp_47, -- 909
			isFullscreen = isFs, -- 910
			storyTalentBoxes = storyTalentBoxes, -- 911
			dt = frameDt -- 912
		}) -- 912
	end -- 912
	if gamepadRouter ~= nil then -- 912
		local trial = run and run.trial -- 917
		local trialEnded = isTrialMode and trial ~= nil and (trial.lost or (run and run.finished) == true) -- 918
		local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 919
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 920
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 923
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 924
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 925
		local ____temp_61 -- 928
		if isPlayMode and p ~= nil then -- 928
			____temp_61 = isCutsceneBlockingPlay(p) -- 928
		else -- 928
			____temp_61 = false -- 928
		end -- 928
		local cutsceneBlocking = ____temp_61 -- 928
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 929
		local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 931
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 932
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 934
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 936
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 939
		local playerScreenX = stageVp.stageW * 0.5 -- 941
		local playerScreenY = stageVp.stageH * 0.38 -- 942
		if p ~= nil then -- 942
			if isPlayMode and fe ~= nil then -- 942
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 945
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 946
			else -- 946
				local vz = p.view.zoom > 0 and p.view.zoom or 1 -- 949
				playerScreenX = stageVp.stageW * 0.5 + (p.player.x + p.player.facing * 8 - p.cam.x) * vz -- 950
				playerScreenY = stageVp.stageH * 0.5 + (p.player.y + p.player.h * 0.72 + p.player.depth * DEPTH_Y_SCALE - p.cam.y) * vz -- 951
			end -- 951
		end -- 951
		local enemyTargets = canShoot and p ~= nil and (isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or collectTrialAimTargets(p, stageVp.stageW, stageVp.stageH)) or ({}) -- 955
		local gpCtx = { -- 961
			stageW = stageVp.stageW, -- 962
			stageH = stageVp.stageH, -- 963
			uiScale = stageVp.uiScale, -- 964
			modal = modal, -- 965
			gameplayActive = gameplayActive, -- 966
			reloadActive = reloadActive, -- 967
			craftActive = craftActive, -- 968
			talentOfferCount = talentOfferCount, -- 969
			childMode = p ~= nil and p.childMode, -- 970
			allowDepth = allowDepth, -- 971
			canShoot = canShoot, -- 972
			canBottleAim = canBottleAim, -- 973
			playerRolling = p ~= nil and p.player.rollT > 0, -- 974
			inLowArch = inLowArch, -- 975
			inTowerEnd = inTowerEnd, -- 976
			playerFacing = p ~= nil and p.player.facing or 1, -- 977
			playerScreenX = playerScreenX, -- 978
			playerScreenY = playerScreenY, -- 979
			enemyTargets = enemyTargets -- 980
		} -- 980
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 982
	end -- 982
end -- 982
function renderTouchOverlay() -- 986
	if touchControls ~= nil and touchRouter ~= nil then -- 986
		touchControls:render(touchRouter) -- 988
	end -- 988
end -- 988
function tick(frameDt) -- 992
	appClock = appClock + math.min( -- 993
		0.05, -- 993
		math.max(0, frameDt) -- 993
	) -- 993
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 994
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 995
	if w ~= viewW or h ~= viewH then -- 995
		viewW = w -- 997
		viewH = h -- 998
		applySize() -- 999
		dirty = true -- 1000
	end -- 1000
	if input == nil then -- 1000
		return -- 1003
	end -- 1003
	syncFrameAdapters(frameDt) -- 1005
	input:update() -- 1006
	if input.userInteracted then -- 1006
		onFirstUserGesture() -- 1009
	end -- 1009
	if input.muteTogglePressed and fe ~= nil then -- 1009
		input.muteTogglePressed = false -- 1012
		fe.audio:toggleAllMuted() -- 1013
	end -- 1013
	if input.fullscreenTogglePressed then -- 1013
		input.fullscreenTogglePressed = false -- 1016
		toggleFullscreen() -- 1017
	end -- 1017
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 1017
		input.artifactTogglePressed = false -- 1020
		play:toggleArtifactWeapon() -- 1021
	end -- 1021
	if input.bottleCanceled and play ~= nil then -- 1021
		input.bottleCanceled = false -- 1024
		play.aimHold = 0 -- 1025
		play.bottleAimX = -1 -- 1026
	end -- 1026
	if mode == 2 and (run and run.trial) ~= nil then -- 1026
		tickCampaign(frameDt) -- 1030
		renderTouchOverlay() -- 1031
		return -- 1032
	end -- 1032
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 1032
		play:chooseTalent(input.pickRoom - 1) -- 1038
		input.pickRoom = 0 -- 1039
	end -- 1039
	if isReleaseBuild() then -- 1039
		input.toggleView.pressed = false -- 1043
		input.pickRoom = 0 -- 1044
		input.tab.pressed = false -- 1045
	else -- 1045
		if input.toggleView.pressed then -- 1045
			input.toggleView.pressed = false -- 1049
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 1050
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 1050
				ensurePlay() -- 1052
			end -- 1052
		end -- 1052
		if input.pickRoom ~= 0 then -- 1052
			local idx = input.pickRoom - 1 -- 1058
			input.pickRoom = 0 -- 1059
			pickByIndex(idx) -- 1060
		elseif input.tab.pressed then -- 1060
			input.tab.pressed = false -- 1062
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 1062
				pickByIndex((current + 1) % #ROOMS) -- 1064
			end -- 1064
		end -- 1064
	end -- 1064
	if mode == 2 then -- 1064
		tickCampaign(frameDt) -- 1070
	elseif mode == 1 then -- 1070
		tickFrontend(frameDt) -- 1072
	elseif dirty then -- 1072
		redrawGraybox() -- 1074
		dirty = false -- 1075
	end -- 1075
	renderTouchOverlay() -- 1077
end -- 1077
function registerPlay() -- 1081
	local reg = _G.package.loaded -- 1082
	reg["watch.play"] = play -- 1083
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 1084
	reg["watch.room"] = rooms[current + 1].key -- 1085
end -- 1085
function ensurePlay(resume) -- 1089
	if mode == 2 then -- 1089
		if run == nil then -- 1089
			run = createRun() -- 1092
		end -- 1092
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 1094
	else -- 1094
		if storyRun == nil then -- 1094
			storyRun = createRun(20261124, "debug", profile) -- 1099
		end -- 1099
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1101
	end -- 1101
	registerPlay() -- 1103
	clock:reset() -- 1104
	if fe ~= nil and mode == 1 then -- 1104
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1106
	elseif fe ~= nil and mode == 2 then -- 1106
		fe:resetTrialAudio(play) -- 1108
	end -- 1108
end -- 1108
function startTrial() -- 1112
	current = 0 -- 1113
	trialTalentSelected = 0 -- 1114
	run = createTrial(App.rand) -- 1115
	setMode(2) -- 1116
	ensurePlay() -- 1117
end -- 1117
function tickCampaign(frameDt) -- 1120
	if input == nil then -- 1120
		return -- 1122
	end -- 1122
	if play == nil then -- 1122
		ensurePlay() -- 1125
	end -- 1125
	if play == nil then -- 1125
		return -- 1128
	end -- 1128
	local p = play -- 1130
	p.aimX = input.mx -- 1131
	p.aimY = input.my -- 1132
	local zoneTap = input.touchZoneTap -- 1134
	input.touchZoneTap = "" -- 1135
	local trial = run and run.trial -- 1137
	if trial ~= nil then -- 1137
		local ended = trial.lost or (run and run.finished) == true -- 1139
		local pick = input.pickRoom -- 1140
		input.pickRoom = 0 -- 1141
		if zoneTap == "trial:resume" and p.paused and not ended then -- 1141
			p.paused = false -- 1144
			clock:reset() -- 1145
			input:consumeEdges() -- 1146
			drawCampaign(p) -- 1147
			return -- 1148
		end -- 1148
		if zoneTap == "trial:retry" then -- 1148
			input:consumeEdges() -- 1151
			startTrial() -- 1152
			return -- 1153
		end -- 1153
		if zoneTap == "trial:title" then -- 1153
			input:consumeEdges() -- 1156
			current = 0 -- 1157
			play = nil -- 1158
			run = nil -- 1159
			setMode(1) -- 1160
			if fe ~= nil then -- 1160
				fe.audio:stopRoomTransient() -- 1162
				fe.screen = "title" -- 1163
				fe.menus:resetInput() -- 1164
			end -- 1164
			return -- 1166
		end -- 1166
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1166
			input:consumeEdges() -- 1170
			current = 0 -- 1171
			play = nil -- 1172
			run = nil -- 1173
			setMode(1) -- 1174
			if fe ~= nil then -- 1174
				fe.audio:stopRoomTransient() -- 1176
				fe.screen = "title" -- 1177
				fe.menus:resetInput() -- 1178
			end -- 1178
			return -- 1180
		end -- 1180
		if ended or p.paused and input.retry.pressed then -- 1180
			local restart = input.retry.pressed or ended and input.navConfirm -- 1183
			input:consumeEdges() -- 1184
			if restart then -- 1184
				startTrial() -- 1185
			else -- 1185
				drawCampaign(p) -- 1186
			end -- 1186
			return -- 1187
		end -- 1187
		input.retry.pressed = false -- 1189
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1189
			if trialTalentSelected >= #trial.offers then -- 1189
				trialTalentSelected = 0 -- 1192
			end -- 1192
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1192
				local idx = __TS__ParseInt( -- 1195
					string.sub(zoneTap, 8), -- 1195
					10 -- 1195
				) -- 1195
				if idx >= 0 and idx < #trial.offers then -- 1195
					p:chooseTalent(idx) -- 1197
				end -- 1197
			elseif pick > 0 then -- 1197
				p:chooseTalent(pick - 1) -- 1200
			else -- 1200
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1202
				if delta ~= 0 then -- 1202
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1206
				end -- 1206
				if input.talentConfirm or input.navConfirm then -- 1206
					p:chooseTalent(trialTalentSelected) -- 1209
				end -- 1209
			end -- 1209
			input:consumeEdges() -- 1212
			clock:reset() -- 1213
			if fe ~= nil then -- 1213
				fe:syncTrialAudio(frameDt, p, #trial.offers) -- 1214
			end -- 1214
			drawCampaign(p) -- 1215
			return -- 1216
		end -- 1216
	end -- 1216
	if input.retry.pressed then -- 1216
		input.retry.pressed = false -- 1221
		input:consumeEdges() -- 1222
		play = nil -- 1224
		ensurePlay() -- 1225
		return -- 1226
	end -- 1226
	if input.pause.pressed or p.paused and input.navBack then -- 1226
		input.pause.pressed = false -- 1229
		p.paused = not p.paused -- 1230
		if fe ~= nil then -- 1230
			fe.audio:playUi(p.paused and "ui:pause_open" or "ui:pause_close", p.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 1231
		end -- 1231
		clock:reset() -- 1232
		input:consumeEdges() -- 1233
	end -- 1233
	if p.paused then -- 1233
		if fe ~= nil then -- 1233
			fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1236
		end -- 1236
		drawCampaign(p) -- 1237
		return -- 1238
	end -- 1238
	local steps = clock:advance(frameDt) -- 1241
	local i = 0 -- 1242
	do -- 1242
		i = 0 -- 1243
		while i < steps do -- 1243
			input:beginStep(i == 0) -- 1244
			p:update(STEP, input) -- 1245
			input:endStep() -- 1246
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1246
				break -- 1248
			end -- 1248
			i = i + 1 -- 1243
		end -- 1243
	end -- 1243
	if fe ~= nil then -- 1243
		fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1251
	end -- 1251
	if p.wantRoom ~= "" then -- 1251
		local key = p.wantRoom -- 1254
		p.wantRoom = "" -- 1255
		local idx = -1 -- 1256
		local j = 0 -- 1257
		do -- 1257
			j = 0 -- 1258
			while j < #CAMPAIGN_ROOMS do -- 1258
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1258
					idx = j -- 1260
				end -- 1260
				j = j + 1 -- 1258
			end -- 1258
		end -- 1258
		if idx >= 0 then -- 1258
			current = idx -- 1264
			play = nil -- 1265
			ensurePlay() -- 1266
		end -- 1266
		return -- 1268
	end -- 1268
	drawCampaign(p) -- 1270
end -- 1270
function goalLabel(goal) -- 1273
	if goal == "dock_cart" then -- 1273
		return "推车入窝并抬闩" -- 1275
	end -- 1275
	if goal == "raise_latch" then -- 1275
		return "抬闩开侧门" -- 1278
	end -- 1278
	return "到段出口" -- 1280
end -- 1280
function drawCampaign(p) -- 1283
	if campaignDraw == nil then -- 1283
		return -- 1285
	end -- 1285
	local w = stageVp.stageW -- 1287
	local h = stageVp.stageH -- 1288
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1289
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1290
	p:draw(campaignDraw, w, h) -- 1291
	local room = CAMPAIGN_ROOMS[current + 1] -- 1292
	local c = room.campaign -- 1293
	local r = run -- 1294
	local line = room.name -- 1295
	if c ~= nil then -- 1295
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget * 60) -- 1297
	end -- 1297
	if p.paused then -- 1297
		line = line .. "  · 已暂停 Esc 继续" -- 1301
	end -- 1301
	local trial = r and r.trial -- 1303
	if trial ~= nil and r ~= nil then -- 1303
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 1305
		if p.paused then -- 1305
			line = line .. " · 暂停" -- 1306
		elseif trial.lost then -- 1306
			line = line .. " · 护送失败" -- 1307
		elseif r.finished then -- 1307
			line = line .. " · 护送完成" -- 1308
		elseif #trial.offers > 0 then -- 1308
			line = line .. " · 选择本段本领" -- 1309
		elseif c ~= nil then -- 1309
			line = line .. " · " .. goalLabel(c.goal) -- 1310
		end -- 1310
	end -- 1310
	if campaignHud ~= nil then -- 1310
		campaignHud.text = line -- 1313
		campaignHud.position = Vec2(24 + safeL, h - 14 - safeT) -- 1314
		campaignHud.visible = true -- 1315
	end -- 1315
	if campaignSub ~= nil then -- 1315
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 1318
		if r ~= nil then -- 1318
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 1320
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 1321
		end -- 1321
		if p.flash ~= "" then -- 1321
			sub = (sub .. " · ") .. p.flash -- 1327
		end -- 1327
		if trial ~= nil and r ~= nil then -- 1327
			local gpMode = input ~= nil and input:isGamepadMode() -- 1330
			local touchMode = input ~= nil and input:isTouchMode() -- 1331
			if trial.lost or r.finished then -- 1331
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · A 再开一局 · START 返回标题" or (touchMode and " · 点下方按钮再开或返回标题" or " · R 再开一局 · Esc 返回标题")) -- 1333
			elseif p.paused then -- 1333
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · START 继续 · 长按BACK 重开 · Y 返回标题" or (touchMode and " · 点下方按钮继续/重开/返回标题" or " · Esc 继续 · R 重新开局 · E 返回标题")) -- 1335
			elseif #trial.offers > 0 then -- 1335
				sub = table.concat( -- 1337
					__TS__ArrayMap( -- 1337
						trial.offers, -- 1337
						function(____, talent, index) -- 1337
							local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1338
							return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1339
						end -- 1337
					), -- 1337
					"　" -- 1340
				) -- 1340
			else -- 1340
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 1342
			end -- 1342
		end -- 1342
		campaignSub.text = sub -- 1345
		campaignSub.position = Vec2(24 + safeL, h - 44 - safeT) -- 1346
		campaignSub.visible = true -- 1347
	end -- 1347
end -- 1347
function tickFrontend(frameDt) -- 1351
	if fe == nil or input == nil then -- 1351
		return -- 1353
	end -- 1353
	if fe.screen ~= "play" then -- 1353
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1358
		input:consumeEdges() -- 1359
		if act.type == "splashDone" then -- 1359
			fe.menus:resetInput() -- 1361
			fe.screen = "title" -- 1362
		elseif act.type == "trial" then -- 1362
			startTrial() -- 1364
		elseif act.type == "continue" then -- 1364
			if continueOfficialStory() == nil then -- 1364
				enterPlayRoom( -- 1367
					officialStartIndex(), -- 1367
					"official", -- 1367
					true -- 1367
				) -- 1367
			end -- 1367
		elseif act.type == "start" then -- 1367
			clearSession() -- 1371
			refreshTitleSessionFlag() -- 1372
			enterPlayRoom( -- 1373
				officialStartIndex(), -- 1373
				"official", -- 1373
				true -- 1373
			) -- 1373
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1373
			enterPlayRoom(act.roomIndex, "chapter") -- 1375
		elseif act.type == "openChapters" then -- 1375
			fe.menus:openChapters() -- 1377
			fe.screen = "chapters" -- 1378
		elseif act.type == "openControls" then -- 1378
			fe.menus:resetInput() -- 1380
			fe.screen = "controls" -- 1381
		elseif act.type == "openHistory" then -- 1381
			fe.menus:openHistory(true) -- 1383
			fe.screen = "history" -- 1384
		elseif act.type == "backEpilogue" then -- 1384
			fe.menus:resetInput() -- 1386
			fe.screen = "epilogue" -- 1387
		elseif act.type == "replayStory" then -- 1387
			clearSession() -- 1389
			refreshTitleSessionFlag() -- 1390
			enterPlayRoom( -- 1391
				officialStartIndex(), -- 1391
				"official", -- 1391
				true -- 1391
			) -- 1391
		elseif act.type == "backTitle" then -- 1391
			fe.menus:resetInput() -- 1393
			fe.screen = "title" -- 1394
		elseif act.type == "backPause" then -- 1394
			fe.menus:resetInput() -- 1396
			fe.screen = "play" -- 1397
		elseif act.type == "quit" then -- 1397
			quitGame() -- 1399
		end -- 1399
		return -- 1401
	end -- 1401
	if play == nil then -- 1401
		ensurePlay() -- 1406
	end -- 1406
	if play == nil then -- 1406
		return -- 1409
	end -- 1409
	local p = play -- 1411
	p.aimX = input.mx -- 1413
	p.aimY = input.my -- 1414
	local zoneTap = input.touchZoneTap -- 1416
	input.touchZoneTap = "" -- 1417
	local offers = p:getStoryTalentOffers() -- 1419
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1419
		if fe.hud.talentSelected >= #offers then -- 1419
			fe.hud.talentSelected = 0 -- 1422
		end -- 1422
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1422
			local idx = __TS__ParseInt( -- 1425
				string.sub(zoneTap, 8), -- 1425
				10 -- 1425
			) -- 1425
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1425
				input.fire.pressed = false -- 1427
			end -- 1427
		else -- 1427
			if input.talentDelta ~= 0 then -- 1427
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1431
				input.talentDelta = 0 -- 1432
			end -- 1432
			if input.talentConfirm then -- 1432
				p:chooseTalent(fe.hud.talentSelected) -- 1435
				input.talentConfirm = false -- 1436
				input.fire.pressed = false -- 1437
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1437
				input.fire.pressed = false -- 1440
			end -- 1440
		end -- 1440
	end -- 1440
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1440
		if input.navConfirm then -- 1440
			input.interact.pressed = true -- 1448
		end -- 1448
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1448
			flushProfile() -- 1451
			if p.run.source == "official" and hasSessionSave() then -- 1451
				clearSession() -- 1453
				refreshTitleSessionFlag() -- 1454
			end -- 1454
			fe.audio:stopRoomTransient() -- 1456
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1457
			fe.screen = "epilogue" -- 1461
			input:clearTransient(true) -- 1462
			input:consumeEdges() -- 1463
			return -- 1464
		end -- 1464
	end -- 1464
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1464
		p:closeCraftBench() -- 1469
		input:consumeEdges() -- 1470
		return -- 1471
	end -- 1471
	if not p.paused and input.pause.pressed then -- 1471
		p.paused = true -- 1474
		p.aimHold = 0 -- 1475
		p.bottleAimX = -1 -- 1476
		saveCurrentSession() -- 1477
		fe.menus:openPause() -- 1478
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1479
		input:clearTransient(true) -- 1480
		input:consumeEdges() -- 1481
	end -- 1481
	if p.paused then -- 1481
		clock:reset() -- 1486
		local pauseAct = fe:renderPlay( -- 1487
			frameDt, -- 1487
			p, -- 1487
			input, -- 1487
			stageVp.stageW, -- 1487
			stageVp.stageH -- 1487
		) -- 1487
		input:consumeEdges() -- 1488
		if pauseAct.type == "resume" then -- 1488
			p.paused = false -- 1490
		elseif pauseAct.type == "retry" then -- 1490
			ensurePlay({checkpoint = p.checkpoint}) -- 1492
		elseif pauseAct.type == "openChapters" then -- 1492
			fe.audio:stopRoomTransient() -- 1494
			fe.audio:setPaused(false) -- 1495
			fe.menus:openChapters(current) -- 1496
			fe.screen = "chapters" -- 1497
		elseif pauseAct.type == "toggleFullscreen" then -- 1497
			toggleFullscreen() -- 1499
		elseif pauseAct.type == "quit" then -- 1499
			quitGame() -- 1501
		elseif pauseAct.type == "toTitle" then -- 1501
			saveCurrentSession() -- 1503
			refreshTitleSessionFlag() -- 1504
			fe.menus:resetInput() -- 1505
			fe.screen = "title" -- 1506
		end -- 1506
		return -- 1508
	end -- 1508
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1511
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1512
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1512
		input:consumeEdges() -- 1515
		ensurePlay({checkpoint = p.checkpoint}) -- 1517
		return -- 1518
	end -- 1518
	local steps = clock:advance(frameDt) -- 1521
	local i = 0 -- 1522
	do -- 1522
		i = 0 -- 1523
		while i < steps do -- 1523
			input:beginStep(i == 0) -- 1524
			p:update(STEP, input) -- 1525
			input:endStep() -- 1526
			if p.wantRoom ~= "" then -- 1526
				break -- 1528
			end -- 1528
			i = i + 1 -- 1523
		end -- 1523
	end -- 1523
	if p.wantRoom ~= "" then -- 1523
		local key = p.wantRoom -- 1534
		p.wantRoom = "" -- 1535
		local idx = -1 -- 1536
		local j = 0 -- 1537
		do -- 1537
			j = 0 -- 1538
			while j < #ROOMS do -- 1538
				if ROOMS[j + 1].key == key then -- 1538
					idx = j -- 1540
				end -- 1540
				j = j + 1 -- 1538
			end -- 1538
		end -- 1538
		if idx >= 0 then -- 1538
			flushProfile() -- 1547
			local leaving = p:drainEvents() -- 1548
			if p.restartStory then -- 1548
				if storyRun ~= nil and storyRun.source == "official" then -- 1548
					clearSession() -- 1552
					refreshTitleSessionFlag() -- 1553
				end -- 1553
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1555
				storyRun = createRun(20261124, nextSource, profile) -- 1556
			end -- 1556
			current = idx -- 1558
			ensurePlay() -- 1559
			local fresh = play -- 1560
			if fresh ~= nil then -- 1560
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1560
					fresh.phase = "prologue-wake" -- 1563
				end -- 1563
				fresh:adoptEvents(leaving) -- 1565
			end -- 1565
			if not p.restartStory then -- 1565
				saveCurrentSession() -- 1568
			end -- 1568
			clock:reset() -- 1570
			dirty = true -- 1571
		end -- 1571
		return -- 1573
	end -- 1573
	flushProfile() -- 1577
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1577
		clearSession() -- 1579
		refreshTitleSessionFlag() -- 1580
	elseif p.sessionDirty then -- 1580
		saveCurrentSession() -- 1582
	end -- 1582
	fe:renderPlay( -- 1584
		frameDt, -- 1584
		p, -- 1584
		input, -- 1584
		stageVp.stageW, -- 1584
		stageVp.stageH -- 1584
	) -- 1584
end -- 1584
function redrawGraybox() -- 1588
	if draw == nil then -- 1588
		return -- 1590
	end -- 1590
	local w = viewW -- 1592
	local h = viewH -- 1593
	local room = ROOMS[current + 1] -- 1594
	draw:clear() -- 1596
	draw:drawRect( -- 1597
		Rect(0, h - TOP_H, w, TOP_H), -- 1597
		C_BG -- 1597
	) -- 1597
	draw:drawRect( -- 1598
		Rect(0, 0, w, BOTTOM_H), -- 1598
		C_BG -- 1598
	) -- 1598
	draw:drawSegment( -- 1599
		Vec2(0, h - TOP_H), -- 1599
		Vec2(w, h - TOP_H), -- 1599
		1, -- 1599
		Color(52, 54, 54, 255) -- 1599
	) -- 1599
	draw:drawSegment( -- 1600
		Vec2(0, BOTTOM_H), -- 1600
		Vec2(w, BOTTOM_H), -- 1600
		1, -- 1600
		Color(52, 54, 54, 255) -- 1600
	) -- 1600
	local v = computeView(room, w, h) -- 1602
	renderWorld( -- 1603
		draw, -- 1603
		room, -- 1603
		v, -- 1603
		w, -- 1603
		h -- 1603
	) -- 1603
	local roomTop = v.groundPx + room.height * v.scale -- 1605
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1606
	place( -- 1608
		titleLabel, -- 1608
		48, -- 1608
		h - 40, -- 1608
		0, -- 1608
		1 -- 1608
	) -- 1608
	place( -- 1609
		roomLabel, -- 1609
		48, -- 1609
		h - 96, -- 1609
		0, -- 1609
		1 -- 1609
	) -- 1609
	place( -- 1610
		captionLabel, -- 1610
		48, -- 1610
		h - 140, -- 1610
		0, -- 1610
		1 -- 1610
	) -- 1610
	place( -- 1612
		switchLabel, -- 1612
		48, -- 1612
		40, -- 1612
		0, -- 1612
		0 -- 1612
	) -- 1612
	place( -- 1613
		hintLabel, -- 1613
		48, -- 1613
		84, -- 1613
		0, -- 1613
		0 -- 1613
	) -- 1613
	place( -- 1614
		rulerLabel, -- 1614
		w - 216, -- 1614
		roomTop + 36 + v.scale * 0.5 - 14, -- 1614
		1, -- 1614
		0 -- 1614
	) -- 1614
	place( -- 1615
		standLabel, -- 1615
		48, -- 1615
		roomTop + 40, -- 1615
		0, -- 1615
		0 -- 1615
	) -- 1615
	place( -- 1616
		cartLabel, -- 1616
		48, -- 1616
		roomTop + 92, -- 1616
		0, -- 1616
		0 -- 1616
	) -- 1616
	if roomLabel ~= nil then -- 1616
		roomLabel.text = room.name -- 1619
	end -- 1619
	if captionLabel ~= nil then -- 1619
		captionLabel.text = room.caption -- 1622
	end -- 1622
	if hintLabel ~= nil then -- 1622
		local hintIdx = math.min(current, #HINTS - 1) -- 1625
		local lines = HINTS[hintIdx + 1] -- 1626
		local merged = lines[1] -- 1627
		do -- 1627
			local i = 1 -- 1628
			while i < #lines do -- 1628
				merged = (merged .. "    ") .. lines[i + 1] -- 1629
				i = i + 1 -- 1628
			end -- 1628
		end -- 1628
		hintLabel.text = merged -- 1631
	end -- 1631
	local specs = collectLabels(room, v, w) -- 1634
	local body = {} -- 1635
	local small = {} -- 1636
	do -- 1636
		local i = 0 -- 1637
		while i < #specs do -- 1637
			local s = specs[i + 1] -- 1638
			if s.size >= 24 then -- 1638
				body[#body + 1] = s -- 1640
			else -- 1640
				small[#small + 1] = s -- 1642
			end -- 1642
			i = i + 1 -- 1637
		end -- 1637
	end -- 1637
	applyPool(body, poolBody) -- 1645
	applyPool(small, poolSmall) -- 1646
	if LAYOUT_AUDIT then -- 1646
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1649
	end -- 1649
end -- 1649
function applyPool(specs, pool) -- 1653
	do -- 1653
		local i = 0 -- 1654
		while i < #pool do -- 1654
			local lb = pool[i + 1] -- 1655
			if i < #specs then -- 1655
				local s = specs[i + 1] -- 1657
				lb.text = s.text -- 1658
				lb.position = Vec2(s.x, s.y) -- 1659
				lb.anchor = Vec2(s.ax, s.ay) -- 1660
				lb.color = s.color -- 1661
				lb.visible = true -- 1662
			else -- 1662
				lb.visible = false -- 1664
			end -- 1664
			i = i + 1 -- 1654
		end -- 1654
	end -- 1654
end -- 1654
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
			if key == "1" then -- 525
				play:chooseTalent(0) -- 530
				if input ~= nil then -- 530
					input:consumePickRoom() -- 531
				end -- 531
				return -- 532
			end -- 532
			if key == "2" then -- 532
				play:chooseTalent(1) -- 535
				if input ~= nil then -- 535
					input:consumePickRoom() -- 536
				end -- 536
				return -- 537
			end -- 537
			if key == "3" then -- 537
				play:chooseTalent(2) -- 540
				if input ~= nil then -- 540
					input:consumePickRoom() -- 541
				end -- 541
				return -- 542
			end -- 542
		end -- 542
		local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 545
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 545
			fe.menus:onKeyEvent(key) -- 547
		end -- 547
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay or mode == 2) then -- 547
			if key == "E" then -- 547
				input.interact.pressed = true -- 551
			elseif key == "Space" then -- 551
				input.jump.pressed = true -- 553
			elseif key == "Escape" then -- 553
				input.pause.pressed = true -- 555
			elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 555
				input.retry.pressed = true -- 557
			end -- 557
		end -- 557
		if mode == 2 and (run and run.trial) ~= nil then -- 557
			return -- 560
		end -- 560
		if isReleaseBuild() then -- 560
			return -- 561
		end -- 561
		if key == "F1" then -- 561
			if mode == 2 then -- 561
				current = 0 -- 564
				play = nil -- 565
				ensurePlay() -- 566
			else -- 566
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 568
			end -- 568
		elseif key == "F2" then -- 568
			setMode(0) -- 571
		elseif key == "1" then -- 571
			pickByIndex(0) -- 573
		elseif key == "2" then -- 573
			pickByIndex(1) -- 575
		elseif key == "3" then -- 575
			pickByIndex(2) -- 577
		elseif key == "4" then -- 577
			pickByIndex(3) -- 579
		elseif key == "5" then -- 579
			pickByIndex(4) -- 581
		elseif key == "6" then -- 581
			pickByIndex(5) -- 583
		elseif key == "7" then -- 583
			pickByIndex(6) -- 585
		elseif key == "8" then -- 585
			pickByIndex(7) -- 587
		end -- 587
	end) -- 515
	viewW = View.size.width -- 591
	viewH = View.size.height -- 592
	applySize() -- 593
	local reg = _G.package.loaded -- 596
	reg["watch.input"] = input -- 597
	reg["watch.touch"] = touchRouter -- 598
	reg["watch.gamepad"] = gamepadRouter -- 599
	reg["watch.fe"] = { -- 600
		setScreen = function(sc) -- 601
			if fe == nil then -- 601
				return -- 603
			end -- 603
			setMode(1) -- 605
			fe.screen = sc -- 606
			if sc == "splash" then -- 606
				fe.menus:resetSplash() -- 608
			elseif sc == "chapters" then -- 608
				fe.menus:openChapters() -- 610
			elseif sc == "epilogue" then -- 610
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 612
			elseif sc == "history" then -- 612
				fe.menus:openHistory(false) -- 617
			else -- 617
				fe.menus:resetInput() -- 619
			end -- 619
			if sc == "play" then -- 619
				ensurePlay() -- 622
			end -- 622
		end, -- 601
		jumpRoom = function(keyOrIdx) -- 625
			local idx = -1 -- 626
			if type(keyOrIdx) == "number" then -- 626
				idx = keyOrIdx -- 628
			else -- 628
				local k = 0 -- 630
				do -- 630
					k = 0 -- 631
					while k < #ROOMS do -- 631
						if ROOMS[k + 1].key == keyOrIdx then -- 631
							idx = k -- 633
						end -- 633
						k = k + 1 -- 631
					end -- 631
				end -- 631
			end -- 631
			if idx >= 0 and idx < #ROOMS then -- 631
				enterPlayRoom(idx, "debug") -- 638
			end -- 638
		end, -- 625
		getPlay = function() return play end, -- 641
		getFrontend = function() return fe end, -- 642
		startStory = function() -- 644
			enterPlayRoom( -- 645
				officialStartIndex(), -- 645
				"official", -- 645
				true -- 645
			) -- 645
			return play -- 646
		end, -- 644
		previewChapter = function(idx) -- 649
			enterPlayRoom(idx, "chapter") -- 650
			return play -- 651
		end, -- 649
		getStoryRun = function() return storyRun end, -- 653
		getProfilePending = function() return profilePending() end, -- 654
		flushProfileNow = function() return flushProfile() end, -- 655
		getProfile = function() return profile end, -- 657
		getProfileStatus = function() return profileStatus end, -- 658
		getProfileDetail = function() return profileDetail end, -- 659
		useTestSave = function(name) -- 660
			setSaveFile(name) -- 661
			setSessionFile(name == "" and "" or name .. ".session") -- 662
			clearProfilePending() -- 663
			local loaded = loadSave() -- 664
			profile = loaded.state -- 665
			profileStatus = loaded.status -- 666
			profileDetail = loaded.detail -- 667
			refreshTitleSessionFlag() -- 668
		end, -- 660
		useTestSession = function(name) -- 670
			setSessionFile(name) -- 671
			refreshTitleSessionFlag() -- 672
		end, -- 670
		getSessionFile = getSessionFile, -- 674
		hasSessionSave = hasSessionSave, -- 675
		saveSessionNow = function() return saveCurrentSession() end, -- 676
		clearSessionNow = function() -- 677
			local ok = clearSession() -- 678
			refreshTitleSessionFlag() -- 679
			return ok -- 680
		end, -- 677
		continueStory = function() return continueOfficialStory() end, -- 682
		saveNow = function() return saveSave(profile) end, -- 683
		getSaveFile = getSaveFile, -- 684
		isRelease = function() return isReleaseBuild() end, -- 685
		getReleaseVersion = function() -- 686
			local ____opt_32 = getReleaseConfig() -- 686
			return ____opt_32 and ____opt_32.version or "dev" -- 686
		end, -- 686
		toggleFullscreen = function() return toggleFullscreen() end, -- 687
		quitGame = function() return quitGame() end, -- 688
		startTrial = function() return startTrial() end, -- 689
		handleBackButton = function() return handleBackButton() end, -- 690
		getViewport = function() return stageVp end, -- 691
		getTouchController = function() return touchControls end, -- 692
		getTouchRouter = function() return touchRouter end, -- 693
		getGamepad = function() return gamepadRouter end, -- 694
		setGamepadSim = function(state) -- 695
			if gamepadRouter ~= nil then -- 695
				gamepadRouter:setSimulatedState(state) -- 696
			end -- 696
		end, -- 695
		injectTouch = function(phase, id, x, y, fromMouse) -- 698
			if touchRouter ~= nil then -- 698
				touchRouter:injectTouch( -- 699
					phase, -- 699
					id, -- 699
					x, -- 699
					y, -- 699
					fromMouse -- 699
				) -- 699
			end -- 699
		end, -- 698
		getInputMode = function() return input and input.inputMode or "kbm" end, -- 701
		setInputMode = function(m) -- 702
			if input ~= nil then -- 702
				input:setInputMode(m) -- 703
			end -- 703
		end, -- 702
		setModePref = function(pref) -- 705
			if input ~= nil then -- 705
				input:setModePref(pref) -- 706
			end -- 706
		end, -- 705
		applyViewportForTest = function(w, h) -- 708
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 708
				testViewportOverride = {w = w, h = h} -- 710
				viewW = w -- 711
				viewH = h -- 712
			else -- 712
				testViewportOverride = nil -- 714
				viewW = View.size.width -- 715
				viewH = View.size.height -- 716
			end -- 716
			applySize() -- 718
			dirty = true -- 719
			return stageVp -- 720
		end, -- 708
		getToast = function() return fe and fe:getToastText() or "" end -- 722
	} -- 722
	if mode == 1 and startScreen == "play" then -- 722
		ensurePlay() -- 726
	end -- 726
	parent:schedule(function(frameDt) -- 729
		tick(frameDt) -- 730
		return false -- 731
	end) -- 729
end -- 388
return ____exports -- 388