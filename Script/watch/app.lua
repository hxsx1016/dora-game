-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local ____exports = {} -- 1
local randomRunSeed, isReleaseBuild, onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, place, setMode, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, pickByIndex, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, applyRoomTransition, tickFrontend, redrawGraybox, applyPool, LAYOUT_AUDIT, C_BG, TOP_H, BOTTOM_H, root, grayboxLayer, draw, titleLabel, roomLabel, captionLabel, hintLabel, switchLabel, storyRun, profile, rulerLabel, standLabel, cartLabel, poolBody, poolSmall, current, viewW, viewH, dirty, mode, input, touchRouter, gamepadRouter, touchControls, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock -- 91
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
	if audioUnlocked or fe == nil then -- 100
		return -- 101
	end -- 101
	audioUnlocked = true -- 103
	fe.audio:unlockAndResyncAfterGesture() -- 104
end -- 104
function toggleFullscreen() -- 107
	if not canToggleFullscreen() then -- 108
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
	if input ~= nil then -- 123
		input:clearTransient(false) -- 123
	end -- 123
	if fe ~= nil then -- 124
		fe.audio:stopRoomTransient() -- 125
	end -- 125
	if not canQuitApp() then -- 127
		current = 0 -- 129
		play = nil -- 130
		setMode(1) -- 131
		if fe ~= nil then -- 132
			fe.audio:stopRoomTransient() -- 133
			fe.screen = "title" -- 134
			fe.menus:resetInput() -- 135
		end -- 135
		return -- 137
	end -- 137
	App:shutdown() -- 139
end -- 139
function canSaveSession() -- 198
	if mode ~= 1 or play == nil or storyRun == nil then -- 199
		return false -- 200
	end -- 200
	if storyRun.source ~= "official" or play.run.finished then -- 202
		return false -- 203
	end -- 203
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 205
		return false -- 206
	end -- 206
	return true -- 208
end -- 208
function refreshTitleSessionFlag() -- 211
	if fe ~= nil then -- 212
		fe.menus.hasSession = hasSessionSave() -- 213
	end -- 213
end -- 213
function saveCurrentSession() -- 217
	if not canSaveSession() or play == nil then -- 218
		return false -- 219
	end -- 219
	play.sessionDirty = false -- 221
	local ok = saveSession(play:exportSession()) -- 222
	refreshTitleSessionFlag() -- 223
	return ok -- 224
end -- 224
function continueOfficialStory() -- 227
	local res = loadSession() -- 228
	if res.status ~= "ok" or res.state == nil then -- 229
		refreshTitleSessionFlag() -- 230
		return nil -- 231
	end -- 231
	local s = res.state -- 233
	local idx = roomIndexByKey(s.roomKey) -- 234
	if ROOMS[idx + 1].key ~= s.roomKey then -- 235
		return nil -- 236
	end -- 236
	storyRun = createRun(s.seed, "official", profile) -- 238
	storyRun.checkpoint = s.checkpoint -- 239
	storyRun.story.route = s.route -- 240
	storyRun.story.hp = s.hp -- 241
	storyRun.story.maxHp = s.maxHp -- 242
	storyRun.story.hpAtGate = s.hpAtGate -- 243
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 244
	storyRun.story.settled = s.settled -- 245
	storyRun.story.phase = s.phase -- 246
	storyRun.story.countTick = s.countTick -- 247
	storyRun.story.phaseTick = s.phaseTick -- 248
	storyRun.story.handTicks = s.handTicks -- 249
	storyRun.story.handDone = s.handDone -- 250
	storyRun.story.lineSaid = s.lineSaid -- 251
	storyRun.story.tied = s.tied -- 252
	storyRun.story.carry = s.carry -- 253
	storyRun.story.escortDone = s.escortDone -- 254
	storyRun.story.craftedWeapon = s.craftedWeapon -- 255
	storyRun.story.equippedWeapon = s.equippedWeapon -- 256
	storyRun.inventory.wood = s.wood -- 257
	storyRun.inventory.bell = s.bell -- 258
	storyRun.inventory.scrap = s.scrap -- 259
	storyRun.inventory.wedge = s.wedge -- 260
	storyRun.inventory.ammo = s.ammo -- 261
	storyRun.inventory.shield = s.shield -- 262
	storyRun.inventory.pass = s.pass -- 263
	storyRun.inventory.quickbelt = s.quickbelt -- 264
	local k = 0 -- 265
	do -- 265
		k = 0 -- 266
		while k < #s.taken do -- 266
			storyRun.taken[s.taken[k + 1]] = true -- 267
			k = k + 1 -- 266
		end -- 266
	end -- 266
	do -- 266
		k = 0 -- 269
		while k < #s.segments do -- 269
			storyRun.story.segments[s.segments[k + 1]] = true -- 270
			k = k + 1 -- 269
		end -- 269
	end -- 269
	if s.campaignRoute ~= nil then -- 272
		storyRun.route = s.campaignRoute -- 273
	end -- 273
	if s.joined ~= nil then -- 275
		storyRun.joined = s.joined -- 276
	end -- 276
	if s.c1Latch ~= nil then -- 278
		storyRun.c1Latch = s.c1Latch -- 279
	end -- 279
	if s.c2Latch ~= nil then -- 281
		storyRun.c2Latch = s.c2Latch -- 282
	end -- 282
	if s.props ~= nil then -- 284
		do -- 284
			k = 0 -- 285
			while k < #s.props do -- 285
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 286
				local pid = parts[1] -- 287
				if pid ~= nil and pid ~= "" then -- 288
					local ____storyRun_props_10 = storyRun.props -- 289
					local ____temp_6 -- 290
					if parts[2] == nil then -- 290
						____temp_6 = true -- 290
					else -- 290
						____temp_6 = parts[2] == "1" -- 290
					end -- 290
					local ____temp_8 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 291
					local ____temp_9 = parts[4] == "1" -- 292
					local ____temp_7 -- 293
					if parts[5] == "1" then -- 293
						____temp_7 = true -- 293
					else -- 293
						____temp_7 = nil -- 293
					end -- 293
					____storyRun_props_10[pid] = {broken = ____temp_6, hp = ____temp_8, wedge = ____temp_9, revealed = ____temp_7} -- 289
				end -- 289
				k = k + 1 -- 285
			end -- 285
		end -- 285
	end -- 285
	local stTalents = createStoryTalents(s.seed) -- 298
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 299
		stTalents.randomState = s.talentSeed -- 300
	end -- 300
	if s.escortAttempt ~= nil and s.escortAttempt >= 1 then -- 302
		stTalents.attempt = s.escortAttempt -- 303
	end -- 303
	if s.escortVariant ~= nil and s.escortVariant >= 0 then -- 305
		stTalents.variant = s.escortVariant -- 306
	end -- 306
	stTalents.deferred = s.talentDeferred == true -- 308
	stTalents.room = s.talentRoom or "" -- 309
	if s.talentRanks ~= nil and #s.talentRanks > 0 then -- 310
		do -- 310
			k = 0 -- 311
			while k < #s.talentRanks do -- 311
				local parts = __TS__StringSplit(s.talentRanks[k + 1], ":") -- 312
				local ____temp_11 -- 313
				if parts[1] ~= nil then -- 313
					____temp_11 = normalizeLegacyTalent(parts[1]) -- 313
				else -- 313
					____temp_11 = nil -- 313
				end -- 313
				local norm = ____temp_11 -- 313
				local rk = parts[2] ~= nil and (tonumber(parts[2]) or 0) or 0 -- 314
				if norm ~= nil and rk > 0 then -- 315
					stTalents.ranks[norm] = (stTalents.ranks[norm] or 0) + math.floor(rk) -- 316
				end -- 316
				k = k + 1 -- 311
			end -- 311
		end -- 311
	else -- 311
		stTalents.ranks.vitality = s.talentVitality or 0 -- 321
		stTalents.ranks.focus = s.talentReload or 0 -- 322
		stTalents.ranks.guard = s.talentGuard or 0 -- 323
		stTalents.ranks.salvage = s.talentCraft or 0 -- 324
	end -- 324
	if s.talentOffers ~= nil then -- 326
		do -- 326
			k = 0 -- 327
			while k < #s.talentOffers do -- 327
				local norm = normalizeLegacyTalent(s.talentOffers[k + 1]) -- 328
				if norm ~= nil then -- 329
					local ____stTalents_offers_12 = stTalents.offers -- 330
					____stTalents_offers_12[#____stTalents_offers_12 + 1] = norm -- 330
				end -- 330
				k = k + 1 -- 327
			end -- 327
		end -- 327
	end -- 327
	storyRun.story.talents = stTalents -- 334
	current = idx -- 335
	setMode(1) -- 336
	if fe ~= nil then -- 337
		fe.screen = "play" -- 338
	end -- 338
	play = nil -- 340
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 341
	local cur = play -- 342
	if cur ~= nil then -- 343
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 344
			cur.cartAxle = s.cartAxle -- 345
			cur.cartDocked = s.cartDocked -- 346
		end -- 346
		if s.playerX ~= nil and s.playerX >= 0 then -- 348
			cur.player.x = math.max( -- 349
				cur.room.minX + 16, -- 349
				math.min(cur.room.maxX - 16, s.playerX) -- 349
			) -- 349
			cur.player.y = math.max(0, s.playerY or 0) -- 350
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 351
				cur.player.depth = math.max( -- 352
					cur.room.depth.min, -- 352
					math.min(cur.room.depth.max, s.playerDepth) -- 352
				) -- 352
			end -- 352
		end -- 352
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 355
			cur.gateTick = s.gateTick -- 356
		end -- 356
		if cur.room.key == "village" then -- 358
			if s.hasBottle == true then -- 359
				cur.hasBottle = true -- 359
			end -- 359
			if s.villagePassed == true then -- 360
				cur.passed = true -- 360
			end -- 360
		end -- 360
	end -- 360
	return play -- 363
end -- 363
function place(lb, x, y, ax, ay) -- 381
	if lb == nil then -- 382
		return -- 383
	end -- 383
	lb.position = Vec2(x, y) -- 385
	lb.anchor = Vec2(ax, ay) -- 386
	lb.visible = true -- 387
end -- 387
function setMode(nextMode) -- 756
	mode = nextMode == 0 and 0 or 1 -- 757
	if grayboxLayer ~= nil then -- 758
		grayboxLayer.visible = mode == 0 -- 759
	end -- 759
	if fe ~= nil then -- 761
		fe:setVisible(mode == 1) -- 762
	end -- 762
	dirty = true -- 764
	clock:reset() -- 765
end -- 765
function flushProfile() -- 772
	local cur = play -- 773
	if cur ~= nil and cur.archiveDirty then -- 774
		cur.archiveDirty = false -- 775
		markProfilePending(profile) -- 776
	end -- 776
	local ok = flushSaveProfile() -- 778
	if not ok and cur ~= nil then -- 779
		cur.archiveDirty = true -- 780
	end -- 780
	return ok -- 782
end -- 782
function officialStartIndex() -- 786
	local mp = profile.museumPhase -- 787
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 788
	return inMuseum and roomIndexByKey("museum") or 0 -- 789
end -- 789
function roomIndexByKey(key) -- 792
	local i = 0 -- 793
	do -- 793
		i = 0 -- 794
		while i < #ROOMS do -- 794
			if ROOMS[i + 1].key == key then -- 795
				return i -- 796
			end -- 796
			i = i + 1 -- 794
		end -- 794
	end -- 794
	return 0 -- 799
end -- 799
function enterPlayRoom(idx, source, fresh, seedOverride) -- 802
	if source == nil then -- 802
		source = "debug" -- 802
	end -- 802
	if fresh == nil then -- 802
		fresh = false -- 802
	end -- 802
	current = idx -- 803
	setMode(1) -- 804
	if fe ~= nil then -- 805
		fe.screen = "play" -- 806
	end -- 806
	play = nil -- 808
	if fresh or source == "chapter" or storyRun == nil then -- 810
		local seed = seedOverride ~= nil and seedOverride or ((source == "official" or source == "chapter") and randomRunSeed() or 20261124) -- 811
		storyRun = createRun(seed, source, profile) -- 814
		if source == "chapter" then -- 815
			local targetKey = ROOMS[idx + 1].key -- 816
			if targetKey == "gatepath" or targetKey == "escort1" or targetKey == "escort2" or targetKey == "escort3" or targetKey == "escort4" or targetKey == "escort5" then -- 817
				storyRun.story.route = "soldier" -- 819
				storyRun.story.settled = true -- 820
				storyRun.story.hp = 3 -- 821
				storyRun.story.maxHp = 3 -- 822
				storyRun.story.hpAtGate = 3 -- 823
				storyRun.story.maxHpAtGate = 3 -- 824
				storyRun.story.handDone = true -- 825
				storyRun.story.tied = true -- 826
				storyRun.story.carry = targetKey ~= "gatepath" -- 827
				storyRun.joined = true -- 828
				if targetKey == "escort3" or targetKey == "escort4" or targetKey == "escort5" then -- 829
					storyRun.inventory.wood = 2 -- 830
					storyRun.inventory.bell = 1 -- 831
				end -- 831
			elseif targetKey == "outside" or targetKey == "village" or targetKey == "forest" then -- 833
				storyRun.story.route = "child" -- 834
				storyRun.story.settled = true -- 835
				storyRun.story.countTick = 1440 -- 836
			end -- 836
		end -- 836
	else -- 836
		storyRun.source = source -- 840
	end -- 840
	ensurePlay() -- 842
	local firstPlay = play -- 844
	if fresh and source == "official" and firstPlay ~= nil and ROOMS[current + 1].key == "prologue" then -- 845
		firstPlay.phase = "prologue-wake" -- 846
	end -- 846
	flushProfile() -- 848
end -- 848
function pickByIndex(idx, source) -- 851
	if source == nil then -- 851
		source = "debug" -- 851
	end -- 851
	if idx < 0 or idx >= #ROOMS then -- 852
		return -- 853
	end -- 853
	flushProfile() -- 855
	if storyRun ~= nil then -- 856
		storyRun.source = source -- 857
	end -- 857
	current = idx -- 859
	dirty = true -- 860
	play = nil -- 861
	clock:reset() -- 862
	if mode == 1 then -- 863
		if fe ~= nil then -- 864
			fe.screen = "play" -- 865
		end -- 865
		ensurePlay() -- 867
	end -- 867
end -- 867
function applySize() -- 871
	if root == nil then -- 872
		return -- 873
	end -- 873
	root.size = Size(viewW, viewH) -- 875
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 876
	stageVp = computeStageViewport(viewW, viewH) -- 877
	if input ~= nil then -- 878
		input:setStageViewport(stageVp) -- 879
	end -- 879
	if fe ~= nil then -- 881
		fe:setStagePlacement(stageVp) -- 882
	end -- 882
	if grayboxLayer ~= nil then -- 884
		grayboxLayer.position = Vec2(0, 0) -- 885
	end -- 885
end -- 885
function syncFrameAdapters(frameDt) -- 889
	if input == nil then -- 890
		return -- 891
	end -- 891
	local p = play -- 893
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 894
	local gameplayActive = isPlayMode -- 895
	local storyTalentBoxes = isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and fe:getStoryTalentBoxes( -- 897
		p, -- 899
		stageVp.stageW, -- 899
		stageVp.stageH, -- 899
		input:isTouchMode() -- 899
	) or ({}) -- 900
	local ____temp_43 -- 901
	if isPlayMode and fe ~= nil and p ~= nil and not p.paused and p.escortFailed then -- 901
		____temp_43 = fe:getEscortDeathBoxes(p, stageVp.stageW, stageVp.stageH) -- 903
	else -- 903
		____temp_43 = nil -- 904
	end -- 904
	local escortDeathBoxes = ____temp_43 -- 901
	if touchControls ~= nil and touchRouter ~= nil then -- 906
		local isFs = false -- 907
		if canToggleFullscreen() then -- 908
			do -- 908
				local function ____catch() -- 908
					isFs = false -- 912
				end -- 912
				local ____try = pcall(function() -- 912
					isFs = App.fullScreen -- 910
				end) -- 910
				if not ____try then -- 910
					____catch() -- 910
				end -- 910
			end -- 910
		end -- 910
		local ____touchControls_53 = touchControls -- 915
		local ____touchControls_syncContext_54 = touchControls.syncContext -- 915
		local ____stageVp_46 = stageVp -- 916
		local ____mode_47 = mode -- 917
		local ____temp_48 = fe ~= nil and fe.screen or "title" -- 918
		local ____storyRun_49 = storyRun -- 920
		local ____temp_50 = fe ~= nil and fe.cam or nil -- 921
		local ____input_51 = input -- 922
		local ____touchRouter_52 = touchRouter -- 923
		local ____temp_44 -- 924
		if fe ~= nil then -- 924
			____temp_44 = fe.contract:isAssistHintsEnabled() -- 924
		else -- 924
			____temp_44 = false -- 924
		end -- 924
		local ____temp_45 -- 925
		if fe ~= nil then -- 925
			____temp_45 = fe.audio:isAllMuted() -- 925
		else -- 925
			____temp_45 = false -- 925
		end -- 925
		____touchControls_syncContext_54(____touchControls_53, { -- 915
			viewport = ____stageVp_46, -- 916
			mode = ____mode_47, -- 917
			screen = ____temp_48, -- 918
			play = p, -- 919
			run = ____storyRun_49, -- 920
			cam = ____temp_50, -- 921
			input = ____input_51, -- 922
			router = ____touchRouter_52, -- 923
			assistHintsEnabled = ____temp_44, -- 924
			isMuted = ____temp_45, -- 925
			isFullscreen = isFs, -- 926
			storyTalentBoxes = storyTalentBoxes, -- 927
			escortDeathBoxes = escortDeathBoxes, -- 928
			dt = frameDt -- 929
		}) -- 929
	end -- 929
	if gamepadRouter ~= nil then -- 933
		local talentOfferCount = isPlayMode and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and #p:getStoryTalentOffers() or 0 -- 934
		local talentBlocking = isPlayMode and p ~= nil and p.talentModalActive and talentOfferCount > 0 -- 937
		local modal = not gameplayActive or isPlayMode and p ~= nil and (p.paused or p.reloadOpen or p.craftBench.active or p.escortFailed or talentBlocking) -- 938
		local reloadActive = isPlayMode and p ~= nil and not p.paused and p.reloadOpen -- 940
		local craftActive = isPlayMode and p ~= nil and not p.paused and p.craftBench.active -- 941
		local ____temp_55 -- 942
		if isPlayMode and p ~= nil then -- 942
			____temp_55 = isCutsceneBlockingPlay(p) -- 942
		else -- 942
			____temp_55 = false -- 942
		end -- 942
		local cutsceneBlocking = ____temp_55 -- 942
		local allowDepth = p ~= nil and p.room.depth ~= nil and (not p.childMode or p.phase == "prologue-escape") -- 943
		local peacefulRoom = p ~= nil and (p.room.key == "museum" or p.room.key == "tower") -- 945
		local canShoot = gameplayActive and p ~= nil and not p.childMode and not peacefulRoom and not p.gripping and not modal and not cutsceneBlocking and p.escort.state ~= "calming" -- 946
		local canBottleAim = isPlayMode and p ~= nil and p.childMode and p.room.key == "village" and p.hasBottle and not p.passed and not modal and not cutsceneBlocking -- 948
		local inLowArch = p ~= nil and p.room.arch.h > 0 and p.player.x >= p.room.arch.x0 - 10 and p.player.x <= p.room.arch.x1 + 10 and p.player.y <= p.room.arch.y + p.room.arch.h -- 950
		local inTowerEnd = isPlayMode and p ~= nil and p.room.key == "tower" and p.phase == "tower-end" -- 953
		local playerScreenX = stageVp.stageW * 0.5 -- 955
		local playerScreenY = stageVp.stageH * 0.38 -- 956
		if p ~= nil and isPlayMode and fe ~= nil then -- 957
			playerScreenX = fe.cam:sx(p.player.x + p.player.facing * 8) -- 958
			playerScreenY = fe.cam:sy(p.player.y + p.player.h * 0.72, p.player.depth) -- 959
		end -- 959
		local enemyTargets = canShoot and p ~= nil and isPlayMode and fe ~= nil and collectPlayAimTargets(p, fe.cam, stageVp.stageW, stageVp.stageH) or ({}) -- 962
		local gpCtx = { -- 966
			stageW = stageVp.stageW, -- 967
			stageH = stageVp.stageH, -- 968
			uiScale = stageVp.uiScale, -- 969
			modal = modal, -- 970
			gameplayActive = gameplayActive, -- 971
			reloadActive = reloadActive, -- 972
			craftActive = craftActive, -- 973
			talentOfferCount = talentOfferCount, -- 974
			childMode = p ~= nil and p.childMode, -- 975
			allowDepth = allowDepth, -- 976
			canShoot = canShoot, -- 977
			canBottleAim = canBottleAim, -- 978
			playerRolling = p ~= nil and p.player.rollT > 0, -- 979
			inLowArch = inLowArch, -- 980
			inTowerEnd = inTowerEnd, -- 981
			playerFacing = p ~= nil and p.player.facing or 1, -- 982
			playerScreenX = playerScreenX, -- 983
			playerScreenY = playerScreenY, -- 984
			enemyTargets = enemyTargets -- 985
		} -- 985
		gamepadRouter:setFrameContext(gpCtx, frameDt) -- 987
	end -- 987
end -- 987
function renderTouchOverlay() -- 991
	if touchControls ~= nil and touchRouter ~= nil then -- 992
		touchControls:render(touchRouter) -- 993
	end -- 993
end -- 993
function tick(frameDt) -- 997
	appClock = appClock + math.min( -- 998
		0.05, -- 998
		math.max(0, frameDt) -- 998
	) -- 998
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 999
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 1000
	if w ~= viewW or h ~= viewH then -- 1001
		viewW = w -- 1002
		viewH = h -- 1003
		applySize() -- 1004
		dirty = true -- 1005
	end -- 1005
	if input == nil then -- 1007
		return -- 1008
	end -- 1008
	syncFrameAdapters(frameDt) -- 1010
	input:update() -- 1011
	if input.userInteracted then -- 1013
		onFirstUserGesture() -- 1014
	end -- 1014
	if input.muteTogglePressed and fe ~= nil then -- 1016
		input.muteTogglePressed = false -- 1017
		fe.audio:toggleAllMuted() -- 1018
	end -- 1018
	if input.fullscreenTogglePressed then -- 1020
		input.fullscreenTogglePressed = false -- 1021
		toggleFullscreen() -- 1022
	end -- 1022
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.escortFailed then -- 1024
		input.artifactTogglePressed = false -- 1025
		play:toggleArtifactWeapon() -- 1026
	end -- 1026
	if input.bottleCanceled and play ~= nil then -- 1028
		input.bottleCanceled = false -- 1029
		play.aimHold = 0 -- 1030
		play.bottleAimX = -1 -- 1031
	end -- 1031
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and not play.escortFailed and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 1034
		play:chooseTalent(input.pickRoom - 1) -- 1037
		input.pickRoom = 0 -- 1038
	end -- 1038
	if isReleaseBuild() then -- 1041
		input.toggleView.pressed = false -- 1042
		input.pickRoom = 0 -- 1043
		input.tab.pressed = false -- 1044
	else -- 1044
		if input.toggleView.pressed then -- 1047
			input.toggleView.pressed = false -- 1048
			setMode(mode == 0 and 1 or 0) -- 1049
			if mode == 1 and fe ~= nil and fe.screen == "play" and play == nil then -- 1050
				ensurePlay() -- 1051
			end -- 1051
		end -- 1051
		if input.pickRoom ~= 0 then -- 1056
			local idx = input.pickRoom - 1 -- 1057
			input.pickRoom = 0 -- 1058
			pickByIndex(idx) -- 1059
		elseif input.tab.pressed then -- 1060
			input.tab.pressed = false -- 1061
			if mode == 0 or (fe and fe.screen) == "play" and not (play and play.paused) then -- 1062
				pickByIndex((current + 1) % #ROOMS) -- 1063
			end -- 1063
		end -- 1063
	end -- 1063
	if mode == 1 then -- 1068
		tickFrontend(frameDt) -- 1069
	elseif dirty then -- 1070
		redrawGraybox() -- 1071
		dirty = false -- 1072
	end -- 1072
	renderTouchOverlay() -- 1074
end -- 1074
function registerPlay() -- 1078
	local reg = _G.package.loaded -- 1079
	reg["watch.play"] = play -- 1080
	reg["watch.room"] = ROOMS[current + 1].key -- 1081
end -- 1081
function ensurePlay(resume) -- 1085
	if storyRun == nil then -- 1088
		storyRun = createRun(20261124, "debug", profile) -- 1089
	end -- 1089
	play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1091
	registerPlay() -- 1092
	clock:reset() -- 1093
	if fe ~= nil and mode == 1 then -- 1094
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1095
	end -- 1095
end -- 1095
function applyRoomTransition(p) -- 1100
	if p.wantRoom == "" then -- 1101
		return false -- 1102
	end -- 1102
	local key = p.wantRoom -- 1104
	p.wantRoom = "" -- 1105
	local idx = -1 -- 1106
	local j = 0 -- 1107
	do -- 1107
		j = 0 -- 1108
		while j < #ROOMS do -- 1108
			if ROOMS[j + 1].key == key then -- 1109
				idx = j -- 1110
			end -- 1110
			j = j + 1 -- 1108
		end -- 1108
	end -- 1108
	if idx < 0 then -- 1113
		return false -- 1114
	end -- 1114
	flushProfile() -- 1119
	local leaving = p:drainEvents() -- 1120
	if p.restartStory then -- 1122
		if storyRun ~= nil and storyRun.source == "official" then -- 1123
			clearSession() -- 1124
			refreshTitleSessionFlag() -- 1125
		end -- 1125
		local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1127
		local nextSeed = nextSource == "official" and randomRunSeed() or 20261124 -- 1128
		storyRun = createRun(nextSeed, nextSource, profile) -- 1129
	end -- 1129
	current = idx -- 1131
	ensurePlay() -- 1132
	local fresh = play -- 1133
	if fresh ~= nil then -- 1134
		if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1135
			fresh.phase = "prologue-wake" -- 1136
		end -- 1136
		fresh:adoptEvents(leaving) -- 1138
	end -- 1138
	if not p.restartStory then -- 1140
		saveCurrentSession() -- 1141
	end -- 1141
	clock:reset() -- 1143
	dirty = true -- 1144
	return true -- 1145
end -- 1145
function tickFrontend(frameDt) -- 1148
	if fe == nil or input == nil then -- 1149
		return -- 1150
	end -- 1150
	if fe.screen ~= "play" then -- 1154
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1155
		input:consumeEdges() -- 1156
		if act.type == "splashDone" then -- 1157
			fe.menus:resetInput() -- 1158
			fe.screen = "title" -- 1159
		elseif act.type == "continue" then -- 1160
			if continueOfficialStory() == nil then -- 1161
				enterPlayRoom( -- 1162
					officialStartIndex(), -- 1162
					"official", -- 1162
					true -- 1162
				) -- 1162
			end -- 1162
		elseif act.type == "start" then -- 1164
			clearSession() -- 1166
			refreshTitleSessionFlag() -- 1167
			enterPlayRoom( -- 1168
				officialStartIndex(), -- 1168
				"official", -- 1168
				true -- 1168
			) -- 1168
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1169
			enterPlayRoom(act.roomIndex, "chapter") -- 1170
		elseif act.type == "openChapters" then -- 1171
			fe.menus:openChapters() -- 1172
			fe.screen = "chapters" -- 1173
		elseif act.type == "openControls" then -- 1174
			fe.menus:resetInput() -- 1175
			fe.screen = "controls" -- 1176
		elseif act.type == "openHistory" then -- 1177
			fe.menus:openHistory(true) -- 1178
			fe.screen = "history" -- 1179
		elseif act.type == "backEpilogue" then -- 1180
			fe.menus:resetInput() -- 1181
			fe.screen = "epilogue" -- 1182
		elseif act.type == "replayStory" then -- 1183
			clearSession() -- 1184
			refreshTitleSessionFlag() -- 1185
			enterPlayRoom( -- 1186
				officialStartIndex(), -- 1186
				"official", -- 1186
				true -- 1186
			) -- 1186
		elseif act.type == "backTitle" then -- 1187
			fe.menus:resetInput() -- 1188
			fe.screen = "title" -- 1189
		elseif act.type == "backPause" then -- 1190
			fe.menus:resetInput() -- 1191
			fe.screen = "play" -- 1192
		elseif act.type == "quit" then -- 1193
			quitGame() -- 1194
		end -- 1194
		return -- 1196
	end -- 1196
	if play == nil then -- 1200
		ensurePlay() -- 1201
	end -- 1201
	if play == nil then -- 1203
		return -- 1204
	end -- 1204
	local p = play -- 1206
	p.aimX = input.mx -- 1208
	p.aimY = input.my -- 1209
	local zoneTap = input.touchZoneTap -- 1211
	input.touchZoneTap = "" -- 1212
	if not p.paused and p.escortFailed then -- 1215
		local deathAction = "" -- 1216
		if zoneTap == "escort:retry" and p.escortFailedTicks >= 12 then -- 1217
			deathAction = "retry" -- 1218
		elseif zoneTap == "escort:title" then -- 1219
			deathAction = "title" -- 1220
		else -- 1220
			if input.navLeft or input.navPrevTab then -- 1222
				fe.talentDraft.deathSelected = 0 -- 1223
			elseif input.navRight or input.navNextTab then -- 1224
				fe.talentDraft.deathSelected = 1 -- 1225
			end -- 1225
			if input.pause.pressed or input.navBack then -- 1227
				deathAction = "title" -- 1228
			elseif p.escortFailedTicks >= 24 and input.retry.pressed then -- 1229
				deathAction = "retry" -- 1230
			elseif p.escortFailedTicks >= 24 and input.navConfirm then -- 1231
				deathAction = fe.talentDraft.deathSelected == 0 and "retry" or "title" -- 1232
			elseif p.escortFailedTicks >= 12 and (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) then -- 1233
				deathAction = fe:tryPickEscortDeathAtPointer(p, input, stageVp.stageW, stageVp.stageH) -- 1235
			end -- 1235
		end -- 1235
		if deathAction == "retry" then -- 1238
			input:consumeEdges() -- 1239
			p:confirmEscortRestart() -- 1240
			applyRoomTransition(p) -- 1241
			return -- 1242
		end -- 1242
		if deathAction == "title" then -- 1244
			input:consumeEdges() -- 1245
			fe.audio:stopRoomTransient() -- 1246
			fe.menus:resetInput() -- 1247
			fe.screen = "title" -- 1248
			input:clearTransient(true) -- 1249
			return -- 1250
		end -- 1250
		input.pause.pressed = false -- 1252
		input.retry.pressed = false -- 1253
		input.fire.pressed = false -- 1254
	end -- 1254
	local offers = p:getStoryTalentOffers() -- 1257
	if not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and #offers > 0 then -- 1258
		if fe.talentDraft.selected >= #offers then -- 1259
			fe.talentDraft.selected = 0 -- 1260
		end -- 1260
		fe.hud.talentSelected = fe.talentDraft.selected -- 1262
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1263
			local idx = __TS__ParseInt( -- 1264
				string.sub(zoneTap, 8), -- 1264
				10 -- 1264
			) -- 1264
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1265
				fe.talentDraft.selected = idx -- 1266
				fe.hud.talentSelected = idx -- 1267
				input.fire.pressed = false -- 1268
			end -- 1268
		else -- 1268
			local navDelta = p.talentModalActive and ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) or 0 -- 1271
			local totalDelta = input.talentDelta + navDelta -- 1274
			if totalDelta ~= 0 then -- 1275
				fe.talentDraft.selected = (fe.talentDraft.selected + totalDelta + #offers) % #offers -- 1276
				fe.hud.talentSelected = fe.talentDraft.selected -- 1277
				input.talentDelta = 0 -- 1278
			end -- 1278
			if input.talentConfirm or p.talentModalActive and input.navConfirm then -- 1280
				p:chooseTalent(fe.talentDraft.selected) -- 1281
				input.talentConfirm = false -- 1282
				input.fire.pressed = false -- 1283
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1284
				input.fire.pressed = false -- 1286
			end -- 1286
		end -- 1286
	end -- 1286
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1292
		if input.navConfirm then -- 1293
			input.interact.pressed = true -- 1294
		end -- 1294
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1296
			flushProfile() -- 1297
			if p.run.source == "official" and hasSessionSave() then -- 1298
				clearSession() -- 1299
				refreshTitleSessionFlag() -- 1300
			end -- 1300
			fe.audio:stopRoomTransient() -- 1302
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1303
			fe.screen = "epilogue" -- 1307
			input:clearTransient(true) -- 1308
			input:consumeEdges() -- 1309
			return -- 1310
		end -- 1310
	end -- 1310
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1314
		p:closeCraftBench() -- 1315
		input:consumeEdges() -- 1316
		return -- 1317
	end -- 1317
	if not p.paused and not p.escortFailed and input.pause.pressed then -- 1319
		p.paused = true -- 1320
		p.aimHold = 0 -- 1321
		p.bottleAimX = -1 -- 1322
		saveCurrentSession() -- 1323
		fe.menus:openPause() -- 1324
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1325
		input:clearTransient(true) -- 1326
		input:consumeEdges() -- 1327
	end -- 1327
	if p.paused then -- 1330
		clock:reset() -- 1332
		local pauseAct = fe:renderPlay( -- 1333
			frameDt, -- 1333
			p, -- 1333
			input, -- 1333
			stageVp.stageW, -- 1333
			stageVp.stageH -- 1333
		) -- 1333
		input:consumeEdges() -- 1334
		if pauseAct.type == "resume" then -- 1335
			p.paused = false -- 1336
		elseif pauseAct.type == "retry" then -- 1337
			if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1338
				p:restartEscortRun() -- 1339
				applyRoomTransition(p) -- 1340
			else -- 1340
				ensurePlay({checkpoint = p.checkpoint}) -- 1342
			end -- 1342
		elseif pauseAct.type == "openChapters" then -- 1344
			fe.audio:stopRoomTransient() -- 1345
			fe.audio:setPaused(false) -- 1346
			fe.menus:openChapters(current) -- 1347
			fe.screen = "chapters" -- 1348
		elseif pauseAct.type == "toggleFullscreen" then -- 1349
			toggleFullscreen() -- 1350
		elseif pauseAct.type == "quit" then -- 1351
			quitGame() -- 1352
		elseif pauseAct.type == "toTitle" then -- 1353
			saveCurrentSession() -- 1354
			refreshTitleSessionFlag() -- 1355
			fe.menus:resetInput() -- 1356
			fe.screen = "title" -- 1357
		end -- 1357
		return -- 1359
	end -- 1359
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1362
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1363
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and not p.talentModalActive then -- 1365
		input:consumeEdges() -- 1366
		if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1367
			p:restartEscortRun() -- 1369
			applyRoomTransition(p) -- 1370
		else -- 1370
			ensurePlay({checkpoint = p.checkpoint}) -- 1373
		end -- 1373
		return -- 1375
	end -- 1375
	local steps = clock:advance(frameDt) -- 1378
	local i = 0 -- 1379
	do -- 1379
		i = 0 -- 1380
		while i < steps do -- 1380
			input:beginStep(i == 0) -- 1381
			p:update(STEP, input) -- 1382
			input:endStep() -- 1383
			if p.wantRoom ~= "" then -- 1384
				break -- 1385
			end -- 1385
			i = i + 1 -- 1380
		end -- 1380
	end -- 1380
	if applyRoomTransition(p) then -- 1390
		return -- 1391
	end -- 1391
	flushProfile() -- 1395
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1396
		clearSession() -- 1397
		refreshTitleSessionFlag() -- 1398
	elseif p.sessionDirty then -- 1399
		saveCurrentSession() -- 1400
	end -- 1400
	fe:renderPlay( -- 1402
		frameDt, -- 1402
		p, -- 1402
		input, -- 1402
		stageVp.stageW, -- 1402
		stageVp.stageH -- 1402
	) -- 1402
end -- 1402
function redrawGraybox() -- 1406
	if draw == nil then -- 1407
		return -- 1408
	end -- 1408
	local w = viewW -- 1410
	local h = viewH -- 1411
	local room = ROOMS[current + 1] -- 1412
	draw:clear() -- 1414
	draw:drawRect( -- 1415
		Rect(0, h - TOP_H, w, TOP_H), -- 1415
		C_BG -- 1415
	) -- 1415
	draw:drawRect( -- 1416
		Rect(0, 0, w, BOTTOM_H), -- 1416
		C_BG -- 1416
	) -- 1416
	draw:drawSegment( -- 1417
		Vec2(0, h - TOP_H), -- 1417
		Vec2(w, h - TOP_H), -- 1417
		1, -- 1417
		Color(52, 54, 54, 255) -- 1417
	) -- 1417
	draw:drawSegment( -- 1418
		Vec2(0, BOTTOM_H), -- 1418
		Vec2(w, BOTTOM_H), -- 1418
		1, -- 1418
		Color(52, 54, 54, 255) -- 1418
	) -- 1418
	local v = computeView(room, w, h) -- 1420
	renderWorld( -- 1421
		draw, -- 1421
		room, -- 1421
		v, -- 1421
		w, -- 1421
		h -- 1421
	) -- 1421
	local roomTop = v.groundPx + room.height * v.scale -- 1423
	drawScaleRuler(draw, w - 192, roomTop + 36, v.scale) -- 1424
	place( -- 1426
		titleLabel, -- 1426
		48, -- 1426
		h - 40, -- 1426
		0, -- 1426
		1 -- 1426
	) -- 1426
	place( -- 1427
		roomLabel, -- 1427
		48, -- 1427
		h - 96, -- 1427
		0, -- 1427
		1 -- 1427
	) -- 1427
	place( -- 1428
		captionLabel, -- 1428
		48, -- 1428
		h - 140, -- 1428
		0, -- 1428
		1 -- 1428
	) -- 1428
	place( -- 1430
		switchLabel, -- 1430
		48, -- 1430
		40, -- 1430
		0, -- 1430
		0 -- 1430
	) -- 1430
	place( -- 1431
		hintLabel, -- 1431
		48, -- 1431
		84, -- 1431
		0, -- 1431
		0 -- 1431
	) -- 1431
	place( -- 1432
		rulerLabel, -- 1432
		w - 216, -- 1432
		roomTop + 36 + v.scale * 0.5 - 14, -- 1432
		1, -- 1432
		0 -- 1432
	) -- 1432
	place( -- 1433
		standLabel, -- 1433
		48, -- 1433
		roomTop + 40, -- 1433
		0, -- 1433
		0 -- 1433
	) -- 1433
	place( -- 1434
		cartLabel, -- 1434
		48, -- 1434
		roomTop + 92, -- 1434
		0, -- 1434
		0 -- 1434
	) -- 1434
	if roomLabel ~= nil then -- 1436
		roomLabel.text = room.name -- 1437
	end -- 1437
	if captionLabel ~= nil then -- 1439
		captionLabel.text = room.caption -- 1440
	end -- 1440
	if hintLabel ~= nil then -- 1442
		local hintIdx = math.min(current, #HINTS - 1) -- 1443
		local lines = HINTS[hintIdx + 1] -- 1444
		local merged = lines[1] -- 1445
		do -- 1445
			local i = 1 -- 1446
			while i < #lines do -- 1446
				merged = (merged .. "    ") .. lines[i + 1] -- 1447
				i = i + 1 -- 1446
			end -- 1446
		end -- 1446
		hintLabel.text = merged -- 1449
	end -- 1449
	local specs = collectLabels(room, v, w) -- 1452
	local body = {} -- 1453
	local small = {} -- 1454
	do -- 1454
		local i = 0 -- 1455
		while i < #specs do -- 1455
			local s = specs[i + 1] -- 1456
			if s.size >= 24 then -- 1457
				body[#body + 1] = s -- 1458
			else -- 1458
				small[#small + 1] = s -- 1460
			end -- 1460
			i = i + 1 -- 1455
		end -- 1455
	end -- 1455
	applyPool(body, poolBody) -- 1463
	applyPool(small, poolSmall) -- 1464
	if LAYOUT_AUDIT then -- 1466
		print((("AUDIT|" .. room.key) .. "|") .. tostring(#specs)) -- 1467
	end -- 1467
end -- 1467
function applyPool(specs, pool) -- 1471
	do -- 1471
		local i = 0 -- 1472
		while i < #pool do -- 1472
			local lb = pool[i + 1] -- 1473
			if i < #specs then -- 1474
				local s = specs[i + 1] -- 1475
				lb.text = s.text -- 1476
				lb.position = Vec2(s.x, s.y) -- 1477
				lb.anchor = Vec2(s.ax, s.ay) -- 1478
				lb.color = s.color -- 1479
				lb.visible = true -- 1480
			else -- 1480
				lb.visible = false -- 1482
			end -- 1482
			i = i + 1 -- 1472
		end -- 1472
	end -- 1472
end -- 1472
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
	if mode == 0 then -- 143
		setMode(1) -- 144
		return -- 145
	end -- 145
	if fe == nil then -- 147
		return -- 148
	end -- 148
	if fe.screen == "splash" then -- 150
		fe.menus:resetSplash() -- 151
		fe.screen = "title" -- 152
		fe.menus:resetInput() -- 153
		return -- 154
	end -- 154
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "epilogue" or fe.screen == "history" then -- 156
		fe.menus:triggerBack() -- 157
		return -- 158
	end -- 158
	if fe.screen == "title" then -- 160
		if not canQuitApp() then -- 161
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 162
			return -- 163
		end -- 163
		if appClock - lastBackPressClock <= 2 then -- 165
			quitGame() -- 166
		else -- 166
			lastBackPressClock = appClock -- 168
			fe:showToast("再按一次返回退出游戏", 2) -- 169
		end -- 169
		return -- 171
	end -- 171
	if fe.screen == "play" and play ~= nil then -- 173
		if play.escortFailed then -- 174
			fe.audio:stopRoomTransient() -- 175
			fe.menus:resetInput() -- 176
			fe.screen = "title" -- 177
			if input ~= nil then -- 178
				input:clearTransient(true) -- 178
			end -- 178
			return -- 179
		end -- 179
		if play.paused then -- 181
			fe.menus:triggerBack() -- 182
			return -- 183
		end -- 183
		if play.craftBench.active then -- 185
			play:closeCraftBench() -- 186
			return -- 187
		end -- 187
		play.paused = true -- 189
		play.aimHold = 0 -- 190
		play.bottleAimX = -1 -- 191
		saveCurrentSession() -- 192
		fe.menus:openPause() -- 193
		if input ~= nil then -- 194
			input:clearTransient(true) -- 194
		end -- 194
	end -- 194
end -- 142
local function makeGrayboxLabel(text, size, color) -- 366
	if grayboxLayer == nil then -- 367
		return nil -- 368
	end -- 368
	local lb = Label(FONT, size) -- 370
	if lb == nil then -- 371
		return nil -- 372
	end -- 372
	lb.text = text -- 374
	lb.color = color -- 375
	lb:addTo(grayboxLayer) -- 376
	lb.visible = true -- 377
	return lb -- 378
end -- 366
function ____exports.start(parent, initialMode, startScreen) -- 390
	if initialMode == nil then -- 390
		initialMode = 1 -- 390
	end -- 390
	if startScreen == nil then -- 390
		startScreen = "title" -- 390
	end -- 390
	root = parent -- 391
	mode = initialMode -- 392
	grayboxLayer = Node() -- 395
	grayboxLayer.order = 2 -- 396
	grayboxLayer:addTo(parent) -- 397
	draw = DrawNode() -- 399
	draw:addTo(grayboxLayer) -- 400
	titleLabel = makeGrayboxLabel(TITLE, 40, C_TEXT) -- 402
	roomLabel = makeGrayboxLabel("", 26, C_ACCENT) -- 403
	captionLabel = makeGrayboxLabel("", 22, C_DIM) -- 404
	switchLabel = makeGrayboxLabel(SWITCH_HINT, 22, C_DIM) -- 405
	hintLabel = makeGrayboxLabel("", 22, C_TEXT) -- 406
	rulerLabel = makeGrayboxLabel(RULER_TEXT, 22, C_DIM) -- 407
	standLabel = makeGrayboxLabel(STAND_NOTE, 24, C_DIM) -- 408
	cartLabel = makeGrayboxLabel(CART_NOTE, 24, C_ACCENT) -- 409
	do -- 409
		local i = 0 -- 411
		while i < POOL_BODY do -- 411
			local lb = makeGrayboxLabel("", 24, C_TEXT) -- 412
			if lb ~= nil then -- 413
				poolBody[#poolBody + 1] = lb -- 414
			end -- 414
			i = i + 1 -- 411
		end -- 411
	end -- 411
	do -- 411
		local i = 0 -- 417
		while i < POOL_SMALL do -- 417
			local lb = makeGrayboxLabel("", 22, C_DIM) -- 418
			if lb ~= nil then -- 419
				poolSmall[#poolSmall + 1] = lb -- 420
			end -- 420
			i = i + 1 -- 417
		end -- 417
	end -- 417
	if mode == 1 then -- 426
		local loaded = loadSave() -- 427
		profile = loaded.state -- 428
		profileStatus = loaded.status -- 429
		profileDetail = loaded.detail -- 430
	end -- 430
	fe = __TS__New(WatchFrontend, parent) -- 432
	fe.screen = startScreen -- 433
	if startScreen == "splash" then -- 434
		fe.menus:resetSplash() -- 435
	end -- 435
	refreshTitleSessionFlag() -- 437
	grayboxLayer.visible = mode == 0 -- 438
	fe:setVisible(mode == 1) -- 439
	input = __TS__New(Input) -- 441
	fe.audio:applyUserVolumes(input.settings) -- 442
	touchRouter = __TS__New(TouchRouter, input.settings) -- 443
	touchRouter:attach(parent) -- 444
	input:bindTouch(touchRouter) -- 445
	gamepadRouter = __TS__New(GamepadRouter, input.settings) -- 447
	gamepadRouter:attach(parent) -- 448
	input:bindGamepad(gamepadRouter) -- 449
	touchControls = __TS__New(TouchControls, parent) -- 451
	parent:gslot( -- 454
		"AppEvent", -- 454
		function(eventType) -- 454
			if eventType == "BackButton" then -- 455
				handleBackButton() -- 456
				return -- 457
			end -- 457
			if eventType == "Quit" or eventType == "Shutdown" then -- 459
				flushProfile() -- 460
				saveCurrentSession() -- 461
				if input ~= nil then -- 462
					input:clearTransient(false) -- 462
				end -- 462
				return -- 463
			end -- 463
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 465
				flushProfile() -- 466
				saveCurrentSession() -- 467
				if input ~= nil then -- 468
					input:clearTransient(true) -- 468
				end -- 468
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.escortFailed then -- 469
					play.paused = true -- 470
					play.aimHold = 0 -- 471
					play.bottleAimX = -1 -- 472
					fe.menus:openPause() -- 473
				end -- 473
				if fe ~= nil then -- 475
					fe.audio:setPaused(true) -- 476
				end -- 476
				return -- 478
			end -- 478
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 480
				if fe ~= nil then -- 481
					local paused = play ~= nil and play.paused and mode == 1 and fe.screen == "play" -- 482
					fe.audio:setPaused(paused) -- 483
				end -- 483
			end -- 483
		end -- 454
	) -- 454
	parent:onKeyDown(function(key) -- 489
		onFirstUserGesture() -- 490
		if input ~= nil then -- 491
			input:markKeyboardActivity() -- 491
		end -- 491
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 492
			toggleFullscreen() -- 494
			return -- 495
		end -- 495
		if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 497
			if play.escortFailed then -- 498
				if key == "Left" or key == "A" then -- 499
					fe.talentDraft.deathSelected = 0 -- 500
					return -- 501
				end -- 501
				if key == "Right" or key == "D" then -- 503
					fe.talentDraft.deathSelected = 1 -- 504
					return -- 505
				end -- 505
				if key == "Escape" then -- 507
					fe.audio:stopRoomTransient() -- 508
					fe.menus:resetInput() -- 509
					fe.screen = "title" -- 510
					if input ~= nil then -- 511
						input:clearTransient(true) -- 511
					end -- 511
					return -- 512
				end -- 512
				if (key == "Return" or key == "Space") and play.escortFailedTicks >= 24 then -- 514
					if fe.talentDraft.deathSelected == 0 then -- 515
						play:confirmEscortRestart() -- 516
						applyRoomTransition(play) -- 517
					else -- 517
						fe.audio:stopRoomTransient() -- 519
						fe.menus:resetInput() -- 520
						fe.screen = "title" -- 521
						if input ~= nil then -- 522
							input:clearTransient(true) -- 522
						end -- 522
					end -- 522
					return -- 524
				end -- 524
				if key == "R" and play.escortFailedTicks >= 24 then -- 526
					play:confirmEscortRestart() -- 527
					applyRoomTransition(play) -- 528
					return -- 529
				end -- 529
				return -- 531
			end -- 531
			if not play.craftBench.active and not play.reloadOpen then -- 533
				local offers = play:getStoryTalentOffers() -- 534
				if #offers > 0 then -- 535
					if key == "1" then -- 536
						play:chooseTalent(0) -- 537
						if input ~= nil then -- 538
							input:consumePickRoom() -- 538
						end -- 538
						return -- 539
					end -- 539
					if key == "2" then -- 541
						play:chooseTalent(1) -- 542
						if input ~= nil then -- 543
							input:consumePickRoom() -- 543
						end -- 543
						return -- 544
					end -- 544
					if key == "3" then -- 546
						play:chooseTalent(2) -- 547
						if input ~= nil then -- 548
							input:consumePickRoom() -- 548
						end -- 548
						return -- 549
					end -- 549
					if play.talentModalActive then -- 551
						if key == "Left" or key == "A" then -- 552
							fe.talentDraft.selected = (fe.talentDraft.selected + #offers - 1) % #offers -- 553
							fe.hud.talentSelected = fe.talentDraft.selected -- 554
							return -- 555
						end -- 555
						if key == "Right" or key == "D" then -- 557
							fe.talentDraft.selected = (fe.talentDraft.selected + 1) % #offers -- 558
							fe.hud.talentSelected = fe.talentDraft.selected -- 559
							return -- 560
						end -- 560
						if key == "Return" or key == "Space" then -- 562
							play:chooseTalent(fe.talentDraft.selected) -- 563
							return -- 564
						end -- 564
					end -- 564
				end -- 564
			end -- 564
			if key == "T" and not (play.talentModalActive and #play:getStoryTalentOffers() > 0) then -- 569
				play:toggleArtifactWeapon() -- 570
				return -- 571
			end -- 571
		end -- 571
		local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 574
		if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 575
			fe.menus:onKeyEvent(key) -- 576
		end -- 576
		if input ~= nil and mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay then -- 578
			if key == "E" then -- 579
				input.interact.pressed = true -- 580
			elseif key == "Space" then -- 581
				input.jump.pressed = true -- 582
			elseif key == "Escape" then -- 583
				input.pause.pressed = true -- 584
			elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen and not play.talentModalActive) then -- 585
				input.retry.pressed = true -- 586
			end -- 586
		end -- 586
		if isReleaseBuild() then -- 589
			return -- 589
		end -- 589
		if key == "F1" then -- 590
			enterPlayRoom(current, storyRun == nil and "debug" or storyRun.source) -- 591
		elseif key == "F2" then -- 592
			setMode(0) -- 593
		elseif key == "1" then -- 594
			pickByIndex(0) -- 595
		elseif key == "2" then -- 596
			pickByIndex(1) -- 597
		elseif key == "3" then -- 598
			pickByIndex(2) -- 599
		elseif key == "4" then -- 600
			pickByIndex(3) -- 601
		elseif key == "5" then -- 602
			pickByIndex(4) -- 603
		elseif key == "6" then -- 604
			pickByIndex(5) -- 605
		elseif key == "7" then -- 606
			pickByIndex(6) -- 607
		elseif key == "8" then -- 608
			pickByIndex(7) -- 609
		end -- 609
	end) -- 489
	viewW = View.size.width -- 613
	viewH = View.size.height -- 614
	applySize() -- 615
	local reg = _G.package.loaded -- 618
	reg["watch.input"] = input -- 619
	reg["watch.touch"] = touchRouter -- 620
	reg["watch.gamepad"] = gamepadRouter -- 621
	reg["watch.fe"] = { -- 622
		setScreen = function(sc) -- 623
			if fe == nil then -- 624
				return -- 625
			end -- 625
			setMode(1) -- 627
			fe.screen = sc -- 628
			if sc == "splash" then -- 629
				fe.menus:resetSplash() -- 630
			elseif sc == "chapters" then -- 631
				fe.menus:openChapters() -- 632
			elseif sc == "epilogue" then -- 633
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 634
			elseif sc == "history" then -- 638
				fe.menus:openHistory(false) -- 639
			else -- 639
				fe.menus:resetInput() -- 641
			end -- 641
			if sc == "play" then -- 643
				ensurePlay() -- 644
			end -- 644
		end, -- 623
		jumpRoom = function(keyOrIdx) -- 647
			local idx = -1 -- 648
			if type(keyOrIdx) == "number" then -- 649
				idx = keyOrIdx -- 650
			else -- 650
				local k = 0 -- 652
				do -- 652
					k = 0 -- 653
					while k < #ROOMS do -- 653
						if ROOMS[k + 1].key == keyOrIdx then -- 654
							idx = k -- 655
						end -- 655
						k = k + 1 -- 653
					end -- 653
				end -- 653
			end -- 653
			if idx >= 0 and idx < #ROOMS then -- 659
				enterPlayRoom(idx, "debug") -- 660
			end -- 660
		end, -- 647
		getPlay = function() return play end, -- 663
		getFrontend = function() return fe end, -- 664
		startStory = function(seed) -- 666
			enterPlayRoom( -- 667
				officialStartIndex(), -- 667
				"official", -- 667
				true, -- 667
				seed -- 667
			) -- 667
			return play -- 668
		end, -- 666
		previewChapter = function(idx, seed) -- 671
			enterPlayRoom(idx, "chapter", false, seed) -- 672
			return play -- 673
		end, -- 671
		getStoryRun = function() return storyRun end, -- 675
		getProfilePending = function() return profilePending() end, -- 676
		flushProfileNow = function() return flushProfile() end, -- 677
		getProfile = function() return profile end, -- 679
		getProfileStatus = function() return profileStatus end, -- 680
		getProfileDetail = function() return profileDetail end, -- 681
		useTestSave = function(name) -- 682
			setSaveFile(name) -- 683
			setSessionFile(name == "" and "" or name .. ".session") -- 684
			clearProfilePending() -- 685
			local loaded = loadSave() -- 686
			profile = loaded.state -- 687
			profileStatus = loaded.status -- 688
			profileDetail = loaded.detail -- 689
			refreshTitleSessionFlag() -- 690
		end, -- 682
		useTestSession = function(name) -- 692
			setSessionFile(name) -- 693
			refreshTitleSessionFlag() -- 694
		end, -- 692
		getSessionFile = getSessionFile, -- 696
		hasSessionSave = hasSessionSave, -- 697
		saveSessionNow = function() return saveCurrentSession() end, -- 698
		clearSessionNow = function() -- 699
			local ok = clearSession() -- 700
			refreshTitleSessionFlag() -- 701
			return ok -- 702
		end, -- 699
		continueStory = function() return continueOfficialStory() end, -- 704
		saveNow = function() return saveSave(profile) end, -- 705
		getSaveFile = getSaveFile, -- 706
		isRelease = function() return isReleaseBuild() end, -- 707
		getReleaseVersion = function() -- 708
			local ____opt_29 = getReleaseConfig() -- 708
			return ____opt_29 and ____opt_29.version or "dev" -- 708
		end, -- 708
		toggleFullscreen = function() return toggleFullscreen() end, -- 709
		quitGame = function() return quitGame() end, -- 710
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
end -- 390
return ____exports -- 390
