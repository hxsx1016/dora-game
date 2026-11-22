-- [ts]: input.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local edge -- 1
local ____Dora = require("Dora") -- 11
local App = ____Dora.App -- 11
local Keyboard = ____Dora.Keyboard -- 11
local Mouse = ____Dora.Mouse -- 11
local View = ____Dora.View -- 11
function edge(state, held) -- 114
	local next = {held = held, pressed = held and not state.held, released = not held and state.held} -- 115
	state.held = next.held -- 120
	state.pressed = next.pressed -- 121
	state.released = next.released -- 122
	return state -- 123
end -- 123
local function emptyKey() -- 20
	return {held = false, pressed = false, released = false} -- 21
end -- 20
____exports.Input = __TS__Class() -- 24
local Input = ____exports.Input -- 24
Input.name = "Input" -- 24
function Input.prototype.____constructor(self) -- 24
	self.moveX = 0 -- 26
	self.moveY = 0 -- 28
	self.jump = emptyKey() -- 30
	self.crouch = emptyKey() -- 31
	self.cover = emptyKey() -- 32
	self.interact = emptyKey() -- 33
	self.aim = emptyKey() -- 34
	self.fire = emptyKey() -- 35
	self.flare = emptyKey() -- 36
	self.pause = emptyKey() -- 37
	self.retry = emptyKey() -- 38
	self.toggleView = emptyKey() -- 39
	self.tab = emptyKey() -- 40
	self.pickRoom = 0 -- 43
	self.mx = 0 -- 46
	self.my = 0 -- 47
	self.inside = true -- 49
	self.mdx = 0 -- 52
	self.mdy = 0 -- 53
	self.lastPick = 0 -- 55
end -- 24
function Input.prototype.update(self) -- 57
	self:readKeys() -- 58
	self:readMouse() -- 59
end -- 57
function Input.prototype.readKeys(self) -- 62
	local left = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 63
	local right = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 64
	local up = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 65
	local down = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 66
	self.moveX = (right and 1 or 0) - (left and 1 or 0) -- 67
	self.moveY = (down and 1 or 0) - (up and 1 or 0) -- 68
	self.jump = edge( -- 70
		self.jump, -- 70
		Keyboard:isKeyPressed("Space") -- 70
	) -- 70
	self.crouch = edge( -- 71
		self.crouch, -- 71
		Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") or Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") -- 72
	) -- 72
	self.cover = edge( -- 74
		self.cover, -- 74
		Keyboard:isKeyPressed("LShift") or Keyboard:isKeyPressed("RShift") -- 75
	) -- 75
	self.interact = edge( -- 76
		self.interact, -- 76
		Keyboard:isKeyPressed("E") -- 76
	) -- 76
	self.aim = edge( -- 77
		self.aim, -- 77
		Keyboard:isKeyPressed("F") -- 77
	) -- 77
	self.fire = edge(self.fire, Mouse.leftButtonPressed) -- 78
	self.flare = edge( -- 79
		self.flare, -- 79
		Keyboard:isKeyPressed("Q") -- 79
	) -- 79
	self.pause = edge( -- 80
		self.pause, -- 80
		Keyboard:isKeyPressed("Escape") -- 80
	) -- 80
	self.retry = edge( -- 81
		self.retry, -- 81
		Keyboard:isKeyPressed("R") -- 81
	) -- 81
	self.toggleView = edge( -- 82
		self.toggleView, -- 82
		Keyboard:isKeyPressed("G") -- 82
	) -- 82
	self.tab = edge( -- 83
		self.tab, -- 83
		Keyboard:isKeyPressed("Tab") -- 83
	) -- 83
	local n1 = Keyboard:isKeyPressed("1") -- 85
	local n2 = Keyboard:isKeyPressed("2") -- 86
	local pick = n1 and 1 or (n2 and 2 or 0) -- 87
	self.pickRoom = pick ~= 0 and pick ~= self.lastPick and pick or 0 -- 88
	self.lastPick = pick -- 89
end -- 62
function Input.prototype.readMouse(self) -- 92
	local vs = App.visualSize -- 93
	local vw = View.size.width -- 94
	local vh = View.size.height -- 95
	local sw = vs.width > 0 and vs.width or 1 -- 96
	local sh = vs.height > 0 and vs.height or 1 -- 97
	local p = Mouse.position -- 98
	local x = p.x * vw / sw -- 100
	local y = p.y * vh / sh -- 101
	local nx = x -- 103
	local ny = vh - y -- 104
	self.mdx = nx - self.mx -- 105
	self.mdy = ny - self.my -- 106
	self.mx = nx -- 107
	self.my = ny -- 108
	self.inside = x >= 0 and x <= vw and y >= 0 and y <= vh -- 109
end -- 92
return ____exports -- 92