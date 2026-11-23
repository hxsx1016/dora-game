-- [ts]: adapter.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
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
--- 推导当前场景内最应高亮的 1–2 个世界空间悬浮交互提示（艾希风场景内嵌指引）
function ____exports.deriveWorldPrompts(p) -- 172
	local out = {} -- 173
	local key = p.room.key -- 174
	local pl = p.player -- 175
	if p.paused then -- 175
		return out -- 178
	end -- 178
	if key == "prologue" and p.phase == "prologue-wait" then -- 178
		local d = math.abs(pl.x - p.partner.x) -- 183
		out[#out + 1] = { -- 184
			x = p.partner.x, -- 185
			y = p.partner.y + p.partner.h + 18, -- 186
			keyTag = d <= 52 and "E" or "→", -- 187
			label = d <= 52 and "递出指南针" or "走近小满", -- 188
			urgent = d <= 52 -- 189
		} -- 189
		return out -- 191
	end -- 191
	if not p.childMode and p.escort.state == "frozen" then -- 191
		local d = math.abs(pl.x - p.partner.x) -- 196
		out[#out + 1] = { -- 197
			x = p.partner.x, -- 198
			y = p.partner.y + p.partner.h + 18, -- 199
			keyTag = d <= CALM_REACH and "E" or "!", -- 200
			label = d <= CALM_REACH and "敲两下安抚" or "小满受惊停步", -- 201
			urgent = true -- 202
		} -- 202
	end -- 202
	if not p.childMode and p.coverNear and not p.coverHug and not (key == "gate" and p.phase == "gate-idle") then -- 202
		out[#out + 1] = { -- 208
			x = pl.x, -- 209
			y = pl.y + pl.h + 22, -- 210
			keyTag = "SHIFT", -- 211
			label = "贴靠掩体", -- 212
			urgent = key == "gate" and p.phase == "gate-hold" -- 213
		} -- 213
	end -- 213
	if key == "gate" and p.room.story ~= nil and p.room.story.gate ~= nil then -- 213
		local g = p.room.story.gate -- 219
		if p.phase == "gate-idle" then -- 219
			if p.gateNeedConfirm then -- 219
				out[#out + 1] = { -- 222
					x = g.winchX, -- 222
					y = 84, -- 222
					keyTag = "E", -- 222
					label = "重新就位", -- 222
					urgent = true -- 222
				} -- 222
			else -- 222
				out[#out + 1] = { -- 224
					x = g.winchX, -- 224
					y = 84, -- 224
					keyTag = "守", -- 224
					label = "贴近绞盘就位", -- 224
					urgent = false -- 224
				} -- 224
			end -- 224
		elseif p.phase == "gate-send" then -- 224
			out[#out + 1] = { -- 227
				x = g.doorX, -- 227
				y = 98, -- 227
				keyTag = "E", -- 227
				label = "送她出城", -- 227
				urgent = true -- 227
			} -- 227
		end -- 227
	end -- 227
	if (key == "checkpoint" or key == "outside") and not p.cartDocked and p.room.cart.bodyW > 0 then -- 227
		local c = p.room.cart -- 233
		local hx = p.cartAxle + c.handleOffset -- 234
		local d = math.abs(pl.x - hx) -- 235
		local dy = math.abs(pl.y - c.baseY) -- 236
		if d < 95 and dy < 48 then -- 236
			out[#out + 1] = { -- 238
				x = hx, -- 239
				y = c.baseY + c.wheelR + c.bodyH + 26, -- 240
				keyTag = p.gripping and "D" or "E+D", -- 241
				label = key == "checkpoint" and "推车入窝" or "拉车入窝", -- 242
				urgent = p.gripping -- 243
			} -- 243
		end -- 243
	end -- 243
	if key == "outside" and p.cartDocked and pl.y < 30 and pl.x > 190 and pl.x < 320 and not pl.crouch then -- 243
		out[#out + 1] = { -- 250
			x = 320, -- 251
			y = 54, -- 252
			keyTag = "CTRL", -- 253
			label = "蹲伏穿拱", -- 254
			urgent = false -- 255
		} -- 255
	end -- 255
	if key == "village" then -- 255
		if not p.hasBottle and p.bottleFly == nil and p.room.bottle ~= nil then -- 255
			local d = math.abs(pl.x - p.room.bottle.x) -- 262
			if d < 85 then -- 262
				out[#out + 1] = { -- 264
					x = p.room.bottle.x, -- 265
					y = 78, -- 266
					keyTag = "E", -- 267
					label = "拾取玻璃瓶", -- 268
					urgent = true -- 269
				} -- 269
			end -- 269
		elseif p.hasBottle and p.aimHold <= 0 then -- 269
			out[#out + 1] = { -- 273
				x = pl.x, -- 274
				y = pl.y + pl.h + 22, -- 275
				keyTag = "F", -- 276
				label = "按住瞄准 · 松手投向砖地", -- 277
				urgent = false -- 278
			} -- 278
		end -- 278
		if pl.x > 250 and pl.x < 330 and not pl.crouch then -- 278
			out[#out + 1] = { -- 282
				x = 360, -- 283
				y = 58, -- 284
				keyTag = "CTRL", -- 285
				label = "蹲伏钻桌", -- 286
				urgent = false -- 287
			} -- 287
		end -- 287
	end -- 287
	if key == "tower" and p.phase == "tower-wait" and p.room.story ~= nil and p.room.story.tower ~= nil then -- 287
		local dx = math.abs(pl.x - p.room.story.tower.doorX) -- 294
		out[#out + 1] = { -- 295
			x = p.room.story.tower.doorX, -- 296
			y = 96, -- 297
			keyTag = "E", -- 298
			label = dx <= 50 and "敲两下" or "走到塔门前", -- 299
			urgent = dx <= 50 -- 300
		} -- 300
	end -- 300
	return out -- 304
end -- 172
return ____exports -- 172