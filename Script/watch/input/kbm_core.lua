-- [ts]: kbm_core.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local App = ____Dora.App -- 12
local Keyboard = ____Dora.Keyboard -- 12
local Mouse = ____Dora.Mouse -- 12
local View = ____Dora.View -- 12
____exports.KbmPoller = __TS__Class() -- 53
local KbmPoller = ____exports.KbmPoller -- 53
KbmPoller.name = "KbmPoller" -- 53
function KbmPoller.prototype.____constructor(self) -- 53
	self.rawMouseX = -1 -- 54
	self.rawMouseY = -1 -- 55
	self.rawMouseInited = false -- 56
	self.prevMouseLeft = false -- 57
	self.prevMouseRight = false -- 58
	self.prevUp = false -- 60
	self.prevDown = false -- 61
	self.prevLeft = false -- 62
	self.prevRight = false -- 63
	self.prevConfirm = false -- 64
	self.prevConfirmWithE = false -- 65
	self.prevBackSpace = false -- 66
end -- 53
function KbmPoller.prototype.attach(self, parent, hooks) -- 68
	parent:onKeyDown(function(key) -- 69
		hooks:onFirstUserGesture() -- 70
		if key == "F11" or key == "Return" and (Keyboard:isKeyPressed("LAlt") or Keyboard:isKeyPressed("RAlt")) then -- 70
			hooks:onToggleFullscreen() -- 74
			return -- 75
		end -- 75
		hooks:onKeyDownEvent(key) -- 77
	end) -- 69
end -- 68
function KbmPoller.prototype.sample(self, vp) -- 81
	local vs = App.visualSize -- 83
	local vw = View.size.width > 0 and View.size.width or vp.fullW -- 84
	local vh = View.size.height > 0 and View.size.height or vp.fullH -- 85
	local sw = vs.width > 0 and vs.width or 1 -- 86
	local sh = vs.height > 0 and vs.height or 1 -- 87
	local p = Mouse.position -- 88
	local fullX = p.x * vw / sw -- 89
	local fullY = vh - p.y * vh / sh -- 90
	local mouseLeft = Mouse.leftButtonPressed -- 92
	local mouseRight = Mouse.rightButtonPressed -- 93
	local mouseMoved = self.rawMouseInited and math.abs(fullX - self.rawMouseX) + math.abs(fullY - self.rawMouseY) >= 2.5 -- 94
	local mouseLeftPressed = mouseLeft and not self.prevMouseLeft -- 96
	local mouseLeftReleased = not mouseLeft and self.prevMouseLeft -- 97
	local mouseRightPressed = mouseRight and not self.prevMouseRight -- 98
	local mouseClicked = mouseLeftPressed or mouseRightPressed -- 99
	self.rawMouseX = fullX -- 101
	self.rawMouseY = fullY -- 102
	self.rawMouseInited = true -- 103
	self.prevMouseLeft = mouseLeft -- 104
	self.prevMouseRight = mouseRight -- 105
	local stX = vp.stageW > 0 and vp.stageX or 0 -- 107
	local stY = vp.stageH > 0 and vp.stageY or 0 -- 108
	local stW = vp.stageW > 0 and vp.stageW or vw -- 109
	local stH = vp.stageH > 0 and vp.stageH or vh -- 110
	local mouseStageX = fullX - stX -- 111
	local mouseStageY = fullY - stY -- 112
	local mouseInsideStage = mouseStageX >= 0 and mouseStageX <= stW and mouseStageY >= 0 and mouseStageY <= stH -- 113
	local left = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 116
	local right = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 117
	local up = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 118
	local down = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 119
	local jump = Keyboard:isKeyPressed("Space") -- 120
	local crouch = Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") or Keyboard:isKeyPressed("C") -- 121
	local cover = Keyboard:isKeyPressed("LShift") or Keyboard:isKeyPressed("RShift") -- 122
	local interact = Keyboard:isKeyPressed("E") -- 123
	local aim = Keyboard:isKeyPressed("F") -- 124
	local flare = Keyboard:isKeyPressed("Q") -- 125
	local pause = Keyboard:isKeyPressed("Escape") -- 126
	local retry = Keyboard:isKeyPressed("R") -- 127
	local toggleView = Keyboard:isKeyPressed("G") -- 128
	local tab = Keyboard:isKeyPressed("Tab") -- 129
	local ret = Keyboard:isKeyPressed("Return") -- 130
	local bs = Keyboard:isKeyPressed("BackSpace") -- 131
	local n1 = Keyboard:isKeyPressed("1") -- 132
	local n2 = Keyboard:isKeyPressed("2") -- 133
	local n3 = Keyboard:isKeyPressed("3") -- 134
	local confirm = ret or jump -- 136
	local confirmWithE = confirm or interact -- 137
	local navUp = up and not self.prevUp -- 139
	local navDown = down and not self.prevDown -- 140
	local navLeft = left and not self.prevLeft -- 141
	local navRight = right and not self.prevRight -- 142
	local navConfirm = confirm and not self.prevConfirm -- 143
	local uiConfirmWithE = confirmWithE and not self.prevConfirmWithE -- 144
	local uiBackSpace = bs and not self.prevBackSpace -- 145
	self.prevUp = up -- 147
	self.prevDown = down -- 148
	self.prevLeft = left -- 149
	self.prevRight = right -- 150
	self.prevConfirm = confirm -- 151
	self.prevConfirmWithE = confirmWithE -- 152
	self.prevBackSpace = bs -- 153
	local anyKb = left or right or up or down or jump or crouch or cover or interact or aim or flare or pause or retry or toggleView or tab or n1 or n2 or n3 or ret or bs -- 155
	return { -- 159
		mouseStageX = mouseStageX, -- 160
		mouseStageY = mouseStageY, -- 161
		mouseInsideStage = mouseInsideStage, -- 162
		mouseLeft = mouseLeft, -- 163
		mouseLeftPressed = mouseLeftPressed, -- 164
		mouseLeftReleased = mouseLeftReleased, -- 165
		mouseRight = mouseRight, -- 166
		mouseRightPressed = mouseRightPressed, -- 167
		mouseMoved = mouseMoved, -- 168
		mouseClicked = mouseClicked, -- 169
		moveX = (right and 1 or 0) - (left and 1 or 0), -- 170
		moveY = (down and 1 or 0) - (up and 1 or 0), -- 171
		jump = jump, -- 172
		crouch = crouch, -- 173
		cover = cover, -- 174
		interact = interact, -- 175
		aim = aim, -- 176
		flare = flare, -- 177
		pause = pause, -- 178
		retry = retry, -- 179
		toggleView = toggleView, -- 180
		tab = tab, -- 181
		pick = n1 and 1 or (n2 and 2 or (n3 and 3 or 0)), -- 182
		anyKb = anyKb, -- 183
		navUp = navUp, -- 184
		navDown = navDown, -- 185
		navLeft = navLeft, -- 186
		navRight = navRight, -- 187
		navConfirm = navConfirm, -- 188
		navBack = false, -- 189
		uiConfirmWithE = uiConfirmWithE, -- 190
		uiBackSpace = uiBackSpace -- 191
	} -- 191
end -- 81
return ____exports -- 81