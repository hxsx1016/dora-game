-- [ts]: adapter.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____escort = require("Script.watch.escort") -- 9
local CALM_REACH = ____escort.CALM_REACH -- 9
local ____depth = require("Script.watch.depth") -- 10
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 10
local inReachDepth = ____depth.inReachDepth -- 10
local overlapsDepth = ____depth.overlapsDepth -- 10
function ____exports.createEmptyFrameEvents(roomSessionId, eventSeq, checkpoint) -- 110
	return { -- 115
		shotFired = false, -- 116
		shotHit = false, -- 117
		shotTrace = nil, -- 118
		enemyKilledX = -9999, -- 119
		enemyKilledY = 0, -- 120
		playerHit = false, -- 121
		coverDeflect = false, -- 122
		rollStarted = false, -- 123
		knockPulse = false, -- 124
		knockX = 0, -- 125
		knockY = 0, -- 126
		bottleLanded = false, -- 127
		bottleLandX = -1, -- 128
		bottleLandY = 0, -- 129
		cartJustDocked = false, -- 130
		checkpointJustHit = false, -- 131
		caughtTriggered = false, -- 132
		phaseChanged = false, -- 133
		roomChanged = false, -- 134
		gateWaveSpawned = false, -- 135
		storyRouteLocked = false, -- 136
		storyRoute = "", -- 137
		gateRested = false, -- 138
		handJustTied = false, -- 139
		handReleased = false, -- 140
		storyLine = false, -- 141
		storyLineText = "", -- 142
		storyExit = false, -- 143
		storyExitRoute = "", -- 144
		carryStarted = false, -- 145
		reloadOpened = false, -- 146
		reloadSolved = false, -- 147
		reloadEffect = "", -- 148
		reloadApplied = false, -- 149
		reloadAppliedEffect = "", -- 150
		reloadTimeout = false, -- 151
		reloadInvalid = false, -- 152
		segmentDone = false, -- 153
		segmentKey = "", -- 154
		segmentNext = "", -- 155
		benchOpened = false, -- 156
		benchCrafted = false, -- 157
		benchCraftedWeapon = "", -- 158
		benchEquipped = false, -- 159
		benchClosed = false, -- 160
		benchRejected = false, -- 161
		benchRejectReason = "", -- 162
		endingReached = false, -- 163
		ending = "", -- 164
		endingOfficial = false, -- 165
		endingLines = {}, -- 166
		museumStep = false, -- 167
		museumStepName = "", -- 168
		museumDone = false, -- 169
		storyBeats = {}, -- 170
		talentPicked = false, -- 171
		talentPickedId = "", -- 172
		talentPickedRank = 0, -- 173
		campaignFailedReset = false, -- 174
		campaignFailedRoom = "", -- 175
		pickupTaken = false, -- 176
		pickupKind = "", -- 177
		pickupLabel = "", -- 178
		pickupRejected = false, -- 179
		pickupRejectedKind = "", -- 180
		craftStarted = false, -- 181
		craftDone = false, -- 182
		rawEvents = {}, -- 183
		eventSeq = eventSeq, -- 184
		roomSessionId = roomSessionId, -- 185
		checkpoint = checkpoint, -- 186
		eventSummary = {} -- 187
	} -- 187
end -- 110
____exports.PlayAdapter = __TS__Class() -- 202
local PlayAdapter = ____exports.PlayAdapter -- 202
PlayAdapter.name = "PlayAdapter" -- 202
function PlayAdapter.prototype.____constructor(self) -- 202
	self.prevRoomKey = "" -- 203
	self.prevPhase = "" -- 204
	self.prevHp = 3 -- 205
	self.prevCoveredFlash = 0 -- 207
	self.prevRollT = 0 -- 208
	self.prevCalmTick = 0 -- 209
	self.prevKnocks = 0 -- 210
	self.prevBottleLandT = 0 -- 211
	self.prevCartDocked = false -- 212
	self.prevCheckpoint = -1 -- 213
	self.prevCaughtT = 0 -- 214
	self.prevGateSpawned = 0 -- 215
	self.prevAliveMask = {} -- 216
	self.roomSessionId = 0 -- 217
	self.eventSeq = 0 -- 218
end -- 202
function PlayAdapter.prototype.getRoomSessionId(self) -- 220
	return self.roomSessionId -- 221
end -- 220
function PlayAdapter.prototype.getEventSeq(self) -- 224
	return self.eventSeq -- 225
end -- 224
function PlayAdapter.prototype.emptyFrame(self, p) -- 228
	return ____exports.createEmptyFrameEvents(self.roomSessionId, self.eventSeq, p ~= nil and p.checkpoint or -1) -- 229
end -- 228
function PlayAdapter.prototype.reset(self, p) -- 236
	self.roomSessionId = self.roomSessionId + 1 -- 237
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 238
	self.prevPhase = p ~= nil and p.phase or "" -- 239
	self.prevHp = p ~= nil and p.hp or 3 -- 240
	self.prevTrace = nil -- 241
	self.prevCoveredFlash = 0 -- 242
	self.prevRollT = 0 -- 243
	self.prevCalmTick = 0 -- 244
	self.prevKnocks = 0 -- 245
	self.prevBottleLandT = 0 -- 246
	local ____temp_0 -- 247
	if p ~= nil then -- 247
		____temp_0 = p.cartDocked -- 247
	else -- 247
		____temp_0 = false -- 247
	end -- 247
	self.prevCartDocked = ____temp_0 -- 247
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 248
	self.prevCaughtT = 0 -- 249
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 250
	self.prevAliveMask = {} -- 251
	if p ~= nil then -- 251
		local i = 0 -- 253
		do -- 253
			i = 0 -- 254
			while i < #p.enemies do -- 254
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 254
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 255
				i = i + 1 -- 254
			end -- 254
		end -- 254
	end -- 254
end -- 236
function PlayAdapter.prototype.sample(self, p) -- 261
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 262
	if roomChanged then -- 262
		self:reset(p) -- 264
	end -- 264
	local rawEvents = p:drainEvents() -- 267
	if #rawEvents > 1 then -- 267
		__TS__ArraySort( -- 270
			rawEvents, -- 270
			function(____, a, b) return a.seq ~= b.seq and a.seq - b.seq or a.tick - b.tick end -- 270
		) -- 270
	end -- 270
	local eventSummary = {} -- 272
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 273
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 274
	local enemyKilledX = -9999 -- 275
	local enemyKilledY = 0 -- 276
	local i = 0 -- 277
	do -- 277
		i = 0 -- 278
		while i < #p.enemies do -- 278
			local ____temp_2 -- 279
			if i < #self.prevAliveMask then -- 279
				____temp_2 = self.prevAliveMask[i + 1] -- 279
			else -- 279
				____temp_2 = true -- 279
			end -- 279
			local wasAlive = ____temp_2 -- 279
			if wasAlive and not p.enemies[i + 1].alive then -- 279
				enemyKilledX = p.enemies[i + 1].x -- 281
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) * DEPTH_Y_SCALE + p.enemies[i + 1].h * 0.55 -- 282
			end -- 282
			i = i + 1 -- 278
		end -- 278
	end -- 278
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 286
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 287
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 288
	local knockPulse = false -- 291
	local knockX = p.player.x -- 292
	local knockY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.5 -- 293
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 295
	local bottleLandX = p.bottleLandX -- 296
	local bottleLandY = p.bottleLandY -- 297
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 298
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 299
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 300
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 301
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 302
	local migratedRoomChange = false -- 303
	local storyRouteLocked = false -- 305
	local gateRested = false -- 306
	local handJustTied = false -- 307
	local handReleased = false -- 308
	local storyLine = false -- 309
	local storyLineText = "" -- 310
	local storyExit = false -- 311
	local storyExitRoute = "" -- 312
	local carryStarted = false -- 313
	local reloadOpened = false -- 314
	local reloadSolved = false -- 315
	local reloadEffect = "" -- 316
	local reloadApplied = false -- 317
	local reloadAppliedEffect = "" -- 318
	local reloadTimeout = false -- 319
	local reloadInvalid = false -- 320
	local segmentDone = false -- 321
	local segmentKey = "" -- 322
	local segmentNext = "" -- 323
	local benchOpened = false -- 324
	local benchCrafted = false -- 325
	local benchCraftedWeapon = "" -- 326
	local benchEquipped = false -- 327
	local benchClosed = false -- 328
	local benchRejected = false -- 329
	local benchRejectReason = "" -- 330
	local endingReached = false -- 331
	local museumStep = false -- 332
	local museumStepName = "" -- 333
	local museumDone = false -- 334
	local ending = "" -- 335
	local endingOfficial = false -- 336
	local endingLines = {} -- 337
	local storyBeats = {} -- 338
	local talentPicked = false -- 339
	local talentPickedId = "" -- 340
	local talentPickedRank = 0 -- 341
	local campaignFailedReset = false -- 342
	local campaignFailedRoom = "" -- 343
	local fallenBuild -- 344
	local pickupTaken = false -- 345
	local pickupKind = "" -- 346
	local pickupLabel = "" -- 347
	local pickupRejected = false -- 348
	local pickupRejectedKind = "" -- 349
	local craftStarted = false -- 350
	local craftDone = false -- 351
	for ____, event in ipairs(rawEvents) do -- 352
		self.eventSeq = self.eventSeq + 1 -- 353
		eventSummary[#eventSummary + 1] = (((tostring(event.seq) .. "@") .. tostring(event.tick)) .. ":") .. event.name -- 354
		if event.name == "knock" then -- 354
			knockPulse = true -- 357
			local x = event.data.x -- 358
			knockX = type(x) == "number" and x or p.player.x -- 359
			knockY = p.escort.state == "calming" and p.partner.y + p.partner.depth * DEPTH_Y_SCALE + 28 or p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.55 -- 360
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 360
			playerHit = true -- 364
		elseif event.name == "coverBlocked" then -- 364
			coverDeflect = true -- 366
		elseif event.name == "bottleLanded" then -- 366
			bottleLanded = true -- 368
			if type(event.data.x) == "number" then -- 368
				bottleLandX = event.data.x -- 370
			end -- 370
			if type(event.data.y) == "number" then -- 370
				bottleLandY = event.data.y -- 373
			end -- 373
		elseif event.name == "cartDocked" then -- 373
			cartJustDocked = true -- 376
		elseif event.name == "roomChange" then -- 376
			migratedRoomChange = true -- 378
		elseif event.name == "storyRouteLocked" then -- 378
			storyRouteLocked = true -- 380
		elseif event.name == "gateCountDone" and p.storyRoute == "soldier" then -- 380
			gateRested = true -- 382
		elseif event.name == "handHeld" then -- 382
			handJustTied = true -- 384
		elseif event.name == "handRelease" then -- 384
			handReleased = true -- 386
		elseif event.name == "storyLine" then -- 386
			storyLine = true -- 388
			storyLineText = type(event.data.text) == "string" and event.data.text or "" -- 389
		elseif event.name == "storyExit" then -- 389
			storyExit = true -- 391
			storyExitRoute = type(event.data.route) == "string" and event.data.route or "" -- 392
		elseif event.name == "carryStart" then -- 392
			carryStarted = true -- 394
		elseif event.name == "reloadOpen" then -- 394
			reloadOpened = true -- 396
		elseif event.name == "reloadSolved" then -- 396
			reloadSolved = true -- 398
			reloadEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 399
		elseif event.name == "reloadApplied" then -- 399
			reloadApplied = true -- 401
			reloadAppliedEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 402
		elseif event.name == "reloadTimeout" then -- 402
			reloadTimeout = true -- 404
		elseif event.name == "reloadInvalid" then -- 404
			reloadInvalid = true -- 406
		elseif event.name == "segmentDone" then -- 406
			segmentDone = true -- 408
			segmentKey = type(event.data.room) == "string" and event.data.room or "" -- 409
			segmentNext = type(event.data.next) == "string" and event.data.next or "" -- 410
		elseif event.name == "benchOpen" then -- 410
			benchOpened = true -- 412
		elseif event.name == "benchCraft" then -- 412
			benchCrafted = true -- 414
			benchCraftedWeapon = type(event.data.weapon) == "string" and event.data.weapon or "" -- 415
		elseif event.name == "benchEquip" then -- 415
			benchEquipped = true -- 417
		elseif event.name == "benchClose" then -- 417
			benchClosed = true -- 419
		elseif event.name == "benchRejected" then -- 419
			benchRejected = true -- 421
			benchRejectReason = type(event.data.reason) == "string" and event.data.reason or "" -- 422
		elseif event.name == "museumStep" then -- 422
			museumStep = true -- 424
			museumStepName = type(event.data.step) == "string" and event.data.step or "" -- 425
		elseif event.name == "museumDone" then -- 425
			museumDone = true -- 427
		elseif event.name == "storyBeat" then -- 427
			if event.data.beat == "talent_picked" then -- 427
				talentPicked = true -- 430
				talentPickedId = type(event.data.talent) == "string" and event.data.talent or "" -- 431
				talentPickedRank = type(event.data.rank) == "number" and event.data.rank or 1 -- 432
			end -- 432
			storyBeats[#storyBeats + 1] = { -- 434
				beat = type(event.data.beat) == "string" and event.data.beat or "", -- 435
				x = type(event.data.x) == "number" and event.data.x or p.player.x, -- 436
				room = type(event.data.room) == "string" and event.data.room or p.room.key, -- 437
				item = type(event.data.item) == "string" and event.data.item or "" -- 438
			} -- 438
		elseif event.name == "endingReached" then -- 438
			endingReached = true -- 441
			ending = type(event.data.ending) == "string" and event.data.ending or "" -- 442
			endingOfficial = event.data.official == true -- 443
			endingLines = __TS__ArrayIsArray(event.data.lines) and __TS__ArrayMap( -- 444
				event.data.lines, -- 445
				function(____, v) return type(v) == "string" and v or "" end -- 445
			) or ({}) -- 445
		elseif event.name == "campaignFailed" and event.data.reset == true then -- 445
			campaignFailedReset = true -- 448
			fallenBuild = event.data.fallenBuild -- 449
			campaignFailedRoom = type(event.data.room) == "string" and event.data.room or "" -- 450
		elseif event.name == "pickup" then -- 450
			pickupTaken = true -- 452
			pickupKind = type(event.data.kind) == "string" and event.data.kind or "" -- 453
			pickupLabel = type(event.data.label) == "string" and event.data.label or "" -- 454
		elseif event.name == "pickupRejected" then -- 454
			pickupRejected = true -- 456
			pickupRejectedKind = type(event.data.kind) == "string" and event.data.kind or "" -- 457
		elseif event.name == "craftStart" then -- 457
			craftStarted = true -- 459
		elseif event.name == "craftDone" then -- 459
			craftDone = true -- 461
		end -- 461
	end -- 461
	self.prevRoomKey = p.room.key -- 466
	self.prevPhase = p.phase -- 467
	self.prevHp = p.hp -- 468
	self.prevTrace = p.trace -- 469
	self.prevCoveredFlash = p.coveredFlash -- 470
	self.prevRollT = p.player.rollT -- 471
	self.prevCalmTick = p.escort.calmTick -- 472
	self.prevKnocks = p.knocks -- 473
	self.prevBottleLandT = p.bottleLandT -- 474
	self.prevCartDocked = p.cartDocked -- 475
	self.prevCheckpoint = p.checkpoint -- 476
	self.prevCaughtT = p.caughtT -- 477
	self.prevGateSpawned = p.gateSpawned -- 478
	self.prevAliveMask = {} -- 479
	do -- 479
		i = 0 -- 480
		while i < #p.enemies do -- 480
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 480
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 481
			i = i + 1 -- 480
		end -- 480
	end -- 480
	local ____shotFired_5 = shotFired -- 485
	local ____shotHit_6 = shotHit -- 486
	local ____shotFired_4 -- 487
	if shotFired then -- 487
		____shotFired_4 = p.trace -- 487
	else -- 487
		____shotFired_4 = nil -- 487
	end -- 487
	return { -- 484
		shotFired = ____shotFired_5, -- 485
		shotHit = ____shotHit_6, -- 486
		shotTrace = ____shotFired_4, -- 487
		enemyKilledX = enemyKilledX, -- 488
		enemyKilledY = enemyKilledY, -- 489
		playerHit = playerHit, -- 490
		coverDeflect = coverDeflect, -- 491
		rollStarted = rollStarted, -- 492
		knockPulse = knockPulse, -- 493
		knockX = knockX, -- 494
		knockY = knockY, -- 495
		bottleLanded = bottleLanded, -- 496
		bottleLandX = bottleLandX, -- 497
		bottleLandY = bottleLandY, -- 498
		cartJustDocked = cartJustDocked, -- 499
		checkpointJustHit = checkpointJustHit, -- 500
		caughtTriggered = caughtTriggered, -- 501
		phaseChanged = phaseChanged, -- 502
		roomChanged = roomChanged or migratedRoomChange, -- 503
		gateWaveSpawned = gateWaveSpawned, -- 504
		storyRouteLocked = storyRouteLocked, -- 506
		storyRoute = p.storyRoute, -- 507
		gateRested = gateRested, -- 508
		handJustTied = handJustTied, -- 509
		handReleased = handReleased, -- 510
		storyLine = storyLine, -- 511
		storyLineText = storyLineText, -- 512
		storyExit = storyExit, -- 513
		storyExitRoute = storyExitRoute, -- 514
		carryStarted = carryStarted, -- 515
		reloadOpened = reloadOpened, -- 516
		reloadSolved = reloadSolved, -- 517
		reloadEffect = reloadEffect, -- 518
		reloadApplied = reloadApplied, -- 519
		reloadAppliedEffect = reloadAppliedEffect, -- 520
		reloadTimeout = reloadTimeout, -- 521
		reloadInvalid = reloadInvalid, -- 522
		segmentDone = segmentDone, -- 523
		segmentKey = segmentKey, -- 524
		segmentNext = segmentNext, -- 525
		benchOpened = benchOpened, -- 526
		benchCrafted = benchCrafted, -- 527
		benchCraftedWeapon = benchCraftedWeapon, -- 528
		benchEquipped = benchEquipped, -- 529
		benchClosed = benchClosed, -- 530
		benchRejected = benchRejected, -- 531
		benchRejectReason = benchRejectReason, -- 532
		endingReached = endingReached, -- 533
		ending = ending, -- 534
		endingOfficial = endingOfficial, -- 535
		endingLines = endingLines, -- 536
		museumStep = museumStep, -- 537
		museumStepName = museumStepName, -- 538
		museumDone = museumDone, -- 539
		storyBeats = storyBeats, -- 540
		talentPicked = talentPicked, -- 541
		talentPickedId = talentPickedId, -- 542
		talentPickedRank = talentPickedRank, -- 543
		campaignFailedReset = campaignFailedReset, -- 544
		campaignFailedRoom = campaignFailedRoom, -- 545
		fallenBuild = fallenBuild, -- 546
		pickupTaken = pickupTaken, -- 547
		pickupKind = pickupKind, -- 548
		pickupLabel = pickupLabel, -- 549
		pickupRejected = pickupRejected, -- 550
		pickupRejectedKind = pickupRejectedKind, -- 551
		craftStarted = craftStarted, -- 552
		craftDone = craftDone, -- 553
		rawEvents = rawEvents, -- 555
		eventSeq = self.eventSeq, -- 556
		roomSessionId = self.roomSessionId, -- 557
		checkpoint = p.checkpoint, -- 558
		eventSummary = eventSummary -- 559
	} -- 559
end -- 261
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 566
	local room = p.room -- 567
	local player = p.player -- 568
	if p.paused or not player.alive then -- 568
		return nil -- 570
	end -- 570
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 570
		local ____opt_9 = room.story -- 570
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 570
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 574
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 574
			return { -- 576
				x = p.partner.x, -- 576
				y = p.partner.y + p.partner.depth * DEPTH_Y_SCALE + p.partner.h + 22, -- 576
				keyTag = "E", -- 576
				label = "递出指南针", -- 576
				urgent = false -- 576
			} -- 576
		end -- 576
		return nil -- 578
	end -- 578
	if not p.childMode and p.escort.state == "frozen" then -- 578
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 578
			return { -- 583
				x = p.partner.x, -- 583
				y = p.partner.y + p.partner.depth * DEPTH_Y_SCALE + p.partner.h + 22, -- 583
				keyTag = "E", -- 583
				label = "安抚小满", -- 583
				urgent = true -- 583
			} -- 583
		end -- 583
		return nil -- 585
	end -- 585
	local ____opt_11 = room.story -- 585
	local gate = ____opt_11 and ____opt_11.gate -- 588
	if gate ~= nil then -- 588
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 588
			return { -- 593
				x = gate.winchX, -- 593
				y = 84, -- 593
				keyTag = "E", -- 593
				label = "重新守门", -- 593
				urgent = true -- 593
			} -- 593
		end -- 593
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 593
			return { -- 596
				x = gate.doorX, -- 596
				y = 98, -- 596
				keyTag = "E", -- 596
				label = "送小满出城", -- 596
				urgent = true -- 596
			} -- 596
		end -- 596
		if p.phase == "gate-wait" then -- 596
			local ratio = math.max( -- 600
				0, -- 600
				math.min(1, p.handTicks / p.handNeedTicks) -- 600
			) -- 600
			return { -- 601
				x = gate.doorX + 30, -- 602
				y = 96, -- 602
				keyTag = p.handArmed and "按住 E" or "松开再按住 E", -- 603
				label = p.handTicks > 0 and "牵起小满" or "把手伸给她", -- 604
				urgent = p.handArmed, -- 605
				progress = ratio -- 605
			} -- 605
		end -- 605
		if p.phase == "gate-hand" then -- 605
			return { -- 609
				x = gate.doorX + 30, -- 609
				y = 96, -- 609
				keyTag = "E", -- 609
				label = "我们走吧。", -- 609
				urgent = false -- 609
			} -- 609
		end -- 609
		if p.phase == "gate-walk" then -- 609
			return { -- 612
				x = player.x, -- 612
				y = player.y + player.h + 22, -- 612
				keyTag = "→", -- 612
				label = "走向城外", -- 612
				urgent = false -- 612
			} -- 612
		end -- 612
	end -- 612
	if p.reloadOpen then -- 612
		local need = math.max( -- 618
			1, -- 618
			p:reloadNeedTicks() -- 618
		) -- 618
		local ratio = math.max( -- 619
			0, -- 619
			math.min(1, p.reloadAnswerTicks / need) -- 619
		) -- 619
		return { -- 620
			x = player.x, -- 621
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 34, -- 621
			keyTag = "连线", -- 622
			label = "画到枪机复位", -- 622
			urgent = p.reloadAnswerTicks > need * 0.7, -- 622
			progress = ratio -- 622
		} -- 622
	end -- 622
	if p.reloadPendingEffect ~= "" then -- 622
		return { -- 626
			x = player.x, -- 627
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 34, -- 627
			keyTag = "左键", -- 628
			label = "枪机已上势 · 打下一枪", -- 628
			urgent = false -- 628
		} -- 628
	end -- 628
	if room.key == "gatepath" and not p.carryOn then -- 628
		return { -- 632
			x = player.x, -- 632
			y = player.y + player.h + 24, -- 632
			keyTag = "→", -- 632
			label = "走到高石阶", -- 632
			urgent = false -- 632
		} -- 632
	end -- 632
	if room.key == "escort3" and not p.craftBench.active then -- 632
		local bench = 560 -- 635
		if math.abs(player.x - bench) <= p.benchReach + 40 and player.y < 12 then -- 635
			return { -- 637
				x = bench, -- 637
				y = 92, -- 637
				keyTag = "E", -- 637
				label = "在工台制作", -- 637
				urgent = false -- 637
			} -- 637
		end -- 637
	end -- 637
	if (room.key == "escort2" or room.key == "escort3" or room.key == "escort4" or room.key == "escort5") and p.carryOn then -- 637
		return { -- 641
			x = player.x, -- 641
			y = player.y + player.h + 24, -- 641
			keyTag = "→", -- 641
			label = "带她走到出口", -- 641
			urgent = false -- 641
		} -- 641
	end -- 641
	local cart = room.cart -- 644
	if (room.key == "checkpoint" or room.key == "outside" or room.key == "c2-granary") and not p.cartDocked and cart.bodyW > 0 then -- 644
		local handleX = p.cartAxle + cart.handleOffset -- 646
		if p.gripping or p:cartHandleInReach() then -- 646
			return { -- 648
				x = handleX, -- 649
				y = cart.baseY + (cart.depth or 0) * DEPTH_Y_SCALE + cart.wheelR + cart.bodyH + 46, -- 650
				keyTag = room.key == "c2-granary" and "E 握柄 + D" or "按住 E + D", -- 651
				label = room.key == "outside" and "向前拉车" or "向前推车", -- 652
				urgent = false -- 653
			} -- 653
		end -- 653
		if room.key == "outside" then -- 653
			return { -- 657
				x = handleX, -- 658
				y = cart.baseY + cart.bodyH + 36, -- 658
				keyTag = player.x > handleX and "←" or "→", -- 659
				label = "红布车右柄", -- 659
				urgent = false -- 659
			} -- 659
		end -- 659
	end -- 659
	if room.key == "outside" and p.cartDocked and p.checkpoint < room.arch.x1 and player.y > room.arch.y + 1 then -- 659
		local stairs = room.stairs[1] -- 664
		if stairs ~= nil then -- 664
			return { -- 666
				x = stairs.x0, -- 666
				y = stairs.y0 + 30, -- 666
				keyTag = "←", -- 666
				label = "从石阶下到地面", -- 666
				urgent = false -- 666
			} -- 666
		end -- 666
	end -- 666
	if p.isCampaign then -- 666
		local bi = 0 -- 671
		do -- 671
			bi = 0 -- 672
			while bi < #p.boxes do -- 672
				do -- 672
					local b = p.boxes[bi + 1] -- 673
					if b.broken == true or b.hidden == true or b.interact == nil then -- 673
						goto __continue84 -- 675
					end -- 675
					local cx = (b.x0 + b.x1) * 0.5 -- 677
					local reach = b.interact.reach or 46 -- 678
					if math.abs(player.x - cx) <= reach + 16 and overlapsDepth(player.depth, b.depth, 16) then -- 678
						local kind = b.interact.kind -- 680
						local label = kind == "open_board" and "放下窗板" or (kind == "lower_curtain" and "放下木帘" or "抬起门锁") -- 681
						return { -- 683
							x = cx, -- 683
							y = b.y1 + 24, -- 683
							keyTag = "E", -- 683
							label = label, -- 683
							urgent = true -- 683
						} -- 683
					end -- 683
				end -- 683
				::__continue84:: -- 683
				bi = bi + 1 -- 672
			end -- 672
		end -- 672
	end -- 672
	if room.key == "village" and p.scavChase then -- 672
		local ____player_crouch_13 -- 689
		if player.crouch then -- 689
			____player_crouch_13 = nil -- 689
		else -- 689
			____player_crouch_13 = { -- 689
				x = player.x, -- 690
				y = player.y + player.h + 22, -- 690
				keyTag = "按住 Ctrl", -- 690
				label = "蹲下躲避", -- 690
				urgent = true -- 690
			} -- 690
		end -- 690
		return ____player_crouch_13 -- 689
	end -- 689
	if room.key == "village" and not p.passed then -- 689
		local bottle = room.bottle -- 695
		if p.hasBottle then -- 695
			return { -- 697
				x = player.x, -- 698
				y = player.y + player.h + 26, -- 698
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 699
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 700
				urgent = false -- 700
			} -- 700
		end -- 700
		if p.bottleFly == nil and bottle ~= nil then -- 700
			local dx = player.x - bottle.x -- 704
			local dy = player.y + player.h * 0.5 - bottle.y -- 705
			if dx * dx + dy * dy < 56 * 56 then -- 705
				return { -- 707
					x = bottle.x, -- 707
					y = bottle.y + 36, -- 707
					keyTag = "E", -- 707
					label = "拾起瓶子", -- 707
					urgent = false -- 707
				} -- 707
			end -- 707
		end -- 707
	end -- 707
	local arch = room.arch -- 712
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 712
		return { -- 716
			x = (arch.x0 + arch.x1) * 0.5, -- 717
			y = arch.y + arch.h + 44, -- 717
			keyTag = "按住 Ctrl", -- 718
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 718
			urgent = false -- 718
		} -- 718
	end -- 718
	local ____opt_14 = room.story -- 718
	local museum = ____opt_14 and ____opt_14.museum -- 722
	if room.key == "museum" and museum ~= nil then -- 722
		if p.phase == "museum-cabinet" then -- 722
			return { -- 725
				x = museum.cabinetX, -- 725
				y = 64 + 44, -- 725
				keyTag = "E", -- 725
				label = "玻璃柜前 · 收枪入袖", -- 725
				urgent = true -- 725
			} -- 725
		end -- 725
		if p.phase == "museum-hall" then -- 725
			return { -- 728
				x = museum.hallX, -- 728
				y = 120, -- 728
				keyTag = "走到", -- 728
				label = "西厅那头 · 孩子的脚步", -- 728
				urgent = false -- 728
			} -- 728
		end -- 728
		if p.phase == "museum-lamp" then -- 728
			return { -- 731
				x = museum.lampX, -- 731
				y = 120, -- 731
				keyTag = "E", -- 731
				label = "末厅 · 把灯转向西窗", -- 731
				urgent = true -- 731
			} -- 731
		end -- 731
		if p.phase == "museum-return" then -- 731
			return { -- 734
				x = museum.cabinetX, -- 734
				y = 64 + 44, -- 734
				keyTag = "E", -- 734
				label = "回柜边 · 轻敲两下", -- 734
				urgent = true -- 734
			} -- 734
		end -- 734
		if p.phase == "museum-done" then -- 734
			return { -- 737
				x = museum.cabinetX, -- 737
				y = 64 + 44, -- 737
				keyTag = "E", -- 737
				label = "回柜边 · 灯还亮着", -- 737
				urgent = false -- 737
			} -- 737
		end -- 737
		return nil -- 739
	end -- 739
	local ____opt_16 = room.story -- 739
	local tower = ____opt_16 and ____opt_16.tower -- 742
	if p.phase == "tower-wait" and tower ~= nil then -- 742
		local near = math.abs(player.x - tower.doorX) <= 50 -- 744
		return { -- 745
			x = tower.doorX, -- 745
			y = 127, -- 745
			keyTag = near and "E" or "→", -- 745
			label = near and "敲木门" or "走到木门前", -- 745
			urgent = false -- 745
		} -- 745
	end -- 745
	if p.phase == "tower-enter" then -- 745
		return { -- 748
			x = 605, -- 748
			y = 64, -- 748
			keyTag = "→", -- 748
			label = "跨过门槛 · 走到值夜桌前", -- 748
			urgent = false -- 748
		} -- 748
	end -- 748
	if p.phase == "tower-desk" then -- 748
		return { -- 751
			x = 605, -- 752
			y = 64, -- 752
			keyTag = "按住 E", -- 752
			label = "交出针套、指南针和纸条", -- 752
			progress = p.deskHold / 36, -- 753
			urgent = true -- 753
		} -- 753
	end -- 753
	if p.phase == "tower-given" then -- 753
		return { -- 757
			x = 605, -- 757
			y = 64, -- 757
			keyTag = "", -- 757
			label = "看登记簿 · 西窗的灯", -- 757
			urgent = false -- 757
		} -- 757
	end -- 757
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 757
		return { -- 762
			x = player.x, -- 763
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 25, -- 763
			keyTag = "按住 Shift", -- 764
			label = "贴靠掩体", -- 764
			urgent = gate ~= nil -- 764
		} -- 764
	end -- 764
	return nil -- 767
end -- 566
return ____exports -- 566