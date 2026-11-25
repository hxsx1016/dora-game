-- [ts]: adapter.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____escort = require("Script.watch.escort") -- 9
local CALM_REACH = ____escort.CALM_REACH -- 9
local ____depth = require("Script.watch.depth") -- 10
local inReachDepth = ____depth.inReachDepth -- 10
____exports.PlayAdapter = __TS__Class() -- 44
local PlayAdapter = ____exports.PlayAdapter -- 44
PlayAdapter.name = "PlayAdapter" -- 44
function PlayAdapter.prototype.____constructor(self) -- 44
	self.prevRoomKey = "" -- 45
	self.prevPhase = "" -- 46
	self.prevHp = 3 -- 47
	self.prevCoveredFlash = 0 -- 49
	self.prevRollT = 0 -- 50
	self.prevCalmTick = 0 -- 51
	self.prevKnocks = 0 -- 52
	self.prevBottleLandT = 0 -- 53
	self.prevCartDocked = false -- 54
	self.prevCheckpoint = -1 -- 55
	self.prevCaughtT = 0 -- 56
	self.prevGateSpawned = 0 -- 57
	self.prevAliveMask = {} -- 58
end -- 44
function PlayAdapter.prototype.reset(self, p) -- 60
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 61
	self.prevPhase = p ~= nil and p.phase or "" -- 62
	self.prevHp = p ~= nil and p.hp or 3 -- 63
	self.prevTrace = nil -- 64
	self.prevCoveredFlash = 0 -- 65
	self.prevRollT = 0 -- 66
	self.prevCalmTick = 0 -- 67
	self.prevKnocks = 0 -- 68
	self.prevBottleLandT = 0 -- 69
	local ____temp_0 -- 70
	if p ~= nil then -- 70
		____temp_0 = p.cartDocked -- 70
	else -- 70
		____temp_0 = false -- 70
	end -- 70
	self.prevCartDocked = ____temp_0 -- 70
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 71
	self.prevCaughtT = 0 -- 72
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 73
	self.prevAliveMask = {} -- 74
	if p ~= nil then -- 74
		local i = 0 -- 76
		do -- 76
			i = 0 -- 77
			while i < #p.enemies do -- 77
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 77
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 78
				i = i + 1 -- 77
			end -- 77
		end -- 77
	end -- 77
end -- 60
function PlayAdapter.prototype.sample(self, p) -- 84
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 85
	if roomChanged then -- 85
		self:reset(p) -- 87
	end -- 87
	local events = p:drainEvents() -- 90
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 91
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 92
	local enemyKilledX = -9999 -- 93
	local enemyKilledY = 0 -- 94
	local i = 0 -- 95
	do -- 95
		i = 0 -- 96
		while i < #p.enemies do -- 96
			local ____temp_2 -- 97
			if i < #self.prevAliveMask then -- 97
				____temp_2 = self.prevAliveMask[i + 1] -- 97
			else -- 97
				____temp_2 = true -- 97
			end -- 97
			local wasAlive = ____temp_2 -- 97
			if wasAlive and not p.enemies[i + 1].alive then -- 97
				enemyKilledX = p.enemies[i + 1].x -- 99
				enemyKilledY = p.enemies[i + 1].y + (p.enemies[i + 1].depth or 0) + p.enemies[i + 1].h * 0.55 -- 100
			end -- 100
			i = i + 1 -- 96
		end -- 96
	end -- 96
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 104
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 105
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 106
	local knockPulse = false -- 109
	local knockX = p.player.x -- 110
	local knockY = p.player.y + p.player.depth + p.player.h * 0.5 -- 111
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 113
	local bottleLandX = p.bottleLandX -- 114
	local bottleLandY = p.bottleLandY -- 115
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 116
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 117
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 118
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 119
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 120
	local migratedRoomChange = false -- 121
	for ____, event in ipairs(events) do -- 122
		if event.name == "knock" then -- 122
			knockPulse = true -- 124
			local x = event.data.x -- 125
			knockX = type(x) == "number" and x or p.player.x -- 126
			knockY = p.escort.state == "calming" and p.partner.y + p.partner.depth + 28 or p.player.y + p.player.depth + p.player.h * 0.55 -- 127
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 127
			playerHit = true -- 130
		elseif event.name == "coverBlocked" then -- 130
			coverDeflect = true -- 132
		elseif event.name == "bottleLanded" then -- 132
			bottleLanded = true -- 134
			if type(event.data.x) == "number" then -- 134
				bottleLandX = event.data.x -- 136
			end -- 136
			if type(event.data.y) == "number" then -- 136
				bottleLandY = event.data.y -- 139
			end -- 139
		elseif event.name == "cartDocked" then -- 139
			cartJustDocked = true -- 142
		elseif event.name == "roomChange" then -- 142
			migratedRoomChange = true -- 144
		end -- 144
	end -- 144
	self.prevRoomKey = p.room.key -- 149
	self.prevPhase = p.phase -- 150
	self.prevHp = p.hp -- 151
	self.prevTrace = p.trace -- 152
	self.prevCoveredFlash = p.coveredFlash -- 153
	self.prevRollT = p.player.rollT -- 154
	self.prevCalmTick = p.escort.calmTick -- 155
	self.prevKnocks = p.knocks -- 156
	self.prevBottleLandT = p.bottleLandT -- 157
	self.prevCartDocked = p.cartDocked -- 158
	self.prevCheckpoint = p.checkpoint -- 159
	self.prevCaughtT = p.caughtT -- 160
	self.prevGateSpawned = p.gateSpawned -- 161
	self.prevAliveMask = {} -- 162
	do -- 162
		i = 0 -- 163
		while i < #p.enemies do -- 163
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 163
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 164
			i = i + 1 -- 163
		end -- 163
	end -- 163
	local ____shotFired_5 = shotFired -- 168
	local ____shotHit_6 = shotHit -- 169
	local ____shotFired_4 -- 170
	if shotFired then -- 170
		____shotFired_4 = p.trace -- 170
	else -- 170
		____shotFired_4 = nil -- 170
	end -- 170
	return { -- 167
		shotFired = ____shotFired_5, -- 168
		shotHit = ____shotHit_6, -- 169
		shotTrace = ____shotFired_4, -- 170
		enemyKilledX = enemyKilledX, -- 171
		enemyKilledY = enemyKilledY, -- 172
		playerHit = playerHit, -- 173
		coverDeflect = coverDeflect, -- 174
		rollStarted = rollStarted, -- 175
		knockPulse = knockPulse, -- 176
		knockX = knockX, -- 177
		knockY = knockY, -- 178
		bottleLanded = bottleLanded, -- 179
		bottleLandX = bottleLandX, -- 180
		bottleLandY = bottleLandY, -- 181
		cartJustDocked = cartJustDocked, -- 182
		checkpointJustHit = checkpointJustHit, -- 183
		caughtTriggered = caughtTriggered, -- 184
		phaseChanged = phaseChanged, -- 185
		roomChanged = roomChanged or migratedRoomChange, -- 186
		gateWaveSpawned = gateWaveSpawned -- 187
	} -- 187
end -- 84
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 193
	local room = p.room -- 194
	local player = p.player -- 195
	if p.paused or not player.alive then -- 195
		return nil -- 197
	end -- 197
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 197
		local ____opt_9 = room.story -- 197
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 197
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 201
		if math.abs(player.x - p.partner.x) <= reach and inReachDepth(player.depth, p.partner.depth) then -- 201
			return { -- 203
				x = p.partner.x, -- 203
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 203
				keyTag = "E", -- 203
				label = "递出指南针", -- 203
				urgent = false -- 203
			} -- 203
		end -- 203
		return nil -- 205
	end -- 205
	if not p.childMode and p.escort.state == "frozen" then -- 205
		if math.abs(player.x - p.partner.x) <= CALM_REACH and inReachDepth(player.depth, p.partner.depth) then -- 205
			return { -- 210
				x = p.partner.x, -- 210
				y = p.partner.y + p.partner.depth + p.partner.h + 22, -- 210
				keyTag = "E", -- 210
				label = "安抚小满", -- 210
				urgent = true -- 210
			} -- 210
		end -- 210
		return nil -- 212
	end -- 212
	local ____opt_11 = room.story -- 212
	local gate = ____opt_11 and ____opt_11.gate -- 215
	if gate ~= nil then -- 215
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and inReachDepth(player.depth) and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 215
			return { -- 220
				x = gate.winchX, -- 220
				y = 84, -- 220
				keyTag = "E", -- 220
				label = "重新守门", -- 220
				urgent = true -- 220
			} -- 220
		end -- 220
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 and inReachDepth(player.depth) then -- 220
			return { -- 223
				x = gate.doorX, -- 223
				y = 98, -- 223
				keyTag = "E", -- 223
				label = "送小满出城", -- 223
				urgent = true -- 223
			} -- 223
		end -- 223
	end -- 223
	local cart = room.cart -- 227
	if (room.key == "checkpoint" or room.key == "outside") and not p.cartDocked and cart.bodyW > 0 then -- 227
		local handleX = p.cartAxle + cart.handleOffset -- 229
		if p.gripping or p:cartHandleInReach() then -- 229
			return { -- 231
				x = handleX, -- 232
				y = cart.baseY + (cart.depth or 0) + cart.wheelR + cart.bodyH + 46, -- 233
				keyTag = "按住 E + D", -- 234
				label = room.key == "checkpoint" and "向前推车" or "向前拉车", -- 235
				urgent = false -- 236
			} -- 236
		end -- 236
	end -- 236
	if room.key == "village" and p.scavChase then -- 236
		local ____player_crouch_13 -- 242
		if player.crouch then -- 242
			____player_crouch_13 = nil -- 242
		else -- 242
			____player_crouch_13 = { -- 242
				x = player.x, -- 243
				y = player.y + player.h + 22, -- 243
				keyTag = "按住 Ctrl", -- 243
				label = "蹲下躲避", -- 243
				urgent = true -- 243
			} -- 243
		end -- 243
		return ____player_crouch_13 -- 242
	end -- 242
	if room.key == "village" and not p.passed then -- 242
		local bottle = room.bottle -- 248
		if p.hasBottle then -- 248
			return { -- 250
				x = player.x, -- 251
				y = player.y + player.h + 26, -- 251
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 252
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 253
				urgent = false -- 253
			} -- 253
		end -- 253
		if p.bottleFly == nil and bottle ~= nil then -- 253
			local dx = player.x - bottle.x -- 257
			local dy = player.y + player.h * 0.5 - bottle.y -- 258
			if dx * dx + dy * dy < 56 * 56 then -- 258
				return { -- 260
					x = bottle.x, -- 260
					y = bottle.y + 36, -- 260
					keyTag = "E", -- 260
					label = "拾起瓶子", -- 260
					urgent = false -- 260
				} -- 260
			end -- 260
		end -- 260
	end -- 260
	local arch = room.arch -- 265
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 265
		return { -- 269
			x = (arch.x0 + arch.x1) * 0.5, -- 270
			y = arch.y + arch.h + 44, -- 270
			keyTag = "按住 Ctrl", -- 271
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 271
			urgent = false -- 271
		} -- 271
	end -- 271
	local ____opt_14 = room.story -- 271
	local tower = ____opt_14 and ____opt_14.tower -- 275
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 275
		return { -- 277
			x = tower.doorX, -- 277
			y = 96, -- 277
			keyTag = "E", -- 277
			label = "敲门", -- 277
			urgent = false -- 277
		} -- 277
	end -- 277
	if room.key ~= "prologue" and not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 277
		return { -- 282
			x = player.x, -- 283
			y = player.y + player.depth + player.h + 25, -- 283
			keyTag = "按住 Shift", -- 284
			label = "贴靠掩体", -- 284
			urgent = gate ~= nil -- 284
		} -- 284
	end -- 284
	return nil -- 287
end -- 193
return ____exports -- 193