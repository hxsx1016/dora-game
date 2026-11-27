-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local ____exports = {} -- 1
local randomRunSeed, onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, setMode, flushProfile, officialStartIndex, roomIndexByKey, applyChapterPreviewContext, enterPlayRoom, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, applyRoomTransition, tickFrontend, root, storyRun, profile, current, viewW, viewH, dirty, mode, input, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock -- 61
local ____Dora = require("Dora") -- 8
local App = ____Dora.App -- 8
local Color = ____Dora.Color -- 8
local Size = ____Dora.Size -- 8
local Vec2 = ____Dora.Vec2 -- 8
local View = ____Dora.View -- 8
local ____rooms = require("Script.watch.rooms") -- 9
local ROOMS = ____rooms.ROOMS -- 9
local ____input = require("Script.watch.input") -- 10
local Input = ____input.Input -- 10
local ____play = require("Script.watch.play") -- 11
local Play = ____play.Play -- 11
local ____clock = require("Script.watch.clock") -- 12
local STEP = ____clock.STEP -- 12
local StepClock = ____clock.StepClock -- 12
local ____platform = require("Script.watch.platform") -- 14
local canQuitApp = ____platform.canQuitApp -- 16
local canToggleFullscreen = ____platform.canToggleFullscreen -- 17
local computeStageViewport = ____platform.computeStageViewport -- 18
local getReleaseConfig = ____platform.getReleaseConfig -- 19
local isReleaseMode = ____platform.isReleaseMode -- 20
local ____target = require("Script.watch.target") -- 22
local getActiveTarget = ____target.getActiveTarget -- 22
local ____frontend = require("Script.watch.fe.frontend") -- 23
local WatchFrontend = ____frontend.WatchFrontend -- 23
local ____run = require("Script.watch.run") -- 24
local createRun = ____run.createRun -- 24
local createStoryTalents = ____run.createStoryTalents -- 24
local normalizeLegacyTalent = ____run.normalizeLegacyTalent -- 24
local ____save = require("Script.watch.save") -- 25
local emptySave = ____save.emptySave -- 25
local loadSave = ____save.loadSave -- 25
local saveSave = ____save.saveSave -- 25
local setSaveFile = ____save.setSaveFile -- 25
local getSaveFile = ____save.getSaveFile -- 25
local markProfilePending = ____save.markProfilePending -- 26
local flushSaveProfile = ____save.flushProfile -- 26
local clearProfilePending = ____save.clearProfilePending -- 26
local profilePending = ____save.profilePending -- 26
local loadSession = ____save.loadSession -- 27
local saveSession = ____save.saveSession -- 27
local clearSession = ____save.clearSession -- 27
local hasSessionSave = ____save.hasSessionSave -- 27
local setSessionFile = ____save.setSessionFile -- 27
local getSessionFile = ____save.getSessionFile -- 27
function randomRunSeed() -- 61
	return math.max( -- 62
		1, -- 62
		math.floor(math.abs(App.rand)) % 2147483646 -- 62
	) -- 62
end -- 62
function onFirstUserGesture() -- 69
	if audioUnlocked or fe == nil then -- 70
		return -- 71
	end -- 71
	audioUnlocked = true -- 73
	fe.audio:unlockAndResyncAfterGesture() -- 74
end -- 74
function toggleFullscreen() -- 77
	if not canToggleFullscreen() then -- 78
		return false -- 79
	end -- 79
	do -- 79
		local function ____catch() -- 79
			return true, false -- 86
		end -- 86
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 86
			local next = not App.fullScreen -- 82
			App.fullScreen = next -- 83
			return true, next -- 84
		end) -- 84
		if not ____try then -- 84
			____hasReturned, ____returnValue = ____catch() -- 84
		end -- 84
		if ____hasReturned then -- 84
			return ____returnValue -- 81
		end -- 81
	end -- 81
end -- 81
function quitGame() -- 90
	flushProfile() -- 91
	saveCurrentSession() -- 92
	if input ~= nil then -- 93
		input:clearTransient(false) -- 93
	end -- 93
	if fe ~= nil then -- 94
		fe.audio:stopRoomTransient() -- 95
	end -- 95
	if not canQuitApp() then -- 97
		current = 0 -- 99
		play = nil -- 100
		setMode(1) -- 101
		if fe ~= nil then -- 102
			fe.audio:stopRoomTransient() -- 103
			fe.screen = "title" -- 104
			fe.menus:resetInput() -- 105
		end -- 105
		return -- 107
	end -- 107
	App:shutdown() -- 109
end -- 109
function canSaveSession() -- 164
	if mode ~= 1 or play == nil or storyRun == nil then -- 165
		return false -- 166
	end -- 166
	if storyRun.source ~= "official" or play.run.finished then -- 168
		return false -- 169
	end -- 169
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 171
		return false -- 172
	end -- 172
	return true -- 174
end -- 174
function refreshTitleSessionFlag() -- 177
	if fe ~= nil then -- 178
		local has = hasSessionSave() -- 179
		fe.menus.hasSession = has -- 180
		if has then -- 181
			local loaded = loadSession() -- 182
			fe.menus:setSessionRoomKey(loaded.status == "ok" and loaded.state ~= nil and loaded.state.roomKey or "") -- 183
		else -- 183
			fe.menus:setSessionRoomKey("") -- 185
		end -- 185
	end -- 185
end -- 185
function saveCurrentSession() -- 190
	if not canSaveSession() or play == nil then -- 191
		return false -- 192
	end -- 192
	local ok = saveSession(play:exportSession()) -- 194
	play.sessionDirty = not ok -- 195
	refreshTitleSessionFlag() -- 196
	return ok -- 197
end -- 197
function continueOfficialStory() -- 200
	if play and play.escortFailed and play.run.source == "official" and play.sessionDirty then -- 201
		play:confirmEscortRestart() -- 203
		applyRoomTransition(play) -- 204
		if fe ~= nil then -- 205
			fe.screen = "play" -- 205
		end -- 205
		return play -- 206
	end -- 206
	local res = loadSession() -- 208
	if res.status ~= "ok" or res.state == nil then -- 209
		refreshTitleSessionFlag() -- 210
		return nil -- 211
	end -- 211
	local s = res.state -- 213
	local idx = roomIndexByKey(s.roomKey) -- 214
	if ROOMS[idx + 1].key ~= s.roomKey then -- 215
		return nil -- 216
	end -- 216
	storyRun = createRun(s.seed, "official", profile) -- 218
	storyRun.checkpoint = s.checkpoint -- 219
	storyRun.story.route = s.route -- 220
	storyRun.story.hp = s.hp -- 221
	storyRun.story.maxHp = s.maxHp -- 222
	storyRun.story.hpAtGate = s.hpAtGate -- 223
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 224
	storyRun.story.settled = s.settled -- 225
	storyRun.story.phase = s.phase -- 226
	storyRun.story.countTick = s.countTick -- 227
	storyRun.story.phaseTick = s.phaseTick -- 228
	storyRun.story.handTicks = s.handTicks -- 229
	storyRun.story.handDone = s.handDone -- 230
	storyRun.story.lineSaid = s.lineSaid -- 231
	storyRun.story.tied = s.tied -- 232
	storyRun.story.carry = s.carry -- 233
	storyRun.story.escortDone = s.escortDone -- 234
	storyRun.story.craftedWeapon = s.craftedWeapon -- 235
	storyRun.story.equippedWeapon = s.equippedWeapon -- 236
	storyRun.inventory.wood = s.wood -- 237
	storyRun.inventory.bell = s.bell -- 238
	storyRun.inventory.scrap = s.scrap -- 239
	storyRun.inventory.wedge = s.wedge -- 240
	storyRun.inventory.ammo = s.ammo -- 241
	storyRun.inventory.shield = s.shield -- 242
	storyRun.inventory.pass = s.pass -- 243
	storyRun.inventory.quickbelt = s.quickbelt -- 244
	local k = 0 -- 245
	do -- 245
		k = 0 -- 246
		while k < #s.taken do -- 246
			storyRun.taken[s.taken[k + 1]] = true -- 247
			k = k + 1 -- 246
		end -- 246
	end -- 246
	do -- 246
		k = 0 -- 249
		while k < #s.segments do -- 249
			storyRun.story.segments[s.segments[k + 1]] = true -- 250
			k = k + 1 -- 249
		end -- 249
	end -- 249
	if s.campaignRoute ~= nil then -- 252
		storyRun.route = s.campaignRoute -- 253
	end -- 253
	if s.joined ~= nil then -- 255
		storyRun.joined = s.joined -- 256
	end -- 256
	if s.c1Latch ~= nil then -- 258
		storyRun.c1Latch = s.c1Latch -- 259
	end -- 259
	if s.c2Latch ~= nil then -- 261
		storyRun.c2Latch = s.c2Latch -- 262
	end -- 262
	if s.props ~= nil then -- 264
		do -- 264
			k = 0 -- 265
			while k < #s.props do -- 265
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 266
				local pid = parts[1] -- 267
				if pid ~= nil and pid ~= "" then -- 268
					local ____storyRun_props_12 = storyRun.props -- 269
					local ____temp_8 -- 270
					if parts[2] == nil then -- 270
						____temp_8 = true -- 270
					else -- 270
						____temp_8 = parts[2] == "1" -- 270
					end -- 270
					local ____temp_10 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 271
					local ____temp_11 = parts[4] == "1" -- 272
					local ____temp_9 -- 273
					if parts[5] == "1" then -- 273
						____temp_9 = true -- 273
					else -- 273
						____temp_9 = nil -- 273
					end -- 273
					____storyRun_props_12[pid] = {broken = ____temp_8, hp = ____temp_10, wedge = ____temp_11, revealed = ____temp_9} -- 269
				end -- 269
				k = k + 1 -- 265
			end -- 265
		end -- 265
	end -- 265
	local stTalents = createStoryTalents(s.seed) -- 278
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 279
		stTalents.randomState = s.talentSeed -- 280
	end -- 280
	if s.escortAttempt ~= nil and s.escortAttempt >= 1 then -- 282
		stTalents.attempt = s.escortAttempt -- 283
	end -- 283
	if s.escortVariant ~= nil and s.escortVariant >= 0 then -- 285
		stTalents.variant = s.escortVariant -- 286
	end -- 286
	stTalents.deferred = s.talentDeferred == true -- 288
	stTalents.room = s.talentRoom or "" -- 289
	if s.talentRanks ~= nil and #s.talentRanks > 0 then -- 290
		do -- 290
			k = 0 -- 291
			while k < #s.talentRanks do -- 291
				local parts = __TS__StringSplit(s.talentRanks[k + 1], ":") -- 292
				local ____temp_13 -- 293
				if parts[1] ~= nil then -- 293
					____temp_13 = normalizeLegacyTalent(parts[1]) -- 293
				else -- 293
					____temp_13 = nil -- 293
				end -- 293
				local norm = ____temp_13 -- 293
				local rk = parts[2] ~= nil and (tonumber(parts[2]) or 0) or 0 -- 294
				if norm ~= nil and rk > 0 then -- 295
					stTalents.ranks[norm] = (stTalents.ranks[norm] or 0) + math.floor(rk) -- 296
				end -- 296
				k = k + 1 -- 291
			end -- 291
		end -- 291
	else -- 291
		stTalents.ranks.vitality = s.talentVitality or 0 -- 301
		stTalents.ranks.focus = s.talentReload or 0 -- 302
		stTalents.ranks.guard = s.talentGuard or 0 -- 303
		stTalents.ranks.salvage = s.talentCraft or 0 -- 304
	end -- 304
	if s.talentOffers ~= nil then -- 306
		do -- 306
			k = 0 -- 307
			while k < #s.talentOffers do -- 307
				local norm = normalizeLegacyTalent(s.talentOffers[k + 1]) -- 308
				if norm ~= nil then -- 309
					local ____stTalents_offers_14 = stTalents.offers -- 310
					____stTalents_offers_14[#____stTalents_offers_14 + 1] = norm -- 310
				end -- 310
				k = k + 1 -- 307
			end -- 307
		end -- 307
	end -- 307
	storyRun.story.talents = stTalents -- 314
	current = idx -- 315
	setMode(1) -- 316
	if fe ~= nil then -- 317
		fe.screen = "play" -- 318
	end -- 318
	play = nil -- 320
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 321
	local cur = play -- 322
	if cur ~= nil then -- 323
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 324
			cur.cartAxle = s.cartAxle -- 325
			cur.cartDocked = s.cartDocked -- 326
		end -- 326
		if s.playerX ~= nil and s.playerX >= 0 then -- 328
			cur.player.x = math.max( -- 329
				cur.room.minX + 16, -- 329
				math.min(cur.room.maxX - 16, s.playerX) -- 329
			) -- 329
			cur.player.y = math.max(0, s.playerY or 0) -- 330
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 331
				cur.player.depth = math.max( -- 332
					cur.room.depth.min, -- 332
					math.min(cur.room.depth.max, s.playerDepth) -- 332
				) -- 332
			end -- 332
		end -- 332
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 335
			cur.gateTick = s.gateTick -- 336
		end -- 336
		if cur.room.key == "village" then -- 338
			if s.hasBottle == true then -- 339
				cur.hasBottle = true -- 339
			end -- 339
			if s.villagePassed == true then -- 340
				cur.passed = true -- 340
			end -- 340
		end -- 340
		if cur.room.key == "prologue" and (s.phase == "" or s.phase == "prologue-wake" or s.phase == "prologue-shadow" or s.phase == "prologue-escape" or s.phase == "prologue-hide") then -- 343
			cur.phase = "prologue-wake" -- 349
		end -- 349
		if (string.find(cur.room.key, "escort", nil, true) or 0) - 1 == 0 and s.route == "soldier" and not cur.craftBench.active and not cur.carryOn then -- 352
			cur.carryOn = true -- 353
			storyRun.story.carry = true -- 354
		end -- 354
	end -- 354
	return play -- 357
end -- 357
function setMode(_nextMode) -- 677
	mode = 1 -- 678
	if fe ~= nil then -- 679
		fe:setVisible(true) -- 680
	end -- 680
	dirty = true -- 682
	clock:reset() -- 683
end -- 683
function flushProfile() -- 690
	local cur = play -- 691
	if cur ~= nil and cur.archiveDirty then -- 692
		cur.archiveDirty = false -- 693
		markProfilePending(profile) -- 694
	end -- 694
	local ok = flushSaveProfile() -- 696
	if not ok and cur ~= nil then -- 697
		cur.archiveDirty = true -- 698
	end -- 698
	return ok -- 700
end -- 700
function officialStartIndex() -- 704
	local mp = profile.museumPhase -- 705
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 706
	return inMuseum and roomIndexByKey("museum") or 0 -- 707
end -- 707
function roomIndexByKey(key) -- 710
	local i = 0 -- 711
	do -- 711
		i = 0 -- 712
		while i < #ROOMS do -- 712
			if ROOMS[i + 1].key == key then -- 713
				return i -- 714
			end -- 714
			i = i + 1 -- 712
		end -- 712
	end -- 712
	return 0 -- 717
end -- 717
function applyChapterPreviewContext(targetRun, roomKey, routeOverride) -- 720
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" and routeOverride ~= "soldier" then -- 723
		targetRun.story.route = "child" -- 725
		targetRun.story.settled = true -- 726
		targetRun.story.countTick = 1440 -- 727
	elseif roomKey == "gatepath" or (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 or roomKey == "tower" and routeOverride == "soldier" then -- 728
		targetRun.story.route = "soldier" -- 730
		targetRun.story.settled = true -- 731
		targetRun.story.hp = 3 -- 732
		targetRun.story.maxHp = 3 -- 733
		targetRun.story.hpAtGate = 3 -- 734
		targetRun.story.maxHpAtGate = 3 -- 735
		targetRun.story.handDone = true -- 736
		targetRun.story.tied = true -- 737
		targetRun.joined = true -- 738
		if (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 then -- 739
			targetRun.story.carry = true -- 740
		end -- 740
		if roomKey == "escort3" or roomKey == "escort4" or roomKey == "escort5" then -- 742
			targetRun.inventory.wood = math.max(targetRun.inventory.wood, 2) -- 743
			targetRun.inventory.bell = math.max(targetRun.inventory.bell, 1) -- 744
		end -- 744
		if roomKey == "escort3" then -- 746
			targetRun.inventory.scrap = math.max(targetRun.inventory.scrap, 2) -- 747
			targetRun.inventory.wedge = math.max(targetRun.inventory.wedge, 1) -- 748
		end -- 748
	end -- 748
end -- 748
function enterPlayRoom(idx, source, fresh, seedOverride, chapterRoute) -- 753
	if source == nil then -- 753
		source = "debug" -- 753
	end -- 753
	if fresh == nil then -- 753
		fresh = false -- 753
	end -- 753
	current = idx -- 754
	setMode(1) -- 755
	if fe ~= nil then -- 756
		fe.screen = "play" -- 757
	end -- 757
	play = nil -- 759
	if fresh or source == "chapter" or storyRun == nil then -- 761
		local seed = seedOverride ~= nil and seedOverride or ((source == "official" or source == "chapter") and randomRunSeed() or 20261124) -- 762
		storyRun = createRun(seed, source, profile) -- 765
		if source == "chapter" then -- 766
			local targetKey = ROOMS[current + 1] ~= nil and ROOMS[current + 1].key or "" -- 767
			applyChapterPreviewContext(storyRun, targetKey, chapterRoute) -- 768
		end -- 768
	else -- 768
		storyRun.source = source -- 771
	end -- 771
	ensurePlay() -- 773
	local firstPlay = play -- 775
	if firstPlay ~= nil and ROOMS[current + 1].key == "prologue" and (fresh and source == "official" or source == "chapter") then -- 776
		firstPlay.phase = "prologue-wake" -- 778
	end -- 778
	flushProfile() -- 780
end -- 780
function applySize() -- 803
	if root == nil then -- 804
		return -- 805
	end -- 805
	root.size = Size(viewW, viewH) -- 807
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 808
	stageVp = computeStageViewport(viewW, viewH) -- 809
	if input ~= nil then -- 810
		input:setStageViewport(stageVp) -- 811
	end -- 811
	if fe ~= nil then -- 813
		fe:setStagePlacement(stageVp) -- 814
	end -- 814
end -- 814
function syncFrameAdapters(frameDt) -- 818
	if input == nil then -- 819
		return -- 820
	end -- 820
	local target = input.target -- 822
	if not target.supportsTouch and not target.supportsGamepad then -- 823
		return -- 824
	end -- 824
	local p = play -- 826
	local isPlayMode = mode == 1 and fe ~= nil and fe.screen == "play" and p ~= nil -- 827
	local storyTalentBoxes = target.supportsTouch and isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and fe:getStoryTalentBoxes( -- 828
		p, -- 830
		stageVp.stageW, -- 830
		stageVp.stageH, -- 830
		input:isTouchMode() -- 830
	) or ({}) -- 831
	local ____temp_51 -- 832
	if target.supportsTouch and isPlayMode and fe ~= nil and p ~= nil and not p.paused and p.escortFailed then -- 832
		____temp_51 = fe:getEscortDeathBoxes(p, stageVp.stageW, stageVp.stageH) -- 834
	else -- 834
		____temp_51 = nil -- 835
	end -- 835
	local escortDeathBoxes = ____temp_51 -- 832
	local ____temp_52 -- 836
	if target.supportsTouch and isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.escortFailed and not p.craftBench.active and not p.reloadOpen then -- 836
		____temp_52 = fe:getLedgerButtonBox() -- 838
	else -- 838
		____temp_52 = nil -- 839
	end -- 839
	local ledgerButtonBox = ____temp_52 -- 836
	local isFs = false -- 841
	if target:canToggleFullscreen() then -- 842
		do -- 842
			local function ____catch() -- 842
				isFs = false -- 846
			end -- 846
			local ____try = pcall(function() -- 846
				isFs = App.fullScreen -- 844
			end) -- 844
			if not ____try then -- 844
				____catch() -- 844
			end -- 844
		end -- 844
	end -- 844
	local ____input_63 = input -- 849
	local ____input_syncFrame_64 = input.syncFrame -- 849
	local ____stageVp_57 = stageVp -- 850
	local ____mode_58 = mode -- 851
	local ____temp_59 = fe ~= nil and fe.screen or "title" -- 852
	local ____storyRun_60 = storyRun -- 854
	local ____temp_61 = fe and fe.cam -- 855
	local ____input_62 = input -- 856
	local ____temp_55 -- 857
	if fe ~= nil then -- 857
		____temp_55 = fe.contract:isAssistHintsEnabled() -- 857
	else -- 857
		____temp_55 = false -- 857
	end -- 857
	local ____temp_56 -- 858
	if fe ~= nil then -- 858
		____temp_56 = fe.audio:isAllMuted() -- 858
	else -- 858
		____temp_56 = false -- 858
	end -- 858
	____input_syncFrame_64(____input_63, { -- 849
		viewport = ____stageVp_57, -- 850
		mode = ____mode_58, -- 851
		screen = ____temp_59, -- 852
		play = p, -- 853
		run = ____storyRun_60, -- 854
		cam = ____temp_61, -- 855
		input = ____input_62, -- 856
		assistHintsEnabled = ____temp_55, -- 857
		isMuted = ____temp_56, -- 858
		isFullscreen = isFs, -- 859
		storyTalentBoxes = storyTalentBoxes, -- 860
		escortDeathBoxes = escortDeathBoxes, -- 861
		ledgerButtonBox = ledgerButtonBox, -- 862
		dt = frameDt -- 863
	}) -- 863
end -- 863
function renderTouchOverlay() -- 867
	if input ~= nil then -- 868
		input:renderOverlay() -- 868
	end -- 868
end -- 868
function tick(frameDt) -- 871
	appClock = appClock + math.min( -- 872
		0.05, -- 872
		math.max(0, frameDt) -- 872
	) -- 872
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 873
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 874
	if w ~= viewW or h ~= viewH then -- 875
		viewW = w -- 876
		viewH = h -- 877
		applySize() -- 878
		dirty = true -- 879
	end -- 879
	if input == nil then -- 881
		return -- 882
	end -- 882
	syncFrameAdapters(frameDt) -- 884
	input:update() -- 885
	if input.userInteracted then -- 887
		onFirstUserGesture() -- 888
	end -- 888
	if input.muteTogglePressed and fe ~= nil then -- 890
		input.muteTogglePressed = false -- 891
		fe.audio:toggleAllMuted() -- 892
	end -- 892
	if input.fullscreenTogglePressed then -- 894
		input.fullscreenTogglePressed = false -- 895
		toggleFullscreen() -- 896
	end -- 896
	if input.artifactTogglePressed and mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.escortFailed then -- 898
		input.artifactTogglePressed = false -- 899
		play:toggleArtifactWeapon() -- 900
	end -- 900
	if input.bottleCanceled and play ~= nil then -- 902
		input.bottleCanceled = false -- 903
		play.aimHold = 0 -- 904
		play.bottleAimX = -1 -- 905
	end -- 905
	if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and not play.escortFailed and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 908
		if fe:canPickStoryTalent(play) then -- 911
			play:chooseTalent(input.pickRoom - 1) -- 912
		end -- 912
		input.pickRoom = 0 -- 914
	end -- 914
	input.toggleView.pressed = false -- 918
	input.pickRoom = 0 -- 919
	input.tab.pressed = false -- 920
	if mode == 1 then -- 922
		tickFrontend(frameDt) -- 923
	end -- 923
	renderTouchOverlay() -- 925
end -- 925
function registerPlay() -- 929
	local reg = _G.package.loaded -- 930
	reg["watch.play"] = play -- 931
	reg["watch.room"] = ROOMS[current + 1].key -- 932
end -- 932
function ensurePlay(resume) -- 936
	if storyRun == nil then -- 939
		storyRun = createRun(20261124, "debug", profile) -- 940
	end -- 940
	play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 942
	registerPlay() -- 943
	clock:reset() -- 944
	if fe ~= nil then -- 945
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 946
	end -- 946
end -- 946
function applyRoomTransition(p) -- 951
	if p.wantRoom == "" then -- 952
		return false -- 953
	end -- 953
	local key = p.wantRoom -- 955
	p.wantRoom = "" -- 956
	local idx = -1 -- 957
	local j = 0 -- 958
	do -- 958
		j = 0 -- 959
		while j < #ROOMS do -- 959
			if ROOMS[j + 1].key == key then -- 960
				idx = j -- 961
			end -- 961
			j = j + 1 -- 959
		end -- 959
	end -- 959
	if idx < 0 then -- 964
		return false -- 965
	end -- 965
	flushProfile() -- 970
	local leaving = p:drainEvents() -- 971
	if p.restartStory then -- 973
		if storyRun ~= nil and storyRun.source == "official" then -- 974
			clearSession() -- 975
			refreshTitleSessionFlag() -- 976
		end -- 976
		local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 978
		local nextSeed = nextSource == "official" and randomRunSeed() or 20261124 -- 979
		storyRun = createRun(nextSeed, nextSource, profile) -- 980
	end -- 980
	current = idx -- 982
	ensurePlay() -- 983
	local fresh = play -- 984
	if fresh ~= nil then -- 985
		if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 986
			fresh.phase = "prologue-wake" -- 987
		end -- 987
		fresh:adoptEvents(leaving) -- 989
	end -- 989
	if not p.restartStory then -- 991
		saveCurrentSession() -- 992
	end -- 992
	clock:reset() -- 994
	dirty = true -- 995
	return true -- 996
end -- 996
function tickFrontend(frameDt) -- 999
	if fe == nil or input == nil then -- 1000
		return -- 1001
	end -- 1001
	if fe.screen ~= "play" then -- 1005
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1006
		input:consumeEdges() -- 1007
		if act.type == "splashDone" then -- 1008
			fe.menus:resetInput() -- 1009
			fe.screen = "title" -- 1010
		elseif act.type == "continue" then -- 1011
			if continueOfficialStory() == nil then -- 1012
				enterPlayRoom( -- 1013
					officialStartIndex(), -- 1013
					"official", -- 1013
					true -- 1013
				) -- 1013
			end -- 1013
		elseif act.type == "start" then -- 1015
			clearSession() -- 1017
			refreshTitleSessionFlag() -- 1018
			enterPlayRoom( -- 1019
				officialStartIndex(), -- 1019
				"official", -- 1019
				true -- 1019
			) -- 1019
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1020
			enterPlayRoom( -- 1021
				act.roomIndex, -- 1021
				"chapter", -- 1021
				false, -- 1021
				nil, -- 1021
				act.route -- 1021
			) -- 1021
		elseif act.type == "openChapters" then -- 1022
			fe.menus:openChapters() -- 1023
			fe.screen = "chapters" -- 1024
		elseif act.type == "openControls" then -- 1025
			fe.menus:resetInput() -- 1026
			fe.screen = "controls" -- 1027
		elseif act.type == "openHistory" then -- 1028
			fe.menus:openHistory(true) -- 1029
			fe.screen = "history" -- 1030
		elseif act.type == "backEpilogue" then -- 1031
			fe.menus:resetInput() -- 1032
			fe.screen = "epilogue" -- 1033
		elseif act.type == "replayStory" then -- 1034
			clearSession() -- 1035
			refreshTitleSessionFlag() -- 1036
			enterPlayRoom( -- 1037
				officialStartIndex(), -- 1037
				"official", -- 1037
				true -- 1037
			) -- 1037
		elseif act.type == "backTitle" then -- 1038
			fe.menus:resetInput() -- 1039
			fe.screen = "title" -- 1040
		elseif act.type == "backPause" then -- 1041
			fe.menus:resetInput() -- 1042
			fe.screen = "play" -- 1043
		elseif act.type == "quit" then -- 1044
			quitGame() -- 1045
		end -- 1045
		return -- 1047
	end -- 1047
	if play == nil then -- 1051
		ensurePlay() -- 1052
	end -- 1052
	if play == nil then -- 1054
		return -- 1055
	end -- 1055
	local p = play -- 1057
	p.aimX = input.mx -- 1059
	p.aimY = input.my -- 1060
	local zoneTap = input.touchZoneTap -- 1062
	if zoneTap ~= "ledger:toggle" then -- 1063
		input.touchZoneTap = "" -- 1064
	end -- 1064
	if not p.paused and p.escortFailed then -- 1068
		local deathAction = "" -- 1069
		if zoneTap == "escort:retry" and p.escortFailedTicks >= 12 then -- 1070
			deathAction = "retry" -- 1071
		elseif zoneTap == "escort:title" then -- 1072
			deathAction = "title" -- 1073
		else -- 1073
			if input.navLeft or input.navPrevTab then -- 1075
				fe.talentDraft.deathSelected = 0 -- 1076
			elseif input.navRight or input.navNextTab then -- 1077
				fe.talentDraft.deathSelected = 1 -- 1078
			end -- 1078
			if input.pause.pressed or input.navBack then -- 1080
				deathAction = "title" -- 1081
			elseif p.escortFailedTicks >= 24 and input.retry.pressed then -- 1082
				deathAction = "retry" -- 1083
			elseif p.escortFailedTicks >= 24 and input.navConfirm then -- 1084
				deathAction = fe.talentDraft.deathSelected == 0 and "retry" or "title" -- 1085
			elseif p.escortFailedTicks >= 12 and (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) then -- 1086
				deathAction = fe:tryPickEscortDeathAtPointer(p, input, stageVp.stageW, stageVp.stageH) -- 1088
			end -- 1088
		end -- 1088
		if deathAction == "retry" then -- 1091
			input:consumeEdges() -- 1092
			p:confirmEscortRestart() -- 1093
			applyRoomTransition(p) -- 1094
			return -- 1095
		end -- 1095
		if deathAction == "title" then -- 1097
			input:consumeEdges() -- 1098
			fe.audio:stopRoomTransient() -- 1099
			fe.menus:resetInput() -- 1100
			fe.screen = "title" -- 1101
			input:clearTransient(true) -- 1102
			return -- 1103
		end -- 1103
		input.pause.pressed = false -- 1105
		input.retry.pressed = false -- 1106
		input.fire.pressed = false -- 1107
	end -- 1107
	local offers = p:getStoryTalentOffers() -- 1110
	if fe:canPickStoryTalent(p) and #offers > 0 then -- 1111
		if fe.talentDraft.selected >= #offers then -- 1112
			fe.talentDraft.selected = 0 -- 1113
		end -- 1113
		fe.hud.talentSelected = fe.talentDraft.selected -- 1115
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1116
			local idx = __TS__ParseInt( -- 1117
				string.sub(zoneTap, 8), -- 1117
				10 -- 1117
			) -- 1117
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1118
				fe.talentDraft.selected = idx -- 1119
				fe.hud.talentSelected = idx -- 1120
				input.fire.pressed = false -- 1121
			end -- 1121
		else -- 1121
			local navDelta = p.talentModalActive and ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) or 0 -- 1124
			local totalDelta = input.talentDelta + navDelta -- 1127
			if totalDelta ~= 0 then -- 1128
				fe.talentDraft.selected = (fe.talentDraft.selected + totalDelta + #offers) % #offers -- 1129
				fe.hud.talentSelected = fe.talentDraft.selected -- 1130
				input.talentDelta = 0 -- 1131
			end -- 1131
			if input.talentConfirm or p.talentModalActive and input.navConfirm then -- 1133
				p:chooseTalent(fe.talentDraft.selected) -- 1134
				input.talentConfirm = false -- 1135
				input.fire.pressed = false -- 1136
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1137
				input.fire.pressed = false -- 1139
			end -- 1139
		end -- 1139
	end -- 1139
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1145
		if input.navConfirm then -- 1146
			input.interact.pressed = true -- 1147
		end -- 1147
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1149
			flushProfile() -- 1150
			if p.run.source == "official" and hasSessionSave() then -- 1151
				clearSession() -- 1152
				refreshTitleSessionFlag() -- 1153
			end -- 1153
			fe.audio:stopRoomTransient() -- 1155
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1156
			fe.screen = "epilogue" -- 1160
			input:clearTransient(true) -- 1161
			input:consumeEdges() -- 1162
			return -- 1163
		end -- 1163
	end -- 1163
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1167
		p:closeCraftBench() -- 1168
		input:consumeEdges() -- 1169
		return -- 1170
	end -- 1170
	if not p.paused and not p.escortFailed and input.pause.pressed then -- 1172
		p.paused = true -- 1173
		p.aimHold = 0 -- 1174
		p.bottleAimX = -1 -- 1175
		saveCurrentSession() -- 1176
		fe.menus:openPause() -- 1177
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1178
		input:clearTransient(true) -- 1179
		input:consumeEdges() -- 1180
	end -- 1180
	if p.paused then -- 1183
		clock:reset() -- 1185
		local pauseAct = fe:renderPlay( -- 1186
			frameDt, -- 1186
			p, -- 1186
			input, -- 1186
			stageVp.stageW, -- 1186
			stageVp.stageH -- 1186
		) -- 1186
		input:consumeEdges() -- 1187
		if pauseAct.type == "resume" then -- 1188
			p.paused = false -- 1189
		elseif pauseAct.type == "retry" then -- 1190
			if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1191
				p:restartEscortRun() -- 1192
				applyRoomTransition(p) -- 1193
			else -- 1193
				ensurePlay({checkpoint = p.checkpoint}) -- 1195
			end -- 1195
		elseif pauseAct.type == "openChapters" then -- 1197
			fe.audio:stopRoomTransient() -- 1198
			fe.audio:setPaused(false) -- 1199
			fe.menus:openChapters(current) -- 1200
			fe.screen = "chapters" -- 1201
		elseif pauseAct.type == "toggleFullscreen" then -- 1202
			toggleFullscreen() -- 1203
		elseif pauseAct.type == "quit" then -- 1204
			quitGame() -- 1205
		elseif pauseAct.type == "toTitle" then -- 1206
			saveCurrentSession() -- 1207
			refreshTitleSessionFlag() -- 1208
			fe.menus:resetInput() -- 1209
			fe.screen = "title" -- 1210
		end -- 1210
		return -- 1212
	end -- 1212
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1215
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1216
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and not p.talentModalActive then -- 1218
		input:consumeEdges() -- 1219
		if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1220
			p:restartEscortRun() -- 1222
			applyRoomTransition(p) -- 1223
		else -- 1223
			ensurePlay({checkpoint = p.checkpoint}) -- 1226
		end -- 1226
		return -- 1228
	end -- 1228
	local steps = clock:advance(frameDt) -- 1231
	local i = 0 -- 1232
	do -- 1232
		i = 0 -- 1233
		while i < steps do -- 1233
			input:beginStep(i == 0) -- 1234
			p:update(STEP, input) -- 1235
			input:endStep() -- 1236
			if p.wantRoom ~= "" then -- 1237
				break -- 1238
			end -- 1238
			i = i + 1 -- 1233
		end -- 1233
	end -- 1233
	if applyRoomTransition(p) then -- 1243
		return -- 1244
	end -- 1244
	flushProfile() -- 1248
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1249
		clearSession() -- 1250
		refreshTitleSessionFlag() -- 1251
	elseif p.sessionDirty then -- 1252
		saveCurrentSession() -- 1253
	end -- 1253
	fe:renderPlay( -- 1255
		frameDt, -- 1255
		p, -- 1255
		input, -- 1255
		stageVp.stageW, -- 1255
		stageVp.stageH -- 1255
	) -- 1255
end -- 1255
local FONT = "sarasa-mono-sc-regular" -- 32
local C_TEXT = Color(236, 236, 232, 255) -- 34
local C_ACCENT = Color(226, 186, 84, 255) -- 35
profile = emptySave() -- 41
local profileStatus = "missing" -- 42
local profileDetail = "" -- 43
current = 0 -- 45
viewW = 0 -- 46
viewH = 0 -- 47
dirty = true -- 48
mode = 1 -- 50
clock = __TS__New(StepClock) -- 54
stageVp = computeStageViewport(1280, 720) -- 55
audioUnlocked = false -- 57
appClock = 0 -- 58
local lastBackPressClock = -10 -- 59
local function isReleaseBuild() -- 65
	return isReleaseMode() -- 66
end -- 65
local function handleBackButton() -- 112
	if fe == nil then -- 113
		return -- 114
	end -- 114
	if fe.screen == "splash" then -- 116
		fe.menus:resetSplash() -- 117
		fe.screen = "title" -- 118
		fe.menus:resetInput() -- 119
		return -- 120
	end -- 120
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "epilogue" or fe.screen == "history" then -- 122
		fe.menus:triggerBack() -- 123
		return -- 124
	end -- 124
	if fe.screen == "title" then -- 126
		if not canQuitApp() then -- 127
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 128
			return -- 129
		end -- 129
		if appClock - lastBackPressClock <= 2 then -- 131
			quitGame() -- 132
		else -- 132
			lastBackPressClock = appClock -- 134
			fe:showToast("再按一次返回退出游戏", 2) -- 135
		end -- 135
		return -- 137
	end -- 137
	if fe.screen == "play" and play ~= nil then -- 139
		if play.escortFailed then -- 140
			fe.audio:stopRoomTransient() -- 141
			fe.menus:resetInput() -- 142
			fe.screen = "title" -- 143
			if input ~= nil then -- 144
				input:clearTransient(true) -- 144
			end -- 144
			return -- 145
		end -- 145
		if play.paused then -- 147
			fe.menus:triggerBack() -- 148
			return -- 149
		end -- 149
		if play.craftBench.active then -- 151
			play:closeCraftBench() -- 152
			return -- 153
		end -- 153
		play.paused = true -- 155
		play.aimHold = 0 -- 156
		play.bottleAimX = -1 -- 157
		saveCurrentSession() -- 158
		fe.menus:openPause() -- 159
		if input ~= nil then -- 160
			input:clearTransient(true) -- 160
		end -- 160
	end -- 160
end -- 112
function ____exports.start(parent, initialMode, startScreen) -- 360
	if initialMode == nil then -- 360
		initialMode = 1 -- 360
	end -- 360
	if startScreen == nil then -- 360
		startScreen = "title" -- 360
	end -- 360
	root = parent -- 361
	mode = initialMode -- 362
	if mode == 1 then -- 366
		local loaded = loadSave() -- 367
		profile = loaded.state -- 368
		profileStatus = loaded.status -- 369
		profileDetail = loaded.detail -- 370
	end -- 370
	fe = __TS__New(WatchFrontend, parent) -- 372
	fe.screen = startScreen -- 373
	if startScreen == "splash" then -- 374
		fe.menus:resetSplash() -- 375
	end -- 375
	refreshTitleSessionFlag() -- 377
	fe:setVisible(mode == 1) -- 378
	input = __TS__New(Input) -- 380
	fe.audio:applyUserVolumes(input.settings) -- 381
	input:attach( -- 382
		parent, -- 382
		{ -- 382
			onFirstUserGesture = function() -- 383
				onFirstUserGesture() -- 384
				if input ~= nil then -- 385
					input:markKeyboardActivity() -- 385
				end -- 385
			end, -- 383
			onToggleFullscreen = function() -- 387
				toggleFullscreen() -- 388
			end, -- 387
			onKeyDownEvent = function(____, key) -- 390
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused then -- 391
					if play.escortFailed then -- 392
						if key == "Left" or key == "A" then -- 393
							fe.talentDraft.deathSelected = 0 -- 394
							return -- 395
						end -- 395
						if key == "Right" or key == "D" then -- 397
							fe.talentDraft.deathSelected = 1 -- 398
							return -- 399
						end -- 399
						if key == "Escape" then -- 401
							fe.audio:stopRoomTransient() -- 402
							fe.menus:resetInput() -- 403
							fe.screen = "title" -- 404
							if input ~= nil then -- 405
								input:clearTransient(true) -- 405
							end -- 405
							return -- 406
						end -- 406
						if (key == "Return" or key == "Space") and play.escortFailedTicks >= 24 then -- 408
							if fe.talentDraft.deathSelected == 0 then -- 409
								play:confirmEscortRestart() -- 410
								applyRoomTransition(play) -- 411
							else -- 411
								fe.audio:stopRoomTransient() -- 413
								fe.menus:resetInput() -- 414
								fe.screen = "title" -- 415
								if input ~= nil then -- 416
									input:clearTransient(true) -- 416
								end -- 416
							end -- 416
							return -- 418
						end -- 418
						if key == "R" and play.escortFailedTicks >= 24 then -- 420
							play:confirmEscortRestart() -- 421
							applyRoomTransition(play) -- 422
							return -- 423
						end -- 423
						return -- 425
					end -- 425
					if not play.craftBench.active and not play.reloadOpen then -- 427
						if key == "V" then -- 428
							fe.roguelikeUi:requestToggleLedger() -- 429
							return -- 430
						end -- 430
						if fe:isLedgerOpen() then -- 432
							if key == "Escape" or key == "BackSpace" then -- 433
								fe.roguelikeUi:requestCloseLedger() -- 434
							end -- 434
							return -- 436
						end -- 436
						local offers = play:getStoryTalentOffers() -- 438
						if #offers > 0 and fe:canPickStoryTalent(play) then -- 439
							if key == "1" then -- 440
								play:chooseTalent(0) -- 441
								if input ~= nil then -- 442
									input:consumePickRoom() -- 442
								end -- 442
								return -- 443
							end -- 443
							if key == "2" then -- 445
								play:chooseTalent(1) -- 446
								if input ~= nil then -- 447
									input:consumePickRoom() -- 447
								end -- 447
								return -- 448
							end -- 448
							if key == "3" then -- 450
								play:chooseTalent(2) -- 451
								if input ~= nil then -- 452
									input:consumePickRoom() -- 452
								end -- 452
								return -- 453
							end -- 453
							if play.talentModalActive then -- 455
								if key == "Left" or key == "A" then -- 456
									fe.talentDraft.selected = (fe.talentDraft.selected + #offers - 1) % #offers -- 457
									fe.hud.talentSelected = fe.talentDraft.selected -- 458
									return -- 459
								end -- 459
								if key == "Right" or key == "D" then -- 461
									fe.talentDraft.selected = (fe.talentDraft.selected + 1) % #offers -- 462
									fe.hud.talentSelected = fe.talentDraft.selected -- 463
									return -- 464
								end -- 464
								if key == "Return" or key == "Space" then -- 466
									play:chooseTalent(fe.talentDraft.selected) -- 467
									return -- 468
								end -- 468
							end -- 468
						end -- 468
					end -- 468
					if key == "T" and not fe:isLedgerOpen() and not (play.talentModalActive and #play:getStoryTalentOffers() > 0) then -- 473
						play:toggleArtifactWeapon() -- 474
						return -- 475
					end -- 475
				end -- 475
				local inPausedPlay = mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 478
				if fe ~= nil and mode == 1 and (fe.screen ~= "play" or inPausedPlay) then -- 479
					fe.menus:onKeyEvent(key) -- 480
				end -- 480
				if input ~= nil and mode == 1 and fe ~= nil and fe.screen == "play" and not inPausedPlay then -- 482
					if key == "E" then -- 483
						input.interact.pressed = true -- 484
					elseif key == "Space" then -- 485
						input.jump.pressed = true -- 486
					elseif key == "Escape" then -- 487
						input.pause.pressed = true -- 488
					elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen and not play.talentModalActive) then -- 489
						input.retry.pressed = true -- 490
					end -- 490
				end -- 490
			end -- 390
		} -- 390
	) -- 390
	parent:gslot( -- 497
		"AppEvent", -- 497
		function(eventType) -- 497
			if eventType == "BackButton" then -- 498
				handleBackButton() -- 499
				return -- 500
			end -- 500
			if eventType == "Quit" or eventType == "Shutdown" then -- 502
				flushProfile() -- 503
				saveCurrentSession() -- 504
				if input ~= nil then -- 505
					input:clearTransient(false) -- 505
				end -- 505
				return -- 506
			end -- 506
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 508
				flushProfile() -- 509
				saveCurrentSession() -- 510
				if input ~= nil then -- 511
					input:clearTransient(true) -- 511
				end -- 511
				if mode == 1 and fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.escortFailed then -- 512
					play.paused = true -- 513
					play.aimHold = 0 -- 514
					play.bottleAimX = -1 -- 515
					fe.menus:openPause() -- 516
				end -- 516
				if fe ~= nil then -- 518
					fe.audio:setPaused(true) -- 519
				end -- 519
				return -- 521
			end -- 521
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 523
				if fe ~= nil then -- 524
					local paused = play ~= nil and play.paused and mode == 1 and fe.screen == "play" -- 525
					fe.audio:setPaused(paused) -- 526
				end -- 526
			end -- 526
		end -- 497
	) -- 497
	viewW = View.size.width -- 531
	viewH = View.size.height -- 532
	applySize() -- 533
	local reg = _G.package.loaded -- 536
	reg["watch.input"] = input -- 537
	reg["watch.touch"] = input:getTouchRouter() -- 538
	reg["watch.gamepad"] = input:getGamepadRouter() -- 539
	reg["watch.fe"] = { -- 540
		setScreen = function(sc) -- 541
			if fe == nil then -- 542
				return -- 543
			end -- 543
			setMode(1) -- 545
			fe.screen = sc -- 546
			if sc == "splash" then -- 547
				fe.menus:resetSplash() -- 548
			elseif sc == "chapters" then -- 549
				fe.menus:openChapters() -- 550
			elseif sc == "epilogue" then -- 551
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 552
			elseif sc == "history" then -- 556
				fe.menus:openHistory(false) -- 557
			else -- 557
				fe.menus:resetInput() -- 559
			end -- 559
			if sc == "play" then -- 561
				ensurePlay() -- 562
			end -- 562
		end, -- 541
		jumpRoom = function(keyOrIdx) -- 565
			local idx = -1 -- 566
			if type(keyOrIdx) == "number" then -- 567
				idx = keyOrIdx -- 568
			else -- 568
				local k = 0 -- 570
				do -- 570
					k = 0 -- 571
					while k < #ROOMS do -- 571
						if ROOMS[k + 1].key == keyOrIdx then -- 572
							idx = k -- 573
						end -- 573
						k = k + 1 -- 571
					end -- 571
				end -- 571
			end -- 571
			if idx >= 0 and idx < #ROOMS then -- 577
				enterPlayRoom(idx, "debug") -- 578
			end -- 578
		end, -- 565
		getPlay = function() return play end, -- 581
		getFrontend = function() return fe end, -- 582
		startStory = function(seed) -- 584
			enterPlayRoom( -- 585
				officialStartIndex(), -- 585
				"official", -- 585
				true, -- 585
				seed -- 585
			) -- 585
			return play -- 586
		end, -- 584
		previewChapter = function(idx, routeOrSeed, seedOpt) -- 589
			local route = type(routeOrSeed) == "string" and routeOrSeed or nil -- 590
			local seed = type(routeOrSeed) == "number" and routeOrSeed or seedOpt -- 591
			enterPlayRoom( -- 592
				idx, -- 592
				"chapter", -- 592
				false, -- 592
				seed, -- 592
				route -- 592
			) -- 592
			return play -- 593
		end, -- 589
		getStoryRun = function() return storyRun end, -- 595
		getProfilePending = function() return profilePending() end, -- 596
		flushProfileNow = function() return flushProfile() end, -- 597
		getProfile = function() return profile end, -- 599
		getProfileStatus = function() return profileStatus end, -- 600
		getProfileDetail = function() return profileDetail end, -- 601
		useTestSave = function(name) -- 602
			setSaveFile(name) -- 603
			setSessionFile(name == "" and "" or name .. ".session") -- 604
			clearProfilePending() -- 605
			local loaded = loadSave() -- 606
			profile = loaded.state -- 607
			profileStatus = loaded.status -- 608
			profileDetail = loaded.detail -- 609
			refreshTitleSessionFlag() -- 610
		end, -- 602
		useTestSession = function(name) -- 612
			setSessionFile(name) -- 613
			refreshTitleSessionFlag() -- 614
		end, -- 612
		getSessionFile = getSessionFile, -- 616
		hasSessionSave = hasSessionSave, -- 617
		saveSessionNow = function() return saveCurrentSession() end, -- 618
		clearSessionNow = function() -- 619
			local ok = clearSession() -- 620
			refreshTitleSessionFlag() -- 621
			return ok -- 622
		end, -- 619
		continueStory = function() return continueOfficialStory() end, -- 624
		saveNow = function() return saveSave(profile) end, -- 625
		getSaveFile = getSaveFile, -- 626
		isRelease = function() return isReleaseBuild() end, -- 627
		getReleaseVersion = function() -- 628
			local ____opt_31 = getReleaseConfig() -- 628
			return ____opt_31 and ____opt_31.version or "dev" -- 628
		end, -- 628
		toggleFullscreen = function() return toggleFullscreen() end, -- 629
		quitGame = function() return quitGame() end, -- 630
		handleBackButton = function() return handleBackButton() end, -- 631
		getViewport = function() return stageVp end, -- 632
		getTargetId = function() return getActiveTarget().id end, -- 633
		getTouchController = function() return input and input:getTouchControls() end, -- 634
		getTouchRouter = function() return input and input:getTouchRouter() end, -- 635
		getGamepad = function() return input and input:getGamepadRouter() end, -- 636
		setGamepadSim = function(state) -- 637
			if input ~= nil then -- 638
				input:setGamepadSim(state) -- 638
			end -- 638
		end, -- 637
		injectTouch = function(phase, id, x, y, fromMouse) -- 640
			if input ~= nil then -- 641
				input:injectTouch( -- 641
					phase, -- 641
					id, -- 641
					x, -- 641
					y, -- 641
					fromMouse -- 641
				) -- 641
			end -- 641
		end, -- 640
		getInputMode = function() return input and input.inputMode or getActiveTarget().defaultInputMode end, -- 643
		setInputMode = function(m) -- 644
			if input ~= nil then -- 645
				input:setInputMode(m) -- 645
			end -- 645
		end, -- 644
		setModePref = function(pref) -- 647
			if input ~= nil then -- 648
				input:setModePref(pref) -- 648
			end -- 648
		end, -- 647
		applyViewportForTest = function(w, h) -- 650
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 651
				testViewportOverride = {w = w, h = h} -- 652
				viewW = w -- 653
				viewH = h -- 654
			else -- 654
				testViewportOverride = nil -- 656
				viewW = View.size.width -- 657
				viewH = View.size.height -- 658
			end -- 658
			applySize() -- 660
			dirty = true -- 661
			return stageVp -- 662
		end, -- 650
		getToast = function() return fe and fe:getToastText() or "" end -- 664
	} -- 664
	if mode == 1 and startScreen == "play" then -- 667
		ensurePlay() -- 668
	end -- 668
	parent:schedule(function(frameDt) -- 671
		tick(frameDt) -- 672
		return false -- 673
	end) -- 671
end -- 360
local function pickByIndex(idx, source) -- 783
	if source == nil then -- 783
		source = "debug" -- 783
	end -- 783
	if idx < 0 or idx >= #ROOMS then -- 784
		return -- 785
	end -- 785
	flushProfile() -- 787
	if storyRun ~= nil then -- 788
		storyRun.source = source -- 789
	end -- 789
	current = idx -- 791
	dirty = true -- 792
	play = nil -- 793
	clock:reset() -- 794
	if mode == 1 then -- 795
		if fe ~= nil then -- 796
			fe.screen = "play" -- 797
		end -- 797
		ensurePlay() -- 799
	end -- 799
end -- 783
return ____exports -- 783
