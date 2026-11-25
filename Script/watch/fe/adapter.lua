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
____exports.PlayAdapter = __TS__Class() -- 90
local PlayAdapter = ____exports.PlayAdapter -- 90
PlayAdapter.name = "PlayAdapter" -- 90
function PlayAdapter.prototype.____constructor(self) -- 90
	self.prevRoomKey = "" -- 91
	self.prevPhase = "" -- 92
	self.prevHp = 3 -- 93
	self.prevCoveredFlash = 0 -- 95
	self.prevRollT = 0 -- 96
	self.prevCalmTick = 0 -- 97
	self.prevKnocks = 0 -- 98
	self.prevBottleLandT = 0 -- 99
	self.prevCartDocked = false -- 100
	self.prevCheckpoint = -1 -- 101
	self.prevCaughtT = 0 -- 102
	self.prevGateSpawned = 0 -- 103
	self.prevAliveMask = {} -- 104
end -- 90
function PlayAdapter.prototype.reset(self, p) -- 106
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 107
	self.prevPhase = p ~= nil and p.phase or "" -- 108
	self.prevHp = p ~= nil and p.hp or 3 -- 109
	self.prevTrace = nil -- 110
	self.prevCoveredFlash = 0 -- 111
	self.prevRollT = 0 -- 112
	self.prevCalmTick = 0 -- 113
	self.prevKnocks = 0 -- 114
	self.prevBottleLandT = 0 -- 115
	local ____temp_0 -- 116
	if p ~= nil then -- 116
		____temp_0 = p.cartDocked -- 116
	else -- 116
		____temp_0 = false -- 116
	end -- 116
	self.prevCartDocked = ____temp_0 -- 116
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 117
	self.prevCaughtT = 0 -- 118
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 119
	self.prevAliveMask = {} -- 120
	if p ~= nil then -- 120
		local i = 0 -- 122
		do -- 122
			i = 0 -- 123
			while i < #p.enemies do -- 123
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 123
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 124
				i = i + 1 -- 123
			end -- 123
		end -- 123
	end -- 123
end -- 106
function PlayAdapter.prototype.sample(self, p) -- 130
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 131
	if roomChanged then -- 131
		self:reset(p) -- 133
	end -- 133
	local events = p:drainEvents() -- 136
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 137
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 138
	local enemyKilledX = -9999 -- 139
	local enemyKilledY = 0 -- 140
	local i = 0 -- 141
	do -- 141
		i = 0 -- 142
		while i < #p.enemies do -- 142
			local ____temp_2 -- 143
			if i < #self.prevAliveMask then -- 143
				____temp_2 = self.prevAliveMask[i + 1] -- 143
			else -- 143
				____temp_2 = true -- 143
			end -- 143
			local wasAlive = ____temp_2 -- 143
			if wasAlive and not p.enemies[i + 1].alive then -- 143
				enemyKilledX = p.enemies[i + 1].x -- 145
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) + p.enemies[i + 1].h * 0.55 -- 146
			end -- 146
			i = i + 1 -- 142
		end -- 142
	end -- 142
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 150
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 151
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 152
	local knockPulse = false -- 155
	local knockX = p.player.x -- 156
	local knockY = p.player.y + p.player.depth + p.player.h * 0.5 -- 157
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 159
	local bottleLandX = p.bottleLandX -- 160
	local bottleLandY = p.bottleLandY -- 161
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 162
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 163
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 164
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 165
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 166
	local migratedRoomChange = false -- 167
	local storyRouteLocked = false -- 168
	local gateRested = false -- 169
	local handJustTied = false -- 170
	local handReleased = false -- 171
	local storyLine = false -- 172
	local storyLineText = "" -- 173
	local storyExit = false -- 174
	local storyExitRoute = "" -- 175
	local carryStarted = false -- 176
	local reloadOpened = false -- 177
	local reloadSolved = false -- 178
	local reloadEffect = "" -- 179
	local reloadApplied = false -- 180
	local reloadAppliedEffect = "" -- 181
	local reloadTimeout = false -- 182
	local reloadInvalid = false -- 183
	local segmentDone = false -- 184
	local segmentKey = "" -- 185
	local segmentNext = "" -- 186
	local benchOpened = false -- 187
	local benchCrafted = false -- 188
	local benchCraftedWeapon = "" -- 189
	local benchEquipped = false -- 190
	local benchClosed = false -- 191
	local benchRejected = false -- 192
	local benchRejectReason = "" -- 193
	local endingReached = false -- 194
	local ending = "" -- 195
	local endingOfficial = false -- 196
	local endingLines = {} -- 197
	for ____, event in ipairs(events) do -- 198
		if event.name == "knock" then -- 198
			knockPulse = true -- 200
			local x = event.data.x -- 201
			knockX = type(x) == "number" and x or p.player.x -- 202
			knockY = p.escort.state == "calming" and p.partner.y + p.partner.depth + 28 or p.player.y + p.player.depth + p.player.h * 0.55 -- 203
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 203
			playerHit = true -- 206
		elseif event.name == "coverBlocked" then -- 206
			coverDeflect = true -- 208
		elseif event.name == "bottleLanded" then -- 208
			bottleLanded = true -- 210
			if type(event.data.x) == "number" then -- 210
				bottleLandX = event.data.x -- 212
			end -- 212
			if type(event.data.y) == "number" then -- 212
				bottleLandY = event.data.y -- 215
			end -- 215
		elseif event.name == "cartDocked" then -- 215
			cartJustDocked = true -- 218
		elseif event.name == "roomChange" then -- 218
			migratedRoomChange = true -- 220
		elseif event.name == "storyRouteLocked" then -- 220
			storyRouteLocked = true -- 222
		elseif event.name == "gateCountDone" and p.storyRoute == "soldier" then -- 222
			gateRested = true -- 224
		elseif event.name == "handHeld" then -- 224
			handJustTied = true -- 226
		elseif event.name == "handRelease" then -- 226
			handReleased = true -- 228
		elseif event.name == "storyLine" then -- 228
			storyLine = true -- 230
			storyLineText = type(event.data.text) == "string" and event.data.text or "" -- 231
		elseif event.name == "storyExit" then -- 231
			storyExit = true -- 233
			storyExitRoute = type(event.data.route) == "string" and event.data.route or "" -- 234
		elseif event.name == "carryStart" then -- 234
			carryStarted = true -- 236
		elseif event.name == "reloadOpen" then -- 236
			reloadOpened = true -- 238
		elseif event.name == "reloadSolved" then -- 238
			reloadSolved = true -- 240
			reloadEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 241
		elseif event.name == "reloadApplied" then -- 241
			reloadApplied = true -- 243
			reloadAppliedEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 244
		elseif event.name == "reloadTimeout" then -- 244
			reloadTimeout = true -- 246
		elseif event.name == "reloadInvalid" then -- 246
			reloadInvalid = true -- 248
		elseif event.name == "segmentDone" then -- 248
			segmentDone = true -- 250
			segmentKey = type(event.data.room) == "string" and event.data.room or "" -- 251
			segmentNext = type(event.data.next) == "string" and event.data.next or "" -- 252
		elseif event.name == "benchOpen" then -- 252
			benchOpened = true -- 254
		elseif event.name == "benchCraft" then -- 254
			benchCrafted = true -- 256
			benchCraftedWeapon = type(event.data.weapon) == "string" and event.data.weapon or "" -- 257
		elseif event.name == "benchEquip" then -- 257
			benchEquipped = true -- 259
		elseif event.name == "benchClose" then -- 259
			benchClosed = true -- 261
		elseif event.name == "benchRejected" then -- 261
			benchRejected = true -- 263
			benchRejectReason = type(event.data.reason) == "string" and event.data.reason or "" -- 264
		elseif event.name == "endingReached" then -- 264
			endingReached = true -- 266
			ending = type(event.data.ending) == "string" and event.data.ending or "" -- 267
			endingOfficial = event.data.official == true -- 268
			endingLines = __TS__ArrayIsArray(event.data.lines) and __TS__ArrayMap( -- 269
				event.data.lines, -- 270
				function(____, v) return type(v) == "string" and v or "" end -- 270
			) or ({}) -- 270
		end -- 270
	end -- 270
	self.prevRoomKey = p.room.key -- 276
	self.prevPhase = p.phase -- 277
	self.prevHp = p.hp -- 278
	self.prevTrace = p.trace -- 279
	self.prevCoveredFlash = p.coveredFlash -- 280
	self.prevRollT = p.player.rollT -- 281
	self.prevCalmTick = p.escort.calmTick -- 282
	self.prevKnocks = p.knocks -- 283
	self.prevBottleLandT = p.bottleLandT -- 284
	self.prevCartDocked = p.cartDocked -- 285
	self.prevCheckpoint = p.checkpoint -- 286
	self.prevCaughtT = p.caughtT -- 287
	self.prevGateSpawned = p.gateSpawned -- 288
	self.prevAliveMask = {} -- 289
	do -- 289
		i = 0 -- 290
		while i < #p.enemies do -- 290
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 290
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 291
			i = i + 1 -- 290
		end -- 290
	end -- 290
	local ____shotFired_5 = shotFired -- 295
	local ____shotHit_6 = shotHit -- 296
	local ____shotFired_4 -- 297
	if shotFired then -- 297
		____shotFired_4 = p.trace -- 297
	else -- 297
		____shotFired_4 = nil -- 297
	end -- 297
	return { -- 294
		shotFired = ____shotFired_5, -- 295
		shotHit = ____shotHit_6, -- 296
		shotTrace = ____shotFired_4, -- 297
		enemyKilledX = enemyKilledX, -- 298
		enemyKilledY = enemyKilledY, -- 299
		playerHit = playerHit, -- 300
		coverDeflect = coverDeflect, -- 301
		rollStarted = rollStarted, -- 302
		knockPulse = knockPulse, -- 303
		knockX = knockX, -- 304
		knockY = knockY, -- 305
		bottleLanded = bottleLanded, -- 306
		bottleLandX = bottleLandX, -- 307
		bottleLandY = bottleLandY, -- 308
		cartJustDocked = cartJustDocked, -- 309
		checkpointJustHit = checkpointJustHit, -- 310
		caughtTriggered = caughtTriggered, -- 311
		phaseChanged = phaseChanged, -- 312
		roomChanged = roomChanged or migratedRoomChange, -- 313
		gateWaveSpawned = gateWaveSpawned, -- 314
		storyRouteLocked = storyRouteLocked, -- 315
		storyRoute = p.storyRoute, -- 316
		gateRested = gateRested, -- 317
		handJustTied = handJustTied, -- 318
		handReleased = handReleased, -- 319
		storyLine = storyLine, -- 320
		storyLineText = storyLineText, -- 321
		storyExit = storyExit, -- 322
		storyExitRoute = storyExitRoute, -- 323
		carryStarted = carryStarted, -- 324
		reloadOpened = reloadOpened, -- 325
		reloadSolved = reloadSolved, -- 326
		reloadEffect = reloadEffect, -- 327
		reloadApplied = reloadApplied, -- 328
		reloadAppliedEffect = reloadAppliedEffect, -- 329
		reloadTimeout = reloadTimeout, -- 330
		reloadInvalid = reloadInvalid, -- 331
		segmentDone = segmentDone, -- 332
		segmentKey = segmentKey, -- 333
		segmentNext = segmentNext, -- 334
		benchOpened = benchOpened, -- 335
		benchCrafted = benchCrafted, -- 336
		benchCraftedWeapon = benchCraftedWeapon, -- 337
		benchEquipped = benchEquipped, -- 338
		benchClosed = benchClosed, -- 339
		benchRejected = benchRejected, -- 340
		benchRejectReason = benchRejectReason, -- 341
		endingReached = endingReached, -- 342
		ending = ending, -- 343
		endingOfficial = endingOfficial, -- 344
		endingLines = endingLines -- 345
	} -- 345
end -- 130
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 351
	local room = p.room -- 352
	local player = p.player -- 353
	if p.paused or not player.alive then -- 353
		return nil -- 355
	end -- 355
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 355
		local ____opt_9 = room.story -- 355
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 355
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 359
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 359
			return { -- 361
				x = p.partner.x, -- 361
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 361
				keyTag = "E", -- 361
				label = "递出指南针", -- 361
				urgent = false -- 361
			} -- 361
		end -- 361
		return nil -- 363
	end -- 363
	if not p.childMode and p.escort.state == "frozen" then -- 363
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 363
			return { -- 368
				x = p.partner.x, -- 368
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 368
				keyTag = "E", -- 368
				label = "安抚小满", -- 368
				urgent = true -- 368
			} -- 368
		end -- 368
		return nil -- 370
	end -- 370
	local ____opt_11 = room.story -- 370
	local gate = ____opt_11 and ____opt_11.gate -- 373
	if gate ~= nil then -- 373
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 373
			return { -- 378
				x = gate.winchX, -- 378
				y = 84, -- 378
				keyTag = "E", -- 378
				label = "重新守门", -- 378
				urgent = true -- 378
			} -- 378
		end -- 378
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 378
			return { -- 381
				x = gate.doorX, -- 381
				y = 98, -- 381
				keyTag = "E", -- 381
				label = "送小满出城", -- 381
				urgent = true -- 381
			} -- 381
		end -- 381
		if p.phase == "gate-wait" then -- 381
			local ratio = math.max( -- 385
				0, -- 385
				math.min(1, p.handTicks / p.handNeedTicks) -- 385
			) -- 385
			return { -- 386
				x = gate.doorX + 30, -- 387
				y = 96, -- 387
				keyTag = p.handArmed and "按住 E" or "松开再按住 E", -- 388
				label = p.handTicks > 0 and "牵起小满" or "把手伸给她", -- 389
				urgent = p.handArmed, -- 390
				progress = ratio -- 390
			} -- 390
		end -- 390
		if p.phase == "gate-hand" then -- 390
			return { -- 394
				x = gate.doorX + 30, -- 394
				y = 96, -- 394
				keyTag = "E", -- 394
				label = "我们走吧。", -- 394
				urgent = false -- 394
			} -- 394
		end -- 394
		if p.phase == "gate-walk" then -- 394
			return { -- 397
				x = player.x, -- 397
				y = player.y + player.h + 22, -- 397
				keyTag = "→", -- 397
				label = "走向城外", -- 397
				urgent = false -- 397
			} -- 397
		end -- 397
	end -- 397
	if p.reloadOpen then -- 397
		local ratio = math.max( -- 403
			0, -- 403
			math.min(1, p.reloadAnswerTicks / 240) -- 403
		) -- 403
		return { -- 404
			x = player.x, -- 405
			y = player.y + player.depth + player.h + 34, -- 405
			keyTag = "连线", -- 406
			label = "画到枪机复位", -- 406
			urgent = p.reloadAnswerTicks > 168, -- 406
			progress = ratio -- 406
		} -- 406
	end -- 406
	if p.reloadPendingEffect ~= "" then -- 406
		return { -- 410
			x = player.x, -- 411
			y = player.y + player.depth + player.h + 34, -- 411
			keyTag = "F", -- 412
			label = "枪机已上势 · 打下一枪", -- 412
			urgent = false -- 412
		} -- 412
	end -- 412
	if room.key == "gatepath" and not p.carryOn then -- 412
		return { -- 416
			x = player.x, -- 416
			y = player.y + player.h + 24, -- 416
			keyTag = "→", -- 416
			label = "走到高石阶", -- 416
			urgent = false -- 416
		} -- 416
	end -- 416
	if room.key == "escort3" and not p.craftBench.active then -- 416
		local bench = 560 -- 419
		if math.abs(player.x - bench) <= p.benchReach + 40 and player.y < 12 then -- 419
			return { -- 421
				x = bench, -- 421
				y = 92, -- 421
				keyTag = "E", -- 421
				label = "在工台制作", -- 421
				urgent = false -- 421
			} -- 421
		end -- 421
	end -- 421
	if (room.key == "escort2" or room.key == "escort3" or room.key == "escort4" or room.key == "escort5") and p.carryOn then -- 421
		return { -- 425
			x = player.x, -- 425
			y = player.y + player.h + 24, -- 425
			keyTag = "→", -- 425
			label = "带她走到出口", -- 425
			urgent = false -- 425
		} -- 425
	end -- 425
	local cart = room.cart -- 428
	if (room.key == "checkpoint" or room.key == "outside") and not p.cartDocked and cart.bodyW > 0 then -- 428
		local handleX = p.cartAxle + cart.handleOffset -- 430
		if p.gripping or p:cartHandleInReach() then -- 430
			return { -- 432
				x = handleX, -- 433
				y = cart.baseY + (cart.depth or 0) + cart.wheelR + cart.bodyH + 46, -- 434
				keyTag = "按住 E + D", -- 435
				label = room.key == "checkpoint" and "向前推车" or "向前拉车", -- 436
				urgent = false -- 437
			} -- 437
		end -- 437
	end -- 437
	if room.key == "village" and p.scavChase then -- 437
		local ____player_crouch_13 -- 443
		if player.crouch then -- 443
			____player_crouch_13 = nil -- 443
		else -- 443
			____player_crouch_13 = { -- 443
				x = player.x, -- 444
				y = player.y + player.h + 22, -- 444
				keyTag = "按住 Ctrl", -- 444
				label = "蹲下躲避", -- 444
				urgent = true -- 444
			} -- 444
		end -- 444
		return ____player_crouch_13 -- 443
	end -- 443
	if room.key == "village" and not p.passed then -- 443
		local bottle = room.bottle -- 449
		if p.hasBottle then -- 449
			return { -- 451
				x = player.x, -- 452
				y = player.y + player.h + 26, -- 452
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 453
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 454
				urgent = false -- 454
			} -- 454
		end -- 454
		if p.bottleFly == nil and bottle ~= nil then -- 454
			local dx = player.x - bottle.x -- 458
			local dy = player.y + player.h * 0.5 - bottle.y -- 459
			if dx * dx + dy * dy < 56 * 56 then -- 459
				return { -- 461
					x = bottle.x, -- 461
					y = bottle.y + 36, -- 461
					keyTag = "E", -- 461
					label = "拾起瓶子", -- 461
					urgent = false -- 461
				} -- 461
			end -- 461
		end -- 461
	end -- 461
	local arch = room.arch -- 466
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 466
		return { -- 470
			x = (arch.x0 + arch.x1) * 0.5, -- 471
			y = arch.y + arch.h + 44, -- 471
			keyTag = "按住 Ctrl", -- 472
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 472
			urgent = false -- 472
		} -- 472
	end -- 472
	local ____opt_14 = room.story -- 472
	local tower = ____opt_14 and ____opt_14.tower -- 476
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 476
		return { -- 478
			x = tower.doorX, -- 478
			y = 96, -- 478
			keyTag = "E", -- 478
			label = "敲门", -- 478
			urgent = false -- 478
		} -- 478
	end -- 478
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 478
		return { -- 483
			x = player.x, -- 484
			y = player.y + player.depth + player.h + 25, -- 484
			keyTag = "按住 Shift", -- 485
			label = "贴靠掩体", -- 485
			urgent = gate ~= nil -- 485
		} -- 485
	end -- 485
	return nil -- 488
end -- 351
return ____exports -- 351