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
function ____exports.createEmptyFrameEvents(roomSessionId, eventSeq, checkpoint) -- 94
	return { -- 99
		shotFired = false, -- 100
		shotHit = false, -- 101
		shotTrace = nil, -- 102
		enemyKilledX = -9999, -- 103
		enemyKilledY = 0, -- 104
		playerHit = false, -- 105
		coverDeflect = false, -- 106
		rollStarted = false, -- 107
		knockPulse = false, -- 108
		knockX = 0, -- 109
		knockY = 0, -- 110
		bottleLanded = false, -- 111
		bottleLandX = -1, -- 112
		bottleLandY = 0, -- 113
		cartJustDocked = false, -- 114
		checkpointJustHit = false, -- 115
		caughtTriggered = false, -- 116
		phaseChanged = false, -- 117
		roomChanged = false, -- 118
		gateWaveSpawned = false, -- 119
		storyRouteLocked = false, -- 120
		storyRoute = "", -- 121
		gateRested = false, -- 122
		handJustTied = false, -- 123
		handReleased = false, -- 124
		storyLine = false, -- 125
		storyLineText = "", -- 126
		storyExit = false, -- 127
		storyExitRoute = "", -- 128
		carryStarted = false, -- 129
		reloadOpened = false, -- 130
		reloadSolved = false, -- 131
		reloadEffect = "", -- 132
		reloadApplied = false, -- 133
		reloadAppliedEffect = "", -- 134
		reloadTimeout = false, -- 135
		reloadInvalid = false, -- 136
		segmentDone = false, -- 137
		segmentKey = "", -- 138
		segmentNext = "", -- 139
		benchOpened = false, -- 140
		benchCrafted = false, -- 141
		benchCraftedWeapon = "", -- 142
		benchEquipped = false, -- 143
		benchClosed = false, -- 144
		benchRejected = false, -- 145
		benchRejectReason = "", -- 146
		endingReached = false, -- 147
		ending = "", -- 148
		endingOfficial = false, -- 149
		endingLines = {}, -- 150
		museumStep = false, -- 151
		museumStepName = "", -- 152
		museumDone = false, -- 153
		rawEvents = {}, -- 154
		eventSeq = eventSeq, -- 155
		roomSessionId = roomSessionId, -- 156
		checkpoint = checkpoint, -- 157
		eventSummary = {} -- 158
	} -- 158
end -- 94
____exports.PlayAdapter = __TS__Class() -- 173
local PlayAdapter = ____exports.PlayAdapter -- 173
PlayAdapter.name = "PlayAdapter" -- 173
function PlayAdapter.prototype.____constructor(self) -- 173
	self.prevRoomKey = "" -- 174
	self.prevPhase = "" -- 175
	self.prevHp = 3 -- 176
	self.prevCoveredFlash = 0 -- 178
	self.prevRollT = 0 -- 179
	self.prevCalmTick = 0 -- 180
	self.prevKnocks = 0 -- 181
	self.prevBottleLandT = 0 -- 182
	self.prevCartDocked = false -- 183
	self.prevCheckpoint = -1 -- 184
	self.prevCaughtT = 0 -- 185
	self.prevGateSpawned = 0 -- 186
	self.prevAliveMask = {} -- 187
	self.roomSessionId = 0 -- 188
	self.eventSeq = 0 -- 189
end -- 173
function PlayAdapter.prototype.getRoomSessionId(self) -- 191
	return self.roomSessionId -- 192
end -- 191
function PlayAdapter.prototype.getEventSeq(self) -- 195
	return self.eventSeq -- 196
end -- 195
function PlayAdapter.prototype.emptyFrame(self, p) -- 199
	return ____exports.createEmptyFrameEvents(self.roomSessionId, self.eventSeq, p ~= nil and p.checkpoint or -1) -- 200
end -- 199
function PlayAdapter.prototype.reset(self, p) -- 207
	self.roomSessionId = self.roomSessionId + 1 -- 208
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 209
	self.prevPhase = p ~= nil and p.phase or "" -- 210
	self.prevHp = p ~= nil and p.hp or 3 -- 211
	self.prevTrace = nil -- 212
	self.prevCoveredFlash = 0 -- 213
	self.prevRollT = 0 -- 214
	self.prevCalmTick = 0 -- 215
	self.prevKnocks = 0 -- 216
	self.prevBottleLandT = 0 -- 217
	local ____temp_0 -- 218
	if p ~= nil then -- 218
		____temp_0 = p.cartDocked -- 218
	else -- 218
		____temp_0 = false -- 218
	end -- 218
	self.prevCartDocked = ____temp_0 -- 218
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 219
	self.prevCaughtT = 0 -- 220
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 221
	self.prevAliveMask = {} -- 222
	if p ~= nil then -- 223
		local i = 0 -- 224
		do -- 224
			i = 0 -- 225
			while i < #p.enemies do -- 225
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 226
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 226
				i = i + 1 -- 225
			end -- 225
		end -- 225
	end -- 225
end -- 207
function PlayAdapter.prototype.sample(self, p) -- 232
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 233
	if roomChanged then -- 234
		self:reset(p) -- 235
	end -- 235
	local rawEvents = p:drainEvents() -- 238
	if #rawEvents > 1 then -- 240
		__TS__ArraySort( -- 241
			rawEvents, -- 241
			function(____, a, b) return a.seq ~= b.seq and a.seq - b.seq or a.tick - b.tick end -- 241
		) -- 241
	end -- 241
	local eventSummary = {} -- 243
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 244
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 245
	local enemyKilledX = -9999 -- 246
	local enemyKilledY = 0 -- 247
	local i = 0 -- 248
	do -- 248
		i = 0 -- 249
		while i < #p.enemies do -- 249
			local ____temp_2 -- 250
			if i < #self.prevAliveMask then -- 250
				____temp_2 = self.prevAliveMask[i + 1] -- 250
			else -- 250
				____temp_2 = true -- 250
			end -- 250
			local wasAlive = ____temp_2 -- 250
			if wasAlive and not p.enemies[i + 1].alive then -- 251
				enemyKilledX = p.enemies[i + 1].x -- 252
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) * DEPTH_Y_SCALE + p.enemies[i + 1].h * 0.55 -- 253
			end -- 253
			i = i + 1 -- 249
		end -- 249
	end -- 249
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 257
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 258
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 259
	local knockPulse = false -- 262
	local knockX = p.player.x -- 263
	local knockY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.5 -- 264
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 266
	local bottleLandX = p.bottleLandX -- 267
	local bottleLandY = p.bottleLandY -- 268
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 269
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 270
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 271
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 272
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 273
	local migratedRoomChange = false -- 274
	local storyRouteLocked = false -- 276
	local gateRested = false -- 277
	local handJustTied = false -- 278
	local handReleased = false -- 279
	local storyLine = false -- 280
	local storyLineText = "" -- 281
	local storyExit = false -- 282
	local storyExitRoute = "" -- 283
	local carryStarted = false -- 284
	local reloadOpened = false -- 285
	local reloadSolved = false -- 286
	local reloadEffect = "" -- 287
	local reloadApplied = false -- 288
	local reloadAppliedEffect = "" -- 289
	local reloadTimeout = false -- 290
	local reloadInvalid = false -- 291
	local segmentDone = false -- 292
	local segmentKey = "" -- 293
	local segmentNext = "" -- 294
	local benchOpened = false -- 295
	local benchCrafted = false -- 296
	local benchCraftedWeapon = "" -- 297
	local benchEquipped = false -- 298
	local benchClosed = false -- 299
	local benchRejected = false -- 300
	local benchRejectReason = "" -- 301
	local endingReached = false -- 302
	local museumStep = false -- 303
	local museumStepName = "" -- 304
	local museumDone = false -- 305
	local ending = "" -- 306
	local endingOfficial = false -- 307
	local endingLines = {} -- 308
	for ____, event in ipairs(rawEvents) do -- 309
		self.eventSeq = self.eventSeq + 1 -- 310
		eventSummary[#eventSummary + 1] = (((tostring(event.seq) .. "@") .. tostring(event.tick)) .. ":") .. event.name -- 311
		if event.name == "knock" then -- 313
			knockPulse = true -- 314
			local x = event.data.x -- 315
			knockX = type(x) == "number" and x or p.player.x -- 316
			knockY = p.escort.state == "calming" and p.partner.y + p.partner.depth * DEPTH_Y_SCALE + 28 or p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.55 -- 317
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 320
			playerHit = true -- 321
		elseif event.name == "coverBlocked" then -- 322
			coverDeflect = true -- 323
		elseif event.name == "bottleLanded" then -- 324
			bottleLanded = true -- 325
			if type(event.data.x) == "number" then -- 326
				bottleLandX = event.data.x -- 327
			end -- 327
			if type(event.data.y) == "number" then -- 329
				bottleLandY = event.data.y -- 330
			end -- 330
		elseif event.name == "cartDocked" then -- 332
			cartJustDocked = true -- 333
		elseif event.name == "roomChange" then -- 334
			migratedRoomChange = true -- 335
		elseif event.name == "storyRouteLocked" then -- 336
			storyRouteLocked = true -- 337
		elseif event.name == "gateCountDone" and p.storyRoute == "soldier" then -- 338
			gateRested = true -- 339
		elseif event.name == "handHeld" then -- 340
			handJustTied = true -- 341
		elseif event.name == "handRelease" then -- 342
			handReleased = true -- 343
		elseif event.name == "storyLine" then -- 344
			storyLine = true -- 345
			storyLineText = type(event.data.text) == "string" and event.data.text or "" -- 346
		elseif event.name == "storyExit" then -- 347
			storyExit = true -- 348
			storyExitRoute = type(event.data.route) == "string" and event.data.route or "" -- 349
		elseif event.name == "carryStart" then -- 350
			carryStarted = true -- 351
		elseif event.name == "reloadOpen" then -- 352
			reloadOpened = true -- 353
		elseif event.name == "reloadSolved" then -- 354
			reloadSolved = true -- 355
			reloadEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 356
		elseif event.name == "reloadApplied" then -- 357
			reloadApplied = true -- 358
			reloadAppliedEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 359
		elseif event.name == "reloadTimeout" then -- 360
			reloadTimeout = true -- 361
		elseif event.name == "reloadInvalid" then -- 362
			reloadInvalid = true -- 363
		elseif event.name == "segmentDone" then -- 364
			segmentDone = true -- 365
			segmentKey = type(event.data.room) == "string" and event.data.room or "" -- 366
			segmentNext = type(event.data.next) == "string" and event.data.next or "" -- 367
		elseif event.name == "benchOpen" then -- 368
			benchOpened = true -- 369
		elseif event.name == "benchCraft" then -- 370
			benchCrafted = true -- 371
			benchCraftedWeapon = type(event.data.weapon) == "string" and event.data.weapon or "" -- 372
		elseif event.name == "benchEquip" then -- 373
			benchEquipped = true -- 374
		elseif event.name == "benchClose" then -- 375
			benchClosed = true -- 376
		elseif event.name == "benchRejected" then -- 377
			benchRejected = true -- 378
			benchRejectReason = type(event.data.reason) == "string" and event.data.reason or "" -- 379
		elseif event.name == "museumStep" then -- 380
			museumStep = true -- 381
			museumStepName = type(event.data.step) == "string" and event.data.step or "" -- 382
		elseif event.name == "museumDone" then -- 383
			museumDone = true -- 384
		elseif event.name == "endingReached" then -- 385
			endingReached = true -- 386
			ending = type(event.data.ending) == "string" and event.data.ending or "" -- 387
			endingOfficial = event.data.official == true -- 388
			endingLines = __TS__ArrayIsArray(event.data.lines) and __TS__ArrayMap( -- 389
				event.data.lines, -- 390
				function(____, v) return type(v) == "string" and v or "" end -- 390
			) or ({}) -- 391
		end -- 391
	end -- 391
	self.prevRoomKey = p.room.key -- 396
	self.prevPhase = p.phase -- 397
	self.prevHp = p.hp -- 398
	self.prevTrace = p.trace -- 399
	self.prevCoveredFlash = p.coveredFlash -- 400
	self.prevRollT = p.player.rollT -- 401
	self.prevCalmTick = p.escort.calmTick -- 402
	self.prevKnocks = p.knocks -- 403
	self.prevBottleLandT = p.bottleLandT -- 404
	self.prevCartDocked = p.cartDocked -- 405
	self.prevCheckpoint = p.checkpoint -- 406
	self.prevCaughtT = p.caughtT -- 407
	self.prevGateSpawned = p.gateSpawned -- 408
	self.prevAliveMask = {} -- 409
	do -- 409
		i = 0 -- 410
		while i < #p.enemies do -- 410
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 411
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 411
			i = i + 1 -- 410
		end -- 410
	end -- 410
	local ____shotFired_5 = shotFired -- 415
	local ____shotHit_6 = shotHit -- 416
	local ____shotFired_4 -- 417
	if shotFired then -- 417
		____shotFired_4 = p.trace -- 417
	else -- 417
		____shotFired_4 = nil -- 417
	end -- 417
	return { -- 414
		shotFired = ____shotFired_5, -- 415
		shotHit = ____shotHit_6, -- 416
		shotTrace = ____shotFired_4, -- 417
		enemyKilledX = enemyKilledX, -- 418
		enemyKilledY = enemyKilledY, -- 419
		playerHit = playerHit, -- 420
		coverDeflect = coverDeflect, -- 421
		rollStarted = rollStarted, -- 422
		knockPulse = knockPulse, -- 423
		knockX = knockX, -- 424
		knockY = knockY, -- 425
		bottleLanded = bottleLanded, -- 426
		bottleLandX = bottleLandX, -- 427
		bottleLandY = bottleLandY, -- 428
		cartJustDocked = cartJustDocked, -- 429
		checkpointJustHit = checkpointJustHit, -- 430
		caughtTriggered = caughtTriggered, -- 431
		phaseChanged = phaseChanged, -- 432
		roomChanged = roomChanged or migratedRoomChange, -- 433
		gateWaveSpawned = gateWaveSpawned, -- 434
		storyRouteLocked = storyRouteLocked, -- 436
		storyRoute = p.storyRoute, -- 437
		gateRested = gateRested, -- 438
		handJustTied = handJustTied, -- 439
		handReleased = handReleased, -- 440
		storyLine = storyLine, -- 441
		storyLineText = storyLineText, -- 442
		storyExit = storyExit, -- 443
		storyExitRoute = storyExitRoute, -- 444
		carryStarted = carryStarted, -- 445
		reloadOpened = reloadOpened, -- 446
		reloadSolved = reloadSolved, -- 447
		reloadEffect = reloadEffect, -- 448
		reloadApplied = reloadApplied, -- 449
		reloadAppliedEffect = reloadAppliedEffect, -- 450
		reloadTimeout = reloadTimeout, -- 451
		reloadInvalid = reloadInvalid, -- 452
		segmentDone = segmentDone, -- 453
		segmentKey = segmentKey, -- 454
		segmentNext = segmentNext, -- 455
		benchOpened = benchOpened, -- 456
		benchCrafted = benchCrafted, -- 457
		benchCraftedWeapon = benchCraftedWeapon, -- 458
		benchEquipped = benchEquipped, -- 459
		benchClosed = benchClosed, -- 460
		benchRejected = benchRejected, -- 461
		benchRejectReason = benchRejectReason, -- 462
		endingReached = endingReached, -- 463
		ending = ending, -- 464
		endingOfficial = endingOfficial, -- 465
		endingLines = endingLines, -- 466
		museumStep = museumStep, -- 467
		museumStepName = museumStepName, -- 468
		museumDone = museumDone, -- 469
		rawEvents = rawEvents, -- 471
		eventSeq = self.eventSeq, -- 472
		roomSessionId = self.roomSessionId, -- 473
		checkpoint = p.checkpoint, -- 474
		eventSummary = eventSummary -- 475
	} -- 475
end -- 232
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 482
	local room = p.room -- 483
	local player = p.player -- 484
	if p.paused or not player.alive then -- 485
		return nil -- 486
	end -- 486
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 489
		local ____opt_9 = room.story -- 490
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 490
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 490
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 491
			return { -- 492
				x = p.partner.x, -- 492
				y = p.partner.y + p.partner.depth * DEPTH_Y_SCALE + p.partner.h + 22, -- 492
				keyTag = "E", -- 492
				label = "递出指南针", -- 492
				urgent = false -- 492
			} -- 492
		end -- 492
		return nil -- 494
	end -- 494
	if not p.childMode and p.escort.state == "frozen" then -- 497
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 498
			return { -- 499
				x = p.partner.x, -- 499
				y = p.partner.y + p.partner.depth * DEPTH_Y_SCALE + p.partner.h + 22, -- 499
				keyTag = "E", -- 499
				label = "安抚小满", -- 499
				urgent = true -- 499
			} -- 499
		end -- 499
		return nil -- 501
	end -- 501
	local ____opt_11 = room.story -- 504
	local gate = ____opt_11 and ____opt_11.gate -- 504
	if gate ~= nil then -- 505
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 506
			return { -- 509
				x = gate.winchX, -- 509
				y = 84, -- 509
				keyTag = "E", -- 509
				label = "重新守门", -- 509
				urgent = true -- 509
			} -- 509
		end -- 509
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 511
			return { -- 512
				x = gate.doorX, -- 512
				y = 98, -- 512
				keyTag = "E", -- 512
				label = "送小满出城", -- 512
				urgent = true -- 512
			} -- 512
		end -- 512
		if p.phase == "gate-wait" then -- 514
			local ratio = math.max( -- 516
				0, -- 516
				math.min(1, p.handTicks / p.handNeedTicks) -- 516
			) -- 516
			return { -- 517
				x = gate.doorX + 30, -- 518
				y = 96, -- 518
				keyTag = p.handArmed and "按住 E" or "松开再按住 E", -- 519
				label = p.handTicks > 0 and "牵起小满" or "把手伸给她", -- 520
				urgent = p.handArmed, -- 521
				progress = ratio -- 521
			} -- 521
		end -- 521
		if p.phase == "gate-hand" then -- 524
			return { -- 525
				x = gate.doorX + 30, -- 525
				y = 96, -- 525
				keyTag = "E", -- 525
				label = "我们走吧。", -- 525
				urgent = false -- 525
			} -- 525
		end -- 525
		if p.phase == "gate-walk" then -- 527
			return { -- 528
				x = player.x, -- 528
				y = player.y + player.h + 22, -- 528
				keyTag = "→", -- 528
				label = "走向城外", -- 528
				urgent = false -- 528
			} -- 528
		end -- 528
	end -- 528
	if p.reloadOpen then -- 533
		local need = math.max( -- 534
			1, -- 534
			p:reloadNeedTicks() -- 534
		) -- 534
		local ratio = math.max( -- 535
			0, -- 535
			math.min(1, p.reloadAnswerTicks / need) -- 535
		) -- 535
		return { -- 536
			x = player.x, -- 537
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 34, -- 537
			keyTag = "连线", -- 538
			label = "画到枪机复位", -- 538
			urgent = p.reloadAnswerTicks > need * 0.7, -- 538
			progress = ratio -- 538
		} -- 538
	end -- 538
	if p.reloadPendingEffect ~= "" then -- 541
		return { -- 542
			x = player.x, -- 543
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 34, -- 543
			keyTag = "左键", -- 544
			label = "枪机已上势 · 打下一枪", -- 544
			urgent = false -- 544
		} -- 544
	end -- 544
	if room.key == "gatepath" and not p.carryOn then -- 547
		return { -- 548
			x = player.x, -- 548
			y = player.y + player.h + 24, -- 548
			keyTag = "→", -- 548
			label = "走到高石阶", -- 548
			urgent = false -- 548
		} -- 548
	end -- 548
	if room.key == "escort3" and not p.craftBench.active then -- 550
		local bench = 560 -- 551
		if math.abs(player.x - bench) <= p.benchReach + 40 and player.y < 12 then -- 552
			return { -- 553
				x = bench, -- 553
				y = 92, -- 553
				keyTag = "E", -- 553
				label = "在工台制作", -- 553
				urgent = false -- 553
			} -- 553
		end -- 553
	end -- 553
	if (room.key == "escort2" or room.key == "escort3" or room.key == "escort4" or room.key == "escort5") and p.carryOn then -- 556
		return { -- 557
			x = player.x, -- 557
			y = player.y + player.h + 24, -- 557
			keyTag = "→", -- 557
			label = "带她走到出口", -- 557
			urgent = false -- 557
		} -- 557
	end -- 557
	local cart = room.cart -- 560
	if (room.key == "checkpoint" or room.key == "outside" or room.key == "c2-granary") and not p.cartDocked and cart.bodyW > 0 then -- 561
		local handleX = p.cartAxle + cart.handleOffset -- 562
		if p.gripping or p:cartHandleInReach() then -- 563
			return { -- 564
				x = handleX, -- 565
				y = cart.baseY + (cart.depth or 0) * DEPTH_Y_SCALE + cart.wheelR + cart.bodyH + 46, -- 566
				keyTag = room.key == "c2-granary" and "E 握柄 + D" or "按住 E + D", -- 567
				label = room.key == "outside" and "向前拉车" or "向前推车", -- 568
				urgent = false -- 569
			} -- 569
		end -- 569
	end -- 569
	if p.isCampaign then -- 574
		local bi = 0 -- 575
		do -- 575
			bi = 0 -- 576
			while bi < #p.boxes do -- 576
				do -- 576
					local b = p.boxes[bi + 1] -- 577
					if b.broken == true or b.hidden == true or b.interact == nil then -- 578
						goto __continue74 -- 579
					end -- 579
					local cx = (b.x0 + b.x1) * 0.5 -- 581
					local reach = b.interact.reach or 46 -- 582
					if math.abs(player.x - cx) <= reach + 16 and overlapsDepth(player.depth, b.depth, 16) then -- 583
						local kind = b.interact.kind -- 584
						local label = kind == "open_board" and "放下窗板" or (kind == "lower_curtain" and "放下木帘" or "抬起门锁") -- 585
						return { -- 587
							x = cx, -- 587
							y = b.y1 + 24, -- 587
							keyTag = "E", -- 587
							label = label, -- 587
							urgent = true -- 587
						} -- 587
					end -- 587
				end -- 587
				::__continue74:: -- 587
				bi = bi + 1 -- 576
			end -- 576
		end -- 576
	end -- 576
	if room.key == "village" and p.scavChase then -- 592
		local ____player_crouch_13 -- 593
		if player.crouch then -- 593
			____player_crouch_13 = nil -- 593
		else -- 593
			____player_crouch_13 = { -- 593
				x = player.x, -- 594
				y = player.y + player.h + 22, -- 594
				keyTag = "按住 Ctrl", -- 594
				label = "蹲下躲避", -- 594
				urgent = true -- 594
			} -- 594
		end -- 594
		return ____player_crouch_13 -- 593
	end -- 593
	if room.key == "village" and not p.passed then -- 598
		local bottle = room.bottle -- 599
		if p.hasBottle then -- 600
			return { -- 601
				x = player.x, -- 602
				y = player.y + player.h + 26, -- 602
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 603
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 604
				urgent = false -- 604
			} -- 604
		end -- 604
		if p.bottleFly == nil and bottle ~= nil then -- 607
			local dx = player.x - bottle.x -- 608
			local dy = player.y + player.h * 0.5 - bottle.y -- 609
			if dx * dx + dy * dy < 56 * 56 then -- 610
				return { -- 611
					x = bottle.x, -- 611
					y = bottle.y + 36, -- 611
					keyTag = "E", -- 611
					label = "拾起瓶子", -- 611
					urgent = false -- 611
				} -- 611
			end -- 611
		end -- 611
	end -- 611
	local arch = room.arch -- 616
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 617
		return { -- 620
			x = (arch.x0 + arch.x1) * 0.5, -- 621
			y = arch.y + arch.h + 44, -- 621
			keyTag = "按住 Ctrl", -- 622
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 622
			urgent = false -- 622
		} -- 622
	end -- 622
	local ____opt_14 = room.story -- 626
	local museum = ____opt_14 and ____opt_14.museum -- 626
	if room.key == "museum" and museum ~= nil then -- 627
		if p.phase == "museum-cabinet" then -- 628
			return { -- 629
				x = museum.cabinetX, -- 629
				y = 64 + 44, -- 629
				keyTag = "E", -- 629
				label = "玻璃柜前 · 收枪入袖", -- 629
				urgent = true -- 629
			} -- 629
		end -- 629
		if p.phase == "museum-hall" then -- 631
			return { -- 632
				x = museum.hallX, -- 632
				y = 120, -- 632
				keyTag = "走到", -- 632
				label = "西厅那头 · 孩子的脚步", -- 632
				urgent = false -- 632
			} -- 632
		end -- 632
		if p.phase == "museum-lamp" then -- 634
			return { -- 635
				x = museum.lampX, -- 635
				y = 120, -- 635
				keyTag = "E", -- 635
				label = "末厅 · 把灯转向西窗", -- 635
				urgent = true -- 635
			} -- 635
		end -- 635
		if p.phase == "museum-return" then -- 637
			return { -- 638
				x = museum.cabinetX, -- 638
				y = 64 + 44, -- 638
				keyTag = "E", -- 638
				label = "回柜边 · 轻敲两下", -- 638
				urgent = true -- 638
			} -- 638
		end -- 638
		if p.phase == "museum-done" then -- 640
			return { -- 641
				x = museum.cabinetX, -- 641
				y = 64 + 44, -- 641
				keyTag = "E", -- 641
				label = "回柜边 · 灯还亮着", -- 641
				urgent = false -- 641
			} -- 641
		end -- 641
		return nil -- 643
	end -- 643
	local ____opt_16 = room.story -- 646
	local tower = ____opt_16 and ____opt_16.tower -- 646
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 647
		return { -- 648
			x = tower.doorX, -- 648
			y = 96, -- 648
			keyTag = "E", -- 648
			label = "敲两下 · 守卒应门", -- 648
			urgent = false -- 648
		} -- 648
	end -- 648
	if p.phase == "tower-enter" then -- 650
		return { -- 651
			x = 605, -- 651
			y = 64, -- 651
			keyTag = "→", -- 651
			label = "跨过门槛 · 走到值夜桌前", -- 651
			urgent = false -- 651
		} -- 651
	end -- 651
	if p.phase == "tower-desk" then -- 653
		return { -- 654
			x = 605, -- 655
			y = 64, -- 655
			keyTag = "按住 E", -- 655
			label = "交出针套、指南针和纸条", -- 655
			progress = p.deskHold / 36, -- 656
			urgent = true -- 656
		} -- 656
	end -- 656
	if p.phase == "tower-given" then -- 659
		return { -- 660
			x = 605, -- 660
			y = 64, -- 660
			keyTag = "", -- 660
			label = "看登记簿 · 西窗的灯", -- 660
			urgent = false -- 660
		} -- 660
	end -- 660
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 663
		return { -- 665
			x = player.x, -- 666
			y = player.y + player.depth * DEPTH_Y_SCALE + player.h + 25, -- 666
			keyTag = "按住 Shift", -- 667
			label = "贴靠掩体", -- 667
			urgent = gate ~= nil -- 667
		} -- 667
	end -- 667
	return nil -- 670
end -- 482
return ____exports -- 482
