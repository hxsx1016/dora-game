-- [ts]: adapter.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____escort = require("Script.watch.escort") -- 9
local CALM_REACH = ____escort.CALM_REACH -- 9
local ____depth = require("Script.watch.depth") -- 10
local inReachDepth = ____depth.inReachDepth -- 10
____exports.PlayAdapter = __TS__Class() -- 61
local PlayAdapter = ____exports.PlayAdapter -- 61
PlayAdapter.name = "PlayAdapter" -- 61
function PlayAdapter.prototype.____constructor(self) -- 61
	self.prevRoomKey = "" -- 62
	self.prevPhase = "" -- 63
	self.prevHp = 3 -- 64
	self.prevCoveredFlash = 0 -- 66
	self.prevRollT = 0 -- 67
	self.prevCalmTick = 0 -- 68
	self.prevKnocks = 0 -- 69
	self.prevBottleLandT = 0 -- 70
	self.prevCartDocked = false -- 71
	self.prevCheckpoint = -1 -- 72
	self.prevCaughtT = 0 -- 73
	self.prevGateSpawned = 0 -- 74
	self.prevAliveMask = {} -- 75
end -- 61
function PlayAdapter.prototype.reset(self, p) -- 77
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 78
	self.prevPhase = p ~= nil and p.phase or "" -- 79
	self.prevHp = p ~= nil and p.hp or 3 -- 80
	self.prevTrace = nil -- 81
	self.prevCoveredFlash = 0 -- 82
	self.prevRollT = 0 -- 83
	self.prevCalmTick = 0 -- 84
	self.prevKnocks = 0 -- 85
	self.prevBottleLandT = 0 -- 86
	local ____temp_0 -- 87
	if p ~= nil then -- 87
		____temp_0 = p.cartDocked -- 87
	else -- 87
		____temp_0 = false -- 87
	end -- 87
	self.prevCartDocked = ____temp_0 -- 87
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 88
	self.prevCaughtT = 0 -- 89
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 90
	self.prevAliveMask = {} -- 91
	if p ~= nil then -- 91
		local i = 0 -- 93
		do -- 93
			i = 0 -- 94
			while i < #p.enemies do -- 94
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 94
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 95
				i = i + 1 -- 94
			end -- 94
		end -- 94
	end -- 94
end -- 77
function PlayAdapter.prototype.sample(self, p) -- 101
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 102
	if roomChanged then -- 102
		self:reset(p) -- 104
	end -- 104
	local events = p:drainEvents() -- 107
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 108
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 109
	local enemyKilledX = -9999 -- 110
	local enemyKilledY = 0 -- 111
	local i = 0 -- 112
	do -- 112
		i = 0 -- 113
		while i < #p.enemies do -- 113
			local ____temp_2 -- 114
			if i < #self.prevAliveMask then -- 114
				____temp_2 = self.prevAliveMask[i + 1] -- 114
			else -- 114
				____temp_2 = true -- 114
			end -- 114
			local wasAlive = ____temp_2 -- 114
			if wasAlive and not p.enemies[i + 1].alive then -- 114
				enemyKilledX = p.enemies[i + 1].x -- 116
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) + p.enemies[i + 1].h * 0.55 -- 117
			end -- 117
			i = i + 1 -- 113
		end -- 113
	end -- 113
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 121
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 122
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 123
	local knockPulse = false -- 126
	local knockX = p.player.x -- 127
	local knockY = p.player.y + p.player.depth + p.player.h * 0.5 -- 128
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 130
	local bottleLandX = p.bottleLandX -- 131
	local bottleLandY = p.bottleLandY -- 132
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 133
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 134
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 135
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 136
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 137
	local migratedRoomChange = false -- 138
	local storyRouteLocked = false -- 139
	local gateRested = false -- 140
	local handJustTied = false -- 141
	local handReleased = false -- 142
	local storyLine = false -- 143
	local storyLineText = "" -- 144
	local storyExit = false -- 145
	local storyExitRoute = "" -- 146
	for ____, event in ipairs(events) do -- 147
		if event.name == "knock" then -- 147
			knockPulse = true -- 149
			local x = event.data.x -- 150
			knockX = type(x) == "number" and x or p.player.x -- 151
			knockY = p.escort.state == "calming" and p.partner.y + p.partner.depth + 28 or p.player.y + p.player.depth + p.player.h * 0.55 -- 152
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 152
			playerHit = true -- 155
		elseif event.name == "coverBlocked" then -- 155
			coverDeflect = true -- 157
		elseif event.name == "bottleLanded" then -- 157
			bottleLanded = true -- 159
			if type(event.data.x) == "number" then -- 159
				bottleLandX = event.data.x -- 161
			end -- 161
			if type(event.data.y) == "number" then -- 161
				bottleLandY = event.data.y -- 164
			end -- 164
		elseif event.name == "cartDocked" then -- 164
			cartJustDocked = true -- 167
		elseif event.name == "roomChange" then -- 167
			migratedRoomChange = true -- 169
		elseif event.name == "storyRouteLocked" then -- 169
			storyRouteLocked = true -- 171
		elseif event.name == "gateCountDone" and p.storyRoute == "soldier" then -- 171
			gateRested = true -- 173
		elseif event.name == "handHeld" then -- 173
			handJustTied = true -- 175
		elseif event.name == "handRelease" then -- 175
			handReleased = true -- 177
		elseif event.name == "storyLine" then -- 177
			storyLine = true -- 179
			storyLineText = type(event.data.text) == "string" and event.data.text or "" -- 180
		elseif event.name == "storyExit" then -- 180
			storyExit = true -- 182
			storyExitRoute = type(event.data.route) == "string" and event.data.route or "" -- 183
		end -- 183
	end -- 183
	self.prevRoomKey = p.room.key -- 188
	self.prevPhase = p.phase -- 189
	self.prevHp = p.hp -- 190
	self.prevTrace = p.trace -- 191
	self.prevCoveredFlash = p.coveredFlash -- 192
	self.prevRollT = p.player.rollT -- 193
	self.prevCalmTick = p.escort.calmTick -- 194
	self.prevKnocks = p.knocks -- 195
	self.prevBottleLandT = p.bottleLandT -- 196
	self.prevCartDocked = p.cartDocked -- 197
	self.prevCheckpoint = p.checkpoint -- 198
	self.prevCaughtT = p.caughtT -- 199
	self.prevGateSpawned = p.gateSpawned -- 200
	self.prevAliveMask = {} -- 201
	do -- 201
		i = 0 -- 202
		while i < #p.enemies do -- 202
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 202
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 203
			i = i + 1 -- 202
		end -- 202
	end -- 202
	local ____shotFired_5 = shotFired -- 207
	local ____shotHit_6 = shotHit -- 208
	local ____shotFired_4 -- 209
	if shotFired then -- 209
		____shotFired_4 = p.trace -- 209
	else -- 209
		____shotFired_4 = nil -- 209
	end -- 209
	return { -- 206
		shotFired = ____shotFired_5, -- 207
		shotHit = ____shotHit_6, -- 208
		shotTrace = ____shotFired_4, -- 209
		enemyKilledX = enemyKilledX, -- 210
		enemyKilledY = enemyKilledY, -- 211
		playerHit = playerHit, -- 212
		coverDeflect = coverDeflect, -- 213
		rollStarted = rollStarted, -- 214
		knockPulse = knockPulse, -- 215
		knockX = knockX, -- 216
		knockY = knockY, -- 217
		bottleLanded = bottleLanded, -- 218
		bottleLandX = bottleLandX, -- 219
		bottleLandY = bottleLandY, -- 220
		cartJustDocked = cartJustDocked, -- 221
		checkpointJustHit = checkpointJustHit, -- 222
		caughtTriggered = caughtTriggered, -- 223
		phaseChanged = phaseChanged, -- 224
		roomChanged = roomChanged or migratedRoomChange, -- 225
		gateWaveSpawned = gateWaveSpawned, -- 226
		storyRouteLocked = storyRouteLocked, -- 227
		storyRoute = p.storyRoute, -- 228
		gateRested = gateRested, -- 229
		handJustTied = handJustTied, -- 230
		handReleased = handReleased, -- 231
		storyLine = storyLine, -- 232
		storyLineText = storyLineText, -- 233
		storyExit = storyExit, -- 234
		storyExitRoute = storyExitRoute -- 235
	} -- 235
end -- 101
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 241
	local room = p.room -- 242
	local player = p.player -- 243
	if p.paused or not player.alive then -- 243
		return nil -- 245
	end -- 245
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 245
		local ____opt_9 = room.story -- 245
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 245
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 249
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 249
			return { -- 251
				x = p.partner.x, -- 251
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 251
				keyTag = "E", -- 251
				label = "递出指南针", -- 251
				urgent = false -- 251
			} -- 251
		end -- 251
		return nil -- 253
	end -- 253
	if not p.childMode and p.escort.state == "frozen" then -- 253
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 253
			return { -- 258
				x = p.partner.x, -- 258
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 258
				keyTag = "E", -- 258
				label = "安抚小满", -- 258
				urgent = true -- 258
			} -- 258
		end -- 258
		return nil -- 260
	end -- 260
	local ____opt_11 = room.story -- 260
	local gate = ____opt_11 and ____opt_11.gate -- 263
	if gate ~= nil then -- 263
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 263
			return { -- 268
				x = gate.winchX, -- 268
				y = 84, -- 268
				keyTag = "E", -- 268
				label = "重新守门", -- 268
				urgent = true -- 268
			} -- 268
		end -- 268
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 268
			return { -- 271
				x = gate.doorX, -- 271
				y = 98, -- 271
				keyTag = "E", -- 271
				label = "送小满出城", -- 271
				urgent = true -- 271
			} -- 271
		end -- 271
		if p.phase == "gate-wait" then -- 271
			local ratio = math.max( -- 275
				0, -- 275
				math.min(1, p.handTicks / p.handNeedTicks) -- 275
			) -- 275
			return { -- 276
				x = gate.doorX + 30, -- 277
				y = 96, -- 277
				keyTag = p.handArmed and "按住 E" or "松开再按住 E", -- 278
				label = p.handTicks > 0 and "牵起小满" or "把手伸给她", -- 279
				urgent = p.handArmed, -- 280
				progress = ratio -- 280
			} -- 280
		end -- 280
		if p.phase == "gate-hand" then -- 280
			return { -- 284
				x = gate.doorX + 30, -- 284
				y = 96, -- 284
				keyTag = "E", -- 284
				label = "我们走吧。", -- 284
				urgent = false -- 284
			} -- 284
		end -- 284
		if p.phase == "gate-walk" then -- 284
			return { -- 287
				x = player.x, -- 287
				y = player.y + player.h + 22, -- 287
				keyTag = "→", -- 287
				label = "走向城外", -- 287
				urgent = false -- 287
			} -- 287
		end -- 287
	end -- 287
	local cart = room.cart -- 291
	if (room.key == "checkpoint" or room.key == "outside") and not p.cartDocked and cart.bodyW > 0 then -- 291
		local handleX = p.cartAxle + cart.handleOffset -- 293
		if p.gripping or p:cartHandleInReach() then -- 293
			return { -- 295
				x = handleX, -- 296
				y = cart.baseY + (cart.depth or 0) + cart.wheelR + cart.bodyH + 46, -- 297
				keyTag = "按住 E + D", -- 298
				label = room.key == "checkpoint" and "向前推车" or "向前拉车", -- 299
				urgent = false -- 300
			} -- 300
		end -- 300
	end -- 300
	if room.key == "village" and p.scavChase then -- 300
		local ____player_crouch_13 -- 306
		if player.crouch then -- 306
			____player_crouch_13 = nil -- 306
		else -- 306
			____player_crouch_13 = { -- 306
				x = player.x, -- 307
				y = player.y + player.h + 22, -- 307
				keyTag = "按住 Ctrl", -- 307
				label = "蹲下躲避", -- 307
				urgent = true -- 307
			} -- 307
		end -- 307
		return ____player_crouch_13 -- 306
	end -- 306
	if room.key == "village" and not p.passed then -- 306
		local bottle = room.bottle -- 312
		if p.hasBottle then -- 312
			return { -- 314
				x = player.x, -- 315
				y = player.y + player.h + 26, -- 315
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 316
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 317
				urgent = false -- 317
			} -- 317
		end -- 317
		if p.bottleFly == nil and bottle ~= nil then -- 317
			local dx = player.x - bottle.x -- 321
			local dy = player.y + player.h * 0.5 - bottle.y -- 322
			if dx * dx + dy * dy < 56 * 56 then -- 322
				return { -- 324
					x = bottle.x, -- 324
					y = bottle.y + 36, -- 324
					keyTag = "E", -- 324
					label = "拾起瓶子", -- 324
					urgent = false -- 324
				} -- 324
			end -- 324
		end -- 324
	end -- 324
	local arch = room.arch -- 329
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 329
		return { -- 333
			x = (arch.x0 + arch.x1) * 0.5, -- 334
			y = arch.y + arch.h + 44, -- 334
			keyTag = "按住 Ctrl", -- 335
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 335
			urgent = false -- 335
		} -- 335
	end -- 335
	local ____opt_14 = room.story -- 335
	local tower = ____opt_14 and ____opt_14.tower -- 339
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 339
		return { -- 341
			x = tower.doorX, -- 341
			y = 96, -- 341
			keyTag = "E", -- 341
			label = "敲门", -- 341
			urgent = false -- 341
		} -- 341
	end -- 341
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 341
		return { -- 346
			x = player.x, -- 347
			y = player.y + player.depth + player.h + 25, -- 347
			keyTag = "按住 Shift", -- 348
			label = "贴靠掩体", -- 348
			urgent = gate ~= nil -- 348
		} -- 348
	end -- 348
	return nil -- 351
end -- 241
return ____exports -- 241