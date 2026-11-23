-- [ts]: escort.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor -- 1
local ____exports = {} -- 1
--- 恐惧满格。
____exports.FEAR_MAX = 3 -- 16
--- 安抚总拍数：第 12 拍第一声、第 36 拍第二声、第 60 拍恢复移动。
____exports.CALM_TICKS = 60 -- 18
--- 周戍离她多近才能开始安抚。
____exports.CALM_REACH = 64 -- 20
--- 躲进掩体后停留的拍数。
local COVER_TICKS = 90 -- 22
--- 跟随时落在周戍身后多少单位。
local FOLLOW_GAP = 30 -- 24
--- 到这个距离内就不再挪脚，避免左右抖。
local STOP_GAP = 6 -- 26
____exports.Escort = __TS__Class() -- 28
local Escort = ____exports.Escort -- 28
Escort.name = "Escort" -- 28
function Escort.prototype.____constructor(self, safeX, followGap) -- 46
	if followGap == nil then -- 46
		followGap = FOLLOW_GAP -- 46
	end -- 46
	self.state = "follow" -- 29
	self.fear = 0 -- 30
	self.calmTick = 0 -- 32
	self.knock1 = false -- 34
	self.knock2 = false -- 35
	self.targetX = 0 -- 37
	self.note = "" -- 39
	self.coverTick = 0 -- 41
	self.dangerIds = {} -- 42
	self.safeX = safeX -- 47
	self.followGap = followGap -- 48
	self.targetX = safeX -- 49
end -- 46
function Escort.prototype.hasDanger(self, id) -- 63
	local i = 0 -- 64
	do -- 64
		i = 0 -- 65
		while i < #self.dangerIds do -- 65
			if self.dangerIds[i + 1] == id then -- 65
				return true -- 67
			end -- 67
			i = i + 1 -- 65
		end -- 65
	end -- 65
	return false -- 70
end -- 63
function Escort.prototype.applyDanger(self, id, exposed, childX) -- 77
	if not exposed then -- 77
		return self.fear -- 79
	end -- 79
	if self:hasDanger(id) then -- 79
		return self.fear -- 82
	end -- 82
	local ____self_dangerIds_0 = self.dangerIds -- 82
	____self_dangerIds_0[#____self_dangerIds_0 + 1] = id -- 84
	if self.fear < ____exports.FEAR_MAX then -- 84
		self.fear = self.fear + 1 -- 86
	end -- 86
	if self.fear >= ____exports.FEAR_MAX then -- 86
		self.state = "frozen" -- 90
		self.targetX = childX -- 91
		self.note = "三格 · 蹲下捂耳" -- 92
	else -- 92
		self.state = "seekCover" -- 94
		self.targetX = self.safeX -- 95
		self.note = "跑向安全锚" -- 96
	end -- 96
	return self.fear -- 98
end -- 77
function Escort.prototype.update(self, input, playerX, playerFacing, childX, distance) -- 105
	if self.state == "frozen" then -- 105
		if input.interact.pressed and distance <= ____exports.CALM_REACH then -- 105
			self.state = "calming" -- 108
			self.calmTick = 0 -- 109
			self.knock1 = false -- 110
			self.knock2 = false -- 111
			self.note = "周戍蹲下，抬起手" -- 112
			return true -- 113
		end -- 113
		return false -- 115
	end -- 115
	if self.state == "calming" then -- 115
		self.calmTick = self.calmTick + 1 -- 119
		if self.calmTick == 12 then -- 119
			self.knock1 = true -- 121
			self.note = "第一声" -- 122
		end -- 122
		if self.calmTick == 36 then -- 122
			self.knock2 = true -- 125
			self.fear = 1 -- 126
			self.note = "第二声 · 我听见了" -- 127
		end -- 127
		if self.calmTick >= ____exports.CALM_TICKS then -- 127
			self.state = "follow" -- 130
			self.note = "小满站起来，重新跟上" -- 131
		end -- 131
		return false -- 133
	end -- 133
	if self.state == "sheltered" then -- 133
		self.coverTick = self.coverTick - 1 -- 137
		if self.coverTick <= 0 then -- 137
			self.state = "follow" -- 139
			self.note = "危险过去，继续跟随" -- 140
		end -- 140
		return false -- 142
	end -- 142
	if self.state == "seekCover" then -- 142
		self.targetX = self.safeX -- 146
		if math.abs(self.safeX - childX) < STOP_GAP then -- 146
			self.state = "sheltered" -- 148
			self.coverTick = COVER_TICKS -- 149
			self.note = "缩在柜台后，捂住耳朵" -- 150
		end -- 150
		return false -- 152
	end -- 152
	self.targetX = playerX - playerFacing * self.followGap -- 155
	return false -- 156
end -- 105
function Escort.prototype.moveDir(self, childX) -- 160
	if self.stopped then -- 160
		return 0 -- 162
	end -- 162
	local dx = self.targetX - childX -- 164
	if dx > STOP_GAP then -- 164
		return 1 -- 166
	end -- 166
	if dx < -STOP_GAP then -- 166
		return -1 -- 169
	end -- 169
	return 0 -- 171
end -- 160
__TS__SetDescriptor( -- 160
	Escort.prototype, -- 160
	"stopped", -- 160
	{get = function(self) -- 160
		return self.state == "frozen" or self.state == "calming" -- 54
	end}, -- 54
	true -- 54
) -- 54
__TS__SetDescriptor( -- 54
	Escort.prototype, -- 54
	"crouchPose", -- 54
	{get = function(self) -- 54
		return self.state == "frozen" or self.state == "calming" or self.state == "sheltered" -- 59
	end}, -- 59
	true -- 59
) -- 59
--- 从房间标记里找第一个安全锚（kind 1）的 x；没有就返回 -1。
function ____exports.safeAnchorX(marks) -- 176
	local i = 0 -- 177
	do -- 177
		i = 0 -- 178
		while i < #marks do -- 178
			if marks[i + 1].kind == 1 then -- 178
				return marks[i + 1].x -- 180
			end -- 180
			i = i + 1 -- 178
		end -- 178
	end -- 178
	return -1 -- 183
end -- 176
return ____exports -- 176