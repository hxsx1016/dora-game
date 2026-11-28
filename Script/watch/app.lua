-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local ____exports = {} -- 1
local randomRunSeed, syncPowerMode, onFirstUserGesture, toggleFullscreen, slotDisplayName, quitGame, canSaveSession, refreshTitleSessionFlag, exportSessionWithMeta, sessionMilestoneSignature, saveCurrentSession, saveToManualSlot, deleteSaveSlotById, continueOfficialStory, loadOfficialSlot, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, applyRoomTransition, tickFrontend, root, storyRun, profile, profileStatus, current, viewW, viewH, input, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock, runPlaySeconds, autosaveTimer, autosaveCooldown, lastAutosaveSig, windowFocused, lastAppliedIdle, pendingWinSizeSaveTimer, startupNoticeShown -- 1
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
local ____controls_config = require("Script.watch.controls_config") -- 7
local saveControlSettings = ____controls_config.saveControlSettings -- 7
local ____platform = require("Script.watch.platform") -- 8
local canQuitApp = ____platform.canQuitApp -- 10
local canToggleFullscreen = ____platform.canToggleFullscreen -- 11
local computeStageViewport = ____platform.computeStageViewport -- 12
local getReleaseConfig = ____platform.getReleaseConfig -- 13
local isDesktopNative = ____platform.isDesktopNative -- 14
local isReleaseMode = ____platform.isReleaseMode -- 15
local ____frontend = require("Script.watch.fe.frontend") -- 17
local WatchFrontend = ____frontend.WatchFrontend -- 17
local ____run = require("Script.watch.run") -- 18
local createRun = ____run.createRun -- 18
local createStoryTalents = ____run.createStoryTalents -- 18
local normalizeLegacyTalent = ____run.normalizeLegacyTalent -- 18
local ____save = require("Script.watch.save") -- 19
local emptySave = ____save.emptySave -- 20
local loadSave = ____save.loadSave -- 20
local saveSave = ____save.saveSave -- 20
local setSaveFile = ____save.setSaveFile -- 20
local getSaveFile = ____save.getSaveFile -- 20
local markProfilePending = ____save.markProfilePending -- 21
local flushSaveProfile = ____save.flushProfile -- 21
local clearProfilePending = ____save.clearProfilePending -- 21
local profilePending = ____save.profilePending -- 21
local loadSession = ____save.loadSession -- 22
local saveSession = ____save.saveSession -- 22
local clearSession = ____save.clearSession -- 22
local hasSessionSave = ____save.hasSessionSave -- 22
local setSessionFile = ____save.setSessionFile -- 22
local getSessionFile = ____save.getSessionFile -- 22
local listSaveSlots = ____save.listSaveSlots -- 23
local loadSlot = ____save.loadSlot -- 23
local saveSlot = ____save.saveSlot -- 23
local deleteSlot = ____save.deleteSlot -- 23
local nowUnixSeconds = ____save.nowUnixSeconds -- 23
function randomRunSeed() -- 58
	return math.max( -- 59
		1, -- 59
		math.floor(math.abs(App.rand)) % 2147483646 -- 59
	) -- 59
end -- 59
function syncPowerMode() -- 66
	if not isDesktopNative() then -- 66
		return -- 68
	end -- 68
	local wantIdle = not windowFocused -- 71
	if lastAppliedIdle == wantIdle then -- 71
		return -- 73
	end -- 73
	lastAppliedIdle = wantIdle -- 75
	do -- 75
		pcall(function() -- 75
			App.idled = wantIdle -- 77
		end) -- 77
	end -- 77
end -- 77
function onFirstUserGesture() -- 83
	if audioUnlocked or fe == nil then -- 83
		return -- 85
	end -- 85
	audioUnlocked = true -- 87
	fe.audio:unlockAndResyncAfterGesture() -- 88
end -- 88
function toggleFullscreen() -- 91
	if not canToggleFullscreen() then -- 91
		return false -- 93
	end -- 93
	do -- 93
		local function ____catch() -- 93
			return true, false -- 104
		end -- 104
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 104
			local next = not App.fullScreen -- 96
			App.fullScreen = next -- 97
			if input ~= nil then -- 97
				input.settings.fullscreen = next -- 99
				saveControlSettings(input.settings) -- 100
			end -- 100
			return true, next -- 102
		end) -- 102
		if not ____try then -- 102
			____hasReturned, ____returnValue = ____catch() -- 102
		end -- 102
		if ____hasReturned then -- 102
			return ____returnValue -- 95
		end -- 95
	end -- 95
end -- 95
function slotDisplayName(slot) -- 108
	if slot == "auto" then -- 108
		return "自动存档" -- 109
	end -- 109
	if slot == 1 then -- 109
		return "档案一" -- 110
	end -- 110
	if slot == 2 then -- 110
		return "档案二" -- 111
	end -- 111
	return "档案三" -- 112
end -- 112
function quitGame() -- 115
	flushProfile() -- 116
	saveCurrentSession() -- 117
	if input ~= nil and isDesktopNative() then -- 117
		do -- 117
			pcall(function() -- 117
				input.settings.fullscreen = App.fullScreen -- 120
				if not App.fullScreen then -- 120
					local ws = App.winSize -- 122
					if ws.width >= 640 and ws.height >= 360 then -- 122
						input.settings.winWidth = math.floor(ws.width + 0.5) -- 124
						input.settings.winHeight = math.floor(ws.height + 0.5) -- 125
					end -- 125
				end -- 125
				saveControlSettings(input.settings) -- 128
			end) -- 128
		end -- 128
	end -- 128
	if input ~= nil then -- 128
		input:clearTransient(false) -- 133
	end -- 133
	if fe ~= nil then -- 133
		fe.audio:stopRoomTransient() -- 135
	end -- 135
	if not canQuitApp() then -- 135
		current = 0 -- 139
		play = nil -- 140
		clock:reset() -- 141
		if fe ~= nil then -- 141
			fe.audio:stopRoomTransient() -- 143
			fe.screen = "title" -- 144
			fe.menus:resetInput() -- 145
		end -- 145
		return -- 147
	end -- 147
	App:shutdown() -- 149
end -- 149
function canSaveSession() -- 275
	if play == nil or storyRun == nil then -- 275
		return false -- 277
	end -- 277
	if storyRun.source ~= "official" or play.run.finished then -- 277
		return false -- 280
	end -- 280
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 280
		return false -- 283
	end -- 283
	return true -- 285
end -- 285
function refreshTitleSessionFlag() -- 288
	if fe ~= nil then -- 288
		local has = hasSessionSave() -- 290
		fe.menus.hasSession = has -- 291
		if has then -- 291
			local loaded = loadSession() -- 293
			fe.menus:setSessionRoomKey(loaded.status == "ok" and loaded.state ~= nil and loaded.state.roomKey or "") -- 294
		else -- 294
			fe.menus:setSessionRoomKey("") -- 296
		end -- 296
		fe.menus:refreshSaveSlots() -- 298
	end -- 298
end -- 298
function exportSessionWithMeta() -- 302
	if play == nil then -- 302
		return nil -- 304
	end -- 304
	local snap = play:exportSession() -- 306
	snap.savedAt = nowUnixSeconds() -- 307
	snap.playSeconds = math.max( -- 308
		0, -- 308
		math.floor(runPlaySeconds) -- 308
	) -- 308
	return snap -- 309
end -- 309
function sessionMilestoneSignature(p) -- 312
	local inv = p.run.inventory -- 313
	local takenCount = 0 -- 314
	for k in pairs(p.run.taken) do -- 315
		if p.run.taken[k] == true then -- 315
			takenCount = takenCount + 1 -- 316
		end -- 316
	end -- 316
	local segCount = 0 -- 318
	for k in pairs(p.run.story.segments) do -- 319
		if p.run.story.segments[k] == true then -- 319
			segCount = segCount + 1 -- 320
		end -- 320
	end -- 320
	return (((((((((((((((((((((((((((((p.room.key .. "|") .. tostring(p.checkpoint)) .. "|") .. p.phase) .. "|") .. tostring(p.run.story.hp)) .. "|") .. p.run.story.route) .. "|") .. tostring(inv.wood)) .. ":") .. tostring(inv.bell)) .. ":") .. tostring(inv.scrap)) .. ":") .. tostring(inv.wedge)) .. ":") .. tostring(inv.ammo)) .. "|") .. tostring(takenCount)) .. ":") .. tostring(segCount)) .. "|") .. (p.cartDocked and "1" or "0")) .. "|") .. (p.hasBottle and "1" or "0")) .. "|") .. (p.passed and "1" or "0")) .. "|") .. p.equippedWeapon -- 322
end -- 322
function saveCurrentSession() -- 335
	if not canSaveSession() or play == nil then -- 335
		return false -- 337
	end -- 337
	local snap = exportSessionWithMeta() -- 339
	if snap == nil then -- 339
		return false -- 341
	end -- 341
	local ok = saveSession(snap) -- 343
	play.sessionDirty = not ok -- 344
	if ok then -- 344
		autosaveTimer = 0 -- 346
		autosaveCooldown = 2.5 -- 347
		lastAutosaveSig = sessionMilestoneSignature(play) -- 348
	end -- 348
	refreshTitleSessionFlag() -- 350
	return ok -- 351
end -- 351
function saveToManualSlot(slot) -- 354
	if not canSaveSession() or play == nil then -- 354
		if fe ~= nil then -- 354
			fe:showToast("当前段落无法手动存档", 2) -- 356
		end -- 356
		return false -- 357
	end -- 357
	local snap = exportSessionWithMeta() -- 359
	if snap == nil then -- 359
		return false -- 361
	end -- 361
	local ok = saveSlot(slot, snap) -- 363
	refreshTitleSessionFlag() -- 364
	if ok then -- 364
		if fe ~= nil then -- 364
			fe:showToast( -- 366
				"已保存至" .. slotDisplayName(slot), -- 366
				2 -- 366
			) -- 366
		end -- 366
	else -- 366
		if fe ~= nil then -- 366
			fe:showToast("保存失败，请检查目录写权限", 2.4) -- 368
		end -- 368
	end -- 368
	return ok -- 370
end -- 370
function deleteSaveSlotById(slot) -- 373
	local ok = deleteSlot(slot) -- 374
	refreshTitleSessionFlag() -- 375
	if fe ~= nil then -- 375
		fe:showToast( -- 376
			ok and "已删除" .. slotDisplayName(slot) or "删除存档失败", -- 376
			2 -- 376
		) -- 376
	end -- 376
	return ok -- 377
end -- 377
function continueOfficialStory() -- 380
	return loadOfficialSlot("auto") -- 381
end -- 381
function loadOfficialSlot(slot) -- 384
	if slot == "auto" and (play and play.escortFailed) and play.run.source == "official" and play.sessionDirty then -- 384
		play:confirmEscortRestart() -- 387
		applyRoomTransition(play) -- 388
		if fe ~= nil then -- 388
			fe.screen = "play" -- 389
		end -- 389
		return play -- 390
	end -- 390
	local res = loadSlot(slot) -- 392
	if res.status ~= "ok" or res.state == nil then -- 392
		refreshTitleSessionFlag() -- 394
		return nil -- 395
	end -- 395
	local s = res.state -- 397
	local idx = roomIndexByKey(s.roomKey) -- 398
	if ROOMS[idx + 1].key ~= s.roomKey then -- 398
		return nil -- 400
	end -- 400
	runPlaySeconds = math.max(0, s.playSeconds or 0) -- 402
	autosaveTimer = 0 -- 403
	autosaveCooldown = 2.5 -- 404
	lastAutosaveSig = "" -- 405
	storyRun = createRun(s.seed, "official", profile) -- 406
	storyRun.checkpoint = s.checkpoint -- 407
	storyRun.story.route = s.route -- 408
	storyRun.story.hp = s.hp -- 409
	storyRun.story.maxHp = s.maxHp -- 410
	storyRun.story.hpAtGate = s.hpAtGate -- 411
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 412
	storyRun.story.settled = s.settled -- 413
	storyRun.story.phase = s.phase -- 414
	storyRun.story.countTick = s.countTick -- 415
	storyRun.story.phaseTick = s.phaseTick -- 416
	storyRun.story.handTicks = s.handTicks -- 417
	storyRun.story.handDone = s.handDone -- 418
	storyRun.story.lineSaid = s.lineSaid -- 419
	storyRun.story.tied = s.tied -- 420
	storyRun.story.carry = s.carry -- 421
	storyRun.story.escortDone = s.escortDone -- 422
	storyRun.story.craftedWeapon = s.craftedWeapon -- 423
	storyRun.story.equippedWeapon = s.equippedWeapon -- 424
	storyRun.inventory.wood = s.wood -- 425
	storyRun.inventory.bell = s.bell -- 426
	storyRun.inventory.scrap = s.scrap -- 427
	storyRun.inventory.wedge = s.wedge -- 428
	storyRun.inventory.ammo = s.ammo -- 429
	storyRun.inventory.shield = s.shield -- 430
	storyRun.inventory.pass = s.pass -- 431
	storyRun.inventory.quickbelt = s.quickbelt -- 432
	local k = 0 -- 433
	do -- 433
		k = 0 -- 434
		while k < #s.taken do -- 434
			storyRun.taken[s.taken[k + 1]] = true -- 435
			k = k + 1 -- 434
		end -- 434
	end -- 434
	do -- 434
		k = 0 -- 437
		while k < #s.segments do -- 437
			storyRun.story.segments[s.segments[k + 1]] = true -- 438
			k = k + 1 -- 437
		end -- 437
	end -- 437
	if s.campaignRoute ~= nil then -- 437
		storyRun.route = s.campaignRoute -- 441
	end -- 441
	if s.joined ~= nil then -- 441
		storyRun.joined = s.joined -- 444
	end -- 444
	if s.c1Latch ~= nil then -- 444
		storyRun.c1Latch = s.c1Latch -- 447
	end -- 447
	if s.c2Latch ~= nil then -- 447
		storyRun.c2Latch = s.c2Latch -- 450
	end -- 450
	if s.props ~= nil then -- 450
		do -- 450
			k = 0 -- 453
			while k < #s.props do -- 453
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 454
				local pid = parts[1] -- 455
				if pid ~= nil and pid ~= "" then -- 455
					local ____storyRun_props_22 = storyRun.props -- 457
					local ____temp_18 -- 458
					if parts[2] == nil then -- 458
						____temp_18 = true -- 458
					else -- 458
						____temp_18 = parts[2] == "1" -- 458
					end -- 458
					local ____temp_20 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 459
					local ____temp_21 = parts[4] == "1" -- 460
					local ____temp_19 -- 461
					if parts[5] == "1" then -- 461
						____temp_19 = true -- 461
					else -- 461
						____temp_19 = nil -- 461
					end -- 461
					____storyRun_props_22[pid] = {broken = ____temp_18, hp = ____temp_20, wedge = ____temp_21, revealed = ____temp_19} -- 457
				end -- 457
				k = k + 1 -- 453
			end -- 453
		end -- 453
	end -- 453
	local stTalents = createStoryTalents(s.seed) -- 466
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 466
		stTalents.randomState = s.talentSeed -- 468
	end -- 468
	if s.escortAttempt ~= nil and s.escortAttempt >= 1 then -- 468
		stTalents.attempt = s.escortAttempt -- 471
	end -- 471
	if s.escortVariant ~= nil and s.escortVariant >= 0 then -- 471
		stTalents.variant = s.escortVariant -- 474
	end -- 474
	stTalents.deferred = s.talentDeferred == true -- 476
	stTalents.room = s.talentRoom or "" -- 477
	if s.talentRanks ~= nil and #s.talentRanks > 0 then -- 477
		do -- 477
			k = 0 -- 479
			while k < #s.talentRanks do -- 479
				local parts = __TS__StringSplit(s.talentRanks[k + 1], ":") -- 480
				local ____temp_23 -- 481
				if parts[1] ~= nil then -- 481
					____temp_23 = normalizeLegacyTalent(parts[1]) -- 481
				else -- 481
					____temp_23 = nil -- 481
				end -- 481
				local norm = ____temp_23 -- 481
				local rk = parts[2] ~= nil and (tonumber(parts[2]) or 0) or 0 -- 482
				if norm ~= nil and rk > 0 then -- 482
					stTalents.ranks[norm] = (stTalents.ranks[norm] or 0) + math.floor(rk) -- 484
				end -- 484
				k = k + 1 -- 479
			end -- 479
		end -- 479
	else -- 479
		stTalents.ranks.vitality = s.talentVitality or 0 -- 489
		stTalents.ranks.focus = s.talentReload or 0 -- 490
		stTalents.ranks.guard = s.talentGuard or 0 -- 491
		stTalents.ranks.salvage = s.talentCraft or 0 -- 492
	end -- 492
	if s.talentOffers ~= nil then -- 492
		do -- 492
			k = 0 -- 495
			while k < #s.talentOffers do -- 495
				local norm = normalizeLegacyTalent(s.talentOffers[k + 1]) -- 496
				if norm ~= nil then -- 496
					local ____stTalents_offers_24 = stTalents.offers -- 496
					____stTalents_offers_24[#____stTalents_offers_24 + 1] = norm -- 498
				end -- 498
				k = k + 1 -- 495
			end -- 495
		end -- 495
	end -- 495
	storyRun.story.talents = stTalents -- 502
	current = idx -- 503
	clock:reset() -- 504
	if fe ~= nil then -- 504
		fe.screen = "play" -- 506
	end -- 506
	play = nil -- 508
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 509
	local cur = play -- 510
	if cur ~= nil then -- 510
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 510
			cur.cartAxle = s.cartAxle -- 513
			cur.cartDocked = s.cartDocked -- 514
		end -- 514
		if s.playerX ~= nil and s.playerX >= 0 then -- 514
			cur.player.x = math.max( -- 517
				cur.room.minX + 16, -- 517
				math.min(cur.room.maxX - 16, s.playerX) -- 517
			) -- 517
			cur.player.y = math.max(0, s.playerY or 0) -- 518
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 518
				cur.player.depth = math.max( -- 520
					cur.room.depth.min, -- 520
					math.min(cur.room.depth.max, s.playerDepth) -- 520
				) -- 520
			end -- 520
		end -- 520
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 520
			cur.gateTick = s.gateTick -- 524
		end -- 524
		if cur.room.key == "village" then -- 524
			if s.hasBottle == true then -- 524
				cur.hasBottle = true -- 527
			end -- 527
			if s.villagePassed == true then -- 527
				cur.passed = true -- 528
			end -- 528
		end -- 528
		if cur.room.key == "prologue" and (s.phase == "" or s.phase == "prologue-wake" or s.phase == "prologue-shadow" or s.phase == "prologue-escape" or s.phase == "prologue-hide") then -- 528
			cur.phase = "prologue-wake" -- 537
		end -- 537
		if (string.find(cur.room.key, "escort", nil, true) or 0) - 1 == 0 and s.route == "soldier" and not cur.craftBench.active and not cur.carryOn then -- 537
			cur.carryOn = true -- 541
			storyRun.story.carry = true -- 542
		end -- 542
	end -- 542
	return play -- 545
end -- 545
function flushProfile() -- 844
	local cur = play -- 845
	if cur ~= nil and cur.archiveDirty then -- 845
		cur.archiveDirty = false -- 847
		markProfilePending(profile) -- 848
	end -- 848
	local ok = flushSaveProfile() -- 850
	if not ok and cur ~= nil then -- 850
		cur.archiveDirty = true -- 852
	end -- 852
	return ok -- 854
end -- 854
function officialStartIndex() -- 858
	local mp = profile.museumPhase -- 859
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 860
	return inMuseum and roomIndexByKey("museum") or 0 -- 861
end -- 861
function roomIndexByKey(key) -- 864
	local i = 0 -- 865
	do -- 865
		i = 0 -- 866
		while i < #ROOMS do -- 866
			if ROOMS[i + 1].key == key then -- 866
				return i -- 868
			end -- 868
			i = i + 1 -- 866
		end -- 866
	end -- 866
	return 0 -- 871
end -- 871
function ____exports.applyChapterPreviewRoute(targetRun, roomKey, routeOverride) -- 874
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" and routeOverride ~= "soldier" then -- 874
		targetRun.story.route = "child" -- 879
		targetRun.story.settled = true -- 880
		targetRun.story.countTick = 1440 -- 881
	elseif roomKey == "gatepath" or (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 or roomKey == "tower" and routeOverride == "soldier" then -- 881
		targetRun.story.route = "soldier" -- 884
		targetRun.story.settled = true -- 885
		targetRun.joined = true -- 886
		targetRun.story.handDone = true -- 887
		targetRun.story.tied = true -- 888
		local ____targetRun_story_55 = targetRun.story -- 889
		targetRun.story.maxHpAtGate = 3 -- 889
		____targetRun_story_55.hpAtGate = 3 -- 889
		if (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 then -- 889
			targetRun.story.carry = true -- 891
		end -- 891
		if roomKey == "escort4" or roomKey == "escort5" then -- 891
			targetRun.inventory.wood = 2 -- 894
			targetRun.inventory.bell = 1 -- 895
		end -- 895
		if roomKey == "escort3" then -- 895
			targetRun.inventory.wood = math.max(targetRun.inventory.wood, 2) -- 898
			targetRun.inventory.scrap = math.max(targetRun.inventory.scrap, 2) -- 899
			targetRun.inventory.bell = math.max(targetRun.inventory.bell, 1) -- 900
			targetRun.inventory.wedge = math.max(targetRun.inventory.wedge, 1) -- 901
		end -- 901
	end -- 901
end -- 874
function enterPlayRoom(idx, source, fresh, seedOverride, chapterRoute) -- 906
	if source == nil then -- 906
		source = "debug" -- 906
	end -- 906
	if fresh == nil then -- 906
		fresh = false -- 906
	end -- 906
	current = idx -- 907
	clock:reset() -- 908
	if fe ~= nil then -- 908
		fe.screen = "play" -- 910
	end -- 910
	play = nil -- 912
	if fresh or source == "chapter" or storyRun == nil then -- 912
		storyRun = createRun( -- 915
			seedOverride or (source == "debug" and 20261124 or randomRunSeed()), -- 915
			source, -- 915
			profile -- 915
		) -- 915
		if fresh or source == "official" then -- 915
			runPlaySeconds = 0 -- 917
			autosaveTimer = 0 -- 918
			lastAutosaveSig = "" -- 919
		end -- 919
		if source == "chapter" then -- 919
			local targetKey = ROOMS[current + 1] ~= nil and ROOMS[current + 1].key or "" -- 922
			____exports.applyChapterPreviewRoute(storyRun, targetKey, chapterRoute) -- 923
		end -- 923
	else -- 923
		storyRun.source = source -- 926
	end -- 926
	ensurePlay() -- 928
	local firstPlay = play -- 930
	if firstPlay ~= nil and ROOMS[current + 1].key == "prologue" and (fresh and source == "official" or source == "chapter") then -- 930
		firstPlay.phase = "prologue-wake" -- 933
	end -- 933
	flushProfile() -- 935
end -- 935
function applySize() -- 938
	if root == nil then -- 938
		return -- 940
	end -- 940
	root.size = Size(viewW, viewH) -- 942
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 943
	stageVp = computeStageViewport(viewW, viewH) -- 944
	if input ~= nil then -- 944
		input:setStageViewport(stageVp) -- 946
	end -- 946
	if fe ~= nil then -- 946
		fe:setStagePlacement(stageVp) -- 949
	end -- 949
end -- 949
function syncFrameAdapters(frameDt) -- 953
	if input == nil then -- 953
		return -- 955
	end -- 955
	local target = input.target -- 957
	if not target.supportsTouch and not target.supportsGamepad then -- 957
		return -- 959
	end -- 959
	local p = play -- 961
	local isPlayMode = fe ~= nil and fe.screen == "play" and p ~= nil -- 962
	local storyTalentBoxes = target.supportsTouch and isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 963
		p, -- 965
		stageVp.stageW, -- 965
		stageVp.stageH, -- 965
		input:isTouchMode() -- 965
	) or ({}) -- 965
	local isFs = false -- 968
	if target:canToggleFullscreen() then -- 968
		do -- 968
			local function ____catch() -- 968
				isFs = false -- 973
			end -- 973
			local ____try = pcall(function() -- 973
				isFs = App.fullScreen -- 971
			end) -- 971
			if not ____try then -- 971
				____catch() -- 971
			end -- 971
		end -- 971
	end -- 971
	local ____input_74 = input -- 976
	local ____input_syncFrame_75 = input.syncFrame -- 976
	local ____stageVp_67 = stageVp -- 977
	local ____temp_68 = fe ~= nil and fe.screen or "title" -- 979
	local ____storyRun_69 = storyRun -- 981
	local ____isPlayMode_58 -- 982
	if isPlayMode then -- 982
		____isPlayMode_58 = fe and fe.cam -- 982
	else -- 982
		____isPlayMode_58 = nil -- 982
	end -- 982
	local ____input_70 = input -- 983
	local ____temp_59 -- 984
	if fe ~= nil then -- 984
		____temp_59 = fe.contract:isAssistHintsEnabled() -- 984
	else -- 984
		____temp_59 = true -- 984
	end -- 984
	local ____temp_60 -- 985
	if fe ~= nil then -- 985
		____temp_60 = fe.audio:isAllMuted() -- 985
	else -- 985
		____temp_60 = false -- 985
	end -- 985
	local ____isFs_71 = isFs -- 986
	local ____storyTalentBoxes_72 = storyTalentBoxes -- 987
	local ____temp_61 -- 988
	if p and fe then -- 988
		____temp_61 = fe:getEscortDeathBoxes(p, stageVp.stageW, stageVp.stageH) -- 988
	else -- 988
		____temp_61 = nil -- 988
	end -- 988
	local ____temp_73 = fe and fe.roguelikeUi:getLedgerButtonRect() -- 989
	local ____temp_66 = fe and fe.roguelikeUi:isLedgerOpen() -- 990
	if ____temp_66 == nil then -- 990
		____temp_66 = false -- 990
	end -- 990
	____input_syncFrame_75(____input_74, { -- 976
		viewport = ____stageVp_67, -- 977
		mode = 1, -- 978
		screen = ____temp_68, -- 979
		play = p, -- 980
		run = ____storyRun_69, -- 981
		cam = ____isPlayMode_58, -- 982
		input = ____input_70, -- 983
		assistHintsEnabled = ____temp_59, -- 984
		isMuted = ____temp_60, -- 985
		isFullscreen = ____isFs_71, -- 986
		storyTalentBoxes = ____storyTalentBoxes_72, -- 987
		escortDeathBoxes = ____temp_61, -- 988
		ledgerBox = ____temp_73, -- 989
		ledgerOpen = ____temp_66, -- 990
		dt = frameDt -- 991
	}) -- 991
end -- 991
function renderTouchOverlay() -- 995
	if input ~= nil then -- 995
		input:renderOverlay() -- 996
	end -- 996
end -- 996
function tick(frameDt) -- 999
	appClock = appClock + math.min( -- 1000
		0.05, -- 1000
		math.max(0, frameDt) -- 1000
	) -- 1000
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 1001
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 1002
	if w ~= viewW or h ~= viewH then -- 1002
		viewW = w -- 1004
		viewH = h -- 1005
		applySize() -- 1006
	end -- 1006
	if input == nil then -- 1006
		return -- 1009
	end -- 1009
	syncFrameAdapters(frameDt) -- 1011
	input:update(frameDt) -- 1012
	if input.userInteracted then -- 1012
		onFirstUserGesture() -- 1015
	end -- 1015
	if pendingWinSizeSaveTimer > 0 then -- 1015
		pendingWinSizeSaveTimer = pendingWinSizeSaveTimer - frameDt -- 1018
		if pendingWinSizeSaveTimer <= 0 and isDesktopNative() then -- 1018
			do -- 1018
				pcall(function() -- 1018
					if not App.fullScreen then -- 1018
						local ws = App.winSize -- 1022
						if ws.width >= 640 and ws.height >= 360 then -- 1022
							input.settings.winWidth = math.floor(ws.width + 0.5) -- 1024
							input.settings.winHeight = math.floor(ws.height + 0.5) -- 1025
							saveControlSettings(input.settings) -- 1026
						end -- 1026
					end -- 1026
				end) -- 1026
			end -- 1026
		end -- 1026
	end -- 1026
	if input.muteTogglePressed and fe ~= nil then -- 1026
		input.muteTogglePressed = false -- 1035
		local muted = fe.audio:toggleAllMuted() -- 1036
		input.settings.muted = muted -- 1037
		saveControlSettings(input.settings) -- 1038
	end -- 1038
	if input.fullscreenTogglePressed then -- 1038
		input.fullscreenTogglePressed = false -- 1041
		toggleFullscreen() -- 1042
	end -- 1042
	syncPowerMode() -- 1044
	if not startupNoticeShown and fe ~= nil and fe.screen == "title" then -- 1044
		startupNoticeShown = true -- 1046
		local rel = getReleaseConfig() -- 1047
		if rel ~= nil and rel.saveFallbackReason == "readonly" then -- 1047
			fe:showToast("游戏目录不可写，存档已自动回退至用户目录", 4.5) -- 1049
		elseif rel ~= nil and rel.migratedFrom ~= nil and rel.migratedFrom ~= "" then -- 1049
			fe:showToast("已自动迁移旧存档至 saves 目录", 3.5) -- 1051
		elseif profileStatus == "corrupt" or profileStatus == "unsupported" then -- 1051
			fe:showToast("主档案异常，原件已备份至 backups 目录", 4.5) -- 1053
		end -- 1053
	end -- 1053
	if input.artifactTogglePressed then -- 1053
		input.artifactTogglePressed = false -- 1057
		if (fe and fe.screen) == "play" and play ~= nil and not play.paused and not play.escortFailed and not play.talentModalActive and not fe.roguelikeUi:isLedgerOpen() then -- 1057
			play:toggleArtifactWeapon() -- 1060
		end -- 1060
	end -- 1060
	if input.bottleCanceled and play ~= nil then -- 1060
		input.bottleCanceled = false -- 1064
		play.aimHold = 0 -- 1065
		play.bottleAimX = -1 -- 1066
	end -- 1066
	if fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and not play.escortFailed and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 1066
		if fe:canPickStoryTalent(play) then -- 1066
			play:chooseTalent(input.pickRoom - 1) -- 1073
		end -- 1073
	end -- 1073
	input.pickRoom = 0 -- 1076
	tickFrontend(frameDt) -- 1077
	renderTouchOverlay() -- 1078
end -- 1078
function registerPlay() -- 1082
	local reg = _G.package.loaded -- 1083
	reg["watch.play"] = play -- 1084
	reg["watch.room"] = ROOMS[current + 1].key -- 1085
end -- 1085
function ensurePlay(resume) -- 1089
	if storyRun == nil then -- 1089
		storyRun = createRun(20261124, "debug", profile) -- 1093
	end -- 1093
	play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1095
	registerPlay() -- 1096
	clock:reset() -- 1097
	if fe ~= nil then -- 1097
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1099
	end -- 1099
end -- 1099
function applyRoomTransition(p) -- 1104
	if p.wantRoom == "" then -- 1104
		return false -- 1106
	end -- 1106
	local key = p.wantRoom -- 1108
	p.wantRoom = "" -- 1109
	local idx = -1 -- 1110
	local j = 0 -- 1111
	do -- 1111
		j = 0 -- 1112
		while j < #ROOMS do -- 1112
			if ROOMS[j + 1].key == key then -- 1112
				idx = j -- 1114
			end -- 1114
			j = j + 1 -- 1112
		end -- 1112
	end -- 1112
	if idx < 0 then -- 1112
		return false -- 1118
	end -- 1118
	flushProfile() -- 1123
	local leaving = p:drainEvents() -- 1124
	if p.restartStory then -- 1124
		if storyRun ~= nil and storyRun.source == "official" then -- 1124
			clearSession() -- 1128
			refreshTitleSessionFlag() -- 1129
		end -- 1129
		local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1131
		local nextSeed = nextSource == "official" and randomRunSeed() or 20261124 -- 1132
		storyRun = createRun(nextSeed, nextSource, profile) -- 1133
	end -- 1133
	current = idx -- 1135
	ensurePlay() -- 1136
	local fresh = play -- 1137
	if fresh ~= nil then -- 1137
		if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1137
			fresh.phase = "prologue-wake" -- 1140
		end -- 1140
		fresh:adoptEvents(leaving) -- 1142
	end -- 1142
	if not p.restartStory then -- 1142
		saveCurrentSession() -- 1145
	end -- 1145
	clock:reset() -- 1147
	return true -- 1148
end -- 1148
function tickFrontend(frameDt) -- 1151
	if fe == nil or input == nil then -- 1151
		return -- 1153
	end -- 1153
	if fe.screen ~= "play" then -- 1153
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1158
		input:consumeEdges() -- 1159
		if act.type == "splashDone" then -- 1159
			fe.menus:resetInput() -- 1161
			fe.screen = "title" -- 1162
		elseif act.type == "continue" then -- 1162
			if continueOfficialStory() == nil then -- 1162
				enterPlayRoom( -- 1165
					officialStartIndex(), -- 1165
					"official", -- 1165
					true -- 1165
				) -- 1165
			end -- 1165
		elseif act.type == "start" then -- 1165
			clearSession() -- 1169
			refreshTitleSessionFlag() -- 1170
			enterPlayRoom( -- 1171
				officialStartIndex(), -- 1171
				"official", -- 1171
				true -- 1171
			) -- 1171
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1171
			enterPlayRoom( -- 1173
				act.roomIndex, -- 1173
				"chapter", -- 1173
				false, -- 1173
				nil, -- 1173
				act.route -- 1173
			) -- 1173
		elseif act.type == "openChapters" then -- 1173
			fe.menus:openChapters() -- 1175
			fe.screen = "chapters" -- 1176
		elseif act.type == "openControls" then -- 1176
			fe.menus:resetInput() -- 1178
			fe.screen = "controls" -- 1179
		elseif act.type == "openSaves" then -- 1179
			fe.menus:openSaves(false) -- 1181
			fe.screen = "saves" -- 1182
		elseif act.type == "openSettings" then -- 1182
			fe.menus:openSettings() -- 1184
			fe.screen = "settings" -- 1185
		elseif act.type == "loadSlot" and act.slot ~= nil then -- 1185
			if loadOfficialSlot(act.slot) ~= nil then -- 1185
				fe:showToast( -- 1188
					"已读取" .. slotDisplayName(act.slot), -- 1188
					2 -- 1188
				) -- 1188
			else -- 1188
				fe:showToast("读取存档失败", 2.2) -- 1190
			end -- 1190
		elseif act.type == "deleteSlot" and act.slot ~= nil then -- 1190
			deleteSaveSlotById(act.slot) -- 1193
		elseif act.type == "openHistory" then -- 1193
			fe.menus:openHistory(true) -- 1195
			fe.screen = "history" -- 1196
		elseif act.type == "backEpilogue" then -- 1196
			fe.menus:resetInput() -- 1198
			fe.screen = "epilogue" -- 1199
		elseif act.type == "replayStory" then -- 1199
			clearSession() -- 1201
			refreshTitleSessionFlag() -- 1202
			enterPlayRoom( -- 1203
				officialStartIndex(), -- 1203
				"official", -- 1203
				true -- 1203
			) -- 1203
		elseif act.type == "backTitle" then -- 1203
			fe.menus:resetInput() -- 1205
			fe.screen = "title" -- 1206
		elseif act.type == "backPause" then -- 1206
			fe.menus:resetInput() -- 1208
			fe.screen = "play" -- 1209
		elseif act.type == "quit" then -- 1209
			quitGame() -- 1211
		end -- 1211
		return -- 1213
	end -- 1213
	if play == nil then -- 1213
		ensurePlay() -- 1218
	end -- 1218
	if play == nil then -- 1218
		return -- 1221
	end -- 1221
	local p = play -- 1223
	p.aimX = input.mx -- 1225
	p.aimY = input.my -- 1226
	local zoneTap = input.touchZoneTap -- 1228
	if zoneTap ~= "ledger:toggle" then -- 1228
		input.touchZoneTap = "" -- 1229
	end -- 1229
	if not p.paused and p.escortFailed then -- 1229
		local deathAction = "" -- 1233
		if zoneTap == "escort:retry" and p.escortFailedTicks >= 12 then -- 1233
			deathAction = "retry" -- 1235
		elseif zoneTap == "escort:title" then -- 1235
			deathAction = "title" -- 1237
		else -- 1237
			if input.navLeft or input.navPrevTab then -- 1237
				fe.roguelikeUi.deathSelected = 0 -- 1240
			elseif input.navRight or input.navNextTab then -- 1240
				fe.roguelikeUi.deathSelected = 1 -- 1242
			end -- 1242
			if input.pause.pressed or input.navBack then -- 1242
				deathAction = "title" -- 1245
			elseif p.escortFailedTicks >= 24 and (input.retry.pressed or input.retryTapPressed) then -- 1245
				deathAction = "retry" -- 1247
			elseif p.escortFailedTicks >= 24 and input.navConfirm then -- 1247
				deathAction = fe.roguelikeUi.deathSelected == 0 and "retry" or "title" -- 1249
			elseif p.escortFailedTicks >= 12 and (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) then -- 1249
				deathAction = fe:tryPickEscortDeathAtPointer(p, input, stageVp.stageW, stageVp.stageH) -- 1252
			end -- 1252
		end -- 1252
		if deathAction == "retry" then -- 1252
			input:consumeEdges() -- 1256
			p:confirmEscortRestart() -- 1257
			applyRoomTransition(p) -- 1258
			return -- 1259
		end -- 1259
		if deathAction == "title" then -- 1259
			input:consumeEdges() -- 1262
			fe.audio:stopRoomTransient() -- 1263
			fe.menus:resetInput() -- 1264
			fe.screen = "title" -- 1265
			input:clearTransient(true) -- 1266
			return -- 1267
		end -- 1267
		input.pause.pressed = false -- 1269
		input.retry.pressed = false -- 1270
		input.fire.pressed = false -- 1271
	end -- 1271
	if not p.paused and fe.roguelikeUi:isLedgerOpen() then -- 1271
		clock:reset() -- 1275
		fe:renderPlay( -- 1276
			frameDt, -- 1276
			p, -- 1276
			input, -- 1276
			stageVp.stageW, -- 1276
			stageVp.stageH -- 1276
		) -- 1276
		input:consumeEdges() -- 1277
		return -- 1278
	end -- 1278
	local offers = p:getStoryTalentOffers() -- 1281
	if fe:canPickStoryTalent(p) and #offers > 0 then -- 1281
		if fe.hud.talentSelected >= #offers then -- 1281
			fe.hud.talentSelected = 0 -- 1284
		end -- 1284
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1284
			local idx = __TS__ParseInt( -- 1287
				string.sub(zoneTap, 8), -- 1287
				10 -- 1287
			) -- 1287
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1287
				fe.hud.talentSelected = idx -- 1289
				input.fire.pressed = false -- 1290
			end -- 1290
		else -- 1290
			local navDelta = p.talentModalActive and ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) or 0 -- 1293
			local totalDelta = navDelta ~= 0 and navDelta or input.talentDelta -- 1296
			if totalDelta ~= 0 then -- 1296
				fe.hud.talentSelected = (fe.hud.talentSelected + totalDelta + #offers) % #offers -- 1298
				input.talentDelta = 0 -- 1299
			end -- 1299
			if input.talentConfirm or p.talentModalActive and input.navConfirm then -- 1299
				p:chooseTalent(fe.hud.talentSelected) -- 1302
				input.talentConfirm = false -- 1303
				input.fire.pressed = false -- 1304
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1304
				input.fire.pressed = false -- 1307
			end -- 1307
		end -- 1307
	end -- 1307
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1307
		if input.navConfirm then -- 1307
			input.interact.pressed = true -- 1315
		end -- 1315
		local towerMouseContinue = input.inputMode ~= "gamepad" and (input.uiPressed or input.fire.pressed) -- 1317
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed or input.retryTapPressed or towerMouseContinue) then -- 1317
			flushProfile() -- 1319
			if p.run.source == "official" and hasSessionSave() then -- 1319
				clearSession() -- 1321
				refreshTitleSessionFlag() -- 1322
			end -- 1322
			fe.audio:stopRoomTransient() -- 1324
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1325
			fe.screen = "epilogue" -- 1329
			input:clearTransient(true) -- 1330
			input:consumeEdges() -- 1331
			return -- 1332
		end -- 1332
	end -- 1332
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1332
		p:closeCraftBench() -- 1337
		input:consumeEdges() -- 1338
		return -- 1339
	end -- 1339
	if not p.paused and not p.escortFailed and fe:tryClickHudPause(p, input, stageVp.stageW, stageVp.stageH) then -- 1339
		input.pause.pressed = true -- 1342
		input.fire.pressed = false -- 1343
		input.fire.held = false -- 1344
		input.uiPressed = false -- 1345
	end -- 1345
	if not p.paused and not p.escortFailed and input.pause.pressed then -- 1345
		p.paused = true -- 1348
		p.aimHold = 0 -- 1349
		p.bottleAimX = -1 -- 1350
		saveCurrentSession() -- 1351
		fe.menus:openPause() -- 1352
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1353
		input:clearTransient(true) -- 1354
		input:consumeEdges() -- 1355
	end -- 1355
	if p.paused then -- 1355
		clock:reset() -- 1360
		local pauseAct = fe:renderPlay( -- 1361
			frameDt, -- 1361
			p, -- 1361
			input, -- 1361
			stageVp.stageW, -- 1361
			stageVp.stageH -- 1361
		) -- 1361
		input:consumeEdges() -- 1362
		if pauseAct.type == "resume" then -- 1362
			p.paused = false -- 1364
		elseif pauseAct.type == "retry" then -- 1364
			if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1364
				p:restartEscortRun() -- 1367
				applyRoomTransition(p) -- 1368
			else -- 1368
				ensurePlay({checkpoint = p.checkpoint}) -- 1370
			end -- 1370
		elseif pauseAct.type == "openChapters" then -- 1370
			fe.audio:stopRoomTransient() -- 1373
			fe.audio:setPaused(false) -- 1374
			fe.menus:openChapters(current) -- 1375
			fe.screen = "chapters" -- 1376
		elseif pauseAct.type == "toggleFullscreen" then -- 1376
			toggleFullscreen() -- 1378
		elseif pauseAct.type == "saveSlot" and pauseAct.slot ~= nil then -- 1378
			saveToManualSlot(pauseAct.slot) -- 1380
		elseif pauseAct.type == "loadSlot" and pauseAct.slot ~= nil then -- 1380
			if loadOfficialSlot(pauseAct.slot) ~= nil then -- 1380
				fe:showToast( -- 1383
					"已读取" .. slotDisplayName(pauseAct.slot), -- 1383
					2 -- 1383
				) -- 1383
			else -- 1383
				fe:showToast("读取存档失败", 2.2) -- 1385
			end -- 1385
		elseif pauseAct.type == "deleteSlot" and pauseAct.slot ~= nil then -- 1385
			deleteSaveSlotById(pauseAct.slot) -- 1388
		elseif pauseAct.type == "quit" then -- 1388
			quitGame() -- 1390
		elseif pauseAct.type == "toTitle" then -- 1390
			saveCurrentSession() -- 1392
			refreshTitleSessionFlag() -- 1393
			fe.menus:resetInput() -- 1394
			fe.screen = "title" -- 1395
		end -- 1395
		return -- 1397
	end -- 1397
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1400
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1401
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and not p.talentModalActive then -- 1401
		input:consumeEdges() -- 1404
		if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1404
			p:restartEscortRun() -- 1407
			applyRoomTransition(p) -- 1408
		else -- 1408
			ensurePlay({checkpoint = p.checkpoint}) -- 1411
		end -- 1411
		return -- 1413
	end -- 1413
	local worldPromptClick = fe:tryClickWorldPrompt(p, input, stageVp.stageW, stageVp.stageH) -- 1416
	if worldPromptClick == "tap" then -- 1416
		input.interact.pressed = true -- 1418
		input.interact.held = true -- 1419
		input.frameInteractPressed = true -- 1420
		input.fire.pressed = false -- 1421
		input.fire.held = false -- 1422
	elseif worldPromptClick == "hold" then -- 1422
		if input.uiPressed or input.fire.pressed then -- 1422
			input.interact.pressed = true -- 1425
			input.frameInteractPressed = true -- 1426
		end -- 1426
		input.interact.held = true -- 1428
		input.fire.pressed = false -- 1429
		input.fire.held = false -- 1430
	end -- 1430
	local steps = clock:advance(frameDt) -- 1433
	local i = 0 -- 1434
	do -- 1434
		i = 0 -- 1435
		while i < steps do -- 1435
			input:beginStep(i == 0) -- 1436
			p:update(STEP, input) -- 1437
			input:endStep() -- 1438
			if p.wantRoom ~= "" then -- 1438
				break -- 1440
			end -- 1440
			i = i + 1 -- 1435
		end -- 1435
	end -- 1435
	if applyRoomTransition(p) then -- 1435
		return -- 1446
	end -- 1446
	flushProfile() -- 1450
	if p.run.source == "official" and not p.paused and not p.run.finished then -- 1450
		runPlaySeconds = runPlaySeconds + math.min( -- 1452
			0.1, -- 1452
			math.max(0, frameDt) -- 1452
		) -- 1452
		autosaveTimer = autosaveTimer + math.min( -- 1453
			0.1, -- 1453
			math.max(0, frameDt) -- 1453
		) -- 1453
		if autosaveCooldown > 0 then -- 1453
			autosaveCooldown = math.max(0, autosaveCooldown - frameDt) -- 1455
		end -- 1455
	end -- 1455
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1455
		clearSession() -- 1459
		refreshTitleSessionFlag() -- 1460
	elseif p.sessionDirty then -- 1460
		saveCurrentSession() -- 1462
	elseif canSaveSession() and autosaveCooldown <= 0 then -- 1462
		local sig = sessionMilestoneSignature(p) -- 1464
		if lastAutosaveSig == "" then -- 1464
			lastAutosaveSig = sig -- 1466
		elseif sig ~= lastAutosaveSig or autosaveTimer >= 20 then -- 1466
			saveCurrentSession() -- 1468
		end -- 1468
	end -- 1468
	fe:renderPlay( -- 1471
		frameDt, -- 1471
		p, -- 1471
		input, -- 1471
		stageVp.stageW, -- 1471
		stageVp.stageH -- 1471
	) -- 1471
end -- 1471
profile = emptySave() -- 31
profileStatus = "missing" -- 32
local profileDetail = "" -- 33
current = 0 -- 34
viewW = 0 -- 35
viewH = 0 -- 36
clock = __TS__New(StepClock) -- 40
stageVp = computeStageViewport(1280, 720) -- 41
audioUnlocked = false -- 43
appClock = 0 -- 44
local lastBackPressClock = -10 -- 45
runPlaySeconds = 0 -- 46
autosaveTimer = 0 -- 47
autosaveCooldown = 0 -- 48
lastAutosaveSig = "" -- 49
windowFocused = true -- 50
pendingWinSizeSaveTimer = -1 -- 52
startupNoticeShown = false -- 53
local WINDOW_CLOSE_FORCE_COUNT = 4 -- 54
local WINDOW_CLOSE_FORCE_WINDOW = 2 -- 55
local windowCloseClicks = {} -- 56
local function isReleaseBuild() -- 62
	return isReleaseMode() -- 63
end -- 62
local function handleBackButton() -- 152
	if fe == nil then -- 152
		return -- 154
	end -- 154
	if fe.screen == "splash" then -- 154
		fe.menus:resetSplash() -- 157
		fe.screen = "title" -- 158
		fe.menus:resetInput() -- 159
		return -- 160
	end -- 160
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "saves" or fe.screen == "settings" or fe.screen == "epilogue" or fe.screen == "history" then -- 160
		fe.menus:triggerBack() -- 163
		return -- 164
	end -- 164
	if fe.screen == "title" then -- 164
		if not canQuitApp() then -- 164
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 168
			return -- 169
		end -- 169
		if appClock - lastBackPressClock <= 2 then -- 169
			quitGame() -- 172
		else -- 172
			lastBackPressClock = appClock -- 174
			fe:showToast("再按一次返回退出游戏", 2) -- 175
		end -- 175
		return -- 177
	end -- 177
	if fe.screen == "play" and play ~= nil then -- 177
		if play.escortFailed then -- 177
			fe.audio:stopRoomTransient() -- 181
			fe.menus:resetInput() -- 182
			fe.screen = "title" -- 183
			if input ~= nil then -- 183
				input:clearTransient(true) -- 184
			end -- 184
			return -- 185
		end -- 185
		if fe.roguelikeUi:isLedgerOpen() then -- 185
			fe.roguelikeUi:closeLedger() -- 188
			return -- 189
		end -- 189
		if play.paused then -- 189
			fe.menus:triggerBack() -- 192
			return -- 193
		end -- 193
		if play.craftBench.active then -- 193
			play:closeCraftBench() -- 196
			return -- 197
		end -- 197
		play.paused = true -- 199
		play.aimHold = 0 -- 200
		play.bottleAimX = -1 -- 201
		saveCurrentSession() -- 202
		fe.menus:openPause() -- 203
		if input ~= nil then -- 203
			input:clearTransient(true) -- 204
		end -- 204
	end -- 204
end -- 152
--- Windows 窗口右上角「×」拦截状态机：
-- - 单次点击：局内自动存档并弹出 ESC 暂歇菜单；若已在暂歇/标题页则将光标聚焦至「退出游戏」；
-- - 2 秒内连续点击 4 次：立即安全落盘并强制退出（原生 C++ 渲染线程亦同步计数兜底，主循环卡死也可强退）。
local function handleWindowClose(nativeCount) -- 213
	local now = appClock -- 214
	local kept = {} -- 215
	local i = 0 -- 216
	do -- 216
		i = 0 -- 217
		while i < #windowCloseClicks do -- 217
			if now - windowCloseClicks[i + 1] <= WINDOW_CLOSE_FORCE_WINDOW then -- 217
				kept[#kept + 1] = windowCloseClicks[i + 1] -- 219
			end -- 219
			i = i + 1 -- 217
		end -- 217
	end -- 217
	kept[#kept + 1] = now -- 222
	windowCloseClicks = kept -- 223
	local count = math.max( -- 225
		#windowCloseClicks, -- 225
		type(nativeCount) == "number" and math.floor(nativeCount) or 0 -- 225
	) -- 225
	if count >= WINDOW_CLOSE_FORCE_COUNT or fe == nil then -- 225
		quitGame() -- 227
		return -- 228
	end -- 228
	local remain = math.max(1, WINDOW_CLOSE_FORCE_COUNT - count) -- 231
	if fe.screen == "splash" then -- 231
		fe.menus:resetSplash() -- 233
		fe.screen = "title" -- 234
		fe.menus:focusQuit("title") -- 235
		fe:showToast( -- 236
			("已跳过片头 · 再连点关闭 " .. tostring(remain)) .. " 次可强制退出", -- 236
			2.6 -- 236
		) -- 236
		return -- 237
	end -- 237
	if fe.screen == "play" and play ~= nil then -- 237
		if fe.roguelikeUi:isLedgerOpen() then -- 237
			fe.roguelikeUi:closeLedger() -- 241
		end -- 241
		if not play.paused then -- 241
			if play.craftBench.active then -- 241
				play:closeCraftBench() -- 245
			end -- 245
			play.paused = true -- 247
			play.aimHold = 0 -- 248
			play.bottleAimX = -1 -- 249
			saveCurrentSession() -- 250
			fe.menus:openPause() -- 251
			fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 252
			if input ~= nil then -- 252
				input:clearTransient(true) -- 253
			end -- 253
			syncPowerMode() -- 254
			fe:showToast( -- 255
				("已暂歇并自动存档 · 如需强制退出请连点关闭（还差 " .. tostring(remain)) .. " 次）", -- 255
				3 -- 255
			) -- 255
			return -- 256
		end -- 256
		fe.menus:focusQuit("play") -- 258
		fe.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 259
		fe:showToast( -- 260
			("点击「退出游戏」安全退出 · 连点关闭还差 " .. tostring(remain)) .. " 次强制退出", -- 260
			2.6 -- 260
		) -- 260
		return -- 261
	end -- 261
	if fe.screen == "title" then -- 261
		fe.menus:focusQuit("title") -- 264
		fe.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 265
		fe:showToast( -- 266
			("点击「退出游戏」安全退出 · 连点关闭还差 " .. tostring(remain)) .. " 次强制退出", -- 266
			2.6 -- 266
		) -- 266
		return -- 267
	end -- 267
	fe.screen = "title" -- 269
	fe.menus:focusQuit("title") -- 270
	fe.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 271
	fe:showToast( -- 272
		("已返回标题 · 点击「退出游戏」或再连点关闭 " .. tostring(remain)) .. " 次强制退出", -- 272
		2.6 -- 272
	) -- 272
end -- 213
function ____exports.start(parent, _initialMode, startScreen) -- 548
	if _initialMode == nil then -- 548
		_initialMode = 1 -- 548
	end -- 548
	if startScreen == nil then -- 548
		startScreen = "title" -- 548
	end -- 548
	root = parent -- 549
	local loaded = loadSave() -- 553
	profile = loaded.state -- 554
	profileStatus = loaded.status -- 555
	profileDetail = loaded.detail -- 556
	fe = __TS__New(WatchFrontend, parent) -- 557
	fe.screen = startScreen -- 558
	if startScreen == "splash" then -- 558
		fe.menus:resetSplash() -- 560
	end -- 560
	refreshTitleSessionFlag() -- 562
	fe:setVisible(true) -- 563
	input = __TS__New(Input) -- 565
	fe.audio:applyUserVolumes(input.settings) -- 566
	fe.contract:setAssistHintsEnabled(input.settings.assistHints) -- 567
	if input.settings.muted then -- 567
		fe.audio:setAllMuted(true) -- 569
	end -- 569
	fe.menus.onToggleFullscreen = function() -- 571
		toggleFullscreen() -- 572
	end -- 571
	if isDesktopNative() and canToggleFullscreen() and testViewportOverride == nil then -- 571
		do -- 571
			pcall(function() -- 571
				if input.settings.fullscreen then -- 571
					if not App.fullScreen then -- 571
						App.fullScreen = true -- 579
					end -- 579
				elseif input.settings.winWidth >= 640 and input.settings.winHeight >= 360 then -- 579
					local curSize = App.winSize -- 582
					if math.abs(curSize.width - input.settings.winWidth) > 2 or math.abs(curSize.height - input.settings.winHeight) > 2 then -- 582
						App.winSize = Size(input.settings.winWidth, input.settings.winHeight) -- 585
					end -- 585
				end -- 585
			end) -- 585
		end -- 585
	end -- 585
	windowFocused = true -- 592
	lastAppliedIdle = nil -- 593
	startupNoticeShown = false -- 594
	syncPowerMode() -- 595
	input:attach( -- 596
		parent, -- 596
		{ -- 596
			onFirstUserGesture = function() -- 597
				onFirstUserGesture() -- 598
				if input ~= nil then -- 598
					input:markKeyboardActivity() -- 599
				end -- 599
			end, -- 597
			onToggleFullscreen = function() -- 601
				toggleFullscreen() -- 602
			end, -- 601
			onKeyDownEvent = function(____, key) -- 604
				if (fe and fe.screen) == "play" and play ~= nil and not play.paused then -- 604
					if key == "1" or key == "2" or key == "3" then -- 604
						if input ~= nil then -- 604
							input:requestPickRoom(__TS__Number(key)) -- 607
						end -- 607
						return -- 608
					end -- 608
					if key == "T" and not play.escortFailed and not play.talentModalActive and not fe.roguelikeUi:isLedgerOpen() then -- 608
						play:toggleArtifactWeapon() -- 611
						return -- 612
					end -- 612
				end -- 612
				local inPausedPlay = fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 615
				if fe ~= nil and (fe.screen ~= "play" or inPausedPlay) then -- 615
					fe.menus:onKeyEvent(key) -- 617
				end -- 617
				if input ~= nil and (fe ~= nil and fe.screen == "play" and not inPausedPlay) then -- 617
					if key == "E" then -- 617
						input.interact.pressed = true -- 621
					elseif key == "Space" then -- 621
						input.jump.pressed = true -- 623
					elseif key == "Escape" then -- 623
						input.pause.pressed = true -- 625
					end -- 625
				end -- 625
			end -- 604
		} -- 604
	) -- 604
	parent:gslot( -- 632
		"AppChange", -- 632
		function(settingName) -- 632
			if input == nil or not isDesktopNative() then -- 632
				return -- 634
			end -- 634
			if settingName == "FullScreen" then -- 634
				do -- 634
					pcall(function() -- 634
						input.settings.fullscreen = App.fullScreen -- 638
						saveControlSettings(input.settings) -- 639
					end) -- 639
				end -- 639
			elseif settingName == "Size" then -- 639
				pendingWinSizeSaveTimer = 0.45 -- 644
			end -- 644
		end -- 632
	) -- 632
	parent:gslot( -- 649
		"AppEvent", -- 649
		function(eventType, payload) -- 649
			if eventType == "BackButton" then -- 649
				handleBackButton() -- 651
				return -- 652
			end -- 652
			if eventType == "WindowClose" then -- 652
				handleWindowClose(type(payload) == "number" and payload or nil) -- 655
				return -- 656
			end -- 656
			if eventType == "Quit" or eventType == "Shutdown" then -- 656
				flushProfile() -- 659
				saveCurrentSession() -- 660
				if input ~= nil then -- 660
					input:clearTransient(false) -- 661
				end -- 661
				return -- 662
			end -- 662
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 662
				windowFocused = false -- 665
				flushProfile() -- 666
				saveCurrentSession() -- 667
				if input ~= nil then -- 667
					input:clearTransient(true) -- 668
				end -- 668
				if fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.escortFailed then -- 668
					play.paused = true -- 670
					play.aimHold = 0 -- 671
					play.bottleAimX = -1 -- 672
					fe.menus:openPause() -- 673
				end -- 673
				if fe ~= nil then -- 673
					fe.audio:setPaused(true) -- 676
				end -- 676
				syncPowerMode() -- 678
				return -- 679
			end -- 679
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 679
				windowFocused = true -- 682
				if fe ~= nil then -- 682
					local paused = play ~= nil and play.paused and fe.screen == "play" -- 684
					fe.audio:setPaused(paused) -- 685
				end -- 685
				syncPowerMode() -- 687
			end -- 687
		end -- 649
	) -- 649
	viewW = View.size.width -- 691
	viewH = View.size.height -- 692
	applySize() -- 693
	local reg = _G.package.loaded -- 696
	reg["watch.input"] = input -- 697
	reg["watch.touch"] = input:getTouchRouter() -- 698
	reg["watch.gamepad"] = input:getGamepadRouter() -- 699
	reg["watch.fe"] = { -- 700
		setScreen = function(sc) -- 701
			if fe == nil then -- 701
				return -- 703
			end -- 703
			clock:reset() -- 705
			fe.screen = sc -- 706
			if sc == "splash" then -- 706
				fe.menus:resetSplash() -- 708
			elseif sc == "chapters" then -- 708
				fe.menus:openChapters() -- 710
			elseif sc == "epilogue" then -- 710
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 712
			elseif sc == "history" then -- 712
				fe.menus:openHistory(false) -- 717
			else -- 717
				fe.menus:resetInput() -- 719
			end -- 719
			if sc == "play" then -- 719
				ensurePlay() -- 722
			end -- 722
		end, -- 701
		jumpRoom = function(keyOrIdx) -- 725
			local idx = -1 -- 726
			if type(keyOrIdx) == "number" then -- 726
				idx = keyOrIdx -- 728
			else -- 728
				local k = 0 -- 730
				do -- 730
					k = 0 -- 731
					while k < #ROOMS do -- 731
						if ROOMS[k + 1].key == keyOrIdx then -- 731
							idx = k -- 733
						end -- 733
						k = k + 1 -- 731
					end -- 731
				end -- 731
			end -- 731
			if idx >= 0 and idx < #ROOMS then -- 731
				enterPlayRoom(idx, "debug") -- 738
			end -- 738
		end, -- 725
		getPlay = function() return play end, -- 741
		getFrontend = function() return fe end, -- 742
		startStory = function(seed) -- 744
			enterPlayRoom( -- 745
				officialStartIndex(), -- 745
				"official", -- 745
				true, -- 745
				seed -- 745
			) -- 745
			return play -- 746
		end, -- 744
		previewChapter = function(idx, routeOrSeed, seed) -- 749
			enterPlayRoom( -- 750
				idx, -- 750
				"chapter", -- 750
				false, -- 750
				type(routeOrSeed) == "number" and routeOrSeed or seed, -- 750
				type(routeOrSeed) == "string" and routeOrSeed or nil -- 751
			) -- 751
			return play -- 752
		end, -- 749
		getStoryRun = function() return storyRun end, -- 754
		getProfilePending = function() return profilePending() end, -- 755
		flushProfileNow = function() return flushProfile() end, -- 756
		getProfile = function() return profile end, -- 758
		getProfileStatus = function() return profileStatus end, -- 759
		getProfileDetail = function() return profileDetail end, -- 760
		useTestSave = function(name) -- 761
			setSaveFile(name) -- 762
			setSessionFile(name == "" and "" or name .. ".session") -- 763
			clearProfilePending() -- 764
			local loaded = loadSave() -- 765
			profile = loaded.state -- 766
			profileStatus = loaded.status -- 767
			profileDetail = loaded.detail -- 768
			refreshTitleSessionFlag() -- 769
		end, -- 761
		useTestSession = function(name) -- 771
			setSessionFile(name) -- 772
			refreshTitleSessionFlag() -- 773
		end, -- 771
		getSessionFile = getSessionFile, -- 775
		hasSessionSave = hasSessionSave, -- 776
		saveSessionNow = function() return saveCurrentSession() end, -- 777
		clearSessionNow = function() -- 778
			local ok = clearSession() -- 779
			refreshTitleSessionFlag() -- 780
			return ok -- 781
		end, -- 778
		continueStory = function() return continueOfficialStory() end, -- 783
		listSaveSlots = function() return listSaveSlots() end, -- 784
		saveToSlot = function(slot) return saveToManualSlot(slot) end, -- 785
		loadFromSlot = function(slot) return loadOfficialSlot(slot) end, -- 786
		deleteSlot = function(slot) return deleteSaveSlotById(slot) end, -- 787
		canSaveSession = function() return canSaveSession() end, -- 788
		saveNow = function() return saveSave(profile) end, -- 789
		getSaveFile = getSaveFile, -- 790
		isRelease = function() return isReleaseBuild() end, -- 791
		getReleaseVersion = function() -- 792
			local ____opt_35 = getReleaseConfig() -- 792
			return ____opt_35 and ____opt_35.version or "dev" -- 792
		end, -- 792
		toggleFullscreen = function() return toggleFullscreen() end, -- 793
		quitGame = function() return quitGame() end, -- 794
		handleBackButton = function() return handleBackButton() end, -- 795
		getViewport = function() return stageVp end, -- 796
		getTargetId = function() return getActiveTarget().id end, -- 797
		getTouchController = function() return input and input:getTouchControls() end, -- 798
		getTouchRouter = function() return input and input:getTouchRouter() end, -- 799
		getGamepad = function() return input and input:getGamepadRouter() end, -- 800
		setGamepadSim = function(state) -- 801
			if input ~= nil then -- 801
				input:setGamepadSim(state) -- 802
			end -- 802
		end, -- 801
		injectTouch = function(phase, id, x, y, fromMouse) -- 804
			if input ~= nil then -- 804
				input:injectTouch( -- 805
					phase, -- 805
					id, -- 805
					x, -- 805
					y, -- 805
					fromMouse -- 805
				) -- 805
			end -- 805
		end, -- 804
		getInputMode = function() return input and input.inputMode or getActiveTarget().defaultInputMode end, -- 807
		setInputMode = function(m) -- 808
			if input ~= nil then -- 808
				input:setInputMode(m) -- 809
			end -- 809
		end, -- 808
		setModePref = function(pref) -- 811
			if input ~= nil then -- 811
				input:setModePref(pref) -- 812
			end -- 812
		end, -- 811
		applyViewportForTest = function(w, h) -- 814
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 814
				testViewportOverride = {w = w, h = h} -- 816
				viewW = w -- 817
				viewH = h -- 818
			else -- 818
				testViewportOverride = nil -- 820
				viewW = View.size.width -- 821
				viewH = View.size.height -- 822
			end -- 822
			applySize() -- 824
			return stageVp -- 825
		end, -- 814
		getToast = function() return fe and fe:getToastText() or "" end -- 827
	} -- 827
	if startScreen == "play" then -- 827
		ensurePlay() -- 831
	end -- 831
	parent:schedule(function(frameDt) -- 834
		tick(frameDt) -- 835
		return false -- 836
	end) -- 834
end -- 548
return ____exports -- 548