-- [ts]: adapter.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local ____exports = {} -- 1
local ____escort = require("Script.watch.escort") -- 9
local CALM_REACH = ____escort.CALM_REACH -- 9
local ____depth = require("Script.watch.depth") -- 10
local inReachDepth = ____depth.inReachDepth -- 10
function ____exports.createEmptyFrameEvents(roomSessionId, eventSeq, checkpoint) -- 45
	return { -- 50
		shotFired = false, -- 51
		shotHit = false, -- 52
		shotTrace = nil, -- 53
		enemyKilledX = -9999, -- 54
		enemyKilledY = 0, -- 55
		playerHit = false, -- 56
		coverDeflect = false, -- 57
		rollStarted = false, -- 58
		knockPulse = false, -- 59
		knockX = 0, -- 60
		knockY = 0, -- 61
		bottleLanded = false, -- 62
		bottleLandX = -1, -- 63
		bottleLandY = 0, -- 64
		cartJustDocked = false, -- 65
		checkpointJustHit = false, -- 66
		caughtTriggered = false, -- 67
		phaseChanged = false, -- 68
		roomChanged = false, -- 69
		gateWaveSpawned = false, -- 70
		rawEvents = {}, -- 71
		eventSeq = eventSeq, -- 72
		roomSessionId = roomSessionId, -- 73
		checkpoint = checkpoint, -- 74
		eventSummary = {} -- 75
	} -- 75
end -- 45
____exports.PlayAdapter = __TS__Class() -- 88
local PlayAdapter = ____exports.PlayAdapter -- 88
PlayAdapter.name = "PlayAdapter" -- 88
function PlayAdapter.prototype.____constructor(self) -- 88
	self.prevRoomKey = "" -- 89
	self.prevPhase = "" -- 90
	self.prevHp = 3 -- 91
	self.prevCoveredFlash = 0 -- 93
	self.prevRollT = 0 -- 94
	self.prevCalmTick = 0 -- 95
	self.prevKnocks = 0 -- 96
	self.prevBottleLandT = 0 -- 97
	self.prevCartDocked = false -- 98
	self.prevCheckpoint = -1 -- 99
	self.prevCaughtT = 0 -- 100
	self.prevGateSpawned = 0 -- 101
	self.prevAliveMask = {} -- 102
	self.roomSessionId = 0 -- 103
	self.eventSeq = 0 -- 104
end -- 88
function PlayAdapter.prototype.getRoomSessionId(self) -- 106
	return self.roomSessionId -- 107
end -- 106
function PlayAdapter.prototype.getEventSeq(self) -- 110
	return self.eventSeq -- 111
end -- 110
function PlayAdapter.prototype.emptyFrame(self, p) -- 114
	return ____exports.createEmptyFrameEvents(self.roomSessionId, self.eventSeq, p ~= nil and p.checkpoint or -1) -- 115
end -- 114
function PlayAdapter.prototype.reset(self, p) -- 122
	self.roomSessionId = self.roomSessionId + 1 -- 123
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 124
	self.prevPhase = p ~= nil and p.phase or "" -- 125
	self.prevHp = p ~= nil and p.hp or 3 -- 126
	self.prevTrace = nil -- 127
	self.prevCoveredFlash = 0 -- 128
	self.prevRollT = 0 -- 129
	self.prevCalmTick = 0 -- 130
	self.prevKnocks = 0 -- 131
	self.prevBottleLandT = 0 -- 132
	local ____temp_0 -- 133
	if p ~= nil then -- 133
		____temp_0 = p.cartDocked -- 133
	else -- 133
		____temp_0 = false -- 133
	end -- 133
	self.prevCartDocked = ____temp_0 -- 133
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 134
	self.prevCaughtT = 0 -- 135
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 136
	self.prevAliveMask = {} -- 137
	if p ~= nil then -- 137
		local i = 0 -- 139
		do -- 139
			i = 0 -- 140
			while i < #p.enemies do -- 140
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 140
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 141
				i = i + 1 -- 140
			end -- 140
		end -- 140
	end -- 140
end -- 122
function PlayAdapter.prototype.sample(self, p) -- 147
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 148
	if roomChanged then -- 148
		self:reset(p) -- 150
	end -- 150
	local rawEvents = p:drainEvents() -- 153
	if #rawEvents > 1 then -- 153
		__TS__ArraySort( -- 156
			rawEvents, -- 156
			function(____, a, b) return a.seq ~= b.seq and a.seq - b.seq or a.tick - b.tick end -- 156
		) -- 156
	end -- 156
	local eventSummary = {} -- 158
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 159
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 160
	local enemyKilledX = -9999 -- 161
	local enemyKilledY = 0 -- 162
	local i = 0 -- 163
	do -- 163
		i = 0 -- 164
		while i < #p.enemies do -- 164
			local ____temp_2 -- 165
			if i < #self.prevAliveMask then -- 165
				____temp_2 = self.prevAliveMask[i + 1] -- 165
			else -- 165
				____temp_2 = true -- 165
			end -- 165
			local wasAlive = ____temp_2 -- 165
			if wasAlive and not p.enemies[i + 1].alive then -- 165
				enemyKilledX = p.enemies[i + 1].x -- 167
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) + p.enemies[i + 1].h * 0.55 -- 168
			end -- 168
			i = i + 1 -- 164
		end -- 164
	end -- 164
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 172
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 173
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 174
	local knockPulse = false -- 177
	local knockX = p.player.x -- 178
	local knockY = p.player.y + p.player.depth + p.player.h * 0.5 -- 179
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 181
	local bottleLandX = p.bottleLandX -- 182
	local bottleLandY = p.bottleLandY -- 183
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 184
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 185
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 186
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 187
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 188
	local migratedRoomChange = false -- 189
	for ____, event in ipairs(rawEvents) do -- 190
		self.eventSeq = self.eventSeq + 1 -- 191
		eventSummary[#eventSummary + 1] = (((tostring(event.seq) .. "@") .. tostring(event.tick)) .. ":") .. event.name -- 192
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
		end -- 214
	end -- 214
	self.prevRoomKey = p.room.key -- 219
	self.prevPhase = p.phase -- 220
	self.prevHp = p.hp -- 221
	self.prevTrace = p.trace -- 222
	self.prevCoveredFlash = p.coveredFlash -- 223
	self.prevRollT = p.player.rollT -- 224
	self.prevCalmTick = p.escort.calmTick -- 225
	self.prevKnocks = p.knocks -- 226
	self.prevBottleLandT = p.bottleLandT -- 227
	self.prevCartDocked = p.cartDocked -- 228
	self.prevCheckpoint = p.checkpoint -- 229
	self.prevCaughtT = p.caughtT -- 230
	self.prevGateSpawned = p.gateSpawned -- 231
	self.prevAliveMask = {} -- 232
	do -- 232
		i = 0 -- 233
		while i < #p.enemies do -- 233
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 233
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 234
			i = i + 1 -- 233
		end -- 233
	end -- 233
	local ____shotFired_5 = shotFired -- 238
	local ____shotHit_6 = shotHit -- 239
	local ____shotFired_4 -- 240
	if shotFired then -- 240
		____shotFired_4 = p.trace -- 240
	else -- 240
		____shotFired_4 = nil -- 240
	end -- 240
	return { -- 237
		shotFired = ____shotFired_5, -- 238
		shotHit = ____shotHit_6, -- 239
		shotTrace = ____shotFired_4, -- 240
		enemyKilledX = enemyKilledX, -- 241
		enemyKilledY = enemyKilledY, -- 242
		playerHit = playerHit, -- 243
		coverDeflect = coverDeflect, -- 244
		rollStarted = rollStarted, -- 245
		knockPulse = knockPulse, -- 246
		knockX = knockX, -- 247
		knockY = knockY, -- 248
		bottleLanded = bottleLanded, -- 249
		bottleLandX = bottleLandX, -- 250
		bottleLandY = bottleLandY, -- 251
		cartJustDocked = cartJustDocked, -- 252
		checkpointJustHit = checkpointJustHit, -- 253
		caughtTriggered = caughtTriggered, -- 254
		phaseChanged = phaseChanged, -- 255
		roomChanged = roomChanged or migratedRoomChange, -- 256
		gateWaveSpawned = gateWaveSpawned, -- 257
		rawEvents = rawEvents, -- 258
		eventSeq = self.eventSeq, -- 259
		roomSessionId = self.roomSessionId, -- 260
		checkpoint = p.checkpoint, -- 261
		eventSummary = eventSummary -- 262
	} -- 262
end -- 147
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 268
	local room = p.room -- 269
	local player = p.player -- 270
	if p.paused or not player.alive then -- 270
		return nil -- 272
	end -- 272
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 272
		local ____opt_9 = room.story -- 272
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 272
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 276
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 276
			return { -- 278
				x = p.partner.x, -- 278
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 278
				keyTag = "E", -- 278
				label = "递出指南针", -- 278
				urgent = false -- 278
			} -- 278
		end -- 278
		return nil -- 280
	end -- 280
	if not p.childMode and p.escort.state == "frozen" then -- 280
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 280
			return { -- 285
				x = p.partner.x, -- 285
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 285
				keyTag = "E", -- 285
				label = "安抚小满", -- 285
				urgent = true -- 285
			} -- 285
		end -- 285
		return nil -- 287
	end -- 287
	local ____opt_11 = room.story -- 287
	local gate = ____opt_11 and ____opt_11.gate -- 290
	if gate ~= nil then -- 290
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 290
			return { -- 295
				x = gate.winchX, -- 295
				y = 84, -- 295
				keyTag = "E", -- 295
				label = "重新守门", -- 295
				urgent = true -- 295
			} -- 295
		end -- 295
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 295
			return { -- 298
				x = gate.doorX, -- 298
				y = 98, -- 298
				keyTag = "E", -- 298
				label = "送小满出城", -- 298
				urgent = true -- 298
			} -- 298
		end -- 298
	end -- 298
	local cart = room.cart -- 302
	if (room.key == "checkpoint" or room.key == "outside") and not p.cartDocked and cart.bodyW > 0 then -- 302
		local handleX = p.cartAxle + cart.handleOffset -- 304
		if p.gripping or p:cartHandleInReach() then -- 304
			return { -- 306
				x = handleX, -- 307
				y = cart.baseY + (cart.depth or 0) + cart.wheelR + cart.bodyH + 46, -- 308
				keyTag = "按住 E + D", -- 309
				label = room.key == "checkpoint" and "向前推车" or "向前拉车", -- 310
				urgent = false -- 311
			} -- 311
		end -- 311
	end -- 311
	if room.key == "village" and p.scavChase then -- 311
		local ____player_crouch_13 -- 317
		if player.crouch then -- 317
			____player_crouch_13 = nil -- 317
		else -- 317
			____player_crouch_13 = { -- 317
				x = player.x, -- 318
				y = player.y + player.h + 22, -- 318
				keyTag = "按住 Ctrl", -- 318
				label = "蹲下躲避", -- 318
				urgent = true -- 318
			} -- 318
		end -- 318
		return ____player_crouch_13 -- 317
	end -- 317
	if room.key == "village" and not p.passed then -- 317
		local bottle = room.bottle -- 323
		if p.hasBottle then -- 323
			return { -- 325
				x = player.x, -- 326
				y = player.y + player.h + 26, -- 326
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 327
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 328
				urgent = false -- 328
			} -- 328
		end -- 328
		if p.bottleFly == nil and bottle ~= nil then -- 328
			local dx = player.x - bottle.x -- 332
			local dy = player.y + player.h * 0.5 - bottle.y -- 333
			if dx * dx + dy * dy < 56 * 56 then -- 333
				return { -- 335
					x = bottle.x, -- 335
					y = bottle.y + 36, -- 335
					keyTag = "E", -- 335
					label = "拾起瓶子", -- 335
					urgent = false -- 335
				} -- 335
			end -- 335
		end -- 335
	end -- 335
	local arch = room.arch -- 340
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 340
		return { -- 344
			x = (arch.x0 + arch.x1) * 0.5, -- 345
			y = arch.y + arch.h + 44, -- 345
			keyTag = "按住 Ctrl", -- 346
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 346
			urgent = false -- 346
		} -- 346
	end -- 346
	local ____opt_14 = room.story -- 346
	local tower = ____opt_14 and ____opt_14.tower -- 350
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 350
		return { -- 352
			x = tower.doorX, -- 352
			y = 96, -- 352
			keyTag = "E", -- 352
			label = "敲门", -- 352
			urgent = false -- 352
		} -- 352
	end -- 352
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 352
		return { -- 357
			x = player.x, -- 358
			y = player.y + player.depth + player.h + 25, -- 358
			keyTag = "按住 Shift", -- 359
			label = "贴靠掩体", -- 359
			urgent = gate ~= nil -- 359
		} -- 359
	end -- 359
	return nil -- 362
end -- 268
return ____exports -- 268