-- [ts]: app.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__ParseInt = ____lualib.__TS__ParseInt -- 1
local ____exports = {} -- 1
local randomRunSeed, syncPowerMode, onFirstUserGesture, toggleFullscreen, slotDisplayName, quitGame, canSaveSession, refreshTitleSessionFlag, clearSessionForRestart, exportSessionWithMeta, sessionMilestoneSignature, saveCurrentSession, saveToManualSlot, deleteSaveSlotById, continueOfficialStory, loadOfficialSlot, flushProfile, officialStartIndex, roomIndexByKey, enterPlayRoom, applySize, syncFrameAdapters, renderTouchOverlay, tick, registerPlay, ensurePlay, applyRoomTransition, tickFrontend, root, storyRun, profile, profileStatus, current, viewW, viewH, input, play, fe, clock, stageVp, testViewportOverride, audioUnlocked, appClock, runPlaySeconds, autosaveTimer, autosaveCooldown, lastAutosaveSig, windowFocused, lastAppliedIdle, pendingWinSizeSaveTimer, startupNoticeShown -- 1
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
function randomRunSeed() -- 56
	return math.max( -- 57
		1, -- 57
		math.floor(math.abs(App.rand)) % 2147483646 -- 57
	) -- 57
end -- 57
function syncPowerMode() -- 64
	if not isDesktopNative() then -- 64
		return -- 66
	end -- 66
	local wantIdle = not windowFocused -- 69
	if lastAppliedIdle == wantIdle then -- 69
		return -- 71
	end -- 71
	lastAppliedIdle = wantIdle -- 73
	do -- 73
		pcall(function() -- 73
			App.idled = wantIdle -- 75
		end) -- 75
	end -- 75
end -- 75
function onFirstUserGesture() -- 81
	if audioUnlocked or fe == nil then -- 81
		return -- 83
	end -- 83
	audioUnlocked = true -- 85
	fe.audio:unlockAndResyncAfterGesture() -- 86
end -- 86
function toggleFullscreen() -- 89
	if not canToggleFullscreen() then -- 89
		return false -- 91
	end -- 91
	do -- 91
		local function ____catch() -- 91
			return true, false -- 102
		end -- 102
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 102
			local next = not App.fullScreen -- 94
			App.fullScreen = next -- 95
			if input ~= nil then -- 95
				input.settings.fullscreen = next -- 97
				saveControlSettings(input.settings) -- 98
			end -- 98
			return true, next -- 100
		end) -- 100
		if not ____try then -- 100
			____hasReturned, ____returnValue = ____catch() -- 100
		end -- 100
		if ____hasReturned then -- 100
			return ____returnValue -- 93
		end -- 93
	end -- 93
end -- 93
function slotDisplayName(slot) -- 106
	if slot == "auto" then -- 106
		return "自动存档" -- 107
	end -- 107
	if slot == 1 then -- 107
		return "档案一" -- 108
	end -- 108
	if slot == 2 then -- 108
		return "档案二" -- 109
	end -- 109
	return "档案三" -- 110
end -- 110
function quitGame() -- 113
	flushProfile() -- 114
	saveCurrentSession() -- 115
	if input ~= nil and isDesktopNative() then -- 115
		do -- 115
			pcall(function() -- 115
				input.settings.fullscreen = App.fullScreen -- 118
				if not App.fullScreen then -- 118
					local ws = App.winSize -- 120
					if ws.width >= 640 and ws.height >= 360 then -- 120
						input.settings.winWidth = math.floor(ws.width + 0.5) -- 122
						input.settings.winHeight = math.floor(ws.height + 0.5) -- 123
					end -- 123
				end -- 123
				saveControlSettings(input.settings) -- 126
			end) -- 126
		end -- 126
	end -- 126
	if input ~= nil then -- 126
		input:clearTransient(false) -- 131
	end -- 131
	if fe ~= nil then -- 131
		fe.audio:stopRoomTransient() -- 133
	end -- 133
	if not canQuitApp() then -- 133
		current = 0 -- 137
		play = nil -- 138
		clock:reset() -- 139
		if fe ~= nil then -- 139
			fe.audio:stopRoomTransient() -- 141
			fe.screen = "title" -- 142
			fe.menus:resetInput() -- 143
		end -- 143
		return -- 145
	end -- 145
	App:shutdown() -- 147
end -- 147
function canSaveSession() -- 263
	if play == nil or storyRun == nil then -- 263
		return false -- 265
	end -- 265
	if storyRun.source ~= "official" or play.run.finished then -- 265
		return false -- 268
	end -- 268
	if play.room.key == "museum" or play.room.key == "tower" and play.phase == "tower-end" then -- 268
		return false -- 271
	end -- 271
	return true -- 273
end -- 273
function refreshTitleSessionFlag() -- 276
	if fe ~= nil then -- 276
		local has = hasSessionSave() -- 278
		fe.menus.hasSession = has -- 279
		if has then -- 279
			local loaded = loadSession() -- 281
			fe.menus:setSessionRoomKey(loaded.status == "ok" and loaded.state ~= nil and loaded.state.roomKey or "") -- 282
		else -- 282
			fe.menus:setSessionRoomKey("") -- 284
		end -- 284
		fe.menus:refreshSaveSlots() -- 286
	end -- 286
end -- 286
function clearSessionForRestart() -- 291
	if not clearSession() then -- 291
		if fe ~= nil then -- 291
			fe:showToast("清理自动存档失败，请检查目录写权限后重试", 3) -- 293
		end -- 293
		return false -- 294
	end -- 294
	refreshTitleSessionFlag() -- 296
	return true -- 297
end -- 297
function exportSessionWithMeta() -- 300
	if play == nil then -- 300
		return nil -- 302
	end -- 302
	local snap = play:exportSession() -- 304
	snap.savedAt = nowUnixSeconds() -- 305
	snap.playSeconds = math.max( -- 306
		0, -- 306
		math.floor(runPlaySeconds) -- 306
	) -- 306
	return snap -- 307
end -- 307
function sessionMilestoneSignature(p) -- 310
	local inv = p.run.inventory -- 311
	local takenCount = 0 -- 312
	for k in pairs(p.run.taken) do -- 313
		if p.run.taken[k] == true then -- 313
			takenCount = takenCount + 1 -- 314
		end -- 314
	end -- 314
	local segCount = 0 -- 316
	for k in pairs(p.run.story.segments) do -- 317
		if p.run.story.segments[k] == true then -- 317
			segCount = segCount + 1 -- 318
		end -- 318
	end -- 318
	return (((((((((((((((((((((((((((((p.room.key .. "|") .. tostring(p.checkpoint)) .. "|") .. p.phase) .. "|") .. tostring(p.run.story.hp)) .. "|") .. p.run.story.route) .. "|") .. tostring(inv.wood)) .. ":") .. tostring(inv.bell)) .. ":") .. tostring(inv.scrap)) .. ":") .. tostring(inv.wedge)) .. ":") .. tostring(inv.ammo)) .. "|") .. tostring(takenCount)) .. ":") .. tostring(segCount)) .. "|") .. (p.cartDocked and "1" or "0")) .. "|") .. (p.hasBottle and "1" or "0")) .. "|") .. (p.passed and "1" or "0")) .. "|") .. p.equippedWeapon -- 320
end -- 320
function saveCurrentSession() -- 333
	if not canSaveSession() or play == nil then -- 333
		return false -- 335
	end -- 335
	local snap = exportSessionWithMeta() -- 337
	if snap == nil then -- 337
		return false -- 339
	end -- 339
	local ok = saveSession(snap) -- 341
	play.sessionDirty = not ok -- 342
	if ok then -- 342
		autosaveTimer = 0 -- 344
		autosaveCooldown = 2.5 -- 345
		lastAutosaveSig = sessionMilestoneSignature(play) -- 346
	end -- 346
	refreshTitleSessionFlag() -- 348
	return ok -- 349
end -- 349
function saveToManualSlot(slot) -- 352
	if not canSaveSession() or play == nil then -- 352
		if fe ~= nil then -- 352
			fe:showToast("当前段落无法手动存档", 2) -- 354
		end -- 354
		return false -- 355
	end -- 355
	local snap = exportSessionWithMeta() -- 357
	if snap == nil then -- 357
		return false -- 359
	end -- 359
	local ok = saveSlot(slot, snap) -- 361
	refreshTitleSessionFlag() -- 362
	if ok then -- 362
		if fe ~= nil then -- 362
			fe:showToast( -- 364
				"已保存至" .. slotDisplayName(slot), -- 364
				2 -- 364
			) -- 364
		end -- 364
	else -- 364
		if fe ~= nil then -- 364
			fe:showToast("保存失败，请检查目录写权限", 2.4) -- 366
		end -- 366
	end -- 366
	return ok -- 368
end -- 368
function deleteSaveSlotById(slot) -- 371
	local ok = deleteSlot(slot) -- 372
	refreshTitleSessionFlag() -- 373
	if fe ~= nil then -- 373
		fe:showToast( -- 374
			ok and "已删除" .. slotDisplayName(slot) or "删除存档失败", -- 374
			2 -- 374
		) -- 374
	end -- 374
	return ok -- 375
end -- 375
function continueOfficialStory() -- 378
	return loadOfficialSlot("auto") -- 379
end -- 379
function loadOfficialSlot(slot) -- 382
	if slot == "auto" and (play and play.escortFailed) and play.run.source == "official" and play.sessionDirty then -- 382
		play:confirmEscortRestart() -- 385
		applyRoomTransition(play) -- 386
		if fe ~= nil then -- 386
			fe.screen = "play" -- 387
		end -- 387
		return play -- 388
	end -- 388
	local res = loadSlot(slot) -- 390
	if res.status ~= "ok" or res.state == nil then -- 390
		refreshTitleSessionFlag() -- 392
		return nil -- 393
	end -- 393
	local s = res.state -- 395
	local idx = roomIndexByKey(s.roomKey) -- 396
	if ROOMS[idx + 1].key ~= s.roomKey then -- 396
		return nil -- 398
	end -- 398
	runPlaySeconds = math.max(0, s.playSeconds or 0) -- 400
	autosaveTimer = 0 -- 401
	autosaveCooldown = 2.5 -- 402
	lastAutosaveSig = "" -- 403
	storyRun = createRun(s.seed, "official", profile) -- 404
	storyRun.checkpoint = s.checkpoint -- 405
	storyRun.story.route = s.route -- 406
	storyRun.story.hp = s.hp -- 407
	storyRun.story.maxHp = s.maxHp -- 408
	storyRun.story.hpAtGate = s.hpAtGate -- 409
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 410
	storyRun.story.settled = s.settled -- 411
	storyRun.story.phase = s.phase -- 412
	storyRun.story.countTick = s.countTick -- 413
	storyRun.story.phaseTick = s.phaseTick -- 414
	storyRun.story.handTicks = s.handTicks -- 415
	storyRun.story.handDone = s.handDone -- 416
	storyRun.story.lineSaid = s.lineSaid -- 417
	storyRun.story.tied = s.tied -- 418
	storyRun.story.carry = s.carry -- 419
	storyRun.story.escortDone = s.escortDone -- 420
	storyRun.story.craftedWeapon = s.craftedWeapon -- 421
	storyRun.story.equippedWeapon = s.equippedWeapon -- 422
	storyRun.inventory.wood = s.wood -- 423
	storyRun.inventory.bell = s.bell -- 424
	storyRun.inventory.scrap = s.scrap -- 425
	storyRun.inventory.wedge = s.wedge -- 426
	storyRun.inventory.ammo = s.ammo -- 427
	storyRun.inventory.shield = s.shield -- 428
	storyRun.inventory.pass = s.pass -- 429
	storyRun.inventory.quickbelt = s.quickbelt -- 430
	local k = 0 -- 431
	do -- 431
		k = 0 -- 432
		while k < #s.taken do -- 432
			storyRun.taken[s.taken[k + 1]] = true -- 433
			k = k + 1 -- 432
		end -- 432
	end -- 432
	do -- 432
		k = 0 -- 435
		while k < #s.segments do -- 435
			storyRun.story.segments[s.segments[k + 1]] = true -- 436
			k = k + 1 -- 435
		end -- 435
	end -- 435
	if s.campaignRoute ~= nil then -- 435
		storyRun.route = s.campaignRoute -- 439
	end -- 439
	if s.joined ~= nil then -- 439
		storyRun.joined = s.joined -- 442
	end -- 442
	if s.c1Latch ~= nil then -- 442
		storyRun.c1Latch = s.c1Latch -- 445
	end -- 445
	if s.c2Latch ~= nil then -- 445
		storyRun.c2Latch = s.c2Latch -- 448
	end -- 448
	if s.props ~= nil then -- 448
		do -- 448
			k = 0 -- 451
			while k < #s.props do -- 451
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 452
				local pid = parts[1] -- 453
				if pid ~= nil and pid ~= "" then -- 453
					local ____storyRun_props_24 = storyRun.props -- 455
					local ____temp_20 -- 456
					if parts[2] == nil then -- 456
						____temp_20 = true -- 456
					else -- 456
						____temp_20 = parts[2] == "1" -- 456
					end -- 456
					local ____temp_22 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 457
					local ____temp_23 = parts[4] == "1" -- 458
					local ____temp_21 -- 459
					if parts[5] == "1" then -- 459
						____temp_21 = true -- 459
					else -- 459
						____temp_21 = nil -- 459
					end -- 459
					____storyRun_props_24[pid] = {broken = ____temp_20, hp = ____temp_22, wedge = ____temp_23, revealed = ____temp_21} -- 455
				end -- 455
				k = k + 1 -- 451
			end -- 451
		end -- 451
	end -- 451
	local stTalents = createStoryTalents(s.seed) -- 464
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 464
		stTalents.randomState = s.talentSeed -- 466
	end -- 466
	if s.escortAttempt ~= nil and s.escortAttempt >= 1 then -- 466
		stTalents.attempt = s.escortAttempt -- 469
	end -- 469
	if s.escortVariant ~= nil and s.escortVariant >= 0 then -- 469
		stTalents.variant = s.escortVariant -- 472
	end -- 472
	stTalents.deferred = s.talentDeferred == true -- 474
	stTalents.room = s.talentRoom or "" -- 475
	if s.talentRanks ~= nil and #s.talentRanks > 0 then -- 475
		do -- 475
			k = 0 -- 477
			while k < #s.talentRanks do -- 477
				local parts = __TS__StringSplit(s.talentRanks[k + 1], ":") -- 478
				local ____temp_25 -- 479
				if parts[1] ~= nil then -- 479
					____temp_25 = normalizeLegacyTalent(parts[1]) -- 479
				else -- 479
					____temp_25 = nil -- 479
				end -- 479
				local norm = ____temp_25 -- 479
				local rk = parts[2] ~= nil and (tonumber(parts[2]) or 0) or 0 -- 480
				if norm ~= nil and rk > 0 then -- 480
					stTalents.ranks[norm] = (stTalents.ranks[norm] or 0) + math.floor(rk) -- 482
				end -- 482
				k = k + 1 -- 477
			end -- 477
		end -- 477
	else -- 477
		stTalents.ranks.vitality = s.talentVitality or 0 -- 487
		stTalents.ranks.focus = s.talentReload or 0 -- 488
		stTalents.ranks.guard = s.talentGuard or 0 -- 489
		stTalents.ranks.salvage = s.talentCraft or 0 -- 490
	end -- 490
	if s.talentOffers ~= nil then -- 490
		do -- 490
			k = 0 -- 493
			while k < #s.talentOffers do -- 493
				local norm = normalizeLegacyTalent(s.talentOffers[k + 1]) -- 494
				if norm ~= nil then -- 494
					local ____stTalents_offers_26 = stTalents.offers -- 494
					____stTalents_offers_26[#____stTalents_offers_26 + 1] = norm -- 496
				end -- 496
				k = k + 1 -- 493
			end -- 493
		end -- 493
	end -- 493
	storyRun.story.talents = stTalents -- 500
	current = idx -- 501
	clock:reset() -- 502
	if fe ~= nil then -- 502
		fe.screen = "play" -- 504
	end -- 504
	play = nil -- 506
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 507
	local cur = play -- 508
	if cur ~= nil then -- 508
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 508
			cur.cartAxle = s.cartAxle -- 511
			cur.cartDocked = s.cartDocked -- 512
		end -- 512
		if s.playerX ~= nil and s.playerX >= 0 then -- 512
			cur.player.x = math.max( -- 515
				cur.room.minX + 16, -- 515
				math.min(cur.room.maxX - 16, s.playerX) -- 515
			) -- 515
			cur.player.y = math.max(0, s.playerY or 0) -- 516
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 516
				cur.player.depth = math.max( -- 518
					cur.room.depth.min, -- 518
					math.min(cur.room.depth.max, s.playerDepth) -- 518
				) -- 518
			end -- 518
		end -- 518
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 518
			cur.gateTick = s.gateTick -- 522
		end -- 522
		if cur.room.key == "village" then -- 522
			if s.hasBottle == true then -- 522
				cur.hasBottle = true -- 525
			end -- 525
			if s.villagePassed == true then -- 525
				cur.passed = true -- 526
			end -- 526
		end -- 526
		if cur.room.key == "prologue" and (s.phase == "" or s.phase == "prologue-wake" or s.phase == "prologue-shadow" or s.phase == "prologue-escape" or s.phase == "prologue-hide") then -- 526
			cur.phase = "prologue-wake" -- 535
		end -- 535
		if (string.find(cur.room.key, "escort", nil, true) or 0) - 1 == 0 and s.route == "soldier" and not cur.craftBench.active and not cur.carryOn then -- 535
			cur.carryOn = true -- 539
			storyRun.story.carry = true -- 540
		end -- 540
	end -- 540
	return play -- 543
end -- 543
function flushProfile() -- 842
	local cur = play -- 843
	if cur ~= nil and cur.archiveDirty then -- 843
		cur.archiveDirty = false -- 845
		markProfilePending(profile) -- 846
	end -- 846
	local ok = flushSaveProfile() -- 848
	if not ok and cur ~= nil then -- 848
		cur.archiveDirty = true -- 850
	end -- 850
	return ok -- 852
end -- 852
function officialStartIndex() -- 856
	local mp = profile.museumPhase -- 857
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 858
	return inMuseum and roomIndexByKey("museum") or 0 -- 859
end -- 859
function roomIndexByKey(key) -- 862
	local i = 0 -- 863
	do -- 863
		i = 0 -- 864
		while i < #ROOMS do -- 864
			if ROOMS[i + 1].key == key then -- 864
				return i -- 866
			end -- 866
			i = i + 1 -- 864
		end -- 864
	end -- 864
	return 0 -- 869
end -- 869
function ____exports.applyChapterPreviewRoute(targetRun, roomKey, routeOverride) -- 872
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" and routeOverride ~= "soldier" then -- 872
		targetRun.story.route = "child" -- 877
		targetRun.story.settled = true -- 878
		targetRun.story.countTick = 1440 -- 879
	elseif roomKey == "gatepath" or (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 or roomKey == "tower" and routeOverride == "soldier" then -- 879
		targetRun.story.route = "soldier" -- 882
		targetRun.story.settled = true -- 883
		targetRun.joined = true -- 884
		targetRun.story.handDone = true -- 885
		targetRun.story.tied = true -- 886
		local ____targetRun_story_57 = targetRun.story -- 887
		targetRun.story.maxHpAtGate = 3 -- 887
		____targetRun_story_57.hpAtGate = 3 -- 887
		if (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 then -- 887
			targetRun.story.carry = true -- 889
		end -- 889
		if roomKey == "escort4" or roomKey == "escort5" then -- 889
			targetRun.inventory.wood = 2 -- 892
			targetRun.inventory.bell = 1 -- 893
		end -- 893
		if roomKey == "escort3" then -- 893
			targetRun.inventory.wood = math.max(targetRun.inventory.wood, 2) -- 896
			targetRun.inventory.scrap = math.max(targetRun.inventory.scrap, 2) -- 897
			targetRun.inventory.bell = math.max(targetRun.inventory.bell, 1) -- 898
			targetRun.inventory.wedge = math.max(targetRun.inventory.wedge, 1) -- 899
		end -- 899
	end -- 899
end -- 872
function enterPlayRoom(idx, source, fresh, seedOverride, chapterRoute) -- 904
	if source == nil then -- 904
		source = "debug" -- 904
	end -- 904
	if fresh == nil then -- 904
		fresh = false -- 904
	end -- 904
	current = idx -- 905
	clock:reset() -- 906
	if fe ~= nil then -- 906
		fe.screen = "play" -- 908
	end -- 908
	play = nil -- 910
	if fresh or source == "chapter" or storyRun == nil then -- 910
		storyRun = createRun( -- 913
			seedOverride or (source == "debug" and 20261124 or randomRunSeed()), -- 913
			source, -- 913
			profile -- 913
		) -- 913
		if fresh or source == "official" then -- 913
			runPlaySeconds = 0 -- 915
			autosaveTimer = 0 -- 916
			lastAutosaveSig = "" -- 917
		end -- 917
		if source == "chapter" then -- 917
			local targetKey = ROOMS[current + 1] ~= nil and ROOMS[current + 1].key or "" -- 920
			____exports.applyChapterPreviewRoute(storyRun, targetKey, chapterRoute) -- 921
		end -- 921
	else -- 921
		storyRun.source = source -- 924
	end -- 924
	ensurePlay() -- 926
	local firstPlay = play -- 928
	if firstPlay ~= nil and ROOMS[current + 1].key == "prologue" and (fresh and source == "official" or source == "chapter") then -- 928
		firstPlay.phase = "prologue-wake" -- 931
	end -- 931
	flushProfile() -- 933
end -- 933
function applySize() -- 936
	if root == nil then -- 936
		return -- 938
	end -- 938
	root.size = Size(viewW, viewH) -- 940
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 941
	stageVp = computeStageViewport(viewW, viewH) -- 942
	if input ~= nil then -- 942
		input:setStageViewport(stageVp) -- 944
	end -- 944
	if fe ~= nil then -- 944
		fe:setStagePlacement(stageVp) -- 947
	end -- 947
end -- 947
function syncFrameAdapters(frameDt) -- 951
	if input == nil then -- 951
		return -- 953
	end -- 953
	local target = input.target -- 955
	if not target.supportsTouch and not target.supportsGamepad then -- 955
		return -- 957
	end -- 957
	local p = play -- 959
	local isPlayMode = fe ~= nil and fe.screen == "play" and p ~= nil -- 960
	local storyTalentBoxes = target.supportsTouch and isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 961
		p, -- 963
		stageVp.stageW, -- 963
		stageVp.stageH, -- 963
		input:isTouchMode() -- 963
	) or ({}) -- 963
	local isFs = false -- 966
	if target:canToggleFullscreen() then -- 966
		do -- 966
			local function ____catch() -- 966
				isFs = false -- 971
			end -- 971
			local ____try = pcall(function() -- 971
				isFs = App.fullScreen -- 969
			end) -- 969
			if not ____try then -- 969
				____catch() -- 969
			end -- 969
		end -- 969
	end -- 969
	local ____input_76 = input -- 974
	local ____input_syncFrame_77 = input.syncFrame -- 974
	local ____stageVp_69 = stageVp -- 975
	local ____temp_70 = fe ~= nil and fe.screen or "title" -- 977
	local ____storyRun_71 = storyRun -- 979
	local ____isPlayMode_60 -- 980
	if isPlayMode then -- 980
		____isPlayMode_60 = fe and fe.cam -- 980
	else -- 980
		____isPlayMode_60 = nil -- 980
	end -- 980
	local ____input_72 = input -- 981
	local ____temp_61 -- 982
	if fe ~= nil then -- 982
		____temp_61 = fe.contract:isAssistHintsEnabled() -- 982
	else -- 982
		____temp_61 = true -- 982
	end -- 982
	local ____temp_62 -- 983
	if fe ~= nil then -- 983
		____temp_62 = fe.audio:isAllMuted() -- 983
	else -- 983
		____temp_62 = false -- 983
	end -- 983
	local ____isFs_73 = isFs -- 984
	local ____storyTalentBoxes_74 = storyTalentBoxes -- 985
	local ____temp_63 -- 986
	if p and fe then -- 986
		____temp_63 = fe:getEscortDeathBoxes(p, stageVp.stageW, stageVp.stageH) -- 986
	else -- 986
		____temp_63 = nil -- 986
	end -- 986
	local ____temp_75 = fe and fe.roguelikeUi:getLedgerButtonRect() -- 987
	local ____temp_68 = fe and fe.roguelikeUi:isLedgerOpen() -- 988
	if ____temp_68 == nil then -- 988
		____temp_68 = false -- 988
	end -- 988
	____input_syncFrame_77(____input_76, { -- 974
		viewport = ____stageVp_69, -- 975
		mode = 1, -- 976
		screen = ____temp_70, -- 977
		play = p, -- 978
		run = ____storyRun_71, -- 979
		cam = ____isPlayMode_60, -- 980
		input = ____input_72, -- 981
		assistHintsEnabled = ____temp_61, -- 982
		isMuted = ____temp_62, -- 983
		isFullscreen = ____isFs_73, -- 984
		storyTalentBoxes = ____storyTalentBoxes_74, -- 985
		escortDeathBoxes = ____temp_63, -- 986
		ledgerBox = ____temp_75, -- 987
		ledgerOpen = ____temp_68, -- 988
		dt = frameDt -- 989
	}) -- 989
end -- 989
function renderTouchOverlay() -- 993
	if input ~= nil then -- 993
		input:renderOverlay() -- 994
	end -- 994
end -- 994
function tick(frameDt) -- 997
	appClock = appClock + math.min( -- 998
		0.05, -- 998
		math.max(0, frameDt) -- 998
	) -- 998
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 999
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 1000
	if w ~= viewW or h ~= viewH then -- 1000
		viewW = w -- 1002
		viewH = h -- 1003
		applySize() -- 1004
	end -- 1004
	if input == nil then -- 1004
		return -- 1007
	end -- 1007
	syncFrameAdapters(frameDt) -- 1009
	input:update(frameDt) -- 1010
	if input.userInteracted then -- 1010
		onFirstUserGesture() -- 1013
	end -- 1013
	if pendingWinSizeSaveTimer > 0 then -- 1013
		pendingWinSizeSaveTimer = pendingWinSizeSaveTimer - frameDt -- 1016
		if pendingWinSizeSaveTimer <= 0 and isDesktopNative() then -- 1016
			do -- 1016
				pcall(function() -- 1016
					if not App.fullScreen then -- 1016
						local ws = App.winSize -- 1020
						if ws.width >= 640 and ws.height >= 360 then -- 1020
							input.settings.winWidth = math.floor(ws.width + 0.5) -- 1022
							input.settings.winHeight = math.floor(ws.height + 0.5) -- 1023
							saveControlSettings(input.settings) -- 1024
						end -- 1024
					end -- 1024
				end) -- 1024
			end -- 1024
		end -- 1024
	end -- 1024
	if input.muteTogglePressed and fe ~= nil then -- 1024
		input.muteTogglePressed = false -- 1033
		local muted = fe.audio:toggleAllMuted() -- 1034
		input.settings.muted = muted -- 1035
		saveControlSettings(input.settings) -- 1036
	end -- 1036
	if input.fullscreenTogglePressed then -- 1036
		input.fullscreenTogglePressed = false -- 1039
		toggleFullscreen() -- 1040
	end -- 1040
	syncPowerMode() -- 1042
	if not startupNoticeShown and fe ~= nil and fe.screen == "title" then -- 1042
		startupNoticeShown = true -- 1044
		local rel = getReleaseConfig() -- 1045
		if rel ~= nil and rel.saveFallbackReason == "readonly" then -- 1045
			fe:showToast("游戏目录不可写，存档已自动回退至用户目录", 4.5) -- 1047
		elseif rel ~= nil and rel.migratedFrom ~= nil and rel.migratedFrom ~= "" then -- 1047
			fe:showToast("已自动迁移旧存档至 saves 目录", 3.5) -- 1049
		elseif profileStatus == "corrupt" or profileStatus == "unsupported" then -- 1049
			fe:showToast("主档案异常，原件已备份至 backups 目录", 4.5) -- 1051
		end -- 1051
	end -- 1051
	if input.artifactTogglePressed then -- 1051
		input.artifactTogglePressed = false -- 1055
		if (fe and fe.screen) == "play" and play ~= nil and not play.paused and not play.escortFailed and not play.talentModalActive and not fe.roguelikeUi:isLedgerOpen() then -- 1055
			play:toggleArtifactWeapon() -- 1058
		end -- 1058
	end -- 1058
	if input.bottleCanceled and play ~= nil then -- 1058
		input.bottleCanceled = false -- 1062
		play.aimHold = 0 -- 1063
		play.bottleAimX = -1 -- 1064
	end -- 1064
	if fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and not play.escortFailed and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 1064
		if fe:canPickStoryTalent(play) then -- 1064
			play:chooseTalent(input.pickRoom - 1) -- 1071
		end -- 1071
	end -- 1071
	input.pickRoom = 0 -- 1074
	tickFrontend(frameDt) -- 1075
	renderTouchOverlay() -- 1076
end -- 1076
function registerPlay() -- 1080
	local reg = _G.package.loaded -- 1081
	reg["watch.play"] = play -- 1082
	reg["watch.room"] = ROOMS[current + 1].key -- 1083
end -- 1083
function ensurePlay(resume) -- 1087
	if storyRun == nil then -- 1087
		storyRun = createRun(20261124, "debug", profile) -- 1091
	end -- 1091
	play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1093
	registerPlay() -- 1094
	clock:reset() -- 1095
	if fe ~= nil then -- 1095
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1097
	end -- 1097
end -- 1097
function applyRoomTransition(p) -- 1102
	if p.wantRoom == "" then -- 1102
		return false -- 1104
	end -- 1104
	local key = p.wantRoom -- 1106
	p.wantRoom = "" -- 1107
	local idx = -1 -- 1108
	local j = 0 -- 1109
	do -- 1109
		j = 0 -- 1110
		while j < #ROOMS do -- 1110
			if ROOMS[j + 1].key == key then -- 1110
				idx = j -- 1112
			end -- 1112
			j = j + 1 -- 1110
		end -- 1110
	end -- 1110
	if idx < 0 then -- 1110
		return false -- 1116
	end -- 1116
	flushProfile() -- 1121
	if p.restartStory and (storyRun and storyRun.source) == "official" and not clearSessionForRestart() then -- 1121
		p.restartStory = false -- 1123
		if fe ~= nil then -- 1123
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1125
			fe.screen = "epilogue" -- 1126
		end -- 1126
		if input ~= nil then -- 1126
			input:clearTransient(true) -- 1128
		end -- 1128
		return true -- 1129
	end -- 1129
	local leaving = p:drainEvents() -- 1131
	if p.restartStory then -- 1131
		local nextSource = storyRun and storyRun.source or "debug" -- 1133
		local nextSeed = nextSource == "official" and randomRunSeed() or 20261124 -- 1134
		storyRun = createRun(nextSeed, nextSource, profile) -- 1135
	end -- 1135
	current = idx -- 1137
	ensurePlay() -- 1138
	local fresh = play -- 1139
	if fresh ~= nil then -- 1139
		if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1139
			fresh.phase = "prologue-wake" -- 1142
		end -- 1142
		fresh:adoptEvents(leaving) -- 1144
	end -- 1144
	if not p.restartStory then -- 1144
		saveCurrentSession() -- 1147
	end -- 1147
	clock:reset() -- 1149
	return true -- 1150
end -- 1150
function tickFrontend(frameDt) -- 1153
	if fe == nil or input == nil then -- 1153
		return -- 1155
	end -- 1155
	if fe.screen ~= "play" then -- 1155
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1160
		input:consumeEdges() -- 1161
		if act.type == "splashDone" then -- 1161
			fe.menus:resetInput() -- 1163
			fe.screen = "title" -- 1164
		elseif act.type == "continue" then -- 1164
			if continueOfficialStory() == nil then -- 1164
				fe:showToast("读取存档失败", 2.2) -- 1167
			end -- 1167
		elseif act.type == "start" or act.type == "replayStory" then -- 1167
			if clearSessionForRestart() then -- 1167
				enterPlayRoom( -- 1170
					officialStartIndex(), -- 1170
					"official", -- 1170
					true -- 1170
				) -- 1170
			end -- 1170
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1170
			enterPlayRoom( -- 1172
				act.roomIndex, -- 1172
				"chapter", -- 1172
				false, -- 1172
				nil, -- 1172
				act.route -- 1172
			) -- 1172
		elseif act.type == "openChapters" then -- 1172
			fe.menus:openChapters() -- 1174
			fe.screen = "chapters" -- 1175
		elseif act.type == "openControls" then -- 1175
			fe.menus:resetInput() -- 1177
			fe.screen = "controls" -- 1178
		elseif act.type == "openSaves" then -- 1178
			fe.menus:openSaves(false) -- 1180
			fe.screen = "saves" -- 1181
		elseif act.type == "openSettings" then -- 1181
			fe.menus:openSettings() -- 1183
			fe.screen = "settings" -- 1184
		elseif act.type == "loadSlot" and act.slot ~= nil then -- 1184
			if loadOfficialSlot(act.slot) ~= nil then -- 1184
				fe:showToast( -- 1187
					"已读取" .. slotDisplayName(act.slot), -- 1187
					2 -- 1187
				) -- 1187
			else -- 1187
				fe:showToast("读取存档失败", 2.2) -- 1189
			end -- 1189
		elseif act.type == "deleteSlot" and act.slot ~= nil then -- 1189
			deleteSaveSlotById(act.slot) -- 1192
		elseif act.type == "openHistory" then -- 1192
			fe.menus:openHistory(true) -- 1194
			fe.screen = "history" -- 1195
		elseif act.type == "backEpilogue" then -- 1195
			fe.menus:resetInput() -- 1197
			fe.screen = "epilogue" -- 1198
		elseif act.type == "backTitle" then -- 1198
			fe.menus:resetInput() -- 1200
			fe.screen = "title" -- 1201
		elseif act.type == "backPause" then -- 1201
			fe.menus:resetInput() -- 1203
			fe.screen = "play" -- 1204
		elseif act.type == "quit" then -- 1204
			quitGame() -- 1206
		end -- 1206
		return -- 1208
	end -- 1208
	if play == nil then -- 1208
		ensurePlay() -- 1213
	end -- 1213
	if play == nil then -- 1213
		return -- 1216
	end -- 1216
	local p = play -- 1218
	p.aimX = input.mx -- 1220
	p.aimY = input.my -- 1221
	local zoneTap = input.touchZoneTap -- 1223
	if zoneTap ~= "ledger:toggle" then -- 1223
		input.touchZoneTap = "" -- 1224
	end -- 1224
	if not p.paused and p.escortFailed then -- 1224
		local deathAction = "" -- 1228
		if zoneTap == "escort:retry" and p.escortFailedTicks >= 12 then -- 1228
			deathAction = "retry" -- 1230
		elseif zoneTap == "escort:title" then -- 1230
			deathAction = "title" -- 1232
		else -- 1232
			if input.navLeft or input.navPrevTab then -- 1232
				fe.roguelikeUi.deathSelected = 0 -- 1235
			elseif input.navRight or input.navNextTab then -- 1235
				fe.roguelikeUi.deathSelected = 1 -- 1237
			end -- 1237
			if input.pause.pressed or input.navBack then -- 1237
				deathAction = "title" -- 1240
			elseif p.escortFailedTicks >= 24 and (input.retry.pressed or input.retryTapPressed) then -- 1240
				deathAction = "retry" -- 1242
			elseif p.escortFailedTicks >= 24 and input.navConfirm then -- 1242
				deathAction = fe.roguelikeUi.deathSelected == 0 and "retry" or "title" -- 1244
			elseif p.escortFailedTicks >= 12 and (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) then -- 1244
				deathAction = fe:tryPickEscortDeathAtPointer(p, input, stageVp.stageW, stageVp.stageH) -- 1247
			end -- 1247
		end -- 1247
		if deathAction == "retry" then -- 1247
			input:consumeEdges() -- 1251
			p:confirmEscortRestart() -- 1252
			applyRoomTransition(p) -- 1253
			return -- 1254
		end -- 1254
		if deathAction == "title" then -- 1254
			input:consumeEdges() -- 1257
			fe.audio:stopRoomTransient() -- 1258
			fe.menus:resetInput() -- 1259
			fe.screen = "title" -- 1260
			input:clearTransient(true) -- 1261
			return -- 1262
		end -- 1262
		input.pause.pressed = false -- 1264
		input.retry.pressed = false -- 1265
		input.fire.pressed = false -- 1266
	end -- 1266
	if not p.paused and fe.roguelikeUi:isLedgerOpen() then -- 1266
		clock:reset() -- 1270
		fe:renderPlay( -- 1271
			frameDt, -- 1271
			p, -- 1271
			input, -- 1271
			stageVp.stageW, -- 1271
			stageVp.stageH -- 1271
		) -- 1271
		input:consumeEdges() -- 1272
		return -- 1273
	end -- 1273
	local offers = p:getStoryTalentOffers() -- 1276
	if fe:canPickStoryTalent(p) and #offers > 0 then -- 1276
		if fe.hud.talentSelected >= #offers then -- 1276
			fe.hud.talentSelected = 0 -- 1279
		end -- 1279
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1279
			local idx = __TS__ParseInt( -- 1282
				string.sub(zoneTap, 8), -- 1282
				10 -- 1282
			) -- 1282
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1282
				fe.hud.talentSelected = idx -- 1284
				input.fire.pressed = false -- 1285
			end -- 1285
		else -- 1285
			local navDelta = p.talentModalActive and ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) or 0 -- 1288
			local totalDelta = navDelta ~= 0 and navDelta or input.talentDelta -- 1291
			if totalDelta ~= 0 then -- 1291
				fe.hud.talentSelected = (fe.hud.talentSelected + totalDelta + #offers) % #offers -- 1293
				input.talentDelta = 0 -- 1294
			end -- 1294
			if input.talentConfirm or p.talentModalActive and input.navConfirm then -- 1294
				p:chooseTalent(fe.hud.talentSelected) -- 1297
				input.talentConfirm = false -- 1298
				input.fire.pressed = false -- 1299
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1299
				input.fire.pressed = false -- 1302
			end -- 1302
		end -- 1302
	end -- 1302
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1302
		if input.navConfirm then -- 1302
			input.interact.pressed = true -- 1310
		end -- 1310
		local towerMouseContinue = input.inputMode ~= "gamepad" and (input.uiPressed or input.fire.pressed) -- 1312
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed or input.retryTapPressed or towerMouseContinue) then -- 1312
			flushProfile() -- 1314
			if p.run.source == "official" and hasSessionSave() then -- 1314
				clearSession() -- 1316
				refreshTitleSessionFlag() -- 1317
			end -- 1317
			fe.audio:stopRoomTransient() -- 1319
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1320
			fe.screen = "epilogue" -- 1324
			input:clearTransient(true) -- 1325
			input:consumeEdges() -- 1326
			return -- 1327
		end -- 1327
	end -- 1327
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1327
		p:closeCraftBench() -- 1332
		input:consumeEdges() -- 1333
		return -- 1334
	end -- 1334
	if not p.paused and not p.escortFailed and fe:tryClickHudPause(p, input, stageVp.stageW, stageVp.stageH) then -- 1334
		input.pause.pressed = true -- 1337
		input.fire.pressed = false -- 1338
		input.fire.held = false -- 1339
		input.uiPressed = false -- 1340
	end -- 1340
	if not p.paused and not p.escortFailed and input.pause.pressed then -- 1340
		p.paused = true -- 1343
		p.aimHold = 0 -- 1344
		p.bottleAimX = -1 -- 1345
		saveCurrentSession() -- 1346
		fe.menus:openPause() -- 1347
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1348
		input:clearTransient(true) -- 1349
		input:consumeEdges() -- 1350
	end -- 1350
	if p.paused then -- 1350
		clock:reset() -- 1355
		local pauseAct = fe:renderPlay( -- 1356
			frameDt, -- 1356
			p, -- 1356
			input, -- 1356
			stageVp.stageW, -- 1356
			stageVp.stageH -- 1356
		) -- 1356
		input:consumeEdges() -- 1357
		if pauseAct.type == "resume" then -- 1357
			p.paused = false -- 1359
		elseif pauseAct.type == "retry" then -- 1359
			if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1359
				p:restartEscortRun() -- 1362
				applyRoomTransition(p) -- 1363
			else -- 1363
				ensurePlay({checkpoint = p.checkpoint}) -- 1365
			end -- 1365
		elseif pauseAct.type == "openChapters" then -- 1365
			fe.audio:stopRoomTransient() -- 1368
			fe.audio:setPaused(false) -- 1369
			fe.menus:openChapters(current) -- 1370
			fe.screen = "chapters" -- 1371
		elseif pauseAct.type == "toggleFullscreen" then -- 1371
			toggleFullscreen() -- 1373
		elseif pauseAct.type == "saveSlot" and pauseAct.slot ~= nil then -- 1373
			saveToManualSlot(pauseAct.slot) -- 1375
		elseif pauseAct.type == "loadSlot" and pauseAct.slot ~= nil then -- 1375
			if loadOfficialSlot(pauseAct.slot) ~= nil then -- 1375
				fe:showToast( -- 1378
					"已读取" .. slotDisplayName(pauseAct.slot), -- 1378
					2 -- 1378
				) -- 1378
			else -- 1378
				fe:showToast("读取存档失败", 2.2) -- 1380
			end -- 1380
		elseif pauseAct.type == "deleteSlot" and pauseAct.slot ~= nil then -- 1380
			deleteSaveSlotById(pauseAct.slot) -- 1383
		elseif pauseAct.type == "quit" then -- 1383
			quitGame() -- 1385
		elseif pauseAct.type == "toTitle" then -- 1385
			saveCurrentSession() -- 1387
			refreshTitleSessionFlag() -- 1388
			fe.menus:resetInput() -- 1389
			fe.screen = "title" -- 1390
		end -- 1390
		return -- 1392
	end -- 1392
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1395
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1396
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and not p.talentModalActive then -- 1396
		input:consumeEdges() -- 1399
		if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1399
			p:restartEscortRun() -- 1402
			applyRoomTransition(p) -- 1403
		else -- 1403
			ensurePlay({checkpoint = p.checkpoint}) -- 1406
		end -- 1406
		return -- 1408
	end -- 1408
	local worldPromptClick = fe:tryClickWorldPrompt(p, input, stageVp.stageW, stageVp.stageH) -- 1411
	if worldPromptClick == "tap" then -- 1411
		input.interact.pressed = true -- 1413
		input.interact.held = true -- 1414
		input.frameInteractPressed = true -- 1415
		input.fire.pressed = false -- 1416
		input.fire.held = false -- 1417
	elseif worldPromptClick == "hold" then -- 1417
		if input.uiPressed or input.fire.pressed then -- 1417
			input.interact.pressed = true -- 1420
			input.frameInteractPressed = true -- 1421
		end -- 1421
		input.interact.held = true -- 1423
		input.fire.pressed = false -- 1424
		input.fire.held = false -- 1425
	end -- 1425
	local steps = clock:advance(frameDt) -- 1428
	local i = 0 -- 1429
	do -- 1429
		i = 0 -- 1430
		while i < steps do -- 1430
			input:beginStep(i == 0) -- 1431
			p:update(STEP, input) -- 1432
			input:endStep() -- 1433
			if p.wantRoom ~= "" then -- 1433
				break -- 1435
			end -- 1435
			i = i + 1 -- 1430
		end -- 1430
	end -- 1430
	if applyRoomTransition(p) then -- 1430
		return -- 1441
	end -- 1441
	flushProfile() -- 1445
	if p.run.source == "official" and not p.paused and not p.run.finished then -- 1445
		runPlaySeconds = runPlaySeconds + math.min( -- 1447
			0.1, -- 1447
			math.max(0, frameDt) -- 1447
		) -- 1447
		autosaveTimer = autosaveTimer + math.min( -- 1448
			0.1, -- 1448
			math.max(0, frameDt) -- 1448
		) -- 1448
		if autosaveCooldown > 0 then -- 1448
			autosaveCooldown = math.max(0, autosaveCooldown - frameDt) -- 1450
		end -- 1450
	end -- 1450
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1450
		clearSession() -- 1454
		refreshTitleSessionFlag() -- 1455
	elseif p.sessionDirty then -- 1455
		saveCurrentSession() -- 1457
	elseif canSaveSession() and autosaveCooldown <= 0 then -- 1457
		local sig = sessionMilestoneSignature(p) -- 1459
		if lastAutosaveSig == "" then -- 1459
			lastAutosaveSig = sig -- 1461
		elseif sig ~= lastAutosaveSig or autosaveTimer >= 20 then -- 1461
			saveCurrentSession() -- 1463
		end -- 1463
	end -- 1463
	fe:renderPlay( -- 1466
		frameDt, -- 1466
		p, -- 1466
		input, -- 1466
		stageVp.stageW, -- 1466
		stageVp.stageH -- 1466
	) -- 1466
end -- 1466
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
local function isReleaseBuild() -- 60
	return isReleaseMode() -- 61
end -- 60
local function handleBackButton() -- 150
	if fe == nil then -- 150
		return -- 152
	end -- 152
	if fe.screen == "splash" then -- 152
		fe.menus:resetSplash() -- 155
		fe.screen = "title" -- 156
		fe.menus:resetInput() -- 157
		return -- 158
	end -- 158
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "saves" or fe.screen == "settings" or fe.screen == "epilogue" or fe.screen == "history" then -- 158
		fe.menus:triggerBack() -- 161
		return -- 162
	end -- 162
	if fe.screen == "title" then -- 162
		if not canQuitApp() then -- 162
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 166
			return -- 167
		end -- 167
		if appClock - lastBackPressClock <= 2 then -- 167
			quitGame() -- 170
		else -- 170
			lastBackPressClock = appClock -- 172
			fe:showToast("再按一次返回退出游戏", 2) -- 173
		end -- 173
		return -- 175
	end -- 175
	if fe.screen == "play" and play ~= nil then -- 175
		if play.escortFailed then -- 175
			fe.audio:stopRoomTransient() -- 179
			fe.menus:resetInput() -- 180
			fe.screen = "title" -- 181
			if input ~= nil then -- 181
				input:clearTransient(true) -- 182
			end -- 182
			return -- 183
		end -- 183
		if fe.roguelikeUi:isLedgerOpen() then -- 183
			fe.roguelikeUi:closeLedger() -- 186
			return -- 187
		end -- 187
		if play.paused then -- 187
			fe.menus:triggerBack() -- 190
			return -- 191
		end -- 191
		if play.craftBench.active then -- 191
			play:closeCraftBench() -- 194
			return -- 195
		end -- 195
		play.paused = true -- 197
		play.aimHold = 0 -- 198
		play.bottleAimX = -1 -- 199
		saveCurrentSession() -- 200
		fe.menus:openPause() -- 201
		if input ~= nil then -- 201
			input:clearTransient(true) -- 202
		end -- 202
	end -- 202
end -- 150
--- Windows 窗口右上角「×」拦截状态机：
-- - 单次点击：局内自动存档并弹出 ESC 暂歇菜单；若已在暂歇/标题页则将光标聚焦至「退出游戏」；
-- - 2 秒内连续点击 4 次：立即安全落盘并强制退出（原生 C++ 渲染线程亦同步计数兜底，主循环卡死也可强退）。
local function handleWindowClose(nativeCount) -- 211
	local count = nativeCount ~= nil and nativeCount > 0 and math.floor(nativeCount) or 1 -- 213
	if count >= WINDOW_CLOSE_FORCE_COUNT or fe == nil then -- 213
		quitGame() -- 215
		return -- 216
	end -- 216
	local remain = math.max(1, WINDOW_CLOSE_FORCE_COUNT - count) -- 219
	if fe.screen == "splash" then -- 219
		fe.menus:resetSplash() -- 221
		fe.screen = "title" -- 222
		fe.menus:focusQuit("title") -- 223
		fe:showToast( -- 224
			("已跳过片头 · 再连点关闭 " .. tostring(remain)) .. " 次可强制退出", -- 224
			2.6 -- 224
		) -- 224
		return -- 225
	end -- 225
	if fe.screen == "play" and play ~= nil then -- 225
		if fe.roguelikeUi:isLedgerOpen() then -- 225
			fe.roguelikeUi:closeLedger() -- 229
		end -- 229
		if not play.paused then -- 229
			if play.craftBench.active then -- 229
				play:closeCraftBench() -- 233
			end -- 233
			play.paused = true -- 235
			play.aimHold = 0 -- 236
			play.bottleAimX = -1 -- 237
			saveCurrentSession() -- 238
			fe.menus:openPause() -- 239
			fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 240
			if input ~= nil then -- 240
				input:clearTransient(true) -- 241
			end -- 241
			syncPowerMode() -- 242
			fe:showToast( -- 243
				("已暂歇并自动存档 · 如需强制退出请连点关闭（还差 " .. tostring(remain)) .. " 次）", -- 243
				3 -- 243
			) -- 243
			return -- 244
		end -- 244
		fe.menus:focusQuit("play") -- 246
		fe.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 247
		fe:showToast( -- 248
			("点击「退出游戏」安全退出 · 连点关闭还差 " .. tostring(remain)) .. " 次强制退出", -- 248
			2.6 -- 248
		) -- 248
		return -- 249
	end -- 249
	if fe.screen == "title" then -- 249
		fe.menus:focusQuit("title") -- 252
		fe.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 253
		fe:showToast( -- 254
			("点击「退出游戏」安全退出 · 连点关闭还差 " .. tostring(remain)) .. " 次强制退出", -- 254
			2.6 -- 254
		) -- 254
		return -- 255
	end -- 255
	fe.screen = "title" -- 257
	fe.menus:focusQuit("title") -- 258
	fe.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 259
	fe:showToast( -- 260
		("已返回标题 · 点击「退出游戏」或再连点关闭 " .. tostring(remain)) .. " 次强制退出", -- 260
		2.6 -- 260
	) -- 260
end -- 211
function ____exports.start(parent, _initialMode, startScreen) -- 546
	if _initialMode == nil then -- 546
		_initialMode = 1 -- 546
	end -- 546
	if startScreen == nil then -- 546
		startScreen = "title" -- 546
	end -- 546
	root = parent -- 547
	local loaded = loadSave() -- 551
	profile = loaded.state -- 552
	profileStatus = loaded.status -- 553
	profileDetail = loaded.detail -- 554
	fe = __TS__New(WatchFrontend, parent) -- 555
	fe.screen = startScreen -- 556
	if startScreen == "splash" then -- 556
		fe.menus:resetSplash() -- 558
	end -- 558
	refreshTitleSessionFlag() -- 560
	fe:setVisible(true) -- 561
	input = __TS__New(Input) -- 563
	fe.audio:applyUserVolumes(input.settings) -- 564
	fe.contract:setAssistHintsEnabled(input.settings.assistHints) -- 565
	if input.settings.muted then -- 565
		fe.audio:setAllMuted(true) -- 567
	end -- 567
	fe.menus.onToggleFullscreen = function() -- 569
		toggleFullscreen() -- 570
	end -- 569
	if isDesktopNative() and canToggleFullscreen() and testViewportOverride == nil then -- 569
		do -- 569
			pcall(function() -- 569
				if input.settings.fullscreen then -- 569
					if not App.fullScreen then -- 569
						App.fullScreen = true -- 577
					end -- 577
				elseif input.settings.winWidth >= 640 and input.settings.winHeight >= 360 then -- 577
					local curSize = App.winSize -- 580
					if math.abs(curSize.width - input.settings.winWidth) > 2 or math.abs(curSize.height - input.settings.winHeight) > 2 then -- 580
						App.winSize = Size(input.settings.winWidth, input.settings.winHeight) -- 583
					end -- 583
				end -- 583
			end) -- 583
		end -- 583
	end -- 583
	windowFocused = true -- 590
	lastAppliedIdle = nil -- 591
	startupNoticeShown = false -- 592
	syncPowerMode() -- 593
	input:attach( -- 594
		parent, -- 594
		{ -- 594
			onFirstUserGesture = function() -- 595
				onFirstUserGesture() -- 596
				if input ~= nil then -- 596
					input:markKeyboardActivity() -- 597
				end -- 597
			end, -- 595
			onToggleFullscreen = function() -- 599
				toggleFullscreen() -- 600
			end, -- 599
			onKeyDownEvent = function(____, key) -- 602
				if (fe and fe.screen) == "play" and play ~= nil and not play.paused then -- 602
					if key == "1" or key == "2" or key == "3" then -- 602
						if input ~= nil then -- 602
							input:requestPickRoom(__TS__Number(key)) -- 605
						end -- 605
						return -- 606
					end -- 606
					if key == "T" and not play.escortFailed and not play.talentModalActive and not fe.roguelikeUi:isLedgerOpen() then -- 606
						play:toggleArtifactWeapon() -- 609
						return -- 610
					end -- 610
				end -- 610
				local inPausedPlay = fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 613
				if fe ~= nil and (fe.screen ~= "play" or inPausedPlay) then -- 613
					fe.menus:onKeyEvent(key) -- 615
				end -- 615
				if input ~= nil and (fe ~= nil and fe.screen == "play" and not inPausedPlay) then -- 615
					if key == "E" then -- 615
						input.interact.pressed = true -- 619
					elseif key == "Space" then -- 619
						input.jump.pressed = true -- 621
					elseif key == "Escape" then -- 621
						input.pause.pressed = true -- 623
					end -- 623
				end -- 623
			end -- 602
		} -- 602
	) -- 602
	parent:gslot( -- 630
		"AppChange", -- 630
		function(settingName) -- 630
			if input == nil or not isDesktopNative() then -- 630
				return -- 632
			end -- 632
			if settingName == "FullScreen" then -- 632
				do -- 632
					pcall(function() -- 632
						input.settings.fullscreen = App.fullScreen -- 636
						saveControlSettings(input.settings) -- 637
					end) -- 637
				end -- 637
			elseif settingName == "Size" then -- 637
				pendingWinSizeSaveTimer = 0.45 -- 642
			end -- 642
		end -- 630
	) -- 630
	parent:gslot( -- 647
		"AppEvent", -- 647
		function(eventType, payload) -- 647
			if eventType == "BackButton" then -- 647
				handleBackButton() -- 649
				return -- 650
			end -- 650
			if eventType == "WindowClose" then -- 650
				handleWindowClose(type(payload) == "number" and payload or nil) -- 653
				return -- 654
			end -- 654
			if eventType == "Quit" or eventType == "Shutdown" then -- 654
				flushProfile() -- 657
				saveCurrentSession() -- 658
				if input ~= nil then -- 658
					input:clearTransient(false) -- 659
				end -- 659
				return -- 660
			end -- 660
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 660
				windowFocused = false -- 663
				flushProfile() -- 664
				saveCurrentSession() -- 665
				if input ~= nil then -- 665
					input:clearTransient(true) -- 666
				end -- 666
				if fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.escortFailed then -- 666
					play.paused = true -- 668
					play.aimHold = 0 -- 669
					play.bottleAimX = -1 -- 670
					fe.menus:openPause() -- 671
				end -- 671
				if fe ~= nil then -- 671
					fe.audio:setPaused(true) -- 674
				end -- 674
				syncPowerMode() -- 676
				return -- 677
			end -- 677
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 677
				windowFocused = true -- 680
				if fe ~= nil then -- 680
					local paused = play ~= nil and play.paused and fe.screen == "play" -- 682
					fe.audio:setPaused(paused) -- 683
				end -- 683
				syncPowerMode() -- 685
			end -- 685
		end -- 647
	) -- 647
	viewW = View.size.width -- 689
	viewH = View.size.height -- 690
	applySize() -- 691
	local reg = _G.package.loaded -- 694
	reg["watch.input"] = input -- 695
	reg["watch.touch"] = input:getTouchRouter() -- 696
	reg["watch.gamepad"] = input:getGamepadRouter() -- 697
	reg["watch.fe"] = { -- 698
		setScreen = function(sc) -- 699
			if fe == nil then -- 699
				return -- 701
			end -- 701
			clock:reset() -- 703
			fe.screen = sc -- 704
			if sc == "splash" then -- 704
				fe.menus:resetSplash() -- 706
			elseif sc == "chapters" then -- 706
				fe.menus:openChapters() -- 708
			elseif sc == "epilogue" then -- 708
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 710
			elseif sc == "history" then -- 710
				fe.menus:openHistory(false) -- 715
			else -- 715
				fe.menus:resetInput() -- 717
			end -- 717
			if sc == "play" then -- 717
				ensurePlay() -- 720
			end -- 720
		end, -- 699
		jumpRoom = function(keyOrIdx) -- 723
			local idx = -1 -- 724
			if type(keyOrIdx) == "number" then -- 724
				idx = keyOrIdx -- 726
			else -- 726
				local k = 0 -- 728
				do -- 728
					k = 0 -- 729
					while k < #ROOMS do -- 729
						if ROOMS[k + 1].key == keyOrIdx then -- 729
							idx = k -- 731
						end -- 731
						k = k + 1 -- 729
					end -- 729
				end -- 729
			end -- 729
			if idx >= 0 and idx < #ROOMS then -- 729
				enterPlayRoom(idx, "debug") -- 736
			end -- 736
		end, -- 723
		getPlay = function() return play end, -- 739
		getFrontend = function() return fe end, -- 740
		startStory = function(seed) -- 742
			enterPlayRoom( -- 743
				officialStartIndex(), -- 743
				"official", -- 743
				true, -- 743
				seed -- 743
			) -- 743
			return play -- 744
		end, -- 742
		previewChapter = function(idx, routeOrSeed, seed) -- 747
			enterPlayRoom( -- 748
				idx, -- 748
				"chapter", -- 748
				false, -- 748
				type(routeOrSeed) == "number" and routeOrSeed or seed, -- 748
				type(routeOrSeed) == "string" and routeOrSeed or nil -- 749
			) -- 749
			return play -- 750
		end, -- 747
		getStoryRun = function() return storyRun end, -- 752
		getProfilePending = function() return profilePending() end, -- 753
		flushProfileNow = function() return flushProfile() end, -- 754
		getProfile = function() return profile end, -- 756
		getProfileStatus = function() return profileStatus end, -- 757
		getProfileDetail = function() return profileDetail end, -- 758
		useTestSave = function(name) -- 759
			setSaveFile(name) -- 760
			setSessionFile(name == "" and "" or name .. ".session") -- 761
			clearProfilePending() -- 762
			local loaded = loadSave() -- 763
			profile = loaded.state -- 764
			profileStatus = loaded.status -- 765
			profileDetail = loaded.detail -- 766
			refreshTitleSessionFlag() -- 767
		end, -- 759
		useTestSession = function(name) -- 769
			setSessionFile(name) -- 770
			refreshTitleSessionFlag() -- 771
		end, -- 769
		getSessionFile = getSessionFile, -- 773
		hasSessionSave = hasSessionSave, -- 774
		saveSessionNow = function() return saveCurrentSession() end, -- 775
		clearSessionNow = function() -- 776
			local ok = clearSession() -- 777
			refreshTitleSessionFlag() -- 778
			return ok -- 779
		end, -- 776
		continueStory = function() return continueOfficialStory() end, -- 781
		listSaveSlots = function() return listSaveSlots() end, -- 782
		saveToSlot = function(slot) return saveToManualSlot(slot) end, -- 783
		loadFromSlot = function(slot) return loadOfficialSlot(slot) end, -- 784
		deleteSlot = function(slot) return deleteSaveSlotById(slot) end, -- 785
		canSaveSession = function() return canSaveSession() end, -- 786
		saveNow = function() return saveSave(profile) end, -- 787
		getSaveFile = getSaveFile, -- 788
		isRelease = function() return isReleaseBuild() end, -- 789
		getReleaseVersion = function() -- 790
			local ____opt_37 = getReleaseConfig() -- 790
			return ____opt_37 and ____opt_37.version or "dev" -- 790
		end, -- 790
		toggleFullscreen = function() return toggleFullscreen() end, -- 791
		quitGame = function() return quitGame() end, -- 792
		handleBackButton = function() return handleBackButton() end, -- 793
		getViewport = function() return stageVp end, -- 794
		getTargetId = function() return getActiveTarget().id end, -- 795
		getTouchController = function() return input and input:getTouchControls() end, -- 796
		getTouchRouter = function() return input and input:getTouchRouter() end, -- 797
		getGamepad = function() return input and input:getGamepadRouter() end, -- 798
		setGamepadSim = function(state) -- 799
			if input ~= nil then -- 799
				input:setGamepadSim(state) -- 800
			end -- 800
		end, -- 799
		injectTouch = function(phase, id, x, y, fromMouse) -- 802
			if input ~= nil then -- 802
				input:injectTouch( -- 803
					phase, -- 803
					id, -- 803
					x, -- 803
					y, -- 803
					fromMouse -- 803
				) -- 803
			end -- 803
		end, -- 802
		getInputMode = function() return input and input.inputMode or getActiveTarget().defaultInputMode end, -- 805
		setInputMode = function(m) -- 806
			if input ~= nil then -- 806
				input:setInputMode(m) -- 807
			end -- 807
		end, -- 806
		setModePref = function(pref) -- 809
			if input ~= nil then -- 809
				input:setModePref(pref) -- 810
			end -- 810
		end, -- 809
		applyViewportForTest = function(w, h) -- 812
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 812
				testViewportOverride = {w = w, h = h} -- 814
				viewW = w -- 815
				viewH = h -- 816
			else -- 816
				testViewportOverride = nil -- 818
				viewW = View.size.width -- 819
				viewH = View.size.height -- 820
			end -- 820
			applySize() -- 822
			return stageVp -- 823
		end, -- 812
		getToast = function() return fe and fe:getToastText() or "" end -- 825
	} -- 825
	if startScreen == "play" then -- 825
		ensurePlay() -- 829
	end -- 829
	parent:schedule(function(frameDt) -- 832
		tick(frameDt) -- 833
		return false -- 834
	end) -- 832
end -- 546
return ____exports -- 546