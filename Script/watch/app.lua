-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local isReleaseBuild, onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, place, setMode, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, pickByIndex, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, touchRouter, gamepadRouter, touchControls, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock, trialTalentSelected -- 97
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
	if audioUnlocked or fe == nil then -- 102
		return -- 103
	end -- 103
	audioUnlocked = true -- 105
	fe.audio:unlockAndResyncAfterGesture() -- 106
end -- 106
function toggleFullscreen() -- 109
	if not canToggleFullscreen() then -- 110
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
	if input ~= nil then -- 125
		input:clearTransient(false) -- 125
	end -- 125
	if fe ~= nil then -- 126
		fe.audio:stopRoomTransient() -- 127
	end -- 127
	if not canQuitApp() then -- 129
		current = 0 -- 131
		play = nil -- 132
		run = nil -- 133
		setMode(1) -- 134
		if fe ~= nil then -- 135
			fe.screen = "title" -- 136
			fe.menus:resetInput() -- 137
		end -- 137
		return -- 139
	end -- 139
	App:shutdown() -- 141
end -- 141
function canSaveSession() -- 211
	if mode ~= 1 or play == nil or storyRun == nil then -- 212
		return false -- 213
	end -- 213
	if storyRun.source ~= "official" or play.run.finished then -- 215
		return false -- 216
	end -- 216
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 218
		return false -- 219
	end -- 219
	return true -- 221
end -- 221
function refreshTitleSessionFlag() -- 224
	if fe ~= nil then -- 225
		fe.menus.hasSession = hasSessionSave() -- 226
	end -- 226
end -- 226
function saveCurrentSession() -- 230
	if not canSaveSession() or play == nil then -- 231
		return false -- 232
	end -- 232
	play.sessionDirty = false -- 234
	local ok = saveSession(play:exportSession()) -- 235
	refreshTitleSessionFlag() -- 236
	return ok -- 237
end -- 237
function continueOfficialStory() -- 240
	local res = loadSession() -- 241
	if res.status ~= "ok" or res.state == nil then -- 242
		refreshTitleSessionFlag() -- 243
		return nil -- 244
	end -- 244
	local s = res.state -- 246
	local idx = roomIndexByKey(s.roomKey) -- 247
	if ROOMS[idx + 1].key ~= s.roomKey then -- 248
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
	if s.campaignRoute ~= nil then -- 285
		storyRun.route = s.campaignRoute -- 286
	end -- 286
	if s.joined ~= nil then -- 288
		storyRun.joined = s.joined -- 289
	end -- 289
	if s.c1Latch ~= nil then -- 291
		storyRun.c1Latch = s.c1Latch -- 292
	end -- 292
	if s.c2Latch ~= nil then -- 294
		storyRun.c2Latch = s.c2Latch -- 295
	end -- 295
	if s.props ~= nil then -- 297
		do -- 297
			k = 0 -- 298
			while k < #s.props do -- 298
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 299
				local pid = parts[1] -- 300
				if pid ~= nil and pid ~= "" then -- 301
					local ____storyRun_props_14 = storyRun.props -- 302
					local ____temp_10 -- 303
					if parts[2] == nil then -- 303
						____temp_10 = true -- 303
					else -- 303
						____temp_10 = parts[2] == "1" -- 303
					end -- 303
					local ____temp_12 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 304
					local ____temp_13 = parts[4] == "1" -- 305
					local ____temp_11 -- 306
					if parts[5] == "1" then -- 306
						____temp_11 = true -- 306
					else -- 306
						____temp_11 = nil -- 306
					end -- 306
					____storyRun_props_14[pid] = {broken = ____temp_10, hp = ____temp_12, wedge = ____temp_13, revealed = ____temp_11} -- 302
				end -- 302
				k = k + 1 -- 298
			end -- 298
		end -- 298
	end -- 298
	local stTalents = createStoryTalents(s.seed) -- 311
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 312
		stTalents.randomState = s.talentSeed -- 313
	end -- 313
	stTalents.room = s.talentRoom or "" -- 315
	stTalents.ranks.vitality = s.talentVitality or 0 -- 316
	stTalents.ranks.reload = s.talentReload or 0 -- 317
	stTalents.ranks.guard = s.talentGuard or 0 -- 318
	stTalents.ranks.craft = s.talentCraft or 0 -- 319
	if s.talentOffers ~= nil then -- 320
		do -- 320
			k = 0 -- 321
			while k < #s.talentOffers do -- 321
				local t = s.talentOffers[k + 1] -- 322
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 323
					local ____stTalents_offers_15 = stTalents.offers -- 324
					____stTalents_offers_15[#____stTalents_offers_15 + 1] = t -- 324
				end -- 324
				k = k + 1 -- 321
			end -- 321
		end -- 321
	end -- 321
	storyRun.story.talents = stTalents -- 328
	current = idx -- 329
	setMode(1) -- 330
	if fe ~= nil then -- 331
		fe.screen = "play" -- 332
	end -- 332
	play = nil -- 334
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 335
	local cur = play -- 336
	if cur ~= nil then -- 337
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 338
			cur.cartAxle = s.cartAxle -- 339
			cur.cartDocked = s.cartDocked -- 340
		end -- 340
		if s.playerX ~= nil and s.playerX >= 0 then -- 342
			cur.player.x = math.max( -- 343
				cur.room.minX + 16, -- 343
				math.min(cur.room.maxX - 16, s.playerX) -- 343
			) -- 343
			cur.player.y = math.max(0, s.playerY or 0) -- 344
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 345
				cur.player.depth = math.max( -- 346
					cur.room.depth.min, -- 346
					math.min(cur.room.depth.max, s.playerDepth) -- 346
				) -- 346
			end -- 346
		end -- 346
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 349
			cur.gateTick = s.gateTick -- 350
		end -- 350
		if cur.room.key == "village" then -- 352
			if s.hasBottle == true then -- 353
				cur.hasBottle = true -- 353
			end -- 353
			if s.villagePassed == true then -- 354
				cur.passed = true -- 354
			end -- 354
		end -- 354
	end -- 354
	return play -- 357
end -- 357
function place(lb, x, y, ax, ay) -- 375
	if lb == nil then -- 376
		return -- 377
	end -- 377
	lb.position = Vec2(x, y) -- 379
	lb.anchor = Vec2(ax, ay) -- 380
	lb.visible = true -- 381
end -- 381
function setMode(nextMode) -- 723
	mode = nextMode -- 724
	if grayboxLayer ~= nil then -- 725
		grayboxLayer.visible = mode == 0 -- 726
	end -- 726
	if fe ~= nil then -- 728
		fe:setVisible(mode == 1) -- 729
	end -- 729
	if campaignLayer ~= nil then -- 731
		campaignLayer.visible = mode == 2 -- 732
	end -- 732
	dirty = true -- 734
	clock:reset() -- 735
end -- 735
function flushProfile() -- 742
	local cur = play -- 743
	if cur ~= nil and cur.archiveDirty then -- 744
		cur.archiveDirty = false -- 745
		markProfilePending(profile) -- 746
	end -- 746
	local ok = flushSaveProfile() -- 748
	if not ok and cur ~= nil then -- 749
		cur.archiveDirty = true -- 750
	end -- 750
	return ok -- 752
end -- 752
function officialStartIndex() -- 756
	local mp = profile.museumPhase -- 757
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 758
	return inMuseum and roomIndexByKey("museum") or 0 -- 759
end -- 759
function roomIndexByKey(key) -- 762
	local i = 0 -- 763
	do -- 763
		i = 0 -- 764
		while i < #ROOMS do -- 764
			if ROOMS[i + 1].key == key then -- 765
				return i -- 766
			end -- 766
			i = i + 1 -- 764
		end -- 764
	end -- 764
	return 0 -- 769
end -- 769
function enterPlayRoom(idx, source, fresh) -- 772
	if source == nil then -- 772
		source = "debug" -- 772
	end -- 772
	if fresh == nil then -- 772
		fresh = false -- 772
	end -- 772
	current = idx -- 773
	setMode(1) -- 774
	if fe ~= nil then -- 775
		fe.screen = "play" -- 776
	end -- 776
	play = nil -- 778
	if fresh or source == "chapter" or storyRun == nil then -- 780
		storyRun = createRun(20261124, source, profile) -- 781
	else -- 781
		storyRun.source = source -- 783
	end -- 783
	ensurePlay() -- 785
	local firstPlay = play -- 787
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 788
		firstPlay.phase = "prologue-wake" -- 789
	end -- 789
	flushProfile() -- 791
end -- 791
function pickByIndex(idx, source) -- 794
	if source == nil then -- 794
		source = "debug" -- 794
	end -- 794
	if mode == 2 then -- 795
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 796
			return -- 797
		end -- 797
		current = idx -- 799
		play = nil -- 800
		clock:reset() -- 801
		ensurePlay() -- 802
		return -- 803
	end -- 803
	if idx < 0 or idx >= #ROOMS then -- 805
		return -- 806
	end -- 806
	flushProfile() -- 808
	if storyRun ~= nil then -- 809
		storyRun.source = source -- 810
	end -- 810
	current = idx -- 812
	dirty = true -- 813
	play = nil -- 814
	clock:reset() -- 815
	if mode == 1 then -- 816
		if fe ~= nil then -- 817
			fe.screen = "play" -- 818
		end -- 818
		ensurePlay() -- 820
	end -- 820
end -- 820
function applySize() -- 824
	if root == nil then -- 825
		return -- 826
	end -- 826
	root.size = Size(viewW, viewH) -- 828
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 829
	stageVp = computeStageViewport(viewW, viewH) -- 830
	if input ~= nil then -- 831
		input:setStageViewport(stageVp) -- 832
	end -- 832
	if fe ~= nil then -- 834
		fe:setStagePlacement(stageVp) -- 835
	end -- 835
	if campaignLayer ~= nil then -- 837
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 838
	end -- 838
	if grayboxLayer ~= nil then -- 840
		grayboxLayer.position = Vec2(0, 0) -- 841
	end -- 841
end -- 841
function syncFrameAdapters(frameDt) -- 845
	if input == nil then -- 846
		return -- 847
	end -- 847
	local p = play -- 849
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 850
	local isTrialMode = mode == 2 and p ~= nil -- 851
	local gameplayActive = isPlayMode or isTrialMode -- 852
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 854
		p, -- 856
		stageVp.stageW, -- 856
		stageVp.stageH, -- 856
		input:isTouchMode() -- 856
	) or ({}) -- 857
	if touchControls ~= nil and touchRouter ~= nil then -- 859
		local isFs = false -- 860
		if canToggleFullscreen() then -- 861
			do -- 861
				local function ____catch() -- 861
					isFs = false -- 865
				end -- 865
				local ____try = pcall(function() -- 865
					isFs = App.fullScreen -- 863
				end) -- 863
				if not ____try then -- 863
					____catch() -- 863
				end -- 863
			end -- 863
		end -- 863
		local ____touchControls_53 = touchControls -- 868
		local ____touchControls_syncContext_54 = touchControls.syncContext -- 868
		local ____stageVp_46 = stageVp -- 869
		local ____mode_47 = mode -- 870
		local ____temp_48 = fe ~= nil and fe.screen or "title" -- 871
		local ____run_49 = run -- 873
		local ____temp_50 = fe ~= nil and fe.cam or nil -- 874
		local ____input_51 = input -- 875
		local ____touchRouter_52 = touchRouter -- 876
		local ____temp_44 -- 877
		if fe ~= nil then -- 877
			____temp_44 = fe.contract:isAssistHintsEnabled() -- 877
		else -- 877
			____temp_44 = false -- 877
		end -- 877
		local ____temp_45 -- 878
		if fe ~= nil then -- 878
			____temp_45 = fe.audio:isAllMuted() -- 878
		else -- 878
			____temp_45 = false -- 878
		end -- 878
		____touchControls_syncContext_54(____touchControls_53, { -- 868
			viewport = ____stageVp_46, -- 869
			mode = ____mode_47, -- 870
			screen = ____temp_48, -- 871
			play = p, -- 872
			run = ____run_49, -- 873
			cam = ____temp_50, -- 874
			input = ____input_51, -- 875
			router = ____touchRouter_52, -- 876
			assistHintsEnabled = ____temp_44, -- 877
			isMuted = ____temp_45, -- 878
			isFullscreen = isFs, -- 879
			storyTalentBoxes = storyTalentBoxes, -- 880
			dt = frameDt -- 881
		}) -- 881
	end -- 881
	if gamepadRouter ~= nil then -- 885
		local trial = run and run.trial -- 886
		local trialEnded = isTrialMode and trial ~= nil and (trial.lost or (run and run.finished) == true) -- 887
		local trialHasOffers = isTrialMode and trial ~= nil and #trial.offers > 0 and p ~= nil and not p.paused and not trialEnded -- 888
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active) or isTrialMode and p ~= nil and (p.paused or trialEnded) -- 889
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 892
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 893
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and #p:getStoryTalentOffers() or (trialHasOffers and trial ~= nil and #trial.offers or 0) -- 894
		local ____temp_59 -- 897
		if isPlayMode and p ~= nil then -- 897
			____temp_59 = isCutsceneBlockingPlay(p) -- 897
		else -- 897
			____temp_59 = false -- 897
		end -- 897
		local cutsceneBlocking = ____temp_59 -- 897
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 898
		local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 900
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and not trialHasOffers and p.escort.state ~= "calming" -- 901
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 903
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 905
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 908
		local playerScreenX = stageVp.stageW * 0.5 -- 910
		local playerScreenY = stageVp.stageH * 0.38 -- 911
		if p ~= nil then -- 912
			if isPlayMode and fe ~= nil then -- 913
				playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 914
				playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 915
			else -- 915
				playerScreenX = stageVp.stageW * 0.45 -- 917
				playerScreenY = stageVp.stageH * 0.36 -- 918
			end -- 918
		end -- 918
		local enemyTargets = canShoot and p ~= nil and (isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or collectTrialAimTargets(p, stageVp.stageW, stageVp.stageH)) or ({}) -- 922
		local gpCtx = { -- 928
			stageW = stageVp.stageW, -- 929
			stageH = stageVp.stageH, -- 930
			uiScale = stageVp.uiScale, -- 931
			modal = modal, -- 932
			gameplayActive = gameplayActive, -- 933
			reloadActive = reloadActive, -- 934
			craftActive = craftActive, -- 935
			talentOfferCount = talentOfferCount, -- 936
			childMode = p ~= nil and p.childMode, -- 937
			allowDepth = allowDepth, -- 938
			canShoot = canShoot, -- 939
			canBottleAim = canBottleAim, -- 940
			playerRolling = p ~= nil and p.player.rollT > 0, -- 941
			inLowArch = inLowArch, -- 942
			inTowerEnd = inTowerEnd, -- 943
			playerFacing = p ~= nil and p.player.facing or 1, -- 944
			playerScreenX = playerScreenX, -- 945
			playerScreenY = playerScreenY, -- 946
			enemyTargets = enemyTargets -- 947
		} -- 947
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 949
	end -- 949
end -- 949
function renderTouchOverlay() -- 953
	if touchControls ~= nil and touchRouter ~= nil then -- 954
		touchControls:render(touchRouter) -- 955
	end -- 955
end -- 955
function tick(frameDt) -- 959
	appClock = appClock + math.min( -- 960
		0.05, -- 960
		math.max(0, frameDt) -- 960
	) -- 960
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 961
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 962
	if w ~= viewW or h ~= viewH then -- 963
		viewW = w -- 964
		viewH = h -- 965
		applySize() -- 966
		dirty = true -- 967
	end -- 967
	if input == nil then -- 969
		return -- 970
	end -- 970
	syncFrameAdapters(frameDt) -- 972
	input:update() -- 973
	if input.userInteracted then -- 975
		onFirstUserGesture() -- 976
	end -- 976
	if input.muteTogglePressed and fe ~= nil then -- 978
		input.muteTogglePressed = false -- 979
		fe.audio:toggleAllMuted() -- 980
	end -- 980
	if input.fullscreenTogglePressed then -- 982
		input.fullscreenTogglePressed = false -- 983
		toggleFullscreen() -- 984
	end -- 984
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 986
		input.artifactTogglePressed = false -- 987
		play:toggleArtifactWeapon() -- 988
	end -- 988
	if input.bottleCanceled and play ~= nil then -- 990
		input.bottleCanceled = false -- 991
		play.aimHold = 0 -- 992
		play.bottleAimX = -1 -- 993
	end -- 993
	if mode == 2 and (run and run.trial) ~= nil then -- 996
		tickCampaign(frameDt) -- 997
		renderTouchOverlay() -- 998
		return -- 999
	end -- 999
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 1002
		play:chooseTalent(input.pickRoom - 1) -- 1005
		input.pickRoom = 0 -- 1006
	end -- 1006
	if isReleaseBuild() then -- 1009
		input.toggleView.pressed = false -- 1010
		input.pickRoom = 0 -- 1011
		input.tab.pressed = false -- 1012
	else -- 1012
		if input.toggleView.pressed then -- 1015
			input.toggleView.pressed = false -- 1016
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 1017
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 1018
				ensurePlay() -- 1019
			end -- 1019
		end -- 1019
		if input.pickRoom ~= 0 then -- 1024
			local idx = input.pickRoom - 1 -- 1025
			input.pickRoom = 0 -- 1026
			pickByIndex(idx) -- 1027
		elseif input.tab.pressed then -- 1028
			input.tab.pressed = false -- 1029
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 1030
				pickByIndex((current + 1) % #ROOMS) -- 1031
			end -- 1031
		end -- 1031
	end -- 1031
	if mode == 2 then -- 1036
		tickCampaign(frameDt) -- 1037
	elseif mode == 1 then -- 1038
		tickFrontend(frameDt) -- 1039
	elseif dirty then -- 1040
		redrawGraybox() -- 1041
		dirty = false -- 1042
	end -- 1042
	renderTouchOverlay() -- 1044
end -- 1044
function registerPlay() -- 1048
	local reg = _G.package.loaded -- 1049
	reg["watch.play"] = play -- 1050
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 1051
	reg["watch.room"] = rooms[current + 1].key -- 1052
end -- 1052
function ensurePlay(resume) -- 1056
	if mode == 2 then -- 1057
		if run == nil then -- 1058
			run = createRun() -- 1059
		end -- 1059
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 1061
	else -- 1061
		if storyRun == nil then -- 1065
			storyRun = createRun(20261124, "debug", profile) -- 1066
		end -- 1066
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1068
	end -- 1068
	registerPlay() -- 1070
	clock:reset() -- 1071
	if fe ~= nil and mode == 1 then -- 1072
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1073
	end -- 1073
end -- 1073
function startTrial() -- 1077
	current = 0 -- 1078
	trialTalentSelected = 0 -- 1079
	run = createTrial(App.rand) -- 1080
	setMode(2) -- 1081
	ensurePlay() -- 1082
end -- 1082
function tickCampaign(frameDt) -- 1085
	if input == nil then -- 1086
		return -- 1087
	end -- 1087
	if play == nil then -- 1089
		ensurePlay() -- 1090
	end -- 1090
	if play == nil then -- 1092
		return -- 1093
	end -- 1093
	local p = play -- 1095
	p.aimX = input.mx -- 1096
	p.aimY = input.my -- 1097
	local zoneTap = input.touchZoneTap -- 1099
	input.touchZoneTap = "" -- 1100
	local trial = run and run.trial -- 1102
	if trial ~= nil then -- 1103
		local ended = trial.lost or (run and run.finished) == true -- 1104
		local pick = input.pickRoom -- 1105
		input.pickRoom = 0 -- 1106
		if zoneTap == "trial:resume" and p.paused and not ended then -- 1108
			p.paused = false -- 1109
			clock:reset() -- 1110
			input:consumeEdges() -- 1111
			drawCampaign(p) -- 1112
			return -- 1113
		end -- 1113
		if zoneTap == "trial:retry" then -- 1115
			input:consumeEdges() -- 1116
			startTrial() -- 1117
			return -- 1118
		end -- 1118
		if zoneTap == "trial:title" then -- 1120
			input:consumeEdges() -- 1121
			current = 0 -- 1122
			play = nil -- 1123
			run = nil -- 1124
			setMode(1) -- 1125
			if fe ~= nil then -- 1126
				fe.screen = "title" -- 1127
				fe.menus:resetInput() -- 1128
			end -- 1128
			return -- 1130
		end -- 1130
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1133
			input:consumeEdges() -- 1134
			current = 0 -- 1135
			play = nil -- 1136
			run = nil -- 1137
			setMode(1) -- 1138
			if fe ~= nil then -- 1139
				fe.screen = "title" -- 1140
				fe.menus:resetInput() -- 1141
			end -- 1141
			return -- 1143
		end -- 1143
		if ended or p.paused and input.retry.pressed then -- 1145
			local restart = input.retry.pressed or ended and input.navConfirm -- 1146
			input:consumeEdges() -- 1147
			if restart then -- 1148
				startTrial() -- 1148
			else -- 1148
				drawCampaign(p) -- 1149
			end -- 1149
			return -- 1150
		end -- 1150
		input.retry.pressed = false -- 1152
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1153
			if trialTalentSelected >= #trial.offers then -- 1154
				trialTalentSelected = 0 -- 1155
			end -- 1155
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1157
				local idx = __TS__ParseInt( -- 1158
					string.sub(zoneTap, 8), -- 1158
					10 -- 1158
				) -- 1158
				if idx >= 0 and idx < #trial.offers then -- 1159
					p:chooseTalent(idx) -- 1160
				end -- 1160
			elseif pick > 0 then -- 1162
				p:chooseTalent(pick - 1) -- 1163
			else -- 1163
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1165
				if delta ~= 0 then -- 1168
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1169
				end -- 1169
				if input.talentConfirm or input.navConfirm then -- 1171
					p:chooseTalent(trialTalentSelected) -- 1172
				end -- 1172
			end -- 1172
			input:consumeEdges() -- 1175
			clock:reset() -- 1176
			drawCampaign(p) -- 1177
			return -- 1178
		end -- 1178
	end -- 1178
	if input.retry.pressed then -- 1182
		input.retry.pressed = false -- 1183
		input:consumeEdges() -- 1184
		play = nil -- 1186
		ensurePlay() -- 1187
		return -- 1188
	end -- 1188
	if input.pause.pressed or p.paused and input.navBack then -- 1190
		input.pause.pressed = false -- 1191
		p.paused = not p.paused -- 1192
		clock:reset() -- 1193
		input:consumeEdges() -- 1194
	end -- 1194
	if p.paused then -- 1196
		drawCampaign(p) -- 1197
		return -- 1198
	end -- 1198
	local steps = clock:advance(frameDt) -- 1201
	local i = 0 -- 1202
	do -- 1202
		i = 0 -- 1203
		while i < steps do -- 1203
			input:beginStep(i == 0) -- 1204
			p:update(STEP, input) -- 1205
			input:endStep() -- 1206
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1207
				break -- 1208
			end -- 1208
			i = i + 1 -- 1203
		end -- 1203
	end -- 1203
	if p.wantRoom ~= "" then -- 1212
		local key = p.wantRoom -- 1213
		p.wantRoom = "" -- 1214
		local idx = -1 -- 1215
		local j = 0 -- 1216
		do -- 1216
			j = 0 -- 1217
			while j < #CAMPAIGN_ROOMS do -- 1217
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1218
					idx = j -- 1219
				end -- 1219
				j = j + 1 -- 1217
			end -- 1217
		end -- 1217
		if idx >= 0 then -- 1222
			current = idx -- 1223
			play = nil -- 1224
			ensurePlay() -- 1225
		end -- 1225
		return -- 1227
	end -- 1227
	drawCampaign(p) -- 1229
end -- 1229
function goalLabel(goal) -- 1232
	if goal == "dock_cart" then -- 1233
		return "推车入窝并抬闩" -- 1234
	end -- 1234
	if goal == "raise_latch" then -- 1236
		return "抬闩开侧门" -- 1237
	end -- 1237
	return "到段出口" -- 1239
end -- 1239
function drawCampaign(p) -- 1242
	if campaignDraw == nil then -- 1243
		return -- 1244
	end -- 1244
	local w = stageVp.stageW -- 1246
	local h = stageVp.stageH -- 1247
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1248
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1249
	p:draw(campaignDraw, w, h) -- 1250
	local room = CAMPAIGN_ROOMS[current + 1] -- 1251
	local c = room.campaign -- 1252
	local r = run -- 1253
	local line = room.name -- 1254
	if c ~= nil then -- 1255
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget) -- 1256
	end -- 1256
	if p.paused then -- 1259
		line = line .. "  · 已暂停 Esc 继续" -- 1260
	end -- 1260
	local trial = r and r.trial -- 1262
	if trial ~= nil and r ~= nil then -- 1263
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 1264
		if p.paused then -- 1265
			line = line .. " · 暂停" -- 1265
		elseif trial.lost then -- 1266
			line = line .. " · 护送失败" -- 1266
		elseif r.finished then -- 1267
			line = line .. " · 护送完成" -- 1267
		elseif #trial.offers > 0 then -- 1268
			line = line .. " · 选择本段本领" -- 1268
		elseif c ~= nil then -- 1269
			line = line .. " · " .. goalLabel(c.goal) -- 1269
		end -- 1269
	end -- 1269
	if campaignHud ~= nil then -- 1271
		campaignHud.text = line -- 1272
		campaignHud.position = Vec2(24 + safeL, h - 14 - safeT) -- 1273
		campaignHud.visible = true -- 1274
	end -- 1274
	if campaignSub ~= nil then -- 1276
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 1277
		if r ~= nil then -- 1278
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 1279
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 1280
		end -- 1280
		if p.flash ~= "" then -- 1285
			sub = (sub .. " · ") .. p.flash -- 1286
		end -- 1286
		if trial ~= nil and r ~= nil then -- 1288
			local gpMode = input ~= nil and input:isGamepadMode() -- 1289
			local touchMode = input ~= nil and input:isTouchMode() -- 1290
			if trial.lost or r.finished then -- 1291
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · A 再开一局 · START 返回标题" or (touchMode and " · 点下方按钮再开或返回标题" or " · R 再开一局 · Esc 返回标题")) -- 1292
			elseif p.paused then -- 1293
				sub = ("种子 " .. tostring(r.seed)) .. (gpMode and " · START 继续 · 长按BACK 重开 · Y 返回标题" or (touchMode and " · 点下方按钮继续/重开/返回标题" or " · Esc 继续 · R 重新开局 · E 返回标题")) -- 1294
			elseif #trial.offers > 0 then -- 1295
				sub = table.concat( -- 1296
					__TS__ArrayMap( -- 1296
						trial.offers, -- 1296
						function(____, talent, index) -- 1296
							local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1297
							return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1298
						end -- 1296
					), -- 1296
					"　" -- 1299
				) -- 1299
			else -- 1299
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 1301
			end -- 1301
		end -- 1301
		campaignSub.text = sub -- 1304
		campaignSub.position = Vec2(24 + safeL, h - 44 - safeT) -- 1305
		campaignSub.visible = true -- 1306
	end -- 1306
end -- 1306
function tickFrontend(frameDt) -- 1310
	if fe == nil or input == nil then -- 1311
		return -- 1312
	end -- 1312
	if fe.screen ~= "play" then -- 1316
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1317
		input:consumeEdges() -- 1318
		if act.type == "splashDone" then -- 1319
			fe.menus:resetInput() -- 1320
			fe.screen = "title" -- 1321
		elseif act.type == "trial" then -- 1322
			startTrial() -- 1323
		elseif act.type == "continue" then -- 1324
			if continueOfficialStory() == nil then -- 1325
				enterPlayRoom( -- 1326
					officialStartIndex(), -- 1326
					"official", -- 1326
					true -- 1326
				) -- 1326
			end -- 1326
		elseif act.type == "start" then -- 1328
			clearSession() -- 1330
			refreshTitleSessionFlag() -- 1331
			enterPlayRoom( -- 1332
				officialStartIndex(), -- 1332
				"official", -- 1332
				true -- 1332
			) -- 1332
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1333
			enterPlayRoom(act.roomIndex, "chapter") -- 1334
		elseif act.type == "openChapters" then -- 1335
			fe.menus:openChapters() -- 1336
			fe.screen = "chapters" -- 1337
		elseif act.type == "openControls" then -- 1338
			fe.menus:resetInput() -- 1339
			fe.screen = "controls" -- 1340
		elseif act.type == "backTitle" then -- 1341
			fe.menus:resetInput() -- 1342
			fe.screen = "title" -- 1343
		elseif act.type == "backPause" then -- 1344
			fe.menus:resetInput() -- 1345
			fe.screen = "play" -- 1346
		elseif act.type == "quit" then -- 1347
			quitGame() -- 1348
		end -- 1348
		return -- 1350
	end -- 1350
	if play == nil then -- 1354
		ensurePlay() -- 1355
	end -- 1355
	if play == nil then -- 1357
		return -- 1358
	end -- 1358
	local p = play -- 1360
	p.aimX = input.mx -- 1362
	p.aimY = input.my -- 1363
	local zoneTap = input.touchZoneTap -- 1365
	input.touchZoneTap = "" -- 1366
	local offers = p:getStoryTalentOffers() -- 1368
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1369
		if fe.hud.talentSelected >= #offers then -- 1370
			fe.hud.talentSelected = 0 -- 1371
		end -- 1371
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1373
			local idx = __TS__ParseInt( -- 1374
				string.sub(zoneTap, 8), -- 1374
				10 -- 1374
			) -- 1374
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1375
				input.fire.pressed = false -- 1376
			end -- 1376
		else -- 1376
			if input.talentDelta ~= 0 then -- 1379
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1380
				input.talentDelta = 0 -- 1381
			end -- 1381
			if input.talentConfirm then -- 1383
				p:chooseTalent(fe.hud.talentSelected) -- 1384
				input.talentConfirm = false -- 1385
				input.fire.pressed = false -- 1386
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1387
				input.fire.pressed = false -- 1389
			end -- 1389
		end -- 1389
	end -- 1389
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" and input.navConfirm then -- 1395
		input.interact.pressed = true -- 1396
	end -- 1396
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1399
		p:closeCraftBench() -- 1400
		input:consumeEdges() -- 1401
		return -- 1402
	end -- 1402
	if not p.paused and input.pause.pressed then -- 1404
		p.paused = true -- 1405
		p.aimHold = 0 -- 1406
		p.bottleAimX = -1 -- 1407
		saveCurrentSession() -- 1408
		fe.menus:openPause() -- 1409
		input:clearTransient(true) -- 1410
		input:consumeEdges() -- 1411
	end -- 1411
	if p.paused then -- 1414
		clock:reset() -- 1416
		local pauseAct = fe:renderPlay( -- 1417
			frameDt, -- 1417
			p, -- 1417
			input, -- 1417
			stageVp.stageW, -- 1417
			stageVp.stageH -- 1417
		) -- 1417
		input:consumeEdges() -- 1418
		if pauseAct.type == "resume" then -- 1419
			p.paused = false -- 1420
		elseif pauseAct.type == "retry" then -- 1421
			ensurePlay({checkpoint = p.checkpoint}) -- 1422
		elseif pauseAct.type == "openChapters" then -- 1423
			fe.audio:stopRoomTransient() -- 1424
			fe.audio:setPaused(false) -- 1425
			fe.menus:openChapters(current) -- 1426
			fe.screen = "chapters" -- 1427
		elseif pauseAct.type == "toggleFullscreen" then -- 1428
			toggleFullscreen() -- 1429
		elseif pauseAct.type == "quit" then -- 1430
			quitGame() -- 1431
		elseif pauseAct.type == "toTitle" then -- 1432
			saveCurrentSession() -- 1433
			refreshTitleSessionFlag() -- 1434
			fe.menus:resetInput() -- 1435
			fe.screen = "title" -- 1436
		end -- 1436
		return -- 1438
	end -- 1438
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1441
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1442
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1444
		input:consumeEdges() -- 1445
		ensurePlay({checkpoint = p.checkpoint}) -- 1447
		return -- 1448
	end -- 1448
	local steps = clock:advance(frameDt) -- 1451
	local i = 0 -- 1452
	do -- 1452
		i = 0 -- 1453
		while i < steps do -- 1453
			input:beginStep(i == 0) -- 1454
			p:update(STEP, input) -- 1455
			input:endStep() -- 1456
			if p.wantRoom ~= "" then -- 1457
				break -- 1458
			end -- 1458
			i = i + 1 -- 1453
		end -- 1453
	end -- 1453
	if p.wantRoom ~= "" then -- 1463
		local key = p.wantRoom -- 1464
		p.wantRoom = "" -- 1465
		local idx = -1 -- 1466
		local j = 0 -- 1467
		do -- 1467
			j = 0 -- 1468
			while j < #ROOMS do -- 1468
				if ROOMS[j + 1].key == key then -- 1469
					idx = j -- 1470
				end -- 1470
				j = j + 1 -- 1468
			end -- 1468
		end -- 1468
		if idx >= 0 then -- 1473
			flushProfile() -- 1477
			local leaving = p:drainEvents() -- 1478
			if p.restartStory then -- 1480
				if storyRun ~= nil and storyRun.source == "official" then -- 1481
					clearSession() -- 1482
					refreshTitleSessionFlag() -- 1483
				end -- 1483
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1485
				storyRun = createRun(20261124, nextSource, profile) -- 1486
			end -- 1486
			current = idx -- 1488
			ensurePlay() -- 1489
			local fresh = play -- 1490
			if fresh ~= nil then -- 1491
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1492
					fresh.phase = "prologue-wake" -- 1493
				end -- 1493
				fresh:adoptEvents(leaving) -- 1495
			end -- 1495
			if not p.restartStory then -- 1497
				saveCurrentSession() -- 1498
			end -- 1498
			clock:reset() -- 1500
			dirty = true -- 1501
		end -- 1501
		return -- 1503
	end -- 1503
	flushProfile() -- 1507
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1508
		clearSession() -- 1509
		refreshTitleSessionFlag() -- 1510
	elseif p.sessionDirty then -- 1511
		saveCurrentSession() -- 1512
	end -- 1512
	fe:renderPlay( -- 1514
		frameDt, -- 1514
		p, -- 1514
		input, -- 1514
		stageVp.stageW, -- 1514
		stageVp.stageH -- 1514
	) -- 1514
end -- 1514
function redrawGraybox() -- 1518
	if draw == nil then -- 1519
		return -- 1520
	end -- 1520
	local w = viewW -- 1522
	local h = viewH -- 1523
	local room = ROOMS[current + 1] -- 1524
	draw:clear() -- 1526
	draw:drawRect( -- 1527
		Rect(0, h - TOP_H, w, TOP_H), -- 1527
		C_BG -- 1527
	) -- 1527
	draw:drawRect( -- 1528
		Rect(0, 0, w, BOTTOM_H), -- 1528
		C_BG -- 1528
	) -- 1528
	draw:drawSegment( -- 1529
		Vec2(0, h - TOP_H), -- 1529
		Vec2(w, h - TOP_H), -- 1529
		1, -- 1529
		Color(52, 54, 54, 255) -- 1529
	) -- 1529
	draw:drawSegment( -- 1530
		Vec2(0, BOTTOM_H), -- 1530
		Vec2(w, BOTTOM_H), -- 1530
		1, -- 1530
		Color(52, 54, 54, 255) -- 1530
	) -- 1530
	local v = computeView(room, w, h) -- 1532
	renderWorld( -- 1533
		draw, -- 1533
		room, -- 1533
		v, -- 1533
		w, -- 1533
		h -- 1533
	) -- 1533
	local roomTop = v.groundPx + room.height * v.scale -- 1535
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1536
	place( -- 1538
		titleLabel, -- 1538
		48, -- 1538
		h - 40, -- 1538
		0, -- 1538
		1 -- 1538
	) -- 1538
	place( -- 1539
		roomLabel, -- 1539
		48, -- 1539
		h - 96, -- 1539
		0, -- 1539
		1 -- 1539
	) -- 1539
	place( -- 1540
		captionLabel, -- 1540
		48, -- 1540
		h - 140, -- 1540
		0, -- 1540
		1 -- 1540
	) -- 1540
	place( -- 1542
		switchLabel, -- 1542
		48, -- 1542
		40, -- 1542
		0, -- 1542
		0 -- 1542
	) -- 1542
	place( -- 1543
		hintLabel, -- 1543
		48, -- 1543
		84, -- 1543
		0, -- 1543
		0 -- 1543
	) -- 1543
	place( -- 1544
		rulerLabel, -- 1544
		w - 216, -- 1544
		roomTop + 36 + v.scale * 0.5 - 14, -- 1544
		1, -- 1544
		0 -- 1544
	) -- 1544
	place( -- 1545
		standLabel, -- 1545
		48, -- 1545
		roomTop + 40, -- 1545
		0, -- 1545
		0 -- 1545
	) -- 1545
	place( -- 1546
		cartLabel, -- 1546
		48, -- 1546
		roomTop + 92, -- 1546
		0, -- 1546
		0 -- 1546
	) -- 1546
	if roomLabel ~= nil then -- 1548
		roomLabel.text = room.name -- 1549
	end -- 1549
	if captionLabel ~= nil then -- 1551
		captionLabel.text = room.caption -- 1552
	end -- 1552
	if hintLabel ~= nil then -- 1554
		local hintIdx = math.min(current, #HINTS - 1) -- 1555
		local lines = HINTS[hintIdx + 1] -- 1556
		local merged = lines[1] -- 1557
		do -- 1557
			local i = 1 -- 1558
			while i < #lines do -- 1558
				merged = (merged .. "    ") .. lines[i + 1] -- 1559
				i = i + 1 -- 1558
			end -- 1558
		end -- 1558
		hintLabel.text = merged -- 1561
	end -- 1561
	local specs = collectLabels(room, v, w) -- 1564
	local body = {} -- 1565
	local small = {} -- 1566
	do -- 1566
		local i = 0 -- 1567
		while i < #specs do -- 1567
			local s = specs[i + 1] -- 1568
			if s.size >= 24 then -- 1569
				body[#body + 1] = s -- 1570
			else -- 1570
				small[#small + 1] = s -- 1572
			end -- 1572
			i = i + 1 -- 1567
		end -- 1567
	end -- 1567
	applyPool(body, poolBody) -- 1575
	applyPool(small, poolSmall) -- 1576
	if LAYOUT_AUDIT then -- 1578
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1579
	end -- 1579
end -- 1579
function applyPool(specs, pool) -- 1583
	do -- 1583
		local i = 0 -- 1584
		while i < #pool do -- 1584
			local lb = pool[i + 1] -- 1585
			if i < #specs then -- 1586
				local s = specs[i + 1] -- 1587
				lb.text = s.text -- 1588
				lb.position = Vec2(s.x, s.y) -- 1589
				lb.anchor = Vec2(s.ax, s.ay) -- 1590
				lb.color = s.color -- 1591
				lb.visible = true -- 1592
			else -- 1592
				lb.visible = false -- 1594
			end -- 1594
			i = i + 1 -- 1584
		end -- 1584
	end -- 1584
end -- 1584
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
	if mode == 0 then -- 145
		setMode(1) -- 146
		return -- 147
	end -- 147
	if mode == 2 and play ~= nil then -- 149
		local trial = run and run.trial -- 150
		if trial ~= nil and (trial.lost or (run and run.finished) == true) then -- 151
			current = 0 -- 152
			play = nil -- 153
			run = nil -- 154
			setMode(1) -- 155
			if fe ~= nil then -- 156
				fe.screen = "title" -- 157
				fe.menus:resetInput() -- 158
			end -- 158
			return -- 160
		end -- 160
		play.paused = not play.paused -- 162
		clock:reset() -- 163
		if input ~= nil then -- 164
			input:clearTransient(true) -- 164
		end -- 164
		return -- 165
	end -- 165
	if fe == nil then -- 167
		return -- 168
	end -- 168
	if fe.screen == "splash" then -- 170
		fe.menus:resetSplash() -- 171
		fe.screen = "title" -- 172
		fe.menus:resetInput() -- 173
		return -- 174
	end -- 174
	if fe.screen == "chapters" or fe.screen == "controls" then -- 176
		fe.menus:triggerBack() -- 177
		return -- 178
	end -- 178
	if fe.screen == "title" then -- 180
		if not canQuitApp() then -- 181
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 182
			return -- 183
		end -- 183
		if appClock - lastBackPressClock <= 2 then -- 185
			quitGame() -- 186
		else -- 186
			lastBackPressClock = appClock -- 188
			fe:showToast("再按一次返回退出游戏", 2) -- 189
		end -- 189
		return -- 191
	end -- 191
	if fe.screen == "play" and play ~= nil then -- 193
		if play.paused then -- 194
			fe.menus:triggerBack() -- 195
			return -- 196
		end -- 196
		if play.craftBench.active then -- 198
			play:closeCraftBench() -- 199
			return -- 200
		end -- 200
		play.paused = true -- 202
		play.aimHold = 0 -- 203
		play.bottleAimX = -1 -- 204
		saveCurrentSession() -- 205
		fe.menus:openPause() -- 206
		if input ~= nil then -- 207
			input:clearTransient(true) -- 207
		end -- 207
	end -- 207
end -- 144
local function makeGrayboxLabel(text, size, color) -- 360
	if grayboxLayer == nil then -- 361
		return nil -- 362
	end -- 362
	local lb = Label(FONT, size) -- 364
	if lb == nil then -- 365
		return nil -- 366
	end -- 366
	lb.text = text -- 368
	lb.color = color -- 369
	lb:addTo(grayboxLayer) -- 370
	lb.visible = true -- 371
	return lb -- 372
end -- 360
function ____exports.start(parent, initialMode, startScreen) -- 384
	if initialMode == nil then -- 384
		initialMode = 1 -- 384
	end -- 384
	if startScreen == nil then -- 384
		startScreen = "title" -- 384
	end -- 384
	root = parent -- 385
	mode = initialMode -- 386
	grayboxLayer = Node() -- 389
	grayboxLayer.order = 2 -- 390
	grayboxLayer:addTo(parent) -- 391
	draw = DrawNode() -- 393
	draw:addTo(grayboxLayer) -- 394
	campaignLayer = Node() -- 397
	campaignLayer.order = 3 -- 398
	campaignLayer:addTo(parent) -- 399
	campaignDraw = DrawNode() -- 400
	campaignDraw:addTo(campaignLayer) -- 401
	campaignHud = Label(FONT, 24) -- 402
	if campaignHud ~= nil then -- 403
		campaignHud.color = C_TEXT -- 404
		campaignHud.anchor = Vec2(0, 1) -- 405
		campaignHud:addTo(campaignLayer) -- 406
		campaignHud.visible = true -- 407
	end -- 407
	campaignSub = Label(FONT, 20) -- 409
	if campaignSub ~= nil then -- 410
		campaignSub.color = C_ACCENT -- 411
		campaignSub.anchor = Vec2(0, 1) -- 412
		campaignSub:addTo(campaignLayer) -- 413
		campaignSub.visible = true -- 414
	end -- 414
	campaignLayer.visible = mode == 2 -- 416
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 418
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 419
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 420
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 421
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 422
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 423
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 424
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 425
	do -- 425
		local i = 0 -- 427
		while i < POOL_BODY do -- 427
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 428
			if lb ~= nil then -- 429
				poolBody[#poolBody + 1] = lb -- 430
			end -- 430
			i = i + 1 -- 427
		end -- 427
	end -- 427
	do -- 427
		local i = 0 -- 433
		while i < POOL_SMALL do -- 433
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 434
			if lb ~= nil then -- 435
				poolSmall[#poolSmall + 1] = lb -- 436
			end -- 436
			i = i + 1 -- 433
		end -- 433
	end -- 433
	if mode == 1 then -- 442
		local loaded = loadSave() -- 443
		profile = loaded.state -- 444
		profileStatus = loaded.status -- 445
		profileDetail = loaded.detail -- 446
	end -- 446
	fe = __TS__New(WatchFrontend, parent) -- 448
	fe.screen = startScreen -- 449
	if startScreen == "splash" then -- 450
		fe.menus:resetSplash() -- 451
	end -- 451
	refreshTitleSessionFlag() -- 453
	grayboxLayer.visible = mode == 0 -- 454
	fe:setVisible(mode == 1) -- 455
	if campaignLayer ~= nil then -- 456
		campaignLayer.visible = mode == 2 -- 457
	end -- 457
	input = __TS__New(Input) -- 460
	touchRouter = __TS__New(TouchRouter, input.settings) -- 461
	touchRouter:attach(parent) -- 462
	input:bindTouch(touchRouter) -- 463
	gamepadRouter = __TS__New(GamepadRouter, input.settings) -- 465
	gamepadRouter:attach(parent) -- 466
	input:bindGamepad(gamepadRouter) -- 467
	touchControls = __TS__New(TouchControls, parent) -- 469
	parent:gslot( -- 472
		"AppEvent", -- 472
		function(eventType) -- 472
			if eventType == "BackButton" then -- 473
				handleBackButton() -- 474
				return -- 475
			end -- 475
			if eventType == "Quit" or eventType == "Shutdown" then -- 477
				flushProfile() -- 478
				saveCurrentSession() -- 479
				if input ~= nil then -- 480
					input:clearTransient(false) -- 480
				end -- 480
				return -- 481
			end -- 481
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 483
				flushProfile() -- 484
				saveCurrentSession() -- 485
				if input ~= nil then -- 486
					input:clearTransient(true) -- 486
				end -- 486
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 487
					play.paused = true -- 488
					play.aimHold = 0 -- 489
					play.bottleAimX = -1 -- 490
					fe.menus:openPause() -- 491
				elseif mode == 2 and play ~= nil and not play.paused then -- 492
					play.paused = true -- 493
				end -- 493
				if fe ~= nil then -- 495
					fe.audio:setPaused(true) -- 496
				end -- 496
				return -- 498
			end -- 498
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 500
				if fe ~= nil then -- 501
					local paused = play ~= nil and play.paused and (mode == 1 and fe.screen == "play" or mode == 2) -- 502
					fe.audio:setPaused(paused) -- 504
				end -- 504
			end -- 504
		end -- 472
	) -- 472
	parent:onKeyDown(function(key) -- 510
		onFirstUserGesture() -- 511
		if input ~= nil then -- 512
			input:markKeyboardActivity() -- 512
		end -- 512
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 513
			toggleFullscreen() -- 515
			return -- 516
		end -- 516
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 518
			play:toggleArtifactWeapon() -- 519
			return -- 520
		end -- 520
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and #play:getStoryTalentOffers() > 0 then -- 522
			if key == "1" then -- 524
				play:chooseTalent(0) -- 525
				if input ~= nil then -- 526
					input:consumePickRoom() -- 526
				end -- 526
				return -- 527
			end -- 527
			if key == "2" then -- 529
				play:chooseTalent(1) -- 530
				if input ~= nil then -- 531
					input:consumePickRoom() -- 531
				end -- 531
				return -- 532
			end -- 532
			if key == "3" then -- 534
				play:chooseTalent(2) -- 535
				if input ~= nil then -- 536
					input:consumePickRoom() -- 536
				end -- 536
				return -- 537
			end -- 537
		end -- 537
		local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 540
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 541
			fe.menus:onKeyEvent(key) -- 542
		end -- 542
		if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay or mode == 2) then -- 544
			if key == "E" then -- 545
				input.interact.pressed = true -- 546
			elseif key == "Space" then -- 547
				input.jump.pressed = true -- 548
			elseif key == "Escape" then -- 549
				input.pause.pressed = true -- 550
			elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 551
				input.retry.pressed = true -- 552
			end -- 552
		end -- 552
		if mode == 2 and (run and run.trial) ~= nil then -- 555
			return -- 555
		end -- 555
		if isReleaseBuild() then -- 556
			return -- 556
		end -- 556
		if key == "F1" then -- 557
			if mode == 2 then -- 558
				current = 0 -- 559
				play = nil -- 560
				ensurePlay() -- 561
			else -- 561
				enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 563
			end -- 563
		elseif key == "F2" then -- 565
			setMode(0) -- 566
		elseif key == "1" then -- 567
			pickByIndex(0) -- 568
		elseif key == "2" then -- 569
			pickByIndex(1) -- 570
		elseif key == "3" then -- 571
			pickByIndex(2) -- 572
		elseif key == "4" then -- 573
			pickByIndex(3) -- 574
		elseif key == "5" then -- 575
			pickByIndex(4) -- 576
		elseif key == "6" then -- 577
			pickByIndex(5) -- 578
		elseif key == "7" then -- 579
			pickByIndex(6) -- 580
		elseif key == "8" then -- 581
			pickByIndex(7) -- 582
		end -- 582
	end) -- 510
	viewW = View.size.width -- 586
	viewH = View.size.height -- 587
	applySize() -- 588
	local reg = _G.package.loaded -- 591
	reg["watch.input"] = input -- 592
	reg["watch.touch"] = touchRouter -- 593
	reg["watch.gamepad"] = gamepadRouter -- 594
	reg["watch.fe"] = { -- 595
		setScreen = function(sc) -- 596
			if fe == nil then -- 597
				return -- 598
			end -- 598
			setMode(1) -- 600
			fe.screen = sc -- 601
			if sc == "splash" then -- 602
				fe.menus:resetSplash() -- 603
			elseif sc == "chapters" then -- 604
				fe.menus:openChapters() -- 605
			else -- 605
				fe.menus:resetInput() -- 607
			end -- 607
			if sc == "play" then -- 609
				ensurePlay() -- 610
			end -- 610
		end, -- 596
		jumpRoom = function(keyOrIdx) -- 613
			local idx = -1 -- 614
			if type(keyOrIdx) == "number" then -- 615
				idx = keyOrIdx -- 616
			else -- 616
				local k = 0 -- 618
				do -- 618
					k = 0 -- 619
					while k < #ROOMS do -- 619
						if ROOMS[k + 1].key == keyOrIdx then -- 620
							idx = k -- 621
						end -- 621
						k = k + 1 -- 619
					end -- 619
				end -- 619
			end -- 619
			if idx >= 0 and idx < #ROOMS then -- 625
				enterPlayRoom(idx, "debug") -- 626
			end -- 626
		end, -- 613
		getPlay = function() return play end, -- 629
		getFrontend = function() return fe end, -- 630
		startStory = function() -- 632
			enterPlayRoom( -- 633
				officialStartIndex(), -- 633
				"official", -- 633
				true -- 633
			) -- 633
			return play -- 634
		end, -- 632
		previewChapter = function(idx) -- 637
			enterPlayRoom(idx, "chapter") -- 638
			return play -- 639
		end, -- 637
		getStoryRun = function() return storyRun end, -- 641
		getProfilePending = function() return profilePending() end, -- 642
		flushProfileNow = function() return flushProfile() end, -- 643
		getProfile = function() return profile end, -- 645
		getProfileStatus = function() return profileStatus end, -- 646
		getProfileDetail = function() return profileDetail end, -- 647
		useTestSave = function(name) -- 648
			setSaveFile(name) -- 649
			setSessionFile(name == "" and "" or name .. ".session") -- 650
			clearProfilePending() -- 651
			local loaded = loadSave() -- 652
			profile = loaded.state -- 653
			profileStatus = loaded.status -- 654
			profileDetail = loaded.detail -- 655
			refreshTitleSessionFlag() -- 656
		end, -- 648
		useTestSession = function(name) -- 658
			setSessionFile(name) -- 659
			refreshTitleSessionFlag() -- 660
		end, -- 658
		getSessionFile = getSessionFile, -- 662
		hasSessionSave = hasSessionSave, -- 663
		saveSessionNow = function() return saveCurrentSession() end, -- 664
		clearSessionNow = function() -- 665
			local ok = clearSession() -- 666
			refreshTitleSessionFlag() -- 667
			return ok -- 668
		end, -- 665
		continueStory = function() return continueOfficialStory() end, -- 670
		saveNow = function() return saveSave(profile) end, -- 671
		getSaveFile = getSaveFile, -- 672
		isRelease = function() return isReleaseBuild() end, -- 673
		getReleaseVersion = function() -- 674
			local ____opt_30 = getReleaseConfig() -- 674
			return ____opt_30 and ____opt_30.version or "dev" -- 674
		end, -- 674
		toggleFullscreen = function() return toggleFullscreen() end, -- 675
		quitGame = function() return quitGame() end, -- 676
		startTrial = function() return startTrial() end, -- 677
		handleBackButton = function() return handleBackButton() end, -- 678
		getViewport = function() return stageVp end, -- 679
		getTouchController = function() return touchControls end, -- 680
		getTouchRouter = function() return touchRouter end, -- 681
		getGamepad = function() return gamepadRouter end, -- 682
		setGamepadSim = function(state) -- 683
			if gamepadRouter ~= nil then -- 684
				gamepadRouter:setSimulatedState(state) -- 684
			end -- 684
		end, -- 683
		injectTouch = function(phase, id, x, y, fromMouse) -- 686
			if touchRouter ~= nil then -- 687
				touchRouter:injectTouch( -- 687
					phase, -- 687
					id, -- 687
					x, -- 687
					y, -- 687
					fromMouse -- 687
				) -- 687
			end -- 687
		end, -- 686
		getInputMode = function() return input and input.inputMode or "kbm" end, -- 689
		setInputMode = function(m) -- 690
			if input ~= nil then -- 691
				input:setInputMode(m) -- 691
			end -- 691
		end, -- 690
		setModePref = function(pref) -- 693
			if input ~= nil then -- 694
				input:setModePref(pref) -- 694
			end -- 694
		end, -- 693
		applyViewportForTest = function(w, h) -- 696
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 697
				testViewportOverride = {w = w, h = h} -- 698
				viewW = w -- 699
				viewH = h -- 700
			else -- 700
				testViewportOverride = nil -- 702
				viewW = View.size.width -- 703
				viewH = View.size.height -- 704
			end -- 704
			applySize() -- 706
			dirty = true -- 707
			return stageVp -- 708
		end, -- 696
		getToast = function() return fe and fe:getToastText() or "" end -- 710
	} -- 710
	if mode == 1 and startScreen == "play" then -- 713
		ensurePlay() -- 714
	end -- 714
	parent:schedule(function(frameDt) -- 717
		tick(frameDt) -- 718
		return false -- 719
	end) -- 717
end -- 384
return ____exports -- 384
