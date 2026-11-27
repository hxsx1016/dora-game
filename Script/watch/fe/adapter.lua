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
function ____exports.createEmptyFrameEvents(roomSessionId, eventSeq, checkpoint) -- 108
	return { -- 113
		shotFired = false, -- 114
		shotHit = false, -- 115
		shotTrace = nil, -- 116
		enemyKilledX = -9999, -- 117
		enemyKilledY = 0, -- 118
		playerHit = false, -- 119
		coverDeflect = false, -- 120
		rollStarted = false, -- 121
		knockPulse = false, -- 122
		knockX = 0, -- 123
		knockY = 0, -- 124
		bottleLanded = false, -- 125
		bottleLandX = -1, -- 126
		bottleLandY = 0, -- 127
		cartJustDocked = false, -- 128
		checkpointJustHit = false, -- 129
		caughtTriggered = false, -- 130
		phaseChanged = false, -- 131
		roomChanged = false, -- 132
		gateWaveSpawned = false, -- 133
		storyRouteLocked = false, -- 134
		storyRoute = "", -- 135
		gateRested = false, -- 136
		handJustTied = false, -- 137
		handReleased = false, -- 138
		storyLine = false, -- 139
		storyLineText = "", -- 140
		storyExit = false, -- 141
		storyExitRoute = "", -- 142
		carryStarted = false, -- 143
		reloadOpened = false, -- 144
		reloadSolved = false, -- 145
		reloadEffect = "", -- 146
		reloadApplied = false, -- 147
		reloadAppliedEffect = "", -- 148
		reloadTimeout = false, -- 149
		reloadInvalid = false, -- 150
		segmentDone = false, -- 151
		segmentKey = "", -- 152
		segmentNext = "", -- 153
		benchOpened = false, -- 154
		benchCrafted = false, -- 155
		benchCraftedWeapon = "", -- 156
		benchEquipped = false, -- 157
		benchClosed = false, -- 158
		benchRejected = false, -- 159
		benchRejectReason = "", -- 160
		endingReached = false, -- 161
		ending = "", -- 162
		endingOfficial = false, -- 163
		endingLines = {}, -- 164
		museumStep = false, -- 165
		museumStepName = "", -- 166
		museumDone = false, -- 167
		talentPicked = false, -- 168
		talentPickedId = "", -- 169
		talentPickedRank = 0, -- 170
		campaignFailedReset = false, -- 171
		campaignFailedRoom = "", -- 172
		pickupTaken = false, -- 173
		pickupKind = "", -- 174
		pickupLabel = "", -- 175
		pickupRejected = false, -- 176
		pickupRejectedKind = "", -- 177
		craftStarted = false, -- 178
		craftDone = false, -- 179
		rawEvents = {}, -- 180
		eventSeq = eventSeq, -- 181
		roomSessionId = roomSessionId, -- 182
		checkpoint = checkpoint, -- 183
		eventSummary = {} -- 184
	} -- 184
end -- 108
____exports.PlayAdapter = __TS__Class() -- 199
local PlayAdapter = ____exports.PlayAdapter -- 199
PlayAdapter.name = "PlayAdapter" -- 199
function PlayAdapter.prototype.____constructor(self) -- 199
	self.prevRoomKey = "" -- 200
	self.prevPhase = "" -- 201
	self.prevHp = 3 -- 202
	self.prevCoveredFlash = 0 -- 204
	self.prevRollT = 0 -- 205
	self.prevCalmTick = 0 -- 206
	self.prevKnocks = 0 -- 207
	self.prevBottleLandT = 0 -- 208
	self.prevCartDocked = false -- 209
	self.prevCheckpoint = -1 -- 210
	self.prevCaughtT = 0 -- 211
	self.prevGateSpawned = 0 -- 212
	self.prevAliveMask = {} -- 213
	self.roomSessionId = 0 -- 214
	self.eventSeq = 0 -- 215
end -- 199
function PlayAdapter.prototype.getRoomSessionId(self) -- 217
	return self.roomSessionId -- 218
end -- 217
function PlayAdapter.prototype.getEventSeq(self) -- 221
	return self.eventSeq -- 222
end -- 221
function PlayAdapter.prototype.emptyFrame(self, p) -- 225
	return ____exports.createEmptyFrameEvents(self.roomSessionId, self.eventSeq, p ~= nil and p.checkpoint or -1) -- 226
end -- 225
function PlayAdapter.prototype.reset(self, p) -- 233
	self.roomSessionId = self.roomSessionId + 1 -- 234
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 235
	self.prevPhase = p ~= nil and p.phase or "" -- 236
	self.prevHp = p ~= nil and p.hp or 3 -- 237
	self.prevTrace = nil -- 238
	self.prevCoveredFlash = 0 -- 239
	self.prevRollT = 0 -- 240
	self.prevCalmTick = 0 -- 241
	self.prevKnocks = 0 -- 242
	self.prevBottleLandT = 0 -- 243
	local ____temp_0 -- 244
	if p ~= nil then -- 244
		____temp_0 = p.cartDocked -- 244
	else -- 244
		____temp_0 = false -- 244
	end -- 244
	self.prevCartDocked = ____temp_0 -- 244
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 245
	self.prevCaughtT = 0 -- 246
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 247
	self.prevAliveMask = {} -- 248
	if p ~= nil then -- 249
		local i = 0 -- 250
		do -- 250
			i = 0 -- 251
			while i < #p.enemies do -- 251
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 252
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 252
				i = i + 1 -- 251
			end -- 251
		end -- 251
	end -- 251
end -- 233
function PlayAdapter.prototype.sample(self, p) -- 258
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 259
	if roomChanged then -- 260
		self:reset(p) -- 261
	end -- 261
	local rawEvents = p:drainEvents() -- 264
	if #rawEvents > 1 then -- 266
		__TS__ArraySort( -- 267
			rawEvents, -- 267
			function(____, a, b) return a.seq ~= b.seq and a.seq - b.seq or a.tick - b.tick end -- 267
		) -- 267
	end -- 267
	local eventSummary = {} -- 269
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 270
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 271
	local enemyKilledX = -9999 -- 272
	local enemyKilledY = 0 -- 273
	local i = 0 -- 274
	do -- 274
		i = 0 -- 275
		while i < #p.enemies do -- 275
			local ____temp_2 -- 276
			if i < #self.prevAliveMask then -- 276
				____temp_2 = self.prevAliveMask[i + 1] -- 276
			else -- 276
				____temp_2 = true -- 276
			end -- 276
			local wasAlive = ____temp_2 -- 276
			if wasAlive and not p.enemies[i + 1].alive then -- 277
				enemyKilledX = p.enemies[i + 1].x -- 278
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) * DEPTH_Y_SCALE + p.enemies[i + 1].h * 0.55 -- 279
			end -- 279
			i = i + 1 -- 275
		end -- 275
	end -- 275
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 283
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 284
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 285
	local knockPulse = false -- 288
	local knockX = p.player.x -- 289
	local knockY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.5 -- 290
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 292
	local bottleLandX = p.bottleLandX -- 293
	local bottleLandY = p.bottleLandY -- 294
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 295
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 296
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 297
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 298
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 299
	local migratedRoomChange = false -- 300
	local storyRouteLocked = false -- 302
	local gateRested = false -- 303
	local handJustTied = false -- 304
	local handReleased = false -- 305
	local storyLine = false -- 306
	local storyLineText = "" -- 307
	local storyExit = false -- 308
	local storyExitRoute = "" -- 309
	local carryStarted = false -- 310
	local reloadOpened = false -- 311
	local reloadSolved = false -- 312
	local reloadEffect = "" -- 313
	local reloadApplied = false -- 314
	local reloadAppliedEffect = "" -- 315
	local reloadTimeout = false -- 316
	local reloadInvalid = false -- 317
	local segmentDone = false -- 318
	local segmentKey = "" -- 319
	local segmentNext = "" -- 320
	local benchOpened = false -- 321
	local benchCrafted = false -- 322
	local benchCraftedWeapon = "" -- 323
	local benchEquipped = false -- 324
	local benchClosed = false -- 325
	local benchRejected = false -- 326
	local benchRejectReason = "" -- 327
	local endingReached = false -- 328
	local museumStep = false -- 329
	local museumStepName = "" -- 330
	local museumDone = false -- 331
	local ending = "" -- 332
	local endingOfficial = false -- 333
	local endingLines = {} -- 334
	local talentPicked = false -- 335
	local talentPickedId = "" -- 336
	local talentPickedRank = 0 -- 337
	local campaignFailedReset = false -- 338
	local campaignFailedRoom = "" -- 339
	local fallenBuild -- 340
	local pickupTaken = false -- 341
	local pickupKind = "" -- 342
	local pickupLabel = "" -- 343
	local pickupRejected = false -- 344
	local pickupRejectedKind = "" -- 345
	local craftStarted = false -- 346
	local craftDone = false -- 347
	for ____, event in ipairs(rawEvents) do -- 348
		self.eventSeq = self.eventSeq + 1 -- 349
		eventSummary[#eventSummary + 1] = (((tostring(event.seq) .. "@") .. tostring(event.tick)) .. ":") .. event.name -- 350
		if event.name == "knock" then -- 352
			knockPulse = true -- 353
			local x = event.data.x -- 354
			knockX = type(x) == "number" and x or p.player.x -- 355
			knockY = p.escort.state == "calming" and p.partner.y + p.partner.depth * DEPTH_Y_SCALE + 28 or p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.55 -- 356
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 359
			playerHit = true -- 360
		elseif event.name == "coverBlocked" then -- 361
			coverDeflect = true -- 362
		elseif event.name == "bottleLanded" then -- 363
			bottleLanded = true -- 364
			if type(event.data.x) == "number" then -- 365
				bottleLandX = event.data.x -- 366
			end -- 366
			if type(event.data.y) == "number" then -- 368
				bottleLandY = event.data.y -- 369
			end -- 369
		elseif event.name == "cartDocked" then -- 371
			cartJustDocked = true -- 372
		elseif event.name == "roomChange" then -- 373
			migratedRoomChange = true -- 374
		elseif event.name == "storyRouteLocked" then -- 375
			storyRouteLocked = true -- 376
		elseif event.name == "gateCountDone" and p.storyRoute == "soldier" then -- 377
			gateRested = true -- 378
		elseif event.name == "handHeld" then -- 379
			handJustTied = true -- 380
		elseif event.name == "handRelease" then -- 381
			handReleased = true -- 382
		elseif event.name == "storyLine" then -- 383
			storyLine = true -- 384
			storyLineText = type(event.data.text) == "string" and event.data.text or "" -- 385
		elseif event.name == "storyExit" then -- 386
			storyExit = true -- 387
			storyExitRoute = type(event.data.route) == "string" and event.data.route or "" -- 388
		elseif event.name == "carryStart" then -- 389
			carryStarted = true -- 390
		elseif event.name == "reloadOpen" then -- 391
			reloadOpened = true -- 392
		elseif event.name == "reloadSolved" then -- 393
			reloadSolved = true -- 394
			reloadEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 395
		elseif event.name == "reloadApplied" then -- 396
			reloadApplied = true -- 397
			reloadAppliedEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 398
		elseif event.name == "reloadTimeout" then -- 399
			reloadTimeout = true -- 400
		elseif event.name == "reloadInvalid" then -- 401
			reloadInvalid = true -- 402
		elseif event.name == "segmentDone" then -- 403
			segmentDone = true -- 404
			segmentKey = type(event.data.room) == "string" and event.data.room or "" -- 405
			segmentNext = type(event.data.next) == "string" and event.data.next or "" -- 406
		elseif event.name == "benchOpen" then -- 407
			benchOpened = true -- 408
		elseif event.name == "benchCraft" then -- 409
			benchCrafted = true -- 410
			benchCraftedWeapon = type(event.data.weapon) == "string" and event.data.weapon or "" -- 411
		elseif event.name == "benchEquip" then -- 412
			benchEquipped = true -- 413
		elseif event.name == "benchClose" then -- 414
			benchClosed = true -- 415
		elseif event.name == "benchRejected" then -- 416
			benchRejected = true -- 417
			benchRejectReason = type(event.data.reason) == "string" and event.data.reason or "" -- 418
		elseif event.name == "museumStep" then -- 419
			museumStep = true -- 420
			museumStepName = type(event.data.step) == "string" and event.data.step or "" -- 421
		elseif event.name == "museumDone" then -- 422
			museumDone = true -- 423
		elseif event.name == "endingReached" then -- 424
			endingReached = true -- 425
			ending = type(event.data.ending) == "string" and event.data.ending or "" -- 426
			endingOfficial = event.data.official == true -- 427
			endingLines = __TS__ArrayIsArray(event.data.lines) and __TS__ArrayMap( -- 428
				event.data.lines, -- 429
				function(____, v) return type(v) == "string" and v or "" end -- 429
			) or ({}) -- 430
		elseif event.name == "storyBeat" and event.data.beat == "talent_picked" then -- 431
			talentPicked = true -- 432
			talentPickedId = type(event.data.talent) == "string" and event.data.talent or "" -- 433
			talentPickedRank = type(event.data.rank) == "number" and event.data.rank or 1 -- 434
		elseif event.name == "campaignFailed" and event.data.reset == true then -- 435
			campaignFailedReset = true -- 436
			fallenBuild = event.data.fallenBuild -- 437
			campaignFailedRoom = type(event.data.room) == "string" and event.data.room or "" -- 438
		elseif event.name == "pickup" then -- 439
			pickupTaken = true -- 440
			pickupKind = type(event.data.kind) == "string" and event.data.kind or "" -- 441
			pickupLabel = type(event.data.label) == "string" and event.data.label or "" -- 442
		elseif event.name == "pickupRejected" then -- 443
			pickupRejected = true -- 444
			pickupRejectedKind = type(event.data.kind) == "string" and event.data.kind or "" -- 445
		elseif event.name == "craftStart" then -- 446
			craftStarted = true -- 447
		elseif event.name == "craftDone" then -- 448
			craftDone = true -- 449
		end -- 449
	end -- 449
	self.prevRoomKey = p.room.key -- 454
	self.prevPhase = p.phase -- 455
	self.prevHp = p.hp -- 456
	self.prevTrace = p.trace -- 457
	self.prevCoveredFlash = p.coveredFlash -- 458
	self.prevRollT = p.player.rollT -- 459
	self.prevCalmTick = p.escort.calmTick -- 460
	self.prevKnocks = p.knocks -- 461
	self.prevBottleLandT = p.bottleLandT -- 462
	self.prevCartDocked = p.cartDocked -- 463
	self.prevCheckpoint = p.checkpoint -- 464
	self.prevCaughtT = p.caughtT -- 465
	self.prevGateSpawned = p.gateSpawned -- 466
	self.prevAliveMask = {} -- 467
	do -- 467
		i = 0 -- 468
		while i < #p.enemies do -- 468
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 469
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 469
			i = i + 1 -- 468
		end -- 468
	end -- 468
	local ____shotFired_5 = shotFired -- 473
	local ____shotHit_6 = shotHit -- 474
	local ____shotFired_4 -- 475
	if shotFired then -- 475
		____shotFired_4 = p.trace -- 475
	else -- 475
		____shotFired_4 = nil -- 475
	end -- 475
	return { -- 472
		shotFired = ____shotFired_5, -- 473
		shotHit = ____shotHit_6, -- 474
		shotTrace = ____shotFired_4, -- 475
		enemyKilledX = enemyKilledX, -- 476
		enemyKilledY = enemyKilledY, -- 477
		playerHit = playerHit, -- 478
		coverDeflect = coverDeflect, -- 479
		rollStarted = rollStarted, -- 480
		knockPulse = knockPulse, -- 481
		knockX = knockX, -- 482
		knockY = knockY, -- 483
		bottleLanded = bottleLanded, -- 484
		bottleLandX = bottleLandX, -- 485
		bottleLandY = bottleLandY, -- 486
		cartJustDocked = cartJustDocked, -- 487
		checkpointJustHit = checkpointJustHit, -- 488
		caughtTriggered = caughtTriggered, -- 489
		phaseChanged = phaseChanged, -- 490
		roomChanged = roomChanged or migratedRoomChange, -- 491
		gateWaveSpawned = gateWaveSpawned, -- 492
		storyRouteLocked = storyRouteLocked, -- 494
		storyRoute = p.storyRoute, -- 495
		gateRested = gateRested, -- 496
		handJustTied = handJustTied, -- 497
		handReleased = handReleased, -- 498
		storyLine = storyLine, -- 499
		storyLineText = storyLineText, -- 500
		storyExit = storyExit, -- 501
		storyExitRoute = storyExitRoute, -- 502
		carryStarted = carryStarted, -- 503
		reloadOpened = reloadOpened, -- 504
		reloadSolved = reloadSolved, -- 505
		reloadEffect = reloadEffect, -- 506
		reloadApplied = reloadApplied, -- 507
		reloadAppliedEffect = reloadAppliedEffect, -- 508
		reloadTimeout = reloadTimeout, -- 509
		reloadInvalid = reloadInvalid, -- 510
		segmentDone = segmentDone, -- 511
		segmentKey = segmentKey, -- 512
		segmentNext = segmentNext, -- 513
		benchOpened = benchOpened, -- 514
		benchCrafted = benchCrafted, -- 515
		benchCraftedWeapon = benchCraftedWeapon, -- 516
		benchEquipped = benchEquipped, -- 517
		benchClosed = benchClosed, -- 518
		benchRejected = benchRejected, -- 519
		benchRejectReason = benchRejectReason, -- 520
		endingReached = endingReached, -- 521
		ending = ending, -- 522
		endingOfficial = endingOfficial, -- 523
		endingLines = endingLines, -- 524
		museumStep = museumStep, -- 525
		museumStepName = museumStepName, -- 526
		museumDone = museumDone, -- 527
		talentPicked = talentPicked, -- 528
		talentPickedId = talentPickedId, -- 529
		talentPickedRank = talentPickedRank, -- 530
		campaignFailedReset = campaignFailedReset, -- 531
		campaignFailedRoom = campaignFailedRoom, -- 532
		fallenBuild = fallenBuild, -- 533
		pickupTaken = pickupTaken, -- 534
		pickupKind = pickupKind, -- 535
		pickupLabel = pickupLabel, -- 536
		pickupRejected = pickupRejected, -- 537
		pickupRejectedKind = pickupRejectedKind, -- 538
		craftStarted = craftStarted, -- 539
		craftDone = craftDone, -- 540
		rawEvents = rawEvents, -- 542
		eventSeq = self.eventSeq, -- 543
		roomSessionId = self.roomSessionId, -- 544
		checkpoint = p.checkpoint, -- 545
		eventSummary = eventSummary -- 546
	} -- 546
end -- 258
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 553
	local room = p.room -- 554
	local player = p.player -- 555
	if p.paused or not player.alive then -- 556
		return nil -- 557
	end -- 557
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 560
		local ____opt_9 = room.story -- 561
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 561
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 561
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 562
			return { -- 563
				x = p.partner.x, -- 563
				y = p.partner.y + p.partner.depth * DEPTH_Y_SCALE + p.partner.h + 22, -- 563
				keyTag = "E", -- 563
				label = "递出指南针", -- 563
				urgent = false -- 563
			} -- 563
		end -- 563
		return nil -- 565
	end -- 565
	if not p.childMode and p.escort.state == "frozen" then -- 568
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 569
			return { -- 570
				x = p.partner.x, -- 570
				y = p.partner.y + p.partner.depth * DEPTH_Y_SCALE + p.partner.h + 22, -- 570
				keyTag = "E", -- 570
				label = "安抚小满", -- 570
				urgent = true -- 570
			} -- 570
		end -- 570
		return nil -- 572
	end -- 572
	local ____opt_11 = room.story -- 575
	local gate = ____opt_11 and ____opt_11.gate -- 575
	if gate ~= nil then -- 576
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 577
			return { -- 580
				x = gate.winchX, -- 580
				y = 84, -- 580
				keyTag = "E", -- 580
				label = "重新守门", -- 580
				urgent = true -- 580
			} -- 580
		end -- 580
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 582
			return { -- 583
				x = gate.doorX, -- 583
				y = 98, -- 583
				keyTag = "E", -- 583
				label = "送小满出城", -- 583
				urgent = true -- 583
			} -- 583
		end -- 583
		if p.phase == "gate-wait" then -- 585
			local ratio = math.max( -- 587
				0, -- 587
				math.min(1, p.handTicks / p.handNeedTicks) -- 587
			) -- 587
			return { -- 588
				x = gate.doorX + 30, -- 589
				y = 96, -- 589
				keyTag = p.handArmed and "按住 E" or "松开再按住 E", -- 590
				label = p.handTicks > 0 and "牵起小满" or "把手伸给她", -- 591
				urgent = p.handArmed, -- 592
				progress = ratio -- 592
			} -- 592
		end -- 592
		if p.phase == "gate-hand" then -- 595
			return { -- 596
				x = gate.doorX + 30, -- 596
				y = 96, -- 596
				keyTag = "E", -- 596
				label = "我们走吧。", -- 596
				urgent = false -- 596
			} -- 596
		end -- 596
		if p.phase == "gate-walk" then -- 598
			return { -- 599
				x = player.x, -- 599
				y = player.y + player.h + 22, -- 599
				keyTag = "→", -- 599
				label = "走向城外", -- 599
				urgent = false -- 599
			} -- 599
		end -- 599
	end -- 599
	if p.reloadOpen then -- 604
		local need = math.max( -- 605
			1, -- 605
			p:reloadNeedTicks() -- 605
		) -- 605
		local ratio = math.max( -- 606
			0, -- 606
			math.min(1, p.reloadAnswerTicks / need) -- 606
		) -- 606
		return { -- 607
			x = player.x, -- 608
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 34, -- 608
			keyTag = "连线", -- 609
			label = "画到枪机复位", -- 609
			urgent = p.reloadAnswerTicks > need * 0.7, -- 609
			progress = ratio -- 609
		} -- 609
	end -- 609
	if p.reloadPendingEffect ~= "" then -- 612
		return { -- 613
			x = player.x, -- 614
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 34, -- 614
			keyTag = "左键", -- 615
			label = "枪机已上势 · 打下一枪", -- 615
			urgent = false -- 615
		} -- 615
	end -- 615
	if room.key == "gatepath" and not p.carryOn then -- 618
		return { -- 619
			x = player.x, -- 619
			y = player.y + player.h + 24, -- 619
			keyTag = "→", -- 619
			label = "走到高石阶", -- 619
			urgent = false -- 619
		} -- 619
	end -- 619
	if room.key == "escort3" and not p.craftBench.active then -- 621
		local bench = 560 -- 622
		if math.abs(player.x - bench) <= p.benchReach + 40 and player.y < 12 then -- 623
			return { -- 624
				x = bench, -- 624
				y = 92, -- 624
				keyTag = "E", -- 624
				label = "在工台制作", -- 624
				urgent = false -- 624
			} -- 624
		end -- 624
	end -- 624
	if (room.key == "escort2" or room.key == "escort3" or room.key == "escort4" or room.key == "escort5") and p.carryOn then -- 627
		return { -- 628
			x = player.x, -- 628
			y = player.y + player.h + 24, -- 628
			keyTag = "→", -- 628
			label = "带她走到出口", -- 628
			urgent = false -- 628
		} -- 628
	end -- 628
	local cart = room.cart -- 631
	if (room.key == "checkpoint" or room.key == "outside" or room.key == "c2-granary") and not p.cartDocked and cart.bodyW > 0 then -- 632
		local handleX = p.cartAxle + cart.handleOffset -- 633
		if p.gripping or p:cartHandleInReach() then -- 634
			return { -- 635
				x = handleX, -- 636
				y = cart.baseY + (cart.depth or 0) * DEPTH_Y_SCALE + cart.wheelR + cart.bodyH + 46, -- 637
				keyTag = room.key == "c2-granary" and "E 握柄 + D" or "按住 E + D", -- 638
				label = room.key == "outside" and "向前拉车" or "向前推车", -- 639
				urgent = false -- 640
			} -- 640
		end -- 640
	end -- 640
	if p.isCampaign then -- 645
		local bi = 0 -- 646
		do -- 646
			bi = 0 -- 647
			while bi < #p.boxes do -- 647
				do -- 647
					local b = p.boxes[bi + 1] -- 648
					if b.broken == true or b.hidden == true or b.interact == nil then -- 649
						goto __continue80 -- 650
					end -- 650
					local cx = (b.x0 + b.x1) * 0.5 -- 652
					local reach = b.interact.reach or 46 -- 653
					if math.abs(player.x - cx) <= reach + 16 and overlapsDepth(player.depth, b.depth, 16) then -- 654
						local kind = b.interact.kind -- 655
						local label = kind == "open_board" and "放下窗板" or (kind == "lower_curtain" and "放下木帘" or "抬起门锁") -- 656
						return { -- 658
							x = cx, -- 658
							y = b.y1 + 24, -- 658
							keyTag = "E", -- 658
							label = label, -- 658
							urgent = true -- 658
						} -- 658
					end -- 658
				end -- 658
				::__continue80:: -- 658
				bi = bi + 1 -- 647
			end -- 647
		end -- 647
	end -- 647
	if room.key == "village" and p.scavChase then -- 663
		local ____player_crouch_13 -- 664
		if player.crouch then -- 664
			____player_crouch_13 = nil -- 664
		else -- 664
			____player_crouch_13 = { -- 664
				x = player.x, -- 665
				y = player.y + player.h + 22, -- 665
				keyTag = "按住 Ctrl", -- 665
				label = "蹲下躲避", -- 665
				urgent = true -- 665
			} -- 665
		end -- 665
		return ____player_crouch_13 -- 664
	end -- 664
	if room.key == "village" and not p.passed then -- 669
		local bottle = room.bottle -- 670
		if p.hasBottle then -- 671
			return { -- 672
				x = player.x, -- 673
				y = player.y + player.h + 26, -- 673
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 674
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 675
				urgent = false -- 675
			} -- 675
		end -- 675
		if p.bottleFly == nil and bottle ~= nil then -- 678
			local dx = player.x - bottle.x -- 679
			local dy = player.y + player.h * 0.5 - bottle.y -- 680
			if dx * dx + dy * dy < 56 * 56 then -- 681
				return { -- 682
					x = bottle.x, -- 682
					y = bottle.y + 36, -- 682
					keyTag = "E", -- 682
					label = "拾起瓶子", -- 682
					urgent = false -- 682
				} -- 682
			end -- 682
		end -- 682
	end -- 682
	local arch = room.arch -- 687
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 688
		return { -- 691
			x = (arch.x0 + arch.x1) * 0.5, -- 692
			y = arch.y + arch.h + 44, -- 692
			keyTag = "按住 Ctrl", -- 693
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 693
			urgent = false -- 693
		} -- 693
	end -- 693
	local ____opt_14 = room.story -- 697
	local museum = ____opt_14 and ____opt_14.museum -- 697
	if room.key == "museum" and museum ~= nil then -- 698
		if p.phase == "museum-cabinet" then -- 699
			return { -- 700
				x = museum.cabinetX, -- 700
				y = 64 + 44, -- 700
				keyTag = "E", -- 700
				label = "玻璃柜前 · 收枪入袖", -- 700
				urgent = true -- 700
			} -- 700
		end -- 700
		if p.phase == "museum-hall" then -- 702
			return { -- 703
				x = museum.hallX, -- 703
				y = 120, -- 703
				keyTag = "走到", -- 703
				label = "西厅那头 · 孩子的脚步", -- 703
				urgent = false -- 703
			} -- 703
		end -- 703
		if p.phase == "museum-lamp" then -- 705
			return { -- 706
				x = museum.lampX, -- 706
				y = 120, -- 706
				keyTag = "E", -- 706
				label = "末厅 · 把灯转向西窗", -- 706
				urgent = true -- 706
			} -- 706
		end -- 706
		if p.phase == "museum-return" then -- 708
			return { -- 709
				x = museum.cabinetX, -- 709
				y = 64 + 44, -- 709
				keyTag = "E", -- 709
				label = "回柜边 · 轻敲两下", -- 709
				urgent = true -- 709
			} -- 709
		end -- 709
		if p.phase == "museum-done" then -- 711
			return { -- 712
				x = museum.cabinetX, -- 712
				y = 64 + 44, -- 712
				keyTag = "E", -- 712
				label = "回柜边 · 灯还亮着", -- 712
				urgent = false -- 712
			} -- 712
		end -- 712
		return nil -- 714
	end -- 714
	local ____opt_16 = room.story -- 717
	local tower = ____opt_16 and ____opt_16.tower -- 717
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 718
		return { -- 719
			x = tower.doorX, -- 719
			y = 96, -- 719
			keyTag = "E", -- 719
			label = "敲两下 · 守卒应门", -- 719
			urgent = false -- 719
		} -- 719
	end -- 719
	if p.phase == "tower-enter" then -- 721
		return { -- 722
			x = 605, -- 722
			y = 64, -- 722
			keyTag = "→", -- 722
			label = "跨过门槛 · 走到值夜桌前", -- 722
			urgent = false -- 722
		} -- 722
	end -- 722
	if p.phase == "tower-desk" then -- 724
		return { -- 725
			x = 605, -- 726
			y = 64, -- 726
			keyTag = "按住 E", -- 726
			label = "交出针套、指南针和纸条", -- 726
			progress = p.deskHold / 36, -- 727
			urgent = true -- 727
		} -- 727
	end -- 727
	if p.phase == "tower-given" then -- 730
		return { -- 731
			x = 605, -- 731
			y = 64, -- 731
			keyTag = "", -- 731
			label = "看登记簿 · 西窗的灯", -- 731
			urgent = false -- 731
		} -- 731
	end -- 731
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 734
		return { -- 736
			x = player.x, -- 737
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 25, -- 737
			keyTag = "按住 Shift", -- 738
			label = "贴靠掩体", -- 738
			urgent = gate ~= nil -- 738
		} -- 738
	end -- 738
	return nil -- 741
end -- 553
return ____exports -- 553
