-- [ts]: adapter.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____play = require("Script.watch.play") -- 8
local CART_REACH = ____play.CART_REACH -- 8
local ____escort = require("Script.watch.escort") -- 9
local CALM_REACH = ____escort.CALM_REACH -- 9
____exports.PlayAdapter = __TS__Class() -- 41
local PlayAdapter = ____exports.PlayAdapter -- 41
PlayAdapter.name = "PlayAdapter" -- 41
function PlayAdapter.prototype.____constructor(self) -- 41
	self.prevRoomKey = "" -- 42
	self.prevPhase = "" -- 43
	self.prevHp = 3 -- 44
	self.prevCoveredFlash = 0 -- 46
	self.prevRollT = 0 -- 47
	self.prevCalmTick = 0 -- 48
	self.prevKnocks = 0 -- 49
	self.prevBottleLandT = 0 -- 50
	self.prevCartDocked = false -- 51
	self.prevCheckpoint = -1 -- 52
	self.prevCaughtT = 0 -- 53
	self.prevGateSpawned = 0 -- 54
	self.prevAliveMask = {} -- 55
end -- 41
function PlayAdapter.prototype.reset(self, p) -- 57
	self.prevRoomKey = p ~= nil and p.room.key or "" -- 58
	self.prevPhase = p ~= nil and p.phase or "" -- 59
	self.prevHp = p ~= nil and p.hp or 3 -- 60
	self.prevTrace = nil -- 61
	self.prevCoveredFlash = 0 -- 62
	self.prevRollT = 0 -- 63
	self.prevCalmTick = 0 -- 64
	self.prevKnocks = 0 -- 65
	self.prevBottleLandT = 0 -- 66
	local ____temp_0 -- 67
	if p ~= nil then -- 67
		____temp_0 = p.cartDocked -- 67
	else -- 67
		____temp_0 = false -- 67
	end -- 67
	self.prevCartDocked = ____temp_0 -- 67
	self.prevCheckpoint = p ~= nil and p.checkpoint or -1 -- 68
	self.prevCaughtT = 0 -- 69
	self.prevGateSpawned = p ~= nil and p.gateSpawned or 0 -- 70
	self.prevAliveMask = {} -- 71
	if p ~= nil then -- 71
		local i = 0 -- 73
		do -- 73
			i = 0 -- 74
			while i < #p.enemies do -- 74
				local ____self_prevAliveMask_1 = self.prevAliveMask -- 74
				____self_prevAliveMask_1[#____self_prevAliveMask_1 + 1] = p.enemies[i + 1].alive -- 75
				i = i + 1 -- 74
			end -- 74
		end -- 74
	end -- 74
end -- 57
function PlayAdapter.prototype.sample(self, p) -- 81
	local roomChanged = self.prevRoomKey ~= "" and self.prevRoomKey ~= p.room.key -- 82
	if roomChanged then -- 82
		self:reset(p) -- 84
	end -- 84
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 87
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 88
	local enemyKilledX = -9999 -- 89
	local enemyKilledY = 0 -- 90
	local i = 0 -- 91
	do -- 91
		i = 0 -- 92
		while i < #p.enemies do -- 92
			local ____temp_2 -- 93
			if i < #self.prevAliveMask then -- 93
				____temp_2 = self.prevAliveMask[i + 1] -- 93
			else -- 93
				____temp_2 = true -- 93
			end -- 93
			local wasAlive = ____temp_2 -- 93
			if wasAlive and not p.enemies[i + 1].alive then -- 93
				enemyKilledX = p.enemies[i + 1].x -- 95
				enemyKilledY = p.enemies[i + 1].y + p.enemies[i + 1].h * 0.55 -- 96
			end -- 96
			i = i + 1 -- 92
		end -- 92
	end -- 92
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 100
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 101
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 102
	local knockPulse = false -- 105
	local knockX = p.player.x -- 106
	local knockY = p.player.y + p.player.h * 0.5 -- 107
	if p.escort.state == "calming" then -- 107
		if self.prevCalmTick < 12 and p.escort.calmTick >= 12 or self.prevCalmTick < 36 and p.escort.calmTick >= 36 then -- 107
			knockPulse = true -- 110
			knockX = (p.player.x + p.partner.x) * 0.5 -- 111
			knockY = p.partner.y + 28 -- 112
		end -- 112
	end -- 112
	if p.knocks ~= self.prevKnocks and p.knocks > 0 then -- 112
		knockPulse = true -- 116
		knockX = p.player.x + p.player.facing * 12 -- 117
		knockY = p.player.y + p.player.h * 0.55 -- 118
	end -- 118
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 121
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 122
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 123
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 124
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 125
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 126
	self.prevRoomKey = p.room.key -- 129
	self.prevPhase = p.phase -- 130
	self.prevHp = p.hp -- 131
	self.prevTrace = p.trace -- 132
	self.prevCoveredFlash = p.coveredFlash -- 133
	self.prevRollT = p.player.rollT -- 134
	self.prevCalmTick = p.escort.calmTick -- 135
	self.prevKnocks = p.knocks -- 136
	self.prevBottleLandT = p.bottleLandT -- 137
	self.prevCartDocked = p.cartDocked -- 138
	self.prevCheckpoint = p.checkpoint -- 139
	self.prevCaughtT = p.caughtT -- 140
	self.prevGateSpawned = p.gateSpawned -- 141
	self.prevAliveMask = {} -- 142
	do -- 142
		i = 0 -- 143
		while i < #p.enemies do -- 143
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 143
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 144
			i = i + 1 -- 143
		end -- 143
	end -- 143
	local ____shotFired_5 = shotFired -- 148
	local ____shotHit_6 = shotHit -- 149
	local ____shotFired_4 -- 150
	if shotFired then -- 150
		____shotFired_4 = p.trace -- 150
	else -- 150
		____shotFired_4 = nil -- 150
	end -- 150
	return { -- 147
		shotFired = ____shotFired_5, -- 148
		shotHit = ____shotHit_6, -- 149
		shotTrace = ____shotFired_4, -- 150
		enemyKilledX = enemyKilledX, -- 151
		enemyKilledY = enemyKilledY, -- 152
		playerHit = playerHit, -- 153
		coverDeflect = coverDeflect, -- 154
		rollStarted = rollStarted, -- 155
		knockPulse = knockPulse, -- 156
		knockX = knockX, -- 157
		knockY = knockY, -- 158
		bottleLanded = bottleLanded, -- 159
		bottleLandX = p.bottleLandX, -- 160
		cartJustDocked = cartJustDocked, -- 161
		checkpointJustHit = checkpointJustHit, -- 162
		caughtTriggered = caughtTriggered, -- 163
		phaseChanged = phaseChanged, -- 164
		roomChanged = roomChanged, -- 165
		gateWaveSpawned = gateWaveSpawned -- 166
	} -- 166
end -- 81
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 172
	local room = p.room -- 173
	local player = p.player -- 174
	if p.paused or not player.alive then -- 174
		return nil -- 176
	end -- 176
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 176
		local ____opt_9 = room.story -- 176
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 176
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 180
		if math.abs(player.x - p.partner.x) <= reach then -- 180
			return { -- 182
				x = p.partner.x, -- 182
				y = p.partner.y + p.partner.h + 22, -- 182
				keyTag = "E", -- 182
				label = "递出指南针", -- 182
				urgent = false -- 182
			} -- 182
		end -- 182
		return nil -- 184
	end -- 184
	if not p.childMode and p.escort.state == "frozen" then -- 184
		if math.abs(player.x - p.partner.x) <= CALM_REACH then -- 184
			return { -- 189
				x = p.partner.x, -- 189
				y = p.partner.y + p.partner.h + 22, -- 189
				keyTag = "E", -- 189
				label = "安抚小满", -- 189
				urgent = true -- 189
			} -- 189
		end -- 189
		return nil -- 191
	end -- 191
	local ____opt_11 = room.story -- 191
	local gate = ____opt_11 and ____opt_11.gate -- 194
	if gate ~= nil then -- 194
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 194
			return { -- 199
				x = gate.winchX, -- 199
				y = 84, -- 199
				keyTag = "E", -- 199
				label = "重新守门", -- 199
				urgent = true -- 199
			} -- 199
		end -- 199
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 then -- 199
			return { -- 202
				x = gate.doorX, -- 202
				y = 98, -- 202
				keyTag = "E", -- 202
				label = "送小满出城", -- 202
				urgent = true -- 202
			} -- 202
		end -- 202
	end -- 202
	local cart = room.cart -- 206
	if (room.key == "checkpoint" or room.key == "outside") and not p.cartDocked and cart.bodyW > 0 then -- 206
		local handleX = p.cartAxle + cart.handleOffset -- 208
		if p.gripping or math.abs(player.x - handleX) <= CART_REACH and math.abs(player.y - cart.baseY) <= 40 then -- 208
			return { -- 210
				x = handleX, -- 211
				y = cart.baseY + cart.wheelR + cart.bodyH + 46, -- 212
				keyTag = "按住 E + D", -- 213
				label = room.key == "checkpoint" and "向前推车" or "向前拉车", -- 214
				urgent = false -- 215
			} -- 215
		end -- 215
	end -- 215
	if room.key == "village" and p.scavChase then -- 215
		local ____player_crouch_13 -- 221
		if player.crouch then -- 221
			____player_crouch_13 = nil -- 221
		else -- 221
			____player_crouch_13 = { -- 221
				x = player.x, -- 222
				y = player.y + player.h + 22, -- 222
				keyTag = "按住 Ctrl", -- 222
				label = "蹲下躲避", -- 222
				urgent = true -- 222
			} -- 222
		end -- 222
		return ____player_crouch_13 -- 221
	end -- 221
	if room.key == "village" and not p.passed then -- 221
		local bottle = room.bottle -- 227
		if p.hasBottle then -- 227
			return { -- 229
				x = player.x, -- 230
				y = player.y + player.h + 26, -- 230
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 231
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 232
				urgent = false -- 232
			} -- 232
		end -- 232
		if p.bottleFly == nil and bottle ~= nil then -- 232
			local dx = player.x - bottle.x -- 236
			local dy = player.y + player.h * 0.5 - bottle.y -- 237
			if dx * dx + dy * dy < 56 * 56 then -- 237
				return { -- 239
					x = bottle.x, -- 239
					y = bottle.y + 36, -- 239
					keyTag = "E", -- 239
					label = "拾起瓶子", -- 239
					urgent = false -- 239
				} -- 239
			end -- 239
		end -- 239
	end -- 239
	local arch = room.arch -- 244
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 244
		return { -- 248
			x = (arch.x0 + arch.x1) * 0.5, -- 249
			y = arch.y + arch.h + 44, -- 249
			keyTag = "按住 Ctrl", -- 250
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 250
			urgent = false -- 250
		} -- 250
	end -- 250
	local ____opt_14 = room.story -- 250
	local tower = ____opt_14 and ____opt_14.tower -- 254
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 254
		return { -- 256
			x = tower.doorX, -- 256
			y = 96, -- 256
			keyTag = "E", -- 256
			label = "敲门", -- 256
			urgent = false -- 256
		} -- 256
	end -- 256
	if not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 256
		return { -- 261
			x = player.x, -- 262
			y = player.y + player.h + 25, -- 262
			keyTag = "按住 Shift", -- 263
			label = "贴靠掩体", -- 263
			urgent = gate ~= nil -- 263
		} -- 263
	end -- 263
	return nil -- 266
end -- 172
return ____exports -- 172