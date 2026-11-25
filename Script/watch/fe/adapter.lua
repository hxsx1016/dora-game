-- [ts]: adapter.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____escort = require("Script.watch.escort") -- 9
local CALM_REACH = ____escort.CALM_REACH -- 9
local ____depth = require("Script.watch.depth") -- 10
local inReachDepth = ____depth.inReachDepth -- 10
____exports.PlayAdapter = __TS__Class() -- 86
local PlayAdapter = ____exports.PlayAdapter -- 86
PlayAdapter.name = "PlayAdapter" -- 86
function PlayAdapter.prototype.____constructor(self) -- 86
	self.prevRoomKey = "" -- 87
	self.prevPhase = "" -- 88
	self.prevHp = 3 -- 89
	self.prevCoveredFlash = 0 -- 91
	self.prevRollT = 0 -- 92
	self.prevCalmTick = 0 -- 93
	self.prevKnocks = 0 -- 94
	self.prevBottleLandT = 0 -- 95
	self.prevCartDocked = false -- 96
	self.prevCheckpoint = -1 -- 97
	self.prevCaughtT = 0 -- 98
	self.prevGateSpawned = 0 -- 99
	self.prevAliveMask = {} -- 100
end -- 86
function PlayAdapter.prototype.reset(self, p) -- 102
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 103
	self.prevPhase = p ~= nil and p.phase or "" -- 104
	self.prevHp = p ~= nil and p.hp or 3 -- 105
	self.prevTrace = nil -- 106
	self.prevCoveredFlash = 0 -- 107
	self.prevRollT = 0 -- 108
	self.prevCalmTick = 0 -- 109
	self.prevKnocks = 0 -- 110
	self.prevBottleLandT = 0 -- 111
	local ____temp_0 -- 112
	if p ~= nil then -- 112
		____temp_0 = p.cartDocked -- 112
	else -- 112
		____temp_0 = false -- 112
	end -- 112
	self.prevCartDocked = ____temp_0 -- 112
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 113
	self.prevCaughtT = 0 -- 114
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 115
	self.prevAliveMask = {} -- 116
	if p ~= nil then -- 116
		local i = 0 -- 118
		do -- 118
			i = 0 -- 119
			while i < #p.enemies do -- 119
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 119
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 120
				i = i + 1 -- 119
			end -- 119
		end -- 119
	end -- 119
end -- 102
function PlayAdapter.prototype.sample(self, p) -- 126
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 127
	if roomChanged then -- 127
		self:reset(p) -- 129
	end -- 129
	local events = p:drainEvents() -- 132
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 133
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 134
	local enemyKilledX = -9999 -- 135
	local enemyKilledY = 0 -- 136
	local i = 0 -- 137
	do -- 137
		i = 0 -- 138
		while i < #p.enemies do -- 138
			local ____temp_2 -- 139
			if i < #self.prevAliveMask then -- 139
				____temp_2 = self.prevAliveMask[i + 1] -- 139
			else -- 139
				____temp_2 = true -- 139
			end -- 139
			local wasAlive = ____temp_2 -- 139
			if wasAlive and not p.enemies[i + 1].alive then -- 139
				enemyKilledX = p.enemies[i + 1].x -- 141
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) + p.enemies[i + 1].h * 0.55 -- 142
			end -- 142
			i = i + 1 -- 138
		end -- 138
	end -- 138
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 146
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 147
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 148
	local knockPulse = false -- 151
	local knockX = p.player.x -- 152
	local knockY = p.player.y + p.player.depth + p.player.h * 0.5 -- 153
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 155
	local bottleLandX = p.bottleLandX -- 156
	local bottleLandY = p.bottleLandY -- 157
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 158
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 159
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 160
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 161
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 162
	local migratedRoomChange = false -- 163
	local storyRouteLocked = false -- 164
	local gateRested = false -- 165
	local handJustTied = false -- 166
	local handReleased = false -- 167
	local storyLine = false -- 168
	local storyLineText = "" -- 169
	local storyExit = false -- 170
	local storyExitRoute = "" -- 171
	local carryStarted = false -- 172
	local reloadOpened = false -- 173
	local reloadSolved = false -- 174
	local reloadEffect = "" -- 175
	local reloadApplied = false -- 176
	local reloadAppliedEffect = "" -- 177
	local reloadTimeout = false -- 178
	local reloadInvalid = false -- 179
	local segmentDone = false -- 180
	local segmentKey = "" -- 181
	local segmentNext = "" -- 182
	local benchOpened = false -- 183
	local benchCrafted = false -- 184
	local benchCraftedWeapon = "" -- 185
	local benchEquipped = false -- 186
	local benchClosed = false -- 187
	local benchRejected = false -- 188
	local benchRejectReason = "" -- 189
	local endingReached = false -- 190
	local ending = "" -- 191
	for ____, event in ipairs(events) do -- 192
		if event.name == "knock" then -- 192
			knockPulse = true -- 194
			local x = event.data.x -- 195
			knockX = type(x) == "number" and x or p.player.x -- 196
			knockY = p.escort.state == "calming" and p.partner.y + p.partner.depth + 28 or p.player.y + p.player.depth + p.player.h * 0.55 -- 197
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 197
			playerHit = true -- 200
		elseif event.name == "coverBlocked" then -- 200
			coverDeflect = true -- 202
		elseif event.name == "bottleLanded" then -- 202
			bottleLanded = true -- 204
			if type(event.data.x) == "number" then -- 204
				bottleLandX = event.data.x -- 206
			end -- 206
			if type(event.data.y) == "number" then -- 206
				bottleLandY = event.data.y -- 209
			end -- 209
		elseif event.name == "cartDocked" then -- 209
			cartJustDocked = true -- 212
		elseif event.name == "roomChange" then -- 212
			migratedRoomChange = true -- 214
		elseif event.name == "storyRouteLocked" then -- 214
			storyRouteLocked = true -- 216
		elseif event.name == "gateCountDone" and p.storyRoute == "soldier" then -- 216
			gateRested = true -- 218
		elseif event.name == "handHeld" then -- 218
			handJustTied = true -- 220
		elseif event.name == "handRelease" then -- 220
			handReleased = true -- 222
		elseif event.name == "storyLine" then -- 222
			storyLine = true -- 224
			storyLineText = type(event.data.text) == "string" and event.data.text or "" -- 225
		elseif event.name == "storyExit" then -- 225
			storyExit = true -- 227
			storyExitRoute = type(event.data.route) == "string" and event.data.route or "" -- 228
		elseif event.name == "carryStart" then -- 228
			carryStarted = true -- 230
		elseif event.name == "reloadOpen" then -- 230
			reloadOpened = true -- 232
		elseif event.name == "reloadSolved" then -- 232
			reloadSolved = true -- 234
			reloadEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 235
		elseif event.name == "reloadApplied" then -- 235
			reloadApplied = true -- 237
			reloadAppliedEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 238
		elseif event.name == "reloadTimeout" then -- 238
			reloadTimeout = true -- 240
		elseif event.name == "reloadInvalid" then -- 240
			reloadInvalid = true -- 242
		elseif event.name == "segmentDone" then -- 242
			segmentDone = true -- 244
			segmentKey = type(event.data.room) == "string" and event.data.room or "" -- 245
			segmentNext = type(event.data.next) == "string" and event.data.next or "" -- 246
		elseif event.name == "benchOpen" then -- 246
			benchOpened = true -- 248
		elseif event.name == "benchCraft" then -- 248
			benchCrafted = true -- 250
			benchCraftedWeapon = type(event.data.weapon) == "string" and event.data.weapon or "" -- 251
		elseif event.name == "benchEquip" then -- 251
			benchEquipped = true -- 253
		elseif event.name == "benchClose" then -- 253
			benchClosed = true -- 255
		elseif event.name == "benchRejected" then -- 255
			benchRejected = true -- 257
			benchRejectReason = type(event.data.reason) == "string" and event.data.reason or "" -- 258
		elseif event.name == "endingReached" then -- 258
			endingReached = true -- 260
			ending = type(event.data.ending) == "string" and event.data.ending or "" -- 261
		end -- 261
	end -- 261
	self.prevRoomKey = p.room.key -- 266
	self.prevPhase = p.phase -- 267
	self.prevHp = p.hp -- 268
	self.prevTrace = p.trace -- 269
	self.prevCoveredFlash = p.coveredFlash -- 270
	self.prevRollT = p.player.rollT -- 271
	self.prevCalmTick = p.escort.calmTick -- 272
	self.prevKnocks = p.knocks -- 273
	self.prevBottleLandT = p.bottleLandT -- 274
	self.prevCartDocked = p.cartDocked -- 275
	self.prevCheckpoint = p.checkpoint -- 276
	self.prevCaughtT = p.caughtT -- 277
	self.prevGateSpawned = p.gateSpawned -- 278
	self.prevAliveMask = {} -- 279
	do -- 279
		i = 0 -- 280
		while i < #p.enemies do -- 280
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 280
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 281
			i = i + 1 -- 280
		end -- 280
	end -- 280
	local ____shotFired_5 = shotFired -- 285
	local ____shotHit_6 = shotHit -- 286
	local ____shotFired_4 -- 287
	if shotFired then -- 287
		____shotFired_4 = p.trace -- 287
	else -- 287
		____shotFired_4 = nil -- 287
	end -- 287
	return { -- 284
		shotFired = ____shotFired_5, -- 285
		shotHit = ____shotHit_6, -- 286
		shotTrace = ____shotFired_4, -- 287
		enemyKilledX = enemyKilledX, -- 288
		enemyKilledY = enemyKilledY, -- 289
		playerHit = playerHit, -- 290
		coverDeflect = coverDeflect, -- 291
		rollStarted = rollStarted, -- 292
		knockPulse = knockPulse, -- 293
		knockX = knockX, -- 294
		knockY = knockY, -- 295
		bottleLanded = bottleLanded, -- 296
		bottleLandX = bottleLandX, -- 297
		bottleLandY = bottleLandY, -- 298
		cartJustDocked = cartJustDocked, -- 299
		checkpointJustHit = checkpointJustHit, -- 300
		caughtTriggered = caughtTriggered, -- 301
		phaseChanged = phaseChanged, -- 302
		roomChanged = roomChanged or migratedRoomChange, -- 303
		gateWaveSpawned = gateWaveSpawned, -- 304
		storyRouteLocked = storyRouteLocked, -- 305
		storyRoute = p.storyRoute, -- 306
		gateRested = gateRested, -- 307
		handJustTied = handJustTied, -- 308
		handReleased = handReleased, -- 309
		storyLine = storyLine, -- 310
		storyLineText = storyLineText, -- 311
		storyExit = storyExit, -- 312
		storyExitRoute = storyExitRoute, -- 313
		carryStarted = carryStarted, -- 314
		reloadOpened = reloadOpened, -- 315
		reloadSolved = reloadSolved, -- 316
		reloadEffect = reloadEffect, -- 317
		reloadApplied = reloadApplied, -- 318
		reloadAppliedEffect = reloadAppliedEffect, -- 319
		reloadTimeout = reloadTimeout, -- 320
		reloadInvalid = reloadInvalid, -- 321
		segmentDone = segmentDone, -- 322
		segmentKey = segmentKey, -- 323
		segmentNext = segmentNext, -- 324
		benchOpened = benchOpened, -- 325
		benchCrafted = benchCrafted, -- 326
		benchCraftedWeapon = benchCraftedWeapon, -- 327
		benchEquipped = benchEquipped, -- 328
		benchClosed = benchClosed, -- 329
		benchRejected = benchRejected, -- 330
		benchRejectReason = benchRejectReason, -- 331
		endingReached = endingReached, -- 332
		ending = ending -- 333
	} -- 333
end -- 126
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 339
	local room = p.room -- 340
	local player = p.player -- 341
	if p.paused or not player.alive then -- 341
		return nil -- 343
	end -- 343
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 343
		local ____opt_9 = room.story -- 343
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 343
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 347
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 347
			return { -- 349
				x = p.partner.x, -- 349
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 349
				keyTag = "E", -- 349
				label = "递出指南针", -- 349
				urgent = false -- 349
			} -- 349
		end -- 349
		return nil -- 351
	end -- 351
	if not p.childMode and p.escort.state == "frozen" then -- 351
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 351
			return { -- 356
				x = p.partner.x, -- 356
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 356
				keyTag = "E", -- 356
				label = "安抚小满", -- 356
				urgent = true -- 356
			} -- 356
		end -- 356
		return nil -- 358
	end -- 358
	local ____opt_11 = room.story -- 358
	local gate = ____opt_11 and ____opt_11.gate -- 361
	if gate ~= nil then -- 361
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 361
			return { -- 366
				x = gate.winchX, -- 366
				y = 84, -- 366
				keyTag = "E", -- 366
				label = "重新守门", -- 366
				urgent = true -- 366
			} -- 366
		end -- 366
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 366
			return { -- 369
				x = gate.doorX, -- 369
				y = 98, -- 369
				keyTag = "E", -- 369
				label = "送小满出城", -- 369
				urgent = true -- 369
			} -- 369
		end -- 369
		if p.phase == "gate-wait" then -- 369
			local ratio = math.max( -- 373
				0, -- 373
				math.min(1, p.handTicks / p.handNeedTicks) -- 373
			) -- 373
			return { -- 374
				x = gate.doorX + 30, -- 375
				y = 96, -- 375
				keyTag = p.handArmed and "按住 E" or "松开再按住 E", -- 376
				label = p.handTicks > 0 and "牵起小满" or "把手伸给她", -- 377
				urgent = p.handArmed, -- 378
				progress = ratio -- 378
			} -- 378
		end -- 378
		if p.phase == "gate-hand" then -- 378
			return { -- 382
				x = gate.doorX + 30, -- 382
				y = 96, -- 382
				keyTag = "E", -- 382
				label = "我们走吧。", -- 382
				urgent = false -- 382
			} -- 382
		end -- 382
		if p.phase == "gate-walk" then -- 382
			return { -- 385
				x = player.x, -- 385
				y = player.y + player.h + 22, -- 385
				keyTag = "→", -- 385
				label = "走向城外", -- 385
				urgent = false -- 385
			} -- 385
		end -- 385
	end -- 385
	if p.reloadOpen then -- 385
		local ratio = math.max( -- 391
			0, -- 391
			math.min(1, p.reloadAnswerTicks / 240) -- 391
		) -- 391
		return { -- 392
			x = player.x, -- 393
			y = player.y + player.depth + player.h + 34, -- 393
			keyTag = "连线", -- 394
			label = "画到枪机复位", -- 394
			urgent = p.reloadAnswerTicks > 168, -- 394
			progress = ratio -- 394
		} -- 394
	end -- 394
	if p.reloadPendingEffect ~= "" then -- 394
		return { -- 398
			x = player.x, -- 399
			y = player.y + player.depth + player.h + 34, -- 399
			keyTag = "F", -- 400
			label = "枪机已上势 · 打下一枪", -- 400
			urgent = false -- 400
		} -- 400
	end -- 400
	if room.key == "gatepath" and not p.carryOn then -- 400
		return { -- 404
			x = player.x, -- 404
			y = player.y + player.h + 24, -- 404
			keyTag = "→", -- 404
			label = "走到高石阶", -- 404
			urgent = false -- 404
		} -- 404
	end -- 404
	if room.key == "escort3" and not p.craftBench.active then -- 404
		local bench = 560 -- 407
		if math.abs(player.x - bench) <= p.benchReach + 40 and player.y < 12 then -- 407
			return { -- 409
				x = bench, -- 409
				y = 92, -- 409
				keyTag = "E", -- 409
				label = "在工台制作", -- 409
				urgent = false -- 409
			} -- 409
		end -- 409
	end -- 409
	if (room.key == "escort2" or room.key == "escort3" or room.key == "escort4" or room.key == "escort5") and p.carryOn then -- 409
		return { -- 413
			x = player.x, -- 413
			y = player.y + player.h + 24, -- 413
			keyTag = "→", -- 413
			label = "带她走到出口", -- 413
			urgent = false -- 413
		} -- 413
	end -- 413
	local cart = room.cart -- 416
	if (room.key == "checkpoint" or room.key == "outside") and not p.cartDocked and cart.bodyW > 0 then -- 416
		local handleX = p.cartAxle + cart.handleOffset -- 418
		if p.gripping or p:cartHandleInReach() then -- 418
			return { -- 420
				x = handleX, -- 421
				y = cart.baseY + (cart.depth or 0) + cart.wheelR + cart.bodyH + 46, -- 422
				keyTag = "按住 E + D", -- 423
				label = room.key == "checkpoint" and "向前推车" or "向前拉车", -- 424
				urgent = false -- 425
			} -- 425
		end -- 425
	end -- 425
	if room.key == "village" and p.scavChase then -- 425
		local ____player_crouch_13 -- 431
		if player.crouch then -- 431
			____player_crouch_13 = nil -- 431
		else -- 431
			____player_crouch_13 = { -- 431
				x = player.x, -- 432
				y = player.y + player.h + 22, -- 432
				keyTag = "按住 Ctrl", -- 432
				label = "蹲下躲避", -- 432
				urgent = true -- 432
			} -- 432
		end -- 432
		return ____player_crouch_13 -- 431
	end -- 431
	if room.key == "village" and not p.passed then -- 431
		local bottle = room.bottle -- 437
		if p.hasBottle then -- 437
			return { -- 439
				x = player.x, -- 440
				y = player.y + player.h + 26, -- 440
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 441
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 442
				urgent = false -- 442
			} -- 442
		end -- 442
		if p.bottleFly == nil and bottle ~= nil then -- 442
			local dx = player.x - bottle.x -- 446
			local dy = player.y + player.h * 0.5 - bottle.y -- 447
			if dx * dx + dy * dy < 56 * 56 then -- 447
				return { -- 449
					x = bottle.x, -- 449
					y = bottle.y + 36, -- 449
					keyTag = "E", -- 449
					label = "拾起瓶子", -- 449
					urgent = false -- 449
				} -- 449
			end -- 449
		end -- 449
	end -- 449
	local arch = room.arch -- 454
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 454
		return { -- 458
			x = (arch.x0 + arch.x1) * 0.5, -- 459
			y = arch.y + arch.h + 44, -- 459
			keyTag = "按住 Ctrl", -- 460
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 460
			urgent = false -- 460
		} -- 460
	end -- 460
	local ____opt_14 = room.story -- 460
	local tower = ____opt_14 and ____opt_14.tower -- 464
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 464
		return { -- 466
			x = tower.doorX, -- 466
			y = 96, -- 466
			keyTag = "E", -- 466
			label = "敲门", -- 466
			urgent = false -- 466
		} -- 466
	end -- 466
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 466
		return { -- 471
			x = player.x, -- 472
			y = player.y + player.depth + player.h + 25, -- 472
			keyTag = "按住 Shift", -- 473
			label = "贴靠掩体", -- 473
			urgent = gate ~= nil -- 473
		} -- 473
	end -- 473
	return nil -- 476
end -- 339
return ____exports -- 339