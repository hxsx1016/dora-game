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
____exports.CameraDirector = __TS__Class() -- 29
local CameraDirector = ____exports.CameraDirector -- 29
CameraDirector.name = "CameraDirector" -- 29
function CameraDirector.prototype.____constructor(self) -- 29
	self.x = 0 -- 31
	self.y = 85 -- 32
	self.zoom = 1 -- 34
	self.shakeAmp = 0 -- 36
	self.shakeX = 0 -- 37
	self.shakeY = 0 -- 38
	self.shakePhase = 0 -- 39
	self.viewW = 1280 -- 44
	self.viewH = 720 -- 45
	self.ppu = 2.37 -- 46
	self.groundScreenY = 162 -- 47
end -- 29
function CameraDirector.prototype.setAnchorLock(self, lock) -- 50
	self.anchorLock = lock -- 51
end -- 50
function CameraDirector.prototype.getAnchorLock(self) -- 54
	return self.anchorLock -- 55
end -- 54
function CameraDirector.prototype.snap(self, p, w, h) -- 59
	self.anchorLock = nil -- 60
	local theme = themeOf(p.room.key) -- 61
	self.zoom = theme.defaultZoom -- 62
	self.shakeAmp = 0 -- 63
	self.shakeX = 0 -- 64
	self.shakeY = 0 -- 65
	self.x = p.player.x + p.player.facing * 42 -- 66
	self.y = self:targetCamY(p) -- 67
	self:recomputeMetrics(p, w, h) -- 68
end -- 59
function CameraDirector.prototype.addShake(self, amount) -- 72
	if amount > self.shakeAmp then -- 72
		self.shakeAmp = math.min(18, amount) -- 74
	else -- 74
		self.shakeAmp = math.min(18, self.shakeAmp + amount * 0.45) -- 76
	end -- 76
end -- 72
function CameraDirector.prototype.update(self, dt, p, w, h) -- 81
	if self.anchorLock ~= nil then -- 81
		self.shakeAmp = 0 -- 83
		self.shakeX = 0 -- 84
		self.shakeY = 0 -- 85
		self:recomputeMetrics(p, w, h) -- 86
		return -- 87
	end -- 87
	local theme = themeOf(p.room.key) -- 89
	local desiredZoom = theme.defaultZoom -- 90
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 90
		desiredZoom = 1.24 -- 94
	elseif not p.childMode and p.escort.state == "calming" then -- 94
		desiredZoom = 1.2 -- 96
	elseif p.room.key == "gate" then -- 96
		if p.phase == "gate-hold" then -- 96
			desiredZoom = 0.88 -- 99
		elseif p.phase == "gate-count" then -- 99
			desiredZoom = 1.15 -- 101
		elseif p.phase == "gate-send" then -- 101
			desiredZoom = 1.06 -- 103
		end -- 103
	elseif p.room.key == "outside" then -- 103
		desiredZoom = p.player.x < 560 and 0.94 or 1.02 -- 107
	elseif p.room.key == "tower" and p.phase ~= "tower-wait" then -- 107
		desiredZoom = 1.22 -- 109
	end -- 109
	local zk = math.min(1, dt * 3.8) -- 112
	self.zoom = self.zoom + (desiredZoom - self.zoom) * zk -- 113
	local lookAhead = p.player.facing * 48 -- 116
	if not p.childMode and p.aimX > 0 and w > 0 then -- 116
		local normMouse = (p.aimX / w - 0.5) * 2 -- 118
		lookAhead = lookAhead + normMouse * 36 -- 119
	end -- 119
	if p.room.key == "outside" and p.player.x < 520 then -- 119
		lookAhead = p.player.x < 280 and 96 or 18 -- 123
	end -- 123
	if p.room.key == "gate" and p.phase == "gate-hold" then -- 123
		lookAhead = 120 -- 126
	end -- 126
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 126
		lookAhead = (p.partner.x - p.player.x) * 0.5 -- 129
	end -- 129
	local tx = p.player.x + lookAhead -- 132
	local ty = self:targetCamY(p) -- 133
	local followK = math.min(1, dt * 6.5) -- 134
	self.x = self.x + (tx - self.x) * followK -- 135
	self.y = self.y + (ty - self.y) * math.min(1, dt * 5) -- 136
	if self.shakeAmp > 0.08 then -- 136
		self.shakePhase = self.shakePhase + dt * 68 -- 140
		self.shakeX = math.sin(self.shakePhase * 1.3) * self.shakeAmp -- 141
		self.shakeY = math.cos(self.shakePhase * 1.7) * self.shakeAmp * 0.72 -- 142
		self.shakeAmp = self.shakeAmp * math.max(0, 1 - dt * 11.5) -- 143
	else -- 143
		self.shakeAmp = 0 -- 145
		self.shakeX = 0 -- 146
		self.shakeY = 0 -- 147
	end -- 147
	self:recomputeMetrics(p, w, h) -- 150
end -- 81
function CameraDirector.prototype.targetCamY(self, p) -- 153
	if p.room.key == "outside" and p.player.y >= 60 then -- 153
		return 102 -- 155
	end -- 155
	return 82 + math.max(0, p.player.y - 36) * 0.35 -- 157
end -- 153
function CameraDirector.prototype.recomputeMetrics(self, p, w, h) -- 160
	self.viewW = math.max(320, w) -- 161
	self.viewH = math.max(180, h) -- 162
	self.groundScreenY = self.viewH * GROUND_SCREEN_FRAC -- 163
	local lock = self.anchorLock -- 165
	if lock ~= nil then -- 165
		local basePpu = self.viewH / BASE_VIEW_UNITS_H -- 167
		local worldSpan = lock.thresholdWorldX - lock.footWorldX -- 168
		if lock.screenThresholdFracX ~= nil and math.abs(worldSpan) > 0.0001 then -- 168
			local screenSpan = (lock.screenThresholdFracX - lock.screenFootFracX) * self.viewW -- 170
			local solvedPpu = screenSpan / worldSpan -- 171
			if solvedPpu > 0.05 then -- 171
				self.ppu = solvedPpu -- 173
				self.zoom = solvedPpu / basePpu -- 174
			else -- 174
				if lock.zoomOverride ~= nil and lock.zoomOverride > 0.05 then -- 174
					self.zoom = lock.zoomOverride -- 177
				end -- 177
				self.ppu = basePpu * self.zoom -- 179
			end -- 179
		else -- 179
			if lock.zoomOverride ~= nil and lock.zoomOverride > 0.05 then -- 179
				self.zoom = lock.zoomOverride -- 183
			end -- 183
			self.ppu = basePpu * self.zoom -- 185
		end -- 185
		local footDepth = lock.footDepth or 0 -- 187
		self.x = lock.footWorldX - (lock.screenFootFracX - 0.5) * self.viewW / self.ppu -- 188
		local desiredYOffset = lock.footWorldY + footDepth - (lock.screenFootFracY * self.viewH - self.groundScreenY) / self.ppu -- 189
		self.y = 82 + desiredYOffset / 0.45 -- 190
		return -- 191
	end -- 191
	self.ppu = self.viewH / BASE_VIEW_UNITS_H * self.zoom -- 194
	local halfWorldW = self.viewW * 0.5 / self.ppu -- 197
	local spanX = p.room.maxX - p.room.minX -- 198
	if spanX <= halfWorldW * 2 then -- 198
		self.x = (p.room.minX + p.room.maxX) * 0.5 -- 200
	else -- 200
		local minCam = p.room.minX + halfWorldW -- 202
		local maxCam = p.room.maxX - halfWorldW -- 203
		if self.x < minCam then -- 203
			self.x = minCam -- 205
		end -- 205
		if self.x > maxCam then -- 205
			self.x = maxCam -- 208
		end -- 208
	end -- 208
end -- 160
function CameraDirector.prototype.sx(self, wx) -- 214
	return self.viewW * 0.5 + (wx - self.x) * self.ppu + self.shakeX -- 215
end -- 214
function CameraDirector.prototype.sy(self, wy, depth) -- 219
	if depth == nil then -- 219
		depth = 0 -- 219
	end -- 219
	local yOffset = (self.y - 82) * 0.45 -- 220
	return self.groundScreenY + (wy + depth - yOffset) * self.ppu + self.shakeY -- 221
end -- 219
function CameraDirector.prototype.len(self, worldLen) -- 225
	return worldLen * self.ppu -- 226
end -- 225
function CameraDirector.prototype.worldToScreen(self, wx, wy, depth) -- 230
	if depth == nil then -- 230
		depth = 0 -- 230
	end -- 230
	return { -- 231
		x = self:sx(wx), -- 232
		y = self:sy(wy, depth) -- 233
	} -- 233
end -- 230
function CameraDirector.prototype.screenToWorld(self, screenX, screenY) -- 238
	local yOffset = (self.y - 82) * 0.45 -- 239
	return {x = self.x + (screenX - self.shakeX - self.viewW * 0.5) / self.ppu, y = yOffset + (screenY - self.shakeY - self.groundScreenY) / self.ppu} -- 240
end -- 238
return ____exports -- 238