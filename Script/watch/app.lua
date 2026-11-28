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
function randomRunSeed() -- 55
	return math.max( -- 56
		1, -- 56
		math.floor(math.abs(App.rand)) % 2147483646 -- 56
	) -- 56
end -- 56
function syncPowerMode() -- 63
	if not isDesktopNative() then -- 63
		return -- 65
	end -- 65
	local wantIdle = not windowFocused or fe == nil or fe.screen ~= "play" or play ~= nil and play.paused -- 67
	if lastAppliedIdle == wantIdle then -- 67
		return -- 72
	end -- 72
	lastAppliedIdle = wantIdle -- 74
	do -- 74
		pcall(function() -- 74
			App.idled = wantIdle -- 76
		end) -- 76
	end -- 76
end -- 76
function onFirstUserGesture() -- 82
	if audioUnlocked or fe == nil then -- 82
		return -- 84
	end -- 84
	audioUnlocked = true -- 86
	fe.audio:unlockAndResyncAfterGesture() -- 87
end -- 87
function toggleFullscreen() -- 90
	if not canToggleFullscreen() then -- 90
		return false -- 92
	end -- 92
	do -- 92
		local function ____catch() -- 92
			return true, false -- 103
		end -- 103
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 103
			local next = not App.fullScreen -- 95
			App.fullScreen = next -- 96
			if input ~= nil then -- 96
				input.settings.fullscreen = next -- 98
				saveControlSettings(input.settings) -- 99
			end -- 99
			return true, next -- 101
		end) -- 101
		if not ____try then -- 101
			____hasReturned, ____returnValue = ____catch() -- 101
		end -- 101
		if ____hasReturned then -- 101
			return ____returnValue -- 94
		end -- 94
	end -- 94
end -- 94
function slotDisplayName(slot) -- 107
	if slot == "auto" then -- 107
		return "自动存档" -- 108
	end -- 108
	if slot == 1 then -- 108
		return "档案一" -- 109
	end -- 109
	if slot == 2 then -- 109
		return "档案二" -- 110
	end -- 110
	return "档案三" -- 111
end -- 111
function quitGame() -- 114
	flushProfile() -- 115
	saveCurrentSession() -- 116
	if input ~= nil and isDesktopNative() then -- 116
		do -- 116
			pcall(function() -- 116
				input.settings.fullscreen = App.fullScreen -- 119
				if not App.fullScreen then -- 119
					local ws = App.winSize -- 121
					if ws.width >= 640 and ws.height >= 360 then -- 121
						input.settings.winWidth = math.floor(ws.width + 0.5) -- 123
						input.settings.winHeight = math.floor(ws.height + 0.5) -- 124
					end -- 124
				end -- 124
				saveControlSettings(input.settings) -- 127
			end) -- 127
		end -- 127
	end -- 127
	if input ~= nil then -- 127
		input:clearTransient(false) -- 132
	end -- 132
	if fe ~= nil then -- 132
		fe.audio:stopRoomTransient() -- 134
	end -- 134
	if not canQuitApp() then -- 134
		current = 0 -- 138
		play = nil -- 139
		clock:reset() -- 140
		if fe ~= nil then -- 140
			fe.audio:stopRoomTransient() -- 142
			fe.screen = "title" -- 143
			fe.menus:resetInput() -- 144
		end -- 144
		return -- 146
	end -- 146
	App:shutdown() -- 148
end -- 148
function canSaveSession() -- 207
	if play == nil or storyRun == nil then -- 207
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
		local has = hasSessionSave() -- 222
		fe.menus.hasSession = has -- 223
		if has then -- 223
			local loaded = loadSession() -- 225
			fe.menus:setSessionRoomKey(loaded.status == "ok" and loaded.state ~= nil and loaded.state.roomKey or "") -- 226
		else -- 226
			fe.menus:setSessionRoomKey("") -- 228
		end -- 228
		fe.menus:refreshSaveSlots() -- 230
	end -- 230
end -- 230
function exportSessionWithMeta() -- 234
	if play == nil then -- 234
		return nil -- 236
	end -- 236
	local snap = play:exportSession() -- 238
	snap.savedAt = nowUnixSeconds() -- 239
	snap.playSeconds = math.max( -- 240
		0, -- 240
		math.floor(runPlaySeconds) -- 240
	) -- 240
	return snap -- 241
end -- 241
function sessionMilestoneSignature(p) -- 244
	local inv = p.run.inventory -- 245
	local takenCount = 0 -- 246
	for k in pairs(p.run.taken) do -- 247
		if p.run.taken[k] == true then -- 247
			takenCount = takenCount + 1 -- 248
		end -- 248
	end -- 248
	local segCount = 0 -- 250
	for k in pairs(p.run.story.segments) do -- 251
		if p.run.story.segments[k] == true then -- 251
			segCount = segCount + 1 -- 252
		end -- 252
	end -- 252
	return (((((((((((((((((((((((((((((p.room.key .. "|") .. tostring(p.checkpoint)) .. "|") .. p.phase) .. "|") .. tostring(p.run.story.hp)) .. "|") .. p.run.story.route) .. "|") .. tostring(inv.wood)) .. ":") .. tostring(inv.bell)) .. ":") .. tostring(inv.scrap)) .. ":") .. tostring(inv.wedge)) .. ":") .. tostring(inv.ammo)) .. "|") .. tostring(takenCount)) .. ":") .. tostring(segCount)) .. "|") .. (p.cartDocked and "1" or "0")) .. "|") .. (p.hasBottle and "1" or "0")) .. "|") .. (p.passed and "1" or "0")) .. "|") .. p.equippedWeapon -- 254
end -- 254
function saveCurrentSession() -- 267
	if not canSaveSession() or play == nil then -- 267
		return false -- 269
	end -- 269
	local snap = exportSessionWithMeta() -- 271
	if snap == nil then -- 271
		return false -- 273
	end -- 273
	local ok = saveSession(snap) -- 275
	play.sessionDirty = not ok -- 276
	if ok then -- 276
		autosaveTimer = 0 -- 278
		autosaveCooldown = 2.5 -- 279
		lastAutosaveSig = sessionMilestoneSignature(play) -- 280
	end -- 280
	refreshTitleSessionFlag() -- 282
	return ok -- 283
end -- 283
function saveToManualSlot(slot) -- 286
	if not canSaveSession() or play == nil then -- 286
		if fe ~= nil then -- 286
			fe:showToast("当前段落无法手动存档", 2) -- 288
		end -- 288
		return false -- 289
	end -- 289
	local snap = exportSessionWithMeta() -- 291
	if snap == nil then -- 291
		return false -- 293
	end -- 293
	local ok = saveSlot(slot, snap) -- 295
	refreshTitleSessionFlag() -- 296
	if ok then -- 296
		if fe ~= nil then -- 296
			fe:showToast( -- 298
				"已保存至" .. slotDisplayName(slot), -- 298
				2 -- 298
			) -- 298
		end -- 298
	else -- 298
		if fe ~= nil then -- 298
			fe:showToast("保存失败，请检查目录写权限", 2.4) -- 300
		end -- 300
	end -- 300
	return ok -- 302
end -- 302
function deleteSaveSlotById(slot) -- 305
	local ok = deleteSlot(slot) -- 306
	refreshTitleSessionFlag() -- 307
	if fe ~= nil then -- 307
		fe:showToast( -- 308
			ok and "已删除" .. slotDisplayName(slot) or "删除存档失败", -- 308
			2 -- 308
		) -- 308
	end -- 308
	return ok -- 309
end -- 309
function continueOfficialStory() -- 312
	return loadOfficialSlot("auto") -- 313
end -- 313
function loadOfficialSlot(slot) -- 316
	if slot == "auto" and (play and play.escortFailed) and play.run.source == "official" and play.sessionDirty then -- 316
		play:confirmEscortRestart() -- 319
		applyRoomTransition(play) -- 320
		if fe ~= nil then -- 320
			fe.screen = "play" -- 321
		end -- 321
		return play -- 322
	end -- 322
	local res = loadSlot(slot) -- 324
	if res.status ~= "ok" or res.state == nil then -- 324
		refreshTitleSessionFlag() -- 326
		return nil -- 327
	end -- 327
	local s = res.state -- 329
	local idx = roomIndexByKey(s.roomKey) -- 330
	if ROOMS[idx + 1].key ~= s.roomKey then -- 330
		return nil -- 332
	end -- 332
	runPlaySeconds = math.max(0, s.playSeconds or 0) -- 334
	autosaveTimer = 0 -- 335
	autosaveCooldown = 2.5 -- 336
	lastAutosaveSig = "" -- 337
	storyRun = createRun(s.seed, "official", profile) -- 338
	storyRun.checkpoint = s.checkpoint -- 339
	storyRun.story.route = s.route -- 340
	storyRun.story.hp = s.hp -- 341
	storyRun.story.maxHp = s.maxHp -- 342
	storyRun.story.hpAtGate = s.hpAtGate -- 343
	storyRun.story.maxHpAtGate = s.maxHpAtGate -- 344
	storyRun.story.settled = s.settled -- 345
	storyRun.story.phase = s.phase -- 346
	storyRun.story.countTick = s.countTick -- 347
	storyRun.story.phaseTick = s.phaseTick -- 348
	storyRun.story.handTicks = s.handTicks -- 349
	storyRun.story.handDone = s.handDone -- 350
	storyRun.story.lineSaid = s.lineSaid -- 351
	storyRun.story.tied = s.tied -- 352
	storyRun.story.carry = s.carry -- 353
	storyRun.story.escortDone = s.escortDone -- 354
	storyRun.story.craftedWeapon = s.craftedWeapon -- 355
	storyRun.story.equippedWeapon = s.equippedWeapon -- 356
	storyRun.inventory.wood = s.wood -- 357
	storyRun.inventory.bell = s.bell -- 358
	storyRun.inventory.scrap = s.scrap -- 359
	storyRun.inventory.wedge = s.wedge -- 360
	storyRun.inventory.ammo = s.ammo -- 361
	storyRun.inventory.shield = s.shield -- 362
	storyRun.inventory.pass = s.pass -- 363
	storyRun.inventory.quickbelt = s.quickbelt -- 364
	local k = 0 -- 365
	do -- 365
		k = 0 -- 366
		while k < #s.taken do -- 366
			storyRun.taken[s.taken[k + 1]] = true -- 367
			k = k + 1 -- 366
		end -- 366
	end -- 366
	do -- 366
		k = 0 -- 369
		while k < #s.segments do -- 369
			storyRun.story.segments[s.segments[k + 1]] = true -- 370
			k = k + 1 -- 369
		end -- 369
	end -- 369
	if s.campaignRoute ~= nil then -- 369
		storyRun.route = s.campaignRoute -- 373
	end -- 373
	if s.joined ~= nil then -- 373
		storyRun.joined = s.joined -- 376
	end -- 376
	if s.c1Latch ~= nil then -- 376
		storyRun.c1Latch = s.c1Latch -- 379
	end -- 379
	if s.c2Latch ~= nil then -- 379
		storyRun.c2Latch = s.c2Latch -- 382
	end -- 382
	if s.props ~= nil then -- 382
		do -- 382
			k = 0 -- 385
			while k < #s.props do -- 385
				local parts = __TS__StringSplit(s.props[k + 1], ":") -- 386
				local pid = parts[1] -- 387
				if pid ~= nil and pid ~= "" then -- 387
					local ____storyRun_props_20 = storyRun.props -- 389
					local ____temp_16 -- 390
					if parts[2] == nil then -- 390
						____temp_16 = true -- 390
					else -- 390
						____temp_16 = parts[2] == "1" -- 390
					end -- 390
					local ____temp_18 = parts[3] == nil and 0 or (tonumber(parts[3]) or 0) -- 391
					local ____temp_19 = parts[4] == "1" -- 392
					local ____temp_17 -- 393
					if parts[5] == "1" then -- 393
						____temp_17 = true -- 393
					else -- 393
						____temp_17 = nil -- 393
					end -- 393
					____storyRun_props_20[pid] = {broken = ____temp_16, hp = ____temp_18, wedge = ____temp_19, revealed = ____temp_17} -- 389
				end -- 389
				k = k + 1 -- 385
			end -- 385
		end -- 385
	end -- 385
	local stTalents = createStoryTalents(s.seed) -- 398
	if s.talentSeed ~= nil and s.talentSeed > 0 then -- 398
		stTalents.randomState = s.talentSeed -- 400
	end -- 400
	if s.escortAttempt ~= nil and s.escortAttempt >= 1 then -- 400
		stTalents.attempt = s.escortAttempt -- 403
	end -- 403
	if s.escortVariant ~= nil and s.escortVariant >= 0 then -- 403
		stTalents.variant = s.escortVariant -- 406
	end -- 406
	stTalents.deferred = s.talentDeferred == true -- 408
	stTalents.room = s.talentRoom or "" -- 409
	if s.talentRanks ~= nil and #s.talentRanks > 0 then -- 409
		do -- 409
			k = 0 -- 411
			while k < #s.talentRanks do -- 411
				local parts = __TS__StringSplit(s.talentRanks[k + 1], ":") -- 412
				local ____temp_21 -- 413
				if parts[1] ~= nil then -- 413
					____temp_21 = normalizeLegacyTalent(parts[1]) -- 413
				else -- 413
					____temp_21 = nil -- 413
				end -- 413
				local norm = ____temp_21 -- 413
				local rk = parts[2] ~= nil and (tonumber(parts[2]) or 0) or 0 -- 414
				if norm ~= nil and rk > 0 then -- 414
					stTalents.ranks[norm] = (stTalents.ranks[norm] or 0) + math.floor(rk) -- 416
				end -- 416
				k = k + 1 -- 411
			end -- 411
		end -- 411
	else -- 411
		stTalents.ranks.vitality = s.talentVitality or 0 -- 421
		stTalents.ranks.focus = s.talentReload or 0 -- 422
		stTalents.ranks.guard = s.talentGuard or 0 -- 423
		stTalents.ranks.salvage = s.talentCraft or 0 -- 424
	end -- 424
	if s.talentOffers ~= nil then -- 424
		do -- 424
			k = 0 -- 427
			while k < #s.talentOffers do -- 427
				local norm = normalizeLegacyTalent(s.talentOffers[k + 1]) -- 428
				if norm ~= nil then -- 428
					local ____stTalents_offers_22 = stTalents.offers -- 428
					____stTalents_offers_22[#____stTalents_offers_22 + 1] = norm -- 430
				end -- 430
				k = k + 1 -- 427
			end -- 427
		end -- 427
	end -- 427
	storyRun.story.talents = stTalents -- 434
	current = idx -- 435
	clock:reset() -- 436
	if fe ~= nil then -- 436
		fe.screen = "play" -- 438
	end -- 438
	play = nil -- 440
	ensurePlay(s.checkpoint > 0 and ({checkpoint = s.checkpoint}) or nil) -- 441
	local cur = play -- 442
	if cur ~= nil then -- 442
		if s.cartAxle > 0 and cur.room.cart.bodyW > 0 then -- 442
			cur.cartAxle = s.cartAxle -- 445
			cur.cartDocked = s.cartDocked -- 446
		end -- 446
		if s.playerX ~= nil and s.playerX >= 0 then -- 446
			cur.player.x = math.max( -- 449
				cur.room.minX + 16, -- 449
				math.min(cur.room.maxX - 16, s.playerX) -- 449
			) -- 449
			cur.player.y = math.max(0, s.playerY or 0) -- 450
			if cur.room.depth ~= nil and s.playerDepth ~= nil then -- 450
				cur.player.depth = math.max( -- 452
					cur.room.depth.min, -- 452
					math.min(cur.room.depth.max, s.playerDepth) -- 452
				) -- 452
			end -- 452
		end -- 452
		if cur.room.key == "gate" and s.gateTick ~= nil and s.gateTick > 0 then -- 452
			cur.gateTick = s.gateTick -- 456
		end -- 456
		if cur.room.key == "village" then -- 456
			if s.hasBottle == true then -- 456
				cur.hasBottle = true -- 459
			end -- 459
			if s.villagePassed == true then -- 459
				cur.passed = true -- 460
			end -- 460
		end -- 460
		if cur.room.key == "prologue" and (s.phase == "" or s.phase == "prologue-wake" or s.phase == "prologue-shadow" or s.phase == "prologue-escape" or s.phase == "prologue-hide") then -- 460
			cur.phase = "prologue-wake" -- 469
		end -- 469
		if (string.find(cur.room.key, "escort", nil, true) or 0) - 1 == 0 and s.route == "soldier" and not cur.craftBench.active and not cur.carryOn then -- 469
			cur.carryOn = true -- 473
			storyRun.story.carry = true -- 474
		end -- 474
	end -- 474
	return play -- 477
end -- 477
function flushProfile() -- 774
	local cur = play -- 775
	if cur ~= nil and cur.archiveDirty then -- 775
		cur.archiveDirty = false -- 777
		markProfilePending(profile) -- 778
	end -- 778
	local ok = flushSaveProfile() -- 780
	if not ok and cur ~= nil then -- 780
		cur.archiveDirty = true -- 782
	end -- 782
	return ok -- 784
end -- 784
function officialStartIndex() -- 788
	local mp = profile.museumPhase -- 789
	local inMuseum = mp == "well_reflect" or mp == "hall_walk" or mp == "lamp_turn" or mp == "return_cabinet" -- 790
	return inMuseum and roomIndexByKey("museum") or 0 -- 791
end -- 791
function roomIndexByKey(key) -- 794
	local i = 0 -- 795
	do -- 795
		i = 0 -- 796
		while i < #ROOMS do -- 796
			if ROOMS[i + 1].key == key then -- 796
				return i -- 798
			end -- 798
			i = i + 1 -- 796
		end -- 796
	end -- 796
	return 0 -- 801
end -- 801
function ____exports.applyChapterPreviewRoute(targetRun, roomKey, routeOverride) -- 804
	if roomKey == "outside" or roomKey == "village" or roomKey == "forest" or roomKey == "tower" and routeOverride ~= "soldier" then -- 804
		targetRun.story.route = "child" -- 809
		targetRun.story.settled = true -- 810
		targetRun.story.countTick = 1440 -- 811
	elseif roomKey == "gatepath" or (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 or roomKey == "tower" and routeOverride == "soldier" then -- 811
		targetRun.story.route = "soldier" -- 814
		targetRun.story.settled = true -- 815
		targetRun.joined = true -- 816
		targetRun.story.handDone = true -- 817
		targetRun.story.tied = true -- 818
		local ____targetRun_story_53 = targetRun.story -- 819
		targetRun.story.maxHpAtGate = 3 -- 819
		____targetRun_story_53.hpAtGate = 3 -- 819
		if (string.find(roomKey, "escort", nil, true) or 0) - 1 == 0 then -- 819
			targetRun.story.carry = true -- 821
		end -- 821
		if roomKey == "escort4" or roomKey == "escort5" then -- 821
			targetRun.inventory.wood = 2 -- 824
			targetRun.inventory.bell = 1 -- 825
		end -- 825
		if roomKey == "escort3" then -- 825
			targetRun.inventory.wood = math.max(targetRun.inventory.wood, 2) -- 828
			targetRun.inventory.scrap = math.max(targetRun.inventory.scrap, 2) -- 829
			targetRun.inventory.bell = math.max(targetRun.inventory.bell, 1) -- 830
			targetRun.inventory.wedge = math.max(targetRun.inventory.wedge, 1) -- 831
		end -- 831
	end -- 831
end -- 804
function enterPlayRoom(idx, source, fresh, seedOverride, chapterRoute) -- 836
	if source == nil then -- 836
		source = "debug" -- 836
	end -- 836
	if fresh == nil then -- 836
		fresh = false -- 836
	end -- 836
	current = idx -- 837
	clock:reset() -- 838
	if fe ~= nil then -- 838
		fe.screen = "play" -- 840
	end -- 840
	play = nil -- 842
	if fresh or source == "chapter" or storyRun == nil then -- 842
		storyRun = createRun( -- 845
			seedOverride or (source == "debug" and 20261124 or randomRunSeed()), -- 845
			source, -- 845
			profile -- 845
		) -- 845
		if fresh or source == "official" then -- 845
			runPlaySeconds = 0 -- 847
			autosaveTimer = 0 -- 848
			lastAutosaveSig = "" -- 849
		end -- 849
		if source == "chapter" then -- 849
			local targetKey = ROOMS[current + 1] ~= nil and ROOMS[current + 1].key or "" -- 852
			____exports.applyChapterPreviewRoute(storyRun, targetKey, chapterRoute) -- 853
		end -- 853
	else -- 853
		storyRun.source = source -- 856
	end -- 856
	ensurePlay() -- 858
	local firstPlay = play -- 860
	if firstPlay ~= nil and ROOMS[current + 1].key == "prologue" and (fresh and source == "official" or source == "chapter") then -- 860
		firstPlay.phase = "prologue-wake" -- 863
	end -- 863
	flushProfile() -- 865
end -- 865
function applySize() -- 868
	if root == nil then -- 868
		return -- 870
	end -- 870
	root.size = Size(viewW, viewH) -- 872
	root.position = Vec2(-viewW / 2, -viewH / 2) -- 873
	stageVp = computeStageViewport(viewW, viewH) -- 874
	if input ~= nil then -- 874
		input:setStageViewport(stageVp) -- 876
	end -- 876
	if fe ~= nil then -- 876
		fe:setStagePlacement(stageVp) -- 879
	end -- 879
end -- 879
function syncFrameAdapters(frameDt) -- 883
	if input == nil then -- 883
		return -- 885
	end -- 885
	local target = input.target -- 887
	if not target.supportsTouch and not target.supportsGamepad then -- 887
		return -- 889
	end -- 889
	local p = play -- 891
	local isPlayMode = fe ~= nil and fe.screen == "play" and p ~= nil -- 892
	local storyTalentBoxes = target.supportsTouch and isPlayMode and fe ~= nil and p ~= nil and not p.paused and not p.craftBench.active and not p.reloadOpen and fe:getStoryTalentBoxes( -- 893
		p, -- 895
		stageVp.stageW, -- 895
		stageVp.stageH, -- 895
		input:isTouchMode() -- 895
	) or ({}) -- 895
	local isFs = false -- 898
	if target:canToggleFullscreen() then -- 898
		do -- 898
			local function ____catch() -- 898
				isFs = false -- 903
			end -- 903
			local ____try = pcall(function() -- 903
				isFs = App.fullScreen -- 901
			end) -- 901
			if not ____try then -- 901
				____catch() -- 901
			end -- 901
		end -- 901
	end -- 901
	local ____input_72 = input -- 906
	local ____input_syncFrame_73 = input.syncFrame -- 906
	local ____stageVp_65 = stageVp -- 907
	local ____temp_66 = fe ~= nil and fe.screen or "title" -- 909
	local ____storyRun_67 = storyRun -- 911
	local ____isPlayMode_56 -- 912
	if isPlayMode then -- 912
		____isPlayMode_56 = fe and fe.cam -- 912
	else -- 912
		____isPlayMode_56 = nil -- 912
	end -- 912
	local ____input_68 = input -- 913
	local ____temp_57 -- 914
	if fe ~= nil then -- 914
		____temp_57 = fe.contract:isAssistHintsEnabled() -- 914
	else -- 914
		____temp_57 = false -- 914
	end -- 914
	local ____temp_58 -- 915
	if fe ~= nil then -- 915
		____temp_58 = fe.audio:isAllMuted() -- 915
	else -- 915
		____temp_58 = false -- 915
	end -- 915
	local ____isFs_69 = isFs -- 916
	local ____storyTalentBoxes_70 = storyTalentBoxes -- 917
	local ____temp_59 -- 918
	if p and fe then -- 918
		____temp_59 = fe:getEscortDeathBoxes(p, stageVp.stageW, stageVp.stageH) -- 918
	else -- 918
		____temp_59 = nil -- 918
	end -- 918
	local ____temp_71 = fe and fe.roguelikeUi:getLedgerButtonRect() -- 919
	local ____temp_64 = fe and fe.roguelikeUi:isLedgerOpen() -- 920
	if ____temp_64 == nil then -- 920
		____temp_64 = false -- 920
	end -- 920
	____input_syncFrame_73(____input_72, { -- 906
		viewport = ____stageVp_65, -- 907
		mode = 1, -- 908
		screen = ____temp_66, -- 909
		play = p, -- 910
		run = ____storyRun_67, -- 911
		cam = ____isPlayMode_56, -- 912
		input = ____input_68, -- 913
		assistHintsEnabled = ____temp_57, -- 914
		isMuted = ____temp_58, -- 915
		isFullscreen = ____isFs_69, -- 916
		storyTalentBoxes = ____storyTalentBoxes_70, -- 917
		escortDeathBoxes = ____temp_59, -- 918
		ledgerBox = ____temp_71, -- 919
		ledgerOpen = ____temp_64, -- 920
		dt = frameDt -- 921
	}) -- 921
end -- 921
function renderTouchOverlay() -- 925
	if input ~= nil then -- 925
		input:renderOverlay() -- 926
	end -- 926
end -- 926
function tick(frameDt) -- 929
	appClock = appClock + math.min( -- 930
		0.05, -- 930
		math.max(0, frameDt) -- 930
	) -- 930
	local w = testViewportOverride ~= nil and testViewportOverride.w or View.size.width -- 931
	local h = testViewportOverride ~= nil and testViewportOverride.h or View.size.height -- 932
	if w ~= viewW or h ~= viewH then -- 932
		viewW = w -- 934
		viewH = h -- 935
		applySize() -- 936
	end -- 936
	if input == nil then -- 936
		return -- 939
	end -- 939
	syncFrameAdapters(frameDt) -- 941
	input:update() -- 942
	if input.userInteracted then -- 942
		onFirstUserGesture() -- 945
	end -- 945
	if pendingWinSizeSaveTimer > 0 then -- 945
		pendingWinSizeSaveTimer = pendingWinSizeSaveTimer - frameDt -- 948
		if pendingWinSizeSaveTimer <= 0 and isDesktopNative() then -- 948
			do -- 948
				pcall(function() -- 948
					if not App.fullScreen then -- 948
						local ws = App.winSize -- 952
						if ws.width >= 640 and ws.height >= 360 then -- 952
							input.settings.winWidth = math.floor(ws.width + 0.5) -- 954
							input.settings.winHeight = math.floor(ws.height + 0.5) -- 955
							saveControlSettings(input.settings) -- 956
						end -- 956
					end -- 956
				end) -- 956
			end -- 956
		end -- 956
	end -- 956
	if input.muteTogglePressed and fe ~= nil then -- 956
		input.muteTogglePressed = false -- 965
		local muted = fe.audio:toggleAllMuted() -- 966
		input.settings.muted = muted -- 967
		saveControlSettings(input.settings) -- 968
	end -- 968
	if input.fullscreenTogglePressed then -- 968
		input.fullscreenTogglePressed = false -- 971
		toggleFullscreen() -- 972
	end -- 972
	syncPowerMode() -- 974
	if not startupNoticeShown and fe ~= nil and fe.screen == "title" then -- 974
		startupNoticeShown = true -- 976
		local rel = getReleaseConfig() -- 977
		if rel ~= nil and rel.saveFallbackReason == "readonly" then -- 977
			fe:showToast("游戏目录不可写，存档已自动回退至用户目录", 4.5) -- 979
		elseif rel ~= nil and rel.migratedFrom ~= nil and rel.migratedFrom ~= "" then -- 979
			fe:showToast("已自动迁移旧存档至 saves 目录", 3.5) -- 981
		elseif profileStatus == "corrupt" or profileStatus == "unsupported" then -- 981
			fe:showToast("主档案异常，原件已备份至 backups 目录", 4.5) -- 983
		end -- 983
	end -- 983
	if input.artifactTogglePressed then -- 983
		input.artifactTogglePressed = false -- 987
		if (fe and fe.screen) == "play" and play ~= nil and not play.paused and not play.escortFailed and not play.talentModalActive and not fe.roguelikeUi:isLedgerOpen() then -- 987
			play:toggleArtifactWeapon() -- 990
		end -- 990
	end -- 990
	if input.bottleCanceled and play ~= nil then -- 990
		input.bottleCanceled = false -- 994
		play.aimHold = 0 -- 995
		play.bottleAimX = -1 -- 996
	end -- 996
	if fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.craftBench.active and not play.reloadOpen and not play.escortFailed and #play:getStoryTalentOffers() > 0 and input.pickRoom >= 1 and input.pickRoom <= 3 then -- 996
		if fe:canPickStoryTalent(play) then -- 996
			play:chooseTalent(input.pickRoom - 1) -- 1003
		end -- 1003
	end -- 1003
	input.pickRoom = 0 -- 1006
	tickFrontend(frameDt) -- 1007
	renderTouchOverlay() -- 1008
end -- 1008
function registerPlay() -- 1012
	local reg = _G.package.loaded -- 1013
	reg["watch.play"] = play -- 1014
	reg["watch.room"] = ROOMS[current + 1].key -- 1015
end -- 1015
function ensurePlay(resume) -- 1019
	if storyRun == nil then -- 1019
		storyRun = createRun(20261124, "debug", profile) -- 1023
	end -- 1023
	play = __TS__New(Play, ROOMS[current + 1], resume, storyRun) -- 1025
	registerPlay() -- 1026
	clock:reset() -- 1027
	if fe ~= nil then -- 1027
		fe:bindPlay(play, stageVp.stageW, stageVp.stageH) -- 1029
	end -- 1029
end -- 1029
function applyRoomTransition(p) -- 1034
	if p.wantRoom == "" then -- 1034
		return false -- 1036
	end -- 1036
	local key = p.wantRoom -- 1038
	p.wantRoom = "" -- 1039
	local idx = -1 -- 1040
	local j = 0 -- 1041
	do -- 1041
		j = 0 -- 1042
		while j < #ROOMS do -- 1042
			if ROOMS[j + 1].key == key then -- 1042
				idx = j -- 1044
			end -- 1044
			j = j + 1 -- 1042
		end -- 1042
	end -- 1042
	if idx < 0 then -- 1042
		return false -- 1048
	end -- 1048
	flushProfile() -- 1053
	local leaving = p:drainEvents() -- 1054
	if p.restartStory then -- 1054
		if storyRun ~= nil and storyRun.source == "official" then -- 1054
			clearSession() -- 1058
			refreshTitleSessionFlag() -- 1059
		end -- 1059
		local nextSource = storyRun ~= nil and storyRun.source == "debug" and "debug" or "official" -- 1061
		local nextSeed = nextSource == "official" and randomRunSeed() or 20261124 -- 1062
		storyRun = createRun(nextSeed, nextSource, profile) -- 1063
	end -- 1063
	current = idx -- 1065
	ensurePlay() -- 1066
	local fresh = play -- 1067
	if fresh ~= nil then -- 1067
		if p.restartStory and ROOMS[current + 1].key == "prologue" and (storyRun and storyRun.source) == "official" then -- 1067
			fresh.phase = "prologue-wake" -- 1070
		end -- 1070
		fresh:adoptEvents(leaving) -- 1072
	end -- 1072
	if not p.restartStory then -- 1072
		saveCurrentSession() -- 1075
	end -- 1075
	clock:reset() -- 1077
	return true -- 1078
end -- 1078
function tickFrontend(frameDt) -- 1081
	if fe == nil or input == nil then -- 1081
		return -- 1083
	end -- 1083
	if fe.screen ~= "play" then -- 1083
		local act = fe:renderMenu(frameDt, input, stageVp.stageW, stageVp.stageH) -- 1088
		input:consumeEdges() -- 1089
		if act.type == "splashDone" then -- 1089
			fe.menus:resetInput() -- 1091
			fe.screen = "title" -- 1092
		elseif act.type == "continue" then -- 1092
			if continueOfficialStory() == nil then -- 1092
				enterPlayRoom( -- 1095
					officialStartIndex(), -- 1095
					"official", -- 1095
					true -- 1095
				) -- 1095
			end -- 1095
		elseif act.type == "start" then -- 1095
			clearSession() -- 1099
			refreshTitleSessionFlag() -- 1100
			enterPlayRoom( -- 1101
				officialStartIndex(), -- 1101
				"official", -- 1101
				true -- 1101
			) -- 1101
		elseif act.type == "jump" and act.roomIndex ~= nil then -- 1101
			enterPlayRoom( -- 1103
				act.roomIndex, -- 1103
				"chapter", -- 1103
				false, -- 1103
				nil, -- 1103
				act.route -- 1103
			) -- 1103
		elseif act.type == "openChapters" then -- 1103
			fe.menus:openChapters() -- 1105
			fe.screen = "chapters" -- 1106
		elseif act.type == "openControls" then -- 1106
			fe.menus:resetInput() -- 1108
			fe.screen = "controls" -- 1109
		elseif act.type == "openSaves" then -- 1109
			fe.menus:openSaves(false) -- 1111
			fe.screen = "saves" -- 1112
		elseif act.type == "openSettings" then -- 1112
			fe.menus:openSettings() -- 1114
			fe.screen = "settings" -- 1115
		elseif act.type == "loadSlot" and act.slot ~= nil then -- 1115
			if loadOfficialSlot(act.slot) ~= nil then -- 1115
				fe:showToast( -- 1118
					"已读取" .. slotDisplayName(act.slot), -- 1118
					2 -- 1118
				) -- 1118
			else -- 1118
				fe:showToast("读取存档失败", 2.2) -- 1120
			end -- 1120
		elseif act.type == "deleteSlot" and act.slot ~= nil then -- 1120
			deleteSaveSlotById(act.slot) -- 1123
		elseif act.type == "openHistory" then -- 1123
			fe.menus:openHistory(true) -- 1125
			fe.screen = "history" -- 1126
		elseif act.type == "backEpilogue" then -- 1126
			fe.menus:resetInput() -- 1128
			fe.screen = "epilogue" -- 1129
		elseif act.type == "replayStory" then -- 1129
			clearSession() -- 1131
			refreshTitleSessionFlag() -- 1132
			enterPlayRoom( -- 1133
				officialStartIndex(), -- 1133
				"official", -- 1133
				true -- 1133
			) -- 1133
		elseif act.type == "backTitle" then -- 1133
			fe.menus:resetInput() -- 1135
			fe.screen = "title" -- 1136
		elseif act.type == "backPause" then -- 1136
			fe.menus:resetInput() -- 1138
			fe.screen = "play" -- 1139
		elseif act.type == "quit" then -- 1139
			quitGame() -- 1141
		end -- 1141
		return -- 1143
	end -- 1143
	if play == nil then -- 1143
		ensurePlay() -- 1148
	end -- 1148
	if play == nil then -- 1148
		return -- 1151
	end -- 1151
	local p = play -- 1153
	p.aimX = input.mx -- 1155
	p.aimY = input.my -- 1156
	local zoneTap = input.touchZoneTap -- 1158
	if zoneTap ~= "ledger:toggle" then -- 1158
		input.touchZoneTap = "" -- 1159
	end -- 1159
	if not p.paused and p.escortFailed then -- 1159
		local deathAction = "" -- 1163
		if zoneTap == "escort:retry" and p.escortFailedTicks >= 12 then -- 1163
			deathAction = "retry" -- 1165
		elseif zoneTap == "escort:title" then -- 1165
			deathAction = "title" -- 1167
		else -- 1167
			if input.navLeft or input.navPrevTab then -- 1167
				fe.roguelikeUi.deathSelected = 0 -- 1170
			elseif input.navRight or input.navNextTab then -- 1170
				fe.roguelikeUi.deathSelected = 1 -- 1172
			end -- 1172
			if input.pause.pressed or input.navBack then -- 1172
				deathAction = "title" -- 1175
			elseif p.escortFailedTicks >= 24 and input.retry.pressed then -- 1175
				deathAction = "retry" -- 1177
			elseif p.escortFailedTicks >= 24 and input.navConfirm then -- 1177
				deathAction = fe.roguelikeUi.deathSelected == 0 and "retry" or "title" -- 1179
			elseif p.escortFailedTicks >= 12 and (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) then -- 1179
				deathAction = fe:tryPickEscortDeathAtPointer(p, input, stageVp.stageW, stageVp.stageH) -- 1182
			end -- 1182
		end -- 1182
		if deathAction == "retry" then -- 1182
			input:consumeEdges() -- 1186
			p:confirmEscortRestart() -- 1187
			applyRoomTransition(p) -- 1188
			return -- 1189
		end -- 1189
		if deathAction == "title" then -- 1189
			input:consumeEdges() -- 1192
			fe.audio:stopRoomTransient() -- 1193
			fe.menus:resetInput() -- 1194
			fe.screen = "title" -- 1195
			input:clearTransient(true) -- 1196
			return -- 1197
		end -- 1197
		input.pause.pressed = false -- 1199
		input.retry.pressed = false -- 1200
		input.fire.pressed = false -- 1201
	end -- 1201
	if not p.paused and fe.roguelikeUi:isLedgerOpen() then -- 1201
		clock:reset() -- 1205
		fe:renderPlay( -- 1206
			frameDt, -- 1206
			p, -- 1206
			input, -- 1206
			stageVp.stageW, -- 1206
			stageVp.stageH -- 1206
		) -- 1206
		input:consumeEdges() -- 1207
		return -- 1208
	end -- 1208
	local offers = p:getStoryTalentOffers() -- 1211
	if fe:canPickStoryTalent(p) and #offers > 0 then -- 1211
		if fe.hud.talentSelected >= #offers then -- 1211
			fe.hud.talentSelected = 0 -- 1214
		end -- 1214
		if (string.find(zoneTap, "talent:", nil, true) or 0) - 1 == 0 then -- 1214
			local idx = __TS__ParseInt( -- 1217
				string.sub(zoneTap, 8), -- 1217
				10 -- 1217
			) -- 1217
			if idx >= 0 and idx < #offers and p:chooseTalent(idx) then -- 1217
				fe.hud.talentSelected = idx -- 1219
				input.fire.pressed = false -- 1220
			end -- 1220
		else -- 1220
			local navDelta = p.talentModalActive and ((input.navRight or input.navNextTab) and 1 or 0) - ((input.navLeft or input.navPrevTab) and 1 or 0) or 0 -- 1223
			local totalDelta = navDelta ~= 0 and navDelta or input.talentDelta -- 1226
			if totalDelta ~= 0 then -- 1226
				fe.hud.talentSelected = (fe.hud.talentSelected + totalDelta + #offers) % #offers -- 1228
				input.talentDelta = 0 -- 1229
			end -- 1229
			if input.talentConfirm or p.talentModalActive and input.navConfirm then -- 1229
				p:chooseTalent(fe.hud.talentSelected) -- 1232
				input.talentConfirm = false -- 1233
				input.fire.pressed = false -- 1234
			elseif (input.uiPressed or input.inputMode ~= "gamepad" and input.fire.pressed) and fe:tryPickTalentAtPointer(p, input, stageVp.stageW, stageVp.stageH) then -- 1234
				input.fire.pressed = false -- 1237
			end -- 1237
		end -- 1237
	end -- 1237
	if not p.paused and p.room.key == "tower" and p.phase == "tower-end" then -- 1237
		if input.navConfirm then -- 1237
			input.interact.pressed = true -- 1245
		end -- 1245
		if p:towerEndReady() and (input.interact.pressed or input.retry.pressed) then -- 1245
			flushProfile() -- 1248
			if p.run.source == "official" and hasSessionSave() then -- 1248
				clearSession() -- 1250
				refreshTitleSessionFlag() -- 1251
			end -- 1251
			fe.audio:stopRoomTransient() -- 1253
			fe.menus:openEpilogue(p.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 1254
			fe.screen = "epilogue" -- 1258
			input:clearTransient(true) -- 1259
			input:consumeEdges() -- 1260
			return -- 1261
		end -- 1261
	end -- 1261
	if not p.paused and p.craftBench.active and input.pause.pressed then -- 1261
		p:closeCraftBench() -- 1266
		input:consumeEdges() -- 1267
		return -- 1268
	end -- 1268
	if not p.paused and not p.escortFailed and input.pause.pressed then -- 1268
		p.paused = true -- 1271
		p.aimHold = 0 -- 1272
		p.bottleAimX = -1 -- 1273
		saveCurrentSession() -- 1274
		fe.menus:openPause() -- 1275
		fe.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 1276
		input:clearTransient(true) -- 1277
		input:consumeEdges() -- 1278
	end -- 1278
	if p.paused then -- 1278
		clock:reset() -- 1283
		local pauseAct = fe:renderPlay( -- 1284
			frameDt, -- 1284
			p, -- 1284
			input, -- 1284
			stageVp.stageW, -- 1284
			stageVp.stageH -- 1284
		) -- 1284
		input:consumeEdges() -- 1285
		if pauseAct.type == "resume" then -- 1285
			p.paused = false -- 1287
		elseif pauseAct.type == "retry" then -- 1287
			if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1287
				p:restartEscortRun() -- 1290
				applyRoomTransition(p) -- 1291
			else -- 1291
				ensurePlay({checkpoint = p.checkpoint}) -- 1293
			end -- 1293
		elseif pauseAct.type == "openChapters" then -- 1293
			fe.audio:stopRoomTransient() -- 1296
			fe.audio:setPaused(false) -- 1297
			fe.menus:openChapters(current) -- 1298
			fe.screen = "chapters" -- 1299
		elseif pauseAct.type == "toggleFullscreen" then -- 1299
			toggleFullscreen() -- 1301
		elseif pauseAct.type == "saveSlot" and pauseAct.slot ~= nil then -- 1301
			saveToManualSlot(pauseAct.slot) -- 1303
		elseif pauseAct.type == "loadSlot" and pauseAct.slot ~= nil then -- 1303
			if loadOfficialSlot(pauseAct.slot) ~= nil then -- 1303
				fe:showToast( -- 1306
					"已读取" .. slotDisplayName(pauseAct.slot), -- 1306
					2 -- 1306
				) -- 1306
			else -- 1306
				fe:showToast("读取存档失败", 2.2) -- 1308
			end -- 1308
		elseif pauseAct.type == "deleteSlot" and pauseAct.slot ~= nil then -- 1308
			deleteSaveSlotById(pauseAct.slot) -- 1311
		elseif pauseAct.type == "quit" then -- 1311
			quitGame() -- 1313
		elseif pauseAct.type == "toTitle" then -- 1313
			saveCurrentSession() -- 1315
			refreshTitleSessionFlag() -- 1316
			fe.menus:resetInput() -- 1317
			fe.screen = "title" -- 1318
		end -- 1318
		return -- 1320
	end -- 1320
	local inTowerEnding = p.room.key == "tower" and p.phase ~= "tower-wait" -- 1323
	local inPrologueIntro = p.room.key == "prologue" and (p.phase == "prologue-wake" or p.phase == "prologue-shadow" or p.phase == "prologue-escape" or p.phase == "prologue-hide") -- 1324
	if input.retry.pressed and not inTowerEnding and not inPrologueIntro and not p.craftBench.active and not p.reloadOpen and not p.escortFailed and not p.talentModalActive then -- 1324
		input:consumeEdges() -- 1327
		if p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() then -- 1327
			p:restartEscortRun() -- 1330
			applyRoomTransition(p) -- 1331
		else -- 1331
			ensurePlay({checkpoint = p.checkpoint}) -- 1334
		end -- 1334
		return -- 1336
	end -- 1336
	local steps = clock:advance(frameDt) -- 1339
	local i = 0 -- 1340
	do -- 1340
		i = 0 -- 1341
		while i < steps do -- 1341
			input:beginStep(i == 0) -- 1342
			p:update(STEP, input) -- 1343
			input:endStep() -- 1344
			if p.wantRoom ~= "" then -- 1344
				break -- 1346
			end -- 1346
			i = i + 1 -- 1341
		end -- 1341
	end -- 1341
	if applyRoomTransition(p) then -- 1341
		return -- 1352
	end -- 1352
	flushProfile() -- 1356
	if p.run.source == "official" and not p.paused and not p.run.finished then -- 1356
		runPlaySeconds = runPlaySeconds + math.min( -- 1358
			0.1, -- 1358
			math.max(0, frameDt) -- 1358
		) -- 1358
		autosaveTimer = autosaveTimer + math.min( -- 1359
			0.1, -- 1359
			math.max(0, frameDt) -- 1359
		) -- 1359
		if autosaveCooldown > 0 then -- 1359
			autosaveCooldown = math.max(0, autosaveCooldown - frameDt) -- 1361
		end -- 1361
	end -- 1361
	if p.run.finished and p.run.source == "official" and hasSessionSave() then -- 1361
		clearSession() -- 1365
		refreshTitleSessionFlag() -- 1366
	elseif p.sessionDirty then -- 1366
		saveCurrentSession() -- 1368
	elseif canSaveSession() and autosaveCooldown <= 0 then -- 1368
		local sig = sessionMilestoneSignature(p) -- 1370
		if lastAutosaveSig == "" then -- 1370
			lastAutosaveSig = sig -- 1372
		elseif sig ~= lastAutosaveSig or autosaveTimer >= 20 then -- 1372
			saveCurrentSession() -- 1374
		end -- 1374
	end -- 1374
	fe:renderPlay( -- 1377
		frameDt, -- 1377
		p, -- 1377
		input, -- 1377
		stageVp.stageW, -- 1377
		stageVp.stageH -- 1377
	) -- 1377
end -- 1377
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
local function isReleaseBuild() -- 59
	return isReleaseMode() -- 60
end -- 59
local function handleBackButton() -- 151
	if fe == nil then -- 151
		return -- 153
	end -- 153
	if fe.screen == "splash" then -- 153
		fe.menus:resetSplash() -- 156
		fe.screen = "title" -- 157
		fe.menus:resetInput() -- 158
		return -- 159
	end -- 159
	if fe.screen == "chapters" or fe.screen == "controls" or fe.screen == "saves" or fe.screen == "settings" or fe.screen == "epilogue" or fe.screen == "history" then -- 159
		fe.menus:triggerBack() -- 162
		return -- 163
	end -- 163
	if fe.screen == "title" then -- 163
		if not canQuitApp() then -- 163
			fe:showToast("按系统返回主界面或切换应用离开", 1.8) -- 167
			return -- 168
		end -- 168
		if appClock - lastBackPressClock <= 2 then -- 168
			quitGame() -- 171
		else -- 171
			lastBackPressClock = appClock -- 173
			fe:showToast("再按一次返回退出游戏", 2) -- 174
		end -- 174
		return -- 176
	end -- 176
	if fe.screen == "play" and play ~= nil then -- 176
		if play.escortFailed then -- 176
			fe.audio:stopRoomTransient() -- 180
			fe.menus:resetInput() -- 181
			fe.screen = "title" -- 182
			if input ~= nil then -- 182
				input:clearTransient(true) -- 183
			end -- 183
			return -- 184
		end -- 184
		if fe.roguelikeUi:isLedgerOpen() then -- 184
			fe.roguelikeUi:closeLedger() -- 187
			return -- 188
		end -- 188
		if play.paused then -- 188
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
end -- 151
function ____exports.start(parent, _initialMode, startScreen) -- 480
	if _initialMode == nil then -- 480
		_initialMode = 1 -- 480
	end -- 480
	if startScreen == nil then -- 480
		startScreen = "title" -- 480
	end -- 480
	root = parent -- 481
	local loaded = loadSave() -- 485
	profile = loaded.state -- 486
	profileStatus = loaded.status -- 487
	profileDetail = loaded.detail -- 488
	fe = __TS__New(WatchFrontend, parent) -- 489
	fe.screen = startScreen -- 490
	if startScreen == "splash" then -- 490
		fe.menus:resetSplash() -- 492
	end -- 492
	refreshTitleSessionFlag() -- 494
	fe:setVisible(true) -- 495
	input = __TS__New(Input) -- 497
	fe.audio:applyUserVolumes(input.settings) -- 498
	fe.contract:setAssistHintsEnabled(input.settings.assistHints) -- 499
	if input.settings.muted then -- 499
		fe.audio:setAllMuted(true) -- 501
	end -- 501
	fe.menus.onToggleFullscreen = function() -- 503
		toggleFullscreen() -- 504
	end -- 503
	if isDesktopNative() and canToggleFullscreen() and testViewportOverride == nil then -- 503
		do -- 503
			pcall(function() -- 503
				if input.settings.fullscreen then -- 503
					if not App.fullScreen then -- 503
						App.fullScreen = true -- 511
					end -- 511
				elseif input.settings.winWidth >= 640 and input.settings.winHeight >= 360 then -- 511
					local curSize = App.winSize -- 514
					if math.abs(curSize.width - input.settings.winWidth) > 2 or math.abs(curSize.height - input.settings.winHeight) > 2 then -- 514
						App.winSize = Size(input.settings.winWidth, input.settings.winHeight) -- 517
					end -- 517
				end -- 517
			end) -- 517
		end -- 517
	end -- 517
	windowFocused = true -- 524
	lastAppliedIdle = nil -- 525
	startupNoticeShown = false -- 526
	syncPowerMode() -- 527
	input:attach( -- 528
		parent, -- 528
		{ -- 528
			onFirstUserGesture = function() -- 529
				onFirstUserGesture() -- 530
				if input ~= nil then -- 530
					input:markKeyboardActivity() -- 531
				end -- 531
			end, -- 529
			onToggleFullscreen = function() -- 533
				toggleFullscreen() -- 534
			end, -- 533
			onKeyDownEvent = function(____, key) -- 536
				if (fe and fe.screen) == "play" and play ~= nil and not play.paused then -- 536
					if key == "1" or key == "2" or key == "3" then -- 536
						if input ~= nil then -- 536
							input:requestPickRoom(__TS__Number(key)) -- 539
						end -- 539
						return -- 540
					end -- 540
					if key == "T" and not play.escortFailed and not play.talentModalActive and not fe.roguelikeUi:isLedgerOpen() then -- 540
						play:toggleArtifactWeapon() -- 543
						return -- 544
					end -- 544
				end -- 544
				local inPausedPlay = fe ~= nil and fe.screen == "play" and play ~= nil and play.paused -- 547
				if fe ~= nil and (fe.screen ~= "play" or inPausedPlay) then -- 547
					fe.menus:onKeyEvent(key) -- 549
				end -- 549
				if input ~= nil and (fe ~= nil and fe.screen == "play" and not inPausedPlay) then -- 549
					if key == "E" then -- 549
						input.interact.pressed = true -- 553
					elseif key == "Space" then -- 553
						input.jump.pressed = true -- 555
					elseif key == "Escape" then -- 555
						input.pause.pressed = true -- 557
					elseif key == "R" and (play == nil or not play.craftBench.active and not play.reloadOpen) then -- 557
						input.retry.pressed = true -- 559
					end -- 559
				end -- 559
			end -- 536
		} -- 536
	) -- 536
	parent:gslot( -- 566
		"AppChange", -- 566
		function(settingName) -- 566
			if input == nil or not isDesktopNative() then -- 566
				return -- 568
			end -- 568
			if settingName == "FullScreen" then -- 568
				do -- 568
					pcall(function() -- 568
						input.settings.fullscreen = App.fullScreen -- 572
						saveControlSettings(input.settings) -- 573
					end) -- 573
				end -- 573
			elseif settingName == "Size" then -- 573
				pendingWinSizeSaveTimer = 0.45 -- 578
			end -- 578
		end -- 566
	) -- 566
	parent:gslot( -- 583
		"AppEvent", -- 583
		function(eventType) -- 583
			if eventType == "BackButton" then -- 583
				handleBackButton() -- 585
				return -- 586
			end -- 586
			if eventType == "Quit" or eventType == "Shutdown" then -- 586
				flushProfile() -- 589
				saveCurrentSession() -- 590
				if input ~= nil then -- 590
					input:clearTransient(false) -- 591
				end -- 591
				return -- 592
			end -- 592
			if eventType == "WillEnterBackground" or eventType == "DidEnterBackground" or eventType == "WindowFocusLost" then -- 592
				windowFocused = false -- 595
				flushProfile() -- 596
				saveCurrentSession() -- 597
				if input ~= nil then -- 597
					input:clearTransient(true) -- 598
				end -- 598
				if fe ~= nil and fe.screen == "play" and play ~= nil and not play.paused and not play.escortFailed then -- 598
					play.paused = true -- 600
					play.aimHold = 0 -- 601
					play.bottleAimX = -1 -- 602
					fe.menus:openPause() -- 603
				end -- 603
				if fe ~= nil then -- 603
					fe.audio:setPaused(true) -- 606
				end -- 606
				syncPowerMode() -- 608
				return -- 609
			end -- 609
			if eventType == "DidEnterForeground" or eventType == "WindowFocusGained" then -- 609
				windowFocused = true -- 612
				if fe ~= nil then -- 612
					local paused = play ~= nil and play.paused and fe.screen == "play" -- 614
					fe.audio:setPaused(paused) -- 615
				end -- 615
				syncPowerMode() -- 617
			end -- 617
		end -- 583
	) -- 583
	viewW = View.size.width -- 621
	viewH = View.size.height -- 622
	applySize() -- 623
	local reg = _G.package.loaded -- 626
	reg["watch.input"] = input -- 627
	reg["watch.touch"] = input:getTouchRouter() -- 628
	reg["watch.gamepad"] = input:getGamepadRouter() -- 629
	reg["watch.fe"] = { -- 630
		setScreen = function(sc) -- 631
			if fe == nil then -- 631
				return -- 633
			end -- 633
			clock:reset() -- 635
			fe.screen = sc -- 636
			if sc == "splash" then -- 636
				fe.menus:resetSplash() -- 638
			elseif sc == "chapters" then -- 638
				fe.menus:openChapters() -- 640
			elseif sc == "epilogue" then -- 640
				fe.menus:openEpilogue(play ~= nil and play.storyRoute == "soldier" and "reunion" or "lamp", profile.childCleared and profile.soldierCleared) -- 642
			elseif sc == "history" then -- 642
				fe.menus:openHistory(false) -- 647
			else -- 647
				fe.menus:resetInput() -- 649
			end -- 649
			if sc == "play" then -- 649
				ensurePlay() -- 652
			end -- 652
		end, -- 631
		jumpRoom = function(keyOrIdx) -- 655
			local idx = -1 -- 656
			if type(keyOrIdx) == "number" then -- 656
				idx = keyOrIdx -- 658
			else -- 658
				local k = 0 -- 660
				do -- 660
					k = 0 -- 661
					while k < #ROOMS do -- 661
						if ROOMS[k + 1].key == keyOrIdx then -- 661
							idx = k -- 663
						end -- 663
						k = k + 1 -- 661
					end -- 661
				end -- 661
			end -- 661
			if idx >= 0 and idx < #ROOMS then -- 661
				enterPlayRoom(idx, "debug") -- 668
			end -- 668
		end, -- 655
		getPlay = function() return play end, -- 671
		getFrontend = function() return fe end, -- 672
		startStory = function(seed) -- 674
			enterPlayRoom( -- 675
				officialStartIndex(), -- 675
				"official", -- 675
				true, -- 675
				seed -- 675
			) -- 675
			return play -- 676
		end, -- 674
		previewChapter = function(idx, routeOrSeed, seed) -- 679
			enterPlayRoom( -- 680
				idx, -- 680
				"chapter", -- 680
				false, -- 680
				type(routeOrSeed) == "number" and routeOrSeed or seed, -- 680
				type(routeOrSeed) == "string" and routeOrSeed or nil -- 681
			) -- 681
			return play -- 682
		end, -- 679
		getStoryRun = function() return storyRun end, -- 684
		getProfilePending = function() return profilePending() end, -- 685
		flushProfileNow = function() return flushProfile() end, -- 686
		getProfile = function() return profile end, -- 688
		getProfileStatus = function() return profileStatus end, -- 689
		getProfileDetail = function() return profileDetail end, -- 690
		useTestSave = function(name) -- 691
			setSaveFile(name) -- 692
			setSessionFile(name == "" and "" or name .. ".session") -- 693
			clearProfilePending() -- 694
			local loaded = loadSave() -- 695
			profile = loaded.state -- 696
			profileStatus = loaded.status -- 697
			profileDetail = loaded.detail -- 698
			refreshTitleSessionFlag() -- 699
		end, -- 691
		useTestSession = function(name) -- 701
			setSessionFile(name) -- 702
			refreshTitleSessionFlag() -- 703
		end, -- 701
		getSessionFile = getSessionFile, -- 705
		hasSessionSave = hasSessionSave, -- 706
		saveSessionNow = function() return saveCurrentSession() end, -- 707
		clearSessionNow = function() -- 708
			local ok = clearSession() -- 709
			refreshTitleSessionFlag() -- 710
			return ok -- 711
		end, -- 708
		continueStory = function() return continueOfficialStory() end, -- 713
		listSaveSlots = function() return listSaveSlots() end, -- 714
		saveToSlot = function(slot) return saveToManualSlot(slot) end, -- 715
		loadFromSlot = function(slot) return loadOfficialSlot(slot) end, -- 716
		deleteSlot = function(slot) return deleteSaveSlotById(slot) end, -- 717
		canSaveSession = function() return canSaveSession() end, -- 718
		saveNow = function() return saveSave(profile) end, -- 719
		getSaveFile = getSaveFile, -- 720
		isRelease = function() return isReleaseBuild() end, -- 721
		getReleaseVersion = function() -- 722
			local ____opt_33 = getReleaseConfig() -- 722
			return ____opt_33 and ____opt_33.version or "dev" -- 722
		end, -- 722
		toggleFullscreen = function() return toggleFullscreen() end, -- 723
		quitGame = function() return quitGame() end, -- 724
		handleBackButton = function() return handleBackButton() end, -- 725
		getViewport = function() return stageVp end, -- 726
		getTargetId = function() return getActiveTarget().id end, -- 727
		getTouchController = function() return input and input:getTouchControls() end, -- 728
		getTouchRouter = function() return input and input:getTouchRouter() end, -- 729
		getGamepad = function() return input and input:getGamepadRouter() end, -- 730
		setGamepadSim = function(state) -- 731
			if input ~= nil then -- 731
				input:setGamepadSim(state) -- 732
			end -- 732
		end, -- 731
		injectTouch = function(phase, id, x, y, fromMouse) -- 734
			if input ~= nil then -- 734
				input:injectTouch( -- 735
					phase, -- 735
					id, -- 735
					x, -- 735
					y, -- 735
					fromMouse -- 735
				) -- 735
			end -- 735
		end, -- 734
		getInputMode = function() return input and input.inputMode or getActiveTarget().defaultInputMode end, -- 737
		setInputMode = function(m) -- 738
			if input ~= nil then -- 738
				input:setInputMode(m) -- 739
			end -- 739
		end, -- 738
		setModePref = function(pref) -- 741
			if input ~= nil then -- 741
				input:setModePref(pref) -- 742
			end -- 742
		end, -- 741
		applyViewportForTest = function(w, h) -- 744
			if w ~= nil and h ~= nil and w > 0 and h > 0 then -- 744
				testViewportOverride = {w = w, h = h} -- 746
				viewW = w -- 747
				viewH = h -- 748
			else -- 748
				testViewportOverride = nil -- 750
				viewW = View.size.width -- 751
				viewH = View.size.height -- 752
			end -- 752
			applySize() -- 754
			return stageVp -- 755
		end, -- 744
		getToast = function() return fe and fe:getToastText() or "" end -- 757
	} -- 757
	if startScreen == "play" then -- 757
		ensurePlay() -- 761
	end -- 761
	parent:schedule(function(frameDt) -- 764
		tick(frameDt) -- 765
		return false -- 766
	end) -- 764
end -- 480
return ____exports -- 480