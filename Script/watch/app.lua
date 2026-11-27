-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local isReleaseBuild, onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, place, setMode, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, pickByIndex, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, touchRouter, gamepadRouter, touchControls, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock, trialTalentSelected -- 98
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
	if audioUnlocked or fe == nil then -- 103
		return -- 104
	end -- 104
	audioUnlocked = true -- 106
	fe.audio:unlockAndResyncAfterGesture() -- 107
end -- 107
function toggleFullscreen() -- 110
	if not canToggleFullscreen() then -- 111
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
	if input ~= nil then -- 126
		input:clearTransient(false) -- 126
	end -- 126
	if fe ~= nil then -- 127
		fe.audio:stopRoomTransient() -- 128
	end -- 128
	if not canQuitApp() then -- 130
		current = 0 -- 132
		play = nil -- 133
		run = nil -- 134
		setMode(1) -- 135
		if fe ~= nil then -- 136
			fe.audio:stopRoomTransient() -- 137
			fe.screen = "title" -- 138
			fe.menus:resetInput() -- 139
		end -- 139
		return -- 141
	end -- 141
	App:shutdown() -- 143
end -- 143
function canSaveSession() -- 215
	if mode ~= 1 or play == nil or storyRun == nil then -- 216
		return false -- 217
	end -- 217
	if storyRun.source ~= "official" or play.run.finished then -- 219
		return false -- 220
	end -- 220
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 222
		return false -- 223
	end -- 223
	return true -- 225
end -- 225
function refreshTitleSessionFlag() -- 228
	if fe ~= nil then -- 229
		fe.menus.hasSession = hasSessionSave() -- 230
	end -- 230
end -- 230
function saveCurrentSession() -- 234
	if not canSaveSession() or play == nil then -- 235
		return false -- 236
	end -- 236
	play.sessionDirty = false -- 238
	local ok = saveSession(play:exportSession()) -- 239
	refreshTitleSessionFlag() -- 240
	return ok -- 241
end -- 241
function continueOfficialStory() -- 244
	local res = loadSession() -- 245
	if res.status ~= "ok" or res.state == nil then -- 246
		refreshTitleSessionFlag() -- 247
		return nil -- 248
	end -- 248
	local s = res.state -- 250
	local idx = roomIndexByKey(s.roomKey) -- 251
	if ROOMS[idx + 1].key ~= s.roomKey then -- 252
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
	if s.campaignRoute ~= nil then -- 289
		storyRun.route = s.campaignRoute -- 290
	end -- 290
	if s.joined ~= nil then -- 292
		storyRun.joined = s.joined -- 293
	end -- 293
	if s.c1Latch ~= nil then -- 295
		storyRun.c1Latch = s.c1Latch -- 296
	end -- 296
	if s.c2Latch ~= nil then -- 298
		storyRun.c2Latch = s.c2Latch -- 299
	end -- 299
	if s.props ~= nil then -- 301
		do -- 301
			k = 0 -- 302
			while k < #s.props do -- 302
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 303
				local pid = parts[1] -- 304
				if pid ~= nil and pid ~= "" then -- 305
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
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 316
		stTalents.randomState = s.talentSeed -- 317
	end -- 317
	stTalents.room = s.talentRoom or "" -- 319
	stTalents.ranks.vitality = s.talentVitality or 0 -- 320
	stTalents.ranks.reload = s.talentReload or 0 -- 321
	stTalents.ranks.guard = s.talentGuard or 0 -- 322
	stTalents.ranks.craft = s.talentCraft or 0 -- 323
	if s.talentOffers ~= nil then -- 324
		do -- 324
			k = 0 -- 325
			while k < #s.talentOffers do -- 325
				local t = s.talentOffers[k + 1] -- 326
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 327
					local ____stTalents_offers_17 = stTalents.offers -- 328
					____stTalents_offers_17[#____stTalents_offers_17 + 1] = t -- 328
				end -- 328
				k = k + 1 -- 325
			end -- 325
		end -- 325
	end -- 325
	storyRun.story.talents = stTalents -- 332
	current = idx -- 333
	setMode(1) -- 334
	if fe ~= nil then -- 335
		fe.screen = "play" -- 336
	end -- 336
	play = nil -- 338
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 339
	local cur = play -- 340
	if cur ~= nil then -- 341
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 342
			cur.cartAxle = s.cartAxle -- 343
			cur.cartDocked = s.cartDocked -- 344
		end -- 344
		if s.playerX ~= nil and s.playerX >= 0 then -- 346
			cur.player.x = math.max( -- 347
				cur.room.minX + 16, -- 347
				math.min(cur.room.maxX - 16, s.playerX) -- 347
			) -- 347
			cur.player.y = math.max(0, s.playerY or 0) -- 348
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 349
				cur.player.depth = math.max( -- 350
					cur.room.depth.min, -- 350
					math.min(cur.room.depth.max, s.playerDepth) -- 350
				) -- 350
			end -- 350
		end -- 350
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 353
			cur.gateTick = s.gateTick -- 354
		end -- 354
		if cur.room.key == "village" then -- 356
			if s.hasBottle == true then -- 357
				cur.hasBottle = true -- 357
			end -- 357
			if s.villagePassed == true then -- 358
				cur.passed = true -- 358
			end -- 358
		end -- 358
	end -- 358
	return play -- 361
end -- 361
function place(lb, x, y, ax, ay) -- 379
	if lb == nil then -- 380
		return -- 381
	end -- 381
	lb.position = Vec2(x, y) -- 383
	lb.anchor = Vec2(ax, ay) -- 384
	lb.visible = true -- 385
end -- 385
function setMode(nextMode) -- 735
	mode = nextMode -- 736
	if grayboxLayer ~= nil then -- 737
		grayboxLayer.visible = mode == 0 -- 738
	end -- 738
	if fe ~= nil then -- 740
		fe:setVisible(mode == 1) -- 741
	end -- 741
	if campaignLayer ~= nil then -- 743
		campaignLayer.visible = mode == 2 -- 744
	end -- 744
	dirty = true -- 746
	clock:reset() -- 747
end -- 747
function flushProfile() -- 754
	local cur = play -- 755
	if cur ~= nil and cur.archiveDirty then -- 756
		cur.archiveDirty = false -- 757
		markProfilePending(profile) -- 758
	end -- 758
	local ok = flushSaveProfile() -- 760
	if not ok and cur ~= nil then -- 761
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
			if ROOMS[i + 1].key == key then -- 777
				return i -- 778
			end -- 778
			i = i + 1 -- 776
		end -- 776
	end -- 776
	return 0 -- 781
end -- 781
function enterPlayRoom(idx, source, fresh) -- 784
	if source == nil then -- 784
		source = "debug" -- 784
	end -- 784
	if fresh == nil then -- 784
		fresh = false -- 784
	end -- 784
	current = idx -- 785
	setMode(1) -- 786
	if fe ~= nil then -- 787
		fe.screen = "play" -- 788
	end -- 788
	play = nil -- 790
	if fresh or source == "chapter" or storyRun == nil then -- 792
		storyRun = createRun(20261124, source, profile) -- 793
	else -- 793
		storyRun.source = source -- 795
	end -- 795
	ensurePlay() -- 797
	local firstPlay = play -- 799
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 800
		firstPlay.phase = "prologue-wake" -- 801
	end -- 801
	flushProfile() -- 803
end -- 803
function pickByIndex(idx, source) -- 806
	if source == nil then -- 806
		source = "debug" -- 806
	end -- 806
	if mode == 2 then -- 807
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 808
			return -- 809
		end -- 809
		current = idx -- 811
		play = nil -- 812
		clock:reset() -- 813
		ensurePlay() -- 814
		return -- 815
	end -- 815
	if idx < 0 or idx >= #ROOMS then -- 817
		return -- 818
	end -- 818
	flushProfile() -- 820
	if storyRun ~= nil then -- 821
		storyRun.source = source -- 822
	end -- 822
	current = idx -- 824
	dirty = true -- 825
	play = nil -- 826
	clock:reset() -- 827
	if mode == 1 then -- 828
		if fe ~= nil then -- 829
			fe.screen = "play" -- 830
		end -- 830
		ensurePlay() -- 832
	end -- 832
end -- 832
function applySize() -- 836
	if root == nil then -- 837
		return -- 838
	end -- 838
	root.size = Size(viewW, viewH) -- 840
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 841
	stageVp = computeStageViewport(viewW, viewH) -- 842
	if input ~= nil then -- 843
		input:setStageViewport(stageVp) -- 844
	end -- 844
	if fe ~= nil then -- 846
		fe:setStagePlacement(stageVp) -- 847
	end -- 847
	if campaignLayer ~= nil then -- 849
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 850
	end -- 850
	if grayboxLayer ~= nil then -- 852
		grayboxLayer.position = Vec2(0, 0) -- 853
	end -- 853
end -- 853
function syncFrameAdapters(frameDt) -- 857
	if input == nil then -- 858
		return -- 859
	end -- 859
	local p = play -- 861
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 862
	local isTrialMode = mode == 2 and p ~= nil -- 863
	local gameplayActive = isPlayMode or isTrialMode -- 864
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 866
		p, -- 868
		stageVp.stageW, -- 868
		stageVp.stageH, -- 868
		input:isTouchMode() -- 868
	) or ({}) -- 869
	if touchControls ~= nil and touchRouter ~= nil then -- 871
		local isFs = false -- 872
		if canToggleFullscreen() then -- 873
			do -- 873
				local function ____catch() -- 873
					isFs = false -- 877
				end -- 877
				local ____try = pcall(function() -- 877
					isFs = App.fullScreen -- 875
				end) -- 875
				if not ____try then -- 875
					____catch() -- 875
				end -- 875
			end -- 875
		end -- 875
		local ____touchControls_55 = touchControls -- 880
		local ____touchControls_syncContext_56 = touchControls.syncContext -- 880
		local ____stageVp_48 = stageVp -- 881
		local ____mode_49 = mode -- 882
		local ____temp_50 = fe ~= nil and fe.screen or "title" -- 883
		local ____run_51 = run -- 885
		local ____temp_52 = fe ~= nil and fe.cam or nil -- 886
		local ____input_53 = input -- 887
		local ____touchRouter_54 = touchRouter -- 888
		local ____temp_46 -- 889
		if fe ~= nil then -- 889
			____temp_46 = fe.contract:isAssistHintsEnabled() -- 889
		else -- 889
			____temp_46 = false -- 889
		end -- 889
		local ____temp_47 -- 890
		if fe ~= nil then -- 890
			____temp_47 = fe.audio:isAllMuted() -- 890
		else -- 890
			____temp_47 = false -- 890
		end -- 890
		____touchControls_syncContext_56(____touchControls_55, { -- 880
			viewport = ____stageVp_48, -- 881
			mode = ____mode_49, -- 882
			screen = ____temp_50, -- 883
			play = p, -- 884
			run = ____run_51, -- 885
			cam = ____temp_52, -- 886
			input = ____input_53, -- 887
			router = ____touchRouter_54, -- 888
			assistHintsEnabled = ____temp_46, -- 889
			isMuted = ____temp_47, -- 890
			isFullscreen = isFs, -- 891
			storyTalentBoxes = storyTalentBoxes, -- 892
			dt = frameDt -- 893
		}) -- 893
	end -- 893
	if gamepadRouter ~= nil then -- 897
		local trial = run and run.trial -- 898
		local trialEnded = isTrialMode and trial ~= nil and (trial.lost or (run and run.finished) == true) -- 899
		local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 900
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 901
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 904
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 905
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 906
		local ____temp_61 -- 909
		if isPlayMode and p ~= nil then -- 909
			____temp_61 = isCutsceneBlockingPlay(p) -- 909
		else -- 909
			____temp_61 = false -- 909
		end -- 909
		local cutsceneBlocking = ____temp_61 -- 909
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 910
		local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 912
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 913
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 915
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 917
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 920
		local playerScreenX = stageVp.stageW * 0.5 -- 922
		local playerScreenY = stageVp.stageH * 0.38 -- 923
		if p ~= nil then -- 924
			if isPlayMode and fe ~= nil then -- 925
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 926
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 927
			else -- 927
				local vz = p.view.zoom > 0 and p.view.zoom or 1 -- 930
				playerScreenX = stageVp.stageW * 0.5 + (p.player.x + p.player.facing * 8 - p.cam.x) * vz -- 931
				playerScreenY = stageVp.stageH * 0.5 + (p.player.y + p.player.h * 0.72 + p.player.depth * DEPTH_Y_SCALE - p.cam.y) * vz -- 932
			end -- 932
		end -- 932
		local enemyTargets = canShoot and p ~= nil and (isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or collectTrialAimTargets(p, stageVp.stageW, stageVp.stageH)) or ({}) -- 936
		local gpCtx = { -- 942
			stageW = stageVp.stageW, -- 943
			stageH = stageVp.stageH, -- 944
			uiScale = stageVp.uiScale, -- 945
			modal = modal, -- 946
			gameplayActive = gameplayActive, -- 947
			reloadActive = reloadActive, -- 948
			craftActive = craftActive, -- 949
			talentOfferCount = talentOfferCount, -- 950
			childMode = p ~= nil and p.childMode, -- 951
			allowDepth = allowDepth, -- 952
			canShoot = canShoot, -- 953
			canBottleAim = canBottleAim, -- 954
			playerRolling = p ~= nil and p.player.rollT > 0, -- 955
			inLowArch = inLowArch, -- 956
			inTowerEnd = inTowerEnd, -- 957
			playerFacing = p ~= nil and p.player.facing or 1, -- 958
			playerScreenX = playerScreenX, -- 959
			playerScreenY = playerScreenY, -- 960
			enemyTargets = enemyTargets -- 961
		} -- 961
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 963
	end -- 963
end -- 963
function renderTouchOverlay() -- 967
	if touchControls ~= nil and touchRouter ~= nil then -- 968
		touchControls:render(touchRouter) -- 969
	end -- 969
end -- 969
function tick(frameDt) -- 973
	appClock = appClock + math.min( -- 974
		0.05, -- 974
		math.max(0, frameDt) -- 974
	) -- 974
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 975
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 976
	if w ~= viewW or h ~= viewH then -- 977
		viewW = w -- 978
		viewH = h -- 979
		applySize() -- 980
		dirty = true -- 981
	end -- 981
	if input == nil then -- 983
		return -- 984
	end -- 984
	syncFrameAdapters(frameDt) -- 986
	input:update() -- 987
	if input.userInteracted then -- 989
		onFirstUserGesture() -- 990
	end -- 990
	if input.muteTogglePressed and fe ~= nil then -- 992
		input.muteTogglePressed = false -- 993
		fe.audio:toggleAllMuted() -- 994
	end -- 994
	if input.fullscreenTogglePressed then -- 996
		input.fullscreenTogglePressed = false -- 997
		toggleFullscreen() -- 998
	end -- 998
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 1000
		input.artifactTogglePressed = false -- 1001
		play:toggleArtifactWeapon() -- 1002
	end -- 1002
	if input.bottleCanceled and play ~= nil then -- 1004
		input.bottleCanceled = false -- 1005
		play.aimHold = 0 -- 1006
		play.bottleAimX = -1 -- 1007
	end -- 1007
	if mode == 2 and (run and run.trial) ~= nil then -- 1010
		tickCampaign(frameDt) -- 1011
		renderTouchOverlay() -- 1012
		return -- 1013
	end -- 1013
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 1016
		play:chooseTalent(input.pickRoom - 1) -- 1019
		input.pickRoom = 0 -- 1020
	end -- 1020
	if isReleaseBuild() then -- 1023
		input.toggleView.pressed = false -- 1024
		input.pickRoom = 0 -- 1025
		input.tab.pressed = false -- 1026
	else -- 1026
		if input.toggleView.pressed then -- 1029
			input.toggleView.pressed = false -- 1030
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 1031
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 1032
				ensurePlay() -- 1033
			end -- 1033
		end -- 1033
		if input.pickRoom ~= 0 then -- 1038
			local idx = input.pickRoom - 1 -- 1039
			input.pickRoom = 0 -- 1040
			pickByIndex(idx) -- 1041
		elseif input.tab.pressed then -- 1042
			input.tab.pressed = false -- 1043
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 1044
				pickByIndex((current + 1) % #ROOMS) -- 1045
			end -- 1045
		end -- 1045
	end -- 1045
	if mode == 2 then -- 1050
		tickCampaign(frameDt) -- 1051
	elseif mode == 1 then -- 1052
		tickFrontend(frameDt) -- 1053
	elseif dirty then -- 1054
		redrawGraybox() -- 1055
		dirty = false -- 1056
	end -- 1056
	renderTouchOverlay() -- 1058
end -- 1058
function registerPlay() -- 1062
	local reg = _G.package.loaded -- 1063
	reg["watch.play"] = play -- 1064
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 1065
	reg["watch.room"] = rooms[current + 1].key -- 1066
end -- 1066
function ensurePlay(resume) -- 1070
	if mode == 2 then -- 1071
		if run == nil then -- 1072
			run = createRun() -- 1073
		end -- 1073
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 1075
	else -- 1075
		if storyRun == nil then -- 1079
			storyRun = createRun(20261124, "debug", profile) -- 1080
		end -- 1080
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1082
	end -- 1082
	registerPlay() -- 1084
	clock:reset() -- 1085
	if fe ~= nil and mode == 1 then -- 1086
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1087
	elseif fe ~= nil and mode == 2 then -- 1088
		fe:resetTrialAudio(play) -- 1089
	end -- 1089
end -- 1089
function startTrial() -- 1093
	current = 0 -- 1094
	trialTalentSelected = 0 -- 1095
	run = createTrial(App.rand) -- 1096
	setMode(2) -- 1097
	ensurePlay() -- 1098
end -- 1098
function tickCampaign(frameDt) -- 1101
	if input == nil then -- 1102
		return -- 1103
	end -- 1103
	if play == nil then -- 1105
		ensurePlay() -- 1106
	end -- 1106
	if play == nil then -- 1108
		return -- 1109
	end -- 1109
	local p = play -- 1111
	p.aimX = input.mx -- 1112
	p.aimY = input.my -- 1113
	local zoneTap = input.touchZoneTap -- 1115
	input.touchZoneTap = "" -- 1116
	local trial = run and run.trial -- 1118
	if trial ~= nil then -- 1119
		local ended = trial.lost or (run and run.finished) == true -- 1120
		local pick = input.pickRoom -- 1121
		input.pickRoom = 0 -- 1122
		if zoneTap == "trial:resume" and p.paused and not ended then -- 1124
			p.paused = false -- 1125
			clock:reset() -- 1126
			input:consumeEdges() -- 1127
			drawCampaign(p) -- 1128
			return -- 1129
		end -- 1129
		if zoneTap == "trial:retry" then -- 1131
			input:consumeEdges() -- 1132
			startTrial() -- 1133
			return -- 1134
		end -- 1134
		if zoneTap == "trial:title" then -- 1136
			input:consumeEdges() -- 1137
			current = 0 -- 1138
			play = nil -- 1139
			run = nil -- 1140
			setMode(1) -- 1141
			if fe ~= nil then -- 1142
				fe.audio:stopRoomTransient() -- 1143
				fe.screen = "title" -- 1144
				fe.menus:resetInput() -- 1145
			end -- 1145
			return -- 1147
		end -- 1147
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1150
			input:consumeEdges() -- 1151
			current = 0 -- 1152
			play = nil -- 1153
			run = nil -- 1154
			setMode(1) -- 1155
			if fe ~= nil then -- 1156
				fe.audio:stopRoomTransient() -- 1157
				fe.screen = "title" -- 1158
				fe.menus:resetInput() -- 1159
			end -- 1159
			return -- 1161
		end -- 1161
		if ended or p.paused and input.retry.pressed then -- 1163
			local restart = input.retry.pressed or ended and input.navConfirm -- 1164
			input:consumeEdges() -- 1165
			if restart then -- 1166
				startTrial() -- 1166
			else -- 1166
				drawCampaign(p) -- 1167
			end -- 1167
			return -- 1168
		end -- 1168
		input.retry.pressed = false -- 1170
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1171
			if trialTalentSelected >= #trial.offers then -- 1172
				trialTalentSelected = 0 -- 1173
			end -- 1173
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1175
				local idx = __TS__ParseInt( -- 1176
					string.sub(zoneTap, 8), -- 1176
					10 -- 1176
				) -- 1176
				if idx >= 0 and idx < #trial.offers then -- 1177
					p:chooseTalent(idx) -- 1178
				end -- 1178
			elseif pick > 0 then -- 1180
				p:chooseTalent(pick - 1) -- 1181
			else -- 1181
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1183
				if delta ~= 0 then -- 1186
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1187
				end -- 1187
				if input.talentConfirm or input.navConfirm then -- 1189
					p:chooseTalent(trialTalentSelected) -- 1190
				end -- 1190
			end -- 1190
			input:consumeEdges() -- 1193
			clock:reset() -- 1194
			if fe ~= nil then -- 1195
				fe:syncTrialAudio(frameDt, p, #trial.offers) -- 1195
			end -- 1195
			drawCampaign(p) -- 1196
			return -- 1197
		end -- 1197
	end -- 1197
	if input.retry.pressed then -- 1201
		input.retry.pressed = false -- 1202
		input:consumeEdges() -- 1203
		play = nil -- 1205
		ensurePlay() -- 1206
		return -- 1207
	end -- 1207
	if input.pause.pressed or p.paused and input.navBack then -- 1209
		input.pause.pressed = false -- 1210
		p.paused = not p.paused -- 1211
		if fe ~= nil then -- 1212
			fe.audio:playUi(p.paused and "ui:pause_open" or "ui:pause_close", p.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 1212
		end -- 1212
		clock:reset() -- 1213
		input:consumeEdges() -- 1214
	end -- 1214
	if p.paused then -- 1216
		if fe ~= nil then -- 1217
			fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1217
		end -- 1217
		drawCampaign(p) -- 1218
		return -- 1219
	end -- 1219
	local steps = clock:advance(frameDt) -- 1222
	local i = 0 -- 1223
	do -- 1223
		i = 0 -- 1224
		while i < steps do -- 1224
			input:beginStep(i == 0) -- 1225
			p:update(STEP, input) -- 1226
			input:endStep() -- 1227
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1228
				break -- 1229
			end -- 1229
			i = i + 1 -- 1224
		end -- 1224
	end -- 1224
	if fe ~= nil then -- 1232
		fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1232
	end -- 1232
	if p.wantRoom ~= "" then -- 1234
		local key = p.wantRoom -- 1235
		p.wantRoom = "" -- 1236
		local idx = -1 -- 1237
		local j = 0 -- 1238
		do -- 1238
			j = 0 -- 1239
			while j < #CAMPAIGN_ROOMS do -- 1239
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1240
					idx = j -- 1241
				end -- 1241
				j = j + 1 -- 1239
			end -- 1239
		end -- 1239
		if idx >= 0 then -- 1244
			current = idx -- 1245
			play = nil -- 1246
			ensurePlay() -- 1247
		end -- 1247
		return -- 1249
	end -- 1249
	drawCampaign(p) -- 1251
end -- 1251
function goalLabel(goal) -- 1254
	if goal == "dock_cart" then -- 1255
		return "推车入窝并抬闩" -- 1256
	end -- 1256
	if goal == "raise_latch" then -- 1258
		return "抬闩开侧门" -- 1259
	end -- 1259
	return "到段出口" -- 1261
end -- 1261
function drawCampaign(p) -- 1264
	if campaignDraw == nil then -- 1265
		return -- 1266
	end -- 1266
	local w = stageVp.stageW -- 1268
	local h = stageVp.stageH -- 1269
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1270
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1271
	p:draw(campaignDraw, w, h) -- 1272
	local room = CAMPAIGN_ROOMS[current + 1] -- 1273
	local c = room.campaign -- 1274
	local r = run -- 1275
	local line = room.name -- 1276
	if c ~= nil then -- 1277
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget * 60) -- 1278
	end -- 1278
	if p.paused then -- 1281
		line = line .. "  · 已暂停 Esc 继续" -- 1282
	end -- 1282
	local trial = r and r.trial -- 1284
	if trial ~= nil and r ~= nil then -- 1285
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 1286
		if p.paused then -- 1287
			line = line .. " · 暂停" -- 1287
		elseif trial.lost then -- 1288
			line = line .. " · 护送失败" -- 1288
		elseif r.finished then -- 1289
			line = line .. " · 护送完成" -- 1289
		elseif #trial.offers > 0 then -- 1290
			line = line .. " · 选择本段本领" -- 1290
		elseif c ~= nil then -- 1291
			line = line .. " · " .. goalLabel(c.goal) -- 1291
		end -- 1291
	end -- 1291
	if campaignHud ~= nil then -- 1293
		campaignHud.text = line -- 1294
		campaignHud.position = Vec2(24 + safeL, h - 14 - safeT) -- 1295
		campaignHud.visible = true -- 1296
	end -- 1296
	if campaignSub ~= nil then -- 1298
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 1299
		if r ~= nil then -- 1300
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 1301
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 1302
		end -- 1302
		if p.flash ~= "" then -- 1307
			sub = (sub .. " · ") .. p.flash -- 1308
		end -- 1308
		if trial ~= nil and r ~= nil then -- 1310
			local gpMode = input ~= nil and input:isGamepadMode() -- 1311
			local touchMode = input ~= nil and input:isTouchMode() -- 1312
			if trial.lost or r.finished then -- 1313
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · A 再开一局 · START 返回标题" or (touchMode and " · 点下方按钮再开或返回标题" or " · R 再开一局 · Esc 返回标题")) -- 1314
			elseif p.paused then -- 1315
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · START 继续 · 长按BACK 重开 · Y 返回标题" or (touchMode and " · 点下方按钮继续/重开/返回标题" or " · Esc 继续 · R 重新开局 · E 返回标题")) -- 1316
			elseif #trial.offers > 0 then -- 1317
				sub = table.concat( -- 1318
					__TS__ArrayMap( -- 1318
						trial.offers, -- 1318
						function(____, talent, index) -- 1318
							local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1319
							return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1320
						end -- 1318
					), -- 1318
					"　" -- 1321
				) -- 1321
			else -- 1321
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 1323
			end -- 1323
		end -- 1323
		campaignSub.text = sub -- 1326
		campaignSub.position = Vec2(24 + safeL, h - 44 - safeT) -- 1327
		campaignSub.visible = true -- 1328
	end -- 1328
end -- 1328
function tickFrontend(frameDt) -- 1332
	if fe == nil or input == nil then -- 1333
		return -- 1334
	end -- 1334
	if fe.screen ~= "play" then -- 1338
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1339
		input:consumeEdges() -- 1340
		if act.type == "splashDone" then -- 1341
			fe.menus:resetInput() -- 1342
			fe.screen = "title" -- 1343
		elseif act.type == "trial" then -- 1344
			startTrial() -- 1345
		elseif act.type == "continue" then -- 1346
			if continueOfficialStory() == nil then -- 1347
				enterPlayRoom( -- 1348
					officialStartIndex(), -- 1348
					"official", -- 1348
					true -- 1348
				) -- 1348
			end -- 1348
		elseif act.type == "start" then -- 1350
			clearSession() -- 1352
			refreshTitleSessionFlag() -- 1353
			enterPlayRoom( -- 1354
				officialStartIndex(), -- 1354
				"official", -- 1354
				true -- 1354
			) -- 1354
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1355
			enterPlayRoom(act.roomIndex, "chapter") -- 1356
		elseif act.type == "openChapters" then -- 1357
			fe.menus:openChapters() -- 1358
			fe.screen = "chapters" -- 1359
		elseif act.type == "openControls" then -- 1360
			fe.menus:resetInput() -- 1361
			fe.screen = "controls" -- 1362
		elseif act.type == "openHistory" then -- 1363
			fe.menus:openHistory(true) -- 1364
			fe.screen = "history" -- 1365
		elseif act.type == "backEpilogue" then -- 1366
			fe.menus:resetInput() -- 1367
			fe.screen = "epilogue" -- 1368
		elseif act.type == "replayStory" then -- 1369
			clearSession() -- 1370
			refreshTitleSessionFlag() -- 1371
			enterPlayRoom( -- 1372
				officialStartIndex(), -- 1372
				"official", -- 1372
				true -- 1372
			) -- 1372
		elseif act.type == "backTitle" then -- 1373
			fe.menus:resetInput() -- 1374
			fe.screen = "title" -- 1375
		elseif act.type == "backPause" then -- 1376
			fe.menus:resetInput() -- 1377
			fe.screen = "play" -- 1378
		elseif act.type == "quit" then -- 1379
			quitGame() -- 1380
		end -- 1380
		return -- 1382
	end -- 1382
	if play == nil then -- 1386
		ensurePlay() -- 1387
	end -- 1387
	if play == nil then -- 1389
		return -- 1390
	end -- 1390
	local p = play -- 1392
	p.aimX = input.mx -- 1394
	p.aimY = input.my -- 1395
	local zoneTap = input.touchZoneTap -- 1397
	input.touchZoneTap = "" -- 1398
	local offers = p:getStoryTalentOffers() -- 1400
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1401
		if fe.hud.talentSelected >= #offers then -- 1402
			fe.hud.talentSelected = 0 -- 1403
		end -- 1403
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1405
			local idx = __TS__ParseInt( -- 1406
				string.sub(zoneTap, 8), -- 1406
				10 -- 1406
			) -- 1406
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1407
				input.fire.pressed = false -- 1408
			end -- 1408
		else -- 1408
			if input.talentDelta ~= 0 then -- 1411
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1412
				input.talentDelta = 0 -- 1413
			end -- 1413
			if input.talentConfirm then -- 1415
				p:chooseTalent(fe.hud.talentSelected) -- 1416
				input.talentConfirm = false -- 1417
				input.fire.pressed = false -- 1418
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1419
				input.fire.pressed = false -- 1421
			end -- 1421
		end -- 1421
	end -- 1421
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1427
		if input.navConfirm then -- 1428
			input.interact.pressed = true -- 1429
		end -- 1429
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1431
			flushProfile() -- 1432
			if p.run.source == "official" and hasSessionSave() then -- 1433
				clearSession() -- 1434
				refreshTitleSessionFlag() -- 1435
			end -- 1435
			fe.audio:stopRoomTransient() -- 1437
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1438
			fe.screen = "epilogue" -- 1442
			input:clearTransient(true) -- 1443
			input:consumeEdges() -- 1444
			return -- 1445
		end -- 1445
	end -- 1445
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1449
		p:closeCraftBench() -- 1450
		input:consumeEdges() -- 1451
		return -- 1452
	end -- 1452
	if not p.paused and input.pause.pressed then -- 1454
		p.paused = true -- 1455
		p.aimHold = 0 -- 1456
		p.bottleAimX = -1 -- 1457
		saveCurrentSession() -- 1458
		fe.menus:openPause() -- 1459
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1460
		input:clearTransient(true) -- 1461
		input:consumeEdges() -- 1462
	end -- 1462
	if p.paused then -- 1465
		clock:reset() -- 1467
		local pauseAct = fe:renderPlay( -- 1468
			frameDt, -- 1468
			p, -- 1468
			input, -- 1468
			stageVp.stageW, -- 1468
			stageVp.stageH -- 1468
		) -- 1468
		input:consumeEdges() -- 1469
		if pauseAct.type == "resume" then -- 1470
			p.paused = false -- 1471
		elseif pauseAct.type == "retry" then -- 1472
			ensurePlay({checkpoint = p.checkpoint}) -- 1473
		elseif pauseAct.type == "openChapters" then -- 1474
			fe.audio:stopRoomTransient() -- 1475
			fe.audio:setPaused(false) -- 1476
			fe.menus:openChapters(current) -- 1477
			fe.screen = "chapters" -- 1478
		elseif pauseAct.type == "toggleFullscreen" then -- 1479
			toggleFullscreen() -- 1480
		elseif pauseAct.type == "quit" then -- 1481
			quitGame() -- 1482
		elseif pauseAct.type == "toTitle" then -- 1483
			saveCurrentSession() -- 1484
			refreshTitleSessionFlag() -- 1485
			fe.menus:resetInput() -- 1486
			fe.screen = "title" -- 1487
		end -- 1487
		return -- 1489
	end -- 1489
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1492
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1493
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1495
		input:consumeEdges() -- 1496
		ensurePlay({checkpoint = p.checkpoint}) -- 1498
		return -- 1499
	end -- 1499
	local steps = clock:advance(frameDt) -- 1502
	local i = 0 -- 1503
	do -- 1503
		i = 0 -- 1504
		while i < steps do -- 1504
			input:beginStep(i == 0) -- 1505
			p:update(STEP, input) -- 1506
			input:endStep() -- 1507
			if p.wantRoom ~= "" then -- 1508
				break -- 1509
			end -- 1509
			i = i + 1 -- 1504
		end -- 1504
	end -- 1504
	if p.wantRoom ~= "" then -- 1514
		local key = p.wantRoom -- 1515
		p.wantRoom = "" -- 1516
		local idx = -1 -- 1517
		local j = 0 -- 1518
		do -- 1518
			j = 0 -- 1519
			while j < #ROOMS do -- 1519
				if ROOMS[j + 1].key == key then -- 1520
					idx = j -- 1521
				end -- 1521
				j = j + 1 -- 1519
			end -- 1519
		end -- 1519
		if idx >= 0 then -- 1524
			flushProfile() -- 1528
			local leaving = p:drainEvents() -- 1529
			if p.restartStory then -- 1531
				if storyRun ~= nil and storyRun.source == "official" then -- 1532
					clearSession() -- 1533
					refreshTitleSessionFlag() -- 1534
				end -- 1534
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1536
				storyRun = createRun(20261124, nextSource, profile) -- 1537
			end -- 1537
			current = idx -- 1539
			ensurePlay() -- 1540
			local fresh = play -- 1541
			if fresh ~= nil then -- 1542
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1543
					fresh.phase = "prologue-wake" -- 1544
				end -- 1544
				fresh:adoptEvents(leaving) -- 1546
			end -- 1546
			if not p.restartStory then -- 1548
				saveCurrentSession() -- 1549
			end -- 1549
			clock:reset() -- 1551
			dirty = true -- 1552
		end -- 1552
		return -- 1554
	end -- 1554
	flushProfile() -- 1558
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1559
		clearSession() -- 1560
		refreshTitleSessionFlag() -- 1561
	elseif p.sessionDirty then -- 1562
		saveCurrentSession() -- 1563
	end -- 1563
	fe:renderPlay( -- 1565
		frameDt, -- 1565
		p, -- 1565
		input, -- 1565
		stageVp.stageW, -- 1565
		stageVp.stageH -- 1565
	) -- 1565
end -- 1565
function redrawGraybox() -- 1569
	if draw == nil then -- 1570
		return -- 1571
	end -- 1571
	local w = viewW -- 1573
	local h = viewH -- 1574
	local room = ROOMS[current + 1] -- 1575
	draw:clear() -- 1577
	draw:drawRect( -- 1578
		Rect(0, h - TOP_H, w, TOP_H), -- 1578
		C_BG -- 1578
	) -- 1578
	draw:drawRect( -- 1579
		Rect(0, 0, w, BOTTOM_H), -- 1579
		C_BG -- 1579
	) -- 1579
	draw:drawSegment( -- 1580
		Vec2(0, h - TOP_H), -- 1580
		Vec2(w, h - TOP_H), -- 1580
		1, -- 1580
		Color(52, 54, 54, 255) -- 1580
	) -- 1580
	draw:drawSegment( -- 1581
		Vec2(0, BOTTOM_H), -- 1581
		Vec2(w, BOTTOM_H), -- 1581
		1, -- 1581
		Color(52, 54, 54, 255) -- 1581
	) -- 1581
	local v = computeView(room, w, h) -- 1583
	renderWorld( -- 1584
		draw, -- 1584
		room, -- 1584
		v, -- 1584
		w, -- 1584
		h -- 1584
	) -- 1584
	local roomTop = v.groundPx + room.height * v.scale -- 1586
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1587
	place( -- 1589
		titleLabel, -- 1589
		48, -- 1589
		h - 40, -- 1589
		0, -- 1589
		1 -- 1589
	) -- 1589
	place( -- 1590
		roomLabel, -- 1590
		48, -- 1590
		h - 96, -- 1590
		0, -- 1590
		1 -- 1590
	) -- 1590
	place( -- 1591
		captionLabel, -- 1591
		48, -- 1591
		h - 140, -- 1591
		0, -- 1591
		1 -- 1591
	) -- 1591
	place( -- 1593
		switchLabel, -- 1593
		48, -- 1593
		40, -- 1593
		0, -- 1593
		0 -- 1593
	) -- 1593
	place( -- 1594
		hintLabel, -- 1594
		48, -- 1594
		84, -- 1594
		0, -- 1594
		0 -- 1594
	) -- 1594
	place( -- 1595
		rulerLabel, -- 1595
		w - 216, -- 1595
		roomTop + 36 + v.scale * 0.5 - 14, -- 1595
		1, -- 1595
		0 -- 1595
	) -- 1595
	place( -- 1596
		standLabel, -- 1596
		48, -- 1596
		roomTop + 40, -- 1596
		0, -- 1596
		0 -- 1596
	) -- 1596
	place( -- 1597
		cartLabel, -- 1597
		48, -- 1597
		roomTop + 92, -- 1597
		0, -- 1597
		0 -- 1597
	) -- 1597
	if roomLabel ~= nil then -- 1599
		roomLabel.text = room.name -- 1600
	end -- 1600
	if captionLabel ~= nil then -- 1602
		captionLabel.text = room.caption -- 1603
	end -- 1603
	if hintLabel ~= nil then -- 1605
		local hintIdx = math.min(current, #HINTS - 1) -- 1606
		local lines = HINTS[hintIdx + 1] -- 1607
		local merged = lines[1] -- 1608
		do -- 1608
			local i = 1 -- 1609
			while i < #lines do -- 1609
				merged = (merged .. "    ") .. lines[i + 1] -- 1610
				i = i + 1 -- 1609
			end -- 1609
		end -- 1609
		hintLabel.text = merged -- 1612
	end -- 1612
	local specs = collectLabels(room, v, w) -- 1615
	local body = {} -- 1616
	local small = {} -- 1617
	do -- 1617
		local i = 0 -- 1618
		while i < #specs do -- 1618
			local s = specs[i + 1] -- 1619
			if s.size >= 24 then -- 1620
				body[#body + 1] = s -- 1621
			else -- 1621
				small[#small + 1] = s -- 1623
			end -- 1623
			i = i + 1 -- 1618
		end -- 1618
	end -- 1618
	applyPool(body, poolBody) -- 1626
	applyPool(small, poolSmall) -- 1627
	if LAYOUT_AUDIT then -- 1629
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1630
	end -- 1630
end -- 1630
function applyPool(specs, pool) -- 1634
	do -- 1634
		local i = 0 -- 1635
		while i < #pool do -- 1635
			local lb = pool[i + 1] -- 1636
			if i < #specs then -- 1637
				local s = specs[i + 1] -- 1638
				lb.text = s.text -- 1639
				lb.position = Vec2(s.x, s.y) -- 1640
				lb.anchor = Vec2(s.ax, s.ay) -- 1641
				lb.color = s.color -- 1642
				lb.visible = true -- 1643
			else -- 1643
				lb.visible = false -- 1645
			end -- 1645
			i = i + 1 -- 1635
		end -- 1635
	end -- 1635
end -- 1635
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
	if mode == 0 then -- 147
		setMode(1) -- 148
		return -- 149
	end -- 149
	if mode == 2 and play ~= nil then -- 151
		local trial = run and run.trial -- 152
		if trial ~= nil and (trial.lost or (run and run.finished) == true) then -- 153
			current = 0 -- 154
			play = nil -- 155
			run = nil -- 156
			setMode(1) -- 157
			if fe ~= nil then -- 158
				fe.audio:stopRoomTransient() -- 159
				fe.screen = "title" -- 160
				fe.menus:resetInput() -- 161
			end -- 161
			return -- 163
		end -- 163
		play.paused = not play.paused -- 165
		if fe ~= nil then -- 166
			fe.audio:playUi(play.paused and "ui:pause_open" or "ui:pause_close", play.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 166
		end -- 166
		clock:reset() -- 167
		if input ~= nil then -- 168
			input:clearTransient(true) -- 168
		end -- 168
		return -- 169
	end -- 169
	if fe == nil then -- 171
		return -- 172
	end -- 172
	if fe.screen == "splash" then -- 174
		fe.menus:resetSplash() -- 175
		fe.screen = "title" -- 176
		fe.menus:resetInput() -- 177
		return -- 178
	end -- 178
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "epilogue" or fe.screen == "history" then -- 180
		fe.menus:triggerBack() -- 181
		return -- 182
	end -- 182
	if fe.screen == "title" then -- 184
		if not canQuitApp() then -- 185
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 186
			return -- 187
		end -- 187
		if appClock - lastBackPressClock <= 2 then -- 189
			quitGame() -- 190
		else -- 190
			lastBackPressClock = appClock -- 192
			fe:showToast("再按一次返回退出游戏", 2) -- 193
		end -- 193
		return -- 195
	end -- 195
	if fe.screen == "play" and play ~= nil then -- 197
		if play.paused then -- 198
			fe.menus:triggerBack() -- 199
			return -- 200
		end -- 200
		if play.craftBench.active then -- 202
			play:closeCraftBench() -- 203
			return -- 204
		end -- 204
		play.paused = true -- 206
		play.aimHold = 0 -- 207
		play.bottleAimX = -1 -- 208
		saveCurrentSession() -- 209
		fe.menus:openPause() -- 210
		if input ~= nil then -- 211
			input:clearTransient(true) -- 211
		end -- 211
	end -- 211
end -- 146
local function makeGrayboxLabel(text, size, color) -- 364
	if grayboxLayer == nil then -- 365
		return nil -- 366
	end -- 366
	local lb = Label(FONT, size) -- 368
	if lb == nil then -- 369
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
	if campaignHud ~= nil then -- 407
		campaignHud.color = C_TEXT -- 408
		campaignHud.anchor = Vec2(0, 1) -- 409
		campaignHud:addTo(campaignLayer) -- 410
		campaignHud.visible = true -- 411
	end -- 411
	campaignSub = Label(FONT, 20) -- 413
	if campaignSub ~= nil then -- 414
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
			if lb ~= nil then -- 433
				poolBody[#poolBody + 1] = lb -- 434
			end -- 434
			i = i + 1 -- 431
		end -- 431
	end -- 431
	do -- 431
		local i = 0 -- 437
		while i < POOL_SMALL do -- 437
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 438
			if lb ~= nil then -- 439
				poolSmall[#poolSmall + 1] = lb -- 440
			end -- 440
			i = i + 1 -- 437
		end -- 437
	end -- 437
	if mode == 1 then -- 446
		local loaded = loadSave() -- 447
		profile = loaded.state -- 448
		profileStatus = loaded.status -- 449
		profileDetail = loaded.detail -- 450
	end -- 450
	fe = __TS__New(WatchFrontend, parent) -- 452
	fe.screen = startScreen -- 453
	if startScreen == "splash" then -- 454
		fe.menus:resetSplash() -- 455
	end -- 455
	refreshTitleSessionFlag() -- 457
	grayboxLayer.visible = mode == 0 -- 458
	fe:setVisible(mode == 1) -- 459
	if campaignLayer ~= nil then -- 460
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
			if eventType == "BackButton" then -- 478
				handleBackButton() -- 479
				return -- 480
			end -- 480
			if eventType == "Quit" or eventType == "Shutdown" then -- 482
				flushProfile() -- 483
				saveCurrentSession() -- 484
				if input ~= nil then -- 485
					input:clearTransient(false) -- 485
				end -- 485
				return -- 486
			end -- 486
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 488
				flushProfile() -- 489
				saveCurrentSession() -- 490
				if input ~= nil then -- 491
					input:clearTransient(true) -- 491
				end -- 491
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 492
					play.paused = true -- 493
					play.aimHold = 0 -- 494
					play.bottleAimX = -1 -- 495
					fe.menus:openPause() -- 496
				elseif mode == 2 and play ~= nil and not play.paused then -- 497
					play.paused = true -- 498
				end -- 498
				if fe ~= nil then -- 500
					fe.audio:setPaused(true) -- 501
				end -- 501
				return -- 503
			end -- 503
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 505
				if fe ~= nil then -- 506
					local paused = play ~= nil and play.paused and (mode == 1 and fe.screen == "play" or mode == 2) -- 507
					fe.audio:setPaused(paused) -- 509
				end -- 509
			end -- 509
		end -- 477
	) -- 477
	parent:onKeyDown(function(key) -- 515
		onFirstUserGesture() -- 516
		if input ~= nil then -- 517
			input:markKeyboardActivity() -- 517
		end -- 517
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 518
			toggleFullscreen() -- 520
			return -- 521
		end -- 521
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 523
			play:toggleArtifactWeapon() -- 524
			return -- 525
		end -- 525
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and #play:getStoryTalentOffers() > 0 then -- 527
			if key == "1" then -- 529
				play:chooseTalent(0) -- 530
				if input ~= nil then -- 531
					input:consumePickRoom() -- 531
				end -- 531
				return -- 532
			end -- 532
			if key == "2" then -- 534
				play:chooseTalent(1) -- 535
				if input ~= nil then -- 536
					input:consumePickRoom() -- 536
				end -- 536
				return -- 537
			end -- 537
			if key == "3" then -- 539
				play:chooseTalent(2) -- 540
				if input ~= nil then -- 541
					input:consumePickRoom() -- 541
				end -- 541
				return -- 542
			end -- 542
		end -- 542
		local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 545
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 546
			fe.menus:onKeyEvent(key) -- 547
		end -- 547
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay or mode == 2) then -- 549
			if key == "E" then -- 550
				input.interact.pressed = true -- 551
			elseif key == "Space" then -- 552
				input.jump.pressed = true -- 553
			elseif key == "Escape" then -- 554
				input.pause.pressed = true -- 555
			elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 556
				input.retry.pressed = true -- 557
			end -- 557
		end -- 557
		if mode == 2 and (run and run.trial) ~= nil then -- 560
			return -- 560
		end -- 560
		if isReleaseBuild() then -- 561
			return -- 561
		end -- 561
		if key == "F1" then -- 562
			if mode == 2 then -- 563
				current = 0 -- 564
				play = nil -- 565
				ensurePlay() -- 566
			else -- 566
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 568
			end -- 568
		elseif key == "F2" then -- 570
			setMode(0) -- 571
		elseif key == "1" then -- 572
			pickByIndex(0) -- 573
		elseif key == "2" then -- 574
			pickByIndex(1) -- 575
		elseif key == "3" then -- 576
			pickByIndex(2) -- 577
		elseif key == "4" then -- 578
			pickByIndex(3) -- 579
		elseif key == "5" then -- 580
			pickByIndex(4) -- 581
		elseif key == "6" then -- 582
			pickByIndex(5) -- 583
		elseif key == "7" then -- 584
			pickByIndex(6) -- 585
		elseif key == "8" then -- 586
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
			if fe == nil then -- 602
				return -- 603
			end -- 603
			setMode(1) -- 605
			fe.screen = sc -- 606
			if sc == "splash" then -- 607
				fe.menus:resetSplash() -- 608
			elseif sc == "chapters" then -- 609
				fe.menus:openChapters() -- 610
			elseif sc == "epilogue" then -- 611
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 612
			elseif sc == "history" then -- 616
				fe.menus:openHistory(false) -- 617
			else -- 617
				fe.menus:resetInput() -- 619
			end -- 619
			if sc == "play" then -- 621
				ensurePlay() -- 622
			end -- 622
		end, -- 601
		jumpRoom = function(keyOrIdx) -- 625
			local idx = -1 -- 626
			if type(keyOrIdx) == "number" then -- 627
				idx = keyOrIdx -- 628
			else -- 628
				local k = 0 -- 630
				do -- 630
					k = 0 -- 631
					while k < #ROOMS do -- 631
						if ROOMS[k + 1].key == keyOrIdx then -- 632
							idx = k -- 633
						end -- 633
						k = k + 1 -- 631
					end -- 631
				end -- 631
			end -- 631
			if idx >= 0 and idx < #ROOMS then -- 637
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
			if gamepadRouter ~= nil then -- 696
				gamepadRouter:setSimulatedState(state) -- 696
			end -- 696
		end, -- 695
		injectTouch = function(phase, id, x, y, fromMouse) -- 698
			if touchRouter ~= nil then -- 699
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
			if input ~= nil then -- 703
				input:setInputMode(m) -- 703
			end -- 703
		end, -- 702
		setModePref = function(pref) -- 705
			if input ~= nil then -- 706
				input:setModePref(pref) -- 706
			end -- 706
		end, -- 705
		applyViewportForTest = function(w, h) -- 708
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 709
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
	if mode == 1 and startScreen == "play" then -- 725
		ensurePlay() -- 726
	end -- 726
	parent:schedule(function(frameDt) -- 729
		tick(frameDt) -- 730
		return false -- 731
	end) -- 729
end -- 388
return ____exports -- 388
