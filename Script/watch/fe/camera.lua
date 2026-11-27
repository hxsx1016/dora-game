-- [ts]: camera.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local ____depth = require("Script.watch.depth") -- 9
local DEPTH_Y_SCALE = ____depth.DEPTH_Y_SCALE -- 9
local ____theme = require("Script.watch.fe.theme") -- 10
local themeOf = ____theme.themeOf -- 10
--- 基础竖直世界视野高度（zoom=1 时屏幕纵向容纳约 304 世界单位，1280×720 下约 2.37 px/单位）
local BASE_VIEW_UNITS_H = 304 -- 13
--- 地面基准线落在屏幕从底往上的比例（约 22.5%，留出大气天际与底部叙事字幕带）
local GROUND_SCREEN_FRAC = 0.225 -- 15
____exports.CameraDirector = __TS__Class() -- 30
local CameraDirector = ____exports.CameraDirector -- 30
CameraDirector.name = "CameraDirector" -- 30
function CameraDirector.prototype.____constructor(self) -- 30
	self.x = 0 -- 32
	self.y = 85 -- 33
	self.zoom = 1 -- 35
	self.shakeAmp = 0 -- 37
	self.shakeX = 0 -- 38
	self.shakeY = 0 -- 39
	self.shakePhase = 0 -- 40
	self.viewW = 1280 -- 45
	self.viewH = 720 -- 46
	self.ppu = 2.37 -- 47
	self.groundScreenY = 162 -- 48
end -- 30
function CameraDirector.prototype.setAnchorLock(self, lock) -- 51
	self.anchorLock = lock -- 52
end -- 51
function CameraDirector.prototype.getAnchorLock(self) -- 55
	return self.anchorLock -- 56
end -- 55
function CameraDirector.prototype.snap(self, p, w, h) -- 60
	self.anchorLock = nil -- 61
	local theme = themeOf(p.room.key) -- 62
	self.zoom = theme.defaultZoom -- 63
	self.shakeAmp = 0 -- 64
	self.shakeX = 0 -- 65
	self.shakeY = 0 -- 66
	self.x = p.player.x + p.player.facing * 42 -- 67
	self.y = self:targetCamY(p) -- 68
	self:recomputeMetrics(p, w, h) -- 69
end -- 60
function CameraDirector.prototype.addShake(self, amount) -- 73
	if amount > self.shakeAmp then -- 73
		self.shakeAmp = math.min(18, amount) -- 75
	else -- 75
		self.shakeAmp = math.min(18, self.shakeAmp + amount * 0.45) -- 77
	end -- 77
end -- 73
function CameraDirector.prototype.update(self, dt, p, w, h) -- 82
	if self.anchorLock ~= nil then -- 82
		self.shakeAmp = 0 -- 84
		self.shakeX = 0 -- 85
		self.shakeY = 0 -- 86
		self:recomputeMetrics(p, w, h) -- 87
		return -- 88
	end -- 88
	local theme = themeOf(p.room.key) -- 90
	local desiredZoom = theme.defaultZoom -- 91
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 91
		desiredZoom = 1.24 -- 95
	elseif not p.childMode and p.escort.state == "calming" then -- 95
		desiredZoom = 1.2 -- 97
	elseif p.room.key == "gate" then -- 97
		if p.phase == "gate-hold" then -- 97
			desiredZoom = 0.88 -- 100
		elseif p.phase == "gate-count" then -- 100
			desiredZoom = 1.15 -- 102
		elseif p.phase == "gate-wait" then -- 102
			desiredZoom = 1.12 -- 105
		elseif p.phase == "gate-hand" then -- 105
			desiredZoom = 1.22 -- 107
		elseif p.phase == "gate-send" then -- 107
			desiredZoom = 1.06 -- 109
		end -- 109
	elseif p.room.key == "museum" then -- 109
		desiredZoom = p.phase == "museum-cabinet" and 1.14 or 1.06 -- 113
	elseif p.room.key == "outside" then -- 113
		desiredZoom = p.player.x < 560 and 0.94 or 1.02 -- 116
	elseif p.room.key == "tower" and p.phase ~= "tower-wait" then -- 116
		desiredZoom = 1.22 -- 118
	end -- 118
	local zk = math.min(1, dt * 3.8) -- 121
	if p.reloadOpen then -- 121
		desiredZoom = math.max(desiredZoom, 1.16) -- 124
	end -- 124
	self.zoom = self.zoom + (desiredZoom - self.zoom) * zk -- 126
	local lookAhead = p.player.facing * 48 -- 129
	if not p.childMode and p.aimX > 0 and w > 0 then -- 129
		local normMouse = (p.aimX / w - 0.5) * 2 -- 131
		lookAhead = lookAhead + normMouse * 36 -- 132
	end -- 132
	if p.room.key == "outside" and p.player.x < 520 then -- 132
		lookAhead = p.player.x < 280 and 96 or 18 -- 136
	end -- 136
	if p.room.key == "gate" and p.phase == "gate-hold" then -- 136
		lookAhead = 120 -- 139
	end -- 139
	if p.room.key == "prologue" and p.phase == "prologue-give" then -- 139
		lookAhead = (p.partner.x - p.player.x) * 0.5 -- 142
	end -- 142
	local tx = p.player.x + lookAhead -- 145
	local ty = self:targetCamY(p) -- 146
	local followK = math.min(1, dt * 6.5) -- 147
	self.x = self.x + (tx - self.x) * followK -- 148
	self.y = self.y + (ty - self.y) * math.min(1, dt * 5) -- 149
	if self.shakeAmp > 0.08 then -- 149
		self.shakePhase = self.shakePhase + dt * 68 -- 153
		self.shakeX = math.sin(self.shakePhase * 1.3) * self.shakeAmp -- 154
		self.shakeY = math.cos(self.shakePhase * 1.7) * self.shakeAmp * 0.72 -- 155
		self.shakeAmp = self.shakeAmp * math.max(0, 1 - dt * 11.5) -- 156
	else -- 156
		self.shakeAmp = 0 -- 158
		self.shakeX = 0 -- 159
		self.shakeY = 0 -- 160
	end -- 160
	self:recomputeMetrics(p, w, h) -- 163
end -- 82
function CameraDirector.prototype.targetCamY(self, p) -- 166
	if p.room.key == "outside" and p.player.y >= 60 then -- 166
		return 102 -- 168
	end -- 168
	return 82 + math.max(0, p.player.y - 36) * 0.35 -- 170
end -- 166
function CameraDirector.prototype.recomputeMetrics(self, p, w, h) -- 173
	self.viewW = math.max(320, w) -- 174
	self.viewH = math.max(180, h) -- 175
	self.groundScreenY = self.viewH * GROUND_SCREEN_FRAC -- 176
	local lock = self.anchorLock -- 178
	if lock ~= nil then -- 178
		local basePpu = self.viewH / BASE_VIEW_UNITS_H -- 180
		local worldSpan = lock.thresholdWorldX - lock.footWorldX -- 181
		if lock.screenThresholdFracX ~= nil and math.abs(worldSpan) > 0.0001 then -- 181
			local screenSpan = (lock.screenThresholdFracX - lock.screenFootFracX) * self.viewW -- 183
			local solvedPpu = screenSpan / worldSpan -- 184
			if solvedPpu > 0.05 then -- 184
				self.ppu = solvedPpu -- 186
				self.zoom = solvedPpu / basePpu -- 187
			else -- 187
				if lock.zoomOverride ~= nil and lock.zoomOverride > 0.05 then -- 187
					self.zoom = lock.zoomOverride -- 190
				end -- 190
				self.ppu = basePpu * self.zoom -- 192
			end -- 192
		else -- 192
			if lock.zoomOverride ~= nil and lock.zoomOverride > 0.05 then -- 192
				self.zoom = lock.zoomOverride -- 196
			end -- 196
			self.ppu = basePpu * self.zoom -- 198
		end -- 198
		local footDepth = lock.footDepth or 0 -- 200
		self.x = lock.footWorldX - (lock.screenFootFracX - 0.5) * self.viewW / self.ppu -- 201
		local desiredYOffset = lock.footWorldY + footDepth * DEPTH_Y_SCALE - (lock.screenFootFracY * self.viewH - self.groundScreenY) / self.ppu -- 202
		self.y = 82 + desiredYOffset / 0.45 -- 203
		return -- 204
	end -- 204
	self.ppu = self.viewH / BASE_VIEW_UNITS_H * self.zoom -- 207
	local halfWorldW = self.viewW * 0.5 / self.ppu -- 210
	local spanX = p.room.maxX - p.room.minX -- 211
	if spanX <= halfWorldW * 2 then -- 211
		self.x = (p.room.minX + p.room.maxX) * 0.5 -- 213
	else -- 213
		local minCam = p.room.minX + halfWorldW -- 215
		local maxCam = p.room.maxX - halfWorldW -- 216
		if self.x < minCam then -- 216
			self.x = minCam -- 218
		end -- 218
		if self.x > maxCam then -- 218
			self.x = maxCam -- 221
		end -- 221
	end -- 221
end -- 173
function CameraDirector.prototype.sx(self, wx) -- 227
	return self.viewW * 0.5 + (wx - self.x) * self.ppu + self.shakeX -- 228
end -- 227
function CameraDirector.prototype.sy(self, wy, depth) -- 232
	if depth == nil then -- 232
		depth = 0 -- 232
	end -- 232
	local yOffset = (self.y - 82) * 0.45 -- 233
	return self.groundScreenY + (wy + depth * DEPTH_Y_SCALE - yOffset) * self.ppu + self.shakeY -- 234
end -- 232
function CameraDirector.prototype.len(self, worldLen) -- 238
	return worldLen * self.ppu -- 239
end -- 238
function CameraDirector.prototype.worldToScreen(self, wx, wy, depth) -- 243
	if depth == nil then -- 243
		depth = 0 -- 243
	end -- 243
	return { -- 244
		x = self:sx(wx), -- 245
		y = self:sy(wy, depth) -- 246
	} -- 246
end -- 243
function CameraDirector.prototype.screenToWorld(self, screenX, screenY) -- 251
	local yOffset = (self.y - 82) * 0.45 -- 252
	return {x = self.x + (screenX - self.shakeX - self.viewW * 0.5) / self.ppu, y = yOffset + (screenY - self.shakeY - self.groundScreenY) / self.ppu} -- 253
end -- 251
return ____exports -- 251