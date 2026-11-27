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
			fe.screen = "title" -- 137
			fe.menus:resetInput() -- 138
		end -- 138
		return -- 140
	end -- 140
	App:shutdown() -- 142
end -- 142
function canSaveSession() -- 212
	if mode ~= 1 or play == nil or storyRun == nil then -- 213
		return false -- 214
	end -- 214
	if storyRun.source ~= "official" or play.run.finished then -- 216
		return false -- 217
	end -- 217
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 219
		return false -- 220
	end -- 220
	return true -- 222
end -- 222
function refreshTitleSessionFlag() -- 225
	if fe ~= nil then -- 226
		fe.menus.hasSession = hasSessionSave() -- 227
	end -- 227
end -- 227
function saveCurrentSession() -- 231
	if not canSaveSession() or play == nil then -- 232
		return false -- 233
	end -- 233
	play.sessionDirty = false -- 235
	local ok = saveSession(play:exportSession()) -- 236
	refreshTitleSessionFlag() -- 237
	return ok -- 238
end -- 238
function continueOfficialStory() -- 241
	local res = loadSession() -- 242
	if res.status ~= "ok" or res.state == nil then -- 243
		refreshTitleSessionFlag() -- 244
		return nil -- 245
	end -- 245
	local s = res.state -- 247
	local idx = roomIndexByKey(s.roomKey) -- 248
	if ROOMS[idx + 1].key ~= s.roomKey then -- 249
		return nil -- 250
	end -- 250
	storyRun = createRun(s.seed, "official", profile) -- 252
	storyRun.checkpoint = s.checkpoint -- 253
	storyRun.story.route = s.route -- 254
	storyRun.story.hp = s.hp -- 255
	storyRun.story.maxHp = s.maxHp -- 256
	storyRun.story.hpAtGate = s.hpAtGate -- 257
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 258
	storyRun.story.settled = s.settled -- 259
	storyRun.story.phase = s.phase -- 260
	storyRun.story.countTick = s.countTick -- 261
	storyRun.story.phaseTick = s.phaseTick -- 262
	storyRun.story.handTicks = s.handTicks -- 263
	storyRun.story.handDone = s.handDone -- 264
	storyRun.story.lineSaid = s.lineSaid -- 265
	storyRun.story.tied = s.tied -- 266
	storyRun.story.carry = s.carry -- 267
	storyRun.story.escortDone = s.escortDone -- 268
	storyRun.story.craftedWeapon = s.craftedWeapon -- 269
	storyRun.story.equippedWeapon = s.equippedWeapon -- 270
	storyRun.inventory.wood = s.wood -- 271
	storyRun.inventory.bell = s.bell -- 272
	storyRun.inventory.scrap = s.scrap -- 273
	storyRun.inventory.wedge = s.wedge -- 274
	storyRun.inventory.ammo = s.ammo -- 275
	storyRun.inventory.shield = s.shield -- 276
	storyRun.inventory.pass = s.pass -- 277
	storyRun.inventory.quickbelt = s.quickbelt -- 278
	local k = 0 -- 279
	do -- 279
		k = 0 -- 280
		while k < #s.taken do -- 280
			storyRun.taken[s.taken[k + 1]] = true -- 281
			k = k + 1 -- 280
		end -- 280
	end -- 280
	do -- 280
		k = 0 -- 283
		while k < #s.segments do -- 283
			storyRun.story.segments[s.segments[k + 1]] = true -- 284
			k = k + 1 -- 283
		end -- 283
	end -- 283
	if s.campaignRoute ~= nil then -- 286
		storyRun.route = s.campaignRoute -- 287
	end -- 287
	if s.joined ~= nil then -- 289
		storyRun.joined = s.joined -- 290
	end -- 290
	if s.c1Latch ~= nil then -- 292
		storyRun.c1Latch = s.c1Latch -- 293
	end -- 293
	if s.c2Latch ~= nil then -- 295
		storyRun.c2Latch = s.c2Latch -- 296
	end -- 296
	if s.props ~= nil then -- 298
		do -- 298
			k = 0 -- 299
			while k < #s.props do -- 299
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 300
				local pid = parts[1] -- 301
				if pid ~= nil and pid ~= "" then -- 302
					local ____storyRun_props_14 = storyRun.props -- 303
					local ____temp_10 -- 304
					if parts[2] == nil then -- 304
						____temp_10 = true -- 304
					else -- 304
						____temp_10 = parts[2] == "1" -- 304
					end -- 304
					local ____temp_12 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 305
					local ____temp_13 = parts[4] == "1" -- 306
					local ____temp_11 -- 307
					if parts[5] == "1" then -- 307
						____temp_11 = true -- 307
					else -- 307
						____temp_11 = nil -- 307
					end -- 307
					____storyRun_props_14[pid] = {broken = ____temp_10, hp = ____temp_12, wedge = ____temp_13, revealed = ____temp_11} -- 303
				end -- 303
				k = k + 1 -- 299
			end -- 299
		end -- 299
	end -- 299
	local stTalents = createStoryTalents(s.seed) -- 312
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 313
		stTalents.randomState = s.talentSeed -- 314
	end -- 314
	stTalents.room = s.talentRoom or "" -- 316
	stTalents.ranks.vitality = s.talentVitality or 0 -- 317
	stTalents.ranks.reload = s.talentReload or 0 -- 318
	stTalents.ranks.guard = s.talentGuard or 0 -- 319
	stTalents.ranks.craft = s.talentCraft or 0 -- 320
	if s.talentOffers ~= nil then -- 321
		do -- 321
			k = 0 -- 322
			while k < #s.talentOffers do -- 322
				local t = s.talentOffers[k + 1] -- 323
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 324
					local ____stTalents_offers_15 = stTalents.offers -- 325
					____stTalents_offers_15[#____stTalents_offers_15 + 1] = t -- 325
				end -- 325
				k = k + 1 -- 322
			end -- 322
		end -- 322
	end -- 322
	storyRun.story.talents = stTalents -- 329
	current = idx -- 330
	setMode(1) -- 331
	if fe ~= nil then -- 332
		fe.screen = "play" -- 333
	end -- 333
	play = nil -- 335
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 336
	local cur = play -- 337
	if cur ~= nil then -- 338
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 339
			cur.cartAxle = s.cartAxle -- 340
			cur.cartDocked = s.cartDocked -- 341
		end -- 341
		if s.playerX ~= nil and s.playerX >= 0 then -- 343
			cur.player.x = math.max( -- 344
				cur.room.minX + 16, -- 344
				math.min(cur.room.maxX - 16, s.playerX) -- 344
			) -- 344
			cur.player.y = math.max(0, s.playerY or 0) -- 345
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 346
				cur.player.depth = math.max( -- 347
					cur.room.depth.min, -- 347
					math.min(cur.room.depth.max, s.playerDepth) -- 347
				) -- 347
			end -- 347
		end -- 347
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 350
			cur.gateTick = s.gateTick -- 351
		end -- 351
		if cur.room.key == "village" then -- 353
			if s.hasBottle == true then -- 354
				cur.hasBottle = true -- 354
			end -- 354
			if s.villagePassed == true then -- 355
				cur.passed = true -- 355
			end -- 355
		end -- 355
	end -- 355
	return play -- 358
end -- 358
function place(lb, x, y, ax, ay) -- 376
	if lb == nil then -- 377
		return -- 378
	end -- 378
	lb.position = Vec2(x, y) -- 380
	lb.anchor = Vec2(ax, ay) -- 381
	lb.visible = true -- 382
end -- 382
function setMode(nextMode) -- 731
	mode = nextMode -- 732
	if grayboxLayer ~= nil then -- 733
		grayboxLayer.visible = mode == 0 -- 734
	end -- 734
	if fe ~= nil then -- 736
		fe:setVisible(mode == 1) -- 737
	end -- 737
	if campaignLayer ~= nil then -- 739
		campaignLayer.visible = mode == 2 -- 740
	end -- 740
	dirty = true -- 742
	clock:reset() -- 743
end -- 743
function flushProfile() -- 750
	local cur = play -- 751
	if cur ~= nil and cur.archiveDirty then -- 752
		cur.archiveDirty = false -- 753
		markProfilePending(profile) -- 754
	end -- 754
	local ok = flushSaveProfile() -- 756
	if not ok and cur ~= nil then -- 757
		cur.archiveDirty = true -- 758
	end -- 758
	return ok -- 760
end -- 760
function officialStartIndex() -- 764
	local mp = profile.museumPhase -- 765
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 766
	return inMuseum and roomIndexByKey("museum") or 0 -- 767
end -- 767
function roomIndexByKey(key) -- 770
	local i = 0 -- 771
	do -- 771
		i = 0 -- 772
		while i < #ROOMS do -- 772
			if ROOMS[i + 1].key == key then -- 773
				return i -- 774
			end -- 774
			i = i + 1 -- 772
		end -- 772
	end -- 772
	return 0 -- 777
end -- 777
function enterPlayRoom(idx, source, fresh) -- 780
	if source == nil then -- 780
		source = "debug" -- 780
	end -- 780
	if fresh == nil then -- 780
		fresh = false -- 780
	end -- 780
	current = idx -- 781
	setMode(1) -- 782
	if fe ~= nil then -- 783
		fe.screen = "play" -- 784
	end -- 784
	play = nil -- 786
	if fresh or source == "chapter" or storyRun == nil then -- 788
		storyRun = createRun(20261124, source, profile) -- 789
	else -- 789
		storyRun.source = source -- 791
	end -- 791
	ensurePlay() -- 793
	local firstPlay = play -- 795
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 796
		firstPlay.phase = "prologue-wake" -- 797
	end -- 797
	flushProfile() -- 799
end -- 799
function pickByIndex(idx, source) -- 802
	if source == nil then -- 802
		source = "debug" -- 802
	end -- 802
	if mode == 2 then -- 803
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 804
			return -- 805
		end -- 805
		current = idx -- 807
		play = nil -- 808
		clock:reset() -- 809
		ensurePlay() -- 810
		return -- 811
	end -- 811
	if idx < 0 or idx >= #ROOMS then -- 813
		return -- 814
	end -- 814
	flushProfile() -- 816
	if storyRun ~= nil then -- 817
		storyRun.source = source -- 818
	end -- 818
	current = idx -- 820
	dirty = true -- 821
	play = nil -- 822
	clock:reset() -- 823
	if mode == 1 then -- 824
		if fe ~= nil then -- 825
			fe.screen = "play" -- 826
		end -- 826
		ensurePlay() -- 828
	end -- 828
end -- 828
function applySize() -- 832
	if root == nil then -- 833
		return -- 834
	end -- 834
	root.size = Size(viewW, viewH) -- 836
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 837
	stageVp = computeStageViewport(viewW, viewH) -- 838
	if input ~= nil then -- 839
		input:setStageViewport(stageVp) -- 840
	end -- 840
	if fe ~= nil then -- 842
		fe:setStagePlacement(stageVp) -- 843
	end -- 843
	if campaignLayer ~= nil then -- 845
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 846
	end -- 846
	if grayboxLayer ~= nil then -- 848
		grayboxLayer.position = Vec2(0, 0) -- 849
	end -- 849
end -- 849
function syncFrameAdapters(frameDt) -- 853
	if input == nil then -- 854
		return -- 855
	end -- 855
	local p = play -- 857
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 858
	local isTrialMode = mode == 2 and p ~= nil -- 859
	local gameplayActive = isPlayMode or isTrialMode -- 860
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 862
		p, -- 864
		stageVp.stageW, -- 864
		stageVp.stageH, -- 864
		input:isTouchMode() -- 864
	) or ({}) -- 865
	if touchControls ~= nil and touchRouter ~= nil then -- 867
		local isFs = false -- 868
		if canToggleFullscreen() then -- 869
			do -- 869
				local function ____catch() -- 869
					isFs = false -- 873
				end -- 873
				local ____try = pcall(function() -- 873
					isFs = App.fullScreen -- 871
				end) -- 871
				if not ____try then -- 871
					____catch() -- 871
				end -- 871
			end -- 871
		end -- 871
		local ____touchControls_53 = touchControls -- 876
		local ____touchControls_syncContext_54 = touchControls.syncContext -- 876
		local ____stageVp_46 = stageVp -- 877
		local ____mode_47 = mode -- 878
		local ____temp_48 = fe ~= nil and fe.screen or "title" -- 879
		local ____run_49 = run -- 881
		local ____temp_50 = fe ~= nil and fe.cam or nil -- 882
		local ____input_51 = input -- 883
		local ____touchRouter_52 = touchRouter -- 884
		local ____temp_44 -- 885
		if fe ~= nil then -- 885
			____temp_44 = fe.contract:isAssistHintsEnabled() -- 885
		else -- 885
			____temp_44 = false -- 885
		end -- 885
		local ____temp_45 -- 886
		if fe ~= nil then -- 886
			____temp_45 = fe.audio:isAllMuted() -- 886
		else -- 886
			____temp_45 = false -- 886
		end -- 886
		____touchControls_syncContext_54(____touchControls_53, { -- 876
			viewport = ____stageVp_46, -- 877
			mode = ____mode_47, -- 878
			screen = ____temp_48, -- 879
			play = p, -- 880
			run = ____run_49, -- 881
			cam = ____temp_50, -- 882
			input = ____input_51, -- 883
			router = ____touchRouter_52, -- 884
			assistHintsEnabled = ____temp_44, -- 885
			isMuted = ____temp_45, -- 886
			isFullscreen = isFs, -- 887
			storyTalentBoxes = storyTalentBoxes, -- 888
			dt = frameDt -- 889
		}) -- 889
	end -- 889
	if gamepadRouter ~= nil then -- 893
		local trial = run and run.trial -- 894
		local trialEnded = isTrialMode and trial ~= nil and (trial.lost or (run and run.finished) == true) -- 895
		local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 896
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 897
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 900
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 901
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 902
		local ____temp_59 -- 905
		if isPlayMode and p ~= nil then -- 905
			____temp_59 = isCutsceneBlockingPlay(p) -- 905
		else -- 905
			____temp_59 = false -- 905
		end -- 905
		local cutsceneBlocking = ____temp_59 -- 905
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 906
		local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 908
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 909
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 911
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 913
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 916
		local playerScreenX = stageVp.stageW * 0.5 -- 918
		local playerScreenY = stageVp.stageH * 0.38 -- 919
		if p ~= nil then -- 920
			if isPlayMode and fe ~= nil then -- 921
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 922
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 923
			else -- 923
				local vz = p.view.zoom > 0 and p.view.zoom or 1 -- 926
				playerScreenX = stageVp.stageW * 0.5 + (p.player.x + p.player.facing * 8 - p.cam.x) * vz -- 927
				playerScreenY = stageVp.stageH * 0.5 + (p.player.y + p.player.h * 0.72 + p.player.depth * DEPTH_Y_SCALE - p.cam.y) * vz -- 928
			end -- 928
		end -- 928
		local enemyTargets = canShoot and p ~= nil and (isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or collectTrialAimTargets(p, stageVp.stageW, stageVp.stageH)) or ({}) -- 932
		local gpCtx = { -- 938
			stageW = stageVp.stageW, -- 939
			stageH = stageVp.stageH, -- 940
			uiScale = stageVp.uiScale, -- 941
			modal = modal, -- 942
			gameplayActive = gameplayActive, -- 943
			reloadActive = reloadActive, -- 944
			craftActive = craftActive, -- 945
			talentOfferCount = talentOfferCount, -- 946
			childMode = p ~= nil and p.childMode, -- 947
			allowDepth = allowDepth, -- 948
			canShoot = canShoot, -- 949
			canBottleAim = canBottleAim, -- 950
			playerRolling = p ~= nil and p.player.rollT > 0, -- 951
			inLowArch = inLowArch, -- 952
			inTowerEnd = inTowerEnd, -- 953
			playerFacing = p ~= nil and p.player.facing or 1, -- 954
			playerScreenX = playerScreenX, -- 955
			playerScreenY = playerScreenY, -- 956
			enemyTargets = enemyTargets -- 957
		} -- 957
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 959
	end -- 959
end -- 959
function renderTouchOverlay() -- 963
	if touchControls ~= nil and touchRouter ~= nil then -- 964
		touchControls:render(touchRouter) -- 965
	end -- 965
end -- 965
function tick(frameDt) -- 969
	appClock = appClock + math.min( -- 970
		0.05, -- 970
		math.max(0, frameDt) -- 970
	) -- 970
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 971
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 972
	if w ~= viewW or h ~= viewH then -- 973
		viewW = w -- 974
		viewH = h -- 975
		applySize() -- 976
		dirty = true -- 977
	end -- 977
	if input == nil then -- 979
		return -- 980
	end -- 980
	syncFrameAdapters(frameDt) -- 982
	input:update() -- 983
	if input.userInteracted then -- 985
		onFirstUserGesture() -- 986
	end -- 986
	if input.muteTogglePressed and fe ~= nil then -- 988
		input.muteTogglePressed = false -- 989
		fe.audio:toggleAllMuted() -- 990
	end -- 990
	if input.fullscreenTogglePressed then -- 992
		input.fullscreenTogglePressed = false -- 993
		toggleFullscreen() -- 994
	end -- 994
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 996
		input.artifactTogglePressed = false -- 997
		play:toggleArtifactWeapon() -- 998
	end -- 998
	if input.bottleCanceled and play ~= nil then -- 1000
		input.bottleCanceled = false -- 1001
		play.aimHold = 0 -- 1002
		play.bottleAimX = -1 -- 1003
	end -- 1003
	if mode == 2 and (run and run.trial) ~= nil then -- 1006
		tickCampaign(frameDt) -- 1007
		renderTouchOverlay() -- 1008
		return -- 1009
	end -- 1009
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 1012
		play:chooseTalent(input.pickRoom - 1) -- 1015
		input.pickRoom = 0 -- 1016
	end -- 1016
	if isReleaseBuild() then -- 1019
		input.toggleView.pressed = false -- 1020
		input.pickRoom = 0 -- 1021
		input.tab.pressed = false -- 1022
	else -- 1022
		if input.toggleView.pressed then -- 1025
			input.toggleView.pressed = false -- 1026
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 1027
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 1028
				ensurePlay() -- 1029
			end -- 1029
		end -- 1029
		if input.pickRoom ~= 0 then -- 1034
			local idx = input.pickRoom - 1 -- 1035
			input.pickRoom = 0 -- 1036
			pickByIndex(idx) -- 1037
		elseif input.tab.pressed then -- 1038
			input.tab.pressed = false -- 1039
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 1040
				pickByIndex((current + 1) % #ROOMS) -- 1041
			end -- 1041
		end -- 1041
	end -- 1041
	if mode == 2 then -- 1046
		tickCampaign(frameDt) -- 1047
	elseif mode == 1 then -- 1048
		tickFrontend(frameDt) -- 1049
	elseif dirty then -- 1050
		redrawGraybox() -- 1051
		dirty = false -- 1052
	end -- 1052
	renderTouchOverlay() -- 1054
end -- 1054
function registerPlay() -- 1058
	local reg = _G.package.loaded -- 1059
	reg["watch.play"] = play -- 1060
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 1061
	reg["watch.room"] = rooms[current + 1].key -- 1062
end -- 1062
function ensurePlay(resume) -- 1066
	if mode == 2 then -- 1067
		if run == nil then -- 1068
			run = createRun() -- 1069
		end -- 1069
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 1071
	else -- 1071
		if storyRun == nil then -- 1075
			storyRun = createRun(20261124, "debug", profile) -- 1076
		end -- 1076
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1078
	end -- 1078
	registerPlay() -- 1080
	clock:reset() -- 1081
	if fe ~= nil and mode == 1 then -- 1082
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1083
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
	if input == nil then -- 1096
		return -- 1097
	end -- 1097
	if play == nil then -- 1099
		ensurePlay() -- 1100
	end -- 1100
	if play == nil then -- 1102
		return -- 1103
	end -- 1103
	local p = play -- 1105
	p.aimX = input.mx -- 1106
	p.aimY = input.my -- 1107
	local zoneTap = input.touchZoneTap -- 1109
	input.touchZoneTap = "" -- 1110
	local trial = run and run.trial -- 1112
	if trial ~= nil then -- 1113
		local ended = trial.lost or (run and run.finished) == true -- 1114
		local pick = input.pickRoom -- 1115
		input.pickRoom = 0 -- 1116
		if zoneTap == "trial:resume" and p.paused and not ended then -- 1118
			p.paused = false -- 1119
			clock:reset() -- 1120
			input:consumeEdges() -- 1121
			drawCampaign(p) -- 1122
			return -- 1123
		end -- 1123
		if zoneTap == "trial:retry" then -- 1125
			input:consumeEdges() -- 1126
			startTrial() -- 1127
			return -- 1128
		end -- 1128
		if zoneTap == "trial:title" then -- 1130
			input:consumeEdges() -- 1131
			current = 0 -- 1132
			play = nil -- 1133
			run = nil -- 1134
			setMode(1) -- 1135
			if fe ~= nil then -- 1136
				fe.screen = "title" -- 1137
				fe.menus:resetInput() -- 1138
			end -- 1138
			return -- 1140
		end -- 1140
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1143
			input:consumeEdges() -- 1144
			current = 0 -- 1145
			play = nil -- 1146
			run = nil -- 1147
			setMode(1) -- 1148
			if fe ~= nil then -- 1149
				fe.screen = "title" -- 1150
				fe.menus:resetInput() -- 1151
			end -- 1151
			return -- 1153
		end -- 1153
		if ended or p.paused and input.retry.pressed then -- 1155
			local restart = input.retry.pressed or ended and input.navConfirm -- 1156
			input:consumeEdges() -- 1157
			if restart then -- 1158
				startTrial() -- 1158
			else -- 1158
				drawCampaign(p) -- 1159
			end -- 1159
			return -- 1160
		end -- 1160
		input.retry.pressed = false -- 1162
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1163
			if trialTalentSelected >= #trial.offers then -- 1164
				trialTalentSelected = 0 -- 1165
			end -- 1165
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1167
				local idx = __TS__ParseInt( -- 1168
					string.sub(zoneTap, 8), -- 1168
					10 -- 1168
				) -- 1168
				if idx >= 0 and idx < #trial.offers then -- 1169
					p:chooseTalent(idx) -- 1170
				end -- 1170
			elseif pick > 0 then -- 1172
				p:chooseTalent(pick - 1) -- 1173
			else -- 1173
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1175
				if delta ~= 0 then -- 1178
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1179
				end -- 1179
				if input.talentConfirm or input.navConfirm then -- 1181
					p:chooseTalent(trialTalentSelected) -- 1182
				end -- 1182
			end -- 1182
			input:consumeEdges() -- 1185
			clock:reset() -- 1186
			drawCampaign(p) -- 1187
			return -- 1188
		end -- 1188
	end -- 1188
	if input.retry.pressed then -- 1192
		input.retry.pressed = false -- 1193
		input:consumeEdges() -- 1194
		play = nil -- 1196
		ensurePlay() -- 1197
		return -- 1198
	end -- 1198
	if input.pause.pressed or p.paused and input.navBack then -- 1200
		input.pause.pressed = false -- 1201
		p.paused = not p.paused -- 1202
		clock:reset() -- 1203
		input:consumeEdges() -- 1204
	end -- 1204
	if p.paused then -- 1206
		drawCampaign(p) -- 1207
		return -- 1208
	end -- 1208
	local steps = clock:advance(frameDt) -- 1211
	local i = 0 -- 1212
	do -- 1212
		i = 0 -- 1213
		while i < steps do -- 1213
			input:beginStep(i == 0) -- 1214
			p:update(STEP, input) -- 1215
			input:endStep() -- 1216
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1217
				break -- 1218
			end -- 1218
			i = i + 1 -- 1213
		end -- 1213
	end -- 1213
	if p.wantRoom ~= "" then -- 1222
		local key = p.wantRoom -- 1223
		p.wantRoom = "" -- 1224
		local idx = -1 -- 1225
		local j = 0 -- 1226
		do -- 1226
			j = 0 -- 1227
			while j < #CAMPAIGN_ROOMS do -- 1227
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1228
					idx = j -- 1229
				end -- 1229
				j = j + 1 -- 1227
			end -- 1227
		end -- 1227
		if idx >= 0 then -- 1232
			current = idx -- 1233
			play = nil -- 1234
			ensurePlay() -- 1235
		end -- 1235
		return -- 1237
	end -- 1237
	drawCampaign(p) -- 1239
end -- 1239
function goalLabel(goal) -- 1242
	if goal == "dock_cart" then -- 1243
		return "推车入窝并抬闩" -- 1244
	end -- 1244
	if goal == "raise_latch" then -- 1246
		return "抬闩开侧门" -- 1247
	end -- 1247
	return "到段出口" -- 1249
end -- 1249
function drawCampaign(p) -- 1252
	if campaignDraw == nil then -- 1253
		return -- 1254
	end -- 1254
	local w = stageVp.stageW -- 1256
	local h = stageVp.stageH -- 1257
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1258
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1259
	p:draw(campaignDraw, w, h) -- 1260
	local room = CAMPAIGN_ROOMS[current + 1] -- 1261
	local c = room.campaign -- 1262
	local r = run -- 1263
	local line = room.name -- 1264
	if c ~= nil then -- 1265
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget * 60) -- 1266
	end -- 1266
	if p.paused then -- 1269
		line = line .. "  · 已暂停 Esc 继续" -- 1270
	end -- 1270
	local trial = r and r.trial -- 1272
	if trial ~= nil and r ~= nil then -- 1273
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 1274
		if p.paused then -- 1275
			line = line .. " · 暂停" -- 1275
		elseif trial.lost then -- 1276
			line = line .. " · 护送失败" -- 1276
		elseif r.finished then -- 1277
			line = line .. " · 护送完成" -- 1277
		elseif #trial.offers > 0 then -- 1278
			line = line .. " · 选择本段本领" -- 1278
		elseif c ~= nil then -- 1279
			line = line .. " · " .. goalLabel(c.goal) -- 1279
		end -- 1279
	end -- 1279
	if campaignHud ~= nil then -- 1281
		campaignHud.text = line -- 1282
		campaignHud.position = Vec2(24 + safeL, h - 14 - safeT) -- 1283
		campaignHud.visible = true -- 1284
	end -- 1284
	if campaignSub ~= nil then -- 1286
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 1287
		if r ~= nil then -- 1288
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 1289
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 1290
		end -- 1290
		if p.flash ~= "" then -- 1295
			sub = (sub .. " · ") .. p.flash -- 1296
		end -- 1296
		if trial ~= nil and r ~= nil then -- 1298
			local gpMode = input ~= nil and input:isGamepadMode() -- 1299
			local touchMode = input ~= nil and input:isTouchMode() -- 1300
			if trial.lost or r.finished then -- 1301
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · A 再开一局 · START 返回标题" or (touchMode and " · 点下方按钮再开或返回标题" or " · R 再开一局 · Esc 返回标题")) -- 1302
			elseif p.paused then -- 1303
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · START 继续 · 长按BACK 重开 · Y 返回标题" or (touchMode and " · 点下方按钮继续/重开/返回标题" or " · Esc 继续 · R 重新开局 · E 返回标题")) -- 1304
			elseif #trial.offers > 0 then -- 1305
				sub = table.concat( -- 1306
					__TS__ArrayMap( -- 1306
						trial.offers, -- 1306
						function(____, talent, index) -- 1306
							local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1307
							return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1308
						end -- 1306
					), -- 1306
					"　" -- 1309
				) -- 1309
			else -- 1309
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 1311
			end -- 1311
		end -- 1311
		campaignSub.text = sub -- 1314
		campaignSub.position = Vec2(24 + safeL, h - 44 - safeT) -- 1315
		campaignSub.visible = true -- 1316
	end -- 1316
end -- 1316
function tickFrontend(frameDt) -- 1320
	if fe == nil or input == nil then -- 1321
		return -- 1322
	end -- 1322
	if fe.screen ~= "play" then -- 1326
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1327
		input:consumeEdges() -- 1328
		if act.type == "splashDone" then -- 1329
			fe.menus:resetInput() -- 1330
			fe.screen = "title" -- 1331
		elseif act.type == "trial" then -- 1332
			startTrial() -- 1333
		elseif act.type == "continue" then -- 1334
			if continueOfficialStory() == nil then -- 1335
				enterPlayRoom( -- 1336
					officialStartIndex(), -- 1336
					"official", -- 1336
					true -- 1336
				) -- 1336
			end -- 1336
		elseif act.type == "start" then -- 1338
			clearSession() -- 1340
			refreshTitleSessionFlag() -- 1341
			enterPlayRoom( -- 1342
				officialStartIndex(), -- 1342
				"official", -- 1342
				true -- 1342
			) -- 1342
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1343
			enterPlayRoom(act.roomIndex, "chapter") -- 1344
		elseif act.type == "openChapters" then -- 1345
			fe.menus:openChapters() -- 1346
			fe.screen = "chapters" -- 1347
		elseif act.type == "openControls" then -- 1348
			fe.menus:resetInput() -- 1349
			fe.screen = "controls" -- 1350
		elseif act.type == "openHistory" then -- 1351
			fe.menus:openHistory(true) -- 1352
			fe.screen = "history" -- 1353
		elseif act.type == "backEpilogue" then -- 1354
			fe.menus:resetInput() -- 1355
			fe.screen = "epilogue" -- 1356
		elseif act.type == "replayStory" then -- 1357
			clearSession() -- 1358
			refreshTitleSessionFlag() -- 1359
			enterPlayRoom( -- 1360
				officialStartIndex(), -- 1360
				"official", -- 1360
				true -- 1360
			) -- 1360
		elseif act.type == "backTitle" then -- 1361
			fe.menus:resetInput() -- 1362
			fe.screen = "title" -- 1363
		elseif act.type == "backPause" then -- 1364
			fe.menus:resetInput() -- 1365
			fe.screen = "play" -- 1366
		elseif act.type == "quit" then -- 1367
			quitGame() -- 1368
		end -- 1368
		return -- 1370
	end -- 1370
	if play == nil then -- 1374
		ensurePlay() -- 1375
	end -- 1375
	if play == nil then -- 1377
		return -- 1378
	end -- 1378
	local p = play -- 1380
	p.aimX = input.mx -- 1382
	p.aimY = input.my -- 1383
	local zoneTap = input.touchZoneTap -- 1385
	input.touchZoneTap = "" -- 1386
	local offers = p:getStoryTalentOffers() -- 1388
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1389
		if fe.hud.talentSelected >= #offers then -- 1390
			fe.hud.talentSelected = 0 -- 1391
		end -- 1391
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1393
			local idx = __TS__ParseInt( -- 1394
				string.sub(zoneTap, 8), -- 1394
				10 -- 1394
			) -- 1394
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1395
				input.fire.pressed = false -- 1396
			end -- 1396
		else -- 1396
			if input.talentDelta ~= 0 then -- 1399
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1400
				input.talentDelta = 0 -- 1401
			end -- 1401
			if input.talentConfirm then -- 1403
				p:chooseTalent(fe.hud.talentSelected) -- 1404
				input.talentConfirm = false -- 1405
				input.fire.pressed = false -- 1406
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1407
				input.fire.pressed = false -- 1409
			end -- 1409
		end -- 1409
	end -- 1409
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1415
		if input.navConfirm then -- 1416
			input.interact.pressed = true -- 1417
		end -- 1417
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1419
			flushProfile() -- 1420
			if p.run.source == "official" and hasSessionSave() then -- 1421
				clearSession() -- 1422
				refreshTitleSessionFlag() -- 1423
			end -- 1423
			fe.audio:stopRoomTransient() -- 1425
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1426
			fe.screen = "epilogue" -- 1430
			input:clearTransient(true) -- 1431
			input:consumeEdges() -- 1432
			return -- 1433
		end -- 1433
	end -- 1433
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1437
		p:closeCraftBench() -- 1438
		input:consumeEdges() -- 1439
		return -- 1440
	end -- 1440
	if not p.paused and input.pause.pressed then -- 1442
		p.paused = true -- 1443
		p.aimHold = 0 -- 1444
		p.bottleAimX = -1 -- 1445
		saveCurrentSession() -- 1446
		fe.menus:openPause() -- 1447
		input:clearTransient(true) -- 1448
		input:consumeEdges() -- 1449
	end -- 1449
	if p.paused then -- 1452
		clock:reset() -- 1454
		local pauseAct = fe:renderPlay( -- 1455
			frameDt, -- 1455
			p, -- 1455
			input, -- 1455
			stageVp.stageW, -- 1455
			stageVp.stageH -- 1455
		) -- 1455
		input:consumeEdges() -- 1456
		if pauseAct.type == "resume" then -- 1457
			p.paused = false -- 1458
		elseif pauseAct.type == "retry" then -- 1459
			ensurePlay({checkpoint = p.checkpoint}) -- 1460
		elseif pauseAct.type == "openChapters" then -- 1461
			fe.audio:stopRoomTransient() -- 1462
			fe.audio:setPaused(false) -- 1463
			fe.menus:openChapters(current) -- 1464
			fe.screen = "chapters" -- 1465
		elseif pauseAct.type == "toggleFullscreen" then -- 1466
			toggleFullscreen() -- 1467
		elseif pauseAct.type == "quit" then -- 1468
			quitGame() -- 1469
		elseif pauseAct.type == "toTitle" then -- 1470
			saveCurrentSession() -- 1471
			refreshTitleSessionFlag() -- 1472
			fe.menus:resetInput() -- 1473
			fe.screen = "title" -- 1474
		end -- 1474
		return -- 1476
	end -- 1476
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1479
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1480
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1482
		input:consumeEdges() -- 1483
		ensurePlay({checkpoint = p.checkpoint}) -- 1485
		return -- 1486
	end -- 1486
	local steps = clock:advance(frameDt) -- 1489
	local i = 0 -- 1490
	do -- 1490
		i = 0 -- 1491
		while i < steps do -- 1491
			input:beginStep(i == 0) -- 1492
			p:update(STEP, input) -- 1493
			input:endStep() -- 1494
			if p.wantRoom ~= "" then -- 1495
				break -- 1496
			end -- 1496
			i = i + 1 -- 1491
		end -- 1491
	end -- 1491
	if p.wantRoom ~= "" then -- 1501
		local key = p.wantRoom -- 1502
		p.wantRoom = "" -- 1503
		local idx = -1 -- 1504
		local j = 0 -- 1505
		do -- 1505
			j = 0 -- 1506
			while j < #ROOMS do -- 1506
				if ROOMS[j + 1].key == key then -- 1507
					idx = j -- 1508
				end -- 1508
				j = j + 1 -- 1506
			end -- 1506
		end -- 1506
		if idx >= 0 then -- 1511
			flushProfile() -- 1515
			local leaving = p:drainEvents() -- 1516
			if p.restartStory then -- 1518
				if storyRun ~= nil and storyRun.source == "official" then -- 1519
					clearSession() -- 1520
					refreshTitleSessionFlag() -- 1521
				end -- 1521
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1523
				storyRun = createRun(20261124, nextSource, profile) -- 1524
			end -- 1524
			current = idx -- 1526
			ensurePlay() -- 1527
			local fresh = play -- 1528
			if fresh ~= nil then -- 1529
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1530
					fresh.phase = "prologue-wake" -- 1531
				end -- 1531
				fresh:adoptEvents(leaving) -- 1533
			end -- 1533
			if not p.restartStory then -- 1535
				saveCurrentSession() -- 1536
			end -- 1536
			clock:reset() -- 1538
			dirty = true -- 1539
		end -- 1539
		return -- 1541
	end -- 1541
	flushProfile() -- 1545
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1546
		clearSession() -- 1547
		refreshTitleSessionFlag() -- 1548
	elseif p.sessionDirty then -- 1549
		saveCurrentSession() -- 1550
	end -- 1550
	fe:renderPlay( -- 1552
		frameDt, -- 1552
		p, -- 1552
		input, -- 1552
		stageVp.stageW, -- 1552
		stageVp.stageH -- 1552
	) -- 1552
end -- 1552
function redrawGraybox() -- 1556
	if draw == nil then -- 1557
		return -- 1558
	end -- 1558
	local w = viewW -- 1560
	local h = viewH -- 1561
	local room = ROOMS[current + 1] -- 1562
	draw:clear() -- 1564
	draw:drawRect( -- 1565
		Rect(0, h - TOP_H, w, TOP_H), -- 1565
		C_BG -- 1565
	) -- 1565
	draw:drawRect( -- 1566
		Rect(0, 0, w, BOTTOM_H), -- 1566
		C_BG -- 1566
	) -- 1566
	draw:drawSegment( -- 1567
		Vec2(0, h - TOP_H), -- 1567
		Vec2(w, h - TOP_H), -- 1567
		1, -- 1567
		Color(52, 54, 54, 255) -- 1567
	) -- 1567
	draw:drawSegment( -- 1568
		Vec2(0, BOTTOM_H), -- 1568
		Vec2(w, BOTTOM_H), -- 1568
		1, -- 1568
		Color(52, 54, 54, 255) -- 1568
	) -- 1568
	local v = computeView(room, w, h) -- 1570
	renderWorld( -- 1571
		draw, -- 1571
		room, -- 1571
		v, -- 1571
		w, -- 1571
		h -- 1571
	) -- 1571
	local roomTop = v.groundPx + room.height * v.scale -- 1573
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1574
	place( -- 1576
		titleLabel, -- 1576
		48, -- 1576
		h - 40, -- 1576
		0, -- 1576
		1 -- 1576
	) -- 1576
	place( -- 1577
		roomLabel, -- 1577
		48, -- 1577
		h - 96, -- 1577
		0, -- 1577
		1 -- 1577
	) -- 1577
	place( -- 1578
		captionLabel, -- 1578
		48, -- 1578
		h - 140, -- 1578
		0, -- 1578
		1 -- 1578
	) -- 1578
	place( -- 1580
		switchLabel, -- 1580
		48, -- 1580
		40, -- 1580
		0, -- 1580
		0 -- 1580
	) -- 1580
	place( -- 1581
		hintLabel, -- 1581
		48, -- 1581
		84, -- 1581
		0, -- 1581
		0 -- 1581
	) -- 1581
	place( -- 1582
		rulerLabel, -- 1582
		w - 216, -- 1582
		roomTop + 36 + v.scale * 0.5 - 14, -- 1582
		1, -- 1582
		0 -- 1582
	) -- 1582
	place( -- 1583
		standLabel, -- 1583
		48, -- 1583
		roomTop + 40, -- 1583
		0, -- 1583
		0 -- 1583
	) -- 1583
	place( -- 1584
		cartLabel, -- 1584
		48, -- 1584
		roomTop + 92, -- 1584
		0, -- 1584
		0 -- 1584
	) -- 1584
	if roomLabel ~= nil then -- 1586
		roomLabel.text = room.name -- 1587
	end -- 1587
	if captionLabel ~= nil then -- 1589
		captionLabel.text = room.caption -- 1590
	end -- 1590
	if hintLabel ~= nil then -- 1592
		local hintIdx = math.min(current, #HINTS - 1) -- 1593
		local lines = HINTS[hintIdx + 1] -- 1594
		local merged = lines[1] -- 1595
		do -- 1595
			local i = 1 -- 1596
			while i < #lines do -- 1596
				merged = (merged .. "    ") .. lines[i + 1] -- 1597
				i = i + 1 -- 1596
			end -- 1596
		end -- 1596
		hintLabel.text = merged -- 1599
	end -- 1599
	local specs = collectLabels(room, v, w) -- 1602
	local body = {} -- 1603
	local small = {} -- 1604
	do -- 1604
		local i = 0 -- 1605
		while i < #specs do -- 1605
			local s = specs[i + 1] -- 1606
			if s.size >= 24 then -- 1607
				body[#body + 1] = s -- 1608
			else -- 1608
				small[#small + 1] = s -- 1610
			end -- 1610
			i = i + 1 -- 1605
		end -- 1605
	end -- 1605
	applyPool(body, poolBody) -- 1613
	applyPool(small, poolSmall) -- 1614
	if LAYOUT_AUDIT then -- 1616
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1617
	end -- 1617
end -- 1617
function applyPool(specs, pool) -- 1621
	do -- 1621
		local i = 0 -- 1622
		while i < #pool do -- 1622
			local lb = pool[i + 1] -- 1623
			if i < #specs then -- 1624
				local s = specs[i + 1] -- 1625
				lb.text = s.text -- 1626
				lb.position = Vec2(s.x, s.y) -- 1627
				lb.anchor = Vec2(s.ax, s.ay) -- 1628
				lb.color = s.color -- 1629
				lb.visible = true -- 1630
			else -- 1630
				lb.visible = false -- 1632
			end -- 1632
			i = i + 1 -- 1622
		end -- 1622
	end -- 1622
end -- 1622
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
local function handleBackButton() -- 145
	if mode == 0 then -- 146
		setMode(1) -- 147
		return -- 148
	end -- 148
	if mode == 2 and play ~= nil then -- 150
		local trial = run and run.trial -- 151
		if trial ~= nil and (trial.lost or (run and run.finished) == true) then -- 152
			current = 0 -- 153
			play = nil -- 154
			run = nil -- 155
			setMode(1) -- 156
			if fe ~= nil then -- 157
				fe.screen = "title" -- 158
				fe.menus:resetInput() -- 159
			end -- 159
			return -- 161
		end -- 161
		play.paused = not play.paused -- 163
		clock:reset() -- 164
		if input ~= nil then -- 165
			input:clearTransient(true) -- 165
		end -- 165
		return -- 166
	end -- 166
	if fe == nil then -- 168
		return -- 169
	end -- 169
	if fe.screen == "splash" then -- 171
		fe.menus:resetSplash() -- 172
		fe.screen = "title" -- 173
		fe.menus:resetInput() -- 174
		return -- 175
	end -- 175
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "epilogue" or fe.screen == "history" then -- 177
		fe.menus:triggerBack() -- 178
		return -- 179
	end -- 179
	if fe.screen == "title" then -- 181
		if not canQuitApp() then -- 182
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 183
			return -- 184
		end -- 184
		if appClock - lastBackPressClock <= 2 then -- 186
			quitGame() -- 187
		else -- 187
			lastBackPressClock = appClock -- 189
			fe:showToast("再按一次返回退出游戏", 2) -- 190
		end -- 190
		return -- 192
	end -- 192
	if fe.screen == "play" and play ~= nil then -- 194
		if play.paused then -- 195
			fe.menus:triggerBack() -- 196
			return -- 197
		end -- 197
		if play.craftBench.active then -- 199
			play:closeCraftBench() -- 200
			return -- 201
		end -- 201
		play.paused = true -- 203
		play.aimHold = 0 -- 204
		play.bottleAimX = -1 -- 205
		saveCurrentSession() -- 206
		fe.menus:openPause() -- 207
		if input ~= nil then -- 208
			input:clearTransient(true) -- 208
		end -- 208
	end -- 208
end -- 145
local function makeGrayboxLabel(text, size, color) -- 361
	if grayboxLayer == nil then -- 362
		return nil -- 363
	end -- 363
	local lb = Label(FONT, size) -- 365
	if lb == nil then -- 366
		return nil -- 367
	end -- 367
	lb.text = text -- 369
	lb.color = color -- 370
	lb:addTo(grayboxLayer) -- 371
	lb.visible = true -- 372
	return lb -- 373
end -- 361
function ____exports.start(parent, initialMode, startScreen) -- 385
	if initialMode == nil then -- 385
		initialMode = 1 -- 385
	end -- 385
	if startScreen == nil then -- 385
		startScreen = "title" -- 385
	end -- 385
	root = parent -- 386
	mode = initialMode -- 387
	grayboxLayer = Node() -- 390
	grayboxLayer.order = 2 -- 391
	grayboxLayer:addTo(parent) -- 392
	draw = DrawNode() -- 394
	draw:addTo(grayboxLayer) -- 395
	campaignLayer = Node() -- 398
	campaignLayer.order = 3 -- 399
	campaignLayer:addTo(parent) -- 400
	campaignDraw = DrawNode() -- 401
	campaignDraw:addTo(campaignLayer) -- 402
	campaignHud = Label(FONT, 24) -- 403
	if campaignHud ~= nil then -- 404
		campaignHud.color = C_TEXT -- 405
		campaignHud.anchor = Vec2(0, 1) -- 406
		campaignHud:addTo(campaignLayer) -- 407
		campaignHud.visible = true -- 408
	end -- 408
	campaignSub = Label(FONT, 20) -- 410
	if campaignSub ~= nil then -- 411
		campaignSub.color = C_ACCENT -- 412
		campaignSub.anchor = Vec2(0, 1) -- 413
		campaignSub:addTo(campaignLayer) -- 414
		campaignSub.visible = true -- 415
	end -- 415
	campaignLayer.visible = mode == 2 -- 417
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 419
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 420
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 421
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 422
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 423
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 424
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 425
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 426
	do -- 426
		local i = 0 -- 428
		while i < POOL_BODY do -- 428
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 429
			if lb ~= nil then -- 430
				poolBody[#poolBody + 1] = lb -- 431
			end -- 431
			i = i + 1 -- 428
		end -- 428
	end -- 428
	do -- 428
		local i = 0 -- 434
		while i < POOL_SMALL do -- 434
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 435
			if lb ~= nil then -- 436
				poolSmall[#poolSmall + 1] = lb -- 437
			end -- 437
			i = i + 1 -- 434
		end -- 434
	end -- 434
	if mode == 1 then -- 443
		local loaded = loadSave() -- 444
		profile = loaded.state -- 445
		profileStatus = loaded.status -- 446
		profileDetail = loaded.detail -- 447
	end -- 447
	fe = __TS__New(WatchFrontend, parent) -- 449
	fe.screen = startScreen -- 450
	if startScreen == "splash" then -- 451
		fe.menus:resetSplash() -- 452
	end -- 452
	refreshTitleSessionFlag() -- 454
	grayboxLayer.visible = mode == 0 -- 455
	fe:setVisible(mode == 1) -- 456
	if campaignLayer ~= nil then -- 457
		campaignLayer.visible = mode == 2 -- 458
	end -- 458
	input = __TS__New(Input) -- 461
	touchRouter = __TS__New(TouchRouter, input.settings) -- 462
	touchRouter:attach(parent) -- 463
	input:bindTouch(touchRouter) -- 464
	gamepadRouter = __TS__New(GamepadRouter, input.settings) -- 466
	gamepadRouter:attach(parent) -- 467
	input:bindGamepad(gamepadRouter) -- 468
	touchControls = __TS__New(TouchControls, parent) -- 470
	parent:gslot( -- 473
		"AppEvent", -- 473
		function(eventType) -- 473
			if eventType == "BackButton" then -- 474
				handleBackButton() -- 475
				return -- 476
			end -- 476
			if eventType == "Quit" or eventType == "Shutdown" then -- 478
				flushProfile() -- 479
				saveCurrentSession() -- 480
				if input ~= nil then -- 481
					input:clearTransient(false) -- 481
				end -- 481
				return -- 482
			end -- 482
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 484
				flushProfile() -- 485
				saveCurrentSession() -- 486
				if input ~= nil then -- 487
					input:clearTransient(true) -- 487
				end -- 487
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 488
					play.paused = true -- 489
					play.aimHold = 0 -- 490
					play.bottleAimX = -1 -- 491
					fe.menus:openPause() -- 492
				elseif mode == 2 and play ~= nil and not play.paused then -- 493
					play.paused = true -- 494
				end -- 494
				if fe ~= nil then -- 496
					fe.audio:setPaused(true) -- 497
				end -- 497
				return -- 499
			end -- 499
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 501
				if fe ~= nil then -- 502
					local paused = play ~= nil and play.paused and (mode == 1 and fe.screen == "play" or mode == 2) -- 503
					fe.audio:setPaused(paused) -- 505
				end -- 505
			end -- 505
		end -- 473
	) -- 473
	parent:onKeyDown(function(key) -- 511
		onFirstUserGesture() -- 512
		if input ~= nil then -- 513
			input:markKeyboardActivity() -- 513
		end -- 513
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 514
			toggleFullscreen() -- 516
			return -- 517
		end -- 517
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 519
			play:toggleArtifactWeapon() -- 520
			return -- 521
		end -- 521
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and #play:getStoryTalentOffers() > 0 then -- 523
			if key == "1" then -- 525
				play:chooseTalent(0) -- 526
				if input ~= nil then -- 527
					input:consumePickRoom() -- 527
				end -- 527
				return -- 528
			end -- 528
			if key == "2" then -- 530
				play:chooseTalent(1) -- 531
				if input ~= nil then -- 532
					input:consumePickRoom() -- 532
				end -- 532
				return -- 533
			end -- 533
			if key == "3" then -- 535
				play:chooseTalent(2) -- 536
				if input ~= nil then -- 537
					input:consumePickRoom() -- 537
				end -- 537
				return -- 538
			end -- 538
		end -- 538
		local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 541
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 542
			fe.menus:onKeyEvent(key) -- 543
		end -- 543
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay or mode == 2) then -- 545
			if key == "E" then -- 546
				input.interact.pressed = true -- 547
			elseif key == "Space" then -- 548
				input.jump.pressed = true -- 549
			elseif key == "Escape" then -- 550
				input.pause.pressed = true -- 551
			elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 552
				input.retry.pressed = true -- 553
			end -- 553
		end -- 553
		if mode == 2 and (run and run.trial) ~= nil then -- 556
			return -- 556
		end -- 556
		if isReleaseBuild() then -- 557
			return -- 557
		end -- 557
		if key == "F1" then -- 558
			if mode == 2 then -- 559
				current = 0 -- 560
				play = nil -- 561
				ensurePlay() -- 562
			else -- 562
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 564
			end -- 564
		elseif key == "F2" then -- 566
			setMode(0) -- 567
		elseif key == "1" then -- 568
			pickByIndex(0) -- 569
		elseif key == "2" then -- 570
			pickByIndex(1) -- 571
		elseif key == "3" then -- 572
			pickByIndex(2) -- 573
		elseif key == "4" then -- 574
			pickByIndex(3) -- 575
		elseif key == "5" then -- 576
			pickByIndex(4) -- 577
		elseif key == "6" then -- 578
			pickByIndex(5) -- 579
		elseif key == "7" then -- 580
			pickByIndex(6) -- 581
		elseif key == "8" then -- 582
			pickByIndex(7) -- 583
		end -- 583
	end) -- 511
	viewW = View.size.width -- 587
	viewH = View.size.height -- 588
	applySize() -- 589
	local reg = _G.package.loaded -- 592
	reg["watch.input"] = input -- 593
	reg["watch.touch"] = touchRouter -- 594
	reg["watch.gamepad"] = gamepadRouter -- 595
	reg["watch.fe"] = { -- 596
		setScreen = function(sc) -- 597
			if fe == nil then -- 598
				return -- 599
			end -- 599
			setMode(1) -- 601
			fe.screen = sc -- 602
			if sc == "splash" then -- 603
				fe.menus:resetSplash() -- 604
			elseif sc == "chapters" then -- 605
				fe.menus:openChapters() -- 606
			elseif sc == "epilogue" then -- 607
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 608
			elseif sc == "history" then -- 612
				fe.menus:openHistory(false) -- 613
			else -- 613
				fe.menus:resetInput() -- 615
			end -- 615
			if sc == "play" then -- 617
				ensurePlay() -- 618
			end -- 618
		end, -- 597
		jumpRoom = function(keyOrIdx) -- 621
			local idx = -1 -- 622
			if type(keyOrIdx) == "number" then -- 623
				idx = keyOrIdx -- 624
			else -- 624
				local k = 0 -- 626
				do -- 626
					k = 0 -- 627
					while k < #ROOMS do -- 627
						if ROOMS[k + 1].key == keyOrIdx then -- 628
							idx = k -- 629
						end -- 629
						k = k + 1 -- 627
					end -- 627
				end -- 627
			end -- 627
			if idx >= 0 and idx < #ROOMS then -- 633
				enterPlayRoom(idx, "debug") -- 634
			end -- 634
		end, -- 621
		getPlay = function() return play end, -- 637
		getFrontend = function() return fe end, -- 638
		startStory = function() -- 640
			enterPlayRoom( -- 641
				officialStartIndex(), -- 641
				"official", -- 641
				true -- 641
			) -- 641
			return play -- 642
		end, -- 640
		previewChapter = function(idx) -- 645
			enterPlayRoom(idx, "chapter") -- 646
			return play -- 647
		end, -- 645
		getStoryRun = function() return storyRun end, -- 649
		getProfilePending = function() return profilePending() end, -- 650
		flushProfileNow = function() return flushProfile() end, -- 651
		getProfile = function() return profile end, -- 653
		getProfileStatus = function() return profileStatus end, -- 654
		getProfileDetail = function() return profileDetail end, -- 655
		useTestSave = function(name) -- 656
			setSaveFile(name) -- 657
			setSessionFile(name == "" and "" or name .. ".session") -- 658
			clearProfilePending() -- 659
			local loaded = loadSave() -- 660
			profile = loaded.state -- 661
			profileStatus = loaded.status -- 662
			profileDetail = loaded.detail -- 663
			refreshTitleSessionFlag() -- 664
		end, -- 656
		useTestSession = function(name) -- 666
			setSessionFile(name) -- 667
			refreshTitleSessionFlag() -- 668
		end, -- 666
		getSessionFile = getSessionFile, -- 670
		hasSessionSave = hasSessionSave, -- 671
		saveSessionNow = function() return saveCurrentSession() end, -- 672
		clearSessionNow = function() -- 673
			local ok = clearSession() -- 674
			refreshTitleSessionFlag() -- 675
			return ok -- 676
		end, -- 673
		continueStory = function() return continueOfficialStory() end, -- 678
		saveNow = function() return saveSave(profile) end, -- 679
		getSaveFile = getSaveFile, -- 680
		isRelease = function() return isReleaseBuild() end, -- 681
		getReleaseVersion = function() -- 682
			local ____opt_30 = getReleaseConfig() -- 682
			return ____opt_30 and ____opt_30.version or "dev" -- 682
		end, -- 682
		toggleFullscreen = function() return toggleFullscreen() end, -- 683
		quitGame = function() return quitGame() end, -- 684
		startTrial = function() return startTrial() end, -- 685
		handleBackButton = function() return handleBackButton() end, -- 686
		getViewport = function() return stageVp end, -- 687
		getTouchController = function() return touchControls end, -- 688
		getTouchRouter = function() return touchRouter end, -- 689
		getGamepad = function() return gamepadRouter end, -- 690
		setGamepadSim = function(state) -- 691
			if gamepadRouter ~= nil then -- 692
				gamepadRouter:setSimulatedState(state) -- 692
			end -- 692
		end, -- 691
		injectTouch = function(phase, id, x, y, fromMouse) -- 694
			if touchRouter ~= nil then -- 695
				touchRouter:injectTouch( -- 695
					phase, -- 695
					id, -- 695
					x, -- 695
					y, -- 695
					fromMouse -- 695
				) -- 695
			end -- 695
		end, -- 694
		getInputMode = function() return input and input.inputMode or "kbm" end, -- 697
		setInputMode = function(m) -- 698
			if input ~= nil then -- 699
				input:setInputMode(m) -- 699
			end -- 699
		end, -- 698
		setModePref = function(pref) -- 701
			if input ~= nil then -- 702
				input:setModePref(pref) -- 702
			end -- 702
		end, -- 701
		applyViewportForTest = function(w, h) -- 704
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 705
				testViewportOverride = {w = w, h = h} -- 706
				viewW = w -- 707
				viewH = h -- 708
			else -- 708
				testViewportOverride = nil -- 710
				viewW = View.size.width -- 711
				viewH = View.size.height -- 712
			end -- 712
			applySize() -- 714
			dirty = true -- 715
			return stageVp -- 716
		end, -- 704
		getToast = function() return fe and fe:getToastText() or "" end -- 718
	} -- 718
	if mode == 1 and startScreen == "play" then -- 721
		ensurePlay() -- 722
	end -- 722
	parent:schedule(function(frameDt) -- 725
		tick(frameDt) -- 726
		return false -- 727
	end) -- 725
end -- 385
return ____exports -- 385
