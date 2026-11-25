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
local inReachDepth = ____depth.inReachDepth -- 10
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
	if p ~= nil then -- 222
		local i = 0 -- 224
		do -- 224
			i = 0 -- 225
			while i < #p.enemies do -- 225
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 225
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 226
				i = i + 1 -- 225
			end -- 225
		end -- 225
	end -- 225
end -- 207
function PlayAdapter.prototype.sample(self, p) -- 232
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 233
	if roomChanged then -- 233
		self:reset(p) -- 235
	end -- 235
	local rawEvents = p:drainEvents() -- 238
	if #rawEvents > 1 then -- 238
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
			if wasAlive and not p.enemies[i + 1].alive then -- 250
				enemyKilledX = p.enemies[i + 1].x -- 252
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) + p.enemies[i + 1].h * 0.55 -- 253
			end -- 253
			i = i + 1 -- 249
		end -- 249
	end -- 249
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 257
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 258
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 259
	local knockPulse = false -- 262
	local knockX = p.player.x -- 263
	local knockY = p.player.y + p.player.depth + p.player.h * 0.5 -- 264
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
		if event.name == "knock" then -- 311
			knockPulse = true -- 314
			local x = event.data.x -- 315
			knockX = type(x) == "number" and x or p.player.x -- 316
			knockY = p.escort.state == "calming" and p.partner.y + p.partner.depth + 28 or p.player.y + p.player.depth + p.player.h * 0.55 -- 317
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 317
			playerHit = true -- 320
		elseif event.name == "coverBlocked" then -- 320
			coverDeflect = true -- 322
		elseif event.name == "bottleLanded" then -- 322
			bottleLanded = true -- 324
			if type(event.data.x) == "number" then -- 324
				bottleLandX = event.data.x -- 326
			end -- 326
			if type(event.data.y) == "number" then -- 326
				bottleLandY = event.data.y -- 329
			end -- 329
		elseif event.name == "cartDocked" then -- 329
			cartJustDocked = true -- 332
		elseif event.name == "roomChange" then -- 332
			migratedRoomChange = true -- 334
		elseif event.name == "storyRouteLocked" then -- 334
			storyRouteLocked = true -- 336
		elseif event.name == "gateCountDone" and p.storyRoute == "soldier" then -- 336
			gateRested = true -- 338
		elseif event.name == "handHeld" then -- 338
			handJustTied = true -- 340
		elseif event.name == "handRelease" then -- 340
			handReleased = true -- 342
		elseif event.name == "storyLine" then -- 342
			storyLine = true -- 344
			storyLineText = type(event.data.text) == "string" and event.data.text or "" -- 345
		elseif event.name == "storyExit" then -- 345
			storyExit = true -- 347
			storyExitRoute = type(event.data.route) == "string" and event.data.route or "" -- 348
		elseif event.name == "carryStart" then -- 348
			carryStarted = true -- 350
		elseif event.name == "reloadOpen" then -- 350
			reloadOpened = true -- 352
		elseif event.name == "reloadSolved" then -- 352
			reloadSolved = true -- 354
			reloadEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 355
		elseif event.name == "reloadApplied" then -- 355
			reloadApplied = true -- 357
			reloadAppliedEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 358
		elseif event.name == "reloadTimeout" then -- 358
			reloadTimeout = true -- 360
		elseif event.name == "reloadInvalid" then -- 360
			reloadInvalid = true -- 362
		elseif event.name == "segmentDone" then -- 362
			segmentDone = true -- 364
			segmentKey = type(event.data.room) == "string" and event.data.room or "" -- 365
			segmentNext = type(event.data.next) == "string" and event.data.next or "" -- 366
		elseif event.name == "benchOpen" then -- 366
			benchOpened = true -- 368
		elseif event.name == "benchCraft" then -- 368
			benchCrafted = true -- 370
			benchCraftedWeapon = type(event.data.weapon) == "string" and event.data.weapon or "" -- 371
		elseif event.name == "benchEquip" then -- 371
			benchEquipped = true -- 373
		elseif event.name == "benchClose" then -- 373
			benchClosed = true -- 375
		elseif event.name == "benchRejected" then -- 375
			benchRejected = true -- 377
			benchRejectReason = type(event.data.reason) == "string" and event.data.reason or "" -- 378
		elseif event.name == "museumStep" then -- 378
			museumStep = true -- 380
			museumStepName = type(event.data.step) == "string" and event.data.step or "" -- 381
		elseif event.name == "museumDone" then -- 381
			museumDone = true -- 383
		elseif event.name == "endingReached" then -- 383
			endingReached = true -- 385
			ending = type(event.data.ending) == "string" and event.data.ending or "" -- 386
			endingOfficial = event.data.official == true -- 387
			endingLines = __TS__ArrayIsArray(event.data.lines) and __TS__ArrayMap( -- 388
				event.data.lines, -- 389
				function(____, v) return type(v) == "string" and v or "" end -- 389
			) or ({}) -- 389
		end -- 389
	end -- 389
	self.prevRoomKey = p.room.key -- 395
	self.prevPhase = p.phase -- 396
	self.prevHp = p.hp -- 397
	self.prevTrace = p.trace -- 398
	self.prevCoveredFlash = p.coveredFlash -- 399
	self.prevRollT = p.player.rollT -- 400
	self.prevCalmTick = p.escort.calmTick -- 401
	self.prevKnocks = p.knocks -- 402
	self.prevBottleLandT = p.bottleLandT -- 403
	self.prevCartDocked = p.cartDocked -- 404
	self.prevCheckpoint = p.checkpoint -- 405
	self.prevCaughtT = p.caughtT -- 406
	self.prevGateSpawned = p.gateSpawned -- 407
	self.prevAliveMask = {} -- 408
	do -- 408
		i = 0 -- 409
		while i < #p.enemies do -- 409
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 409
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 410
			i = i + 1 -- 409
		end -- 409
	end -- 409
	local ____shotFired_5 = shotFired -- 414
	local ____shotHit_6 = shotHit -- 415
	local ____shotFired_4 -- 416
	if shotFired then -- 416
		____shotFired_4 = p.trace -- 416
	else -- 416
		____shotFired_4 = nil -- 416
	end -- 416
	return { -- 413
		shotFired = ____shotFired_5, -- 414
		shotHit = ____shotHit_6, -- 415
		shotTrace = ____shotFired_4, -- 416
		enemyKilledX = enemyKilledX, -- 417
		enemyKilledY = enemyKilledY, -- 418
		playerHit = playerHit, -- 419
		coverDeflect = coverDeflect, -- 420
		rollStarted = rollStarted, -- 421
		knockPulse = knockPulse, -- 422
		knockX = knockX, -- 423
		knockY = knockY, -- 424
		bottleLanded = bottleLanded, -- 425
		bottleLandX = bottleLandX, -- 426
		bottleLandY = bottleLandY, -- 427
		cartJustDocked = cartJustDocked, -- 428
		checkpointJustHit = checkpointJustHit, -- 429
		caughtTriggered = caughtTriggered, -- 430
		phaseChanged = phaseChanged, -- 431
		roomChanged = roomChanged or migratedRoomChange, -- 432
		gateWaveSpawned = gateWaveSpawned, -- 433
		storyRouteLocked = storyRouteLocked, -- 435
		storyRoute = p.storyRoute, -- 436
		gateRested = gateRested, -- 437
		handJustTied = handJustTied, -- 438
		handReleased = handReleased, -- 439
		storyLine = storyLine, -- 440
		storyLineText = storyLineText, -- 441
		storyExit = storyExit, -- 442
		storyExitRoute = storyExitRoute, -- 443
		carryStarted = carryStarted, -- 444
		reloadOpened = reloadOpened, -- 445
		reloadSolved = reloadSolved, -- 446
		reloadEffect = reloadEffect, -- 447
		reloadApplied = reloadApplied, -- 448
		reloadAppliedEffect = reloadAppliedEffect, -- 449
		reloadTimeout = reloadTimeout, -- 450
		reloadInvalid = reloadInvalid, -- 451
		segmentDone = segmentDone, -- 452
		segmentKey = segmentKey, -- 453
		segmentNext = segmentNext, -- 454
		benchOpened = benchOpened, -- 455
		benchCrafted = benchCrafted, -- 456
		benchCraftedWeapon = benchCraftedWeapon, -- 457
		benchEquipped = benchEquipped, -- 458
		benchClosed = benchClosed, -- 459
		benchRejected = benchRejected, -- 460
		benchRejectReason = benchRejectReason, -- 461
		endingReached = endingReached, -- 462
		ending = ending, -- 463
		endingOfficial = endingOfficial, -- 464
		endingLines = endingLines, -- 465
		museumStep = museumStep, -- 466
		museumStepName = museumStepName, -- 467
		museumDone = museumDone, -- 468
		rawEvents = rawEvents, -- 470
		eventSeq = self.eventSeq, -- 471
		roomSessionId = self.roomSessionId, -- 472
		checkpoint = p.checkpoint, -- 473
		eventSummary = eventSummary -- 474
	} -- 474
end -- 232
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 481
	local room = p.room -- 482
	local player = p.player -- 483
	if p.paused or not player.alive then -- 483
		return nil -- 485
	end -- 485
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 485
		local ____opt_9 = room.story -- 485
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 485
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 489
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 489
			return { -- 491
				x = p.partner.x, -- 491
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 491
				keyTag = "E", -- 491
				label = "递出指南针", -- 491
				urgent = false -- 491
			} -- 491
		end -- 491
		return nil -- 493
	end -- 493
	if not p.childMode and p.escort.state == "frozen" then -- 493
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 493
			return { -- 498
				x = p.partner.x, -- 498
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 498
				keyTag = "E", -- 498
				label = "安抚小满", -- 498
				urgent = true -- 498
			} -- 498
		end -- 498
		return nil -- 500
	end -- 500
	local ____opt_11 = room.story -- 500
	local gate = ____opt_11 and ____opt_11.gate -- 503
	if gate ~= nil then -- 503
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 503
			return { -- 508
				x = gate.winchX, -- 508
				y = 84, -- 508
				keyTag = "E", -- 508
				label = "重新守门", -- 508
				urgent = true -- 508
			} -- 508
		end -- 508
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 508
			return { -- 511
				x = gate.doorX, -- 511
				y = 98, -- 511
				keyTag = "E", -- 511
				label = "送小满出城", -- 511
				urgent = true -- 511
			} -- 511
		end -- 511
		if p.phase == "gate-wait" then -- 511
			local ratio = math.max( -- 515
				0, -- 515
				math.min(1, p.handTicks / p.handNeedTicks) -- 515
			) -- 515
			return { -- 516
				x = gate.doorX + 30, -- 517
				y = 96, -- 517
				keyTag = p.handArmed and "按住 E" or "松开再按住 E", -- 518
				label = p.handTicks > 0 and "牵起小满" or "把手伸给她", -- 519
				urgent = p.handArmed, -- 520
				progress = ratio -- 520
			} -- 520
		end -- 520
		if p.phase == "gate-hand" then -- 520
			return { -- 524
				x = gate.doorX + 30, -- 524
				y = 96, -- 524
				keyTag = "E", -- 524
				label = "我们走吧。", -- 524
				urgent = false -- 524
			} -- 524
		end -- 524
		if p.phase == "gate-walk" then -- 524
			return { -- 527
				x = player.x, -- 527
				y = player.y + player.h + 22, -- 527
				keyTag = "→", -- 527
				label = "走向城外", -- 527
				urgent = false -- 527
			} -- 527
		end -- 527
	end -- 527
	if p.reloadOpen then -- 527
		local ratio = math.max( -- 533
			0, -- 533
			math.min(1, p.reloadAnswerTicks / 240) -- 533
		) -- 533
		return { -- 534
			x = player.x, -- 535
			y = player.y + player.depth + player.h + 34, -- 535
			keyTag = "连线", -- 536
			label = "画到枪机复位", -- 536
			urgent = p.reloadAnswerTicks > 168, -- 536
			progress = ratio -- 536
		} -- 536
	end -- 536
	if p.reloadPendingEffect ~= "" then -- 536
		return { -- 540
			x = player.x, -- 541
			y = player.y + player.depth + player.h + 34, -- 541
			keyTag = "F", -- 542
			label = "枪机已上势 · 打下一枪", -- 542
			urgent = false -- 542
		} -- 542
	end -- 542
	if room.key == "gatepath" and not p.carryOn then -- 542
		return { -- 546
			x = player.x, -- 546
			y = player.y + player.h + 24, -- 546
			keyTag = "→", -- 546
			label = "走到高石阶", -- 546
			urgent = false -- 546
		} -- 546
	end -- 546
	if room.key == "escort3" and not p.craftBench.active then -- 546
		local bench = 560 -- 549
		if math.abs(player.x - bench) <= p.benchReach + 40 and player.y < 12 then -- 549
			return { -- 551
				x = bench, -- 551
				y = 92, -- 551
				keyTag = "E", -- 551
				label = "在工台制作", -- 551
				urgent = false -- 551
			} -- 551
		end -- 551
	end -- 551
	if (room.key == "escort2" or room.key == "escort3" or room.key == "escort4" or room.key == "escort5") and p.carryOn then -- 551
		return { -- 555
			x = player.x, -- 555
			y = player.y + player.h + 24, -- 555
			keyTag = "→", -- 555
			label = "带她走到出口", -- 555
			urgent = false -- 555
		} -- 555
	end -- 555
	local cart = room.cart -- 558
	if (room.key == "checkpoint" or room.key == "outside") and not p.cartDocked and cart.bodyW > 0 then -- 558
		local handleX = p.cartAxle + cart.handleOffset -- 560
		if p.gripping or p:cartHandleInReach() then -- 560
			return { -- 562
				x = handleX, -- 563
				y = cart.baseY + (cart.depth or 0) + cart.wheelR + cart.bodyH + 46, -- 564
				keyTag = "按住 E + D", -- 565
				label = room.key == "checkpoint" and "向前推车" or "向前拉车", -- 566
				urgent = false -- 567
			} -- 567
		end -- 567
	end -- 567
	if room.key == "village" and p.scavChase then -- 567
		local ____player_crouch_13 -- 573
		if player.crouch then -- 573
			____player_crouch_13 = nil -- 573
		else -- 573
			____player_crouch_13 = { -- 573
				x = player.x, -- 574
				y = player.y + player.h + 22, -- 574
				keyTag = "按住 Ctrl", -- 574
				label = "蹲下躲避", -- 574
				urgent = true -- 574
			} -- 574
		end -- 574
		return ____player_crouch_13 -- 573
	end -- 573
	if room.key == "village" and not p.passed then -- 573
		local bottle = room.bottle -- 579
		if p.hasBottle then -- 579
			return { -- 581
				x = player.x, -- 582
				y = player.y + player.h + 26, -- 582
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 583
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 584
				urgent = false -- 584
			} -- 584
		end -- 584
		if p.bottleFly == nil and bottle ~= nil then -- 584
			local dx = player.x - bottle.x -- 588
			local dy = player.y + player.h * 0.5 - bottle.y -- 589
			if dx * dx + dy * dy < 56 * 56 then -- 589
				return { -- 591
					x = bottle.x, -- 591
					y = bottle.y + 36, -- 591
					keyTag = "E", -- 591
					label = "拾起瓶子", -- 591
					urgent = false -- 591
				} -- 591
			end -- 591
		end -- 591
	end -- 591
	local arch = room.arch -- 596
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 596
		return { -- 600
			x = (arch.x0 + arch.x1) * 0.5, -- 601
			y = arch.y + arch.h + 44, -- 601
			keyTag = "按住 Ctrl", -- 602
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 602
			urgent = false -- 602
		} -- 602
	end -- 602
	local ____opt_14 = room.story -- 602
	local museum = ____opt_14 and ____opt_14.museum -- 606
	if room.key == "museum" and museum ~= nil then -- 606
		if p.phase == "museum-cabinet" then -- 606
			return { -- 609
				x = museum.cabinetX, -- 609
				y = 64 + 44, -- 609
				keyTag = "E", -- 609
				label = "玻璃柜前 · 收枪入袖", -- 609
				urgent = true -- 609
			} -- 609
		end -- 609
		if p.phase == "museum-hall" then -- 609
			return { -- 612
				x = museum.hallX, -- 612
				y = 120, -- 612
				keyTag = "走到", -- 612
				label = "西厅那头 · 孩子的脚步", -- 612
				urgent = false -- 612
			} -- 612
		end -- 612
		if p.phase == "museum-lamp" then -- 612
			return { -- 615
				x = museum.lampX, -- 615
				y = 120, -- 615
				keyTag = "E", -- 615
				label = "末厅 · 把灯转向西窗", -- 615
				urgent = true -- 615
			} -- 615
		end -- 615
		if p.phase == "museum-return" then -- 615
			return { -- 618
				x = museum.cabinetX, -- 618
				y = 64 + 44, -- 618
				keyTag = "E", -- 618
				label = "回柜边 · 两下轻叩", -- 618
				urgent = true -- 618
			} -- 618
		end -- 618
		if p.phase == "museum-done" then -- 618
			return { -- 621
				x = museum.cabinetX, -- 621
				y = 64 + 44, -- 621
				keyTag = "E", -- 621
				label = "回柜边 · 灯还亮着", -- 621
				urgent = false -- 621
			} -- 621
		end -- 621
		return nil -- 623
	end -- 623
	local ____opt_16 = room.story -- 623
	local tower = ____opt_16 and ____opt_16.tower -- 626
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 626
		return { -- 628
			x = tower.doorX, -- 628
			y = 96, -- 628
			keyTag = "E", -- 628
			label = "敲门", -- 628
			urgent = false -- 628
		} -- 628
	end -- 628
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 628
		return { -- 633
			x = player.x, -- 634
			y = player.y + player.depth + player.h + 25, -- 634
			keyTag = "按住 Shift", -- 635
			label = "贴靠掩体", -- 635
			urgent = gate ~= nil -- 635
		} -- 635
	end -- 635
	return nil -- 638
end -- 481
return ____exports -- 481