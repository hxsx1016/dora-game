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
function ____exports.createEmptyFrameEvents(roomSessionId, eventSeq, checkpoint) -- 107
	return { -- 112
		shotFired = false, -- 113
		shotHit = false, -- 114
		shotTrace = nil, -- 115
		enemyKilledX = -9999, -- 116
		enemyKilledY = 0, -- 117
		playerHit = false, -- 118
		coverDeflect = false, -- 119
		rollStarted = false, -- 120
		knockPulse = false, -- 121
		knockX = 0, -- 122
		knockY = 0, -- 123
		bottleLanded = false, -- 124
		bottleLandX = -1, -- 125
		bottleLandY = 0, -- 126
		cartJustDocked = false, -- 127
		checkpointJustHit = false, -- 128
		caughtTriggered = false, -- 129
		phaseChanged = false, -- 130
		roomChanged = false, -- 131
		gateWaveSpawned = false, -- 132
		storyRouteLocked = false, -- 133
		storyRoute = "", -- 134
		gateRested = false, -- 135
		handJustTied = false, -- 136
		handReleased = false, -- 137
		storyLine = false, -- 138
		storyLineText = "", -- 139
		storyExit = false, -- 140
		storyExitRoute = "", -- 141
		carryStarted = false, -- 142
		reloadOpened = false, -- 143
		reloadSolved = false, -- 144
		reloadEffect = "", -- 145
		reloadApplied = false, -- 146
		reloadAppliedEffect = "", -- 147
		reloadTimeout = false, -- 148
		reloadInvalid = false, -- 149
		segmentDone = false, -- 150
		segmentKey = "", -- 151
		segmentNext = "", -- 152
		benchOpened = false, -- 153
		benchCrafted = false, -- 154
		benchCraftedWeapon = "", -- 155
		benchEquipped = false, -- 156
		benchClosed = false, -- 157
		benchRejected = false, -- 158
		benchRejectReason = "", -- 159
		endingReached = false, -- 160
		ending = "", -- 161
		endingOfficial = false, -- 162
		endingLines = {}, -- 163
		museumStep = false, -- 164
		museumStepName = "", -- 165
		museumDone = false, -- 166
		talentPicked = false, -- 167
		talentPickedId = "", -- 168
		talentPickedRank = 0, -- 169
		campaignFailedReset = false, -- 170
		campaignFailedRoom = "", -- 171
		pickupTaken = false, -- 172
		pickupKind = "", -- 173
		pickupLabel = "", -- 174
		pickupRejected = false, -- 175
		pickupRejectedKind = "", -- 176
		craftStarted = false, -- 177
		craftDone = false, -- 178
		rawEvents = {}, -- 179
		eventSeq = eventSeq, -- 180
		roomSessionId = roomSessionId, -- 181
		checkpoint = checkpoint, -- 182
		eventSummary = {} -- 183
	} -- 183
end -- 107
____exports.PlayAdapter = __TS__Class() -- 198
local PlayAdapter = ____exports.PlayAdapter -- 198
PlayAdapter.name = "PlayAdapter" -- 198
function PlayAdapter.prototype.____constructor(self) -- 198
	self.prevRoomKey = "" -- 199
	self.prevPhase = "" -- 200
	self.prevHp = 3 -- 201
	self.prevCoveredFlash = 0 -- 203
	self.prevRollT = 0 -- 204
	self.prevCalmTick = 0 -- 205
	self.prevKnocks = 0 -- 206
	self.prevBottleLandT = 0 -- 207
	self.prevCartDocked = false -- 208
	self.prevCheckpoint = -1 -- 209
	self.prevCaughtT = 0 -- 210
	self.prevGateSpawned = 0 -- 211
	self.prevAliveMask = {} -- 212
	self.roomSessionId = 0 -- 213
	self.eventSeq = 0 -- 214
end -- 198
function PlayAdapter.prototype.getRoomSessionId(self) -- 216
	return self.roomSessionId -- 217
end -- 216
function PlayAdapter.prototype.getEventSeq(self) -- 220
	return self.eventSeq -- 221
end -- 220
function PlayAdapter.prototype.emptyFrame(self, p) -- 224
	return ____exports.createEmptyFrameEvents(self.roomSessionId, self.eventSeq, p ~= nil and p.checkpoint or -1) -- 225
end -- 224
function PlayAdapter.prototype.reset(self, p) -- 232
	self.roomSessionId = self.roomSessionId + 1 -- 233
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 234
	self.prevPhase = p ~= nil and p.phase or "" -- 235
	self.prevHp = p ~= nil and p.hp or 3 -- 236
	self.prevTrace = nil -- 237
	self.prevCoveredFlash = 0 -- 238
	self.prevRollT = 0 -- 239
	self.prevCalmTick = 0 -- 240
	self.prevKnocks = 0 -- 241
	self.prevBottleLandT = 0 -- 242
	local ____temp_0 -- 243
	if p ~= nil then -- 243
		____temp_0 = p.cartDocked -- 243
	else -- 243
		____temp_0 = false -- 243
	end -- 243
	self.prevCartDocked = ____temp_0 -- 243
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 244
	self.prevCaughtT = 0 -- 245
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 246
	self.prevAliveMask = {} -- 247
	if p ~= nil then -- 248
		local i = 0 -- 249
		do -- 249
			i = 0 -- 250
			while i < #p.enemies do -- 250
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 251
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 251
				i = i + 1 -- 250
			end -- 250
		end -- 250
	end -- 250
end -- 232
function PlayAdapter.prototype.sample(self, p) -- 257
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 258
	if roomChanged then -- 259
		self:reset(p) -- 260
	end -- 260
	local rawEvents = p:drainEvents() -- 263
	if #rawEvents > 1 then -- 265
		__TS__ArraySort( -- 266
			rawEvents, -- 266
			function(____, a, b) return a.seq ~= b.seq and a.seq - b.seq or a.tick - b.tick end -- 266
		) -- 266
	end -- 266
	local eventSummary = {} -- 268
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 269
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 270
	local enemyKilledX = -9999 -- 271
	local enemyKilledY = 0 -- 272
	local i = 0 -- 273
	do -- 273
		i = 0 -- 274
		while i < #p.enemies do -- 274
			local ____temp_2 -- 275
			if i < #self.prevAliveMask then -- 275
				____temp_2 = self.prevAliveMask[i + 1] -- 275
			else -- 275
				____temp_2 = true -- 275
			end -- 275
			local wasAlive = ____temp_2 -- 275
			if wasAlive and not p.enemies[i + 1].alive then -- 276
				enemyKilledX = p.enemies[i + 1].x -- 277
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) * DEPTH_Y_SCALE + p.enemies[i + 1].h * 0.55 -- 278
			end -- 278
			i = i + 1 -- 274
		end -- 274
	end -- 274
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 282
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 283
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 284
	local knockPulse = false -- 287
	local knockX = p.player.x -- 288
	local knockY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.5 -- 289
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 291
	local bottleLandX = p.bottleLandX -- 292
	local bottleLandY = p.bottleLandY -- 293
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 294
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 295
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 296
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 297
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 298
	local migratedRoomChange = false -- 299
	local storyRouteLocked = false -- 301
	local gateRested = false -- 302
	local handJustTied = false -- 303
	local handReleased = false -- 304
	local storyLine = false -- 305
	local storyLineText = "" -- 306
	local storyExit = false -- 307
	local storyExitRoute = "" -- 308
	local carryStarted = false -- 309
	local reloadOpened = false -- 310
	local reloadSolved = false -- 311
	local reloadEffect = "" -- 312
	local reloadApplied = false -- 313
	local reloadAppliedEffect = "" -- 314
	local reloadTimeout = false -- 315
	local reloadInvalid = false -- 316
	local segmentDone = false -- 317
	local segmentKey = "" -- 318
	local segmentNext = "" -- 319
	local benchOpened = false -- 320
	local benchCrafted = false -- 321
	local benchCraftedWeapon = "" -- 322
	local benchEquipped = false -- 323
	local benchClosed = false -- 324
	local benchRejected = false -- 325
	local benchRejectReason = "" -- 326
	local endingReached = false -- 327
	local museumStep = false -- 328
	local museumStepName = "" -- 329
	local museumDone = false -- 330
	local ending = "" -- 331
	local endingOfficial = false -- 332
	local endingLines = {} -- 333
	local talentPicked = false -- 334
	local talentPickedId = "" -- 335
	local talentPickedRank = 0 -- 336
	local campaignFailedReset = false -- 337
	local campaignFailedRoom = "" -- 338
	local pickupTaken = false -- 339
	local pickupKind = "" -- 340
	local pickupLabel = "" -- 341
	local pickupRejected = false -- 342
	local pickupRejectedKind = "" -- 343
	local craftStarted = false -- 344
	local craftDone = false -- 345
	for ____, event in ipairs(rawEvents) do -- 346
		self.eventSeq = self.eventSeq + 1 -- 347
		eventSummary[#eventSummary + 1] = (((tostring(event.seq) .. "@") .. tostring(event.tick)) .. ":") .. event.name -- 348
		if event.name == "knock" then -- 350
			knockPulse = true -- 351
			local x = event.data.x -- 352
			knockX = type(x) == "number" and x or p.player.x -- 353
			knockY = p.escort.state == "calming" and p.partner.y + p.partner.depth * DEPTH_Y_SCALE + 28 or p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.55 -- 354
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 357
			playerHit = true -- 358
		elseif event.name == "coverBlocked" then -- 359
			coverDeflect = true -- 360
		elseif event.name == "bottleLanded" then -- 361
			bottleLanded = true -- 362
			if type(event.data.x) == "number" then -- 363
				bottleLandX = event.data.x -- 364
			end -- 364
			if type(event.data.y) == "number" then -- 366
				bottleLandY = event.data.y -- 367
			end -- 367
		elseif event.name == "cartDocked" then -- 369
			cartJustDocked = true -- 370
		elseif event.name == "roomChange" then -- 371
			migratedRoomChange = true -- 372
		elseif event.name == "storyRouteLocked" then -- 373
			storyRouteLocked = true -- 374
		elseif event.name == "gateCountDone" and p.storyRoute == "soldier" then -- 375
			gateRested = true -- 376
		elseif event.name == "handHeld" then -- 377
			handJustTied = true -- 378
		elseif event.name == "handRelease" then -- 379
			handReleased = true -- 380
		elseif event.name == "storyLine" then -- 381
			storyLine = true -- 382
			storyLineText = type(event.data.text) == "string" and event.data.text or "" -- 383
		elseif event.name == "storyExit" then -- 384
			storyExit = true -- 385
			storyExitRoute = type(event.data.route) == "string" and event.data.route or "" -- 386
		elseif event.name == "carryStart" then -- 387
			carryStarted = true -- 388
		elseif event.name == "reloadOpen" then -- 389
			reloadOpened = true -- 390
		elseif event.name == "reloadSolved" then -- 391
			reloadSolved = true -- 392
			reloadEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 393
		elseif event.name == "reloadApplied" then -- 394
			reloadApplied = true -- 395
			reloadAppliedEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 396
		elseif event.name == "reloadTimeout" then -- 397
			reloadTimeout = true -- 398
		elseif event.name == "reloadInvalid" then -- 399
			reloadInvalid = true -- 400
		elseif event.name == "segmentDone" then -- 401
			segmentDone = true -- 402
			segmentKey = type(event.data.room) == "string" and event.data.room or "" -- 403
			segmentNext = type(event.data.next) == "string" and event.data.next or "" -- 404
		elseif event.name == "benchOpen" then -- 405
			benchOpened = true -- 406
		elseif event.name == "benchCraft" then -- 407
			benchCrafted = true -- 408
			benchCraftedWeapon = type(event.data.weapon) == "string" and event.data.weapon or "" -- 409
		elseif event.name == "benchEquip" then -- 410
			benchEquipped = true -- 411
		elseif event.name == "benchClose" then -- 412
			benchClosed = true -- 413
		elseif event.name == "benchRejected" then -- 414
			benchRejected = true -- 415
			benchRejectReason = type(event.data.reason) == "string" and event.data.reason or "" -- 416
		elseif event.name == "museumStep" then -- 417
			museumStep = true -- 418
			museumStepName = type(event.data.step) == "string" and event.data.step or "" -- 419
		elseif event.name == "museumDone" then -- 420
			museumDone = true -- 421
		elseif event.name == "endingReached" then -- 422
			endingReached = true -- 423
			ending = type(event.data.ending) == "string" and event.data.ending or "" -- 424
			endingOfficial = event.data.official == true -- 425
			endingLines = __TS__ArrayIsArray(event.data.lines) and __TS__ArrayMap( -- 426
				event.data.lines, -- 427
				function(____, v) return type(v) == "string" and v or "" end -- 427
			) or ({}) -- 428
		elseif event.name == "storyBeat" and event.data.beat == "talent_picked" then -- 429
			talentPicked = true -- 430
			talentPickedId = type(event.data.talent) == "string" and event.data.talent or "" -- 431
			talentPickedRank = type(event.data.rank) == "number" and event.data.rank or 1 -- 432
		elseif event.name == "campaignFailed" and event.data.reset == true then -- 433
			campaignFailedReset = true -- 434
			campaignFailedRoom = type(event.data.room) == "string" and event.data.room or "" -- 435
		elseif event.name == "pickup" then -- 436
			pickupTaken = true -- 437
			pickupKind = type(event.data.kind) == "string" and event.data.kind or "" -- 438
			pickupLabel = type(event.data.label) == "string" and event.data.label or "" -- 439
		elseif event.name == "pickupRejected" then -- 440
			pickupRejected = true -- 441
			pickupRejectedKind = type(event.data.kind) == "string" and event.data.kind or "" -- 442
		elseif event.name == "craftStart" then -- 443
			craftStarted = true -- 444
		elseif event.name == "craftDone" then -- 445
			craftDone = true -- 446
		end -- 446
	end -- 446
	self.prevRoomKey = p.room.key -- 451
	self.prevPhase = p.phase -- 452
	self.prevHp = p.hp -- 453
	self.prevTrace = p.trace -- 454
	self.prevCoveredFlash = p.coveredFlash -- 455
	self.prevRollT = p.player.rollT -- 456
	self.prevCalmTick = p.escort.calmTick -- 457
	self.prevKnocks = p.knocks -- 458
	self.prevBottleLandT = p.bottleLandT -- 459
	self.prevCartDocked = p.cartDocked -- 460
	self.prevCheckpoint = p.checkpoint -- 461
	self.prevCaughtT = p.caughtT -- 462
	self.prevGateSpawned = p.gateSpawned -- 463
	self.prevAliveMask = {} -- 464
	do -- 464
		i = 0 -- 465
		while i < #p.enemies do -- 465
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 466
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 466
			i = i + 1 -- 465
		end -- 465
	end -- 465
	local ____shotFired_5 = shotFired -- 470
	local ____shotHit_6 = shotHit -- 471
	local ____shotFired_4 -- 472
	if shotFired then -- 472
		____shotFired_4 = p.trace -- 472
	else -- 472
		____shotFired_4 = nil -- 472
	end -- 472
	return { -- 469
		shotFired = ____shotFired_5, -- 470
		shotHit = ____shotHit_6, -- 471
		shotTrace = ____shotFired_4, -- 472
		enemyKilledX = enemyKilledX, -- 473
		enemyKilledY = enemyKilledY, -- 474
		playerHit = playerHit, -- 475
		coverDeflect = coverDeflect, -- 476
		rollStarted = rollStarted, -- 477
		knockPulse = knockPulse, -- 478
		knockX = knockX, -- 479
		knockY = knockY, -- 480
		bottleLanded = bottleLanded, -- 481
		bottleLandX = bottleLandX, -- 482
		bottleLandY = bottleLandY, -- 483
		cartJustDocked = cartJustDocked, -- 484
		checkpointJustHit = checkpointJustHit, -- 485
		caughtTriggered = caughtTriggered, -- 486
		phaseChanged = phaseChanged, -- 487
		roomChanged = roomChanged or migratedRoomChange, -- 488
		gateWaveSpawned = gateWaveSpawned, -- 489
		storyRouteLocked = storyRouteLocked, -- 491
		storyRoute = p.storyRoute, -- 492
		gateRested = gateRested, -- 493
		handJustTied = handJustTied, -- 494
		handReleased = handReleased, -- 495
		storyLine = storyLine, -- 496
		storyLineText = storyLineText, -- 497
		storyExit = storyExit, -- 498
		storyExitRoute = storyExitRoute, -- 499
		carryStarted = carryStarted, -- 500
		reloadOpened = reloadOpened, -- 501
		reloadSolved = reloadSolved, -- 502
		reloadEffect = reloadEffect, -- 503
		reloadApplied = reloadApplied, -- 504
		reloadAppliedEffect = reloadAppliedEffect, -- 505
		reloadTimeout = reloadTimeout, -- 506
		reloadInvalid = reloadInvalid, -- 507
		segmentDone = segmentDone, -- 508
		segmentKey = segmentKey, -- 509
		segmentNext = segmentNext, -- 510
		benchOpened = benchOpened, -- 511
		benchCrafted = benchCrafted, -- 512
		benchCraftedWeapon = benchCraftedWeapon, -- 513
		benchEquipped = benchEquipped, -- 514
		benchClosed = benchClosed, -- 515
		benchRejected = benchRejected, -- 516
		benchRejectReason = benchRejectReason, -- 517
		endingReached = endingReached, -- 518
		ending = ending, -- 519
		endingOfficial = endingOfficial, -- 520
		endingLines = endingLines, -- 521
		museumStep = museumStep, -- 522
		museumStepName = museumStepName, -- 523
		museumDone = museumDone, -- 524
		talentPicked = talentPicked, -- 525
		talentPickedId = talentPickedId, -- 526
		talentPickedRank = talentPickedRank, -- 527
		campaignFailedReset = campaignFailedReset, -- 528
		campaignFailedRoom = campaignFailedRoom, -- 529
		pickupTaken = pickupTaken, -- 530
		pickupKind = pickupKind, -- 531
		pickupLabel = pickupLabel, -- 532
		pickupRejected = pickupRejected, -- 533
		pickupRejectedKind = pickupRejectedKind, -- 534
		craftStarted = craftStarted, -- 535
		craftDone = craftDone, -- 536
		rawEvents = rawEvents, -- 538
		eventSeq = self.eventSeq, -- 539
		roomSessionId = self.roomSessionId, -- 540
		checkpoint = p.checkpoint, -- 541
		eventSummary = eventSummary -- 542
	} -- 542
end -- 257
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 549
	local room = p.room -- 550
	local player = p.player -- 551
	if p.paused or not player.alive then -- 552
		return nil -- 553
	end -- 553
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 556
		local ____opt_9 = room.story -- 557
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 557
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 557
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 558
			return { -- 559
				x = p.partner.x, -- 559
				y = p.partner.y + p.partner.depth * DEPTH_Y_SCALE + p.partner.h + 22, -- 559
				keyTag = "E", -- 559
				label = "递出指南针", -- 559
				urgent = false -- 559
			} -- 559
		end -- 559
		return nil -- 561
	end -- 561
	if not p.childMode and p.escort.state == "frozen" then -- 564
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 565
			return { -- 566
				x = p.partner.x, -- 566
				y = p.partner.y + p.partner.depth * DEPTH_Y_SCALE + p.partner.h + 22, -- 566
				keyTag = "E", -- 566
				label = "安抚小满", -- 566
				urgent = true -- 566
			} -- 566
		end -- 566
		return nil -- 568
	end -- 568
	local ____opt_11 = room.story -- 571
	local gate = ____opt_11 and ____opt_11.gate -- 571
	if gate ~= nil then -- 572
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 573
			return { -- 576
				x = gate.winchX, -- 576
				y = 84, -- 576
				keyTag = "E", -- 576
				label = "重新守门", -- 576
				urgent = true -- 576
			} -- 576
		end -- 576
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 578
			return { -- 579
				x = gate.doorX, -- 579
				y = 98, -- 579
				keyTag = "E", -- 579
				label = "送小满出城", -- 579
				urgent = true -- 579
			} -- 579
		end -- 579
		if p.phase == "gate-wait" then -- 581
			local ratio = math.max( -- 583
				0, -- 583
				math.min(1, p.handTicks / p.handNeedTicks) -- 583
			) -- 583
			return { -- 584
				x = gate.doorX + 30, -- 585
				y = 96, -- 585
				keyTag = p.handArmed and "按住 E" or "松开再按住 E", -- 586
				label = p.handTicks > 0 and "牵起小满" or "把手伸给她", -- 587
				urgent = p.handArmed, -- 588
				progress = ratio -- 588
			} -- 588
		end -- 588
		if p.phase == "gate-hand" then -- 591
			return { -- 592
				x = gate.doorX + 30, -- 592
				y = 96, -- 592
				keyTag = "E", -- 592
				label = "我们走吧。", -- 592
				urgent = false -- 592
			} -- 592
		end -- 592
		if p.phase == "gate-walk" then -- 594
			return { -- 595
				x = player.x, -- 595
				y = player.y + player.h + 22, -- 595
				keyTag = "→", -- 595
				label = "走向城外", -- 595
				urgent = false -- 595
			} -- 595
		end -- 595
	end -- 595
	if p.reloadOpen then -- 600
		local ratio = math.max( -- 601
			0, -- 601
			math.min(1, p.reloadAnswerTicks / 240) -- 601
		) -- 601
		return { -- 602
			x = player.x, -- 603
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 34, -- 603
			keyTag = "连线", -- 604
			label = "画到枪机复位", -- 604
			urgent = p.reloadAnswerTicks > 168, -- 604
			progress = ratio -- 604
		} -- 604
	end -- 604
	if p.reloadPendingEffect ~= "" then -- 607
		return { -- 608
			x = player.x, -- 609
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 34, -- 609
			keyTag = "左键", -- 610
			label = "枪机已上势 · 打下一枪", -- 610
			urgent = false -- 610
		} -- 610
	end -- 610
	if room.key == "gatepath" and not p.carryOn then -- 613
		return { -- 614
			x = player.x, -- 614
			y = player.y + player.h + 24, -- 614
			keyTag = "→", -- 614
			label = "走到高石阶", -- 614
			urgent = false -- 614
		} -- 614
	end -- 614
	if room.key == "escort3" and not p.craftBench.active then -- 616
		local bench = 560 -- 617
		if math.abs(player.x - bench) <= p.benchReach + 40 and player.y < 12 then -- 618
			return { -- 619
				x = bench, -- 619
				y = 92, -- 619
				keyTag = "E", -- 619
				label = "在工台制作", -- 619
				urgent = false -- 619
			} -- 619
		end -- 619
	end -- 619
	if (room.key == "escort2" or room.key == "escort3" or room.key == "escort4" or room.key == "escort5") and p.carryOn then -- 622
		return { -- 623
			x = player.x, -- 623
			y = player.y + player.h + 24, -- 623
			keyTag = "→", -- 623
			label = "带她走到出口", -- 623
			urgent = false -- 623
		} -- 623
	end -- 623
	local cart = room.cart -- 626
	if (room.key == "checkpoint" or room.key == "outside" or room.key == "c2-granary") and not p.cartDocked and cart.bodyW > 0 then -- 627
		local handleX = p.cartAxle + cart.handleOffset -- 628
		if p.gripping or p:cartHandleInReach() then -- 629
			return { -- 630
				x = handleX, -- 631
				y = cart.baseY + (cart.depth or 0) * DEPTH_Y_SCALE + cart.wheelR + cart.bodyH + 46, -- 632
				keyTag = room.key == "c2-granary" and "E 握柄 + D" or "按住 E + D", -- 633
				label = room.key == "outside" and "向前拉车" or "向前推车", -- 634
				urgent = false -- 635
			} -- 635
		end -- 635
	end -- 635
	if p.isCampaign then -- 640
		local bi = 0 -- 641
		do -- 641
			bi = 0 -- 642
			while bi < #p.boxes do -- 642
				do -- 642
					local b = p.boxes[bi + 1] -- 643
					if b.broken == true or b.hidden == true or b.interact == nil then -- 644
						goto __continue80 -- 645
					end -- 645
					local cx = (b.x0 + b.x1) * 0.5 -- 647
					local reach = b.interact.reach or 46 -- 648
					if math.abs(player.x - cx) <= reach + 16 and overlapsDepth(player.depth, b.depth, 16) then -- 649
						local kind = b.interact.kind -- 650
						local label = kind == "open_board" and "放下窗板" or (kind == "lower_curtain" and "放下木帘" or "抬起门锁") -- 651
						return { -- 653
							x = cx, -- 653
							y = b.y1 + 24, -- 653
							keyTag = "E", -- 653
							label = label, -- 653
							urgent = true -- 653
						} -- 653
					end -- 653
				end -- 653
				::__continue80:: -- 653
				bi = bi + 1 -- 642
			end -- 642
		end -- 642
	end -- 642
	if room.key == "village" and p.scavChase then -- 658
		local ____player_crouch_13 -- 659
		if player.crouch then -- 659
			____player_crouch_13 = nil -- 659
		else -- 659
			____player_crouch_13 = { -- 659
				x = player.x, -- 660
				y = player.y + player.h + 22, -- 660
				keyTag = "按住 Ctrl", -- 660
				label = "蹲下躲避", -- 660
				urgent = true -- 660
			} -- 660
		end -- 660
		return ____player_crouch_13 -- 659
	end -- 659
	if room.key == "village" and not p.passed then -- 664
		local bottle = room.bottle -- 665
		if p.hasBottle then -- 666
			return { -- 667
				x = player.x, -- 668
				y = player.y + player.h + 26, -- 668
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 669
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 670
				urgent = false -- 670
			} -- 670
		end -- 670
		if p.bottleFly == nil and bottle ~= nil then -- 673
			local dx = player.x - bottle.x -- 674
			local dy = player.y + player.h * 0.5 - bottle.y -- 675
			if dx * dx + dy * dy < 56 * 56 then -- 676
				return { -- 677
					x = bottle.x, -- 677
					y = bottle.y + 36, -- 677
					keyTag = "E", -- 677
					label = "拾起瓶子", -- 677
					urgent = false -- 677
				} -- 677
			end -- 677
		end -- 677
	end -- 677
	local arch = room.arch -- 682
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 683
		return { -- 686
			x = (arch.x0 + arch.x1) * 0.5, -- 687
			y = arch.y + arch.h + 44, -- 687
			keyTag = "按住 Ctrl", -- 688
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 688
			urgent = false -- 688
		} -- 688
	end -- 688
	local ____opt_14 = room.story -- 692
	local museum = ____opt_14 and ____opt_14.museum -- 692
	if room.key == "museum" and museum ~= nil then -- 693
		if p.phase == "museum-cabinet" then -- 694
			return { -- 695
				x = museum.cabinetX, -- 695
				y = 64 + 44, -- 695
				keyTag = "E", -- 695
				label = "玻璃柜前 · 收枪入袖", -- 695
				urgent = true -- 695
			} -- 695
		end -- 695
		if p.phase == "museum-hall" then -- 697
			return { -- 698
				x = museum.hallX, -- 698
				y = 120, -- 698
				keyTag = "走到", -- 698
				label = "西厅那头 · 孩子的脚步", -- 698
				urgent = false -- 698
			} -- 698
		end -- 698
		if p.phase == "museum-lamp" then -- 700
			return { -- 701
				x = museum.lampX, -- 701
				y = 120, -- 701
				keyTag = "E", -- 701
				label = "末厅 · 把灯转向西窗", -- 701
				urgent = true -- 701
			} -- 701
		end -- 701
		if p.phase == "museum-return" then -- 703
			return { -- 704
				x = museum.cabinetX, -- 704
				y = 64 + 44, -- 704
				keyTag = "E", -- 704
				label = "回柜边 · 轻敲两下", -- 704
				urgent = true -- 704
			} -- 704
		end -- 704
		if p.phase == "museum-done" then -- 706
			return { -- 707
				x = museum.cabinetX, -- 707
				y = 64 + 44, -- 707
				keyTag = "E", -- 707
				label = "回柜边 · 灯还亮着", -- 707
				urgent = false -- 707
			} -- 707
		end -- 707
		return nil -- 709
	end -- 709
	local ____opt_16 = room.story -- 712
	local tower = ____opt_16 and ____opt_16.tower -- 712
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 713
		return { -- 714
			x = tower.doorX, -- 714
			y = 96, -- 714
			keyTag = "E", -- 714
			label = "敲两下 · 守卒应门", -- 714
			urgent = false -- 714
		} -- 714
	end -- 714
	if p.phase == "tower-enter" then -- 716
		return { -- 717
			x = 605, -- 717
			y = 64, -- 717
			keyTag = "→", -- 717
			label = "跨过门槛 · 走到值夜桌前", -- 717
			urgent = false -- 717
		} -- 717
	end -- 717
	if p.phase == "tower-desk" then -- 719
		return { -- 720
			x = 605, -- 721
			y = 64, -- 721
			keyTag = "按住 E", -- 721
			label = "交出针套、指南针和纸条", -- 721
			progress = p.deskHold / 36, -- 722
			urgent = true -- 722
		} -- 722
	end -- 722
	if p.phase == "tower-given" then -- 725
		return { -- 726
			x = 605, -- 726
			y = 64, -- 726
			keyTag = "", -- 726
			label = "看登记簿 · 西窗的灯", -- 726
			urgent = false -- 726
		} -- 726
	end -- 726
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 729
		return { -- 731
			x = player.x, -- 732
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 25, -- 732
			keyTag = "按住 Shift", -- 733
			label = "贴靠掩体", -- 733
			urgent = gate ~= nil -- 733
		} -- 733
	end -- 733
	return nil -- 736
end -- 549
return ____exports -- 549
