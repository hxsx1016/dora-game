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
function edge(state, held) -- 173
	local was = state.held -- 174
	state.held = held -- 175
	if held and not was then -- 175
		state.pressed = true -- 177
	end -- 177
	if not held and was then -- 177
		state.released = true -- 180
	end -- 180
	return state -- 182
end -- 182
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
	self.crouch = edge( -- 127
		self.crouch, -- 127
		Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") -- 128
	) -- 128
	self.cover = edge( -- 129
		self.cover, -- 129
		Keyboard:isKeyPressed("LShift") or Keyboard:isKeyPressed("RShift") -- 130
	) -- 130
	self.interact = edge( -- 131
		self.interact, -- 131
		Keyboard:isKeyPressed("E") -- 131
	) -- 131
	self.aim = edge( -- 132
		self.aim, -- 132
		Keyboard:isKeyPressed("F") -- 132
	) -- 132
	self.fire = edge(self.fire, Mouse.leftButtonPressed) -- 133
	self.flare = edge( -- 134
		self.flare, -- 134
		Keyboard:isKeyPressed("Q") -- 134
	) -- 134
	self.pause = edge( -- 135
		self.pause, -- 135
		Keyboard:isKeyPressed("Escape") -- 135
	) -- 135
	self.retry = edge( -- 136
		self.retry, -- 136
		Keyboard:isKeyPressed("R") -- 136
	) -- 136
	self.toggleView = edge( -- 137
		self.toggleView, -- 137
		Keyboard:isKeyPressed("G") -- 137
	) -- 137
	self.tab = edge( -- 138
		self.tab, -- 138
		Keyboard:isKeyPressed("Tab") -- 138
	) -- 138
	local n1 = Keyboard:isKeyPressed("1") -- 140
	local n2 = Keyboard:isKeyPressed("2") -- 141
	local n3 = Keyboard:isKeyPressed("3") -- 142
	local pick = n1 and 1 or (n2 and 2 or (n3 and 3 or 0)) -- 143
	if pick ~= 0 and pick ~= self.lastPick then -- 143
		self.pickRoom = pick -- 146
	end -- 146
	self.lastPick = pick -- 148
end -- 115
function Input.prototype.readMouse(self) -- 151
	local vs = App.visualSize -- 152
	local vw = View.size.width -- 153
	local vh = View.size.height -- 154
	local sw = vs.width > 0 and vs.width or 1 -- 155
	local sh = vs.height > 0 and vs.height or 1 -- 156
	local p = Mouse.position -- 157
	local x = p.x * vw / sw -- 159
	local y = p.y * vh / sh -- 160
	local nx = x -- 162
	local ny = vh - y -- 163
	self.mdx = nx - self.mx -- 164
	self.mdy = ny - self.my -- 165
	self.mx = nx -- 166
	self.my = ny -- 167
	self.inside = x >= 0 and x <= vw and y >= 0 and y <= vh -- 168
end -- 151
return ____exports -- 151