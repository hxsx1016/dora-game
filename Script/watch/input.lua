-- [ts]: input.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local edge -- 1
local ____Dora = require("Dora") -- 19
local App = ____Dora.App -- 19
local Keyboard = ____Dora.Keyboard -- 19
local Mouse = ____Dora.Mouse -- 19
local View = ____Dora.View -- 19
function edge(state, held) -- 171
	local was = state.held -- 172
	state.held = held -- 173
	if held and not was then -- 173
		state.pressed = true -- 175
	end -- 175
	if not held and was then -- 175
		state.released = true -- 178
	end -- 178
	return state -- 180
end -- 180
local function emptyKey() -- 28
	return {held = false, pressed = false, released = false} -- 29
end -- 28
____exports.Input = __TS__Class() -- 32
local Input = ____exports.Input -- 32
Input.name = "Input" -- 32
function Input.prototype.____constructor(self) -- 32
	self.moveX = 0 -- 34
	self.moveY = 0 -- 36
	self.jump = emptyKey() -- 38
	self.crouch = emptyKey() -- 39
	self.cover = emptyKey() -- 40
	self.interact = emptyKey() -- 41
	self.aim = emptyKey() -- 42
	self.fire = emptyKey() -- 43
	self.flare = emptyKey() -- 44
	self.pause = emptyKey() -- 45
	self.retry = emptyKey() -- 46
	self.toggleView = emptyKey() -- 47
	self.tab = emptyKey() -- 48
	self.pickRoom = 0 -- 51
	self.mx = 0 -- 54
	self.my = 0 -- 55
	self.inside = true -- 57
	self.mdx = 0 -- 60
	self.mdy = 0 -- 61
	self.lastPick = 0 -- 63
end -- 32
function Input.prototype.update(self) -- 65
	self:readKeys() -- 66
	self:readMouse() -- 67
end -- 65
function Input.prototype.beginStep(self, first) -- 74
	if not first then -- 74
		self:clearEdges() -- 76
	end -- 76
end -- 74
function Input.prototype.endStep(self) -- 81
	self:clearEdges() -- 82
end -- 81
function Input.prototype.consumeEdges(self) -- 86
	self:clearEdges() -- 87
end -- 86
function Input.prototype.clearEdges(self) -- 90
	self.jump.pressed = false -- 91
	self.jump.released = false -- 92
	self.crouch.pressed = false -- 93
	self.crouch.released = false -- 94
	self.cover.pressed = false -- 95
	self.cover.released = false -- 96
	self.interact.pressed = false -- 97
	self.interact.released = false -- 98
	self.aim.pressed = false -- 99
	self.aim.released = false -- 100
	self.fire.pressed = false -- 101
	self.fire.released = false -- 102
	self.flare.pressed = false -- 103
	self.flare.released = false -- 104
	self.pause.pressed = false -- 105
	self.pause.released = false -- 106
	self.retry.pressed = false -- 107
	self.retry.released = false -- 108
	self.toggleView.pressed = false -- 109
	self.toggleView.released = false -- 110
	self.tab.pressed = false -- 111
	self.tab.released = false -- 112
end -- 90
function Input.prototype.readKeys(self) -- 115
	local left = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 116
	local right = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 117
	local up = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 118
	local down = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 119
	self.moveX = (right and 1 or 0) - (left and 1 or 0) -- 120
	self.moveY = (down and 1 or 0) - (up and 1 or 0) -- 121
	self.jump = edge( -- 123
		self.jump, -- 123
		Keyboard:isKeyPressed("Space") -- 123
	) -- 123
	self.crouch = edge( -- 124
		self.crouch, -- 124
		Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") -- 125
	) -- 125
	self.cover = edge( -- 127
		self.cover, -- 127
		Keyboard:isKeyPressed("LShift") or Keyboard:isKeyPressed("RShift") -- 128
	) -- 128
	self.interact = edge( -- 129
		self.interact, -- 129
		Keyboard:isKeyPressed("E") -- 129
	) -- 129
	self.aim = edge( -- 130
		self.aim, -- 130
		Keyboard:isKeyPressed("F") -- 130
	) -- 130
	self.fire = edge(self.fire, Mouse.leftButtonPressed) -- 131
	self.flare = edge( -- 132
		self.flare, -- 132
		Keyboard:isKeyPressed("Q") -- 132
	) -- 132
	self.pause = edge( -- 133
		self.pause, -- 133
		Keyboard:isKeyPressed("Escape") -- 133
	) -- 133
	self.retry = edge( -- 134
		self.retry, -- 134
		Keyboard:isKeyPressed("R") -- 134
	) -- 134
	self.toggleView = edge( -- 135
		self.toggleView, -- 135
		Keyboard:isKeyPressed("G") -- 135
	) -- 135
	self.tab = edge( -- 136
		self.tab, -- 136
		Keyboard:isKeyPressed("Tab") -- 136
	) -- 136
	local n1 = Keyboard:isKeyPressed("1") -- 138
	local n2 = Keyboard:isKeyPressed("2") -- 139
	local n3 = Keyboard:isKeyPressed("3") -- 140
	local pick = n1 and 1 or (n2 and 2 or (n3 and 3 or 0)) -- 141
	if pick ~= 0 and pick ~= self.lastPick then -- 141
		self.pickRoom = pick -- 144
	end -- 144
	self.lastPick = pick -- 146
end -- 115
function Input.prototype.readMouse(self) -- 149
	local vs = App.visualSize -- 150
	local vw = View.size.width -- 151
	local vh = View.size.height -- 152
	local sw = vs.width > 0 and vs.width or 1 -- 153
	local sh = vs.height > 0 and vs.height or 1 -- 154
	local p = Mouse.position -- 155
	local x = p.x * vw / sw -- 157
	local y = p.y * vh / sh -- 158
	local nx = x -- 160
	local ny = vh - y -- 161
	self.mdx = nx - self.mx -- 162
	self.mdy = ny - self.my -- 163
	self.mx = nx -- 164
	self.my = ny -- 165
	self.inside = x >= 0 and x <= vw and y >= 0 and y <= vh -- 166
end -- 149
return ____exports -- 149