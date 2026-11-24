-- [ts]: adapter.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____play = require("Script.watch.play") -- 8
local CART_REACH = ____play.CART_REACH -- 8
local ____escort = require("Script.watch.escort") -- 9
local CALM_REACH = ____escort.CALM_REACH -- 9
____exports.PlayAdapter = __TS__Class() -- 42
local PlayAdapter = ____exports.PlayAdapter -- 42
PlayAdapter.name = "PlayAdapter" -- 42
function PlayAdapter.prototype.____constructor(self) -- 42
	self.prevRoomKey = "" -- 43
	self.prevPhase = "" -- 44
	self.prevHp = 3 -- 45
	self.prevCoveredFlash = 0 -- 47
	self.prevRollT = 0 -- 48
	self.prevCalmTick = 0 -- 49
	self.prevKnocks = 0 -- 50
	self.prevBottleLandT = 0 -- 51
	self.prevCartDocked = false -- 52
	self.prevCheckpoint = -1 -- 53
	self.prevCaughtT = 0 -- 54
	self.prevGateSpawned = 0 -- 55
	self.prevAliveMask = {} -- 56
end -- 42
function PlayAdapter.prototype.reset(self, p) -- 58
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 59
	self.prevPhase = p ~= nil and p.phase or "" -- 60
	self.prevHp = p ~= nil and p.hp or 3 -- 61
	self.prevTrace = nil -- 62
	self.prevCoveredFlash = 0 -- 63
	self.prevRollT = 0 -- 64
	self.prevCalmTick = 0 -- 65
	self.prevKnocks = 0 -- 66
	self.prevBottleLandT = 0 -- 67
	local ____temp_0 -- 68
	if p ~= nil then -- 68
		____temp_0 = p.cartDocked -- 68
	else -- 68
		____temp_0 = false -- 68
	end -- 68
	self.prevCartDocked = ____temp_0 -- 68
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 69
	self.prevCaughtT = 0 -- 70
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 71
	self.prevAliveMask = {} -- 72
	if p ~= nil then -- 72
		local i = 0 -- 74
		do -- 74
			i = 0 -- 75
			while i < #p.enemies do -- 75
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 75
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 76
				i = i + 1 -- 75
			end -- 75
		end -- 75
	end -- 75
end -- 58
function PlayAdapter.prototype.sample(self, p) -- 82
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 83
	if roomChanged then -- 83
		self:reset(p) -- 85
	end -- 85
	local events = p:drainEvents() -- 88
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 89
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 90
	local enemyKilledX = -9999 -- 91
	local enemyKilledY = 0 -- 92
	local i = 0 -- 93
	do -- 93
		i = 0 -- 94
		while i < #p.enemies do -- 94
			local ____temp_2 -- 95
			if i < #self.prevAliveMask then -- 95
				____temp_2 = self.prevAliveMask[i + 1] -- 95
			else -- 95
				____temp_2 = true -- 95
			end -- 95
			local wasAlive = ____temp_2 -- 95
			if wasAlive and not p.enemies[i + 1].alive then -- 95
				enemyKilledX = p.enemies[i + 1].x -- 97
				enemyKilledY = p.enemies[i + 1].y + p.enemies[i + 1].h * 0.55 -- 98
			end -- 98
			i = i + 1 -- 94
		end -- 94
	end -- 94
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 102
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 103
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 104
	local knockPulse = false -- 107
	local knockX = p.player.x -- 108
	local knockY = p.player.y + p.player.h * 0.5 -- 109
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 111
	local bottleLandX = p.bottleLandX -- 112
	local bottleLandY = p.bottleLandY -- 113
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 114
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 115
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 116
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 117
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 118
	local migratedRoomChange = false -- 119
	for ____, event in ipairs(events) do -- 120
		if event.name == "knock" then -- 120
			knockPulse = true -- 122
			local x = event.data.x -- 123
			knockX = type(x) == "number" and x or p.player.x -- 124
			knockY = p.escort.state == "calming" and p.partner.y + 28 or p.player.y + p.player.h * 0.55 -- 125
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 125
			playerHit = true -- 127
		elseif event.name == "coverBlocked" then -- 127
			coverDeflect = true -- 129
		elseif event.name == "bottleLanded" then -- 129
			bottleLanded = true -- 131
			if type(event.data.x) == "number" then -- 131
				bottleLandX = event.data.x -- 133
			end -- 133
			if type(event.data.y) == "number" then -- 133
				bottleLandY = event.data.y -- 136
			end -- 136
		elseif event.name == "cartDocked" then -- 136
			cartJustDocked = true -- 139
		elseif event.name == "roomChange" then -- 139
			migratedRoomChange = true -- 141
		end -- 141
	end -- 141
	self.prevRoomKey = p.room.key -- 146
	self.prevPhase = p.phase -- 147
	self.prevHp = p.hp -- 148
	self.prevTrace = p.trace -- 149
	self.prevCoveredFlash = p.coveredFlash -- 150
	self.prevRollT = p.player.rollT -- 151
	self.prevCalmTick = p.escort.calmTick -- 152
	self.prevKnocks = p.knocks -- 153
	self.prevBottleLandT = p.bottleLandT -- 154
	self.prevCartDocked = p.cartDocked -- 155
	self.prevCheckpoint = p.checkpoint -- 156
	self.prevCaughtT = p.caughtT -- 157
	self.prevGateSpawned = p.gateSpawned -- 158
	self.prevAliveMask = {} -- 159
	do -- 159
		i = 0 -- 160
		while i < #p.enemies do -- 160
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 160
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 161
			i = i + 1 -- 160
		end -- 160
	end -- 160
	local ____shotFired_5 = shotFired -- 165
	local ____shotHit_6 = shotHit -- 166
	local ____shotFired_4 -- 167
	if shotFired then -- 167
		____shotFired_4 = p.trace -- 167
	else -- 167
		____shotFired_4 = nil -- 167
	end -- 167
	return { -- 164
		shotFired = ____shotFired_5, -- 165
		shotHit = ____shotHit_6, -- 166
		shotTrace = ____shotFired_4, -- 167
		enemyKilledX = enemyKilledX, -- 168
		enemyKilledY = enemyKilledY, -- 169
		playerHit = playerHit, -- 170
		coverDeflect = coverDeflect, -- 171
		rollStarted = rollStarted, -- 172
		knockPulse = knockPulse, -- 173
		knockX = knockX, -- 174
		knockY = knockY, -- 175
		bottleLanded = bottleLanded, -- 176
		bottleLandX = bottleLandX, -- 177
		bottleLandY = bottleLandY, -- 178
		cartJustDocked = cartJustDocked, -- 179
		checkpointJustHit = checkpointJustHit, -- 180
		caughtTriggered = caughtTriggered, -- 181
		phaseChanged = phaseChanged, -- 182
		roomChanged = roomChanged or migratedRoomChange, -- 183
		gateWaveSpawned = gateWaveSpawned -- 184
	} -- 184
end -- 82
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 190
	local room = p.room -- 191
	local player = p.player -- 192
	if p.paused or not player.alive then -- 192
		return nil -- 194
	end -- 194
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 194
		local ____opt_9 = room.story -- 194
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 194
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 198
		if math.abs(player.x - p.partner.x) <= reach then -- 198
			return { -- 200
				x = p.partner.x, -- 200
				y = p.partner.y + p.partner.h + 22, -- 200
				keyTag = "E", -- 200
				label = "递出指南针", -- 200
				urgent = false -- 200
			} -- 200
		end -- 200
		return nil -- 202
	end -- 202
	if not p.childMode and p.escort.state == "frozen" then -- 202
		if math.abs(player.x - p.partner.x) <= CALM_REACH then -- 202
			return { -- 207
				x = p.partner.x, -- 207
				y = p.partner.y + p.partner.h + 22, -- 207
				keyTag = "E", -- 207
				label = "安抚小满", -- 207
				urgent = true -- 207
			} -- 207
		end -- 207
		return nil -- 209
	end -- 209
	local ____opt_11 = room.story -- 209
	local gate = ____opt_11 and ____opt_11.gate -- 212
	if gate ~= nil then -- 212
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 212
			return { -- 217
				x = gate.winchX, -- 217
				y = 84, -- 217
				keyTag = "E", -- 217
				label = "重新守门", -- 217
				urgent = true -- 217
			} -- 217
		end -- 217
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 then -- 217
			return { -- 220
				x = gate.doorX, -- 220
				y = 98, -- 220
				keyTag = "E", -- 220
				label = "送小满出城", -- 220
				urgent = true -- 220
			} -- 220
		end -- 220
	end -- 220
	local cart = room.cart -- 224
	if (room.key == "checkpoint" or room.key == "outside") and not p.cartDocked and cart.bodyW > 0 then -- 224
		local handleX = p.cartAxle + cart.handleOffset -- 226
		if p.gripping or math.abs(player.x - handleX) <= CART_REACH and math.abs(player.y - cart.baseY) <= 40 then -- 226
			return { -- 228
				x = handleX, -- 229
				y = cart.baseY + cart.wheelR + cart.bodyH + 46, -- 230
				keyTag = "按住 E + D", -- 231
				label = room.key == "checkpoint" and "向前推车" or "向前拉车", -- 232
				urgent = false -- 233
			} -- 233
		end -- 233
	end -- 233
	if room.key == "village" and p.scavChase then -- 233
		local ____player_crouch_13 -- 239
		if player.crouch then -- 239
			____player_crouch_13 = nil -- 239
		else -- 239
			____player_crouch_13 = { -- 239
				x = player.x, -- 240
				y = player.y + player.h + 22, -- 240
				keyTag = "按住 Ctrl", -- 240
				label = "蹲下躲避", -- 240
				urgent = true -- 240
			} -- 240
		end -- 240
		return ____player_crouch_13 -- 239
	end -- 239
	if room.key == "village" and not p.passed then -- 239
		local bottle = room.bottle -- 245
		if p.hasBottle then -- 245
			return { -- 247
				x = player.x, -- 248
				y = player.y + player.h + 26, -- 248
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 249
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 250
				urgent = false -- 250
			} -- 250
		end -- 250
		if p.bottleFly == nil and bottle ~= nil then -- 250
			local dx = player.x - bottle.x -- 254
			local dy = player.y + player.h * 0.5 - bottle.y -- 255
			if dx * dx + dy * dy < 56 * 56 then -- 255
				return { -- 257
					x = bottle.x, -- 257
					y = bottle.y + 36, -- 257
					keyTag = "E", -- 257
					label = "拾起瓶子", -- 257
					urgent = false -- 257
				} -- 257
			end -- 257
		end -- 257
	end -- 257
	local arch = room.arch -- 262
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 262
		return { -- 266
			x = (arch.x0 + arch.x1) * 0.5, -- 267
			y = arch.y + arch.h + 44, -- 267
			keyTag = "按住 Ctrl", -- 268
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 268
			urgent = false -- 268
		} -- 268
	end -- 268
	local ____opt_14 = room.story -- 268
	local tower = ____opt_14 and ____opt_14.tower -- 272
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 272
		return { -- 274
			x = tower.doorX, -- 274
			y = 96, -- 274
			keyTag = "E", -- 274
			label = "敲门", -- 274
			urgent = false -- 274
		} -- 274
	end -- 274
	if not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 274
		return { -- 279
			x = player.x, -- 280
			y = player.y + player.h + 25, -- 280
			keyTag = "按住 Shift", -- 281
			label = "贴靠掩体", -- 281
			urgent = gate ~= nil -- 281
		} -- 281
	end -- 281
	return nil -- 284
end -- 190
return ____exports -- 190