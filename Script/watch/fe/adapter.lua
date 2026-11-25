-- [ts]: adapter.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____escort = require("Script.watch.escort") -- 9
local CALM_REACH = ____escort.CALM_REACH -- 9
local ____depth = require("Script.watch.depth") -- 10
local inReachDepth = ____depth.inReachDepth -- 10
____exports.PlayAdapter = __TS__Class() -- 71
local PlayAdapter = ____exports.PlayAdapter -- 71
PlayAdapter.name = "PlayAdapter" -- 71
function PlayAdapter.prototype.____constructor(self) -- 71
	self.prevRoomKey = "" -- 72
	self.prevPhase = "" -- 73
	self.prevHp = 3 -- 74
	self.prevCoveredFlash = 0 -- 76
	self.prevRollT = 0 -- 77
	self.prevCalmTick = 0 -- 78
	self.prevKnocks = 0 -- 79
	self.prevBottleLandT = 0 -- 80
	self.prevCartDocked = false -- 81
	self.prevCheckpoint = -1 -- 82
	self.prevCaughtT = 0 -- 83
	self.prevGateSpawned = 0 -- 84
	self.prevAliveMask = {} -- 85
end -- 71
function PlayAdapter.prototype.reset(self, p) -- 87
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 88
	self.prevPhase = p ~= nil and p.phase or "" -- 89
	self.prevHp = p ~= nil and p.hp or 3 -- 90
	self.prevTrace = nil -- 91
	self.prevCoveredFlash = 0 -- 92
	self.prevRollT = 0 -- 93
	self.prevCalmTick = 0 -- 94
	self.prevKnocks = 0 -- 95
	self.prevBottleLandT = 0 -- 96
	local ____temp_0 -- 97
	if p ~= nil then -- 97
		____temp_0 = p.cartDocked -- 97
	else -- 97
		____temp_0 = false -- 97
	end -- 97
	self.prevCartDocked = ____temp_0 -- 97
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 98
	self.prevCaughtT = 0 -- 99
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 100
	self.prevAliveMask = {} -- 101
	if p ~= nil then -- 101
		local i = 0 -- 103
		do -- 103
			i = 0 -- 104
			while i < #p.enemies do -- 104
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 104
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 105
				i = i + 1 -- 104
			end -- 104
		end -- 104
	end -- 104
end -- 87
function PlayAdapter.prototype.sample(self, p) -- 111
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 112
	if roomChanged then -- 112
		self:reset(p) -- 114
	end -- 114
	local events = p:drainEvents() -- 117
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 118
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 119
	local enemyKilledX = -9999 -- 120
	local enemyKilledY = 0 -- 121
	local i = 0 -- 122
	do -- 122
		i = 0 -- 123
		while i < #p.enemies do -- 123
			local ____temp_2 -- 124
			if i < #self.prevAliveMask then -- 124
				____temp_2 = self.prevAliveMask[i + 1] -- 124
			else -- 124
				____temp_2 = true -- 124
			end -- 124
			local wasAlive = ____temp_2 -- 124
			if wasAlive and not p.enemies[i + 1].alive then -- 124
				enemyKilledX = p.enemies[i + 1].x -- 126
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) + p.enemies[i + 1].h * 0.55 -- 127
			end -- 127
			i = i + 1 -- 123
		end -- 123
	end -- 123
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 131
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 132
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 133
	local knockPulse = false -- 136
	local knockX = p.player.x -- 137
	local knockY = p.player.y + p.player.depth + p.player.h * 0.5 -- 138
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 140
	local bottleLandX = p.bottleLandX -- 141
	local bottleLandY = p.bottleLandY -- 142
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 143
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 144
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 145
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 146
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 147
	local migratedRoomChange = false -- 148
	local storyRouteLocked = false -- 149
	local gateRested = false -- 150
	local handJustTied = false -- 151
	local handReleased = false -- 152
	local storyLine = false -- 153
	local storyLineText = "" -- 154
	local storyExit = false -- 155
	local storyExitRoute = "" -- 156
	local carryStarted = false -- 157
	local reloadOpened = false -- 158
	local reloadSolved = false -- 159
	local reloadEffect = "" -- 160
	local reloadApplied = false -- 161
	local reloadAppliedEffect = "" -- 162
	local reloadTimeout = false -- 163
	local reloadInvalid = false -- 164
	for ____, event in ipairs(events) do -- 165
		if event.name == "knock" then -- 165
			knockPulse = true -- 167
			local x = event.data.x -- 168
			knockX = type(x) == "number" and x or p.player.x -- 169
			knockY = p.escort.state == "calming" and p.partner.y + p.partner.depth + 28 or p.player.y + p.player.depth + p.player.h * 0.55 -- 170
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 170
			playerHit = true -- 173
		elseif event.name == "coverBlocked" then -- 173
			coverDeflect = true -- 175
		elseif event.name == "bottleLanded" then -- 175
			bottleLanded = true -- 177
			if type(event.data.x) == "number" then -- 177
				bottleLandX = event.data.x -- 179
			end -- 179
			if type(event.data.y) == "number" then -- 179
				bottleLandY = event.data.y -- 182
			end -- 182
		elseif event.name == "cartDocked" then -- 182
			cartJustDocked = true -- 185
		elseif event.name == "roomChange" then -- 185
			migratedRoomChange = true -- 187
		elseif event.name == "storyRouteLocked" then -- 187
			storyRouteLocked = true -- 189
		elseif event.name == "gateCountDone" and p.storyRoute == "soldier" then -- 189
			gateRested = true -- 191
		elseif event.name == "handHeld" then -- 191
			handJustTied = true -- 193
		elseif event.name == "handRelease" then -- 193
			handReleased = true -- 195
		elseif event.name == "storyLine" then -- 195
			storyLine = true -- 197
			storyLineText = type(event.data.text) == "string" and event.data.text or "" -- 198
		elseif event.name == "storyExit" then -- 198
			storyExit = true -- 200
			storyExitRoute = type(event.data.route) == "string" and event.data.route or "" -- 201
		elseif event.name == "carryStart" then -- 201
			carryStarted = true -- 203
		elseif event.name == "reloadOpen" then -- 203
			reloadOpened = true -- 205
		elseif event.name == "reloadSolved" then -- 205
			reloadSolved = true -- 207
			reloadEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 208
		elseif event.name == "reloadApplied" then -- 208
			reloadApplied = true -- 210
			reloadAppliedEffect = type(event.data.effect) == "string" and event.data.effect or "" -- 211
		elseif event.name == "reloadTimeout" then -- 211
			reloadTimeout = true -- 213
		elseif event.name == "reloadInvalid" then -- 213
			reloadInvalid = true -- 215
		end -- 215
	end -- 215
	self.prevRoomKey = p.room.key -- 220
	self.prevPhase = p.phase -- 221
	self.prevHp = p.hp -- 222
	self.prevTrace = p.trace -- 223
	self.prevCoveredFlash = p.coveredFlash -- 224
	self.prevRollT = p.player.rollT -- 225
	self.prevCalmTick = p.escort.calmTick -- 226
	self.prevKnocks = p.knocks -- 227
	self.prevBottleLandT = p.bottleLandT -- 228
	self.prevCartDocked = p.cartDocked -- 229
	self.prevCheckpoint = p.checkpoint -- 230
	self.prevCaughtT = p.caughtT -- 231
	self.prevGateSpawned = p.gateSpawned -- 232
	self.prevAliveMask = {} -- 233
	do -- 233
		i = 0 -- 234
		while i < #p.enemies do -- 234
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 234
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 235
			i = i + 1 -- 234
		end -- 234
	end -- 234
	local ____shotFired_5 = shotFired -- 239
	local ____shotHit_6 = shotHit -- 240
	local ____shotFired_4 -- 241
	if shotFired then -- 241
		____shotFired_4 = p.trace -- 241
	else -- 241
		____shotFired_4 = nil -- 241
	end -- 241
	return { -- 238
		shotFired = ____shotFired_5, -- 239
		shotHit = ____shotHit_6, -- 240
		shotTrace = ____shotFired_4, -- 241
		enemyKilledX = enemyKilledX, -- 242
		enemyKilledY = enemyKilledY, -- 243
		playerHit = playerHit, -- 244
		coverDeflect = coverDeflect, -- 245
		rollStarted = rollStarted, -- 246
		knockPulse = knockPulse, -- 247
		knockX = knockX, -- 248
		knockY = knockY, -- 249
		bottleLanded = bottleLanded, -- 250
		bottleLandX = bottleLandX, -- 251
		bottleLandY = bottleLandY, -- 252
		cartJustDocked = cartJustDocked, -- 253
		checkpointJustHit = checkpointJustHit, -- 254
		caughtTriggered = caughtTriggered, -- 255
		phaseChanged = phaseChanged, -- 256
		roomChanged = roomChanged or migratedRoomChange, -- 257
		gateWaveSpawned = gateWaveSpawned, -- 258
		storyRouteLocked = storyRouteLocked, -- 259
		storyRoute = p.storyRoute, -- 260
		gateRested = gateRested, -- 261
		handJustTied = handJustTied, -- 262
		handReleased = handReleased, -- 263
		storyLine = storyLine, -- 264
		storyLineText = storyLineText, -- 265
		storyExit = storyExit, -- 266
		storyExitRoute = storyExitRoute, -- 267
		carryStarted = carryStarted, -- 268
		reloadOpened = reloadOpened, -- 269
		reloadSolved = reloadSolved, -- 270
		reloadEffect = reloadEffect, -- 271
		reloadApplied = reloadApplied, -- 272
		reloadAppliedEffect = reloadAppliedEffect, -- 273
		reloadTimeout = reloadTimeout, -- 274
		reloadInvalid = reloadInvalid -- 275
	} -- 275
end -- 111
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 281
	local room = p.room -- 282
	local player = p.player -- 283
	if p.paused or not player.alive then -- 283
		return nil -- 285
	end -- 285
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 285
		local ____opt_9 = room.story -- 285
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 285
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 289
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 289
			return { -- 291
				x = p.partner.x, -- 291
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 291
				keyTag = "E", -- 291
				label = "递出指南针", -- 291
				urgent = false -- 291
			} -- 291
		end -- 291
		return nil -- 293
	end -- 293
	if not p.childMode and p.escort.state == "frozen" then -- 293
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 293
			return { -- 298
				x = p.partner.x, -- 298
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 298
				keyTag = "E", -- 298
				label = "安抚小满", -- 298
				urgent = true -- 298
			} -- 298
		end -- 298
		return nil -- 300
	end -- 300
	local ____opt_11 = room.story -- 300
	local gate = ____opt_11 and ____opt_11.gate -- 303
	if gate ~= nil then -- 303
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 303
			return { -- 308
				x = gate.winchX, -- 308
				y = 84, -- 308
				keyTag = "E", -- 308
				label = "重新守门", -- 308
				urgent = true -- 308
			} -- 308
		end -- 308
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 308
			return { -- 311
				x = gate.doorX, -- 311
				y = 98, -- 311
				keyTag = "E", -- 311
				label = "送小满出城", -- 311
				urgent = true -- 311
			} -- 311
		end -- 311
		if p.phase == "gate-wait" then -- 311
			local ratio = math.max( -- 315
				0, -- 315
				math.min(1, p.handTicks / p.handNeedTicks) -- 315
			) -- 315
			return { -- 316
				x = gate.doorX + 30, -- 317
				y = 96, -- 317
				keyTag = p.handArmed and "按住 E" or "松开再按住 E", -- 318
				label = p.handTicks > 0 and "牵起小满" or "把手伸给她", -- 319
				urgent = p.handArmed, -- 320
				progress = ratio -- 320
			} -- 320
		end -- 320
		if p.phase == "gate-hand" then -- 320
			return { -- 324
				x = gate.doorX + 30, -- 324
				y = 96, -- 324
				keyTag = "E", -- 324
				label = "我们走吧。", -- 324
				urgent = false -- 324
			} -- 324
		end -- 324
		if p.phase == "gate-walk" then -- 324
			return { -- 327
				x = player.x, -- 327
				y = player.y + player.h + 22, -- 327
				keyTag = "→", -- 327
				label = "走向城外", -- 327
				urgent = false -- 327
			} -- 327
		end -- 327
	end -- 327
	if p.reloadOpen then -- 327
		local ratio = math.max( -- 333
			0, -- 333
			math.min(1, p.reloadAnswerTicks / 240) -- 333
		) -- 333
		return { -- 334
			x = player.x, -- 335
			y = player.y + player.depth + player.h + 34, -- 335
			keyTag = "连线", -- 336
			label = "画到枪机复位", -- 336
			urgent = p.reloadAnswerTicks > 168, -- 336
			progress = ratio -- 336
		} -- 336
	end -- 336
	if p.reloadPendingEffect ~= "" then -- 336
		return { -- 340
			x = player.x, -- 341
			y = player.y + player.depth + player.h + 34, -- 341
			keyTag = "F", -- 342
			label = "枪机已上势 · 打下一枪", -- 342
			urgent = false -- 342
		} -- 342
	end -- 342
	if room.key == "gatepath" and not p.carryOn then -- 342
		return { -- 346
			x = player.x, -- 346
			y = player.y + player.h + 24, -- 346
			keyTag = "→", -- 346
			label = "走到高石阶", -- 346
			urgent = false -- 346
		} -- 346
	end -- 346
	if room.key == "escort1" and p.carryOn then -- 346
		return { -- 349
			x = player.x, -- 349
			y = player.y + player.h + 24, -- 349
			keyTag = "→", -- 349
			label = "带她走到出口", -- 349
			urgent = false -- 349
		} -- 349
	end -- 349
	local cart = room.cart -- 352
	if (room.key == "checkpoint" or room.key == "outside") and not p.cartDocked and cart.bodyW > 0 then -- 352
		local handleX = p.cartAxle + cart.handleOffset -- 354
		if p.gripping or p:cartHandleInReach() then -- 354
			return { -- 356
				x = handleX, -- 357
				y = cart.baseY + (cart.depth or 0) + cart.wheelR + cart.bodyH + 46, -- 358
				keyTag = "按住 E + D", -- 359
				label = room.key == "checkpoint" and "向前推车" or "向前拉车", -- 360
				urgent = false -- 361
			} -- 361
		end -- 361
	end -- 361
	if room.key == "village" and p.scavChase then -- 361
		local ____player_crouch_13 -- 367
		if player.crouch then -- 367
			____player_crouch_13 = nil -- 367
		else -- 367
			____player_crouch_13 = { -- 367
				x = player.x, -- 368
				y = player.y + player.h + 22, -- 368
				keyTag = "按住 Ctrl", -- 368
				label = "蹲下躲避", -- 368
				urgent = true -- 368
			} -- 368
		end -- 368
		return ____player_crouch_13 -- 367
	end -- 367
	if room.key == "village" and not p.passed then -- 367
		local bottle = room.bottle -- 373
		if p.hasBottle then -- 373
			return { -- 375
				x = player.x, -- 376
				y = player.y + player.h + 26, -- 376
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 377
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 378
				urgent = false -- 378
			} -- 378
		end -- 378
		if p.bottleFly == nil and bottle ~= nil then -- 378
			local dx = player.x - bottle.x -- 382
			local dy = player.y + player.h * 0.5 - bottle.y -- 383
			if dx * dx + dy * dy < 56 * 56 then -- 383
				return { -- 385
					x = bottle.x, -- 385
					y = bottle.y + 36, -- 385
					keyTag = "E", -- 385
					label = "拾起瓶子", -- 385
					urgent = false -- 385
				} -- 385
			end -- 385
		end -- 385
	end -- 385
	local arch = room.arch -- 390
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 390
		return { -- 394
			x = (arch.x0 + arch.x1) * 0.5, -- 395
			y = arch.y + arch.h + 44, -- 395
			keyTag = "按住 Ctrl", -- 396
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 396
			urgent = false -- 396
		} -- 396
	end -- 396
	local ____opt_14 = room.story -- 396
	local tower = ____opt_14 and ____opt_14.tower -- 400
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 400
		return { -- 402
			x = tower.doorX, -- 402
			y = 96, -- 402
			keyTag = "E", -- 402
			label = "敲门", -- 402
			urgent = false -- 402
		} -- 402
	end -- 402
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 402
		return { -- 407
			x = player.x, -- 408
			y = player.y + player.depth + player.h + 25, -- 408
			keyTag = "按住 Shift", -- 409
			label = "贴靠掩体", -- 409
			urgent = gate ~= nil -- 409
		} -- 409
	end -- 409
	return nil -- 412
end -- 281
return ____exports -- 281