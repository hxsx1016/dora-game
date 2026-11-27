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
function setMode(nextMode) -- 724
	mode = nextMode -- 725
	if grayboxLayer ~= nil then -- 726
		grayboxLayer.visible = mode == 0 -- 727
	end -- 727
	if fe ~= nil then -- 729
		fe:setVisible(mode == 1) -- 730
	end -- 730
	if campaignLayer ~= nil then -- 732
		campaignLayer.visible = mode == 2 -- 733
	end -- 733
	dirty = true -- 735
	clock:reset() -- 736
end -- 736
function flushProfile() -- 743
	local cur = play -- 744
	if cur ~= nil and cur.archiveDirty then -- 745
		cur.archiveDirty = false -- 746
		markProfilePending(profile) -- 747
	end -- 747
	local ok = flushSaveProfile() -- 749
	if not ok and cur ~= nil then -- 750
		cur.archiveDirty = true -- 751
	end -- 751
	return ok -- 753
end -- 753
function officialStartIndex() -- 757
	local mp = profile.museumPhase -- 758
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 759
	return inMuseum and roomIndexByKey("museum") or 0 -- 760
end -- 760
function roomIndexByKey(key) -- 763
	local i = 0 -- 764
	do -- 764
		i = 0 -- 765
		while i < #ROOMS do -- 765
			if ROOMS[i + 1].key == key then -- 766
				return i -- 767
			end -- 767
			i = i + 1 -- 765
		end -- 765
	end -- 765
	return 0 -- 770
end -- 770
function enterPlayRoom(idx, source, fresh) -- 773
	if source == nil then -- 773
		source = "debug" -- 773
	end -- 773
	if fresh == nil then -- 773
		fresh = false -- 773
	end -- 773
	current = idx -- 774
	setMode(1) -- 775
	if fe ~= nil then -- 776
		fe.screen = "play" -- 777
	end -- 777
	play = nil -- 779
	if fresh or source == "chapter" or storyRun == nil then -- 781
		storyRun = createRun(20261124, source, profile) -- 782
	else -- 782
		storyRun.source = source -- 784
	end -- 784
	ensurePlay() -- 786
	local firstPlay = play -- 788
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 789
		firstPlay.phase = "prologue-wake" -- 790
	end -- 790
	flushProfile() -- 792
end -- 792
function pickByIndex(idx, source) -- 795
	if source == nil then -- 795
		source = "debug" -- 795
	end -- 795
	if mode == 2 then -- 796
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 797
			return -- 798
		end -- 798
		current = idx -- 800
		play = nil -- 801
		clock:reset() -- 802
		ensurePlay() -- 803
		return -- 804
	end -- 804
	if idx < 0 or idx >= #ROOMS then -- 806
		return -- 807
	end -- 807
	flushProfile() -- 809
	if storyRun ~= nil then -- 810
		storyRun.source = source -- 811
	end -- 811
	current = idx -- 813
	dirty = true -- 814
	play = nil -- 815
	clock:reset() -- 816
	if mode == 1 then -- 817
		if fe ~= nil then -- 818
			fe.screen = "play" -- 819
		end -- 819
		ensurePlay() -- 821
	end -- 821
end -- 821
function applySize() -- 825
	if root == nil then -- 826
		return -- 827
	end -- 827
	root.size = Size(viewW, viewH) -- 829
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 830
	stageVp = computeStageViewport(viewW, viewH) -- 831
	if input ~= nil then -- 832
		input:setStageViewport(stageVp) -- 833
	end -- 833
	if fe ~= nil then -- 835
		fe:setStagePlacement(stageVp) -- 836
	end -- 836
	if campaignLayer ~= nil then -- 838
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 839
	end -- 839
	if grayboxLayer ~= nil then -- 841
		grayboxLayer.position = Vec2(0, 0) -- 842
	end -- 842
end -- 842
function syncFrameAdapters(frameDt) -- 846
	if input == nil then -- 847
		return -- 848
	end -- 848
	local p = play -- 850
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 851
	local isTrialMode = mode == 2 and p ~= nil -- 852
	local gameplayActive = isPlayMode or isTrialMode -- 853
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 855
		p, -- 857
		stageVp.stageW, -- 857
		stageVp.stageH, -- 857
		input:isTouchMode() -- 857
	) or ({}) -- 858
	if touchControls ~= nil and touchRouter ~= nil then -- 860
		local isFs = false -- 861
		if canToggleFullscreen() then -- 862
			do -- 862
				local function ____catch() -- 862
					isFs = false -- 866
				end -- 866
				local ____try = pcall(function() -- 866
					isFs = App.fullScreen -- 864
				end) -- 864
				if not ____try then -- 864
					____catch() -- 864
				end -- 864
			end -- 864
		end -- 864
		local ____touchControls_53 = touchControls -- 869
		local ____touchControls_syncContext_54 = touchControls.syncContext -- 869
		local ____stageVp_46 = stageVp -- 870
		local ____mode_47 = mode -- 871
		local ____temp_48 = fe ~= nil and fe.screen or "title" -- 872
		local ____run_49 = run -- 874
		local ____temp_50 = fe ~= nil and fe.cam or nil -- 875
		local ____input_51 = input -- 876
		local ____touchRouter_52 = touchRouter -- 877
		local ____temp_44 -- 878
		if fe ~= nil then -- 878
			____temp_44 = fe.contract:isAssistHintsEnabled() -- 878
		else -- 878
			____temp_44 = false -- 878
		end -- 878
		local ____temp_45 -- 879
		if fe ~= nil then -- 879
			____temp_45 = fe.audio:isAllMuted() -- 879
		else -- 879
			____temp_45 = false -- 879
		end -- 879
		____touchControls_syncContext_54(____touchControls_53, { -- 869
			viewport = ____stageVp_46, -- 870
			mode = ____mode_47, -- 871
			screen = ____temp_48, -- 872
			play = p, -- 873
			run = ____run_49, -- 874
			cam = ____temp_50, -- 875
			input = ____input_51, -- 876
			router = ____touchRouter_52, -- 877
			assistHintsEnabled = ____temp_44, -- 878
			isMuted = ____temp_45, -- 879
			isFullscreen = isFs, -- 880
			storyTalentBoxes = storyTalentBoxes, -- 881
			dt = frameDt -- 882
		}) -- 882
	end -- 882
	if gamepadRouter ~= nil then -- 886
		local trial = run and run.trial -- 887
		local trialEnded = isTrialMode and trial ~= nil and (trial.lost or (run and run.finished) == true) -- 888
		local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 889
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 890
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 893
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 894
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 895
		local ____temp_59 -- 898
		if isPlayMode and p ~= nil then -- 898
			____temp_59 = isCutsceneBlockingPlay(p) -- 898
		else -- 898
			____temp_59 = false -- 898
		end -- 898
		local cutsceneBlocking = ____temp_59 -- 898
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 899
		local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 901
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 902
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 904
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 906
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 909
		local playerScreenX = stageVp.stageW * 0.5 -- 911
		local playerScreenY = stageVp.stageH * 0.38 -- 912
		if p ~= nil then -- 913
			if isPlayMode and fe ~= nil then -- 914
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 915
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 916
			else -- 916
				local vz = p.view.zoom > 0 and p.view.zoom or 1 -- 919
				playerScreenX = stageVp.stageW * 0.5 + (p.player.x + p.player.facing * 8 - p.cam.x) * vz -- 920
				playerScreenY = stageVp.stageH * 0.5 + (p.player.y + p.player.h * 0.72 + p.player.depth * DEPTH_Y_SCALE - p.cam.y) * vz -- 921
			end -- 921
		end -- 921
		local enemyTargets = canShoot and p ~= nil and (isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or collectTrialAimTargets(p, stageVp.stageW, stageVp.stageH)) or ({}) -- 925
		local gpCtx = { -- 931
			stageW = stageVp.stageW, -- 932
			stageH = stageVp.stageH, -- 933
			uiScale = stageVp.uiScale, -- 934
			modal = modal, -- 935
			gameplayActive = gameplayActive, -- 936
			reloadActive = reloadActive, -- 937
			craftActive = craftActive, -- 938
			talentOfferCount = talentOfferCount, -- 939
			childMode = p ~= nil and p.childMode, -- 940
			allowDepth = allowDepth, -- 941
			canShoot = canShoot, -- 942
			canBottleAim = canBottleAim, -- 943
			playerRolling = p ~= nil and p.player.rollT > 0, -- 944
			inLowArch = inLowArch, -- 945
			inTowerEnd = inTowerEnd, -- 946
			playerFacing = p ~= nil and p.player.facing or 1, -- 947
			playerScreenX = playerScreenX, -- 948
			playerScreenY = playerScreenY, -- 949
			enemyTargets = enemyTargets -- 950
		} -- 950
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 952
	end -- 952
end -- 952
function renderTouchOverlay() -- 956
	if touchControls ~= nil and touchRouter ~= nil then -- 957
		touchControls:render(touchRouter) -- 958
	end -- 958
end -- 958
function tick(frameDt) -- 962
	appClock = appClock + math.min( -- 963
		0.05, -- 963
		math.max(0, frameDt) -- 963
	) -- 963
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 964
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 965
	if w ~= viewW or h ~= viewH then -- 966
		viewW = w -- 967
		viewH = h -- 968
		applySize() -- 969
		dirty = true -- 970
	end -- 970
	if input == nil then -- 972
		return -- 973
	end -- 973
	syncFrameAdapters(frameDt) -- 975
	input:update() -- 976
	if input.userInteracted then -- 978
		onFirstUserGesture() -- 979
	end -- 979
	if input.muteTogglePressed and fe ~= nil then -- 981
		input.muteTogglePressed = false -- 982
		fe.audio:toggleAllMuted() -- 983
	end -- 983
	if input.fullscreenTogglePressed then -- 985
		input.fullscreenTogglePressed = false -- 986
		toggleFullscreen() -- 987
	end -- 987
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 989
		input.artifactTogglePressed = false -- 990
		play:toggleArtifactWeapon() -- 991
	end -- 991
	if input.bottleCanceled and play ~= nil then -- 993
		input.bottleCanceled = false -- 994
		play.aimHold = 0 -- 995
		play.bottleAimX = -1 -- 996
	end -- 996
	if mode == 2 and (run and run.trial) ~= nil then -- 999
		tickCampaign(frameDt) -- 1000
		renderTouchOverlay() -- 1001
		return -- 1002
	end -- 1002
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 1005
		play:chooseTalent(input.pickRoom - 1) -- 1008
		input.pickRoom = 0 -- 1009
	end -- 1009
	if isReleaseBuild() then -- 1012
		input.toggleView.pressed = false -- 1013
		input.pickRoom = 0 -- 1014
		input.tab.pressed = false -- 1015
	else -- 1015
		if input.toggleView.pressed then -- 1018
			input.toggleView.pressed = false -- 1019
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 1020
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 1021
				ensurePlay() -- 1022
			end -- 1022
		end -- 1022
		if input.pickRoom ~= 0 then -- 1027
			local idx = input.pickRoom - 1 -- 1028
			input.pickRoom = 0 -- 1029
			pickByIndex(idx) -- 1030
		elseif input.tab.pressed then -- 1031
			input.tab.pressed = false -- 1032
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 1033
				pickByIndex((current + 1) % #ROOMS) -- 1034
			end -- 1034
		end -- 1034
	end -- 1034
	if mode == 2 then -- 1039
		tickCampaign(frameDt) -- 1040
	elseif mode == 1 then -- 1041
		tickFrontend(frameDt) -- 1042
	elseif dirty then -- 1043
		redrawGraybox() -- 1044
		dirty = false -- 1045
	end -- 1045
	renderTouchOverlay() -- 1047
end -- 1047
function registerPlay() -- 1051
	local reg = _G.package.loaded -- 1052
	reg["watch.play"] = play -- 1053
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 1054
	reg["watch.room"] = rooms[current + 1].key -- 1055
end -- 1055
function ensurePlay(resume) -- 1059
	if mode == 2 then -- 1060
		if run == nil then -- 1061
			run = createRun() -- 1062
		end -- 1062
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 1064
	else -- 1064
		if storyRun == nil then -- 1068
			storyRun = createRun(20261124, "debug", profile) -- 1069
		end -- 1069
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1071
	end -- 1071
	registerPlay() -- 1073
	clock:reset() -- 1074
	if fe ~= nil and mode == 1 then -- 1075
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1076
	end -- 1076
end -- 1076
function startTrial() -- 1080
	current = 0 -- 1081
	trialTalentSelected = 0 -- 1082
	run = createTrial(App.rand) -- 1083
	setMode(2) -- 1084
	ensurePlay() -- 1085
end -- 1085
function tickCampaign(frameDt) -- 1088
	if input == nil then -- 1089
		return -- 1090
	end -- 1090
	if play == nil then -- 1092
		ensurePlay() -- 1093
	end -- 1093
	if play == nil then -- 1095
		return -- 1096
	end -- 1096
	local p = play -- 1098
	p.aimX = input.mx -- 1099
	p.aimY = input.my -- 1100
	local zoneTap = input.touchZoneTap -- 1102
	input.touchZoneTap = "" -- 1103
	local trial = run and run.trial -- 1105
	if trial ~= nil then -- 1106
		local ended = trial.lost or (run and run.finished) == true -- 1107
		local pick = input.pickRoom -- 1108
		input.pickRoom = 0 -- 1109
		if zoneTap == "trial:resume" and p.paused and not ended then -- 1111
			p.paused = false -- 1112
			clock:reset() -- 1113
			input:consumeEdges() -- 1114
			drawCampaign(p) -- 1115
			return -- 1116
		end -- 1116
		if zoneTap == "trial:retry" then -- 1118
			input:consumeEdges() -- 1119
			startTrial() -- 1120
			return -- 1121
		end -- 1121
		if zoneTap == "trial:title" then -- 1123
			input:consumeEdges() -- 1124
			current = 0 -- 1125
			play = nil -- 1126
			run = nil -- 1127
			setMode(1) -- 1128
			if fe ~= nil then -- 1129
				fe.screen = "title" -- 1130
				fe.menus:resetInput() -- 1131
			end -- 1131
			return -- 1133
		end -- 1133
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1136
			input:consumeEdges() -- 1137
			current = 0 -- 1138
			play = nil -- 1139
			run = nil -- 1140
			setMode(1) -- 1141
			if fe ~= nil then -- 1142
				fe.screen = "title" -- 1143
				fe.menus:resetInput() -- 1144
			end -- 1144
			return -- 1146
		end -- 1146
		if ended or p.paused and input.retry.pressed then -- 1148
			local restart = input.retry.pressed or ended and input.navConfirm -- 1149
			input:consumeEdges() -- 1150
			if restart then -- 1151
				startTrial() -- 1151
			else -- 1151
				drawCampaign(p) -- 1152
			end -- 1152
			return -- 1153
		end -- 1153
		input.retry.pressed = false -- 1155
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1156
			if trialTalentSelected >= #trial.offers then -- 1157
				trialTalentSelected = 0 -- 1158
			end -- 1158
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1160
				local idx = __TS__ParseInt( -- 1161
					string.sub(zoneTap, 8), -- 1161
					10 -- 1161
				) -- 1161
				if idx >= 0 and idx < #trial.offers then -- 1162
					p:chooseTalent(idx) -- 1163
				end -- 1163
			elseif pick > 0 then -- 1165
				p:chooseTalent(pick - 1) -- 1166
			else -- 1166
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1168
				if delta ~= 0 then -- 1171
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1172
				end -- 1172
				if input.talentConfirm or input.navConfirm then -- 1174
					p:chooseTalent(trialTalentSelected) -- 1175
				end -- 1175
			end -- 1175
			input:consumeEdges() -- 1178
			clock:reset() -- 1179
			drawCampaign(p) -- 1180
			return -- 1181
		end -- 1181
	end -- 1181
	if input.retry.pressed then -- 1185
		input.retry.pressed = false -- 1186
		input:consumeEdges() -- 1187
		play = nil -- 1189
		ensurePlay() -- 1190
		return -- 1191
	end -- 1191
	if input.pause.pressed or p.paused and input.navBack then -- 1193
		input.pause.pressed = false -- 1194
		p.paused = not p.paused -- 1195
		clock:reset() -- 1196
		input:consumeEdges() -- 1197
	end -- 1197
	if p.paused then -- 1199
		drawCampaign(p) -- 1200
		return -- 1201
	end -- 1201
	local steps = clock:advance(frameDt) -- 1204
	local i = 0 -- 1205
	do -- 1205
		i = 0 -- 1206
		while i < steps do -- 1206
			input:beginStep(i == 0) -- 1207
			p:update(STEP, input) -- 1208
			input:endStep() -- 1209
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1210
				break -- 1211
			end -- 1211
			i = i + 1 -- 1206
		end -- 1206
	end -- 1206
	if p.wantRoom ~= "" then -- 1215
		local key = p.wantRoom -- 1216
		p.wantRoom = "" -- 1217
		local idx = -1 -- 1218
		local j = 0 -- 1219
		do -- 1219
			j = 0 -- 1220
			while j < #CAMPAIGN_ROOMS do -- 1220
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1221
					idx = j -- 1222
				end -- 1222
				j = j + 1 -- 1220
			end -- 1220
		end -- 1220
		if idx >= 0 then -- 1225
			current = idx -- 1226
			play = nil -- 1227
			ensurePlay() -- 1228
		end -- 1228
		return -- 1230
	end -- 1230
	drawCampaign(p) -- 1232
end -- 1232
function goalLabel(goal) -- 1235
	if goal == "dock_cart" then -- 1236
		return "推车入窝并抬闩" -- 1237
	end -- 1237
	if goal == "raise_latch" then -- 1239
		return "抬闩开侧门" -- 1240
	end -- 1240
	return "到段出口" -- 1242
end -- 1242
function drawCampaign(p) -- 1245
	if campaignDraw == nil then -- 1246
		return -- 1247
	end -- 1247
	local w = stageVp.stageW -- 1249
	local h = stageVp.stageH -- 1250
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1251
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1252
	p:draw(campaignDraw, w, h) -- 1253
	local room = CAMPAIGN_ROOMS[current + 1] -- 1254
	local c = room.campaign -- 1255
	local r = run -- 1256
	local line = room.name -- 1257
	if c ~= nil then -- 1258
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget * 60) -- 1259
	end -- 1259
	if p.paused then -- 1262
		line = line .. "  · 已暂停 Esc 继续" -- 1263
	end -- 1263
	local trial = r and r.trial -- 1265
	if trial ~= nil and r ~= nil then -- 1266
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 1267
		if p.paused then -- 1268
			line = line .. " · 暂停" -- 1268
		elseif trial.lost then -- 1269
			line = line .. " · 护送失败" -- 1269
		elseif r.finished then -- 1270
			line = line .. " · 护送完成" -- 1270
		elseif #trial.offers > 0 then -- 1271
			line = line .. " · 选择本段本领" -- 1271
		elseif c ~= nil then -- 1272
			line = line .. " · " .. goalLabel(c.goal) -- 1272
		end -- 1272
	end -- 1272
	if campaignHud ~= nil then -- 1274
		campaignHud.text = line -- 1275
		campaignHud.position = Vec2(24 + safeL, h - 14 - safeT) -- 1276
		campaignHud.visible = true -- 1277
	end -- 1277
	if campaignSub ~= nil then -- 1279
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 1280
		if r ~= nil then -- 1281
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 1282
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 1283
		end -- 1283
		if p.flash ~= "" then -- 1288
			sub = (sub .. " · ") .. p.flash -- 1289
		end -- 1289
		if trial ~= nil and r ~= nil then -- 1291
			local gpMode = input ~= nil and input:isGamepadMode() -- 1292
			local touchMode = input ~= nil and input:isTouchMode() -- 1293
			if trial.lost or r.finished then -- 1294
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · A 再开一局 · START 返回标题" or (touchMode and " · 点下方按钮再开或返回标题" or " · R 再开一局 · Esc 返回标题")) -- 1295
			elseif p.paused then -- 1296
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · START 继续 · 长按BACK 重开 · Y 返回标题" or (touchMode and " · 点下方按钮继续/重开/返回标题" or " · Esc 继续 · R 重新开局 · E 返回标题")) -- 1297
			elseif #trial.offers > 0 then -- 1298
				sub = table.concat( -- 1299
					__TS__ArrayMap( -- 1299
						trial.offers, -- 1299
						function(____, talent, index) -- 1299
							local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1300
							return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1301
						end -- 1299
					), -- 1299
					"　" -- 1302
				) -- 1302
			else -- 1302
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 1304
			end -- 1304
		end -- 1304
		campaignSub.text = sub -- 1307
		campaignSub.position = Vec2(24 + safeL, h - 44 - safeT) -- 1308
		campaignSub.visible = true -- 1309
	end -- 1309
end -- 1309
function tickFrontend(frameDt) -- 1313
	if fe == nil or input == nil then -- 1314
		return -- 1315
	end -- 1315
	if fe.screen ~= "play" then -- 1319
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1320
		input:consumeEdges() -- 1321
		if act.type == "splashDone" then -- 1322
			fe.menus:resetInput() -- 1323
			fe.screen = "title" -- 1324
		elseif act.type == "trial" then -- 1325
			startTrial() -- 1326
		elseif act.type == "continue" then -- 1327
			if continueOfficialStory() == nil then -- 1328
				enterPlayRoom( -- 1329
					officialStartIndex(), -- 1329
					"official", -- 1329
					true -- 1329
				) -- 1329
			end -- 1329
		elseif act.type == "start" then -- 1331
			clearSession() -- 1333
			refreshTitleSessionFlag() -- 1334
			enterPlayRoom( -- 1335
				officialStartIndex(), -- 1335
				"official", -- 1335
				true -- 1335
			) -- 1335
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1336
			enterPlayRoom(act.roomIndex, "chapter") -- 1337
		elseif act.type == "openChapters" then -- 1338
			fe.menus:openChapters() -- 1339
			fe.screen = "chapters" -- 1340
		elseif act.type == "openControls" then -- 1341
			fe.menus:resetInput() -- 1342
			fe.screen = "controls" -- 1343
		elseif act.type == "backTitle" then -- 1344
			fe.menus:resetInput() -- 1345
			fe.screen = "title" -- 1346
		elseif act.type == "backPause" then -- 1347
			fe.menus:resetInput() -- 1348
			fe.screen = "play" -- 1349
		elseif act.type == "quit" then -- 1350
			quitGame() -- 1351
		end -- 1351
		return -- 1353
	end -- 1353
	if play == nil then -- 1357
		ensurePlay() -- 1358
	end -- 1358
	if play == nil then -- 1360
		return -- 1361
	end -- 1361
	local p = play -- 1363
	p.aimX = input.mx -- 1365
	p.aimY = input.my -- 1366
	local zoneTap = input.touchZoneTap -- 1368
	input.touchZoneTap = "" -- 1369
	local offers = p:getStoryTalentOffers() -- 1371
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1372
		if fe.hud.talentSelected >= #offers then -- 1373
			fe.hud.talentSelected = 0 -- 1374
		end -- 1374
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1376
			local idx = __TS__ParseInt( -- 1377
				string.sub(zoneTap, 8), -- 1377
				10 -- 1377
			) -- 1377
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1378
				input.fire.pressed = false -- 1379
			end -- 1379
		else -- 1379
			if input.talentDelta ~= 0 then -- 1382
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1383
				input.talentDelta = 0 -- 1384
			end -- 1384
			if input.talentConfirm then -- 1386
				p:chooseTalent(fe.hud.talentSelected) -- 1387
				input.talentConfirm = false -- 1388
				input.fire.pressed = false -- 1389
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1390
				input.fire.pressed = false -- 1392
			end -- 1392
		end -- 1392
	end -- 1392
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" and input.navConfirm then -- 1398
		input.interact.pressed = true -- 1399
	end -- 1399
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1402
		p:closeCraftBench() -- 1403
		input:consumeEdges() -- 1404
		return -- 1405
	end -- 1405
	if not p.paused and input.pause.pressed then -- 1407
		p.paused = true -- 1408
		p.aimHold = 0 -- 1409
		p.bottleAimX = -1 -- 1410
		saveCurrentSession() -- 1411
		fe.menus:openPause() -- 1412
		input:clearTransient(true) -- 1413
		input:consumeEdges() -- 1414
	end -- 1414
	if p.paused then -- 1417
		clock:reset() -- 1419
		local pauseAct = fe:renderPlay( -- 1420
			frameDt, -- 1420
			p, -- 1420
			input, -- 1420
			stageVp.stageW, -- 1420
			stageVp.stageH -- 1420
		) -- 1420
		input:consumeEdges() -- 1421
		if pauseAct.type == "resume" then -- 1422
			p.paused = false -- 1423
		elseif pauseAct.type == "retry" then -- 1424
			ensurePlay({checkpoint = p.checkpoint}) -- 1425
		elseif pauseAct.type == "openChapters" then -- 1426
			fe.audio:stopRoomTransient() -- 1427
			fe.audio:setPaused(false) -- 1428
			fe.menus:openChapters(current) -- 1429
			fe.screen = "chapters" -- 1430
		elseif pauseAct.type == "toggleFullscreen" then -- 1431
			toggleFullscreen() -- 1432
		elseif pauseAct.type == "quit" then -- 1433
			quitGame() -- 1434
		elseif pauseAct.type == "toTitle" then -- 1435
			saveCurrentSession() -- 1436
			refreshTitleSessionFlag() -- 1437
			fe.menus:resetInput() -- 1438
			fe.screen = "title" -- 1439
		end -- 1439
		return -- 1441
	end -- 1441
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1444
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1445
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1447
		input:consumeEdges() -- 1448
		ensurePlay({checkpoint = p.checkpoint}) -- 1450
		return -- 1451
	end -- 1451
	local steps = clock:advance(frameDt) -- 1454
	local i = 0 -- 1455
	do -- 1455
		i = 0 -- 1456
		while i < steps do -- 1456
			input:beginStep(i == 0) -- 1457
			p:update(STEP, input) -- 1458
			input:endStep() -- 1459
			if p.wantRoom ~= "" then -- 1460
				break -- 1461
			end -- 1461
			i = i + 1 -- 1456
		end -- 1456
	end -- 1456
	if p.wantRoom ~= "" then -- 1466
		local key = p.wantRoom -- 1467
		p.wantRoom = "" -- 1468
		local idx = -1 -- 1469
		local j = 0 -- 1470
		do -- 1470
			j = 0 -- 1471
			while j < #ROOMS do -- 1471
				if ROOMS[j + 1].key == key then -- 1472
					idx = j -- 1473
				end -- 1473
				j = j + 1 -- 1471
			end -- 1471
		end -- 1471
		if idx >= 0 then -- 1476
			flushProfile() -- 1480
			local leaving = p:drainEvents() -- 1481
			if p.restartStory then -- 1483
				if storyRun ~= nil and storyRun.source == "official" then -- 1484
					clearSession() -- 1485
					refreshTitleSessionFlag() -- 1486
				end -- 1486
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1488
				storyRun = createRun(20261124, nextSource, profile) -- 1489
			end -- 1489
			current = idx -- 1491
			ensurePlay() -- 1492
			local fresh = play -- 1493
			if fresh ~= nil then -- 1494
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1495
					fresh.phase = "prologue-wake" -- 1496
				end -- 1496
				fresh:adoptEvents(leaving) -- 1498
			end -- 1498
			if not p.restartStory then -- 1500
				saveCurrentSession() -- 1501
			end -- 1501
			clock:reset() -- 1503
			dirty = true -- 1504
		end -- 1504
		return -- 1506
	end -- 1506
	flushProfile() -- 1510
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1511
		clearSession() -- 1512
		refreshTitleSessionFlag() -- 1513
	elseif p.sessionDirty then -- 1514
		saveCurrentSession() -- 1515
	end -- 1515
	fe:renderPlay( -- 1517
		frameDt, -- 1517
		p, -- 1517
		input, -- 1517
		stageVp.stageW, -- 1517
		stageVp.stageH -- 1517
	) -- 1517
end -- 1517
function redrawGraybox() -- 1521
	if draw == nil then -- 1522
		return -- 1523
	end -- 1523
	local w = viewW -- 1525
	local h = viewH -- 1526
	local room = ROOMS[current + 1] -- 1527
	draw:clear() -- 1529
	draw:drawRect( -- 1530
		Rect(0, h - TOP_H, w, TOP_H), -- 1530
		C_BG -- 1530
	) -- 1530
	draw:drawRect( -- 1531
		Rect(0, 0, w, BOTTOM_H), -- 1531
		C_BG -- 1531
	) -- 1531
	draw:drawSegment( -- 1532
		Vec2(0, h - TOP_H), -- 1532
		Vec2(w, h - TOP_H), -- 1532
		1, -- 1532
		Color(52, 54, 54, 255) -- 1532
	) -- 1532
	draw:drawSegment( -- 1533
		Vec2(0, BOTTOM_H), -- 1533
		Vec2(w, BOTTOM_H), -- 1533
		1, -- 1533
		Color(52, 54, 54, 255) -- 1533
	) -- 1533
	local v = computeView(room, w, h) -- 1535
	renderWorld( -- 1536
		draw, -- 1536
		room, -- 1536
		v, -- 1536
		w, -- 1536
		h -- 1536
	) -- 1536
	local roomTop = v.groundPx + room.height * v.scale -- 1538
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1539
	place( -- 1541
		titleLabel, -- 1541
		48, -- 1541
		h - 40, -- 1541
		0, -- 1541
		1 -- 1541
	) -- 1541
	place( -- 1542
		roomLabel, -- 1542
		48, -- 1542
		h - 96, -- 1542
		0, -- 1542
		1 -- 1542
	) -- 1542
	place( -- 1543
		captionLabel, -- 1543
		48, -- 1543
		h - 140, -- 1543
		0, -- 1543
		1 -- 1543
	) -- 1543
	place( -- 1545
		switchLabel, -- 1545
		48, -- 1545
		40, -- 1545
		0, -- 1545
		0 -- 1545
	) -- 1545
	place( -- 1546
		hintLabel, -- 1546
		48, -- 1546
		84, -- 1546
		0, -- 1546
		0 -- 1546
	) -- 1546
	place( -- 1547
		rulerLabel, -- 1547
		w - 216, -- 1547
		roomTop + 36 + v.scale * 0.5 - 14, -- 1547
		1, -- 1547
		0 -- 1547
	) -- 1547
	place( -- 1548
		standLabel, -- 1548
		48, -- 1548
		roomTop + 40, -- 1548
		0, -- 1548
		0 -- 1548
	) -- 1548
	place( -- 1549
		cartLabel, -- 1549
		48, -- 1549
		roomTop + 92, -- 1549
		0, -- 1549
		0 -- 1549
	) -- 1549
	if roomLabel ~= nil then -- 1551
		roomLabel.text = room.name -- 1552
	end -- 1552
	if captionLabel ~= nil then -- 1554
		captionLabel.text = room.caption -- 1555
	end -- 1555
	if hintLabel ~= nil then -- 1557
		local hintIdx = math.min(current, #HINTS - 1) -- 1558
		local lines = HINTS[hintIdx + 1] -- 1559
		local merged = lines[1] -- 1560
		do -- 1560
			local i = 1 -- 1561
			while i < #lines do -- 1561
				merged = (merged .. "    ") .. lines[i + 1] -- 1562
				i = i + 1 -- 1561
			end -- 1561
		end -- 1561
		hintLabel.text = merged -- 1564
	end -- 1564
	local specs = collectLabels(room, v, w) -- 1567
	local body = {} -- 1568
	local small = {} -- 1569
	do -- 1569
		local i = 0 -- 1570
		while i < #specs do -- 1570
			local s = specs[i + 1] -- 1571
			if s.size >= 24 then -- 1572
				body[#body + 1] = s -- 1573
			else -- 1573
				small[#small + 1] = s -- 1575
			end -- 1575
			i = i + 1 -- 1570
		end -- 1570
	end -- 1570
	applyPool(body, poolBody) -- 1578
	applyPool(small, poolSmall) -- 1579
	if LAYOUT_AUDIT then -- 1581
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1582
	end -- 1582
end -- 1582
function applyPool(specs, pool) -- 1586
	do -- 1586
		local i = 0 -- 1587
		while i < #pool do -- 1587
			local lb = pool[i + 1] -- 1588
			if i < #specs then -- 1589
				local s = specs[i + 1] -- 1590
				lb.text = s.text -- 1591
				lb.position = Vec2(s.x, s.y) -- 1592
				lb.anchor = Vec2(s.ax, s.ay) -- 1593
				lb.color = s.color -- 1594
				lb.visible = true -- 1595
			else -- 1595
				lb.visible = false -- 1597
			end -- 1597
			i = i + 1 -- 1587
		end -- 1587
	end -- 1587
end -- 1587
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
	if fe.screen == "chapters" or fe.screen == "controls" then -- 177
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
			else -- 606
				fe.menus:resetInput() -- 608
			end -- 608
			if sc == "play" then -- 610
				ensurePlay() -- 611
			end -- 611
		end, -- 597
		jumpRoom = function(keyOrIdx) -- 614
			local idx = -1 -- 615
			if type(keyOrIdx) == "number" then -- 616
				idx = keyOrIdx -- 617
			else -- 617
				local k = 0 -- 619
				do -- 619
					k = 0 -- 620
					while k < #ROOMS do -- 620
						if ROOMS[k + 1].key == keyOrIdx then -- 621
							idx = k -- 622
						end -- 622
						k = k + 1 -- 620
					end -- 620
				end -- 620
			end -- 620
			if idx >= 0 and idx < #ROOMS then -- 626
				enterPlayRoom(idx, "debug") -- 627
			end -- 627
		end, -- 614
		getPlay = function() return play end, -- 630
		getFrontend = function() return fe end, -- 631
		startStory = function() -- 633
			enterPlayRoom( -- 634
				officialStartIndex(), -- 634
				"official", -- 634
				true -- 634
			) -- 634
			return play -- 635
		end, -- 633
		previewChapter = function(idx) -- 638
			enterPlayRoom(idx, "chapter") -- 639
			return play -- 640
		end, -- 638
		getStoryRun = function() return storyRun end, -- 642
		getProfilePending = function() return profilePending() end, -- 643
		flushProfileNow = function() return flushProfile() end, -- 644
		getProfile = function() return profile end, -- 646
		getProfileStatus = function() return profileStatus end, -- 647
		getProfileDetail = function() return profileDetail end, -- 648
		useTestSave = function(name) -- 649
			setSaveFile(name) -- 650
			setSessionFile(name == "" and "" or name .. ".session") -- 651
			clearProfilePending() -- 652
			local loaded = loadSave() -- 653
			profile = loaded.state -- 654
			profileStatus = loaded.status -- 655
			profileDetail = loaded.detail -- 656
			refreshTitleSessionFlag() -- 657
		end, -- 649
		useTestSession = function(name) -- 659
			setSessionFile(name) -- 660
			refreshTitleSessionFlag() -- 661
		end, -- 659
		getSessionFile = getSessionFile, -- 663
		hasSessionSave = hasSessionSave, -- 664
		saveSessionNow = function() return saveCurrentSession() end, -- 665
		clearSessionNow = function() -- 666
			local ok = clearSession() -- 667
			refreshTitleSessionFlag() -- 668
			return ok -- 669
		end, -- 666
		continueStory = function() return continueOfficialStory() end, -- 671
		saveNow = function() return saveSave(profile) end, -- 672
		getSaveFile = getSaveFile, -- 673
		isRelease = function() return isReleaseBuild() end, -- 674
		getReleaseVersion = function() -- 675
			local ____opt_30 = getReleaseConfig() -- 675
			return ____opt_30 and ____opt_30.version or "dev" -- 675
		end, -- 675
		toggleFullscreen = function() return toggleFullscreen() end, -- 676
		quitGame = function() return quitGame() end, -- 677
		startTrial = function() return startTrial() end, -- 678
		handleBackButton = function() return handleBackButton() end, -- 679
		getViewport = function() return stageVp end, -- 680
		getTouchController = function() return touchControls end, -- 681
		getTouchRouter = function() return touchRouter end, -- 682
		getGamepad = function() return gamepadRouter end, -- 683
		setGamepadSim = function(state) -- 684
			if gamepadRouter ~= nil then -- 685
				gamepadRouter:setSimulatedState(state) -- 685
			end -- 685
		end, -- 684
		injectTouch = function(phase, id, x, y, fromMouse) -- 687
			if touchRouter ~= nil then -- 688
				touchRouter:injectTouch( -- 688
					phase, -- 688
					id, -- 688
					x, -- 688
					y, -- 688
					fromMouse -- 688
				) -- 688
			end -- 688
		end, -- 687
		getInputMode = function() return input and input.inputMode or "kbm" end, -- 690
		setInputMode = function(m) -- 691
			if input ~= nil then -- 692
				input:setInputMode(m) -- 692
			end -- 692
		end, -- 691
		setModePref = function(pref) -- 694
			if input ~= nil then -- 695
				input:setModePref(pref) -- 695
			end -- 695
		end, -- 694
		applyViewportForTest = function(w, h) -- 697
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 698
				testViewportOverride = {w = w, h = h} -- 699
				viewW = w -- 700
				viewH = h -- 701
			else -- 701
				testViewportOverride = nil -- 703
				viewW = View.size.width -- 704
				viewH = View.size.height -- 705
			end -- 705
			applySize() -- 707
			dirty = true -- 708
			return stageVp -- 709
		end, -- 697
		getToast = function() return fe and fe:getToastText() or "" end -- 711
	} -- 711
	if mode == 1 and startScreen == "play" then -- 714
		ensurePlay() -- 715
	end -- 715
	parent:schedule(function(frameDt) -- 718
		tick(frameDt) -- 719
		return false -- 720
	end) -- 718
end -- 385
return ____exports -- 385
