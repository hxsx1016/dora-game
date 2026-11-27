-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local ____exports = {} -- 1
local randomRunSeed, isReleaseBuild, onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, place, setMode, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, pickByIndex, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, applyRoomTransition, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, touchRouter, gamepadRouter, touchControls, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock -- 1
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
local normalizeLegacyTalent = ____run.normalizeLegacyTalent -- 28
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
function randomRunSeed() -- 91
	return math.max( -- 92
		1, -- 92
		math.floor(math.abs(App.rand)) % 2147483646 -- 92
	) -- 92
end -- 92
function isReleaseBuild() -- 95
	return isReleaseMode() -- 96
end -- 96
function onFirstUserGesture() -- 99
	if audioUnlocked or fe == nil then -- 99
		return -- 101
	end -- 101
	audioUnlocked = true -- 103
	fe.audio:unlockAndResyncAfterGesture() -- 104
end -- 104
function toggleFullscreen() -- 107
	if not canToggleFullscreen() then -- 107
		return false -- 109
	end -- 109
	do -- 109
		local function ____catch() -- 109
			return true, false -- 116
		end -- 116
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 116
			local next = not App.fullScreen -- 112
			App.fullScreen = next -- 113
			return true, next -- 114
		end) -- 114
		if not ____try then -- 114
			____hasReturned, ____returnValue = ____catch() -- 114
		end -- 114
		if ____hasReturned then -- 114
			return ____returnValue -- 111
		end -- 111
	end -- 111
end -- 111
function quitGame() -- 120
	flushProfile() -- 121
	saveCurrentSession() -- 122
	if input ~= nil then -- 122
		input:clearTransient(false) -- 123
	end -- 123
	if fe ~= nil then -- 123
		fe.audio:stopRoomTransient() -- 125
	end -- 125
	if not canQuitApp() then -- 125
		current = 0 -- 129
		play = nil -- 130
		setMode(1) -- 131
		if fe ~= nil then -- 131
			fe.audio:stopRoomTransient() -- 133
			fe.screen = "title" -- 134
			fe.menus:resetInput() -- 135
		end -- 135
		return -- 137
	end -- 137
	App:shutdown() -- 139
end -- 139
function canSaveSession() -- 198
	if mode ~= 1 or play == nil or storyRun == nil then -- 198
		return false -- 200
	end -- 200
	if storyRun.source ~= "official" or play.run.finished then -- 200
		return false -- 203
	end -- 203
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 203
		return false -- 206
	end -- 206
	return true -- 208
end -- 208
function refreshTitleSessionFlag() -- 211
	if fe ~= nil then -- 211
		fe.menus.hasSession = hasSessionSave() -- 213
	end -- 213
end -- 213
function saveCurrentSession() -- 217
	if not canSaveSession() or play == nil then -- 217
		return false -- 219
	end -- 219
	local ok = saveSession(play:exportSession()) -- 221
	play.sessionDirty = not ok -- 222
	refreshTitleSessionFlag() -- 223
	return ok -- 224
end -- 224
function continueOfficialStory() -- 227
	if play and play.escortFailed and play.run.source == "official" and play.sessionDirty then -- 227
		play:confirmEscortRestart() -- 230
		applyRoomTransition(play) -- 231
		if fe ~= nil then -- 231
			fe.screen = "play" -- 232
		end -- 232
		return play -- 233
	end -- 233
	local res = loadSession() -- 235
	if res.status ~= "ok" or res.state == nil then -- 235
		refreshTitleSessionFlag() -- 237
		return nil -- 238
	end -- 238
	local s = res.state -- 240
	local idx = roomIndexByKey(s.roomKey) -- 241
	if ROOMS[idx + 1].key ~= s.roomKey then -- 241
		return nil -- 243
	end -- 243
	storyRun = createRun(s.seed, "official", profile) -- 245
	storyRun.checkpoint = s.checkpoint -- 246
	storyRun.story.route = s.route -- 247
	storyRun.story.hp = s.hp -- 248
	storyRun.story.maxHp = s.maxHp -- 249
	storyRun.story.hpAtGate = s.hpAtGate -- 250
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 251
	storyRun.story.settled = s.settled -- 252
	storyRun.story.phase = s.phase -- 253
	storyRun.story.countTick = s.countTick -- 254
	storyRun.story.phaseTick = s.phaseTick -- 255
	storyRun.story.handTicks = s.handTicks -- 256
	storyRun.story.handDone = s.handDone -- 257
	storyRun.story.lineSaid = s.lineSaid -- 258
	storyRun.story.tied = s.tied -- 259
	storyRun.story.carry = s.carry -- 260
	storyRun.story.escortDone = s.escortDone -- 261
	storyRun.story.craftedWeapon = s.craftedWeapon -- 262
	storyRun.story.equippedWeapon = s.equippedWeapon -- 263
	storyRun.inventory.wood = s.wood -- 264
	storyRun.inventory.bell = s.bell -- 265
	storyRun.inventory.scrap = s.scrap -- 266
	storyRun.inventory.wedge = s.wedge -- 267
	storyRun.inventory.ammo = s.ammo -- 268
	storyRun.inventory.shield = s.shield -- 269
	storyRun.inventory.pass = s.pass -- 270
	storyRun.inventory.quickbelt = s.quickbelt -- 271
	local k = 0 -- 272
	do -- 272
		k = 0 -- 273
		while k < #s.taken do -- 273
			storyRun.taken[s.taken[k + 1]] = true -- 274
			k = k + 1 -- 273
		end -- 273
	end -- 273
	do -- 273
		k = 0 -- 276
		while k < #s.segments do -- 276
			storyRun.story.segments[s.segments[k + 1]] = true -- 277
			k = k + 1 -- 276
		end -- 276
	end -- 276
	if s.campaignRoute ~= nil then -- 276
		storyRun.route = s.campaignRoute -- 280
	end -- 280
	if s.joined ~= nil then -- 280
		storyRun.joined = s.joined -- 283
	end -- 283
	if s.c1Latch ~= nil then -- 283
		storyRun.c1Latch = s.c1Latch -- 286
	end -- 286
	if s.c2Latch ~= nil then -- 286
		storyRun.c2Latch = s.c2Latch -- 289
	end -- 289
	if s.props ~= nil then -- 289
		do -- 289
			k = 0 -- 292
			while k < #s.props do -- 292
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 293
				local pid = parts[1] -- 294
				if pid ~= nil and pid ~= "" then -- 294
					local ____storyRun_props_12 = storyRun.props -- 296
					local ____temp_8 -- 297
					if parts[2] == nil then -- 297
						____temp_8 = true -- 297
					else -- 297
						____temp_8 = parts[2] == "1" -- 297
					end -- 297
					local ____temp_10 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 298
					local ____temp_11 = parts[4] == "1" -- 299
					local ____temp_9 -- 300
					if parts[5] == "1" then -- 300
						____temp_9 = true -- 300
					else -- 300
						____temp_9 = nil -- 300
					end -- 300
					____storyRun_props_12[pid] = {broken = ____temp_8, hp = ____temp_10, wedge = ____temp_11, revealed = ____temp_9} -- 296
				end -- 296
				k = k + 1 -- 292
			end -- 292
		end -- 292
	end -- 292
	local stTalents = createStoryTalents(s.seed) -- 305
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 305
		stTalents.randomState = s.talentSeed -- 307
	end -- 307
	if s.escortAttempt ~= nil and s.escortAttempt >= 1 then -- 307
		stTalents.attempt = s.escortAttempt -- 310
	end -- 310
	if s.escortVariant ~= nil and s.escortVariant >= 0 then -- 310
		stTalents.variant = s.escortVariant -- 313
	end -- 313
	stTalents.deferred = s.talentDeferred == true -- 315
	stTalents.room = s.talentRoom or "" -- 316
	if s.talentRanks ~= nil and #s.talentRanks > 0 then -- 316
		do -- 316
			k = 0 -- 318
			while k < #s.talentRanks do -- 318
				local parts = __TS__StringSplit(s.talentRanks[k + 1], ":") -- 319
				local ____temp_13 -- 320
				if parts[1] ~= nil then -- 320
					____temp_13 = normalizeLegacyTalent(parts[1]) -- 320
				else -- 320
					____temp_13 = nil -- 320
				end -- 320
				local norm = ____temp_13 -- 320
				local rk = parts[2] ~= nil and (tonumber(parts[2]) or 0) or 0 -- 321
				if norm ~= nil and rk > 0 then -- 321
					stTalents.ranks[norm] = (stTalents.ranks[norm] or 0) + math.floor(rk) -- 323
				end -- 323
				k = k + 1 -- 318
			end -- 318
		end -- 318
	else -- 318
		stTalents.ranks.vitality = s.talentVitality or 0 -- 328
		stTalents.ranks.focus = s.talentReload or 0 -- 329
		stTalents.ranks.guard = s.talentGuard or 0 -- 330
		stTalents.ranks.salvage = s.talentCraft or 0 -- 331
	end -- 331
	if s.talentOffers ~= nil then -- 331
		do -- 331
			k = 0 -- 334
			while k < #s.talentOffers do -- 334
				local norm = normalizeLegacyTalent(s.talentOffers[k + 1]) -- 335
				if norm ~= nil then -- 335
					local ____stTalents_offers_14 = stTalents.offers -- 335
					____stTalents_offers_14[#____stTalents_offers_14 + 1] = norm -- 337
				end -- 337
				k = k + 1 -- 334
			end -- 334
		end -- 334
	end -- 334
	storyRun.story.talents = stTalents -- 341
	current = idx -- 342
	setMode(1) -- 343
	if fe ~= nil then -- 343
		fe.screen = "play" -- 345
	end -- 345
	play = nil -- 347
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 348
	local cur = play -- 349
	if cur ~= nil then -- 349
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 349
			cur.cartAxle = s.cartAxle -- 352
			cur.cartDocked = s.cartDocked -- 353
		end -- 353
		if s.playerX ~= nil and s.playerX >= 0 then -- 353
			cur.player.x = math.max( -- 356
				cur.room.minX + 16, -- 356
				math.min(cur.room.maxX - 16, s.playerX) -- 356
			) -- 356
			cur.player.y = math.max(0, s.playerY or 0) -- 357
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 357
				cur.player.depth = math.max( -- 359
					cur.room.depth.min, -- 359
					math.min(cur.room.depth.max, s.playerDepth) -- 359
				) -- 359
			end -- 359
		end -- 359
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 359
			cur.gateTick = s.gateTick -- 363
		end -- 363
		if cur.room.key == "village" then -- 363
			if s.hasBottle == true then -- 363
				cur.hasBottle = true -- 366
			end -- 366
			if s.villagePassed == true then -- 366
				cur.passed = true -- 367
			end -- 367
		end -- 367
	end -- 367
	return play -- 370
end -- 370
function place(lb, x, y, ax, ay) -- 388
	if lb == nil then -- 388
		return -- 390
	end -- 390
	lb.position = Vec2(x, y) -- 392
	lb.anchor = Vec2(ax, ay) -- 393
	lb.visible = true -- 394
end -- 394
function setMode(nextMode) -- 763
	mode = nextMode == 0 and 0 or 1 -- 764
	if grayboxLayer ~= nil then -- 764
		grayboxLayer.visible = mode == 0 -- 766
	end -- 766
	if fe ~= nil then -- 766
		fe:setVisible(mode == 1) -- 769
	end -- 769
	dirty = true -- 771
	clock:reset() -- 772
end -- 772
function flushProfile() -- 779
	local cur = play -- 780
	if cur ~= nil and cur.archiveDirty then -- 780
		cur.archiveDirty = false -- 782
		markProfilePending(profile) -- 783
	end -- 783
	local ok = flushSaveProfile() -- 785
	if not ok and cur ~= nil then -- 785
		cur.archiveDirty = true -- 787
	end -- 787
	return ok -- 789
end -- 789
function officialStartIndex() -- 793
	local mp = profile.museumPhase -- 794
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 795
	return inMuseum and roomIndexByKey("museum") or 0 -- 796
end -- 796
function roomIndexByKey(key) -- 799
	local i = 0 -- 800
	do -- 800
		i = 0 -- 801
		while i < #ROOMS do -- 801
			if ROOMS[i + 1].key == key then -- 801
				return i -- 803
			end -- 803
			i = i + 1 -- 801
		end -- 801
	end -- 801
	return 0 -- 806
end -- 806
function enterPlayRoom(idx, source, fresh, seedOverride) -- 809
	if source == nil then -- 809
		source = "debug" -- 809
	end -- 809
	if fresh == nil then -- 809
		fresh = false -- 809
	end -- 809
	current = idx -- 810
	setMode(1) -- 811
	if fe ~= nil then -- 811
		fe.screen = "play" -- 813
	end -- 813
	play = nil -- 815
	if fresh or source == "chapter" or storyRun == nil then -- 815
		local seed = seedOverride ~= nil and seedOverride or ((source == "official" or source == "chapter") and randomRunSeed() or 20261124) -- 818
		storyRun = createRun(seed, source, profile) -- 821
		if source == "chapter" then -- 821
			local targetKey = ROOMS[idx + 1].key -- 823
			if targetKey == "gatepath" or targetKey == "escort1" or targetKey == "escort2" or targetKey == "escort3" or targetKey == "escort4" or targetKey == "escort5" then -- 823
				storyRun.story.route = "soldier" -- 826
				storyRun.story.settled = true -- 827
				storyRun.story.hp = 3 -- 828
				storyRun.story.maxHp = 3 -- 829
				storyRun.story.hpAtGate = 3 -- 830
				storyRun.story.maxHpAtGate = 3 -- 831
				storyRun.story.handDone = true -- 832
				storyRun.story.tied = true -- 833
				storyRun.story.carry = targetKey ~= "gatepath" -- 834
				storyRun.joined = true -- 835
				if targetKey == "escort3" or targetKey == "escort4" or targetKey == "escort5" then -- 835
					storyRun.inventory.wood = 2 -- 837
					storyRun.inventory.bell = 1 -- 838
				end -- 838
			elseif targetKey == "outside" or targetKey == "village" or targetKey == "forest" then -- 838
				storyRun.story.route = "child" -- 841
				storyRun.story.settled = true -- 842
				storyRun.story.countTick = 1440 -- 843
			end -- 843
		end -- 843
	else -- 843
		storyRun.source = source -- 847
	end -- 847
	ensurePlay() -- 849
	local firstPlay = play -- 851
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 851
		firstPlay.phase = "prologue-wake" -- 853
	end -- 853
	flushProfile() -- 855
end -- 855
function pickByIndex(idx, source) -- 858
	if source == nil then -- 858
		source = "debug" -- 858
	end -- 858
	if idx < 0 or idx >= #ROOMS then -- 858
		return -- 860
	end -- 860
	flushProfile() -- 862
	if storyRun ~= nil then -- 862
		storyRun.source = source -- 864
	end -- 864
	current = idx -- 866
	dirty = true -- 867
	play = nil -- 868
	clock:reset() -- 869
	if mode == 1 then -- 869
		if fe ~= nil then -- 869
			fe.screen = "play" -- 872
		end -- 872
		ensurePlay() -- 874
	end -- 874
end -- 874
function applySize() -- 878
	if root == nil then -- 878
		return -- 880
	end -- 880
	root.size = Size(viewW, viewH) -- 882
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 883
	stageVp = computeStageViewport(viewW, viewH) -- 884
	if input ~= nil then -- 884
		input:setStageViewport(stageVp) -- 886
	end -- 886
	if fe ~= nil then -- 886
		fe:setStagePlacement(stageVp) -- 889
	end -- 889
	if grayboxLayer ~= nil then -- 889
		grayboxLayer.position = Vec2(0, 0) -- 892
	end -- 892
end -- 892
function syncFrameAdapters(frameDt) -- 896
	if input == nil then -- 896
		return -- 898
	end -- 898
	local p = play -- 900
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 901
	local gameplayActive = isPlayMode -- 902
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and fe:getStoryTalentBoxes( -- 904
		p, -- 906
		stageVp.stageW, -- 906
		stageVp.stageH, -- 906
		input:isTouchMode() -- 906
	) or ({}) -- 906
	local ____temp_45 -- 908
	if isPlayMode and fe ~= nil and p ~= nil and not p.paused and p.escortFailed then -- 908
		____temp_45 = fe:getEscortDeathBoxes(p, stageVp.stageW, stageVp.stageH) -- 910
	else -- 910
		____temp_45 = nil -- 911
	end -- 911
	local escortDeathBoxes = ____temp_45 -- 908
	if touchControls ~= nil and touchRouter ~= nil then -- 908
		local isFs = false -- 914
		if canToggleFullscreen() then -- 914
			do -- 914
				local function ____catch() -- 914
					isFs = false -- 919
				end -- 919
				local ____try = pcall(function() -- 919
					isFs = App.fullScreen -- 917
				end) -- 917
				if not ____try then -- 917
					____catch() -- 917
				end -- 917
			end -- 917
		end -- 917
		local ____touchControls_55 = touchControls -- 922
		local ____touchControls_syncContext_56 = touchControls.syncContext -- 922
		local ____stageVp_48 = stageVp -- 923
		local ____mode_49 = mode -- 924
		local ____temp_50 = fe ~= nil and fe.screen or "title" -- 925
		local ____storyRun_51 = storyRun -- 927
		local ____temp_52 = fe ~= nil and fe.cam or nil -- 928
		local ____input_53 = input -- 929
		local ____touchRouter_54 = touchRouter -- 930
		local ____temp_46 -- 931
		if fe ~= nil then -- 931
			____temp_46 = fe.contract:isAssistHintsEnabled() -- 931
		else -- 931
			____temp_46 = false -- 931
		end -- 931
		local ____temp_47 -- 932
		if fe ~= nil then -- 932
			____temp_47 = fe.audio:isAllMuted() -- 932
		else -- 932
			____temp_47 = false -- 932
		end -- 932
		____touchControls_syncContext_56(____touchControls_55, { -- 922
			viewport = ____stageVp_48, -- 923
			mode = ____mode_49, -- 924
			screen = ____temp_50, -- 925
			play = p, -- 926
			run = ____storyRun_51, -- 927
			cam = ____temp_52, -- 928
			input = ____input_53, -- 929
			router = ____touchRouter_54, -- 930
			assistHintsEnabled = ____temp_46, -- 931
			isMuted = ____temp_47, -- 932
			isFullscreen = isFs, -- 933
			storyTalentBoxes = storyTalentBoxes, -- 934
			escortDeathBoxes = escortDeathBoxes, -- 935
			dt = frameDt -- 936
		}) -- 936
	end -- 936
	if gamepadRouter ~= nil then -- 936
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and #p:getStoryTalentOffers() or 0 -- 941
		local talentBlocking = isPlayMode and p ~= nil and p.talentModalActive and talentOfferCount > 0 -- 944
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active or p.escortFailed or talentBlocking) -- 945
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 947
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 948
		local ____temp_57 -- 949
		if isPlayMode and p ~= nil then -- 949
			____temp_57 = isCutsceneBlockingPlay(p) -- 949
		else -- 949
			____temp_57 = false -- 949
		end -- 949
		local cutsceneBlocking = ____temp_57 -- 949
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 950
		local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 952
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and p.escort.state ~= "calming" -- 953
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 955
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 957
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 960
		local playerScreenX = stageVp.stageW * 0.5 -- 962
		local playerScreenY = stageVp.stageH * 0.38 -- 963
		if p ~= nil and isPlayMode and fe ~= nil then -- 963
			playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 965
			playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 966
		end -- 966
		local enemyTargets = canShoot and p ~= nil and isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or ({}) -- 969
		local gpCtx = { -- 973
			stageW = stageVp.stageW, -- 974
			stageH = stageVp.stageH, -- 975
			uiScale = stageVp.uiScale, -- 976
			modal = modal, -- 977
			gameplayActive = gameplayActive, -- 978
			reloadActive = reloadActive, -- 979
			craftActive = craftActive, -- 980
			talentOfferCount = talentOfferCount, -- 981
			childMode = p ~= nil and p.childMode, -- 982
			allowDepth = allowDepth, -- 983
			canShoot = canShoot, -- 984
			canBottleAim = canBottleAim, -- 985
			playerRolling = p ~= nil and p.player.rollT > 0, -- 986
			inLowArch = inLowArch, -- 987
			inTowerEnd = inTowerEnd, -- 988
			playerFacing = p ~= nil and p.player.facing or 1, -- 989
			playerScreenX = playerScreenX, -- 990
			playerScreenY = playerScreenY, -- 991
			enemyTargets = enemyTargets -- 992
		} -- 992
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 994
	end -- 994
end -- 994
function renderTouchOverlay() -- 998
	if touchControls ~= nil and touchRouter ~= nil then -- 998
		touchControls:render(touchRouter) -- 1000
	end -- 1000
end -- 1000
function tick(frameDt) -- 1004
	appClock = appClock + math.min( -- 1005
		0.05, -- 1005
		math.max(0, frameDt) -- 1005
	) -- 1005
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 1006
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 1007
	if w ~= viewW or h ~= viewH then -- 1007
		viewW = w -- 1009
		viewH = h -- 1010
		applySize() -- 1011
		dirty = true -- 1012
	end -- 1012
	if input == nil then -- 1012
		return -- 1015
	end -- 1015
	syncFrameAdapters(frameDt) -- 1017
	input:update() -- 1018
	if input.userInteracted then -- 1018
		onFirstUserGesture() -- 1021
	end -- 1021
	if input.muteTogglePressed and fe ~= nil then -- 1021
		input.muteTogglePressed = false -- 1024
		fe.audio:toggleAllMuted() -- 1025
	end -- 1025
	if input.fullscreenTogglePressed then -- 1025
		input.fullscreenTogglePressed = false -- 1028
		toggleFullscreen() -- 1029
	end -- 1029
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.escortFailed then -- 1029
		input.artifactTogglePressed = false -- 1032
		play:toggleArtifactWeapon() -- 1033
	end -- 1033
	if input.bottleCanceled and play ~= nil then -- 1033
		input.bottleCanceled = false -- 1036
		play.aimHold = 0 -- 1037
		play.bottleAimX = -1 -- 1038
	end -- 1038
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and not play.escortFailed and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 1038
		play:chooseTalent(input.pickRoom - 1) -- 1044
		input.pickRoom = 0 -- 1045
	end -- 1045
	if isReleaseBuild() then -- 1045
		input.toggleView.pressed = false -- 1049
		input.pickRoom = 0 -- 1050
		input.tab.pressed = false -- 1051
	else -- 1051
		if input.toggleView.pressed then -- 1051
			input.toggleView.pressed = false -- 1055
			setMode(mode == 0 and 1 or 0) -- 1056
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 1056
				ensurePlay() -- 1058
			end -- 1058
		end -- 1058
		if input.pickRoom ~= 0 then -- 1058
			local idx = input.pickRoom - 1 -- 1064
			input.pickRoom = 0 -- 1065
			pickByIndex(idx) -- 1066
		elseif input.tab.pressed then -- 1066
			input.tab.pressed = false -- 1068
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 1068
				pickByIndex((current + 1) % #ROOMS) -- 1070
			end -- 1070
		end -- 1070
	end -- 1070
	if mode == 1 then -- 1070
		tickFrontend(frameDt) -- 1076
	elseif dirty then -- 1076
		redrawGraybox() -- 1078
		dirty = false -- 1079
	end -- 1079
	renderTouchOverlay() -- 1081
end -- 1081
function registerPlay() -- 1085
	local reg = _G.package.loaded -- 1086
	reg["watch.play"] = play -- 1087
	reg["watch.room"] = ROOMS[current + 1].key -- 1088
end -- 1088
function ensurePlay(resume) -- 1092
	if storyRun == nil then -- 1092
		storyRun = createRun(20261124, "debug", profile) -- 1096
	end -- 1096
	play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1098
	registerPlay() -- 1099
	clock:reset() -- 1100
	if fe ~= nil and mode == 1 then -- 1100
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1102
	end -- 1102
end -- 1102
function applyRoomTransition(p) -- 1107
	if p.wantRoom == "" then -- 1107
		return false -- 1109
	end -- 1109
	local key = p.wantRoom -- 1111
	p.wantRoom = "" -- 1112
	local idx = -1 -- 1113
	local j = 0 -- 1114
	do -- 1114
		j = 0 -- 1115
		while j < #ROOMS do -- 1115
			if ROOMS[j + 1].key == key then -- 1115
				idx = j -- 1117
			end -- 1117
			j = j + 1 -- 1115
		end -- 1115
	end -- 1115
	if idx < 0 then -- 1115
		return false -- 1121
	end -- 1121
	flushProfile() -- 1126
	local leaving = p:drainEvents() -- 1127
	if p.restartStory then -- 1127
		if storyRun ~= nil and storyRun.source == "official" then -- 1127
			clearSession() -- 1131
			refreshTitleSessionFlag() -- 1132
		end -- 1132
		local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1134
		local nextSeed = nextSource == "official" and randomRunSeed() or 20261124 -- 1135
		storyRun = createRun(nextSeed, nextSource, profile) -- 1136
	end -- 1136
	current = idx -- 1138
	ensurePlay() -- 1139
	local fresh = play -- 1140
	if fresh ~= nil then -- 1140
		if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1140
			fresh.phase = "prologue-wake" -- 1143
		end -- 1143
		fresh:adoptEvents(leaving) -- 1145
	end -- 1145
	if not p.restartStory then -- 1145
		saveCurrentSession() -- 1148
	end -- 1148
	clock:reset() -- 1150
	dirty = true -- 1151
	return true -- 1152
end -- 1152
function tickFrontend(frameDt) -- 1155
	if fe == nil or input == nil then -- 1155
		return -- 1157
	end -- 1157
	if fe.screen ~= "play" then -- 1157
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1162
		input:consumeEdges() -- 1163
		if act.type == "splashDone" then -- 1163
			fe.menus:resetInput() -- 1165
			fe.screen = "title" -- 1166
		elseif act.type == "continue" then -- 1166
			if continueOfficialStory() == nil then -- 1166
				enterPlayRoom( -- 1169
					officialStartIndex(), -- 1169
					"official", -- 1169
					true -- 1169
				) -- 1169
			end -- 1169
		elseif act.type == "start" then -- 1169
			clearSession() -- 1173
			refreshTitleSessionFlag() -- 1174
			enterPlayRoom( -- 1175
				officialStartIndex(), -- 1175
				"official", -- 1175
				true -- 1175
			) -- 1175
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1175
			enterPlayRoom(act.roomIndex, "chapter") -- 1177
		elseif act.type == "openChapters" then -- 1177
			fe.menus:openChapters() -- 1179
			fe.screen = "chapters" -- 1180
		elseif act.type == "openControls" then -- 1180
			fe.menus:resetInput() -- 1182
			fe.screen = "controls" -- 1183
		elseif act.type == "openHistory" then -- 1183
			fe.menus:openHistory(true) -- 1185
			fe.screen = "history" -- 1186
		elseif act.type == "backEpilogue" then -- 1186
			fe.menus:resetInput() -- 1188
			fe.screen = "epilogue" -- 1189
		elseif act.type == "replayStory" then -- 1189
			clearSession() -- 1191
			refreshTitleSessionFlag() -- 1192
			enterPlayRoom( -- 1193
				officialStartIndex(), -- 1193
				"official", -- 1193
				true -- 1193
			) -- 1193
		elseif act.type == "backTitle" then -- 1193
			fe.menus:resetInput() -- 1195
			fe.screen = "title" -- 1196
		elseif act.type == "backPause" then -- 1196
			fe.menus:resetInput() -- 1198
			fe.screen = "play" -- 1199
		elseif act.type == "quit" then -- 1199
			quitGame() -- 1201
		end -- 1201
		return -- 1203
	end -- 1203
	if play == nil then -- 1203
		ensurePlay() -- 1208
	end -- 1208
	if play == nil then -- 1208
		return -- 1211
	end -- 1211
	local p = play -- 1213
	p.aimX = input.mx -- 1215
	p.aimY = input.my -- 1216
	local zoneTap = input.touchZoneTap -- 1218
	input.touchZoneTap = "" -- 1219
	if not p.paused and p.escortFailed then -- 1219
		local deathAction = "" -- 1223
		if zoneTap == "escort:retry" and p.escortFailedTicks >= 12 then -- 1223
			deathAction = "retry" -- 1225
		elseif zoneTap == "escort:title" then -- 1225
			deathAction = "title" -- 1227
		else -- 1227
			if input.navLeft or input.navPrevTab then -- 1227
				fe.talentDraft.deathSelected = 0 -- 1230
			elseif input.navRight or input.navNextTab then -- 1230
				fe.talentDraft.deathSelected = 1 -- 1232
			end -- 1232
			if input.pause.pressed or input.navBack then -- 1232
				deathAction = "title" -- 1235
			elseif p.escortFailedTicks >= 24 and input.retry.pressed then -- 1235
				deathAction = "retry" -- 1237
			elseif p.escortFailedTicks >= 24 and input.navConfirm then -- 1237
				deathAction = fe.talentDraft.deathSelected == 0 and "retry" or "title" -- 1239
			elseif p.escortFailedTicks >= 12 and (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) then -- 1239
				deathAction = fe:tryPickEscortDeathAtPointer(p, input, stageVp.stageW, stageVp.stageH) -- 1242
			end -- 1242
		end -- 1242
		if deathAction == "retry" then -- 1242
			input:consumeEdges() -- 1246
			p:confirmEscortRestart() -- 1247
			applyRoomTransition(p) -- 1248
			return -- 1249
		end -- 1249
		if deathAction == "title" then -- 1249
			input:consumeEdges() -- 1252
			fe.audio:stopRoomTransient() -- 1253
			fe.menus:resetInput() -- 1254
			fe.screen = "title" -- 1255
			input:clearTransient(true) -- 1256
			return -- 1257
		end -- 1257
		input.pause.pressed = false -- 1259
		input.retry.pressed = false -- 1260
		input.fire.pressed = false -- 1261
	end -- 1261
	local offers = p:getStoryTalentOffers() -- 1264
	if not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and #offers > 0 then -- 1264
		if fe.talentDraft.selected >= #offers then -- 1264
			fe.talentDraft.selected = 0 -- 1267
		end -- 1267
		fe.hud.talentSelected = fe.talentDraft.selected -- 1269
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1269
			local idx = __TS__ParseInt( -- 1271
				string.sub(zoneTap, 8), -- 1271
				10 -- 1271
			) -- 1271
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1271
				fe.talentDraft.selected = idx -- 1273
				fe.hud.talentSelected = idx -- 1274
				input.fire.pressed = false -- 1275
			end -- 1275
		else -- 1275
			local navDelta = p.talentModalActive and ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) or 0 -- 1278
			local totalDelta = input.talentDelta + navDelta -- 1281
			if totalDelta ~= 0 then -- 1281
				fe.talentDraft.selected = (fe.talentDraft.selected + totalDelta + #offers) % #offers -- 1283
				fe.hud.talentSelected = fe.talentDraft.selected -- 1284
				input.talentDelta = 0 -- 1285
			end -- 1285
			if input.talentConfirm or p.talentModalActive and input.navConfirm then -- 1285
				p:chooseTalent(fe.talentDraft.selected) -- 1288
				input.talentConfirm = false -- 1289
				input.fire.pressed = false -- 1290
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1290
				input.fire.pressed = false -- 1293
			end -- 1293
		end -- 1293
	end -- 1293
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1293
		if input.navConfirm then -- 1293
			input.interact.pressed = true -- 1301
		end -- 1301
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1301
			flushProfile() -- 1304
			if p.run.source == "official" and hasSessionSave() then -- 1304
				clearSession() -- 1306
				refreshTitleSessionFlag() -- 1307
			end -- 1307
			fe.audio:stopRoomTransient() -- 1309
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1310
			fe.screen = "epilogue" -- 1314
			input:clearTransient(true) -- 1315
			input:consumeEdges() -- 1316
			return -- 1317
		end -- 1317
	end -- 1317
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1317
		p:closeCraftBench() -- 1322
		input:consumeEdges() -- 1323
		return -- 1324
	end -- 1324
	if not p.paused and not p.escortFailed and input.pause.pressed then -- 1324
		p.paused = true -- 1327
		p.aimHold = 0 -- 1328
		p.bottleAimX = -1 -- 1329
		saveCurrentSession() -- 1330
		fe.menus:openPause() -- 1331
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1332
		input:clearTransient(true) -- 1333
		input:consumeEdges() -- 1334
	end -- 1334
	if p.paused then -- 1334
		clock:reset() -- 1339
		local pauseAct = fe:renderPlay( -- 1340
			frameDt, -- 1340
			p, -- 1340
			input, -- 1340
			stageVp.stageW, -- 1340
			stageVp.stageH -- 1340
		) -- 1340
		input:consumeEdges() -- 1341
		if pauseAct.type == "resume" then -- 1341
			p.paused = false -- 1343
		elseif pauseAct.type == "retry" then -- 1343
			if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1343
				p:restartEscortRun() -- 1346
				applyRoomTransition(p) -- 1347
			else -- 1347
				ensurePlay({checkpoint = p.checkpoint}) -- 1349
			end -- 1349
		elseif pauseAct.type == "openChapters" then -- 1349
			fe.audio:stopRoomTransient() -- 1352
			fe.audio:setPaused(false) -- 1353
			fe.menus:openChapters(current) -- 1354
			fe.screen = "chapters" -- 1355
		elseif pauseAct.type == "toggleFullscreen" then -- 1355
			toggleFullscreen() -- 1357
		elseif pauseAct.type == "quit" then -- 1357
			quitGame() -- 1359
		elseif pauseAct.type == "toTitle" then -- 1359
			saveCurrentSession() -- 1361
			refreshTitleSessionFlag() -- 1362
			fe.menus:resetInput() -- 1363
			fe.screen = "title" -- 1364
		end -- 1364
		return -- 1366
	end -- 1366
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1369
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1370
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and not p.talentModalActive then -- 1370
		input:consumeEdges() -- 1373
		if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1373
			p:restartEscortRun() -- 1376
			applyRoomTransition(p) -- 1377
		else -- 1377
			ensurePlay({checkpoint = p.checkpoint}) -- 1380
		end -- 1380
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
	if applyRoomTransition(p) then -- 1387
		return -- 1398
	end -- 1398
	flushProfile() -- 1402
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1402
		clearSession() -- 1404
		refreshTitleSessionFlag() -- 1405
	elseif p.sessionDirty then -- 1405
		saveCurrentSession() -- 1407
	end -- 1407
	fe:renderPlay( -- 1409
		frameDt, -- 1409
		p, -- 1409
		input, -- 1409
		stageVp.stageW, -- 1409
		stageVp.stageH -- 1409
	) -- 1409
end -- 1409
function redrawGraybox() -- 1413
	if draw == nil then -- 1413
		return -- 1415
	end -- 1415
	local w = viewW -- 1417
	local h = viewH -- 1418
	local room = ROOMS[current + 1] -- 1419
	draw:clear() -- 1421
	draw:drawRect( -- 1422
		Rect(0, h - TOP_H, w, TOP_H), -- 1422
		C_BG -- 1422
	) -- 1422
	draw:drawRect( -- 1423
		Rect(0, 0, w, BOTTOM_H), -- 1423
		C_BG -- 1423
	) -- 1423
	draw:drawSegment( -- 1424
		Vec2(0, h - TOP_H), -- 1424
		Vec2(w, h - TOP_H), -- 1424
		1, -- 1424
		Color(52, 54, 54, 255) -- 1424
	) -- 1424
	draw:drawSegment( -- 1425
		Vec2(0, BOTTOM_H), -- 1425
		Vec2(w, BOTTOM_H), -- 1425
		1, -- 1425
		Color(52, 54, 54, 255) -- 1425
	) -- 1425
	local v = computeView(room, w, h) -- 1427
	renderWorld( -- 1428
		draw, -- 1428
		room, -- 1428
		v, -- 1428
		w, -- 1428
		h -- 1428
	) -- 1428
	local roomTop = v.groundPx + room.height * v.scale -- 1430
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1431
	place( -- 1433
		titleLabel, -- 1433
		48, -- 1433
		h - 40, -- 1433
		0, -- 1433
		1 -- 1433
	) -- 1433
	place( -- 1434
		roomLabel, -- 1434
		48, -- 1434
		h - 96, -- 1434
		0, -- 1434
		1 -- 1434
	) -- 1434
	place( -- 1435
		captionLabel, -- 1435
		48, -- 1435
		h - 140, -- 1435
		0, -- 1435
		1 -- 1435
	) -- 1435
	place( -- 1437
		switchLabel, -- 1437
		48, -- 1437
		40, -- 1437
		0, -- 1437
		0 -- 1437
	) -- 1437
	place( -- 1438
		hintLabel, -- 1438
		48, -- 1438
		84, -- 1438
		0, -- 1438
		0 -- 1438
	) -- 1438
	place( -- 1439
		rulerLabel, -- 1439
		w - 216, -- 1439
		roomTop + 36 + v.scale * 0.5 - 14, -- 1439
		1, -- 1439
		0 -- 1439
	) -- 1439
	place( -- 1440
		standLabel, -- 1440
		48, -- 1440
		roomTop + 40, -- 1440
		0, -- 1440
		0 -- 1440
	) -- 1440
	place( -- 1441
		cartLabel, -- 1441
		48, -- 1441
		roomTop + 92, -- 1441
		0, -- 1441
		0 -- 1441
	) -- 1441
	if roomLabel ~= nil then -- 1441
		roomLabel.text = room.name -- 1444
	end -- 1444
	if captionLabel ~= nil then -- 1444
		captionLabel.text = room.caption -- 1447
	end -- 1447
	if hintLabel ~= nil then -- 1447
		local hintIdx = math.min(current, #HINTS - 1) -- 1450
		local lines = HINTS[hintIdx + 1] -- 1451
		local merged = lines[1] -- 1452
		do -- 1452
			local i = 1 -- 1453
			while i < #lines do -- 1453
				merged = (merged .. "    ") .. lines[i + 1] -- 1454
				i = i + 1 -- 1453
			end -- 1453
		end -- 1453
		hintLabel.text = merged -- 1456
	end -- 1456
	local specs = collectLabels(room, v, w) -- 1459
	local body = {} -- 1460
	local small = {} -- 1461
	do -- 1461
		local i = 0 -- 1462
		while i < #specs do -- 1462
			local s = specs[i + 1] -- 1463
			if s.size >= 24 then -- 1463
				body[#body + 1] = s -- 1465
			else -- 1465
				small[#small + 1] = s -- 1467
			end -- 1467
			i = i + 1 -- 1462
		end -- 1462
	end -- 1462
	applyPool(body, poolBody) -- 1470
	applyPool(small, poolSmall) -- 1471
	if LAYOUT_AUDIT then -- 1471
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1474
	end -- 1474
end -- 1474
function applyPool(specs, pool) -- 1478
	do -- 1478
		local i = 0 -- 1479
		while i < #pool do -- 1479
			local lb = pool[i + 1] -- 1480
			if i < #specs then -- 1480
				local s = specs[i + 1] -- 1482
				lb.text = s.text -- 1483
				lb.position = Vec2(s.x, s.y) -- 1484
				lb.anchor = Vec2(s.ax, s.ay) -- 1485
				lb.color = s.color -- 1486
				lb.visible = true -- 1487
			else -- 1487
				lb.visible = false -- 1489
			end -- 1489
			i = i + 1 -- 1479
		end -- 1479
	end -- 1479
end -- 1479
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
profile = emptySave() -- 62
local profileStatus = "missing" -- 63
local profileDetail = "" -- 64
poolBody = {} -- 69
poolSmall = {} -- 70
current = 0 -- 72
viewW = 0 -- 73
viewH = 0 -- 74
dirty = true -- 75
mode = 1 -- 77
clock = __TS__New(StepClock) -- 84
stageVp = computeStageViewport(1280, 720) -- 85
audioUnlocked = false -- 87
appClock = 0 -- 88
local lastBackPressClock = -10 -- 89
local function handleBackButton() -- 142
	if mode == 0 then -- 142
		setMode(1) -- 144
		return -- 145
	end -- 145
	if fe == nil then -- 145
		return -- 148
	end -- 148
	if fe.screen == "splash" then -- 148
		fe.menus:resetSplash() -- 151
		fe.screen = "title" -- 152
		fe.menus:resetInput() -- 153
		return -- 154
	end -- 154
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "epilogue" or fe.screen == "history" then -- 154
		fe.menus:triggerBack() -- 157
		return -- 158
	end -- 158
	if fe.screen == "title" then -- 158
		if not canQuitApp() then -- 158
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 162
			return -- 163
		end -- 163
		if appClock - lastBackPressClock <= 2 then -- 163
			quitGame() -- 166
		else -- 166
			lastBackPressClock = appClock -- 168
			fe:showToast("再按一次返回退出游戏", 2) -- 169
		end -- 169
		return -- 171
	end -- 171
	if fe.screen == "play" and play ~= nil then -- 171
		if play.escortFailed then -- 171
			fe.audio:stopRoomTransient() -- 175
			fe.menus:resetInput() -- 176
			fe.screen = "title" -- 177
			if input ~= nil then -- 177
				input:clearTransient(true) -- 178
			end -- 178
			return -- 179
		end -- 179
		if play.paused then -- 179
			fe.menus:triggerBack() -- 182
			return -- 183
		end -- 183
		if play.craftBench.active then -- 183
			play:closeCraftBench() -- 186
			return -- 187
		end -- 187
		play.paused = true -- 189
		play.aimHold = 0 -- 190
		play.bottleAimX = -1 -- 191
		saveCurrentSession() -- 192
		fe.menus:openPause() -- 193
		if input ~= nil then -- 193
			input:clearTransient(true) -- 194
		end -- 194
	end -- 194
end -- 142
local function makeGrayboxLabel(text, size, color) -- 373
	if grayboxLayer == nil then -- 373
		return nil -- 375
	end -- 375
	local lb = Label(FONT, size) -- 377
	if lb == nil then -- 377
		return nil -- 379
	end -- 379
	lb.text = text -- 381
	lb.color = color -- 382
	lb:addTo(grayboxLayer) -- 383
	lb.visible = true -- 384
	return lb -- 385
end -- 373
function ____exports.start(parent, initialMode, startScreen) -- 397
	if initialMode == nil then -- 397
		initialMode = 1 -- 397
	end -- 397
	if startScreen == nil then -- 397
		startScreen = "title" -- 397
	end -- 397
	root = parent -- 398
	mode = initialMode -- 399
	grayboxLayer = Node() -- 402
	grayboxLayer.order = 2 -- 403
	grayboxLayer:addTo(parent) -- 404
	draw = DrawNode() -- 406
	draw:addTo(grayboxLayer) -- 407
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 409
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 410
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 411
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 412
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 413
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 414
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 415
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 416
	do -- 416
		local i = 0 -- 418
		while i < POOL_BODY do -- 418
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 419
			if lb ~= nil then -- 419
				poolBody[#poolBody + 1] = lb -- 421
			end -- 421
			i = i + 1 -- 418
		end -- 418
	end -- 418
	do -- 418
		local i = 0 -- 424
		while i < POOL_SMALL do -- 424
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 425
			if lb ~= nil then -- 425
				poolSmall[#poolSmall + 1] = lb -- 427
			end -- 427
			i = i + 1 -- 424
		end -- 424
	end -- 424
	if mode == 1 then -- 424
		local loaded = loadSave() -- 434
		profile = loaded.state -- 435
		profileStatus = loaded.status -- 436
		profileDetail = loaded.detail -- 437
	end -- 437
	fe = __TS__New(WatchFrontend, parent) -- 439
	fe.screen = startScreen -- 440
	if startScreen == "splash" then -- 440
		fe.menus:resetSplash() -- 442
	end -- 442
	refreshTitleSessionFlag() -- 444
	grayboxLayer.visible = mode == 0 -- 445
	fe:setVisible(mode == 1) -- 446
	input = __TS__New(Input) -- 448
	fe.audio:applyUserVolumes(input.settings) -- 449
	touchRouter = __TS__New(TouchRouter, input.settings) -- 450
	touchRouter:attach(parent) -- 451
	input:bindTouch(touchRouter) -- 452
	gamepadRouter = __TS__New(GamepadRouter, input.settings) -- 454
	gamepadRouter:attach(parent) -- 455
	input:bindGamepad(gamepadRouter) -- 456
	touchControls = __TS__New(TouchControls, parent) -- 458
	parent:gslot( -- 461
		"AppEvent", -- 461
		function(eventType) -- 461
			if eventType == "BackButton" then -- 461
				handleBackButton() -- 463
				return -- 464
			end -- 464
			if eventType == "Quit" or eventType == "Shutdown" then -- 464
				flushProfile() -- 467
				saveCurrentSession() -- 468
				if input ~= nil then -- 468
					input:clearTransient(false) -- 469
				end -- 469
				return -- 470
			end -- 470
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 470
				flushProfile() -- 473
				saveCurrentSession() -- 474
				if input ~= nil then -- 474
					input:clearTransient(true) -- 475
				end -- 475
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.escortFailed then -- 475
					play.paused = true -- 477
					play.aimHold = 0 -- 478
					play.bottleAimX = -1 -- 479
					fe.menus:openPause() -- 480
				end -- 480
				if fe ~= nil then -- 480
					fe.audio:setPaused(true) -- 483
				end -- 483
				return -- 485
			end -- 485
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 485
				if fe ~= nil then -- 485
					local paused = play ~= nil and play.paused and mode == 1 and fe.screen == "play" -- 489
					fe.audio:setPaused(paused) -- 490
				end -- 490
			end -- 490
		end -- 461
	) -- 461
	parent:onKeyDown(function(key) -- 496
		onFirstUserGesture() -- 497
		if input ~= nil then -- 497
			input:markKeyboardActivity() -- 498
		end -- 498
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 498
			toggleFullscreen() -- 501
			return -- 502
		end -- 502
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 502
			if play.escortFailed then -- 502
				if key == "Left" or key == "A" then -- 502
					fe.talentDraft.deathSelected = 0 -- 507
					return -- 508
				end -- 508
				if key == "Right" or key == "D" then -- 508
					fe.talentDraft.deathSelected = 1 -- 511
					return -- 512
				end -- 512
				if key == "Escape" then -- 512
					fe.audio:stopRoomTransient() -- 515
					fe.menus:resetInput() -- 516
					fe.screen = "title" -- 517
					if input ~= nil then -- 517
						input:clearTransient(true) -- 518
					end -- 518
					return -- 519
				end -- 519
				if (key == "Return" or key == "Space") and play.escortFailedTicks >= 24 then -- 519
					if fe.talentDraft.deathSelected == 0 then -- 519
						play:confirmEscortRestart() -- 523
						applyRoomTransition(play) -- 524
					else -- 524
						fe.audio:stopRoomTransient() -- 526
						fe.menus:resetInput() -- 527
						fe.screen = "title" -- 528
						if input ~= nil then -- 528
							input:clearTransient(true) -- 529
						end -- 529
					end -- 529
					return -- 531
				end -- 531
				if key == "R" and play.escortFailedTicks >= 24 then -- 531
					play:confirmEscortRestart() -- 534
					applyRoomTransition(play) -- 535
					return -- 536
				end -- 536
				return -- 538
			end -- 538
			if not play.craftBench.active and not play.reloadOpen then -- 538
				local offers = play:getStoryTalentOffers() -- 541
				if #offers > 0 then -- 541
					if key == "1" then -- 541
						play:chooseTalent(0) -- 544
						if input ~= nil then -- 544
							input:consumePickRoom() -- 545
						end -- 545
						return -- 546
					end -- 546
					if key == "2" then -- 546
						play:chooseTalent(1) -- 549
						if input ~= nil then -- 549
							input:consumePickRoom() -- 550
						end -- 550
						return -- 551
					end -- 551
					if key == "3" then -- 551
						play:chooseTalent(2) -- 554
						if input ~= nil then -- 554
							input:consumePickRoom() -- 555
						end -- 555
						return -- 556
					end -- 556
					if play.talentModalActive then -- 556
						if key == "Left" or key == "A" then -- 556
							fe.talentDraft.selected = (fe.talentDraft.selected + #offers - 1) % #offers -- 560
							fe.hud.talentSelected = fe.talentDraft.selected -- 561
							return -- 562
						end -- 562
						if key == "Right" or key == "D" then -- 562
							fe.talentDraft.selected = (fe.talentDraft.selected + 1) % #offers -- 565
							fe.hud.talentSelected = fe.talentDraft.selected -- 566
							return -- 567
						end -- 567
						if key == "Return" or key == "Space" then -- 567
							play:chooseTalent(fe.talentDraft.selected) -- 570
							return -- 571
						end -- 571
					end -- 571
				end -- 571
			end -- 571
			if key == "T" and not (play.talentModalActive and #play:getStoryTalentOffers() > 0) then -- 571
				play:toggleArtifactWeapon() -- 577
				return -- 578
			end -- 578
		end -- 578
		local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 581
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 581
			fe.menus:onKeyEvent(key) -- 583
		end -- 583
		if input ~= nil and mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay then -- 583
			if key == "E" then -- 583
				input.interact.pressed = true -- 587
			elseif key == "Space" then -- 587
				input.jump.pressed = true -- 589
			elseif key == "Escape" then -- 589
				input.pause.pressed = true -- 591
			elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen and not play.talentModalActive) then -- 591
				input.retry.pressed = true -- 593
			end -- 593
		end -- 593
		if isReleaseBuild() then -- 593
			return -- 596
		end -- 596
		if key == "F1" then -- 596
			enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 598
		elseif key == "F2" then -- 598
			setMode(0) -- 600
		elseif key == "1" then -- 600
			pickByIndex(0) -- 602
		elseif key == "2" then -- 602
			pickByIndex(1) -- 604
		elseif key == "3" then -- 604
			pickByIndex(2) -- 606
		elseif key == "4" then -- 606
			pickByIndex(3) -- 608
		elseif key == "5" then -- 608
			pickByIndex(4) -- 610
		elseif key == "6" then -- 610
			pickByIndex(5) -- 612
		elseif key == "7" then -- 612
			pickByIndex(6) -- 614
		elseif key == "8" then -- 614
			pickByIndex(7) -- 616
		end -- 616
	end) -- 496
	viewW = View.size.width -- 620
	viewH = View.size.height -- 621
	applySize() -- 622
	local reg = _G.package.loaded -- 625
	reg["watch.input"] = input -- 626
	reg["watch.touch"] = touchRouter -- 627
	reg["watch.gamepad"] = gamepadRouter -- 628
	reg["watch.fe"] = { -- 629
		setScreen = function(sc) -- 630
			if fe == nil then -- 630
				return -- 632
			end -- 632
			setMode(1) -- 634
			fe.screen = sc -- 635
			if sc == "splash" then -- 635
				fe.menus:resetSplash() -- 637
			elseif sc == "chapters" then -- 637
				fe.menus:openChapters() -- 639
			elseif sc == "epilogue" then -- 639
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 641
			elseif sc == "history" then -- 641
				fe.menus:openHistory(false) -- 646
			else -- 646
				fe.menus:resetInput() -- 648
			end -- 648
			if sc == "play" then -- 648
				ensurePlay() -- 651
			end -- 651
		end, -- 630
		jumpRoom = function(keyOrIdx) -- 654
			local idx = -1 -- 655
			if type(keyOrIdx) == "number" then -- 655
				idx = keyOrIdx -- 657
			else -- 657
				local k = 0 -- 659
				do -- 659
					k = 0 -- 660
					while k < #ROOMS do -- 660
						if ROOMS[k + 1].key == keyOrIdx then -- 660
							idx = k -- 662
						end -- 662
						k = k + 1 -- 660
					end -- 660
				end -- 660
			end -- 660
			if idx >= 0 and idx < #ROOMS then -- 660
				enterPlayRoom(idx, "debug") -- 667
			end -- 667
		end, -- 654
		getPlay = function() return play end, -- 670
		getFrontend = function() return fe end, -- 671
		startStory = function(seed) -- 673
			enterPlayRoom( -- 674
				officialStartIndex(), -- 674
				"official", -- 674
				true, -- 674
				seed -- 674
			) -- 674
			return play -- 675
		end, -- 673
		previewChapter = function(idx, seed) -- 678
			enterPlayRoom(idx, "chapter", false, seed) -- 679
			return play -- 680
		end, -- 678
		getStoryRun = function() return storyRun end, -- 682
		getProfilePending = function() return profilePending() end, -- 683
		flushProfileNow = function() return flushProfile() end, -- 684
		getProfile = function() return profile end, -- 686
		getProfileStatus = function() return profileStatus end, -- 687
		getProfileDetail = function() return profileDetail end, -- 688
		useTestSave = function(name) -- 689
			setSaveFile(name) -- 690
			setSessionFile(name == "" and "" or name .. ".session") -- 691
			clearProfilePending() -- 692
			local loaded = loadSave() -- 693
			profile = loaded.state -- 694
			profileStatus = loaded.status -- 695
			profileDetail = loaded.detail -- 696
			refreshTitleSessionFlag() -- 697
		end, -- 689
		useTestSession = function(name) -- 699
			setSessionFile(name) -- 700
			refreshTitleSessionFlag() -- 701
		end, -- 699
		getSessionFile = getSessionFile, -- 703
		hasSessionSave = hasSessionSave, -- 704
		saveSessionNow = function() return saveCurrentSession() end, -- 705
		clearSessionNow = function() -- 706
			local ok = clearSession() -- 707
			refreshTitleSessionFlag() -- 708
			return ok -- 709
		end, -- 706
		continueStory = function() return continueOfficialStory() end, -- 711
		saveNow = function() return saveSave(profile) end, -- 712
		getSaveFile = getSaveFile, -- 713
		isRelease = function() return isReleaseBuild() end, -- 714
		getReleaseVersion = function() -- 715
			local ____opt_31 = getReleaseConfig() -- 715
			return ____opt_31 and ____opt_31.version or "dev" -- 715
		end, -- 715
		toggleFullscreen = function() return toggleFullscreen() end, -- 716
		quitGame = function() return quitGame() end, -- 717
		handleBackButton = function() return handleBackButton() end, -- 718
		getViewport = function() return stageVp end, -- 719
		getTouchController = function() return touchControls end, -- 720
		getTouchRouter = function() return touchRouter end, -- 721
		getGamepad = function() return gamepadRouter end, -- 722
		setGamepadSim = function(state) -- 723
			if gamepadRouter ~= nil then -- 723
				gamepadRouter:setSimulatedState(state) -- 724
			end -- 724
		end, -- 723
		injectTouch = function(phase, id, x, y, fromMouse) -- 726
			if touchRouter ~= nil then -- 726
				touchRouter:injectTouch( -- 727
					phase, -- 727
					id, -- 727
					x, -- 727
					y, -- 727
					fromMouse -- 727
				) -- 727
			end -- 727
		end, -- 726
		getInputMode = function() return input and input.inputMode or "kbm" end, -- 729
		setInputMode = function(m) -- 730
			if input ~= nil then -- 730
				input:setInputMode(m) -- 731
			end -- 731
		end, -- 730
		setModePref = function(pref) -- 733
			if input ~= nil then -- 733
				input:setModePref(pref) -- 734
			end -- 734
		end, -- 733
		applyViewportForTest = function(w, h) -- 736
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 736
				testViewportOverride = {w = w, h = h} -- 738
				viewW = w -- 739
				viewH = h -- 740
			else -- 740
				testViewportOverride = nil -- 742
				viewW = View.size.width -- 743
				viewH = View.size.height -- 744
			end -- 744
			applySize() -- 746
			dirty = true -- 747
			return stageVp -- 748
		end, -- 736
		getToast = function() return fe and fe:getToastText() or "" end -- 750
	} -- 750
	if mode == 1 and startScreen == "play" then -- 750
		ensurePlay() -- 754
	end -- 754
	parent:schedule(function(frameDt) -- 757
		tick(frameDt) -- 758
		return false -- 759
	end) -- 757
end -- 397
return ____exports -- 397