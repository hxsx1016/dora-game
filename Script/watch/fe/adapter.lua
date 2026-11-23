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
	local events = p:drainEvents() -- 87
	local shotFired = p.trace ~= nil and p.trace ~= self.prevTrace -- 88
	local shotHit = shotFired and p.trace ~= nil and p.trace.hit -- 89
	local enemyKilledX = -9999 -- 90
	local enemyKilledY = 0 -- 91
	local i = 0 -- 92
	do -- 92
		i = 0 -- 93
		while i < #p.enemies do -- 93
			local ____temp_2 -- 94
			if i < #self.prevAliveMask then -- 94
				____temp_2 = self.prevAliveMask[i + 1] -- 94
			else -- 94
				____temp_2 = true -- 94
			end -- 94
			local wasAlive = ____temp_2 -- 94
			if wasAlive and not p.enemies[i + 1].alive then -- 94
				enemyKilledX = p.enemies[i + 1].x -- 96
				enemyKilledY = p.enemies[i + 1].y + p.enemies[i + 1].h * 0.55 -- 97
			end -- 97
			i = i + 1 -- 93
		end -- 93
	end -- 93
	local playerHit = p.hp < self.prevHp or self.prevPhase == "gate-hold" and p.phase == "gate-idle" and p.gateNeedConfirm -- 101
	local coverDeflect = p.coveredFlash > self.prevCoveredFlash + 0.05 -- 102
	local rollStarted = p.player.rollT > 0 and self.prevRollT <= 0 -- 103
	local knockPulse = false -- 106
	local knockX = p.player.x -- 107
	local knockY = p.player.y + p.player.h * 0.5 -- 108
	local bottleLanded = p.bottleLandT > self.prevBottleLandT + 0.1 and p.bottleLandX >= 0 -- 110
	local cartJustDocked = p.cartDocked and not self.prevCartDocked -- 111
	local checkpointJustHit = p.checkpoint >= 0 and p.checkpoint ~= self.prevCheckpoint -- 112
	local caughtTriggered = p.caughtT > 0 and self.prevCaughtT <= 0 -- 113
	local phaseChanged = self.prevPhase ~= "" and self.prevPhase ~= p.phase -- 114
	local gateWaveSpawned = p.gateSpawned > self.prevGateSpawned -- 115
	local migratedRoomChange = false -- 116
	for ____, event in ipairs(events) do -- 117
		if event.name == "knock" then -- 117
			knockPulse = true -- 119
			local x = event.data.x -- 120
			knockX = type(x) == "number" and x or p.player.x -- 121
			knockY = p.escort.state == "calming" and p.partner.y + 28 or p.player.y + p.player.h * 0.55 -- 122
		elseif event.name == "actorHit" or event.name == "gateFailed" then -- 122
			playerHit = true -- 124
		elseif event.name == "coverBlocked" then -- 124
			coverDeflect = true -- 126
		elseif event.name == "bottleLanded" then -- 126
			bottleLanded = true -- 128
		elseif event.name == "cartDocked" then -- 128
			cartJustDocked = true -- 130
		elseif event.name == "roomChange" then -- 130
			migratedRoomChange = true -- 132
		end -- 132
	end -- 132
	self.prevRoomKey = p.room.key -- 137
	self.prevPhase = p.phase -- 138
	self.prevHp = p.hp -- 139
	self.prevTrace = p.trace -- 140
	self.prevCoveredFlash = p.coveredFlash -- 141
	self.prevRollT = p.player.rollT -- 142
	self.prevCalmTick = p.escort.calmTick -- 143
	self.prevKnocks = p.knocks -- 144
	self.prevBottleLandT = p.bottleLandT -- 145
	self.prevCartDocked = p.cartDocked -- 146
	self.prevCheckpoint = p.checkpoint -- 147
	self.prevCaughtT = p.caughtT -- 148
	self.prevGateSpawned = p.gateSpawned -- 149
	self.prevAliveMask = {} -- 150
	do -- 150
		i = 0 -- 151
		while i < #p.enemies do -- 151
			local ____self_prevAliveMask_3 = self.prevAliveMask -- 151
			____self_prevAliveMask_3[#____self_prevAliveMask_3 + 1] = p.enemies[i + 1].alive -- 152
			i = i + 1 -- 151
		end -- 151
	end -- 151
	local ____shotFired_5 = shotFired -- 156
	local ____shotHit_6 = shotHit -- 157
	local ____shotFired_4 -- 158
	if shotFired then -- 158
		____shotFired_4 = p.trace -- 158
	else -- 158
		____shotFired_4 = nil -- 158
	end -- 158
	return { -- 155
		shotFired = ____shotFired_5, -- 156
		shotHit = ____shotHit_6, -- 157
		shotTrace = ____shotFired_4, -- 158
		enemyKilledX = enemyKilledX, -- 159
		enemyKilledY = enemyKilledY, -- 160
		playerHit = playerHit, -- 161
		coverDeflect = coverDeflect, -- 162
		rollStarted = rollStarted, -- 163
		knockPulse = knockPulse, -- 164
		knockX = knockX, -- 165
		knockY = knockY, -- 166
		bottleLanded = bottleLanded, -- 167
		bottleLandX = p.bottleLandX, -- 168
		cartJustDocked = cartJustDocked, -- 169
		checkpointJustHit = checkpointJustHit, -- 170
		caughtTriggered = caughtTriggered, -- 171
		phaseChanged = phaseChanged, -- 172
		roomChanged = roomChanged or migratedRoomChange, -- 173
		gateWaveSpawned = gateWaveSpawned -- 174
	} -- 174
end -- 81
--- 每次只展示最相关的就近操作。走到可触发的位置才显示按键。
function ____exports.deriveWorldPrompt(p) -- 180
	local room = p.room -- 181
	local player = p.player -- 182
	if p.paused or not player.alive then -- 182
		return nil -- 184
	end -- 184
	if room.key == "prologue" and p.phase == "prologue-wait" then -- 184
		local ____opt_9 = room.story -- 184
		local ____opt_7 = ____opt_9 and ____opt_9.prologue -- 184
		local reach = ____opt_7 and ____opt_7.giveReach or 46 -- 188
		if math.abs(player.x - p.partner.x) <= reach then -- 188
			return { -- 190
				x = p.partner.x, -- 190
				y = p.partner.y + p.partner.h + 22, -- 190
				keyTag = "E", -- 190
				label = "递出指南针", -- 190
				urgent = false -- 190
			} -- 190
		end -- 190
		return nil -- 192
	end -- 192
	if not p.childMode and p.escort.state == "frozen" then -- 192
		if math.abs(player.x - p.partner.x) <= CALM_REACH then -- 192
			return { -- 197
				x = p.partner.x, -- 197
				y = p.partner.y + p.partner.h + 22, -- 197
				keyTag = "E", -- 197
				label = "安抚小满", -- 197
				urgent = true -- 197
			} -- 197
		end -- 197
		return nil -- 199
	end -- 199
	local ____opt_11 = room.story -- 199
	local gate = ____opt_11 and ____opt_11.gate -- 202
	if gate ~= nil then -- 202
		if p.phase == "gate-idle" and p.gateNeedConfirm and math.abs(player.x - gate.winchX) <= 24 and player.y < 20 and p.partner.alive and math.abs(p.partner.x - gate.waitX) <= 60 then -- 202
			return { -- 207
				x = gate.winchX, -- 207
				y = 84, -- 207
				keyTag = "E", -- 207
				label = "重新守门", -- 207
				urgent = true -- 207
			} -- 207
		end -- 207
		if p.phase == "gate-send" and math.abs(player.x - gate.doorX) <= 60 then -- 207
			return { -- 210
				x = gate.doorX, -- 210
				y = 98, -- 210
				keyTag = "E", -- 210
				label = "送小满出城", -- 210
				urgent = true -- 210
			} -- 210
		end -- 210
	end -- 210
	local cart = room.cart -- 214
	if (room.key == "checkpoint" or room.key == "outside") and not p.cartDocked and cart.bodyW > 0 then -- 214
		local handleX = p.cartAxle + cart.handleOffset -- 216
		if p.gripping or math.abs(player.x - handleX) <= CART_REACH and math.abs(player.y - cart.baseY) <= 40 then -- 216
			return { -- 218
				x = handleX, -- 219
				y = cart.baseY + cart.wheelR + cart.bodyH + 46, -- 220
				keyTag = "按住 E + D", -- 221
				label = room.key == "checkpoint" and "向前推车" or "向前拉车", -- 222
				urgent = false -- 223
			} -- 223
		end -- 223
	end -- 223
	if room.key == "village" and p.scavChase then -- 223
		local ____player_crouch_13 -- 229
		if player.crouch then -- 229
			____player_crouch_13 = nil -- 229
		else -- 229
			____player_crouch_13 = { -- 229
				x = player.x, -- 230
				y = player.y + player.h + 22, -- 230
				keyTag = "按住 Ctrl", -- 230
				label = "蹲下躲避", -- 230
				urgent = true -- 230
			} -- 230
		end -- 230
		return ____player_crouch_13 -- 229
	end -- 229
	if room.key == "village" and not p.passed then -- 229
		local bottle = room.bottle -- 235
		if p.hasBottle then -- 235
			return { -- 237
				x = player.x, -- 238
				y = player.y + player.h + 26, -- 238
				keyTag = p.aimHold >= 0.12 and "松开 F" or "按住 F", -- 239
				label = p.aimHold >= 0.12 and "投瓶" or "瞄准砖地", -- 240
				urgent = false -- 240
			} -- 240
		end -- 240
		if p.bottleFly == nil and bottle ~= nil then -- 240
			local dx = player.x - bottle.x -- 244
			local dy = player.y + player.h * 0.5 - bottle.y -- 245
			if dx * dx + dy * dy < 56 * 56 then -- 245
				return { -- 247
					x = bottle.x, -- 247
					y = bottle.y + 36, -- 247
					keyTag = "E", -- 247
					label = "拾起瓶子", -- 247
					urgent = false -- 247
				} -- 247
			end -- 247
		end -- 247
	end -- 247
	local arch = room.arch -- 252
	if (room.key == "village" or room.key == "outside" and p.cartDocked) and arch.h > 0 and not player.crouch and player.y <= arch.y + 28 and player.x >= arch.x0 - 56 and player.x < arch.x1 then -- 252
		return { -- 256
			x = (arch.x0 + arch.x1) * 0.5, -- 257
			y = arch.y + arch.h + 44, -- 257
			keyTag = "按住 Ctrl", -- 258
			label = room.key == "outside" and "蹲着穿过拱洞" or "蹲着钻过桌下", -- 258
			urgent = false -- 258
		} -- 258
	end -- 258
	local ____opt_14 = room.story -- 258
	local tower = ____opt_14 and ____opt_14.tower -- 262
	if p.phase == "tower-wait" and tower ~= nil and math.abs(player.x - tower.doorX) <= 50 then -- 262
		return { -- 264
			x = tower.doorX, -- 264
			y = 96, -- 264
			keyTag = "E", -- 264
			label = "敲门", -- 264
			urgent = false -- 264
		} -- 264
	end -- 264
	if not p.childMode and p.coverNear and not p.coverHug and not p.gripping and p.escort.state ~= "calming" and (gate == nil or p.phase == "gate-hold") then -- 264
		return { -- 269
			x = player.x, -- 270
			y = player.y + player.h + 25, -- 270
			keyTag = "按住 Shift", -- 271
			label = "贴靠掩体", -- 271
			urgent = gate ~= nil -- 271
		} -- 271
	end -- 271
	return nil -- 274
end -- 180
return ____exports -- 180