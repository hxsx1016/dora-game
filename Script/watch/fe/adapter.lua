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
function ____exports.createEmptyFrameEvents(roomSessionId, eventSeq, checkpoint) -- 96
	return { -- 101
		shotFired = false, -- 102
		shotHit = false, -- 103
		shotTrace = nil, -- 104
		enemyKilledX = -9999, -- 105
		enemyKilledY = 0, -- 106
		playerHit = false, -- 107
		coverDeflect = false, -- 108
		rollStarted = false, -- 109
		knockPulse = false, -- 110
		knockX = 0, -- 111
		knockY = 0, -- 112
		bottleLanded = false, -- 113
		bottleLandX = -1, -- 114
		bottleLandY = 0, -- 115
		cartJustDocked = false, -- 116
		checkpointJustHit = false, -- 117
		caughtTriggered = false, -- 118
		phaseChanged = false, -- 119
		roomChanged = false, -- 120
		gateWaveSpawned = false, -- 121
		storyRouteLocked = false, -- 122
		storyRoute = "", -- 123
		gateRested = false, -- 124
		handJustTied = false, -- 125
		handReleased = false, -- 126
		storyLine = false, -- 127
		storyLineText = "", -- 128
		storyExit = false, -- 129
		storyExitRoute = "", -- 130
		carryStarted = false, -- 131
		reloadOpened = false, -- 132
		reloadSolved = false, -- 133
		reloadEffect = "", -- 134
		reloadApplied = false, -- 135
		reloadAppliedEffect = "", -- 136
		reloadTimeout = false, -- 137
		reloadInvalid = false, -- 138
		segmentDone = false, -- 139
		segmentKey = "", -- 140
		segmentNext = "", -- 141
		benchOpened = false, -- 142
		benchCrafted = false, -- 143
		benchCraftedWeapon = "", -- 144
		benchEquipped = false, -- 145
		benchClosed = false, -- 146
		benchRejected = false, -- 147
		benchRejectReason = "", -- 148
		endingReached = false, -- 149
		ending = "", -- 150
		endingOfficial = false, -- 151
		endingLines = {}, -- 152
		museumStep = false, -- 153
		museumStepName = "", -- 154
		museumDone = false, -- 155
		storyBeats = {}, -- 156
		rawEvents = {}, -- 157
		eventSeq = eventSeq, -- 158
		roomSessionId = roomSessionId, -- 159
		checkpoint = checkpoint, -- 160
		eventSummary = {} -- 161
	} -- 161
end -- 96
____exports.PlayAdapter = __TS__Class() -- 176
local PlayAdapter = ____exports.PlayAdapter -- 176
PlayAdapter.name = "PlayAdapter" -- 176
function PlayAdapter.prototype.____constructor(self) -- 176
	self.prevRoomKey = "" -- 177
	self.prevPhase = "" -- 178
	self.prevHp = 3 -- 179
	self.prevCoveredFlash = 0 -- 181
	self.prevRollT = 0 -- 182
	self.prevCalmTick = 0 -- 183
	self.prevKnocks = 0 -- 184
	self.prevBottleLandT = 0 -- 185
	self.prevCartDocked = false -- 186
	self.prevCheckpoint = -1 -- 187
	self.prevCaughtT = 0 -- 188
	self.prevGateSpawned = 0 -- 189
	self.prevAliveMask = {} -- 190
	self.roomSessionId = 0 -- 191
	self.eventSeq = 0 -- 192
end -- 176
function PlayAdapter.prototype.getRoomSessionId(self) -- 194
	return self.roomSessionId -- 195
end -- 194
function PlayAdapter.prototype.getEventSeq(self) -- 198
	return self.eventSeq -- 199
end -- 198
function PlayAdapter.prototype.emptyFrame(self, p) -- 202
	return ____exports.createEmptyFrameEvents(self.roomSessionId, self.eventSeq, p ~= nil and p.checkpoint or -1) -- 203
end -- 202
function PlayAdapter.prototype.reset(self, p) -- 210
	self.roomSessionId = self.roomSessionId + 1 -- 211
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 212
	self.prevPhase = p ~= nil and p.phase or "" -- 213
	self.prevHp = p ~= nil and p.hp or 3 -- 214
	self.prevTrace = nil -- 215
	self.prevCoveredFlash = 0 -- 216
	self.prevRollT = 0 -- 217
	self.prevCalmTick = 0 -- 218
	self.prevKnocks = 0 -- 219
	self.prevBottleLandT = 0 -- 220
	local ____temp_0 -- 221
	if p ~= nil then -- 221
		____temp_0 = p.cartDocked -- 221
	else -- 221
		____temp_0 = false -- 221
	end -- 221
	self.prevCartDocked = ____temp_0 -- 221
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 222
	self.prevCaughtT = 0 -- 223
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 224
	self.prevAliveMask = {} -- 225
	if p ~= nil then -- 226
		local i = 0 -- 227
		do -- 227
			i = 0 -- 228
			while i < #p.enemies do -- 228
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 229
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 229
				i = i + 1 -- 228
			end -- 228
		end -- 228
	end -- 228
end -- 210
function PlayAdapter.prototype.sample(self, p) -- 235
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 236
	if roomChanged then -- 237
		self:reset(p) -- 238
	end -- 238
	local rawEvents = p:drainEvents() -- 241
	if #rawEvents > 1 then -- 243
		__TS__ArraySort( -- 244
			rawEvents, -- 244
			function(____, a, b) return a.seq ~= b.seq and a.seq - b.seq or a.tick - b.tick end -- 244
		) -- 244
	end -- 244
	local eventSummary = {} -- 246
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 247
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 248
	local enemyKilledX = -9999 -- 249
	local enemyKilledY = 0 -- 250
	local i = 0 -- 251
	do -- 251
		i = 0 -- 252
		while i < #p.enemies do -- 252
			local ____temp_2 -- 253
			if i < #self.prevAliveMask then -- 253
				____temp_2 = self.prevAliveMask[i + 1] -- 253
			else -- 253
				____temp_2 = true -- 253
			end -- 253
			local wasAlive = ____temp_2 -- 253
			if wasAlive and not p.enemies[i + 1].alive then -- 254
				enemyKilledX = p.enemies[i + 1].x -- 255
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) * DEPTH_Y_SCALE + p.enemies[i + 1].h * 0.55 -- 256
			end -- 256
			i = i + 1 -- 252
		end -- 252
	end -- 252
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 260
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 261
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 262
	local knockPulse = false -- 265
	local knockX = p.player.x -- 266
	local knockY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.5 -- 267
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 269
	local bottleLandX = p.bottleLandX -- 270
	local bottleLandY = p.bottleLandY -- 271
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 272
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 273
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 274
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 275
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 276
	local migratedRoomChange = false -- 277
	local storyRouteLocked = false -- 279
	local gateRested = false -- 280
	local handJustTied = false -- 281
	local handReleased = false -- 282
	local storyLine = false -- 283
	local storyLineText = "" -- 284
	local storyExit = false -- 285
	local storyExitRoute = "" -- 286
	local carryStarted = false -- 287
	local reloadOpened = false -- 288
	local reloadSolved = false -- 289
	local reloadEffect = "" -- 290
	local reloadApplied = false -- 291
	local reloadAppliedEffect = "" -- 292
	local reloadTimeout = false -- 293
	local reloadInvalid = false -- 294
	local segmentDone = false -- 295
	local segmentKey = "" -- 296
	local segmentNext = "" -- 297
	local benchOpened = false -- 298
	local benchCrafted = false -- 299
	local benchCraftedWeapon = "" -- 300
	local benchEquipped = false -- 301
	local benchClosed = false -- 302
	local benchRejected = false -- 303
	local benchRejectReason = "" -- 304
	local endingReached = false -- 305
	local museumStep = false -- 306
	local museumStepName = "" -- 307
	local museumDone = false -- 308
	local ending = "" -- 309
	local endingOfficial = false -- 310
	local endingLines = {} -- 311
	local storyBeats = {} -- 312
	for ____, event in ipairs(rawEvents) do -- 313
		self.eventSeq = self.eventSeq + 1 -- 314
		eventSummary[#eventSummary + 1] = (((tostring(event.seq) .. "@") .. tostring(event.tick)) .. ":") .. event.name -- 315
		if event.name == "knock" then -- 317
			knockPulse = true -- 318
			local x = event.data.x -- 319
			knockX = type(x) == "number" and x or p.player.x -- 320
			knockY = p.escort.state == "calming" and p.partner.y + p.partner.depth * DEPTH_Y_SCALE + 28 or p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.55 -- 321
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 324
			playerHit = true -- 325
		elseif event.name == "coverBlocked" then -- 326
			coverDeflect = true -- 327
		elseif event.name == "bottleLanded" then -- 328
			bottleLanded = true -- 329
			if type(event.data.x) == "number" then -- 330
				bottleLandX = event.data.x -- 331
			end -- 331
			if type(event.data.y) == "number" then -- 333
				bottleLandY = event.data.y -- 334
			end -- 334
		elseif event.name == "cartDocked" then -- 336
			cartJustDocked = true -- 337
		elseif event.name == "roomChange" then -- 338
			migratedRoomChange = true -- 339
		elseif event.name == "storyRouteLocked" then -- 340
			storyRouteLocked = true -- 341
		elseif event.name == "gateCountDone" and p.storyRoute == "soldier" then -- 342
			gateRested = true -- 343
		elseif event.name == "handHeld" then -- 344
			handJustTied = true -- 345
		elseif event.name == "handRelease" then -- 346
			handReleased = true -- 347
		elseif event.name == "storyLine" then -- 348
			storyLine = true -- 349
			storyLineText = type(event.data.text) == "string" and event.data.text or "" -- 350
		elseif event.name == "storyExit" then -- 351
			storyExit = true -- 352
			storyExitRoute = type(event.data.route) == "string" and event.data.route or "" -- 353
		elseif event.name == "carryStart" then -- 354
			carryStarted = true -- 355
		elseif event.name == "reloadOpen" then -- 356
			reloadOpened = true -- 357
		elseif event.name == "reloadSolved" then -- 358
			reloadSolved = true -- 359
			reloadEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 360
		elseif event.name == "reloadApplied" then -- 361
			reloadApplied = true -- 362
			reloadAppliedEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 363
		elseif event.name == "reloadTimeout" then -- 364
			reloadTimeout = true -- 365
		elseif event.name == "reloadInvalid" then -- 366
			reloadInvalid = true -- 367
		elseif event.name == "segmentDone" then -- 368
			segmentDone = true -- 369
			segmentKey = type(event.data.room) == "string" and event.data.room or "" -- 370
			segmentNext = type(event.data.next) == "string" and event.data.next or "" -- 371
		elseif event.name == "benchOpen" then -- 372
			benchOpened = true -- 373
		elseif event.name == "benchCraft" then -- 374
			benchCrafted = true -- 375
			benchCraftedWeapon = type(event.data.weapon) == "string" and event.data.weapon or "" -- 376
		elseif event.name == "benchEquip" then -- 377
			benchEquipped = true -- 378
		elseif event.name == "benchClose" then -- 379
			benchClosed = true -- 380
		elseif event.name == "benchRejected" then -- 381
			benchRejected = true -- 382
			benchRejectReason = type(event.data.reason) == "string" and event.data.reason or "" -- 383
		elseif event.name == "museumStep" then -- 384
			museumStep = true -- 385
			museumStepName = type(event.data.step) == "string" and event.data.step or "" -- 386
		elseif event.name == "museumDone" then -- 387
			museumDone = true -- 388
		elseif event.name == "storyBeat" then -- 389
			storyBeats[#storyBeats + 1] = { -- 390
				beat = type(event.data.beat) == "string" and event.data.beat or "", -- 391
				x = type(event.data.x) == "number" and event.data.x or p.player.x, -- 392
				room = type(event.data.room) == "string" and event.data.room or p.room.key, -- 393
				item = type(event.data.item) == "string" and event.data.item or "" -- 394
			} -- 394
		elseif event.name == "endingReached" then -- 396
			endingReached = true -- 397
			ending = type(event.data.ending) == "string" and event.data.ending or "" -- 398
			endingOfficial = event.data.official == true -- 399
			endingLines = __TS__ArrayIsArray(event.data.lines) and __TS__ArrayMap( -- 400
				event.data.lines, -- 401
				function(____, v) return type(v) == "string" and v or "" end -- 401
			) or ({}) -- 402
		end -- 402
	end -- 402
	self.prevRoomKey = p.room.key -- 407
	self.prevPhase = p.phase -- 408
	self.prevHp = p.hp -- 409
	self.prevTrace = p.trace -- 410
	self.prevCoveredFlash = p.coveredFlash -- 411
	self.prevRollT = p.player.rollT -- 412
	self.prevCalmTick = p.escort.calmTick -- 413
	self.prevKnocks = p.knocks -- 414
	self.prevBottleLandT = p.bottleLandT -- 415
	self.prevCartDocked = p.cartDocked -- 416
	self.prevCheckpoint = p.checkpoint -- 417
	self.prevCaughtT = p.caughtT -- 418
	self.prevGateSpawned = p.gateSpawned -- 419
	self.prevAliveMask = {} -- 420
	do -- 420
		i = 0 -- 421
		while i < #p.enemies do -- 421
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 422
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 422
			i = i + 1 -- 421
		end -- 421
	end -- 421
	local ____shotFired_5 = shotFired -- 426
	local ____shotHit_6 = shotHit -- 427
	local ____shotFired_4 -- 428
	if shotFired then -- 428
		____shotFired_4 = p.trace -- 428
	else -- 428
		____shotFired_4 = nil -- 428
	end -- 428
	return { -- 425
		shotFired = ____shotFired_5, -- 426
		shotHit = ____shotHit_6, -- 427
		shotTrace = ____shotFired_4, -- 428
		enemyKilledX = enemyKilledX, -- 429
		enemyKilledY = enemyKilledY, -- 430
		playerHit = playerHit, -- 431
		coverDeflect = coverDeflect, -- 432
		rollStarted = rollStarted, -- 433
		knockPulse = knockPulse, -- 434
		knockX = knockX, -- 435
		knockY = knockY, -- 436
		bottleLanded = bottleLanded, -- 437
		bottleLandX = bottleLandX, -- 438
		bottleLandY = bottleLandY, -- 439
		cartJustDocked = cartJustDocked, -- 440
		checkpointJustHit = checkpointJustHit, -- 441
		caughtTriggered = caughtTriggered, -- 442
		phaseChanged = phaseChanged, -- 443
		roomChanged = roomChanged or migratedRoomChange, -- 444
		gateWaveSpawned = gateWaveSpawned, -- 445
		storyRouteLocked = storyRouteLocked, -- 447
		storyRoute = p.storyRoute, -- 448
		gateRested = gateRested, -- 449
		handJustTied = handJustTied, -- 450
		handReleased = handReleased, -- 451
		storyLine = storyLine, -- 452
		storyLineText = storyLineText, -- 453
		storyExit = storyExit, -- 454
		storyExitRoute = storyExitRoute, -- 455
		carryStarted = carryStarted, -- 456
		reloadOpened = reloadOpened, -- 457
		reloadSolved = reloadSolved, -- 458
		reloadEffect = reloadEffect, -- 459
		reloadApplied = reloadApplied, -- 460
		reloadAppliedEffect = reloadAppliedEffect, -- 461
		reloadTimeout = reloadTimeout, -- 462
		reloadInvalid = reloadInvalid, -- 463
		segmentDone = segmentDone, -- 464
		segmentKey = segmentKey, -- 465
		segmentNext = segmentNext, -- 466
		benchOpened = benchOpened, -- 467
		benchCrafted = benchCrafted, -- 468
		benchCraftedWeapon = benchCraftedWeapon, -- 469
		benchEquipped = benchEquipped, -- 470
		benchClosed = benchClosed, -- 471
		benchRejected = benchRejected, -- 472
		benchRejectReason = benchRejectReason, -- 473
		endingReached = endingReached, -- 474
		ending = ending, -- 475
		endingOfficial = endingOfficial, -- 476
		endingLines = endingLines, -- 477
		museumStep = museumStep, -- 478
		museumStepName = museumStepName, -- 479
		museumDone = museumDone, -- 480
		storyBeats = storyBeats, -- 481
		rawEvents = rawEvents, -- 483
		eventSeq = self.eventSeq, -- 484
		roomSessionId = self.roomSessionId, -- 485
		checkpoint = p.checkpoint, -- 486
		eventSummary = eventSummary -- 487
	} -- 487
end -- 235
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 494
	local room = p.room -- 495
	local player = p.player -- 496
	if p.paused or not player.alive then -- 497
		return nil -- 498
	end -- 498
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 501
		local ____opt_9 = room.story -- 502
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 502
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 502
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 503
			return { -- 504
				x = p.partner.x, -- 504
				y = p.partner.y + p.partner.depth * DEPTH_Y_SCALE + p.partner.h + 22, -- 504
				keyTag = "E", -- 504
				label = "递出指南针", -- 504
				urgent = false -- 504
			} -- 504
		end -- 504
		return nil -- 506
	end -- 506
	if not p.childMode and p.escort.state == "frozen" then -- 509
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 510
			return { -- 511
				x = p.partner.x, -- 511
				y = p.partner.y + p.partner.depth * DEPTH_Y_SCALE + p.partner.h + 22, -- 511
				keyTag = "E", -- 511
				label = "安抚小满", -- 511
				urgent = true -- 511
			} -- 511
		end -- 511
		return nil -- 513
	end -- 513
	local ____opt_11 = room.story -- 516
	local gate = ____opt_11 and ____opt_11.gate -- 516
	if gate ~= nil then -- 517
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 518
			return { -- 521
				x = gate.winchX, -- 521
				y = 84, -- 521
				keyTag = "E", -- 521
				label = "重新守门", -- 521
				urgent = true -- 521
			} -- 521
		end -- 521
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 523
			return { -- 524
				x = gate.doorX, -- 524
				y = 98, -- 524
				keyTag = "E", -- 524
				label = "送小满出城", -- 524
				urgent = true -- 524
			} -- 524
		end -- 524
		if p.phase == "gate-wait" then -- 526
			local ratio = math.max( -- 528
				0, -- 528
				math.min(1, p.handTicks / p.handNeedTicks) -- 528
			) -- 528
			return { -- 529
				x = gate.doorX + 30, -- 530
				y = 96, -- 530
				keyTag = p.handArmed and "按住 E" or "松开再按住 E", -- 531
				label = p.handTicks > 0 and "牵起小满" or "把手伸给她", -- 532
				urgent = p.handArmed, -- 533
				progress = ratio -- 533
			} -- 533
		end -- 533
		if p.phase == "gate-hand" then -- 536
			return { -- 537
				x = gate.doorX + 30, -- 537
				y = 96, -- 537
				keyTag = "E", -- 537
				label = "我们走吧。", -- 537
				urgent = false -- 537
			} -- 537
		end -- 537
		if p.phase == "gate-walk" then -- 539
			return { -- 540
				x = player.x, -- 540
				y = player.y + player.h + 22, -- 540
				keyTag = "→", -- 540
				label = "走向城外", -- 540
				urgent = false -- 540
			} -- 540
		end -- 540
	end -- 540
	if p.reloadOpen then -- 545
		local ratio = math.max( -- 546
			0, -- 546
			math.min(1, p.reloadAnswerTicks / 240) -- 546
		) -- 546
		return { -- 547
			x = player.x, -- 548
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 34, -- 548
			keyTag = "连线", -- 549
			label = "画到枪机复位", -- 549
			urgent = p.reloadAnswerTicks > 168, -- 549
			progress = ratio -- 549
		} -- 549
	end -- 549
	if p.reloadPendingEffect ~= "" then -- 552
		return { -- 553
			x = player.x, -- 554
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 34, -- 554
			keyTag = "左键", -- 555
			label = "枪机已上势 · 打下一枪", -- 555
			urgent = false -- 555
		} -- 555
	end -- 555
	if room.key == "gatepath" and not p.carryOn then -- 558
		return { -- 559
			x = player.x, -- 559
			y = player.y + player.h + 24, -- 559
			keyTag = "→", -- 559
			label = "走到高石阶", -- 559
			urgent = false -- 559
		} -- 559
	end -- 559
	if room.key == "escort3" and not p.craftBench.active then -- 561
		local bench = 560 -- 562
		if math.abs(player.x - bench) <= p.benchReach + 40 and player.y < 12 then -- 563
			return { -- 564
				x = bench, -- 564
				y = 92, -- 564
				keyTag = "E", -- 564
				label = "在工台制作", -- 564
				urgent = false -- 564
			} -- 564
		end -- 564
	end -- 564
	if (room.key == "escort2" or room.key == "escort3" or room.key == "escort4" or room.key == "escort5") and p.carryOn then -- 567
		return { -- 568
			x = player.x, -- 568
			y = player.y + player.h + 24, -- 568
			keyTag = "→", -- 568
			label = "带她走到出口", -- 568
			urgent = false -- 568
		} -- 568
	end -- 568
	local cart = room.cart -- 571
	if (room.key == "checkpoint" or room.key == "outside" or room.key == "c2-granary") and not p.cartDocked and cart.bodyW > 0 then -- 572
		local handleX = p.cartAxle + cart.handleOffset -- 573
		if p.gripping or p:cartHandleInReach() then -- 574
			return { -- 575
				x = handleX, -- 576
				y = cart.baseY + (cart.depth or 0) * DEPTH_Y_SCALE + cart.wheelR + cart.bodyH + 46, -- 577
				keyTag = room.key == "c2-granary" and "E 握柄 + D" or "按住 E + D", -- 578
				label = room.key == "outside" and "向前拉车" or "向前推车", -- 579
				urgent = false -- 580
			} -- 580
		end -- 580
	end -- 580
	if p.isCampaign then -- 585
		local bi = 0 -- 586
		do -- 586
			bi = 0 -- 587
			while bi < #p.boxes do -- 587
				do -- 587
					local b = p.boxes[bi + 1] -- 588
					if b.broken == true or b.hidden == true or b.interact == nil then -- 589
						goto __continue75 -- 590
					end -- 590
					local cx = (b.x0 + b.x1) * 0.5 -- 592
					local reach = b.interact.reach or 46 -- 593
					if math.abs(player.x - cx) <= reach + 16 and overlapsDepth(player.depth, b.depth, 16) then -- 594
						local kind = b.interact.kind -- 595
						local label = kind == "open_board" and "放下窗板" or (kind == "lower_curtain" and "放下木帘" or "抬起门锁") -- 596
						return { -- 598
							x = cx, -- 598
							y = b.y1 + 24, -- 598
							keyTag = "E", -- 598
							label = label, -- 598
							urgent = true -- 598
						} -- 598
					end -- 598
				end -- 598
				::__continue75:: -- 598
				bi = bi + 1 -- 587
			end -- 587
		end -- 587
	end -- 587
	if room.key == "village" and p.scavChase then -- 603
		local ____player_crouch_13 -- 604
		if player.crouch then -- 604
			____player_crouch_13 = nil -- 604
		else -- 604
			____player_crouch_13 = { -- 604
				x = player.x, -- 605
				y = player.y + player.h + 22, -- 605
				keyTag = "按住 Ctrl", -- 605
				label = "蹲下躲避", -- 605
				urgent = true -- 605
			} -- 605
		end -- 605
		return ____player_crouch_13 -- 604
	end -- 604
	if room.key == "village" and not p.passed then -- 609
		local bottle = room.bottle -- 610
		if p.hasBottle then -- 611
			return { -- 612
				x = player.x, -- 613
				y = player.y + player.h + 26, -- 613
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 614
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 615
				urgent = false -- 615
			} -- 615
		end -- 615
		if p.bottleFly == nil and bottle ~= nil then -- 618
			local dx = player.x - bottle.x -- 619
			local dy = player.y + player.h * 0.5 - bottle.y -- 620
			if dx * dx + dy * dy < 56 * 56 then -- 621
				return { -- 622
					x = bottle.x, -- 622
					y = bottle.y + 36, -- 622
					keyTag = "E", -- 622
					label = "拾起瓶子", -- 622
					urgent = false -- 622
				} -- 622
			end -- 622
		end -- 622
	end -- 622
	local arch = room.arch -- 627
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 628
		return { -- 631
			x = (arch.x0 + arch.x1) * 0.5, -- 632
			y = arch.y + arch.h + 44, -- 632
			keyTag = "按住 Ctrl", -- 633
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 633
			urgent = false -- 633
		} -- 633
	end -- 633
	local ____opt_14 = room.story -- 637
	local museum = ____opt_14 and ____opt_14.museum -- 637
	if room.key == "museum" and museum ~= nil then -- 638
		if p.phase == "museum-cabinet" then -- 639
			return { -- 640
				x = museum.cabinetX, -- 640
				y = 64 + 44, -- 640
				keyTag = "E", -- 640
				label = "玻璃柜前 · 收枪入袖", -- 640
				urgent = true -- 640
			} -- 640
		end -- 640
		if p.phase == "museum-hall" then -- 642
			return { -- 643
				x = museum.hallX, -- 643
				y = 120, -- 643
				keyTag = "走到", -- 643
				label = "西厅那头 · 孩子的脚步", -- 643
				urgent = false -- 643
			} -- 643
		end -- 643
		if p.phase == "museum-lamp" then -- 645
			return { -- 646
				x = museum.lampX, -- 646
				y = 120, -- 646
				keyTag = "E", -- 646
				label = "末厅 · 把灯转向西窗", -- 646
				urgent = true -- 646
			} -- 646
		end -- 646
		if p.phase == "museum-return" then -- 648
			return { -- 649
				x = museum.cabinetX, -- 649
				y = 64 + 44, -- 649
				keyTag = "E", -- 649
				label = "回柜边 · 轻敲两下", -- 649
				urgent = true -- 649
			} -- 649
		end -- 649
		if p.phase == "museum-done" then -- 651
			return { -- 652
				x = museum.cabinetX, -- 652
				y = 64 + 44, -- 652
				keyTag = "E", -- 652
				label = "回柜边 · 灯还亮着", -- 652
				urgent = false -- 652
			} -- 652
		end -- 652
		return nil -- 654
	end -- 654
	local ____opt_16 = room.story -- 657
	local tower = ____opt_16 and ____opt_16.tower -- 657
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 658
		return { -- 659
			x = tower.doorX, -- 659
			y = 96, -- 659
			keyTag = "E", -- 659
			label = "敲两下 · 守卒应门", -- 659
			urgent = false -- 659
		} -- 659
	end -- 659
	if p.phase == "tower-enter" then -- 661
		return { -- 662
			x = 605, -- 662
			y = 64, -- 662
			keyTag = "→", -- 662
			label = "跨过门槛 · 走到值夜桌前", -- 662
			urgent = false -- 662
		} -- 662
	end -- 662
	if p.phase == "tower-desk" then -- 664
		return { -- 665
			x = 605, -- 666
			y = 64, -- 666
			keyTag = "按住 E", -- 666
			label = "交出针套、指南针和纸条", -- 666
			progress = p.deskHold / 36, -- 667
			urgent = true -- 667
		} -- 667
	end -- 667
	if p.phase == "tower-given" then -- 670
		return { -- 671
			x = 605, -- 671
			y = 64, -- 671
			keyTag = "", -- 671
			label = "看登记簿 · 西窗的灯", -- 671
			urgent = false -- 671
		} -- 671
	end -- 671
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 674
		return { -- 676
			x = player.x, -- 677
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 25, -- 677
			keyTag = "按住 Shift", -- 678
			label = "贴靠掩体", -- 678
			urgent = gate ~= nil -- 678
		} -- 678
	end -- 678
	return nil -- 681
end -- 494
return ____exports -- 494
