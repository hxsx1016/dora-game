-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local ____exports = {} -- 1
local randomRunSeed, onFirstUserGesture, toggleFullscreen, quitGame, canSaveSession, refreshTitleSessionFlag, saveCurrentSession, continueOfficialStory, flushProfile, officialStartIndex, roomIndexByKey, applyChapterPreviewContext, enterPlayRoom, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, applyRoomTransition, tickFrontend, root, storyRun, profile, current, viewW, viewH, input, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Size = ____Dora.Size -- 1
local Vec2 = ____Dora.Vec2 -- 1
local View = ____Dora.View -- 1
local ____target = require("Script.watch.target") -- 2
local getActiveTarget = ____target.getActiveTarget -- 2
local ____rooms = require("Script.watch.rooms") -- 3
local ROOMS = ____rooms.ROOMS -- 3
local ____input = require("Script.watch.input") -- 4
local Input = ____input.Input -- 4
local ____play = require("Script.watch.play") -- 5
local Play = ____play.Play -- 5
local ____clock = require("Script.watch.clock") -- 6
local STEP = ____clock.STEP -- 6
local StepClock = ____clock.StepClock -- 6
local ____platform = require("Script.watch.platform") -- 8
local canQuitApp = ____platform.canQuitApp -- 10
local canToggleFullscreen = ____platform.canToggleFullscreen -- 11
local computeStageViewport = ____platform.computeStageViewport -- 12
local getReleaseConfig = ____platform.getReleaseConfig -- 13
local isReleaseMode = ____platform.isReleaseMode -- 14
local ____frontend = require("Script.watch.fe.frontend") -- 16
local WatchFrontend = ____frontend.WatchFrontend -- 16
local ____run = require("Script.watch.run") -- 17
local createRun = ____run.createRun -- 17
local createStoryTalents = ____run.createStoryTalents -- 17
local normalizeLegacyTalent = ____run.normalizeLegacyTalent -- 17
local ____save = require("Script.watch.save") -- 18
local emptySave = ____save.emptySave -- 18
local loadSave = ____save.loadSave -- 18
local saveSave = ____save.saveSave -- 18
local setSaveFile = ____save.setSaveFile -- 18
local getSaveFile = ____save.getSaveFile -- 18
local markProfilePending = ____save.markProfilePending -- 19
local flushSaveProfile = ____save.flushProfile -- 19
local clearProfilePending = ____save.clearProfilePending -- 19
local profilePending = ____save.profilePending -- 19
local loadSession = ____save.loadSession -- 20
local saveSession = ____save.saveSession -- 20
local clearSession = ____save.clearSession -- 20
local hasSessionSave = ____save.hasSessionSave -- 20
local setSessionFile = ____save.setSessionFile -- 20
local getSessionFile = ____save.getSessionFile -- 20
function randomRunSeed() -- 43
	return math.max( -- 44
		1, -- 44
		math.floor(math.abs(App.rand)) % 2147483646 -- 44
	) -- 44
end -- 44
function onFirstUserGesture() -- 51
	if audioUnlocked or fe == nil then -- 51
		return -- 53
	end -- 53
	audioUnlocked = true -- 55
	fe.audio:unlockAndResyncAfterGesture() -- 56
end -- 56
function toggleFullscreen() -- 59
	if not canToggleFullscreen() then -- 59
		return false -- 61
	end -- 61
	do -- 61
		local function ____catch() -- 61
			return true, false -- 68
		end -- 68
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 68
			local next = not App.fullScreen -- 64
			App.fullScreen = next -- 65
			return true, next -- 66
		end) -- 66
		if not ____try then -- 66
			____hasReturned, ____returnValue = ____catch() -- 66
		end -- 66
		if ____hasReturned then -- 66
			return ____returnValue -- 63
		end -- 63
	end -- 63
end -- 63
function quitGame() -- 72
	flushProfile() -- 73
	saveCurrentSession() -- 74
	if input ~= nil then -- 74
		input:clearTransient(false) -- 75
	end -- 75
	if fe ~= nil then -- 75
		fe.audio:stopRoomTransient() -- 77
	end -- 77
	if not canQuitApp() then -- 77
		current = 0 -- 81
		play = nil -- 82
		clock:reset() -- 83
		if fe ~= nil then -- 83
			fe.audio:stopRoomTransient() -- 85
			fe.screen = "title" -- 86
			fe.menus:resetInput() -- 87
		end -- 87
		return -- 89
	end -- 89
	App:shutdown() -- 91
end -- 91
function canSaveSession() -- 150
	if play == nil or storyRun == nil then -- 150
		return false -- 152
	end -- 152
	if storyRun.source ~= "official" or play.run.finished then -- 152
		return false -- 155
	end -- 155
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 155
		return false -- 158
	end -- 158
	return true -- 160
end -- 160
function refreshTitleSessionFlag() -- 163
	if fe ~= nil then -- 163
		local has = hasSessionSave() -- 165
		fe.menus.hasSession = has -- 166
		if has then -- 166
			local loaded = loadSession() -- 168
			fe.menus:setSessionRoomKey(loaded.status == "ok" and loaded.state ~= nil and loaded.state.roomKey or "") -- 169
		else -- 169
			fe.menus:setSessionRoomKey("") -- 171
		end -- 171
	end -- 171
end -- 171
function saveCurrentSession() -- 176
	if not canSaveSession() or play == nil then -- 176
		return false -- 178
	end -- 178
	local ok = saveSession(play:exportSession()) -- 180
	play.sessionDirty = not ok -- 181
	refreshTitleSessionFlag() -- 182
	return ok -- 183
end -- 183
function continueOfficialStory() -- 186
	if play and play.escortFailed and play.run.source == "official" and play.sessionDirty then -- 186
		play:confirmEscortRestart() -- 189
		applyRoomTransition(play) -- 190
		if fe ~= nil then -- 190
			fe.screen = "play" -- 191
		end -- 191
		return play -- 192
	end -- 192
	local res = loadSession() -- 194
	if res.status ~= "ok" or res.state == nil then -- 194
		refreshTitleSessionFlag() -- 196
		return nil -- 197
	end -- 197
	local s = res.state -- 199
	local idx = roomIndexByKey(s.roomKey) -- 200
	if ROOMS[idx + 1].key ~= s.roomKey then -- 200
		return nil -- 202
	end -- 202
	storyRun = createRun(s.seed, "official", profile) -- 204
	storyRun.checkpoint = s.checkpoint -- 205
	storyRun.story.route = s.route -- 206
	storyRun.story.hp = s.hp -- 207
	storyRun.story.maxHp = s.maxHp -- 208
	storyRun.story.hpAtGate = s.hpAtGate -- 209
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 210
	storyRun.story.settled = s.settled -- 211
	storyRun.story.phase = s.phase -- 212
	storyRun.story.countTick = s.countTick -- 213
	storyRun.story.phaseTick = s.phaseTick -- 214
	storyRun.story.handTicks = s.handTicks -- 215
	storyRun.story.handDone = s.handDone -- 216
	storyRun.story.lineSaid = s.lineSaid -- 217
	storyRun.story.tied = s.tied -- 218
	storyRun.story.carry = s.carry -- 219
	storyRun.story.escortDone = s.escortDone -- 220
	storyRun.story.craftedWeapon = s.craftedWeapon -- 221
	storyRun.story.equippedWeapon = s.equippedWeapon -- 222
	storyRun.inventory.wood = s.wood -- 223
	storyRun.inventory.bell = s.bell -- 224
	storyRun.inventory.scrap = s.scrap -- 225
	storyRun.inventory.wedge = s.wedge -- 226
	storyRun.inventory.ammo = s.ammo -- 227
	storyRun.inventory.shield = s.shield -- 228
	storyRun.inventory.pass = s.pass -- 229
	storyRun.inventory.quickbelt = s.quickbelt -- 230
	local k = 0 -- 231
	do -- 231
		k = 0 -- 232
		while k < #s.taken do -- 232
			storyRun.taken[s.taken[k + 1]] = true -- 233
			k = k + 1 -- 232
		end -- 232
	end -- 232
	do -- 232
		k = 0 -- 235
		while k < #s.segments do -- 235
			storyRun.story.segments[s.segments[k + 1]] = true -- 236
			k = k + 1 -- 235
		end -- 235
	end -- 235
	if s.campaignRoute ~= nil then -- 235
		storyRun.route = s.campaignRoute -- 239
	end -- 239
	if s.joined ~= nil then -- 239
		storyRun.joined = s.joined -- 242
	end -- 242
	if s.c1Latch ~= nil then -- 242
		storyRun.c1Latch = s.c1Latch -- 245
	end -- 245
	if s.c2Latch ~= nil then -- 245
		storyRun.c2Latch = s.c2Latch -- 248
	end -- 248
	if s.props ~= nil then -- 248
		do -- 248
			k = 0 -- 251
			while k < #s.props do -- 251
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 252
				local pid = parts[1] -- 253
				if pid ~= nil and pid ~= "" then -- 253
					local ____storyRun_props_12 = storyRun.props -- 255
					local ____temp_8 -- 256
					if parts[2] == nil then -- 256
						____temp_8 = true -- 256
					else -- 256
						____temp_8 = parts[2] == "1" -- 256
					end -- 256
					local ____temp_10 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 257
					local ____temp_11 = parts[4] == "1" -- 258
					local ____temp_9 -- 259
					if parts[5] == "1" then -- 259
						____temp_9 = true -- 259
					else -- 259
						____temp_9 = nil -- 259
					end -- 259
					____storyRun_props_12[pid] = {broken = ____temp_8, hp = ____temp_10, wedge = ____temp_11, revealed = ____temp_9} -- 255
				end -- 255
				k = k + 1 -- 251
			end -- 251
		end -- 251
	end -- 251
	local stTalents = createStoryTalents(s.seed) -- 264
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 264
		stTalents.randomState = s.talentSeed -- 266
	end -- 266
	if s.escortAttempt ~= nil and s.escortAttempt >= 1 then -- 266
		stTalents.attempt = s.escortAttempt -- 269
	end -- 269
	if s.escortVariant ~= nil and s.escortVariant >= 0 then -- 269
		stTalents.variant = s.escortVariant -- 272
	end -- 272
	stTalents.deferred = s.talentDeferred == true -- 274
	stTalents.room = s.talentRoom or "" -- 275
	if s.talentRanks ~= nil and #s.talentRanks > 0 then -- 275
		do -- 275
			k = 0 -- 277
			while k < #s.talentRanks do -- 277
				local parts = __TS__StringSplit(s.talentRanks[k + 1], ":") -- 278
				local ____temp_13 -- 279
				if parts[1] ~= nil then -- 279
					____temp_13 = normalizeLegacyTalent(parts[1]) -- 279
				else -- 279
					____temp_13 = nil -- 279
				end -- 279
				local norm = ____temp_13 -- 279
				local rk = parts[2] ~= nil and (tonumber(parts[2]) or 0) or 0 -- 280
				if norm ~= nil and rk > 0 then -- 280
					stTalents.ranks[norm] = (stTalents.ranks[norm] or 0) + math.floor(rk) -- 282
				end -- 282
				k = k + 1 -- 277
			end -- 277
		end -- 277
	else -- 277
		stTalents.ranks.vitality = s.talentVitality or 0 -- 287
		stTalents.ranks.focus = s.talentReload or 0 -- 288
		stTalents.ranks.guard = s.talentGuard or 0 -- 289
		stTalents.ranks.salvage = s.talentCraft or 0 -- 290
	end -- 290
	if s.talentOffers ~= nil then -- 290
		do -- 290
			k = 0 -- 293
			while k < #s.talentOffers do -- 293
				local norm = normalizeLegacyTalent(s.talentOffers[k + 1]) -- 294
				if norm ~= nil then -- 294
					local ____stTalents_offers_14 = stTalents.offers -- 294
					____stTalents_offers_14[#____stTalents_offers_14 + 1] = norm -- 296
				end -- 296
				k = k + 1 -- 293
			end -- 293
		end -- 293
	end -- 293
	storyRun.story.talents = stTalents -- 300
	current = idx -- 301
	clock:reset() -- 302
	if fe ~= nil then -- 302
		fe.screen = "play" -- 304
	end -- 304
	play = nil -- 306
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 307
	local cur = play -- 308
	if cur ~= nil then -- 308
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 308
			cur.cartAxle = s.cartAxle -- 311
			cur.cartDocked = s.cartDocked -- 312
		end -- 312
		if s.playerX ~= nil and s.playerX >= 0 then -- 312
			cur.player.x = math.max( -- 315
				cur.room.minX + 16, -- 315
				math.min(cur.room.maxX - 16, s.playerX) -- 315
			) -- 315
			cur.player.y = math.max(0, s.playerY or 0) -- 316
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 316
				cur.player.depth = math.max( -- 318
					cur.room.depth.min, -- 318
					math.min(cur.room.depth.max, s.playerDepth) -- 318
				) -- 318
			end -- 318
		end -- 318
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 318
			cur.gateTick = s.gateTick -- 322
		end -- 322
		if cur.room.key == "village" then -- 322
			if s.hasBottle == true then -- 322
				cur.hasBottle = true -- 325
			end -- 325
			if s.villagePassed == true then -- 325
				cur.passed = true -- 326
			end -- 326
		end -- 326
		if cur.room.key == "prologue" and (s.phase == "" or s.phase == "prologue-wake" or s.phase == "prologue-shadow" or s.phase == "prologue-escape" or s.phase == "prologue-hide") then -- 326
			cur.phase = "prologue-wake" -- 335
		end -- 335
		if (string.find(cur.room.key, "escort", nil, true) or 0) - 1 == 0 and s.route == "soldier" and not cur.craftBench.active and not cur.carryOn then -- 335
			cur.carryOn = true -- 339
			storyRun.story.carry = true -- 340
		end -- 340
	end -- 340
	return play -- 343
end -- 343
function flushProfile() -- 585
	local cur = play -- 586
	if cur ~= nil and cur.archiveDirty then -- 586
		cur.archiveDirty = false -- 588
		markProfilePending(profile) -- 589
	end -- 589
	local ok = flushSaveProfile() -- 591
	if not ok and cur ~= nil then -- 591
		cur.archiveDirty = true -- 593
	end -- 593
	return ok -- 595
end -- 595
function officialStartIndex() -- 599
	local mp = profile.museumPhase -- 600
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 601
	return inMuseum and roomIndexByKey("museum") or 0 -- 602
end -- 602
function roomIndexByKey(key) -- 605
	local i = 0 -- 606
	do -- 606
		i = 0 -- 607
		while i < #ROOMS do -- 607
			if ROOMS[i + 1].key == key then -- 607
				return i -- 609
			end -- 609
			i = i + 1 -- 607
		end -- 607
	end -- 607
	return 0 -- 612
end -- 612
function applyChapterPreviewContext(targetRun, roomKey, routeOverride) -- 615
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" and routeOverride ~= "soldier" then -- 615
		targetRun.story.route = "child" -- 620
		targetRun.story.settled = true -- 621
		targetRun.story.countTick = 1440 -- 622
	elseif roomKey == "gatepath" or (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 or roomKey == "tower" and routeOverride == "soldier" then -- 622
		targetRun.story.route = "soldier" -- 625
		targetRun.story.settled = true -- 626
		targetRun.joined = true -- 627
		targetRun.story.handDone = true -- 628
		targetRun.story.tied = true -- 629
		local ____targetRun_story_45 = targetRun.story -- 630
		targetRun.story.maxHpAtGate = 3 -- 630
		____targetRun_story_45.hpAtGate = 3 -- 630
		if (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 then -- 630
			targetRun.story.carry = true -- 632
		end -- 632
		if roomKey == "escort4" or roomKey == "escort5" then -- 632
			targetRun.inventory.wood = 2 -- 635
			targetRun.inventory.bell = 1 -- 636
		end -- 636
		if roomKey == "escort3" then -- 636
			targetRun.inventory.wood = math.max(targetRun.inventory.wood, 2) -- 639
			targetRun.inventory.scrap = math.max(targetRun.inventory.scrap, 2) -- 640
			targetRun.inventory.bell = math.max(targetRun.inventory.bell, 1) -- 641
			targetRun.inventory.wedge = math.max(targetRun.inventory.wedge, 1) -- 642
		end -- 642
	end -- 642
end -- 642
function enterPlayRoom(idx, source, fresh, seedOverride, chapterRoute) -- 647
	if source == nil then -- 647
		source = "debug" -- 647
	end -- 647
	if fresh == nil then -- 647
		fresh = false -- 647
	end -- 647
	current = idx -- 648
	clock:reset() -- 649
	if fe ~= nil then -- 649
		fe.screen = "play" -- 651
	end -- 651
	play = nil -- 653
	if fresh or source == "chapter" or storyRun == nil then -- 653
		storyRun = createRun( -- 656
			seedOverride or (source == "debug" and 20261124 or randomRunSeed()), -- 656
			source, -- 656
			profile -- 656
		) -- 656
		if source == "chapter" then -- 656
			local targetKey = ROOMS[current + 1] ~= nil and ROOMS[current + 1].key or "" -- 658
			applyChapterPreviewContext(storyRun, targetKey, chapterRoute) -- 659
		end -- 659
	else -- 659
		storyRun.source = source -- 662
	end -- 662
	ensurePlay() -- 664
	local firstPlay = play -- 666
	if firstPlay ~= nil and ROOMS[current + 1].key == "prologue" and (fresh and source == "official" or source == "chapter") then -- 666
		firstPlay.phase = "prologue-wake" -- 669
	end -- 669
	flushProfile() -- 671
end -- 671
function applySize() -- 674
	if root == nil then -- 674
		return -- 676
	end -- 676
	root.size = Size(viewW, viewH) -- 678
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 679
	stageVp = computeStageViewport(viewW, viewH) -- 680
	if input ~= nil then -- 680
		input:setStageViewport(stageVp) -- 682
	end -- 682
	if fe ~= nil then -- 682
		fe:setStagePlacement(stageVp) -- 685
	end -- 685
end -- 685
function syncFrameAdapters(frameDt) -- 689
	if input == nil then -- 689
		return -- 691
	end -- 691
	local target = input.target -- 693
	if not target.supportsTouch and not target.supportsGamepad then -- 693
		return -- 695
	end -- 695
	local p = play -- 697
	local isPlayMode = fe ~= nil and fe.screen == "play" and p ~= nil -- 698
	local storyTalentBoxes = target.supportsTouch and isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 699
		p, -- 701
		stageVp.stageW, -- 701
		stageVp.stageH, -- 701
		input:isTouchMode() -- 701
	) or ({}) -- 701
	local isFs = false -- 704
	if target:canToggleFullscreen() then -- 704
		do -- 704
			local function ____catch() -- 704
				isFs = false -- 709
			end -- 709
			local ____try = pcall(function() -- 709
				isFs = App.fullScreen -- 707
			end) -- 707
			if not ____try then -- 707
				____catch() -- 707
			end -- 707
		end -- 707
	end -- 707
	local ____input_64 = input -- 712
	local ____input_syncFrame_65 = input.syncFrame -- 712
	local ____stageVp_57 = stageVp -- 713
	local ____temp_58 = fe ~= nil and fe.screen or "title" -- 715
	local ____storyRun_59 = storyRun -- 717
	local ____isPlayMode_48 -- 718
	if isPlayMode then -- 718
		____isPlayMode_48 = fe and fe.cam -- 718
	else -- 718
		____isPlayMode_48 = nil -- 718
	end -- 718
	local ____input_60 = input -- 719
	local ____temp_49 -- 720
	if fe ~= nil then -- 720
		____temp_49 = fe.contract:isAssistHintsEnabled() -- 720
	else -- 720
		____temp_49 = false -- 720
	end -- 720
	local ____temp_50 -- 721
	if fe ~= nil then -- 721
		____temp_50 = fe.audio:isAllMuted() -- 721
	else -- 721
		____temp_50 = false -- 721
	end -- 721
	local ____isFs_61 = isFs -- 722
	local ____storyTalentBoxes_62 = storyTalentBoxes -- 723
	local ____temp_51 -- 724
	if p and fe then -- 724
		____temp_51 = fe:getEscortDeathBoxes(p, stageVp.stageW, stageVp.stageH) -- 724
	else -- 724
		____temp_51 = nil -- 724
	end -- 724
	local ____temp_63 = fe and fe.roguelikeUi:getLedgerButtonRect() -- 725
	local ____temp_56 = fe and fe.roguelikeUi:isLedgerOpen() -- 726
	if ____temp_56 == nil then -- 726
		____temp_56 = false -- 726
	end -- 726
	____input_syncFrame_65(____input_64, { -- 712
		viewport = ____stageVp_57, -- 713
		mode = 1, -- 714
		screen = ____temp_58, -- 715
		play = p, -- 716
		run = ____storyRun_59, -- 717
		cam = ____isPlayMode_48, -- 718
		input = ____input_60, -- 719
		assistHintsEnabled = ____temp_49, -- 720
		isMuted = ____temp_50, -- 721
		isFullscreen = ____isFs_61, -- 722
		storyTalentBoxes = ____storyTalentBoxes_62, -- 723
		escortDeathBoxes = ____temp_51, -- 724
		ledgerBox = ____temp_63, -- 725
		ledgerOpen = ____temp_56, -- 726
		dt = frameDt -- 727
	}) -- 727
end -- 727
function renderTouchOverlay() -- 731
	if input ~= nil then -- 731
		input:renderOverlay() -- 732
	end -- 732
end -- 732
function tick(frameDt) -- 735
	appClock = appClock + math.min( -- 736
		0.05, -- 736
		math.max(0, frameDt) -- 736
	) -- 736
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 737
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 738
	if w ~= viewW or h ~= viewH then -- 738
		viewW = w -- 740
		viewH = h -- 741
		applySize() -- 742
	end -- 742
	if input == nil then -- 742
		return -- 745
	end -- 745
	syncFrameAdapters(frameDt) -- 747
	input:update() -- 748
	if input.userInteracted then -- 748
		onFirstUserGesture() -- 751
	end -- 751
	if input.muteTogglePressed and fe ~= nil then -- 751
		input.muteTogglePressed = false -- 754
		fe.audio:toggleAllMuted() -- 755
	end -- 755
	if input.fullscreenTogglePressed then -- 755
		input.fullscreenTogglePressed = false -- 758
		toggleFullscreen() -- 759
	end -- 759
	if input.artifactTogglePressed then -- 759
		input.artifactTogglePressed = false -- 762
		if (fe and fe.screen) == "play" and play ~= nil and not play.paused and not play.escortFailed and not play.talentModalActive and not fe.roguelikeUi:isLedgerOpen() then -- 762
			play:toggleArtifactWeapon() -- 765
		end -- 765
	end -- 765
	if input.bottleCanceled and play ~= nil then -- 765
		input.bottleCanceled = false -- 769
		play.aimHold = 0 -- 770
		play.bottleAimX = -1 -- 771
	end -- 771
	if fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and not play.escortFailed and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 771
		if fe:canPickStoryTalent(play) then -- 771
			play:chooseTalent(input.pickRoom - 1) -- 778
		end -- 778
	end -- 778
	input.pickRoom = 0 -- 781
	tickFrontend(frameDt) -- 782
	renderTouchOverlay() -- 783
end -- 783
function registerPlay() -- 787
	local reg = _G.package.loaded -- 788
	reg["watch.play"] = play -- 789
	reg["watch.room"] = ROOMS[current + 1].key -- 790
end -- 790
function ensurePlay(resume) -- 794
	if storyRun == nil then -- 794
		storyRun = createRun(20261124, "debug", profile) -- 798
	end -- 798
	play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 800
	registerPlay() -- 801
	clock:reset() -- 802
	if fe ~= nil then -- 802
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 804
	end -- 804
end -- 804
function applyRoomTransition(p) -- 809
	if p.wantRoom == "" then -- 809
		return false -- 811
	end -- 811
	local key = p.wantRoom -- 813
	p.wantRoom = "" -- 814
	local idx = -1 -- 815
	local j = 0 -- 816
	do -- 816
		j = 0 -- 817
		while j < #ROOMS do -- 817
			if ROOMS[j + 1].key == key then -- 817
				idx = j -- 819
			end -- 819
			j = j + 1 -- 817
		end -- 817
	end -- 817
	if idx < 0 then -- 817
		return false -- 823
	end -- 823
	flushProfile() -- 828
	local leaving = p:drainEvents() -- 829
	if p.restartStory then -- 829
		if storyRun ~= nil and storyRun.source == "official" then -- 829
			clearSession() -- 833
			refreshTitleSessionFlag() -- 834
		end -- 834
		local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 836
		local nextSeed = nextSource == "official" and randomRunSeed() or 20261124 -- 837
		storyRun = createRun(nextSeed, nextSource, profile) -- 838
	end -- 838
	current = idx -- 840
	ensurePlay() -- 841
	local fresh = play -- 842
	if fresh ~= nil then -- 842
		if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 842
			fresh.phase = "prologue-wake" -- 845
		end -- 845
		fresh:adoptEvents(leaving) -- 847
	end -- 847
	if not p.restartStory then -- 847
		saveCurrentSession() -- 850
	end -- 850
	clock:reset() -- 852
	return true -- 853
end -- 853
function tickFrontend(frameDt) -- 856
	if fe == nil or input == nil then -- 856
		return -- 858
	end -- 858
	if fe.screen ~= "play" then -- 858
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 863
		input:consumeEdges() -- 864
		if act.type == "splashDone" then -- 864
			fe.menus:resetInput() -- 866
			fe.screen = "title" -- 867
		elseif act.type == "continue" then -- 867
			if continueOfficialStory() == nil then -- 867
				enterPlayRoom( -- 870
					officialStartIndex(), -- 870
					"official", -- 870
					true -- 870
				) -- 870
			end -- 870
		elseif act.type == "start" then -- 870
			clearSession() -- 874
			refreshTitleSessionFlag() -- 875
			enterPlayRoom( -- 876
				officialStartIndex(), -- 876
				"official", -- 876
				true -- 876
			) -- 876
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 876
			enterPlayRoom( -- 878
				act.roomIndex, -- 878
				"chapter", -- 878
				false, -- 878
				nil, -- 878
				act.route -- 878
			) -- 878
		elseif act.type == "openChapters" then -- 878
			fe.menus:openChapters() -- 880
			fe.screen = "chapters" -- 881
		elseif act.type == "openControls" then -- 881
			fe.menus:resetInput() -- 883
			fe.screen = "controls" -- 884
		elseif act.type == "openHistory" then -- 884
			fe.menus:openHistory(true) -- 886
			fe.screen = "history" -- 887
		elseif act.type == "backEpilogue" then -- 887
			fe.menus:resetInput() -- 889
			fe.screen = "epilogue" -- 890
		elseif act.type == "replayStory" then -- 890
			clearSession() -- 892
			refreshTitleSessionFlag() -- 893
			enterPlayRoom( -- 894
				officialStartIndex(), -- 894
				"official", -- 894
				true -- 894
			) -- 894
		elseif act.type == "backTitle" then -- 894
			fe.menus:resetInput() -- 896
			fe.screen = "title" -- 897
		elseif act.type == "backPause" then -- 897
			fe.menus:resetInput() -- 899
			fe.screen = "play" -- 900
		elseif act.type == "quit" then -- 900
			quitGame() -- 902
		end -- 902
		return -- 904
	end -- 904
	if play == nil then -- 904
		ensurePlay() -- 909
	end -- 909
	if play == nil then -- 909
		return -- 912
	end -- 912
	local p = play -- 914
	p.aimX = input.mx -- 916
	p.aimY = input.my -- 917
	local zoneTap = input.touchZoneTap -- 919
	if zoneTap ~= "ledger:toggle" then -- 919
		input.touchZoneTap = "" -- 920
	end -- 920
	if not p.paused and p.escortFailed then -- 920
		local deathAction = "" -- 924
		if zoneTap == "escort:retry" and p.escortFailedTicks >= 12 then -- 924
			deathAction = "retry" -- 926
		elseif zoneTap == "escort:title" then -- 926
			deathAction = "title" -- 928
		else -- 928
			if input.navLeft or input.navPrevTab then -- 928
				fe.roguelikeUi.deathSelected = 0 -- 931
			elseif input.navRight or input.navNextTab then -- 931
				fe.roguelikeUi.deathSelected = 1 -- 933
			end -- 933
			if input.pause.pressed or input.navBack then -- 933
				deathAction = "title" -- 936
			elseif p.escortFailedTicks >= 24 and input.retry.pressed then -- 936
				deathAction = "retry" -- 938
			elseif p.escortFailedTicks >= 24 and input.navConfirm then -- 938
				deathAction = fe.roguelikeUi.deathSelected == 0 and "retry" or "title" -- 940
			elseif p.escortFailedTicks >= 12 and (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) then -- 940
				deathAction = fe:tryPickEscortDeathAtPointer(p, input, stageVp.stageW, stageVp.stageH) -- 943
			end -- 943
		end -- 943
		if deathAction == "retry" then -- 943
			input:consumeEdges() -- 947
			p:confirmEscortRestart() -- 948
			applyRoomTransition(p) -- 949
			return -- 950
		end -- 950
		if deathAction == "title" then -- 950
			input:consumeEdges() -- 953
			fe.audio:stopRoomTransient() -- 954
			fe.menus:resetInput() -- 955
			fe.screen = "title" -- 956
			input:clearTransient(true) -- 957
			return -- 958
		end -- 958
		input.pause.pressed = false -- 960
		input.retry.pressed = false -- 961
		input.fire.pressed = false -- 962
	end -- 962
	if not p.paused and fe.roguelikeUi:isLedgerOpen() then -- 962
		clock:reset() -- 966
		fe:renderPlay( -- 967
			frameDt, -- 967
			p, -- 967
			input, -- 967
			stageVp.stageW, -- 967
			stageVp.stageH -- 967
		) -- 967
		input:consumeEdges() -- 968
		return -- 969
	end -- 969
	local offers = p:getStoryTalentOffers() -- 972
	if fe:canPickStoryTalent(p) and #offers > 0 then -- 972
		if fe.hud.talentSelected >= #offers then -- 972
			fe.hud.talentSelected = 0 -- 975
		end -- 975
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 975
			local idx = __TS__ParseInt( -- 978
				string.sub(zoneTap, 8), -- 978
				10 -- 978
			) -- 978
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 978
				fe.hud.talentSelected = idx -- 980
				input.fire.pressed = false -- 981
			end -- 981
		else -- 981
			local navDelta = p.talentModalActive and ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) or 0 -- 984
			local totalDelta = navDelta ~= 0 and navDelta or input.talentDelta -- 987
			if totalDelta ~= 0 then -- 987
				fe.hud.talentSelected = (fe.hud.talentSelected + totalDelta + #offers) % #offers -- 989
				input.talentDelta = 0 -- 990
			end -- 990
			if input.talentConfirm or p.talentModalActive and input.navConfirm then -- 990
				p:chooseTalent(fe.hud.talentSelected) -- 993
				input.talentConfirm = false -- 994
				input.fire.pressed = false -- 995
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 995
				input.fire.pressed = false -- 998
			end -- 998
		end -- 998
	end -- 998
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 998
		if input.navConfirm then -- 998
			input.interact.pressed = true -- 1006
		end -- 1006
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1006
			flushProfile() -- 1009
			if p.run.source == "official" and hasSessionSave() then -- 1009
				clearSession() -- 1011
				refreshTitleSessionFlag() -- 1012
			end -- 1012
			fe.audio:stopRoomTransient() -- 1014
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1015
			fe.screen = "epilogue" -- 1019
			input:clearTransient(true) -- 1020
			input:consumeEdges() -- 1021
			return -- 1022
		end -- 1022
	end -- 1022
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1022
		p:closeCraftBench() -- 1027
		input:consumeEdges() -- 1028
		return -- 1029
	end -- 1029
	if not p.paused and not p.escortFailed and input.pause.pressed then -- 1029
		p.paused = true -- 1032
		p.aimHold = 0 -- 1033
		p.bottleAimX = -1 -- 1034
		saveCurrentSession() -- 1035
		fe.menus:openPause() -- 1036
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1037
		input:clearTransient(true) -- 1038
		input:consumeEdges() -- 1039
	end -- 1039
	if p.paused then -- 1039
		clock:reset() -- 1044
		local pauseAct = fe:renderPlay( -- 1045
			frameDt, -- 1045
			p, -- 1045
			input, -- 1045
			stageVp.stageW, -- 1045
			stageVp.stageH -- 1045
		) -- 1045
		input:consumeEdges() -- 1046
		if pauseAct.type == "resume" then -- 1046
			p.paused = false -- 1048
		elseif pauseAct.type == "retry" then -- 1048
			if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1048
				p:restartEscortRun() -- 1051
				applyRoomTransition(p) -- 1052
			else -- 1052
				ensurePlay({checkpoint = p.checkpoint}) -- 1054
			end -- 1054
		elseif pauseAct.type == "openChapters" then -- 1054
			fe.audio:stopRoomTransient() -- 1057
			fe.audio:setPaused(false) -- 1058
			fe.menus:openChapters(current) -- 1059
			fe.screen = "chapters" -- 1060
		elseif pauseAct.type == "toggleFullscreen" then -- 1060
			toggleFullscreen() -- 1062
		elseif pauseAct.type == "quit" then -- 1062
			quitGame() -- 1064
		elseif pauseAct.type == "toTitle" then -- 1064
			saveCurrentSession() -- 1066
			refreshTitleSessionFlag() -- 1067
			fe.menus:resetInput() -- 1068
			fe.screen = "title" -- 1069
		end -- 1069
		return -- 1071
	end -- 1071
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1074
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1075
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and not p.talentModalActive then -- 1075
		input:consumeEdges() -- 1078
		if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1078
			p:restartEscortRun() -- 1081
			applyRoomTransition(p) -- 1082
		else -- 1082
			ensurePlay({checkpoint = p.checkpoint}) -- 1085
		end -- 1085
		return -- 1087
	end -- 1087
	local steps = clock:advance(frameDt) -- 1090
	local i = 0 -- 1091
	do -- 1091
		i = 0 -- 1092
		while i < steps do -- 1092
			input:beginStep(i == 0) -- 1093
			p:update(STEP, input) -- 1094
			input:endStep() -- 1095
			if p.wantRoom ~= "" then -- 1095
				break -- 1097
			end -- 1097
			i = i + 1 -- 1092
		end -- 1092
	end -- 1092
	if applyRoomTransition(p) then -- 1092
		return -- 1103
	end -- 1103
	flushProfile() -- 1107
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1107
		clearSession() -- 1109
		refreshTitleSessionFlag() -- 1110
	elseif p.sessionDirty then -- 1110
		saveCurrentSession() -- 1112
	end -- 1112
	fe:renderPlay( -- 1114
		frameDt, -- 1114
		p, -- 1114
		input, -- 1114
		stageVp.stageW, -- 1114
		stageVp.stageH -- 1114
	) -- 1114
end -- 1114
profile = emptySave() -- 27
local profileStatus = "missing" -- 28
local profileDetail = "" -- 29
current = 0 -- 30
viewW = 0 -- 31
viewH = 0 -- 32
clock = __TS__New(StepClock) -- 36
stageVp = computeStageViewport(1280, 720) -- 37
audioUnlocked = false -- 39
appClock = 0 -- 40
local lastBackPressClock = -10 -- 41
local function isReleaseBuild() -- 47
	return isReleaseMode() -- 48
end -- 47
local function handleBackButton() -- 94
	if fe == nil then -- 94
		return -- 96
	end -- 96
	if fe.screen == "splash" then -- 96
		fe.menus:resetSplash() -- 99
		fe.screen = "title" -- 100
		fe.menus:resetInput() -- 101
		return -- 102
	end -- 102
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "epilogue" or fe.screen == "history" then -- 102
		fe.menus:triggerBack() -- 105
		return -- 106
	end -- 106
	if fe.screen == "title" then -- 106
		if not canQuitApp() then -- 106
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 110
			return -- 111
		end -- 111
		if appClock - lastBackPressClock <= 2 then -- 111
			quitGame() -- 114
		else -- 114
			lastBackPressClock = appClock -- 116
			fe:showToast("再按一次返回退出游戏", 2) -- 117
		end -- 117
		return -- 119
	end -- 119
	if fe.screen == "play" and play ~= nil then -- 119
		if play.escortFailed then -- 119
			fe.audio:stopRoomTransient() -- 123
			fe.menus:resetInput() -- 124
			fe.screen = "title" -- 125
			if input ~= nil then -- 125
				input:clearTransient(true) -- 126
			end -- 126
			return -- 127
		end -- 127
		if fe.roguelikeUi:isLedgerOpen() then -- 127
			fe.roguelikeUi:closeLedger() -- 130
			return -- 131
		end -- 131
		if play.paused then -- 131
			fe.menus:triggerBack() -- 134
			return -- 135
		end -- 135
		if play.craftBench.active then -- 135
			play:closeCraftBench() -- 138
			return -- 139
		end -- 139
		play.paused = true -- 141
		play.aimHold = 0 -- 142
		play.bottleAimX = -1 -- 143
		saveCurrentSession() -- 144
		fe.menus:openPause() -- 145
		if input ~= nil then -- 145
			input:clearTransient(true) -- 146
		end -- 146
	end -- 146
end -- 94
function ____exports.start(parent, _initialMode, startScreen) -- 346
	if _initialMode == nil then -- 346
		_initialMode = 1 -- 346
	end -- 346
	if startScreen == nil then -- 346
		startScreen = "title" -- 346
	end -- 346
	root = parent -- 347
	local loaded = loadSave() -- 351
	profile = loaded.state -- 352
	profileStatus = loaded.status -- 353
	profileDetail = loaded.detail -- 354
	fe = __TS__New(WatchFrontend, parent) -- 355
	fe.screen = startScreen -- 356
	if startScreen == "splash" then -- 356
		fe.menus:resetSplash() -- 358
	end -- 358
	refreshTitleSessionFlag() -- 360
	fe:setVisible(true) -- 361
	input = __TS__New(Input) -- 363
	fe.audio:applyUserVolumes(input.settings) -- 364
	input:attach( -- 365
		parent, -- 365
		{ -- 365
			onFirstUserGesture = function() -- 366
				onFirstUserGesture() -- 367
				if input ~= nil then -- 367
					input:markKeyboardActivity() -- 368
				end -- 368
			end, -- 366
			onToggleFullscreen = function() -- 370
				toggleFullscreen() -- 371
			end, -- 370
			onKeyDownEvent = function(____, key) -- 373
				if (fe and fe.screen) == "play" and play ~= nil and not play.paused then -- 373
					if key == "1" or key == "2" or key == "3" then -- 373
						if input ~= nil then -- 373
							input:requestPickRoom(__TS__Number(key)) -- 376
						end -- 376
						return -- 377
					end -- 377
					if key == "T" and not play.escortFailed and not play.talentModalActive and not fe.roguelikeUi:isLedgerOpen() then -- 377
						play:toggleArtifactWeapon() -- 380
						return -- 381
					end -- 381
				end -- 381
				local inPausedPlay = fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 384
				if fe ~= nil and (fe.screen ~= "play" or inPausedPlay) then -- 384
					fe.menus:onKeyEvent(key) -- 386
				end -- 386
				if input ~= nil and (fe ~= nil and fe.screen == "play" and not inPausedPlay) then -- 386
					if key == "E" then -- 386
						input.interact.pressed = true -- 390
					elseif key == "Space" then -- 390
						input.jump.pressed = true -- 392
					elseif key == "Escape" then -- 392
						input.pause.pressed = true -- 394
					elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 394
						input.retry.pressed = true -- 396
					end -- 396
				end -- 396
			end -- 373
		} -- 373
	) -- 373
	parent:gslot( -- 403
		"AppEvent", -- 403
		function(eventType) -- 403
			if eventType == "BackButton" then -- 403
				handleBackButton() -- 405
				return -- 406
			end -- 406
			if eventType == "Quit" or eventType == "Shutdown" then -- 406
				flushProfile() -- 409
				saveCurrentSession() -- 410
				if input ~= nil then -- 410
					input:clearTransient(false) -- 411
				end -- 411
				return -- 412
			end -- 412
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 412
				flushProfile() -- 415
				saveCurrentSession() -- 416
				if input ~= nil then -- 416
					input:clearTransient(true) -- 417
				end -- 417
				if fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.escortFailed then -- 417
					play.paused = true -- 419
					play.aimHold = 0 -- 420
					play.bottleAimX = -1 -- 421
					fe.menus:openPause() -- 422
				end -- 422
				if fe ~= nil then -- 422
					fe.audio:setPaused(true) -- 425
				end -- 425
				return -- 427
			end -- 427
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 427
				if fe ~= nil then -- 427
					local paused = play ~= nil and play.paused and fe.screen == "play" -- 431
					fe.audio:setPaused(paused) -- 432
				end -- 432
			end -- 432
		end -- 403
	) -- 403
	viewW = View.size.width -- 437
	viewH = View.size.height -- 438
	applySize() -- 439
	local reg = _G.package.loaded -- 442
	reg["watch.input"] = input -- 443
	reg["watch.touch"] = input:getTouchRouter() -- 444
	reg["watch.gamepad"] = input:getGamepadRouter() -- 445
	reg["watch.fe"] = { -- 446
		setScreen = function(sc) -- 447
			if fe == nil then -- 447
				return -- 449
			end -- 449
			clock:reset() -- 451
			fe.screen = sc -- 452
			if sc == "splash" then -- 452
				fe.menus:resetSplash() -- 454
			elseif sc == "chapters" then -- 454
				fe.menus:openChapters() -- 456
			elseif sc == "epilogue" then -- 456
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 458
			elseif sc == "history" then -- 458
				fe.menus:openHistory(false) -- 463
			else -- 463
				fe.menus:resetInput() -- 465
			end -- 465
			if sc == "play" then -- 465
				ensurePlay() -- 468
			end -- 468
		end, -- 447
		jumpRoom = function(keyOrIdx) -- 471
			local idx = -1 -- 472
			if type(keyOrIdx) == "number" then -- 472
				idx = keyOrIdx -- 474
			else -- 474
				local k = 0 -- 476
				do -- 476
					k = 0 -- 477
					while k < #ROOMS do -- 477
						if ROOMS[k + 1].key == keyOrIdx then -- 477
							idx = k -- 479
						end -- 479
						k = k + 1 -- 477
					end -- 477
				end -- 477
			end -- 477
			if idx >= 0 and idx < #ROOMS then -- 477
				enterPlayRoom(idx, "debug") -- 484
			end -- 484
		end, -- 471
		getPlay = function() return play end, -- 487
		getFrontend = function() return fe end, -- 488
		startStory = function(seed) -- 490
			enterPlayRoom( -- 491
				officialStartIndex(), -- 491
				"official", -- 491
				true, -- 491
				seed -- 491
			) -- 491
			return play -- 492
		end, -- 490
		previewChapter = function(idx, routeOrSeed, seed) -- 495
			enterPlayRoom( -- 496
				idx, -- 496
				"chapter", -- 496
				false, -- 496
				type(routeOrSeed) == "number" and routeOrSeed or seed, -- 496
				type(routeOrSeed) == "string" and routeOrSeed or nil -- 497
			) -- 497
			return play -- 498
		end, -- 495
		getStoryRun = function() return storyRun end, -- 500
		getProfilePending = function() return profilePending() end, -- 501
		flushProfileNow = function() return flushProfile() end, -- 502
		getProfile = function() return profile end, -- 504
		getProfileStatus = function() return profileStatus end, -- 505
		getProfileDetail = function() return profileDetail end, -- 506
		useTestSave = function(name) -- 507
			setSaveFile(name) -- 508
			setSessionFile(name == "" and "" or name .. ".session") -- 509
			clearProfilePending() -- 510
			local loaded = loadSave() -- 511
			profile = loaded.state -- 512
			profileStatus = loaded.status -- 513
			profileDetail = loaded.detail -- 514
			refreshTitleSessionFlag() -- 515
		end, -- 507
		useTestSession = function(name) -- 517
			setSessionFile(name) -- 518
			refreshTitleSessionFlag() -- 519
		end, -- 517
		getSessionFile = getSessionFile, -- 521
		hasSessionSave = hasSessionSave, -- 522
		saveSessionNow = function() return saveCurrentSession() end, -- 523
		clearSessionNow = function() -- 524
			local ok = clearSession() -- 525
			refreshTitleSessionFlag() -- 526
			return ok -- 527
		end, -- 524
		continueStory = function() return continueOfficialStory() end, -- 529
		saveNow = function() return saveSave(profile) end, -- 530
		getSaveFile = getSaveFile, -- 531
		isRelease = function() return isReleaseBuild() end, -- 532
		getReleaseVersion = function() -- 533
			local ____opt_25 = getReleaseConfig() -- 533
			return ____opt_25 and ____opt_25.version or "dev" -- 533
		end, -- 533
		toggleFullscreen = function() return toggleFullscreen() end, -- 534
		quitGame = function() return quitGame() end, -- 535
		handleBackButton = function() return handleBackButton() end, -- 536
		getViewport = function() return stageVp end, -- 537
		getTargetId = function() return getActiveTarget().id end, -- 538
		getTouchController = function() return input and input:getTouchControls() end, -- 539
		getTouchRouter = function() return input and input:getTouchRouter() end, -- 540
		getGamepad = function() return input and input:getGamepadRouter() end, -- 541
		setGamepadSim = function(state) -- 542
			if input ~= nil then -- 542
				input:setGamepadSim(state) -- 543
			end -- 543
		end, -- 542
		injectTouch = function(phase, id, x, y, fromMouse) -- 545
			if input ~= nil then -- 545
				input:injectTouch( -- 546
					phase, -- 546
					id, -- 546
					x, -- 546
					y, -- 546
					fromMouse -- 546
				) -- 546
			end -- 546
		end, -- 545
		getInputMode = function() return input and input.inputMode or getActiveTarget().defaultInputMode end, -- 548
		setInputMode = function(m) -- 549
			if input ~= nil then -- 549
				input:setInputMode(m) -- 550
			end -- 550
		end, -- 549
		setModePref = function(pref) -- 552
			if input ~= nil then -- 552
				input:setModePref(pref) -- 553
			end -- 553
		end, -- 552
		applyViewportForTest = function(w, h) -- 555
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 555
				testViewportOverride = {w = w, h = h} -- 557
				viewW = w -- 558
				viewH = h -- 559
			else -- 559
				testViewportOverride = nil -- 561
				viewW = View.size.width -- 562
				viewH = View.size.height -- 563
			end -- 563
			applySize() -- 565
			return stageVp -- 566
		end, -- 555
		getToast = function() return fe and fe:getToastText() or "" end -- 568
	} -- 568
	if startScreen == "play" then -- 568
		ensurePlay() -- 572
	end -- 572
	parent:schedule(function(frameDt) -- 575
		tick(frameDt) -- 576
		return false -- 577
	end) -- 575
end -- 346
return ____exports -- 346