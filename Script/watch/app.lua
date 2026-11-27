-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local isReleaseBuild, onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, place, setMode, flushProfile, officialStartIndex, roomIndexByKey, applyChapterPreviewContext, enterPlayRoom, pickByIndex, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, touchRouter, gamepadRouter, touchControls, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock, trialTalentSelected -- 98
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
		local has = hasSessionSave() -- 230
		fe.menus.hasSession = has -- 231
		if has then -- 232
			local loaded = loadSession() -- 233
			fe.menus:setSessionRoomKey(loaded.status == "ok" and loaded.state ~= nil and loaded.state.roomKey or "") -- 234
		else -- 234
			fe.menus:setSessionRoomKey("") -- 236
		end -- 236
	end -- 236
end -- 236
function saveCurrentSession() -- 241
	if not canSaveSession() or play == nil then -- 242
		return false -- 243
	end -- 243
	play.sessionDirty = false -- 245
	local ok = saveSession(play:exportSession()) -- 246
	refreshTitleSessionFlag() -- 247
	return ok -- 248
end -- 248
function continueOfficialStory() -- 251
	local res = loadSession() -- 252
	if res.status ~= "ok" or res.state == nil then -- 253
		refreshTitleSessionFlag() -- 254
		return nil -- 255
	end -- 255
	local s = res.state -- 257
	local idx = roomIndexByKey(s.roomKey) -- 258
	if ROOMS[idx + 1].key ~= s.roomKey then -- 259
		return nil -- 260
	end -- 260
	storyRun = createRun(s.seed, "official", profile) -- 262
	storyRun.checkpoint = s.checkpoint -- 263
	storyRun.story.route = s.route -- 264
	storyRun.story.hp = s.hp -- 265
	storyRun.story.maxHp = s.maxHp -- 266
	storyRun.story.hpAtGate = s.hpAtGate -- 267
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 268
	storyRun.story.settled = s.settled -- 269
	storyRun.story.phase = s.phase -- 270
	storyRun.story.countTick = s.countTick -- 271
	storyRun.story.phaseTick = s.phaseTick -- 272
	storyRun.story.handTicks = s.handTicks -- 273
	storyRun.story.handDone = s.handDone -- 274
	storyRun.story.lineSaid = s.lineSaid -- 275
	storyRun.story.tied = s.tied -- 276
	storyRun.story.carry = s.carry -- 277
	storyRun.story.escortDone = s.escortDone -- 278
	storyRun.story.craftedWeapon = s.craftedWeapon -- 279
	storyRun.story.equippedWeapon = s.equippedWeapon -- 280
	storyRun.inventory.wood = s.wood -- 281
	storyRun.inventory.bell = s.bell -- 282
	storyRun.inventory.scrap = s.scrap -- 283
	storyRun.inventory.wedge = s.wedge -- 284
	storyRun.inventory.ammo = s.ammo -- 285
	storyRun.inventory.shield = s.shield -- 286
	storyRun.inventory.pass = s.pass -- 287
	storyRun.inventory.quickbelt = s.quickbelt -- 288
	local k = 0 -- 289
	do -- 289
		k = 0 -- 290
		while k < #s.taken do -- 290
			storyRun.taken[s.taken[k + 1]] = true -- 291
			k = k + 1 -- 290
		end -- 290
	end -- 290
	do -- 290
		k = 0 -- 293
		while k < #s.segments do -- 293
			storyRun.story.segments[s.segments[k + 1]] = true -- 294
			k = k + 1 -- 293
		end -- 293
	end -- 293
	if s.campaignRoute ~= nil then -- 296
		storyRun.route = s.campaignRoute -- 297
	end -- 297
	if s.joined ~= nil then -- 299
		storyRun.joined = s.joined -- 300
	end -- 300
	if s.c1Latch ~= nil then -- 302
		storyRun.c1Latch = s.c1Latch -- 303
	end -- 303
	if s.c2Latch ~= nil then -- 305
		storyRun.c2Latch = s.c2Latch -- 306
	end -- 306
	if s.props ~= nil then -- 308
		do -- 308
			k = 0 -- 309
			while k < #s.props do -- 309
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 310
				local pid = parts[1] -- 311
				if pid ~= nil and pid ~= "" then -- 312
					local ____storyRun_props_16 = storyRun.props -- 313
					local ____temp_12 -- 314
					if parts[2] == nil then -- 314
						____temp_12 = true -- 314
					else -- 314
						____temp_12 = parts[2] == "1" -- 314
					end -- 314
					local ____temp_14 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 315
					local ____temp_15 = parts[4] == "1" -- 316
					local ____temp_13 -- 317
					if parts[5] == "1" then -- 317
						____temp_13 = true -- 317
					else -- 317
						____temp_13 = nil -- 317
					end -- 317
					____storyRun_props_16[pid] = {broken = ____temp_12, hp = ____temp_14, wedge = ____temp_15, revealed = ____temp_13} -- 313
				end -- 313
				k = k + 1 -- 309
			end -- 309
		end -- 309
	end -- 309
	local stTalents = createStoryTalents(s.seed) -- 322
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 323
		stTalents.randomState = s.talentSeed -- 324
	end -- 324
	stTalents.room = s.talentRoom or "" -- 326
	stTalents.ranks.vitality = s.talentVitality or 0 -- 327
	stTalents.ranks.reload = s.talentReload or 0 -- 328
	stTalents.ranks.guard = s.talentGuard or 0 -- 329
	stTalents.ranks.craft = s.talentCraft or 0 -- 330
	if s.talentOffers ~= nil then -- 331
		do -- 331
			k = 0 -- 332
			while k < #s.talentOffers do -- 332
				local t = s.talentOffers[k + 1] -- 333
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 334
					local ____stTalents_offers_17 = stTalents.offers -- 335
					____stTalents_offers_17[#____stTalents_offers_17 + 1] = t -- 335
				end -- 335
				k = k + 1 -- 332
			end -- 332
		end -- 332
	end -- 332
	storyRun.story.talents = stTalents -- 339
	current = idx -- 340
	setMode(1) -- 341
	if fe ~= nil then -- 342
		fe.screen = "play" -- 343
	end -- 343
	play = nil -- 345
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 346
	local cur = play -- 347
	if cur ~= nil then -- 348
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 349
			cur.cartAxle = s.cartAxle -- 350
			cur.cartDocked = s.cartDocked -- 351
		end -- 351
		if s.playerX ~= nil and s.playerX >= 0 then -- 353
			cur.player.x = math.max( -- 354
				cur.room.minX + 16, -- 354
				math.min(cur.room.maxX - 16, s.playerX) -- 354
			) -- 354
			cur.player.y = math.max(0, s.playerY or 0) -- 355
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 356
				cur.player.depth = math.max( -- 357
					cur.room.depth.min, -- 357
					math.min(cur.room.depth.max, s.playerDepth) -- 357
				) -- 357
			end -- 357
		end -- 357
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 360
			cur.gateTick = s.gateTick -- 361
		end -- 361
		if cur.room.key == "village" then -- 363
			if s.hasBottle == true then -- 364
				cur.hasBottle = true -- 364
			end -- 364
			if s.villagePassed == true then -- 365
				cur.passed = true -- 365
			end -- 365
		end -- 365
		if cur.room.key == "prologue" and (s.phase == "" or s.phase == "prologue-wake" or s.phase == "prologue-shadow" or s.phase == "prologue-escape" or s.phase == "prologue-hide") then -- 368
			cur.phase = "prologue-wake" -- 374
		end -- 374
		if (string.find(cur.room.key, "escort", nil, true) or 0) - 1 == 0 and s.route == "soldier" and not cur.craftBench.active and not cur.carryOn then -- 377
			cur.carryOn = true -- 378
			storyRun.story.carry = true -- 379
		end -- 379
	end -- 379
	return play -- 382
end -- 382
function place(lb, x, y, ax, ay) -- 400
	if lb == nil then -- 401
		return -- 402
	end -- 402
	lb.position = Vec2(x, y) -- 404
	lb.anchor = Vec2(ax, ay) -- 405
	lb.visible = true -- 406
end -- 406
function setMode(nextMode) -- 756
	mode = nextMode -- 757
	if grayboxLayer ~= nil then -- 758
		grayboxLayer.visible = mode == 0 -- 759
	end -- 759
	if fe ~= nil then -- 761
		fe:setVisible(mode == 1) -- 762
	end -- 762
	if campaignLayer ~= nil then -- 764
		campaignLayer.visible = mode == 2 -- 765
	end -- 765
	dirty = true -- 767
	clock:reset() -- 768
end -- 768
function flushProfile() -- 775
	local cur = play -- 776
	if cur ~= nil and cur.archiveDirty then -- 777
		cur.archiveDirty = false -- 778
		markProfilePending(profile) -- 779
	end -- 779
	local ok = flushSaveProfile() -- 781
	if not ok and cur ~= nil then -- 782
		cur.archiveDirty = true -- 783
	end -- 783
	return ok -- 785
end -- 785
function officialStartIndex() -- 789
	local mp = profile.museumPhase -- 790
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 791
	return inMuseum and roomIndexByKey("museum") or 0 -- 792
end -- 792
function roomIndexByKey(key) -- 795
	local i = 0 -- 796
	do -- 796
		i = 0 -- 797
		while i < #ROOMS do -- 797
			if ROOMS[i + 1].key == key then -- 798
				return i -- 799
			end -- 799
			i = i + 1 -- 797
		end -- 797
	end -- 797
	return 0 -- 802
end -- 802
function applyChapterPreviewContext(targetRun, roomKey, routeOverride) -- 805
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" and routeOverride ~= "soldier" then -- 808
		targetRun.story.route = "child" -- 810
		targetRun.story.settled = true -- 811
		targetRun.story.countTick = 1440 -- 812
	elseif roomKey == "gatepath" or (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 or roomKey == "tower" and routeOverride == "soldier" then -- 813
		targetRun.story.route = "soldier" -- 815
		targetRun.story.settled = true -- 816
		targetRun.joined = true -- 817
		if (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 then -- 818
			targetRun.story.carry = true -- 819
		end -- 819
		if roomKey == "escort3" then -- 821
			targetRun.inventory.wood = math.max(targetRun.inventory.wood, 2) -- 822
			targetRun.inventory.scrap = math.max(targetRun.inventory.scrap, 2) -- 823
			targetRun.inventory.bell = math.max(targetRun.inventory.bell, 1) -- 824
			targetRun.inventory.wedge = math.max(targetRun.inventory.wedge, 1) -- 825
		end -- 825
	end -- 825
end -- 825
function enterPlayRoom(idx, source, fresh, chapterRoute) -- 830
	if source == nil then -- 830
		source = "debug" -- 830
	end -- 830
	if fresh == nil then -- 830
		fresh = false -- 830
	end -- 830
	current = idx -- 831
	setMode(1) -- 832
	if fe ~= nil then -- 833
		fe.screen = "play" -- 834
	end -- 834
	play = nil -- 836
	if fresh or source == "chapter" or storyRun == nil then -- 838
		storyRun = createRun(20261124, source, profile) -- 839
		if source == "chapter" then -- 840
			local targetKey = ROOMS[current + 1] ~= nil and ROOMS[current + 1].key or "" -- 841
			applyChapterPreviewContext(storyRun, targetKey, chapterRoute) -- 842
		end -- 842
	else -- 842
		storyRun.source = source -- 845
	end -- 845
	ensurePlay() -- 847
	local firstPlay = play -- 849
	if firstPlay ~= nil and ROOMS[current + 1].key == "prologue" and (fresh and source == "official" or source == "chapter") then -- 850
		firstPlay.phase = "prologue-wake" -- 852
	end -- 852
	flushProfile() -- 854
end -- 854
function pickByIndex(idx, source) -- 857
	if source == nil then -- 857
		source = "debug" -- 857
	end -- 857
	if mode == 2 then -- 858
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 859
			return -- 860
		end -- 860
		current = idx -- 862
		play = nil -- 863
		clock:reset() -- 864
		ensurePlay() -- 865
		return -- 866
	end -- 866
	if idx < 0 or idx >= #ROOMS then -- 868
		return -- 869
	end -- 869
	flushProfile() -- 871
	if storyRun ~= nil then -- 872
		storyRun.source = source -- 873
	end -- 873
	current = idx -- 875
	dirty = true -- 876
	play = nil -- 877
	clock:reset() -- 878
	if mode == 1 then -- 879
		if fe ~= nil then -- 880
			fe.screen = "play" -- 881
		end -- 881
		ensurePlay() -- 883
	end -- 883
end -- 883
function applySize() -- 887
	if root == nil then -- 888
		return -- 889
	end -- 889
	root.size = Size(viewW, viewH) -- 891
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 892
	stageVp = computeStageViewport(viewW, viewH) -- 893
	if input ~= nil then -- 894
		input:setStageViewport(stageVp) -- 895
	end -- 895
	if fe ~= nil then -- 897
		fe:setStagePlacement(stageVp) -- 898
	end -- 898
	if campaignLayer ~= nil then -- 900
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 901
	end -- 901
	if grayboxLayer ~= nil then -- 903
		grayboxLayer.position = Vec2(0, 0) -- 904
	end -- 904
end -- 904
function syncFrameAdapters(frameDt) -- 908
	if input == nil then -- 909
		return -- 910
	end -- 910
	local p = play -- 912
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 913
	local isTrialMode = mode == 2 and p ~= nil -- 914
	local gameplayActive = isPlayMode or isTrialMode -- 915
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 917
		p, -- 919
		stageVp.stageW, -- 919
		stageVp.stageH, -- 919
		input:isTouchMode() -- 919
	) or ({}) -- 920
	if touchControls ~= nil and touchRouter ~= nil then -- 922
		local isFs = false -- 923
		if canToggleFullscreen() then -- 924
			do -- 924
				local function ____catch() -- 924
					isFs = false -- 928
				end -- 928
				local ____try = pcall(function() -- 928
					isFs = App.fullScreen -- 926
				end) -- 926
				if not ____try then -- 926
					____catch() -- 926
				end -- 926
			end -- 926
		end -- 926
		local ____touchControls_55 = touchControls -- 931
		local ____touchControls_syncContext_56 = touchControls.syncContext -- 931
		local ____stageVp_48 = stageVp -- 932
		local ____mode_49 = mode -- 933
		local ____temp_50 = fe ~= nil and fe.screen or "title" -- 934
		local ____run_51 = run -- 936
		local ____temp_52 = fe ~= nil and fe.cam or nil -- 937
		local ____input_53 = input -- 938
		local ____touchRouter_54 = touchRouter -- 939
		local ____temp_46 -- 940
		if fe ~= nil then -- 940
			____temp_46 = fe.contract:isAssistHintsEnabled() -- 940
		else -- 940
			____temp_46 = false -- 940
		end -- 940
		local ____temp_47 -- 941
		if fe ~= nil then -- 941
			____temp_47 = fe.audio:isAllMuted() -- 941
		else -- 941
			____temp_47 = false -- 941
		end -- 941
		____touchControls_syncContext_56(____touchControls_55, { -- 931
			viewport = ____stageVp_48, -- 932
			mode = ____mode_49, -- 933
			screen = ____temp_50, -- 934
			play = p, -- 935
			run = ____run_51, -- 936
			cam = ____temp_52, -- 937
			input = ____input_53, -- 938
			router = ____touchRouter_54, -- 939
			assistHintsEnabled = ____temp_46, -- 940
			isMuted = ____temp_47, -- 941
			isFullscreen = isFs, -- 942
			storyTalentBoxes = storyTalentBoxes, -- 943
			dt = frameDt -- 944
		}) -- 944
	end -- 944
	if gamepadRouter ~= nil then -- 948
		local trial = run and run.trial -- 949
		local trialEnded = isTrialMode and trial ~= nil and (trial.lost or (run and run.finished) == true) -- 950
		local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 951
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 952
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 955
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 956
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 957
		local ____temp_61 -- 960
		if isPlayMode and p ~= nil then -- 960
			____temp_61 = isCutsceneBlockingPlay(p) -- 960
		else -- 960
			____temp_61 = false -- 960
		end -- 960
		local cutsceneBlocking = ____temp_61 -- 960
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 961
		local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 963
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 964
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 966
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 968
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 971
		local playerScreenX = stageVp.stageW * 0.5 -- 973
		local playerScreenY = stageVp.stageH * 0.38 -- 974
		if p ~= nil then -- 975
			if isPlayMode and fe ~= nil then -- 976
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 977
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 978
			else -- 978
				local vz = p.view.zoom > 0 and p.view.zoom or 1 -- 981
				playerScreenX = stageVp.stageW * 0.5 + (p.player.x + p.player.facing * 8 - p.cam.x) * vz -- 982
				playerScreenY = stageVp.stageH * 0.5 + (p.player.y + p.player.h * 0.72 + p.player.depth * DEPTH_Y_SCALE - p.cam.y) * vz -- 983
			end -- 983
		end -- 983
		local enemyTargets = canShoot and p ~= nil and (isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or collectTrialAimTargets(p, stageVp.stageW, stageVp.stageH)) or ({}) -- 987
		local gpCtx = { -- 993
			stageW = stageVp.stageW, -- 994
			stageH = stageVp.stageH, -- 995
			uiScale = stageVp.uiScale, -- 996
			modal = modal, -- 997
			gameplayActive = gameplayActive, -- 998
			reloadActive = reloadActive, -- 999
			craftActive = craftActive, -- 1000
			talentOfferCount = talentOfferCount, -- 1001
			childMode = p ~= nil and p.childMode, -- 1002
			allowDepth = allowDepth, -- 1003
			canShoot = canShoot, -- 1004
			canBottleAim = canBottleAim, -- 1005
			playerRolling = p ~= nil and p.player.rollT > 0, -- 1006
			inLowArch = inLowArch, -- 1007
			inTowerEnd = inTowerEnd, -- 1008
			playerFacing = p ~= nil and p.player.facing or 1, -- 1009
			playerScreenX = playerScreenX, -- 1010
			playerScreenY = playerScreenY, -- 1011
			enemyTargets = enemyTargets -- 1012
		} -- 1012
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 1014
	end -- 1014
end -- 1014
function renderTouchOverlay() -- 1018
	if touchControls ~= nil and touchRouter ~= nil then -- 1019
		touchControls:render(touchRouter) -- 1020
	end -- 1020
end -- 1020
function tick(frameDt) -- 1024
	appClock = appClock + math.min( -- 1025
		0.05, -- 1025
		math.max(0, frameDt) -- 1025
	) -- 1025
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 1026
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 1027
	if w ~= viewW or h ~= viewH then -- 1028
		viewW = w -- 1029
		viewH = h -- 1030
		applySize() -- 1031
		dirty = true -- 1032
	end -- 1032
	if input == nil then -- 1034
		return -- 1035
	end -- 1035
	syncFrameAdapters(frameDt) -- 1037
	input:update() -- 1038
	if input.userInteracted then -- 1040
		onFirstUserGesture() -- 1041
	end -- 1041
	if input.muteTogglePressed and fe ~= nil then -- 1043
		input.muteTogglePressed = false -- 1044
		fe.audio:toggleAllMuted() -- 1045
	end -- 1045
	if input.fullscreenTogglePressed then -- 1047
		input.fullscreenTogglePressed = false -- 1048
		toggleFullscreen() -- 1049
	end -- 1049
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 1051
		input.artifactTogglePressed = false -- 1052
		play:toggleArtifactWeapon() -- 1053
	end -- 1053
	if input.bottleCanceled and play ~= nil then -- 1055
		input.bottleCanceled = false -- 1056
		play.aimHold = 0 -- 1057
		play.bottleAimX = -1 -- 1058
	end -- 1058
	if mode == 2 and (run and run.trial) ~= nil then -- 1061
		tickCampaign(frameDt) -- 1062
		renderTouchOverlay() -- 1063
		return -- 1064
	end -- 1064
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 1067
		play:chooseTalent(input.pickRoom - 1) -- 1070
		input.pickRoom = 0 -- 1071
	end -- 1071
	if isReleaseBuild() then -- 1074
		input.toggleView.pressed = false -- 1075
		input.pickRoom = 0 -- 1076
		input.tab.pressed = false -- 1077
	else -- 1077
		if input.toggleView.pressed then -- 1080
			input.toggleView.pressed = false -- 1081
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 1082
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 1083
				ensurePlay() -- 1084
			end -- 1084
		end -- 1084
		if input.pickRoom ~= 0 then -- 1089
			local idx = input.pickRoom - 1 -- 1090
			input.pickRoom = 0 -- 1091
			pickByIndex(idx) -- 1092
		elseif input.tab.pressed then -- 1093
			input.tab.pressed = false -- 1094
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 1095
				pickByIndex((current + 1) % #ROOMS) -- 1096
			end -- 1096
		end -- 1096
	end -- 1096
	if mode == 2 then -- 1101
		tickCampaign(frameDt) -- 1102
	elseif mode == 1 then -- 1103
		tickFrontend(frameDt) -- 1104
	elseif dirty then -- 1105
		redrawGraybox() -- 1106
		dirty = false -- 1107
	end -- 1107
	renderTouchOverlay() -- 1109
end -- 1109
function registerPlay() -- 1113
	local reg = _G.package.loaded -- 1114
	reg["watch.play"] = play -- 1115
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 1116
	reg["watch.room"] = rooms[current + 1].key -- 1117
end -- 1117
function ensurePlay(resume) -- 1121
	if mode == 2 then -- 1122
		if run == nil then -- 1123
			run = createRun() -- 1124
		end -- 1124
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 1126
	else -- 1126
		if storyRun == nil then -- 1130
			storyRun = createRun(20261124, "debug", profile) -- 1131
		end -- 1131
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1133
	end -- 1133
	registerPlay() -- 1135
	clock:reset() -- 1136
	if fe ~= nil and mode == 1 then -- 1137
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1138
	elseif fe ~= nil and mode == 2 then -- 1139
		fe:resetTrialAudio(play) -- 1140
	end -- 1140
end -- 1140
function startTrial() -- 1144
	current = 0 -- 1145
	trialTalentSelected = 0 -- 1146
	run = createTrial(App.rand) -- 1147
	setMode(2) -- 1148
	ensurePlay() -- 1149
end -- 1149
function tickCampaign(frameDt) -- 1152
	if input == nil then -- 1153
		return -- 1154
	end -- 1154
	if play == nil then -- 1156
		ensurePlay() -- 1157
	end -- 1157
	if play == nil then -- 1159
		return -- 1160
	end -- 1160
	local p = play -- 1162
	p.aimX = input.mx -- 1163
	p.aimY = input.my -- 1164
	local zoneTap = input.touchZoneTap -- 1166
	input.touchZoneTap = "" -- 1167
	local trial = run and run.trial -- 1169
	if trial ~= nil then -- 1170
		local ended = trial.lost or (run and run.finished) == true -- 1171
		local pick = input.pickRoom -- 1172
		input.pickRoom = 0 -- 1173
		if zoneTap == "trial:resume" and p.paused and not ended then -- 1175
			p.paused = false -- 1176
			clock:reset() -- 1177
			input:consumeEdges() -- 1178
			drawCampaign(p) -- 1179
			return -- 1180
		end -- 1180
		if zoneTap == "trial:retry" then -- 1182
			input:consumeEdges() -- 1183
			startTrial() -- 1184
			return -- 1185
		end -- 1185
		if zoneTap == "trial:title" then -- 1187
			input:consumeEdges() -- 1188
			current = 0 -- 1189
			play = nil -- 1190
			run = nil -- 1191
			setMode(1) -- 1192
			if fe ~= nil then -- 1193
				fe.audio:stopRoomTransient() -- 1194
				fe.screen = "title" -- 1195
				fe.menus:resetInput() -- 1196
			end -- 1196
			return -- 1198
		end -- 1198
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1201
			input:consumeEdges() -- 1202
			current = 0 -- 1203
			play = nil -- 1204
			run = nil -- 1205
			setMode(1) -- 1206
			if fe ~= nil then -- 1207
				fe.audio:stopRoomTransient() -- 1208
				fe.screen = "title" -- 1209
				fe.menus:resetInput() -- 1210
			end -- 1210
			return -- 1212
		end -- 1212
		if ended or p.paused and input.retry.pressed then -- 1214
			local restart = input.retry.pressed or ended and input.navConfirm -- 1215
			input:consumeEdges() -- 1216
			if restart then -- 1217
				startTrial() -- 1217
			else -- 1217
				drawCampaign(p) -- 1218
			end -- 1218
			return -- 1219
		end -- 1219
		input.retry.pressed = false -- 1221
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1222
			if trialTalentSelected >= #trial.offers then -- 1223
				trialTalentSelected = 0 -- 1224
			end -- 1224
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1226
				local idx = __TS__ParseInt( -- 1227
					string.sub(zoneTap, 8), -- 1227
					10 -- 1227
				) -- 1227
				if idx >= 0 and idx < #trial.offers then -- 1228
					p:chooseTalent(idx) -- 1229
				end -- 1229
			elseif pick > 0 then -- 1231
				p:chooseTalent(pick - 1) -- 1232
			else -- 1232
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1234
				if delta ~= 0 then -- 1237
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1238
				end -- 1238
				if input.talentConfirm or input.navConfirm then -- 1240
					p:chooseTalent(trialTalentSelected) -- 1241
				end -- 1241
			end -- 1241
			input:consumeEdges() -- 1244
			clock:reset() -- 1245
			if fe ~= nil then -- 1246
				fe:syncTrialAudio(frameDt, p, #trial.offers) -- 1246
			end -- 1246
			drawCampaign(p) -- 1247
			return -- 1248
		end -- 1248
	end -- 1248
	if input.retry.pressed then -- 1252
		input.retry.pressed = false -- 1253
		input:consumeEdges() -- 1254
		play = nil -- 1256
		ensurePlay() -- 1257
		return -- 1258
	end -- 1258
	if input.pause.pressed or p.paused and input.navBack then -- 1260
		input.pause.pressed = false -- 1261
		p.paused = not p.paused -- 1262
		if fe ~= nil then -- 1263
			fe.audio:playUi(p.paused and "ui:pause_open" or "ui:pause_close", p.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 1263
		end -- 1263
		clock:reset() -- 1264
		input:consumeEdges() -- 1265
	end -- 1265
	if p.paused then -- 1267
		if fe ~= nil then -- 1268
			fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1268
		end -- 1268
		drawCampaign(p) -- 1269
		return -- 1270
	end -- 1270
	local steps = clock:advance(frameDt) -- 1273
	local i = 0 -- 1274
	do -- 1274
		i = 0 -- 1275
		while i < steps do -- 1275
			input:beginStep(i == 0) -- 1276
			p:update(STEP, input) -- 1277
			input:endStep() -- 1278
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1279
				break -- 1280
			end -- 1280
			i = i + 1 -- 1275
		end -- 1275
	end -- 1275
	if fe ~= nil then -- 1283
		fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1283
	end -- 1283
	if p.wantRoom ~= "" then -- 1285
		local key = p.wantRoom -- 1286
		p.wantRoom = "" -- 1287
		local idx = -1 -- 1288
		local j = 0 -- 1289
		do -- 1289
			j = 0 -- 1290
			while j < #CAMPAIGN_ROOMS do -- 1290
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1291
					idx = j -- 1292
				end -- 1292
				j = j + 1 -- 1290
			end -- 1290
		end -- 1290
		if idx >= 0 then -- 1295
			current = idx -- 1296
			play = nil -- 1297
			ensurePlay() -- 1298
		end -- 1298
		return -- 1300
	end -- 1300
	drawCampaign(p) -- 1302
end -- 1302
function goalLabel(goal) -- 1305
	if goal == "dock_cart" then -- 1306
		return "推车入窝并抬闩" -- 1307
	end -- 1307
	if goal == "raise_latch" then -- 1309
		return "抬闩开侧门" -- 1310
	end -- 1310
	return "到段出口" -- 1312
end -- 1312
function drawCampaign(p) -- 1315
	if campaignDraw == nil then -- 1316
		return -- 1317
	end -- 1317
	local w = stageVp.stageW -- 1319
	local h = stageVp.stageH -- 1320
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1321
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1322
	p:draw(campaignDraw, w, h) -- 1323
	local room = CAMPAIGN_ROOMS[current + 1] -- 1324
	local c = room.campaign -- 1325
	local r = run -- 1326
	local line = room.name -- 1327
	if c ~= nil then -- 1328
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget * 60) -- 1329
	end -- 1329
	if p.paused then -- 1332
		line = line .. "  · 已暂停 Esc 继续" -- 1333
	end -- 1333
	local trial = r and r.trial -- 1335
	if trial ~= nil and r ~= nil then -- 1336
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 1337
		if p.paused then -- 1338
			line = line .. " · 暂停" -- 1338
		elseif trial.lost then -- 1339
			line = line .. " · 护送失败" -- 1339
		elseif r.finished then -- 1340
			line = line .. " · 护送完成" -- 1340
		elseif #trial.offers > 0 then -- 1341
			line = line .. " · 选择本段本领" -- 1341
		elseif c ~= nil then -- 1342
			line = line .. " · " .. goalLabel(c.goal) -- 1342
		end -- 1342
	end -- 1342
	if campaignHud ~= nil then -- 1344
		campaignHud.text = line -- 1345
		campaignHud.position = Vec2(24 + safeL, h - 14 - safeT) -- 1346
		campaignHud.visible = true -- 1347
	end -- 1347
	if campaignSub ~= nil then -- 1349
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 1350
		if r ~= nil then -- 1351
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 1352
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 1353
		end -- 1353
		if p.flash ~= "" then -- 1358
			sub = (sub .. " · ") .. p.flash -- 1359
		end -- 1359
		if trial ~= nil and r ~= nil then -- 1361
			local gpMode = input ~= nil and input:isGamepadMode() -- 1362
			local touchMode = input ~= nil and input:isTouchMode() -- 1363
			if trial.lost or r.finished then -- 1364
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · A 再开一局 · START 返回标题" or (touchMode and " · 点下方按钮再开或返回标题" or " · R 再开一局 · Esc 返回标题")) -- 1365
			elseif p.paused then -- 1366
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · START 继续 · 长按BACK 重开 · Y 返回标题" or (touchMode and " · 点下方按钮继续/重开/返回标题" or " · Esc 继续 · R 重新开局 · E 返回标题")) -- 1367
			elseif #trial.offers > 0 then -- 1368
				sub = table.concat( -- 1369
					__TS__ArrayMap( -- 1369
						trial.offers, -- 1369
						function(____, talent, index) -- 1369
							local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1370
							return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1371
						end -- 1369
					), -- 1369
					"　" -- 1372
				) -- 1372
			else -- 1372
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 1374
			end -- 1374
		end -- 1374
		campaignSub.text = sub -- 1377
		campaignSub.position = Vec2(24 + safeL, h - 44 - safeT) -- 1378
		campaignSub.visible = true -- 1379
	end -- 1379
end -- 1379
function tickFrontend(frameDt) -- 1383
	if fe == nil or input == nil then -- 1384
		return -- 1385
	end -- 1385
	if fe.screen ~= "play" then -- 1389
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1390
		input:consumeEdges() -- 1391
		if act.type == "splashDone" then -- 1392
			fe.menus:resetInput() -- 1393
			fe.screen = "title" -- 1394
		elseif act.type == "trial" then -- 1395
			startTrial() -- 1396
		elseif act.type == "continue" then -- 1397
			if continueOfficialStory() == nil then -- 1398
				enterPlayRoom( -- 1399
					officialStartIndex(), -- 1399
					"official", -- 1399
					true -- 1399
				) -- 1399
			end -- 1399
		elseif act.type == "start" then -- 1401
			clearSession() -- 1403
			refreshTitleSessionFlag() -- 1404
			enterPlayRoom( -- 1405
				officialStartIndex(), -- 1405
				"official", -- 1405
				true -- 1405
			) -- 1405
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1406
			enterPlayRoom(act.roomIndex, "chapter", false, act.route) -- 1407
		elseif act.type == "openChapters" then -- 1408
			fe.menus:openChapters() -- 1409
			fe.screen = "chapters" -- 1410
		elseif act.type == "openControls" then -- 1411
			fe.menus:resetInput() -- 1412
			fe.screen = "controls" -- 1413
		elseif act.type == "openHistory" then -- 1414
			fe.menus:openHistory(true) -- 1415
			fe.screen = "history" -- 1416
		elseif act.type == "backEpilogue" then -- 1417
			fe.menus:resetInput() -- 1418
			fe.screen = "epilogue" -- 1419
		elseif act.type == "replayStory" then -- 1420
			clearSession() -- 1421
			refreshTitleSessionFlag() -- 1422
			enterPlayRoom( -- 1423
				officialStartIndex(), -- 1423
				"official", -- 1423
				true -- 1423
			) -- 1423
		elseif act.type == "backTitle" then -- 1424
			fe.menus:resetInput() -- 1425
			fe.screen = "title" -- 1426
		elseif act.type == "backPause" then -- 1427
			fe.menus:resetInput() -- 1428
			fe.screen = "play" -- 1429
		elseif act.type == "quit" then -- 1430
			quitGame() -- 1431
		end -- 1431
		return -- 1433
	end -- 1433
	if play == nil then -- 1437
		ensurePlay() -- 1438
	end -- 1438
	if play == nil then -- 1440
		return -- 1441
	end -- 1441
	local p = play -- 1443
	p.aimX = input.mx -- 1445
	p.aimY = input.my -- 1446
	local zoneTap = input.touchZoneTap -- 1448
	input.touchZoneTap = "" -- 1449
	local offers = p:getStoryTalentOffers() -- 1451
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1452
		if fe.hud.talentSelected >= #offers then -- 1453
			fe.hud.talentSelected = 0 -- 1454
		end -- 1454
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1456
			local idx = __TS__ParseInt( -- 1457
				string.sub(zoneTap, 8), -- 1457
				10 -- 1457
			) -- 1457
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1458
				input.fire.pressed = false -- 1459
			end -- 1459
		else -- 1459
			if input.talentDelta ~= 0 then -- 1462
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1463
				input.talentDelta = 0 -- 1464
			end -- 1464
			if input.talentConfirm then -- 1466
				p:chooseTalent(fe.hud.talentSelected) -- 1467
				input.talentConfirm = false -- 1468
				input.fire.pressed = false -- 1469
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1470
				input.fire.pressed = false -- 1472
			end -- 1472
		end -- 1472
	end -- 1472
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1478
		if input.navConfirm then -- 1479
			input.interact.pressed = true -- 1480
		end -- 1480
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1482
			flushProfile() -- 1483
			if p.run.source == "official" and hasSessionSave() then -- 1484
				clearSession() -- 1485
				refreshTitleSessionFlag() -- 1486
			end -- 1486
			fe.audio:stopRoomTransient() -- 1488
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1489
			fe.screen = "epilogue" -- 1493
			input:clearTransient(true) -- 1494
			input:consumeEdges() -- 1495
			return -- 1496
		end -- 1496
	end -- 1496
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1500
		p:closeCraftBench() -- 1501
		input:consumeEdges() -- 1502
		return -- 1503
	end -- 1503
	if not p.paused and input.pause.pressed then -- 1505
		p.paused = true -- 1506
		p.aimHold = 0 -- 1507
		p.bottleAimX = -1 -- 1508
		saveCurrentSession() -- 1509
		fe.menus:openPause() -- 1510
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1511
		input:clearTransient(true) -- 1512
		input:consumeEdges() -- 1513
	end -- 1513
	if p.paused then -- 1516
		clock:reset() -- 1518
		local pauseAct = fe:renderPlay( -- 1519
			frameDt, -- 1519
			p, -- 1519
			input, -- 1519
			stageVp.stageW, -- 1519
			stageVp.stageH -- 1519
		) -- 1519
		input:consumeEdges() -- 1520
		if pauseAct.type == "resume" then -- 1521
			p.paused = false -- 1522
		elseif pauseAct.type == "retry" then -- 1523
			ensurePlay({checkpoint = p.checkpoint}) -- 1524
		elseif pauseAct.type == "openChapters" then -- 1525
			fe.audio:stopRoomTransient() -- 1526
			fe.audio:setPaused(false) -- 1527
			fe.menus:openChapters(current) -- 1528
			fe.screen = "chapters" -- 1529
		elseif pauseAct.type == "toggleFullscreen" then -- 1530
			toggleFullscreen() -- 1531
		elseif pauseAct.type == "quit" then -- 1532
			quitGame() -- 1533
		elseif pauseAct.type == "toTitle" then -- 1534
			saveCurrentSession() -- 1535
			refreshTitleSessionFlag() -- 1536
			fe.menus:resetInput() -- 1537
			fe.screen = "title" -- 1538
		end -- 1538
		return -- 1540
	end -- 1540
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1543
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1544
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1546
		input:consumeEdges() -- 1547
		ensurePlay({checkpoint = p.checkpoint}) -- 1549
		return -- 1550
	end -- 1550
	local steps = clock:advance(frameDt) -- 1553
	local i = 0 -- 1554
	do -- 1554
		i = 0 -- 1555
		while i < steps do -- 1555
			input:beginStep(i == 0) -- 1556
			p:update(STEP, input) -- 1557
			input:endStep() -- 1558
			if p.wantRoom ~= "" then -- 1559
				break -- 1560
			end -- 1560
			i = i + 1 -- 1555
		end -- 1555
	end -- 1555
	if p.wantRoom ~= "" then -- 1565
		local key = p.wantRoom -- 1566
		p.wantRoom = "" -- 1567
		local idx = -1 -- 1568
		local j = 0 -- 1569
		do -- 1569
			j = 0 -- 1570
			while j < #ROOMS do -- 1570
				if ROOMS[j + 1].key == key then -- 1571
					idx = j -- 1572
				end -- 1572
				j = j + 1 -- 1570
			end -- 1570
		end -- 1570
		if idx >= 0 then -- 1575
			flushProfile() -- 1579
			local leaving = p:drainEvents() -- 1580
			if p.restartStory then -- 1582
				if storyRun ~= nil and storyRun.source == "official" then -- 1583
					clearSession() -- 1584
					refreshTitleSessionFlag() -- 1585
				end -- 1585
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1587
				storyRun = createRun(20261124, nextSource, profile) -- 1588
			end -- 1588
			current = idx -- 1590
			ensurePlay() -- 1591
			local fresh = play -- 1592
			if fresh ~= nil then -- 1593
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1594
					fresh.phase = "prologue-wake" -- 1595
				end -- 1595
				fresh:adoptEvents(leaving) -- 1597
			end -- 1597
			if not p.restartStory then -- 1599
				saveCurrentSession() -- 1600
			end -- 1600
			clock:reset() -- 1602
			dirty = true -- 1603
		end -- 1603
		return -- 1605
	end -- 1605
	flushProfile() -- 1609
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1610
		clearSession() -- 1611
		refreshTitleSessionFlag() -- 1612
	elseif p.sessionDirty then -- 1613
		saveCurrentSession() -- 1614
	end -- 1614
	fe:renderPlay( -- 1616
		frameDt, -- 1616
		p, -- 1616
		input, -- 1616
		stageVp.stageW, -- 1616
		stageVp.stageH -- 1616
	) -- 1616
end -- 1616
function redrawGraybox() -- 1620
	if draw == nil then -- 1621
		return -- 1622
	end -- 1622
	local w = viewW -- 1624
	local h = viewH -- 1625
	local room = ROOMS[current + 1] -- 1626
	draw:clear() -- 1628
	draw:drawRect( -- 1629
		Rect(0, h - TOP_H, w, TOP_H), -- 1629
		C_BG -- 1629
	) -- 1629
	draw:drawRect( -- 1630
		Rect(0, 0, w, BOTTOM_H), -- 1630
		C_BG -- 1630
	) -- 1630
	draw:drawSegment( -- 1631
		Vec2(0, h - TOP_H), -- 1631
		Vec2(w, h - TOP_H), -- 1631
		1, -- 1631
		Color(52, 54, 54, 255) -- 1631
	) -- 1631
	draw:drawSegment( -- 1632
		Vec2(0, BOTTOM_H), -- 1632
		Vec2(w, BOTTOM_H), -- 1632
		1, -- 1632
		Color(52, 54, 54, 255) -- 1632
	) -- 1632
	local v = computeView(room, w, h) -- 1634
	renderWorld( -- 1635
		draw, -- 1635
		room, -- 1635
		v, -- 1635
		w, -- 1635
		h -- 1635
	) -- 1635
	local roomTop = v.groundPx + room.height * v.scale -- 1637
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1638
	place( -- 1640
		titleLabel, -- 1640
		48, -- 1640
		h - 40, -- 1640
		0, -- 1640
		1 -- 1640
	) -- 1640
	place( -- 1641
		roomLabel, -- 1641
		48, -- 1641
		h - 96, -- 1641
		0, -- 1641
		1 -- 1641
	) -- 1641
	place( -- 1642
		captionLabel, -- 1642
		48, -- 1642
		h - 140, -- 1642
		0, -- 1642
		1 -- 1642
	) -- 1642
	place( -- 1644
		switchLabel, -- 1644
		48, -- 1644
		40, -- 1644
		0, -- 1644
		0 -- 1644
	) -- 1644
	place( -- 1645
		hintLabel, -- 1645
		48, -- 1645
		84, -- 1645
		0, -- 1645
		0 -- 1645
	) -- 1645
	place( -- 1646
		rulerLabel, -- 1646
		w - 216, -- 1646
		roomTop + 36 + v.scale * 0.5 - 14, -- 1646
		1, -- 1646
		0 -- 1646
	) -- 1646
	place( -- 1647
		standLabel, -- 1647
		48, -- 1647
		roomTop + 40, -- 1647
		0, -- 1647
		0 -- 1647
	) -- 1647
	place( -- 1648
		cartLabel, -- 1648
		48, -- 1648
		roomTop + 92, -- 1648
		0, -- 1648
		0 -- 1648
	) -- 1648
	if roomLabel ~= nil then -- 1650
		roomLabel.text = room.name -- 1651
	end -- 1651
	if captionLabel ~= nil then -- 1653
		captionLabel.text = room.caption -- 1654
	end -- 1654
	if hintLabel ~= nil then -- 1656
		local hintIdx = math.min(current, #HINTS - 1) -- 1657
		local lines = HINTS[hintIdx + 1] -- 1658
		local merged = lines[1] -- 1659
		do -- 1659
			local i = 1 -- 1660
			while i < #lines do -- 1660
				merged = (merged .. "    ") .. lines[i + 1] -- 1661
				i = i + 1 -- 1660
			end -- 1660
		end -- 1660
		hintLabel.text = merged -- 1663
	end -- 1663
	local specs = collectLabels(room, v, w) -- 1666
	local body = {} -- 1667
	local small = {} -- 1668
	do -- 1668
		local i = 0 -- 1669
		while i < #specs do -- 1669
			local s = specs[i + 1] -- 1670
			if s.size >= 24 then -- 1671
				body[#body + 1] = s -- 1672
			else -- 1672
				small[#small + 1] = s -- 1674
			end -- 1674
			i = i + 1 -- 1669
		end -- 1669
	end -- 1669
	applyPool(body, poolBody) -- 1677
	applyPool(small, poolSmall) -- 1678
	if LAYOUT_AUDIT then -- 1680
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1681
	end -- 1681
end -- 1681
function applyPool(specs, pool) -- 1685
	do -- 1685
		local i = 0 -- 1686
		while i < #pool do -- 1686
			local lb = pool[i + 1] -- 1687
			if i < #specs then -- 1688
				local s = specs[i + 1] -- 1689
				lb.text = s.text -- 1690
				lb.position = Vec2(s.x, s.y) -- 1691
				lb.anchor = Vec2(s.ax, s.ay) -- 1692
				lb.color = s.color -- 1693
				lb.visible = true -- 1694
			else -- 1694
				lb.visible = false -- 1696
			end -- 1696
			i = i + 1 -- 1686
		end -- 1686
	end -- 1686
end -- 1686
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
local function makeGrayboxLabel(text, size, color) -- 385
	if grayboxLayer == nil then -- 386
		return nil -- 387
	end -- 387
	local lb = Label(FONT, size) -- 389
	if lb == nil then -- 390
		return nil -- 391
	end -- 391
	lb.text = text -- 393
	lb.color = color -- 394
	lb:addTo(grayboxLayer) -- 395
	lb.visible = true -- 396
	return lb -- 397
end -- 385
function ____exports.start(parent, initialMode, startScreen) -- 409
	if initialMode == nil then -- 409
		initialMode = 1 -- 409
	end -- 409
	if startScreen == nil then -- 409
		startScreen = "title" -- 409
	end -- 409
	root = parent -- 410
	mode = initialMode -- 411
	grayboxLayer = Node() -- 414
	grayboxLayer.order = 2 -- 415
	grayboxLayer:addTo(parent) -- 416
	draw = DrawNode() -- 418
	draw:addTo(grayboxLayer) -- 419
	campaignLayer = Node() -- 422
	campaignLayer.order = 3 -- 423
	campaignLayer:addTo(parent) -- 424
	campaignDraw = DrawNode() -- 425
	campaignDraw:addTo(campaignLayer) -- 426
	campaignHud = Label(FONT, 24) -- 427
	if campaignHud ~= nil then -- 428
		campaignHud.color = C_TEXT -- 429
		campaignHud.anchor = Vec2(0, 1) -- 430
		campaignHud:addTo(campaignLayer) -- 431
		campaignHud.visible = true -- 432
	end -- 432
	campaignSub = Label(FONT, 20) -- 434
	if campaignSub ~= nil then -- 435
		campaignSub.color = C_ACCENT -- 436
		campaignSub.anchor = Vec2(0, 1) -- 437
		campaignSub:addTo(campaignLayer) -- 438
		campaignSub.visible = true -- 439
	end -- 439
	campaignLayer.visible = mode == 2 -- 441
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 443
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 444
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 445
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 446
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 447
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 448
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 449
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 450
	do -- 450
		local i = 0 -- 452
		while i < POOL_BODY do -- 452
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 453
			if lb ~= nil then -- 454
				poolBody[#poolBody + 1] = lb -- 455
			end -- 455
			i = i + 1 -- 452
		end -- 452
	end -- 452
	do -- 452
		local i = 0 -- 458
		while i < POOL_SMALL do -- 458
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 459
			if lb ~= nil then -- 460
				poolSmall[#poolSmall + 1] = lb -- 461
			end -- 461
			i = i + 1 -- 458
		end -- 458
	end -- 458
	if mode == 1 then -- 467
		local loaded = loadSave() -- 468
		profile = loaded.state -- 469
		profileStatus = loaded.status -- 470
		profileDetail = loaded.detail -- 471
	end -- 471
	fe = __TS__New(WatchFrontend, parent) -- 473
	fe.screen = startScreen -- 474
	if startScreen == "splash" then -- 475
		fe.menus:resetSplash() -- 476
	end -- 476
	refreshTitleSessionFlag() -- 478
	grayboxLayer.visible = mode == 0 -- 479
	fe:setVisible(mode == 1) -- 480
	if campaignLayer ~= nil then -- 481
		campaignLayer.visible = mode == 2 -- 482
	end -- 482
	input = __TS__New(Input) -- 485
	fe.audio:applyUserVolumes(input.settings) -- 486
	touchRouter = __TS__New(TouchRouter, input.settings) -- 487
	touchRouter:attach(parent) -- 488
	input:bindTouch(touchRouter) -- 489
	gamepadRouter = __TS__New(GamepadRouter, input.settings) -- 491
	gamepadRouter:attach(parent) -- 492
	input:bindGamepad(gamepadRouter) -- 493
	touchControls = __TS__New(TouchControls, parent) -- 495
	parent:gslot( -- 498
		"AppEvent", -- 498
		function(eventType) -- 498
			if eventType == "BackButton" then -- 499
				handleBackButton() -- 500
				return -- 501
			end -- 501
			if eventType == "Quit" or eventType == "Shutdown" then -- 503
				flushProfile() -- 504
				saveCurrentSession() -- 505
				if input ~= nil then -- 506
					input:clearTransient(false) -- 506
				end -- 506
				return -- 507
			end -- 507
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 509
				flushProfile() -- 510
				saveCurrentSession() -- 511
				if input ~= nil then -- 512
					input:clearTransient(true) -- 512
				end -- 512
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 513
					play.paused = true -- 514
					play.aimHold = 0 -- 515
					play.bottleAimX = -1 -- 516
					fe.menus:openPause() -- 517
				elseif mode == 2 and play ~= nil and not play.paused then -- 518
					play.paused = true -- 519
				end -- 519
				if fe ~= nil then -- 521
					fe.audio:setPaused(true) -- 522
				end -- 522
				return -- 524
			end -- 524
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 526
				if fe ~= nil then -- 527
					local paused = play ~= nil and play.paused and (mode == 1 and fe.screen == "play" or mode == 2) -- 528
					fe.audio:setPaused(paused) -- 530
				end -- 530
			end -- 530
		end -- 498
	) -- 498
	parent:onKeyDown(function(key) -- 536
		onFirstUserGesture() -- 537
		if input ~= nil then -- 538
			input:markKeyboardActivity() -- 538
		end -- 538
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 539
			toggleFullscreen() -- 541
			return -- 542
		end -- 542
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 544
			play:toggleArtifactWeapon() -- 545
			return -- 546
		end -- 546
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and #play:getStoryTalentOffers() > 0 then -- 548
			if key == "1" then -- 550
				play:chooseTalent(0) -- 551
				if input ~= nil then -- 552
					input:consumePickRoom() -- 552
				end -- 552
				return -- 553
			end -- 553
			if key == "2" then -- 555
				play:chooseTalent(1) -- 556
				if input ~= nil then -- 557
					input:consumePickRoom() -- 557
				end -- 557
				return -- 558
			end -- 558
			if key == "3" then -- 560
				play:chooseTalent(2) -- 561
				if input ~= nil then -- 562
					input:consumePickRoom() -- 562
				end -- 562
				return -- 563
			end -- 563
		end -- 563
		local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 566
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 567
			fe.menus:onKeyEvent(key) -- 568
		end -- 568
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay or mode == 2) then -- 570
			if key == "E" then -- 571
				input.interact.pressed = true -- 572
			elseif key == "Space" then -- 573
				input.jump.pressed = true -- 574
			elseif key == "Escape" then -- 575
				input.pause.pressed = true -- 576
			elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 577
				input.retry.pressed = true -- 578
			end -- 578
		end -- 578
		if mode == 2 and (run and run.trial) ~= nil then -- 581
			return -- 581
		end -- 581
		if isReleaseBuild() then -- 582
			return -- 582
		end -- 582
		if key == "F1" then -- 583
			if mode == 2 then -- 584
				current = 0 -- 585
				play = nil -- 586
				ensurePlay() -- 587
			else -- 587
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 589
			end -- 589
		elseif key == "F2" then -- 591
			setMode(0) -- 592
		elseif key == "1" then -- 593
			pickByIndex(0) -- 594
		elseif key == "2" then -- 595
			pickByIndex(1) -- 596
		elseif key == "3" then -- 597
			pickByIndex(2) -- 598
		elseif key == "4" then -- 599
			pickByIndex(3) -- 600
		elseif key == "5" then -- 601
			pickByIndex(4) -- 602
		elseif key == "6" then -- 603
			pickByIndex(5) -- 604
		elseif key == "7" then -- 605
			pickByIndex(6) -- 606
		elseif key == "8" then -- 607
			pickByIndex(7) -- 608
		end -- 608
	end) -- 536
	viewW = View.size.width -- 612
	viewH = View.size.height -- 613
	applySize() -- 614
	local reg = _G.package.loaded -- 617
	reg["watch.input"] = input -- 618
	reg["watch.touch"] = touchRouter -- 619
	reg["watch.gamepad"] = gamepadRouter -- 620
	reg["watch.fe"] = { -- 621
		setScreen = function(sc) -- 622
			if fe == nil then -- 623
				return -- 624
			end -- 624
			setMode(1) -- 626
			fe.screen = sc -- 627
			if sc == "splash" then -- 628
				fe.menus:resetSplash() -- 629
			elseif sc == "chapters" then -- 630
				fe.menus:openChapters() -- 631
			elseif sc == "epilogue" then -- 632
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 633
			elseif sc == "history" then -- 637
				fe.menus:openHistory(false) -- 638
			else -- 638
				fe.menus:resetInput() -- 640
			end -- 640
			if sc == "play" then -- 642
				ensurePlay() -- 643
			end -- 643
		end, -- 622
		jumpRoom = function(keyOrIdx) -- 646
			local idx = -1 -- 647
			if type(keyOrIdx) == "number" then -- 648
				idx = keyOrIdx -- 649
			else -- 649
				local k = 0 -- 651
				do -- 651
					k = 0 -- 652
					while k < #ROOMS do -- 652
						if ROOMS[k + 1].key == keyOrIdx then -- 653
							idx = k -- 654
						end -- 654
						k = k + 1 -- 652
					end -- 652
				end -- 652
			end -- 652
			if idx >= 0 and idx < #ROOMS then -- 658
				enterPlayRoom(idx, "debug") -- 659
			end -- 659
		end, -- 646
		getPlay = function() return play end, -- 662
		getFrontend = function() return fe end, -- 663
		startStory = function() -- 665
			enterPlayRoom( -- 666
				officialStartIndex(), -- 666
				"official", -- 666
				true -- 666
			) -- 666
			return play -- 667
		end, -- 665
		previewChapter = function(idx, route) -- 670
			enterPlayRoom(idx, "chapter", false, route) -- 671
			return play -- 672
		end, -- 670
		getStoryRun = function() return storyRun end, -- 674
		getProfilePending = function() return profilePending() end, -- 675
		flushProfileNow = function() return flushProfile() end, -- 676
		getProfile = function() return profile end, -- 678
		getProfileStatus = function() return profileStatus end, -- 679
		getProfileDetail = function() return profileDetail end, -- 680
		useTestSave = function(name) -- 681
			setSaveFile(name) -- 682
			setSessionFile(name == "" and "" or name .. ".session") -- 683
			clearProfilePending() -- 684
			local loaded = loadSave() -- 685
			profile = loaded.state -- 686
			profileStatus = loaded.status -- 687
			profileDetail = loaded.detail -- 688
			refreshTitleSessionFlag() -- 689
		end, -- 681
		useTestSession = function(name) -- 691
			setSessionFile(name) -- 692
			refreshTitleSessionFlag() -- 693
		end, -- 691
		getSessionFile = getSessionFile, -- 695
		hasSessionSave = hasSessionSave, -- 696
		saveSessionNow = function() return saveCurrentSession() end, -- 697
		clearSessionNow = function() -- 698
			local ok = clearSession() -- 699
			refreshTitleSessionFlag() -- 700
			return ok -- 701
		end, -- 698
		continueStory = function() return continueOfficialStory() end, -- 703
		saveNow = function() return saveSave(profile) end, -- 704
		getSaveFile = getSaveFile, -- 705
		isRelease = function() return isReleaseBuild() end, -- 706
		getReleaseVersion = function() -- 707
			local ____opt_32 = getReleaseConfig() -- 707
			return ____opt_32 and ____opt_32.version or "dev" -- 707
		end, -- 707
		toggleFullscreen = function() return toggleFullscreen() end, -- 708
		quitGame = function() return quitGame() end, -- 709
		startTrial = function() return startTrial() end, -- 710
		handleBackButton = function() return handleBackButton() end, -- 711
		getViewport = function() return stageVp end, -- 712
		getTouchController = function() return touchControls end, -- 713
		getTouchRouter = function() return touchRouter end, -- 714
		getGamepad = function() return gamepadRouter end, -- 715
		setGamepadSim = function(state) -- 716
			if gamepadRouter ~= nil then -- 717
				gamepadRouter:setSimulatedState(state) -- 717
			end -- 717
		end, -- 716
		injectTouch = function(phase, id, x, y, fromMouse) -- 719
			if touchRouter ~= nil then -- 720
				touchRouter:injectTouch( -- 720
					phase, -- 720
					id, -- 720
					x, -- 720
					y, -- 720
					fromMouse -- 720
				) -- 720
			end -- 720
		end, -- 719
		getInputMode = function() return input and input.inputMode or "kbm" end, -- 722
		setInputMode = function(m) -- 723
			if input ~= nil then -- 724
				input:setInputMode(m) -- 724
			end -- 724
		end, -- 723
		setModePref = function(pref) -- 726
			if input ~= nil then -- 727
				input:setModePref(pref) -- 727
			end -- 727
		end, -- 726
		applyViewportForTest = function(w, h) -- 729
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 730
				testViewportOverride = {w = w, h = h} -- 731
				viewW = w -- 732
				viewH = h -- 733
			else -- 733
				testViewportOverride = nil -- 735
				viewW = View.size.width -- 736
				viewH = View.size.height -- 737
			end -- 737
			applySize() -- 739
			dirty = true -- 740
			return stageVp -- 741
		end, -- 729
		getToast = function() return fe and fe:getToastText() or "" end -- 743
	} -- 743
	if mode == 1 and startScreen == "play" then -- 746
		ensurePlay() -- 747
	end -- 747
	parent:schedule(function(frameDt) -- 750
		tick(frameDt) -- 751
		return false -- 752
	end) -- 750
end -- 409
return ____exports -- 409
