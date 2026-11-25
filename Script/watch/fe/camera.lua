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
		elseif p.phase == "gate-wait" then -- 69
			desiredZoom = 1.12 -- 72
		elseif p.phase == "gate-hand" then -- 72
			desiredZoom = 1.22 -- 74
		elseif p.phase == "gate-send" then -- 74
			desiredZoom = 1.06 -- 76
		end -- 76
	elseif p.room.key == "outside" then -- 76
		desiredZoom = p.player.x < 560 and 0.94 or 1.02 -- 80
	elseif p.room.key == "tower" and p.phase ~= "tower-wait" then -- 80
		desiredZoom = 1.22 -- 82
	end -- 82
	local zk = math.min(1, dt * 3.8) -- 85
	if p.reloadOpen then -- 85
		desiredZoom = math.max(desiredZoom, 1.16) -- 88
	end -- 88
	self.zoom = self.zoom + (desiredZoom - self.zoom) * zk -- 90
	local lookAhead = p.player.facing * 48 -- 93
	if not p.childMode and p.aimX > 0 and w > 0 then -- 93
		local normMouse = (p.aimX / w - 0.5) * 2 -- 95
		lookAhead = lookAhead + normMouse * 36 -- 96
	end -- 96
	if p.room.key == "outside" and p.player.x < 520 then -- 96
		lookAhead = p.player.x < 280 and 96 or 18 -- 100
	end -- 100
	if p.room.key == "gate" and p.phase == "gate-hold" then -- 100
		lookAhead = 120 -- 103
	end -- 103
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 103
		lookAhead = (p.partner.x - p.player.x) * 0.5 -- 106
	end -- 106
	local tx = p.player.x + lookAhead -- 109
	local ty = self:targetCamY(p) -- 110
	local followK = math.min(1, dt * 6.5) -- 111
	self.x = self.x + (tx - self.x) * followK -- 112
	self.y = self.y + (ty - self.y) * math.min(1, dt * 5) -- 113
	if self.shakeAmp > 0.08 then -- 113
		self.shakePhase = self.shakePhase + dt * 68 -- 117
		self.shakeX = math.sin(self.shakePhase * 1.3) * self.shakeAmp -- 118
		self.shakeY = math.cos(self.shakePhase * 1.7) * self.shakeAmp * 0.72 -- 119
		self.shakeAmp = self.shakeAmp * math.max(0, 1 - dt * 11.5) -- 120
	else -- 120
		self.shakeAmp = 0 -- 122
		self.shakeX = 0 -- 123
		self.shakeY = 0 -- 124
	end -- 124
	self:recomputeMetrics(p, w, h) -- 127
end -- 56
function CameraDirector.prototype.targetCamY(self, p) -- 130
	if p.room.key == "outside" and p.player.y >= 60 then -- 130
		return 102 -- 132
	end -- 132
	return 82 + math.max(0, p.player.y - 36) * 0.35 -- 134
end -- 130
function CameraDirector.prototype.recomputeMetrics(self, p, w, h) -- 137
	self.viewW = math.max(320, w) -- 138
	self.viewH = math.max(180, h) -- 139
	self.ppu = self.viewH / BASE_VIEW_UNITS_H * self.zoom -- 140
	self.groundScreenY = self.viewH * GROUND_SCREEN_FRAC -- 141
	local halfWorldW = self.viewW * 0.5 / self.ppu -- 144
	local spanX = p.room.maxX - p.room.minX -- 145
	if spanX <= halfWorldW * 2 then -- 145
		self.x = (p.room.minX + p.room.maxX) * 0.5 -- 147
	else -- 147
		local minCam = p.room.minX + halfWorldW -- 149
		local maxCam = p.room.maxX - halfWorldW -- 150
		if self.x < minCam then -- 150
			self.x = minCam -- 152
		end -- 152
		if self.x > maxCam then -- 152
			self.x = maxCam -- 155
		end -- 155
	end -- 155
end -- 137
function CameraDirector.prototype.sx(self, wx) -- 161
	return self.viewW * 0.5 + (wx - self.x) * self.ppu + self.shakeX -- 162
end -- 161
function CameraDirector.prototype.sy(self, wy, depth) -- 166
	if depth == nil then -- 166
		depth = 0 -- 166
	end -- 166
	local yOffset = (self.y - 82) * 0.45 -- 167
	return self.groundScreenY + (wy + depth - yOffset) * self.ppu + self.shakeY -- 168
end -- 166
function CameraDirector.prototype.len(self, worldLen) -- 172
	return worldLen * self.ppu -- 173
end -- 172
function CameraDirector.prototype.screenToWorld(self, screenX, screenY) -- 177
	local yOffset = (self.y - 82) * 0.45 -- 178
	return {x = self.x + (screenX - self.shakeX - self.viewW * 0.5) / self.ppu, y = yOffset + (screenY - self.shakeY - self.groundScreenY) / self.ppu} -- 179
end -- 177
return ____exports -- 177