-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local isReleaseBuild, onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, place, setMode, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, pickByIndex, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, startTrial, tickCampaign, goalLabel, drawCampaign, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, campaignLayer, campaignDraw, campaignHud, campaignSub, run, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock, trialTalentSelected -- 1
local ____Dora = require("Dora") -- 8
local App = ____Dora.App -- 8
local Color = ____Dora.Color -- 8
local DrawNode = ____Dora.DrawNode -- 8
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
local ____platform = require("Script.watch.platform") -- 16
local canQuitApp = ____platform.canQuitApp -- 18
local canToggleFullscreen = ____platform.canToggleFullscreen -- 19
local computeStageViewport = ____platform.computeStageViewport -- 20
local getReleaseConfig = ____platform.getReleaseConfig -- 21
local isReleaseMode = ____platform.isReleaseMode -- 22
local ____target = require("Script.watch.target") -- 24
local getActiveTarget = ____target.getActiveTarget -- 24
local ____frontend = require("Script.watch.fe.frontend") -- 25
local WatchFrontend = ____frontend.WatchFrontend -- 25
local ____run = require("Script.watch.run") -- 26
local createRun = ____run.createRun -- 26
local createStoryTalents = ____run.createStoryTalents -- 26
local createTrial = ____run.createTrial -- 26
local mmss = ____run.mmss -- 26
local talentNames = ____run.talentNames -- 26
local ____save = require("Script.watch.save") -- 27
local emptySave = ____save.emptySave -- 27
local loadSave = ____save.loadSave -- 27
local saveSave = ____save.saveSave -- 27
local setSaveFile = ____save.setSaveFile -- 27
local getSaveFile = ____save.getSaveFile -- 27
local markProfilePending = ____save.markProfilePending -- 28
local flushSaveProfile = ____save.flushProfile -- 28
local clearProfilePending = ____save.clearProfilePending -- 28
local profilePending = ____save.profilePending -- 28
local loadSession = ____save.loadSession -- 29
local saveSession = ____save.saveSession -- 29
local clearSession = ____save.clearSession -- 29
local hasSessionSave = ____save.hasSessionSave -- 29
local setSessionFile = ____save.setSessionFile -- 29
local getSessionFile = ____save.getSessionFile -- 29
function isReleaseBuild() -- 90
	return isReleaseMode() -- 91
end -- 91
function onFirstUserGesture() -- 94
	if audioUnlocked or fe == nil then -- 94
		return -- 96
	end -- 96
	audioUnlocked = true -- 98
	fe.audio:unlockAndResyncAfterGesture() -- 99
end -- 99
function toggleFullscreen() -- 102
	if not canToggleFullscreen() then -- 102
		return false -- 104
	end -- 104
	do -- 104
		local function ____catch() -- 104
			return true, false -- 111
		end -- 111
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 111
			local next = not App.fullScreen -- 107
			App.fullScreen = next -- 108
			return true, next -- 109
		end) -- 109
		if not ____try then -- 109
			____hasReturned, ____returnValue = ____catch() -- 109
		end -- 109
		if ____hasReturned then -- 109
			return ____returnValue -- 106
		end -- 106
	end -- 106
end -- 106
function quitGame() -- 115
	flushProfile() -- 116
	saveCurrentSession() -- 117
	if input ~= nil then -- 117
		input:clearTransient(false) -- 118
	end -- 118
	if fe ~= nil then -- 118
		fe.audio:stopRoomTransient() -- 120
	end -- 120
	if not canQuitApp() then -- 120
		current = 0 -- 124
		play = nil -- 125
		run = nil -- 126
		setMode(1) -- 127
		if fe ~= nil then -- 127
			fe.audio:stopRoomTransient() -- 129
			fe.screen = "title" -- 130
			fe.menus:resetInput() -- 131
		end -- 131
		return -- 133
	end -- 133
	App:shutdown() -- 135
end -- 135
function canSaveSession() -- 207
	if mode ~= 1 or play == nil or storyRun == nil then -- 207
		return false -- 209
	end -- 209
	if storyRun.source ~= "official" or play.run.finished then -- 209
		return false -- 212
	end -- 212
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 212
		return false -- 215
	end -- 215
	return true -- 217
end -- 217
function refreshTitleSessionFlag() -- 220
	if fe ~= nil then -- 220
		fe.menus.hasSession = hasSessionSave() -- 222
	end -- 222
end -- 222
function saveCurrentSession() -- 226
	if not canSaveSession() or play == nil then -- 226
		return false -- 228
	end -- 228
	play.sessionDirty = false -- 230
	local ok = saveSession(play:exportSession()) -- 231
	refreshTitleSessionFlag() -- 232
	return ok -- 233
end -- 233
function continueOfficialStory() -- 236
	local res = loadSession() -- 237
	if res.status ~= "ok" or res.state == nil then -- 237
		refreshTitleSessionFlag() -- 239
		return nil -- 240
	end -- 240
	local s = res.state -- 242
	local idx = roomIndexByKey(s.roomKey) -- 243
	if ROOMS[idx + 1].key ~= s.roomKey then -- 243
		return nil -- 245
	end -- 245
	storyRun = createRun(s.seed, "official", profile) -- 247
	storyRun.checkpoint = s.checkpoint -- 248
	storyRun.story.route = s.route -- 249
	storyRun.story.hp = s.hp -- 250
	storyRun.story.maxHp = s.maxHp -- 251
	storyRun.story.hpAtGate = s.hpAtGate -- 252
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 253
	storyRun.story.settled = s.settled -- 254
	storyRun.story.phase = s.phase -- 255
	storyRun.story.countTick = s.countTick -- 256
	storyRun.story.phaseTick = s.phaseTick -- 257
	storyRun.story.handTicks = s.handTicks -- 258
	storyRun.story.handDone = s.handDone -- 259
	storyRun.story.lineSaid = s.lineSaid -- 260
	storyRun.story.tied = s.tied -- 261
	storyRun.story.carry = s.carry -- 262
	storyRun.story.escortDone = s.escortDone -- 263
	storyRun.story.craftedWeapon = s.craftedWeapon -- 264
	storyRun.story.equippedWeapon = s.equippedWeapon -- 265
	storyRun.inventory.wood = s.wood -- 266
	storyRun.inventory.bell = s.bell -- 267
	storyRun.inventory.scrap = s.scrap -- 268
	storyRun.inventory.wedge = s.wedge -- 269
	storyRun.inventory.ammo = s.ammo -- 270
	storyRun.inventory.shield = s.shield -- 271
	storyRun.inventory.pass = s.pass -- 272
	storyRun.inventory.quickbelt = s.quickbelt -- 273
	local k = 0 -- 274
	do -- 274
		k = 0 -- 275
		while k < #s.taken do -- 275
			storyRun.taken[s.taken[k + 1]] = true -- 276
			k = k + 1 -- 275
		end -- 275
	end -- 275
	do -- 275
		k = 0 -- 278
		while k < #s.segments do -- 278
			storyRun.story.segments[s.segments[k + 1]] = true -- 279
			k = k + 1 -- 278
		end -- 278
	end -- 278
	if s.campaignRoute ~= nil then -- 278
		storyRun.route = s.campaignRoute -- 282
	end -- 282
	if s.joined ~= nil then -- 282
		storyRun.joined = s.joined -- 285
	end -- 285
	if s.c1Latch ~= nil then -- 285
		storyRun.c1Latch = s.c1Latch -- 288
	end -- 288
	if s.c2Latch ~= nil then -- 288
		storyRun.c2Latch = s.c2Latch -- 291
	end -- 291
	if s.props ~= nil then -- 291
		do -- 291
			k = 0 -- 294
			while k < #s.props do -- 294
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 295
				local pid = parts[1] -- 296
				if pid ~= nil and pid ~= "" then -- 296
					local ____storyRun_props_16 = storyRun.props -- 298
					local ____temp_12 -- 299
					if parts[2] == nil then -- 299
						____temp_12 = true -- 299
					else -- 299
						____temp_12 = parts[2] == "1" -- 299
					end -- 299
					local ____temp_14 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 300
					local ____temp_15 = parts[4] == "1" -- 301
					local ____temp_13 -- 302
					if parts[5] == "1" then -- 302
						____temp_13 = true -- 302
					else -- 302
						____temp_13 = nil -- 302
					end -- 302
					____storyRun_props_16[pid] = {broken = ____temp_12, hp = ____temp_14, wedge = ____temp_15, revealed = ____temp_13} -- 298
				end -- 298
				k = k + 1 -- 294
			end -- 294
		end -- 294
	end -- 294
	local stTalents = createStoryTalents(s.seed) -- 307
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 307
		stTalents.randomState = s.talentSeed -- 309
	end -- 309
	stTalents.room = s.talentRoom or "" -- 311
	stTalents.ranks.vitality = s.talentVitality or 0 -- 312
	stTalents.ranks.reload = s.talentReload or 0 -- 313
	stTalents.ranks.guard = s.talentGuard or 0 -- 314
	stTalents.ranks.craft = s.talentCraft or 0 -- 315
	if s.talentOffers ~= nil then -- 315
		do -- 315
			k = 0 -- 317
			while k < #s.talentOffers do -- 317
				local t = s.talentOffers[k + 1] -- 318
				if t == "vitality" or t == "reload" or t == "guard" or t == "craft" then -- 318
					local ____stTalents_offers_17 = stTalents.offers -- 318
					____stTalents_offers_17[#____stTalents_offers_17 + 1] = t -- 320
				end -- 320
				k = k + 1 -- 317
			end -- 317
		end -- 317
	end -- 317
	storyRun.story.talents = stTalents -- 324
	current = idx -- 325
	setMode(1) -- 326
	if fe ~= nil then -- 326
		fe.screen = "play" -- 328
	end -- 328
	play = nil -- 330
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 331
	local cur = play -- 332
	if cur ~= nil then -- 332
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 332
			cur.cartAxle = s.cartAxle -- 335
			cur.cartDocked = s.cartDocked -- 336
		end -- 336
		if s.playerX ~= nil and s.playerX >= 0 then -- 336
			cur.player.x = math.max( -- 339
				cur.room.minX + 16, -- 339
				math.min(cur.room.maxX - 16, s.playerX) -- 339
			) -- 339
			cur.player.y = math.max(0, s.playerY or 0) -- 340
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 340
				cur.player.depth = math.max( -- 342
					cur.room.depth.min, -- 342
					math.min(cur.room.depth.max, s.playerDepth) -- 342
				) -- 342
			end -- 342
		end -- 342
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 342
			cur.gateTick = s.gateTick -- 346
		end -- 346
		if cur.room.key == "village" then -- 346
			if s.hasBottle == true then -- 346
				cur.hasBottle = true -- 349
			end -- 349
			if s.villagePassed == true then -- 349
				cur.passed = true -- 350
			end -- 350
		end -- 350
	end -- 350
	return play -- 353
end -- 353
function place(lb, x, y, ax, ay) -- 371
	if lb == nil then -- 371
		return -- 373
	end -- 373
	lb.position = Vec2(x, y) -- 375
	lb.anchor = Vec2(ax, ay) -- 376
	lb.visible = true -- 377
end -- 377
function setMode(nextMode) -- 719
	mode = nextMode -- 720
	if grayboxLayer ~= nil then -- 720
		grayboxLayer.visible = mode == 0 -- 722
	end -- 722
	if fe ~= nil then -- 722
		fe:setVisible(mode == 1) -- 725
	end -- 725
	if campaignLayer ~= nil then -- 725
		campaignLayer.visible = mode == 2 -- 728
	end -- 728
	dirty = true -- 730
	clock:reset() -- 731
end -- 731
function flushProfile() -- 738
	local cur = play -- 739
	if cur ~= nil and cur.archiveDirty then -- 739
		cur.archiveDirty = false -- 741
		markProfilePending(profile) -- 742
	end -- 742
	local ok = flushSaveProfile() -- 744
	if not ok and cur ~= nil then -- 744
		cur.archiveDirty = true -- 746
	end -- 746
	return ok -- 748
end -- 748
function officialStartIndex() -- 752
	local mp = profile.museumPhase -- 753
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 754
	return inMuseum and roomIndexByKey("museum") or 0 -- 755
end -- 755
function roomIndexByKey(key) -- 758
	local i = 0 -- 759
	do -- 759
		i = 0 -- 760
		while i < #ROOMS do -- 760
			if ROOMS[i + 1].key == key then -- 760
				return i -- 762
			end -- 762
			i = i + 1 -- 760
		end -- 760
	end -- 760
	return 0 -- 765
end -- 765
function enterPlayRoom(idx, source, fresh) -- 768
	if source == nil then -- 768
		source = "debug" -- 768
	end -- 768
	if fresh == nil then -- 768
		fresh = false -- 768
	end -- 768
	current = idx -- 769
	setMode(1) -- 770
	if fe ~= nil then -- 770
		fe.screen = "play" -- 772
	end -- 772
	play = nil -- 774
	if fresh or source == "chapter" or storyRun == nil then -- 774
		storyRun = createRun(20261124, source, profile) -- 777
	else -- 777
		storyRun.source = source -- 779
	end -- 779
	ensurePlay() -- 781
	local firstPlay = play -- 783
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 783
		firstPlay.phase = "prologue-wake" -- 785
	end -- 785
	flushProfile() -- 787
end -- 787
function pickByIndex(idx, source) -- 790
	if source == nil then -- 790
		source = "debug" -- 790
	end -- 790
	if mode == 2 then -- 790
		if idx < 0 or idx >= #CAMPAIGN_ROOMS then -- 790
			return -- 793
		end -- 793
		current = idx -- 795
		play = nil -- 796
		clock:reset() -- 797
		ensurePlay() -- 798
		return -- 799
	end -- 799
	if idx < 0 or idx >= #ROOMS then -- 799
		return -- 802
	end -- 802
	flushProfile() -- 804
	if storyRun ~= nil then -- 804
		storyRun.source = source -- 806
	end -- 806
	current = idx -- 808
	dirty = true -- 809
	play = nil -- 810
	clock:reset() -- 811
	if mode == 1 then -- 811
		if fe ~= nil then -- 811
			fe.screen = "play" -- 814
		end -- 814
		ensurePlay() -- 816
	end -- 816
end -- 816
function applySize() -- 820
	if root == nil then -- 820
		return -- 822
	end -- 822
	root.size = Size(viewW, viewH) -- 824
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 825
	stageVp = computeStageViewport(viewW, viewH) -- 826
	if input ~= nil then -- 826
		input:setStageViewport(stageVp) -- 828
	end -- 828
	if fe ~= nil then -- 828
		fe:setStagePlacement(stageVp) -- 831
	end -- 831
	if campaignLayer ~= nil then -- 831
		campaignLayer.position = Vec2(stageVp.stageX, stageVp.stageY) -- 834
	end -- 834
	if grayboxLayer ~= nil then -- 834
		grayboxLayer.position = Vec2(0, 0) -- 837
	end -- 837
end -- 837
function syncFrameAdapters(frameDt) -- 841
	if input == nil then -- 841
		return -- 843
	end -- 843
	local target = input.target -- 845
	if not target.supportsTouch and not target.supportsGamepad then -- 845
		return -- 847
	end -- 847
	local p = play -- 849
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 850
	local storyTalentBoxes = target.supportsTouch and isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 851
		p, -- 853
		stageVp.stageW, -- 853
		stageVp.stageH, -- 853
		input:isTouchMode() -- 853
	) or ({}) -- 853
	local isFs = false -- 856
	if target:canToggleFullscreen() then -- 856
		do -- 856
			local function ____catch() -- 856
				isFs = false -- 861
			end -- 861
			local ____try = pcall(function() -- 861
				isFs = App.fullScreen -- 859
			end) -- 859
			if not ____try then -- 859
				____catch() -- 859
			end -- 859
		end -- 859
	end -- 859
	local ____input_62 = input -- 864
	local ____input_syncFrame_63 = input.syncFrame -- 864
	local ____stageVp_57 = stageVp -- 865
	local ____mode_58 = mode -- 866
	local ____temp_59 = fe ~= nil and fe.screen or "title" -- 867
	local ____run_60 = run -- 869
	local ____isPlayMode_54 -- 871
	if isPlayMode then -- 871
		____isPlayMode_54 = fe and fe.cam -- 871
	else -- 871
		____isPlayMode_54 = nil -- 871
	end -- 871
	local ____input_61 = input -- 872
	local ____temp_55 -- 873
	if fe ~= nil then -- 873
		____temp_55 = fe.contract:isAssistHintsEnabled() -- 873
	else -- 873
		____temp_55 = false -- 873
	end -- 873
	local ____temp_56 -- 874
	if fe ~= nil then -- 874
		____temp_56 = fe.audio:isAllMuted() -- 874
	else -- 874
		____temp_56 = false -- 874
	end -- 874
	____input_syncFrame_63(____input_62, { -- 864
		viewport = ____stageVp_57, -- 865
		mode = ____mode_58, -- 866
		screen = ____temp_59, -- 867
		play = p, -- 868
		run = ____run_60, -- 869
		cam = ____isPlayMode_54, -- 871
		input = ____input_61, -- 872
		assistHintsEnabled = ____temp_55, -- 873
		isMuted = ____temp_56, -- 874
		isFullscreen = isFs, -- 875
		storyTalentBoxes = storyTalentBoxes, -- 876
		dt = frameDt -- 877
	}) -- 877
end -- 877
function renderTouchOverlay() -- 881
	if input ~= nil then -- 881
		input:renderOverlay() -- 882
	end -- 882
end -- 882
function tick(frameDt) -- 885
	appClock = appClock + math.min( -- 886
		0.05, -- 886
		math.max(0, frameDt) -- 886
	) -- 886
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 887
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 888
	if w ~= viewW or h ~= viewH then -- 888
		viewW = w -- 890
		viewH = h -- 891
		applySize() -- 892
		dirty = true -- 893
	end -- 893
	if input == nil then -- 893
		return -- 896
	end -- 896
	syncFrameAdapters(frameDt) -- 898
	input:update() -- 899
	if input.userInteracted then -- 899
		onFirstUserGesture() -- 902
	end -- 902
	if input.muteTogglePressed and fe ~= nil then -- 902
		input.muteTogglePressed = false -- 905
		fe.audio:toggleAllMuted() -- 906
	end -- 906
	if input.fullscreenTogglePressed then -- 906
		input.fullscreenTogglePressed = false -- 909
		toggleFullscreen() -- 910
	end -- 910
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 910
		input.artifactTogglePressed = false -- 913
		play:toggleArtifactWeapon() -- 914
	end -- 914
	if input.bottleCanceled and play ~= nil then -- 914
		input.bottleCanceled = false -- 917
		play.aimHold = 0 -- 918
		play.bottleAimX = -1 -- 919
	end -- 919
	if mode == 2 and (run and run.trial) ~= nil then -- 919
		tickCampaign(frameDt) -- 923
		renderTouchOverlay() -- 924
		return -- 925
	end -- 925
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 925
		play:chooseTalent(input.pickRoom - 1) -- 931
		input.pickRoom = 0 -- 932
	end -- 932
	if isReleaseBuild() then -- 932
		input.toggleView.pressed = false -- 936
		input.pickRoom = 0 -- 937
		input.tab.pressed = false -- 938
	else -- 938
		if input.toggleView.pressed then -- 938
			input.toggleView.pressed = false -- 942
			setMode(mode == 0 and 1 or (mode == 1 and 2 or 0)) -- 943
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 943
				ensurePlay() -- 945
			end -- 945
		end -- 945
		if input.pickRoom ~= 0 then -- 945
			local idx = input.pickRoom - 1 -- 951
			input.pickRoom = 0 -- 952
			pickByIndex(idx) -- 953
		elseif input.tab.pressed then -- 953
			input.tab.pressed = false -- 955
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 955
				pickByIndex((current + 1) % #ROOMS) -- 957
			end -- 957
		end -- 957
	end -- 957
	if mode == 2 then -- 957
		tickCampaign(frameDt) -- 963
	elseif mode == 1 then -- 963
		tickFrontend(frameDt) -- 965
	elseif dirty then -- 965
		redrawGraybox() -- 967
		dirty = false -- 968
	end -- 968
	renderTouchOverlay() -- 970
end -- 970
function registerPlay() -- 974
	local reg = _G.package.loaded -- 975
	reg["watch.play"] = play -- 976
	local rooms = mode == 2 and CAMPAIGN_ROOMS or ROOMS -- 977
	reg["watch.room"] = rooms[current + 1].key -- 978
end -- 978
function ensurePlay(resume) -- 982
	if mode == 2 then -- 982
		if run == nil then -- 982
			run = createRun() -- 985
		end -- 985
		play = __TS__New(Play, CAMPAIGN_ROOMS[current + 1], nil, run) -- 987
	else -- 987
		if storyRun == nil then -- 987
			storyRun = createRun(20261124, "debug", profile) -- 992
		end -- 992
		play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 994
	end -- 994
	registerPlay() -- 996
	clock:reset() -- 997
	if fe ~= nil and mode == 1 then -- 997
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 999
	elseif fe ~= nil and mode == 2 then -- 999
		fe:resetTrialAudio(play) -- 1001
	end -- 1001
end -- 1001
function startTrial() -- 1005
	current = 0 -- 1006
	trialTalentSelected = 0 -- 1007
	run = createTrial(App.rand) -- 1008
	setMode(2) -- 1009
	ensurePlay() -- 1010
end -- 1010
function tickCampaign(frameDt) -- 1013
	if input == nil then -- 1013
		return -- 1015
	end -- 1015
	if play == nil then -- 1015
		ensurePlay() -- 1018
	end -- 1018
	if play == nil then -- 1018
		return -- 1021
	end -- 1021
	local p = play -- 1023
	p.aimX = input.mx -- 1024
	p.aimY = input.my -- 1025
	local zoneTap = input.touchZoneTap -- 1027
	input.touchZoneTap = "" -- 1028
	local trial = run and run.trial -- 1030
	if trial ~= nil then -- 1030
		local ended = trial.lost or (run and run.finished) == true -- 1032
		local pick = input.pickRoom -- 1033
		input.pickRoom = 0 -- 1034
		if zoneTap == "trial:resume" and p.paused and not ended then -- 1034
			p.paused = false -- 1037
			clock:reset() -- 1038
			input:consumeEdges() -- 1039
			drawCampaign(p) -- 1040
			return -- 1041
		end -- 1041
		if zoneTap == "trial:retry" then -- 1041
			input:consumeEdges() -- 1044
			startTrial() -- 1045
			return -- 1046
		end -- 1046
		if zoneTap == "trial:title" then -- 1046
			input:consumeEdges() -- 1049
			current = 0 -- 1050
			play = nil -- 1051
			run = nil -- 1052
			setMode(1) -- 1053
			if fe ~= nil then -- 1053
				fe.audio:stopRoomTransient() -- 1055
				fe.screen = "title" -- 1056
				fe.menus:resetInput() -- 1057
			end -- 1057
			return -- 1059
		end -- 1059
		if ended and (input.pause.pressed or input.navBack) or p.paused and input.interact.pressed then -- 1059
			input:consumeEdges() -- 1063
			current = 0 -- 1064
			play = nil -- 1065
			run = nil -- 1066
			setMode(1) -- 1067
			if fe ~= nil then -- 1067
				fe.audio:stopRoomTransient() -- 1069
				fe.screen = "title" -- 1070
				fe.menus:resetInput() -- 1071
			end -- 1071
			return -- 1073
		end -- 1073
		if ended or p.paused and input.retry.pressed then -- 1073
			local restart = input.retry.pressed or ended and input.navConfirm -- 1076
			input:consumeEdges() -- 1077
			if restart then -- 1077
				startTrial() -- 1078
			else -- 1078
				drawCampaign(p) -- 1079
			end -- 1079
			return -- 1080
		end -- 1080
		input.retry.pressed = false -- 1082
		if #trial.offers > 0 and not p.paused and not input.pause.pressed then -- 1082
			if trialTalentSelected >= #trial.offers then -- 1082
				trialTalentSelected = 0 -- 1085
			end -- 1085
			if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1085
				local idx = __TS__ParseInt( -- 1088
					string.sub(zoneTap, 8), -- 1088
					10 -- 1088
				) -- 1088
				if idx >= 0 and idx < #trial.offers then -- 1088
					p:chooseTalent(idx) -- 1090
				end -- 1090
			elseif pick > 0 then -- 1090
				p:chooseTalent(pick - 1) -- 1093
			else -- 1093
				local delta = input.talentDelta + ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) -- 1095
				if delta ~= 0 then -- 1095
					trialTalentSelected = (trialTalentSelected + delta + #trial.offers) % #trial.offers -- 1099
				end -- 1099
				if input.talentConfirm or input.navConfirm then -- 1099
					p:chooseTalent(trialTalentSelected) -- 1102
				end -- 1102
			end -- 1102
			input:consumeEdges() -- 1105
			clock:reset() -- 1106
			if fe ~= nil then -- 1106
				fe:syncTrialAudio(frameDt, p, #trial.offers) -- 1107
			end -- 1107
			drawCampaign(p) -- 1108
			return -- 1109
		end -- 1109
	end -- 1109
	if input.retry.pressed then -- 1109
		input.retry.pressed = false -- 1114
		input:consumeEdges() -- 1115
		play = nil -- 1117
		ensurePlay() -- 1118
		return -- 1119
	end -- 1119
	if input.pause.pressed or p.paused and input.navBack then -- 1119
		input.pause.pressed = false -- 1122
		p.paused = not p.paused -- 1123
		if fe ~= nil then -- 1123
			fe.audio:playUi(p.paused and "ui:pause_open" or "ui:pause_close", p.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 1124
		end -- 1124
		clock:reset() -- 1125
		input:consumeEdges() -- 1126
	end -- 1126
	if p.paused then -- 1126
		if fe ~= nil then -- 1126
			fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1129
		end -- 1129
		drawCampaign(p) -- 1130
		return -- 1131
	end -- 1131
	local steps = clock:advance(frameDt) -- 1134
	local i = 0 -- 1135
	do -- 1135
		i = 0 -- 1136
		while i < steps do -- 1136
			input:beginStep(i == 0) -- 1137
			p:update(STEP, input) -- 1138
			input:endStep() -- 1139
			if p.wantRoom ~= "" or trial and trial.lost or trial ~= nil and (run and run.finished) then -- 1139
				break -- 1141
			end -- 1141
			i = i + 1 -- 1136
		end -- 1136
	end -- 1136
	if fe ~= nil then -- 1136
		fe:syncTrialAudio(frameDt, p, trial and #trial.offers or 0) -- 1144
	end -- 1144
	if p.wantRoom ~= "" then -- 1144
		local key = p.wantRoom -- 1147
		p.wantRoom = "" -- 1148
		local idx = -1 -- 1149
		local j = 0 -- 1150
		do -- 1150
			j = 0 -- 1151
			while j < #CAMPAIGN_ROOMS do -- 1151
				if CAMPAIGN_ROOMS[j + 1].key == key then -- 1151
					idx = j -- 1153
				end -- 1153
				j = j + 1 -- 1151
			end -- 1151
		end -- 1151
		if idx >= 0 then -- 1151
			current = idx -- 1157
			play = nil -- 1158
			ensurePlay() -- 1159
		end -- 1159
		return -- 1161
	end -- 1161
	drawCampaign(p) -- 1163
end -- 1163
function goalLabel(goal) -- 1166
	if goal == "dock_cart" then -- 1166
		return "推车入窝并抬闩" -- 1168
	end -- 1168
	if goal == "raise_latch" then -- 1168
		return "抬闩开侧门" -- 1171
	end -- 1171
	return "到段出口" -- 1173
end -- 1173
function drawCampaign(p) -- 1176
	if campaignDraw == nil then -- 1176
		return -- 1178
	end -- 1178
	local w = stageVp.stageW -- 1180
	local h = stageVp.stageH -- 1181
	local safeL = stageVp.safeUi.left * stageVp.uiScale -- 1182
	local safeT = stageVp.safeUi.top * stageVp.uiScale -- 1183
	p:draw(campaignDraw, w, h) -- 1184
	local room = CAMPAIGN_ROOMS[current + 1] -- 1185
	local c = room.campaign -- 1186
	local r = run -- 1187
	local line = room.name -- 1188
	if c ~= nil then -- 1188
		line = ((((((((line .. "  ") .. c.chapter) .. tostring(c.act)) .. " · 目标 ") .. goalLabel(c.goal)) .. " · 本段 ") .. mmss(r == nil and 0 or (r.roomTicks[room.key] or 0))) .. " / 预算 ") .. mmss(c.budget * 60) -- 1190
	end -- 1190
	if p.paused then -- 1190
		line = line .. "  · 已暂停 Esc 继续" -- 1194
	end -- 1194
	local trial = r and r.trial -- 1196
	if trial ~= nil and r ~= nil then -- 1196
		line = (((((("护送试炼 · " .. room.name) .. " · 体力 ") .. tostring(p.hp)) .. "/") .. tostring(p.maxHp)) .. " · ") .. mmss(r.ticks) -- 1198
		if p.paused then -- 1198
			line = line .. " · 暂停" -- 1199
		elseif trial.lost then -- 1199
			line = line .. " · 护送失败" -- 1200
		elseif r.finished then -- 1200
			line = line .. " · 护送完成" -- 1201
		elseif #trial.offers > 0 then -- 1201
			line = line .. " · 选择本段本领" -- 1202
		elseif c ~= nil then -- 1202
			line = line .. " · " .. goalLabel(c.goal) -- 1203
		end -- 1203
	end -- 1203
	if campaignHud ~= nil then -- 1203
		campaignHud.text = line -- 1206
		campaignHud.position = Vec2(24 + safeL, h - 14 - safeT) -- 1207
		campaignHud.visible = true -- 1208
	end -- 1208
	if campaignSub ~= nil then -- 1208
		local sub = "总 " .. mmss(r == nil and 0 or r.ticks) -- 1211
		if r ~= nil then -- 1211
			local route = r.route == "drygoods" and "布行" or (r.route == "outer" and "外檐" or "未定") -- 1213
			sub = (((((((((((((sub .. " · 路线 ") .. route) .. " · 盾") .. tostring(r.inventory.shield)) .. " 楔") .. tostring(r.inventory.wedge)) .. " 弹") .. tostring(r.inventory.ammo)) .. " 牌") .. tostring(r.inventory.pass)) .. " 带") .. tostring(r.inventory.quickbelt)) .. " · ") .. (r.joined and "小满跟随" or "小满等待") -- 1214
		end -- 1214
		if p.flash ~= "" then -- 1214
			sub = (sub .. " · ") .. p.flash -- 1220
		end -- 1220
		if trial ~= nil and r ~= nil then -- 1220
			local gpMode = input ~= nil and input:isGamepadMode() -- 1223
			local curMode = input ~= nil and input.inputMode or getActiveTarget().defaultInputMode -- 1224
			if trial.lost or r.finished then -- 1224
				sub = getActiveTarget():trialSubHint(curMode, true, r.seed) -- 1226
			elseif p.paused then -- 1226
				sub = getActiveTarget():trialSubHint(curMode, false, r.seed) -- 1228
			elseif #trial.offers > 0 then -- 1228
				sub = table.concat( -- 1230
					__TS__ArrayMap( -- 1230
						trial.offers, -- 1230
						function(____, talent, index) -- 1230
							local mark = gpMode and index == trialTalentSelected and "▶ " or "" -- 1231
							return ((mark .. tostring(index + 1)) .. " ") .. talentNames[talent] -- 1232
						end -- 1230
					), -- 1230
					"　" -- 1233
				) -- 1233
			else -- 1233
				sub = (((((((("厚甲" .. tostring(trial.ranks.vitality)) .. " 熟铳") .. tostring(trial.ranks.reload)) .. " 护身") .. tostring(trial.ranks.guard)) .. " 巧手") .. tostring(trial.ranks.craft)) .. " · ") .. (p.flash ~= "" and p.flash or (r.joined and "小满跟随" or "小满等待")) -- 1235
			end -- 1235
		end -- 1235
		campaignSub.text = sub -- 1238
		campaignSub.position = Vec2(24 + safeL, h - 44 - safeT) -- 1239
		campaignSub.visible = true -- 1240
	end -- 1240
end -- 1240
function tickFrontend(frameDt) -- 1244
	if fe == nil or input == nil then -- 1244
		return -- 1246
	end -- 1246
	if fe.screen ~= "play" then -- 1246
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1251
		input:consumeEdges() -- 1252
		if act.type == "splashDone" then -- 1252
			fe.menus:resetInput() -- 1254
			fe.screen = "title" -- 1255
		elseif act.type == "trial" then -- 1255
			startTrial() -- 1257
		elseif act.type == "continue" then -- 1257
			if continueOfficialStory() == nil then -- 1257
				enterPlayRoom( -- 1260
					officialStartIndex(), -- 1260
					"official", -- 1260
					true -- 1260
				) -- 1260
			end -- 1260
		elseif act.type == "start" then -- 1260
			clearSession() -- 1264
			refreshTitleSessionFlag() -- 1265
			enterPlayRoom( -- 1266
				officialStartIndex(), -- 1266
				"official", -- 1266
				true -- 1266
			) -- 1266
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1266
			enterPlayRoom(act.roomIndex, "chapter") -- 1268
		elseif act.type == "openChapters" then -- 1268
			fe.menus:openChapters() -- 1270
			fe.screen = "chapters" -- 1271
		elseif act.type == "openControls" then -- 1271
			fe.menus:resetInput() -- 1273
			fe.screen = "controls" -- 1274
		elseif act.type == "openHistory" then -- 1274
			fe.menus:openHistory(true) -- 1276
			fe.screen = "history" -- 1277
		elseif act.type == "backEpilogue" then -- 1277
			fe.menus:resetInput() -- 1279
			fe.screen = "epilogue" -- 1280
		elseif act.type == "replayStory" then -- 1280
			clearSession() -- 1282
			refreshTitleSessionFlag() -- 1283
			enterPlayRoom( -- 1284
				officialStartIndex(), -- 1284
				"official", -- 1284
				true -- 1284
			) -- 1284
		elseif act.type == "backTitle" then -- 1284
			fe.menus:resetInput() -- 1286
			fe.screen = "title" -- 1287
		elseif act.type == "backPause" then -- 1287
			fe.menus:resetInput() -- 1289
			fe.screen = "play" -- 1290
		elseif act.type == "quit" then -- 1290
			quitGame() -- 1292
		end -- 1292
		return -- 1294
	end -- 1294
	if play == nil then -- 1294
		ensurePlay() -- 1299
	end -- 1299
	if play == nil then -- 1299
		return -- 1302
	end -- 1302
	local p = play -- 1304
	p.aimX = input.mx -- 1306
	p.aimY = input.my -- 1307
	local zoneTap = input.touchZoneTap -- 1309
	input.touchZoneTap = "" -- 1310
	local offers = p:getStoryTalentOffers() -- 1312
	if not p.paused and not p.craftBench.active and not p.reloadOpen and #offers > 0 then -- 1312
		if fe.hud.talentSelected >= #offers then -- 1312
			fe.hud.talentSelected = 0 -- 1315
		end -- 1315
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1315
			local idx = __TS__ParseInt( -- 1318
				string.sub(zoneTap, 8), -- 1318
				10 -- 1318
			) -- 1318
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1318
				input.fire.pressed = false -- 1320
			end -- 1320
		else -- 1320
			if input.talentDelta ~= 0 then -- 1320
				fe.hud.talentSelected = (fe.hud.talentSelected + input.talentDelta + #offers) % #offers -- 1324
				input.talentDelta = 0 -- 1325
			end -- 1325
			if input.talentConfirm then -- 1325
				p:chooseTalent(fe.hud.talentSelected) -- 1328
				input.talentConfirm = false -- 1329
				input.fire.pressed = false -- 1330
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1330
				input.fire.pressed = false -- 1333
			end -- 1333
		end -- 1333
	end -- 1333
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1333
		if input.navConfirm then -- 1333
			input.interact.pressed = true -- 1341
		end -- 1341
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1341
			flushProfile() -- 1344
			if p.run.source == "official" and hasSessionSave() then -- 1344
				clearSession() -- 1346
				refreshTitleSessionFlag() -- 1347
			end -- 1347
			fe.audio:stopRoomTransient() -- 1349
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1350
			fe.screen = "epilogue" -- 1354
			input:clearTransient(true) -- 1355
			input:consumeEdges() -- 1356
			return -- 1357
		end -- 1357
	end -- 1357
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1357
		p:closeCraftBench() -- 1362
		input:consumeEdges() -- 1363
		return -- 1364
	end -- 1364
	if not p.paused and input.pause.pressed then -- 1364
		p.paused = true -- 1367
		p.aimHold = 0 -- 1368
		p.bottleAimX = -1 -- 1369
		saveCurrentSession() -- 1370
		fe.menus:openPause() -- 1371
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1372
		input:clearTransient(true) -- 1373
		input:consumeEdges() -- 1374
	end -- 1374
	if p.paused then -- 1374
		clock:reset() -- 1379
		local pauseAct = fe:renderPlay( -- 1380
			frameDt, -- 1380
			p, -- 1380
			input, -- 1380
			stageVp.stageW, -- 1380
			stageVp.stageH -- 1380
		) -- 1380
		input:consumeEdges() -- 1381
		if pauseAct.type == "resume" then -- 1381
			p.paused = false -- 1383
		elseif pauseAct.type == "retry" then -- 1383
			ensurePlay({checkpoint = p.checkpoint}) -- 1385
		elseif pauseAct.type == "openChapters" then -- 1385
			fe.audio:stopRoomTransient() -- 1387
			fe.audio:setPaused(false) -- 1388
			fe.menus:openChapters(current) -- 1389
			fe.screen = "chapters" -- 1390
		elseif pauseAct.type == "toggleFullscreen" then -- 1390
			toggleFullscreen() -- 1392
		elseif pauseAct.type == "quit" then -- 1392
			quitGame() -- 1394
		elseif pauseAct.type == "toTitle" then -- 1394
			saveCurrentSession() -- 1396
			refreshTitleSessionFlag() -- 1397
			fe.menus:resetInput() -- 1398
			fe.screen = "title" -- 1399
		end -- 1399
		return -- 1401
	end -- 1401
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1404
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1405
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen then -- 1405
		input:consumeEdges() -- 1408
		ensurePlay({checkpoint = p.checkpoint}) -- 1410
		return -- 1411
	end -- 1411
	local steps = clock:advance(frameDt) -- 1414
	local i = 0 -- 1415
	do -- 1415
		i = 0 -- 1416
		while i < steps do -- 1416
			input:beginStep(i == 0) -- 1417
			p:update(STEP, input) -- 1418
			input:endStep() -- 1419
			if p.wantRoom ~= "" then -- 1419
				break -- 1421
			end -- 1421
			i = i + 1 -- 1416
		end -- 1416
	end -- 1416
	if p.wantRoom ~= "" then -- 1416
		local key = p.wantRoom -- 1427
		p.wantRoom = "" -- 1428
		local idx = -1 -- 1429
		local j = 0 -- 1430
		do -- 1430
			j = 0 -- 1431
			while j < #ROOMS do -- 1431
				if ROOMS[j + 1].key == key then -- 1431
					idx = j -- 1433
				end -- 1433
				j = j + 1 -- 1431
			end -- 1431
		end -- 1431
		if idx >= 0 then -- 1431
			flushProfile() -- 1440
			local leaving = p:drainEvents() -- 1441
			if p.restartStory then -- 1441
				if storyRun ~= nil and storyRun.source == "official" then -- 1441
					clearSession() -- 1445
					refreshTitleSessionFlag() -- 1446
				end -- 1446
				local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1448
				storyRun = createRun(20261124, nextSource, profile) -- 1449
			end -- 1449
			current = idx -- 1451
			ensurePlay() -- 1452
			local fresh = play -- 1453
			if fresh ~= nil then -- 1453
				if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1453
					fresh.phase = "prologue-wake" -- 1456
				end -- 1456
				fresh:adoptEvents(leaving) -- 1458
			end -- 1458
			if not p.restartStory then -- 1458
				saveCurrentSession() -- 1461
			end -- 1461
			clock:reset() -- 1463
			dirty = true -- 1464
		end -- 1464
		return -- 1466
	end -- 1466
	flushProfile() -- 1470
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1470
		clearSession() -- 1472
		refreshTitleSessionFlag() -- 1473
	elseif p.sessionDirty then -- 1473
		saveCurrentSession() -- 1475
	end -- 1475
	fe:renderPlay( -- 1477
		frameDt, -- 1477
		p, -- 1477
		input, -- 1477
		stageVp.stageW, -- 1477
		stageVp.stageH -- 1477
	) -- 1477
end -- 1477
function redrawGraybox() -- 1481
	if draw == nil then -- 1481
		return -- 1483
	end -- 1483
	local w = viewW -- 1485
	local h = viewH -- 1486
	local room = ROOMS[current + 1] -- 1487
	draw:clear() -- 1489
	draw:drawRect( -- 1490
		Rect(0, h - TOP_H, w, TOP_H), -- 1490
		C_BG -- 1490
	) -- 1490
	draw:drawRect( -- 1491
		Rect(0, 0, w, BOTTOM_H), -- 1491
		C_BG -- 1491
	) -- 1491
	draw:drawSegment( -- 1492
		Vec2(0, h - TOP_H), -- 1492
		Vec2(w, h - TOP_H), -- 1492
		1, -- 1492
		Color(52, 54, 54, 255) -- 1492
	) -- 1492
	draw:drawSegment( -- 1493
		Vec2(0, BOTTOM_H), -- 1493
		Vec2(w, BOTTOM_H), -- 1493
		1, -- 1493
		Color(52, 54, 54, 255) -- 1493
	) -- 1493
	local v = computeView(room, w, h) -- 1495
	renderWorld( -- 1496
		draw, -- 1496
		room, -- 1496
		v, -- 1496
		w, -- 1496
		h -- 1496
	) -- 1496
	local roomTop = v.groundPx + room.height * v.scale -- 1498
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1499
	place( -- 1501
		titleLabel, -- 1501
		48, -- 1501
		h - 40, -- 1501
		0, -- 1501
		1 -- 1501
	) -- 1501
	place( -- 1502
		roomLabel, -- 1502
		48, -- 1502
		h - 96, -- 1502
		0, -- 1502
		1 -- 1502
	) -- 1502
	place( -- 1503
		captionLabel, -- 1503
		48, -- 1503
		h - 140, -- 1503
		0, -- 1503
		1 -- 1503
	) -- 1503
	place( -- 1505
		switchLabel, -- 1505
		48, -- 1505
		40, -- 1505
		0, -- 1505
		0 -- 1505
	) -- 1505
	place( -- 1506
		hintLabel, -- 1506
		48, -- 1506
		84, -- 1506
		0, -- 1506
		0 -- 1506
	) -- 1506
	place( -- 1507
		rulerLabel, -- 1507
		w - 216, -- 1507
		roomTop + 36 + v.scale * 0.5 - 14, -- 1507
		1, -- 1507
		0 -- 1507
	) -- 1507
	place( -- 1508
		standLabel, -- 1508
		48, -- 1508
		roomTop + 40, -- 1508
		0, -- 1508
		0 -- 1508
	) -- 1508
	place( -- 1509
		cartLabel, -- 1509
		48, -- 1509
		roomTop + 92, -- 1509
		0, -- 1509
		0 -- 1509
	) -- 1509
	if roomLabel ~= nil then -- 1509
		roomLabel.text = room.name -- 1512
	end -- 1512
	if captionLabel ~= nil then -- 1512
		captionLabel.text = room.caption -- 1515
	end -- 1515
	if hintLabel ~= nil then -- 1515
		local hintIdx = math.min(current, #HINTS - 1) -- 1518
		local lines = HINTS[hintIdx + 1] -- 1519
		local merged = lines[1] -- 1520
		do -- 1520
			local i = 1 -- 1521
			while i < #lines do -- 1521
				merged = (merged .. "    ") .. lines[i + 1] -- 1522
				i = i + 1 -- 1521
			end -- 1521
		end -- 1521
		hintLabel.text = merged -- 1524
	end -- 1524
	local specs = collectLabels(room, v, w) -- 1527
	local body = {} -- 1528
	local small = {} -- 1529
	do -- 1529
		local i = 0 -- 1530
		while i < #specs do -- 1530
			local s = specs[i + 1] -- 1531
			if s.size >= 24 then -- 1531
				body[#body + 1] = s -- 1533
			else -- 1533
				small[#small + 1] = s -- 1535
			end -- 1535
			i = i + 1 -- 1530
		end -- 1530
	end -- 1530
	applyPool(body, poolBody) -- 1538
	applyPool(small, poolSmall) -- 1539
	if LAYOUT_AUDIT then -- 1539
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1542
	end -- 1542
end -- 1542
function applyPool(specs, pool) -- 1546
	do -- 1546
		local i = 0 -- 1547
		while i < #pool do -- 1547
			local lb = pool[i + 1] -- 1548
			if i < #specs then -- 1548
				local s = specs[i + 1] -- 1550
				lb.text = s.text -- 1551
				lb.position = Vec2(s.x, s.y) -- 1552
				lb.anchor = Vec2(s.ax, s.ay) -- 1553
				lb.color = s.color -- 1554
				lb.visible = true -- 1555
			else -- 1555
				lb.visible = false -- 1557
			end -- 1557
			i = i + 1 -- 1547
		end -- 1547
	end -- 1547
end -- 1547
local FONT = "sarasa-mono-sc-regular" -- 34
LAYOUT_AUDIT = false -- 35
local C_TEXT = Color(236, 236, 232, 255) -- 37
local C_DIM = Color(150, 154, 152, 255) -- 38
local C_ACCENT = Color(226, 186, 84, 255) -- 39
C_BG = Color(17, 18, 19, 255) -- 40
local POOL_BODY = 30 -- 42
local POOL_SMALL = 44 -- 43
TOP_H = 208 -- 44
BOTTOM_H = 216 -- 45
profile = emptySave() -- 63
local profileStatus = "missing" -- 64
local profileDetail = "" -- 65
poolBody = {} -- 70
poolSmall = {} -- 71
current = 0 -- 73
viewW = 0 -- 74
viewH = 0 -- 75
dirty = true -- 76
mode = 1 -- 78
clock = __TS__New(StepClock) -- 82
stageVp = computeStageViewport(1280, 720) -- 83
audioUnlocked = false -- 85
appClock = 0 -- 86
local lastBackPressClock = -10 -- 87
trialTalentSelected = 0 -- 88
local function handleBackButton() -- 138
	if mode == 0 then -- 138
		setMode(1) -- 140
		return -- 141
	end -- 141
	if mode == 2 and play ~= nil then -- 141
		local trial = run and run.trial -- 144
		if trial ~= nil and (trial.lost or (run and run.finished) == true) then -- 144
			current = 0 -- 146
			play = nil -- 147
			run = nil -- 148
			setMode(1) -- 149
			if fe ~= nil then -- 149
				fe.audio:stopRoomTransient() -- 151
				fe.screen = "title" -- 152
				fe.menus:resetInput() -- 153
			end -- 153
			return -- 155
		end -- 155
		play.paused = not play.paused -- 157
		if fe ~= nil then -- 157
			fe.audio:playUi(play.paused and "ui:pause_open" or "ui:pause_close", play.paused and "assets/audio/ui/pause_open.wav" or "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 158
		end -- 158
		clock:reset() -- 159
		if input ~= nil then -- 159
			input:clearTransient(true) -- 160
		end -- 160
		return -- 161
	end -- 161
	if fe == nil then -- 161
		return -- 164
	end -- 164
	if fe.screen == "splash" then -- 164
		fe.menus:resetSplash() -- 167
		fe.screen = "title" -- 168
		fe.menus:resetInput() -- 169
		return -- 170
	end -- 170
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "epilogue" or fe.screen == "history" then -- 170
		fe.menus:triggerBack() -- 173
		return -- 174
	end -- 174
	if fe.screen == "title" then -- 174
		if not canQuitApp() then -- 174
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 178
			return -- 179
		end -- 179
		if appClock - lastBackPressClock <= 2 then -- 179
			quitGame() -- 182
		else -- 182
			lastBackPressClock = appClock -- 184
			fe:showToast("再按一次返回退出游戏", 2) -- 185
		end -- 185
		return -- 187
	end -- 187
	if fe.screen == "play" and play ~= nil then -- 187
		if play.paused then -- 187
			fe.menus:triggerBack() -- 191
			return -- 192
		end -- 192
		if play.craftBench.active then -- 192
			play:closeCraftBench() -- 195
			return -- 196
		end -- 196
		play.paused = true -- 198
		play.aimHold = 0 -- 199
		play.bottleAimX = -1 -- 200
		saveCurrentSession() -- 201
		fe.menus:openPause() -- 202
		if input ~= nil then -- 202
			input:clearTransient(true) -- 203
		end -- 203
	end -- 203
end -- 138
local function makeGrayboxLabel(text, size, color) -- 356
	if grayboxLayer == nil then -- 356
		return nil -- 358
	end -- 358
	local lb = Label(FONT, size) -- 360
	if lb == nil then -- 360
		return nil -- 362
	end -- 362
	lb.text = text -- 364
	lb.color = color -- 365
	lb:addTo(grayboxLayer) -- 366
	lb.visible = true -- 367
	return lb -- 368
end -- 356
function ____exports.start(parent, initialMode, startScreen) -- 380
	if initialMode == nil then -- 380
		initialMode = 1 -- 380
	end -- 380
	if startScreen == nil then -- 380
		startScreen = "title" -- 380
	end -- 380
	root = parent -- 381
	mode = initialMode -- 382
	grayboxLayer = Node() -- 385
	grayboxLayer.order = 2 -- 386
	grayboxLayer:addTo(parent) -- 387
	draw = DrawNode() -- 389
	draw:addTo(grayboxLayer) -- 390
	campaignLayer = Node() -- 393
	campaignLayer.order = 3 -- 394
	campaignLayer:addTo(parent) -- 395
	campaignDraw = DrawNode() -- 396
	campaignDraw:addTo(campaignLayer) -- 397
	campaignHud = Label(FONT, 24) -- 398
	if campaignHud ~= nil then -- 398
		campaignHud.color = C_TEXT -- 400
		campaignHud.anchor = Vec2(0, 1) -- 401
		campaignHud:addTo(campaignLayer) -- 402
		campaignHud.visible = true -- 403
	end -- 403
	campaignSub = Label(FONT, 20) -- 405
	if campaignSub ~= nil then -- 405
		campaignSub.color = C_ACCENT -- 407
		campaignSub.anchor = Vec2(0, 1) -- 408
		campaignSub:addTo(campaignLayer) -- 409
		campaignSub.visible = true -- 410
	end -- 410
	campaignLayer.visible = mode == 2 -- 412
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 414
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 415
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 416
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 417
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 418
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 419
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 420
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 421
	do -- 421
		local i = 0 -- 423
		while i < POOL_BODY do -- 423
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 424
			if lb ~= nil then -- 424
				poolBody[#poolBody + 1] = lb -- 426
			end -- 426
			i = i + 1 -- 423
		end -- 423
	end -- 423
	do -- 423
		local i = 0 -- 429
		while i < POOL_SMALL do -- 429
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 430
			if lb ~= nil then -- 430
				poolSmall[#poolSmall + 1] = lb -- 432
			end -- 432
			i = i + 1 -- 429
		end -- 429
	end -- 429
	if mode == 1 then -- 429
		local loaded = loadSave() -- 439
		profile = loaded.state -- 440
		profileStatus = loaded.status -- 441
		profileDetail = loaded.detail -- 442
	end -- 442
	fe = __TS__New(WatchFrontend, parent) -- 444
	fe.screen = startScreen -- 445
	if startScreen == "splash" then -- 445
		fe.menus:resetSplash() -- 447
	end -- 447
	refreshTitleSessionFlag() -- 449
	grayboxLayer.visible = mode == 0 -- 450
	fe:setVisible(mode == 1) -- 451
	if campaignLayer ~= nil then -- 451
		campaignLayer.visible = mode == 2 -- 453
	end -- 453
	input = __TS__New(Input) -- 456
	fe.audio:applyUserVolumes(input.settings) -- 457
	input:attach( -- 458
		parent, -- 458
		{ -- 458
			onFirstUserGesture = function() -- 459
				onFirstUserGesture() -- 460
				if input ~= nil then -- 460
					input:markKeyboardActivity() -- 461
				end -- 461
			end, -- 459
			onToggleFullscreen = function() -- 463
				toggleFullscreen() -- 464
			end, -- 463
			onKeyDownEvent = function(____, key) -- 466
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and key == "T" then -- 466
					play:toggleArtifactWeapon() -- 468
					return -- 469
				end -- 469
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and #play:getStoryTalentOffers() > 0 then -- 469
					if key == "1" then -- 469
						play:chooseTalent(0) -- 474
						if input ~= nil then -- 474
							input:consumePickRoom() -- 475
						end -- 475
						return -- 476
					end -- 476
					if key == "2" then -- 476
						play:chooseTalent(1) -- 479
						if input ~= nil then -- 479
							input:consumePickRoom() -- 480
						end -- 480
						return -- 481
					end -- 481
					if key == "3" then -- 481
						play:chooseTalent(2) -- 484
						if input ~= nil then -- 484
							input:consumePickRoom() -- 485
						end -- 485
						return -- 486
					end -- 486
				end -- 486
				local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 489
				if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 489
					fe.menus:onKeyEvent(key) -- 491
				end -- 491
				if input ~= nil and (mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay or mode == 2) then -- 491
					if key == "E" then -- 491
						input.interact.pressed = true -- 495
					elseif key == "Space" then -- 495
						input.jump.pressed = true -- 497
					elseif key == "Escape" then -- 497
						input.pause.pressed = true -- 499
					elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 499
						input.retry.pressed = true -- 501
					end -- 501
				end -- 501
				if mode == 2 and (run and run.trial) ~= nil then -- 501
					return -- 504
				end -- 504
				if isReleaseBuild() then -- 504
					return -- 505
				end -- 505
				if key == "F1" then -- 505
					if mode == 2 then -- 505
						current = 0 -- 508
						play = nil -- 509
						ensurePlay() -- 510
					else -- 510
						enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 512
					end -- 512
				elseif key == "F2" then -- 512
					setMode(0) -- 515
				elseif key == "1" then -- 515
					pickByIndex(0) -- 517
				elseif key == "2" then -- 517
					pickByIndex(1) -- 519
				elseif key == "3" then -- 519
					pickByIndex(2) -- 521
				elseif key == "4" then -- 521
					pickByIndex(3) -- 523
				elseif key == "5" then -- 523
					pickByIndex(4) -- 525
				elseif key == "6" then -- 525
					pickByIndex(5) -- 527
				elseif key == "7" then -- 527
					pickByIndex(6) -- 529
				elseif key == "8" then -- 529
					pickByIndex(7) -- 531
				end -- 531
			end -- 466
		} -- 466
	) -- 466
	parent:gslot( -- 537
		"AppEvent", -- 537
		function(eventType) -- 537
			if eventType == "BackButton" then -- 537
				handleBackButton() -- 539
				return -- 540
			end -- 540
			if eventType == "Quit" or eventType == "Shutdown" then -- 540
				flushProfile() -- 543
				saveCurrentSession() -- 544
				if input ~= nil then -- 544
					input:clearTransient(false) -- 545
				end -- 545
				return -- 546
			end -- 546
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 546
				flushProfile() -- 549
				saveCurrentSession() -- 550
				if input ~= nil then -- 550
					input:clearTransient(true) -- 551
				end -- 551
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 551
					play.paused = true -- 553
					play.aimHold = 0 -- 554
					play.bottleAimX = -1 -- 555
					fe.menus:openPause() -- 556
				elseif mode == 2 and play ~= nil and not play.paused then -- 556
					play.paused = true -- 558
				end -- 558
				if fe ~= nil then -- 558
					fe.audio:setPaused(true) -- 561
				end -- 561
				return -- 563
			end -- 563
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 563
				if fe ~= nil then -- 563
					local paused = play ~= nil and play.paused and (mode == 1 and fe.screen == "play" or mode == 2) -- 567
					fe.audio:setPaused(paused) -- 569
				end -- 569
			end -- 569
		end -- 537
	) -- 537
	viewW = View.size.width -- 574
	viewH = View.size.height -- 575
	applySize() -- 576
	local reg = _G.package.loaded -- 579
	reg["watch.input"] = input -- 580
	reg["watch.touch"] = input:getTouchRouter() -- 581
	reg["watch.gamepad"] = input:getGamepadRouter() -- 582
	reg["watch.fe"] = { -- 583
		setScreen = function(sc) -- 584
			if fe == nil then -- 584
				return -- 586
			end -- 586
			setMode(1) -- 588
			fe.screen = sc -- 589
			if sc == "splash" then -- 589
				fe.menus:resetSplash() -- 591
			elseif sc == "chapters" then -- 591
				fe.menus:openChapters() -- 593
			elseif sc == "epilogue" then -- 593
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 595
			elseif sc == "history" then -- 595
				fe.menus:openHistory(false) -- 600
			else -- 600
				fe.menus:resetInput() -- 602
			end -- 602
			if sc == "play" then -- 602
				ensurePlay() -- 605
			end -- 605
		end, -- 584
		jumpRoom = function(keyOrIdx) -- 608
			local idx = -1 -- 609
			if type(keyOrIdx) == "number" then -- 609
				idx = keyOrIdx -- 611
			else -- 611
				local k = 0 -- 613
				do -- 613
					k = 0 -- 614
					while k < #ROOMS do -- 614
						if ROOMS[k + 1].key == keyOrIdx then -- 614
							idx = k -- 616
						end -- 616
						k = k + 1 -- 614
					end -- 614
				end -- 614
			end -- 614
			if idx >= 0 and idx < #ROOMS then -- 614
				enterPlayRoom(idx, "debug") -- 621
			end -- 621
		end, -- 608
		getPlay = function() return play end, -- 624
		getFrontend = function() return fe end, -- 625
		startStory = function() -- 627
			enterPlayRoom( -- 628
				officialStartIndex(), -- 628
				"official", -- 628
				true -- 628
			) -- 628
			return play -- 629
		end, -- 627
		previewChapter = function(idx) -- 632
			enterPlayRoom(idx, "chapter") -- 633
			return play -- 634
		end, -- 632
		getStoryRun = function() return storyRun end, -- 636
		getProfilePending = function() return profilePending() end, -- 637
		flushProfileNow = function() return flushProfile() end, -- 638
		getProfile = function() return profile end, -- 640
		getProfileStatus = function() return profileStatus end, -- 641
		getProfileDetail = function() return profileDetail end, -- 642
		useTestSave = function(name) -- 643
			setSaveFile(name) -- 644
			setSessionFile(name == "" and "" or name .. ".session") -- 645
			clearProfilePending() -- 646
			local loaded = loadSave() -- 647
			profile = loaded.state -- 648
			profileStatus = loaded.status -- 649
			profileDetail = loaded.detail -- 650
			refreshTitleSessionFlag() -- 651
		end, -- 643
		useTestSession = function(name) -- 653
			setSessionFile(name) -- 654
			refreshTitleSessionFlag() -- 655
		end, -- 653
		getSessionFile = getSessionFile, -- 657
		hasSessionSave = hasSessionSave, -- 658
		saveSessionNow = function() return saveCurrentSession() end, -- 659
		clearSessionNow = function() -- 660
			local ok = clearSession() -- 661
			refreshTitleSessionFlag() -- 662
			return ok -- 663
		end, -- 660
		continueStory = function() return continueOfficialStory() end, -- 665
		saveNow = function() return saveSave(profile) end, -- 666
		getSaveFile = getSaveFile, -- 667
		isRelease = function() return isReleaseBuild() end, -- 668
		getReleaseVersion = function() -- 669
			local ____opt_32 = getReleaseConfig() -- 669
			return ____opt_32 and ____opt_32.version or "dev" -- 669
		end, -- 669
		toggleFullscreen = function() return toggleFullscreen() end, -- 670
		quitGame = function() return quitGame() end, -- 671
		startTrial = function() return startTrial() end, -- 672
		handleBackButton = function() return handleBackButton() end, -- 673
		getViewport = function() return stageVp end, -- 674
		getTargetId = function() return getActiveTarget().id end, -- 675
		getTouchController = function() return input and input:getTouchControls() end, -- 676
		getTouchRouter = function() return input and input:getTouchRouter() end, -- 677
		getGamepad = function() return input and input:getGamepadRouter() end, -- 678
		setGamepadSim = function(state) -- 679
			if input ~= nil then -- 679
				input:setGamepadSim(state) -- 680
			end -- 680
		end, -- 679
		injectTouch = function(phase, id, x, y, fromMouse) -- 682
			if input ~= nil then -- 682
				input:injectTouch( -- 683
					phase, -- 683
					id, -- 683
					x, -- 683
					y, -- 683
					fromMouse -- 683
				) -- 683
			end -- 683
		end, -- 682
		getInputMode = function() return input and input.inputMode or getActiveTarget().defaultInputMode end, -- 685
		setInputMode = function(m) -- 686
			if input ~= nil then -- 686
				input:setInputMode(m) -- 687
			end -- 687
		end, -- 686
		setModePref = function(pref) -- 689
			if input ~= nil then -- 689
				input:setModePref(pref) -- 690
			end -- 690
		end, -- 689
		applyViewportForTest = function(w, h) -- 692
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 692
				testViewportOverride = {w = w, h = h} -- 694
				viewW = w -- 695
				viewH = h -- 696
			else -- 696
				testViewportOverride = nil -- 698
				viewW = View.size.width -- 699
				viewH = View.size.height -- 700
			end -- 700
			applySize() -- 702
			dirty = true -- 703
			return stageVp -- 704
		end, -- 692
		getToast = function() return fe and fe:getToastText() or "" end -- 706
	} -- 706
	if mode == 1 and startScreen == "play" then -- 706
		ensurePlay() -- 710
	end -- 710
	parent:schedule(function(frameDt) -- 713
		tick(frameDt) -- 714
		return false -- 715
	end) -- 713
end -- 380
return ____exports -- 380