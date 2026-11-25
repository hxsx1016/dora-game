-- [ts]: adapter.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____escort = require("Script.watch.escort") -- 9
local CALM_REACH = ____escort.CALM_REACH -- 9
local ____depth = require("Script.watch.depth") -- 10
local inReachDepth = ____depth.inReachDepth -- 10
____exports.PlayAdapter = __TS__Class() -- 94
local PlayAdapter = ____exports.PlayAdapter -- 94
PlayAdapter.name = "PlayAdapter" -- 94
function PlayAdapter.prototype.____constructor(self) -- 94
	self.prevRoomKey = "" -- 95
	self.prevPhase = "" -- 96
	self.prevHp = 3 -- 97
	self.prevCoveredFlash = 0 -- 99
	self.prevRollT = 0 -- 100
	self.prevCalmTick = 0 -- 101
	self.prevKnocks = 0 -- 102
	self.prevBottleLandT = 0 -- 103
	self.prevCartDocked = false -- 104
	self.prevCheckpoint = -1 -- 105
	self.prevCaughtT = 0 -- 106
	self.prevGateSpawned = 0 -- 107
	self.prevAliveMask = {} -- 108
end -- 94
function PlayAdapter.prototype.reset(self, p) -- 110
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 111
	self.prevPhase = p ~= nil and p.phase or "" -- 112
	self.prevHp = p ~= nil and p.hp or 3 -- 113
	self.prevTrace = nil -- 114
	self.prevCoveredFlash = 0 -- 115
	self.prevRollT = 0 -- 116
	self.prevCalmTick = 0 -- 117
	self.prevKnocks = 0 -- 118
	self.prevBottleLandT = 0 -- 119
	local ____temp_0 -- 120
	if p ~= nil then -- 120
		____temp_0 = p.cartDocked -- 120
	else -- 120
		____temp_0 = false -- 120
	end -- 120
	self.prevCartDocked = ____temp_0 -- 120
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 121
	self.prevCaughtT = 0 -- 122
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 123
	self.prevAliveMask = {} -- 124
	if p ~= nil then -- 124
		local i = 0 -- 126
		do -- 126
			i = 0 -- 127
			while i < #p.enemies do -- 127
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 127
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 128
				i = i + 1 -- 127
			end -- 127
		end -- 127
	end -- 127
end -- 110
function PlayAdapter.prototype.sample(self, p) -- 134
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 135
	if roomChanged then -- 135
		self:reset(p) -- 137
	end -- 137
	local events = p:drainEvents() -- 140
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 141
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 142
	local enemyKilledX = -9999 -- 143
	local enemyKilledY = 0 -- 144
	local i = 0 -- 145
	do -- 145
		i = 0 -- 146
		while i < #p.enemies do -- 146
			local ____temp_2 -- 147
			if i < #self.prevAliveMask then -- 147
				____temp_2 = self.prevAliveMask[i + 1] -- 147
			else -- 147
				____temp_2 = true -- 147
			end -- 147
			local wasAlive = ____temp_2 -- 147
			if wasAlive and not p.enemies[i + 1].alive then -- 147
				enemyKilledX = p.enemies[i + 1].x -- 149
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) + p.enemies[i + 1].h * 0.55 -- 150
			end -- 150
			i = i + 1 -- 146
		end -- 146
	end -- 146
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 154
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 155
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 156
	local knockPulse = false -- 159
	local knockX = p.player.x -- 160
	local knockY = p.player.y + p.player.depth + p.player.h * 0.5 -- 161
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 163
	local bottleLandX = p.bottleLandX -- 164
	local bottleLandY = p.bottleLandY -- 165
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 166
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 167
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 168
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 169
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 170
	local migratedRoomChange = false -- 171
	local storyRouteLocked = false -- 172
	local gateRested = false -- 173
	local handJustTied = false -- 174
	local handReleased = false -- 175
	local storyLine = false -- 176
	local storyLineText = "" -- 177
	local storyExit = false -- 178
	local storyExitRoute = "" -- 179
	local carryStarted = false -- 180
	local reloadOpened = false -- 181
	local reloadSolved = false -- 182
	local reloadEffect = "" -- 183
	local reloadApplied = false -- 184
	local reloadAppliedEffect = "" -- 185
	local reloadTimeout = false -- 186
	local reloadInvalid = false -- 187
	local segmentDone = false -- 188
	local segmentKey = "" -- 189
	local segmentNext = "" -- 190
	local benchOpened = false -- 191
	local benchCrafted = false -- 192
	local benchCraftedWeapon = "" -- 193
	local benchEquipped = false -- 194
	local benchClosed = false -- 195
	local benchRejected = false -- 196
	local benchRejectReason = "" -- 197
	local endingReached = false -- 198
	local museumStep = false -- 199
	local museumStepName = "" -- 200
	local museumDone = false -- 201
	local ending = "" -- 202
	local endingOfficial = false -- 203
	local endingLines = {} -- 204
	for ____, event in ipairs(events) do -- 205
		if event.name == "knock" then -- 205
			knockPulse = true -- 207
			local x = event.data.x -- 208
			knockX = type(x) == "number" and x or p.player.x -- 209
			knockY = p.escort.state == "calming" and p.partner.y + p.partner.depth + 28 or p.player.y + p.player.depth + p.player.h * 0.55 -- 210
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 210
			playerHit = true -- 213
		elseif event.name == "coverBlocked" then -- 213
			coverDeflect = true -- 215
		elseif event.name == "bottleLanded" then -- 215
			bottleLanded = true -- 217
			if type(event.data.x) == "number" then -- 217
				bottleLandX = event.data.x -- 219
			end -- 219
			if type(event.data.y) == "number" then -- 219
				bottleLandY = event.data.y -- 222
			end -- 222
		elseif event.name == "cartDocked" then -- 222
			cartJustDocked = true -- 225
		elseif event.name == "roomChange" then -- 225
			migratedRoomChange = true -- 227
		elseif event.name == "storyRouteLocked" then -- 227
			storyRouteLocked = true -- 229
		elseif event.name == "gateCountDone" and p.storyRoute == "soldier" then -- 229
			gateRested = true -- 231
		elseif event.name == "handHeld" then -- 231
			handJustTied = true -- 233
		elseif event.name == "handRelease" then -- 233
			handReleased = true -- 235
		elseif event.name == "storyLine" then -- 235
			storyLine = true -- 237
			storyLineText = type(event.data.text) == "string" and event.data.text or "" -- 238
		elseif event.name == "storyExit" then -- 238
			storyExit = true -- 240
			storyExitRoute = type(event.data.route) == "string" and event.data.route or "" -- 241
		elseif event.name == "carryStart" then -- 241
			carryStarted = true -- 243
		elseif event.name == "reloadOpen" then -- 243
			reloadOpened = true -- 245
		elseif event.name == "reloadSolved" then -- 245
			reloadSolved = true -- 247
			reloadEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 248
		elseif event.name == "reloadApplied" then -- 248
			reloadApplied = true -- 250
			reloadAppliedEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 251
		elseif event.name == "reloadTimeout" then -- 251
			reloadTimeout = true -- 253
		elseif event.name == "reloadInvalid" then -- 253
			reloadInvalid = true -- 255
		elseif event.name == "segmentDone" then -- 255
			segmentDone = true -- 257
			segmentKey = type(event.data.room) == "string" and event.data.room or "" -- 258
			segmentNext = type(event.data.next) == "string" and event.data.next or "" -- 259
		elseif event.name == "benchOpen" then -- 259
			benchOpened = true -- 261
		elseif event.name == "benchCraft" then -- 261
			benchCrafted = true -- 263
			benchCraftedWeapon = type(event.data.weapon) == "string" and event.data.weapon or "" -- 264
		elseif event.name == "benchEquip" then -- 264
			benchEquipped = true -- 266
		elseif event.name == "benchClose" then -- 266
			benchClosed = true -- 268
		elseif event.name == "benchRejected" then -- 268
			benchRejected = true -- 270
			benchRejectReason = type(event.data.reason) == "string" and event.data.reason or "" -- 271
		elseif event.name == "museumStep" then -- 271
			museumStep = true -- 273
			museumStepName = type(event.data.step) == "string" and event.data.step or "" -- 274
		elseif event.name == "museumDone" then -- 274
			museumDone = true -- 276
		elseif event.name == "endingReached" then -- 276
			endingReached = true -- 278
			ending = type(event.data.ending) == "string" and event.data.ending or "" -- 279
			endingOfficial = event.data.official == true -- 280
			endingLines = __TS__ArrayIsArray(event.data.lines) and __TS__ArrayMap( -- 281
				event.data.lines, -- 282
				function(____, v) return type(v) == "string" and v or "" end -- 282
			) or ({}) -- 282
		end -- 282
	end -- 282
	self.prevRoomKey = p.room.key -- 288
	self.prevPhase = p.phase -- 289
	self.prevHp = p.hp -- 290
	self.prevTrace = p.trace -- 291
	self.prevCoveredFlash = p.coveredFlash -- 292
	self.prevRollT = p.player.rollT -- 293
	self.prevCalmTick = p.escort.calmTick -- 294
	self.prevKnocks = p.knocks -- 295
	self.prevBottleLandT = p.bottleLandT -- 296
	self.prevCartDocked = p.cartDocked -- 297
	self.prevCheckpoint = p.checkpoint -- 298
	self.prevCaughtT = p.caughtT -- 299
	self.prevGateSpawned = p.gateSpawned -- 300
	self.prevAliveMask = {} -- 301
	do -- 301
		i = 0 -- 302
		while i < #p.enemies do -- 302
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 302
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 303
			i = i + 1 -- 302
		end -- 302
	end -- 302
	local ____shotFired_5 = shotFired -- 307
	local ____shotHit_6 = shotHit -- 308
	local ____shotFired_4 -- 309
	if shotFired then -- 309
		____shotFired_4 = p.trace -- 309
	else -- 309
		____shotFired_4 = nil -- 309
	end -- 309
	return { -- 306
		shotFired = ____shotFired_5, -- 307
		shotHit = ____shotHit_6, -- 308
		shotTrace = ____shotFired_4, -- 309
		enemyKilledX = enemyKilledX, -- 310
		enemyKilledY = enemyKilledY, -- 311
		playerHit = playerHit, -- 312
		coverDeflect = coverDeflect, -- 313
		rollStarted = rollStarted, -- 314
		knockPulse = knockPulse, -- 315
		knockX = knockX, -- 316
		knockY = knockY, -- 317
		bottleLanded = bottleLanded, -- 318
		bottleLandX = bottleLandX, -- 319
		bottleLandY = bottleLandY, -- 320
		cartJustDocked = cartJustDocked, -- 321
		checkpointJustHit = checkpointJustHit, -- 322
		caughtTriggered = caughtTriggered, -- 323
		phaseChanged = phaseChanged, -- 324
		roomChanged = roomChanged or migratedRoomChange, -- 325
		gateWaveSpawned = gateWaveSpawned, -- 326
		storyRouteLocked = storyRouteLocked, -- 327
		storyRoute = p.storyRoute, -- 328
		gateRested = gateRested, -- 329
		handJustTied = handJustTied, -- 330
		handReleased = handReleased, -- 331
		storyLine = storyLine, -- 332
		storyLineText = storyLineText, -- 333
		storyExit = storyExit, -- 334
		storyExitRoute = storyExitRoute, -- 335
		carryStarted = carryStarted, -- 336
		reloadOpened = reloadOpened, -- 337
		reloadSolved = reloadSolved, -- 338
		reloadEffect = reloadEffect, -- 339
		reloadApplied = reloadApplied, -- 340
		reloadAppliedEffect = reloadAppliedEffect, -- 341
		reloadTimeout = reloadTimeout, -- 342
		reloadInvalid = reloadInvalid, -- 343
		segmentDone = segmentDone, -- 344
		segmentKey = segmentKey, -- 345
		segmentNext = segmentNext, -- 346
		benchOpened = benchOpened, -- 347
		benchCrafted = benchCrafted, -- 348
		benchCraftedWeapon = benchCraftedWeapon, -- 349
		benchEquipped = benchEquipped, -- 350
		benchClosed = benchClosed, -- 351
		benchRejected = benchRejected, -- 352
		benchRejectReason = benchRejectReason, -- 353
		endingReached = endingReached, -- 354
		ending = ending, -- 355
		endingOfficial = endingOfficial, -- 356
		endingLines = endingLines, -- 357
		museumStep = museumStep, -- 358
		museumStepName = museumStepName, -- 359
		museumDone = museumDone -- 360
	} -- 360
end -- 134
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 366
	local room = p.room -- 367
	local player = p.player -- 368
	if p.paused or not player.alive then -- 368
		return nil -- 370
	end -- 370
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 370
		local ____opt_9 = room.story -- 370
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 370
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 374
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 374
			return { -- 376
				x = p.partner.x, -- 376
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 376
				keyTag = "E", -- 376
				label = "递出指南针", -- 376
				urgent = false -- 376
			} -- 376
		end -- 376
		return nil -- 378
	end -- 378
	if not p.childMode and p.escort.state == "frozen" then -- 378
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 378
			return { -- 383
				x = p.partner.x, -- 383
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 383
				keyTag = "E", -- 383
				label = "安抚小满", -- 383
				urgent = true -- 383
			} -- 383
		end -- 383
		return nil -- 385
	end -- 385
	local ____opt_11 = room.story -- 385
	local gate = ____opt_11 and ____opt_11.gate -- 388
	if gate ~= nil then -- 388
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 388
			return { -- 393
				x = gate.winchX, -- 393
				y = 84, -- 393
				keyTag = "E", -- 393
				label = "重新守门", -- 393
				urgent = true -- 393
			} -- 393
		end -- 393
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 393
			return { -- 396
				x = gate.doorX, -- 396
				y = 98, -- 396
				keyTag = "E", -- 396
				label = "送小满出城", -- 396
				urgent = true -- 396
			} -- 396
		end -- 396
		if p.phase == "gate-wait" then -- 396
			local ratio = math.max( -- 400
				0, -- 400
				math.min(1, p.handTicks / p.handNeedTicks) -- 400
			) -- 400
			return { -- 401
				x = gate.doorX + 30, -- 402
				y = 96, -- 402
				keyTag = p.handArmed and "按住 E" or "松开再按住 E", -- 403
				label = p.handTicks > 0 and "牵起小满" or "把手伸给她", -- 404
				urgent = p.handArmed, -- 405
				progress = ratio -- 405
			} -- 405
		end -- 405
		if p.phase == "gate-hand" then -- 405
			return { -- 409
				x = gate.doorX + 30, -- 409
				y = 96, -- 409
				keyTag = "E", -- 409
				label = "我们走吧。", -- 409
				urgent = false -- 409
			} -- 409
		end -- 409
		if p.phase == "gate-walk" then -- 409
			return { -- 412
				x = player.x, -- 412
				y = player.y + player.h + 22, -- 412
				keyTag = "→", -- 412
				label = "走向城外", -- 412
				urgent = false -- 412
			} -- 412
		end -- 412
	end -- 412
	if p.reloadOpen then -- 412
		local ratio = math.max( -- 418
			0, -- 418
			math.min(1, p.reloadAnswerTicks / 240) -- 418
		) -- 418
		return { -- 419
			x = player.x, -- 420
			y = player.y + player.depth + player.h + 34, -- 420
			keyTag = "连线", -- 421
			label = "画到枪机复位", -- 421
			urgent = p.reloadAnswerTicks > 168, -- 421
			progress = ratio -- 421
		} -- 421
	end -- 421
	if p.reloadPendingEffect ~= "" then -- 421
		return { -- 425
			x = player.x, -- 426
			y = player.y + player.depth + player.h + 34, -- 426
			keyTag = "F", -- 427
			label = "枪机已上势 · 打下一枪", -- 427
			urgent = false -- 427
		} -- 427
	end -- 427
	if room.key == "gatepath" and not p.carryOn then -- 427
		return { -- 431
			x = player.x, -- 431
			y = player.y + player.h + 24, -- 431
			keyTag = "→", -- 431
			label = "走到高石阶", -- 431
			urgent = false -- 431
		} -- 431
	end -- 431
	if room.key == "escort3" and not p.craftBench.active then -- 431
		local bench = 560 -- 434
		if math.abs(player.x - bench) <= p.benchReach + 40 and player.y < 12 then -- 434
			return { -- 436
				x = bench, -- 436
				y = 92, -- 436
				keyTag = "E", -- 436
				label = "在工台制作", -- 436
				urgent = false -- 436
			} -- 436
		end -- 436
	end -- 436
	if (room.key == "escort2" or room.key == "escort3" or room.key == "escort4" or room.key == "escort5") and p.carryOn then -- 436
		return { -- 440
			x = player.x, -- 440
			y = player.y + player.h + 24, -- 440
			keyTag = "→", -- 440
			label = "带她走到出口", -- 440
			urgent = false -- 440
		} -- 440
	end -- 440
	local cart = room.cart -- 443
	if (room.key == "checkpoint" or room.key == "outside") and not p.cartDocked and cart.bodyW > 0 then -- 443
		local handleX = p.cartAxle + cart.handleOffset -- 445
		if p.gripping or p:cartHandleInReach() then -- 445
			return { -- 447
				x = handleX, -- 448
				y = cart.baseY + (cart.depth or 0) + cart.wheelR + cart.bodyH + 46, -- 449
				keyTag = "按住 E + D", -- 450
				label = room.key == "checkpoint" and "向前推车" or "向前拉车", -- 451
				urgent = false -- 452
			} -- 452
		end -- 452
	end -- 452
	if room.key == "village" and p.scavChase then -- 452
		local ____player_crouch_13 -- 458
		if player.crouch then -- 458
			____player_crouch_13 = nil -- 458
		else -- 458
			____player_crouch_13 = { -- 458
				x = player.x, -- 459
				y = player.y + player.h + 22, -- 459
				keyTag = "按住 Ctrl", -- 459
				label = "蹲下躲避", -- 459
				urgent = true -- 459
			} -- 459
		end -- 459
		return ____player_crouch_13 -- 458
	end -- 458
	if room.key == "village" and not p.passed then -- 458
		local bottle = room.bottle -- 464
		if p.hasBottle then -- 464
			return { -- 466
				x = player.x, -- 467
				y = player.y + player.h + 26, -- 467
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 468
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 469
				urgent = false -- 469
			} -- 469
		end -- 469
		if p.bottleFly == nil and bottle ~= nil then -- 469
			local dx = player.x - bottle.x -- 473
			local dy = player.y + player.h * 0.5 - bottle.y -- 474
			if dx * dx + dy * dy < 56 * 56 then -- 474
				return { -- 476
					x = bottle.x, -- 476
					y = bottle.y + 36, -- 476
					keyTag = "E", -- 476
					label = "拾起瓶子", -- 476
					urgent = false -- 476
				} -- 476
			end -- 476
		end -- 476
	end -- 476
	local arch = room.arch -- 481
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 481
		return { -- 485
			x = (arch.x0 + arch.x1) * 0.5, -- 486
			y = arch.y + arch.h + 44, -- 486
			keyTag = "按住 Ctrl", -- 487
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 487
			urgent = false -- 487
		} -- 487
	end -- 487
	local ____opt_14 = room.story -- 487
	local museum = ____opt_14 and ____opt_14.museum -- 491
	if room.key == "museum" and museum ~= nil then -- 491
		if p.phase == "museum-cabinet" then -- 491
			return { -- 494
				x = museum.cabinetX, -- 494
				y = 64 + 44, -- 494
				keyTag = "E", -- 494
				label = "玻璃柜前 · 收枪入袖", -- 494
				urgent = true -- 494
			} -- 494
		end -- 494
		if p.phase == "museum-hall" then -- 494
			return { -- 497
				x = museum.hallX, -- 497
				y = 120, -- 497
				keyTag = "走到", -- 497
				label = "西厅那头 · 孩子的脚步", -- 497
				urgent = false -- 497
			} -- 497
		end -- 497
		if p.phase == "museum-lamp" then -- 497
			return { -- 500
				x = museum.lampX, -- 500
				y = 120, -- 500
				keyTag = "E", -- 500
				label = "末厅 · 把灯转向西窗", -- 500
				urgent = true -- 500
			} -- 500
		end -- 500
		if p.phase == "museum-return" then -- 500
			return { -- 503
				x = museum.cabinetX, -- 503
				y = 64 + 44, -- 503
				keyTag = "E", -- 503
				label = "回柜边 · 两下轻叩", -- 503
				urgent = true -- 503
			} -- 503
		end -- 503
		if p.phase == "museum-done" then -- 503
			return { -- 506
				x = museum.cabinetX, -- 506
				y = 64 + 44, -- 506
				keyTag = "E", -- 506
				label = "回柜边 · 灯还亮着", -- 506
				urgent = false -- 506
			} -- 506
		end -- 506
		return nil -- 508
	end -- 508
	local ____opt_16 = room.story -- 508
	local tower = ____opt_16 and ____opt_16.tower -- 511
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 511
		return { -- 513
			x = tower.doorX, -- 513
			y = 96, -- 513
			keyTag = "E", -- 513
			label = "敲门", -- 513
			urgent = false -- 513
		} -- 513
	end -- 513
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 513
		return { -- 518
			x = player.x, -- 519
			y = player.y + player.depth + player.h + 25, -- 519
			keyTag = "按住 Shift", -- 520
			label = "贴靠掩体", -- 520
			urgent = gate ~= nil -- 520
		} -- 520
	end -- 520
	return nil -- 523
end -- 366
return ____exports -- 366