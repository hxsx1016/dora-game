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
		elseif p.phase == "gate-wait" then -- 101
			desiredZoom = 1.12 -- 104
		elseif p.phase == "gate-hand" then -- 104
			desiredZoom = 1.22 -- 106
		elseif p.phase == "gate-send" then -- 106
			desiredZoom = 1.06 -- 108
		end -- 108
	elseif p.room.key == "museum" then -- 108
		desiredZoom = p.phase == "museum-cabinet" and 1.14 or 1.06 -- 112
	elseif p.room.key == "outside" then -- 112
		desiredZoom = p.player.x < 560 and 0.94 or 1.02 -- 115
	elseif p.room.key == "tower" and p.phase ~= "tower-wait" then -- 115
		desiredZoom = 1.22 -- 117
	end -- 117
	local zk = math.min(1, dt * 3.8) -- 120
	if p.reloadOpen then -- 120
		desiredZoom = math.max(desiredZoom, 1.16) -- 123
	end -- 123
	self.zoom = self.zoom + (desiredZoom - self.zoom) * zk -- 125
	local lookAhead = p.player.facing * 48 -- 128
	if not p.childMode and p.aimX > 0 and w > 0 then -- 128
		local normMouse = (p.aimX / w - 0.5) * 2 -- 130
		lookAhead = lookAhead + normMouse * 36 -- 131
	end -- 131
	if p.room.key == "outside" and p.player.x < 520 then -- 131
		lookAhead = p.player.x < 280 and 96 or 18 -- 135
	end -- 135
	if p.room.key == "gate" and p.phase == "gate-hold" then -- 135
		lookAhead = 120 -- 138
	end -- 138
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 138
		lookAhead = (p.partner.x - p.player.x) * 0.5 -- 141
	end -- 141
	local tx = p.player.x + lookAhead -- 144
	local ty = self:targetCamY(p) -- 145
	local followK = math.min(1, dt * 6.5) -- 146
	self.x = self.x + (tx - self.x) * followK -- 147
	self.y = self.y + (ty - self.y) * math.min(1, dt * 5) -- 148
	if self.shakeAmp > 0.08 then -- 148
		self.shakePhase = self.shakePhase + dt * 68 -- 152
		self.shakeX = math.sin(self.shakePhase * 1.3) * self.shakeAmp -- 153
		self.shakeY = math.cos(self.shakePhase * 1.7) * self.shakeAmp * 0.72 -- 154
		self.shakeAmp = self.shakeAmp * math.max(0, 1 - dt * 11.5) -- 155
	else -- 155
		self.shakeAmp = 0 -- 157
		self.shakeX = 0 -- 158
		self.shakeY = 0 -- 159
	end -- 159
	self:recomputeMetrics(p, w, h) -- 162
end -- 81
function CameraDirector.prototype.targetCamY(self, p) -- 165
	if p.room.key == "outside" and p.player.y >= 60 then -- 165
		return 102 -- 167
	end -- 167
	return 82 + math.max(0, p.player.y - 36) * 0.35 -- 169
end -- 165
function CameraDirector.prototype.recomputeMetrics(self, p, w, h) -- 172
	self.viewW = math.max(320, w) -- 173
	self.viewH = math.max(180, h) -- 174
	self.groundScreenY = self.viewH * GROUND_SCREEN_FRAC -- 175
	local lock = self.anchorLock -- 177
	if lock ~= nil then -- 177
		local basePpu = self.viewH / BASE_VIEW_UNITS_H -- 179
		local worldSpan = lock.thresholdWorldX - lock.footWorldX -- 180
		if lock.screenThresholdFracX ~= nil and math.abs(worldSpan) > 0.0001 then -- 180
			local screenSpan = (lock.screenThresholdFracX - lock.screenFootFracX) * self.viewW -- 182
			local solvedPpu = screenSpan / worldSpan -- 183
			if solvedPpu > 0.05 then -- 183
				self.ppu = solvedPpu -- 185
				self.zoom = solvedPpu / basePpu -- 186
			else -- 186
				if lock.zoomOverride ~= nil and lock.zoomOverride > 0.05 then -- 186
					self.zoom = lock.zoomOverride -- 189
				end -- 189
				self.ppu = basePpu * self.zoom -- 191
			end -- 191
		else -- 191
			if lock.zoomOverride ~= nil and lock.zoomOverride > 0.05 then -- 191
				self.zoom = lock.zoomOverride -- 195
			end -- 195
			self.ppu = basePpu * self.zoom -- 197
		end -- 197
		local footDepth = lock.footDepth or 0 -- 199
		self.x = lock.footWorldX - (lock.screenFootFracX - 0.5) * self.viewW / self.ppu -- 200
		local desiredYOffset = lock.footWorldY + footDepth - (lock.screenFootFracY * self.viewH - self.groundScreenY) / self.ppu -- 201
		self.y = 82 + desiredYOffset / 0.45 -- 202
		return -- 203
	end -- 203
	self.ppu = self.viewH / BASE_VIEW_UNITS_H * self.zoom -- 206
	local halfWorldW = self.viewW * 0.5 / self.ppu -- 209
	local spanX = p.room.maxX - p.room.minX -- 210
	if spanX <= halfWorldW * 2 then -- 210
		self.x = (p.room.minX + p.room.maxX) * 0.5 -- 212
	else -- 212
		local minCam = p.room.minX + halfWorldW -- 214
		local maxCam = p.room.maxX - halfWorldW -- 215
		if self.x < minCam then -- 215
			self.x = minCam -- 217
		end -- 217
		if self.x > maxCam then -- 217
			self.x = maxCam -- 220
		end -- 220
	end -- 220
end -- 172
function CameraDirector.prototype.sx(self, wx) -- 226
	return self.viewW * 0.5 + (wx - self.x) * self.ppu + self.shakeX -- 227
end -- 226
function CameraDirector.prototype.sy(self, wy, depth) -- 231
	if depth == nil then -- 231
		depth = 0 -- 231
	end -- 231
	local yOffset = (self.y - 82) * 0.45 -- 232
	return self.groundScreenY + (wy + depth - yOffset) * self.ppu + self.shakeY -- 233
end -- 231
function CameraDirector.prototype.len(self, worldLen) -- 237
	return worldLen * self.ppu -- 238
end -- 237
function CameraDirector.prototype.worldToScreen(self, wx, wy, depth) -- 242
	if depth == nil then -- 242
		depth = 0 -- 242
	end -- 242
	return { -- 243
		x = self:sx(wx), -- 244
		y = self:sy(wy, depth) -- 245
	} -- 245
end -- 242
function CameraDirector.prototype.screenToWorld(self, screenX, screenY) -- 250
	local yOffset = (self.y - 82) * 0.45 -- 251
	return {x = self.x + (screenX - self.shakeX - self.viewW * 0.5) / self.ppu, y = yOffset + (screenY - self.shakeY - self.groundScreenY) / self.ppu} -- 252
end -- 250
return ____exports -- 250