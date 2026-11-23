-- [ts]: camera.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____theme = require("Script.watch.fe.theme") -- 9
local themeOf = ____theme.themeOf -- 9
--- 基础竖直世界视野高度（zoom=1 时屏幕纵向容纳约 304 世界单位，1280×720 下约 2.37 px/单位）
local BASE_VIEW_UNITS_H = 304 -- 12
--- 地面基准线落在屏幕从底往上的比例（约 22.5%，留出大气天际与底部叙事字幕带）
local GROUND_SCREEN_FRAC = 0.225 -- 14
____exports.CameraDirector = __TS__Class() -- 16
local CameraDirector = ____exports.CameraDirector -- 16
CameraDirector.name = "CameraDirector" -- 16
function CameraDirector.prototype.____constructor(self) -- 16
	self.x = 0 -- 18
	self.y = 85 -- 19
	self.zoom = 1 -- 21
	self.shakeAmp = 0 -- 23
	self.shakeX = 0 -- 24
	self.shakeY = 0 -- 25
	self.shakePhase = 0 -- 26
	self.viewW = 1280 -- 29
	self.viewH = 720 -- 30
	self.ppu = 2.37 -- 31
	self.groundScreenY = 162 -- 32
end -- 16
function CameraDirector.prototype.snap(self, p, w, h) -- 35
	local theme = themeOf(p.room.key) -- 36
	self.zoom = theme.defaultZoom -- 37
	self.shakeAmp = 0 -- 38
	self.shakeX = 0 -- 39
	self.shakeY = 0 -- 40
	self.x = p.player.x + p.player.facing * 42 -- 41
	self.y = self:targetCamY(p) -- 42
	self:recomputeMetrics(p, w, h) -- 43
end -- 35
function CameraDirector.prototype.addShake(self, amount) -- 47
	if amount > self.shakeAmp then -- 47
		self.shakeAmp = math.min(18, amount) -- 49
	else -- 49
		self.shakeAmp = math.min(18, self.shakeAmp + amount * 0.45) -- 51
	end -- 51
end -- 47
function CameraDirector.prototype.update(self, dt, p, w, h) -- 56
	local theme = themeOf(p.room.key) -- 57
	local desiredZoom = theme.defaultZoom -- 58
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 58
		desiredZoom = 1.24 -- 62
	elseif not p.childMode and p.escort.state == "calming" then -- 62
		desiredZoom = 1.2 -- 64
	elseif p.room.key == "gate" then -- 64
		if p.phase == "gate-hold" then -- 64
			desiredZoom = 0.88 -- 67
		elseif p.phase == "gate-count" then -- 67
			desiredZoom = 1.15 -- 69
		elseif p.phase == "gate-send" then -- 69
			desiredZoom = 1.06 -- 71
		end -- 71
	elseif p.room.key == "outside" then -- 71
		desiredZoom = p.player.x < 560 and 0.94 or 1.02 -- 75
	elseif p.room.key == "tower" and p.phase ~= "tower-wait" then -- 75
		desiredZoom = 1.22 -- 77
	end -- 77
	local zk = math.min(1, dt * 3.8) -- 80
	self.zoom = self.zoom + (desiredZoom - self.zoom) * zk -- 81
	local lookAhead = p.player.facing * 48 -- 84
	if not p.childMode and p.aimX > 0 and w > 0 then -- 84
		local normMouse = (p.aimX / w - 0.5) * 2 -- 86
		lookAhead = lookAhead + normMouse * 36 -- 87
	end -- 87
	if p.room.key == "outside" and p.player.x < 520 then -- 87
		lookAhead = p.player.x < 280 and 96 or 18 -- 91
	end -- 91
	if p.room.key == "gate" and p.phase == "gate-hold" then -- 91
		lookAhead = 120 -- 94
	end -- 94
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 94
		lookAhead = (p.partner.x - p.player.x) * 0.5 -- 97
	end -- 97
	local tx = p.player.x + lookAhead -- 100
	local ty = self:targetCamY(p) -- 101
	local followK = math.min(1, dt * 6.5) -- 102
	self.x = self.x + (tx - self.x) * followK -- 103
	self.y = self.y + (ty - self.y) * math.min(1, dt * 5) -- 104
	if self.shakeAmp > 0.08 then -- 104
		self.shakePhase = self.shakePhase + dt * 68 -- 108
		self.shakeX = math.sin(self.shakePhase * 1.3) * self.shakeAmp -- 109
		self.shakeY = math.cos(self.shakePhase * 1.7) * self.shakeAmp * 0.72 -- 110
		self.shakeAmp = self.shakeAmp * math.max(0, 1 - dt * 11.5) -- 111
	else -- 111
		self.shakeAmp = 0 -- 113
		self.shakeX = 0 -- 114
		self.shakeY = 0 -- 115
	end -- 115
	self:recomputeMetrics(p, w, h) -- 118
end -- 56
function CameraDirector.prototype.targetCamY(self, p) -- 121
	if p.room.key == "outside" and p.player.y >= 60 then -- 121
		return 102 -- 123
	end -- 123
	return 82 + math.max(0, p.player.y - 36) * 0.35 -- 125
end -- 121
function CameraDirector.prototype.recomputeMetrics(self, p, w, h) -- 128
	self.viewW = math.max(320, w) -- 129
	self.viewH = math.max(180, h) -- 130
	self.ppu = self.viewH / BASE_VIEW_UNITS_H * self.zoom -- 131
	self.groundScreenY = self.viewH * GROUND_SCREEN_FRAC -- 132
	local halfWorldW = self.viewW * 0.5 / self.ppu -- 135
	local spanX = p.room.maxX - p.room.minX -- 136
	if spanX <= halfWorldW * 2 then -- 136
		self.x = (p.room.minX + p.room.maxX) * 0.5 -- 138
	else -- 138
		local minCam = p.room.minX + halfWorldW -- 140
		local maxCam = p.room.maxX - halfWorldW -- 141
		if self.x < minCam then -- 141
			self.x = minCam -- 143
		end -- 143
		if self.x > maxCam then -- 143
			self.x = maxCam -- 146
		end -- 146
	end -- 146
end -- 128
function CameraDirector.prototype.sx(self, wx) -- 152
	return self.viewW * 0.5 + (wx - self.x) * self.ppu + self.shakeX -- 153
end -- 152
function CameraDirector.prototype.sy(self, wy) -- 157
	local yOffset = (self.y - 82) * 0.45 -- 158
	return self.groundScreenY + (wy - yOffset) * self.ppu + self.shakeY -- 159
end -- 157
function CameraDirector.prototype.len(self, worldLen) -- 163
	return worldLen * self.ppu -- 164
end -- 163
function CameraDirector.prototype.screenToWorld(self, screenX, screenY) -- 168
	local yOffset = (self.y - 82) * 0.45 -- 169
	return {x = self.x + (screenX - self.shakeX - self.viewW * 0.5) / self.ppu, y = yOffset + (screenY - self.shakeY - self.groundScreenY) / self.ppu} -- 170
end -- 168
return ____exports -- 168